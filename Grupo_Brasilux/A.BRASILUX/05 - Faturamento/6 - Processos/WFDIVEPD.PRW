#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH" 

/*
	+---------------------------------------------------------------------------+
	+ Funcao    | WFDIVEPD         | Função de Workflow					   	    |
	+-----------+----------+-------+-----------------------+------+-------------+ 
	+ Autor 	| André Maester 					                            | 
	+-----------+----------+-------+-----------------------+------+-------------+
	+ Data 		| 19/08/20   													|
	+-----------+----------+-------+-----------------------+------+-------------+
	|                                                                           |
    | Descricao: Função de WorkFlow para envio de mensagem por email	 	  	|
    |            dos pedidos que tem divergência no almoxarifado de faturamento |
	+-----------+------------------------------------------+------+-------------+ 
	| USO  AP        				    									   	|                                      						    
	+---------------------------------------------------------------------------+  
*/         
User Function WFDIVEPD()
   
    Local cPara    	:= "expedicao@brasilux.com.br,eliana@brasilux.com.br,estoque@brasilux.com.br"
    Local cAssunto  := "Pedidos com divergência em almoxarifados de faturamento"
    Local cMsg		:= ""
    Local cQuery    := ""

    u_zcfga01( 'WFDIVEPD' ) //LGS#2021119 - Gravação de log de utilização da rotina    

    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010101" 

    cQuery := ""
    cQuery += " SELECT C5_NUM AS 'PEDIDO', C5_CLIENTE AS 'CLIENTE', A1_NOME AS 'NOME', SUBSTRING(C5_EMISSAO,7,2)+'/'+SUBSTRING(C5_EMISSAO,5,2)+'/'+SUBSTRING(C5_EMISSAO,1,4) AS 'EMISSAO', " 
    cQuery += " C5_TRANSP AS 'TRANSPORTADORA', SUBSTRING(C6_LOCAL,1,1) AS LOCALC6, SUBSTRING(C9_LOCAL,1,1) AS LOCALC9 "
    cQuery += " FROM "+RetSqlName("SC5")+" SC5 WITH(NOLOCK) " 
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH(NOLOCK) ON C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM AND SC6.D_E_L_E_T_ ='' "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SC9")+" SC9 WITH(NOLOCK) ON C9_FILIAL = C6_FILIAL AND C9_PEDIDO = C6_NUM AND C6_PRODUTO = C9_PRODUTO AND C9_ITEM = C6_ITEM AND SC9.D_E_L_E_T_ ='' "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH(NOLOCK) ON A1_FILIAL = A1_FILIAL AND C5_CLIENTE = A1_COD AND SA1.D_E_L_E_T_ ='' "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON B1_FILIAL = C6_FILIAL AND B1_COD = C6_PRODUTO AND SB1.D_E_L_E_T_ ='' "
    cQuery += " WHERE SC5.D_E_L_E_T_ ='' "
    cQuery += " AND C5_FILIAL ='"+xFilial("SC5")+"'"
    cQuery += " AND C5_APROVA ='1' "
    cQuery += " AND ((C5_TRANSP NOT IN('00700','00800','00573') AND (SUBSTRING(C6_LOCAL,1,1) <>'0' OR SUBSTRING(C9_LOCAL,1,1) <>'0')) "
    cQuery += " OR (C5_TRANSP IN('00700','00800','00573') AND (SUBSTRING(C6_LOCAL,1,1) <>'G' OR SUBSTRING(C9_LOCAL,1,1) <>'G'))) "
    cQuery += " AND C5_NOTA ='' "
    cQuery += " AND B1_TIPO IN('MP','PI','PA') "
    cQuery += " GROUP BY C5_NUM, C5_CLIENTE, C5_TRANSP, SUBSTRING(C6_LOCAL,1,1), SUBSTRING(C9_LOCAL,1,1), C5_EMISSAO, A1_NOME "

	TcQuery cQuery ALIAS "TM1" NEW   
	DbSelectArea("TM1")        

   	If TM1->(eof()) //se o arquivo estiver vazio, sai da rotina
   		 TM1->(DbCloseArea()) 
   		 Return()
   	EndIf		
    
	/**		Monta o script HTML para ser enviado por email 	**/        
	cMsg:="<html>"
	cMsg+="<body>"
	cMsg+="<table width='1400' height='92' border='0' font-size='1'>"
	cMsg+="<tr><th height='30'  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>PEDIDO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>CLIENTE</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>NOME</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>EMISSAO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>TRANSPORTADORA</th>"
	cMsg+="</tr>"    
	        //#FFD7D7   #ECFFEC
   	DbSelectArea("TM1")
   	While TM1->(!eof())

			cMsg+="<tr>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->PEDIDO+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->CLIENTE+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->NOME+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim(TM1->EMISSAO)+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->TRANSPORTADORA+"</td>"
			cMsg+="</tr>"
	    
	    TM1->(dbSkip())
  	EndDo
  
	cMsg+="</table>"
	cMsg+="<footer>"
	cMsg+="<p height='50' width='1400' style='text-align:center; color: rgb(255, 255, 255); background-color:rgb(0, 0, 0);'  scope='col'>WFDIVEPD</p>"
	cMsg+="</footer>"
  	cMsg+="</body>"
  	cMsg+="</html>" 

    DbSelectArea("TM1")
    DbCloseArea() 
    
    U_EnvMail(cAssunto, cMsg, cPara)
  	
  	RESET ENVIRONMENT 

Return
