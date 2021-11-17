#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH" 

/*
	+---------------------------------------------------------------------------+
	+ Funcao    | WFDespa       | Função de Workflow					   	    |
	+-----------+----------+-------+-----------------------+------+-------------+ 
	+ Autor 	| André Maester						                            | 
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
User Function WFDespa()
   
    Local cPara    	:= "deposito@brasilux.com.br;coletas@brasilux.com.br;danilo@brasilux.com.br;expedicao@brasilux.com.br;vendas@brasilux.com.br"
    Local cAssunto  := "Pedidos faturados com 4 ou mais dias sem coleta no Depósito"
    Local cMsg		:= ""

    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010101" 
     

     /**	Monta a query para buscar os dados	**/   
	cTmp := U_NovoCursor()    
    cQuery := ""
    
    cQuery += " SELECT C5_NUM, SC5.D_E_L_E_T_ AS 'DELETADO', ISNULL(F2_DOC,'N.FATURADO') AS 'F2_DOC', ISNULL(F2_SERIE,' ') AS 'F2_SERIE', A1_NOME, C5_VOLUME1 AS 'VOL', "
    cQuery += " ISNULL(SUBSTRING(F2_EMISSAO,7,2)+'/'+SUBSTRING(F2_EMISSAO,5,2)+'/'+SUBSTRING(F2_EMISSAO,1,4),'        ') AS EMISSAO, DATEDIFF(D,F2_EMISSAO,GETDATE()) AS 'DIAS', ISNULL(A4_NOME,'') AS 'TRANSPORTE' "
    cQuery += " FROM "+RetSqlName("ZZT")+" ZZT WITH(NOLOCK) "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("ZZU")+" ZZU WITH(NOLOCK) ON ZZT_FILIAL = ZZU_FILIAL AND ZZT_CODIGO = ZZU_ENDERE AND ZZU.D_E_L_E_T_ ='' "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("ZZ0")+" ZZ0 WITH(NOLOCK) ON ZZU_FILIAL = ZZ0_FILIAL AND ZZU_PEDIDO = ZZ0_PEDIDO AND ZZ0.D_E_L_E_T_ ='' "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH(NOLOCK) ON F2_FILIAL = ZZU_FILIAL AND F2_PEDIDO = ZZU_PEDIDO AND SF2.D_E_L_E_T_ ='' "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH(NOLOCK) ON A1_FILIAL = A1_FILIAL AND ZZU_CODCLI = A1_COD AND SA1.D_E_L_E_T_ ='' "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH(NOLOCK) ON C5_FILIAL = ZZU_FILIAL  AND C5_NUM = ZZU_PEDIDO "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SA4")+" SA4 WITH(NOLOCK) ON A4_FILIAL = A4_FILIAL AND F2_REDESP = A4_COD AND SA4.D_E_L_E_T_ ='' "
    cQuery += " WHERE (ZZT.D_E_L_E_T_ ='') AND (ZZT_FILIAL ='"+XFilial("ZZT")+"')"                                                          
    cQuery += " AND (ZZU_PEDIDO  IS NOT NULL) AND ((F2_EMISSAO <> '' AND DATEDIFF(D,F2_EMISSAO,GETDATE()) >=4) OR SC5.D_E_L_E_T_ <>'') "
    cQuery += " GROUP BY C5_NUM, SC5.D_E_L_E_T_,F2_DOC, F2_SERIE, A1_NOME, C5_VOLUME1,F2_EMISSAO, A4_NOME "
    cQuery += " ORDER BY F2_EMISSAO  "

	TcQuery cQuery ALIAS (cTmp) NEW   
	DbSelectArea(cTmp)        
   
	/**		Monta o script HTML para ser enviado por email 	**/        
	cMsg:="<html>"
	cMsg+="<body>"
	cMsg+="<table width='1400' height='92' border='0' font size='1'>"
	cMsg+="<tr><th height='30'  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>PEDIDO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>DEL</th>" 
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>NOTA</th>" 
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>SERIE</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>CLIENTE</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>VOL.</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>EMISSÃO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>DIAS</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>RESDESPACHO</th>"
	cMsg+="</tr>"    
	        //#FFD7D7   #ECFFEC
   	If (cTmp)->(eof()) //se o arquivo estiver vazio, sai da rotina
   		 (cTmp)->(DbCloseArea()) 
   		 Return()
   	EndIf		
   	dbselectarea(cTmp)
   	While !eof()
		cMsg+="<tr>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->C5_NUM)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->DELETADO)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->F2_DOC)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->F2_SERIE)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->A1_NOME)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TRANSFORM((cTmp)->VOL,'@E 99999')+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->EMISSAO)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TRANSFORM((cTmp)->DIAS,'@E 999')+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->TRANSPORTE)+"</td>"
		cMsg+="</tr>"
  
	    (cTmp)->(dbSkip())
  	End
  
  
	cMsg+="</table>"
  	cMsg+="</body>"
  	cMsg+="</html>" 
   
  	(cTmp)->(DbCloseArea()) 
    
    U_EnvMail(cAssunto, cMsg, cPara)
  	
  	RESET ENVIRONMENT