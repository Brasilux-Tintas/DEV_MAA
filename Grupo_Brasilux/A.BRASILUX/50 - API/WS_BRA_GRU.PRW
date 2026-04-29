#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"                   
#Include "TopConn.Ch"
#Include "TbiConn.Ch"      

#DEFINE  CrLf  chr(13)+chr(10)

//=====================================================================================================
#DEFINE cStrSyntax "/api/iventmobile/v1/"
//=====================================================================================================

WSRESTFUL API_PEDIDOSGRU  DESCRIPTION "Retorna Pedidos de Venda Guarulhos D2" FORMAT APPLICATION_JSON
   WSMETHOD POST DESCRIPTION "Retorna Pedidos de Venda Guarulhos D2" WSSYNTAX "API_PEDIDOSGRU"   
END WSRESTFUL

//------------------------------------------//
//------------- METODO ---------------------//                                              
//------------------------------------------//    
WSMETHOD POST WSSERVICE API_PEDIDOSGRU

Local cBody     := ::GetContent()
Local nX        := 0   
Local lRet      := .f.
Local cResponse := ""	
Local oJson     := JsonObject():New()  
Local cJsonTmp  := ""
Local cQry      := ""
Local aJson     := {}
Local aDados    := {}
local bError    := ErrorBlock({|oError| cError := oError:Description})
local cError   as char
Local Corte     := ""

//-----------------------
Private lMsErroAuto := .F.   
Private cAutoErro   := ""

