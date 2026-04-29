#include "PROTHEUS.ch"
#Include 'FWMVCDef.ch'



/* tabela ZA7 kit coca cola */
Static aCmpCabT01 := {'ZA7_CODIGO','ZA7_DESCRI'}
Static aCmpIteT01 := {'ZA7_SEQ','ZA7_COMPON','ZA7_DESCRI','ZA7_EMBAL','ZA7_QTD','ZA7_PAI','ZA7_QTDFIL'}

User Function BRFAT106()

Local aAreOld 	:= {ZA7->(GetArea()),GetArea()} 
Local oBrowser 	:= FWMBrowse():New()

oBrowser:SetAlias("ZA7")
oBrowser:SetDescription('Cadastro Kit Coca Cola')

oBrowser:Activate()

AEval(aAreOld, {|x| RestArea(x) })

Return

Static Function MenuDef()

Local aRotina := {}

Add Option aRotina Title "Visualizar"	Action "VIEWDEF.BRFAT106" 	Operation 2 Access 0
Add Option aRotina Title "Incluir"		Action "VIEWDEF.BRFAT106"	Operation 3 Access 0
Add Option aRotina Title "Alterar"		Action "VIEWDEF.BRFAT106"	Operation 4 Access 0
Add Option aRotina Title "Excluir"		Action "VIEWDEF.BRFAT106"	Operation 5 Access 0 

Return aRotina


Static Function ModelDef()
Local bVldPos := {|| FAT106PS()} //Validação ao clicar no Confirmar
Local oModel 	:= MPFormModel():New('FAT140BR', ,bVldPos, , )

Local oStrCabT01 := FwFormStruct(1,'ZA7',{|cCampo|AScan(aCmpCabT01,AllTrim(cCampo)) <> 0})
Local oStrIteT01 := FwFormStruct(1,'ZA7',{|cCampo|AScan(aCmpIteT01,AllTrim(cCampo)) <> 0})

/*oModel:SetProperty( 'ZA7_SEQ'    , MVC_VIEW_ORDEM, '01' )
oModel:SetProperty( 'ZA7_COMPON' , MVC_VIEW_ORDEM, '02' )
oModel:SetProperty( 'ZA7_DESCRI' , MVC_VIEW_ORDEM, '03' )*/

//oStr2:RemoveField( 'ZA7_COMPON' )

oModel:AddFields('T01MASTER',/*Owner*/	,oStrCabT01)

//oModel:AddGrid('T01DETAIL','T01MASTER',oStrIteT01,,/*LinhaOk*/)

oModel:AddGrid('T01DETAIL','T01MASTER',oStrIteT01,,,/*bPreGrid*/,/*bProsGrid*/)

 
oModel:SetPrimaryKey({'ZA7_FILIAL','ZA7_CODIGO'})

oModel:SetRelation('T01DETAIL',{{'ZA7_FILIAL','xFilial("ZA7")'},{'ZA7_CODIGO','ZA7_CODIGO'}},ZA7->(IndexKey(1)))

//oModel:GetModel('T01DETAIL'):SetUniqueLine({'Z0_CODPRD'})

//oStrIteT01:AddTrigger( 'Z0_COTA', 'Z0_SALEST',{|| .T. }, {|| 1000   } )

Return oModel

Static Function FAT106PS(oModel)
Local oModelPad  := FWModelActive()
Local lRet       := .T.

If oModelPad:GetOperation() == MODEL_OPERATION_INSERT
    MsgAlert('Não é permitido incluir')
EndIf




Return lRet

Static Function ViewDef()

Local oView		:= FWFormView():New()
Local oModel 	:= FwLoadModel('BRFAT106')

Local oStrCabT01 := FwFormStruct(2,'ZA7',{|cCampo|AScan(aCmpCabT01,AllTrim(cCampo)) <> 0})
Local oStrIteT01 := FwFormStruct(2,'ZA7',{|cCampo|AScan(aCmpIteT01,AllTrim(cCampo)) <> 0})

oView:SetModel(oModel)

oView:AddField('VWT01MASTER',oStrCabT01,'T01MASTER')
oView:AddGrid('VWT01DETAIL',oStrIteT01,'T01DETAIL')

oView:AddIncrementField('VWT01DETAIL','ZA7_SEQ')

oView:CreateHorizontalBox('SUPERIOR',20)
oView:CreateHorizontalBox('INFERIOR',80)

oView:SetOwnerView('VWT01MASTER','SUPERIOR')
oView:SetOwnerView('VWT01DETAIL','INFERIOR')

Return oView
