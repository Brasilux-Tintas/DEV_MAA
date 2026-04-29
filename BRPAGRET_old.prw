#Include "Protheus.ch"
#Include "fileio.ch"
/*/{Protheus.doc} BRPAGRET
Programa que le o arquivo de retorno de pagamento bancario (.ret),
extrai os dados dos blocos A/B/Z e gera um CSV com:
  - Conta bancaria (sem zeros a esquerda)
  - Nome do favorecido
  - Tipo de pagamento (ADI / FER / FOL / RSC)
  - Data de lancamento (DD/MM/AAAA)
  - Data de credito    (DD/MM/AAAA)
  - Valor com centavos (R$)
  - Autenticacao bancaria (linha Z)

Layout do arquivo retorno (posicoes 1-based):
  Linha A:
    [01-13] Cabecalho sequencial
    [14]    Tipo de registro = 'A'
    [15-45] Conta bancaria (30 chars)
    [43-73] Nome do favorecido (31 chars)
    [74-76] Tipo de pagamento  (ADI/FER/FOL/RSC)
    [94-101] Data de lancamento (DDMMAAAA)
    [120-134] Valor (15 digitos inteiros / 100 = valor com centavos)
    [155-162] Data de credito (DDMMAAAA)
  Linha Z:
    [14]    Tipo de registro = 'Z'
    Primeira sequencia numerica >= 10 digitos apos pos 14 = autenticacao

@type function Processamento
@version 1.00
@author marioantonaccio
@since 08/04/2026
@return character, sem retorno
/*/
User Function BRPAGRET()

	Local cMsgIntro := "" as character

	cMsgIntro := ;
		"Este programa executa:" + CRLF + ;
		" " + Chr(149) + " Leitura do arquivo de retorno bancario (.ret)" + CRLF + ;
		" " + Chr(149) + " Extracao dos blocos A (dados) e Z (autenticacao)" + CRLF + ;
		" " + Chr(149) + " Tipos suportados: ADI, FER, FOL, RSC" + CRLF + ;
		" " + Chr(149) + " Geracao de arquivo CSV separado por ponto-e-virgula" + CRLF + ;
		" " + Chr(149) + " Geracao de LOG detalhado do processamento" + CRLF + CRLF + ;
		"Clique SIM para selecionar o arquivo."

	If .NOT. FWAlertNoYes(cMsgIntro, "Extrator de Retorno Bancario")
		Return (NIL)
	Else
		Processa({|| BRPAGRET01()}, "Processando retorno bancario...")
	EndIf

Return (NIL)

