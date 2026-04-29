#Include "Protheus.ch"
#Include "fileio.ch"
#Include "Totvs.ch"

// =============================================================================
// BRSPED_ALL.PRW
// Consolidacao de todos os programas de analise e ajuste de arquivos SPED EFD
// Versao : 3.00
// Autor  : marioantonaccio
// Desde  : 13/04/2026
//
// FUNCOES DISPONIVEIS (User Functions - chamadas via menu/RPW):
//   BRSPEDX   - Ajuste de CST, duplicidades C190 e H010 (versao melhorada)
//   BRSPED_NF - Verificacao de valores NF: confronto SPED x Protheus SF1
//   BRSPEDN090- Correcao proporcional VL_OPR do C190 vs VL_DOC do C100
//
// OBSERVACAO SOBRE NOMES DE FUNCOES EM ADVPL:
//   O compilador AdvPL trunca nomes de funcao em 10 caracteres.
//   Todos os nomes neste arquivo foram revisados e limitados a 10 caracteres.
//   Funcoes renomeadas em relacao aos originais:
//     C190_ProcessaDupl()   -> C190ProcDp()   (10 chars)
//     C190_GravaSomatorio() -> C190GravSm()   (10 chars)
//     RebuildLine()         -> RebuildLin()   (10 chars)  [era 11]
//     BRSPEDNF01()          -> BRSPEDNF01()   (10 chars OK)
//     BRSPEDN091()          -> BRSPEDN091()   (10 chars OK)
//     BRSPEDN092()          -> BRSPEDN092()   (10 chars OK)
// =============================================================================

// =============================================================================
// BLOCO 1: BRSPEDX - Ajuste completo do SPED (CST, duplicidades C190, H010)
// =============================================================================

/*/{Protheus.doc} BRSPEDX
Programa principal: analisa o arquivo SPED EFD gerado e faz correcoes,
gerando um novo arquivo _new.txt e LOG detalhado.
Operacoes realizadas:
  - Ajuste de CST de 2 para 3 digitos (C170, D190, C190)
  - Limpeza de campo 0220 e descricao 0305
  - Consolidacao de duplicidades C190 por chave CST+CFOP dentro de cada C100
  - Ajuste de H010 conforme estoques por armazem (tabela SB9)
  - Acerto de todos os totalizadores (C990, H990, H999, 9900, 9999...)
  - Geracao de arquivos auxiliares de deposito (HARA, HGUA)
@type UserFunction
@version 3.00
@author marioantonaccio
@since 13/04/2026
@return NIL
/*/
User Function BRSPEDX()

    Local cMsgIntro := "" as character

    cMsgIntro := ;
        "Este programa executa:" + CRLF + ;
        " " + Chr(149) + " Leitura completa do arquivo TXT" + CRLF + ;
        " " + Chr(149) + " Separacao dos campos via '|'(pipe)" + CRLF + ;
        " " + Chr(149) + " Ajuste de CST de 2 para 3 digitos (C170, D190, C190)" + CRLF + ;
        " " + Chr(149) + " Verificacao e consolidacao de duplicidades C190" + CRLF + ;
        " " + Chr(149) + " Somatorio por grupo CST+CFOP do C190" + CRLF + ;
        " " + Chr(149) + " Processamento H010 por armazem (SB9)" + CRLF + ;
        " " + Chr(149) + " Acerto de totalizadores (C990, H990, H999, 9900, 9999)" + CRLF + ;
        " " + Chr(149) + " Geracao de LOG detalhado" + CRLF + CRLF + ;
        "Clique SIM para selecionar o arquivo."

    If .NOT. FWAlertNoYes(cMsgIntro, "Processador de Arquivos TXT / SPED")
        Return (NIL)
    Else
        Processa({|| BRSPED01()}, "Lendo arquivo....")
    EndIf

Return (NIL)

