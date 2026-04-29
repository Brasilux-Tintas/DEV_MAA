#include "Protheus.ch"
#include "rwmake.ch"
#include "totvs.ch"
#include "Topconn.ch"

#DEFINE SALTALINHA	chr(10)+chr(13)				// Salta linha em campos memo

/*/{Protheus.doc} User Function IncSCBTB
    Função para gerar SC do processo de BTB após o PV
    @type User Function
    @author Celso Rondinelli
    @since 09/05/22
    @version 1
    @param _NumPVWS,_sDataPV,_IDCli,nValorT,_Empresa,_EnderEnt,_CEPEnt,_PaisEnt,aItPvWS
    @return lRet
/*/

User Function IncSCBTB(_NumPVWS,aItPvWS,_cCodPV)
	Local aCabSC := {}
	Local aItensSC := {}
	Local aLinhaC1 := {}
	Local cCodTrat := ""
	Local nX := 0
	Local iX := 0
	Local n := 0
	Local cDoc := ""
	Local _cCodsc :=space(6)
	Local _cFor := ""
	Local _cLjFor := ""
	Local _cOri := ""
	Local _cCodPed := _cCodPV
	Private lMsHelpAuto := .T.
	Private lMsErroAuto := .F.
	Private aItErr := {}
	Private lC5Pos := .F.

	//Posiciona SC5 para coleta de informações para a SC

	aAreaC5 := SC5->(FwGetArea())
	dbSelectArea("SC5")
	dbSetOrder(1)
	If SC5->(MsSeek(FwxFilial("SC5")+_cCodPV))
		lC5Pos := .T.
	Else
		lC5Pos := .F.
	EndIf
	For iX := 1 to Len(aItPVWS)
		cSql := ""
		cCodTrat := AllTrim(trataCod(aItPVWS[iX,4]))
		cSql := "SELECT B1_COD FROM "+RetSqlName("SB1")+" WHERE B1_COD = '"+cCodTrat+"' AND D_E_L_E_T_ = ''"
		TcQuery cSql NEW ALIAS "QB1"
		If !Empty(QB1->B1_COD)
			lValIt := .T.
			QB1->(dbCloseArea())
		Else
			lValIt := .F.
			aAdd(aItErr,aItPVWS[iX,4])
			QB1->(dbCloseArea())
		EndIf
	Next iX
	If lValIt
		cDoc := GetSXENum("SC1","C1_NUM")
		SC1->(dbSetOrder(1))
		While SC1->(dbSeek(xFilial("SC1")+cDoc))
			ConfirmSX8()
			cDoc := GetSXENum("SC1","C1_NUM")
		EndDo
		aadd(aCabSC,{"C1_NUM" ,cDoc})
		aadd(aCabSC,{"C1_SOLICIT",AllTrim(UsrRetName(RetCodUsr()))})
		aadd(aCabSC,{"C1_EMISSAO",dDataBase})
		//Itens do Array da SC
		aLinhaC1 := aItPVWS
		_cMemObs := "SC de geração automática Webshop:"+SALTALINHA
		_cMemObs += "Referencia del Comercial: PV"+AllTrim(_cCodPed)+SALTALINHA
		_cMemObs += "Referencia Cliente: "+_NumPVWS + SALTALINHA
		_cMemObs += "Sucursal: "+FwxFilial("SC1")+" - UY"+SALTALINHA
		_cMemObs += "Tipo de exportacion:  BTB"+SALTALINHA
		//chamar tela complementar
		_cTxtAd := ""
		_cTxtAd += telComInv()
		_cMemObs += _cTxtAd
		For nX := 1 To Len(aLinhaC1)
			_aLinha := {}
			Do Case
			Case "germany" $ aLinhaC1[nX,7]
				_cFor := "000765"
				_cLjFor := "01"
				_cOri := "AG"
			Case "china" $ aLinhaC1[nX,7]
				_cFor := "000521"
				_cLjFor := "01"
				_cOri := "CH"
			Case "China" $ aLinhaC1[nX,7]
				_cFor := "000521"
				_cLjFor := "01"
				_cOri := "CH"
			Case "usa" $ aLinhaC1[nX,7]
				_cFor := "000659"
				_cLjFor := "01"
				_cOri := "US"
			Case "africa" $ aLinhaC1[nX,7]
				_cFor := "000619"
				_cLjFor := "01"
				_cOri := "AF"
			Case Empty(aLinhaC1[nX,7])
				_cFor := "000765"
				_cLjFor := "01"
				_cOri := "AG"
			Case "Germany" $ aLinhaC1[nX,7]
				_cFor := "000765"
				_cLjFor := "01"
				_cOri := "AG"
			EndCase
			aadd(_aLinha,{"C1_ITEM" ,StrZero(nX,len(SC1->C1_ITEM)),Nil})
			aadd(_aLinha,{"C1_PRODUTO",trataCod(aLinhaC1[nX,4]),Nil})
			aadd(_aLinha,{"C1_XUM",aLinhaC1[nX,5],Nil})
			aadd(_aLinha,{"C1_XQTDVEN",Val(aLinhaC1[nX,3]),Nil})
			aadd(_aLinha,{"C1_XPRECO",1,Nil})
			aadd(_aLinha,{"C1_CONTA","1.130.1.00.0001",Nil})
			aadd(_aLinha,{"C1_XFINALI","4",Nil})
			aadd(_aLinha,{"C1_CC","9.999",Nil})
			aadd(_aLinha,{"C1_FORNECE",_cFor, Nil})
			aadd(_aLinha,{"C1_LOJA",_cLjFor, Nil})
			aadd(_aLinha,{"C1_XORIGEM",_cOri, Nil})
			aadd(_aLinha,{"C1_ITEMCTA","999999999",Nil})
			aadd(_aLinha,{"C1_XLOCENT","784", Nil})
			aadd(_aLinha,{"C1_EC08DB","999999",Nil})
			aadd(_aLinha,{"C1_LOCAL","0103",Nil})
			aadd(_aLinha,{"C1_XOBS1",_cMemObs, Nil})
			aadd(_aLinha,{"C1_PEDRES",_cCodPV, Nil})
			aadd(aItensSC,_aLinha)
		Next nX
		//Validar se a função abaixo funciona corretamente
		aCabSC := FWVetByDic(aCabSC, "SC1",.F.)
		aItensSC := FWVetByDic(aItensSC, "SC1",.T.)
		MSExecAuto({|x,y| mata110(x,y)},aCabSC,aItensSC)
		If !lMsErroAuto
			MsgBox("Solicitação de compras :"+cDoc+", criado com sucesso!","[WEBSHOP]","INFO")
			_cCodsc := cDoc //SC1->C1_NUM
			aAreaZZG := ZZG->(GetArea())
			dbSelectArea("ZZG")
			dbSetOrder(1)
			If (dbSeek(FwxFilial("ZZG")+_NumPVWS))
				RecLock("ZZG",.F.)
				ZZG_SC := _cCodsc
				MsUnlock()
			EndIf
			RestArea(aAreaZZG)
		Else
			MsgBox("Ocorreu erro na geração da solicitação de compras, SC não foi criada","[WEBSHOP]","ALERT")
			DisarmTransaction() // Libera sequencial RollBackSx8()
			cLogErr := MostraErro()
			MemoWrite("\magento\log_geraScERPIt.log",cLogErr)
			u_zMsgLog(cLogErr, "Erro na Integração do Pedido Magento", 1, .F.)
		EndIf
		aRetSC1 := SC1->(GetArea())
	Else
		cLogErr := "Item(ns) Invalido(s)" + Chr(13)
		For n := 1 to Len(aItErr)
			cLogErr += "Item "+StrZero(n,2)+" -> "+aItErr[n]+" não localizado no cadastro" + Chr(13)
		Next n
		MsgBox(cLogErr,"[WEBSHOP]","ALERT")
		MemoWrite("\magento\log_geraScERPIt.log",cLogErr)
		u_zMsgLog(cLogErr, "Erro na Integração do Pedido Magento", 1, .F.)
	EndIf
