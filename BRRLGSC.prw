#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
/*/{Protheus.doc} BRRLGSC
Relatorio de log de alterações em solicitações
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 29/01/2026
@return character, sem retorno
/*/
User Function BRRLGSC()

	Local aArea       := FWGetArea() as Array
	Private aGrp      := {}          as Array
	Private aPerg     := {}          as Array
	Private aSVend    := {}          as Array
	Private cPerg     := "BRRLLOGSC" as Character
	Private lEmail    := .F.         as Logical
	Private lRet      := .T.         as Logical
	Private nAlterGer := 0           as Numeric
	Private nAlterSC  := 0           as Numeric
	Private oReport                  as Object
	Private oSecFor                  as Object
	Private oSecSC                   as Object
	Default cDef01    := Space(15)
	Default cDef02    := Space(15)
	Default cDef03    := Space(15)
	Default cDef04    := Space(15)
	Default cDef05    := Space(15)
	Default cF3       := Space(06)
	Default cHelp     := ""
	Default cPicture  := Space(40)
	Default cValid    := Space(60)

	If .NOT. FWSX1Util():ExistPergunte(cPerg)

		AADD(aPerg,{cPerg, "01", "Da Solicitação?"	, "MV_PAR01", "MV_CH0", "C", TamSX3( 'C1_NUM' )[01]		, 0, "G",cValid , "SC8", cPicture, cDef01, cDef02, cDef03, cDef04, cDef05,0,"Informe a Solicitacao inicial"})
		AADD(aPerg,{cPerg, "02", "Ate Solicitação?"	, "MV_PAR02", "MV_CH1", "C", TamSX3( 'C1_NUM' )[01]		, 0, "G",cValid , "SC8", cPicture, cDef01, cDef02, cDef03, cDef04, cDef05,0,"Informe a Solicitacao final"})
		AADD(aPerg,{cPerg, "07", "Do Produto ?"		, "MV_PAR03", "MV_CH2", "C", TamSX3( 'B1_COD' )[01]		, 0, "G",cValid , "SB1", cPicture, cDef01, cDef02, cDef03, cDef04, cDef05,0,"Informe o produto inicial"})
		AADD(aPerg,{cPerg, "08", "Ate Produto?"		, "MV_PAR04", "MV_CH3", "C", TamSX3( 'B1_COD' )[01]		, 0, "G",cValid , "SB1", cPicture, cDef01, cDef02, cDef03, cDef04, cDef05,0,"Informe o produto final"})
		brPutSX1(aPerg)
	Else
		If .NOT. Pergunte(cPerg,.T.)
			Return(NIL)
		End
	End
	//Cria as definições do relatório
	oReport := ReportDef()

	//Será enviado por e-Mail?
	If lEmail
		oReport:nRemoteType := NO_REMOTE
		oReport:cEmail := cPara
		oReport:nDevice := 3 //1-Arquivo,2-Impressora,3-email,4-Planilha e 5-Html
		oReport:SetPreview(.F.)
		oReport:Print(.F., "", .T.)
		//Senão, mostra a tela
	Else
		oReport:PrintDialog()
	EndIf

	FWRestArea(aArea)

Return (NIL)

