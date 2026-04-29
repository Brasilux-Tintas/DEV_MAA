#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TOTVS.CH"

//Dyego Figueredo
//Rotina para incluir no pedido de venda, os itens de MP utilizados
//no produto TA e vincular com os saldos de terceiros

User Function INCTA4()

	Local posC6ITEM 	:= GdFieldPos("C6_ITEM",	aHeader)
	Local posC6PRODUTO 	:= GdFieldPos("C6_PRODUTO",	aHeader)
	Local posC6LOCAL 	:= GdFieldPos("C6_LOCAL",	aHeader)
	Local posC6UM 		:= GdFieldPos("C6_UM",		aHeader)
	Local posC6QTDLIB 	:= GdFieldPos("C6_QTDLIB",	aHeader)
	Local posC6QTDVEN 	:= GdFieldPos("C6_QTDVEN",	aHeader)
	Local posC6PRCVEN 	:= GdFieldPos("C6_PRCVEN",	aHeader)
	Local posC6VALOR 	:= GdFieldPos("C6_VALOR",	aHeader)
	Local posC6OPER 	:= GdFieldPos("C6_OPER",	aHeader)
	Local posC6TES 		:= GdFieldPos("C6_TES",		aHeader)
	Local posC6CF 		:= GdFieldPos("C6_CF",		aHeader)
	Local posC6CLAFIS   := GdFieldPos("C6_CLASFIS", aHeader)
	Local posC6DESCRI 	:= GdFieldPos("C6_DESCRI",	aHeader)
	Local posC6LOTECTL	:= GdFieldPos("C6_LOTECTL",	aHeader)


	Local posC6RECWT	:= GdFieldPos("C6_REC_WT",	aHeader)

	Local posC6NFORI	:= GdFieldPos("C6_NFORI",	aHeader)
	Local posC6SERIORI	:= GdFieldPos("C6_SERIORI",	aHeader)
	Local posC6ITORI	:= GdFieldPos("C6_ITEMORI",	aHeader)
	Local posC6NUMOP	:= GdFieldPos("C6_XNUMOP",	aHeader)
	Local posC6ITOP		:= GdFieldPos("C6_XITEMOP",	aHeader)

	Local posC6XTERCTP		:= GdFieldPos("C6_XTERCTP",	aHeader)

	Local posC6IDENTB6	:= GdFieldPos("C6_IDENTB6",	aHeader)

	Local posC6NUMPCOM	:= GdFieldPos("C6_NUMPCOM",	aHeader)





	Local cOperac, maxItem
    //Local cLocal, cCodPallet
	Local cPedido	:= M->C5_NUM // aCols[N][posC6NUM]
	Local cProduto	:= aCols[N][posC6PRODUTO]
	Local cLote		:= aCols[N][posC6LOTECTL]
	Local nC6QTDVEN := aCols[N][posC6QTDVEN]
	Local cCliente	:= M->C5_CLIENTE
	Local cLoja 	:= M->C5_LOJACLI

	//Local nX, j
	Local nI, i

	Local estFil := ""
	Local estCli := ""

	Local cPT
	Private	_cLote:= " "
	Private _aArea := getArea()
	Private _cCodProd := " "
	Private _cLocal:=""
	Private _nQuant:=0
	Private _aItens:={}, _aAux:={}




	If Empty(N) .OR. ! Posicione("SB1",1,XfILIAL("SB1")+(aCols[N,posC6PRODUTO]),"B1_TIPO") $ "PA/TA"

		MsgAlert("O item selecionado não é do tipo TA", "INCTA.PRW")
		Return
	Endif

	estFil :=  GETMV("MV_ESTADO")

	IF M->C5_TIPO=="N"
		estCli := Posicione("SA1",1,XfILIAL("SA1")+cCliente + cLoja,"A1_EST")

	ElseIf 	 M->C5_TIPO=="B"
		estCli := Posicione("SA2",1,XfILIAL("SA2")+cCliente + cLoja,"A2_EST")

	Endif


	//maxItem		:= 0
	maxItem		:= ""

	nQtdPallet 	:= 0

 	//Varre os itens do Pedido de Vendas
	For i := 1 to Len(aCols)

		//maxItem	:= Val(aCols[i, posC6ITEM])
		maxItem	:= (aCols[i, posC6ITEM])

		If  aCols[i][len(aHeader)+1]
			loop
		Endif

	Next


	aAux:={}
	aAuxOrig :=aclone(acols)

	aAux := Array(Len(aHeader)+1)


	For nI := 1 To Len( aHeader )

		If ! (aHeader[nI,2] $ "C6_ALI_WT/C6_REC_WT")
			aAux[nI] := CriaVar(aHeader[nI,2],.T.)
		Else
			aAux[nI] :=	aCols[1][nI]

		Endif

	Next nI

	aAuxLimpo := aclone(aAux)

	//INICIO

	nQuant1 := Query01(cProduto, cLote, cPedido)
	nQuant2 := 	qtdTAPed (cLote, cProduto, aCols)

	cPT := "P"
	If (nQuant1 - nQuant2) == 0
		cPT := "T"
	Endif

	aCols[N][posC6XTERCTP] := cPT
	//FIM

	aItensSD3 :=  querySD3(cCliente, cLoja, cProduto, cLote, nC6QTDVEN, cPT, cPedido)

	If Empty(aItensSD3)
		MsgAlert("Não localizado o apontamento de OP deste item TA (de OP encerradas) ou a matéria prima está sem saldo disponível!", "TECPOLPA - INCTA.PRW")
		Return
	Endif

	for i := 1  to len(aItensSD3)

		cTeste := ""

		maxItem := Soma1(maxItem, TamSX3("C6_ITEM")[1])

		//maxItem := maxItem + 1


		//	1= op 2=item 3=cod pro	 4= desc 5=UM	6= Qtd	7=preco   8= doc orig 	9= serie orig  10 = item orig	 11  = operaca 12= loc pad 13=Ident sb6  14 TIPO

		nC6QTDVEN :=  Round(aItensSD3[i][6]	,TamSX3("C6_QTDVEN")[2])

		If  /*aItensSD3[i][14] $ 'MP/TP' .AND.*/ aItensSD3[i][5]  == 'KG'    /////  JOSE ver Gustavo o produzido é LT
			nC6QTDVEN := Round(aItensSD3[i][6]	,4)
		Endif

		//correto
		//nTotal := Round(nC6QTDVEN  * aItensSD3[i][7],TamSX3("C6_VALOR")[2])

		//nTotal := Round(nC6QTDVEN  * Round(aItensSD3[i][7]	,TamSX3("C6_PRCVEN")[2]) ,TamSX3("C6_VALOR")[2])

		nTotal := a410Arred(nC6QTDVEN  * Round(aItensSD3[i][7]	,TamSX3("C6_PRCVEN")[2]) ,"C6_VALOR")

		//alert("item: " + maxItem)
		If aItensSD3[i][15] <> 0.0
			//alert(" entrou " )
			nTotal := aItensSD3[i][15] // 15 D1_VALOR
		Endif

		//aAux[posC6ITEM] 	:= Strzero(maxItem , 2)
		aAux[posC6ITEM] 	:= maxItem

		aAux[posC6PRODUTO] 	:= aItensSD3[i][3]
		aAux[posC6UM] 		:= aItensSD3[i][5]
		aAux[posC6QTDVEN] 	:= nC6QTDVEN
		aAux[posC6PRCVEN] 	:= Round(aItensSD3[i][7]	,TamSX3("C6_PRCVEN")[2])
		aAux[posC6VALOR] 	:= nTotal // Round(nC6QTDVEN  * aItensSD3[i][7],TamSX3("C6_VALOR")[2])
		aAux[posC6QTDLIB] 	:= 0
		aAux[posC6OPER] 	:= aItensSD3[i][11]


		cOperac		:= aItensSD3[i][11]

		//TES (Gatilho da TES inteligente
		_cTes := getTes(cOperac,cCliente, cLoja, aItensSD3[i][3] )
		_cCF := Posicione("SF4",1,xFilial("SF4")+ _cTes,"F4_CF")

		If ! Empty(_cCF)
			If AllTrim(estFil) == AllTrim(estCli)
				_cCF :=  "5" + Substr(_cCF, 2, 3)
			Else
				_cCF :=  "6" + Substr(_cCF, 2, 3)
			Endif
		Endif

		aAux[posC6TES] 		:= _cTes



		aAux[posC6CF] 		:= _cCF

		aAux[posC6CLAFIS] 	:= CodSitTri()				//Operação
		aAux[posC6NFORI] 	:= aItensSD3[i][8]
		aAux[posC6SERIORI] 	:= aItensSD3[i][9]
		aAux[posC6ITORI] 	:= aItensSD3[i][10]
		aAux[posC6NUMOP] 	:= aItensSD3[i][1]
		aAux[posC6ITOP] 	:= aItensSD3[i][2]          //para nao validar
		aAux[posC6IDENTB6] 	:= aItensSD3[i][13]
		aAux[posC6LOCAL] 	:= aItensSD3[i][12]			//Armazem
		aAux[posC6DESCRI] 	:= aItensSD3[i][4] 			//Descrição
		aAux[posC6RECWT] 	:= 0						//Recno do acols

		If nTotal > 0.0 
			aAux[len(aHeader)+1] 	:= .F. /* NÃO APAGA LINHA */
		Else
			aAux[len(aHeader)+1] 	:= .T. /* APAGA LINHA */
		Endif

		/* produtos da estrutura deleta nelieder 16/08/2022 */
		if aItensSD3[i][16] == "RE1"
			aAux[len(aHeader)+1] 	:= .T. /* apaga linha de produtos da estrutura do produto */	
		EndIf

		/* nelieder 16/08/2022 */
		If (SUBSTR(aItensSD3[i][3], 2,3) $ "AAA")
			If !Empty( GETMV("ZP_PAR0062")) .AND. (aItensSD3[i][16] <> "RE1")
				aAux[len(aHeader)+1] 	:= .F.
			EndIf
		EndIf

		
		If ( cCliente	+ cLoja ) == "00002802"
			aAux[posC6NUMPCOM] 	:= Posicione('SB1',1,xFilial('SB1')+aAux[posC6PRODUTO] , 'B1_XPRGREM')
		Endif


		Aadd(aAuxOrig,aAux)
		//Aadd(M->acols,aAux)
		aAux := aClone(aAuxLimpo)


	next i

	M->acols := aAuxOrig

	//nLin := LEN(acols)


	SysRefresh()
	GETDREFRESH()

	RestArea(_aArea)

