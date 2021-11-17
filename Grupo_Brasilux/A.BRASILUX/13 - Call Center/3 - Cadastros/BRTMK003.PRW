#include 'fivewin.ch'
#include 'tbiconn.ch'
#include 'topconn.ch'    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRTMK003 บAutor ณ	Viviane Ruiz	 บ Data ณ  11/06/13   บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ CONTROLE DE CHAMADOS...                                    บฑฑ
ฑฑบ          ณ Controla os chamados, inclui, altera, exclui, e verifica   บฑฑ
ฑฑบ          ณ os andamentos de chamados...                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Brasilux Tintas                                            บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ  MOTIVO                                         บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

#define CHR_LINE				'<hr>'
#define CHR_CENTER_OPEN			'<div align="center" >'
#define CHR_CENTER_CLOSE   		'</div>'
#define CHR_FONT_DET_OPEN		'<font face="Courier New" size="2">'
#define CHR_FONT_DET_CLOSE		'</font>'
#define CHR_ENTER				'<br>'
#define CHR_NEGRITO				'<b>'
#define CHR_NOTNEGRITO			'</b>'

User Function BRTMK003()
Private	_cEmpUso  	:= AllTrim(cEmpAnt)+"/",;
		_cPerg    	:= 'BRTMK3',;
		_bFiltraBrw	:= ''
		_aIndexZ03 	:= {}
		_cFiltro  	:= ''

Private	cCadastro 	:= OemToAnsi('Controle de Chamados'),;
		cAlias	  	:= 'Z03',;
		aCores    	:= {{ "Z03->Z03_STATUS=='0'", 'ENABLE' },; // Aberto
						{ "Z03->Z03_STATUS=='8'", 'BR_PRETO'},; // Cancelado
						{ "Z03->Z03_STATUS=='9'", 'DISABLE'},; // Encerrado
						{ "Z03->Z03_STATUS=='1'", 'BR_AMARELO'} },;// Em analise
		aRotina   	:= {{ 'Pesquisar','AxPesqui',0,1},;
		               	{ 'Visualizar','U_CHAMEdit',0,2},;
        		       	{ 'Incluir','U_CHAMEdit',0,3},;
		               	{ 'Alterar','U_CHAMEdit',0,4},;
		               	{ 'Excluir','U_CHAMEdit',0,5},;
		               	{ 'Ence&rrar','U_CHAMEdit',0,6},;
		               	{ '&Cancelar','U_CHAMCan',0,7},;
		               	{ 'Im&primir','U_CHAMPRIN',0,9},;
		               	{ 'Legenda','U_CHAMLeng',0,8}}

		DbSelectArea(cAlias)
		(cAlias)->(DbSetOrder(1))
		(cAlias)->(DbGoTop())

		If	( cNivel < 5 ) // Caso nao seja Usuario Superior 
			If	! ( AllTrim(cModulo) $ "ATF|" ) // Caso o modulo nao seja Ativo Fixo
				_cFiltro := "Z03->Z03_SOLCHA == __cUserId" // Filtra, mostrando somente os chamados do usuario.
			Else
				_cFiltro := "_cEmpUso $ Z03->Z03_EMPCHA" // Filtra, mostrando os dados de todos os usuarios, mas somente da mesma empresa.
			EndIf
		Else
			AjustaSx1(_cPerg) // ajusta os parametros da rotina.
			If	! Pergunte(_cPerg,.T.) // Faz as perguntas ao usuario.
				Return .F.
			Else
				// Monta o filtro de acordo com os parametros selecionados.
				If	( mv_par01 == 1 ) // Pendentes
					_cFiltro := "(AllTrim(Z03->Z03_STATUS)='0' .or. AllTrim(Z03->Z03_STATUS)='1') "
				ElseIf	( mv_par01 == 2 ) // Em analise
					_cFiltro := "AllTrim(Z03->Z03_STATUS)='1'"
				ElseIf	( mv_par01 == 3 ) // Encerrados
					_cFiltro := "AllTrim(Z03->Z03_STATUS)='9'"
				ElseIf	( mv_par01 == 4 ) // Cancelados
					_cFiltro := "AllTrim(Z03->Z03_STATUS)='8'"
				Else
					_cFiltro := "AllTrim(Z03->Z03_STATUS)$'0/1/8/9'"
				EndIf
				If	( mv_par02 == 1 ) // Alto
					_cFiltro += " .AND. AllTrim(Z03->Z03_PRICHA)='A'"
				ElseIf	( mv_par02 == 2 ) // Normal
					_cFiltro += " .AND. AllTrim(Z03->Z03_PRICHA)='N'"
				ElseIf	( mv_par02 == 3 ) // Baixa
					_cFiltro += " .AND. AllTrim(Z03->Z03_PRICHA)='B'"
				Else
					_cFiltro += " .AND. AllTrim(Z03->Z03_PRICHA)$'A/B/N'"
				EndIf
					_cFiltro += " .AND. Z03->Z03_PROGRA >= '" + mv_par03 + "' .AND. Z03->Z03_PROGRA <= '" + mv_par04 + "' "
				If	( mv_par05 == 1 ) // Filtra por Tecnico /1=Sim,2=Nao
					_cFiltro += " .AND. ( (Z03->Z03_SOLCHA == __cUserId) .or. (Z03->Z03_TECALO == __cUserId) .or. (Z03->Z03_TECNIC == __cUserId) ) "
				EndIf
				If	( ! Empty(mv_par06) )
					_cFiltro += " .AND. ( AllTrim(Upper(mv_par06)) $ Upper(Z03->Z03_DESC) .or. AllTrim(Upper(mv_par06)) $ Upper(Z03->Z03_OCORRE) ) "
				EndIf
			EndIf
		EndIf

		If	! Empty(_cFiltro)
			_bFiltraBrw := {|| FilBrowse("Z03",@_aIndexZ03,@_cFiltro) }
			Eval(_bFiltraBrw)
		EndIf

		mBrowse(6,1,22,75,"Z03",,,,,,aCores,,,,,.T.)

		EndFilBrw("Z03",_aIndexZ03)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณxChamados บAutor ณ	Viviane Ruiz	 บ Data ณ  11/06/13   บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Chamados...                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao Principal                                           บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ  MOTIVO                                         บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function CHAMEdit( cAlias, nReg, nOpcion )
