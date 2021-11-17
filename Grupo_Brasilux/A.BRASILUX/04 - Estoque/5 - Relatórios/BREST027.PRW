#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "protheus.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณ BREST027 บ Autor ณ Luํs Gustavo de Souza บ Data ณ 10/09/03 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณ Monta rela็ใo de produtos, com quantidades de vendas, m้diaบฑฑ
ฑฑบ          ณ de consumos, etc.                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบ Cleber(02/01/06) Altera็ใo tirando onde hแ C5_ESPECI4                 ผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function BREST027()
     Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2         := "de acordo com os parametros informados pelo usuario."
     Local cDesc3         := "Programa็ใo de Produ็ใo"
     Local cPict          := ""
     Local titulo         := "Programa็ใo de Produ็ใo"
     Local nLin           := 80

     Local Cabec1         := "                                                           SALDO ATUAL   PED. LIBER.   O.P.s         PEDIDOS       PONTO         LOTE          MษDIA DE      SUGESTรO DE   ULTIMA"
     Local Cabec2         := "CODIGO             DESCRICAO                       TP  UM                PELO CREDITO  COLOCADAS     COLOCADOS     PEDIDO        ECONOMICO     3  MESES      PRODUวรO      SAอDA"
     Local imprime        := .T.
     Local aOrd           := {}
     Private lEnd         := .F.
     Private lAbortPrint  := .F.
     Private CbTxt        := ""
     Private limite       := 220
     Private tamanho      := "G"
     Private nomeprog     := "BREST027"
     Private nTipo        := 15
     Private aReturn      := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
     Private nLastKey     := 0
     Private cPerg        := "EST027"
     Private cbtxt        := Space(10)
     Private cbcont       := 00
     Private CONTFL       := 01
     Private m_pag        := 01
     Private wnrel        := "BREST027"

     Private cString      := ""

     dbSelectArea("SB1")
     dbSetOrder(1)

     ValPerg()
     pergunte(cPerg,.F.)

     //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
     //ณ Monta a interface padrao com o usuario...                           ณ
     //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

     wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

     If nLastKey == 27
        Return
     Endif

     SetDefault(aReturn,cString)

     If nLastKey == 27
        Return
     Endif

     nTipo := If(aReturn[4]==1,15,18)

     //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
     //ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
     //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

     RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Luis Gustavo       บ Data ณ  10/09/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport(Cabec1, Cabec2, Titulo, nLin)
       Local nOrdem
       Local cQry1 := ""
       Local cQry2 := ""

       cQry1 := ""
       cQry1 += "SELECT SB1.B1_COD AS CODPRO, SB1.B1_DESC AS DESPRO, SB1.B1_TIPO AS TIPPRO, SB1.B1_UM AS UNIMED, "
       cQry1 += "       SB2.B2_QATU AS QTDATU, SB1.B1_EMIN AS PTOPED, SB1.B1_LE AS LOTECO, ZZ2.ZZ2_MEDIA AS MEDPRO, "
       cQry1 += "       SUBSTRING(SB2.B2_USAI,7,2)+'/'+SUBSTRING(SB2.B2_USAI,5,2)+'/'+SUBSTRING(SB2.B2_USAI,1,4) AS ULTSAI "
       cQry1 += "FROM "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON SB1.B1_FILIAL = SB2.B2_FILIAL AND SB1.B1_COD = SB2.B2_COD AND SB1.B1_LOCPAD = SB2.B2_LOCAL AND SB2.D_E_L_E_T_ = '' "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("ZZ2")+" ZZ2 WITH (NOLOCK) ON SB1.B1_FILIAL = ZZ2.ZZ2_FILIAL AND SB1.B1_COD = ZZ2.ZZ2_COD AND ZZ2.D_E_L_E_T_ = '' "
       cQry1 += "WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
       cQry1 += "  AND SB1.D_E_L_E_T_ = '' "
       cQry1 += "  AND SB1.B1_COD    BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
       cQry1 += "  AND SB1.B1_TIPO   BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
       cQry1 += "  AND SB1.B1_GRUPO  BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' "
       cQry1 += "  AND SB1.B1_DESC   BETWEEN '"+mv_par07+"' AND '"+mv_par08+"' "
       cQry1 += "  AND SB1.B1_LOCPAD BETWEEN '"+mv_par09+"' AND '"+mv_par10+"' "
       If mv_par11 == 1
          cQry1 += "  AND SB2.B2_LOCALIZ NOT IN('') "
       Endif
       If mv_par12 == 2
          cQry1 += "  AND SB2.B2_QATU NOT IN(0.0) "
       Endif
       If mv_par14 == 1
          cQry1 += "ORDER BY SB1.B1_COD "
       Else
          cQry1 += "ORDER BY ZZ2.ZZ2_MEDIA DESC "
       Endif
       
       SetRegua(2000)
       //cQry1 := ChangeQuery(cQry1)
       //dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry1),"QCON1",.T.,.T.)
       TCQuery cQry1 ALIAS "QCON1" NEW

       DbSelectArea("QCON1")
       dbGoTop()
       While !EOF()
             cQry2 := ""
             cQry2 += "SELECT ISNULL(SUM(SC2.C2_QUANT),0) AS QTDPRD "
             cQry2 += "FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "
             cQry2 += "WHERE SC2.D_E_L_E_T_ = '' "
             cQry2 += "  AND SC2.C2_FILIAL  = '"+xFilial("SC2")+"' "
             cQry2 += "  AND SC2.C2_PRODUTO = '"+QCON1->CODPRO+"' "
             cQry2 += "  AND SC2.C2_DATRF   = '' "
             cQry2 += "  AND (SC2.C2_QUANT - SC2.C2_QUJE) > 0 "
             cQry2 := ChangeQuery(cQry2)
             TCQuery cQry2 ALIAS "QCON2" NEW
             //dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry2),"QCON2",.T.,.T.)
             DbSelectArea("QCON2")

             cQry3 := ""             
             cQry3 += "SELECT SC9.C9_PRODUTO AS CODPRO,SC9.C9_QTDLIB AS QTDLIB "
