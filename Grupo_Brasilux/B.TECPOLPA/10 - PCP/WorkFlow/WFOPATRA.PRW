#include "rwmake.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "topconn.ch"


/*
*********************************************************************************************************
** Função * WFOPATRA.PRW *  Autor * Tiago Lucio - Chaus      *  Data :  * 19/09/2016                   **
*********************************************************************************************************
** Descrição      * Este workFlow deverá ser executado via schedule do siga e o mesmo tem como objetivo**
**                * avisar os resp. dos Pedido de Venda em atraso                                      **
*********************************************************************************************************
** Uso            * Rotina: WFPVARTR - Modulo: Faturamento                                             **
*********************************************************************************************************
** ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL, RELACIONAR ABAIXO CONFORME A PROXIMA LINHA.       **
*********************************************************************************************************
** ANALISTA                           * DATA                *  MOTIVO DA ALTERACAO                     **
*********************************************************************************************************
**  																								   **
**                                                                                                     **
** 																									   **
**                                                                                                     **
*********************************************************************************************************
*********************************************************************************************************
*/


User Function WFOPATRA(_cEmp,_cFil)

//Local 	nRecno    := 0
//Local 	nI        := 0
//Local 	nX        := 0
//Local 	aRecnoSM0 := {}
//Local   _aArea     := getArea()
Private cQLinha   := Chr(13) + Chr(10)

PREPARE ENVIRONMENT EMPRESA '11' FILIAL '11'

//RpcSetType(3)
//RpcSetEnv(_cEmp,_cFil)
WfOPAtrasa(  cEmpAnt,cFilAnt )

/*
DbSelectArea("SM0")
DbGotop()

_codEmp := SM0->M0_CODIGO
_codFil := SM0->M0_CODFIL
RpcClearEnv()
RpcSetEnv(_codEmp,_codFil)
WfColabora(_codEmp,_codFil)

While !Eof()

	//If AllTrim(SM0->M0_CODIGO)
		Aadd(aRecnoSM0,{Recno(),SM0->M0_CODIGO, SM0->M0_CODFIL})
	//Endif
	DbSkip()
EndDo

For nI := 1 To Len(aRecnoSM0)
	SM0->(dbGoto(aRecnoSM0[nI,1]))
	_codEmp := SM0->M0_CODIGO
	_codFil := SM0->M0_CODFIL
	RpcClearEnv()
	RpcSetEnv(_codEmp,_codFil)
	WfColabora(_codEmp,_codFil )
 	DbSkip()
Next nI


restArea(_aArea)
*/
//RESET ENVIRONMENT

Return





Static Function WfOPAtrasa( _codEmp,_codFil)
//Local dData   	:=DATE()
Local cAssunto	:= "WorkFlow da Relação das Ordens de Produção em Atraso "/*+_codEmp*/+ ". Filial "+_codFil+". Data: "+DTOC(DDataBase)
Local cMsg		:= ""
Local cAnexo	:= ""
//Local nCont     := 0
//Local cQuery    := ""
Local _aDados := {}
Local cLinha := Chr(13) + Chr(10)
//Local cCliente:="", cLoja:=""
//Local aDadosCli:={}
Local i := 0


//prepare environment empresa _emp filial _fil
//LGS#20200214 - Adequação de release 12.1.25 e posteriores
//ConOut("WfOPAtrasa.prw - Inicio do fonte.. ")
FwLogMSG( "INFO", , 'SIGAPCP', funname(), '', '01', "WfOPAtrasa.prw - Inicio do fonte.. ", 0 )

cHabilit:=""
cPara := "ti@brasilux.com.br"
nPercent:=0
cDtFecha:=""

DbGotop()

//Pega o(s) remente(s) para o envio do workflow
/*If SX6->(dbSeek(cFilAnt+"MV_XWNOTAT" ))
    cHabilit := SX6->X6_CONTEUD
ElseIf SX6->(dbSeek(xFilial("SX6")+"MV_XWNOTAT" ))
    cHabilit := SX6->X6_CONTEUD
Endif

*/
_aDados := queryMain()



