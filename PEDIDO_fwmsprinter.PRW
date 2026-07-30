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

	Local nI
	Private aTotNota := {}        as Array
	Private aTotItem := {}        as Array
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
	//Linhas e colunas
	Private nLinAtu   := 030
	Private nTamLin   := 050
	Private nLinFin   := 2500
	Private nColIni   := 010
	Private nColFin   := 550
	Private nColMeio  := (nColFin-nColIni)/2
	//Variáveis auxiliares
	Private dDataGer  := Date()
	Private cHoraGer  := Time()
	Private cNomeUsr  := UsrRetName(RetCodUsr())
	Private cNomeFont := "Arial"
	Private oFontDet  := TFont():New(cNomeFont, 9, -10, .T., .F., 5, .T., 5, .T., .F.)
	Private oFontDetN := TFont():New(cNomeFont, 9, -10, .T., .T., 5, .T., 5, .T., .F.)
	Private oFontTit  := TFont():New(cNomeFont, 9, -13, .T., .T., 5, .T., 5, .T., .F.)

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

	cCaminho  := "c:\spool\" //GetTempPath()
	cArquivo := "SAC_" + cGet1Sac+ ".pdf"
	//oPrn := FWMSPrinter():New(cArquivo, IMP_PDF, .F., "", .T., , @oPrn, "", , , , .T.)
      oPrn := FWMSPrinter():New(;
            cArquivo,;    // cFilePrinter
            IMP_PDF,;     // nDevice
            .F.,;         // lAdjustToLegacy
            ,;            // cPathInServer
            .T.,;         // lDisabeSetup
            ,;            // lTReport
            @oPrn,;  // oPrintSetup
            ,;            // cPrinter
            ,;            // lServer
            ,;            // lParam10
            ,;            // lRaw
            .T.;          // lViewPDF
        )
	//Setando os atributos necessários do relatório
	oPrn:SetResolution(72)
	oPrn:oPrn:SetLandscape() //SetPortrait()
	oPrn:SetPaperSize(DMPAPER_A4)
	//oPrn:SetMargin(60, 60, 60, 60)

	fQuery(@aTotNota,@aTotItem)

	fImpCab()

	For nI:=1 To Len(aTotItem)

		If nLinAtu + nTamLin > nLinFin
			fImpRod()
			fImpCab()
		EndIf
		oPrn:Say(nLinAtu,0025,aItemNota[nI][01]										,oFont12,,,PAD_LEFT)
		oPrn:Say(nLinAtu,0340,Substr(aItemNota[nI][02],1,35)					,oFont12,,,PAD_LEFT)
		oPrn:Say(nLinAtu,1030,aItemNota[nI][03]		 								,oFont12,,,PAD_LEFT)
		oPrn:Say(nLinAtu,1260,aItemNota[nI][04]  	        							,oFont12,,,PAD_LEFT)
		oPrn:Say(nLinAtu,1345,aItemNota[nI][05]	        							,oFont12,,,PAD_LEFT)
		oPrn:Say(nLinAtu,1445,Transform(aItemNota[nI][06]	,"@ER 999,999,999.99")	,oFont12,,,PAD_LEFT)
		oPrn:Say(nLinAtu,1650,Transform(aItemNota[nI][07]	,"@ER 999,999,999.99")	,oFont12,,,PAD_LEFT)
		oPrn:Say(nLinAtu,1880,Transform(aItemNota[nI][08]	,"@ER 999,999,999.99")	,oFont12,,,PAD_LEFT)
		oPrn:Say(nLinAtu,2100,Transform(aItemNota[nI][09]	,"@ER 99.99")          	,oFont12,,,PAD_LEFT)
		oPrn:Say(nLinAtu,2250,Transform(aItemNota[nI][10]	,"@ER 999,999,999.99")	,oFont12,,,PAD_LEFT)
		oPrn:Say(nLinAtu,2480,Transform(aItemNota[nI][11]	,"@ER 99.99")          	,oFont12,,,PAD_LEFT)
		oPrn:Say(nLinAtu,2600,Transform(aItemNota[nI][12]	,"@ER 999,999,999.99")	,oFont12,,,PAD_LEFT)
		oPrn:Say(nLinAtu,2850,aItemNota[nI][13]		    							,oFont12,,,PAD_LEFT)
		oPrn:Say(nLinAtu,3050,aItemNota[nI][14]								        ,oFont12,,,PAD_LEFT)
		nLinAtu += nTamLin
	Next
	If nLinAtu <= nLinFin
		fImpRod()
	EndIf
	//Se for via job, imprime o arquivo para gerar corretamente o pdf
	If FWAlertNoYes("Deseja Enviar por e-mail?", "Envio de E-mail")
		oPrn:Print()
		anexos:={}
		//Atenção! - é necessário baixar a função zEnvMail() - disponível em https://terminaldeinformacao.com/2017/10/17/funcao-dispara-e-mail-varios-anexos-em-advpl/
		cPara    := "marioantonaccio@brasilux.com.br"
		cAssunto := "Assunto: Relatorio Espelho SAC "+cGet1Sac
		cCorpo   := "Prezado, \n\nSegue em anexo o relatório solicitado.\n\nAtenciosamente,\nEquipe de TI"
		aAdd(aAnexos, cCaminho + cArquivo)

		//Monta o corpo do e-Mail
		cCorpo := '<p>Olá.</p>'
		cCorpo += '<p></p>'
		cCorpo += '<p>Esse é um <strong>e-Mail de teste</strong> gerado pelo <font color=""red"">ERP Protheus</font>.</p>'
		cCorpo += '<p></p>'
		cCorpo += '<p>Data <em>' + dToC(Date()) + '</em> às <em>' +Time() + '</em>.</p>'

		//Faz o disparo via GPEMail
		cAssunto := "Envio de Teste (GPEMail)"
		lEnvio   := GPEMail(cAssunto, cCorpo, cPara, aAnexos, .F.)

		If lEnvio
			FWAlertSuccess("Sucesso no disparo do e-Mail", "Teste GPEMail")
		Else
			FWAlertError("Falha no disparo do e-Mail", "Teste GPEMail")
		EndIf


		u_zEnvMail(cPara, cAssunto, cCorpo, aAnexos)

		//Se for via manual, mostra o relatório
	Else
		oPrn:EndPage()

		oPrn:Preview()    // Abre a tela para visualização do relatório (se lViewPDF == .T.)

		/// tratamento para ver se o PDF foi gerado corretamente
		cArqPDF    := "c:\Spool\SAC_"+cGet1Sac+".PDF"

		For nX := 1 to 10
			If .NOT. File(cArqPDF)
				Sleep(1000)
			EndIf
		Next nX

		For nX := 1 to 10
			aFilePDF := Directory(cArqPDF)    // Retorna um array com { cNomeArq, cTamanho, dData, cHora, cAtributos }

			// Verifica se tamanho do PDF gerado está maior que zero
			If aFilePDF[1,2] > 0
				// Se maior que zero, OK! Então sai do loop
				Exit
			Else
				Sleep(1000)
			EndIf
		Next nX
	EndIf
