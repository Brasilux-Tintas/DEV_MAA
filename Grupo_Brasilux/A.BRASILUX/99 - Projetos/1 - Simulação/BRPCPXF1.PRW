#include "rwmake.ch"
#include "topconn.ch"                                                                 
#include "colors.ch"
#include "font.ch"
#include "brpcpx01.ch"
#include "dbtree.ch"
#define DS_MODALFRAME            128  // 0x80
#define WS_POPUP          2147483648  // 0x80000000L
#define WS_CAPTION          12582912  // 0x00C00000L
#define WS_VISIBLE         268435456  // 0x10000000L
#xtranslate bSETGET(<uVar>) => { | u | If( PCount() == 0, <uVar>, <uVar> := u ) }

User Function PCPX01_4(cAlias, nRecno, nOpcx)
     Local cCadastro := "Estrutura Completa do Produto - "+SZM->ZM_CODIGO
     Local cCodAtual := SZM->ZM_CODIGO
     Local cCodSim   := SZM->ZM_CODIGO
     Local cRevisao  := SZM->ZM_REVISAO
     Local oDlg, oTree
     Private lDbTree := .T.
     Private nNivel  := 1

     nOrder := IndexOrd()
     cAlias := Alias()
     nRecNo := RecNo()

     DEFINE MSDIALOG oDlg TITLE cCadastro From 6,0 to 28,100 of oMainWnd
     DEFINE FONT oFont SIZE 8,0 BOLD

            oTree := DbTree():New(010,010,150,383,oDlg,,,.T.)
            @ 152,355 BMPBUTTON TYPE 1 ACTION oDlg:End()

     ACTIVATE MSDIALOG oDlg ON INIT EST021D01(oTree, oDlg, cCodAtual, cCodSim, cRevisao, nOpcx,,,"N") CENTERED

     DbSelectArea(cAlias)
     DbSetOrder(nOrder)
     DbGoTo(nRecNo)
     If lFiltro
        U_PCPX01_6(1)
     Endif
Return

/*/
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ EST021D01³ Luís Gustavo de Souza         ³ Data ³20.09.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Rotina de montagem da arvore da estrutura de produtos.       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
/*/
Static Function EST021D01(oTree, oDlg, cCodigo, cCodSim, cRevisao, nOpcx, cCargo, cTRTPai, cTpCall)
       Local cComp     := ''
       Local cPrompt   := ''
       Local cFOLDERA  := 'FOLDER5'
       Local cFOLDERB  := 'FOLDER6'
       Local nRecAnt   := 0
       //Local nRecCargo := 0
       Local cTRTAux   := 0
       Private nEstru  := 0
       nOpcx := Iif(nOpcx==Nil, 0, nOpcx)

      If !lDbTree
         oDlg:SetFocus()
         Return .F.
      Endif

       cTRTPai := Iif(cTRTPai == Nil,'000', cTRTPai)
       cPrompt := cTRTPai+" · "+cCodigo+SubStr(SZM->ZM_DESCRIC,1,30)+Iif(cTpCall == "N", "   · ", " · ")+TransForm(Iif(cTpCall=="R", SZN->ZN_PERC, fSomPer(cCodigo, cRevisao)),"@E 999.999 %")

       If cCargo = Nil
          cCargo := cTRTPai+SZM->ZM_CODIGO+SZM->ZM_DESCRIC+StrZero(SZN->(RecNo()),9)+'CODI'
       Endif
       cFolderA := 'FOLDER5'
       cFolderB := 'FOLDER6'

       DbADDTree oTree PROMPT cPrompt OPENED RESOURCE cFolderA, cFolderB CARGO cCargo
       DbSelectArea("SZN")
       DbSetOrder(2)
       DbSeek(xFilial("SZN")+cCodigo+cRevisao,.t.)
       If Found()
          While !Eof() .and. SZN->ZN_CODIGO == cCodigo .and. SZN->ZN_REVISAO == cRevisao
                nRecAnt  := SZN->(RecNo())
                cComp    := SZN->ZN_COMP
                cCargo   := SZN->ZN_TRT+SZN->ZN_COMP+Posicione("SB1", 1, xFilial("SZN")+cComp, "SB1->B1_DESC")+StrZero(SZN->(RecNo()),9)+'COMP'

                cFolderA := 'FOLDER5'
                cFolderB := 'FOLDER6'

                cPrompt  := SZN->ZN_TRT+" · "+cComp+SubStr(Posicione("SB1", 1, xFilial("SZN")+cComp, "SB1->B1_DESC"),1,30)+" · "+TransForm(SZN->ZN_PERC,"@E 999.999 %")
                cTRTAux := SZN->ZN_TRT

                If SZN->(DbSeek(xFilial("SZN")+SZN->ZN_COMP,.f.))
                   nNivel += 1
                   //LGS#20200210 - Adequação de release 12.1.25 e posteriores
                   //EST021D01(oTree, oDlg, SZN->ZN_CODIGO, '', fUltRev(SZN->ZN_CODIGO), nOpcx, cCargo, cTRTAux, "R", nNivel )
                   EST021D01(oTree, oDlg, SZN->ZN_CODIGO, '', fUltRev(SZN->ZN_CODIGO), nOpcx, cCargo, cTRTAux, "R" )
                Else
                   DbADDItem oTree PROMPT cPrompt RESOURCE cFolderA CARGO cCargo
                Endif

                SZN->(DbGoTo(nRecAnt))
                SZN->(DbSkip())
          Enddo
       EndIf
       DbENDTree oTree

       oFont1 := TFont():New("Courier New"        ,9,12,.F.,.T.,5,.T.,5,.F.,.F.)
       oTree:oFont := oFont1

       If lDbTree
          oTree:Refresh()
          oTree:SetFocus()
       Else
          oDlg:SetFocus()
       Endif
