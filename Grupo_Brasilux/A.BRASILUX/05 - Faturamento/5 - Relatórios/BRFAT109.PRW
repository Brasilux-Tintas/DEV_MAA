#Include "RWMAKE.CH"
#Include "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫FunÁ„o    ≥ BRFAT105 ∫ Autor ≥ Nelieder Corneta   ∫ Data ≥  26/10/2021 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫DESCRICAO ≥ RelatÛrio CT-e                                             ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/


User Function BRFAT109()

Private cPerg 
Private aPlBrasi  := {} /* Planilha Brasilux */
Private aPlDissol := {} /* Planilha Dissoltex */
Private nComissao
Private BTributos := 0 /* Tributos Brasilux */
Private DTributos := 0 /* Tributos Dissoltex */
Private nICMS
Private aArray := {}
Private cLiberado := .F.

cUsuario = RetCodUsr()

/* 000723 - Nelieder*/

 if (cUsuario $ GETMV("ZP_PAR0065") )                 
     cLiberado := .T.
 Endif


if !cLiberado
    MsgAlert('Usu·rio sem acesso !')
    return()
EndIf    


cPerg := PADR("BRFAT109",10," ")
If !Pergunte(cPerg, .T.)  // Pergunta no SX1
    return()
Endif
/* ler dados das planilhas */
LePDV()




FWMsgRun( , { || ReportPrint() }, "Aguarde.....", "Consultando dados na base de dados...." )


return()

Static Function ReportPrint()

Local oFWMsExcel
Local oExcel
Local cArquivo      := GetTempPath()+'brfat109.xml'

Local cPerIni   := DTOS(mv_par01) //"20220201"
Local cPerFim   := DTOS(mv_par02) //"20220228"

Local cPerIni12 := DTOS(mv_par05) //"20220201" /* Emissao Litragem*/
Local cPerFim12 := DTOS(mv_par06) //"20220228" /* Emissao Litragem*/
Local BJuros := Alltrim(Str(mv_par03))  //0.98056333  0,98056333 
Local DJuros := Alltrim(Str(mv_par04))  //0.98056333  0,98056333 
Local pMarge,MargLiq
Local Chave := ""
Local PSimula
Local TabEvi := ""
Local TitTab1 := ""
Local vDolar 




nICMS := GETMV("MV_ICMPAD")
nComissao := mv_par09

/*
[1] PIS              aPlBrasi[1][2]    
[2] COFINS           aPlBrasi[2][2]
[3] CONTR.SOCIAL     aPlBrasi[3][2]
[4] IR SOB LUCRO     aPlBrasi[4][2]
[5] CPMF             aPlBrasi[5][2]
[6] DESP ADMI        aPlBrasi[6][2]
[7] GASTOS GERAIS    aPlBrasi[7][2]
[8] DESP COMERCI     aPlBrasi[8][2]
*/

//Local vMarge
              /* PIS          COFINS       CONTR.SOCIA IR LUCRO     DESP.ADMI     GASTOS GE  + DESP COMER                                                             */                                                             */ 
    BTributos := aPlBrasi[1][2] + aPlBrasi[2][2] + aPlBrasi[3][2] + aPlBrasi[4][2] + aPlBrasi[6][2] + aPlBrasi[7][2] + aPlBrasi[8][2]

    /* PIS          COFINS       CONTR.SOCIA IR LUCRO     DESP.ADMI     GASTOS GE  + DESP COMER                                                             */                                                             */ 
    DTributos := aPlDissol[1][2] + aPlDissol[2][2] + aPlDissol[3][2] + aPlDissol[4][2] + aPlDissol[6][2] + aPlDissol[7][2] + aPlDissol[8][2]

