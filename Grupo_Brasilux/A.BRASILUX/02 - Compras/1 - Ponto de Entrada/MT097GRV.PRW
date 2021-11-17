#include "protheus.ch"
#include "topconn.ch"
  /*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
  ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
  ฑฑบPrograma  ณ MT097GRV บ Autor ณ                    บ Data ณ  31/08/04   บฑฑ
  ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
  ฑฑบDescrio ณ Programa para consulta de itens dos pedidos de compras paraบฑฑ
  ฑฑบ          ณ Liberacao.                                                 บฑฑ
  ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
  ฑฑณ Uso      ณ PONTO DE ENTRADA                                           ณฑฑ
  ฑฑณ          ณ COM - MATA097 - LIBERACAO DE PEDIDO DE COMPRA              ณฑฑ
  ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
  ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
  ฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
  //25/09/2019 - Luํs Gustavo - Adequa็ใo para release 12.1.25
User Function MT097GRV()
     Local _cAlias   := Alias()
     Local _aAreaAnt
     //Local cNomArq   := ""
     //Local cIndArq   := ""
     Local cNumPed   := ""
     Local nTotPed   := 0
     Local aStrIte   := {}
     Local aCamBrw   := {}
     Local _nCusto  := 0
     Local _aDocto := PARAMIXB[1]
     Local oDlg,oLPD,_cFuncao
     Local _nTAXAPIS := GETMV("MV_TXPIS") //LGS#20200108 - Ajuste para adequa็ใo de release 12.1.25
     Local _nTAXACOF := GETMV("MV_TXCOFIN") //LGS#20200108 - Ajuste para adequa็ใo de release 12.1.25
     Private lRetPed := .f.
     Private oTemptable := ""
     If alltrim(FWGrpCompany()) <> '11' //Empresas que nใo sใo do grupo 11(Tecpolpa).
        _aAreaAnt := u_PegaArea({"SC7","SF4","SB1","SC8","SE4","ZZ3","SB2","SA5"})
        _cFuncao := funname() //Verificar qual fun็ใo estแ chamando o Ponto de Entrada, qdo vem do EIC estแ dando problema
        If !( Alltrim( _cFuncao ) == "MATA094" )
           Return(.t.)
        endif 
     
        if _aDocto[2] <> "PC"
           return(.t.)
        endif

        //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
        //ณ Buscando Informacoes.                                               ณ
        //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
        aadd(aStrIte, {"ITENS", "C",04,00} )
        aadd(aStrIte, {"DESCR", "C",30,00} )
        aadd(aStrIte, {"QUANT", "N",14,04} )
        aadd(aStrIte, {"PRECO", "N",14,04} )
        aadd(aStrIte, {"TOTAL", "N",15,04} )
        aadd(aStrIte, {"PRODU", "C",15,00} )
        aadd(aStrIte, {"LOCPR", "C",02,00} )
        aadd(aStrIte, {"COTAC", "C",06,00} )
        aadd(aStrIte, {"CUSTO", "N",14,04} ) // Cleber (25/01/10)
        aadd(aStrIte, {"ULPRC", "N",14,04} )
        aadd(aStrIte, {"OK"   , "C",02,00} )

        aadd(aCamBrw, {"ITENS", "", OemToAnsi("Item")       , "@!" } )
        aadd(aCamBrw, {"PRODU", "", OemToAnsi("C๓digo")     , "@!"                } )
        aadd(aCamBrw, {"DESCR", "", OemToAnsi("Produto")    , "@!"                } )
        aadd(aCamBrw, {"QUANT", "", OemToAnsi("Quantidade") , "@E 99999999.9999"  } )
        aadd(aCamBrw, {"PRECO", "", OemToAnsi("Prc. Unit.") , "@E 9999,999.9999"  } )
        aadd(aCamBrw, {"CUSTO", "", OemToAnsi("Custo Unit."), "@E 9999,999.9999"  } ) // Cleber (25/01/10)
        aadd(aCamBrw, {"ULPRC", "", OemToAnsi("Ult. Pre็o") , "@E 9999,999.9999"  } )
        aadd(aCamBrw, {"TOTAL", "", OemToAnsi("Prc. Total") , "@E 9,999,999.9999" } )

        /*cNomArq := CriaTrab(aStrIte, .t.)
          cIndArq := CriaTrab(Nil, .f.)
          DbUseArea(.T., "DBFCDX", cNomArq, "TMP", .F., .F.)
          Index on ITENS TO &cIndArq
        */
        /*
        cNomArq := U_NovoArqTrab("DTC") 
        dbcreate(cNomArq+".dtc", aStrIte, "CTREECDX")
        Use (cNomArq+".dtc") Alias "TMP" VIA "CTREECDX" New Exclusive  
        Index on ITENS TO (cNomArq)
        */
        oTempTable := FWTemporaryTable():New( "TMP" )
        oTemptable:SetFields( aStrIte )
        oTempTable:AddIndex( "cInd01", { "ITENS" } )
        oTempTable:Create()
        DbSelectArea( "TMP" )
        DbSetOrder(1)

        dbselectarea("SF4")
        DbSetOrder(1)

        cNumPed := SC7->C7_NUM
        nTotPed := 0
        
        DbSelectArea("SC7")
        DbSetOrder(1)
        DbSeek(xFilial("SC7")+cNumPed, .f.)
        While !eof() .and. (SC7->C7_FILIAL == xFilial("SC7")) .AND. (SC7->C7_NUM == cNumPed)
              DbSelectArea("TMP")
              RecLock("TMP",.t.)
                 TMP->ITENS := SC7->C7_ITEM
                 TMP->DESCR := SC7->C7_DESCRI
                 TMP->QUANT := SC7->C7_QUANT
                 TMP->PRECO := SC7->C7_PRECO
                 TMP->TOTAL := SC7->C7_TOTAL
                 TMP->PRODU := SC7->C7_PRODUTO
                 TMP->LOCPR := SC7->C7_LOCAL
                 TMP->COTAC := SC7->C7_NUMCOT
                 TMP->ULPRC := FBuscaPreco(xFilial("SC7"), SC7->C7_PRODUTO)
                 _nCusto := SC7->C7_TOTAL

                 dbselectarea("SF4")
                 dbseek(xFilial("SF4")+SC7->C7_TES)
                 if !found()
                    Alert("Aten็ใo! Nใo encontrado o TES "+SC7->C7_TES+" !!")
                 else
                    If SF4->F4_CREDICM == "S"
				       _nCusto -= SC7->C7_VALICM
                    Endif
             		If (SF4->F4_PISCRED == "1") .and. (ALLTRIM(SF4->F4_PISCOF) $ "1_3") //Verif. se hแ o cr้dito de PIS
	                 	//_nCusto -= SC7->C7_TOTAL*GETMV("MV_TXPIS")/100
	                 	_nCusto -= SC7->C7_TOTAL * _nTAXAPIS / 100 //LGS#20200108 - Ajuste para adequa็ใo de release 12.1.25
    	         	Endif
        	     	If (SF4->F4_PISCRED == "1") .and. (ALLTRIM(SF4->F4_PISCOF) $ "2_3") //Verif. se hแ o cr้dito de COFINS
            	     	//_nCusto -= SC7->C7_TOTAL*GETMV("MV_TXCOFIN")/100
            	     	_nCusto -= SC7->C7_TOTAL * _nTAXACOF / 100 //LGS#20200108 - Ajuste para adequa็ใo de release 12.1.25
    	           	Endif
                 endif

                 TMP->CUSTO := _nCusto / IIF(SC7->C7_QUANT > 0,SC7->C7_QUANT,1)
                 DbSelectArea("TMP")
              MsUnLock()
              nTotPed += SC7->C7_TOTAL
              DbSelectArea("SC7")
              DbSkip()
        Enddo
        //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
        //ณ Criacao da Interface.                                               ณ
        //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
        DbSelectArea("TMP")
        DbGoTop()

        DEFINE MSDIALOG oDlg FROM 000,000 TO 015,077 TITLE OemToAnsi("Aprova็ใo de Pedidos" ) OF oMainWnd
               oLPD := MSSelect():New("TMP", "OK", Nil, aCamBrw, .f., Nil, {002, 005, 090, 300}, , , oDlg)

               @ 095,005 SAY    OemToAnsi("Total a ser Liberado :")  SIZE 060,09 COLOR CLR_RED  PIXEL OF oDlg
               @ 095,070 SAY    Transform(nTotPed, "@E 999,999.999") SIZE 060,08 COLOR CLR_BLUE PIXEL OF oDlg
               @ 095,175 BUTTON OemToAnsi("&Consulta")               SIZE 036,16                PIXEL OF oDlg ACTION { || fLibCI() }
               @ 095,215 BUTTON OemToAnsi("C&onfirma")               SIZE 036,16                PIXEL OF oDlg ACTION { || fLibOk(oDlg) }
               @ 095,255 BUTTON OemToAnsi("&Abandona")               SIZE 036,16                PIXEL OF oDlg ACTION { || fLibAB(oDlg) }

               oDlg:nStyle    := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
        ACTIVATE MSDIALOG oDlg CENTERED VALID .T.
        DbSelectArea("TMP")
        DbCloseArea()
        oTempTable:Delete()

        U_VoltaArea(_aAreaAnt)
        If !empty(_cAlias)
           dbselectarea(_cAlias)
        endif
     Else //Tratamento para tecpolpa
	    lRetPed := .T.
	 Endif