Return .t.

/*/
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fUltRev  ³ Luís Gustavo de Souza         ³ Data ³20.09.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Busca a ultima revisão dos sub-itens.                        ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
/*/
Static Function fUltRev(cCodigo)
       nOrder := IndexOrd()
       cAlias := Alias()
       nRecNo := RecNo()

       DbSelectArea("SZM")
       DbSetOrder(3)
       DbSeek(xFilial("SZM")+cCodigo,.t.)
       If Found()
          cRevisao := SZM->ZM_REVISAO
       Else
          cRevisao := '001'
       Endif

       DbSelectArea(cAlias)
       DbSetOrder(nOrder)
       DbGoTo(nRecNo)
Return(cRevisao)

/*/
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fSomPer  ³ Luís Gustavo de Souza         ³ Data ³20.09.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Busca os valores dos percentuais.                            ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
/*/
Static Function fSomPer(cCodigo, cRevisao)
       Local nValPerc := 0

       nOrder := IndexOrd()
       cAlias := Alias()
       nRecNo := RecNo()

       DbSelectArea("SZN")
       DbSetOrder(2)
       DbSeek(xFilial("SZN")+cCodigo+cRevisao,.t.)
       If Found()
          While !Eof() .and. SZN->ZN_CODIGO == cCodigo .and. SZN->ZN_REVISAO == cRevisao
                // produto de custeio
                If U_IsProdCusto(SZN->ZN_COMP)
                     SZN->(dbSkip())
                     Loop
                Endif   

                nValPerc += SZN->ZN_PERC
                DbSelectArea("SZN")
                DbSkip()
          Enddo
       Else
          nValPerc := 0
       Endif

       DbSelectArea(cAlias)
       DbSetOrder(nOrder)
       DbGoTo(nRecNo)

Return nValPerc