/*/{Protheus.doc} BRSPED01
Funcao principal de processamento do SPED: executa todos os passos de
ajuste, consolidacao e geracao dos arquivos de saida.
@type Static Function
@version 3.00
@author marioantonaccio
@since 13/04/2026
@return NIL
/*/
Static Function BRSPED01()

    // --- Arrays ---
    Local aCampos      := {}  as array
    Local aH010ARA     := {}  as array
    Local aH010GUA     := {}  as array
    Local aLinhas      := {}  as array
    Local aArmazem     := {}  as array
    Local aDep         := {}  as array

    // --- Strings ---
    Local cAntes       := " " as character
    Local cArqDest     := " " as character
    Local cArqHARA     := " " as character
    Local cArqHGUA     := " " as character
    Local cArqOrig     := " " as character
    Local cArqDelete   := " " as character
    Local cCFO         := " " as character
    Local cDataHoraFim := " " as character
    Local cDataHoraIni := " " as character
    Local cDiretorio   := " " as character
    Local cDrive       := " " as character
    Local cExtensao    := " " as character
    Local cHoraFim     := " " as character
    Local cHoraIni     := " " as character
    Local cLinha       := " " as character
    Local cLinhaNova   := " " as character
    Local cLocal       := " " as character
    Local cLogArq      := " " as character
    Local cNew         := " " as character
    Local cNome        := " " as character

    // --- Datas ---
    Local dDataInv            as Date

    // --- Numericos ---
    Local nAlt         := 0   as numeric
    Local nDC190       := 0   as numeric
    Local nDelete      := 0   as numeric
    Local nDH010       := 0   as numeric
    Local nDVH010      := 0   as numeric
    Local nExc         := 0   as numeric
    Local nHandle      := 0   as numeric
    Local nHARA        := 0   as numeric
    Local nHDest       := 0   as numeric
    Local nHGUA        := 0   as numeric
    Local nHLog        := 0   as numeric
    Local nHDelete     := 0   as numeric
    Local nIndex       := 0   as numeric
    Local nLocal       := 0   as numeric
    Local nQtd         := 0   as numeric
    Local nTotEst      := 0   as numeric
    Local nValor       := 0   as numeric

    // --- Logicos ---
    Local l02          := .F. as logical

    cDataHoraIni := DtoC(Date()) + " " + Time()
    cHoraIni     := Time()

    // SELECAO DO ARQUIVO
    cArqOrig := cGetFile("Arquivos TXT (*.txt)|*.txt|", "Selecione o arquivo para processamento")
    If Empty(cArqOrig)
        FWAlertError("Nenhum arquivo selecionado.", "Selecao de arquivo", NIL)
        Return (NIL)
    EndIf

    SplitPath(cArqOrig, @cDrive, @cDiretorio, @cNome, @cExtensao)
    cArqDest   := cDrive + cDiretorio + ChgFileExt(cNome, "_new.txt")
    cLogArq    := cDrive + cDiretorio + ChgFileExt(cNome, ".log")
    cArqHARA   := cDrive + cDiretorio + ChgFileExt(cNome, "_HARA.txt")
    cArqHGUA   := cDrive + cDiretorio + ChgFileExt(cNome, "_HGUA.txt")
    cArqDelete := cDrive + cDiretorio + ChgFileExt(cNome, "_del.txt")

    // Remove arquivos anteriores
    If File(cArqDest)
        If FERASE(cArqDest) == -1
            FWAlertError("Nao foi possivel excluir o arquivo " + CRLF + cArqDest, "Erro na exclusao")
            Return (NIL)
        End
    End
    If File(cLogArq)
        If FERASE(cLogArq) == -1
            FWAlertError("Nao foi possivel excluir o arquivo " + CRLF + cLogArq, "Erro na exclusao")
            Return (NIL)
        End
    End
    If File(cArqHARA)
        If FERASE(cArqHARA) == -1
            FWAlertError("Nao foi possivel excluir o arquivo " + CRLF + cArqHARA, "Erro na exclusao")
            Return (NIL)
        End
    End
    If File(cArqHGUA)
        If FERASE(cArqHGUA) == -1
            FWAlertError("Nao foi possivel excluir o arquivo " + CRLF + cArqHGUA, "Erro na exclusao")
            Return (NIL)
        End
    End
    If File(cArqDelete)
        If FERASE(cArqDelete) == -1
            FWAlertError("Nao foi possivel excluir o arquivo " + CRLF + cArqDelete, "Erro na exclusao")
            Return (NIL)
        End
    End

    // Cria o LOG
    nHLog := FCreate(cLogArq)
    If nHLog < 0
        FWAlertError("Erro ao criar o arquivo de LOG.", "Erro", NIL)
        Return (NIL)
    End

    FWrite(nHLog, "LOG DO PROCESSAMENTO" + CRLF)
    FWrite(nHLog, "Arquivo origem  : " + cArqOrig     + CRLF)
    FWrite(nHLog, "Processo iniciado em : " + cDataHoraIni + CRLF + CRLF)

    // Leitura do arquivo origem
    If File(cArqOrig)
        FWMsgRun(, {|| nHandle := FT_FUse(cArqOrig)}, "Processando", "Aguarde.. lendo arquivo...")
        If nHandle == -1
            FWAlertError("Erro na abertura do arquivo.", "Erro na abertura", NIL)
            Return (NIL)
        End
        FT_FGoTop()
        aLinhas := {}
        While .NOT. FT_FEOF()
            cLinha := FT_FReadLn()
            AAdd(aLinhas, cLinha)
            FT_FSKIP()
        End
        FT_FUSE()
    Else
        FWAlertError("Arquivo nao encontrado.", "Nao encontrado", NIL)
        Return (NIL)
    EndIf

    // ==========================================================
    // PASSO 1: Ajustes simples de CST em C170, D190, 0220, 0305
    // ==========================================================
    FWrite(nHLog, "=== PASSO 1: AJUSTES DE CAMPOS ===" + CRLF + CRLF)
    ProcRegua(Len(aLinhas))

    For nIndex := 1 To Len(aLinhas)
        IncProc()
        aCampos    := StrTokArr(aLinhas[nIndex], "|")
        cLinhaNova := ""

        // C170 - Corrige CST com 2 posicoes para 3
        If aCampos[1] == "C170"
            l02 := .F.
            If Len(AllTrim(aCampos[10])) == 2
                l02   := .T.
                cCFO   := aCampos[11]
                cAntes := AllTrim(aCampos[10])
                cNew   := "0" + AllTrim(aCampos[10])
                aCampos[10] := cNew
                FWrite(nHLog, "ALTERACAO C170 - Linha " + Str(nIndex, 6) + CRLF)
                FWrite(nHLog, "  ANTES : " + cAntes + CRLF)
                FWrite(nHLog, "  DEPOIS: " + cNew   + CRLF + CRLF)
                nAlt++
                cAntes     := "|" + cAntes + "|" + cCFO + "|"
                cNew       := "|" + cNew   + "|" + cCFO + "|"
                cLinhaNova := StrTran(aLinhas[nIndex], cAntes, cNew, 1, 1)
                aLinhas[nIndex] := cLinhaNova
            End
        EndIf

        // D190 - Corrige CST com 2 posicoes para 3
        If aCampos[1] == "D190"
            If Len(AllTrim(aCampos[02])) == 2
                cCFO   := aCampos[03]
                cAntes := AllTrim(aCampos[02])
                cNew   := "0" + AllTrim(aCampos[02])
                aCampos[02] := cNew
                FWrite(nHLog, "ALTERACAO D190 - Linha " + Str(nIndex, 6) + CRLF)
                FWrite(nHLog, "  ANTES : " + cAntes + CRLF)
                FWrite(nHLog, "  DEPOIS: " + cNew   + CRLF + CRLF)
                nAlt++
                cAntes     := "|" + cAntes + "|" + cCFO + "|"
                cNew       := "|" + cNew   + "|" + cCFO + "|"
                cLinhaNova := StrTran(aLinhas[nIndex], cAntes, cNew, 1, 1)
                aLinhas[nIndex] := cLinhaNova
            End
        EndIf

        // 0220 - Remove conteudo do campo 4 quando ha apenas 4 campos
        If aCampos[1] == "0220"
            If Len(aCampos) == 4
                cAntes := "|" + AllTrim(aCampos[04]) + "|"
                cNew   := "| |"
                FWrite(nHLog, "ALTERACAO 0220 - Linha " + Str(nIndex, 6) + CRLF)
                FWrite(nHLog, "  ANTES : " + cAntes + CRLF)
                FWrite(nHLog, "  DEPOIS: " + cNew   + CRLF + CRLF)
                nAlt++
                cLinhaNova := StrTran(aLinhas[nIndex], cAntes, cNew, 1, 1)
                aLinhas[nIndex] := cLinhaNova
            End
        EndIf

        // 0305 - Forca descricao para 'USO INTERNO'
        If aCampos[1] == "0305"
            aCampos := StrTokArr(aLinhas[nIndex], "|")
            cAntes  := AllTrim(aCampos[03])
            cNew    := "USO INTERNO"
            aCampos[3] := cNew
            FWrite(nHLog, "ALTERACAO 0305 - Linha " + Str(nIndex, 6) + CRLF)
            FWrite(nHLog, "  ANTES : " + cAntes + CRLF)
            FWrite(nHLog, "  DEPOIS: " + cNew   + CRLF + CRLF)
            nAlt++
            cLinhaNova := RebuildLin(aCampos)
            aLinhas[nIndex] := cLinhaNova
        EndIf

    Next

    // ==========================================================
    // PASSO 2: Verificacao e consolidacao de duplicidades C190
    // ==========================================================
    FWrite(nHLog, "=== PASSO 2: DUPLICIDADES C190 ===" + CRLF + CRLF)

    nDC190 := C190ProcDp(@aLinhas, nHLog, @nAlt, @nExc)

    // ==========================================================
    // PASSO 3: Ajuste de CST de 2 para 3 digitos nos C190 remanescentes
    // ==========================================================
    FWrite(nHLog, "=== PASSO 3: AJUSTE CST C190 REMANESCENTES ===" + CRLF + CRLF)
    ProcRegua(Len(aLinhas))

    For nIndex := 1 To Len(aLinhas)
        IncProc()
        aCampos := StrTokArr(aLinhas[nIndex], "|")
        If aCampos[1] == "C190"
            If Len(AllTrim(aCampos[02])) == 2
                cCFO   := aCampos[03]
                cAntes := AllTrim(aCampos[02])
                cNew   := "0" + AllTrim(aCampos[02])
                aCampos[02] := cNew
                FWrite(nHLog, "ALTERACAO C190 CST - Linha " + Str(nIndex, 6) + CRLF)
                FWrite(nHLog, "  ANTES : " + cAntes + CRLF)
                FWrite(nHLog, "  DEPOIS: " + cNew   + CRLF + CRLF)
                nAlt++
                cAntes     := "|" + cAntes + "|" + cCFO + "|"
                cNew       := "|" + cNew   + "|" + cCFO + "|"
                cLinhaNova := StrTran(aLinhas[nIndex], cAntes, cNew, 1, 1)
                aLinhas[nIndex] := cLinhaNova
            End
        End
    Next

    // ==========================================================
    // PASSO 4: Processamento H010 - Armazens de Deposito (SB9)
    // ==========================================================
    FWrite(nHLog, "=== PASSO 4: PROCESSAMENTO H010 ===" + CRLF + CRLF)
    ProcRegua(Len(aLinhas))

    nDH010   := 0
    nDVH010  := 0
    cLocal   := ""
    aArmazem := {}

    For nIndex := 1 To Len(aLinhas)
        IncProc()
        cLinhaNova := ""
        aCampos    := StrTokArr(aLinhas[nIndex], "|")

        If aCampos[1] == "H005"
            dDataInv := CTOD(Substr(aCampos[2], 1, 2) + "/" + Substr(aCampos[2], 3, 2) + "/" + Substr(aCampos[2], 5, 4))
        End

        If aCampos[1] == "0005"
            If "BRASILUX DEPOSITO ARARAQUARA" $ AllTrim(aCampos[2])
                aArmazem := {"AF", "A3"}
                cLocal   := "ARA"
            End
            If "DEPOSITO" $ AllTrim(aCampos[2])
                aArmazem := {"G1", "G3"}
                cLocal   := "GUA"
            End
            If "MATRIZ" $ AllTrim(aCampos[2])
                aArmazem := {"G1", "G3", "AF", "A3"}
                cLocal   := "MAT"
            End
        End

        If aCampos[1] == "H010"
            nQtd   := Val(StrTran(AllTrim(aCampos[4]), ",", "."))
            nValor := Val(StrTran(AllTrim(aCampos[6]), ",", "."))

            For nLocal := 1 To Len(aArmazem)
                SB9->(dbSetOrder(1))
                If cLocal == "MAT"
                    If SB9->(dbSeek(xFilial("SB9") + Substr(aCampos[2], 1, 15) + aArmazem[nLocal] + DTOS(dDataInv)))
                        nQtd   -= SB9->B9_QINI
                        nValor -= SB9->B9_VINI1
                        If aArmazem[nLocal] $ "AF/A3"
                            AADD(aH010ARA, aLinhas[nIndex])
                        ElseIf aArmazem[nLocal] $ "G1/G3"
                            AADD(aH010GUA, aLinhas[nIndex])
                        End
                    End
                Else
                    If .NOT. SB9->(dbSeek(xFilial("SB9") + Substr(aCampos[2], 1, 15) + aArmazem[nLocal] + DTOS(dDataInv)))
                        nQtd   -= SB9->B9_QINI
                        nValor -= SB9->B9_VINI1
                    End
                End
            Next

            If nQtd <= 0
                nDH010++
                nDVH010 += Val(StrTran(AllTrim(aCampos[6]), ",", "."))
                cLinhaNova := StrTran(aLinhas[nIndex], "|H010|", "|H010__DELETE__|", 1, 1)
                aLinhas[nIndex] := cLinhaNova
                FWrite(nHLog, "EXCLUSAO H010 - Linha " + Str(nIndex, 6) + CRLF + CRLF)
                nExc++
            Else
                If Val(StrTran(AllTrim(aCampos[4]), ",", ".")) <> nQtd .OR. ;
                   Val(StrTran(AllTrim(aCampos[6]), ",", ".")) <> nValor
                    nDVH010 += (Val(StrTran(AllTrim(aCampos[6]), ",", ".")) - nValor)
                    FWrite(nHLog, "ALTERACAO H010 - Linha " + Str(nIndex, 6) + CRLF)
                    FWrite(nHLog, "  ANTES QTD : " + aCampos[4] + CRLF)
                    FWrite(nHLog, "  ANTES VAL : " + aCampos[6] + CRLF)
                    FWrite(nHLog, "  DEPOIS QTD: " + cValToChar(nQtd)   + CRLF)
                    FWrite(nHLog, "  DEPOIS VAL: " + cValToChar(nValor) + CRLF + CRLF)
                    nAlt++
                    aCampos[04]     := AllTrim(Transform(nQtd,   "@ER 999999999.999"))
                    aCampos[06]     := AllTrim(Transform(nValor, "@ER 999999999.99"))
                    cLinhaNova      := RebuildLin(aCampos)
                    aLinhas[nIndex] := cLinhaNova
                End
            End
        End
    Next

    // ==========================================================
    // PASSO 5: Acerto de totalizadores
    // ==========================================================
    nDelete := 0
    For nIndex := 1 To Len(aLinhas)
        If "DELETE__" $ aLinhas[nIndex]
            nDelete++
        End
    Next

    If nDelete > 0
        FWrite(nHLog, "=== PASSO 5: ACERTO DE TOTALIZADORES ===" + CRLF + CRLF)
        For nIndex := 1 To Len(aLinhas)
            aCampos := StrTokArr(aLinhas[nIndex], "|")

            If aCampos[1] == "H005"
                nQtd := Val(AllTrim(StrTran(aCampos[3], ",", "."))) - nDVH010
                FWrite(nHLog, "ALTERACAO H005 - Linha " + Str(nIndex, 6) + CRLF)
                FWrite(nHLog, "  Antes  : " + aCampos[3] + CRLF)
                FWrite(nHLog, "  Depois : " + cValToChar(nQtd) + CRLF + CRLF)
                nAlt++
                aCampos[3]      := AllTrim(Transform(nQtd, "@ER 999999999"))
                cLinhaNova      := RebuildLin(aCampos)
                aLinhas[nIndex] := cLinhaNova
            End

            If aCampos[1] == "C990"
                nQtd := Val(AllTrim(StrTran(aCampos[2], ",", "."))) - nDC190
                FWrite(nHLog, "ALTERACAO C990 - Linha " + Str(nIndex, 6) + CRLF)
                FWrite(nHLog, "  Antes  : " + aCampos[2] + CRLF)
                FWrite(nHLog, "  Depois : " + cValToChar(nQtd) + CRLF + CRLF)
                nAlt++
                aCampos[2]      := AllTrim(Transform(nQtd, "@ER 999999999"))
                cLinhaNova      := RebuildLin(aCampos)
                aLinhas[nIndex] := cLinhaNova
            End

            If aCampos[1] == "9900"
                If aCampos[2] == "C190"
                    nQtd := Val(AllTrim(StrTran(aCampos[3], ",", "."))) - nDC190
                    FWrite(nHLog, "ALTERACAO 9900-C190 - Linha " + Str(nIndex, 6) + CRLF)
                    FWrite(nHLog, "  Antes  : " + aCampos[3] + CRLF)
                    FWrite(nHLog, "  Depois : " + cValToChar(nQtd) + CRLF + CRLF)
                    nAlt++
                    aCampos[3]      := AllTrim(Transform(nQtd, "@ER 999999999"))
                    cLinhaNova      := RebuildLin(aCampos)
                    aLinhas[nIndex] := cLinhaNova
                End
                If aCampos[2] == "H010"
                    nQtd := Val(AllTrim(StrTran(aCampos[3], ",", "."))) - nDH010
                    FWrite(nHLog, "ALTERACAO 9900-H010 - Linha " + Str(nIndex, 6) + CRLF)
                    FWrite(nHLog, "  Antes  : " + aCampos[3] + CRLF)
                    FWrite(nHLog, "  Depois : " + cValToChar(nQtd) + CRLF + CRLF)
                    nAlt++
                    aCampos[3]      := AllTrim(Transform(nQtd, "@ER 999999999"))
                    cLinhaNova      := RebuildLin(aCampos)
                    aLinhas[nIndex] := cLinhaNova
                End
            End

            If aCampos[1] == "9999"
                nQtd := Val(AllTrim(StrTran(aCampos[2], ",", "."))) - nDelete
                FWrite(nHLog, "ALTERACAO 9999 - Linha " + Str(nIndex, 6) + CRLF)
                FWrite(nHLog, "  Antes  : " + aCampos[2] + CRLF)
                FWrite(nHLog, "  Depois : " + cValToChar(nQtd) + CRLF + CRLF)
                nAlt++
                aCampos[2]      := AllTrim(Transform(nQtd, "@ER 999999999"))
                cLinhaNova      := RebuildLin(aCampos)
                aLinhas[nIndex] := cLinhaNova
            End

            If aCampos[1] == "H999"
                nQtd := Val(AllTrim(StrTran(aCampos[2], ",", "."))) - nDH010
                FWrite(nHLog, "ALTERACAO H999 - Linha " + Str(nIndex, 6) + CRLF)
                FWrite(nHLog, "  Antes  : " + aCampos[2] + CRLF)
                FWrite(nHLog, "  Depois : " + cValToChar(nQtd) + CRLF + CRLF)
                nAlt++
                aCampos[2]      := AllTrim(Transform(nQtd, "@ER 999999999"))
                cLinhaNova      := RebuildLin(aCampos)
                aLinhas[nIndex] := cLinhaNova
            End

            If aCampos[1] == "H990"
                nQtd := Val(AllTrim(StrTran(aCampos[2], ",", "."))) - nDH010
                FWrite(nHLog, "ALTERACAO H990 - Linha " + Str(nIndex, 6) + CRLF)
                FWrite(nHLog, "  Antes  : " + aCampos[2] + CRLF)
                FWrite(nHLog, "  Depois : " + cValToChar(nQtd) + CRLF + CRLF)
                nAlt++
                aCampos[2]      := AllTrim(Transform(nQtd, "@ER 999999999"))
                cLinhaNova      := RebuildLin(aCampos)
                aLinhas[nIndex] := cLinhaNova
            End
        Next
    End

    // ==========================================================
    // PASSO 6: Gravacao do arquivo final e arquivo de deletados
    // ==========================================================
    nHDest := FCreate(cArqDest)
    If nHDest < 0
        FWAlertError("Erro ao criar arquivo destino.", "Nao Criado")
        Return (NIL)
    EndIf

    nHDelete := FCreate(cArqDelete)
    If nHDelete < 0
        FWAlertError("Erro ao criar o arquivo de LOG (delete).", "Erro", NIL)
        Return (NIL)
    End

    ProcRegua(Len(aLinhas))
    For nIndex := 1 To Len(aLinhas)
        IncProc()
        If .NOT. ("DELETE__" $ aLinhas[nIndex])
            FWrite(nHDest,   aLinhas[nIndex] + CRLF)
        Else
            FWrite(nHDelete, "Linha " + cValToChar(nIndex) + " - " + aLinhas[nIndex] + CRLF)
        EndIf
    Next
    FClose(nHDest)
    FClose(nHDelete)

    // ==========================================================
    // PASSO 7: Geracao de arquivos de deposito (HARA / HGUA)
    // ==========================================================
    If Len(aH010ARA) > 0
        nHARA := FCreate(cArqHARA)
        If nHARA < 0
            FWAlertError("Erro ao criar arquivo destino.", "Nao Criado")
            Return (NIL)
        EndIf
        nTotEst := 0
        For nIndex := 1 To Len(aH010ARA)
            aCampos := StrTokArr(aH010ARA[nIndex], "|")
            nTotEst += Val(StrTran(aCampos[06], ",", "."))
        End
        aDep := {}
        AADD(aDep, "|H001|0|")
        AADD(aDep, "|H005|" + GravaData(dDataInv, .F., 5) + "|" + AllTrim(Transform(nTotEst, "@ER 999999999.99")) + "|01|")
        For nIndex := 1 To Len(aH010ARA)
            AADD(aDep, aH010ARA[nIndex])
        Next
        AADD(aDep, "|H990|" + AllTrim(cValToChar(Len(aH010ARA) + 2)) + "|")
        ProcRegua(Len(aDep))
        For nIndex := 1 To Len(aDep)
            IncProc()
            FWrite(nHARA, aDep[nIndex] + CRLF)
        Next
        FClose(nHARA)
    End

    If Len(aH010GUA) > 0
        nHGUA := FCreate(cArqHGUA)
        If nHGUA < 0
            FWAlertError("Erro ao criar arquivo destino.", "Nao Criado")
            Return (NIL)
        EndIf
        nTotEst := 0
        For nIndex := 1 To Len(aH010GUA)
            aCampos := StrTokArr(aH010GUA[nIndex], "|")
            nTotEst += Val(StrTran(aCampos[06], ",", "."))
        End
        aDep := {}
        AADD(aDep, "|H001|0|")
        AADD(aDep, "|H005|" + GravaData(dDataInv, .F., 5) + "|" + AllTrim(Transform(nTotEst, "@ER 999999999.99")) + "|01|")
        For nIndex := 1 To Len(aH010GUA)
            AADD(aDep, aH010GUA[nIndex])
        Next
        AADD(aDep, "|H990|" + AllTrim(cValToChar(Len(aH010GUA) + 2)) + "|")
        ProcRegua(Len(aDep))
        For nIndex := 1 To Len(aDep)
            IncProc()
            FWrite(nHGUA, aDep[nIndex] + CRLF)
        Next
        FClose(nHGUA)
    End

    // FECHAMENTO DO LOG
    cDataHoraFim := DtoC(Date()) + " " + Time()
    cHoraFim     := Time()

    FWrite(nHLog, CRLF + "=== RESUMO FINAL ===" + CRLF)
    FWrite(nHLog, "Processamento finalizado em      : " + cDataHoraFim + CRLF)
    FWrite(nHLog, "Tempo Gasto Processamento        : " + Elaptime(cHoraIni, cHoraFim) + CRLF)
    FWrite(nHLog, "Arquivo gerado                   : " + cArqDest + CRLF)
    FWrite(nHLog, "Total de Linhas (original)       : " + cValToChar(Len(aLinhas)) + CRLF)
    FWrite(nHLog, "Alteracoes Efetuadas             : " + cValToChar(nAlt) + CRLF)
    FWrite(nHLog, "Exclusoes Efetuadas              : " + cValToChar(nExc) + CRLF)
    FWrite(nHLog, "Linhas excluidas C190 (dupl)     : " + cValToChar(nDC190) + CRLF)
    FWrite(nHLog, "Linhas excluidas H010            : " + cValToChar(nDH010) + CRLF)
    FWrite(nHLog, "Total Alteracoes/Exclusoes       : " + cValToChar(nExc + nAlt) + CRLF)

    FClose(nHLog)

    FWAlertSuccess("Processamento finalizado!" + CRLF + CRLF + ;
        "Arquivo gerado : " + cArqDest + CRLF + CRLF + ;
        "Log criado     : " + cLogArq, "Processo Concluido")

