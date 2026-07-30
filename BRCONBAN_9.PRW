#include "rwmake.ch"
#include "PROTHEUS.CH"
#include "Fileio.ch"
#include "TBICONN.CH"
#include "topconn.ch"
#include "COLORS.CH"
#include "RPTDEF.CH"
#include "FWPrintSetup.ch"
#include "font.ch"
#include "PROTHEUS.CH"
#include "RPTDEF.CH"

/*/{Protheus.doc} BRCONBAN
Programa que exibe as informações salvas na tabela ZAK -  Comprovantes de Pagamento Bradesco
@type function Menu
@version  1.00
@author marioantonaccio
@since 20/07/2026
@return character, sem retorno
/*/
User Function BRCONBAN()
	Local aArea       := FWGetArea()
	Local oBrowse
	Private aRotina   := {}
	Private cCadastro := "Extrator de Retorno Bancario"
	Private cCGCAtu   := "" as character
	Private cString   := "ZAK"
	Private aregistros:={}
	//Aviso( 'VarInfo', VarInfo('xEmpFil', totvs.framework.company.xEmpFil("SE1","01","010106") , , .F. ) ,{'ok'} ,4,,,, .T.)

	aRotina := MenuDef()

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZAK")
	oBrowse:SetDescription(cCadastro)
	oBrowse:DisableDetails()

	oBrowse:Activate()
	FWRestArea(aArea)
Return (Nil)

/*/{Protheus.doc} MenuDef
Opções de Menu
@type function Tela
@version  1.00
@author marioantonaccio
@since 20/07/2026
@return array, opções que podem ser acessadas
/*/
Static Function MenuDef()
	Local aRotina := {}

	aadd(aRotina, {"Visualizar", "AXVISUAL"    , 0, 2})
	aadd(aRotina, {"Pesquisar" , "AXPESQUISA", 0, 1})
	aadd(aRotina, {"Imprimir"  , "U_JUNIN()", 0, 3})
	aadd(aRotina, {"Importar"  , "U_BRPAGRET()", 0, 3})
Return (aRotina)

/*/{Protheus.doc} fMontaQry
Mota query de pesquisa
@type function Processamento
@version  1.00
@author marioantonaccio
@since 20/07/2026
@param cCPFParam, character, informação a ser pesquisada
@return character, query montada
/*/
Static Function fMontaQry(cCPFParam)
	Local cQ := ""
	cQ := "    SELECT DISTINCT                          " + CRLF
	cQ += "    ZAK.ZAK_FUNCPF  AS CPF,                  " + CRLF
	cQ += "    ZAK.ZAK_FUNNOM  AS NOME,                 " + CRLF
	cQ += "    ZAK.ZAK_FUNCON  AS CONTA,                " + CRLF
	cQ += "    ZAK.ZAK_FUNAGE  AS AGENCIA,              " + CRLF
	cQ += "    ZAK.ZAK_FUNBAN  AS BANCO,                " + CRLF
	cQ += "    ZAK.ZAK_FUNTIP  AS TIPO                  " + CRLF
	cQ += "    FROM " + RetSqlName("ZAK") + " ZAK       " + CRLF
	cQ += "    WHERE ZAK.D_E_L_E_T_ = ' '               " + CRLF
	cQ += "    AND ZAK.ZAK_FUNCPF = '" + cCPFParam + "' " + CRLF
	cQ += "    ORDER BY NOME                            " + CRLF
Return (cQ)

/*/{Protheus.doc} ConsArq
Executa a Consulta
@type function Processamento
@version  1.00
@author marioantonaccio
@since 20/07/2026
@return object, inicia o processo
/*/
Static Function ConsArq()
	Local cAlias   := GetNextAlias()
	Local aDados   := {}

	If .NOT. lParam
		MsgAlert("Parâmetros não informados, consulta cancelada.")
		Return .F.
	EndIf

	cCPF := fLimpaCPF(cFunci)

	If Empty(cCPF)
		MsgAlert("CPF não informado, consulta cancelada.")
		Return .F.
	EndIf

	cQry := fMontaQry(cCPF)

	If Select(cAlias) <> 0
		(cAlias)->(dbCloseArea())
	EndIf

	DbUseArea(.T., "TOPCONN", TCGenQry(,, cQry), cAlias, .F., .T.)
	DbSelectArea(cAlias)

	While !Eof()
		AAdd(aDados, {;
			AllTrim((cAlias)->CPF)    ,;
			AllTrim((cAlias)->NOME)   ,;
			AllTrim((cAlias)->CONTA)  ,;
			AllTrim((cAlias)->AGENCIA),;
			AllTrim((cAlias)->BANCO)  ,;
			AllTrim((cAlias)->TIPO)   ;
			})
		DbSkip()
	EndDo

	(cAlias)->(dbCloseArea())

Return (fMostDados(aDados, cFunci))

/*/{Protheus.doc} xParamBox
Tela de pesquisa
@type function Tela
@version  1.00
@author marioantonaccio
@since 20/07/2026
@return character, sem retorno
/*/
Static Function xParamBox()
	Local aRet      := {}
	Local aParambox := {}

	AADD(aParambox, {1, "Funcionário (CPF)", Space(14), "", "", "ZAK", "", 0, .F.})

	If Parambox(aParambox, "Informe o CPF", @aRet)
		cFunci := AllTrim(aRet[1])
		lParam := .T.
	Else
		lParam := .F.
	EndIf
Return (NIL)