Return Nil



Static Function getTes(cOper, cCliente, cLoja,cProd )

	Local cTes:=""
	Local _aArea:=getArea()

	cTes:= MaTesInt(2,cOper,cCliente,cLoja,If(M->C5_TIPO$'DB',"F","C"),cProd,"C6_TES") 

	RestArea(_aArea)
Return cTes


Static function querySD3(cCliente, cLoja, cProduto, cLote, nC6QTDVEN, cPT, cPedido)

	Local _aItAcols := {}
	Local j := 0
	Private cQLinha   := Chr(13) + Chr(10)

	nC6QTDVEN := str(nC6QTDVEN)

	If Select("TMSD3")<>0
		dbselectarea("TMSD3")
		dbclosearea()
	Endif



cQuery := "SELECT *,																												"+cQLinha

cPT := "P" // TESTE

If cPT == "P"     ////////   JOSE VER COM GUSTAVO -  FALTA O TIPO MP o da TecPolpa é PI e o codigo do produto é '1AAAAUNC1LB1' dos pI é só ele para entrar
	If getmv("MV_XARDSC6")
///*Cleber(24/09/20)->subst pela linha abaixo*/		cQuery += "	CASE WHEN B1_TIPO IN ('EM', 'TE', 'MC', 'TC') AND B1_UM IN ('UN') AND FLOOR (( A.QUANT_ITEM_SD3 *  "+nC6QTDVEN+") /A.QTDPA ) > 0.0 THEN FLOOR (( A.QUANT_ITEM_SD3 *  "+nC6QTDVEN+") /A.QTDPA )	"+cQLinha
		cQuery += "	CASE WHEN (B1_UM = 'UN') AND ((B1_TIPO IN ('EM', 'TE', 'MC', 'TC')) OR ((B1_TIPO = 'MP') AND (B1_COD LIKE '4%'))) AND FLOOR (( A.QUANT_ITEM_SD3 *  "+nC6QTDVEN+") /A.QTDPA ) > 0.0 THEN FLOOR (( A.QUANT_ITEM_SD3 *  "+nC6QTDVEN+") /A.QTDPA )	"+cQLinha
		cQuery += "		ELSE ((A.QUANT_ITEM_SD3 *     "+nC6QTDVEN+") / A.QTDPA) 														"+cQLinha
		cQuery += " END QTD_ITEM_CALC 																									"+cQLinha
	Else
		cQuery += "		(A.QUANT_ITEM_SD3 * "+nC6QTDVEN+" /  A.QTDPA) AS QTD_ITEM_CALC													"+cQLinha

	Endif


