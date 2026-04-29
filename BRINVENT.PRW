#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TBICONN.CH"

#define MB_OK                       0
#define MB_OKCANCEL                 1
#define MB_YESNO                    4
#define MB_ICONHAND                 16
#define MB_ICONQUESTION             32
#define MB_ICONEXCLAMATION          48
#define MB_ICONASTERISK             64

/*/{Protheus.doc} BRINVENT
Função para montar a tela de login simplificada
@type function Tela
@author Atilio - alterado por MAA
@since 17/09/2015 - Alterado em 04/12/2025
@version 1.0
@return Logical, se o usuario tem permissao de entrar na rotina
/*/
User Function BRINVENT()
	//Local oBtnConf
	Local aArea      := FWGetArea()
	Local oBtnBar
	Local oGrpLog
	Private cGetPsw  := Space(20)
	Private cGetUsr  := Space(25)
	Private lRetorno := .F.
	Private nJanAltu := 200
	Private nJanLarg := 380
	Private oDlgPvt
	Private oGetPsw
	Private oGetUsr
	Private oSayPsw
	Private oSayUsr

	//Criando a janela
	Define MsDialog oDlgPvt Title OemToAnsi('Login') From 000,000 To  nJanAltu, nJanLarg  COLOR CLR_BLACK,CLR_WHITE STYLE NOR(DS_SYSMODAL,WS_MAXIMIZEBOX,WS_POPUP) Pixel

	//Grupo de Login
	@ 003, 001     GROUP oGrpLog TO (nJanAltu/2)-1, (nJanLarg/2)-3         PROMPT "Login: "     OF oDlgPvt COLOR CLR_BLACK,CLR_WHITE PIXEL

	//Label e Get de Usuário
	@ 013, 006   SAY   oSayUsr PROMPT "Usuário:"        SIZE 030, 015 OF oDlgPvt                    PIXEL
	@ 020, 006   MSGET oGetUsr VAR    cGetUsr           SIZE (nJanLarg/2)-12, 015 OF oDlgPvt COLORS CLR_BLACK,CLR_WHITE PIXEL

	//Label e Get da Senha
	@ 043, 006   SAY   oSayPsw PROMPT "Senha:"          SIZE 030, 015 OF oDlgPvt                    PIXEL
	@ 050, 006   MSGET oGetPsw VAR    cGetPsw           SIZE (nJanLarg/2)-12, 015 OF oDlgPvt COLORS CLR_BLACK,CLR_WHITE PIXEL PASSWORD

	//Botões
	//@ (nJanAltu/2)-18, 006 BUTTON oBtnConf PROMPT "Confirmar"             SIZE (nJanLarg/2)-12, 015 OF oDlgPvt ACTION (fVldUsr()) PIXEL
	oBtnBar:= FWButtonBar():New()
	oBtnBar:Init( oDlgPVT, 030, 030, CONTROL_ALIGN_BOTTOM, .T. )
	oBtnBar:addBtnImage( "FINAL.PNG" , "Sair <ESC>" , {|| lRetorno:=.F., oDlgPVT:End()}, , .T., CONTROL_ALIGN_LEFT)
	oBtnBar:addBtnImage( "OK.PNG" , "Confirmar <ENTER>" , {|| (fVldUsr())}, , .T., CONTROL_ALIGN_LEFT)

	ACTIVATE MSDIALOG oDlgPvt CENTERED

	//Se a rotina foi confirmada e deu certo, atualiza o usuário e a senha
	If lRetorno
		cUsrLog := Alltrim(cGetUsr)
		cPswLog := Alltrim(cGetPsw)
		U_BRINVE01()
	EndIf

	FWRestArea(aArea)

Return lRetorno

/*/{Protheus.doc} fVldUsr
Funcão que valida o usuario
@type function Processamento
@version  1.00
@author Dan Atilio - modificado por marioantonaccio
@since 05/12/2025
@return character, sem retorno
/*/
Static Function fVldUsr()
	Local cUsrAux := Alltrim(cGetUsr)
	Local cPswAux := Alltrim(cGetPsw)
	Local cCodAux := ""

	//Pega o código do usuário
	RPCClearEnv()
	If RpcSetEnv("01", "010101", cUsrAux, cPswAux)
		cCodAux := RetCodUsr()
		lRetorno := .T.
		//Senão atualiza o erro e retorna para a rotina
	Else
		VTALERT("Usuário e/ou senha inválidos!",'Atencao',MB_ICONHAND)
	EndIf

	//Verifica se o usuario está cadastrado como operador
	If lRetorno
		CB1->(dbSetOrder(2))
		If .NOT. CB1->(dbSeek(xFilial("CB1")+cCodAux))
			lRetorno:=.F.
			VTALERT("Operador nao cadastrado!",'Atencao',MB_ICONHAND)
		End
	End

	If  2==1 //lRetorno
		//Verifica se nao esta em ferias ou demitido
		BeginSql Alias 'XUSR'
			SELECT
				DISTINCT (
					TRIM(VIN.USR_GRPEMP + ' - ' + VIN.USR_FILIAL) + ' - ' + VIN.USR_CODFUNC
				) AS EMPR_FILIAL_MATR,
				ISNULL(SRA.RA_MSBLQL, ' ') AS RA_MSBLQL,
				ISNULL(SRA.RA_SITFOLH, ' ') AS RA_SITFOLH,
				ISNULL(SRA.RA_DEMISSA, ' ') AS RA_DEMISSA,
				CB1.CB1_CODUSR
			FROM
				%Table:CB1% CB1
			LEFT JOIN SYS_USR USR
			ON USR.D_E_L_E_T_ = ' '
				AND CB1.CB1_CODUSR = USR.USR_ID
			LEFT JOIN SYS_USR_VINCFUNC VIN
			ON VIN.D_E_L_E_T_ = ' '
				AND VIN.USR_ID = USR.USR_ID
			LEFT JOIN SRA010 SRA
			ON SRA.D_E_L_E_T_ = ' '
				AND SRA.RA_FILIAL = VIN.USR_FILIAL
				AND RA_MAT = VIN.USR_CODFUNC
			WHERE
				CB1.D_E_L_E_T_ = ' '
				AND CB1_CODUSR = %Exp:CB1->CB1_CODUSR%
		EndSQL

		If .NOT. XUSR->(EOF()) .and. .NOT. XUSR->(BOF())
			If XUSR->RA_MSBLQL == '1'
				lRetorno:=.F.
				VTALERT("Operador Bloqueado!",'Atencao',MB_ICONHAND)
			End
			If XUSR->RA_SITFOLH <> ' '
				lRetorno:=.F.
				VTALERT("Operador nao ativo! (FOLHA)",'Atencao',MB_ICONHAND)
			End
			If .NOT. Empty(XUSR->RA_DEMISSA) .and. XUSER->RA_SITFOLH = 'D'
				lRetorno:=.F.
				VTALERT("Operador Desligado!",'Atencao',MB_ICONHAND)
			End
			If Empty(AllTrim(XUSR->RA_DEMISSA)+AllTrim(XUSR->RA_SITFOLH)+Alltrim(XUSR->RA_MSBLQL))
				lRetorno:=.F.
				VTALERT("Operador nao localizado! (FOLHA)",'Atencao',MB_ICONHAND)
			End
		Else
			lRetorno:=.F.
			VTALERT("Operador Sem registro!",'Atencao',MB_ICONHAND)
		End
		XUSR->(dbCloseArea())
	End

	If lRetorno
		RpcClearEnv()
		oDlgPvt:End()
	End

Return (NIL)

/*/{Protheus.doc} BRINVE01
Abre tela para digitação inventário
@type function Tela
@version 1.00
@author marioantonaccio
@since 04/12/2025
@return character, sem retorno
/*/
User function BRINVE01()

	//Local _bWindowInit 	:= { || __Execute( "U_UESTW01A()" , "xxxxxxxxxxxxxxxxxxxx" , "MATA010" , "SIGAFAT" , "SIGAFAT", 1 , .T. ) }
	//Local _bWindowInit 	:= { ||  U_ACDV035() }
	Local _bWindowInit     :={|| BRINVE02() }
	Local _cMod            := "EST"
	Local _cModName        := "SIGAEST"
	Private __cInterNet    := Nil
	Private __cUserId      := ''
	Private __IMAGEGALLERY := Nil
	Private _cCodOpe       := ''
	Private cUsuario       := ''
	Public cEmpAnt         := '01'
	Public cEmpFil         := '010101'
	Public cFilAnt         := '000000000'
	Public oMainWnd        := Nil

	MsgRun( "Abrindo Login!" ;
		, "Aguarde..." ;
		, {|oSay| ;
		RpcSetEnv( "01" ;
		, "010101" ;
		, cUsrLog ;
		, cPswLog ;
		, _cMod ;
		, "BRASILUX" ;
		, {} ;
		,.F. ;
		,.T. ;
		,.T. ;
		,.T. ;
		) ;
		} ;
		)
	aSelec := AdmGetFil()

	InitPublic()
	SetsDefault()
	SetModulo( @_cModName , @_cMod )

	DEFINE   WINDOW oMainWnd FROM 001,001 TO 400,500 TITLE OemToAnsi( FunName() )
	ACTIVATE WINDOW oMainWnd MAXIMIZED ON INIT ( Eval( _bWindowInit ) , oMainWnd:End() )

	RpcClearEnv()

Return ( NIL )

/*/{Protheus.doc} BRINVE02
Tela de digitação/bipagem de inventario
@type function Tela
@version 1.0
@author marioantonaccio
@since 19/11/2025
@return character,sem retorno definido
/*/
Static Function BRINVE02()

	Local _aSize        := FWGetDialogSize( oMainWnd )
	Local _oAreaMain    := Nil
	Local _oBtnBar      := Nil
	Local _oFont        := TFont():New("Arial", 12, 24, .T., .T., 5, .T., 5, .T., .F.)
	Local _oFontMemo    := TFont():New("Arial", 12, 24, .T., .T., 5, .T., 5, .T., .F.)
	Local _oLyr0        := Nil
	Local _oPanel0      := Nil
	Local cLocal        := ''
	Local lCBINVFIM     := ExistBlock( 'CBINVFIM' )
	Local lLocaliz      := GetMv( 'MV_LOCALIZ' ) =="S"

	Private cLibUsada  := ""
	Private nTipoEst     := 0
	Private cEtiqProd
	Private _lValid     := .T.
	Private _oDlgMain   := Nil
	Private aProdEnd    := {}
	Private cArmazem
	Private cClasses    := ""
	Private cCodInv
	Private cCodProd
	Private cCodTpUni
	Private cCodUnit
	Private cEtiqend
	Private cProduto
	Private lForcaQtd   := GetMV("MV_CBFCQTD",,"2") =="1"
	Private lModelo1    := GetMv("MV_CBINVMD")=="1"
	Private lMsErroAuto := .F.
	Private lProcUnit   := .F.
	Private lUsaCB001   := UsaCB0("01")
	Private lUsaCB002   := UsaCB0("02")
	Private lVldTelWMS  := .F.
	Private nQtdEtiq    := 0

	_aSize[1]:=000
	_aSize[2]:=000
	_aSize[3]:=250
	_aSize[4]:=350

	lValidQtdInv := If(lUsaCB001,(GetMv("MV_VQTDINV")=="1"),.T.)

	If .NOT. SuperGetMV("MV_CBPE012",.F.,.F.)
		MessageBox("Necessario ativar o parametro MV_CBPE012", "Aviso", MB_ICONHAND)
		Return (.F.)
	EndIf

	//Busca as informações sobre o remote
	nTipoEst := GetRemoteType(@cLibUsada)

	While _lValid

		Define MsDialog _oDlgMain Title OemToAnsi('BRASILUX') From  _aSize[1],_aSize[2] To _aSize[3],_aSize[4]  Of oMainWnd COLOR 'W+/W' STYLE NOR(DS_SYSMODAL,WS_MAXIMIZEBOX,WS_POPUP) Pixel

		_oAreaMain 			:= FWLayer():New()

		_oAreaMain:Init(_oDlgMain, .F.)
		_oAreaMain:AddLine('line_fold00'	, 100	, .F.)

		_oPanel0	:= _oAreaMain:GetLinePanel('line_fold00')

		_oLyr0 		:= FWLayer():New()
		_oLyr0:Init(_oPanel0,.F.)
		_oLyr0:AddCollumn('column_fold00'	, 100, .F.)
		_oLyr0:AddWindow('column_fold00'	,'WIN_CLIENTE'	, 'BRASILUX - Inventario'	, 100	, .F., .F.,{|| })

		_oAreaMain	:= _oLyr0:GetWinPanel('column_fold00'	, 'WIN_CLIENTE')
		_oAreaMain:FreeChildren()

		_nWidth := (_oAreaMain:nClientWidth/2)

		cArmazem   := '' //Space(nTamLoc)
		cCodInv    := Space(009)
		cCodTpUni  := '' //Space(nTamCodUni)
		cCodunit   := Space(015) //Space(nTamUnit)
		cEndereco  := Space(10) //Space(nTamEnd)
		cEtiqend   := '' //Space(48)
		cProduto   := '' //Space(nTamProd)
		nQtdEtiq   := 0
		cArmazem   := cLocal
		cEspaco    := ""
		cEtiqProd := Space(015)

		TSay():New(17*1-16,000,{|| "Cod Mestre"}	,_oAreaMain,,_oFont,,,,.T.,,,280,100)
		@ 17*1-16,60 Get oCodInv Var cCodInv SIZE _nWidth-65,15 WHEN .F. FONT _oFont OF _oAreaMain  Pixel

		If lLocaliz .and. If(Empty(CBA->CBA_PROD),.T.,Localiza(CBA->CBA_PROD,.T.))
			TSay():New(17*2-16,000,{|| "Endereco"}	,_oAreaMain,,_oFont,,,,.T.,,,280,100)
			@ 17*2-16,60 Get oEndereco Var cEndereco  SIZE _nWidth-66,15 VALID VldEnd(AllTrim(cEndereco)) FONT _oFontMemo OF _oAreaMain  Pixel
			@ 17*2.5-16,60 Get oEspaco Var cEspaco SIZE 01,15   FONT _oFontMemo OF _oAreaMain  Pixel
		EndIf

		TSay():New(17*3-16,000,{|| If (lUsaCB001,"Etiqueta","Produto")}	,_oAreaMain,,_oFont,,,,.T.,,,280,100)
		@ 17*3-16,60 Get oEtiqProd Var cEtiqProd  VALID VldProd(@cEtiqProd) SIZE _nWidth-65,15 FONT _oFontMemo Of _oAreaMain  Pixel

		TSay():New(17*4-16,000,{|| "Quantidade"}	,_oAreaMain,,_oFont,,,,.T.,,,280,100)
		@ 17*4-16,60 Get oQuant Var nQtdEtiq  PICT "@E 999,999.99" SIZE _nWidth-65,15 FONT _oFont Of _oAreaMain  Pixel

		//	oQuant := 	TGet():New(17*4-16,60,bSetGet(nQtdEtiq),_oAreaMain,_nWidth-065,13,"@E 999,999.99", {|| .T. }  ,,,_oFont,,,;
		//		.T.,,,,,,,,,,,,,,.T.,.F.,,,1 )

		_oBtnBar:= FWButtonBar():New()
		_oBtnBar:Init( _oAreaMain, 030, 030, CONTROL_ALIGN_BOTTOM, .T. )
		_oBtnBar:addBtnImage( "FINAL.PNG" , "Sair <ESC>" , {|| _lValid:=.F. , _oDlgMain:End()}, , .T., CONTROL_ALIGN_LEFT)
		_oBtnBar:addBtnImage( "OFFICEBTNSEARCHCLEAR.PNG" , "Limpar Tela" , {|| BRLIMPA()}, , .T., CONTROL_ALIGN_LEFT)
		_oBtnBar:addBtnImage( "STOP.PNG" , "Encerra Contagem" , {|| FWMsgRun(, {||aiv035Fim() },,"Aguarde! Encerrando Contagem...","Inv")}, , .T., CONTROL_ALIGN_RIGHT)
		_oBtnBar:addBtnImage( "OK.PNG" , "Confirmar Contagem <ENTER>" , {|| FWMsgRun(, {|| VldEtiPro() },,"Aguarde! Registrando Contagem...","Inv")}, , .T., CONTROL_ALIGN_RIGHT)

		Activate MsDialog _oDlgMain //Center
	End

	If .NOT. Empty(cEndereco) .and. .NOT. Empty(cCodInv)

		//	aiv035Fim()

		If lCBINVFIM
			lRet:=ExecBlock('CBINVFIM',.F.,.F.)
			If ValType(lRet)#"L"
				Return (.T.)
			EndIf
		EndIF

	EndIf

