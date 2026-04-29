#Include "Protheus.ch"
#Include "fileio.ch"
/*/{Protheus.doc} BRSPED_C17
Programa que analisa o arquivo SPED gerado, verifica produtos do bloco C170 contra o bloco 0200,
deleta linhas 0200 sem correspondência no C170 (produtos não movimentados) e gera log detalhado.
@type function Processamento
@version  1.00
@author marioantonaccio
@since 23/04/2026
@return character, sem retorno
/*/
User Function BRSPED_C17()

	Local cMsgIntro      := "" as character

	cMsgIntro := ;
		"Este programa executa:" + CRLF + ;
		" " + Chr(149) + " Leitura completa do arquivo TXT" + CRLF + ;
		" " + Chr(149) + " Extração de produtos movimentados do bloco C170" + CRLF + ;
		" " + Chr(149) + " Extração de produtos utilizados em 0220" + CRLF + ;
		" " + Chr(149) + " Verificação de produtos no bloco 0200" + CRLF + ;
		" " + Chr(149) + " Exclusão de linhas 0200 sem produto no C170" + CRLF + ;
		" " + Chr(149) + " Limpeza de codigo de barras duplicado em 0220" + CRLF + ;
		" " + Chr(149) + " Verificação de produtos C170 sem uso em 0220" + CRLF + ;
		" " + Chr(149) + " Geração de linhas 0200 para produtos C170 orphãos" + CRLF + ;
		" " + Chr(149) + " Ajuste de totalizadores" + CRLF + ;
		" " + Chr(149) + " Geração de LOG detalhado" + CRLF + CRLF + ;
		"Clique SIM para selecionar o arquivo."

	If .NOT. FWAlertNoYes(cMsgIntro, "Processador de Arquivos TXT / SPED - C170 vs 0200")
		Return (NIL)
	Else
		Processa({|| BRSPED_C17P()}, "Lendo arquivo....")
	EndIf

Return (NIL)

