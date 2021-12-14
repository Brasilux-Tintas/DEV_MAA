//Bibliotecas
#Include "Totvs.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function BRFATR21
Vendas/Faturamento de Campanhas
@author CLEBER ORATI DOMINGUES
@since 19/11/2021
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

User Function BRFATR21()
	Local aArea := GetArea()
	Local oReport := nil 
	Private cPerg := "BRFATR21"
	PRIVATE MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06,MV_PAR07,MV_PAR08

	MV_PAR01 := 2
	MV_PAR02 := 1
	MV_PAR03 := CTOD(SPACE(8))
	MV_PAR04 := CTOD(SPACE(8))
	MV_PAR05 := ""
	MV_PAR06 := ""
	
	//Adicionando os parametros do ParamBox
//aAdd(aParamBox,{2,"Informe o mÃªs",1,aCombo,50,"",.F.})
// Tipo 2 -> Combo
//           [2]-Descricao
//           [3]-Numerico contendo a opcao inicial do combo
//           [4]-Array contendo as opcoes do Combo
//           [5]-Tamanho do Combo
//           [6]-Validacao
//           [7]-Flag .T./.F. Parametro Obrigatorio ?
// Cuidado, hÃ¡ um problema nesta opÃ§Ã£o quando selecionado a 1Âª opÃ§Ã£o.
ValidPerg()
Pergunte(cPerg,.f.)

	
	//Se a pergunta for confirma, cria as definicoes do relatorio

	//If ParamBox(aPergs, "Informe os parametros")
		oReport := fReportDef()
		oReport:PrintDialog()
	//EndIf
	
	RestArea(aArea)
Return

