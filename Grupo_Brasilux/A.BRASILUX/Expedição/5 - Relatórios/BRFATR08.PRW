#include 'rwmake.ch'
#include 'topconn.ch

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRFATR08 บ Autor ณ Luํs G. de Souza   บ Data ณ  26/01/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rela็ใo por bordero dos itens a serem retirados do estoque.บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Brasilux Tintas T้cnicas Ltda.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function BRFATR08()   
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "Retirada de Estoque por bordero."
     //Local cPict         := ""
     Local titulo        := "Bordero - "
     Local nLin          := 80
     Local Cabec1        := "PRODUTO         DESCRIวรO                 UN-VOLUME      LOCALIZ         QTDE   "
     Local Cabec2        := ""
     //Local imprime       := .T.
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     //Private CbTxt       := ""
     Private limite      := 80
     Private tamanho     := "P"
     Private nomeprog    := "BRFAR08" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 18
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := "FATR08"
     Private cbtxt       := Space(10)
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRFATR08" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString := "ZZC"

     DbSelectArea("ZZC")
     DbSetOrder(1)

     fVldPer()
     Pergunte(cPerg,.F.)

     wnrel := SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho, , .F.)

     If nLastKey == 27
        Return
     Endif

     SetDefault(aReturn,cString)

     If nLastKey == 27
        Return
     Endif

     nTipo := If(aReturn[4] == 1, 15, 18)

     Processa({|| FATR08_1(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ FATR08_1 บ Autor ณ Luํs G. de Souza   บ Data ณ  26/01/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FATR08_1(Cabec1, Cabec2, Titulo, nLin)
       //Local nOrdem
       Local cQry1   := ""
       Local aMatImp := {}
       Local nX, nY
       Titulo := Alltrim(Titulo)+" "+mv_par01
       
       cQry1 += "SELECT ZZC.ZZC_PRODUT AS PRODUTO, SB1.B1_DESC AS DESCRICAO, SB2.B2_LOCALIZ AS LOCALIZ, SUM(ZZC.ZZC_QUANTI - ZZC.ZZC_RETIRA) AS QUANTIDADE, SUM(ZZC.ZZC_QUANTI - ZZC.ZZC_RETIRA) AS RETIRA, SUM(ZZC.ZZC_VOLUME - ZZC.ZZC_VOLRET) AS VOLUME, SUM(ZZC.ZZC_VOLUME - ZZC.ZZC_VOLRET) AS VOLRET "
       cQry1 += "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON ZZC.ZZC_FILIAL = SB1.B1_FILIAL AND ZZC.ZZC_PRODUT = SB1.B1_COD AND SB1.D_E_L_E_T_ = '' "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON SB1.B1_FILIAL = SB2.B2_FILIAL AND SB1.B1_COD = SB2.B2_COD AND SB1.B1_LOCPAD = SB2.B2_LOCAL AND SB2.D_E_L_E_T_ = '' "
       cQry1 += "WHERE ZZC.ZZC_FILIAL = '"+xFilial("ZZC")+"' "
       cQry1 += "  AND ZZC.D_E_L_E_T_ = '' "
       cQry1 += "  AND ZZC.ZZC_BORDER = '"+mv_par01+"' "
       cQry1 += "  AND ZZC.ZZC_QUANTI <> ZZC.ZZC_RETIRA "
       cQry1 += "GROUP BY ZZC.ZZC_PRODUT, SB1.B1_DESC, SB2.B2_LOCALIZ "
       cQry1 += "ORDER BY 3, 1 "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       cOrdAtu  := "N"
       cLocaliz := ""
       aMatOrd  := {}
       While !Eof()
             cLocaliz := SubStr(Alltrim(TCQ->LOCALIZ), 1, 3)
             If Empty(cLocaliz)
                If aScan(aMatOrd, {|x| Alltrim(x[1]) == Alltrim(cLocaliz)}) == 0
                   aadd(aMatOrd, {cLocaliz, "N"})
                Endif
                DbSkip()
                Loop
             Else
                While !Eof() .and. cLocaliz == SubStr(Alltrim(TCQ->LOCALIZ), 1, 3)
                      If aScan(aMatOrd, {|x| Alltrim(x[1]) == Alltrim(cLocaliz)}) == 0
                         aadd(aMatOrd, {SubStr(cLocaliz, 1, 3), cOrdAtu})
                      Endif
                      DbSkip()
                Enddo
                cOrdAtu := Iif(cOrdAtu == "I", "N", "I")
             Endif
       Enddo
       For nY := 1 To Len(aMatOrd)
           DbSelectArea("TCQ")
           DbGoTop()
           aMatAux := {}
           While !Eof()
                 If SubStr(Alltrim(TCQ->LOCALIZ), 1, 3) == aMatOrd[nY][1]
                    aadd(aMatAux, { TCQ->PRODUTO, TCQ->DESCRICAO, TCQ->LOCALIZ, TCQ->QUANTIDADE, TCQ->RETIRA, TCQ->VOLUME, TCQ->VOLRET, .f. })
                 Endif
                 DbSelectArea("TCQ")
                 DbSkip()
           Enddo
           //Ordena Matriz
           If aMatOrd[nY][2] $ 'I'
              aSort(aMatAux, , , {|x, y| x[4] > y[4]})
           Endif
           For nX := 1 To Len(aMatAux)
               aAdd(aMatImp, {aMatAux[nX][01], aMatAux[nX][02], aMatAux[nX][03], aMatAux[nX][04], aMatAux[nX][05], aMatAux[nX][06], aMatAux[nX][07], aMatAux[nX][08] })
           Next
       Next
       DbSelectArea("TCQ")
       DbCloseArea()

       DbSelectArea(cString)
       DbSetOrder(1)

       ProcRegua(Len(aMatImp))

       For nY := 1 To Len(aMatImp)
           IncProc()
           If lAbortPrint
              @nLin, 000 PSAY "*** CANCELADO PELO OPERADOR ***"
              Exit
           Endif
           If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
              nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
              nLin += 1
           Endif
           @ nLin, 000 PSAY Alltrim(aMatImp[nY][01]) Picture "@R XXX99.99.999-99"
           @ nLin, 015 PSAY Iif(Posicione("SB1", 1, xFilial("SB1")+aMatImp[nY][01], "B1_ESTOQUE") = 'S', "*", "-")
           @ nLin, 016 PSAY SubStr(aMatImp[nY][02], 1, 25) Picture "@!"
           @ nLin, 041 PSAY "("+SubStr(aMatImp[nY][01], 11, 2)+"-"+Alltrim(SubStr(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(aMatImp[nY][01], 11, 2), "Z5_DESCR"), 1, 10))+")"
           @ nLin, 057 PSAY Iif(Empty(aMatImp[nY][03]), " ", AllTrim(aMatImp[nY][03]))
           @ nlin, 074 PSAY aMatImp[nY][04] Picture "@E 999999"
             nLin += 1
           @ nlin,000 PSAY Replicate("_",80)
             nLin += 1
       Next

       SET DEVICE TO SCREEN
      
       If aReturn[5]==1
          dbCommitAll()
          SET PRINTER TO
          OurSpool(wnrel)
       Endif
       
       MS_FLUSH()
Return

/*******************************************************************************/
/*** VLDPERG - Ajusta perguntas com o SX1.                                   ***/
/*******************************************************************************/
//LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
/*Static Function fVldPer()
       PutSX1("FATR08    ", "01"  ,   "Bordero             ", ""     , ""     , "mv_ch1", "C"  , 6       , 0       , 0      , "G" , " "   , "SZF", " "    , " "  , "mv_par01", " "        , " "     , " "     , " "   , " "        , " "     , " "     , " "  , " "     , " "     , " ", " "     , " "     , " ",  " "     ,  " "     , Nil     , Nil     , Nil     , "FATR08" )
Return*/