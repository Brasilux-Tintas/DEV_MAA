#Include "PROTHEUS.ch"
#Include "FWMVCDef.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRPCPX12  ºAutor  ³ André Maester     º Data ³  06/02/2023 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Cadastro Usuarios x Linhas  		                          º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/


//Static aCmpCabT01 := {'ZAC_CODIGO','ZAC_NOME','ZAC_TIPO'}   jose 08/07/2025
Static aCmpCabT01 := {'ZAC_CODIGO','ZAC_TIPO','ZAC_LINHA'}   // Jose 08/07/2025
//Static aCmpIteT01 := {'ZAC_LINHA','ZAC_DLINHA'} jose 08/07/2025
Static aCmpIteT01 := {'ZAC_LINHA','ZAC_USERGI'} // Jose 08/07/2025  'ZAC_TIPO','ZAC_LINHA',
User Function BRPCPX12()

Local aAreOld 	:= {ZAC->(GetArea()),GetArea()} 
Local oBrowser 	:= FWMBrowse():New()



If !u_VldAcesso(funname())
    MessageBox("Acesso não autorizado!---->"+funname(),"Atenção", 48)
	Return 
Endif 

oBrowser:SetAlias("ZAC")
oBrowser:SetDescription('Cadastro Usuários X Linhas de Produtos ')

oBrowser:Activate()

AEval(aAreOld, {|x| RestArea(x) })

Return

Static Function MenuDef()

    Local aRotina := {}
    
    Add Option aRotina Title "Visualizar"	Action "VIEWDEF.BRPCPX12" 	Operation 2 Access 0
    Add Option aRotina Title "Incluir"		Action "VIEWDEF.BRPCPX12"	Operation 3 Access 0
 // Add Option aRotina Title "Alterar"		Action "VIEWDEF.BRPCPX12"	Operation 4 Access 0      Jose  09/07/2025
    Add Option aRotina Title "Excluir"		Action "VIEWDEF.BRPCPX12"	Operation 5 Access 0 
    Add Option aRotina Title "Copiar"		Action "VIEWDEF.BRPCPX12"	Operation 9 Access 0 

Return aRotina


Static Function ModelDef()

    Local oModel 	:= MPFormModel():New('FAT140BR', ,, , )  

    Local oStrCabT01 := FwFormStruct(1,'ZAC',{|cCampo|AScan(aCmpCabT01,AllTrim(cCampo)) <> 0})
    Local oStrIteT01 := FwFormStruct(1,'ZAC',{|cCampo|AScan(aCmpIteT01,AllTrim(cCampo)) <> 0})

    oModel:AddFields('T01MASTER',/*Owner*/	,oStrCabT01)

    oModel:AddGrid('T01DETAIL','T01MASTER',oStrIteT01,,,/*bPreGrid*/,/*bProsGrid*/)

    oModel:SetPrimaryKey({'ZAC_FILIAL','ZAC_CODIGO','ZAC_TIPO','ZAC_LINHA'})

    oModel:SetRelation('T01DETAIL',{{'ZAC_FILIAL','xFilial("ZAC")'},{'ZAC_CODIGO','ZAC_CODIGO'},{'ZAC_TIPO','ZAC_TIPO'},{'ZAC_LINHA','ZAC_LINHA'}},ZAC->(IndexKey(1)))

    oModel:GetModel('T01DETAIL'):SetUniqueLine({'ZAC_LINHA'})

Return oModel


Static Function ViewDef()

    Local oView		:= FWFormView():New()
    Local oModel 	:= FwLoadModel('BRPCPX12')

    Local oStrCabT01 := FwFormStruct(2,'ZAC',{|cCampo|AScan(aCmpCabT01,AllTrim(cCampo)) <> 0})
    Local oStrIteT01 := FwFormStruct(2,'ZAC',{|cCampo|AScan(aCmpIteT01,AllTrim(cCampo)) <> 0})

    oView:SetModel(oModel)

    oView:AddField('VWT01MASTER',oStrCabT01,'T01MASTER')
    oView:AddGrid('VWT01DETAIL',oStrIteT01,'T01DETAIL')

    oView:CreateHorizontalBox('SUPERIOR',20)
    oView:CreateHorizontalBox('INFERIOR',80)

    oView:SetOwnerView('VWT01MASTER','SUPERIOR')
    oView:SetOwnerView('VWT01DETAIL','INFERIOR')

Return oView


User Function VLPCPX12(valor)
	
	Local Retorna := .F.
    
    Dbselectarea("ZAC")
    Dbsetorder(1)
    Dbseek(xFilial("ZAC")+valor)
    If found() 
        MessageBox( 'Linha já atribuída para o Usuário / Tipo de Produto !', "Atenção", 48 )
    Else
        Retorna := .T.
    EndIf

Return Retorna
