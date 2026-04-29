//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "Avprint.ch"
#include 'font.ch'
#include 'totvs.ch'

//Constantes
#Define STR_PULA    Chr(13)+Chr(10)

/*/{Protheus.doc} ZEXPR05
//RETIRADOS DO ESTOQUE E NÃO DESPACHADOS
@type function
@version  v.2022.08.09.001 
@author joseuliana
@since 09/08/2022
@return variant, return_description 
/*/

User Function ZEXPR05()
    Local _cPerg       := "ZEXPR05   "  
    Private MV_Par01
    Private aMatDad    := {} 
 
   if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  	endif 

    If !Pergunte( _cPerg ) 
       Return() //Se cancelar as perguntas sai do programa
    Endif

    /* Nelieder - criei função para utilizar a tela de progress para o usuário */ 
    MsAguarde({|| Imprimir() },"Gerando Planilha Excel   ","Filtrando Registros de acordo com Paramêtros...")
   
Return    

/* Nelieder - criei função para utilizar a tela de progress para o usuário */
Static Function Imprimir()
    Local aArea        := GetArea()
    Local cQuery       := ""
//  Local cQuery1      := ""
//  Local vValor       := 0
    Local nY           := 0
    Local nPosDad      := 0
    Local oFWMsExcel
    Local oExcel
//  Local cArquivo     := GetTempPath()+'ZEXPR05.xml'
    Local cArquivo     := "C:\Temp\"+"ZEXPR05.xml"
//  Local nAtual       := 0
    Local vFilial      := ''
    Local vProduto     := ''
    Local vPedido      := ''
    Local vItemPedido  := ''
