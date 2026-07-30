#INCLUDE "RWMAKE.CH"
#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#include "topconn.ch"
#Include "TOTVS.ch"
#Include "FWPrintSetup.ch"

//Constantes
#Define PAD_LEFT            0                    //Alinhamento Esquerda
#Define PAD_RIGHT            1                    //Alinhamento Direita
#Define PAD_CENTER            2                    //Alinhamento Centralizado
#Define IMP_SPOOL           2
#Define IMP_PDF           6

User Function RFATR05()

	LOCAL oDlg       := NIL       as Object
	Private aTotNota := {}        as Array
	Private cTitulo  := ""        as character
	Private nLastKey := 0         as numeric
	Private nLinha   := 0         as Nuneric
	Private nomeProg := FunName() as character
	Private nPag	 := 1         as numeric
	Private nSubTot  := 0         as numeric
	Private nTotal   := 0         as numeric
	Private oFont1   := NIL       as Object
	Private oFont2   := NIL       as Object
	Private oFont3   := NIL       as Objject
	Private oFont4   := NIL       as Object
	Private oFont5   := NIL       as Object
	Private oFont6   := NIL       as Object
	Private oPrn     := NIL       as Object
	Private titulo   := ""        as character
	Private wnrel    := FunName() as character

	DEFINE FONT oFont1 NAME "Times New Roman" SIZE 0,20 BOLD  OF oPrn
	DEFINE FONT oFont2 NAME "Times New Roman" SIZE 0,14 BOLD OF oPrn
	DEFINE FONT oFont3 NAME "Times New Roman" SIZE 0,14 OF oPrn
	DEFINE FONT oFont4 NAME "Times New Roman" SIZE 0,14 ITALIC OF oPrn
	DEFINE FONT oFont5 NAME "Times New Roman" SIZE 0,14 OF oPrn
	DEFINE FONT oFont6 NAME "Courier New" BOLD

	cTitulo := "Impressão Espelho de Nota (SAC)"
	oFont08	 := TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
	oFont08N := TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)
	oFont10	 := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
	oFont11  := TFont():New("Arial",11,11,,.F.,,,,.T.,.F.)
	oFont14	 := TFont():New("Arial",14,14,,.F.,,,,.T.,.F.)
	oFont16	 := TFont():New("Arial",16,16,,.F.,,,,.T.,.F.)
	oFont10N := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
	oFont12  := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
	oFont12N := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
	oFont16N := TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)
	oFont14N := TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)
	oFont06	 := TFont():New("Arial",06,06,,.F.,,,,.T.,.F.)
	oFont06N := TFont():New("Arial",06,06,,.T.,,,,.T.,.F.)

	nLastKey  := If(LastKey() == 27,27,nLastKey)

	If nLastKey == 27
		Return (NIL)
	Endif
 
	oPrn := TMSPrinter():New(cTitulo)

	//oPrn:SetPortrait()
	//oPrn:Setup()
	oPrn:SetLandscape() //SetPortrait()
	oPrn:StartPage()
	Imprimir()
	oPrn:EndPage()
	oPrn:End()

	DEFINE MSDIALOG oDlg FROM 264,182 TO 441,613 TITLE cTitulo OF oDlg PIXEL
	@ 004,010 TO 082,157 LABEL "" OF oDlg PIXEL

	@ 015,017 SAY "Esta rotina tem por objetivo imprimir"	OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE
	@ 030,017 SAY "o impresso customizado:"					OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE
	@ 045,017 SAY "Espelho de Nota (SAC)" 						OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE

	@ 06,167 BUTTON "&Imprime" 		SIZE 036,012 ACTION {|| Imprimir(),oPrn:Print()}   	OF oDlg PIXEL
	@ 28,167 BUTTON "Pre&view" 		SIZE 036,012 ACTION {|| Imprimir(),oPrn:Preview()} 	OF oDlg PIXEL
	@ 49,167 BUTTON "Sai&r"    		SIZE 036,012 ACTION {||oDlg:End()}     	OF oDlg PIXEL
	//@ 70,167 BUTTON "Conf.&Impres" 	SIZE 036,012 ACTION oPrn:Setup()    OF oDlg PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

	oPrn:End()

Return

STATIC FUNCTION Imprimir()
	Orcamento()
	Ms_Flush()
Return