//SE FOR TOTAL, RETORNA A QUANTIDADE RESTANTE DA MP PARA RESOLVER O PROBLEMA DO ARREDONDAMENTO PARA BAIXO
Else


	cQuery += " QUANT_ITEM_SD3 -												"+cQLinha
	cQuery += " ISNULL((														"+cQLinha
	cQuery += "SELECT   SUM(D2_QUANT - D2_QTDEDEV) QTD_FAT						"+cQLinha
	cQuery += "FROM "+RetSqlName("SD2")+" SD2									"+cQLinha
	cQuery += "		INNER JOIN "+RetSqlName("SC6")+" SC6 ON C6_FILIAL = '"+xFilial("SC6")+"'	AND D2_PEDIDO = C6_NUM AND D2_ITEMPV = C6_ITEM AND D2_COD = C6_PRODUTO AND SC6.D_E_L_E_T_ = ''"+cQLinha
	cQuery += "WHERE SD2.D_E_L_E_T_ = ''										"+cQLinha
	cQuery += "AND D2_FILIAL =	'"+xFilial("SD2")+"'							"+cQLinha
	//cQuery += "AND D2_ESTOQUE = 'S'											"+cQLinha
	cQuery += "AND D2_COD = A.B1_COD											"+cQLinha
	cQuery += "AND C6_XNUMOP = SUBSTRING(D3_OP, 1,6)							"+cQLinha
	cQuery += "																	"+cQLinha
	cQuery += "), 0) - 															"+cQLinha
	cQuery += "																	"+cQLinha
	cQuery += " ISNULL((SELECT 	SUM( SC6.C6_QTDVEN-SC6.C6_QTDENT )  QTDLIB		"+cQLinha
	cQuery += "		FROM "+RetSqlName("SC6")+" SC6 								"+cQLinha
	cQuery += "				INNER JOIN "+RetSqlName("SF4")+" SF4  ON F4_FILIAL = '"+xFilial("SF4")+"'	 AND SC6.C6_TES = SF4.F4_CODIGO AND SF4.D_E_L_E_T_ = ' '   "+cQLinha
	cQuery += "		WHERE SC6.D_E_L_E_T_ = ' '  								"+cQLinha
	cQuery += "			AND C6_FILIAL = '"+xFilial("SC6")+"'					"+cQLinha
	cQuery += "			AND SC6.C6_BLQ <> 'R'									"+cQLinha
	cQuery += "			AND SC6.C6_QTDENT < SC6.C6_QTDVEN						"+cQLinha
	//cQuery += "			AND SC5.C5_TIPO		= 'N' 							"+cQLinha
	cQuery += "			AND SC6.C6_NUM		!= '"+cPedido+"'				"+cQLinha
	//cQuery += "			AND SF4.F4_ESTOQUE	= 'S'							"+cQLinha
	cQuery += "			AND C6_PRODUTO = A.B1_COD								"+cQLinha
	cQuery += "			AND C6_XNUMOP = SUBSTRING(D3_OP, 1,6)), 0) QTD_ITEM_CALC "+cQLinha


Endif

cQuery += "FROM (																	"+cQLinha
cQuery += "SELECT  SUBSTRING(SD3.D3_OP, 1,6) + '01001' D3_OP,D3_CF, 				"+cQLinha
cQuery += "		SB1.B1_COD ,														"+cQLinha
cQuery += "		SB1.B1_DESC, 														"+cQLinha
cQuery += "		SB1.B1_TIPO ,														"+cQLinha
cQuery += "		SB1.B1_UM, 															"+cQLinha
cQuery += "		SB1.B1_LOCPAD, 														"+cQLinha
cQuery += "		SUM(SD3.D3_QUANT) QUANT_ITEM_SD3,									"+cQLinha
cQuery += "		( 	SELECT  SUM(SD3_.D3_QUANT)    									"+cQLinha
cQuery += "			FROM "+RetSqlName("SD3")+"  SD3_ 								"+cQLinha
cQuery += "			WHERE SD3_.D_E_L_E_T_ = '' 										"+cQLinha
cQuery += "				AND SD3_.D3_FILIAL		= '"+xFilial("SD3")+"'				"+cQLinha
cQuery += "				AND SD3_.D3_ESTORNO		<> 'S'		 						"+cQLinha
cQuery += "				AND SD3_.D3_COD  		= '"+cProduto+"'					"+cQLinha
cQuery += "				AND SD3_.D3_LOTECTL 	= '"+cLote+"'						"+cQLinha
cQuery += "				AND SD3_.D3_OP			<> ''								"+cQLinha
cQuery += "				AND SUBSTRING(SD3_.D3_OP,7,2) <> 'OS' 						"+cQLinha
cQuery += "				AND SD3_.D3_CF			= 'PR0'								"+cQLinha
cQuery += "             AND ( SD3_.D3_TIPO    NOT IN ('PI', 'TI', 'MO') OR ( SD3.D3_TIPO = 'PI' AND SD3.D3_GRUPO = 'MSUG' ) ) "+cQLinha
//Linha abaixo substituida pela linha de cima, por Jose Ulina entrou Açucar Liquido prodyzido pela TecPolpa
//cQuery += "				AND SD3_.D3_TIPO			NOT IN ('PI', 'TI', 'MO')		"+cQLinha     ///// JOSE VER COM O GUSTAVO 
cQuery += "				AND SUBSTRING(SD3_.D3_OP, 1,6)   =  SUBSTRING(SD3.D3_OP, 1,6)  	"+cQLinha
cQuery += "		) QTDPA																"+cQLinha
cQuery += "FROM	"+RetSqlName("SD3")+"  SD3											"+cQLinha
cQuery += "			INNER JOIN "+RetSqlName("SB1")+"  SB1		ON SB1.B1_FILIAL	= '"+xFilial("SB1")+"'		AND SD3.D3_COD = SB1.B1_COD		AND SB1.D_E_L_E_T_ = ''						"+cQLinha
cQuery += "WHERE  SD3.D_E_L_E_T_ = ''												"+cQLinha
cQuery += "	AND SD3.D3_FILIAL		= '"+xFilial("SD3")+"'							"+cQLinha
cQuery += "	AND SD3.D3_ESTORNO		<> 'S'											"+cQLinha
cQuery += " AND ( SD3.D3_TIPO       NOT IN ('PI', 'TI', 'MO') OR ( SD3.D3_TIPO = 'PI' AND SD3.D3_GRUPO = 'MSUG' ) ) "+cQLinha
//Linha abaixo substituida pela linha de cima, por Jose Ulina entrou Açucar Liquido prodyzido pela TecPolpa
//cQuery += "	AND SD3.D3_TIPO			NOT IN ('PI', 'TI', 'MO')						"+cQLinha   ///// JOSE VER COM O GUSTAVO

