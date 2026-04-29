#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'INKEY.CH'
#INCLUDE 'vkey.CH'
//------- acrescentado por Jose 14/09/2022  -----------------------

#INCLUDE "Avprint.ch"
#include 'totvs.ch'

#Define STR_PULA    Chr(13)+Chr(10)

Static _zConta    :=0

/*/
{Protheus.doc} BRFATX66
FunÁ„o que cria arquivo de FWMsExcel
@author jOSE ULIANA
@since 13/09/2022
@version 1.0
@example_cPerg
u_BRFATX66()
/*/

//------------  AtÈ aqui  14/09/2022   -------------------

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥ BRFATX66  ≥ Autor ≥ AndrÈ Maester      ≥ Data ≥ /07/2015≥ ±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Montagem / Desmontagem de Pallets (Linha de Montagem Exp)  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥              ≥ 17/07/15≥ Inclus„o da Rotina, montagem de pallets por  ≥±±
±±≥                bordero de pedidos.									  ≥±±
±±≥              ≥  /  /  ≥                                               ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
User Function BRFATX66()

	Private cGet1Env   := Space(11) //"      /    "	// Pallet
	Private cGet2Env   := Space(06)				    // Bordero
	Private cGet3Env   := "     .  .   -  "    // Produto
	Private cSay1Env   := Space(01)
	Private cSay2Env   := Space(01)
	Private cSay4Env   := Space(20)
	Private cSay3Env   := Space(30)
	Private cSay5Env   := Space(30)
	Private nCapPallet := 0
	Private nCapAntPal := 0
	Private nCount     := 0
	Private lProdMist  :=.f.
	Private nCBox1Co   := ""
	Private nCBox1Lo   := Space(04)
	Private cCor4Env   := 0
	Private cPallet    := ""
	Private cMaxSeq    := ""
	Private _CodProd   := ""
	Private _cMaxSeq   := ""
	Private nQtdTotal  := 0
	Private cCodBarra  := ""
	Private lJaFech    := .f.
	Private lTelaJaFechada := .f.
	Private lCheck     := .t.
	Private cRotina    := "BRFATX66"
	Private cCodUsr    := RetCodUsr()
	Private cAcessos   := Posicione("SZW", 4, xFilial("SZW")+cRotina+__cUserID+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2), "ZW_ACESSOS")
	Private oTempTbl1
	Private _ZPPAR0118 := GetMV( "ZP_PAR0118" ) // Libera Bloqueio de Lotes

	Private nTipoBor   := "0"  // jose 19/09/2023
	Private oBrowser as Object // Jose 11/06/2024

	/*ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
    ±± DeclaraÁ„o de Variaveis Private dos Objetos                             ±±
	Ÿ±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*/
	SetPrvt("oFontEnv", "oDlg1Env", "oGrp1Env", "oSay1Env", "oSay2Env", "oGet1Env", "oGet2Env", "oBtn1Env", "oBtn2Env")
	SetPrvt("oBtn3Env", "oBtn4Env", "oBtn5Env", "oBtn6Env", "oBrw1Env", "oGrp3Env", "oBtn7Env", "oBtn8Env", "oBtn9Env")
	SetPrvt("oSay4Env", "oBtn6Env", "oSay3Env", "oSay5Env", "oCBox1"  , "oBtnAEnv", "oBtnBEnv", "oSay6Env", "oSay7Env")
	SetPrvt("oBtnCEnv", "oSay8Env","oSay2Loc" ,"oCBox1Lo")
	// oCBox2
	If !u_VldAcesso(funname())
		If __cUserID <> "003134" //MAA
			MsgBox("Acesso n„o autorizado!---->"+funname(),"AtenÁ„o","Alert")
			Return
		End
	Endif

	/*ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
    ±± Definicao do Dialog e todos os seus componentes.                        ±±
	Ÿ±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*/
	oFontEnv   := TFont():New( "MS Sans Serif", 0, -19, , .F., 0, , 400, .F., .F., , , , , , )
	oFon2Env   := TFont():New( "Courier New"  , 0,  19, , .T., 0, , 400, .F., .F., , , , , , )
	oFon3Env   := TFont():New( "Courier New"  , 0,  25, , .T., 0, , 400, .F., .F., , , , , , )

	oDlg1Env   := MSDialog():New( 140, 264, 680, 980, "Monta Compra", , , .F., , , , , , .T., , , .T. )
	oGrp1Env   := TGroup():New( 003, 004, 048, 356, "Dados do Pallet", oDlg1Env, CLR_RED, CLR_WHITE, .T., .F. )
	oSay1Env   := TSay():New( 012, 008, { || "Pallet:"}, oGrp1Env, , oFontEnv, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 040, 012)
	oGet1Env   := TGet():New( 010, 064, { |u| If(PCount() > 0, cGet1Env := u, cGet1Env)}, oGrp1Env, 080, 014, '@!' , , CLR_BLACK, CLR_WHITE, oFontEnv,   , , .T., "", , , .F., .F., , .F., .F., "", "cGet1Env", , )
	oGet1Env:bLostFocus := {|| Iif(!Empty(Alltrim(cGet1Env)),fCarPall(cGet1Env),"")}

	oSay6Env   := TSay():New( 012, 150, { || "BorderÙ:"}, oGrp1Env, , oFontEnv, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 040, 012)
	oGet2Env   := TGet():New( 010, 200, { |u| If(PCount() > 0, cGet2Env := u, cGet2Env)}, oGrp1Env, 080, 014, '@!' , , CLR_BLACK, CLR_WHITE, oFontEnv,   , , .T., "", , , .F., .F., , .F., .F., "", "cGet2Env", , )

	oCBox1     := TCheckBox():New( 027,210,"Pallet Padr„o",{|u| If(PCount() > 0, lCheck := u, lCheck)},oGrp1Env,080,012,,,oFontEnv,,CLR_BLUE ,CLR_WHITE,,.t.,"Bloqueia Bipe Qdo Ultrapassa Limite",, )

	oBtn3Env   := TButton():New( 028, 008, "Novo Pallet", oGrp1Env, {|| fNPal()}, 052, 016, , oFontEnv, , .T., , "", , , , .F. )
	oGet2Env:bLostFocus := {|| Iif(!Empty(Alltrim(cGet2Env)),fValBord(cGet2Env),"")}

	oSay4Env   := TSay():New( 030, 152, { || cSay4Env  }, oGrp1Env, , oFontEnv, .F., .F., .F., .T., cCor4Env, CLR_WHITE, 106, 012)
	oBtn1Env   := TButton():New( 009, 297, "Confirma", oGrp1Env, {|| fSMntPal()}, 052, 016, , oFontEnv, , .T., , "", , , , .F. )

	oBtn2Env   := TButton():New( 030, 297, "Abandona", oGrp1Env, {|| fSairMPa()}, 052, 016, , oFontEnv, , .T., , "", , , , .F. )
	oGrp2Env   := TGroup():New( 050, 004, 268, 356, "", oDlg1Env, CLR_BLACK, CLR_WHITE, .T., .F. )

	//  oCBox1Lo   := TComboBox():New( 058, 290, {|u| If(PCount() > 0, nCBox1Lo := u, nCBox1Lo)}, {"","FAB1", "FAB2","DEPO"}, 060, 016, oGrp2Env, , , , CLR_BLACK, CLR_WHITE, .T., oFon2Env, "", , , , ,  , , nCBox1Lo ) // Jose 21/09/2024 Substituido pelo de baixo
	//  oCBox1Lo   := TComboBox():New( 058, 290, {|u| If(PCount() > 0, nCBox1Lo := u, nCBox1Lo)}, {"","FAB1","FAB2","ARA","DEPO"}, 060, 016, oGrp2Env, , , , CLR_BLACK, CLR_WHITE, .T., oFon2Env, "", , , , ,  , , nCBox1Lo )   // Jose 10/12/2024 Por SolicitaÁ„o do Mirinho tirado o espaÁo em banco
	oCBox1Lo   := TComboBox():New( 058, 290, {|u| If(PCount() > 0, nCBox1Lo := u, nCBox1Lo)}, {"FAB1","FAB2","ARA","DEPO"}, 060, 016, oGrp2Env, , , , CLR_BLACK, CLR_WHITE, .T., oFon2Env, "", , , , ,  , , nCBox1Lo )


	//	oSay2Loc   := TSay():New( 075, 290, { || "LocalizaÁ„o"}, oGrp2Env, , oFon2Env, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 060, 012)

	oBtn4Env   := TButton():New( 088, 290, "<- Monta     " , oGrp2Env, {|| fMntPallet(1) }, 060, 012, , oFon2Env, , .T., , "", , , , .F. ) // 068
	oBtn5Env   := TButton():New( 105, 290, "<- Desmonta  " , oGrp2Env, {|| fMntPallet(2) }, 060, 012, , oFon2Env, , .T., , "", , , , .F. ) // 088

	oSay7Env   := TSay():New( 120, 338, { || nCount}    , oGrp2Env, , oFon3Env, .F., .F., .F., .T., CLR_RED, CLR_WHITE, 020, 020)
	oSay8Env   := TSay():New( 120, 283, { || "Volumes:"}, oGrp2Env, , oFon3Env, .F., .F., .F., .T., CLR_RED, CLR_WHITE, 050, 020)

	oSay2Env   := TSay():New( 135, 290, { || "Impressora"}, oGrp2Env, , oFon2Env, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 060, 012)
	oCBox1Co   := TComboBox():New( 145, 290, {|u| If(PCount() > 0, nCBox1Co := u, nCBox1Co)}, {"", "ZEBRA S4M", "ZEBRA ZT230"}, 060, 016, oGrp2Env, , , , CLR_BLACK, CLR_WHITE, .T., oFon2Env, "", , , , ,  , , nCBox1Co )

	oBtn6Env   := TButton():New( 165, 290, "<- Imp.Etq ->" , oGrp2Env, {|| fIEtPallet(nCBox1Co) }, 060, 012, , oFon2Env, , .T., , "", , , , .F. )
	oBtn7Env   := TButton():New( 180, 290, "<- Res. Pro->" , oGrp2Env, {|| U_fResPallet(1) }, 060, 012, , oFon2Env, , .T., , "", , , , .F. )
	oBtn9Env   := TButton():New( 195, 290, "<- Res. Emb->" , oGrp2Env, {|| U_fResPallet(2) }, 060, 012, , oFon2Env, , .T., , "", , , , .F. )
	oBtnAEnv   := TButton():New( 210, 290, "<- Res. Grp->" , oGrp2Env, {|| U_fResPallet(3) }, 060, 012, , oFon2Env, , .T., , "", , , , .F. )
	oBtnBEnv   := TButton():New( 225, 290, "<- Rel. Bor->" , oGrp2Env, {|| U_fImpInf()     }, 060, 012, , oFon2Env, , .T., , "", , , , .F. )
	oBtnBEnv   := TButton():New( 240, 290, "<- Rel. Exc->" , oGrp2Env, {|| U_fImpExc(nTipoBor) }, 060, 012, , oFon2Env, , .T., , "", , , , .F. )
	oBtnCEnv   := TButton():New( 255, 310, "Destruir"      , oGrp2Env, {|| fDelPallet()    }, 040, 012, , oFon2Env, , .T., , "", , , , .F. )

	oSay3Env   := TSay():New( 038, 076, { || cSay3Env  },   oGrp1Env, , oFon2Env, .F., .F., .F., .T., CLR_RED, CLR_WHITE, 240, 012)
	oSay5Env   := TSay():New( 042, 076, { || cSay5Env  },   oGrp1Env, , oFon2Env, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 240, 012)

	oTblIPall()
	DbSelectArea("TMPITE")
	DbSetOrder(1)
	DbGoTop()
	oBrw1Env   := MsSelect():New( "TMPITE", "", "", { {"TMPPRO", "", "Produto", "@R XX 99.99.999-99"}, {"TMPSEQ", "", "Sequ.", "@!"}, {"TMPLOT", "", "Lote   ", "@R X99999"}, { "TMPQTD", "", "Quantidade", "@E 999,999"} , {"TMPPED", "", "Pedido", "@E 999999"}, {"TMPCBR", "", "Cod. Barras", "@R X99999999999999999"}  }, .F., , {056, 007, 266, 280}, , , oGrp2Env ) // Jose 07/03/2025  "Lote   ", "@E 999999" "Cod. Barras", "@E 999999999999999999"

	oBrw1Env:oBrowse:oFont          := oFon2Env
	oBrw1Env:oBrowse:lAdjustColSize := .t.
	oBrw1Env:oBrowse:Refresh()
	oBtn3Env:SetFocus()

	oDlg1Env:Activate(,,,.T.)

	If !lJaFech
		lTelaJaFechada := .t.
		fSairMPa()
	Endif
	oTempTbl1:Delete()

Return


/*ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
Function  ≥ fSMntPal()  Salvar Dados das Tabelas Tempor·rias - Bot„o Confirmar Tela Principal
ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*/
Static Function fSMntPal()

	If Empty(Alltrim(cGet1Env)) .or.  Empty(Alltrim(cGet2Env))
		Return
	Endif

	DbSelectArea("ZZJ")
	DbSetOrder(1)
	DbSeek(xFilial("ZZJ")+cGet1Env, .t.)
	If Found()
		If ZZJ->ZZJ_FLAG == "4"
			Messagebox("N„o È possÌvel alterar este Pallet, pois j· foi transformado em pedido de transferÍncia !","AtenÁ„o...",48)
			DbSelectArea("ZZJ")
			DbClosearea()
			Return
		Endif
	Endif

	Begin Transaction

		DbSelectArea("TMPITE")
		DbSetOrder(1)
		DbGoTop()
		If Eof()
			DbSelectArea("ZZJ")
			DbSetOrder(1)
			DbSeek(xFilial("ZZJ")+cGet1Env, .t.)
			If Found() .and. (xFilial("ZZJ") == ZZJ->ZZJ_FILIAL) .and. (Alltrim(cGet1Env) == Alltrim(ZZJ->ZZJ_CODIGO))
				RecLock("ZZJ", .F.)
				DbDelete()
				MsUnlock()
				CGet1Env := Space(11)
			Endif
		Else
			DbSelectArea("ZZJ")
			DbSetOrder(1)
			DbSeek(xFilial("ZZJ")+cGet1Env, .t.)
			If  cGet1Env <> ''  // Jose 14/09/2023
				If Found() .and. (xFilial("ZZJ") == ZZJ->ZZJ_FILIAL) .and. (Alltrim(cGet1Env) == Alltrim(ZZJ->ZZJ_CODIGO))
					If ZZJ->ZZJ_FLAG $ '3'
						RecLock("ZZJ", .f.)
						ZZJ->ZZJ_DTFIM  := Date()
						ZZJ->ZZJ_HFIM   := SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)
						ZZJ->ZZJ_TIPBOR := Posicione("SZF", 1, xFilial("SZF")+cGet2Env, "ZF_TIPOBOR")
						MsUnLock()
					Endif
				Endif
			Else // jose 14/09/2023
				// jose 14/09/2023
				If Found() .and. (xFilial("ZZJ") == ZZJ->ZZJ_FILIAL)
					If ZZJ->ZZJ_FLAG $ '3'
						RecLock("ZZJ", .f.)
						ZZJ->ZZJ_DTFIM  := Date()
						ZZJ->ZZJ_HFIM   := SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)
						ZZJ->ZZJ_TIPBOR := Posicione("SZF", 1, xFilial("SZF")+cGet2Env, "ZF_TIPOBOR")
						MsUnLock()
					Endif
				Endif
			EndIf
			//---------------------------------------------------

		Endif

	End Transaction

	If ChkFile("TMPITE")
		DbSelectArea("TMPITE")
		DbGotop()
		//Zap
		//LGS#20191029 - Substituido comando ZAP devido a utilizaÁ„o de funÁ„o do banco.
		TCSqlExec("DELETE FROM " + oTempTbl1:GetRealName() )
	Endif
	If ChkFile("ZZK")
		DbSelectArea("ZZK")
		DbCloseArea()
	Endif
	If ChkFile("ZZJ")
		DbSelectArea("ZZJ")
		DbCloseArea()
	Endif
	If !lTelaJaFechada
		oBtn3Env:Enable()
		oCBox1Lo:Enable()
	Endif
	If !Empty(Alltrim(cGet1Env))
		fCarPall(cGet1Env)
	Endif

Return

/*ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
Function  ≥ fSairMPa()
ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*/
Static Function fSairMPa()
	//Local lRet

	If !lTelaJaFechada
		oDlg1Env:End()
	Endif
	lJaFech :=.t.

Return


/*ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
Function  ≥ oTblIPall() - Cria temporario para o Alias: TMPITE
ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*/
Static Function oTblIPall()
	Local aFds := {}
	//Local cTmp

	If ChkFile("TMPITE")
		DbSelectArea("TMPITE")
		DbClosearea()
	Endif

	aAdd( aFds , {"TMPINV"  ,"C", 003, 000} )   // ORDEM INVERTIDA
	aAdd( aFds , {"TMPPAL"  ,"C", 011, 000} )   // PALLET
	aAdd( aFds , {"TMPLOT"  ,"C", 006, 000} )   // LOTE
	aAdd( aFds , {"TMPSEQ"  ,"C", 003, 000} )   // SEQUENCIA
	aAdd( aFds , {"TMPPRO"  ,"C", 015, 000} )   // PRODUTO
	aAdd( aFds , {"TMPQTD"  ,"N", 011, 003} )   // QUANTIDADE
	aAdd( aFds , {"TMPCBR"  ,"C", 018, 000} )   // CODIGO DE BARRAS
	aAdd( aFds , {"TMPDEL"  ,"C", 001, 000} )   // DELETADO
	aAdd( aFds , {"TMPPED"  ,"C", 006, 000} )   // PEDIDO

	/********************************************************************************************************************************/
	/*** BLOCO ALTERADO EM 28/10/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZA«√O DE RELEASE PROTHEUS 12.1.25                  ***/

	//cTmp := U_NovoArqTrab("dbf") //CriaTrab( , .F. )
	//DbCreate(cTmp+".dbf", aFds, "DBFCDXADS")
	//Use (cTmp+".Dbf") Alias TMPITE VIA "DBFCDXADS" New Exclusive
	//DbCreateIndex(cTmp+"_1.cdx", "TMPPAL+TMPSEQ"	   , {||"TMPPAL+TMPSEQ"} )
	//DbCreateIndex(cTmp+"_2.cdx", "TMPPAL+TMPPRO+TMPSEQ", {||"TMPPAL+TMPPRO+TMPSEQ"} )
	//DbCreateIndex(cTmp+"_3.cdx", "TMPPAL+TMPINV"       , {||"TMPPAL+TMPINV"} )
	//DbCreateIndex(cTmp+"_4.cdx", "TMPPAL+TMPCBR"	   , {||"TMPPAL+TMPCBR"} )
	//DbCreateIndex(cTmp+"_5.cdx", "TMPCBR"			   , {||"TMPCBR"} )

	//DbClearInd()
	//DbSetIndex(cTmp+"_1")
	//DbSetIndex(cTmp+"_2")
	//DbSetIndex(cTmp+"_3")
	//DbSetIndex(cTmp+"_4")
	//DbSetIndex(cTmp+"_5")
	oTempTbl1 := FWTemporaryTable():New( 'TMPITE' )
	oTempTbl1:SetFields( aFds )
	oTempTbl1:AddIndex( "cInd01", { "TMPPAL", "TMPSEQ"           } )
	oTempTbl1:AddIndex( "cInd02", { "TMPPAL", "TMPPRO", "TMPSEQ" } )
	oTempTbl1:AddIndex( "cInd03", { "TMPPAL", "TMPINV"           } )
	oTempTbl1:AddIndex( "cInd04", { "TMPPAL", "TMPCBR"           } )
	oTempTbl1:AddIndex( "cInd05", { "TMPCBR"                     } )
	oTempTbl1:Create()
	/********************************************************************************************************************************/

	DbSetOrder(1)

Return

/*ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
Function  ≥ fValBord() - Valida BorderÙ de Pedidos digitado a ser separado
ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*/
Static Function fValBord(cNumBord)

	If Empty(Alltrim(cNumBord))
		Return
	Endif
	//cSay3Env := ""
	//cSay5Env := ""
	DbSelectArea("SZF")
	DbSetOrder(1)
	DbSeek(xFilial("SZF")+cNumBord, .t.)
	If !Found()
		Messagebox("BorderÙ de pedido inv·lido, verifique !!!","AtenÁ„o...",48)
		oGet2Env:Setfocus()
		Return
	Else
		If !SZF->ZF_FLAG $ 'D'
			Messagebox("Status do BorderÙ Inv·lido para Compra, Somente È possÌvel comprar com status (Digitado) !!!","AtenÁ„o...",48)
			oGet2Env:Setfocus()
			Return
		Endif
	Endif

	DbSelectArea("SZF")
	DbCloseArea()

	If ChkFile("TMPITE")
		DbSelectArea("TMPITE")
		DbSetorder(1)
		DbGoTop()
	Endif
	oBtn4Env:Setfocus()

Return

Static Function fCarPall(cPallet)

	nCapPallet := 0
	nCapAntPal := 0
	lProdMist  := .f.

	If Empty(Alltrim(cPallet)) .or. (cGet1Env $ "NOVO PALLET")
		Return
	Endif
	If Len(Alltrim(cPallet)) = 10
		cGet1Env  := Substr(cPallet,1,6)+'/'+Substr(cPallet,7,4)
		cPallet := cGet1Env
	Endif
	cSay3Env := ""
	cSay5Env := ""
	If ChkFile("TMPITE")
		DbSelectArea("TMPITE")
		DbGoTop()
		//Zap
		//LGS#20191029 - Substituido comando ZAP devido a utilizaÁ„o de funÁ„o do banco.
		TCSqlExec("DELETE FROM " + oTempTbl1:GetRealName() )
	Endif

	nCount :=0

	cQry1 := ""
	cQry1 += " SELECT ZZK_CODIGO, ZZK_LOTE, ZZK_SEQENV, ZZK_PRODUT, ZZK_QUANT, ZZK_LOCORI, ZZJ_FLAG, ZZK_CODBAR, ZZK_PEDIDO , ZZJ_BORDER, ZZJ_LOCALI "
	cQry1 += " FROM "+RetSqlName("ZZJ")+" ZZJ WITH (NOLOCK) "
	cQry1 += " LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) ON ZZJ_FILIAL = ZZK_FILIAL AND ZZJ_CODIGO = ZZK_CODIGO AND ZZK.D_E_L_E_T_ ='' "
	cQry1 += " WHERE (ZZJ.ZZJ_FILIAL = '"+XFILIAL("ZZJ")+"') "
	cQry1 += "  AND (ZZJ.D_E_L_E_T_ = '') "
	cQry1 += "  AND ZZK.ZZK_CODIGO = '"+cPallet+"' "
	//cQry1 += "  AND (ZZJ_BORDER <> '') "
	cQry1 += " ORDER BY ZZK_CODIGO, ZZK_SEQENV"

	TCQuery cQry1 ALIAS "TCQ" NEW
	//nConOrd := 1
	DbSelectArea("TCQ")
	If !Eof()
		If TCQ->ZZJ_FLAG $ '1.2'
			Messagebox("Tipo de Pallet inv·lido (TransferÍncias Internas), verifique o cÛdigo do Pallet bipado / digitado !!!","AtenÁ„o...",48)
			oGet1Env:Setfocus()
		Else
			cGet2Env:=TCQ->ZZJ_BORDER
			nCBox1Lo:=TCQ->ZZJ_LOCALI
			oCBox1Lo:Enable()
			oCBox1Lo:Refresh()
			oGet2Env:Refresh()
			oBtn3Env:Enable()
			While !Eof()
				nCapPallet := fVerCPall(TCQ->ZZK_PRODUT)
				If nCapPallet <> nCapAntPal .and. (nCapAntPal <> 0) .or. lProdMist
					lProdMist := .t.
					cSay3Env  := "Produtos com capacidade de Pallett misturados"
				Else
					If nCapPallet = 0
						cSay3Env := "Capacidade Total do Pallet ainda n„o cadastrada!"
					Else
						cSay3Env := "Capacidade Total do Pallet"+TransForm(nCapPallet,"@E 9999")+" Volumes "
					Endif
				Endif
				nCapAntPal:= nCapPallet
				oSay3Env:Refresh()

				RecLock("TMPITE", .T.)
				TMPITE->TMPPAL := TCQ->ZZK_CODIGO
				TMPITE->TMPLOT := TCQ->ZZK_LOTE
				TMPITE->TMPSEQ := TCQ->ZZK_SEQENV
				TMPITE->TMPPRO := TCQ->ZZK_PRODUT
				TMPITE->TMPQTD := TCQ->ZZK_QUANT
				TMPITE->TMPCBR := TCQ->ZZK_CODBAR
				TMPITE->TMPINV := Inverte(TCQ->ZZK_SEQENV)
				TMPITE->TMPPED := TCQ->ZZK_PEDIDO
				nCount := (nCount + 1)
				MsUnLock()
				DbSelectArea("TCQ")
				DbSkip()
			Enddo
		Endif
	Else
		Messagebox("Pallet Inexistente, verifique o n˙mero do Pallet digitado / bipado !!!","AtenÁ„o...",48)
		cGet1Env := Space(11)
		nCBox1Lo := Space(04)
		oCBox1Lo:Enable()
		oCbox1Lo:Refresh()
		oBtn3Env:Enable()
		oGet1Env:Setfocus()
	Endif
	DbSelectArea("TCQ")
	DbCloseArea()

	oSay7Env:Refresh()

	If ChkFile("TMPITE")
		DbSelectArea("TMPITE")
		DbGoTop()
		oBrw1Env:oBrowse:GoTop()
		oBrw1Env:oBrowse:Refresh()
	Endif

Return


/*ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
Function  ≥ fIEtPallet() - Impress„o da Etiqueta do Pallet
ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*/
Static Function fIEtPallet(cModelo)

	Local nPeso   := 0
	Local nVolume := 0

	If cGet1Env $ "NOVO PALLET"
		Messagebox("Salve o Pallet antes de Imprimir a etiqueta !!!","AtenÁ„o...",48)
		Return
	Endif
	If Empty(Alltrim(cModelo))
		Messagebox("Escolha o modelo da impressora antes de mandar a impress„o !!!","AtenÁ„o...",48)
		Return
	Endif

	nPeso   := round(u_fPesPallet(cGet1Env),2)
	nVolume := U_fTotUnit(cGet1Env,2)

	If Alltrim(cModelo) $ "ZEBRA S4M"
		cModelo   := "S4M"
	Elseif Alltrim(cModelo) $ "ZEBRA ZT230"
		cModelo   := "ZEBRA"
	Endif
	cPorta    := "LPT1" //Porta da impressora
	nTam      := 120    //Tamanho da etiqueta

	lTipo     := .f.    //.f.=Local; .t.=Servidor ou Outro Servidor
	lDrvWin   := .f.    //Usa Drive do Windows

	MSCBPRINTER(cModelo, cPorta, , nTam, lTipo, , , , , , lDrvWin)

	If !MSCBIsPrinter('LPT1')
		Messagebox("Impressora n„o encontrada!","AtenÁ„o",48)
		MSCBCLOSEPRINTER()
		Return
	Else
		MSCBBEGIN(1, 6, , .f.)
		MSCBSAYBAR(05, 03, StrTran(cGet1Env,"/",""), "N", "MB07", 15, .F., .T., .F., , 3, 2)
		MSCBSay(06,25,"V. "+Alltrim(str(nVolume)) ,"N","0","30,30")
		MSCBSay(30,25,"P. "+Alltrim(str(nPeso))   ,"N","0","30,30")
		MSCBSay(55,25,"B. "+Alltrim(cGet2Env),"N","0","30,30")

		MSCBCHKSTATUS(.f.)
		cText := MSCBEND()
		MSCBCLOSEPRINTER()

		//cArq := 'C:\TEMP\'+strtran(cGet1Env,"/","")+'.ETQ' // PARAR DE GERAR ARQUIVO ETQ NA PASTA C:\TEMP PARA MELHORAR
		//MemoWrit(cArq, cText)                              // A PERFORMANCE DO PROGRAMA QUE IMPRIMI ETIQUETA
		//Type cArq > prn
	Endif
Return


/*ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
Function  ≥ fMntPallet() - ManutenÁ„o dos itens de montagem do Pallet
ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*/