Local	oWindow,;
		oFontWin,;
		aFolders	:= {},;
		aHead		:= {},;
		bOk 		:= "{ || Iif(Iif(nOpcao<>6,!Empty(cDesCham).and.!Empty(cTipCham).and.!Empty(cPriCham),!Empty(cDesCham).and.!Empty(cTipCham).and.!Empty(cPriCham).and.!Empty(cClasFech)),(lSave:=.t.,oWindow:End()),Nil) }",;
		bCancel 	:= "{ || lSave:=.f. , oWindow:End() }",;
		aButtons	:= {},;
		_cMsgCic	:= '',;
		cTitWin, nx

Private	nRegSM0		:= SM0->(Recno())

Private	cNumCham	:= Space(8),;
		cDesCham	:= Space(80),;
		dDtAbert	:= dDataBase,;
		dHrAbert	:= Time(),;
		cSolCham	:= __cUserId,;
		cEmpCham	:= cEmpAnt+'/'+cFilAnt,;
		cTipCham	:= Space(4),;
		cPriCham 	:= Space(4),;
		cModCham	:= cModulo,;
		cProgCham	:= Space(15),;
		mAberOcor,;
		oAberOcor,;
		mSoluOcor,;
		oSoluOcor,;
		mComentar,;
		oComentar,;
		dDtFecha	:= Ctod('  /  /  '),;
		dHrFecha	:= '  :  :  ',;
		cTecCham	:= Space(6),;
		cClasFech	:= Space(4),;
		cTecAloc	:= Space(6)

Private	nOpcao 		:= nOpcion,;		// Numero da opcao selecionada..
		lSave		:= .f.,;			// Variavel controla se tem ou nao que salvar.
		lEdite		:= .f.				// Controla se edita ou nao os dados.

