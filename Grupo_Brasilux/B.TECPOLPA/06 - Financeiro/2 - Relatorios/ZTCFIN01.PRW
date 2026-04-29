//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "Avprint.ch"
#include 'font.ch'
#include 'totvs.ch'

//Constantes
#Define STR_PULA    Chr(13)+Chr(10)

/*/
{Protheus.doc} ZTCFIN01
//CALCULA COMISSÃO VENCDEDDORES TECPOLPA
@type function
@version  v.2022.10.20.001 
@author joseuliana
@since 20/10/2022
@return variant, return 
/*/

User Function ZTCFIN01()
     Local   _cPerg   := "ZTCFIN01   "  
     Private MV_PAR01
     Private MV_PAR02
     Private MV_PAR03
     Private aMatDad  := {}

   if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  	endif 

  If !Pergunte( _cPerg ) 
     Return() //Se cancelar as perguntas sai do programa
  Endif

    MsAguarde({|| Imprimir() },"Gerando Planilha Excel   ","Filtrando Registros de acordo com Paramêtros...")
   
Return    

Static Function Imprimir()
    Local aArea            := GetArea()
    Local cQuery           := ""
    Local cQuery1          := ""
//  Local MV_Par03 := "30/09/2022"     ///  Tirar assim que der certo Jose 28/10/2022
    Local cNumero 
    Local cValorNF         := 0
    Local cDesconto        := 0
    Local cValorProduto    := 0
    Local cPValorProduto   := 0
    Local cValorComissao   := 0
    Local cValorLiqComi    := 0
    Local cValorDesc       := 0
    Local cTrep            := 0
    Local cPerCom          := ''
    Local cTTotalvlnf      := 0
    Local cTTotalDescontos := 0
    Local cTTotalVlProduto := 0
    Local cTTotalICMS_S_T  := 0
    Local cTTotalIPI       := 0
    Local cTTotalVlLiquido := 0
    Local cTTotalRep       := 0
    Local cTotalVlNF       := 0 
    Local cTotalDescontos  := 0
    Local cTotalVlProduto  := 0
    Local cTotalICMS_S_T   := 0
    Local cTotalIPI        := 0
    Local cTotalVlLiquido  := 0
    Local cTotalRep        := 0
    Local cCodRep          := 0
    Local cParcela         := 0
    Local cImposto         := 0
    Local cIcmsst          := 0
    Local cIpi             := 0
    Local cFiller          := ""
    Local cFiller1         := "Total Comissão Repres.=>"
    Local cFiller2         := "Total "
    Local cArquivo         := "C:\Temp\"+"ZTCFIN01.xml"
//  Local cArquivo         := "C:\Temp\"+"ZTCFIN01.xlsx"
    Local oExcel           := FWMsExcelEx():New()

