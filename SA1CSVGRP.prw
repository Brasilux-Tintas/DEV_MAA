#Include "Protheus.ch"
#Include "fileio.ch"

/*/{Protheus.doc} SA1CSVGRP
Programa que lê um CSV com Codigo;Grupo e atualiza o campo Grupo na SA1
@type function Processamento
@version  1.0   
@author marioantonaccio
@since 15/04/2026
@return character, sem retorno
/*/
User Function SA1CSVGRP()

    Local cMsg := ""
    
    cMsg := ;
        "Este programa executa:" + CRLF + ;
        "- Leitura de arquivo CSV (Codigo;Grupo)" + CRLF + ;
        "- Procura o Codigo na SA1" + CRLF + ;
        "- Atualiza o campo Grupo Tributação em todas as ocorrências" + CRLF + CRLF + ;
        "Clique SIM para selecionar o arquivo CSV."

    If .NOT. FWAlertNoYes(cMsg, "Atualização Grupo Tributação Cliente via CSV")
        Return NIL
    EndIf

    Processa({|| ProcCSV()}, "Processando CSV...")

Return (NIL)

/*/{Protheus.doc} ProcCSV
Lê o CSV e chama a atualização da SA1
@type function Processamento
@version  1.0
@author marioantonaccio
@since 15/04/2026
@return character, sem retorno
/*/
Static Function ProcCSV()

    Local cArqCSV     := ""
    Local cLinha      := ""
    Local aCampos     := {}
    Local nHandle     := 0
    Local nLinha      := 0
    Local cLog        := ""
    Local nHLog       := 0

    // Seleção do CSV
    cArqCSV := cGetFile( "Arquivos CSV (*.csv)|*.csv", ;
                         "Selecione o arquivo CSV" )

    If Empty(cArqCSV)
        FWAlertError("Nenhum arquivo selecionado.", "Processo cancelado")
        Return NIL
    EndIf

    cLog := StrTran(cArqCSV, ".csv", ".log")
    nHLog := FCreate(cLog)

    If nHLog < 0
        FWAlertError("Erro ao criar o log.", "Erro")
        Return NIL
    EndIf

    FWrite(nHLog, "LOG ATUALIZAÇÃO SA1 - CSV" + CRLF)
    FWrite(nHLog, "Arquivo: " + cArqCSV + CRLF + CRLF)

    nHandle := FT_FUse(cArqCSV)
    If nHandle == -1
        FWAlertError("Erro ao abrir o CSV.", "Erro")
        FClose(nHLog)
        Return NIL
    EndIf

    FT_FGoTop()

    While .NOT. FT_FEOF()

        cLinha := FT_FReadLn()
        FT_FSkip()
        nLinha++

        // Ignora cabeçalho
        If nLinha == 1 .And. "CODIGO" $ Upper(cLinha)
            Loop
        EndIf

        aCampos := StrTokArr(cLinha, ";")

        If Len(aCampos) < 2
            FWrite(nHLog, "Linha inválida: " + cLinha + CRLF)
            Loop
        EndIf

        AtualSA1( AllTrim(aCampos[1]), ;
                     AllTrim(aCampos[2]), ;
                     nHLog )

    EndDo

    FT_FUse()
    FClose(nHLog)

    FWAlertSuccess("Processamento finalizado!" + CRLF + ;
                   "Log: " + cLog, "Concluído")

Return (NIL)

/*/{Protheus.doc} AtualSA1
Atualiza todas as ocorrências do código na SA1
@type function Processamento
@version  1.00
@author marioantonaccio
@since 15/04/2026
@param cCodigo, character, Codigo do Cliente
@param cGrupo, character, Grupo Tributação
@param nHLog, numeric, Handle do arquivo de log
@return character, sem retorno
/*/
Static Function AtualSA1(cCodigo, cGrupo, nHLog)

    Local lAchou := .F.
    Local nAlt   := 0

    SA1->(DbSetOrder(1)) // A1_FILIAL + A1_COD

    If SA1->(DbSeek(xFilial("SA1") + cCodigo))

        While .NOT. SA1->(EOF()) .And. SA1->A1_COD == cCodigo

            lAchou := .T.

            If SA1->A1_GRPTRIB <> cGrupo
                RecLock("SA1", .F.)
                SA1->A1_GRPTRIB := cGrupo
                MsUnlock()
                nAlt++
            EndIf

            SA1->(DbSkip())
        EndDo

    EndIf

    If lAchou
        FWrite(nHLog, ;
            "CODIGO: " + cCodigo + ;
            " | Grupo Tributacao aplicado: " + cGrupo + ;
            " | Registros alterados: " + cValToChar(nAlt) + CRLF)
    Else
        FWrite(nHLog, ;
            "CODIGO NAO ENCONTRADO: " + cCodigo + CRLF)
    EndIf

Return (NIL)
