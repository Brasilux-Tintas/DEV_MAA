#include "Protheus.ch"
#include "colors.ch"
#INCLUDE "topconn.ch"
#include 'rwmake.ch'

/*/{Protheus.doc} NBRSACA01
Atendimento ao CLiente
@type function Tela
@version  1.00
@author marioantonaccio
@since 28/05/2026
@return character, sem retorno
/*/

User Function NBRSACA01()
	Local aSubMenu:={}
	Private cUserDir  := "001327/"+GETMV("ZP_PAR0207") as Character
	Private aCores    := {}                            as Array
	// Private aEnvSac   := fBusEnvSac()                  as Array
	Private aIndexSZQ := {}                            as array // Funcionamento do Filtro
	Private aRotina   := {}                            as Array
	Private cCadastro := "ATENDIMENTO AO CLIENTE(SAC)" as Character
	Private cCodUsr   := RetCodUsr()                   as Character
	Private cDelFunc  := ".T."                         as character // Validacao para a exclusao. Pode-se utilizar ExecBlock
	Private cDepart   := " "                           as Character
	Private cDepUsu   := ""                            as Character
	Private cRotUsu   := 'BRSACA01  '                  as Character
	Private cString   := "SZQ"                         as character
	Private cTipFil   := ""                            as Character
	Private cVlrOpcB  := ''                            as Character
	Private erroTrans := .F.                           as Logical
	Private lConChv   := GetNewPar("MV_CHVNFE",.F.)    as Logical
	Private lFilUtil  := .T.                           as Logical
	Private nGetOSac  :={"Sim" , "Nao"}                as Array
	Private nGetPSac  :={"SPED", "NFE"}                as Array
	Private nOpc      := 0                             as Number
	Private nOpcRot   := 0                             as Number //Opção do Roteiro do sistema
	Private oObjBrow  := Nil                           as object // Funcionamento do Filtro

	If RetCodUsr() <> '001327'
		If .NOT. u_fVerAcsUsr(cRotUsu, 1, , @cDepUsu, @cTipFil)
			FWAlertError("Usuário sem acesso a essa opção.", "Atenção")
			Return (NIL)
		Endif

		cDepart    :=	 GetAdvFVal("SZW",;
			"ZW_DEPTO",;
			xFilial("SZW") +;
			cRotUsu+;
			cCodUsr+;
			SUBSTR(cNumEmp,1,2)+;
			SUBSTR(cNumEmp,FWSizeFilial()+1,2),;
			,4,'')
	Else
		cDepart:='DIR'
	End

	aRotina   := { {"Pesquisar"  , "AxPesqui"  , 0, 1} ,;
		{"Visualizar" , "NSACA011", 0, 2}  }
	// aadd(aRotina, {OemToAnsi("Atendimento" )           , aSubMenu           , 0, 2})

	If (u_fVerAcsUsr(cRotUsu, 2) .or. cCodUsr=="001327")  .and. cDepart $ 'INF/ATE/DIR'
		aadd(aSubMenu, {OemToAnsi("Inclui SAC")          , 'U_SACA011(3)', 0, 9})
		aadd(aSubMenu, {OemToAnsi("Reabre SAC")          , 'U_SACA011(4)', 0, 9})
		aadd(aSubMenu, {OemToAnsi("Exclusao Atendimento"), 'U_SACA011(5)', 0, 9})
		aadd(aSubMenu, {OemToAnsi("Encerrar Atendimento"), 'U_SACA011(8)', 0, 9})

		If cDepart == 'DIR' .and. cCodUsr $ cUserDir
			aadd(aSubMenu, {OemToAnsi("Emite Parecer SAC")   , 'U_SACA011(6)', 0, 9})
			nOpcRot := 1   //Para Usuários do atendimento, informatica e diretoria onde Diretoria, Gustavo tem opção do parecer.
		Else
			nOpcRot := 2 //Para outros usuários do atendimento cujos pareceres (diagnostico/solução) são dados na tela principal.
		Endif
	ElseIf u_fVerAcsUsr(cRotUsu, 4)  .or. cDepart == 'FIN'
		aadd(aSubMenu, {OemToAnsi("Emite Parecer SAC")   , 'U_SACA011(6)', 0, 9})
		aadd(aSubMenu, {OemToAnsi("Encerrar Atendimento"), 'U_SACA011(8)', 0, 9})
		nOpcRot := 3 //Para usuários que não são do atendimento, diretoria ou informatica e informam seus pareceres.
	Endif

	aAdd(aRotina, { OemToAnsi("Atendimento"), aSubMenu, 0, 3} )

	//aAdd(aRotina, { OemToAnsi("Pendentes")               , 'U_SACA01_R'      , 0, 9} )
	aadd(aRotina, { OemToAnsi("Mostrar Pendentes")       , 'U_SACA01_F(1,1)' , 0, 0} )
	aadd(aRotina, { OemToAnsi("Mostrar Todos os Abertos") , 'U_SACA01_F(1,2)' , 0, 0} )
	aadd(aRotina, { OemToAnsi("Desligar Filtro")         , 'U_SACA01_F(2)'   , 0, 0} )

	If (cDepart == 'DIR' .or. cCodUsr $ '000071/000023') .or. cDepUsu $ 'INF/ATE'
		aAdd(aRotina, { OemToAnsi("Vencimento")       , 'U_SACA01_V'      , 0, 9} )
	Endif

	aAdd(aRotina, { OemToAnsi("Ficha")                ,'U_BRSACR07'      , 0, 9} )
	aAdd(aRotina, { OemToAnsi("Imprime sac")          ,'U_BRSACR01(1)'   , 0, 9} )
	aAdd(aRotina, { OemToAnsi("Imp. Aut. Devolução")  ,'U_BRSACA02(1)'   , 0, 9} )
	aAdd(aRotina, { OemToAnsi("Banco de Conhecimento"),'MsDocument'      , 0, 4} )
	aAdd(aRotina, { OemToAnsi("Legenda")              ,'U_SACA01_L'      , 0, 9} )

	If cCodUsr $ '00001327/000000/000071/000092/000023'
		aAdd(aRotina, { OemToAnsi("Acessos")           , 'U_SENA01(cRotUsu)' , 0, 6} )
	Endif

	cDelFunc  := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

	aCores   := { { "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'D')", 'BR_AZUL'    },; //SAC com Diretoria
		{ "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'C')", 'BR_AMARELO' },; //SAC com Comercial
		{ "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'F')", 'BR_PINK'    },; //SAC com Financeiro
		{ "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'T')", 'BR_MARRON'  },; //SAC com Técnico
		{ "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'P')", 'BR_MARRON'  },; //SAC com Produção
		{ "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'E')", 'BR_PRETO'   },; //SAC com Expedição
		{ "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'S')", 'BR_CINZA '  },; //SAC com Suprimentos- Compras
		{ "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'V')", 'BR_CINZA '  },; //SAC com Depósito SP - Viamix
		{ "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'R')", 'BR_LARANJA' },; //SAC com Recebimento
		{ "(ZQ_STATUS == '1' .AND. ZQ_FLAG == '-')", 'BTCALC'     },; //SAC com Contabilidade
		{ "(ZQ_STATUS == '1' .AND. ZQ_FLAG == '#')", 'INSTRUME'   },; //SAC com Manutencao
		{ "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'A')", 'ENABLE'     },; //SAC com Atendente
		{ "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'M')", 'BR_BRANCO'  },; //Atendimento com Resposta
		{ "(ZQ_STATUS == '2'                     )", 'DISABLE'    } } //SAC encerrado


	///PAra testes da rotina
	if cCodUsr == '001327'
		aRotina:={}
		nOpcRot := 1
		aadd(aRotina, {OemToAnsi("Pesquisar")              , "AxPesqui"         , 0, 1})
		aadd(aRotina, {OemToAnsi("Visualizar")             , "u_SACA011(2)"     , 0, 2})
		aadd(aRotina, {OemToAnsi("Atendimento" )           , aSubMenu           , 0, 3})
		aadd(aRotina, {OemToAnsi("Mostrar Pendentes")      , 'U_SACA01_F(1,1)'  , 0, 0})
		aadd(aRotina, {OemToAnsi("Mostrar Todos Abertos")  , 'U_SACA01_F(1,2)'  , 0, 0})
		aadd(aRotina, {OemToAnsi("Desligar Filtro")        , 'U_SACA01_F(2)'    , 0, 0})
		aadd(aRotina, {OemToAnsi("Vencimento")             , 'U_SACA01_V'       , 0, 9})
		aadd(aRotina, {OemToAnsi("Ficha")                  , 'U_BRSACR07'       , 0, 9})
		aadd(aRotina, {OemToAnsi("Imprime sac")            , 'U_BRSACR01(1)'    , 0, 9})
		aadd(aRotina, {OemToAnsi("Imp.Aut.Devolução")      , 'U_BRSACA02(1)'    , 0, 9})
		aadd(aRotina, {OemToAnsi("Banco Conhecimento")     , 'MsDocument'       , 0, 4})
		aadd(aRotina, {OemToAnsi("Legenda")                , 'U_SACA01_L'       , 0, 9})
		aadd(aRotina, {OemToAnsi("Acessos")                , 'U_SENA01(cRotUsu)', 0, 6})
		//aAdd(aRotina, { OemToAnsi("Pendentes")            , 'U_SACA01_R'      , 0, 9} )
		//aAdd(aRotina, { OemToAnsi("Romaneio de Coleta")   , 'U_BRSACR02(1)'   , 0, 9} )
		//aAdd(aRotina, { OemToAnsi("E-mail representante") , 'U_SACX02_4()'    , 0, 9} )
	End

	DbSelectArea(cString)
	DbSetOrder(1)

	oObjBrow := FWMBrowse():New()
	oObjBrow:SetAlias(cString)		// Indica o Alias da tabela utilizada no Browse
	oObjBrow:SetMenuDef(cRotUsu)
	oObjBrow:SetWalkThru(.F.)
	oObjBrow:SetUseFilter(.T.)
	If type("oObjBrow:lDetails") <> "U"
		oObjBrow:lDetails := .F.
	Endif
	oObjBrow:SetExecuteDef(2)		// Elemento do aRotina executado no duplo clique
	oObjBrow:AddLegend( "(ZQ_STATUS == '1' .AND. ZQ_FLAG == '#' )" , 'INSTRUME'   , "SAC com Manutenção " )
	oObjBrow:AddLegend( "(ZQ_STATUS == '1' .AND. ZQ_FLAG == '-' )" , 'BTCALC'     , "SAC com Contabilidade " )
	oObjBrow:AddLegend( "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'A' )" , 'ENABLE'     , "SAC com Atendente " )
	oObjBrow:AddLegend( "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'C' )" , 'BR_AMARELO' , "SAC com Comercial " )
	oObjBrow:AddLegend( "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'D' )" , 'BR_AZUL'    , "SAC com Diretoria " )
	oObjBrow:AddLegend( "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'E' )" , 'BR_PRETO'   , "SAC com Expedição " )
	oObjBrow:AddLegend( "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'F' )" , 'BR_PINK'    , "SAC com Financeiro " )
	oObjBrow:AddLegend( "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'M' )" , 'BR_BRANCO'  , "Atendimento com Resposta" )
	oObjBrow:AddLegend( "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'P' )" , 'BR_MARRON'  , "SAC com Produção " )
	oObjBrow:AddLegend( "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'R' )" , 'BR_LARANJA' , "SAC com Recebimento " )
	oObjBrow:AddLegend( "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'S' )" , 'BR_CINZA'   , "SAC com Supri. Compras " )
	oObjBrow:AddLegend( "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'T' )" , 'BR_MARRON'  , "SAC com Técnico " )
	oObjBrow:AddLegend( "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'V' )" , 'BR_CINZA'   , "SAC com Depósito SP " )
	oObjBrow:AddLegend( "(ZQ_STATUS == '2' ) "                     , 'DISABLE'    , "SAC Encerrado " )

	oObjBrow:Activate()

	EndFilBrw("SZQ",aIndexSZQ)

	If Select("TMPCLO")<>0
		TMPCLO->(dbclosearea())
	Endif
	If Select("TMPHIS")<>0
		TMPHIS->(dbclosearea())
	Endif
	If Select("TMPLOT")<>0
		TMPLOT->(dbclosearea())
	Endif
	If Select("TMPSEL")<>0
		TMPSEL->(dbclosearea())
	Endif
	If Select("TMPLOG")<>0
		TMPLOG->(dbclosearea())
	Endif
	If Select("TMPABE")<>0
		TMPABE->(dbclosearea())
	Endif

	aEval(Directory("tmp*.dbf"), { |aFile| FERASE(aFile[F_NAME]) })
	aEval(Directory("tmp*.fpt"), { |aFile| FERASE(aFile[F_NAME]) })
	aEval(Directory("tmp*.cdx"), { |aFile| FERASE(aFile[F_NAME]) })

