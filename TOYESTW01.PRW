//©´Definicao dos includesÃ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  
	#INCLUDE 'PROTHEUS.CH'
	//#INCLUDE 'ERPI_CLASS.CH'
	#INCLUDE "MSMGADD.CH"
	#INCLUDE "TBICONN.CH"

	#define MB_OK                       0
	#define MB_OKCANCEL                 1
	#define MB_YESNO                    4
	#define MB_ICONHAND                 16
	#define MB_ICONQUESTION             32
	#define MB_ICONEXCLAMATION          48
	#define MB_ICONASTERISK             64
	
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Definicao dos includesÃ 

// 00743083370119 

User Function BR_UESTW01B( _aMenu , _cUser )





	Local 	_aSize   	:= FWGetDialogSize( oMainWnd )
	Local 	_oDlgMain	:= Nil
	Local 	_oFont		:= Nil
	Local 	_nMenu		:= 0
	Local 	_cOpcao		:= Space(20)
	Local 	_nWidth    	:= 0

	Define MsDialog _oDlgMain Title OemToAnsi('TOYS') From  _aSize[1],_aSize[2] To _aSize[3],_aSize[4]  Of oMainWnd COLOR 'W+/W' STYLE NOR(DS_SYSMODAL,WS_MAXIMIZEBOX,WS_POPUP) Pixel

		_oAreaMain 			:= FWLayer():New()
		_oAreaMain:Init(_oDlgMain, .F.)	 

		_oAreaMain:AddLine('line_fold00'	, 100	, .F.)

		_oPanel0	:= _oAreaMain:GetLinePanel('line_fold00')

		_oLyr0 		:= FWLayer():New()	
		
		_oLyr0:Init(_oPanel0,.F.)
		_oLyr0:AddCollumn('column_fold00'	, 100, .F.)
		_oLyr0:AddWindow('column_fold00'	,'WIN_CLIENTE'	, 'Menu - '+_cUser	, 100	, .F., .F.,{|| }) 

		_oAreaMain	:= _oLyr0:GetWinPanel('column_fold00'	, 'WIN_CLIENTE')

		_oAreaMain:FreeChildren() 
		
		_nWidth := ((_oAreaMain:nClientWidth)/2)

		_oFont 		:= TFont():New("Arial",12,36,.T.,.T.,5,.T.,5,.T.,.F.)

		_nMenu	:= 0

		For _nMenu := 1 To Len( _aMenu )

			_nLinha	:= Round(_nMenu/2,0) // Int(_nMenu/3) + 1
			_nCol	:= iif(Empty(_nMenu%2),1,0)

			TSay():New(002 + (_nLinha-1)*17,002+_nCol*80,&("{||'"+ _aMenu[_nMenu,1] + ") " +  _aMenu[_nMenu,2] +"'}"),_oAreaMain,,_oFont,,,,.T.,CLR_BLUE,CLR_WHITE,280,100)

		Next


		//_nMenu	:= 4

		TSay():New(002 + (_nLinha+1)*17,02,{|| "Opção : "}	,_oAreaMain,,_oFont,,,,.T.,,,280,100)
		TGet():New(002 + (_nLinha+1)*17,30,bSetGet(_cOpcao),_oAreaMain,_nWidth-70,13,		, {|| ChoiceMenu(_aMenu, _cOpcao , _cUser) } ,,,_oFont,,,.T.,,,,,,,,,,,,,,.T.,.F.,,,1 ) 
		
		_oTButton 	:= TButton():Create( _oAreaMain,002 + (_nLinha+1)*17, _nWidth-40,">>",{|| .T. }, 40,13,,,,.T.,,,,,,)

		_oBtnBar 	:= FWButtonBar():new()

		_oBtnBar:Init( _oAreaMain, 030, 030, CONTROL_ALIGN_BOTTOM, .T. )

		_oBtnBar:addBtnImage( "FINAL.PNG"			, "Sair <ESC>"			, {|| _lValid := .F., _oDlgMain:End() 	}, , .T., CONTROL_ALIGN_LEFT)

	Activate MsDialog _oDlgMain Center