Private	_oTipCham,;
		_cTipCham	:= Space(20),;
		_oPriCham,;
		_cPriCham	:= Space(20),;
		_oSolCham,;
		_cSolCham	:= Space(20),;
		_oEmpCham,;
		_cEmpCham	:= Space(20),;
		_oTecAloc,;
		_cTecAloc	:= Space(20),;
		_oTecCham,;
		_cMailTec,;
		_cTecCham	:= Space(20),;
		_oClasFech,;
		_cClasFech	:= Space(20),;
		_oModulo,;
		_oModCham,;
		_oPrograma,;
		_oProgCham,;
		oRadio,;
		nRadio 		:= 1

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica se o chamado esta cancelado.!ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If	( nOpcao <> 3 ) .and. ( Z03->Z03_STATUS == '8' )
			Return
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica qual o titulo sera colocado na janela.!ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If	( nOpcao == 3 ) // Incluir
			cTitWin := 'Incluir'
		ElseIf	( nOpcao == 4 ) // Alterar
			cTitWin := 'Alterar'
		ElseIf	( nOpcao == 5 ) // Excluir
			cTitWin := 'Excluir'
		ElseIf	( nOpcao == 2 ) // Visualizar
			cTitWin := 'Visualizar'
		ElseIf	( nOpcao == 6 ) // Encerrar
			cTitWin := 'Encerrar'
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAutoriza a editar os "edites"ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If	( cNivel >= 5 ) //.or. ( AllTrim(cModulo) $ "ATF|" )
			lEdite := .t.
		EndIf
		
		
		If	( cNivel < 5 )
			If	( nOpcao == 4 ) .or. ( nOpcao == 5 ) .or. ( nOpcao == 6 )
				Help('',1,'BRTMK003',,OemToAnsi('Voc๊ nใo tem permissใo para '+cTitWin+'.'),1)
				Return
			EndIf
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica se o usuario pode alterar !ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If	( nOpcao==4 ) .and. ( ! Empty(Z03->Z03_TECNIC) )
			Help('',1,'BRTMK003',,OemToAnsi('Este chamado jแ foi encerrado.'),1)
			Return
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica se o usuario pode alterar !ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If	( nOpcao==5 ) .and. ( ! Empty(Z03->Z03_TECNIC) .or. ! Empty(Z03->Z03_TECALO) ) 
			Help('',1,'BRTMK003',,OemToAnsi('Este chamado jแ foi encerrado.'),1)
			Return
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAtualiza os dados.!ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If	( nOpcao <> 3 )
			cNumCham	:= Z03->Z03_NUMCHA
			cEmpCham	:= Z03->Z03_EMPCHA
			cSolCham	:= Z03->Z03_SOLCHA
			cPriCham	:= Z03->Z03_PRICHA
			cDesCham	:= Z03->Z03_DESC
			cTipCham	:= Z03->Z03_TIPO
			cModCham	:= Z03->Z03_MODULO
			cProgCham	:= Z03->Z03_PROGRA
			dDtAbert	:= Z03->Z03_DTABER
			dHrAbert	:= Z03->Z03_HRABER
			mAberOcor	:= Z03->Z03_OCORRE
			cTecAloc	:= Z03->Z03_TECALO
			mComentar	:= Z03->Z03_COMENT
			dDtFecha	:= Z03->Z03_DTFECH
			dHrFecha	:= Z03->Z03_HRFECH
			cTecCham	:= Z03->Z03_TECNIC
			cClasFech	:= Z03->Z03_CLASSI
			mSoluOcor	:= Z03->Z03_SOLUCA
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณQuando estiver alterando o Chamado.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If	( nOpcao == 4 ) .and. Empty(cTecAloc)
				cTecAloc := __cUserId // Atualiza o Tecnico Alocado
			EndIf
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณQuando estiver ENCERRANDOณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If	( nOpcao == 6 ) .and. Empty(cTecCham)
				dDtFecha	:= dDataBase
				dHrFecha	:= Time()
				cTecCham	:= __cUserId
			EndIf
		Else
			cNumCham	:= GetSx8Num('Z03','Z03_NUMCHA')
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณMonta a janela de interacao com o usuario. !ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DEFINE MSDIALOG oWindow FROM 38,16 TO 550,531 TITLE Alltrim(OemToAnsi('Chamados - Ocorr๊ncias ['+cTitWin+']')) Pixel //430,531 
		DEFINE FONT oFontWin NAME 'Arial' SIZE 6, 15 BOLD
		DEFINE FONT oFontMemo NAME 'Courier New' SIZE 0,15
		@ 015, 005 To 050, 255 Label OemToAnsi('Controle de Chamados') Of oWindow Pixel
		@ 023, 011 Say OemToAnsi('Chamado') Size 023, 007 Of oWindow Pixel
		@ 033, 011 MsGet cNumCham Size 017, 010 When .F. Font oFontWin Of oWindow Pixel
		@ 023, 050 Say OemToAnsi('Descri็ใo') Size 028, 007 Of oWindow Pixel
		@ 033, 050 MsGet cDesCham Size 200, 010 Picture ('@!') When nOpcao<>5.and.nOpcao<>2 Valid TEXTO() Of oWindow Pixel

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณDefine os Folders.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aAdd(aFolders,OemToAnsi('&Informa็๕es'))
		aAdd(aHead,'HEADER 1')
		aAdd(aFolders,OemToAnsi('&Abertura'))
		aAdd(aHead,'HEADER 2')
		If	( nOpcao == 2 ) .or. ( nOpcao == 4 ) .or. ( nOpcao == 5 ) .or. ( nOpcao == 6 )
			aAdd(aFolders,OemToAnsi('&Comentแrios T้cnicos'))
			aAdd(aHead,'HEADER 3')
		EndIf
		If	( nOpcao == 2 ) .or. ( nOpcao == 6 ) .or. ( nOpcao == 5 )
			aAdd(aFolders,OemToAnsi('&Encerramento'))
			aAdd(aHead,'HEADER 4')
		EndIf	
		oFolder := TFolder():New(055,005,aFolders,aHead,oWindow,,,,.T.,.F.,250,192)
		For nx:=1 to Len(aFolders)
			DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolder:aDialogs[nx]
		Next nx

		//ฺฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณInformacoesณ
		//ภฤฤฤฤฤฤฤฤฤฤฤู
		@ 005, 005 Say OemToAnsi('Tipo:') Size 025, 007 Of oFolder:aDialogs[1] Pixel
		@ 005, 040 MsGet cTipCham Size 035, 010 F3 'Z4 ' Valid xValid(1) When nOpcao<>5.and.nOpcao<>2 Of oFolder:aDialogs[1] Pixel
		@ 005, 083 Say _oTipCham Var _cTipCham Font oFontWin Of oFolder:aDialogs[1] Pixel
		@ 017, 005 Say OemToAnsi('Prioridade:') Size 025, 007 Of oFolder:aDialogs[1] Pixel
		@ 017, 040 MsGet cPriCham Size 035, 010 F3 'Z5 ' Valid xValid(2) When nOpcao<>5.and.nOpcao<>2 Of oFolder:aDialogs[1] Pixel
		@ 017, 083 Say _oPriCham Var _cPriCham Font oFontWin Of oFolder:aDialogs[1] Pixel
		@ 029, 005 Say _oModulo Var OemToAnsi('M๓dulo:') Size 025, 007 Of oFolder:aDialogs[1] Pixel
		@ 029, 040 MsGet _oModCham Var cModCham Size 035, 010 When .f. Of oFolder:aDialogs[1] Pixel
		@ 041, 005 Say _oPrograma Var OemToAnsi('Programa:') Size 025, 007 Of oFolder:aDialogs[1] Pixel
		@ 041, 040 MsGet _oProgCham Var cProgCham Size 060, 010 When nOpcao<>5.and.nOpcao<>2 Of oFolder:aDialogs[1] Pixel
		If	( Empty(dDtFecha) )
			@ 095, 005 Say OemToAnsi('Dias em atraso:') Size 040, 007 Of oFolder:aDialogs[1] Pixel
			@ 095, 055 Say TransForm(dDataBase-dDtAbert,'@R 9999') Size 060, 010 Of oFolder:aDialogs[1] Pixel
		EndIf
		_oModulo:lVisible := .f.
		_oModCham:lVisible := .f.
		_oPrograma:lVisible := .f.
		_oProgCham:lVisible := .f.

		//ฺฤฤฤฤฤฤฤฤฟ
		//ณAberturaณ
		//ภฤฤฤฤฤฤฤฤู
		@ 005, 005 Say OemToAnsi('Data/Hora:') Size 025, 007 Of oFolder:aDialogs[2] Pixel
		@ 005, 040 MsGet dDtAbert Size 035, 010 When .f. Of oFolder:aDialogs[2] Pixel
		@ 005, 080 MsGet dHrAbert Size 035, 010 When .f. Of oFolder:aDialogs[2] Pixel
		@ 017, 005 Say OemToAnsi('Solicitante:') Size 025, 007 Of oFolder:aDialogs[2] Pixel
		@ 017, 040 MsGet cSolCham Size 035, 010 F3 'USR' Valid xValid(3) When lEdite .and. nOpcao<>5.and.nOpcao<>2 Of oFolder:aDialogs[2] Pixel
		@ 017, 083 Say _oSolCham Var _cSolCham Font oFontWin Of oFolder:aDialogs[2] Pixel
		xValid(3) // Atualiza os Solicitantes
		@ 029, 005 Say OemToAnsi('Empresa:') Size 025, 007 Of oFolder:aDialogs[2] Pixel
		@ 029, 040 MsGet cEmpCham Size 035, 010 When .f. Of oFolder:aDialogs[2] Pixel
		@ 029, 083 Say _oEmpCham Var _cEmpCham Font oFontWin Of oFolder:aDialogs[2] Pixel
		xValid(4) // Atualiza a empresa/filial
		@ 041, 005 Say OemToAnsi('Ocorr๊ncia:') Size 028, 007 Of oFolder:aDialogs[2] Pixel
		@ 041, 040 Get oAberOcor Var mAberOcor Memo When nOpcao<>5.and.nOpcao<>2 Size 200, 112 Of oFolder:aDialogs[2] Pixel
		oAberOcor:oFont:=oFontMemo
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณComentariosณ
		//ภฤฤฤฤฤฤฤฤฤฤฤู
		If	( nOpcao == 2 ) .or. ( nOpcao == 4 ) .or. ( nOpcao == 5 ) .or. ( nOpcao == 6 )
			@ 005, 005 Say OemToAnsi('T้c.Alocado:') Size 030, 007 Of oFolder:aDialogs[3] Pixel
			@ 005, 040 MsGet cTecAloc Size 035, 010 F3 'USR' Valid xValid(5) When lEdite .and. nOpcao<>5.and.nOpcao<>2 Of oFolder:aDialogs[3] Pixel
			@ 005, 083 Say _oTecAloc Var _cTecAloc Font oFontWin Of oFolder:aDialogs[3] Pixel
			If	( nOpcao <> 2 ) .and. ( nOpcao <> 5 )
				xValid(5) // Atualiza o Alocado
			EndIf	
			@ 017, 005 Say OemToAnsi('Comentแrios:') Size 030, 007 Of oFolder:aDialogs[3] Pixel
			@ 017, 040 Get oComentar Var mComentar Memo When nOpcao<>5.and.nOpcao<>2 Size 200, 132 Of oFolder:aDialogs[3] Pixel
			oComentar:oFont:=oFontMemo
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณEncerramentoณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤู
		If	( nOpcao == 2 ) .or. ( nOpcao == 5 ) .or. ( nOpcao == 6 )
			@ 005, 005 Say OemToAnsi('Data/Hora:') Size 025, 007 Of oFolder:aDialogs[4] Pixel
			@ 005, 040 MsGet dDtFecha Size 035, 010 When .f. Of oFolder:aDialogs[4] Pixel
			@ 005, 080 MsGet dHrFecha Size 035, 010 When .f. Of oFolder:aDialogs[4] Pixel
			@ 017, 005 Say OemToAnsi('T้cnico:') Size 025, 007 Of oFolder:aDialogs[4] Pixel
			@ 017, 040 MsGet cTecCham Size 035, 010 F3 'USR' Valid xValid(6) When lEdite .and. nOpcao<>5.and.nOpcao<>2 Of oFolder:aDialogs[4] Pixel
			@ 017, 083 Say _oTecCham Var _cTecCham Font oFontWin Of oFolder:aDialogs[4] Pixel
			xValid(6) // Atualiza o Tecnico
			@ 029, 005 Say OemToAnsi('Classif.') Size 025, 007 Of oFolder:aDialogs[4] Pixel
			@ 029, 040 MsGet cClasFech Size 035, 010 F3 'Z6 ' Valid xValid(7) When nOpcao<>5.and.nOpcao<>2 Of oFolder:aDialogs[4] Pixel
			@ 029, 083 Say _oClasFech Var _cClasFech Font oFontWin Of oFolder:aDialogs[4] Pixel
			@ 041, 005 Say OemToAnsi('Solu็ใo:') Size 028, 007 Of oFolder:aDialogs[4] Pixel
			@ 041, 040 Get oSoluOcor Var mSoluOcor Memo When nOpcao<>5.and.nOpcao<>2 Size 200, 100 Of oFolder:aDialogs[4] Pixel
			oSoluOcor:oFont:=oFontMemo
			@ 145, 005 Say OemToAnsi('Env. Resp.:') Size 030, 007 Of oFolder:aDialogs[4] Pixel
			@ 145, 040 Radio oRadio Var nRadio When lEdite.and.nOpcao<>5.and.nOpcao<>2 Size 090,007 Of oFolder:aDialogs[4] Pixel Prompt OemToAnsi('Nใo enviar'),OemToAnsi('CIC (Comunicador Intrachat)'),OemToAnsi('E-Mail do Solicitante')
		EndIf

		If	( nOpcao <> 3 )
			xValid(1)
			xValid(2)
			If	( nOpcao == 2 ) .or. ( nOpcao == 5 ) .or. ( nOpcao == 6 )
				xValid(7)
			EndIf
		EndIf
		ACTIVATE MSDIALOG oWindow CENTERED ON INIT EnchoiceBar(oWindow,&(bOk),&(bCancel),,aButtons)

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณExecuta o processo de gravacao dos dados. !ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If	( lSave )
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSalva os dados...ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If	( nOpcao <> 2 )
				MsgRun(OemToAnsi('Gerando o Chamado.... Aguarde....'),'',{|| CursorWait(), xGravaDado() ,CursorArrow()})
			EndIf
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณEnvia as mensagens de "ENCERRAMENTO"ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If	( nOpcao == 6 ) // ENCERRAR
				If	( nRadio == 2 ) // CIC
					_cMsgCic += Chr(10)+Chr(13)
					_cMsgCic += 'O Chamado ' + cNumCham 
					_cMsgCic += Chr(10)+Chr(13)+Chr(10)+Chr(13)
					_cMsgCic += AllTrim(cDesCham)
					_cMsgCic += Chr(10)+Chr(13)
					_cMsgCic += 'Foi Encerrado...'+Chr(10)+Chr(13)
					_cMsgCic += AllTrim(Substr(mSoluOcor,1,300)) + '...'
					U_SENDCIC(AllTrim(Upper(UsrRetName(cSolCham))),OemToAnsi(_cMsgCic))
				ElseIf	( nRadio == 3 ) // E-MAIL
					WfAvisaCha(UsrRetMail(cSolCham))
				EndIf
			EndIf
		Else
			If	( nOpcao == 3 )
				RollBackSx8()
			EndIf
		EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CHAMCan  บAutor ณ	Viviane Ruiz	 บ Data ณ  11/06/13   บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para cancelar o chamado.                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao Principal                                           บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ MOTIVO                                          บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function CHAMCan()

	If	( Z03->Z03_STATUS == '0' )
		If	MsgYesNo(OemToAnsi('Deseja cancelar realmente este chamado ?'))
			If	RecLock('Z03',.F.)
				Replace Z03->Z03_STATUS	With '8'
				MsUnLock()
			Else
				Help('',1,'REGNOIS')
			EndIf
		EndIf
	Else
		Help('',1,'BRTMK003',,OemToAnsi('Este chamado nใo pode ser cancelado.'),1)
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณxGravaDado บAutorณ	Viviane Ruiz	 บ Data ณ  11/06/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida os dados digitados...                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao Principal                                           บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ  MOTIVO                                         บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function xGravaDado()

	If	RecLock('Z03',Iif(nOpcao==3,.t.,.f.))
		If	( nOpcao == 5 )
			DbDelete()
		Else
			Z03->Z03_NUMCHA   := cNumCham
			Z03->Z03_EMPCHA   := cEmpCham
			Z03->Z03_SOLCHA   := cSolCham
			Z03->Z03_PRICHA   := cPriCham
			Z03->Z03_DESC     := cDesCham
			Z03->Z03_TIPO     := cTipCham
			If	( AllTrim(cTipCham) == '001' )
				Z03->Z03_MODULO  := cModCham
				Z03->Z03_PROGRA := cProgCham
			Else
				Z03->Z03_MODULO  := Space(3)
				Z03->Z03_PROGRA := Space(15)
			EndIf
				Z03->Z03_DTABER := dDtAbert
                Z03->Z03_HRABER := dHrAbert
                Z03->Z03_OCORRE := mAberOcor
                Z03->Z03_TECALO := cTecAloc
			If	( Empty(cTecAloc) ) .and. ( ! Empty(cTecCham) )
				Z03->Z03_TECALO	:= cTecCham
			EndIf
			    Z03->Z03_COMENT := mComentar
			    Z03->Z03_DTFECH := dDtFecha
                Z03->Z03_HRFECH := dHrFecha
			    Z03->Z03_TECNIC := cTecCham
			    Z03->Z03_CLASSI := cClasFech
			    Z03->Z03_SOLUCA := mSoluOcor
			If	( ! Empty(cTecCham) ) // Encerrado
				Z03->Z03_STATUS := '9'
			ElseIf	( ! Empty(cTecAloc) ) // Em analise
				Z03->Z03_STATUS	:= '1'
			ElseIf	( Empty(cTecCham) .and. Empty(cTecAloc) )
				Z03->Z03_STATUS	:= '0'
			EndIf
		EndIf
		MsUnLock()
	Else
		Help('',1,'REGNOIS')
	EndIf
	
	If	( nOpcao == 3 )
		ConfirmSx8Num('Z03')
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ xValid() บAutor ณ	Viviane Ruiz	 บ Data ณ  11/06/13   บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida os dados digitados...                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao Principal                                           บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ  MOTIVO                                         บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function xValid( nType )
Local	lReturn	:= .f.

		Do Case
		Case	( nType == 1 ) // Tipo
			If	( ! Empty(cTipCham) )
				If	ExistCpo('SX5','Z4'+cTipCham)
					lReturn := .t.
					_cTipCham := Tabela('Z4',cTipCham)
					_oTipCham:Refresh()
				EndIf
				If	( AllTrim(cTipCham) == '001' )
					cModCham:= cModulo
					_oModulo:lVisible := .t.
					_oModCham:lVisible := .t.
					_oPrograma:lVisible := .t.
					_oProgCham:lVisible := .t.
				Else
					_oModulo:lVisible := .f.
					_oModCham:lVisible := .f.
					_oPrograma:lVisible := .f.
					_oProgCham:lVisible := .f.
				EndIf
			EndIf
		Case	( nType == 2 ) // Prioridade
			If	( ! Empty(cPriCham) )
				If	ExistCpo('SX5','Z5'+cPriCham)
					lReturn := .t.
					_cPriCham := Tabela('Z5',cPriCham)
					_oPriCham:Refresh()
				EndIf
			EndIf
		Case	( nType == 3 ) // Solicitante
			If	UsrExist(cSolCham)
				lReturn := .t.
				_cSolCham := Upper(UsrFullName(cSolCham))
				_oSolCham:Refresh()
			EndIf
		Case	( nType == 4 ) // Empresa
			nRegSM0   := SM0->(Recno())
			DbSelectArea('SM0')
			SM0->(DbGoTop())
			While 	SM0->( ! Eof() )
					If	( SubStr(cEmpCham,1,2) == AllTrim(SM0->M0_CODIGO) ) .and. ( SubStr(cEmpCham,4,2) == AllTrim(SM0->M0_CODFIL) )
						_cEmpCham := AllTrim(Upper(SM0->M0_NOME))+' ('+AllTrim(Upper(SM0->M0_FILIAL))+')'
					EndIf
				SM0->(DbSkip())	
			End
			SM0->(DbGoTo(nRegSM0))
			_oEmpCham:Refresh()
		Case	( nType == 5 ) // Tecnico Alocado
			If	( ! Empty(cTecAloc) )
				If	UsrExist(cTecAloc)
					lReturn := .t.
					_cTecAloc := Upper(UsrFullName(cTecAloc))
					_oTecAloc:Refresh()
				EndIf
			Else
				lReturn := .t.
			EndIf
		Case	( nType == 6 ) // Tecnico que solucionou
			If	( ! Empty(cTecCham) )
				If	UsrExist(cTecCham)
					lReturn := .t.
					_cMailTec := UsrRetMail(cTecCham)
					_cTecCham := Upper(UsrFullName(cTecCham))
					_oTecCham:Refresh()
				EndIf
			Else
				lReturn := .t.
			EndIf
		Case	( nType == 7 ) // Classificacao
			If	( ! Empty(cClasFech) )
				If	ExistCpo('SX5','Z6'+cClasFech)
					lReturn := .t.
					_cClasFech := Tabela('Z6',cClasFech)
					_oClasFech:Refresh()
				EndIf
			EndIf
		End Case

