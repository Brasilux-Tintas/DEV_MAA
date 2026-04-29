#Include "protheus.ch"
#Include "fileio.ch"
/*/{Protheus.doc} BRIMPEXT
Ajuste do programa de exrato Bradesco - correção do tipo de D/C das ocorrencias
@type function Processamento
@version  1.00
@author marioantonaccio
@since 16/03/2026
@return character, sme retorno
/*/
User Function BRIMPEXT()
    Local cFile     := ""
    Local lFullLog  := .F.
    Local aRules    := {}
    
    // 1. Seleção do Arquivo
    cFile := cGetFile("CNAB RET|*.ret|CNAB REM|*.rem|Arq.TXT|*.txt|Todos|*.*", ;
                      "Selecione o arquivo CNAB", 1, "C:\", .F., ;
                      GETF_LOCALHARD + GETF_NETWORKDRIVE, .T.)

    If Empty(cFile)
        Return (Nil)
    EndIf

    // 2. Definição das Regras
    // Estrutura: {PosBusca, TamBusca, ValBusca, PosTroca, TamTroca, ValNovo}
    AAdd(aRules, {1, 1, "1", 22, 10, "0012345678"}) // Exemplo CNAB
    
    // 3. Opção de Log
    lFullLog := MsgYesNo("Deseja gerar Log Detalhado?", "Auditoria")

    // 4. Inicia Processamento
    MsgRun("Processando arquivo, aguarde...", "CNAB", {|| BRIMPE01(cFile, aRules, lFullLog)})

Return (Nil)

/*/{Protheus.doc} BRIMPE01
Provessamento do arquivo TXT
@type function Processamento
@version  1.00
@author marioantonaccio
@since 16/03/2026
@param cFileIn, character, nome do arquivo a ser processado
@param aRules, array, array com as regras de troca
@param lFullLog, logical, Gera ou nao o LOG 
@return logical, sempre verdadeiro
/*/
Static Function BRIMPE01(cFileIn, aRules, lFullLog)

    Local cFileTemp :=   GetNextAlias()+"_tmp.txt"
    Local cFileLog  :=  GetNextAlias()+".log"
    Local nHdlOut   := -1
    Local nHdlLog   := -1
    Local nLines    := 0
    Local nChanges  := 0
    Local cLine     := ""
    Local cOldLine  := ""
    Local n         := 0
    Local nFileSize := 0

    // Abertura para leitura
    FT_FUse(cFileIn)
    If FT_FError() <> 0
        MsgStop("Erro ao abrir arquivo!")
        Return (.F.)
    EndIf

    nFileSize := FT_FLastRec()
    nHdlOut   := FCreate(cFileTemp)
    nHdlLog   := FCreate(cFileLog)

    If nHdlOut == -1 .Or. nHdlLog == -1
        FT_FUse()
        MsgStop("Erro ao criar arquivos de saída!")
        Return (.F.)
    EndIf

    // Cabeçalho Log
    FWrite(nHdlLog, "[" + Time() + "] INICIO: " + cFileIn + CRLF)

    FT_FGotop()
    While .NOT. FT_FEOF()
        cLine := FT_FReadLn()
        nLines++
        cOldLine := cLine

        // Aplicação das Regras
        For n := 1 To Len(aRules)
            If SubStr(cLine, aRules[n][1], aRules[n][2]) == aRules[n][3]
                cLine := Stuff(cLine, aRules[n][4], aRules[n][5], PadR(aRules[n][6], aRules[n][5]))
                nChanges++
            EndIf
        Next

        // Log Detalhado
        If lFullLog .And. .NOT. (cLine == cOldLine)
            FWrite(nHdlLog, "[" + Time() + "] L:" + AllTrim(Str(nLines)) + " Alterada" + CRLF)
        EndIf

        FWrite(nHdlOut, cLine + CRLF)
        FT_FSkip()
    EndDo

    // Finalização
    FWrite(nHdlLog, "[" + Time() + "] FIM. Linhas: " + Str(nLines) + " Alteracoes: " + Str(nChanges) + CRLF)
    
    FT_FUse()
    FClose(nHdlOut)
    FClose(nHdlLog)

    // Substituição do Arquivo
    If FErase(cFileIn) == 0
        FRename(cFileTemp, cFileIn)
         FWAlertInfo("Arquivo atualizado com sucesso!" + CRLF + "Log gerado: " + cFileLog,"Log Gerado")
    Else
        FWAlertError("Erro ao substituir arquivo original.","Erro na Gravacao")
    EndIf

Return (.T.)
