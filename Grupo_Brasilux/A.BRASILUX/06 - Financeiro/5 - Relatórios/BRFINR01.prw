#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'TOPCONN.CH'
#include "avprint.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BRFINR01³ Autor ³ Luís G. de Souza      ³ Data ³ 15/12/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³                  ³Contato ³                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressão de boletos Bancários                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³  /  /  ³                                               ³±±
±±³              ³  /  /  ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function BRFINR01()
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de cVariable dos componentes                                 ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     Private cSay1Bol   := Space(1)
     Private cSay2Bol   := Space(1)
     Private cSay3Bol   := Space(1)
     Private cPergBol   := "FINR01"
     Private cFilSele   := "N"
     Private cGet1Bol   := Space(12)
     Private cSay4Bol   := Space(1)
     Private cMGet1Bo
     Private aMGet1Bo   := {}
     Private lEnd       := .f.
     Private nQtdReg    := 0
          
	if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
	endif 
     u_zcfga01( 'BRFINR01' ) //LGS#2021202 - Gravação de log de utilização da rotina
     ValidPerg()
     Pergunte(cPergBol, .f.)

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oFont1Bl", "oDlg1Bol", "oBtn2Bol", "oBtn3Bol", "oPnl1Bol", "oSay1Bol", "oSay2Bol", "oSay3Bol", "oBtn1Bol")

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oFont1Bl   := TFont():New( "MS Sans Serif", 0, -19, , .T., 0, , 700, .F., .F., , , , , , )
     oDlg1Bol   := MSDialog():New( 095, 232, 247, 820, "Impressão de Boletos", , , .F., , , , , , .T., , , .T. )
     oBtn1Bol   := TButton():New( 004, 004, "Parâmetros", oDlg1Bol, { || Pergunte(cPergBol, .t.) }, 037, 012, , , , .T., , "", , , , .F. )
     oBtn2Bol   := TButton():New( 004, 196, "Imprime"   , oDlg1Bol, { || fSelTitulos()           }, 037, 012, , , , .T., , "", , , , .F. )
     oBtn3Bol   := TButton():New( 004, 254, "Cancela"   , oDlg1Bol, { || oDlg1Bol:End()          }, 037, 012, , , , .T., , "", , , , .F. )
     oGrp1Bol   := TGroup():New( 020, 004, 072, 292, "", oDlg1Bol, CLR_BLACK, CLR_WHITE, .T., .F. )
     oSay1Bol   := TSay():New( 026, 006, {||"Esse programa tem a função de imprimir boletos bancários."}, oGrp1Bol, , oFont1Bl, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 284, 012 )
     oSay2Bol   := TSay():New( 040, 006, {||"- Banco do Brasil"}                                        , oGrp1Bol, , oFont1Bl, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 096, 012 )
     oSay3Bol   := TSay():New( 054, 006, {||"- Bradesco"}                                               , oGrp1Bol, , oFont1Bl, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 084, 012 )

     oDlg1Bol:Activate(, , , .T.)
Return

Static Function fSelTitulos()
       If mv_par01 == 1
          /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
          ±± Definicao do Dialog e todos os seus componentes.                        ±±
          Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
          nOpca := 0
          oFont2Bo   := TFont():New( "MS Sans Serif", 0, -19, , .T., 0, , 700, .F., .F., , , , , , )
          oFont3Bo   := TFont():New( "MS Sans Serif", 0, -13, , .T., 0, , 700, .F., .F., , , , , , )
          oDlg2Bol   := MSDialog():New( 095, 232, 380, 532, "Seleção de Duplicatas", , , .F., , , , , , .T., , , .T. )
          oSay4Bol   := TSay():New( 004, 004, {|| "NF / Série:"}, oDlg2Bol, , oFont2Bo, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 056, 013 )
          oGet1Bol   := TGet():New( 002, 064, {|u| If(PCount() > 0, cGet1Bol := u, cGet1Bol) }, oDlg2Bol, 080, 014, '@!R 999999XXX/XXX', , CLR_BLACK, CLR_WHITE, oFont2Bo, , , .T., "", , , .F., .F., , .F., .F., "", "cGet1Bol", , )
          oBtn4Bol   := TButton():New( 020, 106, "Adiciona", oDlg2Bol, { || fAddNf() }, 037, 012, , , , .T., , "", , , , .F. )
          oMGet1Bo   := TMultiGet():New( 036, 004, {|u| If( PCount() > 0, cMGet1Bo := u, cMGet1Bo) }, oDlg2Bol, 145, 088, oFont3Bo, , CLR_BLACK, CLR_WHITE, , .T., "", , , .F., .F., .F., , , .F., , )
          oBtn5Bol   := TButton():New( 128, 106, "Cancela" , oDlg2Bol, { || nOpca := 1, oDlg2Bol:End() }, 037, 012, , , , .T., , "", , , , .F. )
          oBtn6Bol   := TButton():New( 128, 060, "Confirma", oDlg2Bol, { || fImprAvulso()  }, 037, 012, , , , .T., , "", , , , .F. )
          oGet1Bol:bValid := { || fExistNf() }
          oDlg2Bol:Activate(, , , .T.)
          If nOpca == 1 //Cancela
             aMGet1Bo := {}
          Endif
       Else
          cQry1 := "" 
          cQry2 := "" 
          cQry3 := ""
          cQry1 += "SELECT SF2.F2_FILIAL, SF2.F2_DOC, SF2.F2_SERIE "
          cQry2 += "SELECT COUNT(SF2.R_E_C_N_O_) AS QTDREG "
          cQry3 += "FROM "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) "
          cQry3 += "LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SF2.F2_FILIAL = SC5.C5_FILIAL) AND (SF2.F2_PEDIDO = SC5.C5_NUM) AND (SC5.D_E_L_E_T_ <> '*') "
          cQry3 += "WHERE (SF2.F2_FILIAL = '"+xFilial("SF2")+"') "
          cQry3 += "  AND (SF2.D_E_L_E_T_ <> '*') "
          cQry3 += "  AND (SF2.F2_EMISSAO BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"') "
          cQry3 += "  AND (SC5.C5_BOLETO = 'S') "
          cQry3 += "  AND (SC5.C5_CONDPAG = '001') "
          cQry1 += cQry3
          cQry1 += "ORDER BY SF2.F2_DOC "
          cQry2 += cQry3
          TCQuery cQry2 ALIAS "TCQ" NEW
          DbSelectArea("TCQ")
          DbGoTop()
          nQtdReg := TCQ->QTDREG
          DbSelectArea("TCQ")
          DbCloseArea()
          If nQtdReg > 0
             TCQuery cQry1 ALIAS "TCQ" NEW
             DbSelectArea("TCQ")
             DbGoTop()
             If mv_par04 == 1     //Imprime Banco do Brasil
                Processa( { |lEnd| fEnviaBBrasil() } )
             ElseIf mv_par04 == 2 //Imprime Bradesco
                    Processa( { |lEnd| fEnviaBradesco() } )
             Endif
             DbSelectArea("TCQ")
             DbCloseArea()
          Else
             MSgStop("Atenção, não existem registros a serem impressos, verifique os parâmetros!")
          Endif
       Endif
       oDlg1Bol:End()
