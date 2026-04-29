#INCLUDE "rwmake.ch"
#INCLUDE "TOTVS.ch"
/*/{Protheus.doc} MT120GRV
@description Valida o contrato de parceria
@type function Ponto de Entrada
@version  1.00
@author marioantonaccio
@since 18/02/2026
@return logical, se permite ou nao a gravacao dos ajustes
/*/
User Function MT120GRV()
	Local aArea     := FwGetArea()
	Local lRet      := .T.
	Local nPosItSc  := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_ITEMSC"})
	Local nPosNumSc := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_NUMSC"})
	Local lInclui  := PARAMIXB[2]
	Local nI

	If nTipoPed == 2 .and. lInclui

		For nI:=1 To Len(aCols)

			If GdDeleted(nI)
				Loop
			End

			If .NOT. Empty(aCols[nI][nPosNumSC]) .And. .NOT. Empty(aCols[nI][nPosItSC])
				SC3->(dbSetOrder(1))
				If SC3->(MsSeek(xFilial("SC3")+aCols[nI][nPosNumSC]+aCols[nI][nPosItSC]))
					If SC3->C3_DATPRF < dDataBase
						FWAlertError("Contrato de Parceria Vencido! "+CRLF+"Linha "+cValToChar(nI)+CRLF+" Verifique!","Contrato Vencido")
						lRet := .F.
						Exit
					End
					If lRet
						If (SC3->C3_FORNECE <> cA120Forn) .or. (SC3->C3_FORNECE == cA120Forn .and.  SC3->C3_LOJA  <> cA120Loj  )
							FWAlertWarning("Fornecedor/Loja Diverge do contrato!"+CRLF+"Linha "+cValToChar(nI)+CRLF+"Verifique!","Contrato Vencido")
							//lRet := .F.
						End
					End
				EndIf
			End
		Next
	End
	FwRestArea(aArea)
Return (lRet)






