#Include "TOTVS.ch"


/*/{Protheus.doc} BRSPED_INT
Programa integrado de processamento de arquivo SPED EFD.
Executa em sequencia todas as correcoes e validacoes:
  1. Leitura do arquivo TXT via cGetFile
  2. Correcao de CST em C170 (2->3 digitos) + redistribuicao em C190
  3. Eliminacao de linhas C190 com CST de 2 posicoes (ja consolidadas)
  4. Comparacao C100 x C190 e verificacao no SF1/SF2 (Protheus)
  5. Ajuste de C190 divergente e geracao de linha corrigida
  6. Comparacao 0200 x 0220 (codigo de barras) - limpeza 0220
  7. Preenchimento de campo vazio em 0305 com "USO INTERNO"
  8. Desmembracao de inventario H010 por armazem (SB9)
  9. Correcao de todos os totalizadores de bloco e gerais
 10. Geracao de _NEW.txt, _DEL.txt e _LOG.txt
@type UserFunction
@version 3.00
@author marioantonaccio
@since 16/04/2026
@return NIL
/*/
User Function BRSPED_INT()

	Local cMsgIntro := "" as character

	cMsgIntro := ;
		"PROCESSADOR INTEGRADO DE SPED EFD" + CRLF + CRLF + ;
		"Este programa executa:" + CRLF + ;
		" " + Chr(149) + " Correcao de CST (C170/C190): 2 -> 3 digitos"   + CRLF + ;
		" " + Chr(149) + " Consolidacao de duplicidades C190"              + CRLF + ;
		" " + Chr(149) + " Verificacao C100 x Protheus (SF1/SF2)"         + CRLF + ;
		" " + Chr(149) + " Ajuste de divergencias C100 x C190"            + CRLF + ;
		" " + Chr(149) + " Limpeza de codigo de barras 0220"              + CRLF + ;
		" " + Chr(149) + " Preenchimento de 0305 vazio"                   + CRLF + ;
		" " + Chr(149) + " Desmembracao de inventario H010 por armazem"  + CRLF + ;
		" " + Chr(149) + " Correcao de totalizadores"                     + CRLF + ;
		" " + Chr(149) + " Geracao de _NEW, _DEL e _LOG"                 + CRLF + CRLF + ;
		"Clique SIM para selecionar o arquivo SPED."

	If .NOT. FWAlertNoYes(cMsgIntro, "Processador Integrado SPED EFD")
		Return (NIL)
	Else
		Processa({|| BRSINT01()}, "Processando SPED EFD...")
	EndIf

Return (NIL)

