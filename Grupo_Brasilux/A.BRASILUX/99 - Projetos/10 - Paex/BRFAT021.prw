#include 'rwmake.ch'
#include 'avprint.ch'
#include 'topconn.ch'
#include 'font.ch'
//#include 'avprinte.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFAT021 ºAutor  ³                    º Data ³  13/11/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio do bordero de cargas Brasilux para Viamix.       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ DEPÓSITO SP (VMFAT021 ALTERADO)                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRFAT021()
	
	Local cQry
     
    Private cPerg := padr("BRF021",10)

    oFont1 := TFont():New( "Courier New Negrito"        , 9, 19, .F., .T., 5, .T., 5, .F., .F.)
    oFont2 := TFont():New( "Courier New Negrito"        , 9, 12, .F., .T., 5, .T., 5, .F., .F.)
    oFont3 := TFont():New( "Courier New Negrito"        , 9, 08, .F., .T., 5, .T., 5, .F., .F.)
    oFont4 := TFont():New( "Courier New"                , 9, 08, .F., .F., 5, .T., 5, .F., .F.)
    oFont5 := TFont():New( "Courier New Negrito Itálico", 9, 12, .F., .T., 5, .T., 5, .T., .F.)
     
    //VldPerg()  //LGS#20200210 - Adequação de release 12.1.25 e posteriores
    If !Pergunte(cPerg,.t.)
       Return
    Endif       

	cQry := " WITH TMP AS ( " 
	cQry += " SELECT (C5_NUM) AS F2_PEDIDO,CODRED = CASE WHEN ISNULL(ZZ0_CGCRED,'') > '' THEN "
	cQry += " (SELECT TOP 1 A4_COD FROM "+RetSqlName("SA4")+" WITH (NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND (A4_FILIAL = '"+xFilial("SA4")+"') AND (A4_CGC = ZZ0.ZZ0_CGCRED)) ELSE SA4.A4_COD END, "
	cQry +=	" ISNULL(F2_SERIE,'') AS SERIE,ISNULL(F2_DOC,'') AS NFISCA, "
    cQry += " ZZ0_CNPJ = CASE WHEN C5_TIPO IN ('D','B') THEN A2_CGC ELSE A1_CGC END, "
    cQry += " ZZ0_RAZAO = CASE WHEN C5_TIPO IN ('D','B') THEN A2_NOME ELSE A1_NOME END, "
    cQry += " ISNULL(Z7_NOME,'') AS ZZ0_MUNENT,F2_VALMERC , ZG_LOCALIZ AS LOCALIZ, "
    cQry += " C5_PBRUTO AS ZZ0_PBRUTO,C5_VOLUME1 AS ZZ0_VOLUME, C6_QTDVEN, SUM(ZZK_QUANT) AS ZZK_QUANT, ISNULL(ZZ0_ENTREG,'N') AS ZZ0_ENTREG,  "
    cQry += " CASE WHEN (C5_XNROCOL)<>'' OR (ZZ0_NROCOL)<>'' THEN 'S' ELSE 'N' END AS ZZ0_COLETA
    cQry += " FROM "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) "
    cQry += " LEFT OUTER JOIN "+RetSqlName("SZB")+" SZB WITH (NOLOCK) ON (SZB.D_E_L_E_T_ <> '*') AND (ZB_FILIAL  = '"+xFilial("SZB")+"') AND (SUBSTRING(ZB_PEDIDO,3,6) = C5_NUM) "
    cQry += " LEFT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH (NOLOCK) ON (SZG.D_E_L_E_T_ <> '*') AND (ZG_FILIAL  = '"+xFilial("SZG")+"') AND (SUBSTRING(ZG_PEDIDO,3,6) = C5_NUM) "
    cQry += " LEFT OUTER JOIN "+RetSqlName("SZF")+" SZF WITH (NOLOCK) ON (SZF.D_E_L_E_T_ <> '*') AND (ZF_FILIAL  = '"+xFilial("SZF")+"') AND (ZF_CODIGO = ZG_CODIGO) "
    cQry += " LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL  = '"+xFilial("SA1")+"') AND (C5_CLIENTE = A1_COD) "
    cQry += " LEFT OUTER JOIN "+RetSqlName("SZ7")+" SZ7 WITH (NOLOCK) ON (SZ7.D_E_L_E_T_ <> '*') AND (Z7_FILIAL  = '"+xFilial("SZ7")+"') AND (A1_CODCID = Z7_COD) "
    cQry += " LEFT OUTER JOIN "+RetSqlName("SA2")+" SA2 WITH (NOLOCK) ON (SA2.D_E_L_E_T_ <> '*') AND (A2_FILIAL  = '"+xFilial("SA2")+"') AND (C5_CLIENTE = A2_COD) "
    cQry += " LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (ZB_FILIAL  = '"+xFilial("SZB")+"') AND (SUBSTRING(ZB_PEDIDO,3,6) = F2_PEDIDO) "
    cQry += " LEFT OUTER JOIN "+RetSqlName("SA4")+" SA4 WITH (NOLOCK) ON (SA4.D_E_L_E_T_ <> '*') AND (A4_FILIAL  = '"+xFilial("SA4")+"') AND (C5_REDESP = SA4.A4_COD) "
    cQry += " LEFT OUTER JOIN "+RetSqlName("ZZ0")+" ZZ0 WITH (NOLOCK) ON (ZZ0.D_E_L_E_T_ <> '*') AND (ZZ0_FILIAL = '"+xFilial("ZZ0")+"') AND (C5_NUM = ZZ0_PEDIDO) "
	cQry +=	" LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON (SC6.D_E_L_E_T_ <> '*') AND (C6_FILIAL  = '"+xFilial("SC6")+"') AND (C5_NUM = C6_NUM) " 
	cQry +=	" LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) ON (ZZK.D_E_L_E_T_ <> '*') AND (ZZK_FILIAL = '"+xFilial("ZZK")+"') AND (ZZK_PRODUT = C6_PRODUTO) AND (ZZK_PEDIDO = C6_NUM) "
	cQry +=	" LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL  = '"+xFilial("SB1")+"') AND (B1_COD = C6_PRODUTO) "
    cQry += " WHERE (SC5.D_E_L_E_T_ <> '*') AND (SC5.C5_FILIAL = '"+xFilial("SC5")+"') AND (ZZ0.R_E_C_N_O_ IS NOT NULL) "
	cQry += " AND (C5_TRANSP ='00700') AND (C5_EMISSAO >'20150901') "
	cQry += " AND B1_TIPO ='PA' AND SUBSTRING(B1_COD,1,2) NOT IN('ST') "
	cQry += " AND DATEDIFF(DAY,ZF_EMISSAO,GETDATE() )>0  "  // NÃO CONSIDERAR BORDERO DE PEDIDOS DO MESMO DIA PARA NÃO TRAZER PEDIDOS QUE AINDA NÃO FORAM DESPACHADOS
	cQry += " GROUP BY C5_NUM, F2_SERIE, F2_DOC,C5_TIPO,ZZ0_CGCRED,A4_COD, A1_CGC, A2_CGC, A1_NOME, A2_NOME,Z7_NOME, F2_VALMERC,C5_PBRUTO, C5_VOLUME1, C6_PRODUTO, C6_QTDVEN, ZG_LOCALIZ, ZZ0_ENTREG,C5_XNROCOL, ZZ0_NROCOL ) "
    cQry += " SELECT TMP.ZZ0_PBRUTO, TMP.F2_PEDIDO, TMP.SERIE, TMP.NFISCA,TMP.ZZ0_RAZAO,A4_COD, TMP.ZZ0_CNPJ, TMP.ZZ0_RAZAO,TMP.ZZ0_VOLUME,TMP.CODRED,TMP.ZZ0_MUNENT,TMP.ZZ0_VOLUME,  TMP.F2_VALMERC ,CGCRED = A4_CGC, ZZ0_REDESP = CODRED, A4_NOME, A4_TEL, SUM(TMP.C6_QTDVEN), SUM(TMP.ZZK_QUANT),  "
    cQry += " TMP.ZZ0_COLETA, TMP.LOCALIZ, ZZ0_VALFAT = CASE WHEN TMP.NFISCA > '' THEN TMP.F2_VALMERC ELSE ( "
    cQry += " SELECT SUM(C6_VALOR) FROM "+RetSqlName("SC6")+" WITH (NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND (C6_FILIAL = '"+xFilial("SC6")+"') AND (C6_NUM = TMP.F2_PEDIDO)) END "
    cQry += " FROM TMP "
    cQry += " LEFT OUTER JOIN "+RetSqlName("SA4")+" SA4 WITH (NOLOCK) ON (SA4.D_E_L_E_T_ <> '*') AND (A4_FILIAL = '"+xFilial("SA4")+"') AND (CODRED = A4_COD) "
    cQry += " WHERE (TMP.ZZ0_ENTREG ='N' OR TMP.ZZ0_ENTREG ='') "
    cQry += " GROUP BY TMP.F2_PEDIDO, TMP.SERIE, TMP.NFISCA,TMP.ZZ0_RAZAO,A4_COD, TMP.ZZ0_CNPJ, TMP.ZZ0_RAZAO,TMP.ZZ0_VOLUME,TMP.CODRED,TMP.ZZ0_MUNENT,TMP.ZZ0_VOLUME, A4_CGC, A4_NOME,A4_TEL, TMP.F2_VALMERC, TMP.ZZ0_PBRUTO, TMP.LOCALIZ, TMP.ZZ0_COLETA  "
	cQry += " HAVING SUM(TMP.C6_QTDVEN) <= SUM(TMP.ZZK_QUANT) "
    If MV_PAR02 == 1
		cQry += " AND TMP.ZZ0_COLETA ='N' "
	ElseIf MV_PAR02 == 2
		cQry += " AND TMP.ZZ0_COLETA ='S' "	
	Endif
    If MV_PAR01 == 1
	    cQry += " ORDER BY CODRED,SERIE,NFISCA,F2_PEDIDO "
    Else
	    cQry += " ORDER BY TMP.LOCALIZ,CODRED,SERIE,NFISCA,F2_PEDIDO "
	Endif    
	TCQUERY cQry ALIAS "TCQ" NEW
    
    DbSelectArea('TCQ')
    DbGoTop()

    If Eof()
    	MsgBox("Não há dados a serem processados com estes parâmetros !!","Atenção","STOP")
        DbSelectArea("TCQ")
        DbCloseArea()
        Return
    Else  
        Processa({|lEnd| FAT0212()})
    Endif

	DbSelectArea("TCQ")
	DbCloseArea()