//  Local vLocDest     := ''

    //Pegando os dados
    cQuery := "SELECT ZZJ.ZZJ_FILIAL          AS FILIAL, "                           + STR_PULA
    cQuery += "       SC5.C5_NUM              AS PEDIDO, "                           + STR_PULA
    cQuery += "       ZZJ.ZZJ_CODIGO          AS PALLETS, "                          + STR_PULA
    cQuery += "       ZZJ.ZZJ_FLAG            AS FLAG, "                             + STR_PULA
    cQuery += "       CASE "                                                         + STR_PULA
    cQuery += "           WHEN ZZJ.ZZJ_FLAG  = '1' THEN 'Pallet de Transferência de Produto Digitado e Não Transferido' "                   + STR_PULA
    cQuery += "		      WHEN ZZJ.ZZJ_FLAG  = '2' THEN 'Pallet de transferência de produto Digitado e Transferido de Almoxarifado' "       + STR_PULA
    cQuery += "		      WHEN ZZJ.ZZJ_FLAG  = '3' TH   EN 'Pallet de Separação de Pedido Não Transferido' "                                + STR_PULA
    cQuery += "		      WHEN ZZJ.ZZJ_FLAG  = '4' THEN 'Pallet de Separação de Pedido Transferido de Almoxarifado' "                       + STR_PULA
    cQuery += "		      WHEN ZZJ.ZZJ_FLAG  = '5' THEN 'Pallet de Separação de Pedido que Gerou Nota Fiscal de Transferência p/Depósito' " + STR_PULA
    cQuery += "	      END AS DESCRFLAG, "                                            + STR_PULA
    cQuery += "       ZZJ.ZZJ_LOCDES          AS LOCALDEST, "                        + STR_PULA
    cQuery += "	      ZZJ.ZZJ_LOCORI          AS LOCAL_ORIGEM, "                     + STR_PULA
    cQuery += "	      SC6.C6_LOCAL            AS LOCAL_PEDIDO, "                     + STR_PULA
    cQuery += "       ISNULL((SF2.F2_DOC),'') AS NOTA_FISCCAL, "                     + STR_PULA
    cQuery += "       ZZK.ZZK_PRODUT          AS PRODUTO, "                          + STR_PULA
    cQuery += "       SB1.B1_DESC             AS DESCRICAO, "                        + STR_PULA
    cQuery += "       SC6.C6_QTDVEN           AS QTD_PEDIDO, "                       + STR_PULA
    cQuery += "       SC6.C6_ITEM             AS ITEM_PEDIDO, "                      + STR_PULA
    cQuery += "	      CASE "                                                         + STR_PULA
    cQuery += "           WHEN SC6.C6_LOCAL = '03' THEN  SUM(ZZK.ZZK_QUANT) "        + STR_PULA 
    cQuery += "	      END AS QTDDEP03, "                                             + STR_PULA
    cQuery += "       CASE "                                                         + STR_PULA
    cQuery += "           WHEN SC6.C6_LOCAL = '30' THEN  SUM(ZZK.ZZK_QUANT) "        + STR_PULA
    cQuery += "	      END AS QTDDEP30, "                                             + STR_PULA
    cQuery += "	      CASE "                                                         + STR_PULA
    cQuery += "	          WHEN SC6.C6_LOCAL = 'G3' THEN  SUM(ZZK.ZZK_QUANT) "        + STR_PULA
    cQuery += "	      END AS QTDDEPG3, "                                             + STR_PULA
    cQuery += "	      CASE "                                                         + STR_PULA
    cQuery += "	          WHEN SC6.C6_LOCAL <> '03' "                                + STR_PULA 
    cQuery += "	           AND SC6.C6_LOCAL <> '30' "                                + STR_PULA
    cQuery += "		       AND SC6.C6_LOCAL <> 'G3' THEN  SUM(ZZK.ZZK_QUANT) "       + STR_PULA
    cQuery += "		  END AS QTDDEPDV, "                                             + STR_PULA
    cQuery += "       SUM(ZZK.ZZK_QUANT)       AS QUANTIDADE, "                      + STR_PULA
    cQuery += "       ISNULL((SD2.D2_QUANT),0) AS QTDEVENDAS, "                      + STR_PULA
    cQuery += "       CASE "                                                         + STR_PULA
    cQuery += "           WHEN SD2.D2_QUANT IS NULL       THEN 'NAO' "               + STR_PULA
    cQuery += "           WHEN SD2.D2_QUANT IS NOT NULL   THEN 'SIM' "               + STR_PULA
    cQuery += "       END AS FATURADO, "                                             + STR_PULA
    cQuery += "       CASE "                                                         + STR_PULA
    cQuery += "           WHEN ZZJ.ZZJ_CODIGO IS NULL     THEN 'NAO' "               + STR_PULA
    cQuery += "           WHEN ZZJ.ZZJ_CODIGO IS NOT NULL THEN 'SIM' "               + STR_PULA
    cQuery += "       END AS BIPADO "                                                + STR_PULA
    cQuery += "  FROM SC5010 SC5 "                                                   + STR_PULA
    cQuery += "       LEFT OUTER JOIN SF2010 SF2 WITH(NOLOCK) ON SF2.D_E_L_E_T_ = '' "                                            + STR_PULA 
    cQuery += "	                                             AND SF2.F2_DOC     = SC5.C5_NOTA "                                   + STR_PULA
    cQuery += "			    		                         AND SF2.F2_SERIE   = SC5.C5_SERIE "                                  + STR_PULA
    cQuery += "                                              AND SF2.F2_FILIAL  = SC5.C5_FILIAL "                                 + STR_PULA
    cQuery += "       LEFT OUTER JOIN ZZK010 ZZK WITH(NOLOCK) ON ZZK.D_E_L_E_T_ = '' "                                            + STR_PULA
    cQuery += "	                                             AND ZZK.ZZK_PEDIDO = SC5.C5_NUM "                                    + STR_PULA
    cQuery += "                                              AND ZZK.ZZK_FILIAL = SC5.C5_FILIAL "                                 + STR_PULA
    cQuery += "										         AND (ZZK.ZZK_PRODUT BETWEEN ('"+MV_PAR03+"') AND ('"+MV_PAR04+"')) " + STR_PULA 
    cQuery += "       LEFT OUTER JOIN ZZJ010 ZZJ WITH(NOLOCK) ON ZZJ.D_E_L_E_T_ ='' "                                             + STR_PULA
    cQuery += "	                                             AND ZZJ_FILIAL     = ZZK_FILIAL "                                    + STR_PULA
    cQuery += "                                              AND ZZJ_CODIGO     = ZZK_CODIGO "                                    + STR_PULA
    cQuery += "											     AND (ZZJ.ZZJ_BORDER BETWEEN ('"+MV_PAR05+"') AND ('"+MV_PAR06+"')) " + STR_PULA 
    cQuery += "       LEFT OUTER JOIN SD2010 SD2 WITH(NOLOCK) ON SD2.D_E_L_E_T_ = '' "                                            + STR_PULA 
    cQuery += "                                              AND SD2.D2_FILIAL  = SC5.C5_FILIAL "                                 + STR_PULA
    cQuery += "                                              AND SD2.D2_PEDIDO  = ZZK.ZZK_PEDIDO "                                + STR_PULA
    cQuery += "                                              AND SD2.D2_COD     = ZZK.ZZK_PRODUT "                                + STR_PULA
    cQuery += "            INNER JOIN SC6010 SC6 WITH(NOLOCK) ON SC6.D_E_L_E_T_ = '' "                                            + STR_PULA
    cQuery += "	                                             AND SC6.C6_NUM     = SC5.C5_NUM "                                    + STR_PULA
    cQuery += "							                     AND SC6.C6_FILIAL  = SC5.C5_FILIAL "                                 + STR_PULA
    cQuery += "                                              AND SC6.C6_PRODUTO = ZZK.ZZK_PRODUT "                                + STR_PULA 
    cQuery += "            INNER JOIN SB1010 SB1 WITH(NOLOCK) ON SB1.D_E_L_E_T_ = '' "                                            + STR_PULA
    cQuery += "                                              AND SB1.B1_FILIAL  = ZZJ.ZZJ_FILIAL "                                + STR_PULA
    cQuery += "                                              AND SB1.B1_COD     = ZZK.ZZK_PRODUT "                                + STR_PULA
    cQuery += "                                              AND ZZJ.ZZJ_CODIGO IS NOT NULL "                                     + STR_PULA 
    cQuery += "								     		     AND SF2.F2_DOC IS NULL "                                             + STR_PULA
    cQuery += " WHERE SC5.D_E_L_E_T_  = '' "                                                                                      + STR_PULA
    cQuery += "   AND (SC5.C5_FILIAL BETWEEN ('"+MV_PAR01+"') AND ('"+MV_PAR02+"')) "                                             + STR_PULA 
    cQuery += "GROUP BY SC5.C5_NUM,     SF2.F2_DOC,     ZZK.ZZK_PEDIDO, ZZK.ZZK_PRODUT, SC6.C6_QTDVEN,  ZZK.ZZK_QUANT, SC6.C6_LOCAL,   ZZJ.ZZJ_LOCORI, " + STR_PULA 
    cQuery += "         SD2.D2_QUANT,   SC6.C6_PRODUTO, ZZJ.ZZJ_CODIGO, SB1.B1_DESC,    ZZJ.ZZJ_LOCDES, ZZJ.ZZJ_FLAG,  ZZJ.ZZJ_FILIAL, SC6.C6_ITEM "     + STR_PULA
    cQuery += "ORDER BY ZZJ.ZZJ_FILIAL, ZZK.ZZK_PRODUT, ZZJ.ZZJ_LOCDES, SC5.C5_NUM "                                                                     + STR_PULA

    TCQuery cQuery New Alias "QRYPRO" 

    MsProcTxt("Aguarde...   Processando Registros Selecionados... ")  

    While  !(QRYPRO->(EoF()))
      nPosDad ++  
      aadd(aMatDad, {' ', ' ', ' ', ' ' , ' ' , ' ', ' ' , ' ', ' ', ' ', ' ', ' ', ' ', ' '})
      If (QRYPRO->FILIAL      == vFilial     .And.;
          QRYPRO->PRODUTO     == vProduto    .And.;
          QRYPRO->PEDIDO      == vPedido     .And.;
          QRYPRO->ITEM_PEDIDO == vItemPedido) 
         aMatDad[nPosDad][09]  = 0
      Else
         aMatDad[nPosDad][09]  = QRYPRO->QTD_PEDIDO 
      EndIf
         aMatDad[nPosDad][01]  = QRYPRO->FILIAL
         aMatDad[nPosDad][02]  = QRYPRO->PEDIDO
         aMatDad[nPosDad][03]  = QRYPRO->PALLETS
         aMatDad[nPosDad][04]  = QRYPRO->DESCRFLAG
         aMatDad[nPosDad][05]  = QRYPRO->LOCAL_ORIGEM
         aMatDad[nPosDad][06]  = QRYPRO->LOCAL_PEDIDO
         aMatDad[nPosDad][07]  = QRYPRO->PRODUTO
         aMatDad[nPosDad][08]  = QRYPRO->DESCRICAO
         aMatDad[nPosDad][10]  = QRYPRO->QTDDEP03
         aMatDad[nPosDad][11]  = QRYPRO->QTDDEP30
         aMatDad[nPosDad][12]  = QRYPRO->QTDDEPG3
         aMatDad[nPosDad][13]  = QRYPRO->QTDDEPDV 
         aMatDad[nPosDad][14]  = QRYPRO->QUANTIDADE
         vFilial               = QRYPRO->FILIAL 
         vProduto              = QRYPRO->PRODUTO 
         vPedido               = QRYPRO->PEDIDO 
         vItemPedido           = QRYPRO->ITEM_PEDIDO       
      //Pulando Registro
      QRYPRO->(DbSkip())
    EndDo                   

    //Criando o objeto que irá gerar o conteúdo do Excel
    oFWMsExcel := FWMSExcel():New()
   
    //Aba 01 
    oFWMsExcel:AddworkSheet("Separacao") //Não utilizar número junto com sinal de menos. Ex.: 1-
    //Criando a Tabela      
    ccabecalho :="Programa:- ZEXPR05                                                             Data.: "+DTOC(dDataBase)+"     AS     "+Time()+ "                          "+"RETIRADOS DO ESTOQUE E NÃO DESPACHADOS                                                               "
    //Criando Colunas
    oFWMsExcel:AddTable("Separacao",ccabecalho) // Adiciona a tabela 
    oFWMsExcel:AddColumn("Separacao",ccabecalho,"FILIAL"           ,1) 
    oFWMsExcel:AddColumn("Separacao",ccabecalho,"PEDIDO"           ,1) 
    oFWMsExcel:AddColumn("Separacao",ccabecalho,"PALLETS"          ,1) 
    oFWMsExcel:AddColumn("Separacao",ccabecalho,"DESCRFLAG"        ,1) 
    oFWMsExcel:AddColumn("Separacao",ccabecalho,"LOCAL_ORIGEM"     ,2) 
    oFWMsExcel:AddColumn("Separacao",ccabecalho,"LOCAL_PEDIDO"     ,2) 
    oFWMsExcel:AddColumn("Separacao",ccabecalho,"PRODUTO       "   ,1) 
    oFWMsExcel:AddColumn("Separacao",ccabecalho,"DESCRICAO        ",1) 
    oFWMsExcel:AddColumn("Separacao",ccabecalho,"QTDE PEDIDO"      ,2)
    oFWMsExcel:AddColumn("Separacao",ccabecalho,"SALDO DEP 03"     ,2)
    oFWMsExcel:AddColumn("Separacao",ccabecalho,"SALDO DEP 30"     ,2)
    oFWMsExcel:AddColumn("Separacao",ccabecalho,"SALDO DEP G3"     ,2)
    oFWMsExcel:AddColumn("Separacao",ccabecalho,"SALDO OUTROS DEP" ,2)
    oFWMsExcel:AddColumn("Separacao",ccabecalho,"QTDE SEPARACAO"   ,2)
    //Criando as Linhas... Enquanto não for fim da query

    MsProcTxt("Montando Arquivo em Excel...... Processando")
    For nY := 1 To Len(aMatDad)
        oFWMsExcel:AddRow("Separacao",ccabecalho,{;
        aMatDad[nY][01],;
        aMatDad[nY][02],;
        aMatDad[nY][03],;
        aMatDad[nY][04],;
        aMatDad[nY][05],;
        aMatDad[nY][06],;
        aMatDad[nY][07],;
        aMatDad[nY][08],;
        aMatDad[nY][09],;
        aMatDad[nY][10],;
        aMatDad[nY][11],;
        aMatDad[nY][12],;
        aMatDad[nY][13],;
        aMatDad[nY][14];
        }) 
    Next

    //Ativando o arquivo e gerando o xml
    oFWMsExcel:Activate()
    MsgRun("Processando...","Aguarde Gerando arquivo em Excel...",{|| oFWMsExcel:GetXMLFile(cArquivo) } )

    //Abrindo o excel e abrindo o arquivo xml
    oExcel := MsExcel():New()           //Abre uma nova conexão com Excel
    oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
    oExcel:SetVisible(.T.)              //Visualiza a planilha
    oExcel:Destroy()                    //Encerra o processo do gerenciador de tarefas
     
    QRYPRO->(DbCloseArea())
    RestArea(aArea)