/*/{Protheus.doc} BRPAGRET01
Funcao principal de leitura e extracao do arquivo de retorno bancario.
@type function Processamento
@version 1.00
@author marioantonaccio
@since 08/04/2026
@return character, sem retorno
/*/
Static Function BRPAGRET01()

	// --- Arrays ---
	Local aLinhas      := {} as array

	// --- Strings ---
	Local cArqOrig     := "" as character
	Local cArqCSV      := "" as character
	Local cLogArq      := "" as character
	Local cDrive       := "" as character
	Local cDiretorio   := "" as character
	Local cNome        := "" as character
	Local cExtensao    := "" as character
	Local cDataHoraIni := "" as character
	Local cDataHoraFim := "" as character
	Local cHoraIni     := "" as character
	Local cHoraFim     := "" as character
	Local cLinha       := "" as character

	// --- Numericos ---
	Local nHandle      := 0 as numeric
	Local nHLog        := 0 as numeric
	Local nHCSV        := 0 as numeric
	Local nTotal       := 0 as numeric
	Local nRegistros   := 0 as numeric

	cDataHoraIni := DtoC(Date()) + " " + Time()
	cHoraIni     := Time()

	// Selecao do arquivo
	cArqOrig := cGetFile("Arquivos RET (*.ret)|*.ret|Arquivos TXT (*.txt)|*.txt|", ;
	                      "Selecione o arquivo de retorno bancario",)

	If Empty(cArqOrig)
		FWAlertError("Nenhum arquivo selecionado.", "Selecao de arquivo", NIL)
		Return (NIL)
	EndIf

	SplitPath(cArqOrig, @cDrive, @cDiretorio, @cNome, @cExtensao)
	cArqCSV := cDrive + cDiretorio + ChgFileExt(cNome, "_extrato.csv")
	cLogArq := cDrive + cDiretorio + ChgFileExt(cNome, "_extrato.log")

	// Remove arquivos anteriores
	If File(cArqCSV)
		If FERASE(cArqCSV) == -1
			FWAlertError("Nao foi possivel excluir o arquivo:" + CRLF + cArqCSV, "Erro na exclusao")
			Return (NIL)
		End
	End
	If File(cLogArq)
		If FERASE(cLogArq) == -1
			FWAlertError("Nao foi possivel excluir o arquivo:" + CRLF + cLogArq, "Erro na exclusao")
			Return (NIL)
		End
	End

	// Cria LOG
	nHLog := FCreate(cLogArq)
	If nHLog < 0
		FWAlertError("Erro ao criar arquivo de LOG.", "Erro", NIL)
		Return (NIL)
	End

	FWrite(nHLog, "LOG DO PROCESSAMENTO - RETORNO BANCARIO" + CRLF)
	FWrite(nHLog, "Arquivo origem   : " + cArqOrig     + CRLF)
	FWrite(nHLog, "Iniciado em      : " + cDataHoraIni + CRLF + CRLF)

	// Leitura do arquivo
	If File(cArqOrig)
		FWMsgRun(, {|| nHandle := FT_FUse(cArqOrig)}, "Processando", "Aguarde... lendo arquivo...")
		If nHandle == -1
			FWAlertError("Erro na abertura do arquivo.", "Erro na abertura", NIL)
			FClose(nHLog)
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
		FClose(nHLog)
		Return (NIL)
	EndIf

	FWrite(nHLog, "Total de linhas lidas: " + cValToChar(Len(aLinhas)) + CRLF + CRLF)

	// Cria CSV
	nHCSV := FCreate(cArqCSV)
	If nHCSV < 0
		FWAlertError("Erro ao criar arquivo CSV.", "Erro", NIL)
		FClose(nHLog)
		Return (NIL)
	End

	// Cabecalho do CSV
	FWrite(nHCSV, ;
		"CONTA"         + ";" + ;
		"NOME"          + ";" + ;
		"TIPO"          + ";" + ;
		"DT_LANCAMENTO" + ";" + ;
		"DT_CREDITO"    + ";" + ;
		"VALOR"         + ";" + ;
		"AUTENTICACAO"  + CRLF)

	// Cabecalho do LOG
	FWrite(nHLog, Replicate("=", 135) + CRLF)
	FWrite(nHLog, ;
		PadR("CONTA",          22) + " | " + ;
		PadR("NOME",           32) + " | " + ;
		PadR("TIPO",            4) + " | " + ;
		PadR("DT_LANC",        10) + " | " + ;
		PadR("DT_CRED",        10) + " | " + ;
		PadL("VALOR",          14) + " | " + ;
		PadR("AUTENTICACAO",   26) + CRLF)
	FWrite(nHLog, Replicate("-", 135) + CRLF)

	// Extracao dos blocos A/Z
	nRegistros := BRPAGRET_E(@aLinhas, nHCSV, nHLog, @nTotal)

	// Rodape LOG
	cDataHoraFim := DtoC(Date()) + " " + Time()
	cHoraFim     := Time()

	FWrite(nHLog, Replicate("=", 135) + CRLF + CRLF)
	FWrite(nHLog, "=== RESUMO FINAL ===" + CRLF)
	FWrite(nHLog, "Finalizado em    : " + cDataHoraFim + CRLF)
	FWrite(nHLog, "Tempo gasto      : " + ElapTime(cHoraIni, cHoraFim) + CRLF)
	FWrite(nHLog, "Registros gerados: " + cValToChar(nRegistros) + CRLF)
	FWrite(nHLog, "Valor total      : " + AllTrim(Transform(nTotal, "@ER 999999999.99")) + CRLF)
	FWrite(nHLog, "CSV gerado       : " + cArqCSV + CRLF)

	FClose(nHCSV)
	FClose(nHLog)

	FWAlertSuccess( ;
		"Processamento finalizado!" + CRLF + CRLF + ;
		"Registros gerados : " + cValToChar(nRegistros) + CRLF + ;
		"Valor total       : R$ " + AllTrim(Transform(nTotal, "@ER 999999999.99")) + CRLF + CRLF + ;
		"CSV gerado        : " + cArqCSV + CRLF + ;
		"Log gerado        : " + cLogArq, ;
		"Extracao Concluida")

