#include 'rwmake.ch'
#include 'topconn.ch'
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRPCPR06 º Autor ³ AP6 IDE            º Data ³  30/09/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRPCPR06()
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "RELAÇÃO PARA PRODUÇÃO"
     //Local cPict         := ""
     Local titulo        := "RELAÇÃO PARA PRODUÇÃO"
     Local nLin          := 80
     Local Cabec1        := "Pr.  Produto         Descrição                             Quantidades       "
     Local Cabec2        := "                                                    Bord. Saldo O.P.   Neces."
     //Local imprime       := .T.
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     //Private CbTxt       := ""
     Private limite      := 80
     Private tamanho     := "P"
     Private nomeprog    := "BRPCPR06" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 18
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := "PCPR06"
     Private cbtxt       := Space(10)
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRPCPR06" // Coloque aqui o nome do arquivo usado para impressao em disco

     Private cString     := "SZF"

     dbSelectArea("SZF")
     dbSetOrder(1)
     //VldPerg()  //LGS#20200131 - Adequação de release 12.1.25 e posteriores
     pergunte(cPerg, .F.)

     wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

     If nLastKey == 27
        Return
     Endif

     SetDefault(aReturn,cString)

     If nLastKey == 27
        Return
     Endif

     nTipo := If(aReturn[4]==1,15,18)

     Processa({|| PCPR06_1(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ PCPR06_1 º Autor ³ AP6 IDE            º Data ³  30/09/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PCPR06_1(Cabec1, Cabec2, Titulo, nLin)
       //Local nOrdem
       Local nX, nY
       Local cQry1   := ""
       Local aMatImp := {}
       
       cQry1 += "SELECT 'ORDEM' = CASE WHEN SZF.ZF_CODIGO = '"+mv_par01+"' THEN '01' ELSE '02' END, "
       cQry1 += "       SZF.ZF_CODIGO AS BORDERO, SUBSTRING(SZG.ZG_PEDIDO, 3, 6) AS PEDIDO, SZG.ZG_LOCALIZ AS LOCALIZACAO, SC5.C5_CLIENTE AS CLIENTE, SC5.C5_LOJACLI AS LOJA, SC6.C6_PRODUTO AS PRODUTO, SC6.C6_QTDVEN AS QUANTIDADE "
       cQry1 += "FROM "+RetSqlName("SZF")+" SZF WITH (NOLOCK) "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH (NOLOCK) ON SZF.ZF_FILIAL = SZG.ZG_FILIAL AND SZF.ZF_CODIGO = SZG.ZG_CODIGO AND SZG.D_E_L_E_T_ = '' "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON SZG.ZG_FILIAL = SC5.C5_FILIAL AND SUBSTRING(SZG.ZG_PEDIDO, 3, 6) = SC5.C5_NUM AND SC5.D_E_L_E_T_ = '' "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON SC5.C5_FILIAL = SC6.C6_FILIAL AND SC5.C5_NUM = SC6.C6_NUM AND SC6.D_E_L_E_T_ = '' "
       cQry1 += "WHERE SZF.ZF_FILIAL = '"+xFilial("SZF")+"' "
       cQry1 += "  AND SZF.D_E_L_E_T_ = '' "
       cQry1 += "  AND SZF.ZF_CODIGO BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
       cQry1 += "  AND LEN(SC6.C6_PRODUTO) = 12 "
       cQry1 += "  AND SC6.C6_QTDENT = 0.0 "
       cQry1 += "ORDER BY SZF.ZF_CODIGO "
       TCQuery cQry1 ALIAS "TCQ" NEW
       
       DbSelectArea("TCQ")
       DbGoTop()
       While !Eof()
             If aScan(aMatImp, {|x| x[1]+x[2] == TCQ->ORDEM+TCQ->PRODUTO}) == 0
                aAdd(aMatImp, {TCQ->ORDEM, TCQ->PRODUTO, TCQ->QUANTIDADE, ''})
             Else
                aMatImp[aScan(aMatImp, {|x| x[1]+x[2] == TCQ->ORDEM+TCQ->PRODUTO})][3] += TCQ->QUANTIDADE
             Endif
             DbSelectArea("TCQ")
             DbSkip()
       EndDo
       DbSelectArea("TCQ")
       DbCloseArea()
       
       If mv_par03 == 1 //Considera pedidos sem bordero.
          cQry1 := ""
          cQry1 += "SELECT 'ORDEM' = CASE WHEN SC5.C5_APROVA = '1' THEN '03' ELSE '04' END, SC5.C5_NUM, SC5.C5_APROVA, SC6.C6_PRODUTO AS PRODUTO, SC6.C6_QTDVEN AS QUANTIDADE, CASE WHEN ISNULL(SZG.ZG_CODIGO, 'N') = 'N' THEN 'N' ELSE 'S' END AS BORDERO "
          cQry1 += "FROM "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) "
          cQry1 += "LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON SC5.C5_FILIAL = SC6.C6_FILIAL AND SC5.C5_NUM = SC6.C6_NUM AND SC6.D_E_L_E_T_ = '' "
          cQry1 += "LEFT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH (NOLOCK) ON SC5.C5_FILIAL = SZG.ZG_FILIAL AND SC5.C5_NUM = SUBSTRING(SZG.ZG_PEDIDO, 3, 6) AND SZG.D_E_L_E_T_ = '' "
          cQry1 += "WHERE SC5.C5_FILIAL = '"+xFilial("SC5")+"' "
          cQry1 += "  AND SC5.D_E_L_E_T_ = '' "
          cQry1 += "  AND SC5.C5_NOTA = '' "
          cQry1 += "  AND SC5.C5_APROVA <> '2' "
          cQry1 += "  AND LEN(SC6.C6_PRODUTO) = 12 "
          cQry1 += "ORDER BY SC5.C5_NUM "
          TCQuery cQry1 ALIAS "TCQ" NEW
       
          DbSelectArea("TCQ")
          DbGoTop()
          While !Eof()
                If TCQ->BORDERO $ 'N'
                   If aScan(aMatImp, {|x| x[1]+x[2] == TCQ->ORDEM+TCQ->PRODUTO}) == 0
                      aAdd(aMatImp, {TCQ->ORDEM, TCQ->PRODUTO, TCQ->QUANTIDADE, ''})
                   Else
                      aMatImp[aScan(aMatImp, {|x| x[1]+x[2] == TCQ->ORDEM+TCQ->PRODUTO})][3] += TCQ->QUANTIDADE
                   Endif
                Endif
                DbSelectArea("TCQ")
                DbSkip()
          EndDo
          DbSelectArea("TCQ")
          DbCloseArea()
       Endif
       
       ProcRegua(Len(aMatImp))
       
       aSort(aMatImp,,,{|x, y| x[1]+x[2] < y[1]+y[2]})
       //0         1         2         3         4         5         6         7         8
       //01234567890123456789012345678901234567890123456789012345678901234567890123456789
       //Pr.  Produto         Descrição                             Quantidades       
       //                                                    Bord. Saldo O.P.   Neces.
       //01 - XX 99.99.999-99 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 99999 99999 99999  999999
       For nY := 1 To Len(aMatImp)
           IncProc('Processando: '+aMatImp[nY][2])
           If lAbortPrint
              @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
              Exit
           Endif
           If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
              nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
              nLin += 1
           Endif
           If Empty(aMatImp[nY][4])
              cProd   := aMatImp[nY][2]
              nQtdB   := 0
              aMatAux := {}
              For nX := 1 To Len(aMatImp)
                  If Empty(aMatImp[nX][4])
                     If aMatImp[nX][2] == cProd
                        aadd(aMatAux, {aMatImp[nX][1]+' - '+Transform(aMatImp[nX][2], "@R XX 99.99.999-99"), Posicione("SB1", 1, xFilial("SB1")+aMatImp[nX][2], "B1_DESC"), aMatImp[nX][3]})
                        aMatImp[nX][4] := 'S'
                        nQtdB += aMatImp[nX][3]
                     Endif
                  Endif
              Next
              If Len(aMatAux) > 0
                 nQtdAt := 0
                 nQtdAt := Posicione("SB2", 1, xFilial("SB2")+aMatImp[nY][2]+Posicione("SB1", 1, xFilial("SB1")+aMatImp[nY][2], "B1_LOCPAD"), "B2_QATU") 
                 nQtdOp := 0
                 cQry1 := "SELECT SUM(SC2.C2_QUANT) AS C2_QUANT FROM "+RetSqlName("SC2")+" SC2 WITH(NOLOCK) WHERE SC2.C2_FILIAL  = '"+xFilial("SC2")+"' AND SC2.D_E_L_E_T_ = '' AND SC2.C2_PRODUTO = '"+aMatImp[nY][2]+"' AND SC2.C2_DATRF   = '' "
                 TCQuery cQry1 ALIAS "QTMP" NEW
                 DbSelectArea("QTMP")
                 nQtdOp := QTMP->C2_QUANT 
                 DbSelectArea("QTMP")
                 DbCloseArea()
                 If mv_par04 == 1
                    If ((nQtdAt + nQtdOp) - nQtdB) < 0
                       For nX := 1 To Len(aMatAux)
                           @ nLin, 000 PSAY aMatImp[nX][1]+' - '+Transform(aMatImp[nX][2], "@R XX 99.99.999-99")
                           @ nLin, 021 PSAY Posicione("SB1", 1, xFilial("SB1")+aMatImp[nX][2], "B1_DESC")
                           @ nLin, 052 PSAY aMatImp[nX][3] Picture "@E 99999"
                           nLin += 1 // Avanca a linha de impressao
                       Next
                       @ nLin, 000 PSAY Replicate("-", 79)
                       nLin += 1
                       @ nLin, 052 PSAY nQtdB  Picture "@E 99999"
                       @ nLin, 058 PSAY nQtdAt Picture "@E 99999"
                       @ nLin, 064 PSAY nQtdOp Picture "@E 99999"
                       @ nLin, 071 PSAY (nQtdAt + nQtdOp) - nQtdB Picture "@E 999999"
                       nLin += 2
                    EndIf
                 Endif
              Endif
           Endif
       Next

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Finaliza a execucao do relatorio...                                 ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

       SET DEVICE TO SCREEN
       If aReturn[5]==1
          dbCommitAll()
          SET PRINTER TO
          OurSpool(wnrel)
       Endif

       MS_FLUSH()

Return

//LGS#20200131 - Adequação de release 12.1.25 e posteriores
/*
Static Function VldPerg()
       Local aHelp1 := {}
       Local aHelp2 := {}
       aAdd( aHelp1, "Informe a faixa de borderos a serem" )
       aAdd( aHelp1, "processados.                       " )
       aAdd( aHelp2, "Considerar pedidos que não estão em" )
       aAdd( aHelp2, "borderos de pedidos?               " )
       
       PutSX1("PCPR06", "01"  ,   "Do Bordero              ", ""     , ""     , "mv_ch1", "C"  , 6       , 0       , 0      , "G" , " "   , "SZF", " "    , " "  , "mv_par01", " "          , " "     , " "     , " "   , " "             , " "     , " "     , " "           , " "     , " "     , " "    , " "     , " "     , " "          ,  " "     ,  " "     , aHelp1  , Nil     , Nil     , "PCPR06" )
       PutSX1("PCPR06", "02"  ,   "Até Bordero             ", ""     , ""     , "mv_ch2", "C"  , 6       , 0       , 0      , "G" , " "   , "SZF", " "    , " "  , "mv_par02", " "          , " "     , " "     , " "   , " "             , " "     , " "     , " "           , " "     , " "     , " "    , " "     , " "     , " "          ,  " "     ,  " "     , aHelp1  , Nil     , Nil     , "PCPR06" )
       PutSX1("PCPR06", "03"  ,   "Considera Ped. sem Bord.", ""     , ""     , "mv_ch3", "N"  , 1       , 0       , 0      , "C" , " "   , ""   , " "    , " "  , "mv_par03", "Sim"        , " "     , " "     , " "   , "Não"           , " "     , " "     , " "           , " "     , " "     , " "    , " "     , " "     , " "          ,  " "     ,  " "     , aHelp2  , Nil     , Nil     , "PCPR06" )
       PutSX1("PCPR06", "04"  ,   "Somente c/ Necessidade  ", ""     , ""     , "mv_ch4", "N"  , 1       , 0       , 0      , "C" , " "   , ""   , " "    , " "  , "mv_par04", "Sim"        , " "     , " "     , " "   , "Não"           , " "     , " "     , " "           , " "     , " "     , " "    , " "     , " "     , " "          ,  " "     ,  " "     , Nil     , Nil     , Nil     , "PCPR06" )
Return
*/