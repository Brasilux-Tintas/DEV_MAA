#Include "Protheus.ch"
#Include "Totvs.ch"

/*/{Protheus.doc} BRSPEDN090
Programa que le um arquivo SPED EFD (TXT), compara o VL_DOC do bloco
C100 com a soma dos VL_OPR dos registros C190 filhos e:
  - Gera um arquivo _new.txt com as linhas C190 CORRIGIDAS (VL_OPR
    redistribuido proporcionalmente para fechar com o VL_DOC do C100)
  - Gera um arquivo .log com o detalhe de cada divergencia encontrada
    e os totalizadores gerais do processamento
Todas as demais linhas (nao C190, ou C190 sem divergencia) sao copiadas
integralmente para o arquivo de saida.
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
	Local cArqOrig      := " " as character  // Arquivo SPED selecionado
	Local cArqDest      := " " as character  // Arquivo _new.txt gerado
	Local cLogArq       := " " as character  // Arquivo de log
	Local cDrive        := " " as character
	Local cDiretorio    := " " as character
	Local cNome         := " " as character
	Local cExtensao     := " " as character
	Local nHLog         := 0   as numeric
	Local nHDest        := 0   as numeric
	Local nHandle       := 0   as numeric

	// --- Leitura ---
	Local aLinhas       := {}  as array      // Todas as linhas do SPED
	Local aCampos       := {}  as array      // Campos da linha corrente
	Local cLinha        := " " as character

	// --- Controle de bloco C100 ---
	Local cIndOper      := " " as character  // IND_OPER do C100
	Local cNumDoc       := " " as character  // NUM_DOC
	Local cSerDoc       := " " as character  // SER
	Local cCnpjPart     := " " as character  // COD_PART
	Local cChvNFe       := " " as character  // CHV_NFE
	Local cDtDoc        := " " as character  // DT_DOC
	Local nVlDoc        := 0   as numeric    // VL_DOC do C100
	Local nLinC100      := 0   as numeric    // Indice da linha C100 no array

	// --- Controle de bloco C190 ---
	// Cada elemento: { nIndice, nVlOprOriginal, cLinhaBruta }
	Local aC190Bloco    := {}  as array      // C190s do bloco corrente
	Local nSomaOpr      := 0   as numeric    // Soma VL_OPR dos C190 do bloco
	//Local nValor_Op      := 0   as numeric    // Soma VL_OPR dos C190 do bloco

	// --- Flags e contadores gerais ---
	Local lDentroC100   := .F. as logical
	Local nIndex        := 0   as numeric
	Local nLinhaAtual   := 0   as numeric

	// Contadores para o resumo
	Local nTotLinhas    := 0   as numeric    // Total de linhas no arquivo
	Local nTotC100      := 0   as numeric    // Total de C100 processados
	Local nTotC190      := 0   as numeric    // Total de C190 encontrados
	Local nTotDiverg    := 0   as numeric    // Blocos com divergencia
	Local nTotOk        := 0   as numeric    // Blocos sem divergencia
	Local nTotCorrig    := 0   as numeric    // Linhas C190 efetivamente corrigidas
	Local nSomaDif      := 0   as numeric    // Soma total das diferencas
	Local nSomaVlDoc    := 0   as numeric    // Soma total VL_DOC dos C100
	Local nSomaVlOpr    := 0   as numeric    // Soma total VL_OPR dos C190 (original)

	// --- Data e hora ---
	Local cDataHoraIni  := " " as character
	Local cDataHoraFim  := " " as character
	Local cHoraIni      := " " as character
	Local cHoraFim      := " " as character

	cDataHoraIni := DtoC(Date()) + " " + Time()
	cHoraIni     := Time()

	// =========================================================
	// 1. SELECAO DO ARQUIVO
	// =========================================================
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

	// =========================================================
	// 2. CRIACAO DOS ARQUIVOS DE SAIDA
	// =========================================================
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
	FWrite(nHLog, "Arquivo origem  : " + cArqOrig  + CRLF)
	FWrite(nHLog, "Arquivo gerado  : " + cArqDest  + CRLF)
	FWrite(nHLog, "Arquivo log     : " + cLogArq   + CRLF)
	FWrite(nHLog, "Inicio          : " + cDataHoraIni + CRLF)
	FWrite(nHLog, Replicate("-", 80) + CRLF + CRLF)

	// =========================================================
	// 3. LEITURA DO ARQUIVO SPED
	// =========================================================
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

	// =========================================================
	// 4. PRIMEIRA PASSAGEM: identifica blocos C100+C190,
	//    calcula divergencias e marca quais C190 precisam de correcao.
	//    Armazena as linhas ja com a correcao aplicada de volta
	//    no proprio array aLinhas (in-place), para que a segunda
	//    passagem simplesmente grave linha a linha.
	// =========================================================
	ProcRegua(nTotLinhas)

	For nIndex := 1 To nTotLinhas
		IncProc()
		nLinhaAtual := nIndex
		aCampos     := StrTokArr(aLinhas[nIndex], "|")

		If Len(aCampos) < 2
			Loop
		EndIf

		// ---------------------------------------------------------
		// C100 - CABECALHO DO DOCUMENTO
		// [1]  REG      = "C100"
		// [2]  IND_OPER = 0 (Entrada) | 1 (Saida)
		// [4]  COD_PART = codigo participante
		// [7]  SER      = serie
		// [8]  NUM_DOC  = numero documento
		// [9]  CHV_NFE  = chave NFe
		// [10] DT_DOC   = data emissao
		// [12] VL_DOC   = valor total  <-- referencia para correcao
		// ---------------------------------------------------------
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

		// ---------------------------------------------------------
		// C190 - REGISTRO ANALITICO
		// [1]  REG      = "C190"
		// [3]  CFOP     = codigo fiscal
		// [5]  VL_OPR   = valor da operacao  <-- campo a corrigir
		// [6]  VL_BC_ICMS
		// [8]  VL_BC_IPI
		// ---------------------------------------------------------
		ElseIf AllTrim(aCampos[1]) == "C190" .AND. lDentroC100
			nVlOpr := If(Len(aCampos) >= 5, Val(StrTran(AllTrim(aCampos[5]), ",", ".")), 0)
			nSomaOpr   += nVlOpr
			nTotC190   += 1
			// Guarda: { indice no array, VL_OPR original }
			AAdd(aC190Bloco, { nIndex, nVlOpr })

		// ---------------------------------------------------------
		// Registro de fechamento de bloco
		// ---------------------------------------------------------
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

	// Fecha ultimo bloco caso o arquivo nao tenha registro de encerramento
	If lDentroC100
		BRSPEDN092( ;
			nHLog, @aLinhas, @aC190Bloco, ;
			cNumDoc, cSerDoc, cCnpjPart, cChvNFe, cDtDoc, cIndOper, ;
			nVlDoc, nSomaOpr, nLinC100, ;
			@nTotDiverg, @nTotOk, @nTotCorrig, @nSomaDif, @nSomaVlOpr ;
		)
	EndIf

	// =========================================================
	// 5. SEGUNDA PASSAGEM: grava o arquivo _new.txt com as
	//    linhas ja corrigidas (in-place no array aLinhas)
	// =========================================================
	For nIndex := 1 To nTotLinhas
		FWrite(nHDest, aLinhas[nIndex] + CRLF)
	Next nIndex

	// =========================================================
	// 6. RESUMO FINAL DO LOG
	// =========================================================
	cDataHoraFim := DtoC(Date()) + " " + Time()
	cHoraFim     := Time()

	FWrite(nHLog, CRLF + Replicate("=", 80) + CRLF)
	FWrite(nHLog, "  RESUMO GERAL DO PROCESSAMENTO" + CRLF)
	FWrite(nHLog, Replicate("=", 80) + CRLF)
	FWrite(nHLog, "Total de linhas no arquivo       : " + cValToChar(nTotLinhas)  + CRLF)
	FWrite(nHLog, "Total de registros C100          : " + cValToChar(nTotC100)    + CRLF)
	FWrite(nHLog, "Total de registros C190          : " + cValToChar(nTotC190)    + CRLF)
	FWrite(nHLog, "Blocos SEM divergencia           : " + cValToChar(nTotOk)      + CRLF)
	FWrite(nHLog, "Blocos COM divergencia corrigidos: " + cValToChar(nTotDiverg)  + CRLF)
	FWrite(nHLog, "Linhas C190 efetivamente alteradas: " + cValToChar(nTotCorrig) + CRLF)
	FWrite(nHLog, Replicate("-", 80) + CRLF)
	FWrite(nHLog, "Soma VL_DOC dos C100 (referencia): " + Transform(nSomaVlDoc, "@E 999,999,999.99") + CRLF)
	FWrite(nHLog, "Soma VL_OPR dos C190 (original)  : " + Transform(nSomaVlOpr, "@E 999,999,999.99") + CRLF)
	FWrite(nHLog, "Soma total das diferencas         : " + Transform(nSomaDif,   "@E 999,999,999.99") + CRLF)
	FWrite(nHLog, Replicate("-", 80) + CRLF)
	FWrite(nHLog, "Inicio do processamento           : " + cDataHoraIni + CRLF)
	FWrite(nHLog, "Fim do processamento              : " + cDataHoraFim + CRLF)
	FWrite(nHLog, "Tempo total                       : " + ElapTime(cHoraIni, cHoraFim) + CRLF)
	FWrite(nHLog, Replicate("=", 80) + CRLF)
	FClose(nHLog)
	FClose(nHDest)

	// =========================================================
	// 7. MENSAGEM FINAL
	// =========================================================
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
Funcao auxiliar: avalia um bloco C100+seus C190.
Se houver divergencia entre VL_DOC (C100) e soma VL_OPR (C190):
  - Registra o detalhe no LOG
  - Redistribui o VL_DOC proporcionalmente entre os C190
  - Substitui in-place as linhas C190 no array aLinhas com o novo VL_OPR
A redistribuicao e proporcional ao peso original de cada C190.
O ultimo C190 absorve o centavo residual para garantir soma exata.
@type function Processamento
@version 1.00
@author marioantonaccio
@since 09/04/2026
@param nHLog      , Numeric ,	 Handle do log
@param aLinhas    , Array	,    Array de todas as linhas (by reference - escrita in-place)
@param aC190Bloco , Array	,    { {nIndice, nVlOpr}, ... } dos C190 do bloco (by reference)
@param cNumDoc    , Character, Numero do documento
@param cSerDoc    , Character	, Serie
@param cCnpjPart  , Character	, CNPJ participante
@param cChvNFe    , Character	, Chave NFe
@param cDtDoc     , Character	, Data documento
@param cIndOper   , Character	, Indicador operacao (0/1)
@param nVlDoc     , Numeric 	,  VL_DOC do C100 (valor correto)
@param nSomaOpr   , Numeric 	,  Soma VL_OPR dos C190 originais
@param nLinC100   , Numeric 	,  Indice do C100 no array (para log)
@param nTotDiverg , Numeric 	,  Contador de divergencias (by reference)
@param nTotOk     , Numeric 	,  Contador de OK (by reference)
@param nTotCorrig , Numeric 	,  Contador de C190 corrigidos (by reference)
@param nSomaDif   , Numeric 	,  Soma das diferencas (by reference)
@param nSomaVlOpr , Numeric 	,  Soma total VL_OPR originais (by reference)
@return character, sem retono
/*/