Return

/*
//    NÃO TESTAR O DEPOSITO ----------------------------------------------------------------------------
//          If QRYPRO->LOCALDEST = '03'
             cQuery1 := ""
             cQuery1 := "SELECT SB2.B2_QATU AS B2_QATU03 " + STR_PULA
             cQuery1 += "  FROM SB2010 SB2 " + STR_PULA
             cQuery1 += " WHERE SB2.D_E_L_E_T_ <> '*' AND SB2.B2_FILIAL = '"+QRYPRO->FILIAL+"' AND " + STR_PULA
             cQuery1 += "       SB2.B2_COD = '"+QRYPRO->PRODUTO+"' AND SB2.B2_LOCAL = '03' " + STR_PULA 
             TCQuery cQuery1 New Alias "QSB203"
             If QSB203->B2_QATU03 == 0
               aMatDad[nPosDad][6] = vValor
             Else
               aMatDad[nPosDad][6] = QSB203->B2_QATU03  
             EndIf 
             DbSelectArea("QSB203")
             DbCloseArea()
//          EndIf
//    NÃO TESTAR O DEPOSITO ----------------------------------------------------------------------------
//          If QRYPRO->LOCALDEST = 'G3'
             cQuery1 := ""
             cQuery1 := "SELECT SB2.B2_QATU AS B2_QATUG3" + STR_PULA
             cQuery1 += "  FROM SB2010 SB2 " + STR_PULA
             cQuery1 += " WHERE SB2.D_E_L_E_T_ <> '*' AND SB2.B2_FILIAL = '"+QRYPRO->FILIAL+"' AND " + STR_PULA
             cQuery1 += "       SB2.B2_COD = '"+QRYPRO->PRODUTO+"' AND SB2.B2_LOCAL = 'G3' " + STR_PULA 
             TCQuery cQuery1 New Alias "QSB2G3"
             If QSB2G3->B2_QATUG3 == 0
                aMatDad[nPosDad][7] = vValor
             ELse
                aMatDad[nPosDad][7] = QSB2G3->B2_QATUG3   
             EndIf                
             DbSelectArea("QSB2G3")
             DbCloseArea()
//          EndIf
//    NÃO TESTAR O DEPOSITO ----------------------------------------------------------------------------
//          If QRYPRO->LOCALDEST = '30'
             cQuery1 := ""
             cQuery1 := "SELECT SB2.B2_QATU AS B2_QATU30" + STR_PULA
             cQuery1 += "  FROM SB2010 SB2 " + STR_PULA
             cQuery1 += " WHERE SB2.D_E_L_E_T_ <> '*' AND SB2.B2_FILIAL = '"+QRYPRO->FILIAL+"' AND " + STR_PULA
             cQuery1 += "       SB2.B2_COD = '"+QRYPRO->PRODUTO+"' AND SB2.B2_LOCAL = '30' " + STR_PULA 
             TCQuery cQuery1 New Alias "QSB230"
             If QSB230->B2_QATU30 == 0
                aMatDad[nPosDad][8] = vValor
             Else
                aMatDad[nPosDad][8] = QSB230->B2_QATU30                   
             EndIf
             DbSelectArea("QSB230")
             DbCloseArea()


*/
