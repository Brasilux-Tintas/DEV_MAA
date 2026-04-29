#INCLUDE "rwmake.ch"
/*/{Protheus.doc} MT120LOK
@description Valida o contrato de parceria
@type function Ponto de Entrada
@version  1.00
@author marioantonaccio
@since 18/02/2026
@return logical, se permite ou nao a gravacao dos ajustes
/*/
User Function MT120LOK()
	Local aArea     := FwGetArea()
	Local lRet      := .T.
	Local nPosItSc  := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_ITEMSC"})
	Local nPosNumSc := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_NUMSC"})

	If nTipoPed == 2
		If .NOT. Empty(aCols[n][nPosNumSC]) .And. .NOT. Empty(aCols[n][nPosItSC])
			SC3->(dbSetOrder(1))
			If SC3->(MsSeek(xFilial("SC3")+aCols[n][nPosNumSC]+aCols[n][nPosItSC]))
				If SC3->C3_DATPRF < dDataBase
					FWAlertError("Contrato de Parceria Vencido! Verifique!","Contrato Vencido")
					lRet := .F.
				End
				If lRet
					If (SC3->C3_FORNECE <> cA120Forn) .or. (SC3->C3_FORNECE == cA120Forn .and.  SC3->C3_LOJA  <> cA120Loj  )
						FWAlertWarning("Fornecedor/Loja Diverge do contrato! Verifique!","Contrato Vencido")
						//lRet := .F.
					End
				End
			EndIf
		End
	End
	FwRestArea(aArea)
Return (lRet)

