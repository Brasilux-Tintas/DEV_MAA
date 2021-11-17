#include "protheus.ch"
#include "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFATR01 º Autor ³ Luís G. de Souza   º Data ³  03/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rancking Cliente x periodo.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRFATR01()
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Declaracao de Variaveis                                             ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "Rancking de Clientes x periodo"
     Local titulo        := "Rancking de Clientes x periodo"
     Local nLin          := 80                                                                                                                    
	/*
							"   0        1           2          3        4         5         6         7        8          9          10
     						"012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	*/     						
     Local Cabec1        := "CLIENTE                                       VAL. MERC.      VAL. IPI      VAL. ST.     VAL. BRUTO RANCKING LIQUIDEZ"
     Local Cabec2        := ""
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     Private CbTxt       := ""
     Private limite      := 132
     Private tamanho     := "M"
     Private nomeprog    := "BRAFATR01" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 18
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := "FATR01"
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRFATR01" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString     := "SD2"
        
  if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 

     DbSelectArea("SD2")
     DbSetOrder(1)
     //VldPerg()
     Pergunte(cPerg, .F.)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Monta a interface padrao com o usuario...                           ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     wnrel := SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho, , .F.)

     If nLastKey == 27
        Return
     Endif

     SetDefault(aReturn,cString)

     If nLastKey == 27
        Return
     Endif

     nTipo := If(aReturn[4] == 1, 15, 18)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     Processa({|| RunReport(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  31/01/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RunReport(Cabec1, Cabec2, Titulo, nLin)

       Local cQry1
       DbSelectArea(cString)
       DbSetOrder(1)

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ SETREGUA -> Indica quantos registros serao processados para a regua ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       cQry1 := "SELECT "
       If mv_par05 > 0
          cQry1 += "TOP "+Str(mv_par05)+" "
       Endif   
		cQry1 += "SD2.D2_CLIENTE, MAX(SA1.A1_NOME) AS A1_NOME, SUM(SD2.D2_TOTAL) AS D2_TOTAL, "+;
		"SUM(SD2.D2_VALIPI) AS D2_VALIPI, SUM(SD2.D2_ICMSRET) AS D2_ICMSRET, SUM(SD2.D2_VALBRUT) AS D2_VALBRUT,MAX(A1_LIQUID) AS INDLIQ "
       cQry1 += "FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH(NOLOCK) ON SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND SA1.A1_COD = SD2.D2_CLIENTE AND SA1.D_E_L_E_T_ = '' "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH(NOLOCK) ON (SF4.F4_FILIAL = '"+xFilial("SF4")+"') AND SF4.F4_CODIGO = SD2.D2_TES AND SF4.D_E_L_E_T_ = '' "
       cQry1 += "WHERE (SD2.D_E_L_E_T_ = '') AND (SD2.D2_FILIAL  = '"+xFilial("SD2")+"') AND (SF4.F4_DUPLIC <> 'N') " 
       	if !empty(MV_PAR06)  
	       cQry1 += "AND (LEN(D2_COD) = 12) AND "+U_ParamSql("SUBSTRING(D2_COD,4,2)",MV_PAR06)+" "
	  	endif    
       cQry1 += "  AND SD2.D2_EMISSAO BETWEEN '"+dTos(mv_par01)+"' AND '"+dTos(mv_par02)+"' "
       cQry1 += "  AND SD2.D2_CLIENTE BETWEEN '"+mv_par03+"' AND '"+mv_par04+"'
       cQry1 += "  AND (A1_CGC <> '"+ALLTRIM(SM0->M0_CGC)+"') "
       cQry1 += "  AND (D2_TIPO = 'N') "
       cQry1 += "GROUP BY D2_CLIENTE "
       cQry1 += "ORDER BY D2_VALBRUT DESC "
       TCQuery cQry1 ALIAS "TCQ" NEW

       ProcRegua(Iif(mv_par05 > 0, mv_par05, 18000))
       DbGoTop()
       nRancking := 1
       nValmerc  := 0
       nValIcms  := 0
       nValIPI   := 0
       nValICMSt := 0
       nValBrut  := 0
       While !EOF()
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Verifica o cancelamento pelo usuario...                             ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If lAbortPrint
               @ nLin,000 PSAY "*** CANCELADO PELO OPERADOR ***"
               Exit
            Endif
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Impressao do cabecalho do relatorio. . .                            ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
               nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
               nLin += 1
            Endif

            @ nLin, 000 PSAY TCQ->D2_CLIENTE+'-'+SubStr(TCQ->A1_NOME, 1, 30)
            @ nLin, 042 PSAY TransForm(TCQ->D2_TOTAL  , "@E 999,999,999.99")
            @ nLin, 057 PSAY TransForm(TCQ->D2_VALIPI , "@E  99,999,999.99")
            @ nLin, 071 PSAY TransForm(TCQ->D2_ICMSRET, "@E  99,999,999.99")
            @ nLin, 085 PSAY TransForm(TCQ->D2_VALBRUT, "@E 999,999,999.99")
            @ nLin, 103 PSAY TransForm(nRancking, "@E 99999")
            @ nLin, 111 PSAY TransForm(TCQ->INDLIQ, "@E 999.99")
            nValMerc  += TCQ->D2_TOTAL
            nValIPI   += TCQ->D2_VALIPI
            nValICMSt += TCQ->D2_ICMSRET
            nValBrut  += TCQ->D2_VALBRUT
            nRancking += 1
            nLin      += 1 // Avanca a linha de impressao
            DbSelectArea("TCQ")
            DbSkip()       // Avanca o ponteiro do registro no arquivo
      EndDo
      DbSelectArea("TCQ")
      DbCloseArea()
      @ nLin, 000 PSAY Repl("-", 132)
      nLin      += 1 // Avanca a linha de impressao
      @ nLin, 042 PSAY TransForm(nValMerc , "@E 999,999,999.99")
      @ nLin, 057 PSAY TransForm(nValIPI  , "@E  99,999,999.99")
      @ nLin, 071 PSAY TransForm(nValIcmSt, "@E  99,999,999.99")
      @ nLin, 085 PSAY TransForm(nValBrut , "@E 999,999,999.99")

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Finaliza a execucao do relatorio...                                 ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

      SET DEVICE TO SCREEN

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Se impressao em disco, chama o gerenciador de impressao...          ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

      If aReturn[5]==1
         dbCommitAll()
         SET PRINTER TO
         OurSpool(wnrel)
      Endif

      MS_FLUSH()

Return

/*******************************************************************************/
/*** VLDPERG - Ajusta perguntas com o SX1.                                   ***/
/*******************************************************************************/
/*
Static Function VldPerg() 

       Local aHelp := {}, aHelp1 := {} ; Local aHelp2 := {} ; Local aHelp3 := {} ; Local aHelp4 := {} ; Local aHelp5 := {}
       aAdd( aHelp1, "Informe o periodo desejado para a  " )
       aAdd( aHelp1, "emissão do relatório.              " )
       aAdd( aHelp2, "Informe o código do cliente.       " )
       aAdd( aHelp3, "Informe a quantidade de clientes p/" )
       aAdd( aHelp3, "sairem no rancking.                " )

//            Texto do help em português    , inglês, espanhol
AAdd(aHelp, {{"Informe a Linha de Produto"},  {"Informe a Linha de Produto"}, {"Informe a Linha de Produto"}})
       
     //PutSx1(cGrupo  , cOrdem,   cPergunt            , cPerSpa, cPerEng, cVar    , cTipo, nTamanho, nDecimal, nPresel, cGSC, cValid, cF3, cGrpSxg, cPyme, cVar01    , cDef01, cDefSpa1, cDefEng1, cCnt01, cDef02, cDefSpa2, cDefEng2, cDef03, cDefSpa3, cDefEng3, cDef04, cDefSpa4, cDefEng4, cDef05,  cDefSpa5,  cDefEng5, aHelpPor, aHelpEng, aHelpSpa, cHelp    )
       PutSX1("FATR01    ", "01"  ,   "Do Periodo        ", ""     , ""     , "mv_ch1", "D"  , 8       , 0       , 0      , "G" , " "   , "   ", " "    , " "  , "mv_par01", " " , " "     , " "     , " "   , " "   , " "     , " "     , " "   , " "     , " "     , " "   , " "     , " "     , " "   ,  " "     ,  " "     , aHelp1  , Nil     , Nil     , ".FATR0101." )
       PutSX1("FATR01    ", "02"  ,   "Até Periodo       ", ""     , ""     , "mv_ch2", "D"  , 8       , 0       , 0      , "G" , " "   , "   ", " "    , " "  , "mv_par02", " " , " "     , " "     , " "   , " "   , " "     , " "     , " "   , " "     , " "     , " "   , " "     , " "     , " "   ,  " "     ,  " "     , aHelp1  , Nil     , Nil     , ".FATR0102." )
       PutSX1("FATR01    ", "03"  ,   "Do Cliente        ", ""     , ""     , "mv_ch3", "C"  , 6       , 0       , 0      , "G" , " "   , "CLI", " "    , " "  , "mv_par03", " " , " "     , " "     , " "   , " "   , " "     , " "     , " "   , " "     , " "     , " "   , " "     , " "     , " "   ,  " "     ,  " "     , aHelp2  , Nil     , Nil     , ".FATR0103." )
       PutSX1("FATR01    ", "04"  ,   "Até Cliente       ", ""     , ""     , "mv_ch4", "C"  , 6       , 0       , 0      , "G" , " "   , "CLI", " "    , " "  , "mv_par04", " " , " "     , " "     , " "   , " "   , " "     , " "     , " "   , " "     , " "     , " "   , " "     , " "     , " "   ,  " "     ,  " "     , aHelp2  , Nil     , Nil     , ".FATR0104." )
       PutSX1("FATR01    ", "05"  ,   "Qtde. Clientes    ", ""     , ""     , "mv_ch5", "N"  , 5       , 0       , 0      , "G" , " "   , " "  , " "    , " "  , "mv_par05", " " , " "     , " "     , " "   , " "   , " "     , " "     , " "   , " "     , " "     , " "   , " "     , " "     , " "   ,  " "     ,  " "     , aHelp3  , Nil     , Nil     , ".FATR0105." )
	   PutSX1("FATR01    ","06","Linha(s) Produto"    ,"Linha(s) Produto","Linha(s) Produto","mv_ch6","C",99,00,00,"G","","","","","mv_Par06","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")

	

Return
*/