//Pegando os dados
////////////////////////--------------------------------------------------------------------------//////////////////////////////////
cQuery := "SELECT SE1.E1_CLIENTE   AS CODIGO,                                                     " + STR_PULA      
cQuery += "       SE1.E1_NOMCLI    AS CLIENTE,                                                    " + STR_PULA 
cQuery += "       SE1.E1_LOJA      AS LOJA,                                                       " + STR_PULA 
cQuery += "       SE1.E1_NUM       AS NUMERO,                                                     " + STR_PULA
cQuery += "       SUBSTRING(SE1.E1_VENCTO,7,2) + '/' + SUBSTRING(SE1.E1_VENCTO,5,2) + '/' + SUBSTRING(SE1.E1_VENCTO,1,4) AS VENCIMENTO,    " + STR_PULA 
cQuery += "	      SE1.E1_VALOR     AS VALOR_NF,                                                   " + STR_PULA
cQuery += "	      'DESCONTOS' = ( ( ISNULL( ( SE1.E1_DESCONT ),0 ) ) + SE1.E1_SALDO ),            " + STR_PULA //  ACRESCENTADO JOSE 17/03/2023 + SE1.E1_SALDO )
cQuery += "       SF2.F2_VALMERC   AS VALOR_PRODUTO,                                              " + STR_PULA   
cQuery += "       SF2.F2_ICMSRET   AS ICMS_ST,                                                    " + STR_PULA
cQuery += "       SF2.F2_VALIPI    AS VAL_IPI,                                                    " + STR_PULA
cQuery += "	      SE1.E1_VALOR     AS LIQUID_COMISSAO,                                            " + STR_PULA
cQuery += "       SF2.F2_VEND1,                                                                   " + STR_PULA 
cQuery += "       ZAA.ZAA_NOMREP   AS REPRESENTANTE,                                              " + STR_PULA
cQuery += "       ZAA.ZAA_PERCOM   AS PERC_COMI,                                                  " + STR_PULA
cQuery += "	      ROUND( ( ( SUM ( SE1.E1_VALOR ) * ZAA.ZAA_PERCOM ) / 100 ),2 )  AS VALOR_COMI,  " + STR_PULA 
cQuery += "       SUBSTRING( SE1.E1_BAIXA,7,2 ) + '/' + SUBSTRING( SE1.E1_BAIXA,5,2 ) + '/' + SUBSTRING( SE1.E1_BAIXA,1,4 ) AS DATA_PAGTO, " + STR_PULA 
cQuery += "       SE1.E1_TIPO      AS TIPO,                                                       " + STR_PULA
cQuery += "       SE1.E1_PARCELA   AS PARCELA,                                                    " + STR_PULA
cQuery += "       SE1.E1_VALOR     AS VALOR_NFF,                                                  " + STR_PULA
cQuery += "       SA1.A1_VEND      AS COD_REPRES,                                                 " + STR_PULA
cQuery += "       SA1.A1_COMIS,                                                                   " + STR_PULA
cQuery += "       SA1.A1_COD,                                                                     " + STR_PULA
cQuery += "       SA1.A1_LOJA,                                                                    " + STR_PULA
cQuery += "       SE1.E1_FILIAL    AS FILIAL,                                                     " + STR_PULA
cQuery += "       SE1.E1_PREFIXO   AS PREFIXO,                                                    " + STR_PULA
cQuery += "       SE5.E5_MOTBX     AS MOTBX                                                       " + STR_PULA
cQuery += "  FROM "+RetSqlName("SE1")+" SE1                                                       " + STR_PULA
cQuery += "	           INNER JOIN "+RetSqlName("SE5")+" SE5 WITH (NOLOCK) ON SE5.D_E_L_E_T_ = ''  " + STR_PULA    
cQuery += "                          AND SE5.E5_FILIAL   = SE1.E1_FILIAL                          " + STR_PULA
cQuery += "                          AND SE5.E5_RECPAG   = 'R'                                    " + STR_PULA
cQuery += "                          AND SE5.E5_CLIFOR   = SE1.E1_CLIENTE                         " + STR_PULA                    
cQuery += "                          AND SE5.E5_LOJA     = SE1.E1_LOJA                            " + STR_PULA
cQuery += "                          AND SE5.E5_NUMERO   = SE1.E1_NUM                             " + STR_PULA
cQuery += "                          AND SE5.E5_PREFIXO  = SE1.E1_PREFIXO                         " + STR_PULA
cQuery += "                          AND SE5.E5_TIPO     = SE1.E1_TIPO                            " + STR_PULA 
cQuery += "                          AND SE5.E5_DATA     = SE1.E1_BAIXA                           " + STR_PULA
cQuery += "                          AND ( SE5.E5_MOTBX  = 'NOR'  OR  SE5.E5_MOTBX = 'CMP' )      " + STR_PULA
cQuery += "       LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON SF2.D_E_L_E_T_  = '' " + STR_PULA 
cQuery += "	                         AND SF2.D_E_L_E_T_  = ''                                     " + STR_PULA
cQuery += "                          AND SF2.F2_DOC      = SE1.E1_NUM                             " + STR_PULA
cQuery += "                          AND SF2.F2_CLIENTE  = SE1.E1_CLIENTE                         " + STR_PULA
cQuery += "                          AND SF2.F2_LOJA     = SE1.E1_LOJA                            " + STR_PULA
cQuery += "       LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON SA1.D_E_L_E_T_  = '' " + STR_PULA
cQuery += "                          AND SA1.A1_COD      = SE1.E1_CLIENTE                         " + STR_PULA
cQuery += "                          AND SA1.A1_LOJA     = SE1.E1_LOJA                            " + STR_PULA 
cQuery += "	           INNER JOIN "+RetSqlName("ZAA")+" ZAA WITH (NOLOCK) ON ZAA.D_E_L_E_T_  = '' " + STR_PULA
cQuery += "                          AND ZAA.ZAA_FILIAL  = SE1.E1_FILIAL                          " + STR_PULA
cQuery += "                          AND ZAA.ZAA_CODREP  = SA1.A1_VEND                            " + STR_PULA
cQuery += "                          AND ZAA.ZAA_DATINI  <= '"+Dtos(MV_PAR01)+"'                  " + STR_PULA  
cQuery += "                          AND ZAA.ZAA_DATFIN  >= '"+Dtos(MV_PAR02)+"'                  " + STR_PULA     
cQuery += " WHERE SE1.D_E_L_E_T_  = ''                                                            " + STR_PULA
cQuery += "   AND SE1.E1_FILIAL   = '"+xFilial("SE1")+"'                                          " + STR_PULA
cQuery += "   AND SE1.E1_TIPO     = 'NF'                                                          " + STR_PULA
cQuery += "   AND SE1.E1_BAIXA   <> ''                                                            " + STR_PULA // TIRADO JOSE 17/03/2023 AND SE1.E1_SALDO = 0
cQuery += "   AND (SE1.E1_BAIXA  >= '"+Dtos(MV_PAR01)+"'                                          " + STR_PULA 
cQuery += "   AND SE1.E1_BAIXA   <= '"+Dtos(MV_PAR02)+"' )                                        " + STR_PULA  
//cQuery += "   AND SE1.E1_STATUS   = 'B'                                                         " + STR_PULA // TIRADO JOSE 17/03/2023
//cQuery += "  AND  SE1.E1_VEND1    = '000015'                                                    " + STR_PULA // TIRAR 18/11/2022 
cQuery += "GROUP BY SE1.E1_CLIENTE, SE1.E1_NOMCLI,   SE1.E1_LOJA,  SE1.E1_BAIXA,   SE1.E1_SALDO,  " + STR_PULA 
cQuery += "         SE1.E1_VALOR,   SE1.E1_DESCONT,  SF2.F2_VEND1, SE1.E1_COMIS1,  SE1.E1_FILIAL, " + STR_PULA
cQuery += "         SE1.E1_VENCTO,  SE1.E1_PARCELA,  SA1.A1_VEND,  SA1.A1_COMIS,   SA1.A1_COD,    " + STR_PULA
cQuery += "         SA1.A1_LOJA,    SE1.E1_TIPO,     SE1.E1_NUM,   SF2.F2_VALMERC, ZAA_PERCOM,    " + STR_PULA
cQuery += "         ZAA_NOMREP,     SE1.E1_PREFIXO,  SE5.E5_MOTBX, SF2.F2_ICMSRET, SF2.F2_VALIPI  " + STR_PULA
cQuery += "ORDER BY 20, 1, 3, 4, 18, 17                                                           " + STR_PULA  
                 // 20 = SA1.A1_VEND    (Vendedor)    
                 //  1 = SE1.E1_CLIENTE (Cliente)   
                 //  3 = SE1.E1_LOJA    (Loja)
                 //  4 = SE1.E1_NUM     (Titulo)
                 // 18 = SE1.E1_PARCELA (Parcela)    
                 // 17 = SE1.E1_TIPO    (Tipo do Titulo)

