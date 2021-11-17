#include "rwmake.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "topconn.ch"


/*
Rotina que envia e-mail avisando ao usuário de que existem OP´s não apontadas, ou seja, não viraram Produção, e que
tem alguma inconsistência. O usuário deverá utilizar a rotina U_CADZZE para poder verificar o erro e então fazer a cor-
reção. Logo após efetuar a correção deverá rodar novamente a rotina U_APONTAOP.
*/

User Function SCHZZE()
	//LGS#20200207 - Adequação de release 12.1.25 e posteriores
	//ConOut("Entrou no fonte SCHZZE...")
	FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', "Entrou no fonte SCHZZE...", 0 )
	SCHZZE1(11,11)
	//LGS#20200207 - Adequação de release 12.1.25 e posteriores
	//ConOut("Terminou a execução do SCHZZE1, encerrando a rotina...")
	FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', "Terminou a execução do SCHZZE1, encerrando a rotina...", 0 )
Return

Static Function SCHZZE1( _codEmp,_codFil)
	Local cAssunto	:= "WorkFlow da Relação das Ordens de Produção com problemas na empresa " +cValToChar(_codEmp)+ " Filial " +cValToChar(_codFil)+ ". Data: " +DTOC(dDataBase)
	Local cMsg		:= ""
	Local cAnexo	:= ""
	//Local cQuery    := ""
	Local _aDados := {}
	Local cLinha := Chr(13) + Chr(10)
	Local _ret
	Local i

	//LGS#20200207 - Adequação de release 12.1.25 e posteriores
	//ConOut("SCHZZE1.PRW - Inicio do fonte.. ")
    FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', "SCHZZE1.PRW - Inicio do fonte.. ", 0 )
	cPara := GETMV("MV_XMAILOP")

	_aDados := QueryDados()


	If Len(_aDados) > 0

		/**		Monta o script HTML para ser enviado por email 	**/
		cMsg:="<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>"+cLinha
		cMsg+="<html xmlns='http://www.w3.org/1999/xhtml'>"+cLinha
		cMsg+="	<head>"+cLinha
		cMsg+=" <meta http-equiv='Content-Type' content='text/html; charset=UTF-8' />"+cLinha
		cMsg+=" <title>Relação das Ordens de Produção com problemas</title>"+cLinha
		cMsg+=" <meta name='viewport' content='width=device-width, initial-scale=1.0'/>"+cLinha
		cMsg+="</head>"+cLinha
		cMsg+="<body>"+cLinha

		cMsg+=" <table align='center' border='0'  width='95%'>"+cLinha
		cMsg+="<tr >"+cLinha
		cMsg+="<td  colspan='9'>"+cLinha
		cMsg+="<center><h1> Relação das Ordens de Produção com problemas</h1></center>"+cLinha
		cMsg+="</td >"+cLinha
		cMsg+="</tr >"+cLinha
		cMsg+="<tr >"+cLinha
		cMsg+="<th bgcolor='#00B95C' FONT COLOR='#ffffff'>"+cLinha
		cMsg+="Num. OP"+cLinha
		cMsg+="</th>"+cLinha
		cMsg+="<th bgcolor='#00B95C'>"+cLinha
		cMsg+="item"+cLinha
		cMsg+="</th>"+cLinha
		cMsg+="<th bgcolor='#00B95C'>"+cLinha
		cMsg+="Dt. Emissao"+cLinha
		cMsg+="</th>"+cLinha
		cMsg+="</tr>"+cLinha

		For i:=1 To Len(_aDados)

			IF i%2!=0
				cMsg+=" <tr>"+cLinha
				cMsg+="<td bgcolor='#F1F8FE' FONT COLOR='#ffffff'>"+cLinha
				cMsg+=" "+_aDados[i][2]+" "+cLinha
				cMsg+=" </td>"+cLinha
				cMsg+="   <td bgcolor='#F1F8FE'>"+cLinha
				cMsg+="  "+_aDados[i][3]+"  "+cLinha
				cMsg+="  </td>"+cLinha
				cMsg+="  <td bgcolor='#F1F8FE'>"+cLinha
				cMsg+="  "+_aDados[i][4]+" "+cLinha
				cMsg+="  </td>"+cLinha
				cMsg+=" </tr>"+cLinha
			Else
				cMsg+=" <tr>"+cLinha
				cMsg+="<td bgcolor='#A4CDF7' FONT COLOR='#ffffff'>"+cLinha
				cMsg+=" "+_aDados[i][2]+" "+cLinha
				cMsg+=" </td>"+cLinha
				cMsg+="   <td bgcolor='#A4CDF7'>"+cLinha
				cMsg+="  "+_aDados[i][3]+"  "+cLinha
				cMsg+="  </td>"+cLinha
				cMsg+="  <td bgcolor='#A4CDF7'>"+cLinha
				cMsg+="  "+_aDados[i][4]+" "+cLinha
				cMsg+="  </td>"+cLinha
				cMsg+=" </tr>"+cLinha
			EndIf
		Next i

		cMsg+="</table>"+cLinha
		cMsg+="</body>"+cLinha
		cMsg+="</html>  "+cLinha

		_ret := EnvMail(cAssunto, cMsg, cPara, "", cAnexo)
	Else
	    //LGS#20200207 - Adequação de release 12.1.25 e posteriores
	    //ConOut("Nao ha dados! - SCHZZE1.PRW")
        FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', "Nao ha dados! - SCHZZE1.PRW", 0 )
	Endif