Return (NIL)

/*/{Protheus.doc} VldEnd
Valida Endereco na contagem
@type function Processamento
@version 1.0
@author marioantonaccio
@since 19/11/2025
@param cEndereco, character, Codigo do Endereco
@return Logical, se encontrou ou nao o endereco
/*/
Static Function VldEnd(cEndereco)
	Local lRet:=.T.

	cEndereco:=AllTrim(cEndereco)

	If .NOT. _lValid    //Se abortou processo
		Return (.T.)
	End

	CBA->(dbSetOrder(4))

	If .NOT. (CBA->(dbSeek(xFilial("CBA")+cEndereco)))
		VTAlert('Endereco nao Localizado: '+cEndereco,'Atencao',MB_ICONHAND,4000)
		lRet:=.F.
	End

	If nTipoEst == 5 .or. nTipoEst == 4 //coletor/ACD condição por causa do enter final de cada campo pelo coletor
		If lRet .and. Empty(cEndereco)
			Return(.F.)
		End
	End

	If  lRet .and. .NOT. CBA->CBA_STATUS $ ("0/1")
		VTAlert('Inventario nao Disponivel. Status: '+CBA->CBA_STATUS ,'Atencao',MB_ICONHAND,4000)
		lRet:=.F.
	End

	If lRet .and. .NOT. CBA->CBA_TIPINV == "2" //1=Endereco / 2 = Produto
		VTAlert('Tipo de Inventario diferente do indicado','Atencao',MB_ICONHAND,4000)
		lRet:=.F.
	End

	If lRet .and.  DTOS(CBA->CBA_DATA) > DTOS(dDataBase)
		VTAlert('Data de Inventario Invalida','Atencao',MB_ICONHAND,4000)
		lRet:=.F.
	EndIf

	If lRet
		cCodInv:=CBA->CBA_CODINV
		oCodInv:cText:=cCodInv
		oCodInv:REFRESH()

		If .NOT. VldCodInv(cCodInv)
			lRet:=.F.
		End

	End

	If lRet
		//	oEndereco:lReadOnly		:= .T.
		//  oEndereco:lCanGotFocus 	:= .F.
		//	oEndereco:Refresh()

		oEtiqProd:lReadOnly		:= .F.
		oEtiqProd:lCanGotFocus 	:= .T.
		oEtiqProd:SetFocus()
	Else
		BRLIMPA()
	End

Return (lRet)

/*/{Protheus.doc} VldProd
Valida produto na contagem
@type function Processamento
@version 1.00
@author marioantonaccio
@since 19/11/2025
@param cProduto, character, Codigo do Produto
@return Logical, retorna se encontra ou nao o produto
/*/
Static Function VldProd(cProduto)


	If .NOT. _lValid .or. Empty(cProduto)
		Return (.T.)
	End

	If Len(AllTrim(cProduto)) == 14 //Indica etiqueta de volume
		If Select("XSC2")  > 0
			XSC2->(dbCloseArea())
		End

		BeginSql ALIAS "XSC2"
			SELECT
				DISTINCT C2_LOTE,
				C2_PRODUTO
			FROM
				%Table:SC2%
			WHERE
				%NotDel%
				AND C2_LOTE = %Exp:Substr(cProduto,1,6)%
				AND SUBSTRING(C2_PRODUTO, 11, 2) = %Exp:Substr(cProduto,7,2)%
				AND SUBSTRING(C2_PRODUTO, 11, 2) NOT IN ('00', '99')
		EndSql
		If .NOT. BOF() .or. .NOT. EOF()
			cProduto:=XSC2->C2_PRODUTO
		Else
			cProduto:=Space(15)
			VTAlert("Produto nao Encontrado " +cProduto,'Atencao',MB_ICONHAND)
			Return (.F.)
		End
		XSC2->(dbCloseArea())

	Else

		SB1->(dbSetOrder(5)) // Cod Barra
		If .NOT. SB1->(dbSeek(xFilial("SB1")+cProduto))
			SB1->(dbSetOrder(1)) //Codigo Produto
			If .NOT. SB1->(dbSeek(xFilial("SB1")+cProduto))
				VTAlert("Produto nao Encontrado " +cProduto,'Atencao',MB_ICONHAND)
				Return (.F.)
			Else
				cProduto:=SB1->B1_COD
			End
		Else
			cProduto:=SB1->B1_COD
		End
	End


	/*
	SB1->(dbSetOrder(5)) // Cod Barra
	SB1->(dbSeek(xFilial("SB1")+cProduto))

	SB1->(dbSetOrder(1)) //Codigo Produto
	SB1->(dbSeek(xFilial("SB1")+cProduto))
	*/
	//cEtiqProd:=cProduto

	//	oEndereco:lReadOnly    := If(Empty(cEndereco),.F.,.T.)
	//	oEndereco:lCanGotFocus := If(Empty(cEndereco),.T.,.F.)

	oEtiqProd:cCaption     := ''
	oEtiqProd:lReadOnly    := .F.
	oEtiqProd:lCanGotFocus := .T.
	oEtiqProd:Refresh()

	oQuant:lReadOnly       := .F.
	oQuant:lCanGotFocus    := .T.
	oQuant:SetFocus()

Return (.T.)

/*/{Protheus.doc} VldCodInv
Valida o codigo de inventario do Mestre de Invetario
@type function Processamento
@version 1.0
@author marioantonaccio
@since 19/11/2025
@param cCodInv, character,Codigo do inventario (referencia)
@param lAlert, logical, Indica se mostra algum erro
@return logical, retorna sempre verdadeiro
/*/
Static Function VldCodInv(cCodInv,lAlert)

	Local _cCodOpe  := RetCodusr()
	Local aCBC      := {}
	Local cUltCont
	Local lRetorno
	Local lV035VLDM := ExistBlock("V035VLDM")
	Local nX
	Local nY

	Private _nReCB0 := 0

	Default lAlert	:= .T.

	_cCodOpe:=If(Empty(_cCodOpe),Space(TamSX3("CBB_USU")[1]),_cCodOpe)

	//Remonta o cod inventario
	//cCodInv:=Space(09)

	If .NOT. Empty(cCodInv)

		cCodInv := StrZero( Val( cCodInv ) ,9 )
		oCodInv:cText := cCodInv

		CBA->(DbSetOrder(1))

		If .NOT. CBA->(DbSeek(xFilial('CBA')+cCodInv))
			VTAlert('Codigo mestre de inventario nao cadastrado','Atencao',MB_ICONHAND,4000) //'Codigo mestre de inventario nao cadastrado'###'Atencao'
			Return (.F.)
		EndIf

		If CBA->CBA_STATUS$"4-5" // 4=Finalizado / 5=Processado
			VTAlert('Inventario finalizado','Atencao',MB_ICONHAND,4000) //'Inventario finalizado'###'Atencao'
			Return (.F.)
		EndIf

		If (CB1->CB1_INVPVC <> "1")// mesmo operador executar o mesmo inventario

			CBB->(dbSetOrder(2))

			If CBB->(dbSeek(xFilial('CBB')+"2"+_cCodOpe+CBA->CBA_CODINV ))
				VTAlert("Operador ja realizou contagem para o inventario","Sem permissao",MB_ICONHAND,4000)  //"Operador ja realizou contagem para o inventario"###"Sem permissao"
				Return (.F.)
			EndIf

		EndIf

		/*
		If DTOS(CBA->CBA_DATA)<=DTOS(dDataBase)
			VTAlert('Data do "Mestre de Inventario" deve ser igual a "Data Base" do sistema!','Atencao',MB_ICONHAND,4000,3) //'Data do "Mestre de Inventario" deve ser igual a "Data Base" do sistema!'
			VTAlert(I18N("Somente o Operador ",{DTOC(CBA->CBA_DATA)}),'Atencao',MB_ICONHAND)  //"Somente o Operador "###" pode dar continuidade a este inventario"###"Contagens == 1"
			Return (.F.)
		EndIf
		*/

		If CBA->CBA_CONTS == 1
			CBB->(DbSetOrder(1))
			If CBB->(DbSeek(xFilial('CBB')+CBA->CBA_CODINV )) .and. CBB->CBB_USU # _cCodOpe
				VTAlert("Somente o Operador "+CBB->CBB_USU+" pode dar continuidade a este inventario","Contagens == 1",MB_ICONHAND,4000)  //"Somente o Operador "###" pode dar continuidade a este inventario"###"Contagens == 1"
				Return (.F.)
			Endif
		Endif

		CBB->(DbSetOrder(2))

		If CBB->(DbSeek(xFilial('CBB')+"1"+_cCodOpe+CBA->CBA_CODINV ))

			If .NOT. CBB->(RLock())
				VTAlert('Operador executando inventario em outro terminal','Atencao',MB_ICONHAND,4000) //'Operador executando inventario em outro terminal'###'Atencao'
				Return (.F.)
			EndIf
			CBB->(DBUnLock())
			Reclock("CBB",.F.)

		Else

			cUltCont:=Space(TamSX3("CBB_NUM")[1])

			If .NOT. lModelo1 // se for modelo 2 tem que verificar se tem autorizacao
				If CBA->CBA_AUTREC=="2" // BLOQUEADO
					VTAlert("Inventario bloqueado para auditoria",'Atencao',MB_ICONHAND,4000) //'Atencao' //"Inventario bloqueado para auditoria"
					Return (.F.)
				EndIf
				cUltCont := CBUltCont(CBA->CBA_CODINV)
			EndIf

			Reclock("CBB",.T.)
			CBB->CBB_FILIAL := xFilial("CBB")
			CBB->CBB_NUM    := CBProxCod( 'MV_USUINV' )
			CBB->CBB_CODINV := CBA->CBA_CODINV
			CBB->CBB_USU    := _cCodOpe
			CBB->CBB_STATUS := "1"
			CBB->(MsUnlock())

			cArmazem := CBA->CBA_LOCAL

			oCodInv:lReadOnly		:= .T.
			oCodInv:lCanGotFocus 	:= .F.

			// Incrementa numero de contagens realizadas do mestre
			CBAtuContR(CBB->CBB_CODINV, 1)

			Reclock("CBB",.F.)
			//-- transpor as contagens batidas para este usuario
			If .NOT. lModelo1 .and. .NOT.  Empty(cUltCont)

				CBC->(DbSetOrder(1))
				CBC->(DbSeek(xFilial('CBC')+cUltCont))

				While .NOT. CBC->(EOF() .and. xFilial('CBC')+cUltCont == CBC_FILIAL+CBC_NUM)

					If CBC->CBC_CONTOK=="1"
						AADD(aCBC,array(CBC->(FCount())))
						For nX:= 1 to CBC->(FCount())
							aCBC[Len(aCBC),nX] := CBC->(FieldGet(nX))
						Next
					EndIf

					CBC->(DbSkip())

				End

				For nX:= 1 to Len(aCBC)
					Reclock("CBC",.T.)
					For nY := 1 to CBC->(FCount())
						If CBC->(FieldName(nY)) == "CBC_CODINV"
							CBC->CBC_CODINV    := CBB->CBB_CODINV
						ElseIf CBC->(FieldName(nY)) == "CBC_NUM"
							CBC->CBC_NUM    := CBB->CBB_NUM
						Else
							CBC->(FieldPut(nY,aCBC[nX,nY]))
						EndIf
					Next
					CBC->(MsUnLock())
				Next

			EndIf

		EndIf

		//Analisando Classificacao por curva ABC
		cClasses := ""

		If CBA->CBA_CLASSA=="1"
			cClasses+="A"
		EndIf

		If CBA->CBA_CLASSB=="1"
			cClasses+="B"
		EndIf

		If CBA->CBA_CLASSC=="1"
			cClasses+="C"
		EndIf

		CBLoadEst(aProdEnd)

		If CBA->CBA_STATUS=='0'
			IniciaCBM(aProdEnd)
		EndIf

		RecLock("CBA",.F.)
		If .NOT. lModelo1 				// se for modelo 2 tem que verificar se tem autorizacao
			CBA->CBA_AUTREC:="2" 	// BLOQUEADO
		EndIf
		CBA->CBA_STATUS := "1"  	// 1=Em andamento
		CBA->(MsUnlock())

		If lV035VLDM
			lRetorno := ExecBlock("V035VLDM",.F.,.F.)
			lRetorno := If(ValType(lRetorno)=="L",lRetorno,.T.)

			If  .NOT. lRetorno
				Return (.F.)
			Else
				lRetorno:= NIL
			Endif

		Endif

		If CBA->CBA_TIPINV =="2" .and. lAlert
			//	VTAlert("Va para o Armazem "+CBA->CBA_LOCAL+" Endereco "+CBA->CBA_LOCALI,"Aviso",MB_ICONHAND,4000) //"Va para o Armazem "###" Endereco "###"Aviso"
			cEndereco 	:= CBA->CBA_LOCALI
			oEndereco:cToolTip	:= CBA->CBA_LOCALI
			oEndereco:lCanGotFocus 	:= .F.
		EndIf

		If Unitiza( CBA->CBA_LOCALI )

			oEndereco:lReadOnly		:= .T.
			oEndereco:lCanGotFocus 	:= .F.

			oEtiqProd:lReadOnly		:= .T.
			oEtiqProd:lCanGotFocus 	:= .F.

			oQuant:lReadOnly		:= .T.
			oQuant:lCanGotFocus 	:= .F.

		Else
			If _nReCB0 > 0
				If VTAlert("Confirma exclusão da unitização?","Aviso",MB_YESNO)
					DbSelectArea('CB0')
					CB0->(DbGoTo(_nReCB0))
					If CB0->(Recno()) == _nReCB0
						RecLock('CB0',.F.)
						DbDelete()
						CB0->(MsUnlock())
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Return (.T.)

