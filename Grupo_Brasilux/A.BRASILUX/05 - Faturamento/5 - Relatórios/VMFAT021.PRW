#include 'rwmake.ch'
#include 'avprint.ch'
#include 'topconn.ch'
#include 'font.ch'
//#include 'avprinte.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VMFAT021 ºAutor  ³                    º Data ³  15/04/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio do bordero de cargas Brasilux para Viamix.       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ VIAMIX                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function VMFAT021()
	Local cQry
    Private cPerg := padr("VMF021",10)
     u_zcfga01( 'VMFAT021' ) //LGS#2021201 - Gravação de log de utilização da rotina
    
    oFont1 := TFont():New( "Courier New Negrito"        , 9, 19, .F., .T., 5, .T., 5, .F., .F.)
    oFont2 := TFont():New( "Courier New Negrito"        , 9, 12, .F., .T., 5, .T., 5, .F., .F.)
    oFont3 := TFont():New( "Courier New Negrito"        , 9, 08, .F., .T., 5, .T., 5, .F., .F.)
    oFont4 := TFont():New( "Courier New"                , 9, 08, .F., .F., 5, .T., 5, .F., .F.)
    oFont5 := TFont():New( "Courier New Negrito Itálico", 9, 12, .F., .T., 5, .T., 5, .T., .F.)
     
    //VldPerg()
    If !Pergunte(cPerg,.t.)
       Return
    endif       