cQuery += "	AND SD3.D3_CF			!= 'PR0'										"+cQLinha //Nelieder 16/08/2022

//cQuery += "	AND SD3.D3_CF			NOT IN ('PR0','RE1')							"+cQLinha  Nelieder 16/08/2022

cQuery += " AND  SUBSTRING(SD3.D3_OP,7,2) <> 'OS' 									"+cQLinha
cQuery += "	AND ISNULL((SELECT DISTINCT CASE WHEN C2_DATRF = ' ' THEN 'ABERTA'	ELSE 'ENCERRADA' END  FROM	"+RetSqlName("SC2")+" SC2 WHERE	SC2.D_E_L_E_T_ = '' AND C2_FILIAL = '"+xFilial("SC2")+"' AND  C2_NUM + C2_ITEM + C2_SEQUEN = RTRIM(SUBSTRING(SD3.D3_OP, 1,6) + '01001' )), 'XYZ') = 'ENCERRADA'  "+cQLinha  // busca apenas ops encerradas
cQuery += " AND  SUBSTRING(SD3.D3_OP, 1,6) IN 										"+cQLinha
cQuery += "	( 	SELECT  SUBSTRING(SD3_.D3_OP, 1,6)   								"+cQLinha
cQuery += "		FROM "+RetSqlName("SD3")+"  SD3_ 									"+cQLinha
cQuery += "		WHERE SD3_.D_E_L_E_T_ = '' 											"+cQLinha
cQuery += "			AND SD3_.D3_FILIAL		= '"+xFilial("SD3")+"'					"+cQLinha
cQuery += "			AND SD3_.D3_ESTORNO		<> 'S'		 							"+cQLinha
cQuery += "			AND SD3_.D3_COD  		= '"+cProduto+"'						"+cQLinha
cQuery += "			AND SD3_.D3_LOTECTL 	= '"+cLote+"'							"+cQLinha
cQuery += "			AND SD3_.D3_OP			<> ''									"+cQLinha
cQuery += "		)																	"+cQLinha
cQuery += "GROUP BY SUBSTRING(SD3.D3_OP, 1,6),										"+cQLinha
cQuery += "		SD3.D3_CF,															"+cQLinha
cQuery += "		SB1.B1_COD ,														"+cQLinha
cQuery += "		SB1.B1_DESC, 														"+cQLinha
cQuery += "		SB1.B1_TIPO ,														"+cQLinha
cQuery += "		SB1.B1_UM, 															"+cQLinha
cQuery += "		SB1.B1_LOCPAD,														"+cQLinha
//--------------------------------------------------------------------------------------------
// Acrescentado pelo Jose Uliana
cQuery += "		SD3.D3_TIPO,									      				"+cQLinha
cQuery += "		SD3.D3_GRUPO									      				"+cQLinha
//-------------------------------------------------------------------------------------------
cQuery += ")A																		"+cQLinha
cQuery += "ORDER BY 1,2																"+cQLinha



 // conout('x1 -> ' + (cQuery) )

