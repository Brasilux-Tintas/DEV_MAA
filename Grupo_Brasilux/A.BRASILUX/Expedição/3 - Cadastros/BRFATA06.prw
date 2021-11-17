#include "protheus.ch"
#include "topconn.ch" 
#include 'font.ch'
#xtranslate bsetget(<uvar>) => { | u | If( PCount() == 0, <uvar>, <uvar> := u ) }
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BRFATA06 ³ Autor ³ Luís Gustavo de Souza ³ Data ³14/08/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³ Desenvolvimento  ³Contato ³ lgsouza@brasilux.com.br        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Bordero de Pedidos Despachos                               ³±±
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
User Function BRFATA06()
     Private cRotina   := "BRFATA06  "
     Private cAcessos  := Posicione("SZW", 4, xFilial("SZW")+cRotina+__cUserID+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2), "ZW_ACESSOS")

	MsgStop('Programa Disponível em outro Menu!')
	return

     If !SubStr(cAcessos, 1, 1) $ '*'
        MsgStop('Usuário sem acesso. Consulte o Administrador do Sistema!')
        Return
     Endif

     Private cAliasMB  := "SZA"
     Private aRotina   := {}
     Private cCadastro := "Cadastro de Bordero de Despacho"

     aAdd(aRotina, { OemToAnsi("Pesquisar"     ), 'AxPesqui       ', 0, 1}) // 1 - Pesquisar
     aAdd(aRotina, { OemToAnsi("Visualizar"    ), 'u_FATA06_1     ', 0, 2}) // 2 - Visualizar
     aAdd(aRotina, { OemToAnsi("Incluir"       ), 'u_FATA06_1     ', 0, 3}) // 3 - Incluir
     aAdd(aRotina, { OemToAnsi("Alterar"       ), 'u_FATA06_1     ', 0, 4}) // 4 - Alterar
     aAdd(aRotina, { OemToAnsi("Excluir"       ), 'u_FATA06_1     ', 0, 5}) // 5 - Excluir
     aAdd(aRotina, { OemToAnsi("Baixar"        ), 'U_FATA06_1     ', 0, 9}) // 6 - Baixar
     aAdd(aRotina, { OemToAnsi("Cancela Baixa" ), 'U_FATA06_1     ', 0, 9}) // 7 - Cancelamento Baixa
     aAdd(aRotina, { OemToAnsi("Conferência"   ), 'U_FATA06_4     ', 0, 9}) // 8 - Conferência
     aAdd(aRotina, { OemToAnsi("Re-monta Desp."), 'U_FATA06_6     ', 0, 9}) // 8 - Conferência
     aAdd(aRotina, { OemToAnsi("Rel. de Faltas"), 'U_BRFATR12("M")', 0, 9}) // 9 -
     aadd(aRotina, { OemToAnsi("Legenda"       ), 'U_FATA06_5()'   , 0, 9}) //10 -

     Private aCores    := { { 'SZA->ZA_FLAG $ " .N"', 'ENABLE'    },; //Não despachado
                            { 'SZA->ZA_FLAG == "C"' , 'BR_AMARELO'},; //Conferência
                            { 'SZA->ZA_FLAG == "S"' , 'DISABLE'   } } //Baixado

     Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

     DbSelectArea(cAliasMB)
     DbSetOrder(1)
     DbGoTop()
     //LGS#20200211 - Adequação de release 12.1.25 e posteriores
     //Set Key VK_F10 To fAtvF10()
     SetKey( VK_F10, { || fAtvF10() } )
     mBrowse(06, 01, 22, 75, cAliasMB, , , , , , aCores)
     //LGS#20200211 - Adequação de release 12.1.25 e posteriores
     //Set Key VK_F10 To 
     SetKey( VK_F10, { ||  } )
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FATA06_1 ³ Autor ³ Luís Gustavo de Souza ³ Data ³30/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³ Desenvolvimento  ³Contato ³ lgsouza@brasilux.com.br        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Bordero de Despacho                                        ³±±
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
User Function FATA06_1(cAlias, nReg, nOpcX, aCamEnc, cTipo, cRegiao, aAuxDes, aQtdReg, lTroBor)
     // Variaveis Locais da Funcao
     Local cAliasE      := "SZA"  // Tabela cadastrada no Dicionario de Tabelas (SX2) que sera editada
     Local nOpcA        := 0
     // Vetor com nome dos campos que serao exibidos. Os campos de usuario sempre serao
     // exibidos se nao existir no parametro um elemento com a expressao "NOUSER"
     Local aCpoEnch     := {"ZA_CODIGO", "ZA_EMISSAO", "ZA_DTDESPA", "ZA_PREVDSP", "ZA_REGIAO", "ZA_DESCR", "ZA_CODVEI", "ZA_NOMVEI", "ZA_CODMOT", "ZA_NOMMOT"}
     Local aAlterEnch   := Iif(nOpcX == 6, {"ZA_DTDESPA"}, {"ZA_PREVDSP", "ZA_REGIAO", "ZA_DESCR", "ZA_CODVEI", "ZA_CODMOT"})  // Vetor com nome dos campos que poderao ser editados
     Local nOpc         := Iif(nOpcX == 6, 3, nOpcx) // Numero da linha do aRotina que definira o tipo de edicao (Inclusao, Alteracao, Exclucao, Visualizacao)
     // Vetor com coordenadas para criacao da enchoice no formato {<top>, <left>, <bottom>, <right>}
     Local aPos         := {C(014), C(000), C(079), C(363)}
     Local nModelo      := 3     // Se for diferente de 1 desabilita execucao de gatilhos estrangeiros
     Local lF3          := .F.   // Indica se a enchoice esta sendo criada em uma consulta F3 para utilizar variaveis de memoria
     Local lMemoria     := .T.   // Indica se a enchoice utilizara variaveis de memoria ou os campos da tabela na edicao
     Local lColumn      := .F.   // Indica se a apresentacao dos campos sera em forma de coluna
     Local caTela       := ""    // Nome da variavel tipo "private" que a enchoice utilizara no lugar da propriedade aTela
     Local lNoFolder    := .F.   // Indica se a enchoice nao ira utilizar as Pastas de Cadastro (SXA)
     Local lProperty    := .f.   // Indica se a enchoice nao utilizara as variaveis aTela e aGets, somente suas propriedades com os mesmos nomes
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
     Local nX, aTirBor, nY
     Local _lOpen        := .F. //LGS#20200211 - Adequação para release 12.1.25
     cTipo   := Iif(cTipo == Nil, '', cTipo)
     lTroBor := Iif(lTroBor == Nil, .f., lTroBor)
     nReg  := Iif(cTipo $ 'P.R', 0, nReg )
     nOpc  := Iif(cTipo $ 'P.R', 3, nOpc )
     nOpcX := Iif(cTipo $ 'P.R', 3, nOpcX)
     // Variaveis Private da Funcao
     Private _oDlg  // Dialog Principal
     // Variaveis que definem a Acao escolhida na MBrowse
     Private VISUAL := (nOpcX == 2)
     Private INCLUI := (nOpcX == 3)
     Private ALTERA := (nOpcX == 4)
     Private DELETA := (nOpcX == 5)
     Private BAIXAR := (nOpcX == 6)
     Private CANCEL := (nOpcX == 7)
     Private aTELA[0][0], aGETS[0]
     // Privates das NewGetDados
     Private oGetDados1
     Private nPesBor := 0
     Private nVolBor := 0
     Private onPesBor
     Private onVolBor
     Private _cAliasSX3 := GetNextAlias() //LGS#20200211 - Adequação para release 12.1.25
       
     // ABERTURA DO DICIONÁRIO SX3 - LGS#20200211 - Adequação para release 12.1.25
     OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
     _lOpen := Select( _cAliasSX3 ) > 0
     If !_lOpen //LGS#20200211 - Adequação para release 12.1.25
        MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
        Return
     Endif

     If nOpcX == 6
        nOpcX := 2
     Endif
     If DELETA .or. ALTERA
        If SZA->ZA_FLAG $ 'S'
           MsgStop("Despacho não pode ser "+Iif(ALTERA, "alterado.", "excluido."))
           Return (.f.)
        Endif
     ElseIf BAIXAR
            If !Empty(SZA->ZA_DTDESPA)
               MsgStop("Esse bordero já foi despachado.")
               Return(.f.)
            Endif
            /********************************************************************************************************************************/
            /*** BLOCO ALTERADO EM 11/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
            /*DbSelectArea("SX3")
            DbSetOrder(2)
            DbSeek("ZA_DTDESPA")
            If Found()
               RecLock("SX3", .f.)
                  SX3->X3_OBRIGAT := 'Ç'
               MsUnLock()
            Endif*/
            DbSelectArea( _cAliasSX3 )
            ( _cAliasSX3 )->( DbSetOrder(2) )
            ( _cAliasSX3 )->( DbSeek("ZA_DTDESPA") )
            If Found()
               RecLock( _cAliasSX3 , .f.)
                  ( _cAliasSX3 )->( X3_OBRIGAT ) := 'Ç'
               MsUnLock()
            Endif
            DbSelectArea("SZA")
     ElseIf CANCEL
            If Empty(SZA->ZA_DTDESPA)
               MsgStop("Esse bordero ainda não foi baixado.")
               Return(.f.)
            Endif
     Endif
     DEFINE MSDIALOG _oDlg TITLE "Bordero de Despacho" FROM C(188),C(181) TO C(588),C(904) PIXEL
     DEFINE FONT oFont NAME "Courier New" SIZE 0, 20 BOLD
            // Defina aqui a chamada dos Aliases para o GetArea
            CtrlArea(1, @_aArea, @_aAlias, {"SZA", "SZB"}) // GetArea

            @ C(182), C(000) Say   ocPesBor Var "Peso:"                              Size C(030), C(008) COLOR CLR_BLACK           PIXEL OF _oDlg FONT oFont
            @ C(181), C(035) MsGet onPesBor Var nPesBor      Picture '@E 9999999.99' Size C(065), C(009) COLOR CLR_HBLUE  WHEN .F. PIXEL OF _oDlg FONT oFont
            @ C(182), C(120) Say   ocVolBor Var "Volume: "                           Size C(030), C(008) COLOR CLR_BLACK           PIXEL OF _oDlg FONT oFont
            @ C(181), C(165) MsGet onVolBor Var nVolBor      Picture '@E 9999999'    Size C(065), C(009) COLOR CLR_HBLUE  WHEN .F. PIXEL OF _oDlg FONT oFont

            // Chamadas da Enchoice do Sistema
            // INCLUI = True  --> Traz Enchoice vazia pronta para Inclusao
            // INCLUI = False --> Traz Enchoice com o Registro definido pela variavel nReg
            RegToMemory(cAliasE, INCLUI, .F.)
            Enchoice(cAliasE, nReg, nOpc, /*aCRA*/, /*cLetra*/, /*cTexto*/, aCpoEnch, aPos, aAlterEnch, nModelo, /*nColMens*/, /*cMensagem*/, /*cTudoOk*/, _oDlg, lF3, lMemoria, lColumn, caTela, lNoFolder, lProperty)

            If INCLUI
               M->ZA_EMISSAO := dDataBase
               If cTipo $ 'P.R'
                  M->ZA_REGIAO := cRegiao
                  M->ZA_DESCR  := Posicione("SA4", 1, xFilial("SA4")+cRegiao, "A4_NOME")
               Endif
            Endif
            // Chamadas das GetDados do Sistema
            fGetDados2(nOpcX, cTipo, aAuxDes)

            CtrlArea(2, _aArea, _aAlias) // RestArea
     ACTIVATE MSDIALOG _oDlg CENTERED  ON INIT EnchoiceBar(_oDlg, {|| Iif(Obrigatorio(aGets, aTela), nOpcA := 1, nOpcA := 0), Iif(nOpcA == 1, _oDlg:End(), nOpcA := 0)}, {|| _oDlg:End()},, aButtons)
     If nOpcA == 1
        If INCLUI
           nQtdAdd := 0
           nPesBor := 0
           nVolBor := 0
           For nX := 1 To Len(oGetDados1:aCols)
               If !NwDeleted(oGetDados1, nX)
                  cCodReg := oMonDes:aArray[aScan(oMonDes:aArray, {|x| x[2] == SubStr(oGetDados1:aCols[nX][1], 3, 6)})][7]
                  If cTipo $ 'P.R' //Retorna as quantidades para serem deletadas da tela do monta/re-monta despacho
                     aQtdReg[aScan(aQtdReg, {|x| Alltrim(x[1]) == Alltrim(cCodReg)})][4] += 1
                  Endif
                  nQtdAdd += 1
                  nPesBor += Posicione("SC5", 1, xFilial("SC5")+substr(oGetDados1:aCols[nX][1],3,6), "C5_PBRUTO")
                  nVolBor += Posicione("SC5", 1, xFilial("SC5")+substr(oGetDados1:aCols[nX][1],3,6), "C5_VOLUME1")
               Endif
           Next
           If nQtdAdd > 0
              //****************************************************************************************************
              //Busca o numero do próximo bordero
              cBorAtu := SZA->ZA_CODIGO
              cCodDes := GETSX8NUM("SZA", "ZA_CODIGO")
              lConDes := .t.
              While lConDes
                    DbSelectArea("SZA")
                    DbSetOrder(1)
                    DbSeek(xFilial("SZA")+cCodDes, .t.)
                    If !Found()
                       lConDes := .f.
                       Loop
                    Else
                       CONFIRMSX8()
                       cCodDes := GETSX8NUM("SZA", "ZA_CODIGO")
                    Endif
              EndDo
              //****************************************************************************************************
              //1º) GRAVAR CABEÇALHO 
              If lTroBor
                 RecLock("SZA", .f.)
                    SZA->ZA_CODIGO  := cCodDes
                 MsUnLock()
                 CONFIRMSX8()
              Else
                 RecLock("SZA", .t.)
                    SZA->ZA_FILIAL  := xFilial("SZA")
                    SZA->ZA_CODIGO  := cCodDes
                    SZA->ZA_EMISSAO := M->ZA_EMISSAO
                    SZA->ZA_DTDESPA := M->ZA_DTDESPA
                    SZA->ZA_DESCR   := M->ZA_DESCR
                    SZA->ZA_PREVDSP := M->ZA_PREVDSP
                    SZA->ZA_REGIAO  := M->ZA_REGIAO
                    SZA->ZA_FLAG    := 'N'
                    SZA->ZA_CODVEI  := M->ZA_CODVEI
                    SZA->ZA_CODMOT  := M->ZA_CODMOT
                 MsUnLock()
                 CONFIRMSX8()
              Endif
              //****************************************************************************************************
              //2º) GRAVAR RODAPÉ
              If Empty(cTipo) .or. cTipo $ 'P'
                 For nX := 1 To Len(oGetDados1:aCols)
                     If !NwDeleted(oGetDados1, nX)
                        DbSelectArea("SZB")
                        DbSetOrder(2)
                        DbSeek(xFilial("SZB")+oGetDados1:aCols[nX][1], .t.)
                        If !Found()//Se não encontrou o pedido
                           RecLock("SZB", .t.)
                              SZB->ZB_FILIAL := xFilial("SZB")
                              SZB->ZB_CODIGO := cCodDes
                              cAux := alltrim(oGetDados1:aCols[nX][1])
                              cAux := substr(cNumEmp,1,2)+substr(cAux,len(cAux)-5,6)
                              SZB->ZB_PEDIDO := cAux //oGetDados1:aCols[nX][1]
                              SZB->ZB_RAZAO  := oGetDados1:aCols[nX][2]
                           MsUnLock()
                           DbSelectArea("ZZC")
                           DbSetOrder(2)
                           DbSeek(xFilial("ZZC")+SubStr(oGetDados1:aCols[nX][1], 3, 6), .t.)
                           If Found()
                              While !Eof() .AND. (ZZC->ZZC_FILIAL == xFilial("ZZC")) .AND. ZZC->ZZC_PEDIDO == SubStr(oGetDados1:aCols[nX][1], 3, 6)
                                    RecLock("ZZC", .f.)
                                       ZZC->ZZC_CARGA := cCodDes
                                    MsUnLock()
                                    DbSelectArea("ZZC")
                                    DbSkip()
                              Enddo
                           Else
                              DbSelectArea("SC6")
                              DbSetOrder(1)
                              DbSeek(xFilial("SC6")+SubStr(oGetDados1:aCols[nX][1], 3, 6), .t.)
                              If Found()
                                 While !Eof() .AND. (SC6->C6_FILIAL == xFilial("SC6")) .AND. SC6->C6_NUM == SubStr(oGetDados1:aCols[nX][1], 3, 6)
                                       RecLock("ZZC", .t.)
                                          ZZC->ZZC_FILIAL := xFilial("ZZC")
                                          ZZC->ZZC_BORDER := Posicione("SZG", 1, xFilial("SZG")+oGetDados1:aCols[nX][1], "ZG_CODIGO")
                                          ZZC->ZZC_PEDIDO := SC6->C6_NUM
                                          ZZC->ZZC_PRODUT := SC6->C6_PRODUTO
                                          ZZC->ZZC_QUANTI := SC6->C6_QTDVEN
                                          ZZC->ZZC_RETIRA := 0.0
                                          ZZC->ZZC_GAVETA := Space(03)
                                          ZZC->ZZC_VOLUME := SC6->C6_VOLUME
                                          ZZC->ZZC_VOLRET := 0.0
                                          ZZC->ZZC_CARGA  := cCodDes
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
                        Else //Se encontrou o pedido em outro despacho.
                           If MsgYesNo("Pedido "+SubStr(oGetDados1:aCols[nX][1], 3, 6)+" está no despacho "+SZB->ZB_CODIGO, "Continua no despacho "+SZB->ZB_CODIGO+" ou troca?") //Se Continua
                              //Desconta do despacho atual
                              nPesBor -= Posicione("SC5", 1, xFilial("SC5")+Substr(oGetDados1:aCols[nX][1],3,6), "C5_PBRUTO")
                              nVolBor -= Posicione("SC5", 1, xFilial("SC5")+Substr(oGetDados1:aCols[nX][1],3,6), "C5_VOLUME1")
                           Else //Se troca o bordero
                              //1º) Desconta Pesos e Volumes do despacho atual
                              DbSelectArea("SZA")
                              DbSetOrder(1)
                              DbSeek(xFilial("SZA")+SZB->ZB_CODIGO, .t.)
                              If Found()
                                 RecLock("SZA", .f.)
                                    SZA->ZA_PESO   -= Posicione("SC5", 1, xFilial("SC5")+Substr(oGetDados1:aCols[nX][1],3,6), "C5_PBRUTO")
                                    SZA->ZA_VOLUME -= Posicione("SC5", 1, xFilial("SC5")+Substr(oGetDados1:aCols[nX][1],3,6), "C5_VOLUME1")
                                 MsUnLock("SZA")
                              Endif
                              //2º) Troca o código do bordero no pedido
                              RecLock("SZB", .f.)
                                 SZB->ZB_CODIGO := cCodDes
                              MsUnLock()
                              //3º) Reposiciona pedido no bordero de despacho
                              DbSelectArea("SZA")
                              DbSeek(xFilial("SZA")+cCodDes, .t.)
                              //4º) Acerta arquivos de retirada/faltas
                              DbSelectArea("ZZC")
                              DbSetOrder(2)
                              DbSeek(xFilial("ZZC")+SubStr(oGetDados1:aCols[nX][1], 3, 6), .t.)
                              If Found()
                                 While !Eof() .AND. (ZZC->ZZC_FILIAL == xFilial("ZZC")) .AND. ZZC->ZZC_PEDIDO == SubStr(oGetDados1:aCols[nX][1], 3, 6)
                                       RecLock("ZZC", .f.)
                                          ZZC->ZZC_CARGA := cCodDes
                                       MsUnLock()
                                 Enddo
                              Else
                                 DbSelectArea("SC6")
                                 DbSetOrder(1)
                                 DbSeek(xFilial("SC6")+SubStr(oGetDados1:aCols[nX][1], 3, 6), .t.)
                                 If Found()
                                    While !Eof() .AND. (SC6->C6_FILIAL == xFilial("SC6")) .AND. SC6->C6_NUM == SubStr(oGetDados1:aCols[nX][1], 3, 6)
                                          RecLock("ZZC", .t.)
                                             ZZC->ZZC_FILIAL := xFilial("ZZC")
                                             ZZC->ZZC_BORDER := Posicione("SZG", 1, xFilial("SZG")+Substr(oGetDados1:aCols[nX][1],3,6), "ZG_CODIGO")
                                             ZZC->ZZC_PEDIDO := SC6->C6_NUM
                                             ZZC->ZZC_PRODUT := SC6->C6_PRODUTO
                                             ZZC->ZZC_QUANTI := SC6->C6_QTDVEN
                                             ZZC->ZZC_RETIRA := 0.0
                                             ZZC->ZZC_GAVETA := Space(03)
                                             ZZC->ZZC_VOLUME := SC6->C6_VOLUME
                                             ZZC->ZZC_VOLRET := 0.0
                                             ZZC->ZZC_CARGA  := cCodDes
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
                           Endif
                        Endif
                     Endif
                 Next
                 RecLock("SZA", .f.)
                    SZA->ZA_VOLUME  := nVolBor
                    SZA->ZA_PESO    := nPesBor
                 MsUnLock()
              Else
                 //Remonta a carga com outro numero
                 For nX := 1 To Len(oGetDados1:aCols)
                     If !NwDeleted(oGetDados1, nX)
                        DbSelectArea("SZB")
                        DbSetOrder(2)
                        DbSeek(xFilial("SZB")+oGetDados1:aCols[nX][1], .t.)
                        If !Found() //Pedido estava em outro Bodero
                           RecLock("SZB", .t.)
                              SZB->ZB_FILIAL := xFilial("SZB")
                              SZB->ZB_CODIGO := cCodDes
                              cAux := alltrim(oGetDados1:aCols[nX][1])
                              cAux := substr(cNumEmp,1,2)+substr(cAux,len(cAux)-5,6)
                              SZB->ZB_PEDIDO := cAux //oGetDados1:aCols[nX][1]
                              SZB->ZB_RAZAO  := oGetDados1:aCols[nX][2]
                           MsUnLock()
                           DbSelectArea("ZZC")
                           DbSetOrder(2)
                           DbSeek(xFilial("ZZC")+SubStr(oGetDados1:aCols[nX][1], 3, 6), .t.)
                           If Found()
                              While !Eof() .AND. (ZZC->ZZC_FILIAL == xFilial("ZZC")) .AND. ZZC->ZZC_PEDIDO == SubStr(oGetDados1:aCols[nX][1], 3, 6)
                                    RecLock("ZZC", .f.)
                                       ZZC->ZZC_CARGA := cCodDes
                                    MsUnLock()
                                    DbSelectArea("ZZC")
                                    DbSkip()
                              Enddo
                           Else
                              DbSelectArea("SC6")
                              DbSetOrder(1)
                              DbSeek(xFilial("SC6")+SubStr(oGetDados1:aCols[nX][1], 3, 6), .t.)
                              If Found()
                                 While !Eof() .AND. (SC6->C6_FILIAL == xFilial("SC6")) .AND. SC6->C6_NUM == SubStr(oGetDados1:aCols[nX][1], 3, 6)
                                       RecLock("ZZC", .t.)
                                          ZZC->ZZC_FILIAL := xFilial("ZZC")
                                          ZZC->ZZC_BORDER := Posicione("SZG", 1, xFilial("SZG")+oGetDados1:aCols[nX][1], "ZG_CODIGO")
                                          ZZC->ZZC_PEDIDO := SC6->C6_NUM
                                          ZZC->ZZC_PRODUT := SC6->C6_PRODUTO
                                          ZZC->ZZC_QUANTI := SC6->C6_QTDVEN
                                          ZZC->ZZC_RETIRA := 0.0
                                          ZZC->ZZC_GAVETA := Space(03)
                                          ZZC->ZZC_VOLUME := SC6->C6_VOLUME
                                          ZZC->ZZC_VOLRET := 0.0
                                          ZZC->ZZC_CARGA  := cCodDes
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
                           //1º) Desconta Pesos e Volumes do despacho atual
                           DbSelectArea("SZA")
                           DbSetOrder(1)
                           DbSeek(xFilial("SZA")+cBorAtu, .t.)
                           If Found()
                              RecLock("SZA", .f.)
                                 SZA->ZA_PESO   -= Posicione("SC5", 1, xFilial("SC5")+Substr(oGetDados1:aCols[nX][1],3,6), "C5_PBRUTO")
                                 SZA->ZA_VOLUME -= Posicione("SC5", 1, xFilial("SC5")+Substr(oGetDados1:aCols[nX][1],3,6), "C5_VOLUME1")
                              MsUnLock("SZA")
                           Endif
                           //2º) Troca o código do bordero no pedido
                           RecLock("SZB", .f.)
                              SZB->ZB_CODIGO := cCodDes
                           MsUnLock()
                           //3º) Reposiciona pedido no bordero de despacho
                           DbSelectArea("SZA")
                           DbSeek(xFilial("SZA")+cCodDes, .t.)
                           //4º) Acerta arquivos de retirada/faltas
                           DbSelectArea("ZZC")
                           DbSetOrder(2)
                           DbSeek(xFilial("ZZC")+SubStr(oGetDados1:aCols[nX][1], 3, 6), .t.)
                           If Found()
                              While !Eof() .AND. (ZZC->ZZC_FILIAL == xFilial("ZZC")) .AND. ZZC->ZZC_PEDIDO == SubStr(oGetDados1:aCols[nX][1], 3, 6)
                                    RecLock("ZZC", .f.)
                                       ZZC->ZZC_CARGA := cCodDes
                                    MsUnLock()
                                    DbSelectArea("ZZC")
                                    DbSkip()
                              Enddo
                           Else
                              DbSelectArea("SC6")
                              DbSetOrder(1)
                              DbSeek(xFilial("SC6")+SubStr(oGetDados1:aCols[nX][1], 3, 6), .t.)
                              If Found()
                                 While !Eof() .AND. (SC6->C6_FILIAL == xFilial("SC6")) .AND. SC6->C6_NUM == SubStr(oGetDados1:aCols[nX][1], 3, 6)
                                       RecLock("ZZC", .t.)
                                          ZZC->ZZC_FILIAL := xFilial("ZZC")
                                          ZZC->ZZC_BORDER := Posicione("SZG", 1, xFilial("SZG")+oGetDados1:aCols[nX][1], "ZG_CODIGO")
                                          ZZC->ZZC_PEDIDO := SC6->C6_NUM
                                          ZZC->ZZC_PRODUT := SC6->C6_PRODUTO
                                          ZZC->ZZC_QUANTI := SC6->C6_QTDVEN
                                          ZZC->ZZC_RETIRA := 0.0
                                          ZZC->ZZC_GAVETA := Space(03)
                                          ZZC->ZZC_VOLUME := SC6->C6_VOLUME
                                          ZZC->ZZC_VOLRET := 0.0
                                          ZZC->ZZC_CARGA  := cCodDes
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
                        Endif
                     Endif
                 Next
              Endif
           Else
              MsgAlert("Bordero não tem itens a serem adicionados!", "Atenção...")
           Endif
        ElseIf ALTERA //Altera na tabela itens do bordero de despacho
               aTirBor := {}
               For nX := 1 To Len(oGetDados1:aCols)
                   If NwDeleted(oGetDados1, nX)
                      DbSelectArea("ZZC")
                      DbSetOrder(2)
                      DbSeek(xFilial("ZZC")+SubStr(oGetDados1:aCols[nX][1], 3, 6), .t.)
                      If Found()
                         While !Eof() .and. (ZZC->ZZC_FILIAL == xFilial("ZZC")) .and. ZZC->ZZC_PEDIDO == SubStr(oGetDados1:aCols[nX][1], 3, 6)
                               RecLock("ZZC", .f.)
                                  ZZC->ZZC_CARGA := space(06)
                               MsUnLock()
                               DbSelectArea("ZZC")
                               DbSkip()
                         Enddo
                      Endif
                      DbSelectArea("SZB")
                      DbSetOrder(2)
                      DbSeek(xFilial("SZB")+oGetDados1:aCols[nX][1], .t.)
                      If Found()
                         RecLock("SZB", .f.)
                            DbDelete()
                         MsUnLock()
                      Endif
                   Else
                      DbSelectArea("SZB")
                      DbSetOrder(2)
                      DbSeek(xFilial("SZB")+oGetDados1:aCols[nX][1], .t.)
                      If !Found()
                         RecLock("SZB", .t.)
                            SZB->ZB_FILIAL := xFilial("SZB")
                            SZB->ZB_CODIGO := cCodDes
                            cAux := alltrim(oGetDados1:aCols[nX][1])
                            cAux := substr(cNumEmp,1,2)+substr(cAux,len(cAux)-5,6)
                            SZB->ZB_PEDIDO := cAux //oGetDados1:aCols[nX][1]
                            SZB->ZB_RAZAO  := oGetDados1:aCols[nX][2]
                         MsUnLock()
                         DbSelectArea("ZZC")
                         DbSetOrder(2)
                         DbSeek(xFilial("ZZC")+SubStr(oGetDados1:aCols[nX][1], 3, 6), .t.)
                         If Found()
                            While !Eof() .and. (ZZC->ZZC_FILIAL == xFilial("ZZC")) .and. ZZC->ZZC_PEDIDO == SubStr(oGetDados1:aCols[nX][1], 3, 6)
                                  RecLock("ZZC", .f.)
                                     ZZC->ZZC_CARGA := SZA->ZA_CODIGO
                                  MsUnLock()
                                  DbSelectArea("ZZC")
                                  DbSkip()
                            Enddo
                         Endif
                      Else
                         If !SZA->ZA_CODIGO == SZB->ZB_CODIGO
                            If MsgYesNo("Pedido "+SubStr(oGetDados1:aCols[nX][1], 3, 6)+" está no despacho "+SZB->ZB_CODIGO, "Continua nesse despacho ?")
                               nPesBor -= Posicione("SC5", 1, xFilial("SC5")+Substr(oGetDados1:aCols[nX][1],3,6), "C5_PBRUTO")
                               nVolBor -= Posicione("SC5", 1, xFilial("SC5")+Substr(oGetDados1:aCols[nX][1],3,6), "C5_VOLUME1")
                               DbSelectArea("ZZC")
                               DbSetOrder(2)
                               DbSeek(xFilial("ZZC")+SubStr(oGetDados1:aCols[nX][1], 3, 6), .t.)
                               If Found()
                                  While !Eof() .and. (ZZC->ZZC_FILIAL == xFilial("ZZC")) .and. ZZC->ZZC_PEDIDO == SubStr(oGetDados1:aCols[nX][1], 3, 6)
                                        RecLock("ZZC", .f.)
                                           ZZC->ZZC_CARGA := SZB->ZB_CODIGO
                                        MsUnLock()
                                        DbSelectArea("ZZC")
                                        DbSkip()
                                  Enddo
                               Endif
                            Else
                               DbSelectArea("ZZC")
                               DbSetOrder(2)
                               DbSeek(xFilial("ZZC")+SubStr(oGetDados1:aCols[nX][1], 3, 6), .t.)
                               If Found()
                                  While !Eof() .and. (ZZC->ZZC_FILIAL == xFilial("ZZC")) .and. ZZC->ZZC_PEDIDO == SubStr(oGetDados1:aCols[nX][1], 3, 6)
                                        RecLock("ZZC", .f.)
                                           ZZC->ZZC_CARGA := SZA->ZA_CODIGO
                                        MsUnLock()
                                        DbSelectArea("ZZC")
                                        DbSkip()
                                  Enddo
                               Endif
                               aAdd(aTirBor, {SZB->ZB_CODIGO, SZB->ZB_PEDIDO})
                               RecLock("SZB", .f.)
                                  SZB->ZB_CODIGO := SZA->ZA_CODIGO
                               MsUnLock()
                            Endif
                         Else
                            DbSelectArea("ZZC")
                            DbSetOrder(2)
                            DbSeek(xFilial("ZZC")+SubStr(oGetDados1:aCols[nX][1], 3, 6), .t.)
                            If Found()
                               While !Eof() .and. (ZZC->ZZC_FILIAL == xFilial("ZZC")) .and. ZZC->ZZC_PEDIDO == SubStr(oGetDados1:aCols[nX][1], 3, 6)
                                     RecLock("ZZC", .f.)
                                        ZZC->ZZC_CARGA := SZA->ZA_CODIGO
                                     MsUnLock()
                                     DbSelectArea("ZZC")
                                     DbSkip()
                               Enddo
                            Endif
                         Endif
                      Endif
                   Endif
               Next
               //Altera na tabela de cabeçalho do bordero de despacho
               RecLock("SZA", .f.)
                  SZA->ZA_DESCR   := M->ZA_DESCR
                  SZA->ZA_PREVDSP := M->ZA_PREVDSP
                  SZA->ZA_REGIAO  := M->ZA_REGIAO
                  SZA->ZA_CODVEI  := M->ZA_CODVEI
                  SZA->ZA_CODMOT  := M->ZA_CODMOT
               MsUnLock()
               If Len(aTirBor) > 0
                  For nY := 1 To Len(aTirBor)
                      DbSelectArea("SZA")
                      DbSetOrder(1)
                      DbSeek(xFilial("SZA")+aTirBor[nY][1], .t.)
                      If Found()
                         RecLock("SZA", .f.)
                            SZA->ZA_PESO   -= Posicione("SC5", 1, xFilial("SC5")+aTirBor[nY][2], "C5_PBRUTO")
                            SZA->ZA_VOLUME -= Posicione("SC5", 1, xFilial("SC5")+aTirBor[nY][2], "C5_VOLUME1")
                         MsUnLock()
                      Endif
                  Next
               Endif
        ElseIf DELETA
               DbSelectArea("SZB")
               DbSetOrder(1)
               DbSeek(xFilial("SZB")+SZA->ZA_CODIGO, .t.)
               If Found()
                  DbSelectArea("ZZC")
                  DbSetOrder(2)
                  DbSeek(xFilial("ZZC")+SZB->ZB_PEDIDO, .t.)
                  If Found()
                     While !Eof() .and. (ZZC->ZZC_FILIAL == SZB->ZB_FILIAL) .and. ZZC_PEDIDO == SubStr(SZB->ZB_PEDIDO, 3, 6)
                           RecLock("ZZC", .f.)
                              ZZC->ZZC_CARGA := space(06)
                           MsUnLock()
                           DbSelectArea("ZZC")
                           DbSkip()
                     Enddo
                  Endif
                  DbSelectArea("SZG")
                  DbSetOrder(2)
                  DbSeek(xFilial("SZG")+SZB->ZB_PEDIDO, .t.)
                  If Found()
                     DbSelectArea("SZF")
                     DbSetOrder(1)
                     DbSeek(xFilial("SZF")+SZG->ZG_CODIGO, .t.)
                     If Found()
                        RecLock("SZF", .f.)
                           SZF->ZF_FLAG := 'P'
                        MsUnLock()
                     Endif
                  Endif
                  RecLock("SZB", .f.)
                     DbDelete()
                  MsUnLock()
               Endif
               RecLock("SZA", .f.)
                  DbDelete()
               MsUnLock()
        ElseIf BAIXAR
               lPodeBaixar := .t.
               DbSelectArea("SF2")
               DbOrderNickName("SF2001")
               DbSelectArea("SZB")
               DbSeek(xFilial("SZB")+SZA->ZA_CODIGO, .t.)
               If Found()
                  While !Eof() .and. SZB->ZB_FILIAL == xFilial("SZB") .AND. SZB->ZB_CODIGO == SZA->ZA_CODIGO
                        DbSelectArea("SF2")
                        If !DbSeek(xFilial("SF2")+SubStr(SZB->ZB_PEDIDO, 3, 6))
                           lPodeBaixar = .f.
                        Endif
                        DbSelectArea("SZB")
                        DbSkip()
                  Enddo
                  aCarDif := {}
                  If lPodeBaixar
                     DbSelectArea("SZB")
                     DbSeek(xFilial("SZB")+SZA->ZA_CODIGO, .t.)
                     While !Eof() .and. SZB->ZB_FILIAL == xFilial("SZB") .AND. SZB->ZB_CODIGO == SZA->ZA_CODIGO
                           //Incluir registro para as cargas despachadas.
                           DbSelectArea("SF2")
                           DbSeek(xFilial("SZB")+SubStr(SZB->ZB_PEDIDO, 3, 6))
                           If Found()
                              //Enviar informação para o Brasrepres
                              If ((cNumEmp = "01010101") .OR. (cNumEmp = "01060101")) .and. (SubStr(SZB->ZB_PEDIDO, 1, 2) $ "01_03")