Static Function fMntPallet(nOpcMnt) // 1 - Monta / 2 - Desmonta

	/*ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
    ±± DeclaraÁ„o de cVariable dos componentes                                 ±±
	Ÿ±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*/

	Private cGet1Mnt   := Space(20)
	Private cGet2Mnt   := Space(3)
	Private nGet3Mnt   := 0
	Private nGet7Mnt   := 0
	Private cGet5Mnt   := Space(6)
	Private cGet4Mnt   := Space(30)
	Private cSay1Mnt   := Space(1)
	Private cSay2Mnt   := Space(1)
	Private cSay3Mnt   := Space(1)
	Private cSay4Mnt   := Space(1)
	Private cSay6Mnt   := Space(140)
	Private cGet8Mnt   := Space(06)
	Private nGet9Mnt   := Space(04)
	Private nGetAMnt   := Space(04)

	Private nVolAtual  := 0
	Private lJaBipou   :=.f.

	/*ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
	±± DeclaraÁ„o de Variaveis Private dos Objetos                             ±±
	Ÿ±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*/
	SetPrvt("oFontMn1", "oFontMn2", "oDlg1Mnt", "oSay1Mnt", "oSay4Mnt", "oSay2Mnt", "oSay3Mnt", "oGet1Mnt", "oGet2Mnt")
	SetPrvt("oGet3Mnt", "oBtn2Mnt", "oBtn1Mnt", "oGet4Mnt", "oSay5Mnt", "oGet5Mnt", "oSay6Mnt", "oGet7Mnt", "oGet8Mnt" )
	SetPrvt("oGet9Mnt", "oGetAMnt", "oSay8Mnt", "oSay9Mnt", "oSayAMnt")

	If Empty(Alltrim(cGet1Env))
		Return
	Endif

	If nOpcMnt == 1
		DbSelectArea("ZZJ")
		DbSetOrder(1)
		DbSeek(xFilial("ZZJ")+cGet1Env, .t.)
		If Found() .and. (ZZJ->ZZJ_FILIAL == xFilial("ZZJ")) .and. (ZZJ->ZZJ_BORDER <>'')
			If ZZJ->ZZJ_FLAG == "4"
				Messagebox("Pallet j· transformado em pedido de transferÍncia e n„o pode ser alterado!!","AtenÁ„o...",48)
				Return
			Endif
		Endif
	Endif

	If Empty(Alltrim(cGet2Env))
		Messagebox("Informe o BorderÙ de Pedido que ser· comprado antes de montar/desmontar o Pallet da compra !!","AtenÁ„o...",48)
		Return
	Endif

	If ChkFile("TMPITE")
		DbSelectArea("TMPITE")
		DbGoTop()
		oBrw1Env:oBrowse:GoTop()
		oBrw1Env:oBrowse:Refresh()
	Endif

	/*ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
    ±± Definicao do Dialog e todos os seus componentes.                        ±±
	Ÿ±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*/

	oFontMn1   := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
	oFontMn2   := TFont():New( "MS Sans Serif", 0, -16, , .F., 0, , 400, .F., .F., , , , , , )
	oDlg1Mnt   := MSDialog():New( 258, 252, 400, 897, "ManutenÁ„o da Compra", , , .F., , , , , , .T., , , .T. )
	oSay1Mnt   := TSay():New( 009, 003, {|| "Codigo"   }, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 048, 012)
	oGet1Mnt   := TGet():New( 007, 037, {|u| If(PCount() > 0, cGet1Mnt := u, cGet1Mnt)}, oDlg1Mnt, 073, 012, '@!'              , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .F. , .F., ""   ,"cGet1Mnt", , )
	oSay4Mnt   := TSay():New( 026, 003, {|| "Descr.:"   }, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 048, 012)
	oGet4Mnt   := TGet():New( 025, 037, {|u| If(PCount() > 0, cGet4Mnt := u, cGet4Mnt)}, oDlg1Mnt, 206, 012, '@!'              , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .T. , .F., ""   ,"cGet4Mnt", , )
	oSay5Mnt   := TSay():New( 026, 250, {|| "Lote"     }, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 024, 012)
	oGet5Mnt   := TGet():New( 025, 276, {|u| If(PCount() > 0, cGet5Mnt := u, cGet5Mnt)}, oDlg1Mnt, 024, 012, '@R X99999'       , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .T. , .F., ""   ,"cGet5Mnt", , ) // Jose 07/03/2025 '@R 999999'
	oSay2Mnt   := TSay():New( 009, 120, {|| "Seq"      }, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 024, 012)
	oGet2Mnt   := TGet():New( 007, 143, {|u| If(PCount() > 0, cGet2Mnt := u, cGet2Mnt)}, oDlg1Mnt, 024, 012, '@R 999'          , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .T. , .F., ""   ,"cGet2Mnt", , )
	oSay3Mnt   := TSay():New( 009, 180, {|| "Qtde"     }, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 028, 012)
	oGet3Mnt   := TGet():New( 007, 205, {|u| If(PCount() > 0, nGet3Mnt := u, nGet3Mnt)}, oDlg1Mnt, 024, 012, '@E 999999'       , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .T. , .F., ""   ,"nGet3Mnt", , )
	oSay4Mnt   := TSay():New( 009, 250, {|| "Total"    }, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 028, 012)
	oGet7Mnt   := TGet():New( 007, 276, {|u| If(PCount() > 0, nGet7Mnt := u, nGet7Mnt)}, oDlg1Mnt, 024, 012, '@E 999999'       , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .T. , .F., ""   ,"nGet7Mnt", , )
	oSay6Mnt   := TSay():New( 060, 004, {||  cSay6Mnt}, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 230, 011)
	oSay8Mnt   := TSay():New( 045, 003, {|| "Pedido"    }, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 040, 012)
	oGet8Mnt   := TGet():New( 043, 037, {|u| If(PCount() > 0, cGet8Mnt := u, cGet8Mnt)}, oDlg1Mnt, 042, 012, '@!'              , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .T. , .F., ""   ,"cGet8Mnt", , )
	oSay9Mnt   := TSay():New( 045, 081, {|| "Qtd Pedido"}, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 055, 012)
	oGet9Mnt   := TGet():New( 043, 127, {|u| If(PCount() > 0, nGet9Mnt := u, nGet9Mnt)}, oDlg1Mnt, 034, 012, '@R 9999'         , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .T. , .F.,  ""  ,"nGet9Mnt", , )
	oSayAMnt   := TSay():New( 045, 165, {|| "Separado"  }, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 055, 012)
	oGetAMnt   := TGet():New( 043, 205, {|u| If(PCount() > 0, nGetAMnt := u, nGetAMnt)}, oDlg1Mnt, 034, 012, '@R 9999'         , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .T. , .F., ""   ,"nGetAMnt", , )

	//oBtn1Mnt   := TButton():New( 056, 272, "Confirma", oDlg1Mnt, {|| fManuPal(nOpcMnt)}  , 050, 014, , oFontMn2, , .T., , "", , , , .F. )
	oGet1Mnt:bLostFocus := {|| fValCodPro(nOpcMnt) }
	//oGet2Mnt:bLostFocus := {|| Iif(nOpcMnt == 2, fBusSequ(cGet2Mnt), cGet2Mnt) }
	oGet3Mnt:bLostFocus := {|| (nGet7Mnt := nGet3Mnt) }

	oDlg1Mnt:Activate( , , , .T.)

Return


/*ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
Function  ≥ fValCodPro() - ValidaÁ„o do cÛdigo do produto na manutenÁ„o do Pallet
ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*/

Static Function fValCodPro(nOpcMnt)  //1 - Montagem do Pallet 2- Desmontagem

	Local cQry 		:= ""
	Local nVol 		:= 0
	Local nQtdAtual := 0
	Local nPrazo    := 0
	Local nValida   := 0
	Local aGerEtq   := {}
	Local dDtValida := ""
	Local _nXVALESP := GetMv("MV_XVALESP") //100  //LGS#20200210 - AdequaÁ„o de release 12.1.25 e posteriores
	Local _nXVALIDA := GetMv("MV_XVALIDA") //180  //LGS#20200210 - AdequaÁ„o de release 12.1.25 e posteriores


	/* variaveis criadas por Nelieder em 12/11/2021 */
	/* para impress„o das etiquetas de volume pelo protheus */
	Local cPedido   := ""
	Local cProduto  := ""
	Local _Etinew   := .F. /* variavel que habilita a nova impress„o de etique pelo protheus */

	//Local lProdMist :=.f.

	lJaBipou := .f.
	cCodBarra := Substr(cGet1Mnt,1,18)

	If Empty(Alltrim(cGet1Env)) .or. Empty(Alltrim(cCodBarra))
		Return
	Endif
	DbSelectArea("SZF")
	DbSetOrder(1)
	DbSeek(xFilial("SZF")+cGet2Env, .t.)
	If !Found()
		Messagebox("BorderÙ de pedido inv·lido, verifique !!!","AtenÁ„o...",48)
		oGet1Mnt:SetFocus()
		Return
	Else
		If !SZF->ZF_FLAG $ 'D'
			Messagebox("Status do BorderÙ Inv·lido para Compra, Somente È possÌvel comprar com status (Digitado) !!!","AtenÁ„o...",48)
			oGet1Mnt:SetFocus()
			Return
		Endif
	Endif

	DbSelectArea("SZF")
	DbCloseArea()


	//If !(Len(Alltrim(cCodBarra)) == 12 .or. Len(Alltrim(cCodBarra)) == 14 .or. Len(Alltrim(cCodBarra)) == 18)
	If !(Len(Alltrim(cCodBarra)) == 14 .or. Len(Alltrim(cCodBarra)) == 18)
		Messagebox("Tamanho do cÛdigo de Barras incompatÌvel com os padrıes utilizados (14 ou 18 digitos)!!","Verifique...",48)
		oGet1Mnt:SetFocus()
		Return
	Endif
	If Len(Alltrim(cCodBarra)) == 14 .and. Val(Substr(Alltrim(cCodBarra),9,2)) ==0 .and. nOpcMnt == 1
		Messagebox("Leitura da quantidade do cÛdigo de barras incorreta. Bipe novamente, quantidade zero n„o permitida !!","Verifique...",48)
		oGet1Mnt:SetFocus()
		Return
	Endif
	DbSelectArea("TMPITE")
	DbSetOrder(4)
	DbGoTop()
	DbSeek(cGet1Env+cCodBarra, .F.)
	If Found()
		If nOpcMnt == 1
			nGet7Mnt :=0
			nVol     :=0
			lJaBipou :=.t.
			Messagebox("Produto J¡ foi bipado neste Pallet, verifique !!!","AtenÁ„o...",48)
			cGet1Mnt := PADR(cGet1Mnt,20,' ')
			oGet4Mnt:SetFocus()
			Return
		Endif
	Else
		If nOpcMnt == 2
			Messagebox("Produto n„o foi bipado neste Pallet, portanto n„o È possÌvel retir·-lo!!!","AtenÁ„o...",48)
			Return
		Endif
	Endif

	DbSelectArea("ZZK")
	DbSetOrder(5)
	DbGoTop()
	DbSeek(xFilial("ZZK")+cCodBarra, .t.)
	If Found()
		If nOpcMnt == 1
			DbSelectArea("ZZJ")
			DbSetOrder(1)
			DbSeek(xFilial("ZZJ")+ZZK->ZZK_CODIGO, .t.)
			If Found() .and. ZZJ->ZZJ_FLAG $ '3.4.5' .AND. (TRIM(ZZK->ZZK_PEDIDO) <>'')
				Messagebox("Produto j· digitado em OUTRO PALLET..: "+ZZK->ZZK_CODIGO+" !! Verifique ou faÁa a desmontagem antes de incluir neste Pallet !!","AtenÁ„o...",48)
				DbSelectArea("ZZK")
				DbCloseArea()

				DbSelectArea("ZZJ")
				DbCloseArea()

				oGet1Mnt:SetFocus()
				Return
			Endif
			DbSelectArea("ZZJ")
			DbCloseArea()
		Endif
	Endif

	DbSelectArea("ZZK")
	DbCloseArea()

	If Len(Alltrim(cCodBarra)) == 18
		DbSelectArea("SB1")
		DbSetOrder(5)
		DbSeek(xFilial("SB1")+Substr(cGet1Mnt,1,12), .t.)
		If Found()
			If SB1->B1_MSBLQL <> '1'
				//If SB1->B1_TIPO $ 'PA'
				cGet5Mnt := '999999'//Substr(cGet1Mnt,1,6)
				cGet1Mnt := (SB1->B1_COD)
				//Endif
			Else
				Messagebox("Produto bloqueado, verifique!!!","AtenÁ„o...",48)
				oGet1Mnt:SetFocus()
				cGet1Mnt := space(20)
				oGet1Mnt:Refresh()
				cGet4Mnt := space(30)
				oGet4Mnt:Refresh()
				cGet2Mnt := space(3)
				oGet2Mnt:Refresh()
				nGet3Mnt := 0
				oGet3Mnt:Refresh()
				nGet7Mnt := 0
				oGet7Mnt:Refresh()
				cGet5Mnt := space(6)
				oGet5Mnt:Refresh()
				cGet8Mnt:= space(6)
				oGet8Mnt:Refresh()
				nGet9Mnt:=space(4)
				oGet9Mnt:Refresh()
				nGetAMnt:=space(4)
				oGetAMnt:Refresh()
				Return
			Endif
		Endif
		DbSelectArea("SB1")
		DbCloseArea()
	Else
		DbSelectArea("SC2")
		DbSetOrder(13)
		DbSeek(xFilial("SC2")+Alltrim(Substr(cGet1Mnt,1,6)), .t.)
		If Found()
			While !(SC2->(Eof())) .AND. (XFilial("SC2") == SC2->C2_FILIAL) .AND. (Substr(cGet1Mnt,1,6) == Alltrim(SC2->C2_LOTE))
				If Substr(cGet1Mnt,7,2) == Substr(SC2->C2_PRODUTO,11,2)
					cGet5Mnt := Substr(cGet1Mnt,1,6)
					cGet1Mnt := (SC2->C2_PRODUTO)
					If Empty(SC2->C2_DATRF) .AND. (SC2->C2_QUJE = 0)	// disparar workflow chamado
						Messagebox("Produto bipado, porÈm n„o existe nenhuma baixa do produto nesta o.p, entre em contato com o PCP !!","AtenÁ„o...",48)
						cAuxMens := "Produto bipado sem nenhuma baixa na ordem de produÁ„o de PA. "+chr(13)+chr(10)

						cAuxMens +="Lote.........: "+(SC2->C2_LOTE)+chr(13)+chr(10)
						cAuxMens +="Produto......: "+SC2->C2_PRODUTO+chr(13)+chr(10)
						cAuxMens +=" "+chr(13)+chr(10)
						cAuxMens += chr(13)+chr(10)+"Prog. Origem : BRFATX66"

						If Substr(SC2->C2_FILIAL,1,2)== "06"
							//U_EnvMail("DISSOLTEX - Lote "+SC2->C2_LOTE+" j· esta sendo comprado e a O.P ainda n„o foi baixada !",cAuxMens,silene@brasilux.com.br","")
						Else
							U_EnvMail("BRASILUX - Lote "+SC2->C2_LOTE+" j· esta sendo comprado e a O.P ainda n„o foi baixada !",cAuxMens,"pcp@brasilux.com.br","")
						Endif
					Endif
					dDtValida:= u_ValidProd(SC2->C2_LOTE,SC2->C2_PRODUTO)
					nPrazo   := (dDtValida - dDataBase)

					If u_ValMesesPro(SC2->C2_PRODUTO) <= 6   // funÁ„o que retorna validade em meses do produto
						//LGS#20200210 - AdequaÁ„o de release 12.1.25 e posteriores
						//nValida := GetMv("MV_XVALESP") //100
						nValida := _nXVALESP
					Else
						//LGS#20200210 - AdequaÁ„o de release 12.1.25 e posteriores
						//nValida := GetMv("MV_XVALIDA") //180
						nValida := _nXVALIDA
					Endif
					If nPrazo <= nValida
						Messagebox("Produto bipado vencer· em "+cValtoChar(nPrazo)+" dias e portanto n„o poder· ser comprado, entre em contato com o Supervisor  !!","AtenÁ„o...",48)
						cAuxMens := "Produto bipado vencer· em "+cValtoChar(nPrazo)+" dias e portanto n„o poder· ser comprado !"+chr(13)+chr(10)

						cAuxMens +="Lote...............:  "+(SC2->C2_LOTE)+chr(13)+chr(10)
						cAuxMens +="Produto............:  "+SC2->C2_PRODUTO+chr(13)+chr(10)
						cAuxMens +="Validade...........:  "+DToc(dDtValida)+chr(13)+chr(10)
						cAuxMens +="MÌnimo em dias.....:  "+cValToChar(nValida)+chr(13)+chr(10)

						cAuxMens +=" "+chr(13)+chr(10)
						cAuxMens += chr(13)+chr(10)+"Prog. Origem : BRFATX66"

						If Substr(SC2->C2_FILIAL,1,2)== "06"
							//U_EnvMail("DISSOLTEX - Lote "+SC2->C2_LOTE+" com data inferior ao mÌnimo exigido para envio !",cAuxMens,silene@brasilux.com.br","")
						Else
							U_EnvMail("BRASILUX - Lote "+SC2->C2_LOTE+" com data inferior ao mÌnimo exigido para envio !",cAuxMens,"pcp@brasilux.com.br,expedicao@brasilux.com.br","")
						Endif
						cGet1Mnt:= PADR(cGet1Mnt,20,' ')

						DbSelectArea("SC2")
						DbCloseArea()
						Return
					Endif
				Endif
				DbSelectArea("SC2")
				DbSkip()
			Enddo
			DbSelectArea("SC2")
			DbCloseArea()
		Else
			DbSelectArea("SC2")
			DbCloseArea()
			cGet1Mnt:= PADR(cGet1Mnt,20,' ')
			Messagebox("Lote lido/digitado n„o existe, verifique !!!","AtenÁ„o...",48)
			//oGet1Mnt:SetFocus()
			Return
		Endif
	Endif

	If Alltrim(cGet1Mnt) == Alltrim(cCodBarra) // Se o cÛdigo de barras n„o for traduzido para cÛdigo de produto
		cGet1Mnt:= PADR(cGet1Mnt,20,' ')
		Messagebox("CÛdigo de barras inv·lido ou op n„o apontada ou inexistente, verifique !!!","AtenÁ„o...",48)
		//oGet1Mnt:SetFocus()
		Return
	Endif
	/*---  Jose 26/12/2024   inibido por solicitaÁ„o do AndrÈ -------------------------------------------------------------
    If nOpcMnt = 1
		// COMPRAR PRIMEIRO PEGANDO A MENOR QUANTIDADE E DEPOIS A SEQUENCIA DO PEDIDO MAIS ANTIGO
		cQry :=" SELECT TOP 1 C6_NUM, C6_PRODUTO, B1_DESC, ( SELECT dbo.DetVol(C6_FILIAL,C6_PRODUTO) )  AS 'VOL', B1_TIPO, B1_RELVOL, C6_QTDVEN, ISNULL(SUM(ZZK_QUANT),0) AS ZZK_QUANT, 'FALTA' =(ISNULL(SUM(ZZK_QUANT),0) - C6_QTDVEN), " //, Z1_DESCRE
        cQry +="'VOLUME' = ( ( ISNULL ( SUM ( ZZK_QUANT ),0 ) - C6_QTDVEN ) / ( SELECT dbo.DetVol ( C6_FILIAL,C6_PRODUTO ) ) * -1)"
		cQry +=" FROM "+RetSqlName("SZG")+" SZG WITH(NOLOCK) "
		cQry +=" LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH(NOLOCK) ON (ZG_FILIAL  = C6_FILIAL) AND (SUBSTRING(ZG_PEDIDO,3,6) = C6_NUM) AND (SC6.D_E_L_E_T_ ='') "
		cQry +=" LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH(NOLOCK) ON (ZZK_FILIAL = C6_FILIAL) AND (ZZK_PRODUT = C6_PRODUTO) AND (ZZK_PEDIDO = C6_NUM) AND (ZZK.D_E_L_E_T_ ='') "
		cQry +=" LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON (C6_FILIAL  = B1_FILIAL) AND (C6_PRODUTO = B1_COD) AND (SB1.D_E_L_E_T_ ='') "
		cQry +=" LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH(NOLOCK) ON (F4_FILIAL  ='"+XFilial("SF4")+"') AND (F4_CODIGO = C6_TES) AND (SF4.D_E_L_E_T_ ='') "
		cQry +=" WHERE SZG.D_E_L_E_T_ ='' "
		cQry +=" AND ZG_FILIAL ='"+XFilial("SZG")+"' "
		cQry +=" AND ZG_CODIGO ='"+Alltrim(cGet2Env)+"' "
		cQry +=" AND C6_PRODUTO ='"+Alltrim(cGet1Mnt)+"' "
		cQry +=" AND F4_ESTOQUE ='S' "
		If GetMv("MV_XBIPFAT") == .F.
			cQry +=" AND C6_NOTA ='' "
		Endif
		cQry +=" GROUP BY C6_NUM, C6_PRODUTO, C6_QTDVEN, B1_DESC, B1_TIPO, C6_FILIAL, B1_RELVOL"
		cQry +=" HAVING ISNULL(SUM(ZZK_QUANT),0) < C6_QTDVEN "
		cQry +=" ORDER BY FALTA DESC, C6_NUM "
	----   Jose atÈ aqui 26/12/2024 -----------------------------------------------------------------------*/
	//   Acrescentado Jose 26/12/2024     por solicitaÁ„o do AndrÈ ------------------------------------------
	If nOpcMnt = 1
		// COMPRAR PRIMEIRO PEGANDO A MENOR QUANTIDADE E DEPOIS A SEQUENCIA DO PEDIDO MAIS ANTIGO
		cQry :=" SELECT TOP 1 C6_FILIAL, C6_NUM, C6_PRODUTO, B1_DESC, ( SELECT dbo.DetVol(C6_FILIAL,C6_PRODUTO) )  AS 'VOL', B1_TIPO, B1_RELVOL, C6_QTDVEN, ISNULL(SUM(ZZK_QUANT),0) AS ZZK_QUANT, 'FALTA' =(ISNULL(SUM(ZZK_QUANT),0) - C6_QTDVEN), " //, Z1_DESCRE
		cQry +="'VOLUME' = ( ( ISNULL ( SUM ( ZZK_QUANT ),0 ) - C6_QTDVEN ) / ( SELECT dbo.DetVol ( C6_FILIAL,C6_PRODUTO ) ) * -1) , C6_LOCAL, ISNULL(C9_BLEST,'') AS C9_BLEST, "
		cQry +=" C9_BLOQ = (SELECT COUNT(C9_ITEM) FROM "+RetSqlName("SC9")+" SC9 WITH(NOLOCK) WHERE (C9_FILIAL  = C6_FILIAL) AND (C9_PEDIDO = C6_NUM) AND (SC9.D_E_L_E_T_ ='')  AND (C9_BLEST ='02') ), "
		cQry +=" TEMSC9  = (SELECT COUNT(*) FROM "+RetSqlName("SC9")+" SC9 WITH(NOLOCK) WHERE (C9_FILIAL  = C6_FILIAL) AND (C9_PEDIDO = C6_NUM) AND (SC9.D_E_L_E_T_ ='') ) "
		cQry +=" FROM "+RetSqlName("SZG")+" SZG WITH(NOLOCK) "
		cQry +=" LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH(NOLOCK) ON (ZG_FILIAL  = C6_FILIAL) AND (SUBSTRING(ZG_PEDIDO,3,6) = C6_NUM) AND (SC6.D_E_L_E_T_ ='') "
		cQry +=" LEFT OUTER JOIN "+RetSqlName("SC9")+" SC9 WITH(NOLOCK) ON (C6_FILIAL = C9_FILIAL) AND (C9_PEDIDO = C6_NUM) AND (C9_PRODUTO = C6_PRODUTO) AND (C9_ITEM = C6_ITEM) AND SC9.D_E_L_E_T_ ='' "
		cQry +=" LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH(NOLOCK) ON (ZZK_FILIAL = C6_FILIAL) AND (ZZK_PRODUT = C6_PRODUTO) AND (ZZK_PEDIDO = C6_NUM) AND (ZZK.D_E_L_E_T_ ='') "
		cQry +=" LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON (C6_FILIAL  = B1_FILIAL) AND (C6_PRODUTO = B1_COD) AND (SB1.D_E_L_E_T_ ='') "
		//      cQry +=" LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH(NOLOCK) ON (F4_FILIAL  ='"+XFilial("SF4")+"') AND (F4_CODIGO = C6_TES) AND (SF4.D_E_L_E_T_ ='') " JOSE 25/04/2025
		cQry +=" LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH(NOLOCK) ON (F4_CODIGO = C6_TES) AND (SF4.D_E_L_E_T_ ='') " //  JOSE 25/04/2025
		cQry +=" WHERE SZG.D_E_L_E_T_ ='' "
		cQry +=" AND ZG_FILIAL ='"+XFilial("SZG")+"' "
		cQry +=" AND ZG_CODIGO ='"+Alltrim(cGet2Env)+"' "
		cQry +=" AND C6_PRODUTO ='"+Alltrim(cGet1Mnt)+"' "
		cQry +=" AND F4_ESTOQUE ='S' "
		If GetMv("MV_XBIPFAT") == .F.
			cQry +=" AND C6_NOTA ='' "
		Endif
		cQry +=" GROUP BY C6_NUM, C6_PRODUTO, C6_QTDVEN, B1_DESC, B1_TIPO, C6_FILIAL, B1_RELVOL, C6_LOCAL, C9_BLEST"
		cQry +=" HAVING ISNULL(SUM(ZZK_QUANT),0) < C6_QTDVEN "
		//cQry +=" ORDER BY FALTA DESC, C6_NUM "

		TCQuery cQry ALIAS "TCQ1" NEW
		DbSelectArea("TCQ1")
		If !(TCQ1->(Eof()))
			/*    If nCBox1Lo $ 'ARA' .AND. TCQ1->C6_LOCAL <>'A3'
                Messagebox("Pedido( "+TCQ1->C6_NUM+" ) n„o pode ser separado nesta unidade (LOCAL de separaÁ„o ou ALMOXARIFADO inv·lido!  Verifique com o Planejamento LogÌstico !!","AtenÁ„o...",48)
                DbSelectArea("TCQ1")
                DbCloseArea()
                Return
			Elseif nCBox1Lo $ 'DEPO' .AND. TCQ1->C6_LOCAL <>'G3'
                Messagebox("Pedido( "+TCQ1->C6_NUM+" ) n„o pode ser separado nesta unidade (LOCAL de separaÁ„o ou ALMOXARIFADO inv·lido!  Verifique com o Planejamento LogÌstico !!","AtenÁ„o...",48)
                DbSelectArea("TCQ1")
                DbCloseArea()
                Return
			Endif*/
			If GetMv("ZP_PAR0332") // verificar se o pedido que esta sendo separado esta bloqueado por estoque
				If TCQ1->TEMSC9 == 0
					Messagebox("Pedido( "+TCQ1->C6_NUM+" ) n„o pode ser separado pois N√O tem itens COM estoque liberado!  Verifique com o Planejamento LogÌstico !!","AtenÁ„o...",48)
					DbSelectArea("TCQ1")
					DbCloseArea()
					Return
				Elseif TCQ1->C9_BLOQ >0
					Messagebox("O pedido( "+TCQ1->C6_NUM+" ) n„o pode ser separado pois esta SEM liberaÁ„o de estoque!  Verifique com o Planejamento LogÌstico !!","AtenÁ„o...",48)
					DbSelectArea("TCQ1")
					DbCloseArea()
					Return
				Endif
			Endif
			If TCQ1->C9_BLEST ='02'
				Messagebox("O produto ( "+C6_PRODUTO+" )+ ref ao pedido( "+TCQ1->C6_NUM+" ) n„o pode ser separado pois esta SEM liberaÁ„o de estoque!  Verifique com o Planejamento LogÌstico !!","AtenÁ„o...",48)
				DbSelectArea("TCQ1")
				DbCloseArea()
				Return
			Endif

			//  Jose 26/12/2024  AtÈ aqui ---------------------------------------------------------------------------

			If TCQ1->B1_TIPO $ 'PA.PI.MP.MC'
				If ChkFile("TCR")
					DbSelectArea("TCR")
					DbCloseArea()
				Endif
				cQry := " "
				cQry += " SELECT RELVOL = dbo.DetVol('"+xFilial("SB1")+"','"+(cGet1Mnt)+"')"
				TCQuery cQry ALIAS "TCR" NEW
				DbSelectArea("TCR")
				If Len(Alltrim(cCodBarra)) == 14 // etiquetas novas j· trazem a relaÁ„o de volumes
					nGet3Mnt := Val(Substr(Alltrim(cCodBarra),9,2))
					If Val(TCR->RELVOL) < (nGet3Mnt)
						Messagebox("Quantidade bipada / digitada na etiqueta È maior do que volume cadastrado para o produto !!","AtenÁ„o...",48)
						If ChkFile("TCR")
							DbSelectArea("TCR")
							DbCloseArea()
						Endif
						DbSelectArea("TCQ1")
						DbCloseArea()
						Return
					Endif
				Else
					//cQry := " "
					//cQry += " SELECT RELVOL = dbo.DetVol('"+xFilial("SB1")+"','"+(cGet1Mnt)+"')"
					//TCQuery cQry ALIAS "TCR" NEW
					nGet3Mnt := Val(TCR->RELVOL)
				Endif

				nGet7Mnt  := (nGet7Mnt + nGet3Mnt) // Soma no Total a quantidade bipada
				nVol 	  := (nGet7Mnt/nGet3Mnt)
				_CodProd   := cGet1Mnt
				nCapPallet := fVerCPall(_CodProd)
				cGet2Mnt   := MaxSequ()
				cGet4Mnt   := TCQ1->B1_DESC
				cGet8Mnt   := TCQ1->C6_NUM
				nGet9Mnt   := TCQ1->C6_QTDVEN
				nGetAMnt   := (TCQ1->ZZK_QUANT + nGet3Mnt) // j· separado + quantidade bipada
				If nGetAMnt > nGet9Mnt  // se quantidade + bipe atual ultrapassa qtde total do pedido (caso dos proutos que tem mais de uma relaÁ„o de volume)
					Messagebox("Quantidade no volume bipado ultrapassa a total do pedido. Total Pedido( "+TransForm(nGet9Mnt,"@E 9999")+" ) !!, Verifique !!","AtenÁ„o...",48)
					oGet1Mnt:SetFocus()
					cSay6Mnt  := TransForm((nGetAMnt-nGet9Mnt), "@E 9999")+" unidades a mais, verifique a rel. de volumes !"
					nGet7Mnt  := (nGet7Mnt - nGet3Mnt) // subtrair total
					DbSelectArea("TCQ1")
					DbCloseArea()
					Return
				Endif
				If nCapPallet <> nCapAntPal .and. (nCapAntPal <> 0) .or. lProdMist
					lProdMist := .t.
					cSay3Env  := "Produtos com capacidade de Pallett misturados"
				Else
					If nCapPallet = 0
						cSay3Env := "Capacidade Total do Pallet ainda n„o cadastrada!"
					Else
						cSay3Env := "Capacidade Total do Pallet "+TransForm(nCapPallet,"@E 9999")+" Volumes"
						If lCheck
							If (nCount + 1) > nCapPallet
								Messagebox("Capacidade do Pallet j· foi atingida, n„o È possÌvel incluir mais produtos neste Pallet !!!","AtenÁ„o...",48)
								If ChkFile("TCR")
									DbSelectArea("TCR")
									DbCloseArea()
								Endif
								DbSelectArea("TCQ1")
								DbCloseArea()

								DbSelectArea("TMPITE")
								DbSetOrder(1)
								DbGoTop()

								oGet1Mnt:SetFocus()
								Return
							Endif
						Endif
					Endif
				Endif

				nCount    := (nCount + 1)
				nCapAntPal:= nCapPallet
				oSay7Env:Refresh()
				oSay3Env:Refresh()
				oGet1Mnt:SetFocus()
				cSay6Mnt  := "MONTAGEM - VOL. BIPADOS..:  "+Alltrim(TransForm(nCount, "@E 9999"))+Iif(nCapPallet <>0 .and. !lProdMist,"  RESTANDO ..: "+TransForm((nCapPallet-nCount),"@E 9999")," ")
				If ChkFile("TCR")
					DbSelectArea("TCR")
					DbCloseArea()
				Endif

				//Nelieder - 21/07/23 Bloqueio de Lote
				If BLQLOTE(cGet5Mnt)
					oSay7Env:Refresh()
					oSay3Env:Refresh()
					oGet1Mnt:SetFocus()
					DbSelectArea("TCQ1")
					DbCloseArea()
					return()
				EndIf


				Begin Transaction
					If cGet1Env $ "NOVO PALLET"  // gravar o n˙mero do pallet na primeira inclus„o do produto
						fGrvNPal()
					Endif
					DbSelectArea("TMPITE")
					RecLock("TMPITE", .T.)
					TMPITE->TMPPAL := (cGet1Env)
					TMPITE->TMPPRO := cGet1Mnt
					TMPITE->TMPSEQ := cGet2Mnt
					TMPITE->TMPQTD := nGet3Mnt
					TMPITE->TMPLOT := cGet5Mnt
					TMPITE->TMPCBR := (cCodBarra)
					TMPITE->TMPPED := cGet8Mnt
					TMPITE->TMPINV := Inverte(TMPITE->TMPSEQ)
					cGet1Mnt 	   := Space(20)
					cGet1Mnt       := PADR(TMPITE->TMPPRO,20,' ')
					MsUnLock()
					DbSelectArea("ZZK")
					DbSetOrder(5)
					DbGoTop()
					DbSeek(xFilial("ZZK")+TMPITE->TMPCBR, .t.)
					If !Found() .OR. (Found() .AND. ALLTRIM(ZZK->ZZK_CODIGO) # ALLTRIM(TMPITE->TMPPAL))
						RecLock("ZZK", .T.)
						ZZK->ZZK_FILIAL := xFilial("ZZK")
						ZZK->ZZK_CODIGO := TMPITE->TMPPAL
						ZZK->ZZK_LOTE   := TMPITE->TMPLOT
						ZZK->ZZK_SEQENV := TMPITE->TMPSEQ
						ZZK->ZZK_PRODUT := TMPITE->TMPPRO
						ZZK->ZZK_QUANT  := TMPITE->TMPQTD
						ZZK->ZZK_CODBAR := TMPITE->TMPCBR
						ZZK->ZZK_DATA   := Date()
						ZZK->ZZK_HORA   := SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)
						ZZK->ZZK_FLAG   := '1'
						ZZK->ZZK_PEDIDO := TMPITE->TMPPED
						MsUnLock()
					Endif
					aadd(aGerEtq, {cGet8Mnt+' '+cGet1Mnt})

					//***********************************************************************************/
					//*** BRASILUX
					//*** 12/11/2021 - Nelieder Corneta - AdequaÁ„o para impress„o de Etiquetas de volume
					//***								  pelo protheus (excluindo agente)

					cPedido = cGet8Mnt /* pega valor do pedido */
					cProduto = cGet1Mnt /* pega valor do produto */

					/* pega valor do paramentro para habilitar a impress„o pelo protheus */
					_Etinew := GETMV("ZP_PAR0033")
					if _Etinew == .F.
						FGerEtq(aGerEtq) /* usa impress„o por agende */
					else
						U_BRPCP032(cPedido,cProduto) /* usa impress„o pelo protheus */
					Endif

				End Transaction
			Else
				Messagebox("Tipo de produto inv·lido, bipe somente P A's!!!","AtenÁ„o...",48)
				oGet1Mnt:SetFocus()
				cGet1Mnt := space(20)
				oGet1Mnt:Refresh()
				cGet4Mnt := space(30)
				oGet4Mnt:Refresh()
				cGet2Mnt := space(3)
				oGet2Mnt:Refresh()
				nGet3Mnt := 0
				oGet3Mnt:Refresh()
				nGet7Mnt := 0
				oGet7Mnt:Refresh()
				cGet5Mnt := space(6)
				oGet5Mnt:Refresh()
				cGet8Mnt:= space(6)
				oGet8Mnt:Refresh()
				nGet9Mnt:=space(4)
				oGet9Mnt:Refresh()
				nGetAMnt:=space(4)
				oGetAMnt:Refresh()
			Endif
		Else
			Messagebox("Este produto n„o faz parte da lista de compra /(ou)/ Todos os volumes deste produto j· foram comprados para este borderÙ !!, Verifique!!!","AtenÁ„o...",48)
		Endif

		DbSelectArea("TCQ1")
		DbCloseArea()


	Elseif nOpcMnt = 2 // Retirada da carga
		DbSelectArea("TMPITE")
		DbSetOrder(4) // pallet + cÛdigo de barras
		DbGoTop()
		DbSeek(cGet1Env+cCodBarra, .F.)
		If Found() .AND. (Alltrim(TMPITE->TMPPAL) == Alltrim(cGet1Env))
			cGet4Mnt := Posicione("SB1", 1, xFilial("SB1")+TMPITE->TMPPRO, "B1_DESC")
			cGet5Mnt := TMPITE->TMPLOT
			cGet2Mnt := TMPITE->TMPSEQ
			cGet8Mnt := TMPITE->TMPPED
			nQtdAtual:= fProdPalle(1) // qtde de itens do mesmo produto no bordero
			nGet9Mnt := fProdPalle(2) // qtde de itens do mesmo produto no pedido
			If Len(Alltrim(cCodBarra)) == 14
				nGet3Mnt := Val(Substr(Alltrim(cCodBarra),9,2))
			Else
				cQry := ""
				cQry += " SELECT RELVOL = dbo.DetVol('"+xFilial("SB1")+"','"+(cGet1Mnt)+"')"
				TCQuery cQry ALIAS "TCR" NEW
				nGet3Mnt := Val(TCR->RELVOL)
			Endif
			nGetAMnt := (nGet9Mnt-nGet3Mnt)
			nGet7Mnt 	:= (nQtdAtual-nGet3Mnt) // Subtrai no Total a quantidade bipada
			nVol		:= (nGet7Mnt/nGet3Mnt)
			nVolAtual 	:= (nVolAtual +1)
			cSay6Mnt  	:= "DESMONTAGEM - VOL. BIPADOS..:  "+TransForm(nVolAtual, "@E 9999")
			_CodProd 	:= cGet1Mnt
			nCount      := (nCount - 1)
			oSay7Env:Refresh()
			cGet1Mnt    := PADR(cGet1Mnt,20,' ')
			oGet4Mnt:Refresh()
			oGet2Mnt:Refresh()
			oGet1Mnt:SetFocus()
			If ChkFile("TCR")
				DbSelectArea("TCR")
				DbCloseArea()
			Endif

			Begin Transaction
				RecLock("TMPITE", .f.)
				DbDelete()
				MsUnLock()

				DbSelectArea("ZZK")
				DbSetOrder(5)  // filial + cÛdigo barras + pallet
				DbGoTop()
				DbSeek(xFilial("ZZK")+cCodBarra+cGet1Env, .t.)
				If Found() .and. (ZZK->ZZK_FILIAL == xFilial("ZZK")) .and. (Alltrim(ZZK->ZZK_CODIGO) == Alltrim(cGet1Env))
					RecLock("ZZK", .F.)
					DbDelete()
					MsUnlock()
				Endif
			End Transaction
		Else
			Messagebox("Produto n„o encontrado neste Pallet, verifique o volume bipado !!!","AtenÁ„o...",48)
			oGet1Mnt:SetFocus()
			cGet1Mnt := space(20)
			oGet1Mnt:Refresh()
			cGet4Mnt := space(30)
			oGet4Mnt:Refresh()
			cGet2Mnt := space(3)
			oGet2Mnt:Refresh()
			nGet3Mnt := 0
			oGet3Mnt:Refresh()
			nGet7Mnt := 0
			oGet7Mnt:Refresh()
			cGet5Mnt := space(6)
			oGet5Mnt:Refresh()
			cGet8Mnt:= space(6)
			oGet8Mnt:Refresh()
			nGet9Mnt:=space(4)
			oGet9Mnt:Refresh()
			nGetAMnt:=space(4)
			oGetAMnt:Refresh()
		Endif
	Endif

	DbSelectArea("TMPITE")
	DbSetOrder(1)
	DbGoTop()

