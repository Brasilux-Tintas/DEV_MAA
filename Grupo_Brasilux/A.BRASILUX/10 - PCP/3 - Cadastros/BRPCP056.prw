#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"
#Include "TOTVS.CH"
#Include "FWMVCDEF.CH"

/*/
    {Protheus.doc} BRPCP056
    FICHAS DE ANALISES DO PRODUTO
    @type  User Function
    @author Andre Fracassi
    @since 05/04/13
    @version P12 12.1.25
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @table Z02
    @history
    @obs TASK -
    @menu Livros PCP->Especificos Brasilux->Cadastro->Analise do Produto
/*/
User Function BRPCP056()

	Local _oBrowse
     u_zcfga01( 'BRPCP056' ) //LGS#2021201 - Gravação de log de utilização da rotina
	//Instanciamento da Classe de Browse
	_oBrowse := FWMBrowse():New()

	//Definicao da tabela do Browse
	_oBrowse:SetAlias("Z02")

    //Adicionando Legenda
    _oBrowse:AddLegend("Z02_APROV == '1'", "BR_VERDE",      "Aprovado",             "1" )
    _oBrowse:AddLegend("Z02_APROV == '2'", "BR_VERMELHO",   "Reprovado",            "1" )
    _oBrowse:AddLegend("Z02_APROV == '3'", "BR_LARANJA",    "Aprov. com Restrição", "1" )
    _oBrowse:AddLegend("Empty(Z02_APROV)", "BR_AMARELO",    "Pendente",             "1" )

	//Definicao do titulo do browser
	_oBrowse:SetDescription( FWX2Nome("Z02" ) )

	_oBrowse:Activate()

Return



/*/
    {Protheus.doc} MenuDef
    Funcao para definição de opções do menu
    @type  Static Function
    @author Andre Fracassi
    @since 05/04/13
    @version P12 12.1.25
    @param param_name, param_type, param_descr
    @return _aRotina, Array, Retorna array contendo as opções de menu
    @example
    (examples)
    @see (links_or_references)
    @table Z02
    @history
    @obs TASK -
    @menu Livros PCP->Especificos Brasilux->Cadastro->Analise do Produto
/*/
Static Function MenuDef()

    Local _aRotina := {}

	ADD OPTION _aRotina TITLE "Pesquisar"       ACTION "PesqBrw"             OPERATION 1 ACCESS 0
	ADD OPTION _aRotina TITLE "Visualizar"      ACTION "VIEWDEF.BRPCP056"    OPERATION 2 ACCESS 0
	ADD OPTION _aRotina TITLE "Incluir"         ACTION "VIEWDEF.BRPCP056"    OPERATION 3 ACCESS 0
	ADD OPTION _aRotina TITLE "Alterar"         ACTION "VIEWDEF.BRPCP056"    OPERATION 4 ACCESS 0
	ADD OPTION _aRotina TITLE "Excluir"         ACTION "VIEWDEF.BRPCP056"    OPERATION 5 ACCESS 0
    ADD OPTION _aRotina TITLE "Conhecimento"    ACTION "u_BRPCP06doc()"      OPERATION 4 ACCESS 0

Return( _aRotina )



/*/
    {Protheus.doc} BRPCP06doc
    Chamada da funcao para Base de Conhecimento
    @type  Static Function
    @author Andre Fracassi
    @since 05/04/13
    @version P12 12.1.25
    @param param_name, param_type, param_descr
    @return _aRotina, Array, Retorna array contendo as opções de menu
    @example
    (examples)
    @see (links_or_references)
    @table Z02
    @history
    @obs TASK -
    @menu Livros PCP->Especificos Brasilux->Cadastro->Analise do Produto
/*/
User Function BRPCP06doc()
Return( MsDocument("Z02", Z02->( RecNo() ), 1 ) )



/*/
    {Protheus.doc} ModelDef
    Funcao para criação de definicao de modelo
    @type  Static Function
    @author Andre Fracassi
    @since 05/04/13
    @version P12 12.1.25
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @table Z02
    @history
    @obs TASK -
    @menu Livros PCP->Especificos Brasilux->Cadastro->Analise do Produto
/*/
Static Function ModelDef()

    Local _oModel
    Local _oStrZ02 := FWFormStruct( 1, "Z02", /*bAvalCampo*/, /*lViewUsado*/ )

    _oModel := MPFormModel():New("zBRPCP056", /*bMPFormModelo*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
    _oModel:SetDescription( FWX2Nome("Z02") )

    _oModel:AddFields("Z02MASTER", , _oStrZ02 )
    _oModel:SetPrimaryKey( { "Z02_FILIAL", "Z02_COD" } )

    _oModel:GetModel("Z02MASTER"):SetDescription( FWX2Nome("Z02") )

Return( _oModel )



/*/
    {Protheus.doc} ViewDef
    Funcao para criação de definicao de visualização
    @type  Static Function
    @author Andre Fracassi
    @since 05/04/13
    @version P12 12.1.25
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @table Z02
    @history
    @obs TASK -
    @menu Livros PCP->Especificos Brasilux->Cadastro->Analise do Produto
/*/
Static Function ViewDef()

    Local _oView
    Local _oModelVd := ModelDef()
    Local _oStrZ02  := FWFormStruct( 2, "Z02")

    _oView := FWFormView():New()
    _oView:SetModel( _oModelVd )

    _oView:AddField("VIEW_Z02", _oStrZ02, "Z02MASTER" )
    _oView:CreateHorizontalBox( "SUPERIOR", 100)
    _oView:SetOwnerView("VIEW_Z02", "SUPERIOR")

	//Força o fechamento da janela na confirmação
	_oView:SetCloseOnOk( { || .T. } )

Return( _oView )
