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
	Local aSubRot1 := {}
	Local aSubRot2 := {}

	aadd(aSubRot1, {"Somente Registro", "AXVISUAL"    , 0, 2})
	aadd(aSubRot1, {"Movimentação"    , "U_BRPAGMOV()", 0, 6})

	aadd(aSubRot2, {"Comprovante"     , "U_BRCOMPFUN()"   , 0, 6})
	aadd(aSubRot2, {"Relatorio"       , "U_BRRELPAG()"  , 0, 6})

	aadd(aRotina , {"Pesquisar"       , "AXPESQUI"    , 0, 1})
	aadd(aRotina , {"Visualizar"      , aSubRot1      , 0, 2})
	aadd(aRotina , {"Imprimir"		  , aSubRot2      , 0, 6})
	aadd(aRotina , {"Importar"        , "U_BRPAGRET()", 0, 3})

Return (aRotina)

/*/{Protheus.doc} BRPAGMOV
Executa a Consulta
@type function Processamento
@version  1.00
@author marioantonaccio
@since 20/07/2026
@return object, inicia o processo
/*/
User Function BRPAGMOV()
	Local cAlias   := GetNextAlias()
	Local oDlg
	Local oBrw
	Local oBtnExp
	Local oBtnSai
	Local cBrw       := ""
	Private aDados   := {}

	If Select(cAlias) <> 0
		(cAlias)->(dbCloseArea())
	EndIf

	BEGINSQL ALIAS cAlias
		SELECT
			ZAK.ZAK_FUNCPF AS CPF,
			ZAK.ZAK_FUNNOM AS NOME,
			ZAK.ZAK_FUNCON AS CONTA,
			ZAK.ZAK_FUNAGE AS AGENCIA,
			ZAK.ZAK_FUNBAN AS BANCO,
			ZAK.ZAK_FUNTIP AS TIPO,
			ZAK.ZAK_VALPAG AS VALOR,
			ZAK.ZAK_DTPAG AS DATPAG,
			ZAK.ZAK_AUTENT AS AUTENT
		FROM
			%TABLE:ZAK% ZAK
		WHERE
			ZAK.%NOTDEL%
			AND ZAK.ZAK_FILIAL = %XFILIAL:ZAK%
			AND ZAK.ZAK_FUNCPF = %EXP:ZAK->ZAK_FUNCPF%
		ORDER BY
			CPF
	EndSQL

	While .NOT. (cAlias)->(EOF())
		AAdd(aDados, {;
			(cAlias)->CPF    ,;
			AllTrim((cAlias)->NOME)   ,;
			(cAlias)->CONTA  ,;
			(cAlias)->AGENCIA,;
			(cAlias)->BANCO  ,;
			(cAlias)->TIPO   ,;
			(cAlias)->VALOR  ,;
			(cAlias)->DATPAG ,;
			(cAlias)->AUTENT })
		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(dbCloseArea())

	If Len(aDados) == 0
		FWAlertError("Funcionário sem informações cadastradas.","Sem Dados")
		Return (NIL)
	EndIf

	DEFINE MSDIALOG oDlg ;
		TITLE OemToAnsi("Movimentação Pagamento - ") + AllTrim(ZAK->ZAK_FUNCPF) ;
		From 000, 000 To 310, 900 PIXEL

	@ 005, 005 LISTBOX oBrw VAR cBrw ;
		FIELDS HEADER "CPF", "NOME", "CONTA", "AGENCIA", "BANCO", "TIPO","VALOR","DATA PAGTO","AUTENTICACAO" ;
		SIZE 440, 125 OF oDlg PIXEL

	oBrw:SetArray(aDados)
	oBrw:bLine := {|| {;
		Transform(aDados[oBrw:nAt][1],"@R 999.999.999-99"),;
		OemToAnsi(aDados[oBrw:nAt][2]),;
		aDados[oBrw:nAt][3],;
		aDados[oBrw:nAt][4],;
		aDados[oBrw:nAt][5],;
		aDados[oBrw:nAt][6],;
		Transform(aDados[oBrw:nAt][7],"@ER 999,999,999.99"),;
		cValToChar(STOD(aDados[oBrw:nAt][8])),;
		aDados[oBrw:nAt][9]}}

	oBrw:lAdjustColSize := .T.
	oDlg:nStyle := nOR(DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE)

	@ 132, 080 BUTTON oBtnExp PROMPT "Exportar" SIZE 055, 013 OF oDlg ACTION BRPAGM01() PIXEL
	@ 132, 385 BUTTON oBtnSai PROMPT "Sair"     SIZE 050, 013 OF oDlg ACTION oDlg:End() PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

Return (NIL)

/*/{Protheus.doc} BRPAGM01
Relatório do Funcionário
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 20/07/2026
@return character, sem retorno
/*/
Static Function BRPAGM01()
	Private oReport                  as Object
	Private oSecCPF                   as Object

	//Cria as definições do relatório
	oReport := BRPAGM02()
	oReport:PrintDialog()

Return (NIL)

Static Function BRPAGM02()
	Local cTitle  as Character
	Local oReport as Object

	cTitle := "Relação de Movimentação de Depositos Pagamentos "
	//--------------------------------------------------------------------------
	//³Criacao do componente de impressao                                      ³
	//³                                                                        ³
	//³TReport():New                                                           ³
	//³ExpC1 : Nome do relatorio                                               ³
	//³ExpC2 : Titulo                                                          ³
	//³ExpC3 : Pergunte                                                        ³
	//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
	//³ExpC5 : Descricao                                                       ³
	//³                                                                        ³
	//--------------------------------------------------------------------------
	oReport:=TReport():New("BRPAGM0V",cTitle,"", {|oReport|BRPAGM03(oReport)},;
		"Este programa emite o Relatorio de "+cTitle)

	oReport:lParamPage:=.F.
	oReport:lTotalInLine:=.F.
	oReport:SetLandScape()
	oReport:nFontBody := 8
	oReport:nLineHeight := 30
	oReport:lDisableOrientation:=.F.
	oReport:nEnvironment:=2
	oReport:lEdit:=.F.
	oReport:SetLeftMargin(1)

	oSecCPF:= TRSection():New(oReport,"CPF")
	oSecCPF:SetHeaderPage()
	oSecCPF:nLinesBefore := 0

