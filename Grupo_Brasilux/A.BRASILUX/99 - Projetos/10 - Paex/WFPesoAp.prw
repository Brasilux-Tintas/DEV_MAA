#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH" 

/*
	+---------------------------------------------------------------------------+
	+ Funcao    | WFPesoAp         | Função de Workflow					   	    |
	+-----------+----------+-------+-----------------------+------+-------------+ 
	+ Autor 	| André Maester						                            | 
	+-----------+----------+-------+-----------------------+------+-------------+
	+ Data 		| 26/05/16   													|
	+-----------+----------+-------+-----------------------+------+-------------+
	|                                                                           |
    | Descricao:	Função de WorkFlow para envio de mensagem por email	 	  	|
    |               das ordens de Produção apontadas no dia e a apuração das    |
    |               diferenças encontradas entre o peso apurado e peso calculado| 
	+-----------+------------------------------------------+------+-------------+ 
	| USO  AP        				    									   	|                                      						    
	+---------------------------------------------------------------------------+  

*/         
User Function WFPesoAp()
    
    Local cPara    	:= "" //TRIM(GETMV("ZP_PAR0074")) //"pcp@brasilux.com.br;andre@brasilux.com.br"
    Local cAssunto  := "Ordens de Produção Encerradas em "+Dtoc(ddatabase)
    Local cMsg		:= ""

    // Tolerância 0.4 Kg para Ops até 200 Kgs e 0.2% para Ops Maiores do que 200 Kgs

    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010101" 
    cPara 	:= TRIM(GETMV("ZP_PAR0074"))

     /**	Monta a query para buscar os dados	**/   
	cTmp 	:= U_NovoCursor()    
    cQuery 	:= ""
    
    cQuery += " WITH TMP AS( "
    cQuery += " SELECT ZZA_ORDEM, ZZA_LOTE, ZZA_PRODUT, B1_DESC, (ZZA_PESFIN+ZZA_TARA) AS 'PESOFINAL',ZZA_PESAPU AS 'PESOENVASE', "
    cQuery += " CASE WHEN ZZA_PESAPU <> 0 AND ZZA_PESFIN > 200  THEN ROUND((((ZZA_PESAPU / (ZZA_PESFIN+ZZA_TARA)) -1)*100),4) ELSE "
    cQuery += " CASE WHEN ZZA_PESAPU <> 0 AND ZZA_PESFIN <= 200 THEN ROUND(ABS(ZZA_PESAPU - (ZZA_PESFIN+ZZA_TARA)),2) ELSE "
    cQuery += " CASE WHEN ZZA_PESAPU = 0 THEN -100 END END END AS 'PERCENT', "
    cQuery += " CASE WHEN ZZA_PESAPU <> 0 AND ZZA_PESFIN <=200 AND ABS(ZZA_PESAPU - (ZZA_PESFIN+ZZA_TARA)) <0.4 THEN '1- MENOR QUE 200 (QTDE) OK' ELSE "
    cQuery += " CASE WHEN ZZA_PESAPU <> 0 AND ZZA_PESFIN <=200 AND ABS(ZZA_PESAPU - (ZZA_PESFIN+ZZA_TARA)) >0.4 THEN '2- MENOR QUE 200 (QTDE) FORA' ELSE "
    cQuery += " CASE WHEN ZZA_PESAPU <> 0 AND ZZA_PESFIN > 200 AND ABS(ROUND((((ZZA_PESAPU / (ZZA_PESFIN+ZZA_TARA)) -1)*100),4)) <0.2 THEN '1- MAIOR QUE 200 (%) OK' ELSE  "
    cQuery += " CASE WHEN ZZA_PESAPU <> 0 AND ZZA_PESFIN > 200 AND ABS(ROUND((((ZZA_PESAPU / (ZZA_PESFIN+ZZA_TARA)) -1)*100),4)) >0.2 THEN '2- MAIOR QUE 200 (%) FORA' ELSE  "
    cQuery += " CASE WHEN ZZA_PESAPU = 0 THEN '3 - SEM APURAR' END END END END END AS 'RESULT', "
    cQuery += " 'COUNTZZA' = (SELECT COUNT(*) FROM ZZA010 ZZA1 WHERE ZZA1.ZZA_FILIAL = ZZA.ZZA_FILIAL AND ZZA1.ZZA_LOTE = ZZA.ZZA_LOTE AND ZZA1.ZZA_PRODUT <> ZZA.ZZA_PRODUT)"
    cQuery += " FROM "+RetSqlName("ZZA")+" ZZA WITH (NOLOCK) "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON ZZA_FILIAL = B1_FILIAL AND ZZA_PRODUT = B1_COD AND SB1.D_E_L_E_T_ ='' "
    cQuery += " WHERE ZZA_DTFIM ='"+Dtos(ddatabase)+"'" 
    cQuery += " AND ZZA.D_E_L_E_T_ ='' "
    cQuery += " AND ZZA_FILIAL ='"+XFilial("ZZA")+"'"
    cQuery += " AND B1_TIPO ='PI' "
    cQuery += " AND B1_GRUPO BETWEEN('PI00') AND ('PI99'))"
    cQuery += " SELECT * FROM TMP WHERE TMP.COUNTZZA >0 "
    cQuery += " ORDER BY RESULT ASC, TMP.PESOFINAL , TMP.ZZA_LOTE  "
    
    
	TcQuery cQuery ALIAS (cTmp) NEW   
	DbSelectArea(cTmp)        
   
            
	/**		Monta o script HTML para ser enviado por email 	**/        
	cMsg:="<html>"
	cMsg+="<body>"
	cMsg+="<table width='1400' height='92' border='0'>"
	cMsg+="<tr><th height='30'  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>LOTE</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>PRODUTO</th>" 
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>DESCRIÇÃO</th>" 
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>PESO CALCULADO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>PESO APURADO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>QTD OU %.</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>RESULTADO</th>"
	cMsg+="</tr>"    
	        //#FFD7D7   #ECFFEC
   	If (cTmp)->(eof()) //se o arquivo estiver vazio, sai da rotina
   		 (cTmp)->(DbCloseArea()) 
   		 Return()
   	EndIf		
   	dbselectarea(cTmp)
   	While !eof()
		cMsg+="<tr>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->ZZA_LOTE)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->ZZA_PRODUT)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->B1_DESC)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TRANSFORM((cTmp)->PESOFINAL,'@E 999,999.999')+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TRANSFORM((cTmp)->PESOENVASE,'@E 999,999.999')+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TRANSFORM((cTmp)->PERCENT,'@E 999.99')+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->RESULT)+"</td>"
		cMsg+="</tr>"
  
	    (cTmp)->(dbSkip())
  	End
  
  
	cMsg+="</table>"
  	cMsg+="</body>"
  	cMsg+="</html>" 
   
  	(cTmp)->(DbCloseArea()) 
    
    U_EnvMail(cAssunto, cMsg, cPara)
  	
  	RESET ENVIRONMENT
  	
Return