/*/{Protheus.doc} BRSINT01
Funcao principal: orquestra todas as etapas de processamento.
@type Static Function
@version 3.00
@author marioantonaccio
@since 16/04/2026
@return NIL
/*/
Static Function BRSINT01()

	// --- Arrays ---
	Local aLinhas    := {} as array
	Local aCampos    := {} as array
	Local aH010ARA   := {} as array
	Local aH010GUA   := {} as array
	Local aArmazem   := {} as array
	Local aDep       := {} as array

	// --- Strings ---
	Local cArqOrig   := " " as character
	Local cArqDest   := " " as character
	Local cArqDel    := " " as character
	Local cArqHARA   := " " as character
	Local cArqHGUA   := " " as character
	Local cLogArq    := " " as character
	Local cDrive     := " " as character
	Local cDir       := " " as character
	Local cNome      := " " as character
	Local cExt       := " " as character
	Local cLinha     := " " as character
	Local cLinhaNova := " " as character
	Local cAntes     := " " as character
	Local cNew       := " " as character
	Local cCFO       := " " as character
	Local cLocal     := " " as character
	Local cHoraIni   := " " as character
	Local cHoraFim   := " " as character
	Local cDtHrIni   := " " as character
	Local cDtHrFim   := " " as character

	// --- Datas ---
	Local dDataInv         as Date

	// --- Numericos ---
	Local nHandle    := 0  as numeric
	Local nHLog      := 0  as numeric
	Local nHDest     := 0  as numeric
	Local nHDel      := 0  as numeric
	Local nHARA      := 0  as numeric
	Local nHGUA      := 0  as numeric
	Local nIndex     := 0  as numeric
	Local nAlt       := 0  as numeric
	Local nExc       := 0  as numeric
	Local nDC190     := 0  as numeric
	Local nDH010     := 0  as numeric
	Local nDVH010    := 0  as numeric
	Local nDelete    := 0  as numeric
	Local nQtd       := 0  as numeric
	Local nValor     := 0  as numeric
	Local nTotEst    := 0  as numeric
	Local nLocal     := 0  as numeric

	// --- Logicos ---
	Local lAlterou   := .F. as logical

	cDtHrIni := DtoC(Date()) + " " + Time()
	cHoraIni := Time()

	// =========================================================
	// 1. SELECAO DO ARQUIVO
	// =========================================================
	cArqOrig := cGetFile("Arquivos TXT (*.txt)|*.txt|", "Selecione o arquivo SPED EFD")
	If Empty(cArqOrig)
		FWAlertError("Nenhum arquivo selecionado.", "Selecao de arquivo", NIL)
		Return (NIL)
	EndIf

	SplitPath(cArqOrig, @cDrive, @cDir, @cNome, @cExt)
	cArqDest := cDrive + cDir + cNome + "_NEW.txt"
	cArqDel  := cDrive + cDir + cNome + "_DEL.txt"
	cLogArq  := cDrive + cDir + cNome + "_LOG.txt"
	cArqHARA := cDrive + cDir + cNome + "_ARA.txt"
	cArqHGUA := cDrive + cDir + cNome + "_GUA.txt"

	// Remove arquivos anteriores
	BRSINT_Del(cArqDest)
	BRSINT_Del(cArqDel)
	BRSINT_Del(cLogArq)
	BRSINT_Del(cArqHARA)
	BRSINT_Del(cArqHGUA)

	// =========================================================
	// 2. CRIA LOG
	// =========================================================
	nHLog := FCreate(cLogArq)
	If nHLog < 0
		FWAlertError("Erro ao criar o arquivo de LOG.", "Erro", NIL)
		Return (NIL)
	EndIf

	FWrite(nHLog, Replicate("=", 80) + CRLF)
	FWrite(nHLog, "  LOG INTEGRADO DE PROCESSAMENTO SPED EFD" + CRLF)
	FWrite(nHLog, Replicate("=", 80) + CRLF)
	FWrite(nHLog, "Arquivo origem  : " + cArqOrig  + CRLF)
	FWrite(nHLog, "Arquivo gerado  : " + cArqDest  + CRLF)
	FWrite(nHLog, "Arquivo deletes : " + cArqDel   + CRLF)
	FWrite(nHLog, "Arquivo log     : " + cLogArq   + CRLF)
	FWrite(nHLog, "Inicio          : " + cDtHrIni  + CRLF)
	FWrite(nHLog, Replicate("-", 80) + CRLF + CRLF)

	// =========================================================
	// 3. LEITURA DO ARQUIVO SPED
	// =========================================================
	If .NOT. File(cArqOrig)
		FWAlertError("Arquivo nao encontrado.", "Erro", NIL)
		FClose(nHLog)
		Return (NIL)
	EndIf

	FWMsgRun(, {|| nHandle := FT_FUse(cArqOrig)}, "Processando", "Aguarde... lendo arquivo...")
	If nHandle == -1
		FWAlertError("Erro na abertura do arquivo.", "Erro na abertura", NIL)
		FClose(nHLog)
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

	FWrite(nHLog, "Total de linhas lidas: " + cValToChar(Len(aLinhas)) + CRLF + CRLF)

	// =========================================================
	// PASSO 1: Ajustes simples - C170, 0220, 0305
	// =========================================================
	FWrite(nHLog, Replicate("=", 80) + CRLF)
	FWrite(nHLog, "  PASSO 1: AJUSTES DE CAMPOS (C170 / 0220 / 0305)" + CRLF)
	FWrite(nHLog, Replicate("=", 80) + CRLF + CRLF)

	ProcRegua(Len(aLinhas))
	For nIndex := 1 To Len(aLinhas)
		IncProc()
		aCampos    := StrTokArr(aLinhas[nIndex], "|")
		cLinhaNova := ""
		lAlterou   := .F.

		// --- C170: corrige CST de 2 para 3 digitos ---
		If aCampos[1] == "C170"
			If Len(aCampos) >= 10
				If Len(AllTrim(aCampos[10])) == 2
					cCFO       := If(Len(aCampos) >= 11, aCampos[11], "")
					cAntes     := AllTrim(aCampos[10])
					cNew       := "0" + cAntes
					aCampos[10]:= cNew
					FWrite(nHLog, "C170 CST CORRIGIDO - Linha " + Str(nIndex, 6) + CRLF)
					FWrite(nHLog, "  ANTES : |" + cAntes + "|" + cCFO + "|" + CRLF)
					FWrite(nHLog, "  DEPOIS: |" + cNew   + "|" + cCFO + "|" + CRLF + CRLF)
					nAlt++
					cAntes     := "|" + cAntes + "|" + cCFO + "|"
					cNew       := "|" + cNew   + "|" + cCFO + "|"
					cLinhaNova := StrTran(aLinhas[nIndex], cAntes, cNew, 1, 1)
					aLinhas[nIndex] := cLinhaNova
					lAlterou   := .T.
				EndIf
			EndIf
		EndIf

		// --- 0220: limpa campo de codigo de barras quando coincide com 0200 ---
		If aCampos[1] == "0220"
			lAlterou := BRSINT0220(@aLinhas, nIndex, @aCampos, nHLog, @nAlt)
		EndIf

		// --- 0305: preenche campo 3 vazio com "USO INTERNO" ---
		If aCampos[1] == "0305"
			If Len(aCampos) >= 3
				If Empty(AllTrim(aCampos[3]))
					cAntes     := AllTrim(aCampos[3])
					cNew       := "USO INTERNO"
					aCampos[3] := cNew
					FWrite(nHLog, "0305 DESCRICAO PREENCHIDA - Linha " + Str(nIndex, 6) + CRLF)
					FWrite(nHLog, "  ANTES : [" + cAntes + "]" + CRLF)
					FWrite(nHLog, "  DEPOIS: [" + cNew   + "]" + CRLF + CRLF)
					nAlt++
					cLinhaNova := BRSINT_Reb(aCampos)
					aLinhas[nIndex] := cLinhaNova
				EndIf
			EndIf
		EndIf

	Next nIndex

	// =========================================================
	// PASSO 2: Consolidacao de duplicidades C190 por bloco C100
	// =========================================================
	FWrite(nHLog, Replicate("=", 80) + CRLF)
	FWrite(nHLog, "  PASSO 2: CONSOLIDACAO DE DUPLICIDADES C190" + CRLF)
	FWrite(nHLog, Replicate("=", 80) + CRLF + CRLF)

	nDC190 := BRSINT190D(@aLinhas, nHLog, @nAlt, @nExc)

	// =========================================================
	// PASSO 3: Correcao de CST 2 digitos nos C190 remanescentes
	// =========================================================
	FWrite(nHLog, Replicate("=", 80) + CRLF)
	FWrite(nHLog, "  PASSO 3: AJUSTE CST C190 (2 -> 3 DIGITOS)" + CRLF)
	FWrite(nHLog, Replicate("=", 80) + CRLF + CRLF)

	ProcRegua(Len(aLinhas))
	For nIndex := 1 To Len(aLinhas)
		IncProc()
		aCampos := StrTokArr(aLinhas[nIndex], "|")
		If aCampos[1] == "C190"
			If Len(aCampos) >= 2
				If Len(AllTrim(aCampos[2])) == 2
					cCFO       := If(Len(aCampos) >= 3, aCampos[3], "")
					cAntes     := AllTrim(aCampos[2])
					cNew       := "0" + cAntes
					aCampos[2] := cNew
					FWrite(nHLog, "C190 CST CORRIGIDO - Linha " + Str(nIndex, 6) + CRLF)
					FWrite(nHLog, "  ANTES : |" + cAntes + "|" + cCFO + "|" + CRLF)
					FWrite(nHLog, "  DEPOIS: |" + cNew   + "|" + cCFO + "|" + CRLF + CRLF)
					nAlt++
					cAntes := "|" + cAntes + "|" + cCFO + "|"
					cNew   := "|" + cNew   + "|" + cCFO + "|"
					aLinhas[nIndex] := StrTran(aLinhas[nIndex], cAntes, cNew, 1, 1)
				EndIf
			EndIf
		EndIf
	Next nIndex

	// =========================================================
	// PASSO 4: Verificacao C100 x Protheus (SF1/SF2) e C190
	// =========================================================
	FWrite(nHLog, Replicate("=", 80) + CRLF)
	FWrite(nHLog, "  PASSO 4: VERIFICACAO C100 x PROTHEUS e C190" + CRLF)
	FWrite(nHLog, Replicate("=", 80) + CRLF + CRLF)

	BRSINT100V(@aLinhas, nHLog, @nAlt, @nExc)

	// =========================================================
	// PASSO 5: Desmembracao H010 por armazem (SB9)
	// =========================================================
	FWrite(nHLog, Replicate("=", 80) + CRLF)
	FWrite(nHLog, "  PASSO 5: DESMEMBRACAO H010 POR ARMAZEM" + CRLF)
	FWrite(nHLog, Replicate("=", 80) + CRLF + CRLF)

	nDH010  := 0
	nDVH010 := 0
	cLocal  := ""
	aArmazem := {}
	dDataInv := CtoD("")

	ProcRegua(Len(aLinhas))
	For nIndex := 1 To Len(aLinhas)
		IncProc()
		aCampos    := StrTokArr(aLinhas[nIndex], "|")
		cLinhaNova := ""

		// Captura data de inventario do H005
		If aCampos[1] == "H005"
			If Len(aCampos) >= 2
				dDataInv := CTOD(Substr(aCampos[2], 1, 2) + "/" + ;
				                 Substr(aCampos[2], 3, 2) + "/" + ;
				                 Substr(aCampos[2], 5, 4))
			EndIf
		EndIf

		// Define armazens conforme nome do estabelecimento
		If aCampos[1] == "0005"
			If Len(aCampos) >= 2
				aArmazem := {}
				cLocal   := ""
				If "BRASILUX DEPOSITO ARARAQUARA" $ Upper(AllTrim(aCampos[2]))
					aArmazem := {"AF", "A3"}
					cLocal   := "ARA"
				ElseIf "DEPOSITO" $ Upper(AllTrim(aCampos[2]))
					aArmazem := {"G1", "G3"}
					cLocal   := "GUA"
				ElseIf "MATRIZ" $ Upper(AllTrim(aCampos[2]))
					aArmazem := {"G1", "G3", "AF", "A3"}
					cLocal   := "MAT"
				EndIf
				FWrite(nHLog, "0005 LOCAL=[" + AllTrim(aCampos[2]) + "] => cLocal=[" + cLocal + "]" + CRLF)
			EndIf
		EndIf

		// Processa H010 - abate por armazem
		If aCampos[1] == "H010" .AND. Len(aCampos) >= 6 .AND. Len(aArmazem) > 0
			nQtd   := Val(StrTran(AllTrim(aCampos[4]), ",", "."))
			nValor := Val(StrTran(AllTrim(aCampos[6]), ",", "."))

			For nLocal := 1 To Len(aArmazem)
				SB9->(dbSetOrder(1))
				If cLocal == "MAT"
					// Para MATRIZ: desconta o que existe nos outros armazens
					If SB9->(dbSeek(xFilial("SB9") + Substr(aCampos[2], 1, 15) + aArmazem[nLocal] + DTOS(dDataInv)))
						nQtd   -= SB9->B9_QINI
						nValor -= SB9->B9_VINI1
						If aArmazem[nLocal] == "AF" .OR. aArmazem[nLocal] == "A3"
							AAdd(aH010ARA, aLinhas[nIndex])
						ElseIf aArmazem[nLocal] == "G1" .OR. aArmazem[nLocal] == "G3"
							AAdd(aH010GUA, aLinhas[nIndex])
						EndIf
					EndIf
				Else
					// Para ARA/GUA: pega o saldo do armazem encontrado
					If SB9->(dbSeek(xFilial("SB9") + Substr(aCampos[2], 1, 15) + aArmazem[nLocal] + DTOS(dDataInv)))
						nQtd   -= SB9->B9_QINI
						nValor -= SB9->B9_VINI1
					EndIf
				EndIf
			Next nLocal

			If nQtd <= 0
				// Linha zerada: marcar para exclusao
				nDH010  += 1
				nDVH010 += Val(StrTran(AllTrim(aCampos[6]), ",", "."))
				FWrite(nHLog, "H010 EXCLUIDO (zerado) - Linha " + Str(nIndex, 6) + CRLF)
				FWrite(nHLog, "  Produto: " + AllTrim(aCampos[2]) + ;
				              " | Qtd orig: " + AllTrim(aCampos[4]) + CRLF + CRLF)
				aLinhas[nIndex] := StrTran(aLinhas[nIndex], "|H010|", "|H010__DELETE__|", 1, 1)
				nExc++
			Else
				// Linha com saldo: atualiza se houve mudanca
				If Val(StrTran(AllTrim(aCampos[4]), ",", ".")) <> nQtd .OR. ;
				   Val(StrTran(AllTrim(aCampos[6]), ",", ".")) <> nValor
					nDVH010 += Val(StrTran(AllTrim(aCampos[6]), ",", ".")) - nValor
					FWrite(nHLog, "H010 ALTERADO - Linha " + Str(nIndex, 6) + CRLF)
					FWrite(nHLog, "  ANTES  QTD: " + aCampos[4] + " | VAL: " + aCampos[6] + CRLF)
					FWrite(nHLog, "  DEPOIS QTD: " + Transform(nQtd,   "@ER 999999999.999") + ;
					              " | VAL: " + Transform(nValor, "@ER 999999999.99") + CRLF + CRLF)
					nAlt++
					aCampos[4]     := AllTrim(Transform(nQtd,   "@ER 999999999.999"))
					aCampos[6]     := AllTrim(Transform(nValor, "@ER 999999999.99"))
					aLinhas[nIndex] := BRSINT_Reb(aCampos)
				EndIf
			EndIf
		EndIf
	Next nIndex

	// =========================================================
	// PASSO 6: Acerto de totalizadores
	// =========================================================
	nDelete := 0
	For nIndex := 1 To Len(aLinhas)
		If "DELETE__" $ aLinhas[nIndex]
			nDelete++
		EndIf
	Next nIndex

	If nDelete > 0 .OR. nAlt > 0
		FWrite(nHLog, Replicate("=", 80) + CRLF)
		FWrite(nHLog, "  PASSO 6: ACERTO DE TOTALIZADORES" + CRLF)
		FWrite(nHLog, Replicate("=", 80) + CRLF + CRLF)
		BRSINT_Tot(@aLinhas, nHLog, @nAlt, nDC190, nDH010, nDVH010, nDelete)
	EndIf

	// =========================================================
	// PASSO 7: Gravacao dos arquivos de saida
	// =========================================================
	FWrite(nHLog, Replicate("=", 80) + CRLF)
	FWrite(nHLog, "  PASSO 7: GRAVACAO DOS ARQUIVOS" + CRLF)
	FWrite(nHLog, Replicate("=", 80) + CRLF + CRLF)

	nHDest := FCreate(cArqDest)
	If nHDest < 0
		FWAlertError("Erro ao criar arquivo destino: " + cArqDest, "Erro")
		FClose(nHLog)
		Return (NIL)
	EndIf

	nHDel := FCreate(cArqDel)
	If nHDel < 0
		FWAlertError("Erro ao criar arquivo de deletes: " + cArqDel, "Erro")
		FClose(nHDest)
		FClose(nHLog)
		Return (NIL)
	EndIf

	ProcRegua(Len(aLinhas))
	For nIndex := 1 To Len(aLinhas)
		IncProc()
		If .NOT. ("DELETE__" $ aLinhas[nIndex])
			FWrite(nHDest, aLinhas[nIndex] + CRLF)
		Else
			FWrite(nHDel, "Linha " + cValToChar(nIndex) + " - " + aLinhas[nIndex] + CRLF)
		EndIf
	Next nIndex
	FClose(nHDest)
	FClose(nHDel)

	// =========================================================
	// PASSO 8: Arquivos de deposito ARA/GUA
	// =========================================================
	If Len(aH010ARA) > 0
		nHARA := FCreate(cArqHARA)
		If nHARA >= 0
			nTotEst := 0
			For nIndex := 1 To Len(aH010ARA)
				aCampos  := StrTokArr(aH010ARA[nIndex], "|")
				nTotEst  += Val(StrTran(AllTrim(aCampos[6]), ",", "."))
			Next nIndex
			aDep := {}
			AAdd(aDep, "|H001|0|")
			AAdd(aDep, "|H005|" + DTOS(dDataInv) + "|" + AllTrim(Transform(nTotEst, "@ER 999999999.99")) + "|01|")
			For nIndex := 1 To Len(aH010ARA)
				AAdd(aDep, aH010ARA[nIndex])
			Next nIndex
			AAdd(aDep, "|H990|" + AllTrim(cValToChar(Len(aH010ARA) + 2)) + "|")
			For nIndex := 1 To Len(aDep)
				FWrite(nHARA, aDep[nIndex] + CRLF)
			Next nIndex
			FClose(nHARA)
			FWrite(nHLog, "Arquivo ARA gerado: " + cArqHARA + " (" + cValToChar(Len(aH010ARA)) + " itens)" + CRLF)
		EndIf
	EndIf

	If Len(aH010GUA) > 0
		nHGUA := FCreate(cArqHGUA)
		If nHGUA >= 0
			nTotEst := 0
			For nIndex := 1 To Len(aH010GUA)
				aCampos  := StrTokArr(aH010GUA[nIndex], "|")
				nTotEst  += Val(StrTran(AllTrim(aCampos[6]), ",", "."))
			Next nIndex
			aDep := {}
			AAdd(aDep, "|H001|0|")
			AAdd(aDep, "|H005|" + DTOS(dDataInv) + "|" + AllTrim(Transform(nTotEst, "@ER 999999999.99")) + "|01|")
			For nIndex := 1 To Len(aH010GUA)
				AAdd(aDep, aH010GUA[nIndex])
			Next nIndex
			AAdd(aDep, "|H990|" + AllTrim(cValToChar(Len(aH010GUA) + 2)) + "|")
			For nIndex := 1 To Len(aDep)
				FWrite(nHGUA, aDep[nIndex] + CRLF)
			Next nIndex
			FClose(nHGUA)
			FWrite(nHLog, "Arquivo GUA gerado: " + cArqHGUA + " (" + cValToChar(Len(aH010GUA)) + " itens)" + CRLF)
		EndIf
	EndIf

	// =========================================================
	// FECHAMENTO DO LOG - RESUMO FINAL
	// =========================================================
	cDtHrFim := DtoC(Date()) + " " + Time()
	cHoraFim := Time()

	FWrite(nHLog, CRLF + Replicate("=", 80) + CRLF)
	FWrite(nHLog, "  RESUMO FINAL DO PROCESSAMENTO" + CRLF)
	FWrite(nHLog, Replicate("=", 80) + CRLF)
	FWrite(nHLog, "Total de linhas (original)       : " + cValToChar(Len(aLinhas))  + CRLF)
	FWrite(nHLog, "Alteracoes efetuadas             : " + cValToChar(nAlt)           + CRLF)
	FWrite(nHLog, "Exclusoes efetuadas (total)      : " + cValToChar(nExc)           + CRLF)
	FWrite(nHLog, "  C190 excluidos (dupl/CST)      : " + cValToChar(nDC190)         + CRLF)
	FWrite(nHLog, "  H010 excluidos (zerados)       : " + cValToChar(nDH010)         + CRLF)
	FWrite(nHLog, "Total alteracoes + exclusoes     : " + cValToChar(nAlt + nExc)    + CRLF)
	FWrite(nHLog, Replicate("-", 80) + CRLF)
	FWrite(nHLog, "Arquivo gerado (_NEW)            : " + cArqDest  + CRLF)
	FWrite(nHLog, "Arquivo de deletes (_DEL)        : " + cArqDel   + CRLF)
	FWrite(nHLog, "Arquivo de log (_LOG)            : " + cLogArq   + CRLF)
	FWrite(nHLog, Replicate("-", 80) + CRLF)
	FWrite(nHLog, "Inicio do processamento          : " + cDtHrIni  + CRLF)
	FWrite(nHLog, "Fim do processamento             : " + cDtHrFim  + CRLF)
	FWrite(nHLog, "Tempo total                      : " + ElapTime(cHoraIni, cHoraFim) + CRLF)
	FWrite(nHLog, Replicate("=", 80) + CRLF)
	FClose(nHLog)

	FWAlertSuccess( ;
		"Processamento finalizado!" + CRLF + CRLF + ;
		"Linhas originais    : " + cValToChar(Len(aLinhas)) + CRLF + ;
		"Alteracoes          : " + cValToChar(nAlt)         + CRLF + ;
		"Exclusoes           : " + cValToChar(nExc)         + CRLF + CRLF + ;
		"Arquivo gerado : " + cArqDest + CRLF + ;
		"Log criado     : " + cLogArq, ;
		"Processo Concluido" ;
	)