/*/{Protheus.doc} fReportDef
Definicoes do relatorio BRFATR21
@author CLEBER ORATI DOMINGUES
@since 19/11/2021
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

Static Function fReportDef()
	Local oReport := Nil
	Local oSection := Nil
	Local oBreak := ""
	Local oBreak1 := ""
	Local _cGrupo,_cMens,_cMGrupo
	
	//Criacao do componente de impressao
	oReport := TReport():New( "BRFATR21",;
		"Campanhas",cPerg,;
		{|oReport| fRepPrint(oReport),};
		)
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9)
	
	//Orientacao do Relatorio
	oReport:SetLandscape()
	
	//Definicoes da fonte utilizada
	oReport:SetLineHeight(40)
	oReport:nFontBody := 10
	
	//Criando a secao de dados
	oSection := TRSection():New( oReport,;
		"Dados",;
		{"QRY_REP"})
	oSection:SetTotalInLine(.F.)
	
	/*
	oReport := TReport():New("ClinteXVendedor","Relatorio de Clientes X 
Vendedor","XCLIVEND",{|oReport| PrintReport(oReport)},"Relatorio de visitas de 
vendedores nos clientes")
oSection := TRSection():New(oReport,"Dados dos Clientes",{"SA1"} )
*/
	//Colunas do relatorio
		TRCell():New(oSection, "CODREPR", "QRY_REP", "Repres", /*cPicture*/, 6, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
		TRCell():New(oSection, "NOMEREPR", "QRY_REP", "Nome Repres", /*cPicture*/, 30, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
		TRCell():New(oSection, "TABELA", "QRY_REP", "Campanha", /*cPicture*/, 3, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
		TRCell():New(oSection, "DESCTAB", "QRY_REP", "Nome Campanha", /*cPicture*/, 15, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
		TRCell():New(oSection, "CODPRO", "QRY_REP", "Cod Prod", /*cPicture*/, 15, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
		TRCell():New(oSection, "DESCPRO", "QRY_REP", "Descr Produto", /*cPicture*/, 30, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
		TRCell():New(oSection, "COR", "QRY_REP", "Cor", /*cPicture*/, 3, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
		TRCell():New(oSection, "F2_VALMERC", "QRY_REP", "Vlr Mercadoria", "@E 99,999,999,999.99     ", 14, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT", /*lLineBreak*/, "RIGHT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
		TRCell():New(oSection, "VOLUME", "QRY_REP", "Volume(L.KG)", "@E 99,999,999,999.99     ", 14, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT", /*lLineBreak*/, "RIGHT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)


	//Quebras do relatorio
	DO CASE
	CASE MV_PAR02 == 1
		_cGrupo := "CODREPR"
		_cMens := "Total do Repr"
		_cMGrupo := "Total Repr+Camp"
	CASE MV_PAR02 == 2
		_cGrupo := "TABELA"
		_cMens := "Total da Camp"
		_cMGrupo := "Total Camp+Repr"
	CASE MV_PAR02 == 3
		_cGrupo := "COR"
		_cMens := "Total da Cor"
		_cMGrupo := "Total Cor+Repr"
	ENDCASE 
		oBreak := TRBreak():New(oSection, oSection:Cell(_cGrupo), {||_cMens}, .F.)
		//Totalizadores
		TRFunction():New(oSection:Cell("F2_VALMERC"), , "SUM", oBreak, , "@E 99,999,999,999.99", , .F.)
		TRFunction():New(oSection:Cell("VOLUME"), , "SUM", oBreak, , "@E 99,999,999,999.99", , .F.)
		oBreak1 := TRBreak():New(oSection, "QRY_REP->GRUPO", {||_cMGrupo}, .F.)
		TRFunction():New(oSection:Cell("F2_VALMERC"), , "SUM", oBreak1, , "@E 99,999,999,999.99", , .F.)
		TRFunction():New(oSection:Cell("VOLUME"), , "SUM", oBreak1, , "@E 99,999,999,999.99", , .F.)


Return oReport

/*/{Protheus.doc} fRepPrint
Impressao do relatorio BRFATR21
@author CLEBER ORATI DOMINGUES
@since 19/11/2021
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

Static Function fRepPrint(oReport)
	Local aArea    := GetArea()
	Local cQryReport  := ""
	Local oSectDad := Nil
	Local nAtual   := 0
	Local nTotal   := 0
	
	//Pegando as secoes do relatorio
	oSectDad := oReport:Section(1)
	
	//Montando consulta de dados
	IF MV_PAR01 == 2
		cQryReport += "WITH TMP AS (SELECT F2_VEND1 AS CODREPR,D2_COD AS CODPRO,C5_TABELA AS TABELA,"+;
		"SUM(D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1.0 END)) AS F2_VALMERC, "+;
		"VOLUME = SUM(CASE WHEN D2_UM IN ('L','K','KG') THEN D2_QUANT WHEN D2_SEGUM IN ('L','K','KG') THEN D2_QTSEGUM ELSE 0 END)  "+;
		"FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) "+;
		"LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = '"+xFilial("SF2")+"') AND (D2_SERIE = F2_SERIE) AND (D2_DOC = F2_DOC) AND (D2_CLIENTE = F2_CLIENTE) "+;
		"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (D2_CLIENTE = A1_COD) AND (D2_LOJA = A1_LOJA) "+;
		"LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (D2_TES = F4_CODIGO) "+;
		"LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = '"+xFilial("SC5")+"') AND (D2_PEDIDO = C5_NUM) "+;
		"WHERE (SD2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = '"+xFilial("SD2")+"') AND (D2_TIPO = 'N') AND ((F4_DUPLIC <> 'N') OR (D2_TES = '519')) AND "+;
		"(C5_XCONF = 'T') AND (C5_TABELA > '') "+;
		"AND (D2_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"') "
		IF !EMPTY(MV_PAR06) .AND. (MV_PAR06 >= MV_PAR05)
			cQryReport += "AND (D2_CLIENTE BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"') "
		ENDIF 
		IF !EMPTY(MV_PAR08) .AND. (MV_PAR08 >= MV_PAR07)
			cQryReport += "AND (F2_VEND1 BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"') "
		ENDIF 
		cQryReport += "GROUP BY F2_VEND1,C5_TABELA,D2_COD  "+;
		"UNION ALL "+;
		"SELECT F2_VEND1 AS CODREPR,D1_COD AS CODPRO,C5_TABELA AS TABELA,"+;
		"SUM(-1.0*D1_TOTAL) AS F2_VALMERC, "+;
		"VOLUME = -1.0*SUM(CASE WHEN D1_UM IN ('L','K','KG') THEN D1_QUANT WHEN D1_SEGUM IN ('L','K','KG') THEN D1_QTSEGUM ELSE 0 END)  "+;
		"FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK) "+;
		"LEFT OUTER JOIN "+RetSqlName("SF1")+" SF1 WITH (NOLOCK) ON (SF1.D_E_L_E_T_ <> '*') AND (F1_FILIAL = D1_FILIAL) AND (F1_DOC = D1_DOC) AND (F1_SERIE = D1_SERIE) AND (F1_FORNECE = D1_FORNECE) AND (F1_TIPO = D1_TIPO) "+;
		"LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = D1_FILIAL) AND (F2_SERIE = D1_SERIORI) AND (F2_DOC = D1_NFORI) "+;
		"LEFT OUTER JOIN "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) ON (SD2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = D1_FILIAL) AND (D2_SERIE =  D1_SERIORI) AND (D2_DOC = D1_NFORI) AND (D2_ITEM = D1_ITEMORI) AND (D2_CLIENTE = D1_FORNECE) AND (D2_LOJA = D1_LOJA) "+;
		"LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = D2_FILIAL) AND (C5_NUM = D2_PEDIDO) "+;
		"LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (D1_TES = F4_CODIGO) "+;
		"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (A1_COD = D1_FORNECE) AND (A1_LOJA = D1_LOJA) "+;
		"WHERE (SD1.D_E_L_E_T_ <> '*') AND (D1_FILIAL = '"+xFilial("SD1")+"') AND (D1_TIPO = 'D') AND (D1_NFORI > '') AND (F4_DUPLIC <> 'N') AND "+;
		"(C5_XCONF = 'T') AND (C5_TABELA > '') AND "+;
		"(D1_DTDIGIT BETWEEN  '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"') "
		IF !EMPTY(MV_PAR06) .AND. (MV_PAR06 >= MV_PAR05)
			cQryReport += "AND (D1_FORNECE BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"') "
		ENDIF 
		IF !EMPTY(MV_PAR08) .AND. (MV_PAR08 >= MV_PAR07)
			cQryReport += "AND (F2_VEND1 BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"') "
		ENDIF 
		cQryReport += "GROUP BY F2_VEND1,C5_TABELA,D1_COD) "
	ELSE 
		cQryReport += "WITH TMP AS (SELECT C5_VEND1 AS CODREPR,C6_PRODUTO AS CODPRO,C5_TABELA AS TABELA,"+;
		"SUM(C6_VALOR/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1.0 END)) AS F2_VALMERC, "+;
		"VOLUME = SUM(CASE WHEN C6_UM IN ('L','K','KG') THEN C6_QTDVEN WHEN C6_SEGUM IN ('L','K','KG') THEN C6_UNSVEN ELSE 0 END)  "+;
		"FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "+;
		"LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = '"+xFilial("SC5")+"') AND (C6_NUM = C5_NUM) "+;
		"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (C5_CLIENTE = A1_COD) AND (C5_LOJACLI = A1_LOJA) "+;
		"LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (C6_TES = F4_CODIGO) "+;
		"WHERE (SC6.D_E_L_E_T_ <> '*') AND (C6_FILIAL = '"+xFilial("SC6")+"') AND (C5_TIPO = 'N') AND ((F4_DUPLIC <> 'N') OR (C6_TES = '519')) AND "+;
		"(C5_XCONF = 'T') AND (C5_TABELA > '') AND (C5_APROVA = '1') "+;
		"AND (C5_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"') "
		IF !EMPTY(MV_PAR06) .AND. (MV_PAR06 >= MV_PAR05)
			cQryReport += "AND (C5_CLIENTE BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"') "
		ENDIF 
		IF !EMPTY(MV_PAR08) .AND. (MV_PAR08 >= MV_PAR07)
			cQryReport += "AND (C5_VEND1 BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"') "
		ENDIF 
		cQryReport += "GROUP BY C5_VEND1,C5_TABELA,C6_PRODUTO)  "
	ENDIF 
	cQryReport += "SELECT CODREPR,MAX(A3_NOME) AS NOMEREPR ,TABELA,MAX(DA0_DESCRI) AS DESCTAB,CODPRO,MAX(B1_DESC) AS DESCPRO,SUBSTRING(CODPRO,6,2) AS COR,SUM(F2_VALMERC) AS F2_VALMERC,SUM(VOLUME) AS VOLUME,GRUPO = "
	DO CASE
		CASE MV_PAR02 == 1
			cQryReport += "CODREPR+TABELA "
		CASE MV_PAR02 == 2
			cQryReport += "TABELA+CODREPR "
		CASE MV_PAR02 == 3
			cQryReport += "SUBSTRING(CODPRO,6,2)+CODREPR "
	ENDCASE 
	cQryReport += "FROM TMP "+;
	"LEFT OUTER JOIN "+RetSqlName("SA3")+" SA3 WITH (NOLOCK) ON (SA3.D_E_L_E_T_ <> '*') AND (A3_FILIAL = '"+xFilial("SA3")+"') AND (A3_COD = CODREPR) "+;
	"LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = '"+xFilial("SB1")+"') AND (CODPRO = B1_COD) "+;
	"LEFT OUTER JOIN "+RetSqlName("DA0")+" DA0 WITH (NOLOCK) ON (DA0.D_E_L_E_T_ <> '*') AND (DA0_FILIAL = '"+xFilial("DA0")+"') AND (TABELA = DA0_CODTAB) "+;
	"GROUP BY CODREPR,TABELA,SUBSTRING(CODPRO,6,2),CODPRO  "+;
	"ORDER BY GRUPO,COR,CODPRO"
	
	If SELECT( "QRY_REP" ) <> 0
		DbSelectArea( "QRY_REP" )
		DbCloseArea()
	Endif

	//Executando consulta e setando o total da regua
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryReport),"QRY_REP")
	//PlsQuery(cQryReport, "QRY_REP")
	DbSelectArea("QRY_REP")
	Count to nTotal
	oReport:SetMeter(nTotal)
	
	//Enquanto houver dados
	oSectDad:Init()
	QRY_REP->(DbGoTop())
	While ! QRY_REP->(Eof())
	
		//Incrementando a regua
		nAtual++
		oReport:SetMsgPrint("Imprimindo registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
		oReport:IncMeter()
		
		//Imprimindo a linha atual
		oSectDad:PrintLine()
		
		QRY_REP->(DbSkip())
	EndDo
	oSectDad:Finish()
	QRY_REP->(DbCloseArea())
	
	RestArea(aArea)
Return

Static Function ValidPerg()
Local _sAlias := Alias()
//Local aHelp := {}


u_xPutSX1(cPerg,"01","Venda ou Faturamento?" ,"Venda ou Faturamento?","Venda ou Faturamento?","mv_ch1","N",1,0,1,"C","","","","","MV_PAR01","1-Venda","1-Venda","1-Venda","","2-Faturamento","2-Faturamento","2-Faturamento","","","","","","","","","","Venda ou Faturamento?","Venda ou Faturamento?","Venda ou Faturamento?",cPerg)
u_xPutSX1(cPerg,"02","Ordem de?" ,"Ordem de?","Ordem de?","mv_ch2","N",1,0,1,"C","","","","","MV_PAR02","Repres+Camp+Cor","Repres+Camp+Cor","Repres+Camp+Cor","","Camp+Repres+Cor","Camp+Repres+Cor","Camp+Repres+Cor","Cor+Repr","Cor+Repr","Cor+Repr","","","","","","","Qual a Ordem?","Qual a Ordem?","Qual a Ordem?",cPerg)
u_xPutSX1(cPerg,"03","Data De ?"      ,"Data De ?" ,"Data De ?"  ,"mv_ch3" ,"D",08,0,0,"G",""  ,"","","","MV_PAR03",""     ,""     ,""     ,"",""     ,""     ,""     ,"","","","","","","","","",Nil         ,Nil         ,Nil         ,cPerg)
u_xPutSX1(cPerg,"04","Data Ate ?"      ,"Data Ate ?" ,"Data Ate ?"  ,"mv_ch4" ,"D",08,0,0,"G",""  ,"","","","MV_PAR04",""     ,""     ,""     ,"",""     ,""     ,""     ,"","","","","","","","","",Nil         ,Nil         ,Nil         ,cPerg)
u_xPutSx1(cPerg,"05","Do Cliente         ", "Do Cliente         ", "Do Cliente         ", "mv_ch5", "C",  6, 0, 0, "G", " ", "SA1", " ", " ", "MV_PAR05", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
u_xPutSx1(cPerg,"06","Até o Cliente      ", "Até o Cliente      ", "Até o Cliente      ", "mv_ch6", "C",  6, 0, 0, "G", " ", "SA1", " ", " ", "MV_PAR06", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
u_xPutSx1(cPerg,"07","Do Repres         ", "Do Repres         ", "Do Repres         ", "mv_ch7", "C",  6, 0, 0, "G", " ", "SA3", " ", " ", "MV_PAR07", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
u_xPutSx1(cPerg,"08","Até o Repres      ", "Até o Repres      ", "Até o Repres      ", "mv_ch8", "C",  6, 0, 0, "G", " ", "SA3", " ", " ", "MV_PAR08", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)


dbSelectArea(_sAlias)
Return