Return (NIL)

/*/{Protheus.doc} C190ProcDp
Varre todas as linhas C190 e consolida duplicidades com base na chave
CST+CFOP. Agrupa por bloco C100: ao encontrar um novo C100, reinicia
o hash do bloco. Dentro de cada bloco, a primeira ocorrencia de cada
chave CST+CFOP e mantida com a soma acumulada. As demais sao marcadas
para exclusao. Ao final grava no LOG o somatorio por grupo CST+CFOP.
Renomeada de C190_ProcessaDupl (21 chars) para C190ProcDp (10 chars).
@type Static Function
@version 3.00
@author marioantonaccio
@since 13/04/2026
@param aLinhas, array,   Array de linhas do arquivo (by reference)
@param nHLog,   numeric, Handle do arquivo de LOG
@param nAlt,    numeric, Contador de alteracoes (by reference)
@param nExc,    numeric, Contador de exclusoes (by reference)
@return numeric, quantidade de linhas C190 marcadas para exclusao
/*/
Static Function C190ProcDp(aLinhas, nHLog, nAlt, nExc)

    Local aHash      := {} as array
    Local aCampos    := {} as array
    Local cLinhaNova := "" as character
    Local cChave     := "" as character
    Local cCST       := "" as character
    Local nIndex     := 0  as numeric
    Local nPos       := 0  as numeric
    Local nDC190     := 0  as numeric
    Local nI         := 0  as numeric
    Local nV1        := 0  as numeric
    Local nV2        := 0  as numeric
    Local nV3        := 0  as numeric
    Local nV4        := 0  as numeric
    Local nV5        := 0  as numeric
    Local nV6        := 0  as numeric
    Local nV7        := 0  as numeric

    FWrite(nHLog, "--- Inicio varredura de duplicidades C190 ---" + CRLF + CRLF)
    ProcRegua(Len(aLinhas))

    For nIndex := 1 To Len(aLinhas)
        IncProc()
        aCampos := StrTokArr(aLinhas[nIndex], "|")

        // Novo bloco de nota: reinicia o hash do bloco corrente
        If aCampos[1] == "C100"
            If Len(aHash) > 0
                C190GravSm(aHash, nHLog)
                aHash := {}
            End
        End

        If aCampos[1] == "C190"
            // Normaliza CST para 3 digitos para efeito da chave
            cCST   := PadL(AllTrim(aCampos[2]), 3, "0")
            cChave := Substr(cCST, 2, 2) + "|" + AllTrim(aCampos[3])

            nV1 := Val(StrTran(AllTrim(aCampos[05]), ",", "."))
            nV2 := Val(StrTran(AllTrim(aCampos[06]), ",", "."))
            nV3 := Val(StrTran(AllTrim(aCampos[07]), ",", "."))
            nV4 := Val(StrTran(AllTrim(aCampos[08]), ",", "."))
            nV5 := Val(StrTran(AllTrim(aCampos[09]), ",", "."))
            nV6 := Val(StrTran(AllTrim(aCampos[10]), ",", "."))
            nV7 := Val(StrTran(AllTrim(aCampos[11]), ",", "."))

            // Procura chave no hash do bloco
            nPos := 0
            For nI := 1 To Len(aHash)
                If aHash[nI][1] == cChave
                    nPos := nI
                    Exit
                End
            Next

            If nPos == 0
                // Primeira ocorrencia: registra no hash
                AADD(aHash, {cChave, nIndex, nV1, nV2, nV3, nV4, nV5, nV6, nV7})
            Else
                // Duplicidade: acumula valores na primeira ocorrencia
                aHash[nPos][3] += nV1
                aHash[nPos][4] += nV2
                aHash[nPos][5] += nV3
                aHash[nPos][6] += nV4
                aHash[nPos][7] += nV5
                aHash[nPos][8] += nV6
                aHash[nPos][9] += nV7

                // Atualiza a linha da primeira ocorrencia com os valores acumulados
                aCampos := StrTokArr(aLinhas[aHash[nPos][2]], "|")
                aCampos[05] := AllTrim(Transform(aHash[nPos][3], "@ER 999999999.99"))
                aCampos[06] := AllTrim(Transform(aHash[nPos][4], "@ER 999999999.99"))
                aCampos[07] := AllTrim(Transform(aHash[nPos][5], "@ER 999999999.99"))
                aCampos[08] := AllTrim(Transform(aHash[nPos][6], "@ER 999999999.99"))
                aCampos[09] := AllTrim(Transform(aHash[nPos][7], "@ER 999999999.99"))
                aCampos[10] := AllTrim(Transform(aHash[nPos][8], "@ER 999999999.99"))
                aCampos[11] := AllTrim(Transform(aHash[nPos][9], "@ER 999999999.99"))
                cLinhaNova  := RebuildLin(aCampos)
                aLinhas[aHash[nPos][2]] := cLinhaNova
                nAlt++

                FWrite(nHLog, "C190 CONSOLIDADO - Chave [" + cChave + "]" + CRLF)
                FWrite(nHLog, "  Linha ref    : " + Str(aHash[nPos][2], 6) + CRLF)
                FWrite(nHLog, "  Linha dupl   : " + Str(nIndex, 6)         + CRLF)
                FWrite(nHLog, "  Val acumul   : " + Transform(aHash[nPos][3], "@ER 999999999.99") + CRLF + CRLF)

                // Marca linha duplicada para exclusao
                aCampos    := StrTokArr(aLinhas[nIndex], "|")
                aCampos[1] := "C190__DELETE__"
                cLinhaNova := RebuildLin(aCampos)
                aLinhas[nIndex] := cLinhaNova
                nDC190++
                nExc++
            End
        End
    Next

    // Grava somatorio do ultimo bloco processado
    If Len(aHash) > 0
        C190GravSm(aHash, nHLog)
    End

    FWrite(nHLog, "--- Fim varredura de duplicidades C190 - " + ;
        cValToChar(nDC190) + " linha(s) excluida(s) ---" + CRLF + CRLF)

