#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRPCP045 บ Autor ณ Luํs Gustavo       บ Data ณ  21/01/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Programa para emissao do fechamento mensal de producao.    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function BRPCP045()
     //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
     //ณ Declaracao de Variaveis                                             ณ
     //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

     Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2         := "de acordo com os parametros informados pelo usuario."
     Local cDesc3         := "Fechamento Mensal de Produ็ใo"
     //Local cPict          := ""
     Local titulo         := "FECHAMENTO MENSAL DE PRODUCAO"
     Local nLin           := 80

     Local Cabec1         := "    PRODUTO               DESCRICAO            |    REATOR I    CG HORAS  |    REATOR II   CG HORAS  |   REATOR III   CG HORAS  |    REATOR IV   CG HORAS  |  T O T A I S   CG  |"
     Local Cabec2         := ""
     //01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
     //0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21        22
     //    PRODUTO               DESCRICAO            |    REATOR I    CG HORAS  |    REATOR II   CG HORAS  |   REATOR III   CG HORAS  |    REATOR IV   CG HORAS  |  T O T A I S   CG |
     //999999999999999 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX | 9,999,999.9999 99 999:99 | 9,999,999.9999 99 999:99 | 9,999,999.9999 99 999:99 | 9,999,999.9999 99 999:99 | 9,999,999.9999 99 |
     //123456789012345   12345678901234 12 123456   12345678901234 12 123456   12345678901234 12 123456   12345678901234 12 123456   12345678901234 12 |
     //  T O T A I S   | 9,999,999.9999 99 999:99 | 9,999,999.9999 99 999:99 | 9,999,999.9999 99 999:99 | 9,999,999.9999 99 999:99 | 9,999,999.9999 99 |
     //----------------+--------------------------+--------------------------+--------------------------+--------------------------+-------------------+
     // HORAS TOTAIS   |                   999:99 |                   999:99 |                   999:99 |                   999:99 |           9999:99 |
     //----------------+--------------------------+--------------------------+--------------------------+--------------------------+-------------------+
     // OCIOSIDADE     |                   999:99 |                   999:99 |                   999:99 |                   999:99 |           9999:99 |
     //----------------+--------------------------+--------------------------+--------------------------+--------------------------+-------------------+
     //Local imprime        := .T.
     Local aOrd := {}
     Private lEnd         := .F.
     Private lAbortPrint  := .F.
     //Private CbTxt        := ""
     Private limite       := 220
     Private tamanho      := "G"
     Private nomeprog     := "BRPCP045" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo        := 15
     Private aReturn      := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
     Private nLastKey     := 0
     Private cPerg        := "PCP045"
     Private cbtxt        := Space(10)
     Private cbcont       := 00
     Private CONTFL       := 01
     Private m_pag        := 01
     Private wnrel        := "BRPCP045" // Coloque aqui o nome do arquivo usado para impressao em disco

     Private cString      := "SC2"

     If !(cNumEmp == "01010104")
        MSGBOX("Relat๓rio Exclusivo da Filial Brasilux - Resina","Aten็ใo","INFO")
        Return
     Endif

     dbSelectArea("SC2")
     dbSetOrder(1)

     //PCP0452()  //LGS#20200204 - Adequa็ใo de release 12.1.25 e posteriores
     pergunte(cPerg,.F.)

     //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
     //ณ Monta a interface padrao com o usuario...                           ณ
     //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

     wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)

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
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP6 IDE            บ Data ณ  21/01/03   บฑฑ
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
       Local cQuery
       Local nTotRea1 := 0
       Local nTotPro1 := 0
       Local nTotRea2 := 0
       Local nTotPro2 := 0
       Local nTotRea3 := 0
       Local nTotPro3 := 0
       Local nTotRea4 := 0
       Local nTotPro4 := 0
       Local nTotCar1 := 0
       Local nTotCar2 := 0
       Local nTotCar3 := 0
       Local nTotCar4 := 0
       Local nTotHor1 := "000:00"
       Local nTotHor2 := "000:00"
       Local nTotHor3 := "000:00"
       Local nTotHor4 := "000:00"
       Local _i
       Local aProd    := {}
       
       titulo         := titulo + "  -  De: "+Strzero(Day(mv_par01),2)+" de "+Alltrim(MesExtenso(month(mv_par01)))+" de "+StrZero(year(mv_par01),4)+" Ate: "+Strzero(Day(mv_par02),2)+" de "+Alltrim(MesExtenso(month(mv_par02)))+" de "+StrZero(year(mv_par02),4)
       
       cQuery := ""
       cQuery := cQuery + "SELECT B1.B1_COD, B1.B1_DESC "
       cQuery := cQuery + "FROM "+RetSqlName("SB1")+" B1 "
       cQuery := cQuery + "WHERE LEN(B1.B1_COD) = 5 "
       cQuery := cQuery + "  AND B1.D_E_L_E_T_ = '' "
       cQuery := cQuery + "  AND B1.B1_COD BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
       cQuery := cQuery + "ORDER BY B1.B1_COD "

       TCQuery cQuery NEW ALIAS "QSB1"
       
       dbSelectArea("QSB1")
       dbGoTop()
       While !Eof()
             aadd(aProd,{QSB1->B1_COD, Substr(QSB1->B1_DESC,1,30),0,0,"000:00",0,0,"000:00",0,0,"000:00",0,0,"000:00"})
             dbSelectArea("QSB1")
             dbSkip()
       Enddo
       
       dbSelectArea("QSB1")
       dbCloseArea()

       cQuery := ""
       cQuery := cQuery + "SELECT H1.H1_CODIGO AS RECURSO, "
       cQuery := cQuery + "       H1.H1_DESCRI AS DESCRICAO, "
       cQuery := cQuery + "       HB.HB_HRUT+HB.HB_HRUTSAB+HB.HB_HRUTDOM AS HORAS "
       cQuery := cQuery + "FROM "+RetSqlName("SH1")+" H1 "
       cQuery := cQuery + "LEFT JOIN "+RetSqlName("SHB")+" HB ON H1.H1_FILIAL+H1.H1_CTRAB = HB.HB_FILIAL+HB.HB_COD "
       cQuery := cQuery + "WHERE H1.H1_FILIAL = '04' "
       cQuery := cQuery + "  AND H1.D_E_L_E_T_ = '' "
       cQuery := cQuery + "  AND HB.D_E_L_E_T_ = '' "
       
       TCQuery cQuery NEW ALIAS "QSH1"
       
       dbSelectArea("QSH1")
       dbGoTop()
       nConRec := 0
       nSomHor := 0
       While !Eof()
             nConRec := nConRec + 1
             nSomHor := nSomHor + QSH1->HORAS 
             dbSelectArea("QSH1")
             dbSkip()
       Enddo
       nSomHor := PCP0451("0000:00",StrZero(Int((nSomHor / nConRec) * mv_par05),4)+":"+Strzero(((nSomHor / nConRec) * mv_par05) - Int(((nSomHor / nConRec) * mv_par05)),2),"CE" )
       
       dbSelectArea("QSH1")
       dbCloseArea()

       For _i := 1 to len(aProd)
           cQuery := ""
           cQuery := cQuery + "SELECT H6.H6_OP           AS OP, "
           cQuery := cQuery + "       H6.H6_RECURSO      AS RECURSO, "
           cQuery := cQuery + "       H6.H6_OPERAC       AS OPERACAO, "
           cQuery := cQuery + "       SUM(H6.H6_QTDPROD) AS QUANTIDADE, "
           cQuery := cQuery + "       H6.H6_TEMPO        AS TEMPO "
           cQuery := cQuery + "FROM "+RetSqlName("SH6")+" H6 "
           cQuery := cQuery + "WHERE H6.D_E_L_E_T_ = '' "
           cQuery := cQuery + "  AND H6.H6_FILIAL = '04' "
           cQuery := cQuery + "  AND H6.H6_DTPROD BETWEEN '"+dtos(mv_par01)+"' AND '"+dtos(mv_par02)+"' "
           cQuery := cQuery + "  AND H6.H6_PRODUTO = '"+aProd[_i,1]+"' "
           cQuery := cQuery + "GROUP BY H6.H6_OP, H6.H6_RECURSO, H6.H6_OPERAC, H6.H6_TEMPO "

           TCQuery cQuery NEW ALIAS "QSH6"
           
           dbSelectArea("QSH6")
           dbGoTop()
           While !Eof()
                 cOp := QSH6->OP
                 cNu := QSH6->OPERACAO
                 nCo := 0 
                 While !Eof() .and. QSH6->OP == cOP
                       If QSH6->OPERACAO == cNu
                          nCo := nCo + 1
                          If QSH6->RECURSO == '000001'
                             aProd[_i,03] := aProd[_i,03] + QSH6->QUANTIDADE
                             aProd[_i,04] := aProd[_i,04] + nCo
                             aProd[_i,05] := PCP0451(aProd[_i,05],QSH6->TEMPO,"CE")
                          ElseIf QSH6->RECURSO == '000002'
                                 aProd[_i,06] := aProd[_i,06] + QSH6->QUANTIDADE
                                 aProd[_i,07] := aProd[_i,07] + nCo
                                 aProd[_i,08] := PCP0451(aProd[_i,08],QSH6->TEMPO,"CE")
                          ElseIf QSH6->RECURSO == '000003'
                                 aProd[_i,09] := aProd[_i,09] + QSH6->QUANTIDADE
                                 aProd[_i,10] := aProd[_i,10] + nCo
                                 aProd[_i,11] := PCP0451(aProd[_i,11],QSH6->TEMPO,"CE")
                          ElseIf QSH6->RECURSO == '000004'
                                 aProd[_i,12] := aProd[_i,12] + QSH6->QUANTIDADE
                                 aProd[_i,13] := aProd[_i,13] + nCo
                                 aProd[_i,14] := PCP0451(aProd[_i,14],QSH6->TEMPO,"CE")
                          Endif
                       Else
                          If QSH6->RECURSO == '000001'
                             aProd[_i,05] := PCP0451(aProd[_i,05],QSH6->TEMPO,"CE")
                          ElseIf QSH6->RECURSO == '000002'
                                 aProd[_i,08] := PCP0451(aProd[_i,08],QSH6->TEMPO,"CE")
                          ElseIf QSH6->RECURSO == '000003'
                                 aProd[_i,11] := PCP0451(aProd[_i,11],QSH6->TEMPO,"CE")
                          ElseIf QSH6->RECURSO == '000004'
                                 aProd[_i,14] := PCP0451(aProd[_i,14],QSH6->TEMPO,"CE")
                          Endif
                       Endif
                       dbSelectArea("QSH6")
                       dbSkip()
                 Enddo
           Enddo

           dbSelectArea("QSH6")
           dbCloseArea()
       Next
       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

       SetRegua(Len(aProd))

       For _i := 1 to Len(aProd)
           nTotPro1 := 0
           nTotPro2 := 0
           nTotPro3 := 0
           nTotPro4 := 0
           //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
           //ณ Verifica o cancelamento pelo usuario...                             ณ
           //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

           If lAbortPrint
              @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
              Exit
           Endif

           //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
           //ณ Impressao do cabecalho do relatorio. . .                            ณ
           //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

           If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
              Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
              nLin := 8
           Endif
           //01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
           //0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21        22
           //    PRODUTO               DESCRICAO            |    REATOR I    CG HORAS  |    REATOR II   CG HORAS  |   REATOR III   CG HORAS  |    REATOR IV   CG HORAS  |  T O T A I S   CG  |
           //999999999999999 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX | 9,999,999.9999 99 999:99 | 9,999,999.9999 99 999:99 | 9,999,999.9999 99 999:99 | 9,999,999.9999 99 999:99 | 9,999,999.9999 999 |
           //123456789012345 123456789012345678901234567890   12345678901234 12 123456   12345678901234 12 123456   12345678901234 12 123456   12345678901234 12 123456   12345678901234 123 |
           //             T O T A I S ===>>>>>              | 9,999,999.9999 99 999:99 | 9,999,999.9999 99 999:99 | 9,999,999.9999 99 999:99 | 9,999,999.9999 99 999:99 | 9,999,999.9999 999 |
           //-----------------------------------------------+--------------------------+--------------------------+--------------------------+--------------------------+--------------------+
           //HORAS TOTAIS: 9999:99       |       OCIOSIDADE |                   999:99 |                   999:99 |                   999:99 |                   999:99 |
           //-----------------------------------------------+--------------------------+--------------------------+--------------------------+--------------------------+
           //                            |       PROJECAO   | 9,999,999.9999 99        | 9,999,999.9999 99        | 9,999,999.9999 99        | 9,999,999.9999 99        |
           //                            +------------------+--------------------------+--------------------------+--------------------------+--------------------------+
      
           @ nLin,000 PSAY aProd[_i,01] Picture "@R XXX999999999999"
           @ nLin,016 PSAY aProd[_i,02] Picture "@!"
           
           @ nLin,047 PSAY "|"
           @ nLin,049 PSAY aProd[_i,03] Picture "@E 9,999,999.9999"  //REATOR I
           @ nLin,064 PSAY aProd[_i,04] Picture "@E 99"
           @ nLin,067 PSAY aProd[_i,05] Picture "@R 999:99"
           nTotRea1 := nTotRea1 + aProd[_i,03]
           nTotPro1 := nTotPro1 + aProd[_i,03]
           nTotCar1 := nTotCar1 + aProd[_i,04]
           nTotHor1 := PCP0451(nTotHor1,aProd[_i,05],"NO")
           
           @ nLin,074 PSAY "|"
           @ nLin,076 PSAY aProd[_i,06] Picture "@E 9,999,999.9999"  //REATOR II
           @ nLin,091 PSAY aProd[_i,07] Picture "@E 99"
           @ nLin,094 PSAY aProd[_i,08] Picture "@E 999:99"
           nTotRea2 := nTotRea2 + aProd[_i,06]
           nTotPro2 := nTotPro2 + aProd[_i,06]
           nTotCar2 := nTotCar2 + aProd[_i,07]
           nTotHor2 := PCP0451(nTotHor2,aProd[_i,08],"NO")
           
           @ nLin,101 PSAY "|"
           @ nLin,103 PSAY aProd[_i,09] Picture "@E 9,999,999.9999"  //REATOR III
           @ nLin,118 PSAY aProd[_i,10] Picture "@E 99"
           @ nLin,121 PSAY aProd[_i,11] Picture "@E 999:99"
           nTotRea3 := nTotRea3 + aProd[_i,09]
           nTotPro3 := nTotPro3 + aProd[_i,09]
           nTotCar3 := nTotCar3 + aProd[_i,10]
           nTotHor3 := PCP0451(nTotHor3,aProd[_i,11],"NO")
           
           @ nLin,128 PSAY "|"
           @ nLin,130 PSAY aProd[_i,12] Picture "@E 9,999,999.9999"  //REATOR IV
           @ nLin,145 PSAY aProd[_i,13] Picture "@E 99"
           @ nLin,148 PSAY aProd[_i,14] Picture "@E 999:99"
           nTotRea4 := nTotRea4 + aProd[_i,12]
           nTotPro4 := nTotPro4 + aProd[_i,12]
           nTotCar4 := nTotCar4 + aProd[_i,13]
           nTotHor4 := PCP0451(nTotHor4,aProd[_i,14],"NO")
           
           @ nLin,155 PSAY "|"
           @ nLin,157 PSAY (nTotPro1+nTotPro2+nTotPro3+nTotPro4)               Picture "@E 9,999,999.9999"
           @ nLin,172 PSAY aProd[_i,04]+aProd[_i,07]+aProd[_i,10]+aProd[_i,13] Picture "@E 999"
           
           @ nLin,176 PSAY "|"
           nLin := nLin + 1 // Avanca a linha de impressao

       Next
       @ nLin,000 PSAY "-----------------------------------------------+--------------------------+--------------------------+--------------------------+--------------------------+--------------------+"
       nLin := nLin + 1
       @ nLin,000 PSAY "             T O T A I S ===>>>>>              |"
       @ nLin,049 PSAY nTotRea1 Picture "@E 9,999,999.9999"
       @ nLin,064 PSAY nTotCar1 Picture "@E 99"
       @ nLin,067 PSAY nTotHor1 Picture "@R 999:99"
       @ nLin,074 PSAY "|"
       @ nLin,076 PSAY nTotRea2 Picture "@E 9,999,999.9999"
       @ nLin,091 PSAY nTotCar2 Picture "@E 99"
       @ nLin,094 PSAY nTotHor2 Picture "@R 999:99"
       @ nLin,101 PSAY "|"
       @ nLin,103 PSAY nTotRea3 Picture "@E 9,999,999.9999"
       @ nLin,118 PSAY nTotCar3 Picture "@E 99"
       @ nLin,121 PSAY nTotHor3 Picture "@R 999:99"
       @ nLin,128 PSAY "|"
       @ nLin,130 PSAY nTotRea4 Picture "@E 9,999,999.9999"
       @ nLin,145 PSAY nTotCar4 Picture "@E 99"
       @ nLin,148 PSAY nTotHor4 Picture "@R 999:99"
       @ nLin,155 PSAY "|"
       @ nLin,157 PSAY nTotRea1+nTotRea2+nTotRea3+nTotRea4 Picture "@E 9,999,999.9999"
       @ nLin,172 PSAY nTotCar1+nTotCar2+nTotCar3+nTotCar4 Picture "@E 999"
       @ nLin,176 PSAY "|"
       nLin := nLin + 1
       @ nLin,000 PSAY "----------------------------+------------------+--------------------------+--------------------------+--------------------------+--------------------------+--------------------+"
       nOciRea1 := 100 - ( ( (Val(Substr(nTotHor1,1,3))+(Val(SubStr(nTotHor1,5,2))/60)) / (Val(Substr(nSomHor,1,4))+(Val(SubStr(nSomHor,6,2))/60)) ) * 100 )
       nOciRea2 := 100 - ( ( (Val(Substr(nTotHor2,1,3))+(Val(SubStr(nTotHor2,5,2))/60)) / (Val(Substr(nSomHor,1,4))+(Val(SubStr(nSomHor,6,2))/60)) ) * 100 )
       nOciRea3 := 100 - ( ( (Val(Substr(nTotHor3,1,3))+(Val(SubStr(nTotHor3,5,2))/60)) / (Val(Substr(nSomHor,1,4))+(Val(SubStr(nSomHor,6,2))/60)) ) * 100 )
       nOciRea4 := 100 - ( ( (Val(Substr(nTotHor4,1,3))+(Val(SubStr(nTotHor4,5,2))/60)) / (Val(Substr(nSomHor,1,4))+(Val(SubStr(nSomHor,6,2))/60)) ) * 100 )
       nLin := nLin + 1
       @ nLin,000 PSAY "HORAS TOTAIS: "
       @ nLin,014 PSAY nSomHor Picture "@R 9999:99"
       @ nLin,028 PSAY "|       OCIOSIDADE |"
       @ nLin,067 PSAY nOciRea1  Picture "@E 999.99"
       @ nLin,074 PSAY "|"
       @ nLin,094 PSAY nOciRea2  Picture "@E 999.99"
       @ nLin,101 PSAY "|"
       @ nLin,121 PSAY nOciRea3  Picture "@E 999.99"
       @ nLin,128 PSAY "|"
       @ nLin,148 PSAY nOciRea4  Picture "@E 999.99"
       @ nLin,155 PSAY "|"
       nLin := nLin + 1
       @ nLin,000 PSAY "----------------------------+------------------+--------------------------+--------------------------+--------------------------+--------------------------+--------------------+"
       nLin := nLin + 1
       @ nLin,028 PSAY "|       PROJECAO   |"
       @ nLin,049 PSAY Iif(nOciRea1 > 0, (nTotRea1 * 100) / (100 - nOciRea1), 0) Picture "@E 9,999,999.9999"
       @ nLin,064 PSAY Iif(nOciRea1 > 0, (nTotCar1 * 100) / (100 - nOciRea1), 0) Picture "@E 99"
       @ nLin,074 PSAY "|"
       @ nLin,076 PSAY Iif(nOciRea2 > 0, (nTotRea2 * 100) / (100 - nOciRea2), 0) Picture "@E 9,999,999.9999"
       @ nLin,091 PSAY Iif(nOciRea1 > 0, (nTotCar2 * 100) / (100 - nOciRea2), 0) Picture "@E 99"
       @ nLin,101 PSAY "|"
       @ nLin,103 PSAY Iif(nOciRea3 > 0, (nTotRea3 * 100) / (100 - nOciRea3), 0) Picture "@E 9,999,999.9999"
       @ nLin,118 PSAY Iif(nOciRea2 > 0, (nTotCar3 * 100) / (100 - nOciRea3), 0) Picture "@E 99"
       @ nLin,128 PSAY "|"
       @ nLin,130 PSAY Iif(nOciRea4 > 0, (nTotRea4 * 100) / (100 - nOciRea4), 0) Picture "@E 9,999,999.9999"
       @ nLin,145 PSAY Iif(nOciRea2 > 0, (nTotCar4 * 100) / (100 - nOciRea4), 0) Picture "@E 99"
       @ nLin,155 PSAY "|"
       @ nLin,157 PSAY Iif(nOciRea1 > 0, (nTotRea1 * 100) / (100 - nOciRea1), 0) + Iif(nOciRea2 > 0, (nTotRea2 * 100) / (100 - nOciRea2), 0) + Iif(nOciRea3 > 0, (nTotRea3 * 100) / (100 - nOciRea3), 0) + Iif(nOciRea4 > 0, (nTotRea4 * 100) / (100 - nOciRea4), 0) Picture "@E 9,999,999.9999"
       @ nLin,172 PSAY Iif(nOciRea1 > 0, (nTotCar1 * 100) / (100 - nOciRea1), 0) + Iif(nOciRea2 > 0, (nTotCar2 * 100) / (100 - nOciRea2), 0) + Iif(nOciRea3 > 0, (nTotCar3 * 100) / (100 - nOciRea3), 0) + Iif(nOciRea4 > 0, (nTotCar4 * 100) / (100 - nOciRea4), 0) Picture "@E 999"
       @ nLIn,176 PSAY "|"
       nLin := nLin + 1
       @ nLin,028 PSAY "+------------------+--------------------------+--------------------------+--------------------------+--------------------------+--------------------+"
       nLin := nLin + 1
       @ nLin,128 PSAY "|    D I F E R E N C A     |"
       @ nLin,157 PSAY (Iif(nOciRea1 > 0, (nTotRea1 * 100) / (100 - nOciRea1), 0) + Iif(nOciRea2 > 0, (nTotRea2 * 100) / (100 - nOciRea2), 0) + Iif(nOciRea3 > 0, (nTotRea3 * 100) / (100 - nOciRea3), 0) + Iif(nOciRea4 > 0, (nTotRea4 * 100) / (100 - nOciRea4), 0)) - (nTotRea1+nTotRea2+nTotRea3+nTotRea4) Picture "@E 9,999,999.9999"
       @ nLin,172 PSAY (Iif(nOciRea1 > 0, (nTotCar1 * 100) / (100 - nOciRea1), 0) + Iif(nOciRea2 > 0, (nTotCar2 * 100) / (100 - nOciRea2), 0) + Iif(nOciRea3 > 0, (nTotCar3 * 100) / (100 - nOciRea3), 0) + Iif(nOciRea4 > 0, (nTotCar4 * 100) / (100 - nOciRea4), 0)) - (nTotCar1+nTotCar2+nTotCar3+nTotCar4) Picture "@E 999"
       @ nLin,176 PSAY "|"
       nLin := nLin + 1
       @ nLin,128 PSAY "+--------------------------+--------------------+"
       nLin := nLin + 1
       @ nLin,128 PSAY "|    OCIOSIDADE MEDIA      |"
       @ nLin,163 PSAY (nOciRea1+nOciRea2+nOciRea3+nOciRea4) / 4 Picture "@E 999.99"
       @ nLin,176 PSAY "|"
       nLin := nLin + 1
       @ nLin,128 PSAY "+--------------------------+--------------------+"

       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Finaliza a execucao do relatorio...                                 ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
       //01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
       //0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21        22
       //             T O T A I S ===>>>>>              | 9,999,999.9999 99 999:99 | 9,999,999.9999 99 999:99 | 9,999,999.9999 99 999:99 | 9,999,999.9999 99 999:99 | 9,999,999.9999 999 |
       //-----------------------------------------------+--------------------------+--------------------------+--------------------------+--------------------------+--------------------+
       //HORAS TOTAIS: 9999:99       |       OCIOSIDADE |                   999:99 |                   999:99 |                   999:99 |                   999:99 |
       //-----------------------------------------------+--------------------------+--------------------------+--------------------------+--------------------------+--------------------+
       //                            |       PROJECAO   | 9,999,999.9999 99        | 9,999,999.9999 99        | 9,999,999.9999 99        | 9,999,999.9999 99        | 9,999,999.9999 999 |
       //                            +------------------+--------------------------+--------------------------+--------------------------+--------------------------+--------------------+
       //                                                                                                                                |    D I F E R E N C A     | 9,999,999.9999 999 |
       //                                                                                                                                +--------------------------+--------------------+
       //                                                                                                                                |     OCIOSIDADE MEDIA     |       999,99       |
       //                                                                                                                                +--------------------------+--------------------+
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

