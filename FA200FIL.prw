User Function FA200FIL()
 
    Local cNumeroTit    As Character
    Local lHelp:=.F.    As Logical
 
    cNumeroTit  := AllTrim(paramIXB[1])+"NF "
 
    //Sua forma para pesquisa do título a receber
    SE1->(DbSelectArea("SE1"))
    SE1->(DbSetOrder(1))
   
 
    If SE1->(DbSeek(FwXFilial("SE1") + cNumeroTit))
        Alert("Título encontrado através do ponto de entrada FA200FIL!")
    Else
        //Só é permitida a manipulação da variável lHelp. Caso queira que o help seja exibido, lHelp deve receber .T.
        lHelp       := .F.
        //Variáveis permitidas para uso, mas que NÃO devem ser manipuladas
        //cNumTit     := ""
        //cEspecie    := ""
    EndIf
 
Return Nil