Return (NIL)

/*/{Protheus.doc} BRPAGRET_E
Varre o array de linhas do arquivo de retorno, extrai os dados dos blocos
compostos por linha A (dados) + linha B (endereco) + linha Z (autenticacao)
e grava cada registro no CSV e no LOG.

Posicoes utilizadas na linha A (1-based):
  [14]      Tipo de registro = 'A'
  [15-42]   Conta bancaria (28 chars) - gravada sem zeros a esquerda
  [43-73]   Nome do favorecido (31 chars)
  [74-76]   Tipo de pagamento: ADI / FER / FOL / RSC
  [94-101]  Data de lancamento DDMMAAAA
  [120-134] Valor bruto (15 digitos inteiros; dividir por 100 = R$ com centavos)
  [155-162] Data de credito DDMMAAAA

Posicao utilizada na linha Z:
  Primeira sequencia numerica com 10+ digitos apos posicao 14 = autenticacao

@type function Auxiliar
@version 1.00
@author marioantonaccio
@since 08/04/2026
@param aLinhas,    array,   Array com todas as linhas do arquivo (by reference)
@param nHCSV,      numeric, Handle do arquivo CSV
@param nHLog,      numeric, Handle do arquivo LOG
@param nTotal,     numeric, Acumulador do valor total (by reference)
@return numeric, quantidade de registros gravados
/*/
Static Function BRPAGRET_E(aLinhas, nHCSV, nHLog, nTotal)

	// --- Strings ---
	Local cTipoReg     := "" as character
	Local cConta       := "" as character
	Local cNome        := "" as character
	Local cTipoPag     := "" as character
	Local cDtLanc      := "" as character
	Local cDtCred      := "" as character
	Local cValorRaw    := "" as character
	Local cAutent      := "" as character

	// --- Numericos ---
	Local nIndex       := 0  as numeric
	Local nRegistros   := 0  as numeric
	Local nValor       := 0  as numeric
	Local nI           := 0  as numeric

	// --- Logicos ---
	Local lBlocoA      := .F. as logical

	// Dados do bloco A corrente
	Local cContaA      := "" as character
	Local cNomeA       := "" as character
	Local cTipoA       := "" as character
	Local cDtLancA     := "" as character
	Local cDtCredA     := "" as character
	Local nValorA      := 0  as numeric

	ProcRegua(Len(aLinhas))

	For nIndex := 1 To Len(aLinhas)
		IncProc()

		If Len(aLinhas[nIndex]) < 14
			Loop
		End

		cTipoReg := SubStr(aLinhas[nIndex], 14, 1)

		// -------------------------------------------------------
		// Linha A: extrai todos os campos do bloco
		// -------------------------------------------------------
		If cTipoReg == "A"

			// Conta: posicoes 15-45 (28 chars), remove zeros a esquerda
			cConta := AllTrim(SubStr(aLinhas[nIndex], 15, 28))
			// Remove zeros a esquerda mantendo ao menos 1 digito
			For nI:=1 To Len(cConta)
				If .NOT. (SubStr(cConta, nI, 1) == "0")
					Exit
				End
			End
			cConta := SubStr(cConta, nI)

			// Nome: posicoes 43-73 (31 chars)
			cNome := AllTrim(SubStr(aLinhas[nIndex], 43, 31))

			// Tipo pagamento: posicoes 74-76 (3 chars) - ADI/FER/FOL/RSC
			cTipoPag := AllTrim(SubStr(aLinhas[nIndex], 74, 3))

			// Data lancamento: posicoes 94-101 (DDMMAAAA)
			cDtLanc := BRPAGRET_F(AllTrim(SubStr(aLinhas[nIndex], 94, 8)))

			// Valor: posicoes 120-134 (15 digitos inteiros / 100)
			cValorRaw := AllTrim(SubStr(aLinhas[nIndex], 120, 15))
			nValor    := 0
			If cValorRaw == StrTran(cValorRaw, " ", "") .AND. Len(cValorRaw) > 0
				nValor := Val(cValorRaw) / 100
			End

			// Data credito: posicoes 155-162 (DDMMAAAA)
			cDtCred := BRPAGRET_F(AllTrim(SubStr(aLinhas[nIndex], 155, 8)))

			// Guarda o bloco A para fechar na linha Z
			cContaA  := cConta
			cNomeA   := cNome
			cTipoA   := cTipoPag
			cDtLancA := cDtLanc
			cDtCredA := cDtCred
			nValorA  := nValor
			lBlocoA  := .T.

		End

		// -------------------------------------------------------
		// Linha Z: fecha o bloco e grava o registro
		// -------------------------------------------------------
		If cTipoReg == "Z" .AND. lBlocoA

			// Autenticacao: primeira sequencia numerica >= 10 digitos apos pos 14
			cAutent := BRPAGRETEX(SubStr(aLinhas[nIndex], 15))

			// Grava no CSV (separador ; decimal ,)
			FWrite(nHCSV, ;
				cContaA  + ";" + ;
				cNomeA   + ";" + ;
				cTipoA   + ";" + ;
				cDtLancA + ";" + ;
				cDtCredA + ";" + ;
				StrTran(AllTrim(Transform(nValorA, "@ER 999999999.99")), ".", ",") + ";" + ;
				cAutent  + CRLF)

			// Grava no LOG
			FWrite(nHLog, ;
				PadR(cContaA,  22) + " | " + ;
				PadR(cNomeA,   32) + " | " + ;
				PadR(cTipoA,    4) + " | " + ;
				PadR(cDtLancA, 10) + " | " + ;
				PadR(cDtCredA, 10) + " | " + ;
				PadL(Transform(nValorA, "@ER 999999999.99"), 14) + " | " + ;
				cAutent + CRLF)

			nTotal     += nValorA
			nRegistros++
			lBlocoA    := .F.

		End

	Next

