#include 'totvs.ch'
#include 'fwmvcdef.ch'
#INCLUDE "FWLIBVERSION.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"       
#INCLUDE "FWADAPTEREAI.CH"     

/*/{Protheus.doc} ZFATF01
Liberação de Pedidos de Vendas
@type function
@version  v.2021.001
@author Luís Gustavo de Souza
@since 27/09/2021
/*/
User Function ZFATA01() 
     Private _cRotUsu := FunName() + Space( TAMSX3('ZW_ROTINA')[1] - Len( FunName() ) )
     //Local _oVision := getVisions()
     Private aRotina As ARRAY
     Private cRotina As String
     Private aHeader As ARRAY
     Private aCols   As ARRAY
     Private cString As String
     Public aHeader  As Array
     Public aCols    As Array
     Public cCodUsr   := RetCodUsr()
     Public lAdmin    := .f.
     Public cAcesso   := ""
     Public lAcsVis   := .f.
     Public lAcsCad   := .f.
     Public lAcsPed   := .f.
     Public lAcsCre   := .f.
     Public lAcsDir   := .f.
     Public lAcsOut   := .f.
     Public _oLibCad, _oLibPed, _oLibCre, _oLibDir, _oLibRec
     Public _oUsrCad, _oUsrPed, _oUsrCre, _oUsrDir, _oUsrRec
     Public _lLibCad  := .F., _lLibPed := .F., _lLibCre := .F., _lLibDir := .F., _lLibRec := .F.
     Public _cUsrCad  := '' , _cUsrPed := '' , _cUsrCre := '' , _cUsrDir := '' , _cUsrRec := ''
     Public _cRestri  := ""
     Public _oRestri
     Public _oObsMsg, _oObserv
     Public _cObsMsg, _cObserv
     Public bHistorico
     Public bItensPedi
     Public bDadosPedi
     Public bPlanilhaF
     Public bTitAberto
     Public bTitRecebi
     Public bDadosClie
     Public bObservPed
     Public bPesquisaP
     Public _oPriCom, _oUltCom, _oRisco, _oAltera, _oVenda
     Public _cPriCom, _cUltCom, _cRisco, _cAltera, _cVenda
     Public _aTotal := {}
     Public _aItens := {}
     Public _aPedidos := {}

     Default cFilDef    := ""
     Default aAddFil    := {}
     Default cVDefault  := ""

     /****************************************************************************************************/
     /***                                     VERIFICAÇÃO DE ACESSO                                    ***/
     lAdmin := ( PSWADMIN( cUsername, SubStr( cUsuario, 1, 6), cCodUsr ) == 0 )
     If lAdmin
        cAcesso := '*****   * '		
     Else
        DbSelectArea("SZW")
        DbSetOrder(4)
        DbSeek(xFilial("SZW") + _cRotUsu + cCodUsr + SUBSTR(cNumEmp,1,2) + SUBSTR( cNumEmp, FWSizeFilial() + 1, 2 ), .t. )
        If Found()
           cAcesso := SZW->ZW_ACESSOS
        Else
           MessageBox( "Usuário não autorizado!!! Entre em contato com o administrador do sistema", "Atenção", 48 )
           Return
        Endif 
     EndIf
     If !Empty( cAcesso )
        lAcsVis := Iif(SubStr(cAcesso, 1, 1) == '*', .t., .f.) // Itens a serem liberados por vendas.
        lAcsCad := Iif(SubStr(cAcesso, 2, 1) == '*', .t., .f.) // Itens a serem liberados por vendas.
        lAcsPed := Iif(SubStr(cAcesso, 3, 1) == '*', .t., .f.) // Itens a serem liberados por vendas.
        lAcsCre := Iif(SubStr(cAcesso, 4, 1) == '*', .t., .f.) // Itens a serem liberados pelo crédito
        lAcsDir := Iif(SubStr(cAcesso, 5, 1) == '*', .t., .f.) // Itens a serem liberados pela diretoria
        lAcsOut := Iif(SubStr(cAcesso, 6, 1) == '*', .t., .f.) // Outros pedidos a serem Liberados.
     Else
        MessageBox( "Usuário não autorizado!!! Entre em contato com o administrador do sistema", "Atenção", 48 )
        Return
     Endif
     /*************************?***************************************************************************/
     aRotina := {}
     aHeader := {}
     aCols   := {}
     cString := "SC5"

     u_zcfga01( "ZFATA01" )

     BrowseDef( /*oMBrowse*/, cFilDef, aAddFil, cVDefault )