STATIC FUNCTION Orcamento()


	BeginSQL ALIAS "TCR"
		SELECT
			ROUND(SUM(SZR.ZR_QTD * SD2.D2_PRCVEN), 2) AS VALPROD,
			ROUND(
				SUM(SD2.D2_BASEICM /(SD2.D2_QUANT / SZR.ZR_QTD)),
				2
			) AS BICMS,
			ROUND(
				SUM(SD2.D2_VALICM /(SD2.D2_QUANT / SZR.ZR_QTD)),
				2
			) AS VALICMS,
			ROUND(
				SUM(SD2.D2_BASEIPI /(SD2.D2_QUANT / SZR.ZR_QTD)),
				2
			) AS BIPI,
			ROUND(
				SUM(SD2.D2_VALIPI /(SD2.D2_QUANT / SZR.ZR_QTD)),
				2
			) AS VALIPI,
			ROUND(
				SUM(SD2.D2_BRICMS /(SD2.D2_QUANT / SZR.ZR_QTD)),
				2
			) AS BST,
			ROUND(
				SUM(SD2.D2_ICMSRET /(SD2.D2_QUANT / SZR.ZR_QTD)),
				2
			) AS VALST,
			ROUND(
				SUM(SD2.D2_VALFRE /(SD2.D2_QUANT / SZR.ZR_QTD)),
				2
			) AS VALFRE,
			ROUND(
				SUM(SZR.ZR_QTD * SD2.D2_PRCVEN) + SUM(SD2.D2_VALIPI /(SD2.D2_QUANT / SZR.ZR_QTD)) + SUM(SD2.D2_ICMSRET /(SD2.D2_QUANT / SZR.ZR_QTD)),
				2
			) AS TOTNOTA,
			SUM(SZR.ZR_QTD * SB1.B1_PESBRU) AS PESOBR
		FROM
			%TABLE:SD2% SD2
		INNER JOIN %TABLE:SB1% SB1
		ON SD2.D2_COD = SB1.B1_COD
			AND SD2.D2_FILIAL = SB1.B1_FILIAL
			AND SB1.%NOTDEL%
			LEFT OUTER JOIN %TABLE:SZR% SZR
		ON SZR.ZR_FILIAL = SD2.D2_FILIAL
			AND SZR.ZR_NUMNF = SD2.D2_DOC
			AND SZR.ZR_SERNF = SD2.D2_SERIE
			AND SZR.ZR_PRODUTO = SD2.D2_COD
			AND SZR.ZR_ITEMORI = SD2.D2_ITEM
			AND SZR.ZR_NUM = %EXP:cGet1Sac%
			AND SZR.ZR_QTD > 0
			AND SZR.%NOTDEL%
		WHERE
			SD2.%NOTDEL%
			AND SD2.D2_FILIAL = %XFILIAL:SD2%
	ENDSQL

	AADD(aTotNota,TCR->VALPROD)
	AADD(aTotNota,TCR->VALICMS)
	AADD(aTotNota,TCR->VALIPI)
	AADD(aTotNota,TCR->VALST)
	AADD(aTotNota,TCR->BICMS)
	AADD(aTotNota,TCR->BIPI)
	AADD(aTotNota,TCR->BST)
	AADD(aTotNota,TCR->TOTNOTA)
	AADD(aTotNota,TCR->PESOBR)
	AADD(aTotNota,TCR->VALFRE)

	TCR->(dbCloseArea())

	cDia := SubStr(DtoS(dDataBase),7,2)
	cMes := SubStr(DtoS(dDataBase),5,2)
	cAno := SubStr(DtoS(dDataBase),1,4)
	cMesExt := MesExtenso(Month(dDataBase))
	cDataImpressao := cDia+" de "+cMesExt+" de "+cAno

	oPrn:StartPage()
	cBitMap := ""
	fLogoEmp(@cBitMap)
	oPrn:SayBitmap(035,0035,cBitMap,100,60)			// Imprime logo da Empresa: comprimento X altura

	//Linha Inicial Identificação
	oPrn:Box(0030,0015,0100,3270)
	oPrn:Say(0050,0500,OemToAnsi("* RELATÓRIO DE SUGESTÃO PARA AUXILIO NA EMISSÃO DE NOTA FISCAL DE DEVOLUÇÃO *"),oFont14N)
	oPrn:Say(0050,2750,"Data: "+cValToChar(dDataBase),oFont14N)
	oPrn:Say(0050,3150,"Pag:: "+cValtoChar(nPag),oFont08)

	oPrn:Say(0130,0025,OemToAnsi("Dados SAC"),oFont14N)

	oPrn:Box(0180,0015,0300,3270)

	oPrn:Say(0200,0025,OemToAnsi("SAC No.")		,oFont12,,,, PAD_LEFT)
	oPrn:Say(0200,0150,OemToAnsi("Cliente")		,oFont12,,,, PAD_LEFT)
	oPrn:Say(0200,1010,OemToAnsi("Emissao")		,oFont12,,,, PAD_LEFT)
	oPrn:Say(0200,1225,OemToAnsi("Valor Prod.")	,oFont12,,,, PAD_LEFT)
	oPrn:Say(0200,1445,OemToAnsi("Valor ICMS ")	,oFont12,,,, PAD_LEFT)
	oPrn:Say(0200,1625,OemToAnsi("Valor IPI  ")	,oFont12,,,, PAD_LEFT)
	oPrn:Say(0200,1825,OemToAnsi("Valor ST   ")	,oFont12,,,, PAD_LEFT)
	oPrn:Say(0200,2025,OemToAnsi("Base ICMS  ")	,oFont12,,,, PAD_LEFT)
	oPrn:Say(0200,2225,OemToAnsi("Base IPI   ")	,oFont12,,,, PAD_LEFT)
	oPrn:Say(0200,2425,OemToAnsi("Base ST    ")	,oFont12,,,, PAD_LEFT)
	oPrn:Say(0200,2625,OemToAnsi("Total NF   ")	,oFont12,,,, PAD_LEFT)
	oPrn:Say(0200,2825,OemToAnsi("Peso Total ")	,oFont12,,,, PAD_LEFT)
	oPrn:Say(0200,3025,OemToAnsi("Frete      ")	,oFont12,,,, PAD_LEFT)

	oPrn:Say(0250,0025,OemToAnsi(cGet1Sac)								,oFont12N,,,,PAD_LEFT)
	oPrn:Say(0250,0150,OemToAnsi(cGet4Sac)								,oFont12N,,,,PAD_LEFT)
	oPrn:Say(0250,1010,cValToChar(dDataBase)							,oFont12N,,,,PAD_LEFT)
	oPrn:Say(0250,1200,Transform(aTotNota[01],"@ER 999,999,999.99")		,oFont12N,,,,PAD_LEFT)
	oPrn:Say(0250,1400,Transform(aTotNota[02],"@ER 999,999,999.99")		,oFont12N,,,,PAD_LEFT)
	oPrn:Say(0250,1600,Transform(aTotNota[03],"@ER 999,999,999.99")		,oFont12N,,,,PAD_LEFT)
	oPrn:Say(0250,1800,Transform(aTotNota[04],"@ER 999,999,999.99")		,oFont12N,,,,PAD_LEFT)
	oPrn:Say(0250,2000,Transform(aTotNota[05],"@ER 999,999,999.99")		,oFont12N,,,,PAD_LEFT)
	oPrn:Say(0250,2200,Transform(aTotNota[06],"@ER 999,999,999.99")		,oFont12N,,,,PAD_LEFT)
	oPrn:Say(0250,2400,Transform(aTotNota[07],"@ER 999,999,999.99")		,oFont12N,,,,PAD_LEFT)
	oPrn:Say(0250,2600,Transform(aTotNota[08],"@ER 999,999,999.99")		,oFont12N,,,,PAD_LEFT)
	oPrn:Say(0250,2800,Transform(aTotNota[09],"@ER 999,999,999.9999")	,oFont12N,,,,PAD_LEFT)
	oPrn:Say(0250,3000,Transform(aTotNota[10],"@ER 999,999,999.99")		,oFont12N,,,,PAD_LEFT)

	oPrn:Say(0320,0025,"Dados para Emissão da NF"						,oFont14N)

	oPrn:Box(0380,0015,2700,3270)

	oPrn:Say(0400,0025,OemToAnsi("Cliente")						,oFont12,,,PAD_LEFT)
	oPrn:Say(0450,0025,OemToAnsi(SM0->M0_NOMECOM)				,oFont14N,,,PAD_LEFT)
	oPrn:Say(0450,1010,"("+RTrim(OemToAnsi(SM0->M0_FILIAL))+")"	,oFont12N,,,PAD_LEFT)

	oPrn:Say(0520,0025,OemToAnsi("Endereco ")					,oFont12,,,PAD_LEFT)
	oPrn:Say(0520,1010,OemToAnsi("Bairro   ")					,oFont12,,,PAD_LEFT)
	oPrn:Say(0520,1800,OemToAnsi("Municipio")					,oFont12,,,PAD_LEFT)
	oPrn:Say(0520,2300,OemToAnsi("Estado   ")					,oFont12,,,PAD_LEFT)
	oPrn:Say(0520,2700,OemToAnsi("CEP      ")					,oFont12,,,PAD_LEFT)

	oPrn:Say(0570,0025,OemToAnsi(SM0->M0_ENDENT)				,oFont12N,,,PAD_LEFT)
	oPrn:Say(0570,1010,OemToAnsi(SM0->M0_BAIRENT)				,oFont12N,,,PAD_LEFT)
	oPrn:Say(0570,1800,OemToAnsi(SM0->M0_CIDENT)				,oFont12N,,,PAD_LEFT)
	oPrn:Say(0570,2300,OemToAnsi(SM0->M0_ESTENT)				,oFont12N,,,PAD_LEFT)
	oPrn:Say(0570,2700,Transform(SM0->M0_CEPENT,"@R 99999-999")	,oFont12N,,,PAD_LEFT)

	oPrn:Say(0620,0025,"CNPJ"				,oFont12,,,PAD_LEFT)
	oPrn:Say(0620,1010,"Inscricao Estadual"	,oFont12,,,PAD_LEFT)
	oPrn:Say(0620,1800,"Telefone"			,oFont12,,,PAD_LEFT)

	oPrn:Say(0670,0025,Transform(Alltrim(SM0->M0_CGC),"@R 99.999.999/9999-99")	,oFont12N,,,PAD_LEFT)
	oPrn:Say(0670,1010,Transform(Alltrim(SM0->M0_INSC),"@R 999.999.999.999")	,oFont12N,,,PAD_LEFT)
	oPrn:Say(0670,1800,OemToAnsi(SM0->M0_TEL)									,oFont12N,,,PAD_LEFT)

	//Linha de cabecalho de Itens
	oPrn:BOX(0720,0015,0790,3270)

	oPrn:Say(0735,0025,"Codigo"  	    ,oFont12N,,,PAD_LEFT)
	oPrn:Say(0735,0340,"Descricao"	    ,oFont12N,,,PAD_LEFT)
	oPrn:Say(0735,1030,"NCM"   	        ,oFont12N,,,PAD_LEFT)
	oPrn:Say(0735,1260,"CST"  	        ,oFont12N,,,PAD_LEFT)
	oPrn:Say(0735,1345,"CFOP"	        ,oFont12N,,,PAD_LEFT)
	oPrn:Say(0735,1445,"Qtd Devolv" 	,oFont12N,,,PAD_LEFT)
	oPrn:Say(0735,1650,"Vlr Unitario"	,oFont12N,,,PAD_LEFT)
	oPrn:Say(0735,1880,"Vlr.Total"  	,oFont12N,,,PAD_LEFT)
	oPrn:Say(0735,2100,"% ICMS"         ,oFont12N,,,PAD_LEFT)
	oPrn:Say(0735,2250,"Vlr ICMS"       ,oFont12N,,,PAD_LEFT)
	oPrn:Say(0735,2480,"% IPI" 	        ,oFont12N,,,PAD_LEFT)
	oPrn:Say(0735,2600,"Vlr Ipi"   	    ,oFont12N,,,PAD_LEFT)
	oPrn:Say(0735,2850,"NF Original"    ,oFont12N,,,PAD_LEFT)
	oPrn:Say(0735,3050,"Serie Orig."    ,oFont12N,,,PAD_LEFT)

	BeginSQL Alias "TCQ"
		SELECT
			SD2.D2_COD AS COD,
			SD2.D2_PRCVEN AS PRCVEN,
			SD2.D2_POSIPI AS NCM,
			SD2.D2_CLASFIS AS CST,
			SD2.D2_CF AS CFOP,
			SZR.ZR_QTD AS QTDPRET,
			ROUND(SZR.ZR_QTD * SD2.D2_PRCVEN, 2) AS VALPROD,
			ROUND((SD2.D2_BASEICM /(SD2.D2_QUANT / SZR.ZR_QTD)), 2) AS BICMS,
			ROUND((SD2.D2_BASEIPI /(SD2.D2_QUANT / SZR.ZR_QTD)), 2) AS BIPI,
			ROUND((SD2.D2_VALICM /(SD2.D2_QUANT / SZR.ZR_QTD)), 2) AS VALICM,
			ROUND((SD2.D2_VALIPI /(SD2.D2_QUANT / SZR.ZR_QTD)), 2) AS VALIPI,
			SD2.D2_PICM AS PICM,
			SD2.D2_IPI AS PIPI,
			RTRIM(ISNULL(SZ1.Z1_DESCR, '')) + ' - ' + RTRIM(SB1.B1_DESC) + ' ' + ISNULL(SZ5.Z5_DESCR, '') AS DESCRICAO,
			SD2.D2_DOC AS NUMNF,
			SD2.D2_SERIE AS SERIE
		FROM
			%TABLE:SZR% SZR
			LEFT OUTER JOIN %TABLE:SD2% SD2
		ON SD2.D2_FILIAL = %XFILIAL:SD2%
			AND SZR.ZR_NUMNF = SD2.D2_DOC
			AND SZR.ZR_SERNF = SD2.D2_SERIE
			AND SZR.ZR_PRODUTO = SD2.D2_COD
			AND SZR.ZR_ITEMORI = SD2.D2_ITEM
			AND SD2.D_E_L_E_T_ = ' '
			LEFT OUTER JOIN SB1010 SB1
		ON SB1.B1_FILIAL = %XFILIAL:SB1%
			AND SZR.ZR_PRODUTO = SB1.B1_COD
			AND SB1.D_E_L_E_T_ = ' '
			LEFT OUTER JOIN SZ5010 SZ5
		ON SZ5.Z5_FILIAL = %XFILIAL:SZ5%
			AND SUBSTRING(SD2.D2_COD, 11, 2) = SZ5.Z5_EMB
			AND SZ5.D_E_L_E_T_ = ' '
			LEFT OUTER JOIN SZ1010 SZ1
		ON SZ1.Z1_FILIAL = %XFILIAL:SZ1%
			AND SUBSTRING(SZR.ZR_PRODUTO, 4, 2) = SZ1.Z1_LINHA
			AND SZ1.D_E_L_E_T_ = ' '
		WHERE
			SZR.D_E_L_E_T_ = ' '
			AND SZR.ZR_FILIAL = %XFILIAL:SZR%
			AND SZR.ZR_NUM = %EXP:cGet1Sac%
		ORDER BY
			SZR.ZR_SEQITEM
	ENDSQL

	nLinha:=810
	While .NOT. TCQ->(EOF())
		oPrn:Say(nLinha,0025,TCQ->COD										,oFont12,,,PAD_LEFT)
		oPrn:Say(nLinha,0340,Substr(TCQ->DESCRICAO,1,35)					,oFont12,,,PAD_LEFT)
		oPrn:Say(nLinha,1030,TCQ->NCM		 								,oFont12,,,PAD_LEFT)
		oPrn:Say(nLinha,1260,TCQ->CST  	        							,oFont12,,,PAD_LEFT)
		oPrn:Say(nLinha,1345,TCQ->CFOP	        							,oFont12,,,PAD_LEFT)
		oPrn:Say(nLinha,1445,Transform(TCQ->QTDPRET	,"@ER 999,999,999.99")	,oFont12,,,PAD_LEFT)
		oPrn:Say(nLinha,1650,Transform(TCQ->PRCVEN	,"@ER 999,999,999.99")	,oFont12,,,PAD_LEFT)
		oPrn:Say(nLinha,1880,Transform(TCQ->VALPROD	,"@ER 999,999,999.99")	,oFont12,,,PAD_LEFT)
		oPrn:Say(nLinha,2100,Transform(TCQ->PICM	,"@ER 99.99")          	,oFont12,,,PAD_LEFT)
		oPrn:Say(nLinha,2250,Transform(TCQ->VALICM	,"@ER 999,999,999.99")	,oFont12,,,PAD_LEFT)
		oPrn:Say(nLinha,2480,Transform(TCQ->PIPI	,"@ER 99.99")          	,oFont12,,,PAD_LEFT)
		oPrn:Say(nLinha,2600,Transform(TCQ->VALIPI	,"@ER 999,999,999.99")	,oFont12,,,PAD_LEFT)
		oPrn:Say(nLinha,2850,TCQ->NUMNF		    							,oFont12,,,PAD_LEFT)
		oPrn:Say(nLinha,3050,TCQ->SERIE								        ,oFont12,,,PAD_LEFT)

		LINHA(nLinha)

		oPrn:Line(nLinha,0015,nLinha,3270,,"-2")

		LINHA(@nLinha)

		TCQ->(dbSkip())
	End

	TCQ->(dbCloseArea())

	oPrn:Line(nLinha,0015,nLinha,3270,,"-4")

	LINHA(@nLinha)
	oPrn:Say(nLinha,0015,OemToAnsi("Base Calculo ICMS: ")				,oFont12,,,PAD_LEFT)
	oPrn:Say(nLinha,1030,OemToAnsi("Valor do ICMS: ")					,oFont12,,,PAD_LEFT)
	oPrn:Say(nLinha,1880,OemToAnsi("Base Calc ICMS Substit.:")			,oFont12,,,PAD_LEFT)
	oPrn:Say(nLinha,2500,OemToAnsi("Valor ICMS SUbstituicao: ")			,oFont12,,,PAD_LEFT)

	oPrn:Say(nLinha,0315,Transform(aTotNota[05],"@ER 999,999,999.99")	,oFont12N,,,PAD_RIGHT)
	oPrn:Say(nLinha,1330,Transform(aTotNota[02],"@ER 999,999,999.99")	,oFont12N,,,PAD_RIGHT)
	oPrn:Say(nLinha,2180,Transform(aTotNota[07],"@ER 999,999,999.99")	,oFont12N,,,PAD_RIGHT)
	oPrn:Say(nLinha,2800,Transform(aTotNota[04],"@ER 999,999,999.99")	,oFont12N,,,PAD_RIGHT)

	LINHA(@nLinha)

	oPrn:Say(nLinha,0015,OemToAnsi("Valor Frete: ")						,oFont12,,,PAD_LEFT)
	oPrn:Say(nLinha,1030,OemToAnsi("Valor IPI: ")						,oFont12,,,PAD_LEFT)
	oPrn:Say(nLinha,1880,OemToAnsi("Valor Total NF: ")					,oFont14N,,,PAD_LEFT)
	oPrn:Say(nLinha,2500,OemToAnsi("Peso Bruto Total: ")				,oFont12,,,PAD_LEFT)

	oPrn:Say(nLinha,0315,Transform(aTotNota[10]	,"@ER 999,999,999.99")	,oFont12N,,,PAD_LEFT)
	oPrn:Say(nLinha,1330,Transform(aTotNota[03]	,"@ER 999,999,999.99")	,oFont12N,,,PAD_LEFT)
	oPrn:Say(nLinha,2180,Transform(aTotNota[08]	,"@ER 999,999,999.99")	,oFont12N,,,PAD_LEFT)
	oPrn:Say(nLinha,2800,Transform(aTotNota[09]	,"@ER 999,999,999.9999"),oFont12N,,,PAD_LEFT)

	LINHA(@nLinha)
	LINHA(@nLinha)
	LINHA(@nLinha)

	cTExto:=" - ESTE RELATÓRIO NÃO EXCLUI NECESSIDADE DE EMITIR NOTA FISCAL DE ACORDO C/ PARTICULARIDADES FISCAIS DE SUA EMPRESA"+CRLF

	oPrn:Say(nLinha,0015,"Atencao:"	,oFont16N)
	LINHA(@nLinha)
	LINHA(@nLinha)
	oPrn:Say(nLinha,0015,OemToAnsi(cTExto),oFont14N)

	oPrn:EndPage()

	//Processo para salvar relatório como imagem
	/*
aCaminho           := {"\\192.168.1.8\teste.jpg"}
filepath          := "\192.168.1.8"
nwidthpage      := 630
nheightpage     := 870

aFiles := Directory(aCaminho[1])
For i:=1 to Len(aFiles)
	fErase("\\192.168.1.8\"+aFiles[1])
Next i

oPrint:SaveAllAsJpeg(filepath,nwidthpage,nheightpage,100)   //Gera arquivos JPEG na Pasta \Protheus_data\Images\

aFiles := {}
aFiles := Directory(aCaminho[1])

//Visualizacao e finalizacao do relatorio
	*/
	oPrint:Setup()
	oPrint:Preview()
	oPrint:EndPage()
	MS_FLUSH()

	If lemail               //Envia E-mail
		//	ENVMAIL()
	EndIF
	

