#include "protheus.ch"
//#Translate MSGBOX( => IW_MsgBox(
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFAT039 ºAutor  ³ Marcos C. D. Vieiraº Data ³  17/07/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cadastro de GNRE's                                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TECNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRFAT039()
     Local cVldAlt   := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
     Local cVldExc   := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
     Private cString := "SZ9"

     DbSelectArea("SZ9")
     DbSetOrder(1)

     AxCadastro(cString, "Cadastro de GNRE's", "U_FAT039_2()", cVldAlt)

Return                   

/*******************************************************************************/
/*** FAT039_2 - Valida exclusão da GNRE                                      ***/
/*** Autor: Marcos C. D. Vieira                                              ***/
/*** Data : 17/07/01                                                         ***/
/*** Alterações: 10/05/07 - Luís Gustavo de Souza                            ***/
/***                        Troca do programa BRFT39E PARA FAT039_2          ***/
/*******************************************************************************/
User Function FAT039_2()
     Local lRet := .T.
     If IsDigit(SubStr(SZ9->Z9_NF, 1, 1))
        MsgStop("Essa Guia somente sera' excluida c/ a exclusao da Nota Fiscal! ")
        lRet := .F.
     Endif
Return(lRet)