Return


// Relatorio
Static Function FAT0212()
       //Local aMatDad    := {}
       Private nlinMax  := 2280
       Private nColMax  := 3385
       Private nLin     := 0
       Private nCol     := 30

       AVPRINT oPrn NAME "RELATÓRIO DE PEDIDOS BIPADOS, PRONTOS PARA FATURAMENTO / PEDIDO DE COLETA"
               oPrn:SetPage(9)
               oPrn:SetLandscape()
               AVPAGE
                 fCab0212()
                 DbSelectArea("TCQ")
                 dbgotop()
                 While !Eof()
                       cRedesp := TCQ->A4_NOME+" - "+TCQ->A4_TEL
                       
                       oPrn:Line(nlin     , nCol     , nlin+0060, nCol     )
                       nLin += 15 
                       oPrn:Say( nLin, nCol+0020, IIF(!EMPTY(TCQ->NFISCA),TCQ->NFISCA,"*"+TCQ->F2_PEDIDO+"*"), oFont4)
                       oPrn:Line(nlin-0010, nCol+0160, nlin+0050, nCol+0160)
                       oPrn:Say( nLin, nCol+0180, Transform(TCQ->ZZ0_CNPJ, "@R 99.999.999/9999-99"), oFont4)
                       oPrn:Line(nlin-0010, nCol+0500, nlin+0050, nCol+0500)
                       oPrn:Say( nLin, nCol+0520, SubStr(TCQ->ZZ0_RAZAO , 01, 30)                  , oFont4)
                       oPrn:Line(nlin-0010, nCol+1050, nlin+0050, nCol+1050)
                       oPrn:Say( nLin, nCol+1070, SubStr(TCQ->ZZ0_MUNENT, 01, 20)                  , oFont4)
                       oPrn:Line(nlin-0010, nCol+1430, nlin+0050, nCol+1430)
                       oPrn:Say( nLin, nCol+1450, Transform(TCQ->ZZ0_VALFAT, "@E 999,999.99")      , oFont4)
                       oPrn:Line(nlin-0010, nCol+1630, nlin+0050, nCol+1630)
                       oPrn:Say( nLin, nCol+1650, Transform(TCQ->ZZ0_PBRUTO, "@E 999,999.99")      , oFont4)
                       oPrn:Line(nlin-0010, nCol+1830, nlin+0050, nCol+1830)
                       oPrn:Say( nLin, nCol+1870, Transform(TCQ->ZZ0_VOLUME, "@E 9999")            , oFont4)
                       oPrn:Line(nlin-0010, nCol+2000, nlin+0050, nCol+2000)
                       oPrn:Say( nLin, nCol+2030, Substr(TCQ->LOCALIZ,1,15)				           , oFont4)
                       oPrn:Line(nlin-0010, nCol+2210, nlin+0050, nCol+2210)
                       oPrn:Say( nLin, nCol+2230, Iif(TCQ->ZZ0_COLETA ='S','Sim','Não')            , oFont4)
                       oPrn:Line(nlin-0010, nCol+2300, nlin+0050, nCol+2300)
                       oPrn:Say( nLin, nCol+2330, TCQ->CODRED+" - "+cRedesp                        , oFont4)
                       oPrn:Line(nlin-0010, nColMax  , nlin+0045, nColMax  )
                       
                       nLin += 45
                       oPrn:Line(nlin, nCol    , nlin, nColMax    )
                       If nLin >= nLinMax
                          AVNEWPAGE
                            nLin := 0
                            fCab0212()
                       Endif  
                       DbSelectArea("TCQ")
                       DbSkip()
                 Enddo

               AVENDPAGE
       AVENDPRINT
       MS_FLUSH()