Return (nDC190)

/*/{Protheus.doc} C190GravSm
Grava no LOG o somatorio por grupo CST+CFOP do bloco C190 processado.
Renomeada de C190_GravaSomatorio (22 chars) para C190GravSm (10 chars).
@type Static Function
@version 3.00
@author marioantonaccio
@since 13/04/2026
@param aHash,  array,   Hash com os grupos do bloco atual
@param nHLog,  numeric, Handle do arquivo de LOG
@return NIL
/*/
Static Function C190GravSm(aHash, nHLog)

    Local nI      := 0 as numeric
    Local nTotVal := 0 as numeric

    FWrite(nHLog, "--- SOMATORIO C190 POR GRUPO CST+CFOP ---" + CRLF)
    FWrite(nHLog, PadR("Chave CST+CFOP", 20) + " | " + ;
        PadL("VL_BC_ICMS",    14) + " | " + ;
        PadL("VL_ICMS",       14) + " | " + ;
        PadL("VL_BC_ICMS_ST", 14) + " | " + ;
        PadL("VL_ICMS_ST",    14) + " | " + ;
        PadL("VL_RED_BC",     14) + " | " + ;
        PadL("VL_IPI",        14) + " | " + ;
        PadL("VL_PIS_COF",    14) + CRLF)
    FWrite(nHLog, Replicate("-", 135) + CRLF)

    nTotVal := 0
    For nI := 1 To Len(aHash)
        FWrite(nHLog, ;
            PadR(aHash[nI][1], 20) + " | " + ;
            PadL(Transform(aHash[nI][3], "@ER 999999999.99"), 14) + " | " + ;
            PadL(Transform(aHash[nI][4], "@ER 999999999.99"), 14) + " | " + ;
            PadL(Transform(aHash[nI][5], "@ER 999999999.99"), 14) + " | " + ;
            PadL(Transform(aHash[nI][6], "@ER 999999999.99"), 14) + " | " + ;
            PadL(Transform(aHash[nI][7], "@ER 999999999.99"), 14) + " | " + ;
            PadL(Transform(aHash[nI][8], "@ER 999999999.99"), 14) + " | " + ;
            PadL(Transform(aHash[nI][9], "@ER 999999999.99"), 14) + CRLF)
        nTotVal += aHash[nI][3]
    Next

    FWrite(nHLog, Replicate("-", 135) + CRLF)
    FWrite(nHLog, PadR("TOTAL GRUPOS: " + cValToChar(Len(aHash)), 20) + " | " + ;
        PadL(Transform(nTotVal, "@ER 999999999.99"), 14) + CRLF + CRLF)

