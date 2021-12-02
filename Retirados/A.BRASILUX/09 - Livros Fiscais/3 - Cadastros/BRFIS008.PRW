#include "protheus.ch"
#include "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFIS008 º Autor ³ Cleber Orati       º Data ³  26/04/21   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cadastro de Amarração Grupo Trib x NCM                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TECNICAS LTDA                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRFIS008()
     Local cVldAlt   := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
     Local cVldExc   := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
     Private cString := "Z17"

if !u_VldAcesso(funname())
	MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
	return 
endif

     cVldAlt := 'ExecBlock("FIS008_1", .F., .F.)'       
     cVldExc := 'ExecBlock("FIS008_2", .F., .F.)'

     DbSelectArea("Z17")
     DbSetOrder(1)

     AxCadastro(cString, "Amarracao Grupo Trib x NCM", cVldExc, cVldAlt)
Return

/*******************************************************************************/
/*** FAT002_1 - Valida Alteracao Amarracao Grupo Trib x NCM                  ***/
/*** Autor: Cleber Orati                                                     ***/
/*** Data : 26/04/24                                                         ***/
/*******************************************************************************/
User Function FIS008_1()
Return(.t.)
                
/*******************************************************************************/
/*** FAT002_2 - Valida exclusão Amarracao Grupo Trib x NCM                   ***/
/*** Autor: JCleber Orati                                                    ***/
/*** Data : 26/04/24                                                          ***/
/*******************************************************************************/
User Function FIS008_2()
	 Local cQuery :=""
    Local _existe,lRet
   

     cQuery := "SELECT TOP 1 R_E_C_N_O_ AS REG "
     cQuery += " FROM "+RetSqlName("SF7")+" SF7 WITH (NOLOCK) "
     cQuery += " WHERE (SF7.F7_FILIAL = '"+xFilial("SF7")+"') AND "
     cQuery += " (F7_GRTRIB = '"+ALLTRIM(M->Z17_GRTRIB)+"') AND (F7_POSIPI = '"+ALLTRIM(M->Z17_POSIPI)+"') AND "
     cQuery += " (SF7.D_E_L_E_T_ <> '*') "
     TCQUERY cQuery NEW ALIAS "TMP"

     DbSelectArea("TMP")
     DbGoTop()

     _existe := .f.
     If !Eof()
        _existe := .t.
     Endif

     DbSelectArea("TMP")
     DbCloseArea()
     DbSelectArea("Z17")
     If _existe
        MsgStop("Registro nao pode ser excluido pois existe exceção fiscal cadastrada!")
     Endif
     lRet := !_existe
Return(lRet)
