#Include 'Protheus.ch'
/*================================================|
|Rotina: MT160GRPC()							  |
|Função: Calcular o custo do produto sem impostos |	
|Autor : Igor Manrique / Chaus					  |
|================================================*/
//25/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function MT160GRPC()
     Local _cTes 		:= ""
     Local _cForne		:= SC7->C7_FORNECE
     Local _cLoja		:= SC7->C7_LOJA
     Local _cProd		:= SC7->C7_PRODUTO
     Local _nValUnit		:= SC7->C7_PRECO
     Local _nQuant		:= SC7->C7_QUANT
     Local _nPrcTot		:= SC7->C7_TOTAL
     Local _nItem		:= 0 //Val(SC7->C7_ITEM)
     Local _cOper		:= "EC"
     Local _aArea		:= GetArea()
     Local _cPrcUlt		:= ""
     Local _cCusUni 		:= ""
     //ExpA1
     //ExpA2
     If FWCodEmp() = '11' //Empresas que são do grupo 11(Tecpolpa).
        _cTes := MaTesInt(1,_cOper,_cForne,_cLoja,"F",_cProd,Nil)
        dbSelectArea("SB1")
        SB1->(dbSetOrder(1))
        SB1->(dbSeek(xFilial("SB1")+_cProd))

//        _cPrcUlt := SB1->B1_XUPRCCM
        _cPrcUlt := SB1->B1_XUPRCCM

        MaFisSave()

        MaFisClear()
        MaFisIni(_cForne,_cLoja,"F","N","J",Nil,Nil,Nil,Nil,"MATA161") 

        dbSelectArea("SC8")
        SC8->(dbSetOrder(2))
        SC8->(dbSeek(xFilial("SC8")+DTOS(SC8->C8_VALIDA)+SC8->C8_NUM))

        While !EOF()
              _nItem := VAL(SC8->C8_ITEM)
              If !Deleted()
                 _cCusUni := U_CUSTOUNIT(_cForne, _cLoja,_nItem,_nValUnit,_nQuant,_cProd,_nPrcTot,_cTes)
              Endif
              dbSkip()
        ENDDO
        MaFisRestore()
        Reclock("SC7",.F.)
           SC7->C7_XUPCR	:= _cPrcUlt
           SC7->C7_TES		:= _cTes
           SC7->C7_XCSTUNI := _cCusUni
        MSUNLOCK()
        RestArea(_aArea)
     Endif
Return