//                                 U_EnviaRec("SC5", SubStr(SZB->ZB_PEDIDO, 3, 6), .F.)
                              		U_EnviaRec("SC5", SubStr(SZB->ZB_PEDIDO, 3, 6), .F.,Posicione("SC5", 1, xFilial("SC5")+SubStr(SZB->ZB_PEDIDO, 3, 6), "C5_VEND1"))
                              Endif
                           Endif
                           //Baixar Pedido da Retirada de pedidos
                           DbSelectArea("ZZC")
                           DbSetOrder(2)
                           DbSeek(xFilial("ZZC")+SubStr(SZB->ZB_PEDIDO, 3, 6), .t.)
                           While !Eof() .and. ZZC->ZZC_FILIAL == xFilial("ZZC") .and. ZZC->ZZC_PEDIDO == SubStr(SZB->ZB_PEDIDO, 3, 6)
                                 If ZZC->ZZC_CARGA == SZB->ZB_CODIGO
                                    RecLock("ZZC", .f.)
                                       ZZC->ZZC_DESPAC := 'S'
                                    MsUnLock()
                                 Else
                                    aAdd(aCarDif, {ZZC->ZZC_CARGA, SZB->ZB_PEDIDO})
                                    RecLock("ZZC", .f.)
                                       ZZC->ZZC_CARGA  := SZB->ZB_CODIGO
                                       ZZC->ZZC_DESPAC := 'S'
                                    MsUnLock()
                                 Endif
                                 DbSelectArea("ZZC")
                                 DbSkip()
                           Enddo
                           DbSelectArea("SZB")
                           Dbskip()
                     EndDo
                     DbSelectArea("SZA")
                     RecLock("SZA", .F.)
                        SZA->ZA_DTDESPA := M->ZA_DTDESPA
                        SZA->ZA_FLAG    := 'S'
                     MsUnLock()
                     If Len(aCarDif) > 0
                        For nY := 1 To Len(aCarDif)
                            nPesTir := 0
                            nVolTir := 0
                            DbSelectArea("SZB")
                            DbSetOrder(2)
                            DbSeek(xFilial("SZB")+aCarDif[nY][2], .t.)
                            If Found()
                               nPesTir += Posicione("SC5", 1, aCarDif[nY][2], "C5_PBRUTO")
                               nVolTir += Posicione("SC5", 1, aCarDif[nY][2], "C5_VOLUME1")
                               RecLock("SZB", .f.)
                                  DbDelete()
                               MsUnLock()
                            Endif
                            DbSelectArea("SZA")
                            DbSetOrder(1)
                            DbSeek(xFilial("SZA")+aCarDif[nY][1], .t.)
                            If Found()
                               RecLock("SZA", .f.)
                                  SZA->ZA_PESO   -= nPesTir
                                  SZA->ZA_VOLUME -= nVolTir
                               MsUnLock()
                            Endif
                        Next
                     Endif
                  Else
                     MsgAlert("Bordero já baixado anteriormente ou pedido não faturado. Verifique!", "A baixa não será executada!")
                  Endif
               Endif 
               /********************************************************************************************************************************/
               /*** BLOCO ALTERADO EM 11/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
               /*DbSelectArea("SX3")
               DbSetOrder(2)
               DbSeek("ZA_DTDESPA")
               If Found()
                  RecLock("SX3", .f.)
                     SX3->X3_OBRIGAT := ''
                  MsUnLock()
               Endif*/
               DbSelectArea( _cAliasSX3 )
               ( _cAliasSX3 )->( DbSetOrder(2) )
               ( _cAliasSX3 )->( DbSeek("ZA_DTDESPA") )
               If Found()
                  RecLock( _cAliasSX3 , .f.)
                     ( _cAliasSX3 )->( X3_OBRIGAT ) := ''
                  MsUnLock()
               Endif
        ElseIf CANCEL
               DbSelectArea("SZB")
               DbSeek(xFilial("SZB")+SZA->ZA_CODIGO, .t.)
               While !Eof() .and. SZB->ZB_FILIAL == xFilial("SZB") .AND. SZB->ZB_CODIGO == SZA->ZA_CODIGO
                     DbSelectArea("ZZC")
                     DbSetOrder(2)
                     DbSeek(xFilial("ZZC")+SubStr(SZB->ZB_PEDIDO, 3, 6), .t.)
                     While !Eof() .and. ZZC->ZZC_FILIAL == xFilial("ZZC") .and. ZZC->ZZC_PEDIDO == SubStr(SZB->ZB_PEDIDO, 3, 6)
                           RecLock("ZZC", .f.)
                              ZZC->ZZC_DESPAC := ' '
                           MsUnLock()
                           DbSelectArea("ZZC")
                           DbSkip()
                     Enddo
                     DbSelectArea("SZB")
                     DbSkip()
               Enddo
               DbSelectArea("SZA")
               RecLock("SZA", .F.)
                  SZA->ZA_DTDESPA := cTod(space(8))
                  SZA->ZA_FLAG    := 'N'
               MsUnLock()
        Endif
     Else
        If BAIXAR
           /********************************************************************************************************************************/
           /*** BLOCO ALTERADO EM 11/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
           /*DbSelectArea("SX3")
           DbSetOrder(2)
           DbSeek("ZA_DTDESPA")
           If Found()
              RecLock("SX3", .f.)
                 SX3->X3_OBRIGAT := ''
              MsUnLock()
           Endif*/
           DbSelectArea( _cAliasSX3 )
           ( _cAliasSX3 )->( DbSetOrder(2) )
           ( _cAliasSX3 )->( DbSeek("ZA_DTDESPA") )
           If Found()
              RecLock( _cAliasSX3 , .f.)
                 ( _cAliasSX3 )->( X3_OBRIGAT ) := ''
              MsUnLock()
           Endif
        Endif
     Endif
     DbSelectArea( _cAliasSX3 )
     DbCloseArea()
