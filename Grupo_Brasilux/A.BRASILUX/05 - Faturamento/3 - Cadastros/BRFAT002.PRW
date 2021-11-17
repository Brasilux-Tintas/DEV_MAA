#include "protheus.ch"
#include "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFAT002 º Autor ³ Jeane Q. Oliveira  º Data ³  24/11/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cadastro de cores dos produtos                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TECNICAS LTDA                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRFAT002()
     Local cVldAlt   := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
     Local cVldExc   := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
     Private cString := "SZ2"

     cVldAlt := 'ExecBlock("FAT002_1", .F., .F.)'       
     cVldExc := 'ExecBlock("FAT002_2", .F., .F.)'

     DbSelectArea("SZ2")
     DbSetOrder(1)

     AxCadastro(cString, "Cadastro de Cores de Produtos", cVldExc, cVldAlt)
Return

/*******************************************************************************/
/*** FAT002_1 - Valida alteração de cores                                    ***/
/*** Autor: Jeane Q. Oliveira                                                ***/
/*** Data : 30/11/00                                                         ***/
/*** Alterações: 09/05/07 - Luís Gustavo de Souza                            ***/
/***                        Troca do programa BRFAT014 para FAT002_1 dentro  ***/
/***                        do programa BRFAT002                             ***/
/*******************************************************************************/
User Function FAT002_1()
Return(.t.)
                
/*******************************************************************************/
/*** FAT002_2 - Valida exclusão de cores                                     ***/
/*** Autor: Jeane Q. Oliveira                                                ***/
/*** Data : 30/11/00                                                         ***/
/*** Alterações: 09/05/07 - Luís Gustavo de Souza                            ***/
/***                        Troca do programa BRFAT015 para FAT002_1 dentro  ***/
/***                        do programa BRFAT002                             ***/
/*******************************************************************************/
User Function FAT002_2()
	 Local cQuery :=""
     Private _existe

     cQuery := ""
     cQuery += "SELECT TOP 1 R_E_C_N_O_ AS REG "
     cQuery += " FROM "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) "
     cQuery += " WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND "
     cQuery += " SUBSTRING(SB1.B1_COD, 6, 2) = '"+SZ2->Z2_COR+"' AND "
     cQuery += " SB1.D_E_L_E_T_ <> '*' "
     TCQUERY cQuery NEW ALIAS "TMP"

     DbSelectArea("TMP")
     DbGoTop()

     _existe := .f.
     If !Eof()
        _existe := .t.
     Endif

     DbCloseArea("TMP")
     DbSelectArea("SZ2")
     If _existe
        MsgStop("Cor nao pode ser excluida, pois existe produto cadastrado com essa cor.")
        Return(.f.)
     Else
        Return(.t.)
     Endif
Return(.t.)