Return (NIL)

/*/{Protheus.doc} SACA011
Inclui Atendimento
@type function Tela
@version  1.00
@author marioantonaccio
@since 29/05/2026
@param nOpc, numeric, Codigo funcação apdrao a ser executada
@return character, sem retorno
/*/
User Function SACA011(nOPC)
	Local aCpoAGd := {}  as Array
	Local cDepto  := ' ' as Character
	Local cVarATE := ""  as Character
	Local cVarDIA := ""  as Character

	SetKey( VK_F4, { || ShowF4("F") } )
	SetKey( VK_F5, { || ShowF5() } )
	aCpoAGd := {"ZR_PRODUTO", "ZR_QTD", "ZR_LOTE", "ZR_QAPRRET","ZR_QTDABAT"}

	Do Case
		Case nOpc == 3 // INCLUSÃO NOVO SAC

		Case nOpc == 4 //ALTERAÇÃO / RE-ABERTURA DE SAC
			If SZQ->ZQ_STATUS == '1'  //Em aberto
				If .NOT. (SZQ->ZQ_FLAG $ 'A/M')
					If  .NOT. cDepart $ 'ATE/INF/DIR'
						FWAlertError("O Status desse SAC não permite a alteração.","sem Permissao")
						Return (NIL)
					Endif
				Endif
			ElseIf SZQ->ZQ_STATUS == '2'  //Encerrado
				If  .NOT. (cDepart $ 'ATE.INF.DIR') //para reabrir somente esses departamentos
					FWAlertError("Esse SAC já se encontra encerrado. Contactar Atendimento","SAC Encerrado")
					Return (NIL)
				Endif
			Endif

		Case nOpc == 5 //EXCLUSÃO DO SAC
			If SZQ->ZQ_STATUS == '1'
				If .NOT. (SZQ->ZQ_FLAG $ 'A/M')
					FWAlertError("O Status desse SAC não permite a exclusão.","SAC em Atendimento")
					Return (NIL)
				Endif
			Else
				FWAlertError("Esse SAC já se encontra encerrado.","SAC Encerrado")
				Return (NIL)
			Endif

		Case nOpc == 6 //PARECER DO SAC
			If SZQ->ZQ_STATUS == '2'  //Encerrado
				FWAlertError("O Status desse SAC não permite informar o parecer.","SAC Encerrado")
				Return (NIL)
			End

			cDepto:=Tabela("ZS", cDepart, .F.)

			If .NOT. Empty(cDepto)

				If SZQ->ZQ_FLAG <>  AllTrim(X5Descric())
					FWAlertError("O Status desse SAC não permite informar o parecer.","FLAG nao permite")
					Return (NIL)
				Else
					If  .NOT. (SZQ->ZQ_FLAG $ 'A/M')
						If .NOT. (cDepart == 'INF')
							FWAlertError("O Status do departamento do usuário não permite informar o parecer.","Depto. Nao Autorizado")
							Return (NIL)
						Endif
					Endif
				End
			End

		Case nOpc == 8 //ENCERRAMENTO DO SAC
			If SZQ->ZQ_STATUS == '1'
				If .NOT. (SZQ->ZQ_FLAG $ 'A/M/F')
					FWAlertError("O Status desse SAC não permite o encerramento.","Status Nao permite Encerramento")
					Return (NIL)
				Endif
				cVarATE := ""
				cVarDIA := ""
				SZS->(DbSetOrder(1))
				If SZS->(DbSeek(xFilial("SZS")+cSacNum))
					While .NOT. SZS->(EOF()) .and. SZS->ZS_NUM == cSacNum
						If SZS->ZS_LOG $ 'ATE'
							cVarATE += SZS->ZS_PARECER+CRLF+CRLF
						ElseIf SZS->ZS_LOG $ 'DIA'
							cVarDIA += SZS->ZS_PARECER+CRLF+CRLF
						Endif
						SZS->(DbSkip())
					End
				Endif

				If !Empty(Alltrim(cVarDIA))
					cMul2Sac := cVarDIA
				Else
					If !Empty(Alltrim(cVarATE))
						cMul2Sac := cVarATE
					Endif
				Endif
			Else
				FWAlertError("Esse SAC já se encontra encerrado.","SAC Encerrado")
				Return (NIL)
			Endif
	EndCase
	SACA011A(nOpc)

Return