Return lReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CHAMLeng บAutor ณ	Viviane Ruiz	 บ Data ณ  11/06/13   บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Lengenda da rotina..                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao Principal                                           บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ  MOTIVO                                         บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function CHAMLeng()
Local	aLegenda  := {	{'ENABLE'		,'Aberto'},;
						{'BR_AMARELO'	,'Em Anแlise'},;
						{'BR_PRETO'	    ,'Cancelado'},;
						{'DISABLE'		,'Encerrado'}	}

		BrwLegenda(cCadastro,'Legenda',aLegenda)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัอออออออออออออออออออออหอออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณWfAvisaCha บAutor ณ	Viviane Ruiz	  บ Dataณ  11/06/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯอออออออออออออออออออออสอออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ ENVIO DE E-MAILs de resposta.                              บฑฑ
ฑฑบ          ณ Esta funcao envia um e-mail para o usuario que solicitou.  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao Principal                                           บฑฑ
ฑฑฬออออออออออุอออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA  ณ  MOTIVO                                        บฑฑ
ฑฑฬออออออออออุอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ           ณ                                                บฑฑ
ฑฑศออออออออออฯอออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function WfAvisaCha( cTo )
Local	_cSmtpSrv 	:= AllTrim(GetMv('MV_WFSMTPS')),;
		_cAccount 	:= AllTrim(GetMv('MV_WFCONTA')),;
		_cPassSmtp	:= AllTrim(GetMv('MV_WFSENHA')),;
		_cSmtpError	:= '',;
		_lOk		:= .f.,;
		_cTitulo 	:= OemToAnsi('[BRASILUX TINTAS] CHAMADO: '+cNumCham),;
		_cTo		:= cTo,;
		_cFrom		:= _cMailTec,;
		_cMensagem	:= '',;
		_lReturn	:= .f.
        Local _cMsgMail 
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณMonta a mensagem no corpo do e-mail..ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		_cMensagem	+= CHR_CENTER_OPEN + CHR_CENTER_CLOSE + CHR_LINE + CHR_ENTER
		_cMensagem	+= CHR_FONT_DET_OPEN
		_cMensagem	+= OemToAnsi('Chamado: ') + cNumCham + CHR_ENTER + CHR_ENTER
		_cMensagem	+= OemToAnsi('Foi Encerrado.... ') + CHR_ENTER + CHR_ENTER
		_cMensagem	+= OemToAnsi('Solu็ใo: ') + mSoluOcor + CHR_ENTER + CHR_ENTER
		_cMensagem	+= OemToAnsi('T้cnico: ') + _cTecCham + CHR_ENTER + CHR_ENTER
		_cMensagem	+= CHR_LINE + CHR_ENTER + CHR_NEGRITO
		_cMensagem	+= OemToAnsi('Brasilux Tintas') + CHR_NOTNEGRITO + CHR_ENTER
		_cMensagem	+= CHR_NEGRITO + OemToAnsi('Tecnologia da Informa็ใo') + CHR_ENTER + CHR_NOTNEGRITO
		_cMensagem	+= CHR_ENTER + CHR_LINE
		_cMensagem	+= CHR_FONT_DET_CLOSE

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณConectando com o Servidor. !!ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		CONNECT SMTP SERVER _cSmtpSrv ACCOUNT _cAccount PASSWORD _cPassSmtp RESULT _lOk
		//LGS#20200204 - Adequa็ใo de release 12.1.25 e posteriores
		//ConOut('Conectando com o Servidor SMTP')
        FwLogMSG( "ERROR", , 'SIGATMK', funname(), '', '01', 'Conectando com o Servidor SMTP', 0 )
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCaso a conexao for esbelecida com sucesso, inicia o processo de envio do e-mail..ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If	( _lOk )
			//LGS#20200204 - Adequa็ใo de release 12.1.25 e posteriores
			//ConOut('Enviando o e-mail')
			FwLogMSG( "ERROR", , 'SIGATMK', funname(), '', '01', 'Enviando o e-mail', 0 )
			SEND MAIL FROM _cFrom TO _cTo SUBJECT _cTitulo BODY _cMensagem RESULT _lOk
			//LGS#20200204 - Adequa็ใo de release 12.1.25 e posteriores
			//ConOut('De........: ' + _cFrom)
			//ConOut('Para......: ' + _cTo)
			//ConOut('Assunto...: ' + _cTitulo)
			//ConOut('Status....: Enviado com Sucesso')
			_cMsgMail := 'De........: ' + _cFrom   + CHR(13) + CHR(10)
			_cMsgMail += 'Para......: ' + _cTo     + CHR(13) + CHR(10)
			_cMsgMail += 'Assunto...: ' + _cTitulo + CHR(13) + CHR(10)
			_cMsgMail += 'Status....: Enviado com Sucesso' + CHR(13) + CHR(10)
			FwLogMSG( "ERROR", , 'SIGATMK', funname(), '', '01', _cMsgMail, 0 )
			If	( ! _lOk )
				GET MAIL ERROR _cSmtpError
				//LGS#20200204 - Adequa็ใo de release 12.1.25 e posteriores
				//ConOut(_cSmtpError)
				FwLogMSG( "ERROR", , 'SIGATMK', funname(), '', '01', _cSmtpError, 0 )
				_lReturn := .f.
			EndIf
			DISCONNECT SMTP SERVER
			//LGS#20200204 - Adequa็ใo de release 12.1.25 e posteriores
			//ConOut('Desconectando do Servidor')
			FwLogMSG( "ERROR", , 'SIGATMK', funname(), '', '01', 'Desconectando do Servidor', 0 )
			_lReturn := .t.
		Else
			GET MAIL ERROR _cSmtpError
			//LGS#20200204 - Adequa็ใo de release 12.1.25 e posteriores
			//ConOut(_cSmtpError)
			FwLogMSG( "ERROR", , 'SIGATMK', funname(), '', '01', _cSmtpError, 0 )
			_lReturn := .f.
		EndIf