/*/{Protheus.doc} VTAlert
Mostra mensgens na tela
@type function tela
@version 1.0
@author marioantonaccio
@since 19/11/2025
@param cMSG, character, Mensagem para ser mostrada
@param cTit, character, titulo da janela
@param nFlag, numeric, Indicador
@param nSecs, numeric, Segundos para exibição mensagem
@param nX, numeric,Contador
@return logical, retorna ou nao a tela
/*/
Static Function VTAlert( cMSG, cTit , nFlag, nSecs, nX)

	Local lRet := .T.
	Local nRet	:= 0

	nRet := MessageBox(cMSG, cTit, nFlag)

	If nRet = 7 .or. nRet = 2
		lRet := .F.
	EndIf

Return (lRet)

/*/{Protheus.doc} AIV035FIM
description
@type function
@version 1.0
@author marioantonaccio
@since 26/11/2025
@return logical, sempre .T.
/*/
Static Function AIV035FIM()

	Local cCodInv    := ""
	Local lPerExcInv := SuperGetMv("MV_CBEXMIN", .F., .F.)
	Local lUniCPO    := CBC->(ColumnPos("CBC_IDUNIT")) > 0
	Local lWmsNew    := SuperGetMv("MV_WMSNEW",.F.,.F.)
	Local nRecCBB
	Local nX

	If .NOT. VTAlert("Deseja finalizar a contagem?","Aviso",MB_YESNO)
		// sandro
		// vereficar se nao leu nada para voltar o status
		CBB->(MsUnlock())

		//³ Estorna contagem possicionada e altera status se necessario. ³
		//VoltaStatus()
		VTAlert("A Contagem permanece em andamento!","Aviso",MB_OK)
		Return (.F.)
	EndIf

	// BY ERIKE Verificar se existe produtos a serem contados para este mestre
	CBLoadEst(aProdEnd,.F.)
	CBC->(dbSetOrder(1))

	If Empty(aProdEnd) .and. .NOT. CBC->(dbSeek(xFilial('CBC')+CBB->CBB_NUM))

		If CBA->CBA_TIPINV == "1" // Por Produto
			VTAlert("Nao existem Produtos para este endereco. A contagem nao sera finalizada!","Aviso",MB_ICONHAND)
			CBB->(MsUnlock())
			Return (NIL)
		Else	//Por Endereco
			CBB->(MsUnlock())
			nRecCBB := CBB->(RecNo())

			//Caso este endereco estaja vazio, e nao exista ocorrencia de  ³
			// contagem, sera perguntado para o operador se o mesmo deseja  ³
			// continuar com a contagem em aberto, ou finalizar o mestre de ³
			// inventario.                                                  ³
			CBC->(dbSetOrder(3))
			If  .NOT. CBC->(DbSeek(xFilial('CBC')+CBA->CBA_CODINV))
				//Realiza desbloqueio do endereço
				If lWmsNew
					SBE->(dbSetOrder(1))
					If SBE->(dbSeek(xFilial('SBE')+CBA->(CBA_LOCAL+CBA_LOCALI)))
						RecLock("SBE",.F.)
						SBE->BE_STATUS  := "1"
						SBE->(MsUnlock())
					Endif
				EndIf

				VTAlert("Nao existem saldo(s) para este(s) produto(s) neste endereco, "+;
					"nem foi detectada a ocorrencia de inventario para este mestre!"+CRLF+;
					"Este mestre deve ser excluido, caso contrario a contagem nao sera "+;
					"finalizada.","Atencao",MB_ICONHAND)

				//Permite operador excluir Mestre inventario (tipo=endereco) por RF para inventario de endereco sem saldo.
				If lPerExcInv
					If VTAlert("Deseja excluir este mestre de inventario?","Atencao",MB_YESNO)
						//Apaga Contagem atual
						CBB->(DbDelete())
						CBB->(MsUnLock())

						//Apaga Mestre de inventario
						RecLock('CBA',.F.)
						CBA->(dbDelete())
						CBA->(MsUnLock())
					Else
						cCodInv := CBB->CBB_CODINV
						//Apaga Contagem atual
						RecLock('CBB',.F.)
						CBB->(DbDelete())
						CBB->(MsUnLock())

						RecLock('CBA',.F.)
						CBA->CBA_STATUS := "6" //"Endereco Sem Saldo" -> aProdEnd retorna vazio
						CBA->(MsUnLock())

						//³ Decrementa numero de contagens realizadas do mestre          ³
						CBAtuContR(cCodInv, 2)

					EndIf

					ACDA30Exc()

				Else

					cCodInv := CBB->CBB_CODINV
					//Apaga Contagem atual
					RecLock('CBB',.F.)
					CBB->(DbDelete())
					CBB->(MsUnLock())

					//Atualiza o status do mestre como nao inicial
					RecLock('CBA',.F.)
					CBA->CBA_STATUS := "6" //"Endereco Sem Saldo" -> aProdEnd retorna vazio
					CBA->(MsUnLock())

					//³ Decrementa numero de contagens realizadas do mestre          ³
					CBAtuContR(cCodInv, 2)

				EndIf
			Else
				CBB->(MsGoto(nRecCBB))
				VTAlert("Nao existem produtos para este endereco nos saldos do sistema, "+;
					"porem foi detectada a ocorrencia de inventario para este mestre! "+CRLF+;
					"Sera necessario excluir esta contagem, caso contrario a contagem nao sera "+;
					"finalizada.","Atencao",MB_ICONHAND)

				If VTAlert("Deseja excluir a contagem atual?","Atencao",MB_YESNO)

					cCodInv := CBB->CBB_CODINV

					RecLock('CBB',.F.)
					CBB->(DbDelete())
					CBB->(MsUnLock())

					//³ Decrementa numero de contagens realizadas do mestre          ³
					CBAtuContR(cCodInv, 2)

				EndIf

				If CBA->CBA_STATUS == "0"
					ACDA30Exc()
				EndIf

			EndIf

			Return (NIL)

		EndIf

	EndIf

	dbSelectArea("CBC")
	CBC->(dbSetOrder(1))

	If .NOT. CBC->(dbSeek(xFilial('CBC')+CBB->CBB_NUM))

		If .NOT. VTAlert('Nenhum produto foi inventariado, confirma estoque Zero',"Aviso",MB_YESNO) //'Nenhum produto foi inventariado, confirma estoque Zero'###"Aviso"

			CBB->(MsUnlock())

			//³ Estorna contagem possicionada e altera status se necessario. ³
			VoltaStatus()

			Return (NIL)

		Else

			For nX:= 1 To Len(aProdEnd)
				RecLock("CBC",.T.)
				CBC->CBC_FILIAL := xFilial("CBC")
				CBC->CBC_CODINV := CBB->CBB_CODINV
				CBC->CBC_NUM    := CBB->CBB_NUM
				CBC->CBC_LOCAL  := aProdEnd[nX,4]
				CBC->CBC_LOCALI := aProdEnd[nX,5]
				CBC->CBC_COD    := aProdEnd[nX,1]
				CBC->CBC_LOTECT := aProdEnd[nX,2]
				CBC->CBC_NUMLOT := aProdEnd[nX,3]
				CBC->CBC_NUMSER := aProdEnd[nX,6]
				If lUniCPO .and.IntWms(aProdEnd[nX,1])
					CBC->CBC_IDUNIT := aProdEnd[nX,9]
					CBC->CBC_CODUNI := aProdEnd[nX,10]
				EndIf
				CBC->CBC_QUANT  := 0
				CBC->(MSUNLOCK())
			Next

		EndIf

	Else

		AllProd()

		CBC->(dbSetOrder(2))

		For nX:= 1 To Len(aProdEnd)

			If .NOT. lWmsNew
				If CBC->(dbSeek(xFilial('CBC')+CBB->CBB_NUM+aProdEnd[nX,1]+aProdEnd[nX,4]+aProdEnd[nX,5]+aProdEnd[nX,2]+aProdEnd[nX,3]+aProdEnd[nX,6]))
					// se encontrar nao eh necessario completar a contagem para compatibilizar o estoque
					Loop
				EndIf
			ElseIf lUniCPO .and. lWmsNew
				If CBC->(dbSeek(xFilial('CBC')+CBB->CBB_NUM+aProdEnd[nX,1]+aProdEnd[nX,4]+aProdEnd[nX,5]+aProdEnd[nX,2]+aProdEnd[nX,3]+aProdEnd[nX,6]+aProdEnd[nX,9]))
					Loop
				EndIf
			EndIf

			RecLock("CBC",.T.)
			CBC->CBC_FILIAL := xFilial("CBC")
			CBC->CBC_CODINV := CBB->CBB_CODINV
			CBC->CBC_NUM    := CBB->CBB_NUM
			CBC->CBC_LOCAL  := aProdEnd[nX,4]
			CBC->CBC_LOCALI := aProdEnd[nX,5]
			CBC->CBC_COD    := aProdEnd[nX,1]
			CBC->CBC_LOTECT := aProdEnd[nX,2]
			CBC->CBC_NUMLOT := aProdEnd[nX,3]
			CBC->CBC_NUMSER := aProdEnd[nX,6]
			if lUniCPO .and.IntWms(aProdEnd[nX,1])
				CBC->CBC_IDUNIT := aProdEnd[nX,9]
				CBC->CBC_CODUNI := aProdEnd[nX,10]
			EndIf
			CBC->CBC_QUANT  := 0
			CBC->(MSUNLOCK())

		Next nX

	Endif

	dbSelectArea("CBB")
	RecLock("CBB",.F.)
	CBB->CBB_STATUS := "2"
	CBB->CBB_NCONT:=1
	CBB->(MsUnlock())

	If .NOT. Ultimo()
		Return (NIL)
	EndIF

	dbSelectArea("CBA")
	RecLock("CBA",.F.)
	//	CBA->CBA_STATUS := "3" //Contado
	CBA->(MsUnLock())

	If GetMV("MV_ANAINV") # "1"
		//Esta funcao eh executada para atualizar o CBA_ANALIS (que indica se existe divergencia ou nao no mestre de inventario)
		AnalisaInv(.F.)
		Return (NIL)
	EndIf

	CBAnaInv()