/*/{Protheus.doc} ReportDef
Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS  monta a janela com a regua de processamento.
@type function Processamento
@version  1.0
@author marioantonaccio
@since 30/01/2026
@return object, Objeto Report
/*/
Static Function ReportDef()

	Local cTitle  as Character
	Local oReport as Object

    cTitle := "Histórico de Alteração de Solicitacao de Compras (LOG SC p/PP)"
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
	oReport:=TReport():New("BRRLLOGSC",cTitle,"BRRLLOGSC", {|oReport| _FQuery(),RPrintCom(oReport)},;
		"Este programa emite o Relatorio de LOG de Alteracao de Solicitação de Compras por ponto de Pedido de acordo com os parametros informados.")

	oReport:lParamPage:=.F.
	oReport:lTotalInLine:=.F.
	oReport:SetLandScape()
	oReport:nFontBody := 8
	oReport:nLineHeight := 30
	oReport:lDisableOrientation:=.F.
	oReport:nEnvironment:=2
	oReport:lEdit:=.F.
	oReport:SetLeftMargin(1)

	//*-------------------------------------------------------------------------
	//³Criacao da secao utilizada pelo relatorio                               ³
	//³                                                                        ³
	//³TRSection():New                                                         ³
	//³ExpO1 : Objeto TReport que a secao pertence                             ³
	//³ExpC2 : Descricao da seçao                                              ³
	//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
	//³        sera considerada como principal para a seção.                   ³
	//³ExpA4 : Array com as Ordens do relatório                                ³
	//³ExpL5 : Carrega campos do SX3 como celulas                              ³
	//³        Default : False                                                 ³
	//³ExpL6 : Carrega ordens do Sindex                                        ³
	//³        Default : False                                                 ³
	//³                                                                        ³
	//*-------------------------------------------------------------------------
	oSecSC:= TRSection():New(oReport,"Solicitação")
	oSecSC:SetHeaderPage()
	oSecSC:nLinesBefore := 0
	oSecPR:= TRSection():New(oReport,"Produto")
	oSecPR:SetHeaderPage()
	oSecPR:nLinesBefore := 0

Return(oReport)

