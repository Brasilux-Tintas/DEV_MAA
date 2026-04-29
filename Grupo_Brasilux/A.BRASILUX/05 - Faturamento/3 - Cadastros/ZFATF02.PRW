#include 'TOTVS.CH'
#include 'FWMVCDEF.CH'

/*/{Protheus.doc} ZFATF02
Tabela de Frete CIF
@type function
@version  v.2023.06
@author Luís Gustavo Souza
@since 13/06/2023
/*/
User Function ZFATF02()
     Local _oBrowse

     _oBrowse := FWMBrowse():New()
     _oBrowse:SetAlias( 'Z15' )
     _oBrowse:SetDescription( 'Tabela de Frete CIF' )
     _oBrowse:Activate()
Return NIL

/*/{Protheus.doc} MENUDEF
Montagem do menu
@type function
@version  v.2023.06
@author Luís Gustavo Souza
@since 13/06/2023
/*/
Static Function MenuDef()
       Local aRotina := {}

       ADD OPTION aRotina Title 'Visualizar'  Action 'VIEWDEF.ZFATF02' OPERATION 2 ACCESS 0
       ADD OPTION aRotina Title 'Incluir'     Action 'VIEWDEF.ZFATF02' OPERATION 3 ACCESS 0
       ADD OPTION aRotina Title 'Alterar'     Action 'VIEWDEF.ZFATF02' OPERATION 4 ACCESS 0
       ADD OPTION aRotina Title 'Excluir'     Action 'VIEWDEF.ZFATF02' OPERATION 5 ACCESS 0
       ADD OPTION aRotina Title 'Imprimir'    Action 'VIEWDEF.ZFATF02' OPERATION 8 ACCESS 0
Return aRotina

/*/{Protheus.doc} MODELDEF
Montagem do modelo
@type function
@version  v.2023.06
@author Luís Gustavo Souza
@since 13/06/2023
/*/
Static Function ModelDef()
       // Cria a estrutura a ser usada no Modelo de Dados e os campos que serão exibidos no cabeçalho
       Local oStruZ15 := FWFormStruct( 1, 'Z15', { |cCampo| AllTRim(cCampo) $ "Z15_CODTRA;Z15_DESTRA;Z15_CODREG;Z15_DESREG;Z15_PESLIM;Z15_VLRFPE;Z15_VLREXC;Z15_PEDAGI;Z15_SEGURO;Z15_GRIS  ;Z15_TAS   ;Z15_SECCAT; " }, /*lViewUsado*/ )
       Local oStruGrd := FWFormStruct( 1, 'Z15' )
       Local oModel

       // Cria o objeto do Modelo de Dados
       oModel := MPFormModel():New( 'MODFAT02F', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

       //Adiciona ao modelo uma estrutura de formulário de edição por campo
       oModel:AddFields( 'Z15MASTER', /*cOwner*/ , oStruZ15 )
       oModel:AddGrid(   'Z15DETAIL', 'Z15MASTER', oStruGrd, , )

       // Adiciona ao modelo uma estrutura de formulário de edição por grid
       
       // Faz relaciomaneto entre os compomentes do model
       oModel:SetRelation( 'Z15DETAIL', { { 'Z15_FILIAL', 'xFilial("Z15")' },;
                                          { 'Z15_CODTRA', 'Z15_CODTRA'     },;
                                          { 'Z15_CODREG', 'Z15_CODREG'     };
                                        }, Z15->( IndexKey(1) ) )

       // Liga o controle de nao repeticao de linha
       oModel:GetModel( 'Z15DETAIL' ):SetUniqueLine( { 'Z15_CODCID' } )

       //Indica que é opcional ter dados informados na Grid
       //oModel:GetModel( 'Z15DETAIL' ):SetOptional(.T.)
       //oModel:GetModel( 'Z15DETAIL' ):SetOnlyView(.T.)

       // Adiciona a descricao do Modelo de Dados
       oModel:SetDescription( 'Cadastro de Fretes' )

       // Adiciona a descricao do Componente do Modelo de Dados
       oModel:GetModel( 'Z15MASTER' ):SetDescription( 'Dados da Transportadora/Região' )
       oModel:GetModel( 'Z15DETAIL' ):SetDescription( 'Dados da Cidade'                )

       //Definindo outras informações do Modelo e da Grid
       oModel:GetModel("Z15DETAIL"):SetMaxLine(9999)
       oModel:SetDescription("Manutenção de Fretes CIF")
       oModel:SetPrimaryKey({"Z15_FILIAL", "Z15_CODTRA", "Z15_CODREG" } )
 
Return oModel

/*/{Protheus.doc} MENUDEF
Montagem da view
@type function
@version  v.2023.06
@author Luís Gustavo Souza
@since 13/06/2023
/*/
Static Function ViewDef()
       //Na montagem da estrutura da visualização de dados, vamos chamar o modelo criado anteriormente, no cabeçalho vamos mostrar somente 3 campos, e na grid vamos carregar conforme a função fViewStruct
       Local oView        := NIL
       Local oModel    := FWLoadModel('ZFATF02')
       Local oStruCab  := FWFormStruct( 2, "Z15", { |cCampo|    Alltrim(cCampo) $ "Z15_CODTRA;Z15_DESTRA;Z15_CODREG;Z15_DESREG;Z15_PESLIM;Z15_VLRFPE;Z15_VLREXC;Z15_PEDAGI;Z15_SEGURO;Z15_GRIS  ;Z15_TAS   ;Z15_SECCAT; "  } )
       Local oStruGRD  := FWFormStruct( 2, "Z15", { |cCampo| !( Alltrim(cCampo) $ "Z15_CODTRA;Z15_DESTRA;Z15_CODREG;Z15_DESREG;Z15_PESLIM;Z15_VLRFPE;Z15_VLREXC;Z15_PEDAGI;Z15_SEGURO;Z15_GRIS  ;Z15_TAS   ;Z15_SECCAT; ") } )
 
       //Define que no cabeçalho não terá separação de abas (SXA)
       oStruCab:SetNoFolder()
 
       //Cria o View
       oView:= FWFormView():New() 
       oView:SetModel(oModel)              
 
       //Cria uma área de Field vinculando a estrutura do cabeçalho com MDFieldZAF, e uma Grid vinculando com Z15DETAIL
       oView:AddField( 'VIEW_Z15', oStruCab, 'Z15MASTER' )
       oView:AddGrid ( 'GRID_Z15', oStruGRD, 'Z15DETAIL' )
 
       //O cabeçalho (MAIN) terá 25% de tamanho, e o restante de 75% irá para a GRID
       oView:CreateHorizontalBox( "MAIN", 40 )
       oView:CreateHorizontalBox( "GRID", 60 )
 
       //Vincula o MAIN com a VIEW_ZAF e a GRID com a GRID_ZAF
       oView:SetOwnerView( 'VIEW_Z15', 'MAIN' )
       oView:SetOwnerView( 'GRID_Z15', 'GRID' )
       //oView:EnableControlBar(.T.)
 
       //Define o campo incremental da grid como o ZAF_ITEM
       //oView:AddIncrementField('GRID_Z15', 'ZAF_ITEM')
Return oView
