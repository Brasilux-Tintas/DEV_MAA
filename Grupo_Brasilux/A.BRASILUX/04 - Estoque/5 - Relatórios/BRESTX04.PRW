#include "rwmake.ch"
#include "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRESTX04 บ Autor ณ Luํs G. de Souza   บ Data ณ  09/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de produtos em estoque x endere็os.              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Brasilux Tintas T้cnicas Ltda.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function BRESTX04()
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "Saldo de Produtos x Endere็os"
     //Local cPict         := ""
     Local titulo        := "Saldo de Produtos x Endere็os"
     Local nLin          := 80
     Local Cabec1        := "ENDEREวO        CำDIGO          DESCRIวรO                      LC SALDO ATUAL"
     Local Cabec2        := ""
     //Local imprime       := .T.
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     //Private CbTxt       := ""
     Private limite      := 80
     Private tamanho     := "P"
     Private nomeprog    := "BRESTX04" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 18
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := "ESTX04"
     Private cbtxt       := Space(10)
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRESTX04" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString     := "SB2"
     
   if !u_VldAcesso(funname())
      MsgBox("Acesso nใo autorizado!---->"+funname(),"Aten็ใo","Alert")
      return 
  endif 
     u_zcfga01( 'BRESTX04' ) //LGS#2021118 - Grava็ใo de log de utiliza็ใo da rotina
     dbSelectArea("SB2")
     dbSetOrder(1)
     //VldPerg()  //LGS#20200130 - Adequa็ใo a release 12.1.25 
     Pergunte(cPerg,.F.)

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

     nTipo := If(aReturn[4]==1,15,18)

     //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
     //ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
     //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

     RptStatus({|| ESTX04_1(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ ESTX04_1 บ Autor ณ Luํs G. de Souza   บ Data ณ  09/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ESTX04_1(Cabec1,Cabec2,Titulo,nLin)
       //Local nOrdem
       Local cQry1 := ""
       dbSelectArea(cString)
       dbSetOrder(1)

       SetRegua(RecCount())
       If mv_par12 == 2
          	cQry1 := ""
          	cQry1 += "SELECT MAX(SB2.B2_LOCALIZ) AS B2_LOCALIZ, SB2.B2_COD, MAX(SB1.B1_DESC) AS B1_DESC, SUM(SB2.B2_QATU) AS B2_QATU "
          	cQry1 += "FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) "
          	cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON SB2.B2_FILIAL = SB1.B1_FILIAL AND SB2.B2_COD = SB1.B1_COD AND SB1.D_E_L_E_T_ = '' "
          	cQry1 += "WHERE SB2.B2_FILIAL = '"+xFilial("SB2")+"' "
          	cQry1 += "  AND SB2.D_E_L_E_T_ = ''
          	cQry1 += "  AND SB2.B2_COD   BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
          	cQry1 += "  AND SB2.B2_LOCAL BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
          	cQry1 += "  AND SB1.B1_TIPO  BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' "
          	cQry1 += "  AND SB1.B1_GRUPO BETWEEN '"+mv_par07+"' AND '"+mv_par08+"' "
          	cQry1 += "GROUP BY SB2.B2_COD "
          	If mv_par09 == 2
             	cQry1 += "HAVING SUM(SB2.B2_QATU) <> 0.0 "
          	Endif
			IF mv_par10 == 2
				cQry1 += iif("HAVING " $ cQry1,"AND ","HAVING ")
          		cQry1 += "(MAX(SB2.B2_LOCALIZ) > '') "
    		endif 
          	If mv_par11 == 1
             	cQry1 += "ORDER BY B2_COD "
          	ElseIf mv_par11 == 2
           		cQry1 += "ORDER BY B1_DESC,B2_COD "
          	ElseIf mv_par11 == 3
           		cQry1 += "ORDER BY B2_LOCALIZ,B2_COD "
          	Endif
       Else
          	cQry1 := ""
          	cQry1 += "SELECT SB2.B2_COD, SB1.B1_DESC, SB2.B2_LOCAL, SB2.B2_LOCALIZ, SB2.B2_QATU "
          	cQry1 += "FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) "
          	cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON SB2.B2_FILIAL = SB1.B1_FILIAL AND SB2.B2_COD = SB1.B1_COD AND SB1.D_E_L_E_T_ = '' "
          	cQry1 += "WHERE SB2.B2_FILIAL = '"+xFilial("SB2")+"' "
          	cQry1 += "  AND SB2.D_E_L_E_T_ = ''
          	cQry1 += "  AND SB2.B2_COD   BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
          	cQry1 += "  AND SB2.B2_LOCAL BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
          	cQry1 += "  AND SB1.B1_TIPO  BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' "
          	cQry1 += "  AND SB1.B1_GRUPO BETWEEN '"+mv_par07+"' AND '"+mv_par08+"' "
			If mv_par09 == 2
    	         cQry1 += "  AND SB2.B2_QATU <> 0.0 "
          	Endif
          	If mv_par10 == 2
             	cQry1 += "  AND SB2.B2_LOCALIZ <> '' "
          	Endif
          	If mv_par11 == 1
             	cQry1 += "ORDER BY B2_COD, B2_LOCAL "
          	ElseIf mv_par11 == 2
                 cQry1 += "ORDER BY SB1.B1_DESC,B2_COD,B2_LOCAL "
          	ElseIf mv_par11 == 3
                 cQry1 += "ORDER BY B2_LOCALIZ,B2_COD,B2_LOCAL "
          	Endif
       Endif
       TCQuery cQry1 ALIAS "TCQ" NEW
       
       DbSelectArea("TCQ")
       DbGoTop()
       While !EOF()
             If lAbortPrint
                @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
                Exit
             Endif
             If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
                Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                nLin := 8
             Endif
             If mv_par12 == 2
                @ nLin, 000 PSAY TCQ->B2_LOCALIZ Picture "@!"
                @ nLin, 016 PSAY TCQ->B2_COD     Picture "@R XX 99.99.999-99"
                @ nLin, 032 PSAY TCQ->B1_DESC    Picture "@!"
                @ nLin, 063 PSAY "**"            Picture "@!"
                @ nLin, 066 PSAY TCQ->B2_QATU    Picture "@E 9,999,999.9999"
                nLin    += 1 // Avanca a linha de impressao
                DbSkip()
             Else
                cCodPro := TCQ->B2_COD
                nQtdPro := 0
                nSomPro := 0
                While !Eof() .and. TCQ->B2_COD == cCodPro
                      @ nLin, 000 PSAY TCQ->B2_LOCALIZ Picture "@!"
                      @ nLin, 016 PSAY TCQ->B2_COD     Picture "@R XX 99.99.999-99"
                      @ nLin, 032 PSAY TCQ->B1_DESC    Picture "@!"
                      @ nLin, 063 PSAY TCQ->B2_LOCAL   Picture "@!"
                      @ nLin, 066 PSAY TCQ->B2_QATU    Picture "@E 9,999,999.9999"
                        nLin    += 1 // Avanca a linha de impressao
                        nSomPro += TCQ->B2_QATU
                        nQtdPro += 1
                      DbSkip()
                EndDo
                If nQtdPro > 1
                   @ nLin, 032 PSAY "Total do Produto: "+Transform(cCodPro, "@R XX 99.99.999-99")
                   @ nLin, 066 PSAY nSomPro              Picture "@E 9,999,999.9999"
                   nLin += 2
                Endif
             Endif
       EndDo
       DbSelectArea("TCQ")
       DbCloseArea()
       
       SET DEVICE TO SCREEN

       If aReturn[5]==1
          dbCommitAll()
          SET PRINTER TO
          OurSpool(wnrel)
       Endif

       MS_FLUSH()
Return

/***********************************************************************************/
/*** VLDPERG - Verifica e monta parโmetros SX1.                                  ***/
/***********************************************************************************/
//LGS#20200130 - Adequa็ใo a release 12.1.25
/*
Static Function VldPerg()
       Local aHelp1 := {}; Local aHelp2 := {}; Local aHelp3 := {}; Local aHelp4 := {}; Local aHelp5 := {}; Local aHelp6 := {}; Local aHelp7 := {}; Local aHelp8 := {}
       aAdd( aHelp1, "Informe o c๓digo do produto.     " )
       aAdd( aHelp2, "Informe o armazem do produto.    " )
       aAdd( aHelp3, "Informe o tipo do produto.       " )
       aAdd( aHelp4, "Informe o grupo do produto.      " )
       aAdd( aHelp5, "Lista itens zerados ? Sim ou Nใo?" )
       aAdd( aHelp6, "'Lista Prod. S/Endere็o?'        " )
       aAdd( aHelp7, "Selecione a ordem do relat๓rio:  " )
       aAdd( aHelp7, "C๓digo / Descri็ใo / Endere็o    " )
       aAdd( aHelp8, "Selecione entre analitico e sint้tico" ) 
       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Inclui parametros de consulta                                                  ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
       //     1        / 2        / 3          / 4         / 5         / 6          / 7       / 8          / 9          / 10        / 11     / 12       / 13    / 14        / 15      / 16       / 17       / 18         / 19         / 20       / 21       / 22       / 23
       //     X1_GRUPO / X1_ORDEM / X1_PERGUNT / X1_PERSPA / X1_PERENG / X1_VARIAVL / X1_TIPO / X1_TAMANHO / X1_DECIMAL / X1_PRESEL / X1_GSC / X1_VALID / X1_F3 / X1_GRPSXG / X1_PYME / X1_VAR01 / X1_DEF01 / X1_DEFSPA1 / X1_DEFENG1 / X1_CNT01 / X1_VAR02 / X1_DEF02 / X1_DEFSPA2 / X1_DEFENG2 / X1_CNT02 / X1_VAR03 / X1_DEF03 / X1_DEFSPA3 / X1_DEFENG3 / X1_CNT03 / X1_VAR04 / X1_DEF04 / X1_DEFSPA4 / X1_DEFENG4 / X1_CNT04 / X1_VAR05 / X1_DEF05 / X1_DEFSPA5 / X1_DEFENG5 / X1_CNT05 / X1_HELP
       //     1         2     3                          4   5   6         7    8   9  10 11   12   13     14   15   16          17        18   19   20   21           22    23  24   25
       PutSX1("ESTX04    ", "01", "Do Produto             ", "", "", "mv_ch1", "C", 15, 0, 0, "G", " ", "SB1", " ", " ", "mv_par01", "         ", " ", " ", " ", "         ", " ", " ", "        ", " ", Nil, Nil, Nil, Nil, Nil, Nil, Nil, aHelp1, Nil, Nil )
       PutSX1("ESTX04    ", "02", "At้ Produto            ", "", "", "mv_ch2", "C", 15, 0, 0, "G", " ", "SB1", " ", " ", "mv_par02", "         ", " ", " ", " ", "         ", " ", " ", "        ", " ", Nil, Nil, Nil, Nil, Nil, Nil, Nil, aHelp1, Nil, Nil )
       PutSX1("ESTX04    ", "03", "Do Local               ", "", "", "mv_ch3", "C", 02, 0, 0, "G", " ", "X99", " ", " ", "mv_par03", "         ", " ", " ", " ", "         ", " ", " ", "        ", " ", Nil, Nil, Nil, Nil, Nil, Nil, Nil, aHelp2, Nil, Nil )
       PutSX1("ESTX04    ", "04", "At้ Local              ", "", "", "mv_ch4", "C", 02, 0, 0, "G", " ", "X99", " ", " ", "mv_par04", "         ", " ", " ", " ", "         ", " ", " ", "        ", " ", Nil, Nil, Nil, Nil, Nil, Nil, Nil, aHelp2, Nil, Nil )
       PutSX1("ESTX04    ", "05", "Do Tipo                ", "", "", "mv_ch5", "C", 02, 0, 0, "G", " ", "X02", " ", " ", "mv_par05", "         ", " ", " ", " ", "         ", " ", " ", "        ", " ", Nil, Nil, Nil, Nil, Nil, Nil, Nil, aHelp3, Nil, Nil )
       PutSX1("ESTX04    ", "06", "At้ Tipo               ", "", "", "mv_ch6", "C", 02, 0, 0, "G", " ", "X02", " ", " ", "mv_par06", "         ", " ", " ", " ", "         ", " ", " ", "        ", " ", Nil, Nil, Nil, Nil, Nil, Nil, Nil, aHelp3, Nil, Nil )
       PutSX1("ESTX04    ", "07", "Do Grupo               ", "", "", "mv_ch7", "C", 04, 0, 0, "G", " ", "SBM", " ", " ", "mv_par07", "         ", " ", " ", " ", "         ", " ", " ", "        ", " ", Nil, Nil, Nil, Nil, Nil, Nil, Nil, aHelp4, Nil, Nil )
       PutSX1("ESTX04    ", "08", "At้ Grupo              ", "", "", "mv_ch8", "C", 04, 0, 0, "G", " ", "SBM", " ", " ", "mv_par08", "         ", " ", " ", " ", "         ", " ", " ", "        ", " ", Nil, Nil, Nil, Nil, Nil, Nil, Nil, aHelp4, Nil, Nil )
       PutSX1("ESTX04    ", "09", "Lista Saldo Zerado?    ", "", "", "mv_ch9", "N", 01, 0, 0, "C", " ", "   ", " ", " ", "mv_par09", "Sim      ", " ", " ", " ", "Nใo      ", " ", " ", "        ", " ", Nil, Nil, Nil, Nil, Nil, Nil, Nil, aHelp5, Nil, Nil )
       PutSX1("ESTX04    ", "10", "Lista Prod. S/Endere็o?", "", "", "mv_cha", "N", 01, 0, 0, "C", " ", "   ", " ", " ", "mv_par10", "Sim      ", " ", " ", " ", "Nใo      ", " ", " ", "        ", " ", Nil, Nil, Nil, Nil, Nil, Nil, Nil, aHelp6, Nil, Nil )
       PutSX1("ESTX04    ", "11", "Ordem do Relat๓rio?    ", "", "", "mv_chb", "N", 01, 0, 0, "C", " ", "   ", " ", " ", "mv_par11", "C๓digo   ", " ", " ", " ", "Descri็ใo", " ", " ", "Endere็o", " ", Nil, Nil, Nil, Nil, Nil, Nil, Nil, aHelp7, Nil, Nil )
       PutSX1("ESTX04    ", "12", "Analํtico / Sint้tico? ", "", "", "mv_chc", "N", 01, 0, 0, "C", " ", "   ", " ", " ", "mv_par12", "Analํtico", " ", " ", " ", "Sint้tico", " ", " ", "        ", " ", Nil, Nil, Nil, Nil, Nil, Nil, Nil, aHelp6, Nil, Nil )
Return
*/
//0         1         2         3         4         5         6         7         8         9         10        11
//012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//ENDEREวO        CำDIGO          DESCRIวรO                      LC SALDO ATUAL
//XXXXXXXXXXXXXXX XX 99.99.999-99 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XX 9,999,999.9999
//                                Total do produto: XX 99.99.999-99 9,999,999.9999
