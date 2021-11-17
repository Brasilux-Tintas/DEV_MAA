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
	+ Data 		| 23/06/16   													|
	+-----------+----------+-------+-----------------------+------+-------------+
	|                                                                           |
    | Descricao:																| 
	+-----------+------------------------------------------+------+-------------+ 
	| USO  AP        				    									   	|                                      						    
	+---------------------------------------------------------------------------+  

*/         
User Function wflotven()
   
    Local cPara    	:= "wflotevencido@tecpolpa.com.br"
    Local cAssunto  := "Itens com data de validade menor que 90 dias"
    Local cMsg		:= ""
    Local cQuery    := ""
    //Local cQuery1   := ""
    //Local TM1, TM2                                                                          
    
    PREPARE ENVIRONMENT EMPRESA "11" FILIAL "11" 

    cQuery := ""
    cQuery += "SELECT B8_PRODUTO,B1_DESC,B8_SALDO,B8_LOCAL,B8_LOTECTL,DATEDIFF(D,GETDATE(),B8_DTVALID) as VALIDADE "
	cQuery += "FROM "+RetSqlName("SB8")+" SB8 "
	cQuery += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON B8_PRODUTO = B1_COD AND B1_FILIAL = B8_FILIAL AND SB1.D_E_L_E_T_ <> '*'"
	cQuery += "WHERE B8_SALDO > 0 AND DATEDIFF(D,GETDATE(),B8_DTVALID) < 90 AND SB8.D_E_L_E_T_ <> '*' AND B8_FILIAL = '"+xFilial("SB8")+"' "
	cQuery += "ORDER BY VALIDADE "
	
	TcQuery cQuery ALIAS "TCQ" NEW   
	DbSelectArea("TCQ")        
   
	/**		Monta o script HTML para ser enviado por email 	**/        
	
    
    cMsg:="<html>"
	cMsg+="<body>"
	cMsg+="<table width='1400' height='92' border='0' font size='1'>"
	cMsg+="<tr><th height='30'  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>CODIGO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>DESCRIÇÃO</th>" 
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>SALDO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>LOCAL</th>" 
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>LOTE</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>VALIDADE</th>"
	cMsg+="</tr>"    
	
	If eof() //se o arquivo estiver vazio, sai da rotina
   		dbCloseArea()
   		Return()
   	EndIf
 
 	While !eof()
 		cMsg+="<tr>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+alltrim(TCQ->B8_PRODUTO)+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+alltrim(TCQ->B1_DESC)+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+transform(TCQ->B8_SALDO,'@E 999,999,999.99')+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+alltrim(TCQ->B8_LOCAL)+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+alltrim(TCQ->B8_LOTECTL)+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+transform(TCQ->VALIDADE,'@E 99999')+"</td>"
		cMsg+="</tr>"
		dbselectarea("TCQ")	 
	    dbskip() 
 	End
 	cMsg+="</table>"
	cMsg+="<footer>"
	cMsg+="<p height='50' width='1400' style='text-align:center; color: rgb(255, 255, 255); background-color:rgb(0, 0, 0);'  scope='col'>WFLOTVEN</p>"
	cMsg+="</footer>"
  	cMsg+="</body>"
  	cMsg+="</html>" 
  	
	dbselectarea("TCQ")
  	dbCloseArea()
 
  EnvMail(cAssunto, cMsg, cPara)

RESET ENVIRONMENT


//---- Enviar Email
Static Function EnvMail(_cSubject, _cBody, _cMailTo, _cCC, _cAnexo, _cAccount, _cPass)
Local _cMailS		:= GetMv("MV_RELSERV")
Local lAuth			:= GetMv("MV_RELAUTH",,.F.)
Local _xx 
Default _cCC := ""
Default _cAnexo := ""
Default _cAccount	:= GetMV("MV_RELACNT")
Default _cPass		:= GetMV("MV_RELPSW")   

Connect Smtp Server _cMailS Account _cAccount Password _cPass RESULT lResult

If lAuth		// Autenticacao da conta de e-mail
	lResult := MailAuth(_cAccount, _cPass)
	If !lResult
		//LGS#20200214 - Adequação de release 12.1.25 e posteriores
		//ConOut("Nao foi possivel autenticar a conta - " + _cAccount)
		FwLogMSG( "INFO", , 'SIGAPCP', funname(), '', '01', "Nao foi possivel autenticar a conta - " + _cAccount, 0 )
		Return(.f.)
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
		//LGS#20200214 - Adequação de release 12.1.25 e posteriores
		//ConOut(cErrorMsg)
		FwLogMSG( "INFO", , 'SIGAPCP', funname(), '', '01', cErrorMsg, 0 )
	EndIf
EndDo
Return(lResult)  
 