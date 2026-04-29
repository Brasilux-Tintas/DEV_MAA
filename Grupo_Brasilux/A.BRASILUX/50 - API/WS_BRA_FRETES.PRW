#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"                   
#Include "TopConn.Ch"
#Include "TbiConn.Ch"      

#DEFINE  CrLf  chr(13)+chr(10)

//=====================================================================================================
#DEFINE cStrSyntax "/api/iventmobile/v1/"
//=====================================================================================================

WSRESTFUL BRA_FRETE  DESCRIPTION "Retorna Pedidos de Venda" FORMAT APPLICATION_JSON
   WSMETHOD POST DESCRIPTION "Retorna Pedidos de Venda" WSSYNTAX "BRA_FRETE"   
END WSRESTFUL

//------------------------------------------//
//------------- METODO ---------------------//                                              
//------------------------------------------//    
WSMETHOD POST WSSERVICE BRA_FRETE

Local cBody     := ::GetContent()
Local nX        := 0   
Local lRet      := .f.
Local cResponse := ""	
Local oJson     := JsonObject():New()  
Local cJsonTmp  := ""
Local cQry      := ""
Local aJson     := {}
Local aDados    := {}
//Local cPorc     

//-----------------------
Private lMsErroAuto := .F.   
Private cAutoErro   := ""