/*/{Protheus.doc} fMostDados
Mostra dados de Pesquisa
@type function Tela
@version  1.00
@author marioantonaccio
@since 20/07/2026
@param aDados, array, Array com Dados
@param cFunci, character, CPF do funcionário
@return logical, indica se fecha a pesquisa
/*/
Static Function fMostDados(aDados, cFunci)
	Local oDlg
	Local oBrw
	Local oBtnVol
	Local oBtnExp
	Local oBtnSai
	Local cBrw       := ""
	Local lVolta     := .F.
	Local lFechaIni  := .T.

	If Len(aDados) == 0
		ApMsgStop("Funcionário sem informações cadastradas.")
		fLimpaParam()
		Return .F.
	EndIf

	DEFINE MSDIALOG oDlg ;
		TITLE OemToAnsi("Folha de Pagamento - " + AllTrim(cFunci)) ;
		From 000, 000 To 290, 900 PIXEL

	@ 005, 005 LISTBOX oBrw VAR cBrw ;
		FIELDS HEADER "CPF", "NOME", "CONTA", "AGENCIA", "BANCO", "TIPO" ;
		SIZE 440, 125 OF oDlg PIXEL

	oBrw:SetArray(aDados)
	oBrw:bLine := {|| {;
		fMaskCPF(aDados[oBrw:nAt][1]),;
		OemToAnsi(aDados[oBrw:nAt][2]),;
		aDados[oBrw:nAt][3],;
		aDados[oBrw:nAt][4],;
		aDados[oBrw:nAt][5],;
		aDados[oBrw:nAt][6];
		}}
	oBrw:lAdjustColSize := .T.
	oDlg:nStyle := nOR(DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE)

	@ 132, 005 BUTTON oBtnVol PROMPT "Voltar"   SIZE 070, 013 OF oDlg ACTION (lVolta := .T., oDlg:End()) PIXEL
	@ 132, 080 BUTTON oBtnExp PROMPT "Exportar" SIZE 055, 013 OF oDlg ACTION fRelFun(aDados, cFunci) PIXEL
	@ 132, 385 BUTTON oBtnSai PROMPT "Sair"     SIZE 050, 013 OF oDlg ACTION (fLimpaParam(), lFechaIni := .F., oDlg:End()) PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

	If lVolta
		xParamBox()
		If lParam
			Return ConsArq()
		EndIf
		fLimpaParam()
		Return .F.
	EndIf
Return (lFechaIni)

/*/{Protheus.doc} fRelFun
Relatório do Funcionário
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 20/07/2026
@param aDados, array, Array com Dados
@param cFunci, character, CPF do funcionário
@return character, sem retorno
/*/
Static Function fRelFun(aDados, cFunci)
	//Local oReport := Nil

	If Len(aDados) == 0
		MsgAlert(OemToAnsi("Nenhum dado para exportar."))
		Return
	EndIf

	cCPF := aDados[1][1]
	cNomRel := OemToAnsi(AllTrim(cFunci))

	fImpComprovante(aDados, cNomRel)

	cCPF := ""
	cNomRel := ""
Return (NIL)

/*/{Protheus.doc} fDefRelFun
Imprime Comprovante
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 20/07/2026
@return Object, obejto do relatorio
/*/
Static Function fDefRelFun()
	Local oReport  := Nil
	Local oSection := Nil

	oReport := TReport():New( ;
		"BRCRELFUN",;
		OemToAnsi("Detalhe do Pagamento - Crédito em Conta Salário"),;
		,;
		{|oRpt| fPrnRelFun(oRpt)},;
		OemToAnsi("Funcionário: " + cNomRel) ;
		)

	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9)
	oReport:SetPortrait()
	oReport:SetLineHeight(50)
	oReport:nFontBody := 10

	oSection := TRSection():New(oReport, OemToAnsi("Dados do Funcionário"), {"QRY_ZAKREL"})
	oSection:SetTotalInLine(.F.)

	TRCell():New(oSection, "CPF"    , "QRY_ZAKREL", "CPF"              ,, 20,,, "LEFT",,,,, .F.,,, .T.)
	TRCell():New(oSection, "NOME"   , "QRY_ZAKREL", OemToAnsi("Nome")  ,, 50,,, "LEFT",,,,, .F.,,, .F.)
	TRCell():New(oSection, "BANCO"  , "QRY_ZAKREL", "Banco"            ,, 10,,, "LEFT",,,,, .F.,,, .F.)
	TRCell():New(oSection, "AGENCIA", "QRY_ZAKREL", OemToAnsi("Agência"),, 10,,, "LEFT",,,,, .F.,,, .F.)
	TRCell():New(oSection, "CONTA"  , "QRY_ZAKREL", "Conta"            ,, 20,,, "LEFT",,,,, .F.,,, .F.)
	TRCell():New(oSection, "TIPO"   , "QRY_ZAKREL", "Tipo"             ,, 15,,, "LEFT",,,,, .F.,,, .F.)

Return (oReport)

/*/{Protheus.doc} fPrnRelFun
Executa o relatorio
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 20/07/2026
@param oReport, object, obejto do relatorio
@return character, sem retorno
/*/
Static Function fPrnRelFun(oReport)
	Local aArea   := FWGetArea()
	Local oSect   := Nil
	Local nAtual  := 0
	Local nTotal  := 0

	oSect := oReport:Section(1)

	If Select("QRY_ZAKREL") <> 0
		dbSelectArea("QRY_ZAKREL")
		dbCloseArea()
	EndIf

	PlsQuery(cQry, "QRY_ZAKREL")
	dbSelectArea("QRY_ZAKREL")
	Count To nTotal
	oReport:SetMeter(nTotal)

	oSect:Init()
	QRY_ZAKREL->(dbGoTop())
	While !QRY_ZAKREL->(Eof())
		nAtual++
		oReport:SetMsgPrint(OemToAnsi("Imprimindo " + cValToChar(nAtual) + " de " + cValToChar(nTotal)))
		oReport:IncMeter()
		oSect:PrintLine()
		QRY_ZAKREL->(dbSkip())
	EndDo
	oSect:Finish()
	QRY_ZAKREL->(dbCloseArea())

	FWRestArea(aArea)
Return (NIL)

/*/{Protheus.doc} fLimpaParam
Limpa totalmente os parametros caso o funcionario não tenha dados
assim já volta vazia para uma nova consulta
@type function Tela
@version  1.00
@author marioantonaccio
@since 20/07/2026
@return Character, sem retorno
/*/
Static Function fLimpaParam()
	cFunci := ""
	cCPF         := ""
	cQry         := ""
	lParam       := .F.
Return (NIL)


/*/{Protheus.doc} fMaskCPF
Mascara para usar no CPF
@type function Processamento
@version  1.00
@author marioantonaccio
@since 20/07/2026
@param cCPFParam, character, CPF para consulta
@return character, Varaivel de CPF com mascara
/*/
Static Function fMaskCPF(cCPFParam)
	Local cRet := AllTrim(cCPFParam)
	If Len(cRet) == 11
		cRet := SubStr(cRet,1,3) + "." + SubStr(cRet,4,3) + "." + SubStr(cRet,7,3) + "-" + SubStr(cRet,10,2)
	EndIf
Return (cRet)