Return

Static Function fImprAvulso()
       Local cFiltro := ""
       Local nY, nX
       For nY := 1 To Len(aMGet1Bo)
           For nX := 1 To 3
               If !Empty(aMGet1Bo[nY][nX])
                  cFiltro += "'"+aMGet1Bo[nY][nX]+"', "
               Endif
           Next
       Next
       cFiltro := SubStr(cFiltro, 1, ( Len( Alltrim( cFiltro ) ) - 1 ) )
       
       cQry1 := ""; cQry2 := ""; cQry3 := ""
       cQry1 += "SELECT SF2.F2_FILIAL, SF2.F2_DOC, SF2.F2_SERIE "
       cQry2 += "SELECT COUNT(SF2.R_E_C_N_O_) AS QTDREG "
       cQry3 += "FROM "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) "
       cQry3 += "WHERE SF2.F2_FILIAL = '"+xFilial("SF2")+"' "
       cQry3 += "  AND SF2.F2_DOC+SF2.F2_SERIE IN("+cFiltro+") "
       cQry3 += "  AND SF2.D_E_L_E_T_ <> '*' "
       cQry1 += cQry3
       cQry1 += "ORDER BY SF2.F2_DOC "
       cQry2 += cQry3
       TCQuery cQry2 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()
       nQtdReg := TCQ->QTDREG
       DbSelectArea("TCQ")
       DbCloseArea()
       If nQtdReg > 0
          TCQuery cQry1 ALIAS "TCQ" NEW
          DbSelectArea("TCQ")
          DbGoTop()
          If mv_par04 == 1     //Imprime Banco do Brasil
             Processa( { |lEnd| fEnviaBBrasil() } )
          ElseIf mv_par04 == 2 //Imprime Bradesco
                 Processa( { |lEnd| fEnviaBradesco() } )
          Endif
          DbSelectArea("TCQ")
          DbCloseArea()
          aMGet1Bo := {}
          cMGet1Bo := ""
          oDlg2Bol:End()
       Else
          MSgStop("Atenção, não existem registros a serem impressos, verifique os parâmetros!")
          aMGet1Bo := {}
          cMGet1Bo := ""
          oDlg2Bol:End()
       Endif
Return

Static Function fEnviaBBrasil()
       Local nLinha := 0, lAvista

       SetPrvt("TAMANHO, LIMITE, TITULO, CDESC1, CDESC2, CDESC3, CSTRING, ARETURN")
       SetPrvt("CPERG, NLASTKEY, LI, CSAVSCR1, CSAVCUR1, CSAVROW1")
       SetPrvt("CSAVCOL1, CSAVCOR1, WNREL")

       tamanho  := "P"
       limite   := 80
       titulo   := "EMISSAO DE BOLETOS BANCARIOS"
       cDesc1   := "Este programa ira emitir boletos conforme"
       cDesc2   := "selecao anterior."
       cDesc3   := ""
       cString  := "TCQ"
       aReturn  := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
       cPerg    := ""
       nLastKey := 0
       nLin     := 0
       nCont    := 1
       wnrel    := "BRFINR01"
       wnrel    := SetPrint(cString, wnrel, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., , .F., )
       nLinha   := 0

       If LastKey() == 27 .Or. nLastKey == 27
          Return
       Endif

       SetDefault(aReturn, cString)

       If LastKey() == 27 .Or. nLastKey == 27
          Return
       Endif

       DbSelectArea("SC5")
       DbSetOrder(1)

       DbSelectArea("TCQ")

       ProcRegua(nQtdReg)
       SetPrc(0, 0)
       DbGoTop()
       While !Eof()
             DbSelectArea("SE1")
             DbSetOrder(1)
             DbSeek(xFilial("SE1")+TCQ->F2_SERIE+TCQ->F2_DOC, .F.)
             While !Eof() .and. (SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM) == (TCQ->F2_FILIAL+TCQ->F2_SERIE+TCQ->F2_DOC)
                   If SE1->E1_TIPO != "NF"
                      DbSelectArea("SE1")
                      SE1->(DbSkip())
                      Loop
                   Endif
                   nLinha += 2
                   @ nLinha, 000 PSAY CHR(15)
                   lAvista = .f.
                   DbSelectArea("SC5")
                   DbSeek(xFilial("SC5")+SE1->E1_PEDIDO)
                   If Found() .and. (SC5->C5_CONDPAG == "001") // Se for venda à vista
                      lAvista = .t.
                   Endif
                   @ nLinha, 091 PSAY IF(lAvista, "C/ APRESENTACAO", SE1->E1_VENCREA)
                   nLinha += 3
                   @ nLinha, 005 PSAY SE1->E1_EMISSAO
                   @ nLinha, 016 PSAY SE1->E1_PREFIXO+alltrim(SE1->E1_NUM)+SE1->E1_PARCELA
                   @ nLinha, 053 PSAY "B" // Especie Doc
                   @ nLinha, 063 PSAY "N" // Aceite
                   @ nLinha, 072 PSAY dDataBase
                   nLinha += 2
                   @ nLinha, 045 PSAY Transform(SE1->E1_VALOR,"@E 999,999,999.99")
                   @ nLinha, 090 PSAY Transform(SE1->E1_VALOR,"@E 999,999,999.99")
                   If !lAvista
                      nLinha += 3
                      @ nLinha, 010 PSAY "COBRAR R$ " + Transform((SE1->E1_VALOR * .0033),"@R 999.99") + " POR DIA DE ATRASO"
                      nLinha += 2
                      @ nLinha, 010 PSAY "** APOS VENCIMENTO PAGAVEL SOMENTE NO B. BRASIL"
                   Else
                      nLinha += 5
                   Endif 
                   nLinha += 2
                   @ nLinha, 090 PSAY Transform(SE1->E1_VALOR,"@E 999,999,999.99")
                   nLinha ++

                   DbSelectArea("SA1")
                   DbSetOrder(1)
                   DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)
                   @ nLinha, 010 PSAY AllTrim(SA1->A1_NOME)
                   nLinha ++
                   @ nLinha, 010 PSAY AllTrim(SA1->A1_ENDCOB)
                   nLinha ++
                   @ nLinha, 010 PSAY Transform(SA1->A1_CEP,"@R 99999-999") + "  " + AllTrim(SA1->A1_MUN) + "  " +AllTrim(SA1->A1_EST)
                   nLinha ++
                   @ nLinha, 010 PSAY If(Len(SA1->A1_CGC) > 11, "C.N.P.J. " + Transform(SA1->A1_CGC, "@R 99.999.999/9999-99"), "C.P.F." + Transform(SA1->A1_CGC,"@R 999.999.999-99") ) + chr(18)
                   nLinha += 6

                   DbSelectArea("SE1")
                   SE1->(DbSkip())
             EndDo

             DbSelectArea("TCQ")
             IncProc()
             DbSkip()
       Enddo

       SET DEVICE TO SCREEN

       If aReturn[5] == 1   // Se impressao em Disco, chama Spool. 
          Set Printer To 
          DbCommitAll()
          OurSpool(wnrel)
       Endif

       FT_PFLUSH()          // Libera relatorio para Spool da Rede.