Return _cCodsc
/**************************************************************************************************************************/
Static Function trataCod(cCodOri)
	Local cCodTrat As Character
	Local nPosTr As Numeric
	cCodTrat := ""
	nPosTr := 0
	nPosTr := At("-",cCodOri)
	If nPosTr > 0
		cCodTrat := Substr(cCodOri,1,nPosTr - 1)
	Else
		cCodTrat := AllTrim(cCodOri)
	EndIf
Return cCodTrat
/************************************************************************************************************************/
Static Function telComInv()
	Local cRet As Character
	Local cNomCli, cModEmb, cIncot, cTpHBL, cPrcEsp As Character
	Local aRadios As Array
	Local nRad1, nRad2, nRad3 As Numeric
	Private oDlg, oGet1, oGet2, oGet3, oGet4, oGet5, oRadio1, oRadio2, oRadio3, oRadio4
	nRad1 := 1
	nRad2 := 1
	nRad3 := 1
	aRadios := {"Si","No"}
	cRet := ""
	cNomCli := Iif(lC5Pos,Posicione("SA1",1,FwxFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME"),"")
	cModEmb := Space(150)
	cIncot := Space(150)
	cCerCal := ""
	cEmbPar := ""
	cTpHBL := Space(150)
	cPrcEsp := Space(150)
	DEFINE MSDIALOG oDlg FROM 0,0 TO 380,690 PIXEL TITLE "Información adicional COMEX"
	@ 10,10 SAY "Nombre del Cliente: " OF oDlg PIXEL  //cNomCli
	oGet1:= TGet():New(10,120,,oDlg,150,10,"@!",,,,,,,.T.,,,,,,,,,,"cNomCli")
	@ 10,120 MSGET oGet1 VAR cNomCli SIZE 150,10 OF oDlg PIXEL
	@ 25,10 SAY "Modalidad del Embarque: " OF oDlg PIXEL  //cModEmb
	oGet2:= TGet():New(25,120,,oDlg,150,10,"@!",,,,,,,.T.,,,,,,,,,,"cModEmb")
	@ 25,120 MSGET oGet2 VAR cModEmb SIZE 150,10 OF oDlg PIXEL
	@ 40,10 SAY "Inconterm: " OF oDlg PIXEL  //cIncot
	oGet3:= TGet():New(40,120,,oDlg,150,10,"@!",,,,,,,.T.,,,,,,,,,,"cInCot")
	@ 40,120 MSGET oGet3 VAR cInCot SIZE 150,10 OF oDlg PIXEL
	@ 55,10 SAY "Solicitar Certificado de Calidad: " OF oDlg PIXEL //cCerCal Si-No
	oRadio1:= TRadMenu():New(55,120,aRadios,,oDlg,,,,,,,,20,10,,,,.T.)
	oRadio1:bSetGet := {|u|Iif (PCount()==0,nRad1,nRad1:=u)}
	@ 80,10 SAY "Puede embarcar parcial: " OF oDlg PIXEL //cEmbPar Si-No
	oRadio2:= TRadMenu():New(80,120,aRadios,,oDlg,,,,,,,,20,10,,,,.T.)
	oRadio2:bSetGet := {|u|Iif (PCount()==0,nRad2,nRad2:=u)}
	@ 105,10 SAY "Tipo de HBL - Fisico o Express Release: " OF oDlg PIXEL //cTpHBL
	oGet4:= TGet():New(105,120,,oDlg,150,10,"@!",,,,,,,.T.,,,,,,,,,,"cTpHBL")
	@ 105,120 MSGET oGet4 VAR cTpHBL SIZE 150,10 OF oDlg PIXEL
	@ 120,10 SAY "Se necessita un procedimento especial: " OF oDlg PIXEL // cPrcEsp Si-No
	oRadio3:= TRadMenu():New(120,120,aRadios,,oDlg,,,,,,,,20,10,,,,.T.)
	oRadio3:bSetGet := {|u|Iif (PCount()==0,nRad3,nRad3:=u)}
	@ 145,10 SAY "Procedimento especial: " OF oDlg PIXEL //cPrcEsp
	oGet5:= TGet():New(145,120,,oDlg,150,10,"@!",,,,,,,.T.,,,,,,,,,,"cPrcEsp")
	@ 145,120 MSGET oGet5 VAR cPrcEsp SIZE 150,10 OF oDlg PIXEL
	@ 170,80 BUTTON oButton PROMPT "Confirmar" OF oDlg PIXEL ACTION cRet := u_geracRet(nRad1,nRad2,nRad3,cNomCli,cModEmb,cIncot,cTpHBL,cPrcEsp,oDlg) //oDlg:End()
	@ 170,180 BUTTON oButton PROMPT "Abandona" OF oDlg PIXEL ACTION oDlg:End()
	oDlg:lEscClose := .F. // desabilita a tecla ESCape pra fechar a janela.
	ACTIVATE MSDIALOG oDlg CENTERED
Return cRet
/**********************************************************************************************************************************/
User Function geracRet(nRad1,nRad2,nRad3,cNomCli,cModEmb,cIncot,cTpHBL,cPrcEsp,oDlg)
	Local cRet := ""
	cRet := "Nombre del Cliente: "+AllTrim(cNomCli)+chr(10)+chr(13)
	cRet += "Modalidad del Embarque: "+AllTrim(cModEmb)+chr(10)+chr(13)
	cRet += "Inconterm: "+AllTrim(cInCOt)+chr(10)+chr(13)
	cRet += "Solicitar Certificado de Calidad: "+Iif(nRad1==1,"Si","No")+chr(10)+chr(13)
	cRet += "Puede embarcar parcial: "+Iif(nRad2==1,"Si","No")+chr(10)+chr(13)
	cRet += "Tipo de HBL - Fisico o Express Release: "+AllTrim(cTpHBL)+chr(10)+chr(13)
	cRet += "Se necessita un procedimento especial: "+Iif(nRad3==1,"Si","No")+chr(10)+chr(13)
	If nRad3 <> 1
		cRet += "Procedimento especial: "+AllTrim(cPrcEsp)+chr(10)+chr(13)
	EndIf
	oDlg:End()
Return cRet