//AVISO("Título", cQuery, { "Botao1", "Botao2" }, 1)

	TCQUERY cQuery ALIAS TMSD3 NEW
	dbSelectArea("TMSD3")
	dbGoTop()

	If TMSD3->(EOF())
		//LGS#20200131 - Adequação de release 12.1.25 e posteriores
		//ConOut("A Query nao retornou dados - fonte INCTA.prw")
		FwLogMSG( "INFO", , 'SIGAFAT', funname(), '', '01', "A Query nao retornou dados - fonte INCTA.prw", 0 )
	Endif

	While !TMSD3->(EOF())

	//aadd(_aItens,{TMSD3->D3_OP ,  TMSD3->B1_COD, TMSD3->B1_DESC, TMSD3->B1_UM, TMSD3->QTD_ITEM_CALC})
	//					 1				 2			 3					4	                5




		nQtdCalc := TMSD3->QTD_ITEM_CALC
        //LGS#20200131 - Adequação de release 12.1.25 e posteriores
		//conout('x2 -> ' + str(nQtdCalc) )
		FwLogMSG( "INFO", , 'SIGAFAT', funname(), '', '01', 'x2 -> ' + str(nQtdCalc), 0 )
		If cPT == "P"
				nQtdCalc := nQtdCalc - sub2QtdPed (substr(TMSD3->D3_OP,1,6), cProduto, aCols)
				//LGS#20200131 - Adequação de release 12.1.25 e posteriores
				//conout('x3 -> ' + str(nQtdCalc) )
		        FwLogMSG( "INFO", , 'SIGAFAT', funname(), '', '01', 'x3 -> ' + str(nQtdCalc), 0 )
			Endif

		/* produtos tecpolpa */
		
		If (SUBSTR(TMSD3->B1_COD, 2,3) $ "AAA")

			/* tem tabela de preço cadastrada e não faz parte de estrutura */
			If !Empty( GETMV("ZP_PAR0062")) .AND. (TMSD3->D3_CF <> "RE1")
				
				_nPreco := 0
				dbselectarea("DA1")
        		dbsetorder(1) //Cod. Tabela + Cod.Produto
        		if dbseek(xFilial("DA1")+PADR(GETMV("ZP_PAR0062"),TamSX3("DA1_CODTAB")[1])+PADR(TMSD3->B1_COD,TamSX3("DA1_CODPRO")[1])) 
					_nPreco := DA1->DA1_PRCVEN
				else
					MessageBox( 'O Produto '+TMSD3->B1_COD+' não está cadastrado na Tabela de Preço '+GETMV("ZP_PAR0062")+', favor verificar !', "Atenção!", 16 )
				EndIf

			Else
				_nPreco		:=  u_RMarkup(0, cCliente, cLoja, TMSD3->B1_COD)	
			EndIf	
			


			aadd(_aItAcols,{substr(TMSD3->D3_OP,1,6) , substr(TMSD3->D3_OP,7,2)  ,  TMSD3->B1_COD, TMSD3->B1_DESC, TMSD3->B1_UM, nQtdCalc 		, _nPreco,  			SPACE(TamSX3("D1_DOC")[1]), 			SPACE(TamSX3("D1_SERIE")[1]),	SPACE(TamSX3("D1_ITEM")[1] ), 				"SM", 			TMSD3->B1_LOCPAD,  SPACE(TamSX3("D1_NUMSEQ")[1]), TMSD3->B1_TIPO, 0 , TMSD3->D3_CF})
			//						1= op						2=item				3=cod pro		4= desc			 5=UM			6= Qtd		 		7=preco   		  8= doc orig 							9= serie orig 				  10 = item orig						11= operacao	12= loc pad			13 = IDENT SB6							14 TIPO

		Else


			aItensSB6 := querySB6(TMSD3->B1_COD, cCliente, cLoja, nQtdCalc, _aItAcols)

			If Empty(aItensSB6)
				MsgAlert(".Não foi localizado saldo de terceiros para o produto: " + TMSD3->B1_COD + " - " + TMSD3->B1_DESC , "TECPOLPA - INCTA.PRW")
				Return Nil
			Else

				for j := 1  to len(aItensSB6)


					aadd(_aItAcols,{substr(TMSD3->D3_OP,1,6) ,  substr(TMSD3->D3_OP,7,2),  	TMSD3->B1_COD, TMSD3->B1_DESC, TMSD3->B1_UM, aItensSB6[j][5], 	aItensSB6[j][3],  aItensSB6[j][1],  aItensSB6[j][2],  aItensSB6[j][4], 		aItensSB6[j][9], 		TMSD3->B1_LOCPAD,  aItensSB6[j][8], TMSD3->B1_TIPO, aItensSB6[j][10], TMSD3->D3_CF})
					//							1= op				2=item					3=cod pro		4= desc			 5=UM			6= Qtd		 		7=preco   		  8= doc orig 		9= serie orig 	  10 = item orig	11= operac			12= loc pad    			13 IDENT		14 TIPO			15 D1_VALOR,      16 D3_CF

				Next j

			Endif

		Endif

		dbSelectArea("TMSD3")
		TMSD3->(dbSkip())
	EndDo

Return _aItAcols