TCQuery cQuery New Alias "QRYCOM"

MsProcTxt("Aguarde...   Processando Registros Selecionados... ")  

//Criando o objeto que irá gerar o conteúdo do Excel
//Aba 01 
oExcel:AddworkSheet("Comissao") // Não utilizar número junto com sinal de menos. Ex.: 1-
//Criando a Tabela   
ccabecalho :="ZTCFIN01                                " + "DATA.:    " + DTOC(dDataBase) + "    AS    "  +Time()+ "                PERIODO DE  " + DTOC(MV_PAR01) + "    ATÉ    " + DTOC(MV_PAR02) + "                    RELATORIO DE COMISSÃO VENDEDORES TECPOLPA"
//Criando Colunas
oExcel:AddTable ("Comissao",ccabecalho)  // Adiciona a tabela 
oExcel:AddColumn("Comissao",ccabecalho,"CODIGO"            ,1)    //,1 = Modo Texto
oExcel:AddColumn("Comissao",ccabecalho,"CLIENTE"           ,1)    //,2 = Valor sem R$
oExcel:AddColumn("Comissao",ccabecalho,"LOJA"              ,1)    //,3 = Valor com R$
oExcel:AddColumn("Comissao",ccabecalho,"NF"                ,1)
oExcel:AddColumn("Comissao",ccabecalho,"VENCIMENTO"        ,2)
oExcel:AddColumn("Comissao",ccabecalho,"VALOR NF"          ,3,3)  //,3,2 ,3,3
oExcel:AddColumn("Comissao",ccabecalho,"DESCONTOS"         ,3,3)  //,3,2 ,3,3
oExcel:AddColumn("Comissao",ccabecalho,"VALOR PRODUTO"     ,3,3)  //,3,2 ,3,3
oExcel:AddColumn("Comissao",ccabecalho,"ICMS_S_T"          ,3,3)  //,3,2 ,3,3
oExcel:AddColumn("Comissao",ccabecalho,"IPI"               ,3,3)  //,3,2 ,3,3
oExcel:AddColumn("Comissao",ccabecalho,"VLR. LIQUIDO"      ,1,3)  //,3,2 ,3,3
oExcel:AddColumn("Comissao",ccabecalho,"COD.REPRES"        ,3)    //,1,1
oExcel:AddColumn("Comissao",ccabecalho,"REPRESENTANTE"     ,3)    //,1,2
oExcel:AddColumn("Comissao",ccabecalho,"PERCENTUAL"        ,3)    //,2,2)
oExcel:AddColumn("Comissao",ccabecalho,"COMISSAO ($)"      ,1,3)  //,2,2
oExcel:AddColumn("Comissao",ccabecalho,"DATA DE PAGAMENTO" ,2)
oExcel:AddColumn("Comissao",ccabecalho,"DATA PAGTO TITULO" ,2)

