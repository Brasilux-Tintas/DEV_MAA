#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH" 

/*
	+---------------------------------------------------------------------------+
	+ Funcao    | WFDevSac        | Função de Workflow					   	    |
	+-----------+----------+-------+-----------------------+------+-------------+ 
	+ Autor 	| Dyego /Chaus Informática 									    | 
	+-----------+----------+-------+-----------------------+------+-------------+
	+ Data 		| 19/03/14   													|
	+-----------+----------+-------+-----------------------+------+-------------+
	|                                                                           |
    | Descricao:	Função de WorkFlow para envio de mensagem por email	 	  	|
    |               produtos parados no armazem de reaproveitamento             |
	+-----------+------------------------------------------+------+-------------+ 
	| USO  AP        				    									   	|                                      						    
	+---------------------------------------------------------------------------+  
*/    
         
User Function WFDevSac(_para)
	 Local cEmail   				:= "brasilux@gmail.com"//Trim(GetMV("MV_WFMAIL")) //conta de email utilizada para envio
     Local cPass    				:= ""//Trim(GetMV("MV_WFPASSW")) //senha do email
     //Local cServerSMTP  			:= ""//Trim(GetMV("MV_WFSMTP")) //servidor para envio de email 
	 //Local cPortSMTP   		    	:=465  //GetMV("MV_PORSMTP") //porta para envio de email 
     //Local cServerPOP3  		    :=""//Trim(GetMV("MV_WFPOP3")) //servidor para recebimento de email
	 //Local cPortPOP3   		    	:=""//GetMV("MV_PORPOP3") //porta para recebimento de email 
     //Local cDe		   			    := ""//Trim(GetMV("MV_WFMAIL")) //conta de email que é o rementente do email
     Local cPara    			  	:= _para  //lista de rementes 
     Local dData                    :=DATE()                    
	 Local cAssunto				    := "WorkFlow Produtos Parados no Armazem de Reaproveitamento "+DTOC(dData)
     Local cMsg						:= ""
     LOcal cAnexo					:= ""  //"<img src='http://www.trianguloflorestal.com.br/image/logo.png' width='100' height='76'>"
     Local nCont                    := 0        
     Local cQuery                   := ""  
      
    // PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010101" //TABLES "SB1", "SC2", "ZZA", "ZZF"   
     
     /**	Monta a query para buscar os dados	**/   
     
  	cQuery:="SELECT	B2_FILIAL, B2_COD, BM_DESC, B1_DESC, B2_LOCAL, B2_QATU, B2_VATU1, B2_CM1 "
	cQuery+="FROM	"+RetSqlName("SB2")+" SB2 WITH (NOLOCK)	"
	cQuery+="		INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"' AND B2_COD = B1_COD AND SB2.D_E_L_E_T_ = SB1.D_E_L_E_T_  "
	cQuery+="		INNER JOIN "+RetSqlName("SBM")+" SBM WITH (NOLOCK) ON BM_FILIAL = '"+xFilial("SBM")+"' AND B1_GRUPO = BM_GRUPO AND SBM.D_E_L_E_T_ = SB1.D_E_L_E_T_ "
	cQuery+="WHERE	SB2.D_E_L_E_T_ = ''	"
	cQuery+="	AND B2_LOCAL = '13'	"
	cQuery+="	AND B2_QATU > 0	" 
	cQuery+="	AND B2_FILIAL = '"+xFilial("SB2")+"'"
		    
		
     
     TcQuery cQuery ALIAS "TMP" NEW   
      
	 DbSelectArea("TMP")        
	              
	/**		Monta o script HTML para ser enviado por email 	**/        
	cMsg:="<html>"
	cMsg+="<body>"
	cMsg+="<table width='1400' height='92' border='0'>"
	cMsg+="<tr><th height='30'  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>Filial</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>Grupo de Produto</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>Codigo</th>" 
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>Descricao</th>" 
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>Armazem</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>Quantidade atual</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>Custo Unitario</th>" 
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>Custo Total</th>"
	cMsg+="</tr>"    
	        //#FFD7D7   #ECFFEC
   	If TMP->(eof()) //se o arquivo estiver vazio, sai da rotina
   		 Return()
   	EndIf		

   While !(TMP->(eof()))                                               
	
            
  		IF nCont % 2 == 1
  		
			cMsg+="<tr>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim(TMP->B2_FILIAL)+"</td>"    
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim(TMP->BM_DESC)+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim(TMP->B2_COD)+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim(TMP->B1_DESC)+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim(TMP->B2_LOCAL)+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TRANSFORM(TMP->B2_QATU,'@E 999,999,999')+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >R$ "+TRANSFORM(TMP->B2_CM1,'@E 999,999,999.99')+"</td>"  
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >R$ "+TRANSFORM(TMP->B2_QATU*TMP->B2_CM1,'@E 999,999,999.99')+"</td>" 
			cMsg+="</tr>"
  		ELSE 
  	cMsg+="<tr>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(255, 255, 255);' >"+Alltrim(TMP->B2_FILIAL)+"</td>"    
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(255, 255, 255);' >"+Alltrim(TMP->BM_DESC)+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(255, 255, 255);' >"+Alltrim(TMP->B2_COD)+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(255, 255, 255);' >"+Alltrim(TMP->B1_DESC)+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(255, 255, 255);' >"+Alltrim(TMP->B2_LOCAL)+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(255, 255, 255);' >"+TRANSFORM(TMP->B2_QATU,'@E 999,999,999')+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(255, 255, 255);' >R$ "+TRANSFORM(TMP->B2_CM1,'@E 999,999,999.99')+"</td>"  
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(255, 255, 255);' >R$ "+TRANSFORM(TMP->B2_QATU*TMP->B2_CM1,'@E 999,999,999.99')+"</td>" 
			cMsg+="</tr>"
  		ENDIF      
  
   	nCont++
    TMP->(dbSkip())
  End
  
  
  cMsg+="</table>"
  cMsg+="</body>"
  cMsg+="</html>" 
   
  TMP->(DbCloseArea()) 
  
  EnvMail(cAssunto, cMsg, cPara, "", cAnexo, cEmail, cPass)	                                                          

  //RESET ENVIRONMENT 

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
	|  19/03/14 Dyego/Chaus => Alteração para envio de email do Workflow 	|
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