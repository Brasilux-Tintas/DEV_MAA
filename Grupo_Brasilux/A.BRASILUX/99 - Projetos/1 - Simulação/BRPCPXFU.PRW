//#include 'brasilux.ch'
#include "protheus.ch"
#include 'topconn.ch'                                                                                   	
#include "rwmake.ch"                                                                                      
#define DS_MODALFRAME            128  // 0x80
#define WS_POPUP          2147483648  // 0x80000000L
#define WS_CAPTION          12582912  // 0x00C00000L
#define WS_VISIBLE         268435456  // 0x10000000L
#define GEL_POS  02
#xtranslate bSETGET(<uVar>) => { | u | If( PCount() == 0, <uVar>, <uVar> := u ) } 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
  ±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
  ±±ºPrograma  ³ BRPCPXFU ºAutor  ³ Luís Gustavo       º Data ³  11/03/04   º±±
  ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
  ±±ºDesc.     ³ Programa que contém varias funções relacionadas a simula - º±±
  ±±º          ³ lação de produtos.                                         º±±
  ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
  ±±ºUso       ³ BRASILUX - BRPCPX01.PRW                                    º±±
  ±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
  ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
  /*****************************************************************************/
  /*** MONTA FORMULA VIGENTE DO PRODUTO                                      ***/
  /*** Parâmetros: ExpC1 - Usuário                                           ***/
  /***             ExpC2 - Status do  cabeçalho do browse                    ***/
  /***             ExpC3 - Acessos                                           ***/
  /***             ExpN1 - Opção do browse                                   ***/
  /*****************************************************************************/
User Function fVerPerm(cUser, cStatus, cAcess, nOpc, cCodigo, cTipo)
     If cStatus $ "EE"
        If nOpc == 4
			if PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) != 0
           		If cTipo $ 'PI'
              		If !SubStr(cAcess, 2, 1) == '*'
                 		MsgBox("Usuário não autorizado a liberar as alterações dessa estrutura !!!","Atenção...","STOP")
                 		Return(.f.)
              		Endif
              		If !Upper(Alltrim(cUser)) $ Upper(Alltrim(cUsername))
                 		MsgBox("Usuário não autorizado a liberar as alterações dessa estrutura !!!","Atenção...","STOP")
                 		Return(.f.)
              		Endif
           		ElseIf cTipo $ 'PA'
              		If !SubStr(cAcess, 4, 1) == '*'
                 		MsgBox("Usuário não autorizado a liberar as alterações dessa estrutura !!!","Atenção...","STOP")
                 		Return(.f.)
              		Endif
           		Endif
   			endif 
        ElseIf nOpc == 3
			if PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) != 0
               If cTipo $ 'PI'
                  If !SubStr(cAcess, 1, 1) == '*'
                     MsgBox("Usuário não autorizado a efetuar alterações dessa estrutura !!!","Atenção...","STOP")
                     Return(.f.)
                  Endif
               ElseIf cTipo == 'PA'
                      If !SubStr(cAcess, 3, 1) == '*'
                         MsgBox("Usuário não autorizado a efetuar alterações dessa estrutura !!!","Atenção...","STOP")
                         Return(.f.)
                      Endif
               Endif
   			endif 
        ElseIf nOpc == 2
			if PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) != 0
               If cTipo == 'PI'
                  If !Upper(Alltrim(cUser)) == Upper(Alltrim(cUsername))
                     MsgBox("Usuário não autorizado a efetuar alterações dessa estrutura !!!","Atenção...","STOP")
                     Return(.f.)
                  Else
                     If !SubStr(cAcessos, 1, 1) == '*'
                        MsgBox("Usuário não autorizado a efetuar alterações dessa estrutura !!!","Atenção...","STOP")
                        Return(.f.)
                     Endif
                  Endif
               ElseIf cTipo == 'PA'
                      If !Empty(cUser)
                         If !Upper(Alltrim(cUser)) == Upper(Alltrim(cUsername))
                            MsgBox("Usuário não autorizado a efetuar alterações dessa estrutura !!!","Atenção...","STOP")
                            Return(.f.)
                         Endif
                      Else
                         If SubStr(cAcessos, 3, 1) == '*'
                            MsgBox("Usuário não autorizado a efetuar alterações dessa estrutura !!!","Atenção...","STOP")
                            Return(.f.)
                         Endif
                      Endif
               Endif
   			endif 
        Endif
     ElseIf cStatus $ "PP"
			if PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) != 0
            	If nOpc == 4
               		If !SubStr(cAcess, 4 , 1) == '*'
                  		MsgBox("Usuário não autorizado a liberar as alterações dessa estrutura !!!","Atenção...","STOP")
                  		Return(.f.)
               		Endif
            	ElseIf nOpc == 2
                   If !SubStr(cAcess, 3 , 1) == '*'
                      MsgBox("Usuário não autorizado a efetuar alterações dessa estrutura !!!","Atenção...","STOP")
                      Return(.f.)
                   Endif
                   If !cTipo $ 'PA'
                      MsgBox("Esse produto não pode ser alterado nesse status !!!","Atenção...","STOP")
                      Return(.f.)
                   Endif
            	Endif
   			endif 
     ElseIf cStatus $ "EA"
			if PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) != 0
            	If nOpc == 4
               		If !SubStr(cAcess, 5, 1) == '*'
                  		MsgBox("Usuário não autorizado a liberar as alterações dessa estrutura !!!","Atenção...","STOP")
                  		Return(.f.)
               		Endif
            	ElseIf nOpc == 2
                 MsgBox("Usuário não autorizado a efetuar alterações dessa estrutura !!!","Atenção...","STOP")
                 Return(.f.)
            	Endif
   			endif 
     ElseIf cStatus $ "AC.RE.RT"
            If !nOpc == 1
               MsgBox("Atenção esse status não permite manutenção dessa estrutura !!!","Informação...","INFO")
               Return(.f.)
            Endif
     Endif
Return(.t.)

  /*****************************************************************************/
  /*** MONTA FORMULA VIGENTE DO PRODUTO                                      ***/
  /*** Parâmetros: ExpC1 - Código                                            ***/
  /***             ExpA1 - Matriz com cabeçalho do browse                    ***/
  /***             ExpA2 - Matriz com os dados da fórmula vigente            ***/
  /***             ExpO1...O4 - Objetos a serem atualizados na tela principal***/
  /***             Expn1...n4 - Variáveis a serem atualizados na tela princ. ***/
  /*****************************************************************************/