Return

//Cabecalho do relatorio
Static Function fCab0212()
       nLin += 30  // linha 30
       oPrn:Box( nLin, nCol, nLin+120, nColMax ) //Box da Linha 30 até a 150
       nLin += 30 // linha 60
       oPrn:Say( nLin, nCol+800, "RELATÓRIO DE PEDIDOS PRONTOS - BIPADOS", oFont1)
       nLin += 100 // linha 160
       oPrn:Box( nLin, nCol    , nLin+60, nColMax ) //Box da linha 160 até 220
       nLin += 10 // Linha 240
       oPrn:Say( nLin     , nCol+0020, "NOTA/*PED*", oFont3)
       oPrn:Line(nlin-0010, nCol+0160, nlin+0050, nCol+0160)
       oPrn:Say( nLin     , nCol+0280, "CNPJ"        , oFont3)
       oPrn:Line(nlin-0010, nCol+0500, nlin+0050, nCol+0500)
       oPrn:Say( nLin     , nCol+0700, "DESTINATARIO", oFont3)
       oPrn:Line(nlin-0010, nCol+1050, nlin+0050, nCol+1050)
       oPrn:Say( nLin     , nCol+1150, "CIDADE"      , oFont3)
       oPrn:Line(nlin-0010, nCol+1430, nlin+0050, nCol+1430)
       oPrn:Say( nLin     , nCol+1450, "VALOR(R$)"   , oFont3)
       oPrn:Line(nlin-0010, nCol+1630, nlin+0050, nCol+1630)
       oPrn:Say( nLin     , nCol+1650, "PESO (KG)"   , oFont3)
       oPrn:Line(nlin-0010, nCol+1830, nlin+0050, nCol+1830)
       oPrn:Say( nLin     , nCol+1840, "VOLUME"      , oFont3)
       oPrn:Line(nlin-0010, nCol+2000, nlin+0050, nCol+2000)
       oPrn:Say( nLin     , nCol+2010, "LOCALIZAÇÃO" , oFont3)
       oPrn:Line(nlin-0010, nCol+2210, nlin+0050, nCol+2210)
       oPrn:Say( nLin     , nCol+2220, "SOL."        , oFont3)
       oPrn:Line(nlin-0010, nCol+2300, nlin+0050, nCol+2300)
       oPrn:Say( nLin     , nCol+2500, "REDESPACHO"  , oFont3)
       nLin += 40