Return

/*ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
Function  ≥ fProdPalle(Opc)  1-) Total Pallet 2-) Total Pedido
ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*/
Static Function fProdPalle(Opc)

	Local cArea := Alias()
	Local aArea := U_PegaArea({"TMPITE"})

	Local nQtd  := 0
	Local cQry1 := ""

	DbSelectArea("TMPITE")
	DbSetOrder(2)
	DbGoTop()
	DbSeek(cGet1Env+cGet1Mnt, .F.)
	If !Eof()
		While !Eof() .AND. (Alltrim(cGet1Env) == Alltrim(TMPITE->TMPPAL)) .AND. (Alltrim(cGet1Mnt) == Alltrim(TMPITE->TMPPRO))
			If Opc == 2 .and. Alltrim(TMPITE->TMPPED) == Alltrim(cGet8Mnt)
				nQtd += TMPITE->TMPQTD
			Else
				nQtd += TMPITE->TMPQTD
			Endif
			DbSkip()
		Enddo
	Else
		cQry1 := ""
		cQry1 += " SELECT SUM(ZZK_QUANT) AS ZZK_QUANT "
		cQry1 += " FROM "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) "
		cQry1 += " WHERE ZZK.D_E_L_E_T_ ='' "
		cQry1 += " AND ZZK_FILIAL = '"+XFILIAL("ZZK")+"' "
		cQry1 += " AND ZZK.ZZK_CODIGO = '"+Alltrim(cGet1Env)+"' "
		If Opc == 2
			cQry1 += " AND ZZK.ZZK_PRODUT = '"+Alltrim(cGet1Mnt)+"' "
			cQry1 += " AND ZZK.ZZK_PEDIDO = '"+Alltrim(cGet8Mnt)+"' "
		Endif

		TCQuery cQry1 ALIAS "TCQ" NEW
		DbSelectArea("TCQ")
		If !Eof()
			nQtd := TCQ->ZZK_QUANT
		Endif
		DbSelectArea("TCQ")
		DbCloseArea()
	Endif

	U_VoltaArea(aArea)
	If !Empty(cArea)
		DbSelectArea(cArea)
	Endif

Return(nQtd)

/*ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
Function  ≥ fManuPal(nOpc)
ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*/
/*Static Function fManuPal(nOpc)

 	If Len(Alltrim(cGet1Mnt)) == 0
		Messagebox("Bipe o cÛdigo de barras antes de confirmar !!","Verifique...",48)
	   	oGet1Mnt:SetFocus()
		Return
	Endif
	If nOpc == 1
 		If nGet7Mnt > 0
   			_cMaxSeq := cGet2Mnt
      	Endif
      	nQtdTotal := 0
	ElseIf nOpc == 2
    	If nGet7Mnt = 0
   	    	DbSelectArea("TMPITE")
   			DbSetOrder(2)
    		//DbSetOrder(5)
   			DbGoTop()
   			//DbSeek(cGet1Env+cGet1Mnt, .F.)
			DbSeek(cGet1Env+cGet1Mnt+cGet2Mnt, .F.)
   			If Found()
       	    	RecLock("TMPITE", .f.)
	            	DbDelete()
   	          	MsUnLock()
   			Endif
        Elseif nGet7Mnt > 0
   	    	DbSelectArea("TMPITE")       //
   			DbSetOrder(2)
    		DbGoTop()
   			DbSeek(cGet1Env+cGet1Mnt+cGet2Mnt, .F.)
   			If Found()
      			RecLock("TMPITE", .f.)
	        		TMPITE->TMPQTD := nGet3Mnt
       	   		MsUnLock()
           	Endif
   	  	Endif
	Endif
    oDlg1Mnt:End()
    DbSelectArea("TMPITE")
    DbSetOrder(1)
    DbGoTop()

Return  */

Static Function fNPal()

	If Empty(Alltrim(nCBox1Lo)) .and. alltrim(FWCodFil()) =='010101'
		Messagebox("Informe o local onde o Pallet esta sendo montado (FAB-1 / FAB-2 / ARA / DEPOS) !!","Verifique...",48)
		oCBox1Lo:Setfocus()
		Return
	Endif

	cGet1Env := "NOVO PALLET"
	cSay3Env := ""
	cSay5Env := ""
	lCheck   := .t.

	If ChkFile("TMPITE")
		DbSelectArea("TMPITE")
		DbGoTop()
		//Zap
		//LGS#20191029 - Substituido comando ZAP devido a utilizaÁ„o de funÁ„o do banco.
		TCSqlExec("DELETE FROM " + oTempTbl1:GetRealName() )
	Endif

	oBtn3Env:Disable()
	oBrw1Env:oBrowse:GoTop()
	oBrw1Env:oBrowse:Refresh()
	oBtn4Env:Setfocus()
	oCBox1Lo:Disable()

Return

Static Function fGrvNPal() // Grava NumeraÁ„o do Pallet Antes de Salvar

	Local cQry1   := ""
	//Local cQry2   := ""
	Local nCodReg := ""
	//Local cLocali := ""
	//Local cNumIP  := GetClientIP()

	If cGet1Env $ "NOVO PALLET"
		//Buscar o ultimo R_E_C_N_O_ para Inclus„o
		cQry1 += " SELECT MAX(R_E_C_N_O_) AS R_E_C_N_O_ "
		cQry1 += " FROM  "+RetSqlName("ZZJ")+" WITH (NOLOCK) "

		TCQUERY cQry1 ALIAS "TCQ" NEW
		DbSelectArea("TCQ")
		DbGoTop()
		nCodReg := Str(TCQ->R_E_C_N_O_ + 1, 10)

		DbSelectArea("TCQ")
		DbCloseArea()

		cQry1 := ""
		cQry1 += " SELECT TOP 1 ZZJ.ZZJ_CODIGO "
		cQry1 += " FROM "+RetSqlName("ZZJ")+" ZZJ WITH (NOLOCK) "
		cQry1 += " WHERE ZZJ.ZZJ_FILIAL = '"+xFilial("ZZJ")+"'"
		//cQry1 += "  AND ZZJ.D_E_L_E_T_ = '' "
		cQry1 += "  AND ZZJ.ZZJ_DTINI  = '"+DTOS(Date())+"' "
		cQry1 += " ORDER BY ZZJ.ZZJ_CODIGO DESC "

		TCQUERY cQry1 ALIAS "TCQ" NEW
		DbSelectArea("TCQ")
		DbGoTop()

		cCodSeq := Iif(Empty(TCQ->ZZJ_CODIGO), SubStr(Dtos(Date()), 7, 2)+SubStr(Dtos(Date()), 5, 2)+SubStr(Dtos(Date()), 3, 2)+'/'+'0001', SubStr(TCQ->ZZJ_CODIGO, 1, 7)+StrZero(Val(SubStr(TCQ->ZZJ_CODIGO, 8, 4))+1, 4) )
		cNomArq := SubStr(cCodSeq, 8, 4)
		DbSelectArea("TCQ")
		DbCloseArea()

		DbSelectArea("ZZJ")
		DbSetOrder(1)
		DbSeek(xFilial("ZZJ")+cCodSeq, .t.)
		If !Found()
			Reclock("ZZJ",.t.)
			ZZJ->ZZJ_FILIAL := xFilial("ZZJ")
			ZZJ->ZZJ_CODIGO := cCodSeq
			ZZJ->ZZJ_DTINI  := Date()
			ZZJ->ZZJ_HINI   := SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)
			ZZJ->ZZJ_FLAG   := '3'
			ZZJ->ZZJ_BORDER	:= cGet2Env
			ZZJ->ZZJ_USER   := __cUserId
			ZZJ->ZZJ_LOCALI := nCBox1Lo
			MsUnlock()
		Endif

		If ChkFile("TMPITE")
			DbSelectArea("TMPITE")
			//DbGoTop()
			//Zap
			//LGS#20191029 - Substituido comando ZAP devido a utilizaÁ„o de funÁ„o do banco.
			TCSqlExec("DELETE FROM " + oTempTbl1:GetRealName() )
		Endif

		oBtn3Env:Disable()
		cGet1Env := cCodSeq
		oGet1Env:Refresh()
	Endif

Return()



/*
Static Function fGrvNPal() // Grava NumeraÁ„o do Pallet Antes de Salvar

	Local cQry1   := ""
	Local cQry2   := ""
    Local nCodReg := ""
    Local cLocali := ""
	Local cNumIP  := GetClientIP()

    If cGet1Env $ "NOVO PALLET"
       //Buscar o ultimo R_E_C_N_O_ para Inclus„o
       cQry1 += " SELECT MAX(R_E_C_N_O_) AS R_E_C_N_O_ "
       cQry1 += " FROM  "+RetSqlName("ZZJ")+" WITH (NOLOCK) "

       TCQUERY cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()
       nCodReg := Str(TCQ->R_E_C_N_O_ + 1, 10)

       DbSelectArea("TCQ")
       DbCloseArea()

       // Buscar LocalizaÁ„o baseado no cadastro de IP do Antivirus
       cQry2 += " SELECT Z11_LOCALI FROM "+RetSqlName("Z11")+" WITH(NOLOCK) "
       cQry2 += " WHERE D_E_L_E_T_ ='' AND D_E_L_E_T_ ='' AND Z11_CODIGO IN('000006') AND Z11_IP ='"+Alltrim(cNumIP)+"'"

       TCQUERY cQry2 ALIAS "TCR" NEW
       DbSelectArea("TCR")
       DbGoTop()
	   If !Eof()
	   	   cLocali := Alltrim(TCR->Z11_LOCALI)
	   Endif
       DbSelectArea("TCR")
       DbCloseArea()


	   cQry1 := ""
       cQry1 += " SELECT TOP 1 ZZJ.ZZJ_CODIGO "
       cQry1 += " FROM "+RetSqlName("ZZJ")+" ZZJ WITH (NOLOCK) "
       cQry1 += " WHERE ZZJ.ZZJ_FILIAL = '"+xFilial("ZZJ")+"'"
       //cQry1 += "  AND ZZJ.D_E_L_E_T_ = '' "
       cQry1 += "  AND ZZJ.ZZJ_DTINI  = '"+DTOS(Date())+"' "
       cQry1 += " ORDER BY ZZJ.ZZJ_CODIGO DESC "

       TCQUERY cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()

	   cCodSeq := Iif(Empty(TCQ->ZZJ_CODIGO), SubStr(Dtos(Date()), 7, 2)+SubStr(Dtos(Date()), 5, 2)+SubStr(Dtos(Date()), 3, 2)+'/'+'0001', SubStr(TCQ->ZZJ_CODIGO, 1, 7)+StrZero(Val(SubStr(TCQ->ZZJ_CODIGO, 8, 4))+1, 4) )
       cNomArq := SubStr(cCodSeq, 8, 4)
       DbSelectArea("TCQ")
       DbCloseArea()

       cQry1 := ""
       cQry1 += "INSERT INTO "+RetSqlName("ZZJ")+" (ZZJ_FILIAL,  ZZJ_CODIGO  ,  ZZJ_DTINI         , ZZJ_HINI                                       ,  R_E_C_N_O_ , ZZJ_FLAG,   ZZJ_USER     , ZZJ_BORDER, ZZJ_LOCALI    ) "
       cQry1 += "                  VALUES('"+xFilial("ZZJ")+"', '"+cCodSeq+"',  '"+DTOS(Date())+"', '"+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+"', "+nCodReg+" ,  '3'    , '"+__cUserId+"','"+cGet2Env+"','"+cLocali+"' ) "
	   XXX := TCSQLExec(cQry1)
       If XXX <> 0
       	   cNomArq := 'C:\TEMP\ERR'+DTOS(MsDate())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+'.ERR'
           MemoWrit(cNomArq, cQry1)
       Endif

       If ChkFile("TMPITE")
		   DbSelectArea("TMPITE")
		   //DbGoTop()
           //Zap
           //LGS#20191029 - Substituido comando ZAP devido a utilizaÁ„o de funÁ„o do banco.
           TCSqlExec("DELETE FROM " + oTempTbl1:GetRealName() )
	   Endif

	   oBtn3Env:Disable()
       cGet1Env := cCodSeq
       oGet1Env:Refresh()
    Endif

Return()
/*

/*ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
Function  ≥ fVerCPall() - Funcao para retornar capacidade de empilhamento do *
		  ≥	Pallet de acordo com tabela ZZ por Embalagem MP                  *
ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*/
Static Function fVerCPall(_cProduto)

	Local cQry 			:= ""
	Local nCapacidade 	:= 0

	cQry += " SELECT G1_COD, X5_CHAVE, X5_DESCRI AS X5DESCRI FROM "+RetSqlName("SX5")+" SX5 WITH(NOLOCK) "
	cQry += " LEFT OUTER JOIN "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) ON X5_FILIAL = '"+xFilial("SX5")+"' AND X5_CHAVE = G1_COMP AND SG1.D_E_L_E_T_ ='' "
	cQry += " WHERE SX5.D_E_L_E_T_ ='' AND X5_TABELA ='ZZ' AND G1_COD ='"+Alltrim(_cProduto)+"' AND G1_FILIAL ='"+xFilial("SG1")+"'"

	TCQUERY cQry ALIAS "TCP" NEW
	DbSelectArea("TCP")
	DbGoTop()
	If !Eof() .and. !Bof()
		nCapacidade :=   Val( TCP->X5DESCRI )
	Endif
	DbSelectArea("TCP")
	DbCloseArea()

Return(nCapacidade)

/*ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
Function  ≥ FGerEtq() - FunÁ„o que gera o arquivo txt contendo o produto e o *
		  ≥	Pedido para uma pasta local, ser· lido pelo programa que imprimi *
		  ≥	r· etiquetas de volume											 *
ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*/
Static Function FGerEtq(aGerEtq)
	Local cLin      := ""
	Private cArqTxt := ""
	Private nHandle := ""
	Private nTamLin := 22
	Private cEOL    := "CHR(13)+CHR(10)"

	cEOL := Trim(cEOL)
	cEOL := &cEOL

	cArqTxt += "C:\TEMP\etq"
	cArqTxt += SUBSTR(DTOS(DATE()),7,2)+SUBSTR(DTOS(DATE()),5,2)
	cArqTxt += SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)+".txt"

	nHandle := FCREATE(cArqTxt)
	cLin := Space(nTamLin)+cEOL  // Variavel para criacao da linha do registros para gravacao
	cCpo := aGerEtq[01][01]
	cLin := Stuff(cLin, 001, 022, cCpo)
	If fWrite(nHandle, cLin, Len(cLin)) != Len(cLin)
		If !MsgAlert("Ocorreu um erro na gravacao do arquivo TXT !","Atencao!")
			Return
		Endif
	Endif
	//FWrite(nHandle, cLin + CRLF)
	FClose(nHandle)

Return

/*ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
// Function MaxSequ - Incremento de Sequencia na inclus„o dos produtos no Pallet
ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*/
Static Function MaxSequ()

	Local cArea := Alias()
	Local aArea := U_PegaArea({"ZZK"})
	Local cQry1 := ""

	cQry1 := " SELECT ISNULL(MAX(ZZK_SEQENV), '0') AS ZZK_SEQENV FROM "+RetSqlName("ZZK")+" WITH(NOLOCK) WHERE ZZK_FILIAL = '"+xFilial("ZZK")+"' AND ZZK_CODIGO = '"+cGet1Env+"' AND D_E_L_E_T_ = '' "
	TCQuery cQry1 ALIAS "TMPSEQ" NEW
	DbSelectArea("TMPSEQ")
	cMaxSeq := StrZero(Val(TMPSEQ->ZZK_SEQENV) + 1, 3)
	DbSelectArea("TMPSEQ")
	DbCloseArea()

	U_VoltaArea(aArea)
	If !Empty(cArea)
		DbSelectArea(cArea)
	Endif

Return(cMaxSeq)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±∫Descricao ≥ Apagar Itens e CabeÁalho de Pallet de compra                ∫±±
±±∫          ≥ (usado qdo h· divergÍncia nas contagens de o pallet È bipado∫±±
±±∫             novamente)                                                 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ π±±
±±∫Uso       ≥ BRASILUX TINTAS T…CNICAS LTDA.                              ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function fDelPallet()

	Local lRet  := .f.
	Local cQry1 := " "
	Local cQry2 := " "

	If !SubStr(cAcessos, 2, 1) $ '*' //.or. !(PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),cCodUsr) == 0)
		Messagebox("Usu·rio sem permiss„o para Destruir Pallets !!","AtenÁ„o...",48)
		Return
	Endif

	If Empty(Alltrim(cGet1Env)) .or.  Empty(Alltrim(cGet2Env))
		Return
	Endif

	DbSelectArea("ZZJ")
	DbSetOrder(1)
	DbSeek(xFilial("ZZJ")+cGet1Env, .t.)
	If Found()
		If ZZJ->ZZJ_FLAG $ '3'
			lRet := MsgBox("Deseja DESTRUIR este PALLET e todos os itens j· bipados nele ?'","Pergunta","YESNO")
			If lRet
				Begin Transaction
					cQry1 := " "
					cQry1 += " UPDATE "+RetSqlName("ZZJ")+" SET D_E_L_E_T_ ='*' FROM "+RetSqlName("ZZJ")+"  WHERE ZZJ_CODIGO ='"+cGet1Env+"'"
					cQry1 += " AND D_E_L_E_T_ ='' AND ZZJ_FLAG IN('3') AND ZZJ_BORDER ='"+cGet2Env+"' AND ZZJ_FILIAL ='"+xFilial("ZZJ")+"'"
					XXX := TCSQLExec(cQry1)
					If XXX <> 0
						DisarmTransaction()
						Messagebox("Erro durante o processo de exclus„o do Pallet !!","AtenÁ„o...",48)
						DbSelectArea("ZZJ")
						DbCloseArea()
						//Return  //LGS#20200210 - AdequaÁ„o de release 12.1.25 e posteriores - N„o pode usar return dentro de Begin transaction
					Endif

					cQry2 := " "
					cQry2 += " UPDATE "+RetSqlName("ZZK")+" SET D_E_L_E_T_ ='*' FROM "+RetSqlName("ZZK")+"  WHERE ZZK_CODIGO ='"+cGet1Env+"'"
					cQry2 += " AND D_E_L_E_T_ ='' AND ZZK_PEDIDO <>'' AND ZZK_FILIAL ='"+xFilial("ZZK")+"'"
					XXX := TCSQLExec(cQry2)
					If XXX <> 0
						DisarmTransaction()
						Messagebox("Erro durante o processo de exclus„o do Pallet  !!","AtenÁ„o...",48)
						DbSelectArea("ZZJ")
						DbCloseArea()
						//Return //LGS#20200210 - AdequaÁ„o de release 12.1.25 e posteriores - N„o pode usar return dentro de Begin transaction
					Endif
				End Transaction

				Messagebox("Pallet "+cGet1Env+" foi DESTRUIDO e os produtos foram liberados !!","AtenÁ„o...",48)

			Endif
		Elseif ZZJ->ZZJ_FLAG $ '2'
			Messagebox("N„o È possÌvel DESTRUIR este Pallet, pois j· foi transferido do "+ZZJ->ZZJ_LOCORI+" para "+ZZJ->ZZJ_LOCDES+" !","AtenÁ„o...",48)
		Elseif ZZJ->ZZJ_FLAG $ '4'
			Messagebox("N„o È possÌvel DESTRUIR este Pallet, pois j· foi transformado em pedido de transferÍncia !","AtenÁ„o...",48)
		Endif
	Else
		Messagebox("Pallet "+cGet1Env+" n„o encontrado, verifique !!","AtenÁ„o...",48)
	Endif

	DbSelectArea("ZZJ")
	DbCloseArea()

	fNPal() // novo pallet