Return _lReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณxPrintChamบAutor ณ	Viviane Ruiz	 บ Data ณ  11/06/13   บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para imprimir o chamado.                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao Principal                                           บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ  MOTIVO                                         บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function CHAMPRIN()
Local i
Private	cStartPath	:= GetSrvProfString('Startpath',''),;
		cFileLogo	:= cStartPath + 'logorech_' + AllTrim(cEmpAnt) + '.bmp'

Private	oPrint		:= TMSPrinter():New(OemToAnsi('Controle de Chamado')),;
		oBrush		:= TBrush():New(,4),;
		oFont07		:= TFont():New('Courier New',07,07,,.F.,,,,.T.,.F.),;
		oFont08		:= TFont():New('Courier New',08,08,,.F.,,,,.T.,.F.),;
		oFont08n	:= TFont():New('Courier New',08,08,,.T.,,,,.T.,.F.),;
		oFont10Co   := TFont():New('Courier New',10,10,,.F.,,,,.T.,.F.),;
		oFont09		:= TFont():New('Tahoma',09,09,,.F.,,,,.T.,.F.),;
		oFont10		:= TFont():New('Tahoma',10,10,,.F.,,,,.T.,.F.),;
		oFont10n	:= TFont():New('Courier New',10,10,,.T.,,,,.T.,.F.),;
		oFont11		:= TFont():New('Tahoma',11,11,,.F.,,,,.T.,.F.),;
		oFont12		:= TFont():New('Tahoma',12,12,,.T.,,,,.T.,.F.),;
		oFont14		:= TFont():New('Tahoma',14,14,,.T.,,,,.T.,.F.),;
		oFont14s	:= TFont():New('Arial',14,14,,.T.,,,,.T.,.T.),;
		oFont15		:= TFont():New('Courier New',15,15,,.T.,,,,.T.,.F.),;
		oFont18		:= TFont():New('Arial',18,18,,.T.,,,,.T.,.T.),;
		oFont18n	:= TFont():New('Arial',18,18,,.T.,,,,.T.,.F.),;
		oFont16		:= TFont():New('Arial',16,16,,.T.,,,,.T.,.F.),;
		oFont22		:= TFont():New('Arial',22,22,,.T.,,,,.T.,.F.)

