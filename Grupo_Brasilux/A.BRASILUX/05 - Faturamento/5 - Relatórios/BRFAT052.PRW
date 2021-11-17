#Include "Protheus.ch"
#include "topconn.ch"

/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: BRFAT052     Data....: 04/02/02         //
// Autor.....: Cleber Orati Domingues                   //
// Descriçao.: Relatorio de Pedidos de Venda //
// Uso.......: Brasilux/Brasitec                       //
//                                                     //
/////////////////////////////////////////////////////////
//                                                     //
// Variaveis utilizadas para parametros                //
//                                                     //
// mv_par01     // Pedido de                           //
// mv_par02     // Pedido até                          //
// mv_par03     // Cliente de                          //
// mv_par04     // Cliente até                         //
// mv_par05     // Aprovação de                        //
// mv_par06     // Aprovação até                       //
// mv_par06     // Aprovação até                       //
// mv_par07     // Totos ou Nao Conf. Rev              //
// mv_par08     // Ordem dos Itens                     //
/////////////////////////////////////////////////////////
User Function BRFAT052()
     Local _cUser

     

     Private cxEntrega := "", cPerg := ""
     SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M")
     SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3")
     SetPrvt("CCABEC,CCABPRO,CNATUREZA,ARETURN,NOMEPROG")
     SetPrvt("NLASTKEY,LCONTINUA,NLIN,NCOL,WNREL,NTIPO")
     SetPrvt("M_PAG,CCABEC1,CCABEC2,CCABEC3,NTAMNF,CSTRING")
     SetPrvt("CQUERY,_TOTALG,_TOTFIN,_TOTESTE,_TOTESTS,LIMPEST")
     SetPrvt("LIMPFIN,_DTGERAD,_NRAVAR,_TOTAL,_SALIAS,AREGS")

  if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 

     nOrdem   := 0
     Alfa     := 0
     Z        := 0
     M        := 0
     tamanho  := "P"
     limite   := 80
     titulo   := "PEDIDOS - RELATORIO P/ PRODUCAO"
     cDesc1   := PADC("Programa para emitir Pedidos",74)
     cDesc2   := PADC(" ",74)
     cDesc3   := PADC(" ",74)
     cCabec   := PADC("PEDIDOS - RELATÓRIO P/ PRODUCAO",27)
     cCabPro  := ""
     cNatureza:= ""
     aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
     nomeprog := "BRFAT052"
     cPerg    := "BRFT52"
     nLastKey := 0
     lContinua:= .T.
     nLin     := 90
     nCol     := 60
     wnrel    := "BRFAT052"
     nTipo    := 18
     m_pag    := 01
     //           012345678901234567890123456789012345678901234567890123456789012345678901234567890
     cCabec1  := "PRODUTO "
     cCabec2  := "PEDIDO    CLIENTE                                  REG/REGTR QUANTIDADE LOCALIZ."
     cCabec3  := ""
     nTamNf   := 83     // Apenas Informativo
     cString  := "SC9"

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Envia controle para a funcao SETPRINT                        ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    

     _cUser := upper(alltrim(cUserName))

     //ValidPerg()
     Pergunte("BRFT52",.F.)

     wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,,.F.,Tamanho)

     If nLastKey == 27
        Return
     Endif
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Verifica Posicao do Formulario na Impressora                 ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     SetDefault(aReturn,cString)

     If nLastKey == 27
        Return
     Endif

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Inicio do Processamento do Relatorio                         ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     RptStatus({|| RptDetail()})


