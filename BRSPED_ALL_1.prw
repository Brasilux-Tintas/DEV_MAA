#Include "Protheus.ch"
#Include "fileio.ch"
#Include "Totvs.ch"

// =============================================================================
// BRSPED_ALL.PRW
// Consolidacao de todos os programas de analise e ajuste de arquivos SPED EFD
// Versao : 4.00 - Passagem Unica
// Autor  : marioantonaccio
// Desde  : 13/04/2026
//
// FUNCOES DISPONIVEIS (User Functions - chamadas via menu/RPW):
//   BRSPEDX   - Ajuste completo SPED: CST, duplicidades C190, H010,
//               totalizadores e arquivos de deposito - em PASSAGEM UNICA
//   BRSPED_NF - Verificacao de valores NF: confronto SPED x Protheus SF1
//   BRSPEDN090- Correcao proporcional VL_OPR do C190 vs VL_DOC do C100
//
// NOMES DE FUNCOES - limite de 10 caracteres respeitado em todos:
//   RebuildLin  (10)  utilitaria de reconstrucao de linha pipe
//   C190GravSm  (10)  interna: grava somatorio C190 por grupo no LOG
//   BRSPED01    ( 8)  worker de BRSPEDX
//   BRSPEDNF01  (10)  worker de BRSPED_NF
//   BRSPEDN091  (10)  worker de BRSPEDN090
//   BRSPEDN092  (10)  auxiliar de BRSPEDN091
// =============================================================================

// =============================================================================
// BLOCO 1: BRSPEDX
// Ajuste completo do SPED em PASSAGEM UNICA:
//   - Ajuste de CST 2->3 digitos (C170, D190, C190)
//   - Limpeza 0220 / 0305
//   - Identificacao de armazem (0005) e data inventario (H005)
//   - Consolidacao de duplicidades C190 por hash CST+CFOP por bloco C100
//   - Ajuste e exclusao de H010 via SB9
//   - Coleta de indices dos totalizadores (C990, H990, H999, 9900, 9999)
//   - Correcao dos totalizadores apos passagem (valores finais disponiveis)
//   - Gravacao do arquivo final e arquivos de deposito ARA/GUA
// =============================================================================

/*/{Protheus.doc} BRSPEDX
Programa principal de ajuste do arquivo SPED EFD.
Realiza todas as correcoes em uma unica passagem de leitura sobre o array
de linhas, eliminando varreduras multiplas e acelerando o processamento.
@type UserFunction
@version 4.00
@author marioantonaccio
@since 13/04/2026
@return NIL
/*/
User Function BRSPEDX()

    Local cMsgIntro := "" as character

    cMsgIntro := ;
        "Este programa executa:" + CRLF + ;
        " " + Chr(149) + " Leitura completa do arquivo TXT" + CRLF + ;
        " " + Chr(149) + " Ajuste de CST de 2 para 3 digitos (C170, D190, C190)" + CRLF + ;
        " " + Chr(149) + " Limpeza de 0220 e 0305" + CRLF + ;
        " " + Chr(149) + " Consolidacao de duplicidades C190 por CST+CFOP" + CRLF + ;
        " " + Chr(149) + " Ajuste de H010 por armazem (SB9)" + CRLF + ;
        " " + Chr(149) + " Acerto de totalizadores (C990, H990, H999, 9900, 9999)" + CRLF + ;
        " " + Chr(149) + " Geracao de arquivos de deposito (HARA, HGUA)" + CRLF + ;
        " " + Chr(149) + " Tudo em PASSAGEM UNICA sobre o arquivo" + CRLF + CRLF + ;
        "Clique SIM para selecionar o arquivo."

    If .NOT. FWAlertNoYes(cMsgIntro, "Processador SPED - Passagem Unica")
        Return (NIL)
    Else
        Processa({|| BRSPED01()}, "Processando SPED...")
    EndIf

Return (NIL)