/*    cQuery1 := " WITH TMP AS ( "
    cQuery1 += " SELECT B1_FILIAL AS 'FILIAL', "
    cQuery1 += " '01/'+SUBSTRING('"+cPerIni+"',5,2)+'/'+SUBSTRING('"+cPerIni+"',1,4) AS 'PERIODO', "
    cQuery1 += " ISNULL((CASE WHEN LEN(B1_COD) = 12 THEN SUBSTRING(B1_COD,4,2)+'-'+Z1_DESCR END),B1_TIPO) AS 'DESC_LINHA',  "
    cQuery1 += " B1_COD AS 'PRODUTO', B1_DESC AS 'DESCRICAO', SUBSTRING(B1_COD,1,15)+' - '+ B1_DESC AS 'DESCRI«√OCOMPLETA', B1_UM AS 'UNID', 0 AS 'QTDE UNIT', "
    cQuery1 += " 'VOLUME'     = 0,  "
    cQuery1 += " 'FATBRUTO'   = 0,  "
    cQuery1 += " 'FATBRUTO1'  = 0,  "
    cQuery1 += " 'IPI'        = 0,  "
    cQuery1 += " 'IPI1'       = 0,  "
    cQuery1 += " 'ICMSST'     = 0,  "
    cQuery1 += " 'ICMSST1'    = 0,  "
    cQuery1 += " 'ICMS'       = 0,  "
    cQuery1 += " 'PIS'        = 0,  "
    cQuery1 += " 'COFINS'     = 0,  "
    cQuery1 += " 'DESCONTO'   = 0,  "
    cQuery1 += " 'CPV'        = 0   "
    cQuery1 += " FROM SB1010 SB1 WITH (NOLOCK)  "
    cQuery1 += " LEFT OUTER JOIN SZ1010 SZ1 WITH (NOLOCK) ON (SZ1.D_E_L_E_T_ <> '*') AND (Z1_FILIAL = SUBSTRING(B1_FILIAL,1,2)) AND (Z1_LINHA = SUBSTRING(B1_COD,4,2)) AND SZ1.D_E_L_E_T_ ='' "
    cQuery1 += " WHERE SB1.D_E_L_E_T_ ='' "
    /* trata filial */
  //  cQuery1 += " AND SUBSTRING(B1_FILIAL,1,2) IN('01','06') "
    //cQuery1 += " AND B1_FILIAL = '"+xFilial("SB1")+"' "
    /*cQuery1 += " AND B1_GRUPO BETWEEN('PA00') AND ('PA99') "
    cQuery1 += " AND B1_MSBLQL <>'1' "
    cQuery1 += " AND SUBSTRING(B1_COD,11,2) NOT IN(CASE WHEN B1_FILIAL ='060101' THEN '38' ELSE '' END) "
    cQuery1 += " UNION ALL "
    cQuery1 += " SELECT D2_FILIAL AS 'FILIAL', "
    cQuery1 += " '01/'+SUBSTRING(D2_EMISSAO,5,2)+'/'+SUBSTRING(D2_EMISSAO,1,4) AS 'PERIODO', "
    cQuery1 += " ISNULL((CASE WHEN LEN(D2_COD) = 12 THEN SUBSTRING(D2_COD,4,2)+'-'+Z1_DESCR END),B1_TIPO) AS 'DESC_LINHA', " 
    cQuery1 += " SUBSTRING(D2_COD,1,12) AS 'PRODUTO', B1_DESC AS 'DESCRICAO', SUBSTRING(B1_COD,1,15)+' - '+ B1_DESC AS 'DESCRI«√OCOMPLETA', D2_UM AS 'UNID', D2_QUANT AS 'QTDE UNIT', "
    cQuery1 += " 'VOLUME'     = CASE WHEN D2_UM IN ('L','K','KG') OR LEN(B1_COD)<12 THEN D2_QUANT WHEN D2_SEGUM IN ('L','K','KG') THEN D2_QTSEGUM ELSE 0 END,  "
    cQuery1 += " 'FATBRUTO'   = CASE WHEN D2_TIPO <> 'I' THEN (D2_TOTAL+D2_VALIPI+D2_VALFRE+D2_DESPESA+D2_ICMSRET+D2_DESCON+D2_DESCZFR) ELSE CASE WHEN D2_TIPO ='I' AND F4_DUPLIC ='S' THEN D2_TOTAL ELSE 0 END END,  "
    cQuery1 += " 'FATBRUTO1'  = CASE WHEN D2_TIPO <> 'I' THEN (D2_TOTAL+D2_VALIPI+D2_VALFRE+D2_DESPESA+D2_ICMSRET+D2_DESCON+D2_DESCZFR) ELSE CASE WHEN D2_TIPO ='I' AND F4_DUPLIC ='S' THEN D2_TOTAL ELSE 0 END END,  "
    cQuery1 += " 'IPI'        = D2_VALIPI, "
    cQuery1 += " 'IPI1'       = D2_VALIPI, "
    cQuery1 += " 'ICMSST'     = D2_ICMSRET, "
    cQuery1 += " 'ICMSST1'    = D2_ICMSRET, "
    cQuery1 += " 'ICMS'       = (D2_VALICM+D2_DIFAL+D2_VFCPDIF), "
    cQuery1 += " 'PIS'        = D2_VALIMP6, "
    cQuery1 += " 'COFINS'     = D2_VALIMP5, "
    cQuery1 += " 'DESCONTO'   = (D2_DESCON+D2_DESCZFR), "
    cQuery1 += " 'CPV'        = D2_CUSTO1 "
    cQuery1 += " FROM SD2010 SD2 WITH(NOLOCK) "
    cQuery1 += " LEFT OUTER JOIN SB1010 SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = D2_FILIAL) AND (B1_COD = D2_COD)  "
    cQuery1 += " LEFT OUTER JOIN SA1010 SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '      ') AND (D2_CLIENTE = A1_COD) " 
    cQuery1 += " LEFT OUTER JOIN SF4010 SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (D2_TES = F4_CODIGO)  "
    cQuery1 += " LEFT OUTER JOIN SZ1010 SZ1 WITH (NOLOCK) ON (SZ1.D_E_L_E_T_ <> '*') AND (Z1_FILIAL = SUBSTRING(D2_FILIAL,1,2)) AND (Z1_LINHA = SUBSTRING(D2_COD,4,2)) AND SZ1.D_E_L_E_T_ ='' "
    cQuery1 += " WHERE SD2.D_E_L_E_T_='' "
    
    cQuery1 += " AND SUBSTRING(D2_FILIAL,1,2) IN('01','06') "
    //cQuery1 += " AND D2_FILIAL = '"+xFilial("SD2")+"' "

    cQuery1 += " AND D2_EMISSAO BETWEEN '"+cPerIni+"' AND '"+cPerFim+"'  "
    cQuery1 += " AND (D2_TIPO <> 'D')  "
    cQuery1 += " AND (F4_DUPLIC = 'S' OR D2_TIPO ='I' OR F4_CODIGO ='519') "
    cQuery1 += " AND (D2_CF IN('000','5101','5105','5106','5113','5118','5122','5124','5401','5403','5501','5502','5922','6101','6102','6105','6106','6107','6108','6113','6118','6122','6124','6401','6403','6501','6502','6922','7105','7106','5102','6109','6110','7101','7102') OR (D2_CF IN('5949','6949') AND D2_TES IN('519','520','540','559'))) "
    
    cQuery1 += " UNION ALL "
    cQuery1 += " SELECT D1_FILIAL AS FILIAL,  "
    cQuery1 += " '01/'+SUBSTRING(D1_DTDIGIT,5,2)+'/'+SUBSTRING(D1_DTDIGIT,1,4) AS 'PERIODO', "
    cQuery1 += " ISNULL((CASE WHEN LEN(D1_COD) = 12 THEN SUBSTRING(D1_COD,4,2)+'-'+Z1_DESCR END),B1_TIPO) AS 'DESC_LINHA',  "
    cQuery1 += " SUBSTRING(D1_COD,1,12) AS 'PRODUTO', B1_DESC AS 'DESCRICAO', SUBSTRING(B1_COD,1,15)+' - '+ B1_DESC AS 'DESCRI«√OCOMPLETA', D1_UM AS 'UNID', D1_QUANT AS 'QTDE UNIT', "
    cQuery1 += " 'VOLUME'     = 0, "
    cQuery1 += " 'FATBRUTO'   = (D1_TOTAL+D1_VALIPI+D1_VALFRE+D1_DESPESA+D1_ICMSRET) * -1,  "
    cQuery1 += " 'FATBRUTO1'   = 0,  "
    cQuery1 += " 'IPI'        = (D1_VALIPI *-1), "
    cQuery1 += " 'IPI1'        = 0, "
    cQuery1 += " 'ICMSST'     = CASE WHEN D1_ALIQSOL =20 THEN ((D1_ICMSRET - (D1_BRICMS * 0.02))*-1) ELSE (D1_ICMSRET*-1) END, "
    cQuery1 += " 'ICMSST1'     = 0, "
    cQuery1 += " 'ICMS'       = CASE WHEN A1_CLAS ='N' THEN (D1_VALICM*-1) ELSE ((D1_VALICM+D1_DIFAL+D1_VFCPDIF)*-1) END, "
    cQuery1 += " 'PIS'        = (D1_VALIMP6*-1), "
    cQuery1 += " 'COFINS'     = (D1_VALIMP5*-1), "
    cQuery1 += " 'DESCONTO'   = (D1_DESCZFR*-1), "
    cQuery1 += " 'CPV'        = (D1_CUSTO*-1) "
    cQuery1 += " FROM SD1010 SD1 WITH (NOLOCK)  "
    cQuery1 += " LEFT OUTER JOIN SB1010 SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = D1_FILIAL) AND (B1_COD = D1_COD) " 
    cQuery1 += " LEFT OUTER JOIN SA1010 SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '      ') AND (D1_FORNECE = A1_COD)  "
    cQuery1 += " LEFT OUTER JOIN SD2010 SD2 WITH (NOLOCK) ON (SD2.D_E_L_E_T_ <> '*') AND (D1_FILIAL = D2_FILIAL) AND (D1_SERIORI = D2_SERIE) AND (D1_NFORI = D2_DOC) AND (D1_FORNECE = D2_CLIENTE) AND (D1_COD = D2_COD) "
    cQuery1 += " LEFT OUTER JOIN SF4010 SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (D1_TES = F4_CODIGO)  "
    cQuery1 += " LEFT OUTER JOIN SZ1010 SZ1 WITH (NOLOCK) ON (SZ1.D_E_L_E_T_ <> '*') AND (Z1_FILIAL = SUBSTRING(D1_FILIAL,1,2)) AND (Z1_LINHA = SUBSTRING(D1_COD,4,2)) AND SZ1.D_E_L_E_T_ = '' "
    cQuery1 += " WHERE SD1.D_E_L_E_T_ = '' "
    
    cQuery1 += " AND SUBSTRING(D1_FILIAL,1,2)IN('01','06') "
    //cQuery1 += " AND D1_FILIAL = '"+xFilial("SD1")+"' "

    cQuery1 += " AND D1_DTDIGIT BETWEEN '"+cPerIni+"' AND '"+cPerFim+"'  "
    cQuery1 += " AND ((F4_DUPLIC = 'S'AND D1_CF <>'000') OR (F4_CODIGO ='082' AND D1_SERIORI ='F')) "
    cQuery1 += " AND D1_CF IN('000','1201','1202','1203','1204','2201','2202','2203','2204','1410','1411','1503','1504','2410','2411','2503','2504','3201','3202') "
    cQuery1 += " ), "
    cQuery1 += " TMP1 AS (SELECT FILIAL, CONVERT(varchar(10), EOMONTH(PERIODO), 112) AS PERIODO,[DESC_LINHA], PRODUTO, DESCRICAO, "
    cQuery1 += " SUM(VOLUME) AS 'VOLUME', SUM(CPV) AS 'CPV', "
    cQuery1 += " SUM(FATBRUTO) - SUM(IPI) - SUM(ICMSST) AS 'FATLIQVENDAS', "
    cQuery1 += " SUM(FATBRUTO1) - SUM(IPI1) - SUM(ICMSST1) AS 'FATLIQVENDAS1', "
    cQuery1 += " SUM(FATBRUTO) - (SUM(IPI) + SUM(ICMSST) + SUM(ICMS) + SUM(PIS) + SUM(COFINS) + SUM(DESCONTO)) AS 'RECEITALIQUIDA'  "
    cQuery1 += " FROM TMP "
    cQuery1 += " GROUP BY FILIAL, PERIODO, [DESC_LINHA],PRODUTO, DESCRICAO) "
    cQuery1 += " SELECT FILIAL, PERIODO, [DESC_LINHA],SUBSTRING(PRODUTO,1,12) AS PRODUTO, DESCRICAO,SUM(RECEITALIQUIDA) AS RECEITALIQ, SUM(CPV ) AS CPV, SUM(FATLIQVENDAS)  AS FATLIQVENDAS,SUM(FATLIQVENDAS1)  AS FATLIQVENDAS1,SUM(VOLUME) AS VOLUME, "
    cQuery1 += " CASE WHEN(SB1.B1_ESTOQUE)='S' THEN ROUND(SB1.B1_PRV1,2) ELSE ROUND(SB5.B5_PRV2,2) END AS PRECOTAB, CASE WHEN SB1.B1_ESTOQUE ='S' THEN 'SIM' ELSE '' END AS ESTOQUE, "
    cQuery1 += " CASE WHEN(SB1.B1_ESTOQUE)='S' THEN Z1_LUCRO ELSE Z1_LUCRO2 END AS LUCRO, "
    cQuery1 += " CASE WHEN SUBSTRING(FILIAL,1,2)='01' THEN  "
    //cQuery1 += " -- MATRIZ

    cQuery1 += " ROUND((dbo.CustoPro(SB1.B1_FILIAL,SB1.B1_COD,1)/("+BJuros+"-(("+AllTrim(str(BTributos))+"+"+AllTrim(str(nComissao))+"+"+AllTrim(str(nICMS))+"+CASE WHEN(SB1.B1_ESTOQUE)='S' THEN Z1_LUCRO ELSE Z1_LUCRO2 END))/100)),2) "
    cQuery1 += " ELSE "
    //cQuery1 += " -- DISSOLTEX

    cQuery1 += " ROUND((dbo.CustoPro(SB1.B1_FILIAL,SB1.B1_COD,1)/("+DJuros+"-(("+AllTrim(str(DTributos))+"+"+AllTrim(str(nComissao))+"+"+AllTrim(str(nICMS))+"+CASE WHEN(SB1.B1_ESTOQUE)='S' THEN Z1_LUCRO ELSE Z1_LUCRO2 END))/100)),2) "
    cQuery1 += " END AS 'SIMULA', "
    cQuery1 += " (SELECT SUM(D2_QTSEGUM) FROM SD2010 SD2 WITH(NOLOCK) WHERE FILIAL = D2_FILIAL AND PRODUTO = D2_COD AND SD2.D_E_L_E_T_ ='' AND D2_GRUPO BETWEEN('PA00') AND ('PA99') AND (D2_ESTOQUE ='S' OR D2_XESTOQU ='S') AND D2_EMISSAO BETWEEN('"+cPerIni12+"') AND ('"+cPerFim12+"')) AS LITRAGEM, "
    cQuery1 += " dbo.CustoPro(SB1.B1_FILIAL,SB1.B1_COD,1) AS CUSTOPRO, dbo.CustoMp(SB1.B1_FILIAL,SB1.B1_COD,1) AS CUSTOMP, "
    cQuery1 += " Z99_GGFCON AS GGF, Z99_MOCONS AS MO, Z99_REQCON AS REQ, B1_CONV "
    cQuery1 += " FROM TMP1  "
    cQuery1 += " LEFT OUTER JOIN SB1010 SB1 ON B1_FILIAL = FILIAL AND B1_COD = PRODUTO AND SB1.D_E_L_E_T_ ='' "
    cQuery1 += " LEFT OUTER JOIN SB5010 SB5 ON B5_FILIAL = B1_FILIAL AND B1_COD = B5_COD AND SB5.D_E_L_E_T_ ='' "
    cQuery1 += " LEFT OUTER JOIN SZ1010 SZ1 ON Z1_FILIAL = SUBSTRING(B1_FILIAL,1,2) AND Z1_LINHA = SUBSTRING(B1_COD,4,2) AND SZ1.D_E_L_E_T_ ='' "
    cQuery1 += " LEFT OUTER JOIN Z99010 Z99 ON Z99_FILIAL = B1_FILIAL AND Z99_COD = PRODUTO AND Z99_DATA = '"+cPerFim+"' AND Z99.D_E_L_E_T_ ='' "
    cQuery1 += " WHERE  "
    cQuery1 += " B1_GRUPO BETWEEN('PA00') AND ('PA99') "
    cQuery1 += " and FATLIQVENDAS <> 0 "
    cQuery1 += " AND (SELECT SUM(D2_QTSEGUM) FROM SD2010 SD2 WITH(NOLOCK) WHERE FILIAL = D2_FILIAL AND PRODUTO = D2_COD AND SD2.D_E_L_E_T_ ='' AND D2_GRUPO BETWEEN('PA00') AND ('PA99') AND (D2_ESTOQUE ='S' OR D2_XESTOQU ='S') AND D2_EMISSAO BETWEEN('"+cPerIni12+"') AND ('"+cPerFim+"')) >0 "
    cQuery1 += " GROUP BY FILIAL, PERIODO, [DESC_LINHA], PRODUTO, DESCRICAO,B1_FILIAL,B1_COD,B1_ESTOQUE,Z1_LUCRO, Z1_LUCRO2,B1_PRV1, B5_PRV2, Z99_GGFCON, Z99_MOCONS, Z99_REQCON, B1_CONV "
    cQuery1 += " ORDER BY FILIAL, [DESC_LINHA],B1_COD "*/


    //cQuery1 := " DECLARE @cPerIni VARCHAR(8),@cPerFim VARCHAR(8), @cPerIni12 VARCHAR(8),@cPerFim12 VARCHAR(8) "

   /* cQuery1 += " SET @cPerIni  = '20220801' ; "
    cQuery1 += " SET @cPerFim  = '20220831' ; "
    cQuery1 += " SET @cPerIni12 ='20210901' ; "
    cQuery1 += " SET @cPerFim12 ='20220831' ; "*/

    /*cPerIni   := '20220801' 
    cPerFim   := '20220831' 
    cPerIni12 := '20210901' 
    cPerFim12 := '20220831' */

    if Empty(cPerIni) .OR. Empty(cPerFim) .OR. Empty(cPerIni12) .OR. Empty(cPerFim12)

        MsgAlert('Informar Periodos !')
        return()

    EndIf

    /* Pega valor do dolar */
    cQry := "SELECT TOP 1 M2_MOEDA2 FROM SM2010 WHERE M2_MOEDA2 > 0 "
    cQry += "ORDER BY M2_DATA DESC "
    TCQuery cQry ALIAS "TCQ" NEW
    vDolar := TCQ->M2_MOEDA2


    
    cQuery1 := " WITH TMP AS ( "
 
    cQuery1 += " SELECT B1_FILIAL AS 'FILIAL', "
    cQuery1 += " '01/'+SUBSTRING('"+cPerIni+"',5,2)+'/'+SUBSTRING('"+cPerIni+"',1,4) AS 'PERIODO', "
    cQuery1 += " ISNULL((CASE WHEN LEN(B1_COD) = 12 THEN SUBSTRING(B1_COD,4,2)+'-'+Z1_DESCR END),B1_TIPO) AS 'DESC_LINHA',  "
    cQuery1 += " B1_COD AS 'PRODUTO', B1_DESC AS 'DESCRICAO', SUBSTRING(B1_COD,1,15)+' - '+ B1_DESC AS 'DESCRI«√OCOMPLETA', B1_UM AS 'UNID', 0 AS 'QTDE UNIT', "
    cQuery1 += " 'VOLUME'     = 0,  "
    cQuery1 += " 'FATBRUTO'   = 0,  "
    cQuery1 += " 'FATBRUTO1'  = 0,  "
    cQuery1 += " 'IPI'        = 0,  "
    cQuery1 += " 'IPI1'       = 0,  "
    cQuery1 += " 'ICMSST'     = 0,  "
    cQuery1 += " 'ICMSST1'    = 0,  "
    cQuery1 += " 'ICMS'       = 0,  "
    cQuery1 += " 'PIS'        = 0,  "
    cQuery1 += " 'COFINS'     = 0,  "
    cQuery1 += " 'DESCONTO'   = 0,  "
    cQuery1 += " 'CPV'        = 0   "
    cQuery1 += " FROM SB1010 SB1 WITH (NOLOCK)  "
    cQuery1 += " LEFT OUTER JOIN SZ1010 SZ1 WITH (NOLOCK) ON (SZ1.D_E_L_E_T_ <> '*') AND (Z1_FILIAL = SUBSTRING(B1_FILIAL,1,2)) AND (Z1_LINHA = SUBSTRING(B1_COD,4,2)) AND SZ1.D_E_L_E_T_ = '' "
    cQuery1 += " WHERE SB1.D_E_L_E_T_ =''  "
    cQuery1 += " AND SUBSTRING(B1_FILIAL,1,2) IN('01','06') "
    cQuery1 += " AND B1_GRUPO BETWEEN('PA00') AND ('PA99') "
    cQuery1 += " AND B1_MSBLQL <>'1' "
    cQuery1 += " AND SUBSTRING(B1_COD,11,2) NOT IN(CASE WHEN B1_FILIAL ='060101' THEN '38' ELSE '' END) "
    cQuery1 += " UNION ALL "
    cQuery1 += " SELECT D2_FILIAL AS 'FILIAL', "
    cQuery1 += " '01/'+SUBSTRING(D2_EMISSAO,5,2)+'/'+SUBSTRING(D2_EMISSAO,1,4) AS 'PERIODO', "
    cQuery1 += " ISNULL((CASE WHEN LEN(D2_COD) = 12 THEN SUBSTRING(D2_COD,4,2)+'-'+Z1_DESCR END),B1_TIPO) AS 'DESC_LINHA',  "
    cQuery1 += " SUBSTRING(D2_COD,1,12) AS 'PRODUTO', B1_DESC AS 'DESCRICAO', SUBSTRING(B1_COD,1,15)+' - '+ B1_DESC AS 'DESCRI«√OCOMPLETA', D2_UM AS 'UNID', D2_QUANT AS 'QTDE UNIT', "
    cQuery1 += " 'VOLUME'     = CASE WHEN D2_UM IN ('L','K','KG') OR LEN(B1_COD)<12 THEN D2_QUANT WHEN D2_SEGUM IN ('L','K','KG') THEN D2_QTSEGUM ELSE 0 END,  "
    cQuery1 += " 'FATBRUTO'   = CASE WHEN D2_TIPO <> 'I' THEN (D2_TOTAL+D2_VALIPI+D2_VALFRE+D2_DESPESA+D2_ICMSRET+D2_DESCON+D2_DESCZFR) ELSE CASE WHEN D2_TIPO ='I' AND F4_DUPLIC ='S' THEN D2_TOTAL ELSE 0 END END,  "
    cQuery1 += " 'FATBRUTO1'  = CASE WHEN D2_TIPO <> 'I' THEN (D2_TOTAL+D2_VALIPI+D2_VALFRE+D2_DESPESA+D2_ICMSRET+D2_DESCON+D2_DESCZFR) ELSE CASE WHEN D2_TIPO ='I' AND F4_DUPLIC ='S' THEN D2_TOTAL ELSE 0 END END,  "
    cQuery1 += " 'IPI'        = D2_VALIPI,  "
    cQuery1 += " 'IPI1'       = D2_VALIPI,  "
    cQuery1 += " 'ICMSST'     = D2_ICMSRET, "
    cQuery1 += " 'ICMSST1'    = D2_ICMSRET, "
    cQuery1 += " 'ICMS'       = (D2_VALICM+D2_DIFAL+D2_VFCPDIF), "
    cQuery1 += " 'PIS'        = D2_VALIMP6, "
    cQuery1 += " 'COFINS'     = D2_VALIMP5, "
    cQuery1 += " 'DESCONTO'   = (D2_DESCON+D2_DESCZFR), "
    cQuery1 += " 'CPV'        = D2_CUSTO1 "
    cQuery1 += " FROM SD2010 SD2 WITH(NOLOCK) "
    cQuery1 += " LEFT OUTER JOIN SB1010 SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = D2_FILIAL) AND (B1_COD = D2_COD)  "
    cQuery1 += " LEFT OUTER JOIN SA1010 SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '      ') AND (D2_CLIENTE = A1_COD) " 
    cQuery1 += " LEFT OUTER JOIN SF4010 SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (D2_TES = F4_CODIGO)  "
    cQuery1 += " LEFT OUTER JOIN SZ1010 SZ1 WITH (NOLOCK) ON (SZ1.D_E_L_E_T_ <> '*') AND (Z1_FILIAL = SUBSTRING(D2_FILIAL,1,2)) AND (Z1_LINHA = SUBSTRING(D2_COD,4,2)) AND SZ1.D_E_L_E_T_ ='' "
    cQuery1 += " WHERE SD2.D_E_L_E_T_='' "
    cQuery1 += " AND SUBSTRING(D2_FILIAL,1,2) IN('01','06') "
    cQuery1 += " AND D2_EMISSAO BETWEEN '"+cPerIni+"' AND '"+cPerFim+"'   "
    cQuery1 += " AND (D2_TIPO <> 'D')  "
    cQuery1 += " AND (F4_DUPLIC = 'S' OR D2_TIPO ='I' OR F4_CODIGO ='519') "
    cQuery1 += " AND (D2_CF IN('000','5101','5105','5106','5113','5118','5122','5124','5401','5403','5501','5502','5922','6101','6102','6105','6106','6107','6108','6113','6118','6122','6124','6401','6403','6501','6502','6922','7105','7106','5102','6109','6110','7101','7102') OR (D2_CF IN('5949','6949') AND D2_TES IN('519','520','540','559'))) "

    cQuery1 += " UNION ALL "
    cQuery1 += " SELECT D1_FILIAL AS FILIAL,  "
    cQuery1 += " '01/'+SUBSTRING(D1_DTDIGIT,5,2)+'/'+SUBSTRING(D1_DTDIGIT,1,4) AS 'PERIODO', "
    cQuery1 += " ISNULL((CASE WHEN LEN(D1_COD) = 12 THEN SUBSTRING(D1_COD,4,2)+'-'+Z1_DESCR END),B1_TIPO) AS 'DESC_LINHA',  "
    cQuery1 += " SUBSTRING(D1_COD,1,12) AS 'PRODUTO', B1_DESC AS 'DESCRICAO', SUBSTRING(B1_COD,1,15)+' - '+ B1_DESC AS 'DESCRI«√OCOMPLETA', D1_UM AS 'UNID', D1_QUANT AS 'QTDE UNIT', "
    cQuery1 += " 'VOLUME'     = 0, "
    cQuery1 += " 'FATBRUTO'   = (D1_TOTAL+D1_VALIPI+D1_VALFRE+D1_DESPESA+D1_ICMSRET) * -1,  "
    cQuery1 += " 'FATBRUTO1'   = 0,  "
    cQuery1 += " 'IPI'        = (D1_VALIPI *-1), "
    cQuery1 += " 'IPI1'        = 0, "
    cQuery1 += " 'ICMSST'     = CASE WHEN D1_ALIQSOL =20 THEN ((D1_ICMSRET - (D1_BRICMS * 0.02))*-1) ELSE (D1_ICMSRET*-1) END, "
    cQuery1 += " 'ICMSST1'     = 0, "
    cQuery1 += " 'ICMS'       = CASE WHEN A1_CLAS ='N' THEN (D1_VALICM*-1) ELSE ((D1_VALICM+D1_DIFAL+D1_VFCPDIF)*-1) END,  "
    cQuery1 += " 'PIS'        = (D1_VALIMP6*-1), "
    cQuery1 += " 'COFINS'     = (D1_VALIMP5*-1), "
    cQuery1 += " 'DESCONTO'   = (D1_DESCZFR*-1), "
    cQuery1 += " 'CPV'        = (D1_CUSTO*-1) "
    cQuery1 += " FROM SD1010 SD1 WITH (NOLOCK) "
    cQuery1 += " LEFT OUTER JOIN SB1010 SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = D1_FILIAL) AND (B1_COD = D1_COD) "
    cQuery1 += " LEFT OUTER JOIN SA1010 SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '      ') AND (D1_FORNECE = A1_COD)  "
    cQuery1 += " LEFT OUTER JOIN SD2010 SD2 WITH (NOLOCK) ON (SD2.D_E_L_E_T_ <> '*') AND (D1_FILIAL = D2_FILIAL) AND (D1_SERIORI = D2_SERIE) AND (D1_NFORI = D2_DOC) AND (D1_FORNECE = D2_CLIENTE) AND (D1_COD = D2_COD) "
    cQuery1 += " LEFT OUTER JOIN SF4010 SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (D1_TES = F4_CODIGO) "
    cQuery1 += " LEFT OUTER JOIN SZ1010 SZ1 WITH (NOLOCK) ON (SZ1.D_E_L_E_T_ <> '*') AND (Z1_FILIAL = SUBSTRING(D1_FILIAL,1,2)) AND (Z1_LINHA = SUBSTRING(D1_COD,4,2)) AND SZ1.D_E_L_E_T_ ='' "
    cQuery1 += " WHERE SD1.D_E_L_E_T_ =''"
    cQuery1 += " AND SUBSTRING(D1_FILIAL,1,2)IN('01','06') "
    cQuery1 += " AND D1_DTDIGIT BETWEEN '"+cPerIni+"' AND '"+cPerFim+"'   "
    cQuery1 += " AND ((F4_DUPLIC = 'S'AND D1_CF <>'000') OR (F4_CODIGO ='082' AND D1_SERIORI ='F')) "
    cQuery1 += " AND D1_CF IN('000','1201','1202','1203','1204','2201','2202','2203','2204','1410','1411','1503','1504','2410','2411','2503','2504','3201','3202') "
    cQuery1 += " ), "
    cQuery1 += " TMP1 AS (SELECT FILIAL, CONVERT(varchar(10), EOMONTH(PERIODO), 112) AS PERIODO,[DESC_LINHA], PRODUTO, DESCRICAO, "
    cQuery1 += " SUM(VOLUME) AS 'VOLUME', SUM(CPV) AS 'CPV',  "
    cQuery1 += " SUM(FATBRUTO) - SUM(IPI) - SUM(ICMSST) AS 'FATLIQVENDAS', "
    cQuery1 += " SUM(FATBRUTO1) - SUM(IPI1) - SUM(ICMSST1) AS 'FATLIQVENDAS1', "
    cQuery1 += " SUM(FATBRUTO) - (SUM(IPI) + SUM(ICMSST) + SUM(ICMS) + SUM(PIS) + SUM(COFINS) + SUM(DESCONTO)) AS 'RECEITALIQUIDA'  "
    cQuery1 += " FROM TMP "
    cQuery1 += " GROUP BY FILIAL, PERIODO, [DESC_LINHA],PRODUTO, DESCRICAO) "
    cQuery1 += " SELECT FILIAL, PERIODO, [DESC_LINHA],SUBSTRING(PRODUTO,1,12) AS PRODUTO, DESCRICAO,SUM(RECEITALIQUIDA) AS RECEITALIQ, SUM(CPV ) AS CPV, SUM(FATLIQVENDAS)  AS FATLIQVENDAS,SUM(FATLIQVENDAS1)  AS FATLIQVENDAS1,SUM(VOLUME) AS VOLUME, "
    cQuery1 += " CASE WHEN(SB1.B1_ESTOQUE)='S' THEN ROUND(SB1.B1_PRV1,2) ELSE ROUND(SB5.B5_PRV2,2) END AS PRECOTAB, CASE WHEN SB1.B1_ESTOQUE ='S' THEN 'SIM' ELSE '' END AS ESTOQUE, "
    cQuery1 += " CASE WHEN(SB1.B1_ESTOQUE)='S' THEN Z1_LUCRO ELSE Z1_LUCRO2 END AS LUCRO, "
    cQuery1 += " CASE WHEN SUBSTRING(FILIAL,1,2)='01' THEN "
    // MATRIZ
    //cQuery1 += "  ROUND((dbo.CustoPro(SB1.B1_FILIAL,SB1.B1_COD,1)/(0.98056333-((20.85+5+18+CASE WHEN(SB1.B1_ESTOQUE)='S' THEN Z1_LUCRO ELSE Z1_LUCRO2 END))/100)),2) "
    cQuery1 += " ROUND((dbo.CustoPro(SB1.B1_FILIAL,SB1.B1_COD,1)/("+BJuros+"-(("+AllTrim(str(BTributos))+"+"+AllTrim(str(nComissao))+"+"+AllTrim(str(nICMS))+"+CASE WHEN(SB1.B1_ESTOQUE)='S' THEN Z1_LUCRO ELSE Z1_LUCRO2 END))/100)),2) "
    cQuery1 += " ELSE "
    // DISSOLTEX
    //cQuery1 += " ROUND((dbo.CustoPro(SB1.B1_FILIAL,SB1.B1_COD,1)/(0.98056333-((19.05+5+18+CASE WHEN(SB1.B1_ESTOQUE)='S' THEN Z1_LUCRO ELSE Z1_LUCRO2 END))/100)),2)  "
    cQuery1 += " ROUND((dbo.CustoPro(SB1.B1_FILIAL,SB1.B1_COD,1)/("+DJuros+"-(("+AllTrim(str(DTributos))+"+"+AllTrim(str(nComissao))+"+"+AllTrim(str(nICMS))+"+CASE WHEN(SB1.B1_ESTOQUE)='S' THEN Z1_LUCRO ELSE Z1_LUCRO2 END))/100)),2) "
    cQuery1 += " END AS 'SIMULA', "
    cQuery1 += " (SELECT SUM(D2_QTSEGUM) FROM SD2010 SD2 WITH(NOLOCK) WHERE FILIAL = D2_FILIAL AND PRODUTO = D2_COD AND SD2.D_E_L_E_T_ ='' AND D2_GRUPO BETWEEN('PA00') AND ('PA99') AND (D2_ESTOQUE ='S' OR D2_XESTOQU ='S') AND D2_EMISSAO BETWEEN('"+cPerIni12+"') AND ('"+cPerFim12+"')) AS LITRAGEM, "
    cQuery1 += " dbo.CustoPro(SB1.B1_FILIAL,SB1.B1_COD,1) AS CUSTOPRO, dbo.CustoMp(SB1.B1_FILIAL,SB1.B1_COD,1) AS CUSTOMP, "
    cQuery1 += " Z99_GGFCON AS GGF, Z99_MOCONS AS MO, Z99_REQCON AS REQ, B1_CONV "
    cQuery1 += " FROM TMP1  "
    cQuery1 += " LEFT OUTER JOIN SB1010 SB1 ON B1_FILIAL = FILIAL AND B1_COD = PRODUTO AND SB1.D_E_L_E_T_ ='' "
    cQuery1 += " LEFT OUTER JOIN SB5010 SB5 ON B5_FILIAL = B1_FILIAL AND B1_COD = B5_COD AND SB5.D_E_L_E_T_ ='' "
    cQuery1 += " LEFT OUTER JOIN SZ1010 SZ1 ON Z1_FILIAL = SUBSTRING(B1_FILIAL,1,2) AND Z1_LINHA = SUBSTRING(B1_COD,4,2) AND SZ1.D_E_L_E_T_ ='' "
    cQuery1 += " LEFT OUTER JOIN Z99010 Z99 ON Z99_FILIAL = B1_FILIAL AND Z99_COD = PRODUTO AND Z99_DATA = '"+cPerFim+"' AND Z99.D_E_L_E_T_ ='' "
    cQuery1 += " WHERE "
    cQuery1 += " B1_GRUPO BETWEEN('PA00') AND ('PA99') "
    cQuery1 += " and FATLIQVENDAS <>0 "
    cQuery1 += " AND PRODUTO BETWEEN '"+mv_par07+"' AND '"+mv_par08+"'  "
    cQuery1 += " AND (SELECT SUM(D2_QTSEGUM) FROM SD2010 SD2 WITH(NOLOCK) WHERE FILIAL = D2_FILIAL AND PRODUTO = D2_COD AND SD2.D_E_L_E_T_ ='' AND D2_GRUPO BETWEEN('PA00') AND ('PA99') AND (D2_ESTOQUE ='S' OR D2_XESTOQU ='S') AND D2_EMISSAO BETWEEN('"+cPerIni12+"') AND ('"+cPerFim12+"')) >0 "
    cQuery1 += " GROUP BY FILIAL, PERIODO, [DESC_LINHA], PRODUTO, DESCRICAO,B1_FILIAL,B1_COD,B1_ESTOQUE,Z1_LUCRO, Z1_LUCRO2,B1_PRV1, B5_PRV2, Z99_GGFCON, Z99_MOCONS, Z99_REQCON, B1_CONV "
    cQuery1 += " ORDER BY FILIAL, [DESC_LINHA],B1_COD "

     /* verifica quem È o usu·rio */
    cUsuario = PswChave(RetCodUsr())
    if (cUsuario == 'neliedercorneta') 
        /* gera log do script sql */
        GravaSQL(cQuery1)
    Endif


     /* verifica se arquivo est· aberto e finaliza */
    IF Select("QCON") <> 0
        DbSelectArea("QCON")
        DbCloseArea()
    ENDIF
    
    TCQUERY cQuery1 NEW ALIAS "QCON"  
    Count To nTotal 
    //oReport:SetMsgPrint("Registros encontrados "+cValToChar(nTotal)) 
    
    dbSelectArea("QCON")
    QCON->(dbGoTop())

    //Criando o objeto que ir· gerar o conte˙do do Excel
    oFWMsExcel := FWMsExcelEx():New()
     
    TabEvi  := "Evidencias"
    TitTab1 := "Evidencias"
    oFWMsExcel:AddworkSheet(TabEvi) 
    //Criando a Tabela
    oFWMsExcel:AddTable(TabEvi,TitTab1)
    //Criando Colunas
    oFWMsExcel:AddColumn(TabEvi,TitTab1,"Empresa  ",1) //1 = Modo Texto
    oFWMsExcel:AddColumn(TabEvi,TitTab1,"PIS (%)",1) //1 = Modo Texto
    oFWMsExcel:AddColumn(TabEvi,TitTab1,"Cofins (%)",1) //2 = Valor sem R$
    oFWMsExcel:AddColumn(TabEvi,TitTab1,"Contr.Social (%)",1) //3 = Valor com R$
    oFWMsExcel:AddColumn(TabEvi,TitTab1,"IR Sobre Lucro (%)",1)
    oFWMsExcel:AddColumn(TabEvi,TitTab1,"Desp. Administrativas (%)",1)
    oFWMsExcel:AddColumn(TabEvi,TitTab1,"Gastos Gerais (%)",1)
    oFWMsExcel:AddColumn(TabEvi,TitTab1,"Desp.Comerciais (%)",1)
    oFWMsExcel:AddColumn(TabEvi,TitTab1,"ICMS (%)",1)
    oFWMsExcel:AddColumn(TabEvi,TitTab1,"Comiss„o (%)",1)

    /*
    [1] PIS              aPlBrasi[1][2]    
    [2] COFINS           aPlBrasi[2][2]
    [3] CONTR.SOCIAL     aPlBrasi[3][2]
    [4] IR SOB LUCRO     aPlBrasi[4][2]
    [5] CPMF             aPlBrasi[5][2]
    [6] DESP ADMI        aPlBrasi[6][2]
    [7] GASTOS GERAIS    aPlBrasi[7][2]
    [8] DESP COMERCI     aPlBrasi[8][2]
    */


    //Linhas Brasilux
    oFWMsExcel:AddRow(TabEvi,TitTab1,{;
                                    "Brasilux",;
                                    aPlBrasi[1][2],;
                                    aPlBrasi[2][2],;
                                    aPlBrasi[3][2],;
                                    aPlBrasi[4][2],;
                                    aPlBrasi[6][2],;
                                    aPlBrasi[7][2],;
                                    aPlBrasi[8][2],;
                                    nICMS,;
                                    nComissao;
                                    })


    //Dissoltec
    oFWMsExcel:AddRow(TabEvi,TitTab1,{;
                                    "Dissoltec",;
                                    aPlDissol[1][2],;
                                    aPlDissol[2][2],;
                                    aPlDissol[3][2],;
                                    aPlDissol[4][2],;
                                    aPlDissol[6][2],;
                                    aPlDissol[7][2],;
                                    aPlDissol[8][2],;
                                    nICMS,;
                                    nComissao;
                                    })                                
    
    
    
    
     //Aba 02 - Pedidos Coca
    oFWMsExcel:AddworkSheet("Simulado")
    ccabecalho := "Simulado Form PreÁo Vlr Dolar..:"+ Alltrim(Str(vDolar))      
    oFWMsExcel:AddTable("Simulado",ccabecalho)
    oFWMsExcel:AddColumn("Simulado",ccabecalho,"Chave",1)
    oFWMsExcel:AddColumn("Simulado",ccabecalho,"Filial  ",1)
    oFWMsExcel:AddColumn("Simulado",ccabecalho,"DESCRI«√O LINHA",1)
    oFWMsExcel:AddColumn("Simulado",ccabecalho,"PRODUTO",1)
    oFWMsExcel:AddColumn("Simulado",ccabecalho,"DESCRI«√O DO PRODUTO",1)
    oFWMsExcel:AddColumn("Simulado",ccabecalho,"ESTOQUE",1)
    oFWMsExcel:AddColumn("Simulado",ccabecalho,"LUCRO",1)
    oFWMsExcel:AddColumn("Simulado",ccabecalho,"RECEITA LIQ",3,3)
    oFWMsExcel:AddColumn("Simulado",ccabecalho,"CPV",3,3)
    oFWMsExcel:AddColumn("Simulado",ccabecalho,"MARGEM %",1)
    oFWMsExcel:AddColumn("Simulado",ccabecalho,"MARG. VALOR",3,3)
    oFWMsExcel:AddColumn("Simulado",ccabecalho,"VOLUME M S",1)
    oFWMsExcel:AddColumn("Simulado",ccabecalho,"VOL. ULT. 12 MESES",1)
    oFWMsExcel:AddColumn("Simulado",ccabecalho,"REC. COMERC",3,3)
    oFWMsExcel:AddColumn("Simulado",ccabecalho,"TAB VIGENTE",3,3)
    oFWMsExcel:AddColumn("Simulado",ccabecalho,"1∫ SIMULA«√O "+Alltrim(Str(vDolar)) ,3,3)
    oFWMsExcel:AddColumn("Simulado",ccabecalho,"% TABELA  ATUAL X SIMUL",1)
    oFWMsExcel:AddColumn("Simulado",ccabecalho,"CUSTO REPOSI«√O",3,3)
    oFWMsExcel:AddColumn("Simulado",ccabecalho,"GGF",3,3)
    oFWMsExcel:AddColumn("Simulado",ccabecalho,"MO",3,3)
    oFWMsExcel:AddColumn("Simulado",ccabecalho,"REQ",3,3)
    oFWMsExcel:AddColumn("Simulado",ccabecalho,"CONV.",1)
    
        
    conta := 0
    porc  := 0
    While !QCON->(eof())

        conta++
        porc = (conta/nTotal)*100
        porc = round(porc,2) 

        If QCON->RECEITALIQ == 0
            pMarge := 0
        else
            pMarge := 1 - (QCON->CPV/QCON->RECEITALIQ)
            pMarge := pMarge * 100
            pMarge := ROUND(pMarge,0)
        EndIf    

        MargLiq := QCON->RECEITALIQ - QCON->CPV

        PSimula := (QCON->SIMULA/QCON->PRECOTAB)-1;

        Chave := Alltrim(QCON->DESC_LINHA)+Alltrim(QCON->FILIAL)+Alltrim(QCON->ESTOQUE)
        oFWMsExcel:AddRow("Simulado",ccabecalho,{;
                                    Chave,;
                                    QCON->FILIAL,;
                                    QCON->DESC_LINHA,;
                                    QCON->PRODUTO,;
                                    QCON->DESCRICAO,;
                                    QCON->ESTOQUE,;
                                    QCON->LUCRO,;
                                    QCON->RECEITALIQ,;
                                    QCON->CPV,;
                                    pMarge,;                                    
                                    MargLiq,;
                                    QCON->VOLUME,;
                                    QCON->LITRAGEM,;
                                    QCON->FATLIQVENDAS,;
                                    QCON->PRECOTAB,;
                                    QCON->SIMULA,;
                                    PSimula,;
                                    QCON->CUSTOMP,;
                                    QCON->GGF,;
                                    QCON->MO,;
                                    QCON->REQ,;
                                    QCON->B1_CONV;
                                    }) 
        QCON->(dbSkip())
   
    Enddo
    

    //Ativando o arquivo e gerando o xml
    oFWMsExcel:Activate()
    MsgRun("Processando...","Aguarde...",{|| oFWMsExcel:GetXMLFile(cArquivo) } )
    
         
    //Abrindo o excel e abrindo o arquivo xml
    oExcel := MsExcel():New()             //Abre uma nova conex„o com Excel
    oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
    oExcel:SetVisible(.T.)                 //Visualiza a planilha
    oExcel:Destroy()   