Return (NIL)


Static Function FQUery(aTotnota,aTotItem)

	aTotNota:={}
	aTotItem:={}

	BeginSQL ALIAS "NOTA"
		SELECT
			ROUND(SUM(SZR.ZR_QTD * SD2.D2_PRCVEN), 2) AS VALPROD,
			ROUND(SUM(SD2.D2_BASEICM /(SD2.D2_QUANT / SZR.ZR_QTD)), 2) AS BICMS,
			ROUND(SUM(SD2.D2_VALICM /(SD2.D2_QUANT / SZR.ZR_QTD)), 2) AS VALICMS,
			ROUND(SUM(SD2.D2_BASEIPI /(SD2.D2_QUANT / SZR.ZR_QTD)), 2) AS BIPI,
			ROUND(SUM(SD2.D2_VALIPI /(SD2.D2_QUANT / SZR.ZR_QTD)), 2) AS VALIPI,
			ROUND(SUM(SD2.D2_BRICMS /(SD2.D2_QUANT / SZR.ZR_QTD)), 2) AS BST,
			ROUND(SUM(SD2.D2_ICMSRET /(SD2.D2_QUANT / SZR.ZR_QTD)), 2) AS VALST,
			ROUND(SUM(SD2.D2_VALFRE /(SD2.D2_QUANT / SZR.ZR_QTD)), 2) AS VALFRE,
			ROUND(SUM(SZR.ZR_QTD*SD2.D2_PRCVEN)+SUM(SD2.D2_VALIPI/(SD2.D2_QUANT/SZR.ZR_QTD))+SUM(SD2.D2_ICMSRET/(SD2.D2_QUANT/SZR.ZR_QTD)),2) AS TOTNOTA,
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

	AADD(aTotNota,NOTA->VALPROD)
	AADD(aTotNota,NOTA->VALICMS)
	AADD(aTotNota,NOTA->VALIPI)
	AADD(aTotNota,NOTA->VALST)
	AADD(aTotNota,NOTA->BICMS)
	AADD(aTotNota,NOTA->BIPI)
	AADD(aTotNota,NOTA->BST)
	AADD(aTotNota,NOTA->TOTNOTA)
	AADD(aTotNota,NOTA->PESOBR)
	AADD(aTotNota,NOTA->VALFRE)
	NOTA->(dbCloseArea())

	BeginSQL Alias "ITEM"
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
	While .NOT. ITEM->(EOF())
		aadd(aTotItem, {	ITEM->COD,;
			Substr(ITEM->DESCRICAO,1,35),;
			ITEM->NCM,;
			ITEM->CST,;
			ITEM->CFOP,;
			ITEM->QTDPRET,;
			ITEM->PRCVEN,;
			ITEM->VALPROD,;
			ITEM->PICM,;
			ITEM->VALICM,;
			ITEM->PIPI,;
			ITEM->VALIPI,;
			ITEM->NUMNF,;
			ITEM->SERIE})
		ITEM->(dbSkip())
	End
	ITEM->(dbCloseArea())