/*/{Protheus.doc} fLimpaCPF
Verifica se o CPF esta vazio ou se tem a quantidade de caracteres e após isso limpa a formatação
@type function Tela
@version  1.00
@author marioantonaccio
@since 20/07/2026
@param cCPFParam, character, CPF para consulta
@return character, Variavel do CPF
/*/
Static Function fLimpaCPF(cCPFParam)
	Local cRet := AllTrim(StrTran(StrTran(StrTran(cCPFParam, ".", ""), "-", ""), " ", ""))
	Local cTemp := ""
	Local nI := 0

	For nI := 1 To Len(cRet)
		If SubStr(cRet, nI, 1) >= "0" .And. SubStr(cRet, nI, 1) <= "9"
			cTemp += SubStr(cRet, nI, 1)
		EndIf
	Next nI

	If Len(cTemp) <> 11 .Or. Empty(cTemp)
		Return ""
	EndIf
Return (cTemp)

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
Funcionalidades adicionais:
  - Pesquisa de arquivo via cGetFile com diretorio de rede pre-definido
  - Filtro opcional por nome do favorecido (parcial, sem distincao de maiusculas)
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
	Private cCGCAtu := "" as character

	cMsgIntro := ;
		"Este programa executa:" + CRLF + ;
		" " + Chr(149) + " Leitura do arquivo de retorno bancario (.ret)" + CRLF + ;
		" " + Chr(149) + " Extracao dos blocos A (dados) e Z (autenticacao)" + CRLF + ;
		" " + Chr(149) + " Tipos suportados: ADI, FER, FOL, RSC" + CRLF + ;
		" " + Chr(149) + " Pesquisa de arquivo diretamente em pasta de rede" + CRLF + ;
		" " + Chr(149) + " Filtro opcional por nome do favorecido" + CRLF + ;
		" " + Chr(149) + " Geracao de arquivo CSV separado por ponto-e-virgula" + CRLF + ;
		" " + Chr(149) + " Geracao de LOG detalhado do processamento" + CRLF + CRLF + ;
		"Clique SIM para selecionar o arquivo."

	If .NOT. FWAlertNoYes(cMsgIntro, "Extrator de Retorno Bancario")
		Return (NIL)
	Else
		If FWAlertNoYes("Deseja pré-processar e copiar os aquivos retorno de pagamento?", "Arquivos de Retorno Bancario")
			ShellExecute( "open", "c:\spool\VerifBancario.exe", "", "", 1 )
		End

		Processa({|| BRPAGRET01()}, "Processando retorno bancario...")
	EndIf

Return (NIL)

/*/{Protheus.doc} BRPAGRET01
Funcao principal de leitura e extracao do arquivo de retorno bancario.
Abre cGetFile apontando para diretorio de rede configuravel e solicita
filtro opcional de nome antes de iniciar o processamento.
@type function Processamento
@version 1.00
@author marioantonaccio
@since 08/04/2026
@return character, sem retorno
/*/
Static Function BRPAGRET01()
	Local cArqOrig:=""
	Local cArqCSV
	Local cLogArq
	
	Local cLinha
	Local cDataHoraFim
	Local cHoraFim
 	Local cDrive
	Local cDiretorio
	Local cNome
	Local cExtensao
	Private nRegistros:=0
	Private aLinhas:={}
	Private nTotal:=0
	Private cArqImp

	cArqOrig := cGetFile( 'Arquivos RET (*.ret)|*.ret|Arquivos TXT (*.txt)|*.txt|Todos Arquivos|*.*',; //[ cMascara],
		"Selecione o arquivo de retorno bancario",;                  //[ cTitulo],
		0,;                                      //[ nMascpadrao],
		'C:\',;                                  //[ cDirinicial],
		.F.,;                                    //[ lSalvar],
		GETF_LOCALHARD  + GETF_NETWORKDRIVE,;    //[ nOpcoes],
		.T.)                                     //[ lArvore]

	If Empty(cArqOrig)
		FWAlertError("Nenhum arquivo selecionado.", "Selecao de arquivo", NIL)
		Return (NIL)
	EndIf

	// =========================================================
	// 4. MONTAGEM DOS CAMINHOS DE SAIDA
	// =========================================================
	SplitPath(cArqOrig, @cDrive, @cDiretorio, @cNome, @cExtensao)
	cArqCSV := cDrive + cDiretorio + ChgFileExt(cNome, "_extrato.csv")
	cLogArq := cDrive + cDiretorio + ChgFileExt(cNome, "_extrato.log")
	cArqImp:=cNome

	//validar pois o mesmo não considera os arquivos na mesma pasta para uma proxima leitura...
	// Remove arquivos anteriores
	If File(cArqCSV)
		FClose(cArqCSV)
		If FERASE(cArqCSV) == -1
			FWAlertError("Nao foi possivel excluir o arquivo:" + CRLF + cArqCSV, "Erro na exclusao")
			Return (NIL)
		End
	End
	If File(cLogArq)
		FClose(cLogArq)
		If FERASE(cLogArq) == -1
			FWAlertError("Nao foi possivel excluir o arquivo:" + CRLF + cLogArq, "Erro na exclusao")
			Return (NIL)
		End
	End

	// =========================================================
	// 5. CRIACAO DO LOG
	// =========================================================
	nHLog := FCreate(cLogArq)
	If nHLog < 0
		FWAlertError("Erro ao criar arquivo de LOG.", "Erro", NIL)
		Return (NIL)
	End

	FWrite(nHLog, "LOG DO PROCESSAMENTO - RETORNO BANCARIO" + CRLF)
	FWrite(nHLog, "Arquivo origem   : " + cArqOrig     + CRLF)
	FWrite(nHLog, "Iniciado em      : " + cDataHoraIni + CRLF)

	// =========================================================
	// 6. LEITURA DO ARQUIVO DE RETORNO
	// =========================================================
	If File(cArqOrig)
		FWMsgRun(, {|| nHandle := FT_FUse(cArqOrig)}, "Processando", "Aguarde... lendo arquivo...")
		If nHandle == -1
			FClose(nHLog)
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

		FRENAME(cArqOrig,"XX_"+cArqOrig)


	Else
		FWAlertError("Arquivo nao encontrado.", "Nao encontrado", NIL)
		FClose(nHLog)
		Return (NIL)
	EndIf

	FWrite(nHLog, "Total de linhas lidas: " + cValToChar(Len(aLinhas)) + CRLF + CRLF)

	// =========================================================
	// 7. CRIACAO DO CSV
	// =========================================================
	nHCSV := FCreate(cArqCSV)
	If nHCSV < 0
		FWAlertError("Erro ao criar arquivo CSV.", "Erro", NIL)
		Return (NIL)
	End

	// Cabecalho CSV
	FWrite(nHCSV, ;
		"CONTA"         + ";" + ;
		"NOME"          + ";" + ;
		"CPF"          + ";" + ;
		"TIPO"          + ";" + ;
		"DT_LANCAMENTO" + ";" + ;
		"DT_CREDITO"    + ";" + ;
		"VALOR"         + ";" + ;
		"AUTENTICACAO"  + CRLF)

	// Cabecalho LOG
	FWrite(nHLog, Replicate("=", 135) + CRLF)
	FWrite(nHLog, ;
		PadR("CONTA",          22) + " | " + ;
		PadR("NOME",           32) + " | " + ;
		PadR("CPF",            32) + " | " + ;
		PadR("TIPO",            4) + " | " + ;
		PadR("DT_LANC",        10) + " | " + ;
		PadR("DT_CRED",        10) + " | " + ;
		PadL("VALOR",          14) + " | " + ;
		PadR("AUTENTICACAO",   26) + CRLF)
	FWrite(nHLog, Replicate("-", 135) + CRLF)

	// =========================================================
	// 8. EXTRACAO DOS BLOCOS A/Z COM FILTRO DE NOME
	// =========================================================
	nRegistros := BRPAGRET02(@aLinhas, nHCSV, nHLog, @nTotal, cFiltroNome, @aRegistros)

	// =========================================================
	// 9. RODAPE DO LOG E ENCERRAMENTO
	// =========================================================
	cDataHoraFim := DtoC(Date()) + " " + Time()
	cHoraFim     := Time()
	If nRegistros > 0
	        cFiltroNome:=""
			BRPAGRET06(@aRegistros, nTotal, cFiltroNome, cArqOrig)
	EndIf

