#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
 
//Variáveis Estáticas
Static cTitulo := ""
 
/*/{Protheus.doc} zCadSX5
Cadastro de tabelas SX5
@author Atilio
@since 05/08/2016
@version 1.0
    @param cTabela, character, Código da tabela genérica
    @param cTitRot, character, Título da Rotina
    @example
    u_zCadSX5("01", "Séries de NF")
/*/
 
User Function zCadSX5(cTabela, cTitRot)
    Local aArea   := GetArea()
    Local oBrowse
    Local cFunBkp := FunName()
    Default cTitRot := ""
    Private cTabX := cTabela
     
    //Senão tiver chave, finaliza    
    If Empty(cTabela)
        Return
    EndIf
     
    DbSelectArea('SX5')
    SX5->(DbSetOrder(1)) // X5_FILIAL+X5_TABELA+X5_CHAVE
    SX5->(DbGoTop())
     
    //Se vier título por parâmetro
    If !Empty(cTitRot)
        cTitulo := cTitRot
    EndIf
     
    //Se ainda tiver em branco, pega o da própria tabela
    If Empty(cTitulo)
        //Se conseguir posicionar
        If SX5->(DbSeek(FWxFilial("SX5") + "00" + cTabela))
            cTitulo := SX5->X5_DESCRI
             
        Else
            MsgAlert("Tabela não encontrada!", "Atenção")
            Return
        EndIf
    EndIf
     
    //Instânciando FWMBrowse - Somente com dicionário de dados
    SetFunName("zCadSX5")
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela de cadastro de Autor/Interprete
    oBrowse:SetAlias("SX5")
 
    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)
     
    //Filtrando
    oBrowse:SetFilterDefault("SX5->X5_TABELA = '"+cTabela+"'")
     
    //Ativa a Browse
    oBrowse:Activate()
     
    SetFunName(cFunBkp)
    RestArea(aArea)
Return
 
/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  05/08/2016                                                   |
 | Desc:  Criação do menu MVC                                          |
 *---------------------------------------------------------------------*/
 
Static Function MenuDef()
    Local aRot := {}
     
    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.zCadSX5' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.zCadSX5' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.zCadSX5' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.zCadSX5' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
 
Return aRot
 
/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Daniel Atilio                                                |
 | Data:  05/08/2016                                                   |
 | Desc:  Criação do modelo de dados MVC                               |
 *---------------------------------------------------------------------*/
 
Static Function ModelDef()
    //Criação do objeto do modelo de dados
    Local oModel := Nil
     
    //Criação da estrutura de dados utilizada na interface
    Local oStSX5 := FWFormStruct(1, "SX5")
     
    //Editando características do dicionário
    oStSX5:SetProperty('X5_TABELA',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                       //Modo de Edição
    oStSX5:SetProperty('X5_TABELA',   MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'cTabX'))                     //Ini Padrão
    oStSX5:SetProperty('X5_CHAVE',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    'Iif(INCLUI, .T., .F.)'))     //Modo de Edição
    oStSX5:SetProperty('X5_CHAVE',    MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'u_zSX5Chv()'))               //Validação de Campo
    oStSX5:SetProperty('X5_CHAVE',    MODEL_FIELD_OBRIGAT, .T. )                                                                //Campo Obrigatório
    oStSX5:SetProperty('X5_DESCRI',   MODEL_FIELD_OBRIGAT, .T. )                                                                //Campo Obrigatório
         
    //Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("zCadSX5M",/*bPre*/,/*bPos*/,/*bCommit*/,/*bCancel*/) 
     
    //Atribuindo formulários para o modelo
    oModel:AddFields("FORMSX5",/*cOwner*/,oStSX5)
     
    //Setando a chave primária da rotina
    oModel:SetPrimaryKey({'X5_FILIAL', 'X5_TABELA', 'X5_CHAVE'})
     
    //Adicionando descrição ao modelo
    oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)
     
    //Setando a descrição do formulário
    oModel:GetModel("FORMSX5"):SetDescription("Formulário do Cadastro "+cTitulo)
Return oModel
 
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  05/08/2016                                                   |
 | Desc:  Criação da visão MVC                                         |
 *---------------------------------------------------------------------*/
 
Static Function ViewDef()
    //Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
    Local oModel := FWLoadModel("zCadSX5")
     
    //Criação da estrutura de dados utilizada na interface do cadastro de Autor
    Local oStSX5 := FWFormStruct(2, "SX5")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SX5_NOME|SX5_DTAFAL|'}
     
    //Criando oView como nulo
    Local oView := Nil
 
    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Atribuindo formulários para interface
    oView:AddField("VIEW_SX5", oStSX5, "FORMSX5")
     
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Colocando título do formulário
    oView:EnableTitleView('VIEW_SX5', 'Dados - '+cTitulo )  
     
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
     
    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_SX5","TELA")
     
    //Retira o campo de tabela da visualização
    oStSX5:RemoveField("X5_TABELA")
Return oView
 
/*/{Protheus.doc} zSX5Chv
Função que valida a digitação do campo Chave, para verificar se já existe
@type function
@author Atilio
@since 05/08/2016
@version 1.0
/*/
 
User Function zSX5Chv()
    Local aArea    := GetArea()
    Local lRet     := .T.
    Local cX5Chave := M->X5_CHAVE
     
    DbSelectArea('SX5')
    SX5->(DbSetOrder(1)) // X5_FILIAL+X5_TABELA+X5_CHAVE
    SX5->(DbGoTop())
     
    //Se conseguir posicionar, já existe
    If SX5->(DbSeek(FWxFilial('SX5') + cTabX + cX5Chave))
        MsgAlert("J� existe chave com esse c�digo (<b>"+cX5Chave+"</b>)!", "Aten��o!")
        lRet := .F.
    EndIf
     
    RestArea(aArea)
Return lRet