/*/{Protheus.doc} BRSPED01
Worker do BRSPEDX. Executa toda a logica de ajuste do SPED em passagem
unica: le o arquivo, processa cada linha aplicando todas as regras
simultaneamente e grava o resultado.
Estrategia de passagem unica:
  - Variaveis de estado (cLocal, aArmazem, dDataInv, aHashC190...)
    sao mantidas entre iteracoes sem necessidade de re-varrer o array.
  - Hash de deduplicacao C190 e reiniciado a cada novo C100.
  - Totalizadores (nDC190, nDH010, nDVH010) sao acumulados on-the-fly.
  - Indices dos registros totalizadores sao capturados para correcao
    in-place apos a passagem (so entao os totais finais sao conhecidos).
  - Linhas marcadas para exclusao recebem token DELETE__ e sao filtradas
    na gravacao final - unica segunda passagem necessaria.
@type Static Function
@version 4.00
@author marioantonaccio
@since 13/04/2026
@return NIL
/*/
Static Function BRSPED01()

    // --- Controle de arquivo ---
    Local cArqOrig   := " " as character
    Local cArqDest   := " " as character
    Local cArqHARA   := " " as character
    Local cArqHGUA   := " " as character
    Local cArqDelete := " " as character
    Local cLogArq    := " " as character
    Local cDrive     := " " as character
    Local cDiretorio := " " as character
    Local cNome      := " " as character
    Local cExtensao  := " " as character
    Local nHLog      := 0   as numeric
    Local nHDest     := 0   as numeric
    Local nHARA      := 0   as numeric
    Local nHGUA      := 0   as numeric
    Local nHDelete   := 0   as numeric
    Local nHandle    := 0   as numeric

    // --- Leitura ---
    Local aLinhas    := {} as array

    // --- Estado da passagem unica ---
    Local aCampos    := {} as array
    Local cLinhaNova := " " as character
    Local nIndex     := 0   as numeric

    // Estado: armazem / local (definido por 0005)
    Local cLocal     := " " as character
    Local aArmazem   := {}  as array
    Local nLocal     := 0   as numeric

    // Estado: inventario (definido por H005)
    Local dDataInv           as Date

    // Estado: hash de deduplicacao C190 por bloco C100
    // Estrutura: { {cChave, nIdxLinha, v1, v2, v3, v4, v5, v6, v7}, ... }
    Local aHashC190  := {}  as array
    Local cCST       := " " as character
    Local cChave     := " " as character
    Local nPos       := 0   as numeric
    Local nI         := 0   as numeric
    Local nV1  := 0 as numeric
    Local nV2  := 0 as numeric
    Local nV3  := 0 as numeric
    Local nV4  := 0 as numeric
    Local nV5  := 0 as numeric
    Local nV6  := 0 as numeric
    Local nV7  := 0 as numeric

    // Coleta de linhas H010 por deposito (para HARA/HGUA)
    Local aH010ARA   := {} as array
    Local aH010GUA   := {} as array

    // Ajuste H010 via SB9
    Local nQtd       := 0 as numeric
    Local nValor     := 0 as numeric

    // Strings de substituicao
    Local cAntes     := " " as character
    Local cNew       := " " as character
    Local cCFO       := " " as character

    // Contadores
    Local nAlt       := 0 as numeric
    Local nExc       := 0 as numeric
    Local nDC190     := 0 as numeric
    Local nDH010     := 0 as numeric
    Local nDVH010    := 0 as numeric
    Local nDelete    := 0 as numeric

    // Indices dos totalizadores (capturados na passagem para correcao posterior)
    Local nIdxC990   := 0 as numeric
    Local nIdxH005   := 0 as numeric
    Local nIdxH990   := 0 as numeric
    Local nIdxH999   := 0 as numeric
    Local nIdx9999   := 0 as numeric
    Local a9900C190  := {} as array
    Local a9900H010  := {} as array

    // Temp deposito
    Local aDep       := {} as array
    Local nTotEst    := 0  as numeric

    // Tempo
    Local cDataHoraIni := " " as character
    Local cDataHoraFim := " " as character
    Local cHoraIni     := " " as character
    Local cHoraFim     := " " as character

    cDataHoraIni := DtoC(Date()) + " " + Time()
    cHoraIni     := Time()

    // =========================================================
    // 1. SELECAO E PREPARACAO DE ARQUIVOS
    // =========================================================
    cArqOrig := cGetFile("Arquivos TXT (*.txt)|*.txt|", "Selecione o arquivo SPED")
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

    If File(cArqDest)   .AND. FERASE(cArqDest)   == -1 ; FWAlertError("Erro ao excluir: "+cArqDest,   "Exclusao") ; Return(NIL) ; EndIf
    If File(cLogArq)    .AND. FERASE(cLogArq)    == -1 ; FWAlertError("Erro ao excluir: "+cLogArq,    "Exclusao") ; Return(NIL) ; EndIf
    If File(cArqHARA)   .AND. FERASE(cArqHARA)   == -1 ; FWAlertError("Erro ao excluir: "+cArqHARA,   "Exclusao") ; Return(NIL) ; EndIf
    If File(cArqHGUA)   .AND. FERASE(cArqHGUA)   == -1 ; FWAlertError("Erro ao excluir: "+cArqHGUA,   "Exclusao") ; Return(NIL) ; EndIf
    If File(cArqDelete) .AND. FERASE(cArqDelete) == -1 ; FWAlertError("Erro ao excluir: "+cArqDelete, "Exclusao") ; Return(NIL) ; EndIf

    nHLog := FCreate(cLogArq)
    If nHLog < 0 ; FWAlertError("Erro ao criar LOG.", "Erro", NIL) ; Return (NIL) ; EndIf

    FWrite(nHLog, Replicate("=", 80) + CRLF)
    FWrite(nHLog, "  LOG BRSPED - PASSAGEM UNICA" + CRLF)
    FWrite(nHLog, Replicate("=", 80) + CRLF)
    FWrite(nHLog, "Arquivo origem  : " + cArqOrig     + CRLF)
    FWrite(nHLog, "Inicio          : " + cDataHoraIni + CRLF)
    FWrite(nHLog, Replicate("-", 80) + CRLF + CRLF)

    // =========================================================
    // 2. LEITURA COMPLETA DO ARQUIVO EM MEMORIA
    // =========================================================
    If .NOT. File(cArqOrig)
        FWAlertError("Arquivo nao encontrado.", "Nao encontrado", NIL)
        FClose(nHLog)
        Return (NIL)
    EndIf

    FWMsgRun(, {|| nHandle := FT_FUse(cArqOrig)}, "Lendo", "Aguarde... lendo arquivo...")
    If nHandle == -1
        FWAlertError("Erro na abertura do arquivo.", "Erro na abertura", NIL)
        FClose(nHLog)
        Return (NIL)
    EndIf

    FT_FGoTop()
    aLinhas := {}
    While .NOT. FT_FEOF()
        AAdd(aLinhas, FT_FReadLn())
        FT_FSKIP()
    End
    FT_FUSE()

    FWrite(nHLog, "Total de linhas lidas: " + cValToChar(Len(aLinhas)) + CRLF + CRLF)

    // =========================================================
    // 3. PASSAGEM UNICA: aplica todas as regras linha a linha
    //    mantendo estado entre iteracoes via variaveis de contexto
    // =========================================================
    FWrite(nHLog, "=== PROCESSAMENTO (PASSAGEM UNICA) ===" + CRLF + CRLF)
    ProcRegua(Len(aLinhas))

    For nIndex := 1 To Len(aLinhas)
        IncProc()
        aCampos    := StrTokArr(aLinhas[nIndex], "|")
        cLinhaNova := ""

        If Len(aCampos) < 1
            Loop
        EndIf

        // ---------------------------------------------------------
        // 0005: identifica estabelecimento -> define aArmazem/cLocal
        // ---------------------------------------------------------
        If aCampos[1] == "0005"
            If "BRASILUX DEPOSITO ARARAQUARA" $ AllTrim(aCampos[2])
                aArmazem := {"AF", "A3"} ; cLocal := "ARA"
            EndIf
            If "DEPOSITO" $ AllTrim(aCampos[2])
                aArmazem := {"G1", "G3"} ; cLocal := "GUA"
            EndIf
            If "MATRIZ" $ AllTrim(aCampos[2])
                aArmazem := {"G1", "G3", "AF", "A3"} ; cLocal := "MAT"
            EndIf
        EndIf

        // ---------------------------------------------------------
        // 0220: limpa campo 4 quando ha exatamente 4 campos
        // ---------------------------------------------------------
        If aCampos[1] == "0220" .AND. Len(aCampos) == 4
            cAntes := "|" + AllTrim(aCampos[04]) + "|"
            cNew   := "| |"
            FWrite(nHLog, "ALTERACAO 0220 - Linha " + Str(nIndex, 6) + CRLF)
            FWrite(nHLog, "  ANTES : " + cAntes + CRLF + "  DEPOIS: " + cNew + CRLF + CRLF)
            nAlt++
            aLinhas[nIndex] := StrTran(aLinhas[nIndex], cAntes, cNew, 1, 1)
        EndIf

        // ---------------------------------------------------------
        // 0305: forca descricao para 'USO INTERNO'
        // ---------------------------------------------------------
        If aCampos[1] == "0305"
            cAntes     := AllTrim(aCampos[03])
            aCampos[3] := "USO INTERNO"
            FWrite(nHLog, "ALTERACAO 0305 - Linha " + Str(nIndex, 6) + CRLF)
            FWrite(nHLog, "  ANTES : " + cAntes + CRLF + "  DEPOIS: USO INTERNO" + CRLF + CRLF)
            nAlt++
            aLinhas[nIndex] := RebuildLin(aCampos)
        EndIf

        // ---------------------------------------------------------
        // C100: novo bloco -> fecha hash C190 anterior e reinicia
        // ---------------------------------------------------------
        If aCampos[1] == "C100"
            If Len(aHashC190) > 0
                C190GravSm(aHashC190, nHLog)
                aHashC190 := {}
            EndIf
        EndIf

        // ---------------------------------------------------------
        // C170: corrige CST de 2 para 3 digitos
        // ---------------------------------------------------------
        If aCampos[1] == "C170" .AND. Len(AllTrim(aCampos[10])) == 2
            cCFO   := aCampos[11]
            cAntes := AllTrim(aCampos[10])
            cNew   := "0" + cAntes
            FWrite(nHLog, "ALTERACAO C170 - Linha " + Str(nIndex, 6) + CRLF)
            FWrite(nHLog, "  ANTES : " + cAntes + CRLF + "  DEPOIS: " + cNew + CRLF + CRLF)
            nAlt++
            aLinhas[nIndex] := StrTran(aLinhas[nIndex], "|"+cAntes+"|"+cCFO+"|", "|"+cNew+"|"+cCFO+"|", 1, 1)
        EndIf

        // ---------------------------------------------------------
        // C190: deduplicacao por hash + ajuste CST 2->3 digitos
        // ---------------------------------------------------------
        If aCampos[1] == "C190"

            cCST   := PadL(AllTrim(aCampos[2]), 3, "0")
            cChave := Substr(cCST, 2, 2) + "|" + AllTrim(aCampos[3])

            nV1 := Val(StrTran(AllTrim(aCampos[05]), ",", "."))
            nV2 := Val(StrTran(AllTrim(aCampos[06]), ",", "."))
            nV3 := Val(StrTran(AllTrim(aCampos[07]), ",", "."))
            nV4 := Val(StrTran(AllTrim(aCampos[08]), ",", "."))
            nV5 := Val(StrTran(AllTrim(aCampos[09]), ",", "."))
            nV6 := Val(StrTran(AllTrim(aCampos[10]), ",", "."))
            nV7 := Val(StrTran(AllTrim(aCampos[11]), ",", "."))

            nPos := 0
            For nI := 1 To Len(aHashC190)
                If aHashC190[nI][1] == cChave ; nPos := nI ; Exit ; EndIf
            Next

            If nPos == 0
                // Primeira ocorrencia: corrige CST se 2 digitos e registra no hash
                If Len(AllTrim(aCampos[2])) == 2
                    cCFO   := aCampos[03]
                    cAntes := AllTrim(aCampos[2])
                    cNew   := "0" + cAntes
                    FWrite(nHLog, "ALTERACAO C190 CST - Linha " + Str(nIndex, 6) + CRLF)
                    FWrite(nHLog, "  ANTES : " + cAntes + CRLF + "  DEPOIS: " + cNew + CRLF + CRLF)
                    nAlt++
                    aLinhas[nIndex] := StrTran(aLinhas[nIndex], "|"+cAntes+"|"+cCFO+"|", "|"+cNew+"|"+cCFO+"|", 1, 1)
                EndIf
                AADD(aHashC190, {cChave, nIndex, nV1, nV2, nV3, nV4, nV5, nV6, nV7})

            Else
                // Duplicidade: acumula na primeira ocorrencia e marca esta para exclusao
                aHashC190[nPos][3] += nV1 ; aHashC190[nPos][4] += nV2
                aHashC190[nPos][5] += nV3 ; aHashC190[nPos][6] += nV4
                aHashC190[nPos][7] += nV5 ; aHashC190[nPos][8] += nV6
                aHashC190[nPos][9] += nV7

                aCampos := StrTokArr(aLinhas[aHashC190[nPos][2]], "|")
                aCampos[05] := AllTrim(Transform(aHashC190[nPos][3], "@ER 999999999.99"))
                aCampos[06] := AllTrim(Transform(aHashC190[nPos][4], "@ER 999999999.99"))
                aCampos[07] := AllTrim(Transform(aHashC190[nPos][5], "@ER 999999999.99"))
                aCampos[08] := AllTrim(Transform(aHashC190[nPos][6], "@ER 999999999.99"))
                aCampos[09] := AllTrim(Transform(aHashC190[nPos][7], "@ER 999999999.99"))
                aCampos[10] := AllTrim(Transform(aHashC190[nPos][8], "@ER 999999999.99"))
                aCampos[11] := AllTrim(Transform(aHashC190[nPos][9], "@ER 999999999.99"))
                aLinhas[aHashC190[nPos][2]] := RebuildLin(aCampos)
                nAlt++

                FWrite(nHLog, "C190 CONSOLIDADO - Chave [" + cChave + "]" + CRLF)
                FWrite(nHLog, "  Linha ref  : " + Str(aHashC190[nPos][2], 6) + CRLF)
                FWrite(nHLog, "  Linha dupl : " + Str(nIndex, 6) + CRLF)
                FWrite(nHLog, "  Val acumul : " + Transform(aHashC190[nPos][3], "@ER 999999999.99") + CRLF + CRLF)

                aCampos    := StrTokArr(aLinhas[nIndex], "|")
                aCampos[1] := "C190__DELETE__"
                aLinhas[nIndex] := RebuildLin(aCampos)
                nDC190++ ; nExc++
            EndIf
        EndIf

        // ---------------------------------------------------------
        // D190: corrige CST de 2 para 3 digitos
        // ---------------------------------------------------------
        If aCampos[1] == "D190" .AND. Len(AllTrim(aCampos[02])) == 2
            cCFO   := aCampos[03]
            cAntes := AllTrim(aCampos[02])
            cNew   := "0" + cAntes
            FWrite(nHLog, "ALTERACAO D190 - Linha " + Str(nIndex, 6) + CRLF)
            FWrite(nHLog, "  ANTES : " + cAntes + CRLF + "  DEPOIS: " + cNew + CRLF + CRLF)
            nAlt++
            aLinhas[nIndex] := StrTran(aLinhas[nIndex], "|"+cAntes+"|"+cCFO+"|", "|"+cNew+"|"+cCFO+"|", 1, 1)
        EndIf

        // ---------------------------------------------------------
        // H005: captura data do inventario e guarda indice para correcao
        // ---------------------------------------------------------
        If aCampos[1] == "H005"
            dDataInv := CTOD(Substr(aCampos[2],1,2)+"/"+Substr(aCampos[2],3,2)+"/"+Substr(aCampos[2],5,4))
            nIdxH005 := nIndex
        EndIf

        // ---------------------------------------------------------
        // H010: ajusta ou exclui conforme estoque nos armazens (SB9)
        // ---------------------------------------------------------
        If aCampos[1] == "H010"
            nQtd   := Val(StrTran(AllTrim(aCampos[4]), ",", "."))
            nValor := Val(StrTran(AllTrim(aCampos[6]), ",", "."))

            For nLocal := 1 To Len(aArmazem)
                SB9->(dbSetOrder(1))
                If cLocal == "MAT"
                    If SB9->(dbSeek(xFilial("SB9")+Substr(aCampos[2],1,15)+aArmazem[nLocal]+DTOS(dDataInv)))
                        nQtd   -= SB9->B9_QINI
                        nValor -= SB9->B9_VINI1
                        If aArmazem[nLocal] $ "AF/A3"
                            AADD(aH010ARA, aLinhas[nIndex])
                        ElseIf aArmazem[nLocal] $ "G1/G3"
                            AADD(aH010GUA, aLinhas[nIndex])
                        EndIf
                    EndIf
                Else
                    If .NOT. SB9->(dbSeek(xFilial("SB9")+Substr(aCampos[2],1,15)+aArmazem[nLocal]+DTOS(dDataInv)))
                        nQtd   -= SB9->B9_QINI
                        nValor -= SB9->B9_VINI1
                    EndIf
                EndIf
            Next

            If nQtd <= 0
                nDH010++
                nDVH010 += Val(StrTran(AllTrim(aCampos[6]), ",", "."))
                aLinhas[nIndex] := StrTran(aLinhas[nIndex], "|H010|", "|H010__DELETE__|", 1, 1)
                FWrite(nHLog, "EXCLUSAO H010 - Linha " + Str(nIndex, 6) + CRLF + CRLF)
                nExc++
            Else
                If Val(StrTran(AllTrim(aCampos[4]),",",".")) <> nQtd .OR. ;
                   Val(StrTran(AllTrim(aCampos[6]),",",".")) <> nValor
                    nDVH010 += (Val(StrTran(AllTrim(aCampos[6]),",",".")) - nValor)
                    FWrite(nHLog, "ALTERACAO H010 - Linha " + Str(nIndex, 6) + CRLF)
                    FWrite(nHLog, "  ANTES QTD : " + aCampos[4] + " / VAL: " + aCampos[6] + CRLF)
                    FWrite(nHLog, "  DEPOIS QTD: " + cValToChar(nQtd) + " / VAL: " + cValToChar(nValor) + CRLF + CRLF)
                    nAlt++
                    aCampos[04]     := AllTrim(Transform(nQtd,   "@ER 999999999.999"))
                    aCampos[06]     := AllTrim(Transform(nValor, "@ER 999999999.99"))
                    aLinhas[nIndex] := RebuildLin(aCampos)
                EndIf
            EndIf
        EndIf

        // ---------------------------------------------------------
        // Totalizadores: guarda apenas o indice para correcao pos-passagem
        // ---------------------------------------------------------
        If aCampos[1] == "C990" ; nIdxC990 := nIndex ; EndIf
        If aCampos[1] == "H990" ; nIdxH990 := nIndex ; EndIf
        If aCampos[1] == "H999" ; nIdxH999 := nIndex ; EndIf
        If aCampos[1] == "9999" ; nIdx9999 := nIndex ; EndIf
        If aCampos[1] == "9900"
            If aCampos[2] == "C190" ; AADD(a9900C190, nIndex) ; EndIf
            If aCampos[2] == "H010" ; AADD(a9900H010, nIndex) ; EndIf
        EndIf

    Next  // ===== FIM DA PASSAGEM UNICA =====

    // Fecha hash do ultimo bloco C100 se ainda houver
    If Len(aHashC190) > 0
        C190GravSm(aHashC190, nHLog)
    EndIf

    // =========================================================
    // 4. CORRECAO DOS TOTALIZADORES (in-place no array)
    //    Executada apos passagem pois so agora nDC190/nDH010/nDVH010
    //    tem seus valores definitivos.
    // =========================================================

    // Conta marcadores DELETE__ para ajuste do 9999
    nDelete := 0
    For nI := 1 To Len(aLinhas)
        If "DELETE__" $ aLinhas[nI] ; nDelete++ ; EndIf
    Next

    FWrite(nHLog, CRLF + "=== CORRECAO DE TOTALIZADORES ===" + CRLF + CRLF)

    If nIdxH005 > 0
        aCampos := StrTokArr(aLinhas[nIdxH005], "|")
        nQtd    := Val(AllTrim(StrTran(aCampos[3],",","."))) - nDVH010
        FWrite(nHLog, "ALTERACAO H005 - Linha " + Str(nIdxH005,6) + " | Antes: " + aCampos[3] + " Depois: " + cValToChar(nQtd) + CRLF)
        nAlt++ ; aCampos[3] := AllTrim(Transform(nQtd,"@ER 999999999")) ; aLinhas[nIdxH005] := RebuildLin(aCampos)
    EndIf

    If nIdxC990 > 0
        aCampos := StrTokArr(aLinhas[nIdxC990], "|")
        nQtd    := Val(AllTrim(StrTran(aCampos[2],",","."))) - nDC190
        FWrite(nHLog, "ALTERACAO C990 - Linha " + Str(nIdxC990,6) + " | Antes: " + aCampos[2] + " Depois: " + cValToChar(nQtd) + CRLF)
        nAlt++ ; aCampos[2] := AllTrim(Transform(nQtd,"@ER 999999999")) ; aLinhas[nIdxC990] := RebuildLin(aCampos)
    EndIf

    If nIdxH990 > 0
        aCampos := StrTokArr(aLinhas[nIdxH990], "|")
        nQtd    := Val(AllTrim(StrTran(aCampos[2],",","."))) - nDH010
        FWrite(nHLog, "ALTERACAO H990 - Linha " + Str(nIdxH990,6) + " | Antes: " + aCampos[2] + " Depois: " + cValToChar(nQtd) + CRLF)
        nAlt++ ; aCampos[2] := AllTrim(Transform(nQtd,"@ER 999999999")) ; aLinhas[nIdxH990] := RebuildLin(aCampos)
    EndIf

    If nIdxH999 > 0
        aCampos := StrTokArr(aLinhas[nIdxH999], "|")
        nQtd    := Val(AllTrim(StrTran(aCampos[2],",","."))) - nDH010
        FWrite(nHLog, "ALTERACAO H999 - Linha " + Str(nIdxH999,6) + " | Antes: " + aCampos[2] + " Depois: " + cValToChar(nQtd) + CRLF)
        nAlt++ ; aCampos[2] := AllTrim(Transform(nQtd,"@ER 999999999")) ; aLinhas[nIdxH999] := RebuildLin(aCampos)
    EndIf

    If nIdx9999 > 0
        aCampos := StrTokArr(aLinhas[nIdx9999], "|")
        nQtd    := Val(AllTrim(StrTran(aCampos[2],",","."))) - nDelete
        FWrite(nHLog, "ALTERACAO 9999 - Linha " + Str(nIdx9999,6) + " | Antes: " + aCampos[2] + " Depois: " + cValToChar(nQtd) + CRLF)
        nAlt++ ; aCampos[2] := AllTrim(Transform(nQtd,"@ER 999999999")) ; aLinhas[nIdx9999] := RebuildLin(aCampos)
    EndIf

    For nI := 1 To Len(a9900C190)
        aCampos := StrTokArr(aLinhas[a9900C190[nI]], "|")
        nQtd    := Val(AllTrim(StrTran(aCampos[3],",","."))) - nDC190
        FWrite(nHLog, "ALTERACAO 9900/C190 - Linha " + Str(a9900C190[nI],6) + " | Antes: " + aCampos[3] + " Depois: " + cValToChar(nQtd) + CRLF)
        nAlt++ ; aCampos[3] := AllTrim(Transform(nQtd,"@ER 999999999")) ; aLinhas[a9900C190[nI]] := RebuildLin(aCampos)
    Next

    For nI := 1 To Len(a9900H010)
        aCampos := StrTokArr(aLinhas[a9900H010[nI]], "|")
        nQtd    := Val(AllTrim(StrTran(aCampos[3],",","."))) - nDH010
        FWrite(nHLog, "ALTERACAO 9900/H010 - Linha " + Str(a9900H010[nI],6) + " | Antes: " + aCampos[3] + " Depois: " + cValToChar(nQtd) + CRLF)
        nAlt++ ; aCampos[3] := AllTrim(Transform(nQtd,"@ER 999999999")) ; aLinhas[a9900H010[nI]] := RebuildLin(aCampos)
    Next

    FWrite(nHLog, CRLF)

    // =========================================================
    // 5. GRAVACAO DO ARQUIVO FINAL
    // =========================================================
    nHDest := FCreate(cArqDest)
    If nHDest < 0 ; FWAlertError("Erro ao criar arquivo destino.","Nao Criado") ; FClose(nHLog) ; Return(NIL) ; EndIf

    nHDelete := FCreate(cArqDelete)
    If nHDelete < 0 ; FWAlertError("Erro ao criar arquivo de deletados.","Erro",NIL) ; FClose(nHLog) ; FClose(nHDest) ; Return(NIL) ; EndIf

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

    // =========================================================
    // 6. ARQUIVOS DE DEPOSITO ARA / GUA
    // =========================================================
    If Len(aH010ARA) > 0
        nHARA := FCreate(cArqHARA)
        If nHARA < 0 ; FWAlertError("Erro ao criar HARA.","Nao Criado") ; FClose(nHLog) ; Return(NIL) ; EndIf
        nTotEst := 0
        For nI := 1 To Len(aH010ARA)
            aCampos := StrTokArr(aH010ARA[nI], "|")
            nTotEst += Val(StrTran(aCampos[06], ",", "."))
        Next
        aDep := {"|H001|0|", "|H005|"+GravaData(dDataInv,.F.,5)+"|"+AllTrim(Transform(nTotEst,"@ER 999999999.99"))+"|01|"}
        AEval(aH010ARA, {|x| AADD(aDep, x)})
        AADD(aDep, "|H990|" + AllTrim(cValToChar(Len(aH010ARA)+2)) + "|")
        AEval(aDep, {|x| FWrite(nHARA, x + CRLF)})
        FClose(nHARA)
    EndIf

    If Len(aH010GUA) > 0
        nHGUA := FCreate(cArqHGUA)
        If nHGUA < 0 ; FWAlertError("Erro ao criar HGUA.","Nao Criado") ; FClose(nHLog) ; Return(NIL) ; EndIf
        nTotEst := 0
        For nI := 1 To Len(aH010GUA)
            aCampos := StrTokArr(aH010GUA[nI], "|")
            nTotEst += Val(StrTran(aCampos[06], ",", "."))
        Next
        aDep := {"|H001|0|", "|H005|"+GravaData(dDataInv,.F.,5)+"|"+AllTrim(Transform(nTotEst,"@ER 999999999.99"))+"|01|"}
        AEval(aH010GUA, {|x| AADD(aDep, x)})
        AADD(aDep, "|H990|" + AllTrim(cValToChar(Len(aH010GUA)+2)) + "|")
        AEval(aDep, {|x| FWrite(nHGUA, x + CRLF)})
        FClose(nHGUA)
    EndIf

    // =========================================================
    // 7. FECHAMENTO DO LOG E MENSAGEM FINAL
    // =========================================================
    cDataHoraFim := DtoC(Date()) + " " + Time()
    cHoraFim     := Time()

    FWrite(nHLog, Replicate("=", 80) + CRLF)
    FWrite(nHLog, "  RESUMO FINAL" + CRLF)
    FWrite(nHLog, Replicate("=", 80) + CRLF)
    FWrite(nHLog, "Arquivo gerado            : " + cArqDest               + CRLF)
    FWrite(nHLog, "Total Linhas (original)   : " + cValToChar(Len(aLinhas)) + CRLF)
    FWrite(nHLog, "Alteracoes                : " + cValToChar(nAlt)         + CRLF)
    FWrite(nHLog, "Exclusoes                 : " + cValToChar(nExc)         + CRLF)
    FWrite(nHLog, "  C190 duplicados         : " + cValToChar(nDC190)       + CRLF)
    FWrite(nHLog, "  H010 excluidos          : " + cValToChar(nDH010)       + CRLF)
    FWrite(nHLog, "Total ALTER + EXCL        : " + cValToChar(nAlt+nExc)    + CRLF)
    FWrite(nHLog, "Inicio                    : " + cDataHoraIni             + CRLF)
    FWrite(nHLog, "Fim                       : " + cDataHoraFim             + CRLF)
    FWrite(nHLog, "Tempo                     : " + Elaptime(cHoraIni,cHoraFim) + CRLF)
    FWrite(nHLog, Replicate("=", 80) + CRLF)
    FClose(nHLog)

    FWAlertSuccess("Processamento finalizado!" + CRLF + CRLF + ;
        "Alteracoes    : " + cValToChar(nAlt)   + CRLF + ;
        "Exclusoes     : " + cValToChar(nExc)   + CRLF + ;
        "C190 excluidos: " + cValToChar(nDC190) + CRLF + ;
        "H010 excluidos: " + cValToChar(nDH010) + CRLF + CRLF + ;
        "Arquivo: " + cArqDest + CRLF + ;
        "Log    : " + cLogArq, "Processo Concluido")

