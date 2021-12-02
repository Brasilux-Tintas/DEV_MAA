#include "protheus.ch"
#include "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFAT005 º Autor ³ Jeane Q. Oliveira  º Data ³  24/11/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cadastro de caracteristicas                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRFAT005()
     Local cVldAlt   := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
     Local cVldExc   := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
     Private cString := "SZ4"
     u_zcfga01( 'BRFAT005' ) //LGS#2021201 - Gravação de log de utilização da rotina
     cVldAlt := 'ExecBlock("FAT005_1", .F., .F.)'
     cVldExc := 'ExecBlock("FAT005_2", .F., .F.)'

     DbSelectArea("SZ4")
     DbSetOrder(1)

     AxCadastro(cString, "Cadastro de Caracteristicas", cVldExc, cVldAlt)
Return

/*******************************************************************************/
/*** FAT005_1 - Valida alteração das caracteristicas                         ***/
/*** Autor: Jeane Q. Oliveira                                                ***/
/*** Data : 30/11/00                                                         ***/
/*** Alterações: 09/05/07 - Luís Gustavo de Souza                            ***/
/***                        Troca do programa BRFAT016 para FAT005_1 dentro  ***/
/***                        do programa BRFAT005                             ***/
/*******************************************************************************/
User Function FAT005_1()
Return(.t.)
                
/*******************************************************************************/
/*** FAT005_2 - Valida exclusão das caracteristicas                          ***/
/*** Autor: Jeane Q. Oliveira                                                ***/
/*** Data : 30/11/00                                                         ***/
/*** Alterações: 09/05/07 - Luís Gustavo de Souza                            ***/
/***                        Troca do programa BRFAT017 para FAT005_2 dentro  ***/
/***                        do programa BRFAT005                             ***/
/*******************************************************************************/
User Function FAT005_2()
     Local cQuery := ""
	 Private _existe

     cQuery := ""
     cQuery += "SELECT SB1.B1_COD "
     cQuery += " FROM "+RetSqlName("SB1")+" SB1 "
     cQuery += " WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND"
     cQuery += " SUBSTRING(SB1.B1_COD, 1, 5) = '"+SZ4->Z4_CARAC+SZ4->Z4_LINHA+"' AND "
     cQuery += " SB1.D_E_L_E_T_ <> '*' "
     TCQUERY cQuery NEW ALIAS "TMP"

     DbSelectArea("TMP")
     DbGoTop()
     _existe := .f.
     If ! Eof()
        _existe := .t.
     Endif

     DbCloseArea("TMP")
     DbSelectArea("SZ4")
     If _existe
        MsgStop("Caracteristica nao pode ser excluida, pois existem produtos utilizando-a.")
        Return(.f.)
     Else
        Return(.t.)
     Endif
Return(.f.)