User Function fMonOpe(nOpc, cCodigo, cRevisao, cDescri, aHeaderA, aColsA)
     Local   cRoteiro := Iif(Empty(Posicione("SB1", 1, xFilial("SB1")+cCodigo, "B1_OPERPAD")), '01', Posicione("SB1", 1, xFilial("SB1")+cCodigo, "B1_OPERPAD"))
     Local   nCnt     := 0
     Local   cVarTemp
     Local   nOpcA    := 0
     Local   nOpcX    := Iif(nOpc == 1, 2, 3)
     Local   lExiSG2  := .t.
     Local   cLinhaOk := Iif(nOpc == 1, "AllWaysTrue()", "U_fVlLOpe()")
     Local   cTudoOOk := Iif(nOpc == 1, "AllWaysTrue()", "U_fVlTOpe()")
     Local _lOpen        := .F. //LGS#20200210 - Adequação para release 12.1.25
     Local _cAliasSX3 := GetNextAlias() //LGS#20200210 - Adequação para release 12.1.25
     Private lAps     := .f.
     Private aSize    := {}
     Private aInfo    := {}
     Private aObjects := {}
     Private aPosObj  := {}
     Private nPosOper
     Private nUsado   := 0
     Private aCols    := {}
     Private aHeader[0]
     Private aHeadRec := {}
     Private aColsRec := {}
     Private nMaxArray
     Private lPrim    := .T.
     Private aHeadFer := {}
     Private aColsFer := {}
     Private lPadrao  := .F.
     Private c630Cod  := cRoteiro
     Private c630Prod := cCodigo

     // ABERTURA DO DICIONÁRIO SX3 - LGS#20200210 - Adequação para release 12.1.25
     OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
     _lOpen := Select( _cAliasSX3 ) > 0
     If !_lOpen //LGS#20200210 - Adequação para release 12.1.25
        MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
        Return
     Endif

     AADD(aObjects,{100,020,.T.,.F.,.F.}) // Indica dimensoes x e y e indica que redimensiona x e y e assume que retorno sera em linha final coluna final (.F.)
     AADD(aObjects,{100,100,.T.,.T.,.F.}) // Indica dimensoes x e y e indica que redimensiona x e y
     aSize:=MsAdvSize()
     aInfo:={aSize[1],aSize[2],aSize[3],aSize[4],3,3}
     aPosObj:=MsObjSize(aInfo,aObjects)
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Verifica se existe algum dado no arquivo 				     ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     dbSelectArea("SG2")
     dbSetOrder(1)
     dbSeek(xFilial("SG2")+cCodigo+cRoteiro)
     If !Found()
        lExiSG2 := .f.
     Endif
     nSavRec  := Recno()
     aSavLock := {}
     While !Eof() .and. G2_FILIAL+G2_PRODUTO+G2_CODIGO == xFilial("SG2")+cCodigo+cRoteiro
           AADD(aSavLock,Recno())
           SoftLock("SG2")
           nCnt++
           dbSkip()
     End
     dbGoTo(nSavRec)
     bCampo := {|nCPO| Field(nCPO) }
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Salva a integridade dos campos de Bancos de Dados 		     ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     DbSelectArea("SX2")
     DbSetOrder(1)
     DbSeek("SG2")
     /********************************************************************************************************************************/
     /*** BLOCO ALTERADO EM 10/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
     /*DbSelectArea("SX3")
     DbSetOrder(1)
     DbSeek("SG2")
     While !Eof() .And. (X3_ARQUIVO == "SG2")
           If X3USO(X3_USADO) .AND. cNivel >= X3_NIVEL .And. Trim(X3_CAMPO) != "G2_PRODUTO" 
              nUsado++
              If AllTrim(X3_CAMPO) == "G2_OPERAC"
                 nPosOper := nUsado
              EndIf
              Aadd(aHeader,{ TRIM(( _cAliasSX3 )->( X3_TITULO )), X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )
           EndIf
           DbSkip()
     EndDo*/
     DbSelectArea( _cAliasSX3 )
     ( _cAliasSX3 )->( DbSetOrder(1) )
     ( _cAliasSX3 )->( DbSeek("SG2") )
     While !Eof() .And. ( ( _cAliasSX3 )->( X3_ARQUIVO ) == "SG2")
           If X3USO( ( _cAliasSX3 )->( X3_USADO ) ) .AND. cNivel >= ( _cAliasSX3 )->( X3_NIVEL ) .And. Trim( ( _cAliasSX3 )->( X3_CAMPO )) != "G2_PRODUTO" 
              nUsado++
              If AllTrim( ( _cAliasSX3 )->( X3_CAMPO ) ) == "G2_OPERAC"
                 nPosOper := nUsado
              EndIf
              Aadd(aHeader,{ ( _cAliasSX3 )->( X3_Titulo ), ( _cAliasSX3 )->( X3_CAMPO ), ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), ( _cAliasSX3 )->( X3_VALID ), ( _cAliasSX3 )->( X3_USADO ), ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_ARQUIVO ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
           EndIf
           DbSkip()
     EndDo
     /********************************************************************************************************************************/
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Carrega aCols com dados de SG2							     ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     DbSelectArea("SG2")
     DbSetOrder(1)
     nSavRec   := Recno()
     nCnt      := 0
     cReviBack := ""
     If lExiSG2
        While !Eof() .and. G2_FILIAL+G2_PRODUTO+G2_CODIGO == xFilial("SG2")+cCodigo+cRoteiro
              aadd(aCols, {})
              /********************************************************************************************************************************/
              /*** BLOCO ALTERADO EM 10/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
              /*DbSelectArea("SX3")
              DbSeek("SG2")
              nCnt++
              While !Eof() .And. (X3_ARQUIVO == "SG2")
                    If X3USO(X3_USADO).AND. cNivel >= X3_NIVEL .And. Trim(X3_CAMPO) != "G2_PRODUTO" .And. Trim(X3_CAMPO) != "G2_CODIGO" 
                       cVarTemp := "SG2->"+(X3_CAMPO)
                       If X3_CONTEXT # "V"
                          Aadd(aCols[nCnt],&cVarTemp)
                       ElseIF X3_CONTEXT == "V"
                              aadd(aCols[nCnt],CriaVar(AllTrim(X3_CAMPO)))
                       Endif
                    Endif
                    DbSkip()
              EndDo*/
              DbSelectArea( _cAliasSX3 )
              ( _cAliasSX3 )->( DbSeek("SG2") )
              nCnt++
              While !Eof() .And. ( ( _cAliasSX3 )->( X3_ARQUIVO ) == "SG2" )
                    If X3USO( ( _cAliasSX3 )->( X3_USADO ) ) .AND. cNivel >= ( _cAliasSX3 )->( X3_NIVEL ) .And. Trim( ( _cAliasSX3 )->( X3_CAMPO ) ) != "G2_PRODUTO" .And. Trim( ( _cAliasSX3 )->( X3_CAMPO ) ) != "G2_CODIGO" 
                       cVarTemp := "SG2->"+( ( _cAliasSX3 )->( X3_CAMPO ) )
                       If ( _cAliasSX3 )->( X3_CONTEXT ) # "V"
                          Aadd(aCols[nCnt],&cVarTemp)
                       ElseIF ( _cAliasSX3 )->( X3_CONTEXT ) == "V"
                              aadd( aCols[nCnt], CriaVar( AllTrim( ( _cAliasSX3 )->( X3_CAMPO ) ) ) )
                       Endif
                    Endif
                    DbSkip()
              EndDo
              /********************************************************************************************************************************/
              aadd(aCols[nCnt],.F.)
              DbSelectArea("SG2")
              DbSkip()
        EndDo
     Else
        AADD(aCols,{})
        /********************************************************************************************************************************/
        /*** BLOCO ALTERADO EM 10/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
        /*DbSelectArea("SX3")
        DbSeek("SG2")
        nUsado:=0
        While !Eof() .And. (X3_ARQUIVO == "SG2")
              If X3USO(X3_USADO) .AND. cNivel >= X3_NIVEL .And. Trim(X3_CAMPO) != "G2_PRODUTO" .And. Trim(X3_CAMPO) != "G2_CODIGO" 
                 nUsado++
                 AADD(aCols[1],{})
                 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                 //³ Monta Array de 1 elemento ³
                 //³ vazio. Se inclus†o. 		³
                 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                 If X3_TIPO == "C"
                    If Trim(X3_CAMPO) == "G2_OPERAC"
                       aCols[1][nUsado] := "01"
                    Else
                       aCols[1][nUsado] := SPACE(X3_TAMANHO)
                    EndIF
                 ElseIf X3_TIPO == "N"
                        aCols[1][nUsado] := 0
                 ElseIf x3_tipo == "D"
                        aCols[1][nUsado] := dDataBase
                 ElseIf x3_tipo == "M"
                        aCols[1][nUsado] := ""
                 Else
                    aCOLS[1][nUsado] := .F.
                 Endif
              Endif
              If x3_context == "V"
                 aCOLS[1][nUsado] := CriaVar(Alltrim(x3_campo))
              Endif
              dbSkip()
        EndDo*/
        DbSelectArea( _cAliasSX3 )
        ( _cAliasSX3 )->( DbSeek("SG2") )
        nUsado:=0
        While !Eof() .And. ( ( _cAliasSX3 )->( X3_ARQUIVO ) == "SG2")
              If X3USO( ( _cAliasSX3 )->( X3_USADO ) ) .AND. cNivel >= ( _cAliasSX3 )->( X3_NIVEL ) .And. Trim( ( _cAliasSX3 )->( X3_CAMPO ) ) != "G2_PRODUTO" .And. Trim( ( _cAliasSX3 )->( X3_CAMPO ) ) != "G2_CODIGO" 
                 nUsado++
                 AADD(aCols[1],{})
                 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                 //³ Monta Array de 1 elemento ³
                 //³ vazio. Se inclus†o. 		³
                 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                 If ( _cAliasSX3 )->( X3_TIPO ) == "C"
                    If Trim( ( _cAliasSX3 )->( X3_CAMPO ) ) == "G2_OPERAC"
                       aCols[1][nUsado] := "01"
                    Else
                       aCols[1][nUsado] := SPACE( ( _cAliasSX3 )->( X3_TAMANHO ) )
                    EndIF
                 ElseIf ( _cAliasSX3 )->( X3_TIPO ) == "N"
                        aCols[1][nUsado] := 0
                 ElseIf ( _cAliasSX3 )->( X3_TIPO ) == "D"
                        aCols[1][nUsado] := dDataBase
                 ElseIf ( _cAliasSX3 )->( X3_TIPO ) == "M"
                        aCols[1][nUsado] := ""
                 Else
                    aCOLS[1][nUsado] := .F.
                 Endif
              Endif
              If ( _cAliasSX3 )->( X3_CONTEXT ) == "V"
                 aCOLS[1][nUsado] := CriaVar( Alltrim( ( _cAliasSX3 )->( x3_campo ) ) )
              Endif
              dbSkip()
        EndDo
        /********************************************************************************************************************************/
        AADD(aCols[1],{})
        aCOLS[1][nUsado+1] := .F.
     Endif
     DbGoTo(nSavRec)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Monta aColsRec e aColsFer.								  ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     A630NewaCols()

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Monta aHeadRec e aHeadFer.								  ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     /********************************************************************************************************************************/
     /*** BLOCO ALTERADO EM 10/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
     /*DbSelectArea("SX3")
     DbSetOrder(1)
     DbSeek("SH3")
     While !Eof() .And. (X3_ARQUIVO == "SH3")
           If X3USO(X3_USADO) .And. cNivel >= X3_NIVEL .And. ( Trim(X3_CAMPO) == "H3_RECALTE" .Or. Trim(X3_CAMPO) == "H3_DESC" .Or. Trim(X3_CAMPO) == "H3_TIPO" .Or. Trim(X3_CAMPO) == "H3_EFICIEN" )
              aadd(aHeadRec,{ Trim(( _cAliasSX3 )->( X3_TITULO )), X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )
           ElseIf X3USO(X3_USADO) .And. cNivel >= X3_NIVEL .And. ( Trim(X3_CAMPO) == "H3_FERRAM" .Or. Trim(X3_CAMPO) == "H3_DESCFER" )
                  aadd(aHeadFer,{ Trim(( _cAliasSX3 )->( X3_TITULO )), X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )
           EndIf
           DbSkip()
     EndDo*/
     DbSelectArea( _cAliasSX3 )
     ( _cAliasSX3 )->( DbSetOrder(1) )
     ( _cAliasSX3 )->( DbSeek("SH3") )
     While !Eof() .And. ( ( _cAliasSX3 )->( X3_ARQUIVO ) == "SH3")
           If X3USO( ( _cAliasSX3 )->( X3_USADO ) ) .And. cNivel >= ( _cAliasSX3 )->( X3_NIVEL ) .And. ( Trim( ( _cAliasSX3 )->( X3_CAMPO ) ) == "H3_RECALTE" .Or. Trim( ( _cAliasSX3 )->( X3_CAMPO ) ) == "H3_DESC" .Or. Trim( ( _cAliasSX3 )->( X3_CAMPO ) ) == "H3_TIPO" .Or. Trim( ( _cAliasSX3 )->( X3_CAMPO )) == "H3_EFICIEN" )
              aadd( aHeadRec,{ ( _cAliasSX3 )->( X3_Titulo ), ( _cAliasSX3 )->( X3_CAMPO ), ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), ( _cAliasSX3 )->( X3_VALID ), ( _cAliasSX3 )->( X3_USADO ), ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_ARQUIVO ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
           ElseIf X3USO( ( _cAliasSX3 )->( X3_USADO ) ) .And. cNivel >= ( _cAliasSX3 )->( X3_NIVEL ) .And. ( Trim( ( _cAliasSX3 )->( X3_CAMPO ) ) == "H3_FERRAM" .Or. Trim( ( _cAliasSX3 )->( X3_CAMPO ) ) == "H3_DESCFER" )
                  aadd( aHeadFer,{ ( _cAliasSX3 )->( X3_Titulo ), ( _cAliasSX3 )->( X3_CAMPO ), ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), ( _cAliasSX3 )->( X3_VALID ), ( _cAliasSX3 )->( X3_USADO ), ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_ARQUIVO ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
           EndIf
           DbSkip()
     EndDo
     /********************************************************************************************************************************/
     DbSelectArea("SG2")
     DbSetOrder(1)

     DEFINE MSDIALOG oDlg1 TITLE OemToAnsi("Roteiro de Opera‡”es") PIXEL FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd
            //@ aPosObj[1,1],aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,4]                   PIXEL
            @ 11,007 SAY OemToAnsi("Roteiro")                     SIZE 020,07          PIXEL OF oDlg1
            @ 10,030 MSGET cRoteiro PICTURE "@!"                  SIZE 015,10 WHEN .F. PIXEL OF oDlg1
            @ 11,055 SAY OemToAnsi("Produto")                     SIZE 020,07          PIXEL OF oDlg1
            @ 10,080 MSGET cCodigo  PICTURE "@R! XXX99.99.999.99" SIZE 050,10 WHEN .F. PIXEL OF oDlg1
            @ 11,140 SAY OemToAnsi("Revisão")                     SIZE 020,07          PIXEL OF oDlg1
            @ 10,165 MSGET cRevisao PICTURE "999"                 SIZE 015,10 WHEN .F. PIXEL OF oDlg1
            @ 11,195 SAY OemToAnsi("Descrição")                   SIZE 025,07          PIXEL OF oDlg1
            @ 10,225 MSGET cDescri  PICTURE "@!"                  SIZE 100,10 WHEN .F. PIXEL OF oDlg1

            oGetO := MSGetDados():New(aPosObj[2][1], aPosObj[2][2], aPosObj[2][3], aPosObj[2][4], nOpcx, cLinhaOk, cTudoOOk, "", (nOpcx <> 2),,,, 300)

            oDlg1:nStyle := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
     If nOpc == 1
        ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1, {|| nOpca := 0,  oDlg1:End() }, {|| oDlg1:End() } )
     Else
        ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1, {|| nOpca := 1, If(oGetO:TudoOk(), oDlg1:End(), nOpca := 0)}, {|| oDlg1:End() } )
     Endif
     If nOpcA == 1
        Begin Transaction
              A630Grava("SG2")
        End Transaction
     Endif
     aCols   := aColsA
     aHeader := aHeaderA
     n       := 1
     DbSelectArea( _cAliasSX3 )
     DbCloseArea()
Return Nil

User Function fVlLOpe(o)
     Local nx, lRet := .T., cNewCod, z, x
     Local nTempDes := 0,nTipoDes := 0, nTempSobre := 0, nTipoSobre := 0
     //Local nDesProp := 0
     //Local nPosOper := Ascan(aHeader, { |x| alltrim(x[2]) == "G2_OPERAC" })

     For nx = 1 To Len(aHeader)
         If Trim(aHeader[nx][2]) == "G2_TEMPDES"
            nTempDes := nx
         ElseIf Trim(aHeader[nx][2]) == "G2_TPDESD"
                nTipoDes:=nx
         ElseIf Trim(aHeader[nx][2]) == "G2_TPSOBRE"
                nTipoSobre:=nx
         ElseIf Trim(aHeader[nx][2]) == "G2_TEMPSOB"
                nTempSobre:=nx
         EndIf
     Next nx

     For nx = 1 To Len(aHeader)
         If Empty(aCols[n][nx]) .And. !(aCols[n][Len(aHeader)+1])
            If Trim(aHeader[nx][2]) == "G2_OPERAC" .And. n == Len(aCols)
               Exit
            EndIf
            If Trim(aHeader[nx][2]) == "G2_TEMPAD"
               Help(" ",1,"A630SEMTMP")
               lRet := .F.
               Exit
            EndIf
            If Trim(aHeader[nx][2]) == "G2_OPERAC"  .OR.;
               (Trim(aHeader[nx][2]) == "G2_RECURSO" .And. ! lAPS)
               Help(" ",1,"A630VZ")
               lRet := .F.
               Exit
            EndIf
            If Trim(aHeader[nx][2]) == "G2_TEMPSOB"
               If nTipoSobre > 0
                  If !Empty(aCols[n][nTipoSobre])
                     Help(" ",1,"A630TIPSOB")
                     lRet := .F.
                  EndIf
               EndIf
            EndIf
            If Trim(aHeader[nx][2]) == "G2_TPSOBRE"
               If nTempSobre > 0
                  If !Empty(aCols[n][nTempSobre])
                     Help(" ",1,"A630TMPSOB")
                     lRet := .F.
                  EndIf
               EndIf
            EndIf
            If Trim(aHeader[nx][2]) == "G2_TEMPDES"
               If nTipoDes > 0
                  If !Empty(aCols[n][nTipoDes])
                     Help(" ",1,"A630TIPDES")
                     lRet := .F.
                  EndIf
               EndIf
            EndIf
            If Trim(aHeader[nx][2]) == "G2_TPDESD"
               If nTempDes > 0
                  If !Empty(aCols[n][nTempDes])
                     Help(" ",1,"A630TMPDES")
                     lRet := .F.
                  EndIf
               EndIf
            EndIf
         ElseIf !(aCols[n][Len(aHeader)+1])
                If Trim(aHeader[nx][2]) == "G2_OPERAC"
                   cNewCod  := aCols[n][nx]
                   z        := Len(aCols[n])
                   lDeleted := aCols[n][z]
                   If !lDeleted
                      For x := 1 to Len(aCols)
                          If aCols[x][nx] == cNewCod .And. n != x .And. aCols[x][z] == .F.
                             Help(" ",1,"A630OPERJA")
                             lRet := .F.
                             Exit
                          EndIf
                      Next x
                   EndIf
                EndIf
         EndIf
     Next nx
     If lRet .And. lAps
        lRet := A630DoGrupo(.T.)
     Endif
Return lRet

User Function fVlTOpe(o)
     Local   nx , lRet := .T.
     //Local ny
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ verifica se o ultimo elemento do array esta em branco	     ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     nMaxArray := Len(aCols)
     For nx = 1 to Len(aHeader)
         If Empty(aCols[nMaxArray][nx])
            If Trim(aHeader[nx][2]) == "G2_OPERAC"  .Or.;
               (! lAps .And. Trim(aHeader[nx][2]) == "G2_RECURSO")
               nMaxArray--
               Exit
            EndIf
         EndIf
     Next nx

     If nMaxArray <= 0
        Continua := .T.
     EndIf
Return lRet

User Function PCPX01_5(cPesq)
     Local oDlg
     Local cNome     := "" ; Local oNome
     Local cTextMemo := "" ; Local oTextMemo
     Local cSZT            ; Local oSZT
     Local cProdRev  := "" ; Local oProdRev
     Local cQuery    := ""
     Local aLog      := {}

     If cPesq $ "SI"
        DbSelectArea("SZT")
        DbSetOrder(1)
        DbSeek(xFilial("SZT")+SZM->ZM_ID,.t.)
        cId := SZM->ZM_ID
     Endif
     If Found()
        cQuery := ""
        cQuery += "SELECT SZT.ZT_ID, SZT.ZT_PROCESS, SZT.ZT_STATUS, SZT.ZT_USUARIO, SZT.R_E_C_N_O_, SZT.ZT_LOG, "
        cQuery += "       SUBSTRING(SZT.ZT_DATAGER,7,2)+'/'+SUBSTRING(SZT.ZT_DATAGER,5,2)+'/'+SUBSTRING(SZT.ZT_DATAGER,1,4)+' '+SZT.ZT_HORAGER AS ZT_GERACAO, SZT.ZT_SEQ "
        cQuery += "FROM "+RetSqlName("SZT")+" SZT WITH (NOLOCK) "
        cQuery += "WHERE SZT.D_E_L_E_T_ = '' "
        cQuery += "  AND SZT.ZT_ID = '"+cId+"' "
        cQuery += "ORDER BY SZT.R_E_C_N_O_ "
        TCQuery cQuery ALIAS "QSZT" NEW
        //cQuery := ChangeQuery(cQuery)
        //dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), "QSZT",.T.,.T.)
        DbSelectArea("QSZT")
        DbGoTop()
        While !Eof()
              If QSZT->ZT_PROCESS == "SO"
                 cProcess := "Solicitação"
              ElseIf QSZT->ZT_PROCESS == "SI"
                     cProcess := "Simulação"
              Else
                 cProcess := "Inclusão"
              Endif
              If QSZT->ZT_STATUS == "PA"
                 cStatus := "Solicitação Pendente"
              ElseIf QSZT->ZT_STATUS == "PR"
                     cStatus := "Solicitação em Simulação"
              ElseIf QSZT->ZT_STATUS == "EN"
                     cStatus := "Solicitação Encerrada"
              ElseIf QSZT->ZT_STATUS == "NP"
                     cStatus := "Solicitação não procede"
              ElseIf QSZT->ZT_STATUS == "EE"
                     cStatus := "Produto em elaboração"
              ElseIf QSZT->ZT_STATUS == "PP"
                     cStatus := "Análise pelo PCP"
              ElseIf QSZT->ZT_STATUS == "EA"
                     cStatus := "Análise pela Diretoria"
              ElseIf QSZT->ZT_STATUS == "OD"
                     cStatus := "Observação Diretoria"//QSZT->ZT_LOG
              ElseIf QSZT->ZT_STATUS == "AC"
                     cStatus := "Aceito"
              ElseIf QSZT->ZT_STATUS == "RE"
                     cStatus := "Rejeitado"
              ElseIf QSZT->ZT_STATUS == "DE"
                     cStatus := "Devolvido"
              Else
                 cStatus := ""
              Endif
              aadd(aLog, { QSZT->ZT_ID, cProcess, cStatus, QSZT->ZT_GERACAO, QSZT->R_E_C_N_O_, QSZT->ZT_PROCESS, QSZT->ZT_STATUS, QSZT->ZT_SEQ } )
              DbSelectArea("QSZT")
              DbSkip()
        Enddo
        aSort( aLog,,,{ |x,y| x[1] + x[8] + x[4] < y[1] + y[8] + y[4]} )
        DbSelectArea("QSZT")
        DbCloseArea()
     Else
        MsgBox("Não foram encontradas informações !!!","Informação","INFO")
        If lFiltro
           U_PCPX01_6(1)
        Endif
        Return
     Endif
     DEFINE MSDIALOG oDlg TITLE OemToAnsi( "Histórico de Pendências" ) FROM 000,000 TO 020, 080 OF oMainWnd
            @ 012,001 TO 078,316  Title OemToAnsi( " Movimentos " )
            @ 018,003 LISTBOX oSZT VAR cSZT FIELDS HEADER "ID. Processo", "Processo", "Status", "Geração" SIZE 310,056 OF oDlg PIXEL ON CHANGE fAtuHis( oSZT:nAt, aLog, @oTextMemo, @cTextMemo, @oNome, @cNome, @oProdRev, @cProdRev)
            @ 081,003 SAY OemToAnsi("Responsável")         SIZE 045,009 PIXEL OF oDlg
            @ 080,050 MSGET oNome VAR cNome       WHEN .f. SIZE 060,009 PIXEL OF oDlg
            @ 094,003 SAY OemToAnsi("Produto/Revisão" )    SIZE 045,009 PIXEL OF oDlg
            @ 095,050 MSGET oProdRev VAR cProdRev WHEN .f. SIZE 060,009 PIXEL OF oDlg
            
            @ 080,112 TO 150, 316 Title OemToAnsi( "Motivo / Justificativa" )
            @ 086,114 GET cTextMemo MEMO WHEN  .f.     SIZE 198,060 Object oTextMemo
            

            bSZTLine1 := { || { aLog[oSZT:nAt,1], aLog[oSZT:nAt,2], aLog[oSZT:nAt,3], aLog[oSZT:nAt,4] } }

            oSZT:SetArray( aLog )
            oSZT:bLine    := bSZTLine1
            oSZT:GoTop()
            oDlg:nStyle := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
     //ACTIVATE MSDIALOG oDlg CENTERED ON INIT fHisOpc( oDlg, {|| oDlg:End() }, {|| oDlg:End() }, .f., oSZT:Refresh(), oSZT:SetFocus(.T.), fAtuHis( oSZT:nAt, aLog, @oTextMemo, @cTextMemo, @oNome, @cNome, @oProdRev, @cProdRev) )
     ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( fHisOpc( oDlg, {|| oDlg:End() }, {|| oDlg:End() }, .f.), oSZT:Refresh(), oSZT:SetFocus(.T.), fAtuHis( oSZT:nAt, aLog, @oTextMemo, @cTextMemo, @oNome, @cNome, @oProdRev, @cProdRev) )

     If lFiltro
        U_PCPX01_6(1)
     Endif
Return

Static Function fHisOpc(oDlg, bOk, bCancel, lEntr)
       Private oBar
       //DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlg
       oBar := FWButtonBar():New()
       oBar:Init(oDlg, 025, 025, CONTROL_ALIGN_TOP, .t., .f. )
       If lEntr
          DEFINE BUTTON oBtOk  RESOURCE "PENDENTE" OF oBar GROUP ACTION fLegEnt() TOOLTIP OemToAnsi("Legenda...")
       Endif
       DEFINE BUTTON oBtOk  RESOURCE "S4WB018N" OF oBar GROUP ACTION oDlg:End() TOOLTIP OemToAnsi("Sair...")
       oBar:bRClicked := {|| AllwaysTrue()}
Return Nil

Static Function fAtuHis( nPos, aLog, oText, cText, oNome, cNome, oProdRev, cProdRev )
       cText := ""
       DbSelectArea("SZT")
       DbSetOrder(2)
       DbSeek(xFilial("SZT")+aLog[nPos,1]+aLog[nPos,6]+aLog[nPos,7],.t.)
       If Found()
          cNome := SZT->ZT_USUARIO
          cText := SZT->ZT_LOG
          If aLog[nPos,6] == "SO"
             If !aLog[nPos,7] $ "PA.EN"
                DbSelectArea("SZM")
                DbSetOrder(5)
                DbSeek(xFilial("SZM")+aLog[nPos,1]+aLog[nPos,8],.t.)
                If Found()
                   cProdRev := Alltrim(SZM->ZM_CODIGO) +" / "+Alltrim(SZM->ZM_REVISAO)
                Else
                   DbSelectArea("SZO")
                   DbSetOrder(1)
                   DbSeek(xFilial("SZO")+aLog[nPos,1],.t.)
                   If Found()
                      cProdRev := SZO->ZO_CODIGO
                   Else
                      cProdRev := ""
                   Endif
                Endif
             Else
                DbSelectArea("SZO")
                DbSetOrder(1)
                DbSeek(xFilial("SZO")+aLog[nPos,1],.t.)
                If Found()
                   cProdRev := SZO->ZO_CODIGO
                Else
                   cProdRev := ""
                Endif
             Endif
          Else
             DbSelectArea("SZM")
             nIndexOrd := IndexOrd()
             nRecno    := RecNo()
             DbSetOrder(5)
             DbGoTop()
             DbSeek(xFilial("SZM")+aLog[nPos,1]+SubStr(aLog[nPos,8], 1, 1), .t.)
             If Found()
                cProdRev := Alltrim(SZM->ZM_CODIGO) +" / "+Alltrim(SZM->ZM_REVISAO)
             Else
                cProdRev := ""
             Endif
             DbSetOrder(nIndexOrd)
             DbGoTo(nRecno)
          Endif
       Else
          cNome    := Space(30)
          cText    := Space(30)
          cProdRev := Space(25)
       Endif
       oNome:Refresh()
       oText:Refresh()
       oProdRev:Refresh()
Return Nil

User Function fMosPen()
     Local cQry1   := ""
     Local cCodUse := RetCodUsr()
     Local aCampos := {}
     //Local cNomArq 
     Local cStat   := ""
     Local cStat1  := ""
     Local cStat2  := ""
     Local cStat3  := ""
     Local aStat   := {}
     Private oLibEla  := LoadBitmap( GetResources(), "BR_VERMELHO")
     Private oLibPCP  := LoadBitmap( GetResources(), "BR_AMARELO")
     Private oLibDir  := LoadBitmap( GetResources(), "BR_AZUL")

     aadd(aCampos, { "TRB_COD", "C", 15, 0 } )
     aadd(aCampos, { "TRB_REV", "C", 03, 0 } )
     aadd(aCampos, { "TRB_DES", "C", 40, 0 } )
     aadd(aCampos, { "TRB_STA", "C", 02, 0 } )
     
     DbSelectArea("SZW")
     DbSetOrder(4)
     DbSeek(xFilial("SZW")+'BRPCPX01  '+cCodUse+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2), .t.)
     If Found()
        If SubStr(SZW->ZW_ACESSOS, 2, 1) == '*'
           cStat1 := "EE"
        Endif
        If SubStr(SZW->ZW_ACESSOS, 4, 1) == '*'
           cStat2 := "PP"
        Endif
        If SubStr(SZW->ZW_ACESSOS, 5, 1) == '*'
           cStat3 := "EA"
        Endif
        cStat  := ""
        cStat1 := Iif(Empty(cStat1), "", "'"+cStat1+"'")
        cStat  += Iif(Empty(cStat2), "", Iif(Empty(cStat), "'"+cStat2+"'", ","+"'"+cStat2+"'"))
        cStat  += Iif(Empty(cStat3), "", Iif(Empty(cStat), "'"+cStat3+"'", ","+"'"+cStat3+"'"))
        If !Empty(cStat)
           cQry1 += "SELECT * "
           cQry1 += "FROM "+RetSqlName("SZM")+" SZM "
           cQry1 += "WHERE SZM.ZM_FILIAL = '"+xFilial("SZM")+"' "
           cQry1 += "  AND SZM.D_E_L_E_T_= '' "
           cQry1 += "  AND SZM.ZM_STATUS NOT IN('AC','RE','RT') "
           If !Empty(cStat)
              cQry1 += "  AND SZM.ZM_STATUS IN ("+cStat+") "
           Endif
           If !Empty(cStat1)
              If Empty(cStat)
                 cStat += "  AND (SZM.ZM_STATUS IN ("+cStat1+") AND SZM.ZM_RESPONS = '"+cUsername+"' AND SZM.D_E_L_E_T_= '') "
              Else
                 cQry1 += "  OR (SZM.ZM_STATUS IN ("+cStat1+") AND SZM.ZM_RESPONS = '"+cUsername+"' AND SZM.D_E_L_E_T_= '') "
              Endif
           Endif
           cQry1 += "ORDER BY SZM.ZM_CODIGO "
           TCQuery cQry1 ALIAS "TCQ" NEW
           DbSelectArea("TCQ")
           DbGoTop()
           While !Eof()
                 aadd(aStat, { Iif(TCQ->ZM_STATUS $ 'EE', oLibEla, Iif(TCQ->ZM_STATUS $ 'PP', oLibPCP, oLibDir)), TCQ->ZM_CODIGO, TCQ->ZM_REVISAO, TCQ->ZM_DESCRIC, TCQ->ZM_STATUS } )
                 DbSelectArea("TCQ")
                 DbSkip()
           Enddo
           DbSelectArea("TCQ")
           DbCloseArea()
           If Len(aStat) <= 0
              Return
           Endif
           DEFINE MSDIALOG oDlg TITLE OemToAnsi( "Pendências da Simulação" ) FROM 000,000 TO 020, 080 OF oMainWnd
                  @ 018,003 LISTBOX oSZM VAR cSZM FIELDS HEADER " ", OemToAnsi("Código"), OemToAnsi("Revisão"), OemToAnsi("Descrição") SIZE 310,130 PIXEL OF oDlg 
                  
                  bSZMLine := { || { aStat[oSZM:nAt,1], aStat[oSZM:nAt,2], aStat[oSZM:nAt,3], aStat[oSZM:nAt,4] } }
                  
                  oSZM:SetArray( aStat )
                  oSZM:bLine   := bSZMLine
                  oSZM:GoTop()

                  oDlg:nStyle   := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
           ACTIVATE MSDIALOG oDlg CENTERED VALID .T. ON INIT ( oSZM:Refresh(), fHisOpc(oDlg, {|| oDlg:End() }, {|| oDlg:End() }, .t. ) )
        Endif
     Endif
Return Nil

Static Function fLegEnt()
       BrwLegenda(OemToAnsi("Legenda"), "Status", { {"DISABLE"    ,"Analise Química"   } ,;
                                                    {"BR_AMARELO" ,"Analise PCP"       } ,;
                                                    {"BR_AZUL"    ,"Analise Diretoria" } })
Return Nil