Return (NIL)

/*/{Protheus.doc} BRSINT100V
Verifica cada bloco C100+C190:
  - Para NF de Entrada: busca pela CHV_NFE no SF1 e compara F1_TOTAL com VL_DOC
  - Para NF de Saida  : busca pela CHV_NFE no SF2 e compara F2_VALBRUT com VL_DOC
  - Compara a soma dos C190 com o VL_DOC do C100
  - Se houver divergencia C100xC190: redistribui o VL_DOC proporcional entre C190
@type Static Function
@version 3.00
@author marioantonaccio
@since 16/04/2026
@param aLinhas, array,   Array de linhas (by reference)
@param nHLog,   numeric, Handle do LOG
@param nAlt,    numeric, Contador de alteracoes (by reference)
@param nExc,    numeric, Contador de exclusoes (by reference)
@return NIL
/*/
Static Function BRSINT100V(aLinhas, nHLog, nAlt, nExc)

	Local aCampos     := {} as array
	Local aC190Bloco  := {} as array
	Local aCamposC190 := {} as array
	Local cIndOper    := " " as character
	Local cChvNFe     := " " as character
	Local cNumDoc     := " " as character
	Local cSerDoc     := " " as character
	Local cCnpjPart   := " " as character
	Local cDtDoc      := " " as character
	Local cCfop       := " " as character
	Local cLinhaNova  := " " as character
	Local nVlDoc      := 0   as numeric
	Local nSomaOpr    := 0   as numeric
	Local nLinC100    := 0   as numeric
	Local nDiferenca  := 0   as numeric
	Local nVlProt     := 0   as numeric
	Local nVlOprOrig  := 0   as numeric
	Local nNovoVlOpr  := 0   as numeric
	Local nPeso       := 0   as numeric
	Local nAcum       := 0   as numeric
	Local nTotDiverg  := 0   as numeric
	Local nTotOk      := 0   as numeric
	Local nTotCorrig  := 0   as numeric
	Local nIndex      := 0   as numeric
	Local nI          := 0   as numeric
	Local nJ          := 0   as numeric
	Local lDentroC100 := .F. as logical
	Local lAchouSF    := .F. as logical
	Local nTolerancia := 0.02 as numeric

	FWrite(nHLog, "--- Inicio verificacao C100 x Protheus e C190 ---" + CRLF + CRLF)
	ProcRegua(Len(aLinhas))

	For nIndex := 1 To Len(aLinhas)
		IncProc()
		If Len(aLinhas[nIndex]) < 3
			Loop
		EndIf
		aCampos := StrTokArr(aLinhas[nIndex], "|")
		If Len(aCampos) < 2
			Loop
		EndIf

		// ---- C100: inicio de bloco ----
		If AllTrim(aCampos[1]) == "C100"

			// Fecha bloco anterior
			If lDentroC100 .AND. Len(aC190Bloco) > 0
				BRSINT_C19( ;
					nHLog, @aLinhas, @aC190Bloco, ;
					cNumDoc, cSerDoc, cCnpjPart, cChvNFe, cDtDoc, cIndOper, ;
					nVlDoc, nSomaOpr, nLinC100, ;
					@nTotDiverg, @nTotOk, @nTotCorrig, @nAlt, nTolerancia ;
				)
			EndIf

			// Inicia novo bloco
			lDentroC100 := .T.
			nLinC100    := nIndex
			nSomaOpr    := 0
			aC190Bloco  := {}

			cIndOper  := If(Len(aCampos) >= 2,  AllTrim(aCampos[2]),  "")
			cCnpjPart := If(Len(aCampos) >= 4,  AllTrim(aCampos[4]),  "")
			cSerDoc   := If(Len(aCampos) >= 7,  AllTrim(aCampos[7]),  "")
			cNumDoc   := If(Len(aCampos) >= 8,  AllTrim(aCampos[8]),  "")
			cChvNFe   := If(Len(aCampos) >= 9,  AllTrim(aCampos[9]),  "")
			cDtDoc    := If(Len(aCampos) >= 10, AllTrim(aCampos[10]), "")
			nVlDoc    := If(Len(aCampos) >= 12, Val(StrTran(AllTrim(aCampos[12]), ",", ".")), 0)

			// Verifica no Protheus (SF1=Entrada, SF2=Saida)
			lAchouSF := .F.
			nVlProt  := 0

			If cIndOper == "0"
				// NF de Entrada: SF1 por chave NFE (order 8)
				SF1->(dbSetOrder(8))
				If SF1->(dbSeek(xFilial("SF1") + cChvNFe))
					lAchouSF := .T.
					nVlProt  := SF1->F1_TOTAL
				EndIf
			Else
				// NF de Saida: SF2 por chave NFE (order 8)
				SF2->(dbSetOrder(8))
				If SF2->(dbSeek(xFilial("SF2") + cChvNFe))
					lAchouSF := .T.
					nVlProt  := SF2->F2_VALBRUT
				EndIf
			EndIf

			If lAchouSF
				If Abs(nVlProt - nVlDoc) > nTolerancia
					FWrite(nHLog, "DIVERGENCIA C100 x Protheus - Linha " + Str(nIndex, 6) + CRLF)
					FWrite(nHLog, "  Operacao   : " + If(cIndOper == "0", "ENTRADA (SF1)", "SAIDA (SF2)") + CRLF)
					FWrite(nHLog, "  Doc        : " + cNumDoc + "/" + cSerDoc + CRLF)
					FWrite(nHLog, "  Chave NFE  : " + cChvNFe + CRLF)
					FWrite(nHLog, "  VL_DOC SPED: " + Transform(nVlDoc,  "@E 999,999,999.99") + CRLF)
					FWrite(nHLog, "  VL Protheus: " + Transform(nVlProt, "@E 999,999,999.99") + CRLF)
					FWrite(nHLog, "  Diferenca  : " + Transform(Abs(nVlDoc - nVlProt), "@E 999,999,999.99") + CRLF + CRLF)
					// Usa o valor Protheus como referencia
					nVlDoc := nVlProt
					// Atualiza VL_DOC na linha do C100 (campo 12)
					If Len(aCampos) >= 12
						aCampos[12] := AllTrim(StrTran(Transform(nVlProt, "@E 999999999.99"), ".", ","))
						aLinhas[nIndex] := BRSINT_Reb(aCampos)
						nAlt++
					EndIf
				Else
					FWrite(nHLog, "C100 OK - Linha " + Str(nIndex, 6) + ;
					              " | Doc: " + cNumDoc + "/" + cSerDoc + ;
					              " | VL_DOC: " + Transform(nVlDoc, "@E 999,999,999.99") + CRLF)
				EndIf
			Else
				FWrite(nHLog, "C100 NAO ENCONTRADO EM SF1/SF2 - Linha " + Str(nIndex, 6) + ;
				              " | Chave: " + cChvNFe + CRLF + CRLF)
			EndIf

		// ---- C190 dentro de um bloco C100 ----
		ElseIf AllTrim(aCampos[1]) == "C190" .AND. lDentroC100
			If .NOT. ("DELETE__" $ aLinhas[nIndex])
				nSomaOpr += If(Len(aCampos) >= 5, Val(StrTran(AllTrim(aCampos[5]), ",", ".")), 0)
				AAdd(aC190Bloco, {nIndex, If(Len(aCampos) >= 5, Val(StrTran(AllTrim(aCampos[5]), ",", ".")), 0)})
			EndIf

		// ---- Registro de encerramento de bloco ----
		ElseIf AllTrim(aCampos[1]) $ "C200|C990|D001|D100|D990|E001|E990|0990|9001|9900|9990|9999"
			If lDentroC100 .AND. Len(aC190Bloco) > 0
				BRSINT_C19( ;
					nHLog, @aLinhas, @aC190Bloco, ;
					cNumDoc, cSerDoc, cCnpjPart, cChvNFe, cDtDoc, cIndOper, ;
					nVlDoc, nSomaOpr, nLinC100, ;
					@nTotDiverg, @nTotOk, @nTotCorrig, @nAlt, nTolerancia ;
				)
				lDentroC100 := .F.
				aC190Bloco  := {}
			EndIf
		EndIf
	Next nIndex

	// Fecha ultimo bloco
	If lDentroC100 .AND. Len(aC190Bloco) > 0
		BRSINT_C19( ;
			nHLog, @aLinhas, @aC190Bloco, ;
			cNumDoc, cSerDoc, cCnpjPart, cChvNFe, cDtDoc, cIndOper, ;
			nVlDoc, nSomaOpr, nLinC100, ;
			@nTotDiverg, @nTotOk, @nTotCorrig, @nAlt, nTolerancia ;
		)
	EndIf

	FWrite(nHLog, "--- Fim verificacao C100 ---" + CRLF)
	FWrite(nHLog, "  Blocos com divergencia : " + cValToChar(nTotDiverg) + CRLF)
	FWrite(nHLog, "  Blocos OK              : " + cValToChar(nTotOk)     + CRLF)
	FWrite(nHLog, "  Linhas C190 corrigidas : " + cValToChar(nTotCorrig) + CRLF + CRLF)