Return


Static Function EnvMail(cAnexo,cNumPed,cPara,cContato,mCorpo)
	Private cAssunto     := 'Relatorio SAC - No. ' + cNumPed
	Private nLineSize    := 60
	Private nTabSize     := 3
	Private lWrap        := .T.
	Private nLine        := 0
	Private cTexto       := ""
	Private lServErro	   := .T.
	Private cServer  := Trim(GetMV("MV_RELSERV")) // smtp.tecnotron.ind.br
	Private cDe 	:= Trim(GetMV("MV_RELACNT"))
	Private cPass    := Trim(GetMV("MV_RELPSW"))  //
	Private lAutentic	:= GetMv("MV_RELAUTH",,.F.)
	Private aTarget  :={cAnexo}
	Private nTarget := 0
	Private lCheck1 := .F.
	Private lCheck2 := .f.

	cCC := UsrRetMail(RetCodUsr())
	cAnexos:=cAnexo
	CPYT2S(cAnexos,GetSrvProfString("Startpath", "")+'emailanexos\',.T.)
	cAnexos:=GetSrvProfString("Startpath", "")+'emailanexos\'+SubStr(AllTrim(cAnexos),RAT('\',AllTrim(cAnexos))+1)
	lServERRO 	:= .F.

	CONNECT SMTP                         ;
		SERVER 	 GetMV("MV_RELSERV"); 	// Nome do servidor de e-mail
		ACCOUNT  GetMV("MV_RELACNT"); 	// Nome da conta a ser usada no e-mail
		PASSWORD GetMV("MV_RELPSW") ; 	// Senha
		Result lConectou

	lRet := .f.
	lEnviado := .f.
	If lAutentic
		lRet := Mailauth(cDe,cPass)
	Endif
	If lRet
		cPara   := Rtrim(cPara)
		cCC		:= Rtrim(cCC)
		cAssunto:= Rtrim(cAssunto)

		//	    	    BCC 'diretoria@metalacre.com.br;gerencia@metalacre.com.br';

		SEND MAIL 	FROM cDe ;
			To cPara ;
			CC cCc;
			SUBJECT	cAssunto ;
			Body mCorpo;
			ATTACHMENT cAnexos;
			RESULT lEnviado

		DISCONNECT SMTP SERVER
	Endif
	If !lConectou .Or. !lEnviado
		cMensagem := ""
		GET MAIL ERROR cMensagem
		Alert(cMensagem)
	Endif
	FERASE(cAnexos)

Return


Static Function LINHA(nLinha)
	If nLinha > 2500
		oPrn:EndPage()
		nPag++
		oPrn:StartPage()
		cBitMap := ""
		fLogoEmp(@cBitMap)
		oPrn:SayBitmap(035,0035,cBitMap,100,60)			// Imprime logo da Empresa: comprimento X altura

		//Linha Inicial Identificação
		oPrn:Box(0030,0015,0100,3270)

		oPrn:Say(0050,0550,OemToAnsi("* RELATÓRIO DE SUGESTÃO PARA AUXILIO NA EMISSÃO DE NOTA FISCAL DE DEVOLUÇÃO *"),oFont14N)
		oPrn:Say(0050,2800,"Data: "+cValToChar(dDataBase),oFont14N)
		oPrn:Say(0050,3180,"Pag:: "+cValtoChar(nPag),oFont08)

		oPrn:Say(0130,0025,OemToAnsi("Dados SAC"),oFont14N)

		oPrn:Box(0180,0015,0300,3270)

		oPrn:Say(0200,0025,OemToAnsi("SAC No.")		,oFont12,,,, PAD_LEFT)
		oPrn:Say(0200,0150,OemToAnsi("Cliente")		,oFont12,,,, PAD_LEFT)
		oPrn:Say(0200,1010,OemToAnsi("Emissao")		,oFont12,,,, PAD_LEFT)
		oPrn:Say(0200,1225,OemToAnsi("Valor Prod.")	,oFont12,,,, PAD_LEFT)
		oPrn:Say(0200,1445,OemToAnsi("Valor ICMS ")	,oFont12,,,, PAD_LEFT)
		oPrn:Say(0200,1625,OemToAnsi("Valor IPI  ")	,oFont12,,,, PAD_LEFT)
		oPrn:Say(0200,1825,OemToAnsi("Valor ST   ")	,oFont12,,,, PAD_LEFT)
		oPrn:Say(0200,2025,OemToAnsi("Base ICMS  ")	,oFont12,,,, PAD_LEFT)
		oPrn:Say(0200,2225,OemToAnsi("Base IPI   ")	,oFont12,,,, PAD_LEFT)
		oPrn:Say(0200,2425,OemToAnsi("Base ST    ")	,oFont12,,,, PAD_LEFT)
		oPrn:Say(0200,2625,OemToAnsi("Total NF   ")	,oFont12,,,, PAD_LEFT)
		oPrn:Say(0200,2825,OemToAnsi("Peso Total ")	,oFont12,,,, PAD_LEFT)
		oPrn:Say(0200,3025,OemToAnsi("Frete      ")	,oFont12,,,, PAD_LEFT)

		oPrn:Say(0250,0025,OemToAnsi(cGet1Sac)								,oFont12N,,,,PAD_LEFT)
		oPrn:Say(0250,0150,OemToAnsi(cGet4Sac)								,oFont12N,,,,PAD_LEFT)
		oPrn:Say(0250,1010,cValToChar(dDataBase)							,oFont12N,,,,PAD_LEFT)
		oPrn:Say(0250,1200,Transform(aTotNota[01],"@ER 999,999,999.99")		,oFont12N,,,,PAD_LEFT)
		oPrn:Say(0250,1400,Transform(aTotNota[02],"@ER 999,999,999.99")		,oFont12N,,,,PAD_LEFT)
		oPrn:Say(0250,1600,Transform(aTotNota[03],"@ER 999,999,999.99")		,oFont12N,,,,PAD_LEFT)
		oPrn:Say(0250,1800,Transform(aTotNota[04],"@ER 999,999,999.99")		,oFont12N,,,,PAD_LEFT)
		oPrn:Say(0250,2000,Transform(aTotNota[05],"@ER 999,999,999.99")		,oFont12N,,,,PAD_LEFT)
		oPrn:Say(0250,2200,Transform(aTotNota[06],"@ER 999,999,999.99")		,oFont12N,,,,PAD_LEFT)
		oPrn:Say(0250,2400,Transform(aTotNota[07],"@ER 999,999,999.99")		,oFont12N,,,,PAD_LEFT)
		oPrn:Say(0250,2600,Transform(aTotNota[08],"@ER 999,999,999.99")		,oFont12N,,,,PAD_LEFT)
		oPrn:Say(0250,2800,Transform(aTotNota[09],"@ER 999,999,999.9999")	,oFont12N,,,,PAD_LEFT)
		oPrn:Say(0250,3000,Transform(aTotNota[10],"@ER 999,999,999.99")		,oFont12N,,,,PAD_LEFT)

		oPrn:Say(0320,0025,"Dados para Emissão da NF"						,oFont14N)

		oPrn:Box(0380,0015,3400,3270)

		oPrn:Say(0400,0025,OemToAnsi("Cliente")						,oFont12,,,PAD_LEFT)
		oPrn:Say(0450,0025,OemToAnsi(SM0->M0_NOMECOM)				,oFont14N,,,PAD_LEFT)
		oPrn:Say(0450,1010,"("+RTrim(OemToAnsi(SM0->M0_FILIAL))+")"	,oFont12N,,,PAD_LEFT)

		oPrn:Say(0520,0025,OemToAnsi("Endereco ")					,oFont12,,,PAD_LEFT)
		oPrn:Say(0520,1010,OemToAnsi("Bairro   ")					,oFont12,,,PAD_LEFT)
		oPrn:Say(0520,1800,OemToAnsi("Municipio")					,oFont12,,,PAD_LEFT)
		oPrn:Say(0520,2300,OemToAnsi("Estado   ")					,oFont12,,,PAD_LEFT)
		oPrn:Say(0520,2700,OemToAnsi("CEP      ")					,oFont12,,,PAD_LEFT)

		oPrn:Say(0570,0025,OemToAnsi(SM0->M0_ENDENT)				,oFont12N,,,PAD_LEFT)
		oPrn:Say(0570,1010,OemToAnsi(SM0->M0_BAIRENT)				,oFont12N,,,PAD_LEFT)
		oPrn:Say(0570,1800,OemToAnsi(SM0->M0_CIDENT)				,oFont12N,,,PAD_LEFT)
		oPrn:Say(0570,2300,OemToAnsi(SM0->M0_ESTENT)				,oFont12N,,,PAD_LEFT)
		oPrn:Say(0570,2700,Transform(SM0->M0_CEPENT,"@R 99999-999")	,oFont12N,,,PAD_LEFT)

		oPrn:Say(0620,0025,"CNPJ"				,oFont12,,,PAD_LEFT)
		oPrn:Say(0620,1010,"Inscricao Estadual"	,oFont12,,,PAD_LEFT)
		oPrn:Say(0620,1800,"Telefone"			,oFont12,,,PAD_LEFT)

		oPrn:Say(0670,0025,Transform(Alltrim(SM0->M0_CGC),"@R 99.999.999/9999-99")	,oFont12N,,,PAD_LEFT)
		oPrn:Say(0670,1010,Transform(Alltrim(SM0->M0_INSC),"@R 999.999.999.999")	,oFont12N,,,PAD_LEFT)
		oPrn:Say(0670,1800,OemToAnsi(SM0->M0_TEL)									,oFont12N,,,PAD_LEFT)

		//Linha de cabecalho de Itens
		oPrn:Box(0720,0015,0770,3270)
		oPrn:Say(0735,0025,"Codigo"  	    ,oFont12N,,,PAD_LEFT)
		oPrn:Say(0735,0340,"Descricao"	    ,oFont12N,,,PAD_LEFT)
		oPrn:Say(0735,1030,"NCM"   	        ,oFont12N,,,PAD_LEFT)
		oPrn:Say(0735,1260,"CST"  	        ,oFont12N,,,PAD_LEFT)
		oPrn:Say(0735,1345,"CFOP"	        ,oFont12N,,,PAD_LEFT)
		oPrn:Say(0735,1445,"Qtd a Devolver" ,oFont12N,,,PAD_LEFT)
		oPrn:Say(0735,1650,"Vlr Unitario"	,oFont12N,,,PAD_LEFT)
		oPrn:Say(0735,1880,"Vlr.Total"  	,oFont12N,,,PAD_LEFT)
		oPrn:Say(0735,2100,"% ICMS"         ,oFont12N,,,PAD_LEFT)
		oPrn:Say(0735,2250,"Vlr ICMS"       ,oFont12N,,,PAD_LEFT)
		oPrn:Say(0735,2480,"% IPI" 	        ,oFont12N,,,PAD_LEFT)
		oPrn:Say(0735,2600,"Vlr Ipi"   	    ,oFont12N,,,PAD_LEFT)
		oPrn:Say(0735,2850,"NF Original"    ,oFont12N,,,PAD_LEFT)
		oPrn:Say(0735,3010,"Serie Orig."    ,oFont12N,,,PAD_LEFT)
		//oPrn:Line(0780,0015,0780,3270,,"-4")
		nLinha:=810
	Else
		nLinha+=50
	End
Return (nLinha)