While  !(QRYCOM->(EoF()))
/////////-- ACRESCENTEI JOSE 14/03/2023 -----------------------------/////////////
       cQuery1 := "SELECT COUNT(SE11.E1_PARCELA) AS PARCELA          " + STR_PULA
       cQuery1 += "  FROM "+RetSqlName("SE1")+" SE11                 " + STR_PULA
       cQuery1 += " WHERE SE11.D_E_L_E_T_  = ''                      " + STR_PULA
       cQuery1 += "   AND SE11.E1_FILIAL   = '"+xFilial("SE1")+"'    " + STR_PULA
       cQuery1 += "   AND SE11.E1_PREFIXO <> 'R'                     " + STR_PULA
       cQuery1 += "   AND SE11.E1_TIPO     = 'NF'                    " + STR_PULA
       cQuery1 += "   AND SE11.E1_CLIENTE  = '"+(QRYCOM->CODIGO)+"'  " + STR_PULA
       cQuery1 += "   AND SE11.E1_LOJA     = '"+(QRYCOM->LOJA)+"'    " + STR_PULA 
       cQuery1 += "   AND SE11.E1_NUM      = '"+(QRYCOM->NUMERO)+"'  " + STR_PULA  

       TCQuery cQuery1 New Alias "QRYIMP"
       cParcela = 0
       cImposto = 0
       cIcmsst  = 0
       cIpi     = 0
       While  !(QRYIMP->(EoF()))
               cParcela = QRYIMP->PARCELA
          QRYIMP->(DbSkip())
       EndDo

       QRYIMP->(DbCloseArea())
       RestArea(aArea) 

       cImposto = ( QRYCOM->ICMS_ST + QRYCOM->VAL_IPI ) / cParcela 
       cIcmsst  = ( QRYCOM->ICMS_ST ) / cParcela   
       cIpi     = ( QRYCOM->VAL_IPI ) / cParcela 
       cPValorProduto = ( QRYCOM->VALOR_PRODUTO ) / CParcela
