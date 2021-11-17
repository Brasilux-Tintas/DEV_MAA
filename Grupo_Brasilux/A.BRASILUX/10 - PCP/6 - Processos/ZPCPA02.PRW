#INCLUDE 'totvs.ch'
#INCLUDE 'fwmvcdef.ch'

/*/{Protheus.doc} ZPCPA02
Chamada principal do Log de apontamentos de produção, no menu do usuário.
@type function
@version 2020.01
@author Luís Gustavo de Souza
@since 23/06/2020
/*/
User Function ZPCPA02()
     Local _oBrowse
     Local oVisions   := getVisions()
     Private _nContMnt := 0

     //Instaciamento da Classe
     _oBrowse := FWMBrowse():New()

     //Definição da Legenda

     //Definição dos Dados
     _oBrowse:SetAlias( 'ZZA' )
     _oBrowse:SetUseFilter( .T. )
     _oBrowse:SetAttach( .T. )
     _oBrowse:SetViewsDefault( oVisions:aViews )

     //Definição da Legenda
     _oBrowse:AddLegend( "ZZA->ZZA_FLAG $ '0'                 .AND. ZZA->ZZA_OPERAC <> '  '" , "YELLOW",    "Operação não iniciada"  )
     _oBrowse:AddLegend( "ZZA->ZZA_FLAG $ '1'                 .AND. ZZA->ZZA_OPERAC <> '  '" , "GREEN" ,    "Operação iniciada"      )
     _oBrowse:AddLegend( "ZZA->ZZA_FLAG $ '2'                 .AND. ZZA->ZZA_OPERAC <> '  '" , "BLUE"  ,    "Operação finalizada"    )
     _oBrowse:AddLegend( "ZZA->ZZA_FLAG $ '5'                 .AND. ZZA->ZZA_OPERAC <> '  '" , "RED"   ,    "Operação encerrada"     )
     _oBrowse:AddLegend( "ZZA->ZZA_FLAG $ '1.2.3.4.Z.Y.X.5.B' .AND. ZZA->ZZA_OPERAC  = '  '" , "BLACK" ,    "Apontamento Antigo PI"  )
     _oBrowse:AddLegend( "ZZA->ZZA_FLAG $ '6.7.8'             .AND. ZZA->ZZA_OPERAC  = '  '" , "GRAY"  ,    "Apontamento Antigo PA"  )

     //Definição do Titulo do Browse
     _oBrowse:SetDescription( "Consulta das Baixas das Ordens de Produção" )

     //Desligado a exibição dos detalhes
     _oBrowse:DisableDetails()

     //Ativação da Classe
     _oBrowse:Activate()
Return

/*/{Protheus.doc} MenuDef
Menu principal do FWMBrowse com as opções padrões e particulares para o log do apontamento de produção.
@type function
@version 2020.01
@author Luís Gustavo de Souza
@since 08/07/2020
@return Array, Retorna o aRotina com as opções do menu.
/*/
Static Function MenuDef()
       Local aRotina As ARRAY

       aRotina := {}

       ADD OPTION aRotina TITLE "Visualizar"                    ACTION "VIEWDEF.ZPCPA02"                   OPERATION 2 ACCESS 0
       ADD OPTION aRotina TITLE "Alterar"                       ACTION "VIEWDEF.ZPCPA02"                   OPERATION 4 ACCESS 0
       ADD OPTION aRotina TITLE "Arquivar Ops"                  ACTION "u_ZPCPA03X(1)"                     OPERATION 6 ACCESS 0
       ADD OPTION aRotina TITLE "Apontamentos"                  ACTION "u_ZPCPA03X(2)"                     OPERATION 6 ACCESS 0
       ADD OPTION aRotina TITLE "Apontamentos x Baixas"         ACTION "u_ZPCPA03X(3)"                     OPERATION 6 ACCESS 0
       ADD OPTION aRotina TITLE "Re-enviar ao PCF"              ACTION "u_ZPCPA02I( )"                     OPERATION 6 ACCESS 0
       //ADD OPTION aRotina TITLE "Responsáveis - Balança"        ACTION "u_ZPCPA05( 'XB', 'Balança' )"      OPERATION 6 ACCESS 0
       //ADD OPTION aRotina TITLE "Responsáveis - Tingimento"     ACTION "u_ZPCPA05( 'XC', 'Tingimento' )"   OPERATION 6 ACCESS 0
       //ADD OPTION aRotina TITLE "Responsáveis - Laboratório"    ACTION "u_ZPCPA05( 'XL', 'Laboratório' )"  OPERATION 6 ACCESS 0
       //ADD OPTION aRotina TITLE "Responsáveis - Teste"          ACTION "u_ZPCPA07X('XB', 'Balanceiro')"    OPERATION 6 ACCESS 0
       //ADD OPTION aRotina TITLE "Responsáveis - Teste X"        ACTION "u_ZPCPA07X()"    OPERATION 6 ACCESS 0
       ADD OPTION aRotina TITLE "Parametrização do Apontamento" ACTION "u_ZPCPA03X(6)"   OPERATION 6 ACCESS 0
       ADD OPTION aRotina TITLE "Responsaveis"                  ACTION "u_ZPCPA03X(4)"                     OPERATION 6 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