Return(NIL)

Static Function FImpCab()

	Local cBitMap := ""

	//Iniciando Página
	oPrn:StartPage()
	oPrn:Box(0030,0015,0100,3270)

	//Cabeçalho das colunas
	fLogoEmp(@cBitMap)
	oPrn:SayBitmap(035,0035,cBitMap,100,60)			// Imprime logo da Empresa: comprimento X altura

	//Linha Inicial Identificação
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


	//Atualizando a linha inicial do relatório
	nLinAtu :=820
Return (NIL)

Static Function fImpRod()

	oPrn:Line(nLinAtu,0015,nLinAtu,3270,,"-4")
	nLinAtu+=nTamLin
	oPrn:Say(nLinAtu,0015,OemToAnsi("Base Calculo ICMS: ")				,oFont12,,,PAD_LEFT)
	oPrn:Say(nLinAtu,1030,OemToAnsi("Valor do ICMS: ")					,oFont12,,,PAD_LEFT)
	oPrn:Say(nLinAtu,1880,OemToAnsi("Base Calc ICMS Substit.:")			,oFont12,,,PAD_LEFT)
	oPrn:Say(nLinAtu,2500,OemToAnsi("Valor ICMS SUbstituicao: ")			,oFont12,,,PAD_LEFT)

	oPrn:Say(nLinAtu,0315,Transform(aTotNota[05],"@ER 999,999,999.99")	,oFont12N,,,PAD_RIGHT)
	oPrn:Say(nLinAtu,1330,Transform(aTotNota[02],"@ER 999,999,999.99")	,oFont12N,,,PAD_RIGHT)
	oPrn:Say(nLinAtu,2180,Transform(aTotNota[07],"@ER 999,999,999.99")	,oFont12N,,,PAD_RIGHT)
	oPrn:Say(nLinAtu,2800,Transform(aTotNota[04],"@ER 999,999,999.99")	,oFont12N,,,PAD_RIGHT)

	nLinAtu+=nTamLin

	oPrn:Say(nLinAtu,0015,OemToAnsi("Valor Frete: ")						,oFont12,,,PAD_LEFT)
	oPrn:Say(nLinAtu,1030,OemToAnsi("Valor IPI: ")						,oFont12,,,PAD_LEFT)
	oPrn:Say(nLinAtu,1880,OemToAnsi("Valor Total NF: ")					,oFont14N,,,PAD_LEFT)
	oPrn:Say(nLinAtu,2500,OemToAnsi("Peso Bruto Total: ")				,oFont12,,,PAD_LEFT)

	oPrn:Say(nLinAtu,0315,Transform(aTotNota[10]	,"@ER 999,999,999.99")	,oFont12N,,,PAD_LEFT)
	oPrn:Say(nLinAtu,1330,Transform(aTotNota[03]	,"@ER 999,999,999.99")	,oFont12N,,,PAD_LEFT)
	oPrn:Say(nLinAtu,2180,Transform(aTotNota[08]	,"@ER 999,999,999.99")	,oFont12N,,,PAD_LEFT)
	oPrn:Say(nLinAtu,2800,Transform(aTotNota[09]	,"@ER 999,999,999.9999"),oFont12N,,,PAD_LEFT)

	nLinAtu+=nTamLin

	cTexto:="- ESTE RELATÓRIO NÃO EXCLUI NECESSIDADE DE EMITIR NOTA FISCAL DE ACORDO C/ PARTICULARIDADES FISCAIS DE SUA EMPRESA"+CRLF

	oPrn:Say(nLinAtu,0015,"Atencao:"	,oFont16N)
	nLinAtu+=nTamLin
	oPrn:Say(nLinAtu,0015,OemToAnsi(cTexto),oFont14N)
	oPrn:EndPage()
	nPag++
