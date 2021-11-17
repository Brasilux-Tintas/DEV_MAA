#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH" 

/*
	+---------------------------------------------------------------------------+
	+ Funcao    | WFNFPEND         | Função de Workflow					   	    |
	+-----------+----------+-------+-----------------------+------+-------------+ 
	+ Autor 	| André Maester 					                            | 
	+-----------+----------+-------+-----------------------+------+-------------+
	+ Data 		| 19/09/17   													|
	+-----------+----------+-------+-----------------------+------+-------------+
	|                                                                           |
    | Descricao:	Função de WorkFlow para envio de mensagem por email	 	  	|
    |               dos Status das NFS entre filiais 							|
	+-----------+------------------------------------------+------+-------------+ 
	| USO  AP        				    									   	|                                      						    
	+---------------------------------------------------------------------------+  
*/         
User Function WFNFPEND()
   
    Local cPara    	:= "contabilidade@brasilux.com.br;andre@brasilux.com.br;jean@brasilux.com.br;edevilson@brasilux.com.br;resina@brasilux.com.br;danilo@brasilux.com.br;faturamento@brasilux.com.br;deposito@brasilux.com.br"
    Local cAssunto  := "Nfs Simbólicas ou Transferência pendentes"
    Local cMsg		:= ""
    Local cQuery    := ""
    Local TM1

    
    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010101" 

    cQuery := ""
    cQuery += " SELECT CASE WHEN C5_PEDDEP <>'' THEN 'SIMB.' ELSE 'TRANSF.' END AS 'TIPONF',F2_FILIAL, F2_DOC, F2_SERIE, F2_PEDIDO, C5_USRCAD, "
    cQuery += " F2_CLIENTE,ISNULL(A1_NREDUZ,A2_NREDUZ) AS 'DESTINO', SUBSTRING(F2_EMISSAO,7,2)+'/'+SUBSTRING(F2_EMISSAO,5,2)+'/'+SUBSTRING(F2_EMISSAO,1,4) AS EMISSAO, DATEDIFF(DAY,F2_EMISSAO, GETDATE()) AS 'DIFEMISSAO', DATEDIFF(DAY,GETDATE(),DATEADD(ms ,-3 ,DATEADD(mm, DATEDIFF(mm, 0, GETDATE()) + 1, 0))) AS 'DIFFIMMES', "
    cQuery += " CASE WHEN F1_STATUS ='A' THEN 'OK' ELSE "
    cQuery += " CASE WHEN F1_STATUS =''  THEN 'A CLASSIFICAR' ELSE "
    cQuery += " CASE WHEN F2_CHVNFE =''  THEN 'VERIF. NOTA SAIDA' ELSE 'PUXAR XML' END END END AS 'STATUS', F2_CHVNFE, F2_EMISSAO, "
    cQuery += " (SELECT MAX(D2_TP) FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) WHERE SD2.D_E_L_E_T_ ='' AND D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE)  AS 'TIPOPROD' "
    cQuery += " FROM "+RetSqlName("SF2")+" SF2 WITH(NOLOCK) "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SA2")+" SA2 WITH(NOLOCK) ON A2_FILIAL = '"+xFilial("SA2")+"' AND F2_CLIENTE = A2_COD AND SA2.D_E_L_E_T_ ='' "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH(NOLOCK) ON A1_FILIAL = '"+xFilial("SA1")+"' AND F2_CLIENTE = A1_COD AND SA1.D_E_L_E_T_ ='' "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SF1")+" SF1 WITH(NOLOCK) ON F1_FILIAL = (CASE WHEN F2_CLIENTE IN('023818','05200') THEN '010106' ELSE CASE WHEN F2_CLIENTE IN('00354','000521') THEN '010101' ELSE CASE WHEN F2_CLIENTE IN('00401','010181') THEN '010104' ELSE '010107' END END END) AND F2_CHVNFE = F1_CHVNFE AND F2_SERIE = F1_SERIE AND SF1.D_E_L_E_T_ ='' "
	//cQuery += " LEFT OUTER JOIN "+RetSqlName("SF1")+" SF1 WITH(NOLOCK) ON F1_FILIAL = (CASE WHEN F2_CLIENTE IN('023818','05200') THEN '010106' ELSE CASE WHEN F2_CLIENTE IN('00354','000521') THEN '010101' ELSE CASE WHEN F2_CLIENTE IN('00401','010181') THEN '010104' ELSE '010107' END END END) AND F2_DOC = SUBSTRING(F1_DOC,4,6) AND F2_SERIE = F1_SERIE AND F1_FORNECE IN('00354','00401','05200','10950','07212','023818') AND SF1.D_E_L_E_T_ ='' "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH(NOLOCK) ON C5_FILIAL = F2_FILIAL AND C5_NUM = F2_PEDIDO AND C5_NOTA = F2_DOC AND C5_SERIE = F2_SERIE AND SC5.D_E_L_E_T_ ='' "
    cQuery += " WHERE SF2.D_E_L_E_T_ ='' "
    cQuery += " AND SUBSTRING(ISNULL(A2_CGC,A1_CGC),1,8)='72770878' "
    cQuery += " AND F2_EMISSAO BETWEEN(DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0)) AND (DATEADD(ms ,-3 ,DATEADD(mm, DATEDIFF(mm, 0, GETDATE()) + 1, 0)))  "
    cQuery += " AND F2_SERIE NOT IN('F') AND (F1_STATUS <>'A' OR F1_STATUS IS NULL) "
    cQuery += " AND SUBSTRING(F2_FILIAL,1,2) ='01' "
    cQuery += " ORDER BY F2_FILIAL, F2_CLIENTE,C5_PEDDEP, F2_EMISSAO "

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
	cMsg+="<tr><th height='30'  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>TIPO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>ORIGEM</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>NRO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>SERIE</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>PEDIDO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>DESTINO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>EMISSAO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>STATUS</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>TP PROD</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>CHAVE NFE</th>"

	cMsg+="</tr>"    
	        //#FFD7D7   #ECFFEC
   	DbSelectArea("TM1")
   	While TM1->(!eof())
		
		If (TM1->F2_FILIAL == '010101' .AND. F2_CLIENTE <> '000521') .OR. (TM1->F2_FILIAL == '010102' .AND. F2_CLIENTE <> '027247') .OR. (TM1->F2_FILIAL == '010104' .AND. F2_CLIENTE <> '010181')  .OR. (F2_FILIAL ='010106' .AND. F2_CLIENTE <> '023818') .OR. (F2_FILIAL ='010107' .AND. F2_CLIENTE <> '035163')
			
			If  (TM1->DIFEMISSAO >=2) .OR. (TM1->DIFFIMMES <=4)
				cMsg+="<tr>"
				cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->TIPONF+"</td>"
				cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->F2_FILIAL+"</td>"
				cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->F2_DOC+"</td>"
				cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->F2_SERIE+"</td>" 
				cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->F2_PEDIDO+"</td>"		
				cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Substr(Alltrim(TM1->DESTINO),1,30)+"</td>"
				cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim(TM1->EMISSAO)+"</td>"
				cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->STATUS+"</td>"
				cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->TIPOPROD+"</td>"
				cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Substr(Alltrim(TM1->F2_CHVNFE),1,44)+"</td>"
				cMsg+="</tr>"
			Endif
		Endif
	    
	    TM1->(dbSkip())
  	EndDo
  
	cMsg+="</table>"
	cMsg+="<footer>"
	cMsg+="<p height='50' width='1400' style='text-align:center; color: rgb(255, 255, 255); background-color:rgb(0, 0, 0);'  scope='col'>WFNFPEND</p>"
	cMsg+="</footer>"
  	cMsg+="</body>"
  	cMsg+="</html>" 

    DbSelectArea("TM1")
    DbCloseArea() 
    
    U_EnvMail(cAssunto, cMsg, cPara)
  	
  	RESET ENVIRONMENT 

Return
