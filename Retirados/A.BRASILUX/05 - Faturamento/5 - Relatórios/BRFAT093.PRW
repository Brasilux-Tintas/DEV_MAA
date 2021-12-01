#include "rwmake.ch"
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFAT059 ºAutor  ³ Cleber O. Dominguesº Data ³  22/03/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Emissão de Notas fiscais                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
- Variaveis utilizadas para parametros
  - mv_par01     -- Nf de
  - mv_par02     -- NF até
  - mv_par03     -- Série
*/
User Function BRFAT093()
     Local cDesc1        := PADC("Programa para emitir Notas Fiscais de Entrada",74)
     Local cDesc2        := PADC(" ",74)
     Local cDesc3        := PADC(" ",74)
     Local titulo        := "EMISSAO DE NOTAS FISCAIS DE ENTRADA"
     Private nLin        := 0
     Private CbTxt       := ""
     Private limite      := 220
     Private tamanho     := "G"
     Private nomeprog    := "BRFAT093"
     Private nTipo       := 15
     Private aReturn     := {"Especial", 1, "Administracao", 1, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := "BRFT93"
     Private CbCont      := 0
     Private m_pag       := 01
     Private wnrel       := "BRFAT093"
     Private cString     := "SF1"
     Private lAbortPrint := .F.
     Private lContinua   := .T.
     Private Alfa        := 0
     Private Z           := 0
     Private M           := 0
     Private cCabec      := PADC("Emissao de Notas Fiscais de Entrada",27)
     Private cCabec1     := ""
     Private cCabec2     := ""
     Private cCabec3     := ""
     Private nTamNf      := 220     // Apenas Informativo
     Private cNatureza   := ""

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Envia controle para a funcao SETPRINT                        ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     ValidPerg()
     Pergunte(cPerg, .F.)

     wnrel := SetPrint(cString, wnrel, cPerg, @Titulo, cDesc1, cDesc2, cDesc3, .f., , .f., Tamanho, , .f.)
     If nLastKey == 27
        Return
     Endif
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Verifica Posicao do Formulario na Impressora                 ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     SetDefault(aReturn, cString)

     If nLastKey == 27
        Return
     Endif
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Inicio do Processamento do Relatorio                         ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     #IFDEF WINDOWS
            RptStatus({|| RptDetail(cCabec1, cCabec2, Titulo)}, Titulo)
            Return
     #ENDIF

Static Function RptDetail(cCabec1, cCabec2, Titulo)
       SetPrc(0,0)                 //(Zera o Formulario)
       nLin = 0
       @ nLin, 00 psay chr(27)+"0" //Comprimir Linhas p/ 1/8
       @ nLin, 00 psay chr(15)     //Comprimir colunas

       DbSelectArea("SA1")         //Clientes
       DbSetOrder(1)

       DbSelectArea("SA2")         //Fornecedores
       DbSetOrder(1)

       DbSelectArea("SF4")         //TES
       DbSetOrder(1)

       DbSelectArea('SM4')         //Formulas
       DbSetOrder(1)

       DbSelectArea("SC5")         //Pedidos de Venda
       DbSetOrder(1)

       DbSelectArea("SZ5")
       DbSetOrder(1)               //Tipos de Embalagem

       DbSelectArea("SZ8")         //
       DbSetOrder(1)

       DbSelectArea("SF1")         //Cabecalho da Nota Fiscal Saida
       DbSetOrder(1)
       DbSeek(xFilial("SF1")+mv_par01+mv_par03, .t.)

       DbSelectArea("SD1")         //Itens de Venda da Nota Fiscal
       DbSetOrder(1)               //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM                                                                                                     
       DbSeek(xFilial("SD1")+mv_par01+mv_par03, .t.)

       DbSelectArea("SF3")         //Livros Fiscais
       DbSetOrder(4)               //F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE

       SetRegua(Iif( (Val(mv_par02)-Val(mv_par01)) <= 0, 1, (Val(mv_par02)-Val(mv_par01))) ) //Inicializa  regua de impressao
       lContinua := .t.

       DbSelectArea("SF1")

       While !Eof() .and. (SF1->F1_FILIAL == xFilial("SF1")) .and. (SF1->F1_DOC >= mv_par01) .and. (SF1->F1_DOC <= mv_par02) .and. lContinua
             If lAbortPrint
                @ 00, 01 PSAY "** CANCELADO PELO OPERADOR **"
                lContinua := .F.
                Exit
             Endif
			 if (SF1->F1_SERIE = mv_par03 .and. SF1->F1_FORMUL $ 'S')
	             Imprime()
	   		 endif 
             DbSelectArea("SF1")
             DbSkip()
             IncRegua()  //Termometro de Impressao
       EndDo

       @ nLin,000 PSAY chr(18)
       @ nLin,000 PSAY chr(27)+"2" 

       Set Device To Screen
       If aReturn[5] == 1
          Set Printer TO
          DbCommitAll()
          OurSpool(wnrel)
       Endif

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                   FUNCOES ESPECIFICAS                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function Imprime()
       // Imprimir cada nota
       Local nQtdeFolhas, nQtdeItens, nAuxMens, lTemMens, i, nAux, cNronf, nContFolhas,;
             cMensNF, cCepMunEst, Cod, nSoma, lImprimeTotal, nBaseIcms, nValorIcms
       Local cCfop, nCont, nContCfo, nQuantosItens, cPedido, cNatureza
       Local cIeSubst, nBaseIcms1, nVlrIcms1, nBaseIcms2, nVlrrIcms2, nTotaliza, cUltTes
       Local nDescZFR  := 0, cTipoCons, cEmpresa, lDescPiscof
       Local cNfOrigem // NF's origem, p/ o caso de ICMS ou IPI complemento
       Local aIcms     := {}, cAux, nPosSub
       Local aFormulas := {} // Cadastras as fórmulas já impressas, p/ não reimprimir
       Local nVlrUnit, nVlrTotal, lVendaSubst, lAchou, cPict, aEmbaOrd, cMensEmba, cOnu, cNroRisco,;
             cClasseRisco, nAuxVol, nAuxPesoL, nAuxPesoB
       Local cQuery    := ""
       Private aEmba   := {}
       Private nColunas:= 200 // Qtde de Caracters de uma linha p/ impressão dos itens da NF
       cNroNf := SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE 
       
       cQuery := ""
       cQuery += "SELECT * "
       cQuery += "FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK) "
       cQuery += "WHERE (SD1.D1_FILIAL = '"+SF1->F1_FILIAL+"' AND SD1.D1_DOC = '"+SF1->F1_DOC+"' AND SD1.D1_SERIE = '"+SF1->F1_SERIE
       cQuery += "') AND (SD1.D1_FORNECE = '"+SF1->F1_FORNECE+"') AND (D_E_L_E_T_ <> '*') "
       cQuery += "ORDER BY SD1.D1_CF, SD1.D1_COD"
       TCQUERY cQuery NEW ALIAS "TMPNFPROD"

       DbSelectArea("TMPNFPROD")
       DbGoTop()
       cMensNf     := ""
       lTemMens    := .f.
       lVendaSubst := .f. //Venda passível de subst. tributária ???
       nCont        = 0
       cCfop        = ""
       cPedido     := ""
       aIcms       := {}
       aFormulas   := {}
       nContCfo    := 0
       nDescZFR    := 0 // Desconto Zona Franca
       lDescPisCof := .f. // Identifica se tem desconto ZFM, portaria Suframa 162/2005
       cNfOrigem   := "" // Guardar Notas Fiscais Origem p/ o caso de Notas de Complemento de ICMS/IPI
       aEmba       := {}
       While !Eof()
             If Empty(cPedido)
                cPedido := TMPNFPROD->D1_PEDIDO	
//                DbSelectArea("SC5")     // Pedidos
//                DbSeek(xFilial("SC5")+cPedido)
             Endif
             nCont = nCont+1
             If !(Alltrim(TMPNFPROD->D1_CF) $ cCfop)
                nContCfo += 1
                If nContCfo > 1
                   cCfop := cCfop+"/"
                Endif
                cCfop = cCfop+Alltrim(TMPNFPROD->D1_CF)
             Endif
             If len(aIcms) < nContCfo
                aadd(aIcms,{0, 0, ""}) // Base Icms,Valor Icms,Subst. Trib?
             Endif
//             cTipBas := SC5->C5_BASEICM
             aIcms[nContCfo,1] += TMPNFPROD->D1_BASEICM
             aIcms[nContCfo,2] += TMPNFPROD->D1_VALICM
             cAux              := aIcms[nContCfo,3]
             aIcms[nContCfo,3]  = Iif((TMPNFPROD->D1_BRICMS <= 0) .and. (cAux # "S"), "N", "S")
             cUltTes           := TMPNFPROD->D1_TES
//             nDescZFR          += TMPNFPROD->D1_DESCZFR
             // Guardar Notas Fiscais Origem p/ o caso de Notas de Complemento de ICMS/IPI
             If Len(cNfOrigem) > 0
                cNfOrigem += ", "
             Endif
             cNfOrigem         += Alltrim(TMPNFPROD->D1_NFORI)

             DbSelectArea("SF4")
             DbSeek(xFilial("SF4")+TMPNFPROD->D1_TES)
             If Found()
/*                If (SF4->F4_PISCRED = '4') .and. (SF4->F4_PISCOF = '3') .and. SF1->F2_CODCID $ '002054.002259' .and. Posicione("SA1", 1, xFilial("SA1")+SF1->F2_CLIENTE+SF1->F2_LOJA, "A1_CALCSUF") $ 'S'
                   lDescPisCof := .t.
                Endif
*/                
                If !Empty(alltrim(SF4->F4_FORMULA))
                   lAchou = .f.
                   For i := 1 to Len(aFormulas)
                       If aFormulas[i] = SF4->F4_FORMULA
                          lAchou = .t.
                       Endif
                   Next
                   If !lAchou
                      aadd(aFormulas, SF4->F4_FORMULA)
                      DbSelectArea("SM4")
                      DbSeek(xFilial("SM4")+SF4->F4_FORMULA)
                      If Found() .and. !Empty(Alltrim(SM4->M4_MENSNF))
                         If !Empty(cMensNf)
                            cMensNf += "**"
                         Endif
                         cMensNf += u_tiraacento(alltrim(SM4->M4_MENSNF))
                      Endif
                   Endif
                Endif
                If (Len(Alltrim(TMPNFPROD->D1_COD)) == 12) .and. (SF4->F4_DUPLIC == 'S') // Se for tinta e gera fatura, marcar que existe produto passível de aplic. de Subst. Tributária
                   lVendaSubst := .t.
                Endif
             Endif
             DbSelectArea("TMPNFPROD")
             DbSkip()
       Enddo  
/*       If lDescPisCof // Se tiver desconto pis/cofins de acordo c/ portaria Suframa 162/2005, destacar
          DbSelectArea("SF3")
            DbSeek(SF1->F2_FILIAL+SF1->F2_CLIENTE+SF1->F2_LOJA+SF1->F2_DOC+SF1->F2_SERIE,.F.)  //F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE
            While !eof() .and. ((SF1->F2_FILIAL+SF1->F2_CLIENTE+SF1->F2_LOJA+SF1->F2_DOC+SF1->F2_SERIE) = (SF3->F3_FILIAL+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE))
                  If substr(SF3->F3_CFO,1,1) >= "5"
                     nDescPisCof += SF3->F3_VALOBSE
                  Endif
                  DbSkip()
            Enddo
            nDescPisCof -= nDescZFR 
       Endif                        

       aEmbaOrd  := aSort(aEmba,,, { |x, y| x[1] < y[1] })
       cMensEmba := ""
       If Len(aEmbaOrd) > 0
          nAux := Len(cMensNf) % nColunas //Resto
          If nAux > 0
             cMensNf = Space(nColunas-nAux)+cMensNf
          Endif
          //                      999,999	        999,999
          //     0         1         2         3         4         5
          //      12345678901234567890123456789012345678901234567890123456789
          cAux = "EMBALAGEM          QTDE           VOLUMES"
          cAux = cAux + Space(nColunas - Len(cAux))
          cMensEmba += cAux
       Endif
       For i := 1 To Len(aEmbaOrd)
           cAux  = SubStr(Alltrim(SubStr(aEmbaOrd[i][3],1,18)), 1, 16)
           cAux  = cAux+Space(16-Len(cAux))
           cAux += Iif(aEmbaOrd[i][1] != "  ", Transform(aEmbaOrd[i][2],"999,999"), "--")
           cAux  = cAux+Space(34-Len(cAux))
           If (aEmbaOrd[i][2] > 0) .and. (aEmbaOrd[i][1] != "  ")
              nAux = U_DetVolEmba(aEmbaOrd[i][1], aEmbaOrd[i][2])
           Else
              nAux = aEmbaOrd[i][2]
           Endif
           cAux += Transform(nAux, "999,999")
           cAux += Space(nColunas - Len(cAux))
           cMensEmba += cAux
       Next
       If !Empty(cMensEmba)
          cMensEmba += Replicate("-",41)+Space(nColunas-41)
          cMensNf    = cMensNf + cMensEmba
       Endif 
*/       

       nQuantosItens := nCont

       DbSelectArea("SF4")
       DbSetOrder(1)
       DbSeek(xFilial("SF4")+cUltTes)
       cNatureza := alltrim(SF4->F4_TEXTO) // Natureza da Operacao
       cTipoCons  = ""
       If !(SF1->F1_TIPO $ "D_B")
          DbSelectArea("SA2") // Fornecedores
          DbSeek(xFilial("SA2")+Alltrim(SF1->F1_FORNECE))
          If Found()
             cTipoCons := SA2->A2_CLAS
          Endif
       Else
          DbSelectArea("SA1") // CLIENTES
          DbSeek(xFilial("SA1")+SF1->F1_FORNECE)
          If Found()
             cTipoCons := SA1->A1_CLAS
          Endif
       Endif

       cIeSubst := ""
/*       DbSelectArea("SZ8")
       DbSeek(xFilial("SZ8")+SF1->F2_EST+SF1->F2_CLAS) //iif(SC5->C5_TIPO $ "D_B",SA2->A2_EST+SA2->A2_CLAS,SA1->A1_EST+SA1->A1_CLAS))
       If Found()
          cIeSubst := Alltrim(SZ8->Z8_IEST)
       Endif
*/
       DbSelectArea("SA4")                    // * Transportadoras
       DbSetOrder(1)

/*       If nContCfo > 1
          nQuantosItens += 2 * nContCfo
       Endif */

       nQtdeItens = 41 // Qtde máxima de linhas p/ itens da NF	
//       nQtdeItens = 49 // Qtde máxima de linhas p/ itens da NF	
       //nQtdeItens = 57 // Qtde máxima de linhas p/ itens da NF	

		if !empty(cNfOrigem)
			cMensNf += "REF. NOTA FISCAL DEVOLUCAO DE ORIGEM NRO " + cNfOrigem
		ENDIF 
/*       If SF1->F2_TIPO $ "I_P"
          cMensNf += "NOTA FISCAL COMPLEMENTO DE "+IIF(SF1->F2_TIPO == "I","ICMS","IPI")+;
                     ", REF. NOTA FISCAL ORIGEM NRO " + cNfOrigem
       Else
          If lVendaSubst .and. (SF1->F2_EST != "EX")
             If (cTipoCons = "V") .or. (SF1->F2_EST == "MS")
                If SF1->F2_ICMSRET > 0
                   If Empty(cIeSubst)
                      cMensNf += "ICMS RETIDO ANTECIPADAMENTE NOS TERMOS DO CONVE"
                      cMensNf += "NIO ICMS 74/94"
                   Else
                      cMensNf += "IMPOSTO RETIDO ANTECIPADAMENTE NOS TERMOS DO AR"
                      cMensNf += "TIGO 312 DO RICMS/2000"
                   Endif
                Endif
             Elseif cTipoCons = "C"
                    If SF1->F2_ICMSRET > 0
                       cMensNf += "ICMS RETIDO ANTECIPADAMENTE NOS TERMOS DO CONVE"
                       cMensNf += "NIO ICMS 74/94 OPERACOES INTERESTADUAIS - PARA "
                       cMensNf += "CONSUMO PROPRIO"
                    Endif
             Elseif cTipoCons = "I"
                    cMensNf += "NAO APLICABILIDAD DA SUBST. TRIBUT. CONFORME AR-"
                    cMensNf += "TIGO 243-I DO RICMS/91 CONVENIO ICMS 74/94 - INTE"
                    cMensNf += "GRACAO OU CONSUMO EM PROCESSO DE INDUSTRIALIZACAO"
             Elseif cTipoCons = "D"
                    cMensNf += "OPER. S/ RETENCAO ICMS PREV CONV. 74/94 P/ FORCA"
                    cMensNf += " REG. ESP. No. 141/93 - SFEAM."
                    cMensNf += " OBS.: CLIENTE COM REGIME ESPECIAL."
             Elseif Empty(cTipoCons)
                   cMensNf += "NAO APLICABILIDADE DA SUBST. TRIBUT. CONFORME AR-"
                   cMensNf += "TIGO 243-I DO RICMS/91 CONVENIO ICMS 74/94 - INTE-"
                   cMensNf += "GRACAO OU CONSUMO PROPRIO"
             Endif
          Endif
       Endif

       If SF1->F2_ICMSRET > 0
          If !empty(cMensNf)
             cMensNf += "**"
          Endif
          nPosSub := 0
          For i := 1 to Len(aIcms)
              If aIcms[i,3] == "S"
                 nPosSub := i
              Endif
          Next
          If nPosSub > 0
             cMensNF = cMensNF+"ICMS REF. MERCADORIAS COM SUBST -> BASE CALC : "+;
             AllTrim(Transform(aIcms[nPosSub,1], "999,999.99"))+;
             " ICMS: "+Alltrim(Transform(aIcms[nPosSub,2], "999,999,999.99"))
          Endif	
       Endif
       If !Empty(Alltrim(SC5->C5_MENPAD))
          If !Empty(cMensNf)
             cMensNf += "**"
          Endif
          cAux = U_TIRAACENTO(Alltrim(FORMULA(SC5->C5_MENPAD)))
          If !Empty(cAux)
             cMensNF += Iif(!Empty(cMensNF),"**","")+cAux
          Endif
       Endif
       //cAux = U_TIRAACENTO(Alltrim(SC5->C5_OBSNF))
       cAux = U_TIRAACENTO(Alltrim(MSMM(SC5->C5_OBSNFS)))
       If !Empty(cAux)
          cMensNF += Iif(!Empty(cMensNF),"**","")+cAux            // Mensagem para a Nota Fiscal
       Endif


       If lDescPisCof
          If !Empty(cMensNf)
             cMensNf += "**"
          Endif
          cMensNF = cMensNF+"DESCONTOS DE "+Alltrim(Transform(nDescZFR, "9,999,999.99"))+;
          " DE ICMS(7%) REF. A ZONA FRANCA, PIS E COFINS(9.25%) SEG PORTARIA SUFRAMA 162/2005, ART. 2o. DA LEI 10996/2004."
       Else 
          If nDescZFR > 0
             If !Empty(cMensNf)
                cMensNf+= "**"
             Endif
             cMensNF = cMensNF+"DESCONTO DE "+Alltrim(Transform(nDescZFR, "9,999,999.99"))+;
             "(7%) REF. A ZONA FRANCA"
          Endif
       Endif
*/       

       // Mensagem Padrão da TES
       If !Empty(Alltrim(SF4->F4_FORMULA)) .and. ((SubStr(SF4->F4_FORMULA,1,1) == '"') .OR. ;
          (Substr(SF4->F4_FORMULA,1,1) == "'"))
          If !Empty(cMensNf)
             cMensNf+= "**"
          Endif
          cAux = u_Tiraacento(Alltrim(FORMULA(SF4->F4_FORMULA)))
          If !Empty(cAux)
             cMensNF += Iif(!Empty(cMensNF),"**","")+cAux
          Endif
       Endif

       // Mensagem padrão, fixada no Cliente
       If (SC5->C5_TIPO $ "D_B") .AND. !Empty(SA1->A1_MENSAGE)
          DbSelectArea("SM4")
          DbSeek(xFilial("SM4")+SA1 ->A1_MENSAGE)
          If Found() .and. !Empty(alltrim(SM4->M4_MENSNF))
             If !Empty(cMensNf)
                cMensNf += "**"
             Endif
             cMensNf += u_Tiraacento(Alltrim(SM4->M4_MENSNF))
          Endif
       Endif

       nAux = Len(cMensNF)
       For i := 1 to nAux
           If SubStr(cMensNF,i,2) != "**"
              lTemMens = .t.
              Exit
           Endif
       Next

       //Inclusão de Mensagem Padrão a ser impressa pela gráfica futuramente
       //*******
       nAux = Len(cMensNf) / 200
       If (nAux - int(nAux)) > 0
          cMensNf += Space((int(nAux)+1)*200 - Len(cMensNf))
       Endif
       lTemMens = .t.
       //******	
       nAuxMens = 0
       If lTemMens 
          nAuxMens = len(cMensNF) / 200
          If (nAuxMens - Int(nAuxMens)) > 0
             nAuxMens = Int(nAuxMens) + 1
          Endif
       Else
          cMensNF = ""
       Endif
       nQuantosItens += nAuxMens
       nQtdeFolhas = (nQuantosItens) / nQtdeItens
       If (nQtdeFolhas - Int(nQtdeFolhas)) > 0
          nQtdeFolhas = int(nQtdeFolhas)+1
       Endif

       nContLin = 0
       lImprimeTotal = .f.
       DbSelectArea("TMPNFPROD")
       DbGoTop()
       cAuxCfop = TMPNFPROD->D1_CF
       nSoma = 0
       nTotaliza := 0
       For nContFolhas := 1 to nQtdeFolhas	
           DbSelectArea("SF1")
           //nLin += 2
           //@nLin,00 psay " "
           nLin++
           @ nLin,42 PSAY cPedido
           nLin += 2

/*           DbSelectArea("SA4")
           If !Empty(SC5->C5_REDESP)
              DbSeek(xFilial("SA4")+SC5->C5_REDESP)
              @ nLin,005 PSAY alltrim(SA4->A4_NOME)
           Endif
           @ nLin,158 PSAY "XX"
*/           

           @ nLin,195 PSAY SF1->F1_DOC
           nLin ++
//           If !Empty(SC5->C5_REDESP)
//              @ nLin,005 PSAY Alltrim(SA4->A4_END)
//           Endif
           nLin ++
/*           If !Empty(SC5->C5_REDESP)
              @ nLin,005 PSAY SA4->A4_TEL+"    "+Iif(SC5->C5_TPFRETE == "C", "CIF", "FOB")
           Endif
*/
           // L O C A L   D E  E N T R E G A
           nLin := nLin + 1
//           @ nLin,015 PSAY Iif(SC5->C5_TIPO $ "D_B", "", Iif(Empty(SA1->A1_ENDENT), Alltrim(SA1->A1_END), AllTrim(SA1->A1_ENDENT)))
           nLin := nLin + 1
//           @ nLin,000 PSAY Iif(SC5->C5_TIPO $ "D_B", "", AllTrim(SA1->A1_BAIRROE)+" - "+SA1->A1_CEPE+" - "+SA1->A1_ESTE)
           nLin ++
           @ nLin,056 PSAY cNatureza
           @ nLin,102 PSAY cCfop

//           If SF1->F2_ICMSRET > 0
//              @ nLin,117 PSAY cIeSubst
//           Endif

           nLin++
           @ nLin,000 PSAY "("+upper(u_Tipocons(cTipoCons))+")"
           nLin ++
           @ nLin,005 PSAY "FOLHA "+str(nContFolhas,1)+"/"+str(nQtdeFolhas,1)
           nLin ++
           @ nLin,056 PSAY Iif(!(SF1->F1_TIPO $ "D_B"), SA2->A2_NOME, SA1->A1_NOME)

           If Len(Alltrim(Iif(!(SF1->F1_TIPO $ "D_B"), SA2->A2_CGC, SA1->A1_CGC))) > 11
              @ nLin,157 PSAY Iif(!(SF1->F1_TIPO $ "D_B"), SA2->A2_CGC, SA1->A1_CGC) Picture "@R 99.999.999/9999-99"
           Else
              @ nLin,157 PSAY Iif(!(SF1->F1_TIPO $ "D_B"), SA2->A2_CGC, SA1->A1_CGC) Picture "@R 999.999.999-99"
           Endif
           @ nLin,192 PSAY SF1->F1_EMISSAO
//           cOnu := Alltrim(SC5->C5_ONU)
           nLin += 1
           cNroRisco := ""
           cClasseRisco := ""
/*           If !Empty(cOnu)
              Do Case
                 Case cnumemp == "01010101" .OR. cnumemp == "01060101"
                      cOnu         := Iif(Empty(cOnu), '1263', cOnu)
                      cNroRisco    := "33"
                      cClasseRisco := "3"
                 Case cnumemp == "01010104"
                      cOnu         := Iif(Empty(cOnu), '1866', cOnu)
                      cNroRisco    := "30"
                      cClasseRisco := "3"
              EndCase
           Endif
           
           @ nLin,000 PSAY Iif(!Empty(cOnu), "NUMERO DA ONU : "+cOnu, " ")+Iif(SC5->C5_BOLETO == 'S', "       ACOMPANHA BOLETO", " ")
*/           
           nLin += 1
//           @ nLin,000 PSAY Iif(!Empty(cNroRisco), "NRO DE RISCO : "+cNroRisco, " ")
           @ nLin,056 PSAY Iif(!(SF1->F1_TIPO $ "D_B"), SA2->A2_END, SA1->A1_END)
           @ nLin,136 PSAY Substr(Iif(!(SF1->F1_TIPO $ "D_B"), SA2->A2_BAIRRO, SA1->A1_BAIRRO), 1, 19)
           @ nLin,172 PSAY Iif(!(SF1->F1_TIPO $ "D_B"), SA2->A2_CEP, SA1->A1_CEP)     Picture "@R 99999-999"
           nLin++
//           @ nLin,000 PSAY Iif(!Empty(cClasseRisco), "CLASSE DE RISCO : "+cClasseRisco, " ")
           nLin++ 
/*           cAux = ""
           If !(SC5->C5_TIPO $ "D_B") .and. !Empty(SA1->A1_SUFRAMA)
              cAux += "SUFRAMA: "+Alltrim(SA1->A1_SUFRAMA)
           Endif
           If Len(Alltrim(SC5->C5_ESPECI4)) > 0
              cAux += " | ********"
           Endif
           @ nLin,000 PSAY Iif(!Empty(cAux), cAux, " ")
*/           
           @ nLin,056 PSAY Iif(!(SF1->F1_TIPO $ "D_B"), SA2->A2_MUN, SA1->A1_MUN)
           @ nLin,115 PSAY Iif(!(SF1->F1_TIPO $ "D_B"), TRIM(SA2->A2_DDD)+'-'+SA2->A2_TEL, TRIM(SA1->A1_DDD)+'-'+SA1->A1_TEL)
           @ nLin,149 PSAY SF1->F1_EST //iif(SC5->C5_TIPO $ "D_B",SA2->A2_EST,SA1->A1_EST)
           @ nLin,157 PSAY iif(!(SF1->F1_TIPO $ "D_B"),SA2->A2_INSCR,SA1->A1_INSCR)
           nLin++

           nLin += 3
           @ nLin,000 PSAY " "

           Duplic() //Imprimir Parcelas a Pagar

           nLin += 3

           DbSelectArea("TMPNFPROD")
/*           If nTotaliza > 0
              If nTotaliza == 1
                 nLin ++
                 @ nLin,158 PSAY "      ----------"
                 nTotaliza ++
                 nContLin ++
              Endif
              If nTotaliza == 2
                 nLin ++
                 @ nLin,130 PSAY "Total Parcial --> "
                 @ nLin,158 PSAY nSoma  Picture "9,999,999,999.99"
                 nContLin ++
                 nTotaliza = 0
                 If !Eof()
                    nSoma = 0
                 Endif
              Endif
           Endif

*/
           While !Eof() .and. (nContLin < (nContFolhas * nQtdeItens))
                 nContLin = nContLin + 1
                 nLin ++
                 @ nLin,000     psay ALLTRIM(TMPNFPROD->D1_COD) picture "@R XXX99.99.999-99"
                 DbSelectArea("SB1")
                 DbSeek(xFilial("SB1")+TMPNFPROD->D1_COD)
                 If Found()
                    //@ nLin,025 psay SB1->B1_DESC
                    @ nLin,025 PSAY Iif(Len(Alltrim(SB1->B1_COD))< 12, "",  Iif(Empty(Alltrim(SB1->B1_DESCLIN)), Alltrim(Posicione("SZ1", 1, xFilial("SZ1")+SubStr(SB1->B1_COD,4,2), "Z1_DESCR")), Alltrim(SB1->B1_DESCLIN) )+" - ")+Alltrim(SB1->B1_DESC)
                    @ nLin,096 PSAY SB1->B1_POSIPI Picture "@R 9999.99.99.99"
                 Endif
                 @ nLin,116 PSAY TMPNFPROD->D1_CLASFIS
                 If Len(Alltrim(TMPNFPROD->D1_COD)) == 12
                    @ nLin,122 PSAY SubStr(TMPNFPROD->D1_COD, 11, 2)
                 Else
                    @ nLin,122 PSAY TMPNFPROD->D1_UM
                 Endif
                 nAux = TMPNFPROD->D1_QUANT - Int(TMPNFPROD->D1_QUANT)
                 If (nAux > 0)
                    cPict = "9999.9999"
                 Else
                    cPict = "9,999,999"
                 Endif
                 @ nLin,126 PSAY TMPNFPROD->D1_QUANT  Picture cPict
                 If SF1->F1_TIPO $ "I"
                    nVlrUnit  = 0
                    nVlrTotal = 0
                 Else
                    nVlrUnit  = TMPNFPROD->D1_VUNIT
                    nVlrTotal = TMPNFPROD->D1_TOTAL
                 Endif
                 @ nLin,137 PSAY nVlrUnit             Picture "@Z 9,999,999.99999"
                 @ nLin,158 PSAY nVlrTotal            Picture "@Z 9,999,999,999.99"
                 @ nLin,179 PSAY TMPNFPROD->D1_PICM   Picture "99"
                 @ nLin,181 PSAY "%"
                 @ nLin,187 PSAY TMPNFPROD->D1_IPI    Picture "99"
                 @ nLin,189 PSAY "%"
                 @ nLin,198 PSAY TMPNFPROD->D1_VALIPI Picture "9,999.99"
                 nSoma = nSoma+TMPNFPROD->D1_TOTAL

                 DbSelectArea("TMPNFPROD")
                 DbSkip()

/*                 If nContCfo > 1
                    If Eof() .or. (TMPNFPROD->D1_CF != cAuxCfop)
                       If !Eof()
                          cAuxCfop = TMPNFPROD->D1_CF
                       Endif
                       If ((nContLin + 1) > (nContFolhas * nQtdeItens))
                          nTotaliza := 1
                       Else
                          nLin ++
                          @ nLin,158 PSAY "      ----------"
                          nContLin ++
                          If ((nContLin+1) > (nContFolhas * nQtdeItens))
                             nTotaliza := 2
                          Else
                             nLin ++
                             @ nLin,130 PSAY "Total Parcial --> "
                             @ nLin,158 PSAY nSoma Picture "9,999,999,999.99"
                             nContLin ++
                             nTotaliza = 0
                             If !Eof()
                                nSoma = 0
                             Endif
                          Endif
                       Endif
                    Endif
                 Endif
*/                 
           Enddo
           DbSelectArea("SF1")
           If (nContFolhas == nQtdeFolhas)
              If lTemMens
                 nLin += (nQtdeItens*nQtdeFolhas) - nAuxMens - nContLin
                 @ nLin,000 PSAY " "
                 For i := 1 To nAuxMens
                     nLin++
                     @ nLin,000 PSAY SubStr(cMensNF, i*200 - 199, 200)
                 Next
              Else
                 nLin += (nQtdeItens*nQtdeFolhas) - nContLin
                 @ nLin,000 PSAY " "
              Endif

              nLin += 3
              //Imprimir apenas icms que não participa de Subst. Tributária
              nBaseIcms1 := 0
              nVlrIcms1  := 0
              For i := 1 To Len(aIcms)
//                  If aIcms[i,3] # "S"
                     nBaseIcms1 += aIcms[i,1]
                     nVlrIcms1  += aIcms[i,2]
//                  Endif
              Next
/*              If SF1->F2_TIPO $ "I_P"
                 If !cTipBas $ '2.3'
                    nBaseIcms1 := 0
                 Endif
              Endif
*/              
              @ nLin,000 PSAY nBaseIcms1      Picture "@E@Z 99,999,999,999,999.99"
              @ nLin,028 PSAY nVlrIcms1       Picture "@E@Z 99,999,999,999,999.99"
              @ nLin,055 PSAY SF1->F1_BRICMS  Picture "@E@Z 9,999,999,999.99"
              @ nLin,081 PSAY SF1->F1_ICMSRET Picture "@E@Z 9,999,999,999.99" 
              If SF1->F1_TIPO $ "I"
                 nAux = 0
              Else
                 nAux = SF1->F1_VALMERC+SF1->F1_DESCONT
              Endif
              @ nLin,110 PSAY nAux Picture "@E@Z 999,999,999,999.99"
              nLin += 2
              @ nLin,000 PSAY SF1->F1_FRETE  Picture "@E@Z 99,999,999,999,999.99"
              @ nLin,030 PSAY SF1->F1_SEGURO Picture "@E@Z 999,999,999,999.99"
              @ nLin,083 PSAY SF1->F1_VALIPI Picture "@E@Z 999,999,999.99"
              If SF1->F1_TIPO $ "I"
                 nAux = 0 + SF1->F1_ICMSRET
              Else
                 nAux = SF1->F1_VALBRUT
              Endif
              @ nLin,110 PSAY nAux Picture "@E@Z 999,999,999,999.99"
//              DbSelectArea("SA4")                    // * Transportadoras
//              DbSeek(xFilial("SA4")+SF1->F1_TRANSP)

              nLin += 3
//              @ nLin,000 PSAY SA4->A4_NOME
//              @ nLin,078 PSAY Iif(SC5->C5_TPFRETE == "C", "1", "2")
//              @ nLin,110 PSAY SA4->A4_CGC Picture "@R 99.999.999/9999-99"
              nLin += 2
/*              @ nLin,000 Psay SA4->A4_END
              @ nLin,063 Psay SA4->A4_MUN
              @ nLin,104 Psay SA4->A4_EST
              @ nLin,110 Psay SA4->A4_INSEST
*/              
              nLin += 2
              nAuxVol   := 0 //SF1->F2_VOLUME1
              nAuxPesoB := SF1->F1_PESOL
              nAuxPesoL := SF1->F1_PESOL
		
              @ nLin,000 PSAY nAuxVol  picture "@E@Z 9,999.99"
//              @ nLin,016 PSAY SF1->F1_ESPECI1
              cEmpresa = SubStr(cNumemp, 1, 4)
              @ nLin,038 PSAY Iif(cEmpresa == "0101", "BRASILUX", Iif(cEmpresa == "0301", "BRASITEC",  Iif(cEmpresa == "0501", "UNIONSUR",  Iif(cEmpresa == "0106", "DISSOLTEX", ""))))
              @ nLin,064 PSAY "S/N"
              @ nLin,085 PSAY nAuxPesoB Picture "@E@Z 999,999.99"
              @ nLin,114 PSAY nAuxPesoL Picture "@E@Z 999,999.99"
           Else
              nLin    += (nQtdeItens*nContFolhas) - nContLin
              nContLin = (nQtdeItens*nContFolhas)
              @ nLin,000 PSAY " "
              nLin += 3
              @ nLin,000 PSAY "XXXXXXXXXXXXXXXXXXXXX"
              @ nLin,028 PSAY "XXXXXXXXXXXXXXXXXXXXX"
              @ nLin,055 PSAY "XXXXXXXXXXXXXXXX"
              @ nLin,081 PSAY "XXXXXXXXXXXXXXXX"
              @ nLin,110 PSAY "XXXXXXXXXXXXXXXXXX"
              nLin += 2
              @ nLin,000 PSAY "XXXXXXXXXXXXXXXXXXXXX"
              @ nLin,030 PSAY "XXXXXXXXXXXXXXXXXX"
              @ nLin,083 PSAY "XXXXXXXXXXXXXX"
              @ nLin,110 PSAY "XXXXXXXXXXXXXXXXXX"
              nLin += 7
           Endif

           nLin += 7
           @ nLin,045 PSAY Iif(!(SF1->F1_TIPO $ "D_B"), SA2->A2_NOME, SA1->A1_NOME)
           @ nLin,195 PSAY SF1->F1_DOC

           nLin += 5
           @ nLin,000 PSAY " "
       Next
       DbSelectArea("TMPNFPROD")
       DbCloseArea("TMPNFPROD")

Return

/*
Programa  : VALIDPERG   Autor: 
Data      : 
Descricao : Grava Perguntas
*/
Static Function ValidPerg()
       Local _sAlias := Alias()
       Local aRegs := {}
       Local i, j
       DbSelectArea("SX1")
       DbSetOrder(1)
       cPerg := PADR(cPerg, 10)

       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs,{cPerg, "01", "Da Nota Fiscal    ?", "", "", "mv_ch1", "C", 06, 0, 0, "G", "", "mv_par01", ""          , ""          , ""          , "", "", ""        , ""        , ""        , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SF1", ""})
       aAdd(aRegs,{cPerg, "02", "Ate a Nota Fiscal ?", "", "", "mv_ch2", "C", 06, 0, 0, "G", "", "mv_par02", ""          , ""          , ""          , "", "", ""        , ""        , ""        , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SF1", ""})
       aAdd(aRegs,{cPerg, "03", "Da Serie          ?", "", "", "mv_ch3", "C", 03, 0, 0, "G", "", "mv_par03", ""          , ""          , ""          , "", "", ""        , ""        , ""        , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , ""})
       //aAdd(aRegs,{cPerg, "04", "Tipo de Operacao  ?", "", "", "mv_ch4", "N", 01, 0, 1, "C", "", "mv_par04", "Nf.Entrada", "Nf.Entrada", "Nf.Entrada", "", "", "Nf.Saida", "Nf.Saida", "Nf.Saida", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , ""})

       For i := 1 to Len(aRegs)
           If !dbSeek(cPerg+aRegs[i,2])
              RecLock("SX1", .T.)
                 For j := 1 to FCount()
                     If j <= Len(aRegs[i])
                        FieldPut(j,aRegs[i,j])
                     Endif
                 Next
              MsUnlock()
           Endif
       Next
       DbSelectArea(_sAlias)
Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ DUPLIC   ¦ Autor ¦ 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Impressao do Parcelamento das Duplicacatas                 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Nfiscal                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
Static Function DUPLIC()
       Local BB, xDUPLICATAS
       Local nCol := 59

       DbSelectArea("SE2")                    // * Contas a Pagar
       DbSetOrder(1)        // E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA                                 
       xPARC_DUP   := {}                      // Parcela
       xVENC_DUP   := {}                      // Vencimento
       xVALOR_DUP  := {}                      // Valor
       xDUPLICATAS := IIF(DbSeek(xFilial("SE2")+SF1->F1_SERIE+SF1->F1_DOC,.T.),.T.,.F.) // Flag p/Impressao de Duplicatas
       While !Eof() .and. (SE2->E2_PREFIXO==SF1->F1_SERIE) .and. (SE2->E2_NUM==SF1->F1_DOC) .and. xDUPLICATAS == .T.
             If !("NF" $ SE2->E2_TIPO) .or. (SF1->F1_FORNECE <> SE2->E2_FORNECE)
                DbSkip()
                Loop
             Endif
             aAdd(xPARC_DUP , SE2->E2_PARCELA)
             aAdd(xVENC_DUP , SE2->E2_VENCTO)
             aAdd(xVALOR_DUP, SE2->E2_VALOR)
             DbSkip()
       EndDo
       For BB := 1 to 4
           If xDUPLICATAS == .T. .and. BB <= Len(xVALOR_DUP)
              @ nLin, nCol    PSAY xVENC_DUP[BB]
              @ nLin, nCol+15 PSAY xVALOR_DUP[BB] Picture("@E 9,999,999.99")
           Endif
           nCol := nCol + 37
       Next
       nLin := nLin + 1
       nCol := 59
       For BB := 5 to 8
           If xDUPLICATAS == .T. .and. BB <= Len(xVALOR_DUP)
              @ nLin, nCol    PSAY xVENC_DUP[BB]
              @ nLin, nCol+15 PSAY xVALOR_DUP[BB] Picture("@E 9,999,999.99")
           Endif
           nCol := nCol + 37
       Next
Return   

