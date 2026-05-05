User Function F200VAR()

    Local cNumeroTit    As Character

    SE1->(DbSetOrder(1))
    cNumeroTit  := AllTrim(paramixb[1][1])+"NF "
    SE1->(DbSelectArea("SE1"))
    SE1->(DbSetOrder(1))


    If SE1->(DbSeek(FwXFilial("SE1") + cNumeroTit))
        Alert("Título encontrado através do ponto de entrada F200VAR!")
    End
Return (NIL)
