#include "protheus.ch"
#include "topconn.ch" 
#include 'font.ch'
#xtranslate bsetget(<uvar>) => { | u | If( PCount() == 0, <uvar>, <uvar> := u ) }
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BRFATA02 ³ Autor ³                       ³ Data ³16/07/2007³±±                  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³ Desenvolvimento  ³Contato ³                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Bordero de Pedidos Aprovados                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Brasilux Tintas Técnicas LTDA.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Bops ³ Manutencao Efetuada                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³  /  /  ³      ³                                        ³±±
±±³              ³  /  /  ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function BRFATA02()
    Private oTempTb0l
    Private cRotina   := "BRFATA02  "
    Private cAcessos  := Posicione("SZW", 4, xFilial("SZW")+cRotina+__cUserID+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2), "ZW_ACESSOS")
    Private cAliasMB  := "SZF"
    Private aRotina   := {}
    Private cCadastro := "Cadastro de Bordero de Pedidos"
    Private aTroBor   := {}

	If PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) != 0
     	If !SubStr(cAcessos, 1, 1) $ '*'
        	MsgStop('Usuário sem acesso. Consulte o Administrador do Sistema!')
        	Return
     	Endif 
 	else   
 		//Cleber (05/06/14) ->Administradores têm acesso irrestrito
 		cAcessos := "********"
 	endif 


     aAdd(aRotina, { OemToAnsi("Pesquisar" 				), 'AxPesqui       ', 0, 1})
     aAdd(aRotina, { OemToAnsi("Visualizar"				), 'u_FATA02_2     ', 0, 2})
     aAdd(aRotina, { OemToAnsi("Incluir"   				), 'u_FATA02_2     ', 0, 3})
     aAdd(aRotina, { OemToAnsi("Alterar"   				), 'u_FATA02_2     ', 0, 4})
     aAdd(aRotina, { OemToAnsi("Excluir"   				), 'u_FATA02_2     ', 0, 5})
     aAdd(aRotina, { OemToAnsi("Atualiza Status" 		), 'u_FATA02_9     ', 0, 6})
	 
     If GETMV("MV_QUALCON") == 1
        aAdd(aRotina, { OemToAnsi("Consultar I" ), 'u_FATA03_3("M")', 0, 9}) //Não revisado no periodo de 07/07
     ElseIf GETMV("MV_QUALCON") == 2
            aadd(aRotina, { OemToAnsi('Consultar II'), 'u_FATA03_A("M")', 0, 9 } )
     Else
        aAdd(aRotina, { OemToAnsi("Consultar I" ), 'u_FATA03_3("M")', 0, 9}) //Não revisado no periodo de 07/07
        aadd(aRotina, { OemToAnsi('Consultar II'), 'u_FATA03_A("M")', 0, 9 } )
     Endif
     If SUBSTR(cNumEmp,3,2) ='06'
	     If SubStr(cAcessos, 2, 1) $ '*'
    	    aAdd(aRotina, { OemToAnsi("Endereçamento") , 'u_FATA02_5()     ', 0, 9} )
        	aAdd(aRotina, { OemToAnsi("End. Bord. Espec.") , 'u_FATA02_A()   ', 0, 9} )
	     Endif
    	 If SubStr(cAcessos, 3, 1) $ '*'
	        aAdd(aRotina, { OemToAnsi('Retirada')      , 'u_FATA03_5("1")', 0, 9} ) //Não revisado no periodo de 07/07
    	 Endif
	     If SubStr(cAcessos, 4, 1) $ '*'
    	    aAdd(aRotina, { OemToAnsi('Baixa Retirada'), 'u_FATA03_5("2")', 0, 9} ) //Não revisado no periodo de 07/07
	     Endif
     Endif
     If SubStr(cAcessos, 5, 1) $ '*'
        aAdd(aRotina, { OemToAnsi('Monta Despacho'), 'u_FATA02_7()   ', 0, 9} )
        //aAdd(aRotina, { OemToAnsi('LIBERA BORDERO'), 'U_BRFATLIBEST("007642",1,1,"")   ', 0, 9} )
   //     aAdd(aRotina, { OemToAnsi('Re-Monta Pedidos'), 'u_FATA02_8() ', 0, 9} ) // Remonta Borderô de Pedidos
     Endif
     If Substr(cAcessos, 6, 1) $ '*'
	 	aadd(aRotina,    { OemToAnsi('Transfere Bordero'), 'u_TransfBorPed() ', 0 , 9 } )
	 	aadd(aRotina,    { OemToAnsi('Sequenciador Endereço'), 'u_BrSeqBord() ', 0 , 9 } )
	 Endif
     If SubStr(cAcessos, 7, 1) $ '*'
        aAdd(aRotina, { OemToAnsi('Baixa Retirada Bord Bipado'), 'u_BxRetBipe()', 0, 9} ) //Gerar relatório de Faltas para bordero monta compra
     Endif
     If SubStr(cAcessos, 8, 1) $ '*'
		aAdd(aRotina, { OemToAnsi('Reprocessa Faltas Pedido'), 'u_BRRepFal()', 0, 9} ) //Reprocessa relatório de faltas pra um determinado pedido
     Endif
       
     aAdd(aRotina, { OemToAnsi("Voltar")        , 'u_FATA02_Z()   ', 0, 9} )
     aAdd(aRotina, { OemToAnsi("Legenda")       , 'u_FATA02_1()   ', 0, 9} )

     Private aCores    := { { 'SZF->ZF_FLAG == "D"', 'ENABLE'     },; //D - Bordero digitado
  							{ 'SZF->ZF_FLAG == "Y"', 'BR_MARRON'  },; //Y - Baixa Retirada
   							{ 'SZF->ZF_FLAG == "X"', 'BR_LARANJA' },; //X - Destinado Totalmente     
    						{ 'SZF->ZF_FLAG == "Z"', 'BR_BRANCO'  } } //Z - Totalmente Bipado
                            
                            //{ 'SZF->ZF_FLAG == "E"', 'BR_AMARELO' },; //E - Endereçado
                            //{ 'SZF->ZF_FLAG == "P"', 'BR_AZUL'    },; //P - Parcialmente retirado
                            //{ 'SZF->ZF_FLAG == "T"', 'DISABLE'    },; //T - Totalmente separado
                            //{ 'SZF->ZF_FLAG == "R"', 'BR_PRETO'   },; //R - Totalmente destinado

     Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

     DbSelectArea(cAliasMB)
     DbSetOrder(1)
     DbGoTop()

     mBrowse(06, 01, 22, 75, cAliasMB, , , , , , aCores)

Return

/******************************************************************************************************************/
/*** FATA02_1 - Mostra a legenda com cores correspondentes.                                                     ***/
/******************************************************************************************************************/
User Function FATA02_1()

     BrwLegenda(cCadastro, "Status",{ {"ENABLE"     ,"Digitado"                  } ,;
                                      {"BR_MARRON"  ,"Compl. do Bipe na Rampa"   } ,;
                                      {"BR_LARANJA" ,"Totalmente Destinado"      } ,;
                                      {"BR_BRANCO"  ,"Totalmente Dest e Bipado"  } })                                      

                                   // {"BR_AMARELO" ,"Endereçado"                } ,;
                                   // {"BR_AZUL"    ,"Parcialmente Retirado"     } ,;
                                  //  {"DISABLE"    ,"Totalmente Retirado"       } ,;
                                  //    {"BR_PRETO"   ,"Totalmente Destinado"      } ,;
