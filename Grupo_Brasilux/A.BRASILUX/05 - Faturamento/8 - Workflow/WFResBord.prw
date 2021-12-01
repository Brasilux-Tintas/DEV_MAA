#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH" 

/*
	+---------------------------------------------------------------------------+
	+ Funcao    | WFResBord        | Função de Workflow					   	    |
	+-----------+----------+-------+-----------------------+------+-------------+ 
	+ Autor 	| André Maester						                            | 
	+-----------+----------+-------+-----------------------+------+-------------+
	+ Data 		| 26/02/16   													|
	+-----------+----------+-------+-----------------------+------+-------------+
	|                                                                           |
    | Descricao:	Função de WorkFlow para envio de mensagem por email	 	  	|
    |               do resumo do bordero de pedidos, logo após sua criação      |
	+-----------+------------------------------------------+------+-------------+ 
	| USO  AP        				    									   	|                                      						    
	+---------------------------------------------------------------------------+  

*/         
User Function WFResBord(cNumBor)
   
    Local cPara    	:= "eliana@brasilux.com.br"
    Local cAssunto  := "Resumo do Bordero de Pedidos "
    Local cMsg		:= ""
    Local cQuery    := ""
    Local cQuery1   := ""
    Local cQuery2   := ""    
    Local cQuery3   := ""
    Local cTmp      := ""
    Local cTmp1     := ""
    Local cQDet     := ""
    //CNUMBOR :='012856'
     u_zcfga01( 'WFRESBORD' ) //LGS#2021119 - Gravação de log de utilização da rotina
    //PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010101" 
    //Chamado: 007146 - Detalhar os itens do Resumo do Bordero de Pedidos que é enviado por e-mail. 25/05/17
     /**	Monta a query para buscar os dados	**/   
	cTmp    := U_NovoCursor()    
	cTmp1   := U_NovoCursor()   
	

    cQuery1 += " WITH TMP AS( "
    
    cQuery  += " SELECT ZF_CODIGO, C6_PRODUTO, B1_DESC, SUM(B1_CONV * C6_QTDVEN) AS 'CONV', COUNT(C6_PRODUTO) AS 'QTDE', SUM(C6_VOLITEM) AS 'VOLUME', "
    cQuery  += " CASE WHEN B1_ESTOQUE ='S' THEN 'SIM' ELSE 'NÃO' END AS B1_ESTOQUE, "
    cQuery  += " CASE WHEN SUM(B1_CONV * C6_QTDVEN) <= 40 AND B1_ESTOQUE <>'S' THEN 'MENOR 40 - ESP' ELSE CASE WHEN SUM(B1_CONV * C6_QTDVEN) > 40 AND B1_ESTOQUE <> 'S' THEN 'MAIOR 40 - ESP' ELSE 'ESTOQUE' END END AS 'TIPO', "    
    cQuery  += " CASE WHEN ZF_TIPOBOR = '1' THEN 'AGLUTINADO' WHEN ZF_TIPOBOR = '2' THEN 'DEPÓSITO SP' "
    cQuery  += " WHEN ZF_TIPOBOR = '3' THEN 'REGIÃO/RETIRA' WHEN ZF_TIPOBOR = '4' THEN 'EXPORTAÇÃO' "
    cQuery  += " WHEN ZF_TIPOBOR = '5' THEN 'CARGA FECHADA' WHEN ZF_TIPOBOR = '6' THEN 'AMOSTRAS' "
    cQuery  += " WHEN ZF_TIPOBOR = '7' THEN 'VOL. QUEBRADO' WHEN ZF_TIPOBOR = '8' THEN 'CARGA-MATRIZ' ELSE 'NAO CLASSIF' END AS 'TIPOBOR' "
    cQuery  += " FROM "+RetSqlName("SZF")+" SZF WITH (NOLOCK) " 
    cQuery  += " LEFT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH (NOLOCK) ON ZG_FILIAL = ZF_FILIAL AND ZG_CODIGO = ZF_CODIGO AND SZG.D_E_L_E_T_ ='' "
    cQuery  += " LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON ZG_FILIAL = C6_FILIAL AND SUBSTRING(ZG_PEDIDO,3,6)= C6_NUM AND SC6.D_E_L_E_T_ ='' "
    cQuery  += " LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON F4_FILIAL = '"+XFilial("SF4")+"' AND C6_TES = F4_CODIGO AND SF4.D_E_L_E_T_ ='' "
    cQuery  += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = C6_FILIAL AND B1_COD = C6_PRODUTO AND SB1.D_E_L_E_T_ ='' "
    cQuery  += " WHERE (SZF.D_E_L_E_T_ ='') "
    cQuery  += " AND (ZF_FILIAL ='"+xFilial("SZF")+"') "
    cQuery  += " AND (ZF_CODIGO ='"+cNumBor+"') "
    cQuery  += " AND F4_ESTOQUE <>'N' "
    cQuery  += " AND B1_GRUPO BETWEEN('PA00') AND ('PA99') "
    cQuery  += " GROUP BY ZF_CODIGO, C6_PRODUTO, B1_DESC, B1_ESTOQUE, ZF_TIPOBOR 
    cQuery2 += " ORDER BY TIPO DESC, QTDE DESC, SUBSTRING(C6_PRODUTO,4,2), C6_PRODUTO "
    
    cQuery3 += " ) "
    cQuery3 += " SELECT TMP.ZF_CODIGO,TMP.TIPOBOR,  TMP.TIPO, SUM(TMP.QTDE) AS 'QTDEITENS', ROUND(SUM(TMP.CONV),2) AS 'LITROKG', SUM(VOLUME) AS 'VOLTOTAL' " 
    cQuery3 += " FROM TMP  "
    cQuery3 += " GROUP BY TMP.ZF_CODIGO, TMP.TIPO, TMP.TIPOBOR  "
    cQuery3 += " ORDER BY TMP.ZF_CODIGO, TMP.TIPOBOR,  TMP.TIPO "
    
    cQDet  := cQuery + cQuery2
    cQuery := cQuery1 + cQuery + cQuery3 
	
	TcQuery cQuery ALIAS (cTmp) NEW   
	DbSelectArea(cTmp)        
    
            
	/**		Monta o script HTML para ser enviado por email 	**/        
	cMsg:="<html>"
	cMsg+="<body>"
	cMsg+="<table width='1400' height='92' border='0'>"
	cMsg+="<tr><th height='30'  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>BORDERO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>TIPO BORDERO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>CATEGORIA</th>" 
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>QTD ITENS</th>" 
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>TOTAL (LT/KG)</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>VOL. TOTAL</th>"
	cMsg+="</tr>"    
	        //#FFD7D7   #ECFFEC
   	If (cTmp)->(eof()) //se o arquivo estiver vazio, sai da rotina
   		 Return()
   	EndIf		
   	DbSelectarea(cTmp)
   	While !eof()  
		cMsg+="<tr>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->ZF_CODIGO)+"</td>"    
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->TIPOBOR)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->TIPO)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+STR((cTmp)->QTDEITENS)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TRANSFORM((cTmp)->LITROKG,'@E 999,999,999.99')+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TRANSFORM((cTmp)->VOLTOTAL,'@E 999,999,999')+"</td>"
		cMsg+="</tr>"
  
	    (cTmp)->(dbSkip())
  	End
  
  
	cMsg+="</table>"
  	(cTmp)->(DbCloseArea())  
  	
	TcQuery cQDet ALIAS (cTmp1) NEW   
	DbSelectArea(cTmp1) 

	cMsg+="<table width='1400' height='92' border='0'>"
	cMsg+="<tr><th height='30'  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>PRODUTO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>DESCRIÇÃO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>VOLUME</th>" 
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>QTDE</th>" 
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>TIPO</th>"
	cMsg+="</tr>"    
	        //#FFD7D7   #ECFFEC
   	If (cTmp1)->(eof()) //se o arquivo estiver vazio, sai da rotina
   		 Return()
   	EndIf		
   	DbSelectarea(cTmp1)
   	While !eof()  
		If (cTmp1)->B1_ESTOQUE <> "SIM"
			cMsg+="<tr>"

			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp1)->C6_PRODUTO)+"</td>"    
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp1)->B1_DESC)+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TRANSFORM((cTmp1)->CONV,'@E 999,999,999.99')+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+STR((cTmp)->QTDE)+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp1)->TIPO)+"</td>"
			cMsg+="</tr>"
    	Endif

	    (cTmp1)->(dbSkip())
  	End

  	(cTmp)->(DbCloseArea())  
  	cMsg+="</body>"
  	cMsg+="</html>" 	     	
    
    U_EnvMail(cAssunto, cMsg, cPara)
    
	//RESET ENVIRONMENT
  	
Return