Return (.T.)

/*/{Protheus.doc} AllProd
description
@type function
@version
@author marioantonaccio
@since 26/11/2025
@param , variant, param_description
@return variant, return_description
/*/
Static Function AllProd( )

	Local _cWkSBF   := GetNextAlias()
	Local _cLocal   := CBA->CBA_LOCAL
	Local _cEnder   := CBA->CBA_LOCALIZ
	Local _cMaster  := CBA->CBA_CODINV
	Local _cNum     := CBB->CBB_NUM

	BeginSql alias _cWkSBF
		SELECT
			BF_PRODUTO,
			BF_LOCAL,
			BF_LOCALIZ
		FROM
			%Table:SBF% (NOLOCK) SBF
		WHERE
			BF_FILIAL = %Exp:cFilAnt%
			AND BF_LOCAL = %Exp:_cLocal%
			AND BF_LOCALIZ = %Exp:_cEnder%
			AND BF_PRODUTO NOT IN (
				SELECT
					CBC_COD
				FROM
					%Table:CBC% CBC (NOLOCK)
				WHERE
					CBC_FILIAL = %Exp:cFilAnt%
					AND CBC_CODINV = %Exp:_cMaster%
					AND %notDel%
			)
			AND SBF.%notDel%
	EndSql

	While .NOT. (_cWkSBF)->(EOF())

		nPosField := AScan( aProdEnd, {|x| AllTrim(x[1]) == AllTrim((_cWkSBF)->BF_PRODUTO)} )

		If nPosField == 0

			Aadd( aProdEnd,{	(_cWkSBF)->BF_PRODUTO	,	;
				'	'					,	;
				'	'					,	;
				(_cWkSBF)->BF_LOCAL		,	;
				(_cWkSBF)->BF_LOCALIZ	,	;
				'	'					,	;
				0	,Nil,Nil})

		EndIf

		RecLock('CBC', .T.)
		CBC_FILIAL  := cFilAnt
		CBC_CODINV  := _cMaster
		CBC_NUM     := _cNum
		CBC_COD     := (_cWkSBF)->BF_PRODUTO
		CBC_LOCAL   := (_cWkSBF)->BF_LOCAL
		CBC_QUANT   := 0
		CBC_QTDORI  := 0
		CBC_LOCALI  := (_cWkSBF)->BF_LOCALIZ
		CBC_AJUST   := '2'
		MsUnlock()

		(_cWkSBF)->(DbSkip())

	EndDo

	(_cWkSBF)->(DbCloseArea())

Return (NIL)

/*/{Protheus.doc} CBAnaInv
description
@type function
@version
@author marioantonaccio
@since 26/11/2025
@param lMonitor, logical, param_description
@param lAutomatico, logical, param_description
@param lApp, logical, param_description
@param aProdEnd, array, param_description
@param lautApp, logical, param_description
@return variant, return_description
/*/
Static Function CBAnaInv(lMonitor,lAutomatico,lApp,aProdEnd,lautApp)

	Local nX		:= 0
	Local lRet		:= .F.
	Local lModelo1	:= SuperGetMv("MV_CBINVMD")=="1"
	Local cInvRes 	:= 'INVRES'+ STRTRAN(AllTrim(cEmpAnt),' ','_')+ STRTRAN(AllTrim(cFilAnt),' ','_')
	Local lLock340	:= SuperGetMV("MV_340LOCK",.F.,"F") == "U" // F = Filial ou U = Usuario

	DEFAULT lMonitor   	:= .F.
	DEFAULT lAutomatico	:= .F.
	DEFAULT lApp 		:= .F.
	DEFAULT lautApp		:= Nil

	If lAutApp <> Nil
		//Altero sua propriedade somente se for do ACD Mobile
		lMsErroAuto	:= lAutApp
	EndIF

	If lLock340
		cInvRes	:= 'INVRES'+ STRTRAN(AllTrim(cEmpAnt),' ','_')+ STRTRAN(AllTrim(cFilAnt),' ','_')+ STRTRAN(AllTrim(RetCodusr()),' ','_')
	EndIf

	If MsFile(cInvRes,,"TOPCONN")

		If select(cInvRes) >0
			(cInvRes)->(DbCloseArea())
		EndIf

		USE (cInvres) EXCLUSIVE NEW VIA "TOPCONN"

		If .NOT. (NetErr())
			DbSelectArea(cInvRes)
			ZAP
			(cInvRes)->(DbCloseArea())
		EndIf

	EndIf

	Begin Transaction

		If Type('aLogMestre') # 'A'
			Private aLogMestre := {}
		EndIf

		__cMestre   := ""
		__aRetCount := AnalisaInv(lMonitor,aProdEnd)

		If __aRetCount[1]

			If IsTelNet()
				lRet := AcertoInv(aClone(__aRetCount[2]),aClone(__aRetCount[3]),aClone(__aRetCount[4]),lMonitor,lAutomatico,aProdEnd)
			Else
				ProcRegua(Len(__aRetCount[2]))
				FWMsgRun(, {|| lRet := AcertoInv(aClone(__aRetCount[2]),aClone(__aRetCount[3]),aClone(__aRetCount[4]),lMonitor,lAutomatico,aProdEnd)},;
					"Aguarde! Analisando Inventario...","Inv")
			EndIf

			If .NOT. lRet
				DisarmTransaction()
				If  .NOT. lAutomatico
					VTAlert("Falha na gravacao do inventario","ERRO",MB_ICONHAND)  //###
				EndIf
				Break
			Endif

			//Ajusta localizacao
			If lRet .And. SuperGetMv("MV_ALTENDI") == "1" .And. lUsaCB001
				CB0->(DbSetorder(1))
				For nX:=1 To Len(__aRetCount[4])
					If CB0->(DbSeek(xFilial("CB0")+__aRetCount[4,nX])) .And. CBA->(CBA_LOCAL+CBA_LOCALI) <> CB0->(CB0_LOCAL+CB0_LOCALI)
						RecLock("CB0",.F.)
						CB0->CB0_LOCAL  := __aRetCount[3,nX,3]
						CB0->CB0_LOCALI := __aRetCount[3,nX,4]
						MsUnLock()
					EndIf
				Next
			EndIf
		Endif

		DbSelectArea("CBA")
		RecLock("CBA",.F.)
		If __aRetCount[5] .and. .NOT. lMsErroAuto .and. CBA->CBA_STATUS # "5"
			CBA->CBA_STATUS := "4"  // 4-finalizado
		EndIf
		CBA->(MsUnlock())

	End Transaction

	If lMsErroAuto
		If lAutomatico
			Aadd(aLogMestre,{CBA->CBA_CODINV,0,"-->Mestre:"+CBA->CBA_CODINV+" - Erro na rotina automatica",.F.})
			lMsErroAuto := .F.
		Else
			If IsTelNet()
				VTDispFile(NomeAutoLog(),.t.)
			Else
				MostraErro()
			EndIf
		EndIf
	Else
		If __aRetCount[1]
			If lAutomatico
				Aadd(aLogMestre,{CBA->CBA_CODINV,0,"Mestre "+CBA->CBA_CODINV+" foi finalizado com sucesso",.T.})
			Else
				VTAlert("Inventario concluido","Aviso",MB_OK)
				//xbsurdo
				cEtiqProd := Space(015)
				cCodInv    := Space(009)
				cEndereco  := Space(010)
				cEspaco:=" "

				nQtdEtiq   := 0
				oCodInv:Refresh()
				oEtiqProd:Refresh()

				oQuant:Refresh()

				oEndereco:lReadOnly		:= .F.
				oEndereco:lCanGotFocus 	:= .T.
				oEndereco:SetFocus()
				oEndereco:Refresh()
			Endif
		Else
			If lAutomatico
				Aadd(aLogMestre,{CBA->CBA_CODINV,0,"--> Mestre: "+CBA->CBA_CODINV+" - Nao foi finalizado",.F.})
				Aadd(aLogMestre,{CBA->CBA_CODINV,1,If(lModelo1,"- Contagem divergente","- Inventario bloqueado para auditoria"),.F.})
			Else
				If lModelo1
					VTAlert("Contagem finalizada","Inventario",MB_OK)

					//absurdo
					cEtiqProd := Space(015)
					cCodInv    := Space(009)
					cEndereco  := Space(010)
					nQtdEtiq   := 0

					oCodInv:Refresh()

					oEtiqProd:Refresh()

					oQuant:Refresh()

					oEndereco:lReadOnly		:= .F.
					oEndereco:lCanGotFocus 	:= .T.
					oEndereco:SetFocus()
					oEndereco:Refresh()

				Else
					VTAlert("Inventario bloqueado para Auditoria","Inv. em andamento",MB_ICONHAND)
				EndIf
			EndIf
		Endif
	EndIf

Return (.T.)

