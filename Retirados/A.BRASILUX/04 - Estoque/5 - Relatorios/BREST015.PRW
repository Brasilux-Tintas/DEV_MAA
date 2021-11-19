#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BREST015 บ Autor ณ Luํs Gusatvo de Souza บ Data ณ  05/02/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Codigo gerado pelo AP6 IDE para emissใo de relat๓rio de dife -บฑฑ
ฑฑบ          ณ ren็as de inventแrio e saldos em determinada data.            บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function BREST015()
     //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
     //ณ Declaracao de Variaveis                                             ณ
     //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "Compara็ใo entre Saldos e Inventแrio"
     Local cPict         := ""
     Local titulo        := "Compara็ใo entre Saldos e Inventแrio"
     Local nLin          := 80
     //01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
     //0         1         2         3         4         5         6         7         8         9         10        11        12        13
     //CODIGO           DESCRICAO                                 LC  SALDO             INVENTARIO        DIFERENCA         DOCUMENTO
     //999999999999999  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  99  999,999,999.9999  999,999,999.9999  999,999,999.9999  999999
     Local Cabec1        := "CODIGO           DESCRICAO                                 LC  SALDO "
     Local cCabecAux     := "INVENTARIO        DIFERENCA         DOCUMENTO"
     Local Cabec2        := ""
     Local imprime       := .T.
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     Private CbTxt       := ""
     Private limite      := 132
     Private tamanho     := "M"
     Private nomeprog    := "BREST015" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 18
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := "EST151"
     Private cbtxt       := Space(10)
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BREST015" // Coloque aqui o nome do arquivo usado para impressao em disco

     Private cString     := "SB7"

     dbSelectArea("SB7")
     dbSetOrder(1)

     ValPerg1()
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

     RptStatus({|| EST0151(Cabec1,Cabec2,Titulo,nLin,cCabecAux) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ EST0151  บ Autor ณ Luํs Gustavo       บ Data ณ  05/02/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function EST0151(Cabec1,Cabec2,Titulo,nLin,cCabecAux)

       Local nOrdem
       Local nTotQtd := 0
       Local nTotInv := 0
       Local nTotDif := 0

       If mv_par07 == 1
          Cabec1 := Cabec1 + "ATUAL       " + cCabecAux
       ElseIf mv_par07 == 2
              Cabec1 := Cabec1 + "FECHAMENTO  " + cCabecAux
       Else
          Cabec1 := Cabec1 + "MOVIMENTO   " + cCabecAux
       Endif
       
       dbSelectArea(cString)
       dbSetOrder(1)
       dbSeek(xFilial("SB7")+Dtos(mv_par08),.t.)
       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

       SetRegua(RecCount())
       While !EOF() .and. SB7->B7_DATA == mv_par08
             If SB7->B7_COD   >= mv_par01 .and. SB7->B7_COD   <= mv_par02 .and.;
                SB7->B7_LOCAL >= mv_par03 .and. SB7->B7_LOCAL <= mv_par04 .and.;
                SB7->B7_TIPO  >= mv_par05 .and. SB7->B7_TIPO  <= mv_par06
             Else
                DbSkip()
                Loop
             Endif
             
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
                nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                nLin := nLin + 1
             Endif
             DbSelectArea("SB1")
             DbSetOrder(1)
             DbSeek(xFilial("SB1")+SB7->B7_COD,.t.)
             //01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
             //0         1         2         3         4         5         6         7         8         9         10        11        12        13
             //CODIGO           DESCRICAO                                 LC  SALDO             INVENTARIO        DIFERENCA         DOCUMENTO
             //                                        T O T A L ===>>>>>>>>
             nQuant  := 0
             nInvent := 0
             @nLin,000 PSAY SB1->B1_COD
             @nLin,017 PSAY SubString(SB1->B1_DESC,1,40)
             @nLin,059 PSAY SB7->B7_LOCAL
             //@nLin,063 PSAY nQuant                  Picture "@E 999,999,999.9999"
             @nLin,081 PSAY SB7->B7_QUANT           Picture "@E 999,999,999.9999"
             //@nLin,099 PSAY nQuant - SB7->B7_QUANT  Picture "@E 999,999,999.9999"
             @nLin,117 PSAY SB7->B7_DOC
             //nTotQtd := nTotQtd + nQuant
             nTotInv := nTotInv + SB7->B7_QUANT
             //nTotDif := nTotDif + (nQuant - SB7->B7_QUANT)
             nLin := nLin + 1 // Avanca a linha de impressao
             
             cCodAnt := SB7->B7_COD
             cLocAnt := SB7->B7_LOCAL
             dDatAnt := mv_par08
             dbSelectArea("SB7")
             dbSkip() // Avanca o ponteiro do registro no arquivo
             If SB7->B7_COD <> cCodAnt
                Do Case
                   Case (mv_par07 == 1)
                        DbSelectArea("SB2")
                        DbSetOrder(1)
                        DbSeek(xFilial("SB2")+cCodAnt+cLocAnt,.t.)
                        If Found()
                           nQuant := SB2->B2_QATU
                        Else
                           nQuant := 0
                        Endif
                   Case (mv_par07 == 2)
                        DbSelectArea("SB2")
                        DbSetOrder(1)
                        DbSeek(xFilial("SB2")+cCodAnt+cLocAnt,.t.)
                        If Found()
                           nQuant := SB2->B2_QFIM
                        Else
                           nQuant := 0
                        Endif
                   OtherWise
                        nQuant := CalcEst( cCodAnt,cLocAnt,mv_par09+1,xFilial("SB7") )[1]
                EndCase

                @ nLin,000 PSAY Replicate("-",132)
                nLin := nLin + 1
                @ nLin,040 PSAY "T O T A L ===>>>>>>>>"
                @nLin,063 PSAY nQuant Picture "@E 999,999,999.9999"
                @nLin,081 PSAY nTotInv Picture "@E 999,999,999.9999"
                @nLin,099 PSAY nTotInv - nQuant Picture "@E 999,999,999.9999"
                nLin := nLin + 2
                nTotQtd := 0
                nTotInv := 0
                nTotDif := 0 
             Else
                If SB7->B7_COD == cCodAnt .and. SB7->B7_LOCAL <> cLocAnt
                   Do Case
                      Case (mv_par07 == 1)
                           DbSelectArea("SB2")
                           DbSetOrder(1)
                           DbSeek(xFilial("SB2")+cCodAnt+cLocAnt,.t.)
                           If Found()
                              nQuant := SB2->B2_QATU
                           Else
                              nQuant := 0
                           Endif
                      Case (mv_par07 == 2)
                           DbSelectArea("SB2")
                           DbSetOrder(1)
                           DbSeek(xFilial("SB2")+cCodAnt+cLocAnt,.t.)
                           If Found()
                              nQuant := SB2->B2_QFIM
                           Else
                              nQuant := 0
                           Endif
                      OtherWise
                           nQuant := CalcEst( cCodAnt,cLocAnt,mv_par09+1,xFilial("SB7") )[1]
                   EndCase
                   @ nLin,000 PSAY Replicate("-",132)
                   nLin := nLin + 1
                   @ nLin,040 PSAY "T O T A L ===>>>>>>>>"
                   @nLin,063 PSAY nQuant Picture "@E 999,999,999.9999"
                   @nLin,081 PSAY nTotInv Picture "@E 999,999,999.9999"
                   @nLin,099 PSAY nTotInv - nQuant Picture "@E 999,999,999.9999"
                   nLin := nLin + 2
                   nTotQtd := 0
                   nTotInv := 0
                   nTotDif := 0 
                Endif
             Endif
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

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ VALPERG1 บ Autor ณ AP5 IDE            บ Data ณ  17/09/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Verifica a existencia das perguntas criando-as caso seja   บฑฑ
ฑฑบ          ณ necessario (caso nao existam).                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ValPerg1()
       Local _sAlias := Alias()
       Local aRegs := {}
       Local i,j

       dbSelectArea("SX1")
       dbSetOrder(1)
       cPerg := PADR(cPerg,10)
       
       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs,{cPerg,"01","Do produto          ","","","mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SB1",""})
       aAdd(aRegs,{cPerg,"02","Ate o produto       ","","","mv_ch2","C",15,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SB1",""})
       aAdd(aRegs,{cPerg,"03","Do local            ","","","mv_ch3","C",02,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","99",""})
       aAdd(aRegs,{cPerg,"04","Ate o local         ","","","mv_ch4","C",02,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","99",""})
       aAdd(aRegs,{cPerg,"05","Do tipo             ","","","mv_ch5","C",02,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","02",""})
       aAdd(aRegs,{cPerg,"06","Ate o tipo          ","","","mv_ch6","C",02,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","02",""})
       aAdd(aRegs,{cPerg,"07","Saldo a Considerar  ","","","mv_ch7","N",01,0,0,"C","","mv_par07","Atual","","","","","Fechamento","","","","","Movimento","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg,"08","Data do Inventแrio  ","","","mv_ch8","D",08,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg,"09","Data do Saldo       ","","","mv_ch9","D",08,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","",""})       
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