#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH" 
/*
	+---------------------------------------------------------------------------+
	+ Funcao    | WFOrdProd        | Função de Workflow					   	    |
	+-----------+----------+-------+-----------------------+------+-------------+ 
	+ Autor 	| Tiago /Chaus Informática 									    | 
	+-----------+----------+-------+-----------------------+------+-------------+
	+ Data 		| 19/03/14   													|
	+-----------+----------+-------+-----------------------+------+-------------+
	|                                                                           |
    | Descricao:	Função de WorkFlow para envio de mensagem por email	 	  	|
    |               de Ordens de Produção em aberto atrasadas                   |
	+-----------+------------------------------------------+------+-------------+ 
	| USO  AP        				    									   	|                                      						    
	+---------------------------------------------------------------------------+  
*/    
         
User Function WFOrdProd()
   
	 

	 Local cEmail   				:= "workflowbrasilux@gmail.com"//Trim(GetMV("MV_WFMAIL")) //conta de email utilizada para envio
     Local cPass    				:= ""//Trim(GetMV("MV_WFPASSW")) //senha do email
     //Local cServerSMTP  			:= ""//Trim(GetMV("MV_WFSMTP")) //servidor para envio de email 
	 //Local cPortSMTP   		    	:=465  //GetMV("MV_PORSMTP") //porta para envio de email 
     //Local cServerPOP3  		    :=""//Trim(GetMV("MV_WFPOP3")) //servidor para recebimento de email
	 //Local cPortPOP3   		    	:=""//GetMV("MV_PORPOP3") //porta para recebimento de email 
     //Local cDe		   			    := ""//Trim(GetMV("MV_WFMAIL")) //conta de email que é o rementente do email
     Local cPara    			  //	:= Trim(GetMV("MV_XWFCCPC"))+";tiago.lucio@chaus.com.br"  //lista de rementes 
     Local dData                    :=DATE()                    
	 Local cAssunto				    := "WorkFlow Ordens de Produção atrasadas "+SUBSTR(DTOS(dData),7,2)+"/"+SUBSTR(DTOS(dData),5,2)+"/"+SUBSTR(DTOS(dData),1,4)
     Local cMsg						:= ""
     LOcal cAnexo					:= ""  //"<img src='http://www.trianguloflorestal.com.br/image/logo.png' width='100' height='76'>"
     Local nCont                    := 0        
     Local cQuery                   := ""  
     
      
     PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010101" //TABLES "SB1", "SC2", "ZZA", "ZZF"   
     
     
     cPara    				:= Trim(GetMV("MV_XWFCCPC"))  //lista de rementes 
     
     
      
     /**	Monta a query para buscar os dados	**/   
     cQuery:=" SELECT DISTINCT	ZZA_DTLOG, SC2.C2_OP,SC2.C2_DATPRF, SC2.C2_QUANT, SC2.C2_LOCAL, SC2.C2_QUJE, SC2.C2_LOTE, ZZA.ZZA_OPERAC, SC2.C2_PRODUTO, B1_DESC,ZZA.ZZA_HELP,ZZA.ZZA_CAMPO	"
     cQuery+=" 		FROM "+RetSqlName("SC2")+" SC2   "
	 cQuery+="			LEFT JOIN "+RetSqlName("ZZA")+" ZZA ON C2_FILIAL = ZZA_FILIAL AND C2_OP = ZZA_ORDEM AND SC2.D_E_L_E_T_ = ZZA.D_E_L_E_T_	"
	 cQuery+="			LEFT JOIN "+RetSqlName("ZZF")+" ZZF ON C2_FILIAL = ZZF_FILIAL  AND C2_OP = ZZF_ORDEM AND SC2.D_E_L_E_T_ = ZZF.D_E_L_E_T_	"
     cQuery+="	   		LEFT JOIN SB1010 SB1 ON C2_FILIAL = B1_FILIAL AND  C2_PRODUTO = B1_COD AND SC2.D_E_L_E_T_ = SB1.D_E_L_E_T_ 	"
     cQuery+=" 		WHERE SC2.D_E_L_E_T_='' AND SC2.C2_FILIAL="+xFilial("SC2")+" AND SC2.C2_DATPRF<'"+DTOS(dData)+"' AND SC2.C2_DATPRF >='20140101'"
     cQuery+="  	  AND  C2_QUJE=0 AND SC2.D_E_L_E_T_=''  AND NOT ZZA_HELP LIKE '%EXCLUIDA%' AND ZZA_FLAG NOT IN ('1','2','3','6','E')"                                               
     cQuery+="	GROUP BY SC2.C2_OP,SC2.C2_DATPRF, SC2.C2_QUANT, SC2.C2_LOCAL, SC2.C2_QUJE, SC2.C2_LOTE, ZZA.ZZA_OPERAC, SC2.C2_PRODUTO,ZZA.ZZA_HELP,ZZA.ZZA_CAMPO,B1_DESC,ZZA_DTLOG	 	"  
	 cQuery+="	ORDER BY SC2.C2_DATPRF, SC2.C2_OP,ZZA_DTLOG 	"  
       
     TcQuery cQuery ALIAS "TMP" NEW   
      
	 DbSelectArea("TMP")        
	              
	/**		Monta o script HTML para ser enviado por email 	**/        
	cMsg:="<html>"
	cMsg+="<body>"
	cMsg+="<table width='1400' height='92' border='0'>"
	cMsg+="<tr><th height='30' bgcolor='#FFD7D7' scope='col'>Ordem Prod</th>"
	cMsg+="<th bgcolor='#FFD7D7' scope='col'>Quantidade</th>" 
	cMsg+="<th bgcolor='#FFD7D7' scope='col'>Data de Entrega</th>"
	cMsg+="<th bgcolor='#FFD7D7' scope='col'>Local requisitado</th>"
	cMsg+="<th bgcolor='#FFD7D7' scope='col'>Lote</th>"
	cMsg+="<th bgcolor='#FFD7D7' scope='col'>Produto</th>"
	cMsg+="<th bgcolor='#FFD7D7' scope='col'>Descrição</th>"
	cMsg+="<th bgcolor='#FFD7D7' scope='col'>Data ocorrencia</th>"
	cMsg+="<th bgcolor='#FFD7D7' scope='col'>Ocorrencia</th>"
	cMsg+="</tr>"    
	
   	If TMP->(eof()) //se o arquivo estiver vazio, sai da rotina
   		 Return()
   	EndIf		

   While !(TMP->(eof()))                                               
	
   	if 	nCont%2 =0
		cMsg+="<tr>"
		cMsg+="<td bgcolor='#ECFFEC'>"+Alltrim(TMP->C2_OP)+"</td>"
		cMsg+="<td bgcolor='#ECFFEC'>"+Str(TMP->C2_QUANT)+"</td>"
		cMsg+="<td bgcolor='#ECFFEC'>"+SUBSTR(TMP->C2_DATPRF,7,2)+"/"+SUBSTR(TMP->C2_DATPRF,5,2)+"/"+SUBSTR(TMP->C2_DATPRF,1,4)+"</td>"
		cMsg+="<td bgcolor='#ECFFEC'>"+Alltrim(TMP->C2_LOCAL)+"</td>"
		cMsg+="<td bgcolor='#ECFFEC'>"+Alltrim(TMP->C2_LOTE)+"</td>"
		cMsg+="<td bgcolor='#ECFFEC'>"+Alltrim(TMP->C2_PRODUTO)+"</td>"
		cMsg+="<td bgcolor='#ECFFEC'>"+Alltrim(TMP->B1_DESC)+"</td>"
		cMsg+="<td bgcolor='#ECFFEC'>"+IIF(TRIM(TMP->ZZA_DTLOG)=='','',SUBSTR(TMP->ZZA_DTLOG,7,2)+"/"+SUBSTR(TMP->ZZA_DTLOG,5,2)+"/"+SUBSTR(TMP->ZZA_DTLOG,1,4))+"</td>" 
		cMsg+="<td bgcolor='#ECFFEC'>"+Alltrim(TMP->ZZA_HELP)+" "+Alltrim(TMP->ZZA_CAMPO)+"</td>"
		cMsg+="</tr>"
   	Else		
		
		cMsg+="<tr>"
		cMsg+="<td bgcolor='#FFFFFF'>"+Alltrim(TMP->C2_OP)+"</td>" 
		cMsg+="<td bgcolor='#FFFFFF'>"+Str(TMP->C2_QUANT)+"</td>"
		cMsg+="<td bgcolor='#FFFFFF'>"+SUBSTR(TMP->C2_DATPRF,7,2)+"/"+SUBSTR(TMP->C2_DATPRF,5,2)+"/"+SUBSTR(TMP->C2_DATPRF,1,4)+"</td>"
		cMsg+="<td bgcolor='#FFFFFF'>"+Alltrim(TMP->C2_LOCAL)+"</td>"
		cMsg+="<td bgcolor='#FFFFFF'>"+Alltrim(TMP->C2_LOTE)+"</td>"
		cMsg+="<td bgcolor='#FFFFFF'>"+Alltrim(TMP->C2_PRODUTO)+"</td>"
		cMsg+="<td bgcolor='#FFFFFF'>"+Alltrim(TMP->B1_DESC)+"</td>" 
		cMsg+="<td bgcolor='#FFFFFF'>"+IIF(TRIM(TMP->ZZA_DTLOG)=='','',SUBSTR(TMP->ZZA_DTLOG,7,2)+"/"+SUBSTR(TMP->ZZA_DTLOG,5,2)+"/"+SUBSTR(TMP->ZZA_DTLOG,1,4))+"</td>"
		cMsg+="<td bgcolor='#FFFFFF'>"+Alltrim(TMP->ZZA_HELP)+" "+Alltrim(TMP->ZZA_CAMPO)+"</td>"       
		cMsg+="</tr>"
	   
		                   
   	EndIf		
   	nCont++
    TMP->(dbSkip())
  End
  
  
  cMsg+="</table>"
  cMsg+="</body>"
  cMsg+="</html>" 
   
  TMP->(DbCloseArea()) 
  
  EnvMail(cAssunto, cMsg, cPara, "", cAnexo, cEmail, cPass)	                                                          

  RESET ENVIRONMENT 