//---------------------------------------------------------------------------------------
::SetContentType("application/json")
//---------------------------------------------------------------------------------------- 

    MemoWrite("\ws_logs\frete\INICIO.txt",'INICIO')
    oJson:fromJson( cBody )
 
    cQry   := " SELECT  " + CrLf
	  cQry   += " C5_NUM,	A1_COD,	A1_NOME, A1_TIPO, A1_MUN, " + CrLf
	  cQry   += " A1_EST, CC2_LATITU,	CC2_LONGIT,	C6_ITEM, " + CrLf
    cQry   += " C6_PRODUTO,	C6_DESCRI,	C6_QTDVEN ,	C6_UM," + CrLf
    cQry   += " CONVERT(VARCHAR(10), CAST(C5_EMISSAO AS DATETIME), 103) AS C5_EMISSAO, " + CrLf
    cQry   += " CONVERT(VARCHAR(10), CAST(F2_EMISSAO AS DATETIME), 103) AS F2_EMISSAO, " + CrLf
    cQry   += " C5_FLAG,C5_APROVA,C5_PEDDIV, " + CrLf
    //cQry   += " CAST(ISNULL((SELECT MIN(ZZB_DATLOG) FROM ZZB010 ZZB WHERE ZZB_IDLOG = 'APR' AND ZZB_PEDIDO = SC5.C5_NUM AND ZZB.D_E_L_E_T_ <> '*'), SC5.C5_EMISSAO) as date) as 'Aprovacao' FROM SC5010 SC5  " + CrLf
    cQry   += "   (SELECT COUNT(*) FROM SC5010 C5 WHERE C5.C5_NUM = SC5.C5_EMISSAO OR C5.C5_PEDDIV = SC5.C5_EMISSAO AND D_E_L_E_T_ = '') CORTE," + CrLf
    cQry   += " (ISNULL((SELECT MIN(CONVERT(VARCHAR(10), CAST(ZZB_DATLOG AS DATETIME), 103)) FROM ZZB010 ZZB WHERE ZZB_IDLOG = 'APR' AND ZZB_PEDIDO = SC5.C5_NUM AND ZZB.D_E_L_E_T_ <> '*'), CONVERT(VARCHAR(10), CAST(SC5.C5_EMISSAO AS DATETIME), 103)) ) as 'APROVA'  " + CrLf
    cQry   += " FROM SC5010 SC5  " + CrLf
    cQry   += " INNER JOIN SC6010 SC6 ON SC6.C6_NUM = SC5.C5_NUM AND SC6.C6_FILIAL = SC5.C5_FILIAL AND SC5.C5_TABELA = 'GRU' AND SC5.D_E_L_E_T_ <> '*'  " + CrLf
    cQry   += " INNER JOIN SA1010 SA1 ON SA1.A1_COD = SC5.C5_CLIENTE and SA1.D_E_L_E_T_ <> '*' " + CrLf
    cQry   += " LEFT JOIN  CC2010 CC2 ON CC2_EST+CC2_CODMUN = SA1.A1_EST+SA1.A1_COD_MUN AND CC2.D_E_L_E_T_ <> '*' " + CrLf
    cQry   += " LEFT JOIN SF2010  SF2 ON SF2.D_E_L_E_T_ <> '*' AND SF2.F2_DOC = C5_NOTA AND SF2.F2_SERIE = C5_SERIE AND F2_FILIAL = C5_FILIAL  " + CrLf 
    cQry   += " WHERE C5_APROVA ='1' AND C5_TIPO ='N' AND C5_LIBPED ='T' " + CrLf 
    cQry   += " ORDER BY C5_NUM,C6_ITEM " + CrLf 
    

    MemoWrite("\ws_logs\frete\QUERY.txt",cQry)  
    IIF( Select("QRY")>0 , QRY->(DbCloseArea()),.t.)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QRY")
    QRY->( DbGotop() )
    
    While QRY->(!Eof()) 
      begin sequence

          if QRY->CORTE > 0
            Corte := "Com corte"
          else
            Corte := "Sem corte"
          Endif
          
          aadd(aDados,{;
                    AllTrim(QRY->C5_NUM          ),;
                    AllTrim(QRY->A1_COD          ),;
                    AllTrim(QRY->A1_NOME         ),;
                    AllTrim(QRY->A1_TIPO         ),;
                    AllTrim(QRY->A1_MUN          ),;
                    AllTrim(QRY->A1_EST          ),;
                    AllTrim(Str(QRY->CC2_LATITU) ),;
                    AllTrim(Str(QRY->CC2_LONGIT) ),;
                    AllTrim(QRY->C6_ITEM         ),;
                    AllTrim(QRY->C6_PRODUTO      ),;
                    AllTrim(QRY->C6_DESCRI       ),;
                    AllTrim(Str(QRY->C6_QTDVEN)  ),;
                    AllTrim(QRY->C6_UM           ),;
                    AllTrim(QRY->C5_EMISSAO      ),;
                    AllTrim(QRY->APROVA          ),;
                    AllTrim(QRY->F2_EMISSAO      ),;
                    AllTrim(Corte                ) ;
                                    })
          aadd(aJson, aDados)

         End Sequence

      ErrorBlock(bError)

      if !Empty(cError)
          cResponse := '{"erro":"Sem dados","msg":"Sem Resultado"}'   
          lRet      := .f.
          Return(lRet)
      EndIF

      aDados := {}
      QRY->(DbSkip()) 

    End

    QRY->(dbCloseArea())

    MemoWrite("\ws_logs\frete\passouQuery.txt",'Query')  
    cJsonTmp := '['
    For nX := 1 to len(aJson)
        //MemoWrite("\ws_logs\frete\Nx.txt",AllTrim(Str(Nx))) 
        IF nX>1
          cJsonTmp +=','
        ENDIf
     
        cJsonTmp += '{' + CrLf
          cJsonTmp += '"Num.Pedido":"'              + aJson[nX][1][1]  + '",'  + CrLf
          cJsonTmp += '"Intercompany":"'            + 'Sem Intercompany'  + '",'  + CrLf
          cJsonTmp += '"Num. Cliente":"'            + aJson[nX][1][2]  + '",'  + CrLf
          cJsonTmp += '"Nome Cliente":"'            + aJson[nX][1][3]  + '",'  + CrLf
          cJsonTmp += '"Tipo Cliente":"'            + aJson[nX][1][4]  + '",'  + CrLf
          cJsonTmp += '"Municipio":"'               + aJson[nX][1][5]  + '",'  + CrLf
          cJsonTmp += '"UF":"'                      + aJson[nX][1][6]  + '",'  + CrLf
          cJsonTmp += '"Latitude":"'                + aJson[nX][1][7]  + '",'  + CrLf
          cJsonTmp += '"Longitude":"'               + aJson[nX][1][8]  + '",'  + CrLf
          cJsonTmp += '"Item":"'                    + aJson[nX][1][9]  + '",'  + CrLf
          cJsonTmp += '"Cod. Produto":"'            + aJson[nX][1][10] + '",'  + CrLf
          cJsonTmp += '"Desc. Produto":"'           + aJson[nX][1][11] + '",'  + CrLf
          cJsonTmp += '"Qtd":"'                     + aJson[nX][1][12] + '",'  + CrLf
          cJsonTmp += '"U.M.":"'                    + aJson[nX][1][13] + '",'  + CrLf
          cJsonTmp += '"Data Emissao":"'            + aJson[nX][1][14] + '",'  + CrLf
          cJsonTmp += '"Data Aprovacao":"'          + aJson[nX][1][15] + '",'  + CrLf
          cJsonTmp += '"Data NT Saida":"'           + aJson[nX][1][16] + '",'  + CrLf
          cJsonTmp += '"Status Corte":"'            + aJson[nX][1][17] + '",'  + CrLf



        cJsonTmp += '}' + CrLf
              
    Next
    cJsonTmp  += ']' + CrLf    
    cResponse := cJsonTmp

    ::SetResponse(cResponse)
Return(lRet)