Return (NIL)

/*/{Protheus.doc} RebuildLin
Reconstroi a linha SPED a partir do array de campos, garantindo o
numero minimo de campos por tipo de registro e o delimitador pipe.
Renomeada de RebuildLine (11 chars) para RebuildLin (10 chars).
@type Static Function
@version 3.00
@author marioantonaccio
@since 13/04/2026
@param aCampos, array, Campos lidos na linha
@return character, linha reconstruida com delimitadores pipe
/*/
Static Function RebuildLin(aCampos)

    Local cLinhaR := "|" as character
    Local nI      := 0   as numeric

    // Garante numero minimo de campos por tipo de registro
    If aCampos[1] == "H010"
        If Len(aCampos) < 11
            For nI := 1 To 11 - Len(aCampos)
                AADD(aCampos, "")
            End
        End
    End

    If aCampos[1] == "C190" .OR. aCampos[1] == "C190__DELETE__"
        If Len(aCampos) < 12
            For nI := 1 To 12 - Len(aCampos)
                AADD(aCampos, "")
            End
        End
    End

    If aCampos[1] == "C170"
        If Len(aCampos) < 38
            For nI := 1 To 38 - Len(aCampos)
                AADD(aCampos, "")
            End
        End
    End

    If aCampos[1] == "0305"
        If Len(aCampos) < 4
            For nI := 1 To 4 - Len(aCampos)
                AADD(aCampos, "")
            End
        End
    End

    For nI := 1 To Len(aCampos)
        cLinhaR += aCampos[nI]
        If nI < Len(aCampos)
            cLinhaR += "|"
        EndIf
    Next

    cLinhaR += "|"

Return (cLinhaR)

// =============================================================================
// BLOCO 2: BRSPED_NF - Verificacao de valores NF x Protheus (SF1)
// =============================================================================

/*/{Protheus.doc} BRSPED_NF
Programa que le um arquivo SPED e verifica se os valores do registro
C100 conferem com os totais das notas fiscais de entrada no Protheus
(tabela SF1), gerando LOG com as divergencias encontradas.
@type UserFunction
@version 1.00
@author marioantonaccio
@since 25/03/2026
@return NIL
/*/
User Function BRSPED_NF()

    Local cMsgIntro := "" as character

    cMsgIntro := ;
        "Este programa executa:" + CRLF + ;
        "  Leitura completa do arquivo TXT" + CRLF + ;
        "  Separacao dos campos via '|'(pipe)" + CRLF + ;
        "  Verificacao de valores NF (SPED x Protheus SF1)" + CRLF + ;
        "  Geracao de LOG detalhado" + CRLF + CRLF + ;
        "Clique SIM para selecionar o arquivo."

    If .NOT. FWAlertNoYes(cMsgIntro, "Verificacao NF SPED x Protheus")
        Return (NIL)
    Else
        Processa({|| BRSPEDNF01()}, "Lendo arquivo....")
    EndIf

Return (NIL)

