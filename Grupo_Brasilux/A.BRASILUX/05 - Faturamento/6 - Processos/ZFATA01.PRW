#include 'totvs.ch'
#include 'fwmvcdef.ch'

/*/{Protheus.doc} ZFATF01
Liberação de Pedidos de Vendas
@type function
@version  v.2021.001
@author Luís Gustavo de Souza
@since 27/09/2021
/*/
User Function ZFATA01() 
     Local _oBrowse
     Local cRotina := 'BRFATX01  '
     //Local _oVision := getVisions()
     Private aRotina As ARRAY
     Private aHeader As ARRAY
     Private aCols   As ARRAY
     Private cString As String
     Public aHeader  As Array
     Public aCols    As Array
     Public cCodUsr   := RetCodUsr()
     Public lAdmin    := .f.
     Public cAcesso   := ""
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
     Public _oPriCom, _oUltCom, _oRisco, _oAltera, _oVenda
     Public _cPriCom, _cUltCom, _cRisco, _cAltera, _cVenda
     Public _aTotal := {}
     Public _aItens := {}
     Public _aPedidos := {}
     /****************************************************************************************************/
     /***                                     VERIFICAÇÃO DE ACESSO                                    ***/
     //lAdmin := ( PSWADMIN( cUsername, SubStr( cUsuario, 1, 6), cCodUsr ) == 0 )
			
	If lAdmin
        cAcesso := '*****   * '		
	Else 
        DbSelectArea("SZW")
        DbSetOrder(4)
        DbSeek(xFilial("SZW")+cRotina+cCodUsr+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2),.t.)
        If Found()
        	 cAcesso := SZW->ZW_ACESSOS
        Else
           MessageBox( "Usuário não autorizado !!! Entre em contato com o administrador do sistema", "Atenção", 48 )
           Return
        Endif 
 	EndIf
     lAcsAtv := Iif(SubStr(cAcesso, 9, 1) == '*', .t., .f.) // Usuário Inativo
     If !lAcsAtv
        MessageBox( "Usuário inativo..." + chr(13) + chr(10) + "Entre em contato com o administrador do sistema !", "Atenção...", 48 )
        Return
     Endif
     lAcsCad := Iif(SubStr(cAcesso, 1, 1) == '*', .t., .f.) // Itens a serem liberados por vendas.
     lAcsPed := Iif(SubStr(cAcesso, 2, 1) == '*', .t., .f.) // Itens a serem liberados por vendas.
	lAcsCre := Iif(SubStr(cAcesso, 3, 1) == '*', .t., .f.) // Itens a serem liberados pelo crédito
	lAcsDir := Iif(SubStr(cAcesso, 4, 1) == '*', .t., .f.) // Itens a serem liberados pela diretoria
	lAcsOut := Iif(SubStr(cAcesso, 6, 1) == '*', .t., .f.) // Outros pedidos a serem Liberados.
     /*************************?***************************************************************************/
     aHeader := {}
     aCols   := {}     
     aRotina := {}
     aHeader := {}
     aCols   := {}
     cString := "SC5"

     u_zcfga01( "ZFATA01" )

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
Return Nil

/*/{Protheus.doc} MenuDef
Menu principal do FWMBrowse com as opções padrões e particulares para o log do apontamento de produção.
@type function
@version v.2021.001
@author Luís Gustavo de Souza
@since 27/09/2021
@return Array, Retorna o aRotina com as opções do menu.
/*/
Static Function MenuDef()
       aRotina := {}

       ADD OPTION aRotina TITLE "Visualizar"                    ACTION "U_ZFAT01Vi( )"                     OPERATION 2 ACCESS 0
       ADD OPTION aRotina TITLE "Liberação"                     ACTION "U_ZFAT01Li( )"                     OPERATION 6 ACCESS 0
Return aRotina

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
     Local _nOperation := MODEL_OPERATION_UPDATE

     nOpc := FWExecView( _cTitulo , _cPrograma, _nOperation, /*oDlg*/, {|| .T. }, /*bOk*/, /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, /*oModel*/ )
Return