Return Nil

Static Function ChoiceMenu(_aMenu, _cOpcao , _cUser )

	Local 	_lReturn	:= .T.
	Local 	_cSelByte	:= ""
	Local	_nI			:= 0
	Local	_nPos		:= 9999
	Local 	_aMNU		:= aClone( _aMenu )
	Local 	_cMenu		:= ""
	Local 	_bExec		:= ""


	_cOpcao	:= AllTrim(_cOpcao)

	While (++_nI) <= Len( _cOpcao ) .And. !Empty( _nPos )

		_cSelByte	:= Substr(_cOpcao, _nI, 1)
		_nPos		:= aScan(_aMNU, {|e| e[1] == _cSelByte})

		If !Empty( _nPos )	

			_cMenu	+= iif(Empty(_cMenu), "", "->") + _aMNU[_nPos, 1]+") "+_aMNU[_nPos, 2]
			_bExec	:= _aMNU[_nPos, 3]
			_aMNU	:= aClone( _aMNU[_nPos, 4] )

		EndIf	
		
	EndDo

	If Empty( _nPos )

		MessageBox(_cMenu + ":" + _cSelByte, "Opção Inválida!", MB_ICONHAND)

	Else

		If Empty( _aMNU )

			_bExec	:= "{||" + _bExec + "}"
			_bExec	:= &_bExec

			eVal( _bExec ) 

		Else

			U_UESTW01B( _aMNU , _cUser )

		EndIf

	EndIf
	
Return _lReturn

User Function UESTW01A()

	Local 	_aSize   	 //:= FWGetDialogSize()
	Local 	_oDlgMain	:= Nil
	Local 	_oFont		:= Nil
	Local 	_cUser		:= ''
	Local 	_cCracha	:= ''
	Local 	_cIdeUsr	:= ''
	Local 	_lValid		:= .F.
	Local	_aMenu		:= {}
	Local 	_oMonitor	:= " " //U_TENVJ01B()
	Local 	_oFontMemo  := TFont():New("Arial",12,24,.T.,.T.,5,.T.,5,.T.,.F.)
	Local	_nA			:= 1
	Local 	_aRotinas	:= { 	{"1", 	"Apontam. Prod"		, "U_ACDV020(1)", {} }	;
							, 	{"2", 	"Inventário"		, "U_ACDV035(2)", {} }	;
							,	{"3", 	"Endereçamento"		, "U_ACDV265(1)", {} }	;
							, 	{"4", 	"Transferência"		, "U_ACDV261(1)", {} }	;
							, 	{"5",	"Separação"			, "u_ACDV165(1)", {} }	;
							, 	{"6",	"Expedição"			, "U_ACDV250(1)", {} }	;
							, 	{"7", 	"Unitizar"			, "U_ACDV241(1)", {} }	;
							, 	{"9", 	"Vincular Crachá"	, "U_ACDV000(1)", {} }	}

	Public oMainWnd		:= Nil
		
	Public cEmpFil		:= '01'
	Public cEmpAnt		:= '01'
	Public cFilAnt		:= '000000000'
	Public oMainWnd		:= Nil
	 	_aSize   	:=  FWGetDialogSize(oMainWnd	)
	
	_aSize[1]:=000
	_aSize[2]:=000
	_aSize[3]:=250
	_aSize[4]:=350

	u_zlogin()
