#include "protheus.ch"
#include "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Descri‡…o ³ Impress„o do Arquivo de Envio de Titulos ao Banco  - SE1   ³±±
±±³ 28/03/02 ³ Cleber                                                     ³±±
±±³        2 ³ Colocar contagem de títulos                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRASILUX TINTAS TÉCNICAS LTDA.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function Finr660()
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Define Variaveis                                             ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Local wnrel
     Local cDesc1 := 'Este programa tem como objetivo imprimir os dados'
     Local cDesc2 := 'que ser„o utilizados para o Envio da Comunica‡„o'
     Local cDesc3 := 'Banc ria".'
     Local cString := "SE1"
     Local Tamanho := "G"
     Private cTitulo:= OemToAnsi("Impressao do Envio da Comunicacao Bancaria")  //"Impressao do Envio da Comunicacao Bancaria"
     Private cabec1
     Private cabec2
     Private aReturn := { OemToAnsi("Zebrado"), 1,OemToAnsi("Administracao"), 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
     Private cPerg   := "FIN660"
     Private nomeprog:= "finr660"
     Private nLastKey:=0

     //AjustaSX1() //LGS#20200130 - Adequação para release 12.1.25
     Pergunte(cPerg, .F.)
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Variavel utilizada para parametro                            ³
     //³ mv_par01            // No. do Bordero                        ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Definicao dos cabecalhos                                     ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     cabec1 := OemToAnsi("  No.Bordero  Dt.Bordero  Nosso No.-Parcela  Tipo   Natureza    Nome do Banco   Agencia  Cod.Cliente  Loja   Emissao    Vencto.     Saldo do Titulo      Valor IRRF       Valor ISS      Valor INSS Juros Vlr.Moeda Nacional") //"  No.Bordero  Dt.Bordero  Nosso No.-Parcela  Tipo   Natureza    Nome do Banco   Agencia  Cod.Cliente  Loja   Emissao    Vencto.     Saldo do Titulo      Valor IRRF       Valor ISS      Valor INSS Juros Vlr.Moeda Nacional"
     cabec2 := OemToAnsi("   Nome do Cliente       Historico do Titulo           Ocorrencia CNAB          Desconto Concedido     Valor da Multa    Valor dos Juros  Valor da Correcao Moeda do Titulo  Situacao do Titulo    Nosso Numero") //"   Nome do Cliente       Historico do Titulo           Ocorrencia CNAB          Desconto Concedido     Valor da Multa    Valor dos Juros  Valor da Correcao Moeda do Titulo  Situacao do Titulo    Nosso Numero"

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Envia controle para a funcao SETPRINT                        ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     wnrel := "FINR660"
     wnrel := SetPrint(cString, wnrel, cPerg, @cTitulo, cDesc1, cDesc2, cDesc3, .F., "",, Tamanho)

     If nLastKey == 27
        Return
     End

     SetDefault(aReturn, cString)

     If nLastKey == 27
        Return ( NIL )
     End
     RptStatus({|lEnd| Fa660Imp(@lEnd,wnRel,cString)},cTitulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³ FA660Imp ³ Autor ³ Lu¡s C. Cunha         ³ Data ³ 05/11/93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Retorno Cnab                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ FA660Imp(lEnd,wnRel,cString                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ SIGAFIN                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FA660Imp(lEnd,wnRel,cString)
     Local cbcont, cbtxt
     Local tamanho  := "G"
     Local cDesOco, cDesSit
     Local nTotTit  := 0
     Local nTotIRF  := 0
     Local nTotISS  := 0
     Local nTotINSS := 0
     Local nTotREAL := 0
     Local nTipo
     Local nContTit := 0

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     cbtxt    := SPACE(10)
     cbcont   := 0
     li       := 80
     m_pag    := 1
     nTipo    := Iif(aReturn[4] == 1, GetMv("MV_COMP"), GetMv("MV_NORM"))

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Posiciona no Bordero Informado pelo usuario                  ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     DbSelectArea("SE1")
     DbSetOrder(5)
     If !(DbSeek(cFilial+mv_par01))
        Set Printer To
        Set Device To Screen
        Help(" ", 1, "BORD150")
        Return
     End

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Inicia a leitura do arquivo de Titulos                       ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     DbSelectArea("SE1")
     SetRegua(RecCount())
     nContTit := 0
     While !SE1->(Eof()) .And. cFilial == SE1->E1_FILIAL .And. SE1->E1_NUMBOR == mv_par01
	       IncRegua()
           If Empty(SE1->E1_NUMBOR) .or. Iif(mv_par02 == 2 .and. SE1->E1_SALDO == 0, .T., .F.)
	          SE1->( dbSkip() )
	          Loop
	       Endif
	       If SE1->E1_TIPO $ MVRECANT+"/"+MVPROVIS
	          SE1->( dbSkip() )
	          Loop
	       EndIf
	       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	       //³ Posiciona no Cliente                                         ³
	       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	       DbSelectArea("SA1")
	       DbSeek(cFilial+SE1->E1_CLIENTE+SE1->E1_LOJA)

	       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	       //³ Posiciona no Banco                                           ³
	       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	       DbSelectArea("SA6")
	       DbSeek(cFilial+SE1->E1_PORTADO+SE1->E1_AGEDEP)

	       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	       //³ Posiciona nas Ocorrencias da Transmissao Banc ria            ³
	       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	       DbSelectArea("SEB")
	       If (dbSeek(cFilial+SE1->E1_PORTADO+Substr(SE1->E1_OCORREN,1,2)+" E"))
	          cDesOco := SEB->EB_DESCRI
	       Else
	          cDesOco := OemToAnsi("OCORRENCIA NAO ENCONTRADA")  //"OCORRENCIA NAO ENCONTRADA"
	       End

	       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	       //³ Posiciona no Arquivo de Tabelas                              ³
	       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	       DbSelectArea("SX5")
	       If (dbSeek(cFilial+"07"+SE1->E1_SITUACA))
	          cDesSit := SubStr(X5Descri(), 1, 20)
	       Else
              cDesSit := OemToAnsi("SIT. NAO ENCONTRADA")  //"SIT. NAO ENCONTRADA"
	       End

	       DbSelectArea("SE1")

	       If li > 58
	          cabec(cTitulo, cabec1, cabec2, nomeprog, tamanho, nTipo)
	       End

	       @ li,002 PSAY SE1->E1_NUMBOR
	       @ li,014 PSAY SE1->E1_DATABOR
	       @ li,026 PSAY SE1->E1_PREFIXO
	       @ li,029 PSAY '-'
	       @ li,030 PSAY alltrim(SE1->E1_NUM)+If( !Empty(SE1->E1_PARCELA), "-", "")+SE1->E1_PARCELA
//	       @ li,036 PSAY If( !Empty(SE1->E1_PARCELA), "-", "")+SE1->E1_PARCELA
	       @ li,045 PSAY SE1->E1_TIPO
	       @ li,052 PSAY SE1->E1_NATUREZA
	       @ li,064 PSAY SA6->A6_NREDUZ
	       @ li,080 PSAY SE1->E1_AGEDEP
	       @ li,109 PSAY SE1->E1_EMISSAO
	       @ li,120 PSAY SE1->E1_VENCREA
	       @ li,133 PSAY SE1->E1_SALDO	Picture Tm(SE1->E1_SALDO,14)
	       @ li,149 PSAY SE1->E1_IRRF	Picture Tm(SE1->E1_IRRF,14)
	       @ li,165 PSAY SE1->E1_ISS	Picture Tm(SE1->E1_ISS,14)
	       @ li,181 PSAY SE1->E1_INSS	Picture Tm(SE1->E1_INSS,14)
	       If !Empty( SE1->E1_VALJUR )
	          @ li,195 PSAY SE1->E1_VALJUR  Picture "@E 999.99"
	       Else
	          @ li,195 PSAY SE1->E1_PORCJUR Picture "@E 999.99"
	       Endif
	       @ li,203 PSAY SE1->E1_VLCRUZ   Picture Tm(SE1->E1_VLCRUZ,14)
	       li++
	       @ li,002 PSAY SE1->E1_CLIENTE
	       @ li,023 PSAY SE1->E1_LOJA
	       @ li,028 PSAY SA1->A1_NREDUZ
	       @ li,052 PSAY SE1->E1_HIST
	       @ li,078 PSAY cDesOco
	       //@ li,109 PSAY GetMv("MV_MOEDA"+AllTrim(STR(SE1->E1_MOEDA, 2)))
	       @ li,109 PSAY fRetMoeda( AllTrim( STR( SE1->E1_MOEDA, 2 ) ) )
	       @ li,126 PSAY cDesSit
	       @ li,148 PSAY SE1->E1_NUMBCO
	       li++
	       @ li,000 PSAY Replicate('-',220)
	       li++
	       If E1_TIPO $ MVABATIM
              nTotTit  -= SE1->E1_SALDO
              nTotIRF  -= SE1->E1_IRRF
              nTotISS  -= SE1->E1_ISS
              nTotINSS -= SE1->E1_INSS
              nTotREAL -= SE1->E1_VLCRUZ
	       Else
              nTotTit  += SE1->E1_SALDO
              nTotIRF  += SE1->E1_IRRF
              nTotISS  += SE1->E1_ISS
              nTotINSS += SE1->E1_INSS
              nTotREAL += SE1->E1_VLCRUZ
	       Endif    
	       nContTit++ // Total de Títulos impressos
	       DbSelectArea("SE1")
	       SE1->(dbSkip( ))
     End

     If li != 80
	    li++
	    @ li,000 PSAY OemToAnsi("Total dos Titulos : ")  //"Total dos Titulos : "
        @ li,030 PSAY "QTDE DE TITULOS IMPRESSOS : "
        @ li,058 PSAY nContTit picture "999,999"
        @ li,133 PSAY nTotTit	Picture TM(nTotTit,14)
        @ li,149 PSAY nTotIRF	Picture Tm(nTotIRF,14)
        @ li,165 PSAY nTotISS	Picture Tm(nTotISS,14)
        @ li,181 PSAY nTotINSS	Picture Tm(nTotINSS,14)
        @ li,203 PSAY nTotREAL	Picture Tm(nTotREAL,14)
        Roda(cbcont, cbtxt, tamanho)
     End
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Recupera a Integridade dos dados                             ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     DbSelectArea("SE1")
     DbSetOrder(1)
     DbClearFilter()
     Set Device To Screen

     If aReturn[5] = 1
        Set Printer To
        dbCommitAll()
        OurSpool(wnrel)
     Endif
     MS_FLUSH()

Return

/*/{Protheus.doc} fRetMoeda
//TODO Função criada para adequação da release 12.1.25 a fim de tirar API GetMV de dentro do Loop
@author Luís Gustavo
@since 31/01/2020
@version 1.0
@return ${return}, ${return_description}
@param _cMoedaTit, , descricao
@type function
/*/
Static Function fRetMoeda( _cMoedaTit )
       Local _cRet

       _cRet := GetMv( "MV_MOEDA" + _cMoedaTit )
       
Return _cRet

// Compatibiliza o SX1
//LGS#20200130 - Adequação para release 12.1.25
/*
Static Function AjustaSx1()
       Local cAlias := Alias(), aPerg := {}
       Local cPerg  := "FIN660"
       cPerg := PADR(cPerg,10)
       aAdd(aPerg, {"Cons.Saldos Zerados?", "N", 1}) //"Cons.Saldos Zerados?"

       DbSelectArea("SX1")
       If !DbSeek(cPerg+"02")
          RecLock("SX1",.T.)
             Replace X1_GRUPO   with cPerg
             Replace X1_ORDEM   with "02"
             Replace X1_PERGUNT with aPerg[1][1]
             Replace X1_PERENG 	with aPerg[1][1]
             Replace X1_PERSPA 	with aPerg[1][1]
             Replace X1_VARIAVL with "mv_ch2"
             Replace X1_TIPO	with aPerg[1][2]
             Replace X1_TAMANHO with aPerg[1][3]
             Replace X1_PRESEL  with 2
             Replace X1_GSC	   	with "C"
             Replace X1_VAR01   with "mv_par02"
             Replace X1_DEF01   with "Sim" //"Sim"
             Replace X1_DEFSPA1 with "Sim" // "Sim"
             Replace X1_DEFENG1 with "Sim" // "Sim"
             Replace X1_DEF02   with "Nao" // "Nao"
             Replace X1_DEFSPA2 with "Nao" // "N„o"
             Replace X1_DEFENG2 with "Nao" // "N„o"
          MsUnlock()
       EndIf
       DbSelectArea(cAlias)
Return*/