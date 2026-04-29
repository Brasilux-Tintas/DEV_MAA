#Include "Protheus.ch"
#Include "Totvs.ch"

User Function BRSPED_NF()

Local cMsgIntro      := "" as character

	cMsgIntro := ;
		"Este programa executa:" + CRLF + ;
		" • Leitura completa do arquivo TXT" + CRLF + ;
		" • Separação dos campos via ' | '(pipe)" + CRLF + ;
		" • Verificação de se valores estao OK (SPEDxProtheus) "+ CRLF + ;
		" • Geração de LOG detalhado" + CRLF + CRLF + ;
		"Clique SIM para selecionar o arquivo."

	If .NOT. FWAlertNoYes(cMsgIntro, "Processador de Arquivos TXT / SPED")
		Return (NIL)
	Else
		Processa({|| BRSPEDNF01()}, "Lendo arquivo....")
	EndIf

Return (NIL)

/*/{Protheus.doc} BRSPEDNF01
Inicia o processamento do arquivo txt
@type function Processamento
@version 1.00
@author marioantonaccio
@since 25/03/2026
@return character,sem retorno
/*/
Static Function BRSPEDNF01()
	Local aCampos      := {}  as array
	Local cArqDest     := " " as character
	Local cArqOrig     := " " as character // Arquivo log
	Local cDataHoraFim := " " as character
	Local cDataHoraIni := " " as character
	Local cDiretorio   := " " as character
	Local cDrive       := " " as character
	Local cExtensao    := " " as character
	Local cHoraFim     := " " as character
	Local cHoraIni     := " " as character
	Local cLinha       := " " as character // Linha lida
	Local cLogArq      := " " as character // Arquivo log
	Local cNome        := " " as character
	Local nLinGer      := 0   as numeric
	Local nHandle      := 0   as numeric
	Local nIndex       := 0   as numeric // Contador

	cDataHoraIni := DtoC(Date()) + " " + Time()
	cHoraIni :=  Time()

	// SELEção DO ARQUIVO VIA CGETFILE()
	cArqOrig := cGetFile("Arquivos TXT (*.txt)|*.txt|", "Selecione o arquivo para processamento")
	If Empty(cArqOrig)
		FWAlertError("Nenhum arquivo selecionado.","Seleção de arquivo", NIL)
		Return (NIL)
	EndIf

	SplitPath(cArqOrig, @cDrive, @cDiretorio, @cNome, @cExtensao)
	cArqDest := cDrive+cDiretorio+ChgFileExt(cNome,"_new.txt")
	cLogArq  := cDrive+cDiretorio+ChgFileExt(cNome, ".log")

	If File(cArqDest)
		If FERASE(cArqDest) == -1
			FWAlertError("Nao foi possivel exluir o arquivo "+CRLF+cArqDest,"Nao exclusao de Arquivo")
			Return (NIL)
		End
	End
	If File(cLogArq)
		If FERASE(cLogArq) == -1
			FWAlertError("Nao foi possivel exluir o arquivo "+CRLF+cLogArq,"Nao exclusao de Arquivo")
			Return (NIL)
		End
	End

	nHLog := FCreate(cLogArq)
	If nHLog < 0
		FWAlertError("Erro ao criar o arquivo de LOG.","Erro", NIL)
		Return (NIL)
	End

	FWrite(nHLog, "LOG DO PROCESSAMENTO" + CRLF)
	FWrite(nHLog, "Arquivo origem : " + cArqOrig + CRLF)
	FWrite(nHLog, "Processo iniciado em : " + cDataHoraIni + CRLF + CRLF)

	//Se o arquivo existir
	If File(cArqOrig)

		FWMsgRun(, {|| nHandle := FT_FUse(cArqOrig) }, "Processando", "Aguarde..lendo arquivo...")

		// Se houver erro de abertura abandona processamento
		If nHandle = -1
			FWAlertError("Erro na abertura do arquivo.", "Erro na abertura", NIL)
			Return (NIL)
		End

		FT_FGoTop()

		aLinhas:={}
		While .NOT. FT_FEOF()
			cLinha  := FT_FReadLn()
			AAdd(aLinhas, cLinha)
			FT_FSKIP()
		End
		// Fecha o Arquivo
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
        
           // ===== C100 =====
        If aCampos[1] == "C100" .and. aCampos[2]=="0"

            cCliFor := Right(aCampos[3],8)
            cChvNFE := aLinha[9]
            nC100   := Val(StrTran(aLinha[12],",","."))
            nC190   := 0
            aItem   := {}
     
            SF1->(dbSetOrder(8))
            If SF1->(dbSeek(xFilial("SF1")+cChvNFE))    
                If SF1->F1_TOTAL <> nC100
                    FWrite(nHLog,"Linha: "+cValToChar(nLinha)+" Divergencia Valor: "+CRLF+;
                        "Nota: "+SF1->F1_DOC+"/"+SF1->F1_SERIE+" Forn: "+SF1->F1_FORNECE+SF1->F1_LOJA+CRLF+;
                        "Chave NFE: "+SF1->F1_CHVNFE+CRLF+; 
                        "Protheus: "+cValToChar(SF1->F1_TOTAL)+CRLF+; 
                        "SPED: "+cValToChar(nC100)+CRLF)
                        nLinGer++
                 End
            End   
        EndIf

    Next
    // FECHAMENTO DO LOG
	cDataHoraFim := DtoC(Date()) + " " + Time()
	cHoraFim :=  Time()

	FWrite(nHLog, "Processamento finalizado em : " + cDataHoraFim + CRLF)
	FWrite(nHLog, "Tempo Gasto Processamento : " + Elaptime(cHoraIni,cHoraFim) + CRLF)
	FWrite(nHLog, "Arquivo gerado : " + cArqDest + CRLF)
	FWrite(nHLog, "Total de Linhas Geradas : " + cValToChar(nLinGer)+ CRLF)

	FClose(nHLog)

	FWAlertSuccess("Processamento finalizado!" + CRLF + CRLF + ;
		"Arquivo gerado: " + cArqDest + CRLF + CRLF + ;
		"Log criado: " + cLogArq,"Processo Concluido")

Return (NIL)
 

