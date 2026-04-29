#INCLUDE "Totvs.ch"
   
User Function F200TIT()
Local aAreaSE1 := GetArea()

If ((alltrim(FWGrpCompany())) == '11')
    Return
EndIf 
 
DbSelectArea("SE1")
DbSelectArea("SE5")
 
 RecLock("SE5",.F.)
    SE5->E5_XCNAB := SE1->E1_XCNAB 
 MsUnLock()  

RestArea(aAreaSE1)
  
Return
