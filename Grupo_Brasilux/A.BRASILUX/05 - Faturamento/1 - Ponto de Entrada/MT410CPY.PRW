#include 'protheus.ch'
#include 'topconn.ch'
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MT410CPY  บAutor  ณ Cleber Orati      บ Data ณ  14/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Ponto de entrada para validar tratamento da c๓pia de pedi- บฑฑ
ฑฑบ          ณ dos de vendas para preencher alguns campos                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX TINTAS TษCNICAS LTDA.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
//25/09/2019 - Luํs Gustavo - Adequa็ใo para release 12.1.25
User Function MT410CPY()   
     Local aArea      := GetArea()
     Local nPosVlrFre := GDFIELDPOS("C6_XVLRFRE")
     Local nPosPRCVEN := GDFIELDPOS("C6_PRCVEN")
     Local nPosQTDVEN := GDFIELDPOS("C6_QTDVEN")
     Local nPosTOTAL  := GDFIELDPOS("C6_VALOR")
     Local nx
     u_zcfga01( 'MT410CPY' ) //LGS#2021201 - Grava็ใo de log de utiliza็ใo da rotina
     If FWCodEmp() <> '11' //Empresas que nใo sใo do grupo 11(Tecpolpa).
        M->C5_CAD     := cUsername
        M->DT_CAD     := date()
        M->C5_PEDREPR := ""
        M->C5_FLAG    := ""
        M->C5_LIBPED  := ""
        M->C5_USRPED  := ""
        M->C5_LIBCRE  := ""
        M->C5_USRCRE  := ""
        M->C5_LIBDIR  := ""
        M->C5_USRDIR  := ""
        M->C5_OBSPED  := ""
        M->C5_OBS     := ""
        M->C5_OBSSC5  := ""
        M->C5_APROVA  := ""
        M->C5_USRAPR  := ""
        M->C5_LIBCAD  := "F"
        M->C5_MENPED  := ""
        M->C5_TIPOVEN := ""  
        M->C5_OBSNF   := ""
        //M->C5_TPFRETE := "F"
        M->C5_FRETE   := 0
        M->C5_USRCAD  := ""    
        M->C5_DESC1   := 0
        M->C5_DESC2   := 0
        M->C5_DESC3   := 0
        M->C5_DESC4   := 0
        M->C5_DESCFI  := 0
        M->C5_DESCONT := 0 
        M->C5_PEDPROG := CTOD(space(8))
        M->C5_DTAPR   := CTOD(space(8))
        M->C5_SUGENT  := CTOD(space(8))     
        M->C5_ENTREGA := 0
        M->C5_DEPOSI  := "" 
        M->C5_X_PVSIM := ""
 
        //Zerar Frete CIF!!
        IF (SC5->(FieldPos("C5_XVLRFRE")) > 0) .AND. (M->C5_TPFRETE = "C") .AND. (nPosVlrFre > 0) 
           For nx := 1 To Len(aCols)
           	   if aCols[nx][nPosVlrFre] <> 0
           	   		aCols[nx][nPosPRCVEN] := aCols[nx][nPosVlrFre]	
           	   		aCols[nx][nPosTOTAL] := round(aCols[nx][nPosQTDVEN]*aCols[nx][nPosPRCVEN],TamSx3("C6_VALOR")[2])	
           	   		aCols[nx][nPosVlrFre] := 0
           	   endif	
           Next nx
           M->C5_XVLRFRE := 0
        Endif
        RestArea(aArea)
     Endif
Return(.t.)