Return(oReport)

/*/{Protheus.doc} BRPAGM03
Processa as informacoes e imprime o relatorio
@type function Processamento
@version  1.0
@author marioantonaccio
@since 30/01/2026
@param oReport, object, Obejto do relatorio
@return character, sem retorno
@see
//oSection1:SetTotalInLine(.F.)
//DEFINE FUNCTION FROM oSection1:Cell('PAC_COMIS') FUNCTION SUM NO END SECTION PICTURE '@E@Z 999.99'
oSecSC:Cell("NQTD"):Hide()
/*/
Static Function BRPAGM03(oReport)

	Local cAGENCIA      := ""                 as Character
	Local cAUTENT       := " "                as Character
	Local cBANCO        := ""                 as Character
	Local cCONTA        := ""                 as Character
	Local cCPF          := ""                 as Character
	Local cNOME         := ""                 as Character
	Local cTIPO         := ""                 as Character
	Local cTitulo       := oReport:Title()    as Object
	Local dDATPAG       := CTOD(" ")          as Date
	Local nI            := 0                  as Numeric
	Local nVALOR        := 0                  as Numeric
	Local oSecCPF       := oReport:Section(1) as Objec
	Private lEndPage    := .F.                as Logical
	Private lEndRep     := .T.                as Logical
	Private lEndReport  := .T.                as Logical
	Private lEndSection := .T.                as Logical

	oSecCPF := oReport:Section(1)

	TRCell():New(oSecCPF, "cCPF"    , " ", "CPF"               , "@R 999.999.999-99" , 15, /*lPixel*/, {|| cCPF    }, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .T.)
	TRCell():New(oSecCPF, "cNOME"   , " ", "Nome"              , "@!"                , 40, /*lPixel*/, {|| cNome   }, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New(oSecCPF, "cBANCO"  , " ", "Banco"             , "999"               , 05, /*lPixel*/, {|| cBanco  }, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New(oSecCPF, "cAGENCIA", " ", OemToAnsi("Agência"), "@9"                , 10, /*lPixel*/, {|| cAgencia}, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New(oSecCPF, "cCONTA"  , " ", "Conta"             , "@9"                , 20, /*lPixel*/, {|| cConta  }, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New(oSecCPF, "cTIPO"   , " ", "Tipo Pag"          , "@!"                , 10, /*lPixel*/, {|| cTipo   }, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New(oSecCPF, "nVALOR"  , " ", "Valor Pag"         , "@ER 999,999,999.99", 16, /*lPixel*/, {|| nValor  }, "RIGHT",/*lLineBreak*/, "RIGHT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New(oSecCPF, "dDATPAG" , " ", "Data Pag"          , "@D"                , 10, /*lPixel*/, {|| dDatPag }, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New(oSecCPF, "cAUTENT" , " ", "Autenticação"      , "@!"                , 30, /*lPixel*/, {|| cAutent }, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRFunction():New(oSecCPF:Cell("nVAlor"),"TVENDA","SUM",,,"@ER 999,999,999.99",,.F.,.T.)

	oReport:SetTotalInLine(.F.)
	oReport:lUnderLine := .F.

	// Titulo
	oReport:SetTitle(cTitulo)

	// Regua
	oReport:SetMeter(Len(aDados))

	// Esconde a Secao referente a Filial para impressao somente dos totais
	oReport:cFontBody := 'Courier New'
	oReport:nFontBody := 8
	oReport:EndReport(.F.)

	oSecCPF:lHeaderSection := .T.
	oSecCPF:Init()

	For nI:=1 To Len(aDados)

		If oReport:Cancel()
			Exit
		EndIf

		cCPF     := aDados[nI][1]
		cNOME    := aDados[nI][2]
		cBANCO   := aDados[nI][3]
		cAGENCIA := aDados[nI][4]
		cCONTA   := aDados[nI][5]
		cTIPO    := aDados[nI][6]
		nVALOR   := aDados[nI][7]
		dDATPAG  := cValToChar(STOD(aDados[nI][8]))
		cAUTENT  := aDados[nI][9]

		oReport:SetMsgPrint("Imprimindo ...")
		oReport:SkipLine()
		oReport:IncMeter()

		oSecCPF:PrintLine()

		If oReport:nDevice == 4 .And. oSecCPF:lHeaderSection
			oReport:lHeaderVisible := .F.
			oSecVend:lHeaderSection := .F.
		EndIf
	Next

	oSecCPF:Finish()
	oReport:Finish()

Return (NIL)

/*/{Protheus.doc} BRPAGRET
Programa que le o arquivo de retorno de pagamento bancario (.ret),
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
	
	cMsgIntro := ;
		"Este programa executa:" + CRLF + ;
		" " + Chr(149) + " Leitura do arquivo de retorno bancario (.ret)" + CRLF + ;
		" " + Chr(149) + " Extracao dos blocos A (dados) e Z (autenticacao)" + CRLF + ;
		" " + Chr(149) + " Tipos suportados: ADI, FER, FOL, RSC, 13o.(1 e 2)" + CRLF + ;
		" " + Chr(149) + " Pesquisa de arquivo diretamente em pasta de rede" + CRLF + ;
		" " + Chr(149) + " Geracao de LOG detalhado do processamento" + CRLF + CRLF + ;
		"Clique SIM para selecionar o arquivo."

	If .NOT. FWAlertNoYes(cMsgIntro, "Extrator de Retorno Bancario")
		Return (NIL)
	Else
		If FWAlertNoYes("Deseja pré-processar e copiar os aquivos retorno de pagamento?", "Arquivos de Retorno Bancario")
			ShellExecute( "open", SuperGetMv("BR_DREXELO",.F.,"c:\spool\")+"VerifBancario.exe", "", "", 1 )
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
	Local cLogArq
	Local cLinha
	Local cDataHoraFim
	Local cHoraFim
	Local cDrive
	Local cDiretorio
	Local cNome
	Local cExtensao
	Local nHandle:=0
	Local nRegEmp:=0
	Local aSelec := {}
	Local nI
	Private cCGCAtu := "" as character
	Private nRegistros:=0
	Private aLinhas:={}
	Private nTotal:=0
	Private cArqImp
	Private cFiliais:=""

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

	//Seleção de Filiais
	If FWAlertNoYes("Deseja Selecionar as Filiais a Serem Importadas?", "Arquivos de Retorno Bancario")
		nRegEmp:=SM0->(RecNo())

		//Chama a tela para selecionar filial
		aSelec := FWListBranches(, , .T., {"FLAG", "SM0_CODFIL", "SM0_NOMRED", "SM0_CGC"})

		//Se foi selecionado
		If Len(aSelec) > 0
			For nI:=1 To Len(aSelec)
				cFiliais+=aSelec[nI][2]+"/"
			Next
			cFiliais:=Substr(cFiliais,1,Len(cFiliais)-1)
		EndIf
		SM0->(dbGoTo(nRegEmp))
	End

	// =========================================================
	// 4. MONTAGEM DOS CAMINHOS DE SAIDA
	// =========================================================
	SplitPath(cArqOrig, @cDrive, @cDiretorio, @cNome, @cExtensao)
	cLogArq := cDrive + cDiretorio + ChgFileExt(cNome, "_extrato.log")
	cArqImp:=cNome

	//validar pois o mesmo não considera os arquivos na mesma pasta para uma proxima leitura...
	// Remove arquivos anteriores
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
	cHoraIni:=Time()
	FWrite(nHLog, "LOG DO PROCESSAMENTO - RETORNO BANCARIO" + CRLF)
	FWrite(nHLog, "Arquivo origem   : " + cArqOrig     + CRLF)
	FWrite(nHLog, "Iniciado em      : " + cValToChar(dDataBase)+" - "+Substr(Time(),1,5) + CRLF)

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

		//Processo Principal
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

	// Cabecalho LOG
	FWrite(nHLog, Replicate("=", 135) + CRLF)
	FWrite(nHLog, ;
		PadR("CONTA",          22) + " | " + ;
		PadR("NOME",           32) + " | " + ;
		PadR("CPF",            14) + " | " + ;
		PadR("TIPO",            4) + " | " + ;
		PadR("DT_LANC",        10) + " | " + ;
		PadR("DT_CRED",        10) + " | " + ;
		PadL("VALOR",          14) + " | " + ;
		PadR("AUTENTICACAO",   26) + CRLF)
	FWrite(nHLog, Replicate("-", 135) + CRLF)

	// =========================================================
	// 8. EXTRACAO DOS BLOCOS A/Z COM FILTRO DE NOME
	// =========================================================
	nRegistros := BRPAGRET02(@aLinhas, nHLog, @nTotal, @aRegistros)

	// =========================================================
	// 9. RODAPE DO LOG E ENCERRAMENTO
	// =========================================================
	cDataHoraFim := DtoC(Date()) + " " + Time()
	cHoraFim     := Time()

	FWrite(nHLog, Replicate("=", 135) + CRLF + CRLF)
	FWrite(nHLog, "=== RESUMO FINAL ===" + CRLF)
	FWrite(nHLog, "Finalizado em    : " + cDataHoraFim + CRLF)
	FWrite(nHLog, "Tempo gasto      : " + ElapTime(cHoraIni, cHoraFim) + CRLF)
	FWrite(nHLog, "Registros gerados: " + cValToChar(nRegistros) + CRLF)
	FWrite(nHLog, "Valor total      : " + AllTrim(Transform(nTotal, "@ER 999.999.999.99")) + CRLF)

	If nRegistros > 0
		If FWAlertYesNo("Deseja Imprimir o Relatorio dos Registros Improtados?","Impressao de Relatorio")
			BRPAGRET06(@aRegistros, nTotal, cArqOrig)
		End
	EndIf

	FClose(nHLog)
	FClose(cLogArq)

	FWAlertSuccess( ;
		"Processamento finalizado!" + CRLF + CRLF + ;
		"Registros gerados : " + cValToChar(nRegistros) + CRLF + ;
		"Valor total       : R$ " + AllTrim(Transform(nTotal, "@ER 999999999.99")) + CRLF +  ;
		"Log gerado        : " + cLogArq, "Processamento Concluido")

Return (NIL)

/*/{Protheus.doc} BRPAGRET02
Varre o array de linhas do arquivo de retorno, extrai os dados dos blocos
compostos por linha A (dados) + linha B (endereco) + linha Z (autenticacao)
e grava cada registro no LOG.
Quando a linha Z nao existir, grava o registro com autenticacao em branco.
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
@param nHLog,       numeric,   Handle do arquivo LOG
@param nTotal,      numeric,   Acumulador do valor total (by reference)
@param aRegistros,  array,     Registros extraidos para impressao (by reference)
@return numeric, quantidade de registros gravados
/*/
Static Function BRPAGRET02(aLinhas, nHLog, nTotal, aRegistros)
	Local lBlocoA    := .F. as logical
	Local nIndex            as numeric
	Private cAutent  := " " as Character
	Private cEmpAge  := " " as Character
	Private cEmpBan  := " " as Character
	Private cEmpCNPJ := " " as Character
	Private cEmpCon  := " " as Character
	Private cEmpConv := " " as Character
	Private cEmpHrOp := " " as Character
	Private cEmpNome := " " as Character
	Private cFunCPF  := " " as Character
	Private cTipoReg := " " as Character
	Private dEmpDtOp := " " as Date

	// Dados do bloco corrente
	ProcRegua(Len(aLinhas))

	// Header do lote/empresa (segmento C no layout recebido).
	cEmpBan  := AllTrim(SubStr(aLinhas[1], 001, 03))
	cEmpCNPJ := AllTrim(SubStr(aLinhas[1], 019, 14))
	cEmpConv := AllTrim(SubStr(aLinhas[1], 037, 06))
	cEmpAge  := AllTrim(SubStr(aLinhas[1], 053, 06))
	cEmpCon  := AllTrim(SubStr(aLinhas[1], 059, 13))
	cEmpNome := AllTrim(SubStr(aLinhas[1], 073, 30))
	dEmpDtOp := GetDtoDate( AllTrim(SubStr(aLinhas[1], 144, 08)))
	cEmpHrOp := Transform(AllTrim(SubStr(aLinhas[1], 152, 06)),"@R 99:99:99")

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
	aRegistros:={}
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

				If .NOT. Empty(cFiliais)
					If SRA->RA_FILIAL  $ cFiliais
						BRPAGRET03(SRA->RA_FILIAL)
						nRegistros++
					End
				Else
					BRPAGRET03(SRA->RA_FILIAL)
					nRegistros++
				End
			End
			lBlocoA := .F.
		End

	Next

Return (nRegistros)

/*/{Protheus.doc} BRPAGRET03
Grava uma linha extraida  no LOG.
@type function Auxiliar
@version 1.00
@author marioantonaccio
@since 08/04/2026
@return character, sem retorno
/*/
Static Function BRPAGRET03(cFunFil)
	Local aArea    := GetArea()

	// --- Grava no LOG ---
	FWrite(nHLog, ;
		PadR(cFunCon, 22) 										+ " | " + ;
		PadR(cFunNome,32) 										+ " | " + ;
		PadR(cFunCPF ,14)										+ " | " + ;
		PadR(cTipoPag ,04) 										+ " | " + ;
		PadR(dDtDeb   ,10) 										+ " | " + ;
		PadR(dDtPag   ,10) 										+ " | " + ;
		PadL(Transform(nValor, "@ER 999999999.99"), 14) 		+ " | " + ;
		cValToChar(cAutent) + CRLF )

	// --- Grava na tabela ZAK ---
	DbSelectArea("ZAK")
	If ZAK->(dbSeek(xFilial("ZAK")+cFunCPF+cTipoPaG+StrZero(Year(dDtPag),4,0)+StrZero(Month(dDtPag),2,0)))
		RecLock("ZAK", .F.)
	Else
		RecLock("ZAK", .T.)
	End
	ZAK->ZAK_FILIAL := FWxFilial("ZAK")
	ZAK->ZAK_EMPAGE := cEmpAge
	ZAK->ZAK_EMPCNP := cEmpCNPJ
	ZAK->ZAK_EMPCOV := cEmpConv
	ZAK->ZAK_EMPCON := cEmpCon
	ZAK->ZAK_EMPBAN := cEmpBan
	ZAK->ZAK_EMPPAG := FWCodEmp()+FWCodFil()
	ZAK->ZAK_FUNNOM := cFunNome
	ZAK->ZAK_FUNCPF := cFunCPF
	ZAK->ZAK_FUNCON := cFunCon
	ZAK->ZAK_FUNAGE := cFunAge
	ZAK->ZAK_FUNBAN := cFunBan
	ZAK->ZAK_FUNTIP := cTipoPag
	ZAK->ZAK_FUNFIL := cFunFil
	ZAK->ZAK_DTLANC := dDtDeb
	ZAK->ZAK_NROPAG := cNumPag
	ZAK->ZAK_AUTENT := cAutent
	ZAK->ZAK_DTPAG  := dDtPag
	ZAK->ZAK_VALPAG := nValor
	ZAK->ZAK_DTPREV := dDtPrev
	ZAK->ZAK_ANOMES := AnoMes(dDtPag)
	//MAA
	ZAK->ZAK_DTIMP  := dDataBase
	ZAK->ZAK_USRIMP := UsrRetName(__cUserId)
	ZAK->ZAK_ARQUIV := AllTrim(cArqImp)
	ZAK->ZAK_DTOPER := dEmpDtOp
	ZAK->ZAK_HROPER := cEmpHrOp
	MsUnLock()

	nTotal += nValor
	AAdd(aRegistros, {cFunCon, cFunNome, cTipoPag, dDtDeb, dDtPag, nValor, cAutent})

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
	Local nRegSM0:=0
	// Local cCGCAtu := "" as character
	Local lRet    := .T. as logical

	DbSelectArea("SM0")
	nRegSM0 := SM0->(RecNo()))
	SM0->(DBGoTop()) // M0_CODIGO + M0_CODFIL
	WHILE  .NOT. (SM0->(EOF()))
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

	SM0->(dbGoTo(nRegSM0))
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
@param cArqOrig,    character, Arquivo origem processado
@return character, sem retorno
/*/
Static Function BRPAGRET06(aRegistros, nTotal, cArqOrig)
	Local oPrint    := NIL
	Local oFontTit  := NIL
	Local oFontCab  := NIL
	Local oFontDet  := NIL
	Local oFontRod  := NIL
	Local cArquivo  := ""  as character
	Local cLogo     := ""  as character
	Local cOrigem   := ""  as character
	Local nLin      := 0   as numeric
	Local nLinFim   := 520 as numeric
	Local nPag      := 1   as numeric
	Local nI        := 0   as numeric

	cArquivo := "BRPAGRET_" + DToS(Date()) + "_" + StrTran(Time(), ":", "")
	cLogo    := GetSrvProfString("StartPath", "") + "BRADESCO.BMP"
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
			BRPAGRET07(oPrint, oFontTit, oFontCab, cLogo, cOrigem)
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
@param cOrigem, character, Origem do Arquivo
@return character, sem retorno
/*/
Static Function BRPAGRET07(oPrint, oFontTit, oFontCab, cLogo, cOrigem)

	oPrint:StartPage()
	If File(cLogo)
		oPrint:SayBitmap(020, 040, cLogo, 055, 028)
	EndIf
	oPrint:SayAlign(025, 110, "Retorno Bancario Bradesco", oFontTit, 280, 18, /*nClrText*/, 0, 0)
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

/*/{Protheus.doc} BRCOMPFUN
Impressao de Comprovante
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 28/07/2026
@return character, sem retorno
/*/
User Function BRCOMPFUN()
	Local oDlg
	Local nLastKey
	Private oPrint     := NIL
	Private oFontTit   := NIL
	Private oFontLabel := NIL
	Private oFontValor := NIL
	Private oFontRod   := NIL
	Private cArquivo   := " "

	cArquivo := "COMPR_" + Substr(ZAK->ZAK_FUNCPF,1,6) + "_" + Subs(StrTran(Time(), ":", ""),1,6)

	oFontTit   := TFont():New("Arial", 9, -14, .T., .T., 5, .T., 5, .T., .F.)
	oFontLabel := TFont():New("Arial", 9, -09, .T., .F., 5, .T., 5, .T., .F.)
	oFontLabN  := TFont():New("Arial", 9, -10, .T., .T., 5, .T., 5, .T., .F.)
	oFontValor := TFont():New("Arial", 9, -11, .T., .F., 5, .T., 5, .T., .F.)
	oFontRod   := TFont():New("Arial", 9, -08, .T., .F., 5, .T., 5, .T., .F.)
	nLastKey  := If(LastKey() == 27,27,nLastKey)

	If nLastKey == 27
		Return (NIL)
	Endif

	oPrint := FWMSPrinter():New(cArquivo, IMP_PDF, .F., " ", .T., , @oPrint, "", , , , .T.)
	oPrint:SetResolution(72)
	oPrint:SetPortrait()
	oPrint:setPaperSize(9)
	oPrint:SetMargin(30, 30, 30, 30)
	oPrint:cPathPDF := SuperGetMv("BR_DRIMPLO",.F.,"c:\spool\")
	oPrint:SetParm( "-RFS")
	oPrint:SetViewPDF(.T.)

	DEFINE MSDIALOG oDlg FROM 264,182 TO 441,613 TITLE "Impressao de Comprovante" OF oDlg PIXEL
	@ 004,010 TO 082,157 LABEL "" OF oDlg PIXEL

	@ 015,017 SAY "Esta rotina tem por objetivo imprimir"	OF oDlg PIXEL Size 150,010 FONT oFontlabel COLOR CLR_HBLUE
	@ 030,017 SAY "o impresso customizado:"					OF oDlg PIXEL Size 150,010 FONT oFontLabel COLOR CLR_HBLUE
	@ 045,017 SAY "Comnprovante de Deposito " 				OF oDlg PIXEL Size 150,010 FONT oFontLabel COLOR CLR_HBLUE

	@ 06,167 BUTTON "&Imprime" 		SIZE 036,012 ACTION BRCOMPF01("P")   	OF oDlg PIXEL
	@ 28,167 BUTTON "Pre&view" 		SIZE 036,012 ACTION BRCOMPF01("V") 	OF oDlg PIXEL
	@ 49,167 BUTTON "Sai&r"    		SIZE 036,012 ACTION oDlg:End()     	OF oDlg PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

Return(NIL)

/*/{Protheus.doc} BRCOMPF01
Rotina que gera o comprovante de pagamento
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 28/07/2026
@param cTipo, character, Tipo de Im,pressao -  V=Preview, P= Impressao
@return character, sem retorno
/*/
Static Function BRCOMPF01(cTipo)

	Local cLogo := GetSrvProfString("StartPath", "") + "BRADESCO.BMP"

	SM0->(dbSetOrder(1))
	SM0->(dbSeek(AllTrim(ZAK->ZAK_EMPPAG)))

	//Inicia a Pagina
	oPrint:StartPage()

	//  bloco 1 de  5
	If File(cLogo)
		oPrint:SayBitmap(0050, 040, cLogo, 070, 030)   // logo: ocupa colunas 040-110
	EndIf

	oPrint:Say(0050, 140, "Detalhe do Pagamento - Crédito em Conta Salário ", oFontTit, 260, 24, /*nClrText*/, 0, 0)

	oPrint:Say(0065, 140, "Data da operação:", oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0065, 250, cValToChar(ZAK->ZAK_DTOPER)+" - "+ZAK->ZAK_HROPER, oFontLabel, 350, 12, /*nClrText*/, 0, 0)

	oPrint:Say(0080, 140, "Número de controle:", oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0080, 250, ZAK->ZAK_AUTENT, oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Line(0100, 030, 0100, 560)

	//Bloco 2 de 5
	oPrint:Say(0120, 030, "Dados do Pagador", oFontLabN, 350, 12, /*nClrText*/, 0, 0)

	oPrint:Say(0150, 140, "Pagador: ", oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0150, 180, OemToAnsi(AllTrim(SM0->M0_NOMECOM)), oFontLabN, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0150, 380, " |   CNPJ/CPF: ", oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0150, 440, Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"), oFontLabN, 350, 12, /*nClrText*/, 0, 0)

	oPrint:Say(0170, 140, OemToAnsi("Convênio: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0170, 200, AllTrim(ZAK->ZAK_EMPCOV), oFontLabN, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0170, 240, OemToAnsi(" |  Agência: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0170, 300, AllTrim(ZAK->ZAK_EMPAGE), oFontLabN, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0170, 350, OemToAnsi(" |  Conta: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0170, 390, AllTrim(Transform(Val(ZAK->ZAK_EMPCON),"@R 99999-9")), oFontLabN, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Line(0190, 030, 0190, 560)

	//Terceiro Bloco de 5
	oPrint:Say(0210, 030, OemToAnsi("Dados do Funcionário"), oFontLabN, 350, 12, /*nClrText*/, 0, 0)

	oPrint:Say(0240, 140, OemToAnsi("Funcionário: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0240, 200, AllTrim(ZAK->ZAK_FUNNOM), oFontLabN, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0240, 380, OemToAnsi(" |   CNPJ/CPF: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0240, 455, Transform(ZAK->ZAK_FUNCPF,"@R 999.999.999-99"), oFontLabN, 350, 12, /*nClrText*/, 0, 0)

	oPrint:Say(0260, 140, OemToAnsi("Banco: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0260, 185, ZAK->ZAK_FUNBAN, oFontLabN, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0260, 210, OemToAnsi(" |  Agência: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0260, 260, ZAK->ZAK_FUNAGE, oFontLabN, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0260, 310, OemToAnsi(" |  Conta: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	If ZAK->ZAK_FUNBAN == "237"
		oPrint:Say(0260, 350, Transform(Val(ZAK->ZAK_FUNCON),"@R 99999-9"), oFontLabN, 350, 12, /*nClrText*/, 0, 0)
	Else
		oPrint:Say(0260, 350, ZAK->ZAK_FUNCON, oFontLabN, 350, 12, /*nClrText*/, 0, 0)
	End
	oPrint:Line(0280, 030, 0280, 560)

	//Quarto Bloco de 5
	oPrint:Say(0300, 030, OemToAnsi("Dados do Pagamento"), oFontLabN, 350, 12, /*nClrText*/, 0, 0)

	oPrint:Say(0320, 030, OemToAnsi("Número do Pagamento: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0320, 140, ZAK->ZAK_NROPAG, oFontLabN, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0320, 360, OemToAnsi("Data Prevista de Débito: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0320, 480, cValToChar(ZAK->ZAK_DTPREV), oFontLabN, 350, 12, /*nClrText*/, 0, 0)

	oPrint:Say(0340, 030, OemToAnsi("Data do Pagamento: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0340, 150, cValToChar(ZAK->ZAK_DTPAG), oFontLabN, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0340, 360, OemToAnsi("Data de Débito: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0340, 480, cValToChar(ZAK->ZAK_DTLANC), oFontLabN, 350, 12, /*nClrText*/, 0, 0)

	oPrint:Say(0360, 030, OemToAnsi("Valor do Pagamento: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0360, 150, Transform(ZAK->ZAK_VALPAG,"@ER 999,999,999.99"), oFontLabN, 350, 12, /*nClrText*/, 0, 0)

	oPrint:Say(0380, 030, OemToAnsi("Situação: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0380, 150, "PAGO", oFontLabN, 350, 12, /*nClrText*/, 0, 0)

	oPrint:Say(0400, 030, OemToAnsi("Motivo: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)

	oPrint:Say(0420, 030, OemToAnsi("Uso da Empresa: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)

	oPrint:Line(0440, 030, 0440, 560)

	//Quinto Bloco de 5
	oPrint:Say(0460, 030, OemToAnsi("Dados da Transferência "), oFontLabN, 350, 12, /*nClrText*/, 0, 0)

	oPrint:Say(0480, 140, OemToAnsi("Situação: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0480, 200, OemToAnsi("EFETUADA"), oFontLabN, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0480, 360, OemToAnsi("Banco Destino: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0480, 450, ZAK->ZAK_FUNBAN, oFontLabN, 350, 12, /*nClrText*/, 0, 0)

	oPrint:Say(0500, 140, OemToAnsi("Data: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0500, 360, OemToAnsi("Agência: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0500, 450, ZAK->ZAK_FUNAGE, oFontLabN, 350, 12, /*nClrText*/, 0, 0)

	oPrint:Say(0520, 140, OemToAnsi("Data de Devolução: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0520, 360, OemToAnsi("Conta Destino: "), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	If ZAK->ZAK_FUNBAN == "237"
		oPrint:Say(0520, 450, Transform(Val(ZAK->ZAK_FUNCON),"@R 99999-9"), oFontLabN, 350, 12, /*nClrText*/, 0, 0)
	Else
		oPrint:Say(0520, 450, ZAK->ZAK_FUNCON, oFontLabN, 350, 12, /*nClrText*/, 0, 0)
	End

	oPrint:Say(0540, 360, OemToAnsi("Tipo de Conta"), oFontLabel, 350, 12, /*nClrText*/, 0, 0)
	oPrint:Say(0540, 450, OemToAnsi("CONTA CORRENTE"), oFontLabN, 350, 12, /*nClrText*/, 0, 0)

	oPrint:EndPage()
	If cTipo == "V"
		oPrint:Preview()
	Else
		oPrint:Setup()
		oPrint:Print()
	End
	MS_FLUSH()

Return (NIL)


/*/{Protheus.doc} BRRELPAG
Gera preview PDF do retorno Bradesco com logo fixa do banco.
Para exibir a logo, mantenha o arquivo BRADESCO.BMP no StartPath do AppServer.
@type function Auxiliar
@version 1.00
@author marioantonaccio
@since 08/04/2026
@return character, sem retorno
/*/
User Function BRRELPAG()

	Local aParambox := {} as array

	Local nTipoFol:=1
	Local aTipoFol:={}
	Private aRet      := {} as array

	AADD(aTipoFol,OemToAnsi("FOL - Folha de Pagamento"))
	AADD(aTipoFol,OemToAnsi("ADI - Adiantamento"))
	AADD(aTipoFol,OemToAnsi("FER - Férias"))
	AADD(aTipoFol,OemToAnsi("131 - 1a. Parcela 13o. Salário"))
	AADD(aTipoFol,OemToAnsi("132 - 2a. Parcela 13o. Salário"))
	AADD(aTipoFol,OemToAnsi("RES - Rescisão"))
	/*
AADD(aTipoFOl,OemToAnsi("AUT - Autônomos"))
AADD(aTipoFOl,OemToAnsi("BEN - Outros Benefícios"))
AADD(aTipoFOl,OemToAnsi("INC - Salário Incorporado"))
AADD(aTipoFOl,OemToAnsi("MUV - Múltiplos Vínculos"))
AADD(aTipoFOl,OemToAnsi("PLA - Plano de Saúde"))
AADD(aTipoFOl,OemToAnsi("PLR - Part Lucros/Resultados"))
AADD(aTipoFOl,OemToAnsi("RTF - Retificadora"))
AADD(aTipoFOl,OemToAnsi("VAL - Vale-Alimentação"))
AADD(aTipoFOl,OemToAnsi("VEX - Valores Extras"))
AADD(aTipoFOl,OemToAnsi("VRF - Vale-Refeição"))
AADD(aTipoFOl,OemToAnsi("VTR - Vale-Transporte"))
	*/
	aadd(aParambox, {1, "Da Filial "           , Space(TamSX3("ZAK_FILIAL")[1]) , ""  , "" , "SM0", "" , 0 , .F.})
	aadd(aParambox, {1, "Ate Filial "          , Space(TamSX3("ZAK_FILIAL")[1]) , ""  , "" , "SM0", "" , 0 , .F.})
	aadd(aParambox, {1, "Do Funcionário (CPF)" , Space(TamSX3("ZAK_FUNCPF")[1]) , ""  , "" , "ZAK", "" , 0 , .F.})
	aadd(aParambox, {1, "Ate Funcionário (CPF)", Space(TamSX3("ZAK_FUNCPF")[1]) , ""  , "" , "ZAK", "" , 0 , .F.})
	aadd(aParambox, {1, "Do Ano/Mes "          , Space(TamSX3("ZAK_FILIAL")[1]) , ""  , "" , ""   , "" , 0 , .F.})
	aadd(aParambox, {1, "Ate Ano/Mes "         , Space(TamSX3("ZAK_FILIAL")[1]) , ""  , "" , ""   , "" , 0 , .F.})
	aadd(aParambox, {2, "Tipo de Folha"        , nTipoFol                       , aTipoFol, 090, ".T.", .F.})


	If Parambox(aParambox, "Informe os Parametros", @aRet)
		aRet[7]:=Substr(aTipofol[nTipoFol],1,3)
		Processa({||BRRELPAG01(@aRet)})
	EndIf

Return(NIL)

Static Function BRRELPAG01(aRet)
	Local oPrint    := NIL
	Local oFontTit  := NIL
	Local oFontCab  := NIL
	Local oFontDet  := NIL
	Local oFontRod  := NIL
	Local cArquivo  := ""  as character
	Local cLogo     := ""  as character
	Local nLin      := 1   as numeric
	Local nLinFim   := 520 as numeric
	Local nPag      := 1   as numeric
	Local nCount       := 0   as numeric
	Local nTotal       := 0   as numeric

	//Query de Selecao
	If Select("XZAK")
		XZAK->(dbCloseArea())
	End

	BeginSQL Alias "XZAK"
		SELECT
			ZAK_EMPPAG,
			ZAK_EMPCNP,
			ZAK_EMPBAN,
			ZAK_EMPAGE,
			ZAK_EMPCON,
			ZAK_FUNNOM,
			ZAK_FUNCPF,
			ZAK_FUNBAN,
			ZAK_FUNAGE,
			ZAK_FUNCON,
			ZAK_FUNTIP,
			ZAK_DTLANC,
			ZAK_DTPAG,
			ZAK_VALPAG,
			ZAK_AUTENT
		FROM
			%TABLE:ZAK%
		WHERE
			%NOTDEL%
			AND ZAK_FILIAL >= %EXP:aRet[01]%
			AND ZAK_FILIAL <= %EXP:aRet[02]%
			AND ZAK_FUNCPF >= %EXP:aRet[03]%
			AND ZAK_FUNCPF <= %EXP:aRet[04]%
			AND ZAK_ANOMES >= %EXP:aRet[05]%
			AND ZAK_ANOMES <= %EXP:aRet[06]%
			AND ZAK_FUNTIP = %EXP:aRet[07]%
		ORDER BY
			ZAK_FILIAL,
			ZAK_FUNCPF
	EndSQL

	nCount:=CONTAR("XZAK",".NOT. EOF()")
	XZAK->(dbGoTop())
	If nCount == 0
		XZAK->(dbCloseArea())
		FWAlertError("NAo Existem Registros para os paramentros informados! Verifique!","Sem Dados")
		Return(NIL)
	End

	cArquivo := "BRRELPAG_" + DToS(Date()) + "_" + StrTran(Time(), ":", "")
	cLogo    := GetSrvProfString("StartPath", "") + "BRADESCO.BMP"

	oFontTit := TFont():New("Arial", 9, -16, .T., .T., 5, .T., 5, .T., .F.)
	oFontCab := TFont():New("Arial", 9, -10, .T., .T., 5, .T., 5, .T., .F.)
	oFontDet := TFont():New("Arial", 9, -09, .T., .F., 5, .T., 5, .T., .F.)
	oFontRod := TFont():New("Arial", 9, -08, .T., .F., 5, .T., 5, .T., .F.)

	oPrint := FWMSPrinter():New(cArquivo, IMP_PDF, .F., "", .T., , @oPrint, "", , , , .T.)
	oPrint:SetResolution(72)
	oPrint:SetLandscape()
	oPrint:SetPaperSize(DMPAPER_A4)
	oPrint:SetMargin(40, 40, 40, 40)
	oPrint:cPathPDF := SuperGetMv("BR_DRIMPLO",.F.,"c:\spool\")
	//oPrint:SetViewPDF(.T.)

	While .NOT. XZAK->(EOF())
		IncProc()
		If nLin == 1 .OR. nLin > nLinFim
			If nLin > 1
				BRRELPAG03(oPrint, oFontRod, nPag)
				nPag++
			EndIf
			BRRELPAG02(oPrint, oFontTit, oFontCab, cLogo)
			nLin := 105
		EndIf

		oPrint:SayAlign(nLin, 040, XZAK->ZAK_FUNCON , oFontDet, 080, 10, /*nClrText*/, 0, 0)
		oPrint:SayAlign(nLin, 125, Substr(XZAK->ZAK_FUNNOME,1,34), oFontDet, 180, 10, /*nClrText*/, 0, 0)
		oPrint:SayAlign(nLin, 310, Transform(XZAK->ZAK_FUNCPF,"@R 999.999.999-99"), oFontDet, 180, 10, /*nClrText*/, 0, 0)
		oPrint:SayAlign(nLin, 370, XZAK->ZAK_FUNTIP, oFontDet, 035, 10, /*nClrText*/, 2, 0)
		oPrint:SayAlign(nLin, 410, cValToChar(STOD(XZAK->ZAK_DTLANC)), oFontDet, 060, 10, /*nClrText*/, 2, 0)
		oPrint:SayAlign(nLin, 475, cValToChar(STOD(XZAK->ZAK_DTPAG)), oFontDet, 060, 10, /*nClrText*/, 2, 0)
		oPrint:SayAlign(nLin, 520, Transform(XZAK->ZAK_VALPAG,"@ER 999,999,999.99"), oFontDet, 090, 10, /*nClrText*/, 1, 0)
		oPrint:SayAlign(nLin, 615, XZAK->ZAK_AUTENT, oFontDet, 170, 10, /*nClrText*/, 0, 0)
		nLin += 12

		nTotal+=XZAK->ZAK_VALPAG

		XZAK->(dbSkip())

	End

	XZAK->(dbCloseArea())

	oPrint:Line(nLin + 4, 040, nLin + 4, 745)
	nLin += 10
	oPrint:SayAlign(nLin, 475, "TOTAL", oFontCab, 080, 10, /*nClrText*/, 1, 0)
	oPrint:SayAlign(nLin, 520, Transform(nTotal, "@E 999,999,999.99"), oFontCab, 090, 10, /*nClrText*/, 1, 0)

	BRRELPAG03(oPrint, oFontRod, nPag)

	oPrint:Preview()

Return (NIL)

/*/{Protheus.doc} BRRELPAG02
Imprime cabecalho do relatorio Bradesco.
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 20/07/2026
@param oPrint, object, Obejto Relatorio
@param oFontTit, object, Objeto Fonte do Titulo
@param oFontCab, object, Objeto Fonte do Cabecalho
@param cLogo, character, Caminho do Logo
@return character, sem retorno
/*/
Static Function BRRELPAG02(oPrint, oFontTit, oFontCab, cLogo)

	oPrint:StartPage()

	If File(cLogo)
		oPrint:SayBitmap(020, 040, cLogo, 055, 028)
	EndIf
	oPrint:SayAlign(025, 110, "Retorno Bancario Bradesco", oFontTit, 280, 18, /*nClrText*/, 0, 0)
	oPrint:SayAlign(045, 110, "Empresa Pagadora: ", oFontCab, 280, 18, /*nClrText*/, 0, 0)
	oPrint:SayAlign(045, 220, Posicione("SM0",1,XZAK->ZAK_EMPPAG,"M0_NOMECOM"), oFontCab, 280, 18, /*nClrText*/, 0, 0)
	oPrint:SayAlign(045, 420, "CNPJ: ", oFontCab, 280, 18, /*nClrText*/, 0, 0)
	oPrint:SayAlign(045, 450, Transform(ZAK->ZAK_EMPCNP,"@R 99.999.999/9999-99"), oFontCab, 280, 18, /*nClrText*/, 0, 0)

	oPrint:SayAlign(065, 110, "Banco / Agencia / Conta Pagadora: ", oFontCab, 280, 18, /*nClrText*/, 0, 0)
	oPrint:SayAlign(065, 350, XZAK->ZAK_EMPBAN+ " / "+ XZAK->ZAK_EMPAGE+ " / "+ Transform(VAL(XZAK->ZAK_EMPCON),"@R 99999-9"), oFontCab, 280, 18, /*nClrText*/, 0, 0)

	oPrint:Line(082, 040, 082, 745)

	oPrint:SayAlign(090, 040, "CONTA", oFontCab, 080, 10, /*nClrText*/, 0, 0)
	oPrint:SayAlign(090, 125, "NOME", oFontCab, 180, 10, /*nClrText*/, 0, 0)
	oPrint:SayAlign(090, 300, "CPF", oFontCab, 035, 10, /*nClrText*/, 2, 0)
	oPrint:SayAlign(090, 370, "TIPO", oFontCab, 035, 10, /*nClrText*/, 2, 0)
	oPrint:SayAlign(090, 410, "DT LANC.", oFontCab, 060, 10, /*nClrText*/, 2, 0)
	oPrint:SayAlign(090, 475, "DT CRED.", oFontCab, 060, 10, /*nClrText*/, 2, 0)
	oPrint:SayAlign(090, 520, "VALOR", oFontCab, 090, 10, /*nClrText*/, 1, 0)
	oPrint:SayAlign(090, 615, "AUTENTICACAO", oFontCab, 170, 10, /*nClrText*/, 0, 0)

	oPrint:Line(102, 040, 102, 745)

Return (NIL)

/*/{Protheus.doc} BRRELPAG03
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
Static Function BRRELPAG03(oPrint, oFontRod, nPag)

	oPrint:Line(555, 040, 555, 745)

	oPrint:SayAlign(560, 040, DToC(Date()) + " " + Time() + "  " + FunName(), oFontRod, 250, 10, , 0, 0)
	oPrint:SayAlign(560, 680, "Pagina " + cValToChar(nPag), oFontRod, 065, 10, , 1, 0)

	oPrint:EndPage()

Return (NIL)