Return Nil

Static Function BrowseDef( oMBrowse, cFilDef, aAddFil, cVDefault )
       Local cFilSQL	:= Nil
       Local oTableAtt	:= Nil
       Local nX		:= 0
       Local nScan		:= 0
       Local lWidget	:= .F.
       Local aCores 	:=	{ { "Empty(C5_LIBEROK).And.Empty(C5_NOTA) .And. Empty(C5_BLQ)", 'ENABLE'    , "Pedido em Aberto"          },;
                                { "!Empty(C5_NOTA).Or.C5_LIBEROK=='E' .And. Empty(C5_BLQ)"  , 'DISABLE'   , "Pedido Encerrado"          },;
                                { "!Empty(C5_LIBEROK).And.Empty(C5_NOTA).And. Empty(C5_BLQ)", 'BR_AMARELO', "Pedido Liberado"           },;
                                { "C5_BLQ == '1'"                                           , 'BR_AZUL'   , "Pedido Bloquedo por regra" },;
                                { "C5_BLQ == '2'"                                           , 'BR_LARANJA', "Pedido Bloquedo por verba" } }
       Local nColor		:= 0
       Local nQtdCorNew	:= 0
       Local nTamCorNew	:= 0
       Local aCoresNew	:= {}
       Local lOKMa410Cor	:= .T.

       Default oMBrowse		:= Nil
       Default cFilDef		:= ""
       Default aAddFil		:= {}
       Default cVDefault		:= ""
			
       If cPaisLoc <> "BRA"
          aAdd(aCores,{})
          Ains(aCores,1)
          aCores[1] := { "AllTrim(C5_NOTA)=='REMITO'", "BR_CINZA", "Remito" }
       Endif       

       //Ponto de Entrada para alterar cores do Browse do Cadastro
       If ExistBlock("MA410COR")
          aCoresNew	:= ExecBlock("MA410COR",.F.,.F.,aCores)

          // Para manter a compatibilidade do ponto de entrada com as versões mais antigas cujo array das cores possuíam apenas 2 posições,
          // e não 3 como ?no caso das versões da 12 em diante...
          nQtdCorNew	:= Len(aCoresNew)
          If ValType(aCoresNew) == "A" .AND. nQtdCorNew > 0
             For nColor := 1 to nQtdCorNew
                 If ValType(aCoresNew[nColor]) == "A"
                    nTamCorNew	:= Len(aCoresNew[nColor])
                    If nTamCorNew	== 2
                       aAdd(aCoresNew[nColor], "")
                    ElseIf nTamCorNew == 3
                           If ValType(aCoresNew[nColor,3]) <> "C" // Caso o Ponto de entrada não retorne a Legenda, Manda em Branco
                              aCoresNew[nColor,3]	:= ""
                           EndIf
                    Else 
                       lOKMa410Cor	:= .F.
                       EXIT
                    EndIf
                 Else
                    lOKMa410Cor	:= .F.
                    EXIT
                 EndIf
             Next nColor
          Else
             lOKMa410Cor	:= .F.
          EndIf
          If lOKMa410Cor
             aCores	:= aClone(aCoresNew)
             aSize(aCoresNew,0)
          Else
             MsgStop( "Não foi possível carregar as cores da legenda customizada! Verifique retorno do ponto entrada MA410COR" )
          EndIf
       Endif
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //?Endereca a funcao de BROWSE                          ?
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       If ExistTemplate("MT410BRW")
          ExecTemplate("MT410BRW",.F.,.F.)
       EndIf

       If ExistBlock("MT410BRW")
          ExecBlock("MT410BRW",.F.,.F.)
       EndIf

       If Empty( oMBrowse )
          oMBrowse := FWMBrowse():New()
          oMBrowse:SetAlias( "SC5" )			
       Else
          lWidget := .T.
       EndIf

       If nModulo == 73 .And. ( IsInCallStack("CRMA290") .OR. IsInCallStack("CRMA290A") .Or. IsInCallStack( "CA290CWDGT" ) )
          oMBrowse:SetCanSaveArea(.T.) 
       EndIf

       If ExistBlock("M410FSQL")	// Filtro SQL na MBrowser
          cFilSQL := ExecBlock("M410FSQL",.F.,.F.)
          If !Empty( cFilSQL ) 
             oMBrowse:AddFilter( "Filtro do Ponto de Entrada - M410FSQL", cFilSQL, .T., .T., "SC5", , , "SC5_FILENT" )		 
             oMBrowse:ExecuteFilter()
          EndIf	
       EndIf
       //Adiciona a legenda
       For nX := 1 To Len( aCores )
           oMBrowse:AddLegend( aCores[nX][1], aCores[nX][2], aCores[nX][3] )
       Next nX

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //?Filtro Default do Browse                  ?
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
       If !Empty( cFilDef )
          oMBrowse:SetFilterDefault( cFilDef )
       EndIf

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
       //?Filtros adicionais do Browse                           ?
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       For nX := 1 To Len( aAddFil )
           oMBrowse:DeleteFilter( aAddFil[nX][ADDFIL_ID] )
           oMBrowse:AddFilter( aAddFil[nX][ADDFIL_TITULO]   ,;
                               aAddFil[nX][ADDFIL_EXPR]     ,;
                               aAddFil[nX][ADDFIL_NOCHECK]  ,;
                               aAddFil[nX][ADDFIL_SELECTED] ,;
                               aAddFil[nX][ADDFIL_ALIAS]    ,;
                               aAddFil[nX][ADDFIL_FILASK]   ,;
                               aAddFil[nX][ADDFIL_FILPARSER],;
                               aAddFil[nX][ADDFIL_ID]        )		 
           oMBrowse:ExecuteFilter()	
       Next nX
       oMBrowse:SetDescription( "Liberação de Pedidos Vendas" )
       If !lWidget
          //Adiciona as visões e gráficos
          oTableAtt := TableAttDef()
          oMBrowse:SetAttach(.T.)	
          oMBrowse:SetViewsDefault(oTableAtt:aViews)
          oMBrowse:SetChartsDefault(oTableAtt:aCharts)

          // selecionando a visão inicial 
          If !Empty( cVDefault ) 
             nScan := aScan( oTableAtt:aViews, { |x| x:cID == cVDefault } )
             If nScan > 0 
                oMBrowse:SetIDViewDefault( oTableAtt:aViews[nScan]:cID )
             EndIf
          EndIf

          oMBrowse:SetIDChartDefault( "DSTotVend" )

          //Se não for SIGACRM inibe a exibição do gráfico
          If nModulo <> 73
             oMBrowse:SetOpenChart( .F. )
          EndIf
          oMBrowse:SetMainProc("MATA410")
          oMBrowse:SetTotalDefault( 'C5_FILIAL', 'COUNT', 'Total de Registros' )
          oMBrowse:Activate()
       EndIf			

