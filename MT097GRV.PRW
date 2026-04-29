/*/{Protheus.doc} User Function MT097GRV
    Permite ou não a gravação de nova alçada de compras
    @type  Function Ponto de Entrada
    @author MAA
    @since 28/11/2025
    @version P12
    @return Logical, Grava Alcada ou nao
    @see Considere o paramentro BR_TOLPRC - % Tolerancia de preco
    Parametros
    01 -ExpA1: Array com informacoes do documento
       [1] Numero do documento
       [2] Tipo de Documento
           AE: Autorização de Entrega
           CO: Cotações
           CP: Contrato de Parceria
           NF: Nota Fiscal
           PC: Pedido de Compras
           SA: Solicitações de Armazenagem
           SC: Solicitações de Compras
           ST: Solicitação de Transferência
           IP: Item do Pedido de Compras
           CT: Tipo do Contrato
           IC: Item Contrato
           RV: Tipo do Contrato - Revisão
           IR: Item Contrato - Revisão
           MD: Medições
           IM: Item Medições
           GA: Documento de Garantia
           A1->A9: Documento do Agroindustria
       [3] Valor do Documento
       [4] Codigo do Aprovador
       [5] Codigo do Usuario
       [6] Grupo do Aprovador
       [7] Aprovador Superior
       [8] Moeda do Documento
       [9] Taxa da Moeda
      [10] Data de Emissao do Documento
      [11] Grupo de Compras
      [12] Aprovador Original
    02 - ExpD :Contem a data de referencia para o saldo
    03 - ExpC:Contém a operação a ser executada.
        1-Inclusão do Documento;
        2-Transferência para Superior;
        3-Exclusão;
        4-Aprovação;
        5-Estorno;
        6-Bloqueio de aprovação
    04 - ExpC:Contem a chave da SF1 para exclusão do SCR
    05 - ExpL:Verifica se existe a eliminação de resíduo
    06 - ExpC:Código Aprovador
    07 - ExpC:Código Usuário
    08 - ExpC:Código Grupo Aprovação
/*/

User Function MT097GRV()
  //  Local aArea        := FWGetArea() as array
  //  Local aAreaSCR                    as array
   // Local cPedCom      := " "         as character
  //  Local cTipo        := " "         as character
    Local lGravaAlcada := .T.         as logical
  //  Local nPerc        := 0           as numeric
  //  Local nValor       := 0           as numeric

    //Se for NFC(cotacao) retorna verdadeiro para executar alçada
   /*
    If AllTrim(FunName()) == "PGCA010" .or. AllTrim(FunName()) == "MATA110" .or. Len(PARAMIXB) == 0
        FWRestArea(aArea)
        Return (.T.)
    End

    If Len(PARAMIXB) > 0
        cPedCom := PARAMIXB[4]
        cTipo   := PARAMIXB[1][2]
        nValor  := PARAMIXB[1][3]
    End

    DbSelectArea("SCR")
    aAreaSCR:=FWGetArea()

    SCR->(dbSetOrder(3))

    If SCR->(DbSeek(xFilial("SCR") + cTipo + cPedCom))

        While SCR->(.NOT. EOF() .and. SCR->CR_NUM == cPedCom)
            // CR_STATUS  01=Aguardando nivel anterior;02=Pendente;03=Liberado;04=Bloqueado;05=Liberado outro usuario;06=Rejeitado
            // Se total do Pedido for inferior ao que foi aprovado, nao retorna para aprovação
            IF SCR->CR_STATUS $ "03,05"
                If  SCR->CR_TOTAL >= nValor
                    lGravaAlcada     := .F.
                Else
                    // Se o valor do pedido for maior que o aprovado, verifica se esta dentro do percentual de tolerancia
                    // Se esta dentro do percentual, nao envia para nova aprovação
                    If nValor > 0
                        nPerc:= ((1-(SCR->CR_TOTAL/nValor)) * 100 )
                        If nPerc >= SuperGetMv("BR_TOLPRC",.F.,5)
                            lGravaAlcada     := .T.
                        End
                    End
                End
            EndIF
            SCR->(DBSkip())
        EndDo

    Endif
    FWRestArea(aAreaSCR)
    FwRestArea(aArea)
*/
Return (lGravaAlcada)