/*/{Protheus.doc} BRSPED_C17P
Inicia o processamento do arquivo txt para verificação C170 vs 0200
@type function Processamento
@version 1.00
@author marioantonaccio
@since 23/04/2026
@return character, sem retorno
/*/
Static Function BRSPED_C17P()

	Local aLinhas      := {}  as array
	Local aProdC170   := {}  as array  // Array de códigos de produtos movimentados no C170
	Local aProd0220   := {}  as array  // Array de códigos de produtos em 0220

	Local cArqDest     := " " as character
	Local cArqOrig     := " " as character
	Local cArqDelete   := " " as character
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

	Local nAlt         := 0   as numeric
	Local nDelete      := 0   as numeric
	Local nExc         := 0   as numeric
	Local nHandle      := 0   as numeric
	Local nHDelete     := 0   as numeric
	Local nHDest       := 0   as numeric
	Local nHLog        := 0   as numeric
	Local nIndex       := 0   as numeric
	Local nTot0205D   := 0   as numeric
	Local nTot0220D   := 0   as numeric
	Local nLimpC220   := 0   as numeric
	Local nProdSemU   := 0   as numeric
	Local nNovas0200  := 0   as numeric

	cDataHoraIni := DtoC(Date()) + " " + Time()
	cHoraIni     := Time()

	// SELEÇÃO DO ARQUIVO VIA CGETFILE()
	cArqOrig := cGetFile("Arquivos TXT (*.txt)|*.txt|", "Selecione o arquivo para processamento")

	If Empty(cArqOrig)
		FWAlertError("Nenhum arquivo selecionado.","Selecao de arquivo", NIL)
		Return (NIL)
	EndIf

	SplitPath(cArqOrig, @cDrive, @cDiretorio, @cNome, @cExtensao)
	cArqDest   := cDrive+cDiretorio+ChgFileExt(cNome,"_C1700200N.txt")
	cLogArq    := cDrive+cDiretorio+ChgFileExt(cNome, "_C1700200L.log")
	cArqDelete := cDrive+cDiretorio+ChgFileExt(cNome,"_C1700200D.txt")

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

	FWrite(nHLog, "LOG DO PROCESSAMENTO C170 vs 0200" + CRLF)
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
	// PASSO 1: Extração de produtos movimentados do bloco C170
	// ==========================================================
	FWrite(nHLog, "=== PASSO 1: EXTRACAO PRODUTOS BLOCO C170 ===" + CRLF + CRLF)
	ProcRegua(Len(aLinhas))

	aProdC170 := {}
	For nIndex := 1 To Len(aLinhas)
		IncProc()
		aCampos := StrTokArr(aLinhas[nIndex], "|")
		If aCampos[1] == "C170"
			cCodProd := Alltrim(Substr(aCampos[3],1,15))
			If !Empty(cCodProd) .AND. AScan(aProdC170, cCodProd) == 0
				AAdd(aProdC170, cCodProd)
				FWrite(nHLog, "Produto movimentado no C170: " + cCodProd + CRLF)
			EndIf
		EndIf
	Next

	FWrite(nHLog, "Total de produtos movimentados no bloco C170: " + cValToChar(Len(aProdC170)) + CRLF + CRLF)

	// ==========================================================
	// PASSO 1B: Extração de produtos no bloco 0220
	// ==========================================================
	FWrite(nHLog, "=== PASSO 1B: EXTRACAO PRODUTOS BLOCO 0220 ===" + CRLF + CRLF)
	ProcRegua(Len(aLinhas))

	aProd0220 := {}
	For nIndex := 1 To Len(aLinhas)
		IncProc()
		aCampos := StrTokArr(aLinhas[nIndex], "|")
		If aCampos[1] == "0220"
			cCodProd := Alltrim(Substr(aCampos[2],1,15))
			If !Empty(cCodProd) .AND. AScan(aProd0220, cCodProd) == 0
				AAdd(aProd0220, cCodProd)
				FWrite(nHLog, "Produto usado em 0220: " + cCodProd + CRLF)
			EndIf
		EndIf
	Next

	FWrite(nHLog, "Total de produtos em bloco 0220: " + cValToChar(Len(aProd0220)) + CRLF + CRLF)

	// ==========================================================
	// PASSO 2: Verificação e exclusão de linhas 0200 sem produto no C170
	// ==========================================================""
	FWrite(nHLog, "=== PASSO 2: VERIFICACAO 0200 vs C170 ===" + CRLF + CRLF)
	ProcRegua(Len(aLinhas))

	nTot0200D := 0
	nTot0205D := 0
	nTot0220D := 0
	For nIndex := 1 To Len(aLinhas)
		IncProc()
		If "0200" $ aLinhas[nIndex] .and. "010101" $ aLinhas[nIndex]
			aLinhas[nIndex] := StrTran(aLinhas[nIndex], "010101", "010108")
		End
		aCampos := StrTokArr(aLinhas[nIndex], "|")
		If aCampos[1] == "0200"
			cCodProd := Alltrim(Substr(aCampos[2],1,15))  // Campo 2 do 0200 é o código do produto
			If AScan(aProdC170, cCodProd) == 0
				// Produto não movimentado no C170: marcar para exclusão
				FWrite(nHLog, "EXCLUSAO 0200 - Produto nao movimentado no C170 - Linha " + Str(nIndex,6) + CRLF)
				FWrite(nHLog, "  Codigo Produto: " + cCodProd + CRLF + CRLF)
				aCampos[1] := "0200__DELETE__"
				cLinhaNova := Rebuild0200(aCampos)
				aLinhas[nIndex] := cLinhaNova
				nTot0200D++
				nExc++

				// Verificar se há 0205 subsequente
				If nIndex + 1 <= Len(aLinhas)
					aCamposNext := StrTokArr(aLinhas[nIndex + 1], "|")
					If aCamposNext[1] == "0205"
						FWrite(nHLog, "EXCLUSAO 0205 - Relacionado ao produto deletado - Linha " + Str(nIndex+1,6) + CRLF + CRLF)
						aCamposNext[1] := "0205__DELETE__"
						cLinhaNova := Rebuild0200(aCamposNext)
						aLinhas[nIndex + 1] := cLinhaNova
						nTot0205D++
						nExc++
						// Verificar se há 0220 após a 0205
						If nIndex + 2 <= Len(aLinhas)
							aCampos3 := StrTokArr(aLinhas[nIndex + 2], "|")
							If aCampos3[1] == "0220"
								FWrite(nHLog, "EXCLUSAO 0220 - Relacionado ao produto deletado - Linha " + Str(nIndex+2,6) + CRLF + CRLF)
								aCampos3[1] := "0220__DELETE__"
								cLinhaNova := Rebuild0200(aCampos3)
								aLinhas[nIndex + 2] := cLinhaNova
								nTot0220D++
								nExc++
							EndIf
						EndIf
					ElseIf aCamposNext[1] == "0220"
						// Sem 0205, mas há 0220
						FWrite(nHLog, "EXCLUSAO 0220 - Relacionado ao produto deletado - Linha " + Str(nIndex+1,6) + CRLF + CRLF)
						aCamposNext[1] := "0220__DELETE__"
						cLinhaNova := Rebuild0200(aCamposNext)
						aLinhas[nIndex + 1] := cLinhaNova
						nTot0220D++
						nExc++
					EndIf
				EndIf
			Else
				If nIndex + 1 <= Len(aLinhas)
					aCamposNext := StrTokArr(aLinhas[nIndex + 1], "|")
					If aCamposNext[1] == "0220"
						If Len(Alltrim(aCamposNext[4])) > 2
							cAntes := "|"+AllTrim(aCamposNext[04])+"|"
							cNew:=""
							FWrite(nHLog, "ALTERAÇÃO 0220 - Linha " + Str(nIndex,6)  + CRLF)
							FWrite(nHLog, "  ANTES : " + cAntes + CRLF)
							FWrite(nHLog, "  DEPOIS: " + cNew + CRLF + CRLF)
							nAlt++
							aCamposNext[4]:=cNew
							cLinhaNova :=   Rebuild0200(aCamposNext)
							aLinhas[nIndex+1] := cLinhaNova
						End
					End
				End
			EndIf
		EndIf
	Next

	FWrite(nHLog, "Total de linhas 0200 excluidas: " + cValToChar(nTot0200D) + CRLF)
	FWrite(nHLog, "Total de linhas 0205 excluidas: " + cValToChar(nTot0205D) + CRLF)
	FWrite(nHLog, "Total de linhas 0220 excluidas: " + cValToChar(nTot0220D) + CRLF)
	FWrite(nHLog, "Total de linhas 0220 com codigo de barras limpo: " + cValToChar(nLimpC220) + CRLF + CRLF)

	// ==========================================================
	// PASSO 2B: Verificação C170 x 0220 - produtos movimentados sem uso
	// ==========================================================
	FWrite(nHLog, "=== PASSO 2B: VERIFICACAO C170 x 0220 ===" + CRLF + CRLF)
	ProcRegua(Len(aProdC170))

	nProdSemU := 0
	For nIndex := 1 To Len(aProdC170)
		IncProc()
		If AScan(aProd0220, aProdC170[nIndex]) == 0
			FWrite(nHLog, "AVISO: Produto com movimento C170 mas sem uso em 0220: " + aProdC170[nIndex] + CRLF)
			nProdSemU++
		EndIf
	Next

	FWrite(nHLog, "Total de produtos movimentados sem uso em 0220: " + cValToChar(nProdSemU) + CRLF + CRLF)

	// ==========================================================
	// PASSO 2C: Geração de linhas 0200 para produtos C170 sem 0200
	// ==========================================================
	FWrite(nHLog, "=== PASSO 2C: GERACAO 0200 PARA PRODUTOS C170 ===" + CRLF + CRLF)

	nNovas0200 := 0
	For nIndex := 1 To Len(aProdC170)
		// Verifica se produto está em C170 mas NÃO em 0200
		If AScan(aProd0220, aProdC170[nIndex]) == 0
			// Procura todas as ocorrências do produto em C170
			nQtdC170 := 0
			nSomFator := 0
			cPrimeiraUn := ""
			For nCheck := 1 To Len(aLinhas)
				aCamposC := StrTokArr(aLinhas[nCheck], "|")
				If aCamposC[1] == "C170"
					If Alltrim(Substr(aCamposC[3],1,15)) == aProdC170[nIndex]
						nQtdC170++
						// Campo 5 do C170: fator de conversão
						If Len(aCamposC) >= 5 .AND. !Empty(AllTrim(aCamposC[5]))
							nSomFator += Val(StrTran(AllTrim(aCamposC[5]),",","."))
						EndIf
						// Coleta primeira unidade (campo 4 do C170)
						If Empty(cPrimeiraUn) .AND. Len(aCamposC) >= 4
							cPrimeiraUn := AllTrim(aCamposC[4])
						EndIf
					EndIf
				EndIf
			Next

			If nQtdC170 > 0
				// Gera linha 0200 com estrutura básica
				cNovaLinha := "|0200|" + aProdC170[nIndex] + "|PRODUTO AUTO GERADO|||||"
				AAdd(aLinhas, cNovaLinha)
				nNovas0200++
				FWrite(nHLog, "GERACAO 0200 - Produto: " + aProdC170[nIndex] + CRLF)
				FWrite(nHLog, "  Quantidade C170: " + cValToChar(nQtdC170) + CRLF)
				FWrite(nHLog, "  Linha gerada automaticamente" + CRLF + CRLF)
			EndIf
		EndIf
	Next

	FWrite(nHLog, "Total de linhas 0200 geradas: " + cValToChar(nNovas0200) + CRLF + CRLF)

	// ==========================================================
	// PASSO 3: Ajuste de totalizadores
	// ==========================================================""
	nDelete := 0
	For nIndex := 1 To Len(aLinhas)
		If "DELETE__" $ aLinhas[nIndex]
			nDelete++
		End
	Next

	If nDelete > 0
		FWrite(nHLog, "=== PASSO 3: ACERTO DE TOTALIZADORES ===" + CRLF + CRLF)
		For nIndex := 1 To Len(aLinhas)
			aCampos := StrTokArr2(aLinhas[nIndex], "|",.T.)

			// 0990 - Qtd linhas bloco 0
			If aCampos[1] == "0990"
				nQtd := Val(AllTrim(StrTran(aCampos[2],",","."))) - (nTot0200D + nTot0205D + nTot0220D) + nNovas0200
				FWrite(nHLog, "ALTERACAO 0990 - Linha " + Str(nIndex,6) + CRLF)
				FWrite(nHLog, "  Antes  : " + aCampos[2] + CRLF)
				FWrite(nHLog, "  Depois : " + cValToChar(nQtd) + CRLF + CRLF)
				nAlt++
				aCampos[2]      := AllTrim(Transform(nQtd,"@ER 999999999"))
				cLinhaNova      := Rebuild0200(aCampos)
				aLinhas[nIndex] := cLinhaNova
			End

			// 9900 - Qtd por tipo de registro
			If aCampos[1] == "9900"
				If aCampos[2] == "0200"
				nQtd := Val(AllTrim(StrTran(aCampos[3],",","."))) - nTot0200D + nNovas0200
					FWrite(nHLog, "ALTERACAO 9900-0200 - Linha " + Str(nIndex,6) + CRLF)
					FWrite(nHLog, "  Antes  : " + aCampos[3] + CRLF)
					FWrite(nHLog, "  Depois : " + cValToChar(nQtd) + CRLF + CRLF)
					nAlt++
					aCampos[3]      := AllTrim(Transform(nQtd,"@ER 999999999"))
					cLinhaNova      := Rebuild0200(aCampos)
					aLinhas[nIndex] := cLinhaNova
				EndIf
				If aCampos[2] == "0205"
					nQtd := Val(AllTrim(StrTran(aCampos[3],",","."))) - nTot0205D
					FWrite(nHLog, "ALTERACAO 9900-0205 - Linha " + Str(nIndex,6) + CRLF)
					FWrite(nHLog, "  Antes  : " + aCampos[3] + CRLF)
					FWrite(nHLog, "  Depois : " + cValToChar(nQtd) + CRLF + CRLF)
					nAlt++
					aCampos[3]      := AllTrim(Transform(nQtd,"@ER 999999999"))
					cLinhaNova      := Rebuild0200(aCampos)
					aLinhas[nIndex] := cLinhaNova			EndIf
			If aCampos[2] == "0220"
				nQtd := Val(AllTrim(StrTran(aCampos[3],",","."))) - nTot0220D
				FWrite(nHLog, "ALTERACAO 9900-0220 - Linha " + Str(nIndex,6) + CRLF)
				FWrite(nHLog, "  Antes  : " + aCampos[3] + CRLF)
				FWrite(nHLog, "  Depois : " + cValToChar(nQtd) + CRLF + CRLF)
				nAlt++
				aCampos[3]      := AllTrim(Transform(nQtd,"@ER 999999999"))
				cLinhaNova      := Rebuild0200(aCampos)
				aLinhas[nIndex] := cLinhaNova				EndIf
			End
			// 9999 - Total de linhas do arquivo
			If aCampos[1] == "9999"
				nQtd := Val(AllTrim(StrTran(aCampos[2],",","."))) - nDelete + nNovas0200
				FWrite(nHLog, "ALTERACAO 9999 - Linha " + Str(nIndex,6) + CRLF)
				FWrite(nHLog, "  Antes  : " + aCampos[2] + CRLF)
				FWrite(nHLog, "  Depois : " + cValToChar(nQtd) + CRLF + CRLF)
				nAlt++
				aCampos[2]      := AllTrim(Transform(nQtd,"@ER 999999999"))
				cLinhaNova      := Rebuild0200(aCampos)
				aLinhas[nIndex] := cLinhaNova
			End
		Next
	End
	// ==========================================================
	// PASSO 4: Gravação do arquivo final e arquivo de deletados
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
	FWrite(nHLog, "Linhas excluidas 0200            : " + cValToChar(nTot0200D) + CRLF)
	FWrite(nHLog, "Linhas excluidas 0205            : " + cValToChar(nTot0205D) + CRLF)
	FWrite(nHLog, "Linhas excluidas 0220            : " + cValToChar(nTot0220D) + CRLF)
	FWrite(nHLog, "Codigo barras limpo 0220         : " + cValToChar(nLimpC220) + CRLF)
	FWrite(nHLog, "Produtos C170 sem uso em 0220    : " + cValToChar(nProdSemU) + CRLF)
	FWrite(nHLog, "Linhas 0200 geradas              : " + cValToChar(nNovas0200) + CRLF)
	FWrite(nHLog, "Total Alteracoes/Exclusoes       : " + cValToChar(nExc+nAlt) + CRLF)

	FClose(nHLog)

	FWAlertSuccess("Processamento finalizado!" + CRLF + CRLF + ;
		"Arquivo gerado : " + cArqDest + CRLF + CRLF + ;
		"Log criado     : " + cLogArq, "Processo Concluido")

