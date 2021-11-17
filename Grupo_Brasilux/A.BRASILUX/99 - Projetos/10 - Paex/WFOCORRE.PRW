#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH" 

/*
	+---------------------------------------------------------------------------+
	+ Funcao    | WFOrdProd        | Função de Workflow					   	    |
	+-----------+----------+-------+-----------------------+------+-------------+ 
	+ Autor 	| Cleiton Fernandes/Chaus Informática						    | 
	+-----------+----------+-------+-----------------------+------+-------------+
	+ Data 		| 19/03/14   													|
	+-----------+----------+-------+-----------------------+------+-------------+
	|                                                                           |
    | Descricao:	Função de WorkFlow para envio de mensagem por email	 	  	|
    |               de Resumo das Ocorrências Tratadas PCP                      |
	+-----------+------------------------------------------+------+-------------+ 
	| USO  AP        				    									   	|                                      						    
	+---------------------------------------------------------------------------+  
*/    
         
User Function WFOCORRE()
   
	 

	 Local cEmail   				:= "workflowbrasilux@gmail.com"//Trim(GetMV("MV_WFMAIL")) //conta de email utilizada para envio
     Local cPass    				:= ""//Trim(GetMV("MV_WFPASSW")) //senha do email
     //Local cServerSMTP  			:= ""//Trim(GetMV("MV_WFSMTP")) //servidor para envio de email 
	 //Local cPortSMTP   		    	:=465  //GetMV("MV_PORSMTP") //porta para envio de email 
     //Local cServerPOP3  		    :=""//Trim(GetMV("MV_WFPOP3")) //servidor para recebimento de email
	 //Local cPortPOP3   		    	:=""//GetMV("MV_PORPOP3") //porta para recebimento de email 
     //Local cDe		   			    := ""//Trim(GetMV("MV_WFMAIL")) //conta de email que é o rementente do email
     Local cPara    			  //	:= Trim(GetMV("MV_XWFCCPC"))+";tiago.lucio@chaus.com.br"  //lista de rementes 
     Local dData                    :=DATE()                    
	 Local cAssunto				    := "WorkFlow Resumo de Ocorrências no PCP "+DTOC(dData)
     Local cMsg						:= ""
     LOcal cAnexo					:= ""  //"<img src='http://www.trianguloflorestal.com.br/image/logo.png' width='100' height='76'>"
     Local nCont                    := 0        
     Local cQuery                   := ""  
     
      
     PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010101" //TABLES "ZZR"   
     
     
     //cPara    				:= "michelly@brasilux.com.br; gustavo@brasilux.com.br" //Trim(GetMV("MV_XWFSAA"))  //lista de rementes 
     cPara    			   	    := Trim(GetMV("MV_XWFOCOR"))  //lista de rementes 
     
     
      
    /**	Monta a query para buscar os dados	**/   
     cQuery:=" 		SELECT MAX(SUBSTRING(ZZR_DATA,1,6))AS ZZR_DATA, ZZR_CLASSI, COUNT(ZZR_SETOR) AS QTD , ZZR_SETOR "
     cQuery+=" 		FROM "+ RetSqlName("ZZR")+" ZZR  WITH (NOLOCK) "
	 cQuery+=" 		WHERE ZZR.D_E_L_E_T_='' AND SUBSTRING(ZZR_DATA,5,2) = SUBSTRING(CONVERT( VARCHAR, CAST(DATEDIFF(DAY, 5, GETDATE()) AS DATETIME), 112),5,2)
	 cQuery+=" 								AND SUBSTRING(ZZR_DATA,1,4) = SUBSTRING(CONVERT( VARCHAR, CAST(DATEDIFF(DAY, 0, GETDATE()) AS DATETIME), 112),1,4) "
	 cQuery+=" 		GROUP BY ZZR_CLASSI,ZZR_SETOR "
	 cQuery+="		ORDER BY ZZR_SETOR, ZZR_CLASSI "  
      
      IF (Select("TMP") > 0 )
   		TMPPA->(DbCloseArea())
     EndIf   
       
     TcQuery cQuery ALIAS "TMP" NEW   
      
	 DbSelectArea("TMP")        
	              
	/**		Monta o script HTML para ser enviado por email 	**/        
	cMsg:="<html>"
	cMsg+="<body>"
	cMsg+="<table width='800' height='92' border='#99CCFF'>"
	cMsg+="<tr><th height='20' bgcolor='#99CCFF' scope='col'>Data</th>"
	cMsg+="<th bgcolor='#99CCFF' scope='col'>Classificação</th>"
	cMsg+="<th bgcolor='#99CCFF' scope='col'>Quantidade</th>"
	cMsg+="<th bgcolor='#99CCFF' scope='col'>Setor</th>"
	cMsg+="</tr>"    
	
   	If TMP->(eof()) //se o arquivo estiver vazio, sai da rotina
   		 Return()
   	EndIf		

   While !(TMP->(eof()))                                               
	                       
 
   	if 	nCont%2 =0
		cMsg+="<tr>"
		cMsg+="<td bgcolor='#CCFFFF'align=center>"+SUBSTR(TMP->ZZR_DATA,5,2)+"/"+SUBSTR(TMP->ZZR_DATA,1,4)+"</td>"
		cMsg+="<td bgcolor='#CCFFFF'>"+Alltrim(TMP->ZZR_CLASSI)+"</td>"   
		cMsg+="<td bgcolor='#CCFFFF'align=center>"+str(TMP->QTD)+"</td>" 
		cMsg+="<td bgcolor='#CCFFFF'>"+Alltrim(TMP->ZZR_SETOR)+"</td>"
		cMsg+="</tr>"
   	Else		
		
		cMsg+="<tr>"
		cMsg+="<td bgcolor='#FFFFFF'align=center>"+SUBSTR(TMP->ZZR_DATA,5,2)+"/"+SUBSTR(TMP->ZZR_DATA,1,4)+"</td>"
		cMsg+="<td bgcolor='#FFFFFF'>"+Alltrim(TMP->ZZR_CLASSI)+"</td>"   
		cMsg+="<td bgcolor='#FFFFFF'align=center>"+str(TMP->QTD)+"</td>" 
		cMsg+="<td bgcolor='#FFFFFF'>"+Alltrim(TMP->ZZR_SETOR)+"</td>"
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
		//LGS#20200210 - Adequação de release 12.1.25 e posteriores
		//ConOut(cErrorMsg)
		FwLogMSG( "INFO", , 'SIGAPCP', funname(), '', '01', cErrorMsg, 0 )
	EndIf
EndDo
Return