/*             cQry3 += "       CASE "
             cQry3 += "          WHEN SC5.C5_ESPECI4 = '' THEN (SC9.C9_QTDLIB    ) "
             cQry3 += "                                   ELSE (SC9.C9_QTDLIB * 2) "
             cQry3 += "       END AS QTDLIB "*/
             cQry3 += "FROM "+RetSqlName("SC9")+" SC9 WITH (NOLOCK) "
             cQry3 += "INNER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON SC9.C9_FILIAL = SC5.C5_FILIAL AND SC9.C9_PEDIDO = SC5.C5_NUM AND SC5.D_E_L_E_T_ = '' "
             cQry3 += "WHERE SC9.C9_FILIAL = '"+xFilial("SC9")+"' "
             cQry3 += "  AND SC9.D_E_L_E_T_ = '' "
             cQry3 += "  AND SC9.C9_NFISCAL = '' "
             cQry3 += "  AND SC9.C9_BLCRED  = '' "
             cQry3 += "  AND SC9.C9_PRODUTO = '"+QCON1->CODPRO+"' "
             cQry3 := ChangeQuery(cQry3)
             TCQuery cQry1 ALIAS "QCON3" NEW
//             dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry3),"QCON3",.T.,.T.)
             DbSelectArea("QCON3")
             DbGoTop()
             nQTDLIB := 0
             While !Eof()
                   nQTDLIB += QCON3->QTDLIB
                   DbSelectArea("QCON3")
                   DbSkip()
             Enddo
             If mv_par13 == 1
                If nQTDLIB <= 0
                   DbSelectArea("QCON2")
                   DbCloseArea()
                   DbSelectArea("QCON3")
                   DbCloseArea()
                   DbSelectArea("QCON1")
                   dbSkip() // Avanca o ponteiro do registro no arquivo
                   Loop
                Endif
             Endif

             cQry4 := ""
             cQry4 += "SELECT SC6.C6_PRODUTO AS CODPRO,SC6.C6_QTDVEN - (SC6.C6_QTDEMP + SC6.C6_QTDENT) AS QTDPED "