Return()


Static Function LePDV()
Local  nArq, cPlanilha, nLidos, cLinha, lOk, cVar
Local nUsado   := 0
Local aHeader  := {}


    //cPlanilha = Alltrim(mv_par05)+".pdv"
    /* Processa Planilha Brasilux */

    cPlanilha = "BRASILUX.pdv"
    nArq      = fOpen(cPlanilha)
    nLidos    = 0
    If nArq > 0 
       fSeek(nArq, 0, 0)
       nTamArq := fSeek(nArq, 0, 2)
       fSeek(nArq, 0, 0)
       lOk  := .f.
       aPlBrasi := {}
       While nLidos < nTamArq
            cLinha = U_fGets(nArq, nTamArq)
            If (SubStr(cLinha, 6, 3) $ "PIS_IVA_COF") 
                 lOk := .t.
            Endif
            If lOk
                nUsado := nUsado+1
                cVar   := "V"+Alltrim(Str(nUsado))
                aAdd(aHeader, {Trim(SubStr(cLinha, 6, 30)), cVar, "@E 999.99", 6, 2, 'ExecBlock("BRES03", .F., .F., "'+cVar+'")', "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ†", "N", "", " " } )
                aAdd(aPlBrasi, {cVar, U_cTon(Alltrim(SubStr(cLinha, 36, 10)))})
            Endif
            If (SubStr(cLinha, 6, 16) == "DESP. COMERCIAIS")
                lOk := .f.
            Endif
            nLidos += Len(cLinha)+2
        EndDo
        fClose(nArq)
    Else
        MsgBox("ImpossÌvel abrir planilha: "+cPlanilha, "AtenÁ„o...", "STOP")
        Return
    Endif

    /* Dissoltex */
    cPlanilha = "DISSOLTE.pdv"
    nArq      = fOpen(cPlanilha)
    nLidos    = 0
    If nArq > 0 
       fSeek(nArq, 0, 0)
       nTamArq := fSeek(nArq, 0, 2)
       fSeek(nArq, 0, 0)
       lOk  := .f.
       aPlDissol := {}
       While nLidos < nTamArq
            cLinha = U_fGets(nArq, nTamArq)
            If (SubStr(cLinha, 6, 3) $ "PIS_IVA_COF") 
                 lOk := .t.
            Endif
            If lOk
                nUsado := nUsado+1
                cVar   := "V"+Alltrim(Str(nUsado))
                aAdd(aHeader, {Trim(SubStr(cLinha, 6, 30)), cVar, "@E 999.99", 6, 2, 'ExecBlock("BRES03", .F., .F., "'+cVar+'")', "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ†", "N", "", " " } )
                aAdd(aPlDissol, {cVar, U_cTon(Alltrim(SubStr(cLinha, 36, 10)))})
            Endif
            If (SubStr(cLinha, 6, 16) == "DESP. COMERCIAIS")
                lOk := .f.
            Endif
            nLidos += Len(cLinha)+2
        EndDo
        fClose(nArq)
    Else
        MsgBox("ImpossÌvel abrir planilha: "+cPlanilha, "AtenÁ„o...", "STOP")
        Return
    Endif

return

Static Function GravaSQL(script)

Local cArq := ""


cArq := "C:\Temp\sql.txt" //a pasta deve ser v·lida.


MemoWrite ( cArq , script )


Return