Return(lRetPed)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fLibCI   บ Autor ณ Luis Gustavo       บ Data ณ  31/08/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao para Consulta de item do pedido de compras.         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fLibCI()
       Local aVetDad := {}
       Local aVetStr := ""
       Local nPosVet := 1
       Local aArea := GetArea()

       //Poliester Moreira - Chaus - Se nใo colocar a variแvel que controla o FOR o pr้-compilador nใo deixa passar
       Local nY	:= 0

       DbSelectARea("SC8")

       DbSelectARea("SB1")
       DbSetOrder(1)

       DbSeek(xFilial()+TMP->PRODU+TMP->LOCPR,.t.)
       aVetDad := {}
       Aadd(aVetDad, "———————————————————————————————————————— DADOS CADASTRAIS ——————————————————————————————————————")
       Aadd(aVetDad, "C๓digo.......: "+SubStr(Alltrim(SB1->B1_COD), 1, 4)+" - "+SubStr(Alltrim(SB1->B1_DESC), 1, 30)+"   Unid. Medida.: "+SB1->B1_UM+"            Tipo.: "+SB1->B1_TIPO+" ")
       Aadd(aVetDad, "Ponto Pedido.: "+TransForm(SB1->B1_EMIN, "@E 999,999.999")+"                             Lote Econom..: "+TransForm(SB1->B1_LE, "@E 999,999.999")+"")
       Aadd(aVetDad, "Dt. Ult. Pr็.: "+DtoC(SB1->B1_UCOM)+"                                Vl. Ult. Pr็.: "+TransForm(SB1->B1_UPRC, "@E 999,999.999")+"")
       Aadd(aVetDad, " ")
       Aadd(aVetDad, "————————————————————————————————————————— ULTIMA COTAวรO ———————————————————————————————————————")
       Aadd(aVetDad, "FORNECEDOR            VLR. UNIT.   VLR. IPI    VLR. TOTAL  CONDIวรO DE PAGAMENTO           PRAZO")
       Aadd(aVetDad, "ฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏ")
       DbSelectARea("SC8")
       DbSetOrder(3)
       DbSeek(xFilial("SC8")+TMP->COTAC)
       While ! eof() .and. (SC8->C8_FILIAL = xFilial("SC8")) .AND. (SC8->C8_NUM == TMP->COTAC)
             If SC8->C8_PRODUTO == TMP->PRODU
                DbSelectARea("SA2")
                DbSeek(xFilial()+SC8->C8_FORNECE+SC8->C8_LOJA)
                DbSelectArea("SC8")
                If SC8->C8_NUMPED == "XXXXXX"
                   aVetStr := ""
                   aVetStr += ""+SubStr(SA2->A2_NOME, 1, 20)+"  "+TransForm(SC8->C8_PRECO, PesqPict("SC8","C8_PRECO"))+"  "+TransForm((SC8->C8_PRECO * (SC8->C8_ALIIPI / 100)), PesqPict("SD2","D2_VALIPI"))+"  "+TransForm( (SC8->C8_PRECO + (SC8->C8_PRECO * (SC8->C8_ALIIPI / 100))), PesqPict("SD2","D2_VALIPI"))+"  "
                   DbSelectARea("SE4")
                   DbSeek(xFilial("SE4")+SC8->C8_COND)
                   aVetStr += SE4->E4_DESCRI+"  "+TransForm(SC8->C8_PRAZO, PesqPict("SC8","C8_PRAZO"))+" "
                Else
                   aVetStr := ""
                   aVetStr += ""+SubStr(SA2->A2_NOME, 1, 20)+"  "+TransForm(SC8->C8_PRECO, PesqPict("SC8","C8_PRECO"))+"  "+TransForm((SC8->C8_PRECO * (SC8->C8_ALIIPI / 100)), "@E 999,999.99")+"  "+TransForm( (SC8->C8_PRECO + (SC8->C8_PRECO * (SC8->C8_ALIIPI / 100))), PesqPict("SD2","D2_VALIPI"))+"  "
                   DbSelectARea("SE4")
                   DbSeek(xFilial("SE4")+SC8->C8_COND)
                   aVetStr += SE4->E4_DESCRI+"  "+TransForm(SC8->C8_PRAZO, PesqPict("SC8","C8_PRAZO"))+" "
                Endif
                Aadd(aVetDad, aVetStr)
                DbSelectARea("SC8")
             Endif
             Dbskip()
       Enddo
       Aadd(aVetDad, " ")
      /**************************************************************/
      Aadd(aVetDad, "———————————————————————————————————————— SALDOS E CONSUMO ——————————————————————————————————————")
      Aadd(aVetDad, "—————— ULTIMOS 3 MESES ——————                                                                   ")

      nMesAtu := Month(dDataBase)
      nAnoAtu := Year(dDataBase)
      aMeses1 := {"Jan.", "Fev.", "Mar.", "Abr.", "Mai.", "Jun.", "Jul.", "Ago.", "Set.", "Out.", "Nov.", "Dez."}
      aMeses2 := {"01"  , "02"  , "03"  , "04"  , "05"  , "06"  , "07"  , "08"  , "09"  , "10"  , "11"  , "12"  }
      nMesIni := Iif( (nMesAtu - 3) == 0, 12, Iif( (nMesAtu - 3) == -1, 11, Iif( (nMesAtu - 3) == -2, 10, (nMesAtu - 3) )))
      nAnoIni := Iif( (nMesAtu - 3) == 0, (nAnoAtu - 1), Iif( (nMesAtu - 3) == -1, (nAnoAtu - 1), Iif( (nMesAtu - 3) == -2, (nAnoAtu - 1), nAnoAtu )))
      aMesUti := {}
      For nY := 1 to 12
          If Len(aMesUti) < 3
             If nAnoIni < nAnoAtu
                Aadd(aMesUti, {nMesIni, nAnoIni} )
                If nMesIni == 12
                   nMesIni := 1
                   nAnoIni := nAnoAtu
                Else
                   nMesIni += 1
                Endif
             ElseIf nAnoIni = nAnoAtu
                    Aadd(aMesUti, {nMesIni, nAnoIni} )
                    nMesIni += 1
             Endif
          Endif
      Next
      cMes1 := aMeses1[aMesUti[1][1]]
      cMes2 := aMeses1[aMesUti[2][1]]
      cMes3 := aMeses1[aMesUti[3][1]]

      Aadd(aVetDad, "   "+cMes1+"      "+cMes2+"      "+cMes3+"      MEDIA    SALDO AT.  DURAวรO                                    ")
      Aadd(aVetDad, "ฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏ")

      /*For nY := 1 To Len(aMesUti)
          DbSelectArea("ZZ3")
          DbSetOrder(1)
          DbSeek(xFilial("ZZ3")+Alltrim(StrZero(aMesUti[1][2], 4))+TMP->PRODU, .t.)
          If Found()
             nMes  := "nMes"
             nMes  += Alltrim(StrZero(nY, 2))
             &nMes := &("ZZ3->ZZ3_Q"+StrZero(aMesUti[nY][1], 2))
          Else
             nMes  := "nMes"
             nMes  += Alltrim(StrZero(nY, 2))
             &nMes := 0
          Endif
      Next*/

      nMedia := (nMes01 + nMes02 + nMes03) / 3

      DbSelectArea("SB2")

      DbSeek(xFilial()+TMP->PRODU+TMP->LOCPR)
      If Found()
         nSaldo := SB2->B2_QATU
      Else
         nSaldo := 0
      Endif
      Aadd(aVetDad, " "+TransForm(nMes01, "@E 99999.99")+"  "+TransForm(nMes02, "@E 99999.99")+"  "+TransForm(nMes03, "@E 99999.99")+"  "+TransForm(nMedia, "@E 999999.99")+"  "+TransForm(nSaldo, "@E 999999.99")+"   "+TransForm( Iif(nMedia <> 0, (nSaldo / nMedia), 0), "@E 999.99")+"")
      Aadd(aVetDad, " ")
      Aadd(aVetDad, "—————————————————————————————————————— PRODUTO X FORNECEDOR ————————————————————————————————————")
      DbSelectARea("SA5")
      DbSetOrder(2)
      DbSeek(xFilial()+TMP->PRODU)
      While !eof() .and. SA5->A5_PRODUTO == TMP->PRODU
            Aadd(aVetDad, ""+SubStr(Alltrim(SA5->A5_PRODUTO), 1, 4)+" - "+SA5->A5_NOMPROD+"   -   "+SA5->A5_FORNECE+"/"+SA5->A5_LOJA+" - "+SubStr(SA5->A5_NOMEFOR, 1, 40)+"")
            Dbskip()
      Enddo
      Aadd(aVetDad, " ")
      Aadd(aVetDad, "—————————————————————————————————————— MOVIMENTOS EM ABERTO ————————————————————————————————————")
      Aadd(aVetDad, "PEDIDO  DT.ENTR.  FORNECEDOR                        QTD. PED.   SALDO       VALOR TOTAL         ")
      Aadd(aVetDad, "ฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏ")
      DbSelectARea("SC7")
      DbSetOrder(7)
      DbSeek(xFilial()+TMP->PRODU)
      While !Eof() .and. SC7->C7_PRODUTO == TMP->PRODU
            If SC7->C7_QUJE < SC7->C7_QUANT .AND. SC7->C7_RESIDUO # "S"
               Aadd(aVetDad, ""+SC7->C7_NUM+"  "+DTOC(SC7->C7_DATPRF)+"  "+SC7->C7_FORNECE+"/"+SC7->C7_LOJA+" - "+SubStr(Posicione("SA2", 1, xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA, "A2_NOME"), 1, 20)+"  "+TransForm(SC7->C7_QUANT, "@E 999,999.99")+"  "+Transform( (SC7->C7_QUANT - SC7->C7_QUJE), "@E 999,999.99")+"  "+Transform( ( (SC7->C7_PRECO * (SC7->C7_QUANT-SC7->C7_QUJE))), "@E 999,999,999.99")+"      ")
            Endif
            Dbskip()
      Enddo
      Aadd(aVetDad, " ")
      RecLock("TMP",.f.)
         TMP->OK := "XX"
      MsUnLock()
      nPosVet := 1
      DEFINE MSDIALOG oDlg1 FROM 000,000 TO 026,78 TITLE OemToAnsi("Analise de Produtos") OF oMainWnd
             DEFINE FONT oFont3 NAME 'COURIER NEW' SIZE 6,0
             @ 006,005 LISTBOX nPosVet ITEMS aVetDad SIZE 300,170 FONT oFont3 PIXEL OF oDlg1
             DEFINE SBUTTON FROM 180,275 TYPE 01 ACTION { || oDlg1:End() } ENABLE PIXEL OF oDlg1
             oDlg1:nStyle := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
      ACTIVATE MSDIALOG oDlg1 CENTERED VALID .T.
      dlgRefresh(oDlg)

	RestArea(aArea)
Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
  ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
  ฑฑบPrograma  ณ fLibOk   บ Autor ณ Luis Gustavo       บ Data ณ  31/08/04   บฑฑ
  ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
  ฑฑบDescrio ณ Funcao para Confirmacao de liberacao do pedido.            บฑฑ
  ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
  ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
  ฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function fLibOk(oDlg)
       lRetPed := .t.
       oDlg:End()
Return(lRetPed)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
  ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
  ฑฑบPrograma  ณ fLibAB   บ Autor ณ Luis Gustavo       บ Data ณ  26/10/00   บฑฑ
  ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
  ฑฑบDescrio ณ Funcao para Consulta de item do pedido de compras.         บฑฑ
  ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
  ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
  ฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function fLibAB(oDlg)
       lRetPed := .f.
       oDlg:End()
Return(lRetPed)

Static Function FBuscaPreco(cFilPrc, cCodPrc)
       Local _cAlias := Alias()
       Local nUlPrc  := 0
       Local cQry1   := ''
       cQry1 := "SELECT dbo.UltPreco('"+cFilPrc+"', '"+cCodPrc+"') AS ULPRC "
       TcQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       nUlPrc := TCQ->ULPRC
       DbSelectArea("TCQ")
       DbCloseArea()
       If !Empty(_cAlias)
          dbselectarea(_cAlias)
       Endif
Return(nUlPrc)