/*
	Define MsDialog _oDlgMain Title OemToAnsi('BRASILUX') From  _aSize[1],_aSize[2] To _aSize[3],_aSize[4]  Of oMainWnd COLOR 'W+/W' STYLE NOR(DS_SYSMODAL,WS_MAXIMIZEBOX,WS_POPUP) Pixel

		_oAreaMain 			:= FWLayer():New()
		_oAreaMain:Init(_oDlgMain, .F.)	 

		_oAreaMain:AddLine('line_fold00'	, 100	, .F.)

		_oPanel0	:= _oAreaMain:GetLinePanel('line_fold00')

		_oLyr0 		:= FWLayer():New()	
		
		_oLyr0:Init(_oPanel0,.F.)
		_oLyr0:AddCollumn('column_fold00'	, 100, .F.)
		_oLyr0:AddWindow('column_fold00'	,'WIN_CLIENTE'	, 'TOYSESTW01 - Login' + U_UESTW01V()	, 100	, .F., .F.,{|| }) 

		_oAreaMain	:= _oLyr0:GetWinPanel('column_fold00'	, 'WIN_CLIENTE')

		_oAreaMain:FreeChildren() 
		
		_nWidth := (_oAreaMain:nClientWidth/2)
		
		_oFont 		:= TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)

		TBitmap():New(002,001,60,49,,"\toys\logo\toys_60x50px.png",.T.,_oAreaMain, {||},,.F.,.F.,,,.F.,,.T.,,.F.)

		//TSay():New(012,050,{|| "Crachá"}	,_oAreaMain,,_oFont,,,,.T.,CLR_BLUE,CLR_WHITE,280,100)
		TSay():New(012,040,{|| "Crachá"}	,_oAreaMain,,_oFont,,,,.T.,,,280,100)

		@ 010,075 Get _oCracha Var _cCracha	MEMO						;
					SIZE _nWidth-80,15 								;
					ON CHANGE iif(_lValid := XValid( _cCracha , @_cUser),	; 
										_oDlgMain:End(), Nil) 			;
					FONT _oFontMemo OF _oAreaMain  Pixel
					
		TGet():New(001,300,bSetGet(_cIdeUsr)	,_oAreaMain,(_oAreaMain:nClientWidth)/2-105,13,		, {|| .T. } ,,,_oFont,,,.T.,,,,,,,,,,,,,,.T.,.F.,,,1 ) 
		
		_oBtnBar 	:= FWButtonBar():new()

		_oBtnBar:Init( _oAreaMain, 030, 030, CONTROL_ALIGN_BOTTOM, .T. )

		_oBtnBar:addBtnImage( "FINAL.PNG"			, "Sair <ESC>"			, {|| _lValid := .F., _oDlgMain:End() 	}, , .T., CONTROL_ALIGN_LEFT)
		_oBtnBar:addBtnImage( "CHAVE2_OCEAN.PNG"	, "Validar"				, {|| iif(_lValid := XValid(_cCracha, @_cUser), _oDlgMain:End(), Nil) 	}, , .T., CONTROL_ALIGN_RIGHT)

	Activate MsDialog _oDlgMain //Center

	If _lValid

		_oValid				:= ACESSOS_COLETOR():New()
		_oValid:cCodFun 	:= RetCodUsr()
		_oMonitor:cCodUsr	:= _oValid:cCodFun
		_oMonitor:lChkExe 	:= .T.
		_oMonitor:lCodUsr 	:= .T.

		U_TENVJ01C()
		
		_aAccess 			:= _oValid:Tarefas_Coletor()		

		If Empty( _aAccess )
			
			For _nA := 1 to Len ( _aRotinas )

				Aadd( _aMenu	, _aRotinas[_nA])

			Next _nA
		
		Else

			For _nA := 1 to len( _aAccess )
				
				_nPos := aScan( _aRotinas , {|x| AllTrim(x[1]) == _aAccess[_nA] })

				If _nPos > 0
					Aadd( _aMenu	, _aRotinas[_nPos] )
				EndIf

			Next _nA

		EndIf

		U_UESTW01B( _aMenu , _cUser )

	EndIf
*/
Return Nil	

