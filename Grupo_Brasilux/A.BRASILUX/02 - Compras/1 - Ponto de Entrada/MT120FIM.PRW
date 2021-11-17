#Include "Protheus.ch"
 
/*---------------------------------------------------------------------------------*
 | P.E.:  MT120FIM                                                                 |
 | Desc:  Atualização Pedido Compra p/ preencher todos os itens como deposito fechado|
 | Link:  http://tdn.totvs.com/display/public/mp/MT120FIM                          |
 *---------------------------------------------------------------------------------*/
 /*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³  MT120FIM ºAutor  ³ Cleber Oratiº Data ³  28/10/20        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º 28/10/20 ³ Ponto de entrada para completar itens do ped de compra com º±±
±±º          ³ S (C7_DEPOSI) quando o usuario não preenche todos os itens º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function MT120FIM()
	Local cArea      := Alias()
	Local aAreaAnt := U_PegaArea({"SC7","SC3"})
    Local cDep,lDep,nLinAtu,nQtdItens,_cEmpr,_cGrpEmp,_cFilial,_cNumEmp
    Local cPedCom    := PARAMIXB[2]
    Local nPosItem
    //Local ,nPosQtde,nPosVlr,nPosQtde 
     
_cEmpr := alltrim(FWCodEmp())
_cGrpEmp := alltrim(FWGrpCompany())
_cFilial := alltrim(FWCodFil())
_cNumEmp := _cGrpEmp+_cFilial

if (_cGrpEmp == "01") .and. (_cEmpr == "01") //Somente empresas do grupo Brasilux operam com depósito fechado
    nPosItem   := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_ITEM"})
    //nPosQtde   := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_QUJE"})
    //nPosVlr    := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRECO"})

    DbSelectArea('SC7')
    SC7->(dbSetOrder(1)) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
    cDep := "N"
    lDep := .f.
    nQtdItens := Len(aCols)
    //Percorrendo todos os itens
    For nLinAtu := 1 To nQtdItens

        //Se conseguir posicionar no registro
        If SC7->(DbSeek(FWxFilial("SC7")+cPedCom+aCols[nLinAtu][nPosItem]))
            IF !lDep .and. (cDep == "N") .and. (SC7->C7_DEPOSI = "S")
                lDep := .t.
                cDep := "S"
                nLinAtu := 0
            ELSE  
                IF lDep .AND. (SC7->C7_DEPOSI <> "S")
                    RecLock('SC7', .F.)
                    C7_DEPOSI := "S"
                    SC7->(MsUnlock())
                ENDIF
            ENDIF 
        EndIf
    Next
endif     
U_VoltaArea(aAreaAnt)

if !empty(cArea)
	dbselectarea(cArea)
endif

Return