/*
     _oBrowse := FWMBrowse():New()
     _oBrowse:SetAlias( 'SC5' )
     _oBrowse:SetUseFilter( .T. )
     _oBrowse:SetAttach( .T. )
     _oBrowse:lOptionConfig := .f.
     _oBrowse:lOptionReport := .f.
     //_oBrowse:SetViewsDefault( _oVision:aViews )
     _oBrowse:SetDescription( "Liberação de Pedidos Vendas" )

     //Desligado a exibição dos detalhes
     _oBrowse:DisableDetails()

     //Adiciona legenda de cores
     _oBrowse:AddLegend( "C5_APROVA == '0' .and. C5_LIBCAD == 'F' .and. C5_LIBPED == 'F' .and. C5_LIBCRE == 'F' .and. C5_LIBDIR == 'F'", "RED"  , "Analise de Cadastro"     )
     _oBrowse:AddLegend( "C5_APROVA == '0' .and. C5_LIBCAD == 'T' .and. C5_LIBPED == 'F' .and. C5_LIBCRE == 'F' .and. C5_LIBDIR == 'F'", "GRAY" , "Analise de Vendas"       )
     _oBrowse:AddLegend( "C5_APROVA == '0' .and. C5_LIBCAD == 'T' .and. C5_LIBPED == 'T' .and. C5_LIBCRE == 'F' .and. C5_LIBDIR == 'F'", "PINK" , "Analise de Crédito"      )
     _oBrowse:AddLegend( "C5_APROVA == '0' .and. C5_LIBCAD == 'T' .and. C5_LIBPED == 'T' .and. C5_LIBCRE == 'T' .and. C5_LIBDIR == 'F'", "BLUE" , "Analise da Diretoria"    )
     _oBrowse:AddLegend( "C5_APROVA == '1' .and.  EMPTY(C5_NOTA)"                                                                      , 'BROWN', "Aprovado e não faturado" )
     _oBrowse:AddLegend( "C5_APROVA == '1' .and. !EMPTY(C5_NOTA)"                                                                      , 'GREEN', "Aprovado e faturado"     )
     _oBrowse:AddLegend( "C5_APROVA == '2'"                                                                                            , 'BLACK', "Recusado"                )

     //Ativação da Classe
     _oBrowse:SetMainProc("MATA410")
     _oBrowse:Activate()
*/
Return

