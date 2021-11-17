#include "rwmake.ch"
#include "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BREST026 บ Autor ณ Luํs Gustavo       บ Data ณ  15/01/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rela็ใo de Programa de Produ็ใo.                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function BREST026()
     //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
     //ณ Declaracao de Variaveis                                             ณ
     //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
     Local cDesc1       := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2       := "de acordo com os parametros informados pelo usuario."
     Local cDesc3       := "Programa de Produ็ใo"
     Local cPict        := ""
     Local titulo       := "Programa de Produ็ใo"
     Local nLin         := 80
     Local Cabec1       := "                                                            SALDOS EM   PEDIDOS LIB  PEDIDOS NAO  PEDIDOS BLQ   TOTAL DE    ORDENS PROD.  PONTO DE       LOTE        MEDIA DE   SUGESTAO DE    ULTIMA"
     Local Cabec2       := "CODIGO             DESCRICAO                       TP  UM    ESTOQUE      CREDITO     LIBERADOS     CREDITO      PEDIDOS     COLOCADAS     PEDIDO      ECONOMICO     3 MESES     PRODUCAO      SAIDA "
     Local imprime      := .T.
     Local aOrd         := {}
     Private lEnd       := .F.
     Private lAbortPrint:= .F.
     Private CbTxt      := ""
     Private limite     := 220
     Private tamanho    := "G"
     Private nomeprog   := "BREST026" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo      := 18
     Private aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey   := 0
     Private cPerg      := "EST026"
     Private cbtxt      := Space(10)
     Private cbcont     := 00
     Private CONTFL     := 01
     Private m_pag      := 01
     Private wnrel      := "BREST026" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString    := "SB1"

     DbSelectArea("SB1")
     DbSetOrder(1)

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
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP6 IDE            บ Data ณ  15/01/04   บฑฑ
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
       Local cQry1  := ""
       Local cQry2  := ""
       Local cQry3  := ""
       Local cQry4  := ""
       Local cQry5  := ""
       Local cQry6  := ""
       Local cQry7  := ""
       Local cQry8  := ""
       Local aRelat := {}
       Local aResLi := {}
       Local nPos   := 0
       Local _ni
       cQry1 := "SELECT * "
       cQry1 += "FROM "+RetSqlName("SB1")+" SB1 "
       cQry1 += "WHERE SB1.D_E_L_E_T_ = '' "
       cQry1 += "  AND SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
       cQry1 += "  AND SB1.B1_COD    BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
       cQry1 += "  AND SB1.B1_TIPO   BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
       cQry1 += "  AND SB1.B1_GRUPO  BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' "
       cQry1 += "  AND SB1.B1_DESC   BETWEEN '"+mv_par07+"' AND '"+mv_par08+"' "
       cQry1 += "  AND SB1.B1_LOCPAD = '"+mv_par09+"' "
       
       TCQUERY cQry1 ALIAS "TCQ" NEW
       
       dbSelectArea(cString)
       dbSetOrder(1)

       SetRegua(RecCount())
       
       DbSelectArea("TCQ")
       DbGoTop()
       While !EOF()
             nSldAtu := 0
             nTotItm := 0
             nQtdNLi := 0
             nQtdBLi := 0
             nQtdLib := 0
             nQtdOp  := 0
             nQtdPed := 0
             nQtdMed := 0
             
             /* SALDO DO ITEM */
             cQry2 := ""
             cQry2 += "SELECT SB2.B2_COD, SB2.B2_LOCAL, SB2.B2_QATU, SB2.B2_USAI, SB2.B2_LOCALIZ "
             cQry2 += "FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) "
             cQry2 += "WHERE SB2.B2_COD = '"+TCQ->B1_COD+"' "
             cQry2 += "  AND SB2.B2_FILIAL  = '"+xFilial("SB2")+"' "
             cQry2 += "  AND SB2.D_E_L_E_T_ = '' "
             cQry2 += "  AND SB2.B2_LOCAL = '"+TCQ->B1_LOCPAD+"' "
             TCQUERY cQry2 ALIAS "TMP2" NEW
             
             DbSelectArea("TMP2")
             DbGoTop()
             If mv_par10 == 1
                If TMP2->B2_LOCALIZ <> ''
                   DbSelectArea("TMP2")
                   DbCloseArea()
                   DbSelectArea("TCQ")
                   DbSkip()
                   Loop
                Endif
             Endif
             If mv_par11 == 2
                If TMP2->B2_QATU <> 0.0
                   DbSelectArea("TMP2")
                   DbCloseArea()
                   DbSelectArea("TCQ")
                   DbSkip()
                   Loop
                Endif
             Endif
             nSldAtu := TMP2->B2_QATU
             nUltSai := TMP2->B2_USAI
             DbSelectArea("TMP2")
             DbCloseArea()

             /* TOTAL DE PEDIDOS DO ITEM */
             cQry3 := ""
             cQry3 += "SELECT ISNULL(SUM(SC6.C6_QTDVEN),0) AS C6_TOTVEN "
             cQry3 += "FROM "+RetSqlName("SC6")+" SC6 "
             cQry3 += "WHERE SC6.C6_PRODUTO = '"+TCQ->B1_COD+"' "
             cQry3 += "  AND SC6.D_E_L_E_T_ = '' "
             cQry3 += "  AND SC6.C6_NOTA    = '' "
             TCQUERY cQry3 ALIAS "TMP3" NEW
             DbSelectArea("TMP3")
             DbGoTop()
             nTotItm += TMP3->C6_TOTVEN
             
             DbSelectArea("TMP3")
             DbCloseArea()
             
             cQry3 := ""
             cQry3 += "SELECT ISNULL(SUM(SC6.C6_QTDVEN),0) AS C6_TOTVEN "
             cQry3 += "FROM SC6020 SC6 "
             cQry3 += "WHERE SC6.C6_PRODUTO = '"+TCQ->B1_COD+"' "
             cQry3 += "  AND SC6.D_E_L_E_T_ = '' "
             cQry3 += "  AND SC6.C6_NOTA    = '' "
             TCQUERY cQry3 ALIAS "TMP3" NEW
             DbSelectArea("TMP3")
             DbGoTop()
             nTotItm += TMP3->C6_TOTVEN
             
             DbSelectArea("TMP3")
             DbCloseArea()
             
             /* PEDIDOS NAO LIBERADOS */
             cQry4 := ""
             cQry4 += "SELECT ISNULL(SUM(SC6.C6_QTDVEN),0) AS C6_QTDNLI "
             cQry4 += "FROM "+RetSqlName("SC6")+" SC6 "
             cQry4 += "LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 ON SC6.C6_FILIAL = SC5.C5_FILIAL AND SC6.C6_NUM = SC5.C5_NUM "
             cQry4 += "WHERE SC6.C6_FILIAL = '"+xFilial("SC6")+"' "
             cQry4 += "  AND SC6.C6_PRODUTO = '"+TCQ->B1_COD+"' "
             cQry4 += "  AND SC6.D_E_L_E_T_ = '' "
             cQry4 += "  AND SC6.C6_NOTA    = '' "
             cQry4 += "  AND SC6.C6_LOCAL   = '"+TCQ->B1_LOCPAD+"' "
             cQry4 += "  AND C5_LIBEROK     <> 'S' "
             TCQUERY cQry4 ALIAS "TMP4" NEW
             DbSelectArea("TMP4")
             DbGoTop()
             nQtdNLi += TMP4->C6_QTDNLI
             
             DbSelectArea("TMP4")
             DbCloseArea()

             cQry4 := ""
             cQry4 += "SELECT ISNULL(SUM(SC6.C6_QTDVEN),0) AS C6_QTDNLI "
             cQry4 += "FROM SC6020 SC6 "
             cQry4 += "LEFT OUTER JOIN SC5020 SC5 ON SC6.C6_FILIAL = SC5.C5_FILIAL AND SC6.C6_NUM = SC5.C5_NUM "
             cQry4 += "WHERE SC6.C6_FILIAL = '"+xFilial("SC6")+"' "
             cQry4 += "  AND SC6.C6_PRODUTO = '"+TCQ->B1_COD+"' "
             cQry4 += "  AND SC6.D_E_L_E_T_ = '' "
             cQry4 += "  AND SC6.C6_NOTA    = '' "
             cQry4 += "  AND SC6.C6_LOCAL   = '"+TCQ->B1_LOCPAD+"' "
             cQry4 += "  AND C5_LIBEROK     <> 'S' "
             TCQUERY cQry4 ALIAS "TMP4" NEW
             DbSelectArea("TMP4")
             DbGoTop()
             nQtdNLi += TMP4->C6_QTDNLI
             
             DbSelectArea("TMP4")
             DbCloseArea()             

             /* PEDIDOS BLOQUEADOS NO CREDITO */
             cQry5 := ""
             cQry5 += "SELECT ISNULL(SUM(SC9.C9_QTDLIB),0) AS C9_QTDBLIB "
             cQry5 += "FROM "+RetSqlName("SC9")+" SC9 "
             cQry5 += "WHERE SC9.C9_PRODUTO = '"+TCQ->B1_COD+"' "
             cQry5 += "  AND SC9.C9_FILIAL  = '"+xFilial("SC9")+"' "
             cQry5 += "  AND SC9.D_E_L_E_T_ = '' "
             cQry5 += "  AND SC9.C9_NFISCAL = '' "
             cQry5 += "  AND SC9.C9_LOCAL   = '"+TCQ->B1_LOCPAD+"' "
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
             cQry5 += "WHERE SC9.C9_PRODUTO = '"+TCQ->B1_COD+"' "
             cQry5 += "  AND SC9.C9_FILIAL  = '"+xFilial("SC9")+"' "
             cQry5 += "  AND SC9.D_E_L_E_T_ = '' "
             cQry5 += "  AND SC9.C9_NFISCAL = '' "
             cQry5 += "  AND SC9.C9_LOCAL   = '"+TCQ->B1_LOCPAD+"' "
             cQry5 += "  AND SC9.C9_BLCRED <> '' "
             TCQUERY cQry5 ALIAS "TMP5" NEW
             DbSelectArea("TMP5")
             DbGoTop()
             nQtdBLi += TMP5->C9_QTDBLIB
             
             DbSelectArea("TMP5")
             DbCloseArea()             

             /* QUANTIDADE DE OPs COLOCADAS */
             cQry6 := ""
             cQry6 := "SELECT ISNULL(SUM(SC2.C2_QUANT),0) AS C2_QUANT "
             cQry6 += "FROM "+RetSqlName("SC2")+" SC2 "
             cQry6 += "WHERE SC2.D_E_L_E_T_ = '' "
             cQry6 += "  AND SC2.C2_FILIAL  = '"+xFilial("SC2")+"' "
             cQry6 += "  AND SC2.C2_PRODUTO = '"+TCQ->B1_COD+"' "
             cQry6 += "  AND SC2.C2_DATRF   = '' "
             cQry6 += "  AND (SC2.C2_QUANT - SC2.C2_QUJE) > 0 "
             TCQUERY cQry6 ALIAS "TMP6" NEW
             
             DbSelectArea("TMP6")
             DbGoTop()
             nQtdOp += TMP6->C2_QUANT
             
             DbSelectArea("TMP6")
             DbCloseArea()

             /* PEDIDOS LIBERADOS PELO CREDITO */
             cQry7 := ""
             cQry7 += "SELECT ISNULL(SUM(SC9.C9_QTDLIB),0) AS C9_QTDLIB "
             cQry7 += "FROM "+RetSqlName("SC9")+" SC9 "
             cQry7 += "WHERE SC9.C9_PRODUTO = '"+TCQ->B1_COD+"' "
             cQry7 += "  AND SC9.C9_FILIAL  = '"+xFilial("SC9")+"' "
             cQry7 += "  AND SC9.D_E_L_E_T_ = '' "
             cQry7 += "  AND SC9.C9_NFISCAL = '' "
             cQry7 += "  AND SC9.C9_LOCAL   = '"+TCQ->B1_LOCPAD+"' "
             cQry7 += "  AND SC9.C9_BLCRED  = '' "
             TCQUERY cQry7 ALIAS "TMP7" NEW
             DbSelectArea("TMP7")
             DbGoTop()
             nQtdLib += TMP7->C9_QTDLIB
             
             DbSelectArea("TMP7")
             DbCloseArea()

             cQry7 := ""
             cQry7 += "SELECT ISNULL(SUM(SC9.C9_QTDLIB),0) AS C9_QTDLIB "
             cQry7 += "FROM SC9020 SC9 WITH (NOLOCK) "
             cQry7 += "WHERE SC9.C9_PRODUTO = '"+TCQ->B1_COD+"' "
             cQry7 += "  AND SC9.C9_FILIAL  = '"+xFilial("SC9")+"' "
             cQry7 += "  AND SC9.D_E_L_E_T_ = '' "
             cQry7 += "  AND SC9.C9_NFISCAL = '' "
             cQry7 += "  AND SC9.C9_LOCAL   = '"+TCQ->B1_LOCPAD+"' "
             cQry7 += "  AND SC9.C9_BLCRED  = '' "
             TCQUERY cQry7 ALIAS "TMP7" NEW
             DbSelectArea("TMP7")
             DbGoTop()
             nQtdLib += TMP7->C9_QTDLIB
             
             DbSelectArea("TMP7")
             DbCloseArea()
                          
             If mv_par12 == 1
                If nQtdLib <= 0.0
                   DbSelectArea("TCQ")
                   DbSkip()
                   Loop
                Endif
             Endif
             
             /* MEDIA DE CONSUMO */
             cQry8 := ""
             cQry8 += "SELECT * "
             cQry8 += "FROM "+RetSqlName("ZZ2")+" ZZ2 WITH (NOLOCK) "
             cQry8 += "WHERE ZZ2.ZZ2_COD = '"+TCQ->B1_COD+"' "
             cQry8 += "  AND ZZ2.ZZ2_FILIAL = '"+xFilial("ZZ2")+"' "
             cQry8 += "  AND ZZ2.D_E_L_E_T_ = '' "
             TCQUERY cQry8 ALIAS "TMP8" NEW
             
             DbSelectArea("TMP8")
             DbGoTop()
             nQtdMed += TMP8->ZZ2_MEDIA
             
             DbSelectArea("TMP8")
             DbCloseArea()
             
             aadd(aRelat, { TCQ->B1_COD              ,; // 01 - C๓digo do Produto
                            SubStr(TCQ->B1_DESC,1,30),; // 02 - Descri็ใo do Produto
                            TCQ->B1_TIPO             ,; // 03 - Tipo do Produto
                            TCQ->B1_UM               ,; // 04 - Unidade de Medida do Produto
                            nSldAtu                  ,; // 05 - Saldo Atual
                            nQtdLib                  ,; // 06 - Total de Pedidos Liberados no credito
                            nQtdNLi                  ,; // 07 - Total de Pedidos nao Liberados
                            nQtdBLi                  ,; // 08 - Total de Pedidos Bloqueados no credito
                            nTotItm                  ,; // 09 - Total de Pedido de Vendas
                            nQtdOp                   ,; // 10 - Quantidade de OPs
                            TCQ->B1_EMIN             ,; // 11 - Ponto de Pedido 
                            TCQ->B1_LE               ,; // 12 - Lote Economico
                            nQtdMed                  ,; // 13 - Media de Consumo
                            ((nSldAtu + nQtdOp) - nQtdLib),; // 14 - Sugestao Compras
                            SubStr(nUltSai,7,2)+"/"+SubStr(nUltSai,5,2)+"/"+SubStr(nUltSai,1,4) }) // 15 - Ultima saida 
             
             nPos := aScan(aResLi, {|x| x[1] == Substr(TCQ->B1_COD,4,2)})
             If nPos == 0
                aadd(aResLi,{Substr(TCQ->B1_COD,4,2),;
                             SubStr(Posicione("SZ1", 1, xFilial("SZ1")+Substr(TCQ->B1_COD,4,2),"Z1_DESCR"),1,20),;
                             Posicione("SZ5", 1, xFilial("SZ5")+Substr(TCQ->B1_COD,11,2),"Z5_VOLUME") * nQtdLib,;
                             Posicione("SZ5", 1, xFilial("SZ5")+Substr(TCQ->B1_COD,11,2),"Z5_VOLUME") * nQtdPed })
             Else
                aResLi[nPos][3] := aResLi[nPos][3] + Posicione("SZ5", 1, xFilial("SZ5")+Substr(TCQ->B1_COD,11,2),"Z5_VOLUME") * nQtdLib
                aResLi[nPos][4] := aResLi[nPos][4] + Posicione("SZ5", 1, xFilial("SZ5")+Substr(TCQ->B1_COD,11,2),"Z5_VOLUME") * nQtdPed
             Endif
             
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
       
       If Len(aRelat) > 0
          If mv_par13 == 1
             aSort(aRelat,,, {|x,y| x[1] < y[1] } )
          Else
             aSort(aRelat,,, {|x,y| x[11] > y[11] } )
          Endif
       Endif
       
       aSort(aResLi,,, {|x,y| x[1] < y[1] })
       
       For _ni := 1 to Len(aRelat) 
           If lAbortPrint
              @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
              Exit
           Endif

           If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
              nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
              nLin += 1
           Endif

           @ nLin,000 PSAY aRelat[_ni,01] Picture "@R XX 99.99.999.99" //Codigo
           @ nLin,019 PSAY aRelat[_ni,02] Picture "@!"                 //Descri็ใo
           @ nLin,051 PSAY aRelat[_ni,03] Picture "@!"                 //Tipo
           @ nLin,055 PSAY aRelat[_ni,04] Picture "@!"                 //Unidade de Medida
           @ nLin,059 PSAY aRelat[_ni,05] Picture "@E 9,999,999.99"    //Saldo Atual
           @ nLin,072 PSAY aRelat[_ni,06] Picture "@E 9,999,999.99"    //Total de pedidos
           @ nLin,085 PSAY aRelat[_ni,07] Picture "@E 9,999,999.99"    //Total de Pedidos nao liberados
           @ nLin,098 PSAY aRelat[_ni,08] Picture "@E 9,999,999.99"    //Total de Pedidos bloqueados no credito
           @ nLin,111 PSAY aRelat[_ni,09] Picture "@E 9,999,999.99"    //Total de Pedidos Liberados no credito
           @ nLin,124 PSAY aRelat[_ni,10] Picture "@E 9,999,999.99"    //OPs Colocadas
           @ nLin,137 PSAY aRelat[_ni,11] Picture "@E 9,999,999.99"    //Ponto de Pedido
           @ nLin,150 PSAY aRelat[_ni,12] Picture "@E 9,999,999.99"    //Lote Economico
           @ nLin,163 PSAY aRelat[_ni,13] Picture "@E 9,999,999.99"    //Media de consumo
           @ nLin,176 PSAY Iif(aRelat[_ni,14] < 0, aRelat[_ni,14], 0) Picture "@E 9,999,999.99"    //Sugestao de Producao
           @ nLin,190 PSAY aRelat[_ni,15]  // Ultima Saํda
           nLin := nLin + 1 // Avanca a linha de impressao
       Next
       If mv_par14 == 2
           If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
              Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
              nLin := 8
           Endif
            nLin += 1
          @ nLin,000 PSAY "*********************************************************************************"
            nLin += 1
          @ nLin,000 PSAY "***                        RESUMO EM LITROS POR LINHA                         ***"
            nLin += 1
          @ nLin,000 PSAY "*********************************************************************************"
            nLin += 1
          @ nLin,000 PSAY "*** LINHA DESCRIวรO LINHA            QTDE. LIB.    QTDE. PED.    TOTAL EM     ***"
            nLin += 1
          @ nLin,000 PSAY "***                                  CREDITO       COLOCADOS     LITROS       ***"
            nLin += 1
          @ nLin,000 PSAY "*********************************************************************************"
            nLin += 1
          nTotLib := 0
          nTotPed := 0
          nTotTot := 0
          For _ni := 1 to Len(aResLi)
              If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
                 Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                 nLin := 8
              Endif
              @ nLin,004 PSAY aResLi[_ni][1]                  Picture "99"
              @ nLin,10 PSAY aResLi[_ni][2]                  Picture "@!"
              @ nLin,037 PSAY aResLi[_ni][3]                  Picture "@E 9,999,999.99"
              @ nLin,051 PSAY aResLi[_ni][4]                  Picture "@E 9,999,999.99"
              @ nLin,065 PSAY (aResLi[_ni][3]+aResLi[_ni][4]) Picture "@E 9,999,999.99"
                nLin := nLin + 1
              nTotLib += aResLi[_ni][3]
              nTotPed += aResLi[_ni][4]
              nTotTot += (aResLi[_ni][3]+aResLi[_ni][4])
          Next
          @ nLin,000 PSAY "================================================================================="
            nLin += 1
          @ nLin,000 PSAY "TOTAL POR LINHA ==>>> "
          @ nLin,037 PSAY nTotLib Picture "@E 9,999,999.99"
          @ nLin,051 PSAY nTotPed Picture "@E 9,999,999.99"
          @ nLin,065 PSAY nTotTot Picture "@E 9,999,999.99"
            nLin += 1
          @ nLin,000 PSAY ""
          // 0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20
          // 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
          // *********************************************************************************************************************************************************************************************************
          // Brasilux / Matriz
          // SIGA /BREST026/v.AP7 7.10
          // Hora...: 99:99:99
          // *********************************************************************************************************************************************************************************************************
          //                                                             SALDOS EM   PEDIDOS LIB  PEDIDOS NAO  PEDIDOS BLQ   TOTAL DE    ORDENS PROD.  PONTO DE       LOTE        MEDIA DE   SUGESTAO DE    ULTIMA
          // CODIGO             DESCRICAO                       TP  UM    ESTOQUE      CREDITO     LIBERADOS     CREDITO      PEDIDOS     COLOCADAS     PEDIDO      ECONOMICO     3 MESES     PRODUCAO      SAIDA 
          // *********************************************************************************************************************************************************************************************************
          // XX 99.99.999.99    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XX  XX  9,999,999.99 9,999,999.99 9,999,999.99 9,999,999.99 9,999,999.99 9,999,999.99 9,999,999.99 9,999,999.99 9,999,999.99 9,999,999.99  99/99/99
          //
          // ***                        RESUMO EM LITROS POR LINHA                         ***
          // *********************************************************************************
          // *** LINHA DESCRIวรO LINHA            QTDE. LIB.    QTDE. PED.    TOTAL EM     ***
          //                                      CREDITO       COLOCADOS     LITROS
          //     01    XXXXXXXXXXXXXXXXXXXXXXXXX  9,999,999.99  9,999,999.99  9,999,999.99
          //     02    XXXXXXXXXXXXXXXXXXXXXXXXX  9,999,999.99  9,999,999.99  9,999,999.99
          //=================================================================================
          //     TOTAL POR LINHA ==>>> 
       Endif
       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Finaliza a execucao do relatorio...                                 ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
       SET DEVICE TO SCREEN
       If aReturn[5]==1
          dbCommitAll()
          SET PRINTER TO
          OurSpool(wnrel)
       Endif

       MS_FLUSH()

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
       aAdd(aRegs,{cPerg,"14","Resumo em litros     ?","","","mv_chd","N",01,0,0,"C","","mv_par13","Nใo Utiliza","","","","","Resumo por linha","","","","","","","","","","","","","","","","","","",""   ,""})
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