Return

/******************************************************************************************************************/
/*** FATA06_2 - Validação da linha da GetDados da montagem do bordero de despacho                               ***/
/******************************************************************************************************************/
User Function FATA06_2()
        Local nPesBor := 0
        Local nVolBor := 0
        Local nY
        For nY := 1 To Len(aCols)
            If !NwDeleted(oGetDados1, nY)
               nPesBor += Posicione("SC5", 1, aCols[nY][NwFieldPos(oGetDados1, 'ZB_PEDIDO')], "C5_PBRUTO")
               nVolBor += Posicione("SC5", 1, aCols[nY][NwFieldPos(oGetDados1, 'ZB_PEDIDO')], "C5_VOLUME1")
            Endif
        Next
        onPesBor:Refresh()
        onVolBor:Refresh()
Return(.t.)

/******************************************************************************************************************/
/*** FATA06_3 - Validação da inclusão de itens do bordero de despacho.                                          ***/
/******************************************************************************************************************/
User Function FATA06_3()
     Local nY
     DbSelectArea("SC5")
     DbSetOrder(1)
     DbSeek(M->ZB_PEDIDO, .t.)
     If Found()
        If !SC5->C5_APROVA == '1'
           MsgStop("Pedido não está aprovado, verifique!")
           Return(.f.)
        Else
           If !Empty(SC5->C5_NOTA)
              If !MsgYesNo("Pedido já faturado, verifique!", "Pergunta...")
                 Return(.f.)
              Endif
           Endif
        Endif
        DbSelectArea("SZB")
        DbSetOrder(2)
        DbSeek(xFilial("SZB")+M->ZB_PEDIDO, .t.)
        If Found()
           MsgStop("Pedido já se encontra em outro despacho, verifique!")
           Return(.f.)
        Endif
        lExiPed := .f.
        For nY := 1 To Len(aCols)
            If !NwDeleted(oGetDados1, nY)
               If nY <> n
                  If oGetDados1:aCols[nY][1] == M->ZB_PEDIDO
                     lExiPed := .t.
                  Endif
               Endif
            Endif
        Next
        If lExiPed
           MsgStop("Pedido já se encontra nesse despacho, verifique!")
           Return(.f.)
        Endif
        aCols[n][NwFieldPos(oGetDados1, 'ZB_PEDIDO')] := M->ZB_PEDIDO
        aCols[n][NwFieldPos(oGetDados1, 'ZB_RAZAO')] := Posicione("SA1", 1, xFilial("SA1")+SC5->C5_CLIENTE, 'A1_NOME')
        Return(.t.)
     Else
        MsgStop("Pedido não existe, verifique!")
        Return(.f.)
     Endif