Static Function XValid( _cCracha, _cUser )   
       
	Local _lValid		:= .F.	
	Local _cWkCB1 		:= GetNextAlias()
	
	If Empty(Alltrim(_cCracha))	
		Return .F.
	EndIf
	
	BeginSql alias _cWkCB1
    SELECT
        CB1_FILIAL,
        CB1_CODUSR,
        CB1_NOME,
        CB1_CODOPE,
        TRIM(A.USR_CODIGO) ZLOGIN
    FROM
        %Table:CB1% CB1 (NOLOCK)
        INNER JOIN %Table:SRA% SRA (NOLOCK) ON RA_MAT = CB1.CB1_CODOPE
        AND RA_DEMISSA = ' '
        AND ((RA_CHIDENT = %Exp:_cCracha% AND RA_CHIDENT<>' ')
		OR RA_MAT = %Exp:_cCracha%)
        AND SRA.%notDel%
        INNER JOIN SYS_USR A (NOLOCK) ON A.USR_ID = CB1_CODUSR
        AND USR_MSBLQL = '2'
        AND A.%notDel%
    WHERE
        CB1_FILIAL > ' '
        AND CB1.%notDel%
	EndSql
	
	If (_cWkCB1)->(.NOT. EOF()) 
		
		_lValid	:= .T.
		__cUserId 	:= (_cWkCB1)->CB1_CODUSR
		_cUser		:= (_cWkCB1)->CB1_NOME
		_cCodOpe	:= (_cWkCB1)->CB1_CODOPE
		cUsuario	:= "******"+Left(_cUser,15)+"SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSNSSSSSSSSSSSSSSNSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSNNNNNNNNNNSNSNNSSNSSNSSNSSSSSNSSSNNNNSSSSNNNSSSSSSSSSSSSSNNNSSNNNSNNSSSSSSSSSSNSSSNSSSSSSSSSSSSNSSSSSSNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN"
		_cFilUsr	:= (_cWkCB1)->CB1_FILIAL
		_cLogin		:= (_cWkCB1)->ZLOGIN

		_oDlgWin := MSDialog():New( 000 , 000 , 090 , 192 , 'Escolha a Empresa' ,,,.F.,,,,,,.T.,,,.T. )
						
			_oBtnRot := TButton():New(  010,010 ,"BRASILUX"		,_oDlgWin	,{|| _cFilUsr:= '010101',_oDlgWin:End()   },038,12,,,.F.,.T.,.F.,,.F.,,,.F. ) 
			_oBtnSair:= TButton():New(  010,052 ,"CD ARARA"		,_oDlgWin	,{|| _cFilUsr:= '010108',_oDlgWin:End()   },038,012,,,,.T.,,"",,,,.F. )  
			_oBtnSair:= TButton():New(  025,010 ,"CD GUARU"		,_oDlgWin	,{|| _cFilUsr:= '010106',_oDlgWin:End()   },038,012,,,,.T.,,"",,,,.F. )  
		//	_oBtnIva:= TButton():New(  025,052 ,"DISSOLTEX" 	,_oDlgWin	,{|| _cFilUsr:= '060101',_oDlgWin:End()   },038,012,,,,.T.,,"",,,,.F. )
		//	_oBtnIva:= TButton():New(  035,052 ,"TECPOLPA"  	,_oDlgWin	,{|| _cFilUsr:= '01',_oDlgWin:End()   },038,012,,,,.T.,,"",,,,.F. )
						
		
		_oDlgWin:Activate(,,,.T.)
		
		FWMsgRun(, {|| U_TENVX01D( "01", _cFilUsr,/* _cLogin */,,/* _cMod */,/* "ERPI" */,/* {} */)},,"Aguarde! Validando Usuário...","Login")			
		 
	Else 

		MessageBox("Usuário sem acesso ao coletor!" , "Acesso bloqueado" , MB_ICONHAND)

	EndIf

	(_cWkCB1)->(DbCloseArea())

Return _lValid


// http://erpi142.ddns.net:8078/?StartProg=u_UESTW01W&Comm=TCP&Env=web
// http://192.168.15.113:7023/?StartProg=u_UESTW01W&Comm=TCP&Env=web
// 00743083370119 Tiago
 