Return

Static Function fEnviaBradesco()
       //Local nI , nHoras , dData
       //Local nHeight    := 15
       //Local lBold      := .F.
       //Local lUnderLine := .F.
       //Local lPixel     := .T.
       //Local lPrint     := .F.
       Local oFont1     := TFont():New( "Courier New"    , , 08, , .F., , , ,    , .f. )
       Local oFont2     := TFont():New( "Courier New"    , , 12, , .t., , , ,    , .f. )
       //Local oFont3     := TFont():New( "Times New Roman", , 18, , .t., , , , .T., .f. )
       //Local oFont4     := TFont():New( "Courier New"    , , 20, , .t., , , ,    , .f. )
       Local oPrn       := TMSPrinter():New()
       Local nPag       := 1
       //Local nTPag      := SE1->(FCount())
       //Local nLin       := 0
       //Local cPeriodo
       Local lAvista
       Local lReimprime := .f.
       Local _cNNBrade  := GETMV("MV_NNBRADE")
       Private lContinua := .T.
       //oPrn:SetPortrait()
       //oPrn:Setup()
       //oPrn:EndPage()   //finaliza pagina
       //oPrn:StartPage() //inicializa pagina por problemas duplicação registro - Renato/Michel

       DbSelectArea( "SE1" )
       cAgencia := "3383-9"
       cCart    := "09"
       cAno     := "00"
       cConta   := "29770-4"
       Modulo   := 11
       nCont    := 0
       
       //AVPRINT oPrn NAME "Impressão de Ordens de Produção."
       //AVPAGE
       ProcRegua(nQtdReg)
       DbSelectArea("TCQ")
       DbGoTop()
       While !Eof()
             DbSelectArea("SE1")
             DbSetOrder(1)
             DbSeek(TCQ->F2_FILIAL+TCQ->F2_SERIE+TCQ->F2_DOC, .t.)
             If Found()
                While !Eof() .and. SE1->E1_FILIAL == TCQ->F2_FILIAL .and. SE1->E1_PREFIXO == TCQ->F2_SERIE .and. SE1->E1_NUM == TCQ->F2_DOC
                      If SE1->E1_TIPO != "NF"
                         DbSelectArea("SE1")
                         SE1->(DbSkip())
                         Loop
                      Endif
                      lReimprime := .f.
                      If !Empty(SE1->E1_NUMBCO)
                         If MsgYesNo("Boleto "+SubStr(SE1->E1_NUMBCO, 1, 11)+"-"+SubStr(SE1->E1_NUMBCO, 11, 2)+"já foi impresso anteriormente, deseja re-imprimí-lo?", "Re-impressão")
                            cNumReimpr := SubStr(SE1->E1_NUMBCO, 1, 11)
                            cDigReimpr := SubStr(SE1->E1_NUMBCO, 11, 2)
                            lReimprime := .t.
                         Else
                            DbSelectArea("SE1")
                            SE1->(DbSkip())
                            Loop
                         Endif
                      Endif
                      lAvista := .f.
                      DbSelectArea("SC5")
                      DbSetOrder(1)
                      DbSeek(xFilial("SC5")+SE1->E1_PEDIDO)
                      If Found() .and. (SC5->C5_CONDPAG == "001") // Se for venda à vista
                         lAvista := .t.
                      Endif

                      //Dados do Cliente
                      DbSelectArea("SA1")
                      DbSetOrder(1)
                      DbSeek(xFilial()+SE1->E1_CLIENTE)
                      nCont := nCont + 1
                      If lEnd
                         @ PROW()+1, 001 PSAY "CANCELADO PELO OPERADOR"
                         Exit
                      Endif

                      /**************************************/
                      /*** Calculos do Boleto             ***/
                      /**************************************/
                      //1º Obter nosso numero
                      Private cCarteira    := "19"
                      //LGS#20200130 - Adequação para release 12.1.25 e posteriores
                      //Private cNossoNumero := Iif(lReimprime, cNumReimpr, GETMV("MV_NNBRADE") )
                      Private cNossoNumero := Iif(lReimprime, cNumReimpr, _cNNBrade )
                      If !lReimprime
                         PutMv("MV_NNBRADE", StrZero( ( Val( cNossoNumero ) + 1 ), 11) ) //Gravo o próximo numero no parâmetro
                      Endif
                      cDigitoVerificador := Iif(lReimprime, cDigReimpr, fCalculaDigito(1) )
                      cDigitoVerificador := Iif( ValType(cDigitoVerificador) == "N", StrZero(cDigitoVerificador, 1), cDigitoVerificador)
                      
                      //2º Obter Linha Digitável para Boleto
                        //a) Composição do Campo Livre
                        Private dDataBaseBrad   := CtoD("07/10/1997")
                        Private cAgenciaCedente := "3383"
                        Private cBanco          := "237"
                        Private cMoeda          := "9"
                        Private cNumeroNNumero  := cNossoNumero
                        Private cContaCedente   := "0029770"
                        Private cZero           := "0"
                        Private cCodigoLivre    := cAgenciaCedente + cCarteira + cNumeroNNumero + cContaCedente + cZero
                        Private aDigitosVerif   := fCalculaDigito(2)
                        //Cleber (13/03/17), chamado 006717, trocar vencimento para 14 dias após a emissão ao invés de usar como ref. a data de vencimento
                        Private cFatorVencto    := StrZero( Iif(lAvista, SE1->E1_EMISSAO + 15, SE1->E1_VENCREA) - dDataBaseBrad, 4 )
                        Private cValorDocumento := StrZero( Val( StrTran( StrTran( Alltrim(TransForm( Round( SE1->E1_VALOR, 2 ), "@E 9,999,999,999.99" )), ","), "." ) ), 10 )
                        Private cPrimeiroCampo  := cBanco + cMoeda + SubStr(cCodigoLivre, 1, 5) + StrZero(aDigitosVerif[1], 1)
                        Private cSegundoCampo   := SubStr(cCodigoLivre,  6, 10) + StrZero(aDigitosVerif[2], 1)
                        Private cTerceiroCampo  := SubStr(cCodigoLivre, 16, 10) + StrZero(aDigitosVerif[3], 1)
                        Private cQuartoCampo    := StrZero(fCalculaDigito(3), 1)
                        Private cQuintoCampo    := cFatorVencto + cValorDocumento
                        Private cLinhaDigitavel := SubStr(cPrimeiroCampo, 1, 5)+"."+SubStr(cPrimeiroCampo, 6, 5)+" "+SubStr(cSegundoCampo, 1, 5)+"."+SubStr(cSegundoCampo, 6, 6)+" "+SubStr(cTerceiroCampo, 1, 5)+"."+SubStr(cTerceiroCampo, 6, 6)+" "+cQuartoCampo+" "+cQuintoCampo

                      //3º Obter Código de Barras
                      cCodigoBarras := cBanco + cMoeda + cQuartoCampo + cFatorVencto + cValorDocumento + cCodigoLivre
                      //Alltrim(SubStr( cPrimeiroCampo, 1, Len(cPrimeiroCampo) - 1 ) + SubStr( cSegundoCampo, 1, Len(cSegundoCampo) - 1 ) + SubStr( cTerceiroCampo, 1, Len(cTerceiroCampo) - 1 ) + cQuartoCampo + cQuintoCampo)

                      //Inicio da Impressão
                      oPrn:Say(000, 0000, " ", oFont1, 100 ) // startando a impressora
                      DbSelectArea("SE1")
                      If nPag <> 1 // Fim de Pagina
                         oPrn:EndPage()
                         oPrn:StartPage()
                      Endif
                      If !lReimprime
                         RecLock("SE1", .f.)
                            SE1->E1_NUMBCO  := cNossoNumero+cDigitoVerificador
                            SE1->E1_NATUREZ := '802021'
                         MsUnLock()
                      Endif
                      SET CENTURY ON
                      cNumDocumento := Alltrim(SE1->E1_NUM)+"/"+Alltrim(SE1->E1_PARCELA)
                      cNumNNumero   := cNossoNumero+"-"+cDigitoVerificador
                      cNosNumero    := "19/"+cNossoNumero+"-"+cDigitoVerificador
                      /**************************************************************************************************************/
                      //1º Parte do Boleto - Recibo do Sacado
                      oPrn:SayBitmap(0100, 0000, "bradesco.bmp", 0400, 0070)        //Logotipo do Banco
                      oPrn:Box(0100, 0427, 0180, 0430)                              //Divisão Logotipo / Banco
                      oPrn:Say(0100, 0440, "Banco"                  , oFont1, 100)  //Banco
                      oPrn:Box(0100, 0610, 0180, 0613)                              //Divisão Banco / Recibo do Sacado
                      oPrn:Say(0130, 0460, "237-2"                  , oFont2, 100)  //Código do Banco
                      oPrn:Say(0130, 1920, "Recibo do Sacado"       , oFont2, 100)  //Recibo do Sacado
                      oPrn:Box(0180, 0000, 0183, 2350)                              //Traço

                      oPrn:Say(0180, 0020, "Cedente"                , oFont1, 100)  //Cedente
                      oPrn:Box(0180, 1497, 0260, 1500)                              //Divisão Cedente / Nosso Numero
                      oPrn:Say(0180, 1510, "Nosso Numero"           , oFont1, 100)  //Nosso Numero
                      oPrn:Box(0180, 1897, 0500, 1900)                              //Divisão - Traço
                      oPrn:Say(0180, 1910, "Vencimento"             , oFont1, 100)  //Vencimento
                      oPrn:Say(0205, 0030, SM0->M0_NOMECOM          , oFont2, 100)  //Nome do Cendente
                      oPrn:Say(0205, 1520, cNumNNumero              , oFont2, 100)  //Nosso Numero
                      oPrn:Say(0205, 1920, Iif(lAvista, "C/APRESENTAÇÃO", dtoc(SE1->E1_VENCREA) )    , oFont2, 100)  //Data de Vencimento
                      oPrn:Box(0260, 0000, 0263, 2350)                              //Traço

                      oPrn:Say(0260, 0020, "Data de Emissão"        , oFont1, 100)                    //Data do Documento
                      oPrn:Box(0260, 0427, 0340, 0430)                                                //Divisão Data do Documento / Nº do Documento
                      oPrn:Say(0260, 0440, "Nº do Documento"        , oFont1, 100)                    //Nº do Documento
                      oPrn:Box(0260, 1087, 0340, 1090)                                                //Divisão Nº do Documento / Espécie Documento
                      oPrn:Say(0260, 1100, "Espécie Documento"      , oFont1, 100)                    //Espécie Documento
                      oPrn:Box(0260, 1547, 0340, 1550)                                                //Divisão Espécie Documento / Data Processamento
                      oPrn:Say(0260, 1560, "Data Processamento"     , oFont1, 100)                    //Data Processamento
                      oPrn:Say(0260, 1910, "Agência/Código Cedente" , oFont1, 100)                    //Agência / Código Cedente
                      oPrn:Say(0290, 0030, Dtoc(SE1->E1_EMISSAO)    , oFont2, 100)                    //Data do Documento
                      oPrn:Say(0290, 0450, cNumDocumento            , oFont2, 100)              //Nº do Documento
                      oPrn:Say(0290, 1200, "DM"                     , oFont2, 100)                    //Espécie do Documento
                      oPrn:Say(0290, 1570, Dtoc(dDataBase)          , oFont2, 100)                    //Data do Processamento
                      oPrn:Say(0290, 1920, cAgencia+" / "+cConta  , oFont2, 100)                    //Agência / Código Cedente
                      oPrn:Box(0340, 0000, 0343, 2350)                                                //Traço
                      
                      oPrn:Say(0340, 0020, "Uso do Banco"           , oFont1, 100)                    //Uso do Banco
                      oPrn:Box(0340, 0327, 0420, 0330)                                                //Divisão - Traço
                      oPrn:Say(0340, 0340, "CIP"                    , oFont1, 100)                    //Carteira
                      oPrn:Box(0340, 0477, 0500, 0480)                                                //Divisão - Traço
                      oPrn:Say(0340, 0490, "Carteira"               , oFont1, 100)                    //Carteira
                      oPrn:Box(0340, 0737, 0420, 0740)                                                //Divisão 
                      oPrn:Say(0340, 0750, "Espécie"                , oFont1, 100)                    //Espécie
                      oPrn:Box(0340, 1027, 0500, 1030)                                                //Divisão 
                      oPrn:Say(0340, 1040, "Quantidade"             , oFont1, 100)                    //Quantidade
                      oPrn:Box(0340, 1497, 0360, 1500)                                                //Divisão 
                      oPrn:Say(0365, 1492, "X"                      , oFont1, 100)                    //Sinal de Multiplicação
                      oPrn:Box(0400, 1497, 0500, 1500)                                                //Divisão 
                      oPrn:Say(0340, 1510, "Valor"                  , oFont1, 100)                    //Valor
                      oPrn:Say(0340, 1910, "(=) Valor do Documento" , oFont1, 100)                    //(=) Valor do Documento
                                                                                                      //Uso do Banco
                      oPrn:Say(0370, 0360, "000"                    , oFont2, 100)                    //CIP
                      oPrn:Say(0370, 0540, "19"                     , oFont2, 100)                    //Carteira
                      oPrn:Say(0370, 0800, "R$"                     , oFont2, 100)                    //Espécie
                                                                                                      //Quantidade
                                                                                                      //Valor
                      oPrn:Say(0370, 1910, Transform(SE1->E1_VALOR, "@E 9,999,999,999.99" ), oFont2, 100) // Valor Documento
                      oPrn:Box(0420, 0000, 0423, 2350)                                                //Traço
                      

                      oPrn:Say(0420, 0020, "(-) Desconto/Abatimento", oFont1, 100)  //(-) Desconto/Abatimento
                      oPrn:Say(0420, 0490, "(-) Outras Deduções"    , oFont1, 100)  //(-) Outras Deduções
                      oPrn:Say(0420, 1040, "(+) Mora/Multa"         , oFont1, 100)  //(+) Mora/Multa
                      oPrn:Say(0420, 1510, "(+) Outros Acréscimos"  , oFont1, 100)  //(+) Outros Acréscimos
                      oPrn:Say(0420, 1910, "(=) Valor Cobrado"      , oFont1, 100)  //Data do Documento
                      oPrn:Box(0500, 0000, 0503, 2350)                              //Traço

                      oPrn:Say(0500, 0020, "Sacado"                 , oFont1, 100)  //Sacado
                      oPrn:Box(0500, 1547, 0530, 1550)                              //Traço
                      oPrn:Say(0500, 1560, "Autenticação Mecânica"  , oFont1, 100)  //Autenticação Mecânica
                      oPrn:Say(0510, 0130, SA1->A1_NOME             , oFont2, 100)  //Nome do Sacado
                      oPrn:Say(0700, 0000, '------------------------------------------------------------------------------------------------------------------------------------------------', oFont1, , , , )
                      /**************************************************************************************************************/
                      //2º Parte do Boleto - Ficha de Compensação
                      oPrn:SayBitmap(0800, 0000, "bradesco.bmp", 0400, 0070)        //Logotipo do Banco
                      oPrn:Box(0800, 0427, 0880, 0430)                              //Divisão Logotipo / Banco
                      oPrn:Say(0800, 0440, "Banco"                  , oFont1, 100)  //Banco
                      oPrn:Box(0800, 0610, 0880, 0613)                              //Divisão Banco / Recibo do Sacado
                      oPrn:Say(0830, 0460, "237-2"                  , oFont2, 100)  //Código do Banco
                      oPrn:Say(0830, 0750, cLinhaDigitavel          , oFont2, 100)  //Linha Digitável
                      oPrn:Box(0880, 0000, 0883, 2350)                              //Traço
                      
                      oPrn:Say(0880, 0020, "Local de Pagamento"     , oFont1, 100)                                    //Local de Pagamento
                      oPrn:Say(0880, 1910, "Vencimento"             , oFont1, 100)                                    //Vencimento
                      oPrn:Box(0880, 1897, 1670, 1900)                                                                //Divisão - Traço
                      oPrn:Say(0930, 0030, "Pagável preferencialmente na Rede Bradesco ou Banco Postal", oFont2, 100) //Informação do Local de Pagamento
                      oPrn:Say(0930, 1920, Iif(lAvista, "C/APRESENTAÇÃO", dtoc(SE1->E1_VENCREA) )      , oFont2, 100) //Data de Vencimento
                      oPrn:Box(1000, 0000, 1003, 2350)                                                                //Traço

                      oPrn:Say(1000, 0020, "Cedente"                , oFont1, 100)                                    //Cedente
                      oPrn:Say(1000, 1910, "Agência/Código Cedente" , oFont1, 100)                                    //Agência / Código Cedente                      
                      oPrn:Say(1030, 0030, SM0->M0_NOMECOM          , oFont2, 100)                                    //Nome do Cendente
                      oPrn:Say(1030, 1920, cAgencia+" / "+cConta    , oFont2, 100)                                    //Agência / Código Cedente
                      oPrn:Box(1110, 0000, 1113, 2350)                                                                //Traço

                      oPrn:Say(1110, 0020, "Data do Emissão"        , oFont1, 100)                                    //Data do Documento
                      oPrn:Box(1110, 0427, 1190, 0430)                                                                //Divisão Data do Documento / Nº do Documento
                      oPrn:Say(1110, 0440, "Nº do Documento"        , oFont1, 100)                                    //Nº do Documento
                      oPrn:Box(1110, 1087, 1190, 1090)                                                                //Divisão Nº do Documento / Espécie Documento
                      oPrn:Say(1110, 1100, "Espécie Documento"      , oFont1, 100)                                    //Espécie Documento
                      oPrn:Box(1110, 1432, 1190, 1435)                                                                //Divisão Espécie Documento / Aceite
                      oPrn:Say(1110, 1445, "Aceite"                 , oFont1, 100)                                    //Aceite
                      oPrn:Box(1110, 1547, 1190, 1550)                                                                //Divisão Aceite / Data Processamento
                      oPrn:Say(1110, 1560, "Data Processamento"     , oFont1, 100)                                    //Data Processamento
                      oPrn:Say(1110, 1910, "Carteira/Nosso Numero"  , oFont1, 100)                                    //Agência / Código Cedente
                      oPrn:Say(1140, 0030, Dtoc(SE1->E1_EMISSAO)    , oFont2, 100)                                    //Data do Documento
                      oPrn:Say(1140, 0450, cNumDocumento            , oFont2, 100)                                    //Nº do Documento
                      oPrn:Say(1140, 1200, "DM"                     , oFont2, 100)                                    //Espécie do Documento
                      oPrn:Say(1140, 1480, "N"                      , oFont2, 100)                                    //Aceite
                      oPrn:Say(1140, 1570, Dtoc(dDataBase)          , oFont2, 100)                                    //Data do Processamento
                      oPrn:Say(1140, 1920, cNosNumero, oFont2, 100)                    //Cateira / Nosso Numero
                      oPrn:Box(1190, 0000, 1193, 2350)                                                                //Traço
                      
                      oPrn:Say(1190, 0020, "Uso do Banco"           , oFont1, 100)                                    //Uso do Banco
                      oPrn:Box(1190, 0327, 1270, 0330)                                                                //Divisão - Traço
                      oPrn:Say(1190, 0340, "CIP"                    , oFont1, 100)                                    //Carteira
                      oPrn:Box(1190, 0477, 1270, 0480)                                                                //Divisão - Traço
                      oPrn:Say(1190, 0490, "Carteira"               , oFont1, 100)                                    //Carteira
                      oPrn:Box(1190, 0737, 1270, 0740)                                                                //Divisão 
                      oPrn:Say(1190, 0750, "Espécie"                , oFont1, 100)                                    //Espécie
                      oPrn:Box(1190, 1027, 1270, 1030)                                                                //Divisão 
                      oPrn:Say(1190, 1040, "Quantidade"             , oFont1, 100)                                    //Quantidade
                      oPrn:Box(1190, 1497, 1210, 1500)                                                                //Divisão 
                      oPrn:Say(1215, 1492, "X"                      , oFont1, 100)                                    //Sinal de Multiplicação
                      oPrn:Box(1250, 1497, 1270, 1500)                                                                //Divisão 
                      oPrn:Say(1190, 1510, "Valor"                  , oFont1, 100)                                    //Valor
                      oPrn:Say(1190, 1910, "(=) Valor do Documento" , oFont1, 100)                                    //(=) Valor do Documento
                                                                                                                      //Uso do Banco
                      oPrn:Say(1220, 0360, "000"                    , oFont2, 100)                                    //CIP
                      oPrn:Say(1220, 0540, "19"                     , oFont2, 100)                                    //Carteira
                      oPrn:Say(1220, 0800, "R$"                     , oFont2, 100)                                    //Espécie
                                                                                                                      //Quantidade
                                                                                                                      //Valor
                      oPrn:Say(1220, 1910, Transform(SE1->E1_VALOR, "@E 9,999,999,999.99" ), oFont2, 100)             // Valor Documento
                      oPrn:Box(1270, 0000, 1273, 2350)                                                                //Traço

                      oPrn:Say(1270, 0020, "Instruções:"            , oFont1, 100)                                    //Instruções
                      oPrn:Say(1270, 1910, "(-) Desconto/Abatimento", oFont1, 100)                                    //(-) Desconto/Abatimento
                      oPrn:Box(1350, 1897, 1353, 2350)                                                                //Traço
                      
                      oPrn:Say(1350, 1910, "(-) Outras Deduções"    , oFont1, 100)                                    //(-) Outras Deduções
                      oPrn:Box(1430, 1897, 1433, 2350)                                                                //Traço
                      
                      oPrn:Say(1430, 1910, "(+) Mora/Multa"         , oFont1, 100)                                    //(+) Mora/Multa
                      oPrn:Box(1510, 1897, 1513, 2350)                                                                //Traço
                      
                      oPrn:Say(1510, 1910, "(+) Outros Acréscimos"  , oFont1, 100)                                    //(+) Outros Acréscimos
                      oPrn:Box(1590, 1897, 1593, 2350)                                                                //Traço
                      
                      oPrn:Say(1590, 1910, "(=) Valor Cobrado"      , oFont1, 100)                                    //Data do Documento
                      oPrn:Box(1670, 0000, 1673, 2350)                                                                //Traço

                      oPrn:Say(1670, 0020, "Sacado"                 , oFont1, 100)                                    //Sacado
                      oPrn:Say(1670, 1560, "CPF/CNPJ"               , oFont1, 100)                                    //CPF/CNPJ
                      oPrn:Say(1800, 0020, "Sacador/Avalista"       , oFont1, 100)                                    //CPF/CNPJ
                      oPrn:Say(1680, 0130, SA1->A1_NOME             , oFont2, 100)                                    //Nome do Sacado
                      If Len(Alltrim(SA1->A1_CGC)) == 11
                         oPrn:Say(1680, 1700, Transform(SA1->A1_CGC, "@R 999.999.999-99")    , oFont2, 100)           //CPF
                      Else
                         oPrn:Say(1680, 1700, Transform(SA1->A1_CGC, "@R 99.999.999/9999-99"), oFont2, 100)           //CNPJ
                      Endif
                      oPrn:Say(1720, 0130, SA1->A1_END              , oFont2, 100)                                    //Endereço do Sacado
                      oPrn:Say(1760, 0130, TransForm(SA1->A1_CEP, "@R 99999-999"), oFont2, 100)                       //CEP
                      oPrn:Say(1760, 1040, Alltrim(SA1->A1_MUN)     , oFont2, 100)                                    //Municipio
                      oPrn:Say(1760, 1660, Alltrim(SA1->A1_EST)     , oFont2, 100)                                    //Estado
                      oPrn:Box(1830, 0000, 1833, 2350)                                                                //Traço

                      oPrn:Box(1830, 1547, 1860, 1550)                                                                //Traço
                      oPrn:Say(1830, 1560, "Autenticação Mecânica     FICHA DE COMPENSAÇÃO"  , oFont1, 100)           //Autenticação Mecânica

                      //MsBar("INT25"  , 16, 0.5, cCodigoBarras  , oPrn, .F., , .T., 0.025, 1.3)
                      MsBar("INT25"  , 16.5, 0.5, cCodigoBarras  , oPrn, .F., Nil, Nil, 0.025, 1.3, Nil, Nil, "A", .f.)
                      
                      //AVNEWPAGE
                      nPag ++
                      SET CENTURY OFF
                      DbSelectArea("SE1")
                      DbSkip()
                Enddo
             Endif
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       //AVENDPAGE
       //AVENDPRINT
       oPrn:Preview()
       //oPrn:Print()   // descomentar esta linha para imprimir
       MS_FLUSH()