/////--------  até aqui 14/03/2023  -----------------------------------------///////
       If cTrep             = 0
          cTrep            := 1
          cTTotalvlnf      := 0
          cTTotalDescontos := 0
          cTTotalVlProduto := 0
          cTTotalICMS_S_T  := 0
          cTTotalIPI       := 0
          cTTotalVlLiquido := 0
          cTTotalRep       := 0
          cTotalvlnf       := 0
          cTotalDescontos  := 0
          cTotalVlProduto  := 0
          cTotalICMS_S_T   := 0
          cTotalIPI        := 0
          cTotalVlLiquido  := 0
          cTotalRep        := 0
          cValorComissao   := 0
          cPerCom          := ''
          cValorLiqComi    := QRYCOM->VALOR_NF - cImposto
          cCodRep          := QRYCOM->COD_REPRES
       EndIf

       If ( QRYCOM->COD_REPRES <> cCodRep )
           oExcel:AddRow("Comissao",ccabecalho,{;
           cFiller,;
           cFiller2 + "Vendedor ==>",;
           cFiller,;
           cFiller,;
           cFiller,;
           cTotalVlNF,;
           cTotalDescontos,;
           cTotalVlProduto,;
           cTotalICMS_S_T,;
           cTotalIPI,; 
           cTotalVlLiquido,;
           cFiller,;
           cFiller1,;
           cFiller,;
           cTotalRep,;
           cFiller,;
           cFiller; 
           })

           oExcel:AddRow("Comissao",ccabecalho,{;
           cFiller,;
           cFiller,;
           cFiller,;
           cFiller,;
           cFiller,;
           cFiller,;
           cFiller,;
           cFiller,;
           cFiller,;
           cFiller,; 
           cFiller,;
           cFiller,;
           cFiller,;
           cFiller,;
           cFiller,;
           cFiller,;
           cFiller; 
           })

           cTTotalvlnf      := cTTotalvlnf      + cTotalvlnf
           cTTotalDescontos := cTTotalDescontos + cTotalDescontos
           cTTotalVlProduto := cTTotalVlProduto + cTotalVlProduto
           cTTotalICMS_S_T  := cTTotalICMS_S_T  + cTotalICMS_S_T  
           cTTotalIPI       := cTTotalIPI       + cTotalIPI       
           cTTotalVlLiquido := cTTotalVlLiquido + cTotalVlLiquido 
           cTTotalRep       := cTTotalRep       + cTotalRep
           cValorComissao   := 0
           cTotalvlnf       := 0
           cTotalDescontos  := 0
           cTotalVlProduto  := 0
           cTotalICMS_S_T   := 0
           cTotalIPI        := 0
           cTotalVlLiquido  := 0
           cTotalRep        := 0
       Endif

       cValorNF      := QRYCOM->VALOR_NF
       cDesconto     := QRYCOM->DESCONTOS
       cValorProduto := cPValorProduto // Alterado jose 22/03/2023 QRYCOM->VALOR_PRODUTO // ALTERADO JOSE 21/03/2023 QRYCOM->VALOR_NF
       cValorLiqComi := QRYCOM->VALOR_NF - cImposto - cDesconto
       cNumero       := ( QRYCOM->NUMERO + ' - ' + QRYCOM->PARCELA )
       cCodRep       := QRYCOM->COD_REPRES
       cValorDesc    := 0
