//#include 'brasilux.ch'
#include "protheus.ch"
#include 'topconn.ch'
/********************************************************************************************************************/
/*** Este programa foi desenvolvido com o intuito de auxiliar na manutenção da base de dados do microsiga quality ***/
/*** devido a problemas na versão 7.10 com relação a duplicação de cadastros na tabela SG2, no momento da geração ***/
/*** de uma nova revisão do produto. O intuito dele é verificar e acertar a base SG2 e o campo B1_OPERPAD da ta - ***/
/*** bela SB1, e fazer a geração de uma nova revisão. Tão logo seja alterado para a versão 8.11 desativa-lo.   ***/
/********************************************************************************************************************/
User Function QManut()
     Local oDlg
     Local nOpca     := 2
     Local lContinua := .f.
     Local lRet      := .f.
     Private cPerg   := "QMANUT"

     ValPerg()
     Pergunte("QMANUT", .f.)

     DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi("Manutenção do Inspeção de Processos.")                                    PIXEL
            @ 18,  6 TO 76, 287 LABEL ""                                                                             OF oDlg PIXEL
            @ 29, 15 SAY OemToAnsi("Este programa permite a manutenção da base de infomações do módulo -") SIZE 268, 8 OF oDlg PIXEL
            @ 38, 15 SAY OemToAnsi("de controle de processos devido a um problema de duplicação dos re -") SIZE 268, 8 OF oDlg PIXEL
            @ 47, 15 SAY OemToAnsi("gistro no cadastro de operações que será corrgido a partir da versão") SIZE 268, 8 OF oDlg PIXEL
            @ 56, 15 SAY OemToAnsi("8.11, e ainda fazer a geração de nova revisão.                      ") SIZE 268, 8 OF oDlg PIXEL

            DEFINE SBUTTON FROM 90, 193 TYPE 5 ACTION Pergunte("QMANUT",.T.)                     ENABLE              OF oDlg
            DEFINE SBUTTON FROM 90, 223 TYPE 1 ACTION (lContinua := .t., oDlg:End(), nOpca := 1) ENABLE              OF oDlg
            DEFINE SBUTTON FROM 90, 253 TYPE 2 ACTION (lContinua := .t., oDlg:End(), nOpca := 2) ENABLE              OF oDlg
            oDlg:nStyle    := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
     ACTIVATE MSDIALOG oDlg VALID lContinua CENTERED
     If nOpca == 1
        If mv_par01 == 2
           cProdut := mv_par02
           cDesPro := Posicione("SB1", 1, xFilial("SB1")+mv_par02, "B1_DESC")
           cRevAtu := QA_ULTRVQ(mv_par02,,.f.)
           cRevNew := StrZero(Val(cRevAtu)+1, 2)
           cRotAtu := "01"
           cRotNew := "01"
           lGerRev := .t.
           //1º) Verifica se existe cadastrada a revisão do produto
           DbSelectArea("QP6")
           DbSetOrder(1)
           DbSeek(xFilial("QP6")+mv_par02+Inverte(cRevAtu), .t.)
           If Found()
              //2º)Verificar se existe roteiro cadastrado
              DbSelectArea("SG2")
              DbSetOrder(1)
              DbSeek(xFilial("SG2")+cProdut+cRotNew, .t.)
              If Found()
                 DbSelectArea("QP7")
                 DbSetOrder(1)
                 DbSeek(xFilial("QP7")+cProdut+cRevNew+cRotNew, .t.)
                 If Found()
                    MsgAlert("Roteiro:"+cRotNew+" está cadastrado. Informe outro roteiro destino.", "Atenção")
                    Return
                 Else
                    lGerRev := .t.
                 Endif
              Else
                 MsgAlert("Roteiro não encontrado !", "Atenção...")
                 Return
              Endif
           Else
              MsgAlert("Produto/Revisão não cadastrado !", "Atenção...")
              Return
           Endif
           If lGerRev
              MsAguarde( {|| lRet := QManut_2(cProdut, cDesPro, cRevAtu, cRevNew, cRotAtu, cRotNew)}, "Aguarde...", "Gerando Revisão...")
              If lRet
                 MsgInfo("Revisão foi gerada com sucesso !", "Atenção...")
              Else
                 MsgStop("Revisão não foi gerada !", "Atenção...")
              Endif
           Else
              MsgStop("Revisão não foi gerada !", "Atenção...")
           Endif
        ElseIf mv_par01 == 1
               cQry1 := "" ; cQry2 := "" ; cQry3 := ""
               cQry1 += "SELECT SB1.B1_COD, SB1.B1_DESC, SB1.B1_TIPO, SB1.B1_OPERPAD "
               cQry2 += "SELECT COUNT(*) as QTDE "
               cQry3 += "FROM "+RetSqlName("SB1")+" SB1 "
               cQry3 += "WHERE SB1.B1_FILIAL  = '"+xFilial("SB1")+"' "
               cQry3 += "  AND SB1.D_E_L_E_T_ = '' "
               cQry3 += "  AND SB1.B1_TIPO = 'PI' "
               cQry1 += cQry3
               cQry2 += cQry3
               cQry1 += "ORDER BY SB1.B1_COD "

               TCQUERY cQry1 NEW ALIAS "TCQ"
               TCQUERY cQry2 NEW ALIAS "QTD"
           
               DbSelectArea("QTD")
               nQtdReg := QTD->QTDE
               DbSelectArea("QTD")
               DbCloseArea()
           
               DbSelectArea("TCQ")
               _oProcess := MsNewProcess():New( { |lEnd| QManut_1(_oProcess, nQtdReg) }, "Aguarde...", "Produtos Inspecionados...", .f.)
               _oProcess:Activate ()

               DbSelectArea("TCQ")
               DbCloseArea()
        Endif
     Endif