Return

//LGS#20200210 - Adequação de release 12.1.25 e posteriores
/*Static Function VldPerg()
	Local _sAlias
	Local aHelp :={}

	AAdd(aHelp, {{"Ordenar os registro por Redespacho ou por Localização?"},  {""}, {""}})
    AAdd(aHelp, {{"Mostrar todos os pedidos, somente sem sol. de coleta ou somente com sol. de coleta"},  {""}, {""}})

	_sAlias := Alias()

	PutSX1(cPerg, "01","Ordenado Por:         " ,"","","mv_ch1","N",1,00,00,"C","","","","","MV_PAR01","Redespacho             ","","","","Localização           ","","","     ","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
	PutSX1(cPerg, "02","Mostra Pedidos com:?: " ,"","","mv_ch2","N",1,00,00,"C","","","","","MV_PAR02","Coletas Não Solicitadas","","","","Coletas Já Solicitadas","","","Todos","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")
    //PutSX1(cPerg,"05","Filtrar por: " ,"","","mv_ch5","N",1,00,00,"C","","","","","MV_PAR05","Alteracao","","","","Acerto","","","Reenvase","","","Recuperacao","","","Todos","","",aHelp[5,1],aHelp[5,2],aHelp[5,3],"")
    dbSelectArea(_sAlias)
    
Return */