Return()

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±∫Descricao ≥ Impress„o dos itens n„o comprados em um determinado bordero∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ BRASILUX TINTAS T…CNICAS LTDA.                             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
User Function fImpInf()
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Declaracao de Variaveis                                             ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

	Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2        := "de acordo com os parametros informados pelo usuario."
	Local cDesc3        := "RelaÁ„o de produtos n„o comprados no Bordero"
	//Local cPict         := ""
	Local titulo        := "RelaÁ„o de produtos n„o comprados "
	Local nLin          := 80
	Local Cabec1        := ""
	Local Cabec2        := ""
	//Local imprime       := .T.
	Local aOrd          := {}
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 80
	Private tamanho     := "M"
	Private nomeprog    := "BRFATX66" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cPerg       := 'FATX66'
	Private m_pag       := 01
	Private wnrel       := "BRFATX66" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cString     := ''
	//Private cRetLin     := ''

	If Empty(Alltrim(cGet2Env))
		Messagebox("Informe o cÛdigo do BorderÙ de pedidos antes de consultar !","AtenÁ„o...",48)
		Return
	Endif

	//oPerg() //LGS#20200210 - AdequaÁ„o de release 12.1.25 e posteriores
	Pergunte('FATX66', .t.)

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Monta a interface padrao com o usuario...                           ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	Limite := Iif(mv_par02 = 2, 80, 132)

	Tamanho:= Iif(mv_par02 = 2, "P", "M")

	wnrel  := SetPrint(cString, NomeProg,      , @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho, , .F.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Processamento. RPTSTATUS monta janela com a regua de processamento. ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

	Processa({|| fRunRel(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

//----------------------  acrescentado por jose 13/09/20122 ----------------------------------------------------------
/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±∫Descricao ≥ Impress„o dos itens n„o comprados em um determinado bordero∫±±
±±∫          ≥ Em Excel                                                           ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ BRASILUX TINTAS T…CNICAS LTDA.                             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
User Function fImpExc(nTipoBor)

	/*------------------------------------------------------------------

//Verifica se o Excel esta instalado
If ApOleClient("MSEXCEL")
   MsgInfo("Excel instalado", "AtenÁ„o")
EndIf

	--------------------------------------------------------------------*/

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Declaracao de Variaveis                                             ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 80
	Private tamanho     := "M"
	Private nomeprog    := "BRFATX66" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cPerg       := 'FATX66'
	Private m_pag       := 01
	Private wnrel       := "BRFATX66" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cString     := ''
	Private _nTipoBor   := 0 // jose 19/09/2023

	_nTipoBor  = nTipoBor  // jose 19/09/2023

	//	   Private _oProcess  //  jose 13/10/2022

	// Jose 14/09/2023       If Empty(Alltrim(cGet2Env))
	// Jose 14/09/2023			Messagebox("Informe o cÛdigo do BorderÙ de pedidos antes de consultar !","AtenÁ„o...",48)
	// Jose 14/09/2023			Return
	// Jose 14/09/2023       Endif

	//oPerg() //LGS#20200210 - AdequaÁ„o de release 12.1.25 e posteriores
	Pergunte('FATX66', .t.)

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Monta a interface padrao com o usuario...                           ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	Limite := Iif(mv_par02 = 2, 80, 132)

	Tamanho:= Iif(mv_par02 = 2, "P", "M")

	If nLastKey == 27
		Return
	Endif

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Processamento. RPTSTATUS monta janela com a regua de processamento. ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

	Processa (fRunExc(_nTipoBor))
Return
/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫FunáÑo    ≥ fRunExc  ∫ Autor ≥ Jose  Uliana  	   ∫ Data ≥  / /      ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫DescriáÑo ≥ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ∫±±
±±∫          ≥ monta a janela com a regua de processamento.               ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Programa principal                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function fRunExc(_nTipoBor)
	//------   Jose 13/09/2022 ------
	Local aAreaa        := GetArea()
	Local oFWMsExcel
	Local oExcel
	Local cArquivo     := "C:\Temp\"+"BRFATX66.xml"
	//-----   Jose 18/09/2023 ----------
	Local _cProduto
	Local _cDescricao
	Local _cSaldo
	Local _cSaldoG3
	Local _cSAldoA3  // Jose 10/07/2024
	Local _cZZLLOCALIZ
	Local _cLOCALIZ1
	Local _cLOCALIZ2
	Local _cLOCALIZG3 // Jose 02/09/2024
	Local _cLOCALIZA3 // Jose 02/09/2024
	Local _cVOLUME
	Local _cFALTA
	Local _cDtApr  := ''// Jose 23/10/2024
	Local _cEmb
	LOCAL _cP1P2
	Local _cDisp
	Local _cDispG3
	Local _cDispA3  // Jose 10/07/2024
	Local cLOCALIZ1   := "" // Jose 29/08/2023
	Local cLOCALIZ2   := "" // Jose 29/08/2023
	Local cLOCALIZA3  := "" // Jose 02/09/2024
	Local cLOCALIZG3  := "" // Jose 02/09/2024
	Local cCont       := 0 // Jose 29/08/2023
	Local cQry3       := "" // Jose29/08/2023

	Local _cSugestao  := "" // Jose 17/02/2025
	Local _cSZF       := ""
	//	Local _pSugestao := 0  // Jose 17/02/2025
	// Jose 18/11/2024    Local __nControla
	Local __nTipoBor
	//---------------------------------- Jose
	Local cQry  := ""
	Local cQryy := ""
	//	Local _zCodigo  := ''    Voltar quando voltar a parte de aturalizaÁ„o 18/06/2024
	//	Local _zTipoBor := ''    Voltar quando voltar a parte de aturalizaÁ„o 18/06/2024
	//	Local nLargBtn := 50 // Largura botıes    Voltar quando voltar a parte de aturalizaÁ„o 18/06/2024
	//	Local _cTem := 0         Voltar quando voltar a parte de aturalizaÁ„o 18/06/2024
	Local _zConta   :=0  // Tirar quando volta o atualizaÁ„o 18/06/2024
	Local _vCodpro  := ""
	Local _vQtdevol := 0
	Private oBrowser as Object
	Private oLbx     as Object
	Private nJanLarg := 1300
	Private nJanAltu := 550
	Private aBrowser := {}
	Private addColumn  := {}
	Private aSemVolume := {}
	//Fontes
	Private cFontUti    := "Tahoma"
	Private oFontMod    := TFont():New(cFontUti, , -38)
	Private oFontSub    := TFont():New(cFontUti, ,  12)
	Private oFontSubN   := TFont():New(cFontUti, ,  18)
	Private oFontBtn    := TFont():New(cFontUti, , -14)
	Private oFontSay    := TFont():New(cFontUti, , -12)
	//--------------  Jose 10/10/2023 -----------------------------

	//Verifica se o Excel est· instalado
	If ApOleClient("MSEXCEL") == .F.
		MessageBox("Excel N„o Instalado...,    Favor Executar em Outra Maquina que tenha Excel", "  AtenÁ„o  ",0)
		return
	EndIf
	//-----  Jose 07/06/2024 -------------------------------------
	cQryy  = "WITH TMP1 AS ( SELECT SB1.B1_COD, "  + STR_PULA
	cQryy += "					 SB1.B1_DESC, "   + STR_PULA
	cQryy += "					 'B1_RELVOL' = CASE WHEN SB1.B1_RELVOL > 0 THEN CONVERT(VARCHAR,SB1.B1_RELVOL) ELSE '' END, "  + STR_PULA//SB1.B1_RELVOL,"
	cQryy += "					 SC6.C6_QTDVEN," + STR_PULA
	cQryy += "			    	 SC6.C6_FILIAL, " + STR_PULA
	cQryy += "					 SC6.C6_PRODUTO, "	 + STR_PULA
	cQryy += "					 SC6.C6_NUM, "	 + STR_PULA
	cQryy += "					 'GRPEMB' = ISNULL( ( SELECT TOP 1 CMP.B1_GRUPO2" + STR_PULA
	cQryy += "				                            FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "  + STR_PULA
	cQryy += "				                                 LEFT OUTER JOIN "+RetSqlName("SB1")+" CMP WITH (NOLOCK) ON CMP.D_E_L_E_T_ = ''  "   + STR_PULA
	cQryy += "					                                                                                    AND SG1.G1_FILIAL = CMP.B1_FILIAL"  + STR_PULA
	cQryy += "															                                            AND SG1.G1_COMP   = CMP.B1_COD "    + STR_PULA
	cQryy += "			                               WHERE ( SG1.D_E_L_E_T_ = '')  "    + STR_PULA
	cQryy += "				                             AND ( SG1.G1_FILIAL  = SC6.C6_FILIAL)  "   + STR_PULA
	cQryy += "			                            	 AND ( SG1.G1_COD     = SC6.C6_PRODUTO)"   + STR_PULA
	cQryy += "			                            	 AND ( CMP.B1_GRUPO LIKE 'E%')" + STR_PULA
	cQryy += "			                            	 AND ( CMP.B1_GRUPO2 > '' ) ),'99'), " 	 + STR_PULA
	cQryy += "				     'LOCALIZ' = ISNULL( ( SELECT SB2.B2_LOCALIZ  " + STR_PULA
	cQryy += "					                         FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK)   " + STR_PULA
	cQryy += "											WHERE SB2.B2_FILIAL = SB1.B1_FILIAL "   + STR_PULA
	cQryy += "											  AND SB2.B2_COD    = SB1.B1_COD " + STR_PULA
	cQryy += "											  AND SB2.B2_LOCAL  = SB1.B1_LOCPAD  "  + STR_PULA
	cQryy += "											  AND SB2.D_E_L_E_T_ = '' ), '' ),   "  + STR_PULA
	cQryy += "					 'ZZLLOCALIZ' = ISNULL( ( SELECT TOP 1 ZZL_LOCALI "  + STR_PULA
	cQryy += "					                            FROM "+RetSqlName("ZZL")+" ZZL WITH (NOLOCK)  " + STR_PULA
	cQryy += "											   WHERE ZZL.ZZL_FILIAL = SB1.B1_FILIAL "   + STR_PULA
	cQryy += "											     AND ZZL.ZZL_PRODUT = SB1.B1_COD  " + STR_PULA
	cQryy += "												 AND ZZL.D_E_L_E_T_ = '' ), '' ), " + STR_PULA
	cQryy += "					'SB2_03E30' = ISNULL( ( SELECT SUM(B2_QATU) AS B2_DISP  "  + STR_PULA
	cQryy += "					                          FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) " + STR_PULA
	cQryy += "											 WHERE SB2.B2_FILIAL  = SB1.B1_FILIAL   "  + STR_PULA
	cQryy += "											   AND SB2.B2_COD     = SB1.B1_COD " + STR_PULA
	cQryy += "											   AND SB2.D_E_L_E_T_ = ''  "     + STR_PULA
	cQryy += "											   AND SB2.B2_LOCAL IN( '03','30','G3','A3' ) ), 0 ),  " + STR_PULA
	cQryy += "				    'ZZKQTD' = ISNULL( (  SELECT SUM(ZZK_QUANT) " + STR_PULA
	cQryy += "					                        FROM "+RetSqlName("ZZK")+" ZK  WITH (NOLOCK)  " + STR_PULA
	cQryy += "										   WHERE ZK.ZZK_FILIAL = SC6.C6_FILIAL    " + STR_PULA
	cQryy += "										     AND ZK.ZZK_PEDIDO = SC6.C6_NUM "   + STR_PULA
	cQryy += "											 AND ZK.ZZK_PRODUT = SC6.C6_PRODUTO  "  + STR_PULA
	cQryy += "											 AND ZK.D_E_L_E_T_ = ''), 0 )  "    + STR_PULA
	cQryy += "			FROM "+RetSqlName("SZG")+" SZG WITH (NOLOCK)  "  + STR_PULA
	cQryy += "			     LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON SZG.ZG_FILIAL  = SC6.C6_FILIAL " + STR_PULA
	cQryy += "				                                         AND SUBSTRING(SZG.ZG_PEDIDO, 3, 6 ) = SC6.C6_NUM  "  + STR_PULA
	cQryy += "														 AND SC6.D_E_L_E_T_ = ''" + STR_PULA
	cQryy += "														 AND SC6.C6_NOTA = '' 	" + STR_PULA
	//--	cQryy += "		         INNER  JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON SC6.C6_FILIAL  = SC5.C5_FILIAL "
	//--	cQryy += "			                                         AND SC6.C6_NUM = SC5.C5_NUM"
	//--	cQryy += "							    					 AND SC5.D_E_L_E_T_ = ''"
	//	cQryy += "										    		 AND SC5.C5_EMISSAO >= '20240101'"
	cQryy += "				 INNER JOIN "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) ON ZZC_FILIAL = C6_FILIAL  " + STR_PULA
	cQryy += "				                                    AND ZZC_PEDIDO = C6_NUM" + STR_PULA
	cQryy += "													AND ZZC.D_E_L_E_T_ = ''" + STR_PULA
	cQryy += "													AND ZZC_QUANTI > ZZC_RETIRA"   + STR_PULA
	cQryy += "													AND ZZC_DESPAC NOT IN('S')  " + STR_PULA
	cQryy += "													AND ZZC_SEPARA <> 'S'  "     + STR_PULA
	cQryy += "													AND ZZC_GAVETA <> '' "	    + STR_PULA
	//--    cQryy += "				INNER JOIN "+RetSqlName("SZF")+" SZF WITH (NOLOCK) ON SZF.ZF_FILIAL = SZG.ZG_FILIAL  "
	//--    cQryy += "				                                   AND SZF.ZF_CODIGO = SZG.ZG_CODIGO "
	//--    cQryy += "												   AND SZF.D_E_L_E_T_ = ''"
	// --   cQryy += "										           AND SZF.ZF_FLAG IN ('Y','X')  "
	//--    cQryy += "                                                 AND SZF.ZF_TIPOBOR = '"+_nTipoBor+"'"
	cQryy += "				LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) ON ZZK.ZZK_FILIAL = SC6.C6_FILIAL " + STR_PULA
	cQryy += "				                                        AND ZZK.ZZK_PEDIDO = SC6.C6_NUM "    + STR_PULA
	cQryy += "														AND ZZK.ZZK_PRODUT = SC6.C6_PRODUTO "  + STR_PULA
	cQryy += "														AND ZZK.D_E_L_E_T_ = '' "        + STR_PULA
	cQryy += "				LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON SB1.B1_FILIAL  = SC6.C6_FILIAL  " + STR_PULA
	cQryy += "				                                        AND SB1.B1_COD     = SC6.C6_PRODUTO "  + STR_PULA
	cQryy += "														AND SB1.D_E_L_E_T_ = '' " + STR_PULA
	//  cQryy += "													    AND SB1.B1_MSBLQL <> '1'  "
	//  cQryy += "                                                        AND (SB1.B1_RELVOL = '' OR SB1.B1_RELVOL = 0) "

	If (Alltrim(cGet2Env)) <> '' // Jose 20/09/2024
		cQryy +="    WHERE SZG.ZG_CODIGO = '"+cGet2Env+"' AND "  + STR_PULA // Jose 20/09/2024
	Else // Jose 20/09/2024
		cQryy +="    WHERE "  + STR_PULA// Jose 20/09/2024
	EndIf // Jose 120/09/2024

	cQryy += "		      SZG.ZG_FILIAL  = '"+xFilial("SZG")+"'" + STR_PULA  //WHERE jOSE 20/09/2024
	cQryy += "		  AND SZG.D_E_L_E_T_ = '' "  + STR_PULA // Jose 20/09/2024 tirado o AND
	cQryy += "GROUP BY SB1.B1_COD, SB1.B1_DESC,  SB1.B1_RELVOL,   SC6.C6_FILIAL, SC6.C6_PRODUTO, SB1.B1_FILIAL, SB1.B1_LOCPAD, SC6.C6_NUM, SC6.C6_QTDVEN, SC6.C6_FILIAL, SC6.C6_PRODUTO  ) "  + STR_PULA
	cQryy += "SELECT TMP1.B1_COD,  " + STR_PULA
	cQryy += "       TMP1.C6_NUM,  "	 + STR_PULA
	cQryy += "	     TMP1.B1_DESC,  "	 + STR_PULA
	cQryy += "	     TMP1.B1_RELVOL, " + STR_PULA // ISNULL( TMP1.B1_RELVOL,0 ),0 AS 'B1_RELVOL',  "
	// Jose 25/09/2024	cQryY +="        'B1_VOLUME' = ROUND( ( ( ISNULL ( (TMP1.ZZKQTD ),0 ) - SUM ( TMP1.C6_QTDVEN ) ) / ( SELECT dbo.DetVol ( TMP1.C6_FILIAL,TMP1.C6_PRODUTO ) ) * -1 ),2 ), "
	cQryy += "	     TMP1.C6_QTDVEN AS 'VENDIDO', " + STR_PULA
	cQryy += "	     TMP1.ZZKQTD    AS 'BIPADO',  "  + STR_PULA
	cQryy += "	     ZZK_FALTA = ( TMP1.C6_QTDVEN - TMP1.ZZKQTD )  "  + STR_PULA
	cQryy += "  FROM TMP1  " + STR_PULA
	cQryy += " WHERE TMP1.B1_COD <> '' " + STR_PULA
	//	cQryy += "   AND (TMP1.B1_RELVOL = '0' OR TMP1.B1_RELVOL = '' ) "   Jose 18/06/2024 se der problema VOLTAR
	// jose 28/08/2024    cQryy += "   AND ( TMP1.C6_QTDVEN - TMP1.ZZKQTD ) > 0 "
	cQryy += "GROUP BY TMP1.B1_COD, TMP1.B1_DESC, TMP1.B1_RELVOL, TMP1.C6_QTDVEN, TMP1.ZZKQTD, TMP1.C6_FILIAL, TMP1.C6_PRODUTO, TMP1.C6_NUM " + STR_PULA
	// Jose 25/09/2024    cQryy += "HAVING (ROUND(((ISNULL((TMP1.ZZKQTD),0)-SUM(TMP1.C6_QTDVEN))/(SELECT dbo.DetVol(TMP1.C6_FILIAL,TMP1.C6_PRODUTO))*-1),2))=0 "
	cQryy += "ORDER BY 1 ASC" + STR_PULA
	TCQuery cQryy ALIAS "TRV" NEW

	//Verificando se tem algum produto sem Volume
	_zCodigo = ''
	_zNum    = ''
	_zConta  = 0
	while !(TRV->(EoF()))
		// jose 28/08/2024	      If (TRV->ZZK_FALTA > 0 .AND. TRV->B1_COD <> _zCodigo)
		If (TRV->B1_COD <> _zCodigo)
			_zCodigo := TRV->B1_COD
			_zNum    := TRV->C6_NUM
			/*---------------------------    Jose 04/07/2024 --------------------*/
			cQryz  = " WITH TMP AS (SELECT B1_COD, B1_DESC, RELVOL0 = CASE WHEN SB1.B1_RELVOL > 0 THEN CONVERT(VARCHAR,SB1.B1_RELVOL) ELSE '' END, " + STR_PULA
			cQryz += "              RELVOL1 = ISNULL((SELECT TOP 1 ISNULL(SZ5.Z5_RELVOL,'') " + STR_PULA
			cQryz += " 			                       FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) " + STR_PULA
			cQryz += " 	                                    LEFT OUTER JOIN "+RetSqlName("SB1")+" B1 WITH (NOLOCK) ON (B1.D_E_L_E_T_ <> '*') " + STR_PULA
			cQryz += " 										                                       AND (G1_FILIAL = B1.B1_FILIAL) " + STR_PULA
			cQryz += " 																			   AND (G1_COMP = B1.B1_COD) " + STR_PULA
			cQryz += " 																			   AND (B1.B1_RELCAT1 > '') " + STR_PULA
			cQryz += " 	                                    LEFT OUTER JOIN "+RetSqlName("SZ5")+" SZ5 WITH (NOLOCK) ON (SZ5.D_E_L_E_T_ <> '*') " + STR_PULA
			cQryz += " 										                                        AND (B1_RELCAT1 = Z5_EMB) "  + STR_PULA
			cQryz += " 	                              WHERE (SG1.D_E_L_E_T_ <> '*')  " + STR_PULA
			cQryz += " 				                    AND (SG1.G1_FILIAL = SB1.B1_FILIAL) " + STR_PULA
			cQryz += " 				                    AND (SG1.G1_COD = SB1.B1_COD) " + STR_PULA
			cQryz += " 				                    AND (B1.B1_RELCAT1 > '')),''), " + STR_PULA
			cQryz += " 				RELVOL2 = ISNULL(SZ51.Z5_RELVOL,'') " + STR_PULA
			cQryz += " 	             FROM "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) " + STR_PULA
			cQryz += " 	                     LEFT OUTER JOIN SZ5010 SZ51 WITH (NOLOCK) ON (SZ51.D_E_L_E_T_ <> '*') " + STR_PULA
			cQryz += " 						                                          AND (SUBSTRING(B1_COD,11,2) = SZ51.Z5_EMB) " + STR_PULA
			cQryz += " 	             WHERE (SB1.D_E_L_E_T_ <> '*') " + STR_PULA
			cQryz += " 				   AND (B1_FILIAL = '"+xFilial("SB1")+"') " + STR_PULA
			cQryz += " 				   AND (B1_COD = '"+TRV->B1_COD+"')) "  + STR_PULA
			cQryz += " 				     SELECT B1_COD,B1_DESC, RELVOL =  CASE WHEN RELVOL0 > '' THEN RELVOL0 WHEN RELVOL1 > '' THEN RELVOL1 ELSE RELVOL2 END " + STR_PULA
			cQryz += " 						FROM TMP " + STR_PULA

			If Select( "TSV" ) > 0
				DbSelectArea( "TSV" )
				DbCloseArea()
			Endif
			TCQuery cQryz ALIAS "TSV" NEW
			while !(TSV->(EoF()))
				If ( (Alltrim(TSV->RELVOL) = "" ) .OR. (Alltrim(TSV->RELVOL) = " " ) .OR. (Alltrim(TSV->RELVOL) = "0" ) ) // jose 28/06/2024 <= 0)
					/*-----------------------------    atÈ aqui Jose 04/07/2024 ----------*/
					_zConta += 1
					//                    aadd(aSemVolume, {TRV->B1_RELVOL, TRV->B1_COD, TRV->B1_DESC })
					aadd(aSemVolume, {0, _ZnUM, TSV->B1_COD, TSV->B1_DESC })
				EndIf
				DbSelectArea("TSV")
				DbSkip()
			EndDo
		EndIF
		DbSelectArea("TRV")
		DbSkip()
	EndDo

	DbCloseArea()
	/*     Voltar quando voltar a parte de atualizaÁ„o 18/06/2024
    If Len(aSemVolume) > 0
			If _nTipoBor = "0"
		       _zTipoBor = "                 "
		ElseIf _nTipoBor = "1"
		       _zTipoBor = "1 - glutinado    "
		ElseIf _nTipoBor = "2"
		       _zTipoBor = "2 - Deposito      "
		ElseIf _nTipoBor = "3"
		       _zTipoBor = "3 - Regiao-Retira "
		ElseIf _nTipoBor = "4"
		       _zTipoBor = "4 - ExportaÁ„o    "
		ELseIf _nTipoBor = "5"
		       _zTipoBor = "5 - Carga Fechada "
		ElseIf _nTipoBor = "8"
		       _zTipoBor = "8 - Carga-Matriz  "
		EndIf
	   DEFINE MsDIALOG oDlg TITLE ' Produto(s) Sem Volume(s)  -  ' +_zTipoBor  From 0, 4 To  nJanAltu, nJanLarg  Pixel

	   oBtnPesq := TButton():New(006, 590, "Atualizar", oDlg, {|| Processar()},  nLargBtn, 018, , oFontBtn, , .T., , , , , , )

	   oPnMaster := tPanel():New(030, 001, "", oDlg, , , , RGB(000,000,000), RGB(254,254,254), (nJanLarg/2)-1, (( nJanAltu - (nJanAltu * 0.15) )/2)-3)
	   oBrowser := fwBrowse():New()
       oBrowser:setOwner( oPnMaster )
       oBrowser:setDataArray()
       oBrowser:setArray( aSemVolume )
       oBrowser:SetLocate() // Habilita a LocalizaÁ„o de registros
       oBrowser:disableConfig()
       oBrowser:disableReport()
       oBrowser:SetFontBrowse(oFontSub)

//       oBrowser:AddMarkColumns({|| IIf(aBrowser[aSemVolume:nAt,01], "LBOK", "LBNO")},; //Code-Block image
//                               {|| SelectOne(aSemVolume, aBrowser)},; //Code-Block Double Click
//                               {|| SelectAll(aSemVolume, 01, aBrowser) }) //Code-Block Header Click

       oBrowser:addColumn({"Volume"      , {||aSemVolume[oBrowser:nAt,1]}, "N", pesqPict("SB1","B1_RELVOL") , 1, tamSx3("B1_RELVOL")[1]  ,tamSx3("B1_RELVOL")[1], .T. , , .F.,, "aSemVolume[oBrowser:nAt,1]",, .F., .T.,, "ETDESPES1"})
       oBrowser:addColumn({"Produto"     , {||aSemVolume[oBrowser:nAt,2]}, "C", pesqPict("SB1","B1_COD")    , 1, tamSx3("B1_COD")[1]     ,tamSx3("B1_COD")[1]   , .T. , , .F.,, "aSemVolume[oBrowser:nAt,2]",, .F., .T.,, "ETDESPES2"})
       oBrowser:addColumn({"DescriÁ„o"   , {||aSemVolume[oBrowser:nAt,3]}, "C", pesqPict("SB1","B1_DESC")   , 1, tamSx3("B1_DESC")[1]    ,tamSx3("B1_DESC")[1]  , .T. , , .F.,, "aSemVolume[oBrowser:nAt,3]",, .F., .T.,, "ETDESPES3"})

       oBrowser:SetEditCell( .T. )

       oBrowser:acolumns[1]:ledit     := .T.
       oBrowser:acolumns[2]:ledit     := .F.
       oBrowser:acolumns[3]:ledit     := .F.

       oBrowser:Activate(.T.)

       Activate MsDialog oDlg
    Endif
	Voltar quando voltar a parte de aturalizaÁ„o 18/06/2024       */
	//---------------------------------------------------------------------------------------------------
	If _zConta <> 0
		Messagebox("O Programa ser· encerrado!! Favor anotar o(s) CÛdigo(s) que aparecer·(„o) na Tela Seguinte!!   Para acertar o(s) Volume(s) do(s) Produto(s) OU Retira-lo(s) do Bordero !!","AtenÁ„o...",48)
		DEFINE MSDIALOG oDlg TITLE  "ATEN«√O                        Produto(s) Sem Volume(s) " FROM 0,0 TO 610,820 PIXEL  //240,500

		@ 10,10 LISTBOX oLbx FIELDS HEADER 'Volume' /*"Volume"*/, 'Pedido' /*"Pedido"*/, 'Produto  ' /*"Produto"*/, 'DescriÁ„o' SIZE 390,280 OF oDlg PIXEL // 230,95

		oLbx:SetArray( aSemVolume )
		oLbx:bLine     := {|| {aSemVolume[oLbx:nAt,1], aSemVolume[oLbx:nAt,2], aSemVolume[oLbx:nAt,3], aSemVolume[oLbx:nAt,4]}}
		oLbx:bLDblClick := {|| {oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2],oLbx:aArray[oLbx:nAt,3],oLbx:aArray[oLbx:nAt,4]}}}

		_vCodpro  := aSemVolume[oLbx:nAt,2]
		_vQtdevol := aSemVolume[oLbx:nAt,1]
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+_vCodPro, .t.)
		If Found()
			RecLock("SB1", .f.)
			SB1->B1_RELVOL := _vQtdevol
			MsUnLock()
		Endif

		DEFINE SBUTTON FROM 290,360 TYPE 1 ACTION (oDlg:End())  ENABLE OF oDlg //107,213
		ACTIVATE MSDIALOG oDlg CENTER
	EndIf
	//      Return
	/*------------------------------------------------------------------------------------------------------*/
	//-------    AtÈ aqui Jose 07/06/2024 -------------------------
	//-------------------------------------------------------------
	// Jose 14/09/2023   If Empty(Alltrim(cGet2Env))
	// Jose 14/09/2023		Messagebox("Informe o cÛdigo do BorderÙ de pedidos antes de consultar !","AtenÁ„o...",48)
	// Jose 14/09/2023		Return
	// Jose 14/09/2023    Endif

	If _zConta <> 0   //Voltar quando voltar a parte de aturalizaÁ„o 18/06/2024Sobre
		Return          //Voltar quando voltar a parte de aturalizaÁ„o 18/06/2024
	EndIf              //Voltar quando voltar a parte de aturalizaÁ„o 18/06/2024
	If Mv_Par02 = 1  // RelatÛrio por Pedido
		Cabec1 := "PEDIDO  PRODUTO           (BORD "+cGet2Env+")                   QTD FALTA       GRP  LOCALIZA«√O      PROVIS”RIO"
		cQry +=" SELECT C6_FILIAL, ZG_CODIGO, C6_NUM, ZG_LOCALIZ, C6_PRODUTO, B1_DESC, SUBSTRING(C6_PRODUTO,11,2) AS 'EMBA', B1_RELVOL, ( SELECT dbo.DetVol(C6_FILIAL,C6_PRODUTO) ) AS 'VOL', C6_QTDVEN, ISNULL(SUM(ZZK_QUANT),0) AS ZZK_QUANT, (C6_QTDVEN - ISNULL(SUM(ZZK_QUANT),0)) AS 'ZZK_FALTA', " + STR_PULA
		cQry +=" 'VOLUME' = ( ( ISNULL ( SUM ( ZZK_QUANT ),0 ) - C6_QTDVEN ) / ( SELECT dbo.DetVol ( C6_FILIAL,C6_PRODUTO ) ) * -1 ), " + STR_PULA
		cQry +=" 'GRPEMB'    =ISNULL((SELECT TOP 1 B1_GRUPO2 FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) " + STR_PULA
		cQry +=" LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ = '') AND (G1_FILIAL = SB1.B1_FILIAL) AND (G1_COMP = SB1.B1_COD)  WHERE (SG1.D_E_L_E_T_ = '') AND (G1_FILIAL = C6_FILIAL) AND (G1_COD = C6_PRODUTO) AND (SB1.B1_GRUPO LIKE 'E%') AND (SB1.B1_GRUPO2 > '')),'99')," + STR_PULA
		cQry +=" 'LOCALIZ'   =ISNULL((SELECT B2_LOCALIZ FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) WHERE B2_FILIAL = B1_FILIAL AND B2_COD = B1_COD AND B2_LOCAL = B1_LOCPAD AND SB2.D_E_L_E_T_ ='' ),''), " + STR_PULA
		cQry +=" 'ZZLLOCALIZ'=ISNULL((SELECT TOP 1 ZZL_LOCALI FROM "+RetSqlName("ZZL")+" ZZL WITH (NOLOCK) WHERE ZZL_FILIAL = B1_FILIAL AND ZZL_PRODUT = B1_COD AND ZZL.D_E_L_E_T_ ='' ),'') " + STR_PULA
		cQry +="	FROM "+RetSqlName("SZG")+" SZG WITH (NOLOCK) " + STR_PULA
		cQry +="	LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON ZG_FILIAL = C6_FILIAL AND SUBSTRING(ZG_PEDIDO,3,6) = C6_NUM AND SC6.D_E_L_E_T_ ='' AND C6_NOTA = '' " + STR_PULA
		//---------- Jose 18/09/2023  acrescentado -----------------------------------------------------------------------------------------
		cQry +="	INNER JOIN "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) ON ZZC_FILIAL = C6_FILIAL AND ZZC_PEDIDO = C6_NUM AND ZZC.D_E_L_E_T_ ='' AND ZZC_QUANTI > ZZC_RETIRA AND ZZC_DESPAC NOT IN('S') " + STR_PULA
		cQry +="                                       AND ZZC_SEPARA <> 'S'      AND ZZC_GAVETA <> '' " + STR_PULA
		If _nTipoBor <> "0"
			cQry +="	INNER JOIN "+RetSqlName("SZF")+" SZF WITH (NOLOCK) ON SZF.ZF_FILIAL = SZG.ZG_FILIAL AND SZF.ZF_CODIGO = SZG.ZG_CODIGO AND SZF.D_E_L_E_T_ = '' AND SZF.ZF_TIPOBOR = '"+_nTipoBor+"' " + STR_PULA
		EndIf
		//-----------------------------------------------------------------------------------------------------------------------------------
		cQry +="	LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) ON ZZK_FILIAL = C6_FILIAL AND ZZK_PEDIDO = C6_NUM AND ZZK_PRODUT = C6_PRODUTO AND ZZK.D_E_L_E_T_ = '' " + STR_PULA
		cQry +="    LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = C6_FILIAL AND B1_COD = C6_PRODUTO AND SB1.D_E_L_E_T_ ='' " + STR_PULA
		//   Jose acrecentado 23/10/2024 -----------------------------------------------
		// Jose 18/11/2024        If MV_Par03 = 1
		// Jose 18/11/2024		             cQry += " AND B1_ESTOQUE = 'S' " + STR_PULA
		// Jose 18/11/2024		EndIf
		// Jose 18/11/2024       If MV_Par03 = 2
		// Jose 18/11/2024		             cQry += " AND B1_ESTOQUE = 'N' " + STR_PULA
		// Jose 18/11/2024		EndIf
		//   Jose atÈ aqui  23/10/2024  -------------------------------------------------
		If (Alltrim(cGet2Env)) <> '' // Jose 14/09/2023
			cQry +="	WHERE ZG_CODIGO = '"+cGet2Env+"' AND" + STR_PULA  // Jose 14/09/2023
		Else // Jose 14/09/2023
			cQry +="    WHERE "  + STR_PULA // Jose 14/09/2023
		EndIf // Jose 14/09/2023
		//		cQry +="	WHERE ZG_CODIGO = '"+cGet2Env+"'"  // Inibido Jose 14/09/2023
		If Mv_Par01 = 1  // FILTRA OS SPRAYS DO RELAT”RIO
			cQry +="	SUBSTRING(C6_PRODUTO,4,2) NOT IN('55') AND " + STR_PULA // TIRADO O AND DA FRENTE E COLOCAR ATRAS
		Endif
		cQry +="     ZG_FILIAL   = '"+xFilial("SZG")+"'" + STR_PULA // TIRADO O AND DA FRENTE
		cQry +=" AND SZG.D_E_L_E_T_ ='' " + STR_PULA
		cQry +=" GROUP BY ZG_CODIGO, C6_NUM, ZG_LOCALIZ, B1_DESC, C6_PRODUTO, C6_QTDVEN, B1_FILIAL, B1_COD, B1_LOCPAD, C6_FILIAL, B1_RELVOL " + STR_PULA
		cQry +=" HAVING (C6_QTDVEN - ISNULL(SUM(ZZK_QUANT),0)) > 0 " + STR_PULA //<> 0 "
		cQry +=" ORDER BY 5,12,7,3  "  + STR_PULA // jose 18/09/2023 11,12,5,7,3 "    //" ORDER BY 10,11,12,5,7,3 "
	ElseIf Mv_Par02 = 2 // RelatÛrio por Grupo
		Cabec1 := "   GRUPO          (BORDERO "+cGet2Env+")            QTD FALTA       BORDERO"
		cQry +=" WITH TMP AS (SELECT C6_FILIAL, ZG_CODIGO, C6_PRODUTO, C6_NUM,  (C6_QTDVEN), ISNULL(SUM(ZZK_QUANT),0) AS ZZK_QUANT, 'GRPEMB' =ISNULL((SELECT TOP 1 B1_GRUPO2 FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) " + STR_PULA
		cQry +=" LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ = '') AND (G1_FILIAL = SB1.B1_FILIAL) AND (G1_COMP = SB1.B1_COD)  WHERE (SG1.D_E_L_E_T_ = '') AND (G1_FILIAL = C6_FILIAL) AND (G1_COD = C6_PRODUTO) AND (SB1.B1_GRUPO LIKE 'E%') AND (SB1.B1_GRUPO2 > '')),'99'), COUNT(ZZK_PRODUT) AS 'VOLBIP' " + STR_PULA
		cQry +=" FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) " + STR_PULA
		cQry +=" LEFT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH (NOLOCK) ON ZG_FILIAL = C6_FILIAL AND SUBSTRING(ZG_PEDIDO,3,6) = C6_NUM AND SZG.D_E_L_E_T_ ='' " + STR_PULA
		cQry +=" LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) ON SC6.C6_FILIAL = ZZK_FILIAL AND SC6.C6_NUM = ZZK_PEDIDO AND SC6.C6_PRODUTO = ZZK_PRODUT AND ZZK.D_E_L_E_T_ =''  " + STR_PULA
		cQry +=" WHERE SC6.D_E_L_E_T_ ='' AND C6_FILIAL ='"+xFilial("SC6")+"' AND C6_NOTA = '' "  + STR_PULA
		If Mv_Par01 = 1  // FILTRA OS SPRAYS DO RELAT”RIO
			cQry +=" AND SUBSTRING(C6_PRODUTO,4,2) NOT IN('55') "  + STR_PULA
		Endif
		If (Alltrim(cGet2Env)) <> '' // Jose 14/09/2023
			cQry +=" AND ZG_CODIGO ='"+cGet2Env+"'   " + STR_PULA // Jose 14/09/2023
		EndIf // Jose 14/09/2023
		cQry +=" AND LEN(C6_PRODUTO)=12 "  + STR_PULA // Jose 14/09/2023
		//		cQry +=" AND ZG_CODIGO ='"+cGet2Env+"' AND LEN(C6_PRODUTO)=12 " // Inibido Jose 14/09/2023
		cQry +=" GROUP BY C6_FILIAL, ZG_CODIGO, C6_PRODUTO, C6_QTDVEN, C6_NUM ) " + STR_PULA
		//   Jose 18/09/2023  acrescentado ---------------------------------------------------
		cQry +="	INNER JOIN ZZC010 ZZC WITH (NOLOCK) ON ZZC_FILIAL = C6_FILIAL AND ZZC_PEDIDO = C6_NUM AND ZZC.D_E_L_E_T_ ='' AND ZZC_QUANTI > ZZC_RETIRA AND ZZC_DESPAC NOT IN('S') " + STR_PULA
		cQry +="                                       AND ZZC_SEPARA <> 'S'      AND ZZC_GAVETA <> '' " + STR_PULA
		If _nTipoBor <> "0"
			cQry +="	INNER JOIN SZF010 SZF WITH (NOLOCK) ON SZF.ZF_FILIAL = SZG.ZG_FILIAL AND SZF.ZF_CODIGO = SZG.ZG_CODIGO AND SZF.D_E_L_E_T_ = '' AND SZF.ZF_TIPOBOR = '"+_nTipoBor+"' " + STR_PULA
		EndIf
		//------------------------------------------------------------------------------------
		cQry +=" SELECT TMP.ZG_CODIGO, SUM(C6_QTDVEN) AS C6_QTDVEN, ISNULL(SUM(ZZK_QUANT),0) AS ZZK_QUANT, (SUM(C6_QTDVEN) - ISNULL(SUM(ZZK_QUANT),0)) AS 'ZZK_FALTA', TMP.GRPEMB, ISNULL(X5_DESCRI,'SEM CLASSFICA«√O') AS X5_DESCRI  " + STR_PULA
		cQry +=" FROM TMP " + STR_PULA
		cQry +=" LEFT OUTER JOIN "+RetSqlName("SX5")+" SX5 WITH (NOLOCK) ON (SX5.D_E_L_E_T_ = '') AND (X5_FILIAL = '"+xFilial("SX5")+"') AND (X5_CHAVE = GRPEMB) AND SX5.D_E_L_E_T_ ='' AND X5_TABELA ='03' " + STR_PULA
		cQry +=" GROUP BY TMP.ZG_CODIGO, TMP.GRPEMB, X5_DESCRI " + STR_PULA
		cQry +=" HAVING (SUM(C6_QTDVEN) - ISNULL(SUM(ZZK_QUANT),0)) > 0 "  + STR_PULA //<> 0  "
		cQry +=" ORDER BY TMP.GRPEMB " + STR_PULA
	ElseIf Mv_Par02 = 3  // RelatÛrio por Produto
		//-----------------------------------------------------------------------------------------------------------------------------
		Cabec1 := "PRODUTO           (BORD "+cGet2Env+")                   QTD FALTA     DISPONÕVEL   LOCALIZA«√O      PROVIS”RIO"
		cQry +="WITH TMP AS ( SELECT SC6.C6_FILIAL, "  + STR_PULA
		cQry +="                     SC6.C6_NUM,  "    + STR_PULA
		cQry +="                     SZG.ZG_CODIGO, "  + STR_PULA
		cQry +="                     SC6.C6_PRODUTO, " + STR_PULA
		cQry +="                     SB1.B1_DESC, "    + STR_PULA
		cQry +="                     SC6.C6_QTDVEN  AS C6_QTDVEN, "   + STR_PULA
		cQry +="                     ISNULL( SUM( ZZK.ZZK_QUANT ), 0 ) AS ZZK_QUANT, ( ( SC6.C6_QTDVEN ) - ISNULL( SUM( ZZK.ZZK_QUANT ), 0 ) ) AS 'ZZK_FALTA', "     + STR_PULA
		cQry +=" 	                 SB1.B1_RELVOL, ( SELECT dbo.DetVol( SC6.C6_FILIAL, SC6.C6_PRODUTO ) ) AS 'VOL', "   + STR_PULA
		cQry +=" 	                 'VOLUME' = ( ( ISNULL( SUM (ZZK_QUANT),0) - (SC6.C6_QTDVEN) ) / ( SELECT dbo.DetVol (SC6.C6_FILIAL,SC6.C6_PRODUTO) ) * -1 ),  " + STR_PULA
		cQry +="                     'GRPEMB' = ISNULL( ( SELECT TOP 1 CMP.B1_GRUPO2 "                       + STR_PULA
		cQry +="                                            FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "   + STR_PULA
		cQry +="                                                  LEFT OUTER JOIN "+RetSqlName("SB1")+" CMP WITH (NOLOCK) ON CMP.D_E_L_E_T_ = '' "           + STR_PULA
		cQry +="                                                                                                         AND SG1.G1_FILIAL = CMP.B1_FILIAL " + STR_PULA
		cQry +="                                                                                                         AND SG1.G1_COMP   = CMP.B1_COD "    + STR_PULA
		cQry +="                                           WHERE ( SG1.D_E_L_E_T_ = '') "             + STR_PULA
		cQry +="                                             AND ( SG1.G1_FILIAL  = SC6.C6_FILIAL) "  + STR_PULA
		cQry +="                                             AND ( SG1.G1_COD     = SC6.C6_PRODUTO) " + STR_PULA
		cQry +="                                             AND ( CMP.B1_GRUPO LIKE 'E%') "          + STR_PULA
		cQry +="                                             AND ( CMP.B1_GRUPO2 > '' ) ),'99'), "    + STR_PULA
		//------   MEXER AQUI 02/09/2024   JOSE
		cQry +=" 			         'LOCALIZ' = ISNULL( ( SELECT SB2.B2_LOCALIZ "                          + STR_PULA
		cQry +="                                             FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) " + STR_PULA
		cQry +="                                            WHERE SB2.B2_FILIAL = SB1.B1_FILIAL "           + STR_PULA
		cQry +="                                              AND SB2.B2_COD    = SB1.B1_COD "              + STR_PULA
		cQry +="                                              AND SB2.B2_LOCAL  = SB1.B1_LOCPAD "           + STR_PULA
		cQry +="                                              AND SB2.D_E_L_E_T_ = '' ), '' ), "            + STR_PULA
		//------   AT… AQUI 02/09/2024   JOSE
		cQry +="                     'ZZLLOCALIZ' = ISNULL( ( SELECT TOP 1 ZZL_LOCALI "                         + STR_PULA
		cQry +="                                                FROM "+RetSqlName("ZZL")+" ZZL WITH (NOLOCK) "  + STR_PULA
		cQry +="                                               WHERE ZZL.ZZL_FILIAL = SB1.B1_FILIAL "           + STR_PULA
		cQry +="                                                 AND ZZL.ZZL_PRODUT = SB1.B1_COD "              + STR_PULA
		cQry +="                                                 AND ZZL.D_E_L_E_T_ = '' ), '' ), "             + STR_PULA
		cQry +="                     'SB2_03E30' = ISNULL( ( SELECT SUM(B2_QATU) AS B2_DISP "                        + STR_PULA
		cQry +="                                               FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) "                      + STR_PULA
		cQry +="                                              WHERE SB2.B2_FILIAL  = SB1.B1_FILIAL "                 + STR_PULA
		cQry +="                                                AND SB2.B2_COD     = SB1.B1_COD "                    + STR_PULA
		cQry +="                                                AND SB2.D_E_L_E_T_ ='' "                             + STR_PULA
		cQry +="                                                AND SB2.B2_LOCAL IN( '03','30','G3','A3' ) ), 0 ), " + STR_PULA
		cQry +="                     'ZZKQTD' = ISNULL( (  SELECT SUM(ZZK_QUANT) "                 + STR_PULA
		cQry +="                                             FROM "+RetSqlName("ZZK")+" ZK WITH (NOLOCK) "       + STR_PULA
		cQry +="                                            WHERE ZK.ZZK_FILIAL = SC6.C6_FILIAL  " + STR_PULA
		cQry +="                                              AND ZK.ZZK_PEDIDO = SC6.C6_NUM  "    + STR_PULA
		cQry +="                                              AND ZK.ZZK_PRODUT = SC6.C6_PRODUTO " + STR_PULA
		cQry +="                                              AND ZK.D_E_L_E_T_ = ''), 0 ) "       + STR_PULA
		cQry +="                FROM "+RetSqlName("SZG")+"  SZG WITH (NOLOCK) "               + STR_PULA
		cQry +="                     LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON SZG.ZG_FILIAL  = SC6.C6_FILIAL "               + STR_PULA
		cQry +="                                                                            AND SUBSTRING(SZG.ZG_PEDIDO, 3, 6 ) = SC6.C6_NUM " + STR_PULA
		cQry +="                                                                            AND SC6.D_E_L_E_T_ = '' AND SC6.C6_NOTA = '' "     + STR_PULA
		//   Jose 18/09/2023  acrescentado -----------------------------------------------------
		If (Alltrim(cGet2Env)) = '' // Jose 14/09/2023
			cQry +="	             INNER JOIN "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) ON ZZC_FILIAL = C6_FILIAL "                      + STR_PULA
			cQry +="                                                                   AND ZZC_PEDIDO = C6_NUM AND ZZC.D_E_L_E_T_ = '' " + STR_PULA
			cQry +="                                                                   AND ZZC_QUANTI > ZZC_RETIRA "                     + STR_PULA
			cQry +="                                                                   AND ZZC_DESPAC NOT IN('S') "                      + STR_PULA
			cQry +="                                                                   AND ZZC_SEPARA <> 'S'  "                          + STR_PULA
			cQry +="                                                                   AND ZZC_GAVETA <> '' "                            + STR_PULA
		EndIf
		If (Alltrim(cGet2Env)) <> '' // Jose 29/11/2023
			cQry +="	             LEFT OUTER JOIN "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) ON ZZC_FILIAL = C6_FILIAL "                      + STR_PULA
			cQry +="                                                                        AND ZZC_PEDIDO = C6_NUM AND ZZC.D_E_L_E_T_ = '' " + STR_PULA
			cQry +="                                                                        AND ZZC_QUANTI > ZZC_RETIRA "                     + STR_PULA
			cQry +="                                                                        AND ZZC_DESPAC NOT IN('S') "                      + STR_PULA
			cQry +="                                                                        AND ZZC_SEPARA <> 'S'  "                          + STR_PULA
			cQry +="                                                                        AND ZZC_GAVETA <> '' "                            + STR_PULA
		EndIf
		If _nTipoBor <> "0" // Jose 14/09/2023
			cQry +="	                 INNER JOIN "+RetSqlName("SZF")+" SZF WITH (NOLOCK) ON SZF.ZF_FILIAL = SZG.ZG_FILIAL "    + STR_PULA
			cQry +="                                                                    AND SZF.ZF_CODIGO = SZG.ZG_CODIGO "    + STR_PULA
			cQry +="                                                                    AND SZF.D_E_L_E_T_ = '' "              + STR_PULA
			cQry +="                                                                    AND SZF.ZF_TIPOBOR = '"+_nTipoBor+"' " + STR_PULA
			cQry +="                                                                    AND SZF.ZF_FLAG IN ('Y','X') "         + STR_PULA
		EndIf
		//------------------------------------------------------------------------------------
		cQry +=" 		             LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) ON ZZK.ZZK_FILIAL = SC6.C6_FILIAL "  + STR_PULA
		cQry +="                                                                            AND ZZK.ZZK_PEDIDO = SC6.C6_NUM "     + STR_PULA
		cQry +="                                                                            AND ZZK.ZZK_PRODUT = SC6.C6_PRODUTO " + STR_PULA
		cQry +="                                                                            AND ZZK.D_E_L_E_T_ = '' "             + STR_PULA
		cQry +="                     INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON SB1.B1_FILIAL  = SC6.C6_FILIAL "       + STR_PULA // LEFT OUTER
		cQry +="                                                                            AND SB1.B1_COD     = SC6.C6_PRODUTO " + STR_PULA
		cQry +="                                                                            AND SB1.D_E_L_E_T_ = '' "             + STR_PULA
		//----------------------------   Jose acrecentado 23/10/2024 --------------------------------------------------------------------
		// Jose 18/11/2024                                                                       If MV_Par03 = 1
		// Jose 18/11/2024 		                                                                    cQry += " AND B1_ESTOQUE = 'S' " + STR_PULA
		// Jose 18/11/2024 		                                                                 EndIf
		// Jose 18/11/2024                                                                       If MV_Par03 = 2
		// Jose 18/11/2024 		                                                                    cQry += " AND B1_ESTOQUE = 'N' " + STR_PULA
		// Jose 18/11/2024 		                                                                 EndIf
		//-----------------------------   Jose atÈ aqui  23/10/2024  -------------------------------------------------------------------
		If (Alltrim(cGet2Env)) <> '' // Jose 14/09/2023
			cQry +="           WHERE SZG.ZG_CODIGO = '"+cGet2Env+"' AND "      + STR_PULA // Jose 14/09/2023
		Else // Jose 14/09/2023
			cQry +="           WHERE "       + STR_PULA // Jose 14/09/2023
		EndIf // Jose 14/09/2023
		//		cQry +="              WHERE SZG.ZG_CODIGO = '"+cGet2Env+"' " // Inibido Jose 14/09/2023
		If Mv_Par01 = 1  // FILTRA OS SPRAYS DO RELAT”RIO
			cQry +="                 SUBSTRING( SC6.C6_PRODUTO, 4, 2 ) NOT IN('55') AND "      + STR_PULA // TIRADO AND DA FRENTE E COLOCADO ATRAS
		Endif
		cQry +="                     SZG.ZG_FILIAL  = '"+xFilial("SZG")+"' "      + STR_PULA // TIRADO A AND DA FRENTE
		cQry +="                 AND SZG.D_E_L_E_T_ = '' " + STR_PULA
		cQry +="            GROUP BY SZG.ZG_CODIGO, SC6.C6_NUM, SC6.C6_NOTA, SB1.B1_DESC, SC6.C6_PRODUTO, SB1.B1_FILIAL, SC6.C6_QTDVEN, SB1.B1_COD, "    + STR_PULA
		cQry +="                     SB1.B1_LOCPAD, SC6.C6_FILIAL, SB1.B1_RELVOL, ZZK.ZZK_QUANT ) "     + STR_PULA// ) "
		cQry +="         SELECT TMP.C6_FILIAL, "                              + STR_PULA
		cQry +="                TMP.ZG_CODIGO, "                              + STR_PULA
		cQry +="                TMP.C6_PRODUTO, "                             + STR_PULA
		cQry +="                SUBSTRING(TMP.C6_PRODUTO,11,2) AS 'EMBA',  "  + STR_PULA
		cQry +="                TMP.B1_DESC, "                                + STR_PULA
		cQry +=" 	            TMP.B1_RELVOL, "                              + STR_PULA
		cQry +="                TMP.C6_QTDVEN AS 'VENDIDO', "                 + STR_PULA
		//		cQry +="                SUM(TMP.C6_QTDVEN) AS 'VENDIDO', "  Jose 26/09/2023
		cQry +="                TMP.ZZKQTD         AS 'BIPADO', "             + STR_PULA
		cQry +="                TMP.GRPEMB, "                                 + STR_PULA
		cQry +=" 		  	    TMP.LOCALIZ, "                                + STR_PULA
		cQry +="                SUBSTRING(TMP.LOCALIZ,1,3) AS 'LOCA',  "      + STR_PULA
		cQry +="                TMP.C6_NUM, "                                 + STR_PULA
		cQry +="                TMP.ZZLLOCALIZ, "                             + STR_PULA
		cQry +="                ( TMP.SB2_03E30 - TMP.ZZKQTD )  AS 'SALDO', " + STR_PULA
		cQry +="                ZZK_FALTA = ( TMP.C6_QTDVEN - TMP.ZZKQTD ), " + STR_PULA
		//		cQry +="                ZZK_FALTA = (SUM(TMP.C6_QTDVEN) - TMP.ZZKQTD ),  "  Jose 26/09/2023
		cQry +="                'VOLUME' = ROUND( ( ( ISNULL ( (TMP.ZZKQTD ),0 ) - SUM ( TMP.C6_QTDVEN ) ) / ( SELECT dbo.DetVol ( TMP.C6_FILIAL,TMP.C6_PRODUTO ) ) * -1 ),2 ) "   + STR_PULA
		cQry +=" 		FROM TMP  WHERE TMP.C6_PRODUTO <> '' " //AND TMP.ZZK_FALTA > 0 " //TMP.VOLUME > 0 "
		cQry +="    GROUP BY TMP.C6_FILIAL, TMP.ZG_CODIGO, TMP.C6_PRODUTO, SUBSTRING(TMP.C6_PRODUTO,11,2), TMP.B1_DESC, "                   + STR_PULA
		cQry +=" 		     TMP.GRPEMB, TMP.LOCALIZ, TMP.ZZLLOCALIZ, TMP.SB2_03E30, TMP.ZZKQTD, TMP.B1_RELVOL, TMP.C6_QTDVEN, TMP.C6_NUM " + STR_PULA
		cQry +="    ORDER BY 3, 11 , 4 ASC "      + STR_PULA //Jose 18/09/2023 11, 4 ASC "
	Endif
	//------------------------------------------------------------------------------------------------------------------------------
	TCQuery cQry ALIAS "TCQ" NEW
	//----------------------Excel --------------------------------------
	//Criando o objeto que ir· gerar o conte˙do do Excel
	oFWMsExcel := FWMSExcel():New()
	If Mv_Par02 = 1   // RelatÛrio por Pedido
		//Aba 01
		oFWMsExcel:AddworkSheet("Bordero1") //N„o utilizar n˙mero junto com sinal de menos. Ex.: 1-
		//Criando a Tabela
		If _nTipoBor = "0"
			__nTipoBor = "                "
		ElseIf _nTipoBor = "1"
			__nTipoBor = "1-Aglutinado    "
		ElseIf _nTipoBor = "2"
			__nTipoBor = "2-Deposito - GRU"
		ElseIf _nTipoBor = "3"
			__nTipoBor = "3-Regiao-Retira "
		ElseIf _nTipoBor = "4"
			__nTipoBor = "4-ExportaÁ„o    "
		ELseIf _nTipoBor = "5"
			__nTipoBor = "5-Carga Fechada "
		ElseIf _nTipoBor = "8"
			__nTipoBor = "8-Carga-Matriz  "
		ElseIf _nTipoBor = "9" //Jozse 11/11/20204
			__nTipoBor = "9-Deposito - ARA" //Jozse 11/11/20204
		EndIf
		//  Jose 23/10/2024 -------------------------------------------
		// Jose 18/11/2024         If Mv_Par03 == 1
		// Jose 18/11/2024 		   __nControla = "Estoque        "
		// Jose 18/11/2024 		ElseIf Mv_Par03 == 2
		// Jose 18/11/2024 		   __nControla = "EspecÌfico     "
		// Jose 18/11/2024 		ElseIf Mv_Par03 == 3
		// Jose 18/11/2024 		   __nControla = "Ambos          "
		// Jose 18/11/2024 		EndIf
		//  Jose 23/10/2024   ate   aqui -----------------------------------
		ccabecalho :="BRFATX66    "+__nTipoBor+"        Data.: "+DTOC(dDataBase)+"  AS  "+Time()+ " "+"RelaÁ„o de Produtos n„o Comprados no Bordero "+cGet2Env+     "   "     +"   Por Pedido"  // Jose 18/11/2024  __nControla+
		//Criando Colunas
		oFWMsExcel:AddTable("Bordero1",ccabecalho) // Adiciona a tabela
		oFWMsExcel:AddColumn("Bordero1",ccabecalho,"PEDIDO     ",1)
		oFWMsExcel:AddColumn("Bordero1",ccabecalho,"PRODUTO    ",1)
		oFWMsExcel:AddColumn("Bordero1",ccabecalho,"EMB.       ",1)
		oFWMsExcel:AddColumn("Bordero1",ccabecalho,"DESCRI«√O  ",1)
		oFWMsExcel:AddColumn("Bordero1",ccabecalho,"GRP        ",1)
		oFWMsExcel:AddColumn("Bordero1",ccabecalho,"PROVIS”RIO1",1) // Jose 29/08/2023
		oFWMsExcel:AddColumn("Bordero1",ccabecalho,"PROVIS”RIO2",1) // Jose 29/08/2023
		oFWMsExcel:AddColumn("Bordero1",ccabecalho,"LOCALIZA«√O",1)
		oFWMsExcel:AddColumn("Bordero1",ccabecalho,"LOCALIZA A3",1) // Jose 02/09/2024
		oFWMsExcel:AddColumn("Bordero1",ccabecalho,"LOCALIZA G3",1) // Jose 02/09/2024
		oFWMsExcel:AddColumn("Bordero1",ccabecalho,"VOLUME     ",1)
		oFWMsExcel:AddColumn("Bordero1",ccabecalho,"QTDE_FALTA ",1)

		//Criando as Linhas... Enquanto n„o for fim da query
		While !(TCQ->(EoF()))
			//----------------------------------------------------------
			cQry3  =" SELECT TOP 2 ZZL_LOCALI, ZZL_LOCALI "             + STR_PULA
			cQry3 +="   FROM "+RetSqlName("ZZL")+" ZZLZ WITH (NOLOCK) " + STR_PULA
			cQry3 +="  WHERE ZZLZ.ZZL_FILIAL = '"+TCQ->C6_FILIAL+"' "   + STR_PULA
			cQry3 +="    AND ZZLZ.ZZL_PRODUT = '"+TCQ->C6_PRODUTO+"' "  + STR_PULA
			cQry3 +="    AND ZZLZ.D_E_L_E_T_ = '' "                     + STR_PULA
			TCQuery cQry3 ALIAS "TCQZ" NEW
			cLOCALIZ1 = ""
			cLOCALIZ2 = ""
			cCont = 0
			While !(TCQZ->(EoF()))
				If cCont == 0
					cLOCALIZ1  := TCQZ->ZZL_LOCALI
				Else
					cLOCALIZ2  := TCQZ->ZZL_LOCALI
				EndIf
				cCont := cCont + 1
				//Pulando Registro
				TCQZ->(DbSkip())
			EndDo
			TCQZ->(DbCloseArea())
			//--------------------------------------------------------------

			//------ Acrescentado Jose 02/09/2024  ----------------------------------------------------
			cQry3  =" SELECT B2_LOCAL, B2_LOCALIZ " + STR_PULA
			cQry3 +="   FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) "  + STR_PULA
			cQry3 +="  WHERE SB2.B2_FILIAL = '"+TCQ->C6_FILIAL+"' "  + STR_PULA
			cQry3 +="    AND SB2.B2_COD    = '"+TCQ->C6_PRODUTO+"' " + STR_PULA
			cQry3 +="    AND SB2.B2_LOCAL IN ('G3','A3') "	 + STR_PULA
			cQry3 +="    AND SB2.D_E_L_E_T_ = '' " + STR_PULA
			TCQuery cQry3 ALIAS "TCQGA" NEW
			cLOCALIZG3 = ""
			cLOCALIZA3 = ""
			While !(TCQGA->(EoF()))
				If TCQGA->B2_LOCAL = 'G3'
					cLOCALIZG3  := TCQGA->B2_LOCALIZ
				Else
					cLOCALIZA3  := TCQGA->B2_LOCALIZ
				EndIf
				//Pulando Registro
				TCQGA->(DbSkip())
			EndDo
			TCQGA->(DbCloseArea())
			//--------   AtÈ Aqui Jose 02/09/2024------------------------------------------------------

			oFWMsExcel:AddRow("Bordero1",ccabecalho,{;
				TCQ->C6_NUM,;
				TCQ->C6_PRODUTO,;
				TCQ->EMBA,;
				Substr(TCQ->B1_DESC,1,30),;
				TCQ->GRPEMB,;
				_cLOCALIZ1:=cLOCALIZ1,;
				_cLOCALIZ2:=cLOCALIZ2,;
				TCQ->LOCALIZ,;
				_cLOCALIZA3:=CLOCALIZA3,; // JOSE 02/09/2024
				_cLOCALIZG3:=cLOCALIZG3,; // JOSE 02/09/2024
				TCQ->VOLUME,;
				TCQ->ZZK_FALTA;
				})
			//Pulando Registro
			TCQ->(DbSkip())
		EndDo
		//Ativando o arquivo e gerando o xml
		oFWMsExcel:Activate()
		MsgRun("Processando...","Aguarde Gerando arquivo em Excel...",{|| oFWMsExcel:GetXMLFile(cArquivo) } )
		//Abrindo o excel e abrindo o arquivo xml
		oExcel := MsExcel():New()           //Abre uma nova conex„o com ExcelVOLUME
		oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
		oExcel:SetVisible(.T.)              //Visualiza a planilha
		oExcel:Destroy()                    //Encerra o processo do gerenciador de tarefas
		TCQ->(DbCloseArea())
		RestArea(aAreaa)

	ElseIf Mv_Par02 = 2   // RelatÛrio por Grupo
		//Aba 01
		oFWMsExcel:AddworkSheet("Bordero2") //N„o utilizar n˙mero junto com sinal de menos. Ex.: 1-
		//Criando a Tabela
		If _nTipoBor = "0"
			__nTipoBor = "                "
		ElseIf _nTipoBor = "1"
			__nTipoBor = "1-Aglutinado    "
		ElseIf _nTipoBor = "2"
			__nTipoBor = "2-Deposito - GRU"
		ElseIf _nTipoBor = "3"
			__nTipoBor = "3-Regiao-Retira "
		ElseIf _nTipoBor = "4"
			__nTipoBor = "4-ExportaÁ„o    "
		ELseIf _nTipoBor = "5"
			__nTipoBor = "5-Carga Fechada "
		ElseIf _nTipoBor = "8"
			__nTipoBor = "8-Carga-Matriz  "
		ElseIf _nTipoBor = "9" //Jozse 11/11/20204
			__nTipoBor = "9-Deposito - ARA" //Jozse 11/11/20204
		EndIf
		//  Jose 23/10/2024 -------------------------------------------
		// Jose 18/11/2024          If Mv_Par03 == 1
		// Jose 18/11/2024  		   __nControla = "Estoque        "
		// Jose 18/11/2024  		ElseIf Mv_Par03 == 2
		// Jose 18/11/2024  		   __nControla = "EspecÌfico     "
		// Jose 18/11/2024  		ElseIf Mv_Par03 == 3
		// Jose 18/11/2024  		   __nControla = "Ambos          "
		// Jose 18/11/2024  		EndIf
		//  Jose 23/10/2024   ate   aqui -----------------------------------
		ccabecalho :="BRFATX66   "+__nTipoBor+  "     Data.: "+DTOC(dDataBase)+" AS "+Time()+ " "+"RelaÁ„o de Produtos n„o Comprados no Bordero "+cGet2Env+"   "     +    "  Por Grupo" // Jose 18/11/2024   +__nControla
		//Criando Colunas
		oFWMsExcel:AddTable("Bordero2",ccabecalho) // Adiciona a tabela
		oFWMsExcel:AddColumn("Bordero2",ccabecalho,"GRP        ",1)
		oFWMsExcel:AddColumn("Bordero2",ccabecalho,"DESCRI«√O  ",1)
		oFWMsExcel:AddColumn("Bordero2",ccabecalho,"QTDE_FALTA ",1)
		oFWMsExcel:AddColumn("Bordero2",ccabecalho,"BORDERO"    ,1) // jOSE 14/09/2023

		While !(TCQ->(EoF()))
			oFWMsExcel:AddRow("Bordero2",ccabecalho,{;
				TCQ->GRPEMB,;
				Substr(TCQ ->X5_DESCRI,1,30),;
				TCQ->ZZK_FALTA,;
				TCQ->ZG_CODIGO;
				})
			//Pulando Registro
			TCQ->(DbSkip())
		EndDo
		//Ativando o arquivo e gerando o xml
		oFWMsExcel:Activate()
		MsgRun("Processando...","Aguarde Gerando arquivo em Excel...",{|| oFWMsExcel:GetXMLFile(cArquivo) } )
		//Abrindo o excel e abrindo o arquivo xml
		oExcel := MsExcel():New()           //Abre uma nova conex„o com Excel
		oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
		oExcel:SetVisible(.T.)              //Visualiza a planilha
		oExcel:Destroy()                    //Encerra o processo do gerenciador de tarefas
		TCQ->(DbCloseArea())
		RestArea(aAreaa)
	ElseIf Mv_Par02 == 3 // RelatÛrio por Produto
		//Aba 01
		oFWMsExcel:AddworkSheet("Bordero3") //N„o utilizar n˙mero junto com sinal de menos. Ex.: 1-
		//Criando a Tabela
		If _nTipoBor = "0"
			__nTipoBor = "                "
		ElseIf _nTipoBor = "1"
			__nTipoBor = "1-Aglutinado    "
		ElseIf _nTipoBor = "2"
			__nTipoBor = "2-Deposito - GRU"
		ElseIf _nTipoBor = "3"
			__nTipoBor = "3-Regiao-Retira "
		ElseIf _nTipoBor = "4"
			__nTipoBor = "4-ExportaÁ„o    "
		ELseIf _nTipoBor = "5"
			__nTipoBor = "5-Carga Fechada "
		ElseIf _nTipoBor = "8"
			__nTipoBor = "8-Carga-Matriz  "
		ElseIf _nTipoBor = "9" //Jozse 11/11/20204
			__nTipoBor = "9-Deposito - ARA" //Jozse 11/11/20204
		EndIf
		// Jose 23/10/2024 -------------------------------------------
		// Jose 18/11/2024  If Mv_Par03 == 1
		// Jose 18/11/2024	  __nControla = "Estoque        "
		// Jose 18/11/2024	ElseIf Mv_Par03 == 2
		// Jose 18/11/2024	  __nControla = "EspecÌfico     "
		// Jose 18/11/2024	ElseIf Mv_Par03 == 3
		// Jose 18/11/2024	  __nControla = "Ambos          "
		// Jose 18/11/2024	EndIf
		// Jose 23/10/2024   ate   aqui -----------------------------------
		ccabecalho :="BRFATX66    "+__nTipoBor+"     Data.: "+DTOC(dDataBase)+"  AS  "+Time()+ " "+"RelaÁ„o de Produtos n„o Comprados no Bordero "+cGet2Env+   "    "      +     " Por Produto" // Jose 18/11/2024 +__nControla
		//Criando Colunas
		oFWMsExcel:AddTable("Bordero3",ccabecalho) // Adiciona a tabela
		oFWMsExcel:AddColumn("Bordero3",ccabecalho,"PRODUTO    ",1)
		oFWMsExcel:AddColumn("Bordero3",ccabecalho,"EMB.     "  ,1)
		oFWMsExcel:AddColumn("Bordero3",ccabecalho,"DESCRI«√O  ",1)
		oFWMsExcel:AddColumn("Bordero3",ccabecalho,"DISP. MAT√O",2)
		oFWMsExcel:AddColumn("Bordero3",ccabecalho,"DISP. A3"   ,2)
		oFWMsExcel:AddColumn("Bordero3",ccabecalho,"DISP. G3"   ,2)	// Jose 10/07/2024
		oFWMsExcel:AddColumn("Bordero3",ccabecalho,"PROVIS”RIO1",2) // Jose 29/08/2023
		oFWMsExcel:AddColumn("Bordero3",ccabecalho,"PROVIS”RIO2",2) // Jose 29/08/2023
		oFWMsExcel:AddColumn("Bordero3",ccabecalho,"LOCALIZA«√O",2)
		oFWMsExcel:AddColumn("Bordero3",ccabecalho,"LOCALIZA A3",1) // Jose 02/09/2024
		oFWMsExcel:AddColumn("Bordero3",ccabecalho,"LOCALIZA G3",1) // Jose 02/09/2024
		oFWMsExcel:AddColumn("Bordero3",ccabecalho,"SALDO P1/P2",3) // Jose 04/10/2023
		oFWMsExcel:AddColumn("Bordero3",ccabecalho,"VOLUME    " ,3)
		oFWMsExcel:AddColumn("Bordero3",ccabecalho,"QTDE_FALTA" ,3)
		oFWMsExcel:AddColumn("Bordero3",ccabecalho,"DAT. APROV" ,3) // Jose 23/10/2024
		oFWMsExcel:AddColumn("Bordero3",ccabecalho,"SUGEST√O COMPRA" ,3) // Jose 17/02/2025

		//Criando as Linhas... Enquanto n„o for fim da query
		//    Jose 18/09/2023 --------------------------------------------------
		//--------   Jose 29/08/2023 -------------------------------------------
		If (Alltrim(cGet2Env)) = ''
			_cProduto    = TCQ->C6_PRODUTO
			_cDescricao  = ''
			_cSaldo      = 0
			_cSaldoA3    = 0    //  Jose 10/07/2024
			_cSaldoG3    = 0
			_cZZLLOCALIZ = ''
			_cLOCALIZ1   = ''
			_cLOCALIZ2   = ''
			_cLOCALIZA3  = '' // JOSE 02/09/2024
			_cLOCALIZG3  = '' // JOSE 02/09/2024
			_cVOLUME	    = 0
			_cFALTA      = 0
			_cDtApr      = '' // JOSE 23/10/2024
			_cSugestao   = '' // JOSE 17/02/2025
			While !(TCQ->(EoF()))
				If TCQ->ZZK_FALTA > 0
					If TCQ->C6_PRODUTO = _cProduto
						//--------------------------------------------------------------
						cQry3  =" SELECT TOP 2 ZZL_LOCALI, ZZL_LOCALI " + STR_PULA
						cQry3 +="   FROM "+RetSqlName("ZZL")+" ZZLZ WITH (NOLOCK) "  + STR_PULA
						cQry3 +="  WHERE ZZLZ.ZZL_FILIAL = '"+TCQ->C6_FILIAL+"' "  + STR_PULA
						cQry3 +="    AND ZZLZ.ZZL_PRODUT = '"+TCQ->C6_PRODUTO+"' " + STR_PULA
						//cQry3 +="    AND SUBSTRING(ZZLZ.ZZL_LOCALI,1,1) <> 'R' " + STR_PULA  // Jose 01/04/2025
						cQry3 +="    AND (SUBSTRING(ZZLZ.ZZL_LOCALI,1,2) <> 'F1'  AND SUBSTRING(ZZLZ.ZZL_LOCALI,1,2) <> 'F2' " + STR_PULA  // Jose 01/04/2025
						cQry3 +="    AND  SUBSTRING(ZZLZ.ZZL_LOCALI,1,3) <> ' F1' AND SUBSTRING(ZZLZ.ZZL_LOCALI,1,3) <> ' F2') " + STR_PULA  // Jose 01/04/2025
						cQry3 +="    AND ZZLZ.D_E_L_E_T_ = '' " + STR_PULA
						TCQuery cQry3 ALIAS "TCQZ" NEW
						cLOCALIZ1 = ""
						cLOCALIZ2 = ""
						cCont = 0
						While !(TCQZ->(EoF()))
							If cCont == 0
								cLOCALIZ1  := TCQZ->ZZL_LOCALI
							Else
								cLOCALIZ2  := TCQZ->ZZL_LOCALI
							EndIf
							cCont := cCont + 1
							//Pulando Registro
							TCQZ->(DbSkip())
						EndDo
						TCQZ->(DbCloseArea())

						//-------------------------------------------------------------------------------
						//------ Acrescentado Jose 02/09/2024  ----------------------------------------------------
						cQry3  =" SELECT B2_LOCAL, B2_LOCALIZ " + STR_PULA
						cQry3 +="   FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) "  + STR_PULA
						cQry3 +="  WHERE SB2.B2_FILIAL = '"+TCQ->C6_FILIAL+"' "  + STR_PULA
						cQry3 +="    AND SB2.B2_COD    = '"+TCQ->C6_PRODUTO+"' " + STR_PULA
						cQry3 +="    AND SB2.B2_LOCAL IN ('G3','A3') "	 + STR_PULA
						cQry3 +="    AND SB2.D_E_L_E_T_ = '' " + STR_PULA
						TCQuery cQry3 ALIAS "TCQGA" NEW
						cLOCALIZA3 = ""
						cLOCALIZG3 = ""
						While !(TCQGA->(EoF()))
							If TCQGA->B2_LOCAL = 'G3'
								cLOCALIZG3  := TCQGA->B2_LOCALIZ
							Else
								cLOCALIZA3  := TCQGA->B2_LOCALIZ
							EndIf
							//Pulando Registro
							TCQGA->(DbSkip())
						EndDo
						TCQGA->(DbCloseArea())
						//--------   AtÈ Aqui Jose 02/09/2024------------------------------------------------------
						//--------------   Jose 06/10/2023 ----------------------------------------------
						cQry3  =" WITH TMP AS( " + STR_PULA
						cQry3 +="   SELECT B2_FILIAL, B2_COD, B2_LOCAL, B2_QATU, B2_RESERVA "  + STR_PULA
						cQry3 +="     FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) " + STR_PULA
						cQry3 +="    WHERE SB2.D_E_L_E_T_ ='' "  + STR_PULA
						cQry3 +="      AND B2_FILIAL = '"+TCQ->C6_FILIAL+"' " + STR_PULA
						cQry3 +="      AND B2_COD = '"+TCQ->C6_PRODUTO+"'" + STR_PULA
						cQry3 +="      AND B2_LOCAL IN('03','30','G3','A3')) " + STR_PULA   //--('03','30','P1','P2','G3')
						cQry3 +="   SELECT B2_COD, B2_LOCAL AS 'ALMOXARIFADO', B2_QATU AS 'SALDO TOTAL', " + STR_PULA
						cQry3 +="          B2_RESERVA AS 'RESERVA PADR√O SISTEMA', " + STR_PULA
						cQry3 +="          ISNULL(SUM(C6_QTDVEN),0) AS 'VENDIDO', " + STR_PULA
						cQry3 +="          ISNULL(SUM(ZZK_QUANT),0) AS 'SEPARADO', " + STR_PULA
						cQry3 +="          'DISPONIVEL' = ((B2_QATU) - ISNULL(SUM(ZZK_QUANT),0)) FROM TMP " + STR_PULA
						cQry3 +="             LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON C6_FILIAL = B2_FILIAL AND B2_LOCAL = C6_LOCAL " + STR_PULA
						cQry3 +="                                       AND C6_PRODUTO = B2_COD AND C6_NOTA ='' AND SC6.D_E_L_E_T_ ='' " + STR_PULA
						cQry3 +="             LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM AND C5_APROVA ='1'  " + STR_PULA
						cQry3 +="                                       AND C5_TIPO ='N' AND SC5.D_E_L_E_T_ ='' " + STR_PULA
						cQry3 +="             LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON F4_FILIAL = F4_FILIAL AND C6_TES = F4_CODIGO AND F4_ESTOQUE ='S' " + STR_PULA
						cQry3 +="                                       AND SF4.D_E_L_E_T_ ='' " + STR_PULA
						cQry3 +="             LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) ON ZZK_FILIAL = C6_FILIAL AND ZZK_PRODUT = C6_PRODUTO " + STR_PULA
						cQry3 +="                                       AND ZZK_PEDIDO = C6_NUM  AND ZZK.D_E_L_E_T_ ='' " + STR_PULA
						cQry3 +="   GROUP BY B2_COD, B2_LOCAL, B2_QATU, B2_RESERVA "  + STR_PULA
						TCQuery cQry3 ALIAS "TCQB2" NEW
						_cDisp   = 0
						_cDispA3 = 0   //  Jose 10/07/2024
						_cDispG3 = 0
						While !(TCQB2->(EoF()))
							If (TCQB2->ALMOXARIFADO = "03" .OR. TCQB2->ALMOXARIFADO = "30") // Jose 02/09/2024
								_cDisp  := _cDisp + TCQB2->DISPONIVEL // jose 30/08/2024 separa aqui
							EndIf // jose 02/09/2024
							If TCQB2->ALMOXARIFADO = "G3"
								_cDispG3 := _cDispG3 + TCQB2->DISPONIVEL
							EndIf
							If TCQB2->ALMOXARIFADO = "A3"    // Jose 10/07/2024
								_cDispA3 := _cDispA3 + TCQB2->DISPONIVEL   // Jose 10/07/2024
							EndIf  // Jose 10/07/2024
							//Pulando Registro
							TCQB2->(DbSkip())
						EndDo
						TCQB2->(DbCloseArea())
						//----------------------------------------------------------------------------------------
						//------ Acrescentado Jose 23/10/2024  ----------------------------------------------------
						If Select( "TCQSC5" ) > 0
							DbSelectArea( "TCQSC5" )
							DbCloseArea()
						EndIf
						cQry3  =" SELECT " + STR_PULA
						cQry3 +="   CASE " + STR_PULA
						cQry3 +="       WHEN C5_DTAPR = '' THEN C5_EMISSAO " + STR_PULA
						cQry3 +="       ELSE C5_DTAPR  END AS C5_DTAPR  " + STR_PULA
						cQry3 +="   FROM "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) "  + STR_PULA
						cQry3 +="  WHERE SC5.C5_FILIAL = '"+TCQ->C6_FILIAL+"' "  + STR_PULA
						cQry3 +="    AND SC5.C5_NUM    = '"+TCQ->C6_NUM+"' " + STR_PULA
						cQry3 +="    AND SC5.D_E_L_E_T_ = '' " + STR_PULA
						TCQuery cQry3 ALIAS "TCQSC5" NEW
						//TCQSC5->(DbCloseArea())
						//--------- Jose 23/10/2024 atÈ aqui -------------------------------------
						If LEN(TCQ->C6_PRODUTO) >= 12
							_cEmb = TCQ->EMBA
						Else
							_cEmb = TCQ->B1_RELVOL
						EndIf
						_cDescricao  = Substr(TCQ->B1_DESC,1,30)
						_cSaldo      = _cDisp
						_cSaldoA3    = _cDispA3    // Jose 10/07/2024
						_cSaldoG3    = _cDispG3
						_cLOCALIZ1   = cLOCALIZ1
						_cLOCALIZ2   = cLOCALIZ2
						_cZZLLOCALIZ = TCQ->LOCALIZ
						_cLOCALIZA3  = cLOCALIZA3 // Jose 02/09/2024
						_cLOCALIZG3  = cLOCALIZG3 // Jose 02/09/2024
						_cVOLUME     = _cVOLUME + TCQ->VOLUME
						_cFALTA      = _cFALTA  + TCQ->ZZK_FALTA
						_cDtApr      = ctod(substr(TCQSC5->C5_DTAPR,7,2)+"/"+substr(TCQSC5->C5_DTAPR,5,2)+"/"+substr(TCQSC5->C5_DTAPR,1,4)) // Jose 23/10/2024
					Else
						//---- Jose 04/10/2023 ------------------------------------------------------------
						_cP1P2 = 0
						cQry3  =" SELECT ISNULL( SUM( B2_QATU ), 0 ) AS 'P1P2' " + STR_PULA
						cQry3 +="  FROM  "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) "  + STR_PULA
						cQry3 +=" WHERE D_E_L_E_T_ = '' " + STR_PULA
						cQry3 +="   AND B2_FILIAL = '"+TCQ->C6_FILIAL+"' " + STR_PULA
						cQry3 +="   AND B2_COD = '"+_cPRODUTO+"' " + STR_PULA
						cQry3 +="   AND B2_LOCAL IN ('P1','P2')" + STR_PULA
						TCQuery cQry3 ALIAS "TCQSB2" NEW
						While !(TCQSB2->(EoF()))
							_cP1P2  := TCQSB2->P1P2
							//Pulando Registro
							TCQSB2->(DbSkip())
						EndDo
						TCQSB2->(DbCloseArea())
						//----------------------------------------------------------------------------------
						//      Jose 17/02/2025 -----------------------------------------------------------
						cQry  =" SELECT ZF_TIPOBOR " + STR_PULA
						cQry +="   FROM "+RetSqlName("SZF")+" SZF WITH (NOLOCK) " + STR_PULA
						Cqry +=" WHERE SZF.ZF_FILIAL = '"+TCQ->C6_FILIAL+"' " + STR_PULA
						cQry +="   AND SZF.ZF_CODIGO = '"+TCQ->ZG_CODIGO+"' " + STR_PULA
						cQry +="   AND SZF.D_E_L_E_T_ = '' " + STR_PULA
						TCQuery cQry ALIAS "TCQSZF" NEW
						_cSZF:= ""
						While !(TCQSZF->(EoF()))
							_cSZF  := TCQSZF->ZF_TIPOBOR
							//Pulando Registro
							TCQSZF->(DbSkip())
						EndDo
						TCQSZF->(DbCloseArea())
						_cSugestao :=  ""
						DO CASE
							Case _cSZF = "2" .AND. _cDispg3 > 0 .AND. _cDispg3 >= _cSaldo .AND. Substring(_cZZLLOCALIZ,1,2) = "GF" // _nTipoBor = "2" .AND.
								_cSugestao := "GUARULHOS"
								//Case _cDispA3 >= _cFalta .AND. _cSaldo < _cFalta .AND. _cDispA3 > 0  .OR. _cDispg3 < 0 //  .AND. _cLOCALIZ1 = "" .AND. _cLOCALIZ2 = "")
							Case ((_cDispA3 >0) .AND. (_cP1P2 <=0)) .AND. (  (_cDispA3 >= _cFalta .AND. _cSaldo < _cFalta) .OR. (( _cDispg3 <0 .AND. (_cSaldo+_cDispg3)  < _cDispA3 )) )  //  .AND. _cLOCALIZ1 = "" .AND. _cLOCALIZ2 = "")
								_cSugestao := "ARARAQUARA"
							Case _cFalta <= _cSaldo .OR. _cP1P2 > 0  .OR. (_cSaldo > 0 .AND. (_cLOCALIZ1 <> "" .OR. _cLOCALIZ2 <> ""))
								_cSugestao :=  "MAT√O"
							Case _cSugestao = ""
								_cSugestao :=  "ANALISAR"
						EndCase
						//    Ate Aqui Jose 17/02/2025 ---------------------------------------------------
						oFWMsExcel:AddRow("Bordero3",ccabecalho,{;
							_cPRODUTO,;
							_cEmb,;
							_cDescricao,;
							_cSALDO,;
							_cSaldoA3,;   // Jose 10/07/2024
							_cSaldoG3,;
							_cLOCALIZ1,;
							_cLOCALIZ2,;
							_cZZLLOCALIZ,;
							_cLOCALIZA3,; // Jose 02/09/2024
							_cLOCALIZG3,; // Jose 02/09/2024
							_cP1P2,;
							_cVOLUME,;
							_cFALTA,;
							_cDtApr,; // Jose 23/10/2024
							_cSugestao; // Jose 17/02/2025
							})
						_cProduto = TCQ->C6_PRODUTO
						If LEN(TCQ->C6_PRODUTO) >= 12
							_cEmb = TCQ->EMBA
						Else
							_cEmb = TCQ->B1_RELVOL
						EndIF
						//-----------------------------------------------------------------------------------
						cQry3  =" SELECT TOP 2 ZZL_LOCALI, ZZL_LOCALI " + STR_PULA
						cQry3 +="   FROM "+RetSqlName("ZZL")+" ZZLZ WITH (NOLOCK) "  + STR_PULA
						cQry3 +="  WHERE ZZLZ.ZZL_FILIAL = '"+TCQ->C6_FILIAL+"' "  + STR_PULA
						cQry3 +="    AND ZZLZ.ZZL_PRODUT = '"+TCQ->C6_PRODUTO+"' " + STR_PULA
						//cQry3 +="    AND SUBSTRING(ZZLZ.ZZL_LOCALI,1,1) <> 'R' " + STR_PULA // Jose 01/04/2025
						cQry3 +="    AND (SUBSTRING(ZZLZ.ZZL_LOCALI,1,2) <> 'F1'  AND SUBSTRING(ZZLZ.ZZL_LOCALI,1,2) <> 'F2' " + STR_PULA // Jose 01/04/2025
						cQry3 +="    AND  SUBSTRING(ZZLZ.ZZL_LOCALI,1,3) <> ' F1' AND SUBSTRING(ZZLZ.ZZL_LOCALI,1,3) <> ' F2') " + STR_PULA // Jose 01/04/2025
						cQry3 +="    AND ZZLZ.D_E_L_E_T_ = '' " + STR_PULA
						TCQuery cQry3 ALIAS "TCQZ" NEW
						cLOCALIZ1 = ""
						cLOCALIZ2 = ""
						cCont = 0
						While !(TCQZ->(EoF()))
							If cCont == 0
								cLOCALIZ1  := TCQZ->ZZL_LOCALI
							Else
								cLOCALIZ2  := TCQZ->ZZL_LOCALI
							EndIf
							cCont := cCont + 1
							//Pulando Registro
							TCQZ->(DbSkip())
						EndDo
						TCQZ->(DbCloseArea())
						//---------------------------------------------------------------------------------
						//------ Acrescentado Jose 02/09/2024  ----------------------------------------------------
						cQry3  =" SELECT B2_LOCAL, B2_LOCALIZ " + STR_PULA
						cQry3 +="   FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) "  + STR_PULA
						cQry3 +="  WHERE SB2.B2_FILIAL = '"+TCQ->C6_FILIAL+"' "  + STR_PULA
						cQry3 +="    AND SB2.B2_COD    = '"+TCQ->C6_PRODUTO+"' " + STR_PULA
						cQry3 +="    AND SB2.B2_LOCAL IN ('G3','A3') " + STR_PULA
						cQry3 +="    AND SB2.D_E_L_E_T_ = '' " + STR_PULA
						TCQuery cQry3 ALIAS "TCQGA" NEW
						cLOCALIZA3 = ""
						cLOCALIZG3 = ""
						While !(TCQGA->(EoF()))
							If TCQGA->B2_LOCAL = 'G3'
								cLOCALIZG3  := TCQGA->B2_LOCALIZ
							Else
								cLOCALIZA3  := TCQGA->B2_LOCALIZ
							EndIf
							//Pulando Registro
							TCQGA->(DbSkip())
						EndDo
						TCQGA->(DbCloseArea())
						//--------   AtÈ Aqui Jose 02/09/2024------------------------------------------------------
						//--------------   Jose 06/10/2023 ----------------------------------------------
						cQry3  =" WITH TMP AS( " + STR_PULA
						cQry3 +="   SELECT B2_FILIAL, B2_COD, B2_LOCAL, B2_QATU, B2_RESERVA "  + STR_PULA
						cQry3 +="     FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) " + STR_PULA
						cQry3 +="    WHERE SB2.D_E_L_E_T_ ='' "  + STR_PULA
						cQry3 +="      AND B2_FILIAL = '"+TCQ->C6_FILIAL+"' " + STR_PULA
						cQry3 +="      AND B2_COD = '"+TCQ->C6_PRODUTO+"'" + STR_PULA
						cQry3 +="      AND B2_LOCAL IN('03','30','G3','A3')) "  + STR_PULA  //--('03','30','P1','P2','G3')
						cQry3 +="   SELECT B2_COD, B2_LOCAL AS 'ALMOXARIFADO', B2_QATU AS 'SALDO TOTAL', " + STR_PULA
						cQry3 +="      B2_RESERVA AS 'RESERVA PADR√O SISTEMA', " + STR_PULA
						cQry3 +="          ISNULL(SUM(C6_QTDVEN),0) AS 'VENDIDO', " + STR_PULA
						cQry3 +="          ISNULL(SUM(ZZK_QUANT),0) AS 'SEPARADO', " + STR_PULA
						cQry3 +="          'DISPONIVEL' = ((B2_QATU) - ISNULL(SUM(ZZK_QUANT),0)) FROM TMP " + STR_PULA
						cQry3 +="             LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON C6_FILIAL = B2_FILIAL AND B2_LOCAL = C6_LOCAL " + STR_PULA
						cQry3 +="                                       AND C6_PRODUTO = B2_COD AND C6_NOTA ='' AND SC6.D_E_L_E_T_ ='' " + STR_PULA
						cQry3 +="             LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM AND C5_APROVA ='1'  " + STR_PULA
						cQry3 +="                                       AND C5_TIPO ='N' AND SC5.D_E_L_E_T_ ='' " + STR_PULA
						cQry3 +="             LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON F4_FILIAL = F4_FILIAL AND C6_TES = F4_CODIGO AND F4_ESTOQUE ='S' " + STR_PULA
						cQry3 +="                                       AND SF4.D_E_L_E_T_ ='' " + STR_PULA
						cQry3 +="             LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) ON ZZK_FILIAL = C6_FILIAL AND ZZK_PRODUT = C6_PRODUTO " + STR_PULA
						cQry3 +="                                       AND ZZK_PEDIDO = C6_NUM  AND ZZK.D_E_L_E_T_ ='' " + STR_PULA
						cQry3 +="   GROUP BY B2_COD, B2_LOCAL, B2_QATU, B2_RESERVA " + STR_PULA
						TCQuery cQry3 ALIAS "TCQB2" NEW
						_cDisp   = 0
						_cDispA3 = 0   // Jose 10/07/2024
						_cDispG3 = 0
						While !(TCQB2->(EoF()))
							if (TCQB2->ALMOXARIFADO = "03" .OR. TCQB2->ALMOXARIFADO = "30") // Jose 02/09/2024
								_cDisp  := _cDisp + TCQB2->DISPONIVEL // jose 30/08/2024 separa aqui
							EndIf  // Jose 02/09/2024
							if TCQB2->ALMOXARIFADO = "G3"
								_cDispG3 := _cDispG3 + TCQB2->DISPONIVEL
							EndIf
							If TCQB2->ALMOXARIFADO = "A3"  // Jose 10/07/2024
								_cDispA3 := _cDispA3 + TCQB2->DISPONIVEL   // Jose 10/07/2024
							EndIf   // Jose 10/07/2024
							//Pulando Registro
							TCQB2->(DbSkip())
						EndDo
						TCQB2->(DbCloseArea())
						//-----------------------------------------------------------------------------
						//------ Acrescentado Jose 23/10/2024  ----------------------------------------------------
						If Select( "TCQSC5" ) > 0
							DbSelectArea( "TCQSC5" )
							DbCloseArea()
						Endif
						cQry3  =" SELECT " + STR_PULA
						cQry3 +="   CASE " + STR_PULA
						cQry3 +="       WHEN C5_DTAPR = '' THEN C5_EMISSAO " + STR_PULA
						cQry3 +="       ELSE C5_DTAPR  END AS C5_DTAPR  " + STR_PULA
						cQry3 +="   FROM "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) "  + STR_PULA
						cQry3 +="  WHERE SC5.C5_FILIAL = '"+TCQ->C6_FILIAL+"' "  + STR_PULA
						cQry3 +="    AND SC5.C5_NUM    = '"+TCQ->C6_NUM+"' " + STR_PULA
						cQry3 +="    AND SC5.D_E_L_E_T_ = '' " + STR_PULA
						TCQuery cQry3 ALIAS "TCQSC5" NEW
						//TCQSC5->(DbCloseArea())
						//--------- Jose 23/10/2024 atÈ aqui -------------------------------------
						_cDescricao  = Substr(TCQ->B1_DESC,1,30)
						_cSaldo      = _cDisp
						_cSaldoA3    = _cDispA3  // Jose 10/07/2024
						_cSaldoG3    = _cDispG3
						_cLOCALIZ1   = cLOCALIZ1
						_cLOCALIZ2   = cLOCALIZ2
						_cZZLLOCALIZ = TCQ->LOCALIZ
						_cLOCALIZA3   = cLOCALIZA3 // Jose 02/09/2024
						_cLOCALIZG3   = cLOCALIZG3 // Jose 02/09/2024
						_cVOLUME      = TCQ->VOLUME
						_cFALTA       = TCQ->ZZK_FALTA
						_cDtApr = ctod(substr(TCQSC5->C5_DTAPR,7,2)+"/"+substr(TCQSC5->C5_DTAPR,5,2)+"/"+substr(TCQSC5->C5_DTAPR,1,4)) // Jose 23/10/2024
					EndIf
				EndIf
				//Pulando Registro
				TCQ->(DbSkip())
			EndDo
		Else
			//--------------------------------------------------------------------------------  08/05/2025
			_cProduto    = TCQ->C6_PRODUTO
			_cDescricao  = ''
			_cSaldo      = 0
			_cSaldoA3    = 0  // Jose 10/07/2024
			_cSaldoG3    = 0
			_cZZLLOCALIZ = ''
			_cLOCALIZ1   = ''
			_cLOCALIZ2   = ''
			_cLOCALIZA3  = ''  // JOSE 02/09/2024
			_cLOCALIZG3  = ''  // JOSE 02/09/2024
			_cVOLUME	  = 0
			_cFALTA      = 0
			_cEmb        = 0
			_cDtApr      = ''  // Jose 23/10/2024
			While !(TCQ->(EoF()))
				If TCQ->ZZK_FALTA > 0
					If TCQ->C6_PRODUTO = _cProduto
						//--------------------------------------------------------------------------------
						cQry3  =" SELECT TOP 2 ZZL_LOCALI, ZZL_LOCALI " + STR_PULA
						cQry3 +="   FROM "+RetSqlName("ZZL")+" ZZLZ WITH (NOLOCK) "  + STR_PULA
						cQry3 +="  WHERE ZZLZ.ZZL_FILIAL = '"+TCQ->C6_FILIAL+"' "  + STR_PULA
						cQry3 +="    AND ZZLZ.ZZL_PRODUT = '"+TCQ->C6_PRODUTO+"' " + STR_PULA
						//cQry3 +="    AND SUBSTRING(ZZLZ.ZZL_LOCALI,1,1) <> 'R' " + STR_PULA // Jose 01/04/2025
						cQry3 +="    AND (SUBSTRING(ZZLZ.ZZL_LOCALI,1,2) <> 'F1'  AND SUBSTRING(ZZLZ.ZZL_LOCALI,1,2) <> 'F2' " + STR_PULA // Jose 01/04/2025
						cQry3 +="    AND  SUBSTRING(ZZLZ.ZZL_LOCALI,1,3) <> ' F1' AND SUBSTRING(ZZLZ.ZZL_LOCALI,1,3) <> ' F2') " + STR_PULA // Jose 01/04/2025
						cQry3 +="    AND ZZLZ.D_E_L_E_T_ = '' " + STR_PULA
						TCQuery cQry3 ALIAS "TCQZ" NEW
						cLOCALIZ1 = ""
						cLOCALIZ2 = ""
						cCont = 0
						While !(TCQZ->(EoF()))
							If cCont == 0
								cLOCALIZ1  := TCQZ->ZZL_LOCALI
							Else
								cLOCALIZ2  := TCQZ->ZZL_LOCALI
							EndIf
							cCont := cCont + 1
							//Pulando Registro
							TCQZ->(DbSkip())
						EndDo
						TCQZ->(DbCloseArea())
						//--------------------------------------------------------------------------------
						//------ Acrescentado Jose 02/09/2024  ----------------------------------------------------
						cQry3  =" SELECT B2_LOCAL, B2_LOCALIZ " + STR_PULA
						cQry3 +="   FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) "  + STR_PULA
						cQry3 +="  WHERE SB2.B2_FILIAL = '"+TCQ->C6_FILIAL+"' "  + STR_PULA
						cQry3 +="    AND SB2.B2_COD    = '"+TCQ->C6_PRODUTO+"' " + STR_PULA
						cQry3 +="    AND SB2.B2_LOCAL IN ('G3','A3') "	 + STR_PULA
						cQry3 +="    AND SB2.D_E_L_E_T_ = '' " + STR_PULA
						TCQuery cQry3 ALIAS "TCQGA" NEW
						cLOCALIZA3 = ""
						cLOCALIZG3 = ""
						While !(TCQGA->(EoF()))
							If TCQGA->B2_LOCAL = 'G3'
								cLOCALIZG3  := TCQGA->B2_LOCALIZ
							Else
								cLOCALIZA3  := TCQGA->B2_LOCALIZ
							EndIf
							//Pulando Registro
							TCQGA->(DbSkip())
						EndDo
						TCQGA->(DbCloseArea())
						//--------   AtÈ Aqui Jose 02/09/2024------------------------------------------------------
						//--------------   Jose 06/10/2023 ----------------------------------------------
						cQry3  =" WITH TMP AS( " + STR_PULA
						cQry3 +="   SELECT B2_FILIAL, B2_COD, B2_LOCAL, B2_QATU, B2_RESERVA "  + STR_PULA
						cQry3 +="     FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) " + STR_PULA
						cQry3 +="    WHERE SB2.D_E_L_E_T_ ='' "  + STR_PULA
						cQry3 +="      AND B2_FILIAL = '"+TCQ->C6_FILIAL+"' " + STR_PULA
						cQry3 +="      AND B2_COD = '"+TCQ->C6_PRODUTO+"'" + STR_PULA
						cQry3 +="      AND B2_LOCAL IN('03','30','G3','A3')) " + STR_PULA   //--('03','30','P1','P2','G3')
						cQry3 +="   SELECT B2_COD, B2_LOCAL AS 'ALMOXARIFADO', B2_QATU AS 'SALDO TOTAL', " + STR_PULA
						cQry3 +="      B2_RESERVA AS 'RESERVA PADR√O SISTEMA', " + STR_PULA
						cQry3 +="          ISNULL(SUM(C6_QTDVEN),0) AS 'VENDIDO', " + STR_PULA
						cQry3 +="          ISNULL(SUM(ZZK_QUANT),0) AS 'SEPARADO', " + STR_PULA
						cQry3 +="          'DISPONIVEL' = ((B2_QATU) - ISNULL(SUM(ZZK_QUANT),0)) FROM TMP " + STR_PULA
						cQry3 +="             LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON C6_FILIAL = B2_FILIAL AND B2_LOCAL = C6_LOCAL " + STR_PULA
						cQry3 +="                                       AND C6_PRODUTO = B2_COD AND C6_NOTA ='' AND SC6.D_E_L_E_T_ ='' " + STR_PULA
						cQry3 +="             LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM AND C5_APROVA ='1'  " + STR_PULA
						cQry3 +="                                       AND C5_TIPO ='N' AND SC5.D_E_L_E_T_ ='' " + STR_PULA
						cQry3 +="             LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON F4_FILIAL = F4_FILIAL AND C6_TES = F4_CODIGO AND F4_ESTOQUE ='S' " + STR_PULA
						cQry3 +="                                       AND SF4.D_E_L_E_T_ ='' " + STR_PULA
						cQry3 +="             LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) ON ZZK_FILIAL = C6_FILIAL AND ZZK_PRODUT = C6_PRODUTO " + STR_PULA
						cQry3 +="                                       AND ZZK_PEDIDO = C6_NUM  AND ZZK.D_E_L_E_T_ ='' " + STR_PULA
						cQry3 +="   GROUP BY B2_COD, B2_LOCAL, B2_QATU, B2_RESERVA " + STR_PULA
						TCQuery cQry3 ALIAS "TCQB2" NEW
						_cDisp   = 0
						_cDispA3 = 0  // Jose 10/07/2024
						_cDispG3 = 0
						While !(TCQB2->(EoF()))
							If (TCQB2->ALMOXARIFADO = "03" .OR. TCQB2->ALMOXARIFADO = "30") // Jose 02/09/2024
								_cDisp  := _cDisp + TCQB2->DISPONIVEL  // jose 30/08/2024 separa aqui
							EndIf // Jose 02/09/2024
							If TCQB2->ALMOXARIFADO = "G3"
								_cDispG3 := _cDispG3 + TCQB2->DISPONIVEL
							EndIf
							If TCQB2->ALMOXARIFADO = "A3"  // Jose 10/07/2024
								_cDispA3 := _cDispA3 + TCQB2->DISPONIVEL  // Jose 10/07/2024
							EndIf  // Jose 10/07/2024

							//Pulando Registro
							TCQB2->(DbSkip())
						EndDo
						TCQB2->(DbCloseArea())
						//-----------------------------------------------------------------------------
						//------ Acrescentado Jose 23/10/2024  ----------------------------------------------------
						If Select( "TCQSC5" ) > 0
							DbSelectArea( "TCQSC5" )
							DbCloseArea()
						Endif
						cQry3  =" SELECT " + STR_PULA
						cQry3 +="   CASE " + STR_PULA
						cQry3 +="       WHEN C5_DTAPR = '' THEN C5_EMISSAO " + STR_PULA
						cQry3 +="       ELSE C5_DTAPR  END AS C5_DTAPR  " + STR_PULA
						cQry3 +="   FROM "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) "  + STR_PULA
						cQry3 +="  WHERE SC5.C5_FILIAL = '"+TCQ->C6_FILIAL+"' "  + STR_PULA
						cQry3 +="    AND SC5.C5_NUM    = '"+TCQ->C6_NUM+"' " + STR_PULA
						cQry3 +="    AND SC5.D_E_L_E_T_ = '' " + STR_PULA
						TCQuery cQry3 ALIAS "TCQSC5" NEW
						//TCQSC5->(DbCloseArea())
						//--------- Jose 23/10/2024 atÈ aqui -------------------------------------
						If LEN(TCQ->C6_PRODUTO) >= 12
							_cEmb = TCQ->EMBA
						Else
							_cEmb = TCQ->B1_RELVOL
						EndIf
						_cDescricao  = Substr(TCQ->B1_DESC,1,30)
						_cSaldo      = _cDisp
						_cSaldoA3    = _cDispA3 // Jose 10/07/2024
						_cSaldoG3    = _cDispG3
						_cLOCALIZ1   = cLOCALIZ1
						_cLOCALIZ2   = cLOCALIZ2
						_cZZLLOCALIZ = TCQ->LOCALIZ
						_cLOCALIZA3  = cLOCALIZA3 // Jose 02/09/2024
						_cLOCALIZG3  = cLOCALIZG3 // Jose 02/09/2024
						_cVOLUME     = _cVOLUME + TCQ->VOLUME
						_cFALTA      = _cFALTA  + TCQ->ZZK_FALTA
						_cDtApr = ctod(substr(TCQSC5->C5_DTAPR,7,2)+"/"+substr(TCQSC5->C5_DTAPR,5,2)+"/"+substr(TCQSC5->C5_DTAPR,1,4)) // Jose 23/10/2024
					Else
						//---- Jose 04/10/2023 ------------------------------------------------------------
						_cP1P2 = 0
						cQry3  =" SELECT ISNULL( SUM( B2_QATU ), 0 ) AS 'P1P2' " + STR_PULA
						cQry3 +="  FROM  "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) "  + STR_PULA
						cQry3 +=" WHERE D_E_L_E_T_ = '' " + STR_PULA
						cQry3 +="   AND B2_FILIAL = '"+TCQ->C6_FILIAL+"' " + STR_PULA
						cQry3 +="   AND B2_COD = '"+_cPRODUTO+"' " + STR_PULA
						cQry3 +="   AND B2_LOCAL IN ('P1','P2')"  + STR_PULA
						TCQuery cQry3 ALIAS "TCQSB2" NEW
						While !(TCQSB2->(EoF()))
							_cP1P2  := TCQSB2->P1P2
							//Pulando Registro
							TCQSB2->(DbSkip())
						EndDo
						TCQSB2->(DbCloseArea())
						//----------------------------------------------------------------------------------
						//      Jose 17/02/2025 -----------------------------------------------------------
						cQry  =" SELECT ZF_TIPOBOR " + STR_PULA
						cQry +="   FROM "+RetSqlName("SZF")+" SZF WITH (NOLOCK)  " + STR_PULA
						cQry +=" WHERE SZF.ZF_FILIAL = '"+TCQ->C6_FILIAL+"' " + STR_PULA
						cQry +="   AND SZF.ZF_CODIGO = '"+TCQ->ZG_CODIGO+"' " + STR_PULA
						cQry +="   AND SZF.D_E_L_E_T_ = '' " + STR_PULA
						TCQuery cQry ALIAS "TCQSZF" NEW
						_cSZF:= ""
						While !(TCQSZF->(EoF()))
							_cSZF  := TCQSZF->ZF_TIPOBOR
							//Pulando Registro
							TCQSZF->(DbSkip())
						EndDo
						TCQSZF->(DbCloseArea())
						_cSugestao :=  ""
						DO CASE
							Case _cSZF = "2" .AND. _cDispg3 > 0 .AND. _cDispg3 >= _cSaldo .AND. Substring(_cZZLLOCALIZ,1,2) = "GF" // _nTipoBor = "2" .AND.
								_cSugestao := "GUARULHOS"
								//Case _cDispA3 >= _cFalta .AND. _cSaldo < _cFalta .AND. _cDispA3 > 0  .OR. _cDispg3 < 0 //  .AND. _cLOCALIZ1 = "" .AND. _cLOCALIZ2 = "")
							CASE ((_cDispA3 >0) .AND. (_cP1P2 <=0)) .AND. (  (_cDispA3 >= _cFalta .AND. _cSaldo < _cFalta) .OR. (( _cDispg3 <0 .AND. (_cSaldo+_cDispg3)  < _cDispA3 )) )  //  .AND. _cLOCALIZ1 = "" .AND. _cLOCALIZ2 = "")
								_cSugestao := "ARARAQUARA"
							Case _cFalta <= _cSaldo .OR. _cP1P2 > 0  .OR. (_cSaldo > 0 .AND. (_cLOCALIZ1 <> "" .OR. _cLOCALIZ2 <> ""))
								_cSugestao :=  "MAT√O"
							Case _cSugestao = ""
								_cSugestao :=  "ANALISAR"
						EndCase
						//    Ate Aqui Jose 17/02/2025 ---------------------------------------------------
						oFWMsExcel:AddRow("Bordero3",ccabecalho,{;
							_cPRODUTO,;
							_cEmb,;
							_cDescricao,;
							_cSALDO,;
							_cSaldoA3,; // Jose 10/07/2024
							_cSaldoG3,;
							_cLOCALIZ1,;
							_cLOCALIZ2,;
							_cZZLLOCALIZ,;
							_cLOCALIZA3,; // Jose 02/09/2024
							_cLOCALIZG3,; // Jose 02/09/2024
							_cP1P2,;
							_cVOLUME,;
							_cFALTA,;
							_cDtApr,; // Jose 23/10/2024
							_cSugestao; // Jose 17/02/2025
							})
						_cProduto = TCQ->C6_PRODUTO
						If LEN(TCQ->C6_PRODUTO) >= 12
							_cEmb = TCQ->EMBA
						Else
							_cEmb = TCQ->B1_RELVOL
						EndIF
						//-------------------------------------------------------------------------------
						cQry3  =" SELECT TOP 2 ZZL_LOCALI, ZZL_LOCALI "  + STR_PULA
						cQry3 +="   FROM "+RetSqlName("ZZL")+" ZZLZ WITH (NOLOCK) "  + STR_PULA
						cQry3 +="  WHERE ZZLZ.ZZL_FILIAL = '"+TCQ->C6_FILIAL+"' "  + STR_PULA
						cQry3 +="    AND ZZLZ.ZZL_PRODUT = '"+TCQ->C6_PRODUTO+"' " + STR_PULA
						//cQry3 +="    AND SUBSTRING(ZZLZ.ZZL_LOCALI,1,1) <> 'R' " + STR_PULA  // Jose 01/04/2025
						cQry3 +="    AND (SUBSTRING(ZZLZ.ZZL_LOCALI,1,2) <> 'F1'  AND SUBSTRING(ZZLZ.ZZL_LOCALI,1,2) <> 'F2' " + STR_PULA // Jose 01/04/2025
						cQry3 +="    AND  SUBSTRING(ZZLZ.ZZL_LOCALI,1,3) <> ' F1' AND SUBSTRING(ZZLZ.ZZL_LOCALI,1,3) <> ' F2') " + STR_PULA // Jose 01/04/2025
						cQry3 +="    AND ZZLZ.D_E_L_E_T_ = '' " + STR_PULA
						TCQuery cQry3 ALIAS "TCQZ" NEW
						cLOCALIZ1 = ""
						cLOCALIZ2 = ""
						cCont = 0
						While !(TCQZ->(EoF()))
							If cCont == 0
								cLOCALIZ1  := TCQZ->ZZL_LOCALI
							Else
								cLOCALIZ2  := TCQZ->ZZL_LOCALI
							EndIf
							cCont := cCont + 1
							//Pulando Registro
							TCQZ->(DbSkip())
						EndDo
						TCQZ->(DbCloseArea())
						//-----------------------------------------------------------------------------------------
						//------ Acrescentado Jose 02/09/2024  ----------------------------------------------------
						cQry3  =" SELECT B2_LOCAL, B2_LOCALIZ " + STR_PULA
						cQry3 +="   FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) "  + STR_PULA
						cQry3 +="  WHERE SB2.B2_FILIAL = '"+TCQ->C6_FILIAL+"' "  + STR_PULA
						cQry3 +="    AND SB2.B2_COD    = '"+TCQ->C6_PRODUTO+"' " + STR_PULA
						cQry3 +="    AND SB2.B2_LOCAL IN ('G3','A3') " + STR_PULA
						cQry3 +="    AND SB2.D_E_L_E_T_ = '' " + STR_PULA
						TCQuery cQry3 ALIAS "TCQGA" NEW
						cLOCALIZA3 = ""
						cLOCALIZG3 = ""
						While !(TCQGA->(EoF()))
							If TCQGA->B2_LOCAL = 'G3'
								cLOCALIZG3  := TCQGA->B2_LOCALIZ
							Else
								cLOCALIZA3  := TCQGA->B2_LOCALIZ
							EndIf
							//Pulando Registro
							TCQGA->(DbSkip())
						EndDo
						TCQGA->(DbCloseArea())
						//--------   AtÈ Aqui Jose 02/09/2024------------------------------------------------------
						//------------------------------------------------------------------------------jose 11/12/2023
						cQry3  =" WITH TMP AS( " + STR_PULA
						cQry3 +="   SELECT B2_FILIAL, B2_COD, B2_LOCAL, B2_QATU, B2_RESERVA "  + STR_PULA
						cQry3 +="     FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) " + STR_PULA
						cQry3 +="    WHERE SB2.D_E_L_E_T_ ='' "  + STR_PULA
						cQry3 +="      AND B2_FILIAL = '"+TCQ->C6_FILIAL+"' " + STR_PULA
						cQry3 +="      AND B2_COD = '"+TCQ->C6_PRODUTO+"'" + STR_PULA
						cQry3 +="      AND B2_LOCAL IN('03','30','G3','A3')) " + STR_PULA   //--('03','30','P1','P2','G3')
						cQry3 +="   SELECT B2_COD, B2_LOCAL AS 'ALMOXARIFADO', B2_QATU AS 'SALDO TOTAL', " + STR_PULA
						cQry3 +="      B2_RESERVA AS 'RESERVA PADR√O SISTEMA', " + STR_PULA
						cQry3 +="          ISNULL(SUM(C6_QTDVEN),0) AS 'VENDIDO', " + STR_PULA
						cQry3 +="          ISNULL(SUM(ZZK_QUANT),0) AS 'SEPARADO', " + STR_PULA
						cQry3 +="          'DISPONIVEL' = ((B2_QATU) - ISNULL(SUM(ZZK_QUANT),0)) FROM TMP " + STR_PULA
						cQry3 +="             LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON C6_FILIAL = B2_FILIAL AND B2_LOCAL = C6_LOCAL " + STR_PULA
						cQry3 +="                                       AND C6_PRODUTO = B2_COD AND C6_NOTA ='' AND SC6.D_E_L_E_T_ ='' " + STR_PULA
						cQry3 +="             LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM AND C5_APROVA ='1'  " + STR_PULA
						cQry3 +="                                       AND C5_TIPO ='N' AND SC5.D_E_L_E_T_ ='' " + STR_PULA
						cQry3 +="             LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON F4_FILIAL = F4_FILIAL AND C6_TES = F4_CODIGO AND F4_ESTOQUE ='S' " + STR_PULA
						cQry3 +="                                       AND SF4.D_E_L_E_T_ ='' " + STR_PULA
						cQry3 +="             LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) ON ZZK_FILIAL = C6_FILIAL AND ZZK_PRODUT = C6_PRODUTO " + STR_PULA
						cQry3 +="                                       AND ZZK_PEDIDO = C6_NUM  AND ZZK.D_E_L_E_T_ ='' " + STR_PULA
						cQry3 +="   GROUP BY B2_COD, B2_LOCAL, B2_QATU, B2_RESERVA " + STR_PULA
						TCQuery cQry3 ALIAS "TCQB2" NEW
						_cDisp   = 0
						_cDispA3 = 0  // Jose 10/07/2024
						_cDispG3 = 0
						While !(TCQB2->(EoF()))
							If (TCQB2->ALMOXARIFADO = "03" .OR. TCQB2->ALMOXARIFADO = "30") // Jose 02/09/2024
								_cDisp  := _cDisp + TCQB2->DISPONIVEL // jose 30/08/2024 separa aqui
							EndIf
							If TCQB2->ALMOXARIFADO = "G3"
								_cDispG3 := _cDispG3 + TCQB2->DISPONIVEL
							EndIf
							If TCQB2->ALMOXARIFADO = "A3"  // Jose 10/07/2024
								_cDispA3 := _cDispA3 + TCQB2->DISPONIVEL  // Jose 10/07/2024
							EndIf  // Jose 10/07/2024

							//Pulando Registro
							TCQB2->(DbSkip())
						EndDo
						TCQB2->(DbCloseArea())
						//---------------------------------------  ate aqui------------------------------------------------
						//------ Acrescentado Jose 23/10/2024  ----------------------------------------------------
						If Select( "TCQSC5" ) > 0
							DbSelectArea( "TCQSC5" )
							DbCloseArea()
						Endif
						cQry3  =" SELECT " + STR_PULA
						cQry3 +="   CASE " + STR_PULA
						cQry3 +="       WHEN C5_DTAPR = '' THEN C5_EMISSAO " + STR_PULA
						cQry3 +="       ELSE C5_DTAPR  END AS C5_DTAPR  " + STR_PULA
						cQry3 +="   FROM "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) "  + STR_PULA
						cQry3 +="  WHERE SC5.C5_FILIAL = '"+TCQ->C6_FILIAL+"' " + STR_PULA
						cQry3 +="    AND SC5.C5_NUM    = '"+TCQ->C6_NUM+"' " + STR_PULA
						cQry3 +="    AND SC5.D_E_L_E_T_ = '' " + STR_PULA
						TCQuery cQry3 ALIAS "TCQSC5" NEW
						//TCQSC5->(DbCloseArea())
						//--------- Jose 23/10/2024 atÈ aqui -------------------------------------
						_cDescricao  = Substr(TCQ->B1_DESC,1,30)
						_cSaldo      = _cDisp //TCQ->SALDO
						_cSaldoA3    = _cDispA3  // Jose 10/07/2024
						_cSaldoG3    = _cDispG3
						_cLOCALIZ1   = cLOCALIZ1
						_cLOCALIZ2   = cLOCALIZ2
						_cZZLLOCALIZ = TCQ->LOCALIZ
						_cLOCALIZA3  = cLOCALIZA3 // Jose 02/09/2024
						_cLOCALIZG3  = cLOCALIZG3 // Jose 02/09/2024
						_cVOLUME     = TCQ->VOLUME
						_cFALTA      = TCQ->ZZK_FALTA
						_cDtApr = ctod(substr(TCQSC5->C5_DTAPR,7,2)+"/"+substr(TCQSC5->C5_DTAPR,5,2)+"/"+substr(TCQSC5->C5_DTAPR,1,4)) // Jose 23/10/2024
					EndIf
				EndIf
				//Pulando Registro
				TCQ->(DbSkip())
			EndDo
			//----------    jose 29/11/2023------------------------------------------------------
			_cP1P2 = 0
			cQry3  =" SELECT ISNULL( SUM( B2_QATU ), 0 ) AS 'P1P2' " + STR_PULA
			cQry3 +="  FROM  "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) "  + STR_PULA
			cQry3 +=" WHERE D_E_L_E_T_ = '' " + STR_PULA
			cQry3 +="   AND B2_FILIAL = '"+TCQ->C6_FILIAL+"' " + STR_PULA
			cQry3 +="   AND B2_COD = '"+_cPRODUTO+"' " + STR_PULA
			cQry3 +="   AND B2_LOCAL IN ('P1','P2')"  + STR_PULA
			TCQuery cQry3 ALIAS "TCQSB2" NEW
			While !(TCQSB2->(EoF()))
				_cP1P2  := TCQSB2->P1P2
				//Pulando Registro
				TCQSB2->(DbSkip())
			EndDo
			TCQSB2->(DbCloseArea())

			//------------------------------------------------------------------------------jose 11/12/2023
			cQry3  =" WITH TMP AS( " + STR_PULA
			cQry3 +="   SELECT B2_FILIAL, B2_COD, B2_LOCAL, B2_QATU, B2_RESERVA "  + STR_PULA
			cQry3 +="     FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) " + STR_PULA
			cQry3 +="    WHERE SB2.D_E_L_E_T_ ='' "  + STR_PULA
			cQry3 +="      AND B2_FILIAL = '"+TCQ->C6_FILIAL+"' " + STR_PULA
			cQry3 +="      AND B2_COD = '"+TCQ->C6_PRODUTO+"'" + STR_PULA
			cQry3 +="      AND B2_LOCAL IN('03','30','G3','A3')) " + STR_PULA   //--('03','30','P1','P2','G3')
			cQry3 +="   SELECT B2_COD, B2_LOCAL AS 'ALMOXARIFADO', B2_QATU AS 'SALDO TOTAL', " + STR_PULA
			cQry3 +="      B2_RESERVA AS 'RESERVA PADR√O SISTEMA', " + STR_PULA
			cQry3 +="          ISNULL(SUM(C6_QTDVEN),0) AS 'VENDIDO', " + STR_PULA
			cQry3 +="          ISNULL(SUM(ZZK_QUANT),0) AS 'SEPARADO', " + STR_PULA
			cQry3 +="          'DISPONIVEL' = ((B2_QATU) - ISNULL(SUM(ZZK_QUANT),0)) FROM TMP " + STR_PULA
			cQry3 +="             LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON C6_FILIAL = B2_FILIAL AND B2_LOCAL = C6_LOCAL " + STR_PULA
			cQry3 +="                                       AND C6_PRODUTO = B2_COD AND C6_NOTA ='' AND SC6.D_E_L_E_T_ ='' " + STR_PULA
			cQry3 +="             LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM AND C5_APROVA ='1'  " + STR_PULA
			cQry3 +="                                       AND C5_TIPO ='N' AND SC5.D_E_L_E_T_ ='' " + STR_PULA
			cQry3 +="             LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON F4_FILIAL = F4_FILIAL AND C6_TES = F4_CODIGO AND F4_ESTOQUE ='S' " + STR_PULA
			cQry3 +="                                       AND SF4.D_E_L_E_T_ ='' " + STR_PULA
			cQry3 +="             LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) ON ZZK_FILIAL = C6_FILIAL AND ZZK_PRODUT = C6_PRODUTO " + STR_PULA
			cQry3 +="                                       AND ZZK_PEDIDO = C6_NUM  AND ZZK.D_E_L_E_T_ ='' " + STR_PULA
			cQry3 +="   GROUP BY B2_COD, B2_LOCAL, B2_QATU, B2_RESERVA " + STR_PULA
			TCQuery cQry3 ALIAS "TCQB2" NEW
			_cDisp   = 0
			_cDispA3 = 0   // Jose 10/07/2024
			_cDispG3 = 0
			While !(TCQB2->(EoF()))
				If (TCQB2->ALMOXARIFADO = "03" .OR. TCQB2->ALMOXARIFADO = "30") // Jose 02/09/2024
					_cDisp  := _cDisp + TCQB2->DISPONIVEL  // jose 30/08/2024 separa aqui
				EndIf
				If TCQB2->ALMOXARIFADO = "G3"
					_cDispG3 := _cDispG3 + TCQB2->DISPONIVEL
				EndIf
				If TCQB2->ALMOXARIFADO = "A3"  // Jose 10/07/2024
					_cDispA3 := _cDispA3 + TCQB2->DISPONIVEL  // Jose 10/07/2024
				EndIf  // Jose 10/07/2024

				//Pulando Registro
				TCQB2->(DbSkip())
			EndDo
			TCQB2->(DbCloseArea())
			//---------------------------------------  ate aqui------------------------------------------------
			//------ Acrescentado Jose 23/10/2024  ----------------------------------------------------
			If Select( "TCQSC5" ) > 0
				DbSelectArea( "TCQSC5" )
				DbCloseArea()
			Endif
			cQry3  =" SELECT " + STR_PULA
			cQry3 +="   CASE " + STR_PULA
			cQry3 +="       WHEN C5_DTAPR = '' THEN C5_EMISSAO " + STR_PULA
			cQry3 +="       ELSE C5_DTAPR  END AS C5_DTAPR  " + STR_PULA
			cQry3 +="   FROM "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) "  + STR_PULA
			cQry3 +="  WHERE SC5.C5_FILIAL = '"+TCQ->C6_FILIAL+"' "  + STR_PULA
			cQry3 +="    AND SC5.C5_NUM    = '"+TCQ->C6_NUM+"' " + STR_PULA
			cQry3 +="    AND SC5.D_E_L_E_T_ = '' " + STR_PULA
			TCQuery cQry3 ALIAS "TCQSC5" NEW
			//TCQSC5->(DbCloseArea())
			//--------- Jose 23/10/2024 atÈ aqui -------------------------------------
			//      Jose 17/02/2025 -----------------------------------------------------------
			cQry  =" SELECT ZF_TIPOBOR " + STR_PULA
			cQry +="   FROM "+RetSqlName("SZF")+" SZF WITH (NOLOCK) " + STR_PULA
			cQry +=" WHERE SZF.ZF_FILIAL = '"+TCQ->C6_FILIAL+"' " + STR_PULA
			cQry +="   AND SZF.ZF_CODIGO = '"+TCQ->ZG_CODIGO+"' " + STR_PULA
			cQry +="   AND SZF.D_E_L_E_T_ = '' " + STR_PULA
			TCQuery cQry ALIAS "TCQSZF" NEW
			_cSZF:= ""
			While !(TCQSZF->(EoF()))
				_cSZF  := TCQSZF->ZF_TIPOBOR
				//Pulando Registro
				TCQSZF->(DbSkip())
			EndDo
			TCQSZF->(DbCloseArea())
			_cSugestao :=  ""
			DO CASE
				Case _cSZF = "2" .AND. _cDispg3 > 0 .AND. _cDispg3 >= _cSaldo .AND. Substring(_cZZLLOCALIZ,1,2) = "GF" // _nTipoBor = "2" .AND.
					_cSugestao := "GUARULHOS"
					// Case _cDispA3 >= _cFalta .AND. _cSaldo < _cFalta .AND. _cDispA3 > 0  .OR. _cDispg3 < 0 //  .AND. _cLOCALIZ1 = "" .AND. _cLOCALIZ2 = "")
				CASE ((_cDispA3 >0) .AND. (_cP1P2 <=0)) .AND. (  (_cDispA3 >= _cFalta .AND. _cSaldo < _cFalta) .OR. (( _cDispg3 <0 .AND. (_cSaldo+_cDispg3)  < _cDispA3 )) ) //  .AND. _cLOCALIZ1 = "" .AND. _cLOCALIZ2 = "")
					_cSugestao := "ARARAQUARA"
				Case _cFalta <= _cSaldo .OR. _cP1P2 > 0  .OR. (_cSaldo > 0 .AND. (_cLOCALIZ1 <> "" .OR. _cLOCALIZ2 <> ""))
					_cSugestao :=  "MAT√O"
				Case _cSugestao = ""
					_cSugestao :=  "ANALISAR"
			EndCase
			//    Ate Aqui Jose 17/02/2025 ---------------------------------------------------

			oFWMsExcel:AddRow("Bordero3",ccabecalho,{;
				_cPRODUTO,;
				_cEmb,;
				_cDescricao,;
				_cSALDO,;
				_cSaldoA3,; // Jose 10/07/2024
				_cSaldoG3,;
				_cLOCALIZ1,;
				_cLOCALIZ2,;
				_cZZLLOCALIZ,;
				_cLOCALIZA3,;
				_cLOCALIZG3,;
				_cP1P2,;
				_cVOLUME,;
				_cFALTA,;
				_cDtApr,; // Jose 23/10/2024
				_cSugestao; // Jose 17/02/2025
				})
			//-----------------------------------------------------------------------------------

			/*--------------------------Jose 03/10/2023----------------------------------------
				If LEN(TCQ->C6_PRODUTO) >= 12
					_cEmb = TCQ->EMBA
				Else
					_cEmb = TCQ->B1_RELVOL
				EndIf
         //--------------------------------------------------------------------------------
		        cQry3  =" SELECT TOP 2 ZZL_LOCALI, ZZL_LOCALI "
                cQry3 +="   FROM "+RetSqlName("ZZL")+" ZZLZ WITH (NOLOCK) "
                cQry3 +="  WHERE ZZLZ.ZZL_FILIAL = '"+TCQ->C6_FILIAL+"' "
                cQry3 +="    AND ZZLZ.ZZL_PRODUT = '"+TCQ->C6_PRODUTO+"' "
                cQry3 +="    AND ZZLZ.D_E_L_E_T_ = '' "
                TCQuery cQry3 ALIAS "TCQZ" NEW
                cLOCALIZ1 = ""
		     	cLOCALIZ2 = ""
			    cCont = 0
                While !(TCQZ->(EoF()))
			   	       If cCont == 0
                          cLOCALIZ1 := TCQZ->ZZL_LOCALI
				       Else
				          cLOCALIZ2  := TCQZ->ZZL_LOCALI
				       EndIf
			    cCont := cCont + 1
                //Pulando Registro
                TCQZ->(DbSkip())
		        EndDo
				TCQZ->(DbCloseArea())
         //------------------------------------------------------------------------------
                oFWMsExcel:AddRow("Bordero3",ccabecalho,{;
				TCQ->C6_PRODUTO,;
                _cEmb,;
				Substr(TCQ->B1_DESC,1,30),;
				TCQ->SALDO,;
				_cLOCALIZ1:=cLOCALIZ1,;
				_cLOCALIZ2:=cLOCALIZ2,;
				TCQ->LOCALIZ,;
                TCQ->VOLUME,;
				TCQ->ZZK_FALTA;
				})
			EndIF
            //Pulando Registro
            TCQ->(DbSkip())
          EndDo
			-------------------------------------------------------------------------------*/
			//      Jose 17/02/2025 -----------------------------------------------------------
			/*----------------------------------    Jose   08/05/2025 --------------------------------------------------------------
		 cQry  =" SELECT ZF_TIPOBOR " + STR_PULA
	     cQry +="   FROM "+RetSqlName("SZF")+" SZF WITH (NOLOCK) " + STR_PULA
		 cQry +=" WHERE SZF.ZF_FILIAL = '"+TCQ->C6_FILIAL+"' " + STR_PULA
		 cQry +="   AND SZF.ZF_CODIGO = '"+TCQ->ZG_CODIGO+"' " + STR_PULA
		 cQry +="   AND SZF.D_E_L_E_T_ = '' " + STR_PULA
		 TCQuery cQry ALIAS "TCQSZF" NEW
		 _cSZF:= ""
		 While !(TCQSZF->(EoF()))
               _cSZF  := TCQSZF->ZF_TIPOBOR
               //Pulando Registro
               TCQSZF->(DbSkip())
		 EndDo
		 TCQSZF->(DbCloseArea())
                  _cSugestao :=  ""
          DO CASE
		     Case _cSZF = "2" .AND. _cDispg3 > 0 .AND. _cDispg3 >= _cSaldo .AND. Substring(_cZZLLOCALIZ,1,2) = "GF" // _nTipoBor = "2" .AND.
		          _cSugestao := "GUARULHOS"
          // Case _cDispA3 >= _cFalta .AND. _cSaldo < _cFalta .AND. _cDispA3 > 0  .OR. _cDispg3 < 0 //  .AND. _cLOCALIZ1 = "" .AND. _cLOCALIZ2 = "")
             CASE ((_cDispA3 >0) .AND. (_cP1P2 <=0)) .AND. (  (_cDispA3 >= _cFalta .AND. _cSaldo < _cFalta) .OR. (( _cDispg3 <0 .AND. (_cSaldo+_cDispg3)  < _cDispA3 )) )  //  .AND. _cLOCALIZ1 = "" .AND. _cLOCALIZ2 = "")
			      _cSugestao := "ARARAQUARA"
		     Case _cFalta <= _cSaldo .OR. _cP1P2 > 0  .OR. (_cSaldo > 0 .AND. (_cLOCALIZ1 <> "" .OR. _cLOCALIZ2 <> ""))
		          _cSugestao :=  "MAT√O"
			 Case _cSugestao = ""
			      _cSugestao :=  "ANALISAR"
          EndCase
			//    Ate Aqui Jose 17/02/2025 ---------------------------------------------------*/

		Endif

		/*------------------    Jose 08/05/2025
	    oFWMsExcel:AddRow("Bordero3",ccabecalho,{;
		_cPRODUTO,;
        _cEmb,;
		_cDescricao,;
		_cSALDO,;
		_cSaldoA3,; // Jose 10/07/2024
		_cSaldoG3,;
		_cLOCALIZ1,;
		_cLOCALIZ2,;
		_cZZLLOCALIZ,;
		_cLOCALIZA3,;
		_cLOCALIZG3,;
        _cP1P2,;
        _cVOLUME,;
		_cFALTA,;
     	_cDtApr,; // Jose 23/10/2024
		_cSugestao; // Jose 17/02/2025
		})
		/*		---------------------       ate aqui  Jose 08/05/2025   --------------------------------------------------    */
		//Ativando o arquivo e gerando o xml
		oFWMsExcel:Activate()
		MsgRun("Processando...","Aguarde Gerando arquivo em Excel...",{|| oFWMsExcel:GetXMLFile(cArquivo) } )
		//Abrindo o excel e abrindo o arquivo xml
		oExcel := MsExcel():New()           //Abre uma nova conex„o com Excel
		oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
		oExcel:SetVisible(.T.)              //Visualiza a planilha
		oExcel:Destroy()                    //Encerra o processo do gerenciador de tarefas
	EndIF
	TCQ->(DbCloseArea())
	RestArea(aAreaa)