If Len(_aDados) > 0

	/**		Monta o script HTML para ser enviado por email 	**/
	cMsg:="<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>"+cLinha
	cMsg:="<html xmlns='http://www.w3.org/1999/xhtml'>"+cLinha
	cMsg+="	<head>"+cLinha
	cMsg+=" <meta http-equiv='Content-Type' content='text/html; charset=UTF-8' />"+cLinha
	cMsg+=" <title>Relação das Ordens de Produção em Atraso</title>"+cLinha
	cMsg+=" <meta name='viewport' content='width=device-width, initial-scale=1.0'/>"+cLinha
	cMsg+="</head>"+cLinha
	cMsg+="<body>"+cLinha

	cMsg+=" <table align='center' border='0'  width='95%'>"+cLinha
	cMsg+="<tr >"+cLinha
	cMsg+="<td  colspan='9'>"+cLinha
	cMsg+="<center><h1> Relação das Ordens de Produção em Atraso</h1></center>"+cLinha
	Msg+="</td >"+cLinha
	cMsg+="</tr >"+cLinha
	cMsg+="<tr >"+cLinha
	cMsg+="<th bgcolor='#00B95C' FONT COLOR='#ffffff'>"+cLinha
	cMsg+="Num. OP"+cLinha
	cMsg+="</th>"+cLinha
	cMsg+="<th bgcolor='#00B95C'>"+cLinha
	cMsg+="item"+cLinha
	cMsg+="</th>"+cLinha
	cMsg+="<th bgcolor='#00B95C'>"+cLinha
	cMsg+="Sequencia"+cLinha
	cMsg+="</th>"+cLinha
	cMsg+="<th bgcolor='#00B95C'>"+cLinha
	cMsg+="Produto"+cLinha
	cMsg+="  </th>"+cLinha
	cMsg+="  <th bgcolor='#00B95C'>"+cLinha
	cMsg+="   Armazem"+cLinha
	cMsg+="  </th>"+cLinha
	cMsg+="   <th bgcolor='#00B95C'>"+cLinha
	cMsg+="   Quantidade OP"+cLinha
	cMsg+="  </th>"+cLinha
	cMsg+="   <th bgcolor='#00B95C'>"+cLinha
	cMsg+="   Quantidade Usada"+cLinha
	cMsg+=" </th>"+cLinha
	cMsg+="   <th bgcolor='#00B95C'>"+cLinha
	cMsg+="  Dt. Emissão"+cLinha
	cMsg+=" </th>"+cLinha
	cMsg+="   <th bgcolor='#00B95C'>"+cLinha
	cMsg+="   Dt. Entrega Prevista"+cLinha
	cMsg+=" </th>"+cLinha
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
			cMsg+=" <td bgcolor='#F1F8FE'>"+cLinha
			cMsg+="  "+_aDados[i][5]+" "+cLinha
			cMsg+=" </td>"+cLinha
			cMsg+=" <td bgcolor='#F1F8FE'>"+cLinha
			cMsg+="  "+_aDados[i][6]+" "+cLinha
			cMsg+="  </td>"+cLinha
			cMsg+="  <td bgcolor='#F1F8FE'>"+cLinha
			cMsg+="  "+_aDados[i][7]+" "+cLinha
			cMsg+=" </td>"+cLinha
			cMsg+="  <td bgcolor='#F1F8FE'>"+cLinha
			cMsg+="  "+_aDados[i][8]+" "+cLinha
			cMsg+="  </td>"+cLinha
			cMsg+="  <td bgcolor='#F1F8FE'>"+cLinha
			cMsg+="  "+_aDados[i][9]+" "+cLinha
			cMsg+="  </td>"+cLinha
			cMsg+="  <td bgcolor='#F1F8FE'>"+cLinha
			cMsg+="  "+_aDados[i][10]+" "+cLinha
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
			cMsg+=" <td bgcolor='#A4CDF7'>"+cLinha
			cMsg+="  "+_aDados[i][5]+" "+cLinha
			cMsg+=" </td>"+cLinha
			cMsg+=" <td bgcolor='#A4CDF7'>"+cLinha
			cMsg+="  "+_aDados[i][6]+" "+cLinha
			cMsg+="  </td>"+cLinha
			cMsg+="  <td bgcolor='#A4CDF7'>"+cLinha
			cMsg+="  "+_aDados[i][7]+" "+cLinha
			cMsg+=" </td>"+cLinha
			cMsg+="  <td bgcolor='#A4CDF7'>"+cLinha
			cMsg+="  "+_aDados[i][8]+" "+cLinha
			cMsg+="  </td>"+cLinha
			cMsg+="  <td bgcolor='#A4CDF7'>"+cLinha
			cMsg+="  "+_aDados[i][9]+" "+cLinha
			cMsg+="  </td>"+cLinha
			cMsg+="  <td bgcolor='#A4CDF7'>"+cLinha
			cMsg+="  "+_aDados[i][10]+" "+cLinha
			cMsg+="  </td>"+cLinha
			cMsg+=" </tr>"+cLinha
		EndIf
Next i


cMsg+="</table>"+cLinha
cMsg+="</body>"+cLinha
cMsg+="</html>  "+cLinha


  _ret := EnvMail(cAssunto, cMsg, cPara, "", cAnexo)
Else
	 //ConOut("Nao ha dados! - WFNTRIA.PRW")

Endif

  //RESET ENVIRONMENT

Return




Static Function queryMain()

 Local _aDados := {}
 Local cLinha := Chr(13) + Chr(10)
 Local cData:= dtos(date()-90)

