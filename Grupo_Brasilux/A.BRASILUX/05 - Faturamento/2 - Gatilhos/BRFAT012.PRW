#include "protheus.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFAT012 º Autor ³ Jeane Q. Oliveira  º Data ³  29/11/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gatilho para composicao do Codigo do produto               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TECNICAS LTDA                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRFAT012()

     Local _cCarac   := ""
     Local _cLinha   := ""
     Local _cCor     := ""
     Local _cVariac  := ""
     Local _cTipoEmb :=""
     Private cString  := M->B1_COD
     
     If INCLUI
        If !Empty(M->B1_CARAC)
           cString := M->B1_CARAC+SubStr(cString, 6, 10)
        Endif
        If !Empty(M->B1_COR)
           cString := SubStr(cString, 1, 5)+M->B1_COR+SubStr(cString, 8, 8)
        Endif
        If !Empty(M->B1_VARIAC)
           cString := SubStr(cString, 1, 7)+M->B1_VARIAC+SubStr(cString, 11, 5)
        Endif
        If !Empty(M->B1_TIPOEMB)
           cString := SubStr(cString, 1, 10)+M->B1_TIPOEMB+SubStr(cString, 13, 3)
        Endif
        If !Empty(M->B1_CARAC) .and. !Empty(M->B1_COR) .and. !Empty(M->B1_VARIAC) .and. !Empty(M->B1_TIPOEMB)
           _cCarac   := SubStr(M->B1_CARAC, 1, 3)
           _cLinha   := SubStr(M->B1_CARAC, 4, 2)
           _cCor     := M->B1_COR
           _cVariac  := M->B1_VARIAC
           _cTipoEmb := M->B1_TIPOEMB

           DbSelectArea("SZ1")
           DbSeek(xFilial("SZ1")+_cLinha)
           If !Found()
              DbSelectArea("SB1")
              MsgStop("Linha não cadastrada.")
              Return(Space(15))
           Endif

           DbSelectArea("SZ2")
           DbSeek(xFilial("SZ2")+_cCor)
           If !Found()
              DbSelectArea("SB1")
              MsgStop("Cor não cadastrada.")
              Return(Space(15))
           Endif

           DbSelectArea("SZ3")
           DbSeek(xFilial("SZ3")+_cCor+_cVariac)
           If !Found()
              DbSelectArea("SB1")
              MsgStop("Variacao não cadastrada.")
              Return(Space(15))
           Endif

           DbSelectArea("SZ4")
           DbSeek(xFilial("SZ4")+_cCarac+_cLinha)
           If !Found()
              DbSelectArea("SB1")
              MsgStop("Caracteristica nao cadastrada.")
              Return(space(15))
           Endif

           DbSelectArea("SZ5")
           DbSeek(xFilial("SZ5")+_cTipoEmb)
           If !Found()
              DbSelectArea("SB1")
              MsgStop("Tipo Embalagem não cadastrada.")
              Return(Space(15))
           Endif

           DbSelectArea("SZ6")
           DbSeek(xFilial("SZ6")+_cCarac+_cLinha+_cCor)
           If !Found()
              DbSelectArea("SB1")
              MsgStop("Classificacao fiscal não cadastrada.")
              Return(Space(15))
           Else
              DbSelectArea("SYD")
              DbSeek(xFilial("SYD")+SZ6->Z6_CLASFIS)
           Endif
           DbSelectArea("SB1")
           M->B1_DESC    := Alltrim(Alltrim(SZ4->Z4_DESCR)+" "+Alltrim(SZ2->Z2_DESCR)+" "+Alltrim(SZ3->Z3_DESCR))
           M->B1_POSIPI  := Alltrim(SZ6->Z6_CLASFIS)
           M->B1_CONV    := SZ5->Z5_VOLUME   
           M->B1_SEGUM	 := SZ5->Z5_UMEMB
           M->B1_TIPCONV := "M"
           M->B1_COMIS   := SZ1->Z1_COMISSA
           M->B1_IPI     := SYD->YD_PER_IPI
           M->B1_LCRMIN  := SZ1->Z1_LUCRMIN 
           M->B1_LUCRO   := SZ1->Z1_LUCRO  
           M->B1_LUCRO2  := SZ1->Z1_LUCRO2
           M->B1_LUCROM2 := SZ1->Z1_LUCROM2
        Endif
     Endif
Return(cString)