Static function querySB6(cProduto, cCliente, cLoja, nQuant, aItensSB6)

	Local _aItens := {}
	Local saldoAtual := 0.0
	Local nSaldo := nQuant

	Private cQLinha   := Chr(13) + Chr(10)

	If Select("TMSB6")<>0
		dbselectarea("TMSB6")
		dbclosearea()
	Endif

	//LGS#20200131 - Adequação de release 12.1.25 e posteriores
	//CONout("nsaldo-> " + str(nSaldo) )
	FwLogMSG( "INFO", , 'SIGAFAT', funname(), '', '01', "nsaldo-> " + str(nSaldo), 0 )
	cQuery := "SELECT B6_LOCAL, B6_CLIFOR, B6_LOJA, B6_DOC, B6_SERIE, B6_SALDO, B6_PRUNIT, D1_VUNIT, D1_ITEM, D1_TIPO, D1_TES, B6_IDENT, CASE F4_ESTOQUE	WHEN 'S' THEN 'SI'	ELSE 'ST' END OPERACAO,	"+cQLinha
	cQuery += "D1_TOTAL - D1_VALDESC- D1_VALDEV  	 TOTALD1,  D1_QUANT, "+cQLinha
	cQuery += "(SELECT SUM( C6_QTDVEN - C6_QTDENT) 			"+cQLinha
	cQuery += "FROM "+RetSqlName("SC6")+" SC6 				"+cQLinha
	cQuery += "		INNER JOIN "+RetSqlName("SC5")+" SC5 ON C5_FILIAL 	= '"+xFilial("SC5")+"' AND C5_NUM = C6_NUM		AND 	SC5.D_E_L_E_T_ = '' 	"+cQLinha
	cQuery += "WHERE SC6.D_E_L_E_T_ = '' 					"+cQLinha
	cQuery += "AND C6_FILIAL 	= '"+xFilial("SC6")+"'		"+cQLinha
	cQuery += "AND B6_CLIFOR 	= C6_CLI					"+cQLinha
	cQuery += "AND B6_LOJA		= C6_LOJA					"+cQLinha
	cQuery += "AND B6_IDENT		= C6_IDENTB6				"+cQLinha
	cQuery += "AND C5_LIBEROK != 'E'							"+cQLinha
	cQuery += "AND C5_BLQ = ' '								"+cQLinha
	cQuery += "AND C6_NUM		!= '"+M->C5_NUM+"'			"+cQLinha
	cQuery += "AND B6_PRODUTO 	= C6_PRODUTO) QTD_PED		"+cQLinha

	cQuery += "FROM "+RetSqlName("SB6")+" SB6 																	"+cQLinha
	cQuery += "			INNER JOIN "+RetSqlName("SD1")+" SD1 ON D1_FILIAL = '"+xFilial("SD1")+"' AND  D1_FORNECE = B6_CLIFOR AND D1_LOJA = B6_LOJA AND D1_DOC = B6_DOC AND D1_SERIE = B6_SERIE AND SD1.D1_NUMSEQ = SB6.B6_IDENT AND SD1.D_E_L_E_T_ = '' "+cQLinha
	cQuery += "			INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"' AND  D1_TES = F4_CODIGO AND SF4.D_E_L_E_T_ = '' "+cQLinha
	cQuery += "WHERE  SB6.D_E_L_E_T_ = '' 									"+cQLinha
	cQuery += "AND B6_FILIAL 	= '"+xFilial("SD1")+"'						"+cQLinha
	cQuery += "AND B6_CLIFOR 	= '"+cCliente+"'							"+cQLinha
	cQuery += "AND B6_LOJA 		= '"+cLoja+"'								"+cQLinha
	cQuery += "AND B6_PODER3 	= 'R'										"+cQLinha
	cQuery += "AND B6_ATEND NOT IN ('S')									"+cQLinha // TESTE 10.10.17
	cQuery += "AND B6_PRODUTO 	= '"+cProduto+"'							"+cQLinha
	cQuery += "AND B6_SALDO 	> 0											"+cQLinha
	cQuery += "ORDER BY B6_EMISSAO ASC										"+cQLinha

	//CONout("->" + cQuery)

	TCQUERY cQuery ALIAS TMSB6 NEW
	dbSelectArea("TMSB6")
	dbGoTop()

	If TMSB6->(EOF())
		//LGS#20200131 - Adequação de release 12.1.25 e posteriores
		//ConOut("A Query nao retornou dados - fonte INCTA.prw")
     	FwLogMSG( "INFO", , 'SIGAFAT', funname(), '', '01', "A Query nao retornou dados - fonte INCTA.prw", 0 )
	Endif

	While !TMSB6->(EOF()) .AND.  nSaldo > 0.0


	//CONout(" - saldo >0 " )
		nsubQtdPed 	:= subQtdPed (TMSB6->B6_DOC ,  TMSB6->B6_SERIE, TMSB6->D1_ITEM, TMSB6->B6_IDENT, cProduto, aCols)

		n2subQtdPed := 0.0

		//CONout("1->" + str(nsubQtdPed))

		If ! Empty( aItensSB6 )
			n2subQtdPed := subQtdAcol (TMSB6->B6_DOC ,  TMSB6->B6_SERIE, TMSB6->D1_ITEM, TMSB6->B6_IDENT, cProduto, aItensSB6)
		Endif

		//CONout("2-> " + str( TMSB6->B6_SALDO) + ' - ' + str(nsubQtdPed) +' - '+ str(TMSB6->QTD_PED) +' - ' + str(n2subQtdPed) )

		saldoAtual := TMSB6->B6_SALDO + nsubQtdPed - TMSB6->QTD_PED + n2subQtdPed

		//CONout("3->" + str(saldoAtual))

		If saldoAtual <= 0.0
			TMSB6->(dbSkip())
			loop
		Endif

		If nSaldo <= saldoAtual //TMSB6->B6_SALDO
			nQtd := nSaldo
			nSaldo :=  0.0
		Else
			nQtd 	:=  saldoAtual // TMSB6->B6_SALDO
			nSaldo  -=  saldoAtual // B6_SALDO

		Endif

		//CONout("4->" + str(nSaldo))

		 //quando a quantidade do item for a mesma quantidade da nota, o total do pedido deve ser o mesmo total da nota
		 //caso contrario, ocorre o erro  A410TOTAL
		 nTotal := 0
		 If TMSB6->D1_QUANT == nQtd
		  	nTotal := TMSB6->TOTALD1
		 Endif

		//CONout(" vai add" )
		aadd(_aItens,{TMSB6->B6_DOC ,  TMSB6->B6_SERIE, TMSB6->B6_PRUNIT, TMSB6->D1_ITEM, nQtd, TMSB6->D1_TIPO, TMSB6->D1_TES, TMSB6->B6_IDENT, TMSB6->OPERACAO, nTotal})
	//					 1				 2			         3					4	           5  	     6			7            		8				9			10
		TMSB6->(dbSkip())
	EndDo

	IF nSaldo > 0
			MsgAlert("Não foi localizado saldo de terceiros suficiente para o produto: " + cProduto +". Deveria ter " + Str(nQuant) + " em saldo de terceiros" , "TECPOLPA - INCTA.PRW")
			Return Nil
	Endif

Return _aItens


/*
	Verifica a quantidade no Pedido Atual
*/
Static function subQtdPed (cNfOri, cSerOri, cItemOri, cIdentSB6, cProduto, _aCols)

	Local nQuant := 0
	Local nCntFor

	Local posC6PRODUTO 	:= GdFieldPos("C6_PRODUTO",	aHeader)
	Local posC6QTDVEN 	:= GdFieldPos("C6_QTDVEN",	aHeader)
	Local posC6NFORI	:= GdFieldPos("C6_NFORI",	aHeader)
	Local posC6SERIORI	:= GdFieldPos("C6_SERIORI",	aHeader)
	Local posC6ITORI	:= GdFieldPos("C6_ITEMORI",	aHeader)
	Local posC6IDENTB6	:= GdFieldPos("C6_IDENTB6",	aHeader)


	Local nUsado := Len(aHeader)

	Local aColsBusca := {}

	If Empty(_aCols)
		Return 0
	Else
		aColsBusca :=aclone(_aCols)
	Endif


	For nCntFor := 1  To Len(aColsBusca)
		If ( !aColsBusca[nCntFor][nUsado+1] .and. n <> nCntFor)
			If ( 	aColsBusca[nCntFor][posC6PRODUTO] 	== cProduto .And.;
					aColsBusca[nCntFor][posC6NFORI] 	== cNfOri .And.;
					aColsBusca[nCntFor][posC6SERIORI]	== cSerOri .And.;
					aColsBusca[nCntFor][posC6ITORI]	    == cItemOri .And.;
					aColsBusca[nCntFor][posC6IDENTB6]	== cIdentSB6 )

				nQuant -= aColsBusca[nCntFor][posC6QTDVEN]

			EndIf
		EndIf
	Next nCntFor