Return(.t.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ FATA02_2 ³ Autor  ³ Luís Gustavo de Souza  ³ Data ³16/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Manutenções no Bordero de pedidos                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function FATA02_2(cAlias, nReg, nOpcX)
     // Variaveis Locais da Funcao
     Local cAliasE      := "SZF"  // Tabela cadastrada no Dicionario de Tabelas (SX2) que sera editada
     Local nOpcA        := 0
     // Vetor com nome dos campos que serao exibidos. Os campos de usuario sempre serao
     // exibidos se nao existir no parametro um elemento com a expressao "NOUSER"
     Local aCpoEnch     := {"ZF_CODIGO", "ZF_EMISSAO", "ZF_DATAINI", "ZF_HORAINI", "ZF_DATAFIM", "ZF_HORAFIM", "ZF_TIPOBOR"}
     Local aAlterEnch   := {"ZF_EMISSAO", "ZF_TIPOBOR"}  // Vetor com nome dos campos que poderao ser editados
     Local nOpc         := nOpcX // Numero da linha do aRotina que definira o tipo de edicao (Inclusao, Alteracao, Exclucao, Visualizacao)
     // Vetor com coordenadas para criacao da enchoice no formato {<top>, <left>, <bottom>, <right>}
     Local aPos         := {C(024), C(000), C(070), C(363)}
     Local nModelo      := 3     // Se for diferente de 1 desabilita execucao de gatilhos estrangeiros
     Local lF3          := .F.   // Indica se a enchoice esta sendo criada em uma consulta F3 para utilizar variaveis de memoria
     Local lMemoria     := .T.   // Indica se a enchoice utilizara variaveis de memoria ou os campos da tabela na edicao
     Local lColumn      := .F.   // Indica se a apresentacao dos campos sera em forma de coluna
     Local caTela       := ""    // Nome da variavel tipo "private" que a enchoice utilizara no lugar da propriedade aTela
     Local lNoFolder    := .F.   // Indica se a enchoice nao ira utilizar as Pastas de Cadastro (SXA)
     Local lProperty    := .T.   // Indica se a enchoice nao utilizara as variaveis aTela e aGets, somente suas propriedades com os mesmos nomes
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Termino das variveis da Enchoice   ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     // Defina aqui os Botoes da sua EnchoiceBar
     // Exemplo: Aadd(aButtons,{"USER", {|| Alert("Inclua a Acao")}, "Contatos"})
     Local ocPesBor
     Local ocVolBor
     Local aButtons     := {}
     // Variaveis da Funcao de Controle e GertArea/RestArea
     Local _aArea       := {}
     Local _aAlias      := {}
     Local nY           := 0
     // Variaveis Private da Funcao
     Private _oDlg  // Dialog Principal
     // Variaveis que definem a Acao escolhida na MBrowse
     Private VISUAL := (nOpcX == 2)
     Private INCLUI := (nOpcX == 3)
     Private ALTERA := (nOpcX == 4)
     Private DELETA := (nOpcX == 5)

     // Privates das NewGetDados
     Private oGetDados1
     Private nPesBor := 0
     Private nVolBor := 0
     Private onPesBor
     Private onVolBor

     If ALTERA .or. DELETA
        If SZF->ZF_FLAG $ 'E.P.T.R.Y.Z.X'
           MsgStop("Não pode ser feita manutenção nesse bordero!")
           Return
        Endif
        If SZF->ZF_TIPOBOR == ''
			MsgStop("Escolher o tipo de Bordero (Depósito, Retira-Região ou Exportação!!!")        
        Endif
     Endif
     DEFINE MSDIALOG _oDlg TITLE "Bordero de Pedidos Aprovados" FROM C(228),C(241) TO C(655),C(970) PIXEL
     DEFINE FONT oFont NAME "Courier New" SIZE 0, 20 BOLD
            // Defina aqui a chamada dos Aliases para o GetArea
            CtrlArea(1, @_aArea, @_aAlias, {"SZF", "SZG"}) // GetArea

            @ C(199), C(000) Say   ocPesBor Var "Peso:"                              Size C(030), C(008) COLOR CLR_BLACK           PIXEL OF _oDlg FONT oFont
            @ C(198), C(035) MsGet onPesBor Var nPesBor      Picture '@E 9999999.99' Size C(065), C(009) COLOR CLR_HBLUE  WHEN .F. PIXEL OF _oDlg FONT oFont
            @ C(199), C(120) Say   ocVolBor Var "Volume: "                           Size C(030), C(008) COLOR CLR_BLACK           PIXEL OF _oDlg FONT oFont
            @ C(198), C(165) MsGet onVolBor Var nVolBor      Picture '@E 9999999'    Size C(065), C(009) COLOR CLR_HBLUE  WHEN .F. PIXEL OF _oDlg FONT oFont

            // Chamadas da Enchoice do Sistema
            // INCLUI = True  --> Traz Enchoice vazia pronta para Inclusao
            // INCLUI = False --> Traz Enchoice com o Registro definido pela variavel nReg
            RegToMemory(cAliasE, INCLUI, .F.)
            If INCLUI .or. ALTERA
           	   M->ZF_EMISSAO := dDataBase
            Endif
            Enchoice(cAliasE, nReg, nOpc, /*aCRA*/, /*cLetra*/, /*cTexto*/, aCpoEnch, aPos, aAlterEnch, nModelo, /*nColMens*/, /*cMensagem*/, /*cTudoOk*/, _oDlg, lF3, lMemoria, lColumn, caTela, lNoFolder, lProperty)

            // Chamadas das GetDados do Sistema
            fGetDados1(nOpcX)

            CtrlArea(2, _aArea, _aAlias) // RestArea
     //ACTIVATE MSDIALOG _oDlg CENTERED  ON INIT EnchoiceBar(_oDlg, {||nOpcA := 1}, {|| _oDlg:End()},, aButtons)
	 ACTIVATE MSDIALOG _oDlg CENTERED  ON INIT EnchoiceBar(_oDlg, {||nOpcA := 1, _oDlg:End()}, {|| _oDlg:End()},, aButtons)
     If nOpcA == 1
        nQtdIte := 0
        If Len(oGetDados1:aCols) > 0 .AND. !Empty(oGetDados1:aCols[1][1])
           If INCLUI .or. ALTERA
              If Empty(Alltrim(M->ZF_TIPOBOR))
			  	MsgStop("Atenção, Tipo de Bordero Vazio, verifique antes de prosseguir !!!")
			  	Return              
              Endif 
              If INCLUI
                 cCodBor := U_NumSeqLot("SZF")
              Else
                 cCodBor := SZF->ZF_CODIGO
              Endif
              For nY := 1 To Len(oGetDados1:aCols)
                  If ALTERA
                     DbSelectArea("SZG")
                     DbSetOrder(1)
                     DbSeek(xFilial("SZG")+SZF->ZF_CODIGO+oGetDados1:aCols[nY][NwFieldPos(oGetDados1, "ZG_PEDIDO")], .t.)
                     If Found()
                        RecLock("SZG", INCLUI)
                           If !NwDeleted(oGetDados1, nY)
                              SZG->ZG_PEDIDO  := oGetDados1:aCols[nY][NwFieldPos(oGetDados1, "ZG_PEDIDO")]
                              SZG->ZG_LOCALIZ := oGetDados1:aCols[nY][NwFieldPos(oGetDados1, "ZG_LOCALIZ")]
                              nQtdIte += 1
                           Else
                              DbDelete()
                           Endif
                        MsUnLock()
                     Else
                        If !NwDeleted(oGetDados1, nY)
                           RecLock("SZG", .T.)
                              SZG->ZG_FILIAL  := xFilial("SZG")
                              SZG->ZG_CODIGO  := cCodBor
                              SZG->ZG_PEDIDO  := oGetDados1:aCols[nY][NwFieldPos(oGetDados1, "ZG_PEDIDO")]
                              SZG->ZG_LOCALIZ := oGetDados1:aCols[nY][NwFieldPos(oGetDados1, "ZG_LOCALIZ")]
                              nQtdIte += 1
                           MsUnLock()
                        Endif
                     Endif
                  Else
                     If !NwDeleted(oGetDados1, nY)
                        RecLock("SZG", INCLUI)
                           SZG->ZG_FILIAL  := xFilial("SZG")
                           SZG->ZG_CODIGO  := cCodBor
                           SZG->ZG_PEDIDO  := oGetDados1:aCols[nY][NwFieldPos(oGetDados1, "ZG_PEDIDO")]
                           SZG->ZG_LOCALIZ := oGetDados1:aCols[nY][NwFieldPos(oGetDados1, "ZG_LOCALIZ")]
                           nQtdIte += 1
                        MsUnLock()
                     Endif
                  Endif
              Next
              If nQtdIte >= 1
                 RecLock("SZF", INCLUI)
                    If INCLUI
                       SZF->ZF_FILIAL := xFilial("SZF")
                       SZF->ZF_CODIGO := cCodBor
                       SZF->ZF_FLAG   := 'D'    
                    Endif
                    SZF->ZF_EMISSAO := M->ZF_EMISSAO
                    SZF->ZF_TIPOBOR := M->ZF_TIPOBOR
                 MsUnLock()
              Else
                 If INCLUI
                    MsgStop("Bordero não foi incluído!")
                 Else
                    RecLock("SZF", INCLUI)
                       DbDelete()
                    MsUnLock()
                    MsgStop("Bordero deletado!")
                 Endif
              Endif
           ElseIf DELETA
                  For nY := 1 To Len(oGetDados1:aCols)
                      DbSelectArea("SZG")
                      DbSetOrder(1)
                      DbSeek(xFilial("SZG")+SZF->ZF_CODIGO+oGetDados1:aCols[nY][NwFieldPos(oGetDados1, "ZG_PEDIDO")], .t.)
                      If Found()
                         RecLock("SZG", INCLUI)
                            DbDelete()
                         MsUnLock()
                      Endif
                  Next
                  RecLock("SZF", INCLUI)
                     DbDelete()
                  MsUnLock()
           Endif
        Else
           MsgStop("Bordero sem dados a ser incluido")
        Endif
     Endif
     //_oDlg:End()
     
Return(.T.)

/******************************************************************************************************************/
/*** FATA02_3 - Validação do pedido e da localização digitada pelo usuário.                                     ***/
/******************************************************************************************************************/
User Function FATA02_3(cOpcVal, cOpcTip, aTroBor)
     Local cAprova := ""
     Local lRet    := .t.
     Local aArea   := GetArea()
     //Local nRecN
     Local nNumOr
     Local cNumNot :=""
     Local nY      := 0
     If cOpcVal $ 'P' //Validação do Pedido
        //Não permitir inclusão de ped amostras (solic. Ramon)
/*        If U_BRTEMAMOSTRA(M->ZG_PEDIDO)
   	          lRet = .f.
       	      aCols[n][NwFieldPos(oGetDados1, 'ZG_PEDIDO')] := Space(08)
              M->ZG_PEDIDO                                  := ''
              Msgstop("Atenção, se trata de um pedido de amostra. Não misturar com pedidos normais!")
              Return(lRet)
       */ 
         If U_BrVerPed(M->ZG_PEDIDO,M->ZF_CODIGO)        
        	lRet = .f.                 
       	    aCols[n][NwFieldPos(oGetDados1, 'ZG_PEDIDO')] := Space(08)
            M->ZG_PEDIDO                                  := ''
            Msgstop("Atenção, divergência entre tipo de pedido (Depósito/Regiao-Retira/Exportação) e o tipo do bordero!")
         	Return(lRet)	    
	     Else
	     	DbSelectArea("SZG")
	    	nRecNo := RecNo()
    	    NumOr := IndexOrd()
		    DbSetOrder(2)
    		DbSeek(xFilial("SZG")+M->ZG_PEDIDO, .t.)
	        If Found() .and. (cOpcTip == "I") .and. (M->ZF_CODIGO # SZG->ZG_CODIGO)
		    	If SZG->ZG_CODIGO $ '000000'
    		    	aAdd(aTroBor, {'000000', space(06)})
        		    MsgStop("Pedido será trocado de bordero no final do processo")
		         Else
    		        lRet = .f.
        		    aCols[n][NwFieldPos(oGetDados1, 'ZG_PEDIDO')] := Space(08)
	            	M->ZG_PEDIDO                                  := Space(08)
		            MsgStop("Pedido já digitado anteriormente!")
    		     Endif
	        	 Return(lRet)
		    Endif
    	
	    	DbSetOrder(nNumOr)
    	    DbGoto(nRecNo)

	     Endif 
	     
	     For nY := 1 To Len(aCols)
    	 	If !NwDeleted(oGetDados1, nY)
        		If nY <> n
	            	If aCols[nY][NwFieldPos(oGetDados1, 'ZG_PEDIDO')] == M->ZG_PEDIDO
    	            	lRet := .f.
        	            aCols[n][NwFieldPos(oGetDados1, 'ZG_PEDIDO')] := Space(08)
            	        M->ZG_PEDIDO                                  := Space(08)
                	    MsgStop("Pedido já digitado nesse bordero!")
	                    Return(lRet)
    	            Endif
        	    Endif
          	Endif
         Next      
    	 
    	 cAprova := Posicione("SC5", 1, xFilial("SC5")+SUBSTR(M->ZG_PEDIDO,3,6), "C5_APROVA") //Posicione("SC5", 1, M->ZG_PEDIDO, "C5_APROVA")
	     If cAprova != "1"
    	 	lRet := .f.
        	aCols[n][NwFieldPos(oGetDados1, 'ZG_PEDIDO')] := Space(08)
	        M->ZG_PEDIDO                                  := Space(08)
    	    MsgStop("Pedido NAO está Liberado!")
        	Return(lRet)
	     Else
    	 	If !Empty(Posicione("SC5", 1, xFilial("SC5")+SUBSTR(M->ZG_PEDIDO,3,6), "C5_NOTA"))
        		MsgStop("Pedido já foi faturado!")  
	            Return(lRet)
    	  	Endif
	        
	        DbSelectArea("SA1")
    	    DbSetOrder(1)
        	DbSeek(xFilial("SA1")+Posicione("SC5", 1, xFilial("SC5")+SUBSTR(M->ZG_PEDIDO,3,6), "C5_CLIENTE"), .t.)
	        If Found()
    	    	aCols[n][NwFieldPos(oGetDados1, 'ZG_RAZAO')] := Posicione("SA1", 1, xFilial("SA1")+SC5->C5_CLIENTE, "A1_NOME")
        	    M->ZG_RAZAO                                  := Posicione("SA1", 1, xFilial("SA1")+SC5->C5_CLIENTE, "A1_NOME")
	        Endif
    	    lRet := .t.
         Endif
	     nPesBor := 0
    	 nVolBor := 0
         For nY := 1 To Len(aCols)
	     	If !NwDeleted(oGetDados1, nY)
    	    	If n <> nY
        	    	nPesBor += Posicione("SC5", 1, xFilial("SZG")+Substr(aCols[nY][NwFieldPos(oGetDados1, 'ZG_PEDIDO')],3,6), "C5_PBRUTO")
            	    nVolBor += Posicione("SC5", 1, xFilial("SZG")+Substr(aCols[nY][NwFieldPos(oGetDados1, 'ZG_PEDIDO')],3,6), "C5_VOLUME1")
	            Else
    	            nPesBor += Posicione("SC5", 1, xFilial("SC5")+SUBSTR(M->ZG_PEDIDO,3,6), "C5_PBRUTO")
        	        nVolBor += Posicione("SC5", 1, xFilial("SC5")+SUBSTR(M->ZG_PEDIDO,3,6), "C5_VOLUME1")
	            Endif
    	    Endif
	     Next
     ElseIf cOpcVal $ 'L' //Validação da Localização
     	DbSelectArea("SC5")
        DbSetOrder(1)
        DbSeek(aCols[n][NwFieldPos(oGetDados1, 'ZG_PEDIDO')], .t.)
        If Found()
        	cNumNot := SC5->C5_NOTA
        Endif
        If !Empty(cNumNot)
        	cMsgNot := "        ATENÇÃO: Esse pedido está faturado!        "+chr(13)+chr(10)
            cMsgNot += "Verifique com a Expedição se o mesmo será retirado!"
            MsgStop(cMsgNot)
        Endif
        lRet := .t.
     Endif
     onPesBor:Refresh()
     onVolBor:Refresh()
     RestArea(aArea)
Return(lRet)

/******************************************************************************************************************/
/*** FATA02_4 - Validação da linha da GetDados da montagem do bordero de pedidos.                               ***/
/******************************************************************************************************************/
User Function FATA02_4()
     Local nY:= 0
        nPesBor := 0
        nVolBor := 0
        For nY := 1 To Len(aCols)
            If !NwDeleted(oGetDados1, nY)
               nPesBor += Posicione("SC5", 1, xFilial("SC5")+Substr(aCols[nY][NwFieldPos(oGetDados1, 'ZG_PEDIDO')],3,6), "C5_PBRUTO")
               nVolBor += Posicione("SC5", 1, xFilial("SC5")+Substr(aCols[nY][NwFieldPos(oGetDados1, 'ZG_PEDIDO')],3,6), "C5_VOLUME1")
            Endif
        Next
        onPesBor:Refresh()
        onVolBor:Refresh()

Return(.t.)

/******************************************************************************************************************/
/*** FATA02_5 - Endereçamento dos pedidos que estão contidos no bordero.                                        ***/
/******************************************************************************************************************/
User Function FATA02_5()
    /*
     If SZF->ZF_TIPOBOR $ '1.2' .OR. EMPTY(Alltrim(SZF->ZF_TIPOBOR))  // POR EQTO SÓ NÃO ENDEREÇA CARGA PRA SP
		MsgBox("Bordero não pode ser endereçado!", "Atenção", "STOP")
		Return
	 Endif        	
      */
     Processa({|| fEndBor()}, Iif(SZF->ZF_FLAG $ 'D', OemToAnsi("Endereçando pedidos..."), Iif(SZF->ZF_FLAG $ 'E', OemToAnsi("Estornando endereçando..."), OemToAnsi("Verificando alterações nos pedidos...")))  )
Return
     
     Static Function fEndBor()
            Local aArea := GetArea()
            Local nY    := 0

            ProcRegua(150)

            If SZF->ZF_FLAG $ 'D' //Permite endereçar.
               If SZF->ZF_CODIGO $ '000000'
                  Return()
               Endif
               DbSelectArea("SZG")
               DbSetOrder(1)
               DbSeek(xFilial("SZG")+SZF->ZF_CODIGO, .t.)
               If Found()
                  While !Eof() .and. SZG->ZG_CODIGO == SZF->ZF_CODIGO
                        cQry1 := ""
                        cQry1 += "SELECT SC6.C6_PRODUTO AS PRODUTO, SC6.C6_QTDVEN AS QUANTI, SC6.C6_VOLITEM AS VOLUME, SC6.C6_PALLET AS OCUPAC, '' AS DTHOT, 'B' AS TPINCL, '' AS LOCEXP, 0 AS RESERV "
                        cQry1 += "FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "
                        cQry1 += "WHERE SC6.C6_FILIAL  = '"+xFilial("SC6")+"' "
                        cQry1 += "  AND SC6.D_E_L_E_T_ = '' "
                        cQry1 += "  AND SC6.C6_NUM     = '"+SubStr(SZG->ZG_PEDIDO, 3, 6)+"' "
                        cQry1 += "ORDER BY SC6.C6_PRODUTO "
                        TCQuery cQry1 ALIAS "TCQSC6" NEW
                        DbSelectArea("TCQSC6")
                        DbGoTop()
                        While !Eof()
                              IncProc()
                              DbSelectArea("ZZC")
                              DbSetOrder(1)
                              DbSeek(xFilial("ZZC")+SZF->ZF_CODIGO+SubStr(SZG->ZG_PEDIDO, 3, 6)+TCQSC6->PRODUTO, .t.)
                              If Found()
                                 RecLock("ZZC", .f.)
                                    ZZC->ZZC_QUANTI := TCQSC6->QUANTI
                                    ZZC->ZZC_RETIRA := 0.0
                                    ZZC->ZZC_GAVETA := Space(03)
                                    ZZC->ZZC_VOLUME := TCQSC6->VOLUME
                                    ZZC->ZZC_VOLRET := 0.0
                                    ZZC->ZZC_CARGA  := Posicione("SZB", 2, xFilial("SZB")+SubStr(SZG->ZG_PEDIDO, 3, 6), "ZB_CODIGO")
                                    ZZC->ZZC_OCUPAC := TCQSC6->OCUPAC
                                    ZZC->ZZC_DESPAC := 'N'
                                    ZZC->ZZC_SEPARA := 'N'
                                    ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
                                    ZZC->ZZC_TPINCL := 'B'
                                 MsUnLock()
                              Else
                                 RecLock("ZZC", .t.)
                                    ZZC->ZZC_FILIAL := xFilial("ZZC")
                                    ZZC->ZZC_BORDER := SZF->ZF_CODIGO
                                    ZZC->ZZC_PEDIDO := SubStr(SZG->ZG_PEDIDO, 3, 6)
                                    ZZC->ZZC_PRODUT := TCQSC6->PRODUTO
                                    ZZC->ZZC_QUANTI := TCQSC6->QUANTI
                                    ZZC->ZZC_RETIRA := 0.0
                                    ZZC->ZZC_VOLUME := TCQSC6->VOLUME
                                    ZZC->ZZC_VOLRET := 0.0
                                    ZZC->ZZC_CARGA  := Posicione("SZB", 2, xFilial("SZB")+SubStr(SZG->ZG_PEDIDO, 3, 6), "ZB_CODIGO")
                                    ZZC->ZZC_OCUPAC := TCQSC6->OCUPAC
                                    ZZC->ZZC_GAVETA := Space(03)
                                    ZZC->ZZC_TPINCL := 'B'
                                    //ZZC->ZZC_DESPAC := 'N'
                                    //ZZC->ZZC_SEPARA := 'N'
                                    ZZC->ZZC_LOTE   := Space(06)
                                    ZZC->ZZC_SEMID  := Space(01)
                                    ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
                                    ZZC->ZZC_LOCEXP := Space(09)
                                    ZZC->ZZC_RESERV := 0.0
                                 MsUnLock()
                              Endif
                              DbSelectArea("TCQSC6")
                              DbSkip()
                        Enddo
                        DbSelectArea("TCQSC6")
                        DbCloseArea()
                        DbSelectArea("SZG")
                        DbSkip()
                  Enddo
               Endif
               DbSelectArea("SZF")
               RecLock("SZF", .f.)
                  SZF->ZF_FLAG := 'E'
               MsUnLock()
            ElseIf SZF->ZF_FLAG $ 'E' //Estorna Endereçamento.
                   If !MsgYesNo("Confirma estorno do endereçamento ?", "Pergunta...")
                      Return
                   Endif
                   If SZF->ZF_CODIGO $ '000000'
                      Return()
                   Endif
                   /*
                   DbSelectArea("ZZC")
                   DbSetOrder(1)
                   DbSeek(xFilial("ZZC")+SZF->ZF_CODIGO, .t.)
                   If Found()
                      While !Eof() .and. (ZZC->ZZC_FILIAL == xFilial("ZZC")) .AND. (ZZC->ZZC_BORDER == SZF->ZF_CODIGO)
                            IncProc()
                            If Empty(ZZC->ZZC_CARGA)
                               RecLock("ZZC", .f.)
                                  DbDelete()
                               MsUnLock()
                            Endif
                            DbSelectArea("ZZC")
                            DbSkip()
                      Enddo
                   Endif */
                   RecLock("SZF", .f.)
                      SZF->ZF_FLAG := 'D'
                   MsUnLock()
            ElseIf SZF->ZF_FLAG $ 'P.T.R' //Busca alterações de pedidos.
                   If SZF->ZF_CODIGO $ '000000'
                      Return()
                   Endif
                   If !MsgYesNo("Confirma busca de pedidos com alteração?", "Pergunta...")
                      Return
                   Endif
                   DbSelectArea("SZG")
                   DbSetOrder(1)
                   DbSeek(xFilial("SZG")+SZF->ZF_CODIGO, .T.)
                   If Found()
                      While !Eof() .and. SZG->ZG_CODIGO == SZF->ZF_CODIGO
                            //Busca dados da Tabela de Endereçada
                            cQry1 := ""
                            cQry1 += "SELECT * "
                            cQry1 += "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
                            cQry1 += "WHERE ZZC.ZZC_FILIAL = '"+xFilial("ZZC")+"' "
                            cQry1 += "  AND ZZC.D_E_L_E_T_ = '' "
                            cQry1 += "  AND ZZC.ZZC_BORDER = '"+SZF->ZF_CODIGO+"' "
                            cQry1 += "  AND ZZC.ZZC_PEDIDO = '"+SubStr(SZG->ZG_PEDIDO, 3, 6)+"' "
                            cQry1 += "ORDER BY ZZC.ZZC_PEDIDO "
                            TCQuery cQry1 ALIAS "TCQZZC" NEW
                            DbSelectArea("TCQZZC")
                            DbGoTop()
                            aMatCom := {}
                            While !Eof()
                                  aAdd(aMatCom, {TCQZZC->ZZC_PEDIDO, TCQZZC->ZZC_PRODUT, TCQZZC->ZZC_QUANTI, TCQZZC->ZZC_VOLUME, TCQZZC->ZZC_DESPAC, ''})
                                  DbSelectArea("TCQZZC")
                                  DbSkip()
                            Enddo
                            DbSelectArea("TCQZZC")
                            DbCloseArea()
                            //Busca dados da Tabela de Pedidos
                            aMatSC6 := {}
                            cQry1 := ""
                            cQry1 += "SELECT SC6.C6_PRODUTO, SC6.C6_QTDVEN, SC6.C6_NUM, SC6.C6_VOLITEM, SC6.C6_PALLET "
                            cQry1 += "FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "
                            cQry1 += "WHERE (SC6.C6_FILIAL  = '"+xFilial("SC6")+"') "
                            cQry1 += "  AND SC6.D_E_L_E_T_ = '' "
                            cQry1 += "  AND SC6.C6_NUM     = '"+SubStr(SZG->ZG_PEDIDO, 3, 6)+"' "
                            cQry1 += "ORDER BY SC6.C6_NUM "
                            TCQuery cQry1 ALIAS "TCQSC6" NEW
                            DbSelectArea("TCQSC6")
                            DbGoTop()
                            While !Eof()
                                  IncProc()
                                  aAdd(aMatSC6, {TCQSC6->C6_NUM, TCQSC6->C6_PRODUTO, TCQSC6->C6_QTDVEN, TCQSC6->C6_VOLITEM, TCQSC6->C6_PALLET})
                                  DbSelectArea("TCQSC6")
                                  DbSkip()
                            Enddo
                            DbSelectArea("TCQSC6")
                            DbCloseArea()
                            For nY := 1 To Len(aMatCom)
                                If aScan(aMatSC6, {|x| x[2] == aMatCom[nY][2]}) > 0 //Encontrou Produto
                                   //Verificar se houve alteração nas quantidades
                                   If aMatCom[nY][3] <> aMatSC6[aScan(aMatSC6, {|x| x[2] == aMatCom[nY][2]})][3] .and. aMatCom[nY][5] <> 'S'
                                      //Ajustar quantidade
                                      DbSelectArea("ZZC")
                                      DbSetOrder(1)
                                      DbSeek(xFilial("ZZC")+SZF->ZF_CODIGO+aMatSC6[aScan(aMatSC6, {|x| x[2] == aMatCom[nY][2]})][1]+aMatSC6[aScan(aMatSC6, {|x| x[2] == aMatCom[nY][2]})][2], .t.)
                                      If Found()
                                         RecLock("ZZC", .f.)
                                            ZZC->ZZC_QUANTI := aMatSC6[aScan(aMatSC6, {|x| x[2] == aMatCom[nY][2]})][3]
                                            ZZC->ZZC_VOLUME := aMatSC6[aScan(aMatSC6, {|x| x[2] == aMatCom[nY][2]})][4]
                                            ZZC->ZZC_OCUPAC := aMatSC6[aScan(aMatSC6, {|x| x[2] == aMatCom[nY][2]})][5]
                                            ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
                                            ZZC->ZZC_GAVETA := Iif(Empty(ZZC->ZZC_GAVETA), '999', ZZC->ZZC_GAVETA)
                                            ZZC->ZZC_SEPARA := Iif(ZZC->ZZC_QUANTI == ZZC->ZZC_RETIRA, 'S', 'N')
                                         MsUnLock()
                                      Endif
                                   Endif
                                Else //Não encontrou o produto
                                     //Incluir na Tabela de faltas
                                     DbSelectArea("ZZC")
                                     DbSetOrder(1)
                                     DbSeek(xFilial("ZZC")+SZF->ZF_CODIGO+aMatCom[nY][1]+aMatCom[nY][2], .t.)
                                     If Found()
                                        RecLock("ZZC", .f.)
                                           DbDelete()
                                        MsUnLock()
                                        aMatCom[nY][6] := 'D'
                                     Endif
                                Endif
                            Next
                            nQtdDel := 0
                            For nY := 1 To Len(aMatCom)
                                If !Empty(aMatCom[nY][6])
                                   aDel(aMatCom, nY)
                                   nQtdDel += 1
                                Endif
                            Next
                            aSize(aMatCom, (Len(aMatCom) - nQtdDel) )
                            For nY := 1 To Len(aMatSC6)
                                If aScan(aMatCom, {|x| x[2] == aMatSC6[nY][2]}) > 0 //Encontrou Produto
                                   If aMatCom[nY][3] <> aMatSC6[aScan(aMatSC6, {|x| x[2] == aMatCom[nY][2]})][3] .and. aMatCom[nY][5] <> 'S'
                                      //Ajustar quantidade
                                      DbSelectArea("ZZC")
                                      DbSetOrder(1)
                                      DbSeek(xFilial("ZZC")+SZF->ZF_CODIGO+aMatSC6[aScan(aMatSC6, {|x| x[2] == aMatCom[nY][2]})][1]+aMatSC6[aScan(aMatSC6, {|x| x[2] == aMatCom[nY][2]})][2], .t.)
                                      If Found()
                                         RecLock("ZZC", .f.)
                                            ZZC->ZZC_QUANTI := aMatSC6[aScan(aMatSC6, {|x| x[2] == aMatCom[nY][2]})][3]
                                            ZZC->ZZC_VOLUME := aMatSC6[aScan(aMatSC6, {|x| x[2] == aMatCom[nY][2]})][4]
                                            ZZC->ZZC_OCUPAC := aMatSC6[aScan(aMatSC6, {|x| x[2] == aMatCom[nY][2]})][5]
                                            ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
                                            ZZC->ZZC_GAVETA := Iif(Empty(ZZC->ZZC_GAVETA), '999', ZZC->ZZC_GAVETA)
                                            ZZC->ZZC_SEPARA := Iif(ZZC->ZZC_QUANTI == ZZC->ZZC_RETIRA, 'S', 'N')
                                         MsUnLock()
                                      Endif
                                   Endif
                                Else //Não encontrou o produto
                                     RecLock("ZZC", .t.)
                                        ZZC->ZZC_FILIAL := xFilial("ZZC")
                                        ZZC->ZZC_BORDER := SZF->ZF_CODIGO
                                        ZZC->ZZC_PEDIDO := SubStr(SZG->ZG_PEDIDO, 3, 6)
                                        ZZC->ZZC_PRODUT := aMatSC6[nY][2]
                                        ZZC->ZZC_QUANTI := aMatSC6[nY][3]
                                        ZZC->ZZC_RETIRA := 0.0
                                        ZZC->ZZC_GAVETA := Space(03)
                                        ZZC->ZZC_VOLUME := aMatSC6[nY][4]
                                        ZZC->ZZC_VOLRET := 0.0
                                        ZZC->ZZC_CARGA  := Posicione("SZB", 2, xFilial("SZB")+SubStr(SZG->ZG_PEDIDO, 3, 6), "ZB_CODIGO")
                                        ZZC->ZZC_OCUPAC := aMatSC6[nY][5]
                                        ZZC->ZZC_DESPAC := 'N'
                                        ZZC->ZZC_SEPARA := 'N'
                                        ZZC->ZZC_LOTE   := Space(06)
                                        ZZC->ZZC_SEMID  := Space(01)
                                        ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
                                        ZZC->ZZC_TPINCL := 'B'
                                        ZZC->ZZC_LOCEXP := Space(09)
                                        ZZC->ZZC_RESERV := 0.0
                                      MsUnLock()
                                Endif
                            Next
                            DbSelectArea("SZG")
                            DbSkip()
                      Enddo
                   Endif
            Endif
            RestArea(aArea)
Return

/******************************************************************************************************************/
/*** FATA02_6 - Validação da exclusão de itens do bordero de pedidos.                                           ***/
/******************************************************************************************************************/
User Function FATA02_6()
     Local nY := 0
     oGetDados1:aCols[n][Len(oGetDados1:aHeader)+1] := !NwDeleted(oGetDados1, n)
     nPesBor := 0
     nVolBor := 0
     For nY := 1 To Len(oGetDados1:aCols)
         If !NwDeleted(oGetDados1, nY)
            nPesBor += Posicione("SC5", 1, xFilial("SZG")+Substr(aCols[nY][NwFieldPos(oGetDados1, 'ZG_PEDIDO')],3,6), "C5_PBRUTO")
            nVolBor += Posicione("SC5", 1, xFilial("SZG")+Substr(aCols[nY][NwFieldPos(oGetDados1, 'ZG_PEDIDO')],3,6), "C5_VOLUME1")
         Endif
     Next
     onPesBor:Refresh()
     onVolBor:Refresh()
     oGetDados1:Refresh()
Return(.t.)

/******************************************************************************************************************/
/*** FATA02_7 - Monta despacho                                                                                  ***/
/******************************************************************************************************************/
User Function FATA02_7()
     // Variaveis Locais da Funcao
     // Variaveis da Funcao de Controle e GertArea/RestArea
     Local _aArea  := {}
     Local _aAlias := {}
     Local lRet    := .t.,nConTot,nConAdd
     If SZF->ZF_FLAG $ 'R'
        MsgStop("Bordero já foi totalmente destinado!")
        Return(.f.)
     Endif
     // Variaveis Private da Funcao
     Private _oDlg // Dialog Principal
     // Privates das ListBoxes
     Private aMonDes := {}
     Private oMonDes
     Private cPedFal := ''
     Private oPedFal
     oFont1 := TFont():New("Courier New"        , 7, 13, .F., .F.,  5, .F., 5, .F., .F.)
     DEFINE MSDIALOG _oDlg TITLE "Monta Despacho" FROM C(178), C(181) TO C(550), C(948) PIXEL
            // Defina aqui a chamada dos Aliases para o GetArea
            CtrlArea(1, @_aArea, @_aAlias, {"SZF", "SZG"}) // GetArea

            // Cria as Groups do Sistema
            @ C(112), C(001) TO C(187), C(385) LABEL "Itens Faltantes" PIXEL OF _oDlg

            // Cria Componentes Padroes do Sistema
            @ C(000), C(003) Button "Novo Bordero"      Size C(056), C(012) Action(fNewBor())   PIXEL OF _oDlg
            @ C(000), C(161) Button "Bordero Existente" Size C(056), C(012) Action(fBorJaE())   PIXEL OF _oDlg
            @ C(000), C(326) Button "Sair"              Size C(056), C(012) Action(_oDlg:End()) PIXEL OF _oDlg
            @ C(119), C(004) Get oPedFal Var cPedFal    OF _oDlg PIXEL  MEMO Size C(377), C(064) FONT oFont1 COLOR CLR_BLACK READONLY

		// Chamadas das ListBox do Sistema
		lRet := fListBox1()

		CtrlArea(2, _aArea, _aAlias) // RestArea
        If lRet
           ACTIVATE MSDIALOG _oDlg CENTERED
           nConTot := 0
           nConAdd := 0
           DbSelectArea("SZG")
           DbSetOrder(1)
           DbSeek(xFilial("SZG")+SZF->ZF_CODIGO, .t.)
           	While !Eof() .and. (xFilial("SZG") = SZG->ZG_FILIAL) .AND. (SZG->ZG_CODIGO == SZF->ZF_CODIGO)
           		nConTot += 1
             	DbSelectArea("SZB")
				DbSetOrder(2)
				DbSeek(xFilial("SZB")+SZG->ZG_PEDIDO, .T.)
				If Found()
					nConAdd += 1
     			Endif
        		DbSelectArea("SZG")
				DbSkip()
    		Enddo
           	If nConTot == nConAdd
              	RecLock("SZF", .f.)
              		SZF->ZF_FLAG := 'Y'
              		//SZF->ZF_FLAG := 'Y'
              	MsUnLock()
           	Endif
        Else
           ACTIVATE MSDIALOG _oDlg CENTERED ON INIT (_oDlg:End())
        Endif
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³   C()   ³ Autores ³ Norbert/Ernani/Mansano ³ Data ³10/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C(nTam)
       Local nHRes := oMainWnd:nClientWidth	// Resolucao horizontal do monitor
       If nHRes == 640 //Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
          nTam *= 0.8
       ElseIf (nHRes == 798) .Or. (nHRes == 800) //Resolucao 800x600
              nTam *= 1
       Else            //Resolucao 1024x768 e acima
          nTam *= 1.28
       EndIf
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³Tratamento para tema "Flat"³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       If "MP8" $ oApp:cVersion
          If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
             nTam *= 0.90
          EndIf
       EndIf
Return Int(nTam)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CtrlArea º Autor ³Ricardo Mansano     º Data ³ 18/05/2005  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºLocacao   ³ Fab.Tradicional  ³Contato ³ mansano@microsiga.com.br       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Static Function auxiliar no GetArea e ResArea retornando   º±±
±±º          ³ o ponteiro nos Aliases descritos na chamada da Funcao.     º±±
±±º          ³ Exemplo:                                                   º±±
±±º          ³ Local _aArea  := {} // Array que contera o GetArea         º±±
±±º          ³ Local _aAlias := {} // Array que contera o                 º±±
±±º          ³                     // Alias(), IndexOrd(), Recno()        º±±
±±º          ³                                                            º±±
±±º          ³ // Chama a Funcao como GetArea                             º±±
±±º          ³ P_CtrlArea(1,@_aArea,@_aAlias,{"SL1","SL2","SL4"})         º±±
±±º          ³                                                            º±±
±±º          ³ // Chama a Funcao como RestArea                            º±±
±±º          ³ P_CtrlArea(2,_aArea,_aAlias)                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nTipo   = 1=GetArea / 2=RestArea                           º±±
±±º          ³ _aArea  = Array passado por referencia que contera GetArea º±±
±±º          ³ _aAlias = Array passado por referencia que contera         º±±
±±º          ³           {Alias(), IndexOrd(), Recno()}                   º±±
±±º          ³ _aArqs  = Array com Aliases que se deseja Salvar o GetArea º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAplicacao ³ Generica.                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CtrlArea(_nTipo, _aArea, _aAlias, _aArqs)
       Local _nN
       // Tipo 1 = GetArea()
       If _nTipo == 1
          _aArea   := GetArea()
          For _nN  := 1 To Len(_aArqs)
              DbSelectArea(_aArqs[_nN])
              aAdd(_aAlias, {Alias(), IndexOrd(), Recno()})
          Next
          // Tipo 2 = RestArea()
       Else
          For _nN := 1 To Len(_aAlias)
              DbSelectArea(_aAlias[_nN][1])
              DbSetOrder(_aAlias[_nN][2])
              DbGoto(_aAlias[_nN][3])
          Next
          RestArea(_aArea)
       Endif
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³fGetDados1()³ Autor ³ Luís Gustavo de Souza     ³ Data ³17/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Montagem da GetDados                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao ³ O Objeto oGetDados1 foi criado como Private no inicio do Fonte   ³±±
±±³           ³ desta forma voce podera trata-lo em qualquer parte do            ³±±
±±³           ³ seu programa:                                                    ³±±
±±³           ³                                                                  ³±±
±±³           ³ Para acessar o aCols desta MsNewGetDados: oGetDados1:aCols[nX,nY]³±±
±±³           ³ Para acessar o aHeader: oGetDados1:aHeader[nX,nY]                ³±±
±±³           ³ Para acessar o "n"    : oGetDados1:nAT                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fGetDados1(nOpcX)
       // Variaveis deste Form
       Local nX           := 0
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Cria o Cabecalho da GetDados com todos os Campos do Alias ³
       //³ Caso queira IGNORAR algum Campo basta substituir o Nil    ³
       //³ por uma array com os campos Ex. {"A1_NOME","A1_LC"}		 ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       Local aGetAux1     := {"NOUSER"}
       Local cQry1 		  := ""
       Local nZ           := aEval(ApBuildHeader("SZG", Nil), {|x| Aadd(aGetAux1, x[2])})
       // Fim da Criacao do Cabecalho --------------------------------
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Variaveis da MsNewGetDados()      ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       // Vetor responsavel pela montagem da aHeader
       Local aCpoGDa      := aGetAux1
       // Vetor com os campos que poderao ser alterados
       Local aAlter       := {}
       Local nSuperior    := C(070)           // Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
       Local nEsquerda    := C(000)           // Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
       Local nInferior    := C(193)           // Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
       Local nDireita     := C(363)           // Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
       // Posicao do elemento do vetor aRotina que a MsNewGetDados usara como referencia
       Local nOpc         := Iif(nOpcX == 4, 3, Iif(nOpcX == 5, 2, nOpcX)) //GD_INSERT+GD_DELETE+GD_UPDATE
       Local cLinhaOk     := Iif(nOpcX == 4 .or. nOpcX == 3, "u_FATA02_4()", "AllwaysTrue") // Funcao executada para validar o contexto da linha atual do aCols
       Local cTudoOk      := "AllwaysTrue"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
       Local cIniCpos     := ""               // Nome dos campos do tipo caracter que utilizarao incremento automatico.
                                              // Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do
                                              // segundo campo>+..."
       Local nFreeze      := 000              // Campos estaticos na GetDados.
       Local nMax         := 999              // Numero maximo de linhas permitidas. Valor padrao 99
       Local cCampoOk     := "AllwaysTrue"    // Funcao executada na validacao do campo
       Local cSuperApagar := ""               // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
     //Local cApagaOk     := Iif(nOpcX == 4 .or. nOpcX == 3, { || u_FATA02_6()}, AllwaysTrue()) // Funcao executada para validar a exclusao de uma linha do aCols
       Local cApagaOk     := Iif(nOpcX == 4 .or. nOpcX == 3, "u_FATA02_6()", "AllwaysTrue") // Funcao executada para validar a exclusao de uma linha do aCols
       // Objeto no qual a MsNewGetDados sera criada
       Local oWnd         := _oDlg
       Local aHead        := {}               // Array a ser tratado internamente na MsNewGetDados como aHeader
       Local aCol         := {}               // Array a ser tratado internamente na MsNewGetDados como aCols
       Local _lOpen      := .F. // Adequação para release 12.1.25
	   Local _cAliasSX3  := GetNextAlias() // Adequação para release 12.1.25
       // Carrega aHead
       /* RELEASE 12.1.25
       DbSelectArea("SX3")
       SX3->(DbSetOrder(2)) // Campo
       For nX := 1 to Len(aCpoGDa)
           If SX3->(DbSeek(aCpoGDa[nX]))
              If UPPER(Alltrim(SX3->X3_CAMPO)) $ 'ZG_PEDIDO'
                 cCpoVld := Iif(INCLUI .or. ALTERA, 'u_FATA02_3("P", "I", @aTroBor)', 'u_FATA03_2("P")')
              ElseIf UPPER(Alltrim(SX3->X3_CAMPO)) $ 'ZG_LOCALIZ'
                     cCpoVld := Iif(INCLUI .or. ALTERA, 'u_FATA02_3("L", "I")', 'u_FATA03_2("L")')
              Else
                 cCpoVld := "AllwaysTrue()"
              Endif
              aAdd(aHead, {AllTrim(X3Titulo()),;
                           SX3->X3_CAMPO      ,;
                           SX3->X3_PICTURE    ,;
                           SX3->X3_TAMANHO    ,;
                           SX3->X3_DECIMAL    ,;
                           cCpoVld            ,;
                           SX3->X3_USADO      ,;
                           SX3->X3_TIPO       ,;
                           SX3->X3_F3         ,;
                           SX3->X3_CONTEXT    ,;
                           SX3->X3_CBOX       ,;
                           SX3->X3_RELACAO    })
           Endif
       Next nX
       */
       OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
       _lOpen := Select( _cAliasSX3 ) > 0       
       
       DbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( DbSetOrder(2) )
       For nX := 1 to Len(aCpoGDa)
           If ( _cAliasSX3 )->( DbSeek(aCpoGDa[nX]))
              If UPPER(Alltrim(( _cAliasSX3 )->(X3_CAMPO))) $ 'ZG_PEDIDO'
                  cCpoVld := Iif(INCLUI .or. ALTERA, 'u_FATA02_3("P", "I", @aTroBor)', 'u_FATA03_2("P")')
              ElseIf UPPER(Alltrim(( _cAliasSX3 )->(X3_CAMPO))) $ 'ZG_LOCALIZ'
                  cCpoVld := Iif(INCLUI .or. ALTERA, 'u_FATA02_3("L", "I")', 'u_FATA03_2("L")')
              Else
                 cCpoVld := "AllwaysTrue()"
              Endif
              aAdd(aHead, {AllTrim(( _cAliasSX3 )->(X3_TITULO)),;
                           ( _cAliasSX3 )->(X3_CAMPO)      ,;
                           ( _cAliasSX3 )->(X3_PICTURE)    ,;
                           ( _cAliasSX3 )->(X3_TAMANHO)    ,;
                           ( _cAliasSX3 )->(X3_DECIMAL)    ,;
                           cCpoVld            			   ,;
                           ( _cAliasSX3 )->(X3_USADO)      ,;
                           ( _cAliasSX3 )->(X3_TIPO)       ,;
                           ( _cAliasSX3 )->(X3_F3)         ,;
                           ( _cAliasSX3 )->(X3_CONTEXT)    ,;
                           ( _cAliasSX3 )->(X3_CBOX)       ,;
                           ( _cAliasSX3 )->(X3_RELACAO)    })
           Endif


       Next Nx       

       // Carregue aqui a Montagem da sua aCol
       aAux := {}
       If INCLUI
          For nX := 1 to Len(aCpoGDa)
              If DbSeek(aCpoGDa[nX])
                 aAdd(aAux, CriaVar(( _cAliasSX3 )->(X3_CAMPO)))
              Endif
          Next nX
          aAdd(aAux, .F.)
          aAdd(aCol, aAux)
          aAlter := aGetAux1
       Else
          If ALTERA
             aAlter := aGetAux1
          Endif
          aCol    := {}
          nPesBor := 0
          nVolBor := 0
          cQry1 := ""
          cQry1 += "SELECT SZG.ZG_PEDIDO, SA1.A1_NOME, SZG.ZG_LOCALIZ, SC5.C5_PBRUTO, SC5.C5_VOLUME1 "
          cQry1 += "FROM "+RetSqlName("SZG")+" SZG WITH (NOLOCK) "
          cQry1 += "LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON SC5.C5_FILIAL = SZG.ZG_FILIAL AND SC5.C5_NUM = SUBSTRING(SZG.ZG_PEDIDO, 3, 6) AND SC5.D_E_L_E_T_ = '' "
          cQry1 += "LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.A1_FILIAL = '"+xFilial("SA1")+"') AND SA1.A1_COD = SC5.C5_CLIENTE AND SA1.A1_LOJA = SC5.C5_LOJACLI AND SC5.D_E_L_E_T_ = '' "
          cQry1 += "WHERE SZG.ZG_FILIAL  = '"+xFilial("SZG")+"' "
          cQry1 += "  AND SZG.D_E_L_E_T_ = '' "
          cQry1 += "  AND SZG.ZG_CODIGO  = '"+SZF->ZF_CODIGO+"' "
          cQry1 += "ORDER BY 1 "
          TCQuery cQry1 ALIAS "TCQSZG" NEW
          DbSelectArea("TCQSZG")
          DbGoTop()
          While !Eof()
                aAdd(aCol, {TCQSZG->ZG_PEDIDO, TCQSZG->A1_NOME, TCQSZG->ZG_LOCALIZ, .F.})
                nPesBor += TCQSZG->C5_PBRUTO
                nVolBor += TCQSZG->C5_VOLUME1
                DbSelectArea("TCQSZG")
                DbSkip()
          Enddo
          DbSelectArea("TCQSZG")
          DbCloseArea()
       Endif
       onPesBor:Refresh()
       onVolBor:Refresh()
       /*
       FUNCOES PARA AUXILIO NO USO DA NEWGETDADOS
       PARA MAIORES DETALHES ESTUDE AS FUNCOES AO FIM DESTE FONTE
       ==========================================================

       // Retorna numero da coluna onde se encontra o Campo na NewGetDados
       Ex: NwFieldPos(oGet1, "A1_COD")

       // Retorna Valor da Celula da NewGetDados
       // OBS: Se nLinha estiver vazia ele acatara o oGet1:nAt(Linha Atual) da NewGetDados
       Ex: NwFieldGet(oGet1, "A1_COD", nLinha)

       // Alimenta novo Valor na Celula da NewGetDados
       // OBS: Se nLinha estiver vazia ele acatara o oGet1:nAt(Linha Atual) da NewGetDados
       Ex: NwFieldPut(oGet1, "A1_COD", nLinha, "Novo Valor")

       // Verifica se a linha da NewGetDados esta Deletada.
       // OBS: Se nLinha estiver vazia ele acatara o oGet1:nAt(Linha Atual) da NewGetDados
       Ex: NwDeleted (oGet1, nLinha)
       */
    
       DbSelectArea( _cAliasSX3 )
       DbCloseArea()
              
       u_fVldPed(aCol, Iif(nOpcX == 2, "V", Iif(nOpcX == 3, "I", Iif(nOpcX == 4, "A", "E"))))
       
       oGetDados1 := MsNewGetDados():New(nSuperior, nEsquerda, nInferior, nDireita, nOpc, cLinhaOk         , cTudoOk        , cIniCpos  , aAlter                                   , nFreeze, nMax, cCampoOk         , 'AllwaysTrue()', {|| u_FATA02_6()} , oWnd , aHead  , aCol)
       //oBrw1    := MsNewGetDados():New(      036,       000,       148,      344, nOpc, 'u_SACX02_5("L")', 'AllwaysTrue()', '+D1_ITEM', {"ZR_PRODUTO", "ZR_LOCDEV", "ZR_QTDDEV" }, 0      , 999 , 'u_SACX02_5("C")', 'AllwaysTrue()', {|| u_fApaIte()}  , oDlg1, aHoBrw1, aCoBrw1 )
       //oGetDados1:lDelete := .t.
//     oBrw1      := MsNewGetDados():New(060      ,       040,       120,      180, nOpc, 'AllwaysTrue()','AllwaysTrue()', ''      ,       ,       0,   99, 'AllwaysTrue()', ''          , 'u_teste()', oDlg1, aHoBrw1,aCoBrw1 )
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ NwFieldPos ³ Autor ³ Ricardo Mansano       ³ Data ³06/09/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Retorna numero da coluna onde se encontra o Campo na         ³±±
±±³           ³ NewGetDados                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ oObjeto := Objeto da NewGetDados                             ³±±
±±³           ³ cCampo  := Nome do Campo a ser localizado                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ Numero da coluna localizada pelo aScan                       ³±±
±±³           ³ OBS: Se retornar Zero significa que nao localizou o Registro ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function NwFieldPos(oObjeto, cCampo)
       Local nCol := aScan(oObjeto:aHeader, {|x| AllTrim(x[2]) == Upper(cCampo)})
Return(nCol)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ NwFieldGet ³ Autor ³ Ricardo Mansano       ³ Data ³06/09/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Retorna Valor da Celula da NewGetDados                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ oObjeto := Objeto da NewGetDados                             ³±±
±±³           ³ cCampo  := Nome do Campo a ser localizado                    ³±±
±±³           ³ nLinha  := Linha da GetDados, caso o parametro nao seja      ³±±
±±³           ³            preenchido o Default sera o nAt da NewGetDados    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ xRet := O Valor da Celula independente de seu TYPE           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function NwFieldGet(oObjeto, cCampo, nLinha)
       Local nCol     := aScan(oObjeto:aHeader, {|x| AllTrim(x[2]) == Upper(cCampo)})
       Local xRet
       // Se nLinha nao for preenchida Retorna a Posicao de nAt do Objeto
       Default nLinha := oObjeto:nAt
       xRet := oObjeto:aCols[nLinha][nCol]
Return(xRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ NwFieldPut ³ Autor ³ Ricardo Mansano       ³ Data ³06/09/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Alimenta novo Valor na Celula da NewGetDados                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ oObjeto := Objeto da NewGetDados                             ³±±
±±³           ³ cCampo  := Nome do Campo a ser localizado                    ³±±
±±³           ³ nLinha  := Linha da GetDados, caso o parametro nao seja      ³±±
±±³           ³            preenchido o Default sera o nAt da NewGetDados    ³±±
±±³           ³ xNewValue := Valor a ser inputado na Celula.                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function NwFieldPut(oObjeto, cCampo, nLinha, xNewValue)
       Local nCol := aScan(oObjeto:aHeader,{|x| AllTrim(x[2]) == Upper(cCampo)})
       // Se nLinha nao for preenchida Retorna a Posicao de nAt do Objeto
       Default nLinha := oObjeto:nAt
       // Alimenta Celula com novo Valor se este foi preenchido
       If !Empty(xNewValue)
          oObjeto:aCols[nLinha][nCol] := xNewValue
       Endif
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ NwDeleted  ³ Autor ³ Ricardo Mansano       ³ Data ³06/09/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Verifica se a linha da NewGetDados esta Deletada.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ oObjeto := Objeto da NewGetDados                             ³±±
±±³           ³ nLinha  := Linha da GetDados, caso o parametro nao seja      ³±±
±±³           ³            preenchido o Default sera o nAt da NewGetDados    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ lRet := True = Linha Deletada / False = Nao Deletada         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function NwDeleted(oObjeto, nLinha)
       Local nCol := Len(oObjeto:aCols[1])
       Local lRet := .T.
       // Se nLinha nao for preenchida Retorna a Posicao de nAt do Objeto
       Default nLinha := oObjeto:nAt
       // Alimenta Celula com novo Valor
       lRet := oObjeto:aCols[nLinha][nCol]
Return(lRet)

/******************************************************************************************************************/
/*** fVldPed - Verificação de pedido não liberado.                                                              ***/
/******************************************************************************************************************/
User Function fVldPed(aCols, cOpcao)
       Local nPedNLi := 0
       Local cPedNLi := ""
       Local nPedLib := 0
       Local nPedBlo := 0
       Local cPedBlo := ""
       Local nPedNEn := 0
       Local cPedNEn := ""
       Local cAuxPed := "" 
       Local _ni     := 0
       Local nY      := 0
       Local cMsgSC5 := ""
       Local cMsgSC9 := ""
       Local cQry1   := ""
       Local cMsg 	 := ""
       For _ni := 1 To Len(aCols)
           DbSelectArea("SC5")
           DbGoTop()
           DbSetOrder(1)
           DbSeek(xFilial("SC5")+SubStr(aCols[_ni][1], 3, 6), .t.)
           //DbSeek(aCols[_ni][1], .t.)
           If Found()
              If SC5->C5_APROVA == '0'
                 nPedNLi += 1
                 cPedNLi += SC5->C5_NUM+'/'
              ElseIf SC5->C5_APROVA == '1'
                     nPedLib += 1
              ElseIf SC5->C5_APROVA == '2'
                     nPedBlo += 1
                     cPedBlo += SC5->C5_NUM+'/'
              Endif
              if !empty(cAuxPed)
                  cAuxPed += "', '"
              endif 
              cAuxPed += SC5->C5_NUM
           Else
              nPedNEn += 1
              cPedNEn += SubStr(aCols[_ni][1], 3, 6)+'/'
           Endif
       Next
       If cOpcao $ "A_V"
          cMsg := ""
          If nPedNLi > 0
             cMsg += "Existe(m) "+TransForm(nPedNLi, "@E 9999")+" pedido(s) não liberado(s): "+chr(13)+chr(10)
             cMsg += cPedNLi+chr(13)+chr(10)
          Endif
          If nPedBlo > 0
             cMsg += "Existe(m) "+TransForm(nPedBlo, "@E 9999")+" pedido(s) bloqueado(s): "+chr(13)+chr(10)
             cMsg += cPedBlo+chr(13)+chr(10)
          Endif
          If nPedNEn > 0
             cMsg += "Existe(m) "+TransForm(nPedNEn, "@E 9999")+" pedido(s) não encontrado (excluido): "+chr(13)+chr(10)
             cMsg += cPedNEn+chr(13)+chr(10)
          Endif
          If Len(aCols) = 0
             MsgStop("Não existem pedidos neste este Borderô !!")
			 Return
          Endif
          If !Empty(cMsg)
             MsgStop(cMsg)
          Endif
          aPedSC9 := {}
          cQry1 := ""
          cQry1 += "SELECT C9_PEDIDO "
          cQry1 += "FROM "+RetSqlName("SC9")+" SC9 WITH (NOLOCK) "
          cQry1 += "WHERE (SC9.C9_FILIAL  = '"+xFilial("SC9")+"') "
          cQry1 += "  AND SC9.D_E_L_E_T_ = '' "
//          cQry1 += "  AND SC9.C9_PEDIDO IN('"+SubStr(cAuxPed, 1, Len(cAuxPed)-3)+") "
          cQry1 += "  AND SC9.C9_PEDIDO IN('"+cAuxPed+"') "
          cQry1 += "  AND SC9.C9_BLEST   <> '' "
          cQry1 += "  AND SC9.C9_BLCRED  <> '' "
          TCQuery cQry1 ALIAS "XC9" NEW
          DbSelectArea("XC9")
          While !Eof()
                If aScan(aPedSC9, {|x| x[1] == XC9->C9_PEDIDO}) == 0
                   aAdd(aPedSC9, {XC9->C9_PEDIDO, 1})
                Else
                   aPedSC9[aScan(aPedSC9, {|x| x[1] == XC9->C9_PEDIDO})][2] += 1
                Endif
                DbSelectArea("XC9")
                DbSkip()
          Enddo
          DbSelectArea("XC9")
          DbCloseArea()
          
          aPedSC5 := {}
          cQry1 := ""
          cQry1 += "SELECT C5_NUM "
          cQry1 += "FROM "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) "
          cQry1 += "WHERE (D_E_L_E_T_ <> '*') AND (SC5.C5_FILIAL = '"+xFilial("SC5")+"') "
          cQry1 += "  AND C5_NOTA = '' "
          cQry1 += "  AND SC5.C5_LIBCAD = 'T' "
          cQry1 += "  AND SC5.C5_LIBPED = 'T' "
          cQry1 += "  AND SC5.C5_LIBCRE = 'T' "
          cQry1 += "  AND SC5.C5_LIBDIR = 'T' "
          cQry1 += "  AND SC5.C5_APROVA = 0 "
          TCQuery cQry1 ALIAS "XC5" NEW
          DbSelectArea("XC5")
          While !Eof()
                If aScan(aPedSC5, {|x| x[1] == XC5->C5_NUM}) == 0
                   aAdd(aPedSC5, {XC5->C5_NUM, 1})
                Else
                   aPedSC5[aScan(aPedSC5, {|x| x[1] == XC5->C5_NUM})][2] += 1
                Endif
                DbSelectArea("XC5")
                DbSkip()
          Enddo
          DbSelectArea("XC5")
          DbCloseArea()
          If Len(aPedSC9) > 0.0
             cMsgSC9 := ''
             cMsgSC9 += 'O(s) pedido(s) abaixo, esta(ão) com problema na liberação de crédito!'+chr(13)+chr(10)
             cMsgSC9 += '                  AVISAR A ADMINISTRAÇÃO DO SISTEMA                  '+chr(13)+chr(10)
             For nY := 1 To Len(aPedSC9)
                 cMsgSC9 += Transform(aPedSC9[nY][2], "@E 9999")+' item(ns) do pedido: '+aPedSC9[nY][1]+'.'+chr(13)+chr(10)
             Next
          Endif
          If Len(aPedSC5) > 0.0
             cMsgSC5 := ''
             cMsgSC5 += 'O(s) pedido(s) abaixo, esta(ão) com problema na liberação de crédito!'+chr(13)+chr(10)
             cMsgSC5 += '                  AVISAR A ADMINISTRAÇÃO DO SISTEMA                  '+chr(13)+chr(10)
             For nY := 1 To Len(aPedSC5)
                 cMsgSC5 += 'Pedido: '+aPedSC5[nY][1]+'.'+chr(13)+chr(10)
             Next
          Endif
       Endif
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³fListBox1() ³ Autor ³ Luís Gustavo de Souza ³ Data ³25/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Montagem da ListBox                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fListBox1()
       Local oOk     := LoadBitmap( GetResources(), "LBOK" )
       Local oNo     := LoadBitmap( GetResources(), "LBNO" )
       Local cQry1   := ""
       Local aMatDad := {}
       Local aMatReg := {}
       Local nX      := 0
       Local nY      := 0
       Local cREGTRA := GETMV("MV_REGTRA")
        
       cQry1 += "SELECT ZZC.ZZC_BORDER, ZZC.ZZC_CARGA, ZZC.ZZC_PEDIDO, ZZC.ZZC_SEPARA, SUM(ZZC.ZZC_VOLUME) AS QTDE "
       cQry1 += "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
       cQry1 += "WHERE ZZC.ZZC_FILIAL = '"+xFilial("ZZC")+"' "
       cQry1 += "  AND D_E_L_E_T_ = '' "
       cQry1 += "  AND ZZC.ZZC_BORDER = '"+SZF->ZF_CODIGO+"' "
       cQry1 += "  AND ZZC.ZZC_CARGA  = '' "
       cQry1 += "GROUP BY ZZC.ZZC_BORDER, ZZC.ZZC_CARGA, ZZC.ZZC_PEDIDO, ZZC.ZZC_SEPARA "
       cQry1 += "ORDER BY ZZC.ZZC_PEDIDO, ZZC.ZZC_SEPARA "
       TCQuery cQry1 ALIAS "TCQZZC" NEW
       DbSelectArea("TCQZZC")
       DbGoTop()
       While !Eof()
             nPosDad := aScan(aMatDad, {|x| x[1] == TCQZZC->ZZC_PEDIDO})
             If nPosDad == 0                                                      
                aadd(aMatDad, {' ', ' ', ' ', ' ', ' ', ' ', 0 , 0 , 0, ' ', ' ', ' ', 0})
                //              |    |    |    |    |    |   |   |   |   |    |    |   |
                //              |    |    |    |    |    |   |   |   |   |    |    |   +-->>> 13 - Volume do Pedido
                //              |    |    |    |    |    |   |   |   |   |    |    +------>>> 12 - Endereço na Expedição
                //              |    |    |    |    |    |   |   |   |   |    +----------->>> 11 -
                //              |    |    |    |    |    |   |   |   |   +---------------->>> 10 - Região (Passou a ser transportadora)
                //              |    |    |    |    |    |   |   |   +-------------------->>> 09 - Quantidade TOTAL
                //              |    |    |    |    |    |   |   +------------------------>>> 08 - Quantidade não separada
                //              |    |    |    |    |    |   +---------------------------->>> 07 - Quantidade já separada
                //              |    |    |    |    |    +-------------------------------->>> 06 - Região (Passou a ser transportadora)
                //              |    |    |    |    +------------------------------------->>> 05 - Código da Cidade do Cliente
                //              |    |    |    +------------------------------------------>>> 04 - Nome do Cliente
                //              |    |    +----------------------------------------------->>> 03 - Loja do Cliente
                //              |    +---------------------------------------------------->>> 02 - Código do Cliente
                //              +--------------------------------------------------------->>> 01 - Numero do Pedido

                aMatDad[Len(aMatDad)][01] := TCQZZC->ZZC_PEDIDO                                                                                      //Pedido
                aMatDad[Len(aMatDad)][02] := Posicione("SC5", 1, xFilial("SC5")+aMatDad[Len(aMatDad)][01], "C5_CLIENTE")                          //Cliente
                aMatDad[Len(aMatDad)][03] := Posicione("SC5", 1, xFilial("SC5")+aMatDad[Len(aMatDad)][01], "C5_LOJACLI")                          //Loja Cliente
                aMatDad[Len(aMatDad)][04] := Posicione("SA1", 1, xFilial("SA1")+aMatDad[Len(aMatDad)][02]+aMatDad[Len(aMatDad)][03], "A1_NOME")   //Razão Social
                aMatDad[Len(aMatDad)][05] := Posicione("SA1", 1, xFilial("SA1")+aMatDad[Len(aMatDad)][02]+aMatDad[Len(aMatDad)][03], "A1_CODCID") //Código da Cidade
                //If GETMV("MV_REGTRA") $ 'R' release 12.1.25
                IF cREGTRA $ 'R' 
                   aMatDad[Len(aMatDad)][06] := Posicione("SZ7", 1, xFilial("SZ7")+aMatDad[Len(aMatDad)][05], "Z7_REGIAO")                        //Código da Região (Transportadora)
                Else
                   aMatDad[Len(aMatDad)][06] := Posicione("SC5", 1, xFilial("SC5")+aMatDad[Len(aMatDad)][01], "C5_TRANSP")                        //Código da Região (Transportadora)
                Endif
                aMatDad[Len(aMatDad)][12] := Posicione("SZG", 2, xFilial("SZG")+'01'+aMatDad[Len(aMatDad)][01], "ZG_LOCALIZ")                     //Endereço na Expedição
                If TCQZZC->ZZC_SEPARA $ 'S'
                   aMatDad[Len(aMatDad)][07] := TCQZZC->QTDE                                                                                         //Quantidade já separada
                Else
                   aMatDad[Len(aMatDad)][08] := TCQZZC->QTDE                                                                                         //Quantidade não separada
                Endif
                aMatDad[Len(aMatDad)][09] += TCQZZC->QTDE                                                                                            //Quantidade Total
                aMatDad[Len(aMatDad)][10] := aMatDad[Len(aMatDad)][06]                                                                            //Região (Passou a ser Transportadora)
                aMatDad[Len(aMatDad)][13] := Posicione("SC5", 1, xFilial("SC5")+aMatDad[Len(aMatDad)][01], "C5_VOLUME1")                          //Volume do Pedido

                nPosReg := aScan(aMatReg, aMatDad[Len(aMatDad)][06] )
                If nPosReg == 0
                   aadd(aMatReg, aMatDad[Len(aMatDad)][06])
                Endif
             Else
                If TCQZZC->ZZC_SEPARA $ 'S'
                   aMatDad[nPosDad][07] += TCQZZC->QTDE
                Else
                   aMatDad[nPosDad][08] += TCQZZC->QTDE
                Endif
                aMatDad[nPosDad][09] += TCQZZC->QTDE
             Endif
             DbSelectArea("TCQZZC")
             DbSkip()
       Enddo
       aSort(aMatReg)
       DbSelectArea("TCQZZC")
       DbCloseArea()

       For nY := 1 To Len(aMatReg)
           aMatImp := {}
           For nX := 1 To Len(aMatDad)
               If aMatDad[nX][06] == aMatReg[nY]
                  aadd(aMatImp, {aMatDad[nX][01], aMatDad[nX][02], aMatDad[nX][03], aMatDad[nX][04], aMatDad[nX][05], aMatDad[nX][06], aMatDad[nX][07], aMatDad[nX][08], aMatDad[nX][09], aMatDad[nX][10], aMatDad[nX][11], aMatDad[nX][12], (Iif(aMatDad[nX][09] == 0, 0, aMatDad[nX][07] / aMatDad[nX][09]) * 100), '', aMatDad[nX][13] })
               Endif
           Next
           aSort(aMatImp,,,{|x,y| x[13] > y[13]})
           For nX := 1 To Len(aMatImp)
               aMatImp[nX][14] := aMatImp[nX][10]+StrZero(nX, 3)//StrZero(aMatImp[nX][13], 3)
           Next
           //Adiciona Item para a Transportadora/Redespacho
           aAdd(aMonDes, {.f.              ,;
                          ''               ,;
                          aMatReg[nY]+' - '+Iif(cREGTRA $ 'R', Alltrim(Posicione("SX5", 1, xFilial("SX5")+'98'+aMatReg[nY], "X5_DESCRI")), Alltrim(Posicione("SA4", 1, xFilial("SA4")+aMatReg[nY], "A4_NOME")) ),;						// release 12.1.25 aMatReg[nY]+' - '+Iif(GETMV("MV_REGTRA") $ 'R', Alltrim(Posicione("SX5", 1, xFilial("SX5")+'98'+aMatReg[nY], "X5_DESCRI")), Alltrim(Posicione("SA4", 1, xFilial("SA4")+aMatReg[nY], "A4_NOME")) ),;
                          0                ,;
                          ''               ,;
                          TransForm(0, "@E 999.99")  ,;
                          aMatReg[nY]      ,;
                          aMatReg[nY]+'000'})
           //Adiciona Pedidos a serem despachados
           For nX := 1 To Len(aMatImp)
               aAdd(aMonDes, {.f.            ,;
                              aMatImp[nX][01],;
                              aMatImp[nX][02]+'/'+aMatImp[nX][03]+' - '+aMatImp[nX][04],;
                              aMatImp[nX][15],;
                              aMatImp[nX][12],;
                              TransForm(aMatImp[nX][13], "@E 999.99"),;
                              aMatImp[nX][06],;
                              aMatImp[nX][14]})
           Next
       Next
       If Len(aMonDes) <= 0
          MsgStop("Não existem pedidos para serem separados em cargas!")
          Return(.f.)
       Endif

       // Para editar os Campos da ListBox inclua a linha abaixo
       // na opcao de DuploClick da mesma, ou onde for mais conveniente
       // lembre-se de mudar a picture respeitando a coluna a ser editada
       // PS: Para habilitar o DuploClick selecione a opção MarkBrowse da
       //     ListBox para SIM.
       // lEditCell( aListBox, oListBox, "@!", oListBox:ColPos )

       @ C(014), C(001) ListBox oMonDes Fields ;
                        HEADER "", "PEDIDO", "CLIENTE", "VOLUME", "LOCALIZAÇÃO", "% SEPARADO";
                        Size C(383),C(097) Of _oDlg Pixel;
                        ColSizes 0, 25, 150, 30, 50, 30;
                        On DBLCLICK (fMarCar(), oMonDes:Refresh()) //aMonDes[oMonDes:nAt,1] := !(aMonDes[oMonDes:nAt,1]), oMonDes:Refresh() )
                        oMonDes:SetArray(aMonDes)

       oMonDes:bLine   := {|| {If(aMonDes[oMonDes:nAT][01], oOk, oNo),;
                                aMonDes[oMonDes:nAT][02]           ,;
                                aMonDes[oMonDes:nAT][03]           ,;
                                aMonDes[oMonDes:nAT][04]           ,;
                                aMonDes[oMonDes:nAT][05]           ,;
                                aMonDes[oMonDes:nAT][06]           }}
       oMonDes:bChange := { || fTroPed(@cPedFal)}
Return(.T.)

/******************************************************************************************************************/
/*** fMarCar - Marca e desmarca Cargas                                                                          ***/
/******************************************************************************************************************/
Static Function fMarCar()
       Local nX := 0
       If !Empty(oMonDes:aArray[oMonDes:nAt][2])
          oMonDes:aArray[oMonDes:nAt][1] := !oMonDes:aArray[oMonDes:nAt][1]
       Else
          nPos := oMonDes:nAt
          For nX := 1 To Len(oMonDes:aArray)
              If nX <> nPos .and. oMonDes:aArray[nX][7] == oMonDes:aArray[nPos][7]
                 oMonDes:aArray[nX][1] := !oMonDes:aArray[nX][1]
              Endif
          Next
       Endif
       oMonDes:Refresh()
Return

/******************************************************************************************************************/
/*** fTroPed - Ajusta observação na troca dos pedidos                                                           ***/
/******************************************************************************************************************/
Static Function fTroPed(cObsMsg)
       cObsMsg := "| QTDE. PRODUTO          DESCRIÇÃO                      VOLUME     LOCALIZAÇÃO     PRX. DESP.            |"+CHR(13)+CHR(10)
       cObsMsg += "+--------------------------------------------------------------------------------------------------------+"+CHR(13)+CHR(10)
       nQtdPro := 0
       If !Empty(oMonDes:aArray[oMonDes:nAt][2])
          DbSelectArea("ZZC")
          DbSetOrder(1)
          DbSeek(xFilial("ZZC")+SZF->ZF_CODIGO+oMonDes:aArray[oMonDes:nAt][2], .t.)
          If Found()
              While !Eof() .and. ZZC->ZZC_BORDER == SZF->ZF_CODIGO .and. ZZC->ZZC_PEDIDO == oMonDes:aArray[oMonDes:nAt][2]
                  If ZZC->ZZC_SEPARA <> 'S'
				      cQry1 := "SELECT ZZC.ZZC_PRODUT AS PRODUTO, ZZC.ZZC_CARGA AS CODIGO, ZZC.ZZC_PEDIDO AS PEDIDO, "+;
                      "CASE WHEN ZZC.ZZC_CARGA = '' THEN '' ELSE SUBSTRING(ISNULL(SZA.ZA_DESCR, ''), 1, 10) END AS DESCRICAO, "+;
                      "CASE WHEN ZZC.ZZC_CARGA = '' THEN 'SEM BORD. ' ELSE CASE WHEN SZA.ZA_PREVDSP = '' THEN '99999999' ELSE SZA.ZA_PREVDSP END END AS PREVISAO "+;
					  "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "+;
					  "LEFT OUTER JOIN "+RetSqlName("SZB")+" SZB WITH (NOLOCK) ON (SZB.ZB_FILIAL = ZZC.ZZC_FILIAL) AND (SUBSTRING(SZB.ZB_PEDIDO, 3, 6) = ZZC.ZZC_PEDIDO) AND (SZB.D_E_L_E_T_ = '') "+;
					  "LEFT OUTER JOIN "+RetSqlName("SZA")+" SZA WITH (NOLOCK) ON SZA.ZA_FILIAL = SZB.ZB_FILIAL AND SZA.ZA_CODIGO = SZB.ZB_CODIGO AND SZA.D_E_L_E_T_ = '' "+;
					  "WHERE (ZZC.ZZC_FILIAL = '"+xFilial("SZA")+"') AND (ZZC.D_E_L_E_T_ = '') AND (ZZC.ZZC_SEPARA <> 'S') AND (ZZC.ZZC_DESPAC <> 'S') "+;
					  "AND (ZZC.ZZC_PRODUT = '"+ZZC->ZZC_PRODUTO+"') "+;
					  "ORDER BY PREVISAO"
                      TCQuery cQry1 ALIAS "TCQZZC" NEW
                      DbSelectArea("TCQZZC")
                      cDesDes := TCQZZC->DESCRICAO
                      If Alltrim(TCQZZC->PREVISAO) $ '99999999'
                          dDatDes := '  /  /    '
                      ElseIf Alltrim(TCQZZC->PREVISAO) $ 'SEM BORD.'
                          dDatDes := 'SEM BORD. '
                      Else
                          dDatDes := SubStr(TCQZZC->PREVISAO, 7, 2)+'/'+SubStr(TCQZZC->PREVISAO, 5, 2)+'/'+SubStr(TCQZZC->PREVISAO, 1, 4)
                      Endif
                      DbSelectArea("TCQZZC")
                      DbCloseArea()
                      DbSelectArea("ZZC")
                      //                  1         2         3         4         5         6         7         8         9         10
                      //         1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
                      //         | QTDE. PRODUTO          DESCRIÇÃO                      VOLUME     LOCALIZAÇÃO     PRX. DESP. |
                      //         +---------------------------------------------------------------------------------------------+
                      //         | 99999 XX 99.99.999-99 *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXX XXXXXXXXXXXXXXX SEM BORD   |
                      //           12345 123456789012345 1123456789012345678901234567890 1234567890 123456789012345 12345678
                      cObsMsg += '| '+Transform(Iif(ZZC->ZZC_SEPARA <> 'S', ZZC->ZZC_QUANTI - ZZC->ZZC_RETIRA, ZZC->ZZC_QUANTI), "@E 99999")+' '+Transform(ZZC->ZZC_PRODUT, "@R XX 99.99.999-99")+' '+Iif(Posicione("SB1", 1, xFilial("SB1")+ZZC->ZZC_PRODUT, "B1_ESTOQUE") == 'S', "*", " ")+SubStr(Posicione("SB1", 1, xFilial("SB1")+ZZC->ZZC_PRODUT, "B1_DESC"), 1, 30)+' '+SubStr(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(ZZC->ZZC_PRODUT, 11, 2), "Z5_DESCR"), 1, 10)+' '+SubStr(Posicione("SB2", 1, xFilial("SB2")+ZZC->ZZC_PRODUT+Posicione("SB1", 1, xFilial("SB1")+ZZC->ZZC_PRODUT, "B1_LOCPAD"), "B2_LOCALIZ"), 1, 15)+' '+dDatDes+' '+cDesDes+' |'+CHR(13)+CHR(10)//+Transform(nQtdPro, "@E 99999")+' |'+CHR(13)+CHR(10)
                  Endif
                  DbSelectArea("ZZC")
                  DbSkip()
              Enddo
          Endif
       Endif
       oPedFal:SetText(cObsMsg)
       oPedFal:Refresh()
Return

/******************************************************************************************************************/
/*** fNewBor - Grava um novo bordero de despacho                                                                ***/
/******************************************************************************************************************/
Static Function fNewBor()
       Local aMatReg := {}
       Local aQtdReg := {}
       Local _nLin
       Local nY      := 0
       Local nX      := 0
       Local nA      := 0
       //1º) Verificar quais regiões que possuen cargas marcadas e gravar na matriz aMatReg
       For nY := 1 To Len(oMonDes:aArray)
           If oMonDes:aArray[nY][1]
              If aScan(aMatReg, {|x| x[1] == oMonDes:aArray[nY][7]}) == 0
                 aadd(aMatReg, {oMonDes:aArray[nY][7], 0, 0})
              Endif
           Endif
           If Empty(oMonDes:aArray[nY][2])
              aAdd(aQtdReg, {SubStr(oMonDes:aArray[nY][3], 1, 5), 0, 0, 0})
           Else
           		_nLin := aScan(aQtdReg, {|x| Alltrim(x[1]) == Alltrim(oMonDes:aArray[nY][7])})
           		IF !(valtype(_nLin) = "N") .or. (_nLin <= 0)
		              aAdd(aQtdReg, {SubStr(oMonDes:aArray[nY][3], 1, 5), 0, 0, 0})
		              _nLin := 1
		     	endif 

              aQtdReg[_nLin][2] += 1
              If oMonDes:aArray[nY][1]
                 aQtdReg[aScan(aQtdReg, {|x| Alltrim(x[1]) == Alltrim(oMonDes:aArray[nY][7])})][3] += 1
              Endif
           Endif
       Next
       If Len(aMatReg) > 0
          For nA := 1 To Len(aMatReg)
              //Monta aCols por região
              aMatReg[nA][2] := aQtdReg[aScan(aQtdReg, {|x| Alltrim(x[1]) == Alltrim(aMatReg[nA][1])})][2]
              aMatReg[nA][3] := aQtdReg[aScan(aQtdReg, {|x| Alltrim(x[1]) == Alltrim(aMatReg[nA][1])})][3]
              aAuxDes := {}
              For nX := 1 to Len(oMonDes:aArray)
                  If oMonDes:aArray[nX][1] .and. oMonDes:aArray[nX][7] == aMatReg[nA][1]
                     aAdd(aAuxDes, {'01'+oMonDes:aArray[nX][2], SubStr(oMonDes:aArray[nX][3], 13), .f.})
                  Endif
              Next
              u_FATA06_1( , , , , "P", aMatReg[nA][1], @aAuxDes, @aQtdReg, .f.)
          Next
          //DELEÇÃO DOS PEDIDOS ADICIONADOS DA TELA DE MONTA DESPACHO
          For nA := 1 To Len(aQtdReg)
              If aQtdReg[nA][4] > 0
                 If aQtdReg[nA][4] == aQtdReg[nA][2] //Deleta todos os itens da região
                    nQtdDel := 0
                    For nY := 1 To Len(oMonDes:aArray)
                        If !oMonDes:aArray[nY - nQtdDel] == Nil
                           If Alltrim(oMonDes:aArray[(nY - nQtdDel)][7]) == Alltrim(aQtdReg[nA][1])
                              aDel(oMonDes:aArray, (nY - nQtdDel))
                              nQtdDel += 1
                           Endif
                        Endif
                    Next
                 ElseIf aQtdReg[nA][4] < aQtdReg[nA][2] //Deleta os itens do vetor aDelMon
                        nQtdDel := 0
                        For nY := 1 To Len(oMonDes:aArray)
                            If !oMonDes:aArray[nY - nQtdDel] == Nil
                               If oMonDes:aArray[nY - nQtdDel][1] .and. !Empty(oMonDes:aArray[nY - nQtdDel][2]) .and. Alltrim(oMonDes:aArray[(nY - nQtdDel)][7]) == Alltrim(aQtdReg[nA][1])
                                  aDel(oMonDes:aArray, (nY - nQtdDel))
                                  nQtdDel += 1
                               Endif
                            Endif
                        Next
                 Endif
                 aSize(oMonDes:aArray, (Len(oMonDes:aArray) - nQtdDel) )
              Endif
          Next
       Else
          MsgStop("Não havia nenhum pedido marcardo para geração de uma nova carga.")
       Endif
       oMonDes:nAt := 1
       oMonDes:Refresh()
       If Len(oMonDes:aArray) == 0
          _oDlg:End()
       Endif
Return

/******************************************************************************************************************/
/*** fBorJaE - Grava em um bordero já existente                                                                 ***/
/******************************************************************************************************************/
Static Function fBorJaE()
       Local aMatReg  := {}
       Local aButtons := {}
       Local nOpcA    := 0
       Local aQtdReg  := {}
       Local _nLin
       Local nY       := 0
       Local nA       := 0
       Private aMarCar:= {}
       Private oMarCar

       //1º) Verificar se existe pedidos marcados por região
       For nY := 1 To Len(oMonDes:aArray)
           If oMonDes:aArray[nY][1]
              If aScan(aMatReg, {|x| x[1] == oMonDes:aArray[nY][7]}) == 0
                 aadd(aMatReg, {oMonDes:aArray[nY][7], 0, 0})
              Endif
           Endif 
           //Cleber (19/02/2016)
           If Empty(oMonDes:aArray[nY][2]) .or. (len(aQtdReg) == 0)
              aAdd(aQtdReg, {SubStr(oMonDes:aArray[nY][3], 1, 5), 0, 0, 0})
           Else
	           //Cleber (19/02/2016)
           		_nLin := aScan(aQtdReg, {|x| Alltrim(x[1]) == Alltrim(oMonDes:aArray[nY][7])})
           		IF !(valtype(_nLin) = "N") .or. (_nLin <= 0)
		              aAdd(aQtdReg, {SubStr(oMonDes:aArray[nY][3], 1, 5), 0, 0, 0})
		              _nLin := 1
		     	endif 
             	aQtdReg[_nLin][2] += 1
       			If oMonDes:aArray[nY][1]   
              		//_nLin := aScan(aQtdReg, {|x| Alltrim(x[1]) == Alltrim(oMonDes:aArray[nY][7])}) //Cleber(13/12/19)->Chamado 015419, _nLin está vindo nulo 
              		aQtdReg[_nLin][3] += 1
              	Endif
           Endif
       Next
       If Len(aMatReg) > 0
          DEFINE MSDIALOG _oDlg1 TITLE "Borderos de Despacho Existentes" FROM C(178),C(181) TO C(420),C(674) PIXEL
                 fListBox2()
          ACTIVATE MSDIALOG _oDlg1 CENTERED  ON INIT EnchoiceBar(_oDlg1, {||nOpcA := 1, _oDlg1:End()}, {|| _oDlg1:End()},, aButtons)
          If nOpcA == 1
             For nA := 1 To Len(aMarCar)
                 If aMarCar[nA][1]
                    cBorDes := aMarCar[nA][2]
                 Endif
             Next
             If !Empty(cBorDes)
                //1º) Gravação de Dados no Bordero de Despacho
                DbSelectArea("SZA")
                DbSetOrder(1)
                DbSeek(xFilial("SZA")+cBorDes, .t.)
                If Found()
                   nPesBor := 0
                   nVolBor := 0
                   aDelMon := {}
                   lOutBor := .f.
                   For nA := 1 To Len(oMonDes:aArray)
                       If oMonDes:aArray[nA][1]
                          aQtdReg[aScan(aQtdReg, {|x| Alltrim(x[1]) == AllTrim(oMonDes:aArray[nA][7])})][4] += 1
                          DbSelectArea("SZB")
                          DbSetOrder(2)
                          DbSeek(xFilial("SZB")+oMonDes:aArray[nA][2], .t.)
                          If !Found()
                             RecLock("SZB", .t.)
                                SZB->ZB_FILIAL := xFilial("SZB")
                                SZB->ZB_CODIGO := cBorDes
                                SZB->ZB_PEDIDO := Substr(cnumemp,1,2)+oMonDes:aArray[nA][2]
                                SZB->ZB_RAZAO  := SubStr(oMonDes:aArray[nA][3], 13, 40)
                             MsUnLock()
                             nPesBor += Posicione("SC5", 1, xFilial("SC5")+oMonDes:aArray[nA][2], "C5_PBRUTO")
                             nVolBor += Posicione("SC5", 1, xFilial("SC5")+oMonDes:aArray[nA][2], "C5_VOLUME1")
                             DbSelectArea("ZZC")
                             DbSetOrder(2)
                             DbSeek(xFilial("ZZC")+oMonDes:aArray[nA][2], .t.)
                             If Found()
                                While !Eof() .AND. ZZC->ZZC_FILIAL == SZB->ZB_FILIAL .AND. ZZC->ZZC_PEDIDO == oMonDes:aArray[nA][2]
                                      RecLock("ZZC", .f.)
                                         ZZC->ZZC_CARGA := cBorDes
                                      MsUnLock()
                                      DbSelectArea("ZZC")
                                      DbSkip()
                                Enddo
                             Else
                                DbSelectArea("SC6")
                                DbSetOrder(1)
                                DbSeek(xFilial("SC6")+oMonDes:aArray[nA][2], .t.)
                                If Found()
                                   While !Eof() .AND. SC6->C6_FILIAL == SZB->ZB_FILIAL .AND. SC6->C6_NUM == oMonDes:aArray[nA][2]
                                         RecLock("ZZC", .t.)
                                            ZZC->ZZC_FILIAL := xFilial("ZZC")
                                            ZZC->ZZC_BORDER := Posicione("SZG", 1, xFilial("SZG")+oMonDes:aArray[nA][2], "ZG_CODIGO")
                                            ZZC->ZZC_PEDIDO := SC6->C6_NUM
                                            ZZC->ZZC_PRODUT := SC6->C6_PRODUTO
                                            ZZC->ZZC_QUANTI := SC6->C6_QTDVEN
                                            ZZC->ZZC_RETIRA := 0.0
                                            ZZC->ZZC_GAVETA := Space(03)
                                            ZZC->ZZC_VOLUME := SC6->C6_VOLUME
                                            ZZC->ZZC_VOLRET := 0.0
                                            ZZC->ZZC_CARGA  := cBorDes
                                            ZZC->ZZC_OCUPAC := SC6->C6_OCUPAC
                                            ZZC->ZZC_DESPAC := 'N'
                                            ZZC->ZZC_SEPARA := 'N'
                                            ZZC->ZZC_LOTE   := Space(06)
                                            ZZC->ZZC_SEMID  := Space(01)
                                            ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
                                            ZZC->ZZC_TPINCL := 'B'
                                            ZZC->ZZC_LOCEXP := Space(09)
                                            ZZC->ZZC_RESERV := 0.0
                                         MsUnLock()
                                         DbSelectArea("SC6")
                                         DbSkip()
                                   Enddo
                                Endif
                             Endif
                          Else
                          //***********
                             If MsgYesNo("Pedido "+oMonDes:aArray[nA][2]+" está no despacho "+SZB->ZB_CODIGO, "Continua nesse despacho ?")
                                cRedAtu := SZB->ZB_CODIGO
                                cBorAtu := Posicione("SZG", 1, xFilial("SZG")+'01'+oMonDes:aArray[nA][2], "ZG_CODIGO")
                                lOutBor := .t.
                             Else
                                DbSelectArea("SZA")
                                DbSetOrder(1)
                                DbSeek(xFilial("SZA")+SZB->ZB_CODIGO, .t.)
                                If Found()
                                   RecLock("SZA", .f.)
                                      SZA->ZA_PESO   -= Posicione("SC5", 1, xFilial("SC5")+oMonDes:aArray[nA][2], "C5_PBRUTO")
                                      SZA->ZA_VOLUME -= Posicione("SC5", 1, xFilial("SC5")+oMonDes:aArray[nA][2], "C5_VOLUME1")
                                   MsUnLock("SZA")
                                Endif
                                RecLock("SZB", .f.)
                                   SZB->ZB_CODIGO := cBorDes
                                MsUnLock()
                                nPesBor += Posicione("SC5", 1, xFilial("SC5")+oMonDes:aArray[nA][2], "C5_PBRUTO")
                                nVolBor += Posicione("SC5", 1, xFilial("SC5")+oMonDes:aArray[nA][2], "C5_VOLUME1")
                                lOutBor := .f.
                             Endif
                          Endif
                          aAdd(aDelMon, oMonDes:aArray[nA][2])
                       Endif
                   Next
                   RecLock("SZA", .f.)
                      SZA->ZA_PESO   += nPesBor
                      SZA->ZA_VOLUME += nVolBor
                   MsUnLock()
                   //2º) Deleção dos dados do Array Monta Despacho
                   For nA := 1 To Len(aQtdReg)
                       If aQtdReg[nA][4] > 0
                          If aQtdReg[nA][4] == aQtdReg[nA][2] //Deleta todos os itens da região
                             nQtdDel := 0
                             For nY := 1 To Len(oMonDes:aArray)
                                 If !oMonDes:aArray[nY - nQtdDel] == Nil
                                    If Alltrim(oMonDes:aArray[(nY - nQtdDel)][7]) == Alltrim(aQtdReg[nA][1])
                                       aDel(oMonDes:aArray, (nY - nQtdDel))
                                       nQtdDel += 1
                                    Endif
                                 Endif
                             Next
                          ElseIf aQtdReg[nA][4] < aQtdReg[nA][2] //Deleta os itens do vetor aDelMon
                                 nQtdDel := 0
                                 For nY := 1 To Len(aDelMon)
                                     aDel(oMonDes:aArray, aScan(oMonDes:aArray, {|x| x[2] == aDelMon[nY]}))
                                     nQtdDel += 1
                                 Next
                          Endif
                          aSize(oMonDes:aArray, (Len(oMonDes:aArray) - nQtdDel) )
                       Endif
                   Next
                Else
                   MsgStop("Bordero de Despacho não foi encontrado.")
                Endif
                oMonDes:nAt := 1
                oMonDes:Refresh()
                If Len(oMonDes:aArray) == 0
                   _oDlg:End()
                Endif
             Else
                MsgStop("Nenhum Bordero de Despacho foi selecionado.")
             Endif
          Endif
       Else
          MsgStop("Não havia nenhum pedido marcardo para inclusão em uma carga.")
       Endif
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³fListBox2() ³ Autor ³ Luís Gustavo de Souza ³ Data ³25/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Montagem da ListBox                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fListBox2()
       Local oOk     := LoadBitmap( GetResources(), "LBOK" )
       Local oNo     := LoadBitmap( GetResources(), "LBNO" )

       cQry1 := ""
       cQry1 += "SELECT SZA.ZA_CODIGO, SUBSTRING(SZA.ZA_EMISSAO, 7, 2)+'/'+SUBSTRING(SZA.ZA_EMISSAO, 5, 2)+'/'+SUBSTRING(SZA.ZA_EMISSAO, 1, 4) AS ZA_EMISSAO, SUBSTRING(SZA.ZA_PREVDSP, 7, 2)+'/'+SUBSTRING(SZA.ZA_PREVDSP, 5, 2)+'/'+SUBSTRING(SZA.ZA_PREVDSP, 1, 4) AS ZA_PREVDSP, SZA.ZA_REGIAO+' - '+SZA.ZA_DESCR AS ZA_REGIAO, SZA.ZA_PESO, SZA.ZA_VOLUME "
       cQry1 += "FROM "+RetSqlName("SZA")+" SZA WITH (NOLOCK) "
       cQry1 += "WHERE SZA.ZA_FILIAL  = '"+xFilial("SZA")+"' "
       cQry1 += "  AND SZA.D_E_L_E_T_ = '' "
       cQry1 += "  AND SZA.ZA_DTDESPA = '' "
       cQry1 += "ORDER BY SZA.ZA_PREVDSP, SZA.ZA_REGIAO "
       TCQuery cQry1 ALIAS "PRE" NEW
       DbSelectArea("PRE")
       While !Eof()
             aAdd(aMarCar, {.F., PRE->ZA_CODIGO, CTOD(PRE->ZA_EMISSAO), CTOD(PRE->ZA_PREVDSP), PRE->ZA_REGIAO, Transform(PRE->ZA_PESO, '@E 999,999.99'), Transform(PRE->ZA_VOLUME, '@E 999999')})
             DbSelectArea("PRE")
             DbSkip()
       Enddo
       DbSelectArea("PRE")
       DbCloseArea()

       @ C(014), C(001) ListBox oMarCar Fields ;
                        HEADER "", "DESPACHO", "EMISSÃO", "PREVISÃO", "REGIÃO", "PESO", "VOLUME";
                        Size C(233),C(097) Of _oDlg1 Pixel;
                        ColSizes 0, 35, 30, 30, 50, 30, 30;
                        On DBLCLICK (fMarDes(), oMarCar:Refresh())
       oMarCar:SetArray(aMarCar)

       oMarCar:bLine   := {|| {If(aMarCar[oMarCar:nAT][01], oOk, oNo),;
                                  aMarCar[oMarCar:nAT][02]           ,;
                                  aMarCar[oMarCar:nAT][03]           ,;
                                  aMarCar[oMarCar:nAT][04]           ,;
                                  aMarCar[oMarCar:nAT][05]           ,;
                                  aMarCar[oMarCar:nAT][06]           ,;
                                  aMarCar[oMarCar:nAT][07]           }}
Return Nil

/******************************************************************************************************************/
/*** fMarDes - Marca e desmarca Despacho                                                                        ***/
/******************************************************************************************************************/
Static Function fMarDes()
       Local nB
       oMarCar:aArray[oMarCar:nAt][1] := !oMarCar:aArray[oMarCar:nAt][1]
       For nB := 1 To Len(oMarCar:aArray)
           If nB <> oMarCar:nAt
              oMarCar:aArray[nB][1] := .f.
           Endif
       Next
       oMarCar:Refresh()
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³         ³ Autores ³ Luís G. de Souza       ³ Data ³ 09/08/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Volta itens para o estoque.                                  ³±±
±±³           ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function FATA02_Z()
     // Variaveis Locais da Funcao

     // Variaveis da Funcao de Controle e GertArea/RestArea
     Local _aArea   		:= {}
     Local _aAlias  		:= {}
     // Variaveis Private da Funcao
     Private cBorPed := Space(06)
     Private cBorDes := Space(06)
     Private cNumPed := Space(06)
     Private cCodPro := Space(15)
     Private nQtdPed := 0
     Private nQtdVol := 0
     Private _oDlg				// Dialog Principal
     Private oBorPed
     Private oBorDes
     Private oNumPed
     Private oCodPro
     Private oQtdPed
     Private oQtdVol
     DEFINE MSDIALOG _oDlg TITLE "Volta itens para relatório de Faltas" FROM C(178),C(181) TO C(382),C(433) PIXEL
            // Defina aqui a chamada dos Aliases para o GetArea
            CtrlArea(1, @_aArea, @_aAlias, {"ZZC"}) // GetArea

            // Cria as Groups do Sistema
            @ C(015), C(001) TO C(104), C(128) LABEL ""                                                          PIXEL OF _oDlg

            // Cria Componentes Padroes do Sistema
            @ C(003), C(000) Button "Confirma"                           Size C(037), C(012) Action(fVolBor())            PIXEL OF _oDlg
            @ C(003), C(089) Button "Cancela"                            Size C(037), C(012) Action(_oDlg:End())          PIXEL OF _oDlg
            @ C(026), C(065) MsGet oBorPed Var cBorPed F3 "SZF"          Size C(030), C(009) COLOR CLR_BLACK              PIXEL OF _oDlg
            @ C(027), C(003) Say "Bordero de Pedidos:"                   Size C(060), C(008) COLOR CLR_BLACK              PIXEL OF _oDlg
            @ C(039), C(065) MsGet oBorDes Var cBorDes F3 "SZA"          Size C(030), C(009) COLOR CLR_BLACK              PIXEL OF _oDlg
            @ C(040), C(003) Say "Bordero de Despacho:"                  Size C(060), C(008) COLOR CLR_BLACK              PIXEL OF _oDlg
            @ C(052), C(065) MsGet oNumPed Var cNumPed F3 "SC5"          Size C(030), C(009) COLOR CLR_BLACK              PIXEL OF _oDlg
            @ C(053), C(003) Say "Pedido:"                               Size C(060), C(008) COLOR CLR_BLACK              PIXEL OF _oDlg
            @ C(065), C(065) MsGet oCodPro Var cCodPro F3 "SB1"          Size C(060), C(009) COLOR CLR_BLACK              PIXEL OF _oDlg
            @ C(066), C(003) Say "Produto:"                              Size C(060), C(008) COLOR CLR_BLUE               PIXEL OF _oDlg
            @ C(078), C(065) MsGet oQtdPed Var nQtdPed Picture "@E 9999" Size C(030), C(009) COLOR CLR_BLACK     WHEN .F. PIXEL OF _oDlg
            @ C(079), C(003) Say "Qtde. Retirada:"                       Size C(060), C(008) COLOR CLR_BLUE               PIXEL OF _oDlg
            @ C(091), C(065) MsGet oQtdVol Var nQtdVol Picture "@E 9999" Size C(030), C(009) COLOR CLR_BLACK              PIXEL OF _oDlg
            @ C(092), C(003) Say "Qtde. a Voltar:"                       Size C(060), C(008) COLOR CLR_BLUE               PIXEL OF _oDlg

            oBorPed:bValid := {|| fValVol(1)} ; oBorDes:bValid := {|| fValVol(2)}
            oNumPed:bValid := {|| fValVol(3)} ; oCodPro:bValid := {|| fValVol(4)}
            oQtdVol:bValid := {|| fValVol(5)}
            CtrlArea(2, _aArea, _aAlias) // RestArea
     ACTIVATE MSDIALOG _oDlg CENTERED 
Return(.T.)

Static Function fValVol(nOpcVol)
       If nOpcVol == 1 //Validação do Bordero de Pedido
          If Empty(cBorPed)
             Return(.t.)
          Else
             DbSelectArea("SZF")
             DbSetOrder(1)
             If !DbSeek(xFilial("SZF")+cBorPed, .t.)
                MsgAlert("Esse bordero de pedidos não existe!", "Verifique...")
                oBorPed:SetFocus()
                Return(.f.)
             Endif
             If !Empty(cCodPro)
                cQry1 := ""
                cQry1 += "SELECT SUM(ZZC.ZZC_RETIRA) AS QUANTI "
                cQry1 += "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
                cQry1 += "WHERE ZZC.ZZC_FILIAL = '"+xFilial("ZZC")+"' "
                cQry1 += "  AND ZZC.D_E_L_E_T_ = '' "
                cQry1 += "  AND ZZC.ZZC_PRODUT = '"+cCodPro+"' "
                If !Empty(cBorPed)
                   cQry1 += "  AND ZZC.ZZC_BORDER = '"+cBorPed+"' "
                Endif
                If !Empty(cBorDes)
                   cQry1 += "  AND ZZC.ZZC_CARGA = '"+cBorDes+"' "
                Endif
                If !Empty(cNumPed)
                   cQry1 += "  AND ZZC.ZZC_PEDIDO = '"+cNumPed+"' "
                Endif
                TCQuery cQry1 ALIAS "TCQRET" NEW
                DbSelectArea("TCQRET")
                nQtdPed := TCQRET->RETIRA
                DbSelectArea("TCQRET")
                DbCloseArea()
             Endif
          Endif
       ElseIf nOpcVol == 2 //Validação do Bordero de Despacho
              If Empty(cBorDes)
                 Return(.t.)
              Else
                 DbSelectArea("SZA")
                 DbSetOrder(1)
                 If !DbSeek(xFilial("SZA")+cBorDes, .t.)
                    MsgAlert("Esse bordero de despacho não existe!", "Verifique...")
                    oBorDes:SetFocus()
                    Return(.f.)
                 Endif
                 If !Empty(cCodPro)
                    cQry1 := ""
                    cQry1 += "SELECT SUM(ZZC.ZZC_RETIRA) AS QUANTI "
                    cQry1 += "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
                    cQry1 += "WHERE ZZC.ZZC_FILIAL = '"+xFilial("ZZC")+"' "
                    cQry1 += "  AND ZZC.D_E_L_E_T_ = '' "
                    cQry1 += "  AND ZZC.ZZC_PRODUT = '"+cCodPro+"' "
                    If !Empty(cBorPed)
                       cQry1 += "  AND ZZC.ZZC_BORDER = '"+cBorPed+"' "
                    Endif
                    If !Empty(cBorDes)
                       cQry1 += "  AND ZZC.ZZC_CARGA = '"+cBorDes+"' "
                    Endif
                    If !Empty(cNumPed)
                       cQry1 += "  AND ZZC.ZZC_PEDIDO = '"+cNumPed+"' "
                    Endif
                    TCQuery cQry1 ALIAS "TCQRET" NEW
                    DbSelectArea("TCQRET")
                    nQtdPed := TCQRET->RETIRA
                    DbSelectArea("TCQRET")
                    DbCloseArea()
                 Endif
              Endif
       ElseIf nOpcVol == 3 //Validação do Pedido
              If Empty(cNumPed)
                 Return(.t.)
              Else
                 DbSelectArea("SC5")
                 DbSetOrder(1)
                 If !DbSeek(xFilial("SC5")+cNumPed, .t.)
                    MsgAlert("Esse bordero de despacho não existe!", "Verifique...")
                    oNumPed:SetFocus()
                    Return(.f.)
                 Endif
                 If !Empty(cCodPro)
                    cQry1 := ""
                    cQry1 += "SELECT SUM(ZZC.ZZC_RETIRA) AS QUANTI "
                    cQry1 += "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
                    cQry1 += "WHERE ZZC.ZZC_FILIAL = '"+xFilial("ZZC")+"' "
                    cQry1 += "  AND ZZC.D_E_L_E_T_ = '' "
                    cQry1 += "  AND ZZC.ZZC_PRODUT = '"+cCodPro+"' "
                    If !Empty(cBorPed)
                       cQry1 += "  AND ZZC.ZZC_BORDER = '"+cBorPed+"' "
                    Endif
                    If !Empty(cBorDes)
                       cQry1 += "  AND ZZC.ZZC_CARGA = '"+cBorDes+"' "
                    Endif
                    If !Empty(cNumPed)
                       cQry1 += "  AND ZZC.ZZC_PEDIDO = '"+cNumPed+"' "
                    Endif
                    TCQuery cQry1 ALIAS "TCQRET" NEW
                    DbSelectArea("TCQRET")
                    nQtdPed := TCQRET->RETIRA
                    DbSelectArea("TCQRET")
                    DbCloseArea()
                 Endif
              Endif
       ElseIf nOpcVol == 4 //Validação do Produto
              If Empty(cCodPro)
                 MsgStop("ATENÇÃO: Campo deve ter o preenchimento obrigatório!!!")
                 oCodPro:SetFocus()
                 Return(.f.)
              Else
                 DbSelectArea("SB1")
                 DbSetOrder(1)
                 If !DbSeek(xFilial("SB1")+cCodPro, .t.)
                    MsgAlert("Esse produto não existe!", "Verifique...")
                    oCodPro:SetFocus()
                    Return(.f.)
                 Endif
                 If !Empty(cBorPed) .or. !Empty(cBorDes) .or. !Empty(cNumPed)
                    cQry1 := ""
                    cQry1 += "SELECT SUM(ZZC.ZZC_RETIRA) AS QUANTI "
                    cQry1 += "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
                    cQry1 += "WHERE ZZC.ZZC_FILIAL = '"+xFilial("ZZC")+"' "
                    cQry1 += "  AND ZZC.D_E_L_E_T_ = '' "
                    cQry1 += "  AND ZZC.ZZC_PRODUT = '"+cCodPro+"' "
                    If !Empty(cBorPed)
                       cQry1 += "  AND ZZC.ZZC_BORDER = '"+cBorPed+"' "
                    Endif
                    If !Empty(cBorDes)
                       cQry1 += "  AND ZZC.ZZC_CARGA = '"+cBorDes+"' "
                    Endif
                    If !Empty(cNumPed)
                       cQry1 += "  AND ZZC.ZZC_PEDIDO = '"+cNumPed+"' "
                    Endif
                    TCQuery cQry1 ALIAS "TCQRET" NEW
                    DbSelectArea("TCQRET")
                    nQtdPed := TCQRET->QUANTI
                    DbSelectArea("TCQRET")
                    DbCloseArea()
                 Endif
              Endif
       ElseIf nOpcVol == 5 //Validação do Quantidade a Voltar.
              If nQtdVol > nQtdPed
                 MsgStop("ATENÇÃO: Quantidade deve ser menor ou igual a quantidade dos itens!!!")
                 oCodPro:SetFocus()
                 Return(.f.)
              ElseIf nQtdVol == 0
                     //MsgStop("ATENÇÃO: Quantidade deve ser maior que zero!!!")
                     //oCodPro:SetFocus()
                     //Return(.f.)
              Endif
       Endif
Return(.t.)

Static Function fVolBor()
       Local nY
       If Empty(cBorPed) .and. Empty(cBorDes)
          MsgStop("Atenção ao menos um dos borderos deve ter o numero preenchido.")
          Return(.f.)
       Endif
       cQry1 := ""
       cQry2 := ""
       cQry3 := ""
       cQry1 += "SELECT COUNT(*) AS QTDE "
       cQry2 += "SELECT ZZC.ZZC_PEDIDO, ZZC.ZZC_QUANTI, ZZC.ZZC_RETIRA, ZZC.ZZC_GAVETA "
       cQry3 += "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
       cQry3 += "WHERE ZZC.ZZC_FILIAL = '"+xFilial("ZZC")+"' "
       cQry3 += "  AND ZZC.D_E_L_E_T_ = '' "
       cQry3 += "  AND ZZC.ZZC_RETIRA > 0
       cQry3 += "  AND ZZC.ZZC_PRODUT = '"+cCodPro+"' "
       If !Empty(cBorPed)
          cQry3 += "  AND ZZC.ZZC_BORDER = '"+cBorPed+"' "
       Endif
       If !Empty(cBorDes)
          cQry3 += "  AND ZZC.ZZC_CARGA  = '"+cBorDes+"' "
       Endif
       If !Empty(cNumPed)
          cQry3 += "  AND ZZC.ZZC_PEDIDO = '"+cNumPed+"' "
       Endif
       cQry1 += cQry3
       cQry2 += cQry3 ; cQry2 += "ORDER BY ZZC.ZZC_RETIRA "
       TCQuery cQry1 ALIAS "QTCQ" NEW
       DbSelectArea("QTCQ")
       nQtdPro := QTCQ->QTDE
       DbSelectArea("QTCQ")
       DbCloseArea()

       If nQtdPro > 0
          If nQtdPro == 1
             cMsgUsu := "Foi encontrado "+Transform(nQtdPro, "@E 9999")+" registro. Volta ?"
          Else
             cMsgUsu := "Foram encontrados "+Transform(nQtdPro, "@E 9999")+" registros. Volta ?"
          Endif
          If MsgYesNo(cMsgUsu, "Confirmação...")
             If nQtdPro == 1
                TCQuery cQry2 ALIAS "QTCQ" NEW
                cQry1 := ""
                cQry1 += "UPDATE "+RetSqlName("ZZC")+" SET ZZC_RETIRA = "+StrZero((nQtdPed - nQtdVol), 4)+", ZZC_VOLRET = 0, ZZC_SEPARA = 'N' "
                If Empty(QTCQ->ZZC_GAVETA)
                   cQry1 += ", ZZC_GAVETA = '999' "
                Else
                   cQry1 += ", ZZC_GAVETA = '"+QTCQ->ZZC_GAVETA+"' "
                Endif
                cQry1 += "WHERE ZZC_FILIAL = '"+xFilial("ZZC")+"' AND D_E_L_E_T_ = '' AND ZZC_PRODUT = '"+cCodPro+"' "
                If !Empty(cBorPed)
                   cQry1 += "  AND ZZC_BORDER = '"+cBorPed+"' "
                Endif
                If !Empty(cBorDes)
                   cQry1 += "  AND ZZC_CARGA  = '"+cBorDes+"' "
                Endif
                If !Empty(cNumPed)
                   cQry1 += "  AND ZZC_PEDIDO = '"+cNumPed+"' "
                Endif
                If TCSQLExec(cQry1) == 0
                   MsgStop("Item retornado com sucesso!")
                Else
                   MsgStop("Houve algum problema no retorno do item!")
                Endif
                DbSelectArea("QTCQ")
                DbCloseArea()
             Else
                aPedVol := {}
                TCQuery cQry2 ALIAS "QTCQ" NEW
                DbSelectArea("QTCQ")
                DbGoTop()
                While !Eof()
                      If nQtdVol > QTCQ->ZZC_RETIRA
                         nQtdBai := 0
                         nQtdVol -= QTCQ->ZZC_RETIRA
                      Else
                         nQtdBai := QTCQ->ZZC_RETIRA - nQtdVol
                      Endif
                      cQry1 := ""
                      cQry1 += "UPDATE "+RetSqlName("ZZC")+" SET ZZC_RETIRA = "+StrZero((nQtdBai), 4)+", ZZC_VOLRET = 0, ZZC_SEPARA = 'N' "
                      If Empty(QTCQ->ZZC_GAVETA)
                         cQry1 += ", ZZC_GAVETA = '999' "
                      Else
                         cQry1 += ", ZZC_GAVETA = '"+QTCQ->ZZC_GAVETA+"' "
                      Endif
                      cQry1 += "WHERE ZZC_FILIAL = '"+xFilial("ZZC")+"' AND D_E_L_E_T_ = '' AND ZZC_PRODUT = '"+cCodPro+"' AND ZZC_PEDIDO = '"+QTCQ->ZZC_PEDIDO+"' "
                      If !Empty(cBorPed)
                         cQry1 += "  AND ZZC_BORDER = '"+cBorPed+"' "
                      Endif
                      If !Empty(cBorDes)
                         cQry1 += "  AND ZZC_CARGA  = '"+cBorDes+"' "
                      Endif
                      If !Empty(cNumPed)
                         cQry1 += "  AND ZZC_PEDIDO = '"+cNumPed+"' "
                      Endif
                      If TCSQLExec(cQry1) == 0
                         aAdd(aPedVol, {QTCQ->ZZC_PEDIDO, TransForm(nQtdBai, "@E 9999") })
                      Endif
                      DbSelectArea("QTCQ")
                      DbSkip()
                Enddo
                DbSelectArea("QTCQ")
                DbCloseArea()
                cMsgVol := "Itens retornados com sucesso!"+Chr(13)+Chr(10)
                For nY := 1 To Len(aPedVol)
                    cMsgVol += aPedVol[nY][1]+" - "+aPedVol[nY][2]+Chr(13)+Chr(10)
                Next
                MsgInfo(cMsgVol)
             Endif
          Endif
       Else
          MsgInfo("Não será processado nenhum produto com esses parâmetros!", "Informação...")
          Return Nil
       Endif
       _oDlg:End()
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ FATA02_A³ Autores ³ Luís G. de Souza       ³ Data ³ 09/08/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Endereçamento para borderos especificos                      ³±±
±±³           ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function FATA02_A()
     // Variaveis Locais da Funcao
     Local cBorPed := SZF->ZF_CODIGO
     Local oBorPed

     // Variaveis da Funcao de Controle e GertArea/RestArea
     Local _aArea  := {}
     Local _aAlias := {}
     // Variaveis Private da Funcao
     Private cCodLin := Space(200)
     Private cCodEmb := Space(200)
     Private oCodLin
     Private oCodEmb
     Private _oDlg      // Dialog Principal

     If SZF->ZF_TIPOBOR $ '1.2' .OR. EMPTY(Alltrim(SZF->ZF_TIPOBOR))  // POR EQTO SÓ NÃO ENDEREÇA CARGA PRA SP
		MsgBox("Bordero não pode ser endereçado!", "Atenção", "STOP")
		Return
	 Endif        	


     If !SZF->ZF_FLAG $ 'P'
        If SZF->ZF_FLAG $ 'D'
           MsgAlert("Favor seguir os seguintes passos: 'Endereçamento' / 'Retirada', e depois essa opção.")
           Return(.f.)
        ElseIf SZF->ZF_FLAG $ 'E'
               MsgAlert("Favor seguir os seguintes passos: 'Retirada', e depois essa opção.")
               Return(.f.)
        ElseIf SZF->ZF_FLAG $ 'T.R.X'
               MsgStop("ATENÇÃO: Essa opção não pode ser utilizada nesse status.")
               Return(.f.)
        Endif
     Endif
     DEFINE MSDIALOG _oDlg TITLE "Endereçamento para Borderos Específicos" FROM C(178), C(181) TO C(302), C(647) PIXEL
            // Defina aqui a chamada dos Aliases para o GetArea
            CtrlArea(1, @_aArea, @_aAlias, {"ZZC", "SZF", "SZG"}) // GetArea

            // Cria as Groups do Sistema
            @ C(015), C(000) TO C(064), C(235) LABEL ""                                        PIXEL OF _oDlg

            // Cria Componentes Padroes do Sistema
            @ C(003), C(000) Button "Confirma"         Size C(037), C(012) Action(fEndEsp())    PIXEL OF _oDlg
            @ C(003), C(198) Button "Cancela"          Size C(037), C(012) Action(_oDlg:End())  PIXEL OF _oDlg
            @ C(022), C(065) MsGet oBorPed Var cBorPed Size C(030), C(009) COLOR CLR_BLACK      PIXEL OF _oDlg
            @ C(023), C(003) Say "Bordero de Pedidos:" Size C(060), C(008) COLOR CLR_BLACK      PIXEL OF _oDlg
            @ C(035), C(065) MsGet oCodLin Var cCodLin Size C(125), C(009) COLOR CLR_BLACK      PIXEL OF _oDlg
            @ C(035), C(193) Button "Linhas"           Size C(037), C(009) Action(fMonOpc("L")) PIXEL OF _oDlg
            @ C(036), C(003) Say "Linha de Produtos:"  Size C(060), C(008) COLOR CLR_BLACK      PIXEL OF _oDlg
            @ C(048), C(065) MsGet oCodEmb Var cCodEmb Size C(125), C(009) COLOR CLR_BLACK      PIXEL OF _oDlg
            @ C(048), C(194) Button "Embalagens"       Size C(037), C(009) Action(fMonOpc("E")) PIXEL OF _oDlg
            @ C(049), C(003) Say "Embalagens:"         Size C(060), C(008) COLOR CLR_BLACK      PIXEL OF _oDlg
            oBorPed:lReadOnly := .t.
            oCodLin:lReadOnly := .t.
            oCodEmb:lReadOnly := .t.
            CtrlArea(2, _aArea, _aAlias) // RestArea

     ACTIVATE MSDIALOG _oDlg CENTERED 
Return(.T.)

/******************************************************************************************************************/
/*** fMonOpc - Monta opções de Linha e embalagem para endereçamento de borderos específicos.                    ***/
/******************************************************************************************************************/
Static Function fMonOpc(cOpcMen)
       // Variaveis Locais da Funcao
       Local cQry1   := ""
       Local cRetStr := ""
       // Variaveis da Funcao de Controle e GertArea/RestArea
       Local _aArea  := {}
       Local _aAlias := {}
       // Variaveis Private da Funcao
       Private _oDlg1 // Dialog Principal
       // Privates das ListBoxes
       Private oListBox1
       Private aOpcEsc   := {}

       If cOpcMen $ 'L'
          cQry1 += "SELECT SZ1.Z1_LINHA AS CODIGO, SZ1.Z1_DESCR AS DESCRICAO "
          cQry1 += "FROM "+RetSqlName("SZ1")+" SZ1 WITH (NOLOCK) "
          cQry1 += "WHERE SZ1.Z1_FILIAL = '"+xFilial("SZ1")+"' "
          cQry1 += "  AND SZ1.D_E_L_E_T_ = '' "
          cQry1 += "ORDER BY SZ1.Z1_LINHA "
       Else
          cQry1 += "SELECT SZ5.Z5_EMB AS CODIGO, SZ5.Z5_DESCR AS DESCRICAO "
          cQry1 += "FROM "+RetSqlName("SZ5")+" SZ5 WITH (NOLOCK) "
          cQry1 += "WHERE SZ5.Z5_FILIAL = '' "
          cQry1 += "  AND SZ5.D_E_L_E_T_ = '' "
          cQry1 += "  AND SZ5.Z5_EMB <> '00' "
          cQry1 += "ORDER BY SZ5.Z5_EMB "
       Endif
       TCQuery cQry1 ALIAS "TOPC" NEW
       DbSelectArea("TOPC")
       DbGoTop()
       While !Eof()
             aAdd(aOpcEsc, {.f., TOPC->CODIGO, TOPC->DESCRICAO})
             DbSelectArea("TOPC")
             DbSkip()
       EndDo
       DbSelectArea("TOPC")
       DbCloseArea()

       DEFINE MSDIALOG _oDlg1 TITLE Iif(cOpcMen $ 'L', "Linhas", "Embalagens") FROM C(178), C(181) TO C(363), C(420) PIXEL
              // Defina aqui a chamada dos Aliases para o GetArea
              CtrlArea(1, @_aArea, @_aAlias, {"SZ1", "SZ5"}) // GetArea

              // Cria Componentes Padroes do Sistema
              @ C(002), C(000) Button "Confirma" Size C(037), C(012) Action(cRetStr := fRetDad(), _oDlg1:End())    PIXEL OF _oDlg1
              @ C(002), C(085) Button "Cancela"  Size C(037), C(012) Action(_oDlg1:End()) PIXEL OF _oDlg1

              // Chamadas das ListBox do Sistema
              fListBox3()

              CtrlArea(2, _aArea, _aAlias) // RestArea
       ACTIVATE MSDIALOG _oDlg1 CENTERED
       If cOpcMen $ 'L'
          cCodLin := cRetStr
          oCodLin:Refresh()
       Else
          cCodEmb := cRetStr
          oCodEmb:Refresh()
       Endif
Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³fListBox1() ³ Autor ³ Luís Gustavo de Souza ³ Data ³09/08/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Montagem da ListBox                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fListBox3()
       Local oOk := LoadBitmap( GetResources(), "LBOK" )
       Local oNo := LoadBitmap( GetResources(), "LBNO" )
       // Para editar os Campos da ListBox inclua a linha abaixo
       // na opcao de DuploClick da mesma, ou onde for mais conveniente
       // lembre-se de mudar a picture respeitando a coluna a ser editada
       // PS: Para habilitar o DuploClick selecione a opção MarkBrowse da
       //     ListBox para SIM.
       // lEditCell( aListBox, oListBox, "@!", oListBox:ColPos )

       @ C(016), C(001) ListBox oListBox1 Fields ;
                        HEADER "", "Codigo", "Descrição";
                        Size C(120), C(078) Of _oDlg1 Pixel;
                        ColSizes 0, 20;
                        On DBLCLICK ( aOpcEsc[oListBox1:nAt,1] := !(aOpcEsc[oListBox1:nAt,1]), oListBox1:Refresh() )
       oListBox1:SetArray(aOpcEsc)

       oListBox1:bLine := {|| { If(aOpcEsc[oListBox1:nAT][1], oOk, oNo),;
                                   aOpcEsc[oListBox1:nAT][02],;
                                   aOpcEsc[oListBox1:nAT][03]}}
Return Nil

/******************************************************************************************************************/
/*** fRetDad - Retorna string com os dados de linhas/embalagens.                                                ***/
/******************************************************************************************************************/
Static Function fRetDad()
       Local cRetStr := ""
       Local nY
       For nY := 1 To Len(oListBox1:aArray)
           If oListBox1:aArray[nY][1]
              If Len(cRetStr) == 0
                 cRetStr += oListBox1:aArray[nY][2]
              Else
                 cRetStr += '.'+oListBox1:aArray[nY][2]
              Endif
           Endif
       Next
Return(cRetStr)

/******************************************************************************************************************/
/*** fEndEsp - Processa endereçamento para borderos específicos.                                                ***/
/******************************************************************************************************************/
Static Function fEndEsp()
       Local cQry1 := ""

       If Empty(cCodLin) .and. Empty(cCodEmb)
          If !MsgYesNo("Deseja endereçar todos os produtos do bordero "+SZF->ZF_CODIGO+", com gaveta específica (888)?", "Endereçar...")
             Return Nil
          Endif
       Endif
       If !Empty(cCodLin)
          cLinAux := " IN('"
          While !Empty(cCodLin)
                cLinAux += SubStr(cCodLin, 1, 2)+"', '"
                cCodLin := SubStr(cCodLin, 4, Len(cCodLin))
          Enddo
          cLinAux := SubStr(cLinAux, 1, Len(cLinAux) - 3)+')'
       Endif
       If !Empty(cCodEmb)
          cEmbAux := " IN('"
          While !Empty(cCodEmb)
                cEmbAux += SubStr(cCodEmb, 1, 2)+"', '"
                cCodEmb := SubStr(cCodEmb, 4, Len(cCodEmb))
          Enddo
          cEmbAux := SubStr(cEmbAux, 1, Len(cEmbAux) - 3)+')'
       Endif
       cQry1 += "SELECT COUNT(*) AS QTDE "
       cQry1 += "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
       cQry1 += "WHERE ZZC.ZZC_FILIAL = '"+xFilial("ZZC")+"' "
       cQry1 += "  AND ZZC.D_E_L_E_T_ = '' "
       cQry1 += "  AND ZZC.ZZC_BORDER = '"+SZF->ZF_CODIGO+"' "
       cQry1 += "  AND ZZC.ZZC_RETIRA < ZZC.ZZC_QUANTI "
       cQry1 += "  AND ZZC.ZZC_GAVETA = '' "
       If !Empty(cLinAux)
          cQry1 += "  AND SUBSTRING(ZZC.ZZC_PRODUT, 4, 2)"+cLinAux+" "
       Endif
       If !Empty(cEmbAux)
          cQry1 += "  AND SUBSTRING(ZZC.ZZC_PRODUT, 11, 2)"+cEmbAux+" "
       Endif
       TCQuery cQry1 ALIAS "QTCQ" NEW
       DbSelectArea("QTCQ")
       nQtdPro := QTCQ->QTDE
       DbSelectArea("QTCQ")
       DbCloseArea()

       If nQtdPro > 0
          If nQtdPro == 1
             cMsgUsu := "Foi encontrado "+Transform(nQtdPro, "@E 9999")+" registro. Endereça ?"
          Else
             cMsgUsu := "Foram encontrados "+Transform(nQtdPro, "@E 9999")+" registros. Endereça ?"
          Endif
          If MsgYesNo(cMsgUsu, "Confirmação...")
             cQry1 := ""
             cQry1 += "UPDATE "+RetSqlName("ZZC")+" SET ZZC_GAVETA = '888', ZZC_SEPARA = 'N' WHERE ZZC_FILIAL = '"+xFilial("ZZC")+"' AND D_E_L_E_T_ = '' AND ZZC_BORDER = '"+SZF->ZF_CODIGO+"' AND ZZC_RETIRA < ZZC_QUANTI AND ZZC_GAVETA = '' "
             If !Empty(cLinAux)
                cQry1 += "AND SUBSTRING(ZZC_PRODUT, 4, 2)"+cLinAux+" "
             Endif
             If !Empty(cEmbAux)
                cQry1 += "AND SUBSTRING(ZZC_PRODUT, 11, 2)"+cEmbAux+" "
             Endif
             TCSQLExec(cQry1)
          Endif
       Else
          MsgInfo("Não será processado nenhum produto com esses parâmetros!", "Informação...")
          Return Nil
       Endif
       _oDlg:End()
Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TransfBorPed ³ Autor ³  André Maester     ³ Data ³ 23/09/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³ 23/09/13³  Uso inicial do programa                     ³±±
±±³              ³  /  /   ³  Tranfere Pedido de um Bordero para outro    ³±±
±±³      					  existente ou cria um novo bordero           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function BrSeqBord()
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de cVariable dos componentes                                 ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     Private cGet1TBo   := Space(6)
     Private cGet2TBo   := Space(3)
     Private cGet3TBo   := Space(8)
     Private cGet4TBo   := Space(8)
     Private cSay1TBo   := Space(1)
     Private cSay2TBo   := Space(1)
     Private nRMenu1T  
     Private cMarca     := GetMark()

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oFont1", "oDlg1TBo", "oSay1TBo", "oSay2TBo", "oSay3TBo", "oSay4TBo", "oRMenu1T", "oGet1TBo", "oGet2TBo", "oGet3TBo", "oGet4TBo", "oBtn1TBo", "oBtn2TBo", "oBtn3TBo")

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oFont1     := TFont():New( "MS Sans Serif", 0, -17, , .T., 0, , 700, .F., .F., , , , , , )
     oDlg1TBo   := MSDialog():New( 091, 232, 556, 757, "Sequenciador de Endereços de Pedidos", , , .F., , , , , , .T., , , .T. )
     oSay1TBo   := TSay():New( 004, 003, {||"Bordero:"}  , oDlg1TBo, , oFont1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 064, 012)
     oGet1TBo   := TGet():New( 003, 041, {|u| If(PCount() > 0, cGet1TBo := u, cGet1TBo)}, oDlg1TBo, 040, 012, '', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .F., .F., "SZF", "cGet1TBo", , )
     oSay2TBo   := TSay():New( 004, 092, {||"Seq. Inicial:"}, oDlg1TBo, , oFont1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 068, 012)
     oGet2TBo   := TGet():New( 003, 142, {|u| If(PCount() > 0, cGet2TBo := u, cGet2TBo)}, oDlg1TBo, 025, 012, '', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .F., .F.,      , "cGet2TBo", , )
     oSay3TBo   := TSay():New( 215, 003, {||"Volumes:"}, oDlg1TBo, , oFont1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 068, 012)
     oGet3TBo   := TGet():New( 214, 045, {|u| If(PCount() > 0, cGet3TBo := u, cGet3TBo)}, oDlg1TBo, 040, 012, '', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .T., .F.,      , "cGet3TBo", , )
     oSay4TBo   := TSay():New( 215, 175, {||"Peso:"}, oDlg1TBo, , oFont1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 068, 012)
     oGet4TBo   := TGet():New( 214, 200, {|u| If(PCount() > 0, cGet4TBo := u, cGet4TBo)}, oDlg1TBo, 045, 012, '', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .T., .F.,      , "cGet4TBo", , )
     //GoRMenu1   := TGroup():New( 004, 004, 034, 080, "", oDlg1TBo, CLR_BLACK, CLR_WHITE, .T., .F. )
     //oRMenu1T   := TRadMenu():New( 008, 010, {"1 Pedido", "Multiplos Pedidos"}, {|u| If(PCount() > 0, nRMenu1T := u, nRMenu1T)}, oDlg1TBo, , , CLR_BLACK, CLR_WHITE, "", , , 056, 16, , .F., .F., .T. )

     oBtn1TBo   := TButton():New( 002, 226, "Sair"        , oDlg1TBo, { || oDlg1TBo:End() }, 037, 012, , , , .T., , "", , , , .F. )
     oBtn2TBo   := TButton():New( 019, 226, "Gravar"      , oDlg1TBo, { || fGravEnd()     }, 037, 012, , , , .T., , "", , , , .F. )
     oBtn3TBo   := TButton():New( 002, 181, "Gerar Seq"   , oDlg1TBo, { || fComTran()     }, 037, 012, , , , .T., , "", , , , .F. )
     
     oTbl1TBo()
     DbSelectArea("TMPTBO")
     oBrw1TBo   := MsSelect():New( "TMPTBO", "MARCA", "", { {"MARCA", "", "", ""}, {"PEDID", "", "Pedido", "99999999"}, {"NOMCL", "", "Nome Cliente", "@!"}, {"PALLE", "", "Pallets", "999"}, {"_LOCAL", "", "Localizacao", "@!"}  }, .F., cMarca, {036, 004, 210, 262}, , , oDlg1TBo ) 
     oBrw1TBo:oBrowse:lColDrag    := .t.
     oBrw1TBo:oBrowse:lHasMark    := .t.
     oBrw1TBo:oBrowse:lCanAllmark := .t.
     oBrw1TBo:oBrowse:bAllMark    := {|| InvTrans(cMarca, @oBrw1TBo) }
     oGet1TBo:bValid := {|| fValBorDe() }
     //oGet2TBo:bValid := {|| fValBorPa() }
     oDlg1TBo:Activate(,,,.T.)
     DbSelectArea("TMPTBO")
     DbCloseArea()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTbl1TBo() - Cria temporario para o Alias: TMPTBO
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTbl1TBo()
       Local aFds := {}
       //Local cTmp

       
       Aadd( aFds , {"MARCA", "C", 002, 000} )
       Aadd( aFds , {"PEDID", "C", 008, 000} )
       Aadd( aFds , {"NOMCL", "C", 040, 000} )
       Aadd( aFds , {"_LOCAL", "C", 015, 000} )
       Aadd( aFds , {"PALLE", "N", 004, 000} )

       //Aadd( aFds , {"VOLUM", "N", 005, 000} )
       /*
       cTmp := U_NovoArqTrab("dbf") 
       dbcreate(cTmp+".dbf", aFds, "DBFCDXADS")
       Use (cTmp+".Dbf") Alias "TMPTBO" VIA "DBFCDXADS" New Exclusive
       Index On PEDID To (cTmp)      
       */
       
       oTempTb0l := FWTemporaryTable():New( 'TMPTBO' )
       oTempTb0l:SetFields( aFds )
       oTempTb0l:AddIndex( "cInd01", { "PEDID" } )
       oTempTb0l:Create()       
       
Return

Static Function fValBorDe()

       Local nVolBor :=0
       Local nPesBor :=0
       DbSelectArea("TMPTBO")
       Zap
       If !Posicione("SZF", 1, xFilial("SZF")+cGet1TBo, "ZF_FLAG") $ 'D' //DIGITADO 
          MsgStop("Atenção, o status desse bordero não permite fazer alterações.")
          cGet1TBo := space(06)
          oGet1TBo:Refresh()
          Return
       Endif
       cGet2TBo := space(03)
       oGet2TBo:Refresh()
       DbSelectArea("SZG")
       DbSetOrder(1)
       DbSeek(xFilial("SZG")+cGet1TBo, .t.)
       If Found()
          While !Eof() .and. (SZG->ZG_FILIAL == xFilial("SZG"))  .and. (Alltrim(SZG->ZG_CODIGO) == Alltrim(cGet1TBo))
                RecLock("TMPTBO", .t.)
                   TMPTBO->PEDID := SZG->ZG_PEDIDO
                   TMPTBO->NOMCL := Posicione("SA1", 1, xFilial("SA1")+Posicione("SC5", 1, xFilial("SC5")+SubStr(SZG->ZG_PEDIDO, 3, 6), "C5_CLIENTE"), "A1_NOME")
                   TMPTBO->_LOCAL := SZG->ZG_LOCALIZ
                   TMPTBO->PALLE := IIf(Ceiling(Posicione("SC5", 1, xFilial("SC5")+SubStr(SZG->ZG_PEDIDO, 3, 6), "C5_VOLUME2"))=0,1,Ceiling(Posicione("SC5", 1, xFilial("SC5")+SubStr(SZG->ZG_PEDIDO, 3, 6), "C5_VOLUME2")))
                   //TMPTBO->VOLUM := Posicione("SC5", 1, xFilial("SC5")+SubStr(SZG->ZG_PEDIDO, 3, 6), "C5_VOLUME1")
                MsUnLock()
                nPesBor += Posicione("SC5", 1, xFilial("SC5")+SubStr(SZG->ZG_PEDIDO, 3, 6), "C5_PBRUTO")
                nVolBor += Posicione("SC5", 1, xFilial("SC5")+SubStr(SZG->ZG_PEDIDO, 3, 6), "C5_VOLUME1")
                DbSelectArea("SZG")
                DbSkip()
          EndDo
       Endif
       DbSelectArea("TMPTBO")
       DbGoTop()
       //oBrw1TBo:oBrowse:lReadOnly := .t.
       oBrw1TBo:oBrowse:Refresh()
       cGet3TBo := nVolBor
       cGet4TBo := Transform(nPesBor, '@E 999,999,999.99')
       oGet2TBo:SetFocus()
Return

Static Function InvTrans(cMarca, oBrw1TBo)
	
	Local nReg := TMPTBO->(Recno())
    
    DbSelectArea("TMPTBO")
    DbGoTop()
    
    While !Eof()
    	RecLock("TMPTBO", .f.)
        If TMPTBO->MARCA == cMarca
        	TMPTBO->MARCA := "  "
        Else
            TMPTBO->MARCA := cMarca
        Endif
        MsUnLock()
        DbSkip()
    Enddo
    TMPTBO->(dbGoto(nReg))
    oBrw1TBo:oBrowse:Refresh(.t.)
    
Return

Static Function fComTran()

       If Empty(cGet1TBo) .or. (Len(Alltrim(cGet2TBo)) <> 3)
          Return
       Endif

       cStrSZG := "('"

       nSeqIni := Val(cGet2TBo)

       DbSelectArea("TMPTBO")
       DbGoTop()

       While !Eof()
	       If IsMark("MARCA", cMarca)
			  If Iif(TMPTBO->PALLE = 1, nSeqIni, (nSeqIni+TMPTBO->PALLE-1)) >=1000 
			     nSeqIni := 1		
			  Endif
			  Localiz := Iif(TMPTBO->PALLE = 1, StrZero((nSeqIni),3), StrZero(nSeqIni,3)+'/'+StrZero((nSeqIni+TMPTBO->PALLE-1),3))
	   		  TMPTBO->_LOCAL = 'SP'+Localiz
              cStrSZG += Substr(TMPTBO->PEDID,3,6)+"', '"
           Endif
           nSeqIni += (TMPTBO->PALLE) 
           DbSelectArea("TMPTBO")
           DbSkip() 
       EndDo
		
       DbSelectArea("TMPTBO")
       DbGoTop()
Return

Static Function fGravEnd()

       Local lcontinua := .f.

       If Empty(cGet1TBo) .or. (Len(Alltrim(cGet2TBo)) <> 3)
          MsgStop("Não é possível fazer o endereçamento, escolha o Borderô e informe a sequencia corretamente ")
          Return
       Endif

       If MsgYesNo("Grava Endereçamento gerado ?", "Atenção")

	       DbSelectArea("TMPTBO")
    	   DbGoTop()
	       While !Eof()
		       If IsMark("MARCA", cMarca)
    	       	  lcontinua := .t.
        	   Endif
	           DbSelectArea("TMPTBO")
    	       DbSkip() 
    	   Enddo 
    	   
    	   If lcontinua
    	   	
		       DbSelectArea("TMPTBO")
		       DbGoTop()
	
    		   While !Eof()
			       If IsMark("MARCA", cMarca)
				       DbSelectArea("SZG")
			    	   DbSetOrder(1)
			    	   DbSeek(xFilial("SZG")+cGet1TBo+TMPTBO->PEDID ,.t.)     // Filial + Bordero + Pedido
				       If Found()
	    	               RecLock("SZG", .f.)
    	    	               SZG->ZG_LOCALIZ := TMPTBO->_LOCAL
                	       MsUnLock()
				       Endif
		   		   Endif
	    	       DbSelectArea("TMPTBO")
    	    	   DbSkip() 
		       Enddo
               DbSelectArea("SZG")
               DbCloseArea()
		   Else
				MsgBox("É preciso marcar algum pedido antes endereçar !!", "Atenção", "INFO")
				oBrw1TBo:oBrowse:SetFocus()
				oBrw1TBo:oBrowse:Refresh()
		   Endif		
       Endif
 
       DbSelectArea("TMPTBO")
  	   DbGoTop()       
		
Return


User Function BxRetBipe()

	//Local vetorWfFaltante := {}
	Local countVetorFaltante := wfLaco:= 1
	Local cSZFBORD
	Local wfFlag := 0
	//Local aArea  := GetArea()
	Local cAssunto  
	Local cMsg   := ""
	Local NTOTAL := 0
	Local cQry1  := "" 
    If !MsgYesNo("Confirma geração da lista de faltantes para o Borderô "+SZF->ZF_CODIGO+" ?", "Pergunta...")
    	Return
    Endif    

    ProcRegua(150)

    If SZF->ZF_FLAG $ 'D' //Permite criar as faltas dos itens comprados pela rotina de monta compras

        DbSelectArea("SZG")
        DbSetOrder(1)
        DbSeek(xFilial("SZG")+SZF->ZF_CODIGO, .t.)

        If Found()
        	While !Eof() .and. (SZG->ZG_FILIAL == XFilial("SZG")) .and. (SZG->ZG_CODIGO == SZF->ZF_CODIGO)
         		cQry1 := ""
           	    cQry1 += " SELECT SC6.C6_NUM, SC6.C6_PRODUTO AS PRODUTO, SC6.C6_QTDVEN AS QUANTI, SC6.C6_VOLITEM AS VOLUME,SB2.B2_LOCALIZ,SB1.B1_DESC,SB1.B1_ESTOQUE, "
				cQry1 += " SC6.C6_PALLET AS OCUPAC, '' AS DTHOT, 'B' AS TPINCL, '' AS LOCEXP, 0 AS RESERV, ISNULL(SUM(ZZK_QUANT),0) AS ZZK_QUANT "
				cQry1 += " FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "
				cQry1 += " LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH(NOLOCK) ON C6_FILIAL = ZZK_FILIAL AND C6_NUM = ZZK_PEDIDO AND C6_PRODUTO = ZZK_PRODUT AND ZZK.D_E_L_E_T_ ='' "
				cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON B1_FILIAL = C6_FILIAL AND B1_COD = C6_PRODUTO AND SB1.D_E_L_E_T_ ='' "
				cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH(NOLOCK) ON B2_FILIAL = B1_FILIAL AND B2_LOCAL = B1_LOCPAD AND B2_COD = B1_COD AND SB2.D_E_L_E_T_ ='' "
				cQry1 += " LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH(NOLOCK) ON F4_FILIAL  ='"+XFilial("SF4")+"' AND F4_CODIGO = C6_TES AND SF4.D_E_L_E_T_ ='' "
				cQry1 += " WHERE SC6.C6_FILIAL  = '"+xFilial("SC6")+"'" 
				cQry1 += " AND SC6.D_E_L_E_T_   = '' "
				cQry1 += " AND SF4.F4_ESTOQUE   = 'S' "
				cQry1 += " AND SC6.C6_NUM = '"+SubStr(SZG->ZG_PEDIDO, 3, 6)+"' "
				cQry1 += " GROUP BY SC6.C6_NUM, SC6.C6_PRODUTO, SC6.C6_QTDVEN, SC6.C6_VOLITEM, SC6.C6_PALLET,SB2.B2_LOCALIZ,SB1.B1_DESC,SB1.B1_ESTOQUE "
				cQry1 += " ORDER BY SC6.C6_NUM, SC6.C6_PRODUTO"
                
                TCQuery cQry1 ALIAS "TCQSC6" NEW
                DbSelectArea("TCQSC6")
                DbGoTop()
                	While !Eof()
                    	IncProc()
                        DbSelectArea("ZZC")
                        //DbSetOrder(1)
                        //DbSeek(xFilial("ZZC")+SZF->ZF_CODIGO+SubStr(SZG->ZG_PEDIDO, 3, 6)+TCQSC6->PRODUTO, .t.)
                        DbSetOrder(2)
				        DbSeek(xFilial("ZZC")+TCQSC6->C6_NUM+TCQSC6->PRODUTO, .t.)
                        If Found()
                        	RecLock("ZZC", .f.)
                            	ZZC->ZZC_QUANTI := TCQSC6->QUANTI
                                ZZC->ZZC_RETIRA := TCQSC6->ZZK_QUANT
		                        ZZC->ZZC_BORDER := SZF->ZF_CODIGO
		                        ZZC->ZZC_GAVETA := Iif(TCQSC6->ZZK_QUANT = TCQSC6->QUANTI, Space(03),'999')
                                ZZC->ZZC_VOLUME := TCQSC6->VOLUME
                                ZZC->ZZC_VOLRET := Iif(TCQSC6->ZZK_QUANT = TCQSC6->QUANTI, TCQSC6->VOLUME, 0)
                                ZZC->ZZC_CARGA  := Posicione("SZB", 2, xFilial("SZB")+SubStr(SZG->ZG_PEDIDO, 3, 6), "ZB_CODIGO")
                                ZZC->ZZC_OCUPAC := TCQSC6->OCUPAC
                                ZZC->ZZC_DESPAC := 'N'
                                ZZC->ZZC_SEPARA := Iif(TCQSC6->ZZK_QUANT = TCQSC6->QUANTI,'S','N')
                                ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
                                ZZC->ZZC_TPINCL := 'B'
                                ZZC->ZZC_GAVETA := Iif(TCQSC6->ZZK_QUANT = TCQSC6->QUANTI, Space(03),'999')
                                MsUnLock()
                        Else
                        	RecLock("ZZC", .t.)
                            	ZZC->ZZC_FILIAL := xFilial("ZZC")
                                ZZC->ZZC_BORDER := SZF->ZF_CODIGO
                                ZZC->ZZC_PEDIDO := SubStr(SZG->ZG_PEDIDO, 3, 6)
                                ZZC->ZZC_PRODUT := TCQSC6->PRODUTO
                                ZZC->ZZC_QUANTI := TCQSC6->QUANTI
                                ZZC->ZZC_RETIRA := TCQSC6->ZZK_QUANT
                                ZZC->ZZC_VOLUME := TCQSC6->VOLUME
                                ZZC->ZZC_VOLRET := Iif(TCQSC6->ZZK_QUANT = TCQSC6->QUANTI, TCQSC6->VOLUME, 0)
                                ZZC->ZZC_CARGA  := Posicione("SZB", 2, xFilial("SZB")+SZG->ZG_PEDIDO, "ZB_CODIGO")
                                ZZC->ZZC_OCUPAC := TCQSC6->OCUPAC
                                ZZC->ZZC_GAVETA := Iif(TCQSC6->ZZK_QUANT = TCQSC6->QUANTI, Space(03),'999')
                                ZZC->ZZC_TPINCL := 'B'
                                ZZC->ZZC_DESPAC := 'N'
                                ZZC->ZZC_SEPARA := Iif(TCQSC6->ZZK_QUANT = TCQSC6->QUANTI,'S','N')
                                ZZC->ZZC_LOTE   := Space(06)
                                ZZC->ZZC_SEMID  := Space(01)
                                ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
                                ZZC->ZZC_LOCEXP := Space(09)
                                ZZC->ZZC_RESERV := 0.0
                         	MsUnLock()
                        Endif 
						//Verifica se o produto tem faltante e se o local é diferente de vazio, se afirmativo guarda os valores em um vetor para enviar via Worflow //-- Marcelo                               
                        If (TCQSC6->QUANTI - TCQSC6->ZZK_QUANT > 0) .AND. !Empty(TCQSC6->B2_LOCALIZ) .AND. SUBSTR(TCQSC6->PRODUTO,4,2) <> '55'
    	                    //aAdd(vetorWfFaltante,{TCQSC6->PRODUTO,TCQSC6->B1_DESC,TCQSC6->B2_LOCALIZ})
							//countVetorFaltante += 1
                           	wfFlag := 1
                        EndIf 
                        cSZFBORD := SZF->ZF_CODIGO
                        DbSelectArea("TCQSC6")
                        DbSkip()                                                        
                    Enddo
                    DbSelectArea("TCQSC6")
                    DbCloseArea()

                DbSelectArea("SZG")
                DbSkip()
            Enddo
        Endif

        DbSelectArea("SZF")
        RecLock("SZF", .f.)     // X - Comprado por Bipe
       	    SZF->ZF_FLAG := 'Y' // Y - Complemento comprado na Rampa
        MsUnLock()              // Z - Totalmente Bipado

    	Messagebox("Rotina executada com Sucesso !","Atenção...",48)

    Else
	    Messagebox("Status do Borderô não permite executar esta rotina!","Atenção...",48)
    Endif

	// se flag igual a 1, significa que pedido tem protudo(s) faltante.
	If wfFlag == 1
        /*
        cQry1 := "" 
    	cQry1 += " SELECT DISTINCT ZG_CODIGO, SC6.C6_PRODUTO AS PRODUTO, SB1.B1_DESC, SB2.B2_LOCALIZ "  
    	cQry1 += " FROM "+RetSqlName("SZG")+" SZG WITH(NOLOCK) "
    	cQry1 += " LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH(NOLOCK) ON C6_FILIAL = ZG_FILIAL AND C6_NUM = SUBSTRING(ZG_PEDIDO,3,6) AND SZG.D_E_L_E_T_ ='' "
    	cQry1 += " LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH(NOLOCK) ON C6_FILIAL = ZZK_FILIAL AND C6_NUM = ZZK_PEDIDO AND C6_PRODUTO = ZZK_PRODUT AND ZZK.D_E_L_E_T_ ='' "
    	cQry1 += " LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH(NOLOCK) ON F4_FILIAL  =F4_FILIAL AND F4_CODIGO = C6_TES AND SF4.D_E_L_E_T_ ='' " 
    	cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON B1_FILIAL = C6_FILIAL AND B1_COD = C6_PRODUTO AND SB1.D_E_L_E_T_ ='' " 
    	cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH(NOLOCK) ON B2_FILIAL = B1_FILIAL AND B2_LOCAL = B1_LOCPAD AND B2_COD = B1_COD AND SB2.D_E_L_E_T_ ='' "
    	cQry1 += " WHERE SZG.D_E_L_E_T_ ='' "
    	cQry1 += " AND ZG_FILIAL = '"+xFilial("SZG")+"'"
    	cQry1 += " AND ZG_CODIGO = '"+cSZFBORD+"'"
    	cQry1 += " AND SF4.F4_ESTOQUE = 'S' "
    	cQry1 += " AND SB2.B2_LOCALIZ <>'' AND B1_GRUPO NOT IN('PA55') " 
    	cQry1 += " GROUP BY ZG_CODIGO, SC6.C6_PRODUTO, SC6.C6_QTDVEN, SB2.B2_LOCALIZ,SB1.B1_DESC "
    	cQry1 += " HAVING C6_QTDVEN > ISNULL(SUM(ZZK_QUANT),0) "
    	cQry1 += " ORDER BY ZG_CODIGO, SC6.C6_PRODUTO, SB2.B2_LOCALIZ "  */
    	
        cQry1 := "" 
    	cQry1 += " WITH TMP AS(SELECT ZG_CODIGO, SC6.C6_PRODUTO AS PRODUTO, SB1.B1_DESC, SB2.B2_LOCALIZ, (C6_VOLITEM -ISNULL(COUNT(ZZK_QUANT),0)) AS 'FALTA'
    	cQry1 += " FROM "+RetSqlName("SZG")+" SZG WITH(NOLOCK) "
    	cQry1 += " LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH(NOLOCK) ON C6_FILIAL = ZG_FILIAL AND C6_NUM = SUBSTRING(ZG_PEDIDO,3,6) AND SZG.D_E_L_E_T_ ='' "
    	cQry1 += " LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH(NOLOCK) ON C6_FILIAL = ZZK_FILIAL AND C6_NUM = ZZK_PEDIDO AND C6_PRODUTO = ZZK_PRODUT AND ZZK.D_E_L_E_T_ ='' "
    	cQry1 += " LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH(NOLOCK) ON F4_FILIAL  =F4_FILIAL AND F4_CODIGO = C6_TES AND SF4.D_E_L_E_T_ ='' " 
    	cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON B1_FILIAL = C6_FILIAL AND B1_COD = C6_PRODUTO AND SB1.D_E_L_E_T_ ='' " 
    	cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH(NOLOCK) ON B2_FILIAL = B1_FILIAL AND B2_LOCAL = B1_LOCPAD AND B2_COD = B1_COD AND SB2.D_E_L_E_T_ ='' "
    	cQry1 += " WHERE SZG.D_E_L_E_T_ ='' "
    	cQry1 += " AND ZG_FILIAL = '"+xFilial("SZG")+"'"
    	cQry1 += " AND ZG_CODIGO = '"+cSZFBORD+"'"
    	cQry1 += " AND SF4.F4_ESTOQUE = 'S' "
    	cQry1 += " AND SB2.B2_LOCALIZ <>'' AND B1_GRUPO NOT IN('PA55') " 
    	cQry1 += " GROUP BY ZG_CODIGO, SC6.C6_PRODUTO, SC6.C6_QTDVEN, SB2.B2_LOCALIZ,SB1.B1_DESC, C6_VOLITEM "
    	cQry1 += " HAVING C6_QTDVEN > ISNULL(SUM(ZZK_QUANT),0) ) "
    	cQry1 += " SELECT ZG_CODIGO, PRODUTO, B1_DESC, B2_LOCALIZ, SUM(FALTA) AS FALTA FROM TMP "
    	cQry1 += " GROUP BY ZG_CODIGO, PRODUTO, B2_LOCALIZ, B1_DESC "
    	cQry1 += " ORDER BY ZG_CODIGO, PRODUTO, B2_LOCALIZ "
    	

        TCQuery cQry1 ALIAS "TCQSZG" NEW
        DbSelectArea("TCQSZG")

   		If !Eof() //se o arquivo estiver vazio, sai da rotina

			/**		Monta o script HTML para ser enviado por email 	**/        
			cMsg:="<html>"
			cMsg+="<body>"
			cMsg+="<table width='1400' height='92' border='0' font size='1'>"
			cMsg+="<tr><th height='30'  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>BORDERO</th>"
			cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>PRODUTO</th>" 
			cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>DESCRIÇÃO</th>" 
			cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>LOCALIZAÇÃO</th>"
			cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>VOL. FALT</th>"
			cMsg+="</tr>"    
	        //#FFD7D7   #ECFFEC
        	DbSelectArea("TCQSZG")
		   	While !Eof()
				cMsg+="<tr>"
				cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim(TCQSZG->ZG_CODIGO)+"</td>"
				cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim(TCQSZG->PRODUTO)+"</td>"
				cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim(TCQSZG->B1_DESC)+"</td>"
				cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim(TCQSZG->B2_LOCALIZ)+"</td>"
		   	    cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+STR(TCQSZG->FALTA)+"</td>"
				cMsg+="</tr>"
				NTOTAL += TCQSZG->FALTA
                DbSelectArea("TCQSZG")
			    DbSkip()
  			End
			cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>BRFATA02</th>" 
			cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'></th>" 
			cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'></th>" 
			cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>TOTAL</th>" 
			cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>"+STR(NTOTAL)+"</th>" 

			cMsg+="</table>"
  			cMsg+="</body>"
	  		cMsg+="</html>" 
   

			DbSelectArea("TCQSZG")
            DbCloseArea() 
			cAssunto := "Falta de produtos de estoque na compra do Borderô -> "+cSZFBORD    
 		    tfMail(cAssunto,cMsg)
	    Endif
	EndIf

Return

User Function BRRepFal()

	Private cGet1Tr   := Space(6) 


	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±	
	±± Declaração de Variaveis Private dos Objetos                             ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    
	SetPrvt("oFontTr1", "oFontTr2", "oDlg1Tr", "oSay1Tr", "oSay2Tr", "oSay3Tr", "oGet1Tr")

    /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
    ±± Definicao do Dialog e todos os seus componentes.                        ±±
    Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    oFontTr1  := TFont():New( "MS Sans Serif", 0, -19, , .T., 0, , 700, .F., .F., , , , , , )
    oFontTr2  := TFont():New( "MS Sans Serif", 0, -19, , .F., 0, , 400, .F., .F., , , , , , )
    oDlg1Tr   := MSDialog():New( 258, 232, 383, 570, "Reprocessa Faltas", , , .F., , , , , , .T., , , .T. )


    oSay1Tr   := TSay():New( 023, 008, {|| "Pedido.:"     }, oDlg1Tr, , oFontTr1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 032, 012)
    oGet1Tr   := TGet():New( 020, 047, {|u| If(PCount() > 0, cGet1Tr := u, cGet1Tr)}, oDlg1Tr, 088, 018, '@!'             , , CLR_BLACK, CLR_WHITE, oFontTr1, , , .T., "", , , .F., .F., , .F. , .F., ""      ,"cGet1Tr", , )

    oBtn1Tr   := TButton():New( 046, 122, "Confirma", oDlg1Tr, {|| FReproFaltas(cGet1Tr)}  , 048, 014, , oFontTr2, , .T., , "", , , , .F. )
    oDlg1Tr:Activate( , , , .T.)

	
Return

Static Function FReproFaltas(cNumPed)	
    
    //Local aArea 	  := GetArea()
    Local cQry1 := ""
    If !MsgYesNo("Confirma atualização de Faltas / Produtos Bipados para o Pedido "+cNumPed+" ?", "Pergunta...")
    	Return
    Endif    

    ProcRegua(50)
    Begin Transaction
    	DbSelectArea("ZZC")
    	DbSetOrder(2)
    	DbSeek(xFilial("ZZC")+cNumPed, .t.)
    	If Found()
    		While !Eof() .and. (ZZC->ZZC_FILIAL == xFilial("ZZC")) .and. (Alltrim(cNumPed)== Alltrim(ZZC->ZZC_PEDIDO))
    			RecLock("ZZC", .f.) 
    				DbDelete()
    			MsUnLock()
    			DbSelectArea("ZZC")
    			DbSkip()
    		Enddo
    	Endif
 
    	DbSelectArea("ZZC")
    	DbCloseArea()

    	cQry1 := ""
    	cQry1 += " SELECT SC6.C6_NUM, SC6.C6_PRODUTO AS PRODUTO, SC6.C6_QTDVEN AS QUANTI, SC6.C6_VOLITEM AS VOLUME, SC6.C6_PALLET AS OCUPAC, '' AS DTHOT, 'B' AS TPINCL, '' AS LOCEXP, 0 AS RESERV, ISNULL(SUM(ZZK_QUANT),0) AS ZZK_QUANT "
    	cQry1 += " FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "
    	cQry1 += " LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH(NOLOCK) ON C6_FILIAL = ZZK_FILIAL AND C6_NUM = ZZK_PEDIDO AND C6_PRODUTO = ZZK_PRODUT AND ZZK.D_E_L_E_T_ ='' "
    	cQry1 += " LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH(NOLOCK) ON F4_FILIAL  ='"+XFilial("SF4")+"' AND F4_CODIGO = C6_TES AND SF4.D_E_L_E_T_ ='' "
    	cQry1 += " WHERE SC6.C6_FILIAL  = '"+xFilial("SC6")+"' "
    	cQry1 += " AND SC6.D_E_L_E_T_ = '' "
    	cQry1 += " AND SC6.C6_NUM     = '"+cNumPed+"' "
    	cQry1 += " AND SF4.F4_ESTOQUE = 'S' "
    	cQry1 += " GROUP BY SC6.C6_NUM, SC6.C6_PRODUTO, SC6.C6_QTDVEN, SC6.C6_VOLITEM, SC6.C6_PALLET "
    	cQry1 += " ORDER BY SC6.C6_NUM, SC6.C6_PRODUTO "
                
    	TCQuery cQry1 ALIAS "TCQSC6" NEW
    	DbSelectArea("TCQSC6")
    	DbGoTop()

    	While !Eof()
    		IncProc()
    		DbSelectArea("ZZC")
    		DbSetOrder(2)
    		DbSeek(xFilial("ZZC")+TCQSC6->C6_NUM+TCQSC6->PRODUTO, .t.)
    		If !Found() 
    			RecLock("ZZC", .t.)
    				ZZC->ZZC_FILIAL := xFilial("ZZC")
    				ZZC->ZZC_BORDER := Posicione("SZG", 2, xFilial("SZG")+'01'+TCQSC6->C6_NUM, "ZG_CODIGO")
    				ZZC->ZZC_PEDIDO := TCQSC6->C6_NUM
    				ZZC->ZZC_PRODUT := TCQSC6->PRODUTO
    				ZZC->ZZC_QUANTI := TCQSC6->QUANTI
    				ZZC->ZZC_RETIRA := TCQSC6->ZZK_QUANT
    				ZZC->ZZC_VOLUME := TCQSC6->VOLUME
    				ZZC->ZZC_VOLRET := Iif(TCQSC6->ZZK_QUANT = TCQSC6->QUANTI, TCQSC6->VOLUME, 0)
    				ZZC->ZZC_CARGA  := Posicione("SZB", 2, xFilial("SZB")+'01'+TCQSC6->C6_NUM, "ZB_CODIGO")
    				ZZC->ZZC_OCUPAC := TCQSC6->OCUPAC
    				ZZC->ZZC_GAVETA := Iif(TCQSC6->ZZK_QUANT = TCQSC6->QUANTI, Space(03),'999')
    				ZZC->ZZC_TPINCL := 'B'
    				ZZC->ZZC_DESPAC := 'N'
    				ZZC->ZZC_SEPARA := Iif(TCQSC6->ZZK_QUANT = TCQSC6->QUANTI,'S','N')
    				ZZC->ZZC_LOTE   := Space(06)
    				ZZC->ZZC_SEMID  := Space(01)
    				ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
    				ZZC->ZZC_LOCEXP := Space(09)
    				ZZC->ZZC_RESERV := 0.0
    			MsUnLock()
    		Endif
    		DbSelectArea("TCQSC6")
    		DbSkip()
    	Enddo

    	DbSelectArea("ZZC")
    	DbCloseArea()
    
    	DbSelectArea("TCQSC6")
    	DbCloseArea()

    	// LIMPAR BIP DE PEDIDOS EXCLUÍDOS
        If MsgYesNo("Todos os itens QUE FORAM bipados e EXCLUÍDOS do pedido "+cNumPed+" serão desmontados, confirma ?", "Pergunta...")

      		DbSelectArea("ZZK")
        	DbSetOrder(6)
        	DbSeek(xFilial("ZZK")+cNumPed, .t.)
        	If Found() 
        		While !Eof() .and. (ZZK->ZZK_FILIAL == xFilial("ZZK")) .and. (Alltrim(cNumPed)== Alltrim(ZZK->ZZK_PEDIDO))
        			DbSelectArea("SC6")
        			DbSetOrder(2) // PRODUTO + NUM PEDIDO + ITEM
        			DbSeek(xFilial("SC6")+ZZK->ZZK_PRODUT+ZZK->ZZK_PEDIDO, .t.)
        			If !Found() 
        				RecLock("ZZK", .f.) 
        					DbDelete()
        				MsUnLock()
    				Endif
    				DbSelectArea("SC6")
       				DbCloseArea()
        			
        			DbSelectArea("ZZK")
        			DbSkip()
    			Enddo	        	
    	    Endif
 		
       		
       		DbSelectArea("ZZK")
       		DbCloseArea()

        Endif  
    
    End Transaction

    oDlg1Tr:End()  
	
	Messagebox("Reprocessamento executado com sucesso !","Atenção...",48)    
Return

/*
/******************************************************************************************************************/
/*** FATA02_9 - Atualiza Status do Bordero de Pedidos			                                                ***/
/******************************************************************************************************************/

User Function FATA02_9()

Local 	cQry1 := ""

    ProcRegua(50)
    
	cQry1 += " 	SELECT ZF_CODIGO  "
	cQry1 += " 	FROM "+RetSqlName("SZF")+" SZF WITH(NOLOCK) "
	cQry1 += " 	LEFT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH(NOLOCK) ON ZG_FILIAL = ZF_FILIAL AND ZG_CODIGO = ZF_CODIGO AND SZG.D_E_L_E_T_ ='' "
	cQry1 += " 	LEFT OUTER JOIN "+RetSqlName("SZB")+" SZB WITH(NOLOCK) ON ZB_FILIAL = ZG_FILIAL AND ZB_PEDIDO = ZG_PEDIDO AND SZB.D_E_L_E_T_ ='' "
	cQry1 += " 	WHERE ZF_FLAG ='Y' 
	cQry1 += "	AND ZF_FILIAL ='"+XFilial("SZF")+"'"
	cQry1 += " 	AND SZF.D_E_L_E_T_ ='' "
	cQry1 += " 	GROUP BY ZF_CODIGO "
	cQry1 += " 	HAVING COUNT(ZG_PEDIDO) = ISNULL(COUNT(ZB_PEDIDO),0) " 
	cQry1 += " 	ORDER BY ZF_CODIGO " 


    TCQuery cQry1 ALIAS "TCQ" NEW
    DbSelectArea("TCQ")
    DbGoTop()

   	While !Eof()
	   	IncProc()
	    DbSelectArea("SZF")
	    DbSetOrder(1)
    	DbSeek(xFilial("SZF")+TCQ->ZF_CODIGO, .t.)
	    If Found()
           	RecLock("SZF", .f.)
           	    SZF->ZF_FLAG ='X' // TOTALMENTE DESTINADO
           	MsUnlock()        
		Endif	
        DbSelectArea("TCQ")
        DbSkip()
    Enddo

    DbSelectArea("TCQ")
    DbCloseArea()
    
	cQry1 := "" 
	cQry1 += " WITH TMP AS( "
	cQry1 += " SELECT ZF_CODIGO, C6_NUM, C6_PRODUTO, C6_QTDVEN, SUM(ZZK_QUANT) AS ZZK_QUANT, COUNT(ZZK.R_E_C_N_O_) AS ZZKVOLUME "
	cQry1 += " FROM "+RetSqlName("SZF")+" SZF WITH(NOLOCK) "
	cQry1 += " LEFT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH(NOLOCK) ON ZF_FILIAL = ZG_FILIAL AND ZG_CODIGO = ZF_CODIGO AND SZG.D_E_L_E_T_ ='' "
	cQry1 += " LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH(NOLOCK) ON C6_FILIAL = ZG_FILIAL AND C6_NUM = SUBSTRING(ZG_PEDIDO,3,6) AND SC6.D_E_L_E_T_ ='' "
	cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON B1_FILIAL = C6_FILIAL AND B1_COD = C6_PRODUTO AND SB1.D_E_L_E_T_ ='' "
	cQry1 += " LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH(NOLOCK) ON ZZK_FILIAL = C6_FILIAL AND ZZK_PRODUT = C6_PRODUTO AND ZZK_PEDIDO = C6_NUM AND ZZK.D_E_L_E_T_ ='' "
	cQry1 += " WHERE ZF_FLAG IN('X','Y') AND SZF.D_E_L_E_T_ ='' " 
	cQry1 += " AND ZF_FILIAL ='"+XFilial("SZF")+"' "
	cQry1 += " AND B1_TIPO IN('PA','PI') AND (B1_GRUPO <>'PA55') AND (LEN(B1_COD)=12) "
	cQry1 += " GROUP BY ZF_CODIGO, C6_NUM , C6_QTDVEN, C6_PRODUTO, ZG_CODIGO) "
	cQry1 += " SELECT TMP.ZF_CODIGO "
	cQry1 += " FROM TMP "
	cQry1 += " GROUP BY TMP.ZF_CODIGO "
	cQry1 += " HAVING (SUM(TMP.ZZK_QUANT) = SUM(TMP.C6_QTDVEN)) "
	cQry1 += " ORDER BY TMP.ZF_CODIGO "

    TCQuery cQry1 ALIAS "TCQ" NEW
    DbSelectArea("TCQ")
    DbGoTop()

   	While !Eof()
	   	IncProc()
	    DbSelectArea("SZF")
	    DbSetOrder(1)
    	DbSeek(xFilial("SZF")+TCQ->ZF_CODIGO, .t.)
	    If Found()
           	RecLock("SZF", .f.)
           	    SZF->ZF_FLAG ='Z' // TOTALMENTE DESTINADO E BIPADO
           	MsUnlock()        
		Endif	
        DbSelectArea("TCQ")
        DbSkip()
    Enddo

    DbSelectArea("TCQ")
    DbCloseArea()
    
	Messagebox("Status dos Borderôs Atualizados !!","Atenção...",48)  
	
Return



/*
/******************************************************************************************************************/
/*** FATA02_8 - Re-Monta Pedidos                                                                               ***/
/******************************************************************************************************************/
/*
User Function FATA02_8()
     // Variaveis Locais da Funcao
     // Variaveis da Funcao de Controle e GertArea/RestArea
     Local _aArea  := {}
     Local _aAlias := {}
     Local lRet    := .t.
     DbSelectArea("SZF")
     DbSetOrder(1)
     DbSeek(xFilial("SZF")+M->ZF_CODIGO, .t.)
     If Found()
     	If SZF->ZF_FLAG $ 'E.P.T.R'
        	MsgStop("Não pode ser feita manutenção nesse bordero!")
         	Return
      	Endif
     Else
     	MsgBox("Borderô de Pedidos não encontrado"!,"Atenção","Alert")
     	Return()
     Endif
     
     // Variaveis Private da Funcao
     Private _oDlg1 // Dialog Principal
     // Privates das ListBoxes
     Private aMonPed := {}
     Private oMonPed
     Private cPedFalt := ''
     Private oPedFalt
     oFont1 := TFont():New("Courier New"        , 7, 13, .F., .F.,  5, .F., 5, .F., .F.)
     DEFINE MSDIALOG _oDlg TITLE "Monta Pedidos" FROM C(178), C(181) TO C(550), C(948) PIXEL
            // Defina aqui a chamada dos Aliases para o GetArea
            CtrlArea(1, @_aArea, @_aAlias, {"SZF", "SZG"}) // GetArea

            // Cria Componentes Padroes do Sistema
            @ C(000), C(003) Button "Novo Bordero"      Size C(056), C(012) Action(fNovBorP())   PIXEL OF _oDlg1
            @ C(000), C(161) Button "Bordero Existente" Size C(056), C(012) Action(fBorJaE())   PIXEL OF _oDlg1
            @ C(000), C(326) Button "Sair"              Size C(056), C(012) Action(_oDlg1:End()) PIXEL OF _oDlg1
            @ C(119), C(004) Get oPedFalt Var cPedFalt    OF _oDlg PIXEL  MEMO Size C(377), C(064) FONT oFont1 COLOR CLR_BLACK READONLY

            // Chamadas das ListBox do Sistema
            lRet := fListBox2()

            CtrlArea(2, _aArea, _aAlias) // RestArea
        If lRet
           ACTIVATE MSDIALOG _oDlg1 CENTERED
        Else
           ACTIVATE MSDIALOG _oDlg1 CENTERED ON INIT (_oDlg1:End())
        Endif
Return

/******************************************************************************************************************/
/*** fNovBorP - Grava um novo bordero de Pedidos                                                                 ***/
/******************************************************************************************************************/
/*
Static Function fNovBorP()
       Local aMatReg := {}
       Local aQtdReg := {}
       //1º) Verificar quais regiões que possuen cargas marcadas e gravar na matriz aMatReg
       For nY := 1 To Len(oMonPed:aArray)
           If oMonPed:aArray[nY][1]
              If aScan(aMatReg, {|x| x[1] == oMonPed:aArray[nY][7]}) == 0
                 aadd(aMatReg, {oMonPed:aArray[nY][7], 0, 0})
              Endif
           Endif
           If Empty(oMonPed:aArray[nY][2])
              aAdd(aQtdReg, {SubStr(oMonPed:aArray[nY][3], 1, 5), 0, 0, 0})
           Else
              aQtdReg[aScan(aQtdReg, {|x| Alltrim(x[1]) == Alltrim(oMonPed:aArray[nY][7])})][2] += 1
              If oMonPed:aArray[nY][1]
                 aQtdReg[aScan(aQtdReg, {|x| Alltrim(x[1]) == Alltrim(oMonPed:aArray[nY][7])})][3] += 1
              Endif
           Endif
       Next
       If Len(aMatReg) > 0
          For nA := 1 To Len(aMatReg)
              //Monta aCols por região
              aMatReg[nA][2] := aQtdReg[aScan(aQtdReg, {|x| Alltrim(x[1]) == Alltrim(aMatReg[nA][1])})][2]
              aMatReg[nA][3] := aQtdReg[aScan(aQtdReg, {|x| Alltrim(x[1]) == Alltrim(aMatReg[nA][1])})][3]
              aAuxDes := {}
              For nX := 1 to Len(oMonDes:aArray)
                  If oMonDes:aArray[nX][1] .and. oMonDes:aArray[nX][7] == aMatReg[nA][1]
                     aAdd(aAuxDes, {'01'+oMonDes:aArray[nX][2], SubStr(oMonDes:aArray[nX][3], 13), .f.})
                  Endif
              Next
              u_FATA06_1( , , , , "P", aMatReg[nA][1], @aAuxDes, @aQtdReg, .f.)
          Next
          //DELEÇÃO DOS PEDIDOS ADICIONADOS DA TELA DE MONTA DESPACHO
          For nA := 1 To Len(aQtdReg)
              If aQtdReg[nA][4] > 0
                 If aQtdReg[nA][4] == aQtdReg[nA][2] //Deleta todos os itens da região
                    nQtdDel := 0
                    For nY := 1 To Len(oMonDes:aArray)
                        If !oMonDes:aArray[nY - nQtdDel] == Nil
                           If Alltrim(oMonDes:aArray[(nY - nQtdDel)][7]) == Alltrim(aQtdReg[nA][1])
                              aDel(oMonDes:aArray, (nY - nQtdDel))
                              nQtdDel += 1
                           Endif
                        Endif
                    Next
                 ElseIf aQtdReg[nA][4] < aQtdReg[nA][2] //Deleta os itens do vetor aDelMon
                        nQtdDel := 0
                        For nY := 1 To Len(oMonDes:aArray)
                            If !oMonDes:aArray[nY - nQtdDel] == Nil
                               If oMonDes:aArray[nY - nQtdDel][1] .and. !Empty(oMonDes:aArray[nY - nQtdDel][2]) .and. Alltrim(oMonDes:aArray[(nY - nQtdDel)][7]) == Alltrim(aQtdReg[nA][1])
                                  aDel(oMonDes:aArray, (nY - nQtdDel))
                                  nQtdDel += 1
                               Endif
                            Endif
                        Next
                 Endif
                 aSize(oMonPed:aArray, (Len(oMonPed:aArray) - nQtdDel) )
              Endif
          Next
       Else
          MsgStop("Não havia nenhum pedido marcardo para geração de uma nova carga.")
       Endif
       oMonPed:nAt := 1
       oMonPed:Refresh()
       If Len(oMonPed:aArray) == 0
          _oDlg1:End()
       Endif
Return

*/                                                  
Static function tfMail(cAssunto,cTexto)
local cPara,cCC,cArquivo
cPara 	 :="pcp@brasilux.com.br"
cCC      :="expedicao@brasilux.com.br;paulo@brasilux.com.br"
cArquivo :=''
U_EnvMail(cAssunto,cTexto,cPara,cCC,cArquivo)
return