user function UESTW01W()

	//Local _bWindowInit 	:= { || __Execute( "U_UESTW01A()" , "xxxxxxxxxxxxxxxxxxxx" , "MATA010" , "SIGAFAT" , "SIGAFAT", 1 , .T. ) }
	//Local _bWindowInit 	:= { ||  U_ACDV035() }
	local _bWindowInit 	:= { ||  U_UESTW01A() }
	Local _cMod			:= "EST"
	Local _cModName 	:= "SIGAEST"
	
	Public cEmpFil		:= '01'
	Public cEmpAnt		:= '01'
	Public cFilAnt		:= '000000000'
	Public oMainWnd		:= Nil
	
	MsgRun(		"Abrindo Login!"				;
			, 	"Aguarde..."					;
			,	{|oSay| 						;
					RpcSetEnv(	"01"		;
							,	"010101"		;
							,	"TOTVSACT"			;
							,	"102030"	;
							, 	_cMod			;
							, 	"BRASILUX"			;
							, 	{}				;
							, 					;
							, 					;
							, 					;
							,  					;
							)					;
				}								;
			)

	Private 	__IMAGEGALLERY	:= Nil
	Private		__cInterNet		:= Nil
	Private 	cUsuario		:= ''
	Private 	__cUserId		:= ''
	Private 	_cCodOpe 		:= ''

	InitPublic()
	SetsDefault()
	SetModulo( @_cModName , @_cMod )

	DEFINE   WINDOW oMainWnd FROM 001,001 TO 400,500 TITLE OemToAnsi( FunName() )
	ACTIVATE WINDOW oMainWnd MAXIMIZED ON INIT ( Eval( _bWindowInit ) , oMainWnd:End() )
	
	RpcClearEnv()
	
Return( NIL )

user function UESTW01u( )
	
	Local aEmpFil
	Local _bWindowInit := { || __Execute( "U_UESTW01A()" , "xxxxxxxxxxxxxxxxxxxx" , "MATA010" , "SIGAFAT" , "SIGAFAT", 1 , .T. ) }
	Local cEmp
	Local cFil
	Local _cMod:="FAT"
	Local _cModName := "SIGAFAT"
	
	Public cEmpFil:='01'
	Public cEmpAnt:='000000000'
	Public oMainWnd
	
	aEmpFil := {cEmpFil,cEmpAnt}
	cEmp    := '01'
	cFil    := '000000000'
	MsgRun("Abrindo interface", "Aguarde...",{|oSay| RpcSetEnv( "01","000000000" ,"Admin","!@Admin2010", "FAT", "ERPI", {}, , , ,  )})
	InitPublic()
	SetsDefault()
	SetModulo( @_cModName , @_cMod )
	
	DEFINE   WINDOW oMainWnd FROM 001,001 TO 400,500 TITLE OemToAnsi( FunName() )
	ACTIVATE WINDOW oMainWnd MAXIMIZED ON INIT ( Eval( _bWindowInit ) , oMainWnd:End() )
	
	RESET ENVIRONMENT
	
Return( NIL )

user function UESTW01X()
	Local _bWindowInit := { || __Execute( "U_UESTW01A()" , "xxxxxxxxxxxxxxxxxxxx" , "MATA010" , "SIGAFAT" , "SIGAFAT", 1 , .T. ) }
	
	DEFINE   WINDOW oMainWnd FROM 001,001 TO 400,500 TITLE OemToAnsi( FunName() )
	ACTIVATE WINDOW oMainWnd MAXIMIZED ON INIT ( Eval( _bWindowInit ) , oMainWnd:End() )
		
Return( NIL )

/* Static Function Click( _oTree )

	Local _cPrompt	:= _oTree:GetPrompt(.T.)

	If _cPrompt == "Contagem"

		U_ACDV035()

	EndIf

Return .T. */


User Function UESTW01V()
Return " (V1.0)"


//Bibliotecas
  
