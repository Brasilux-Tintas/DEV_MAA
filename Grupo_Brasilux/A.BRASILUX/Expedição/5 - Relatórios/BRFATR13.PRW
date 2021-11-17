#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFATR13 º Autor ³ Luís G. de Souza   º Data ³  14/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressão de endereços de pedidos por bordero para expedi- º±±
±±º          ³ ção.                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TËCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRFATR13()
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "Endereçamento Expedição"
     //Local cPict         := ""
     Local titulo        := "Endereçamento Expedição"
     Local nLin          := 80
     Local Cabec1        := "PEDIDO CLIENTE                                         REG. VOLUME PLT ENDEREÇO"
     Local Cabec2        := ""
     //Local imprime       := .T.
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     //Private CbTxt       := ""
     Private limite      := 80
     Private tamanho     := "P"
     Private nomeprog    := "BRFATR13" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 18
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cbtxt       := Space(10)
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRFATR13" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString     := "SZF"

      if !u_VldAcesso(funname())
      	  MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
    	  return 
	  endif 

     DbSelectArea("SZF")
     DbSetOrder(1)

     //VldPerg()  //LGS#20200212 - Adequação de release 12.1.25 e posteriores
     Pergunte("FATR13", .f.)
     
     wnrel := SetPrint(cString, NomeProg, "FATR13", @titulo, cDesc1, cDesc2, cDesc3, .f., aOrd, .F., Tamanho, , .F.)

     If nLastKey == 27
        Return
     Endif

     SetDefault(aReturn,cString)

     If nLastKey == 27
        Return
     Endif

     nTipo := If(aReturn[4]==1,15,18)

     Processa({|| FATR13_1(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ FATR13_1 º Autor ³ Luís G. de Souza   º Data ³  14/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela PROCESSA.                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FATR13_1(Cabec1, Cabec2, Titulo, nLin)
       Local aEndExp := {}
       Local aPallet := {}
       Local aQuadra := {}
       Local aProPal := {}
       Local aProQua := {}
       Local nTipoIm := 0
       Local nY, nLoop, nA

       Titulo := Alltrim(Titulo)+' - '+mv_par01

       DbSelectArea("SZF")
       DbSetOrder(1)
       DbSeek(xFilial("SZF")+mv_par01, .t.)
       If !Found()
          Return
       Else
          If SZF->ZF_FLAG $ '' //'D.M'
             nTipoIm := 1
             U_fBusEndLiv(@aPallet, @aQuadra, @aProPal, @aProQua) //Montas Matrizes para endereços livres
             DbSelectArea("SZG")
             DbSetOrder(1)
             DbSeek(xFilial("SZG")+mv_par01, .t.)
             If !Found()
                Return
             Else
                While !Eof() .and. SZG->ZG_CODIGO == mv_par01
                      aAdd(aEndExp, {SubStr(SZG->ZG_PEDIDO, 3, 6), '', '', '', '', 0, 0, 0, '', '', '', ''})
                      DbSelectArea("SZG")
                      DbSkip()
                Enddo
             Endif
             ProcRegua(Len(aEndExp))
          Else
             nTipoIm := 2
             DbSelectArea("SZG")
             DbSetOrder(1)
             DbSeek(xFilial("SZG")+mv_par01, .t.)
             If !Found()
                Return
             Else
                While !Eof() .and. SZG->ZG_CODIGO == mv_par01
                      aAdd(aEndExp, {SubStr(SZG->ZG_PEDIDO, 3, 6), '', '', '', '', 0, 0, 0, '', SZG->ZG_LOCALIZ, '', ''})
                      DbSelectArea("SZG")
                      DbSkip()
                Enddo
             Endif
          Endif
       Endif

       For nY := 1 To Len(aEndExp)
           IncProc("Processando pedido: "+aEndExp[nY][1])

		 //Cleber (18/10/10) -> Verificar se rel. de volumes estão coerentes antes     
		 //U_VerificaVolumes(aEndExp[nY][1]) //Cleber(27/08/2015) -> retirado


           aEndExp[nY][02] := Posicione("SC5", 1, xFilial("SC5")+aEndExp[nY][1], "C5_CLIENTE") //Código do Cliente
           aEndExp[nY][03] := Posicione("SA1", 1, xFilial("SA1")+aEndExp[nY][2], "A1_NOME")    //Nome do Cliente
           aEndExp[nY][04] := Posicione("SA1", 1, xFilial("SA1")+aEndExp[nY][2], "A1_CODCID")  //Código da Cidade
           aEndExp[nY][05] := Posicione("SZ7", 1, xFilial("SZ7")+aEndExp[nY][4], "Z7_REGIAO")  //Código da Região
           aEndExp[nY][06] := Posicione("SC5", 1, xFilial("SC5")+aEndExp[nY][1], "C5_VOLUME1") //Volume do Pedido
           aEndExp[nY][11] := Posicione("SC5", 1, xFilial("SC5")+aEndExp[nY][1], "C5_TRANSP")  //Código da Transportadora
           aEndExp[nY][12] := Posicione("SC5", 1, xFilial("SC5")+aEndExp[nY][1], "C5_REDESP")  //Código dO Redespacho
           DbSelectArea("SC6")
           DbSetOrder(1)
           DbSeek(xFilial("SC6")+aEndExp[nY][1], .t.)
           If Found()
              While !Eof() .and. SC6->C6_NUM == aEndExp[nY][1]
                    If SC6->C6_PALLET == 0.0
                       aEndExp[nY][7] += 1 //Qtde. de Pedidos com 0 Pallet
                    Else
                       aEndExp[nY][8] += SC6->C6_PALLET //Somatória dos Pallets por item
                    Endif
                    DbSelectArea("SC6")
                    DbSkip()
              Enddo
           Endif
       Next
       ProcRegua(Len(aEndExp))
       For nY := 1 To Len(aEndExp)
           IncProc("Calculando espaço para pedido: "+aEndExp[nY][1])
           If aEndExp[nY][8] > 0.22 //Pallet
              If (aEndExp[nY][8] - Int(aEndExp[nY][8])) > 0.0
                 aEndExp[nY][8] := Int(aEndExp[nY][8]) + 1 //+ Iif(aEndExp[nY][7] > 0 , 1, 0.0)
              ElseIf (aEndExp[nY][8] - Int(aEndExp[nY][8])) == 0.0
                     aEndExp[nY][8] += 1 //Iif(aEndExp[nY][7] > 0 , 1, 0.0)
              Endif
              aEndExp[nY][9] := '1'
           Else                     //Endereço avulso
              //If aEndExp[nY][7] > 0
              //   aEndExp[nY][8] := 1
              //   aEndExp[nY][9] := '1'
              //Else
                 aEndExp[nY][9] := '2'
              //Endif
           Endif
       Next
       
       If nTipoIm == 1
          aSort(aEndExp,,, {|x, y| Transform(x[8], "@E 999999")+x[11]+x[12] > Transform(y[8], "@E 999999")+y[11]+y[12]})

          ProcRegua(Len(aEndExp))
          For nY := 1 To Len(aEndExp)
              IncProc("Endereçando pedido: "+aEndExp[nY][1])
              If aEndExp[nY][9] == '1' //Pallets
                 cEndPed := U_fEndPedExp('R', aEndExp[nY][9], mv_par01, aEndExp[nY][1], aEndExp[nY][5], aEndExp[nY][8], @aPallet, @aQuadra, @aProPal, @aProQua)
                 aEndExp[nY][10] := cEndPed
              Else                     //Quadrantes
                 cEndPed := U_fEndPedExp('R', aEndExp[nY][9], mv_par01, aEndExp[nY][1], aEndExp[nY][5],              0, @aPallet, @aQuadra)
                 aEndExp[nY][10] := cEndPed
              Endif
          Next
          aSort(aEndExp,,, {|x, y| x[1] < y[1]})
       Endif
       ProcRegua(Len(aEndExp))
       For nA := 1 To Len(aEndExp)
           IncProc("Imprimindo pedido: "+aEndExp[nA][1])
           If lAbortPrint
              @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
              Exit
           Endif
           If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
              nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
              nLin += 1
           Endif
           //0         1         2         3         4         5         6         7         8
           //012345678901234567890123456789012345678901234567890123456789012345678901234567890
           //PEDIDO CLIENTE                                         REG. VOLUME PLT ENDEREÇO
           //999999 999999-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999 999999 999 XXXXXXXXX
           @ nLin, 000 PSAY aEndExp[nA][1]
           @ nLin, 007 PSAY aEndExp[nA][2]+'-'+aEndExp[nA][3]
           @ nLin, 056 PSAY aEndExp[nA][5]
           @ nLin, 060 PSAY aEndExp[nA][6] Picture '@E 999999'
           @ nLin, 067 PSAY Iif(aEndExp[nA][9] == '1',  aEndExp[nA][8], '') Picture '@E 999'
           @ nLin, 071 PSAY aEndExp[nA][10]
           nLin += 1 // Avanca a linha de impressao
           If mv_par02 == 1
              cEmba := fDetVol(aEndExp[nA][1])
              nQtdLin := MLCount(cEmba)
              If nQtdLin > 0
                 For nLoop := 1 To nQtdLin
                     cLinha := MemoLine(cEmba, 45, nLoop)
                     If !Empty(cLinha)
                        @ nLin,000 PSAY cLinha
                        nLin += 1
                     Endif
                     If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
                        nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
                        nLin += 1
                     Endif
                 Next
              Endif
              nLin += 1
           Endif
     Next

     SET DEVICE TO SCREEN

    If aReturn[5]==1
       dbCommitAll()
       SET PRINTER TO
       OurSpool(wnrel)
    Endif

    MS_FLUSH()
Return

//LGS#20200212 - Adequação de release 12.1.25 e posteriores
/*Static Function VldPerg()
       PutSX1("FATR13    ", "01"   , "Numero Bordero     "          , ""                            , ""                            , "mv_ch1", "C"   , 06      , 0       , 0      , "G"  , "                                                            ", "SZF", "   "  , "   " , "mv_par01"      , "               ", "               ", "               ", "                                                            ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", Nil     , Nil     , Nil     , ".FATR1301." )
       aHelPor1 := {}
       aAdd(aHelPor1, "Informar o numero do bordero de pedidos ")
       aAdd(aHelPor1, 'para endereçamento dos pedidos na expe -')
       aAdd(aHelPor1, 'dição.                                  ')
       PutSX1Help("P.FATR1301.", aHelPor1, Nil, Nil)

       PutSX1("FATR13    ", "02"   , "Analitica / Sintética"        , ""                            , ""                            , "mv_ch2", "N"   , 01      , 0       , 1      , "C"  , "                                                            ", "   ", "   "  , "   " , "mv_par02"      , "Analitico      ", "               ", "               ", "                                                            ", "Sintético      ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", Nil     , Nil     , Nil     , ".FATR1302." )
       aHelPor2 := {}
       aAdd(aHelPor2, 'Informar se a impressão será análitica  ')
       aAdd(aHelPor2, 'ou sintética.                           ')
       aAdd(aHelPor2, '                                        ')
       PutSX1Help("P.FATR1302.", aHelPor2, Nil, Nil)
Return*/

Static Function fDetVol(cPedido)
       //Local cUniMed := ""
       //Local lTemEmb := .f.
       //Local cCodCom := ""
       //Local nQtdCom := 0.0
       //Local lAchouE := .f.
       //Local cDesEmb := ""
       //Local nVarEmb := 0.0
       //Local nRelVol := 0
       //Local nQtdVol := 0
       //Local nAuxEmb := 0
       Local nAuxTam := 0
       Local cAuxMen := ""
       local cAux
       Local nColuna := 45
		Local nArea   := Alias()
       
       DbSelectArea("ZZO") //Qtde de Volumes por Embalagem
       DbSetOrder(1)

       DbSelectArea("SZ5") //Tipos de Embalagem
       DbSetOrder(1)

       cMenEmb := ""
       dbselectarea("ZZO")
       dbseek(xFilial("ZZO")+cPedido)
       If found()
          nAuxTam := Len(cMenEmb) % nColuna //Resto
          If nAuxTam > 0
             cMenEmb := Space(nColuna - nAuxTam) + cMenEmb
          Endif
          //                      999,999	        999,999
          //         0         1         2         3         4         5
          //          12345678901234567890123456789012345678901234567890123456789
          //cMenEmb := "EMBALAGEM          QTDE           VOLUMES"
          cMenEmb := cMenEmb + Space(nColuna - Len(cMenEmb))+chr(13)+chr(10)
       Endif

       while !eof() .and. (ZZO->ZZO_PEDIDO == cPedido) .and. (ZZO->ZZO_FILIAL = xFilial("ZZO")) 
       		cAux := "Diversos"
       		dbselectarea("SZ5")
       		dbseek(xFilial("SZ5")+ZZO->ZZO_EMBA)
       		if found()
       			cAux = alltrim(SZ5->Z5_DESCR)
       		endif 
           	cAuxMen := ZZO->ZZO_EMBA+' - '+SubStr(Alltrim(SubStr(cAux, 1, 18)), 1, 16)
           	cAuxMen := cAuxMen + Space(16 - Len(cAuxMen))
           	cAuxMen += Transform(ZZO->ZZO_QTDE, "999,999")
           	cAuxMen := cAuxMen+Space(34 - Len(cAuxMen))
           	cAuxMen += Transform(ZZO->ZZO_QTDVOL, "999,999")
           	cAuxMen += Space(nColuna - Len(cAuxMen))
           	cMenEmb += cAuxMen+chr(13)+chr(10)
           	dbselectarea("ZZO")
           	dbskip()
       enddo 
     DbSelectArea(nArea)
       
Return(cMenEmb)