/*             cQry4 += "       CASE "
             cQry4 += "          WHEN SC5.C5_ESPECI4 = '' THEN ( SC6.C6_QTDVEN - (SC6.C6_QTDEMP + SC6.C6_QTDENT)) "
             cQry4 += "                                   ELSE ((SC6.C6_QTDVEN - (SC6.C6_QTDEMP + SC6.C6_QTDENT)) * 2) "
             cQry4 += "       END AS QTDPED " */
             cQry4 += "FROM "+RetSqlName("SC6")+" SC6 "
             cQry4 += "INNER JOIN "+RetSqlName("SC5")+" SC5 ON SC6.C6_FILIAL = SC5.C5_FILIAL AND SC6.C6_NUM = SC5.C5_NUM AND SC5.D_E_L_E_T_ = '' "
             cQry4 += "WHERE SC6.C6_FILIAL = '"+xFilial("SC6")+"' "
             cQry4 += "  AND SC6.D_E_L_E_T_ = '' "
             cQry4 += "  AND SC6.C6_NOTA = '' "
             cQry4 += "  AND SC6.C6_PRODUTO = '"+QCON1->CODPRO+"' "
             cQry4 := ChangeQuery(cQry4)
             
             //dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry4),"QCON4",.T.,.T.)
             TCQuery cQry1 ALIAS "QCON4" NEW
             DbSelectArea("QCON4")
             DbGoTop()
             nQTDPED := 0
             While !Eof()
                   nQTDPED += QCON4->QTDPED
                   DbSelectArea("QCON4")
                   DbSkip()
             Enddo
             nQTDSUG := 0
             nQTDSUG := (QCON1->QTDATU + QCON2->QTDPRD) - nQTDLIB
             nQTDSUG := Iif(nQTDSUG < 0, nQTDSUG, 0)
             
             If lAbortPrint
                @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
                Exit
             Endif

             //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
             //ณ Impressao do cabecalho do relatorio. . .                            ณ
             //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

             If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
                nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                nLin := nLin + 1
             Endif
             //0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21        22
             //01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
             //                                                           SALDO ATUAL   PED. LIBER.   O.P.s         PEDIDOS       PONTO         LOTE          MษDIA DE      SUGESTรO DE   ULTIMA
             //CODIGO             DESCRICAO                       TP  UM                PELO CREDITO  COLOCADAS     COLOCADOS     PEDIDO        ECONOMICO     CONSUMO       PRODUวรO      SAอDA
             //XX 99.99.999.99    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XX  XX  9,999,999.99  9,999,999.99  9,999,999.99  9,999,999.99  9,999,999.99  9,999,999.99  9,999,999.99  9,999,999.99  99/99/99
             @ nLin,000 PSAY QCON1->CODPRO      Picture "@R XX 99.99.999.99"                    //Codigo do Produto
             @ nLin,019 PSAY QCON1->DESPRO      Picture "@!"                                    //Descri็ใo do Produto
             @ nLin,051 PSAY QCON1->TIPPRO      Picture "@!"                                    //Tipo do Produto
             @ nLin,055 PSAY QCON1->UNIMED      Picture "@!"                                    //Unidade de Medida
             @ nLin,059 PSAY QCON1->QTDATU      Picture "@E 9,999,999.99"                       //Quantidade Atual
             @ nLin,072 PSAY       nQTDLIB      Picture "@E 9,999,999.99"                       //Quantidade Liberada pelo cr้dito
             @ nLin,087 PSAY QCON2->QTDPRD      Picture "@E 9,999,999.99"                       //Quantidade de Ordens de Produ็ใo
             @ nLin,101 PSAY       nQTDPED      Picture "@E 9,999,999.99"                       //Quantidade de Pedidos Colocados
             @ nLin,115 PSAY QCON1->PTOPED      Picture "@E 9,999,999.99"                       //Ponto de Pedido
             @ nLin,129 PSAY QCON1->LOTECO      Picture "@E 9,999,999.99"                       //Lote Econ๔mico
             @ nLin,143 PSAY QCON1->MEDPRO      Picture "@E 9,999,999.99"                       //Media de Consumo de 3 meses
             @ nLin,157 PSAY       nQTDSUG      Picture "@E 9,999,999.99"                       //Sugestใo para produ็ใo
             @ nLin,171 PSAY QCON1->ULTSAI                                                      //Data da Ultima saํda

             nLin := nLin + 1 // Avanca a linha de impressao
             DbSelectArea("QCON2")
             DbCloseArea()
             DbSelectArea("QCON3")
             DbCloseArea()
             DbSelectArea("QCON4")
             DbCloseArea()
             DbSelectArea("QCON1")
             dbSkip() // Avanca o ponteiro do registro no arquivo
       EndDo

       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Finaliza a execucao do relatorio...                                 ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

       SET DEVICE TO SCREEN

       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

       If aReturn[5]==1
          dbCommitAll()
          SET PRINTER TO
          OurSpool(wnrel)
       Endif

       MS_FLUSH()
       
       DbSelectArea("QCON1")
       DbCloseArea()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบFuno    ณ VALPERG  บ Autor ณ Luํs Gustavo de Souza บ Data ณ 10/07/03 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescrio ณ Verifica a existencia das perguntas criando-as caso seja   บฑฑ
