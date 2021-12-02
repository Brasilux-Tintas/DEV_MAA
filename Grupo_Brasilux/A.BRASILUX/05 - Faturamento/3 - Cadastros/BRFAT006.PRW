#include "protheus.ch"
#include "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFAT006 º Autor ³ Jeane Q. Oliveira  º Data ³  24/11/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cadastro de tipos de embalagens                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TECNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRFAT006()
     Local cVldAlt   := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
     Local cVldExc   := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
     Private cString := "SZ5"
     u_zcfga01( 'BRFAT006' ) //LGS#2021201 - Gravação de log de utilização da rotina
	if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  	endif 


     cVldAlt := 'ExecBlock("FAT006_1", .F., .F.)'
     cVldExc := 'ExecBlock("FAT006_2", .F., .F.)'

     DbSelectArea("SZ5")
     DbSetOrder(1)

     AxCadastro(cString, "Cadastro de Tipo de Embalagens", cVldExc, cVldAlt)

Return

/*******************************************************************************/
/*** FAT006_1 - Valida alteração do tipo de embalagem                        ***/
/*** Autor: Jeane Q. Oliveira                                                ***/
/*** Data : 12/12/00                                                         ***/
/*** Alterações: 09/05/07 - Luís Gustavo de Souza                            ***/
/***                        Troca do programa BRFAT025 para FAT006_1 dentro  ***/
/***                        do programa BRFAT006                             ***/
/*******************************************************************************/
User Function FAT006_1()     
/*
//Cleber (03/06/15) -> conversão é feita via Trigger no SQL Server
     If ALTERA .and. M->Z5_VOLUME # SZ5->Z5_VOLUME
        DbSelectArea("SB1")
        DbSetOrder(1)
        DbSeek(xFilial("SB1"))
        While !Eof()
              If SubStr(SB1->B1_COD,11,2) == M->Z5_EMB
                 Reclock("SB1", .F.)
                    SB1->B1_CONV := M->Z5_VOLUME
                 MsUnLock()
              Endif
              DbSkip()
        EndDo
     Endif    
*/     
     // Mandar alteação p/ representantes
     U_EnviaRec("SZ5", M->Z5_EMB, .F.)

     DbSelectArea("SZ5")
Return(.t.)

/*******************************************************************************/
/*** FAT006_2 - Valida exclusão do tipo de embalagem                         ***/
/*** Autor: Jeane Q. Oliveira                                                ***/
/*** Data : 12/12/00                                                         ***/
/*** Alterações: 10/05/07 - Luís Gustavo de Souza                            ***/
/***                        Troca do programa BRFAT026 para FAT006_2 dentro  ***/
/***                        do programa BRFAT006                             ***/
/*******************************************************************************/
User Function FAT006_2()
     Private _existe

     cQuery := ""
     cQuery += "SELECT TOP 1 R_E_C_N_O_ AS REG "
     cQuery += " FROM "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) "
     cQuery += " WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND"
     cQuery += " SUBSTRING(SB1.B1_COD,11,2) = '"+SZ5->Z5_EMB+"' AND"
     cQuery += " SB1.D_E_L_E_T_ <> '*' "
     TCQUERY cQuery NEW ALIAS "TMP"

     DbSelectArea("TMP")
     DbGoTop()

     _existe:=.f.
     If !Eof()
        _existe := .t.
     Endif

     DbCloseArea("TMP")
     DbSelectArea("SZ5")
     If _existe
        MsgStop("Tipo de Embalagem nao pode ser excluida pois existe(m) produto(s) que a utilizam.")
        Return(.f.)
     Else
        // Mandar alteação p/ representantes
        U_EnviaRec("SZ5", SZ5->Z5_EMB, .T.)
        Return(.t.)
     Endif
Return(.t.)
