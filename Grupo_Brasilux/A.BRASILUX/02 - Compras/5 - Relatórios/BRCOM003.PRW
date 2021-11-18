#INCLUDE "RWMAKE.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BRCOM003 ³ Autor ³ Luís Gustavo de Souza ³ Data ³ 30.01.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Entradas por Fornecedor                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ BRCOM003(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ GUSTAVO      ³22/05/03³      ³ Inclusao de novos campos a pedido da  -³±±
±±³              ³        ³      ³ diretoria.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRCOM003()
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Define Variaveis                                             ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     LOCAL CbTxt
     LOCAL wnrel
     LOCAL titulo     := OemToAnsi("Entradas por Fornecedor")                                   //STR0001 "Faturamento por Cliente"
     LOCAL cDesc1     := OemToAnsi("Este relatorio emite a relacao de entradas. Podera ser   ")	//STR0002 "Este relatorio emite a relacao de faturamento. Podera ser"
     LOCAL cDesc2     := OemToAnsi("emitido por ordem de Fornecedor ou por Valor (Ranking).  ")	//STR0003 "emitido por ordem de Cliente ou por Valor (Ranking).     "
     LOCAL cDesc3     := OemToAnsi("Se no TES estiver gera duplicata (N), nao sera computado.")	//STR0004 "Se no TES estiver gera duplicata (N), nao sera computado."
     LOCAL cString    := "SF1"
     LOCAL tamanho    := "M"
     //LOCAL limite     := 132

     PRIVATE aReturn  := { OemToAnsi("Zebrado"), 1,OemToAnsi("Administracao"), 1, 2, 1, "",1 }	//STR0005 "Zebrado"### STR0006 "Administracao"
     PRIVATE aCodCli  := {}
     PRIVATE aLinha   := {}
     PRIVATE nomeprog := "BRCOM003"
     PRIVATE cPerg    := padr("COM003",10)
     PRIVATE nLastKey := 0
     Private nTotFinal := 0
     Private nTotMedio := 0
     Private nQtdMedio := 0
     Private aMedia    := {}
     Private nSomG     := 0

     if !u_VldAcesso(funname())
     	 MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      	 return 
	 endif 
    u_zcfga01( 'BRCOM003' ) //LGS#2021118 - Gravação de log de utilização da rotina
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     cbtxt    := SPACE(10)
     li       := 80
     m_pag    := 01
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Verifica as perguntas selecionadas                           ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     ValPerg()
     pergunte("COM003",.F.)
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Variaveis utilizadas para parametros                         ³
     //³ mv_par01        // Data de                    	              ³
     //³ mv_par02        // Data ate  					       	      ³
     //³ mv_par03        // Fornecedor de                             ³
     //³ mv_par04 	     // Fornecedor ate                            ³
     //³ mv_par05	     // Estado de                                 ³
     //³ mv_par06	     // Estado ate                                ³
     //³ mv_par07	     // Lista por Fornecedor/Ranking/Estado       ³
     //³ mv_par08	     // Moeda                                     ³
     //³ mv_par09        // Devolucao				                  ³
     //³ mv_par10        // Duplicatas  			                  ³
     //³ mv_par11        // Estoque   				                  ³
     //³ mv_par12        // Tipo de   				                  ³
     //³ mv_par13        // Tipo ate  				                  ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Envia controle para a funcao SETPRINT                        ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     wnrel  := "BRCOM003"
     wnrel  := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

     If nLastKey==27
        Set Filter to
        Return
     Endif

     SetDefault(aReturn,cString)

     If nLastKey==27
        Set Filter to
        Return
     Endif

     RptStatus({|lEnd| COM0031(@lEnd,wnRel,cString)},Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ COM0031  ³ Autor ³ Luis Gustavo de Souza ³ Data ³ 31.01.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRCOM003 		                                       	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function COM0031(lEnd,WnRel,cString)
       LOCAL titulo   := OemToAnsi("Entradas por Fornecedor")                                   //STR0001 "Faturamento por Cliente"
       //LOCAL cDesc1   := OemToAnsi("Este relatorio emite a relacao de entradas. Podera ser   ")	//STR0002 "Este relatorio emite a relacao de faturamento. Podera ser"
       //LOCAL cDesc2   := OemToAnsi("emitido por ordem de Fornecedor ou por Valor (Ranking).  ")	//STR0003 "emitido por ordem de Cliente ou por Valor (Ranking).     "
       //LOCAL cDesc3   := OemToAnsi("Se no TES estiver gera duplicata (N), nao sera computado.")	//STR0004 "Se no TES estiver gera duplicata (N), nao sera computado."
       LOCAL cEstoq   := If( (MV_PAR11== 1),"S",If( (MV_PAR11== 2),"N","SN" ) )
       LOCAL cDupli   := If( (MV_PAR10== 1),"S",If( (MV_PAR10== 2),"N","SN" ) )
       LOCAL cPict	  := ""
       LOCAL CbTxt    := ""
       LOCAL CbCont   := ""
       LOCAL cabec1   := "" 
       LOCAL cabec2   := ""
       LOCAL cCliente := ""
       LOCAL cLoja    := ""
       LOCAL cEst     := ""
       LOCAL cMoeda   := ""
       LOCAL tamanho  := "M"
       //LOCAL limite   := 132
       LOCAL nRank    := 0
       LOCAL nMoeda   := 0
       LOCAL nAg1     := 0
       LOCAL nAg2     := 0
       LOCAL nAg3     := 0
       LOCAL nAg4     := 0
       LOCAL nAg5     := 0
       LOCAL nAg6     := 0
       LOCAL nValor1  := 0
       LOCAL nValor2  := 0
       LOCAL nValor3  := 0
       LOCAL nValor4  := 0
       LOCAL nValor5  := 0
       LOCAL nValor6  := 0
       LOCAL nEstV1   := 0
       LOCAL nEstV2   := 0
       LOCAL nEstV3   := 0
       LOCAL nEstV4   := 0
       LOCAL nEstV5   := 0
       LOCAL nEstV6   := 0
       LOCAL aCampos  := {}
       LOCAL aTam	  := {}
       LOCAL nSomTot  := 0

       PRIVATE nDecs:=msdecimais(mv_par08)
       Private oTempTbl01

       cPict	:= "@E) 99,999,999,999" + IIf(nDecs > 0,"."+replicate("9",nDecs),"")

       nTipo:=IIF(aReturn[4]==1,GetMv("MV_COMP"),GetMv("MV_NORM"))

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       cbtxt    := SPACE(10)
       cbcont   := 00
       li       := 80
       m_pag    := 01

       nMoeda := mv_par08
       cMoeda := GetMv("MV_MOEDA"+Ltrim(STR(nMoeda)))

       IF mv_par07 = 1
          titulo := OemToAnsi("ENTRADA POR FORNECEDOR  (CODIGO) - ")+cmoeda 	//STR0007 "FATURAMENTO POR CLIENTE  (CODIGO) - "
       ElseIf mv_par07 == 2
              titulo := OemToAnsi("ENTRADA POR FORNECEDOR  (RANKING) - ")+cmoeda		//STR0008 "FATURAMENTO POR CLIENTE  (RANKING) - "
       Else
          titulo := OemToAnsi("ENTRADA POR FORNECEDOR  (ESTADO) - ")+cmoeda		//STR0009 "FATURAMENTO POR CLIENTE  (ESTADO) - "
       EndIF

       cabec1 := OemToAnsi("CODIGO/LOJA RAZAO SOCIAL                              VALOR             VALOR DA          VALOR             RANKING   %   PRZ MED")
       cabec2 := OemToAnsi("                                                      SEM ICM           MERCADORIA        TOTAL                           MED PON")
       //                   999999/XX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  99,999,999,999.99 99,999,999,999.99 99,999,999,999.99 9999    99.99 999 999
       //                   0         1         2         3         4         5         6         7         8         9         10        11        12        13
       //                   012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901


       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Cria array para gerar arquivo de trabalho                    ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       aTam:=TamSX3("F1_FORNECE")
       AADD(aCampos,{ "TB_CLI"    ,"C", aTam[1], aTam[2] } )
       aTam:=TamSX3("F1_LOJA")
       AADD(aCampos,{ "TB_LOJA"   ,"C", aTam[1], aTam[2] } )
       aTam:=TamSX3("A2_EST")
       AADD(aCampos,{ "TB_EST"    ,"C", aTam[1], aTam[2] } )
       aTam:=TamSX3("F1_EMISSAO")
       AADD(aCampos,{ "TB_EMISSAO","D", aTam[1], aTam[2] } )
       AADD(aCampos,{ "TB_VALOR1 ","N", 18     , nDecs   } )		// Valores de Faturamento
       AADD(aCampos,{ "TB_VALOR2 ","N", 18     , nDecs   } )
       AADD(aCampos,{ "TB_VALOR3 ","N", 18     , nDecs   } )
       AADD(aCampos,{ "TB_VALOR4 ","N", 18     , nDecs   } )		// Valores para devolucao
       AADD(aCampos,{ "TB_VALOR5 ","N", 18     , nDecs   } )
       AADD(aCampos,{ "TB_VALOR6 ","N", 18     , nDecs   } )
       AADD(aCampos,{ "TB_RANKIN ","N", 18     , 0       } )        // Ranking conforme Valor faturamento
       AADD(aCampos,{ "TB_MEDIA  ","N", 18     , 0       } ) 
       AADD(aCampos,{ "TB_MEDIA2 ","N", 18     , 0       } ) 
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Cria arquivo de trabalho                                     ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 23/12/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       //cNomArq := CriaTrab(aCampos)
       //dbUseArea( .T.,, cNomArq,cNomArq, if(.T. .OR. .F., !.F., NIL), .F. )
       cNomArq := "TMP"
       oTempTbl01 := FWTemporaryTable():New( cNomArq )
       oTempTbl01:SetFields( aCampos )
       oTempTbl01:Create()
       /********************************************************************************************************************************/
       cNomArq1 := SubStr(cNomArq,1,7)+"1"
       cNomArq2 := SubStr(cNomArq,1,7)+"2"
       cNomArq3 := SubStr(cNomArq,1,7)+"3"

       IndRegua(cNomArq,cNomArq1,"TB_CLI+TB_LOJA",,,OemToAnsi("Selecionando Registros..."))	//STR0012 "Selecionando Registros..."

       dbSelectArea("SF1")
       dbSetOrder(2)

       SetRegua(RecCount())		// Total de Elementos da regua
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Chamada da Funcao para gerar arquivo de Trabalho             ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       if mv_par09 == 3
          cKey:="D2_FILIAL+D2_SERIORI+D2_NFORI+D2_CLIENTE+D2_LOJA"
          cFiltro:="D2_FILIAL=='"+xFilial("SD2")+"'.And.!Empty(D2_NFORI)"
          #IFDEF SHELL
                 cFiltro += '.And. D2_CANCEL <> "S"'
          #ENDIF
          IndRegua("SD2",cNomArq3,cKey,,cFiltro,OemToAnsi("Selecionando Registros..."))	//STR0012"Selecionando Registros..."
          nIndex:=RetIndex("SD2")
          #IFNDEF TOP
                  dbSetIndex(cNomArq3+OrdBagExt())
          #ENDIF
          dbSetOrder(nIndex+1)
          dbGotop()
       Endif
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Grava arquivo de trabalho.             ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       GeraTrab(cEstoq,cDupli,nMoeda)

       If mv_par09 == 1
          dbSelectArea("SF2")
          dbSetOrder(2)
          IncRegua()
          GeraTrab1(cEstoq,cDupli,nMoeda)
       Endif

       dbSelectArea(cNomArq)
       dbClearIndex()

       If mv_par07 == 1

          IndRegua(cNomArq,cNomArq2,"StrZero(1000000000000 - TB_VALOR3 + TB_VALOR6,18,2)",,,OemToAnsi("Selecionando Registros..."))
          dbGoTop()
          nRank:=1
          While !Eof()
                RecLock(cNomArq,.F.)
                   Replace TB_RANKIN With nRank
                MsUnlock()
                nRank++
                dbSkip()
          Enddo
          nRank:=0

          dbClearIndex()
          IndRegua(cNomArq,cNomArq1,"TB_CLI+TB_LOJA",,,OemToAnsi("Selecionando Registros..."))
       ElseIf mv_par07 == 2
              IndRegua(cNomArq,cNomArq2,"StrZero(1000000000000 - TB_VALOR3 + TB_VALOR6,18,nDecs)",,,OemToAnsi("Selecionando Registros..."))
       Else
          IndRegua(cNomArq,cNomArq1,"TB_EST+TB_CLI+TB_LOJA",,,OemToAnsi("Selecionando Registros..."))
       Endif

       dbSelectArea(cNomArq)
       dbGoTop()

       While !Eof()
             IncRegua()

             If lEnd
                @Prow()+1,001 PSAY OemToAnsi("CANCELADO PELO OPERADOR")	//STR0013 "CANCELADO PELO OPERADOR"
                Exit
             Endif

             If li > 55
                cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
             Endif

             If mv_par07 == 3
                If Empty(cEst)
                   cEst := TB_EST
                ElseIf cEst != TB_EST
                       li++
                       @li, 00 PSAY OemToAnsi("Total do Estado de ") + cEst + "--->"	//STR0014 "Total do Estado de "
                       @li, 54 PSAY nEstV1		PicTure cPict
                       @li, 72 PSAY nEstV2		PicTure cPict
                       @li, 90 PSAY nEstV3		PicTure cPict

                       If nEstv4+nEstv5+nEstv6!=0
                          li++
                          @li, 54 PSAY nEstV4		PicTure cPict
                          @li, 72 PSAY nEstV5		PicTure cPict
                          @li, 90 PSAY nEstV6		PicTure cPict
                          //@li,129 PSAY "DEV"
                       Endif
                       cEst := TB_EST
                       li++
                       nEstV1:=0
                       nEstV2:=0
                       nEstV3:=0
                       nEstV4:=0
                       nEstV5:=0
                       nEstV6:=0
                       li++
                EndIf
                @ li,00 PSAY OemToAnsi("Estado: ") + cEst 	//STR0015 "Estado: "
                li++
             EndIf

             cCliente := TB_CLI
             cLoja    := TB_LOJA
             dbSelectArea("SA2")
             dbSetOrder(1)
             dbSeek(xFilial()+cCliente+cLoja)

             @li,00 PSAY SA2->A2_COD + "/"+ SA2->A2_LOJA
             @li,11 PSAY Substr(SA2->A2_NOME,1,40)

             dbSelectArea(cNomArq)

             nValor1:= TB_VALOR1
             nValor2:= TB_VALOR2
             nValor3:= TB_VALOR3
             nValor4:= TB_VALOR4
             nValor5:= TB_VALOR5
             nValor6:= TB_VALOR6

             nValor4*=(-1)
             nValor5*=(-1)
             nValor6*=(-1)

             @li, 54 PSAY nValor1  PICTURE cPict
             @li, 72 PSAY nValor2  PICTURE cPict
             @li, 90 PSAY nValor3  PICTURE cPict

             IF mv_par07 = 1
                nRank:=TB_RANKIN
                @li,108 PSAY nRank	PICTURE "9999"
             ELSEIF mv_par07 = 2
                    nRank++
                    @li,108 PSAY nRank	PICTURE "9999"
             EndIF

             @li,116 PSAY ((nValor3 / nTotFinal) * 100) PICTURE "@E 99.99"
             nSomTot := nSomTot + ((nValor3 / nTotFinal) * 100)
             @li,122 PSAY TB_MEDIA                      PICTURE "@E 999"
             @li,126 PSAY TB_MEDIA2                     PICTURE "@E 999"
             
             If nValor4+nValor5+nValor6!=0
                li++
                @li, 54 PSAY nValor4  PICTURE cPict
                @li, 72 PSAY nValor5  PICTURE cPict
                @li, 90 PSAY nValor6  PICTURE cPict
                //@li,129 PSAY "DEV"
             Endif

             nEstV1+= nValor1
             nEstV2+= nValor2
             nEstV3+= nValor3
             nEstV4+= nValor4
             nEstV5+= nValor5
             nEstV6+= nValor6

             li++

             nAg1 += nValor1
             nAg2 += nValor2
             nAg3 += nValor3
             nAg4 += nValor4
             nAg5 += nValor5
             nAg6 += nValor6

             dbSkip()
       EndDo

       IF li != 80
          If mv_par07 == 3
             li++
             @li, 00 PSAY OemToAnsi("Total do Estado de ") + cEst + "--->"
             @li, 54 PSAY nEstV1		PicTure cPict
             @li, 72 PSAY nEstV2		PicTure cPict
             @li, 90 PSAY nEstV3		PicTure cPict

             If (nEstV4+nEstV5+nEstV6)!=0
                li++
                @li, 54 PSAY nEstV4		PicTure cPict
                @li, 72 PSAY nEstV5		PicTure cPict
                @li, 90 PSAY nEstV6		PicTure cPict
                //@li,129 PSAY "DEV"
             Endif

             li:=li + 2
          EndIf
          li++
          @li, 00 PSAY OemToAnsi("T O T A L --->")	//STR0016 "T O T A L --->"
          @li, 54 PSAY nAg1		PicTure cPict
          @li, 72 PSAY nAg2		PicTure cPict
          @li, 90 PSAY nAg3		PicTure cPict
          @li,115 PSAY nSomTot  PicTure "@E 999.99"
          @li,122 PSAY (nTotMedio / nQtdMedio) PicTure "@E 999"
          @li,126 PSAY nSomG    Picture "@E 999"
          
          If (nAg4+nAg5+nAg6)!=0
             li++
             @li, 54 PSAY nAg4		PicTure cPict
             @li, 72 PSAY nAg5		PicTure cPict
             @li, 90 PSAY nAg6		PicTure cPict
             //@li,129 PSAY "DEV"
          Endif

          roda(cbcont,cbtxt)
       EndIF

       dbSelectArea(cNomArq)
       dbCloseArea()
       oTempTbl01:Delete()

       cDelArq := cNomArq+GetDBExtension()

       If File(cDelArq)
          fErase(cDelArq)
       Endif
       fErase(cNomArq1+OrdBagExt())
       If mv_par07 <> 3
          Ferase(cNomarq2+OrdBagExt())
       EndIF
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Restaura a integridade dos dados                             ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       If mv_par09 == 3
          dbSelectArea("SD2")
          Set Filter To
          RetIndex()
          fErase(cNomArq3+OrdBagExt())
          dbSetOrder(1)
       Endif

       dbSelectArea("SF2")
       Set Filter To
       dbSetOrder(1)
       dbSelectArea("SD2")
       dbSetOrder(1)

       If aReturn[5] == 1
          Set Printer TO
          dbCommitAll()
          ourspool(wnrel)
       Endif
       MS_FLUSH()
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GeraTrab  ³ Autor ³ Wagner Xavier         ³ Data ³ 10.01.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera arquivo de Trabalho para emissao de Estat.de Fatur.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GeraTrab()                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static FuncTion GeraTrab(cEstoq,cDupli,nMoeda)
       Local _nY, _nX, nY
       //Local cChaven    := ""
       Local nTOTAL     := 0
       Local nVALICM    := 0
       Local nVALIPI    := 0
       //Local ImpNoInc   := 0    
       Local nImpInc    := 0    
       Local nTB_VALOR1 := 0
       Local nTB_VALOR2 := 0
       Local nTB_VALOR3 := 0
       Local aImpostos  := {}
       Local lAvalTes   := .F.
       Local _lVerCpoM  := Type("SF1->F1_TXMOEDA")#"U"

       Private cCampImp
       
       dbSelectArea("SF1")
       dbSeek(xFilial()+mv_par03,.T.)

       While !Eof() .And. xFilial()=SF1->F1_FILIAL .And.;
             SF1->F1_FORNECE <= mv_par04

             dbSelectArea("SA2")
             dbSetOrder(1)
             dbSeek ( xFilial() + SF1->F1_FORNECE+SF1->F1_LOJA )
             dbSelectArea("SF1")

             #IFDEF SHELL
                    If SF1->F1_CANCEL == "S"
                       SF1->(dbSkip())
                       Loop
                    Endif
             #ENDIF

             IF mv_par14 == 2
                IF SF1->F1_FORNECE $ "00401 .00354 "
                   SF1->(DbSkip())
                   Loop
                Endif
             Endif
             IF SF1->F1_EMISSAO < mv_par01 .Or. SF1->F1_EMISSAO > mv_par02 .Or.;
                SA2->A2_EST 	 < mv_par05 .Or. SA2->A2_EST     > mv_par06
                dbSkip()
                Loop
             EndIF

             If At(SF1->F1_TIPO,"DB") != 0
                Dbskip()
                Loop
             Endif

             IncRegua()

             dbSelectArea("SD1")
             dbSetOrder(1)
             dbSeek(xFilial()+SF1->F1_DOC+SF1->F1_SERIE)
             nTOTAL 		:=0
             nVALICM		:=0
             nVALIPI		:=0
             nImpNoInc	:=0
             nImpInc  	:=0
             lAvalTes    := .F.
             While !Eof() .And. xFilial()==SD1->D1_FILIAL .And.;
                   SD1->D1_DOC+SD1->D1_SERIE == SF1->F1_DOC+SF1->F1_SERIE .And.;
                   SD1->D1_TP >= mv_par12 .and. SD1->D1_TP <= mv_par13
                   IF !(SD1->D1_FORNECE+SD1->D1_LOJA == SF1->F1_FORNECE+SF1->F1_LOJA)
                      DbSkip()
                      Loop
                   Endif
                   #IFDEF SHELL
                          If SD1->D1_CANCEL == "S" .Or. !(Substr(SD1->D1_CF,2,2)$"12|73|74")
                             SD1->(dbSkip())
                             Loop
                          Endif
                   #ENDIF

                   dbSelectArea("SF4")
                   dbSeek(xFilial()+SD1->D1_TES)

                   dbSelectArea("SD1")

                   If AvalTes(D1_TES,cEstoq,cDupli)

                      lAvalTes := .T.
                      /*** Substituido em 08/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
                      //If cPaisLoc <> "BRA" .and. Type("SF1->F1_TXMOEDA")#"U"
                      If cPaisLoc <> "BRA" .and. _lVerCpoM
                         nTOTAL  += xMoeda(SD1->D1_TOTAL,SF1->F1_MOEDA,nMoeda,SF1->F1_EMISSAO,nDecs+1,SF1->F1_TXMOEDA)
                      Else
                         nTOTAL  += xMoeda(SD1->D1_TOTAL,1,nMoeda,SF1->F1_EMISSAO,nDecs+1)
                      Endif
                      If ( cPaisLoc=="BRA")
                         nVALICM += xMoeda(SD1->D1_VALICM,1,nMoeda,SF1->F1_EMISSAO)
                         nVALIPI += xMoeda(SD1->D1_VALIPI,1,nMoeda,SF1->F1_EMISSAO)
                      Else
                         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                         //³ Pesquiso pelas caracteristicas de cada imposto               ³
                         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                         aImpostos:=TesImpInf(SD1->D1_TES)
                         For nY:=1 to Len(aImpostos)
                             cCampImp:="SD1->"+(aImpostos[nY][2])
                             If ( aImpostos[nY][3]=="1" )
                                nImpInc 	+= xMoeda(&cCampImp,SF1->F1_MOEDA,nMoeda,SF1->F1_EMISSAO,nDecs+1,SF1->F1_TXMOEDA)
                             Else
                                nImpNoInc 	+= xmoeda(&cCampImp,SF1->F1_MOEDA,nMoeda,SF1->F1_EMISSAO,nDecs+1,SF1->F1_TXMOEDA)
                             Endif
                         Next
                      EndIf
                   Endif

                   dbSelectArea("SD1")
                   dbSkip()
             EndDo

             dbSelectArea("SF1")

             If lAvalTes
                nTOTAL  += xMoeda(SF1->F1_FRETE+SF1->F1_SEGURO+SF1->F1_DESPESA,1,nMoeda,SF1->F1_EMISSAO)
             Endif

             If nTOTAL > 0
                dbSelectArea(cNomArq)
                If dbSeek(SF1->F1_FORNECE+SF1->F1_LOJA,.F.)
                   RecLock(cNomArq,.F.)
                Else
                   RecLock(cNomArq,.T.)
                      Replace TB_CLI     With SF1->F1_FORNECE
                      Replace TB_LOJA    With SF1->F1_LOJA
                EndIF
                Replace TB_EST     With SA2->A2_EST
                Replace TB_EMISSAO With SF1->F1_EMISSAO

                nTB_VALOR2 := IIF(SF1->F1_TIPO == "P",0,nTOTAL)
                If ( cPaisLoc=="BRA" )
                   nTB_VALOR1 := nTOTAL-nVALICM
                   nTB_VALOR3 := IIF(SF1->F1_TIPO == "P",0,nTOTAL);
                   + nVALIPI+xMoeda(SF1->F1_ICMSRET+SF1->F1_FRETE,1,nMoeda,SF1->F1_EMISSAO)
                Else
                   nTB_VALOR1 := nTOTAL-nImpNoInc
                   nTB_VALOR3 := IIF(SF1->F1_TIPO == "P",0,nTOTAL)+ nImpInc+xMoeda(SF1->F1_FRETAUT,SF1->F1_MOEDA,nMoeda,SF1->F1_EMISSAO,nDecs+1,SF1->F1_TXMOEDA)
                EndIf

                Replace TB_VALOR1  With TB_VALOR1+ nTB_VALOR1
                Replace TB_VALOR2  With TB_VALOR2+ nTB_VALOR2
                Replace TB_VALOR3  With TB_VALOR3+ nTB_VALOR3
                
                DbSelectArea("SE4")
                DbSetOrder(1)
                DbSeek(xFilial("SE4")+SF1->F1_COND,.t.)
                If Found()
                   cAux := Alltrim(SE4->E4_COND)
                   nAux := 0
                   nVez := 0
                   While Len(cAux) > 0
                       nAux := nAux + Val(SubString(cAux,1,If(At(",",cAux)==0,Len(cAux),(At(",",cAux) - 1))))
                       cAux := AllTrim(If(At(",",cAux)==0,"",stuff(cAux,1,3,"")))
                       nVez := nVez + 1
                   Enddo
                Else
                   nAux := 0
                   nVez := 1
                Endif
                aadd(aMedia,{ SF1->F1_FORNECE, SF1->F1_LOJA, Alltrim(SE4->E4_COND), nVez, nAux, nTB_VALOR3 } )
                nAux := (nAux / nVez)
                dbSelectArea(cNomArq)
                Replace TB_MEDIA  With Iif(TB_MEDIA == 0, nAux, ((nAux + TB_MEDIA) / 2) )
                //Replace TB_MEDIA2 With Iif(TB_MEDIA == 0, nAux, ((nAux + TB_MEDIA) / 2) )
                // Sergio Fuzinaka - 16.10.01
                If Ascan( aCodCli, SF1->F1_FORNECE+SF1->F1_LOJA ) == 0
                   Aadd( aCodCli, SF1->F1_FORNECE+SF1->F1_LOJA )
                Endif

                MsUnlock()

                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Grava Devolucao ref a Nota Fiscal posicionada                ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                If mv_par09 == 3
                   GravaDev(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,nMoeda,cEstoq,cDupli)
                Endif
             Endif
             
             dbSelectArea("SF1")
             dbSkip()
       EndDo
       dbSelectArea(cNomArq)
       DbGoTop()
       While !Eof()
             nTotFinal := nTotFinal + TB_VALOR3
             nTotMedio := nTotMedio + TB_MEDIA
             nQtdMedio := nQtdMedio + 1
             dbSelectArea(cNomArq)
             DbSkip()
       Enddo
       //                     1                2                     3        4     5        6
       //aadd(aMedia,{ SF1->F1_FORNECE, SF1->F1_LOJA, Alltrim(SE4->E4_COND), nVez, nAux, nTB_VALOR3 } )
       aSort(aMedia ,,,{|x,y| x[1] < y[1] })
       nSom3 := 0
       nSom4 := 0
       nSomG := 0
       For _nx := 1 to Len(aMedia)
           nSom1 := 0
           nSom2 := 0
           nSomf := 0
           nSomM := 0
           nVez  := 0
           nSom3 := nSom3 + (aMedia[_nx][6] * aMedia[_nx][5])
           nSom4 := nSom4 + (aMedia[_nx][6] * aMedia[_nx][4])
           nVez  := 0
           For _ny := 1 to Len(aMedia)
               If aMedia[_nx][1] == aMedia[_ny][1] .and. aMedia[_nx][2] == aMedia[_ny][2]
                  nSom1 := nSom1 + (aMedia[_ny][6] * aMedia[_ny][5])
                  nSom2 := nSom2 + (aMedia[_ny][6] * aMedia[_ny][4])
                  nSomM := nSomM + Iif(aMedia[_ny][4] > 1, (aMedia[_ny][5] / aMedia[_ny][4]), aMedia[_ny][5])
                  nVez  := nVez  + 1
               Endif
           Next
           nSomM := nSomM / nVez
           nSomF := nSomF + (nSom1 / nSom2)
           DbSelectArea(cNomArq) 
           DbSetOrder(1)
           DbSeek(aMedia[_nx][1]+aMedia[_nx,2],.t.)
           If Found()
              RecLock(cNomArq,.f.)
                 TB_MEDIA  := nSomM
                 TB_MEDIA2 := nSomF
              MsUnLock()
           Else
              RecLock(cNomArq,.f.)
                 TB_MEDIA2 := 0
              MsUnLock()
           Endif
       Next
       nSomG := (nSom3 / nSom4)
Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GeraTrab1 ³ Autor ³ Adriano Sacomani      ³ Data ³ 09.08.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera arquivo de Trabalho para emissao de Estat.de Fatur.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GeraTrab1)                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static FuncTion GeraTrab1(cEstoq,cDupli,nMoeda)
       Local nTOTAL     := 0
       Local nVALICM    := 0
       Local nVALIPI    := 0
       Local nImpNoInc  := 0
       Local nImpInc    := 0
       Local nTB_VALOR4 := 0
       Local nTB_VALOR5 := 0
       Local nTB_VALOR6 := 0
       Local aImpostos	 := {}
       Local lAvalTes   := .F.
       Local nY

       dbSeek(xFilial()+mv_par03,.T.)
       While !Eof() .And. xFilial()==F2_FILIAL .And. F2_CLIENTE <= mv_par04

             #IFDEF SHELL
                    If SF2->F2_CANCEL == "S"
                       SF2->(dbSkip())
                       Loop
                    Endif
             #ENDIF

             dbSelectArea("SA2")
             dbSetOrder(1)
             dbSeek( xFilial() + SF2->F2_CLIENTE + SF2->F2_LOJA)
             dbSelectArea("SF2")

             If SF2->F2_EMISSAO < mv_par01 .Or. SF2->F2_EMISSAO > mv_par02 .Or.;
                SA2->A2_EST     < mv_par05 .Or. SA2->A2_EST     > mv_par06
                dbSkip()
                Loop
             EndIf

             If SF2->F2_TIPO != "D"
                Dbskip()
                Loop
             Endif

             IncRegua()

             dbSelectArea("SD2")
             dbSetOrder(1)
             dbSeek(xFilial()+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
             nTOTAL 		:=0.00
             nVALICM		:=0.00
             nVALIPI		:=0.00
             nImpNoInc	:=0.00
             nImpInc 	:=0.00
             lAvalTes    := .F.

             dbSelectArea("SF4")
             dbSeek(xFilial()+SD2->D2_TES)
             dbSelectArea("SD2")

             While !Eof() .and. xFilial()==SD2->D2_FILIAL .And.;
                   SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA ==;
                   SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA .And.;
                   SD2->D2_TP >= mv_par12 .and. SD2->D2_TP <= mv_par13

                   If SD2->D2_TIPO != "D"
                      dbSkip()
                      Loop
                   Endif

                   #IFDEF SHELL
                          If SD2->D2_CANCEL == "S"
                             SD2->(dbSkip())
                             Loop
                          Endif
                   #ENDIF

                   dbSelectArea("SF4")
                   dbSeek(xFilial()+SD2->D2_TES)
                   dbSelectArea("SD2")

                   If AvalTes(D1_TES,cEstoq,cDupli)

                      lAvalTes := .T.

                      nTOTAL  +=xMoeda((SD2->D2_TOTAL-SD2->D2_VALDESC),SF2->F2_MOEDA,nMoeda,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)

                      If ( cPaisLoc=="BRA" )
                         nVALICM += xMoeda(SD2->D2_VALICM,1,nMoeda,SF2->F2_EMISSAO)
                         nVALIPI += xMoeda(SD2->D2_VALIPI,1,nMoeda,SF2->F2_EMISSAO)
                      Else
                         aImpostos:=TesImpInf(SD2->D2_TES)
                         For nY:=1 to Len(aImpostos)
                             cCampImp:="SD2->"+(aImpostos[nY][2])
                             If ( aImpostos[nY][3]=="1" )
                                nImpInc 	+= xmoeda(&cCampImp,SF2->F2_MOEDA,nMoeda,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
                             Else
                                nImpNoInc	+= xmoeda(&cCampImp,SF2->F2_MOEDA,nMoeda,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
                             Endif
                         Next
                      Endif

                   Endif

                   dbSelectArea("SD2")
                   dbSkip()
             EndDo

             dbSelectArea("SF2")

             If lAvalTes == .T.
                nTOTAL  += xMoeda(SF2->F2_FRETE+SF2->F2_SEGURO+SF2->F2_DESPESA,1,nMoeda,SF2->F2_EMISSAO)
             Endif

             If nTOTAL > 0
                dbSelectArea(cNomArq)
                If dbSeek(SF2->F2_CLIENTE+SF2->F2_LOJA,.F.)
                   RecLock(cNomArq,.F.)
                Else
                   RecLock(cNomArq,.T.)
                      Replace TB_CLI     With SF2->F2_CLIENTE
                      Replace TB_LOJA	 With SF2->F2_LOJA
                EndIf
                Replace TB_EST     With SA2->A2_EST
                Replace TB_EMISSAO With SF2->F2_EMISSAO

                nTB_VALOR5 := nTOTAL

                If ( cPaisLoc=="BRA")
                   nTB_VALOR4 := nTOTAL-nVALICM
                   nTB_VALOR6 := nTOTAL+nVALIPI+xMoeda(SF2->F2_ICMSRET,1,nMoeda,SF2->F2_EMISSAO)
                Else
                   nTB_VALOR4 := nTOTAL-nImpNoInc
                   nTB_VALOR6 := nTotal + nImpInc
                Endif

                Replace TB_VALOR4  With TB_VALOR4+nTB_VALOR4
                Replace TB_VALOR5  With TB_VALOR5+nTB_VALOR5
                Replace TB_VALOR6  With TB_VALOR6+nTB_VALOR6
             Endif

             dbSelectArea("SF2")
             dbSkip()

       Enddo

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GravaDev  ³Revisor³Alexandre Inacio Lemes ³ Data ³ 27/11/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava item da devolucao ref a nota fiscal posicionada.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GravaDev                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static FuncTion GravaDev(cNumOri,cSerieOri,cClienteOri,cLojaOri,nMoeda,cEstoq,cDupli)
       Local cNum        := ""
       Local cSerie      := ""
       Local cFornece    := ""
       Local cLoja       := ""
       Local cNumDocNfe  := ""
       Local nX          := 0
       Local nTOTAL      := 0
       Local nVALICM     := 0
       Local nVALIPI     := 0
       Local nImpNoInc   := 0
       Local nImpInc     := 0
       Local nTB_VALOR4  := 0
       Local nTB_VALOR5  := 0
       Local nTB_VALOR6  := 0
       Local aImpostos   := {}
       Local aNotDev     := {}
       Local lAvalTes    := .F.
       Local nY

       dbSelectArea("SD2")
       dbSetOrder(nIndex+1)
       If dbseek(xFilial()+cSerieOri+cNumOri+cClienteOri+cLojaOri,.F.)

          cNumDocNfe := SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA

          Aadd( aNotDev, cNumDocNfe )

          Do While !Eof() .And. xFilial()==SD2->D2_FILIAL .And. cSerieOri+cNumOri+cClienteOri+cLojaOri;
                   == SD2->D2_SERIORI+SD2->D2_NFORI+SD2->D2_CLIENTE+SD2->D2_LOJA

             If cNumDocNfe <> SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
                If Ascan( aCodCli, SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA) == 0
                   Aadd( aNotDev, SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA)
                   cNumDocNfe := SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
                Endif
             Endif

             dbSelectArea("SD2")
             dbSkip()
          Enddo

          dbSelectArea("SD2")
          dbSetOrder(nIndex+1)
          dbseek(xFilial()+cSerieOri+cNumOri+cClienteOri+cLojaOri,.F.)

          For nX :=1 to Len(aNotDev)

              dbSelectArea("SD2")
              cNum		:=D1_DOC
              cSerie	    :=D1_SERIE
              cFornece	:=D1_FORNECE
              cLoja		:=D1_LOJA

              dbSelectArea("SA2")
              dbSetOrder(1)
              dbSeek( xFilial() + cFornece + cLoja)
              dbSelectArea("SF2")
              dbSetOrder(1)

              If dbSeek(aNotDev[nX])

                 dbSelectArea("SD2")
                 dbSetOrder(1)
                 dbSeek(aNotDev[nX])

                 dbSelectArea("SF2")
                 dbSetOrder(1)
                 If SF2->F2_EMISSAO < mv_par01 .Or. SF2->F2_EMISSAO > mv_par02 .Or.;
                    SA2->A2_EST < mv_par05 .Or. SA2->A2_EST > mv_par06 .Or. SF2->F2_TIPO != "D"
                    SD2->(dbSkip())
                    Loop
                 EndIf

                 #IFDEF SHELL
                        If SF2->F2_CANCEL == "S"
                           SD2->(dbSkip())
                           Loop
                        Endif
                 #ENDIF

                 nTOTAL 		:=0.00
                 nVALICM		:=0.00
                 nVALIPI		:=0.00
                 nImpNoInc	:=0.00
                 nImpInc 	:=0.00
                 lAvalTes    := .F.

                 dbSelectArea("SF4")
                 dbSeek(xFilial()+SD2->D2_TES)
                 dbSelectArea("SD2")

                 While !Eof() .and. xFilial()==SD2->D2_FILIAL .And.SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA ==SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA

                       If SD2->D2_TIPO != "D"
                          dbSkip()
                          Loop
                       Endif

                       #IFDEF SHELL
                              If SD2->D2_CANCEL == "S"
                                 SD2->(dbSkip())
                                 Loop
                              Endif
                       #ENDIF

                       dbSelectArea("SF4")
                       dbSeek(xFilial()+SD2->D2_TES)

                       If AvalTes(SD2->D2_TES,cEstoq,cDupli)

                          lAvalTes := .T.

                          dbSelectArea(cNomArq)
                          nTOTAL  +=xMoeda((SD2->D2_TOTAL-SD2->D2_VALDESC),SF2->F2_MOEDA,nMoeda,TB_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
                          If ( cPaisLoc=="BRA" )
                             nVALICM += xMoeda(SD2->D2_VALICM,1,nMoeda,TB_EMISSAO)
                             nVALIPI += xMoeda(SD2->D2_VALIPI,1,nMoeda,TB_EMISSAO)
                          Else
                             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                             //³ Pesquiso pelas caracteristicas de cada imposto               ³
                             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                             aImpostos:=TesImpInf(SD2->D2_TES)
                             For nY:=1 to Len(aImpostos)
                                 cCampImp:="SD2->"+(aImpostos[nY][2])
                                 If ( aImpostos[nY][3]=="1" )
                                    nImpInc 	+= xmoeda(&cCampImp,SF2->F2_MOEDA,nMoeda,TB_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
                                 Else
                                    nImpNoInc	+= xmoeda(&cCampImp,SF2->F2_MOEDA,nMoeda,TB_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
                                EndIf
                             Next
                          EndIf

                       Endif

                       dbSelectArea("SD2")
                       dbSkip()
                 EndDo

                 dbSelectArea("SF2")
                 If lAvalTes == .T.
                    nTOTAL  += xMoeda(SF2->F2_FRETE+SF2->F2_SEGURO+SF2->F2_DESPESA,1,nMoeda,SF2->F2_EMISSAO)
                 Endif

                 If nTOTAL > 0
                    dbSelectArea(cNomArq)
                    If dbSeek(SF2->F2_CLIENTE+SF2->F2_LOJA,.F.)
                       RecLock(cNomArq,.F.)
                    Else
                       RecLock(cNomArq,.T.)
                          Replace TB_CLI     With SF2->F2_CLIENTE
                          Replace TB_LOJA	 With SF2->F2_LOJA
                    EndIf

                    Replace TB_EST     With SA2->A2_EST
                    Replace TB_EMISSAO With SF2->F2_EMISSAO

                    nTB_VALOR5 := nTOTAL
                    If ( cPaisLoc=="BRA" )
                       nTB_VALOR4 := nTOTAL-nVALICM
                       nTB_VALOR6 := nTOTAL+nVALIPI+xMoeda(SF2->F2_ICMSRET,1,nMoeda,SF2->F2_EMISSAO)
                    Else
                       nTB_VALOR4 := nTOTAL-nImpInc
                       nTB_VALOR6 := nTotal+nImpInc
                    Endif

                    Replace TB_VALOR4  With TB_VALOR4+nTB_VALOR4
                    Replace TB_VALOR5  With TB_VALOR5+nTB_VALOR5
                    Replace TB_VALOR6  With TB_VALOR6+nTB_VALOR6
                 EndIf

              Endif

          Next nX

       endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ VALPERG  º Autor ³ AP5 IDE            º Data ³  17/09/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Verifica a existencia das perguntas criando-as caso seja   º±±
±±º          ³ necessario (caso nao existam).                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValPerg()
       Local _sAlias := Alias()
       Local aRegs := {}
       Local i,j

       dbSelectArea("SX1")
       dbSetOrder(1)
       cPerg := PADR(cPerg, 10, " ")
       
       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs,{cPerg,"01","Data de             ","","","mv_ch1","D",08,0,0,"G","","mv_par01",""               ,"","","","",""             ,"","","","",""               ,"","","","",""        ,"","","","",""        ,"","","",""   ,"",""})
       aAdd(aRegs,{cPerg,"02","Data ate            ","","","mv_ch2","D",08,0,0,"G","","mv_par02",""               ,"","","","",""             ,"","","","",""               ,"","","","",""        ,"","","","",""        ,"","","",""   ,"",""})
       aAdd(aRegs,{cPerg,"03","Fornecedor De       ","","","mv_ch3","C",06,0,0,"G","","mv_par03",""               ,"","","","",""             ,"","","","",""               ,"","","","",""        ,"","","","",""        ,"","","","SA2","","001"})
       aAdd(aRegs,{cPerg,"04","Fornecedor Ate      ","","","mv_ch4","C",06,0,0,"G","","mv_par04",""               ,"","","","",""             ,"","","","",""               ,"","","","",""        ,"","","","",""        ,"","","","SA2","","001"})
       aAdd(aRegs,{cPerg,"05","Estado de           ","","","mv_ch5","C",02,0,0,"G","","mv_par05",""               ,"","","","",""             ,"","","","",""               ,"","","","",""        ,"","","","",""        ,"","","","12" ,"",""})
       aAdd(aRegs,{cPerg,"06","Estado Ate          ","","","mv_ch6","C",02,0,0,"G","","mv_par06",""               ,"","","","",""             ,"","","","",""               ,"","","","",""        ,"","","","",""        ,"","","","12" ,"",""})
       aAdd(aRegs,{cPerg,"07","Lista por           ","","","mv_ch7","N",01,0,1,"C","","mv_par07","Fornecedor"     ,"","","","","Ranking"      ,"","","","","Estado"         ,"","","","",""        ,"","","","",""        ,"","","",""   ,"",""})
       aAdd(aRegs,{cPerg,"08","Qual a Moeda        ","","","mv_ch8","N",01,0,1,"C","","mv_par08","1ªMoeda"        ,"","","","","2ª Moeda"     ,"","","","","3ª Moeda"       ,"","","","","4ª Moeda","","","","","5ª Moeda","","","",""   ,"",""})
       aAdd(aRegs,{cPerg,"09","Inclui Devolucao    ","","","mv_ch9","N",01,0,1,"C","","mv_par09","Sim"            ,"","","","","Nao"          ,"","","","",""               ,"","","","",""        ,"","","","",""        ,"","","",""   ,"",""})
       aAdd(aRegs,{cPerg,"10","TES Qto Entrada     ","","","mv_cha","N",01,0,3,"C","","mv_par10","Gera Financeiro","","","","","Nao Gera"     ,"","","","","Considera Ambas","","","","",""        ,"","","","",""        ,"","","",""   ,"",""})
       aAdd(aRegs,{cPerg,"11","TES Qto Estoque     ","","","mv_chb","N",01,0,3,"C","","mv_par11","Movimente"      ,"","","","","Nao Movimenta","","","","","Considera Ambas","","","","",""        ,"","","","",""        ,"","","",""   ,"",""})
       aAdd(aRegs,{cPerg,"12","Tipo Material De    ","","","mv_chc","C",02,0,0,"G","","mv_par12",""               ,"","","","",""             ,"","","","",""               ,"","","","",""        ,"","","","",""        ,"","","","02" ,"",""})
       aAdd(aRegs,{cPerg,"13","Tipo Material Ate   ","","","mv_chd","C",02,0,0,"G","","mv_par13",""               ,"","","","",""             ,"","","","",""               ,"","","","",""        ,"","","","",""        ,"","","","02" ,"",""})
       aAdd(aRegs,{cPerg,"14","Considera Transfer. ","","","mv_che","N",01,0,1,"C","","mv_par14","Sim"            ,"","","","","Nao"          ,"","","","",""               ,"","","","",""        ,"","","","",""        ,"","","",""   ,"",""})       
       
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