Return (NIL)

/*/{Protheus.doc} BRSINT_C19
Ajusta proporcionalmente os valores VL_OPR dos C190 de um bloco
para fechar com o VL_DOC do C100 correspondente.
@type Static Function
@version 3.00
@author marioantonaccio
@since 16/04/2026
@param nHLog      , Numeric, Handle do log
@param aLinhas    , Array,   Array de todas as linhas (by reference)
@param aC190Bloco , Array,   { {nIndice, nVlOpr}, ... } (by reference)
@param cNumDoc    , Character, Numero do documento
@param cSerDoc    , Character, Serie
@param cCnpjPart  , Character, CNPJ participante
@param cChvNFe    , Character, Chave NFe
@param cDtDoc     , Character, Data documento
@param cIndOper   , Character, Indicador 0=Entrada 1=Saida
@param nVlDoc     , Numeric, VL_DOC do C100 (referencia)
@param nSomaOpr   , Numeric, Soma VL_OPR dos C190 originais
@param nLinC100   , Numeric, Indice do C100 no array
@param nTotDiverg , Numeric, Contador de divergencias (by reference)
@param nTotOk     , Numeric, Contador de OK (by reference)
@param nTotCorrig , Numeric, Contador de correcoes (by reference)
@param nAlt       , Numeric, Contador geral de alteracoes (by reference)
@param nTolerancia, Numeric, Tolerancia para considerar divergencia
@return NIL
/*/
Static Function BRSINT_C19( ;
	nHLog, aLinhas, aC190Bloco, ;
	cNumDoc, cSerDoc, cCnpjPart, cChvNFe, cDtDoc, cIndOper, ;
	nVlDoc, nSomaOpr, nLinC100, ;
	nTotDiverg, nTotOk, nTotCorrig, nAlt, nTolerancia ;
)

	Local nDiferenca := 0   as numeric
	Local nI         := 0   as numeric
	Local nJ         := 0   as numeric
	Local nIdxArr    := 0   as numeric
	Local nVlOprOrig := 0   as numeric
	Local nPeso      := 0   as numeric
	Local nNovoVlOpr := 0   as numeric
	Local nAcum      := 0   as numeric
	Local cLinhaNova := ""  as character
	Local aCamposC190:= {}  as array
	Local cCfop      := ""  as character

	If Len(aC190Bloco) == 0
		nTotOk += 1
		Return (NIL)
	EndIf

	nDiferenca := Abs(nVlDoc - nSomaOpr)

	If nDiferenca <= nTolerancia
		nTotOk += 1
		Return (NIL)
	EndIf

	nTotDiverg += 1
	FWrite(nHLog, Replicate("-", 60) + CRLF)
	FWrite(nHLog, "[DIVERGENCIA C190xC100] Linha C100: " + cValToChar(nLinC100) + CRLF)
	FWrite(nHLog, "  Operacao    : " + If(cIndOper == "0", "ENTRADA", "SAIDA") + CRLF)
	FWrite(nHLog, "  Documento   : " + cNumDoc + "/" + cSerDoc + CRLF)
	FWrite(nHLog, "  Chave NFe   : " + cChvNFe + CRLF)
	FWrite(nHLog, "  VL_DOC C100 : " + Transform(nVlDoc,    "@E 999,999,999.99") + CRLF)
	FWrite(nHLog, "  Soma C190   : " + Transform(nSomaOpr,  "@E 999,999,999.99") + CRLF)
	FWrite(nHLog, "  Diferenca   : " + Transform(nDiferenca,"@E 999,999,999.99") + CRLF)
	FWrite(nHLog, "  " + PadR("CFOP", 6) + " | " + PadL("ANTES", 16) + " | " + PadL("DEPOIS", 16) + " | " + PadL("DIFERENCA", 14) + CRLF)

	nAcum := 0
	For nI := 1 To Len(aC190Bloco)
		nIdxArr    := aC190Bloco[nI][1]
		nVlOprOrig := aC190Bloco[nI][2]

		If nSomaOpr <> 0
			nPeso      := nVlOprOrig / nSomaOpr
			nNovoVlOpr := Round(nVlDoc * nPeso, 2)
		Else
			nNovoVlOpr := Round(nVlDoc / Len(aC190Bloco), 2)
		EndIf

		If nI == Len(aC190Bloco)
			nNovoVlOpr := Round(nVlDoc - nAcum, 2)
		Else
			nAcum += nNovoVlOpr
		EndIf

		aCamposC190 := StrTokArr(aLinhas[nIdxArr], "|")
		cCfop       := If(Len(aCamposC190) >= 3, AllTrim(aCamposC190[3]), "")

		FWrite(nHLog, ;
			"  " + PadR(cCfop, 6) + " | " + ;
			PadL(Transform(nVlOprOrig, "@E 999,999,999.99"), 16) + " | " + ;
			PadL(Transform(nNovoVlOpr, "@E 999,999,999.99"), 16) + " | " + ;
			PadL(Transform(Abs(nNovoVlOpr - nVlOprOrig), "@E 999,999,999.99"), 14) + CRLF ;
		)

		If Len(aCamposC190) >= 5
			aCamposC190[5] := AllTrim(StrTran(Transform(nNovoVlOpr, "@E 999999999.99"), ".", ","))
			cLinhaNova := "|"
			For nJ := 1 To Len(aCamposC190)
				cLinhaNova += aCamposC190[nJ]
				If nJ < Len(aCamposC190)
					cLinhaNova += "|"
				EndIf
			Next nJ
			cLinhaNova += "||"
			aLinhas[nIdxArr] := cLinhaNova
			nTotCorrig       += 1
			nAlt             += 1
		EndIf
	Next nI

	FWrite(nHLog, Replicate("-", 60) + CRLF + CRLF)