ฑฑบ          ณ necessario (caso nao existam).                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ValPerg()
       Local _sAlias := Alias()
       Local aRegs := {}
       Local i,j

       dbSelectArea("SX1")
       dbSetOrder(1)
       cPerg := PADR(cPerg,10)
       
       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs,{cPerg,"01","Do produto           ?","","","mv_ch1","C",15,0,0,"G","","mv_par01",""      ,"","","","",""       ,"","","","","","","","","","","","","","","","","","","SB1",""})
       aAdd(aRegs,{cPerg,"02","Ate o produto        ?","","","mv_ch2","C",15,0,0,"G","","mv_par02",""      ,"","","","",""       ,"","","","","","","","","","","","","","","","","","","SB1",""})
       aAdd(aRegs,{cPerg,"03","Do tipo              ?","","","mv_ch3","C",02,0,0,"G","","mv_par03",""      ,"","","","",""       ,"","","","","","","","","","","","","","","","","","","02" ,""})
       aAdd(aRegs,{cPerg,"04","Ate o tipo           ?","","","mv_ch4","C",02,0,0,"G","","mv_par04",""      ,"","","","",""       ,"","","","","","","","","","","","","","","","","","","02" ,""})
       aAdd(aRegs,{cPerg,"05","Do grupo             ?","","","mv_ch5","C",04,0,0,"G","","mv_par05",""      ,"","","","",""       ,"","","","","","","","","","","","","","","","","","","SBM",""})
       aAdd(aRegs,{cPerg,"06","Ate o grupo          ?","","","mv_ch6","C",04,0,0,"G","","mv_par06",""      ,"","","","",""       ,"","","","","","","","","","","","","","","","","","","SBM",""})
       aAdd(aRegs,{cPerg,"07","Da descri็ใo         ?","","","mv_ch7","C",30,0,0,"G","","mv_par07",""      ,"","","","",""       ,"","","","","","","","","","","","","","","","","","",""   ,""})
       aAdd(aRegs,{cPerg,"08","Ate a descri็ใo      ?","","","mv_ch8","C",30,0,0,"G","","mv_par08",""      ,"","","","",""       ,"","","","","","","","","","","","","","","","","","",""   ,""})
       aAdd(aRegs,{cPerg,"09","Do Local             ?","","","mv_ch9","C",02,0,0,"G","","mv_par09",""      ,"","","","",""       ,"","","","","","","","","","","","","","","","","","","99" ,""})
       aAdd(aRegs,{cPerg,"10","At้ o Local          ?","","","mv_cha","C",02,0,0,"G","","mv_par10",""      ,"","","","",""       ,"","","","","","","","","","","","","","","","","","","99" ,""})
       aAdd(aRegs,{cPerg,"11","Apenas itens estoque ?","","","mv_chb","N",01,0,0,"C","","mv_par11","Sim"   ,"","","","","Nใo"    ,"","","","","","","","","","","","","","","","","","",""   ,""})
       aAdd(aRegs,{cPerg,"12","Lista Itens Zerados  ?","","","mv_chc","N",01,0,0,"C","","mv_par12","Sim"   ,"","","","","Nใo"    ,"","","","","","","","","","","","","","","","","","",""   ,""})
       aAdd(aRegs,{cPerg,"13","Somente c/ Lib. Cred.?","","","mv_chd","N",01,0,0,"C","","mv_par13","Sim"   ,"","","","","Nใo"    ,"","","","","","","","","","","","","","","","","","",""   ,""})
       aAdd(aRegs,{cPerg,"14","Ordem                ?","","","mv_che","N",01,0,0,"C","","mv_par14","Codigo","","","","","Consumo","","","","","","","","","","","","","","","","","","",""   ,""})
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
Return
