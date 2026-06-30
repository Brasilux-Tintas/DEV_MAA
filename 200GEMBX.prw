User Function FA200FIL()
 
    Local cNumeroTit    As Character
 
 a:=1
 b:=1
    cNumeroTit  := AllTrim(paramIXB[1][1])
 
    //Sua forma para pesquisa do título a receber
    SE1->(DbSelectArea("SE1"))
    SE1->(DbSetOrder(1))
   
 
    If SE1->(DbSeek(FwXFilial("SE1") +Substr(cNumeroTit,1,3)+ Substr(cNumeroTit,4,6)+"   "+ Substr(cNumeroTit,10,2)+"NF "))
        Alert("Título encontrado através do ponto de entrada FA200FIL!")
    Else
        //Só é permitida a manipulação da variável lHelp. Caso queira que o help seja exibido, lHelp deve receber .T.
        lHelp       := .F.
        //Variáveis permitidas para uso, mas que NÃO devem ser manipuladas
        //cNumTit     := ""
        //cEspecie    := ""
        ALERT(CnUMTIT + " " +CEspecie)
    EndIf
 
Return Nil
