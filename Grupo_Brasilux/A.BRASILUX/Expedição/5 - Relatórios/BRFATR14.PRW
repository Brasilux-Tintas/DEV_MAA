#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFATR14  º Autor ³ Luíz G. de Souza   º Data ³  07/06/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Divergências de Borderos de Pedidos x Despacho             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRFATR14()
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "Divergências de Borderos"
     //Local cPict         := ""
     Local titulo        := "Divergências de Borderos de Pedidos x Despacho"
     Local nLin          := 80
     Local Cabec1        := "RETIRA PEDIDO DESPAC EM./PRV. CLIENTE                                  VALOR MERCAD.  PESO BRUTO VOLUME CIDADE               REDESPACHO                                                          TRANS. DT. PROG"
     Local Cabec2        := ""
     //Local imprime       := .T.
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     //Private CbTxt       := ""
     Private limite      := 220
     Private tamanho     := "G"
     Private nomeprog    := "BRFATR14" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 18
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cbtxt       := Space(10)
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRFATR14" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString     := "SZF"
     
    if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 

     DbSelectArea("SZF")
     DbSetOrder(1)

     wnrel := SetPrint(cString, NomeProg, "", @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho, , .F.)

     If nLastKey == 27
        Return
     Endif

     SetDefault(aReturn, cString)

     If nLastKey == 27
        Return
     Endif

     nTipo := If(aReturn[4] == 1, 15, 18)

     Processa({|| FATR14_1(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ FATR14_1 º Autor ³ Luíz G. de Souza   º Data ³  07/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FATR14_1(Cabec1, Cabec2, Titulo, nLin)
       DbSelectArea(cString)
       DbSetOrder(1)

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ SETREGUA -> Indica quantos registros serao processados para a regua ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

       ProcRegua(20)
       cQry1 := ""
       cQry1 += "SELECT SZF.ZF_CODIGO AS BORPED, "
       cQry1 += "       SUBSTRING(SZG.ZG_PEDIDO, 3, 6) AS PEDIDO, "
       cQry1 += "       ISNULL(SZB.ZB_CODIGO, '') AS BORDES, "
       cQry1 += "       SZF.ZF_EMISSAO AS EMISSA, "
       cQry1 += "       SA1.A1_NOME AS CLIENT, "
       cQry1 += "       (SELECT SUM(SC6.C6_QTDVEN * SC6.C6_PRCVEN) FROM "+RetSqlName("SC6")+" SC6 WHERE SC6.C6_FILIAL = SC5.C5_FILIAL AND SC6.C6_NUM = SC5.C5_NUM) AS VALMER, "
       cQry1 += "       SC5.C5_PBRUTO AS PESOBR, "
       cQry1 += "       SC5.C5_VOLUME1 AS VOLUME, "
       cQry1 += "       SA1.A1_MUN AS MUNICI, "
       cQry1 += "       SC5.C5_REDESP+'- '+SA4.A4_NOME+' - '+SA4.A4_TEL AS REDESP, "
       cQry1 += "       SC5.C5_TRANSP AS TRANSP, "
       cQry1 += "       SC5.C5_PEDPROG AS DTPROG "
       cQry1 += "FROM "+RetSqlName("SZF")+" SZF WITH (NOLOCK) "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH (NOLOCK) ON SZF.ZF_FILIAL = SZG.ZG_FILIAL AND SZF.ZF_CODIGO = SZG.ZG_CODIGO AND SZG.D_E_L_E_T_ = '' "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SZB")+" SZB WITH (NOLOCK) ON SZG.ZG_FILIAL = SZB.ZB_FILIAL AND SZG.ZG_PEDIDO = SZB.ZB_PEDIDO AND SZB.D_E_L_E_T_ = '' "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON SZG.ZG_FILIAL = SC5.C5_FILIAL AND SUBSTRING(SZG.ZG_PEDIDO, 3, 6) = SC5.C5_NUM AND SC5.D_E_L_E_T_ = '' "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON '  ' = SA1.A1_FILIAL AND SA1.A1_COD = SC5.C5_CLIENTE AND SA1.A1_LOJA = SC5.C5_LOJACLI AND SA1.D_E_L_E_T_ = '' "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SA4")+" SA4 WITH (NOLOCK) ON '  ' = SA4.A4_FILIAL AND SC5.C5_REDESP = SA4.A4_COD AND SA4.D_E_L_E_T_ = '' "
       cQry1 += "WHERE SZF.ZF_FILIAL = '"+xFilial("SZF")+"' "
       cQry1 += "  AND SZF.D_E_L_E_T_ = '' "
       cQry1 += "  AND SZF.ZF_EMISSAO >= '20060701' "
       //cQry1 += "  AND SZF.ZF_FLAG  <> 'T' "
       cQry1 += "  AND ISNULL(SZB.ZB_CODIGO, '') = '' "
       cQry1 += "UNION ALL "
       cQry1 += "SELECT SZA.ZA_CODIGO AS BORPED, "
       cQry1 += "       SUBSTRING(SZB.ZB_PEDIDO, 3, 6) AS PEDIDO, "
       cQry1 += "       ISNULL(SZG.ZG_CODIGO, '') AS BORDES, "
       cQry1 += "       SZA.ZA_PREVDSP AS EMISSA, "
       cQry1 += "       SA1.A1_NOME AS CLIENT, "
       cQry1 += "       (SELECT SUM(SC6.C6_QTDVEN * SC6.C6_PRCVEN) FROM "+RetSqlName("SC6")+" SC6 WHERE SC6.C6_FILIAL = SC5.C5_FILIAL AND SC6.C6_NUM = SC5.C5_NUM) AS VALMER, "
       cQry1 += "       SC5.C5_PBRUTO AS PESOBR, "
       cQry1 += "       SC5.C5_VOLUME1 AS VOLUME, "
       cQry1 += "       SA1.A1_MUN AS MUNICI, "
       cQry1 += "       SC5.C5_REDESP+'- '+SA4.A4_NOME+' - '+SA4.A4_TEL AS REDESP, "
       cQry1 += "       SC5.C5_TRANSP AS TRANSP, "
       cQry1 += "       SC5.C5_PEDPROG AS DTPROG "
       cQry1 += "FROM "+RetSqlName("SZA")+" SZA WITH (NOLOCK) "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SZB")+" SZB WITH (NOLOCK) ON SZA.ZA_FILIAL = SZB.ZB_FILIAL AND SZA.ZA_CODIGO = SZB.ZB_CODIGO AND SZB.D_E_L_E_T_ = '' "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH (NOLOCK) ON SZB.ZB_FILIAL = SZG.ZG_FILIAL AND SZB.ZB_PEDIDO = SZG.ZG_PEDIDO AND SZG.D_E_L_E_T_ = '' "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON SZB.ZB_FILIAL = SC5.C5_FILIAL AND SUBSTRING(SZB.ZB_PEDIDO, 3, 6) = SC5.C5_NUM AND SC5.D_E_L_E_T_ = '' "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON '  ' = SA1.A1_FILIAL AND SA1.A1_COD = SC5.C5_CLIENTE AND SA1.A1_LOJA = SC5.C5_LOJACLI AND SA1.D_E_L_E_T_ = '' "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SA4")+" SA4 WITH (NOLOCK) ON '  ' = SA4.A4_FILIAL AND SC5.C5_REDESP = SA4.A4_COD AND SA4.D_E_L_E_T_ = '' "
       cQry1 += "WHERE SZA.ZA_FILIAL  = '"+xFilial("SZA")+"' "
       cQry1 += "  AND SZA.D_E_L_E_T_ = '' "
       cQry1 += "  AND SZA.ZA_DTDESPA = '' "
       cQry1 += "  AND ISNULL(SZG.ZG_CODIGO, '') = '' "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()
       While !EOF()
             IncProc()
             If lAbortPrint
                @ nLin,000 PSAY "*** CANCELADO PELO OPERADOR ***"
                Exit
             Endif

             If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
                nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
                nLin += 1
             Endif
             //0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21        22
             //0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
             //RETIRA PEDIDO DESPAC EM./PRV. CLIENTE                                  VALOR MERCAD.  PESO BRUTO VOLUME CIDADE               REDESPACHO                                                          TRANS. DT. PROG
             //999999 999999 999999 99/99/99 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 999.999.999,99 999.999,99 999999 XXXXXXXXXXXXXXXXXXXX 999999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX - XXXXXXXXXXXXXXX 999999 99/99/99
             
             @ nLin, 000 PSAY TCQ->BORPED
             @ nLin, 007 PSAY TCQ->PEDIDO
             @ nLin, 014 PSAY TCQ->BORDES
             @ nLin, 021 PSAY SubStr(TCQ->EMISSA, 7, 2)+'/'+SubStr(TCQ->EMISSA, 5, 2)+'/'+SubStr(TCQ->EMISSA, 3, 2)
             @ nLin, 030 PSAY TCQ->CLIENT
             @ nLin, 071 PSAY TCQ->VALMER Picture "@E 999,999,999.99"
             @ nLin, 086 PSAY TCQ->PESOBR Picture "@E 999,999.99 "
             @ nLin, 097 PSAY TCQ->VOLUME Picture "@E 999999"
             @ nLin, 104 PSAY SubStr(Alltrim(TCQ->MUNICI), 1, 20)
             @ nLin, 125 PSAY TCQ->REDESP
             @ nLin, 193 PSAY TCQ->TRANSP
             @ nLin, 200 PSAY SubStr(TCQ->DTPROG, 7, 2)+'/'+SubStr(TCQ->DTPROG, 5, 2)+'/'+SubStr(TCQ->DTPROG, 3, 2)
             nLin += 1 // Avanca a linha de impressao

             DbSkip() // Avanca o ponteiro do registro no arquivo
       EndDo
       DbSelectArea("TCQ")
       DbCloseArea()
       
       SET DEVICE TO SCREEN

       If aReturn[5]==1
          DbCommitAll()
          SET PRINTER TO
          OurSpool(wnrel)
       Endif

       MS_FLUSH()

Return
