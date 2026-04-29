#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"                   
#Include "TopConn.Ch"
#Include "TbiConn.Ch"      

#DEFINE  CrLf  chr(13)+chr(10)

//=====================================================================================================
#DEFINE cStrSyntax "/api/iventmobile/v1/"
//=====================================================================================================

WSRESTFUL BRA_NOVOS_CLIENTES  DESCRIPTION "Retorna Pedidos de Venda" FORMAT APPLICATION_JSON
   WSMETHOD POST DESCRIPTION "Retorna Pedidos de Venda" WSSYNTAX "BRA_NOVOS_CLIENTES"   
END WSRESTFUL

//------------------------------------------//
//------------- METODO ---------------------//                                              
//------------------------------------------//    
WSMETHOD POST WSSERVICE BRA_NOVOS_CLIENTES

Local cBody     := ::GetContent()
Local nX        := 0   
Local lRet      := .f.
Local cResponse := ""	
Local oJson     := JsonObject():New()  
Local cJsonTmp  := ""
Local cQry      := ""
Local nAtual    := 1
Local aJson     := {}
Local aDados    := {}


//-----------------------
Private lMsErroAuto := .F.   
Private cAutoErro   := ""

//---------------------------------------------------------------------------------------
::SetContentType("application/json")
//---------------------------------------------------------------------------------------- 

    MemoWrite("\ws_logs\novos_clientes\WS_BRA_NOVOSCLIENTE_INICIO.txt",'INICIO')
    oJson:fromJson( cBody )


    For nAtual := 1 To 6
    MemoWrite("\ws_logs\novos_clientes\WS_BRA_NOVOS_CLIENTES_FOR_"+AllTrim(Str(nAtual))+".txt",AllTrim(Str(nAtual)))
    do case 
        case nAtual == 1
            cPeriodo := "Janeiro"
            cData    := "20231231"

        case nAtual == 2
            cPeriodo := "Fevereiro"
                cData    := "20240131"

        case nAtual ==  3
            cPeriodo := "Marco"
                cData    := "20240229"

        case nAtual == 4
            cPeriodo := "Abril"
                cData    := "20240331"

        case nAtual == 5
            cPeriodo := "Maio"
                cData    := "20240430"

        case nAtual == 6
            cPeriodo := "Junho"  
                cData    := "20240531"  

        case nAtual == 7
            cPeriodo := "Julho"  
                cData    := "20240630"    

    endcase 
       

    // senha 31qR3Of3iCvH  
    cQry   := "SELECT F2_FILIAL,A1_COD+'-'+TRIM(A1_NOME)A1_NOME,TRIM(A1_MUN)A1_MUN,A1_EST,A1_VEND,A3_NOME,A3_COD, " + CrLf
    cQry   += " (SELECT TOP 1 SUBSTRING(F2_EMISSAO,7,2)+'/'+SUBSTRING(F2_EMISSAO,5,2)+'/'+SUBSTRING(F2_EMISSAO,3,2) FROM SF2010 T2 " + CrLf
    cQry   += " WHERE T2.D_E_L_E_T_ = '' AND T2.F2_CLIENTE = A1_COD AND T2.F2_FILIAL = SF2.F2_FILIAL AND F2_TIPO = 'N' ORDER BY F2_EMISSAO) F2_EMISSAO " + CrLf
    cQry   += " , '"+cPeriodo+"' as Periodo " + CrLf
    cQry   += " FROM SA1010 SA1 "  + CrLf
    cQry   += " INNER JOIN SF2010 SF2 ON SF2.D_E_L_E_T_ = '' AND F2_EMISSAO LIKE '20240"+AllTrim(Str(nAtual))+"%' " + CrLf
    cQry   += " INNER JOIN SA3010 SA3 ON SA3.D_E_L_E_T_ = '' AND A3_COD = A1_VEND " + CrLf
    cQry   += " AND F2_CLIENTE = A1_COD " + CrLf
    cQry   += " WHERE SA1.D_E_L_E_T_ = '' " + CrLf
    cQry   += " AND F2_TIPO = 'N' " + CrLf
    cQry   += " AND (SELECT COUNT(F2_DOC) FROM SF2010 F2 WHERE F2.F2_CLIENTE = A1_COD AND F2.D_E_L_E_T_ = '' "  + CrLf
    cQry   += "  AND F2.F2_EMISSAO <= '"+cData+"' AND F2.F2_FILIAL = SF2.F2_FILIAL AND F2_TIPO = 'N'  ) = 0 "  + CrLf
    cQry   += " GROUP BY F2_FILIAL,A1_COD,A1_NOME,A1_MUN,A1_EST,A1_VEND,A3_COD,A3_NOME "  + CrLf
    cQry   += " ORDER BY A1_VEND,A3_COD,A3_NOME,A1_COD,F2_EMISSAO "  + CrLf

      //==============================================================================================================
    MemoWrite("\ws_logs\novos_clientes\WS_BRA_NOVOSCLIENTES_QUERY.txt",cQry)  
    IIF( Select("QRY")>0 , QRY->(DbCloseArea()),.t.)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QRY")
    QRY->( DbGotop() )
    While QRY->(!Eof()) 
        aadd(aDados,{;
            alltrim(AllTrim(QRY->F2_FILIAL )),;
            alltrim(AllTrim(QRY->A1_NOME )),;
            alltrim(AllTrim(QRY->A1_MUN )),;
            alltrim(AllTrim(QRY->A1_EST )),;
            alltrim(AllTrim(QRY->A3_COD)),;
            alltrim(AllTrim(QRY->A3_NOME )),;
            alltrim(AllTrim(QRY->F2_EMISSAO )),;
            alltrim(AllTrim(QRY->Periodo ));
        })
        aadd(aJson, aDados)
        aDados := {}

        QRY->(DbSkip()) 
    End
    QRY->(dbCloseArea())

    MemoWrite("\ws_logs\novos_clientes\WS_BRA_NOVOSCLIENTES_JSON1.txt",'aJson') 

    Next 

      cJsonTmp := '['
      For nX := 1 to len(aJson)
      
         IF nX>1
            cJsonTmp +=','
         ENDIf
         cJsonTmp += '{' 
         cJsonTmp += '"Filial":"'           + AllTrim(aJson[nX][1][1]) + '",'
         cJsonTmp += '"Cliente":"'          + AllTrim(aJson[nX][1][2]) + '",'
         cJsonTmp += '"Cidade":"'           + AllTrim(aJson[nX][1][3]) + '",'
         cJsonTmp += '"UF":"'               + AllTrim(aJson[nX][1][4]) + '",'
         cJsonTmp += '"Vendedor":"'         + AllTrim(aJson[nX][1][5]) + '",'
         cJsonTmp += '"Nome Vendedor":"'    + AllTrim(aJson[nX][1][6]) + '",'
         cJsonTmp += '"1_Compra":"'         + AllTrim(aJson[nX][1][7]) + '",'
         cJsonTmp += '"Periodo":"'          + AllTrim(aJson[nX][1][8]) + '"'
         cJsonTmp += '}'

       Next
	   cJsonTmp  += ']'    
	   cResponse := cJsonTmp

::SetResponse(cResponse)
Return(lRet)


