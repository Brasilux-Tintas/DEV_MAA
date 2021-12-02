#include "protheus.ch"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
  ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
  ฑฑบPrograma  ณ MA650EMP บAutor  ณ Luํs Gustavo       บ Data ณ  15/09/04   บฑฑ
  ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
  ฑฑบDesc.     ณ Ponto de entrada para ajustes na quantidade empenhada, de- บฑฑ
  ฑฑบ          ณ vido ao ajuste de cor das f๓rmulas.                        บฑฑ
  ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
  ฑฑบUso       ณ BRASILUX                                                   บฑฑ
  ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
  ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
  ฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
  /* - Ap๓s a inclusใo do novo aHeader pelo P.E. MTA650AC e calculado o valor -
       do acerto de cor pelo P.E. EMP650, ้ utilizado esse P.E. MA650EMP para a
       grava็ใo da informa็ใo no campo D4_ACECOR do arquivo SD4.
  */
//30/09/2019 - Luํs Gustavo - Adequa็ใo para release 12.1.25  
User Function MA650EMP()
     Local _aArea := getarea()
     Local lRegD4, nRegD4, nOrdD4
     Local nPosAce, nPosTRT, nPosSLo, nPosNLo, nY
     u_zcfga01( 'MA650EMP' ) //LGS#2021201 - Grava็ใo de log de utiliza็ใo da rotina
     If FWCodEmp() <> '11' //Empresas que nใo sใo do grupo 11(Tecpolpa).
        DbSelectArea("SD4") 
        nOrdD4 := IndexOrd()
        If !eof() .and. !bof()
           lRegD4 := .t.
           nRegD4 := recno()
        Else
           lRegD4 := .f.
        Endif
        If GETMV("MV_AJUSCOR")
           nPosAce := aScan(aHeader, {|x| AllTrim(x[2]) == 'D4_ACECOR'})
           nPosTRT := aScan(aHeader, {|x| AllTrim(x[2]) == 'G1_TRT'}) 
           nPosSLo := aScan(aHeader, {|x| AllTrim(x[2]) == 'D4_NUMLOTE'})
           nPosNLo := aScan(aHeader, {|x| AllTrim(x[2]) == 'D4_LOTECTL'})
           For nY := 1 To Len(aCols)
               DbSelectArea("SD4")
               DbSetOrder(1)
               //DbSeek(xFilial("SD4")+aCols[nY][1]+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD+aCols[nY][nPosTRT]+aCols[nY][nPosNLo]+aCols[nY][nPosSLo],.t.)
               DbSeek(xFilial("SD4")+aCols[nY][1]+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD+aCols[nY][nPosTRT],.t.)
               If Found()
                  RecLock("SD4", .f.)
                     SD4->D4_ACECOR := aCols[nY][nPosAce]
                     SD4->D4_NUMLOTE:= aCols[nY][nPosSLo]   // GRAVANDO CAMPO G1_OPERACA POIS NรO UTILIZAMOS RASTREABILIDADE (IMPRESSรO ORDENADA POR ESTE CAMPO PARA LATEX) -0880.0881.0082.
                  MsUnLock()
               Endif
           Next
        Endif
        DbSelectArea("SD4")
        Dbsetorder(nOrdD4)
        If lRegD4
           dbgoto(nRegD4)
        Endif
        restarea(_aArea)
     Endif
Return
