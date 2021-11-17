#include "protheus.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BRFAT013  º Autor ³ Jeane Q. Oliveira  º Data ³  29/11/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gatilho para montagem da descricao do produto              º±±
±±º          ³ 02/01/02 - Marcos Cesar                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TECNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRFAT013()
     Private _cCarac   := SubStr(M->B1_COD,  1, 3)
     Private _cLinha   := SubStr(M->B1_COD,  4, 2)
     Private _cCor     := SubStr(M->B1_COD,  6, 2)
     Private _cVariac  := SubStr(M->B1_COD,  8, 3)
     Private _cTipoEmb := SubStr(M->B1_COD, 11, 2)
     Private cString

     If INCLUI .and. M->B1_TIPO == 'PA' .and. len(Alltrim(M->B1_COD))=12
        DbSelectArea("SZ1")
        DbSeek(xFilial("SZ1")+_cLinha)
        If !Found()
           DbSelectArea("SB1")
           MsgStop("Linha não cadastrada.")
           Return(.f.)
        Endif

        DbSelectArea("SZ2")
        DbSeek(xFilial("SZ2")+_cCor)
        If !Found()
           DbSelectArea("SB1")
           MsgStop("Cor não cadastrada.")
           Return(.f.)
        Endif          

        DbSelectArea("SZ3")
        DbSeek(xFilial("SZ3")+_cCor+_cVariac)
        If !Found()
           DbSelectArea("SB1")
           MsgStop("Variacao não cadastrada.")
           Return(.f.)
        Endif

        DbSelectArea("SZ4")
        DbSeek(xFilial("SZ4")+_cCarac+_cLinha)
        If !Found()
           DbSelectArea("SB1")
           MsgStop("Caracteristica não cadastrada.")
           Return(.f.)
        Endif

        DbSelectArea("SZ5")
        DbSeek(xFilial("SZ5")+_cTipoEmb)
        If !Found()
           DbSelectArea("SB1")
           MsgStop("Tipo Embalagem não cadastrada.")
           Return(.f.)
        Endif

        DbSelectArea("SZ6")
        DbSeek(xFilial("SZ6")+_cCarac+_cLinha+_cCor)
        If !Found()
           DbSelectArea("SB1")
           MsgStop("Classificacao fiscal não cadastrada.")
           Return(.f.)
        Else
           DbSelectArea("SYD")
           DbSeek(xFilial("SYD")+SZ6->Z6_CLASFIS)
        Endif
        DbSelectArea("SB1")

        //Cleber(06-11-17) -> mudando pra retornar descr. em branco até segunda ordem
        cString      := "" //Alltrim(SZ4->Z4_DESCR)+" "+Alltrim(SZ2->Z2_DESCR)+" "+Alltrim(SZ3->Z3_DESCR)
        M->B1_POSIPI := Alltrim(SZ6->Z6_CLASFIS)
        M->B1_CONV   := SZ5->Z5_VOLUME
		M->B1_SEGUM	 := SZ5->Z5_UMEMB
		M->B1_TIPCONV := "M"
        M->B1_COMIS  := SZ1->Z1_COMISSA
        M->B1_IPI    := SYD->YD_PER_IPI
        M->B1_LCRMIN := SZ1->Z1_LUCRMIN
        M->B1_LUCRO  := SZ1->Z1_LUCRO
     Endif
Return(cString)