/*------------ jOSE 18/11/2022  -------------------------------------------------------------------*/
       cQuery1 := "SELECT 'ABATIMENTO' = ( E5_VALOR ),            " + STR_PULA
       cQuery1 += "       'JUROS'      =   E5_TIPODOC             " + STR_PULA
       cQuery1 += "  FROM "+RetSqlName("SE5")+"                   " + STR_PULA
       cQuery1 += " WHERE D_E_L_E_T_  = ''                        " + STR_PULA
       cQuery1 += "   AND E5_NUMERO   = '"+QRYCOM->NUMERO+"'      " + STR_PULA
       cQuery1 += "   AND E5_FILIAL   = '"+QRYCOM->FILIAL+"'      " + STR_PULA
       cQuery1 += "   AND E5_PREFIXO  = '"+QRYCOM->PREFIXO+"'     " + STR_PULA
       cQuery1 += "   AND E5_CLIFOR   = '"+QRYCOM->CODIGO+"'      " + STR_PULA
       cQuery1 += "   AND E5_LOJA     = '"+QRYCOM->LOJA+"'        " + STR_PULA
       cQuery1 += "   AND E5_PARCELA  = '"+QRYCOM->PARCELA+"'     " + STR_PULA
       cQuery1 += "   AND E5_TIPO    <> 'NCC'                     " + STR_PULA
       cQuery1 += "   AND E5_DATA     < '"+Dtos(MV_PAR01)+"'      " + STR_PULA 
       cQuery1 += "GROUP BY E5_VALOR, E5_TIPODOC                  " + STR_PULA
       TCQuery cQuery1 New Alias "QRYPAG"

    While  !(QRYPAG->(EoF()))
           If QRYPAG->JUROS = "JR"
              cValorDesc = ( cValorDesc - QRYPAG->ABATIMENTO )
           else
              cValorDesc = ( cValorDesc + QRYPAG->ABATIMENTO ) 
          EndIf

     //Pulando Registro
     QRYPAG->(DbSkip())
    EndDo

    QRYPAG->(DbCloseArea())
    RestArea(aArea) 

/*-------------------------------------------------------------------------------------------------*/
    cQuery1 := "SELECT 'DESCONTO' = ( E5_VALOR )                 " + STR_PULA
    cQuery1 += "  FROM "+RetSqlName("SE5")+"                     " + STR_PULA
    cQuery1 += " WHERE D_E_L_E_T_  = ''                          " + STR_PULA
    cQuery1 += "   AND E5_NUMERO   = '"+QRYCOM->NUMERO+"'        " + STR_PULA
    cQuery1 += "   AND E5_FILIAL   = '"+QRYCOM->FILIAL+"'        " + STR_PULA
    cQuery1 += "   AND E5_PREFIXO  = '"+QRYCOM->PREFIXO+"'       " + STR_PULA
    cQuery1 += "   AND E5_CLIFOR   = '"+QRYCOM->CODIGO+"'        " + STR_PULA
    cQuery1 += "   AND E5_LOJA     = '"+QRYCOM->LOJA+"'          " + STR_PULA
