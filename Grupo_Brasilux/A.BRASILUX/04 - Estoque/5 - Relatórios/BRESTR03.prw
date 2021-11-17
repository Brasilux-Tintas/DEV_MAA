#include "rwmake.ch"
#include "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRESTR03 บ Autor ณ Luํs G. de Souza   บ Data ณ  09/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rela็ใo de Custo por produto para fechamento mensal de es- บฑฑ
ฑฑบ          ณ toque.                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX TINTAS TษCNICAS LTDA.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function BRESTR03()
     //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
     //ณ Declaracao de Variaveis                                             ณ
     //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "Rela็ใo de Custo/Produto"
     //Local cPict         := ""
     Local titulo        := "RELACAO DE CUSTO/PRODUTO"
     Local nLin          := 80
     Local Cabec1        := " COD.PRODUTO        DESCRICAO                               TIPO  UN  ALMOX           QTD       CUSTO UNIT         CUSTO TOTAL"
     Local Cabec2        := ""
     //Local imprime       := .T.
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     Private CbTxt       := ""
     Private limite      := 132
     Private tamanho     := "M"
     Private nomeprog    := "BRESTR03" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 18
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := "ESTR03"
     //Private cbtxt       := Space(10)
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRESTR03" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString     := "SB1"
     Private cLocPad     :=""
     DbSelectArea("SB1")
     DbSetOrder(1)
       
  If PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) != 0
        MsgBox("Acesso nใo autorizado!", "Aten็ใo...", "STOP")
        Return
    Endif

     //ValidPerg()  //LGS#20200130 - Adequa็ใo a release 12.1.25
     Pergunte(cPerg, .F.)

     //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
     //ณ Monta a interface padrao com o usuario...                           ณ
     //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

     wnrel := SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho, , .F.)

     If nLastKey == 27
        Return
     Endif

     SetDefault(aReturn,cString)

     If nLastKey == 27
        Return
     Endif

     nTipo := If(aReturn[4] == 1, 15, 18)

     //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
     //ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
     //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

     Processa({|| RunReport(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP6 IDE            บ Data ณ  09/01/08   บฑฑ
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
       Local cQry1   := ""
       Local cQry2   := ""
       Local cQry3   := ""
       Local _TotQtd := 0.00
       Local _TotCus := 0.00
       Local aFecMes := {}
       Local cMesAno :=""
       Local nY
       Local _nICMPAD := GETMV("MV_ICMPAD")
       
       If Len(MV_PAR08)== 6
       		cMesAno := Substr(MV_PAR08,3,6)+Substr(MV_PAR08,1,2)
       Else	
       	    cMesAno := Substr(DTOS(GETMV("MV_ULMES")),1,6)
       	    MV_PAR08 := cMesAno
       Endif
       
       cQry1 += "SELECT * "
       cQry2 += "SELECT COUNT(*) AS QTDREG "
       cQry3 += "FROM "+RetSqlName("SB1")+" A WITH (NOLOCK) "
       cQry3 += "WHERE A.B1_FILIAL = '"+xFilial("SB1")+"' "
       cQry3 += "  AND A.B1_COD  BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
       cQry3 += "  AND A.B1_TIPO BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
       cQry3 += "  AND A.B1_UM   BETWEEN '"+mv_par05+"' AND '"+mv_par06+"'"
       cQry3 += "  AND (A.D_E_L_E_T_ <> '*') "
       cQry1 += cQry3
       cQry2 += cQry3
       cQry1 += "ORDER BY A.B1_FILIAL, A.B1_COD "

       TCQuery cQry2 NEW ALIAS "TCQ"
       DbSelectArea("TCQ")

       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
       ProcRegua(TCQ->QTDREG)
       DbSelectArea("TCQ")
       DbCloseArea()

       TCQuery cQry1 NEW ALIAS "TCQ"
       DbSelectArea("TCQ")
       DbGoTop()
       While !Eof()
             //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
             //ณ Verifica o cancelamento pelo usuario...                             ณ
             //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
             IncProc("Imprimindo relat๓rio...")
             If lAbortPrint
                @ nLin,000 PSAY "*** CANCELADO PELO OPERADOR ***"
                Exit
             Endif
             cQry1 := ""
             If mv_par07 == 1 // Saldo Atual
                 cQry1 += "SELECT SB2.B2_FILIAL AS FILIAL, SB2.B2_COD AS CODIGO, SUM(SB2.B2_QATU) AS QTDE "
                 cQry1 += "FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) "
                 cQry1 += "WHERE SB2.B2_FILIAL  = '"+xFilial("SB2")+"' "
                 cQry1 += "  AND SB2.D_E_L_E_T_ = '' "
                 cQry1 += "  AND SB2.B2_COD     = '"+TCQ->B1_COD+"' "
                 If mv_par09 == 2
                    cQry1 += "  AND SB2.B2_QATU    > 0 "
                 Endif
                 If mv_par12 $ '03.02'
                    cLocPad := mv_par12
                    cQry1 += "  AND SB2.B2_LOCAL   IN('40',  '"+mv_par12+"') "
                 ElseIf mv_par12 $ '30.20'
                    cLocPad := mv_par12
                    cQry1 += "  AND SB2.B2_LOCAL   IN('"+mv_par12+"') "
                 ElseIf Empty(mv_par12)
                        cLocPad := ''
                    cQry1 += "  AND SB2.B2_LOCAL   IN('40', '03', '02', '30', '20') "
                 Else
                    cLocPad := mv_par12
                    cQry1 += "  AND SB2.B2_LOCAL   IN('"+mv_par12+"') "
                 Endif
                 cQry1 += "GROUP BY SB2.B2_FILIAL, SB2.B2_COD "
             Else
                 cQry1 += "SELECT SB9.B9_FILIAL AS FILIAL, SB9.B9_COD AS CODIGO, SUM(SB9.B9_QINI) AS QTDE, SUM(SB9.B9_VINI1) AS VALOR "
                 cQry1 += "FROM "+RetSqlName("SB9")+" SB9 WITH (NOLOCK) "
                 cQry1 += "WHERE SB9.B9_FILIAL  = '"+xFilial("SB9")+"' "
                 cQry1 += "  AND SB9.D_E_L_E_T_ = '' "
                 cQry1 += "  AND SB9.B9_COD     = '"+TCQ->B1_COD+"' "
                 If mv_par09 == 2
                    cQry1 += "  AND SB9.B9_QINI  > 0 "
                 Endif
                 If mv_par12 $ '03.02'
                    cLocPad := mv_par12
                    cQry1 += "  AND SB9.B9_LOCAL IN('40',  '"+mv_par12+"') "
                 ElseIf mv_par12 $ '30.20'
                    cLocPad := mv_par12
                    cQry1 += "  AND SB9.B9_LOCAL IN('"+mv_par12+"') "
                 ElseIf Empty(mv_par12)
                    cLocPad := ''
                    cQry1 += "  AND SB9.B9_LOCAL IN('40', '03', '02', '30', '20') "
                 Else
                    cLocPad := mv_par12
                    cQry1 += "  AND SB9.B9_LOCAL IN('"+mv_par12+"') "
                 Endif
                 cQry1 += "  AND SUBSTRING(SB9.B9_DATA,1,6)   = '"+cMesAno+"' "
                 cQry1 += "GROUP BY SB9.B9_FILIAL, SB9.B9_COD "
             Endif
             TCQuery cQry1 ALIAS "TMP" NEW
             DbSelectArea("TMP")
             DbGoTop()
             While !EoF() .and. TMP->FILIAL == xFilial("SB2") .and. TMP->CODIGO == TCQ->B1_COD
                   //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
                   //ณ Impressao do cabecalho do relatorio. . .                            ณ
                   //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
                   If nLin > 60 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
                      nLin := Cabec(titulo, Cabec1, Cabec2, nomeprog, tamanho, nTipo)
                      nLin += 1
                   Endif
                   If (((mv_par09 == 2) .and. (TMP->QTDE > 0)) .or. (mv_par09 # 2))
                      If !(cNumEmp == '01010104')
                         nCusto := TCQ->B1_UPRC
                         If TCQ->B1_TIPO == "PI" .OR. (TCQ->B1_TIPO == "PA")
                            nLucro := Iif(TCQ->B1_ESTOQUE == "S", TCQ->B1_LUCRO, TCQ->B1_LUCRO2)
                            DbSelectarea("SZ1")
                            DbSetOrder(1)
                            DbSeek(xFilial("SZ1")+SubStr(TCQ->B1_COD, 4, 2), .t.)
                            If Found()
                               nComissao := SZ1->Z1_COMISSA
                            Else
                               nComissao := TCQ->B1_COMIS
                            Endif
                            /*** Substituido em 30/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAวรO DE RELEASE PROTHEUS 12.1.25 ***/
                            //nPercInc := TCQ->B1_PERINT+nLucro+nComissao+GETMV("MV_ICMPAD") // Somar 18% ICMS
                            nPercInc := TCQ->B1_PERINT + nLucro + nComissao + _nICMPAD // Somar 18% ICMS
                            nCusto   := TCQ->B1_CUSTOR / (1 - (nPercInc / 100))
                            If TCQ->B1_TIPO == "PI"
                               nCusto := nCusto * 0.56 // 56% do pre็o de venda do PI
                            Else
                               nCusto := nCusto * 0.70 // 70% do pre็o de venda เ vista do PA
                            Endif
                         Endif
                      Else
                         If Len(Alltrim(TCQ->B1_COD)) <> 12
                            nCusto := Iif(TCQ->B1_TIPO $ 'PA', TCQ->B1_PRV1, TCQ->B1_CUSTOR)
                            If TCQ->B1_TIPO == "PI"
                               nCusto := nCusto * 0.56 // 56% do pre็o de venda do PI
                            Else
                               nCusto := nCusto * 0.70 // 70% do pre็o de venda เ vista do PA
                            Endif
                         Else
                            nLucro := Iif(TCQ->B1_ESTOQUE == "S", TCQ->B1_LUCRO, TCQ->B1_LUCRO2)
                            DbSelectarea("SZ1")
                            DbSetOrder(1)
                            DbSeek(xFilial("SZ1")+SubStr(TCQ->B1_COD, 4, 2), .t.)
                            If Found()
                               nComissao := SZ1->Z1_COMISSA
                            Else
                               nComissao := TCQ->B1_COMIS
                            Endif
                            /*** Substituido em 30/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAวรO DE RELEASE PROTHEUS 12.1.25 ***/
                            //nPercInc := TCQ->B1_PERINT+nLucro+nComissao+GETMV("MV_ICMPAD") // Somar 18% ICMS
                            nPercInc := TCQ->B1_PERINT + nLucro + nComissao + _nICMPAD // Somar 18% ICMS
                            nCusto   := TCQ->B1_CUSTOR / (1 - (nPercInc / 100))
                            If TCQ->B1_TIPO == "PI"
                               nCusto := nCusto * 0.56 // 56% do pre็o de venda do PI
                            Else
                               nCusto := nCusto * 0.70 // 70% do pre็o de venda เ vista do PA
                            Endif
                         Endif
                      Endif
                      nTotal := Round(TMP->QTDE * nCusto, 2)
                      If (TMP->QTDE >= mv_par10) .and. nCusto > 0.00
                         @ nLin,001 PSAY TCQ->B1_COD     Picture "@R XXX99.99.999-99"
                         @ nLin,020 PSAY TCQ->B1_DESC    Picture "@!"
                         @ nLin,060 PSAY TCQ->B1_TIPO    Picture "@!"
                         @ nLin,065 PSAY TCQ->B1_UM      Picture "@!"
                         @ nLin,070 PSAY Iif(Empty(cLocPad), TCQ->B1_LOCPAD, cLocPad)  Picture "99"
                         @ nLin,075 PSAY TMP->QTDE       Picture "@E 999,999,999.99"  
                         @ nLin,090 PSAY nCusto          Picture "@E 999,999,999.9999"
                         @ nLin,110 PSAY nTotal          Picture "@E 999,999,999.9999"

                         _TotQtd := _TotQtd + TMP->QTDE
                         _TotCus := _TotCus + Round(TMP->QTDE * nCusto, 2)
                         aAdd(aFecMes, {TransForm(TCQ->B1_COD, "@R XXX99.99.999-99"), TCQ->B1_DESC, TCQ->B1_TIPO, TCQ->B1_UM, TCQ->B1_LOCPAD, Transform(TMP->QTDE, "@E 999,999,999.99"), Transform(nCusto, "@E 999,999,999.9999"), Transform(Round(TMP->QTDE * nCusto, 2), "@E 999,999,999.9999") })
                         nLin++
                      Endif
                   Endif                                        
                   DbSelectArea("TMP")
                   DbSkip()
             EndDo
             DbSelectArea("TMP")
             DbCloseArea()
             DbSelectArea("TCQ")              
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
        
       DbSelectArea("SB1")
       If (_TotQtd # 0.00) .or. (_TotCus # 0.00)
          If nLin >= 60
             nLin := Cabec(titulo, Cabec1, Cabec2, nomeprog, tamanho, nTipo)
             nLin += 1
          Endif
          @ nLin,001 PSAY "TOTAL"
          @ nLin,075 PSAY _TotQtd Picture "@E 999,999,999.99"
          @ nLin,110 PSAY _TotCus Picture "@E 999,999,999.9999"
          aAdd(aFecMes, {"TOTAL", "", "", "", "", Transform(_TotQtd, "@E 999,999,999.99"), "", Transform(Round(_TotCus, 2), "@E 999,999,999.9999") })
       Endif

       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Finaliza a execucao do relatorio...                                 ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
       SET DEVICE TO SCREEN
       //Verifica็ใo da Existencia dos Diret๓rios de Controle
       cDirTxt := "C:\Auditec\"+Alltrim(StrZero(Year(dDataBase), 4))+"\Auditec\"
       cDirOri := "C:\Auditec\"+Alltrim(StrZero(Year(dDataBase), 4))+"\Original\"
       If !File("C:\AUDITEC") //Diret๓rio principal
          MakeDir("C:\AUDITEC")
       Endif
       If !File("C:\AUDITEC\"+Alltrim(StrZero(Year(dDataBase), 4))) //Diret๓rio anual
          MakeDir("C:\AUDITEC\"+Alltrim(StrZero(Year(dDataBase), 4)))
       Endif
       If !File("C:\Auditec\"+Alltrim(StrZero(Year(dDataBase), 4))+"\Auditec") //Arquivos Texto para Auditec
          MakeDir("C:\Auditec\"+Alltrim(StrZero(Year(dDataBase), 4))+"\Auditec")
       Endif
       If !File("C:\Auditec\"+Alltrim(StrZero(Year(dDataBase), 4))+"\Original") //Arquivos dos relat๓rios
          MakeDir("C:\Auditec\"+Alltrim(StrZero(Year(dDataBase), 4))+"\Original")
       Endif
       If mv_par11 == 1 //Gera arquivo texto para integra็ใo com a AUDITEC
          If Len(aFecMes) > 0
             Private cEOL        := "CHR(13)+CHR(10)"
             Private cArqTxt     := SUBSTR(cNumEmp,FWSizeFilial()+1,2)+mv_par03+Iif(mv_par03 $ 'PI', Alltrim(mv_par05), '')+Substr(dtos(dDataBase), 1, 6)+Iif(Empty(cLocPad), '_TD', Iif( mv_par03 $ 'PI', Iif(cLocPad $ '02', '_02', '_20'), Iif(cLocPad $ '03', '_03', '_30') ) )+".TXT"
             Private nHdl        := fCreate(cDirTxt+cArqTxt)

             If Empty(cEOL)
                cEOL := CHR(13)+CHR(10)
             Else
               cEOL := Trim(cEOL)
               cEOL := &cEOL
             Endif
             If nHdl == -1
                MsgAlert("O arquivo "+cDirTxt+cArqTxt+" nใo pode ser criado! Verifique com o Administrador do Sistema.", "Aten็ใo!")
                Return
             Endif
             ProcRegua(Len(aFecMes))
             For nY := 1 To Len(aFecMes)
                 IncProc("Gerando arquivo para envio.")
                 nTamLin := 132
                 cLin    := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao
                 // COD.PRODUTO        DESCRICAO                               TIPO  UN  ALMOX           QTD       CUSTO UNIT         CUSTO TOTAL"
                 // XX 99.99.999-99    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                 //         1         2         3         4         5         6         7         8         9         10
                 //1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
                 cLin    := Stuff(cLin, 001, 01, PADR(space(01)     , 01))
                 cLin    := Stuff(cLin, 002, 15, PADR(aFecMes[nY][1], 15))
                 cLin    := Stuff(cLin, 017, 04, PADR(space(04)     , 04))
                 cLin    := Stuff(cLin, 021, 30, PADR(aFecMes[nY][2], 30))
                 cLin    := Stuff(cLin, 051, 10, PADR(space(10)     , 10))
                 cLin    := Stuff(cLin, 061, 02, PADR(aFecMes[nY][3], 02))
                 cLin    := Stuff(cLin, 063, 03, PADR(space(03)     , 03))
                 cLin    := Stuff(cLin, 066, 02, PADR(aFecMes[nY][4], 02))
                 cLin    := Stuff(cLin, 068, 03, PADR(space(03)     , 03))
                 cLin    := Stuff(cLin, 071, 02, PADR(aFecMes[nY][5], 02))
                 cLin    := Stuff(cLin, 073, 03, PADR(space(03)     , 03))
                 cLin    := Stuff(cLin, 076, 14, PADR(aFecMes[nY][6], 14))
                 cLin    := Stuff(cLin, 090, 01, PADR(space(01)     , 01))
                 cLin    := Stuff(cLin, 091, 16, PADR(aFecMes[nY][7], 16))
                 cLin    := Stuff(cLin, 107, 04, PADR(space(04)     , 04))
                 cLin    := Stuff(cLin, 111, 16, PADR(aFecMes[nY][8], 16))
                 If fWrite(nHdl, cLin, Len(cLin)) != Len(cLin)
                    If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
                       Exit
                    Endif
                 Endif
                 /*
                 XXX99.99.999-99    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX          XX   XX   XX   999,999,999.99 999,999,999.9999    999,999,999.9999
                 123456789012345    123456789012345678901234567890          12   12   12   12345678901234 1234567890123456    1234567890123456
                           1         2         3         4         5         6         7         8         9         10        11        12    
                 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345 */
             Next
             fClose(nHdl)
          Endif
       Endif

       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
       If aReturn[5]==1
          DbCommitAll()
          SET PRINTER TO
          OurSpool(wnrel)
          If mv_par11 == 1
             __CopyFile(__RELDIR+wnrel+".##r", cDirOri+SubStr(cArqTxt, 1, Len(cArqTxt)-4)+".##r")
          Endif
       Endif
       MS_FLUSH()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ValidPergบAutor  ณLuํs G. de Souza    บ Data ณ  10/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo das perguntas do relat๓rio.                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Brasilux Tintas T้cnicas Ltda.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
//LGS#20200130 - Adequa็ใo a release 12.1.25
/*
Static Function ValidPerg()
       Local _sAlias := Alias()
       Local i, j
       DbSelectArea("SX1")
       DbSetOrder(1)
       cPerg   := PADR(cPerg,10)
       aRegs   := {}

       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd( aRegs, { cPerg, "01", "Cod.Produto    De   	  ?", "", "", "mv_ch1", "C", 15, 0, 0, "G", "", "mv_par01", ""     , "", "", "", "", ""               , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SB1", "" } )
       aAdd( aRegs, { cPerg, "02", "Cod.Produto    Ate  	  ?", "", "", "mv_ch2", "C", 15, 0, 0, "G", "", "mv_par02", ""     , "", "", "", "", ""               , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SB1", "" } )
       aAdd( aRegs, { cPerg, "03", "Tipo Produto   De   	  ?", "", "", "mv_ch3", "C", 02, 0, 0, "G", "", "mv_par03", ""     , "", "", "", "", ""               , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "02" , "" } )
       aAdd( aRegs, { cPerg, "04", "Tipo Produto   Ate  	  ?", "", "", "mv_ch4", "C", 02, 0, 0, "G", "", "mv_par04", ""     , "", "", "", "", ""               , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "02" , "" } )
       aAdd( aRegs, { cPerg, "05", "Da unidade          	  ?", "", "", "mv_ch5", "C", 02, 0, 0, "G", "", "mv_par05", ""     , "", "", "", "", ""               , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SAH", "" } )
       aAdd( aRegs, { cPerg, "06", "Ate unidade         	  ?", "", "", "mv_ch6", "C", 02, 0, 0, "G", "", "mv_par06", ""     , "", "", "", "", ""               , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SAH", "" } )
       aAdd( aRegs, { cPerg, "07", "Tipo de Saldo       	  ?", "", "", "mv_ch7", "N", 01, 0, 0, "C", "", "mv_par07", "Atual", "", "", "", "", "Ult. Fechamento", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , "" } )
       aAdd( aRegs, { cPerg, "08", "Mes/ Ano Fechamento MMAAAA?", "", "", "mv_ch8", "C", 06, 0, 0, "G", "", "mv_par08", ""     , "", "", "", "", ""               , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , "" } )
       aAdd( aRegs, { cPerg, "09", "Lista Zerados/Negat 	  ?", "", "", "mv_ch9", "C", 03, 0, 0, "C", "", "mv_par09", "Sim"  , "", "", "", "", "Nใo"            , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , "" } )
       aAdd( aRegs, { cPerg, "10", "Qtd. minima p/Listar	  ?", "", "", "mv_cha", "N", 06, 2, 0, "G", "", "mv_par10", ""     , "", "", "", "", ""               , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , "" } )
       aAdd( aRegs, { cPerg, "11", "Gera Arq. p/ Contab.	  ?", "", "", "mv_chb", "C", 01, 0, 0, "C", "", "mv_par11", "Sim"  , "", "", "", "", "Nใo"            , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , "" } )
       aAdd( aRegs, { cPerg, "12", "Local               	  ?", "", "", "mv_chc", "C", 02, 0, 0, "G", "", "mv_par12", ""     , "", "", "", "", ""               , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "99" , "" } )
       
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
       DbSelectArea(_sAlias)
Return
*/