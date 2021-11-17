#include 'protheus.ch'
#include 'topconn.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A410EXC  ºAutor  ³ Luís G. de Souza   º Data ³  18/08/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Ponto de entrada para validar tratamento da exclusão de pe-º±±
±±º          ³ didos de vendas com Ordens de Produção. Caso haja O.P. ca- º±±
±±º          ³ dastrado no pedido, não deixa excluir.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
25/09/2019 - Luís Gustavo - Adequação para release 12.1.25
*/
User Function A410EXC()
     Local lRet    := .t.
     Local cAliAtu := Alias()
     Local nConPed := 0
     Local cAuxMen := ""
     Local cQry1   := ""
     Local _cGrpEmp

    _cGrpEmp := ALLTRIM(FWGrpCompany())
     If _cGrpEmp == "01" //Apenas empresas do Grupo 01 (TecPolpa e UnionSur não entram)
        cQry1 += "SELECT C6_ITEM,C6_PRODUTO,C6_NUMOP,C6_NUMLOTE "
        cQry1 += "FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "
        cQry1 += "WHERE SC6.C6_FILIAL  = '"+xFilial("SC6")+"' "
        cQry1 += "  AND SC6.D_E_L_E_T_ = '' "
        cQry1 += "  AND SC6.C6_NUM     = '"+M->C5_NUM+"' "
        cQry1 += "  AND SC6.C6_NUMLOTE <> '' "
        TCQuery cQry1 ALIAS "QPED" NEW
        DbSelectArea("QPED")
        While !Eof()
              nConPed += 1
              cAuxMen += "ITEM / PRODUTO: "+Alltrim(QPED->C6_ITEM)+" / "+Transform(QPED->C6_PRODUTO, "@R XXX99.99.999-99")+" - OP / LOTE: "+Alltrim(QPED->C6_NUMOP)+" / "+Alltrim(QPED->C6_NUMLOTE)+CHR(10)+CHR(13)
              DbSelectArea("QPED")
              DbSkip()
        EndDo
        DbSelectArea("QPED")
        DbCloseArea()
        If nConPed > 0
           cMsgPed := "Existe(m)"+Alltrim(TransForm(nConPed, "9999"))+" item(ns) com Ordem de Produção gerada! Deseja MESMO excluir este pedido?"
           lRet := MsgYesNo(cMsgPed, "Pergunta")
        Endif                                         
        If lRet      
           //Gravar alteração no cad. pedidos para evitar exclusão de pedidos já faturados no B6
           M->C5_ESPECI3 = 'EXCLUIDO'
        Endif
        DbSelectArea(cAliAtu)
     Endif
Return(lRet)