Return (NIL)

// =============================================================================
// Utilitarias compartilhadas
// =============================================================================

/*/{Protheus.doc} RebuildLin
Reconstroi a linha SPED a partir do array de campos, garantindo o
numero minimo de campos por tipo de registro e delimitadores pipe.
Renomeada de RebuildLine (11 chars) para RebuildLin (10 chars).
@type Static Function
@version 4.00
@author marioantonaccio
@since 13/04/2026
@param aCampos, array, campos da linha
@return character, linha com delimitadores pipe
/*/
Static Function RebuildLin(aCampos)

    Local cLinhaR := "|" as character
    Local nI      := 0   as numeric
    Local nMin    := 0   as numeric

    Do Case
        Case aCampos[1] == "H010"                                          ; nMin := 11
        Case aCampos[1] == "C190" .OR. aCampos[1] == "C190__DELETE__"     ; nMin := 12
        Case aCampos[1] == "C170"                                          ; nMin := 38
        Case aCampos[1] == "0305"                                          ; nMin :=  4
        Case aCampos[1] == "H005"                                          ; nMin :=  4
        Case aCampos[1] == "C990" .OR. aCampos[1] == "H990" .OR. ;
             aCampos[1] == "H999" .OR. aCampos[1] == "9999"               ; nMin :=  3
        Case aCampos[1] == "9900"                                          ; nMin :=  4
    EndCase

    If nMin > 0 .AND. Len(aCampos) < nMin
        For nI := 1 To nMin - Len(aCampos)
            AADD(aCampos, "")
        Next
    EndIf

    For nI := 1 To Len(aCampos)
        cLinhaR += aCampos[nI]
        If nI < Len(aCampos) ; cLinhaR += "|" ; EndIf
    Next

