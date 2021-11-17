#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRCOM009 บ Autor ณ Luํs Gustavo       บ Data ณ  04/02/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relat๓rio de Ranking de Consumo de Materias primas.        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function BRCOM009()
     Local cDesc1 := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2 := "de acordo com os parametros informados pelo usuario."
     Local cDesc3 := "Raking de Consumo de Produtos (Valores R$)"
     //Local cPict  := ""
     Local titulo := "Raking de Consumo de Produtos (Valores R$)"
     Local nLin   := 132
     Local Cabec1        := "PRODUTO           DESCRICAO                        CONSUMO              ULTIMO       VALORES EM R$             RANKING"
     Local Cabec2        := "                                                                        PREวO      "
     //Local imprime       := .T.
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     //Private CbTxt       := ""
     Private limite      := 132
     Private tamanho     := "M"
     Private nomeprog    := "BRCOM009" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 18
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := padr("COM009",10)
     Private cbtxt       := Space(10)
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRCOM009" // Coloque aqui o nome do arquivo usado para impressao em disco

     Private cString     := "ZZ3"

    if !u_VldAcesso(funname())
      MsgBox("Acesso nใo autorizado!---->"+funname(),"Aten็ใo","Alert")
      return 
  endif 

   
     dbSelectArea("ZZ3")
     dbSetOrder(1)

     VldPerg()
     pergunte(cPerg,.F.)

     wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

     If nLastKey == 27
        Return
     Endif

     SetDefault(aReturn,cString)

     If nLastKey == 27
        Return
     Endif

     nTipo := If(aReturn[4]==1,15,18)

     RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP6 IDE            บ Data ณ  04/02/04   บฑฑ
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
       //Local nOrdem
       Local cQuery := ""
       
       cQuery := "" 
       cQuery += "SELECT ZZ3.ZZ3_COD AS CODIGO, "
       If MV_PAR03 == 1
          cQuery += "       ZZ3.ZZ3_Q01 + ZZ3.ZZ3_Q02 + ZZ3.ZZ3_Q03 + ZZ3.ZZ3_Q04 + ZZ3.ZZ3_Q05 + ZZ3.ZZ3_Q06 + ZZ3.ZZ3_Q07 + ZZ3.ZZ3_Q08 + ZZ3.ZZ3_Q09 + ZZ3.ZZ3_Q10 + ZZ3.ZZ3_Q11 + ZZ3.ZZ3_Q12 AS QUANTIDADE, "
          cQuery += "       ((ZZ3.ZZ3_Q01 + ZZ3.ZZ3_Q02 + ZZ3.ZZ3_Q03 + ZZ3.ZZ3_Q04 + ZZ3.ZZ3_Q05 + ZZ3.ZZ3_Q06 + ZZ3.ZZ3_Q07 + ZZ3.ZZ3_Q08 + ZZ3.ZZ3_Q09 + ZZ3.ZZ3_Q10 + ZZ3.ZZ3_Q11 + ZZ3.ZZ3_Q12) * SB1.B1_UPRC) AS TOTAL, "
       Else
          cQuery += "       ZZ3.ZZ3_Q"+StrZero((mv_par04),2)+ " AS QUANTIDADE, "
          cQuery += "       (ZZ3.ZZ3_Q"+StrZero(mv_par04,2)+ " * SB1.B1_UPRC) AS TOTAL, "
       Endif
       cQuery += "       SB1.B1_UPRC AS PRECO "
       cQuery += "FROM "+RetSqlName("ZZ3")+" ZZ3 WITH (NOLOCK) "
       cQuery += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.B1_FILIAL = '"+xFilial("SB1")+"') AND ZZ3.ZZ3_COD = SB1.B1_COD AND (SB1.D_E_L_E_T_ = '') "
       cQuery += "WHERE (ZZ3.D_E_L_E_T_ <> '*') AND (ZZ3.ZZ3_FILIAL = '"+xFilial("ZZ3")+"') "
       cQuery += "AND (ZZ3.ZZ3_COD BETWEEN '"+alltrim(MV_PAR01)+"' AND '"+ALLTRIM(MV_PAR02)+"') "
       cQuery += "AND (ZZ3.ZZ3_ANO = '"+mv_par05+"') "
       cQuery += "AND (ZZ3.ZZ3_FILIAL = '"+xFilial("ZZ3")+"') "
       cQuery += "AND (SB1.B1_TIPO = 'MP') "
       cQuery += "ORDER BY TOTAL DESC "
       TCQUERY cQuery ALIAS "TCQ" NEW
       
       DbSelectArea(cString)
       DbSetOrder(1)

       SetRegua(RecCount())

       dbGoTop()
       nCont  := 1
       nTotal := 0
       While !EOF()
             If lAbortPrint
                @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
                Exit
             Endif

             If nLin > 60 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
                nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                nLin++
             Endif
             //0         1         2         3         4         5         6         7         8         9         10        11        12        13
             //0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
             //PRODUTO          DESCRICAO                       CONSUMO             ULTIMO      VALORES EM R$          RANKING
             //                                                                     PREวO      
             //999999999999999  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999,999,999,999.99  999,999.99  999,999,999,999,999.99  99999   999999-XXXXXXXXXXXX
             cCodigo := ""
             cCodigo := U_fBusUlFo(TCQ->CODIGO)
             If mv_par06 == 1
                If SubString(cCodigo,1,6) $ '00401 .00354 .00305 '
                   DbSelectArea("TCQ")
                   DbSkip()
                   Loop
                Endif
             Endif
             If mv_par07 == 1
                If TCQ->QUANTIDADE <= 0
                   DbSelectArea("TCQ")
                   DbSkip()
                   Loop
                Endif
             Endif
             @nLin,000 PSAY TCQ->CODIGO
             @nLin,017 PSAY Posicione("SB1", 1, xFilial("SB1")+TCQ->CODIGO, "B1_DESC") PICTURE "@!"
             @nLin,049 PSAY TCQ->QUANTIDADE                                            PICTURE "@E 999,999,999,999.99"
             @nLin,069 PSAY TCQ->PRECO                                                 PICTURE "@E 999,999.99"
             @nLin,081 PSAY TCQ->TOTAL                                                 PICTURE "@E 999,999,999,999,999.99"
             @nLin,105 PSAY nCont                                                      PICTURE "@E 99999"
             @nLin,113 PSAY cCodigo                                                    PICTURE "@!"
             nLin   := nLin + 1 // Avanca a linha de impressao
             nCont  := nCont + 1
             nTotal += TCQ->TOTAL
             IncProc()
             DbSelectArea("TCQ")
             dbSkip() // Avanca o ponteiro do registro no arquivo
       EndDo
       If nLin > 60 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
          nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
          nLin++
       Endif
       @nLin,000 PSAY Replicate("-",132)
        nLin++
       @nLin,081 PSAY nTOTAL                                                 PICTURE "@E 999,999,999,999,999.99"
       nLin++
       @nLin,000 PSAY ""
       
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

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ VldPerg  บ Autor ณ AP5 IDE            บ Data ณ  17/09/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Verifica a existencia das perguntas criando-as caso seja   บฑฑ
ฑฑบ          ณ necessario (caso nao existam).                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function VldPerg()
       Local i, j
       _sAlias := Alias()
       DbSelectArea("SX1")
       DbSetOrder(1)
       cPerg := PADR(cPerg,10)
       aRegs := {}

       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       AADD(aRegs,{cPerg,"01","Do produto            ?","","","mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SB1","",""})
       AADD(aRegs,{cPerg,"02","Ate o produto         ?","","","mv_ch2","C",15,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SB1",""})
       AADD(aRegs,{cPerg,"03","Acumulado / Mensal    ?","","","mv_ch3","N",01,0,0,"C","","mv_par03","Acumulado"     ,"","","","","Mensal","","","","","","","","","","","","","","","","","","","",""})
       AADD(aRegs,{cPerg,"04","Periodo de            ?","","","mv_ch4","N",02,0,0,"G","","mv_par04",""              ,"","","","","","","","","","","","","","","","","","","","","","","","",""})
       AADD(aRegs,{cPerg,"05","Periodo ate           ?","","","mv_ch5","C",04,0,0,"G","","mv_par05",""              ,"","","","","","","","","","","","","","","","","","","","","","","","",""})
       AADD(aRegs,{cPerg,"06","Filtra Forn. Brasilux ?","","","mv_ch6","N",01,0,0,"C","","mv_par06","Sim"           ,"","","","","Nao","","","","","","","","","","","","","","","","","","","",""})
       AADD(aRegs,{cPerg,"07","Filtra Itens Zerados  ?","","","mv_ch7","N",01,0,0,"C","","mv_par07","Sim"           ,"","","","","Nao","","","","","","","","","","","","","","","","","","","",""})
       For i := 1 to Len(aRegs)
           If !dbSeek(cPerg+aRegs[i,2])
              RecLock("SX1",.T.)
              For j := 1 to FCount()
                  If j <= Len(aRegs[i])
                     FieldPut(j,aRegs[i,j])
                  Endif
              Next
              MsUnlock()
           Endif
       Next     
       DbSelectArea(_sAlias)
Return

User Function fBusUlFo(cProd)
     Local cQry1 := ""
     Local xRet  := ""
     
     cQry1 := ""
     cQry1 += "SELECT TOP 1 * "
     cQry1 += "FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK) "
     cQry1 += "WHERE SD1.D_E_L_E_T_ = '' "
     cQry1 += "  AND SD1.D1_FILIAL  = '"+xFilial("SD1")+"' "
     cQry1 += "  AND SD1.D1_COD     = '"+cProd+"' "
     cQry1 += "ORDER BY SD1.D1_EMISSAO DESC "
     TCQUERY cQry1 ALIAS "XFOR" NEW
     
     DbSelectArea("XFOR")
     DbGoTop()
     xRet := XFOR->D1_FORNECE+"-"+SubStr(Posicione("SA2", 1, xFilial("SA2")+XFOR->D1_FORNECE, "A2_NREDUZ"), 1, 12)
     DbSelectArea("XFOR")
     DbCloseArea()
Return(xRet)