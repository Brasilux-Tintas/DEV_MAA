#include "rwmake.ch"        
#include "topconn.ch"   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFISR01 ºAutor  ³ Luís G. de Souza   º Data ³  20/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Resumo para GIA Subst. Tribut.                             º±±
±±º          ³                                                            º±±
±±º04/10/21  ³ Cleber->Ajuste para FECP no padrão                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Empresas Grupo Brasilux com ST.                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRFISR01()     
     Local cDesc1     := PADC("Relatorio para Apuração da GIA-ST.", 74)
     Local cDesc2     := PADC(" ", 74)
     Local cDesc3     := PADC(" ", 74)
     Local Titulo     := "Apuração para GIA-ST"
     Local nLin       := 0
     Local Cabec1     := ""
     Local Cabec2     := ""

     Private CbTxt    := ""
     Private Limite   := 80
     Private Tamanho  := "P"
     Private NomeProg := "BRFISR01"
     Private nTipo    := 18
     Private aReturn  := {"Especial", 1, "Administracao", 1, 2, 1, "", 1}     
     Private nLastKey := 0
     Private CbCont   := 0
     Private CONTFL   := 01
     Private m_pag    := 01
     Private wnrel    := "BRFISR01"
     Private cString  := "SF3"
     Private cPerg    := "FISR01"
      private MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06,MV_PAR07
      MV_PAR01 := dtos(ctod("  /  /    "))
      MV_PAR02 := dtos(ctod("  /  /    ")) 
      MV_PAR03 := ""
      MV_PAR04 := 1
      MV_PAR05 := 1
      MV_PAR06 := 1
      MV_PAR07 := 1

     fValPer() 
     Pergunte(cPerg, .F.)

     wnrel := SetPrint(cString, NomeProg, cPerg,@titulo, cDesc1, cDesc2, cDesc3, .F., , .F., Tamanho, , .F.)

     If nLastKey == 27
        Return
     Endif
     
     SetDefault(aReturn, cString)

     If nLastKey == 27
        Return
     Endif

     Processa({|| fFISR01_1(Cabec1, Cabec2, Titulo, nLin)}, Titulo)
Return

/***********************************************************************************************************/
/*** FFISR01_01 - Busca dados para o relatório e imprime.                                                ***/
/***********************************************************************************************************/
Static Function fFISR01_1(Cabec1, Cabec2, Titulo, nLin)
       Local cEstado, cQuery,nTam
       Local nSomaVlrProd  := 0
       Local nSomaIpi      := 0
       Local nSomaBaseIcms := 0
       Local nSomaVlrIcms  := 0
       Local nSomaBaseST   := 0
       Local nSomaST       := 0
       Local aFECP         := {}
       Local lFECP         := .f.     
       Local nFECP			:= 0.0
       Local nValorProd, nY,nPosI,nPosF,cIEST
      Local cMVSUBTRIB 	:= ""

cMVSUBTRIB := alltrim(GetSubTrib())
nTam = len(cMVSUBTRIB)
if (nTam > 1 ) .and. !isalpha(substr(cMVSUBTRIB,1,1)) //Inscrições estão vindo com barra no inicio
   cMVSUBTRIB := substr(cMVSUBTRIB,2,nTam-1)
