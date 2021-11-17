#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH" 

/*

*/    
         
User Function WFAbatSac(_para,cNumSac)
	Local cEmail   		:= "brasilux@gmail.com"//Trim(GetMV("MV_WFMAIL")) //conta de email utilizada para envio
    Local cPass    		:= ""//Trim(GetMV("MV_WFPASSW")) //senha do email
    //Local cServerSMTP  	:= ""//Trim(GetMV("MV_WFSMTP")) //servidor para envio de email 
    //Local cServerPOP3  	:=""//Trim(GetMV("MV_WFPOP3")) //servidor para recebimento de email
    //Local cPortPOP3   	:=""//GetMV("MV_PORPOP3") //porta para recebimento de email 
    //Local cDe		   	:= ""//Trim(GetMV("MV_WFMAIL")) //conta de email que é o rementente do email
   	//Local cPortSMTP   	:= 465  //GetMV("MV_PORSMTP") //porta para envio de email 
    Local cPara    		:= _para  //lista de rementes 
    Local dData         := DATE()                    
	Local cAssunto		:= "Workflow de Abatimento Autorizado pela Diretoria via SAC em: "+DTOC(dData)
    Local cMsg			:= ""
    LOcal cAnexo		:= "" 
    Local nCont         := 0        
    Local cQuery		:= "" 
    Local cTmp 
      
     /**	Monta a query para buscar os dados	**/   
	cTmp := U_NovoCursor()    
    cQuery := ""
    cQuery += " SELECT TOP 1 ZQ_FILIAL, ZQ_NUM, ZQ_CLIENTE, CASE WHEN (ZQ_TPABAT='3') THEN 'SOMENTE AB-' ELSE 'NCC E AB-' END AS 'ZQ_TPABAT', SUM(ZR_QTDABAT * ZR_VUORI) AS 'VALABAT'  "
	cQuery += " FROM "+RetSqlName("SZS")+" SZS WITH (NOLOCK) "
	cQuery += " LEFT OUTER JOIN "+RetSqlName("SZQ")+" SZQ WITH (NOLOCK) ON ZS_FILIAL = ZQ_FILIAL AND ZS_NUM = ZQ_NUM AND SZQ.D_E_L_E_T_ ='' "
	cQuery += " LEFT OUTER JOIN "+RetSqlName("SZR")+" SZR WITH (NOLOCK) ON ZR_FILIAL = ZQ_FILIAL AND ZR_NUM = ZQ_NUM AND SZR.D_E_L_E_T_ ='' "
	cQuery += " WHERE SZS.D_E_L_E_T_ ='' "
	cQuery += " AND ZS_FILIAL ='"+xFilial("SZS")+"'"
	cQuery += " AND ZS_NUM ='"+cNumSac+"'" 
	cQuery += " AND ZS_LOG ='DIR' " 
	cQuery += " AND ZS_PROCEDE ='S' " 
	cQuery += " AND ZQ_TPABAT IN('3','4') "
	cQuery += " GROUP BY ZQ_FILIAL, ZQ_NUM, ZQ_TPABAT, ZQ_CLIENTE, SZS.R_E_C_N_O_  "
	cQuery += " ORDER BY SZS.R_E_C_N_O_ DESC "
	    TcQuery cQuery ALIAS (cTmp) NEW   
	DbSelectArea(cTmp)        
   
    
    /*
    cQuery := ""
    cQuery += "	SELECT ZQ_FILIAL,ZQ_NUM, ZQ_CLIENTE, CASE WHEN (ZQ_TPABAT='3') THEN 'AB-' ELSE 'NCC E AB-' END AS 'ZQ_TPABAT', SUM(ZR_QTDABAT * ZR_VUORI) AS 'VALABAT' "
	cQuery += " FROM "+RetSqlName("SZR")+" SZR WITH (NOLOCK) "
	cQuery += " LEFT OUTER JOIN "+RetSqlName("SZQ")+" SZQ WITH (NOLOCK) ON ZR_FILIAL = ZQ_FILIAL AND ZR_NUM = ZQ_NUM AND SZQ.D_E_L_E_T_ ='' "
	cQuery += " LEFT OUTER JOIN "+RetSqlName("SZS")+" SZS WITH (NOLOCK) ON ZS_FILIAL = ZQ_FILIAL AND ZS_NUM = ZQ_NUM AND SZS.D_E_L_E_T_ ='' "
	cQuery += " WHERE SZR.D_E_L_E_T_ ='' "
	cQuery += " AND ZR_FILIAL ='"+xFilial("SZR")+"'"
	cQuery += " AND ZS_LOG ='DIR' "
	cQuery += " AND ZS_PROCEDE ='S' "
	cQuery += " AND ZQ_TPABAT IN('3','4') "
	cQuery += " GROUP BY ZQ_FILIAL, ZQ_NUM, ZQ_TPABAT, ZQ_CLIENTE "
    TcQuery cQuery ALIAS cTmp NEW   
      */

            
	/**		Monta o script HTML para ser enviado por email 	**/        
	cMsg:="<html>"
	cMsg+="<body>"
	cMsg+="<table width='1400' height='92' border='0'>"
	cMsg+="<tr><th height='30'  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>FILIAL</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>SAC NÚMERO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>TIPO DESCONTO</th>" 
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>CLIENTE</th>" 
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>VALOR AB- (CONFIRMAR)</th>"
	cMsg+="</tr>"    
	        //#FFD7D7   #ECFFEC
   	If (cTmp)->(eof()) //se o arquivo estiver vazio, sai da rotina
   		 Return()
   	EndIf		
   	dbselectarea(cTmp)
   	While !eof()
  		IF nCont % 2 == 1
			cMsg+="<tr>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->ZQ_FILIAL)+"</td>"    
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->ZQ_NUM)+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->ZQ_TPABAT)+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Posicione("SA1", 1, xFilial("SA1")+Alltrim((cTmp)->ZQ_CLIENTE), "A1_NOME")+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >R$ "+TRANSFORM((cTmp)->VALABAT,'@E 999,999,999.99')+"</td>" 
			cMsg+="</tr>"
  		ELSE 
  			cMsg+="<tr>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->ZQ_FILIAL)+"</td>"    
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->ZQ_NUM)+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->ZQ_TPABAT)+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Posicione("SA1", 1, xFilial("SA1")+Alltrim((cTmp)->ZQ_CLIENTE), "A1_NOME")+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >R$ "+TRANSFORM((cTmp)->VALABAT,'@E 999,999,999.99')+"</td>" 
			cMsg+="</tr>"
  		ENDIF      
  
	   	nCont++
	    (cTmp)->(dbSkip())
  	End
  
  
	cMsg+="</table>"
  	cMsg+="</body>"
  	cMsg+="</html>" 
   
  	(cTmp)->(DbCloseArea()) 
  
  	EnvMail(cAssunto, cMsg, cPara, "", cAnexo, cEmail, cPass)	                                                          

Return


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
		//LGS#20200211 - Adequação de release 12.1.25 e posteriores
		//ConOut(cErrorMsg)
		FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cErrorMsg, 0 )
	EndIf
EndDo
Return

