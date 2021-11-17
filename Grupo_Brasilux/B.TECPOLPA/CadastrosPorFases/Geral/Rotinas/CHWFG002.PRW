#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"


/**
CHWFG002 - Esta rotina monta um html com os campos que devem ser
preenchidos pelos usuarios da proxima etapa do cadastro de cliente e fornecedor.									  ?±±
**/


User Function CHWFG002( )

	//Local 	nRecno    := 0
	Local 	nI        := 0
	//Local 	nX        := 0

	//Local 	nB        := 0
	Local 	nF        := 0
	Local 	nP        := 0

	//Poliester Moreira - Chaus - 07/03/2018 - Se não incluir a variável não compila
	Local	nC		  := 0

	Local codProd
	Local 	aRecnoSM0 := {}
	Local _lATIVARP := SUPERGETMV("CF_ATIVARP", .F. , .F.)
	Local _lATIVARC := SUPERGETMV("CF_ATIVARC", .F. , .F.)
	Local _lATIVARF := SUPERGETMV("CF_ATIVARF", .F. , .F.)
	Local _cETAPAP :=  GetMv("CF_ETAPAP")
	Local _cETAPAC :=  GetMv("CF_ETAPAC")
	Local _cETAPAF :=  GetMv("CF_ETAPAF")
	//Local 	_tipoCad  := ""
	Private cQLinha   := Chr(13) + Chr(10)
	Private nomeFonte := "CHWFG002"



	RpcSetType(3)
	RpcSetEnv("11","11")

	DbSelectArea("SM0")
	DbGotop()

	While !Eof()

		If AllTrim(SM0->M0_CODIGO) == "11"
			Aadd(aRecnoSM0,{Recno(),SM0->M0_CODIGO, SM0->M0_CODFIL})
		Endif

		DbSkip()
	EndDo

	For nI := 1 To Len(aRecnoSM0)
		SM0->(dbGoto(aRecnoSM0[nI,1]))
		_codEmp := SM0->M0_CODIGO
		_codFil := SM0->M0_CODFIL
		RpcClearEnv()
		RpcSetEnv(_codEmp,_codFil)
		//Conout("for " + Str(nI))
        //LGS#20200214 - Adequação de release 12.1.25 e posteriores
		//If  SUPERGETMV("CF_ATIVARP", .F. , .F.)
		If _lATIVARP
			//For nP := 1 to Val(GetMv("CF_ETAPAP")) - 1
			For nP := 1 to Val( _cETAPAP ) - 1
				codProd := queryP(nP)
				Workflow(_codEmp,_codFil, codProd, "P",  AllTrim(Str(nP)), "Produto"  )
			Next nP
		Endif
        //LGS#20200214 - Adequação de release 12.1.25 e posteriores
		//If  SUPERGETMV("CF_ATIVARF", .F. , .F.)
		If _lATIVARF
			//For nF := 1 to Val(GetMv("CF_ETAPAF")) - 1
			For nF := 1 to Val( _cETAPAF ) - 1
				codFor := queryF(nF)
				Workflow(_codEmp,_codFil, codFor, "F",  AllTrim(Str(nF)), "Fornecedor" )
			Next nF
		Endif
        //LGS#20200214 - Adequação de release 12.1.25 e posteriores
		//If  SUPERGETMV("CF_ATIVARC", .F. , .F.)
		If _lATIVARC
			//For nC := 1 to Val(GetMv("CF_ETAPAC")) - 1
			For nC := 1 to Val( _cETAPAC ) - 1
				codCli := queryC(nC)
				Workflow(_codEmp,_codFil, codCli, "C",  AllTrim(Str(nC)), "Cliente" )
			Next nF
		Endif



	 // retirar para enviar para todas filiais
		DbSkip()


	Next nI




Return


Static Function Workflow( _codEmp,_codFil, _cProduto,_CodTipo, _CodEtapa, _tipoCad)
	//Local dData   	:=DATE()


	Local cAssunto	:= "WorkFlow cadastro de "+ _tipoCad + /*", codigo "+_cProduto+ */ ". Empresa "+_codEmp+ " Filial "+AllTrim(_codFil)+". Data: "+DTOC(DDataBase)

	Local cTitulo 	:= "Cadastro de "+ _tipoCad

	//Local cMsgCorpo	:= " " //Explicação WF

	Local cMsg		:= ""
	Local cAnexo	:= ""
	//Local nCont     := 0
	//Local cQuery    := ""
	Local i, x
    Local _cURLLGWF := GETMV("CF_URLLGWF")  //LGS#20200214 - Adequação de release 12.1.25 e posteriores
    Local _cCORWF   := GETMV("CF_CORWF")
	Local _aItens,_aTitulos, _aTamCol, _aMascara

	If Empty( _cProduto)
		Return
	Endif

	cQLinha :=  Chr(13) + Chr(10)