/*/{Protheus.doc} BRSPEDNF01
Funcao principal da verificacao NF: le o arquivo SPED, confronta
cada C100 com a nota fiscal correspondente na SF1 do Protheus e
registra divergencias no LOG.
@type Static Function
@version 1.00
@author marioantonaccio
@since 25/03/2026
@return NIL
/*/
Static Function BRSPEDNF01()

    Local aCampos      := {}  as array
    Local aLinhas      := {}  as array
    Local cArqOrig     := " " as character
    Local cArqDest     := " " as character
    Local cDataHoraFim := " " as character
    Local cDataHoraIni := " " as character
    Local cDiretorio   := " " as character
    Local cDrive       := " " as character
    Local cExtensao    := " " as character
    Local cHoraFim     := " " as character
    Local cHoraIni     := " " as character
    Local cLinha       := " " as character
    Local cLogArq      := " " as character
    Local cNome        := " " as character
    Local cCliFor      := " " as character
    Local cChvNFE      := " " as character
    Local nLinGer      := 0   as numeric
    Local nHandle      := 0   as numeric
    Local nHLog        := 0   as numeric
    Local nIndex       := 0   as numeric
    Local nC100        := 0   as numeric

    cDataHoraIni := DtoC(Date()) + " " + Time()
    cHoraIni     := Time()

    // Selecao do arquivo
    cArqOrig := cGetFile("Arquivos TXT (*.txt)|*.txt|", "Selecione o arquivo para processamento")
    If Empty(cArqOrig)
        FWAlertError("Nenhum arquivo selecionado.", "Selecao de arquivo", NIL)
        Return (NIL)
    EndIf

    SplitPath(cArqOrig, @cDrive, @cDiretorio, @cNome, @cExtensao)
    cArqDest := cDrive + cDiretorio + ChgFileExt(cNome, "_new.txt")
    cLogArq  := cDrive + cDiretorio + ChgFileExt(cNome, ".log")

    If File(cArqDest)
        If FERASE(cArqDest) == -1
            FWAlertError("Nao foi possivel excluir o arquivo " + CRLF + cArqDest, "Erro na exclusao")
            Return (NIL)
        End
    End
    If File(cLogArq)
        If FERASE(cLogArq) == -1
            FWAlertError("Nao foi possivel excluir o arquivo " + CRLF + cLogArq, "Erro na exclusao")
            Return (NIL)
        End
    End

    nHLog := FCreate(cLogArq)
    If nHLog < 0
        FWAlertError("Erro ao criar o arquivo de LOG.", "Erro", NIL)
        Return (NIL)
    End

    FWrite(nHLog, "LOG DO PROCESSAMENTO - VERIFICACAO NF" + CRLF)
    FWrite(nHLog, "Arquivo origem : " + cArqOrig     + CRLF)
    FWrite(nHLog, "Processo iniciado em : " + cDataHoraIni + CRLF + CRLF)

    If File(cArqOrig)
        FWMsgRun(, {|| nHandle := FT_FUse(cArqOrig)}, "Processando", "Aguarde.. lendo arquivo...")
        If nHandle == -1
            FWAlertError("Erro na abertura do arquivo.", "Erro na abertura", NIL)
            Return (NIL)
        End
        FT_FGoTop()
        aLinhas := {}
        While .NOT. FT_FEOF()
            cLinha := FT_FReadLn()
            AAdd(aLinhas, cLinha)
            FT_FSKIP()
        End
        FT_FUSE()
        FWrite(nHLog, "Total de Linhas: " + cValToChar(Len(aLinhas)) + CRLF + CRLF)
    Else
        FWAlertError("Arquivo nao encontrado.", "Nao encontrado", NIL)
        Return (NIL)
    EndIf

    ProcRegua(Len(aLinhas))

    For nIndex := 1 To Len(aLinhas)
        IncProc()
        aCampos := StrTokArr(aLinhas[nIndex], "|")

        // C100 - Cabecalho: confronta VL_DOC com SF1->F1_TOTAL
        If aCampos[1] == "C100" .AND. aCampos[2] == "0"
            cCliFor := Right(aCampos[3], 8)
            cChvNFE := If(Len(aCampos) >= 9, AllTrim(aCampos[9]), "")
            nC100   := If(Len(aCampos) >= 12, Val(StrTran(aCampos[12], ",", ".")), 0)

            SF1->(dbSetOrder(8))
            If SF1->(dbSeek(xFilial("SF1") + cChvNFE))
                If SF1->F1_TOTAL <> nC100
                    FWrite(nHLog, "Linha: " + cValToChar(nIndex) + " Divergencia Valor:" + CRLF + ;
                        "Nota: " + SF1->F1_DOC + "/" + SF1->F1_SERIE + ;
                        " Forn: " + SF1->F1_FORNECE + SF1->F1_LOJA + CRLF + ;
                        "Chave NFE: " + SF1->F1_CHVNFE + CRLF + ;
                        "Protheus: " + cValToChar(SF1->F1_TOTAL) + CRLF + ;
                        "SPED: "     + cValToChar(nC100) + CRLF + CRLF)
                    nLinGer++
                End
            End
        EndIf

    Next

    // Fechamento do LOG
    cDataHoraFim := DtoC(Date()) + " " + Time()
    cHoraFim     := Time()

    FWrite(nHLog, "Processamento finalizado em : " + cDataHoraFim + CRLF)
    FWrite(nHLog, "Tempo Gasto Processamento   : " + Elaptime(cHoraIni, cHoraFim) + CRLF)
    FWrite(nHLog, "Total Divergencias Geradas  : " + cValToChar(nLinGer) + CRLF)

    FClose(nHLog)

    FWAlertSuccess("Processamento finalizado!" + CRLF + CRLF + ;
        "Divergencias encontradas: " + cValToChar(nLinGer) + CRLF + CRLF + ;
        "Log criado: " + cLogArq, "Processo Concluido")

Return (NIL)

// =============================================================================
// BLOCO 3: BRSPEDN090 - Correcao proporcional VL_OPR C190 vs VL_DOC C100
// =============================================================================

/*/{Protheus.doc} BRSPEDN090
Programa que le um arquivo SPED EFD (TXT), compara o VL_DOC do bloco
C100 com a soma dos VL_OPR dos registros C190 filhos e:
  - Gera um arquivo _new.txt com as linhas C190 CORRIGIDAS (VL_OPR
    redistribuido proporcionalmente para fechar com o VL_DOC do C100)
  - Gera um arquivo .log com o detalhe de cada divergencia encontrada
    e os totalizadores gerais do processamento
Todas as demais linhas sao copiadas integralmente para o arquivo de saida.
@type UserFunction
@version 1.00
@author marioantonaccio
@since 09/04/2026
@return NIL
/*/
User Function BRSPEDN090()

    Local cMsgIntro := "" as character

    cMsgIntro := ;
        "Este programa executa:" + CRLF + ;
        " " + Chr(149) + " Leitura completa do arquivo SPED EFD (TXT)" + CRLF + ;
        " " + Chr(149) + " Separacao dos campos via pipe '|'" + CRLF + ;
        " " + Chr(149) + " Comparacao VL_DOC (C100) x soma VL_OPR (C190)" + CRLF + ;
        " " + Chr(149) + " Correcao proporcional dos VL_OPR no C190" + CRLF + ;
        " " + Chr(149) + " Geracao de arquivo _new.txt com linhas corrigidas" + CRLF + ;
        " " + Chr(149) + " Geracao de LOG detalhado com divergencias e totais" + CRLF + CRLF + ;
        "Clique SIM para selecionar o arquivo SPED EFD."

    If .NOT. FWAlertNoYes(cMsgIntro, "Correcao C190 x C100 - SPED EFD")
        Return (NIL)
    Else
        Processa({|| BRSPEDN091()}, "Processando SPED EFD...")
    EndIf

Return (NIL)