/*
	FWrite(nHLog, Replicate("=", 135) + CRLF + CRLF)
	FWrite(nHLog, "=== RESUMO FINAL ===" + CRLF)
	FWrite(nHLog, "Finalizado em    : " + cDataHoraFim + CRLF)
	FWrite(nHLog, "Tempo gasto      : " + ElapTime(cHoraIni, cHoraFim) + CRLF)
	FWrite(nHLog, "Filtro nome aplic: " + If(Empty(cFiltroNome), "(nenhum)", Upper(cFiltroNome)) + CRLF)
	FWrite(nHLog, "Registros gerados: " + cValToChar(nRegistros) + CRLF)
	FWrite(nHLog, "Valor total      : " + AllTrim(Transform(nTotal, "@ER 999999999.99")) + CRLF)
	FWrite(nHLog, "CSV gerado       : " + cArqCSV + CRLF)
	FClose(nHCSV)
	FClose(nHLog)

	If nRegistros > 0
		//	BRPAGRET06(@aRegistros, nTotal, cFiltroNome, cArqOrig)
	EndIf

	FWAlertSuccess( ;
		"Processamento finalizado!" + CRLF + CRLF + ;
		"Filtro de nome    : " + If(Empty(cFiltroNome), "(todos)", Upper(cFiltroNome)) + CRLF + ;
		"Registros gerados : " + cValToChar(nRegistros) + CRLF + ;
		"Valor total       : R$ " + AllTrim(Transform(nTotal, "@ER 999999999.99")) + CRLF + CRLF + ;
		"CSV gerado        : " + cArqCSV + CRLF + ;
		"Log gerado        : " + cLogArq, ;
		"Extracao Concluida")
*/
Return (NIL)

/*/{Protheus.doc} BRPAGRET02
Varre o array de linhas do arquivo de retorno, extrai os dados dos blocos
compostos por linha A (dados) + linha B (endereco) + linha Z (autenticacao)
e grava cada registro no CSV e no LOG.
Quando a linha Z nao existir, grava o registro com autenticacao em branco.
Aplica filtro parcial de nome quando cFiltroNome nao estiver vazio:
a comparacao e feita em Upper() para ignorar maiusculas/minusculas.
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
@param aLinhas,     array,     Array com todas as linhas do arquivo (by reference)
@param nHCSV,       numeric,   Handle do arquivo CSV
@param nHLog,       numeric,   Handle do arquivo LOG
@param nTotal,      numeric,   Acumulador do valor total (by reference)
@param cFiltroNome, character, Texto parcial para filtrar nome (vazio = todos)
@param aRegistros,  array,     Registros extraidos para impressao (by reference)
@return numeric, quantidade de registros gravados
/*/
Static Function BRPAGRET02(aLinhas, nHCSV, nHLog, nTotal, cFiltroNome, aRegistros)
	
	// --- Logicos ---
	Local lBlocoA      := .F. as logical
	Local nIndex

	// Dados do bloco corrente
	ProcRegua(Len(aLinhas))

	// Header do lote/empresa (segmento C no layout recebido).
	nIndex:=1
	cEmpBan  := AllTrim(SubStr(aLinhas[nIndex], 001, 003))
	cEmpCNPJ := SubStr(aLinhas[nIndex], 019, 14)
	cEmpConv  := AllTrim(SubStr(aLinhas[nIndex], 037, 06))
	cEmpAge  := AllTrim(SubStr(aLinhas[nIndex], 053, 6))
	cEmpCon  := AllTrim(SubStr(aLinhas[nIndex], 059, 13))
	cEmpNome := AllTrim(SubStr(aLinhas[nIndex], 073, 30))
	dEmpDtOp := GetDtoDate( AllTrim(SubStr(aLinhas[nIndex], 144, 08)))
	cEmpHrOp := Transform(AllTrim(SubStr(aLinhas[nIndex], 152, 06)),"@R 99:99:99")

	If Empty(cEmpBan) .OR. Empty(cEmpCNPJ) .OR. Empty(cEmpAge) .OR. Empty(cEmpCNPJ)
		FWrite(nHLog, "ERRO: Header de empresa nao localizado ou incompleto no arquivo." + CRLF)
		FWAlertError("Nao foi possivel validar os dados da empresa no header do arquivo.", "Validacao da empresa", NIL)
		Return (NIL)
	EndIf

	If .NOT. BRPAGRET10(cEmpCNPJ, cEmpNome)
		FWrite(nHLog, "ERRO: CNPJ do arquivo (" + cEmpCNPJ + ") nao confere com a empresa/filial logada." + CRLF)
		Return (NIL)
	EndIf

	FWrite(nHLog, "Empresa arquivo : " + cEmpCNPJ + " - " + cEmpNome + CRLF)
	FWrite(nHLog, "Banco empresa   : " + cEmpBan + " / Agencia: " + cEmpAge + " / Conta: " + cEmpCon + CRLF + CRLF)

	For nIndex := 1 To Len(aLinhas)
		IncProc()
		cTipoReg := SubStr(aLinhas[nIndex], 14, 1)

		If .NOT. (cTipoReg $ "ABZ")
			Loop
		End

		// -------------------------------------------------------
		// Linha A: extrai os dados principais do pagamento
		// -------------------------------------------------------
		If cTipoReg == "A"

			// Se o arquivo nao trouxe linha Z para o bloco anterior,
			// grava mesmo assim com autenticacao em branco.
			If lBlocoA
				lBlocoA := .F.
			EndIf

			cFunBan  := AllTrim(SubStr(aLinhas[nIndex], 021, 03))
			cFunAge  := AllTrim(SubStr(aLinhas[nIndex], 024, 05))
			cFunCon  := AllTrim(SubStr(aLinhas[nIndex], 030, 12))
			cFunNome := AllTrim(SubStr(aLinhas[nIndex], 044, 30))
			cTipoPag := AllTrim(SubStr(aLinhas[nIndex], 074, 03))
			cNumPag  := AllTrim(SubStr(aLinhas[nIndex], 074, 20))
			dDtDeb   := GetDtoDate(AllTrim(SubStr(aLinhas[nIndex], 094, 8)))
			dDtPag   := GetDtoDate(AllTrim(SubStr(aLinhas[nIndex], 0155, 8)))
			dDtPrev  := GetDtoDate(AllTrim(SubStr(aLinhas[nIndex], 0094, 8)))
			nValor	 := Val(AllTrim(SubStr(aLinhas[nIndex], 168, 15)))/100
			lBlocoA  := .T.
		End

		// -------------------------------------------------------
		// Linha B: complementa o bloco A com CPF e data prevista
		// -------------------------------------------------------
		If cTipoReg == "B" .AND. lBlocoA
			// Segmento B: pos. 18 = tipo inscricao; pos. 19-32 = CPF/CNPJ.
			cFunCPF := cValToChar(Val(SubStr(aLinhas[nIndex], 19, 14)))
		End

		// -------------------------------------------------------
		// Linha Z: fecha o bloco e grava o registro
		// -------------------------------------------------------
		If cTipoReg == "Z" .AND. lBlocoA
			// Autenticacao: primeira sequencia numerica >= 10 digitos apos pos 14
			cAutent := SubStr(aLinhas[nIndex], 079,25)

			SRA->(dbSetOrder(20))
			If SRA->(dbSeek(cFunCPF))
				If SRA->RA_FILIAL  == "010101"
					BRPAGRET03()
					nRegistros++
				End
			End	
			lBlocoA := .F.
		End

	Next

	// Ultimo bloco do arquivo sem linha Z.
	If lBlocoA
		//BRPAGRET03()
		//nRegistros++
	EndIf