//  cQuery1 += "   AND E5_PARCELA  = '"+QRYCOM->PARCELA+"'       " + STR_PULA
//  cQuery1 += "   AND ( E5_TIPO   = 'NCC' AND E5_MOTBX = 'CMP') " + STR_PULA
//  cQuery1 += "   AND ( E5_MOTBX <> '"+QRYCOM->MOTBX+"'         " + STR_PULA
    cQuery1 += "   AND ( E5_MOTBX  = 'CMP' )                     " + STR_PULA 
    cQuery1 += "   AND (E5_DATA   >= '"+Dtos(MV_PAR01)+"'        " + STR_PULA 
    cQuery1 += "   AND  E5_DATA   <= '"+Dtos(MV_PAR02)+"' )      " + STR_PULA 
    cQuery1 += "GROUP BY E5_VALOR                                " + STR_PULA
    TCQuery cQuery1 New Alias "QRYDES"

    While  !(QRYDES->(EoF()))
           cDesconto     = ( cDesconto     + QRYDES->DESCONTO )
           cValorLiqComi = ( cValorLiqComi - QRYDES->DESCONTO )

     //Pulando Registro
    QRYDES->(DbSkip())
    EndDo

    QRYDES->(DbCloseArea())
    RestArea(aArea) 
    cValorLiqComi  = cValorLiqComi - cValorDesc     /// acrescetei aqui 18/11/2022
    If cValorLiqComi < 0   /// acrescetei aqui 17/03/2023
       cValorLiqComi = 0   /// acrescetei aqui 17/03/2023
    EndIf                  /// acrescetei aqui 17/03/2023
    cDesconto      = cDesconto + cValorDesc
    cValorComissao = ( ( cValorLiqComi * QRYCOM->PERC_COMI ) / 100 )
 // cPerCom  = Str( QRYCOM->PERC_COMI ) + ' %    ' 
    cPerCom := TransForm( QRYCOM->PERC_COMI,"999.99" ) + " %    "
    oExcel:AddRow("Comissao",ccabecalho,{;
    QRYCOM->CODIGO,;
    QRYCOM->CLIENTE,;
    QRYCOM->LOJA,;
    cNumero,;
    QRYCOM->VENCIMENTO,;
    cValornf,;
    cDesconto,;
    cValorProduto,; 
    cIcmsst,;
    cIpi,;
    cValorLiqComi,;    //QRYCOM->LIQUID_COMISSAO,;
    QRYCOM->COD_REPRES,;
    QRYCOM->REPRESENTANTE,;
    cPerCom,;          //QRYCOM->PERC_COMI,;
    cValorComissao,;
    MV_PAR03,; 
    QRYCOM->DATA_PAGTO;
    })

    cTotalVlNF      := cTotalVlNF      + cValornf
    cTotalDescontos := cTotalDescontos + cDesconto
    cTotalVlProduto := cTotalVlProduto + cPValorProduto
    cTotalICMS_S_T  := cTotalICMS_S_T  + cIcmsst
    cTotalIPI       := cTotalIPI       + cIpi
    cTotalVlLiquido := cTotalVlLiquido + cValorLiqComi
    cTotalRep       := cTotalRep       + cValorComissao 
  //Pulando Registro
    QRYCOM->(DbSkip())

EndDo

oExcel:AddRow("Comissao",ccabecalho,{;
cFiller,;
cFiller2 + "Vendedor ==>",;
cFiller,;
cFiller,;
cFiller,;
cTotalVlNF,;
cTotalDescontos,;
cTotalVlProduto,;
cTotalICMS_S_T,;
cTotalIPI,; 
cTotalVlLiquido,;
cFiller,;
cFiller1,;
cFiller,;
cTotalRep,;
cFiller,;
cFiller; 
})

oExcel:AddRow("Comissao",ccabecalho,{;
cFiller,;
cFiller,;
cFiller,;
cFiller,;
cFiller,;
cFiller,;
cFiller,;
cFiller,;
cFiller,;
cFiller,; 
cFiller,;
cFiller,;
cFiller,;
cFiller,;
cFiller,;
cFiller,;
cFiller; 
})

cTTotalvlnf      := cTTotalvlnf      + cTotalvlnf
cTTotalDescontos := cTTotalDescontos + cTotalDescontos
cTTotalVlProduto := cTTotalVlProduto + cTotalVlProduto
cTTotalICMS_S_T  := cTTotalICMS_S_T  + cTotalICMS_S_T  
cTTotalIPI       := cTTotalIPI       + cTotalIPI       
cTTotalVlLiquido := cTTotalVlLiquido + cTotalVlLiquido 
cTTotalRep       := cTTotalRep       + cTotalRep

oExcel:AddRow("Comissao",ccabecalho,{;
cFiller,;
cFiller2 + "GERAL  ==>",;
cFiller,;
cFiller,;
cFiller,;
cTTotalVlNF,;
cTTotalDescontos,;
cTTotalVlProduto,;
cTTotalICMS_S_T,;
cTTotalIPI,; 
cTTotalVlLiquido,;
cFiller,;
cFiller,;
cFiller,;
cTTotalRep,;
cFiller,;
cFiller; 
})