/*/{Protheus.doc} AnalisaInv
description
@type function
@version
@author marioantonaccio
@since 26/11/2025
@param lMonitor, logical, param_description
@param aprodend, array, param_description
@return variant, return_description
/*/
Static Function AnalisaInv(lMonitor,aprodend)

	Local aEtiLidas := {}
	Local aEtiQtdOK := {}
	Local aProdAux  := {}
	Local aProdNoOk := {}
	Local aProdOK   := {}
	Local aProdOK2  := {}
	Local aProds    := {}
	Local cArm
	Local cAux      := ''
	Local cCodCBB   := CBB->CBB_NUM
	Local cEnd
	Local cIdunit
	Local cLote
	Local cNumSeri
	Local cProduto
	Local cSLote
	Local i
	Local j
	Local lModelo1  := SuperGetMv("MV_CBINVMD")=="1"
	Local lOK       := .F.
	Local lUniCPO   := CBC->(ColumnPos("CBC_IDUNIT")) > 0
	Local lUsaCB001 := UsaCB0("01")
	Local lWmsNew   := SuperGetMv("MV_WMSNEW",.F.,.F.)
	Local nLen
	Local nPos
	Local nSaldo
	Local nTamArm   := TamSx3("B2_LOCAL")[1]
	Local nTamEnd   := TamSX3("BF_LOCALIZ")[1]
	Local nTamLote  := TamSX3("B8_LOTECTL")[1]
	Local nTamProd  := Tamsx3("B1_COD")[1]
	Local nTamSeri  := TamSX3("BF_NUMSERI")[1]
	Local nTamSLote := TamSX3("B8_NUMLOTE")[1]
	Local nTamUnit  := TamSX3("D14_IDUNIT")[1]
	Local oEstEnder := Nil

	Private aCods  	:= {}

	If lModelo1

		CBB->(dbSetOrder(1))
		CBB->(dbSeek(xFilial('CBB')+CBA->CBA_CODINV))

		While .NOT. CBB->(EOF()) .and. xFilial("CBB") == CBB->CBB_FILIAL .and. CBB->CBB_CODINV == CBA->CBA_CODINV
			If CBB->CBB_STATUS == "2"
				Aadd(aCods,CBB->CBB_NUM)
			EndIf
			CBB->(dbSkip())
		EndDo

		For i := 1 To Len(aCods)

			CBC->(dbSetOrder(1))
			CBC->(dbSeek(xFilial('CBC')+aCods[i]))

			While .NOT. CBC->(Eof()) .and. xFilial("CBC") == CBC->CBC_FILIAL .and. CBC->CBC_NUM == aCods[i]

				cAux:=Space(10)

				If lUsaCB001 .and.  CBProdUnit(CBC->CBC_COD) //.and. .NOT. CBQtdVar(CBC->CBC_COD)
					cAux:= CBC->CBC_CODETI
				EndIf

				If lUsaCB001
					If Ascan(aEtiLidas,CBC->CBC_CODETI) == 0 .And. .NOT. Empty(CBC->CBC_CODETI)
						AADD(aEtiLidas,CBC->CBC_CODETI)
					EndIf
				EndIf

				If lUniCPO .and.lWmsNew
					nPos := Ascan(aProds,{|x| x[1] == CBC->(CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER+cAux+CBC_IDUNIT) .and. x[3]==CBC->CBC_NUM })
				Else
					nPos := Ascan(aProds,{|x| x[1] == CBC->(CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER+cAux) .and. x[3]==CBC->CBC_NUM })
				EndIf

				If nPos > 0
					aProds[nPos,2] +=  CBC->CBC_QUANT
				Else
					If lUniCPO .and.lWmsNew
						Aadd(aProds,{CBC->(CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER+cAux+CBC_IDUNIT),; //1
							CBC->CBC_QUANT,;																		//2
							CBC->CBC_NUM,;																			//3
							CBC->CBC_LOCAL,;																		//4
							CBC->CBC_LOCALI,;																		//5
							CBC->CBC_IDUNIT})																		//6

					Else
						Aadd(aProds,	{CBC->(CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER+cAux),; //1
							CBC->CBC_QUANT,;	//2
							CBC->CBC_NUM,;		//3
							CBC->CBC_LOCAL,;	//4
							CBC->CBC_LOCALI,;	//5
							CBC->CBC_LOTECT,;	//6
							CBC->CBC_NUMLOT,;	//7
							CBC->CBC_NUMSER,;	//8
							CBC->CBC_COD,;		//9
							CBC->CBC_CODETI})	//10
					EndIf
				Endif

				If cCodCBB == CBC->CBC_NUM
					CBC->(CBLog("04",{CBC_COD,CBC_QUANT,CBC_LOTECT,CBC_NUMLOT,CBC_LOCAL,CBC_LOCALI,CBA->CBA_CODINV,CBC_NUM,CBC_CODETI}))
				EndIf

				CBC->(dbSkip())

			End

		Next i

		For i := 1 to Len(aProds)
			For j:= 1 to Len(aCods)
				If .NOT. lUniCPO .and. .NOT. lWmsNew

					CBC->(dbSetOrder(2))

					If .NOT. CBC->(DBSeek(xFilial('CBC')+aProds[i,3]+aProds[i,9]+aProds[i,4]+aProds[i,5]+aProds[i,6]+aProds[i,7]+aProds[i,8]))
						If Ascan(aProds,{|x| x[1] == aProds[i,1] .and. x[2] ==0 .and. x[3] == aCods[j]  }) == 0
							Aadd(aProds,{aProds[i,1],0,aCods[j],aProds[i,4],aProds[i,5]})
						EndIF
					Elseif lUsaCB001
						CBC->(dbSetOrder(1))
						If .NOT. (CBC->(DbSeek(xFilial('CBC') + aCods[j] + aProds[i,10])))
							Aadd(aProds,{aProds[i,1],0,aCods[j],aProds[i,4],aProds[i,5]})
						EndIf
					EndIf

				Elseif lUsaCB001
					CBC->(dbSetOrder(1))
					If .NOT. (CBC->(DbSeek(xFilial('CBC') + aCods[j] + aProds[i,10])))
						Aadd(aProds,{aProds[i,1],0,aCods[j],aProds[i,4],aProds[i,5],aProds[i,6]})
					EndIf
				EndIf
			Next
		Next

		For i := 1 to Len(aProds)

			If lUniCPO .and.lWmsNew
				nLen := LEN(CBC->(CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER+cAux+CBC_IDUNIT))
			Else
				nLen := LEN(CBC->(CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER+cAux))
			EndIf

			nPos := Ascan(aProdAux,{|x| Padr(x[1],LEN(aProds[i,1]))==Padr(aProds[i,1], nLen) .and. StrZero(x[2],12,4) == StrZero(aProds[i,2],12,4) })

			If nPos==0
				If lUniCPO .And.lWmsNew
					Aadd(aProdAux,{aProds[i,1],aProds[i,2],1,aProds[i,4],aProds[i,5],aProds[i,6]})
				Else
					Aadd(aProdAux,{aProds[i,1],aProds[i,2],1,aProds[i,4],aProds[i,5]})
				EndIf
			Else
				aProdAux[nPos,3]++
			EndIF

		Next

		For i := 1 to Len(aProdAux)
			If aProdAux[i,3] >= CBA->CBA_CONTS
				nPos := Ascan(aProdOK,{|x| x[1] == aProdAux[i,1]})
				If nPos== 0

					If lUniCPO .And.lWmsNew
						AADD(aProdOk,{aProdAux[i,1],aProdAux[i,2],aProdAux[i,4],aProdAux[i,5],aProdAux[i,6]})
					Else
						AADD(aProdOk,{aProdAux[i,1],aProdAux[i,2],aProdAux[i,4],aProdAux[i,5]})
					EndIf

					If Subs(aProdAux[i,1],LEN(CBC->(CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER)),10) <> Space(10)
						If lUniCPO .And.lWmsNew
							AADD(aEtiQtdOK,{Subs(aProdAux[i,1],nTamProd+nTamArm+nTamEnd+nTamLote+nTamSLote+nTamSeri+nTamUnit+1,10),aProdAux[i,2],aProdAux[i,4],aProdAux[i,5],aProdAux[i,6]})
						Else
							AADD(aEtiQtdOK,{Subs(aProdAux[i,1],nTamProd+nTamArm+nTamEnd+nTamLote+nTamSLote+nTamSeri+1,10),aProdAux[i,2],aProdAux[i,4],aProdAux[i,5]})
						EndIf
					EndIf

				EndIf
			Else
				nPos := Ascan(aProdNoOK,{|x| x[1] == aProdAux[i,1]})

				If nPos == 0
					AADD(aProdNoOK,{aProdAux[i,1]})
				EndIf

			EndIf
		Next

		For i := 1 to Len(aProdOk)
			nPos := Ascan(aProdNoOK,{|x| x[1] == aProdOK[i,1]})

			If nPos > 0
				aDel(aProdNoOk,nPos)
				aSize(aPRodNoOk,Len(aProdNoOK)-1)
			EndIf
		Next

		aProdOk2:={}

		For i:= 1 to Len(aProdOK)

			If lUniCPO .and.lWmsNew
				nPos := Ascan(aProdOK2,{|x| Left(x[1],nTamProd+nTamArm+nTamEnd+nTamLote+nTamSLote+nTamSeri+10+nTamUnit) == Left(aProdOK[i,1],nTamProd+nTamArm+nTamEnd+nTamLote+nTamSLote+nTamSeri+10+nTamUnit)})
			Else
				nPos := Ascan(aProdOK2,{|x| Left(x[1],nTamProd+nTamArm+nTamEnd+nTamLote+nTamSLote+nTamSeri) == Left(aProdOK[i,1],nTamProd+nTamArm+nTamEnd+nTamLote+nTamSLote+nTamSeri)})
			EndIf

			If nPos == 0
				If lUniCPO .and.lWmsNew
					AADD(aProdOk2,{Left(aProdOK[i,1],nTamProd+nTamArm+nTamEnd+nTamLote+nTamSLote+nTamSeri+10+nTamUnit),aProdOK[i,2],aProdOK[i,3],aProdOK[i,4],aProdOK[i,5]})
				Else
					AADD(aProdOk2,{Left(aProdOK[i,1],nTamProd+nTamArm+nTamEnd+nTamLote+nTamSLote+nTamSeri),aProdOK[i,2],aProdOK[i,3],aProdOK[i,4]})
				EndIf
			Else
				aProdOk2[npos,2] +=aProdOk[i,2]
			EndIF

		Next

		//³ Atualiza o status de analise indicando se esta divergente ou nao ³
		DbSelectArea("CBA")
		RecLock("CBA",.F.)
		If Empty(aProdNoOK)
			CBA->CBA_ANALIS := "1"
		Else
			CBA->CBA_ANALIS := "2"
		EndIf
		CBA->(MsUnLock())
	Else
		// posicionar na ultima contagem
		CBB->(dbSetOrder(3))

		If .NOT. CBB->(dbSeek(xFilial('CBB')+CBA->CBA_CODINV))
			VTAlert("Mestre de Inventario"+CBA->CBA_CODINV+" Nao encontrado",'ERRO',MB_ICONEXCLAMATION) //###
		EndIf

		While .NOT. CBB->(Eof()) .and. xFilial("CBB") == CBB->CBB_FILIAL .and. CBB->CBB_CODINV == CBA->CBA_CODINV
			CBB->(dbSkip())
		EndDo

		CBB->(dbSkip(-1))

		CBC->(dbSetOrder(1))// Aglutinar as quantidade pela chave
		CBC->(dbSeek(xFilial('CBC')+CBB->CBB_NUM))

		While .NOT. CBC->( EOF() .and. xFilial("CBC")+CBB->CBB_NUM == CBC_FILIAL+CBC_NUM)

			cAux:=Space(10)

			If lUsaCB001 .and.  CBProdUnit(CBC->CBC_COD) //.and. CBQtdVar(CBC->CBC_COD)
				cAux:= CBC->CBC_CODETI
			EndIf

			If lUsaCB001
				If Ascan(aEtiLidas,CBC->CBC_CODETI) == 0 .And. .NOT. Empty(CBC->CBC_CODETI)
					AADD(aEtiLidas,CBC->CBC_CODETI)
				EndIf
			EndIf

			If lUniCPO .and.lWmsNew
				nPos := Ascan(aProds,{|x| x[1] == CBC->(CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER+cAux+CBC_IDUNIT) })
			Else
				nPos := Ascan(aProds,{|x| x[1] == CBC->(CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER+cAux) })
			EndIf

			If nPos > 0
				aProds[nPos,2] += CBC->CBC_QUANT
			Else
				If lUniCPO .and.lWmsNew
					Aadd(aProds,{CBC->( CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER+cAux+CBC_IDUNIT),CBC->CBC_QUANT,CBC->CBC_LOCAL,CBC->CBC_LOCALI,CBC->CBC_IDUNIT,CBC->CBC_CODUNI})
				Else
					Aadd(aProds,{CBC->( CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER+cAux),CBC->CBC_QUANT,CBC->CBC_LOCAL,CBC->CBC_LOCALI})
				EndIf
			EndIf

			CBC->(CBLog("04",{CBC_COD,CBC_QUANT,CBC_LOTECT,CBC_NUMLOT,CBC_LOCAL,CBC_LOCALI,CBA->CBA_CODINV,CBC_NUM,CBC_CODETI}))
			CBC->(dbSkip())

		EndDo

		// aglutinar o mesmo produto
		For i:= 1 to Len(aProds)
			If lUniCPO .and.lWmsNew
				nPos := Ascan(aProdAux,{|x| Left(x[1],nTamProd+nTamArm+nTamEnd+nTamLote+nTamSLote+nTamSeri+10+nTamUnit) == ;
					Left(aProds[i,1],nTamProd+nTamArm+nTamEnd+nTamLote+nTamSLote+nTamSeri+nTamUnit)})
			Else
				nPos := Ascan(aProdAux,{|x| Left(x[1],nTamProd+nTamArm+nTamEnd+nTamLote+nTamSLote+nTamSeri) == ;
					Left(aProds[i,1],nTamProd+nTamArm+nTamEnd+nTamLote+nTamSLote+nTamSeri)})
			EndIf
			If nPos== 0
				If lUniCPO .and.lWmsNew
					AADD(aProdAux,{Left(aProds[i,1],nTamProd+nTamArm+nTamEnd+nTamLote+nTamSLote+nTamSeri+10+nTamUnit),aProds[i,2],aProds[i,6]})
				Else
					AADD(aProdAux,{Left(aProds[i,1],nTamProd+nTamArm+nTamEnd+nTamLote+nTamSLote+nTamSeri),aProds[i,2]})
				EndIF
			Else
				aProdAux[nPos,2]+=aProds[i,2]
			EndIf
			If lUsaCB001
				AADD(aEtiQtdOK,{Subs(aProds[i,1],nTamProd+nTamArm+nTamEnd+nTamLote+nTamSLote+nTamSeri+1,10),aProds[i,2],aProds[i,3],aProds[i,4]})
			EndIf
		Next

		For i:= 1 to Len(aProdAux)
			//CBC_COD
			//               CBC_LOCAL
			//                 CBC_LOCALI
			//                                CBC_LOTECT
			//                                          CBC_NUMLOT
			//                                                CBC_NUMSER
			//12345678901234512123456789012345123456789012345612345678901234567890
			//1234567890123456789012345678901234567890123456789012345678901234567980  regua
			//         1         2         3         4         5         6
			cProduto := Subs(aProdAux[i,1],01,nTamProd)
			cArm     := Subs(aProdAux[i,1],nTamProd+1,nTamArm)
			cEnd     := Subs(aProdAux[i,1],nTamProd+1+nTamArm,nTamEnd)
			cLote    := Subs(aProdAux[i,1],nTamProd+1+nTamArm+nTamEnd,nTamLote)
			cSLote   := Subs(aProdAux[i,1],nTamProd+1+nTamArm+nTamEnd+nTamLote,nTamSLote)
			cNumSeri := Subs(aProdAux[i,1],nTamProd+1+nTamArm+nTamEnd+nTamLote+nTamSLote,nTamSeri)
			cIdunit  := Subs(aProdAux[i,1],nTamProd+1+nTamArm+nTamEnd+nTamLote+nTamSLote+nTamSeri+10,nTamUnit)


			If Localiza(cProduto,.T.)
				nSaldo := SaldoSBF(cArm,cEnd,cProduto,cNumSeri,cLote,cSlote)
				If lWmsNew .And. AcdCopVal("CTR", , , ,cProduto)//Valido se o produto tem controle WMS
					// Busca o saldo do produto no endereço, independente se é montado ou desmontado
					oEstEnder := WMSDTCEstoqueEndereco():New()
					nSaldo := oEstEnder:FindSldEnd(cArm,cEnd,,,cProduto,cLote,cSlote,cNumSeri,.F./*lEntrPrev*/,.F./*lSaidaPrev*/,.F./*lEmpenho*/,.F./*lBloqueio*/,cIdUnit)
				EndIf
			ElseIf Rastro(cProduto)
				nSaldo := SaldoLote(cProduto,cArm,cLote,cSLote,.F.)
			Else
				SB2->(DbSetOrder(1))
				SB2->(MsSeek(xFilial('SB2')+cProduto+cArm))
				nSaldo := SaldoSB2(,.F.)
			EndIf

			If Str(aProdAux[i,2],12,4) == Str(nSaldo,12,4)
				nPos := ASCAN(aProdOK,{|x| x[1] == aProdAux[i,1]})
				If nPos== 0
					AADD(aProdOk,{aProdAux[i,1],aProdAux[i,2]})
				EndIf
				If lUniCPO .and.lWmsNew
					nPos := ASCAN(aProdEnd,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6]+x[9]==cProduto+cLote+cSLote+cArm+cEnd+cNumSeri+cIdunit })
				Else
					nPos := ASCAN(aProdEnd,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6]==cProduto+cLote+cSLote+cArm+cEnd+cNumSeri })
				EndIf

				If nPos > 0
					ADEL(aProdEnd,nPos)
					ASIZE(aProdEnd,Len(aProdEnd)-1)
				EndIf
			Else
				nPos := Ascan(aProdNoOK,{|x| x[1] == aProdAux[i,1]})
				If nPos == 0
					If lUniCPO .And. lWmsNew
						AADD(aProdNoOK,{aProdAux[i,1],aProdAux[i,2],IIF(Len(aProdAux[i])>2,aProdAux[i,3],NIL),Nil,Nil})
					Else
						AADD(aProdNoOK,{aProdAux[i,1],aProdAux[i,2],IIF(Len(aProdAux[i])>2,aProdAux[i,3],NIL)})
					EndIf
				EndIf
			EndIf
		Next

		// Atualiza o status de analise indicando se esta divergente ou nao
		DbSelectArea("CBA")
		RecLock("CBA",.F.)
		If Empty(aProdNoOK)
			CBA->CBA_ANALIS := "1"
		Else
			CBA->CBA_ANALIS := "2"
		EndIf
		CBA->(MsUnLock())

		If lMonitor .and. .NOT. Empty(aProdNoOK)
			aProdOk2 := aClone(aProdNoOk)
			aProdNoOk := {}
		Else
			If Empty(aProdNoOK) .and. .NOT. Empty(aProdEnd)
				aProdNoOK := {"atribuicao simbolica somente para nao validar a contagem"} //
			Elseif Empty(aProdNoOK) .and. Empty(aProdEnd)
				lOK:= .T.
			EndIf
		EndIf
	EndIf

