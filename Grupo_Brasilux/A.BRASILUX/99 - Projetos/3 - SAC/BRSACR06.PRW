#include "rwmake.ch"
#include "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRSACR06 º Autor ³ Luís G. de Souza   º Data ³  16/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório de Estatisticas de SAC.                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRSACR06()
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "Relatorio Estatistico de SAC's"
     //Local cPict         := ""
     Local titulo        := "Relatorio Estatistico de SAC's"
     Local Cabec1        := ""
     Local Cabec2        := ""
     //Local imprime       := .T.
     Local aOrd          := {}
     Private nLin          := 80
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     //Private CbTxt       := ""
     Private limite      := 80
     Private tamanho     := "P"
     Private nomeprog    := "BRSACR06" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 18
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := "SACR06"
     Private cbtxt       := Space(10)
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRSACR06" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString     := "SZQ"

     DbSelectArea("SZQ")
     DbSetOrder(1)
     
     VldPerg()
     
     Pergunte(cPerg,.F.)

     wnrel := SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho,, .F.)

     If nLastKey == 27
        Return
     Endif

     SetDefault(aReturn,cString)
     If nLastKey == 27
        Return
     Endif

     nTipo := If(aReturn[4]==1,15,18)

     RptStatus({|| SACR06_1(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ SACR06_1 º Autor ³ Luís G. de Souza   º Data ³  16/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SACR06_1(Cabec1, Cabec2, Titulo, nLin)
       //Local nOrdem
       Local cQry1 := ""
       Local nSACTota := 0
       Local aSACTota := {}
       Local nSACProc := 0
       Local aSACProc := {}
       Local nSACNPro := 0
       Local aSACNPro := {}
       Local nSACSRes := 0
       Local aSACSRes := {}
       Local aLinhas  := {}
       Local aProdut  := {}
       Local aEspeci  := {}
       Local aLinAss  := {}
       Local aProAss  := {}
       Local nY, nX, nZ
       Cabec1 := "Período de: "+dToc(mv_par01)+" à "+dToc(mv_par02)+"                LINHAS / PRODUTOS: "+Iif(mv_par03 == 1, "PROCEDENTES", Iif(mv_par03 == 2, "NÃO PROCEDENTES", Iif(mv_par03 == 3, "SEM RESPOSTA", Iif(mv_par03 == 4, "TODOS", "NENHUM"))))
       
       DbSelectArea(cString)
       DbSetOrder(1)
       SetRegua(200)
       cQry1 := ""
       cQry1 += "SELECT SZQ.ZQ_FILIAL, SZQ.ZQ_NUM, SZQ.ZQ_CLIENTE, SZQ.ZQ_DATA, SZQ.ZQ_RESP, SZQ.ZQ_ATENDEN, SZQ.ZQ_CONTATO, SZQ.ZQ_STATUS, SZQ.ZQ_TIPOSAC, SZQ.ZQ_DEVOLV, SZQ.ZQ_HINI, SZQ.ZQ_HFIM, SZQ.ZQ_DTFIM, SZQ.ZQ_PROCEDE, SZQ.ZQ_FLAG, SZQ.ZQ_CUSDEV, SZQ.ZQ_CUSFRE, SZQ.ZQ_CUSFIN "
       cQry1 += "FROM "+RetSQLName("SZQ")+" SZQ "
       cQry1 += "WHERE SZQ.ZQ_FILIAL  = '"+xFilial("SZQ")+"' "
       cQry1 += "  AND SZQ.D_E_L_E_T_ = '' "
       cQry1 += "  AND SZQ.ZQ_DATA BETWEEN '"+dTos(mv_par01)+"' AND '"+dTos(mv_par02)+"' "
       cQry1 += "ORDER BY SZQ.ZQ_FILIAL, SZQ.ZQ_DATA, SZQ.ZQ_NUM "
       TCQuery cQry1 ALIAS "TCQ" NEW
       
       DbSelectArea("TCQ")
       DbGoTop()
       While !Eof()
             If lAbortPrint
                @ nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
                Exit
             Endif
             IncRegua()
             nSACTota += 1
             aadd(aSACTota, TCQ->ZQ_NUM)
             If TCQ->ZQ_PROCEDE $ 'S'
                nSACProc += 1
                aadd(aSACProc, TCQ->ZQ_NUM)
             ElseIf TCQ->ZQ_PROCEDE $ 'N'
                    nSACNPro += 1
                    aadd(aSACNPro, TCQ->ZQ_NUM)
             Else
                If Empty(TCQ->ZQ_PROCEDE)
                   cQry1 := ""
                   cQry1 += "SELECT TOP 1 SZS.ZS_PROCEDE "
                   cQry1 += "FROM "+RetSqlName("SZS")+" SZS "
                   cQry1 += "WHERE SZS.ZS_FILIAL = '"+xFilial("SZS")+"' "
                   cQry1 += "  AND SZS.D_E_L_E_T_ = '' "
                   cQry1 += "  AND SZS.ZS_NUM = '"+TCQ->ZQ_NUM+"' "
                   cQry1 += "  AND SZS.ZS_PROCEDE NOT IN('') "
                   cQry1 += "ORDER BY R_E_C_N_O_ DESC "
                   TCQuery cQry1 ALIAS "TMP" NEW
                   DbSelectArea("TMP")
                   cFlag := TMP->ZS_PROCEDE
                   DbSelectArea("TMP")
                   DbCloseArea()
                   If cFlag == 'S'
                      nSACProc += 1
                      aadd(aSACProc, TCQ->ZQ_NUM)
                   ElseIf cFlag == 'N'
                          nSACNPro += 1
                          aadd(aSACNPro, TCQ->ZQ_NUM)
                   Else
                      nSACSRes += 1
                      aadd(aSACSRes, TCQ->ZQ_NUM)
                   Endif
                Endif
             Endif
             DbSelectArea("TCQ")
             DbSkip()
       Enddo 
       //Monta Matriz de Linhas
       SACR06_2(@aLinhas, @aEspeci, aSACProc, aSACNPro, aSACSRes, aSACTota          ) //Linhas
       SACR06_3(@aProdut, @aEspeci, aSACProc, aSACNPro, aSACSRes, aSACTota, @aLinhas) //Produtos 
       SACR06_4(@aLinhas, @aLinAss, aSACProc, aSACNPro, aSACSRes, aSACTota          ) //Linhas X Assuntos
       SACR06_5(@aLinhas, @aProAss, aSACProc, aSACNPro, aSACSRes, aSACTota          ) //Produtos X Assuntos
       
       DbSelectArea("TCQ")
       DbCloseArea()
       aSort(aEspeci, , , {|x,y| x[1] < y[1]})
       aSort(aLinhas, , , {|x,y| Transform(x[2], "@E 9999")+x[1] > Transform(y[2], "@E 9999")+y[1] })
       aSort(aProdut, , , {|x,y| SubStr(x[1], 4, 2)+Transform(x[2], "@E 9999") > SubStr(y[1], 4, 2)+Transform(y[2], "@E 9999") })
       aSort(aLinAss, , , {|x,y| x[1]+x[2]+Transform(x[4], "@E 9999") < y[1]+y[2]+Transform(y[4], "@E 9999") })

       If (nSACTota + nSACProc + nSACNPro + nSACSRes) > 0
          If nLin > 60 // Salto de Página. Neste caso o formulario tem 60 linhas...
             nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
             nLin += 1
          Endif
          /*********************************************************************************************************/
          /*** IMPRESSÃO DO CABEÇALHO DA ANÁLISE                                                                 ***/
          /*********************************************************************************************************/
          @ nLin, 000 PSAY "SAC's abertos no período.........: "+Transform(nSACTota, "@E 9999")
            nLin += 1
          @ nLin, 000 PSAY "SAC's procedentes no período.....: "+Transform(nSACProc, "@E 9999")
            nLin += 1
          @ nLin, 000 PSAY "SAC's não procedentes no período.: "+Transform(nSACNPro, "@E 9999")
            nLin += 1
          @ nLin, 000 PSAY "SAC's sem respostas no período...: "+Transform(nSACSRes, "@E 9999")
            nLin += 1
          @ nLin, 000 PSAY Replicate("*", 80)
            nLin += 1
       Endif
       If mv_par03 <> 5 //Linhas
          If Len(aLinhas) > 0
             /*********************************************************************************************************/
             /*** IMPRESSÃO DA ANALISE POR LINHAS                                                                   ***/
             /*********************************************************************************************************/
             @ nLin, 000 PSAY PADC("LINHAS", 80)
               nLin += 1
             @ nLin, 000 PSAY "---------------+---------------+---------------+---------------+---------------+"
               nLin += 1
             @ nLin, 000 PSAY " LINHA  QTDE.  | LINHA  QTDE.  | LINHA  QTDE.  | LINHA  QTDE.  | LINHA  QTDE.  | "
               nLin += 1
             @ nLin, 000 PSAY "---------------+---------------+---------------+---------------+---------------+"
               nLin += 1
               nCol1 :=  2
               nCol2 :=  9
               nCol3 := 15
               nTCol :=  1
               nTotOco := 0
             For nY := 1 To Len(aLinhas)
                 @ nLin, nCol1 PSAY Alltrim(aLinhas[nY][1])
                 @ nLin, nCol2 PSAY Transform(aLinhas[nY][2], "@E 9999")
                 @ nLin, nCol3 PSAY "|"
                 If nTCol < 5
                    nTCol += 1 ; nCol1 += 16 ; nCol2 += 16; nCol3 += 16
                 Else
                    nTCol := 1 ; nCol1 :=  2 ; nCol2 :=  9; nCol3 := 15 ; nLin += 1
                 Endif
                 nTotOco += aLinhas[nY][2]
             Next
             For nY := nTCol To 5
                 @ nLin, nCol3 PSAY "|"
                   nCol3 += 16
             Next
               nLin += 1
             @ nLin, 000 PSAY "---------------+---------------+---------------+---------------+---------------+"
               nLin += 1
             @ nLin, 000 PSAY "TOTAL DE OCORRÊNCIAS: "+Transform(nTotOco, "@E 9999")
               nLin += 1
             @ nLin, 000 PSAY Replicate("*", 80)
               nLin += 1
          Endif
       Endif
       If mv_par04 <> 5 //Produtos x Linhas
          If Len(aProdut) > 0
             /*********************************************************************************************************/
             /*** IMPRESSÃO DA ANALISE POR PRODUTOS                                                                 ***/
             /*********************************************************************************************************/
             If nLin > 60 // Salto de Página. Neste caso o formulario tem 60 linhas...
                nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                nLin += 1
             Endif
               nLin += 1
             @ nLin, 000 PSAY PADC("PRODUTOS", 80)
               nLin += 1
             @ nLin, 000 PSAY Replicate("*", 80)
               nLin += 1
             For nY := 1 To Len(aLinhas)
                 If nLin > 60 // Salto de Página. Neste caso o formulario tem 60 linhas...
                    nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                    nLin += 1
                 Endif
                 @ nLin, 000 PSAY "Linha: "+aLinhas[nY][1]
                   nLin += 1
                 @ nLin, 000 PSAY "-------------------------+--------------------------+--------------------------+"
                   nLin += 1
                 @ nLin, 000 PSAY "PRODUTO             QTDE.| PRODUTO             QTDE.| PRODUTO             QTDE.|"
                   nLin += 1
                 @ nLin, 000 PSAY "-------------------------+--------------------------+--------------------------+"
                   nLin += 1
                   nCol1 :=  0
                   nCol2 := 20
                   nCol3 := 25
                   nTCol :=  1
                 For nX := 1 To Len(aProdut)
                     If SubStr(aProdut[nX][1], 4, 2) == aLinhas[nY][1]
                        @ nLin, nCol1 PSAY aProdut[nX][1]  Picture("@R XX 99.99.999-99")
                        @ nLin, nCol2 PSAY TransForm(aProdut[nX][2], "@E 9999")
                        @ nLin, nCol3 PSAY "|"
                        If nTCol < 3
                           nTCol += 1 ; nCol1 += 27 ; nCol2 += 27; nCol3 += 27
                        Else
                           nTCol := 1 ; nCol1 :=  0 ; nCol2 := 20; nCol3 := 25 ; nLin += 1
                           If nLin > 60 // Salto de Página. Neste caso o formulario tem 60 linhas...
                              nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                              nLin += 1
                           Endif
                        Endif
                     Endif
                 Next
                 If nTCol > 1 .or. nTCol > 3
                    For nX := nTCol To 3
                        @ nLin, nCol3 PSAY "|"
                          nCol3 += 27
                    Next
                      nLin += 1
                    @ nLin, 000 PSAY "-------------------------+--------------------------+--------------------------+"
                 Else
                    @ nLin, 000 PSAY "-------------------------+--------------------------+--------------------------+"
                 Endif
                   nLin += 1
                 If nLin > 60 // Salto de Página. Neste caso o formulario tem 60 linhas...
                    nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                    nLin += 1
                 Endif
             Next
             @ nLin, 000 PSAY Replicate("*", 80)
               nLin += 2
          Endif
       Endif
       If Len(aEspeci) > 0
          @ nLin, 000 PSAY PADC("ESPECÍFICOS", 80)
            nLin += 1
          @ nLin, 000 PSAY Replicate("*", 80)
            nLin += 1
          For nY := 1 To Len(aEspeci)
              @ nLin, 000 PSAY aEspeci[nY][1]+" - "+Transform(aEspeci[nY][2], "@E 9999")
                nLin += 1
          Next
          @ nLin, 000 PSAY Replicate("*", 80)
            nLin += 1
       Endif
       If mv_par05 <> 5 //Ocorrências x Linhas
          If Len(aLinhas) > 0
             aMatAux := {}
             /*********************************************************************************************************/
             /*** IMPRESSÃO DA ANALISE DE OCORRÊNCIAS X LINHAS                                                      ***/
             /*********************************************************************************************************/
             If mv_par05 == 1 //Procedentes
                aMatAux := aSACProc
             ElseIf mv_par05 == 2 //Não Procedentes
                    aMatAux := aSACNPro
             ElseIf mv_par05 == 3 //Sem Respostas
                    aMatAux := aSACSRes
             ElseIf mv_par05 == 4 //Todos
                    aMatAux := aSACTota
             ElseIf mv_par05 == 5
                    Return
             Endif
             cMatAux := "('"
             For nY := 1 To Len(aMatAux)
                 cMatAux += aMatAux[nY]+"','"
             Next
             cMatAux := SubStr(cMatAux, 1, Len(cMatAux)-2)+")"
               nLin += 1
             @ nLin, 000 PSAY PADC("OCORRÊNCIAS X LINHAS", 80)
               nLin += 1
             @ nLin, 000 PSAY Replicate("*", 80)
               nLin += 1
             For nY := 1 To Len(aLinhas)
                 @ nLin, 000 PSAY "LINHA: "+aLinhas[nY][1]
                 @ nLin, 063 PSAY "ITENS| QTDE. SAC."
                   nLin += 1
                 aImpALn := {}
                 For nX := 1 To Len(aLinAss)
                     If aLinhas[nY][1] == aLinAss[nX][1]
                        aadd(aImpALn, {aLinAss[nX][1], aLinAss[nX][2], aLinAss[nX][3], aLinAss[nX][4], 0})
                     Endif
                 Next
                 nAss := 1
                 nOco := 1
                 For nX := 1 To Len(aImpALn)
                     If nAss == 1
                        @ nLin, 000 PSAY "Assunto: "+aImpALn[nX][2]+" - "+SubStr(Posicione("SX5", 1, xFilial("SX5")+"T1"+aImpALn[nX][2], "X5_DESCRI"), 1, 15)
                        @ nLin, 068 PSAY "|"
                          nLin += 1
                          cAssunto := aImpALn[nX][2]
                          nAss += 1
                     Else
                        If !cAssunto == aImpALn[nX][2]
                           @ nLin, 009 PSAY aImpALn[nX][2]+" - "+SubStr(Posicione("SX5", 1, xFilial("SX5")+"T1"+aImpALn[nX][2], "X5_DESCRI"), 1, 15)
                           @ nLin, 068 PSAY "|"
                             nLin += 1
                             cAssunto := aImpALn[nX][2]
                        Endif
                     Endif
                     
                     cQry1 := ""
                     cQry1 += "SELECT SZR.ZR_NUM "
                     cQry1 += "FROM "+RetSqlName("SZR")+" SZR "
                     cQry1 += "WHERE SZR.ZR_FILIAL  = '"+xFilial("SZR")+"' "
                     cQry1 += "  AND SZR.D_E_L_E_T_ = '' "
                     cQry1 += "  AND SUBSTRING(SZR.ZR_PRODUTO, 4, 2) = '"+aImpALn[nX][1]+"' "
                     cQry1 += "  AND SZR.ZR_ASSUNTO = '"+aImpALn[nX][2]+"' "
                     cQry1 += "  AND SZR.ZR_OCORREN = '"+aImpALn[nX][3]+"' "
                     cQry1 += "  AND SZR.ZR_NUM IN "+cMatAux+" "
                     cQry1 += "GROUP BY SZR.ZR_NUM "
                     /*
                     cQry1 += "FROM "+RetSqlName("SZQ")+" SZQ "
                     cQry1 += "LEFT OUTER JOIN "+RetSqlName("SZR")+" SZR ON SZQ.ZQ_FILIAL = SZR.ZR_FILIAL AND SZQ.ZQ_NUM = SZR.ZR_NUM AND SZR.D_E_L_E_T_ = '' "
                     cQry1 += "WHERE SZQ.ZQ_FILIAL  = '"+xFilial("SZQ")+"' "
                     cQry1 += "  AND SZQ.D_E_L_E_T_ = '' "
                     cQry1 += "  AND SZQ.ZQ_DATA BETWEEN '"+dTos(mv_par01)+"' AND '"+dTos(mv_par02)+"' "
                     cQry1 += "  AND SZQ.ZQ_PROCEDE IN('"+Iif(mv_par05 == 1, "S')", Iif(mv_par05 == 2, "N')", Iif(mv_par05 == 3, " ')", "S','N',' ') ")))
                     cQry1 += "  AND SUBSTRING(SZR.ZR_PRODUTO, 4, 2) = '"+aImpALn[nX][1]+"' "
                     cQry1 += "  AND SZR.ZR_ASSUNTO = '"+aImpALn[nX][2]+"' "
                     cQry1 += "  AND SZR.ZR_OCORREN = '"+aImpALn[nX][3]+"' "
                     cQry1 += "GROUP BY SZR.ZR_NUM "
                     */
                     TCQuery cQry1 ALIAS "QTD" NEW

                     nQtdOco := 0
                     DbSelectArea("QTD")
                     DbGoTop()
                     While !Eof()
                           nQtdOco += 1
                           DbSkip()
                     EndDo
                     DbSelectArea("QTD")
                     DbCloseArea()
                     If nOco == 1
                        @ nLin, 009 PSAY "Ocorrência: "+Alltrim(aImpALn[nX][3])+" - "+Posicione("SU9", 1, xFilial("SU9")+aImpALn[nX][2]+aImpALn[nX][3], "U9_DESC")+" - "+Transform(aImpALn[nX][4], "@E 9999")
                        @ nLin, 068 PSAY "|"
                        @ nLin, 076 PSAY TransForm(nQtdOco, "@E 9999")
                          nOco += 1
                     Else
                        @ nLin, 021 PSAY Alltrim(aImpALn[nX][3])+" - "+Posicione("SU9", 1, xFilial("SU9")+aImpALn[nX][2]+aImpALn[nX][3], "U9_DESC")+" - "+Transform(aImpALn[nX][4], "@E 9999")
                        @ nLin, 068 PSAY "|"
                        @ nLin, 076 PSAY TransForm(nQtdOco, "@E 9999")
                     Endif
                     nLin += 1
                 Next
                 @ nLin, 000 PSAY Replicate("-", 80)
                   nLin += 1
                 If nLin > 60 // Salto de Página. Neste caso o formulario tem 60 linhas...
                    nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                    nLin += 1
                 Endif
             Next
             @ nLin, 000 PSAY Replicate("*", 80)
               nLin += 1
          Endif
       Endif
       If mv_par06 <> 5 //Ocorrências x Produtos
          If Len(aProAss) > 0
               nLin += 1
             @ nLin, 000 PSAY PADC("OCORRÊNCIAS X PRODUTOS", 80)
               nLin += 1
             @ nLin, 000 PSAY Replicate("*", 80)
               nLin += 1
             For nY := 1 To Len(aLinhas)
                 @ nLin, 000 PSAY "LINHA: "+aLinhas[nY][1]
                 aImpAPr := {}
                 For nX := 1 To Len(aProAss)
                     If aLinhas[nY][1] == SubStr(aProAss[nX][1], 4, 2) .and. Empty(aProAss[nX][5])
                        aadd(aImpAPr, {aProAss[nX][1], aProAss[nX][2], aProAss[nX][3], aProAss[nX][4], ""})
                        aProAss[nX][5] := "S"
                     Endif
                 Next
                 cAssunto := ""
                 For nX := 1 To Len(aImpAPr)
                     If nLin > 60 // Salto de Página. Neste caso o formulario tem 60 linhas...
                        nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                        nLin += 1
                     Endif
                     If Empty(aImpAPr[nX][5])
                        If aImpAPr[nX][2] <> cAssunto
                           @ nLin, 011 PSAY "# Assunto: "+SubStr(Posicione("SX5", 1, xFilial("SX5")+"T1"+aImpApR[nX][2], "X5_DESCRI"), 1, 15)
                           @ nLin, 038 PSAY "# Ocorrên: "+Posicione("SU9", 1, xFilial("SU9")+aImpApR[nX][2]+aImpApR[nX][3], "U9_DESC")
                             nLin += 1
                           @ nLin, 011 PSAY "---------------------+----------------------+----------------------+"
                             nLin += 1
                           cAssunto := aImpAPr[nX][2]
                        Else
                           @ nLin, 049 PSAY Posicione("SU9", 1, xFilial("SU9")+aImpApR[nX][2]+aImpApR[nX][3], "U9_DESC")
                             nLin += 1
                           @ nLin, 011 PSAY "---------------------+----------------------+----------------------+"
                             nLin += 1
                        Endif
                        cOcorren := aImpAPr[nX][3]
                        nCol1 := 11
                        nCol2 := 27
                        nCol3 := 32
                        nTCol :=  1
                        For nZ := 1 To Len(aImpAPr)
                            If nLin > 60 // Salto de Página. Neste caso o formulario tem 60 linhas...
                               nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                               nLin += 1
                            Endif
                            If aImpAPr[nZ][2]+aImpAPr[nZ][3] == cAssunto+cOcorren
                               @ nLin, nCol1 PSAY aImpAPr[nZ][1] Picture "@R XX 99.99.999-99"
                               @ nLin, nCol2 PSAY aImpAPr[nZ][4] Picture "@E 9999"
                               @ nLin, nCol3 PSAY "|"
                               aImpAPr[nZ][5] := "S"
                               If nTCol < 3
                                  nTCol += 1 ; nCol1 += 23 ; nCol2 += 23; nCol3 += 23
                               Else
                                  nTCol := 1 ; nCol1 := 11 ; nCol2 := 27; nCol3 := 32 ; nLin += 1
                               Endif
                            Endif
                        Next
                        For nZ := nTCol To 3
                            @ nLin, nCol3 PSAY "|"
                              nCol3 += 23
                        Next
                        nLin += 1
                        @ nLin, 011 PSAY "---------------------+----------------------+----------------------+"
                          nLin += 1
                     Endif
                 Next
                 @ nLin, 000 PSAY Replicate("-", 80)
                   nLin += 1
                 If nLin > 60 // Salto de Página. Neste caso o formulario tem 60 linhas...
                    nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                    nLin += 1
                 Endif
             Next
             @ nLin, 000 PSAY Replicate("*", 80)
               nLin += 1
          Endif
       Endif
       //0         1         2         3         4         5         6         7         8
       //012345678901234567890123456789012345678901234567890123456789012345678901234567890
       //LINHA: 99                                                      ITENS| QTDE. SAC.
       //Assunto: 999999 - XXXXXXXXXXXXXXX                                   |
       //         Ocorrência: 999999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX - 9999 |       9999
       //                     999999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX - 9999 |
       
       SET DEVICE TO SCREEN
       If aReturn[5]==1
          DbCommitAll()
          SET PRINTER TO
          OurSpool(wnrel)
       Endif
       MS_FLUSH()
Return

/*********************************************************************************************************/
/*** Linhas                                                                                            ***/
/*********************************************************************************************************/
Static Function SACR06_2(aLinhas, aEspeci, aSACProc, aSACNPro, aSACSRes, aSACTota)
       Local aMatAux, nY
       If mv_par03 == 1 //Procedentes
          aMatAux := aSACProc
       ElseIf mv_par03 == 2 //Não Procedentes
              aMatAux := aSACNPro
       ElseIf mv_par03 == 3 //Sem Respostas
              aMatAux := aSACSRes
       ElseIf mv_par03 == 4 //Todos
              aMatAux := aSACTota
       ElseIf mv_par03 == 5
              Return
       Endif
       For nY := 1 To Len(aMatAux)
           IncRegua()
           cQry1 := ""
           cQry1 += "SELECT * "
           cQry1 += "FROM "+RetSQLName("SZR")+" SZR "
           cQry1 += "WHERE SZR.ZR_FILIAL = '"+xFilial("SZQ")+"' "
           cQry1 += "  AND SZR.D_E_L_E_T_ = '' "
           cQry1 += "  AND LEN(SZR.ZR_PRODUTO) = 12 "
           cQry1 += "  AND SZR.ZR_NUM = '"+aMatAux[nY]+"' "
           TCQuery cQry1 ALIAS "XTM" NEW
           DbSelectArea("XTM")
           DbGoTop()
           While !Eof()
                 If SubStr(XTM->ZR_PRODUTO, 1, 3) $ "DIV"
                    If aScan(aEspeci, {|x| x[1] == XTM->ZR_PRODUTO}) == 0
                       aadd(aEspeci, {XTM->ZR_PRODUTO, 1} )
                    Else
                       aEspeci[aScan(aEspeci, {|x| x[1] == XTM->ZR_PRODUTO})][2] += 1
                    Endif
                 Else
                    If Len(Alltrim(XTM->ZR_PRODUTO)) == 12
                       If aScan(aLinhas, {|x| x[1] == SubStr(XTM->ZR_PRODUTO, 4, 2)}) == 0
                          aadd(aLinhas, {SubStr(XTM->ZR_PRODUTO, 4, 2), 1} )
                       Else
                          aLinhas[aScan(aLinhas, {|x| x[1] == SubStr(XTM->ZR_PRODUTO, 4, 2)})][2] += 1
                       Endif
                    Endif
                 Endif
                 DbSelectArea("XTM")
                 DbSkip()
           EndDo
           DbSelectArea("XTM")
           DbCloseArea()
       Next
Return

/*********************************************************************************************************/
/*** Produtos                                                                                          ***/
/*********************************************************************************************************/
Static Function SACR06_3(aProdut, aEspeci, aSACProc, aSACNPro, aSACSRes, aSACTota, aLinhas)
       Local lIncEsp := .f.
       Local lIncLin := .f.
       Local aMatAux, nY
       If Len(aEspeci) > 0
          lIncEsp := .t.
       Endif
       If Len(aLinhas) == 0
          lIncLin := .t.
       Endif
       If mv_par04 == 1 //Procedentes
          aMatAux := aSACProc
       ElseIf mv_par04 == 2 //Não Procedentes
              aMatAux := aSACNPro
       ElseIf mv_par04 == 3 //Sem Respostas
              aMatAux := aSACSRes
       ElseIf mv_par04 == 4 //Todos
              aMatAux := aSACTota
       ElseIf mv_par04 == 5
              Return
       Endif
       For nY := 1 To Len(aMatAux)
           IncRegua()
           cQry1 := ""
           cQry1 += "SELECT * "
           cQry1 += "FROM "+RetSQLName("SZR")+" SZR "
           cQry1 += "WHERE SZR.ZR_FILIAL = '"+xFilial("SZQ")+"' "
           cQry1 += "  AND SZR.D_E_L_E_T_ = '' "
           cQry1 += "  AND SZR.ZR_NUM = '"+aMatAux[nY]+"' "
           TCQuery cQry1 ALIAS "XTM" NEW
           DbSelectArea("XTM")
           DbGoTop()
           While !Eof()
                 If SubStr(XTM->ZR_PRODUTO, 1, 3) $ "DIV"
                    If lIncEsp
                       If aScan(aEspeci, {|x| x[1] == XTM->ZR_PRODUTO}) == 0
                          aadd(aEspeci, {XTM->ZR_PRODUTO, 1} )
                       Else
                          aEspeci[aScan(aEspeci, {|x| x[1] == XTM->ZR_PRODUTO})][2] += 1
                       Endif
                    Endif
                 Else
                    If Len(Alltrim(XTM->ZR_PRODUTO)) == 12
                       If aScan(aProdut, {|x| x[1] == XTM->ZR_PRODUTO}) == 0
                          aadd(aProdut, {XTM->ZR_PRODUTO, 1} )
                       Else
                          aProdut[aScan(aProdut, {|x| x[1] == XTM->ZR_PRODUTO})][2] += 1
                       Endif
                       If lIncLin
                          If aScan(aLinhas, {|x| x[1] == SubStr(XTM->ZR_PRODUTO, 4, 2)}) == 0
                             aadd(aLinhas, {SubStr(XTM->ZR_PRODUTO, 4, 2), 1} )
                          Else
                             aLinhas[aScan(aLinhas, {|x| x[1] == SubStr(XTM->ZR_PRODUTO, 4, 2)})][2] += 1
                          Endif
                       Endif
                    Endif
                 Endif
                 DbSelectArea("XTM")
                 DbSkip()
           EndDo
           DbSelectArea("XTM")
           DbCloseArea()
       Next
Return

/*********************************************************************************************************/
/*** Linhas X Assuntos                                                                                 ***/
/*********************************************************************************************************/
Static Function SACR06_4(aLinhas, aLinAss, aSACProc, aSACNPro, aSACSRes, aSACTota)
       Local lIncLin := .f.
       Local aMatAux, nY
       If Len(aLinhas) == 0
          lIncLin := .t.
       Endif
       If mv_par05 == 1 //Procedentes
          aMatAux := aSACProc
       ElseIf mv_par05 == 2 //Não Procedentes
              aMatAux := aSACNPro
       ElseIf mv_par05 == 3 //Sem Respostas
              aMatAux := aSACSRes
       ElseIf mv_par05 == 4 //Todos
              aMatAux := aSACTota
       ElseIf mv_par05 == 5
              Return
       Endif
       For nY := 1 To Len(aMatAux)
           IncRegua()
           cQry1 := ""
           cQry1 += "SELECT * "
           cQry1 += "FROM "+RetSQLName("SZR")+" SZR "
           cQry1 += "WHERE SZR.ZR_FILIAL = '"+xFilial("SZQ")+"' "
           cQry1 += "  AND SZR.D_E_L_E_T_ = '' "
           cQry1 += "  AND SZR.ZR_NUM = '"+aMatAux[nY]+"' "
           TCQuery cQry1 ALIAS "XTM" NEW
           DbSelectArea("XTM")
           DbGoTop()
           While !Eof()
                 If Len(Alltrim(XTM->ZR_PRODUTO)) == 12
                    If aScan(aLinAss, {|x| x[1]+x[2]+x[3] == SubStr(XTM->ZR_PRODUTO, 4, 2)+XTM->ZR_ASSUNTO+XTM->ZR_OCORREN }) == 0
                       aadd(aLinAss, {SubStr(XTM->ZR_PRODUTO, 4, 2), XTM->ZR_ASSUNTO, XTM->ZR_OCORREN, 1 } )
                    Else
                       aLinAss[aScan(aLinAss, {|x| x[1]+x[2]+x[3] == SubStr(XTM->ZR_PRODUTO, 4, 2)+XTM->ZR_ASSUNTO+XTM->ZR_OCORREN })][4] += 1
                    Endif
                    If lIncLin
                       If aScan(aLinhas, {|x| x[1] == SubStr(XTM->ZR_PRODUTO, 4, 2)}) == 0
                          aadd(aLinhas, {SubStr(XTM->ZR_PRODUTO, 4, 2), 1} )
                       Else
                          aLinhas[aScan(aLinhas, {|x| x[1] == SubStr(XTM->ZR_PRODUTO, 4, 2)})][2] += 1
                       Endif
                    Endif
                 Endif
                 DbSelectArea("XTM")
                 DbSkip()
           EndDo
           DbSelectArea("XTM")
           DbCloseArea()
       Next
Return

/*********************************************************************************************************/
/*** Produtos X Assuntos
/*********************************************************************************************************/
Static Function SACR06_5(aLinhas, aProAss, aSACProc, aSACNPro, aSACSRes, aSACTota)
       Local lIncLin := .f.
       Local aMatAux, nY
       If Len(aLinhas) == 0
          lIncLin := .t.
       Endif
       If mv_par06 == 1 //Procedentes
          aMatAux := aSACProc
       ElseIf mv_par06 == 2 //Não Procedentes
              aMatAux := aSACNPro
       ElseIf mv_par06 == 3 //Sem Respostas
              aMatAux := aSACSRes
       ElseIf mv_par06 == 4 //Todos
              aMatAux := aSACTota
       ElseIf mv_par06 == 5
              Return
       Endif
       For nY := 1 To Len(aMatAux)
           IncRegua()
           cQry1 := ""
           cQry1 += "SELECT * "
           cQry1 += "FROM "+RetSQLName("SZR")+" SZR "
           cQry1 += "WHERE SZR.ZR_FILIAL = '"+xFilial("SZQ")+"' "
           cQry1 += "  AND SZR.D_E_L_E_T_ = '' "
           cQry1 += "  AND SZR.ZR_NUM = '"+aMatAux[nY]+"' "
           TCQuery cQry1 ALIAS "XTM" NEW
           DbSelectArea("XTM")
           DbGoTop()
           While !Eof()
                 If Len(Alltrim(XTM->ZR_PRODUTO)) == 12
                    If aScan(aProAss, {|x| x[1]+x[2]+x[3] == XTM->ZR_PRODUTO+XTM->ZR_ASSUNTO+XTM->ZR_OCORREN }) == 0
                       aadd(aProAss, {XTM->ZR_PRODUTO, XTM->ZR_ASSUNTO, XTM->ZR_OCORREN, 1, ""} )
                    Else
                       aProAss[aScan(aProAss, {|x| x[1]+x[2]+x[3] == XTM->ZR_PRODUTO+XTM->ZR_ASSUNTO+XTM->ZR_OCORREN })][4] += 1
                    Endif
                    If lIncLin
                       If aScan(aLinhas, {|x| x[1] == SubStr(XTM->ZR_PRODUTO, 4, 2)}) == 0
                          aadd(aLinhas, {SubStr(XTM->ZR_PRODUTO, 4, 2), 1} )
                       Else
                          aLinhas[aScan(aLinhas, {|x| x[1] == SubStr(XTM->ZR_PRODUTO, 4, 2)})][2] += 1
                       Endif
                    Endif
                 Endif
                 DbSelectArea("XTM")
                 DbSkip()
           EndDo
           DbSelectArea("XTM")
           DbCloseArea()
       Next
Return

/*******************************************************************************/
/*** VLDPERG - Ajusta perguntas com o SX1.                                   ***/
/*******************************************************************************/
//LGS#20200211 - Adequação de release 12.1.25 e posteriores
/*Static Function VldPerg()
       Local aHelp1 := {} ; Local aHelp2 := {} ; Local aHelp3 := {} ; Local aHelp4 := {} ; Local aHelp5 := {}
       aAdd( aHelp1, "Informe o periodo desejado para a  " )
       aAdd( aHelp1, "emissão do relatório.              " )
       aAdd( aHelp2, "Informe a condição para as linhas  " )
       aAdd( aHelp2, "quanto aos SAC's.                  " )
       aAdd( aHelp3, "Informe a condição para os produtos" )
       aAdd( aHelp3, "quanto aos SAC's.                  " )
       aAdd( aHelp4, "Informe a condição para as linhas X" )
       aAdd( aHelp4, "assuntos quanto aos SAC's.         " )
       aAdd( aHelp5, "Informe a condição para os produtos" )
       aAdd( aHelp5, "X assuntos quanto aos SAC's.       " )
     //PutSx1(cGrupo  , cOrdem,   cPergunt            , cPerSpa, cPerEng, cVar    , cTipo, nTamanho, nDecimal, nPresel, cGSC, cValid, cF3, cGrpSxg, cPyme, cVar01    , cDef01       , cDefSpa1, cDefEng1, cCnt01, cDef02          , cDefSpa2, cDefEng2, cDef03        , cDefSpa3, cDefEng3, cDef04 , cDefSpa4, cDefEng4, cDef05       ,  cDefSpa5,  cDefEng5, aHelpPor, aHelpEng, aHelpSpa, cHelp    )
       PutSX1("SACR06    ", "01"  ,   "Do Periodo        ", ""     , ""     , "mv_ch1", "D"  , 8       , 0       , 0      , "G" , " "   , " ", " "    , " "  , "mv_par01", " "          , " "     , " "     , " "   , " "             , " "     , " "     , " "           , " "     , " "     , " "    , " "     , " "     , " "          ,  " "     ,  " "     , aHelp1  , Nil     , Nil     , "SACR06" )
       PutSX1("SACR06    ", "02"  ,   "Até Periodo       ", ""     , ""     , "mv_ch2", "D"  , 8       , 0       , 0      , "G" , " "   , " ", " "    , " "  , "mv_par02", " "          , " "     , " "     , " "   , " "             , " "     , " "     , " "           , " "     , " "     , " "    , " "     , " "     , " "          ,  " "     ,  " "     , aHelp1  , Nil     , Nil     , "SACR06" )
       PutSX1("SACR06    ", "03"  ,   "Linhas            ", ""     , ""     , "mv_ch3", "N"  , 1       , 0       , 1      , "C" , " "   , " ", " "    , " "  , "mv_par03", "Procedentes", " "     , " "     , " "   , "Não Procedente", " "     , " "     , "Sem Resposta", " "     , " "     , "Todas", " "     , " "     , "Não Imprime",  " "     ,  " "     , aHelp2  , Nil     , Nil     , "SACR06" )
       PutSX1("SACR06    ", "04"  ,   "Produtos          ", ""     , ""     , "mv_ch4", "N"  , 1       , 0       , 1      , "C" , " "   , " ", " "    , " "  , "mv_par04", "Procedentes", " "     , " "     , " "   , "Não Procedente", " "     , " "     , "Sem Resposta", " "     , " "     , "Todas", " "     , " "     , "Não Imprime",  " "     ,  " "     , aHelp3  , Nil     , Nil     , "SACR06" )
       PutSX1("SACR06    ", "05"  ,   "Linhas x Assunto  ", ""     , ""     , "mv_ch5", "N"  , 1       , 0       , 1      , "C" , " "   , " ", " "    , " "  , "mv_par05", "Procedentes", " "     , " "     , " "   , "Não Procedente", " "     , " "     , "Sem Resposta", " "     , " "     , "Todas", " "     , " "     , "Não Imprime",  " "     ,  " "     , aHelp4  , Nil     , Nil     , "SACR06" )
       PutSX1("SACR06    ", "06"  ,   "Produtos x Assunto", ""     , ""     , "mv_ch6", "N"  , 1       , 0       , 1      , "C" , " "   , " ", " "    , " "  , "mv_par06", "Procedentes", " "     , " "     , " "   , "Não Procedente", " "     , " "     , "Sem Resposta", " "     , " "     , "Todas", " "     , " "     , "Não Imprime",  " "     ,  " "     , aHelp5  , Nil     , Nil     , "SACR06" )
Return*/