Return(NIL)


User Function zEnvMail(cPara, cAssunto, cCorpo, aAnexos, lMostraLog, lUsaTLS, lNovo)
	Local aArea        := GetArea()
	Local nAtual       := 0
	Local lRet         := .T.
	Local oMsg         := Nil
	Local oSrv         := Nil
	Local nRet         := 0
	Local cFrom        := Alltrim(GetMV("MV_RELACNT"))
	Local cUser        := SubStr(cFrom, 1, At('@', cFrom)-1)
	Local cPass        := Alltrim(GetMV("MV_RELPSW"))
	Local cSrvFull     := Alltrim(GetMV("MV_RELSERV"))
	Local cServer      := ""
	Local nPort        := 0
	Local nTimeOut     := GetMV("MV_RELTIME")
	Local cLog         := ""
	Local cContaAuth   := ""
	Local cPassAuth    := ""
	Local nAtu         := 0
	Local cProcessos   := ""
	Default cPara      := ""
	Default cAssunto   := ""
	Default cCorpo     := ""
	Default aAnexos    := {}
	Default lMostraLog := .F.
	Default lUsaTLS    := .T.
	Default lNovo      := .F.

	//Se tiver em branco o destinatário, o assunto ou o corpo do email
	If Empty(cPara) .Or. Empty(cAssunto) .Or. Empty(cCorpo)
		cLog += "001 - Destinatario, Assunto ou Corpo do e-Mail vazio(s)!" + CRLF
		lRet := .F.
	EndIf

	If lRet
		If lNovo
			cContaAuth := Alltrim(GetMV("MV_X_NCNT"))
			cPassAuth  := Alltrim(GetMV("MV_X_NPSW"))
			cSrvFull   := Alltrim(GetMV("MV_X_NSRV"))
		Else
			cContaAuth := cFrom
			cPassAuth  := cPass
		EndIf
		cServer      := Iif(':' $ cSrvFull, SubStr(cSrvFull, 1, At(':', cSrvFull)-1), cSrvFull)
		nPort        := Iif(':' $ cSrvFull, Val(SubStr(cSrvFull, At(':', cSrvFull)+1, Len(cSrvFull))), 587)

		//Cria a nova mensagem
		oMsg := TMailMessage():New()
		oMsg:Clear()

		//Define os atributos da mensagem
		//oMsg:cDate    := cValToChar(Date())
		oMsg:cFrom    := cFrom
		oMsg:cTo      := cPara
		oMsg:cSubject := cAssunto
		oMsg:cBody    := cCorpo

		//Percorre os anexos
		For nAtual := 1 To Len(aAnexos)
			//Se o arquivo existir
			If File(aAnexos[nAtual])

				//Anexa o arquivo na mensagem de e-Mail
				nRet := oMsg:AttachFile(aAnexos[nAtual])
				If nRet < 0
					cLog += "002 - Nao foi possivel anexar o arquivo '"+aAnexos[nAtual]+"'!" + CRLF
				EndIf

				//Senao, acrescenta no log
			Else
				cLog += "003 - Arquivo '"+aAnexos[nAtual]+"' nao encontrado!" + CRLF
			EndIf
		Next

		//Cria servidor para disparo do e-Mail
		oSrv := tMailManager():New()

		//Define se irá utilizar o TLS
		If lUsaTLS
			oSrv:SetUseTLS(.T.)
		EndIf

		//Inicializa conexão
		nRet := oSrv:Init("", cServer, cUser, cPass, 0, nPort)
		If nRet != 0
			cLog += "004 - Nao foi possivel inicializar o servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
			lRet := .F.
		EndIf

		If lRet
			//Define o time out
			nRet := oSrv:SetSMTPTimeout(nTimeOut)
			If nRet != 0
				cLog += "005 - Nao foi possivel definir o TimeOut '"+cValToChar(nTimeOut)+"'" + CRLF
			EndIf

			//Conecta no servidor
			nRet := oSrv:SMTPConnect()
			If nRet <> 0
				cLog += "006 - Nao foi possivel conectar no servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
				lRet := .F.
			EndIf

			If lRet
				//Realiza a autenticação do usuário e senha
				nRet := oSrv:SmtpAuth(cContaAuth, cPassAuth)
				If nRet <> 0
					cLog += "007 - Nao foi possivel autenticar no servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
					lRet := .F.
				EndIf

				If lRet
					//Envia a mensagem
					nRet := oMsg:Send(oSrv)
					If nRet <> 0
						cLog += "008 - Nao foi possivel enviar a mensagem: " + oSrv:GetErrorString(nRet) + CRLF
						lRet := .F.
					EndIf
				EndIf

				//Disconecta do servidor
				nRet := oSrv:SMTPDisconnect()
				If nRet <> 0
					cLog += "009 - Nao foi possivel disconectar do servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
				EndIf
			EndIf
		EndIf
	EndIf

	//Se tiver log de avisos/erros
	If !Empty(cLog)
		//Busca todas as funções
		nAtu := 0
		cProcessos := ""
		/*
		While ! (ProcName(nAtu) == '')
			cProcessos += ProcName(nAtu) + "; "
			nAtu++
		EndDo
		*/

		cLog := "+======================= zEnvMail =======================+" + CRLF + ;
			"zEnvMail  - "+dToC(Date())+ " " + Time() + CRLF + ;
			"Funcao    - " + FunName() + CRLF + ;
			"Processos - " + cProcessos + CRLF + ;
			"Para      - " + cPara + CRLF + ;
			"Assunto   - " + cAssunto + CRLF + ;
			"Corpo     - " + cCorpo + CRLF + ;
			"Existem mensagens de aviso: "+ CRLF +;
			cLog + CRLF +;
			"+======================= zEnvMail =======================+"
		//ConOut(cLog)

		//Se for para mostrar o log visualmente e for processo com interface com o usuário, mostra uma mensagem na tela
		If lMostraLog .And. ! IsBlind()
			Aviso("Log", cLog, {"Ok"}, 2)
		EndIf
	EndIf

	RestArea(aArea)
Return lRet
