Return (nRegistros)

/*/{Protheus.doc} BRPAGRET_F
Converte data no formato DDMMAAAA para DD/MM/AAAA.
Retorna a string original se nao for uma data valida.
@type function Auxiliar
@version 1.00
@author marioantonaccio
@since 08/04/2026
@param cData, character, Data no formato DDMMAAAA
@return character, Data formatada DD/MM/AAAA
/*/
Static Function BRPAGRET_F(cData)

	Local cRet := "" as character

	cData := AllTrim(cData)

	If Len(cData) == 8 .AND. cData == StrTran(cData, " ", "")
		// Valida se todos sao digitos
		If Val(cData) > 0 .OR. cData == "00000000"
			cRet := SubStr(cData,1,2) + "/" + SubStr(cData,3,2) + "/" + SubStr(cData,5,4)
		Else
			cRet := cData
		End
	Else
		cRet := cData
	End

Return (cRet)

/*/{Protheus.doc} BRPAGRETEX
Extrai a autenticacao bancaria da linha Z: localiza a primeira sequencia
numerica com 10 ou mais digitos consecutivos na string recebida.
@type function Auxiliar
@version 1.00
@author marioantonaccio
@since 08/04/2026
@param cTexto, character, Conteudo da linha Z apos a posicao 14
@return character, Codigo de autenticacao ou vazio se nao encontrado
/*/
Static Function BRPAGRETEX(cTexto)

	Local cRet     := "" as character
	Local cBloco   := "" as character
	Local nI       := 0  as numeric
	Local cChar    := "" as character

	nI := 1
	While nI <= Len(cTexto)
		cChar := SubStr(cTexto, nI, 1)
		If cChar >= "0" .AND. cChar <= "9"
			cBloco += cChar
		Else
			If Len(cBloco) >= 10
				cRet   := cBloco
				Exit
			End
			cBloco := ""
		End
		nI++
	End

	// Testa o ultimo bloco (caso a linha termine com digitos)
	If Empty(cRet) .AND. Len(cBloco) >= 10
		cRet := cBloco
	End

Return (cRet)
