#include "rwmake.ch"
#include "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRPCPX05 º Autor ³ Luís Gustavo de S. º Data ³  06/12/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Demonstrativo de Produção.                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRPCPX05()
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "            Demonstrativo de Produção.              "
     //Local cPict         := ""
     Local titulo        := "Demonstrativo de Produção: "
     Local nLin          := 80
     Local Cabec1        := ""
     Local Cabec2        := ""
     Local Cabec3        := ""
     Local Cabec4        := ""
     //Local imprime       := .T.
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     //Private CbTxt       := ""
     Private limite      := 220
     Private tamanho     := "G"
     Private nomeprog    := "BRPCPX05" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 15
     Private aReturn     := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := "PCPX05"
     Private cbtxt       := Space(10)
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRPCPX05" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString     := "SZE"

     DbSelectArea("SZE")
     DbSetOrder(1)
     
     //ValPerg()  //LGS#20200204 - Adequação de release 12.1.25 e posteriores
     Pergunte(cPerg,.F.)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Monta a interface padrao com o usuario...                           ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

     If nLastKey == 27
        Return
     Endif

     SetDefault(aReturn,cString)

     If nLastKey == 27
        Return
     Endif

     nTipo := If(aReturn[4]==1,15,18)

     Processa({|| PCPX05_1(Cabec1, Cabec2, Titulo, nLin, Cabec3, Cabec4) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ PCPX05_1 º Autor ³ AP6 IDE            º Data ³  06/12/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PCPX05_1(Cabec1, Cabec2, Titulo, nLin, Cabec3, Cabec4)
       Local aPastas := {}
       Local aPasTot := {}
       Local aTintas := {}
       Local aTinTot := {}
       Local aEnvase := {}
       Local aEnvTot := {}
       Local aDiaMes := {}
       Local cMesRel := StrZero(mv_par04, 2)
       Local cAnoRel := mv_par05
       Local cPul01  := ""
       Local cPul02  := ""
       Local nQtdFol := 0
       Local nZ, nX, nY

       cQry1 := ""
       If mv_par01 == 1
          cQry1 += "SELECT COUNT(*) AS QTDREC FROM sysobjects WHERE name = 'PRO_MAT_"+cAnoRel+cMesRel+"' "
          TCQuery cQry1 NEW ALIAS "TCQ"
          DbSelectArea("TCQ")
          If TCQ->QTDREC <= 0
             MsgBox("O objeto: PRO_MAT_"+cAnoRel+cMesRel+" não existe no Banco de Dados. Verifique !", "Atenção", "STOP")
             DbSelectArea("TCQ")
             DbCloseArea()
             Return
          Else
             DbSelectArea("TCQ")
             DbCloseArea()
          Endif
       ElseIf mv_par01 == 2
              cQry1 += "SELECT COUNT(*) AS QTDREC FROM sysobjects "
              cQry1 += "WHERE name IN('PRO_MAT_"+cAnoRel+"01','PRO_MAT_"+cAnoRel+"02','PRO_MAT_"+cAnoRel+"03', "
              cQry1 += "              'PRO_MAT_"+cAnoRel+"04','PRO_MAT_"+cAnoRel+"05','PRO_MAT_"+cAnoRel+"06', "
              cQry1 += "              'PRO_MAT_"+cAnoRel+"07','PRO_MAT_"+cAnoRel+"08','PRO_MAT_"+cAnoRel+"09', "
              cQry1 += "              'PRO_MAT_"+cAnoRel+"10','PRO_MAT_"+cAnoRel+"11','PRO_MAT_"+cAnoRel+"12') "
              TCQuery cQry1 NEW ALIAS "TCQ"
              DbSelectArea("TCQ")
              If TCQ->QTDREC <> 12
                 MsgBox("O objeto: PRO_MAT_"+cAnoRel+"MM não existe no Banco de Dados. Verifique !", "Atenção", "STOP")
                 DbSelectArea("TCQ")
                 DbCloseArea()
                 Return
              Else
                 DbSelectArea("TCQ")
                 DbCloseArea()
              Endif
       Else
       
       Endif
       
       fMonCab(@aDiaMes, @Cabec1, @Cabec2, @Cabec3, @Cabec4, cMesRel, cAnoRel, @cPul01, @cPul02, @nQtdFol) //Monta Cabeçalho
       If mv_par01 == 1
          aadd(aPasTot, { "TOTAL ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
          aadd(aTinTot, { "TOTAL ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
          aadd(aEnvTot, { "TOTAL ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
          cQry1 := "" ; cQry2 := "" ; cQry3 := ""
          cQry1 += "SELECT * "
          cQry2 += "SELECT COUNT(*) AS QTDREC "
          cQry3 += "FROM PRO_MAT_"+cAnoRel+cMesRel+" PRO "
          cQry1 += cQry3
          cQry1 += "ORDER BY PRO.D3_EMISSAO, PRO.D3_TURNO "
          cQry2 += cQry3
          TCQuery cQry1 NEW ALIAS "TCQ"
          TCQuery cQry2 NEW ALIAS "QTD"

          DbSelectArea("QTD")
          ProcRegua(QTD->QTDREC)
          DbSelectArea("QTD")
          DbCloseArea()
          
          DbSelectArea("TCQ")
          DbGoTop()
          While !Eof()
                IncProc()
                nPosCol := aScan(aDiaMes, {|x| x[1] == TCQ->D3_EMISSAO}) + 1
                If Len(Alltrim(TCQ->D3_COD)) == 4 //Pastas
                       If aScan(aPastas, {|x| x[1] == TCQ->D3_TURNO}) == 0
                          aadd(aPastas, { TCQ->D3_TURNO, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } )
                          nPosLin := aScan(aPastas, {|x| x[1] == TCQ->D3_TURNO})
                          aPastas[nPosLin][nPosCol] += TCQ->D3_QUANT
                          aPasTot[01][nPosCol]      += TCQ->D3_QUANT
                          aPastas[nPosLin][33]      += TCQ->D3_QUANT
                          aPasTot[01][33]           += TCQ->D3_QUANT
                       Else
                          nPosLin := aScan(aPastas, {|x| x[1] == TCQ->D3_TURNO})
                          aPastas[nPosLin][nPosCol] += TCQ->D3_QUANT
                          aPasTot[01][nPosCol]      += TCQ->D3_QUANT
                          aPastas[nPosLin][33]      += TCQ->D3_QUANT
                          aPasTot[01][33]           += TCQ->D3_QUANT
                       Endif
                ElseIf SubStr(Alltrim(TCQ->D3_COD), 11, 2) == '00' //Tintas
                       If aScan(aTintas, {|x| x[1] == TCQ->D3_TURNO}) == 0
                          aadd(aTintas, { TCQ->D3_TURNO, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } )
                          nPosLin := aScan(aTintas, {|x| x[1] == TCQ->D3_TURNO})
                          aTintas[nPosLin][nPosCol] += TCQ->D3_QUANT
                          aTinTot[01][nPosCol]      += TCQ->D3_QUANT
                          aTintas[nPosLin][33]      += TCQ->D3_QUANT
                          aTinTot[01][33]           += TCQ->D3_QUANT
                       Else
                          nPosLin := aScan(aTintas, {|x| x[1] == TCQ->D3_TURNO})
                          aTintas[nPosLin][nPosCol] += TCQ->D3_QUANT
                          aTinTot[01][nPosCol]      += TCQ->D3_QUANT
                          aTintas[nPosLin][33]      += TCQ->D3_QUANT
                          aTinTot[01][33]           += TCQ->D3_QUANT
                       Endif
                Else //Envase
                       If aScan(aEnvase, {|x| x[1] == TCQ->D3_TURNO}) == 0
                          aadd(aEnvase, { TCQ->D3_TURNO, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } )
                          nPosLin := aScan(aEnvase, {|x| x[1] == TCQ->D3_TURNO})
                          aEnvase[nPosLin][nPosCol] += TCQ->D3_QUANT * Posicione("SZ5", 1, xFilial("SZ5")+SubStr(Alltrim(TCQ->D3_COD), 11, 2), "Z5_VOLUME")
                          aEnvTot[01][nPosCol]      += TCQ->D3_QUANT * Posicione("SZ5", 1, xFilial("SZ5")+SubStr(Alltrim(TCQ->D3_COD), 11, 2), "Z5_VOLUME")
                          aEnvase[nPosLin][33]      += TCQ->D3_QUANT * Posicione("SZ5", 1, xFilial("SZ5")+SubStr(Alltrim(TCQ->D3_COD), 11, 2), "Z5_VOLUME")
                          aEnvTot[01][33]           += TCQ->D3_QUANT * Posicione("SZ5", 1, xFilial("SZ5")+SubStr(Alltrim(TCQ->D3_COD), 11, 2), "Z5_VOLUME")
                       Else
                          nPosLin := aScan(aEnvase, {|x| x[1] == TCQ->D3_TURNO})
                          aEnvase[nPosLin][nPosCol] += TCQ->D3_QUANT * Posicione("SZ5", 1, xFilial("SZ5")+SubStr(Alltrim(TCQ->D3_COD), 11, 2), "Z5_VOLUME")
                          aEnvTot[01][nPosCol]      += TCQ->D3_QUANT * Posicione("SZ5", 1, xFilial("SZ5")+SubStr(Alltrim(TCQ->D3_COD), 11, 2), "Z5_VOLUME")
                          aEnvase[nPosLin][33]      += TCQ->D3_QUANT * Posicione("SZ5", 1, xFilial("SZ5")+SubStr(Alltrim(TCQ->D3_COD), 11, 2), "Z5_VOLUME")
                          aEnvTot[01][33]           += TCQ->D3_QUANT * Posicione("SZ5", 1, xFilial("SZ5")+SubStr(Alltrim(TCQ->D3_COD), 11, 2), "Z5_VOLUME")
                       Endif
                Endif
                DbSelectArea("TCQ")
                DbSkip()
          Enddo
          DbSelectArea("TCQ")
          DbCloseArea()
       ElseIf mv_par01 == 2
              aadd(aPasTot, { "TOTAL ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
              aadd(aTinTot, { "TOTAL ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
              aadd(aEnvTot, { "TOTAL ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
              For nZ := 1 To 12
                  cQry1 := "" ; cQry2 := "" ; cQry3 := ""
                  cQry1 += "SELECT * "
                  cQry2 += "SELECT COUNT(*) AS QTDREC "
                  cQry3 += "FROM PRO_MAT_"+cAnoRel+StrZero(nZ,2)+" PRO "
                  cQry1 += cQry3
                  cQry1 += "ORDER BY PRO.D3_EMISSAO, PRO.D3_TURNO "
                  cQry2 += cQry3
                  TCQuery cQry1 NEW ALIAS "TCQ"
                  TCQuery cQry2 NEW ALIAS "QTD"

                  DbSelectArea("QTD")
                  ProcRegua(QTD->QTDREC)
                  DbSelectArea("QTD")
                  DbCloseArea()
          
                  DbSelectArea("TCQ")
                  DbGoTop()
                  While !Eof()
                        IncProc("Processando "+MesExtenso(nZ)+"...")
                        nPosCol := nZ + 1
                        If Len(Alltrim(TCQ->D3_COD)) == 4 //Pastas
                           If aScan(aPastas, {|x| x[1] == TCQ->D3_TURNO}) == 0
                              aadd(aPastas, { TCQ->D3_TURNO, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } )
                              nPosLin := aScan(aPastas, {|x| x[1] == TCQ->D3_TURNO})
                              aPastas[nPosLin][nPosCol] += TCQ->D3_QUANT
                              aPasTot[01][nPosCol]      += TCQ->D3_QUANT
                              aPastas[nPosLin][14]      += TCQ->D3_QUANT
                              aPasTot[01][14]           += TCQ->D3_QUANT
                           Else
                              nPosLin := aScan(aPastas, {|x| x[1] == TCQ->D3_TURNO})
                              aPastas[nPosLin][nPosCol] += TCQ->D3_QUANT
                              aPasTot[01][nPosCol]      += TCQ->D3_QUANT
                              aPastas[nPosLin][14]      += TCQ->D3_QUANT
                              aPasTot[01][14]           += TCQ->D3_QUANT
                           Endif
                        ElseIf SubStr(Alltrim(TCQ->D3_COD), 11, 2) == '00' //Tintas
                               If aScan(aTintas, {|x| x[1] == TCQ->D3_TURNO}) == 0
                                  aadd(aTintas, { TCQ->D3_TURNO, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } )
                                  nPosLin := aScan(aTintas, {|x| x[1] == TCQ->D3_TURNO})
                                  aTintas[nPosLin][nPosCol] += TCQ->D3_QUANT
                                  aTinTot[01][nPosCol]      += TCQ->D3_QUANT
                                  aTintas[nPosLin][14]      += TCQ->D3_QUANT
                                  aTinTot[01][14]           += TCQ->D3_QUANT
                               Else
                                  nPosLin := aScan(aTintas, {|x| x[1] == TCQ->D3_TURNO})
                                  aTintas[nPosLin][nPosCol] += TCQ->D3_QUANT
                                  aTinTot[01][nPosCol]      += TCQ->D3_QUANT
                                  aTintas[nPosLin][14]      += TCQ->D3_QUANT
                                  aTinTot[01][14]           += TCQ->D3_QUANT
                               Endif
                        Else
                           If aScan(aEnvase, {|x| x[1] == TCQ->D3_TURNO}) == 0
                              aadd(aEnvase, { TCQ->D3_TURNO, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } )
                              nPosLin := aScan(aEnvase, {|x| x[1] == TCQ->D3_TURNO})
                              aEnvase[nPosLin][nPosCol] += TCQ->D3_QUANT * Posicione("SZ5", 1, xFilial("SZ5")+SubStr(Alltrim(TCQ->D3_COD), 11, 2), "Z5_VOLUME")
                              aEnvTot[01][nPosCol]      += TCQ->D3_QUANT * Posicione("SZ5", 1, xFilial("SZ5")+SubStr(Alltrim(TCQ->D3_COD), 11, 2), "Z5_VOLUME")
                              aEnvase[nPosLin][14]      += TCQ->D3_QUANT * Posicione("SZ5", 1, xFilial("SZ5")+SubStr(Alltrim(TCQ->D3_COD), 11, 2), "Z5_VOLUME")
                              aEnvTot[01][14]           += TCQ->D3_QUANT * Posicione("SZ5", 1, xFilial("SZ5")+SubStr(Alltrim(TCQ->D3_COD), 11, 2), "Z5_VOLUME")
                           Else
                              nPosLin := aScan(aEnvase, {|x| x[1] == TCQ->D3_TURNO})
                              aEnvase[nPosLin][nPosCol] += TCQ->D3_QUANT * Posicione("SZ5", 1, xFilial("SZ5")+SubStr(Alltrim(TCQ->D3_COD), 11, 2), "Z5_VOLUME")
                              aEnvTot[01][nPosCol]      += TCQ->D3_QUANT * Posicione("SZ5", 1, xFilial("SZ5")+SubStr(Alltrim(TCQ->D3_COD), 11, 2), "Z5_VOLUME")
                              aEnvase[nPosLin][14]      += TCQ->D3_QUANT * Posicione("SZ5", 1, xFilial("SZ5")+SubStr(Alltrim(TCQ->D3_COD), 11, 2), "Z5_VOLUME")
                              aEnvTot[01][14]           += TCQ->D3_QUANT * Posicione("SZ5", 1, xFilial("SZ5")+SubStr(Alltrim(TCQ->D3_COD), 11, 2), "Z5_VOLUME")
                           Endif
                        Endif
                        DbSelectArea("TCQ")
                        DbSkip()
                  Enddo
                  DbSelectArea("TCQ")
                  DbCloseArea()
              Next
       Else
       
       Endif
       /**********************************************************************************************************/
       /*** IMPRESSÃO DO RELATÓRIO                                                                             ***/
       /**********************************************************************************************************/
       If mv_par01 == 1
          ProcRegua(Len(aPastas)+Len(aTintas)+Len(aEnvase))
          aSort(aPastas,,, {|x,y| x[1] < y[1]})
          aSort(aTintas,,, {|x,y| x[1] < y[1]})
          aSort(aEnvase,,, {|x,y| x[1] < y[1]})
          If (Len(aPastas)+Len(aTintas)+Len(aEnvase)) > 0
             For nZ := 1 To nQtdFol
                 Titulo  := Alltrim(Titulo)+' '+Alltrim(mv_par05)+' - Diário'
                 If nQtdFol > 1
                    nColIni := Iif(nZ == 1,     02,           17  )
                    nColFim := Iif(nZ == 1,     16, Len(aDiaMes)+1)
                 Else
                    nColIni := 02
                    nColFim := Len(aDiaMes)+1
                 Endif
                 cPulLin := Iif(nZ == 1, cPul01, cPul02        )
                 If nZ == 1
                    nLin := 0 ; nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo) ; nLin += 1
                 Else
                    nLin := 0 ; nLin := Cabec(Titulo, Cabec3, Cabec4, NomeProg, Tamanho, nTipo) ; nLin += 1
                 Endif
                 /****************************************************************************************************/
                 /***                                     IMPRESSÃO DAS PASTAS                                     ***/
                 /****************************************************************************************************/
                 @ nLin, 000 PSAY "PASTAS / SOLUÇÕES"
                   nLin += 1
                 @ nLin, 000 PSAY cPulLin
                   nLin += 1
                 For nY := 1 To Len(aPastas)
                     IncProc("Imprimindo pastas/soluções...")
                     @ nLin, 000   PSAY aPastas[nY][01] Picture "999"
                     If nZ == 1
                        @ nLin, 003   PSAY "- "+SubStr(Alltrim(Posicione("SR6", 1, xFilial("SR6")+aPastas[nY][1], "R6_DESC")), 1, 18)
                        nCol1 := 24 ; nCol2 := 26
                     Else
                        nCol1 := 06 ; nCol2 := 08
                     Endif
                     For nX := nColIni To nColFim
                         @ nLin, nCol1 PSAY "|"
                         @ nLin, nCol2 PSAY aPastas[nY][nX] Picture "@E 999,999.99"
                         nCol1 += 13; nCol2 += 13
                     Next
                     @ nLin, nCol1 PSAY "|"
                     If nQtdFol == nZ
                        nCol1 += 13
                        @ nLin, nCol2 PSAY aPastas[nY][33] Picture "@E 999,999.99"
                        @ nLin, nCol1 PSAY "|"
                     Endif
                     nLin += 1
                 Next
                 @ nLin, 000 PSAY cPulLin
                   nLin += 1
                 @ nLin, 000   PSAY aPasTot[1][1] Picture "@!"
                 nCol1 := Iif(nZ == 1, 24, 06)
                 nCol2 := Iif(nZ == 1, 26, 08)
                 For nX := nColIni To nColFim
                     @ nLin, nCol1 PSAY "|"
                     @ nLin, nCol2 PSAY aPasTot[1][nX] Picture "@E 999,999.99"
                     nCol1 += 13; nCol2 += 13
                 Next
                 @ nLin, nCol1 PSAY "|"
                 If nQtdFol == nZ
                    nCol1 += 13
                    @ nLin, nCol2 PSAY aPasTot[1][33] Picture "@E 999,999.99"
                    @ nLin, nCol1 PSAY "|"
                 Endif
                 nLin += 1
                 @ nLin, 000 PSAY cPulLin
                 nLin += 2
                 /****************************************************************************************************/
                 /***                                     IMPRESSÃO DAS TINTAS                                     ***/
                 /****************************************************************************************************/
                 @ nLin, 000 PSAY "TINTAS"
                   nLin += 1
                 @ nLin, 000 PSAY cPulLin
                   nLin += 1
                 For nY := 1 To Len(aTintas)
                     IncProc("Imprimindo Tintas...")
                     @ nLin, 000   PSAY aTintas[nY][01] Picture "999"
                     If nZ == 1
                        @ nLin, 003   PSAY "- "+SubStr(Alltrim(Posicione("SR6", 1, xFilial("SR6")+aTintas[nY][1], "R6_DESC")), 1, 18)
                        nCol1 := 24 ; nCol2 := 26
                     Else
                        nCol1 := 06 ; nCol2 := 08
                     Endif
                     For nX := nColIni To nColFim
                         @ nLin, nCol1 PSAY "|"
                         @ nLin, nCol2 PSAY aTintas[nY][nX] Picture "@E 999,999.99"
                         nCol1 += 13; nCol2 += 13
                     Next
                     @ nLin, nCol1 PSAY "|"
                     If nQtdFol == nZ
                        nCol1 += 13
                        @ nLin, nCol2 PSAY aTintas[nY][33] Picture "@E 999,999.99"
                        @ nLin, nCol1 PSAY "|"
                     Endif
                     nLin += 1
                 Next
                 @ nLin, 000 PSAY cPulLin
                   nLin += 1
                 @ nLin, 000   PSAY aTinTot[1][1] Picture "@!"
                 nCol1 := Iif(nZ == 1, 24, 06)
                 nCol2 := Iif(nZ == 1, 26, 08)
                 For nX := nColIni To nColFim
                     @ nLin, nCol1 PSAY "|"
                     @ nLin, nCol2 PSAY aTinTot[1][nX] Picture "@E 999,999.99"
                     nCol1 += 13; nCol2 += 13
                 Next
                 @ nLin, nCol1 PSAY "|"
                 If nQtdFol == nZ
                    nCol1 += 13
                    @ nLin, nCol2 PSAY aTinTot[1][33] Picture "@E 999,999.99"
                    @ nLin, nCol1 PSAY "|"
                 Endif
                 nLin += 1
                 @ nLin, 000 PSAY cPulLin
                 nLin += 2
                 /****************************************************************************************************/
                 /***                                     IMPRESSÃO DOS ENVASES                                    ***/
                 /****************************************************************************************************/
                 @ nLin, 000 PSAY "ENVASE"
                   nLin += 1
                 @ nLin, 000 PSAY cPulLin
                   nLin += 1
                 For nY := 1 To Len(aEnvase)
                     IncProc("Imprimindo envase...")
                     @ nLin, 000   PSAY aEnvase[nY][01] Picture "999"
                     If nZ == 1
                        @ nLin, 003   PSAY "- "+SubStr(Alltrim(Posicione("SR6", 1, xFilial("SR6")+aEnvase[nY][1], "R6_DESC")), 1, 18)
                        nCol1 := 24 ; nCol2 := 26
                     Else
                        nCol1 := 06 ; nCol2 := 08
                     Endif
                     For nX := nColIni To nColFim
                         @ nLin, nCol1 PSAY "|"
                         @ nLin, nCol2 PSAY aEnvase[nY][nX] Picture "@E 999,999.99"
                         nCol1 += 13; nCol2 += 13
                     Next
                     @ nLin, nCol1 PSAY "|"
                     If nQtdFol == nZ
                        nCol1 += 13
                        @ nLin, nCol2 PSAY aEnvase[nY][33] Picture "@E 999,999.99"
                        @ nLin, nCol1 PSAY "|"
                     Endif
                     nLin += 1
                 Next
                 @ nLin, 000 PSAY cPulLin
                   nLin += 1
                 @ nLin, 000   PSAY aEnvTot[1][1] Picture "@!"
                 nCol1 := Iif(nZ == 1, 24, 06)
                 nCol2 := Iif(nZ == 1, 26, 08)
                 For nX := nColIni To nColFim
                     @ nLin, nCol1 PSAY "|"
                     @ nLin, nCol2 PSAY aEnvTot[1][nX] Picture "@E 999,999.99"
                     nCol1 += 13; nCol2 += 13
                 Next
                 @ nLin, nCol1 PSAY "|"
                 If nQtdFol == nZ
                    nCol1 += 13
                    @ nLin, nCol2 PSAY aEnvTot[1][33] Picture "@E 999,999.99"
                    @ nLin, nCol1 PSAY "|"
                 Endif
                 nLin += 1
                 @ nLin, 000 PSAY cPulLin
                 nLin += 2
             Next
          Endif
       ElseIf mv_par01 == 2
              ProcRegua(Len(aPastas)+Len(aTintas)+Len(aEnvase))
              aSort(aPastas,,, {|x,y| x[1] < y[1]})
              aSort(aTintas,,, {|x,y| x[1] < y[1]})
              aSort(aEnvase,,, {|x,y| x[1] < y[1]})
              If (Len(aPastas)+Len(aTintas)+Len(aEnvase)) > 0
                 Titulo  := Alltrim(Titulo)+' '+Alltrim(mv_par05)+' - Mensal'
                 nLin := 0 ; nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo) ; nLin += 1
                 cPulLin := cPul01
                 /****************************************************************************************************/
                 /***                                     IMPRESSÃO DAS PASTAS                                     ***/
                 /****************************************************************************************************/
                 @ nLin, 000 PSAY "PASTAS / SOLUÇÕES"
                   nLin += 1
                 @ nLin, 000 PSAY cPulLin
                   nLin += 1
                 For nY := 1 To Len(aPastas)
                     IncProc("Imprimindo pastas/soluções...")
                     @ nLin, 000   PSAY aPastas[nY][01] Picture "999"
                     @ nLin, 003   PSAY "- "+SubStr(Alltrim(Posicione("SR6", 1, xFilial("SR6")+aPastas[nY][1], "R6_DESC")), 1, 18)
                     nCol1 := 24 ; nCol2 := 26
                     For nX := 2 To 13
                         @ nLin, nCol1 PSAY "|"
                         @ nLin, nCol2 PSAY aPastas[nY][nX] Picture "@E 9,999,999.99"
                         nCol1 += 15; nCol2 += 15
                     Next
                     @ nLin, nCol1 PSAY "|"
                     @ nLin, nCol2 PSAY aPastas[nY][nX] Picture "@E 9,999,999.99"
                     @ nLin, 219   PSAY "|"
                       nLin += 1
                 Next
                 @ nLin, 000 PSAY cPulLin
                   nLin += 1
                 @ nLin, 000   PSAY aPasTot[1][1] Picture "@!"
                 nCol1 := 24 ; nCol2 := 26
                 For nX := 2 To 13
                     @ nLin, nCol1 PSAY "|"
                     @ nLin, nCol2 PSAY aPasTot[1][nX] Picture "@E 9,999,999.99"
                     nCol1 += 15; nCol2 += 15
                 Next
                 @ nLin, nCol1 PSAY "|"
                 @ nLin, nCol2 PSAY aPasTot[1][14] Picture "@E 9,999,999.99"
                 @ nLin, 219   PSAY "|"
                   nLin += 1
                 @ nLin, 000 PSAY cPulLin
                   nLin += 2
                 /****************************************************************************************************/
                 /***                                     IMPRESSÃO DAS TINTAS                                     ***/
                 /****************************************************************************************************/
                 @ nLin, 000 PSAY "TINTAS"
                   nLin += 1
                 @ nLin, 000 PSAY cPulLin
                   nLin += 1
                 For nY := 1 To Len(aPastas)
                     IncProc("Imprimindo tintas...")
                     @ nLin, 000   PSAY aTintas[nY][01] Picture "999"
                     @ nLin, 003   PSAY "- "+SubStr(Alltrim(Posicione("SR6", 1, xFilial("SR6")+aTintas[nY][1], "R6_DESC")), 1, 18)
                     nCol1 := 24 ; nCol2 := 26
                     For nX := 2 To 13
                         @ nLin, nCol1 PSAY "|"
                         @ nLin, nCol2 PSAY aTintas[nY][nX] Picture "@E 9,999,999.99"
                         nCol1 += 15; nCol2 += 15
                     Next
                     @ nLin, nCol1 PSAY "|"
                     @ nLin, nCol2 PSAY aTintas[nY][nX] Picture "@E 9,999,999.99"
                     @ nLin, 219   PSAY "|"
                       nLin += 1
                 Next
                 @ nLin, 000 PSAY cPulLin
                   nLin += 1
                 @ nLin, 000   PSAY aTinTot[1][1] Picture "@!"
                 nCol1 := 24 ; nCol2 := 26
                 For nX := 2 To 13
                     @ nLin, nCol1 PSAY "|"
                     @ nLin, nCol2 PSAY aTinTot[1][nX] Picture "@E 9,999,999.99"
                     nCol1 += 15; nCol2 += 15
                 Next
                 @ nLin, nCol1 PSAY "|"
                 @ nLin, nCol2 PSAY aTinTot[1][14] Picture "@E 9,999,999.99"
                 @ nLin, 219   PSAY "|"
                   nLin += 1
                 @ nLin, 000 PSAY cPulLin
                   nLin += 2
                 /****************************************************************************************************/
                 /***                                     IMPRESSÃO DOS ENVASES                                    ***/
                 /****************************************************************************************************/
                 @ nLin, 000 PSAY "ENVASE"
                   nLin += 1
                 @ nLin, 000 PSAY cPulLin
                   nLin += 1
                 For nY := 1 To Len(aEnvase)
                     IncProc("Imprimindo tintas...")
                     @ nLin, 000   PSAY aEnvase[nY][01] Picture "999"
                     @ nLin, 003   PSAY "- "+SubStr(Alltrim(Posicione("SR6", 1, xFilial("SR6")+aEnvase[nY][1], "R6_DESC")), 1, 18)
                     nCol1 := 24 ; nCol2 := 26
                     For nX := 2 To 13
                         @ nLin, nCol1 PSAY "|"
                         @ nLin, nCol2 PSAY aEnvase[nY][nX] Picture "@E 9,999,999.99"
                         nCol1 += 15; nCol2 += 15
                     Next
                     @ nLin, nCol1 PSAY "|"
                     @ nLin, nCol2 PSAY aEnvase[nY][nX] Picture "@E 9,999,999.99"
                     @ nLin, 219   PSAY "|"
                       nLin += 1
                 Next
                 @ nLin, 000 PSAY cPulLin
                   nLin += 1
                 @ nLin, 000   PSAY aEnvTot[1][1] Picture "@!"
                 nCol1 := 24 ; nCol2 := 26
                 For nX := 2 To 13
                     @ nLin, nCol1 PSAY "|"
                     @ nLin, nCol2 PSAY aEnvTot[1][nX] Picture "@E 9,999,999.99"
                     nCol1 += 15; nCol2 += 15
                 Next
                 @ nLin, nCol1 PSAY "|"
                 @ nLin, nCol2 PSAY aEnvTot[1][14] Picture "@E 9,999,999.99"
                 @ nLin, 219   PSAY "|"
                   nLin += 1
                 @ nLin, 000 PSAY cPulLin
                   nLin += 2
              Endif
       Else
       Endif

       SET DEVICE TO SCREEN

       If aReturn[5]==1
          dbCommitAll()
          SET PRINTER TO
          OurSpool(wnrel)
       Endif

       MS_FLUSH()

Return

/******************************************************************************************************************/
/***                                        MONTA CABEÇALHO DO RELATÓRIO                                        ***/
/******************************************************************************************************************/
Static Function fMonCab(aDiaMes, Cabec1, Cabec2, Cabec3, Cabec4, cMesRel, cAnoRel, cPul01, cPul02, nQtdFol)
       If mv_par01 == 1 //Diário
          Cabec1 := "TIPO DO PRODUTO  "
          Cabec2 := "TURNO                   | "
          cPul01 := "------------------------|"
          Cabec3 := "TIPO DO PRODUTO  "
          Cabec4 := "TURNO | "
          cPul02 := "------|"
          cQry1  := ""
          cQry1  += "SELECT D3_EMISSAO "
          cQry1  += "FROM PRO_MAT_"+cAnoRel+cMesRel+" "
          cQry1  += "GROUP BY D3_EMISSAO "
          cQry1  += "ORDER BY D3_EMISSAO "
          TCQUery cQry1 ALIAS "TCQ" NEW
          nCont := 1
          DbSelectArea("TCQ")
          DbGoTop()
          While !Eof()
                If nCont <= 15
                   Cabec2 += "DIA  "+SubStr(TCQ->D3_EMISSAO, 7, 2)+"/"+SubStr(TCQ->D3_EMISSAO, 5, 2)+" | "
                   cPul01 += "------------|"
                Else
                   Cabec4 += "DIA  "+SubStr(TCQ->D3_EMISSAO, 7, 2)+"/"+SubStr(TCQ->D3_EMISSAO, 5, 2)+" | "
                   cPul02 += "------------|"
                Endif
                aadd(aDiaMes, {TCQ->D3_EMISSAO})
                nCont += 1
                DbSelectArea("TCQ")
                DbSkip()
          Enddo
          DbSelectArea("TCQ")
          DbCloseArea()
          nQtdFol := Iif(Len(aDiaMes) > 14, 2, 1)
          If nQtdFol == 1
             Cabec2 += "  TOTAL    |"
             cPul01 += "------------|"
          Else
             Cabec4 += "  TOTAL    |"
             cPul02 += "------------|"
          Endif
          //0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21        22
          //01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
          //TURNO                   | DIA  01/11 | DIA  02/11 | DIA  03/11 | DIA  04/11 | DIA  05/11 | DIA  06/11 | DIA  07/11 | DIA  08/11 | DIA  09/11 | DIA  10/11 | DIA  11/11 | DIA  12/11 | DIA  13/11 | DIA  14/11 | DIA  15/11 |
          //999- XXXXXXXXXXXXXXXXXX | 999,999.99 | 999,999.99 | 999,999.99 | 999,999.99 | 999,999.99 | 999,999.99 | 999,999.99 | 999,999.99 | 999,999.99 | 999,999.99 | 999,999.99 | 999,999.99 | 999,999.99 | 999,999.99 | 999,999.99 |
          //------|------------|
          //TURNO | DIA  16/11 | DIA  17/11 | DIA  18/11 | DIA  19/11 | DIA  20/11 | DIA  21/11 | DIA  22/11 | DIA  23/11 | DIA  24/11 | DIA  25/11 | DIA  26/11 | DIA  27/11 | DIA  28/11 | DIA  29/11 | DIA  30/11 | DIA  31/11 |     TOTAL      |
          //999   | 999,999.99 | 999,999.99 | 999,999.99 | 999,999.99 | 999,999.99 | 999,999.99 | 999,999.99 | 999,999.99 | 999,999.99 | 999,999.99 | 999,999.99 | 999,999.99 | 999,999.99 | 999,999.99 | 999,999.99 | 999,999.99 | 999,999,999.99 |
       ElseIf mv_par01 == 2 //Mensal
              Cabec1 := "TIPO DO PRODUTO  "
              Cabec2 := "TURNO                   |   JANEIRO    |  FEVEREIRO   |    MARÇO     |    ABRIL     |     MAIO     |    JUNHO     |    JULHO     |    AGOSTO    |   SETEMBRO   |   OUTUBRO    |   NOVEMBRO   |   DEZEMBRO   |  ACUMULADO   |"
              cPul01 := "------------------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|"
              //0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21        22
              //01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
              //TURNO                   |   JANEIRO    |  FEVEREIRO   |    MARÇO     |    ABRIL     |     MAIO     |    JUNHO     |    JULHO     |    AGOSTO    |   SETEMBRO   |   OUTUBRO    |   NOVEMBRO   |   DEZEMBRO   |  ACUMULADO   |
              //999- XXXXXXXXXXXXXXXXXX | 9,999,999.99 | 9,999,999.99 | 9,999,999.99 | 9,999,999.99 | 9,999,999.99 | 9,999,999.99 | 9,999,999.99 | 9,999,999.99 | 9,999,999.99 | 9,999,999.99 | 9,999,999.99 | 9,999,999.99 | 9,999,999.99 |
       ElseIf mv_par01 == 3 //Periodo
       
       Endif
Return
/************************************************************************************************/
/*** VALPERG - Validação das perguntas para o relatório                                       ***/
/************************************************************************************************/
//LGS#20200204 - Adequação de release 12.1.25 e posteriores
/*Static Function ValPerg()
       Local _sAlias := Alias()
       Local aRegs := {}
       Local i,j

       dbSelectArea("SX1")
       dbSetOrder(1)
       cPerg := PADR(cPerg,10)
       
       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs,{cPerg, "01", "Diário/Mensal/Periodo ", "", "", "mv_ch1", "N", 01, 0, 0, "C", ""                               , "mv_par01", "Diário"   , "", "", "", "", "Mensal", "", "", "", "", "Periodo", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs,{cPerg, "02", "Turno/Linha           ", "", "", "mv_ch2", "N", 01, 0, 0, "C", ""                               , "mv_par02", "Turno"    , "", "", "", "", "Linha" , "", "", "", "", ""       , "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs,{cPerg, "03", "Considera Mes Atual   ", "", "", "mv_ch3", "N", 01, 0, 0, "C", ""                               , "mv_par03", "Sim"      , "", "", "", "", "Não"   , "", "", "", "", ""       , "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs,{cPerg, "04", "Mes                   ", "", "", "mv_ch4", "N", 02, 0, 0, "G", "Entre(1, 12, mv_par04)"         , "mv_par01", ""         , "", "", "", "", ""      , "", "", "", "", ""       , "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs,{cPerg, "05", "Ano                   ", "", "", "mv_ch5", "C", 04, 0, 0, "G", "Entre('2000', '2100', mv_par05)", "mv_par01", ""         , "", "", "", "", ""      , "", "", "", "", ""       , "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       //aAdd(aRegs,{cPerg, "03", "Linha                 ", "", "", "mv_ch3", "C", 02, 0, 0, "G", "", "mv_par03", ""         , "", "", "", "", ""      , "", "", "", "", ""                 , "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
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
Return*/
