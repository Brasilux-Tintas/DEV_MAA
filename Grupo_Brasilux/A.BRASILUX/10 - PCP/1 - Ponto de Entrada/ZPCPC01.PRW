#Include 'Protheus.ch'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} ZPCPC01
Programa que faz Cadastro de Lotes Bloqueados.
@type function
@version  v.2022.05
@author Luís Gustavo Souza
@since 22/07/2022
/*/
User Function ZPCPC01()

Local aArea 		:= ZAE->(GetArea())

Private oBrowse
Private cChaveAux 	:= "" 

// Instanciamento da Classe de Browse 
oBrowse := FWMBrowse():New() 

// Definição da tabela do Browse 
oBrowse:SetAlias('ZAE') 

// Titulo da Browse 
oBrowse:SetDescription('Bloqueio de Lotes')
 
// Ativação da Classe 
oBrowse:Activate() 
RestArea(aArea)

Return

Static Function MenuDef()
 
Local aRotina := {}

ADD OPTION aRotina TITLE "Pesquisar"  	ACTION 'PesqBrw' 			OPERATION 1 ACCESS 0
ADD OPTION aRotina Title 'Visualizar'	Action 'VIEWDEF.ZPCPC01'	OPERATION 2 ACCESS 0 
ADD OPTION aRotina Title 'Incluir'   	Action 'VIEWDEF.ZPCPC01'	OPERATION 3 ACCESS 0 
ADD OPTION aRotina Title 'Alterar'  	Action 'VIEWDEF.ZPCPC01'	OPERATION 4 ACCESS 0 
ADD OPTION aRotina Title 'Imprimir'  	Action 'VIEWDEF.ZPCPC01'	OPERATION 8 ACCESS 0 


Return aRotina

Static Function ViewDef() 

// Interface de visualização construída 
Local oView

// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado 
Local oModel := ModelDef() 

// Cria a estrutura a ser usada na View 
Local oStruZAE := FWFormStruct( 2, 'ZAE' ) 


// Cria o objeto de View 
oView := FWFormView():New() 

// Define qual o Modelo de dados será utilizado na View 
oView:SetModel( oModel ) 

// Adiciona no nosso View um controle do tipo formulário 
oView:AddField( 'VIEW_ZAE', oStruZAE, 'ZAEMASTER' )

// Criar um "box" horizontal para receber algum elemento da view 
oView:CreateHorizontalBox( 'TELA' , 100 ) 

// Relaciona o identificador (ID) da View com o "box" para exibição 
oView:SetOwnerView( 'VIEW_ZAE','TELA' ) 
oView:EnableTitleView('VIEW_ZAE','Clientes' )	
oView:SetViewProperty('VIEW_ZAE','SETCOLUMNSEPARATOR', {10})

//Força o fechamento da janela na confirmação
oView:SetCloseOnOk({||.T.})
	
// Retorna o objeto de View criado 
Return oView


Static Function ModelDef() 

// Cria o objeto do Modelo de Dados
Local oModel // Modelo de dados que será construído 

// Cria a estrutura a ser usada no Modelo de Dados 
Local oStruZAE := FWFormStruct( 1, 'ZAE' , /*bAvalCampo*/,/*lViewUsado*/ )

Local bVldPos := {|| ZPCPC01_POS(oModel)} //Validação ao clicar no Confirmar
Local bCommit := {|| ZPCPC01_CMT(oModel)} //Altera Reg após Salvar

oModel := MPFormModel():New('CADCLIEN', ,bVldPos, bCommit)

// Adiciona a descrição do Modelo de Dados
oModel:SetDescription('Clientes')

// Adiciona ao modelo um componente de formulário 
oModel:AddFields( 'ZAEMASTER', /*cOwner*/, oStruZAE) 

bPos := {|oModelGrid | fTudoOkGrid(oModelGrid)}

bPre := {|oModelGrid, nLinha, cAcao, cCampo, xValue, xValueAntigo | fGridbPre(oModelGrid, nLinha, cAcao,; 
cCampo, xValue, xValueAntigo ) }

//Define a chave primaria utilizada pelo modelo
oModel:SetPrimaryKey({'ZAE_FILIAL', 'ZAE_LINHA'})

// Adiciona a descrição do Componente do Modelo de Dados 
oModel:GetModel( 'ZAEMASTER' ):SetDescription( 'XCliente' ) 

// Retorna o Modelo de dados 
Return oModel


// Rotina ao Conformar
Static Function ZPCPC01_POS(oModel)
Local cTipo     := oModel:GetValue( 'ZAEMASTER', 'ZAE_TIPO' )
Local cLote     := oModel:GetValue( 'ZAEMASTER', 'ZAE_LOTE' )
Local nOperation := oModel:GetOperation()


If nOperation == MODEL_OPERATION_INSERT
    
   ZAE->(DbSetOrder(2)) //ZAE_FILIAL+ZAE_LOTE
   If ZAE->(DbSeek(Xfilial('ZAE')+cLote))
      
      /* verifica se é registro diferente */
      if (cLote == ZAE->ZAE_LOTE)

         Help( ,, 'HELP',, 'Lote já Cadastrado !', 1, 0)      
         Return .F.
         
      EndIf   

   EndIf
    
    
    If cTipo == "2" // Bloqueio
         Help( ,, 'HELP',, 'Não é possivel incluir um registro de desbloqueio !', 1, 0)      
         Return .F.

    EndIF
    
EndIf

Return .T.

// Rotina após Salvar Registro
Static Function ZPCPC01_CMT(oModel)
    Local aArea  := FWGetArea()
    Local nOperation := oModel:GetOperation()
    Local lRet   := .T.
 
    FWFormCommit(oModel)

    If nOperation == MODEL_OPERATION_INSERT

        If M->ZAE_TIPO == "1" // Bloqueio
            reclock("ZAE",.F.)
                ZAE->ZAE_USUARI := Upper(Alltrim(cUsername))
                ZAE->ZAE_DATAB  := dDataBase
            msunlock()
        EndIf
    Endif        

    If nOperation == MODEL_OPERATION_UPDATE

        If ZAE->ZAE_TIPO == "2" // Desbloqueio
            reclock("ZAE",.F.)
                ZAE->ZAE_USUARB := Upper(Alltrim(cUsername))
                ZAE->ZAE_DATAD  := dDataBase
            msunlock()
        Endif    

    EndIf    
     
    FWRestArea(aArea)
Return lRet


