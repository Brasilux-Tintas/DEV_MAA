#include 'rwmake.ch'
#include 'topconn.ch'
#include "avprint.ch"
/*
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFATX22 º Autor ³ André C Maester    º Data ³  04/05/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ RELAT. COMPRAS DE PRODT. RESERVADOS Subst o progr BRFATR04 º±±
±±º          ³ devido a mudanças na estrutura de separação / reserva      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRFATX22()
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "RELAT. COMPRAS DE PRODT. RESERVADOS"
     //Local cPict         := ""
     Local titulo        := "RELAT. COMPRAS DE PRODT. RESERVADOS"
     Local nLin          := 80
     Local Cabec1        := ""
     Local Cabec2        := ""
     //Local imprime       := .T.
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     //Private CbTxt       := ""
     Private limite      := 80
     Private tamanho     := "P"
     Private nomeprog    := "BRFATX22" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 18
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := "FATX22"
     Private cbtxt       := Space(10)
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRFATX22" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString     := "SZF"

     DbSelectArea("SZF")
     DbSetOrder(1)
     
     //VldPerg()  //LGS#20200210 - Adequação de release 12.1.25 e posteriores
     Pergunte(cPerg,.F.)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Monta a interface padrao com o usuario...                           ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     wnrel := SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho, , .F.)

     If nLastKey == 27
        Return
     Endif

     SetDefault(aReturn, cString)

     If nLastKey == 27
        Return
     Endif

     nTipo := If(aReturn[4]==1,15,18)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Processa({|| FATX22_1(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ FATX22_1 º Autor ³ André C Maester    º Data ³  04/06/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FATX22_1(Cabec1, Cabec2, Titulo, nLin)
       //Local nOrdem
       Local cRefOrdem,cGrupoEmba
       Local cQry1   := ""
       Local cQTot   := ""
       Local cQry2   := ""
       Local cQry3   := ""
       Local cQOrd   := ""
       Local aMatOrd := {}
       Local aMatImp := {}
       Local aMatAux := {}
       //Local aMatPed := {}
       //Local aMatReg := {}
       //Local nVolItem :=0   
       Local nX, nY
   
	   Dbselectarea("SC6")
	   Dbsetorder(1)
       If mv_par06 == 1   //ANALITICO
          //          0         1         2         3         4         5         6         7         8 
          //          01234567890123456789012345678901234567890123456789012345678901234567890123456789
          //          XXX99.99.999-99-XXXXXXXXXXXXXXXXXXXXXXXXX(99-XXXXXXXXXX)
          //          99-999999 999999-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 999/999  999999 XXXXXXXXXXXXXXXX
          //                                        Qtde. Total do Produto =>  999999 Q. Vol.   999999
          cCabec1 := "PRODUTO         DESCRIÇÃO                 UN-VOLUME                             "
          cCabec2 := "PEDIDO    CLIENTE                                     QTDE     QDRT.    LOCALIZ "
          nCol    := 060
       Else
          //          0         1         2         3         4         5         6         7         8 
          //          01234567890123456789012345678901234567890123456789012345678901234567890123456789
          //          XXX99.99.999-99-XXXXXXXXXXXXXXXXXXXXXXXXX(99-XXXXXXXXXX) XXXXXXXXXXXXXXX 999999
          cCabec1 := "BORDERO DE "+mv_par01+" ATÉ' "+mv_par02"
          cCabec2 := "PRODUTO        DESCRIÇÃO                 EMBAL      QRDT.    LOCALIZ  VOL.  QTDE"
          nCol    := 049
       Endif
	   cQry1 := ""
       cQry1 += " WITH TMP AS (SELECT C9_PEDIDO AS PEDIDO, C9_PRODUTO, C9_ITEM,  C9_LOCAL FROM "+RetSqlName("SC9")+" WITH(NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND (C9_FILIAL = '010101') AND (C9_BLEST='') AND (C9_BLCRED='') AND (C9_BLOQUEI='')) "
	   cQTot += cQry1
	   cQTot += " SELECT PEDIDO, SUM(ISNULL(DC_QUANT,SC9.C9_QTDLIB)/dbo.DetVol('"+XFilial("SC9")+"',SC9.C9_PRODUTO)) AS VOLPEDIDO "
	   cQry1 += " SELECT ZG_CODIGO, PEDIDO, SC9.C9_PRODUTO, B2_LOCALIZ, ISNULL(DC_LOCALIZ,'') AS DC_LOCALIZ, SC9.C9_CLIENTE, C6_DESCRI,(ISNULL(DC_QUANT,SC9.C9_QTDLIB)/dbo.DetVol('"+XFilial("SC9")+"',SC9.C9_PRODUTO)) AS VOLITEM, 
	   cQry1 += " ISNULL(DC_QUANT,SC9.C9_QTDLIB) AS C9_QTDLIB, SC9.C9_ITEM, SC9.C9_LOCAL, SUBSTRING(SC9.C9_PRODUTO,11,2) AS EMBALAGEM , "
	   cQry1 += " ORDEM = CASE WHEN ("+Iif(MV_PAR07=1,"SB2.B2_LOCALIZ =''","SDC.DC_LOCALIZ=''")+") THEN '0' WHEN (SUBSTRING(SC9.C9_PRODUTO,1,3) IN ('BM ','BL ')) THEN '1' ELSE '2' END, 
       cQry1 += " GRPEMBA =  "
       If MV_PAR05 == 4
           cQry1 += " ISNULL((SELECT TOP 1 B1_GRUPO2 FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "
       	   cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB1")+" B1E WITH (NOLOCK) ON (B1E.D_E_L_E_T_ = '') AND (G1_FILIAL = B1E.B1_FILIAL) AND (G1_COMP = B1E.B1_COD) "
       	   cQry1 += " WHERE (SG1.D_E_L_E_T_ = '') AND (G1_FILIAL = SDC.DC_FILIAL) AND (G1_COD = SDC.DC_PRODUTO) AND (B1E.B1_GRUPO LIKE 'E%') AND (B1E.B1_GRUPO2 > '')),'99') "
       Else
       		cQry1 += "'' "
       Endif 
	   cQry2 += " FROM TMP "
	   cQry2 += " LEFT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH(NOLOCK) ON (SZG.D_E_L_E_T_ <> '*') AND (SZG.ZG_FILIAL = '"+XFilial("SZG")+"') AND (SUBSTRING(ZG_PEDIDO,3,6) = TMP.PEDIDO) "
	   cQry2 += " LEFT OUTER JOIN "+RetSqlName("SC9")+" SC9 WITH(NOLOCK) ON (SC9.D_E_L_E_T_ <> '*') AND (SC9.C9_FILIAL = '"+XFilial("SC9")+"') AND (TMP.PEDIDO = SC9.C9_PEDIDO)  AND (TMP.C9_ITEM  = SC9.C9_ITEM) AND (TMP.C9_PRODUTO = SC9.C9_PRODUTO) "
	   cQry2 += " LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH(NOLOCK) ON (SC6.D_E_L_E_T_ <> '*') AND (SC6.C6_FILIAL = '"+XFilial("SC6")+"') AND (TMP.PEDIDO = SC6.C6_NUM)     AND (TMP.C9_ITEM  = SC6.C6_ITEM) AND (TMP.C9_PRODUTO = SC6.C6_PRODUTO) "
	   cQry2 += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (SB1.B1_FILIAL = '"+XFilial("SB1")+"') AND (TMP.C9_PRODUTO = SB1.B1_COD) "
       cQry2 += " LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH(NOLOCK) ON (SB2.D_E_L_E_T_ <> '*') AND (SB2.B2_FILIAL = '"+XFilial("SB2")+"') AND (SB2.B2_COD = SB1.B1_COD)     AND (SB2.B2_LOCAL = SB1.B1_LOCPAD)"
	   cQry2 += " LEFT OUTER JOIN "+RetSqlName("SDC")+" SDC WITH(NOLOCK) ON (SDC.D_E_L_E_T_ <> '*') AND (SDC.DC_FILIAL = '"+XFilial("SDC")+"') AND (TMP.PEDIDO = SDC.DC_PEDIDO)  AND (TMP.C9_ITEM  = SDC.DC_ITEM) AND (TMP.C9_PRODUTO = SDC.DC_PRODUTO) "
	   cQry2 += " WHERE (SZG.R_E_C_N_O_ IS NOT NULL) AND (SZG.ZG_FLAGLIB ='2') "
   	   cQry2 += "	AND (SZG.ZG_FILIAL='"+XFilial("SZG")+"')"
	   cQry2 += "	AND (SUBSTRING(DC_LOCALIZ,1,2) "+Iif((MV_PAR07= 1),"NOT IN('F2')","IN ('F2')")+")" // SEPARAR POR PARAMETRO COMPRAS FAB1 E FAB2 (O QUE NÃO ESTIVER DENTRO DESSES PARAMETROS SAIRÃO NA LISTA FABRICA 1 DESTACADOS" 	
	   cQry2 += "	AND (SZG.ZG_CODIGO  BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"')"
       Do Case
       Case MV_PAR05 == 1  // quadrante
          cQry3 += " ORDER BY B2_LOCALIZ, SC9.C9_PRODUTO, PEDIDO, SC9.C9_CLIENTE "
       Case MV_PAR05 == 2 // endereço
          cQry3 += " ORDER BY DC_LOCALIZ, SC9.C9_PRODUTO, PEDIDO, SC9.C9_CLIENTE "
       Otherwise          // embalagem
          cQry3 += " ORDER BY ORDEM , GRPEMBA ,B2_LOCALIZ, EMBALAGEM, SC9.C9_PRODUTO, PEDIDO " 
       Endcase 

       cQry1 += cQry2 + cQry3
       TCQuery cQry1 ALIAS "TCQ" NEW
       //Acerta Ordem para impressão
       If mv_par05 == 1 .or. mv_par05 == 2  
          cOrdAtu := "N"
          DbSelectArea("TCQ")
          ProcRegua(100)
          DbGoTop()
          While !Eof()
                If mv_par05 =1
                	cLocaliz := SubStr(Alltrim(TCQ->B2_LOCALIZ), 1, 3)
                Elseif mv_par05 =2 
                	cLocaliz := Alltrim(TCQ->DC_LOCALIZ)
                Endif
                If Empty(cLocaliz)
                   If aScan(aMatOrd, {|x| Alltrim(x[1]) == Alltrim(cLocaliz)}) == 0
                      aadd(aMatOrd, {cLocaliz, "N"})
                   Endif
                   DbSkip()
                   Loop
                Else
                   While !Eof() .and. cLocaliz == Iif(mv_par05 == 1, SubStr(Alltrim(TCQ->B2_LOCALIZ), 1, 3), Alltrim(TCQ->DC_LOCALIZ))
                       If aScan(aMatOrd, {|x| Alltrim(x[1]) == Alltrim(cLocaliz)}) == 0
                       	   If mv_par05=1
                       	   	   aadd(aMatOrd, {SubStr(cLocaliz, 1, 3), cOrdAtu})
                       	   Else
                       	   	   aadd(aMatOrd, {Alltrim(cLocaliz), cOrdAtu})
                       	   Endif
                       Endif
                       DbSkip()
                   Enddo
                   cOrdAtu := Iif(cOrdAtu == "I", "N", "I")
                Endif
          Enddo
          For nY := 1 To Len(aMatOrd)
              DbSelectArea("TCQ")
              DbGoTop()
              aMatAux := {}
              While !Eof() 
                    If Iif(mv_par05=1,SubStr(Alltrim(TCQ->B2_LOCALIZ),1,3),Alltrim(TCQ->DC_LOCALIZ)) == aMatOrd[nY][1]
                      //                   1              2               3               4                  5                6          7               8               9              10              11            12               13                 14        
                       aadd(aMatAux, {TCQ->PEDIDO, TCQ->C9_CLIENTE, TCQ->C9_QTDLIB, TCQ->C9_PRODUTO,  TCQ->VOLITEM  , TCQ->C9_ITEM, TCQ->C9_LOCAL, TCQ->C6_DESCRI , TCQ->B2_LOCALIZ, TCQ->DC_LOCALIZ, ''      ,                ,                ,, TCQ->EMBALAGEM})
                    Endif
                    DbSelectArea("TCQ")
                    DbSkip()
              Enddo
              //Ordena Matriz
              If aMatOrd[nY][2] $ 'I'
                 If mv_par05 = 1
                 	aSort(aMatAux, , , {|x, y| x[09] > y[09]})
              	 Else
              	 	aSort(aMatAux, , , {|x, y| x[10] > y[10]})
              	 Endif
              Endif
              For nX := 1 To Len(aMatAux)
                  aAdd(aMatImp, {aMatAux[nX][01], aMatAux[nX][02], aMatAux[nX][03], aMatAux[nX][04], aMatAux[nX][05], aMatAux[nX][06], aMatAux[nX][07], aMatAux[nX][08], aMatAux[nX][09], aMatAux[nX][10], aMatAux[nX][11], '',''})
              Next
          Next
       Else
          DbSelectArea("TCQ")
          While !Eof()               //  1           2                 3                4               5                 6                 7                 8                9               10               11              12                 13              14           
                aAdd(aMatImp,   { TCQ->PEDIDO , TCQ->C9_CLIENTE, TCQ->C9_QTDLIB , TCQ->C9_PRODUTO,   TCQ->VOLITEM   , TCQ->C9_ITEM     , TCQ->C9_LOCAL  , TCQ->C6_DESCRI , TCQ->B2_LOCALIZ, TCQ->DC_LOCALIZ,    ''          ,TCQ->ORDEM      , TCQ->GRPEMBA   , TCQ->EMBALAGEM })
                DbSelectArea("TCQ")
                DbSkip()
          Enddo
       Endif
       DbSelectArea("TCQ")
       DbCloseArea()
       cRefOrdem := iif(Len(aMatImp) > 0,aMatImp[1][12],"")    
       cGrupoEmba := iif(Len(aMatImp) > 0,aMatImp[1][13],"")    
       For nY := 1 To Len(aMatImp)
           If aMatImp[nY][11] <> 'S'
              If lAbortPrint
                 @nLin,000 PSAY "*** CANCELADO PELO OPERADOR ***"
                 Exit
              Endif
			  // Salto de Página. Quebra por grupo de embalagens no caso de ordem por embalagem
              If (nLin > 55) .or. ((mv_par05 == 4) .and. (((cRefOrdem < "2") .and. (cRefOrdem <> aMatImp[nY][12])) .or. ((cRefOrdem >= "2")  .and. ((cRefOrdem+cGrupoEmba) <>  (aMatImp[nY][12]+aMatImp[nY][13])))))
                 nLin := Cabec(Titulo, cCabec1, cCabec2, NomeProg, Tamanho,nTipo)
                 nLin += 1
              Endif
	    	  cRefOrdem  := aMatImp[nY][12]  
       		  cGrupoEmba := aMatImp[nY][13]   
              //Busca Producao / Envase
              cPesado := ""
              cEnvase := ""
              If Len(Alltrim(aMatImp[nY][04])) == 12
                 fBusSta(aMatImp[nY][04], @cPesado, @cEnvase)
              Endif
              @ nLin, 000  PSAY Alltrim(aMatImp[nY][04]) Picture "@R XXX9999999-99"
              @ nLin, 013  PSAY Iif(Posicione("SB1", 1, xFilial("SB1")+Alltrim(aMatImp[nY][04]), "B1_ESTOQUE") == 'S',"*","-")
              @ nLin, 015  PSAY Substr(aMatImp[nY][08], 1, 22)
              @ nLin, 039  PSAY "("+Alltrim(SubStr(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(aMatImp[nY][04], 11, 2), "Z5_DESCR"), 1, 10))+")"
              If !Empty(cPesado)
                 @ nLin, 050  PSAY cPesado
              Endif
              @ nLin, (nCol + 2) PSAY Iif(Empty(aMatImp[nY][09]), " ", Substr(AllTrim(aMatImp[nY][09]),1,9))
              @ nLin, (nCol +12) PSAY Iif(Empty(aMatImp[nY][10]), " ", Alltrim(aMatImp[nY][10]))
              If mv_par06 == 1  //ANALITICO
                 nLin += 1
              Endif
              cProduto  := aMatImp[nY][04]
              cLocaliz  := aMatImp[nY][09]
              nQtdeProd := 0
              nTotVol   := 0 // Totaliza a qtde de volumes por produto
              For nX := 1 To Len(aMatImp)
                  If cProduto == aMatImp[nX][04] .and. cLocaliz == aMatImp[nX][09]
                     If nLin >= 60
                         nLin := Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
                         nLin += 1
                         @ nLin,000  PSAY Alltrim(aMatImp[nX][04]) Picture "@R XXX9999999-99"
                         @ nLin,013  PSAY Iif(Posicione("SB1", 1, xFilial("SB1")+aMatImp[nY][04], "B1_ESTOQUE") == 'S',"*","-")
              			 @ nLin,015  PSAY Substr(aMatImp[nY][08], 1, 22)
              			 @ nLin,039  PSAY "("+Alltrim(SubStr(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(aMatImp[nX][04], 11, 2), "Z5_DESCR"), 1, 10))+")"
                         If !Empty(cPesado)
                             @ nLin,052  PSAY cPesado
      					 Endif
                         @ nLin,(nCol +1) PSAY Iif(Empty(aMatImp[nX][09]), " ", Substr(AllTrim(aMatImp[nX][09]),1,9))
   					     @ nLin,(nCol+12) PSAY Iif(Empty(aMatImp[nX][10]), " ", Alltrim(aMatImp[nX][10]))
                         If mv_par06 == 1 //ANALITICO
                             nLin += 1
                         Endif
                     Endif
					 nTotVol += aMatImp[nX][05]
                     If mv_par06 == 1 // ANALITICO
                         @ nLin,000  PSAY '01'+"-"+aMatImp[nX][01]
                     	 @ nLin,010  PSAY Alltrim(aMatImp[nX][02])+"-"+SubStr(Posicione("SA1", 1, xFilial("SA1")+aMatImp[nX][02], "A1_NOME"), 1, 30)
                      	 @ nLin,052  PSAY aMatImp[nX][03] Picture "@E 999999" 
                     	 @ nLin,(nCol +2) PSAY Iif(Empty(aMatImp[nX][09]), " ", Substr(Alltrim(aMatImp[nX][09]),1,9))
						 @ nLin,(nCol +12) PSAY Iif(Empty(aMatImp[nX][10]), " ", Alltrim(aMatImp[nX][10]))                     	
                     	 nLin += 1
                     Endif
                     nQtdeProd += aMatImp[nX][03] 
                     aMatImp[nX][11] := 'S'
                  Endif
              Next
              If mv_par06 == 1 //ANALITICO
                 @ nLin,000 PSAY Replicate("_", 80)
                 nLin += 1
                 If nLin >= 60
                    nLin := Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
                    nLin += 1
                 Endif
                 nLin += 1
                 @ nLin,030 PSAY "Total do Produto (Qtde.) -> "
                 @ nLin,057 PSAY nQtdeProd Picture "@E 999999"
                 @ nLin,064 PSAY "Qtde.Vol."
                 @ nLin,074 PSAY nTotVol Picture "@E 999999"
                 nLin += 1
                 @ nLin,000 PSAY Replicate("=", 80)
                 nLin += 1
              Else
                 @ nLin, 071  PSAY nTotVol Picture "@E 999"
                 If !Empty(cEnvase)
                    @ nLin,074 PSAY cEnvase
                 Endif
                 @ nlin,075 PSAY nQtdeProd Picture "@E 99999"
                 nLin += 1
                 @ nlin,000 PSAY Replicate("_",80)
                 nLin += 1 
              Endif
           Endif
       Next
       If nLin >= 60
          nLin := Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
          nLin += 1
       Endif
       //               0         1         2         3         4
       //               01234567890123456789012345678901234567890
       //               999-XXXXXXXXXXXXXXXXXXXXXXXXX
       nLin += 1
       @ nLin,000 PSAY "PEDIDO                VOLUMES RESERVADOS"
       nLin += 1
       @ nLin,000 PSAY "________________________________________"
       nLin += 1

       cQOrd += " GROUP BY PEDIDO ORDER BY PEDIDO "
       cQTot += cQry2 + cQOrd
       TCQuery cQTot ALIAS "TCP" NEW
       While !Eof()
           If nLin >= 60
              nLin := Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
              nLin += 1
           Endif
       	  
           @ nLin,000 PSAY TCP->PEDIDO
           @ nLin,030 PSAY TCP->VOLPEDIDO Picture "@E 9999"
           nLin += 1 
           DbSelectArea("TCP")
           DbSkip()
       Enddo
	   DbSelectArea("TCP")
	   DbCloseArea()
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
//LGS#20200210 - Adequação de release 12.1.25 e posteriores
/*Static Function VldPerg()
       Local aHelp1 := {} ; Local aHelp2 := {} ; Local aHelp3 := {} ; Local aHelp4 := {} ; Local aHelp5 := {} 
       aAdd( aHelp1, "Informe a faixa de borderos a serem " )
       aAdd( aHelp1, "impressos.                          " )
       aAdd( aHelp2, "Informe o periodo de emissão do bor-" )
       aAdd( aHelp2, "dero para emissão do relatório.     " )
       aAdd( aHelp3, "Informe a ordem do relatório.       " )
       aAdd( aHelp4, "Informe o tipo do relatório.        " )
       aAdd( aHelp5, "Informe o Local Fab 1 ou Fab 2.     " )
       PutSX1("FATX22    ", "01"  ,   "Do  Bordero         ", ""     , ""     , "mv_ch1", "C"  , 6       , 0       , 0      , "G" , " "   , " ", " "    , " "  , "mv_par01", " "        , " "     , " "     , " "   , " "        , " "     , " "     , " "  , " "     , " "     , " ", " "     , " "     , " ",  " "     ,  " "     , aHelp1  , Nil     , Nil     , "FATX22" )
       PutSX1("FATX22    ", "02"  ,   "Até Bordero         ", ""     , ""     , "mv_ch2", "C"  , 6       , 0       , 0      , "G" , " "   , " ", " "    , " "  , "mv_par02", " "        , " "     , " "     , " "   , " "        , " "     , " "     , " "  , " "     , " "     , " ", " "     , " "     , " ",  " "     ,  " "     , aHelp1  , Nil     , Nil     , "FATX22" )
       PutSX1("FATX22    ", "03"  ,   "Da  Emissão Bordero ", ""     , ""     , "mv_ch3", "D"  , 8       , 0       , 0      , "G" , " "   , " ", " "    , " "  , "mv_par03", " "        , " "     , " "     , " "   , " "        , " "     , " "     , " "  , " "     , " "     , " ", " "     , " "     , " ",  " "     ,  " "     , aHelp2  , Nil     , Nil     , "FATX22" )
       PutSX1("FATX22    ", "04"  ,   "Até Emissão Bordero ", ""     , ""     , "mv_ch4", "D"  , 8       , 0       , 0      , "G" , " "   , " ", " "    , " "  , "mv_par04", " "        , " "     , " "     , " "   , " "        , " "     , " "     , " "  , " "     , " "     , " ", " "     , " "     , " ",  " "     ,  " "     , aHelp2  , Nil     , Nil     , "FATX22" )
       PutSX1("FATX22    ", "05"  ,   "Ordem de            ", ""     , ""     , "mv_ch5", "N"  , 1       , 0       , 0      , "C" , " "   , " ", " "    , " "  , "mv_par05", "Quadrante", " "     , " "     , " "   , "Produto"  , " "     , " "     , "Endereço", " ", " "     , "Embalagem", " ", " "  , " ",  " "     ,  " "     , aHelp3  , Nil     , Nil     , "FATX22" )
       PutSX1("FATX22    ", "06"  ,   "Tipo                ", ""     , ""     , "mv_ch6", "N"  , 1       , 0       , 0      , "C" , " "   , " ", " "    , " "  , "mv_par06", "Analítico", " "     , " "     , " "   , "Sintético", " "     , " "     , " "  , " "     , " "     , " ", " "     , " "     , " ",  " "     ,  " "     , aHelp4  , Nil     , Nil     , "FATX22" )
	   PutSX1("FATX22    ", "07"  ,   "Itens FAB 1/ FAB 2  ", ""     , ""     , "mv_ch7", "N"  , 1       , 0       , 0      , "C" , " "   , " ", " "    , " "  , "mv_par07", "Fabrica I", " "     , " "     , " "   , "Fabrica II"," "     , " "     , " "  , " "     , " "     , " ", " "     , " "     , " ",  " "     ,  " "     , aHelp5  , Nil     , Nil     , "FATX22" )
Return*/