Return
//------------------  AtÈ aqui -------------------------------------------------------------------------------------

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫FunáÑo    ≥ fRunRel  ∫ Autor ≥ 					   ∫ Data ≥  / /      ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫DescriáÑo ≥ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ∫±±
±±∫          ≥ monta a janela com a regua de processamento.               ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Programa principal                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function fRunRel(Cabec1, Cabec2, Titulo, nLin)

	Local cQry := ""

	If Empty(Alltrim(cGet2Env))
		Messagebox("Informe o cÛdigo do BorderÙ de pedidos antes de consultar !","AtenÁ„o...",48)
		Return
	Endif
	If Mv_Par02 = 1
		//*     Inibido por Jose Uliana     30/10/2020 */
		//* Cabec1 := "PEDIDO  PRODUTO           (BORD "+cGet2Env+")                   QTD TOTAL  QTD COMPRA   QTD FALTA       GRP  LOCALIZA«√O      PROVIS”RIO"
		//*
		Cabec1 := "PEDIDO  PRODUTO           (BORD "+cGet2Env+")                   QTD FALTA       GRP  LOCALIZA«√O      PROVIS”RIO"

		cQry +=" SELECT C6_FILIAL, ZG_CODIGO, C6_NUM, ZG_LOCALIZ, C6_PRODUTO, B1_DESC, B1_RELVOL, ( SELECT dbo.DetVol ( C6_FILIAL,C6_PRODUTO ) ) AS 'VOL', C6_QTDVEN, ISNULL(SUM(ZZK_QUANT),0) AS ZZK_QUANT, (C6_QTDVEN - ISNULL(SUM(ZZK_QUANT),0)) AS 'ZZK_FALTA', " + STR_PULA
		cQry +=" 'VOLUME' = ( ( ISNULL ( SUM ( ZZK_QUANT ),0 ) - C6_QTDVEN ) / ( SELECT dbo.DetVol ( C6_FILIAL,C6_PRODUTO ) ) * -1 ), " + STR_PULA
		cQry +=" 'GRPEMB'    =ISNULL((SELECT TOP 1 B1_GRUPO2 FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) " + STR_PULA
		cQry +=" LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ = '') AND (G1_FILIAL = SB1.B1_FILIAL) AND (G1_COMP = SB1.B1_COD)  WHERE (SG1.D_E_L_E_T_ = '') AND (G1_FILIAL = C6_FILIAL) AND (G1_COD = C6_PRODUTO) AND (SB1.B1_GRUPO LIKE 'E%') AND (SB1.B1_GRUPO2 > '')),'99')," + STR_PULA
		cQry +=" 'LOCALIZ'   =ISNULL((SELECT B2_LOCALIZ FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) WHERE B2_FILIAL = B1_FILIAL AND B2_COD = B1_COD AND B2_LOCAL = B1_LOCPAD AND SB2.D_E_L_E_T_ ='' ),''), " + STR_PULA
		cQry +=" 'ZZLLOCALIZ'=ISNULL((SELECT TOP 1 ZZL_LOCALI FROM "+RetSqlName("ZZL")+" ZZL WITH (NOLOCK) WHERE ZZL_FILIAL = B1_FILIAL AND ZZL_PRODUT = B1_COD AND ZZL.D_E_L_E_T_ ='' ),'') " + STR_PULA
		cQry +="	FROM "+RetSqlName("SZG")+" SZG WITH (NOLOCK) " + STR_PULA
		cQry +="	LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON ZG_FILIAL = C6_FILIAL AND SUBSTRING(ZG_PEDIDO,3,6) = C6_NUM AND SC6.D_E_L_E_T_ ='' " + STR_PULA
		cQry +="	LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) ON ZZK_FILIAL = C6_FILIAL AND ZZK_PEDIDO = C6_NUM AND ZZK_PRODUT = C6_PRODUTO AND ZZK.D_E_L_E_T_ = '' " + STR_PULA
		cQry +=" LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = C6_FILIAL AND B1_COD = C6_PRODUTO AND SB1.D_E_L_E_T_ ='' " + STR_PULA
		cQry +="	WHERE ZG_CODIGO = '"+cGet2Env+"'" + STR_PULA
		If Mv_Par01 = 1  // FILTRA OS SPRAYS DO RELAT”RIO
			cQry +="	AND SUBSTRING(C6_PRODUTO,4,2) NOT IN('55') "  + STR_PULA
		Endif
		cQry +=" AND ZG_FILIAL   = '"+xFilial("SZG")+"'" + STR_PULA
		cQry +=" AND SZG.D_E_L_E_T_ ='' " + STR_PULA
		cQry +="	GROUP BY ZG_CODIGO, C6_NUM, ZG_LOCALIZ, B1_DESC, C6_PRODUTO, C6_QTDVEN, B1_FILIAL, B1_COD, B1_LOCPAD, C6_FILIAL, B1_RELVOL " + STR_PULA
		cQry +=" HAVING (C6_QTDVEN - ISNULL(SUM(ZZK_QUANT),0)) <> 0 " + STR_PULA
		cQry +=" ORDER BY 11,12,5,7,3 "  + STR_PULA //" ORDER BY 10,11,12,5,7,3 "
	ElseIf Mv_Par02 = 2
		//*     Inibido por Jose Uliana     30/10/2020 */
		//* Cabec1 := "   GRUPO          (BORDERO "+cGet2Env+")            QTD TOTAL  QTD COMPRA   QTD FALTA"
		//*
		Cabec1 := "   GRUPO          (BORDERO "+cGet2Env+")            QTD FALTA"
		cQry +=" WITH TMP AS (SELECT C6_FILIAL, ZG_CODIGO, C6_PRODUTO, C6_NUM,  (C6_QTDVEN), ISNULL(SUM(ZZK_QUANT),0) AS ZZK_QUANT, 'GRPEMB' =ISNULL((SELECT TOP 1 B1_GRUPO2 FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) " + STR_PULA
		cQry +=" LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ = '') AND (G1_FILIAL = SB1.B1_FILIAL) AND (G1_COMP = SB1.B1_COD)  WHERE (SG1.D_E_L_E_T_ = '') AND (G1_FILIAL = C6_FILIAL) AND (G1_COD = C6_PRODUTO) AND (SB1.B1_GRUPO LIKE 'E%') AND (SB1.B1_GRUPO2 > '')),'99'), COUNT(ZZK_PRODUT) AS 'VOLBIP' " + STR_PULA
		cQry +=" FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) " + STR_PULA
		cQry +=" LEFT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH (NOLOCK) ON ZG_FILIAL = C6_FILIAL AND SUBSTRING(ZG_PEDIDO,3,6) = C6_NUM AND SZG.D_E_L_E_T_ =''" + STR_PULA
		cQry +=" LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) ON SC6.C6_FILIAL = ZZK_FILIAL AND SC6.C6_NUM = ZZK_PEDIDO AND SC6.C6_PRODUTO = ZZK_PRODUT AND ZZK.D_E_L_E_T_ =''" + STR_PULA
		cQry +=" WHERE SC6.D_E_L_E_T_ ='' AND C6_FILIAL ='"+xFilial("SC6")+"'"  + STR_PULA
		If Mv_Par01 = 1  // FILTRA OS SPRAYS DO RELAT”RIO
			cQry +=" AND SUBSTRING(C6_PRODUTO,4,2) NOT IN('55') "  + STR_PULA
		Endif
		cQry +=" AND ZG_CODIGO ='"+cGet2Env+"' AND LEN(C6_PRODUTO)=12 " + STR_PULA
		cQry +=" GROUP BY C6_FILIAL, ZG_CODIGO, C6_PRODUTO, C6_QTDVEN, C6_NUM ) " + STR_PULA
		cQry +=" SELECT TMP.ZG_CODIGO, SUM(C6_QTDVEN) AS C6_QTDVEN, ISNULL(SUM(ZZK_QUANT),0) AS ZZK_QUANT, (SUM(C6_QTDVEN) - ISNULL(SUM(ZZK_QUANT),0)) AS 'ZZK_FALTA', TMP.GRPEMB, ISNULL(X5_DESCRI,'SEM CLASSFICA«√O') AS X5_DESCRI  " + STR_PULA
		cQry +=" FROM TMP " + STR_PULA
		cQry +=" LEFT OUTER JOIN "+RetSqlName("SX5")+" SX5 WITH (NOLOCK) ON (SX5.D_E_L_E_T_ = '') AND (X5_FILIAL = '"+xFilial("SX5")+"') AND (X5_CHAVE = GRPEMB) AND SX5.D_E_L_E_T_ ='' AND X5_TABELA ='03' " + STR_PULA
		cQry +=" GROUP BY TMP.ZG_CODIGO, TMP.GRPEMB, X5_DESCRI " + STR_PULA
		cQry +=" HAVING (SUM(C6_QTDVEN) - ISNULL(SUM(ZZK_QUANT),0)) <> 0  " + STR_PULA
		cQry +=" ORDER BY TMP.GRPEMB "
	ElseIf Mv_Par02 = 3
		//*     Inibido por Jose Uliana     30/10/2020 */
		//*Cabec1 := "PRODUTO           (BORD "+cGet2Env+")                   QTD TOTAL  QTD COMPRA   QTD FALTA     DISPONÕVEL   LOCALIZA«√O      PROVIS”RIO"
		//*
		Cabec1 := "PRODUTO           (BORD "+cGet2Env+")                   QTD FALTA     DISPONÕVEL   LOCALIZA«√O      PROVIS”RIO"
		cQry +=" WITH TMP AS(SELECT C6_FILIAL,C6_NUM, ZG_CODIGO, C6_PRODUTO, B1_DESC, B1_RELVOL, ( SELECT dbo.DetVol ( C6_FILIAL,C6_PRODUTO ) ) AS 'VOL', C6_QTDVEN AS C6_QTDVEN, ISNULL(SUM(ZZK_QUANT),0) AS ZZK_QUANT, (C6_QTDVEN - ISNULL(SUM(ZZK_QUANT),0)) AS 'ZZK_FALTA',  " + STR_PULA
		cQry +=" 'VOLUME' = ( ( ISNULL ( SUM ( ZZK_QUANT ),0 ) - C6_QTDVEN ) / ( SELECT dbo.DetVol ( C6_FILIAL,C6_PRODUTO ) ) * -1 ), " + STR_PULA
		cQry +=" 'GRPEMB'    =ISNULL((SELECT TOP 1 B1_GRUPO2 FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) " + STR_PULA
		cQry +=" LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ = '') AND (G1_FILIAL = SB1.B1_FILIAL) AND (G1_COMP = SB1.B1_COD)  WHERE (SG1.D_E_L_E_T_ = '') AND (G1_FILIAL = C6_FILIAL) AND (G1_COD = C6_PRODUTO) AND (SB1.B1_GRUPO LIKE 'E%') AND (SB1.B1_GRUPO2 > '')),'99')," + STR_PULA
		cQry +=" 'LOCALIZ'   =ISNULL((SELECT B2_LOCALIZ FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) WHERE B2_FILIAL = B1_FILIAL AND B2_COD = B1_COD AND B2_LOCAL = B1_LOCPAD AND SB2.D_E_L_E_T_ ='' ),''), " + STR_PULA
		cQry +=" 'ZZLLOCALIZ'=ISNULL((SELECT TOP 1 ZZL_LOCALI FROM "+RetSqlName("ZZL")+" ZZL WITH (NOLOCK) WHERE ZZL_FILIAL = B1_FILIAL AND ZZL_PRODUT = B1_COD AND ZZL.D_E_L_E_T_ ='' ),'')," + STR_PULA
		cQry +=" 'SB2_03E30' =ISNULL((SELECT SUM(B2_QATU) AS B2_DISP FROM "+RetSqlName("SB2")+" WITH (NOLOCK) WHERE B2_FILIAL = B1_FILIAL AND B2_COD = B1_COD AND D_E_L_E_T_ ='' AND B2_LOCAL IN('03','30','G3','A3')),0), " + STR_PULA
		cQry +=" 'ZZKSEMFAT' =ISNULL((SELECT SUM(ZZK_QUANT) FROM "+RetSqlName("SC6")+" SC6 WITH(NOLOCK) LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH(NOLOCK) ON ZZK_FILIAL = C6_FILIAL AND ZZK_PRODUT = C6_PRODUTO AND ZZK_PEDIDO = C6_NUM AND SC6.D_E_L_E_T_ ='' WHERE C6_FILIAL ='"+xFilial("SC6")+"' AND C6_NOTA ='' AND C6_PRODUTO = B1_COD AND ZZK.D_E_L_E_T_ =''),0) " + STR_PULA
		cQry +="	FROM "+RetSqlName("SZG")+" SZG WITH (NOLOCK) " + STR_PULA
		cQry +="	LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON ZG_FILIAL = C6_FILIAL AND SUBSTRING(ZG_PEDIDO,3,6) = C6_NUM AND SC6.D_E_L_E_T_ ='' " + STR_PULA
		cQry +="	LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) ON ZZK_FILIAL = C6_FILIAL AND ZZK_PEDIDO = C6_NUM AND ZZK_PRODUT = C6_PRODUTO AND ZZK.D_E_L_E_T_ = '' " + STR_PULA
		cQry +=" LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = C6_FILIAL AND B1_COD = C6_PRODUTO AND SB1.D_E_L_E_T_ ='' " + STR_PULA
		cQry +="	WHERE ZG_CODIGO = '"+cGet2Env+"'" + STR_PULA
		If Mv_Par01 = 1  // FILTRA OS SPRAYS DO RELAT”RIO
			cQry +="	AND SUBSTRING(C6_PRODUTO,4,2) NOT IN('55') " + STR_PULA
		Endif
		cQry +=" AND ZG_FILIAL   = '"+xFilial("SZG")+"'" + STR_PULA
		cQry +=" AND SZG.D_E_L_E_T_ ='' " + STR_PULA
		cQry +=" GROUP BY ZG_CODIGO, C6_NUM, B1_DESC, C6_PRODUTO, B1_FILIAL,C6_QTDVEN,  B1_COD, B1_LOCPAD, C6_FILIAL, B1_RELVOL ) " + STR_PULA
		cQry +=" SELECT TMP.C6_FILIAL, TMP.ZG_CODIGO, TMP.C6_PRODUTO, TMP.B1_DESC, ( SELECT dbo.DetVol ( C6_FILIAL,C6_PRODUTO ) ) AS 'VOL', SUM(TMP.C6_QTDVEN) AS 'VENDIDO', SUM(TMP.ZZK_QUANT) AS 'BIPADO', TMP.GRPEMB,TMP.LOCALIZ, TMP.ZZLLOCALIZ, TMP.SB2_03E30, TMP.ZZKSEMFAT, (TMP.SB2_03E30 - TMP.ZZKSEMFAT)  AS 'SALDO', SUM(TMP.ZZK_FALTA) AS ZZK_FALTA, " + STR_PULA
		cQry +=" 'VOLUME' = ( ( ISNULL ( SUM ( TMP.ZZK_QUANT ),0 ) - TMP.C6_QTDVEN ) / ( SELECT dbo.DetVol ( TMP.C6_FILIAL,TMP.C6_PRODUTO ) ) * -1 ) " + STR_PULA
		cQry +=" FROM TMP " + STR_PULA
		cQry +=" GROUP BY TMP.C6_FILIAL, TMP.ZG_CODIGO, TMP.C6_PRODUTO, TMP.B1_DESC, TMP.GRPEMB,TMP.LOCALIZ, TMP.ZZLLOCALIZ, TMP.SB2_03E30, TMP.ZZKSEMFAT, TMP.C6_QTDVEN, TMP.ZZK_QUANT " + STR_PULA //,TMP.ZZK_FALTA
		cQry +=" HAVING (SUM(TMP.C6_QTDVEN) - ISNULL(SUM(TMP.ZZK_QUANT),0)) <> 0 AND ((TMP.SB2_03E30 - TMP.ZZKSEMFAT)>0) " + STR_PULA
		cQry +=" ORDER BY TMP.LOCALIZ, TMP.ZZLLOCALIZ, TMP.C6_PRODUTO " + STR_PULA
		//cQry +=" ORDER BY TMP.GRPEMB,TMP.LOCALIZ, TMP.ZZLLOCALIZ, TMP.C6_PRODUTO "
	Endif

	TCQuery cQry ALIAS "TCQ" NEW
	ProcRegua(RecCount())
	DbGoTop()

	While !Eof()
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Verifica o cancelamento pelo usuario...                             ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		If lAbortPrint
			@ nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Impressao do cabecalho do relatorio. . .                            ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		If nLin > 55 // Salto de P·gina. Neste caso o formulario tem 55 linhas...
			nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
			nLin += 1
		Endif

		If Mv_Par02 = 1
			//"PEDIDO  PRODUTO                                     QTD TOTAL  QTD COMPRA   QTD FALTA   LOCALIZA«√O          "
			// 999999	XX 999999999 123456789012345678901234567890   99999       99999      99999
			// 12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
			//          1         2         3         4         5         6         7         8         9         10        11
			@ nLin,001 PSAY TCQ->C6_NUM      Picture "@R XXXXXX"
			@ nLin,009 PSAY TCQ->C6_PRODUTO  Picture "@R XXXXXXXXXXXX"
			@ nLin,023 PSAY Substr(TCQ->B1_DESC,1,30)
			//* Inibido por Jose Uliana   30/10/2020 @ nLin,059 PSAY TCQ->C6_QTDVEN   Picture "@E 99999"
			//* Inibido por Jose Uliana   30/10/2020 @ nLin,071 PSAY Iif(TCQ->ZZK_QUANT=0, '-',TCQ->ZZK_QUANT)
			@ nLin,059 PSAY TCQ->ZZK_FALTA   Picture "@E 99999"  //*    antes era nLin,082  Alterado por Jose Uliana 30/10/2020
			@ nLin,074 PSAY TCQ->GRPEMB                          //*    antes era nLin,098  Alterado por Jose Uliana 30/10/2020
			@ nLin,085 PSAY TCQ->LOCALIZ                         //*    antes era nLin,105  Alterado por Jose Uliana 30/10/2020
			@ nLin,102 PSAY TCQ->ZZLLOCALIZ                      //*    antes era nLin,122  Alterado por Jose Uliana 30/10/2020

			nLin += 1 // Avanca a linha de impressao
			//*    Acrescentado por Jose Uliana  30/10/2020   ------*/
			@ nLin,001 PSAY Replicate ("_",165)
			nLin +=1 // Avanca a linha de Impress„o
			//*-----------------------------------------------------*/

		ElseIf Mv_Par02 = 2

			//"GRUPO   					  			  	  QTD TOTAL  QTD COMPRA   QTD FALTA"
			// 99	XXXXXXXXXXXXXXXXXXXXXXXXX    				 99999       99999      99999
			// 12345678901234567890123456789012345678901234567890123456789012345678901234567890
			//          1         2         3         4         5         6         7         8
			@ nLin,001 PSAY TCQ->GRPEMB      Picture "@R XX"
			@ nLin,005 PSAY Substr(  TCQ ->X5_DESCRI,1,30)
			//@ nLin,033 PSAY TCQ->C6_PRODUTO  Picture "@R XXXXXXXXXXXX"
			//@ nLin,049 PSAY Substr(TCQ->C6_DESCRI,1,30)
			//* Inibido por Jose Uliana   30/10/2020  @ nLin,048 PSAY TCQ->C6_QTDVEN   Picture "@E 99999"
			//* Inibido por Jose Uliana   30/10/2020  @ nLin,059 PSAY Iif(TCQ->ZZK_QUANT =0, '-', TCQ->ZZK_QUANT)
			@ nLin,048 PSAY TCQ->ZZK_FALTA   Picture "@E 99999"    //* Antes era nLin,71  Alterado por Jose Uliana 30/10/2020 */
			//@ nLin,124 PSAY Iif(TCQ->VOLBIP =0, '-', TCQ->VOLBIP)

			nLin += 1 // Avanca a linha de impressao
			//*    Acrescentado por Jose Uliana  30/10/2020   ------*/
			@ nLin,001 PSAY Replicate ("_",80)
			nLin +=1 // Avanca a linha de Impress„o
			//*-----------------------------------------------------*/

		ElseIf Mv_Par02 == 3

			//"PRODUTO                                     TOTAL BORD  QTD COMPRA  QTD FALTA  DISPONÕVEL  LOCALIZA«√O      "
			// XX 999999999 123456789012345678901234567890   99999       99999       99999      99999
			// 12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
			//          1         2         3         4         5         6         7         8         9         10        11
			@ nLin,001 PSAY TCQ->C6_PRODUTO  Picture "@R XXXXXXXXXXXX"
			@ nLin,014 PSAY Substr(TCQ->B1_DESC,1,30)
			//* Inibido por Jose Uliana   30/10/2020  @ nLin,050 PSAY TCQ->VENDIDO   Picture "@E 99999"
			//* Inibido por Jose Uliana   30/10/2020  @ nLin,062 PSAY Iif(TCQ->BIPADO=0, '-',TCQ->BIPADO)
			@ nLin,050 PSAY TCQ->ZZK_FALTA   Picture "@E 99999" //* Antes era nLin,073  Alterado por Jose Uliana 30/10/2020 */
			@ nLin,065 PSAY (TCQ->SALDO) Picture "@E 999999"    //* Antes era nLin,089  Alterado por Jose Uliana 30/10/2020 */
			@ nLin,080 PSAY TCQ->LOCALIZ                        //* Antes era nLin,104  Alterado por Jose Uliana 30/10/2020 */
			@ nLin,094 PSAY TCQ->ZZLLOCALIZ                     //* Antes era nLin,118  Alterado por Jose Uliana 30/10/2020 */

			nLin += 1 // Avanca a linha de impressao
			//*    Acrescentado por Jose Uliana  30/10/2020   ------*/
			@ nLin,001 PSAY Replicate ("_",165)
			nLin +=1 // Avanca a linha de Impress„o
			//*-----------------------------------------------------*/


		Endif
		DbSelectArea("TCQ")
		DbSkip() // Avanca o ponteiro do registro no arquivo
	EndDo

	DbSelectArea("TCQ")
	DbCloseArea()
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Finaliza a execucao do relatorio...                                 ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	SET DEVICE TO SCREEN

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Se impressao em disco, chama o gerenciador de impressao...          ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif
	MS_FLUSH()