/*/{Protheus.doc} RPrintCom
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
Static Function RPrintCom(oReport)

	Local cTitulo       := oReport:Title()    as Object
	Local oSecSC        := oReport:Section(1) as Object
	Local oSecPR        := oReport:Section(2) as Object
	Private lEndPage    := .F.                as Logical
	Private lEndRep     := .T.                as Logical
	Private lEndReport  := .T.                as Logical
	Private lEndSection := .T.                as Logical

	oSecSC := oReport:Section(1)
	oSecPR := oReport:Section(2)

	//*-------------------------------------------------------------------------
	//³Criacao da celulas da secao do relatorio                                ³
	//³                                                                        ³
	//³TRCell():New                                                            ³
	//³ExpO1 : Objeto TSection que a secao pertence                            ³
	//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
	//³ExpC3 : Nome da tabela de referencia da celula                          ³
	//³ExpC4 : Titulo da celula                                                ³
	//³        Default : X3Titulo()                                            ³
	//³ExpC5 : Picture                                                         ³
	//³        Default : X3_PICTURE                                            ³
	//³ExpC6 : Tamanho                                                         ³
	//³        Default : X3_TAMANHO                                            ³
	//³ExpL7 : Informe se o tamanho esta em pixel                              ³
	//³        Default : False                                                 ³
	//³ExpB8 : Bloco de código para impressao.                                 ³
	//³        Default : ExpC2                                                 ³
	//³                                                                        ³
	//*-------------------------------------------------------------------------
	//³Montagem dos Objetos para a quebra por tipo  ³
	//TRCell():New(oSecSC,"NPROD"		,"   ","Desc.Produto"	,"@!",TamSX3('B1_DESC')[01]			,/*lPixel*/,{||Substr(GetAdvFVal("SB1", "B1_DESC", xFilial("SB1") + XDEM->ZAJ_PROD, 1, " ",.F.),1,30)},"LEFT")
	TRCell():New(oSecSC,"NCAMPO"		,"   ","Campo Alterado"	," ",20								,/*lPixel*/,{||RetTitle(XDEM->ZAJ_CAMPO)},"LEFT")
	TRCell():New(oSecSC,"ZAJ_DE"		,"   ","DE"				,"@!",TamSX3("ZAJ_DE")[01]+5		,/*lPixel*/,{||XDEM->ZAJ_DE},"LEFT")
	TRCell():New(oSecSC,"ZAJ_PARA"		,"   ","PARA"			,"@!",TamSX3("ZAJ_PARA")[01]		,/*lPixel*/,{||XDEM->ZAJ_PARA},"LEFT")
	TRCell():New(oSecSC,"ZAJ_SEQ"		,"   ","Seq."			,"@!",TamSX3("ZAJ_SEQ")[01]+3	 	,/*lPixel*/,{||XDEM->ZAJ_SEQ},"LEFT")
	TRCell():New(oSecSC,"ZAJ_DTALT"	,"   ","Data Alter"		,"@D",TamSX3("ZAJ_DTALT")[01]+5		,/*lPixel*/,{||XDEM->ZAJ_DTALT},"LEFT")
	TRCell():New(oSecSC,"ZAJ_HORA"		,"   ","Hora Alter"		,"@!",TamSX3("ZAJ_HORA")[01]+5		,/*lPixel*/,{||XDEM->ZAJ_HORA},"LEFT")
	TRCell():New(oSecSC,"ZAJ_USRALT"	,"   ","Usuario Alt"	," ",TamSX3("ZAJ_USRALT")[01]		,/*lPixel*/,{||XDEM->ZAJ_USRALT},"LEFT")

	// Quebra 1 - Solicitacao
	oBreak1 := TRBreak():New(oSecSC,{|| (XDEM->ZAJ_NUMERO) },"No.Solicitação")
	oBreak2 := TRBreak():New(oSecPr,{|| (XDEM->ZAJ_PROD) },"Produto")

	oReport:SetTotalInLine(.F.)
	oReport:lUnderLine := .F.

	dbSelectArea("XDEM")
	nCount:=Contar("XDEM",".NOT. EOF()")
	XDEM->(dbGotop())

	// Titulo
	oReport:SetTitle(cTitulo)

	// Regua
	oReport:SetMeter(nCount)

	// Esconde a Secao referente a Filial para impressao somente dos totais
	oReport:cFontBody := 'Courier New'
	oReport:nFontBody := 6
	oReport:EndReport(.F.)

	oSecSC:lHeaderSection := .T.
	oSecPR:Hide()
	oSecPR:lHeaderSection := .T.

	While .NOT. oReport:Cancel() .And. .NOT. XDEM->(EOF())

		If oReport:Cancel()
			Exit
		EndIf

		cNumSC:=XDEM->ZAJ_NUMERO

		//	oReport:SayBitmap(01,01,"BRASILUX.BMP")
		oReport:SetMsgPrint("Imprimindo Solicitação...."+cNumSC)
		oReport:SkipLine()

		oReport:PrintText("Solicitação: "+cNumSC)
		oReport:SkipLine()

		oSecSC:Init()

		While 	.NOT. oReport:Cancel() .And. ;
				.NOT. XDEM->(Eof()) .and.;
				XDEM->ZAJ_NUMERO == cNumSC

			If oReport:Cancel()
				Exit
			EndIf

			cProd:=XDEM->ZAJ_PROD

			cLinha:="Cod.Prod."+XDEM->ZAJ_PROD+"-"+Substr(GetAdvFVal("SB1", "B1_DESC", xFilial("SB1") + XDEM->ZAJ_PROD, 1, " ",.F.),1,30)
			oReport:PrintText(cLinha)
			oReport:SkipLine()
			oSecPR:Init()
			While .NOT. oReport:Cancel() .And.;
					.NOT. XDEM->(Eof()) .and.;
					XDEM->ZAJ_NUMERO == cNumSC .and.;
					XDEM->ZAJ_PROD == cProd

				If oReport:Cancel()
					Exit
				EndIf

				oReport:IncMeter()

				oSecSC:PrintLine()
				If oReport:nDevice == 4 .And. oSecSC:lHeaderSection
					oReport:lHeaderVisible := .F.
					oSecVend:lHeaderSection := .F.
				EndIf
				nAlterGer++
				nAlterSC++

				XDEM->(DbSkip())

			End

			oSecPR:Finish()
			oReport:SkipLine()
			oReport:ThinLine()
			oReport:SkipLine()
			oReport:SkipLine()

		End

		oSecSC:Finish()
		oReport:SkipLine()
		oReport:SkipLine()
		oReport:PrintText("Total Alteracoes na Solicitação "+cNumSC+": "+cValtoChar(nAlterSC))
		oReport:SkipLine()
		oReport:FATLine()
		oReport:SkipLine()
		oReport:SkipLine()
		nAlterSC:=0
		dbSelectArea("XDEM")

	End

	oReport:Finish()
	oReport:SkipLine()
	oReport:SkipLine()
	oReport:PrintText("Total Alteracoes no Geral: "+cValtoChar(nAlterGer))

	If Select ("XDEM") > 0
		XDEM->(DbCloseArea())
	EndIf