Static Function fBusSta(cCodPro, cPesado, cEnvase)
                nQtdPro := 0
                cNumOP:= "'"
                cNumLT:= "'"
				cQry2 := "SELECT SC2.C2_OP AS ORDEM, SC2.C2_LOTE AS LOTE, ISNULL(SUM(SC2.C2_QUANT - SC2.C2_QUJE),0) AS QUANT "+;
				"FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "+;
				"WHERE (SC2.C2_FILIAL  = '"+xFilial("SC2")+"') AND (SC2.D_E_L_E_T_ = '') "+;
				"AND (SC2.C2_DATRF   = '') AND (C2_PRODUTO = '"+cCodPro+"') "+;
				"GROUP BY SC2.C2_OP, SC2.C2_LOTE"
				
                TCQuery cQry2 ALIAS "QOP" NEW
                DbSelectArea("QOP")
                While !Eof()
                      nQtdPro += QOP->QUANT
                      cNumOP  += QOP->ORDEM+"', '"
                      cNumLT  += QOP->LOTE+"', '"
                      DbSelectArea("QOP")
                      DbSkip()
                Enddo
                DbSelectArea("QOP")
                DbCloseArea()
                If !cNumLT == "'"
				
                   cQry2 := ""
                   cQry2 += "SELECT TOP 1 * "
                   cQry2 += "FROM PESQUISA_PRODUCAO PSQ "
                   cQry2 += "WHERE PSQ.C2_LOTE IN("+SubStr(cNumLT, 1, Len(cNumLT)-3)+") "
                   cQry2 += "  AND PSQ.PRODUTO = '"+SubStr(Alltrim(cCodPro), 1, 10)+"00' "
                   cQry2 += "ORDER BY PSQ.FIM "
                   TCQuery cQry2 ALIAS "QOP" NEW
                   If Empty(QOP->STATUS)
                      DbSelectArea("QOP")
                      DbCloseArea()
                      cQry2 := ""
                      cQry2 += "SELECT TOP 1 * "
                      cQry2 += "FROM PESQUISA_PRODUCAO_2 PSQ "
                      cQry2 += "WHERE PSQ.C2_LOTE IN("+SubStr(cNumLT, 1, Len(cNumLT)-3)+") "
                      cQry2 += "  AND PSQ.PRODUTO = '"+SubStr(Alltrim(cCodPro), 1, 10)+"00' "
                      cQry2 += "ORDER BY PSQ.FIM "
                      TCQuery cQry2 ALIAS "QOP" NEW
                   Endif
                   DbSelectArea("QOP")
                   cPesado := Iif(QOP->STATUS $ '1' .or. !Empty(QOP->INICIO), '*', ' ')
                   DbSelectArea("QOP")
                   DbCloseArea()

                   cQry2 := ""
                   cQry2 += "SELECT TOP 1 * "
                   cQry2 += "FROM PESQUISA_PRODUCAO PSQ "
                   cQry2 += "WHERE PSQ.C2_LOTE IN("+SubStr(cNumLT, 1, Len(cNumLT)-3)+") "
                   cQry2 += "  AND PSQ.PRODUTO = '"+cCodPro+"' "
                   cQry2 += "ORDER BY PSQ.FIM "
                   TCQuery cQry2 ALIAS "QOP" NEW
                   If Empty(QOP->STATUS)
                      DbSelectArea("QOP")
                      DbCloseArea()
                      cQry2 := ""
                      cQry2 += "SELECT TOP 1 * "
                      cQry2 += "FROM PESQUISA_PRODUCAO_2 PSQ "
                      cQry2 += "WHERE PSQ.C2_LOTE IN("+SubStr(cNumLT, 1, Len(cNumLT)-3)+") "
                      cQry2 += "  AND PSQ.PRODUTO = '"+cCodPro+"' "
                      cQry2 += "ORDER BY PSQ.FIM "
                      TCQuery cQry2 ALIAS "QOP" NEW
                   Endif
                   DbSelectArea("QOP")
                   cEnvase := Iif(QOP->STATUS $ '1' .or. !Empty(QOP->FIM), '*', ' ')
                   DbSelectArea("QOP")
                   DbCloseArea()
                Else
                   cPesado := ' '
                   cEnvase := ' '
                Endif
Return