if Select("TMPOP")<>0
	dbselectarea("TMPOP")
	dbclosearea()
Endif

cQuery := ""

/*
cQuery :="	SELECT NFOR.DH_FILIAL AS FILIALFOR, NFOR.DH_ITEM AS ITEMFOR, NFOR.DH_OPER AS OPERFOR,NFOR.DH_DOC AS DOCFOR, NFOR.DH_SERIE AS SERIEFOR, NFOR.DH_CLIENTE AS CLIENTEFOR, NFOR.DH_LOJACLI AS LOJACLIFOR, NFOR.DH_IDENTNF AS IDENTFOR, 	"+cLinha
cQuery +="		NFOR.D1_DOC AS DOCFOR, NFOR.D1_SERIE AS SERIEFOR, NFOR.D1_FORNECE AS FORNECEFOR, NFOR.D1_LOJA AS LOJAFOR, NFOR.D1_COD AS CODFOR, NFOR.D1_QUANT AS QUANTFOR, NFOR.D1_UM AS UMFOR, NFOR.D1_VUNIT AS VUNITFOR, NFOR.D1_TOTAL AS TOTALFOR, NFOR.D1_LOTECTL AS LOTECTLFOR, NFOR.D1_DTVALID DTVALIDFOR, NFOR.D1_FORNECE AS FORNECEFOR, NFOR.D1_LOJA AS LOJAFOR,NFOR.D1_DTDIGIT AS DTDIGITFOR,	"+cLinha
cQuery +="		NCLI.DH_FILIAL AS FILIALCLI, NCLI.DH_ITEM AS ITEMCLI, NCLI.DH_OPER AS OPERCLI,NCLI.DH_DOC AS DOCCLI, NCLI.DH_SERIE AS SERIECLI, NCLI.DH_CLIENTE AS CLIENTECLI, NCLI.DH_LOJACLI AS LOJACLI, NCLI.DH_IDENTNF AS IDENTCLI, 	"+cLinha
cQuery +="		NCLI.D1_DOC AS DOCCLI, NCLI.D1_SERIE AS SERIECLI, NCLI.D1_FORNECE AS FORNCECLI, NCLI.D1_LOJA AS LOJACLI, NCLI.D1_COD AS CODCLI, NCLI.D1_QUANT AS QUANTCLI, NCLI.D1_UM AS UMCLI, NCLI.D1_VUNIT AS VUNITCLI, NCLI.D1_TOTAL AS TOTALCLI, NCLI.D1_LOTECTL AS LOTECTLCLI, NCLI.D1_DTVALID AS DTVALIDCLI, NCLI.D1_FORNECE AS FORNECECLI, NCLI.D1_LOJA AS LOJACLI,NCLI.D1_DTDIGIT AS DTDIGITCLI	"+cLinha
*/
cQuery :="	SELECT C2_FILIAL,C2_NUM,C2_ITEM,C2_SEQUEN,C2_PRODUTO,C2_LOCAL,C2_QUANT,C2_QUJE,C2_EMISSAO,C2_DATPRF  "+cLinha
cQuery +="	FROM "+RetSqlName("SC2")+" "+cLinha
cQuery +="	WHERE D_E_L_E_T_=' '  "+cLinha
cQuery +="	AND  C2_DATPRF>='"+cData+"' "+cLinha
cQuery +="	AND C2_DATRF=' ' "+cLinha
cQuery +="	AND C2_FILIAL='"+xFilial("SC2")+"' "+cLinha
cQuery +="	ORDER BY C2_FILIAL,C2_NUM,C2_ITEM,C2_SEQUEN "+cLinha

TcQuery cQuery NEW ALIAS "TMPOP"



If TMPOP->(EOF())
   //ConOut("WFOPATRA.PRW : A Query nao retornou dados..")
Endif

While !(TMPOP->(EOF()))
	aAdd(_aDados,{TMPOP->C2_FILIAL,;
			AllTrim(TMPOP->C2_NUM),	;
			AllTrim(TMPOP->C2_ITEM),	;
			AllTrim(TMPOP->C2_SEQUEN),	;
			AllTrim(TMPOP->C2_PRODUTO),	;
			AllTrim(TMPOP->C2_LOCAL),	;
			AllTrim(Str(TMPOP->C2_QUANT)),		;
			AllTrim(Str(TMPOP->C2_QUJE)), 		;
			dtoc(stod(TMPOP->C2_EMISSAO)),	;
			dtoc(stod(TMPOP->C2_DATPRF))})

	TMPOP->(dbSkip())
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
	   //	Alert("Não foi possivel autenticar a conta - " + _cUsuario2)	//É melhor a mensagem aparecer para o usuário do que no console ou no log.txt - Poliester
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



Return lResult
