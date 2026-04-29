#Include "Protheus.ch"
#Include "fileio.ch"
/*/{Protheus.doc} BRSPEDX
Programa que analisa o arquivo SPED gerado e faz correcoes gerando um novo arquivo
@type function Processamento
@version  2.00
@author marioantonaccio
@since 25/03/2026
@return character, sem retorno
/*/
User Function BRSPEDX()

	Local cMsgIntro      := "" as character

	cMsgIntro := ;
		"Este programa executa:" + CRLF + ;
		" " + Chr(149) + " Leitura completa do arquivo TXT" + CRLF + ;
		" " + Chr(149) + " Separacao dos campos via '|'(pipe)" + CRLF + ;
		" " + Chr(149) + " Ajuste de linhas conforme regras "+ CRLF + ;
		" " + Chr(149) + " Verificacao e consolidacao de duplicidades C190" + CRLF + ;
		" " + Chr(149) + " Somatorio por grupo CST+CFOP do C190" + CRLF + ;
		" " + Chr(149) + " Geracao de LOG detalhado" + CRLF + CRLF + ;
		"Clique SIM para selecionar o arquivo."

	If .NOT. FWAlertNoYes(cMsgIntro, "Processador de Arquivos TXT / SPED")
		Return (NIL)
	Else
		Processa({|| BRSPED01()}, "Lendo arquivo....")
	EndIf

Return (NIL)

