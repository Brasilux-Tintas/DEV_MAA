#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH" 
 
/*
	+---------------------------------------------------------------------------+
	+ Funcao    | WFDespa       | Função de Workflow					   	    |
	+-----------+----------+-------+-----------------------+------+-------------+ 
	+ Autor 	| Marcelo Paiva					                            | 
	+-----------+----------+-------+-----------------------+------+-------------+
	+ Data 		| 23/06/16   													|
	+-----------+----------+-------+-----------------------+------+-------------+
	|                                                                           |
    | Descricao:	Função de WorkFlow para envio de mensagem por email	 	  	|
    |               dos pedidos que estão endereçados e deletados ou ainda dos  |
    |               pedidos que foram faturados e ainda não despachados a 4 dias| 
	+-----------+------------------------------------------+------+-------------+ 
	| USO  AP        				    									   	|                                      						    
	+---------------------------------------------------------------------------+  

*/         
User Function OPATRASO()
   
    Local cPara    	:= "wfopatraso@brasilux.com.br"
    Local cAssunto  := "Ops emitidas e não iniciadas a mais de 7 dias"
    Local cMsg		:= ""

    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010101" 
     

     /**	Monta a query para buscar os dados	**/   
	cTmp := U_NovoCursor()    
    cQuery := ""
    
    cQuery += " SELECT C2_OP,C2_LOTE, C2_PRODUTO, B1_DESC, "
    cQuery += " CASE WHEN C2_LOCAL IN('02','R1') THEN 'FAB1' ELSE 'FAB2' END AS C2_LOCAL, C2_QUANT, SUBSTRING(C2_EMISSAO,7,2)+'/'+SUBSTRING(C2_EMISSAO,5,2)+'/'+SUBSTRING(C2_EMISSAO,1,4) AS 'EMISSAO', DATEDIFF(D,C2_EMISSAO,GETDATE()) AS 'DIAS' "
    cQuery += " FROM "+RetSqlName("SC2")+" SC2 WITH(NOLOCK) "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON B1_FILIAL = C2_FILIAL AND B1_COD = C2_PRODUTO AND SB1.D_E_L_E_T_ ='' "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("ZZA")+" ZZA WITH(NOLOCK) ON ZZA_FILIAL = C2_FILIAL AND ZZA_ORDEM = C2_OP AND C2_PRODUTO = ZZA_PRODUT AND ZZA.D_E_L_E_T_ ='' "
    cQuery += " WHERE C2_FILIAL ='"+XFilial("SC2")+"' AND SC2.D_E_L_E_T_ ='' AND C2_DATRF ='' AND B1_TIPO ='PI' AND ZZA_ORDEM IS NULL AND DATEDIFF(D,C2_EMISSAO,GETDATE()) >7 "
    cQuery += " ORDER BY C2_LOCAL, C2_OP "

	TcQuery cQuery ALIAS (cTmp) NEW   
	DbSelectArea(cTmp)        
   
	/**		Monta o script HTML para ser enviado por email 	**/        
	cMsg:="<html>"
	cMsg+="<body>"
	cMsg+="<table width='1400' height='92' border='0' font size='1'>"
	cMsg+="<tr><th height='30'  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>NUM. OP</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>LOTE</th>" 
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>PRODUTO</th>" 
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>DESC</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>LOCAL</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>QUANT</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>EMISSAO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>DIAS</th>"
	cMsg+="</tr>"    
	        //#FFD7D7   #ECFFEC
   	If (cTmp)->(eof()) //se o arquivo estiver vazio, sai da rotina
   		 (cTmp)->(DbCloseArea()) 
   		 Return()
   	EndIf		
   	dbselectarea(cTmp)
   	While !eof()
		cMsg+="<tr>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->C2_OP)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->C2_LOTE)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->C2_PRODUTO)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->B1_DESC)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->C2_LOCAL)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TRANSFORM((cTmp)->C2_QUANT,'@E 99999')+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->EMISSAO)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TRANSFORM((cTmp)->DIAS,'@E 999')+"</td>"
		cMsg+="</tr>"
  
	    (cTmp)->(dbSkip())
  	End
  
  
	cMsg+="</table>"
  	cMsg+="</body>"
  	cMsg+="</html>" 
   
  	(cTmp)->(DbCloseArea()) 
    
    U_EnvMail(cAssunto, cMsg, cPara)
  	
  	RESET ENVIRONMENT