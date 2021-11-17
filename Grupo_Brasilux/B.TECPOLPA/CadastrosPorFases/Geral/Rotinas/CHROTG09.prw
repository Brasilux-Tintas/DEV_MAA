#Include 'Protheus.ch'
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH" 


//chausMail:	Funcao de WorkFlow para envio de mensagem por email

User Function CHROTG09 (_cSubject, _cBody, _cMailTo, _cCC, _cAnexo)
Local _cMailS		:= GetMv("MV_RELSERV")
Local _cAccount		:= GetMV("MV_RELACNT")
Local _cPass		:= GetMV("MV_RELFROM")
Local _cSenha2		:= GetMV("MV_RELPSW")
Local _cUsuario2	:= GetMV("MV_RELACNT")
Local lAuth			:= GetMv("MV_RELAUTH",,.F.)
Local _xx
Connect Smtp Server _cMailS Account _cAccount Password _cPass RESULT lResult


_cCC += "; dyego.figueiredo@chaus.com.br"

If lAuth		// Autenticacao da conta de e-mail
	lResult := MailAuth(_cUsuario2, _cSenha2)
	If !lResult
	   //	Alert("Nv£o foi possivel autenticar a conta - " + _cUsuario2)	//vâ melhor a mensagem aparecer para o usuv°rio do que no console ou no log.txt - Poliester
			//LGS#20200214 - Adequação de release 12.1.25 e posteriores
			//ConOut("Nao foi possivel autenticar a conta - " + _cUsuario2)
			FwLogMSG( "INFO", , 'SIGAPCP', funname(), '', '01', "Nao foi possivel autenticar a conta - " + _cUsuario2, 0 )
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
		//LGS#20200214 - Adequação de release 12.1.25 e posteriores
		//ConOut(cErrorMsg)
		FwLogMSG( "INFO", , 'SIGAPCP', funname(), '', '01', cErrorMsg, 0 )
	EndIf
EndDo

//ConOut("Fim da funcao envmail")

Return lResult                                                 
                  