/*/{Protheus.doc} MenuDef
Menu principal do FWMBrowse com as opções padrões e particulares para o log do apontamento de produção.
@type function
@version v.2021.001
@author Luís Gustavo de Souza
@since 27/09/2021
@return Array, Retorna o aRotina com as opções do menu.
/*/
Static Function MenuDef()
       Local aRotina   := {}
       Local _cAcsLog  := GETMV( 'ZP_PAR0035' )
       Local _cAcsCal  := GETMV( 'ZP_PAR0036' )
       Local _cCodUsr  := Iif( Type( 'cCodUsr' ) == 'U', '', cCodUsr )
       Local _lValUsr  := PSWADMIN( cUsername, SubStr( cUsuario, 1, 6), _cCodUsr ) == 0

       ADD OPTION aRotina TITLE "Visualizar"                   ACTION "U_ZFAT01Vi( )"            OPERATION 2 ACCESS 0
       ADD OPTION aRotina TITLE "Liberação"                      ACTION "U_ZFAT01Li( )"          OPERATION 9 ACCESS 0
       If __CUSERID $ '000000.000071' .or. _lValUsr
          ADD OPTION aRotina TITLE "Acessos"                     ACTION "U_SENA01(_cRotUsu)"     OPERATION 9 ACCESS 0
       Endif
       If _cCodUsr $_cAcsLog
          ADD OPTION aRotina TITLE "Log de liberação Automática" ACTION "U_ZFAT01Lo( )"          OPERATION 9 ACCESS 0
       Endif
       If _cCodUsr $ _cAcsCal
          ADD OPTION aRotina TITLE "Memória de Calculo" ACTION "U_ZFAT01Ca( )"                   OPERATION 9 ACCESS 0
       Endif