Return

/************************************************************************************************/
/*** QManut_1 - Manutenção da base de dados do QIP.                                           ***/
/************************************************************************************************/
Static Function QManut_1(_oProcess, nQtdReg)
       Local lContinua := .f.
       Local nY
       Local _CodUsr   := RetCodUsr() //LGS#20200204 - Adequação de release 12.1.25 e posteriores
       DbSelectArea("TCQ")
       _oProcess:SetRegua1(nQtdReg)
       aSemRev := {}
       While !Eof()
             //1º) Query para busca de todos os roteiros de um determinado produto
             cQry1 := "" ; cQry2 := "" ; cQry3 := ""
             cQry1 += "SELECT * "
             cQry2 += "SELECT COUNT(*) AS QTDE "
             cQry3 += "FROM "+RetSqlName("SG2")+" SG2 "
             cQry3 += "WHERE SG2.G2_FILIAL  = '"+xFilial("SG2")+"' "
             cQry3 += "  AND SG2.D_E_L_E_T_ = '' "
             cQry3 += "  AND SG2.G2_PRODUTO = '"+TCQ->B1_COD+"' "
             cQry1 += cQry3
             cQry2 += cQry3
             cQry1 += "ORDER BY SG2.G2_CODIGO, SG2.G2_PRODUTO, SG2.G2_OPERAC, G2_REVIPRD "
             TCQUERY cQry1 NEW ALIAS "ROT"
             TCQUERY cQry2 NEW ALIAS "QTD"
             DbSelectArea("QTD")
             nQtdReg := QTD->QTDE
             DbSelectArea("QTD")
             DbCloseArea()
             _oProcess:SetRegua2(nQtdReg)
             DbSelectArea("ROT")
             _SeqRot := "01"
             aRotOri := {}
             aRotOut := {}
             _UltRev := QA_ULTRVQ(TCQ->B1_COD,,.f.)
             If !Empty(_UltRev)
                //2º) Busca a revisão original do produto e grava na matriz como a principal, as outras serão deletadas
                While !Eof()
                      If ROT->G2_REVIPRD $ _UltRev
                         aadd(aRotOri, {ROT->G2_CODIGO+ROT->G2_PRODUTO+ROT->G2_OPERAC+ROT->G2_REVIPRD, ROT->G2_CODIGO, ROT->G2_PRODUTO, ROT->G2_OPERAC, ROT->G2_REVIPRD, ROT->R_E_C_N_O_})
                      Else
                         aadd(aRotOut, {ROT->G2_CODIGO+ROT->G2_PRODUTO+ROT->G2_OPERAC+ROT->G2_REVIPRD, ROT->G2_CODIGO, ROT->G2_PRODUTO, ROT->G2_OPERAC, ROT->G2_REVIPRD, ROT->R_E_C_N_O_})
                      Endif
                      _oProcess:IncRegua2("Ajustando...")
                      DbSelectArea("ROT")
                      DbSkip()
                Enddo
                DbSelectArea("ROT")
                DbCloseArea()
                If Len(aRotOri) > 0
                   //3º) Se existirem revisões igual a revisão atual do produto, grava as outras na matriz de 
                   //    delecão e verifica se os roteiros não estão duplicados
                   aRevOri := {}
                   aMatDel := aRotOut
                   For nY := 1 to Len(aRotOri)
                       If aScan(aRevOri, {|x| x[1] = aRotOri[nY][4]}) == 0
                          aadd(aRevOri, {aRotOri[nY][2], aRotOri[nY][3], aRotOri[nY][4], aRotOri[nY][5], aRotOri[nY][6] })
                       Else
                          aadd(aMatDel, {aRotOri[nY][1], aRotOri[nY][2], aRotOri[nY][3], aRotOri[nY][4], aRotOri[nY][5], aRotOri[nY][6] })
                       Endif
                   Next
                   //4º)Se a matriz aRevOri for maior que 0, ajustar o codigo do roteiro e a revisão do produto; excluir
                   //   os outros roteiros caso a matriz aMatDel for maior que zero.
                   If Len(aRevOri) > 0
                      //Ajuste do Roteiro para o produto
                      cAuxAce := ""
                      cAuxAce += "UPDATE "+RetSqlName("SG2")+" "
                      cAuxAce += "SET  G2_CODIGO = '01', G2_REVIPRD = '"+_UltRev+"' "
                      cAuxAce += "WHERE R_E_C_N_O_ IN( "
                      For nY := 1 To Len(aRevOri)
                          cAuxAce += StrZero(aRevOri[nY][5], 6)+", "
                      Next
                      cAuxAce := SubStr(cAuxAce, 1, Len(cAuxAce) - 2)+") "
                      //Atualiza cadastro de produtos
                      cAuxSB1 := ""
                      cAuxSB1 += "UPDATE "+RetSqlName("SB1")+" "
                      cAuxSB1 += "SET B1_OPERPAD = '01' "
                      cAuxSB1 += "WHERE B1_FILIAL = '01' "
                      cAuxSB1 += "  AND D_E_L_E_T_ = '' "
                      cAuxSB1 += "  AND B1_COD = '"+TCQ->B1_COD+"' "
                      //Atualiza cadastro de especificação do produto
                      cAuxQP6 := ""
                      cAuxQP6 += "UPDATE "+RetSqlName("QP6")+" "
                      cAuxQP6 += "SET QP6_CODREC = '01' "
                      cAuxQP6 += "WHERE QP6_FILIAL = '01' "
                      cAuxQP6 += "  AND D_E_L_E_T_ = '' "
                      cAuxQP6 += "  AND QP6_PRODUT = '"+TCQ->B1_COD+"' "
                      cAuxQP6 += "  AND QP6_REVI   = '"+_UltRev+"' "
                      //Atualiza cadastro de especificações mensuraveis
                      cAuxQP7 := ""
                      cAuxQP7 += "UPDATE "+RetSqlName("QP7")+" "
                      cAuxQP7 += "SET QP7_CODREC = '01' "
                      cAuxQP7 += "WHERE QP7_FILIAL = '01' "
                      cAuxQP7 += "  AND D_E_L_E_T_ = '' "
                      cAuxQP7 += "  AND QP7_PRODUT = '"+TCQ->B1_COD+"' "
                      cAuxQP7 += "  AND QP7_REVI   = '"+_UltRev+"' "
                      //Atualiza cadastro de especificações texto 
                      cAuxQP8 := ""
                      cAuxQP8 += "UPDATE "+RetSqlName("QP8")+" "
                      cAuxQP8 += "SET QP8_CODREC = '01' "
                      cAuxQP8 += "WHERE QP8_FILIAL = '01' "
                      cAuxQP8 += "  AND D_E_L_E_T_ = '' "
                      cAuxQP8 += "  AND QP8_PRODUT = '"+TCQ->B1_COD+"' "
                      cAuxQP8 += "  AND QP8_REVI   = '"+_UltRev+"' "

                      DbSelectArea("SG2")
                      //LGS#20200204 - Adequação de release 12.1.25 e posteriores
                      //If RetCodUsr() $ '000000'
                      If _CodUsr $ '000000'
                         If TCSQLEXEC(cAuxAce) < 0
                            MsgInfo(TCSQLERROR())
                         Else
                            TCSQLEXEC(cAuxSB1)
                            TCSQLEXEC(cAuxQP6)
                            TCSQLEXEC(cAuxQP7)
                            TCSQLEXEC(cAuxQP8)
                         Endif
                      Endif
                      //Exclusão da Matriz aMatDel para outros roteiros
                      If Len(aMatDel) > 0
                         cAuxDel := ""
                         cAuxDel += "UPDATE "+RetSqlName("SG2")+" "
                         cAuxDel += "SET D_E_L_E_T_ = '*' "
                         cAuxDel += "WHERE R_E_C_N_O_ IN( "
                         For nY := 1 To Len(aMatDel)
                             cAuxDel += StrZero(aMatDel[nY][6], 6)+", "
                         Next
                         cAuxDel := SubStr(cAuxDel, 1, Len(cAuxDel) - 2)+")"
                         DbSelectArea("SG2")
                         //LGS#20200204 - Adequação de release 12.1.25 e posteriores
                         //If RetCodUsr() $ '000000'
                         If _CodUsr $ '000000'
                            TCSQLEXEC(cAuxDel)
                         Endif
                      Endif
                   Else
                      //Buscar na matriz aMatDel um código de roteiro para o produto
                      For nY := 1 To Len(aMatDel)
                          aadd(aSemRev, {TCQ->B1_COD, TCQ->B1_DESC, "AVISAR ADMINISTRADOR SOBRE ESSE PRODUTO."})
                      Next
                   Endif
                Else
                   //Verificar o porque do produto não ter revisão e montar uma revisão para o produto
                   If Len(aRotOut) > 0
                      aadd(aSemRev, {TCQ->B1_COD, TCQ->B1_DESC, "AVISAR ADMINISTRADOR SOBRE ESSE PRODUTO."})
                   Else
                      aadd(aSemRev, {TCQ->B1_COD, TCQ->B1_DESC, "SEM ROTEIRO."})
                   Endif
                Endif
             Else
                aadd(aSemRev, {TCQ->B1_COD, TCQ->B1_DESC, "SEM REVISÃO."})
                DbSelectArea("ROT")
                DbCloseArea()
             Endif
             _oProcess:IncRegua1("Produto Inspecionado: " + Alltrim(TCQ->B1_COD) )
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       If Len(aSemRev) > 0
          DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi("Produtos sem revisão.")                     PIXEL
                 @ 10,005 LISTBOX oSemRev FIELDS TITLE OemToAnsi("Código"), OemToAnsi("Descrição"), OemToAnsi("Ocorrência") SIZE 280, 080 PIXEL OF oDlg
                 DEFINE SBUTTON FROM 90, 253 TYPE 2 ACTION (lContinua := .t., oDlg:End()) ENABLE                        OF oDlg
                 
                 oSemRev:SetArray(aSemRev)
                 oSemRev:bLine := {|| oSemRev:aArray[oSemRev:nAt]}
                 oDlg:nStyle    := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
          ACTIVATE MSDIALOG oDlg VALID lContinua CENTERED          
       Endif