Return

/*****************************************************************************************/
/*** FATA06_4 - Bloqueia bordero de despacho para conferencia.                         ***/
/*****************************************************************************************/
User Function FATA06_4()
     If SZA->ZA_FLAG $ ' .N'
        RecLock("SZA", .f.)
           SZA->ZA_FLAG := 'C'
        MsUnLock()
        Return
     ElseIf SZA->ZA_FLAG == 'S'
            MsgStop("Bordero já foi despachado, não pode ser conferido.")
            Return
     ElseIf SZA->ZA_FLAG == 'C'
            RecLock("SZA", .f.)
               SZA->ZA_FLAG := 'N'
            MsUnLock()
            Return
     Endif
Return

/*****************************************************************************************/
/*** FATA06_5 - Mostra a legenda com cores correspondentes.                            ***/
/*****************************************************************************************/
User Function FATA06_5()
     Local cCadastro := OemToAnsi('Bordero de Despacho')
     BrwLegenda(cCadastro, "Status",{ {"ENABLE"     ,"Não despachado"   } ,;
                                      {"BR_AMARELO" ,"Conferência"      } ,;
                                      {"DISABLE"    ,"Despachado"       } })
Return(.t.)

/******************************************************************************************************************/
/*** FATA06_6 - Re-Monta despacho                                                                               ***/
/******************************************************************************************************************/
User Function FATA06_6()
     // Variaveis Locais da Funcao
     // Variaveis da Funcao de Controle e GertArea/RestArea
     Local _aArea  := {}
     Local _aAlias := {}
     Local lRet    := .t.
     If SZA->ZA_FLAG $ 'S'
        MsgStop("Bordero já foi despachado!")
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
        Else
           ACTIVATE MSDIALOG _oDlg CENTERED ON INIT (_oDlg:End())
        Endif
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³fGetDados2()³ Autor ³ Luís Gustavo de Souza     ³ Data ³31/07/2007³±±
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
Static Function fGetDados2(nOpcX, cTipo, aAuxDes)
       // Variaveis deste Form
       Local nX           := 0
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Cria o Cabecalho da GetDados com todos os Campos do Alias ³
       //³ Caso queira IGNORAR algum Campo basta substituir o Nil    ³
       //³ por uma array com os campos Ex. {"A1_NOME","A1_LC"}		 ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       Local aGetAux1     := {"NOUSER"}
       //Local nZ           := aEval(ApBuildHeader("SZB", Nil), {|x| Aadd(aGetAux1, x[2])})
       // Fim da Criacao do Cabecalho --------------------------------
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Variaveis da MsNewGetDados()      ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       // Vetor responsavel pela montagem da aHeader
       Local aCpoGDa      := aGetAux1
       // Vetor com os campos que poderao ser alterados
       Local aAlter       := {}
       Local nSuperior    := C(082)           // Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
       Local nEsquerda    := C(000)           // Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
       Local nInferior    := C(180)           // Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
       Local nDireita     := C(363)           // Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
       // Posicao do elemento do vetor aRotina que a MsNewGetDados usara como referencia
       Local nOpc         := Iif(nOpcX == 4, 3, Iif(nOpcX == 5, 2, nOpcX)) //GD_INSERT+GD_DELETE+GD_UPDATE
       Local cLinhaOk     := Iif(nOpcX == 4 .or. nOpcX == 3, "u_FATA06_2()", "AllwaysTrue") // Funcao executada para validar o contexto da linha atual do aCols
       Local cTudoOk      := "AllwaysTrue"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
       Local cIniCpos     := ""               // Nome dos campos do tipo caracter que utilizarao incremento automatico.
                                              // Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do
                                              // segundo campo>+..."
       Local nFreeze      := 000              // Campos estaticos na GetDados.
       Local nMax         := 999              // Numero maximo de linhas permitidas. Valor padrao 99
       Local cCampoOk     := "AllwaysTrue"    // Funcao executada na validacao do campo
       Local cSuperApagar := ""               // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
       Local cApagaOk     := "AllwaysTrue"    // Funcao executada para validar a exclusao de uma linha do aCols
       // Objeto no qual a MsNewGetDados sera criada
       Local oWnd         := _oDlg
       Local aHead        := {}               // Array a ser tratado internamente na MsNewGetDados como aHeader
       Local aCol         := {}               // Array a ser tratado internamente na MsNewGetDados como aCols

       // Carrega aHead
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 11/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*DbSelectArea("SX3")
       SX3->(DbSetOrder(2)) // Campo
       For nX := 1 to Len(aCpoGDa)
           If SX3->(DbSeek(aCpoGDa[nX]))
              If UPPER(Alltrim(SX3->X3_CAMPO)) $ 'ZB_PEDIDO'
                 cCpoVld := Iif(INCLUI .or. ALTERA, 'u_FATA06_3()', 'AllwaysTrue()')
              Else
                 cCpoVld := "AllwaysTrue()"
              Endif
              aAdd(aHead, {AllTrim(( _cAliasSX3 )->( X3_TITULO )),;
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
       Next nX*/
       DbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( DbSetOrder(2) ) // Campo
       For nX := 1 to Len(aCpoGDa)
           If ( _cAliasSX3 )->( DbSeek( aCpoGDa[nX] ) )
              If UPPER( Alltrim( ( _cAliasSX3 )->( X3_CAMPO ) ) ) $ 'ZB_PEDIDO'
                 cCpoVld := Iif(INCLUI .or. ALTERA, 'u_FATA06_3()', 'AllwaysTrue()')
              Else
                 cCpoVld := "AllwaysTrue()"
              Endif
              aAdd(aHead, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),;
                            ( _cAliasSX3 )->( X3_CAMPO )      ,;
                            ( _cAliasSX3 )->( X3_PICTURE )    ,;
                            ( _cAliasSX3 )->( X3_TAMANHO )    ,;
                            ( _cAliasSX3 )->( X3_DECIMAL )    ,;
                            cCpoVld                           ,;
                            ( _cAliasSX3 )->( X3_USADO )      ,;
                            ( _cAliasSX3 )->( X3_TIPO )       ,;
                            ( _cAliasSX3 )->( X3_F3 )         ,;
                            ( _cAliasSX3 )->( X3_CONTEXT )    ,;
                            ( _cAliasSX3 )->( X3_CBOX )       ,;
                            ( _cAliasSX3 )->( X3_RELACAO )    })
           Endif
       Next nX
       // Carregue aqui a Montagem da sua aCol
       aAux := {}
       If INCLUI
          If cTipo $ 'P.R'
             nPesBor := 0
             nVolBor := 0
             For nX := 1 To Len(aAuxDes)
                 aAdd(aCol, {aAuxDes[nX][1], aAuxDes[nX][2], .f.})
                 nPesBor += Posicione("SC5", 1, xFilial("SC5")+Substr(aAuxDes[nX][1],3,6), "C5_PBRUTO")
                 nVolBor += Posicione("SC5", 1, xFilial("SC5")+Substr(aAuxDes[nX][1],3,6), "C5_VOLUME1")
             Next
          Else
             For nX := 1 to Len(aCpoGDa)
                 If DbSeek(aCpoGDa[nX])
                    //aAdd(aAux, CriaVar(SX3->X3_CAMPO))
                    aAdd(aAux, CriaVar( ( _cAliasSX3 )->( X3_CAMPO ) ) )
                 Endif
             Next nX
             aAdd(aAux, .F.)
             aAdd(aCol, aAux)
          Endif
          aAlter := aGetAux1
       Else
          If ALTERA
             //aAlter := aGetAux1
          Endif
          aCol    := {}
          nPesBor := 0
          nVolBor := 0
          cQry1 := ""
          cQry1 += "SELECT SZB.ZB_PEDIDO, SA1.A1_NOME, SC5.C5_PBRUTO, SC5.C5_VOLUME1 "
          cQry1 += "FROM "+RetSqlName("SZB")+" SZB WITH (NOLOCK) "
          cQry1 += "LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON SC5.C5_FILIAL = SZB.ZB_FILIAL AND SC5.C5_NUM = SUBSTRING(SZB.ZB_PEDIDO, 3, 6) AND SC5.D_E_L_E_T_ = '' "
          cQry1 += "LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON SA1.A1_COD = SC5.C5_CLIENTE AND SA1.A1_LOJA = SC5.C5_LOJACLI AND SC5.D_E_L_E_T_ = '' "
          cQry1 += "WHERE SZB.ZB_FILIAL  = '"+xFilial("SZB")+"' "
          cQry1 += "  AND SZB.D_E_L_E_T_ = '' "
          cQry1 += "  AND SZB.ZB_CODIGO  = '"+SZA->ZA_CODIGO+"' "
          cQry1 += "ORDER BY 1 "
          TCQuery cQry1 ALIAS "TCQSZB" NEW
          DbSelectArea("TCQSZB")
          DbGoTop()
          While !Eof()
                aAdd(aCol, {TCQSZB->ZB_PEDIDO, TCQSZB->A1_NOME, .F.})
                nPesBor += TCQSZB->C5_PBRUTO
                nVolBor += TCQSZB->C5_VOLUME1
                DbSelectArea("TCQSZB")
                DbSkip()
          Enddo
          DbSelectArea("TCQSZB")
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
       If Len(aCol) > 0
          u_fVldPed(aCol, Iif(nOpcX == 2, "V", Iif(nOpcX == 3, "I", Iif(nOpcX == 4, "A", "E"))))
       Endif
       oGetDados1 := MsNewGetDados():New(nSuperior, nEsquerda, nInferior, nDireita, nOpc, cLinhaOk, cTudoOk, cIniCpos, aAlter, nFreeze, nMax, cCampoOk, cSuperApagar, cApagaOk, oWnd, aHead, aCol)