//prepare environment empresa _emp filial _fil
//LGS#20200214 - Adequação de release 12.1.25 e posteriores
	//ConOut("Inicio do fonte "+nomeFonte+".prw")
    FwLogMSG( "INFO", , 'SIGAPCP', funname(), '', '01', "Inicio do fonte "+nomeFonte+".prw", 0 )

// MV_XCH0002
	cPara := ""


	cPara := query01(_CodTipo, _CodEtapa) //(_CodTipo, _CodEtapa)
//cPara := "dyegofigueiredo@gmail.com"

	_aArrays := queryMain(_CodTipo, _CodEtapa)

	_aItens 	:= _aArrays[1]
	_aTitulos  	:= _aArrays[2]
	_aTamCol 	:= _aArrays[3]
	_aMascara 	:= _aArrays[4]

	If Len(_aItens) > 0

		/**		Monta o script HTML para ser enviado por email 	**/
		cMsg:="<html>"
		cMsg+="<head> 					"
		cMsg+="<STYLE TYPE='text/css'> 	"
		cMsg+="<!--     				"
		cMsg+="TD{font-family: Calibri; font-size: 7pt;} "
		cMsg+="--->     				"
		cMsg+="</STYLE> 				"
		cMsg+="</head>  				"
		cMsg+="<body>					"

		cMsg+="<table  border=1 cellpadding=0 width='100%' style='border:none'>"
		cMsg+="<tr>"
		cMsg+="<td width='20%' style='border:none'><img   width='180px' height='45px' id='_x0000_i1033'"
		//LGS#20200214 - Adequação de release 12.1.25 e posteriores
		//cMsg+="		src='"+Alltrim(GETMV("CF_URLLGWF"))+"'  alt='http://www.chaus.com.br/'></td>"
		cMsg+="		src='"+Alltrim( _cURLLGWF )+"'  alt='http://www.chaus.com.br/'></td>"
		cMsg+="<td width='80%'><p align=center><b><span style=' text-align:center;font-size:16.0px;font-weight:bold;font-family:Calibri;color:#000000'>"+cTitulo+"</span></b></p></td>"
		cMsg+="</td></table>"

		cMsg+="<table>"
		cMsg+="<p><font align = 'right' color='Black' size='2' face='Verdana'>Prezado, favor dar prosseguimento no cadastro de "+ _tipoCad +", referente ao(s) código(s) :"+_cProduto+". <br>Devem ser preenchidos os seguintes campos:  </font><br>"
		cMsg+="</table>"

		cMsg+="<br>"

	//	Filial, numero sc, item sc, dt necessidade, emissao, codigo produto, produto, qtd, solicitante
		cMsg+="<table  BORDER=1 width='100%' height='92'  style='border-collapse:collapse;border:none;mso-border-alt:solid black .5pt;'>"
		cMsg+="<tr  BGCOLOR='#000000'>" //D2DDD4' 8B8682

	//Alimenta os titulos
		For x := 1 to Len(_aTitulos)
			cMsg+="<th  style='font-size:13.0px;font-family:Calibri;color:#FFFAFA'  scope='col'><b>"+_aTitulos[x]+"</th>"  //FFFAFA 8B8682
		Next x

		cMsg+="</tr>"


		_dados := .F.


		For  i:=1 to Len(_aItens)

			_dados := .T.

			If i % 2 == 1
				//cMsg+="<tr  BGCOLOR='"+Alltrim( GETMV("CF_CORWF") )+"'>"  // #99FF99
				cMsg+="<tr  BGCOLOR='"+Alltrim( _cCORWF )+"'>"  // #99FF99
			Else
				cMsg+="<tr>"
			Endif

			For x := 1 to Len(_aTitulos)
				cMsg+="<td   style='font-size:13.0px;font-family:Calibri' >"+Transform(_aItens[i][x], _aMascara[x])+"</td>"
			Next x

			cMsg+="</tr>"

		Next i

		If !_dados
			//ConOut("Nao ha dados! - "+nomeFonte+".PRW")
			Return
		Endif

  	//cMsg+="<p><b></font><font color='Black' size='2' face='Verdana'> "+cMsgCorpo+" </font></b><br>"



		cMsg+="</table>"

		cMsg+="<table>"
		cMsg+="<p><font align = 'right' color='Black' size='1' face='Verdana'>Desenvolvido por: <a href='http://www.chaus.com.br'>Chaus <img   width='20px' height='20px'  id='_x0000_i1034'		src='https://pbs.twimg.com/profile_images/1444443565/avatartwitter_400x400.png'  alt='http://www.chaus.com.br'></a> </font><br>"
		cMsg+="</table>"

		cMsg+="</body>"
		cMsg+="</html>"

		_ret := u_CHROTG09(cAssunto, cMsg, cPara, "", cAnexo)

	Endif