Return

Static Function PCP0451(cTmpAnt,cTmpNew,cTp)
       Local cRet := ""
       If Len(cTmpAnt) == 7
          cIniHA := 1; cFimHA := 4
          cIniMA := 6; cFimMA := 2
          cTamF  := 4
       Else
          cIniHA := 1; cFimHA := 3
          cIniMA := 5; cFimMA := 2
          cTamF := 3
       Endif
       If Len(cTmpNew) == 7
          cIniHN := 1; cFimHN := 4
          cIniMN := 6; cFimMN := 2
       Else
          cIniHN := 1; cFimHN := 3
          cIniMN := 5; cFimMN := 2
       Endif
       If cTp == "CE"  // Horas Centesimais
          cTmpHor := Strzero(Val(Substr(cTmpAnt,cIniHA,cFimHA))+ Val(Substr(cTmpNew,cIniHN,cFimHN)),cTamF)
          cTmpMin := Strzero(Val(Substr(cTmpAnt,cIniMA,cFimMA))+(Val(Substr(cTmpNew,cIniMN,cFimMN)) * 0.6),3)
          If Val(cTmpMin) >= 60
             While Val(cTmpMin) >= 60
                   cTmpHor := Strzero(Val(Substr(cTmpHor,1,3)) + 01 ,3)
                   cTmpMin := Strzero(Val(cTmpMin) - 60 ,3)
             Enddo
          Endif
       Else  
          cTmpHor := Strzero(Val(Substr(cTmpAnt,cIniHA,cFimHA))+Val(Substr(cTmpNew,cIniHN,cFimHN)),cTamF)
          cTmpMin := Strzero(Val(Substr(cTmpAnt,cIniMA,cFimMA))+Val(Substr(cTmpNew,cIniMN,cFimMN)),3)
          If Val(cTmpMin) >= 60
             While Val(cTmpMin) >= 60
                   cTmpHor := Strzero(Val(Substr(cTmpHor,1,3)) + 01 ,3)
                   cTmpMin := Strzero(Val(cTmpMin) - 60 ,3)
             Enddo
          Endif
       Endif
       cRet := cTmpHor+":"+StrZero(Val(cTmpMin),2)
Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ  PCP0421 บ Autor ณ Fernando Roquete   บ Data ณ  05/06/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Grava perguntas.                                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
//LGS#20200204 - Adequa็ใo de release 12.1.25 e posteriores
/*
Static Function PCP0452()
       Local _sAlias := Alias()
       Local i, j
       DbSelectArea("SX1")
       DbSetOrder(1)
       cPerg := PADR(cPerg,10)
       aRegs := {}

       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       AADD(aRegs,{cPerg,"01","Da Emissao      ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","",""})
       AADD(aRegs,{cPerg,"02","Ate Emissao     ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","",""})
       AADD(aRegs,{cPerg,"03","Do Produto      ?","","","mv_ch3","C",15,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SB1",""})
       AADD(aRegs,{cPerg,"04","Ate Produto     ?","","","mv_ch4","C",15,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SB1",""})
       AADD(aRegs,{cPerg,"05","Total Dias Uteis?","","","mv_ch5","N",02,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""})
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

Return*/