Return

/*/
{Protheus.doc} BLQLOTE
(long_description)
@type  Function
@author Nelieder Corneta
@since 20/07/2023
@param cLote
@return return
/*/
Static Function BLQLOTE(cLote)
	Local cReturn := .F.

	If _ZPPAR0118 // Bloqueio de lote = .T.

		DbSelectArea("ZAE")
		DbSetOrder(2)
		If DbSeek(xFilial("ZAE")+cLote)
			If ZAE->ZAE_TIPO == "1"
				U_ZPCPC02(cLote)
				cReturn := .T. // Lote est· bloqueado
			EndIf
		EndIf

	EndIf

Return cReturn

Static Function Processar()
	Local _zContador :=1
	//Local _Aux       := ''
	For  _zContador := 1 to len(aSemVolume)
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+ALLTRIM(aSemVolume[_zContador,2]), .t.)
		If Found()
			RecLock("SB1", .f.)
			If aSemVolume[_zContador,1] = 0
				_zConta += 1
			Else
				SB1->B1_RELVOL := aSemVolume[_zContador,1]
			EndIf
			MsUnLock()
		Endif
	Next
	DbCloseArea()
	If _zConta = 0
		Messagebox("Produto(s) Atualizado(s) o Volume !!!         Clique OK   Para Sair ","AtenÁ„o...",48)
	Else
		//       _Aux := "Processamento Vai Encerrar, Tem  "+_zConta+"  Produtos ainda Sem Volume com Problema, favor Acertar !!! Clique OK Para Sair"
		//       Messagebox(_Aux, "AtenÁ„o...", 48)
		Messagebox("Processamento Vai Encerrar, Tem  "+cValtoChar(_zConta)+"   Produtos ainda Sem Volume, favor Acertar  !!!     Clique OK   Para Sair ","AtenÁ„o...",48)
		//     Messagebox("Produto j· digitado em OUTRO PALLET..: "+ZZK->ZZK_CODIGO+" !! Verifique ou faÁa a desmontagem antes de incluir neste Pallet !!","AtenÁ„o...",48)
	Endif
	oDlg:End()