Return (NIL)

/*/{Protheus.doc} BRSINT190D
Varre todas as linhas C190 e consolida duplicidades com base na chave
CST (2 ultimas posicoes) + CFOP por bloco C100.
A primeira ocorrencia acumula todos os valores; as demais sao marcadas
para exclusao com __DELETE__.
@type Static Function
@version 3.00
@author marioantonaccio
@since 16/04/2026
@param aLinhas, array,   Array de linhas (by reference)
@param nHLog,   numeric, Handle do LOG
@param nAlt,    numeric, Contador de alteracoes (by reference)
@param nExc,    numeric, Contador de exclusoes (by reference)
@return numeric, quantidade de C190 marcados para exclusao
/*/
Static Function BRSINT190D(aLinhas, nHLog, nAlt, nExc)

	Local aHash      := {} as array
	Local aCampos    := {} as array
	Local cLinhaNova := "" as character
	Local cChave     := "" as character
	Local cCST       := "" as character
	Local nIndex     := 0  as numeric
	Local nPos       := 0  as numeric
	Local nDC190     := 0  as numeric
	Local nI         := 0  as numeric
	Local nV1 := 0 as numeric
	Local nV2 := 0 as numeric
	Local nV3 := 0 as numeric
	Local nV4 := 0 as numeric
	Local nV5 := 0 as numeric
	Local nV6 := 0 as numeric
	Local nV7 := 0 as numeric

	FWrite(nHLog, "--- Inicio consolidacao C190 por bloco ---" + CRLF + CRLF)
	ProcRegua(Len(aLinhas))

	For nIndex := 1 To Len(aLinhas)
		IncProc()
		aCampos := StrTokArr(aLinhas[nIndex], "|")

		// Novo bloco C100: grava somatorio e reinicia hash
		If aCampos[1] == "C100"
			If Len(aHash) > 0
				BRSINT_19S(aHash, nHLog)
				aHash := {}
			EndIf
		EndIf

		// Processa C190 nao marcados para exclusao
		If aCampos[1] == "C190"
			If Len(aCampos) < 11
				Loop
			EndIf
			cCST   := PadL(AllTrim(aCampos[2]), 3, "0")
			cChave := Substr(cCST, 2, 2) + "|" + AllTrim(aCampos[3])

			nV1 := Val(StrTran(AllTrim(aCampos[5]),  ",", "."))
			nV2 := Val(StrTran(AllTrim(aCampos[6]),  ",", "."))
			nV3 := Val(StrTran(AllTrim(aCampos[7]),  ",", "."))
			nV4 := Val(StrTran(AllTrim(aCampos[8]),  ",", "."))
			nV5 := Val(StrTran(AllTrim(aCampos[9]),  ",", "."))
			nV6 := Val(StrTran(AllTrim(aCampos[10]), ",", "."))
			nV7 := Val(StrTran(AllTrim(aCampos[11]), ",", "."))

			// Procura chave no hash
			nPos := 0
			For nI := 1 To Len(aHash)
				If aHash[nI][1] == cChave
					nPos := nI
					Exit
				EndIf
			Next nI

			If nPos == 0
				// Primeira ocorrencia
				AAdd(aHash, {cChave, nIndex, nV1, nV2, nV3, nV4, nV5, nV6, nV7})
			Else
				// Duplicidade: acumula na primeira ocorrencia
				aHash[nPos][3] += nV1
				aHash[nPos][4] += nV2
				aHash[nPos][5] += nV3
				aHash[nPos][6] += nV4
				aHash[nPos][7] += nV5
				aHash[nPos][8] += nV6
				aHash[nPos][9] += nV7

				// Atualiza linha da primeira ocorrencia
				aCampos := StrTokArr(aLinhas[aHash[nPos][2]], "|")
				aCampos[5]  := AllTrim(Transform(aHash[nPos][3], "@ER 999999999.99"))
				aCampos[6]  := AllTrim(Transform(aHash[nPos][4], "@ER 999999999.99"))
				aCampos[7]  := AllTrim(Transform(aHash[nPos][5], "@ER 999999999.99"))
				aCampos[8]  := AllTrim(Transform(aHash[nPos][6], "@ER 999999999.99"))
				aCampos[9]  := AllTrim(Transform(aHash[nPos][7], "@ER 999999999.99"))
				aCampos[10] := AllTrim(Transform(aHash[nPos][8], "@ER 999999999.99"))
				aCampos[11] := AllTrim(Transform(aHash[nPos][9], "@ER 999999999.99"))
				aLinhas[aHash[nPos][2]] := BRSINT_Reb(aCampos)
				nAlt++

				FWrite(nHLog, "C190 CONSOLIDADO - Chave [" + cChave + "]" + CRLF)
				FWrite(nHLog, "  Linha ref  : " + Str(aHash[nPos][2], 6) + CRLF)
				FWrite(nHLog, "  Linha dupl : " + Str(nIndex, 6) + CRLF)
				FWrite(nHLog, "  VL acumul  : " + Transform(aHash[nPos][3], "@ER 999999999.99") + CRLF + CRLF)

				// Marca linha duplicada para exclusao
				aCampos    := StrTokArr(aLinhas[nIndex], "|")
				aCampos[1] := "C190__DELETE__"
				aLinhas[nIndex] := BRSINT_Reb(aCampos)
				nDC190++
				nExc++
			EndIf
		EndIf
	Next nIndex

	// Grava somatorio do ultimo bloco
	If Len(aHash) > 0
		BRSINT_19S(aHash, nHLog)
	EndIf

	FWrite(nHLog, "--- Fim consolidacao C190: " + cValToChar(nDC190) + " linha(s) excluida(s) ---" + CRLF + CRLF)

