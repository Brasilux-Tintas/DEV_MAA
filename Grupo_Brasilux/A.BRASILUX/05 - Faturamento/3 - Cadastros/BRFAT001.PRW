#include "protheus.ch"
#include "topconn.ch"
#Translate MSGBOX( => IW_MsgBox(
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFAT001  º Autor ³ Jeane Q. Oliveira º Data ³  24/11/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Inclusão e manutenção de linhas de produtos.               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRFAT001()
     Local cVldAlt   := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
     Local cVldExc   := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
     Local _cUser
     Private cString := "SZ1"

	/* 
     _cUser := Alltrim(Upper(cUsername))
	*/
/*	
	If PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) != 0
        MsgBox("Acesso não autorizado!", "Atenção...", "STOP")
        Return
    Endif
*/

if !u_VldAcesso(funname())
	MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
	return 
endif 

     cVldAlt := 'ExecBlock("FAT001_1", .F., .F.)'
     cVldExc := 'ExecBlock("FAT001_2", .F., .F.)'

     DbSelectArea("SZ1")
     DbSetOrder(1)

     AxCadastro(cString, "Cadastro de Linhas de Produtos", cVldExc, cVldAlt)
Return

/*******************************************************************************/
/*** FAT001_1 - Valida alteração da linha                                    ***/
/*** Autor: Jeane Q. Oliveira                                                ***/
/*** Data : 12/12/00                                                         ***/
/*** Alterações: 02/01/02 - Marcos Cesar Vieira                              ***/
/***             29/05/02 - Cleber Orati Domingues                           ***/
/***                        Uso do TcSqlExec                                 ***/
/***             08/05/07 - Luís Gustavo de Souza                            ***/
/***                        Troca do programa BRFAT027 para FAT001_1 dentro  ***/
/***                        do programa BRFAT001                             ***/
/*******************************************************************************/
User Function FAT001_1()
     Local cQuery, cEmpresa, i
     If ALTERA .and. ((M->Z1_COMISSA # SZ1->Z1_COMISSA) .OR. (M->Z1_LUCRO   # SZ1->Z1_LUCRO)   .OR. ;
                      (M->Z1_LUCRMIN # SZ1->Z1_LUCRMIN) .OR. (M->Z1_LUCROM2 # SZ1->Z1_LUCROM2) .OR. ;
                      (M->Z1_LUCRO2  # SZ1->Z1_LUCRO2))
      //  For i := 1 to 2
      //      Do Case
      //         Case i == 1
      //              cEmpresa := "01"
      //         Case i == 2
      //              cEmpresa := "03"
      //      EndCase
            cQuery := "UPDATE "+RetSqlName("SB1")+" SET "+;
                      "B1_COMIS = "+alltrim(transform(M->Z1_COMISSA,"999.99"))+;
                      ",B1_LUCRO = "+alltrim(transform(M->Z1_LUCRO,"999.99"))+;
                      ",B1_LCRMIN = "+alltrim(transform(M->Z1_LUCRMIN,"999.99"))+;
                      ",B1_LUCROM2 = "+alltrim(transform(M->Z1_LUCROM2,"999.99"))+;
                      ",B1_LUCRO2 = "+alltrim(transform(M->Z1_LUCRO2,"999.99"))+;
                      " WHERE (D_E_L_E_T_ <> '*') AND (B1_FILIAL LIKE '"+ALLTRIM(xFilial("SZ1"))+"%') AND (LEN(B1_COD) = 12) AND (SUBSTRING(B1_COD,4,2) = '"+M->Z1_LINHA+;
                      "')"
           // TCSQLEXEC(cQuery) //Cleber(29/05/14) ->Tava demorando muito
      //  Next
     Endif
     // Mandar alteação p/ representantes
     U_EnviaRec("SZ1", M->Z1_LINHA, .F.)
     DbSelectArea("SZ1")
Return(.t.)

/*******************************************************************************/
/*** FAT001_2 - Valida exclusão da linha                                     ***/
/*** Autor: Jeane Q. Oliveira                                                ***/
/*** Data : 12/12/00                                                         ***/
/*** Alterações: 08/05/07 - Luís Gustavo de Souza                            ***/
/***                        Troca do programa BRFAT028 para FAT001_2 dentro  ***/
/***                        do programa BRFAT001                             ***/
/*******************************************************************************/
User Function FAT001_2()
     Private _existe

     cQuery := ""
     cQuery += "SELECT TOP 1 SB1.B1_COD "
     cQuery += "FROM "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) "
     cQuery += "WHERE "
     cQuery += "(SUBSTRING(SB1.B1_COD, 4, 2) = '"+SZ1->Z1_LINHA+"') AND "
     cQuery += "(LEN(SB1.B1_COD) = 12) AND "
     cQuery += "(SB1.D_E_L_E_T_ <> '*') "
     TCQUERY cQuery NEW ALIAS "TMP"

     DbSelectArea("TMP")
     DbGoTop()
     
     _existe := .f.
     If !Eof()
        _existe := .t.
     Endif

     DbCloseArea("TMP")
     DbSelectArea("SZ1")
     If _existe
        MsgStop("Linha nao pode ser excluida, pois existem produtos que a utilizam.")
        Return(.f.)
     Else                              
        // Mandar inf. p/ representante
        U_EnviaRec("SZ1", SZ1->Z1_LINHA, .t.)
        Return(.t.)
     Endif
Return(.f.)
