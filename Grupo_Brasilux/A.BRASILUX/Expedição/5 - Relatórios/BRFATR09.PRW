#include 'rwmake.ch'
#include 'topconn.ch'
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRFATR09 บ Autor ณ Luํs G. de Souza   บ Data ณ  26/01/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rela็ใo de expedi็ใo para retirada do estoque e/ou montagemบฑฑ
ฑฑบ          ณ de carga.                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX TINTAS TษCNICAS LTDA.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function BRFATR09()
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "Expedi็ใo"
     //Local cPict         := ""
     Local titulo        := "Expedi็ใo - "
     Local nLin          := 80
     Local Cabec1        := "PRODUTO         DESCRIวรO                      QTDE.  VOLUME % Ret."
     Local Cabec2        := ""
     //Local imprime       := .T.
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     //Private CbTxt       := ""
     Private limite      := 80
     Private tamanho     := "P"
     Private nomeprog    := "BRFATR09" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 18
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := "FATR09"
     Private cbtxt       := Space(10)
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRFATR09" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString     := "ZZC"

     DbSelectArea("ZZC")
     DbSetOrder(1)

     //fVldPer()  //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
     Pergunte(cPerg,.F.)

     wnrel := SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho, , .F.)

     If nLastKey == 27
        Return
     Endif

     SetDefault(aReturn,cString)

     If nLastKey == 27
        Return
     Endif

     nTipo := If(aReturn[4]== 1, 15, 18)

     Processa({|| FATR09_1(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ FATR09_1 บ Autor ณ Luํs G. de Souza   บ Data ณ  26/01/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FATR09_1(Cabec1, Cabec2, Titulo, nLin)
       //Local nOrdem
       Local cQry1 := ""
       
       If mv_par03 == 1 //Regi๕es
          cQry1 := ""
          //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
          //cQry1 += "SELECT SX5.X5_CHAVE, SX5.X5_DESCRI "
          cQry1 += "SELECT SX5.X5_CHAVE AS X5CHAVE, SX5.X5_DESCRI AS X5DESCRI "
          cQry1 += "FROM "+RetSqlName("SX5")+" SX5 "
          cQry1 += "WHERE SX5.X5_FILIAL = '' "
          cQry1 += "  AND SX5.X5_TABELA = '98' "
          cQry1 += "ORDER BY SX5.X5_CHAVE "
          TCQuery cQry1 ALIAS "REG" NEW
          DbSelectArea("REG")
          DBGoTop()
       Endif
       
       cQry1 := ""
       If mv_par02 == 1
          cQry1 += "SELECT ZZC.ZZC_PRODUT, SUM(ZZC.ZZC_QUANTI) AS ZZC_QUANTI, SUM(ZZC.ZZC_RETIRA) AS ZZC_RETIRA, SUM(ZZC.ZZC_VOLUME) AS ZZC_VOLUME, SUM(ZZC.ZZC_VOLRET) AS ZZC_VOLRET "
       ElseIf mv_par02 == 2
              cQry1 += "SELECT ZZC.ZZC_PEDIDO, ZZC.ZZC_PRODUT, SUM(ZZC.ZZC_QUANTI) AS ZZC_QUANTI, SUM(ZZC.ZZC_RETIRA) AS ZZC_RETIRA, SUM(ZZC.ZZC_VOLUME) AS ZZC_VOLUME, SUM(ZZC.ZZC_VOLRET) AS ZZC_VOLRET "
       Else
           cQry1 += "SELECT ZZC.ZZC_BORDER, ZZC.ZZC_PRODUT, SUM(ZZC.ZZC_QUANTI) AS ZZC_QUANTI, SUM(ZZC.ZZC_RETIRA) AS ZZC_RETIRA, SUM(ZZC.ZZC_VOLUME) AS ZZC_VOLUME, SUM(ZZC.ZZC_VOLRET) AS ZZC_VOLRET "
       Endif
       cQry1 += "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
       cQry1 += "WHERE ZZC.ZZC_FILIAL = '"+xFilial("ZZC")+"' "
       cQry1 += "  AND ZZC.D_E_L_E_T_ = '' "
       cQry1 += "  AND ZZC.ZZC_DESPAC<> 'S' "
       If mv_par02 == 1
          cQry1 += "GROUP BY ZZC.ZZC_PRODUT "
          cQry1 += "ORDER BY ZZC.ZZC_PRODUT "
          Titulo := Alltrim(Titulo)+" Produto"
       ElseIf mv_par02 == 2                                  
              cQry1 += "GROUP BY ZZC.ZZC_PEDIDO, ZZC_PRODUT "
              cQry1 += "ORDER BY ZZC.ZZC_PEDIDO, ZZC_PRODUT "
              Titulo := Alltrim(Titulo)+" Pedido"
       Else
          cQry1 += "GROUP BY ZZC.ZZC_BORDER, ZZC_PRODUT "
          cQry1 += "ORDER BY ZZC.ZZC_BORDER, ZZC_PRODUT "
          Titulo := Alltrim(Titulo)+" Bordero"
       Endif
       TCQuery cQry1 ALIAS "TCQ" NEW                                                     

       DbSelectArea("TCQ")
       DbGoTop()
       ProcRegua(RecCount())
       
       While !EOF()
             If lAbortPrint
                @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
                Exit
             Endif
             If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
                nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                nLin += 1
             Endif               
             If mv_par02 == 1
                If mv_par01 == 1 .and. (TCQ->ZZC_QUANTI - TCQ->ZZC_RETIRA) == 0
                   DbSelectArea("TCQ")
                   DbSkip()
                   Loop
                Endif
                @ nLin, 000 PSAY TCQ->ZZC_PRODUT                                                          Picture "@R XX 99.99.999-99"
                @ nLin, 016 PSAY Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZC_PRODUT, "B1_DESC")           Picture "@!"
                @ nLin, 047 PSAY Iif(mv_par01 == 1, (TCQ->ZZC_QUANTI - TCQ->ZZC_RETIRA), TCQ->ZZC_QUANTI) Picture "@E 999999"
                @ nLin, 054 PSAY Iif(mv_par01 == 1, (TCQ->ZZC_VOLUME - TCQ->ZZC_VOLRET), TCQ->ZZC_VOLUME) Picture "@E 999999"
                @ nLin, 061 PSAY ((TCQ->ZZC_RETIRA / TCQ->ZZC_QUANTI) * 100)                              Picture "@E 99.99%"
                @ nLin, 068 PSAY SubStr(Posicione("SB2", 1, xFilial("SB2")+TCQ->ZZC_PRODUT+Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZC_PRODUT, "B1_LOCPAD"), "B2_LOCALIZ"), 1, 12)
                nLin += 1
                DbSelectArea("TCQ")
                DbSkip()
             ElseIf mv_par02 == 2
                    If mv_par03 == 1
                       DbSelectArea("REG")
                       DbGoTop()
                       While !Eof()
                             //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
                             //cRegiao := U_TiraAcento(REG->X5_CHAVE)
                             //cNomReg := Alltrim(REG->X5_DESCRI)
                             cRegiao := U_TiraAcento(REG->X5CHAVE)
                             cNomReg := Alltrim(REG->X5DESCRI)
                             lImpReg := .f.
                             nPesBru := 0
                             nPesLiq := 0
                             nVolTot := 0
                             DbSelectArea("TCQ")
                             DbGoTop()
                             While !Eof()
                                   cPedido := TCQ->ZZC_PEDIDO
                                   cRegPed := Posicione("SA1", 1, xFilial("SA1")+Posicione("SC5", 1, xFilial("SC5")+cPedido, "C5_CLIENTE"), "A1_REGIAO")
                                   If Alltrim(cRegPed) == Alltrim(cRegiao)
                                      @ nLin, 000 PSAY cRegiao+' - '+cNomReg
                                        nLin += 1
                                      @ nLin, 000 PSAY Replicate("-", 80)
                                        nLin += 1
                                      cPedido := TCQ->ZZC_PEDIDO
                                      @ nLin, 000 PSAY "PEDIDO: "+cPedido
                                      @ nLin, 015 PSAY "CLIENTE: "+Posicione("SC5", 1, xFilial("SC5")+cPedido, "C5_CLIENTE")+' - '+SubStr(Alltrim(Posicione("SA1", 1, xFilial("SA1")+Posicione("SC5", 1, xFilial("SC5")+cPedido, "C5_CLIENTE"), "A1_NOME")), 1, 20)
                                        nLin += 1
                                      @ nLin, 000 PSAY Replicate("-", 80)
                                        nLin += 1
                                      While !Eof() .and. TCQ->ZZC_PEDIDO == cPedido
                                            If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
                                               nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                                               nLin += 1
                                            Endif               
                                            If mv_par01 == 1 .and. (TCQ->ZZC_QUANTI - TCQ->ZZC_RETIRA) == 0
                                               DbSelectArea("TCQ")
                                               DbSkip()
                                               Loop
                                            Endif 
                                            @ nLin, 000 PSAY TCQ->ZZC_PRODUT Picture "@R XX 99.99.999-99"
                                            @ nLin, 016 PSAY Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZC_PRODUT, "B1_DESC")           Picture "@!"
                                            @ nLin, 047 PSAY Iif(mv_par01 == 1, (TCQ->ZZC_QUANTI - TCQ->ZZC_RETIRA), TCQ->ZZC_QUANTI) Picture "@E 999999"
                                            @ nLin, 054 PSAY Iif(mv_par01 == 1, (TCQ->ZZC_VOLUME - TCQ->ZZC_VOLRET), TCQ->ZZC_VOLUME) Picture "@E 999999"
                                            @ nLin, 061 psay ((TCQ->ZZC_RETIRA / TCQ->ZZC_QUANTI) * 100)                              Picture "@E 99.99%"
                                            @ nLin, 068 PSAY SubStr(Posicione("SB2", 1, xFilial("SB2")+TCQ->ZZC_PRODUT+Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZC_PRODUT, "B1_LOCPAD"), "B2_LOCALIZ"), 1, 12)
                                            nLin += 1
                                            DbSelectArea("TCQ")
                                            DbSkip()
                                      Enddo
                                      If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
                                         nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                                         nLin += 1
                                      Endif               
                                      @ nLin, 000 PSAY Replicate("-", 80)
                                        nLin += 1
                                      @ nLin, 000 PSAY "PESO BRUTO: "  +Transform(Posicione("SC5", 1, xFilial("SC5")+cPedido, "C5_PBRUTO") , "@E 999,999.99")
                                      @ nLin, 031 PSAY "PESO LIQUIDO: "+Transform(Posicione("SC5", 1, xFilial("SC5")+cPedido, "C5_PESOL")  , "@E 999,999.99")
                                      @ nLin, 064 PSAY "VOLUMES: "     +Transform(Posicione("SC5", 1, xFilial("SC5")+cPedido, "C5_VOLUME1"), "@E 99999")
                                        nLin += 1
                                      @ nLin, 000 PSAY Replicate("-", 80)
                                        nLin += 2
                                      nPesBru += Posicione("SC5", 1, xFilial("SC5")+cPedido, "C5_PBRUTO")
                                      nPesLiq += Posicione("SC5", 1, xFilial("SC5")+cPedido, "C5_PESOL")
                                      nVolTot += Posicione("SC5", 1, xFilial("SC5")+cPedido, "C5_VOLUME1")
                                      lImpReg := .t.
                                      DbSelectArea("TCQ")
                                      DbSkip()
                                   Else
                                      DbSelectArea("TCQ")
                                      DbSkip()
                                   Endif
                             Enddo
                             If lImpReg
                                @ nLin, 000 PSAY "PESO BRUTO: "  +Transform(nPesBru, "@E 999,999.99")
                                @ nLin, 031 PSAY "PESO LIQUIDO: "+Transform(nPesLiq, "@E 999,999.99")
                                @ nLin, 064 PSAY "VOLUMES: "     +Transform(nVolTot, "@E 99999")
                                  nLin += 1
                                @ nLin, 000 PSAY Replicate("-", 80)
                                  nLin += 2
                             Endif
                             DbSelectArea("REG")
                             DbSkip()
                       Enddo
                    Else
                       cPedido := TCQ->ZZC_PEDIDO
                       @ nLin, 000 PSAY "PEDIDO: "+cPedido
                       @ nLin, 015 PSAY "CLIENTE: "+Posicione("SC5", 1, xFilial("SC5")+cPedido, "C5_CLIENTE")+' - '+SubStr(Alltrim(Posicione("SA1", 1, xFilial("SA1")+Posicione("SC5", 1, xFilial("SC5")+cPedido, "C5_CLIENTE"), "A1_NOME")), 1, 20)
                         nLin += 1
                       @ nLin, 000 PSAY Replicate("-", 80)
                         nLin += 1
                       While !Eof() .and. TCQ->ZZC_PEDIDO == cPedido
                             If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
                                nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                                nLin += 1
                             Endif               
                             If mv_par01 == 1 .and. (TCQ->ZZC_QUANTI - TCQ->ZZC_RETIRA) == 0
                                DbSelectArea("TCQ")
                                DbSkip()
                                Loop
                             Endif 
                             @ nLin, 000 PSAY TCQ->ZZC_PRODUT Picture "@R XX 99.99.999-99"
                             @ nLin, 016 PSAY Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZC_PRODUT, "B1_DESC")           Picture "@!"
                             @ nLin, 047 PSAY Iif(mv_par01 == 1, (TCQ->ZZC_QUANTI - TCQ->ZZC_RETIRA), TCQ->ZZC_QUANTI) Picture "@E 999999"
                             @ nLin, 054 PSAY Iif(mv_par01 == 1, (TCQ->ZZC_VOLUME - TCQ->ZZC_VOLRET), TCQ->ZZC_VOLUME) Picture "@E 999999"
                             @ nLin, 061 psay ((TCQ->ZZC_RETIRA / TCQ->ZZC_QUANTI) * 100)                              Picture "@E 99.99%"
                             @ nLin, 068 PSAY SubStr(Posicione("SB2", 1, xFilial("SB2")+TCQ->ZZC_PRODUT+Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZC_PRODUT, "B1_LOCPAD"), "B2_LOCALIZ"), 1, 12)
                             nLin += 1
                             DbSelectArea("TCQ")
                             DbSkip()
                       Enddo
                       If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
                          nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                          nLin += 1
                       Endif               
                       @ nLin, 000 PSAY Replicate("-", 80)
                         nLin += 1
                       @ nLin, 000 PSAY "PESO BRUTO: "  +Transform(Posicione("SC5", 1, xFilial("SC5")+cPedido, "C5_PBRUTO") , "@E 999,999.99")
                       @ nLin, 031 PSAY "PESO LIQUIDO: "+Transform(Posicione("SC5", 1, xFilial("SC5")+cPedido, "C5_PESOL")  , "@E 999,999.99")
                       @ nLin, 064 PSAY "VOLUMES: "     +Transform(Posicione("SC5", 1, xFilial("SC5")+cPedido, "C5_VOLUME1"), "@E 99999")
                         nLin += 1
                       @ nLin, 000 PSAY Replicate("-", 80)
                         nLin += 2
                    Endif
             ElseIf mv_par02 == 3
                    cBorder := TCQ->ZZC_BORDER
                    @ nLin, 000 PSAY "BORDERO: "+cBorder
                      nLin += 1
                    @ nLin, 000 PSAY Replicate("-", 80)
                      nLin += 1
                    While !Eof() .and. TCQ->ZZC_BORDER == cBorder
                          If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
                             nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                             nLin += 1
                          Endif               
                          If mv_par01 == 1 .and. (TCQ->ZZC_QUANTI - TCQ->ZZC_RETIRA) == 0
                             DbSelectArea("TCQ")
                             DbSkip()
                             Loop
                          Endif
                          @ nLin, 000 PSAY TCQ->ZZC_PRODUT Picture "@R XX 99.99.999-99"
                          @ nLin, 016 PSAY Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZC_PRODUT, "B1_DESC")           Picture "@!"
                          @ nLin, 047 PSAY Iif(mv_par01 == 1, (TCQ->ZZC_QUANTI - TCQ->ZZC_RETIRA), TCQ->ZZC_QUANTI) Picture "@E 999999"
                          @ nLin, 054 PSAY Iif(mv_par01 == 1, (TCQ->ZZC_VOLUME - TCQ->ZZC_VOLRET), TCQ->ZZC_VOLUME) Picture "@E 999999"
                          @ nLin, 061 psay ((TCQ->ZZC_RETIRA / TCQ->ZZC_QUANTI) * 100)                              Picture "@E 99.99%"
                          @ nLin, 068 PSAY SubStr(Posicione("SB2", 1, xFilial("SB2")+TCQ->ZZC_PRODUT+Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZC_PRODUT, "B1_LOCPAD"), "B2_LOCALIZ"), 1, 12)
                          nLin += 1
                          DbSelectArea("TCQ")
                          DbSkip()
                    Enddo
                    If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
                       nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                       nLin += 1
                    Endif               
                    @ nLin, 000 PSAY Replicate("-", 80)
                    nLin += 2
             Endif
      EndDo
      DbSelectArea("TCQ")
      DbCloseArea()
      If mv_par03 == 1 //Regi๕es
         DbSelectArea("REG")
         DbCloseArea()
      Endif
      SET DEVICE TO SCREEN
      If aReturn[5]==1
         DbCommitAll()
         SET PRINTER TO
         OurSpool(wnrel)
      Endif

      MS_FLUSH()