Static Function BRSPEDN092( ;
	nHLog, aLinhas, aC190Bloco, ;
	cNumDoc, cSerDoc, cCnpjPart, cChvNFe, cDtDoc, cIndOper, ;
	nVlDoc, nSomaOpr, nLinC100, ;
	nTotDiverg, nTotOk, nTotCorrig, nSomaDif, nSomaVlOpr ;
)
	Local nDiferenca    := 0    as numeric
	Local nTolerancia   := 0.02 as numeric
	Local nI            := 0    as numeric
	Local nIdxArr       := 0    as numeric
	Local nVlOprOrig    := 0    as numeric
	Local nPeso         := 0    as numeric
	Local nNovoVlOpr    := 0    as numeric
	Local nAcumCorrig   := 0    as numeric   // Acumula o que ja foi distribuido
	Local cLinhaNova    := ""   as character
	Local aCamposC190   := {}   as array
	Local cCfop         := ""   as character
	Local cTipoOper     := ""   as character
	Local nJ 			:= 0	as Numeric

	// Acumula VL_OPR originais no totalizador geral
	nSomaVlOpr += nSomaOpr

	// Sem C190 no bloco -> nao ha o que comparar
	If Len(aC190Bloco) == 0
		nTotOk += 1
		Return (NIL)
	EndIf

	nDiferenca := Abs(nVlDoc - nSomaOpr)
	cTipoOper  := If(cIndOper == "0", "ENTRADA", "SAIDA")

	// -------------------------------------------------------
	// Bloco OK: sem divergencia
	// -------------------------------------------------------
	If nDiferenca <= nTolerancia
		nTotOk += 1
		Return (NIL)
	EndIf

	// -------------------------------------------------------
	// Bloco com DIVERGENCIA: registra no log e corrige C190
	// -------------------------------------------------------
	nTotDiverg += 1
	nSomaDif   += nDiferenca

	FWrite(nHLog, Replicate("-", 80) + CRLF)
	FWrite(nHLog, "[DIVERGENCIA] Linha C100: " + cValToChar(nLinC100) + CRLF)
	FWrite(nHLog, "  Operacao     : " + cTipoOper + CRLF)
	FWrite(nHLog, "  Documento    : " + cNumDoc + " / Serie: " + cSerDoc + CRLF)
	FWrite(nHLog, "  Participante : " + cCnpjPart + CRLF)
	FWrite(nHLog, "  Data Doc.    : " + cDtDoc    + CRLF)
	FWrite(nHLog, "  Chave NFe    : " + cChvNFe   + CRLF)
	FWrite(nHLog, "  VL_DOC C100  : " + Transform(nVlDoc,    "@E 999,999,999.99") + CRLF)
	FWrite(nHLog, "  Soma C190    : " + Transform(nSomaOpr,  "@E 999,999,999.99") + CRLF)
	FWrite(nHLog, "  Diferenca    : " + Transform(nDiferenca,"@E 999,999,999.99") + CRLF)
	FWrite(nHLog, "  Qtd C190     : " + cValToChar(Len(aC190Bloco)) + CRLF)
	FWrite(nHLog, "  " + Replicate(".", 76) + CRLF)
	FWrite(nHLog, "  " + PadR("CFOP", 6) + " " + PadL("VL_OPR ORIGINAL", 18) + " " + PadL("VL_OPR CORRIGIDO", 18) + " " + PadL("DIFERENCA", 14) + CRLF)
	FWrite(nHLog, "  " + Replicate(".", 76) + CRLF)

	// -------------------------------------------------------
	// Redistribuicao proporcional do VL_DOC entre os C190
	// -------------------------------------------------------
	// Caso especial: soma original e zero -> distribui igualmente
	nAcumCorrig := 0

	For nI := 1 To Len(aC190Bloco)
		nIdxArr    := aC190Bloco[nI][1]   // indice da linha no array aLinhas
		nVlOprOrig := aC190Bloco[nI][2]   // VL_OPR original desse C190

		// Calcula novo VL_OPR proporcional
		If nSomaOpr <> 0
			nPeso      := nVlOprOrig / nSomaOpr
			nNovoVlOpr := Round(nVlDoc * nPeso, 2)
		Else
			// Distribui igualmente se soma original era zero
			nNovoVlOpr := Round(nVlDoc / Len(aC190Bloco), 2)
		EndIf

		// No ultimo C190, absorve residuo de arredondamento
		If nI == Len(aC190Bloco)
			nNovoVlOpr := Round(nVlDoc - nAcumCorrig, 2)
		Else
			nAcumCorrig += nNovoVlOpr
		EndIf

		// Grava detalhe no log
		aCamposC190 := StrTokArr(aLinhas[nIdxArr], "|")
		cCfop       := If(Len(aCamposC190) >= 3, AllTrim(aCamposC190[3]), "")
		FWrite(nHLog, ;
			"  " + PadR(cCfop, 6) + " " + ;
			PadL(Transform(nVlOprOrig, "@E 999,999,999.99"), 18) + " " + ;
			PadL(Transform(nNovoVlOpr, "@E 999,999,999.99"), 18) + " " + ;
			PadL(Transform(Abs(nNovoVlOpr - nVlOprOrig), "@E 999,999,999.99"), 14) + CRLF ;
		)

		// ---------------------------------------------------
		// Substitui VL_OPR (campo [5]) na linha C190 original
		// Reconstroi a linha inteira mantendo todos os demais
		// campos e substituindo apenas o campo [5] (VL_OPR).
		// O valor e formatado com 2 casas decimais e virgula
		// como separador decimal (padrao SPED).
		// ---------------------------------------------------
		If Len(aCamposC190) >= 5
			aCamposC190[5] := StrTran(Transform(nNovoVlOpr, "@E 999999999.99"), ".", ",")
			// Remove espacos que Transform pode inserir
			aCamposC190[5] := AllTrim(aCamposC190[5])
			// Reconstroi a linha com pipe
			cLinhaNova := "|"
			For nJ := 1 To Len(aCamposC190)
				cLinhaNova += aCamposC190[nJ]
				If nJ < Len(aCamposC190)
					cLinhaNova += "|"
				EndIf
			Next nJ
			aLinhas[nIdxArr] := cLinhaNova+"||"
			nTotCorrig += 1
		EndIf
	Next nI

	FWrite(nHLog, "  " + Replicate(".", 76) + CRLF + CRLF)

Return (NIL)
