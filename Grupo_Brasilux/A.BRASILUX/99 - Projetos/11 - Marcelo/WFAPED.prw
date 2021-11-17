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
User Function WFAPED()

    Local cPara    	:= "analiseproduto@brasilux.com.br"
    Local cAssunto  := "Amostra de Analise do Produto Pendente a mais de 15 dias "
    Local cMsg		:= ""

    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010101" 
     

     /**	Monta a query para buscar os dados	**/   
	cTmp := U_NovoCursor()    
    cQuery := ""                                                                             	
    
    cQuery += "SELECT Z02_COD,ZH_NOME,Z02_PROD,B1_DESC,SUBSTRING(Z02_DATA,7,2)+'/'+SUBSTRING(Z02_DATA,5,2)+'/'+SUBSTRING(Z02_DATA,1,4) AS DT "
    cQuery += "FROM "+RetSqlName("Z02")+" Z02 (NOLOCK) "
    cQuery += "LEFT OUTER JOIN "+RetSqlName("SZH")+" SZH(NOLOCK) ON ZH_CODIGO = Z02_GEREN AND SZH.D_E_L_E_T_ <> '*' AND (ZH_FILIAL = '"+XFilial("SZH")+"')"
    cQuery += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1(NOLOCK) ON B1_COD = Z02_PROD AND SB1.D_E_L_E_T_ <> '*' AND (B1_FILIAL = '"+XFilial("SB1")+"')
    cQuery += "WHERE Z02_TIPO = 1 AND Z02.D_E_L_E_T_ <> '*' AND Z02_APROV = '' AND DATEDIFF(D,Z02_DATA,GETDATE()) >15 AND SUBSTRING(Z02_DATA,1,4) >= '2017' "
    cQuery += "ORDER BY Z02_GEREN "

	TcQuery cQuery ALIAS (cTmp) NEW   
	DbSelectArea(cTmp)        
   
	/**		Monta o script HTML para ser enviado por email 	**/        
	cMsg:="<html>"
	cMsg+="<body>"
	cMsg+="<table width='1400' height='92' border='0' font size='1'>"
	cMsg+="<tr><th height='30'  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>CODIGO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>RESPONSAVEL</th>" 
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>COD. PRODUTO</th>" 
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>DESCRICAO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>DATA</th>"
	cMsg+="</tr>"    
	        //#FFD7D7   #ECFFEC
   	If (cTmp)->(eof()) //se o arquivo estiver vazio, sai da rotina
   		 (cTmp)->(DbCloseArea()) 
   		 Return()
   	EndIf
   	dbselectarea(cTmp)
   	While !eof()
		cMsg+="<tr>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->Z02_COD)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->ZH_NOME)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->Z02_PROD)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->B1_DESC)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->DT)+"</td>"
		cMsg+="</tr>"
	    (cTmp)->(dbSkip())
  	End
	cMsg+="</table>"
	cMsg+="<footer>"
	cMsg+="<p height='50' width='1400' style='text-align:center; color: rgb(255, 255, 255); background-color:rgb(0, 0, 0);'  scope='col'>WFAPED</p>"
	cMsg+="</footer>"
  	cMsg+="</body>"
  	cMsg+="</html>" 

  	(cTmp)->(DbCloseArea()) 

    U_EnvMail(cAssunto, cMsg, cPara)

  	RESET ENVIRONMENT