/*/{Protheus.doc} BRSPED01
Inicia o processamento do arquivo txt
@type function Processamento
@version 2.00
@author marioantonaccio
@since 25/03/2026
@return character,sem retorno
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

	// SELECAO DO ARQUIVO VIA CGETFILE()
	cArqOrig := cGetFile("Arquivos TXT (*.txt)|*.txt|", "Selecione o arquivo para processamento")

	If Empty(cArqOrig)
		FWAlertError("Nenhum arquivo selecionado.","Selecao de arquivo", NIL)
		Return (NIL)
	EndIf

	SplitPath(cArqOrig, @cDrive, @cDiretorio, @cNome, @cExtensao)
	cArqDest   := cDrive+cDiretorio+ChgFileExt(cNome,"_new.txt")
	cLogArq    := cDrive+cDiretorio+ChgFileExt(cNome, ".log")
	cArqHARA   := cDrive+cDiretorio+ChgFileExt(cNome,"_HARA.txt")
	cArqHGUA   := cDrive+cDiretorio+ChgFileExt(cNome,"_HGUA.txt")
	cArqDelete := cDrive+cDiretorio+ChgFileExt(cNome,"_del.txt")

	// Remove arquivos anteriores
	If File(cArqDest)
		If FERASE(cArqDest) == -1
			FWAlertError("Nao foi possivel excluir o arquivo "+CRLF+cArqDest,"Erro na exclusao de Arquivo")
			Return (NIL)
		End
	End
	If File(cLogArq)
		If FERASE(cLogArq) == -1
			FWAlertError("Nao foi possivel excluir o arquivo "+CRLF+cLogArq,"Erro na exclusao de Arquivo")
			Return (NIL)
		End
	End
	If File(cArqHARA)
		If FERASE(cArqHARA) == -1
			FWAlertError("Nao foi possivel excluir o arquivo "+CRLF+cArqHARA,"Erro na exclusao de Arquivo")
			Return (NIL)
		End
	End
	If File(cArqHGUA)
		If FERASE(cArqHGUA) == -1
			FWAlertError("Nao foi possivel excluir o arquivo "+CRLF+cArqHGUA,"Erro na exclusao de Arquivo")
			Return (NIL)
		End
	End
	If File(cArqDelete)
		If FERASE(cArqDelete) == -1
			FWAlertError("Nao foi possivel excluir o arquivo "+CRLF+cArqDelete,"Erro na exclusao de Arquivo")
			Return (NIL)
		End
	End

	// Cria o LOG
	nHLog := FCreate(cLogArq)
	If nHLog < 0
		FWAlertError("Erro ao criar o arquivo de LOG.","Erro", NIL)
		Return (NIL)
	End

	FWrite(nHLog, "LOG DO PROCESSAMENTO" + CRLF)
	FWrite(nHLog, "Arquivo origem  : " + cArqOrig     + CRLF)
	FWrite(nHLog, "Processo iniciado em : " + cDataHoraIni + CRLF + CRLF)

	// Leitura do arquivo origem
	If File(cArqOrig)
		FWMsgRun(, {|| nHandle := FT_FUse(cArqOrig) }, "Processando", "Aguarde..lendo arquivo...")
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
		aCampos   := StrTokArr(aLinhas[nIndex], "|")
		cLinhaNova := ""

		// C170 - Corrige CST com 2 posicoes para 3
		If aCampos[1] == "C170"
			l02 := .F.
			If Len(AllTrim(aCampos[10])) == 2
				l02  := .T.
				cCFO  := aCampos[11]
				cAntes := AllTrim(aCampos[10])
				cNew   := "0" + AllTrim(aCampos[10])
				aCampos[10] := cNew
				FWrite(nHLog, "ALTERACAO C170 - Linha " + Str(nIndex,6)  + CRLF)
				FWrite(nHLog, "  ANTES : " + cAntes + CRLF)
				FWrite(nHLog, "  DEPOIS: " + cNew   + CRLF + CRLF)
				nAlt++
				cAntes     := "|"+cAntes+"|"+cCFO+"|"
				cNew       := "|"+cNew  +"|"+cCFO+"|"
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
				FWrite(nHLog, "ALTERACAO D190 - Linha " + Str(nIndex,6)  + CRLF)
				FWrite(nHLog, "  ANTES : " + cAntes + CRLF)
				FWrite(nHLog, "  DEPOIS: " + cNew   + CRLF + CRLF)
				nAlt++
				cAntes     := "|"+cAntes+"|"+cCFO+"|"
				cNew       := "|"+cNew  +"|"+cCFO+"|"
				cLinhaNova := StrTran(aLinhas[nIndex], cAntes, cNew, 1, 1)
				aLinhas[nIndex] := cLinhaNova
			End
		EndIf

		// 0220 - Remove conteudo do campo 4 quando ha apenas 4 campos
		If aCampos[1] == "0220"
			If Len(aCampos) == 4
				cAntes := "|"+AllTrim(aCampos[04])+"|"
				cNew   := "| |"
				FWrite(nHLog, "ALTERACAO 0220 - Linha " + Str(nIndex,6)  + CRLF)
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
			FWrite(nHLog, "ALTERACAO 0305 - Linha " + Str(nIndex,6)  + CRLF)
			FWrite(nHLog, "  ANTES : " + cAntes + CRLF)
			FWrite(nHLog, "  DEPOIS: " + cNew   + CRLF + CRLF)
			nAlt++
			cLinhaNova := RebuildLine(aCampos)
			aLinhas[nIndex] := cLinhaNova
		EndIf

	Next

	// ==========================================================
	// PASSO 2: Verificacao e consolidacao de duplicidades C190
	//          Estrategia: varredura por bloco (agrupado por C100)
	//          Chave de duplicidade: CST (2 ultimas posicoes) + CFOP
	//          Acao: soma valores na primeira ocorrencia, marca as
	//          demais para exclusao. Ao final gera somatorio por grupo.
	// ==========================================================
	FWrite(nHLog, "=== PASSO 2: DUPLICIDADES C190 ===" + CRLF + CRLF)

	nDC190 := C190_ProcessaDupl(@aLinhas, nHLog, @nAlt, @nExc)

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
				FWrite(nHLog, "ALTERACAO C190 CST - Linha " + Str(nIndex,6) + CRLF)
				FWrite(nHLog, "  ANTES : " + cAntes + CRLF)
				FWrite(nHLog, "  DEPOIS: " + cNew   + CRLF + CRLF)
				nAlt++
				cAntes     := "|"+cAntes+"|"+cCFO+"|"
				cNew       := "|"+cNew  +"|"+cCFO+"|"
				cLinhaNova := StrTran(aLinhas[nIndex], cAntes, cNew, 1, 1)
				aLinhas[nIndex] := cLinhaNova
			End
		End
	Next

	// ==========================================================
	// PASSO 4: Processamento H010 - Armazens de Deposito
	// ==========================================================
	FWrite(nHLog, "=== PASSO 4: PROCESSAMENTO H010 ===" + CRLF + CRLF)
	ProcRegua(Len(aLinhas))

	nDH010  := 0
	nDVH010 := 0
	cLocal  := ""
	aArmazem := {}

	For nIndex := 1 To Len(aLinhas)
		IncProc()
		cLinhaNova := ""
		aCampos    := StrTokArr(aLinhas[nIndex], "|")

		If aCampos[1] == "H005"
			dDataInv := CTOD(Substr(aCampos[2],1,2)+"/"+Substr(aCampos[2],3,2)+"/"+Substr(aCampos[2],5,4))
		End

		If aCampos[1] == "0005"
			If "BRASILUX DEPOSITO ARARAQUARA" $ AllTrim(aCampos[2])
				aArmazem := {"AF","A3"}
				cLocal   := "ARA"
			End
			If "DEPOSITO" $ AllTrim(aCampos[2])
				aArmazem := {"G1","G3"}
				cLocal   := "GUA"
			End
			If "MATRIZ" $ AllTrim(aCampos[2])
				aArmazem := {"G1","G3","AF","A3"}
				cLocal   := "MAT"
			End
		End

		If aCampos[1] == "H010"
			nQtd   := Val(StrTran(AllTrim(aCampos[4]),",","."))
			nValor := Val(StrTran(AllTrim(aCampos[6]),",","."))

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
						End
					End
				Else
					If .NOT. SB9->(dbSeek(xFilial("SB9")+Substr(aCampos[2],1,15)+aArmazem[nLocal]+DTOS(dDataInv)))
						nQtd   -= SB9->B9_QINI
						nValor -= SB9->B9_VINI1
					End
				End
			Next

			If nQtd <= 0
				nDH010++
				nDVH010 += Val(StrTran(AllTrim(aCampos[6]),",","."))
				cLinhaNova := StrTran(aLinhas[nIndex], "|H010|", "|H010__DELETE__|", 1, 1)
				aLinhas[nIndex] := cLinhaNova
				FWrite(nHLog, "EXCLUSAO H010 - Linha " + Str(nIndex,6) + CRLF + CRLF)
				nExc++
			Else
				If Val(StrTran(AllTrim(aCampos[4]),",",".")) <> nQtd .OR. ;
				   Val(StrTran(AllTrim(aCampos[6]),",",".")) <> nValor
					nDVH010 += (Val(StrTran(AllTrim(aCampos[6]),",","."))-nValor)
					FWrite(nHLog, "ALTERACAO H010 - Linha " + Str(nIndex,6) + CRLF)
					FWrite(nHLog, "  ANTES QTD : " + aCampos[4] + CRLF)
					FWrite(nHLog, "  ANTES VAL : " + aCampos[6] + CRLF)
					FWrite(nHLog, "  DEPOIS QTD: " + cValToChar(nQtd)   + CRLF)
					FWrite(nHLog, "  DEPOIS VAL: " + cValToChar(nValor) + CRLF + CRLF)
					nAlt++
					aCampos[04]     := AllTrim(Transform(nQtd,  "@ER 999999999.999"))
					aCampos[06]     := AllTrim(Transform(nValor, "@ER 999999999.99"))
					cLinhaNova      := RebuildLine(aCampos)
					aLinhas[nIndex] := cLinhaNova
				End
			End
		End
	Next

	// ==========================================================
	// PASSO 5: Acerto de totalizadores (C990, H005, 9900, 9999...)
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

			// H005 - Valor total estoque
			If aCampos[1] == "H005"
				nQtd := Val(AllTrim(StrTran(aCampos[3],",","."))) - nDVH010
				FWrite(nHLog, "ALTERACAO H005 - Linha " + Str(nIndex,6) + CRLF)
				FWrite(nHLog, "  Antes  : " + aCampos[3] + CRLF)
				FWrite(nHLog, "  Depois : " + cValToChar(nQtd) + CRLF + CRLF)
				nAlt++
				aCampos[3]      := AllTrim(Transform(nQtd,"@ER 999999999"))
				cLinhaNova      := RebuildLine(aCampos)
				aLinhas[nIndex] := cLinhaNova
			End

			// C990 - Qtd linhas bloco C
			If aCampos[1] == "C990"
				nQtd := Val(AllTrim(StrTran(aCampos[2],",","."))) - nDC190
				FWrite(nHLog, "ALTERACAO C990 - Linha " + Str(nIndex,6) + CRLF)
				FWrite(nHLog, "  Antes  : " + aCampos[2] + CRLF)
				FWrite(nHLog, "  Depois : " + cValToChar(nQtd) + CRLF + CRLF)
				nAlt++
				aCampos[2]      := AllTrim(Transform(nQtd,"@ER 999999999"))
				cLinhaNova      := RebuildLine(aCampos)
				aLinhas[nIndex] := cLinhaNova
			End

			// 9900 - Qtd por tipo de registro
			If aCampos[1] == "9900"
				nQtd := 0
				If aCampos[2] == "C190"
					nQtd := Val(AllTrim(StrTran(aCampos[3],",","."))) - nDC190
					FWrite(nHLog, "ALTERACAO 9900-C190 - Linha " + Str(nIndex,6) + CRLF)
					FWrite(nHLog, "  Antes  : " + aCampos[3] + CRLF)
					FWrite(nHLog, "  Depois : " + cValToChar(nQtd) + CRLF + CRLF)
					nAlt++
					aCampos[3]      := AllTrim(Transform(nQtd,"@ER 999999999"))
					cLinhaNova      := RebuildLine(aCampos)
					aLinhas[nIndex] := cLinhaNova
				End
				If aCampos[2] == "H010"
					nQtd := Val(AllTrim(StrTran(aCampos[3],",","."))) - nDH010
					FWrite(nHLog, "ALTERACAO 9900-H010 - Linha " + Str(nIndex,6) + CRLF)
					FWrite(nHLog, "  Antes  : " + aCampos[3] + CRLF)
					FWrite(nHLog, "  Depois : " + cValToChar(nQtd) + CRLF + CRLF)
					nAlt++
					aCampos[3]      := AllTrim(Transform(nQtd,"@ER 999999999"))
					cLinhaNova      := RebuildLine(aCampos)
					aLinhas[nIndex] := cLinhaNova
				End
			End

			// 9999 - Total de linhas do arquivo
			If aCampos[1] == "9999"
				nQtd := Val(AllTrim(StrTran(aCampos[2],",","."))) - nDelete
				FWrite(nHLog, "ALTERACAO 9999 - Linha " + Str(nIndex,6) + CRLF)
				FWrite(nHLog, "  Antes  : " + aCampos[2] + CRLF)
				FWrite(nHLog, "  Depois : " + cValToChar(nQtd) + CRLF + CRLF)
				nAlt++
				aCampos[2]      := AllTrim(Transform(nQtd,"@ER 999999999"))
				cLinhaNova      := RebuildLine(aCampos)
				aLinhas[nIndex] := cLinhaNova
			End

			// H999 - Qtd linhas bloco H
			If aCampos[1] == "H999"
				nQtd := Val(AllTrim(StrTran(aCampos[2],",","."))) - nDH010
				FWrite(nHLog, "ALTERACAO H999 - Linha " + Str(nIndex,6) + CRLF)
				FWrite(nHLog, "  Antes  : " + aCampos[2] + CRLF)
				FWrite(nHLog, "  Depois : " + cValToChar(nQtd) + CRLF + CRLF)
				nAlt++
				aCampos[2]      := AllTrim(Transform(nQtd,"@ER 999999999"))
				cLinhaNova      := RebuildLine(aCampos)
				aLinhas[nIndex] := cLinhaNova
			End

			// H990 - Qtd linhas bloco H (encerrament)
			If aCampos[1] == "H990"
				nQtd := Val(AllTrim(StrTran(aCampos[2],",","."))) - nDH010
				FWrite(nHLog, "ALTERACAO H990 - Linha " + Str(nIndex,6) + CRLF)
				FWrite(nHLog, "  Antes  : " + aCampos[2] + CRLF)
				FWrite(nHLog, "  Depois : " + cValToChar(nQtd) + CRLF + CRLF)
				nAlt++
				aCampos[2]      := AllTrim(Transform(nQtd,"@ER 999999999"))
				cLinhaNova      := RebuildLine(aCampos)
				aLinhas[nIndex] := cLinhaNova
			End
		Next
	End

	// ==========================================================
	// PASSO 6: Gravacao do arquivo final e arquivo de deletados
	// ==========================================================
	nHDest := FCreate(cArqDest)
	If nHDest < 0
		FWAlertError("Erro ao criar arquivo destino.","Nao Criado")
		Return (NIL)
	EndIf

	nHDelete := FCreate(cArqDelete)
	If nHDelete < 0
		FWAlertError("Erro ao criar o arquivo de LOG (delete).","Erro", NIL)
		Return (NIL)
	End

	ProcRegua(Len(aLinhas))
	For nIndex := 1 To Len(aLinhas)
		IncProc()
		If .NOT. ("DELETE__" $ aLinhas[nIndex])
			FWrite(nHDest,   aLinhas[nIndex] + CRLF)
		Else
			FWrite(nHDelete, "Linha "+cValToChar(nIndex)+" - "+aLinhas[nIndex] + CRLF)
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
			FWAlertError("Erro ao criar arquivo destino.","Nao Criado")
			Return (NIL)
		EndIf
		nTotEst := 0
		For nIndex := 1 To Len(aH010ARA)
			aCampos  := StrTokArr(aH010ARA[nIndex], "|")
			nTotEst  += Val(StrTran(aCampos[06],",","."))
		End
		aDep := {}
		AADD(aDep, "|H001|0|")
		AADD(aDep, "|H005|"+GravaData(dDataInv,.F.,5)+"|"+AllTrim(Transform(nTotEst,"@ER 999999999.99"))+"|01|")
		For nIndex := 1 To Len(aH010ARA)
			AADD(aDep, aH010ARA[nIndex])
		Next
		AADD(aDep, "|H990|"+AllTrim(cValToChar(Len(aH010ARA)+2))+"|")
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
			FWAlertError("Erro ao criar arquivo destino.","Nao Criado")
			Return (NIL)
		EndIf
		nTotEst := 0
		For nIndex := 1 To Len(aH010GUA)
			aCampos  := StrTokArr(aH010GUA[nIndex], "|")
			nTotEst  += Val(StrTran(aCampos[06],",","."))
		End
		aDep := {}
		AADD(aDep, "|H001|0|")
		AADD(aDep, "|H005|"+GravaData(dDataInv,.F.,5)+"|"+AllTrim(Transform(nTotEst,"@ER 999999999.99"))+"|01|")
		For nIndex := 1 To Len(aH010GUA)
			AADD(aDep, aH010GUA[nIndex])
		Next
		AADD(aDep, "|H990|"+AllTrim(cValToChar(Len(aH010GUA)+2))+"|")
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
	FWrite(nHLog, "Tempo Gasto Processamento        : " + Elaptime(cHoraIni,cHoraFim) + CRLF)
	FWrite(nHLog, "Arquivo gerado                   : " + cArqDest + CRLF)
	FWrite(nHLog, "Total de Linhas (original)       : " + cValToChar(Len(aLinhas)) + CRLF)
	FWrite(nHLog, "Alteracoes Efetuadas             : " + cValToChar(nAlt) + CRLF)
	FWrite(nHLog, "Exclusoes Efetuadas              : " + cValToChar(nExc) + CRLF)
	FWrite(nHLog, "Linhas excluidas C190 (dupl)     : " + cValToChar(nDC190) + CRLF)
	FWrite(nHLog, "Linhas excluidas H010            : " + cValToChar(nDH010) + CRLF)
	FWrite(nHLog, "Total Alteracoes/Exclusoes       : " + cValToChar(nExc+nAlt) + CRLF)

	FClose(nHLog)

	FWAlertSuccess("Processamento finalizado!" + CRLF + CRLF + ;
		"Arquivo gerado : " + cArqDest + CRLF + CRLF + ;
		"Log criado     : " + cLogArq, "Processo Concluido")

Return (NIL)

/*/{Protheus.doc} C190_ProcessaDupl
Varre todas as linhas C190 e consolida duplicidades com base na chave CST+CFOP.
A logica agrupa por bloco C100: ao encontrar um novo C100, reinicia o hash do bloco.
Dentro de cada bloco, a primeira ocorrencia de cada chave CST+CFOP e mantida com a
soma acumulada de todos os valores. As demais ocorrencias sao marcadas para exclusao.
Apos consolidar, grava no LOG um somatorio por grupo CST+CFOP do bloco C.
@type function Processamento
@version 2.00
@author marioantonaccio
@since 07/04/2026
@param aLinhas,  array,   Array de linhas do arquivo (by reference)
@param nHLog,    numeric, Handle do arquivo de LOG
@param nAlt,     numeric, Contador de alteracoes (by reference)
@param nExc,     numeric, Contador de exclusoes (by reference)
@return numeric, quantidade de linhas C190 marcadas para exclusao
/*/
Static Function C190_ProcessaDupl(aLinhas, nHLog, nAlt, nExc)

	// Estrutura do hash: cada elemento = {cChave, nIdx_primeira_ocorrencia, nV1..nV7}
	Local aHash        := {} as array
	Local aCampos      := {} as array
	Local cLinhaNova   := "" as character
	Local cChave       := "" as character
	Local cCST         := "" as character
	Local nIndex       := 0  as numeric
	Local nPos         := 0  as numeric
	Local nDC190       := 0  as numeric
	Local nI           := 0  as numeric
	// Valores numericos dos campos C190
	Local nV1 := 0 as numeric
	Local nV2 := 0 as numeric
	Local nV3 := 0 as numeric
	Local nV4 := 0 as numeric
	Local nV5 := 0 as numeric
	Local nV6 := 0 as numeric
	Local nV7 := 0 as numeric

	FWrite(nHLog, "--- Inicio varredura de duplicidades C190 ---" + CRLF + CRLF)

	ProcRegua(Len(aLinhas))

	For nIndex := 1 To Len(aLinhas)
		IncProc()
		aCampos := StrTokArr(aLinhas[nIndex], "|")

		// Novo bloco de nota: reinicia o hash do bloco corrente
		If aCampos[1] == "C100"
			// Antes de reiniciar, grava somatorio do bloco anterior (se houver)
			If Len(aHash) > 0
				C190_GravaSomatorio(aHash, nHLog)
				aHash := {}
			End
		End

		// Processa registros C190 que nao foram deletados
		If aCampos[1] == "C190"

			// Normaliza CST para 3 digitos para efeito da chave
			cCST   := PadL(AllTrim(aCampos[2]), 3, "0")
			// Chave: 2 ultimas posicoes do CST + CFOP (consistente com a regra original)
//			cChave := Substr(cCST, 2, 2) + "|" + AllTrim(aCampos[3])
			cChave := cCST+ "|" + AllTrim(aCampos[3])

			nV1 := Val(StrTran(AllTrim(aCampos[05]),",","."))
			nV2 := Val(StrTran(AllTrim(aCampos[06]),",","."))
			nV3 := Val(StrTran(AllTrim(aCampos[07]),",","."))
			nV4 := Val(StrTran(AllTrim(aCampos[08]),",","."))
			nV5 := Val(StrTran(AllTrim(aCampos[09]),",","."))
			nV6 := Val(StrTran(AllTrim(aCampos[10]),",","."))
			nV7 := Val(StrTran(AllTrim(aCampos[11]),",","."))

			// Procura chave no hash do bloco
			nPos := 0
			For nI := 1 To Len(aHash)
				If aHash[nI][1] == cChave
					nPos := nI
					Exit
				End
			Next

			If nPos == 0
				// Primeira ocorrencia desta chave no bloco: registra no hash
				AADD(aHash, {cChave, nIndex, nV1, nV2, nV3, nV4, nV5, nV6, nV7})
			Else
				// Duplicidade encontrada: acumula valores na primeira ocorrencia
				aHash[nPos][3] += nV1
				aHash[nPos][4] += nV2
				aHash[nPos][5] += nV3
				aHash[nPos][6] += nV4
				aHash[nPos][7] += nV5
				aHash[nPos][8] += nV6
				aHash[nPos][9] += nV7

				// Atualiza a linha da primeira ocorrencia com os valores acumulados
				aCampos := StrTokArr(aLinhas[aHash[nPos][2]], "|")
				aCampos[05] := AllTrim(Transform(aHash[nPos][3],"@ER 999999999.99"))
				aCampos[06] := AllTrim(Transform(aHash[nPos][4],"@ER 999999999.99"))
				aCampos[07] := AllTrim(Transform(aHash[nPos][5],"@ER 999999999.99"))
				aCampos[08] := AllTrim(Transform(aHash[nPos][6],"@ER 999999999.99"))
				aCampos[09] := AllTrim(Transform(aHash[nPos][7],"@ER 999999999.99"))
				aCampos[10] := AllTrim(Transform(aHash[nPos][8],"@ER 999999999.99"))
				aCampos[11] := AllTrim(Transform(aHash[nPos][9],"@ER 999999999.99"))
				cLinhaNova  := RebuildLine(aCampos)
				aLinhas[aHash[nPos][2]] := cLinhaNova
				nAlt++

				FWrite(nHLog, "C190 CONSOLIDADO - Chave ["+cChave+"]" + CRLF)
				FWrite(nHLog, "  Linha ref    : " + Str(aHash[nPos][2],6) + CRLF)
				FWrite(nHLog, "  Linha dupl   : " + Str(nIndex,6)          + CRLF)
				FWrite(nHLog, "  Val acumul   : " + Transform(aHash[nPos][3],"@ER 999999999.99") + CRLF + CRLF)

				// Marca linha duplicada para exclusao
				aCampos    := StrTokArr(aLinhas[nIndex], "|")
				aCampos[1] := "C190__DELETE__"
				cLinhaNova := RebuildLine(aCampos)
				aLinhas[nIndex] := cLinhaNova
				nDC190++
				nExc++
			End
		End
	Next

	// Grava somatorio do ultimo bloco processado
	If Len(aHash) > 0
		C190_GravaSomatorio(aHash, nHLog)
	End

	FWrite(nHLog, "--- Fim varredura de duplicidades C190 - " + ;
		cValToChar(nDC190) + " linha(s) excluida(s) ---" + CRLF + CRLF)

Return (nDC190)

/*/{Protheus.doc} C190_GravaSomatorio
Grava no LOG o somatorio por grupo CST+CFOP do bloco C190 processado.
@type function Auxiliar
@version 2.00
@author marioantonaccio
@since 07/04/2026
@param aHash,  array,   Hash com os grupos do bloco atual
@param nHLog,  numeric, Handle do arquivo de LOG
@return Character, sem retorno
/*/
Static Function C190_GravaSomatorio(aHash, nHLog)

	Local nI       := 0  as numeric
	Local nTotVal  := 0  as numeric

	FWrite(nHLog, "--- SOMATORIO C190 POR GRUPO CST+CFOP ---" + CRLF)
	FWrite(nHLog, PadR("Chave CST+CFOP",20) + " | " + ;
		PadL("VL_BC_ICMS",14)   + " | " + ;
		PadL("VL_ICMS",14)      + " | " + ;
		PadL("VL_BC_ICMS_ST",14)+ " | " + ;
		PadL("VL_ICMS_ST",14)   + " | " + ;
		PadL("VL_RED_BC",14)    + " | " + ;
		PadL("VL_IPI",14)       + " | " + ;
		PadL("VL_PIS_COF",14)   + CRLF)
	FWrite(nHLog, Replicate("-", 135) + CRLF)

	nTotVal := 0
	For nI := 1 To Len(aHash)
		FWrite(nHLog, ;
			PadR(aHash[nI][1], 20) + " | " + ;
			PadL(Transform(aHash[nI][3],"@ER 999999999.99"), 14) + " | " + ;
			PadL(Transform(aHash[nI][4],"@ER 999999999.99"), 14) + " | " + ;
			PadL(Transform(aHash[nI][5],"@ER 999999999.99"), 14) + " | " + ;
			PadL(Transform(aHash[nI][6],"@ER 999999999.99"), 14) + " | " + ;
			PadL(Transform(aHash[nI][7],"@ER 999999999.99"), 14) + " | " + ;
			PadL(Transform(aHash[nI][8],"@ER 999999999.99"), 14) + " | " + ;
			PadL(Transform(aHash[nI][9],"@ER 999999999.99"), 14) + CRLF)
		nTotVal += aHash[nI][3]
	Next

	FWrite(nHLog, Replicate("-", 135) + CRLF)
	FWrite(nHLog, PadR("TOTAL GRUPOS: "+cValToChar(Len(aHash)),20) + " | " + ;
		PadL(Transform(nTotVal,"@ER 999999999.99"),14) + CRLF + CRLF)

Return (NIL)

/*/{Protheus.doc} RebuildLine
Reconstroi a linha a partir do array de campos.
@type function Auxiliar
@version 1.01
@author marioantonaccio
@since 25/03/2026
@param aCampos, array, Campos lidos na linha
@return character, linha reconstruida
/*/
Static Function RebuildLine(aCampos)

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
