#include "PROTHEUS.ch"
#Include 'FWMVCDef.ch'



/* tabela ZA7 kit coca cola */
Static aCmpCabT01 := {'ZA7_CODIGO','ZA7_DESCRI'}
Static aCmpIteT01 := {'ZA7_SEQ','ZA7_COMPON','ZA7_DESCCO','ZA7_EMBAL','ZA7_QTD','ZA7_PAI','ZA7_QTDFIL'}

User Function BRFAT106()
Local aAreOld 
Local oBrowser 	:= FWMBrowse():New()

 If FWCodEmp() <> '11'
     MessageBox( "Esta operação só pode ser executada na TecPolpa!", "Atenção", 48 )
	return NIL 
 EndIf

aAreOld 	:= {ZA7->(GetArea()),GetArea()} 


oBrowser:SetAlias("ZA7")
oBrowser:SetDescription('Cadastro Kit Coca Cola')

/* exemplo de como adicionar botão em açoes relacionadas */
//oBrowser:AddButton("Enviar Mensagem"	, { || U_MCFG006M()},,,, .F., 2 )

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

bPos := {|oModelGrid | fTudoOkGrid(oModelGrid)}

bPre := {|oModelGrid, nLinha, cAcao, cCampo, xValue, xValueAntigo | fGridbPre(oModelGrid, nLinha, cAcao,; 
cCampo, xValue, xValueAntigo ) }

oModel:AddGrid('T01DETAIL','T01MASTER',oStrIteT01,,,bPre,bPos)




 
oModel:SetPrimaryKey({'ZA7_FILIAL','ZA7_CODIGO'})

oModel:SetRelation('T01DETAIL',{{'ZA7_FILIAL','xFilial("ZA7")'},{'ZA7_CODIGO','ZA7_CODIGO'}},ZA7->(IndexKey(1)))

//oModel:GetModel('T01DETAIL'):SetUniqueLine({'Z0_CODPRD'})

//oStrIteT01:AddTrigger( 'Z0_COTA', 'Z0_SALEST',{|| .T. }, {|| 1000   } )

Return oModel

Static Function FAT106PS(oModel)
Local lRet       := .T.

//MsgAlert('Não é permitido incluir')

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

//oView:SetViewProperty( 'VWT01MASTER', MsgAlert('aaa'),  {VK_F12} )



Return oView

Static Function fTudoOkGrid(oModelGrid)
Local nLinha := 0
Local Conta := 0
Local Conta_Filhos := 0
Local QtdFil := 0
Local Pai

return

/* varre grid */
For nLinha   := 1 To oModelGrid:Length()
    
    /* posiciona na linha da grid */
    oModelGrid:GoLine( nLinha )
    
    /* verifica se linha possui filhos */
    if (oModelGrid:GetValue("ZA7_QTDFIL")) > 0
        
        /* Identifica quem é o Pai */
        Pai := oModelGrid:GetValue("ZA7_COMPON")

        /* varre qtd de filhos para validar se existe pai */
        Conta_Filhos := 0
        QtdFil := oModelGrid:GetValue("ZA7_QTDFIL")
        For Conta := 1 To QtdFil
            oModelGrid:GoLine( nLinha+Conta )
    
             if oModelGrid:GetValue("ZA7_PAI") <> Pai
                MsgAlert('Atenção : Erro em relacionamento de Filho e Pai na linha -> ' + Alltrim(Str(nLinha+Conta))+'º')
                //oModelGrid:GoLine( nLinha+Conta )
                Return .F.
             EndIf
            Conta_Filhos := Conta_Filhos + oModelGrid:GetValue("ZA7_QTD")

            if Conta_Filhos >= QtdFil
                Exit
            End

        Next

    Endif
Next

Return .T.

Static Function fGridbPre(oModelGrid, nLinha, cAcao, cCampo, xValue, xValueAntigo)
Local lRet := .T.


if (cAcao == "SETVALUE") .AND. (cCampo == "ZA7_SEQ")
    MsgAlert('aaa')
    Falinha(oModelGrid,xValue)
EndIf



//Local i := 1
//Local xPai
//"ADDLINE" linha nova
//"SETVALUE" campo setado

/* if cAcao == "ADDLINE"
    //MsgAlert(cCampo)
    if oModelGrid != nil .and. oModelGrid:isActive()
        MsgAlert('entrou')
        oModelGrid:SetValue("ZA7_DESCRI", "111111")
    EndIf    
 EndIf*/

/* if (cAcao == "SETVALUE") .AND. (cCampo == "ZA7_QTDFIL")
   xPai := oModelGrid:GetValue("ZA7_COMPON")
   for i:= 1 to xValue
    
    oModelGrid:AddLine()
    oModelGrid:LoadValue("ZA7_DESCRI", "")
    oModelGrid:LoadValue("ZA7_PAI", xPai )
   Next i
    if oModelGrid != nil .and. oModelGrid:isActive()
        MsgAlert(nLinha)
        oModelGrid:GoLine(nLinha)
        oModelGrid:LoadValue("ZA7_EMBAL", 'xValue' )
        oModelGrid:LoadValue("ZA7_DESCRI", "aaaa")
        oModelGrid:LoadValue("ZA7_COMPON", '20')
        oModelGrid:LoadValue("ZA7_QTDFIL", 5)
        oModelGrid:LoadValue("ZA7_QTD", 5)
    EndIf    


 EndIf	*/


Return lRet


Static Function Falinha(oModelGrid,Seq)
Local nLinha := 0
Local oView		:= FWFormView():New()
//Local oModel 	:= FwLoadModel('BRFAT106')
/* varre grid */
For nLinha   := 1 To oModelGrid:Length()
    
    /* posiciona na linha da grid */
    //oModelGrid:GoLine( nLinha )
    if nLinha == val(Seq)
        oModelGrid:SetLine(nLinha)
        //oModelGrid:AddLine()
        exit
    EndIf 
Next

oView:Refresh()
Return .T.