Return (nRegistros)


/*/{Protheus.doc} BRPAGRET03
Grava uma linha extraida no CSV e no LOG.
@type function Auxiliar
@version 1.00
@author marioantonaccio
@since 08/04/2026
@return character, sem retorno
/*/
Static Function BRPAGRET03()
	Local aArea    := GetArea()
	Local aAreaZAK := NIL
/*
	// --- Grava no CSV ---
	FWrite(nHCSV, ;
		cFunConA + ";" + ;
		cNomeA   + ";" + ;
		cCPFA    + ";" + ;
		cTipoA   + ";" + ;
		cDtLancA + ";" + ;
		cDtCredA + ";" + ;
		StrTran(AllTrim(Transform(nValorA, "@ER 999999999.99")), ".", ",") + ";" + ;
		cAutent  + CRLF)

	// --- Grava no LOG ---
	FWrite(nHLog, ;
		PadR(cFunConA, 22) + " | " + ;
		PadR(cNomeA,   32) + " | " + ;
		PadR(Transform(Val(cCPFA), "@R 999.999.999-99"), 14) + " | " + ;
		PadR(cTipoA,    4) + " | " + ;
		PadR(cDtLancA, 10) + " | " + ;
		PadR(cDtCredA, 10) + " | " + ;
		PadL(Transform(nValorA, "@ER 999999999.99"), 14) + " | " + ;
		cAutent + CRLF)
*/
	// --- Grava na tabela ZAK ---
	DbSelectArea("ZAK")
	If ZAK->(dbSeek(xFilial("ZAK")+cCPFA+DTOS(cDtCredA)+cTipoA))
		RecLock("ZAK", .F.)
	Else
		RecLock("ZAK", .T.)
	End
	ZAK->ZAK_FILIAL := FWxFilial("ZAK")
	ZAK->ZAK_EMPAGE := SubStr(cEmpAge , 1, TamSX3("ZAK_EMPAGE")[1])
	ZAK->ZAK_EMPCNP := SubStr(cEmpCNPJ,  1, TamSX3("ZAK_EMPCNP")[1])
	ZAK->ZAK_EMPCOV := SubStr(cEmpConv, 1, TamSX3("ZAK_EMPCOV")[1])
	ZAK->ZAK_EMPCON := SubStr(cEmpCon, 1, TamSX3("ZAK_EMPCON")[1])
	ZAK->ZAK_DTOPER := dEmpDtOp
	ZAK->ZAK_HORA   := SubStr(cEmpHrOp, 1, TamSX3("ZAK_HORA")[1])
	ZAK->ZAK_EMPBAN := SubStr(cEmpBan, 1, TamSX3("ZAK_EMPBAN")[1])
	ZAK->ZAK_EMPPAG := FWCodEmp()+FWCodFil()
	ZAK->ZAK_FUNNOM := SubStr(cFunNome, 1, TamSX3("ZAK_FUNNOM")[1])
	ZAK->ZAK_FUNCPF := SubStr(cFunCPF, 1, TamSX3("ZAK_FUNCPF")[1])
	ZAK->ZAK_FUNCON := SubStr(cFunCon , 1, TamSX3("ZAK_FUNCON")[1])
	ZAK->ZAK_FUNAGE := SubStr(cFunAge , 1, TamSX3("ZAK_FUNAGE")[1])
	ZAK->ZAK_FUNBAN := SubStr(cFunBan, 1, TamSX3("ZAK_FUNBAN")[1])
	ZAK->ZAK_FUNTIP := SubStr(cTipoPag , 1, TamSX3("ZAK_FUNTIP")[1])
	ZAK->ZAK_DTLANC := dDtDeb
	ZAK->ZAK_NROPAG := SubStr(cNumPag ,1, TamSX3("ZAK_NROPAG")[1])
	ZAK->ZAK_AUTENT := SubStr(cAutent , 1, TamSX3("ZAK_AUTENT")[1])
	ZAK->ZAK_DTPAG  := dDtPag
	ZAK->ZAK_VALPAG := nValor
	ZAK->ZAK_DTPREV := dDtPrev
	//MAA
	ZAK->ZAK_DTIMP 	:= dDataBase
	ZAK->USRIMP		:= (RetCodUsr())
	ZAK_ARQUIV		:= AllTrim(cArqImp)
	ZAK_DTOPER		:= dEmpDtOp
	ZAK_HORA		:= cEmpHrOp
	MsUnLock()

	nTotal += nValor 
	AAdd(aRegistros, {cFunCon, cFunNome, cTipoPag, dDtDeb, dDtPag, nValor, cAutent})

	RestArea(aAreaZAK)
	RestArea(aArea)