Return (nDC190)

/*/{Protheus.doc} BRSINT_19S
Grava no LOG o somatorio por grupo CST+CFOP do bloco C190 processado.
@type Static Function
@version 3.00
@author marioantonaccio
@since 16/04/2026
@param aHash, array,   Hash com os grupos do bloco
@param nHLog, numeric, Handle do LOG
@return NIL
/*/
Static Function BRSINT_19S(aHash, nHLog)

	Local nI      := 0 as numeric
	Local nTotVal := 0 as numeric

	FWrite(nHLog, "--- SOMATORIO C190 POR GRUPO CST+CFOP ---" + CRLF)
	FWrite(nHLog, PadR("Chave CST+CFOP", 20) + " | " + PadL("VL_BC_ICMS", 14) + " | " + PadL("VL_ICMS", 14) + CRLF)
	FWrite(nHLog, Replicate("-", 60) + CRLF)

	nTotVal := 0
	For nI := 1 To Len(aHash)
		FWrite(nHLog, ;
			PadR(aHash[nI][1], 20) + " | " + ;
			PadL(Transform(aHash[nI][3], "@ER 999999999.99"), 14) + " | " + ;
			PadL(Transform(aHash[nI][4], "@ER 999999999.99"), 14) + CRLF)
		nTotVal += aHash[nI][3]
	Next nI

	FWrite(nHLog, Replicate("-", 60) + CRLF)
	FWrite(nHLog, "TOTAL " + PadL(cValToChar(Len(aHash)) + " grupos", 15) + " | " + ;
	              PadL(Transform(nTotVal, "@ER 999999999.99"), 14) + CRLF + CRLF)

