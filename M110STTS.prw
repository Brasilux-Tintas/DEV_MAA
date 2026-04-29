#INCLUDE "PROTHEUS.CH
/*/{Protheus.doc} M110STTS
Gravar ZERO no campo CR_TOTAL para SC
@type function processamento
@version  1.00
@author marioantonaccio
@since 22/04/2026
@return character, sem retorno
/*/
User Function M110STTS()

    Local aArea   := FwGetArea()
    Local cNumSol := Paramixb[1]
    //Local lCopia  := Paramixb[3]
    Local nOpt    := Paramixb[2]

    Do case
        case nOpt == 1 .or. nOpt == 2
            SCR->(dbSetOrder(1))
            IF SCR->(dbSeek(xFilial("SCR")+"SC"+cNumSol))
                While SCR->(.NOT. EOF()) .And. ;
                    SCR->CR_FILIAL+SCR->CR_TIPO+Alltrim(SCR->CR_NUM) == xFilial("SCR")+"SC"+Alltrim(cNumSol)
                    RecLock("SCR",.F.)
                    SCR->CR_TOTAL:=0
                    MsUnLock()
                    SCR->(dbSkip())
                End
            End
        case nOpt == 3
            //msgalert("Solicitação "+alltrim(cNumSol)+" excluída com sucesso!")
    Endcase

    FwRestArea(aArea)
Return (Nil)