Return

/*******************************************************************************/
/*** VLDPERG - Ajusta perguntas com o SX1.                                   ***/
/*******************************************************************************/
//LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
/*Static Function fVldPer()
       PutSX1("FATR09    ", "01", "Imprimir somente ", "", "", "mv_ch1", "N"  , 1, 0, 0, "C", " ", " ", " ", " ", "mv_par01", "Faltas" , " ", " ", " ", "Todos" , " ", " ", ""       , " "     , " "     , " ", " "     , " "     , " ",  " "     ,  " "     , Nil  , Nil     , Nil     , "FATR09" )
       PutSX1("FATR09    ", "02", "Imprimir por     ", "", "", "mv_ch2", "N"  , 1, 0, 0, "C", " ", " ", " ", " ", "mv_par02", "Produto", " ", " ", " ", "Pedido", " ", " ", "Bordero", " "     , " "     , " ", " "     , " "     , " ",  " "     ,  " "     , Nil  , Nil     , Nil     , "FATR09" )
       PutSX1("FATR09    ", "03", "Quebra por regiใo", "", "", "mv_ch3", "N"  , 1, 0, 0, "C", " ", " ", " ", " ", "mv_par03", "Sim"    , " ", " ", " ", "Nใo"   , " ", " ", ""       , " "     , " "     , " ", " "     , " "     , " ",  " "     ,  " "     , Nil  , Nil     , Nil     , "FATR09" )
Return*/