Return (NIL)

/*/{Protheus.doc} BRSINT0220
Compara o campo de codigo de barras do 0200 com o 0220.
Se a posicao do cod_barras do 0200 for igual a do 0220, limpa o 0220.
@type Static Function
@version 3.00
@author marioantonaccio
@since 16/04/2026
@param aLinhas, array,   Array de linhas (by reference)
@param nIndex,  numeric, Indice da linha 0220 atual
@param aCampos, array,   Campos da linha 0220 (by reference)
@param nHLog,   numeric, Handle do LOG
@param nAlt,    numeric, Contador de alteracoes (by reference)
@return logical, .T. se houve alteracao
/*/
Static Function BRSINT0220(aLinhas, nIndex, aCampos, nHLog, nAlt)

	Local aCmp0200   := {} as array
	Local cCodItem   := "" as character
	Local cCodBar220 := "" as character
	Local cCodBar200 := "" as character
	Local cLinhaNova := "" as character
	Local nI         := 0  as numeric
	Local lAlt       := .F. as logical

	// Campo 2 do 0220 = COD_ITEM, campo 4 = COD_BAR (ou ALIQ_ICMS dependendo da versao)
	If Len(aCampos) < 4
		Return (.F.)
	EndIf

	cCodItem   := AllTrim(aCampos[2])
	cCodBar220 := AllTrim(aCampos[4])

	// Procura o 0200 correspondente ao mesmo COD_ITEM
	For nI := 1 To nIndex - 1
		If Len(aLinhas[nI]) > 4
			aCmp0200 := StrTokArr(aLinhas[nI], "|")
			If aCmp0200[1] == "0200"
				If Len(aCmp0200) >= 2 .AND. AllTrim(aCmp0200[2]) == cCodItem
					// Campo 9 do 0200 = COD_BARRA
					cCodBar200 := If(Len(aCmp0200) >= 9, AllTrim(aCmp0200[9]), "")
					If .NOT. Empty(cCodBar200) .AND. cCodBar200 == cCodBar220
						// Limpa campo 4 do 0220
						FWrite(nHLog, "0220 CODBAR LIMPO - Linha " + Str(nIndex, 6) + CRLF)
						FWrite(nHLog, "  CodItem  : " + cCodItem + CRLF)
						FWrite(nHLog, "  CodBar   : " + cCodBar220 + " (igual ao 0200)" + CRLF + CRLF)
						aCampos[4]      := ""
						cLinhaNova      := BRSINT_Reb(aCampos)
						aLinhas[nIndex] := cLinhaNova
						nAlt++
						lAlt := .T.
					EndIf
					Exit
				EndIf
			EndIf
		EndIf
	Next nI

Return (lAlt)