Private	aAberOcor	:= {},;
		aComentar	:= {},;
		aSolucao	:= {}

Private	nLin		:= 30	// Linha que o sistema esta imprimindo.
		nPage		:= 0

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณMonta os dados em array.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		For i:=1 To MlCount(Z03->Z03_OCORRE,56)
			If	! Empty(AllTrim(MemoLine(Z03->Z03_OCORRE,56,i)))
				aAdd(aAberOcor,AllTrim(MemoLine(Z03->Z03_OCORRE,56,i)))
			EndIf
		Next
		For i:=1 To MlCount(Z03->Z03_COMENT,56)
			If	! Empty(AllTrim(MemoLine(Z03->Z03_COMENT,56,i)))
				aAdd(aComentar,AllTrim(MemoLine(Z03->Z03_COMENT,56,i)))
			EndIf
		Next
		For i:=1 To MlCount(Z03->Z03_SOLUCA,56)
			If	! Empty(AllTrim(MemoLine(Z03->Z03_SOLUCA,56,i)))
				aAdd(aSolucao,AllTrim(MemoLine(Z03->Z03_SOLUCA,56,i)))
			EndIf
		Next

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSeta a pagina para impressao em Retrato.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oPrint:SetPortrait()

		xCabecPrin()

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณIMPRIME A PARTE DE INFORMACOES DO CHAMADO.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oPrint:Say(nLin,0050,OemToAnsi('N๚mero Chamado: '),oFont08n)
		oPrint:Say(nLin,0350,OemToAnsi('Descri็ใo: '),oFont08n)
		oPrint:Say(nLin,1600,OemToAnsi('Dt. Abertura: '),oFont08n)
		oPrint:Say(nLin,2000,OemToAnsi('Empresa/Filial: '),oFont08n)
		nLin += 40
		oPrint:Say(nLin,0050,Z03->Z03_NUMCHA,oFont10Co)
		oPrint:Say(nLin,0350,SubStr(Z03->Z03_DESC,1,50),oFont10Co)
		oPrint:Say(nLin,1600,DtoC(Z03->Z03_DTABER)+'-'+Z03->Z03_HRABER,oFont10Co)
		oPrint:Say(nLin,2000,Z03->Z03_EMPCHA,oFont10Co)

		nLin += 60 // Espaco entre os campos

		oPrint:Say(nLin,0050,OemToAnsi('Tipo: '),oFont08n)
		oPrint:Say(nLin,1000,OemToAnsi('Prioridade: '),oFont08n)
		oPrint:Say(nLin,1600,OemToAnsi('Solicitante: '),oFont08n)
		nLin += 40
		oPrint:Say(nLin,0050,Tabela('Z4',Z03->Z03_TIPO) + ' ' + Z03->Z03_MODULO + ' ' + Z03->Z03_PROGRA,oFont10Co)
		oPrint:Say(nLin,1000,Tabela('Z5',Z03->Z03_PRICHA),oFont10Co)
		oPrint:Say(nLin,1600,Upper(UsrFullName(Z03->Z03_SOLCHA)),oFont10Co)

		nLin += 60 // Espaco entre os campos

		oPrint:Say(nLin,0050,OemToAnsi('Ocorr๊ncia:'),oFont08n)

		For i:=1 To Len(aAberOcor)
			nLin += 40
			If	( nLin >= 3000 )
				xCabecPrin()
			EndIf
			oPrint:Say(nLin,0050,aAberOcor[i],oFont10Co)
		Next i

		nLin += 60 // Espaco entre os campos

		If	( nLin >= 3000 )
			xCabecPrin()
		EndIf

		oPrint:Line(nLin,0050,nLin,2300) // Linha Separacao

		nLin += 30

		If	( nLin >= 3000 )
			xCabecPrin()
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณIMPRIME OS DADOS DOS COMENTARIOSณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If	( Z03->Z03_STATUS == '1' ) .or. ( Z03->Z03_STATUS == '8' ) .or. ( Z03->Z03_STATUS == '9' )

			oPrint:Say(nLin,0050,OemToAnsi('T้cnico Alocado:'),oFont08n)
			nLin += 40
			If	( nLin >= 3000 )
				xCabecPrin()
			EndIf

			oPrint:Say(nLin,0050,Upper(UsrFullName(Z03->Z03_TECALO)),oFont10Co)

			nLin += 60 // Espaco entre os campos

			If	( nLin >= 3000 )
				xCabecPrin()
			EndIf

			oPrint:Say(nLin,0050,OemToAnsi('Comentแrios:'),oFont08n)

			For i:=1 To Len(aComentar)
				nLin += 40
				If	( nLin >= 3000 )
					xCabecPrin()
				EndIf
				oPrint:Say(nLin,0050,aComentar[i],oFont10Co)
			Next i

			nLin += 60 // Espaco entre os campos

			If	( nLin >= 3000 )
				xCabecPrin()
			EndIf

			oPrint:Line(nLin,0050,nLin,2300) // Linha Separacao

			nLin += 30

			If	( nLin >= 3000 )
				xCabecPrin()
			EndIf

		EndIf	

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณIMPRIME OS DADOS DOS COMENTARIOSณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If	( Z03->Z03_STATUS == '9' ) .or. ( Z03->Z03_STATUS == '8' )

			oPrint:Say(nLin,0050,OemToAnsi('T้cnico:'),oFont08n)
			oPrint:Say(nLin,1600,OemToAnsi('Dt. Encerramento: '),oFont08n)
			oPrint:Say(nLin,2000,OemToAnsi('Classifica็ใo: '),oFont08n)
			nLin += 40
			oPrint:Say(nLin,0050,Upper(UsrFullName(Z03->Z03_TECNIC)),oFont10Co)
			oPrint:Say(nLin,1600,DtoC(Z03->Z03_DTFECH)+'-'+Z03->Z03_HRFECH,oFont10Co)
			If	! Empty(Z03->Z03_CLASSI)
				oPrint:Say(nLin,2000,Tabela('Z6',Z03->Z03_CLASSI),oFont10Co)
			EndIf

			nLin += 60 // Espaco entre os campos

			If	( nLin >= 3000 )
				xCabecPrin()
			EndIf

			oPrint:Say(nLin,0050,OemToAnsi('Solu็ใo:'),oFont08n)

			For i:=1 To Len(aSolucao)
				nLin += 40
				If	( nLin >= 3000 )
					xCabecPrin()
				EndIf
				oPrint:Say(nLin,0050,aSolucao[i],oFont10Co)
			Next i

			nLin += 60 // Espaco entre os campos

			If	( nLin >= 3000 )
				xCabecPrin()
			EndIf

			oPrint:Line(nLin,0050,nLin,2300) // Linha Separacao

		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณFinaliza a impressao do relatorio.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oPrint:EndPage()

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณMostra em video a impressao do relatorio. !ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oPrint:Preview()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัอออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณxCabecPrin บAutor ณ	Viviane Ruiz	  บ Data ณ  11/06/13  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯอออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para imprimir o cabecalho do relatorio.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao Principal                                           บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ  MOTIVO                                         บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function xCabecPrin()
Local	cStatus	:= ''

		If	( Z03->Z03_STATUS == '0' )
			cStatus	:= 'Aberto'
		ElseIf	( Z03->Z03_STATUS == '1' )
			cStatus	:= 'Em Anแlise'
		ElseIf	( Z03->Z03_STATUS == '8' )
			cStatus	:= 'Cancelado'
		ElseIf	( Z03->Z03_STATUS == '9' )
			cStatus	:= 'Encerrado'
		EndIf

		nLin := 30

		If	( nPage > 0 )
			oPrint:EndPage()
		EndIf
		
		nPage++

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณInicia a impressao da pagina.!ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oPrint:StartPage()

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณImprime o cabecalho da empresa. !ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oPrint:SayBitmap(nLin+20,040,cFileLogo,230,175) // 560,350)
		oPrint:Say(nLin+20,700,'BRASILUX TINTAS',oFont16)
		oPrint:Say(nLin+150,700,'Tecnologia da Informa็ใo',oFont11)
		oPrint:Say(nLin+195,700,'Suporte T้cnico',oFont11)
		oPrint:Say(nLin+285,700,AllTrim('www.brasilux.com.br'),oFont11)

		oPrint:Say(nLin+100,1700,'Ficha de Chamado',oFont18n)
		oPrint:Say(nLin+180,1700,Z03->Z03_NUMCHA + ' - ' + OemToAnsi(cStatus),oFont14s)

		nLin += 450

		oPrint:Line(nLin,0050,nLin,2300) // Linha Separacao

		nLin += 30

