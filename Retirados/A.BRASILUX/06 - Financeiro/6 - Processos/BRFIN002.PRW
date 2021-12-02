#include "topconn.ch"
#include "rwmake.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRFIN002 บAutor  ณ                    บ Data ณ  14/03/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calculo de juros a receber de clientes que pagaram em car- บฑฑ
ฑฑบ          ณ torio                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX TINTAS TษCNICAS LTDA.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function BRFIN002()
     Local cQuery := ""               
     Private oTemptable
     cQuery += "SELECT SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_NOMCLI, SE1.E1_VENCREA, SE1.E1_BAIXA, SE1.E1_VALOR, SE1.E1_SALDO "
     cQuery += "FROM "+RetSqlName("SE1")+" SE1 WITH (NOLOCK) "
     cQuery += "WHERE SE1.E1_FILIAL = '"+xFilial("SE1")+"' "
     cQuery += "  AND LEN(SE1.E1_PGJURO) = 0 "
     cQuery += "  AND SE1.E1_NATUREZ = '802024' "
     cQuery += "  AND SE1.D_E_L_E_T_ <> '*' "
     cQuery += "ORDER BY E1_CLIENTE, E1_BAIXA "
     TCQUERY cQuery ALIAS "TMP" NEW

     DbSelectArea("TMP")
     DbGoTop()
     IncProc()
     //cString := "TRB"
     aStru   := {}
     aAdd(aStru, {"OK"     , "C", 02, 00})
     aAdd(aStru, {"PREFIXO", "C", 03, 00})
     aAdd(aStru, {"TITULO" , "C", 06, 00})
     aAdd(aStru, {"PARCELA", "C", 01, 00})
     aAdd(aStru, {"TIPO"   , "C", 03, 00})
     aAdd(aStru, {"CLIENTE", "C", 06, 00})
     aAdd(aStru, {"LOJA"   , "C", 02, 00})
     aAdd(aStru, {"NOME"   , "C", 20, 00})
     aAdd(aStru, {"VENCTO" , "D", 08, 00})
     aAdd(aStru, {"BAIXA"  , "D", 08, 00})
     aAdd(aStru, {"VALOR"  , "N", 17, 02})
     aAdd(aStru, {"SALDO"  , "N", 17, 02})

     /********************************************************************************************************************************/
     /*** BLOCO ALTERADO EM 23/12/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAวรO DE RELEASE PROTHEUS 12.1.25                  ***/
     //cArq := CriaTrab(aStru, .T.)
     //DbUseArea(.T., , cArq, cString, .T.)
     oTempTable := FWTemporaryTable():New( "TRB" )
     oTemptable:SetFields( aStru )
     oTempTable:Create()
     /********************************************************************************************************************************/

     DbSelectArea("TMP")
     DbGoTop()

     While !Eof()
           DbSelectArea("TRB")
           RecLock("TRB", .T.)
              TRB->PREFIXO:= TMP->E1_PREFIXO
              TRB->TITULO := TMP->E1_NUM
              TRB->PARCELA:= TMP->E1_PARCELA
              TRB->TIPO   := TMP->E1_TIPO
              TRB->CLIENTE:= TMP->E1_CLIENTE
              TRB->LOJA   := TMP->E1_LOJA
              TRB->NOME   := TMP->E1_NOMCLI
              TRB->VENCTO := cTod(SubStr(TMP->E1_VENCREA, 7, 2)+'/'+SubStr(TMP->E1_VENCREA, 5, 2)+'/'+SubStr(TMP->E1_VENCREA, 3, 2))
              TRB->BAIXA  := cTod(SubStr(TMP->E1_BAIXA  , 7, 2)+'/'+SubStr(TMP->E1_BAIXA  , 5, 2)+'/'+SubStr(TMP->E1_BAIXA  , 3, 2))
              TRB->VALOR  := TMP->E1_VALOR
              TRB->SALDO  := TMP->E1_SALDO
           MsUnLock()
           DbSelectArea("TMP")
           DbSkip()
           IncProc()
     EndDo
     DbSelectArea("TRB")
     DbGoTop()

     // Para Utilizacao de um arquivo qualquer sem o SX3 em um browse padrao
     aCampos := {}                                 
     aAdd(aCampos, {"OK"     , "Flag"                             })
     aAdd(aCampos, {"PREFIXO", "Prefixo"    , "@!"                })
     aAdd(aCampos, {"TITULO" , "Titulo"                           }) // Nao precisa por Picture
     aAdd(aCampos, {"PARCELA", "Parc."                            })
     aAdd(aCampos, {"TIPO"   , "Tipo"                             })
     aAdd(aCampos, {"CLIENTE", "Cod.Cliente"                      })
     aAdd(aCampos, {"LOJA"   , "Loja"                             })
     aAdd(aCampos, {"NOME"   , "Cliente"                          })
     aAdd(aCampos, {"VENCTO" , "Vencimento"                       })
     aAdd(aCampos, {"BAIXA"  , "Recebto."                         })
     aAdd(aCampos, {"VALOR"  , "Vlr.Titulo" , "@RE 999,999,999.99"})
     aAdd(aCampos, {"SALDO"  , "Saldo"      , "@RE 999,999,999.99"})

     @ 200,001 TO 600,600 DIALOG oDlg2 TITLE "Boletos de Juros"
     @ 006,005 TO 175,295 BROWSE "TRB" FIELDS aCampos MARK "OK"
     @ 180,240 BMPBUTTON TYPE 1 ACTION ExecBlock("BRFIN003", .F., .F.)
     @ 180,270 BMPBUTTON TYPE 2 ACTION Close(oDlg2)
     ACTIVATE DIALOG oDlg2 CENTERED

     DbSelectArea("TMP")
     DbCloseArea()

     DbSelectArea("TRB")
     DbCloseArea()
     /********************************************************************************************************************************/
     /*** BLOCO ALTERADO EM 23/12/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAวรO DE RELEASE PROTHEUS 12.1.25                  ***/
     //cArq := cArq+".dbf"
     //DELETE FILE (cArq)
     oTempTable:Delete()
     /********************************************************************************************************************************/
     
     DbSelectArea("SE1")
