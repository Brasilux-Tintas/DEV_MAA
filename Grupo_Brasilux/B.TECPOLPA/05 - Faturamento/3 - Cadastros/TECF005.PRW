#Include 'Protheus.ch'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ TECF005   ºAutor  ³ Nelieder Corneta  º Data ³  01/07/2022 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Browser com dados de reforço e redução                     º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TECPOLPA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/



User Function TECF005()
Local aArea := ZC6->(GetArea())
Private oBrowse

// Instanciamento da Classe de Browse 
oBrowse := FWMBrowse():New() 

// Definição da tabela do Browse 
oBrowse:SetAlias('ZC6') 

// Titulo da Browse 
oBrowse:SetDescription('Cadastros Reforço e Redução')
 
// Opcionalmente pode ser desligado a exibição dos detalhes 
oBrowse:DisableDetails() 

// isso pode não apresentar o menu
//oBrowse:SetMenuDef( 'FSFATC01' )

oBrowse:Activate() 

RestArea(aArea)

Return


Static Function MenuDef()
 
Local aRotina := {}

ADD OPTION aRotina Title 'Visualizar'	Action 'VIEWDEF.TECF005'	OPERATION 2 ACCESS 0 
ADD OPTION aRotina Title 'Incluir'   	Action 'VIEWDEF.TECF005'	OPERATION 3 ACCESS 0 
ADD OPTION aRotina Title 'Alterar'  	Action 'VIEWDEF.TECF005'	OPERATION 4 ACCESS 0 
ADD OPTION aRotina Title 'Excluir'   	Action 'VIEWDEF.TECF005'	OPERATION 5 ACCESS 0 
ADD OPTION aRotina Title 'Imprimir'  	Action 'VIEWDEF.TECF005'	OPERATION 8 ACCESS 0 
ADD OPTION aRotina Title 'Copiar'    	Action 'VIEWDEF.TECF005'	OPERATION 9 ACCESS 0 

Return aRotina



Static Function ModelDef() 

// Cria o objeto do Modelo de Dados
Local oModel 

// Cria a estrutura a ser usada no Modelo de Dados 
Local oStruZC6 := FWFormStruct( 1, 'ZC6' , /*bAvalCampo*/,/*lViewUsado*/ )

//bPosModel:={ | oModel | fPosModelo(oModel) }
oModel := MPFormModel():New('F005TEC', ,)

// Adiciona a descriï¿½ï¿½o do Modelo de Dados
oModel:SetDescription('Clientes')

// Adiciona ao modelo um componente de formulï¿½rio 
oModel:AddFields( 'ZC6MASTER', /*cOwner*/, oStruZC6) 

//Define a chave primaria utilizada pelo modelo
oModel:SetPrimaryKey({'ZC6_FILIAL', 'ZC6_NUM'})

// Adiciona a descriï¿½ï¿½o do Componente do Modelo de Dados 
oModel:GetModel( 'ZC6MASTER' ):SetDescription( 'XCoca' ) 

// Retorna o Modelo de dados 
Return oModel

Static Function ViewDef() 

// Interface de visualizaï¿½ï¿½o construï¿½da 
Local oView

// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado 
Local oModel := ModelDef() 

// Cria a estrutura a ser usada na View 
Local oStruZC6 := FWFormStruct( 2, 'ZC6' ) 

// Cria o objeto de View 
oView := FWFormView():New() 

// Define qual o Modelo de dados serï¿½ utilizado na View 
oView:SetModel( oModel ) 

// Adiciona no nosso View um controle do tipo formulï¿½rio 
// (antiga Enchoice) 
oView:AddField( 'VIEW_ZC6', oStruZC6, 'ZC6MASTER' )

// Criar um "box" horizontal para receber algum elemento da view 
oView:CreateHorizontalBox( 'TELA' , 100 ) 

// Relaciona o identificador (ID) da View com o "box" para exibiï¿½ï¿½o 
oView:SetOwnerView( 'VIEW_ZC6','TELA' ) 
oView:EnableTitleView('VIEW_ZC6','Clientes' )	
//oView:SetViewProperty('VIEW_SA1','SETCOLUMNSEPARATOR', {10})

//Forï¿½a o fechamento da janela na confirmaï¿½ï¿½o
oView:SetCloseOnOk({||.T.})
	
// Retorna o objeto de View criado 
Return oView