Return (cLinhaR + "|")

/*/{Protheus.doc} C190GravSm
Grava no LOG o somatorio por grupo CST+CFOP de um bloco C100.
Renomeada de C190_GravaSomatorio (22 chars) para C190GravSm (10 chars).
@type Static Function
@version 4.00
@author marioantonaccio
@since 13/04/2026
@param aHash, array,   hash do bloco: { {cChave, nIdx, v1..v7}, ... }
@param nHLog, numeric, handle do LOG
@return NIL
/*/
Static Function C190GravSm(aHash, nHLog)

    Local nI      := 0 as numeric
    Local nTotVal := 0 as numeric

    FWrite(nHLog, "--- SOMATORIO C190 CST+CFOP ---" + CRLF)
    FWrite(nHLog, PadR("Chave",20)+" | "+PadL("VL_BC_ICMS",14)+" | "+PadL("VL_ICMS",14)+" | "+;
        PadL("VL_BC_ICMS_ST",14)+" | "+PadL("VL_ICMS_ST",14)+" | "+;
        PadL("VL_RED_BC",14)+" | "+PadL("VL_IPI",14)+" | "+PadL("VL_PIS_COF",14)+CRLF)
    FWrite(nHLog, Replicate("-", 135) + CRLF)

    For nI := 1 To Len(aHash)
        FWrite(nHLog, PadR(aHash[nI][1],20)+" | "+;
            PadL(Transform(aHash[nI][3],"@ER 999999999.99"),14)+" | "+;
            PadL(Transform(aHash[nI][4],"@ER 999999999.99"),14)+" | "+;
            PadL(Transform(aHash[nI][5],"@ER 999999999.99"),14)+" | "+;
            PadL(Transform(aHash[nI][6],"@ER 999999999.99"),14)+" | "+;
            PadL(Transform(aHash[nI][7],"@ER 999999999.99"),14)+" | "+;
            PadL(Transform(aHash[nI][8],"@ER 999999999.99"),14)+" | "+;
            PadL(Transform(aHash[nI][9],"@ER 999999999.99"),14)+CRLF)
        nTotVal += aHash[nI][3]
    Next

    FWrite(nHLog, Replicate("-", 135) + CRLF)
    FWrite(nHLog, PadR("TOTAL: "+cValToChar(Len(aHash))+" grupo(s)",20)+" | "+;
        PadL(Transform(nTotVal,"@ER 999999999.99"),14)+CRLF+CRLF)