Return

/*
	+---------------------------------------------------------------------------+
	+ Funcao | EnvMail | Ponto de Entrada 								   	    |
	+-----------+----------+-------+-----------------------+------+-------------+ 
	+ Autor | Brasilux 									   					    | 
	+-----------+----------+-------+-----------------------+------+-------------+                         
	+ Data | 19/03/14   														|
	+-----------+----------+-------+-----------------------+------+-------------+
	|                                                                           |
    | Descricao:	Função de WorkFlow para envio de mensagem por email	  	 	|
    |                                                                           |
	+-----------+------------------------------------------+------+-------------+ 
	| USO  AP        				    									   	|                                      						    
	+-----------+----------+-------+-----------------------+------+-------------+          
	|  Alterações:																|
	|  19/03/14 Tiago Lucio/Chaus => Alteração para envio de email do Workflow 	|
	|  de OPs abertas em atraso.     											|
	+---------------------------------------------------------------------------+
*/


Static Function EnvMail(_cSubject, _cBody, _cMailTo, _cCC, _cAnexo, _cConta, _cSenha)
Local _cMailS		:= GetMv("MV_RELSERV")
Local _cAccount		:= GetMV("MV_RELACNT")
Local _cPass		:= GetMV("MV_RELFROM")
Local _cSenha2		:= GetMV("MV_RELPSW")
Local _cUsuario2	:= GetMV("MV_RELACNT")
Local lAuth			:= GetMv("MV_RELAUTH",,.F.)
Local _xx
Connect Smtp Server _cMailS Account _cAccount Password _cPass RESULT lResult

If lAuth		// Autenticacao da conta de e-mail
	lResult := MailAuth(_cUsuario2, _cSenha2)
	If !lResult
	   //	Alert("Não foi possivel autenticar a conta - " + _cUsuario2)	//É melhor a mensagem aparecer para o usuário do que no console ou no log.txt - Poliester
			//ConOut("Nao foi possivel autenticar a conta - " + _cUsuario2)
		Return()
	EndIf
EndIf

_xx := 0                                             

lResult := .F.

do while !lResult
	
	If !Empty(_cAnexo)
		Send Mail From _cAccount To _cMailTo CC _cCC Subject _cSubject Body _cBody ATTACHMENT _cAnexo RESULT lResult
	Else
		Send Mail From _cAccount To _cMailTo CC _cCC Subject _cSubject Body _cBody RESULT lResult
	Endif
	
	_xx++
	if _xx > 2
		Exit
	Else
		Get Mail Error cErrorMsg
		//LGS#20200131 - Adequação de release 12.1.25 e posteriores
		//ConOut(cErrorMsg)
		FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', cErrorMsg, 0 )
	EndIf
EndDo
Return