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

    Local aCampos      := {}  as array
    Local aLinhas      := {}  as array
    Local cArqCSV      := ""  as character
    Local cDataHoraFim := " " as character
    Local cDataHoraIni := " " as character
    Local cHoraFim     := " " as character
    Local cHoraIni     := " " as character
    Local cLinha       := ""  as character
    Local cLog         := ""  as character
    Local nHandle      := 0   as numeric
    Local nHLog        := 0   as numeric
    Local nI           := 0   as numeric
    Local nLinhaC      := 0   as numeric
    Local nLinhaI      := 0   as numeric
    Private nAlt       := 0   as numeric

    // --- Data e hora ---
    // Seleção do CSV
    cArqCSV := cGetFile( "Arquivos CSV (*.csv)|*.csv","Selecione o arquivo CSV" )

    If Empty(cArqCSV)
        FWAlertError("Nenhum arquivo selecionado.", "Processo cancelado")
        Return (NIL)
    EndIf

    cLog := StrTran(cArqCSV, ".csv", ".log")
    nHLog := FCreate(cLog)

    // Abrindo o CSV para leitura
    nHandle := FT_FUse(cArqCSV)
    If nHandle == -1
        FWAlertError("Erro ao abrir o CSV.", "Erro")
        Return (NIL)
    EndIf

    // Criando arquivo de log
    If nHLog < 0
        FT_USE() // Fecha o CSV
        FWAlertError("Erro ao criar o log.", "Erro")
        Return (NIL)
    EndIf

    FT_FGoTop()
    While .NOT. FT_FEOF()
        cLinha  := FT_FReadLn()
        AAdd(aLinhas, cLinha)
        FT_FSKIP()
    End
    // Fecha o Arquivo
    FT_FUSE()

    If Len(aLinhas) > 0
        If .NOT. FWAlertNoYes("O arquivo CSV contem "+cValToChar(Len(aLinhas))+ " linhas"+CRLF+CRLF+;
            "Continua a Alteração?", "Linhas CSV")
            FClose(nHLog)
            Return (NIL)
        EndIf
    Else
        FWAlertError("O arquivo CSV esta vazio.", "Erro")
        FClose(nHLog)
        Return (NIL)
    End

    cDataHoraIni := DtoC(Date()) + " " + Time()
    cHoraIni     := Time()
    // Cabecalho do LOG
    FWrite(nHLog, Replicate("=", 80) + CRLF)
    FWrite(nHLog, "  ALTERACAO GRUPO TRIBUTAÇÂO CLIENTE" + CRLF)
    FWrite(nHLog, Replicate("=", 80) + CRLF)
    FWrite(nHLog, "Arquivo origem  : " + cArqCSV + CRLF)
    FWrite(nHLog, "Arquivo log     : " + cLog   + CRLF)
    FWrite(nHLog, "Inicio          : " + cDataHoraIni + CRLF)
    FWrite(nHLog, Replicate("-", 80) + CRLF + CRLF)

    ProcRegua(Len(aLinhas))

    For nI := 1 To Len(aLinhas)

        IncProc()
        aCampos := StrTokArr(aLinhas[nI], ";")

        // Ignora cabeçalho
        If "CODIGO" $ Upper(aCampos[1])
            nLinhaC++
            Loop
        EndIf

        If Len(aCampos) < 2
            nLinhaI++
            FWrite(nHLog, "Linha inválida: " + cLinha + CRLF)
            Loop
        EndIf

        AtualSA1( AllTrim(aCampos[1]),AllTrim(aCampos[2]),nHLog,nI )

    Next
    cDataHoraFim := DtoC(Date()) + " " + Time()
    cHoraFim     := Time()

    FWrite(nHLog, CRLF + Replicate("=", 80) + CRLF)
    FWrite(nHLog, "  RESUMO GERAL DO PROCESSAMENTO" + CRLF)
    FWrite(nHLog, Replicate("=", 80) + CRLF)
    FWrite(nHLog, "Total de linhas no arquivo        : " + cValToChar(Len(aLinhas))  + CRLF)
    FWrite(nHLog, "Total de linhas inválidas         : " + cValToChar(nLinhaI)  + CRLF)
    FWrite(nHLog, "Total Cabecalho                   : " + cValToChar(nLinhaC)  + CRLF)
    FWrite(nHLog, "Registros Alterados               : " + cValToChar(nAlt)  + CRLF)
    FWrite(nHLog, Replicate("-", 80) + CRLF)
    FWrite(nHLog, "Inicio do processamento           : " + cDataHoraIni + CRLF)
    FWrite(nHLog, "Fim do processamento              : " + cDataHoraFim + CRLF)
    FWrite(nHLog, "Tempo total                       : " + ElapTime(cHoraIni, cHoraFim) + CRLF)
    FWrite(nHLog, Replicate("=", 80) + CRLF)
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
@param nLinha, numeric, Número da linha
@return character, sem retorno
/*/
Static Function AtualSA1(cCodigo, cGrupo, nHLog, nLinha)

    SA1->(DbSetOrder(1)) // A1_FILIAL + A1_COD

    If SA1->(DbSeek(xFilial("SA1") + cCodigo))

        While .NOT. SA1->(EOF()) .And. SA1->A1_COD == cCodigo

            If SA1->A1_GRPTRIB <> cGrupo

                FWrite(nHLog, "Alterado Grupo: Codigo/Loja: " + cCodigo + "/" + SA1->A1_LOJA+" Linha:" + Str(nLinha,6)  + CRLF)
                FWrite(nHLog, " GRUPO ANTES : " + SA1->A1_GRPTRIB + CRLF)
                FWrite(nHLog, " GRUPO DEPOIS: " + cGrupo + CRLF + CRLF)

                RecLock("SA1", .F.)
                SA1->A1_GRPTRIB := cGrupo
                MsUnlock()
                nAlt++
            Else
                FWrite(nHLog, "Sem Alteração de Grupo:  Codigo/Loja: " + cCodigo + "/" + SA1->A1_LOJA+" Linha:" + Str(nLinha,6)  + CRLF)
            EndIf

            SA1->(DbSkip())
        EndDo

    ElSE
        FWrite(nHLog,"CODIGO NAO ENCONTRADO: " + cCodigo + " Linha:" + Str(nLinha,6) + CRLF+CRLF)
    EndIf

Return (NIL)