Return

/*
Static Function cDigi()
       lBase  := Len(V_Base)
       UmDois := 2
       SumDig := 0
       Auxi   := 0
       iDig   := lBase
       While iDig >= 1
             Auxi   := Val( SubStr(V_base, idig, 1) ) * UmDois
             SumDig := SumDig + Iif(Auxi < 10, Auxi, INT(Auxi / 10) + Auxi % 10)
             UmDois := 3 - UmDois
             iDig   := iDig - 1
       Enddo
       Auxi   := Str( Round( SumDig / 10 + 0.49, 0) * 10 - SumDig, 1)
       V_Base := V_Base + Auxi
Return*/

Static Function fAddNf()
       Local nY, nX
       For nY := 1 To Len(aMGet1Bo)
           For nX := 1 To 3
               If !Empty(aMGet1Bo[nY][nX])
                  If aMGet1Bo[nY][nX] $ cGet1Bol
                     MsgStop("Atenção, Nota Fiscal / Série, já foi digitada anteriormente")
                     nY := Len(aMGet1Bo)+1
                     nX := 4
                     cGet1Bol := space(12)
                     oGet1Bol:Refresh()
                     oGet1Bol:SetFocus()
                     Return
                  Endif
               Endif
           Next
       Next
       If Len(aMGet1Bo) == 0
          aAdd(aMGet1Bo, {cGet1Bol, "", ""} )
          cMGet1Bo := cGet1Bol
       Else
          nLinhas := Len(aMGet1Bo)
          nPosGrv := 0
          For nY := 1 To 3
              If Empty(aMGet1Bo[nLinhas][nY])
                 nPosGrv := nY
                 nY := 4
              Endif
          Next
          If nPosGrv == 0
             aAdd(aMGet1Bo, {cGet1Bol, "", ""} )
             cMGet1Bo += Chr(13)+Chr(10)
             cMget1Bo += cGet1Bol
          Else
             aMGet1Bo[nLinhas][nPosGrv] := cGet1Bol
             cMGet1Bo += "  |  "+cGet1Bol
          Endif
       Endif
       cGet1Bol := space(12)
       oGet1Bol:Refresh()
       oGet1Bol:SetFocus()