Return (NIL)

/*/{Protheus.doc} _FQuery
Motagem Uqry para filtro
@type function Processamento
@version  1.0
@author marioantonaccio
@since 30/01/2026
@return character, sem retorno
/*/
Static Function _FQuery()

	//Montando consulta de dados
	BeginSql Alias "XDEM"
		COLUMN ZAJ_DTALT AS DATE
		SELECT
			ZAJ_FILIAL,
			ZAJ_NUMERO,
			ZAJ_PROD,
			ZAJ_CAMPO,
			ZAJ_DE,
			ZAJ_PARA,
			ZAJ_SEQ,
			ZAJ_DTALT,
			ZAJ_HORA,
			ZAJ_USRALT
		FROM
			%TABLE:ZAJ%
		WHERE
			%NOTDEL%
			AND ZAJ_NUMERO >= %EXP:mv_par01%
			AND ZAJ_NUMERO <= %EXP:mv_par02%
			AND ZAJ_PROD >= %EXP:mv_par03%
			AND ZAJ_PROD <= %EXP:mv_par04%
			AND ZAJ_TIPO = 'SC'
		ORDER BY
			ZAJ_NUMERO,
			ZAJ_PROD
	EndSQL

Return (NIL)

/*/{Protheus.doc} BRPUTSX1
Grava  Perguntas na SX1
@type function Processamento
@version  1.00
@author marioantonaccio
@since 13/02/2026
@param aPerg, array, array com as perguntas
@return character, sem retorno
/*/
Static Function BRPUTSX1(aPerg)
	Local nI:=1

	//Criação de Perguntas
	SX1->(dbSetOrder(1))
	For nI:=1 To Len(aPerg)
		If .NOT. SX1->(DbSeek(aPerg[nI][01] + aPerg[nI][02]))
			RecLock('SX1', .T.)
		Else
			RecLock('SX1', .F.)
		End
		X1_GRUPO   := aPerg[nI][01]
		X1_ORDEM   := aPerg[nI][02]
		X1_PERGUNT := aPerg[nI][03]
		X1_PERSPA  := aPerg[nI][03]
		X1_PERENG  := aPerg[nI][03]
		X1_VAR01   := aPerg[nI][04]
		X1_VARIAVL := aPerg[nI][05]
		X1_TIPO    := aPerg[nI][06]
		X1_TAMANHO := aPerg[nI][07]
		X1_DECIMAL := aPerg[nI][08]
		X1_GSC     := aPerg[nI][09]
		X1_VALID   := aPerg[nI][10]
		X1_F3      := aPerg[nI][11]
		X1_PICTURE := aPerg[nI][12]
		X1_DEF01   := aPerg[nI][13]
		X1_DEFSPA1 := aPerg[nI][13]
		X1_DEFENG1 := aPerg[nI][13]
		X1_DEF02   := aPerg[nI][14]
		X1_DEFSPA2 := aPerg[nI][14]
		X1_DEFENG2 := aPerg[nI][14]
		X1_DEF03   := aPerg[nI][15]
		X1_DEFSPA3 := aPerg[nI][15]
		X1_DEFENG3 := aPerg[nI][15]
		X1_DEF04   := aPerg[nI][16]
		X1_DEFSPA4 := aPerg[nI][16]
		X1_DEFENG4 := aPerg[nI][17]
		X1_DEF05   := aPerg[nI][18]
		X1_DEFSPA5 := aPerg[nI][18]
		X1_DEFENG5 := aPerg[nI][18]
		X1_PRESEL  := aPerg[nI][19]

		//Se tiver Help da Pergunta
		If .NOT. Empty(cHelp)
			X1_HELP    := ""
			fPutHelp(cChaveHelp, cHelp)
		EndIf
		SX1->(MsUnlock())
	Next
Return (NIL)
