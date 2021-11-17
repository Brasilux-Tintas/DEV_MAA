#include "rwmake.ch"
#include "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFATR02 º Autor ³ Luís G. de Souza   º Data ³  07/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ultimo preço pago por produto x cliente x representante.   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRFATR02()
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "ULTIMO PREÇO PAGO X CLIENTE X REPRESENTANTE"
     Local titulo        := "ULTIMO PREÇO PAGO X CLIENTE X REPRESENTANTE"
     Local nLin          := 80
     Local Cabec1        := "       PRODUTO         DESCRIÇÃO                 QUANTIDADE      PREÇO"
     Local Cabec2        := ""
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     Private limite      := 80
     Private tamanho     := "P"
     Private nomeprog    := "BRFATR02" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 18
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := "FATR02"
     Private cbtxt       := Space(10)
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRFATR02" // Coloque aqui o nome do arquivo usado para impressao em disco

     Private cString := "SA1"
     
     If !u_VldAcesso(funname())
        MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
        return 
     Endif 

     DbSelectArea("SA1")
     DbSetOrder(1)
     
     //ValPerg(cPerg)
     Pergunte(cPerg,.F.)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Monta a interface padrao com o usuario...                           ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

     If nLastKey == 27
        Return
     Endif

     SetDefault(aReturn,cString)

     If nLastKey == 27
        Return
     Endif

     nTipo := If(aReturn[4]==1,15,18)

     Processa({|| FATR02_1(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ FATR02_1 º Autor ³ Luís G. de Souza   º Data ³  07/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function FATR02_1(Cabec1, Cabec2, Titulo, nLin)
       
       Local cQry1 := ""
       Local cQry2 := ""
       Local cQry3 := ""
       Local lPriVez :=.T.
       Local lImpCli :=.T.
       
       cQry1 := ""
       cQry1 += "SELECT A1_COD "
       cQry2 += "SELECT COUNT(R_E_C_N_O_) AS QTDREC "
       cQry3 += "FROM "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) "
       cQry3 += "WHERE SA1.A1_FILIAL  = '"+xFilial("SA1")+"' "
       cQry3 += "  AND SA1.D_E_L_E_T_ = '' "
		//Chamado 007514, tirar códigos de repres. especificos do Glaidon 
	   if __cUserId = "000282"
	       cQry3 += "AND (A1_VEND NOT IN ('000250','000444','000303','000333','000438','000276')) "
	   endif 
       If mv_par01 == 1
           cQry3 += "  AND SA1.A1_VEND    = '"+mv_par02+"' "
       Else
           cQry3 += "  AND SA1.A1_COD     = '"+mv_par03+"' "
       Endif
	   IF !empty(MV_PAR09)
	       cQry3 +="AND ((A1_SATIV2 = '') OR ("+U_ParamSql("A1_SATIV2",MV_PAR09)+")) "
	   ENDIF
	   if !empty(MV_PAR10)
	       cQry3 += "AND ("+U_ParamSql("A1_EST",MV_PAR10)+") "
	   endif
       cQry1 += cQry3
       cQry2 += cQry3
       cQry1 += "ORDER BY A1_COD "
       TCQuery cQry1 ALIAS "TCQ" NEW
       TCQuery cQry2 ALIAS "QTD" NEW
       DbSelectArea("QTD")
       DbGoTop()
       
       ProcRegua(QTD->QTDREC)
       DbSelectArea("QTD")
       DbCloseArea()
       
       lPriVez := .t.
       
       DbSelectArea("TCQ")
       DbGoTop()
       While !EOF()
             If lAbortPrint
                @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
                Exit
             Endif
             If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
                nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                nLin += 1
             Endif
             If lPriVez
                If mv_par01 == 1
                   @ nLin, 000 PSAY "REPRESENTANTE: "+mv_par02+' - '+Posicione("SA3", 1, xFilial("SA3")+mv_par02, "A3_NOME")
                     nLin += 1
                   @ nLin, 000 PSAY Replicate('—', 80)
                     nLin += 1
                Else
                   @ nLin, 000 PSAY "CLIENTE: "+mv_par03+' - '+Posicione("SA1", 1, xFilial("SA1")+mv_par03, "A1_NOME")
                     nLin += 1
                   @ nLin, 000 PSAY Replicate('—', 80)
                     nLin += 1
                Endif
                lPriVez := .f.
             Endif
             
       		cQry1 := ""
         	cQry1 += "SELECT SD2.D2_COD, SD2.D2_EMISSAO, SD2.D2_PRCVEN, SD2.D2_QUANT, SD2.D2_CLIENTE, SA1.A1_NOME "
          	cQry1 += "FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) "    
           	cQry1 += "LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ = '') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (D2_CLIENTE = A1_COD) "
            cQry1 += "WHERE (SD2.D_E_L_E_T_ = '') AND (SD2.D2_FILIAL  = '"+xFilial("SD2")+"') "
            if !empty(MV_PAR08)
				cQry1 += "AND (LEN(D2_COD) = 12) AND "+U_ParamSql("SUBSTRING(D2_COD,4,2)",MV_PAR08)+" "
			endif
             cQry1 += "  AND SD2.D2_CLIENTE = '"+TCQ->A1_COD+"' "
             cQry1 += "  AND SD2.D2_TIPO    = 'N' "
             If mv_par05 == 1
                cQry1 += "  AND SD2.D2_COD     BETWEEN '"+mv_par06+"' AND '"+mv_par07+"' "
             Endif
             cQry1 += "ORDER BY D2_COD, D2_EMISSAO DESC "
             TCQuery cQry1 ALIAS "ITM" NEW
             
             lImpCli := .t.
             
             DbSelectArea("ITM")
             DbGoTop()
             While !Eof()
                   If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
                      nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                      nLin += 1
                   Endif
                   cCodPro := ITM->D2_COD
                   nQtdImp := 0
                   If lImpCli
                      @ nLin, 007 PSAY "CLIENTE: "+ITM->D2_CLIENTE+' - '+ITM->A1_NOME
                        nLin += 1
                      @ nLin, 007 PSAY Replicate("-", 73)
                        nLin += 1
                        lImpCli := .f.
                   Endif
                   While !Eof() .and. ITM->D2_COD == cCodPro 
                         If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
                            nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                            nLin += 1
                         Endif
                         If nQtdImp < mv_par04
                            //0         1         2         3         4         5         6         7         8
                            //012345678901234567890123456789012345678901234567890123456789012345678901234567890
                            //       PRODUTO         DESCRIÇÃO                 QUANTIDADE  PREÇO      EMISSÃO
                            //       XX 99.99.999-99 XXXXXXXXXXXXXXXXXXXXXXXXX 999,999.99  999,999.99 99/99/99
                            @ nLin, 007 PSAY ITM->D2_COD                                                               Picture "@R XX 99.99.999-99"
                            @ nLin, 023 PSAY SubStr(Posicione("SB1", 1, xFilial("SB1")+ITM->D2_COD, "B1_DESC"), 1, 25) Picture "@!"
                            @ nLin, 049 PSAY ITM->D2_QUANT                                                             Picture "@E 999,999.99"
                            @ nLin, 061 PSAY ITM->D2_PRCVEN                                                            Picture "@E 999,999.99"
                            @ nLin, 072 PSAY SubStr(ITM->D2_EMISSAO, 7, 2)+'/'+SubStr(ITM->D2_EMISSAO, 5, 2)+'/'+SubStr(ITM->D2_EMISSAO, 3, 2)
                            nLin += 1
                            nQtdImp += 1
                         Endif
                         DbSelectArea("ITM")
                         DbSkip()
                   EndDo
             Enddo
             If !lImpCli
                @ nLin, 007  PSAY Replicate("=", 73)
                nLin += 2
             EndIf
             DbSelectArea("ITM")
             DbCloseArea()
             
             DbSelectArea("TCQ")
             DbSkip()
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
/*
Static Function ValPerg(cPerg)
       Local aHelp :={};Local aHelp1 := {} ; Local aHelp2 := {} ; Local aHelp3 := {} ; Local aHelp4 := {}
       
       aAdd( aHelp2, "Informe o código do representante.     " )
       aAdd( aHelp3, "Informe o código do representante.     " )
       aAdd( aHelp4, "Informe a quantidade de itens para ser " )
       aAdd( aHelp4, "impresso no relatório.                 " )
       aAdd( aHelp1, "Deixar em branco para puxar todos" )   
       
       AAdd(aHelp, {{"Informe a Linha de Produto"},  {"Informe a Linha de Produto"}, {"Informe a Linha de Produto"}})
 
              
 	PutSX1("FATR02    ", "01",   "Repres./Cliente  ?", "", "", "mv_ch1", "N", 1, 0, 0, "C" ," ", "   ", " ", " ", "mv_par01", "Representante", " ", " ", " ", "Cliente", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",  " ", Nil, Nil,Nil, "FATR02" )
  	PutSX1("FATR02    ", "02",   "Representante    ?", "", "", "mv_ch2", "C", 6, 0, 0, "G" ," ", "SA3", " ", " ", "mv_par02", "             ", " ", " ", " ", "       ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",  " ", aHelp2, aHelp2, aHelp2, "FATR02" )
   	PutSX1("FATR02    ", "03",   "Cliente          ?", "", "", "mv_ch3", "C", 6, 0, 0, "G" ," ", "SA1", " ", " ", "mv_par03", "             ", " ", " ", " ", "       ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",  " ", aHelp3, aHelp3, aHelp3, "FATR02" )
   	PutSX1("FATR02    ", "04",   "Qtde. de itens   ?", "", "", "mv_ch4", "N", 2, 0, 0, "G" ," ", "   ", " ", " ", "mv_par04", "             ", " ", " ", " ", "       ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",  " ", aHelp4, aHelp4, aHelp4, "FATR02" )
    PutSX1("FATR02    ", "05",   "Considera Produto?", "", "", "mv_ch5", "N", 1, 0, 0, "C" ," ", "   ", " ", " ", "mv_par05", "Sim          ", " ", " ", " ", "Não    ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",  " ", Nil   , Nil   , Nil   , "FATR02" )
    PutSX1("FATR02    ", "06",   "Do produto       ?", "", "", "mv_ch6", "C",15, 0, 0, "G" ," ", "SB1", " ", " ", "mv_par06", "             ", " ", " ", " ", "       ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",  " ", Nil   , Nil   , Nil   , "FATR02" )
    PutSX1("FATR02    ", "07",   "Até produto      ?", "", "", "mv_ch7", "C",15, 0, 0, "G" ," ", "SB1", " ", " ", "mv_par07", "             ", " ", " ", " ", "       ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",  " ", Nil   , Nil   , Nil   , "FATR02" ) 
	PutSX1(cPerg,"08","Linha(s) Produto"    ,"Linha(s) Produto","Linha(s) Produto","mv_ch8","C",99,00,00,"G","","","","","mv_Par08","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
	PutSX1(cPerg,"09","Segmento(s)        ", "Segmento(s)        ", "Segmento(s)        ", "mv_ch9", "C", 99,00,00, "G",  "", "T3",  "",  "", "mv_Par09","","","","","","","","","","","","","","","","",Nil  , Nil     , Nil,cPerg)
	PutSX1(cPerg,"10","Estado(s)          ", "Estado(s)          ", "Estado(s)          ", "mv_cha", "C", 99,00,00, "G",  "", "",  "",  "", "mv_Par10","","","","","","","","","","","","","","","","",Nil  , Nil     , Nil ,cPerg)
Return

*/