Return Nil


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³   C()   ³ Autores ³ Norbert/Ernani/Mansano ³ Data ³10/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsave por manter o Layout independente da       ³±±
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

/********************************************************************************************/
/*** fAtvF10 - Mostra janela com valores/quantidades dos borderos de despachos pendentes. ***/
/********************************************************************************************/
Static Function fAtvF10()
       Local oDlg
       Local cMemo
       Local oFont
       Local cQry1 := ""
       Local cAux1 := ""
       Local nSomPes := 0
       Local nSomVol := 0
       Local nSomFat := 0
       Local nSomNFt := 0
       SetKey(VK_F10, Nil)
       cMemo := "+-------------------------------------------------------------------------------------------------------+"+Chr(13)+Chr(10)
       cMemo += "| BORDERO  REGIÃO                          PREVISÃO  PESO        VOLUME  NÃO FATURADO    FATURADO       |"+Chr(13)+Chr(10)
       cMemo += "+-------------------------------------------------------------------------------------------------------+"+Chr(13)+Chr(10)

       cQry1 += "SELECT SZA.ZA_CODIGO, SZA.ZA_DESCR, SZA.ZA_PREVDSP, SZA.ZA_PESO, SZA.ZA_VOLUME "
       cQry1 += "FROM "+RetSqlName("SZA")+" SZA "
       cQry1 += "WHERE SZA.ZA_FILIAL  = '"+xFilial("SZA")+"' "
       cQry1 += "  AND SZA.D_E_L_E_T_ = '' "
       cQry1 += "  AND SZA.ZA_DTDESPA = '' "
       cQry1 += "ORDER BY SZA.ZA_PREVDSP "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       While !Eof()
             //         1         2         3         4         5         6         7     
             //123456789012345678901234567890123456789012345678901234567890123456789012345
             //+-------------------------------------------------------------------------------------------------------+
             //| BORDERO  REGIÃO                          PREVISÃO  PESO        VOLUME  NÃO FATURADO    FATURADO       |
             //+-------------------------------------------------------------------------------------------------------+
             //| 999999   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  99/99/99  999,999.99  999999  999,999,999.99  999,999,999.99 |
             cQry1 := ""
             cQry1 += "SELECT SC6.C6_NOTA, SUM(SC6.C6_VALOR) AS TOTAL "
             cQry1 += "FROM "+RetSqlName("SZB")+" SZB "
             cQry1 += "LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 ON SC6.C6_FILIAL = SZB.ZB_FILIAL AND SC6.C6_NUM = SUBSTRING(SZB.ZB_PEDIDO, 3, 6) AND SC6.D_E_L_E_T_ = '' "
             cQry1 += "WHERE SZB.ZB_FILIAL  = '"+xFilial("SZB")+"' "
             cQry1 += "  AND SZB.D_E_L_E_T_ = '' "
             cQry1 += "  AND SZB.ZB_CODIGO = '"+TCQ->ZA_CODIGO+"' "
             cQry1 += "GROUP BY SC6.C6_NOTA "
             TCQuery cQry1 ALIAS "XPED" NEW
             DbSelectArea("XPED")
             xSomFat := 0
             xSomNFt := 0
             While !Eof()
                   If Empty(XPED->C6_NOTA)
                      nSomNFt += XPED->TOTAL
                      xSomNFt += XPED->TOTAL
                   Else
                      nSomFat += XPED->TOTAL
                      xSomFat += XPED->TOTAL
                   Endif
                   DbSelectArea("XPED")
                   DbSkip()
             Enddo
             cAux1 += "| "+TCQ->ZA_CODIGO+"   "+SubStr(TCQ->ZA_DESCR, 1, 30)+"  "+SubStr(TCQ->ZA_PREVDSP, 7, 2)+"/"+SubStr(TCQ->ZA_PREVDSP, 5, 2)+"/"+SubStr(TCQ->ZA_PREVDSP, 3, 2)+"  "+TransForm(TCQ->ZA_PESO, "@E 999,999.99")+"  "+TransForm(TCQ->ZA_VOLUME, "@E 999999")+"  "+TransForm(xSomNFt, "@E 999,999,999.99")+"  "+TransForm(xSomFat, "@E 999,999,999.99")+" |"+Chr(13)+Chr(10)
             nSomPes += TCQ->ZA_PESO
             nSomVol += TCQ->ZA_VOLUME
             DbSelectArea("XPED")
             DbCloseArea()
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
       If !Empty(cAux1)
          cMemo += cAux1
          cMemo += "+-------------------------------------------------------------------------------------------------------+"+Chr(13)+Chr(10)
          cMemo += "|                                                    "+TransForm(nSomPes, "@E 999,999.99")+"  "+TransForm(nSomVol, "@E 999999")+"  "+TransForm(nSomNFt, "@E 999,999,999.99")+"  "+TransForm(nSomFat, "@E 999,999,999.99")+" |"+Chr(13)+Chr(10)
          cMemo += "+-------------------------------------------------------------------------------------------------------+"+Chr(13)+Chr(10)
          DEFINE FONT oFont NAME "Courier New"
          DEFINE MSDIALOG oDlg TITLE OemToAnsi("Saldos dos Borderos") From 0,0 to 330,775 PIXEL

                 @ 5,1 GET oMemo  VAR cMemo MEMO SIZE 384,145 HScroll OF oDlg PIXEL
                 oMemo:bRClicked := {||AllwaysTrue()}
                 oMemo:oFont:=oFont
                 oMemo:lReadOnly := .t.
                 DEFINE SBUTTON  FROM 153,350 TYPE 1 ACTION (oDlg:End()) ENABLE OF oDlg PIXEL
          ACTIVATE MSDIALOG oDlg CENTER
          SetKey(VK_F10, {|| fAtvF10()})
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
       Local nX, nY
       Local _cMVREGTRA := GETMV("MV_REGTRA")

       cQry1 += "SELECT ZZC.ZZC_BORDER, ZZC.ZZC_CARGA, ZZC.ZZC_PEDIDO, ZZC.ZZC_SEPARA, SUM(ZZC.ZZC_VOLUME) AS QTDE "
       cQry1 += "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
       cQry1 += "WHERE ZZC.ZZC_FILIAL = '"+xFilial("ZZC")+"' "
       cQry1 += "  AND D_E_L_E_T_ = '' "
       cQry1 += "  AND ZZC.ZZC_CARGA = '"+SZA->ZA_CODIGO+"' "
       //cQry1 += "  AND ZZC.ZZC_CARGA  = '' "
       cQry1 += "GROUP BY ZZC.ZZC_BORDER, ZZC.ZZC_CARGA, ZZC.ZZC_PEDIDO, ZZC.ZZC_SEPARA "
       cQry1 += "ORDER BY ZZC.ZZC_PEDIDO, ZZC.ZZC_SEPARA "
       TCQuery cQry1 ALIAS "TCQZZC" NEW
       DbSelectArea("TCQZZC")
       DbGoTop()
       While !Eof()
             nPosDad := aScan(aMatDad, {|x| x[1] == TCQZZC->ZZC_PEDIDO})
             If nPosDad == 0                                                      
                aadd(aMatDad, {' ', ' ', ' ', ' ', ' ', ' ', 0 , 0 , 0, ' ', ' ', ' ', 0,})
                //              |    |    |    |    |    |   |   |   |   |    |    |   | 
                //              |    |    |    |    |    |   |   |   |   |    |    |   +-->>> 13 - Volume do Pedido
                //              |    |    |    |    |    |   |   |   |   |    |    +------>>> 12 - Endereço na Expedição
                //              |    |    |    |    |    |   |   |   |   |    +----------->>> 11 - Previsão despacho
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
                //LGS#20200212 - Adequação de release 12.1.25 e posteriores
                //If GETMV("MV_REGTRA") $ 'R'
                If _cMVREGTRA $ 'R'
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
                aMatDad[Len(aMatDad)][11] := Posicione("SC5", 1, xFilial("SC5")+aMatDad[Len(aMatDad)][01], "C5_PEDPROG") 
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
           //LGS#20200212 - Adequação de release 12.1.25 e posteriores
           //Adiciona Item para a Transportadora/Redespacho
           /*aAdd(aMonDes, {.f.              ,;
                          ''               ,;
                          aMatReg[nY]+' - '+Iif(GETMV("MV_REGTRA") $ 'R', Alltrim(Posicione("SX5", 1, xFilial("SX5")+'98'+aMatReg[nY], "X5_DESCRI")), Alltrim(Posicione("SA4", 1, xFilial("SA4")+aMatReg[nY], "A4_NOME")) ),;
                          0                ,;
                          ''               ,;
                          TransForm(0, "@E 999.99") ,;
                           aMatReg[nY]      ,;
                          aMatReg[nY]+'000' ,;
                          ''				})*/
           aAdd(aMonDes, {.f.              ,;
                          ''               ,;
                          aMatReg[nY]+' - '+Iif( _cMVREGTRA $ 'R', Alltrim(Posicione("SX5", 1, xFilial("SX5")+'98'+aMatReg[nY], "X5_DESCRI")), Alltrim(Posicione("SA4", 1, xFilial("SA4")+aMatReg[nY], "A4_NOME")) ),;
                          0                ,;
                          ''               ,;
                          TransForm(0, "@E 999.99") ,;
                           aMatReg[nY]      ,;
                          aMatReg[nY]+'000' ,;
                          ''				})           

           //Adiciona Pedidos a serem despachados
           For nX := 1 To Len(aMatImp)
               aAdd(aMonDes, {.f.            ,;
                              aMatImp[nX][01],;
                              aMatImp[nX][02]+'/'+aMatImp[nX][03]+' - '+aMatImp[nX][04],;
                              aMatImp[nX][15],;
                              aMatImp[nX][12],;
                              TransForm(aMatImp[nX][13], "@E 999.99"),;
                              aMatImp[nX][06],;
                              aMatImp[nX][14],; 
                              aMatImp[nX][11]}) // programação
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
                        HEADER "", "PEDIDO", "CLIENTE", "VOLUME", "LOCALIZAÇÃO", "% SEPARADO","TRANSPORTE", "DT. PROGRAMAÇÃO";
                        Size C(383),C(097) Of _oDlg Pixel;
                        ColSizes 0, 25, 150, 30, 50, 30;
                        On DBLCLICK (fMarCar(), oMonDes:Refresh()) //aMonDes[oMonDes:nAt,1] := !(aMonDes[oMonDes:nAt,1]), oMonDes:Refresh() )
                        oMonDes:SetArray(aMonDes)

       oMonDes:bLine   := {|| {If(aMonDes[oMonDes:nAT][01], oOk, oNo),;
                                aMonDes[oMonDes:nAT][02]           ,;
                                aMonDes[oMonDes:nAT][03]           ,;
                                aMonDes[oMonDes:nAT][04]           ,;
                                aMonDes[oMonDes:nAT][05]           ,;
                                aMonDes[oMonDes:nAT][06]           ,;
                                aMonDes[oMonDes:nAT][07]           ,;
                                aMonDes[oMonDes:nAT][09]            }} // PROGRAMAÇÃO
       oMonDes:bChange := { || fTroPed(@cPedFal)}