endif 


	dbselectarea("CFC")
	dbsetorder(1)
	dbselectarea("SF2")
	dbsetorder(1)       


      cQuery := "SELECT F3_NFISCAL AS NOTA, F3_SERIE AS SERIE, F3_ESTADO AS ESTADO,F3_CLIEFOR, "+;
		"F3_DTCANC AS CANCELADA, "+;
		"SUM(F3_VALIPI) AS IPI, SUM(F3_BASEICM) AS BASEICMS, SUM(F3_VALICM) AS VALORICMS, "+;
		"SUM(F3_BASERET) AS BASESUBST, SUM(F3_ICMSRET) AS ST, SUM(F3_VFECPST) AS VALFECPST "
      cQuery += "FROM "+RetSqlName("SF3")+" SF3 WITH (NOLOCK) "
      cQuery += "WHERE (F3_FILIAL  = '"+xFilial("SF3")+"') "
      cQuery += "  AND (D_E_L_E_T_ = '') "
      cQuery += "  AND (SUBSTRING(F3_CFO, 1, 1) >= '5') "
      cQuery += "  AND (F3_EMISSAO BETWEEN '"+dTos(mv_par01)+"' AND '"+dTos(mv_par02)+"') "
       If !Empty(mv_par03)
          cQuery += "  AND (F3_ESTADO = '"+mv_par03+"') "
       Endif
       If mv_par07 == 2
          cQuery += "AND (F3_DTCANC = '') "
       ElseIf mv_par07 == 3
              cQuery += "AND (F3_DTCANC <> '') "
       Endif
       cQuery += "GROUP BY F3_FILIAL, F3_NFISCAL, F3_SERIE, F3_CLIEFOR, F3_ESTADO, F3_DTCANC "
       If mv_par04 == 1
       		cQuery += "HAVING (SUM(F3_ICMSRET) > 0.00) "
          //cQuery += "  AND (F3_BASERET > 0.00 OR F3_TIPO = 'I') "
       ElseIf mv_par04 == 2  
       		cQuery += "HAVING (SUM(F3_ICMSRET) = 0.00) "