Return (NIL)

/*/{Protheus.doc} BRPAGRET10
Valida o CNPJ do header contra a empresa/filial logada no Protheus.
@type function Processamento
@version  1.00
@author marioantonaccio
@since 20/07/2026
@param cEmpCNPJ, character, Empresa do Docuemntop
@param cEmpNome, character, Nome da Empresa
@return Logical, indica se a validação CNPJ está ok
/*/
Static Function BRPAGRET10(cEmpCNPJ, cEmpNome)
	Local aArea   := GetArea()
	Local aAreaM0 := NIL
	// Local cCGCAtu := "" as character
	Local lRet    := .T. as logical

	DbSelectArea("SM0")
	aAreaM0 := GetArea()
	SM0->(DBGoTop()) // M0_CODIGO + M0_CODFIL
	WHILE (!SM0->(EOF()))
		If SM0->M0_CGC == cEmpCNPJ
			cCGCAtu := SM0->M0_CODIGO + SM0->M0_CODFIL
			Exit
		EndIf
		SM0->(DBSkip())
	END

	If (Empty(cCGCAtu))
		FWAlertError( ;
			"O CNPJ do arquivo nao confere com a empresa/filial logada." + CRLF + CRLF + ;
			"Arquivo : " + cEmpCNPJ + " - " + cEmpNome + CRLF + ;
			"Logada  : " + cCGCAtu + CRLF + ;
			"Filial  : " + cFilAnt, ;
			"Validacao da empresa", NIL)
		lRet := .F.
	EndIf

	RestArea(aAreaM0)
	RestArea(aArea)

Return (lRet)

/*/{Protheus.doc} BRPAGRET06
Gera preview PDF do retorno Bradesco com logo fixa do banco.
Para exibir a logo, mantenha o arquivo BRADESCO.BMP no StartPath do AppServer.
@type function Auxiliar
@version 1.00
@author marioantonaccio
@since 08/04/2026
@param aRegistros,  array,     Registros extraidos
@param nTotal,      numeric,   Valor total extraido
@param cFiltroNome, character, Filtro aplicado
@param cArqOrig,    character, Arquivo origem processado
@return character, sem retorno
/*/
Static Function BRPAGRET06(aRegistros, nTotal, cFiltroNome, cArqOrig)
	Local oPrint    := NIL
	Local oFontTit  := NIL
	Local oFontCab  := NIL
	Local oFontDet  := NIL
	Local oFontRod  := NIL
	Local cArquivo  := ""  as character
	Local cLogo     := ""  as character
	Local cFiltro   := ""  as character
	Local cOrigem   := ""  as character
	Local nLin      := 0   as numeric
	Local nLinFim   := 520 as numeric
	Local nPag      := 1   as numeric
	Local nI        := 0   as numeric

	cArquivo := "BRPAGRET_" + DToS(Date()) + "_" + StrTran(Time(), ":", "-")
	cLogo    := GetSrvProfString("StartPath", "") + "BRADESCO.BMP"
	cFiltro  := If(Empty(cFiltroNome), "(todos)", Upper(AllTrim(cFiltroNome)))
	cOrigem  := SubStr(cArqOrig, Max(1, Len(cArqOrig) - 80))

	oFontTit := TFont():New("Arial", 9, -16, .T., .T., 5, .T., 5, .T., .F.)
	oFontCab := TFont():New("Arial", 9, -10, .T., .T., 5, .T., 5, .T., .F.)
	oFontDet := TFont():New("Arial", 9, -09, .T., .F., 5, .T., 5, .T., .F.)
	oFontRod := TFont():New("Arial", 9, -08, .T., .F., 5, .T., 5, .T., .F.)

	oPrint := FWMSPrinter():New(cArquivo, IMP_PDF, .F., "", .T., , @oPrint, "", , , , .T.)
	oPrint:SetResolution(72)
	oPrint:SetLandscape()
	oPrint:SetPaperSize(DMPAPER_A4)
	oPrint:SetMargin(40, 40, 40, 40)

	For nI := 1 To Len(aRegistros)
		If nI == 1 .OR. nLin > nLinFim
			If nI > 1
				BRPAGRET08(oPrint, oFontRod, nPag)
				nPag++
			EndIf
			BRPAGRET07(oPrint, oFontTit, oFontCab, cLogo, cFiltro, cOrigem)
			nLin := 105
		EndIf

		oPrint:SayAlign(nLin, 040, aRegistros[nI][01], oFontDet, 080, 10, /*nClrText*/, 0, 0)
		oPrint:SayAlign(nLin, 125, SubStr(aRegistros[nI][02], 1, 34), oFontDet, 180, 10, /*nClrText*/, 0, 0)
		oPrint:SayAlign(nLin, 310, aRegistros[nI][03], oFontDet, 035, 10, /*nClrText*/, 2, 0)
		oPrint:SayAlign(nLin, 350, cValToChar(aRegistros[nI][04]), oFontDet, 060, 10, /*nClrText*/, 2, 0)
		oPrint:SayAlign(nLin, 415, cValToChar(aRegistros[nI][05]), oFontDet, 060, 10, /*nClrText*/, 2, 0)
		oPrint:SayAlign(nLin, 480, Transform(aRegistros[nI][06], "@E 999,999,999.99"), oFontDet, 090, 10, /*nClrText*/, 1, 0)
		oPrint:SayAlign(nLin, 575, aRegistros[nI][07], oFontDet, 170, 10, /*nClrText*/, 0, 0)
		nLin += 12
	Next

	oPrint:Line(nLin + 4, 040, nLin + 4, 745)
	nLin += 10
	oPrint:SayAlign(nLin, 395, "TOTAL", oFontCab, 080, 10, /*nClrText*/, 1, 0)
	oPrint:SayAlign(nLin, 480, Transform(nTotal, "@E 999,999,999.99"), oFontCab, 090, 10, /*nClrText*/, 1, 0)
	BRPAGRET08(oPrint, oFontRod, nPag)

	oPrint:Preview()