return()


/*ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
Function  ≥ oPerg() - Cria grupo de Perguntas.
ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*/
//LGS#20200210 - AdequaÁ„o de release 12.1.25 e posteriores
/*Static Function oPerg()

       Local aHelpPor := {}
	   AAdd(aHelpPor, {{"Filtra os Sprays do relatÛrio de faltas ?"}		, {""}, {""}})
	   AAdd(aHelpPor, {{"Faltas por Produto ou por Grupo, ou Recompra ?"}	, {""}, {""}})

	   PutSX1( 'FATX66', '01', 'Filtra Sprays ? 		   			          ' , '', '', 'mv_ch1', 'N',01,00,01, 'C', '', ''        , ''          , '', 'mv_par01', 'Sim'    , '', '', '', ''     , 'N„o'  , '', '', '',          '', '', '', '', '', '', '', aHelpPor[1,1], {}, {} )
	   PutSX1( 'FATX66', '02', 'Faltas por Produto / Grupo/ Re-Compra ?' , '', '', 'mv_ch2', 'N',01,00,01, 'C', '', ''        , ''          , '', 'mv_par02', 'Produto', '', '', '', ''     , 'Grupo', '', '', '', 'Re-Compra', '', '', '', '', '', '', aHelpPor[1,2], {}, {} )

       aHelpPor := {}
Return*/
