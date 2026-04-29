#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH" 

/*
	+---------------------------------------------------------------------------+
	+ Funcao    | WFPNTRAN         | Função de Workflow					   	    |
	+-----------+----------+-------+-----------------------+------+-------------+ 
	+ Autor 	| André Maester 					                            | 
	+-----------+----------+-------+-----------------------+------+-------------+
	+ Data 		| 28/08/18   													|
	+-----------+----------+-------+-----------------------+------+-------------+
	|                                                                           |
    | Descricao:	Função de WorkFlow para envio de mensagem por email	 	  	|
    |               dos Pallets não transferidos entre armazens na Matriz		|
	+-----------+------------------------------------------+------+-------------+ 
	| USO  AP        				    									   	|                                      						    
	+---------------------------------------------------------------------------+  
*/         
User Function WFPNTRAN()
    
    Local cPara    	:= "" //TRIM(GETMV("ZP_PAR0070")) //"mirinho@brasilux.com.br,edevilson@brasilux.com.br,faturamento@brasilux.com.br,kiko@brasilux.com.br,marcosazevedo@brasilux.com.br,estoque@brasilux.com.br"
    Local cAssunto  := "Pallets montados na Fabrica 2 e não transferidos"
    Local cMsg		:= ""
    Local cQuery    := ""
    //Local TM1

    
    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010101" 
	cPara  := TRIM(GETMV("ZP_PAR0070"))
    cQuery := ""
    cQuery += " SELECT ZZJ_CODIGO AS 'PALLET', SUBSTRING(ZZJ_HINI,1,2)+':'+SUBSTRING(ZZJ_HINI,3,2) AS 'HORAINICIO', ZZJ_LOCALI AS 'BIPADOEM', "
    cQuery += " CASE WHEN ZZJ_FLAG ='5' THEN 'FATURADO' ELSE 'NÃO FATURADO' END AS 'STATUS', ZH_NOME AS 'MONTADOPOR', " 
    cQuery += " CASE WHEN ZZJ_TIPBOR ='2' THEN 'DEPÓSITO SP' ELSE " 
    cQuery += " CASE WHEN ZZJ_TIPBOR ='3' THEN 'REGIÃO ' ELSE "
    cQuery += " CASE WHEN ZZJ_TIPBOR ='4' THEN 'EXPORTAÇÃO' ELSE "
    cQuery += " CASE WHEN ZZJ_TIPBOR ='5' THEN 'CARGA FECHADA' END END END END AS 'TIPOBORD' " 
    cQuery += " FROM "+RetSqlName("ZZJ")+" ZZJ WITH(NOLOCK) "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SZH")+" SZH WITH(NOLOCK) ON ZH_FILIAL = ZH_FILIAL AND ZH_CODIGO = ZZJ_USER AND SZH.D_E_L_E_T_ ='' "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH(NOLOCK) ON ZZK_FILIAL = ZZJ_FILIAL AND ZZK_CODIGO = ZZJ_CODIGO AND ZZK.D_E_L_E_T_ ='' "
    cQuery += " WHERE ZZJ.D_E_L_E_T_ ='' AND ZZJ_FILIAL ='"+XFilial("ZZJ")+"'"
    cQuery += " AND ZZJ_BORDER <>'' AND ZZJ_LOCALI ='FAB2' AND ZZJ_LOCORI ='' AND ZZJ_DTINI >'20200501' "
    cQuery += " GROUP BY ZZJ_CODIGO, ZZJ_HINI, ZZJ_FLAG, ZH_NOME,ZZJ_BORDER, ZZJ_LOCALI, ZZJ_TIPBOR, ZZJ.R_E_C_N_O_ " 
    cQuery += " HAVING COUNT(ZZK_PRODUT) > 1 "
    cQuery += " ORDER BY ZZJ_LOCALI, ZZJ.R_E_C_N_O_ " 


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
	cMsg+="<tr><th height='30'  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>PALLET</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>HORA INICIO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>BIPADO EM</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>TIPO BORD</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>STATUS</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>MONTADO POR</th>"
	

	cMsg+="</tr>"    
	        //#FFD7D7   #ECFFEC
   	DbSelectArea("TM1")
   	While TM1->(!eof())
			
				cMsg+="<tr>"
				cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->PALLET+"</td>"
				cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->HORAINICIO+"</td>"
				cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->BIPADOEM+"</td>"
				cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->TIPOBORD	+"</td>" 
				cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->STATUS+"</td>"		
				cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->MONTADOPOR+"</td>"
				cMsg+="</tr>"
	    
	    TM1->(dbSkip())
  	EndDo
  
	cMsg+="</table>"
	cMsg+="<footer>"
	cMsg+="<p height='50' width='1400' style='text-align:center; color: rgb(255, 255, 255); background-color:rgb(0, 0, 0);'  scope='col'>WFPALNTRANS</p>"
	cMsg+="</footer>"
  	cMsg+="</body>"
  	cMsg+="</html>" 

    DbSelectArea("TM1")
    DbCloseArea() 
    
    U_EnvMail(cAssunto, cMsg, cPara)
  	
  	RESET ENVIRONMENT 

Return