Return (NIL)

/*/{Protheus.doc} BRPAGRET07
Imprime cabecalho do relatorio Bradesco.
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 20/07/2026
@param oPrint, object, Obejto Relatorio
@param oFontTit, object, Objeto Fonte do Titulo
@param oFontCab, object, Objeto Fonte do Cabecalho
@param cLogo, character, Caminho do Logo
@param cFiltro, character, Filtro aplicado
@param cOrigem, character, Origem do Arquivo
@return character, sem retorno
/*/
Static Function BRPAGRET07(oPrint, oFontTit, oFontCab, cLogo, cFiltro, cOrigem)

	oPrint:StartPage()
	If File(cLogo)
		oPrint:SayBitmap(020, 040, cLogo, 055, 028)
	EndIf
	oPrint:SayAlign(025, 110, "Retorno Bancario Bradesco", oFontTit, 280, 18, /*nClrText*/, 0, 0)
	oPrint:SayAlign(048, 110, "Filtro: " + cFiltro, oFontCab, 300, 10, /*nClrText*/, 0, 0)
	oPrint:SayAlign(062, 110, "Arquivo: ..." + cOrigem, oFontCab, 500, 10, /*nClrText*/, 0, 0)

	oPrint:Line(082, 040, 082, 745)
	oPrint:SayAlign(090, 040, "CONTA", oFontCab, 080, 10, /*nClrText*/, 0, 0)
	oPrint:SayAlign(090, 125, "NOME", oFontCab, 180, 10, /*nClrText*/, 0, 0)
	oPrint:SayAlign(090, 310, "TIPO", oFontCab, 035, 10, /*nClrText*/, 2, 0)
	oPrint:SayAlign(090, 350, "DT LANC.", oFontCab, 060, 10, /*nClrText*/, 2, 0)
	oPrint:SayAlign(090, 415, "DT CRED.", oFontCab, 060, 10, /*nClrText*/, 2, 0)
	oPrint:SayAlign(090, 480, "VALOR", oFontCab, 090, 10, /*nClrText*/, 1, 0)
	oPrint:SayAlign(090, 575, "AUTENTICACAO", oFontCab, 170, 10, /*nClrText*/, 0, 0)
	oPrint:Line(102, 040, 102, 745)

Return (NIL)

/*/{Protheus.doc} BRPAGRET08
Imprime rodape e fecha pagina do relatorio Bradesco.
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 20/07/2026
@param oPrint, object, Objeto Relatorio
@param oFontRod, object, Objeto Fonte de Rodape
@param nPag, numeric, Numero da Pagina
@return character, sem retorno
/*/
Static Function BRPAGRET08(oPrint, oFontRod, nPag)

	oPrint:Line(555, 040, 555, 745)
	oPrint:SayAlign(560, 040, DToC(Date()) + " " + Time() + "  " + FunName(), oFontRod, 250, 10, , 0, 0)
	oPrint:SayAlign(560, 680, "Pagina " + cValToChar(nPag), oFontRod, 065, 10, , 1, 0)
	oPrint:EndPage()

Return (NIL)

/*/{Protheus.doc} BRPAGRET04
Extrai a autenticacao bancaria da linha Z: localiza a primeira sequencia
numerica com 10 ou mais digitos consecutivos na string recebida.
@type function Auxiliar
@version 1.00
@author marioantonaccio
@since 08/04/2026
@param cTexto, character, Conteudo da linha Z apos a posicao 14
@return character, Codigo de autenticacao ou vazio se nao encontrado
/*/
Static Function BRPAGRET04(cTexto)
	Local cRet   := "" as character
	Local cBloco := "" as character
	Local nI     := 0  as numeric
	Local cChar  := "" as character

	nI := 1
	While nI <= Len(cTexto)
		cChar := SubStr(cTexto, nI, 1)
		If cChar >= "0" .AND. cChar <= "9"
			cBloco += cChar
		Else
			If Len(cBloco) >= 10
				cRet := cBloco
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

User Function JUNIN()
	Local aArea     := FWGetArea()
	Local aDados    := {}
	Local cFunciSel := ""

	Private cCPF    := ""
	Private cNomRel := ""
	Private cQry    := ""

	If ZAK->(Eof())
		MsgAlert("Nenhum registro selecionado.")
		FWRestArea(aArea)
		Return (NIL)
	EndIf

	If Empty(ZAK->ZAK_FUNCPF)
		MsgAlert("O registro selecionado nao possui CPF cadastrado.")
		FWRestArea(aArea)
		Return (NIL)
	EndIf

	cFunciSel := AllTrim(ZAK->ZAK_FUNNOM)

	AAdd(aDados, {;
		AllTrim(ZAK->ZAK_FUNCPF)  ,;
		cFunciSel                 ,;
		AllTrim(ZAK->ZAK_FUNCON)  ,;
		AllTrim(ZAK->ZAK_FUNAGE)  ,;
		AllTrim(ZAK->ZAK_FUNBAN)  ,;
		AllTrim(ZAK->ZAK_FUNTIP)  ;
		})

	cQry := fMontaQry(AllTrim(ZAK->ZAK_FUNCPF))

	fRelFun(aDados, cFunciSel)

	FWRestArea(aArea)
Return (NIL)