Return

/*******************************************************************************/
/*** FIN002_1 - Calculo de juros a receber de clientes que pagaram em cart.  ***/
/*** Autor:                                                                  ***/
/*** Data : 14/03/04                                                         ***/
/*** Altera็๕es: 23/05/07 - Luํs Gustavo de Souza                            ***/
/***                        Troca do programa BRFIN003 para FIN002_1 dentro  ***/
/***                        do programa BRFIN002                             ***/
/*******************************************************************************/
User Function FIN002_1()
     Local cNum, nJuros, cTitGer, cDupl, nValor, cLoja, cCliente, nJuro
     Local aTam := {}
     ProcRegua(300)

     cNum    := GetMv("MV_NTITJUR")
     nJuros  := GetMv("MV_JUROS")
     cTitGer := ""
                  
	aTam := TamSX3("E1_NUM") // Tamanho do campo E1_NUM

     DbSelectArea("TRB")
     DbGoTop()
     ProcRegua(300)

     While !Eof()
           cCliente := TRB->CLIENTE
           cLoja    := TRB->LOJA
           cDupl    := "Juros Ref.a Titulo(s) "
           nValor   := 0
           While !Eof() .and. cCliente == TRB->CLIENTE .and. cLoja == TRB->LOJA
                 // Para avaliar se o registro esta marcado
                 If Marked("OK")
                    nJuro  := fCalcJuros(TRB->BAIXA - TRB->VENCTO)
                    nValor := nValor + (TRB->VALOR * nJuro)
                    DbSelectArea("SE1")
                    DbSeek(xFilial("SE1")+TRB->PREFIXO+PADR(TRB->TITULO,aTam[1])+TRB->PARCELA+TRB->TIPO)
                    If Found()
                       RecLock("SE1", .f.)
                          SE1->E1_PGJURO := "J"
                       MsUnLock()
                    Endif
                    cDupl += Alltrim(TRB->PREFIXO)+Alltrim(TRB->TITULO)+Alltrim(TRB->PARCELA)+chr(10)+chr(13) && "/"
                    DbSelectArea("TRB")
                 Endif                                            
                 DbSkip()
                 IncProc()
           Enddo
           If nValor > 15
              // Cria titulo dos juros
              DbSelectArea("SA1")
              DbSetOrder(1)
              DbSeek(xFilial("SA1")+cCliente+cLoja)
   
              DbSelectArea("SE1")
              RecLock("SE1",.T.)
                 SE1->E1_FILIAL  := xFilial("SE1")
                 SE1->E1_PREFIXO := "JUR"
                 SE1->E1_NUM     := cNum
                 SE1->E1_PARCELA := " "
                 SE1->E1_TIPO    := "DP"
                 SE1->E1_NATUREZ := "802025"
                 SE1->E1_HIST    := cDupl
                 SE1->E1_CLIENTE := cCliente
                 SE1->E1_LOJA    := cLoja
                 SE1->E1_NOMCLI  := SA1->A1_NREDUZ
                 SE1->E1_EMISSAO := dDataBase
                 SE1->E1_VENCTO  := dDataBase
                 SE1->E1_VENCREA := dDataBase
                 SE1->E1_VALOR   := nValor
                 SE1->E1_SALDO   := nValor
                 SE1->E1_EMIS1   := dDataBase
                 SE1->E1_VENCORI := dDataBase
                 SE1->E1_MOEDA   := 1
                 SE1->E1_VLCRUZ  := nValor
                 SE1->E1_STATUS  := "A"
                 SE1->E1_FLUXO   := "S"
                 SE1->E1_FILORIG := "01"
                 SE1->E1_PGJURO  := "J"
                 SE1->E1_SITUACA := "0"
                 SE1->E1_PORTADO := "001"
                 SE1->E1_ORIGEM  := "BRFIN003"
              MsUnLock()
              cTitGer += SE1->E1_PREFIXO+alltrim(SE1->E1_NUM)+" / "
              cNum    := StrZero(Val(cNum)+1, 6)
              DbSelectArea("TRB")
           Endif
     Enddo

     //LGS#20200131 - Adequa็ใo para release 12.1.25 e posteriores
     //DbSelectArea("SX6")
     GetMv("MV_NTITJUR")
     //RecLock("SX6", .F.)
     //   SX6->X6_CONTEUD := cNum
     //MsUnlock()
     PutMv( "MV_NTITJUR", cNum )

     If !Empty(cTitGer)
        MsgBox("Este(s) o(s) tํtulo(s) gerado(s) " + cTitGer + CHR(13)+CHR(10), "Aten็ใo...", "STOP")
     Endif
     Close(oDlg2)
Return

/////////////////////////////////
// Calculo do percentual de    //
// juros                       //
/////////////////////////////////
Static Function fCalcJuros(nDias)
       Local nJuro
       nJuro := 1 + (nJuros / 100)
       nRet  := Exp(((nDias * 12) / 365)*Log(nJuro)) - 1
Return(nRet)