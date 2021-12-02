#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NOVO5     º Autor ³ AP6 IDE            º Data ³  05/07/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRPCPR12()

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Declaracao de Variaveis                                             ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "Apuração de Apontamentos"
     //Local cPict         := ""
     Local titulo        := "Apuração de Apontamentos"
     Local nLin          := 80
     Local Cabec1        := "                                                                    |          ORDEM DE PRODUÇÃO           |       APONTAMENTO       |          BAIXA          |       BAIXA MOD2.       |"
     Local Cabec2        := "LOTE    ORDEM        PRODUTO          DESCRIÇÃO                     | QUANT. SOL.  QUANT. BAI.  DATA FIM   | QUANT. APT.  DATA FIM   | QUANT. SD3.  DATA FIM   | QUANT. SH6.  DATA FIM   | STATUS                         ST           "
     //Local imprime       := .T.
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     //Private CbTxt       := ""
     Private limite      := 220
     Private tamanho     := "G"
     Private nomeprog    := "BRPCPR12" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 15
     Private aReturn     := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := "PCPR12"
     Private cbtxt       := Space(10)
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private cNomArq	 := ""
     Private wnrel       := "BRPCPR12" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString := "ZZA"
     Private oTempTbl01
     u_zcfga01( 'BRPCPR12' ) //LGS#2021201 - Gravação de log de utilização da rotina
     DbSelectArea("ZZA")
     DbSetOrder(1)
     //fPerg()  //LGS#20200131 - Adequação de release 12.1.25 e posteriores
     Pergunte(cPerg, .T.)

     If mv_par03 == 2
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Monta a interface padrao com o usuario...                           ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        wnrel := SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho, , .F.)
        If nLastKey == 27
           Return
        Endif
        SetDefault(aReturn,cString)
        If nLastKey == 27
           Return
        Endif
        nTipo := If(aReturn[4]==1, 15, 18)
     Endif
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Processa({|| RunReport(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  05/07/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
       //Local nOrdem
       Local nY
       Local cQry1   := ''
       Local nQtdBai := 0
       Local nQtdPen := 0

       DbSelectArea(cString)
       DbSetOrder(1)

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ SETREGUA -> Indica quantos registros serao processados para a regua ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

       cQry1 := ""
       cQry2 := ""
       cQry3 := ""
       cQry1 += "SELECT CASE WHEN LEN(ZZA.ZZA_PRODUT) < 12 THEN 1 ELSE CASE WHEN LEN(ZZA.ZZA_PRODUT) = 12 AND SUBSTRING(ZZA.ZZA_PRODUT, 11, 2) = '00' THEN 2 ELSE 3 END END AS 'ORDEM', "
       cQry1 += " ZZA.ZZA_ORDEM, ZZA.ZZA_LOTE, ZZA.ZZA_PRODUT, ZZA.ZZA_SEQENV, ZZA.ZZA_FLAG, ZZA.ZZA_QUANT, ZZA.ZZA_DTFIM, ZZA.* "
       cQry2 += "SELECT COUNT(*) AS QTDREC "
       cQry3 += "FROM ZZA010 ZZA WITH (NOLOCK) "
       cQry3 += "WHERE ZZA.ZZA_FILIAL = '"+xFilial("ZZA")+"' "
       cQry3 += "  AND ZZA.D_E_L_E_T_ = '' "
       cQry3 += "  AND ( LEN(ZZA.ZZA_PRODUT) < 12 "
       cQry3 += "        OR SUBSTRING(ZZA.ZZA_PRODUT, 11, 2) = '00') "
       cQry3 += "  AND ZZA_DTFIM      BETWEEN '"+DTOS(mv_par01)+"' AND '"+DTOS(mv_par02)+"' "
       TCQuery cQry2+cQry3 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       If TCQ->QTDREC > 0
          ProcRegua(TCQ->QTDREC)
          DbSelectArea("TCQ")
          DbCloseArea()

          cQry3 += "ORDER BY 1, 3, 4 "
          TCQuery cQry1+cQry3 ALIAS "TCQ" NEW
          DbSelectArea("TCQ")
          DbGoTop()
          If mv_par03 == 2 //Relatório
             While !Eof()
                   If lAbortPrint
                      @ nLin,000 PSAY "*** CANCELADO PELO OPERADOR ***"
                      Exit
                   Endif

                   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                   //³ Impressao do cabecalho do relatorio. . .                            ³
                   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                   If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
                      nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
                      nLin += 1
                   Endif
                   If Len(Alltrim(TCQ->ZZA_PRODUT)) == 12
                      aQtdePA := {}
                      cQry1 := ""
                      cQry1 += "SELECT ZZA.ZZA_ORDEM, SC2.C2_PRODUTO, SZ5.Z5_EMB, SC2.C2_QUANT, ZZA.ZZA_SEQENV, ZZA.ZZA_FLAG, ZZA.ZZA_QUANT, SZ5.Z5_VOLUME, ZZA.ZZA_PESPES, (ZZA.ZZA_QUANT * SZ5.Z5_VOLUME) AS 'VOLUME' "
                      cQry1 += "FROM ZZA010 ZZA WITH (NOLOCK) "
                      cQry1 += "LEFT OUTER JOIN SZ5010 SZ5 WITH (NOLOCK) ON SZ5.Z5_FILIAL = '' AND SZ5.Z5_EMB = SUBSTRING(ZZA.ZZA_PRODUT, 11, 2) AND SZ5.D_E_L_E_T_ = '' "
                      cQry1 += "LEFT OUTER JOIN SC2010 SC2 WITH (NOLOCK) ON SC2.C2_FILIAL = ZZA.ZZA_FILIAL AND SC2.C2_OP = ZZA.ZZA_ORDEM AND SC2.D_E_L_E_T_ = '' "
                      cQry1 += "WHERE ZZA.ZZA_FILIAL = '"+xFilial("ZZA")+"' "
                      cQry1 += "  AND ZZA.D_E_L_E_T_ = '' "
                      cQry1 += "  AND ZZA.ZZA_LOTE   = '"+TCQ->ZZA_LOTE+"' "
                      cQry1 += "  AND SUBSTRING(ZZA.ZZA_PRODUT, 11, 2) <> '00' "
                      cQry1 += "ORDER BY ZZA.ZZA_ORDEM, ZZA.ZZA_SEQENV "
                      TCQuery cQry1 ALIAS "QTDPA" NEW
                      DbSelectArea("QTDPA")
                      DbGoTop()
                      While !Eof()
                            cNumOrd := QTDPA->ZZA_ORDEM
                            While !Eof() .and. QTDPA->ZZA_ORDEM == cNumOrd
                                  nPos := aScan(aQtdePA, { |x| x[1] == QTDPA->C2_PRODUTO } )
                                  If nPos == 0
                                     aAdd(aQtdePA, {QTDPA->C2_PRODUTO, QTDPA->C2_QUANT, QTDPA->ZZA_QUANT, QTDPA->VOLUME, Iif(QTDPA->ZZA_FLAG == '6', QTDPA->Z5_VOLUME * QTDPA->ZZA_PESPES, 0) } )
                                  Else
                                     aQtdePA[nPos][3] += QTDPA->ZZA_QUANT
                                     aQtdePA[nPos][4] += QTDPA->VOLUME
                                  Endif
                                  DbSelectArea("QTDPA")
                                  DbSkip()
                            EndDo
                      EndDo
                      DbSelectArea("QTDPA")
                      DbCloseArea()
                      nQtdBai := 0
                      nQtdPen := 0
                      If Len(aQtdePA) > 1
                         For nY := 1 to Len(aQtdePA)
                             nQtdBai += aQtdePa[nY][4]
                             nQtdPen += aQtdePa[nY][5]
                         Next
                      ElseIf Len(aQtdePA) == 1
                             nQtdBai := aQtdePa[1][4]
                             nQtdPen := aQtdePa[1][5]
                      Endif
                      DbSelectArea("TCQ")
                   Endif
                   cPictPro := Iif(Len(Alltrim(TCQ->ZZA_PRODUT)) < 12, Iif(Len(Alltrim(TCQ->ZZA_PRODUT)) == 4, "@R 9999", Iif(Len(Alltrim(TCQ->ZZA_PRODUT)) == 5, "@R 99999", "@R 999999" ) ), "@R XX 99.99.999-99")
                   @ nLin,000 PSAY TCQ->ZZA_LOTE
                   @ nLin,009 PSAY TCQ->ZZA_ORDEM
                   @ nLin,022 PSAY TCQ->ZZA_PRODUT                                                 picture cPictPro
                   @ nLin,039 PSAY Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZA_PRODUT, "B1_DESC")
                   @ nLin,071 PSAY Posicione("SC2", 1, xFilial("SC2")+TCQ->ZZA_ORDEM , "C2_QUANT") picture "@E 999,999.999"
                   @ nLin,084 PSAY Posicione("SC2", 1, xFilial("SC2")+TCQ->ZZA_ORDEM , "C2_QUJE")  picture "@E 999,999.999"
                   @ nLin,097 PSAY DTOC(Posicione("SC2", 1, xFilial("SC2")+TCQ->ZZA_ORDEM , "C2_DATRF"), "DDMMYY")
                   @ nLin,110 PSAY TCQ->ZZA_QUANT                                                  picture "@E 999,999.999"
                   @ nLin,123 PSAY DTOC(StoD(TCQ->ZZA_DTFIM), "DDMMYY")

                   //SD3 - MOVIMENTO DE BAIXA
                   cQry1 := ""
                   cQry1 += "SELECT SD3.D3_EMISSAO, SD3.D3_IDENT, SD3.D3_QUANT "
                   cQry1 += "FROM SD3010 SD3 WITH (NOLOCK) "
                   cQry1 += "WHERE SD3.D3_FILIAL  = '"+xFilial("SD3")+"' "
                   cQry1 += "  AND SD3.D_E_L_E_T_ = '' "
                   cQry1 += "  AND SD3.D3_OP      = '"+TCQ->ZZA_ORDEM+"' "
                   cQry1 += "  AND SD3.D3_TM      = '010' "
                   TCQuery cQry1 ALIAS "QTDAPT" NEW
                   DbSelectArea("QTDAPT")
                   cIdenOP := QTDAPT->D3_IDENT
                   @ nLin,136 PSAY QTDAPT->D3_QUANT         picture "@E 999,999.999"
                   @ nLin,149 PSAY DTOC(StoD(QTDAPT->D3_EMISSAO), "DDMMYY")
                   DbSelectArea("QTDAPT")
                   DbCloseArea()
                   DbSelectArea("TCQ")

                   //SH6 - MOVIMENTO PRODUÇÃO
                   If !Empty(cIdenOP)
                      cQry1 := ""
                      cQry1 += "SELECT SH6.H6_DTAPONT, SH6.H6_QTDPROD "
                      cQry1 += "FROM SH6010 SH6 WITH (NOLOCK) "
                      cQry1 += "WHERE SH6.H6_FILIAL  = '"+xFilial("SH6")+"' "
                      cQry1 += "  AND SH6.D_E_L_E_T_ = '' "
                      cQry1 += "  AND SH6.H6_OP      = '"+TCQ->ZZA_ORDEM+"' "
                      cQry1 += "  AND SH6.H6_IDENT   = '"+cIdenOP+"' "
                      TCQuery cQry1 ALIAS "QTDAPT" NEW
                      DbSelectArea("QTDAPT")
                      @ nLin,162 PSAY QTDAPT->H6_QTDPROD   picture "@E 999,999.999"
                      @ nLin,175 PSAY DTOC(StoD(QTDAPT->H6_DTAPONT), "DDMMYY")
                      DbSelectArea("QTDAPT")
                      DbCloseArea()
                      DbSelectArea("TCQ")
                   Else
                      @ nLin,162 PSAY 0          picture "@E 999,999.999"
                      @ nLin,175 PSAY '  /  /  '
                   Endif
                   cStatOP := Iif( Len(Alltrim(TCQ->ZZA_PRODUT)) < 12, SubStr(Iif(TCQ->ZZA_FLAG == '1', '1 - INICIO DE PESAGEM', Iif(TCQ->ZZA_FLAG == '2', '2 - FIM DE PESAGEM', Iif(TCQ->ZZA_FLAG == '3', '3 - COLORISTA', Iif(TCQ->ZZA_FLAG == '4', '4 - LABORATORIO', Iif(TCQ->ZZA_FLAG == '5', '5 - BAIXADA', ZZA->ZZA_FLAG))))), 1, 30), 'B - '+TransForm(nQtdBai, "@E 99,999.999")+' P - '+TransForm(nQtdPen, "@E 99,999.999") )
                   @ nLin, 188 PSAY cStatOp picture "@!"
                   If Posicione("SC2", 1, xFilial("SC2")+TCQ->ZZA_ORDEM , "C2_QUJE") == TCQ->ZZA_QUANT
                      @ nLin, 219 PSAY 'OK' picture "@!"
                   Else
                      @ nLin, 219 PSAY '#' picture "@!"
                   Endif
                   //0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111222222222222222222222
                   //0000000001111111111222222222233333333334444444444555555555566666666667777777777888888888899999999990000000000111111111122222222223333333333444444444455555555556666666666777777777788888888889999999999000000000011111111112
                   //1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
                   //999999  99999999999  XX 99.99.999-99  XXXXXXXXXXXXXXXXXXXXXXXXXXXXX   999.999,999  999.999,999  99/99/9999   999.999,999  99/99/9999   999.999,999  99/99/9999   999.999,999  99/99/9999   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX OK
                   //                                                                    |          ORDEM DE PRODUÇÃO           |       APONTAMENTO       |          BAIXA          |       BAIXA MOD2.       |
                   //LOTE    ORDEM        PRODUTO          DESCRIÇÃO                     | QUANT. SOL.  QUANT. BAI.  DATA FIM   | QUANT. APT.  DATA FIM   | QUANT. SD3.  DATA FIM   | QUANT. SH6.  DATA FIM   | STATUS                         ST           
                   nLin ++                
                   DbSelectArea("TCQ")
                   DbSkip()
             EndDo
          Else //Excel
             aCampos := {}
             cAuxQry := ""
             aAdd(aCampos, {"SEQUENCIA" , "C", 010, 0 })
             aAdd(aCampos, {"ORDEM"     , "C", 006, 0 })
             aAdd(aCampos, {"LOTE"      , "C", 011, 0 })
             aAdd(aCampos, {"PRODUTO"   , "C", 015, 0 })
             aAdd(aCampos, {"DESCRICAO" , "C", 030, 0 })
             aAdd(aCampos, {"OP_QUANTID", "N", 014, 4 })
             aAdd(aCampos, {"OP_DTEMISS", "D", 008, 0 })
             aAdd(aCampos, {"OP_BAIXADA", "N", 014, 4 })
             aAdd(aCampos, {"OP_DTBAIXA", "D", 008, 0 })
             aAdd(aCampos, {"H6_BXMODE2", "N", 014, 4 })
             aAdd(aCampos, {"D3_BXMOVIN", "N", 014, 4 })
             aAdd(aCampos, {"APT_QUANTI", "N", 014, 4 })
             aAdd(aCampos, {"APT_DTINIP", "D", 008, 0 })
             aAdd(aCampos, {"APT_TARATA", "N", 014, 4 })
             aAdd(aCampos, {"APT_DTPESA", "D", 008, 0 })
             aAdd(aCampos, {"APT_PESPES", "N", 014, 4 })
             aAdd(aCampos, {"APT_DTCOLO", "D", 008, 0 })
             aAdd(aCampos, {"APT_PESCOL", "N", 014, 4 })
             aAdd(aCampos, {"APT_DFINAL", "D", 008, 0 })
             aAdd(aCampos, {"APT_PESFIN", "N", 014, 4 })
             aAdd(aCampos, {"APT_P_ESPE", "N", 008, 6 })
             aAdd(aCampos, {"STATUS"    , "C", 014, 0 })
             aAdd(aCampos, {"ENVA_PRODU", "C", 150, 0 })
             aAdd(aCampos, {"ENVA_TOTAL", "N", 014, 4 })
             aAdd(aCampos, {"DIFE_PA_PI", "N", 016, 4 })

             /********************************************************************************************************************************/
             /*** BLOCO ALTERADO EM 03/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
             //cNomArq := CriaTrab(, .f.)
             //DbCreate(cNomArq+".dbf", aCampos, "DBFCDXADS")
             //If Select("LPD")<>0
             //   DbSelectarea("LPD")
             //   DbCloseArea()
             //Endif
             //USE (cNomArq+".dbf") ALIAS LPD VIA "DBFCDXADS" NEW
             oTempTbl01 := FWTemporaryTable():New( "LPD" )
             oTempTbl01:SetFields( aCampos )
             oTempTbl01:Create()
             /********************************************************************************************************************************/
             nQtdReg := 1
             DbSelectArea("TCQ")
             DbGoTop()
             While !Eof()
                   RecLock("LPD", .t.)
                      LPD->SEQUENCIA  := StrZero(nQtdReg, 8)+'00'
                      LPD->ORDEM      := TCQ->ZZA_ORDEM
                      LPD->LOTE       := TCQ->ZZA_LOTE
                      LPD->PRODUTO    := TCQ->ZZA_PRODUT
                      LPD->DESCRICAO  := Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZA_PRODUT, "B1_DESC")
                      LPD->OP_QUANTID := Posicione("SC2", 1, xFilial("SC2")+TCQ->ZZA_ORDEM , "C2_QUANT")
                      LPD->OP_BAIXADA := Posicione("SC2", 1, xFilial("SC2")+TCQ->ZZA_ORDEM , "C2_QUJE")
                      LPD->OP_DTEMISS := Posicione("SC2", 1, xFilial("SC2")+TCQ->ZZA_ORDEM , "C2_EMISSAO")
                      LPD->OP_DTBAIXA := Posicione("SC2", 1, xFilial("SC2")+TCQ->ZZA_ORDEM , "C2_DATRF")
                      LPD->APT_DTINIP := STOD(TCQ->ZZA_DTINI)
                      LPD->APT_QUANTI := TCQ->ZZA_QUANT
                      LPD->APT_TARATA := TCQ->ZZA_TARA
                      LPD->APT_DTPESA := STOD(TCQ->ZZA_DTPES)
                      LPD->APT_PESPES := TCQ->ZZA_PESPES
                      LPD->APT_DTCOLO := STOD(TCQ->ZZA_DTCOL)
                      LPD->APT_PESCOL := TCQ->ZZA_PESCOL
                      LPD->APT_DFINAL := STOD(TCQ->ZZA_DTFIM)
                      LPD->APT_PESFIN := TCQ->ZZA_PESFIN
                      LPD->APT_P_ESPE := TCQ->ZZA_PESLAB
                      LPD->STATUS     := Iif(TCQ->ZZA_FLAG == '5', 'BAIXADA', Iif(TCQ->ZZA_FLAG == '4', 'LABORATORIO', Iif(TCQ->ZZA_FLAG == '3', 'COLORISTA', Iif(TCQ->ZZA_FLAG == '2', 'FIM PESAGEM', 'INICIO PESAGEM' ))))
                      //Informações do envase
                      If Len(Alltrim(TCQ->ZZA_PRODUT)) == 12
                         aProEnv := {}
                         cQry1 := ""
                         cQry1 += "SELECT * "
                         cQry1 += "FROM ZZA010 ZZA WITH (NOLOCK) "
                         cQry1 += "LEFT OUTER JOIN SZ5010 SZ5 WITH (NOLOCK) ON SZ5.Z5_FILIAL = '' AND SZ5.Z5_EMB = SUBSTRING(ZZA.ZZA_PRODUT, 11, 2) AND SZ5.D_E_L_E_T_ = '' "
                         cQry1 += "WHERE ZZA.ZZA_FILIAL = '"+xFilial("ZZA")+"' "
                         cQry1 += "  AND ZZA.D_E_L_E_T_ = '' "
                         cQry1 += "  AND ZZA.ZZA_LOTE   = '"+TCQ->ZZA_LOTE+"' "
                         cQry1 += "  AND SUBSTRING(ZZA.ZZA_PRODUT, 11, 2) <> '00' "
                         TCQuery cQry1 ALIAS "TMPENV" NEW
                         DbSelectArea("TMPENV")
                         While !Eof()
                               nPos := aScan(aProEnv, { |x| x[5] == SubStr(TMPENV->ZZA_PRODUT, 11, 2)+TMPENV->ZZA_FLAG } )
                               If nPos == 0
                                  aAdd(aProEnv, { SubStr(TMPENV->ZZA_PRODUT, 11, 2), TMPENV->ZZA_FLAG, Iif(TMPENV->ZZA_FLAG == '6', TMPENV->ZZA_PESPES, TMPENV->ZZA_QUANT), TMPENV->Z5_VOLUME, SubStr(TMPENV->ZZA_PRODUT, 11, 2)+TMPENV->ZZA_FLAG } )
                               Else
                                  aProEnv[nPos][3] += Iif(TMPENV->ZZA_FLAG == '6', TMPENV->ZZA_PESPES, TMPENV->ZZA_QUANT)
                               Endif
                               DbSelectArea("TMPENV")
                               DbSkip()
                         EndDo
                         DbSelectArea("TMPENV")
                         DbCloseArea()
                         nTotEnv := 0
                         cAuxEnv := ""
                         For nY := 1 To Len(aProEnv)
                             If nY == 1
                                cAuxEnv := aProEnv[nY][1]+Iif(aProEnv[nY][2] == '6', '(INICIADA)', Iif(aProEnv[nY][2] == '7', '(PARCIAL)', Iif(aProEnv[nY][2] == '8', '(TOTAL)', '(FINALIZADA)' )))+' - '+TransForm(aProEnv[nY][3] * aProEnv[nY][4], "@E 9999.999")
                             Else
                                cAuxEnv += ' / '+aProEnv[nY][1]+Iif(aProEnv[nY][2] == '6', '(INICIADA)', Iif(aProEnv[nY][2] == '7', '(PARCIAL)', Iif(aProEnv[nY][2] == '8', '(TOTAL)', '(FINALIZADA)' )))+' - '+TransForm(aProEnv[nY][3] * aProEnv[nY][4], "@E 9999.999")
                             Endif
                             nTotEnv += aProEnv[nY][3] * aProEnv[nY][4]
                         Next
                         LPD->ENVA_PRODU := cAuxEnv
                         LPD->ENVA_TOTAL := nTotEnv
                         
                         cQry1 := ""
                         cQry1 += "SELECT SH6.H6_QTDPROD "
                         cQry1 += "FROM SH6010 SH6 WITH (NOLOCK) "
                         cQry1 += "WHERE SH6.H6_FILIAL  = '"+xFilial("SH6")+"' "
                         cQry1 += "  AND SH6.D_E_L_E_T_ = '' "
                         cQry1 += "  AND SH6.H6_OP      = '"+TCQ->ZZA_ORDEM+"' "
                         cQry1 += "GROUP BY SH6.H6_QTDPROD "
                         TCQuery cQry1 ALIAS "TMPSH6" NEW
                         DbSelectArea("TMPSH6")
                         LPD->H6_BXMODE2 := TMPSH6->H6_QTDPROD
                         DbSelectArea("TMPSH6")
                         DbCloseArea()
                         
                         cQry1 := ""
                         cQry1 += "SELECT * "
                         cQry1 += "FROM SD3010 SD3 WITH (NOLOCK) "
                         cQry1 += "WHERE SD3.D3_FILIAL  = '"+xFilial("SD3")+"' "
                         cQry1 += "  AND SD3.D_E_L_E_T_ = '' "
                         cQry1 += "  AND SD3.D3_TM      = '010' "
                         cQry1 += "  AND SD3.D3_OP      = '"+TCQ->ZZA_ORDEM+"' "
                         cQry1 += "  AND SD3.D3_ESTORNO <> 'S' "
                         cQry1 += "  AND SD3.D3_COD     = '"+TCQ->ZZA_PRODUT+"' "
                         TCQuery cQry1 ALIAS "TMPSD3" NEW
                         DbSelectArea("TMPSD3")
                         nQtdSD3 := 0
                         While !Eof()
                               nQtdSD3 += TMPSD3->D3_QUANT
                               DbSelectArea("TMPSD3")
                               DbSkip()
                         EndDo
                         DbSelectArea("TMPSD3")
                         DbCloseArea()
                         LPD->D3_BXMOVIN := nQtdSD3
                         LPD->DIFE_PA_PI := LPD->OP_BAIXADA - LPD->ENVA_TOTAL
                      Endif
                   MsUnLock()
                   nQtdReg += 1
                   DbSelectArea("TCQ")
                   DbSkip()
             EndDo
          Endif
          DbSelectArea("TCQ")
          DbCloseArea()

          If !ApOleClient("MsExcel")
             MsgStop("Microsoft Excel nao instalado.")  //"Microsoft Excel nao instalado."
             Return
          EndIf

          cArq     := cNomArq+".DBF"
          DbSelectArea("LPD")
          LPD->(DbCloseArea())
          oTempTbl01:Delete()

	      __CopyFile(cArq , AllTrim(GetTempPath())+cNomArq+".XLS")
          //FErase(cNomArq+".DBF")
          oExcelApp:= MsExcel():New()
          oExcelApp:WorkBooks:Open(AllTrim(GetTempPath())+cNomArq+".XLS")
          oExcelApp:SetVisible(.T.)
       Else
          DbCloseArea()
          //MsgStop()
       Endif
       DbSelectArea(cString)

       If mv_par03 == 2
          //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
          //³ Finaliza a execucao do relatorio...                                 ³
          //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
          SET DEVICE TO SCREEN

          //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
          //³ Se impressao em disco, chama o gerenciador de impressao...          ³
          //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
          If aReturn[5] == 1
             dbCommitAll()
             SET PRINTER TO
             OurSpool(wnrel)
          Endif
       Endif
       MS_FLUSH()
Return

/*
Static Function fPergETQ()
       //PutSX1(cPerg, "08"  ,  "Ordem dos itens     ?", "Ordem dos itens     ?", "Ordem dos itens     ?", "mv_ch8", "N",  1, 0, 1, "C"  , "","","","",             "mv_par08","Pedido+Itens", "Pedido+Itens", "Pedido+Itens"   , ""   , "Descrição itens", "Descrição itens", "Descrição itens", "Itens+'BM'+Variação", "Itens+'BM'+Vari", "Itens+'BM'+Vari" , "Quadrantes", "Quadrantes", "Quadrantes",  "Cód. Produto", "Cód. Produto", "Cód. Produto",{},{},{}, "" )
         aHelpPor := {}
         //              1234567890123456789012345678901234567890
         aAdd(aHelpPor, 'Informe ou Selecione o Código da Filial ')
         aAdd(aHelpPor, 'Inicial para Filtro dos dados.')
         PutSX1("GPR320"  , "01"      ,  "Filial de"                     , "Periodo de"                     , "Periodo de"                     , "mv_ch1", "D"      ,  8          , 0           , 1          , "G"     , ""        , ""      , ""         , ""       , "mv_par01", ""        , ""          , ""          , ""        , ""        , ""          , ""          , ""        , ""          , ""          , ""        , ""          , ""          ,  ""       , ""          , ""          , aHelpPor    , {}         , {}           , ".SACR0901." )

         aHelpPor := {}
         aAdd(aHelpPor, 'Informe ou Selecione o Código da Filial ')
         aAdd(aHelpPor, 'Final para Filtro dos dados.')
         PutSX1("GPR320"  , "02"      ,  "Filial até"                    , "Periodo até"                    , "Periodo até"                    , "mv_ch2", "D"      ,  8          , 0           , 1          , "G"     , ""        , ""      , ""         , ""       , "mv_par02", ""        , ""          , ""          , ""        , ""        , ""          , ""          , ""        , ""          , ""          , ""        , ""          , ""          ,  ""       , ""          , ""          , aHelpPor    , {}          , {}          , ".SACR0902." )

         aHelpPor := {}
         aAdd(aHelpPor, 'Informe Sim para mostrar o indicador de ')
         aAdd(aHelpPor, 'qualidade.')
         PutSX1("SACR09"  , "03"      ,  "Mostra Indicador de Qualidade"  , "Mostra Indicador de Qualidade"  , "Mostra Indicador de Qualidade"  , "mv_ch3", "N"      ,  1          , 0           , 1          , "C"     , ""        , ""      , ""         , ""       , "mv_par03", "Sim"     , "Sim"       , "Sim"       , ""        , "Não"     , "Não"       , "Não"       , ""        , ""          , ""          , ""        , ""          , ""          ,  ""       , ""          , ""          , aHelpPor    , {}          , {}          , ".SACR0903." )
         aHelpPor := {}
         aAdd(aHelpPor, 'Informe Sim para o sistema mostrar as   ')
         aAdd(aHelpPor, 'ocorrências x assunto.')
         PutSX1("SACR09"  , "04"      ,  "Mostra Ocorren. X Assunto"      , "Mostra Ocorren. X Assunto"      , "Mostra Ocorren. X Assunto"      , "mv_ch4", "N"      ,  1          , 0           , 1          , "C"     , ""        , ""      , ""         , ""       , "mv_par04", "Sim"     , "Sim"       , "Sim"       , ""        , "Não"     , "Não"       , "Não"       , ""        , ""          , ""          , ""        , ""          , ""          ,  ""       , ""          , ""          , aHelpPor    , {}          , {}          , ".SACR0904." )
         aHelpPor := {}
         aAdd(aHelpPor, 'Informe um assunto específico para ser  ')
         aAdd(aHelpPor, 'analisado.')
         PutSX1("SACR09"  , "05"      ,  "Assunto Específico"             , "Assunto Específico"             , "Assunto Específico"             , "mv_ch5", "C"      ,  6          , 0           , 1          , "G"     , ""        , "T1"    , ""         , ""       , "mv_par05", ""        , ""          , ""          , ""        , ""        , ""          , ""          , ""        , ""          , ""          , ""        , ""          , ""          ,  ""       , ""          , ""          , aHelpPor    , {}          , {}          , ".SACR0905." )
         aHelpPor := {}
         aAdd(aHelpPor, 'Informe uma ocorrência específica para  ')
         aAdd(aHelpPor, 'ser analisado.')
         PutSX1("SACR09"  , "06"      ,  "Ocorrência Específica"          , "Ocorrência Específica"          , "Ocorrência Específica"          , "mv_ch6", "C"      ,  6          , 0           , 1          , "G"     , ""        , "SU9XXZ", ""         , ""       , "mv_par06", ""        , ""          , ""          , ""        , ""        , ""          , ""          , ""        , ""          , ""          , ""        , ""          , ""          ,  ""       , ""          , ""          , aHelpPor    , {}          , {}          , ".SACR0906." )
         aHelpPor := {}
         aAdd(aHelpPor, 'Informe Sim para o sistema mostrar as   ')
         aAdd(aHelpPor, 'Atendimentos procedentes/não procedentes')
         PutSX1("SACR09"  , "07"      ,  "Mostra Qtd. Procede/Não Procede", "Mostra Qtd. Procede/Não Procede", "Mostra Qtd. Procede/Não Procede", "mv_ch7", "N"      ,  1          , 0           , 1          , "C"     , ""        , ""      , ""         , ""       , "mv_par07", "Sim"     , "Sim"       , "Sim"       , ""        , "Não"     , "Não"       , "Não"       , ""        , ""          , ""          , ""        , ""          , ""          ,  ""       , ""          , ""          , aHelpPor    , {}          , {}          , ".SACR0907." )
       //PutSX1([ cGrupo ], [ cOrdem ], [ cPergunt ]                      , [ cPerSpa ]                      , [ cPerEng ]                      , [ cVar ], [ cTipo ], [ nTamanho ], [ nDecimal ], [ nPresel ], [ cGSC ], [ cValid ], [ cF3 ] , [ cGrpSxg ], [ cPyme ], [ cVar01 ], [ cDef01 ], [ cDefSpa1 ], [ cDefEng1 ], [ cCnt01 ], [ cDef02 ], [ cDefSpa2 ], [ cDefEng2 ], [ cDef03 ], [ cDefSpa3 ], [ cDefEng3 ], [ cDef04 ], [ cDefSpa4 ], [ cDefEng4 ], [ cDef05 ], [ cDefSpa5 ], [ cDefEng5 ], [ aHelpPor ], [ aHelpEng ], [ aHelpSpa ], [ cHelp ] )
Return
*/

//LGS#20200131 - Adequação de release 12.1.25 e posteriores
/*
Static Function fPerg()
       aHelpPor := {}
       aAdd(aHelpPor, 'Informe a data de baixa das ordens de - ')
       aAdd(aHelpPor, 'produção.                               ')
       PutSX1("PCPR12"  , "01"  ,  "Data de Baixa"    , "Data de Baixa"     , "Data de Baixa"     , "mv_ch1", "D",  8, 0, 0, "G", "", "", "", "", "mv_par01", "", "", "", "", ""     , ""     , ""     , "", "", "", ""          , ""          , ""          ,  ""            , ""            , ""            , aHelpPor, {}, {}, ".PCPR1201." )

       aHelpPor := {}
       aAdd(aHelpPor, 'Informe a data de baixa das ordens de - ')
       aAdd(aHelpPor, 'produção.                               ')
       PutSX1("PCPR12"  , "02"  ,  "Até Data de Baixa", "Até Data de Baixa" , "Até Data de Baixa" , "mv_ch2", "D",  8, 0, 0, "G", "", "", "", "", "mv_par02", "", "", "", "", ""     , ""     , ""     , "", "", "", ""          , ""          , ""          ,  ""            , ""            , ""            , aHelpPor, {}, {}, ".PCPR1202." )

       aHelpPor := {}
       aAdd(aHelpPor, 'Informe a saida do relatório - excel ou ')
       aAdd(aHelpPor, 'relatório.                              ')
       PutSX1("PCPR12"  , "03"  ,  "Excel/Relatorio"  , "Excel/Relatorio"   , "Excel/Relatorio"   ,;
              "mv_ch3", "C",  1,;
              0, 0, "C",;
              "", "", "",;
              "", "mv_par03",;
              "Excel"    , "Excel", "Excel", "1",;
              "Relatorio", "Relat", "Relat",;
              ""         , ""     , ""     ,;
              ""         , ""     , ""     ,;
              ""         , ""     , ""     ,;
              aHelpPor   , {}     , {}     , ".PCPR1203." )
Return */
