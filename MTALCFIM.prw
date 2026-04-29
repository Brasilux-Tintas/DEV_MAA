#include "totvs.ch"
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TOPCONN.CH'

/*/{Protheus.doc} MTALCFIM
Rotina automatica para aprovar pedidos de compra que tenham como origem SC de Ponto de Pedido (MATA170)
@type function Processamento
@version  1.00
@author marioantonaccio
@since 20/01/2026
@return character, sem retorno
@see
ParamIXB[1] = Array com informações do documento onde:
[1] [1] Número do documento
[1][2] Tipo de Documento
[1][3] Valor do Documento
[1][4] Código do Aprovador
[1][5] Código do Usuário
[1][6] Grupo do Aprovador
[1][7] Aprovador Superior
[1][8] Moeda do Documento
[1][9] Taxa da Moeda
[1][10] Data de Emissão do Documento
[1][11] Grupo de Compras

ParamIXB[3] = nOper (Operação a ser executada pela alçada de aprovação)
1 = Inclusão do Documento
2 = Transferência da Alçada para o Superior
3 = Exclusão do documento
4 = Aprovação do documento
5 = Estorno da Aprovação
6 = Bloqueio manual
7 = Evento de rejeição do documento
/*/

User function MTALCFIM()

    //   Local cDocSF1   := ParamIXB[4] // Chave(Alternativa) do SF1 para exclusão SCR.
    //   Local lResiduo  := ParamIXB[5] // Eliminação de Residuos.
    //   Local dDataRef  := ParamIXB[2] // Data de referência para o saldo.
    Local aArea   := FwGetArea() as Array
    Local aDocto  := ParamIXB[1] as Array // Array com informações do documento.
    Local aRegSCR := {}          as Array
    Local lRet    := .T.         as Logical
    Local nI                     as Numeric
    Local nOper   := ParamIXB[3] as Numeric // Operação a ser executada.

    Local lBloqueiaAuto := .F.
    Local nPerc         := 0
    Local nPrecoAnt     := 0
    Local nPrecoNovo    := 0
    Local nQtd          := 0
    Local cProduto      := ""
    Local cFornecedor   := ""

    //Cancelamento retorna o caminho original
    If nOper == 3
        Return(.T.)
    End

    //Aprova Automaticamente se a Solicitacao de Compra do Pedido for originaria de Ponto de Pedido (Rotina MATA170) - MAA 20260120
    SC7->(dbSetOrder(1))
    If SC7->(dbSeek(xFilial("SC7")+aDocto[1]))
        If .NOT. Empty(SC7->C7_NUMSC)
            SC1->(dbSetOrder(1))
            SC1->(dbSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC))
            If .NOT. Upper(AllTrim(SC1->C1_ORIGEM)) == "MATA170" //se nao Solicitaçao por ponto de pedido vai para liberaçao
                lRet:=.T.
                Return(.T.)
            Else
                //Se nao
                //Fecha cursor se já existir
                If Select("QRY_SCR") > 0
                    QRY_SCR->(DbCloseArea())
                EndIf
                BeginSql Alias "QRY_SCR"
                    SELECT
                        R_E_C_N_O_ AS REGSCR,
                        CR_VALLIB
                    FROM
                        %TABLE:SCR% SCR
                    WHERE
                        SCR.%NOTDEL%
                        AND SCR.CR_FILIAL = %XFILIAL:SCR%
                        AND SCR.CR_STATUS IN ('01', '02')
                        AND SCR.CR_TIPO IN ('IP', 'PC')
                        AND SCR.CR_NUM = %EXP:aDocto[1]%
                    ORDER BY
                        SCR.CR_NIVEL
                EndSQL

                While .NOT. QRY_SCR->(EOF())
                    AADD(aRegSCR,QRY_SCR->REGSCR)
                    QRY_SCR->(dbSkip())
                End
                //QRY_SCR->(dbCloseArea())

                For nI:=1 To Len(aRegSCR)

                    SCR->(dbGoTo(aRegSCR[nI]))

                    MaAlcDoc({ SCR->CR_NUM, SCR->CR_TIPO, , SCR->CR_APROV, , SCR->CR_GRUPO, , , , , }, dDataBase, 4)

                    SCR->(dbGoto(aRegSCR[nI]))
                    RecLock("SCR",.F.)
                    SCR->CR_OBS := "Aprovação Autom. por SC por Ponto Pedido"
                    If SCR->(FieldPos("CR_AUTOMAT")) > 0
                        SCR->CR_AUTOMAT := 'S'
                    EndIf
                    SCR->CR_DATALIB := Date()
                    SCR->CR_USERLIB := "Autom."
                    SCR->CR_LIBAPRO := "Autom."
                    SCR->CR_TIPOLIM := ""
                    SCR->CR_VALLIB := QRY_SCR->CR_VALLIB
                    MsUnlock()
                Next

                QRY_SCR->(dbCloseArea())

            End
        End
    else
        lRet:=.T.
        Return(.T.)
    End

    //Lucas Bonfim - Ajuste para tolerância - Validar último preço de compra do produto. Se for maior que 5%, pedido passa por aprovação. 2026-03-24
    //Percorre itens do pedido
    If Funname() == "MATA121" .AND. nOper == 1
        SC7->(dbSetOrder(1))
        If SC7->(dbSeek(xFilial("SC7")+aDocto[1]))

            While SC7->(!EOF()) .And. SC7->C7_NUM == aDocto[1]

                cProduto    := SC7->C7_PRODUTO
                cFornecedor := SC7->C7_FORNECE
                nQtd        := SC7->C7_QUANT
                nPrecoNovo  := IIf(nQtd > 0, SC7->C7_TOTAL / nQtd, 0)

                nPrecoAnt := fBusUltPrc(cProduto, cFornecedor)

                //Se não encontrou preço anterior -> bloqueia
                If nPrecoAnt <= 0
                    lRet:=.t.
                    lBloqueiaAuto := .T.
                    Exit
                EndIf

                //Calcula percentual
                nPerc := ((nPrecoNovo - nPrecoAnt) / nPrecoAnt) * 100

                If nPerc > SuperGetMv("BR_TOLPRC",.F.,5)
                    lBloqueiaAuto := .T.
                    lRet:=.T.
                    Exit
                EndIf

                SC7->(dbSkip())
            EndDo
        EndIf

        //Se encontrou qualquer divergência, NÃO aprova automático
        If lBloqueiaAuto
            lRet:=.T.
            Return(.T.)
        EndIf
    EndIf
    //Fim Lucas

    FwRestArea(aArea)

Return (lRet)

Static Function fBusUltPrc(cProduto, cFornecedor)

    Local dMaiorData := Ctod("")
    Local nPreco     := 0
    Local nI         := 0
    Local cCampoData := ""
    Local cCampoPreco:= ""
    Local dData      := Ctod("")

    SA5->(dbSetOrder(2)) //Filial + Produto + Fornecedor

    If SA5->(dbSeek(xFilial("SA5")+cProduto+cFornecedor))

        For nI := 1 To 12

            cCampoData  := "A5_DTCOM"  + StrZero(nI,2)
            cCampoPreco := "A5_PRECO"  + StrZero(nI,2)

            dData := SA5->&(cCampoData)

            If !Empty(dData)
                If Empty(dMaiorData) .Or. dData > dMaiorData
                    dMaiorData := dData
                    nPreco     := SA5->&(cCampoPreco)
                EndIf
            EndIf

        Next

    EndIf

Return nPreco