Return {(Len(aProdNoOK) == 0),aProdOk2,aEtiQtdOK,aEtiLidas,lOK}

/*/{Protheus.doc} AcertoInv
description
@type function
@version
@author marioantonaccio
@since 26/11/2025
@param aProdOk, array, param_description
@param aEtiQtdOk, array, param_description
@param aEtiLidas, array, param_description
@param lMonitorInv, logical, param_description
@param lAutomatico, logical, param_description
@param aprodend, array, param_description
@return variant, return_description
/*/
Static Function AcertoInv(aProdOk,aEtiQtdOk,aEtiLidas,lMonitorInv,lAutomatico,aprodend)

	Local aAreaSB7      := SB7->(GetArea())
	Local cArm
	Local cEnd
	Local cLote
	Local cNumSeri
	Local cProduto
	Local cSLote
	Local dDataInv      := dDataBase
	Local dDtValid      := CTOD("")
	Local lModelo1      := SuperGetMv("MV_CBINVMD")=="1"
	Local lUniCPO       := CBC->(ColumnPos("CBC_IDUNIT")) > 0
	Local lWmsNew       := SuperGetMv("MV_WMSNEW",.F.,.F.)
	Local nPos
	Local nTamCod       := TamSX3( 'B1_COD' )[1]
	Local nTamEnd       := TamSX3("BF_LOCALIZ")[1]
	Local nTamLoc       := TamSX3( 'B1_LOCPAD' )[1]
	Local nTamLote      := TamSX3("B8_LOTECTL")[1]
	Local nTamSeri      := TamSX3( 'BF_NUMSERI' )[1]
	Local nTamSLote     := TamSX3("B8_NUMLOTE")[1]
	Local nTamUnit      := TamSX3("D14_IDUNIT")[1]
	Local nX
	Private lMsHelpAuto := .T.
	Private nModulo     := 4

	DEFAULT aProdEnd    := {}
	DEFAULT lAutomatico := .F.
	DEFAULT lMonitorInv := .F.

	RecLock("CBA",.F.)
	CBA->CBA_STATUS := "4"  // 4-finalizado
	CBA->(MsUnlock())

	If Empty(aProdOK) .and. Empty(aProdEnd)

		// desbloquer o inventario
		CBLoadEst(aProdEnd,.F.)
		For nX := 1 to Len(aProdEnd)
			cProduto := Subs(aProdEnd[nX,1],01,nTamCod)
			CBUnBlqInv(CBA->CBA_CODINV,cProduto)
		Next

		RecLock("CBA",.F.)
		CBA->CBA_STATUS := "5"  // 5-Processado sem registro no SB7
		CBA->(MsUnlock())

		Return (.T.)

	EndIf

	//³ Caso a geracao do SB7 seja feita pelo windows  data a            ³
	//³ ser considerada a data do mestre de inventario                   ³
	If .NOT. IsTelnet()
		dDataInv := CBA->CBA_DATA // Pega a data do mestre de inventario quando executador fora do coletor
	EndIf

	For nX := 1 to Len(aProdOK)

		cProduto := Subs(aProdOk[nX,1],01                   ,nTamCod)
		cArm     := Subs(aProdOk[nX,1],nTamCod+01           ,nTamLoc)
		cEnd     := Subs(aProdOk[nX,1],nTamCod+nTamLoc+01   								,nTamEnd)
		cLote    := Subs(aProdOk[nX,1],nTamCod+nTamLoc+nTamEnd+01   					,nTamLote)
		cSLote   := Subs(aProdOk[nX,1],nTamCod+nTamLoc+nTamEnd+nTamLote+01   			,nTamSLote)
		cNumSeri := Subs(aProdOk[nX,1],nTamCod+nTamLoc+nTamEnd+nTamLote+nTamSLote+01 ,nTamSeri)
		cCodUnit := Subs(aProdOk[nX,1],nTamCod+nTamLoc+nTamEnd+nTamLote+nTamSLote+nTamSeri+10+01 ,nTamUnit)

		If lUniCPO .And. lWmsNew  .And. lModelo1
			cCodUnit := aProdOk[nX,5]
		EndIf

		If Empty(cNumSeri)
			cNumSeri:=Space(nTamSeri)
		EndIf

		If lUniCPO .And. lWmsNew
			nPos := ASCAN(aProdEnd,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6]+x[9]==cProduto+cLote+cSLote+cArm+cEnd+cNumSeri+cCodUnit})
		Else
			nPos := ASCAN(aProdEnd,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6]==cProduto+cLote+cSLote+cArm+cEnd+cNumSeri})
		EndIf

		If nPos > 0
			dDtValid := aProdEnd[npos,8]
		EndIf

		If IsTelNet()
			VTAlert("Incluindo Inventario",'Aviso',MB_ICONHAND)
		EndIf

		If .NOT. AcdvGSB7(cProduto,cArm,cEnd,CBA->CBA_CODINV,dDataInv,aProdOk[nX,2],cLote,cSLote,cNumSeri,dDtValid,;
				Iif((lUniCPO .And. lWmsNew .And. WmsArmUnit(cArm)),cCodUnit,Nil),;
				Iif((lUniCPO .And. lWmsNew .And. WmsArmUnit(cArm)),aProdOk[nX,5],Nil))

			If lAutomatico
				AADD(aLogMestre, {CBA->CBA_CODINV, 2, "Erro na rotina automatica:", .F.})
				AADD(aLogMestre, {CBA->CBA_CODINV, 2, "==== == ====== ==========" , .F.})
				AADD(aLogMestre, {CBA->CBA_CODINV, 3, "Produto: "+cProduto        , .F.})
				AADD(aLogMestre, {CBA->CBA_CODINV, 3, "Armazem: "+cArm            , .F.})
				AADD(aLogMestre, {CBA->CBA_CODINV, 3, "Endereco:"+cEnd            , .F.})
				AADD(aLogMestre, {CBA->CBA_CODINV, 3, "Lote: "+cLote              , .F.})
				AADD(aLogMestre, {CBA->CBA_CODINV, 3, "Sub-Lote:"+cSLote          , .F.})
				AADD(aLogMestre, {CBA->CBA_CODINV, 3, "N.Serie: "+cNumSeri        , .F.})
			Else
				//VTAlert(2)
				VTAlert('Erro na rotina automatica, necessario excluir esta finalizacao pelo Mestre de Inventario','Atencao',MB_ICONEXCLAMATION) //###
			EndIf

			Return (.F.)
		Endif

		If nPos > 0
			ADEL(aProdEnd,nPos)
			ASIZE(aProdEnd,LEN(aProdEnd)-1)
		EndIf

	Next

	If IsGeraAcerto(lMonitorInv)

		If IsTelNet()
			VTAlert("Acerto Estoque...",'Aviso',MB_ICONHAND)  //
		EndIf

		SB7->(DbOrderNickName("ACDSB701"))

		If SB7->(DbSeek(xFilial("SB7")+CBA->CBA_CODINV))
			MATA340(.T.,CBA->CBA_CODINV,.F.)
		EndIf

		RestArea(aAreaSB7)

	EndIf

	If .NOT. IsTelnet()
		IncProc()
	EndIf

Return (.T.)

/*/{Protheus.doc} IsGeraAcerto
description
@type function
@version
@author marioantonaccio
@since 26/11/2025
@param lMonitorInv, logical, param_description
@return variant, return_description
/*/
Static Function IsGeraAcerto(lMonitorInv)

	Local lRet    := .F.
	Local cInvAut := SuperGetMv("MV_INVAUT")

	If cInvAut== '3'
		lRet := .T.
	EndIf

	If cInvAut=='1' .and. .NOT. lMonitorInv
		lRet := .T.
	EndIf

	If cInvAut=='2' .and. lMonitorInv
		lRet := .T.
	EndIf

Return (lRet)

/*/{Protheus.doc} Ultimo
description
@type function
@version
@author marioantonaccio
@since 26/11/2025
@return variant, return_description
/*/
Static Function Ultimo()

	Local lIsLast:= .t.
	Local nReg := CBB->(Recno())

	RecLock('CBA',.F.)

	CBB->(DbUnLock())
	CBB->(DBSetOrder(1))
	CBB->(DBSeek(xFilial('CBB')+CBA->CBA_CODINV))

	While .NOT. CBB->(EOF()) .and. CBB->CBB_CODINV == CBA->CBA_CODINV
		If .NOT. CBB->(RLOCK())
			lIsLast := .F.
			Exit
		EndIf
		CBB->(DBSkip())
	EndDo

	CBB->(MsGoto(nReg))

	RecLock('CBB',.F.)
	CBA->(DbUnLock())

Return (lIsLast)

/*/{Protheus.doc} Unitiza
description
@type function
@version
@author marioantonaccio
@since 26/11/2025
@param _cEnd, variant, param_description
@return variant, return_description
/*/
Static Function Unitiza( _cEnd )

	Local 	_cWkCB0 	:= GetNextAlias()
	Local 	_aSize   	:= FWGetDialogSize( oMainWnd )
	Local 	_oFont		:= TFont():New("Arial",12,24,.T.,.T.,5,.T.,5,.T.,.F.)
	Local	_lAchou 	:= .F.
	Local 	_oDlgUnit

	If Select(_cWkCB0) <> 0
		(_cWkCB0)->(DbCloseArea())
	EndIf

	BeginSql alias _cWkCB0
		SELECT
			CB0_CODETI ETIQUETA,
			TRIM(CB0_LOCALI) ENDERECO,
			TRIM(CB0_CODPRO) EAN,
			CB0_QTDE QTD,
			R_E_C_N_O_ RECCB0
		FROM
			%Table:CB0% CB0 (nolock)
		WHERE
			CB0_TIPO = '02'
			AND LEFT(CB0_CODETI, 1) = 'A'
			AND CB0_LOCALI = %Exp:_cEnd%
			AND CB0.%NotDel%
	EndSql

	If .NOT. (_cWkCB0)->(EOF())

		_nReCB0 := (_cWkCB0)->RECCB0

		Define MsDialog _oDlgUnit Title OemToAnsi('TOYS') From  (_aSize[1]/2) , (_aSize[2]/2) To (_aSize[3]/2), (_aSize[4]/2)  Of oMainWnd COLOR 'W+/W' STYLE NOR(DS_SYSMODAL,WS_MAXIMIZEBOX,WS_POPUP) Pixel

		_oAreaMain 			:= FWLayer():New()
		_oAreaMain:Init(_oDlgUnit, .F.)
		_oAreaMain:AddLine('line_fold00'	, 100	, .F.)

		_oPanel0	:= _oAreaMain:GetLinePanel('line_fold00')

		_oLyr0 		:= FWLayer():New()
		_oLyr0:Init(_oPanel0,.F.)
		_oLyr0:AddCollumn('column_fold00'	, 100, .F.)
		_oLyr0:AddWindow('column_fold00'	,'WIN_CLIENTE'	, 'TOYACDV35 - Unitizador'	, 100	, .F., .F.,{|| })

		_oAreaMain	:= _oLyr0:GetWinPanel('column_fold00'	, 'WIN_CLIENTE')
		_oAreaMain:FreeChildren()

		_nWidth := (_oAreaMain:nClientWidth/2)

		TSay():New(17*1-16,000,{|| "Cod. Unitizador"}	,_oAreaMain,,_oFont,,,,.T.,CLR_BLUE,CLR_WHITE,280,100)

		@ 17*2-16,00 Get oCodUnit Var cCodUnit	SIZE _nWidth-05,15 VALID((_cWkCB0)->ETIQUETA == cCodUnit .or. Empty(cCodUnit))		;
			FONT _oFont OF _oAreaMain  Pixel

		oCodUnit:SetFocus()

		_oBtnBar 	:= FWButtonBar():new()
		_oBtnBar:Init( _oAreaMain, 030, 030, CONTROL_ALIGN_BOTTOM, .T. )
		_oBtnBar:addBtnImage( "OK.PNG" 		, "Confirmar <ENTER>"    , {|| FWMsgRun(, {|| (iif((_cWkCB0)->ETIQUETA == cCodUnit	,	;
			_lAchou := .T.,_lAchou := .F.),	;
			_oDlgUnit:End())	};
			,,"Aguarde! ..","Inv")   }, , .T., CONTROL_ALIGN_RIGHT)

		Activate MsDialog _oDlgUnit Center

		If _lAchou
			cEndereco 		:= (_cWkCB0)->ENDERECO
			cEtiqProd 		:= (_cWkCB0)->EAN
			oQuant:cText	:= (_cWkCB0)->QTD
		Else
			_lAchou := .F.
		EndIf

	EndIf

	(_cWkCB0)->(DbCloseArea())