/*/{Protheus.doc} BRSPEDN091
Funcao principal: le o arquivo SPED, agrupa blocos C100+C190, identifica
divergencias, corrige os VL_OPR dos C190 e gera _new.txt e .log.
@type Static Function
@version 1.00
@author marioantonaccio
@since 09/04/2026
@return NIL
/*/
Static Function BRSPEDN091()

    // --- Controle de arquivo ---
    Local cArqOrig      := " " as character
    Local cArqDest      := " " as character
    Local cLogArq       := " " as character
    Local cDrive        := " " as character
    Local cDiretorio    := " " as character
    Local cNome         := " " as character
    Local cExtensao     := " " as character
    Local nHLog         := 0   as numeric
    Local nHDest        := 0   as numeric
    Local nHandle       := 0   as numeric

    // --- Leitura ---
    Local aLinhas       := {}  as array
    Local aCampos       := {}  as array
    Local cLinha        := " " as character

    // --- Controle de bloco C100 ---
    Local cIndOper      := " " as character
    Local cNumDoc       := " " as character
    Local cSerDoc       := " " as character
    Local cCnpjPart     := " " as character
    Local cChvNFe       := " " as character
    Local cDtDoc        := " " as character
    Local nVlDoc        := 0   as numeric
    Local nLinC100      := 0   as numeric

    // --- Controle de bloco C190 ---
    Local aC190Bloco    := {}  as array
    Local nSomaOpr      := 0   as numeric

    // --- Flags e contadores ---
    Local lDentroC100   := .F. as logical
    Local nIndex        := 0   as numeric

    Local nTotLinhas    := 0   as numeric
    Local nTotC100      := 0   as numeric
    Local nTotC190      := 0   as numeric
    Local nTotDiverg    := 0   as numeric
    Local nTotOk        := 0   as numeric
    Local nTotCorrig    := 0   as numeric
    Local nSomaDif      := 0   as numeric
    Local nSomaVlDoc    := 0   as numeric
    Local nSomaVlOpr    := 0   as numeric
    Local nVlOpr        := 0   as numeric

    // --- Data e hora ---
    Local cDataHoraIni  := " " as character
    Local cDataHoraFim  := " " as character
    Local cHoraIni      := " " as character
    Local cHoraFim      := " " as character

    cDataHoraIni := DtoC(Date()) + " " + Time()
    cHoraIni     := Time()

    // 1. SELECAO DO ARQUIVO
    cArqOrig := cGetFile("Arquivos TXT (*.txt)|*.txt|", "Selecione o arquivo SPED EFD")
    If Empty(cArqOrig)
        FWAlertError("Nenhum arquivo selecionado.", "Selecao de arquivo", NIL)
        Return (NIL)
    EndIf
    SplitPath(cArqOrig, @cDrive, @cDiretorio, @cNome, @cExtensao)
    cArqDest := cDrive + cDiretorio + ChgFileExt(cNome, "_new.txt")
    cLogArq  := cDrive + cDiretorio + ChgFileExt(cNome, "_correcao.log")

    // Remove arquivos anteriores
    If File(cArqDest)
        If FERASE(cArqDest) == -1
            FWAlertError("Nao foi possivel excluir:" + CRLF + cArqDest, "Erro ao excluir")
            Return (NIL)
        EndIf
    EndIf
    If File(cLogArq)
        If FERASE(cLogArq) == -1
            FWAlertError("Nao foi possivel excluir:" + CRLF + cLogArq, "Erro ao excluir")
            Return (NIL)
        EndIf
    EndIf

    // 2. CRIACAO DOS ARQUIVOS DE SAIDA
    nHLog := FCreate(cLogArq)
    If nHLog < 0
        FWAlertError("Erro ao criar o arquivo de LOG.", "Erro", NIL)
        Return (NIL)
    EndIf

    nHDest := FCreate(cArqDest)
    If nHDest < 0
        FWAlertError("Erro ao criar o arquivo de saida.", "Erro", NIL)
        FClose(nHLog)
        Return (NIL)
    EndIf

    // Cabecalho do LOG
    FWrite(nHLog, Replicate("=", 80) + CRLF)
    FWrite(nHLog, "  LOG DE CORRECAO C190 x C100 - SPED EFD" + CRLF)
    FWrite(nHLog, Replicate("=", 80) + CRLF)
    FWrite(nHLog, "Arquivo origem  : " + cArqOrig    + CRLF)
    FWrite(nHLog, "Arquivo gerado  : " + cArqDest    + CRLF)
    FWrite(nHLog, "Arquivo log     : " + cLogArq     + CRLF)
    FWrite(nHLog, "Inicio          : " + cDataHoraIni + CRLF)
    FWrite(nHLog, Replicate("-", 80) + CRLF + CRLF)

    // 3. LEITURA DO ARQUIVO SPED
    If .NOT. File(cArqOrig)
        FWAlertError("Arquivo nao encontrado.", "Erro", NIL)
        FClose(nHLog)
        FClose(nHDest)
        Return (NIL)
    EndIf

    FWMsgRun(, {|| nHandle := FT_FUse(cArqOrig)}, "Processando", "Aguarde... lendo arquivo...")
    If nHandle == -1
        FWAlertError("Erro na abertura do arquivo.", "Erro na abertura", NIL)
        FClose(nHLog)
        FClose(nHDest)
        Return (NIL)
    EndIf

    FT_FGoTop()
    aLinhas := {}
    While .NOT. FT_FEOF()
        cLinha := FT_FReadLn()
        AAdd(aLinhas, cLinha)
        FT_FSKIP()
    EndDo
    FT_FUSE()

    nTotLinhas := Len(aLinhas)
    FWrite(nHLog, "Total de linhas lidas: " + cValToChar(nTotLinhas) + CRLF + CRLF)
    FWrite(nHLog, Replicate("=", 80) + CRLF)
    FWrite(nHLog, "  DIVERGENCIAS E CORRECOES" + CRLF)
    FWrite(nHLog, Replicate("=", 80) + CRLF + CRLF)

    // 4. PRIMEIRA PASSAGEM: identifica blocos C100+C190, calcula
    //    divergencias e corrige VL_OPR in-place no array aLinhas
    ProcRegua(nTotLinhas)

    For nIndex := 1 To nTotLinhas
        IncProc()
        aCampos := StrTokArr(aLinhas[nIndex], "|")

        If Len(aCampos) < 2
            Loop
        EndIf

        If AllTrim(aCampos[1]) == "C100"
            // Fecha bloco anterior se existir
            If lDentroC100
                BRSPEDN092( ;
                    nHLog, @aLinhas, @aC190Bloco, ;
                    cNumDoc, cSerDoc, cCnpjPart, cChvNFe, cDtDoc, cIndOper, ;
                    nVlDoc, nSomaOpr, nLinC100, ;
                    @nTotDiverg, @nTotOk, @nTotCorrig, @nSomaDif, @nSomaVlOpr ;
                )
            EndIf

            // Inicia novo bloco C100
            lDentroC100 := .T.
            nLinC100    := nIndex
            nSomaOpr    := 0
            aC190Bloco  := {}
            nTotC100    += 1

            cIndOper  := If(Len(aCampos) >= 2,  AllTrim(aCampos[2]),  "")
            cCnpjPart := If(Len(aCampos) >= 4,  AllTrim(aCampos[4]),  "")
            cSerDoc   := If(Len(aCampos) >= 7,  AllTrim(aCampos[7]),  "")
            cNumDoc   := If(Len(aCampos) >= 8,  AllTrim(aCampos[8]),  "")
            cChvNFe   := If(Len(aCampos) >= 9,  AllTrim(aCampos[9]),  "")
            cDtDoc    := If(Len(aCampos) >= 10, AllTrim(aCampos[10]), "")
            nVlDoc    := If(Len(aCampos) >= 12, Val(StrTran(AllTrim(aCampos[12]), ",", ".")), 0)
            nSomaVlDoc += nVlDoc

        ElseIf AllTrim(aCampos[1]) == "C190" .AND. lDentroC100
            nVlOpr     := If(Len(aCampos) >= 5, Val(StrTran(AllTrim(aCampos[5]), ",", ".")), 0)
            nSomaOpr   += nVlOpr
            nTotC190   += 1
            AAdd(aC190Bloco, {nIndex, nVlOpr})

        ElseIf AllTrim(aCampos[1]) $ "C200|C990|D001|D100|D990|E001|E990|0990|9001|9900|9990|9999"
            If lDentroC100
                BRSPEDN092( ;
                    nHLog, @aLinhas, @aC190Bloco, ;
                    cNumDoc, cSerDoc, cCnpjPart, cChvNFe, cDtDoc, cIndOper, ;
                    nVlDoc, nSomaOpr, nLinC100, ;
                    @nTotDiverg, @nTotOk, @nTotCorrig, @nSomaDif, @nSomaVlOpr ;
                )
                lDentroC100 := .F.
                aC190Bloco  := {}
            EndIf
        EndIf
    Next nIndex

    // Fecha ultimo bloco se necessario
    If lDentroC100
        BRSPEDN092( ;
            nHLog, @aLinhas, @aC190Bloco, ;
            cNumDoc, cSerDoc, cCnpjPart, cChvNFe, cDtDoc, cIndOper, ;
            nVlDoc, nSomaOpr, nLinC100, ;
            @nTotDiverg, @nTotOk, @nTotCorrig, @nSomaDif, @nSomaVlOpr ;
        )
    EndIf

    // 5. SEGUNDA PASSAGEM: grava o arquivo _new.txt
    For nIndex := 1 To nTotLinhas
        FWrite(nHDest, aLinhas[nIndex] + CRLF)
    Next nIndex

    // 6. RESUMO FINAL DO LOG
    cDataHoraFim := DtoC(Date()) + " " + Time()
    cHoraFim     := Time()

    FWrite(nHLog, CRLF + Replicate("=", 80) + CRLF)
    FWrite(nHLog, "  RESUMO GERAL DO PROCESSAMENTO" + CRLF)
    FWrite(nHLog, Replicate("=", 80) + CRLF)
    FWrite(nHLog, "Total de linhas no arquivo        : " + cValToChar(nTotLinhas)  + CRLF)
    FWrite(nHLog, "Total de registros C100           : " + cValToChar(nTotC100)    + CRLF)
    FWrite(nHLog, "Total de registros C190           : " + cValToChar(nTotC190)    + CRLF)
    FWrite(nHLog, "Blocos SEM divergencia            : " + cValToChar(nTotOk)      + CRLF)
    FWrite(nHLog, "Blocos COM divergencia corrigidos : " + cValToChar(nTotDiverg)  + CRLF)
    FWrite(nHLog, "Linhas C190 efetivamente alteradas: " + cValToChar(nTotCorrig)  + CRLF)
    FWrite(nHLog, Replicate("-", 80) + CRLF)
    FWrite(nHLog, "Soma VL_DOC dos C100 (referencia) : " + Transform(nSomaVlDoc, "@E 999,999,999.99") + CRLF)
    FWrite(nHLog, "Soma VL_OPR dos C190 (original)   : " + Transform(nSomaVlOpr, "@E 999,999,999.99") + CRLF)
    FWrite(nHLog, "Soma total das diferencas          : " + Transform(nSomaDif,   "@E 999,999,999.99") + CRLF)
    FWrite(nHLog, Replicate("-", 80) + CRLF)
    FWrite(nHLog, "Inicio do processamento            : " + cDataHoraIni + CRLF)
    FWrite(nHLog, "Fim do processamento               : " + cDataHoraFim + CRLF)
    FWrite(nHLog, "Tempo total                        : " + ElapTime(cHoraIni, cHoraFim) + CRLF)
    FWrite(nHLog, Replicate("=", 80) + CRLF)
    FClose(nHLog)
    FClose(nHDest)

    // 7. MENSAGEM FINAL
    FWAlertSuccess( ;
        "Processamento finalizado!" + CRLF + CRLF + ;
        "Registros C100            : " + cValToChar(nTotC100)   + CRLF + ;
        "Registros C190            : " + cValToChar(nTotC190)   + CRLF + ;
        "Blocos com divergencia    : " + cValToChar(nTotDiverg) + CRLF + ;
        "Linhas C190 corrigidas    : " + cValToChar(nTotCorrig) + CRLF + ;
        "Soma das diferencas       : " + Transform(nSomaDif, "@E 999,999,999.99") + CRLF + CRLF + ;
        "Arquivo gerado: " + cArqDest + CRLF + ;
        "Log gerado    : " + cLogArq, ;
        "Correcao Concluida" ;
    )

