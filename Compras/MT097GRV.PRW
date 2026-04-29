/*/{Protheus.doc} User Function MT097GRV
    Permite ou não a gravação de nova alçada de compras
    @type  Function Ponto de Entrada
    @author MAA
    @since 28/11/2025
    @version P12
    @return Logical, Grava Alcada ou nao
    @see Considere o paramentro BR_TOLPRC - % Tolerancia de preco
/*/

User Function MT097GRV()
    Local cPedCom      := PARAMIXB[4] as character
    Local lGravaAlcada := .T.         as logical
    Local nPerc        := 0           as numeric
    Local aArea        := FWGetArea() as array
    Local aAreaSCR

    //Se for NFC(cotacao) retorna verdadeiro para executar alçada
    If AllTrim(FunName()) == "PGCA010" .or. AllTrim(FunName()) == "MATA110"
        FWRestArea(aArea)
        Return (.T.)
    End

    DbSelectArea("SCR")
    aAreaSCR:=FWGetArea()

    SCR->(dbSetOrder(3))

    If SCR->(DbSeek(xFilial("SCR") + 'IP' + cPedCom))

        While SCR->(.NOT. EOF() .and. SCR->CR_NUM == cPedCom)
            // CR_STATUS  01=Aguardando nivel anterior;02=Pendente;03=Liberado;04=Bloqueado;05=Liberado outro usuario;06=Rejeitado
            // Se total do Pedido for inferior ao que foi aprovado, nao retorna para aprovação
            IF SCR->CR_STATUS $ "03,05"
                If  SCR->CR_TOTAL >= n120TOTLIB
                    lGravaAlcada     := .F.
                Else
                    // Se o valor do pedido for maior que o aprovado, verifica se esta dentro do percentual de tolerancia
                    // Se esta dentro do percentual, nao envia para nova aprovação
                    nPerc:= ((1-(SCR->CR_TOTAL/n120TotLib)) * 100 )
                    If nPerc <= SuperGetMv("BR_TOLPRC",.F.,5)
                        lGravaAlcada     := .F.
                    End
                End
            EndIF
            SCR->(DBSkip())
        EndDo

        //AE
    ElseIf SCR->(DbSeek(xFilial("SCR") + 'AE' + cPedCom))

        While SCR->(.NOT. EOF() .and. SCR->CR_NUM == cPedCom)
            // CR_STATUS  01=Aguardando nivel anterior;02=Pendente;03=Liberado;04=Bloqueado;05=Liberado outro usuario;06=Rejeitado
            // Se total do Pedido for inferior ao que foi aprovado, nao retorna para aprovação
            IF SCR->CR_STATUS $ "03,05"
                If  SCR->CR_TOTAL >= n120TOTLIB
                    lGravaAlcada     := .F.
                Else
                    // Se o valor do pedido for maior que o aprovado, verifica se esta dentro do percentual de tolerancia
                    // Se esta dentro do percentual, nao envia para nova aprovação
                    nPerc:= ((1-(SCR->CR_TOTAL/n120TotLib)) * 100 )
                    If nPerc <= SuperGetMv("BR_TOLPRC",.F.,5)
                        lGravaAlcada     := .F.
                    End
                End
            EndIF
            SCR->(DBSkip())
        EndDo

    Endif
    FWRestArea(aAreaSCR)
    FwRestArea(aArea)

Return (lGravaAlcada)