Return (_lAchou)

/*/{Protheus.doc} AcdCopVal
descValida Campos WMS no produto
@type function Processamento
@version 1.0
@author marioantonaccio
@since 26/11/2025
@param cCod, character, Codigo Produto
@param cArmazem, character, Armazem
@param cEndereco, character, Endereco
@param cCodUnit, character, Codigo Unitização
@param cProduto, character, Codigo Produto
@param cCodTpUni, character, Cod Tipo Unitização
@return Logical, se retorna Ok
/*/
Static Function AcdCopVal(cCod, cArmazem, cEndereco,cCodUnit,cProduto,cCodTpUni)

	Local lRet			:= .F.
	Local lEnd			:= CBA->CBA_TIPINV == "2"
	Local lTipoCPO 		:= CBA->(ColumnPos("CBA_CODUNI")) > 0
	Local lWmsNew   	:= SuperGetMv("MV_WMSNEW",.F.,.F.)

	Default cArmazem  	:= " "
	Default cEndereco 	:= " "
	Default cProduto  	:= " "
	Default cCodUnit  	:= " "
	Default cCodTpUni 	:= " "

	If cCod == "END"

		If WmsEndUnit(cArmazem,cEndereco)
			lRet := .T.
		EndIf

	ElseIf cCod == "UNI"

		If .NOT. Empty(cCodUnit).And. WmsVldEti(cArmazem,cEndereco,cCodUnit,@cCodTpUni)
			lRet :=.T.

			// Verifica tipo de Inventario
			If lTipoCPO .And. lWmsNew
				cTipInv := CBA->CBA_CODUNI

				AProdUni := WmsSldUni(cCodUnit)

				If cTipInv == "1" .And. lEnd

					If Len(AProdUni) > 0
						lProcUnit:= AcdWMSProc(CBB->CBB_NUM,CBB->CBB_CODINV,AProdUni)
					EndIf

				ElseIf cTipInv == "2" .And. lEnd

					If  .NOT. VTAlert("Unitizador Violado","Aviso",MB_ICONHAND) // Unitizador Violado /Aviso
						If Len(AProdUni) > 0
							lProcUnit:= AcdWMSProc(CBB->CBB_NUM,CBB->CBB_CODINV,AProdUni)
						EndIf
					EndIf

				EndIf

			EndIf
		Else
			VTAlert("Codigo unitizador invalido","Aviso",MB_ICONHAND,3000) //"Codigo unitizador invalido"
			Return (.F.)
		EndIf

	ElseIf cCod == "VLP"

		If WmsPrdCmp(cProduto).And. WmsArmUnit(cArmazem)
			VTAlert("Este Produto faz parte de uma estrutura dessa forma não pode ser inventariado","Aviso",MB_ICONHAND,3000) //"Este Produto faz parte de uma estrutura dessa forma não pode ser inventariado"                                                                                                                                                                                                                                                                                                                                                                                                                                     "                                                                                                                                                                                                                                                                                                                                                                                                                                     "
			Return (.F.)
		Else
			lRet := .T.
		EndIf

	ElseIf cCod == "VLE"

		If WmsArmUnit(cArmazem).And. WmsPrdCmp(cProduto)
			lRet := .F.
		Else
			lRet := .T.
		EndIf

	ELseIf cCod == "CTR"

		DbSelectArea("SB5")
		DbSetOrder(1)
		If SB5->(MsSeek(xFilial("SB5")+cProduto))
			If SB5->B5_CTRWMS == "1"
				lRet := .T.
			EndIf
		EndIf

	EndIf

Return (lRet)

/*/{Protheus.doc} VldEtiPro
Valida Etiqueta de produto (fase 1)
@type function Processamento
@version 1.0
@author marioantonaccio
@since 26/11/2025
@return Logical, se validacao OK ou não
/*/
Static Function VldEtiPro()

	Local 	lRet	:= .T.

	If .NOT. _lValid
		Return (.T.)
	End

	lRet	:= xVldEtiPro()

	If lRet
		cEtiqueta	:= ""
		//cCodInv                := Space(09)
		oCodInv:cCaption       := " "
		oCodInv:lReadOnly      := .T.
		oCodInv:lCanGotFocus   := .F.
		oCodInv:Refresh()

		//	cEndereco              := Space(10)
		oEndereco:cCaption     := " "
		oEndereco:lReadOnly    := .T.
		oEndereco:lCanGotFocus := .F.
		oEndereco:SetFocus()
		oEndereco:Refresh()

		cEtiqProd             := Space(015)
		oEtiqProd:cCaption     := ''
		oEtiqProd:lReadOnly    := .F.
		oEtiqProd:lCanGotFocus := .T.
		oEtiqProd:Refresh()

		nQtdEtiq               := 0
		oQuant:cCaption        := ''
		oQuant:lReadOnly       := .F.
		oQuant:lCanGotFocus    := .T.
		oQuant:Refresh()
	EndIf

Return (lRet)

