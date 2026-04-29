#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
/*/{Protheus.doc} abc
Relatorio de log de alterações em cotações
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 29/01/2026
@return character, sem retorno
/*/
User Function BRRLGCOT()

	Local aArea       := FWGetArea()  as Array
	Local lEmail      := .F.          as Logical
	Local oReport                     as Object
	Private aGrp      := {}           as Array
	Private aSVend    := {}           as Array
	Private cPerg     := "BRRLLOGCOT" as Character
	Private lRet      := .T.          as Logical
	Private nAlterCot := 0            as Numeric
	Private nAlterFor := 0            as Numeric
	Private nAlterGer := 0            as Numeric
	Private oSecCot                   as Object
	Private oSecFor                   as Object

	If .NOT. FWSX1Util():ExistPergunte(cPerg)
		//Criação de Perguntas
		AADD(aPerg,{cPerg, "01", "Da Cotacao ?"		, "MV_PAR01", "MV_CH0", "C", TamSX3( 'C8_NUM' )[01]		, 0, "G", cValid, "SC8", cPicture, cDef01, cDef02, cDef03, cDef04, cDef05, 0,"Informe a cotação inicial"})
		AADD(aPerg,{cPerg, "02", "Ate Cotacao?"		, "MV_PAR02", "MV_CH1", "C", TamSX3( 'C8_NUM' )[01]		, 0, "G", cValid, "SC8", cPicture, cDef01, cDef02, cDef03, cDef04, cDef05, 0,"Informe a cotacao final"})
		AADD(aPerg,{cPerg, "03", "Do Fornecedor ?"	, "MV_PAR03", "MV_CH2", "C", TamSX3( 'A2_COD')[01]		, 0, "G", cValid, "SA2", cPicture, cDef01, cDef02, cDef03, cDef04, cDef05, 0,"Informe o Fornecedor inicial"})
		AADD(aPerg,{cPerg, "04", "Ate Fornecedor?"	, "MV_PAR04", "MV_CH3", "C", TamSX3( 'A2_COD')[01]		, 0, "G", cValid, "SA2", cPicture, cDef01, cDef02, cDef03, cDef04, cDef05, 0,"Informe o Fornecedor final"})
		AADD(aPerg,{cPerg, "05", "Da Loja Fornece?"	, "MV_PAR05", "MV_CH4", "C", TamSX3( 'A2_LOJA' )[01]	, 0, "G", cValid, "SA2", cPicture, cDef01, cDef02, cDef03, cDef04, cDef05, 0,"Informe a Loja Fornecedor inicial"})
		AADD(aPerg,{cPerg, "06", "Ate Loja Fornece?", "MV_PAR06", "MV_CH5", "C", TamSX3( 'A2_LOJA' )[01]	, 0, "G", cValid, "SA2", cPicture, cDef01, cDef02, cDef03, cDef04, cDef05, 0,"Informe a Loja Fornecedor final"})
		AADD(aPerg,{cPerg, "07", "Do Produto ?"		, "MV_PAR07", "MV_CH6", "C", TamSX3( 'B1_COD' )[01]		, 0, "G", cValid, "SB1", cPicture, cDef01, cDef02, cDef03, cDef04, cDef05, 0,"Informe o produto inicial"})
		AADD(aPerg,{cPerg, "08", "Ate Produto?"		, "MV_PAR08", "MV_CH7", "C", TamSX3( 'B1_COD' )[01]		, 0, "G", cValid, "SB1", cPicture, cDef01, cDef02, cDef03, cDef04, cDef05, 0,"Informe o produto final"})

		u_zPutSX1(aPerg)
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

	Local cTitle := "Histórico de negociação de compras (LOG COTACAO)" as Character
	Local oReport                                                      as Object
	Local oSecFor                                                      as Object

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
	oReport:=TReport():New("BRRLLOGCOT",cTitle,"BRRLLOGCOT", {|oReport| _FQuery(),RPrintCom(oReport)},;
		"Este programa emite o Relatorio de LOG de Alteracao de Cotação de acordo com os parametros informados.")

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
	oSecCod:= TRSection():New(oReport,"Cotacao")
	oSecCod:SetHeaderPage()
	oSecCod:nLinesBefore := 0

	oSecFor:= TRSection():New(oReport,"Fornecedor")
	oSecFor:SetHeaderPage()
	oSecFor:nLinesBefore := 0

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
oSecCot:Cell("NQTD"):Hide()
/*/
Static Function RPrintCom(oReport)

	Local cTitulo       := oReport:Title()    as Object
	Local oSecCot       := oReport:Section(2) as Object
	Private lEndPage    := .F.                as Logical
	Private lEndRep     := .T.                as Logical
	Private lEndReport  := .T.                as Logical
	Private lEndSection := .T.                as Logical

	oSecFor := oReport:Section(2)
	oSecCot := oReport:Section(1)

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
	//	TRCell():New(oSecCot,"ZAJ_NUMERO"	,"   ","No.Cotacao"		,"@!",TamSX3('C8_NUM' )[01]		,/*lPixel*/,{||XDEM->ZAJ_NUMERO},"LEFT")
	//	TRCell():New(oSecCot,"ZAJ_FORNEC"	,"   ","Cod.Fornec"		,"@!",TamSX3('A2_COD' )[01]		,/*lPixel*/,{||XDEM->ZAJ_FORNEC},"LEFT")
	//	TRCell():New(oSecCot,"ZAJ_LOJA"		,"   ","Lj Fornec"		,"@!",TamSX3('A2_LOJA')[01]		,/*lPixel*/,{||XDEM->ZAJ_LOJA},"LEFT")
	//	TRCell():New(oSecCot,"NFORNEC"	 	,"   ","Nome Fornecedor","@!",TamSX3('A2_NOME')[01]		,/*lPixel*/,{||Posicione("SA2",1,XDEM->ZAJ_FORNEC+XDEM->ZAJ_LOJA,"A2_NOME")},"LEFT")
	//TRCell():New(oSecCot,"ZAJ_PROD"		,"   ","Cod.Prod."		,"@!",TamSX3('B1_COD') [01]		,/*lPixel*/,{||XDEM->ZAJ_PROD},"LEFT")
	//TRCell():New(oSecCot,"NPROD"		,"   ","Desc.Produto"	,"@!",TamSX3('B1_DESC')[01]			,/*lPixel*/,{||Substr(GetAdvFVal("SB1", "B1_DESC", xFilial("SB1") + XDEM->ZAJ_PROD, 1, " ",.F.),1,30)},"LEFT")
	TRCell():New(oSecCot,"NCAMPO"		,"   ","Campo Alterado"	," ",20								,/*lPixel*/,{||RetTitle(XDEM->ZAJ_CAMPO)},"LEFT")
	TRCell():New(oSecCot,"ZAJ_DE"		,"   ","DE"				,"@!",TamSX3("ZAJ_DE")[01]+5		,/*lPixel*/,{||XDEM->ZAJ_DE},"LEFT")
	TRCell():New(oSecCot,"ZAJ_PARA"		,"   ","PARA"			,"@!",TamSX3("ZAJ_PARA")[01]		,/*lPixel*/,{||XDEM->ZAJ_PARA},"LEFT")
	TRCell():New(oSecCot,"ZAJ_SEQ"		,"   ","Seq."			,"@!",TamSX3("ZAJ_SEQ")[01]+3	 	,/*lPixel*/,{||XDEM->ZAJ_SEQ},"LEFT")
	TRCell():New(oSecCot,"ZAJ_DTALT"	,"   ","Data Alter"		,"@D",TamSX3("ZAJ_DTALT")[01]+5		,/*lPixel*/,{||XDEM->ZAJ_DTALT},"LEFT")
	TRCell():New(oSecCot,"ZAJ_HORA"		,"   ","Hora Alter"		,"@!",TamSX3("ZAJ_HORA")[01]+5		,/*lPixel*/,{||XDEM->ZAJ_HORA},"LEFT")
	TRCell():New(oSecCot,"ZAJ_USRALT"	,"   ","Usuario Alt"	," ",TamSX3("ZAJ_USRALT")[01]		,/*lPixel*/,{||XDEM->ZAJ_USRALT},"LEFT")

	// Quebra 1 - Cotacao
	oBreak1 := TRBreak():New(oSecCot,{|| (XDEM->ZAJ_NUMERO) },"No.Cotacao")

	// Quebra 2 - Fornecedor
	oBreak2 := TRBreak():New(oSecFor,{|| (XDEM->ZAJ_FORNEC+XDEM->ZAJ_LOJA) },"Fornecedor+Loja")

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

	oSecFor:Hide()
	oSecFor:lHeaderSection:= .F.
	oSecCot:lHeaderSection := .T.

	While .NOT. oReport:Cancel() .And. .NOT. XDEM->(EOF())

		If oReport:Cancel()
			Exit
		EndIf

		cNumCot:=XDEM->ZAJ_NUMERO

		//	oReport:SayBitmap(01,01,"BRASILUX.BMP")
		oReport:SetMsgPrint("Imprimindo Cotacao...."+cNumCot)
		oReport:SkipLine()

		oReport:PrintText("Cotacao: "+cNumCot)
		oReport:SkipLine()

		oSecCot:Init()

		While 	.NOT. oReport:Cancel() .And. ;
				.NOT. XDEM->(Eof()) .and.;
				XDEM->ZAJ_NUMERO == cNumCot

			If oReport:Cancel()
				Exit
			EndIf

			cFornece:=XDEM->ZAJ_FORNEC
			cLoja:=XDEM->ZAJ_LOJA

			oSecFor:Init()

			cLinha:="Fornecedor: "+cFornece
			cLinha+="  Loja: "+cLoja
			cLinha+="  Nome: "+GetAdvFVal("SA2", "A2_NOME", xFilial("SA2") + cFornece+cLoja, 1, " ",.F.)
			oReport:PrintText(cLinha)
			oReport:SkipLine()

			While .NOT. oReport:Cancel() .And.;
					.NOT. XDEM->(Eof()) .and.;
					XDEM->ZAJ_FORNEC == cFornece .and.;
					XDEM->ZAJ_LOJA == cLoja .and.;
					XDEM->ZAJ_NUMERO == cNumCot

				If oReport:Cancel()
					Exit
				EndIf

				cProd:=XDEM->ZAJ_PROD

				cLinha:="Cod.Prod."+XDEM->ZAJ_PROD+"-"+Substr(GetAdvFVal("SB1", "B1_DESC", xFilial("SB1") + XDEM->ZAJ_PROD, 1, " ",.F.),1,30)
				oReport:PrintText(cLinha)
				oReport:SkipLine()

				While .NOT. oReport:Cancel() .And.;
						.NOT. XDEM->(Eof()) .and.;
						XDEM->ZAJ_FORNEC == cFornece .and.;
						XDEM->ZAJ_LOJA == cLoja .and.;
						XDEM->ZAJ_NUMERO == cNumCot .and.;
						XDEM->ZAJ_PROD == cProd

					If oReport:Cancel()
						Exit
					EndIf

					oReport:IncMeter()

					oSecCot:PrintLine()
					If oReport:nDevice == 4 .And. oSecCot:lHeaderSection
						oReport:lHeaderVisible := .F.
						oSecVend:lHeaderSection := .F.
					EndIf
					nAlterGer++
					nAlterCot++
					nAlterFor++

					XDEM->(DbSkip())

				End

				oSecFor:Finish()
				oReport:SkipLine()
				oReport:SkipLine()
				oReport:PrintText("Total Alteracoes do Fornecedor: "+cFornece+"-"+cLoja+": "+cValtoChar(nAlterFor))
				oReport:SkipLine()
				oReport:ThinLine()
				oReport:SkipLine()
				oReport:SkipLine()
				nAlterFor:=0
		
			End
		
		End

		oSecCot:Finish()
		oReport:SkipLine()
		oReport:SkipLine()
		oReport:PrintText("Total Alteracoes na Cotacao "+cNumCot+": "+cValtoChar(nAlterCot))
		oReport:SkipLine()
		oReport:FATLine()
		oReport:SkipLine()
		oReport:SkipLine()
		nAlterCot:=0
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
			ZAJ_FORNEC,
			ZAJ_LOJA,
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
			AND ZAJ_FORNEC >= %EXP:mv_par03%
			AND ZAJ_FORNEC <= %EXP:mv_par04%
			AND ZAJ_LOJA >= %EXP:mv_par05%
			AND ZAJ_LOJA <= %EXP:mv_par06%
			AND ZAJ_PROD >= %EXP:mv_par07%
			AND ZAJ_PROD <= %EXP:mv_par08%
			AND ZAJ_TIPO = 'CT'
		ORDER BY
			ZAJ_NUMERO,
			ZAJ_FORNEC,
			ZAJ_LOJA,
			ZAJ_PROD
	EndSQL

Return (NIL)
