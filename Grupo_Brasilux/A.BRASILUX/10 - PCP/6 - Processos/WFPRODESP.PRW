#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH" 
/*
	+---------------------------------------------------------------------------+
	+ Funcao    | WFPRODESP        | Função de Workflow					   	    |
	+-----------+----------+-------+-----------------------+------+-------------+ 
	+ Autor 	| André Maester 					                            | 
	+-----------+----------+-------+-----------------------+------+-------------+
	+ Data 		| 24/10/19   													|
	+-----------+----------+-------+-----------------------+------+-------------+
	|                                                                           |
    | Descricao:	Função destinada ao envio de e-mails de produtos especificos|
    |               que foram produzidos pelo menos 3 vezes no mês anterior     |
    +-----------+------------------------------------------+------+-------------+ 
	| USO  AP        				    									   	|                                      						    
	+---------------------------------------------------------------------------+  
*/         
User Function WFPRODESP()
   
    Local cPara    	:= "materiais@brasilux.com.br"
    Local cAssunto  := "Específicos com pelo menos 3 produções no mês anterior."
    Local cMsg		:= ""
    Local cQuery    := ""
    //Local TM1

    
    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010101" 

    cQuery := ""
    cQuery += " SELECT C2_PRODUTO AS 'CODPRO', B1_DESC AS 'DESC', SUM(C2_QUJE) AS 'QTDE', (B1_CONV * SUM(C2_QUJE)) AS 'VOLUME', SUBSTRING(C2_DATRF,1,6) AS 'ANOMES', COUNT(SC2.R_E_C_N_O_) AS 'PRODUCOES' "
    cQuery += " FROM "+RetSqlName("SC2")+" SC2 WITH(NOLOCK) " 
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON B1_FILIAL = C2_FILIAL AND B1_COD = C2_PRODUTO AND SB1.D_E_L_E_T_ ='' "
    cQuery += " WHERE C2_FILIAL ='"+XFILIAL("SC2")+"' AND SC2.D_E_L_E_T_ ='' " 
    cQuery += " AND C2_DATRF BETWEEN (DATEADD(mm, DATEDIFF(mm,0,GETDATE()) - 1, 0)) AND (DATEADD(mm, DATEDIFF(mm,0,GETDATE()), -1)) "
    cQuery += " AND B1_GRUPO BETWEEN('PA00') AND ('PA99') " 
    cQuery += " AND B1_ESTOQUE <>'S' "
    cQuery += " GROUP BY C2_PRODUTO, B1_DESC, B1_CONV, B1_GRUPO, SUBSTRING(C2_DATRF,1,6) "
    cQuery += " HAVING COUNT(SC2.R_E_C_N_O_) >=3 "
    cQuery += " ORDER BY SUBSTRING(C2_DATRF,1,6),COUNT(SC2.R_E_C_N_O_) DESC, B1_GRUPO, C2_PRODUTO "  

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
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>ANO - MÊS</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>CODIGO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>DESCRIÇÃO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>QTDE PRODUZIDA</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>VOLUME PRODUZIDO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>VEZES PRODUZIDO</th>"

	cMsg+="</tr>"    
	        //#FFD7D7   #ECFFEC
   	DbSelectArea("TM1")
   	While TM1->(!eof())
		
		cMsg+="<tr>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->ANOMES+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->CODPRO+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->DESC+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TRANSFORM(TM1->QTDE,'@E 99999')+"</td>" 
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TRANSFORM(TM1->VOLUME,'@E 99999.99')+"</td>" 
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TRANSFORM(TM1->PRODUCOES,'@E 99999')+"</td>" 

		cMsg+="</tr>"
	    
	    TM1->(dbSkip())
  	EndDo
  
	cMsg+="</table>"
	cMsg+="<footer>"
	cMsg+="<p height='50' width='1400' style='text-align:center; color: rgb(255, 255, 255); background-color:rgb(0, 0, 0);'  scope='col'>WFPRODESP</p>"
	cMsg+="</footer>"
  	cMsg+="</body>"
  	cMsg+="</html>" 

    DbSelectArea("TM1")
    DbCloseArea() 
    
    U_EnvMail(cAssunto, cMsg, cPara)
  	
  	RESET ENVIRONMENT 

Return