/*/{Protheus.doc} xVldEtiPro
Valida etiqueta de produto fase 2 e cria registros
@type function Porcessamento
@version Processamento
@author marioantonaccio
@since 26/11/2025
@return logical, Se retorna F é porque houve incosistenca
/*/
Static Function xVldEtiPro( )

	Local aEtiqueta
	Local aItensPallet := CBItPallet(cEtiqProd)
	Local aLidos       := {}
	Local cArm2
	Local cEnd2
	Local cNumSeri
	Local cPrdOri      := ""
	Local cProduto     := ''
	Local lAltend      := GetMV("MV_ALTENDI") == "0"
	Local lB5CtrWms    := .F.
	Local lCBINV01     := ExistBlock( 'CBINV01' )
	Local lCBINV04     := ExistBlock( 'CBINV04' )
	Local lCBINVVAl    := ExistBlock("CBINVVAL")
	Local lCTRWMS      := ""
	Local lIsPallet    := .t.
	Local lIteUnit     := .F.
	Local lRet         := .T.
	Local lUniCPO      := CBC->(ColumnPos("CBC_IDUNIT")) > 0
	Local lV035ALTQTD  := ExistBlock("V035ALTQTD")
	Local lWmsNew      := SuperGetMv("MV_WMSNEW",.F.,.F.)
	Local nP
	Local nQE
	Local nQtdAux      := 0
	Local nQtdEtiq2
	Local nQuant
	Local nX
	Local oProdComp    := IIf(lWmsNew,WMSDTCProdutoComponente():New(), Nil)

	Private cLote      := Space(TamSX3("B8_LOTECTL")[1])
	Private cSLote     := Space(TamSX3("B8_NUMLOTE")[1])

	If .NOT. _lValid
		Return (.T.)
	End

	If .NOT. VldCodInv(cCodInv)
		Return(.F.)
	End

	If Empty(  nQtdEtiq )
		VTAlert('Quantidade deve ser maior que 0',"Erro",MB_ICONHAND,4000)
		oQuant:SetFocus()
		Return (.F.)
	End

	If Empty( AllTrim( cEtiqProd ) ) //.or.  Len(AllTrim(cEtiqProd)) <> 13
		VTAlert('Refaça a leitura do código',"Erro",MB_ICONHAND,4000)
		oEtiqProd:SetFocus()
		Return (.T.)
	Else
		CBC->(DBSetOrder(2))
		If CBC->(DBSeek(xFilial('CBC')+CBB->CBB_NUM + AllTrim(cEtiqProd)))
			VTAlert('Codigo ja lido',"Aviso",MB_ICONHAND,4000)
			Return (.F.)
		EndIf
	EndIf

	If lUsaCB001

		aEtiqueta := CBRetEti(cEtiqProd,"01",.T.,.T.)

		If Len(aEtiqueta)> 0
			cProduto  := aEtiqueta[01]
			If .NOT. ExistCpo("SB1",cProduto)
				Return (.F.)
			EndIf
		EndIF

	Else

		cEndereco := Alltrim( cEndereco )
		aEtiqueta := CBRetEtiEan(cEtiqProd)

		If Len(aEtiqueta)> 0
			cProduto  := aEtiqueta[01]
			If .NOT. ExistCpo("SB1",cProduto)
				Return (.F.)
			EndIf
		EndIF

	EndIf

	// Validacao produto WMS
	If lWmsNew
		DbSelectArea("SB5")
		DbSetOrder(1)
		If SB5->(MsSeek(xFilial("SB5")+cProduto))
			If SB5->B5_CTRWMS == "1"
				lB5CtrWms := .T.
				If .NOT. Empty(cCodUnit)
					lIteUnit := .T.
				EndIf
			EndIf
		EndIf
	EndIf

	If Len(aItensPallet) == 0
		aItensPallet:={cEtiqProd}
		lIsPallet := .F.
	EndIf

	Begin Sequence
		For nP := 1 to Len(aItensPallet)

			//cEtiqProd:=Padr(aItensPallet[nP],48)

			If lCBINV01
				cEtiqProd := ExecBlock("CBINV01",,,{cArmazem,cEndereco,cEtiqProd})
				If ValType(cEtiqProd)#"C"
					cEtiqProd:=Padr(aItensPallet[nP],48)
				EndIf
			EndIf

			If lUsaCB001
				aEtiqueta := CBRetEti(cEtiqProd,"01",.T.,.T.)
				If Len(aEtiqueta) == 0 .Or. CB0->CB0_STATUS $"12"
					VTAlert('Etiqueta invalida',"Aviso",MB_ICONHAND,4000)
					BREAK
				EndIf

				If aEtiqueta[10] <> cArmazem
					VTAlert("Armazem da etiqueta difere do Mestre de Inventario!",'Atencao',MB_ICONHAND,4000)
					Return (.F.)
				EndIf

				If A166VldCB9(aEtiqueta[1], CB0->CB0_CODETI)
					VTAlert("Etiqueta Invalida","Aviso",MB_ICONHAND,3000)
					BREAK
				EndIf

				If .NOT. lIsPallet .and. .NOT. Empty(CB0->CB0_PALLET)
					VTAlert('Etiqueta invalida'+", produto pertence a um pallet ","Aviso",MB_ICONHAND,4000)
					BREAK
				EndIf

				cProduto := aEtiqueta[01]
				nQtdEtiq2:= aEtiqueta[02]
				cLote    := aEtiqueta[16]
				cSLote   := aEtiqueta[17]
				cArm2    := aEtiqueta[10]
				cEnd2    := aEtiqueta[09]
				cNumSeri := CB0->CB0_NUMSER

				SB1->(DbSetOrder(1))
				If .NOT. SB1->(MsSeek(xFilial("SB1")+Padr(Alltrim(cProduto),15)))
					VTAlert('Produto nao cadastrado.','Atencao',MB_ICONHAND,4000) //'Produto nao cadastrado.'###'Atencao'
					BREAK
				EndIf

				//Para evitar problemas na execucao da rotina automatica que gera SB7
				//Sera incluida aqui a validacao do valido do B7_LOCAL (by Erike)
				SB2->(DbSetOrder(1))
				If  .NOT. SB2->(MsSeek(xFilial("SB2")+Padr(Alltrim(cProduto),15)+cArm2))
					CriaSB2(cProduto,cArm2)
				EndIf

				//³Analisando Classificacao por curva ABC, somente inv. por prod.³
				If CBA->CBA_TIPINV == "1" .and. .NOT. Empty(cClasses) .and. .NOT. CBClABC(cProduto,cClasses)
					VTAlert('Produto nao pertence a(s) classe(s) "'+cClasses+'" da curva ABC!','Atencao',MB_ICONHAND,4000)
					BREAK
				EndIf

				If Empty(aEtiqueta[2])
					nQtdEtiq2:= 1
				EndIf

				nQE:= 1

				If .NOT. CBProdUnit(aEtiqueta[1])

					nQE := CBQtdEmb(aEtiqueta[1])

					If Empty(nQE)
						BREAK
					EndIf

					CBC->(DBSetOrder(1))
					If CBC->(DBSeek(xFilial('CBC')+CBB->CBB_NUM+CB0->CB0_CODETI))
						VTAlert('Codigo ja lido',"Aviso",MB_ICONHAND,4000) //'Codigo ja lido'###'Aviso'
						BREAK
					EndIf

					If Localiza(aEtiqueta[1])
						If lAltend
							IF .NOT. Empty(cEnd2) .and. .NOT. cArm2+cEnd2 == cArmazem+cEndereco
								VTAlert('Produto pertence ao endereco:'+cArm2+'-'+cEnd2,"Aviso",MB_ICONHAND,4000) //'Produto pertence ao endereco:'###'Aviso'
								BREAK
							EndIf
						EndIf
					EndIf

				Else

					If CBQtdVar(aEtiqueta[1]) .and. .NOT. lIsPallet
						nQtdEtiq2:= nQE
						nQE:= 1
					EndIf

					CBC->(DBSetOrder(1))
					If CBC->(DBSeek(xFilial('CBC')+CBB->CBB_NUM+CB0->CB0_CODETI))
						VTAlert('Codigo ja lido',"Aviso",MB_ICONHAND,4000) //'Codigo ja lido'###'Aviso'
						BREAK
					EndIf

					If Localiza(aEtiqueta[1])
						IF .NOT. cArm2+cEnd2 == cArmazem+cEndereco
							If lAltend
								VTAlert('Produto pertence ao endereco:'+cArm2+'-'+cEnd2,"Aviso",MB_ICONHAND,4000) //'Produto pertence ao endereco:'###'Aviso'
								BREAK
							EndIf
						EndIF
					EndIf
				EndIF

				If lV035ALTQTD
					nQtdAux := ExecBlock("V035ALTQTD",.F.,.F.,{nQtdEtiq})
					If ValType(nQtdAux) = "N"
						nQtdEtiq := nQtdAux
						VTGetRefresh('nQtdEtiq')
					EndIf
				EndIf

				nQuant := nQE*nQtdEtiq*nQtdEtiq2

			Else

				If .NOT. CBLoad128(@cEtiqProd)
					VTAlert('Leitura invalida',"Aviso",MB_ICONHAND,4000,3)
					Return (.F.)
				Endif

				If Len(Alltrim(cEtiqProd)) == 13
					aEtiqueta := CBRetEtiEan(cEtiqProd)
					If Len(aEtiqueta) == 0
						VTAlert('Etiqueta invalida!!',"Aviso",MB_ICONHAND,4000,3)
						Return (.F.)
					EndIf
				Else
					aEtiqueta := { cEtiqProd ,1,'','',''}
				EndIf

				cProduto  := Alltrim(aEtiqueta[01])
				nQtdEtiq2 := aEtiqueta[02]
				cLote     := aEtiqueta[03]
				cNumSeri  := aEtiqueta[05]
				nQE       := 1
				lCtrWms := IntDl(cProduto)

				If lV035ALTQTD
					nQtdAux := ExecBlock("V035ALTQTD",.F.,.F.,{nQtdEtiq})
					If ValType(nQtdAux) = "N"
						nQtdEtiq := nQtdAux
					EndIf
				EndIf

				nQuant := nQE*nQtdEtiq*nQtdEtiq2

				If .NOT. Empty(cNumseri)
					SBF->(DbSetorder(4))
					If .NOT. SBF->(DbSeek(xFilial("SBF")+cProduto+cNumseri)).And. lAltend
						VTAlert("N.serie: "+cNumseri+"Invalido","Aviso",MB_ICONHAND,3000) // N.serie: inválido #Aviso#
						If .NOT. VTAlert("N.serie: "+cNumseri,"Aviso",MB_ICONHAND)
							Return (.F.)
						EndIF
					EndIf
				EndIf

			EndIf

			SB2->(DbSetOrder(1))
			If .NOT. SB2->(DbSeek(xFilial("SB2")+Padr(Alltrim(cProduto),15)+cArmazem))
				CriaSB2(cProduto,cArmazem)
				If lWmsNew .And. IntDL(cProduto)
					oProdComp:SetPrdCmp(cProduto)
					If oProdComp:LoadData(2)
						cPrdOri := oProdComp:GetPrdOri()
					EndIf
					If .NOT. Empty(cPrdOri) .And. .NOT. SB2->(DbSeek(xFilial("SB2")+cPrdOri+cArmazem))
						CriaSB2(cPrdOri,cArmazem)
					EndIf
				EndIf
			EndIf

			If CBA->CBA_TIPINV == "1"  // 1=Por Produto

				If lIteUnit
					VTAlert("Produto unitizado deve ser utilizado no inventario por endereco","Aviso",MB_ICONHAND,4000)//
					Return (.F.)
				EndIf

				//³Analisando Classificacao por curva ABC, somente inv. por prod.³
				If .NOT. Empty(cClasses) .and. .NOT. CBClABC(cProduto,cClasses)
					VTAlert('Produto nao pertence a(s) classe(s) "'+cClasses+'" da curva ABC!','Atencao',MB_ICONHAND,4000)
					Return (.F.)
				EndIf

				If .NOT. CBA->CBA_PROD == cProduto .and. .NOT. Empty(CBA->CBA_PROD)
					VTAlert('Produto diferente do que deve ser inventariado.','Atencao',MB_ICONHAND,4000)
					Return (.F.)
				EndIf
			EndIf

			If lIteUnit
				If .NOT. AcdCopVal('VLP',cArmazem,,,cProduto)
					Return (.F.)
				EndIf
			EndIf

			If lCBINV04
				ExecBlock("CBINV04",.F.,.F.)
			Endif

			If Rastro(cProduto)

				If .NOT. CBRastro(cProduto,@cLote,@cSLote)
					Return (.F.)
				EndIf

				If .NOT. V35VldLot(cProduto,cArmazem,cLote,cSLote,cPrdOri)
					Return (.F.)
				EndIf

			EndIf

			If lCBINVVAL
				lRet := ExecBlock("CBINVVAL",.F.,.F.)
				If ValType(lRet)== "L"
					If .NOT. lRet
						Return (.F.)
					EndIf
				EndIf
			EndIf

			If lUsaCB001
				CBC->(DBSetOrder(1))
				If CBC->(DBSeek(xFilial('CBC')+CBB->CBB_NUM+CB0->CB0_CODETI))
					RecLock("CBC",.F.)
				Else
					RecLock("CBC",.T.)
					CBC->CBC_FILIAL := xFilial("CBC")
					CBC->CBC_CODINV := CBB->CBB_CODINV
					CBC->CBC_NUM    := CBB->CBB_NUM
					CBC->CBC_LOCAL  := cArmazem
					CBC->CBC_LOCALI := cEndereco
					CBC->CBC_COD    := cProduto
					CBC->CBC_CODETI := CB0->CB0_CODETI
					CBC->CBC_LOTECT := cLote
					CBC->CBC_NUMLOT := cSLote
					CBC->CBC_NUMSER := cNumSeri
					AADD(aLidos,CB0->CB0_CODETI)
				EndIf
				CBC->CBC_QUANT  += nQuant
				CBC->CBC_QTDORI += nQuant
				CBC->(MsUnlock())
			Else
				CBC->(DBSetorder(2))
				If .NOT. lUniCPO .Or. .NOT. lWmsNew
					If .NOT. CBC->(DbSeek(xFilial('CBC')+CBB->CBB_NUM+cProduto+Alltrim(cArmazem)+Alltrim(cEndereco)+cLote+cSLote+cNumSeri))
						RecLock("CBC",.T.)
						CBC->CBC_FILIAL := xFilial("CBC")
						CBC->CBC_CODINV := CBB->CBB_CODINV
						CBC->CBC_NUM    := CBB->CBB_NUM
						CBC->CBC_LOCAL  := cArmazem
						CBC->CBC_LOCALI := cEndereco
						CBC->CBC_COD    := cProduto
						CBC->CBC_LOTECT := cLote
						CBC->CBC_NUMLOT := cSLote
						CBC->CBC_NUMSER := cNumSeri
					Else
						If .NOT. lModelo1
							If CBC->CBC_CONTOK =="1"
								VTAlert("Nao eh necessario a recontagem!!!","Produto ja auditado",MB_ICONHAND,4000)
								Return (.F.)
							EndIf
						EndIf
						RecLock("CBC",.F.)
					EndIf
				Else
					If .NOT. CBC->(DbSeek(xFilial('CBC')+CBB->CBB_NUM+cProduto+cArmazem+cEndereco+cLote+cSLote+cNumSeri+cCodUnit))
						RecLock("CBC",.T.)
						CBC->CBC_FILIAL := xFilial("CBC")
						CBC->CBC_CODINV := CBB->CBB_CODINV
						CBC->CBC_NUM    := CBB->CBB_NUM
						CBC->CBC_LOCAL  := cArmazem
						CBC->CBC_LOCALI := cEndereco
						CBC->CBC_COD    := cProduto
						CBC->CBC_LOTECT := cLote
						CBC->CBC_NUMLOT := cSLote
						CBC->CBC_NUMSER := cNumSeri
						CBC->CBC_IDUNIT := cCodUnit
						CBC->CBC_CODUNI := cCodTpUni
					Else
						If .NOT. lModelo1
							If CBC->CBC_CONTOK =="1"
								VTAlert("Nao eh necessario a recontagem!!!","Produto ja auditado",MB_ICONHAND,4000)
								Return (.F.)
							EndIf
						EndIf
						RecLock("CBC",.F.)
					EndIf
				EndIf
				CBC->CBC_QUANT  += nQuant
				CBC->CBC_QTDORI += nQuant
				CBC->(MsUnlock())
			EndIf

			If lWmsNew .And. lUniCPO
				ACD35CBM(3,CBA->CBA_CODINV,cProduto,cArmazem,cEndereco,cLote,cSLote,cNumSeri,cCodUnit,cCodTpUni)
			Else
				ACD35CBM(3,CBA->CBA_CODINV,cProduto,cArmazem,cEndereco,cLote,cSLote,cNumSeri)
			EndIf
		Next

		If lForcaQtd
			VtSay(7,0,Space(19))
			cEtiqProd	:= Space(015)
			nQtdEtiq 	:= 0
		Else
			nQtdEtiq :=0
			//VTGetRefresh('nQtdEtiq')
		EndIf

		Return (.T.)

	End Sequence

	// se passar aqui e' porque ocorreum alguma consistencia
	For nX:= 1 to Len(aLidos)
		CBC->(DBSetOrder(1))
		If CBC->(DBSeek(xFilial('CBC')+CBB->CBB_NUM+aLidos[nX]))
			RecLock("CBC",.F.)
			CBC->(DbDelete())
			CBC->(MsUnlock())
		EndIf
	Next

Return (.F.)

/*/{Protheus.doc} ExistCpo
description
@type function
@version
@author marioantonaccio
@since 26/11/2025
@param cAlias, character, param_description
@param cValor, character, param_description
@param nOrdem, numeric, param_description
@return variant, return_description
/*/
Static Function ExistCpo(cAlias,cValor,nOrdem)

	Local cAliasAtu	:= Alias()
	Local lRet 		:= .T.

	DEFAULT nOrdem	:= 01

	dbselectArea(cAlias)
	dbSetOrder(nOrdem)

	If dbSeek(xFilial(cAlias)+cValor)
		lRet := .T.
	Else
		lRet := .F.
	EndIf

	If .NOT. Empty(cAliasAtu)
		dbSelectArea(cAliasAtu)
	EndIf

Return (lRet)

/*/{Protheus.doc} CBLoad128
description
@type function
@version
@author marioantonaccio
@since 26/11/2025
@param cID, character, param_description
@return variant, return_description
/*/
Static Function CBLoad128(cID)

	Local lRet:= .f.
	Local lTem2Parte:= SuperGetmv("MV_EANP2",.F.,.F.)

	IF .NOT. Type("lVT100B") == "L"
		Private lVT100B := .F.
	EndIf

	If .NOT. lTem2Parte
		Return (.T.)
	EndIf

Return (lRet)



Static Function BRLIMPA()

	cCodInv    := Space(009)
	cEndereco  := Space(10) //Space(nTamEnd)
	cEtiqend   := '' //Space(48)
	cProduto   := '' //Space(nTamProd)
	nQtdEtiq   := 0
	cEspaco    := ""
	cEtiqProd := Space(015)

	oCodInv:cText   := cCodInv
	oEndereco:cText := cEndereco
	oEspaco:cText   := cEspaco
	oEtiqProd:cText := cEtiqProd
	oQuant:cText    := nQtdEtiq

	oCodInv:Refresh()

	oEspaco:Refresh()

	oEtiqProd:Refresh()

	oQuant:Refresh()

	oEndereco:lCanGotFocus 	:= .T.
	oEndereco:Refresh()
	oEndereco:SetFocus()

	_oDlgMain:Refresh()

Return