Static Function RptDetail()



     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Inicializa  regua de impressao                            ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Local nValorIpi := 0, nSubstrib := 0, nAliqInt := 0, nAliqSol := 0,cUf, cAux,  nPerIcm := 0     
     Local nBaseSubst := 0, nBaseIcms := 0, cUn := "", nAuxIpi := 0, nLucroST := 0
     Local nAuxIcms := 0, cEmpresa, i
     Local nDescZFR := 0 // Desc. Zona Franca
     Local nDescPisCof := 0,lDescPisCof // Desc. Pis/Cofins Zona Franca, portaria Suframa 162/2005
     Local lGeraDuplic, nValorPed, nValorProd,lEstoque
     Local nTxPis  := GETMV("MV_TXPIS")
     Local nTxCofin:= GETMV("MV_TXCOFIN")
     Private cPedido, nPercSubst, nSomaVlrProd, cQuery
     
     
     //Private oPr := ReturnPrtObj() // imprimir código de barras usando o setprint (sem o tmsprinter)  


     cEmpresa := SubStr(cnumemp,1,2)
     
     cQuery := ""
     cQuery += "SELECT SC6.C6_NUM AS PEDIDO, SB2.B2_LOCALIZ, SC6.C6_PRODUTO, SC6.C6_TES, SC6.C6_VALOR,"+;
     "SC6.C6_QTDVEN, SC6.C6_DESCRI, SC6.C6_LOCAL, SC6.C6_PRCVEN, SC6.C6_TES, A.C5_ESPECI4, SC6.C6_PALLET,C5_VLRDUP  "
		IF mv_par08 == 3
			cQuery += ",SUBSTRING(SC6.C6_PRODUTO,11,2) AS EMBA,ORDEM = CASE WHEN (SB2.B2_LOCALIZ = '') THEN '0' WHEN (SUBSTRING(SC6.C6_PRODUTO,1,3) IN ('BM ','BL ')) THEN '1' ELSE '2' END "
       		cQuery += ",GRPEMBA = ISNULL((SELECT TOP 1 B1_GRUPO2 FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "+;
       		"LEFT OUTER JOIN "+RetSqlName("SB1")+" B1E WITH (NOLOCK) ON (B1E.D_E_L_E_T_ = '') AND (G1_FILIAL = B1E.B1_FILIAL) AND (G1_COMP = B1E.B1_COD) "+;
       		"WHERE (SG1.D_E_L_E_T_ = '') AND (G1_FILIAL = SC6.C6_FILIAL) AND (G1_COD = SC6.C6_PRODUTO) AND (B1E.B1_GRUPO LIKE 'E%') AND (B1E.B1_GRUPO2 > '')),'99') "
       	ENDIF 