Modelo da Tela principal do log dos apontamentos de produção
@type function
@version 2020.01
@author Luís Gustavo de Souza
@since 08/07/2020
@return Object, Objeto com o modelo principal
/*/
Static Function ModelDef()
       Local oModel  as Object
       Local oStrZZA as Object 

       oStrZZA := FWFormStruct( 1, "ZZA" )
       oModel  := MPFormModel():New( "ORDENS" )
       oModel:SetDescription( "Consulta Apontamentos de Produção" )
       oModel:addFields( 'MASTERZZA', , oStrZZA )
       oModel:SetPrimaryKey({'ZZA_ORDEM', 'ZZA_OPERAC'})
       oModel:getModel('MASTERZZA'):SetDescription('Dados do Apontamento')
       
Return oModel

/*/{Protheus.doc} ViewDef
View da Tela principal do log dos apontamentos de produção
@type function
@version 2020.01
@author Luís Gustavo de Souza
@since 08/07/2020
@return Object, Objeto com a view principal
/*/
Static Function ViewDef()
       Local oModel  As Object
       Local oView   As Object
       Local oStrZZA As Object

       oModel := ModelDef()
       oStrZZA:= FWFormStrutct( 2, "ZZA" )
       oView  := FWFormView():New()
       oView:SetModel( oModel )
       oView:AddField( "VIEW_ORDENS", oStrZZA, "MASTERZZA" )
       oView:CreateHorizontalBox("SUPERIOR", 100)
       oView:SetOwnerView( "VIEW_ORDENS", "SUPERIOR" )

Return oView

/*/{Protheus.doc} getVisions
Função para incluir as Visões Padrões do programa.
@type function
@version 2020.01
@author Luís Gustavo de Souza
@since 08/07/2020
@return Object, Objeto com as visões padrões.
/*/
Static Function getVisions()
       Local oDSView01 As Object
       Local oTableAtt := FWTableAtt():New()

       oTableAtt:SetAlias("ZZA")

       oDSView01   := FWDSView():New()
       oDSView01:SetName( "Ordens de Produção não retornadas" )   //Nome da Visão
       oDSView01:SetPublic(.T.)                                   //Define se será visível por todos os usuários ou não
       oDSView01:SetCollumns( { "ZZA_ORDEM", "ZZA_LOTE", "ZZA_DTINI", "ZZA_DTFIM", "ZZA_ENVIA", "ZZA_DTENV", "ZZA_HENV", "ZZA_RENV" } )       //Colunas do browse
       oDSView01:SetOrder(2)                                      //índice utilizado
       oDSView01:AddFilter( "Não retornadas", 'ZZA_ENVIA <> "S"' ) //Filtro
       oDSView01:setUser()                                        //usuário dono da visão. Quando a visão não for pública, somente este usuário poderá enxergá-la.
       oDSView01:setID( "1" )                                     //ID da visão
       oDSView01:SetLegend(.T.)
       oTableAtt:AddView(oDSView01)

Return oTableAtt

User Function ZPCPA02I()
     Local aMATA650    := {}       //-Array com os campos
     Local nOpc        := 4
     Local lMsErroAuto := .F.
     Local _cFunAtual  := FunName()

     SetFunName( "MATA650" ) //Para funcionar a integração com o PPI Multitask
     RpcSetType( )

     If ZZA->ZZA_QUANT <= 0
        MessageBox( 'Atenção, utilizar a operação final, que possui a quantidade de apontamento.', 'Re-enviar PCF', 48 )
        Return
     Endif
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Se alteracao ou exclusao, deve-se posicionar no registro     ³
     //³ da SC2 antes de executar a rotina automatica                 ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     SC2->(DbSetOrder(1)) // FILIAL + NUM + ITEM + SEQUEN + ITEMGRD
     SC2->(DbSeek(xFilial("SC2") + ZZA->ZZA_ORDEM ) )
	
     aMata650 := { { 'C2_FILIAL' , SC2->C2_FILIAL           , NIL },;
                   { 'C2_PRODUTO', SC2->C2_PRODUTO          , NIL },;          
                   { 'C2_NUM'    , SC2->C2_NUM              , NIL },;          
                   { 'C2_ITEM'   , SC2->C2_ITEM             , NIL },;
                   { 'C2_SEQUEN' , SC2->C2_SEQUEN           , NIL },;
                   { 'C2_OBS'    , "Re-envio PCF - ZPCPA02" , NIL } }

     msExecAuto( { |x, Y| Mata650(x, Y) }, aMata650, nOpc )
     If lMsErroAuto
        MostraErro()
     Else
        //Função para buscar Ordens de PAs e integrar pesos
        fIntegPAs()
     EndIf
     SetFunName( _cFunAtual )
     MessageBox( "Informações enviadas ao PCF, verifique", 'Re-enviar PCF', 64 )
Return

//************************************************************
//*** TOTVSMES - Integração com o PCFactory - LGS#20191106 ***
//************************************************************
Static Function fIntegPAs()
       Local aMATA650    := {}  //-Array com os campos
       Local nOpc        := 4
       Local lMsErroAuto := .F.
       Private _aPesoProd:= {}

       SetFunName("MATA650") 
       RpcSetType( )

       DbSelectArea("SC2") //Busco Produtos do Lote
       SC2->( DbOrderNickName("SC2001") )
       If SC2->( DbSeek( xFilial("SC2") + ZZA->ZZA_LOTE ) )
          While !Eof() .and. SC2->C2_LOTE == ZZA->ZZA_LOTE
                _aPesoProd := {}
                DbSelectArea("SB1") //Verifico se produto é um PA
                SB1->( DbSetorder( 1 ) )
                If SB1->( DbSeek( xFilial ("SB1") + SC2->C2_PRODUTO ) )
                   If SB1->B1_TIPO == 'PA'
                      _aPesoProd := fPesoPA()
                      aMata650  := { {'C2_FILIAL'   ,SC2->C2_FILIAL                                    , NIL },;
                                     {'C2_PRODUTO'  ,SC2->C2_PRODUTO                                   , NIL },;          
                                     {'C2_NUM'      ,SC2->C2_NUM                                       , NIL },;          
                                     {'C2_ITEM'     ,SC2->C2_ITEM                                      , NIL },;
                                     {'C2_SEQUEN'   ,SC2->C2_SEQUEN                                    , NIL },;
                                     {'C2_OBS'      ,"4 - Fim  do Laboratório" + AllTrim( SC2->C2_OBS ), NIL } }             

                      msExecAuto( { | x, Y | Mata650( x, Y ) }, aMata650, nOpc )
                      If lMsErroAuto
                         MostraErro()
                      EndIf
                   Endif
                Endif
                DbSelectArea("SC2")
                SC2->( DbSkip() )
          EndDo
       Endif
Return

/*/{Protheus.doc} fPesoPA
Busca a estrutura do produto e retorna o peso liquido e bruto do produto
@type function
@version 2020.01
@author Luís Gustavo de Souza
@since 16/12/2020
@return Array, Retorna array com pesos liquido e bruto para envio ao PCF
/*/
Static Function fPesoPA()
       Local _nPesoLiqu := 0
       Local _nPesoBrut := 0
       Local _aCompProd := {}
       Local _nX        := 0

       DbSelectArea("SG1")
       SG1->( DbSetOrder( 1 ) )
       If SG1->( DbSeek( xFilial("SG1") + SB1->B1_COD) )
          While !Eof() .and. SG1->G1_COD == SB1->B1_COD
                //                  COMPONENTE    QUANTIDADE     UNIDADE  TIPO  PESO  TOTAL
                aAdd( _aCompProd, { SG1->G1_COMP, SG1->G1_QUANT, ''     , ''  , 0   , 0    } )
                DbSelectArea("SG1")
                SG1->( DbSkip( ) )
          EndDo
       Endif
       //Calcula Peso Por item da fórmula
       For _nX := 1 To Len( _aCompProd )
           DbSelectArea( "SB1" )
           SB1->( DbSetorder( 1 ) )
           If SB1->( DbSeek( xFilial( "SB1" ) + _aCompProd[_nX][1] ) )
              _aCompProd[ _nX ][3] := SB1->B1_UM
              _aCompProd[ _nX ][4] := SB1->B1_TIPO
              _aCompProd[ _nX ][5] := SB1->B1_PESO //Peso Liquido do Produto
              If SB1->B1_TIPO == 'PI'
                 _aCompProd[ _nX ][6] := Round( Iif( SB1->B1_UM $ 'KG.K ', _aCompProd[ _nX ][2], _aCompProd[ _nX ][2] * ZZA->ZZA_PESLAB ), 3 )
                 _nPesoLiqu += Round( _aCompProd[ _nX ][6], 3 )
                 _nPesoBrut += Round( _aCompProd[ _nX ][6], 3 )
              Else
                 _aCompProd[ _nX ][6] := Round( _aCompProd[ _nX ][2] * _aCompProd[ _nX ][5], 3 )
                 _nPesoBrut += Round( _aCompProd[ _nX ][6], 3 )
              Endif
           Endif
       Next
Return { _nPesoLiqu, _nPesoBrut }