/*/{Protheus.doc} BRSINT_Tot
Recalcula todos os totalizadores do arquivo SPED apos alteracoes:
C990, H005, H990, H999, 9900 (C190 e H010) e 9999.
@type Static Function
@version 3.00
@author marioantonaccio
@since 16/04/2026
@param aLinhas  , array,   Array de linhas (by reference)
@param nHLog    , numeric, Handle do LOG
@param nAlt     , numeric, Contador de alteracoes (by reference)
@param nDC190   , numeric, Qtd de C190 excluidos
@param nDH010   , numeric, Qtd de H010 excluidos
@param nDVH010  , numeric, Valor total de H010 excluidos
@param nDelete  , numeric, Total de linhas marcadas para exclusao
@return NIL
/*/
Static Function BRSINT_Tot(aLinhas, nHLog, nAlt, nDC190, nDH010, nDVH010, nDelete)

	Local aCampos    := {} as array
	Local cLinhaNova := "" as character
	Local nIndex     := 0  as numeric
	Local nQtd       := 0  as numeric

	ProcRegua(Len(aLinhas))
	For nIndex := 1 To Len(aLinhas)
		IncProc()
		aCampos := StrTokArr(aLinhas[nIndex], "|")

		// H005: atualiza valor total do estoque
		If aCampos[1] == "H005" .AND. Len(aCampos) >= 3
			If nDVH010 <> 0
				nQtd := Val(AllTrim(StrTran(aCampos[3], ",", "."))) - nDVH010
				FWrite(nHLog, "H005 TOTAL ESTOQUE - Linha " + Str(nIndex, 6) + CRLF)
				FWrite(nHLog, "  Antes  : " + aCampos[3] + CRLF)
				FWrite(nHLog, "  Depois : " + Transform(nQtd, "@ER 999999999.99") + CRLF + CRLF)
				nAlt++
				aCampos[3]      := AllTrim(Transform(nQtd, "@ER 999999999.99"))
				aLinhas[nIndex] := BRSINT_Reb(aCampos)
			EndIf
		EndIf

		// C990: quantidade de linhas do bloco C
		If aCampos[1] == "C990" .AND. Len(aCampos) >= 2
			If nDC190 > 0
				nQtd := Val(AllTrim(StrTran(aCampos[2], ",", "."))) - nDC190
				FWrite(nHLog, "C990 QTD LINHAS - Linha " + Str(nIndex, 6) + CRLF)
				FWrite(nHLog, "  Antes  : " + aCampos[2] + CRLF)
				FWrite(nHLog, "  Depois : " + cValToChar(nQtd) + CRLF + CRLF)
				nAlt++
				aCampos[2]      := cValToChar(nQtd)
				aLinhas[nIndex] := BRSINT_Reb(aCampos)
			EndIf
		EndIf

		// H990: quantidade de linhas do bloco H
		If aCampos[1] == "H990" .AND. Len(aCampos) >= 2
			If nDH010 > 0
				nQtd := Val(AllTrim(StrTran(aCampos[2], ",", "."))) - nDH010
				FWrite(nHLog, "H990 QTD LINHAS - Linha " + Str(nIndex, 6) + CRLF)
				FWrite(nHLog, "  Antes  : " + aCampos[2] + CRLF)
				FWrite(nHLog, "  Depois : " + cValToChar(nQtd) + CRLF + CRLF)
				nAlt++
				aCampos[2]      := cValToChar(nQtd)
				aLinhas[nIndex] := BRSINT_Reb(aCampos)
			EndIf
		EndIf

		// H999: total de linhas do bloco H (variante)
		If aCampos[1] == "H999" .AND. Len(aCampos) >= 2
			If nDH010 > 0
				nQtd := Val(AllTrim(StrTran(aCampos[2], ",", "."))) - nDH010
				FWrite(nHLog, "H999 QTD LINHAS - Linha " + Str(nIndex, 6) + CRLF)
				FWrite(nHLog, "  Antes  : " + aCampos[2] + CRLF)
				FWrite(nHLog, "  Depois : " + cValToChar(nQtd) + CRLF + CRLF)
				nAlt++
				aCampos[2]      := cValToChar(nQtd)
				aLinhas[nIndex] := BRSINT_Reb(aCampos)
			EndIf
		EndIf

		// 9900: quantidade por tipo de registro
		If aCampos[1] == "9900" .AND. Len(aCampos) >= 3
			If AllTrim(aCampos[2]) == "C190" .AND. nDC190 > 0
				nQtd := Val(AllTrim(StrTran(aCampos[3], ",", "."))) - nDC190
				FWrite(nHLog, "9900 C190 - Linha " + Str(nIndex, 6) + CRLF)
				FWrite(nHLog, "  Antes  : " + aCampos[3] + CRLF)
				FWrite(nHLog, "  Depois : " + cValToChar(nQtd) + CRLF + CRLF)
				nAlt++
				aCampos[3]      := cValToChar(nQtd)
				aLinhas[nIndex] := BRSINT_Reb(aCampos)
			EndIf
			If AllTrim(aCampos[2]) == "H010" .AND. nDH010 > 0
				nQtd := Val(AllTrim(StrTran(aCampos[3], ",", "."))) - nDH010
				FWrite(nHLog, "9900 H010 - Linha " + Str(nIndex, 6) + CRLF)
				FWrite(nHLog, "  Antes  : " + aCampos[3] + CRLF)
				FWrite(nHLog, "  Depois : " + cValToChar(nQtd) + CRLF + CRLF)
				nAlt++
				aCampos[3]      := cValToChar(nQtd)
				aLinhas[nIndex] := BRSINT_Reb(aCampos)
			EndIf
		EndIf

		// 9999: total geral de linhas do arquivo
		If aCampos[1] == "9999" .AND. Len(aCampos) >= 2
			If nDelete > 0
				nQtd := Val(AllTrim(StrTran(aCampos[2], ",", "."))) - nDelete
				FWrite(nHLog, "9999 TOTAL GERAL - Linha " + Str(nIndex, 6) + CRLF)
				FWrite(nHLog, "  Antes  : " + aCampos[2] + CRLF)
				FWrite(nHLog, "  Depois : " + cValToChar(nQtd) + CRLF + CRLF)
				nAlt++
				aCampos[2]      := cValToChar(nQtd)
				aLinhas[nIndex] := BRSINT_Reb(aCampos)
			EndIf
		EndIf

	Next nIndex

Return (NIL)

/*/{Protheus.doc} BRSINT_Reb
Reconstroi a linha a partir do array de campos separados por pipe.
Garante numero minimo de campos por tipo de registro.
@type Static Function
@version 3.00
@author marioantonaccio
@since 16/04/2026
@param aCampos, array, Campos da linha
@return character, linha reconstruida no formato |campo1|campo2|...|
/*/
Static Function BRSINT_Reb(aCampos)

	Local cLinhaR := "|" as character
	Local nI      := 0   as numeric
	Local nMin    := 0   as numeric

	// Minimo de campos por tipo de registro
	Do Case
		Case aCampos[1] == "H010"              ; nMin := 11
		Case aCampos[1] == "C190"              ; nMin := 12
		Case aCampos[1] == "C190__DELETE__"    ; nMin := 12
		Case aCampos[1] == "C170"              ; nMin := 38
		Case aCampos[1] == "0305"              ; nMin :=  4
		Case aCampos[1] == "C100"              ; nMin := 28
		Case aCampos[1] == "0220"              ; nMin :=  5
		Otherwise                              ; nMin :=  Len(aCampos)
	EndCase

	If Len(aCampos) < nMin
		For nI := 1 To nMin - Len(aCampos)
			AAdd(aCampos, "")
		Next nI
	EndIf

	For nI := 1 To Len(aCampos)
		cLinhaR += aCampos[nI]
		If nI < Len(aCampos)
			cLinhaR += "|"
		EndIf
	Next nI
	cLinhaR += "|"

Return (cLinhaR)

/*/{Protheus.doc} BRSINT_Del
Remove um arquivo caso exista, exibindo erro se nao conseguir.
@type Static Function
@version 3.00
@author marioantonaccio
@since 16/04/2026
@param cArquivo, character, Caminho completo do arquivo
@return logical, .T. se removido com sucesso ou nao existia
/*/
Static Function BRSINT_Del(cArquivo)

	If File(cArquivo)
		If FERASE(cArquivo) == -1
			FWAlertError("Nao foi possivel excluir o arquivo:" + CRLF + cArquivo, "Erro na exclusao de Arquivo")
			Return (.F.)
		EndIf
	EndIf

Return (.T.)
