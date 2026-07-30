#Include "Protheus.ch"
#include "topconn.ch"

//Lucas Bonfim - 15-06-2026 - Substituição da cEmpAnt - chamado pelo P.E MA410MNU. Adequação release 25.
User Function zGerPedD(aCab, aItens, aProdBloq, aProdNVend, nPedidoOrig, cObs, nNovoPedido)

    Local nOpc        := 3
    Local nW          := 0
    Local nZ          := 0
    Local cQry1       := ""
    Local cFileLog    := ""
    Local cPath       := ""

    Private lMsErroAuto := .F.

    RpcSetEnv("01", "010101")

    Begin Transaction

        //Libera produtos bloqueados
        For nW := 1 To Len(aProdBloq)

            cQry1 := ""
            cQry1 += " UPDATE " + RetSqlName("SB1")
            cQry1 += " SET B1_MSBLQL = '2'"
            cQry1 += " WHERE B1_FILIAL = '010101'"
            cQry1 += " AND B1_MSBLQL = '1'"
            cQry1 += " AND D_E_L_E_T_ = ''"
            cQry1 += " AND B1_COD = '" + aProdBloq[nW][1] + "'"

            TcSqlExec(cQry1)

        Next nW

        For nZ := 1 To Len(aProdNVend)

            cQry1 := ""
            cQry1 += " UPDATE " + RetSqlName("SB1")
            cQry1 += " SET B1_VEND = 'S'"
            cQry1 += " WHERE B1_FILIAL = '010101'"
            cQry1 += " AND B1_VEND = 'N'"
            cQry1 += " AND D_E_L_E_T_ = ''"
            cQry1 += " AND B1_COD = '" + aProdNVend[nZ][1] + "'"

            TcSqlExec(cQry1)

        Next nZ

        MsExecAuto({|x,y,z| MATA410(x,y,z)}, aCab, aItens, nOpc )

        If lMsErroAuto

            DisarmTransaction()

            cFileLog := NomeAutoLog()

            If !Empty(cFileLog)
                MostraErro(cPath, cFileLog)
            EndIf

        Else

            ConfirmSX8()

        EndIf

        //Rebloqueia produtos
        For nW := 1 To Len(aProdBloq)

            cQry1 := ""
            cQry1 += " UPDATE " + RetSqlName("SB1")
            cQry1 += " SET B1_MSBLQL = '1'"
            cQry1 += " WHERE B1_FILIAL = '010101'"
            cQry1 += " AND B1_MSBLQL = '2'"
            cQry1 += " AND D_E_L_E_T_ = ''"
            cQry1 += " AND B1_COD = '" + aProdBloq[nW][1] + "'"

            TcSqlExec(cQry1)

        Next nW

        For nZ := 1 To Len(aProdNVend)

            cQry1 := ""
            cQry1 += " UPDATE " + RetSqlName("SB1")
            cQry1 += " SET B1_VEND = 'N'"
            cQry1 += " WHERE B1_FILIAL = '010101'"
            cQry1 += " AND B1_VEND = 'S'"
            cQry1 += " AND D_E_L_E_T_ = ''"
            cQry1 += " AND B1_COD = '" + aProdNVend[nZ][1] + "'"

            TcSqlExec(cQry1)

        Next nZ

    End Transaction

    RpcClearEnv()

    //Atualiza pedido origem somente se gerou corretamente
    If !lMsErroAuto
 
        RpcSetEnv("01", "010108")
 
        DbSelectArea("SC5")
        DbSetOrder(1)
 
        If DbSeek(xFilial("SC5") + nPedidoOrig)
 
            RecLock("SC5", .F.)
 
            SC5->C5_PEDDEP := cValToChar(nNovoPedido)
 
            MsUnlock()
 
        EndIf
 
        RpcClearEnv()
 
    EndIf

Return
