//#include 'brasilux.ch'
#include "protheus.ch"
#include 'topconn.ch'

User Function BRPCPR04()
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "Necessidade de Produção"
     //Local cPict         := ""
     Local titulo        := "Necessidade de Produção"
     Local nLin          := 80
     Local Cabec1        := "PRODUTO         DESCRIÇÃO                      TP SALDO ATUAL  "
     Local Cabec2        := ""
     //Local imprime       := .T.
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     //Private CbTxt       := ""
     Private limite      := 132
     Private tamanho     := "M"
     Private nomeprog    := "BRPCPR04" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 18
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cbtxt       := Space(10)
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRPCPR04" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString     := "SC2"

     DbSelectArea("SC2")
     DbSetOrder(1)

     wnrel := SetPrint(cString, NomeProg, "", @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho, , .F.)

     If nLastKey == 27
        Return
     Endif

     SetDefault(aReturn,cString)

     If nLastKey == 27
        Return
     Endif

     nTipo := If(aReturn[4]==1,15,18)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     Processa({|| PCPR04_1(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

Static Function PCPR04_1(Cabec1, Cabec2, Titulo, nLin)
       Local cQry1   := ""
       Local aIteNec := {}
       Local nY
       ProcRegua(500)
       For nY := 1 To 6
           cQry1 := ""
           cQry1 += "SELECT * "
           cQry1 += "FROM OPS_N"+StrZero(nY, 1)+" WITH (NOLOCK) "
           TCQUERY cQry1 ALIAS "TCQ" NEW
           DbSelectArea("TCQ")
           While !Eof()
                 If aScan(aIteNec, {|x| x[1] = TCQ->G1_COMP}) == 0
                    aAdd(aIteNec, {TCQ->G1_COMP, TCQ->B1_DESC, TCQ->B1_TIPO, TCQ->NECESSIDADE, ''})
                    If TCQ->B1_TIPO $ 'MP.MC'
                       aIteNec[Len(aIteNec)][5] := '01'+TCQ->G1_COMP
                    Else
                       aIteNec[Len(aIteNec)][5] := '02'+TCQ->G1_COMP
                    Endif
                 Else
                    aIteNec[aScan(aIteNec, {|x| x[1] = TCQ->G1_COMP})][4] += TCQ->NECESSIDADE
                 Endif
                 DbSelectArea("TCQ")
                 DbSkip()
           Enddo
           IncProc('Aguarde, processamento demorado...')
           DbSelectArea("TCQ")
           DbCloseArea()
       Next
       aSort(aIteNec,,, { |x,y| x[5] < y[5] })
       ProcRegua(Len(aIteNec))
       //0         1         2         3         4         5         6         7         8         9         10        11        12        13
       //0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
       //123456789012345 123456789012345678901234567890 12
       //PRODUTO         DESCRIÇÃO                      TP SALDO ATUAL  ENTRADA      SAIDAS
       //XX 99.99.999-99 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XX 9,999,999.99 9,999,999.99 9,999,999.99
       For nY := 1 To Len(aIteNec)
           IncProc('Processando Relatório...')
           nQtdAtu := 0
           nQtdEnt := 0
           nQtdSai := 0

           If lAbortPrint
              @ nLin, 000 PSAY "*** CANCELADO PELO OPERADOR ***"
              nY := Len(aIteNec)
              Loop
           Endif
           If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
              nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
              nLin += 1
           Endif
           DbSelectArea("SB2")
           DbSetOrder(1)
           DbSeek(xFilial("SB2")+aIteNec[nY][1]+Posicione("SB1", 1, xFilial("SB1")+aIteNec[nY][1], "B1_LOCPAD"), .t.)
           If Found()
              nQtdAtu := SB2->B2_QATU
              nQtdEnt := SB2->B2_SALPEDI
              nQtdSai := SB2->B2_RESERVA + SB2->B2_QPEDVEN
           Endif
           @ nLin, 000 PSAY aIteNec[nY][1] Picture "@R XX 99.99.999-99"
           @ nLin, 016 PSAY aIteNec[nY][2] Picture "@!"
           @ nLin, 047 PSAY aIteNec[nY][3] Picture "@!"
           @ nLin, 050 PSAY nQtdAtu Picture "@E 9,999,999.99"
           @ nLin, 063 PSAY nQtdEnt Picture "@E 9,999,999.99"
           nLin += 1
       Next
       SET DEVICE TO SCREEN

       If aReturn[5]==1
          DbCommitAll()
          SET PRINTER TO
          OurSpool(wnrel)
       Endif

       MS_FLUSH()

Return