//        MsAguarde({|| FAT0211() },"Aguarde","Buscando informações conforme parâmetros...")
		cQry := "WITH TMP AS ("+;
		"SELECT RIGHT(ZB_PEDIDO,6) AS F2_PEDIDO,CODRED = CASE WHEN ISNULL(ZZ0_CGCRED,'') > '' THEN "+;
		"(SELECT TOP 1 A4_COD FROM "+RetSqlName("SA4")+" WITH (NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND (A4_FILIAL = '"+xFilial("SA4")+"') AND (A4_CGC = ZZ0.ZZ0_CGCRED)) ELSE SA4.A4_COD END,"+;
       	"ISNULL(F2_SERIE,'') AS SERIE,ISNULL(F2_DOC,'') AS NFISCA,"+;
       	"ZZ0_CNPJ = CASE WHEN C5_TIPO IN ('D','B') THEN A2_CGC ELSE A1_CGC END,"+;
       	"ZZ0_RAZAO = CASE WHEN C5_TIPO IN ('D','B') THEN A2_NOME ELSE A1_NOME END,"+;
       	"ISNULL(Z7_NOME,'') AS ZZ0_MUNENT,F2_VALMERC ,"+;
       	"C5_PBRUTO AS ZZ0_PBRUTO,C5_VOLUME1 AS ZZ0_VOLUME "+;
       	"FROM "+RetSqlName("SZB")+" SZB WITH (NOLOCK) "+;
       	"LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = '"+xFilial("SC5")+"') AND (SUBSTRING(ZB_PEDIDO,3,6) = C5_NUM) "+;
       	"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (C5_CLIENTE = A1_COD) "+;
       	"LEFT OUTER JOIN "+RetSqlName("SZ7")+" SZ7 WITH (NOLOCK) ON (SZ7.D_E_L_E_T_ <> '*') AND (Z7_FILIAL = '"+xFilial("SZ7")+"') AND (A1_CODCID = Z7_COD) "+;
       	"LEFT OUTER JOIN "+RetSqlName("SA2")+" SA2 WITH (NOLOCK) ON (SA2.D_E_L_E_T_ <> '*') AND (A2_FILIAL = '"+xFilial("SA2")+"') AND (C5_CLIENTE = A2_COD) "+;
       	"LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (ZB_FILIAL = '"+xFilial("SZB")+"') AND (SUBSTRING(ZB_PEDIDO,3,6) = F2_PEDIDO) "+;
       	"LEFT OUTER JOIN "+RetSqlName("SA4")+" SA4 WITH (NOLOCK) ON (SA4.D_E_L_E_T_ <> '*') AND (A4_FILIAL = '"+xFilial("SA4")+"') AND (C5_REDESP = SA4.A4_COD) "+;
       	"LEFT OUTER JOIN "+RetSqlName("ZZ0")+" ZZ0 WITH (NOLOCK) ON (ZZ0.D_E_L_E_T_ <> '*') AND (ZZ0_FILIAL = '"+xFilial("ZZ0")+"') AND (ZB_CODIGO = ZZ0_BORDER) AND (SUBSTRING(ZB_PEDIDO,3,6) = ZZ0_PEDIDO) "+;
       	"WHERE (SZB.D_E_L_E_T_ <> '*') AND (SZB.ZB_FILIAL = '"+xFilial("SZB")+"') "+;
       	"AND (SZB.ZB_CODIGO  = '"+mv_par01+"')) SELECT TMP.*,CGCRED = A4_CGC, ZZ0_REDESP = CODRED,"+;
       	"A4_NOME,A4_TEL, "+;
       	"ZZ0_VALFAT = CASE WHEN TMP.NFISCA > '' THEN TMP.F2_VALMERC ELSE ( "+;
       	"SELECT SUM(C6_VALOR) FROM "+RetSqlName("SC6")+" WITH (NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND (C6_FILIAL = '"+xFilial("SC6")+"') AND (C6_NUM = TMP.F2_PEDIDO)"+;
       	") END "+;
       	"FROM TMP "+;
       	"LEFT OUTER JOIN "+RetSqlName("SA4")+" SA4 WITH (NOLOCK) ON (SA4.D_E_L_E_T_ <> '*') AND (A4_FILIAL = '"+xFilial("SA4")+"') AND (CODRED = A4_COD) "+;
       	"ORDER BY CODRED,SERIE,NFISCA,F2_PEDIDO"
		TCQUERY cQry ALIAS "TCQ" NEW
        DbSelectArea('TCQ')
        DbGoTop()
        If Eof()
           MsgBox("Não há dados a serem processados com estes parâmetros!!!","Atenção","STOP")
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

       AVPRINT oPrn NAME "RELATÓRIO PARA CARREGAMENTO"
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
                       oPrn:Say( nLin, nCol+1450, Transform(TCQ->ZZ0_VALFAT, "@E 999,999.99")       , oFont4)
                       oPrn:Line(nlin-0010, nCol+1630, nlin+0050, nCol+1630)
                       oPrn:Say( nLin, nCol+1650, Transform(TCQ->ZZ0_PBRUTO, "@E 999,999.99")       , oFont4)
                       oPrn:Line(nlin-0010, nCol+1830, nlin+0050, nCol+1830)
                       oPrn:Say( nLin, nCol+1850, Transform(TCQ->ZZ0_VOLUME, "@E 9999")             , oFont4)
                       oPrn:Line(nlin-0010, nCol+1950, nlin+0050, nCol+1950)
                       oPrn:Say( nLin, nCol+1970, TCQ->CODRED+" - "+cRedesp             , oFont4)
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
       oPrn:Say( nLin, nCol+800, "RELATÓRIO PARA REDESPACHO - BORDERO "+mv_par01, oFont1)
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
       oPrn:Say( nLin     , nCol+1840, "VOLUME"  , oFont3)
       oPrn:Line(nlin-0010, nCol+1950, nlin+0050, nCol+1950)
       oPrn:Say( nLin     , nCol+2500, "REDESPACHO"  , oFont3)
       nLin += 40
Return
/* desabilitado release 12.1.25
Static Function VldPerg()
Local _sAlias
       _sAlias := Alias()
       PutSX1(cPerg, "01","Bord Despacho:","Bord Despacho:","Bord Despacho:","mv_ch1","C",6,0,0,"G"," ","SZA"," "," ","mv_par01"," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," ",{},{},{}) 

       dbSelectArea(_sAlias)
Return
*/