Return


Static Function QueryDados()

	Local _aDados	:= {}
	Local cLinha	:= Chr(13) + Chr(10)
	Local cQuery	:= ""

	if Select("TMZZE")<>0
		dbselectarea("TMZZE")
		TMZZE->(dbclosearea())
	Endif

	cQuery :="	SELECT ZZE_FILIAL, ZZE_OP, ZZE_PRODUT, ZZE_DTINI, ZZE_HRINI, ZZE_DTFIN, ZZE_HRFIN, ZZE_QTDE, ZZE_LOTECT, ZZE_LOCAL "+cLinha
	cQuery +="	FROM "+RetSqlName("ZZE")+" "+cLinha
	cQuery +="	WHERE "+cLinha
	cQuery +="	ZZE_RESOLV = '2' "+cLinha
	cQuery +="	AND "+cLinha
	cQuery +="	D_E_L_E_T_='' "+cLinha
	TcQuery cQuery NEW ALIAS "TMZZE"

	If TMZZE->(EOF())
	    //LGS#20200207 - Adequação de release 12.1.25 e posteriores
	    //ConOut("SCHZZE1PRW : A Query nao retornou dados..")
        FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', "SCHZZE1PRW : A Query nao retornou dados..", 0 )
	Endif

	While !(TMZZE->(EOF()))
		aAdd(_aDados,{TMZZE->ZZE_FILIAL,;
			AllTrim(TMZZE->ZZE_OP),	;
			AllTrim(TMZZE->ZZE_PRODUT),	;
			dToc(Stod(TMZZE->ZZE_DTINI)),	;
			AllTrim(TMZZE->ZZE_HRINI),	;
			dToC(Stod(TMZZE->ZZE_DTFIN)),	;
			AllTrim(TMZZE->ZZE_HRFIN),		;
			AllTrim(TMZZE->ZZE_QTDE), 		;
			AllTrim(TMZZE->ZZE_LOTECT),	;
			AllTrim(TMZZE->ZZE_LOCAL)})
		TMZZE->(dbSkip())
	EndDo

Return _aDados

Static Function EnvMail(_cSubject, _cBody, _cMailTo, _cCC, _cAnexo)
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
     	    //LGS#20200207 - Adequação de release 12.1.25 e posteriores
	        //ConOut("Nao foi possivel autenticar a conta - " + _cUsuario2)
            FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', "Nao foi possivel autenticar a conta - " + _cUsuario2, 0 )
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
     	    //LGS#20200207 - Adequação de release 12.1.25 e posteriores
	        //ConOut(cErrorMsg)
            FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', cErrorMsg, 0 )
		EndIf
	EndDo

Return lResult