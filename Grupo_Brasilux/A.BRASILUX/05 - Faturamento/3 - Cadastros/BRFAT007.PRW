#include "protheus.ch"
#include "topconn.ch"      
#include "rwmake.ch"                                         

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFAT007 º Autor ³ Jeane Q. Oliveira  º Data ³  24/11/00   º±±
±±º Alterações: 20/05/10 - Cleber Orati Domingues                         º±±
±±º                        ExecBlock se referia a BRFAT021 e nao  FAT007_2º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Classificação Fiscal                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TECNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRFAT007
     Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
     Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
     Private cString := "SZ6"
     u_zcfga01( 'BRFAT007' ) //LGS#2021201 - Gravação de log de utilização da rotina
   	if !u_VldAcesso(funname())
		MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
	 	return 
	endif 

     cVldAlt := 'ExecBlock("FAT007_1",.F.,.F.)'
     cVldExc := 'ExecBlock("FAT007_2",.F.,.F.)'

     DbSelectArea("SZ6")
     DbSetOrder(1)

     AxCadastro(cString, "Cadastro de Classificacao Fiscal", cVldExc, ".T.") && cVldAlt
Return

/*******************************************************************************/
/*** FAT007_1 - Valida alteração do cadastro de classificação fiscal.        ***/
/*** Autor: Jeane Q. Oliveira                                                ***/
/*** Data : 30/11/00                                                         ***/
/*** Alterações: 11/05/07 - Luís Gustavo de Souza                            ***/
/***                        Troca do programa BRFAT020 para FAT007_1 dentro  ***/
/***                        do programa BRFAT007                             ***/
/*** Alterações: 27/09/07 - Cleber Orati Domingues                           ***/
/***                        ExecBlock se referia a BRFAT020 e nao  FAT007_1  ***/
/***                       	Criei trigger no SQL p/ atualizar                ***/
/*******************************************************************************/
User Function FAT007_1()
local cTable  
IF INCLUI
	cTable := RetSqlName("SZ6")
	TcRefresh( cTable )    
ENDIF 


/*
     If ALTERA .and. M->Z6_CLASFIS # SZ6->Z6_CLASFIS
        DbSelectArea("SB1")
        DbSetOrder(1)
        DbSeek(xFilial("SB1"))
        While !Eof()
              If SubStr(SB1->B1_COD, 4, 2) == M->Z6_LINHA .AND. SubStr(SB1->B1_COD, 6, 2) == M->Z6_COR
                 DbSelectArea("SYD")
                 DbSeek(xFilial("SYD")+M->Z6_CLASFIS)
                 DbSelectArea("SB1")
                 Reclock("SB1", .F.)
                    SB1->B1_POSIPI := M->Z6_CLASFIS
                    SB1->B1_IPI    := SYD->YD_PER_IPI
                 MsUnLock()
              Endif
              DbSkip()
        EndDo
     Endif       
*/     
     DbSelectArea("SZ6")
Return(.t.)

/*******************************************************************************/
/*** FAT007_2 - Valida exclusão do cadastro de classificação fiscal.         ***/
/*** Autor: Jeane Q. Oliveira                                                ***/
/*** Data : 30/11/00                                                         ***/
/*** Alterações: 11/05/07 - Luís Gustavo de Souza                            ***/
/***                        Troca do programa BRFAT021 para FAT007_2 dentro  ***/
/***                        do programa BRFAT007                             ***/
/*******************************************************************************/
User Function FAT007_2()
	Local cQuery
     Private _existe
     cQuery := ""
     cQuery += "SELECT TOP 1 SB1.B1_COD "+;
     "FROM "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) "+;
     "WHERE (LEN(B1_COD) = 12) AND "+;
     "SUBSTRING(B1_COD, 1, 3) = '"+SZ6->Z6_CARAC+"' AND "+;
     "SUBSTRING(B1_COD, 4, 2) = '"+SZ6->Z6_LINHA+"' AND "+;
     "SUBSTRING(B1_COD, 6, 2) = '"+SZ6->Z6_COR+"' AND "+;
     "SB1.D_E_L_E_T_ <> '*' "
     TCQUERY cQuery NEW ALIAS "TMP"


     DbSelectArea("TMP")
     DbGoTop()
     _existe := .f.
     If !Eof()
        _existe := .t.
     Endif
     MsgStop(Eof())

     DbCloseArea("TMP")
     DbSelectArea("SZ6")
     If _existe
        MsgStop("Classificacao nao pode ser excluida, pois existem produtos qua a utilizam.")
        Return(.f.)
     Else
        Return(.t.)
     Endif
Return(.t.)