Return



// monta a query do workflow
Static Function queryMain(_CodTipo, _CodEtapa)

	Local _aItens 	:= {}
	Local _aTitulos := {}
	Local _aTamCol 	:= {}
	Local _aMascara := {}
	Local i, _cCampos, aCampos
	//Local cQuery


	_cCampos := ""
	DbSelectArea("SZP")
	SZP->(DbSetOrder(2)) // ZP_FILIAL, ZP_CAD, ZP_CODRET, R_E_C_N_O_, D_E_L_E_T_

	If SZP->(DBSeek(xFilial("SZP")+ _CodTipo + _CodEtapa)  )
		_cCampos += SZP->ZP_CAMPOS1 + ';' + SZP->ZP_CAMPOS2   + ';'

	Endif


	iVar := Replace(_cCampos, ",", ";")
	iVar := Replace(iVar, ".", ";")
	iVar := Replace(iVar, "-", ";")

	iVar := Replace(iVar, " ", "")

	aCampos := Separa(iVar,";",.T.)

	_cTitulo :=   ""
	For i:= 1 to Len(aCampos)


		DbSelectArea("SX3")
		SX3->(DbSetOrder(2))
		If SX3->(DbSeek( aCampos[i])) .and. !Empty(AllTrim(aCampos[i]))

			aadd(_aItens,{aCampos[i],	SX3->(X3_TITULO) })

		Endif



	Next i



	_aTitulos := 	{"Campo", 	"Titulo"}
	_aTamCol  :=  	{100,		100}
	_aMascara := 	{"@!", 		"@!"}


Return {_aItens,_aTitulos, _aTamCol, _aMascara }



// Retorna os destinatarios
Static Function query01(_CodTipo, _CodEtapa)

	//Local _aItens 	:= {}
	//Local _aTitulos := {}
	//Local _aTamCol 	:= {}
	//Local _aMascara := {}
	Local cQuery

	If Select("TMPWF")<>0
		dbselectarea("TMPWF")
		dbclosearea()
	Endif


	cQuery := "SELECT ZQ_USER		  				"+cQLinha
	cQuery += " 									"+cQLinha
	cQuery += "FROM "+RetSqlName("SZQ")+"	 ZQ  	"+cQLinha
	cQuery += " 									"+cQLinha
	cQuery += "WHERE D_E_L_E_T_ = ' '  		   		"+cQLinha
	cQuery += "	AND ZQ_TIPO = '"+_CodTipo+"'  		"+cQLinha
	cQuery += "	AND ZQ_CODET = '"+_CodEtapa+"' 	   	"+cQLinha
	cQuery += " AND ZQ_FILIAL = '"+xFilial("SZQ")+"'"+cQLinha

	//conout(cQuery)

// UsrRetName(WFCodUser("Admin")) )
// UsrRetMail(WFCodUser("CHAUS"))

	TCQUERY cQuery ALIAS TMPWF NEW
	dbSelectArea("TMPWF")
	dbGoTop()

	If TMPWF->(EOF())
		//ConOut("A Query nao retornou dados - fonte "+nomeFonte+".prw")
	Endif

	_cRet := ""
	While !EOF()
	//aadd(_aItens,{UsrRetName(TMPWF->CAMPO1), UsrRetName(TMPWF->CAMPO2) })
		_cRet +=  UsrRetMail(TMPWF->ZQ_USER)  + ";"
		dbSkip()
	EndDo


Return _cRet



// Retorna os produtos parados na etapa passada por parametro
Static Function queryP(_CodEtapa)

	//Local _aItens 	:= {}
	//Local _aTitulos := {}
	//Local _aTamCol 	:= {}
	//Local _aMascara := {}
	Local cQuery

	If Select("TMPWF")<>0
		dbselectarea("TMPWF")
		dbclosearea()
	Endif


	cQuery := "SELECT B1_COD,B1_DESC	 			"+cQLinha
	cQuery += " 									"+cQLinha
	cQuery += "FROM "+RetSqlName("SB1")+"	 SB1  	"+cQLinha
	cQuery += " 									"+cQLinha
	cQuery += "WHERE D_E_L_E_T_ = ' '  		   		"+cQLinha
	cQuery += "	AND B1_XCETAPA 	= '"+AllTrim(Str(_CodEtapa))+"' 	"+cQLinha
	cQuery += " AND B1_FILIAL 	= '"+xFilial("SB1")+"'"+cQLinha