//              cQuery += "  AND (F3_BASERET = 0.00) "
       Endif

       cQuery += "ORDER BY F3_ESTADO, F3_NFISCAL, F3_SERIE "
       
       TCQuery cQuery ALIAS "TCQ" NEW
    
       Cabec1 := "NRO NF       VALOR PROD  VALOR IPI   BASE ICMS VALOR ICMS BAS ICMS ST VLR ICM ST" //SubStr(AllTrim(SM0->M0_NOMECOM), 1, 30)+" - "+"PERIODO DE "+dtoc(mv_par01) +" ATE "+dtoc(mv_par02)
       //         0         1         2         3         4         5         6         7         8
       //         012345678901234567890123456789012345678901234567890123456789012345678901234567890
       //         9999999999 9,999,999.99 999,999.99 9999,999.99 999,999.99 9999,999.99 999,999.99
       Cabec2 := ""      
      
       DbSelectArea("TCQ")
       DbGoTop()

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Inicializa  regua de impressao                            ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       ProcRegua(2000)
       nLin := 61
       If nLin > 60
          nLin := Cabec(titulo, Cabec1, Cabec2, nomeprog, tamanho, nTipo)
          nLin += 1
       Endif
       @ nLin, 000 PSAY SubStr(AllTrim(SM0->M0_NOMECOM), 1, 30)+" - "+"PERIODO DE "+dtoc(mv_par01) +" ATE "+dtoc(mv_par02)
         nLin += 1
       @ nLin, 000 PSAY Iif(mv_par05 == 1, "Analitico - ", "Sintético - ")+Iif(mv_par04 == 1, "Com Subst. Tribut.", Iif(mv_par04 == 2, "Sem Subst. Tribut.", "Com e Sem Subst. Tribut."))
         nLin += 1
       @ nLin,000 PSAY Replicate("-",80)
         nLin += 1
       While !Eof()
            If nLin > 60
               nLin := Cabec(titulo, Cabec1, Cabec2, nomeprog, tamanho, nTipo)
               nLin += 1
            Endif      
            cIEST := ""
            If At (alltrim(TCQ->ESTADO), cMVSUBTRIB)>0
					nPosI	:=	At (alltrim(TCQ->ESTADO), cMVSUBTRIB)+2
					nPosF	:=	At ("/", SubStr (cMVSUBTRIB, nPosI))-1
					nPosF	:=	IIf(nPosF<=0,len(cMVSUBTRIB),nPosF)
               cIEST := ALLTRIM(SubStr (cMVSUBTRIB, nPosI, nPosF))
            Endif


             
             cImpEst := "ESTADO: "+TCQ->ESTADO+" - ("+Iif(Empty(cIEST), "SEM INSCRIÇÃO", cIEST)+")"
             nLin++
             @ nLin,000 PSAY Replicate("-", Len(cImpEst))
             nLin++
             @ nLin,000 PSAY cImpEst
             nLin++
             @ nLin,000 PSAY Replicate("-", Len(cImpEst))
             nLin++
             nSomaVlrProd  := 0
             nSomaIpi      := 0
             nSomaBaseIcms := 0
             nSomaVlrIcms  := 0
             nSomaBaseST   := 0
             nSomaST       := 0
             cEstado       := TCQ->ESTADO       
             lFECP := .f.
       		 aFECP := {}
             While !Eof() .and. (TCQ->ESTADO == cEstado)
             	IncProc()
              	If nLin > 60
                      @ nLin,000 PSAY Replicate("-",80)
                      nLin := Cabec(titulo, Cabec1,Cabec2,nomeprog,tamanho,nTipo)
                      nLin += 1
               	Endif   
				dbselectarea("SF2")
				dbseek(xFilial("SF2")+TCQ->NOTA+TCQ->SERIE+TCQ->F3_CLIEFOR)
				if found()
					nValorProd := SF2->F2_VALMERC
				ELSE
					nValorProd := 0
				endif 

				nFECP := 0.0
    			nSubTri := TCQ->ST    
             /*
       			if (mv_par06 == 1) .AND. (TCQ->ST > 0) //(cEstado == 'RJ') .and.     
          			dbselectarea("CFC")
             		dbseek(xFilial("CFC")+SM0->M0_ESTENT+cEstado)   //CFC_FILIAL+CFC_UFORIG+CFC_UFDEST+CFC_CODPRD
              		IF !eof() .and. !bof() .and. (CFC->CFC_FILIAL == xFilial("CFC")) .AND. (SM0->M0_ESTENT == CFC->CFC_UFORIG) .AND. (cEstado == CFC->CFC_UFDEST) .AND. (CFC->CFC_ALQFCP > 0)
                     lFECP := .t.
                     nFECP := TCQ->BASESUBST * CFC->CFC_ALQFCP/100
                     nSubTri := nSubTri - nFECP	//nSubTri = TCQ->ST - (TCQ->BASESUBST * 0.01) // (TCQ->BASESUBST*0.18) - TCQ->VALORICMS
                     aadd(aFECP, {TCQ->NOTA, nValorProd, TCQ->IPI, TCQ->BASEICMS, TCQ->VALORICMS, TCQ->BASESUBST, nFECP })
	      			ENDIF 
            */     
            //Cleber->Chamado 024034             
       		if (mv_par06 == 1) .AND. (TCQ->VALFECPST > 0) //(cEstado == 'RJ') .and.     
                     lFECP := .t.
                     nFECP := TCQ->VALFECPST
                     nSubTri := nSubTri - nFECP	//nSubTri = TCQ->ST - (TCQ->BASESUBST * 0.01) // (TCQ->BASESUBST*0.18) - TCQ->VALORICMS
                     aadd(aFECP, {TCQ->NOTA, nValorProd, TCQ->IPI, TCQ->BASEICMS, TCQ->VALORICMS, TCQ->BASESUBST, nFECP })
	    		endif 
						
					 
                If mv_par05 == 1
                      @ nLin,000 PSAY TCQ->NOTA
                      @ nLin,010 PSAY nValorProd 	 Picture "@E 9,999,999.99"
                      @ nLin,023 PSAY TCQ->IPI       Picture "@E 999,999.99"
                      @ nLin,034 PSAY TCQ->BASEICMS  Picture "@E 9999,999.99"
                      @ nLin,046 PSAY TCQ->VALORICMS Picture "@E 999,999.99"
                      @ nLin,057 PSAY TCQ->BASESUBST Picture "@E 9999,999.99"
                      @ nLin,070 PSAY nSubTri        Picture "@E 999,999.99"
                      nLin++
                Endif
                nSomaVlrProd  += nValorProd
                nSomaIpi      += TCQ->IPI
                nSomaBaseIcms += TCQ->BASEICMS
                nSomaVlrIcms  += TCQ->VALORICMS
                nSomaBaseST   += TCQ->BASESUBST
                nSomaST       += nSubTri
                DbSelectArea("TCQ")
                DbSkip()
             Enddo
             If mv_par05 == 1
                nLin++
                @ nLin,000 PSAY __PrtThinLine() //Replicate("-",80)
                  nLin += 1
                If nLin > 60
                   nLin := Cabec(titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
                   nLin += 1
                Endif
             Endif
             @ nLin,000 PSAY "TOT("+cEstado+")"
             @ nLin,010 PSAY nSomaVlrProd  Picture "@E 9,999,999.99"
             @ nLin,023 PSAY nSomaIpi      Picture "@E 999,999.99"
             @ nLin,034 PSAY nSomaBaseIcms Picture "@E 9999,999.99"
             @ nLin,046 PSAY nSomaVlrIcms  Picture "@E 999,999.99"
             @ nLin,057 PSAY nSomaBaseST   Picture "@E 9999,999.99"
             @ nLin,070 PSAY nSomaST       Picture "@E 999,999.99"
             nLin++
             @ nLin,000 PSAY __PrtThinLine() //Replicate("-",80)
             
             If lFECP
                nLin += 2
                If Len(aFECP) > 0
                   @ nLin,000 PSAY Replicate("-", Len(cImpEst))
                   nLin++
                   @ nLin,000 PSAY cImpEst+" - FECP - FUNDO ESTADUAL DE COMBATE A POBREZA"
                   nLin++
                   @ nLin,000 PSAY Replicate("-", Len(cImpEst))
                   nLin++
                   If nLin > 60
                      nLin := Cabec(titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
                      nLin += 1
                   Endif
                   nFECPPR := 0
                   nFECPIP := 0
                   nFECPBI := 0
                   nFECPIC := 0
                   nFECPBS := 0
                   nFECPST := 0
                   For nY := 1 To Len(aFECP)
                       If nLin > 60
                          nLin := Cabec(titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
                          nLin += 1
                       Endif
                       If mv_par05 == 1
                          @ nLin,000 PSAY aFECP[nY][1]
                          @ nLin,010 PSAY aFECP[nY][2] Picture "@E 9,999,999.99"
                          @ nLin,023 PSAY aFECP[nY][3] Picture "@E 999,999.99"
                          @ nLin,034 PSAY aFECP[nY][4] Picture "@E 9999,999.99"
                          @ nLin,046 PSAY aFECP[nY][5] Picture "@E 999,999.99"
                          @ nLin,057 PSAY aFECP[nY][6] Picture "@E 9999,999.99"
                          @ nLin,070 PSAY aFECP[nY][7] Picture "@E 999,999.99"
                          nLin++
                       Endif
                       nFECPPR += aFECP[nY][2]
                       nFECPIP += aFECP[nY][3]
                       nFECPBI += aFECP[nY][4]
                       nFECPIC += aFECP[nY][5]
                       nFECPBS += aFECP[nY][6]
                       nFECPST += aFECP[nY][7]
                   Next
                   @ nLin,000 PSAY Replicate("-",80)
                   nLin++
                   @ nLin,000 PSAY "TOT("+cEstado+")"
                   @ nLin,010 PSAY nFECPPR Picture "@E 9,999,999.99"
                   @ nLin,023 PSAY nFECPIP Picture "@E 999,999.99"
                   @ nLin,034 PSAY nFECPBI Picture "@E 9999,999.99"
                   @ nLin,046 PSAY nFECPIC Picture "@E 999,999.99"
                   @ nLin,057 PSAY nFECPBS Picture "@E 9999,999.99"
                   @ nLin,070 PSAY nFECPST Picture "@E 999,999.99"
                   nLin++
                   @ nLin,000 PSAY Replicate("-",80)
                   nLin++
                Endif
             Endif
             DbSelectArea("TCQ")
       EndDo
       DbSelectArea("TCQ")
       DbCloseArea()

       Set Device To Screen
       If aReturn[5] == 1
          Set Printer TO
          DbCommitAll()
          OurSpool(wnrel)
       Endif
Return

/***********************************************************************************************************/
/*** FVALPER - Validação do dicionário de perguntas.                                                     ***/
/***********************************************************************************************************/
Static Function fValPer()
Local aHelp1 := {} ; Local aHelp2 := {} ; Local aHelp3 := {} ; Local aHelp4 := {} ; Local aHelp5 := {}
       aAdd( aHelp1, "Informe a data incial de emissão.  " )
       aAdd( aHelp2, "Informe a data final de emissão.   " )
       aAdd( aHelp3, "Informe o estado ou deixe em bran- " )
       aAdd( aHelp3, "co para todos os estados.          " )
       aAdd( aHelp4, "Seleção de itens com ou sem Subst. " )
       aAdd( aHelp4, "Tribut., ou ambas.                 " )
       aAdd( aHelp5, "FECP - Fundo Estadual Combate a Po-" )
       aAdd( aHelp5, "breza. Separa para itens com S.T. ." )
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Inclui parametros de consulta                                                  ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                            
      u_xPutSX1(cPerg,"01","Da  Emissão          ","Da  Emissão          ","Da  Emissão          ","mv_ch1" ,"D",08,0,0,"G",""  ,"","","","MV_PAR01",""     ,""     ,""     ,"",""     ,""     ,""     ,"","","","","","","","","",aHelp1,aHelp1,aHelp1,cPerg)
      u_xPutSX1(cPerg,"02","Até Emissão          ","Até Emissão          ","Até Emissão          ","mv_ch2" ,"D",08,0,0,"G",""  ,"","","","MV_PAR02",""     ,""     ,""     ,"",""     ,""     ,""     ,"","","","","","","","","",aHelp2,aHelp2,aHelp2,cPerg)
      u_xPutSx1(cPerg,"03","Estado               ","Estado               ","Estado               ","mv_ch3", "C",02,0,0,"G", " ", "", " ", " ", "MV_PAR03", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , aHelp3  , aHelp3     , aHelp3    ,cPerg)
      u_xPutSX1(cPerg,"04","Subst. Tributaria    ","Subst. Tributaria    ","Subst. Tributaria    ","mv_ch4","N" ,01,0,0,"C","","","","","MV_PAR04","Com S.T. ","Com S.T. ","Com S.T. ","", "Ambas     ", "Ambas     ", "Ambas     ","","","","","","","","","",aHelp4,aHelp4,aHelp4,cPerg)
      u_xPutSX1(cPerg,"05","Analitico/Sintetico  ","Analitico/Sintetico  ","Analitico/Sintetico  ","mv_ch5","N" ,01,0,0,"C","","","","","MV_PAR05","Analitico","Analitico","Analitico","", "Sintetico", "Sintetico","Sintetico","","","","","","","","","",Nil   , Nil, Nil,cPerg)
      u_xPutSX1(cPerg,"06","Separa FECP          ","Separa FECP          ","Separa FECP          ","mv_ch6","N" ,01,0,0,"C","","","","","MV_PAR06","1-Sim","1-Sim","1-Sim","","2-Não","2-Não","2-Não","","","","","","","","","",aHelp5,aHelp5,aHelp5,cPerg)
      u_xPutSX1(cPerg,"07","Tipo Notas a imprimir","Tipo Notas a imprimir","Tipo Notas a imprimir","mv_ch7","N" ,01,0,0,"C","","","","","MV_PAR07","Todas    ","Todas    ","Todas    ","","Normais  ","Normais  ","Normais  ","Canceladas","Canceladas","Canceladas","","","","","","",aHelp5,aHelp5,aHelp5,cPerg)
Return