/*/{Protheus.doc} zLogin
Função para montar a tela de login simplificada
@type function
@author Atilio
@since 17/09/2015
@version 1.0
    @param cUsrLog, Caracter, Usuário para o login (ex.: "admin")
    @param cPswLog, Caracter, Senha para o login (ex.: "123")
    @return lRet, Retorno lógico se conseguiu encontrar o usuário digitado
    @example
    //Verificando se o login deu certo
    If u_zLogin(@cUsrAux, @cPswAux)
        //....
    EndIf
/*/
  
User Function zLogin(cUsrLog, cPswLog)
    Local aArea := GetArea()
    Local oGrpLog
    Local oBtnConf
    Private lRetorno := .F.
    Private oDlgPvt
    //Says e Gets
    Private oSayUsr
    Private oGetUsr, cGetUsr := Space(25)
    Private oSayPsw
    Private oGetPsw, cGetPsw := Space(20)
    Private oGetErr, cGetErr := ""
    //Dimensões da janela
    Private nJanLarg := 200
    Private nJanAltu := 200
      
    //Criando a janela
    DEFINE MSDIALOG oDlgPvt TITLE "Login" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
        //Grupo de Login
        @ 003, 001     GROUP oGrpLog TO (nJanAltu/2)-1, (nJanLarg/2)-3         PROMPT "Login: "     OF oDlgPvt COLOR 0, 16777215 PIXEL
            //Label e Get de Usuário
            @ 013, 006   SAY   oSayUsr PROMPT "Usuário:"        SIZE 030, 007 OF oDlgPvt                    PIXEL
            @ 020, 006   MSGET oGetUsr VAR    cGetUsr           SIZE (nJanLarg/2)-12, 007 OF oDlgPvt COLORS 0, 16777215 PIXEL
          
            //Label e Get da Senha
            @ 033, 006   SAY   oSayPsw PROMPT "Senha:"          SIZE 030, 007 OF oDlgPvt                    PIXEL
            @ 040, 006   MSGET oGetPsw VAR    cGetPsw           SIZE (nJanLarg/2)-12, 007 OF oDlgPvt COLORS 0, 16777215 PIXEL PASSWORD
          
            //Get de Log, pois se for Say, não da para definir a cor
            @ 060, 006   MSGET oGetErr VAR    cGetErr        SIZE (nJanLarg/2)-12, 007 OF oDlgPvt COLORS 0, 16777215 NO BORDER PIXEL
            oGetErr:lActive := .F.
            oGetErr:setCSS("QLineEdit{color:#FF0000; background-color:#FEFEFE;}")
          
            //Botões
            @ (nJanAltu/2)-18, 006 BUTTON oBtnConf PROMPT "Confirmar"             SIZE (nJanLarg/2)-12, 015 OF oDlgPvt ACTION (fVldUsr()) PIXEL
            oBtnConf:SetCss("QPushButton:pressed { background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #dadbde, stop: 1 #f6f7fa); }")
    ACTIVATE MSDIALOG oDlgPvt CENTERED
      
    //Se a rotina foi confirmada e deu certo, atualiza o usuário e a senha
    If lRetorno
        cUsrLog := Alltrim(cGetUsr)
        cPswLog := Alltrim(cGetPsw)
    EndIf
      
    RestArea(aArea)
Return lRetorno
  
/*---------------------------------------------------------------------*
 | Func:  fVldUsr                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  17/09/2015                                                   |
 | Desc:  Função para validar se o usuário existe                      |
 *---------------------------------------------------------------------*/
  
Static Function fVldUsr()
    Local cUsrAux := Alltrim(cGetUsr)
    Local cPswAux := Alltrim(cGetPsw)
    Local cCodAux := ""
      
    //Pega o código do usuário
    RPCClearEnv()
    If RpcSetEnv("01", "0101", cUsrAux, cPswAux)
        cCodAux := RetCodUsr()
        lRetorno := .T.
       
     //Senão atualiza o erro e retorna para a rotina
     Else
         cGetErr := "Usuário e/ou senha inválidos!"
         oGetErr:Refresh()
    EndIf
      
    //Se o retorno for válido, fecha a janela
    If lRetorno
        oDlgPvt:End()
    EndIf
Return
