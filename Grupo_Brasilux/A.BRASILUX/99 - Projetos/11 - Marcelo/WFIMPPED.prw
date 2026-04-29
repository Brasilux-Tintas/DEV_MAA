#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH" 

/*
	+---------------------------------------------------------------------------+
	+ Funcao    | WFDespa       | Função de Workflow					   	    |
	+-----------+----------+-------+-----------------------+------+-------------+ 
	+ Autor 	| Marcelo Paiva						                            | 
	+-----------+----------+-------+-----------------------+------+-------------+
	+ Data 		| 15/12/17   													|
	+-----------+----------+-------+-----------------------+------+-------------+
	|                                                                           |
    | Descricao:	Função de WorkFlow para envio de mensagem por email	 	  	|
    |               dos pedidos que não sairam na impressao					  	|
	+-----------+------------------------------------------+------+-------------+ 
	| USO  AP        				    									   	|                                      						    
	+---------------------------------------------------------------------------+  

*/
User Function WFIMPPED()
 
    Local cPara    	:= "" //TRIM(GETMV("ZP_PAR0076")) //"vendas@brasilux.com.br"
    Local cAssunto  := "PEDIDOS QUE NÃO SAIRAM NA IMPRESSÃO"
    Local cMsg		:= ""
    
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010101" 
    cPara    		:= TRIM(GETMV("ZP_PAR0076")) 

    /**	Monta a query para buscar os dados	**/
	cQuery := "SELECT C5_NUM, C5_CLIENTE, A1_NOME, C5_TRANSP, SUBSTRING(ZZB_DATLOG,7,2)+'/'+SUBSTRING(ZZB_DATLOG,5,2)+'/'+SUBSTRING(ZZB_DATLOG,1,4) AS 'APROVACAO', DATEDIFF(DAY,ZZB_DATLOG,GETDATE()) AS 'ATRASO'
	cQuery += "FROM  "+RetSqlName("SC5")+" SC5 WITH (NOLOCK)
	cQuery += "LEFT OUTER JOIN  "+RetSqlName("SA1")+"  SA1 WITH (NOLOCK) ON A1_FILIAL = '' AND A1_COD = C5_CLIENTE AND SA1.D_E_L_E_T_ =''
	cQuery += "LEFT OUTER JOIN  "+RetSqlName("ZZB")+"  ZZB WITH (NOLOCK) ON ZZB_FILIAL = C5_FILIAL AND ZZB_PEDIDO = C5_NUM AND ZZB.D_E_L_E_T_ =''
	cQuery += "WHERE C5_FLAG ='N' AND C5_NOTA ='' AND C5_APROVA<>'1' AND SC5.D_E_L_E_T_ ='' AND C5_LIBDIR ='T' AND C5_FILIAL ='010101' AND ZZB_IDLOG ='LDI' AND DATEDIFF(DAY,ZZB_DATLOG,GETDATE())>0
	cQuery += "ORDER BY DATEDIFF(DAY,ZZB_DATLOG,GETDATE()) DESC, C5_TRANSP, C5_NUM"                                                                        	
    
	TcQuery cQuery ALIAS "TCQ" NEW   
	DbSelectArea("TCQ")        
   
	/**  Monta o script HTML para ser enviado por email 	**/        
    cMsg:="<html>"
	cMsg+="<body>"
	cMsg+="<table width='1400' height='92' border='0' font size='1'>"
	cMsg+="<tr><th height='30'  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>PEDIDO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>CLIENTE</th>" 
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>RAZAO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>TRANSPORTADORA</th>" 
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>DATA APROVACAO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>DIAS ATRASO</th>"
	cMsg+="</tr>"    
	        
   	If eof()
   		 DbSelectArea("TCQ")
   		 DbCloseArea() 
   		 Return()
   	EndIf
   	dbselectarea("TCQ")
   	While !eof()
		cMsg+="<tr>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim(TCQ->C5_NUM)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim(TCQ->C5_CLIENTE)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim(TCQ->A1_NOME)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim(TCQ->C5_TRANSP)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim(TCQ->APROVACAO)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+transform(TCQ->ATRASO,'@E 99999')+"</td>"
		cMsg+="</tr>"
	    dbselectarea("TCQ")	 
	    dbskip() 
  	End
	cMsg+="</table>"
	cMsg+="<footer>"
	cMsg+="<p height='50' width='1400' style='text-align:center; color: rgb(255, 255, 255); background-color:rgb(0, 0, 0);'  scope='col'>WFIMPPED</p>"
	cMsg+="</footer>"
  	cMsg+="</body>"
  	cMsg+="</html>" 

  	DbCloseArea() 

    U_EnvMail(cAssunto, cMsg, cPara)

RESET ENVIRONMENT
