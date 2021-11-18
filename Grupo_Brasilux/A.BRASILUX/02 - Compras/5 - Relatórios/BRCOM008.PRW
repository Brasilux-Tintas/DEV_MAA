#include "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BRCOM008 ³ Autor ³ Claudinei M. Benzi    ³ Data ³ 05.09.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relacao das Solicitacoes de Compras                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Edson Maricate³02/05/00³XXXXXX³Revisao geral no processamento do Rel.  ³±±
±±³Patricia Sal. ³17/07/00³XXXXXX³Deletar arquivo de trabalho ("TMP").    ³±±
±±³Gustavo       ³08/10/03³XXXXXX³Adequação BRASILUX TINTAS TECNICAS.     ³±±
±±³              ³        ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRCOM008()
     LOCAL wnrel
     LOCAL cDesc1     := "Emite um relacao para controle das solicitacoes cadastradas ,"
     LOCAL cDesc2     := "seus respectivos pedidos e prazos de entrega."
     LOCAL cDesc3     := ""
     LOCAL cString    := "SC1"
     LOCAL aOrd       := {" Por Solicitacao    "," Por Produto        "}

     PRIVATE Tamanho  := "G"
     PRIVATE Titulo   := "Relacao de Solicitacoes de Compras"
     PRIVATE NomeProg := "MATR100"
     PRIVATE aReturn  := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
     PRIVATE nLastKey := 0
     PRIVATE cPerg    := padr("MTR100",10)
     PRIVATE aInd     := {}
     u_zcfga01( 'BRCOM008' ) //LGS#2021118 - Gravação de log de utilização da rotina
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Verifica as perguntas selecionadas                           ³
     //³mv_par01             // a partir do numero                    ³
     //³mv_par02             // ate o numero                          ³
     //³mv_par03             // Tudo, em Aberto ou Canc. pelo Sistema ³
     //³mv_par04             // Data emissao inicial                  ³
     //³mv_par05             // Data emissao final                    ³
     //³mv_par06             // Mostra Pedido Compra p/ cotacoes      ³
     //³mv_par07             // Impr. SC's Firmes, Previstas ou Ambas ³
     //³mv_par08             // Impr. SC's com requisicoes            ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Pergunte(cPerg,.F.)

     wnrel:=SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho)

     If nLastKey == 27
        Set Filter To
        Return
     Endif

     SetDefault(aReturn,cString)

     If nLastKey = 27
        Set Filter To
        Return
     Endif

     RptStatus({|lEnd| C100Imp(@lEnd,wnRel,cString)},Titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C100IMP  ³ Autor ³ Cristina M. Ogura     ³ Data ³ 09.11.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function C100Imp(lEnd,WnRel,cString)

       LOCAL nCntImpr	:= 0
       LOCAL nEntregue	:= 0
       LOCAL nSldProd	:= 0
       LOCAL nTotSC	:= 0
       //Local nIndex	:= 0
       LOCAL nOrdem	:= aReturn[8]
       LOCAL aSoma		:= {}
       //Local aIndex	:= {}
       LOCAL Cabec1,Cabec2,nX
       //Local n
       Local lQuery   := .F.
       Local cQuery   := ""

       Local cProduto	:= ''
       Local cNumSol   := ''
       li := 80
       m_pag := 1
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Inicializa os codigos de caracter Comprimido/Normal da impressora ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Monta os Cabecalhos                                          ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       Titulo := "RELACAO DE SOLICITACOES DE COMPRAS"+Iif(MV_PAR06 == 1, " (Incluindo Pedidos de Compra)", " ")
       If MV_PAR06 == 1
          Cabec1 := "NUMERO ITEM PRODUTO         D E S C R I C A O              TP GRUP   QUANTIDADE UM   CENTRO  EMISSAO  NECESSI SOLICITANTE           DT.LIMITE          SALDO N.PED/ CODIGO LJ RAZAO SOCIAL                          DATA DO "
          Cabec2 := "                              T E C N I C A                          SOLICITADA       CUSTO           DADE SC                       DE COMPRA        DA S.C. N.COT. FORNEC                                          PEDIDO  "
       Else
          Cabec1 := "NUMERO ITEM PRODUTO         D E S C R I C A O              TP GRUP   QUANTIDADE UM   CENTRO  EMISSAO  NECESSI SOLICITANTE           DT.LIMITE          SALDO        CODIGO LJ RAZAO SOCIAL                                  "
          Cabec2 := "                              T E C N I C A                          SOLICITADA       CUSTO           DADE SC                       DE COMPRA        DA S.C.        FORNEC                                                  "
       Endif
       *****         123456 12   123456789012345 123456789012345678901234567890 99 9999 999999999.99 99 999999999 99/99/99 99/99/99 XXXXXXXXXXXXXXX      99/99/99    999999999.99 999999 999999 99 9999999999999999999999999999999999999999 99/99/99 99/99/99 999999999.99
       *****         0         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19       200       210       220
       *****         01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890

       If MV_PAR06 == 1
          #IFNDEF TOP
                  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                  //³ Abre o SC7 em outra area para criar uma nova IndRegua        ³
                  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                  ChkFile('SC7',.F.,'TMP')
                  aADD(aIndex,CriaTrab(NIL,.F.))
                  IndRegua("TMP",aIndex[Len(aIndex)],"C7_FILIAL+C7_NUMCOT+C7_PRODUTO")
                  dbSelectArea("SC7")
                  aADD(aIndex,CriaTrab(NIL,.F.))
                  IndRegua("SC7",aIndex[Len(aIndex)],"C7_FILIAL+C7_NUMSC+C7_ITEMSC+C7_PRODUTO")
                  nIndex := RetIndex("SC7")
                  dbSetIndex(aIndex[2]+OrdbagExt())
                  dbSetOrder(nIndex+1)
          #ENDIF
       EndIf

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Se o usuario escolher a opcao que lista as SC's canceladas   ³
       //³ pelo sistema ,e' necessario ativar as deletadas.             ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       If MV_PAR03 == 3
          SET DELE OFF
       Endif

       dbSelectArea("SC1")
       If nOrdem == 1
          dbSetOrder(1)
          dbSeek(xFilial()+MV_PAR01,.T.)
       Else
          dbSetOrder(2)
          dbSeek(xFilial())
       EndIf
       SetRegua(LastRec())

       While !Eof() .And. SC1->C1_FILIAL == xFilial() .And. IIf(nOrdem==1,C1_NUM <= MV_PAR02,.T.)
       
             If nOrdem == 2
                cValAnt		:= xFilial("SC1")+SC1->C1_PRODUTO
                cProduto    := SC1->C1_PRODUTO
                cQuebra		:= 'cValAnt==xFilial("SC1")+SC1->C1_PRODUTO'
             Else
                cValAnt		:= xFilial("SC1")+SC1->C1_NUM
                cNumSol     := SC1->C1_NUM
                cQuebra 	:= 'cValAnt==xFilial("SC1")+SC1->C1_NUM'
             EndIf

             While !Eof() .And. &( cQuebra )
                   cDescri := ""
                   lPasImp := .f.
                   If lEnd
                      @PROW()+1,001 PSAY "CANCELADO PELO OPERADOR"
                      Exit
                   Endif

                   IncRegua()
                   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                   //³ Filtra as solicitacoes maior que o numero definido           ³
                   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                   If C1_NUM < mv_par01 .Or. C1_NUM > mv_par02
                      dbSkip()
                      Loop
                   Endif

                   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                   //³ Filtra as solicitacoes cancelados pelo sistema               ³
                   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                   If (mv_par03 == 3 .And. !Deleted()) .Or. (mv_par03 == 3 .And. Deleted() .And. !("CANCELADO PELO SISTEMA."$C1_OBS))
                      dbSkip()
                      Loop
                   EndIf

                   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                   //³ Filtra as solicitacoes em aberto gerada cotacao ou pedido    ³
                   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                   If mv_par03 == 2 .And. (C1_QUANT <= C1_QUJE .Or. !Empty(C1_COTACAO))
                      dbSkip()
                      Loop
                   Endif

                   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                   //³ Verifica intervalo de data de emissao                        ³
                   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                   If (C1_EMISSAO < mv_par04 .Or. C1_EMISSAO > mv_par05)
                      dbSkip()
                      Loop
                   Endif

                   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                   //³ Filtra as solicitacoes nao entregue                          ³
                   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                   If mv_par03 == 4
                      If !Empty(C1_COTACAO) .And. C1_COTACAO <> "XXXXXX"
                         aSoma    := SomaSC7(1,C1_PRODUTO,C1_COTACAO)
                         If Empty(aSoma[1])                              // Nao foi entregue nada
                            nEntregue       := SC1->C1_QUANT
                         Elseif aSoma[2] == SC1->C1_QUANT                        // 1 SC ---> n PC
                                nEntregue       := aSoma[2] - aSoma[1]
                         Else                                                    // n SC ---> n PC
                            nEntregue       := (aSoma[1] / aSoma[2]) * SC1->C1_QUANT
                         Endif
                      Else
                         aSoma    := SomaSC7(2,C1_PRODUTO,C1_NUM)
                         nEntregue := SC1->C1_QUANT - aSoma[1]
                      Endif

                      dbSelectArea("SC1")

                      If nEntregue <= 0
                         dbSkip()
                         Loop
                      Endif
                   Else
                      nEntregue       := SC1->C1_QUANT
                   Endif

                   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                   //³ Filtra Tipo de SCs Firmes ou Previstas                       ³
                   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                   If !MtrAValOP(mv_par07, 'SC1')
                      dbSkip()
                      Loop
                   EndIf
                   
                   If MV_PAR08 == 1
                      If EMPTY(SC1->C1_IDREQUI)
                         DbSkip()
                         Loop
                      Endif
                   ElseIf MV_PAR08 == 2
                      If !EMPTY(SC1->C1_IDREQUI)
                         DbSkip()
                         Loop
                      Endif
                   Endif
                   If li > 55
                      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,IIF(aReturn[4]==1,15,18))
                   Endif
                   lPasImp := .t.
                   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                   //³ Adiciona 1 ao contador de registros impressos         ³
                   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                   nCntImpr++

                   @ li,000 PSAY C1_NUM
                   @ li,007 PSAY C1_ITEM
                   @ li,012 PSAY C1_PRODUTO

                   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                   //³ Imprime descricao completa da SC                             ³
                   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                   cDescri := Iif(EMPTY(SC1->C1_IDREQUI), SC1->C1_DESCRI, Posicione("SZU",1,xFilial("SZU")+SC1->C1_IDREQUI,"ZU_DESITEM"))
                   @ li,028 PSAY SubStr(cDescri,1,30)
                   For nX := 31 To Len(Trim(cDescri)) Step 30
                       li++
                       @ li,028 PSAY SubStr(cDescri,nX,30)
                   Next nX		
                   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                   //³ Posiciona no arquivo de produtos                             ³
                   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                   dbSelectArea("SB1")
                   dbSetOrder(1)
                   dbSeek(xFilial()+SC1->C1_PRODUTO)

                   @ li,059 PSAY B1_TIPO
                   @ li,062 PSAY B1_GRUPO

                   dbSelectArea("SC1")
                   @ li,067 PSAY C1_QUANT          Picture PesqPictQt("C1_QUANT",12)
                   @ li,080 PSAY C1_UM
                   @ li,083 PSAY PadL(Alltrim(C1_CC),09)    Picture "@!"
                   @ li,093 PSAY C1_EMISSAO        Picture PesqPict("SC1","C1_EMISSAO")
                   @ li,102 PSAY C1_DATPRF         Picture PesqPict("SC1","C1_DATPRF")
                   @ li,111 PSAY Substr(C1_SOLICIT,1,15)
                   @ li,132 PSAY SC1->C1_DATPRF - CalcPrazo(SC1->C1_PRODUTO,SC1->C1_QUANT)
                   @ li,144 PSAY SC1->C1_QUANT-SC1->C1_QUJE  Picture PesqPictQt("C1_QUANT",12)

                   nSldProd += ( C1_QUANT - C1_QUJE )
                   nTotSc   += Iif(Empty(C1_IDREQUI),C1_QUANT,0)

                   If MV_PAR06 == 1
                      If Empty(C1_COTACAO) .Or. C1_COTACAO == "XXXXXX"
                         #IFNDEF TOP
                                 cAliasSC7 := "SC7"
                                 dbSelectArea("SC7")
                                 If dbSeek(xFilial()+SC1->C1_NUM+SC1->C1_ITEM+SC1->C1_PRODUTO)
                                    While !Eof() .and. C7_FILIAL+C7_NUMSC+C7_ITEMSC == xFilial()+SC1->C1_NUM+SC1->C1_ITEM
                         #ELSE
                                 cAliasSC7 := "TMP"
                                 lQuery := .T.
                                 cQuery := "SELECT C7_FILIAL,C7_NUM,C7_FORNECE,C7_LOJA,C7_EMISSAO,C7_TPOP,C7_NUMSC,C7_ITEMSC "
                                 cQuery += "FROM "+RetSqlName("SC7")+" "					
                                 cQuery += "WHERE "
                                 cQuery += "C7_FILIAL = '"+xFilial("SC7")+"' AND "
                                 cQuery += "C7_NUMSC  = '"+SC1->C1_NUM+"' AND "
                                 cQuery += "C7_ITEMSC = '"+SC1->C1_ITEM+"' AND "
                                 cQuery += "D_E_L_E_T_= ' ' "
                                 cQuery += "ORDER BY C7_FILIAL,C7_NUMSC,C7_ITEMSC"
                                 //cQuery := ChangeQuery(cQuery)
                                 dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.T.,.T.)
                                 TcSetField("TMP","C7_EMISSAO","D",8,0)
                                 If ( Eof() )
                                    li++
                                 EndIf
                                 While !Eof()
                         #ENDIF
                                  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                                  //³ Filtra Tipo de SCs Firmes ou Previstas                       ³
                                  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                                  If !MtrAValOP(mv_par07, "SC7" )
                                     dbSkip()
                                     Loop
                                  EndIf

                                  @ li,157 PSAY C7_NUM
                                  @ li,164 PSAY C7_FORNECE
                                  @ li,171 PSAY C7_LOJA
                                  dbSelectArea("SA2")
                                  dbSeek(xFilial()+(cAliasSC7)->C7_FORNECE+(cAliasSC7)->C7_LOJA)
                                  @ li,174 PSAY SubStr(A2_NOME,1,28)
                                  @ li,210 PSAY (cAliasSC7)->C7_EMISSAO
                                  li++
                                  dbSelectArea(cAliasSC7)
                                  dbSkip()
                            EndDo
                            If ( lQuery )
                               (cAliasSC7)->(dbCloseArea())
                            EndIf
                            dbSelectArea("SC7")
                            #IFNDEF TOP
                         Else
                            li++
                         EndIf
                         #ENDIF
                      Else
                         #IFNDEF TOP
                         dbSelectArea("TMP")
                         If dbSeek(xFilial('SC7')+SC1->C1_COTACAO+SC1->C1_PRODUTO)
                            @ li,157 PSAY OemToAnsi("Pedidos gerados por cotacao - Num. ") + SC1->C1_COTACAO
                            li++
                            While !Eof() .And. C7_FILIAL+C7_NUMCOT+C7_PRODUTO  == xFilial('SC7')+SC1->C1_COTACAO+SC1->C1_PRODUTO
                         #ELSE
                                    lQuery := .T.
                                    cQuery := "SELECT C7_FILIAL,C7_NUM,C7_FORNECE,C7_LOJA,C7_EMISSAO,C7_TPOP,C7_NUMCOT,C7_PRODUTO "
                                    cQuery += "FROM "+RetSqlName("SC7")+" "
                                    cQuery += "WHERE "
                                    cQuery += "C7_FILIAL = '"+xFilial("SC7")+"' AND "
                                    cQuery += "C7_NUMCOT = '"+SC1->C1_COTACAO+"' AND "
                                    cQuery += "C7_PRODUTO = '"+SC1->C1_PRODUTO+"' AND "
                                    cQuery += "D_E_L_E_T_= ' ' "
                                    cQuery += "ORDER BY C7_FILIAL,C7_NUMCOT,C7_PRODUTO "
                                    //cQuery := ChangeQuery(cQuery)
                                    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.T.,.T.)
                                    TcSetField("TMP","C7_EMISSAO","D",8,0)
                                    If ( Eof() )
                                       li++
                                    Else
                                       @ li,157 PSAY OemToAnsi("Pedidos gerados por cotacao - Num. ") + SC1->C1_COTACAO
                                       li++
                                    EndIf
                                    While !Eof()
                         #ENDIF
                                  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                                  //³ Filtra Tipo de SCs Firmes ou Previstas                       ³
                                  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                                  If !MtrAValOP(mv_par07, 'SC7')
                                     dbSkip()
                                     Loop
                                  EndIf
                                  @ li,157 PSAY C7_NUM
                                  @ li,164 PSAY C7_FORNECE
                                  @ li,171 PSAY C7_LOJA
                                  dbSelectArea("SA2")
                                  dbSeek(xFilial()+TMP->C7_FORNECE+TMP->C7_LOJA)
                                  @ li,174 PSAY SubStr(A2_NOME,1,28)
                                  @ li,210 PSAY TMP->C7_EMISSAO
                                  li++
                                  dbSelectArea("TMP")
                                  dbSkip()
                            EndDo
                            #IFDEF TOP
                                   dbSelectArea("TMP")
                                   dbCloseArea()
                                   dbSelectArea("SC7")
                            #ELSE
                         Else
                            li++
                         EndIf
                      #ENDIF
                      EndIf
                   Else
                      dbSelectArea("SA2")
                      If dbSeek(xFilial()+SC1->C1_FORNECE+SC1->C1_LOJA)
                         dbSelectArea("SC1")
                         @ li,164 PSAY SubStr(SC1->C1_FORNECE,1,6)
                         @ li,171 PSAY SubStr(SC1->C1_LOJA,1,2)
                         @ li,174 PSAY SubStr(SA2->A2_NOME,1,38)
                      Endif   
                      li++
                   EndIf
                   dbSelectArea("SC1")
                   dbSkip()
             EndDo
             If lPasImp
                If nOrdem == 2 
                   li++
                   If nTotSC > 0
                      @li, 00 PSay "Total  -  " + Rtrim(cProduto) + " ----> "
                      @li, 67 PSay nTotSC   Picture PesqPictQt("C1_QUANT",16)
                      @li,150 PSay nSldProd Picture PesqPictQt("C1_QUANT",16)
                      li++
                   Endif
                   @li, 00 PSay __PrtThinLine()
                   nTotSc   := 0
                   nSldProd := 0
                   li++
                ElseIf nOrdem == 1 
                       li++
                       If nTotSC > 0
                          @li, 00 PSay "Total  -  " + Rtrim(cNumSol) + " ----> "
                          @li, 67 PSay nTotSC   Picture PesqPictQt("C1_QUANT",16)
                          @li,150 PSay nSldProd Picture PesqPictQt("C1_QUANT",16)
                          li++
                       Endif
                       @li, 00 PSay __PrtThinLine()
                       nTotSc   := 0
                       nSldProd := 0
                       li++
                EndIf
             Endif
       EndDo

       If MV_PAR03 == 3
          SET DELE ON
       EndIf

       If li != 80
          Roda(nCntImpr,"Registro(s)",Tamanho)
       EndIf

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Deleta Arquivo Temporario e Restaura os Indices Nativos.     ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       dbSelectArea("SC7")
       RetIndex("SC7")
       dbSelectArea("SC1")
       Set Filter To
       RetIndex("SC1")
       dbSetOrder(1)
       If ( Select("TMP")<>0 )
          dbSelectArea("TMP")
          dbCloseArea()
          dbSelectArea("SC7")
       EndIf
       #IFNDEF TOP
               For nI:=1 to Len(aIndex)
                   If File(aIndex[nI]+OrdBagExt())
                      Ferase(aIndex[nI]+OrdBagExt())
                   Endif
               Next
       #ENDIF

       Set Device to Screen

       If aReturn[5] = 1
          Set Printer To
          dbCommitAll()
          OurSpool(wnrel)
       Endif

       MS_FLUSH()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SomaSC7  ³ Autor ³ Cristina M. Ogura     ³ Data ³ 01.09.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula a soma das quantidade ja entregue                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nPar    - 1-Cotacao, 2-Solicitacao                         ³±±
±±³          ³ cProd   - Codigo do Produto                                ³±±
±±³          ³ cNumCot - Numero da Cotacao ou Solicitacao (nPar)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function SomaSC7(nPar,cProd,cNum)
     LOCAL aArea		:= GetArea()
     LOCAL aAreaSC7	:= SC7->(GetArea())
     LOCAL aSoma		:= Array(2)

     Afill(aSoma,0)
     dbSelectArea("SC7")
     dbSetOrder(2)
     dbSeek(cFilial+cProd)
     While !Eof() .And. cFilial+cProd == C7_FILIAL+C7_PRODUTO
           If nPar == 1
              If C7_NUMCOT <> cNum
                 dbSkip()
                 Loop
              Endif
           Else
              If C7_NUMSC <> cNum
                 dbSkip()
                 Loop
              Endif
           Endif
           aSoma[1]  +=C7_QUJE
           aSoma[2]  +=C7_QUANT
           dbSkip()
     End

     RestArea(aAreaSC7)
     RestArea(aArea)
Return
