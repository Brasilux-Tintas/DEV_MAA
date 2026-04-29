/*/{Protheus.doc} MT120F
Ponto de Entrada na gravação do Pedido
@type function Ponto de Entrada
@version  1.1
@author ?  //Alterado por marioantonaccio
@since  ? // Alterado em 14/11/2025
@return character, sem retorno
/*/
User Function MT120F()

    Local aArea      := FwGetArea()
    Local nLinAtu
    Local aAreaC7    := SC7->(FWGetArea())
    Local nPosItem   := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_ITEM"})
    Local nPosQtde   := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_QUANT"})
    Local nPosVlr    := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRECO"})

    //Verifica se existe o campo na tabela
    If SC7->(FieldPos("C7_X_ORIG")) == 0
        FWRestArea(aAreaC7)
        FWRestArea(aArea)
        Return (NIL)
    End

    SC7->(dbSetOrder(1)) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN

    //Percorrendo todos os itens
    For nLinAtu := 1 To Len(aCols)

        //Linha Deleteda nao considera
        If  GDDeleted(nLinAtu)
            Loop
        End

        //Se conseguir posicionar no registro  grava o valor original do pedido (Qtde x Preco)
        If SC7->(DbSeek(FWxFilial("SC7")+cA120Num+aCols[nLinAtu][nPosItem]))
            RecLock('SC7', .F.)
            SC7->C7_X_ORIG := aCols[nLinAtu][nPosQtde] * aCols[nLinAtu][nPosVlr]
            SC7->(MsUnlock())
        EndIf
        // Verifica se existe SCR
        SCR->(dbSetOrder(1))
        If SCR->(dbSeek(xFilial("SCR")+"IP"+cA120Num))
            RecLock('SC7', .F.)
            SC7->C7_CONAPRO:="B"
            MsUnLock()
        End
    Next

    FWRestArea(aAreaC7)
    FWRestArea(aArea)

Return (NIL)