//Ativando o arquivo e gerando o xml
oExcel:Activate()
MsgRun("Processando...","Aguarde Gerando arquivo em Excel...",{|| oExcel:GetXMLFile(cArquivo) } )

//Abrindo o excel e abrindo o arquivo xml
oExcel := MsExcel():New()           //Abre uma nova conexão com Excel
oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
oExcel:SetVisible(.T.)              //Visualiza a planilha
oExcel:Destroy()                    //Encerra o processo do gerenciador de tarefas

QRYCOM->(DbCloseArea())
RestArea(aArea)

Return


/*--------------------------Pego da internet----------------------------------------   
User Function TESTE()
Local oExcel := FWMsExcelEx():New()
oExcel:AddworkSheet("Teste - 1")
oExcel:AddTable ("Teste - 1","Titulo de teste 1")
oExcel:AddColumn("Teste - 1","Titulo de teste 1","Col1",1,1)
oExcel:AddColumn("Teste - 1","Titulo de teste 1","Col2",2,2)
oExcel:AddColumn("Teste - 1","Titulo de teste 1","Col3",3,3)
oExcel:AddColumn("Teste - 1","Titulo de teste 1","Col4",1,1)
oExcel:SetCelBold(.T.)
oExcel:SetCelFont('Arial')
oExcel:SetCelItalic(.T.)
oExcel:SetCelUnderLine(.T.)
oExcel:SetCelSizeFont(10)

oExcel:AddRow("Teste - 1","Titulo de teste 1",{11,12,13,14},{1,3})

oExcel:SetCelBold(.T.)
oExcel:SetCelFont('Arial')
oExcel:SetCelItalic(.T.)
oExcel:SetCelUnderLine(.T.)
oExcel:SetCelSizeFont(15)
oExcel:SetCelFrColor("#FFFFFF")
oExcel:SetCelBgColor("#000666")

oExcel:AddRow("Teste - 1","Titulo de teste 1",{21,22,23,24},{1})

oExcel:SetCelBold(.T.)
oExcel:SetCelFont('Courier New')
oExcel:SetCelItalic(.F.)
oExcel:SetCelUnderLine(.T.)
oExcel:SetCelSizeFont(10)
oExcel:SetCelFrColor("#FFFFFF")
oExcel:SetCelBgColor("#000333")

oExcel:AddRow("Teste - 1","Titulo de teste 1",{31,32,33,34},{2,4})

oExcel:SetCelBold(.T.)
oExcel:SetCelFont('Line Draw')
oExcel:SetCelItalic(.F.)
oExcel:SetCelUnderLine(.F.)
oExcel:SetCelSizeFont(12)
oExcel:SetCelFrColor("#FFFFFF")
oExcel:SetCelBgColor("#D7BCFB")


oExcel:AddRow("Teste - 1","Titulo de teste 1",{41,42,43,44},{3})

oExcel:AddworkSheet("Teste - 2")
oExcel:AddTable("Teste - 2","Titulo de teste 1")
oExcel:AddColumn("Teste - 2","Titulo de teste 1","Col1",1)
oExcel:AddColumn("Teste - 2","Titulo de teste 1","Col2",2)
oExcel:AddColumn("Teste - 2","Titulo de teste 1","Col3",3)
oExcel:AddColumn("Teste - 2","Titulo de teste 1","Col4",1)
oExcel:AddRow("Teste - 2","Titulo de teste 1",{11,12,13,stod("20121212")})
oExcel:AddRow("Teste - 2","Titulo de teste 1",{21,22,23,stod("20121212")})
oExcel:AddRow("Teste - 2","Titulo de teste 1",{31,32,33,stod("20121212")})
oExcel:AddRow("Teste - 2","Titulo de teste 1",{41,42,43,stod("20121212")})
oExcel:AddRow("Teste - 2","Titulo de teste 1",{51,52,53,stod("20121212")})
oExcel:Activate()
oExcel:GetXMLFile("TESTE.xml")
Return
--------------------------------------------------------------------------------*/