Return

Static Function fExistNf()
       Local lRet
       lRet = .t.
       If !Empty(cGet1Bol)
          DbSelectArea("SF2")
          DbSetOrder(1)
          DbSeek(xFilial("SF2")+cGet1Bol)
          If !Found() 
             lRet = .f.
             MsgStop("Numero da Nota Fiscal Invalido!")
             cGet1Bol := space(12)
             oGet1Bol:Refresh()
          Endif
       Endif
Return(lRet)

Static Function ValidPerg()
       Local _sAlias, aRegs, i, j
       _sAlias := Alias()
       DbSelectArea("SX1")
       DbSetOrder(1)
       cPergBol := PADR(cPergBol, 10)
       aRegs := {}

       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs, {cPergBol, "01", "Tipo de Selecao  ?", "", "", "mv_ch1", "N", 01, 0, 2, "C", "", "mv_par01", "Selecao Manual" , "", "", "", "", "Ped Marcados", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs, {cPergBol, "02", "Nfs Emitidas De  ?", "", "", "mv_ch2", "D", 08, 0, 0, "G", "", "mv_par02", ""               , "", "", "", "", ""            , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs, {cPergBol, "03", "Nfs Emitidas Ate ?", "", "", "mv_ch3", "D", 08, 0, 0, "G", "", "mv_par03", ""               , "", "", "", "", ""            , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs, {cPergBol, "04", "Selecione o Banco?", "", "", "mv_ch4", "N", 01, 0, 2, "C", "", "mv_par04", "Banco do Brasil", "", "", "", "", "Bradesco"    , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})

       For i := 1 to Len(aRegs)
           If !DbSeek(cPergBol+aRegs[i][2])
              RecLock("SX1", .T.)
              For j := 1 to FCount()
                  If j <= Len(aRegs[i])
                     FieldPut(j, aRegs[i][j])
                  Endif
              Next
              MsUnlock()
           Endif
       Next
       DbSelectArea(_sAlias)
Return

Static Function fCalculaDigito(nCalc)
       Local nRetDig := 0
       Local nAux
       If nCalc == 1 //Calculo do Digito Verificador do Nosso Numero
          aAuxCalc := {2, 7, 6, 5, 4, 3, 2, 7, 6, 5, 4, 3, 2}
          cAuxCalc := cCarteira+cNossoNumero
          nSomAux  := 0
          For nAux := 1 to Len(cAuxCalc)
              nSomAux += Val(SubStr(cAuxCalc, nAux, 1)) * aAuxCalc[nAux]
          Next
          nResAux := Mod(nSomAux, 11)
          If nResAux == 0
             nRetDig := 0
          Else
             nRstAux := 11 - nResAux
             If nRstAux  == 10
                nRetDig := "P"
             Else
                nRetDig := nRstAux
             Endif
          Endif
       ElseIf nCalc == 2 //Calculo das 3 primeiras partes da linha digitável
              aAuxCalc := {2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2}
              cAuxCalc := cBanco + cMoeda + cCodigoLivre
              nSom1Par := 0
              nSom2Par := 0
              nSom3Par := 0
              nAuxCalc := 0
              For nAux := 1 To Len(cAuxCalc)
                  If nAux <= 9 //Soma da 1º Parte
                     nAuxCalc := Val( SubStr(cAuxCalc, nAux, 1) ) * aAuxCalc[nAux]
                     If nAuxCalc == 10
                        nAuxCalc := 1
                     ElseIf nAuxCalc > 10
                            nAuxCalc := Int( (nAuxCalc / 10) ) + ( ( ( nAuxCalc / 10 ) - Int( ( nAuxCalc / 10 ) ) ) * 10 )
                     Endif
                     nSom1Par += nAuxCalc
                     nMultDez := Iif( Mod(nSom1Par, 10) == 0, nSom1Par, ( Int( nSom1Par / 10 ) + 1 ) * 10 )
                     nDig1Ver := nMultDez - nSom1Par
                  ElseIf nAux >= 10 .and. nAux <= 19
                         nAuxCalc := Val( SubStr(cAuxCalc, nAux, 1) ) * aAuxCalc[nAux]
                         If nAuxCalc == 10
                            nAuxCalc := 1
                         ElseIf nAuxCalc > 10
                                nAuxCalc := Int( (nAuxCalc / 10) ) + ( ( ( nAuxCalc / 10 ) - Int( ( nAuxCalc / 10 ) ) ) * 10 )
                         Endif
                         nSom2Par += nAuxCalc
                         nMultDez := Iif( Mod(nSom2Par, 10) == 0, nSom2Par, ( Int( nSom2Par / 10 ) + 1 ) * 10 )
                         nDig2Ver := nMultDez - nSom2Par
                  ElseIf nAux >= 20
                         nAuxCalc := Val( SubStr(cAuxCalc, nAux, 1) ) * aAuxCalc[nAux]
                         If nAuxCalc == 10
                            nAuxCalc := 1
                         ElseIf nAuxCalc > 10
                                nAuxCalc := Int( (nAuxCalc / 10) ) + ( ( ( nAuxCalc / 10 ) - Int( ( nAuxCalc / 10 ) ) ) * 10 )
                         Endif
                         nSom3Par += nAuxCalc
                         nMultDez := Iif( Mod(nSom3Par, 10) == 0, nSom3Par, ( Int( nSom3Par / 10 ) + 1 ) * 10 )
                         nDig3Ver := nMultDez - nSom3Par
                  Endif
              Next
              nRetDig := {nDig1Ver, nDig2Ver, nDig3Ver}
       ElseIf nCalc == 3
              aAuxCalc := { 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2}
              cAuxCalc := cBanco + cMoeda + cFatorVencto + cValorDocumento + cCodigoLivre
              nAuxCalc := 0
              For nAux := 1 To Len(cAuxCalc)
                  nAuxCalc += Val( SubStr(cAuxCalc, nAux, 1) ) * aAuxCalc[nAux]
              Next
              nResCalc := Mod(nAuxCalc, 11)
              nDifCalc := 11 - nResCalc
              If nDifCalc == 0 .or. nDifCalc == 1 .or. nDifCalc > 9
                 nRetDig := 1
              Else
                 nRetDig := nDifCalc
              Endif
       Endif
Return(nRetDig)