Return aRotina
User function ZFAT01Ca()
     Local _cPedido   := SC5->C5_NUM
     Local oModal
     Local oContainer
     Local _aButtons  := {}

     oModal := FWDialogModal():New()
     oModal:SetEscClose( .F. )
     oModal:setTitle( "Log de Liberação automática do pedido de Vendas" )
     oModal:setSize( 141, 268 )
     oModal:createDialog()

     aAdd( _aButtons, { "", 'Cancela' , {|| _nOpcAju := 0, oModal:DeActivate() }, , , .T., .F. } )
     oModal:addButtons( _aButtons )

     oContainer := TPanel():New( ,,, oModal:getPanelMain() ) 
     oContainer:Align := CONTROL_ALIGN_ALLCLIENT

     oModal:Activate()

Return

User Function ZFAT01Lo()
     Local _cPedido   := SC5->C5_NUM
     Local _aFiles    := Directory( "\dirdoc\comercial\libped\" + FWxFilial("SC5") + "_" + _cPedido+'*.log', , , , 2 )
     Local _nY
     Local _cLinLib   := ""
     Local oModal
     Local oContainer
     Local _aButtons  := {}

     If Len( _aFiles ) > 0
        For _nY := 1 to Len( _aFiles )
            _cLinLib += MemoRead( "\dirdoc\comercial\libped\" + _aFiles[_nY][1] )
            _cLinLib += Chr(13) + Chr(10)
            _cLinLib += Replicate( "-", 80 ) 
            _cLinLib += Chr(13) + Chr(10)
        Next

        oModal := FWDialogModal():New()
        oModal:SetEscClose( .F. )
        oModal:setTitle( "Log de Liberação automática do pedido de Vendas" )
        oModal:setSize( 141, 268 )
        oModal:createDialog()

        aAdd( _aButtons, { "", 'Cancela' , {|| _nOpcAju := 0, oModal:DeActivate() }, , , .T., .F. } )
        oModal:addButtons( _aButtons )

       oContainer := TPanel():New( ,,, oModal:getPanelMain() ) 
       oContainer:Align := CONTROL_ALIGN_ALLCLIENT

        _oGetDObs    := tMultiGet():new( 002, 002, {| u | If( pCount() > 0, _cLinLib := u, _cLinLib ) }, oContainer, 260,  92, , , , , , .T., , , , , , .T. )
        oModal:Activate()
     Else
        MessageBox( 'Pedido sem log de liberação', 'Log de liberação', 64 )
     Endif
Return

/*/{Protheus.doc} ModelDef
Modelo da Tela principal do log dos apontamentos de produção
@type function
@version v.2021.001
@author Luís Gustavo de Souza
@since 27/09/2020
@return Object, Objeto com o modelo principal
/*/
Static Function ModelDef()
       Local oModel  as Object
       Local oStrSC5 as Object 

       oStrSC5 := FWFormStruct( 1, "SC5" )
       oModel  := MPFormModel():New( "ORDENS" )
       oModel:SetDescription( "Visualiza Cabeçalho de Pedidos" )
       oModel:addFields( 'MASTERSC5', , oStrSC5 )
       oModel:SetPrimaryKey({'C5_FILIAL', 'C5_NUM'})
       oModel:getModel('MASTERSC5'):SetDescription('Dados do Pedido')
       
Return oModel

/*/{Protheus.doc} ViewDef
View da Tela principal do log dos apontamentos de produção
@type function
@version v.2021.001
@author Luís Gustavo de Souza
@since 27/09/2020
@return Object, Objeto com a view principal
/*/
Static Function ViewDef()
       Local oModel  As Object
       Local oView   As Object
       Local oStrSC5 As Object
       Local _MVLIBPEDE := GETMV( "MV_LIBPEDE" )

       If !( ( SubStr( cNumEmp, 1, 2 ) + SubStr( cNumEmp, FWSizeFilial() + 1, 2) ) $ _MVLIBPEDE )
          MessageBox( "Empresa/Filial não autorizada a utilizar essa rotina !", "Atenção...", 48 )
          Return
       Endif

       oModel := ModelDef()
       oStrSC5:= FWFormStrutct( 2, "SC5" )
       oView  := FWFormView():New()
       oView:SetModel( oModel )
       oView:AddField( "VIEW_ORDENS", oStrSC5, "MASTERSC5" )
       oView:CreateHorizontalBox("SUPERIOR", 100)
       oView:SetOwnerView( "VIEW_ORDENS", "SUPERIOR" )

Return oView

/*/{Protheus.doc} ZFAT01Vi
Visualização do pedido de Vendas
@type function
@version  v2021.001
@author Luis Gustavo de Souza
@since 27/09/2021
/*/
User Function ZFAT01Vi()
     Local aArea       := GetArea()                 //Irei gravar a area atual
     Private Inclui    := .F.                       //defino que a inclusão é falsa
     Private Altera    := .T.                       //defino que a alteração é verdadeira
     Private nOpca     := 1                         //obrigatoriamente passo a variavel nOpca com o conteudo 1
     Private cCadastro := "Pedido de Vendas"        //obrigatoriamente preciso definir com private a variável cCadastro
     Private aRotina   := {}                        //obrigatoriamente preciso definir a variavel aRotina como private

     MatA410( Nil, Nil, Nil, Nil, "A410Visual" ) //executo a função padrão MatA410

     RestArea( aArea )                               //restauro a area anterior.
Return

/*/{Protheus.doc} ZFAT01Li
Liberação do pedido de Vendas
@type function
@version  v2021.001
@author Luis Gustavo de Souza
@since 27/09/2021
/*/
User Function ZFAT01Li()
     Local nOpc
     Local _cTitulo    := "Liberar"
     Local _cPrograma  := 'ZFATA02'
     Local _nOperation := MODEL_OPERATION_VIEW //MODEL_OPERATION_UPDATE

     nOpc := FWExecView( _cTitulo , _cPrograma, _nOperation, /*oDlg*/, {|| .T. }, /*bOk*/, /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, /*oModel*/ )
Return

Static Function TableAttDef()

Local oTableAtt		:= Nil
Local oDSAberto		:= Nil // Pedidos Abertos
Local oDSEncerr		:= Nil // Pedidos Encerrados
Local oDSLibera		:= Nil // Pedidos Liberados
Local oDSBqRegr		:= Nil // Pedidos Bloqueados por Regra
Local oDSBqVerb		:= Nil // Pedidos Bloqueados por Verba
Local oDSTotVend	:= Nil // Colunas: Total do Pedido Por Vendedor
Local oDSTotProd	:= Nil // Colunas: Valor Total Por Produto 
Local oDSVendReg	:= Nil // Colunas: Vendas Por Região
Local aUserPaper	:= {}
Local cCodUser 		:= If(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr())  
Local cSeqPaper		:= " "		

Local lMT410View		:= ExistBlock("CRMBRWVIEW")	//Ponto entrada para manipulação das views padrão
Local cRotina			:= "MATA410"
Local cAliasView		:= "SC5"

If lMT410View 
	oTableAtt := ExecBlock("CRMBRWVIEW", .F.,.F.,{cRotina,cAliasView})
EndIf

If Empty( oTableAtt )
	
	oTableAtt := FWTableAtt():New()
	oTableAtt:SetAlias("SC5")

	If ( IsInCallStack("CRMA310") .Or. IsInCallStack("CRMA290") .Or. IsInCallStack("CRMA290A") .Or. IsInCallStack( "CRM290CWGT" ) )
		aUserPaper := CRMXGetPaper()
		
		If !Empty( aUserPaper )
			cCodUser 	:= aUserPaper[USER_PAPER_CODUSR]
			cSeqPaper	:= aUserPaper[USER_PAPER_SEQUEN] + aUserPaper[USER_PAPER_CODPAPER]			
		EndIf
	
		// Meus Pedidos
		oDSMyPedid := FWDSView():New()
		oDSMyPedid:SetName("Meus Pedidos")
		oDSMyPedid:SetID("DSMyPedid") 
		oDSMyPedid:SetOrder(1) // C5_FILIAL+C5_NUM
		oDSMyPedid:SetCollumns({ Nil,"C5_FILIAL","C5_NUM","C5_CLIENTE","C5_LOJACLI","C5_CLIENT","C5_LOJAENT",;
									"C5_CONDPAG","C5_TABELA","C5_VEND1","C5_EMISSAO","C5_TIPO" })
		oDSMyPedid:SetPublic( .T. )
		oDSMyPedid:AddFilterRelation( "AO4", "AO4_CHVREG", "C5_FILIAL+C5_NUM" )
		If !Empty( aUserPaper )
			oDSMyPedid:AddFilter("Meus Pedidos", "AO4_ENTIDA == 'SC5' .And. AO4_CODUSR == '" + cCodUser + "' .And. ( AO4_USRPAP == '" + cSeqPaper + "' .Or. AO4_USRPAP == ' ' ) .And. AO4_CTRLTT == .T.","AO4")
		Else
			oDSMyPedid:AddFilter("Meus Pedidos", "AO4_ENTIDA == 'SC5' .AND. AO4_CODUSR == '"+cCodUser+"' .AND. AO4_CTRLTT == .T.","AO4")
		EndIf
		oTableAtt:AddView(oDSMyPedid)
	
	EndIf
		
	// Pedidos Abertos
	oDSAberto := FWDSView():New()
	oDSAberto:SetName("Pedidos Abertos")
	oDSAberto:SetID("DSAberto") 
	oDSAberto:SetOrder(1) // C5_FILIAL+C5_NUM
	oDSAberto:SetCollumns({	Nil,"C5_FILIAL","C5_NUM","C5_CLIENTE","C5_LOJACLI","C5_CLIENT","C5_LOJAENT",;
								"C5_CONDPAG","C5_TABELA","C5_VEND1","C5_EMISSAO","C5_TIPO" })
	oDSAberto:SetPublic( .T. )
	oDSAberto:AddFilter("Pedidos Abertos", "Empty(C5_LIBEROK).And.Empty(C5_NOTA) .And. Empty(C5_BLQ)") 
	oTableAtt:AddView(oDSAberto)
	
	// Pedidos Encerrados
	oDSEncerr := FWDSView():New()
	oDSEncerr:SetName("Pedidos Encerrados")
	oDSEncerr:SetID("DSEncerr") 
	oDSEncerr:SetOrder(1) // C5_FILIAL+C5_NUM
	oDSEncerr:SetCollumns({	Nil,"C5_FILIAL","C5_NUM","C5_CLIENTE","C5_LOJACLI","C5_CLIENT","C5_LOJAENT",;
								"C5_CONDPAG","C5_TABELA","C5_VEND1","C5_EMISSAO","C5_TIPO" })
	oDSEncerr:SetPublic( .T. )
	oDSEncerr:AddFilter("Pedidos Encerrados", "!Empty(C5_NOTA).Or.C5_LIBEROK=='E' .And. Empty(C5_BLQ)")
	oTableAtt:AddView(oDSEncerr)
	
	// Pedidos Liberados
	oDSLibera := FWDSView():New()
	oDSLibera:SetName("Pedidos Liberados")
	oDSLibera:SetID("DSLibera") 
	oDSLibera:SetOrder(1) // C5_FILIAL+C5_NUM
	oDSLibera:SetCollumns({	Nil,"C5_FILIAL","C5_NUM","C5_CLIENTE","C5_LOJACLI","C5_CLIENT","C5_LOJAENT",;
								"C5_CONDPAG","C5_TABELA","C5_VEND1","C5_EMISSAO","C5_TIPO" })
	oDSLibera:SetPublic( .T. )
	oDSLibera:AddFilter("Pedidos Liberados", "!Empty(C5_LIBEROK).And.Empty(C5_NOTA).And. Empty(C5_BLQ)")
	oTableAtt:AddView(oDSLibera)
	
	// Pedidos Bloqueados Por Regra
	oDSBqRegr := FWDSView():New()
	oDSBqRegr:SetName("Pedidos Bloqueados Por Regra")
	oDSBqRegr:SetID("DSBqRegr") 
	oDSBqRegr:SetOrder(1) // C5_FILIAL+C5_NUM
	oDSBqRegr:SetCollumns({	Nil,"C5_FILIAL","C5_NUM","C5_CLIENTE","C5_LOJACLI","C5_CLIENT","C5_LOJAENT",;
								"C5_CONDPAG","C5_TABELA","C5_VEND1","C5_EMISSAO","C5_TIPO" })
	oDSBqRegr:SetPublic( .T. )
	oDSBqRegr:AddFilter("Pedidos Bloqueados Por Regra", "C5_BLQ == '1'")
	oTableAtt:AddView(oDSBqRegr)
	
	// Pedidos Bloqueados Por Verba
	oDSBqVerb := FWDSView():New()
	oDSBqVerb:SetName("Pedidos Bloqueados Por Verba") 
	oDSBqVerb:SetID("DSBqVerb") 
	oDSBqVerb:SetOrder(1) // C5_FILIAL+C5_NUM
	oDSBqVerb:SetCollumns({	Nil,"C5_FILIAL","C5_NUM","C5_CLIENTE","C5_LOJACLI","C5_CLIENT","C5_LOJAENT",;
								"C5_CONDPAG","C5_TABELA","C5_VEND1","C5_EMISSAO","C5_TIPO" })
	oDSBqVerb:SetPublic( .T. )
	oDSBqVerb:AddFilter("Pedidos Bloqueados Por Verba", "C5_BLQ == '2'")
	oTableAtt:AddView(oDSBqVerb)

EndIf

// GRAFICOS
// Colunas: Vendas Por Vendedor
oDSTotVend := FWDSChart():New()	
oDSTotVend:SetName("Vendas Por Vendedor")
oDSTotVend:setTitle("Vendas Por Vendedor")
oDSTotVend:SetID("DSTotVend") 
oDSTotVend:SetType("BARCOMPCHART")
oDSTotVend:SetSeries({ {"SC6", "C6_VALOR", "SUM"} })
oDSTotVend:SetCategory( { {"SA3", "A3_NOME"} } )
oDSTotVend:SetPublic( .T. )
oDSTotVend:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oDSTotVend:SetTitleAlign( CONTROL_ALIGN_CENTER ) 
oTableAtt:AddChart(oDSTotVend)

// Colunas: Vendas Por Produto 
oDSTotProd := FWDSChart():New()	
oDSTotProd:SetName("Vendas Por Produto")
oDSTotProd:setTitle("Vendas Por Produto")
oDSTotProd:SetID("DSTotProd") 
oDSTotProd:SetType("BARCOMPCHART")
oDSTotProd:SetSeries({ {"SC6", "C6_VALOR", "SUM"} })
oDSTotProd:SetCategory( { {"SC6", "C6_PRODUTO"} } )
oDSTotProd:SetPublic( .T. )
oDSTotProd:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oDSTotProd:SetTitleAlign( CONTROL_ALIGN_CENTER ) 
oTableAtt:AddChart(oDSTotProd)

// Colunas: Vendas Por Região
oDSVendReg := FWDSChart():New() 	 
oDSVendReg:SetName("Vendas Por Região")
oDSVendReg:setTitle("Vendas Por Região")
oDSVendReg:SetID("DSVendReg") 
oDSVendReg:SetType("BARCOMPCHART")
oDSVendReg:SetSeries({ {"SC6", "C6_VALOR", "SUM"} })
oDSVendReg:SetCategory( { {"SA1", "A1_REGIAO"} } )
oDSVendReg:SetPublic( .T. )
oDSVendReg:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oDSVendReg:SetTitleAlign( CONTROL_ALIGN_CENTER ) 
oTableAtt:AddChart(oDSVendReg)

Return (oTableAtt)	
	