Static Function fImpComprovante(aDados, cNomeFunc)
	Local oPrint     := NIL
	Local oFontTit   := NIL
	Local oFontLabel := NIL
	Local oFontValor := NIL
	Local oFontRod   := NIL
	Local cArquivo   := ""
	Local cLogo     := ""  as character
	//	Local nLin       := 0
	//	Local nColLbl    := 060
	//	Local nColVal    := 110

	If Len(aDados) == 0
		MsgAlert(OemToAnsi("Nenhum dado para exportar."))
		Return (NIL)
	EndIf

	cArquivo := "COMPROVANTE_" + DToS(Date()) + "_" + StrTran(Time(), ":", "-")

	oFontTit   := TFont():New("Arial", 9, -18, .T., .T., 5, .T., 5, .T., .F.)
	oFontLabel := TFont():New("Arial", 9, -10, .T., .T., 5, .T., 5, .T., .F.)
	oFontValor := TFont():New("Arial", 9, -11, .T., .F., 5, .T., 5, .T., .F.)
	oFontRod   := TFont():New("Arial", 9, -08, .T., .F., 5, .T., 5, .T., .F.)

	oPrint := FWMSPrinter():New(cArquivo, IMP_PDF, .F., "", .T., , @oPrint, "", , , , .T.)
	oPrint:SetResolution(72)
	oPrint:SetPortrait()
	oPrint:SetPaperSize(DMPAPER_A5)
	oPrint:SetMargin(30, 30, 30, 30)

	oPrint:StartPage()

	cLogo := GetSrvProfString("StartPath", "") + "BRADESCO.BMP"

	If File(cLogo)
		oPrint:SayBitmap(0030, 040, cLogo, 070, 030)   // logo: ocupa colunas 040-110
	EndIf

	oPrint:Say(0030, 140, "Detalhe do Pagamento - Crédito em Conta Salário ", oFontTit, 260, 24, /*nClrText*/, 0, 0)

	oPrint:Say(0080, 140, "Data da operação:", oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0080, 250, cValToChar(dDataBase), oFontLabel, 350, 12, /*nClrText*/, 0, 0)

	oPrint:Say(0130, 140, "Número de controle:", oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0130, 250, ZAK->ZAK_AUTENT, oFontLabel, 350, 12, /*nClrText*/, 0, 0)

	oPrint:Line(0180, 030, 0180, 400, RGB(0,0,0))   // topo

	SM0->(dbSetOrder(1))
	SM0->(dbSeek(ZAK->ZAK_EMPPAG))

	oPrint:Say(0230, 030, "Dados do Pagador", oFontLabel, 350, 12, /*nClrText*/, 0, 0)

	oPrint:Say(0280, 140, "Pagador: ", oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0280, 250, SM0->M0_NOMECON, oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0280, 500, "| CNPJ/CPF: ", oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0280, 550, Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"), oFontLabel, 350, 12, /*nClrText*/, 0, 0)

	oPrint:Say(0330, 140, OemToAnsi("Convênio: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0330, 250, ZAK->ZAK_EMPCOV, oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0330, 500, OemToAnsi("| Agência: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0330, 550, ZAK->ZAK_EMPAGE, oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0330, 500, OemToAnsi("| Conta: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0330, 650, Transform(Val(ZAK->ZAK_EMPCON),"@R 99999-9"), oFontLabel, 350, 12, /*nClrText*/, 0, 0)

	oPrint:Line(0380, 030, 0380, 400, RGB(0,0,0))   // topo

	oPrint:Say(0430, 030, OemToSay("Dados do Funcionário"), oFontLabel, 350, 12, /*nClrText*/, 0, 0)

	oPrint:Say(0480, 140, OemToAnsi("Funcionário: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0480, 250, ZAK->ZAK_FUNNOM, oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0480, 500, OemToAnsi("| CNPJ/CPF: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0480, 550, Transform(ZAK->ZAK_FUNCPF,"@R 999.999.999-99"), oFontLabel, 350, 12, /*nClrText*/, 0, 0)

	oPrint:Say(0530, 140, OemToAnsi("Banco: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0530, 250, ZAK->ZAK_FUNBAN, oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0530, 350, OemToAnsi("| Agência: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0530, 250, ZAK->ZAK_FUNAGE, oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0530, 350, OemToAnsi("| Conta: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	If ZAK->ZAK_FUNBAN == "237"
		oPrint:Say(0530, 450, Transform(Val(ZAK->ZAK_FUNCON),"@R 99999-9"), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	Else
		oPrint:Say(0530, 450, ZAK->ZAK_FUNCON, oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	End

	oPrint:Line(0580, 030, 0580, 400, RGB(0,0,0))   // topo

	oPrint:Say(0630, 030, OemToSay("Dados do Pagamento"), oFontLabel, 350, 12, /*nClrText*/, 0, 0)

	oPrint:Say(0680, 140, OemToAnsi("Número do Pagamento: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0680, 250, ZAK->ZAK_NROPAG, oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0680, 550, OemToAnsi("Data Prevista de Débito: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0680, 750, cValToChar(ZAK->ZAK_DTPREV), oFontLabel, 350, 12, /*nClrText*/, 0, 0)

	oPrint:Say(0730, 140, OemToAnsi("Data do Pagamento: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0730, 350, cValToChar(ZAK->ZAK_DTPAG), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0730, 550, OemToAnsi("Data de Débito: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0730, 750, cValToChar(ZAK->ZAK_DTLANC), oFontLabel, 350, 12, /*nClrText*/, 0, 0)

	oPrint:Say(0780, 140, OemToAnsi("Valor do Pagamento: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0780, 350, Transform(ZAK->ZAK_VALPAG,"@ER 999,999,999.99"), oFontLabel, 350, 12, /*nClrText*/, 0, 0)

	oPrint:Say(0830, 140, OemToAnsi("Situação: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0830, 350, "PAGO", oFontLabel, 350, 12, /*nClrText*/, 0, 0)

	oPrint:Say(0880, 140, OemToAnsi("Motivo: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)

	oPrint:Say(0930, 140, OemToAnsi("Uso da Empresa: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)

	oPrint:Line(0930, 030, 0930, 400, RGB(0,0,0))   // topo

	oPrint:Say(0980, 030, OemToAnsi("Data da Transferência "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)

	oPrint:Say(1030, 140, OemToAnsi("Situação: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(1030, 350, OemToAnsi("EFETUADA"), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(1030, 450, OemToAnsi("Banco Destino: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(1030, 650, ZAK->ZAK_FUNBAN, oFontLabel, 350, 12, /*nClrText*/, 0, 0)

	oPrint:Say(1080, 140, OemToAnsi("Data: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(1080, 350, OemToAnsi(" "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(1080, 450, OemToAnsi("Agência: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	If ZAK->ZAK_FUNBAN == "237"
		oPrint:Say(1080, 650, Transform(Val(ZAK->ZAK_FUNCON),"@R 99999-9"), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	Else
		oPrint:Say(1080, 650, ZAK->ZAK_FUNCON, oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	End

	oPrint:Say(1130, 140, OemToAnsi("Data de Devolução: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(1130, 350, OemToAnsi(" "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(1130, 450, OemToAnsi("Conta Destino: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	If ZAK->ZAK_FUNBAN == "237"
		oPrint:Say(1130, 650, Transform(Val(ZAK->ZAK_FUNCON),"@R 99999-9"), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	Else
		oPrint:Say(1130, 650, ZAK->ZAK_FUNCON, oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	End

	oPrint:Say(1180, 450, OemToAnsi("Tipo de Conta"), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(1180, 650, OemToAnsi("CONTA CORRENTE"), oFontLabel, 350, 12, /*nClrText*/, 0, 0)

	oPrint:EndPage()
	oPrint:Preview()

Return (NIL)
