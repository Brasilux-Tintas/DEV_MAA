#include "rwmake.ch"
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRCOM010 บAutor  ณ Luis Gustavo       บ Data ณ  02/08/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gatilho para preencher campo virtual do ultimo pre็o pago, บฑฑ
ฑฑบ          ณ na entrada da Nota Fiscal.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Brasilux Tintas T้cnicas Ltda.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function BRCOM010()
     Local aArea   := GetArea()
     Local nUlPrc  := 0
     Local nRegB1,nOrdB1,lRegB1
     Local nPosCod := aScan( aHeader, {|x| x[2] $ 'D1_COD' } )
     u_zcfga01( 'BRCOM010' ) //LGS#2021118 - Grava็ใo de log de utiliza็ใo da rotina
		DbSelectArea("SB1")
        if !eof() .and. !bof()
			lRegB1 := .t.
   			nRegB1 := recno()
      	else
       		lRegB1 := .f.
		endif
  		nOrdB1 := IndexOrd()

     	nUlPrc := Posicione("SB1", 1, xFilial("SB1")+aCols[n][nPosCod], "B1_UPRC")

		DbSelectArea("SB1")
		DbSetOrder(nOrdB1)  
		if lRegB1
			DbGoto(nRegB1)
		endif 

     RestArea(aArea)

Return(nUlPrc)