Return (NIL)

/*/{Protheus.doc} Rebuild0200
Reconstroi a linha a partir do array de campos para 0200.
@type function Auxiliar
@version 1.00
@author marioantonaccio
@since 23/04/2026
@param aCampos, array, Campos lidos na linha
@return character, linha reconstruida
/*/
Static Function Rebuild0200(aCampos)

	Local cLinhaR := "|" as character
	Local nI      := 0   as numeric
	//Local aNewCampo := {} as array
	// Garante número mínimo de campos para 0200 (10 campos obrigatórios)
	If  "0200" $ aCampos[1]

		cLinhaR :="|"+aCampos[1]  // 1
		cLinhaR +="|"+aCampos[2]  //2
		cLinhaR +="|"+aCampos[3]  //3
		cLinhaR +="|"+aCampos[4]  //6
		cLinhaR +="|"  //8
		cLinhaR +="|"+aCampos[5]  //7
		cLinhaR +="|"+aCampos[6]  //10
		cLinhaR +="|"+aCampos[7]  //10
		cLinhaR +="|"  //8
		cLinhaR +="|"+aCampos[8]  //11
		cLinhaR +="|"  //13
		cLinhaR +="|"+If(len(aCampos)>8,aCampos[9],"")  //12
		cLinhaR +="|"+If(len(aCampos)>9,aCampos[10],"")  //13
		cLinhaR +="|"  //13

	ELse

		For nI := 1 To Len(aCampos)
			cLinhaR += aCampos[nI]
			If nI < Len(aCampos)
				cLinhaR += "|"
			EndIf
		Next

		cLinhaR += "|"
	End
Return (cLinhaR)
