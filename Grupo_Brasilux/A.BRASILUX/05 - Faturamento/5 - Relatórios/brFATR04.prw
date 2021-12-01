#include 'rwmake.ch'
#include 'topconn.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFATR04 º Autor ³                    º Data ³  09/08/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Destino de pedidos aprovados. Substitui o programa BRFAT050º±±
±±º          ³ devido a mudanças na estrutura do programa.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRFATR04()
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "DEST. PEDIDOS APROVADOS"
     //Local cPict         := ""
     Local titulo        := "DEST. PEDIDOS APROVADOS"
     Local nLin          := 80
     Local Cabec1        := ""
     Local Cabec2        := ""
     //Local imprime       := .T.
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     Private CbTxt       := ""
     Private limite      := 80
     Private tamanho     := "P"
     Private nomeprog    := "BRFATR04" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 18
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := "FATR04"
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRFATR04" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString     := "SZF"
     
     if !u_VldAcesso(funname())
     	MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
     	return 
     endif 
     u_zcfga01( 'BRFATR04' ) //LGS#2021201 - Gravação de log de utilização da rotina
     DbSelectArea("SZF")
     DbSetOrder(1)
     
     //VldPerg()
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
     Processa({|| FATR04_1(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ FATR04_1 º Autor ³ Luís G. de Souza   º Data ³  09/08/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FATR04_1(Cabec1, Cabec2, Titulo, nLin)
       Local cRefOrdem,cGrupoEmba,nLista,cLista
       Local cQry1   := ""
       Local aMatOrd := {}
       Local aMatImp := {}
       Local aMatAux := {}
       Local aMatPed := {}
       Local aMatReg := {}
       //Local nVolItem :=0
       Local nX, nY   
		
		dbselectarea("ZZL")
		dbsetorder(1)		       
		dbselectarea("SC6")
		dbsetorder(1)
       If mv_par08 == 1
          //          0              1         2         3         4         5         6         7         8 
          //          01234567890123456789012345678901234567890123456789012345678901234567890123456789
          //          XXX99.99.999-99-XXXXXXXXXXXXXXXXXXXXXXXXX(99-XXXXXXXXXX)
          //          99-999999 999999-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 999/999  999999 XXXXXXXXXXXXXXXX
          //                                        Qtde. Total do Produto =>  999999 Q. Vol.   999999
          cCabec1 := "PRODUTO       DESCRIÇÃO              LOC PROVIS                                 "
          cCabec2 := "PEDIDO    CLIENTE                               REG/REGT QTDE   LOCALIZ.        "
          nCol    := 064
       Else
          //                0          1         2         3         4         5         6         7  
          //          01234567890123456789012345678901234567890123456789012345678901234567890123456789
          //          XXX9999999-99-XXXXXXXXX (XXXXXXXXXX) XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 999999
          cCabec1 := "PRODUTO       DESCRIÇÃO              LOC PROVIS     LOCALIZ            VOL  QTDE"
          cCabec2 := "Borderos de "+mv_par03+" ate' "+mv_par04
          nCol    := 052
       Endif
       
       cQry1 := "SELECT '"+substr(cNumEmp,1,2)+"' AS EMPRESA, "+;
       "ORDEM = CASE WHEN (SB2.B2_LOCALIZ = '') THEN '0' WHEN (SUBSTRING(SC9.C9_PRODUTO,1,3) = 'BM ') THEN '1' ELSE '2' END,"
       //"LISTA = CASE WHEN (SB2.B2_LOCALIZ = '') OR (SUBSTRING(SB2.B2_LOCALIZ,1,1) = '_') THEN '00' WHEN (SB2.B2_LOCALIZ < '285') THEN '01' WHEN (SB2.B2_LOCALIZ < '481') THEN '02' WHEN (SB2.B2_LOCALIZ < '700') THEN '03' WHEN (SB2.B2_LOCALIZ < '900') THEN '04' ELSE '05' END,"+;
       cQry1 += "LISTA = CASE WHEN SB2.B2_LOCALIZ = '' THEN '00' WHEN (SUBSTRING(SC9.C9_PRODUTO,1,3) = 'BM ') THEN '01' WHEN ((SUBSTRING(SC9.C9_PRODUTO,1,3) = 'CT ')) AND (B2_LOCALIZ LIKE 'F1%') THEN '02' WHEN (SUBSTRING(SC9.C9_PRODUTO,1,3) = 'ST ') THEN '03' WHEN (SUBSTRING(SB2.B2_LOCALIZ,1,3) = 'F1-') AND (SUBSTRING(SB2.B2_LOCALIZ,4,3) >= '285')  THEN '04' WHEN (SUBSTRING(SB2.B2_LOCALIZ,1,3) = 'F1-') AND (SUBSTRING(SB2.B2_LOCALIZ,4,3) < '285')  THEN '05' WHEN SUBSTRING(SB2.B2_LOCALIZ,1,3) = 'F2-' THEN '06' ELSE '07' END ,"+;
       "SC9.C9_PEDIDO, SC9.C9_CLIENTE , SC9.C9_QTDLIB, SC9.C9_PRODUTO, SC9.C9_ITEM, "+;
       "SC9.C9_SEQUEN, SC9.C9_FLGIMP, SC9.C9_LOCAL, SC9.C9_LOJA, SB2.B2_COD, SB2.B2_LOCALIZ, SC5.C5_VOLUME1, SC5.C5_ESPECI4,"+;
       "SUBSTRING(SC9.C9_PRODUTO,11,2) AS EMBA,GRPEMBA = "  
       IF mv_par07 == 4
       		cQry1 += "ISNULL((SELECT TOP 1 B1_GRUPO2 FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "+;
       		"LEFT OUTER JOIN "+RetSqlName("SB1")+" B1E WITH (NOLOCK) ON (B1E.D_E_L_E_T_ = '') AND (G1_FILIAL = B1E.B1_FILIAL) AND (G1_COMP = B1E.B1_COD) "+;
       		"WHERE (SG1.D_E_L_E_T_ = '') AND (G1_FILIAL = SC9.C9_FILIAL) AND (G1_COD = SC9.C9_PRODUTO) AND (B1E.B1_GRUPO LIKE 'E%') AND (B1E.B1_GRUPO2 > '')),'99') "
       else
       		cQry1 += "'' "
       ENDIF 
       cQry1 += "FROM "+RetSqlName("SZG")+" SZG WITH (NOLOCK) "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SC9")+" SC9 WITH (NOLOCK) ON SZG.ZG_FILIAL = SC9.C9_FILIAL AND SUBSTRING(SZG.ZG_PEDIDO, 3, 6) = SC9.C9_PEDIDO AND SC9.D_E_L_E_T_ = '' "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON SC9.C9_FILIAL = SB1.B1_FILIAL AND SC9.C9_PRODUTO = SB1.B1_COD AND SB1.D_E_L_E_T_ = '' "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON B1_FILIAL = SB2.B2_FILIAL AND B1_COD = SB2.B2_COD AND B1_LOCPAD = SB2.B2_LOCAL AND SB2.D_E_L_E_T_ = '' "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON SZG.ZG_FILIAL = SC5.C5_FILIAL AND SUBSTRING(SZG.ZG_PEDIDO, 3, 6) = SC5.C5_NUM AND SC5.D_E_L_E_T_ = '' "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SZF")+" SZF WITH (NOLOCK) ON SZG.ZG_FILIAL = SZF.ZF_FILIAL AND SZG.ZG_CODIGO = SZF.ZF_CODIGO AND SZF.D_E_L_E_T_ = '' "
       cQry1 += "WHERE SZG.ZG_FILIAL  = '"+xFilial("SZG")+"' "
       cQry1 += "  AND SZG.D_E_L_E_T_ = '' "
       If !Empty(mv_par04)
          cQry1 += "  AND SZG.ZG_CODIGO  BETWEEN '"+mv_par03+"'       AND '"+mv_par04+"' "
       Endif
       cQry1 += "  AND SC9.C9_DTLCRED BETWEEN '"+dtos(mv_par01)+"' AND '"+dtos(mv_par02)+"' "
       If !Empty(mv_par06)
          cQry1 += "  AND SZF.ZF_EMISSAO BETWEEN '"+dtos(mv_par05)+"' AND '"+dtos(mv_par06)+"' "
       Endif
       if !empty(mv_par10)
          cQry1 += "  AND (SB2.B2_LOCALIZ BETWEEN '"+TRIM(mv_par09)+"' AND '"+trim(mv_par10)+"') "
       endif 
       cQry1 += "  AND SC9.C9_BLEST   = '' "
       cQry1 += "  AND SC9.C9_BLCRED  = '' "
       cQry1 += "  AND SC9.C9_BLOQUEI = '' "
       //cQry1 += "  AND SUBSTRING(SC9.C9_PRODUTO, 1, 2) NOT IN('BM', 'BL') "
       do case
       case mv_par07 == 1
          cQry1 += "ORDER BY B2_LOCALIZ, C9_PRODUTO, EMPRESA, C9_PEDIDO, C9_CLIENTE, C9_LOJA "
       case mv_par07 == 2
              cQry1 += "ORDER BY LISTA,C9_PRODUTO, B2_LOCALIZ, EMPRESA, C9_PEDIDO, C9_CLIENTE, C9_LOJA "
       case mv_par07 == 3
          cQry1 += "ORDER BY LISTA,SUBSTRING(SC9.C9_PRODUTO, 06, 05), SUBSTRING(SC9.C9_PRODUTO, 04, 02), SUBSTRING(SC9.C9_PRODUTO, 01, 03), SB2.B2_LOCALIZ, EMPRESA, SC9.C9_PEDIDO, SC9.C9_CLIENTE, SC9.C9_LOJA "
       otherwise
          cQry1 += "ORDER BY LISTA,ORDEM,GRPEMBA,B2_LOCALIZ,EMBA,C9_PRODUTO, EMPRESA, C9_PEDIDO, C9_CLIENTE, C9_LOJA "
       
       endcase 
       TCQuery cQry1 ALIAS "TCQ" NEW
       
       //Acerta Ordem para impressão
       If mv_par07 == 1
          cOrdAtu := "N"
          DbSelectArea("TCQ")
          ProcRegua(100)
          DbGoTop()
          While !Eof()
                cLocaliz := SubStr(Alltrim(TCQ->B2_LOCALIZ), 1, 3)
                If Empty(cLocaliz)
                   If aScan(aMatOrd, {|x| Alltrim(x[1]) == Alltrim(cLocaliz)}) == 0
                      aadd(aMatOrd, {cLocaliz, "N"})
                   Endif
                   DbSkip()
                   Loop
                Else
                   While !Eof() .and. cLocaliz == SubStr(Alltrim(TCQ->B2_LOCALIZ), 1, 3)
                         If aScan(aMatOrd, {|x| Alltrim(x[1]) == Alltrim(cLocaliz)}) == 0
                            aadd(aMatOrd, {SubStr(cLocaliz, 1, 3), cOrdAtu})
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
                    If SubStr(Alltrim(TCQ->B2_LOCALIZ), 1, 3) == aMatOrd[nY][1]
                       aadd(aMatAux, {TCQ->EMPRESA, TCQ->C9_PEDIDO, TCQ->C9_CLIENTE, TCQ->C9_QTDLIB, TCQ->C9_PRODUTO, TCQ->C9_ITEM, TCQ->C9_SEQUEN, TCQ->C9_FLGIMP, TCQ->C9_LOCAL, TCQ->C9_LOJA, TCQ->B2_COD, TCQ->B2_LOCALIZ, TCQ->C5_VOLUME1, TCQ->C5_ESPECI4, '' })
                    Endif
                    DbSelectArea("TCQ")
                    DbSkip()
              Enddo
              //Ordena Matriz
              If aMatOrd[nY][2] $ 'I'
                 aSort(aMatAux, , , {|x, y| x[12] > y[12]})
              //Else
              //   aSort(aMatAux, , , {|x| x[12] > x[12]})
              Endif
              For nX := 1 To Len(aMatAux)
                  aAdd(aMatImp, {aMatAux[nX][01], aMatAux[nX][02], aMatAux[nX][03], aMatAux[nX][04], aMatAux[nX][05], aMatAux[nX][06], aMatAux[nX][07], aMatAux[nX][08], aMatAux[nX][09], aMatAux[nX][10], aMatAux[nX][11], aMatAux[nX][12], aMatAux[nX][13], aMatAux[nX][14], aMatAux[nX][15],'','',''})
              Next
          Next
       Else
          DbSelectArea("TCQ")
          While !Eof()
                aAdd(aMatImp,   {TCQ->EMPRESA   , TCQ->C9_PEDIDO , TCQ->C9_CLIENTE, TCQ->C9_QTDLIB , TCQ->C9_PRODUTO, TCQ->C9_ITEM   , TCQ->C9_SEQUEN , TCQ->C9_FLGIMP , TCQ->C9_LOCAL  , TCQ->C9_LOJA   , TCQ->B2_COD    , TCQ->B2_LOCALIZ, TCQ->C5_VOLUME1, TCQ->C5_ESPECI4, '',TCQ->ORDEM,TCQ->GRPEMBA,TCQ->LISTA  })
                DbSelectArea("TCQ")
                DbSkip()
          Enddo
       Endif
       DbSelectArea("TCQ")
       DbCloseArea()
       //Impressão do  
       cRefOrdem := iif(Len(aMatImp) > 0,aMatImp[1][16],"")    
       nLista = iif(Len(aMatImp) > 0 .and. (aMatImp[1][18] == "00"),0,1) 
       cLista := iif(Len(aMatImp) > 0,aMatImp[1][18],"")   
       cGrupoEmba := iif(Len(aMatImp) > 0,aMatImp[1][17],"")    
       For nY := 1 To Len(aMatImp)
           If aMatImp[nY][15] <> 'S'
              If lAbortPrint
                 @nLin,000 PSAY "*** CANCELADO PELO OPERADOR ***"
                 Exit
              Endif
			  // Salto de Página. Quebra por grupo de embalagens no caso de ordem por embalagem
              If (nLin > 55) .or. ((mv_par07 == 4) .and. (((cRefOrdem < "2") .and. ((cRefOrdem <> aMatImp[nY][16]) .OR. (cLista <> aMatImp[nY][18])) .or. ((cRefOrdem >= "2")  .and. (((cRefOrdem+cGrupoEmba) <>  (aMatImp[nY][16]+aMatImp[nY][17]))  .OR. (cLista <> aMatImp[nY][18]))))))
     				if (cLista <> aMatImp[nY][18])
       					cLista := aMatImp[nY][18]
       					nLista++
       				endif 
                 	nLin := Cabec(alltrim(Titulo)+iif(mv_par07 == 4," - LISTA "+padl(alltrim(str(nLista)),2,"0"),""), cCabec1, cCabec2, NomeProg, Tamanho,nTipo)
                 	nLin += 1
              Endif
	 			cRefOrdem := aMatImp[nY][16]  
       			cGrupoEmba := aMatImp[nY][17]
              //Busca Producao / Envase
              cPesado := ""
              cEnvase := ""
              If Len(Alltrim(aMatImp[nY][05])) == 12
                 fBusSta(aMatImp[nY][05], @cPesado, @cEnvase)
              Endif
              @ nLin, 000  PSAY Alltrim(aMatImp[nY][05]) Picture "@R XXX9999999-99"
              @ nLin, 013  PSAY iif(Posicione("SB1", 1, xFilial("SB1")+aMatImp[nY][05], "B1_ESTOQUE") == 'S',"*","-")
              @ nLin, 014  PSAY SubStr(Posicione("SB1", 1, xFilial("SB1")+aMatImp[nY][05], "B1_DESC"), 1, 21)
//              @ nLin, 024  PSAY "("+Alltrim(SubStr(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(aMatImp[nY][05], 11, 2), "Z5_DESCR"), 1, 10))+")"      
              dbselectarea("ZZL")
              dbseek(xFilial("ZZL")+aMatImp[nY][05])
              if found()
	              @ nLin, 037  PSAY ZZL->ZZL_LOCALI
			  endif 	             
/*            dbselectarea("SC6")
              dbseek(xFilial("SC6")+aMatImp[nY][02]+aMatImp[nY][06]+aMatImp[nY][05])
   		  	  nVolItem = 0
    	      if found()
                  @ nLin, 067  PSAY iif(((aMatImp[nY][04])/(SC6->C6_VOLITEM))>0,((aMatImp[nY][04])/(SC6->C6_VOLITEM)),'')
		      endif
              If !Empty(cPesado)
                 @ nLin, 056  PSAY cPesado
              Endif
*/              
              @ nLin, nCol PSAY Iif(Empty(aMatImp[nY][12]), " ", AllTrim(aMatImp[nY][12]))
              If mv_par08 == 1
                 nLin += 1
              Endif

              cProduto  := aMatImp[nY][05]
              cLocaliz  := aMatImp[nY][12]
              nQtdeProd := 0
              nTotVol   := 0 // Totaliza a qtde de volumes por produto
              For nX := 1 To Len(aMatImp)
                  If cProduto == aMatImp[nX][05] .and. cLocaliz == aMatImp[nX][12]
                     If nLin >= 60
                        nLin := Cabec(alltrim(Titulo)+iif(mv_par07 == 4," - LISTA "+padl(alltrim(str(nLista)),2,"0"),""),cCabec1,cCabec2,nomeprog,tamanho,nTipo)
                        nLin += 1
                        @ nLin,000  PSAY Alltrim(aMatImp[nX][05]) Picture "@R XXX9999999-99"
                        @ nLin,013  PSAY iif(Posicione("SB1", 1, xFilial("SB1")+aMatImp[nY][05], "B1_ESTOQUE") == 'S',"*","-")
                        @ nLin,014  PSAY SubStr(Posicione("SB1", 1, xFilial("SB1")+aMatImp[nX][05], "B1_DESC"), 1, 21)
//					    @ nLin,024  PSAY "("+Alltrim(SubStr(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(aMatImp[nX][05], 11, 2), "Z5_DESCR"), 1, 10))+")"
		              	dbselectarea("ZZL")
              			dbseek(xFilial("ZZL")+aMatImp[nY][05])
              			if found()
	              			@ nLin, 037  PSAY ZZL->ZZL_LOCALI
			  			endif 	             
                        If !Empty(cPesado)
                           @ nLin,056  PSAY cPesado
                        Endif
                        @ nLin,nCol PSAY Iif(Empty(aMatImp[nX][12]), " ", AllTrim(aMatImp[nX][12]))
                        If mv_par08 == 1
                           nLin += 1
                        Endif
                     Endif
                     If aScan(aMatPed, {|x| x[1] == aMatImp[nX][01]+aMatImp[nX][02]}) == 0
                        aAdd(aMatPed, {aMatImp[nX][01]+aMatImp[nX][02],;
                                       Alltrim(Posicione("SZ7", 1, xFilial("SZ7")+Posicione("SA1", 1, xFilial("SA1")+aMatImp[nX][03], "A1_CODCID"), "Z7_REGIAO")),;
                                       aMatImp[nX][13] })
                     Endif

                     dbselectarea("SC6")
    	             dbseek(xFilial("SC6")+aMatImp[nX][02]+aMatImp[nX][06]+aMatImp[nX][05])
        	         if found()
						nTotVol += SC6->C6_VOLITEM
					 endif	
                     If mv_par08 == 1 
                     	@ nLin,000  PSAY aMatImp[nX][01]+"-"+aMatImp[nX][02]
                     	@ nLin,010  PSAY Alltrim(aMatImp[nX][03])+"-"+SubStr(Posicione("SA1", 1, xFilial("SA1")+aMatImp[nX][03], "A1_NOME"), 1, 30)
                     	@ nLin,048  PSAY Alltrim(Posicione("SZ7", 1, xFilial("SZ7")+Posicione("SA1", 1, xFilial("SA1")+aMatImp[nX][03], "A1_CODCID"), "Z7_REGIAO"))
                     	@ nLin,051  PSAY "/"
                     	@ nLin,052  PSAY Alltrim(Posicione("SA4", 1, xFilial("SA4")+Posicione("SC5", 1, xFilial("SC5")+aMatImp[nX][02], "C5_TRANSP"), "A4_REGIAO"))
                     	@ nLin,057  PSAY aMatImp[nX][04] Picture "@E 999999" //* Iif(!Empty(aMatImp[nX][14]), 2, 1)
                     	@ nLin,nCol PSAY Iif(Empty(aMatImp[nX][12]), " ", Alltrim(aMatImp[nX][12]))
/* 	                    dbselectarea("SC6")
    	                dbseek(xFilial("SC6")+aMatImp[nX][02]+aMatImp[nX][06]+aMatImp[nX][05])
        	            if found()
							nTotVol += SC6->C6_VOLITEM
						endif	
*/                     	nLin += 1
                        //{TCQ->EMPRESA   , TCQ->C9_PEDIDO , TCQ->C9_CLIENTE, TCQ->C9_QTDLIB , TCQ->C9_PRODUTO, TCQ->C9_ITEM   , TCQ->C9_SEQUEN , TCQ->C9_FLGIMP , TCQ->C9_LOCAL  , TCQ->C9_LOJA   , TCQ->B2_COD    , TCQ->B2_LOCALIZ, TCQ->C5_VOLUME1, TCQ->C5_ESPECI4, ''             }
                     Endif
                     nQtdeProd += aMatImp[nX][04] // * Iif(!Empty(aMatImp[nX][14]), 2, 1)
                     aMatImp[nX][15] := 'S'
                  Endif
              Next
              If mv_par08 == 1
                 @ nLin,000 PSAY Replicate("_", 80)
                 nLin += 1
                 If nLin >= 60
                    nLin := Cabec(alltrim(Titulo)+iif(mv_par07 == 4," - LISTA "+padl(alltrim(str(nLista)),2,"0"),""),cCabec1,cCabec2,nomeprog,tamanho,nTipo)
                    nLin += 1
                 Endif
                 nLin += 1
                 @ nLin,030 PSAY "Qtde. Total do Produto => "
                 @ nLin,057 PSAY nQtdeProd Picture "@E 999999"
                 @ nLin,064 PSAY "Q. Vol."
                 @ nLin,074 PSAY nTotVol Picture "@E 999999"
                 nLin += 1
                 @ nLin,000 PSAY Replicate("=", 80)
                 nLin += 1
              Else

          //                0          1         2         3         4         5         6         7  
          //          01234567890123456789012345678901234567890123456789012345678901234567890123456789
          //          XXX9999999-99-XXXXXXXXX (XXXXXXXXXX) XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 999999
          cCabec1 := "PRODUTO       DESCRIÇÃO EMBAL        LOC PROVIS     LOCALIZ           VOL   QTDE"

                 @ nLin, 070  PSAY nTotVol Picture "@E 999"
                 If !Empty(cEnvase)
                    @ nLin,073 PSAY cEnvase
                 Endif
                 @ nlin,075 PSAY nQtdeProd Picture "@E 99999"
                 nLin += 1
                 @ nlin,000 PSAY Replicate("_",80)
                 nLin += 1 // Avanca a linha de impressao
              Endif
           Endif
       Next
       For nY := 1 To Len(aMatPed)
           If aScan(aMatReg, {|x| x[1] == aMatPed[nY][2]}) == 0
              aAdd(aMatReg, {aMatPed[nY][2], aMatPed[nY][3]})
           Else
              aMatReg[aScan(aMatReg, {|x| x[1] == aMatPed[nY][2]})][2] += aMatPed[nY][3]
           Endif
       Next
       If nLin >= 60
          nLin := Cabec(alltrim(Titulo)+iif(mv_par07 == 4," - LISTA "+padl(alltrim(str(nLista)),2,"0"),""),cCabec1,cCabec2,nomeprog,tamanho,nTipo)
          nLin += 1
       Endif
       //               0         1         2         3         4
       //               01234567890123456789012345678901234567890
       //               999-XXXXXXXXXXXXXXXXXXXXXXXXX
       nLin += 1
       @ nLin,000 PSAY "REGIAO                           QTDEVOL"
       nLin += 1
       For nY := 1 To Len(aMatReg)
           If nLin >= 60
              nLin := Cabec(alltrim(Titulo)+iif(mv_par07 == 4," - LISTA "+padl(alltrim(str(nLista)),2,"0"),""),cCabec1,cCabec2,nomeprog,tamanho,nTipo)
              nLin += 1
           Endif
           @ nLin,000 PSAY aMatReg[nY][01]+"-"+FDesc("SX5", "98"+aMatReg[nY][01], "X5_DESCRI", 25)
           @ nLin,030 PSAY aMatReg[nY][02] Picture "@E 999,999.99"
           nLin += 1
       Next
       
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
/* DESABILITADO RELEASE 12.1.25
Static Function VldPerg()
       Local aHelp1 := {} ; Local aHelp2 := {} ; Local aHelp3 := {} ; Local aHelp4 := {} ; Local aHelp5 := {}
       aAdd( aHelp1, "Informe o periodo de aprovação do   " )
       aAdd( aHelp1, "pedido para emissão do relatório.   " )
       aAdd( aHelp2, "Informe a faixa de borderos a serem " )
       aAdd( aHelp2, "impressos.                          " )
       aAdd( aHelp3, "Informe o periodo de emissão do bor-" )
       aAdd( aHelp3, "dero para emissão do relatório.     " )
       aAdd( aHelp4, "Informe a ordem do relatório.       " )
       aAdd( aHelp5, "Informe o tipo do relatório.        " )
       PutSX1("FATR04    ", "01"  ,   "Da  Data Aprov. Ped.", ""     , ""     , "mv_ch1", "D"  , 8       , 0       , 0      , "G" , " "   , " ", " "    , " "  , "mv_par01", " "        , " "     , " "     , " "   , " "        , " "     , " "     , " "  , " "     , " "     , " ", " "     , " "     , " ",  " "     ,  " "     , aHelp1  , Nil     , Nil     , "FATR04" )
       PutSX1("FATR04    ", "02"  ,   "Até Data Aprov. Ped.", ""     , ""     , "mv_ch2", "D"  , 8       , 0       , 0      , "G" , " "   , " ", " "    , " "  , "mv_par02", " "        , " "     , " "     , " "   , " "        , " "     , " "     , " "  , " "     , " "     , " ", " "     , " "     , " ",  " "     ,  " "     , aHelp1  , Nil     , Nil     , "FATR04" )
       PutSX1("FATR04    ", "03"  ,   "Do  Bordero         ", ""     , ""     , "mv_ch3", "C"  , 6       , 0       , 0      , "G" , " "   , " ", " "    , " "  , "mv_par03", " "        , " "     , " "     , " "   , " "        , " "     , " "     , " "  , " "     , " "     , " ", " "     , " "     , " ",  " "     ,  " "     , aHelp2  , Nil     , Nil     , "FATR04" )
       PutSX1("FATR04    ", "04"  ,   "Até Bordero         ", ""     , ""     , "mv_ch4", "C"  , 6       , 0       , 0      , "G" , " "   , " ", " "    , " "  , "mv_par04", " "        , " "     , " "     , " "   , " "        , " "     , " "     , " "  , " "     , " "     , " ", " "     , " "     , " ",  " "     ,  " "     , aHelp2  , Nil     , Nil     , "FATR04" )
       PutSX1("FATR04    ", "05"  ,   "Da  Emissão Bordero ", ""     , ""     , "mv_ch5", "D"  , 8       , 0       , 0      , "G" , " "   , " ", " "    , " "  , "mv_par05", " "        , " "     , " "     , " "   , " "        , " "     , " "     , " "  , " "     , " "     , " ", " "     , " "     , " ",  " "     ,  " "     , aHelp3  , Nil     , Nil     , "FATR04" )
       PutSX1("FATR04    ", "06"  ,   "Até Emissão Bordero ", ""     , ""     , "mv_ch6", "D"  , 8       , 0       , 0      , "G" , " "   , " ", " "    , " "  , "mv_par06", " "        , " "     , " "     , " "   , " "        , " "     , " "     , " "  , " "     , " "     , " ", " "     , " "     , " ",  " "     ,  " "     , aHelp3  , Nil     , Nil     , "FATR04" )
       PutSX1("FATR04    ", "07"  ,   "Ordem de            ", ""     , ""     , "mv_ch7", "N"  , 1       , 0       , 0      , "C" , " "   , " ", " "    , " "  , "mv_par07", "Quadrante", " "     , " "     , " "   , "Produto"  , " "     , " "     , "Cor", " "     , " "     , "Embalagem", " "     , " "     , " ",  " "     ,  " "     , aHelp4  , Nil     , Nil     , "FATR04" )
       PutSX1("FATR04    ", "08"  ,   "Tipo                ", ""     , ""     , "mv_ch8", "N"  , 1       , 0       , 0      , "C" , " "   , " ", " "    , " "  , "mv_par08", "Analítico", " "     , " "     , " "   , "Sintético", " "     , " "     , " "  , " "     , " "     , " ", " "     , " "     , " ",  " "     ,  " "     , aHelp5  , Nil     , Nil     , "FATR04" )
       PutSX1("FATR04    ", "09"  ,   "Do Quadrante        ", ""     , ""     , "mv_ch9", "C"  , 15      , 0       , 0      , "G" , " "   , " ", " "    , " "  , "mv_par09", " "        , " "     , " "     , " "   , " "        , " "     , " "     , " "  , " "     , " "     , " ", " "     , " "     , " ",  " "     ,  " "     , {"Quadrante Inicial"}  , Nil     , Nil     , "FATR04" )
       PutSX1("FATR04    ", "10"  ,   "Até o Quadrante     ", ""     , ""     , "mv_chA", "C"  , 15      , 0       , 0      , "G" , " "   , " ", " "    , " "  , "mv_par10", " "        , " "     , " "     , " "   , " "        , " "     , " "     , " "  , " "     , " "     , " ", " "     , " "     , " ",  " "     ,  " "     , {"Quadrante Final"}  , Nil     , Nil     , "FATR04" )
Return
*/
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