Return (NIL)

/*/{Protheus.doc} BRSPEDN092
Funcao auxiliar: avalia um bloco C100 com seus C190 filhos.
Se houver divergencia entre VL_DOC (C100) e soma VL_OPR (C190):
  - Registra o detalhe no LOG
  - Redistribui o VL_DOC proporcionalmente entre os C190
  - Substitui in-place as linhas C190 no array aLinhas com o novo VL_OPR
O ultimo C190 absorve o residuo de arredondamento para garantir soma exata.
@type Static Function
@version 1.00
@author marioantonaccio
@since 09/04/2026
@param nHLog,      Numeric,    Handle do log
@param aLinhas,    Array,      Array de todas as linhas (by reference)
@param aC190Bloco, Array,      {{nIndice, nVlOpr}...} dos C190 do bloco
@param cNumDoc,    Character,  Numero do documento
@param cSerDoc,    Character,  Serie
@param cCnpjPart,  Character,  CNPJ participante
@param cChvNFe,    Character,  Chave NFe
@param cDtDoc,     Character,  Data documento
@param cIndOper,   Character,  Indicador operacao (0/1)
@param nVlDoc,     Numeric,    VL_DOC do C100 (valor correto)
@param nSomaOpr,   Numeric,    Soma VL_OPR dos C190 originais
@param nLinC100,   Numeric,    Indice do C100 no array (para log)
@param nTotDiverg, Numeric,    Contador de divergencias (by reference)
@param nTotOk,     Numeric,    Contador de OK (by reference)
@param nTotCorrig, Numeric,    Contador de C190 corrigidos (by reference)
@param nSomaDif,   Numeric,    Soma das diferencas (by reference)
@param nSomaVlOpr, Numeric,    Soma total VL_OPR originais (by reference)
@return NIL
/*/
Static Function BRSPEDN092( ;
    nHLog, aLinhas, aC190Bloco, ;
    cNumDoc, cSerDoc, cCnpjPart, cChvNFe, cDtDoc, cIndOper, ;
    nVlDoc, nSomaOpr, nLinC100, ;
    nTotDiverg, nTotOk, nTotCorrig, nSomaDif, nSomaVlOpr ;
)
    Local nDiferenca   := 0    as numeric
    Local nTolerancia  := 0.02 as numeric
    Local nI           := 0    as numeric
    Local nJ           := 0    as numeric
    Local nIdxArr      := 0    as numeric
    Local nVlOprOrig   := 0    as numeric
    Local nPeso        := 0    as numeric
    Local nNovoVlOpr   := 0    as numeric
    Local nAcumCorrig  := 0    as numeric
    Local cLinhaNova   := ""   as character
    Local aCamposC190  := {}   as array
    Local cCfop        := ""   as character
    Local cTipoOper    := ""   as character

    // Acumula VL_OPR originais no totalizador geral
    nSomaVlOpr += nSomaOpr

    // Sem C190 no bloco -> nao ha o que comparar
    If Len(aC190Bloco) == 0
        nTotOk += 1
        Return (NIL)
    EndIf

    nDiferenca := Abs(nVlDoc - nSomaOpr)
    cTipoOper  := If(cIndOper == "0", "ENTRADA", "SAIDA")

    // Bloco OK: sem divergencia
    If nDiferenca <= nTolerancia
        nTotOk += 1
        Return (NIL)
    EndIf

    // Bloco com DIVERGENCIA: registra no log e corrige C190
    nTotDiverg += 1
    nSomaDif   += nDiferenca

    FWrite(nHLog, Replicate("-", 80) + CRLF)
    FWrite(nHLog, "[DIVERGENCIA] Linha C100: " + cValToChar(nLinC100) + CRLF)
    FWrite(nHLog, "  Operacao     : " + cTipoOper + CRLF)
    FWrite(nHLog, "  Documento    : " + cNumDoc + " / Serie: " + cSerDoc + CRLF)
    FWrite(nHLog, "  Participante : " + cCnpjPart + CRLF)
    FWrite(nHLog, "  Data Doc.    : " + cDtDoc    + CRLF)
    FWrite(nHLog, "  Chave NFe    : " + cChvNFe   + CRLF)
    FWrite(nHLog, "  VL_DOC C100  : " + Transform(nVlDoc,     "@E 999,999,999.99") + CRLF)
    FWrite(nHLog, "  Soma C190    : " + Transform(nSomaOpr,   "@E 999,999,999.99") + CRLF)
    FWrite(nHLog, "  Diferenca    : " + Transform(nDiferenca, "@E 999,999,999.99") + CRLF)
    FWrite(nHLog, "  Qtd C190     : " + cValToChar(Len(aC190Bloco)) + CRLF)
    FWrite(nHLog, "  " + Replicate(".", 76) + CRLF)
    FWrite(nHLog, "  " + PadR("CFOP", 6) + " " + ;
        PadL("VL_OPR ORIGINAL",  18) + " " + ;
        PadL("VL_OPR CORRIGIDO", 18) + " " + ;
        PadL("DIFERENCA",        14) + CRLF)
    FWrite(nHLog, "  " + Replicate(".", 76) + CRLF)

    // Redistribuicao proporcional do VL_DOC entre os C190
    nAcumCorrig := 0

    For nI := 1 To Len(aC190Bloco)
        nIdxArr    := aC190Bloco[nI][1]
        nVlOprOrig := aC190Bloco[nI][2]

        If nSomaOpr <> 0
            nPeso      := nVlOprOrig / nSomaOpr
            nNovoVlOpr := Round(nVlDoc * nPeso, 2)
        Else
            nNovoVlOpr := Round(nVlDoc / Len(aC190Bloco), 2)
        EndIf

        // Ultimo C190 absorve residuo de arredondamento
        If nI == Len(aC190Bloco)
            nNovoVlOpr := Round(nVlDoc - nAcumCorrig, 2)
        Else
            nAcumCorrig += nNovoVlOpr
        EndIf

        aCamposC190 := StrTokArr(aLinhas[nIdxArr], "|")
        cCfop       := If(Len(aCamposC190) >= 3, AllTrim(aCamposC190[3]), "")
        FWrite(nHLog, ;
            "  " + PadR(cCfop, 6) + " " + ;
            PadL(Transform(nVlOprOrig,  "@E 999,999,999.99"), 18) + " " + ;
            PadL(Transform(nNovoVlOpr,  "@E 999,999,999.99"), 18) + " " + ;
            PadL(Transform(Abs(nNovoVlOpr - nVlOprOrig), "@E 999,999,999.99"), 14) + CRLF ;
        )

        // Substitui VL_OPR (campo [5]) na linha C190
        If Len(aCamposC190) >= 5
            aCamposC190[5] := AllTrim(StrTran(Transform(nNovoVlOpr, "@E 999999999.99"), ".", ","))
            cLinhaNova     := "|"
            For nJ := 1 To Len(aCamposC190)
                cLinhaNova += aCamposC190[nJ]
                If nJ < Len(aCamposC190)
                    cLinhaNova += "|"
                EndIf
            Next nJ
            aLinhas[nIdxArr] := cLinhaNova + "||"
            nTotCorrig += 1
        EndIf
    Next nI

    FWrite(nHLog, "  " + Replicate(".", 76) + CRLF + CRLF)

Return (NIL)
