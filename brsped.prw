#Include "Protheus.ch"
#Include "fileio.ch"
/*/{Protheus.doc} BRSPED
Programa que analisa o arquivo SPED gerado e faz correções gerando um novo arquivo
@type function Processamento
@version  1.00
@author marioantonaccio
@since 25/03/2026
@return character, sem retorno
/*/
User Function BRSPED()

	Local cMsgIntro      := "" as character

	cMsgIntro := ;
		"Este programa executa:" + CRLF + ;
		" • Leitura completa do arquivo TXT" + CRLF + ;
		" • Separação dos campos via ' | '(pipe)" + CRLF + ;
		" • Ajuste de linhas conforme regras "+ CRLF + ;
		" • Geração de LOG detalhado" + CRLF + CRLF + ;
		"Clique SIM para selecionar o arquivo."

	If .NOT. FWAlertNoYes(cMsgIntro, "Processador de Arquivos TXT / SPED")
		Return (NIL)
	Else
		Processa({|| BRSPED001()}, "Lendo arquivo....")
	EndIf

Return (NIL)

/*/{Protheus.doc} BRSPED01
Inicia o processamento do arquivo txt
@type function Processamento
@version 1.00
@author marioantonaccio
@since 25/03/2026
@return character,sem retorno
/*/
Static Function BRSPED001()
	Local aCampos      := {}  as array
	Local cAntes       := " " as character
	Local cArqDest     := " " as character
	Local cArqHARA     := " " as character // Arquivo log
	Local cArqHGUA     := " " as character // Arquivo log
	Local cArqOrig     := " " as character // Arquivo log
	Local cDataHoraFim := " " as character
	Local cDataHoraIni := " " as character
	Local cDiretorio   := " " as character
	Local cDrive       := " " as character
	Local cExtensao    := " " as character
	Local cHoraFim     := " " as character
	Local cHoraIni     := " " as character
	Local cLinha       := " " as character // Linha lida
	Local cLinhaNova   := " " as character 
	Local cLogArq      := " " as character // Arquivo log
	Local cNew         := " " as character
	Local cNome        := " " as character
	Local nAlt         := 0   as numeric
	Local nExc         := 0   as numeric
	Local nHandle      := 0   as numeric
	Local nHDest       := 0   as numeric // Handle arquivo final
	Local nHLog        := 0   as numeric // Handle arquivo log
	Local nHDelete     := 0   as numeric // Handle arquivo log
	Local nIndex       := 0   as numeric // Contador

	cDataHoraIni := DtoC(Date()) + " " + Time()
	cHoraIni :=  Time()

	// SELEÇÃO DO ARQUIVO VIA CGETFILE()
	cArqOrig := cGetFile("Arquivos TXT (*.txt)|*.txt|", "Selecione o arquivo para processamento")
	If Empty(cArqOrig)
		FWAlertError("Nenhum arquivo selecionado.","Seleção de arquivo", NIL)
		Return (NIL)
	EndIf

	SplitPath(cArqOrig, @cDrive, @cDiretorio, @cNome, @cExtensao)
	cArqDest := cDrive+cDiretorio+ChgFileExt(cNome,"_new.txt")
	cLogArq  := cDrive+cDiretorio+ChgFileExt(cNome, ".log")

	cArqHARA     := cDrive+cDiretorio+ChgFileExt(cNome,"_HARA.txt")
	cArqHGUA     := cDrive+cDiretorio+ChgFileExt(cNome,"_HGUA.txt")
	cArqDelete   := cDrive+cDiretorio+ChgFileExt(cNome,"_del.txt")

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

	If File(cArqHARA)
		If FERASE(cArqHARA) == -1
			FWAlertError("Nao foi possivel exluir o arquivo "+CRLF+cArqHARA,"Nao exclusao de Arquivo")
			Return (NIL)
		End
	End
	If File(cArqHGUA)
		If FERASE(cArqHGUA) == -1
			FWAlertError("Nao foi possivel exluir o arquivo "+CRLF+cArqHGUA,"Nao exclusao de Arquivo")
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
	Else
		FWAlertError("Arquivo nao encontrado.", "Nao encontrado", NIL)
		Return (NIL)
	EndIf

	//Processando C170  tirando CST com 2 posicoes
	ProcRegua(Len(aLinhas))

	For nIndex := 1 To Len(aLinhas)
		IncProc()
		aCampos := StrTokArr(aLinhas[nIndex], "|")
		cLinhaNova:=""

	
		If aCampos[1] == "0220"
			If Len(aCampos) == 4
				cAntes := "|"+AllTrim(aCampos[04])+"|"
				cNew:="| |"
				FWrite(nHLog, "ALTERAÇÃO 0220 - Linha " + Str(nIndex,6)  + CRLF)
				FWrite(nHLog, "  ANTES : " + cAntes + CRLF)
				FWrite(nHLog, "  DEPOIS: " + cNew + CRLF + CRLF)
				nAlt++
				aCampos[4]:=" "
				cLinhaNova :=  RebuildLine(aCampos)
				aLinhas[nIndex] := cLinhaNova
			End
		EndIf