//---------------------------------------------------------------------------------------
::SetContentType("application/json")
//---------------------------------------------------------------------------------------- 

    MemoWrite("\ws_logs\frete\INICIO.txt",'INICIO')
    oJson:fromJson( cBody )
 
    cQry   := "  SELECT  ZA9_DOC CTE,ZA9_SERIE SERIE,ZA9_VALMER,C5_REDESP,A4_NOME,C5_XVLRFRE,C5_TPFRETE, " + CrLf
    cQry   += " F2_DOC,F2_SERIE,F2_VALBRUT,C5_NUM,F2_EST,SUM(D2_PESO)PESO,F2_FILIAL,F2_VEND1,A3_NOME, " + CrLf
    cQry   += " CONVERT(VARCHAR(10), CAST(F2_EMISSAO AS DATETIME), 103) AS F2_EMISSAO " + CrLf
    cQry   += " ,(SELECT SUM(C6_VOLITEM) FROM SC6010 SC6 WHERE C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND SC6.D_E_L_E_T_ = '')  Volume  " + CrLf


    cQry   += " FROM SC5010 SC5    " + CrLf
    cQry   += " INNER JOIN SA1010 SA1 ON A1_COD = C5_CLIENTE AND SA1.D_E_L_E_T_ = ''      " + CrLf
    cQry   += " INNER JOIN SF2010 SF2 ON F2_DOC = C5_NOTA AND F2_SERIE = C5_SERIE  AND SF2.D_E_L_E_T_ = '' AND F2_FILIAL = C5_FILIAL   " + CrLf
    cQry   += " INNER JOIN SD2010 SD2 ON F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE  AND SD2.D_E_L_E_T_ = '' AND F2_FILIAL = D2_FILIAL " + CrLf
    cQry   += " LEFT JOIN SA4010 SA4 ON A4_COD = C5_REDESP AND SA4.D_E_L_E_T_ = '' " + CrLf
    cQry   += " INNER JOIN SA3010 SA3 ON SA3.D_E_L_E_T_ = '' AND A3_COD = F2_VEND1 " + CrLf
    cQry   += " INNER JOIN ZA9010 ZA9 ON ZA9.D_E_L_E_T_ = '' AND  ZA9_CHVSF2 = F2_CHVNFE    " + CrLf
    cQry   += " WHERE C5_FILIAL = '010101' AND SC5.D_E_L_E_T_ = ''  AND F2_EMISSAO >= '20230101'   " + CrLf 
    cQry   += " GROUP BY  ZA9_DOC,ZA9_SERIE,ZA9_VALMER,C5_REDESP,A4_NOME,F2_DOC,F2_SERIE,F2_VALBRUT,C5_NUM,F2_EST,F2_FILIAL,F2_VEND1,A3_NOME,C5_XVLRFRE,C5_TPFRETE,F2_EMISSAO,C5_FILIAL " + CrLf 
    cQry   += " ORDER BY ZA9_DOC,ZA9_SERIE,ZA9_VALMER,C5_REDESP,A4_NOME   " + CrLf

      //==============================================================================================================
    MemoWrite("\ws_logs\frete\QUERY.txt",cQry)  
    IIF( Select("QRY")>0 , QRY->(DbCloseArea()),.t.)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QRY")
    QRY->( DbGotop() )
    While QRY->(!Eof()) 

        aadd(aDados,{;
          AllTrim(QRY->CTE        ),;
          AllTrim(QRY->SERIE      ),;
          QRY->ZA9_VALMER          ,; 
          AllTrim(QRY->C5_REDESP  ),;
          AllTrim(QRY->A4_NOME    ),;
          AllTrim(QRY->F2_DOC     ),;
          AllTrim(QRY->F2_SERIE   ),;
          QRY->F2_VALBRUT          ,;
          AllTrim(QRY->C5_NUM     ),;
          AllTrim(QRY->F2_VEND1   ),;
          QRY->Volume              ,;
          QRY->PESO                ,;
          0                        ,;
          AllTrim(QRY->A3_NOME    ),;
          QRY->C5_XVLRFRE          ,;
          AllTrim(QRY->C5_TPFRETE) ,;
          AllTrim(QRY->F2_EST    ) ,;
          AllTrim(QRY->F2_EMISSAO)  ;
                  })
      aadd(aJson, aDados)
      aDados := {}
      QRY->(DbSkip()) 

        // QRY->Volume             ,;
        //  QRY->cPorc              ,;
    End

    QRY->(dbCloseArea())

    MemoWrite("\ws_logs\frete\passouQuery.txt",'Query')  
    cJsonTmp := '['
    For nX := 1 to len(aJson)
        MemoWrite("\ws_logs\frete\Nx.txt",AllTrim(Str(Nx))) 
        IF nX>1
          cJsonTmp +=','
        ENDIf
     
        cJsonTmp += '{' + CrLf
        cJsonTmp += '"CTE":"'             + AllTrim(aJson[nX][1][1]+'-'+aJson[nX][1][2])      + '",' + CrLf
        cJsonTmp += '"VlrCte":'           + AllTrim(Str(aJson[nX][1][3])) + ','  + CrLf
        cJsonTmp += '"CodigoTransp":"'    + AllTrim(aJson[nX][1][4])      + '",' + CrLf
        cJsonTmp += '"DescriTransp":"'    + AllTrim(aJson[nX][1][5])      + '",' + CrLf

         // n := 1
          cTE := AllTrim(aJson[nX][1][1])+AllTrim(aJson[nX][1][2])+AllTrim(aJson[nX][1][4])
          cJsonTmp += ' "Notas": [' + CrLf
          //While PRY->(!Eof()) 
           
            
           
              While ( AllTrim(aJson[nX][1][1])+AllTrim(aJson[nX][1][2])+AllTrim(aJson[nX][1][4]) ) == ( cTE )

                  //cPorc :=  ROUND ( (((aJson[nX][1][3])/PRY->F2_VALBRUT) * 100) , 2)
                  cPorc :=  ROUND ( (((aJson[nX][1][3])/aJson[nX][1][8] ) * 100) , 2)
                  cNota := AllTrim(aJson[nX][1][6])+AllTrim(aJson[nX][1][7])
                  cJsonTmp += '{'  + CrLf
                  cJsonTmp += '"Nota":"'          + AllTrim(aJson[nX][1][6])+'-'+AllTrim(aJson[nX][1][7])    + '",' + CrLf
                  cJsonTmp += '"VlrNF":'          + AllTrim(Str(aJson[nX][1][8] ))                           + ','  + CrLf
                  cJsonTmp += '"Pedido":"'        + AllTrim(aJson[nX][1][9])                                 + '",'  + CrLf
                  cJsonTmp += '"Vendedor":"'      + AllTrim(aJson[nX][1][10]) +'-'+ AllTrim(aJson[nX][1][14])+ '",'  + CrLf
                  cJsonTmp += '"Peso":'           + AllTrim(Str(aJson[nX][1][12]))                           + ','  + CrLf
                  cJsonTmp += '"Volume":'         + AllTrim(Str(aJson[nX][1][11]))                           + ','  + CrLf
                  cJsonTmp += '"Porcentagem":'    + AllTrim(Str(cPorc))                                      + ','  + CrLf
                  cJsonTmp += '"FreteInformado":' + AllTrim(Str(aJson[nX][1][15]))                           + ','  + CrLf
                  cJsonTmp += '"TipoFrete":"'     + AllTrim(aJson[nX][1][16])                                + '",' + CrLf
                  cJsonTmp += '"Estado":"'        + AllTrim(aJson[nX][1][17])                                + '",' + CrLf
                  cJsonTmp += '"Emissao":"'       + AllTrim(aJson[nX][1][18])                                + '",' + CrLf
                  cJsonTmp += '},' + CrLf    
                  nX++
                 
                  If nX >= len(aJson)
                    Exit
                  EndIf
                  
              End

            //n++
            //PRY->(DbSkip()) 
          //End
          //PRY->(dbCloseArea())

          cJsonTmp     += ']' + CrLf
          cJsonTmp += '}' + CrLf
              
    Next
    cJsonTmp  += ']' + CrLf    
    cResponse := cJsonTmp

    ::SetResponse(cResponse)
Return(lRet)