User Function fBusVig(cCodigo, cRevisao, cTipo, aHeaderVig, aDadVig, oPerFor, nPerFor, oPesEsp, nPesEsp, oCusRea, nCusRea, oCusDol, nCusDol, oPrcVig, nPrcVig, nOldPVC, nOldBri, aGeral, nOpc, aMarcacao, oSayVig, nCusOuO, oCusOuO, oCusVig )
     Local aCampos := {}
     Local aStrSG1 := {}
     Local aStrSZN := {}
     Local aEspVig := {}
     Local cQuery  := ""
     Local nY      := 0
     Local nX      := 0
     Local nPos    := 0
     Local _lOpen        := .F. //LGS#20200207 - Adequação para release 12.1.25
     Local _cAliasSX3 := GetNextAlias() //LGS#20200207 - Adequação para release 12.1.25
     
     // ABERTURA DO DICIONÁRIO SX3 - LGS#20200207 - Adequação para release 12.1.25
     OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
     _lOpen := Select( _cAliasSX3 ) > 0

     If !_lOpen //LGS#20200128 - Adequação para release 12.1.25
        MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
        Return
     Endif

     /********************************************************************************************************************************/
     /*** BLOCO ALTERADO EM 07/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
     /*DbSelectArea("SX3")
     DbSetOrder(2)
     MsSeek("ZN_COMP")
     aadd(aCampos, { "G1_COMP"   , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aStrSG1, { "G1_COMP"   , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aStrSZN, { "ZN_COMP", SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aHeaderVig, ( _cAliasSX3 )->( X3_TITULO ) )
     MsSeek("ZN_DESC")
     aadd(aStrSG1, { "G1_DESC"   , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aStrSZN, { "ZN_DESC"   , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aHeaderVig, ( _cAliasSX3 )->( X3_TITULO ) )
     MsSeek("ZN_TRT")
     aadd(aCampos, { "G1_TRT"    , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aStrSG1, { "G1_TRT"    , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aStrSZN, { "ZN_TRT"    , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aHeaderVig, ( _cAliasSX3 )->( X3_TITULO ) )
     MsSeek("ZN_PERC")
     aadd(aCampos, { "G1_PERC"   , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aStrSG1, { "G1_PERC"   , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aStrSZN, { "ZN_PERC"   , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aHeaderVig, ( _cAliasSX3 )->( X3_TITULO ) )
     MsSeek("ZN_QUANT")
     aadd(aCampos, { "G1_QUANT"  , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aStrSG1, { "G1_QUANT"  , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aStrSZN, { "ZN_QUANT"  , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aHeaderVig, ( _cAliasSX3 )->( X3_TITULO ) )
     MsSeek("ZN_PERDA")
     aadd(aCampos, { "G1_PERDA"  , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aStrSG1, { "G1_PERDA"  , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aStrSZN, { "ZN_PERDA"  , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aHeaderVig, ( _cAliasSX3 )->( X3_TITULO ) )
     MsSeek("ZN_PESESP")
     aadd(aStrSG1, { "G1_PESESP" , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aStrSZN, { "ZN_PESESP" , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aHeaderVig, ( _cAliasSX3 )->( X3_TITULO ) )
     MsSeek("ZN_CUSTOUN")
     aadd(aStrSG1, { "G1_CUSTOUN", SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aStrSZN, { "ZN_CUSTOUN", SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aHeaderVig, ( _cAliasSX3 )->( X3_TITULO ) )
     MsSeek("ZN_CUSTORE")
     aadd(aStrSG1, { "G1_CUSTORE", SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aStrSZN, { "ZN_CUSTORE", SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aHeaderVig, ( _cAliasSX3 )->( X3_TITULO ) )
     MsSeek("ZN_CUSTODO")
     aadd(aStrSG1, { "G1_CUSTODO", SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aStrSZN, { "ZN_CUSTODO", SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aHeaderVig, ( _cAliasSX3 )->( X3_TITULO ) )
     MsSeek("ZN_INI")
     aadd(aCampos, { "G1_INI"    , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aStrSG1, { "G1_INI"    , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aStrSZN, { "ZN_INI"    , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aHeaderVig, ( _cAliasSX3 )->( X3_TITULO ) )
     MsSeek("ZN_FIM")
     aadd(aCampos, { "G1_FIM"    , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aStrSG1, { "G1_FIM"    , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aStrSZN, { "ZN_FIM"    , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aHeaderVig, ( _cAliasSX3 )->( X3_TITULO ) )
     MsSeek("ZN_FIXVAR")
     aadd(aCampos, { "G1_FIXVAR" , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aStrSG1, { "G1_FIXVAR" , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aStrSZN, { "ZN_FIXVAR" , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aHeaderVig, ( _cAliasSX3 )->( X3_TITULO ) )
     MsSeek("ZN_REVINI")
     aadd(aCampos, { "G1_REVINI" , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aStrSG1, { "G1_REVINI" , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aStrSZN, { "ZN_REVINI" , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aHeaderVig, ( _cAliasSX3 )->( X3_TITULO ) )
     MsSeek("ZN_REVFIM")
     aadd(aCampos, { "G1_REVFIM" , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aStrSG1, { "G1_REVFIM" , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aStrSZN, { "ZN_REVFIM" , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aHeaderVig, ( _cAliasSX3 )->( X3_TITULO ) )
     MsSeek("ZN_OPERACA")
     aadd(aCampos, { "G1_OPERACA", SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aStrSG1, { "G1_OPERACA", SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aStrSZN, { "ZN_OPERACA", SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
     aadd(aHeaderVig, ( _cAliasSX3 )->( X3_TITULO ) )*/
     DbSelectArea( _cAliasSX3 )
     DbSetOrder(2)
     MsSeek("ZN_COMP")
     aadd(aCampos, { "G1_COMP"   , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aStrSG1, { "G1_COMP"   , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aStrSZN, { "ZN_COMP"   , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aHeaderVig, ( _cAliasSX3 )->( X3_TITULO ) )
     MsSeek("ZN_DESC")
     aadd(aStrSG1, { "G1_DESC"   , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aStrSZN, { "ZN_DESC"   , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aHeaderVig, ( _cAliasSX3 )->( X3_TITULO ) )
     MsSeek("ZN_TRT")
     aadd(aCampos, { "G1_TRT"    , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aStrSG1, { "G1_TRT"    , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aStrSZN, { "ZN_TRT"    , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aHeaderVig, ( _cAliasSX3 )->( X3_TITULO ) )
     MsSeek("ZN_PERC")
     aadd(aCampos, { "G1_PERC"   , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aStrSG1, { "G1_PERC"   , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aStrSZN, { "ZN_PERC"   , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aHeaderVig, ( _cAliasSX3 )->( X3_TITULO ) )
     MsSeek("ZN_QUANT")
     aadd(aCampos, { "G1_QUANT"  , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aStrSG1, { "G1_QUANT"  , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aStrSZN, { "ZN_QUANT"  , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aHeaderVig, ( _cAliasSX3 )->( X3_TITULO ) )
     MsSeek("ZN_PERDA")
     aadd(aCampos, { "G1_PERDA"  , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aStrSG1, { "G1_PERDA"  , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aStrSZN, { "ZN_PERDA"  , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aHeaderVig, ( _cAliasSX3 )->( X3_TITULO ) )
     MsSeek("ZN_PESESP")
     aadd(aStrSG1, { "G1_PESESP" , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aStrSZN, { "ZN_PESESP" , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aHeaderVig, ( _cAliasSX3 )->( X3_TITULO ) )
     MsSeek("ZN_CUSTOUN")
     aadd(aStrSG1, { "G1_CUSTOUN", ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aStrSZN, { "ZN_CUSTOUN", ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aHeaderVig, ( _cAliasSX3 )->( X3_TITULO ) )
     MsSeek("ZN_CUSTORE")
     aadd(aStrSG1, { "G1_CUSTORE", ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aStrSZN, { "ZN_CUSTORE", ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aHeaderVig, ( _cAliasSX3 )->( X3_TITULO ) )
     MsSeek("ZN_CUSTODO")
     aadd(aStrSG1, { "G1_CUSTODO", ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aStrSZN, { "ZN_CUSTODO", ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aHeaderVig, ( _cAliasSX3 )->( X3_TITULO ) )
     MsSeek("ZN_INI")
     aadd(aCampos, { "G1_INI"    , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aStrSG1, { "G1_INI"    , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aStrSZN, { "ZN_INI"    , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aHeaderVig, ( _cAliasSX3 )->( X3_TITULO ) )
     MsSeek("ZN_FIM")
     aadd(aCampos, { "G1_FIM"    , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aStrSG1, { "G1_FIM"    , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aStrSZN, { "ZN_FIM"    , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aHeaderVig, ( _cAliasSX3 )->( X3_TITULO ) )
     MsSeek("ZN_FIXVAR")
     aadd(aCampos, { "G1_FIXVAR" , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aStrSG1, { "G1_FIXVAR" , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aStrSZN, { "ZN_FIXVAR" , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aHeaderVig, ( _cAliasSX3 )->( X3_TITULO ) )
     MsSeek("ZN_REVINI")
     aadd(aCampos, { "G1_REVINI" , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aStrSG1, { "G1_REVINI" , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aStrSZN, { "ZN_REVINI" , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aHeaderVig, ( _cAliasSX3 )->( X3_TITULO ) )
     MsSeek("ZN_REVFIM")
     aadd(aCampos, { "G1_REVFIM" , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aStrSG1, { "G1_REVFIM" , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aStrSZN, { "ZN_REVFIM" , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aHeaderVig, ( _cAliasSX3 )->( X3_TITULO ) )
     MsSeek("ZN_OPERACA")
     aadd(aCampos, { "G1_OPERACA", ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aStrSG1, { "G1_OPERACA", ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aStrSZN, { "ZN_OPERACA", ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
     aadd(aHeaderVig, ( _cAliasSX3 )->( X3_TITULO ) )

     //DbSelectArea("SX3")
     DbSelectArea( _cAliasSX3 )
     DbSetOrder(1)
     /********************************************************************************************************************************/
     For nX := 1 To Len(aCampos)
         cQuery += ","+aCampos[nX][1]
     Next nX
     cQuery := "SELECT "+SubStr(cQuery,2)+" "
     cQuery += "FROM "+RetSqlName("SG1")+" SG1 "
     cQuery += "WHERE SG1.G1_FILIAL='"+xFilial("SZN")+"' AND "
     cQuery += "SG1.G1_COD='"+cCodigo+"' AND "
     cQuery += "SG1.D_E_L_E_T_=' ' "
     cQuery += "ORDER BY SG1.G1_TRT "
     cQuery := ChangeQuery(cQuery)
     dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QSG1",.T.,.T.)
     For nX := 1 To Len(aCampos)
         If ( aCampos[nX][2]<>"C" )
            TcSetField("QSG1",aCampos[nX,1],aCampos[nX,2],aCampos[nX,3],aCampos[nX,4])
         EndIf
     Next nX
     nPosCom := aScan(aStrSG1, { |x| Trim(x[1]) == "G1_COMP"    } )
     nPosPda := aScan(aStrSG1, { |x| Trim(x[1]) == "G1_PERDA"   } )
     nPosQtd := aScan(aStrSG1, { |x| Trim(x[1]) == "G1_QUANT"   } )
     nPosPer := aScan(aStrSG1, { |x| Trim(x[1]) == "G1_PERC"    } )
     nPosCUn := aScan(aStrSG1, { |x| Trim(x[1]) == "G1_CUSTOUN" } )
     nPosCRe := aScan(aStrSG1, { |x| Trim(x[1]) == "G1_CUSTORE" } )
     nPosCDo := aScan(aStrSG1, { |x| Trim(x[1]) == "G1_CUSTODO" } )
     nPosPes := aScan(aStrSG1, { |x| Trim(x[1]) == "G1_PESESP"  } )
     nPosOpe := aScan(aStrSG1, { |x| Trim(x[1]) == "G1_OPERACA" } )
     DbSelectArea("QSG1")
     DbGoTop()
     While ( !Eof() )
           // produto de custeio
           //If U_IsProdCusto(QSG1->G1_COMP)
           //   QSG1->(dbSkip())
           //   Loop
           //Endif   
           aadd(aDadVig, Array( Len( aStrSG1 ) ) )
           nY++
           For nX := 1 To Len(aStrSG1)
               If aStrSG1[nX][1] $ "G1_COMP.G1_TRT.G1_PERC.G1_QUANT.G1_PERDA.G1_INI.G1_FIM.G1_FIXVAR.G1_REVINI.G1_REVFIM.G1_OPERACA"
                  aDadVig[nY][nX] := QSG1->&(aStrSG1[nX][1])
               Else
                  If aStrSG1[nX][1] $ "G1_DESC"
                     aDadVig[nY][nX] := Posicione("SB1", 1, xFilial("SB1")+aDadVig[nY][nPosCom], "B1_DESC")
                  ElseIf aStrSG1[nX][1] $ "G1_PESESP"
                         aDadVig[nY][nX] := Posicione("SB1", 1, xFilial("SB1")+aDadVig[nY][nPosCom], "B1_PESOESP")
                  ElseIf aStrSG1[nX][1] $ "G1_CUSTOUN"
                        // produto de custeio
                        If U_IsProdCusto(aDadVig[nY][nPosCom])
                           aDadVig[nY][nX] := CriaVar("ZN_CUSTOUN")
                           Loop
                        Endif    
                         If Posicione("SB1", 1, xFilial("SB1")+aDadVig[nY][nPosCom], "B1_TIPO") $ "MP.MC"
                            aDadVig[nY][nX] := Posicione("SB1", 1, xFilial("SB1")+aDadVig[nY][nPosCom], "B1_UPRC")
                         Else
                            aDadVig[nY][nX] := U_CUSTOPRO(aDadVig[nY][nPosCom])
                         Endif
                  ElseIf aStrSG1[nX][1] $ "G1_CUSTORE"
                        // produto de custeio
                        If U_IsProdCusto(aDadVig[nY][nPosCom])
                           aDadVig[nY][nX] := CriaVar("ZN_CUSTORE")
                           Loop
                        Endif    
                         //aDadVig[nY][nX] := (aDadVig[nY][nPosQtd] + (aDadVig[nY][nPosQtd] * (aDadVig[nY][nPosPda] / 100))) * aDadVig[nY][nPosCUn]
                         aDadVig[nY][nX] := (aDadVig[nY][nPosQtd] / (1-(aDadVig[nY][nPosPda] / 100))) * aDadVig[nY][nPosCUn]
                  ElseIf aStrSG1[nx][1] $ "G1_CUSTODO"
                        // produto de custeio
                        If U_IsProdCusto(aDadVig[nY][nPosCom])
                           aDadVig[nY][nX] := CriaVar("ZN_CUSTODO")
                           Loop
                        Endif    
                         //aDadVig[nY][nX] := (aDadVig[nY][nPosQtd] + (aDadVig[nY][nPosQtd] * (aDadVig[nY][nPosPda] / 100))) / Posicione("SM2", 1, dDataBase, "M2_MOEDA2")
                         aDadVig[nY][nX] := (aDadVig[nY][nPosQtd] / (1-(aDadVig[nY][nPosPda] / 100))) / Posicione("SM2", 1, dDataBase, "M2_MOEDA2")
                  Endif
               Endif
           Next nX
           DbSelectArea("QSG1")
           DbSkip()
     Enddo
     DbSelectArea("QSG1")
     DbCloseArea()
     If Len(aDadVig) == 0
        aadd(aDadVig, {} )
        For nX := 1 To Len(aStrSG1)
            aadd(aDadVig[1], "")
        Next nX
     Else
        For nX := 1 To Len(aDadVig)
            If !(cNumEmp == '01010104')
               // produto de custeio
               If U_IsProdCusto(aDadVig[nX][nPosCom])
                  Loop
               Endif   
               If Posicione("SB1", 1, xFilial("SB1")+cCodigo, "B1_TIPO") $ "PA"
                  nPerFor := 0
               Else
                  nPerFor := nPerFor +  aDadVig[nX][nPosPer]
               Endif
               nCusRea += Round(aDadVig[nX][nPosCRe], 3)
               nCusDol += Round(aDadVig[nX][nPosCDo], 3)
            Endif
        Next nX
     Endif
     //DbSelectArea("SX3")
     DbSelectArea( _cAliasSX3 )
     DbSetOrder(2)
     For nX := 1 To Len(aStrSZN)
         MsSeek( Trim(aStrSZN[nX][1]) )
         aadd(aHeaderVig, ( _cAliasSX3 )->( X3_TITULO ))
         For nY := 1 To Len(aDadVig)
             aDadVig[nY][nX] := TransForm(aDadVig[nY][nX], ( _cAliasSX3 )->( X3_PICTURE ))
         Next nY
     Next nX
     aEspVig := U_fUlRvFrm(cCodigo)
     nPesEsp := aEspVig[2]
     nOldPVC := aEspVig[3]
     nOldBri := aEspVig[4]
     If cTipo $ 'PI'// .and. Alltrim(Posicione("SZM", 1, xFilial("SZM")+cCodigo+cRevisao, "ZM_UM")) == 'L'
        nCusOuO := nCusRea / nPesEsp
        If Alltrim(Posicione("SZM", 1, xFilial("SZM")+cCodigo+cRevisao, "ZM_UM")) == 'L'
           oCusOuO:Refresh()
           oCusVig:lVisibleControl := .t.
           oCusOuO:lVisibleControl := .t.
		Endif
     //Else
     //   oCusVig:lVisibleControl := .f.
     //   oCusOuO:lVisibleControl := .f.
     Endif
     oPerFor:Refresh() ; oPesEsp:Refresh() ; oCusRea:Refresh() ; oCusDol:Refresh() ; oOldPVC:Refresh() ; oOldBri:Refresh()

     If nOpc == 2
        nPos := Iif( aGeral[GEL_POS] == 0, 1, aGeral[GEL_POS])
        nPrcVig := U_fBusPrc(aMarcacao[nPos][1][2], "VIG", , "2", , , "GEL")
        oPrcVig:Refresh()
     Endif
     If cTipo $ 'PI'
        oSayVig:lVisibleControl := .f.
        oPrcVig:lVisibleControl := .f.
     Else
        oSayVig:lVisibleControl := .t.
        oPrcVig:lVisibleControl := .t.
     Endif
     DbSelectArea( _cAliasSX3 )
     DbCloseArea()
Return

  /*****************************************************************************/
  /*** MONTA PREÇO DO PRODUTO - Principal                                    ***/
  /*** Parâmetros: ExpC1 - Código                                            ***/
  /***             ExpC2 - Tipo de Produto (Fórmula Vigente - Produto Novo   ***/
  /***             ExpC3 - Revisão                                           ***/
  /*****************************************************************************/
User Function fBusPrc(cCod, cTipPro, cRev, cOpc, aHeader, aCols, cOpc2)
	 Local nArq, cPlanilha, nLidos, cLinha, lOk, aAux, cVar, i, nContCols
	 Private aPrazos  := {}
     AADD(aPrazos, 60)

     DbSelectArea("SX3")
     DbSetOrder(1)

     DbSelectArea("SB1")
     DbSetOrder(1)
     nUsado2   := 0
     MV_PAR01  := Iif(cNumEmp == "01010101","BRASILUX",Iif(cNumEmp == "01010104","RESINA",Iif(cNumEmp == "01060101","DISSOLTE",Iif(cNumEmp = "05","UNIONSUR","SEMPLANI"))))
     cPlanilha := Alltrim(mv_par01)+".pdv"
     nArq      := fOpen(cPlanilha)
     nLidos    := 0
     If nArq > 0
        FSeek(nArq, 0, 0)
        nTamArq := FSeek(nArq, 0, 2)
        FSeek(nArq, 0, 0)
        lOk     := .f.
        aAux    := {}
        While nLidos < nTamArq
              cLinha := U_fGets(nArq, nTamArq)
              If SubStr(cLinha, 6, 3) == "PIS"
                 lOk := .t.
              Endif
              If lOk
                 nUsado2 := nUsado2 + 1
                 cVar   := "V"+ALLTRIM( str( nUsado2 ) )
                 aadd( aAux, { cVar, U_cTon( alltrim( substr( cLinha, 36, 10) ) ) })
              endif
              If SubStr(cLinha,6,16) == "DESP. COMERCIAIS"
                 lOk = .f.
              Endif
              nLidos += len(cLinha)+2
        End
        fClose(nArq)
     Else
        Alert("Impossível abrir planilha "+cPlanilha)
        Return
     Endif
     cProduto  := cCod
     nMO       := 0
     nJuros    := GETMV("MV_JUROS")
     nCusto    := 0
     nLucro    := 0
     nComissao := 0
     nPreco    := 0
     nLinGetD  := 0
     nIcms     := GETMV("MV_ICMPAD")
     DbSelectArea("SE4")
     DbSetOrder(1)
     DbSeek(xFilial("SE4")+'010',.t.)
     cCondPagto := SE4->E4_CODIGO
     nCusto     := fCalPrc( cProduto, cTipPro, cRev, ""  , 1, cOpc, aHeader, aCols)
     nMo        := fCalPrc( cProduto, cTipPro, cRev, "MO", 2, cOpc, aHeader, aCols)
     nLucro     := fCalPrc( cProduto, cTipPro, cRev, "LU", 2, cOpc, aHeader, aCols)
     nComissao  := fCalPrc( cProduto, cTipPro, cRev, "CO", 2, cOpc, aHeader, aCols)

     nQtdeParc := len(aPrazos)
     nJur      := 0
     For i := 1 to nQtdeParc
         nJur += 1/((1+(nJuros/100))^((12*aPrazos[i])/365))
     Next
     nJur := (1/nQtdeParc)*nJur

     nSomaCusto := nCusto+nMo
     nPerc      := nIcms+nLucro+nComissao
     nQtdeCols  := len(aAux)
     For nContCols = 1 to nQtdeCols
         nPerc += aAux[nContCols,2]
     Next
     nPreco := nSomaCusto / (nJur - (nPerc/100))
Return(nPreco)

  /*****************************************************************************/
  /*** FUNÇÕES AUXILIARES PARA MONTAGEM DO PREÇO                             ***/
  /*** Parâmetros: ExpC1 - Código                                            ***/
  /***             ExpC2 - Tipo de Produto (Fórmula Vigente - Produto Novo   ***/
  /***             ExpC3 - Revisão                                           ***/
  /***             ExpC4 - Parametro do tipo de calculo                      ***/
  /***             ExpN1 - Opção de calculo                                  ***/
  /*****************************************************************************/
Static Function fCalPrc(cProduto, cTipPro, cRev, _cOpc, nOpc, cOpc, aHeader, aCols)
       Local nArea
       Local nReg
       Local nOrdem
       Local nRegB1
       Local nOrdemB1, nX
       Private aArray := Array(1, 4) //Array com Produto, para fins de calc prc tabela, usado tb nas planilhas

       If nOpc == 1
          _VlrMov := 0.00
          If !Empty(cProduto)
             If cTipPro $ "VIG"
                DbSelectArea("SB1")
                If DbSeek(xFilial("SB1")+cProduto)
                   _VlrMov := U_CUSTOPRO(cProduto)
                Endif
             ElseIf cTipPro $ "NEW"
                    cAlias  := alias()
                    nOrder := IndexOrd()
                    nRecno := Recno()
                    nPosQtd := aScan(aHeader, { |x| Trim(x[2]) == "ZN_QUANT" } )
                    nPosPda := aScan(aHeader, { |x| Trim(x[2]) == "ZN_PERDA" } )
                    nPosCUn := aScan(aHeader, { |x| Trim(x[2]) == "ZN_CUSTOUN" } )
                    nPosCom := aScan(aHeader, { |x| Trim(x[2]) == "ZN_COMP" } )
                    For nX := 1 to Len(aCols)
                        If !aCols[nX][Len(aHeader)+1]
                           // produto de custeio
                           If U_IsProdCusto(aCols[nX][nPosCom])
                              Loop
                           Endif   
                           _VlrMov += Iif( Valtype( aCols[nX][nPosQtd] ) == 'C',  Val( Stuff( aCols[nX][nPosQtd], At( ',', aCols[nX][nPosQtd] ), 1, ".") ), aCols[nX][nPosQtd]) / (1 - (Iif( Valtype( aCols[nX][nPosPda] ) == 'C',  Val( Stuff( aCols[nX][nPosPda], At( ',', aCols[nX][nPosPda] ), 1, ".") ), aCols[nX][nPosPda]) / 100)) * (Iif( Valtype( aCols[nX][nPosCUn] ) == 'C',  Val( Stuff( aCols[nX][nPosCUn], At( ',', aCols[nX][nPosCUn] ), 1, ".") ), aCols[nX][nPosCUn]))
                        Endif
                    Next
                    DbSelectArea(cAlias)
                    DbSetOrder(nOrder)
                    DbGoTo(nRecno)
             Endif
          Endif
       Else
          nArea  := Alias()
          nReg   := recno()
          nOrdem := IndexOrd()

          DbSelectArea("SB1")
          nRegB1   := recno()
          nOrdemB1 := IndexOrd()
          _VlrMov  := 0.00   

          If cTipPro $ "VIG"
	       		aArray[1][4] := cProduto
          		_VlrMov :=	EXECBLOCK("BRPCP011",.F.,.F.,_cOpc)
          else 
			Do Case
    	         Case _cOpc=="MO"          // Valor da Mao de Obra
					DbSelectArea("SB1")
					DbSetorder(1)
		   			DbSeek(xFilial("SB1")+cProduto, .F.)
		      		If Found()            
		             	do case 
		             	case (SB1->B1_GRTRIB $ '002.005') .or. !(alltrim(SB1->B1_TIPO) $ "PA_PI")
		                   _VlrMov := 0
        		        case Len(Alltrim(cProduto)) # 12
                		   _VlrMov := SB1->B1_VLRMO   
		              	otherwise
        		           	// Definir custo por litro	
                		   	DbSelectArea("SZ1")     // LINHA DE PRODUTO
		                   	DbSetOrder(1)
        		           	DbSeek(xFilial("SZ1")+SubStr(cProduto,4,2), .f.)
                		   	If Found().And. SZ1->Z1_VLRMO # 0.00
		                   		do case
        		           		case alltrim(SB1->B1_UM) == 'L'
                		     		_VlrMov := SZ1->Z1_VLRMO
		                   		case alltrim(SB1->B1_UM) $ 'K_KG'
        		             		_VlrMov := SZ1->Z1_VLRMO/SB1->B1_PESOESP
                		      	case alltrim(SB1->B1_SEGUM) == 'L'
                      				_VlrMov := SZ1->Z1_VLRMO*SB1->B1_CONV
		                      	otherwise 
				                   	_VlrMov := iif(alltrim(SB1->B1_TIPO) $ "PA_PI",SB1->B1_VLRMO,0)
								endcase
							else
	    		               _VlrMov := SB1->B1_VLRMO   
	    					endif 
							/*
							If _VlrMov == 0 // Se ainda não preencheu o Vlr. MO, pegar pela embalagem
								DbSelectArea("SZ5")     // EMBALAGEM
								DbSetOrder(1)
								DbSeek(xFilial("SZ5")+SubStr(cProduto,11,2), .f.)
								If Found()
									_VlrMov := SZ1->Z1_VLRMO * SZ5->Z5_VOLUME  // valor da mo por litro * volume da embalagem
								Endif    
		      				Endif */
      					endcase 
					Endif        
					If Len( Alltrim(cProduto) ) >= 12 .and. _VlrMov == 0 // Se ainda não preencheu o Vlr. MO, pegar pela embalagem
                    	_VlrMov := Posicione("SZ5", 1, xFilial("SZ5")+SubStr(cProduto, 11, 02), "Z5_VOLUME") * Posicione("SZ1", 1, xFilial("SZ1")+SubStr(cProduto, 04, 02), "Z1_VLRMO") 
     				Endif

                    /*
                	If Len( Alltrim(cProduto) ) >= 12
                    	_VlrMov := Posicione("SZ5", 1, xFilial("SZ5")+SubStr(cProduto, 11, 02), "Z5_VOLUME") * Posicione("SZ1", 1, xFilial("SZ1")+SubStr(cProduto, 04, 02), "Z1_VLRMO") 
	                Endif
    	            */
        	     Case _cOpc=="LU"          // % do Lucro
            	      /*If cTipPro $ "VIG"
                	     DbSelectArea("SB1")
                    	 DbSetorder(1)
	                     DbSeek(xFilial("SB1")+cProduto,.F.)
    	                 If Found()
        	                If Len(Alltrim(cProduto))>=12
            	               _VlrMov := Posicione("SZ1", 1, xFilial("SZ1")+SubStr(cProduto, 4, 2), "Z1_LUCRO")
                	        Else
                    	       _VlrMov := SB1->B1_LUCRO
	                        Endif
    	                 Endif
        	          Else*/
            	         If Len(Alltrim(cProduto))>=12
                	        _VlrMov := Posicione("SZ1", 1, xFilial("SZ1")+SubStr(cProduto, 4, 2), "Z1_LUCRO")
                    	 Else
                        	_VlrMov := 0
	                     Endif
    	             /* Endif*/
        	     Case _cOpc=="CO"          // % da Comissao
/*  	                If cTipPro $ "VIG"
        	             DbSelectArea("SB1")
            	         DbSetorder(1)
                	     DbSeek(xFilial("SB1")+cProduto,.F.)
                    	 If Found()
	                        If Len(Alltrim(cProduto))>=12
    	                       _VlrMov := Posicione("SZ1", 1, xFilial("SZ1")+SubStr(cProduto, 4, 2), "Z1_COMISSA")
        	                Else
            	               _VlrMov := SB1->B1_COMIS
                	        Endif
                    	 Endif
	                  Else*/
    	                 If Len(Alltrim(cProduto))>=12
        	                _VlrMov := Posicione("SZ1", 1, xFilial("SZ1")+SubStr(cProduto, 4, 2), "Z1_COMISSA")
            	         Else
                	        _VlrMov := 0
                    	 Endif
	                /*  Endif*/
    	         Case _cOpc=="L2"          // % do Lucro
/*      	            If cTipPro $ "VIG"
            	         DbSelectArea("SB1")
                	     DbSetorder(1)
                    	 DbSeek(xFilial("SB1")+cPorduto,.F.)
	                     If Found()
    	                    If Len(Alltrim(cProduto))>=12
        	                   _VlrMov := Posicione("SZ1", 1, xFilial("SZ1")+SubStr(cProduto, 4, 2), "Z1_LUCRO2")
            	            Else
                	           _VlrMov := SB1->B1_LUCRO2
                    	    Endif
	                     Endif
    	              Else*/
        	             If Len(Alltrim(cProduto))>=12
            	            _VlrMov := Posicione("SZ1", 1, xFilial("SZ1")+SubStr(cProduto, 4, 2), "Z1_LUCRO2")
                	     Else
                    	    _VlrMov := 0
	                     Endif
/*  	                Endif*/
			EndCase
		  endif 
          DbSelectArea("SB1")
          DbSetOrder(nOrdemB1)
          DbGoto(nRegB1)

          DbSelectArea(nArea)
          DbSetOrder(nOrdem)
          DbGoto(nReg)
       Endif
Return(_VlrMov)

/****************************************************************************/
/*** MONTA CUSTO DO PRODUTO DE ACORDO COM A REVISÃO EM SIMULAÇÃO.         ***/
/*** Parâmetros: ExpC1 - Código                                           ***/
/***             ExpC2 - Revisão                                          ***/
/****************************************************************************/
User Function fCalCRev(cProd, cRevi, cOpc, aHeader, aCols)
     Local nPosCom := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_COMP" } )
     Local nPosQtd := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_QUANT"   } )
     Local nPosPda := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_PERDA"   } )
     Local nCusto := 0
     Local nX
     DbSelectArea("SZN")
     DbSetOrder(2)
     cAlias := ALIAS()
     nRecno := RECNO()
     nIndex := INDEXORD()
     If !cOpc $ "1"
        DbSeek(xFilial("SZN")+cProd+cRevi,.t.)
        If Found()
           While !Eof() .and. SZN->ZN_CODIGO == cProd .and. SZN->ZN_REVISAO == cRevi
                // produto de custeio
                If U_IsProdCusto(SZN->ZN_COMP)
                     SZN->(dbSkip())
                     Loop
                Endif   

                 DbSelectArea("SB1")
                 DBSetOrder(1)
                 DbSeek(xFilial("SB1")+SZN->ZN_COMP,.t.)
                 If Found()
                    If SB1->B1_TIPO $ "MP.MC"
                       //nCusto += ((SZN->ZN_QUANT + (SZN->ZN_QUANT * (SZN->ZN_PERDA / 100))) * SB1->B1_UPRC )
					   nCusto += ((SZN->ZN_QUANT / (1-(SZN->ZN_PERDA / 100))) * SB1->B1_UPRC )
                    Else
                       nCusto += ((SZN->ZN_QUANT / (1-(SZN->ZN_PERDA / 100))) * U_CUSTOPRO(SZN->ZN_COMP))
                       //nCusto += ((SZN->ZN_QUANT + (SZN->ZN_QUANT * (SZN->ZN_PERDA / 100))) * U_CUSTOPRO(SZN->ZN_COMP))
                    Endif
                 Endif
                 DbSelectArea("SZN")
                 DbSkip()
           Enddo
        Else
           nCusto := U_CUSTOPRO(cProd)
        Endif
     Else
        For nX := 1 To Len(aCols)
            // produto de custeio
            If U_IsProdCusto(aCols[nX][nPosCom])
               Loop
            Endif   
            If Posicione("SB1", 1, xFilial("SB1")+aCols[nX][nPosCom], "B1_TIPO") $ "MP.MC"
               //nCusto += ((aCols[nX][nPosQtd] + (aCols[nX][nPosQtd] * (aCols[nX][nPosPda] / 100))) * Posicione("SB1", 1, xFilial("SB1")+aCols[nX][1], "B1_UPRC") )
               nCusto += ((aCols[nX][nPosQtd] /(1- (aCols[nX][nPosPda] / 100))) * Posicione("SB1", 1, xFilial("SB1")+aCols[nX][1], "B1_UPRC") )
            Else
               //nCusto += ((aCols[nX][nPosQtd] + (aCols[nX][nPosQtd] * (aCols[nX][nPosPda] / 100))) * U_CUSTOPRO(aCols[nX][nPosCom]))
               nCusto += ((aCols[nX][nPosQtd] /(1- (aCols[nX][nPosPda] / 100))) * U_CUSTOPRO(aCols[nX][nPosCom]))
            Endif
        Next
     Endif
     DbSelectArea(cAlias)
     DbSetOrder(nIndex)
     DbGoTo(nRecno)
Return(nCusto)

  
  /****************************************************************************/
  /*** BUSCA MOTIVO DA REVISÃO                                              ***/
  /*** Parâmetros: ExpC1 - Identificador do Log                             ***/
  /***             ExpC2 - Processo                                         ***/
  /***             ExpC3 - Status                                           ***/
  /****************************************************************************/
User Function fBusLog(cIdLog, cPrLog, cStaLog)
     DbSelectArea("SZT")
     DbSetOrder(2)
     DbSeek(xFilial("SZT")+cIdLog+cPrLog+cStaLog,.t.)
     If Found()
        If Empty(SZT->ZT_LOG)
           cLog := "."
        Else
           cLog := SZT->ZT_LOG
        Endif
     Else
        DbSelectArea("SZT")
        DbSetOrder(1)
        DbSeek(xFilial("SZT")+cIdLog,.t.)
        If Found()
           cLog := SZT->ZT_LOG
        Else
           cLog := "."
        Endif
     Endif
Return(cLog)
                     
  /****************************************************************************/
  /*** MONTA A HEADER DA GETDADOS DE ALTERAÇÃO DA ESTRUTURA                 ***/
  /*** Parâmetros: ExpA1 - aHeader a ser preenchido com o cabeçalho.        ***/
  /****************************************************************************/
User Function fMonHea(aHeader)
     Local nUsado := 0
     Local _lOpen        := .F. //LGS#20200207 - Adequação para release 12.1.25
     Local _cAliasSX3 := GetNextAlias() //LGS#20200207 - Adequação para release 12.1.25
     
     // ABERTURA DO DICIONÁRIO SX3 - LGS#20200207 - Adequação para release 12.1.25
     OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
     _lOpen := Select( _cAliasSX3 ) > 0

     If !_lOpen //LGS#20200128 - Adequação para release 12.1.25
        MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
        Return
     Endif

     /********************************************************************************************************************************/
     /*** BLOCO ALTERADO EM 07/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
     /*DbSelectArea("SX3")
     DbSetOrder(1)
     DbSeek("SZN")
     While !Eof() .And. (X3_ARQUIVO == "SZN")
           If X3USO(X3_USADO) .And. cNivel >= X3_NIVEL .And. !(TRIM(X3_CAMPO) $ "ZN_FILIAL")
              nUsado += 1
              AADD(aHeader, { Trim(X3_TITULO), X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )
           EndIf
           DbSkip()
     Enddo*/
     
     DbSelectArea( _cAliasSX3 )
     ( _cAliasSX3 )->( DbSetOrder(1) )
     ( _cAliasSX3 )->( DbSeek("SZN") )
     While !Eof() .And. ( ( _cAliasSX3 )->( X3_ARQUIVO ) == "SZN" )
           If X3USO( ( _cAliasSX3 )->( X3_USADO ) ) .And. cNivel >= ( _cAliasSX3 )->( X3_NIVEL ) .And. !(TRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) $ "ZN_FILIAL")
              nUsado += 1
              AADD(aHeader, { Trim( ( _cAliasSX3 )->( X3_TITULO ) ), ( _cAliasSX3 )->( X3_CAMPO ), ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), ( _cAliasSX3 )->( X3_VALID ), ( _cAliasSX3 )->( X3_USADO ), ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_ARQUIVO ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
           EndIf
           DbSkip()
     Enddo
     DbSelectArea( _cAliasSX3 )
     DbCloseArea()
Return

  /****************************************************************************/
  /*** MONTA A ACOLS DA GETDADOS DA ALTERAÇÃO DA ESTRUTURA                  ***/
  /*** Parâmetros: aEXP01 - Matriz para aCols                               ***/
  /***             aEXP02 - Matriz com aHeader                              ***/
  /***             cEXP03 - 1 - Visualiza, 2 - Manutenção, 3 - Simulação    ***/
  /***             cEXP04 - Código do Produto                               ***/
  /***             cEXP05 - Revisão do Produto                              ***/
  /***             cEXP06 - Identificador do processo                       ***/
  /***             cEXP07 - Tipo do Produto                                 ***/
  /***             cEXP08 - Unidade de medida do Produto                    ***/
  /****************************************************************************/
User Function fMonCol(aCols, aHeader, cTipOpe, cCodigo, cRevisao, cId, cTipo, cUM, nPes123)
     Local nUsado  := Len(aHeader)
     Local nPosCom := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_COMP" } )
     Local nPosPer := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_PERC"    } )
     Local nPosQtd := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_QUANT"   } )
     Local nPosPda := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_PERDA"   } )
     Local nPosCUn := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_CUSTOUN" } )
     Local nPosCRe := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_CUSTORE" } )
     Local nPosCDo := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_CUSTODO" } )
     Local nPosPEs := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_PESESP"  } )
     //Local nPosSeq := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_TRT"     } )
     //Local nPosDes := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_DESC"    } )
     //Local nPosOpe := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_OPERACA" } )
     Local cQry    := ""
     Local cTcq    := ""
     Local nPesEsp := 0
     Local nX
     Local cKL     := IIf(Alltrim(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(cCodigo, 11, 02), "Z5_UMEMB"))='K','99','00')

     If cTipOpe == 1 .or. cTipOpe == 2
        DbSelectArea("SZN")
        DbSetOrder(2)
        DbSeek(xFilial("SZN")+cCodigo+cRevisao,.t.)
        If Found()
           cQry += "SELECT SZN.ZN_COMP    AS ZN_COMP   , ISNULL(SB1.B1_DESC, "
           cQry += " ( SELECT SZM.ZM_DESCRIC FROM "+RetSqlName("SZM")+" SZM WHERE SZM.ZM_FILIAL = '"+xFilial("SZM")+"'"
           cQry += " AND SZM.D_E_L_E_T_ = '' AND SZM.ZM_CODIGO = '"+SubStr(cCodigo, 1, 10)+cKL+"' AND SZM.ZM_REVISAO = '"+cRevisao+"' ) ) AS ZN_DESC, "
           cQry += "       SZN.ZN_TRT     AS ZN_TRT    , SZN.ZN_PERC    AS ZN_PERC, "
           cQry += "       SZN.ZN_QUANT   AS ZN_QUANT  , SZN.ZN_PERDA   AS ZN_PERDA, "
           cQry += "       SB1.B1_PESOESP AS ZN_PESESP , 0              AS ZN_CUSTOUN, "
           cQry += "       0              AS ZN_CUSTORE, 0              AS ZN_CUSTODO, "
           cQry += "       SZN.ZN_INI     AS ZN_INI    , SZN.ZN_FIM     AS ZN_FIM, "
           cQry += "       SZN.ZN_FIXVAR  AS ZN_FIXVAR , SZN.ZN_REVINI  AS ZN_REVINI, "
           cQry += "       SZN.ZN_REVFIM  AS ZN_REVFIM , SZN.ZN_OPERACA AS ZN_OPERACA "
           cQry += "FROM "+RetSqlName("SZN")+" SZN "
           cQry += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 ON SZN.ZN_FILIAL = SB1.B1_FILIAL AND SZN.ZN_COMP = SB1.B1_COD AND SB1.D_E_L_E_T_ = '' "
           cQry += "WHERE SZN.D_E_L_E_T_ = '' "
           cQry += "  AND SZN.ZN_FILIAL  = '"+xFilial("SZN")+"' "
           cQry += "  AND SZN.ZN_CODIGO  = '"+cCodigo+"' "
           cQry += "  AND SZN.ZN_REVISAO = '"+cRevisao+"' "
           cQry += "ORDER BY SZN.ZN_FILIAL, SZN.ZN_CODIGO, SZN.ZN_REVISAO, SZN.ZN_TRT "
	
           cTcq := U_NovoCursor()
           TCQuery cQry ALIAS (cTcq) NEW
           nSomPes := 0
           DbSelectArea(cTcq)
           DbGoTop()
           While !Eof()
               // produto de custeio
               //If U_IsProdCusto((cTcq)->ZN_COMP)
               //   (cTcq)->(dbSkip())
               //   Loop
               //Endif   

                 AADD(aCols, Array(nUsado + 1))
                 For nX := 1 To nUsado
                     If Alltrim(aHeader[nX][2]) $ 'ZN_CUSTOUN'
                        // produto de custeio
                        If U_IsProdCusto(aCols[Len(aCols)][nPosCom])
                           aCols[Len(aCols)][nX] := CriaVar("ZN_CUSTOUN")
                           Loop
                        Endif    
                        If Posicione("SB1", 1, xFilial("SB1")+aCols[Len(aCols)][1], "B1_TIPO") $ 'MP.MC'
                           aCols[Len(aCols)][nX] := Posicione("SB1", 1, xFilial("SB1")+aCols[Len(aCols)][1], "B1_UPRC")
                        Else
                           If Len(Alltrim(aCols[Len(aCols)][1])) == 12
                              cQry1 := ""
                              cQry1 += "SELECT ZM_REVISAO "
                              cQry1 += "FROM "+RetSqlName("SZM")+" SZM WITH (NOLOCK) "
                              cQry1 += "WHERE SZM.ZM_FILIAL  = '"+xFilial("SZM")+"' "
                              cQry1 += "  AND SZM.D_E_L_E_T_ = '' "
                              cQry1 += "  AND SZM.ZM_ID      = '"+cId+"' "
                              cQry1 += "  AND SUBSTRING(SZM.ZM_CODIGO, 11, 2) IN('"+Substr(aCols[Len(aCols)][1],11,2)+"') "
                              TCQuery cQry1 ALIAS "REV" NEW
                              DbSelectArea("REV")
                              DbGoTop()
                              If Eof()
                                 aCols[Len(aCols)][nX] := U_fCCusPro(aCols[Len(aCols)][1])//fCusPro(aCols[Len(aCols)][1])
                              Else
                                 aCols[Len(aCols)][nX] := U_fCCusPro(aCols[Len(aCols)][1],REV->ZM_REVISAO)//fCusPro(aCols[Len(aCols)][1], , REV->ZM_REVISAO)
                              Endif
                              DbSelectArea("REV")
                              DbCloseArea()
                           Else
                              aCols[Len(aCols)][nX] := U_fCCusPro(aCols[Len(aCols)][1], ,Iif(Len(Alltrim(aCols[Len(aCols)][1])) == 12 .and. SubStr(Alltrim(aCols[Len(aCols)][1]), 11, 2) $ '00.99', cRevisao, Nil) )//fCusPro(aCols[Len(aCols)][1], ,Iif(Len(Alltrim(aCols[Len(aCols)][1])) == 12 .and. SubStr(Alltrim(aCols[Len(aCols)][1]), 11, 2) $ '00.99', cRevisao, Nil) )
                           Endif
                        Endif
                     ElseIf Alltrim(aHeader[nX][2]) $ 'ZN_CUSTORE'
                           // produto de custeio
                           If U_IsProdCusto(aCols[Len(aCols)][nPosCom])
                              aCols[Len(aCols)][nX] := CriaVar("ZN_CUSTORE")
                              Loop
                           Endif   
                            //aCols[Len(aCols)][nX] := ( aCols[Len(aCols)][nPosQtd] + ( aCols[Len(aCols)][nPosQtd] * ( aCols[Len(aCols)][nPosPda] / 100 ) ) ) * aCols[Len(aCols)][nPosCUn]
 			             aCols[Len(aCols)][nX] := ( aCols[Len(aCols)][nPosQtd] / (1-( aCols[Len(aCols)][nPosPda] / 100 ) ) ) * aCols[Len(aCols)][nPosCUn]
                     ElseIf Alltrim(aHeader[nX][2]) $ 'ZN_CUSTODO'
                           // produto de custeio
                           If U_IsProdCusto(aCols[Len(aCols)][nPosCom])
                              aCols[Len(aCols)][nX] := CriaVar("ZN_CUSTODO")
                              Loop
                           Endif   
                         //aCols[Len(aCols)][nX] := ( aCols[Len(aCols)][nPosQtd] + ( aCols[Len(aCols)][nPosQtd] * ( aCols[Len(aCols)][nPosPda] / 100 ) ) ) / Posicione("SM2", 1, dDataBase, "M2_MOEDA2")
                     	 aCols[Len(aCols)][nX] := ( aCols[Len(aCols)][nPosQtd] / (1-( aCols[Len(aCols)][nPosPda] / 100 ) ) ) / Posicione("SM2", 1, dDataBase, "M2_MOEDA2")

                     //ElseIf Alltrim(aHeader[nX][2]) $ 'ZN_PESESP'
                            //aCols[Len(aCols)][nX] := TCQ->&(aHeader[nX][2])//Iif(Posicione("SB1", 1, xFilial("SB1")+aCols[Len(aCols)][nPosCom], "B1_PESOESP") == 0.0, Posicione("SZM", 3, xFilial("SZM")+aCols[Len(aCols)][nPosCom], "ZM_PESESP"), Posicione("SB1", 1, xFilial("SB1")+aCols[Len(aCols)][nPosCom], "B1_PESOESP"))
                     ElseIf AllTrim(aHeader[nX][2]) == 'ZN_QUANT'
                            If (cTcq)->&(aHeader[nX][2]) == 0
                               If cTipo $ 'PA'
                                  aCols[Len(aCols)][nX] := aCols[Len(aCols)][nPosPer]
                               Else
                                  // produto de custeio
                                  If U_IsProdCusto(aCols[Len(aCols)][nPosCom])
                                    aCols[Len(aCols)][nX] := (aCols[Len(aCols)][nPosPer] / 100)
                                    Loop
                                  Endif   
                                  aCols[Len(aCols)][nX] := (aCols[Len(aCols)][nPosPer] / 100) * nPes123
                               Endif 
                            Else
                               aCols[Len(aCols)][nX] := (cTcq)->&(aHeader[nX][2])
                            Endif
                     Else
                        If aHeader[nX][8] $ 'D'
                           aCols[Len(aCols)][nX] := ctod(SubStr((cTcq)->&(aHeader[nX][2]), 7,2)+'/'+SubStr((cTcq)->&(aHeader[nX][2]), 5,2)+'/'+SubStr((cTcq)->&(aHeader[nX][2]), 1,4))
                        Else
                           aCols[Len(aCols)][nX] := (cTcq)->&(aHeader[nX][2])
                        Endif
                     Endif
                 Next
                 aCols[Len(aCols)][nUsado + 1] := .F.
                 // produto de custeio
                 If U_IsProdCusto(aCols[Len(aCols)][nPosCom])
                 Else
                     nSomPes += aCols[Len(aCols)][nPosPer] / aCols[Len(aCols)][nPosPEs]
                 Endif    
                 DbSelectArea(cTcq)
                 DbSkip()
           Enddo
           If !cTipo == 'PA'
              nPesEsp := Posicione("SZM", 1, xFilial("SZM")+cCodigo+cRevisao, "ZM_PESESP")
              If !cTipOpe == 1
                 nSomPes := 100 / nSomPes
                 If QtdComp(Round(nPesEsp, 5)) <> QtdComp(Round(nSomPes, 5))
                    nPesEsp := nSomPes
                    RecLock("SZM", .f.)
                       SZM->ZM_PESESP := nPesEsp
                    MsUnLock()
                 Endif
              Endif
              nCalPvc := Posicione("SZM", 1, xFilial("SZM")+cCodigo+cRevisao, "ZM_PVC")
              nCalBri := Posicione("SZM", 1, xFilial("SZM")+cCodigo+cRevisao, "ZM_BRILHO")
              For nX := 1 to Len(aCols)
                  // produto de custeio
                  If U_IsProdCusto(aCols[nX][nPosCom])
                     //aCols[nX][nPosQtd] := ( aCols[nX][nPosPer] / 100 ) 
                     //aCols[nX][nPosCRe] := 0
                     //aCols[nX][nPosCDo] := 0
                     Loop
                  Endif   
                  If Posicione("SB1", 1, xFilial("SB1")+aCols[nX][1], "B1_UM") $ cUM 
                     aCols[nX][nPosQtd] := ( aCols[nX][nPosPer] / 100 ) 
                  Else
                     aCols[nX][nPosQtd] := Iif(Alltrim(cKL) $ '99', (aCols[nX][nPosPer] / 100), (nPesEsp * ( aCols[nx][nPosPer] / 100 )))
                  Endif
                  aCols[nX][nPosCRe] := (aCols[nX][nPosQtd] / (1- ( aCols[nX][nPosPda] / 100 ) ) ) * aCols[nX][nPosCUn]
                  aCols[nX][nPosCDo] := (aCols[nX][nPosQtd] / (1- ( aCols[nX][nPosPda] / 100 ) ) ) / Posicione("SM2", 1, dDataBase, "M2_MOEDA2")
                  //aCols[nX][nPosCRe] := ( aCols[nX][nPosQtd] + ( aCols[nX][nPosQtd] * ( aCols[nX][nPosPda] / 100 ) ) ) * aCols[nX][nPosCUn]
                  //aCols[nX][nPosCDo] := ( aCols[nX][nPosQtd] + ( aCols[nX][nPosQtd] * ( aCols[nX][nPosPda] / 100 ) ) ) / Posicione("SM2", 1, dDataBase, "M2_MOEDA2")
              Next
           Endif
           DbSelectArea(cTcq)
           DbCloseArea()
        Else
           AADD(aCols, Array(nUsado + 1) )
           For nX := 1 To nUsado
               aCols[Len(aCols)][nX] := CriaVar(aHeader[nX][2])
           Next
           aCols[Len(aCols)][nUsado + 1] := .F.
        Endif
     Else
        DbSelectArea("SG1")
        DbSetOrder(1)
        DbSeek(xFilial("SG1")+cCodigo,.t.)
        If Found()
           cQry += "SELECT SG1.G1_COMP    AS ZN_COMP   , SB1.B1_DESC    AS ZN_DESC, "
           cQry += "       SG1.G1_TRT     AS ZN_TRT    , SG1.G1_PERC    AS ZN_PERC, "
           cQry += "       SG1.G1_QUANT   AS ZN_QUANT  , SG1.G1_PERDA   AS ZN_PERDA, "
           cQry += "       SB1.B1_PESOESP AS ZN_PESESP , 0              AS ZN_CUSTOUN, "
           cQry += "       0              AS ZN_CUSTORE, 0              AS ZN_CUSTODO, "
           cQry += "       SG1.G1_INI     AS ZN_INI    , SG1.G1_FIM     AS ZN_FIM, "
           cQry += "       SG1.G1_FIXVAR  AS ZN_FIXVAR , SG1.G1_REVINI  AS ZN_REVINI, "
           cQry += "       SG1.G1_REVFIM  AS ZN_REVFIM , SG1.G1_OPERACA AS ZN_OPERACA "
           cQry += "FROM "+RetSqlName("SG1")+" SG1 "
           cQry += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 ON SG1.G1_FILIAL = SB1.B1_FILIAL AND SG1.G1_COMP = SB1.B1_COD AND SB1.D_E_L_E_T_ = '' "
           cQry += "WHERE SG1.D_E_L_E_T_ = '' "
           cQry += "  AND SG1.G1_FILIAL  = '"+xFilial("SG1")+"' "
           cQry += "  AND SG1.G1_COD     = '"+cCodigo+"' "
           cQry += "ORDER BY SG1.G1_FILIAL, SG1.G1_COD, SG1.G1_TRT "
           TCQuery cQry ALIAS "TCQ" NEW
           DbSelectArea("TCQ")
           DbGoTop()
           While !Eof()
                 // produto de custeio
                 //If U_IsProdCusto(TCQ->ZN_COMP)
                 //    TCQ->(dbSkip())
                 //    Loop
                 //Endif   
                 aadd(aCols, Array(nUsado + 1))
                 For nX := 1 TO nUsado
                     If Alltrim(aHeader[nX][2]) $ 'ZN_CUSTOUN'
                        // produto de custeio
                        If U_IsProdCusto(aCols[Len(aCols)][nPosCom])
                           aCols[Len(aCols)][nX] := CriaVar("ZN_CUSTOUN")
                           Loop
                        Endif    
                        If Posicione("SB1", 1, xFilial("SB1")+aCols[Len(aCols)][1], "B1_TIPO") $ 'MP.MC'
                           aCols[Len(aCols)][nX] := Posicione("SB1", 1, xFilial("SB1")+aCols[Len(aCols)][1], "B1_UPRC")
                        Else
                           aCols[Len(aCols)][nX] := U_fCCusPro(aCols[Len(aCols)][1]) //fCusPro(aCols[Len(aCols)][1])
                        Endif
                     ElseIf Alltrim(aHeader[nX][2]) $ 'ZN_CUSTORE'
                         // produto de custeio
                         If U_IsProdCusto(aCols[Len(aCols)][nPosCom])
                           aCols[Len(aCols)][nX] := CriaVar("ZN_CUSTORE")
                           Loop
                         Endif   
                     	 //aCols[Len(aCols)][nX] := ( aCols[Len(aCols)][nPosQtd] + ( aCols[Len(aCols)][nPosQtd] * ( aCols[Len(aCols)][nPosPda] / 100 ) ) ) * aCols[Len(aCols)][nPosCUn]
                     	 aCols[Len(aCols)][nX] := (aCols[Len(aCols)][nPosQtd] / (1- ( aCols[Len(aCols)][nPosPda] / 100 ) ) ) * aCols[Len(aCols)][nPosCUn]
                     ElseIf Alltrim(aHeader[nX][2]) $ 'ZN_CUSTODO'
                         // produto de custeio
                         If U_IsProdCusto(aCols[Len(aCols)][nPosCom])
                           aCols[Len(aCols)][nX] := CriaVar("ZN_CUSTODO")
                           Loop
                         Endif   
                         //aCols[Len(aCols)][nX] := ( aCols[Len(aCols)][nPosQtd] + ( aCols[Len(aCols)][nPosQtd] * ( aCols[Len(aCols)][nPosPda] / 100 ) ) ) / Posicione("SM2", 1, dDataBase, "M2_MOEDA2")
                         aCols[Len(aCols)][nX] := (aCols[Len(aCols)][nPosQtd] / (1- ( aCols[Len(aCols)][nPosPda] / 100 ) ) ) / Posicione("SM2", 1, dDataBase, "M2_MOEDA2")
                     Else
                        If aHeader[nX][8] $ 'D'
                           aCols[Len(aCols)][nX] := ctod(SubStr(TCQ->&(aHeader[nX][2]), 7,2)+'/'+SubStr(TCQ->&(aHeader[nX][2]), 5,2)+'/'+SubStr(TCQ->&(aHeader[nX][2]), 1,4))
                        Else
                           aCols[Len(aCols)][nX] := TCQ->&(aHeader[nX][2])
                        Endif
                     Endif
                 Next
                 aCols[Len(aCols)][nUsado + 1] := .F.
                 DbSelectArea("TCQ")
                 DbSkip()
           Enddo
           DbSelectArea("TCQ")
           DbCloseArea()
        Else
           If Len(Alltrim(M->ZM_CODIGO)) == 12 .and. M->ZM_TIPO $ 'PA'
              aadd(aCols, Array(nUsado + 1))
              For nX := 1 TO nUsado
                  If Alltrim(aHeader[nX][2]) $ "ZN_COMP"
                     aCols[Len(aCols)][nX] := SubStr(M->ZM_CODIGO, 1, 10)+CKL
                  ElseIf Alltrim(aHeader[nX][2]) $ "ZN_DESC"
                         aCols[Len(aCols)][nX] := Posicione("SB1", 1, xFilial("SB1")+SubStr(M->ZM_CODIGO, 1, 10)+CKL, "B1_DESC")
                  ElseIf Alltrim(aHeader[nX][2]) $ "ZN_TRT"
                         aCols[Len(aCols)][nX] := "001"
                  ElseIf Alltrim(aHeader[nX][2]) $ "ZN_PERC"
                         aCols[Len(aCols)][nX] := Round(IIF(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(M->ZM_CODIGO, 11, 2), "Z5_UMEMB") $ 'K', Posicione("SZ5", 1, xFilial("SZ5")+SubStr(M->ZM_CODIGO, 11, 2), "Z5_VOLUME") / Posicione("SB1", 1, xFilial("SB1")+SubStr(M->ZM_CODIGO, 1, 10)+CKL, "B1_PESOESP"), Posicione("SZ5", 1, xFilial("SZ5")+SubStr(M->ZM_CODIGO, 11, 2), "Z5_VOLUME") ), 3)
                  ElseIf Alltrim(aHeader[nX][2]) $ "ZN_QUANT"
                         aCols[Len(aCols)][nX] := Round(IIF(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(M->ZM_CODIGO, 11, 2), "Z5_UMEMB") $ 'K', Posicione("SZ5", 1, xFilial("SZ5")+SubStr(M->ZM_CODIGO, 11, 2), "Z5_VOLUME") / Posicione("SB1", 1, xFilial("SB1")+SubStr(M->ZM_CODIGO, 1, 10)+CKL, "B1_PESOESP"), Posicione("SZ5", 1, xFilial("SZ5")+SubStr(M->ZM_CODIGO, 11, 2), "Z5_VOLUME") ), 3)
                  ElseIf Alltrim(aHeader[nX][2]) $ "ZN_PERDA"
                         aCols[Len(aCols)][nX] := 0.0
                  ElseIf Alltrim(aHeader[nX][2]) $ "ZN_PESESP"
                         aCols[Len(aCols)][nX] := Posicione("SB1", 1, xFilial("SB1")+SubStr(M->ZM_CODIGO, 1, 10)+CKL, "B1_PESOESP")
                  ElseIf Alltrim(aHeader[nX][2]) $ "ZN_CUSTOUN"
                         aCols[Len(aCols)][nX] :=  U_fCCusPro(aCols[Len(aCols)][1])//fCusPro(aCols[Len(aCols)][1])
                  ElseIf Alltrim(aHeader[nX][2]) $ "ZN_CUSTORE"
                         //aCols[Len(aCols)][nX] := ( aCols[Len(aCols)][nPosQtd] + ( aCols[Len(aCols)][nPosQtd] * ( aCols[Len(aCols)][nPosPda] / 100 ) ) ) * aCols[Len(aCols)][nPosCUn]
                         aCols[Len(aCols)][nX] := (aCols[Len(aCols)][nPosQtd] / (1- ( aCols[Len(aCols)][nPosPda] / 100 ) ) ) * aCols[Len(aCols)][nPosCUn]
                  ElseIf Alltrim(aHeader[nX][2]) $ "ZN_CUSTODO"
                         //aCols[Len(aCols)][nX] := ( aCols[Len(aCols)][nPosQtd] + ( aCols[Len(aCols)][nPosQtd] * ( aCols[Len(aCols)][nPosPda] / 100 ) ) ) / Posicione("SM2", 1, dDataBase, "M2_MOEDA2")
                         aCols[Len(aCols)][nX] := (aCols[Len(aCols)][nPosQtd] / (1- ( aCols[Len(aCols)][nPosPda] / 100 ) ) ) / Posicione("SM2", 1, dDataBase, "M2_MOEDA2")
                  ElseIf Alltrim(aHeader[nX][2]) $ "ZN_INI"
                         aCols[Len(aCols)][nX] := dDataBase
                  ElseIf Alltrim(aHeader[nX][2]) $ "ZN_FIM"
                         aCols[Len(aCols)][nX] := CTOD("31/12/2049")
                  ElseIf Alltrim(aHeader[nX][2]) $ "ZN_FIXVAR"
                         aCols[Len(aCols)][nX] := 'V'
                  ElseIf Alltrim(aHeader[nX][2]) $ "ZN_REVINI"
                         aCols[Len(aCols)][nX] := '   '
                  ElseIf Alltrim(aHeader[nX][2]) $ "ZN_REVFIM"
                         aCols[Len(aCols)][nX] := 'ZZZ'
                  ElseIf Alltrim(aHeader[nX][2]) $ "ZN_OPERACA"
                         aCols[Len(aCols)][nX] := '  '
                  Endif
              Next
              aCols[Len(aCols)][nUsado + 1] := .F.
           Endif
        Endif
     Endif
     aSort(aCols ,,,{|x,y| x[3] < y[3] })
Return

  /****************************************************************************/
  /*** MONTA A RODAPE DOS BROWSES                                           ***/
  /*** Parâmetros:                                                          ***/
  /****************************************************************************/
User Function fMonRod(cCodigo, cRevisao, cTipo, cUM, cTipoPro, aCols, aHeader, oPerNew, nPerNew, oPesNew, nPesNew, oCusRNe, nCusRNe, oCusDNe, nCusDNe, oPrcNew, nPrcNew, oVarPrc, nVarPrc, oBitmap, cBitMap, nCusRea, nPrcVig, oSayPrc, oCalPVC, nCalPVC, oCalBri, nCalBri,  lLiber, aMarcacao, nCusOuN, oCusOuN, nOpc, oCusAtu )
     Local lMesmaUM := .f.
     //Local nCusMed1 := 0
     //Local nCusMed2 := 0
     Local _nPos, nCntFor,cTcq,cQry1
     Local nPosCodi := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_COMP" } )
     //Local nPosPeso := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_PESESP"  } )
     Local nPosPerc := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_PERC"    } )
     //Local nPosQtde := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_QUANT"   } )
     Local nPosCRea := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_CUSTORE" } )
     Local nPosCDol := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_CUSTODO" } )
     Local nY, nX
     Local _lOpen        := .F. //LGS#20200210 - Adequação para release 12.1.25
     Local _cAliasSX3 := GetNextAlias() //LGS#20200210 - Adequação para release 12.1.25
     
     // ABERTURA DO DICIONÁRIO SX3 - LGS#20200210 - Adequação para release 12.1.25
     OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
     _lOpen := Select( _cAliasSX3 ) > 0

     If !_lOpen //LGS#20200210 - Adequação para release 12.1.25
        MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
        Return
     Endif
/*     
		cTcq := U_NovoCursor()   
      cQry1 := "dbo.CustoMpSZN('"+xFilial("SZN")+"','"+cCodigo+"',1.0,'"+cRevisao+"') AS CUSTO "
      TCQuery cQry1 NEW ALIAS (cTcq)
      DbSelectArea(cTcq)
      nCusRNe := (cTcq)->CUSTO
		dbselectarea(cTcq)
		dbCloseArea()
*/

     DbSelectArea("SZM")
     
     If Iif(cTipoPro $ "PE", Posicione("SB1", 1, xFilial("SB1")+cCodigo, "B1_TIPO"), Posicione("SZM", 1, xFilial("SZM")+cCodigo+cRevisao, "ZM_TIPO") ) $ "PA"
        nPerNew := 0
        nPesNew := 0
        For nCntFor := 1 To Len(aCols)
           If !aCols[nCntFor][Len(aHeader) + 1]
              // produto de custeio
              If U_IsProdCusto(aCols[nCntFor][nPosCodi])
                  Loop
              Endif    
              nCusRNe += aCols[nCntFor][nPosCRea]
              nCusDNe += aCols[nCntFor][nPosCDol]
           Endif
        Next
     Else
        If nOpc == 3
           aEspVig := U_fUlRvFrm(cCodigo)
           nPesNew := aEspVig[2]
           nCalPVC := aEspVig[3]
           nCalBri := aEspVig[4]
        Else
           /*If nOpc == 1
              nSomPes := 0
              For nCntFor := 1 To Len(aCols)
                  If Len(Alltrim(cCodigo)) == 12
                     nSomPes += aCols[nCntFor][nPosPerc] / aCols[nCntFor][nPosPeso]
                  Else
                  
                  Endif
              Next
           Endif*/
           nPesNew := Posicione("SZM", 1, xFilial("SZM")+cCodigo+cRevisao, "ZM_PESESP")
           nCalPVC := Posicione("SZM", 1, xFilial("SZM")+cCodigo+cRevisao, "ZM_PVC")
           nCalBri := Posicione("SZM", 1, xFilial("SZM")+cCodigo+cRevisao, "ZM_BRILHO")
        Endif
        For nCntFor := 1 To Len(aCols)
            If U_IsProdCusto(aCols[nCntFor][nPosCodi])
               Loop
            Endif   
            If !aCols[nCntFor][Len(aHeader) + 1]
               If Posicione("SB1", 1, xFilial("SB1")+aCols[nCntFor][nPosCodi], "B1_UM") == cUM
                  nPerNew += aCols[nCntFor][nPosPerc]
                  lMesmaUM := .t.
               Else
                  nPerNew += aCols[nCntFor][nPosPerc]
               Endif
            Endif
            nCusRNe += aCols[nCntFor][nPosCRea]
            nCusDNe += aCols[nCntFor][nPosCDol]
        Next
     Endif
     If cTipo $ 'PI' .and. Alltrim(cUm) $ 'L'
        nCusOuN := nCusRNe / nPesNew
        oCusOuN:Refresh()
        oCusAtu:lVisibleControl := .t.
        oCusOuN:lVisibleControl := .t.
	 Endif

     oPerNew:Refresh() ; oPesNew:Refresh() ; oCusRNe:Refresh() ; oCusDNe:Refresh() ; oCalPVC:Refresh() ; oCalBri:Refresh()

     If lLiber
        /********************************************************************************************************************************/
        /*** BLOCO ALTERADO EM 10/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
        /*DbSelectArea("SX3")
        DbSetOrder(2)
        For nX := 1 To Len(aHeader)
            MsSeek( Trim(aHeader[nX][2]) )
            For nY := 1 To Len(aCols)
                aCols[nY][nX] := TransForm(aCols[nY][nX], SX3->X3_PICTURE)
            Next nY
        Next nX*/
        DbSelectArea( _cAliasSX3 )
        DbSetOrder(2)
        For nX := 1 To Len(aHeader)
            MsSeek( Trim(aHeader[nX][2]) )
            For nY := 1 To Len(aCols)
                aCols[nY][nX] := TransForm(aCols[nY][nX], ( _cAliasSX3 )->( X3_PICTURE ) )
            Next nY
        Next nX
        _nPos := Iif( aGeral[GEL_POS] == 0, 1, aGeral[GEL_POS])
        nPrcNew := U_fBusPrc(aMarcacao[_nPos][1][2], 'NEW', aMarcacao[_nPos][1][4], "2", aHeader, aCols, "LIB")
        oPrcNew:Refresh()
        If aMarcacao[_nPos][1][9] $ 'PI'
           If !Valtype(oSayPrc) $ 'U'
              oSayPrc:lVisibleControl := .f.
           Endif
           If !Valtype(oCusAtu) $ 'U'
              oCusAtu:lVisibleControl := .t.
           Endif
           If !Valtype(oCusVig) $ 'U'
              oCusVig:lVisibleControl := .t.
           Endif
           If !Valtype(oPrcNew) $ 'U'
              oPrcNew:lVisibleControl := .f.
           Endif
           If QtdComp(nCusRNe) <> QtdComp(nCusRea)
              nDifer := QtdComp(nCusRNe) - QtdComp(nCusRea)
              If ABS(nDifer) < 0.003
                 If nDifer < 0
                    nCusRNe += (nDifer * -1)
                 Else
                    nCusRNe -= nDifer
                 Endif
                 oCusRNe:Refresh()
              Endif
           Endif
           nVarPrc := Round( ( ( ( nCusRNe / Iif(nCusRea == 0, nCusRNe, nCusRea) ) - 1 ) * 100 ), 3)
           cBitMap := Iif( nVarPrc == 0, 'QMT_COND', Iif( nVarPrc < 0, 'QMT_OK', 'QMT_NO' ) )
           oBitMap:cResName := cBitMap
           oBitMap:Refresh()
        Else
           If !Valtype(oCusAtu) $ 'U'
              oCusAtu:lVisibleControl := .f.
           Endif
           If !Valtype(oCusVig) $ 'U'
              oCusVig:lVisibleControl := .f.
           Endif
           If !Valtype(oSayPrc) $ 'U'
              oSayPrc:lVisibleControl := .t.
           Endif
           If !Valtype(oPrcNew) $ 'U'
              oPrcNew:lVisibleControl := .t.
           Endif
           If QtdComp(nPrcNew) <> QtdComp(nPrcVig)
              nDifer := QtdComp(nPrcNew) - QtdComp(nPrcVig)
              If ABS(nDifer) < 0.003
                 If nDifer < 0
                    nPrcNew += (nDifer * -1)
                 Else
                    nPrcNew -= nDifer
                 Endif
                 oPrcNew:Refresh()
              Endif
           Endif
           nVarPrc := Round( ( ( ( nPrcNew / Iif(nPrcVig == 0, nPrcNew, nPrcVig) ) - 1 ) * 100 ), 3)
           cBitMap := Iif( nVarPrc == 0, 'QMT_COND', Iif( nVarPrc < 0, 'QMT_OK', 'QMT_NO' ) )
           oBitMap:cResName := cBitMap
           oBitMap:Refresh()
        Endif
     Else
        If cTipo $ 'PI'
           oSayPrc:lVisibleControl := .f.
           oPrcNew:lVisibleControl := .f.
           If QtdComp(nCusRNe) <> QtdComp(nCusRea)
              nDifer := QtdComp(nCusRNe) - QtdComp(nCusRea)
              If ABS(nDifer) < 0.003
                 If nDifer < 0
                    nCusRNe += (nDifer * -1)
                 Else
                    nCusRNe -= nDifer
                 Endif
                 oCusRNe:Refresh()
              Endif
           Endif
           nVarPrc := Round( ( ( ( nCusRNe / Iif(nCusRea == 0, nCusRNe, nCusRea) ) - 1 ) * 100 ), 3)
           cBitMap := Iif( nVarPrc == 0, 'QMT_COND', Iif( nVarPrc < 0, 'QMT_OK', 'QMT_NO' ) )
           oBitMap:cResName := cBitMap
           oBitMap:Refresh()
        Else
           If QtdComp(nPrcNew) <> QtdComp(nPrcVig)
              nDifer := QtdComp(nPrcNew) - QtdComp(nPrcVig)
              If ABS(nDifer) < 0.003
                 If nDifer < 0
                    nPrcNew += (nDifer * -1)
                 Else
                    nPrcNew -= nDifer
                 Endif
                 oPrcNew:Refresh()
              Endif
           Endif
           nVarPrc := Round( ( ( ( nPrcNew / Iif(nPrcVig == 0, nPrcNew, nPrcVig) ) - 1 ) * 100 ), 3)
           cBitMap := Iif( nVarPrc == 0, 'QMT_COND', Iif( nVarPrc < 0, 'QMT_OK', 'QMT_NO' ) )
           oBitMap:cResName := cBitMap
           oBitMap:Refresh()
        Endif
     Endif
     DbSelectArea( _cAliasSX3 )
     DbCloseArea()
Return

  /****************************************************************************/
  /*** VALIDA A ALTERAÇÃO DE CAMPOS NA GETDADOS.                            ***/
  /*** Parâmetros:                                                          ***/
  /****************************************************************************/
User Function fVCamGd(oGetD, aCols, aHeader, cCodigo, cRevisao, cTipo, cUM, cTipoPro, oPerNew, nPerNew, oPesNew, nPesNew, oCusRNe, nCusRNe, oCusDNe, nCusDNe, oPrcNew, nPrcNew, oVarPrc, nVarPrc, nCusRea, oBitMap, nPrcVig, nOpc, oCalPVC, nCalPVC, oCalBri, nCalBri, oCusOuN, nCusOuN)
     Local nPosCom := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_COMP" } )
     Local nPosPer := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_PERC"    } )
     Local nPosQtd := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_QUANT"   } )
     Local nPosPda := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_PERDA"   } )
     Local nPosCUn := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_CUSTOUN" } )
     //Local nPosCRe := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_CUSTORE" } )
     //Local nPosCDo := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_CUSTODO" } )
     Local nPosPEs := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_PESESP"  } )
     Local nPosSeq := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_TRT"     } )
     Local nPosDes := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_DESC"    } )
     Local nPosOpe := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_OPERACA" } )
	 Local cKL     := IIf(Alltrim(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(cCodigo, 11, 02), "Z5_UMEMB"))='K','99','00')
     Local nX
     If __ReadVar $ "M->ZN_COMP"
        If Empty(aCols[n][nPosCom]) .OR. (Alltrim(M->ZN_COMP) <> Alltrim(aCols[n][nPosCom])) // pegar o preço correto do pi mesmo na alteração 22/05/15
           aCols[n][nPosCom] := M->ZN_COMP
           DbSelectArea("SB1")
           DbSetOrder(1)
           DbSeek(xFilial("SB1")+M->ZN_COMP,.t.)
           If Found()
              If cTipo $ 'PA'
                 aCols[n][nPosPda] := 0
              Endif
              aCols[n][nPosDes] := SB1->B1_DESC
              aCols[n][nPosPEs] := SB1->B1_PESOESP
              // produto de custeio
              If U_IsProdCusto(M->ZN_COMP)
              Else
                  aCols[n][nPosCUn] := Iif( Posicione("SB1", 1, xFilial("SB1")+M->ZN_COMP, "B1_TIPO") $ 'MP.MC', SB1->B1_UPRC, U_CUSTOPRO(M->ZN_COMP) )
              Endif                  
           Else
              If M->ZM_TIPOPRO $ "PN"
                 If M->ZM_TIPO $ 'PA'
                    aCols[n,nPosPda] := 0
                    aCols[n,nPosDes] := M->ZM_DESCRIC
                    aCols[n,nPosPEs] := Posicione("SZM", 3, xFilial("SZM")+SubStr(M->ZM_CODIGO,1,10)+cKL, "ZM_PESESP")
                    aCols[n,nPosCUn] := (U_CUSTOPRO(aCols[n][nPosCom]) )
                 Else
                    aCols[n,nPosCom] := ""
                 Endif
              Endif
           Endif
           nNumSeq := 1
           For nX := 1 to Len(aCols)
               If aCols[nX,Len(aHeader) + 1] == .t.
                  Loop
               Endif
               aCols[nX][nPosSeq] := StrZero(nNumSeq,3)
               nNumSeq += 1
           Next
        Else
           DbSelectArea("SB1")
           DbSetOrder(1)
           DbSeek(xFilial("SB1")+M->ZN_COMP,.t.)
           If Found()
              aCols[n][nPosDes] := SB1->B1_DESC
              aCols[n][nPosPEs] := SB1->B1_PESOESP
              // produto de custeio
              If U_IsProdCusto(M->ZN_COMP)
              Else
                  aCols[n][nPosCUn] := Iif( Posicione("SB1", 1, xFilial("SB1")+M->ZN_COMP, "B1_TIPO") $ 'MP.MC', SB1->B1_UPRC, U_FCCUSPRO(M->ZN_COMP,CREVISAO)) //U_CUSTOPRO(M->ZN_COMP) )//U_FCCUSPRO(M->ZN_COMP)) //U_CUSTOPRO(M->ZN_COMP) )
              Endif   
              If M->ZM_TIPO $ 'PA'
                 If Len(Alltrim(M->ZN_COMP)) == 12
                    _nPesEsp := Iif(Posicione("SB1", 1, xFilial("SB1")+SubStr(M->ZM_CODIGO, 1, 10)+cKL, "B1_PESOESP") == 0.0, Posicione("SZM", 3, xFilial("SZM")+SubStr(M->ZM_CODIGO, 1, 10)+cKL, "ZM_PESESP"), Posicione("SB1", 1, xFilial("SB1")+SubStr(M->ZM_CODIGO, 1, 10)+cKL, "B1_PESOESP"))
                    aCols[n][nPosPer] := Round(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(M->ZM_CODIGO, 11, 2), "Z5_VOLUME"), 5)
                    aCols[n][nPosQtd] := Round(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(M->ZM_CODIGO, 11, 2), "Z5_VOLUME"), 5)

                    //aCols[n][nPosPer] := Round(Iif(!Posicione("SZ5", 1, xFilial("SZ5")+SubStr(M->ZM_CODIGO, 11, 2), "Z5_UMEMB") $ 'K', Posicione("SZ5", 1, xFilial("SZ5")+SubStr(M->ZM_CODIGO, 11, 2), "Z5_VOLUME"), Posicione("SZ5", 1, xFilial("SZ5")+SubStr(M->ZM_CODIGO, 11, 2), "Z5_VOLUME") / _nPesEsp), 3)
                    //aCols[n][nPosQtd] := Round(Iif(!Posicione("SZ5", 1, xFilial("SZ5")+SubStr(M->ZM_CODIGO, 11, 2), "Z5_UMEMB") $ 'K', Posicione("SZ5", 1, xFilial("SZ5")+SubStr(M->ZM_CODIGO, 11, 2), "Z5_VOLUME"), Posicione("SZ5", 1, xFilial("SZ5")+SubStr(M->ZM_CODIGO, 11, 2), "Z5_VOLUME") / _nPesEsp), 3)
                 Endif
              Endif
           Endif
           U_fCalCUN(cCodigo, cRevisao, cTipo, cUM, cTipoPro, oDlg, .f., @oPerNew, @nPerNew, @oPesNew, @nPesNew, @oCusRNe, @nCusRNe, @oCusDNe, @nCusDNe, @oPrcNew, @nPrcNew, @oVarPrc, @nVarPrc, nCusRea, @oBitMap, nPrcVig, nOpc, @oCalPVC, @nCalPVC, @oCalBri, @nCalBri)
        Endif
     ElseIf __ReadVar $ "M->ZN_TRT"
            aCols[n][nPosSeq] := StrZero(Val(M->ZN_TRT),3)
            nSeqAtu           := Val(M->ZN_TRT)
            For nX := n to Len(aCols)
                If aCols[nX][Len(aHeader) + 1] == .t.
                   Loop
                Endif
                If nX > n
                   nSeqAtu += 1
                   aCols[nX][nPosSeq] := StrZero(nSeqAtu,3)
                Endif
            Next
     ElseIf __ReadVar $ "M->ZN_PERC"
            If M->ZN_PERC <> aCols[n][nPosPer]
               If !aCols[n][Len(aHeader) + 1] == .t.
                  U_fCalCUN(cCodigo, cRevisao, cTipo, cUM, cTipoPro, oDlg, .t., @oPerNew, @nPerNew, @oPesNew, @nPesNew, @oCusRNe, @nCusRNe, @oCusDNe, @nCusDNe, @oPrcNew, @nPrcNew, @oVarPrc, @nVarPrc, nCusRea, @oBitMap, nPrcVig, nOpc, @oCalPVC, @nCalPVC, @oCalBri, @nCalBri)
               Endif
            Endif
     ElseIf __ReadVar $ "M->ZN_PERDA"
            aCols[n][nPosPda] := M->ZN_PERDA
            U_fCalCUN(cCodigo, cRevisao, cTipo, cUM, cTipoPro, oDlg, .f., @oPerNew, @nPerNew, @oPesNew, @nPesNew, @oCusRNe, @nCusRNe, @oCusDNe, @nCusDNe, @oPrcNew, @nPrcNew, @oVarPrc, @nVarPrc, nCusRea, @oBitMap, nPrcVig, nOpc, @oCalPVC, @nCalPVC, @oCalBri, @nCalBri)
     ElseIf __ReadVar $ "M->ZN_OPERACA"
            If Empty(aCols[n][nPosOpe])
               DbSelectArea("SG2")
               DbSetOrder(3)
               DbSeek(xFilial("SG2")+M->ZM_CODIGO+M->ZN_OPERACA,.t.)
               If found()
                  aCols[n][nPosOpe] := M->ZN_OPERACA
                  M->ZM_ROTEIRO     := SG2->G2_CODIGO
                  //aTela[Val(SubStr(aGets[aScan(aGets, {|x| SubStr(x, 9, 10) == 'ZM_ROTEIRO'} )],1,2))][Val(SubStr(aGets[aScan(aGets, {|x| SubStr(x, 9, 10) == 'ZM_ROTEIRO'} )],3,1))*2]
               Else
                  MsgBox("Operação não encontrada para esse produto","Atençãp","STOP")
                  aCols[n][nPosOpe] := space(02)
                  M->ZN_OPERACA     := space(02)
               Endif
            Else
               DbSelectArea("SG2")
               DbSetOrder(3)
               DbSeek(xFilial("SG2")+M->ZM_CODIGO+M->ZN_OPERACA,.t.)
               If Found()
                  aCols[n][nPosOpe] := M->ZN_OPERACA
                  M->ZM_ROTEIRO     := SG2->G2_CODIGO
                  //aTela[ Val(SubStr(aGets[aScan(aGets, {|x| SubStr(x, 9, 10) == 'ZM_ROTEIRO'} )],1,2)) ][ Val( SubStr( aGets[ aScan( aGets, { |x| SubStr(x, 9, 10) == 'ZM_ROTEIRO'} ) ], 3, 1 ) ) * 2 ] 
               Else
                  MsgBox("Operação não encontrada para esse produto","Atençãp","STOP")
                  M->ZN_OPERACA := aCols[n][nPosOpe]
               Endif
            Endif
     Endif
     aSort(aCols ,,,{|x,y| x[3] < y[3] })
     If cTipo $ 'PI' .and. Alltrim(cUm) $ 'L'
        nCusOuN := (nCusRNe / nPesNew)
        oCusOuN:Refresh()
     Endif
     oGetD:oBrowse:Refresh()
     oPerNew:Refresh() ; oPesNew:Refresh()
     oCusRNe:Refresh() ; oCusDNe:Refresh()
     oPrcNew:Refresh() ; oBitMap:Refresh()
     oVarPrc:Refresh() ; oCalPVC:Refresh()
     oCalBri:Refresh() ; oDlg:Refresh()
Return(.t.)

  /****************************************************************************/
  /*** VALIDA A ALTERAÇÃO DA LINHA NA GETDADOS.                             ***/
  /*** Parâmetros:                                                          ***/
  /****************************************************************************/
User Function fVLinGD(oGetD, aCols, aHeader, cCodigo, cRevisao, cTipo, cUM, cTipoPro, oPerNew, nPerNew, oPesNew, nPesNew, oCusRNe, nCusRNe, oCusDNe, nCusDNe, oPrcNew, nPrcNew, oVarPrc, nVarPrc, nCusRea, oBitMap, nPrcVig, nOpc, oCalPVC, nCalPVC, oCalBri, nCalBri, oCusOuN, nCusOuN)
     //Local nPosCom := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_COMP"    } )
     //Local nPosPer := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_PERC"    } )
     //Local nPosQtd := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_QUANT"   } )
     //Local nPosPda := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_PERDA"   } )
     //Local nPosCUn := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_CUSTOUN" } )
     //Local nPosCRe := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_CUSTORE" } )
     //Local nPosCDo := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_CUSTODO" } )
     //Local nPosPEs := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_PESESP"  } )
     //Local nPosSeq := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_TRT"     } )
     //Local nPosDes := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_DESC"    } )
     
     U_fCalCUN(cCodigo, cRevisao, cTipo, cUM, cTipoPro, oDlg, .f., @oPerNew, @nPerNew, @oPesNew, @nPesNew, @oCusRNe, @nCusRNe, @oCusDNe, @nCusDNe, @oPrcNew, @nPrcNew, @oVarPrc, @nVarPrc, nCusRea, @oBitMap, nPrcVig, nOpc, @oCalPVC, @nCalPVC, @oCalBri, @nCalBri)
     oGetD:oBrowse:Refresh()
     oPerNew:Refresh() ; oPesNew:Refresh()
     oCusRNe:Refresh() ; oCusDNe:Refresh()
     oPrcNew:Refresh() ; oBitMap:Refresh()
     oVarPrc:Refresh() ; oCalPVC:Refresh()
     oCalBri:Refresh()
Return(.t.)

  /****************************************************************************/
  /*** VALIDA A ALTERAÇÃO DE CAMPOS E LINHAS NA GETDADOS.                   ***/
  /*** Parâmetros:                                                          ***/
  /****************************************************************************/
User Function fVTudGD(oGetD, aCols, aHeader, cCodigo, cRevisao, cTipo, cUM, cTipoPro)
     Local nPosCom := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_COMP" } )
     Local nPosPer := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_PERC"    } )
     //Local nPosQtd := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_QUANT"   } )
     //Local nPosPda := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_PERDA"   } )
     //Local nPosCUn := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_CUSTOUN" } )
     //Local nPosCRe := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_CUSTORE" } )
     //Local nPosCDo := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_CUSTODO" } )
     //Local nPosPEs := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_PESESP"  } )
     Local nPosSeq := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_TRT"     } )
     //Local nPosDes := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_DESC"    } )
     Local nPosOpe := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_OPERACA" } )
     Local nSomPer := 0
     Local aAux    := {}
     Local lJaETRT := .f.
     Local lSemOpe := .f.
     Local nX
     For nX := 1 to Len(aCols)
         If aCols[nX][Len(aHeader) + 1] == .t.
            Loop
         Endif
         // produto de custeio
         If U_IsProdCusto(aCols[nX][nPosCom])
         Else
            nSomPer += aCols[nX][nPosPer]
         Endif   
         nPos := aScan(aAux, {|x| x[1] == aCols[nX][nPosSeq]} )
         If nPos == 0
            aadd(aAux, { aCols[nX][nPosSeq] } )
         Else
            lJaETRT := .t.
         Endif
         If Empty(aCols[nX][nPosOpe])
            lSemOpe := .t.
         Endif
     Next
     If lJaETRT
        MsgBox("Atenção existem seqüências iguais na fórmula !!!","Atenção","STOP")
        Return(.f.)
     Endif
     If cTipo $ "PA"
        Return(.t.)
     Endif
     If nSomPer > 100
        MsgBox("Atenção o percentual da fórmula está > 100 % !!!","Atenção","STOP")
        Return(.f.)
     ElseIf nSomPer < 100
            MsgBox("Atenção o percentual da fórmula está < 100 % !!!","Atenção","STOP")
            Return(.f.)
     Endif
     If lSemOpe
        If MsgYesNo("Os itens não tem operações cadastradas !!! Cadastra ?","Pergunta...")
           Return(.f.)
        Endif
     Endif
Return(.t.)

  /****************************************************************************/
  /*** CALCULA O CUSTO DO PRODUTO.                                          ***/
  /*** Parâmetros:                                                          ***/
  /****************************************************************************/
User Function fCalCUN(cCodigo, cRevisao, cTipo, cUM, cTipoPro, oDlg, lPerc, oPerNew, nPerNew, oPesNew, nPesNew, oCusRNe, nCusRNe, oCusDNe, nCusDNe, oPrcNew, nPrcNew, oVarPrc, nVarPrc, nCusRea, oBitMap, nPrcVig, nOpc, oCalPVC, nCalPVC, oCalBri, nCalBri)
     Local nPosCom := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_COMP" } )
     Local nPosPer := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_PERC"    } )
     Local nPosQtd := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_QUANT"   } )
     Local nPosPda := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_PERDA"   } )
     Local nPosCUn := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_CUSTOUN" } )
     Local nPosCRe := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_CUSTORE" } )
     Local nPosCDo := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_CUSTODO" } )
     Local nPosPEs := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_PESESP"  } )
     //Local nPosSeq := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_TRT"     } )
     //Local nPosDes := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_DESC"    } )
     //Local nPosOpe := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_OPERACA" } )
     //Local nCusDol := 0
     Local nValDol := Posicione("SM2", 1, ddataBase, "M2_MOEDA2")
     Local nX,cQry1,cTcq

      // produto de custeio
      //If U_IsProdCusto(aCols[n][nPosCom])
      //   Return()
      //Endif   
     If lPerc
        If cTipo $ "PA" .and. Len(Alltrim(cCodigo)) != 5
           aCols[n][nPosPer] := M->ZN_PERC
           aCols[n][nPosQtd] := M->ZN_PERC
        Else
           If Posicione("SB1", 1, xFilial("SB1")+aCols[n][nPosCom], "B1_UM") == cUM
              aCols[n][nPosPer] :=  M->ZN_PERC
              aCols[n][nPosQtd] := (M->ZN_PERC / 100)
              nPesNew := 0
              For nX := 1 to Len(aCols)
                  If aCols[nX][Len(aHeader) + 1] == .t.
                     Loop
                  Endif
                  // produto de custeio
                  If U_IsProdCusto(aCols[nX][nPosCom])
                     Loop
                  Endif   
                  nPesNew += aCols[nX][nPosPer] / aCols[nX][nPosPEs]
              Next
              nPesNew := (100 / nPesNew)
           Else
              aCols[n][nPosPer] := M->ZN_PERC
              nPesNew := 0
              For nX := 1 to Len(aCols)
                  If aCols[nX][Len(aHeader) + 1] == .t.
                     Loop
                  Endif
                  // produto de custeio
                  If U_IsProdCusto(aCols[nX][nPosCom])
                     Loop
                  Endif   
                  nPesNew += aCols[nX][nPosPer] / aCols[nX][nPosPEs]
              Next
              nPesNew := (100 / nPesNew)
              // produto de custeio
              If U_IsProdCusto(aCols[n][nPosCom])
                  aCols[n][nPosQtd] := (M->ZN_PERC / 100)
              Else
                  aCols[n][nPosQtd] := ( nPesNew * (M->ZN_PERC / 100) )
              Endif    
           Endif
        Endif
     Else
        nPesNew := 0
        For nX := 1 to Len(aCols)
            If aCols[nX][Len(aHeader) + 1] == .t.
               Loop
            Endif
            // produto de custeio
            If U_IsProdCusto(aCols[nX][nPosCom])
               Loop
            Endif   
            nPesNew += aCols[nX][nPosPer] / aCols[nX][nPosPEs]
        Next
        nPesNew := (100 / nPesNew)
     Endif
     U_fCalEsp(cCodigo, cRevisao, nPesNew, @nCalPVC, @nCalBri)
     nCusRNe := 0 ; nCusDNe := 0 ; nPerNew := 0
/*
		cTcq := U_NovoCursor()   
      cQry1 := "dbo.CustoMpSZN('"+xFilial("SZN")+"','"+cCodigo+"',1.0,'"+cRevisao+"') AS CUSTO "
      TCQuery cQry1 NEW ALIAS (cTcq)
      DbSelectArea(cTcq)
      nCusRNe := (cTcq)->CUSTO
		dbselectarea(cTcq)
		dbCloseArea()
*/

     For nX := 1 to Len(aCols)
         If aCols[nX][Len(aHeader) + 1] == .t.
            Loop
         Endif
         // produto de custeio
         If U_IsProdCusto(aCols[nX][nPosCom])
            Loop
         Endif  
         If Alltrim(Posicione("SB1", 1, xFilial("SB1")+aCols[n,nPosCom], "B1_UM")) == Alltrim(cUM)
            If !cTipo $ 'PA' 
               aCols[nX][nPosQtd] := Iif(Alltrim(cUM) == 'L',(nPesNew * (aCols[nX][nPosPer] / 100) ),(aCols[nX][nPosPer] / 100))//( (aCols[nX][nPosPer] / 100) )
            Else
               aCols[nX][nPosQtd] := aCols[nX][nPosPer]
            Endif
         Else
            If !cTipo $ 'PA' 
               aCols[nX][nPosQtd] := Iif(Alltrim(cUM) == 'L',(nPesNew * (aCols[nX][nPosPer] / 100) ),(aCols[nX][nPosPer] / 100))
            Else
               aCols[nX][nPosQtd] := aCols[nX][nPosPer]
            Endif
         Endif
         //aCols[nX][nPosCRe] := (( aCols[nX][nPosQtd] + (aCols[nX][nPosQtd] * (aCols[nX][nPosPda] / 100)) ) * aCols[nX][nPosCUn] )
         //aCols[nX][nPosCDo] := (( aCols[nX][nPosQtd] + (aCols[nX][nPosQtd] * (aCols[nX][nPosPda] / 100)) ) / nValDol )

         aCols[nX][nPosCRe] := ((aCols[nX][nPosQtd] / (1-(aCols[nX][nPosPda] / 100)) ) * aCols[nX][nPosCUn] )
         aCols[nX][nPosCDo] := ((aCols[nX][nPosQtd] / (1-(aCols[nX][nPosPda] / 100)) ) / nValDol )

         nCusRNe += aCols[nX][nPosCRe]
         nCusDNe += aCols[nX][nPosCDo]
         nPerNew += aCols[nX][nPosPer]
     Next
     If cTipo $ "PA"
        If cUM <> "K "
           nPerNew := 0
           nPesNew := 0
        Endif
     Endif
     If cTipo $ 'PA'
        nPrcNew := U_fBusPrc(cCodigo, "NEW", cRevisao, "1", aHeader, aCols, "GEL")
        If QtdComp(nPrcNew) <> QtdComp(nPrcVig)
           nDifer := QtdComp(nPrcNew) - QtdComp(nPrcVig)
           If ABS(nDifer) < 0.003
              If nDifer < 0
                 nPrcNew += (nDifer * -1)
              Else
                 nPrcNew -= nDifer
              Endif
           Endif
        Endif
        nVarPrc := Round( ( ( ( nPrcNew / Iif(nPrcVig == 0, nPrcNew, nPrcVig) ) - 1 ) * 100 ), 3)
        cBitMap := Iif( nVarPrc == 0, 'QMT_COND', Iif( nVarPrc < 0, 'QMT_OK', 'QMT_NO' ) )
        oBitMap:cResName := cBitMap
     Else
        If QtdComp(nCusRNe) <> QtdComp(nCusRea)
           nDifer := QtdComp(nCusRNe) - QtdComp(nCusRea)
           If ABS(nDifer) < 0.005
              If nDifer < 0
                 nCusRNe += (nDifer * -1)
              Else
                 nCusRNe -= nDifer
              Endif
           Endif
        Endif
        nVarPrc := Round( ( ( ( nCusRNe / Iif(nCusRea == 0, nCusRNe, nCusRea) ) - 1 ) * 100 ), 3)
        cBitMap := Iif( nVarPrc == 0, 'QMT_COND', Iif( nVarPrc < 0, 'QMT_OK', 'QMT_NO' ) )
        oBitMap:cResName := cBitMap
     Endif
Return

  /****************************************************************************/
  /*** VERIFICAÇÃO DA INCLUSÃO DE EMBALAGENS NA TELA SIMULAÇÃO / MANUTENÇÃO ***/
  /*** Parâmetros: ExpO1 - Objeto da tela para ser atualizado.              ***/
  /****************************************************************************/
User Function fTudInc()
     Local lRet := .t.
     Local nX
     For nX := 1 to Len(aCols)
         If aCols[nX][Len(aHeader) + 1] == .t.
            Loop
         Endif
         If Empty(aCols[nX][1])
            lRet := .f.
         Endif
     Next
     If !lRet
        MSGBOX("Existem registros em branco, favor deletar antes de confirmar !!!","Atenção","STOP")
        Return(lRet)
     Endif
Return(lRet)

  /****************************************************************************/
  /*** TELA PARA SELEÇÃO DO PRODUTO NOVO - TINTAS OU PASTAS / SOLUÇÕES      ***/
  /*** Parâmetros:                                                          ***/
  /****************************************************************************/
User Function PCPX01_2()
     Local nRadio := 1

     If (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) != 0) .and. !lAcs1 .and. !lAcs3
        MsgBox("Usuário não autorizado a incluir simulação","Atenção","STOP")
        Return
     Endif
     If !(cNumEmp == '01010104')
        DEFINE MSDIALOG oDlg3 TITLE OemToAnsi("Simulação de Formulas - PN") FROM 000,000 TO 012,050 OF oMainWnd
               @ 045,015 GROUP oGrp1 TO 080,180 LABEL  OemToAnsi('')                                                    PIXEL OF oDlg3
               @ 050,020 RADIO oRadio VAR nRadio ITEMS OemToAnsi("Tintas"), OemToAnsi("Pastas / Soluções"), OemToAnsi("Concentrado") SIZE 060,015 PIXEL OF oDlg3
               oDlg3:nStyle       := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
        ACTIVATE MSDIALOG oDlg3 ON INIT EnchoiceBar(oDlg3, {|| oDlg3:End(), Iif(nRadio == 1, U_fProTin(), Iif(nRadio == 2, U_fProPas(1), U_fProPas(2)) ) }, {|| oDlg3:End() } ) CENTERED
     Else
        DEFINE MSDIALOG oDlg3 TITLE OemToAnsi("Simulação de Formulas - PN") FROM 000,000 TO 012,050 OF oMainWnd
               @ 040,015 GROUP oGrp1 TO 080,180 LABEL  OemToAnsi('')                                                    PIXEL OF oDlg3
               @ 050,020 RADIO oRadio VAR nRadio ITEMS OemToAnsi("Tintas"), OemToAnsi("Pastas / Soluções"), OemToAnsi("Concentrado"), OemToAnsi("Resinas")           SIZE 060,015 PIXEL OF oDlg3
               oDlg3:nStyle       := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
        ACTIVATE MSDIALOG oDlg3 ON INIT EnchoiceBar(oDlg3, {|| oDlg3:End(), Iif(nRadio == 1, U_fProTin(), Iif(nRadio == 2, U_fProPas(1), Iif(nRadio == 3, U_fProPas(2), U_fProPas(3)))) }, {|| oDlg3:End() } ) CENTERED
     Endif
Return

  /****************************************************************************/
  /*** TELA PARA INCLUSÃO DO PRODUTO NOVO - TINTAS                          ***/
  /*** Parâmetros:                                                          ***/
  /****************************************************************************/
User Function fProTin()
     Local cBase   := ""
     Local cCaract := space(02) ; Local cLinha  := space(02) ; Local cCor := space(02)
     Local cVariac := space(03) ; Local cEmbal  := space(02) ; Local cSeq := space(02)
     Local cCodigo := space(15) ; Local cDescri := space(30)
     Local cTipo   := space(02) ; Local cLocal  := space(02) ; Local cUM  := space(02)
     Local cDesEmb := space(20)
     Local _aRetInf := FWGetSX5( "ZT" )
     Local _nX
     /********************************************************************************************************************************/
     /*** BLOCO ALTERADO EM 07/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
     /*
     DbSelectArea("SX5")
     DbSetOrder(1)
     DbSeek(xFilial("SX5")+"ZT",.t.)
     If Found()
        While !Eof() .and. SX5->X5_TABELA == "ZT"
              If Upper(Alltrim(cUsername)) == Alltrim(SX5->X5_DESCRI)
                 cBase := SX5->X5_CHAVE
              Endif
              DbSelectArea("SX5")
              DbSkip()
        Enddo
     Endif*/
     For _nX := 1 To Len( _aRetInf )
         If Upper( Alltrim( cUsername ) ) == Upper( Alltrim( _aRetInf[_nX][4] ) )
            cBase := _aRetInf[_nX][3]
         Endif
     Next
     DEFINE MSDIALOG oDlg TITLE OemToAnsi("Desenvolvimento de um novo produto - Tintas") FROM 000,000 TO 015,075 OF oMainWnd
            @ 039,005 GROUP oGrp1 TO 090,290 LABEL  OemToAnsi('')                                        PIXEL OF oDlg
            @ 042,015 SAY OemToAnsi("Caracteristica:")                                       SIZE 035,09 PIXEL OF oDlg
            @ 041,055 MSGET oCaract VAR cCaract PICTURE '@! AA'                     F3 'SZ4' SIZE 020,09 PIXEL OF oDlg
            @ 055,015 SAY OemToAnsi("Variação:")                                             SIZE 035,09 PIXEL OF oDlg
            @ 054,055 MSGET oVariac VAR cVariac PICTURE '999'                       F3 'SZ3' SIZE 020,09 PIXEL OF oDlg
            @ 068,015 SAY OemToAnsi("Código:")                                               SIZE 035,09 PIXEL OF oDlg
            @ 067,055 MSGET oCodigo VAR cCodigo PICTURE '@R! AA 99.99.999.99.999'            SIZE 055,09 PIXEL OF oDlg
            @ 081,015 SAY OemToAnsi("Tipo:")                                                 SIZE 035,09 PIXEL OF oDlg
            @ 080,055 MSGET oTipo   VAR cTipo   PICTURE '@!'                                 SIZE 020,09 PIXEL OF oDlg
            /*************************************************************************************/
            @ 042,115 SAY OemToAnsi("Linha:")                             SIZE 035,09 PIXEL OF oDlg
            @ 041,150 MSGET oLinha  VAR cLinha  PICTURE '99'     F3 'SZ1' SIZE 020,09 PIXEL OF oDlg
            @ 055,115 SAY OemToAnsi("Embalagem:")                         SIZE 035,09 PIXEL OF oDlg
            @ 054,150 MSGET oEmbal  VAR cEmbal  PICTURE '99'     F3 'SZ5' SIZE 020,09 PIXEL OF oDlg
            @ 068,115 SAY OemToAnsi("Descrição:")                         SIZE 035,09 PIXEL OF oDlg
            @ 067,150 MSGET oDescri VAR cDescri PICTURE '@!'              SIZE 130,09 PIXEL OF oDlg
            @ 081,115 SAY OemToAnsi("Local:")                             SIZE 035,09 PIXEL OF oDlg
            @ 080,150 MSGET oLocal  VAR cLocal  PICTURE '@!'              SIZE 020,09 PIXEL OF oDlg
            /*************************************************************************************/
            @ 042,208 SAY OemToAnsi("Cor:")                              SIZE 035,09 PIXEL OF oDlg
            @ 041,248 MSGET oCor    VAR cCor   PICTURE '99'     F3 'SZ2' SIZE 020,09 PIXEL OF oDlg
            @ 055,208 SAY OemToAnsi("Seqüência:")                        SIZE 035,09 PIXEL OF oDlg
            @ 054,248 MSGET oSeq    VAR cSeq   PICTURE '99'              SIZE 020,09 PIXEL OF oDlg
            @ 081,208 SAY OemToAnsi("Unid. Medida:")                     SIZE 035,09 PIXEL OF oDlg
            @ 080,248 MSGET oUM     VAR cUM    PICTURE '@!'              SIZE 020,09 PIXEL OF oDlg

            oDlg:nStyle       := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
            oCodigo:bWhen := {||.f.} ; oTipo:bWhen := {||.f.} // ; oLocal:bWhen   := {||.f.}
            oUM:bWhen     := {||.f.} ; oSeq:bWhen  := {||.f.}
            oCaract:bValid := {|| U_fValPNT(1, @oCaract, @cCaract, @oLinha, @cLinha, @oCor, @cCor, @oVariac, @cVariac, @oEmbal, @cEmbal, @oSeq, @cSeq, @oCodigo, @cCodigo, @oDescri, @cDescri, @oTipo, @cTipo, @oLocal, @cLocal, @oUm, @cUm, @cBase, @cDesEmb )}
            oLinha:bValid  := {|| U_fValPNT(2, @oCaract, @cCaract, @oLinha, @cLinha, @oCor, @cCor, @oVariac, @cVariac, @oEmbal, @cEmbal, @oSeq, @cSeq, @oCodigo, @cCodigo, @oDescri, @cDescri, @oTipo, @cTipo, @oLocal, @cLocal, @oUm, @cUm, @cBase, @cDesEmb )}
            oCor:bValid    := {|| U_fValPNT(3, @oCaract, @cCaract, @oLinha, @cLinha, @oCor, @cCor, @oVariac, @cVariac, @oEmbal, @cEmbal, @oSeq, @cSeq, @oCodigo, @cCodigo, @oDescri, @cDescri, @oTipo, @cTipo, @oLocal, @cLocal, @oUm, @cUm, @cBase, @cDesEmb )}
            oVariac:bValid := {|| U_fValPNT(4, @oCaract, @cCaract, @oLinha, @cLinha, @oCor, @cCor, @oVariac, @cVariac, @oEmbal, @cEmbal, @oSeq, @cSeq, @oCodigo, @cCodigo, @oDescri, @cDescri, @oTipo, @cTipo, @oLocal, @cLocal, @oUm, @cUm, @cBase, @cDesEmb )}
            oEmbal:bValid  := {|| U_fValPNT(5, @oCaract, @cCaract, @oLinha, @cLinha, @oCor, @cCor, @oVariac, @cVariac, @oEmbal, @cEmbal, @oSeq, @cSeq, @oCodigo, @cCodigo, @oDescri, @cDescri, @oTipo, @cTipo, @oLocal, @cLocal, @oUm, @cUm, @cBase, @cDesEmb )}
 			oLocal:bValid  := {|| U_fValPNT(10, @oCaract, @cCaract, @oLinha, @cLinha, @oCor, @cCor, @oVariac, @cVariac, @oEmbal, @cEmbal, @oSeq, @cSeq, @oCodigo, @cCodigo, @oDescri, @cDescri, @oTipo, @cTipo, @oLocal, @cLocal, @oUm, @cUm, @cBase, @cDesEmb )}    
     ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| oDlg:End(), U_fSimPro(cCodigo, cDescri, cDesEmb, cLocal ) }, {|| oDlg:End() } ) CENTERED
Return

  /****************************************************************************/
  /*** TELA PARA VALIDAÇÃO DO PRODUTO NOVO - TINTAS                         ***/
  /*** Parâmetros: ExpN1 - Opção selecionada                                ***/
  /***             Exp?1...Exp?22 - Objetos e variaveis a serem validados   ***/
  /***             ExpC1 - Base de códigos por usuário qdo não definida a - ***/
  /***                     caracteristica e/ou variação da cor              ***/
  /****************************************************************************/
User Function fValPNT(nOpc, oCaract, cCaract, oLinha, cLinha, oCor, cCor, oVariac, cVariac, oEmbal, cEmbal, oSeq, cSeq, oCodigo, cCodigo, oDescri, cDescri, oTipo, cTipo, oLocal, cLocal, oUm, cUm, cBase, cDesEmb)
     If nOpc == 1 // Validação da Caracteristica
        If Empty(cCaract)
           MsgBox("Caracteristica não pode ser vazia","Atenção","STOP")
           cCaract := space(02)
           SetFocus(oCaract:hWnd)
           oCaract:Refresh()
           Return(.f.)
        ElseIf !cCaract $ "XX"
               DbSelectArea("SZ4")
               DbSetOrder(1)
               DbSeek(xFilial("SZ4")+cCaract,.t.)
               If Found()
                  oCaract:bWhen := {|| .f.}
                  oLinha:bWhen  := {|| .t.}
                  cCodigo:= Alltrim(cCaract) + space((Len(cCodigo) - Len(cCaract) ))
                  oCodigo:Refresh()
                  cDescri:= AllTrim(SZ4->Z4_DESCR)+space( (30 - Len(AllTrim(SZ4->Z4_DESCR)) ) )
                  cDescri:= cDescri+Space((30 - Len(Alltrim(cDescri))))
                  oDescri:Refresh()
                  SetFocus(oLinha:hWnd)
                  oLinha:Refresh()
                  //oLinha:bLostFocus  := {|| U_fValPNT(2, @oCaract, @cCaract, @oLinha, @cLinha, @oCor, @cCor, @oVariac, @cVariac, @oEmbal, @cEmbal, @oSeq, @cSeq, @oCodigo, @cCodigo, @oDescri, @cDescri, @oTipo, @cTipo, @oLocal, @cLocal, @oUm, @cUm, @cBase, @cDesEmb )}
                  Return(.t.)
               Else
                  MsgBox("Essa caracteristica não exite no cadastro !!!", "Atenção", "INFO")
                  cCaract := space(02)
                  oCaract:Refresh()
                  SetFocus(oCaract:hWnd)
                  Return(.f.)
               Endif
        ElseIf cCaract $ 'XX'
               oSeq:bWhen := {|| .t.} ; oCaract:bWhen := {|| .f.} ; oLinha:bWhen  := {|| .t.}
               cCodigo := cCaract + space((Len(cCodigo) - Len(cCaract) ))
               oCodigo:Refresh()
               SetFocus(oLinha:hWnd)
               oLinha:Refresh()
               //oLinha:bLostFocus  := {|| U_fValPNT(2, @oCaract, @cCaract, @oLinha, @cLinha, @oCor, @cCor, @oVariac, @cVariac, @oEmbal, @cEmbal, @oSeq, @cSeq, @oCodigo, @cCodigo, @oDescri, @cDescri, @oTipo, @cTipo, @oLocal, @cLocal, @oUm, @cUm, @cBase, @cDesEmb )}
               Return(.t.)
        Endif
     ElseIf nOpc == 2
            If Empty(cLinha)
               MsgBox("Linha não pode ser vazia","Atenção","STOP")
               cLinha := space(02)
               SetFocus(oLinha:hWnd)
               oLinha:Refresh()
               Return(.f.)
            Else
               DbSelectArea("SZ4")
               DbSetOrder(1)
               DbSeek(xFilial("SZ4")+cCaract+' '+cLinha,.t.)   // filial + caracteristica + cor
               If Found()
                  oLinha:bWhen := {|| .f.}
                  oCor:bWhen   := {|| .t.}
                  cCodigo := cCaract+' '+cLinha + space( Len(cCodigo) - Len(cCaract+' '+cLinha) )
                  oCodigo:Refresh()
                  SetFocus(oCor:hWnd)
                  oCor:Refresh()
                  //oCor:bLostFocus  := {|| U_fValPNT(3, @oCaract, @cCaract, @oLinha, @cLinha, @oCor, @cCor, @oVariac, @cVariac, @oEmbal, @cEmbal, @oSeq, @cSeq, @oCodigo, @cCodigo, @oDescri, @cDescri, @oTipo, @cTipo, @oLocal, @cLocal, @oUm, @cUm, @cBase, @cDesEmb )}
                  Return(.t.)
               Else
                  MsgBox("Não existe cadastro para essa CARACTERÍSTICA + LINHA. Verifique no cadastro de Características !!!", "Atenção", "INFO")
                  cLinha := space(02)
                  oLinha:Refresh()
                  SetFocus(oLinha:hWnd)
                  Return(.f.)
               Endif
            Endif
     ElseIf nOpc == 3
            If Empty(cCor)
               MsgBox("Cor não pode ser vazia","Atenção","STOP")
               cCor := space(02)
               SetFocus(oCor:hWnd)
               oCor:Refresh()
               Return(.f.)
            Else
               DbSelectArea("SZ2")
               DbSetOrder(1)
               DbSeek(xFilial("SZ2")+cCor,.t.)
               If Found()
                  oCor:bWhen := {|| .f.}
                  oVariac:bWhen   := {|| .t.}
                  cCodigo:= cCaract+' '+cLinha+cCor + space(Len(cCodigo) - Len(cCaract+' '+cLinha+cCor))
                  oCodigo:Refresh()
                  cDescri:= AllTrim(cDescri)+Iif(Empty(cDescri), Alltrim(SZ2->Z2_DESCR), ' '+Alltrim(SZ2->Z2_DESCR))+space( (30 - Len(AllTrim(AllTrim(cDescri)+Iif(Empty(cDescri), Alltrim(SZ2->Z2_DESCR), ' '+Alltrim(SZ2->Z2_DESCR)))) ) )
                  cDescri:= cDescri+Space((30 - Len(Alltrim(cDescri))))
                  oDescri:Refresh()
                  SetFocus(oVariac:hWnd)
                  oVariac:Refresh()
                  //oVariac:bLostFocus  := {|| U_fValPNT(4, @oCaract, @cCaract, @oLinha, @cLinha, @oCor, @cCor, @oVariac, @cVariac, @oEmbal, @cEmbal, @oSeq, @cSeq, @oCodigo, @cCodigo, @oDescri, @cDescri, @oTipo, @cTipo, @oLocal, @cLocal, @oUm, @cUm, @cBase, @cDesEmb )}
                  Return(.t.)
               Else
                  MsgBox("Essa cor não exite no cadastro !!!", "Atenção", "INFO")
                  cCor := space(02)
                  oCor:Refresh()
                  SetFocus(oCor:hWnd)
                  Return(.f.)
               Endif
            Endif
     ElseIf nOpc == 4
            If Empty(cVariac)
               MsgBox("Variação não pode ser vazia","Atenção","STOP")
               cVariac := space(03)
               SetFocus(oVariac:hWnd)
               oVariac:Refresh()
               Return(.f.)
            ElseIf !cVariac $ '999'
                   DbSelectArea("SZ3")
                   DbSetOrder(1)
                   DbSeek(xFilial("SZ3")+cCor+cVariac,.t.)
                   If Found()
                      oVariac:bWhen := {|| .f.}
                      oEmbal:bWhen  := {|| .t.}
                      cCodigo:= cCaract+' '+cLinha+cCor+cVariac + space(Len(cCodigo) - Len(cCaract+' '+cLinha+cCor+cVariac))
                      oCodigo:Refresh()
                      cDescri:= Alltrim(cDescri)+Iif(Empty(cDescri), Alltrim(SZ3->Z3_DESCR), ' '+Alltrim(SZ3->Z3_DESCR))+space( (30 - Len(AllTrim(cDescri+Iif(Empty(cDescri), Alltrim(SZ3->Z3_DESCR), ' '+Alltrim(SZ3->Z3_DESCR)) )) ) )
                      cDescri:= cDescri+Space((30 - Len(Alltrim(cDescri))))
                      oDescri:Refresh()
                      SetFocus(oEmbal:hWnd)
                      oEmbal:Refresh()
                      //oEmbal:bLostFocus  := {|| U_fValPNT(5, @oCaract, @cCaract, @oLinha, @cLinha, @oCor, @cCor, @oVariac, @cVariac, @oEmbal, @cEmbal, @oSeq, @cSeq, @oCodigo, @cCodigo, @oDescri, @cDescri, @oTipo, @cTipo, @oLocal, @cLocal, @oUm, @cUm, @cBase, @cDesEmb )}
                      Return(.t.)
                   Else
                      MsgBox("Essa variação não exite no cadastro !!!", "Atenção", "INFO")
                      cVariac := space(03)
                      oVariac:Refresh()
                      SetFocus(oVariac:hWnd)
                      Return(.f.)
                   Endif
            ElseIf cVariac $ '999'
                   oVariac:bWhen := {|| .f.} ; oEmbal:bWhen  := {|| .t.} ; oSeq:bWhen  := {|| .t.}
                   cCodigo := cCaract+' '+cLinha+cCor+cVariac + space(Len(cCodigo) - Len(cCaract+' '+cLinha+cCor+cVariac))
                   oCodigo:Refresh()
                   SetFocus(oEmbal:hWnd)
                   oEmbal:Refresh()
                   //oEmbal:bLostFocus  := {|| U_fValPNT(5, @oCaract, @cCaract, @oLinha, @cLinha, @oCor, @cCor, @oVariac, @cVariac, @oEmbal, @cEmbal, @oSeq, @cSeq, @oCodigo, @cCodigo, @oDescri, @cDescri, @oTipo, @cTipo, @oLocal, @cLocal, @oUm, @cUm, @cBase, @cDesEmb )}
                   Return(.t.)
            Endif
     ElseIf nOpc == 5
            If Empty(cEmbal)
               MsgBox("Embalagem não pode ser vazia","Atenção","STOP")
               cEmbal := space(02)
               SetFocus(oEmbal:hWnd)
               oEmbal:Refresh()
               Return(.f.)
            Else
               DbSelectArea("SZ5")
               DbSetOrder(1)
               DbSeek(xFilial("SZ5")+cEmbal,.t.)
               If Found()
                  oEmbal:bWhen := {|| .f.}
                  cCodigo := cCaract+' '+cLinha+cCor+cVariac+cEmbal + space(Len(cCodigo) - Len(cCaract+' '+cLinha+cCor+cVariac+cEmbal))
                  cDesEmb := SZ5->Z5_DESCR
                  oCodigo:Refresh()
                  If cCaract $ 'XX' .or. cVariac $ '999'
                     SetFocus(oSeq:hWnd)
                     oSeq:bLostFocus  := {|| U_fValPNT(6, @oCaract, @cCaract, @oLinha, @cLinha, @oCor, @cCor, @oVariac, @cVariac, @oEmbal, @cEmbal, @oSeq, @cSeq, @oCodigo, @cCodigo, @oDescri, @cDescri, @oTipo, @cTipo, @oLocal, @cLocal, @oUm, @cUm, @cBase, @cDesEmb )}
                  Else
                     SetFocus(oDescri:hWnd)
                  Endif
                  If cEmbal == '00'
                     cTipo  := 'PI' ; oTipo:Refresh()
                     cUM    := 'L'  ; oUM:Refresh()
                 	 Setfocus(oLocal:hWnd)
                     oLocal:Refresh()
                  Elseif cEmbal == '99'
                     cTipo  := 'PI' ; oTipo:Refresh()
                     cUM    := 'K'  ; oUM:Refresh()
                 	 Setfocus(oLocal:hWnd)
                     oLocal:Refresh()
                  Else
                     cTipo  := 'PA' ; oTipo:Refresh()
                     cUM    := 'UN' ; oUM:Refresh()
                     Setfocus(oLocal:hWnd)
                     oLocal:Refresh() 
                     cDesEmb:= SZ5->Z5_DESCR
                  Endif
                  oEmbal:Refresh()
                  Return(.t.)
               Else
                  MsgBox("Essa embalagem não exite no cadastro !!!", "Atenção", "INFO")
                  cEmbal := space(02)
                  oEmbal:Refresh()
                  SetFocus(oEmbal:hWnd)
                  Return(.f.)
               Endif
            Endif
     ElseIf nOpc == 6
            If Empty(cSeq)
               MsgBox("Sequencia não pode ser vazia","Atenção","STOP")
               cSeq := space(02)
               SetFocus(oSeq:hWnd)
               oSeq:Refresh()
               Return(.f.)
            Else
               oEmbal:bWhen := {|| .f.}
               cCodigo:= cCaract+' '+cLinha+cCor+cVariac+cEmbal+Alltrim(cBase)+Alltrim(cSeq) + space(Len(cCodigo) - Len(cCaract+' '+cLinha+cCor+cVariac+cEmbal+Alltrim(cBase)+Alltrim(cSeq)))
               oCodigo:Refresh()
               SetFocus(oLocal:hWnd)
            Endif
     ElseIf nOpc ==10 // Validação do Local Padrão
     		If cEmbal $ '00.99' .and. cTipo  == 'PI'
                If !cLocal $ "02.20"
            		MsgBox("O Local padrão de produção do PI deverá ser escolhido entre (02 Fab I ou 20 Fab II) !!!", "Atenção", "INFO")
                	cLocal := space(02)
                	SetFocus(oLocal:hWnd)
                	oLocal:Refresh()
                	Return(.f.)
    			Endif
            Elseif 	cTipo == 'PA' .and.  cUM == 'UN'
            	If !cLocal $ "P1.P2"
                	MsgBox("O Local padrão de envase do PA deverá ser escolhido entre (P1 Fab I ou P2 Fab II) !!!", "Atenção", "INFO")
 	                cLocal := space(02)
 	                SetFocus(oLocal:hWnd)
 	                oLocal:Refresh()
 	                Return(.f.)
 	            Endif 
            Endif
            oLocal:Refresh()      
     		SetFocus(oDescri:hWnd)
     Endif
Return(.t.)

  /****************************************************************************/
  /*** TELA PARA INCLUSÃO DO PRODUTO NOVO - PASTAS / SOLUÇÕES               ***/
  /*** Parâmetros:                                                          ***/
  /****************************************************************************/
User Function fProPas( _nOpc )
     Local nOpc    := Iif( _nOpc == Nil, 9, _nOpc )
     Local cCodigo := Iif(nOpc == 1, Space(04), Iif(nOpc == 2, Space(05), Space(07)))
     Local cDescri := Space(30)
     Local cTipo   := Iif(nOpc <> 3, 'PI', 'PA')
     Local cLocal  := Iif(nOpc <> 3, '02', '03')
     Local cUM     := 'K '
     Local cDesEmb := space(20)
     Local cTipPro := Iif(nOpc == 1, "Pastas / Soluções", Iif(nOpc == 2, "Concentrado", "Resina"))
     Local cPicPro := Iif(nOpc == 1, '9999', Iif(nOpc == 2, '99999', 'AA99999'))
     Local cLatex  := "  - Base Solvente"
     Local aLatex  := {"  - Base Solvente", "1 - Base d'Agua"}
     If nOpc == 9
        Return
     Endif
     DEFINE MSDIALOG oDlg TITLE OemToAnsi("Desenvolvimento de um novo produto - "+cTipPro) FROM 000,000 TO 012,050 OF oMainWnd
            @ 030,002 GROUP oGrp1 TO 070,185 LABEL  OemToAnsi('')                                                           PIXEL OF oDlg
            @ 032,005 SAY OemToAnsi("Código:")                       SIZE 035,09 PIXEL OF oDlg
            @ 031,045 MSGET oCodigo VAR cCodigo PICTURE cPicPro      SIZE 020,09 PIXEL OF oDlg
            If nOpc == 2
               @ 032, 095 SAY OemToAnsi("Tipo?")                     SIZE 015,09 PIXEL OF oDlg
               @ 031, 117 MSCOMBOBOX oLatex VAR cLatex ITEMS aLatex  SIZE 060,09 PIXEL OF oDlg
            Endif
            @ 045,005 SAY OemToAnsi("Descrição:")                    SIZE 035,09 PIXEL OF oDlg
            @ 044,045 MSGET oDescri VAR cDescri PICTURE '@!'         SIZE 132,09 PIXEL OF oDlg
            @ 058,005 SAY OemToAnsi("Tipo:")                         SIZE 035,09 PIXEL OF oDlg
            @ 057,045 MSGET oTipo   VAR cTipo   PICTURE '@!'         SIZE 020,09 PIXEL OF oDlg
            @ 058,075 SAY OemToAnsi("Local:")                        SIZE 015,09 PIXEL OF oDlg
            @ 057,095 MSGET oLocal  VAR cLocal  PICTURE '99'         SIZE 020,09 PIXEL OF oDlg
            @ 058,125 SAY OemToAnsi("Unid. Medida:")                 SIZE 035,09 PIXEL OF oDlg
            @ 057,160 MSGET oUM     VAR cUM     PICTURE '@!'         SIZE 015,09 PIXEL OF oDlg

            oTipo:bWhen := {||.f.} ;  oUM:bWhen := {||.f.} //; oLocal:bWhen := {||.f.}
            oCodigo:bValid := {|| U_fValPNP(1, @oCodigo, @cCodigo, @oDescri, @cDescri, @oLocal, @cLocal, nOpc)}
            oDescri:bValid := {|| U_fValPNP(2, @oCodigo, @cCodigo, @oDescri, @cDescri, @oLocal, @cLocal, nOpc)}
            oLocal:bValid  := {|| U_fValPNP(3, @oCodigo, @cCodigo, @oDescri, @cDescri, @oLocal, @cLocal, nOpc)}
            oDlg:nStyle       := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
     ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| oDlg:End(), U_fSimPro(Alltrim(cCodigo)+SubStr(cLatex, 1, 1)+space(14), cDescri, cDesEmb, cLocal, nOpc) }, {|| oDlg:End() } ) CENTERED
Return

  /****************************************************************************/
  /*** TELA PARA VALIDAÇÃO DO PRODUTO NOVO - PASTAS / SOLUÇÕES              ***/
  /*** Parâmetros: ExpN1 - Opção selecionada                                ***/
  /***             Exp?1...Exp?2  - Objetos e variaveis a serem validados   ***/
  /****************************************************************************/
User Function fValPNP(nOpc, oCodigo, cCodigo, oDescri, cDescri, oLocal, cLocal, nTpO)
     Local nTamPro := Iif(nTpO == 1, 4, 5)
     If nOpc == 1
        If nTpO == 1 .or. nTpO == 2
           If Empty(cCodigo) .or. Len(Alltrim(cCodigo)) < nTamPro
              MsgBox("Código do produto tem que ter pelo menos 4  digitos !!!", "Atenção", "ALERT")
              cCodigo := space(nTamPro)
              oCodigo:Refresh()
              SetFocus(oCodigo:hWnd)
              Return(.f.)
           Else
              If nTpO == 2
                 DbSelectArea("SZ3")
                 DbSetOrder(1)
                 DbSeek(xFilial("SZ3")+cCodigo, .t.)
                 If !Found()
                    MsgBox("Atenção esse código é inválido para cor+variação, verifique!!!", "Atenção", "ALERT")
                    cCodigo := space(nTamPro)
                    oCodigo:Refresh()
                    SetFocus(oCodigo:hWnd)
                    Return(.f.)
                 Else
                    cCodigo:= cCodigo + Space(15 - Len(cCodigo))
                    oCodigo:bWhen := {|| .f.}
                    SetFocus(oLatex:hWnd)
                    Return(.t.)
                 Endif
              Else
                 cCodigo:= cCodigo + Space(15 - Len(cCodigo))
                 oCodigo:bWhen := {|| .f.}
                 SetFocus(oDescri:hWnd)
                 Return(.t.)
              Endif
           Endif
        ElseIf nTpO == 3
           If Empty(cCodigo) .or. !(Len(Alltrim(cCodigo)) == 5 .or. Len(Alltrim(cCodigo)) == 7)
              MsgBox("Código do produto tem que ter 5 ou 7 digitos !!!", "Atenção", "ALERT")
              cCodigo := space(07)
              oCodigo:Refresh()
              SetFocus(oCodigo:hWnd)
              Return(.f.)
           Else
              cCodigo:= cCodigo + Space(15 - Len(cCodigo))
              oCodigo:bWhen := {|| .f.}
              SetFocus(oDescri:hWnd)
              Return(.t.)
           Endif
        Endif
     ElseIf nOpc == 2
        If Empty(cDescri)
           MsgBox("Digite a descrição do produto !!!","Atenção","ALERT")
           SetFocus(oDescri:hWnd)
           Return(.f.)
        Else
           Return(.t.)
        Endif
     Elseif nOpc == 3
     	If Empty(cLocal)
     		MsgBox("Digite o local padrão para Fabricação(02 ou 20)!!!","Atenção", "Alert")
     		Setfocus(oLocal:hWnd)
     		Return(.f.)
     	Elseif !cLocal $ "02.20"
     		MsgBox("Digite o local padrão para Fabricação(02 ou 20)!!!","Atenção", "Alert")
     		Setfocus(oLocal:hWnd)
     		Return(.f.)
     	Endif
     Endif
     
Return

  /****************************************************************************/
  /*** TELA PARA VALIDAÇÃO DO NOVO PRODUTO                                  ***/
  /*** Parâmetros:                                                          ***/
  /****************************************************************************/
User Function fSimPro(cCodigo, cDescri, cDesEmb, cLocal, nTpO)
     Local nOpc    := 3
     Local cProExi
     Local cVarAux := ""
     Local lRet    := .t.

	 If !EstaAutori(cCodigo)
		Alert("Acesso Não Autorizado!")
		Return(.f.)
	 Endif    
     
     DbSelectArea("SB1")
     DbSetOrder(1)
     DbSeek(xFilial("SB1")+cCodigo,.t.)
     If Found()
        cVarAux += "1 - Já existe um produto cadastrado com esse código !!!"+Chr(13)+Chr(10)
        cDescri := SB1->B1_DESC
        DbSelectArea("SG1")
        DbSetOrder(1)
        DbSeek(xFilial("SG1")+cCodigo,.t.)
        If Found()
           cVarAux += "2 - Já existe uma estrutura cadastrada com esse código !!!"+Chr(13)+Chr(10)
           cVarAux += Chr(13)+Chr(10)
           cVarAux += "Será gerada uma nova revisão..."
           cProExi := 'PE'
        Else
           cVarAux += "2 - Não existe uma estrutura cadastrada com esse código !!!"+Chr(13)+Chr(10)
           cVarAux += Chr(13)+Chr(10)
           cVarAux += "Será incluido uma nova estrutura..."
           cProExi := 'PN'
        Endif
        MsgBox(cVarAux, "Atenção", "INFO")
     Else
        cProExi := 'PN'
     Endif
     If nTpO == 1
        If SubStr(Alltrim(cCodigo), 11, 02) $ '00.99'
           If !lAcs1
              MsgBox("Usuário sem acesso !!!", "Atenção", "STOP")
              lRet := .f.
           Endif
        ElseIf SubStr(Alltrim(cCodigo), 11, 02) <> '00'
           If !lAcs3
              MsgBox("Usuário sem acesso !!!", "Atenção", "STOP")
              lRet := .f.
           Endif
        Endif
     ElseIf nTpO == 2
            If !lAcs1
               MsgBox("Usuário sem acesso !!!", "Atenção", "STOP")
               lRet := .f.
            Endif
     ElseIf nTpO == 3
            If !lAcs3
              MsgBox("Usuário sem acesso !!!", "Atenção", "STOP")
              lRet := .f.
           Endif
     Endif
     If !lRet
        Return(.f.)
     Else
        U_PCPX01_1(nOpc, cCodigo, cDescri, cProExi, , cDesEmb, cLocal )
     Endif
Return

Static Function EstaAutori(_cCodigo)
       Local lRet,cLinha,nArea,_cCodUsr
       //Local lAux
       Local _aRetInf := FWGetSX5( "W0", _cCodUsr )
       Local _nX

       nArea   := Alias()
       _cCodUsr := RetCodUsr()
       lRet := .t.
       If PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),_cCodUsr) != 0
          If Len(Trim(_cCodigo)) == 12
             lRet := .f.
             cLinha := Substr(_cCodigo,4,2)
             /********************************************************************************************************************************/
             /*** BLOCO ALTERADO EM 07/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
             /*DbSelectarea("SX5")
             dbsetorder(1)
             dbseek(xFilial("SX5")+"W0"+_cCodUsr,.t.)
             do while !eof() .and. (xFilial("SX5") = SX5->X5_FILIAL) .AND. (SX5->X5_TABELA = 'W0') .AND. (SX5->X5_CHAVE == _cCodUsr)
                if alltrim(SX5->X5_DESCRI) == alltrim(xFilial("SG1"))+cLinha
                   lRet = .t.
                   exit
                endif
                dbselectarea("SX5")
                dbskip()
             enddo*/
             For _nX := 1 To Len( _aRetInf )
                 If _aRetInf[_nX][3] == _cCodUsr
                    If Alltrim( _aRetInf[_nX][4] ) == Alltrim( xFilial("SG1") ) + cLinha
                       lRet = .t.
                       exit
                    Endif
                 Endif
             Next
             /*If lRet .and. lFiltBM
                  lRet := &cFiltBM
             Endif */
          Endif
       Endif
       DbSelectArea(nArea)
Return(lRet)


User Function fGrvSim(nOpc, nPesNew, nCalPVC, nCalBri)
     Local nPosCom  := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_COMP"    } )
     Local nPosTRT  := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_TRT"     } )
     Local nPosPer  := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_PERC"    } )
     Local nPosQtd  := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_QUANT"   } )
     Local nPosPda  := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_PERDA"   } )
     Local nPosINI  := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_INI"     } )
     Local nPosFIM  := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_FIM"     } )
     Local nPosFVa  := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_FIXVAR"  } )
     Local nPosRIn  := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_REVINI"  } )
     Local nPosRFi  := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_REVFIM"  } )
     Local nPosOpe  := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_OPERACA" } )
     Local nPosPes  := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_PESESP"  } )
     Local cId      := ""
     Local nX
    
     If nOpc == 3
        DbSelectArea("SZM")
        DbSetOrder(1)
        RecLock("SZM", .t.)
           cId := StrZero(SZM->(RecNo()), 6)
           SZM->ZM_FILIAL  := xFilial("SZM")
           SZM->ZM_CODIGO  := M->ZM_CODIGO
           SZM->ZM_DESCRIC := M->ZM_DESCRIC
           SZM->ZM_RESPONS := M->ZM_RESPONS
           SZM->ZM_DTINCLU := M->ZM_DTINCLU
           SZM->ZM_REVISAO := M->ZM_REVISAO
           SZM->ZM_SOLICIT := M->ZM_SOLICIT
           SZM->ZM_PESESP  := nPesNew
           SZM->ZM_PVC     := nCalPVC
           SZM->ZM_BRILHO  := nCalBri
           SZM->ZM_CATALIS := M->ZM_CATALIS
           SZM->ZM_RELCAT  := M->ZM_RELCAT
           SZM->ZM_REVISIN := Inverte(M->ZM_REVISAO)
           SZM->ZM_STATUS  := "EE"
           SZM->ZM_TIPOPRO := M->ZM_TIPOPRO
           SZM->ZM_TIPO    := M->ZM_TIPO
           SZM->ZM_LOCAL   := M->ZM_LOCAL
           SZM->ZM_UM      := M->ZM_UM
           SZM->ZM_ROTEIRO := M->ZM_ROTEIRO
           SZM->ZM_ID      := cId
           SZM->ZM_SEQ     := '101'
           SZM->ZM_PADCOR  := M->ZM_PADCOR
           SZM->ZM_PCREVIS := M->ZM_PCREVIS
           SZM->ZM_POSIPI  := M->ZM_POSIPI
           SZM->ZM_EX_NCM  := M->ZM_EX_NCM
   	       SZM->ZM_XCODANT := M->ZM_XCODANT
   	       SZM->ZM_GRUPO2  := M->ZM_GRUPO2
/*           If Len(Alltrim(M->ZM_CODIGO)) == 12
                DbSelectArea("SZ6")
                DbSetOrder(1)
                DbSeek(xFilial("SZ6")+SubStr(Alltrim(M->ZM_CODIGO),1,3)+SubStr(Alltrim(M->ZM_CODIGO),4,2)+SubStr(Alltrim(M->ZM_CODIGO),6,2), .t.)
                If Found()
                    DbSelectArea("SYD")
                    DbSetOrder(1)
                    DbSeek(xFilial("SYD")+SZ6->Z6_CLASFIS, .t.)
                    If Found()
                    	SZM->ZM_POSIPI:=(SZ6->Z6_CLASFIS)
                    Endif
        		Endif
           Else
           		SZM->ZM_POSIPI  := M->ZM_POSIPI
           Endif	*/

        MsUnLock()
        MsgRun("Gerando LOG de gravação pendência !!!", "Aguarde", {|| U_fGrvLog( SZM->ZM_ID, "SI", "EE", "Inclusão de simulação. "+Chr(13)+Chr(10)+M->ZM_MOTIVO, SZM->ZM_RESPONS, SZM->ZM_SEQ )} )
        For nX := 1 to Len(aCols)
            If aCols[nX][Len(aHeader)+1] == .T.
               Loop
            Endif
            RecLock("SZN",.t.)
               SZN->ZN_FILIAL  := xFilial("SZN")
               SZN->ZN_CODIGO  := M->ZM_CODIGO
               SZN->ZN_REVISAO := M->ZM_REVISAO
               SZN->ZN_COMP    := aCols[nX][nPosCom]
               SZN->ZN_TRT     := aCols[nX][nPosTRT]
               SZN->ZN_PERC    := aCols[nX][nPosPer]
               SZN->ZN_QUANT   := aCols[nX][nPosQtd]
               SZN->ZN_PESESP  := aCols[nX][nPosPEs]
               SZN->ZN_PERDA   := aCols[nX][nPosPda]
               SZN->ZN_INI     := aCols[nX][nPosIni]//IiF(POSICIONE("SB1",1,xFilial("SB1")+Alltrim(aCols[nX][nPosCom]),"B1_TIPO")="MC" .AND. POSICIONE("SB1",1,xFilial("SB1")+Alltrim(aCols[nX][nPosCom]),"B1_GRUPO2")= GETMV("MV_XGRPMC"),CTOD("31/12/2012"),ddatabase)          //aCols[nX][nPosIni]
               SZN->ZN_FIM     := aCols[nX][nPosFim]//IiF(POSICIONE("SB1",1,xFilial("SB1")+Alltrim(aCols[nX][nPosCom]),"B1_TIPO")="MC" .AND. POSICIONE("SB1",1,xFilial("SB1")+Alltrim(aCols[nX][nPosCom]),"B1_GRUPO2")= GETMV("MV_XGRPMC"),CTOD("31/12/2012"),CTOD("31/12/2049")) ////aCols[nX][nPosFim]
               SZN->ZN_FIXVAR  := aCols[nX][nPosFVa]
               SZN->ZN_REVINI  := aCols[nX][nPosRIn]
               SZN->ZN_REVFIM  := aCols[nX][nPosRFi]
               SZN->ZN_OPERACA := aCols[nX][nPosOpe]
            MsUnLock()
        Next
     ElseIf nOpc == 2
            DbSelectArea("SZM")
            DbSetOrder(1)
            DbSeek(xFilial("SZM")+M->ZM_CODIGO+M->ZM_REVISAO,.t.)
            If Found()
               RecLock("SZM",.f.)
                  SZM->ZM_SOLICIT := M->ZM_SOLICIT
                  SZM->ZM_DESCRIC := M->ZM_DESCRIC
                  SZM->ZM_CATALIS := M->ZM_CATALIS
                  SZM->ZM_RELCAT  := M->ZM_RELCAT
                  SZM->ZM_ROTEIRO := M->ZM_ROTEIRO
                  SZM->ZM_RESPONS := M->ZM_RESPONS
                  SZM->ZM_PESESP  := Iif(M->ZM_TIPO $ 'PA', 1, nPesNew)
                  SZM->ZM_PVC     := nCalPVC
                  SZM->ZM_BRILHO  := nCalBri
                  SZM->ZM_PADCOR  := M->ZM_PADCOR
                  SZM->ZM_PCREVIS := M->ZM_PCREVIS
                  SZM->ZM_POSIPI  := M->ZM_POSIPI
                  SZM->ZM_EX_NCM  := M->ZM_EX_NCM
                  SZM->ZM_XCODANT := M->ZM_XCODANT
  				  SZM->ZM_GRUPO2  := M->ZM_GRUPO2
               MsUnLock()
            Endif
            DbSelectArea("SZT")
            DbSetOrder(1)
            DbSeek(xFilial("SZT")+M->ZM_ID,.t.)
            If Found()
               RecLock("SZT",.f.)
                  SZT->ZT_LOG := M->ZM_MOTIVO
               MsUnLock()
            Endif

            For nX := 1 to Len(aCols)
                DbSelectArea("SZN")
                DbSetOrder(4)
                DbSeek(xFilial("SZN")+M->ZM_CODIGO+M->ZM_REVISAO+aCols[nX][nPosCom]+aCols[nX][nPosTRT],.t.)
                If Found()
                   If aCols[nX][Len(aHeader)+1] == .t.
                      RecLock("SZN",.f.)
                         Delete
                      MsUnLock()
                   Else
                      RecLock("SZN",.f.)
                         SZN->ZN_COMP    := aCols[nX][nPosCom]
                         SZN->ZN_TRT     := aCols[nX][nPosTRT]
                         SZN->ZN_PERC    := aCols[nX][nPosPer]
                         SZN->ZN_QUANT   := aCols[nX][nPosQtd]
                         SZN->ZN_PESESP  := aCols[nX][nPosPEs]
                         SZN->ZN_PERDA   := aCols[nX][nPosPda]
                         SZN->ZN_OPERACA := aCols[nX][nPosOpe]
                      MsUnLock()
                   Endif
                Else
                   If aCols[nX][Len(aHeader) + 1] == .f.
                      DbSelectArea("SZN")
                      DbSetOrder(3)
                      DbSeek(xFilial("SZN")+aCols[nX][nPosTRT]+M->ZM_CODIGO+M->ZM_REVISAO,.t.)
                      If Found()
                         RecLock("SZN",.f.)
                            SZN->ZN_COMP    := aCols[nX][nPosCom]
                            SZN->ZN_TRT     := aCols[nX][nPosTRT]
                            SZN->ZN_PERC    := aCols[nX][nPosPer]
                            SZN->ZN_QUANT   := aCols[nX][nPosQtd]
                            SZN->ZN_PERDA   := aCols[nX][nPosPda]
			                SZN->ZN_INI     := aCols[nX][nPosIni]//IiF(POSICIONE("SB1",1,xFilial("SB1")+Alltrim(aCols[nX][nPosCom]),"B1_TIPO")="MC" .AND. POSICIONE("SB1",1,xFilial("SB1")+Alltrim(aCols[nX][nPosCom]),"B1_GRUPO2")= GETMV("MV_XGRPMC"),CTOD("31/12/2012"),ddatabase) //aCols[nX][nPosIni]
			                SZN->ZN_FIM     := aCols[nX][nPosFim]//IiF(POSICIONE("SB1",1,xFilial("SB1")+Alltrim(aCols[nX][nPosCom]),"B1_TIPO")="MC" .AND. POSICIONE("SB1",1,xFilial("SB1")+Alltrim(aCols[nX][nPosCom]),"B1_GRUPO2")= GETMV("MV_XGRPMC"),CTOD("31/12/2012"),CTOD("31/12/2049")) //aCols[nX][nPosFim]
                            SZN->ZN_FIXVAR  := aCols[nX][nPosFVa]
                            SZN->ZN_REVINI  := aCols[nX][nPosRIn]
                            SZN->ZN_REVFIM  := aCols[nX][nPosRFi]
                            SZN->ZN_OPERACA := aCols[nX][nPosOpe]
                         MsUnLock()
                      Else
                         RecLock("SZN",.t.)
                            SZN->ZN_FILIAL  := xFilial("SZN")
                            SZN->ZN_CODIGO  := M->ZM_CODIGO
                            SZN->ZN_REVISAO := M->ZM_REVISAO
                            SZN->ZN_COMP    := aCols[nX][nPosCom]
                            SZN->ZN_TRT     := aCols[nX][nPosTRT]
                            SZN->ZN_PERC    := aCols[nX][nPosPer]
                            SZN->ZN_QUANT   := aCols[nX][nPosQtd]
                            SZN->ZN_PERDA   := aCols[nX][nPosPda]
			                SZN->ZN_INI     := aCols[nX][nPosIni]//IiF(POSICIONE("SB1",1,xFilial("SB1")+Alltrim(aCols[nX][nPosCom]),"B1_TIPO")="MC" .AND. POSICIONE("SB1",1,xFilial("SB1")+Alltrim(aCols[nX][nPosCom]),"B1_GRUPO2")= GETMV("MV_XGRPMC"),CTOD("31/12/2012"),ddatabase) //aCols[nX][nPosIni]
			                SZN->ZN_FIM     := aCols[nX][nPosFim]//IiF(POSICIONE("SB1",1,xFilial("SB1")+Alltrim(aCols[nX][nPosCom]),"B1_TIPO")="MC" .AND. POSICIONE("SB1",1,xFilial("SB1")+Alltrim(aCols[nX][nPosCom]),"B1_GRUPO2")= GETMV("MV_XGRPMC"),CTOD("31/12/2012"),CTOD("31/12/2049")) //aCols[nX][nPosFim]
                            SZN->ZN_FIXVAR  := aCols[nX][nPosFVa]
                            SZN->ZN_REVINI  := aCols[nX][nPosRIn]
                            SZN->ZN_REVFIM  := aCols[nX][nPosRFi]
                            SZN->ZN_OPERACA := aCols[nX][nPosOpe]
                         MsUnLock()
                      Endif
                   Endif
                Endif
            Next                                                                              
     ElseIf nOpc == 4
            cIdExc := M->ZM_ID
            aExcl  := {}
            DbSelectArea("SZM")
            DbSetOrder(4)
            DbSeek(xFilial("SZM")+cIdExc,.t.)
            While !eof() .and. SZM->ZM_ID == cIdExc
                  aadd(aExcl, { cIdExc, SZM->ZM_CODIGO, SZM->ZM_REVISAO, SZM->ZM_NUMSOL })
                  DbSelectArea("SZM")
                  DbSkip()
            Enddo
            For nX := 1 to Len(aExcl)
                DbSelectArea("SZN")
                DbSetOrder(2)
                DbSeek(xFilial("SZN")+aExcl[nX][2]+aExcl[nX][3],.t.)
                If Found()
                   While !Eof() .and. SZN->ZN_CODIGO == aExcl[nX][2] .and. SZN->ZN_REVISAO == aExcl[nX][3]
                         RecLock("SZN",.f.)
                            Delete
                         MsUnLock()
                         DbSelectArea("SZN")
                         DbSkip()
                   Enddo
                Endif
                DbSelectArea("SZP")
                DbSetOrder(1)
                DbSeek(xFilial("SZP")+aExcl[nX][2]+aExcl[nX][3],.t.)
                If Found()
                   While !Eof() .and. SZP->ZP_CODIGO == aExcl[nX][2] .and. SZP->ZP_REVISAO == aExcl[nX][3]
                         RecLock("SZP",.f.)
                            Delete
                         MsUnLock()
                         DbSelectArea("SZP")
                         DbSkip()
                   Enddo
                Endif
                DbSelectArea("SZT")
                DbSetOrder(1)
                DbSeek(xFilial("SZT")+M->ZM_ID,.t.)
                If Found()
                   While !Eof() .and. SZT->ZT_ID == aExcl[nX][1]
                         RecLock("SZT",.f.)
                            Delete
                         MsUnLock()
                         DbSelectArea("SZT")
                         DbSkip()
                   Enddo
                Endif
                If !Empty(M->ZM_SOLICIT)
                   DbSelectArea("SZO")
                   DbSetOrder(1)
                   DbSeek(xFilial("SZO")+aExcl[nX][4],.t.)
                   If Found()
                      RecLock("SZO",.f.)
                         SZO->ZO_STATUS := "EN"
                      MsUnLock()
                   Endif
                Endif
                DbSelectArea("SZM")
                DbSetOrder(1)
                DbSeek(xFilial("SZM")+aExcl[nX][2]+aExcl[nX][3],.t.)
                If Found()
                   RecLock("SZM",.f.)
                      Delete
                   MsUnLock()
                Endif
            Next
      Endif
Return Nil

User Function fGrvLog(cId, cProcess, cStatus, cObs, cUser, cSeq)
     Local cQry := ""
     cQry := ""
     cQry += "SELECT ISNULL(MAX(SZT.ZT_SEQ), '000') AS SEQ "
     cQry += "FROM "+RetSqlName("SZT")+" SZT "
     cQry += "WHERE SZT.D_E_L_E_T_ = ' ' "
     cQry += "  AND SZT.ZT_ID = '"+cId+"' "
     cQry += "  AND SUBSTRING(SZT.ZT_SEQ,1,1) = '"+SubStr(cSeq, 1, 1)+"' "
     TCQuery cQry ALIAS "TCQ" NEW
     DbSelectArea("TCQ")
     cSeq := SubStr(cSeq, 1, 1) + StrZero(Val(SubStr(TCQ->SEQ, 2, 2))+1, 2)
     DbSelectArea("TCQ")
     DbCloseArea()
     
     DbSelectArea("SZT")
     DbSetOrder(1)
     RecLock("SZT",.t.)
        SZT->ZT_FILIAL  := xFilial("SZT")
        SZT->ZT_ID      := cId
        SZT->ZT_PROCESS := cProcess
        SZT->ZT_STATUS  := cStatus
        SZT->ZT_LOG     := cObs
        SZT->ZT_USUARIO := cUser
        SZT->ZT_DATAGER := dDataBase
        SZT->ZT_HORAGER := Time()
        SZT->ZT_SEQ     := cSeq
     MsUnLock()
Return

User FuncTion fCalRea(cProd, cRevi)
     Local nCusto := 0
     DbSelectArea("SZN")
     DbSetOrder(2)
     cAlias := ALIAS()
     nRecno := RECNO()
     nIndex := INDEXORD()

     // produto de custeio
     If U_IsProdCusto(cProd)
         DbSeletArea(cAlias)
         DbSetOrder(nIndex)
         DbGoTo(nRecno)
         Return(nCusto)
     Endif    

     DbSeek(xFilial("SZN")+cProd+cRevi,.t.)
     If Found()
        While !Eof() .and. SZN->ZN_CODIGO == cProd .and. SZN->ZN_REVISAO == cRevi
            // produto de custeio
            If U_IsProdCusto(SZN->ZN_COMP)
               SZN->(dbSkip())
               Loop
            Endif   
         
              DbSelectArea("SB1")
              DBSetOrder(1)
              DbSeek(xFilial("SB1")+SZN->ZN_COMP,.t.)
              If Found()
                 If SB1->B1_TIPO $ "MP.MC"
                    //nCusto += ((SZN->ZN_QUANT + (SZN->ZN_QUANT * (SZN->ZN_PERDA / 100))) * SB1->B1_UPRC )
                    nCusto += ((SZN->ZN_QUANT / (1-(SZN->ZN_PERDA / 100))) * SB1->B1_UPRC )
                 Else
                    //nCusto += ((SZN->ZN_QUANT + (SZN->ZN_QUANT * (SZN->ZN_PERDA / 100))) * fCUSPRO(SZN->ZN_COMP))
                    nCusto += ((SZN->ZN_QUANT / (1- (SZN->ZN_PERDA / 100))) * U_fCCUSPRO(SZN->ZN_COMP))//fCUSPRO(SZN->ZN_COMP))
                 Endif
              Endif
              DbSelectArea("SZN")
              DbSkip()
        Enddo
     Else
        nCusto := U_CUSTOPRO(cProd)
     Endif
     DbSeletArea(cAlias)
     DbSetOrder(nIndex)
     DbGoTo(nRecno)
Return(nCusto)

/*Static Function fCusPro(cComp, cAlias, cRev)
       Local cQry   := ""
       Local nCusto := 0
       Local nPesoE := 0
       //Local cKL    := IIf(Alltrim(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(cCodigo, 11, 02), "Z5_UMEMB"))='K','99','00')
       If cRev <> Nil .and. Len(Alltrim(cComp)) == 12 .and. SubStr(Alltrim(cComp), 11, 2) $ '00.99'
          DbSelectArea("SZM")
          DbSetOrder(1)
          DbSeek(xFilial("SZM")+cComp+cRev, .t.)
          If !Found()
             cRev := ""
          Endif
       Endif
       cAlias := Iif(cAlias == Nil, "CUS00", "CUS"+StrZero(Val(SubStr(cAlias, 4, 2)) + 1, 2) )
       If cRev == Nil
          cQry += "SELECT SG1.G1_COMP AS COMP, SB1.B1_TIPO AS TIPO, SG1.G1_QUANT AS QUANT, SG1.G1_PERDA AS PERDA, SB1.B1_UPRC AS UPRC, "
          cQry += "'CUSTO' = "
          cQry += "       CASE "
          cQry += "          WHEN SB1.B1_TIPO IN('MP','MC') THEN dbo.CustoPro ('"+xFilial("SG1")+"',SG1.G1_COMP,1) " //WHEN SB1.B1_TIPO IN('MP','MC') THEN ((SG1.G1_QUANT + (SG1.G1_QUANT * (SG1.G1_PERDA / 100))) * SB1.B1_UPRC) "
          //cQry += "          WHEN SB1.B1_TIPO IN('MP','MC') THEN ((SG1.G1_QUANT /(1- (SG1.G1_PERDA / 100))) * SB1.B1_UPRC) " //WHEN SB1.B1_TIPO IN('MP','MC') THEN ((SG1.G1_QUANT + (SG1.G1_QUANT * (SG1.G1_PERDA / 100))) * SB1.B1_UPRC) "
          cQry += "          ELSE 0 " 
          cQry += "          END "
          cQry += "FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "
          cQry += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON SG1.G1_FILIAL = SB1.B1_FILIAL AND SG1.G1_COMP = SB1.B1_COD AND SB1.D_E_L_E_T_ = '' "
          cQry += "WHERE SG1.D_E_L_E_T_ = '' "
          cQry += "  AND SG1.G1_FILIAL  = '"+xFilial("SG1")+"' "
          cQry += "  AND SG1.G1_COD = '"+cComp+"' "
          cQry += "ORDER BY SG1.G1_COD, SG1.G1_TRT "
       Else
          nPesoE := Posicione("SZM", 1, xFilial("SZM")+cComp+cRev, "ZM_PESESP")
          cQry += "SELECT SZN.ZN_COMP AS COMP, SB1.B1_TIPO AS TIPO, SB1.B1_UPRC AS UPRC, ((SZN.ZN_PERC / 100) * "+StrTran(Transform(nPesoE, "@E 999.999999"), ",", ".")+") AS QUANT, SZN.ZN_PERDA AS PERDA, "
          //cQry += "'CUSTO' = dbo.CustoProSZN ('"+xFilial("SZN")+"',SZN.ZN_COMP,1,'"+cRev+"')
          cQry += "'CUSTO' = "
          cQry += "       CASE "
		  cQry += "          WHEN SB1.B1_TIPO IN('MP','MC') THEN dbo.CustoProSZN ('"+xFilial("SZN")+"',SZN.ZN_COMP,1,'"+cRev+"') "
          ////cQry += "        WHEN SB1.B1_TIPO IN('MP','MC') THEN ((((SZN.ZN_PERC / 100) * "+StrTran(Transform(nPesoE, "@E 999.999999"), ",", ".")+") + (((SZN.ZN_PERC / 100) * "+StrTran(Transform(nPesoE, "@E 999.999999"), ",", ".")+") * (SZN.ZN_PERDA / 100))) * SB1.B1_UPRC) "
          //cQry += "          WHEN SB1.B1_TIPO IN('MP','MC') THEN (SZN.ZN_QUANT * (1-(SZN.ZN_PERDA / 100)) * SB1.B1_UPRC)   "
          cQry += "          ELSE 0 "
          cQry += "          END "
          cQry += "FROM "+RetSqlName("SZN")+" SZN WITH (NOLOCK) "
          cQry += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON SZN.ZN_FILIAL = SB1.B1_FILIAL AND SZN.ZN_COMP = SB1.B1_COD AND SB1.D_E_L_E_T_ = '' "
          cQry += "WHERE SZN.D_E_L_E_T_ = '' "
          cQry += "  AND SZN.ZN_FILIAL  = '"+xFilial("SZN")+"' "
          cQry += "  AND SZN.ZN_CODIGO  = '"+cComp+"' "
          cQry += "  AND SZN.ZN_REVISAO = '"+cRev+"' "
          cQry += "ORDER BY SZN.ZN_CODIGO, SZN.ZN_REVISAO, SZN.ZN_TRT "
       Endif
       //cQry := ChangeQuery(cQry)
       
       //TCQuery cQry ALIAS &cAlias NEW
       dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAlias,.T.,.T.) 
       DbSelectArea(cAlias)
       DbGoTop()
       While !Eof()
             If !&(cAlias+"->TIPO") $ 'MP.MC'
                //nCusto += (&(cAlias+"->QUANT") + (&(cAlias+"->QUANT") * (&(cAlias+"->PERDA") / 100))) * Iif(&(cAlias+"->TIPO") $ 'PI', fCusPro(&(cAlias+"->COMP"), cAlias), 0)
 				nCusto += &(cAlias+"->CUSTO")//(&(cAlias+"->QUANT") / (1- (&(cAlias+"->PERDA") / 100))) * &(cAlias+"->UPRC") //Iif(&(cAlias+"->TIPO") $ 'PI', fCusPro(&(cAlias+"->COMP"), cAlias), 0)
             Else
                //nCusto += &(cAlias+"->CUSTO")
                nCusto += (&(cAlias+"->QUANT") / (1- (&(cAlias+"->PERDA") / 100))) * Iif(&(cAlias+"->TIPO") $ 'PI', &(cAlias+"->CUSTO"), 0)
             Endif
             DbSelectArea(cAlias)
             DbSkip()
       Enddo
       DbSelectArea(cAlias)
       DbCloseArea()
Return(nCusto)*/

User Function fUlRvFrm(cCodigo)
     Local cQry1   := ""
     Local cCodRev := 0
     Local nPVCVig := 0
     Local nBriVig := 0
     Local nPesVig := 0

     cQry1 += "SELECT TOP 1 SZM.ZM_CODIGO, SZM.ZM_REVISAO, SZM.ZM_PESESP, SZM.ZM_ID, SZM.ZM_PVC, SZM.ZM_BRILHO "
     cQry1 += "FROM "+RetSqlName("SZM")+" SZM WITH (NOLOCK) "
     cQry1 += "WHERE SZM.ZM_FILIAL  = '"+xFilial("SZM")+"' "
     cQry1 += "  AND SZM.D_E_L_E_T_ = '' "
     cQry1 += "  AND SZM.ZM_CODIGO  = '"+cCodigo+"' "
     cQry1 += "  AND SZM.ZM_STATUS  = 'AC' "
     cQry1 += "ORDER BY SZM.ZM_REVISAO DESC "
     TCQuery cQry1 ALIAS "TMP" NEW
     DbSelectArea("TMP")
     cCodRev := TMP->ZM_REVISAO
     nPVCVig := TMP->ZM_PVC
     nBriVig := TMP->ZM_BRILHO
     nPesVig := Posicione("SB1", 1, xFilial("SB1")+TMP->ZM_CODIGO, "B1_PESOESP")
     DbSelectArea("TMP")
     DbCloseArea()
     
Return({cCodRev, nPesVig, nPVCVig, nBriVig})

User Function fCalEsp(cCodigo, cRevisao, nPesNew, _nCalPVC, _nCalBri)
       Local cQry1       := ""
       //Local cQry2       := ""
       //Local nPesEsp     := 0
       Local nCalPVC     := Iif( _nCalPVC == Nil, 0, _nCalPVC )
       Local nCalBri     := Iif( _nCalBri == Nil, 0, _nCalBri )

       cQry1 += "SELECT SZM.ZM_CODIGO, SZM.ZM_REVISAO, SZM.ZM_PESESP, SZM.ZM_TIPO, SZM.ZM_UM "
       cQry1 += "FROM "+RetSqlName("SZM")+" SZM WITH (NOLOCK) "
       cQry1 += "WHERE SZM.ZM_FILIAL  = '"+xFilial("SZM")+"' "
       cQry1 += "  AND SZM.D_E_L_E_T_ = '' "
       cQry1 += "  AND SZM.ZM_CODIGO  = '"+cCodigo+"' "
       cQry1 += "  AND SZM.ZM_REVISAO = '"+cRevisao+"' "
       cQry1 += "ORDER BY SZM.ZM_CODIGO, SZM.ZM_REVISAO "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()
       If !Eof()
          While !Eof()
                fProces(cCodigo, cRevisao, TCQ->ZM_TIPO, TCQ->ZM_UM, nPesNew, @nCalPVC, @nCalBri)
                DbSelectArea("TCQ")
                DbSkip()
          Enddo
       Else
          fProces(cCodigo, cRevisao, M->ZM_TIPO, M->ZM_UM, nPesNew, @nCalPVC, @nCalBri)
       Endif
       DbSelectArea("TCQ")
       DbCloseArea()
Return()

Static Function fProces(cCodPro, cRevPro, cTipPro, cUniMed, nPesNew, nCalPVC, nCalBri)
       Local nPosSeq := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_TRT"  } )
       Local nPosCom := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_COMP" } )
       Local nPosPer := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_PERC"    } )
       //Local nPosPEs := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_PESESP"  } )
       //Local cQry1    := ""
       Local nPerFor  := 0
       Local aFormula := {}
       Local aResina  := {}
       Local aPigmen  := {}
	   Local aSolvent := {}
       Local nPvol    := 0
       Local nPTot    := 0
       Local nVvol    := 0
       //Local nVTot    := 0
       Local nMAbs    := 0
       Local nMMis    := 0
       Local nY
       nCalPVC        := 0
       nCalBri        := 0

       If cTipPro $ 'PI'
          For nY := 1 To Len(aCols)
              If aCols[nY][Len(aHeader) + 1] == .t.
                 Loop
              Endif
              cTipMat := Posicione("SB1", 1, xFilial("SB1")+aCols[nY][nPosCom], "B1_TIPO")
              nPesMat := Posicione("SB1", 1, xFilial("SB1")+aCols[nY][nPosCom], "B1_PESOESP")
              cGruMat := Posicione("SB1", 1, xFilial("SB1")+aCols[nY][nPosCom], "B1_GRUPO")
              aAdd(aFormula, { aCols[nY][nPosSeq], aCols[nY][nPosCom], "", cTipMat, aCols[nY][nPosPer], nPesMat, cGruMat })
          Next
          
          If Len(Alltrim(cCodPro)) == 12
             For nY := 1 To Len(aFormula)
                 If aFormula[nY][4] $ 'MP'      //Matéria Prima
                    If aFormula[nY][7] $ '0002' //Resina
                       aadd(aResina, {'RES', 'D', aFormula[nY][2], aFormula[nY][5], aFormula[nY][6], 0, 0, 0, 0, 0, 0, 0, 0, "", 0, "" })
                       fCalVol(1, aFormula[nY][2], @aSolvent, @aResina, aFormula[nY][5]) //Busca Solventes da Resina
                    ElseIf aFormula[nY][7] $ '0008.0009' //Pigmento ou Carga
                           aadd(aPigmen, {'PIG', 'D', aFormula[nY][2], aFormula[nY][5], aFormula[nY][6], 0, fBusAbs(aFormula[nY][2]), 0, 0, 0, 0, aFormula[nY][5], (aFormula[nY][5] / aFormula[nY][6]), "", 0, ""} )
                    Endif
                 ElseIf aFormula[nY][4] $ 'PI'  //Produto Intermediário
                        If aFormula[nY][7] $ '0011' //Pasta
                           fBusPas(aFormula[nY][2], aFormula[nY][5], '01', @aPigmen, @aResina, @aSolvent)
                        Endif 
                 Endif
             Next
             //Reprocessa Matriz de pigmentos para calculos
             For nY := 1 To Len(aPigmen)
                 nPTot += aPigmen[nY][12]
             Next
             For nY := 1 To Len(aPigmen)
                 aPigmen[nY][08] := (aPigmen[nY][12] / nPTot) * 100
                 aPigmen[nY][09] := (aPigmen[nY][08] / 100) * aPigmen[nY][05]
                 aPigmen[nY][10] := (aPigmen[nY][08] / 100) * aPigmen[nY][07]
                 nMMis += aPigmen[nY][09]
                 nMAbs += aPigmen[nY][10]
                 nPVol += aPigmen[nY][13]
             Next
             For nY := 1 To Len(aResina)
                 nVVol += aResina[nY][13]
             Next

             nCalPVC := ((nPVol / (nPVol + nVVol)) * 100)
             nCalBri := (100 - nCalPVC) - (nCalPVC * nMMis) * (nMAbs / 100)
             nCalPVC := Iif(nCalPVC < 0, 0, Iif(nCalPVC > 100, 100, nCalPVC)) 
             nCalBri := Iif(nCalBri < 0, 0, Iif(nCalBri > 100, 100, nCalBri))
          Else
             nCalPVC := 0
             nCalBri := 0
          Endif
          //DbSelectArea("EST")
          //DbCloseArea()
       Else
          nCalPVC := 0
          nCalBri := 0
          //nPesNew := 0
          nPerFor := 0
       Endif
Return
/************************************************************************************************/
/*** FCALVOL - Calculo do volume da resina.                                                   ***/
/************************************************************************************************/
Static Function fCalVol(nTipCal, cCodRes, aSolvent, aResina, nPerFor)
       Local cQry1   := ""
       Local nPerVol := 0
       Local nDenSol := 0
       Local aRefRes := {}
       Local nX
       
       //VOLUME DO SOLVENTE NA RESINA = SOMA DOS PERCENTUAIS UTILIZADOS
       //DENSIDADE DO SOLVENTE NA RESINA = SOMATÓRIA DO PERCENTUAL DE CADA ITEM DIVIDIDO PELO SEU PESO ESPECIFICO
       //Matriz de conversão de resinas entre as filias 01 e 04 (Matriz x Resina)
       aAdd(aRefRes, {'RV100', '0100'}) ; aAdd(aRefRes, {'RV101', '0101'}) ; aAdd(aRefRes, {'RV108', '0108'})
       aAdd(aRefRes, {'RV109', '0149'}) ; aAdd(aRefRes, {'RV110', '0110'}) ; aAdd(aRefRes, {'RV112', '0112'})
       aAdd(aRefRes, {'RV118', '0118'}) ; aAdd(aRefRes, {'RV124', '0124'}) ; aAdd(aRefRes, {'RV127', '0127'})
       aAdd(aRefRes, {'RV130', '0158'}) ; aAdd(aRefRes, {'RV131', '0131'}) ; aAdd(aRefRes, {'RV132', '0132'})
       aAdd(aRefRes, {'RV138', '0138'}) ; aAdd(aRefRes, {'RV139', '0139'}) ; aAdd(aRefRes, {'RV150', '0150'})
       aAdd(aRefRes, {'RV154', '0154'}) ; aAdd(aRefRes, {'RV157', '0157'}) ; aAdd(aRefRes, {'RV160', '0160'})
       aAdd(aRefRes, {'RV161', '0161'}) ; aAdd(aRefRes, {'RV164', '0164'}) ; aAdd(aRefRes, {'RV165', '0165'})
       aAdd(aRefRes, {'RV166', '0166'}) ; aAdd(aRefRes, {'RV169', '0169'}) ; aAdd(aRefRes, {'RV170', '0170'})
       aAdd(aRefRes, {'RV171', '0171'}) ; aAdd(aRefRes, {'RV173', '0173'}) ; aAdd(aRefRes, {'RV180', '0180'})
       aAdd(aRefRes, {'RV181', '0181'}) ; aAdd(aRefRes, {'RV182', '0182'}) ; aAdd(aRefRes, {'RV183', '0183'})
       aAdd(aRefRes, {'RV188', '0188'}) ; aAdd(aRefRes, {'RV189', '0189'}) ; aAdd(aRefRes, {'RV190', '0190'})
       aAdd(aRefRes, {'RV191', '0191'}) ; aAdd(aRefRes, {'RV192', '0192'}) ; aAdd(aRefRes, {'RV193', '0193'})
       aAdd(aRefRes, {'RV194', '0194'}) ; aAdd(aRefRes, {'RV195', '0195'}) ; aAdd(aRefRes, {'RV198', '0198'})
       aAdd(aRefRes, {'RV719', '0719'})
       nPos := aScan(aRefRes, {|x| Alltrim(x[2]) = Alltrim(cCodRes)})
       
       cQry1 := ""
       If !nPos == 0
          If aScan(aSolvent, {|x| x[1] = aRefRes[nPos][1]}) == 0
             cQry1 += "SELECT SG1.G1_COMP AS COMPONENTE, SB1.B1_DESC AS DESCRICAO, SG1.G1_PERC AS PERVOL, (SG1.G1_PERC / SB1.B1_PESOESP) AS DENSOL "
             cQry1 += "FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "
             cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON SG1.G1_FILIAL = SB1.B1_FILIAL AND SG1.G1_COMP = SB1.B1_COD AND SB1.D_E_L_E_T_ = '' "
             cQry1 += "WHERE SG1.G1_FILIAL  = '04' " // Sempre Filial 04 para pegar fórmula da Resina
             cQry1 += "  AND SG1.D_E_L_E_T_ = '' "
             cQry1 += "  AND SG1.G1_COD = '"+aRefRes[nPos][1]+"' " //Código da Resina
             cQry1 += "  AND SB1.B1_GRUPO = '"+Alltrim(GETMV("MV_GRPSOLV"))+"' " // Sempre Grupo 0003 para pegar Solventes
             cQry1 += "ORDER BY SG1.G1_COMP "
             TCQuery cQry1 ALIAS "CAL" NEW

             DbSelectArea("CAL")
             DbGoTop()
             While !Eof()
                   aadd(aSolvent, { aRefRes[nPos][1], CAL->COMPONENTE, CAL->DESCRICAO, CAL->PERVOL, CAL->DENSOL })
                   nPerVol += CAL->PERVOL
                   nDenSol += CAL->DENSOL
                   DbSelectArea("CAL")
                   DbSkip()
             Enddo
             DbSelectArea("CAL")
             DbCloseArea()
          Else
             For nX := 1 To Len(aSolvent)
                 If aSolvent[nX][1] == aRefRes[nPos][1]
                    nPerVol += aSolvent[nX][4]
                    nDenSol += aSolvent[nX][5]
                 Endif
             Next
          Endif
          nPesEsp := Posicione("SB1", 1, xFilial("SB1")+cCodRes, "B1_PESOESP")
          aResina[Len(aResina)][06] := (100 - nPerVol)                              // V
          aResina[Len(aResina)][07] := nPerVol                                      // 
          aResina[Len(aResina)][08] := (nPerVol / nDenSol)                          // Ds
          aResina[Len(aResina)][09] := (200 + (aResina[Len(aResina)][08] * 100))    // K
          aResina[Len(aResina)][10] := (200 + (nPesEsp * 100))                      // F
          aResina[Len(aResina)][11] := (aResina[Len(aResina)][06] * aResina[Len(aResina)][08]) / (aResina[Len(aResina)][06] + aResina[Len(aResina)][09] - aResina[Len(aResina)][10])
          If Empty(aResina[Len(aResina)][14])
             aResina[Len(aResina)][12] := (nPerFor * aResina[Len(aResina)][06]) / 100
          Else
             aResina[Len(aResina)][12] := ((aResina[Len(aResina)][15] * nPerFor) / 100) * (aResina[Len(aResina)][06] / 100)
          Endif
          aResina[Len(aResina)][13] := aResina[Len(aResina)][12] / aResina[Len(aResina)][11]
       Endif
Return()

/************************************************************************************************/
/*** FBUSPAS - Busca informações das pastas                                                   ***/
/************************************************************************************************/
Static Function fBusPas(cCodPas, nPerPas, cSeq, aPigmen, aResina, aSolvent)
       Local cQry1   := ""
       Local cAlias  := 'PAS'+cSeq
       Local aAuxRes := {}
       Local nX
       Local _cGRPADIT := GETMV("MV_GRPADIT") //LGS#20200207 - Adequação de release 12.1.25 e posteriores
       Local _cGRPPIGM := GETMV("MV_GRPPIGM") //LGS#20200207 - Adequação de release 12.1.25 e posteriores
       Local _cGRPCARG := GETMV("MV_GRPCARG") //LGS#20200207 - Adequação de release 12.1.25 e posteriores
       Local _cGRPPAST := GETMV("MV_GRPPAST") //LGS#20200207 - Adequação de release 12.1.25 e posteriores

       cQry1 := ""
       cQry1 += "SELECT SG1.G1_COMP, SB1.B1_TIPO, SG1.G1_PERC, SB1.B1_PESOESP, SB1.B1_GRUPO "
       cQry1 += "FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON SG1.G1_FILIAL = SB1.B1_FILIAL AND SG1.G1_COMP = SB1.B1_COD AND SB1.D_E_L_E_T_ = '' "
       cQry1 += "WHERE SG1.G1_FILIAL  = '"+XFILIAL("SG1")+"' "
       cQry1 += "  AND SG1.D_E_L_E_T_ = '' "
       cQry1 += "  AND SG1.G1_COD = '"+cCodPas+"' "
       cQry1 += "ORDER BY SG1.G1_TRT "
       TCQuery cQry1 ALIAS &cAlias NEW

       DbSelectArea(cAlias)
       DbGoTop()
       While !Eof()
             If (cAlias)->B1_TIPO $ 'MP'
                //LGS#20200207 - Adequação de release 12.1.25 e posteriores
                //If (cAlias)->B1_GRUPO $ Alltrim(GETMV("MV_GRPADIT")) //aditivos
                If (cAlias)->B1_GRUPO $ Alltrim( _cGRPADIT ) //aditivos
                   If aScan(aAuxRes, {|x| x[1] = (cAlias)->G1_COMP}) == 0
                      aadd(aAuxRes, {(cAlias)->G1_COMP, (cAlias)->G1_PERC, (cAlias)->B1_PESOESP})
                   Else
                      aAuxRes[aScan(aAuxRes, {|x| x[1] = (cAlias)->G1_COMP})][02] += (cAlias)->G1_PERC
                   Endif
                //LGS#20200207 - Adequação de release 12.1.25 e posteriores
                //ElseIf (cAlias)->B1_GRUPO $ Alltrim(GETMV("MV_GRPPIGM")) .or. (cAlias)->B1_GRUPO $ Alltrim(GETMV("MV_GRPCARG")) //Pigmentos e cargas
                ElseIf (cAlias)->B1_GRUPO $ Alltrim( _cGRPPIGM ) .or. (cAlias)->B1_GRUPO $ Alltrim( _cGRPCARG ) //Pigmentos e cargas
                       aadd(aPigmen, {'PIG', 'I', (cAlias)->G1_COMP, (cAlias)->G1_PERC, (cAlias)->B1_PESOESP, 0, fBusAbs((cAlias)->G1_COMP), 0, 0, 0, 0, (((cAlias)->G1_PERC * nPerPas) / 100), ((((cAlias)->G1_PERC * nPerPas) / 100) / (cAlias)->B1_PESOESP), cCodPas, nPerPas, ""} )
                Endif
             ElseIf (cAlias)->B1_TIPO $ 'PI'
                    //LGS#20200207 - Adequação de release 12.1.25 e posteriores
                    //If (cAlias)->B1_GRUPO $ Alltrim(GETMV("MV_GRPPAST"))
                    If (cAlias)->B1_GRUPO $ Alltrim( _cGRPPAST )
                       //fBusPas( (cAlias)->G1_COMP, (cAlias)->G1_PERC, '01', StrZero((Val(cSeq)+1), 2), @aPigmen, @aResina, @aSolvent )
                       fBusPas( (cAlias)->G1_COMP, (cAlias)->G1_PERC, '01', @aPigmen, @aResina, @aSolvent )
                    Endif 
             Endif
             DbSelectArea(cAlias)
             DbSkip()
       Enddo
       DbSelectArea(cAlias)
       DbCloseArea()
       For nX := 1 TO Len(aAuxRes)
           aadd(aResina, {'RES', 'I', aAuxRes[nX][1], aAuxRes[nX][2], aAuxRes[nX][3], 0, 0, 0, 0, 0, 0, 0, 0, cCodPas, nPerPas, ""})
           fCalVol(1, aAuxRes[nX][1], @aSolvent, @aResina, aAuxRes[nX][2]) //Busca Solventes da Resina
       Next
Return

/************************************************************************************************/
/*** FBUSABS - Busca informações de absorção em óleo do pigmento                              ***/
/************************************************************************************************/
Static Function fBusAbs(cCodPig)
       Local cQry1   := ""
       Local nValAbs := 0
       
       cQry1 := "" 
       cQry1 += "SELECT ISNULL(QE7.QE7_NOMINA, '0') AS NOMINAL "
       cQry1 += "FROM "+RetSqlName("QE7")+" QE7 WITH (NOLOCK) "
       cQry1 += "WHERE QE7.QE7_FILIAL = '"+xFilial("QE7")+"' "
       cQry1 += "  AND QE7.QE7_PRODUT = '"+cCodPig+"' "
       cQry1 += "  AND QE7.QE7_ENSAIO = 'ENSABO01' " //Sempre utilizar esse ensaio que é o de absorção de óleo
       cQry1 += "  AND QE7.QE7_REVI   = '"+QA_ULTRV(cCodPig, ,.f.)+"' "
       TCQuery cQry1 ALIAS "CAL" NEW
       
       DbSelectArea("CAL")
       nValAbs := Val(CAL->NOMINAL)
       DbSelectArea("CAL")
       DbCloseArea()
       
Return(nValAbs)

User Function INCPAD(nOpc)
     Local _Ret, nY
     //Local nPosCodi := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_COMP" } )
     
     If nOpc == 1
        _Ret := 0
        For nY := 1 To Len(aCols)
            If Len(Alltrim(M->ZM_CODIGO)) == 12
               If SubStr(Alltrim(M->ZM_CODIGO), 11, 2) $ '00.99'
                  _Ret := 1
               Else
                  _Ret := 0
               Endif 
            Else
               _Ret := 1
            Endif
        Next
     Endif
Return(_Ret)
