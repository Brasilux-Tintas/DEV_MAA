#include "protheus.ch"
#include "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFAT022 º Autor ³ Jeane Q. Oliveira  º Data ³  07/12/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP5 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRFAT022()
     Local cVldAlt   := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
     Local cVldExc   := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
     Private cString := "SZ7"
                
     cVldAlt := 'ExecBlock("FAT022_1", .F., .F.)'
     cVldExc := 'ExecBlock("FAT022_2", .F., .F.)'

     DbSelectArea("SZ7")
     DbSetOrder(1)

     AxCadastro(cString, "Cadastro de Cidades", cVldExc, cVldAlt)

Return

/*******************************************************************************/
/*** FAT022_1 - Valida alteração do cadastro de cidades                      ***/
/*** Autor: Jeane Q. Oliveira                                                ***/
/*** Data : 08/12/00                                                         ***/
/*** Alterações: 21/01/03 - Cleber Orati Domingues                           ***/
/***                        Não permissão de alterar estado e uso de instru- ***/
/***                        ção SQL                                          ***/
/***             10/05/07 - Luís Gustavo de Souza                            ***/
/***                        Troca do programa BRFAT023 para FAT022_1 dentro  ***/
/***                        do programa BRFAT022                             ***/
/*******************************************************************************/
User Function FAT022_1()
     Local cQuery
     If ALTERA .and. ;
        ((M->Z7_NOME # SZ7->Z7_NOME) .OR. (M->Z7_EST # SZ7->Z7_EST) .OR. (M->Z7_REGIAO # SZ7->Z7_REGIAO) .OR. (M->Z7_COD # SZ7->Z7_COD))
        If M->Z7_EST # SZ7->Z7_EST
           MsgStop("Nao e' permitida a alteracao do Estado!")
           Return(.f.)
        Endif
        cQuery := "UPDATE "+RetSqlName("SA1")+" SET A1_CODCID = '"+M->Z7_COD+"',A1_MUN = '"+M->Z7_NOME+"',A1_REGIAO = '"+;
                  M->Z7_REGIAO+"' WHERE (A1_CODCID = '"+SZ7->Z7_COD+"') AND (D_E_L_E_T_ <> '*')"
        TCSQLEXEC(cQuery)
        cQuery := "UPDATE "+RetSqlName("SA2")+" SET A2_CODCID = '"+M->Z7_COD+"',A2_MUN = '"+M->Z7_NOME+"' WHERE (A2_CODCID = '"+;
                  M->Z7_COD+"') AND (D_E_L_E_T_ <> '*')"
        TCSQLEXEC(cQuery)
        cQuery := "UPDATE "+RetSqlName("SF2")+" SET F2_CODCID = '"+M->Z7_COD+"' WHERE (F2_CODCID = '"+;
                  M->Z7_COD+"') AND (D_E_L_E_T_ <> '*')"
        TCSQLEXEC(cQuery)
     Endif
     // Mandar alteação p/ representantes
     U_EnviaRec("SZ7", M->Z7_COD, .F.)

     DbSelectArea("SZ7")
Return(.t.)

/*******************************************************************************/
/*** FAT022_2 - Valida exclusão do cadastro de cidades                       ***/
/*** Autor: Jeane Q. Oliveira                                                ***/
/*** Data : 08/12/00                                                         ***/
/*** Alterações: 10/05/07 - Luís Gustavo de Souza                            ***/
/***                        Troca do programa BRFAT024 para FAT022_1 dentro  ***/
/***                        do programa BRFAT022                             ***/
/*******************************************************************************/
User Function FAT022_2()
     Local cQuery := ""
	 Private _existe

     _existe := .f.
     cQuery := ""
     cQuery += "SELECT TOP 1 SA1.A1_COD "
     cQuery +=" FROM "+RetSqlName("SA1")+" SA1 "
     cQuery +=" WHERE "
     cQuery +=" SA1.A1_CODCID = '"+SZ7->Z7_COD+"' AND"
     cQuery +=" SA1.D_E_L_E_T_ <> '*' "
     TCQUERY cQuery NEW ALIAS "TMP"

     DbSelectArea("TMP")
     DbGoTop()
     
     If !Eof()
        _existe := .t.
     Else
        DbCloseArea("TMP")
        cQuery := ""
        cQuery += "SELECT TOP 1 SA2.A2_COD "
        cQuery += " FROM "+RetSqlName("SA2")+" SA2 "
        cQuery += " WHERE "
        cQuery += " SA2.A2_CODCID = '"+SZ7->Z7_COD+"' AND"
        cQuery += " SA2.D_E_L_E_T_ <> '*' "
        TCQUERY cQuery NEW ALIAS "TMP"
        DbSelectArea("TMP")
        DbGoTop()
        If !Eof()
           _existe := .t.
        Endif
     Endif

     DbCloseArea("TMP")
     DbSelectArea("SZ7")
     If _existe
        MsgStop("Cidade nao pode ser excluida, pois existem cliente(s) ou fornecedor(es) que a utilizam.")
        Return(.f.)
     Else            
        //Mandar p/ representante
        U_EnviaRec("SZ7", SZ7->Z7_COD, .T.)
        Return(.t.)
     Endif
Return(.t.)