Return(.T.)

/******************************************************************************************************************/
/*** fTroPed - Ajusta observação na troca dos pedidos                                                           ***/
/******************************************************************************************************************/
Static Function fTroPed(cObsMsg)
       Local cQry1 := ""
	   cObsMsg := "| QTDE. PRODUTO          DESCRIÇÃO                      VOLUME     LOCALIZAÇÃO     PRX. DESP.            |"+CHR(13)+CHR(10)
       cObsMsg += "+--------------------------------------------------------------------------------------------------------+"+CHR(13)+CHR(10)
       nQtdPro := 0
       If !Empty(oMonDes:aArray[oMonDes:nAt][2])
          DbSelectArea("ZZC")
          DbSetOrder(4)
          DbSeek(xFilial("ZZC")+SZA->ZA_CODIGO+oMonDes:aArray[oMonDes:nAt][2], .t.)
          If Found()
             While !Eof() .and. (ZZC->ZZC_FILIAL == xFilial("ZZC")) .and. (ZZC->ZZC_CARGA == SZA->ZA_CODIGO) .and. ZZC->ZZC_PEDIDO == oMonDes:aArray[oMonDes:nAt][2]
                   If ZZC->ZZC_SEPARA <> 'S'
                      cQry1 := ""
                      cQry1 += "SELECT TOP 1 * "
                      cQry1 += "FROM PROXDESP_X_PRODUTO AS PROX "
                      cQry1 += "WHERE PROX.PRODUTO = '"+ZZC->ZZC_PRODUTO+"' "
                      cQry1 += "  AND PROX.CODIGO <> '"+ZZC->ZZC_CARGA+"' "
                      cQry1 += "ORDER BY PROX.PREVISAO, PROX.PEDIDO DESC "
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
/*** fMarCar - Marca e desmarca Cargas                                                                          ***/
/******************************************************************************************************************/
Static Function fMarCar()
       Local nX
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
/*** fNewBor - Grava um novo bordero de despacho                                                                ***/
/******************************************************************************************************************/
Static Function fNewBor()      
       Local cTransp, nY, nX, nA
       Local aMatReg := {}
       Local aQtdReg := {}
       //1º) Verificar quais regiões que possuen cargas marcadas e gravar na matriz aMatReg
       For nY := 1 To Len(oMonDes:aArray)
           If oMonDes:aArray[nY][1]
              If aScan(aMatReg, {|x| x[1] == oMonDes:aArray[nY][7]}) == 0
                 aadd(aMatReg, {oMonDes:aArray[nY][7], 0, 0})
              Endif
           Endif
           If Empty(oMonDes:aArray[nY][2])
           		cTransp := alltrim(substr(oMonDes:aArray[nY][3],1,at("-",oMonDes:aArray[nY][3])-1))
              	aAdd(aQtdReg, {cTransp, 0, 0, 0})
           Else
              aQtdReg[aScan(aQtdReg, {|x| Alltrim(x[1]) == Alltrim(oMonDes:aArray[nY][7])})][2] += 1
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
              lTroBor := .f.
              If (Len(oMonDes:aArray) - 1) == Len(aAuxDes)
                 If !MsgYesNo("Confirma a Troca de bordero para todos os pedidos ?", "Atenção...")
                    Return(.f.)
                 Endif
                 lTroBor := .t.
              Endif
              u_FATA06_1( , , , , "R", aMatReg[nA][1], @aAuxDes, @aQtdReg, lTroBor)
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
/*Static Function NwFieldGet(oObjeto, cCampo, nLinha)
       Local nCol     := aScan(oObjeto:aHeader, {|x| AllTrim(x[2]) == Upper(cCampo)})
       Local xRet
       // Se nLinha nao for preenchida Retorna a Posicao de nAt do Objeto
       Default nLinha := oObjeto:nAt
       xRet := oObjeto:aCols[nLinha][nCol]
Return(xRet)*/

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
/*Static Function NwFieldPut(oObjeto, cCampo, nLinha, xNewValue)
       Local nCol := aScan(oObjeto:aHeader,{|x| AllTrim(x[2]) == Upper(cCampo)})
       // Se nLinha nao for preenchida Retorna a Posicao de nAt do Objeto
       Default nLinha := oObjeto:nAt
       // Alimenta Celula com novo Valor se este foi preenchido
       If !Empty(xNewValue)
          oObjeto:aCols[nLinha][nCol] := xNewValue
       Endif
Return Nil*/

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
/*** fBorJaE - Grava em um bordero já existente                                                                 ***/
/******************************************************************************************************************/
Static Function fBorJaE() 
       Local nY,nQtdeReg,cTransp, nA
       Local aMatReg  := {}
       Local aButtons := {}
       Local nOpcA    := 0
       Local aQtdReg  := {}
       Private aMarCar:= {}
       Private oMarCar
       //Private nA
       nQtdeReg := Len(oMonDes:aArray)
       //1º) Verificar se existe pedidos marcados por região
       For nY := 1 To nQtdeReg
           If oMonDes:aArray[nY][1]
              If aScan(aMatReg, {|x| x[1] == oMonDes:aArray[nY][7]}) == 0
                 aadd(aMatReg, {oMonDes:aArray[nY][7], 0, 0})
              Endif
           Endif
           If Empty(oMonDes:aArray[nY][2])   
           		cTransp := alltrim(substr(oMonDes:aArray[nY][3],1,at("-",oMonDes:aArray[nY][3])-1))
              	aAdd(aQtdReg, {cTransp, 0, 0, 0}) //SubStr(oMonDes:aArray[nY][3], 1, 5)
           Else
              aQtdReg[aScan(aQtdReg, {|x| Alltrim(x[1]) == Alltrim(oMonDes:aArray[nY][7])})][2] += 1
              If oMonDes:aArray[nY][1]
                 aQtdReg[aScan(aQtdReg, {|x| Alltrim(x[1]) == Alltrim(oMonDes:aArray[nY][7])})][3] += 1
              Endif
           Endif
       Next
       If Len(aMatReg) > 0
          DEFINE MSDIALOG _oDlg1 TITLE "Borderos de Despacho Existentes" FROM C(178),C(181) TO C(400),C(674) PIXEL
                 fListBox2()
          ACTIVATE MSDIALOG _oDlg1 CENTERED  ON INIT EnchoiceBar(_oDlg1, {||nOpcA := 1, _oDlg1:End()}, {|| _oDlg1:End()},, aButtons)
          If nOpcA == 1
             For nA := 1 To Len(aMarCar)
                 If aMarCar[nA][1]
                    cBorDes := aMarCar[nA][2]
                 Endif
             Next
             If !Empty(cBorDes)
                //Guarda código do bordero atual
                cBorAtu := SZA->ZA_CODIGO

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
                          //Posiciona no item e troca o numero do bordero de pedidos
                          DbSelectArea("SZB")
                          DbSetOrder(2)
                          DbSeek(xFilial("SZB")+'01'+oMonDes:aArray[nA][2], .t.)
                          If Found()
                          	RecLock("SZB", .f.)
                            	SZB->ZB_CODIGO := cBorDes
                          	MsUnLock()
                           	nPesBor += Posicione("SC5", 1, xFilial("SC5")+oMonDes:aArray[nA][2], "C5_PBRUTO")
                          	nVolBor += Posicione("SC5", 1, xFilial("SC5")+oMonDes:aArray[nA][2], "C5_VOLUME1")
                          Endif
                          DbSelectArea("ZZC")
                          DbSetOrder(2)
                          DbSeek(xFilial("ZZC")+oMonDes:aArray[nA][2], .t.)
                          If Found()
                             While !Eof() .and. ZZC->ZZC_FILIAL == xFilial("ZZC") .and. ZZC->ZZC_PEDIDO == oMonDes:aArray[nA][2]
                                   RecLock("ZZC", .f.)
                                      ZZC->ZZC_CARGA := cBorDes
                                   MsUnLock()
                                   DbSelectArea("ZZC")
                                   DbSkip()
                             Enddo
                          Else
                             DbSelectArea("SC6")
                             DbSetOrder(2)
                             DbSeek(xFilial("SC6")+oMonDes:aArray[nA][2], .t.)
                             If Found()
                                While !Eof() .AND. SC6->C6_FILIAL == SZB->ZB_FILIAL .AND. SC6->C6_NUM == oMonDes:aArray[nA][2]
                                      RecLock("ZZC", .t.)
                                         ZZC->ZZC_FILIAL := xFilial("ZZC")
                                         ZZC->ZZC_BORDER := Posicione("SZG", 1, xFilial("SZG")+'01'+oMonDes:aArray[nA][2], "ZG_CODIGO")
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
                          aAdd(aDelMon, oMonDes:aArray[nA][2])
                       Endif
                   Next
                   //Ajuste no Bordero anterior
                   nQtdAtu := 0
                   nQtdPes := 0
                   nQtdVol := 0
                   DbSelectArea("SZA")
                   DbSetOrder(1)
                   DbSeek(xFilial("SZA")+cBorAtu, .t.)
                   If Found()
                      DbSelectArea("SZB")
                      DbsetOrder(1)
                      DbSeek(xFilial("SZB")+cBorAtu, .t.)
                      If Found()
                         While !Eof() .and. (SZB->ZB_FILIAL == xFilial("SZB")) .and. SZB->ZB_CODIGO = cBorAtu
                               nQtdpes += Posicione("SC5", 1, SZB->ZB_PEDIDO, "C5_PBRUTO")
                               nQtdVol += Posicione("SC5", 1, SZB->ZB_PEDIDO, "C5_VOLUME1")
                               nQtdAtu += 1
                               DbSelectArea("SZB")
                               DbSkip()
                         Enddo
                      Endif
                      If nQtdAtu <= 0
                         DbSelectArea("SZA")
                         RecLock("SZA", .f.)
                            DbDelete()
                         MsUnLock()
                      Else
                         DbSelectArea("SZA")
                         RecLock("SZA", .f.)
                            SZA->ZA_PESO   := nQtdPes
                            SZA->ZA_VOLUME := nQtdVol
                         MsUnLock()
                      Endif
                   Endif
                   //Ajuste no Bordero atual
                   DbSelectArea("SZA")
                   DbSetOrder(1)
                   DbSeek(xFilial("SZA")+cBorDes, .t.)
                   If Found()
                      RecLock("SZA", .f.)
                         SZA->ZA_PESO   += nVolBor
                         SZA->ZA_VOLUME += nPesBor
                      MsUnLock()
                   Endif
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
                   MsgStop("Nenhum Bordero de Despacho foi selecionado.")
                Endif
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
       cQry1 += "  AND SZA.ZA_CODIGO <> '"+SZA->ZA_CODIGO+"' "
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
                        ColSizes 0, 35, 35, 35, 100, 35, 35;
                        On DBLCLICK (fMarDes(), oMarCar:Refresh())
       oMarCar:SetArray(aMarCar)

       oMarCar:bLine   := {|| {If(aMarCar[oMarCar:nAT][01], oOk, oNo),;
                                  aMarCar[oMarCar:nAT][02]           ,;
                                  aMarCar[oMarCar:nAT][03]           ,;
                                  aMarCar[oMarCar:nAT][04]           ,;
                                  aMarCar[oMarCar:nAT][05]           ,;
                                  aMarCar[oMarCar:nAT][06]           ,;
                                  aMarCar[oMarCar:nAT][07]			 }}
                                  
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