Return (NIL)

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
Le o arquivo SPED, confronta cada C100 de entrada com a nota fiscal
correspondente na SF1 do Protheus e registra divergencias no LOG.
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
    Local cLogArq      := " " as character
    Local cDrive       := " " as character
    Local cDiretorio   := " " as character
    Local cNome        := " " as character
    Local cExtensao    := " " as character
    Local cChvNFE      := " " as character
    Local cDataHoraIni := " " as character
    Local cDataHoraFim := " " as character
    Local cHoraIni     := " " as character
    Local cHoraFim     := " " as character
    Local nLinGer      := 0   as numeric
    Local nHandle      := 0   as numeric
    Local nHLog        := 0   as numeric
    Local nIndex       := 0   as numeric
    Local nC100        := 0   as numeric

    cDataHoraIni := DtoC(Date()) + " " + Time()
    cHoraIni     := Time()

    cArqOrig := cGetFile("Arquivos TXT (*.txt)|*.txt|", "Selecione o arquivo para processamento")
    If Empty(cArqOrig) ; FWAlertError("Nenhum arquivo selecionado.","Selecao de arquivo",NIL) ; Return(NIL) ; EndIf

    SplitPath(cArqOrig, @cDrive, @cDiretorio, @cNome, @cExtensao)
    cLogArq := cDrive + cDiretorio + ChgFileExt(cNome, ".log")

    If File(cLogArq) .AND. FERASE(cLogArq) == -1
        FWAlertError("Nao foi possivel excluir: " + cLogArq, "Exclusao") ; Return (NIL)
    EndIf

    nHLog := FCreate(cLogArq)
    If nHLog < 0 ; FWAlertError("Erro ao criar LOG.","Erro",NIL) ; Return(NIL) ; EndIf

    FWrite(nHLog, "LOG - VERIFICACAO NF SPED x PROTHEUS" + CRLF)
    FWrite(nHLog, "Arquivo : " + cArqOrig + CRLF)
    FWrite(nHLog, "Inicio  : " + cDataHoraIni + CRLF + CRLF)

    If .NOT. File(cArqOrig)
        FWAlertError("Arquivo nao encontrado.","Nao encontrado",NIL) ; FClose(nHLog) ; Return(NIL)
    EndIf

    FWMsgRun(,{|| nHandle:=FT_FUse(cArqOrig)},"Processando","Aguarde... lendo arquivo...")
    If nHandle == -1 ; FWAlertError("Erro na abertura.","Erro na abertura",NIL) ; FClose(nHLog) ; Return(NIL) ; EndIf

    FT_FGoTop()
    aLinhas := {}
    While .NOT. FT_FEOF()
        AAdd(aLinhas, FT_FReadLn()) ; FT_FSKIP()
    End
    FT_FUSE()

    FWrite(nHLog, "Total de Linhas: " + cValToChar(Len(aLinhas)) + CRLF + CRLF)
    ProcRegua(Len(aLinhas))

    For nIndex := 1 To Len(aLinhas)
        IncProc()
        aCampos := StrTokArr(aLinhas[nIndex], "|")

        If aCampos[1] == "C100" .AND. Len(aCampos) >= 12 .AND. aCampos[2] == "0"
            cChvNFE := AllTrim(aCampos[9])
            nC100   := Val(StrTran(aCampos[12], ",", "."))
            SF1->(dbSetOrder(8))
            If SF1->(dbSeek(xFilial("SF1") + cChvNFE))
                If SF1->F1_TOTAL <> nC100
                    FWrite(nHLog, "Linha: " + cValToChar(nIndex) + " - DIVERGENCIA:" + CRLF + ;
                        "  Nota    : " + SF1->F1_DOC + "/" + SF1->F1_SERIE + CRLF + ;
                        "  Fornec. : " + SF1->F1_FORNECE + SF1->F1_LOJA   + CRLF + ;
                        "  Chave NF: " + SF1->F1_CHVNFE  + CRLF + ;
                        "  Protheus: " + cValToChar(SF1->F1_TOTAL) + CRLF + ;
                        "  SPED    : " + cValToChar(nC100) + CRLF + CRLF)
                    nLinGer++
                EndIf
            EndIf
        EndIf
    Next

    cDataHoraFim := DtoC(Date()) + " " + Time()
    cHoraFim     := Time()

    FWrite(nHLog, "Fim                : " + cDataHoraFim + CRLF)
    FWrite(nHLog, "Tempo              : " + Elaptime(cHoraIni,cHoraFim) + CRLF)
    FWrite(nHLog, "Total Divergencias : " + cValToChar(nLinGer) + CRLF)
    FClose(nHLog)

    FWAlertSuccess("Processamento finalizado!" + CRLF + CRLF + ;
        "Divergencias : " + cValToChar(nLinGer) + CRLF + CRLF + ;
        "Log: " + cLogArq, "Verificacao Concluida")