/*/{Protheus.doc} SACA011A
Monta Tela de SAC
@type function Tela
@version 1.00
@author marioantonaccio
@since 24/06/2026
@param nOpc, numeric, Opção de rotina aser executada
@return character,sem valor definido
/*/
Static Function SACA011A(nOpc)

	Private aFlag      := {}             as Array
	Private aItDesc    := {}             as Array
	Private aItPar     := {}             as Array
	Private aItTPSAc   := {}             as Array
	Private aSize      := MsAdvSize(.F.) as Array
	Private bSair      := NIL            as CodeBlock
	Private cCabec     := " "            as Character
	Private cFontUti   := "Tahoma"       as Character
	Private cMascara   := " "            as Character
	Private cSACAnex   := "Nao"          as Character
	Private cSACAssu   := Space(06)      as Character
	Private cSAcAten   := Space(15)      as Character
	Private cSACClie   := Space(06)      as Character
	Private cSACCont   := Space(20)      as Character
	Private cSACDASS   := Space(20)      as Character
	Private cSACDesc   := Space(30)      as Character
	Private cSACDOCO   := Space(30)      as Character
	Private cSACFlag   := " "            as Character
	Private cSACFone   := Space(15)      as Character
	Private cSACHF     := Space(05)      as Character
	Private cSACHI     := Space(05)      as Character
	Private cSACLj     := Space(02)      as Character
	Private cSACNF     := Space(09)      as Character
	Private cSACNome   := Space(30)      as Character
	Private cSacNum    := Space(06)      as Character
	Private cSACOcor   := Space(06)      as Character
	Private cSACPar    := " "            as Character
	Private cSacSeri   := Space(02)      as Character
	Private cTpDesc    := " "            as Character
	Private cTpRePar   := " "            as Character
	Private cTPSac     := " "            as Character
	Private dSACData   := CtoD(" ")      as Date
	Private dSACDRes   := CTOD(" ")      as Date
	Private dSACDtFn   := CtoD(" ")      as Date
	Private nJanAltu   := aSize[06]      as Numeric
	Private nJanLarg   := aSize[05]      as Numeric
	Private nSACCDev   := 0              as Numeric
	Private nSACCFin   := 0              as Numeric
	Private nSACCFrt   := 0              as Numeric
	Private nSACTot    := 0              as Numeric
	Private oBtnCanc   := NIL            as Object
	Private oBtnOk     := NIL            as Object
	Private oDlgSAC    := NIL            as Object
	Private oFontBtn   := NIL            as Object
	Private oFontMod   := NIL            as Object
	Private oFontSay   := NIL            as Object
	Private oFontSub   := NIL            as Object
	Private oFontSubN  := NIL            as Object
	Private oSACAnex   := NIL            as Object
	Private oSACAten   := NIL            as Object
	Private oSACCDev   := NIL            as Object
	Private oSACCFin   := NIL            as Object
	Private oSACCFrt   := NIL            as Object
	Private oSACClie   := NIL            as Object
	Private oSACCont   := NIL            as Object
	Private oSACDAss   := NIL            as Object
	Private oSACData   := NIL            as Object
	Private oSACDEsc   := NIL            as Object
	Private oSACDOCO   := NIL            as Object
	Private oSACDRes   := NIL            as Object
	Private oSACFlag   := NIL            as Object
	Private oSACFld    := NIL            as Object
	Private oSACGrp01  := NIL            as Object
	Private oSACGrp03  := NIL            as Object
	Private oSACGrp04  := NIL            as Object
	Private oSACHF     := NIL            as Object
	Private oSACHI     := NIL            as Object
	Private oSACLj     := NIL            as Object
	Private oSACNF     := NIL            as Object
	Private oSACNome   := NIL            as Object
	Private oSacNum    := NIL            as Object
	Private oSACOcor   := NIL            as Object
	Private oSACOPar   := NIL            as Object
	Private oSACPar    := NIL            as Object
	Private oSACResp   := NIL            as Object
	Private oSacSeri   := NIL            as Object
	Private oSACStat   := NIL            as Object
	Private oSACTot    := NIL            as Object
	Private oSay1      := NIL            as Object
	Private oSay10     := NIL            as Object
	Private oSay11     := NIL            as Object
	Private oSay12     := NIL            as Object
	Private oSay13     := NIL            as Object
	Private oSay14     := NIL            as Object
	Private oSay15     := NIL            as Object
	Private oSay16     := NIL            as Object
	Private oSay17     := NIL            as Object
	Private oSay18     := NIL            as Object
	Private oSay19     := NIL            as Object
	Private oSay2      := NIL            as Object
	Private oSay20     := NIL            as Object
	Private oSay3      := NIL            as Object
	Private oSay4      := NIL            as Object
	Private oSay5      := NIL            as Object
	Private oSay6      := NIL            as Object
	Private oSay7      := NIL            as Object
	Private oSay8      := NIL            as Object
	Private oSay9      := NIL            as Object
	Private oTpDesc    := NIL            as Object
	Private oTPSac     := NIL            as Object

	cMascara   := "@ER 999,999,999,999,999.99"
	oFontBtn   := TFont():New(cFontUti, , -14)
	oFontMod   := TFont():New(cFontUti, , -38)
	oFontSay   := TFont():New(cFontUti, , -12)
	oFontSub   := TFont():New(cFontUti, , -20)

	aadd(aFlag, {'D', "Sac com Diretoria"})
	aadd(aFlag, {'C', "Sac com Comercial"})
	aadd(aFlag, {'F', "Sac com Financeiro"})
	aadd(aFlag, {'T', "Sac com Técnico"})
	aadd(aFlag, {'P', "Sac com Produção"})
	aadd(aFlag, {'E', "Sac com Expedição"})
	aadd(aFlag, {'V', "Sac com Depósito SP"})
	aadd(aFlag, {'#', "Sac com Manutenção"})
	aadd(aFlag, {'S', "Sac com Supri. Compras"})
	aadd(aFlag, {'R', "Sac com Recebimento"})
	aadd(aFlag, {'-', "Sac com Contabilidade"})
	aadd(aFlag, {'A', "Sac com Atendente"})
	aadd(aFlag, {'M', "Atendimento com Resposta"})

	aItDesc  :={"Sem Dev.", "NCC"       , "AB-"     , "NCC e AB-"}
	aItTPSAc :={""        , "Reclamação", "Sugestão", "Comodato" , "Outros", "Interno"}
	aItPar   :={""        , "Sim"       , "Nao"}
	bSair    := {|| Iif(FWAlertYesNo( 'Você tem certeza que deseja sair da rotina? ','Sair da rotina'),(oDlgSAC:End()),nOpc:=2) }

	oFontSubN  := TFont():New(cFontUti, 0, -13, , .T., 0, , 700, .F., .F., , , , , ,)

	If nOpc == 3
		cSacNum   := GetSxeNum("SZQ","ZQ_NUM")
		cSACAtend := cUserName
		dSACData  := Date()
		cSACHI    := Time()
		cTpDesc   := aItDesc[1]
		cTPSac    := aItTPSAc[2]
	Else
		cSACStat := If(SZQ->ZQ_STATUS=='1',"Em Aberto","Encerrado")
		cSacNum   := SZQ->ZQ_NUM
		cSACAtend := SZQ->ZQ_ATENDEN
		dSACData  := SZQ->ZQ_DATA
		dSACDtFim := SZQ->ZQ_DTFIM
		cSACHI    := SZQ->ZQ_HINI
		cSACHF    := SZQ->ZQ_HFIM
		cTpDesc   := aItDesc[Val(SZQ->ZQ_TPABAT)]
		If SZQ->ZQ_TIPOSAC == '1'
			cTPSac:=aItTPSAc[2]
		ElseIf 	SZQ->ZQ_TIPOSAC == '2'
			cTPSac:=aItTPSAc[3]
		ElseIf 	SZQ->ZQ_TIPOSAC == '3'
			cTPSac:=aItTPSAc[4]
		ElseIf 	SZQ->ZQ_TIPOSAC == '4'
			cTPSac:=aItTPSAc[5]
		Else
			cTPSac:=aItTPSAc[6]
		End
		cSACNF   := CriaVar("F2_DOC")
		cSacSeri := Criavar("F2_SERIE")
		cSACClie := SZQ->ZQ_CLIENTE
		cSACLj   := If(SZQ->(FieldPos("ZQ_LOJA")) > 0,SZQ->ZQ_LOJA,"")
		cSACNome := AllTrim(GetAdvFVal("SA1","A1_NOME", xFilial("SA1") + SZQ->ZQ_CLIENTE+cSACLj,1, 'Erro' ))
		cSACFone := AllTrim(GetAdvFVal("SA1","A1_DDD", xFilial("SA1") + SZQ->ZQ_CLIENTE+cSACLj,1, 'Erro' ))+;
			'-' +AllTrim(GetAdvFVal("SA1","A1_TEL", xFilial("SA1") + SZQ->ZQ_CLIENTE+cSACLj,1, 'Erro' ))
		cSACCont := SZQ->ZQ_CONTATO
		cSACResp := SZQ->ZQ_RESP
		cSACFlag := aFlag[aScan(aFlag, {|x| Trim(x[1]) == SZQ->ZQ_FLAG })][2]
		cSACDesc := Posicione("SZS", 1, xFilial("SZS")+SZQ->ZQ_NUM, "ZS_PARECER")
		cSACAssu := Posicione("SZR", 1, xFilial("SZR")+SZQ->ZQ_NUM , "ZR_ASSUNTO")
		cSACDAss := AllTrim(Posicione("SX5", 1, xFilial("SX5")+ 'T1' +cSACAssu, "X5_DESCRI"))
		cSACOcor := Posicione("SZR", 1, xFilial("SZR")+SZQ->ZQ_NUM , "ZR_OCORREN")
		cSACDOco := RTRIM(Posicione("SU9", 1, xFilial("SU9")+cSACAssu+cSACOcor,"U9_DESC"))
		nSACCDev := SZQ->ZQ_CUSDEV
		nSACCFrt := SZQ->ZQ_CUSFRE
		nSACCFin := SZQ->ZQ_CUSFIN
		nSACTot  := SZQ->ZQ_CUSDEV + SZQ->ZQ_CUSFRE + SZQ->ZQ_CUSFIN
		cSACPar  := Posicione("SZS", 1, xFilial("SZS")+SZQ->ZQ_NUM, "ZS_PARECER")

		If SZQ->ZQ_FLAG $ 'D/C'
			If SZQ->ZQ_PROCEDE == 'N'
				aItPar   := {"Não Autoriza"}
			Else
				aItPar   := {"Autoriza"}
			End
		Else
			If SZQ->ZQ_PROCEDE == 'N'
				aItPar   := {"Não Procede"}
			Else
				aItPar   := {"Procede"}
			End

			dSACDRes := dDataBase
		Endif

	End

	If nOpc == 2
		cCabec := "Visualização do Atendimento ao Cliente "
	ElseIf nOpc == 3
		cCabec := "Inclusão do Atendimento ao Cliente "
	ElseIf nOpc == 4
		cCabec := "Re-Abertura/Alteração do Atendimento ao Cliente "
	Elseif nOpc == 5
		cCabec := "Exclusão do Atendimento ao Cliente "
	ElseIf nOpc == 6
		cCabec := "Parecer do Atendimento ao Cliente "
	Elseif nOpc == 8
		cCabec := "Encerramento do Atendimento ao Cliente "
	End

	oDlgSAC:=MSDialog():New(070,232,700,1320,cCabec,,,,DS_MODALFRAME,CLR_BLACK,CLR_WHITE,,,.T.)
	//oDlgSAC:=MSDialog():New(aSize[7], aSize[1], aSize[6], aSize[5],cCabec,,,,DS_MODALFRAME,CLR_BLACK,CLR_WHITE,,,.T.)
	// oDlgSAC:=MSDialog():New(a[1], a[2], a[3], a[4],cCabec,,,,DS_MODALFRAME,CLR_BLACK,CLR_WHITE,,,.T.)
	oDlgSAC:lEscClose := .F. //desabilita fechar a janela ao pressinar esc.

	oSACGrp01  := TGroup():New( 004,008,044,528," Dados do SAC ",oDlgSAC,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSay1    := TSay()     :New(016, 016, {||"Numero "}                                  , oSACGrp01,    ,    , .F.      , .F., .F.      , .T.      , CLR_BLACK, CLR_WHITE, 032, 008)
	oSay2    := TSay()     :New(016, 075, {||"Data"}                                     , oSACGrp01,    ,    , .F.      , .F., .F.      , .T.      , CLR_BLACK, CLR_WHITE, 032, 008)
	oSay3    := TSay()     :New(016, 152, {||"Tipo Desconto"}                            , oSACGrp01,    ,    , .F.      , .F., .F.      , .T.      , CLR_BLACK, CLR_WHITE, 048, 008)
	oSay4    := TSay()     :New(016, 270, {||"Tipo SAC"}                                 , oSACGrp01,    ,    , .F.      , .F., .F.      , .T.      , CLR_BLACK, CLR_WHITE, 032, 008)
	oSacNum  := TGet()     :New(024, 016, {|u| If(PCount() > 0 , cSacNum := u, cSacNum)} , oSACGrp01, 040, 010, "@!"     ,    , CLR_BLACK, CLR_WHITE,oFontSubN           ,          ,    , .T.)
	oSACData := TGet()     :New(024, 075, {|u| If(PCount() > 0 , dSACData:= u, dSACData)}, oSACGrp01, 060, 010, '@D'     ,    , CLR_BLACK, CLR_WHITE,oFontSubN           ,          ,    , .T.)
	oTpDesc  := TComboBox():New(024, 152, {|u| If(PCount()>0,cTpDesc:=u,cTpDesc)}        , aItDesc  , 072, 010, oSACGrp01,    ,          ,          , CLR_BLACK, CLR_WHITE, .T.,    , "", , , , , , , 'cTpDesc')
	oTPSac   := TComboBox():New(024, 270, {|u| If(PCount()>0,cTPSac:=u,cTPSac)}          , aItTPSAc , 072, 010, oSACGrp01,    ,          ,          , CLR_BLACK, CLR_WHITE, .T.,    , "", , , , , , , 'cTPSac')

	If cSACStat == '2'
		oSay16     := TSay():New( 016,350,{||"Data encerramento"},oSACGrp01,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008)
		oSay17     := TSay():New( 016,420,{||"Hora Encerramento"},oSACGrp01,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
		oSACDtFn   := TGet():New( 024,350,{|u| If(PCount()>0,dSACDtFim:=u,dSACDtFim)},oSACGrp01,055,010,'',,CLR_BLACK,CLR_WHITE,oFontSubN  ,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","dSACDtFim",,)
		oSACHF     := TGet():New( 024,420,{|u| If(PCount()>0,cSACHF:=u,cSACHF)},oSACGrp01,032,008,'',,CLR_BLACK,CLR_WHITE,oFontSubN  ,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cSACHF",,)
	End

	oSACGrp02  := TGroup():New( 052,008,092,528," Nota Fiscal / Dados Cliente  ",oDlgSAC,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSay5      := TSay():New(064, 016, {||"Nota Fiscal"}                            , oSACGrp02,    ,    , .F., .F., .F.      , .T.      , CLR_BLACK, CLR_WHITE, 032, 008)
	oSay6      := TSay():New(064, 084, {||"Serie"}                                  , oSACGrp02,    ,    , .F., .F., .F.      , .T.      , CLR_BLACK, CLR_WHITE, 032, 008)
	oSay7      := TSay():New(064, 116, {||"Código"}                                 , oSACGrp02,    ,    , .F., .F., .F.      , .T.      , CLR_BLACK, CLR_WHITE, 032, 008)
	oSay8      := TSay():New(064, 170, {||"Loja"}                                   , oSACGrp02,    ,    , .F., .F., .F.      , .T.      , CLR_BLACK, CLR_WHITE, 032, 008)
	oSay9      := TSay():New(064, 200, {||"Nome"}                                   , oSACGrp02,    ,    , .F., .F., .F.      , .T.      , CLR_BLACK, CLR_WHITE, 032, 008)
	oSay10     := TSay():New(064, 376, {||"Fone(s)"}                                , oSACGrp02,    ,    , .F., .F., .F.      , .T.      , CLR_BLACK, CLR_WHITE, 032, 008)
	oSay16     := TSay():New(064, 440, {||"Contato"}                                , oSACGrp02,    ,    , .F., .F., .F.      , .T.      , CLR_BLACK, CLR_WHITE, 032, 008)
	oSACNF     := TGet():New(072, 016, {|u| If(PCount()>0,cSACNF:=u,cSACNF)}        , oSACGrp02, 060, 008, '' ,    , CLR_BLACK, CLR_WHITE,oFontSubN           ,          ,    , .T., "", , , .F., .F., , .F., .F., "", "cSACNF"    , ,)
	oSACSeri   := TGet():New(072, 084, {|u| If(PCount()>0,cSacSeri:=u,cSacSeri)}    , oSACGrp02, 024, 008, '' ,    , CLR_BLACK, CLR_WHITE,oFontSubN           ,          ,    , .T., "", , , .F., .F., , .F., .F., "", "cSacSeri"  , ,)
	oSACClie   := TGet():New(072, 116, {|u| If(PCount()>0,cSACClie:=u,cSACClie)}    , oSACGrp02, 050, 008, '' ,    , CLR_BLACK, CLR_WHITE,oFontSubN           ,          ,    , .T., "", , , .F., .F., , .F., .F., "", "cSACClie"  , ,)
	oSACLj     := TGet():New(072, 170, {|u| If(PCount()>0,cSACLj:=u,cSACLj)}        , oSACGrp02, 016, 008, '' ,    , CLR_BLACK, CLR_WHITE,oFontSubN           ,          ,    , .T., "", , , .F., .F., , .F., .F., "", "cSACLj"    , ,)
	oSACNome   := TGet():New(072, 200, {|u| If(PCount()>0,cSACNome:=u,cSACNome)}    , oSACGrp02, 172, 008, '' ,    , CLR_BLACK, CLR_WHITE,oFontSubN           ,          ,    , .T., "", , , .F., .F., , .F., .F., "", "cSACNome"  , ,)
	oSACFone   := TGet():New(072, 376, {|u| If(PCount()>0,cSACFone:=u,cSACFone)}    , oSACGrp02, 060, 008, '' ,    , CLR_BLACK, CLR_WHITE,oFontSubN           ,          ,    , .T., "", , , .F., .F., , .F., .F., "", "cSACFone"  , ,)
	oSACCont   := TGet():New(072, 440, {|u| If(PCount()>0,cSACCont:=u,cSACCont)}    , oSACGrp02, 060, 008, '' ,    , CLR_BLACK, CLR_WHITE,oFontSubN           ,          ,    , .T., "", , , .F., .F., , .F., .F., "", "cSACCont", ,)

	oSACGrp03 := TGroup():New( 100,008,204,528," Dados Atendimento ",oDlgSAC,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSay11    := TSay():New(112, 016, {||"Atendente"}                            , oSACGrp03,    ,    , .F., .F., .F.      , .T.      , CLR_BLACK, CLR_WHITE, 032, 008)
	oSay12    := TSay():New(112, 090, {||"Hora Inicio"}                          , oSACGrp03,    ,    , .F., .F., .F.      , .T.      , CLR_BLACK, CLR_WHITE, 032, 008)
	oSay13    := TSay():New(112, 144, {||"Anexo"}                                , oSACGrp03,    ,    , .F., .F., .F.      , .T.      , CLR_BLACK, CLR_WHITE, 032, 008)
	oSay14    := TSay():New(112, 180, {||"Assunto"}                              , oSACGrp03,    ,    , .F., .F., .F.      , .T.      , CLR_BLACK, CLR_WHITE, 032, 008)
	oSay15    := TSay():New(112, 310, {||"Ocorrencia"}                           , oSACGrp03,    ,    , .F., .F., .F.      , .T.      , CLR_BLACK, CLR_WHITE, 032, 008)
	oSACAten  := TGet():New(120, 016, {|u| If(PCount()>0,cSAcAtend:=u,cSAcAtend)}, oSACGrp03, 070, 008, '' ,    , CLR_BLACK, CLR_WHITE,oFontSubN           ,          ,    , .T., "", , , .F., .F., , .F., .F., "", "cSAcAtend", ,)
	oSACHI    := TGet():New(120, 090, {|u| If(PCount()>0,cSACHI:=u,cSACHI)}      , oSACGrp03, 040, 008, '' ,    , CLR_BLACK, CLR_WHITE,oFontSubN           ,          ,    , .T., "", , , .F., .F., , .F., .F., "", "cSACHI"   , ,)
	oSACAnex  := TGet():New(120, 144, {|u| If(PCount()>0,cSACAnex:=u,cSACAnex)}  , oSACGrp03, 024, 008, '' ,    , CLR_BLACK, CLR_WHITE,oFontSubN           ,          ,    , .T., "", , , .F., .F., , .F., .F., "", "cSACAnex" , ,)
	oSACAssu  := TGet():New(120, 180, {|u| If(PCount()>0,cSACAssu:=u,cSACAssu)}  , oSACGrp03, 028, 008, '' ,    , CLR_BLACK, CLR_WHITE,oFontSubN           ,          ,    , .T., "", , , .F., .F., , .F., .F., "", "cSACAssu" , ,)
	oSACDAss  := TGet():New(120, 220, {|u| If(PCount()>0,cSACDAss:=u,cSACDAss)}  , oSACGrp03, 070, 008, '' ,    , CLR_BLACK, CLR_WHITE,oFontSubN           ,          ,    , .T., "", , , .F., .F., , .F., .F., "", "cSACDAss" , ,)
	oSACOcor  := TGet():New(120, 310, {|u| If(PCount()>0,cSACOcor:=u,cSACOcor)}  , oSACGrp03, 028, 008, '' ,    , CLR_BLACK, CLR_WHITE,oFontSubN           ,          ,    , .T., "", , , .F., .F., , .F., .F., "", "cSACOcor" , ,)
	oSACDOco  := TGet():New(120, 350, {|u| If(PCount()>0,cSACDOco:=u,cSACDOco)}  , oSACGrp03, 144, 008, '' ,    , CLR_BLACK, CLR_WHITE,oFontSubN           ,          ,    , .T., "", , , .F., .F., , .F., .F., "", "cSACDOco" , ,)
	oSACGrp04 := TGroup():New( 136,016,200,520," Descritivo Ocorrência /  Problema ",oSACGrp03,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSACDesc  := TMultiGet():New( 144,018,{|u| If(PCount()>0,cSACDesc:=u,cSACDesc)},oSACGrp04,496,052,oFontSubN,,CLR_BLACK,CLR_WHITE,,.T.,"Descreva a ocorrência",,,.F.,.F.,.F.,,,.F.,,  )

	If nOpc == 3
		oSACFld    := TFolder():New( 212,008,{"Itens"},{},oDlgSAC,,,,.T.,.F.,520,076,)
	Else

		oSay18     := TSay():New( 290,012,{||"Status"},oDlgSAC,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay19     := TSay():New( 290,088,{||"Responsavel"},oDlgSAC,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

		oSACStat   := TGet():New( 296,012,{|u| If(PCount()>0,cSACStat:=u,cSACStat)},oDlgSAC,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cSACStat",,)
		oSACResp   := TGet():New( 296,088,{|u| If(PCount()>0,cSACResp:=u,cSACResp)},oDlgSAC,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cSACResp",,)

		If SZQ->ZQ_STATUS=='1'
			oSay20     := TSay():New( 290,170,{||"Situação"},oDlgSAC,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
			oSACFlag   := TGet():New( 298,170,{|u| If(PCount()>0,cSACFlag:=u,cSACFlag)},oDlgSAC,100,008,'',,CLR_BLACK,CLR_WHITE,oFontSubN,          ,    , .T., "", , , .F., .F., , .F., .F., "", "cSACFlag",,)
		End
		oSACFld    := TFolder():New( 212,008,{"Itens","Custos","Diagnóstico / Solução","Histórico","Resumo"},{},oDlgSAC,,,,.T.,.F.,520,076,)

		//Folder 02 -  Custos
		oSay22   := TSay():New(004, 004, {||"Custo Devolucao"}                    , oSACFld:ADIALOGS[2],    ,    , .F., .F., .F.      , .T.      , CLR_BLACK, CLR_WHITE, 052, 008)
		oSay23   := TSay():New(004, 072, {||"Custo Frete"}                        , oSACFld:ADIALOGS[2],    ,    , .F., .F., .F.      , .T.      , CLR_BLACK, CLR_WHITE, 032, 008)
		oSay24   := TSay():New(004, 136, {||"Custo Financeiro"}                   , oSACFld:ADIALOGS[2],    ,    , .F., .F., .F.      , .T.      , CLR_BLACK, CLR_WHITE, 060, 008)
		oSay25   := TSay():New(004, 200, {||"Custo Total"}                        , oSACFld:ADIALOGS[2],    ,    , .F., .F., .F.      , .T.      , CLR_BLACK, CLR_WHITE, 032, 008)
		oSACCDev := TGet():New(012, 004, {|u| If(PCount()>0,nSACCDev:=u,nSACCDev)}, oSACFld:ADIALOGS[2], 060, 008, '' ,    , CLR_BLACK, CLR_WHITE,          ,          ,    , .T., "", , , .F., .F., , .F., .F., "", "nSACCDev", ,)
		oSACCFrt := TGet():New(012, 072, {|u| If(PCount()>0,nSACCFrt:=u,nSACCFrt)}, oSACFld:ADIALOGS[2], 060, 008, '' ,    , CLR_BLACK, CLR_WHITE,          ,          ,    , .T., "", , , .F., .F., , .F., .F., "", "nSACCFrt", ,)
		oSACCFin := TGet():New(012, 136, {|u| If(PCount()>0,nSACCFin:=u,nSACCFin)}, oSACFld:ADIALOGS[2], 060, 008, '' ,    , CLR_BLACK, CLR_WHITE,          ,          ,    , .T., "", , , .F., .F., , .F., .F., "", "nSACCFin", ,)
		oSACTot  := TGet():New(012, 200, {|u| If(PCount()>0,nSACTot:=u,nSACTot)}  , oSACFld:ADIALOGS[2], 060, 008, '' ,    , CLR_BLACK, CLR_WHITE,          ,          ,    , .T., "", , , .F., .F., , .F., .F., "", "nSACTot" ,)

		//Folder 03 -  Diagnostico/Solucao
		oSay26   := TSay()     :New(044, 005, {||"Data Resposta"}                      , oSACFld:ADIALOGS[3],    ,    , .F.              , .F., .F.      , .T.      , CLR_BLACK, CLR_WHITE, 044                                        , 008)
		oSay27   := TSay()     :New(044, 115, {||"Parecer"}                            , oSACFld:ADIALOGS[3],    ,    , .F.              , .F., .F.      , .T.      , CLR_BLACK, CLR_WHITE, 032                                        , 008)
		oSACPar  := TMultiGet():New(003, 005, {|u| If(PCount()>0,cSACPar:=u,cSACPar)}  , oSACFld:ADIALOGS[3], 516, 035,                  ,    , CLR_BLACK, CLR_WHITE,          , .T.      , "Informe o Parecer/Resposta do Atendimento",    ,   , .F., .F., .F.,    , , .F.,    ,)
		oSACDRes := TGet()     :New(044, 050, {|u| If(PCount()>0,dSACDRes:=u,dSACDRes)}, oSACFld:ADIALOGS[3], 060, 008, ''               ,    , CLR_BLACK, CLR_WHITE,          ,          ,                                            , .T., "",    ,    , .F., .F., , .F., .F., "", "dSACDRes", ,)
		oSACOPar := TComboBox():New(044, 150, {|u| If(PCount()>0,cTpRePar:=u,cTpRePar)}, aItPar             , 072, 010, oSACFld:ADIALOGS[3],    ,          ,          , CLR_BLACK, CLR_WHITE, .T.,    , "", , , , , , ,'cTpRePar')

	End

	// Folder 01 -  Itens - Valid para INclusao e alteração
	fGetDadSAC()

	If nOpc <> 2
		oBtnOk   := TButton():New(296, 492, "Confrma" , oDlgSAC, {|| N_fGrvSAC(nOpc)}        , 037, 012, , , , .T., , "", , , , .F.)
		oBtnCanc := TButton():New(296, 432, "Sair"    , oDlgSAC, bSair                       , 037, 012, , , , .T., , "", , , , .F.)
	Else
		oBtnCanc := TButton():New(296, 492, "Sair"    , oDlgSAC, {|| oDlgSac:End()}          , 037, 012, , , , .T., , "", , , , .F.)
	End
	If nOpc == 3
		oSACClie:bValid :={|| fNValClie(cSACClie,"")}
		oSACLj:bValid   :={|| fNValClie(cSACClie,cSACLj)}
		oSACNF:bValid   :={|| fNValNota(cSACNF) }
		oSACClie:cF3 := "SA1"
		oSACNF:cF3   := "SF2"
	Else
		oSACData:bWhen :={||.F.}
		oSACNF:bWhen   :={||.F.}
		oSACSeri:bWhen :={||.F.}
		oSACClie:bWhen :={||.F.}
		oSACLj:bWhen   :={||.F.}
		oSACNome:bWhen :={||.F.}
		oSACFone:bWhen :={||.F.}
		oSACCont:bWhen :={||.F.}
		oSACAten:bWhen :={||.F.}
		oSACHI:bWhen   :={||.F.}
		oSACOPar:bWhen :={||.F.}
	End

	oSACOcor:cF3 := "SU9"
	oSACAssu:cF3 := "T1"

	oSACOcor:bValid :={|| fNValOcorr(cSACOcor) }
	oSACAssu:bValid :={|| fNValAssun(cSACAssu) }

	oSacNum:bWhen    :={||.F.}
	oSACDtFim:bWhen  :={||.F.}
	oSACHF:bWhen     :={||.F.}
	oSACNum :bWhen   :={||.F.}
	oSACDAss:bWhen   :={||.F.}
	oSACDOco:bWhen   :={||.F.}
	oSACNome:bWhen   :={||.F.}
	oSACStat:bWhen   :={||.F.}
	oSACResp:bWhen   :={||.F.}
	oSACFlag:bWhen   :={||.F.}

	oDlgSAC:Activate(,,,.T.)

Return (NIL)

/*/{Protheus.doc} fGetDadSAC
dMontagem do browse de dados de produto do SAC
@type function Tela
@version 1.00
@author marioantonaccio
@since 24/06/2026
@return character, sem retorno
/*/
Static Function fGetDadSAC()
	// Variaveis deste Form
	Local nX			:= 0
	// Vetor responsavel pela montagem da aHeader
	Local aCpoGDa       	:= {"ZR_SEQITEM","ZR_PRODUTO","ZR_DESCPRO","ZR_QTD","ZR_QTDORIG","ZR_QAPRRET","ZR_PEDIDO","ZR_NUMNF","ZR_SERNF","ZR_VUORI","ZR_VTORI","ZR_LOTE","ZR_DTVALID","ZR_QTDPRO","ZR_RETEN","ZR_ITEMDEV","ZR_ITEMORI","ZR_QTDABAT"}
	// Vetor com os campos que poderao ser alterados
	Local aAlter       	:= {"ZR_PRODUTO","ZR_QTD","ZR_QAPRRET","ZR_LOTE","ZR_QTDABAT"}
	Local nSuperior    	:= C(004)           // Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
	Local nEsquerda    	:= C(004)           // Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
	Local nInferior    	:= C(060)           // Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
	Local nDireita     	:= C(500)           // Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
	// Posicao do elemento do vetor aRotina que a MsNewGetDados usara como referencia
	Local nOpc         	:=  Iif(nOpc == 2 .or. nOpc == 6, 0, Iif(nOpc == 4 .and. SZQ->ZQ_FLAG $ 'A/M', GD_INSERT+GD_DELETE+GD_UPDATE, GD_INSERT+GD_DELETE+GD_UPDATE))
	Local cLinOk       	:= "AllwaysTrue"    // Funcao executada para validar o contexto da linha atual do aCols
	Local cTudoOk      	:= "AllwaysTrue"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
	Local cIniCpos     	:= "+ZR_SEQITEM"     // Nome dos campos do tipo caracter que utilizarao incremento automatico.
	// Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do segundo campo>+..."
	Local nFreeze      	:= 001              // Campos estaticos na GetDados.
	Local nMax         	:= 999              // Numero maximo de linhas permitidas. Valor padrao 99
	Local cFieldOk     	:= "AllwaysTrue"    // Funcao executada na validacao do campo
	Local cSuperDel     	:= ""              // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
	Local cDelOk        	:= "AllwaysTrue"   // Funcao executada para validar a exclusao de uma linha do aCols
	// Objeto no qual a MsNewGetDados sera criada
	Local oWnd          	:= oSACFld:ADIALOGS[1]         // Geralmente e passado o Dialog que contem a GetDados, mas pode ser qualquer objeto.
	Local aHead        	:= {}               // Array a ser tratado internamente na MsNewGetDados como aHeader
	Local aCol         	:= {}               // Array a ser tratado internamente na MsNewGetDados como aCols

	// Carrega aHead
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2)) // Campo
	For nX := 1 to Len(aCpoGDa)
		If SX3->(DbSeek(aCpoGDa[nX]))
			Aadd(aHead,{ AllTrim(X3Titulo()),;
				SX3->X3_CAMPO	,;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID	,;
				SX3->X3_USADO	,;
				SX3->X3_TIPO	,;
				SX3->X3_F3 		,;
				SX3->X3_CONTEXT,;
				SX3->X3_CBOX	,;
				SX3->X3_RELACAO})
		Endif
	Next nX
	// Carregue  a Montagem da sua aCol
	aAux := {}
	If nOpc == 3
		For nX := 1 to Len(aCpoGDa)
			If DbSeek(aCpoGDa[nX])
				Aadd(aAux,CriaVar(SX3->X3_CAMPO))
			Endif
		Next nX
		Aadd(aAux,.F.)
		Aadd(aCol,aAux)
		aCols[1][1]:="01"
	Else
		//aCpoGDa       	:= {"ZR_SEQITEM","ZR_PRODUTO","ZR_DESCPRO","ZR_QTD","ZR_QTDORIG","ZR_QAPRRET","ZR_PEDIDO","ZR_NUMNF","ZR_SERNF","ZR_VUORI","ZR_VTORI","ZR_LOTE","ZR_DTVALID","ZR_QTDPRO","ZR_RETEN","ZR_ITEMDEV","ZR_ITEMORI","ZR_QTDABAT"}
		SZR->(dbSetorder(1))
		If SZR->(dbSeek( xFilial("SZR")+SZQ->ZQ_NUM))
			While .NOT. SZR->(EOF()) .and. SZR->ZR_NUM == SZQ->ZQ_NUM
				aAux := {}
				For nX := 1 to Len(aCpoGDa)
					If nX == 3
						Aadd(aAux,Posicione("SB1", 1, xFilial("SB1")+SZR->ZR_PRODUTO, "B1_DESC"))
					Else
						Aadd(aAux,SZR->(FieldGet((FieldPos(aCpoGDa[nX])))))
					Endif
				Next nX
				Aadd(aAux,.F.)
				Aadd(aCol,aAux)

				SZR->(DbSkip())
			End
		End

	End

	oGetDadSAC:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,;
		aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oWnd,aHead,aCol)

Return Nil



/*/{Protheus.doc} FGrEspRel
Geração e relatorio espelho para o cliente emitir a NF
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 17/07/2026
@return character, sem retono
/*/
Static Function FGrEspRel()

   Local oDlg       := NIL       as Object
   Private aTotNota := {}        as Array
   Private cTitulo  := ""        as character
   Private nLastKey := 0         as numeric
   Private nLinha   := 0         as Nuneric
   Private nomeProg := FunName() as character
   Private nPag     := 1         as numeric
   Private nSubTot  := 0         as numeric
   Private nTotal   := 0         as numeric
   Private oFont1   := NIL       as Object
   Private oFont2   := NIL       as Object
   Private oFont3   := NIL       as Objject
   Private oFont4   := NIL       as Object
   Private oFont5   := NIL       as Object
   Private oFont6   := NIL       as Object
   Private oPrn     := NIL       as Object
   Private titulo   := ""        as character
   Private wnrel    := FunName() as character

   DEFINE FONT oFont1 NAME "Times New Roman" SIZE 0,20 BOLD  OF oPrn
   DEFINE FONT oFont2 NAME "Times New Roman" SIZE 0,14 BOLD OF oPrn
   DEFINE FONT oFont3 NAME "Times New Roman" SIZE 0,14 OF oPrn
   DEFINE FONT oFont4 NAME "Times New Roman" SIZE 0,14 ITALIC OF oPrn
   DEFINE FONT oFont5 NAME "Times New Roman" SIZE 0,14 OF oPrn
   DEFINE FONT oFont6 NAME "Courier New" BOLD

   cTitulo := "Impressão Espelho de Nota (SAC)"
   oFont08  := TFont():New("Arial", 08, 08, , .F., , , , .T., .F.)
   oFont08N := TFont():New("Arial", 08, 08, , .T., , , , .T., .F.)
   oFont10  := TFont():New("Arial", 10, 10, , .F., , , , .T., .F.)
   oFont11  := TFont():New("Arial", 11, 11, , .F., , , , .T., .F.)
   oFont14  := TFont():New("Arial", 14, 14, , .F., , , , .T., .F.)
   oFont16  := TFont():New("Arial", 16, 16, , .F., , , , .T., .F.)
   oFont10N := TFont():New("Arial", 10, 10, , .T., , , , .T., .F.)
   oFont12  := TFont():New("Arial", 10, 10, , .F., , , , .T., .F.)
   oFont12N := TFont():New("Arial", 10, 10, , .T., , , , .T., .F.)
   oFont16N := TFont():New("Arial", 16, 16, , .T., , , , .T., .F.)
   oFont14N := TFont():New("Arial", 14, 14, , .T., , , , .T., .F.)
   oFont06  := TFont():New("Arial", 06, 06, , .F., , , , .T., .F.)
   oFont06N := TFont():New("Arial", 06, 06, , .T., , , , .T., .F.)

   nLastKey  := If(LastKey() == 27,27,nLastKey)

   If nLastKey == 27
      Return (NIL)
   Endif

   oPrn := TMSPrinter():New(cTitulo)

   //oPrn:SetPortrait()
   //oPrn:Setup()
   oPrn:SetLandscape() //SetPortrait()
   oPrn:StartPage()
   FGrEspR01()
   oPrn:EndPage()
   oPrn:End()

   DEFINE MSDIALOG oDlg FROM 264,182 TO 441,613 TITLE cTitulo OF oDlg PIXEL
   @ 004,010 TO 082,157 LABEL "" OF oDlg PIXEL

   @ 015,017 SAY "Esta rotina tem por objetivo imprimir"	OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE
   @ 030,017 SAY "o impresso customizado:"					OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE
   @ 045,017 SAY "Espelho de Nota (SAC)" 						OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE

   @ 06,167 BUTTON "&Imprime" 		SIZE 036,012 ACTION oPrn:Print()   	OF oDlg PIXEL
   @ 28,167 BUTTON "Pre&view" 		SIZE 036,012 ACTION oPrn:Preview() 	OF oDlg PIXEL
   @ 49,167 BUTTON "Sai&r"    		SIZE 036,012 ACTION oDlg:End()     	OF oDlg PIXEL
   //@ 70,167 BUTTON "Conf.&Impres" 	SIZE 036,012 ACTION oPrn:Setup()    OF oDlg PIXEL

   ACTIVATE MSDIALOG oDlg CENTERED

   oPrn:End()

Return (NIL)
/*/{Protheus.doc} FGrEspR01
Chamda de geração do relatorio
@type function Processamento
@version  1.0
@author marioantonaccio
@since 17/07/2026
@return character, sem retorno
/*/
STATIC FUNCTION FGrEspR01()

   FGrEspR02()
   Ms_Flush()

Return (NIL)

/*/{Protheus.doc} FGrEspR02
Geração do relatorio
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 17/07/2026
@return character, sem retorno
*/
Static Function FGrEspR02()

   Local cBitMap :="" as character
   Local nLinha:= 0 as numeric
   Local nPag  := 1 as numeric

   BeginSQL ALIAS "TCR"
      SELECT
         ROUND(SUM(SZR.ZR_QTD * SD2.D2_PRCVEN), 2) AS VALPROD,
         ROUND(SUM(SD2.D2_BASEICM /(SD2.D2_QUANT / SZR.ZR_QTD)), 2) AS BICMS,
         ROUND(SUM(SD2.D2_VALICM /(SD2.D2_QUANT / SZR.ZR_QTD)), 2) AS VALICMS,
         ROUND(SUM(SD2.D2_BASEIPI /(SD2.D2_QUANT / SZR.ZR_QTD)), 2) AS BIPI,
         ROUND(SUM(SD2.D2_VALIPI /(SD2.D2_QUANT / SZR.ZR_QTD)), 2) AS VALIPI,
         ROUND(SUM(SD2.D2_BRICMS /(SD2.D2_QUANT / SZR.ZR_QTD)), 2) AS BST,
         ROUND(SUM(SD2.D2_ICMSRET /(SD2.D2_QUANT / SZR.ZR_QTD)), 2) AS VALST,
         ROUND(SUM(SD2.D2_VALFRE /(SD2.D2_QUANT / SZR.ZR_QTD)), 2) AS VALFRE,
         ROUND(
            SUM(SZR.ZR_QTD * SD2.D2_PRCVEN) + SUM(SD2.D2_VALIPI /(SD2.D2_QUANT / SZR.ZR_QTD)) + SUM(SD2.D2_ICMSRET /(SD2.D2_QUANT / SZR.ZR_QTD)),
            2
         ) AS TOTNOTA,
         SUM(SZR.ZR_QTD * SB1.B1_PESBRU) AS PESOBR
      FROM
         %TABLE:SD2% SD2
      INNER JOIN %TABLE:SB1% SB1
      ON SD2.D2_COD = SB1.B1_COD
         AND SD2.D2_FILIAL = SB1.B1_FILIAL
         AND SB1.%NOTDEL%
         LEFT OUTER JOIN %TABLE:SZR% SZR
      ON SZR.ZR_FILIAL = SD2.D2_FILIAL
         AND SZR.ZR_NUMNF = SD2.D2_DOC
         AND SZR.ZR_SERNF = SD2.D2_SERIE
         AND SZR.ZR_PRODUTO = SD2.D2_COD
         AND SZR.ZR_ITEMORI = SD2.D2_ITEM
         AND SZR.ZR_NUM = %EXP:cGet1Sac%
         AND SZR.ZR_QTD > 0
         AND SZR.%NOTDEL%
      WHERE
         SD2.%NOTDEL%
         AND SD2.D2_FILIAL = %XFILIAL:SD2%
   ENDSQL

   AADD(aTotNota,TCR->VALPROD)
   AADD(aTotNota,TCR->VALICMS)
   AADD(aTotNota,TCR->VALIPI)
   AADD(aTotNota,TCR->VALST)
   AADD(aTotNota,TCR->BICMS)
   AADD(aTotNota,TCR->BIPI)
   AADD(aTotNota,TCR->BST)
   AADD(aTotNota,TCR->TOTNOTA)
   AADD(aTotNota,TCR->PESOBR)
   AADD(aTotNota,TCR->VALFRE)

   TCR->(dbCloseArea())

   oPrn:StartPage()
   cBitMap := ""
   fLogoEmp(@cBitMap)
   oPrn:SayBitmap(035,0035,cBitMap,100,60)			// Imprime logo da Empresa: comprimento X altura

   //Linha Inicial Identificação
   oPrn:Box(0030,0015,0100,3270)
   oPrn:Say(0050,0500,OemToAnsi("* RELATÓRIO DE SUGESTÃO PARA AUXILIO NA EMISSÃO DE NOTA FISCAL DE DEVOLUÇÃO *"),oFont14N)
   oPrn:Say(0050,2750,"Data: "+cValToChar(dDataBase),oFont14N)
   oPrn:Say(0050,3150,"Pag:: "+cValtoChar(nPag),oFont08)

   oPrn:Say(0130,0025,OemToAnsi("Dados SAC"),oFont14N)

   oPrn:Box(0180,0015,0300,3270)

   oPrn:Say(0200,0025,OemToAnsi("SAC No.")		,oFont12,,,, PAD_LEFT)
   oPrn:Say(0200,0150,OemToAnsi("Cliente")		,oFont12,,,, PAD_LEFT)
   oPrn:Say(0200,1010,OemToAnsi("Emissao")		,oFont12,,,, PAD_LEFT)
   oPrn:Say(0200,1225,OemToAnsi("Valor Prod.")	,oFont12,,,, PAD_LEFT)
   oPrn:Say(0200,1445,OemToAnsi("Valor ICMS ")	,oFont12,,,, PAD_LEFT)
   oPrn:Say(0200,1625,OemToAnsi("Valor IPI  ")	,oFont12,,,, PAD_LEFT)
   oPrn:Say(0200,1825,OemToAnsi("Valor ST   ")	,oFont12,,,, PAD_LEFT)
   oPrn:Say(0200,2025,OemToAnsi("Base ICMS  ")	,oFont12,,,, PAD_LEFT)
   oPrn:Say(0200,2225,OemToAnsi("Base IPI   ")	,oFont12,,,, PAD_LEFT)
   oPrn:Say(0200,2425,OemToAnsi("Base ST    ")	,oFont12,,,, PAD_LEFT)
   oPrn:Say(0200,2625,OemToAnsi("Total NF   ")	,oFont12,,,, PAD_LEFT)
   oPrn:Say(0200,2825,OemToAnsi("Peso Total ")	,oFont12,,,, PAD_LEFT)
   oPrn:Say(0200,3025,OemToAnsi("Frete      ")	,oFont12,,,, PAD_LEFT)

   oPrn:Say(0250,0025,OemToAnsi(cGet1Sac) ,oFont12N,,,,PAD_LEFT)
   oPrn:Say(0250,0150,OemToAnsi(cGet4Sac) ,oFont12N,,,,PAD_LEFT)
   oPrn:Say(0250,1010,cValToChar(dDataBase) ,oFont12N,,,,PAD_LEFT)
   oPrn:Say(0250,1200,Transform(aTotNota[01],"@ER 999,999,999.99") ,oFont12N,,,,PAD_LEFT)
   oPrn:Say(0250,1400,Transform(aTotNota[02],"@ER 999,999,999.99") ,oFont12N,,,,PAD_LEFT)
   oPrn:Say(0250,1600,Transform(aTotNota[03],"@ER 999,999,999.99") ,oFont12N,,,,PAD_LEFT)
   oPrn:Say(0250,1800,Transform(aTotNota[04],"@ER 999,999,999.99") ,oFont12N,,,,PAD_LEFT)
   oPrn:Say(0250,2000,Transform(aTotNota[05],"@ER 999,999,999.99") ,oFont12N,,,,PAD_LEFT)
   oPrn:Say(0250,2200,Transform(aTotNota[06],"@ER 999,999,999.99") ,oFont12N,,,,PAD_LEFT)
   oPrn:Say(0250,2400,Transform(aTotNota[07],"@ER 999,999,999.99") ,oFont12N,,,,PAD_LEFT)
   oPrn:Say(0250,2600,Transform(aTotNota[08],"@ER 999,999,999.99") ,oFont12N,,,,PAD_LEFT)
   oPrn:Say(0250,2800,Transform(aTotNota[09],"@ER 999,999,999.9999") ,oFont12N,,,,PAD_LEFT)
   oPrn:Say(0250,3000,Transform(aTotNota[10],"@ER 999,999,999.99") ,oFont12N,,,,PAD_LEFT)

   oPrn:Say(0320,0025,"Dados para Emissão da NF"						,oFont14N)

   oPrn:Box(0380,0015,2700,3270)

   oPrn:Say(0400,0025,OemToAnsi("Cliente")						,oFont12,,,PAD_LEFT)
   oPrn:Say(0450,0025,OemToAnsi(SM0->M0_NOMECOM)				,oFont14N,,,PAD_LEFT)
   oPrn:Say(0450,1010,"("+RTrim(OemToAnsi(SM0->M0_FILIAL))+")"	,oFont12N,,,PAD_LEFT)

   oPrn:Say(0520,0025,OemToAnsi("Endereco ")					,oFont12,,,PAD_LEFT)
   oPrn:Say(0520,1010,OemToAnsi("Bairro   ")					,oFont12,,,PAD_LEFT)
   oPrn:Say(0520,1800,OemToAnsi("Municipio")					,oFont12,,,PAD_LEFT)
   oPrn:Say(0520,2300,OemToAnsi("Estado   ")					,oFont12,,,PAD_LEFT)
   oPrn:Say(0520,2700,OemToAnsi("CEP      ")					,oFont12,,,PAD_LEFT)

   oPrn:Say(0570,0025,OemToAnsi(SM0->M0_ENDENT)				,oFont12N,,,PAD_LEFT)
   oPrn:Say(0570,1010,OemToAnsi(SM0->M0_BAIRENT)				,oFont12N,,,PAD_LEFT)
   oPrn:Say(0570,1800,OemToAnsi(SM0->M0_CIDENT)				,oFont12N,,,PAD_LEFT)
   oPrn:Say(0570,2300,OemToAnsi(SM0->M0_ESTENT)				,oFont12N,,,PAD_LEFT)
   oPrn:Say(0570,2700,Transform(SM0->M0_CEPENT,"@R 99999-999")	,oFont12N,,,PAD_LEFT)

   oPrn:Say(0620,0025,"CNPJ"				,oFont12,,,PAD_LEFT)
   oPrn:Say(0620,1010,"Inscricao Estadual"	,oFont12,,,PAD_LEFT)
   oPrn:Say(0620,1800,"Telefone"			,oFont12,,,PAD_LEFT)

   oPrn:Say(0670,0025,Transform(Alltrim(SM0->M0_CGC),"@R 99.999.999/9999-99")	,oFont12N,,,PAD_LEFT)
   oPrn:Say(0670,1010,Transform(Alltrim(SM0->M0_INSC),"@R 999.999.999.999")	,oFont12N,,,PAD_LEFT)
   oPrn:Say(0670,1800,OemToAnsi(SM0->M0_TEL)									,oFont12N,,,PAD_LEFT)

   //Linha de cabecalho de Itens
   oPrn:BOX(0720,0015,0790,3270)

   oPrn:Say(0735,0025,"Codigo" ,oFont12N,,,PAD_LEFT)
   oPrn:Say(0735,0340,"Descricao" ,oFont12N,,,PAD_LEFT)
   oPrn:Say(0735,1030,"NCM" ,oFont12N,,,PAD_LEFT)
   oPrn:Say(0735,1260,"CST" ,oFont12N,,,PAD_LEFT)
   oPrn:Say(0735,1345,"CFOP" ,oFont12N,,,PAD_LEFT)
   oPrn:Say(0735,1445,"Qtd Devolv" ,oFont12N,,,PAD_LEFT)
   oPrn:Say(0735,1650,"Vlr Unitario" ,oFont12N,,,PAD_LEFT)
   oPrn:Say(0735,1880,"Vlr.Total" ,oFont12N,,,PAD_LEFT)
   oPrn:Say(0735,2100,"% ICMS" ,oFont12N,,,PAD_LEFT)
   oPrn:Say(0735,2250,"Vlr ICMS" ,oFont12N,,,PAD_LEFT)
   oPrn:Say(0735,2480,"% IPI" ,oFont12N,,,PAD_LEFT)
   oPrn:Say(0735,2600,"Vlr Ipi" ,oFont12N,,,PAD_LEFT)
   oPrn:Say(0735,2850,"NF Original" ,oFont12N,,,PAD_LEFT)
   oPrn:Say(0735,3050,"Serie Orig." ,oFont12N,,,PAD_LEFT)

   BeginSQL Alias "TCQ"
      SELECT
         SD2.D2_COD AS COD,
         SD2.D2_PRCVEN AS PRCVEN,
         SD2.D2_POSIPI AS NCM,
         SD2.D2_CLASFIS AS CST,
         SD2.D2_CF AS CFOP,
         SZR.ZR_QTD AS QTDPRET,
         ROUND(SZR.ZR_QTD * SD2.D2_PRCVEN, 2) AS VALPROD,
         ROUND((SD2.D2_BASEICM /(SD2.D2_QUANT / SZR.ZR_QTD)), 2) AS BICMS,
         ROUND((SD2.D2_BASEIPI /(SD2.D2_QUANT / SZR.ZR_QTD)), 2) AS BIPI,
         ROUND((SD2.D2_VALICM /(SD2.D2_QUANT / SZR.ZR_QTD)), 2) AS VALICM,
         ROUND((SD2.D2_VALIPI /(SD2.D2_QUANT / SZR.ZR_QTD)), 2) AS VALIPI,
         SD2.D2_PICM AS PICM,
         SD2.D2_IPI AS PIPI,
         RTRIM(ISNULL(SZ1.Z1_DESCR, '')) + ' - ' + RTRIM(SB1.B1_DESC) + ' ' + ISNULL(SZ5.Z5_DESCR, '') AS DESCRICAO,
         SD2.D2_DOC AS NUMNF,
         SD2.D2_SERIE AS SERIE
      FROM
         %TABLE:SZR% SZR
         LEFT OUTER JOIN %TABLE:SD2% SD2
      ON SD2.D2_FILIAL = %XFILIAL:SD2%
         AND SZR.ZR_NUMNF = SD2.D2_DOC
         AND SZR.ZR_SERNF = SD2.D2_SERIE
         AND SZR.ZR_PRODUTO = SD2.D2_COD
         AND SZR.ZR_ITEMORI = SD2.D2_ITEM
         AND SD2.D_E_L_E_T_ = ' '
         LEFT OUTER JOIN SB1010 SB1
      ON SB1.B1_FILIAL = %XFILIAL:SB1%
         AND SZR.ZR_PRODUTO = SB1.B1_COD
         AND SB1.D_E_L_E_T_ = ' '
         LEFT OUTER JOIN SZ5010 SZ5
      ON SZ5.Z5_FILIAL = %XFILIAL:SZ5%
         AND SUBSTRING(SD2.D2_COD, 11, 2) = SZ5.Z5_EMB
         AND SZ5.D_E_L_E_T_ = ' '
         LEFT OUTER JOIN SZ1010 SZ1
      ON SZ1.Z1_FILIAL = %XFILIAL:SZ1%
         AND SUBSTRING(SZR.ZR_PRODUTO, 4, 2) = SZ1.Z1_LINHA
         AND SZ1.D_E_L_E_T_ = ' '
      WHERE
         SZR.D_E_L_E_T_ = ' '
         AND SZR.ZR_FILIAL = %XFILIAL:SZR%
         AND SZR.ZR_NUM = %EXP:cGet1Sac%
      ORDER BY
         SZR.ZR_SEQITEM
   ENDSQL

   nLinha:=810
   While .NOT. TCQ->(EOF())
      oPrn:Say(nLinha,0025,TCQ->COD ,oFont12,,,PAD_LEFT)
      oPrn:Say(nLinha,0340,Substr(TCQ->DESCRICAO,1,35) ,oFont12,,,PAD_LEFT)
      oPrn:Say(nLinha,1030,TCQ->NCM ,oFont12,,,PAD_LEFT)
      oPrn:Say(nLinha,1260,TCQ->CST ,oFont12,,,PAD_LEFT)
      oPrn:Say(nLinha,1345,TCQ->CFOP ,oFont12,,,PAD_LEFT)
      oPrn:Say(nLinha,1445,Transform(TCQ->QTDPRET ,"@ER 999,999,999.99") ,oFont12,,,PAD_LEFT)
      oPrn:Say(nLinha,1650,Transform(TCQ->PRCVEN ,"@ER 999,999,999.99") ,oFont12,,,PAD_LEFT)
      oPrn:Say(nLinha,1880,Transform(TCQ->VALPROD ,"@ER 999,999,999.99") ,oFont12,,,PAD_LEFT)
      oPrn:Say(nLinha,2100,Transform(TCQ->PICM ,"@ER 99.99") ,oFont12,,,PAD_LEFT)
      oPrn:Say(nLinha,2250,Transform(TCQ->VALICM ,"@ER 999,999,999.99") ,oFont12,,,PAD_LEFT)
      oPrn:Say(nLinha,2480,Transform(TCQ->PIPI ,"@ER 99.99") ,oFont12,,,PAD_LEFT)
      oPrn:Say(nLinha,2600,Transform(TCQ->VALIPI ,"@ER 999,999,999.99") ,oFont12,,,PAD_LEFT)
      oPrn:Say(nLinha,2850,TCQ->NUMNF ,oFont12,,,PAD_LEFT)
      oPrn:Say(nLinha,3050,TCQ->SERIE ,oFont12,,,PAD_LEFT)

      LINHA(nLinha)

      oPrn:Line(nLinha,0015,nLinha,3270,,"-2")

      LINHA(@nLinha)

      TCQ->(dbSkip())
   End

   TCQ->(dbCloseArea())

   oPrn:Line(nLinha,0015,nLinha,3270,,"-4")

   LINHA(@nLinha)
   oPrn:Say(nLinha,0015,OemToAnsi("Base Calculo ICMS: ")				,oFont12,,,PAD_LEFT)
   oPrn:Say(nLinha,1030,OemToAnsi("Valor do ICMS: ")					,oFont12,,,PAD_LEFT)
   oPrn:Say(nLinha,1880,OemToAnsi("Base Calc ICMS Substit.:")			,oFont12,,,PAD_LEFT)
   oPrn:Say(nLinha,2500,OemToAnsi("Valor ICMS SUbstituicao: ")			,oFont12,,,PAD_LEFT)

   oPrn:Say(nLinha,0315,Transform(aTotNota[05],"@ER 999,999,999.99")	,oFont12N,,,PAD_RIGHT)
   oPrn:Say(nLinha,1330,Transform(aTotNota[02],"@ER 999,999,999.99")	,oFont12N,,,PAD_RIGHT)
   oPrn:Say(nLinha,2180,Transform(aTotNota[07],"@ER 999,999,999.99")	,oFont12N,,,PAD_RIGHT)
   oPrn:Say(nLinha,2800,Transform(aTotNota[04],"@ER 999,999,999.99")	,oFont12N,,,PAD_RIGHT)

   LINHA(@nLinha)

   oPrn:Say(nLinha,0015,OemToAnsi("Valor Frete: ")						,oFont12,,,PAD_LEFT)
   oPrn:Say(nLinha,1030,OemToAnsi("Valor IPI: ")						,oFont12,,,PAD_LEFT)
   oPrn:Say(nLinha,1880,OemToAnsi("Valor Total NF: ")					,oFont14N,,,PAD_LEFT)
   oPrn:Say(nLinha,2500,OemToAnsi("Peso Bruto Total: ")				,oFont12,,,PAD_LEFT)

   oPrn:Say(nLinha,0315,Transform(aTotNota[10]	,"@ER 999,999,999.99")	,oFont12N,,,PAD_LEFT)
   oPrn:Say(nLinha,1330,Transform(aTotNota[03]	,"@ER 999,999,999.99")	,oFont12N,,,PAD_LEFT)
   oPrn:Say(nLinha,2180,Transform(aTotNota[08]	,"@ER 999,999,999.99")	,oFont12N,,,PAD_LEFT)
   oPrn:Say(nLinha,2800,Transform(aTotNota[09]	,"@ER 999,999,999.9999"),oFont12N,,,PAD_LEFT)

   LINHA(@nLinha)
   LINHA(@nLinha)
   LINHA(@nLinha)

   cTExto:=" - ESTE RELATÓRIO NÃO EXCLUI NECESSIDADE DE EMITIR NOTA FISCAL DE ACORDO C/ PARTICULARIDADES FISCAIS DE SUA EMPRESA"+CRLF

   oPrn:Say(nLinha,0030,"Atencao:"	,oFont16N)
   LINHA(@nLinha)
   LINHA(@nLinha)
   oPrn:Say(nLinha,0030,OemToAnsi(cTExto),oFont14N)
   LINHA(@nLinha)
   LINHA(@nLinha)
   oPrn:Say(nLinha,0030,OemToAnsi("Favor Informar na Nota Fiscal o nosso numero de SAC: "+cGet1Sac),oFont14N)

   oPrn:EndPage()

  // oPrn:Setup()
  // oPrn:Preview()

   MS_FLUSH()
Return


/*/{Protheus.doc} EnvMail
Envio de email do relatorio]
@type function Processamento
@version  1.00
@author marioantonaccio
@since 17/07/2026
@param cAnexo, character, arquivo que sera anexado ao email
@param cNumPed, character, numero do pedido
@param cPara, character, endereco de email do destinatario
@param cContato, character, nome do contato
@param mCorpo, variant, corpo do email
@return character, sme retorno

Static Function EnvMail(cAnexo,cNumPed,cPara,cContato,mCorpo)
	Private cAssunto     := 'Relatorio SAC - No. ' + cNumPed
	Private nLineSize    := 60
	Private nTabSize     := 3
	Private lWrap        := .T.
	Private nLine        := 0
	Private cTexto       := ""
	Private lServErro	   := .T.
	Private cServer  := Trim(GetMV("MV_RELSERV")) // smtp.tecnotron.ind.br
	Private cDe 	:= Trim(GetMV("MV_RELACNT"))
	Private cPass    := Trim(GetMV("MV_RELPSW"))  //
	Private lAutentic	:= GetMv("MV_RELAUTH",,.F.)
	Private aTarget  :={cAnexo}
	Private nTarget := 0
	Private lCheck1 := .F.
	Private lCheck2 := .f.

	cCC := UsrRetMail(RetCodUsr())
	cAnexos:=cAnexo
	CPYT2S(cAnexos,GetSrvProfString("Startpath", "")+'emailanexos\',.T.)
	cAnexos:=GetSrvProfString("Startpath", "")+'emailanexos\'+SubStr(AllTrim(cAnexos),RAT('\',AllTrim(cAnexos))+1)
	lServERRO 	:= .F.

	CONNECT SMTP                         ;
		SERVER 	 GetMV("MV_RELSERV"); 	// Nome do servidor de e-mail
		ACCOUNT  GetMV("MV_RELACNT"); 	// Nome da conta a ser usada no e-mail
		PASSWORD GetMV("MV_RELPSW") ; 	// Senha
		Result lConectou

	lRet := .f.
	lEnviado := .f.
	If lAutentic
		lRet := Mailauth(cDe,cPass)
	Endif
	If lRet
		cPara   := Rtrim(cPara)
		cCC		:= Rtrim(cCC)
		cAssunto:= Rtrim(cAssunto)

		//	    	    BCC 'diretoria@metalacre.com.br;gerencia@metalacre.com.br';

		SEND MAIL 	FROM cDe ;
			To cPara ;
			CC cCc;
			SUBJECT	cAssunto ;
			Body mCorpo;
			ATTACHMENT cAnexos;
			RESULT lEnviado

		DISCONNECT SMTP SERVER
	Endif
	If !lConectou .Or. !lEnviado
		cMensagem := ""
		GET MAIL ERROR cMensagem
		Alert(cMensagem)
	Endif
	FERASE(cAnexos)

Return (NIL)
*/

/*/{Protheus.doc} LINHA
Incremntador de somatorio de linha de impressao
@type function Processamento
@version  1.00
@author marioantonaccio
@since 17/07/2026
@param nLinha, numeric, numero da linha posicionda
@return Numeric, novo numero de linha
/*/
Static Function LINHA(nLinha)

   If nLinha > 2500
      oPrn:EndPage()
      nPag++
      oPrn:StartPage()
      cBitMap := ""
      fLogoEmp(@cBitMap)
      oPrn:SayBitmap(035,0035,cBitMap,100,60)			// Imprime logo da Empresa: comprimento X altura

      //Linha Inicial Identificação
      oPrn:Box(0030,0015,0100,3270)

      oPrn:Say(0050,0550,OemToAnsi("* RELATÓRIO DE SUGESTÃO PARA AUXILIO NA EMISSÃO DE NOTA FISCAL DE DEVOLUÇÃO *"),oFont14N)
      oPrn:Say(0050,2800,"Data: "+cValToChar(dDataBase),oFont14N)
      oPrn:Say(0050,3180,"Pag:: "+cValtoChar(nPag),oFont08)

      oPrn:Say(0130,0025,OemToAnsi("Dados SAC"),oFont14N)

      oPrn:Box(0180,0015,0300,3270)

      oPrn:Say(0200,0025,OemToAnsi("SAC No.")		,oFont12,,,, PAD_LEFT)
      oPrn:Say(0200,0150,OemToAnsi("Cliente")		,oFont12,,,, PAD_LEFT)
      oPrn:Say(0200,1010,OemToAnsi("Emissao")		,oFont12,,,, PAD_LEFT)
      oPrn:Say(0200,1225,OemToAnsi("Valor Prod.")	,oFont12,,,, PAD_LEFT)
      oPrn:Say(0200,1445,OemToAnsi("Valor ICMS ")	,oFont12,,,, PAD_LEFT)
      oPrn:Say(0200,1625,OemToAnsi("Valor IPI  ")	,oFont12,,,, PAD_LEFT)
      oPrn:Say(0200,1825,OemToAnsi("Valor ST   ")	,oFont12,,,, PAD_LEFT)
      oPrn:Say(0200,2025,OemToAnsi("Base ICMS  ")	,oFont12,,,, PAD_LEFT)
      oPrn:Say(0200,2225,OemToAnsi("Base IPI   ")	,oFont12,,,, PAD_LEFT)
      oPrn:Say(0200,2425,OemToAnsi("Base ST    ")	,oFont12,,,, PAD_LEFT)
      oPrn:Say(0200,2625,OemToAnsi("Total NF   ")	,oFont12,,,, PAD_LEFT)
      oPrn:Say(0200,2825,OemToAnsi("Peso Total ")	,oFont12,,,, PAD_LEFT)
      oPrn:Say(0200,3025,OemToAnsi("Frete      ")	,oFont12,,,, PAD_LEFT)

      oPrn:Say(0250,0025,OemToAnsi(cGet1Sac)								,oFont12N,,,,PAD_LEFT)
      oPrn:Say(0250,0150,OemToAnsi(cGet4Sac)								,oFont12N,,,,PAD_LEFT)
      oPrn:Say(0250,1010,cValToChar(dDataBase)							,oFont12N,,,,PAD_LEFT)
      oPrn:Say(0250,1200,Transform(aTotNota[01],"@ER 999,999,999.99")		,oFont12N,,,,PAD_LEFT)
      oPrn:Say(0250,1400,Transform(aTotNota[02],"@ER 999,999,999.99")		,oFont12N,,,,PAD_LEFT)
      oPrn:Say(0250,1600,Transform(aTotNota[03],"@ER 999,999,999.99")		,oFont12N,,,,PAD_LEFT)
      oPrn:Say(0250,1800,Transform(aTotNota[04],"@ER 999,999,999.99")		,oFont12N,,,,PAD_LEFT)
      oPrn:Say(0250,2000,Transform(aTotNota[05],"@ER 999,999,999.99")		,oFont12N,,,,PAD_LEFT)
      oPrn:Say(0250,2200,Transform(aTotNota[06],"@ER 999,999,999.99")		,oFont12N,,,,PAD_LEFT)
      oPrn:Say(0250,2400,Transform(aTotNota[07],"@ER 999,999,999.99")		,oFont12N,,,,PAD_LEFT)
      oPrn:Say(0250,2600,Transform(aTotNota[08],"@ER 999,999,999.99")		,oFont12N,,,,PAD_LEFT)
      oPrn:Say(0250,2800,Transform(aTotNota[09],"@ER 999,999,999.9999")	,oFont12N,,,,PAD_LEFT)
      oPrn:Say(0250,3000,Transform(aTotNota[10],"@ER 999,999,999.99")		,oFont12N,,,,PAD_LEFT)

      oPrn:Say(0320,0025,"Dados para Emissão da NF"						,oFont14N)

      oPrn:Box(0380,0015,3400,3270)

      oPrn:Say(0400,0025,OemToAnsi("Cliente")						,oFont12,,,PAD_LEFT)
      oPrn:Say(0450,0025,OemToAnsi(SM0->M0_NOMECOM)				,oFont14N,,,PAD_LEFT)
      oPrn:Say(0450,1010,"("+RTrim(OemToAnsi(SM0->M0_FILIAL))+")"	,oFont12N,,,PAD_LEFT)

      oPrn:Say(0520,0025,OemToAnsi("Endereco ")					,oFont12,,,PAD_LEFT)
      oPrn:Say(0520,1010,OemToAnsi("Bairro   ")					,oFont12,,,PAD_LEFT)
      oPrn:Say(0520,1800,OemToAnsi("Municipio")					,oFont12,,,PAD_LEFT)
      oPrn:Say(0520,2300,OemToAnsi("Estado   ")					,oFont12,,,PAD_LEFT)
      oPrn:Say(0520,2700,OemToAnsi("CEP      ")					,oFont12,,,PAD_LEFT)

      oPrn:Say(0570,0025,OemToAnsi(SM0->M0_ENDENT)				,oFont12N,,,PAD_LEFT)
      oPrn:Say(0570,1010,OemToAnsi(SM0->M0_BAIRENT)				,oFont12N,,,PAD_LEFT)
      oPrn:Say(0570,1800,OemToAnsi(SM0->M0_CIDENT)				,oFont12N,,,PAD_LEFT)
      oPrn:Say(0570,2300,OemToAnsi(SM0->M0_ESTENT)				,oFont12N,,,PAD_LEFT)
      oPrn:Say(0570,2700,Transform(SM0->M0_CEPENT,"@R 99999-999")	,oFont12N,,,PAD_LEFT)

      oPrn:Say(0620,0025,"CNPJ"				,oFont12,,,PAD_LEFT)
      oPrn:Say(0620,1010,"Inscricao Estadual"	,oFont12,,,PAD_LEFT)
      oPrn:Say(0620,1800,"Telefone"			,oFont12,,,PAD_LEFT)

      oPrn:Say(0670,0025,Transform(Alltrim(SM0->M0_CGC),"@R 99.999.999/9999-99")	,oFont12N,,,PAD_LEFT)
      oPrn:Say(0670,1010,Transform(Alltrim(SM0->M0_INSC),"@R 999.999.999.999")	,oFont12N,,,PAD_LEFT)
      oPrn:Say(0670,1800,OemToAnsi(SM0->M0_TEL)									,oFont12N,,,PAD_LEFT)

      //Linha de cabecalho de Itens
      oPrn:Box(0720,0015,0770,3270)
      oPrn:Say(0735,0025,"Codigo"  	    ,oFont12N,,,PAD_LEFT)
      oPrn:Say(0735,0340,"Descricao"	    ,oFont12N,,,PAD_LEFT)
      oPrn:Say(0735,1030,"NCM"   	        ,oFont12N,,,PAD_LEFT)
      oPrn:Say(0735,1260,"CST"  	        ,oFont12N,,,PAD_LEFT)
      oPrn:Say(0735,1345,"CFOP"	        ,oFont12N,,,PAD_LEFT)
      oPrn:Say(0735,1445,"Qtd a Devolver" ,oFont12N,,,PAD_LEFT)
      oPrn:Say(0735,1650,"Vlr Unitario"	,oFont12N,,,PAD_LEFT)
      oPrn:Say(0735,1880,"Vlr.Total"  	,oFont12N,,,PAD_LEFT)
      oPrn:Say(0735,2100,"% ICMS"         ,oFont12N,,,PAD_LEFT)
      oPrn:Say(0735,2250,"Vlr ICMS"       ,oFont12N,,,PAD_LEFT)
      oPrn:Say(0735,2480,"% IPI" 	        ,oFont12N,,,PAD_LEFT)
      oPrn:Say(0735,2600,"Vlr Ipi"   	    ,oFont12N,,,PAD_LEFT)
      oPrn:Say(0735,2850,"NF Original"    ,oFont12N,,,PAD_LEFT)
      oPrn:Say(0735,3010,"Serie Orig."    ,oFont12N,,,PAD_LEFT)
      //oPrn:Line(0780,0015,0780,3270,,"-4")
      nLinha:=810
   Else
      nLinha+=50
   End
Return (nLinha)
