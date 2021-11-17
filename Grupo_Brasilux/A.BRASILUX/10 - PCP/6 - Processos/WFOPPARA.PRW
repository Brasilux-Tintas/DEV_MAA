#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH" 
/*
	+-X--------------------------------------------------------------------------+
	+ Funcao    | WFOPPARA         | Função de Workflow					   	    |
	+-----------+----------+-------+-----------------------+------+-------------+ 
	+ Autor 	| André Maester 					                            | 
	+-----------+----------+-------+-----------------------+------+-------------+
	+ Data 		| 19/06/19   													|
	+-----------+----------+-------+-----------------------+------+-------------+
	|                                                                           |
    | Descricao:	Função destinada ao envio de e-mails de aviso para o PCP de	|
    |               Ops que tiveram o PI finalizado e PA não iniciado a mais de	|
    |               4 Horas														|
	+-----------+------------------------------------------+------+-------------+ 
	| USO  AP        				    									   	|                                      						    
	+---------------------------------------------------------------------------+  
*/         
User Function WFOPPARA()
   
    Local cPara    	:= "gustavo@brasilux.com.br,michelly@brasilux.com.br,paulo@brasilux.com.br,marciononis@brasilux.com.br,marcosmagalhaes@brasilux.com.br,antoniocarlos@brasilux.com.br,tiagobianchi@brasilux.com.br,jonatas@brasilux.com.br,ricardo@brasilux.com.br"
    Local cAssunto  := "OPS com PI Finalizado e Envase nao iniciado (Intervalo minimo de 4 horas)"
    Local cMsg		:= ""
    Local cQuery    := ""
    //Local TM1

    
    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010101" 

    cQuery := ""
    cQuery += " SELECT SC2.C2_LOTE AS 'LOTE', SC2.C2_PRODUTO AS 'PRODUTO', SB1.B1_DESC AS 'DESCRICAO', "
    cQuery += " SUBSTRING(ZZAPI.ZZA_DTFIM,7,2)+'/'+SUBSTRING(ZZAPI.ZZA_DTFIM,5,2)+'/'+SUBSTRING(ZZAPI.ZZA_DTFIM,1,4) AS 'DTENCERRA'," 
    cQuery += " SUBSTRING(ZZAPI.ZZA_HFIM,1,2)+':'+SUBSTRING(ZZAPI.ZZA_HFIM,3,2) AS 'HORAFIM', " 
    cQuery += " DATEDIFF(HOUR ,CAST(SUBSTRING(ZZAPI.ZZA_HFIM,1,2)+':'+SUBSTRING(ZZAPI.ZZA_HFIM,3,2) AS TIME),CONVERT(TIME,GETDATE())) AS 'HORAS',DATEDIFF(DAY,ZZAPI.ZZA_DTFIM,GETDATE()) AS 'DIAS' "
    cQuery += " FROM "+RetSqlName("SC2")+" SC2 WITH(NOLOCK) "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("ZZA")+" ZZAPI WITH(NOLOCK) ON SC2.C2_FILIAL = ZZAPI.ZZA_FILIAL AND C2_PRODUTO = ZZAPI.ZZA_PRODUT AND C2_LOTE = ZZAPI.ZZA_LOTE AND ZZAPI.D_E_L_E_T_ ='' " 
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1   WITH(NOLOCK) ON SB1.B1_FILIAL = C2_FILIAL AND SB1.B1_COD = C2_PRODUTO AND SB1.D_E_L_E_T_ ='' "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("ZZA")+" ZZAPA WITH(NOLOCK) ON SC2.C2_FILIAL = ZZAPA.ZZA_FILIAL AND SUBSTRING(C2_PRODUTO,1,10) = SUBSTRING(ZZAPA.ZZA_PRODUT,1,10) AND C2_LOTE = ZZAPA.ZZA_LOTE AND ZZAPA.D_E_L_E_T_ ='' AND SUBSTRING(ZZAPA.ZZA_PRODUT,11,2) NOT IN('00','99') "
    cQuery += " WHERE SC2.C2_FILIAL ='010101' "
    cQuery += " AND (DATEDIFF(DAY,ZZAPI.ZZA_DTFIM,GETDATE())> 0 OR DATEDIFF(HOUR ,CAST(SUBSTRING(ZZAPI.ZZA_HFIM,1,2)+':'+SUBSTRING(ZZAPI.ZZA_HFIM,3,2) AS TIME),CONVERT(TIME,GETDATE()))>4) "
    cQuery += " AND (DATEDIFF(DAY,ZZAPI.ZZA_DTFIM,GETDATE())< 15) "
    cQuery += " AND ZZAPI.ZZA_PESFIN > 0 "
    cQuery += " AND SB1.B1_GRUPO BETWEEN('PA00') AND ('PI99') "
    cQuery += " AND (SELECT COUNT(C2_OP) FROM "+RetSqlName("SC2")+" WHERE C2_LOTE = ZZAPI.ZZA_LOTE AND C2_FILIAL = ZZAPI.ZZA_FILIAL AND D_E_L_E_T_ ='')>1 "
    cQuery += " AND ZZAPA.ZZA_LOTE IS NULL "
    cQuery += " ORDER BY ZZAPI.ZZA_DTFIM, SC2.C2_LOTE "
    

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
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>LOTE</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>PRODUTO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>DESCRIÇÃO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>DT ENCERRAMENTO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>HORA ENCERRAMENTO</th>"


	cMsg+="</tr>"    
	        //#FFD7D7   #ECFFEC
   	DbSelectArea("TM1")
   	While TM1->(!eof())
		
		cMsg+="<tr>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->LOTE+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->PRODUTO+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->DESCRICAO+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim(TM1->DTENCERRA)+"</td>" 
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->HORAFIM+"</td>"		
		cMsg+="</tr>"
	    
	    TM1->(dbSkip())
  	EndDo
  
	cMsg+="</table>"
	cMsg+="<footer>"
	cMsg+="<p height='50' width='1400' style='text-align:center; color: rgb(255, 255, 255); background-color:rgb(0, 0, 0);'  scope='col'>WFOPPARA</p>"
	cMsg+="</footer>"
  	cMsg+="</body>"
  	cMsg+="</html>" 

    DbSelectArea("TM1")
    DbCloseArea() 
    
    U_EnvMail(cAssunto, cMsg, cPara)
  	
  	RESET ENVIRONMENT 

Return