//     cQuery += "ORDEM = CASE WHEN SUBSTRING(C6_PRODUTO, 1, 2) = 'BM' THEN SC6.C6_NUM+'ZZ'+SUBSTRING(C6_PRODUTO,4,9)+SUBSTRING(C6_PRODUTO,1,3) ELSE SC6.C6_NUM+SUBSTRING(C6_PRODUTO,4,9)+SUBSTRING(C6_PRODUTO,1,3) END "
     cQuery += "FROM "+retsqlname("SC6")+" SC6 WITH (NOLOCK) "     
     if !empty(MV_PAR09)
	     cQuery += "LEFT OUTER JOIN "+retsqlname("SZG")+" SZG WITH (NOLOCK) ON (C6_FILIAL = ZG_FILIAL) AND (C6_NUM = SUBSTRING(ZG_PEDIDO,3,6)) AND (SZG.D_E_L_E_T_ <> '*') "
     endif 	
     cQuery += "LEFT OUTER JOIN "+retsqlname("SC5")+" A WITH (NOLOCK) ON (C6_FILIAL = C5_FILIAL) AND (A.C5_NUM = SC6.C6_NUM) AND (A.D_E_L_E_T_ <> '*') "
     cQuery += "LEFT OUTER JOIN "+retsqlname("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (C6_FILIAL = B1_FILIAL) AND (C6_PRODUTO = B1_COD) "
     cQuery += "LEFT OUTER JOIN "+retsqlname("SB2")+" SB2 WITH (NOLOCK) ON (SB2.D_E_L_E_T_ <> '*') AND (B1_FILIAL = B2_FILIAL) AND (B1_LOCPAD = B2_LOCAL) AND (B1_COD = B2_COD) "
     cQuery += "WHERE "
     cQuery += "  (SC6.C6_FILIAL = '"+xFilial("SC6")+"') "
     cQuery += "  AND SC6.C6_NUM BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
     If !Empty(mv_par04) .and. (mv_par04 >= mv_par03)
        cQuery += " AND A.C5_CLIENTE BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
     Endif
     If mv_par07 == 2
        cQuery += " AND (A.C5_NAOCONF = 'S') "
     Endif
     if !empty(mv_par09)
        cQuery += " AND (SZG.ZG_CODIGO = '"+MV_PAR09+"') "
     ENDIF 
     	
     If !empty(MV_PAR06) .and. (MV_PAR06 >= MV_PAR05)
        cQuery += " AND SC6.C6_NUM IN (SELECT DISTINCT C9_PEDIDO FROM "+retsqlname("SC9")+" WITH (NOLOCK) "
        cQuery += " WHERE (C9_FILIAL = '"+xFilial("SC9")+"') "
        cQuery += " AND C9_DATALIB BETWEEN '"+DTOS(MV_PAR05)+"' AND '"+DTOS(MV_PAR06)+"' "
        cQuery += " AND (C9_BLEST = '  ') AND (C9_BLCRED = '  ') AND  (C9_BLOQUEI = '  ') "
        cQuery += " AND (D_E_L_E_T_ <> '*'))"
     Endif
     cQuery += "  AND (SC6.D_E_L_E_T_ <> '*') "   
     If MV_PAR08 == 1
        cQuery += "ORDER BY PEDIDO, C6_ITEM "
     ElseIf MV_PAR08 == 2
     	cQuery += "ORDER BY PEDIDO,C6_DESCRI,C6_PRODUTO "
     ElseIf MV_PAR08 == 3
            cQuery += "ORDER BY PEDIDO,ORDEM,GRPEMBA,B2_LOCALIZ,EMBA,C6_PRODUTO "
     ElseIf MV_PAR08 == 4
            cQuery += "ORDER BY PEDIDO,B2_LOCALIZ,C6_PRODUTO "
     ElseIf MV_PAR08 == 5
            cQuery += "ORDER BY PEDIDO,C6_PRODUTO "
     Endif
     TCQuery cQuery NEW ALIAS "TCQ"

     DbSelectArea("ZZO")        // Rel. de Volumes por Embalagem
     DbSetOrder(1)

     DbSelectArea("SF4")        // TES
     DbSetOrder(1)

     Dbselectarea("SB1")
     Dbsetorder(1)

     DbSelectArea("SZ5")
     Dbsetorder(1)

     DbSelectArea("SZ8") 	// Estados Subst. Trib.
     Dbsetorder(1)	// Z8_FILIAL+Z8_EST+Z8_TIPOCLI    

     Dbselectarea("SC6")
     Dbsetorder(1)

     SetPrc(0,0)
     nLin = 0
     DbSelectArea("TCQ")
     DbGoTop()
     SetRegua(Reccount())

     While !Eof() .and. lContinua
           cPedido        := TCQ->PEDIDO
           nSomaVlrProd   := 0 // Usado para saber o valor total do produto antecipadamente p/ efeito de cálc. de Subst. Trib. proporcional em relação ao frete
           lGeraDuplic    := iif(TCQ->C5_VLRDUP > 0,.T.,.F.) //GeraDuplic(cPedido) // Verifica se tem algum item que não gera duplicata
           nPag           := 1
           nValorPed      := 0 // Valor Total do Pedido
           nValorProd     := 0 // Valor Total dos Produtos
           nValorIpi      := 0   // Guarda o valor total do IPI
           nSubstrib      := 0 // Guarda o valor total da Subst. Trib.
           nDescZFR       := 0 //Vlr do Desc. 7% Zona Franca
           nDescPisCof    := 0 //Vlr do Desc. Pis/Cofins Zona Franca Manaus, portaria Suframa 162/2005
//           lCliZFR        := .f.
           If lAbortPrint
              @ 00,01 PSAY "** CANCELADO PELO OPERADOR **"
              lContinua := .F.
              Exit
           Endif

	 		//Cleber (18/10/10) -> Verificar se rel. de volumes estão coerentes antes     
	 		//U_VerificaVolumes(cPedido) //Cleber (27/08/15) ->Retirado

           cabecalho()
           If !lGeraDuplic
              nLin++
              @nLin,00 psay "              ***********************************************"
              nLin++
              @nLin,00 psay "              *           PEDIDO SEM DUPLICATA!!            *"
              nLin++
              @nLin,00 psay "              ***********************************************"
           Else
              If SC5->C5_NAOCONF == "S"
                 nLin++
                 @nLin,00 psay "           ****************************************************"
                 nLin++
                 @nLin,00 psay "           *    Pedido em DESACORDO com a politica p/ Revenda *"
                 nLin++
                 @nLin,00 psay "           ****************************************************"
              Endif
           Endif
//		   lCliZFR := Posicione("SA1", 1, xFilial("SA1")+SC5->C5_CLIENTE, "A1_CODCID") $ '002054.002259.066230' .and. Posicione("SA1", 1, xFilial("SA1")+SC5->C5_CLIENTE, "A1_CALCSUF") $ 'S'
			cUf := iif(SC5->C5_TIPO $ "D_B",SA2->A2_EST,SA1->A1_EST)
           // Det. da Aliq. ICM interna do estado e Alíquta de ICMS Próprio
           nAliqInt := U_Aliqinterna(cUf) //val(SUBSTR(cAux,at(cUf,cAux)+2,2))/100
           nPerIcm := AliqIcms(SC5->C5_TIPO,'S',SC5->C5_TIPOCLI)/100 // Alíquota de ICMS
           lDescPisCof := .f.
           nPallets    := 0
           DbSelectArea("TCQ")
           While !Eof() .and. (TCQ->PEDIDO == cPedido) .AND. lContinua
                 If lAbortPrint
                    @ 00,01 PSAY "** CANCELADO PELO OPERADOR **"
                    lContinua := .F.
                    Exit
                 Endif    

                 //**************************************************************************
                 lEstoque = .f.
                 DbSelectArea("SB1")
                 DbSeek(xFilial("SB1")+TCQ->C6_PRODUTO)
                 If !found()
                    Alert("Erro! Nao Achado o produto "+TCQ->C6_PRODUTO+"!")
                 else
                    lEstoque := iif(SB1->B1_ESTOQUE = "S",.T.,.F.)
                 Endif
		
                 // Cálculo da Subst. Trib. e IPi
                 DbSelectArea("SF4")
                 DbSeek(xFilial("SF4")+TCQ->C6_TES)
                 If Found()       
                 	nAliqSol := nAliqInt + iif((cUf = "RJ") .AND. (SF4->F4_ISEFECP <> '1'),0.01,0) // Consid. 1% fundo pobreza RJ

                 	If (SF4->F4_PISCRED = '4') .AND. (SF4->F4_PISCOF = '3') // .and. lCliZFR
                 		lDescPisCof := .t.
                 	endif 
                    nAuxIpi := 0
                    If SF4->F4_IPI == "S"
                       nAuxIpi := TCQ->C6_VALOR * (SB1->B1_IPI/100)
                       nValorIpi += nAuxIpi
                    Endif
                    If SF4->F4_INCSOL == "S" 
					                    	
                       nFrete = IIF(TCQ->C5_VLRDUP > 0,(TCQ->C6_VALOR/nSomaVlrProd) * SC5->C5_FRETE,0) // Frete proporcional ao valor
                       nBaseIcms = TCQ->C6_VALOR + nFrete + iif(SF4->F4_INCIDE == "S",nAuxIpi,0)
                       nAuxIcms := nBaseIcms * nPerIcm                               
                       nLucroST := (1+(nPercSubst/100))
                       nBaseSubst := (TCQ->C6_VALOR + nFrete + nAuxIpi)*nLucroST*IIF(SF4->F4_BSICMST > 0,SF4->F4_BSICMST/100,1)                                  
                       
                       //Cleber (24/08/11) - Tratamento para MT com MVA diferenciado e também sem desconto ICMS próprio, de acordo com CNAE
                       nSubstrib += (nBaseSubst*nAliqSol) - iif((cUf = "MT") .and. (nPercSubst = 45),0,nAuxIcms)
                    Endif
                 Endif
				
                 cUn := SB1->B1_UM  // Guarda Unidade de Medida, Inicialmente
                 If (Len(alltrim(TCQ->C6_PRODUTO)) == 12) .and. (SubStr(TCQ->C6_PRODUTO,11,2) # "00")
                    DbSelectArea("SZ5")
                    DbSeek(xFilial("SZ5")+Substr(TCQ->C6_PRODUTO,11,2))
                    If Found()   
                       cUn := "("+ALLTRIM(SZ5->Z5_DESCR)+")" // Guardar a descrição da Embalagem
                    Endif
                 Endif
                 nLin+=1
                 @nLin,000 psay ALLTRIM(TCQ->C6_PRODUTO)+iif(lEstoque,"*","")
                 @nLin,013 psay substr(TCQ->C6_DESCRI,1,29)
                 @nLin,043 psay TCQ->C6_QTDVEN picture "@E 99,999"  //*IIF(LEN(ALLTRIM(TCQ->C5_ESPECI4)) > 0,2,1)
                 @nLin,050 psay substr(cUn,1,10)
                 If !Empty(TCQ->B2_LOCALIZ)           
                    cAux = alltrim(alltrim(TCQ->B2_LOCALIZ))
                    cAux = substr(cAux,1,9)
                    @nLin,061 psay cAux
                 Endif 
                 @nLin, 70 psay TCQ->C6_PRCVEN picture "@E 999,999.99"
                 nValorProd+=TCQ->C6_QTDVEN*TCQ->C6_PRCVEN
                 //nPallets += TCQ->C6_PALLET
                 If nLin >= 59
                    ImprLinha()

                    cabecalho()
                 Endif
                 nLin+=1
                 @nLin,000 psay replicate("_",80)
                 If nLin >= 59
                    ImprLinha()
                    Cabecalho()
                 Endif
                 DbSelectArea("TCQ")
                 DbSkip()
                 IncRegua()
           EndDo
//           nValorPed = nValorProd+SC5->C5_FRETE	
           If !(SC5->C5_TIPO $ "D_B") .and. (SA1->A1_CALCSUF != "N") .and. !empty(SA1->A1_SUFRAMA)
              nDescZFR := nValorProd*0.07
           Endif   
           if lDescPisCof
              //nDescPisCof := nValorProd*(GETMV("MV_TXPIS")+GETMV("MV_TXCOFIN"))/100 adequação da release 12.1.25
              nDescPisCof := nValorProd*((nTxPis)+(nTxCofin))/100
           endif 
           nValorPed = (nValorProd-nDescZFR-nDescPisCof)+nValorIpi+nSubstrib+SC5->C5_FRETE
           nLin+=1
           If nLin >= 59
              ImprLinha()
              cabecalho()
              nLin+=1
              @nLin,000 psay replicate("-",80)
              nLin+=1
           Endif
			@nLin,000 psay "QTDE DE VOLUMES : "
			@nLin,018 psay SC5->C5_VOLUME1 picture "@E 9,999"
			@ nLin,024 psay "CUBAGEM : "
			@ nLin,034 psay SC5->C5_VOLUME2 picture "@E 999.999"
			@nLin,043    psay "VALOR TOTAL DOS PRODUTOS : "
			@nLin,070    psay (nValorProd - nDescZFR - nDescPisCof) picture "@E 999,999.99"
           nLin += 1
           @ nLin,052 psay "PESO BRUTO  : "                // RAMON SOLICITOU JOGAR NA LINHA DE BAIXO O PESO.
           @ nLin,070 psay ROUND(SC5->C5_PBRUTO,0) picture "@E 999,999"                
           nLin += 1           
           If nLin >= 59
              ImprLinha()
              cabecalho()
    	      nLin+=1
    	      @nLin,000 psay replicate("-",80)
              nLin+=1
    	   Endif

/*
			//Cleber (21/08/13) -> Exclusão de impostos, utilizar a Pré-Nota
    	   @nLin,000 psay "IPI : "
    	   @nLin,006 psay nValorIpi picture "@E 99,999.99"
    	   @nLin,016 psay "SUBST. TRIB. : "
    	   @nLIn,031 psay nSubstrib picture "@E 99,999.99"
    	   @nLin,045 psay "VALOR TOTAL DO PEDIDO : "
    	   @nLin,070    psay nValorPed picture "@E 999,999.99" //((nValorPed-nDescZFR-nDescPisCof)+nValorIpi+nSubstrib)
*/    	   

    	   If nLin >= 59
    	      ImprLinha()
    	      Cabecalho()
    	   Endif
    	   nLin += 1
    	   @nLin,000 psay replicate("-",80)
    	   If nLin >= 59
    	      ImprLinha()
    	      Cabecalho()
    	   Endif

           //cMens = u_tiraacento(alltrim(SC5->C5_OBS))
           cMens = u_tiraacento(alltrim(MSMM(SC5->C5_OBSSC5)))
    	   If nDescZFR > 0
    	      cMens += Iif(!empty(cMens),"**","")+"Desc. Zona Franca(7%) R$ "+Alltrim(Transform(nDescZFR,"999,999.99"))
    	   Endif
    	   If nDescPisCof > 0
    	      cMens += Iif(!empty(cMens)," **","")+"Desc. PIS/COFINS ZFM (9,25%)R$ "+Alltrim(Transform(nDescPisCof,"999,999.99"))
    	   Endif
    	   nQtdeLin := 0
    	   If !empty(cMens)
    	      nQtdeLin = len(cMens)/80
    	      If int(nQtdeLin) < nQtdeLin
    	         nQtdeLin = int(len(cMens)/80)+1
              Endif
    	   Endif
    	   For i = 1 to nQtdeLin
    	       cAux = substr(cMens,i*80 - 79,80)
    	       nLin+=1
    	       @nLin,000 psay cAux
               If nLin >= 59
    	          ImprLinha()
    	          nLin := 1
    	       Endif
    	   Next        
    	   nLin+=1
    	   @nLin,000 psay replicate("-",80)
    	   If nLin >= 59
    	      ImprLinha()
    	      nLin := 1
    	   Endif
    	   nLin+=1
    	   @nLin,000 psay "Embalagem "
    	   @nLin,025 psay "          Qtde."
    	   @nLin,042 psay "  Qtde. Volumes"
           //9,999.99999
           @ nLin,058 psay "Cubagem(M3)"
    	   If nLin >= 59
    	      ImprLinha()
    	      nLin := 1
    	   Endif                  
    	   dbselectarea("ZZO")
    	   dbseek(xFilial("ZZO")+cPedido)
    	   while !eof() .and. (ZZO->ZZO_FILIAL = xFilial("ZZO")) .and. (ZZO->ZZO_PEDIDO == cPedido)
    	       nLin+=1      
            	DbSelectArea("SZ5")
				DbSeek(xFilial("SZ5")+ZZO->ZZO_EMBA)
				If Found()   
					cUn := ALLTRIM(SZ5->Z5_DESCR) 
				else
					cUn := "Diversos"
				Endif
    	       
    	       @nLin,000 psay ZZO->ZZO_EMBA+"-"+cUn
    	       @nLin,025 psay ZZO->ZZO_QTDE picture "@E 999,999,999,999"
    	       @nLin,042 psay ZZO->ZZO_QTDVOL picture "@E 999,999,999,999"
			   @nLin,058 psay ZZO->ZZO_CUBAGE picture "@E 9,999.99999"
    	       nPallets  += ZZO->ZZO_CUBAGE
    	       If nLin >= 59
    	          ImprLinha()
    	          nLin := 1
    	       Endif
    	       dbselectarea("ZZO")
    	       dbskip()
           enddo 
           nLin := nLin + 2
           If !Empty(cxEntrega)
              @ nLin,000 PSAY "OBSERVAÇÃO: "
    	      nLin := nLin + 1
    	      @ nLin,000 PSAY cxEntrega
    	      nLin := nLin + 2
           Endif
           @ nLin, 000 PSAY "PALLET(S): "+Transform(nPallets, "@E 999.99")
           nLin += 1
           nAux = 60 - nLin
           nLin = nLin+nAux
           @nLin,000 psay replicate("_",80)
           nLin = nLin+1
           @nlin,000 PSAY "Pagina: "
           @nLin,8 psay nPag picture "99"
           @nLin,17 psay "CLIENTE : "+SC5->C5_CLIENTE+"-"+substr(iif(SC5->C5_TIPO $ "D_B",SA2->A2_NOME,SA1->A1_NOME),1,30)
           @nLin,64 psay "|PED : "+SubStr(cnumemp,1,2)+"-"+cPedido
		   //MSBAR3("CODE128", 13.34, 8.6 ,Alltrim(cPedido),oPr,Nil,Nil,Nil,nil ,0.6 ,Nil,Nil,Nil)
           nLin = nLin+1
           @nLin,000 psay replicate("_",55)
           @nLin,058 psay "LOCALIZ: "+ALLTRIM(Posicione("SZG", 2, xFilial("SZG")+'01'+SC5->C5_NUM, "ZG_LOCALIZ"))
     
           nPag+=1
           dbSelectArea("TCQ")
           //dbskip()
     Enddo

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³                      FIM DA IMPRESSAO                        ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     DbSelectArea("TCQ")
     DbCloseArea()

     Set Device To Screen
     If aReturn[5] == 1
        Set Printer TO
        DbCommitAll()
        OurSpool(wnrel)
        RecLock("ZZB", .T.)
           ZZB->ZZB_FILIAL := xFilial("ZZB")
           ZZB->ZZB_PEDIDO := cPedido
           ZZB->ZZB_IDLOG  := 'IMV'
           ZZB->ZZB_USRLOG := cUsername
           ZZB->ZZB_DATLOG := dDataBase
           ZZB->ZZB_HORLOG := Time()
        MsUnLock()
     Else
        RecLock("ZZB", .T.)
           ZZB->ZZB_FILIAL := xFilial("ZZB")
           ZZB->ZZB_PEDIDO := cPedido
           ZZB->ZZB_IDLOG  := 'IMI'
           ZZB->ZZB_USRLOG := cUsername
           ZZB->ZZB_DATLOG := dDataBase
           ZZB->ZZB_HORLOG := Time()
        MsUnLock()
     Endif
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                   FUNCOES ESPECIFICAS                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
Programa  : VALIDPERG   Autor:  
Data      : 28/01/02
Descricao : Grava Perguntas
/*/
/*
Static Function ValidPerg()
       Local _sAlias,aRegs,i,j

       _sAlias := Alias()
       DbSelectArea("SX1")
       DbSetOrder(1)
       cPerg := PADR(cPerg,10)
       aRegs := {}

       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       AADD(aRegs, {cPerg, "01", "Pedido de           ?", "", "", "mv_ch1", "C", 06, 0, 0, "G", "", "mv_par01", ""            , "", "", "", "", ""               , "", "", "", "", ""                   , "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , "" } )
       AADD(aRegs, {cPerg, "02", "Pedido Ate          ?", "", "", "mv_ch2", "C", 06, 0, 0, "G", "", "mv_par02", ""            , "", "", "", "", ""               , "", "", "", "", ""                   , "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , "" } )
       AADD(aRegs, {cPerg, "03", "Cliente de          ?", "", "", "mv_ch3", "C", 06, 0, 0, "G", "", "mv_par03", ""            , "", "", "", "", ""               , "", "", "", "", ""                   , "", "", "", "", "", "", "", "", "", "", "", "", "", "SA1", "" } )
       AADD(aRegs, {cPerg, "04", "Cliente Ate         ?", "", "", "mv_ch4", "C", 06, 0, 0, "G", "", "mv_par04", ""            , "", "", "", "", ""               , "", "", "", "", ""                   , "", "", "", "", "", "", "", "", "", "", "", "", "", "SA1", "" } )
       AADD(aRegs, {cPerg, "05", "Data Aprov.Ped. De  ?", "Data Aprov.Ped. De  ?", "Data Aprov.Ped. De  ?", "mv_ch5", "D", 08, 0, 0, "G", "", "mv_par05", ""            , "", "", "", "", ""               , "", "", "", "", ""                   , "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , "" } )
       AADD(aRegs, {cPerg, "06", "Data Aprov.Ped. Ate ?", "Data Aprov.Ped. Ate ?", "Data Aprov.Ped. Ate ?", "mv_ch6", "D", 08, 0, 0, "G", "", "mv_par06", ""            , "", "", "", "", ""               , "", "", "", "", ""                   , "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , "" } )
       AADD(aRegs, {cPerg, "07", "Imprimir            ?", "Imprimir            ?", "Imprimir            ?", "mv_ch7", "C", 15, 0, 0, "C", "", "mv_par07", "Todos"       , "Todos"       , "Todos"       , "", "", "N. Conforme Rev", "N. Conforme Rev", "N. Conforme Rev", "", "", ""                   , ""               , ""               , "", "", "", "", "", "", "", "", "", "", "", "", ""   , "" } )
       For i := 1 to Len(aRegs)
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

       //PutSX1(cPerg, "08"  ,  "Ordem dos itens     ?", "Ordem dos itens     ?", "Ordem dos itens     ?", "mv_ch8", "N",  1, 0, 1, "C"  , "","","","",             "mv_par08","Pedido+Itens", "Pedido+Itens", "Pedido+Itens"   , ""   , "Descrição itens", "Descrição itens", "Descrição itens", "Embalagens", "Embalagens", "Embalagens" , "Quadrantes", "Quadrantes", "Quadrantes",  "Cód. Produto", "Cód. Produto", "Cód. Produto",{},{},{}, "" )
       //PutSX1(cPerg, "09","Bord Pedido:","Bord Pedido:","Bord Pedido:","mv_ch9","C",6,0,0,"G"," ",""," "," ","mv_par09"," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," ",{},{},{}) 

       DbSelectArea(_sAlias)

Return
*/
Static Function Cabecalho()
       Local cTipoCons := ""
      
       //Local oPr := ReturnPrtObj() // imprimir código de barras usando o setprint (sem o tmsprinter)  

       DbSelectArea("SC5") // Cabecalho dos Pedidos
       DbSetorder(1)
       DbSeek(xFilial("SC5")+cPedido,.F.)
       DbSelectArea("SE4") // Cond. Pagamento
       DbSetOrder(1)
       DbSeek(xFilial("SE4")+SC5->C5_CONDPAG)

       nLin = 1
       @nLin, 000 psay "PEDIDOS - RELATORIO PARA PRODUCAO"
       @nLin, 035 psay "EXP. POR : "+cUsername
       //MSBAR3("CODE128", 0.1, 8.8 ,Alltrim(cPedido),oPr,Nil,Nil,Nil,nil ,0.8 ,Nil,Nil,Nil)
       @nLin, 060 psay "EXPEDICAO : "+DTOC(DATE())
       nLin += 1
       @ nLin, 000 PSAY REPLICATE("_",80)
       nLin += 1
       @ nLin,000 psay "PEDIDO : "+SubStr(cnumemp,1,2)+"-"+cPedido
       @ nLin,020 psay "COND. PAGTO : "+SC5->C5_CONDPAG+"-"+SE4->E4_DESCRI
       //@ nLin,064 psay "EXPED : "+DTOC(DATE())

       nPercSubst := 0 // Perc. de Lucro p/ Subst. Tributária
       cTipoCons := "" // Receberá A2_CLAS ou A1_CLAS
       If (SC5->C5_TIPO $ "D_B")
          DbSelectArea("SA2")
          DbSetOrder(1)
          DbSeek(xFilial("SA2")+SC5->C5_CLIENTE,.F.)
          If Found()
             DbSelectArea("SZ8")
             dbseek(xFilial("SZ8")+SA2->A2_EST+SA2->A2_CLAS)
             If found()
                nPercSubst := SZ8->Z8_PERC
             Endif
             cTipoCons := SA2->A2_CLAS
          Endif      
       Else
          DbSelectArea("SA1")
          DbSetOrder(1)
          DbSeek(xFilial("SA1")+SC5->C5_CLIENTE,.F.)
          If found()  
//***********************                                                  
		//Exceção para MT
        //Cleber (24/08/11) - Tratamento para MT com MVA diferenciado e também sem desconto ICMS próprio, de acordo com CNAE
           If (SA1->A1_EST = 'MT') .AND. (SA1->A1_CLAS == 'V') .AND. (Alltrim(SA1->A1_CNAE) $ Alltrim(GetMv("MV_CNAEMT")))  
           		nPercSubst := 45
           Endif

//****************************          
          
             DbSelectArea("SZ8")
             DbSeek(xFilial("SZ8")+SA1->A1_EST+SA1->A1_CLAS)
             If found()
                nPercSubst := SZ8->Z8_PERC
             Endif
             cTipoCons := SA1->A1_CLAS
          Endif
       Endif
       If !Empty(cTipoCons)
          cClas := U_TIPOCONS(cTipoCons)
       Else
          cClas := ""
       Endif

       nLin += 1
       @nLin,000 psay "CLIENTE : "+SC5->C5_CLIENTE+"-"+iif(SC5->C5_TIPO $ "D_B",SA2->A2_NOME,SA1->A1_NOME)+"   "+cClas //iif(SC5->C5_TIPO $ "D_B","",cCLAS)
       nLin += 1
       @nLin,000 psay "FONE: "+iif(SC5->C5_TIPO $ "D_B",SA2->A2_DDD+'-'+SA2->A2_TEL,SA1->A1_DDD+'-'+SA1->A1_TEL)
       @nLin,030 psay "CIDADE: "+AllTrim(iif(SC5->C5_TIPO $ "D_B",SUBSTR(SA2->A2_MUN,1,35),SUBSTR(SA1->A1_MUN,1,35))) + "-" + iif(SC5->C5_TIPO $ "D_B",SA2->A2_EST,SA1->A1_EST)
       //@nLin,062 psay "LOCAL: "+ALLTRIM(Posicione("SZG", 2, xFilial("SZG")+'01'+cPedido, "ZG_LOCALIZ"))       
       nLin += 1
       @nLin,000 psay "ENDERECO : "+ALLTRIM(SUBSTR(iif(SC5->C5_TIPO $ "D_B",SA2->A2_END,SA1->A1_END),1,40))+" - "+iif(SC5->C5_TIPO $ "D_B",SA2->A2_BAIRRO,SA1->A1_BAIRRO)
       nLin += 1
       DbSelectArea("SA3")
       DbSetorder(1)
       DbSeek(xFilial("SA3")+SC5->C5_VEND1)
       If Found()
          @nLin,000 psay "REPRES : "+SC5->C5_VEND1+"-"+SUBSTR(SA3->A3_NOME,1,40)
       Endif
       If !Empty(SC5->C5_PEDPROG)
          @ nLin,059 PSAY "PED. PROG.: "+DTOC(SC5->C5_PEDPROG)
       Endif
       nLin += 1
       DbSelectArea("SA4")
       DbSetOrder(1)
       DbSeek(xFilial("SA4")+SC5->C5_TRANSP)
       If Found()
          @nLin,000 psay "TRANSPORTADORA : "+SC5->C5_TRANSP+"-"+SA4->A4_NOME
       Endif
       nLin += 1
       DbSeek(xFilial("SA4")+SC5->C5_REDESP)
       If Found()
          @nLin,000 psay "REDESPACHO : "+SC5->C5_REDESP+"-"+ALLTRIM(SA4->A4_NOME)+" Região : "+alltrim(SA4->A4_REGIAO)
       Endif
       If !Empty(SA1->A1_ENDENT)
          If !SC5->C5_TIPO $ "D_B"
             cxEntrega := "ENTREGA: "+Alltrim(SA1->A1_ENDENT)+Iif(Empty(SA1->A1_BAIRROE),""," - BAIRRO : "+ALLTRIM(SA1->A1_BAIRROE))+IIf(Empty(SA1->A1_CEPE),""," - "+Transform(SA1->A1_CEPE,"@R 99999-999"))
          Endif
       Endif
       nLin += 1
       @nLin,000 psay replicate("=",80)
       nLin += 1
       @nLin,000 psay "COD PRODUTO"
       @nLin,013 PSAY "DESCRICAO"
       @nLin,028 psay "B.P->("+Alltrim(Posicione("SZG", 2, xFilial("SZG")+'01'+cPedido, "ZG_CODIGO"))+")"
       @nLin,044 psay "  QTDE"
       @nLin,051 psay "UNIDADE"
       @nLin,062 psay "QUADRTE"
       @nLin,070 psay "  PR. UNIT."
       nLin+=1
       @nLin,000 psay replicate("=",80)
       nLin+=1
Return

Static Function ImprLinha()
       nAux = 60 - nLin
       nLin = nLin+nAux
       @ nLin,000 psay replicate("_",80)
       nLin = nLin+1
       @ nlin,000 PSAY "Pagina: "
       @ nLin,8 psay nPag picture "99"
       @ nLin,17 psay "CLIENTE : "+SC5->C5_CLIENTE+"-"+substr(iif(SC5->C5_TIPO $ "D_B",SA2->A2_NOME,SA1->A1_NOME),1,30)
       @ nLin,64 psay "|PED : "+SubStr(cnumemp,1,2)+"-"+cPedido
	   //MSBAR3("CODE128", 13.2, 8.6 ,Alltrim(cPedido),oPr,Nil,Nil,Nil,nil ,0.6 ,Nil,Nil,Nil)
       nLin = nLin+1
       @nLin,000 psay replicate("_",55)
       @nLin,058 psay "LOCALIZ: "+ALLTRIM(Posicione("SZG", 2, xFilial("SZG")+'01'+SC5->C5_NUM, "ZG_LOCALIZ"))           

       //@ nLin,000 psay replicate("_",71)
       nPag += 1
Return

