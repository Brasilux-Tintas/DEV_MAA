#Include "protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MTI650FILC
Filtrar os componentes que irão compor a lista de materiais - Protheus x Totvs MES

@author TOTVS
@since Dez/2020
@version P12.1.25
/*/
//-------------------------------------------------------------------
User Function MTI650FILC()

/*
Local cOp        := PARAMIXB[1]
Local cTrt       := PARAMIXB[3]
Local cLoteCtl   := PARAMIXB[4]
Local cNumLote   := PARAMIXB[5]
Local cLocal     := PARAMIXB[6]
Local nQtd       := PARAMIXB[7]
Local nRecno     := PARAMIXB[8]
*/
Local cComp      := PARAMIXB[2]
Local aArea 	 := {SB1->(GetArea()),GetArea()}
Local lRet 		 := .T.
     u_zcfga01( 'MTI650FILC' ) //LGS#2021201 - Gravação de log de utilização da rotina
SB1->(dbSetOrder(1))
If SB1->(MsSeek(xFilial("SB1")+cComp))
	If U_IsProdCusto(SB1->B1_COD)
	   lRet := .F.
	EndIf
Endif	

aEval(aArea,{|x| RestArea(x)})

Return(lRet)
