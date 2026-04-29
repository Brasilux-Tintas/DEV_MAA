#include "PROTHEUS.ch"
#Include 'FWMVCDef.ch'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFAT107  ºAutor  ³ Nelieder Corneta  º Data ³  01/07/2022 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Cadastro de Linhas & Embalagens                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/


Static aCmpCabT01 := {'ZA8_LINHA','ZA8_NLINHA'}
Static aCmpIteT01 := {'ZA8_EMB','ZA8_NEMB','ZA8_QTD'}

User Function BRFAT107()
Local aAreOld 	:= {ZA8->(GetArea()),GetArea()} 
Local oBrowser 	:= FWMBrowse():New()

oBrowser:SetAlias("ZA8")
oBrowser:SetDescription('Cadastro Linhas & Embalagens ')

oBrowser:Activate()

AEval(aAreOld, {|x| RestArea(x) })

Return

Static Function MenuDef()

Local aRotina := {}

Add Option aRotina Title "Visualizar"	Action "VIEWDEF.BRFAT107" 	Operation 2 Access 0
Add Option aRotina Title "Incluir"		Action "VIEWDEF.BRFAT107"	Operation 3 Access 0
Add Option aRotina Title "Alterar"		Action "VIEWDEF.BRFAT107"	Operation 4 Access 0
Add Option aRotina Title "Excluir"		Action "VIEWDEF.BRFAT107"	Operation 5 Access 0 
Add Option aRotina Title "Copiar"		Action "VIEWDEF.BRFAT107"	Operation 9 Access 0 

Return aRotina


Static Function ModelDef()
Local oModel 	:= MPFormModel():New('FAT140BR', ,, , )

Local oStrCabT01 := FwFormStruct(1,'ZA8',{|cCampo|AScan(aCmpCabT01,AllTrim(cCampo)) <> 0})
Local oStrIteT01 := FwFormStruct(1,'ZA8',{|cCampo|AScan(aCmpIteT01,AllTrim(cCampo)) <> 0})

oModel:AddFields('T01MASTER',/*Owner*/	,oStrCabT01)

oModel:AddGrid('T01DETAIL','T01MASTER',oStrIteT01,,,/*bPreGrid*/,/*bProsGrid*/)
 
oModel:SetPrimaryKey({'ZA8_FILIAL','ZA8_LINHA'})

oModel:SetRelation('T01DETAIL',{{'ZA8_FILIAL','xFilial("ZA8")'},{'ZA8_LINHA','ZA8_LINHA'}},ZA8->(IndexKey(1)))

oModel:GetModel('T01DETAIL'):SetUniqueLine({'ZA8_EMB'})

Return oModel

Static Function ViewDef()

Local oView		:= FWFormView():New()
Local oModel 	:= FwLoadModel('BRFAT107')

Local oStrCabT01 := FwFormStruct(2,'ZA8',{|cCampo|AScan(aCmpCabT01,AllTrim(cCampo)) <> 0})
Local oStrIteT01 := FwFormStruct(2,'ZA8',{|cCampo|AScan(aCmpIteT01,AllTrim(cCampo)) <> 0})

oView:SetModel(oModel)

oView:AddField('VWT01MASTER',oStrCabT01,'T01MASTER')
oView:AddGrid('VWT01DETAIL',oStrIteT01,'T01DETAIL')

oView:CreateHorizontalBox('SUPERIOR',20)
oView:CreateHorizontalBox('INFERIOR',80)

oView:SetOwnerView('VWT01MASTER','SUPERIOR')
oView:SetOwnerView('VWT01DETAIL','INFERIOR')

Return oView


User Function VLFAT107(valor)
local retorna := .F.

    dbselectarea("ZA8")
    dbsetorder(1)
    dbseek(xFilial("ZA8")+valor)
    If found() 
        MessageBox( 'Linha já cadastrada !', "Atenção", 48 )
    else
        retorna := .T.
    EndIf

Return retorna