/*
		If aCampos[1] $ "0305"
			aCampos:= StrTokArr(aLinhas[nIndex], "|" )
			cAntes := AllTrim(aCampos[03])
			cNew:="USO INTERNO"
			aCampos[3]:=cNew
			FWrite(nHLog, "ALTERAÇÃO 0305 - Linha " + Str(nIndex,6)  + CRLF)
			FWrite(nHLog, "  ANTES : " + cAntes + CRLF)
			FWrite(nHLog, "  DEPOIS: " + cNew + CRLF + CRLF)
			nAlt++
			cLinhaNova :=  RebuildLine(aCampos)
			//cLinhaNova :=  StrTran( aLinhas[nIndex], cAntes, cNew ,1,1)
			aLinhas[nIndex] := cLinhaNova
		EndIf
*/
	Next

	// CRIAÇÃO DO ARQUIVO FINAL
	nHDest := FCreate(cArqDest)
	If nHDest < 0
		FWAlertError("Erro ao criar arquivo destino.","Nao Criado")
		Return (NIL)
	EndIf

	If File(cArqDelete)
		If FERASE(cArqDelete) == -1
			FWAlertError("Nao foi possivel exluir o arquivo "+CRLF+cArqDelete,"Nao exclusao de Arquivo")
			Return (NIL)
		End
	End
	nHDelete := FCreate(cArqDelete)
	If nHDelete < 0
		FWAlertError("Erro ao criar o arquivo de LOG (delete).","Erro", NIL)
		Return (NIL)
	End

	ProcRegua(Len(aLinhas))
	For nIndex := 1 To Len(aLinhas)
		IncProc()
		If .NOT. ("DELETE__" $ aLinhas[nIndex] )
			FWrite(nHDest, aLinhas[nIndex] + CRLF)
		Else
			FWrite(nHDelete, "Linha "+cValToChar(nIndex)+" - "+aLinhas[nIndex] + CRLF)
		EndIf
	Next
	FClose(nHDest)
	FClose(nHDelete)

	// FECHAMENTO DO LOG
	cDataHoraFim := DtoC(Date()) + " " + Time()
	cHoraFim :=  Time()

	FWrite(nHLog, "Processamento finalizado em : " + cDataHoraFim + CRLF)
	FWrite(nHLog, "Tempo Gasto Processamento : " + Elaptime(cHoraIni,cHoraFim) + CRLF)
	FWrite(nHLog, "Arquivo gerado : " + cArqDest + CRLF)
	FWrite(nHLog, "Total de Linhas : " + cValToChar(Len(aLinhas))+ CRLF)
	FWrite(nHLog, "Alteracoes Efetuadas : " + cValToChar(nAlt) + CRLF)
	FWrite(nHLog, "Exclusoes Efetuadas : " + cValToChar(nExc) + CRLF)
	FWrite(nHLog, "Total de Alterações/Exclusoes Efetuadas : " + cValToChar(nExc+nAlt) + CRLF)

	FClose(nHLog)

	FWAlertSuccess("Processamento finalizado!" + CRLF + CRLF + ;
		"Arquivo gerado: " + cArqDest + CRLF + CRLF + ;
		"Log criado: " + cLogArq,"Processo Concluido")

Return (NIL)

/*/{Protheus.doc} RebuildLine
Reconstroi a linha a partir dos campos
@type function Processamento
@version  1.0
@author marioantonaccio
@since 25/03/2026
@param aCampos, array, Campos lidos na linha
@return character, linha ajustada
/*/
Static Function RebuildLine(aCampos)

	Local cLinhaR := "|" as character
	Local nI      := 0   as numeric
/*
	If aCampos[1] $ "0305"
		If Len(aCampos) < 4
			For nI:=1 to 4-Len(aCampos)
				AADD(aCampos,"")
			End
		End
	End
*/
	For nI := 1 To Len(aCampos)
		cLinhaR += aCampos[nI]
		If nI < Len(aCampos)
			cLinhaR += "|"
		EndIf
	Next

	cLinhaR += "|"

Return (cLinhaR)