Return

/************************************************************************************************/
/*** QManut_2 - Geração de uma nova revisão.                                                  ***/
/************************************************************************************************/
Static Function QManut_2(cProdut, cDesPro, cRevAtu, cRevNew, cRotAtu, cRotNew)
       Local lRet      := .f.
       Local cReviAtu  := ""
       Local cReviBack := ""
       Local lExisAlEsp:= Iif(QP6->(FieldPos("QP6_ALTESP")) > 0,.T.,.F.)
       //Local lOk       
       Local cKeyNewH  := "" // Chaves com o novo produto para gravacao
       Local nI
       Private dVigRev := dDataBase
       
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Atualiza QP6 - Gravacao										 ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       dbSelectArea("QP6")
       dbSetOrder(1)
       dbSeek(xFilial("QP6")+cProdut+Inverte(cRevAtu), .t.)
       If Found()
          aDados := {}
          nRec   := Recno()
          For nI:=1 To FCount()
              aAdd(aDados,FieldGet(nI))
          Next
          RecLock("QP6",.T.)
             For nI := 1 To FCount()
                 cCampo := FieldName(nI)
                 If cCampo == "QP6_PRODUT"
                    QP6->QP6_PRODUT:= cProdut
                 ElseIf cCampo == "QP6_REVI"
                        QP6->QP6_REVI := cRevNew
                 ElseIf cCampo == "QP6_DESCPO"
                        QP6->QP6_DESCPO := cDesPro
                 ElseIf cCampo == "QP6_REVINV"
                        QP6->QP6_REVINV := Inverte(cRevNew)
                 ElseIf cCampo == "QP6_CODREC"
                        QP6->QP6_CODREC := cRotNew
                 Else
                    FieldPut(nI,aDados[nI])
                 Endif
             Next
             lRet := .t. //Flag para indicar que houve duplicacao de arquivo.
          MsUnLock()
          dbSelectArea("QP6")
          dbGoTo(nRec)
       Endif
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Atualiza Operacoes - SG2									 ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       dbSelectArea("SG2")
       dbSetOrder(1)
       dbSeek(xFilial("SG2")+cProdut+cRotAtu, .t.)
       If Found()
          While (!Eof() .And. SG2->G2_FILIAL+SG2->G2_PRODUTO+SG2->G2_CODIGO == xFilial("SG2")+cProdut+cRotAtu)
                cReviAtu := SG2->G2_REVIPRD+SG2->G2_OPERAC
                If SG2->G2_REVIPRD <> cRevAtu .Or. cReviBack $ cReviAtu
                   dbSkip()
                   Loop
                EndIf
                cReviBack +=SG2->G2_REVIPRD+SG2->G2_OPERAC
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Atualiza arquivo QA2 - TEXTO           							  ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                cOperac := SG2->G2_OPERAC
                cEspecH := "QIPA010 "
                dbSelectArea("QA2")
                dbSetOrder(1)
                If dbSeek(xFilial("QA2")+cEspecH+SG2->G2_CHAVE)
                   cKeyNewH := xFilial("SG2")+cProdut+cRevNew+SG2->G2_OPERAC
                   cKeyNewH := QA_CvKey(cKeyNewH,"SG2",2)
                   While !QA2->(eof()) .and. xFilial("QA2") == QA2_FILIAL .and. QA2_CHAVE == SG2->G2_CHAVE.and. QA2_ESPEC == cEspecH
                         nCount ++
                         aDados := {}
                         nRec   := Recno()
                         For nI:=1 To FCount()
                             aAdd(aDados,FieldGet(nI))
                         Next
                         RecLock("QA2",.T.)
                            For nI := 1 To FCount()
                                cCampo := FieldName(nI)
                                If cCampo == "QA2_CHAVE"
                                   QA2->QA2_CHAVE := cKeyNewH
                                ElseIf cCampo == "QA2_ESPEC"
                                       QA2->QA2_ESPEC := cEspecH
                                ElseIf cCampo == "QA2_SEQ"
                                       QA2->QA2_SEQ := StrZero(nCount,3)
                                Else
                                   FieldPut(nI,aDados[nI])
                                Endif
                            Next
                            lRet := .T. //Flag para indicar que houve duplicacao de arquivo.
                         MsUnLock()
                         dbSelectArea("QA2")
                         dbGoTo(nRec)
                         dbSkip()
                   EndDo
                   nCount := 0
                EndIf	
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Atualiza arquivo QQ2 - Rastreabilidade - Não aplicado a BRASILUX ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Atualiza QP7 - Gravacao										 ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                dbSelectArea("QP7")
                dbSetOrder(1)
                dbSeek(xFilial("QP7")+cProdut+cRevAtu+cRotAtu+SG2->G2_OPERAC)
                While !QP7->(Eof()) .and. xFilial("QP7") == QP7->QP7_FILIAL .and. QP7->QP7_PRODUT == cProdut .and. QP7->QP7_REVI == cRevAtu .and. QP7->QP7_CODREC == cRotAtu .and. QP7->QP7_OPERAC == SG2->G2_OPERAC
                      aDados  := {}
                      nRecQP7 := Recno()
                      For nI := 1 To FCount()
                          aAdd(aDados, FieldGet(nI))
                      Next
                      RecLock("QP7",.T.)
                         For nI := 1 To FCount()
                             cCampo := FieldName(nI)
                             If cCampo == "QP7_PRODUT"
                                QP7->QP7_PRODUT := cProdut
                             ElseIf cCampo == "QP7_REVI"
                                    QP7->QP7_REVI := cRevNew
                             ElseIf cCampo == "QP7_CODREC"
                                    QP7->QP7_CODREC := cRotNew
                             Else
                                FieldPut(nI,aDados[nI])
                             Endif
                         Next
                         lRet := .t. //Flag para indicar que houve duplicacao de arquivo.
                      MsUnLock()
                      dbSelectArea("QP7")
                      dbGoTo(nRecQP7)
                      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                      //³ Atualiza QQH - Gravacao A partir do QP7 - Não aplicado a BRASILUX ³
                      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

                      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                      //³ Atualiza QQ1 - Instrumentos do Produto A partir do QP7 - Não aplicado a BRASILUX ³
                      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

                      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                      //³ Atualiza QP9 - Gravacao A partir do QP7 - Não aplicado a BRASILUX ³
                      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                      dbSelectArea("QP7")
                      dbGoTo(nRecQP7)
                      dbSkip()
                EndDo
                
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Atualiza QP8 - Gravacao										 ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                dbSelectArea("QP8")
                dbSetOrder(1)
                dbSeek(xFilial("QP8")+cProdut+cRevAtu+cRotAtu+SG2->G2_OPERAC)
                While !QP8->(Eof()) .and. xFilial("QP8") == QP8->QP8_FILIAL .and. QP8->QP8_PRODUT == cProdut .and. QP8->QP8_REVI == cRevAtu .and. QP8->QP8_CODREC == cRotAtu .and. QP8->QP8_OPERAC == SG2->G2_OPERAC
                      aDados  := {}
                      nRecQP8 := Recno()
                      nRec    := Recno()
                      For nI := 1 To FCount()
                          aAdd(aDados,FieldGet(nI))
                      Next
                      RecLock("QP8",.T.)
                         For nI := 1 To FCount()
                             cCampo := FieldName(nI)
                             If cCampo == "QP8_PRODUT"
                                QP8->QP8_PRODUT := cProdut
                             ElseIf cCampo == "QP8_REVI"
                                    QP8->QP8_REVI := cRevNew
                             ElseIf cCampo == "QP8_CODREC"
                                    QP8->QP8_CODREC := cRotNew
                             Else
                                FieldPut(nI,aDados[nI])
                             Endif
                         Next
                         lRet := .t. //Flag para indicar que houve duplicacao de arquivo.
                      MsUnLock()
                      dbSelectArea("QP8")
                      dbGoTo(nRecQP8)
  
                      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                      //³ Atualiza QQH - Gravacao A partir do QP8 - Não aplicado a BRASILUX ³
                      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

                      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                      //³ Atualiza QQ1 - Instrumentos do Produto - A partir do QP8 - Não aplicado a BRASILUX ³
                      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

                      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                      //³ Atualiza QP9 - Gravacao	A partir do QP8 - Não aplicado a BRASILUX ³
                      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                      dbSelectArea("QP8")
                      dbGoTo(nRecQP8)
                      dbSkip()
                EndDo
                dbSelectArea("SG2")
                aDados := {}
                nRec   := Recno()
                RecLock("SG2",.f.)
                   SG2->G2_REVIPRD := cRevNew
                   SG2->G2_CHAVE   := cKeyNewH
                   cKeyNewH        := ""
                   lRet            := .T. //Flag para indicar que houve duplicacao de arquivo.
                MsUnLock()
                dbSelectArea("SG2")
                dbGoTo(nRec)
                dbSkip()
          Enddo
       Endif
       QP6->(dbSetOrder(1))
       If QP6->(dbSeek(xFilial("QP6")+cProdut+Inverte(cRevNew)))
          RecLock("QP6",.F.)
             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³ Grava a data de vigencia da nova revisao da especificacao				  ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             QP6->QP6_DTINI := dVigRev+IF(dVigRev==dDataBase,0,1)
             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³ Inicializa o campo "ALTESP" em branco									  ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             If lExisAlEsp
                QP6->QP6_ALTESP := ""
             EndIf
          MsUnLock()
       EndIf
Return(lRet)

/************************************************************************************************/
/*** VALPERG - Validação das perguntas para o relatório                                       ***/
/************************************************************************************************/
Static Function ValPerg()
       Local _sAlias := Alias()
       Local aRegs := {}
       Local i,j

       dbSelectArea("SX1")
       dbSetOrder(1)
       cPerg := PADR(cPerg,10)
       
       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs,{cPerg, "01", "Manutenção / Duplica ?", "", "", "mv_ch1", "N", 01, 0, 0, "C", "", "mv_par01", "Manutenção", "", "", "", "", "Duplica", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , ""})
       aAdd(aRegs,{cPerg, "02", "Produto"               , "", "", "mv_ch2", "C", 15, 0, 0, "G", "", "mv_par02", ""          , "", "", "", "", ""       , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "QP6", ""})
       For i:=1 to Len(aRegs)
           If !dbSeek(cPerg+aRegs[i,2])
              RecLock("SX1",.T.)
              For j:=1 to FCount()
                  If j <= Len(aRegs[i])
                     FieldPut(j,aRegs[i,j])
                 Endif
              Next
              MsUnlock()
           Endif
       Next

       dbSelectArea(_sAlias)
Return