Return (NIL)

// =============================================================================
// BLOCO 3: BRSPEDN090 - Correcao proporcional VL_OPR C190 vs VL_DOC C100
// =============================================================================

/*/{Protheus.doc} BRSPEDN090
Programa que le um arquivo SPED EFD (TXT), compara o VL_DOC do bloco
C100 com a soma dos VL_OPR dos registros C190 filhos e redistribui
o VL_DOC proporcionalmente entre os C190 quando ha divergencia.
Gera arquivo _new.txt com linhas C190 corrigidas e LOG detalhado.
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
        " " + Chr(149) + " Leitura completa do arquivo SPED EFD" + CRLF + ;
        " " + Chr(149) + " Comparacao VL_DOC (C100) x soma VL_OPR (C190)" + CRLF + ;
        " " + Chr(149) + " Correcao proporcional dos VL_OPR no C190" + CRLF + ;
        " " + Chr(149) + " Arquivo _new.txt com linhas corrigidas" + CRLF + ;
        " " + Chr(149) + " LOG detalhado com divergencias e totais" + CRLF + CRLF + ;
        "Clique SIM para selecionar o arquivo SPED EFD."

    If .NOT. FWAlertNoYes(cMsgIntro, "Correcao C190 x C100 - SPED EFD")
        Return (NIL)
    Else
        Processa({|| BRSPEDN091()}, "Processando SPED EFD...")
    EndIf

Return (NIL)

/*/{Protheus.doc} BRSPEDN091
Le o arquivo SPED, agrupa blocos C100+C190 em passagem unica,
identifica divergencias entre VL_DOC e soma VL_OPR, redistribui
proporcionalmente e grava _new.txt e .log.
@type Static Function
@version 1.00
@author marioantonaccio
@since 09/04/2026
@return NIL
/*/
Static Function BRSPEDN091()

    Local cArqOrig     := " " as character
    Local cArqDest     := " " as character
    Local cLogArq      := " " as character
    Local cDrive       := " " as character
    Local cDiretorio   := " " as character
    Local cNome        := " " as character
    Local cExtensao    := " " as character
    Local nHLog        := 0   as numeric
    Local nHDest       := 0   as numeric
    Local nHandle      := 0   as numeric
    Local aLinhas      := {}  as array
    Local aCampos      := {}  as array
    Local cIndOper     := " " as character
    Local cNumDoc      := " " as character
    Local cSerDoc      := " " as character
    Local cCnpjPart    := " " as character
    Local cChvNFe      := " " as character
    Local cDtDoc       := " " as character
    Local nVlDoc       := 0   as numeric
    Local nLinC100     := 0   as numeric
    Local aC190Bloco   := {}  as array
    Local nSomaOpr     := 0   as numeric
    Local lDentroC100  := .F. as logical
    Local nIndex       := 0   as numeric
    Local nVlOpr       := 0   as numeric
    Local nTotLinhas   := 0   as numeric
    Local nTotC100     := 0   as numeric
    Local nTotC190     := 0   as numeric
    Local nTotDiverg   := 0   as numeric
    Local nTotOk       := 0   as numeric
    Local nTotCorrig   := 0   as numeric
    Local nSomaDif     := 0   as numeric
    Local nSomaVlDoc   := 0   as numeric
    Local nSomaVlOpr   := 0   as numeric
    Local cDataHoraIni := " " as character
    Local cDataHoraFim := " " as character
    Local cHoraIni     := " " as character
    Local cHoraFim     := " " as character

    cDataHoraIni := DtoC(Date()) + " " + Time()
    cHoraIni     := Time()

    cArqOrig := cGetFile("Arquivos TXT (*.txt)|*.txt|", "Selecione o arquivo SPED EFD")
    If Empty(cArqOrig) ; FWAlertError("Nenhum arquivo selecionado.","Selecao de arquivo",NIL) ; Return(NIL) ; EndIf

    SplitPath(cArqOrig, @cDrive, @cDiretorio, @cNome, @cExtensao)
    cArqDest := cDrive + cDiretorio + ChgFileExt(cNome, "_new.txt")
    cLogArq  := cDrive + cDiretorio + ChgFileExt(cNome, "_correcao.log")

    If File(cArqDest) .AND. FERASE(cArqDest)==-1 ; FWAlertError("Erro ao excluir: "+cArqDest,"Erro") ; Return(NIL) ; EndIf
    If File(cLogArq)  .AND. FERASE(cLogArq) ==-1 ; FWAlertError("Erro ao excluir: "+cLogArq, "Erro") ; Return(NIL) ; EndIf

    nHLog := FCreate(cLogArq)
    If nHLog < 0 ; FWAlertError("Erro ao criar LOG.","Erro",NIL) ; Return(NIL) ; EndIf

    nHDest := FCreate(cArqDest)
    If nHDest < 0 ; FWAlertError("Erro ao criar arquivo de saida.","Erro",NIL) ; FClose(nHLog) ; Return(NIL) ; EndIf

    FWrite(nHLog, Replicate("=",80)+CRLF+"  LOG CORRECAO C190 x C100 - SPED EFD"+CRLF+Replicate("=",80)+CRLF)
    FWrite(nHLog, "Origem  : " + cArqOrig + CRLF + "Destino : " + cArqDest + CRLF)
    FWrite(nHLog, "Inicio  : " + cDataHoraIni + CRLF + Replicate("-",80) + CRLF + CRLF)

    If .NOT. File(cArqOrig)
        FWAlertError("Arquivo nao encontrado.","Erro",NIL) ; FClose(nHLog) ; FClose(nHDest) ; Return(NIL)
    EndIf

    FWMsgRun(,{|| nHandle:=FT_FUse(cArqOrig)},"Processando","Aguarde... lendo arquivo...")
    If nHandle==-1 ; FWAlertError("Erro na abertura.","Erro na abertura",NIL) ; FClose(nHLog) ; FClose(nHDest) ; Return(NIL) ; EndIf

    FT_FGoTop()
    aLinhas := {}
    While .NOT. FT_FEOF()
        AAdd(aLinhas, FT_FReadLn()) ; FT_FSKIP()
    EndDo
    FT_FUSE()

    nTotLinhas := Len(aLinhas)
    FWrite(nHLog, "Total de linhas: " + cValToChar(nTotLinhas) + CRLF + CRLF)
    FWrite(nHLog, Replicate("=",80)+CRLF+"  DIVERGENCIAS E CORRECOES"+CRLF+Replicate("=",80)+CRLF+CRLF)

    ProcRegua(nTotLinhas)

    For nIndex := 1 To nTotLinhas
        IncProc()
        aCampos := StrTokArr(aLinhas[nIndex], "|")
        If Len(aCampos) < 2 ; Loop ; EndIf

        If AllTrim(aCampos[1]) == "C100"
            If lDentroC100
                BRSPEDN092(nHLog,@aLinhas,@aC190Bloco, ;
                    cNumDoc,cSerDoc,cCnpjPart,cChvNFe,cDtDoc,cIndOper, ;
                    nVlDoc,nSomaOpr,nLinC100, ;
                    @nTotDiverg,@nTotOk,@nTotCorrig,@nSomaDif,@nSomaVlOpr)
            EndIf
            lDentroC100 := .T. ; nLinC100 := nIndex ; nSomaOpr := 0 ; aC190Bloco := {} ; nTotC100++
            cIndOper  := If(Len(aCampos)>=2,  AllTrim(aCampos[2]),  "")
            cCnpjPart := If(Len(aCampos)>=4,  AllTrim(aCampos[4]),  "")
            cSerDoc   := If(Len(aCampos)>=7,  AllTrim(aCampos[7]),  "")
            cNumDoc   := If(Len(aCampos)>=8,  AllTrim(aCampos[8]),  "")
            cChvNFe   := If(Len(aCampos)>=9,  AllTrim(aCampos[9]),  "")
            cDtDoc    := If(Len(aCampos)>=10, AllTrim(aCampos[10]), "")
            nVlDoc    := If(Len(aCampos)>=12, Val(StrTran(AllTrim(aCampos[12]),",",".")), 0)
            nSomaVlDoc += nVlDoc

        ElseIf AllTrim(aCampos[1]) == "C190" .AND. lDentroC100
            nVlOpr   := If(Len(aCampos)>=5, Val(StrTran(AllTrim(aCampos[5]),",",".")), 0)
            nSomaOpr += nVlOpr ; nTotC190++
            AAdd(aC190Bloco, {nIndex, nVlOpr})

        ElseIf AllTrim(aCampos[1]) $ "C200|C990|D001|D100|D990|E001|E990|0990|9001|9900|9990|9999"
            If lDentroC100
                BRSPEDN092(nHLog,@aLinhas,@aC190Bloco, ;
                    cNumDoc,cSerDoc,cCnpjPart,cChvNFe,cDtDoc,cIndOper, ;
                    nVlDoc,nSomaOpr,nLinC100, ;
                    @nTotDiverg,@nTotOk,@nTotCorrig,@nSomaDif,@nSomaVlOpr)
                lDentroC100 := .F. ; aC190Bloco := {}
            EndIf
        EndIf
    Next nIndex

    If lDentroC100
        BRSPEDN092(nHLog,@aLinhas,@aC190Bloco, ;
            cNumDoc,cSerDoc,cCnpjPart,cChvNFe,cDtDoc,cIndOper, ;
            nVlDoc,nSomaOpr,nLinC100, ;
            @nTotDiverg,@nTotOk,@nTotCorrig,@nSomaDif,@nSomaVlOpr)
    EndIf

    For nIndex := 1 To nTotLinhas
        FWrite(nHDest, aLinhas[nIndex] + CRLF)
    Next nIndex

    cDataHoraFim := DtoC(Date()) + " " + Time()
    cHoraFim     := Time()

    FWrite(nHLog, CRLF+Replicate("=",80)+CRLF+"  RESUMO GERAL"+CRLF+Replicate("=",80)+CRLF)
    FWrite(nHLog, "Total linhas         : " + cValToChar(nTotLinhas)  + CRLF)
    FWrite(nHLog, "Registros C100       : " + cValToChar(nTotC100)    + CRLF)
    FWrite(nHLog, "Registros C190       : " + cValToChar(nTotC190)    + CRLF)
    FWrite(nHLog, "Blocos SEM diverg.   : " + cValToChar(nTotOk)      + CRLF)
    FWrite(nHLog, "Blocos COM diverg.   : " + cValToChar(nTotDiverg)  + CRLF)
    FWrite(nHLog, "C190 corrigidos      : " + cValToChar(nTotCorrig)  + CRLF)
    FWrite(nHLog, Replicate("-",80) + CRLF)
    FWrite(nHLog, "Soma VL_DOC C100     : " + Transform(nSomaVlDoc,"@E 999,999,999.99") + CRLF)
    FWrite(nHLog, "Soma VL_OPR C190     : " + Transform(nSomaVlOpr,"@E 999,999,999.99") + CRLF)
    FWrite(nHLog, "Soma diferencas      : " + Transform(nSomaDif,  "@E 999,999,999.99") + CRLF)
    FWrite(nHLog, Replicate("-",80) + CRLF)
    FWrite(nHLog, "Inicio               : " + cDataHoraIni + CRLF)
    FWrite(nHLog, "Fim                  : " + cDataHoraFim + CRLF)
    FWrite(nHLog, "Tempo                : " + ElapTime(cHoraIni,cHoraFim) + CRLF)
    FWrite(nHLog, Replicate("=",80) + CRLF)
    FClose(nHLog) ; FClose(nHDest)

    FWAlertSuccess("Processamento finalizado!" + CRLF + CRLF + ;
        "C100            : " + cValToChar(nTotC100)   + CRLF + ;
        "C190            : " + cValToChar(nTotC190)   + CRLF + ;
        "Com divergencia : " + cValToChar(nTotDiverg) + CRLF + ;
        "C190 corrigidos : " + cValToChar(nTotCorrig) + CRLF + ;
        "Soma diferencas : " + Transform(nSomaDif,"@E 999,999,999.99") + CRLF + CRLF + ;
        "Arquivo: " + cArqDest + CRLF + "Log: " + cLogArq, "Correcao Concluida")

Return (NIL)

/*/{Protheus.doc} BRSPEDN092
Avalia um bloco C100+C190. Se houver divergencia entre VL_DOC e soma
VL_OPR (tolerancia 0,02), redistribui o VL_DOC proporcionalmente.
O ultimo C190 absorve o residuo de arredondamento para soma exata.
@type Static Function
@version 1.00
@author marioantonaccio
@since 09/04/2026
@param nHLog,      Numeric,   Handle do log
@param aLinhas,    Array,     Array de linhas (by reference)
@param aC190Bloco, Array,     {{nIndice, nVlOpr}...} (by reference)
@param cNumDoc     Character, Numero do documento
@param cSerDoc     Character, Serie
@param cCnpjPart   Character, CNPJ participante
@param cChvNFe     Character, Chave NFe
@param cDtDoc      Character, Data documento
@param cIndOper    Character, Indicador operacao (0=entrada / 1=saida)
@param nVlDoc      Numeric,   VL_DOC do C100
@param nSomaOpr    Numeric,   Soma VL_OPR dos C190 originais
@param nLinC100    Numeric,   Indice do C100 no array
@param nTotDiverg  Numeric,   Contador divergencias (by reference)
@param nTotOk      Numeric,   Contador OK (by reference)
@param nTotCorrig  Numeric,   Contador C190 corrigidos (by reference)
@param nSomaDif    Numeric,   Soma das diferencas (by reference)
@param nSomaVlOpr  Numeric,   Soma total VL_OPR originais (by reference)
@return NIL
/*/
Static Function BRSPEDN092( ;
    nHLog, aLinhas, aC190Bloco, ;
    cNumDoc, cSerDoc, cCnpjPart, cChvNFe, cDtDoc, cIndOper, ;
    nVlDoc, nSomaOpr, nLinC100, ;
    nTotDiverg, nTotOk, nTotCorrig, nSomaDif, nSomaVlOpr ;
)
    Local nDiferenca  := 0    as numeric
    Local nTolerancia := 0.02 as numeric
    Local nI          := 0    as numeric
    Local nJ          := 0    as numeric
    Local nIdxArr     := 0    as numeric
    Local nVlOprOrig  := 0    as numeric
    Local nNovoVlOpr  := 0    as numeric
    Local nAcumCorrig := 0    as numeric
    Local cLinhaNova  := ""   as character
    Local aCamposC190 := {}   as array
    Local cCfop       := ""   as character

    nSomaVlOpr += nSomaOpr

    If Len(aC190Bloco) == 0 ; nTotOk++ ; Return(NIL) ; EndIf

    nDiferenca := Abs(nVlDoc - nSomaOpr)

    If nDiferenca <= nTolerancia ; nTotOk++ ; Return(NIL) ; EndIf

    nTotDiverg++ ; nSomaDif += nDiferenca

    FWrite(nHLog, Replicate("-",80) + CRLF)
    FWrite(nHLog, "[DIVERGENCIA] C100 Linha: " + cValToChar(nLinC100) + CRLF)
    FWrite(nHLog, "  Operacao    : " + If(cIndOper=="0","ENTRADA","SAIDA") + CRLF)
    FWrite(nHLog, "  Documento   : " + cNumDoc + " / " + cSerDoc + CRLF)
    FWrite(nHLog, "  Participante: " + cCnpjPart + CRLF)
    FWrite(nHLog, "  Data Doc.   : " + cDtDoc + CRLF)
    FWrite(nHLog, "  Chave NFe   : " + cChvNFe + CRLF)
    FWrite(nHLog, "  VL_DOC C100 : " + Transform(nVlDoc,    "@E 999,999,999.99") + CRLF)
    FWrite(nHLog, "  Soma C190   : " + Transform(nSomaOpr,  "@E 999,999,999.99") + CRLF)
    FWrite(nHLog, "  Diferenca   : " + Transform(nDiferenca,"@E 999,999,999.99") + CRLF)
    FWrite(nHLog, "  " + Replicate(".",76) + CRLF)
    FWrite(nHLog, "  "+PadR("CFOP",6)+" "+PadL("VL_OPR ORIG",18)+" "+PadL("VL_OPR NOVO",18)+" "+PadL("DIFERENCA",14)+CRLF)
    FWrite(nHLog, "  " + Replicate(".",76) + CRLF)

    nAcumCorrig := 0

    For nI := 1 To Len(aC190Bloco)
        nIdxArr    := aC190Bloco[nI][1]
        nVlOprOrig := aC190Bloco[nI][2]

        If nSomaOpr <> 0
            nNovoVlOpr := Round(nVlDoc * (nVlOprOrig / nSomaOpr), 2)
        Else
            nNovoVlOpr := Round(nVlDoc / Len(aC190Bloco), 2)
        EndIf

        If nI == Len(aC190Bloco)
            nNovoVlOpr := Round(nVlDoc - nAcumCorrig, 2)
        Else
            nAcumCorrig += nNovoVlOpr
        EndIf

        aCamposC190 := StrTokArr(aLinhas[nIdxArr], "|")
        cCfop       := If(Len(aCamposC190)>=3, AllTrim(aCamposC190[3]), "")

        FWrite(nHLog, "  "+PadR(cCfop,6)+" "+;
            PadL(Transform(nVlOprOrig,"@E 999,999,999.99"),18)+" "+;
            PadL(Transform(nNovoVlOpr,"@E 999,999,999.99"),18)+" "+;
            PadL(Transform(Abs(nNovoVlOpr-nVlOprOrig),"@E 999,999,999.99"),14)+CRLF)

        If Len(aCamposC190) >= 5
            aCamposC190[5] := AllTrim(StrTran(Transform(nNovoVlOpr,"@E 999999999.99"),".","," ))
            cLinhaNova := "|"
            For nJ := 1 To Len(aCamposC190)
                cLinhaNova += aCamposC190[nJ]
                If nJ < Len(aCamposC190) ; cLinhaNova += "|" ; EndIf
            Next nJ
            aLinhas[nIdxArr] := cLinhaNova + "||"
            nTotCorrig++
        EndIf
    Next nI

    FWrite(nHLog, "  " + Replicate(".",76) + CRLF + CRLF)

Return (NIL)
