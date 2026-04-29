#Include 'Protheus.ch'
/*/{Protheus.doc} MT170FIM
Ponto de Entrada ao Final da Geração de Solicitação de compra por PP - VErifica se esta Lberada
@type function Ponto de Entrada
@version 1.00
@author marioantonaccio
@since 06/03/2026
@return character, sem retorno
@see
ParamIxb: aSolic Array
1 - Produto
2 - Numero SC
3 - Item SC
/*/
User Function MT170FIM()

    Local aArea  := FwGetArea() as Array
    Local aSolic := PARAMIXB[1] as Array
    Local nI                    as Numeric

    For nI:=1 To Len(aSolic)
        SC1->(dbSetOrder(1))
        If SC1->(dbSeek(xFilial("SC1")+aSolic[nI][2]+aSolic[nI][3]))
            //Força Liberação da SC
            If SC1->C1_APROV <> 'L'
                RecLock("SC1",.F.)
                SC1->C1_APROV:="L"
                MsUnLock()

                //Apaga processo de Liberação da SC pois tem que vir liberada
                SCR->(dbSetOrder(1))
                If SCR->(dbSeek(xFilial("SCR")+"SC"+SC1->C1_NUM))
                    RecLock("SCR",.F.)
                    SCR->(DBDelete())
                    MsUnLock()
                End
            End
        End
    Next
    FwRestArea(aArea)
Return