Return nQuant



/*
	Verifica a quantidade no Pedido Atual se a op for usada totalmente no pedido
*/
Static function sub2QtdPed (cOP, cProduto, _aCols)

	Local nQuant := 0
	Local nCntFor

	Local posC6PRODUTO 	:= GdFieldPos("C6_PRODUTO",	aHeader)
	Local posC6QTDVEN 	:= GdFieldPos("C6_QTDVEN",	aHeader)
	Local posC6XNUMOP	:= GdFieldPos("C6_XNUMOP",	aHeader)


	Local nUsado := Len(aHeader)

	Local aColsBusca := {}

	If Empty(_aCols)
		Return 0
	Else
		aColsBusca :=aclone(_aCols)
	Endif


	For nCntFor := 1  To Len(aColsBusca)
		If ( !aColsBusca[nCntFor][nUsado+1] .and. n <> nCntFor)
			If ( 	aColsBusca[nCntFor][posC6PRODUTO] 	== cProduto .And.;
					aColsBusca[nCntFor][posC6XNUMOP] 	== cOP  )

			  	nQuant -= aColsBusca[nCntFor][posC6QTDVEN]

			EndIf
		EndIf
	Next nCntFor


Return nQuant



/*
	Verifica a quantidade no acols temporario
*/
Static function subQtdAcol (cNfOri, cSerOri, cItemOri, cIdentSB6, cProduto, _aCols)

	Local nQuant := 0
	Local nCntFor

	Local posC6PRODUTO 	:= 3 // GdFieldPos("C6_PRODUTO",	aHeader)
	Local posC6QTDVEN 	:= 6 // GdFieldPos("C6_QTDVEN",	aHeader)
	Local posC6NFORI	:= 8 // GdFieldPos("C6_NFORI",	aHeader)
	Local posC6SERIORI	:= 9 // GdFieldPos("C6_SERIORI",	aHeader)
	Local posC6ITORI	:= 10 //GdFieldPos("C6_ITEMORI",	aHeader)
	Local posC6IDENTB6	:= 13 // GdFieldPos("C6_IDENTB6",	aHeader)

	//1= op 2=item 	3=cod pro 4= desc  5=UM	 6= Qtd  7=preco  8= doc orig 9= serie orig  10 = item orig 11= operac 12= loc pad 13 IDENT	14 TIPO




	Local aColsBusca := {}

	If Empty(_aCols)
		Return 0
	Else
		aColsBusca :=aclone(_aCols)
	Endif

	For nCntFor := 1  To Len(aColsBusca)

			If ( 	aColsBusca[nCntFor][posC6PRODUTO] 	== cProduto .And.;
					aColsBusca[nCntFor][posC6NFORI] 	== cNfOri .And.;
					aColsBusca[nCntFor][posC6SERIORI]	== cSerOri .And.;
					aColsBusca[nCntFor][posC6ITORI]   	== cItemOri .And.;
					aColsBusca[nCntFor][posC6IDENTB6]	== cIdentSB6 )

				nQuant -= aColsBusca[nCntFor][posC6QTDVEN]


			EndIf

	Next nCntFor


Return nQuant