// UsrRetName(WFCodUser("Admin")) )
// UsrRetMail(WFCodUser("CHAUS"))

	TCQUERY cQuery ALIAS TMPWF NEW
	dbSelectArea("TMPWF")
	dbGoTop()

	If TMPWF->(EOF())
		//ConOut("A Query nao retornou dados - fonte "+nomeFonte+".prw")
	Endif

	_cRet := ""
	While !EOF()
	//aadd(_aItens,{UsrRetName(TMPWF->CAMPO1), UsrRetName(TMPWF->CAMPO2) })
		_cRet +=  "<br>&#8227; " +AllTrim(TMPWF->B1_COD)  + " - " + AllTrim(B1_DESC) + " "
		dbSkip()
	EndDo


Return _cRet

// Retorna os clientes parados na etapa passada por parametro
Static Function queryC(_CodEtapa)

	//Local _aItens 	:= {}
	//Local _aTitulos := {}
	//Local _aTamCol 	:= {}
	//Local _aMascara := {}
	Local cQuery

	If Select("TMPWF")<>0
		dbselectarea("TMPWF")
		dbclosearea()
	Endif


	cQuery := "SELECT A1_COD, A1_NOME, A1_LOJA	 	"+cQLinha
	cQuery += " 									"+cQLinha
	cQuery += "FROM "+RetSqlName("SA1")+"	 SA1  	"+cQLinha
	cQuery += " 									"+cQLinha
	cQuery += "WHERE D_E_L_E_T_ = ' '  		   		"+cQLinha
	cQuery += "	AND A1_XCETAPA 	= '"+AllTrim(Str(_CodEtapa))+"' 	"+cQLinha
	cQuery += " AND A1_FILIAL 	= '"+xFilial("SA1")+"'"+cQLinha

// UsrRetName(WFCodUser("Admin")) )
// UsrRetMail(WFCodUser("CHAUS"))

	TCQUERY cQuery ALIAS TMPWF NEW
	dbSelectArea("TMPWF")
	dbGoTop()

	If TMPWF->(EOF())
		//ConOut("A Query nao retornou dados - fonte "+nomeFonte+".prw")
	Endif

	_cRet := ""
	While !EOF()
	//aadd(_aItens,{UsrRetName(TMPWF->CAMPO1), UsrRetName(TMPWF->CAMPO2) })
		_cRet +=  "<br> &#8227; " +AllTrim(TMPWF->A1_COD)+ "/" + A1_LOJA    + " - " + AllTrim(A1_NOME) + " "
		dbSkip()
	EndDo


Return _cRet

// Retorna os fornecedor parados na etapa passada por parametro
Static Function queryF(_CodEtapa)

	//Local _aItens 	:= {}
	//Local _aTitulos := {}
	//Local _aTamCol 	:= {}
	//Local _aMascara := {}
	Local cQuery

	If Select("TMPWF")<>0
		dbselectarea("TMPWF")
		dbclosearea()
	Endif


	cQuery := "SELECT A2_COD, A2_NOME, A2_LOJA	 	"+cQLinha
	cQuery += " 									"+cQLinha
	cQuery += "FROM "+RetSqlName("SA2")+"	 SA2  	"+cQLinha
	cQuery += " 									"+cQLinha
	cQuery += "WHERE D_E_L_E_T_ = ' '  		   		"+cQLinha
	cQuery += "	AND A2_XCETAPA 	= '"+AllTrim(Str(_CodEtapa))+"' 	"+cQLinha
	cQuery += " AND A2_FILIAL 	= '"+xFilial("SA2")+"'"+cQLinha

// UsrRetName(WFCodUser("Admin")) )
// UsrRetMail(WFCodUser("CHAUS"))

	TCQUERY cQuery ALIAS TMPWF NEW
	dbSelectArea("TMPWF")
	dbGoTop()

	If TMPWF->(EOF())
		//ConOut("A Query nao retornou dados - fonte "+nomeFonte+".prw")
	Endif

	_cRet := ""
	While !EOF()
	//aadd(_aItens,{UsrRetName(TMPWF->CAMPO1), UsrRetName(TMPWF->CAMPO2) })
		_cRet +=  "<br>&#8227; " +AllTrim(TMPWF->A2_COD)+ "/" + A2_LOJA    + " - " + AllTrim(A2_NOME) + " "
		dbSkip()
	EndDo


Return _cRet