Return


Static Function AjustaSx1(_cPerg)
    Local _nx	  := 0
	Local _nh	  := 0
	Local nlh    := 0
	Local _aHelp  := Array(8,1)
	Local _aRegs  := {}
	//Local _sAlias := Alias()
		
	Local _aHead	:= {"SX1->X1_GRUPO","SX1->X1_ORDEM","SX1->X1_PERGUNTE","SX1->X1_PERSPA","SX1->X1_PERENG	",;
					"SX1->X1_VARIAVL","SX1->X1_TIPO","SX1->X1_TAMANHO","SX1->X1_DECIMAL","SX1->X1_PRESEL",;
					"SX1->X1_GSC","SX1->X1_VALID","SX1->X1_VAR01","SX1->X1_DEF01","SX1->X1_DEF02",;
					"SX1->X1_DEF03","SX1->X1_DEF04","SX1->X1_DEF05","SX1->X1_F3"}

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCria um array, contendo todos os valores... ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//	PUTSX1{_cPerg,'01',"Filtrar por ?"      ,"Filtrar por ?"      ,"Filtrar por ?"      ,'mv_ch1','N', 1,0,0,'C','','mv_par01','Pendentes','Em analise','Encerrados','Cancelados','Todos',''})
		aAdd(_aRegs,{_cPerg,'02',"Prioridade ?"       ,"Prioridade ?"       ,"Prioridade ?"       ,'mv_ch2','N', 1,0,0,'C','','mv_par02','Alta','Normal','Baixa','Ambas','',''})
		aAdd(_aRegs,{_cPerg,'03',"Programa Inicial? " ,"Programa Inicial? " ,"Programa Inicial? " ,'mv_ch3','C',10,0,0,'G','','mv_par03','','','','',"",""})
		aAdd(_aRegs,{_cPerg,'04',"Programa Final? "   ,"Programa Final? "   ,"Programa Final? "   ,'mv_ch4','C',10,0,0,'G','','mv_par04','','','','',"",""})
		aAdd(_aRegs,{_cPerg,'05',"Filtra por Tecnico?","Filtra por Tecnico?","Filtra por Tecnico?",'mv_ch5','N', 1,0,0,'C','','mv_par05','Sim','Nao','','',"",""})
		aAdd(_aRegs,{_cPerg,'06',"Que contem (palavra)","Que contem (palavra)","Que contem (palavra)",'mv_ch6','C',20,0,0,'G','','mv_par06','','','','',"",""})
	   
		DbSelectArea('SX1')
		SX1->(DbSetOrder(1))

		For _nx:=1 to Len(_aRegs)
			If	RecLock('SX1',Iif(!SX1->(DbSeek(_aRegs[_nx][01]+_aRegs[_nx][02])),.t.,.f.))
				For nlh:=1 to Len(_aHead)
					If	( nlh <> 10 )
						Replace &(_aHead[nlh]) With _aRegs[_nx][nlh]
					EndIf
				Next nlh
				MsUnlock()
			Else
				Help('',1,'REGNOIS')
			Endif
		Next _nx
   
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณMonta array com o help dos campos dos parametros.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aAdd(_aHelp[01],OemToAnsi("Escolha os chamados que deseja visualizar: Abertos, em analise, encerrados, cancelados ou todos."))
		aAdd(_aHelp[02],OemToAnsi("De qual prioridade voc๊ quer visualizar?"))
		aAdd(_aHelp[03],OemToAnsi("Programa, para os chamados envolvendo Microsiga, inicial ?"))
		aAdd(_aHelp[04],OemToAnsi("Programa, para os chamados envolvendo Microsiga, final ?"))
		For _nh:=1 to Len(_aHelp)
			PutSX1Help("P."+AllTrim(_cPerg)+StrZero(_nh,2)+".",_aHelp[_nh],_aHelp[_nh],_aHelp[_nh])
		Next _nh

Return Nil