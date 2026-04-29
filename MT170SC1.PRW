/*/{Protheus.doc} MT170SC1
Ponto de entrada para liberação automatica de SC quando vier de ponto de pedido
@type function Ponto de Entrada
@version  1.0
@author marioantonaccio
@since 21/10/2025
@return character, sem retorno
/*/
User Function MT170SC1()
Local aArea:=FWGetArea()
    RecLock("SC1",.F.)
    SC1->C1_APROV:="L"
    MsUnLock()

    // Apaga registro na SCR caso tenha
    SCR->(dbSetOrder(1))
    If SCR->(dbSeek(xFilial("SCR")+"SC"+SC1->C1_NUM))
        RecLock("SCR",.F.)
        SCR->(dbDelete())
        MsUnLock()
    End
    
FWRestArea(aArea)    
Return (NIL)
