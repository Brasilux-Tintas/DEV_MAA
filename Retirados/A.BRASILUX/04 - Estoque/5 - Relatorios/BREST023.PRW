#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณ BREST023 บ Autor ณ Luํs Gustavo de Souza บ Data ณ 10/07/03 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณ Monta rela็ใo de produtos, com quantidades de vendas, m้diaบฑฑ
ฑฑบ          ณ de consumos, etc.                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function BREST023()
     //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
     //ณ Declaracao de Variaveis                                             ณ
     //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

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
     Private nomeprog     := "BREST023"
     Private nTipo        := 15
     Private aReturn      := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
     Private nLastKey     := 0
     Private cPerg        := "EST023"
     Private cbtxt        := Space(10)
     Private cbcont       := 00
     Private CONTFL       := 01
     Private m_pag        := 01
     Private wnrel        := "BREST023"

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
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP6 IDE            บ Data ณ  10/07/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
       Local nOrdem
       Local cQry1 := ""
       Local cQry2 := ""

       cQry1 := "SELECT SB1.B1_COD, "
       cQry1 += "       SB1.B1_DESC, "
       cQry1 += "       SB1.B1_TIPO, "
       cQry1 += "       SB1.B1_UM, "
       cQry1 += "       (SB21.B2_QATU) AS B2_QATU, "
       cQry1 += "       (SB21.B2_QEMP+SB21.B2_RESERVA)+(IsNull(SB22.B2_QEMP,0)+IsNull(SB22.B2_RESERVA,0)) AS B2_LIBCRED, "
       cQry1 += "       (SELECT ISNULL(SUM( C6_QTDVEN - ( C6_QTDEMP + C6_QTDENT ) ),0) "
       cQry1 += "        FROM SC6"+cEmpAnt+"0 SC6 "
       cQry1 += "        WHERE SC6.D_E_L_E_T_ = '' "
       cQry1 += "          AND SC6.C6_FILIAL = '01' "
       cQry1 += "          AND SC6.C6_PRODUTO = SB1.B1_COD "
       cQry1 += "          AND SC6.C6_LOCAL  = '"+mv_par09+"') AS C6_QTDVEN, "
       cQry1 += "        SB1.B1_EMIN, "
       cQry1 += "        SB1.B1_LE, "
       cQry1 += "        IsNull(ZZ2.ZZ2_MEDIA,0) AS ZZ2_MEDIA, "
       cQry1 += "        (SB21.B2_QATU) - ((SB21.B2_QEMP+SB21.B2_RESERVA)+(IsNull(SB22.B2_QEMP,0)+IsNull(SB22.B2_RESERVA,0))) AS B2_SUGESTAO, "
       cQry1 += "        SUBSTRING(SB21.B2_USAI,7,2)+'/'+SUBSTRING(SB21.B2_USAI,5,2)+'/'+SUBSTRING(SB21.B2_USAI,1,4) AS B2_USAI "
       cQry1 += "FROM SB1"+cEmpAnt+"0 SB1 WITH (NOLOCK) "
       cQry1 += "LEFT OUTER JOIN SB2"+cEmpAnt+"0 SB21 WITH (NOLOCK) ON SB1.B1_FILIAL = SB21.B2_FILIAL AND SB1.B1_COD = SB21.B2_COD AND SB21.B2_LOCAL  = SB1.B1_LOCPAD AND SB21.D_E_L_E_T_ = '' "
       cQry1 += "LEFT OUTER JOIN ZZ2"+cEmpAnt+"0 ZZ2 WITH (NOLOCK)  ON SB1.B1_FILIAL = ZZ2.ZZ2_FILIAL AND SB1.B1_COD = ZZ2.ZZ2_COD AND ZZ2.D_E_L_E_T_ = '' "
       cQry1 += "LEFT OUTER JOIN SB2020          SB22 WITH (NOLOCK) ON SB1.B1_FILIAL = SB22.B2_FILIAL AND SB1.B1_COD = SB22.B2_COD AND SB22.B2_LOCAL  = SB1.B1_LOCPAD AND SB22.D_E_L_E_T_ = '' "
       cQry1 += "WHERE SB1.D_E_L_E_T_ = '' "
       cQry1 += "  AND SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
       cQry1 += "  AND SB1.B1_COD    BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
       cQry1 += "  AND SB1.B1_TIPO   BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
       cQry1 += "  AND SB1.B1_GRUPO  BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' "
       cQry1 += "  AND SB1.B1_DESC   BETWEEN '"+mv_par07+"' AND '"+mv_par08+"' "
       cQry1 += "  AND SB1.B1_LOCPAD = '"+mv_par09+"' "
       If mv_par10 == 1
          cQry1 += "  AND SB21.B2_LOCALIZ<> '' "
       Endif
       If mv_par11 == 2
          cQry1 += "  AND SB21.B2_QATU <> 0.0 "
       Endif
       If mv_par12 == 1
          cQry1 += "  AND (SB21.B2_QEMP+SB21.B2_RESERVA)+(IsNull(SB22.B2_QEMP,0)+IsNull(SB22.B2_RESERVA,0)) > 0.0 "
       Endif
       If mv_par13 == 1
          cQry1 += "ORDER BY SB1.B1_COD "
       Else
          cQry1 += "ORDER BY ZZ2.ZZ2_MEDIA DESC "
       Endif
       cQry1 := ChangeQuery(cQry1)
       dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry1),"QCON",.T.,.T.)
       
       dbSelectArea("QCON")

       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

       SetRegua(RecCount())

       dbGoTop()
       While !EOF()
             nQtdBLi := 0
             
             cQry3 := ""
             cQry3 += "SELECT ISNULL(SUM( C6_QTDVEN - ( C6_QTDEMP + C6_QTDENT ) ),0) AS C6_QTDVEN  "
             cQry3 += "FROM SC6020 SC6 "
             cQry3 += "WHERE SC6.D_E_L_E_T_ = '' "
             cQry3 += "  AND SC6.C6_FILIAL  = '"+xFilial("SC6")+"' "
             cQry3 += "  AND SC6.C6_PRODUTO = '"+QCON->B1_COD+"'
             cQry3 += "  AND SC6.C6_LOCAL   = '"+mv_par09+"'
             cQry3 := ChangeQuery(cQry3)
             dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry3),"QCON2",.T.,.T.)
             DbSelectArea("QCON2")
             
             cQry4 := "SELECT ISNULL(SUM(SC2.C2_QUANT),0) AS C2_QUANT "
             cQry4 += "FROM "+RetSqlName("SC2")+" SC2 "
             cQry4 += "WHERE SC2.D_E_L_E_T_ = '' "
             cQry4 += "  AND SC2.C2_FILIAL  = '"+xFilial("SC2")+"' "
             cQry4 += "  AND SC2.C2_PRODUTO = '"+QCON->B1_COD+"' "
             cQry4 += "  AND SC2.C2_DATRF   = '' "
             cQry4 += "  AND (SC2.C2_QUANT - SC2.C2_QUJE) > 0 "
             cQry4 := ChangeQuery(cQry4)
             dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry4),"QCON3",.T.,.T.)
             DbSelectArea("QCON3")

             //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
             //ณ Verifica o cancelamento pelo usuario...                             ณ
             //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
             /* PEDIDOS BLOQUEADOS NO CREDITO */
             cQry5 := ""
             cQry5 += "SELECT ISNULL(SUM(SC9.C9_QTDLIB),0) AS C9_QTDBLIB "
             cQry5 += "FROM "+RetSqlName("SC9")+" SC9 "
             cQry5 += "WHERE SC9.C9_PRODUTO = '"+QCON->B1_COD+"' "
             cQry5 += "  AND SC9.C9_FILIAL  = '"+xFilial("SC9")+"' "
             cQry5 += "  AND SC9.D_E_L_E_T_ = '' "
             cQry5 += "  AND SC9.C9_NFISCAL = '' "
             cQry5 += "  AND SC9.C9_LOCAL   = '"+MV_PAR09+"' "
             cQry5 += "  AND SC9.C9_BLCRED <> '' "
             TCQUERY cQry5 ALIAS "TMP5" NEW
             DbSelectArea("TMP5")
             DbGoTop()
             nQtdBLi += TMP5->C9_QTDBLIB
             
             DbSelectArea("TMP5")
             DbCloseArea()             
             
             cQry5 := ""
             cQry5 += "SELECT ISNULL(SUM(SC9.C9_QTDLIB),0) AS C9_QTDBLIB "
             cQry5 += "FROM SC9020 SC9 "
             cQry5 += "WHERE SC9.C9_PRODUTO = '"+QCON->B1_COD+"' "
             cQry5 += "  AND SC9.C9_FILIAL  = '"+xFilial("SC9")+"' "
             cQry5 += "  AND SC9.D_E_L_E_T_ = '' "
             cQry5 += "  AND SC9.C9_NFISCAL = '' "
             cQry5 += "  AND SC9.C9_LOCAL   = '"+MV_PAR09+"' "
             cQry5 += "  AND SC9.C9_BLCRED <> '' "
             TCQUERY cQry5 ALIAS "TMP5" NEW
             DbSelectArea("TMP5")
             DbGoTop()
             nQtdBLi += TMP5->C9_QTDBLIB
             
             DbSelectArea("TMP5")
             DbCloseArea()
             
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
             
             @ nLin,000 PSAY QCON->B1_COD      Picture "@R XX 99.99.999.99"                    //Codigo do Produto
             @ nLin,019 PSAY QCON->B1_DESC     Picture "@!"                                    //Descri็ใo do Produto
             @ nLin,051 PSAY QCON->B1_TIPO     Picture "@!"                                    //Tipo do Produto
             @ nLin,055 PSAY QCON->B1_UM       Picture "@!"                                    //Unidade de Medida
             @ nLin,059 PSAY QCON->B2_QATU     Picture "@E 9,999,999.99"                       //Quantidade Atual
             @ nLin,072 PSAY QCON->B2_LIBCRED  Picture "@E 9,999,999.99"  //Quantidade Liberada pelo cr้dito
             @ nLin,087 PSAY QCON3->C2_QUANT   Picture "@E 9,999,999.99"
             @ nLin,101 PSAY Iif( ((QCON->C6_QTDVEN  + QCON2->C6_QTDVEN + nQtdBLi) ) <= 0, (QCON->C6_QTDVEN  + QCON2->C6_QTDVEN + nQtdBLi), ((QCON->C6_QTDVEN  + QCON2->C6_QTDVEN + nQtdBLi) )) Picture "@E 9,999,999.99"
             @ nLin,115 PSAY QCON->B1_EMIN     Picture "@E 9,999,999.99"                       //Ponto de Pedido
             @ nLin,129 PSAY QCON->B1_LE       Picture "@E 9,999,999.99"                       //Lote Econ๔mico
             @ nLin,143 PSAY QCON->ZZ2_MEDIA   Picture "@E 9,999,999.99"                       //Media de Consumo de 3 meses
             @ nLin,157 PSAY Iif( ((QCON->B2_QATU + QCON3->C2_QUANT) - QCON->B2_LIBCRED ) < 0, ((QCON->B2_QATU + QCON3->C2_QUANT) - QCON->B2_LIBCRED ), 0) Picture "@E 9,999,999.99"                       //Sugestใo para produ็ใo
             @ nLin,171 PSAY QCON->B2_USAI                                                     //Data da Ultima saํda

             nLin := nLin + 1 // Avanca a linha de impressao
             //DbSelectArea("QCON1")
             //DbCloseArea()
             DbSelectArea("QCON2")
             DbCloseArea()
             DbSelectArea("QCON3")
             DbCloseArea()
             DbSelectArea("QCON")
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
       
       dbSelectArea("QCON")
       dbCloseArea()
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
       aAdd(aRegs,{cPerg,"09","Local                ?","","","mv_ch9","C",02,0,0,"G","","mv_par09",""      ,"","","","",""       ,"","","","","","","","","","","","","","","","","","","99" ,""})
       aAdd(aRegs,{cPerg,"10","Apenas itens estoque ?","","","mv_cha","N",01,0,0,"C","","mv_par10","Sim"   ,"","","","","Nใo"    ,"","","","","","","","","","","","","","","","","","",""   ,""})
       aAdd(aRegs,{cPerg,"11","Lista Itens Zerados  ?","","","mv_chb","N",01,0,0,"C","","mv_par11","Sim"   ,"","","","","Nใo"    ,"","","","","","","","","","","","","","","","","","",""   ,""})
       aAdd(aRegs,{cPerg,"12","Somente c/ Lib. Cred.?","","","mv_chc","N",01,0,0,"C","","mv_par12","Sim"   ,"","","","","Nใo"    ,"","","","","","","","","","","","","","","","","","",""   ,""})
       aAdd(aRegs,{cPerg,"13","Ordem                ?","","","mv_chd","N",01,0,0,"C","","mv_par13","Codigo","","","","","Consumo","","","","","","","","","","","","","","","","","","",""   ,""})
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
