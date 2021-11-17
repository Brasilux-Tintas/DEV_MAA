#include 'protheus.ch'
#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function CountDia()
Private oData1,data1,oData2,Data2,Hora1,oHora1,Hora2,oHora2

DEFINE MSDIALOG oDlg TITLE "Teste" FROM 000, 000 TO 200, 350 PIXEL 
data1 := data2 := date()
hora1 := hora2 := "     "
@ 008, 010 SAY "Data Ini: " SIZE 052, 007 OF  oDlg  COLORS 0, 16777215 PIXEL 
@ 006, 040 MSGET oData1 VAR data1  OF  oDlg  COLORS 0, 16777215 PIXEL FONT oFont When .T.
@ 008, 080 SAY "Hora Ini: " SIZE 052, 007 OF  oDlg  COLORS 0, 16777215 PIXEL 
@ 006, 105 MSGET oHora1 VAR hora1 PICTURE "@E 99:99" OF  oDlg  COLORS 0, 16777215 PIXEL FONT oFont When .T.
@ 038, 010 SAY "Data Fim: " SIZE 052, 007 OF  oDlg  COLORS 0, 16777215 PIXEL 
@ 036,  040 MSGET oData2 VAR data2  OF  oDlg  COLORS 0, 16777215 PIXEL FONT oFont When .T.
@ 038, 080 SAY "Hora Fim: " SIZE 052, 007 OF  oDlg  COLORS 0, 16777215 PIXEL 
@ 036, 105 MSGET oHora2 VAR hora2 PICTURE "@E 99:99" OF  oDlg  COLORS 0, 16777215 PIXEL FONT oFont When .T.
@ 080, 080 Button "Encerrar" Size 030, 012 PIXEL OF oDlg Action(TestC(data1,data2,hora1,hora2))

ACTIVATE DIALOG oDlg CENTER                       
Return 

Static Function TestC(data1,data2,hora1,hora2)     	
  //Local dtIni := data1
  //Local dtFim := data2
  Local hrIni := hora1
  Local hrFim := hora2                                   	
  Local AuxHora:=0
  Local AuxMin:= 0
  Local iAuxMinIni := transform(substr(hrIni,4,2),"@E99")	
  Local iAuxMinFim := transform(substr(hrFim,4,2),"@E99")
  Local iAuxMin := val(iAuxMinIni) +  val(iAuxMinFim) 
  Local TransfHora := (Val(Transform(substr(hrIni,1,2),"@E 99")) - Val(Transform(substr(hrFim,1,2),"@E 99")))
  Local i
  If TransfHora < 0
  	TransfHora := TransfHora * (-1)
  EndIf  		 
  dtotalDias := 0
  for i = datavalida(data1) to data2
    if datavalida(i) > i
    	i+= datavalida(i) - i
    endif
    dtotalDias ++ 
 Next
 dtotalDias:= dtotalDias-2
   If iAuxMin > 60
  	iAuxMin := val(iAuxMinIni) -  val(iAuxMinFim) 
  	TransfHora += 1
  	If iAuxMin < 0 
  		iAuxMin := iAuxMin * (-1)
	EndIf
  EndIf	  
  If (substr(hrIni,1,2) < substr(hrFim,1,2))
  	If  data1 != data2  
  		AuxHora := TransfHora + 24
  	Else 
  		//TransfHora //??????????????????????
  	EndIf
  Else                                                    
  	AuxHora := 24 - TransfHora
  EndIf 
  iif(dtotalDias>=1,calcH:=((dtotalDias*24)*60),calcH := 0)
  AuxMin += (AuxHora * 60) + (iAuxMin)
  Alert(AuxMin + calcH)
Return