Static function Query01(cProduto, cLote, cPedido)

	Private cQLinha   := Chr(13) + Chr(10)

	If Select("TMREST")<>0
		dbselectarea("TMREST")
		dbclosearea()
	Endif

	cQuery := "SELECT SUM(D3_QUANT) - ISNULL(SUM(C9_QTDLIB), 0)-  ISNULL(SUM(QTD_FAT),0)	RESTANTE 	"+cQLinha
	cQuery += "																							"+cQLinha
	cQuery += "FROM 																					"+cQLinha
	cQuery += "(																						"+cQLinha
	cQuery += "																							"+cQLinha
	cQuery += "SELECT 																					"+cQLinha
	cQuery += "			0			D3_QUANT, 															"+cQLinha
	cQuery += "			ISNULL(SC9.C9_QTDLIB, SC6.C6_QTDVEN-SC6.C6_QTDENT) C9_QTDLIB,					"+cQLinha
	cQuery += "		0 QTD_FAT																			"+cQLinha
	cQuery += " FROM "+RetSqlName("SC6")+" SC6 															"+cQLinha
	cQuery += "			INNER JOIN "+RetSqlName("SF4")+" SF4  ON F4_FILIAL = '"+xFilial("SF4")+"' AND SC6.C6_TES = SF4.F4_CODIGO AND SF4.D_E_L_E_T_ = ' '   "+cQLinha
	cQuery += "			INNER JOIN "+RetSqlName("SB1")+" SB1  ON B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_COD = SC6.C6_PRODUTO AND SB1.D_E_L_E_T_ = ' '	"+cQLinha
	cQuery += "			LEFT JOIN																		"+cQLinha
	cQuery += "			(SELECT	SUM(C9_QTDLIB) C9_QTDLIB, C9_PEDIDO, C9_ITEM							"+cQLinha
	cQuery += "			FROM	"+RetSqlName("SC9")+" SC9  												"+cQLinha
	cQuery += "			WHERE   SC9.D_E_L_E_T_ = ' ' 													"+cQLinha
	cQuery += "				AND C9_FILIAL = '"+xFilial("SC9")+"'			   							"+cQLinha
	cQuery += "				AND C9_BLCRED = '' 															"+cQLinha
	cQuery += "				AND C9_BLEST = ''															"+cQLinha
	cQuery += "				AND C9_PRODUTO =  '"+cProduto+"' 											"+cQLinha
	cQuery += "			    AND C9_LOTECTL = '"+cLote+"' 												"+cQLinha
	cQuery += "			GROUP BY  C9_PEDIDO, C9_ITEM													"+cQLinha
	cQuery += "				) SC9 ON  SC6.C6_NUM = C9_PEDIDO AND C6_ITEM = C9_ITEM 			 			"+cQLinha
	cQuery += "WHERE SC6.D_E_L_E_T_ = ' '  																"+cQLinha
	cQuery += "		AND C6_FILIAL = '"+xFilial("SC6")+"'												"+cQLinha
	cQuery += "		AND B1_TIPO = 'TA'																	"+cQLinha
	cQuery += "		AND SC6.C6_BLQ <> 'R'																"+cQLinha
	cQuery += "		AND SC6.C6_QTDENT < SC6.C6_QTDVEN													"+cQLinha
	cQuery += "		--AND SC5.C5_TIPO		= 'N' 														"+cQLinha
	cQuery += "		AND SC6.C6_NUM		!= '"+cPedido+"'												"+cQLinha
	cQuery += "		AND SF4.F4_ESTOQUE	= 'S'															"+cQLinha
	cQuery += "		AND ( (C9_QTDLIB IS NULL AND  C6_LOTECTL = '"+cLote+"') OR (C9_QTDLIB IS NOT NULL) ) 	"+cQLinha
	cQuery += "		AND C6_PRODUTO = '"+cProduto+"' 													"+cQLinha
	cQuery += "																							"+cQLinha
	cQuery += "UNION ALL 																				"+cQLinha
	cQuery += "																							"+cQLinha
	cQuery += "SELECT	D3_QUANT, 																		"+cQLinha
	cQuery += "		0 C9_QTDLIB,																		"+cQLinha
	cQuery += "		0 QTD_FAT																			"+cQLinha
	cQuery += "FROM "+RetSqlName("SD3")+" SD3															"+cQLinha
	cQuery += "		INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = D3_COD AND SB1.D_E_L_E_T_ = '' "+cQLinha
	cQuery += "WHERE SD3.D_E_L_E_T_ = ''																"+cQLinha
	cQuery += "AND D3_FILIAL = '"+xFilial("SD3")+"'														"+cQLinha
	cQuery += "AND B1_TIPO IN ('TA')												  					"+cQLinha
	cQuery += "AND D3_OP <> ''																			"+cQLinha
	cQuery += "AND D3_ESTORNO <> 'S'												   					"+cQLinha
	cQuery += "AND D3_COD = '"+cProduto+"'												   				"+cQLinha
	cQuery += "AND D3_LOTECTL = '"+cLote+"'												   				"+cQLinha
	cQuery += "																							"+cQLinha
	cQuery += "UNION ALL 																				"+cQLinha
	cQuery += "																							"+cQLinha
	cQuery += "SELECT  0 D3_QUANT, 																		"+cQLinha
	cQuery += "		0 C9_QTDLIB,																		"+cQLinha
	cQuery += "		D2_QUANT - D2_QTDEDEV QTD_FAT														"+cQLinha
	cQuery += "FROM "+RetSqlName("SD2")+" SD2															"+cQLinha
	cQuery += "		INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = D2_COD AND SB1.D_E_L_E_T_ = '' "+cQLinha
	cQuery += "		INNER JOIN "+RetSqlName("SF4")+" SF4  ON F4_FILIAL = '"+xFilial("SF4")+"' AND D2_TES = SF4.F4_CODIGO AND SF4.D_E_L_E_T_ = '' "+cQLinha
	cQuery += "WHERE SD2.D_E_L_E_T_ = ''																"+cQLinha
	cQuery += "AND D2_FILIAL =	'"+xFilial("SD2")+"' 									   				"+cQLinha
	cQuery += "AND B1_TIPO IN ('TA')																	"+cQLinha
	cQuery += "AND SF4.F4_ESTOQUE	= 'S'														 		"+cQLinha
	cQuery += "AND D2_ESTOQUE = 'S'																 		"+cQLinha
	cQuery += "AND D2_COD = '"+cProduto+"'													   			"+cQLinha
	cQuery += "AND D2_LOTECTL = '"+cLote+"'												   				"+cQLinha
	cQuery += ") A 																						"+cQLinha

	//AVISO("VALOR 1", cQuery, { "Botao1", "Botao2" }, 1)

	TCQUERY cQuery ALIAS TMREST NEW
	dbSelectArea("TMREST")
	dbGoTop()

	If TMREST->(EOF())
		//LGS#20200131 - Adequação de release 12.1.25 e posteriores
		//ConOut("A Query 01 nao retornou dados - fonte INCTA4.prw")
     	FwLogMSG( "INFO", , 'SIGAFAT', funname(), '', '01', "A Query nao retornou dados - fonte INCTA.prw", 0 )
	Endif

    nRet := 0
	If !TMREST->(EOF())
		nRet := TMREST->RESTANTE
	Endif

Return	nRet



/*
	Verifica a quantidade do TA no acols temporario
*/
Static function qtdTAPed (cLote, cProduto, _aCols)

	Local nQuant := 0
	Local nCntFor

	Local posC6PRODUTO 	:= GdFieldPos("C6_PRODUTO",	aHeader)
	Local posC6QTDVEN 	:= GdFieldPos("C6_QTDVEN",	aHeader)
	Local posC6LOTECTL	:= GdFieldPos("C6_LOTECTL",	aHeader)



	Local nUsado := Len(aHeader)

	Local aColsBusca := {}

	If Empty(_aCols)
		Return 0
	Else
		aColsBusca :=aclone(_aCols)
	Endif


	For nCntFor := 1  To Len(aColsBusca)
		If ( !aColsBusca[nCntFor][nUsado+1] ) //.and. n <> nCntFor)
			If ( 	aColsBusca[nCntFor][posC6PRODUTO] 	== cProduto .And.;
					aColsBusca[nCntFor][posC6LOTECTL] 	== cLote )

				nQuant += aColsBusca[nCntFor][posC6QTDVEN]

			EndIf
		EndIf
	Next nCntFor


Return nQuant
