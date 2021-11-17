#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TOTVS.CH"


//Dyego Figueredo
//Rotina para incluir um item do Pallet no pedido de venda

User Function INCPALLET()

	Local posC6ITEM 	:= GdFieldPos("C6_ITEM",	aHeader)
	Local posC6PRODUTO 	:= GdFieldPos("C6_PRODUTO",	aHeader)
	//Local posC6LOCAL 	:= GdFieldPos("C6_LOCAL",	aHeader)
	//Local posC6UM 		:= GdFieldPos("C6_UM",		aHeader)
	//Local posC6QTDLIB 	:= GdFieldPos("C6_QTDLIB",	aHeader)
	Local posC6QTDVEN 	:= GdFieldPos("C6_QTDVEN",	aHeader)
	//Local posC6PRCVEN 	:= GdFieldPos("C6_PRCVEN",	aHeader)
	//Local posC6VALOR 	:= GdFieldPos("C6_VALOR",	aHeader)
	//Local posC6OPER 	:= GdFieldPos("C6_OPER",	aHeader)
	//Local posC6TES 		:= GdFieldPos("C6_TES",		aHeader)
	//Local posC6CF 		:= GdFieldPos("C6_CF",		aHeader)
	//Local posC6CLAFIS   := GdFieldPos("C6_CLASFIS", aHeader)
	//Local posC6DESCRI 	:= GdFieldPos("C6_DESCRI",	aHeader)
	//Local posC6LOTECTL	:= GdFieldPos("C6_LOTECTL",	aHeader)
	//Local posC6NUMOP	:= GdFieldPos("C6_XNUMOP",	aHeader)
	
	//Local posC6RECWT	:= GdFieldPos("C6_REC_WT",	aHeader)
	
	
	
	//Local nX, nI
	Local i
	
	Private cCodPale, cOperac, cLocal, maxItem
	
	Private estFil := ""
	Private estCli := ""
	
	Private	_cLote:= " "
	Private _aArea := getArea()
	Private _cCodProd := " "
	Private _cLocal:=""
	Private _nQuant:=0
	Private _aItens:={}, _aAux:={}
	
	cCodPale 	:= GETMV("MV_XCODPLT") 	// "1AAACFPPFE13  "
	cOperac 	:= "SM"
  
  //GETMV("MV_XAROPLT") //  Armazem padrao de origem dos Pallets
	cLocal := GETMV("MV_XARDPLT") //  Armazem padrao de destino dos Pallets E1PA
  
  
	Dbselectarea("SA1")
	SA1->(dbSetorder(1))
	If !SA1->(dbSeek(xFilial("SA1")+ M->C5_CLIENTE +  M->C5_LOJACLI))
		MsgAlert("Cliente ao localizar o cliente, código: " + M->C5_CLIENTE, "INCPALLET.PRW")
		Return
	Else
		cOperac := SA1->A1_XOPPALL
		estCli := SA1->A1_EST
		
		If cOperac == "ST" .AND. ! EMPTY(SA1->A1_XCODPAL)
			cCodPale := SA1->A1_XCODPAL
		Endif
	Endif
	
	estFil :=  GETMV("MV_ESTADO")
	
	
	//cOperac se nao tiver sido preenchdi?

	maxItem	:= 0
	nQtdPallet := 0
	
 	//Varre os itens do Pedido de Vendas
	For i := 1 to Len(aCols)
 
		maxItem	:= Val(aCols[i, posC6ITEM])
 		
		If  aCols[i][len(aHeader)+1] .or. aCols[i, posC6PRODUTO] == cCodPale
			loop
		Endif
 		
		_cCodProd	:=  aCols[i, posC6PRODUTO]
		_nQuant		:=  aCols[i, posC6QTDVEN]
		
		
		If  Posicione("SB1",1,xFilial("SB1")+ Alltrim(aCols[i, posC6PRODUTO]),"B1_TIPO") $ "PA/TA"
		
			Dbselectarea("SB5")
			SB5->(dbSetorder(1))
			If !SB5->(dbSeek(xFilial("SB5")+_cCodProd))
				MsgAlert("O complemento do produto não foi cadastrado, código do produto: " + _cCodProd, "INCPALLET.PRW")
				RestArea(_aArea)
				Return
			Endif
				
			If SB5->B5_EMPMAX*SB5->B5_ECPROFU == 0
				MsgAlert("O complemento do produto foi cadastrado incorretamente, o lastro não pode ser zero, código do produto: " + _cCodProd, "INCPALLET.PRW")
				RestArea(_aArea)
				Return
			Endif
				
				   
			nQtdPallet +=  Ceiling(  aCols[i,posC6QTDVEN] / (SB5->B5_EMPMAX*SB5->B5_ECPROFU) )
				
		Endif
		//Aadd(_aAux, Ceiling(  aCols[i,posC6QTDVEN] / (SB5->B5_EMPMAX*SB5->B5_ECPROFU) )  ) 
  
	Next
	
	
	If nQtdPallet == 0
		RestArea(_aArea)
		Return
	EndIf
	
	
	
	aAuxOrig := aclone(acols)
	
	If cOperac == 'ST'
		aAux := incPalST(cCodPale, nQtdPallet, cOperac, maxItem, aAuxOrig)
	Else
		aAux := incPalet(cCodPale, nQtdPallet, cOperac, maxItem, aAuxOrig)
	Endif
		
	//If nQtdPallet > 0
	//	Aadd(aAuxOrig,aAux)
	//	M->acols := aAuxOrig
	//Endif
	
	nLin := LEN(acols)
	

	SysRefresh()
	GETDREFRESH()

	RestArea(_aArea)

Return Nil


Static Function incPalST(cCodPale, nQtdPallet, cOperac, maxItem, aAux2Orig)

    Local nI
	Local posC6ITEM 	:= GdFieldPos("C6_ITEM",	aHeader)
	Local posC6PRODUTO 	:= GdFieldPos("C6_PRODUTO",	aHeader)
	Local posC6LOCAL 	:= GdFieldPos("C6_LOCAL",	aHeader)
	Local posC6UM 		:= GdFieldPos("C6_UM",		aHeader)
	Local posC6QTDLIB 	:= GdFieldPos("C6_QTDLIB",	aHeader)
	//Local posC6QTDVEN 	:= GdFieldPos("C6_QTDVEN",	aHeader)
	Local posC6PRCVEN 	:= GdFieldPos("C6_PRCVEN",	aHeader)
	Local posC6VALOR 	:= GdFieldPos("C6_VALOR",	aHeader)
	Local posC6OPER 	:= GdFieldPos("C6_OPER",	aHeader)
	Local posC6TES 		:= GdFieldPos("C6_TES",		aHeader)
	Local posC6CF 		:= GdFieldPos("C6_CF",		aHeader)
	//Local posC6CLAFIS   := GdFieldPos("C6_CLASFIS", aHeader)
	Local posC6DESCRI 	:= GdFieldPos("C6_DESCRI",	aHeader)
	//Local posC6LOTECTL	:= GdFieldPos("C6_LOTECTL",	aHeader)
	
	Local posC6QTDVEN 	:= GdFieldPos("C6_QTDVEN",	aHeader)
	Local posC6NFORI	:= GdFieldPos("C6_NFORI",	aHeader)
	Local posC6SERIORI	:= GdFieldPos("C6_SERIORI",	aHeader)
	Local posC6ITORI	:= GdFieldPos("C6_ITEMORI",	aHeader)
	Local posC6IDENTB6	:= GdFieldPos("C6_IDENTB6",	aHeader)
	Local posC6NUMOP	:= GdFieldPos("C6_XNUMOP",	aHeader)
	Local count
	Local posC6RECWT	:= GdFieldPos("C6_REC_WT",	aHeader)
	
	dbSelectArea("SB1")

	
	SB1->(dbSetorder(1))
	If !SB1->(dbSeek(xFilial("SB1")+cCodPale))
		MsgAlert("Produto do Palete não localizado, código: " + cCodPale, "INCPALLET.PRW")
		RestArea(_aArea)
		Return
	Endif
    
    
    // calcula as notas de entrada que possuem paletes
    
    
    
	aSB6 := querySB6(cCodPale, M->C5_CLIENTE, M->C5_LOJACLI, nQtdPallet)
    
	aAux:={}
	aAuxOrig :=aclone(acols) //??
	
	aAux := Array(Len(aHeader)+1)
   
	
	For nI := 1 To Len( aHeader )
		
		If ! (aHeader[nI,2] $ "C6_ALI_WT/C6_REC_WT")
			aAux[nI] := CriaVar(aHeader[nI,2],.T.)
		Else
			aAux[nI] :=	aCols[1][nI]
	
		Endif
	
	Next nI
	
	aAuxLimpo := aclone(aAux)
	
	
	_nPreco:=  0 //CalPreco(M->C5_TABELA,  SB1->B1_COD)
	
	count := 0
	
	somaPalet := 0
	
	
	For count := 1 to len(aSB6)
	
		maxItem := maxItem + 1
	
		aAux[posC6ITEM] 	:= Strzero(maxItem, 2) //Strzero(Len(acols)+1,2) 	//Item
		aAux[posC6PRODUTO] 	:= SB1->B1_COD		   		//Produto
		aAux[posC6UM] 		:= SB1->B1_UM              	//Unidade de Medida
		//aAux[posC6QTDVEN] 	:= nQtdPallet				//Quantidade
		//aAux[posC6PRCVEN] 	:= _nPreco					//Preço de venda
		//aAux[posC6VALOR] 	:= nQtdPallet * _nPreco		//Total
		aAux[posC6QTDLIB] 	:= 0                   		//Quantidade Liberada
		aAux[posC6OPER] 	:= cOperac					//Operação
		
		_cTes := getTes(cOperac, M->C5_CLIENTE,  M->C5_LOJACLI, SB1->B1_COD )//TES (Gatilho da TES inteligente
		_cCF := Posicione("SF4",1,xFilial("SF4")+ _cTes,"F4_CF")
		
		If AllTrim(estFil) == AllTrim(estCli)
			_cCF :=  "5" + Substr(_cCF, 2, 3)
		Else
			_cCF :=  "6" + Substr(_cCF, 2, 3)
		Endif
		
		aAux[posC6TES] 		:= _cTes
		//aAux[posC6CLAFIS] 	:= CodSitTri()					//Operação
		aAux[posC6CF] 		:= _cCF
		aAux[posC6LOCAL] 	:= cLocal					//Armazem
		aAux[posC6DESCRI] 	:= SB1->B1_DESC				//Descrição
		aAux[posC6RECWT] 	:= 0						//Recno do acols
		
		
		
		
		//TMSB6->B6_DOC ,  TMSB6->B6_SERIE, TMSB6->B6_PRUNIT, TMSB6->D1_ITEM, nQtd, TMSB6->D1_TIPO, TMSB6->D1_TES, TMSB6->B6_IDENT, TMSB6->OPERACAO, nTotal})
		
		aAux[posC6NFORI] 	:= aSB6[count][1]
		aAux[posC6SERIORI] 	:= aSB6[count][2]
		aAux[posC6ITORI] 	:= aSB6[count][4]
		//aAux[posC6NUMOP] 	:= aSB6[count][1] // ?
		//aAux[posC6ITOP] 	:= aSB6[count][2]//para nao validar
		aAux[posC6IDENTB6] 	:= aSB6[count][8]
		
		aAux[posC6QTDVEN] 	:= aSB6[count][5] //nQtdPallet	
		aAux[posC6PRCVEN] 	:= aSB6[count][3]					//Preço de venda
		aAux[posC6VALOR] 	:= aSB6[count][5] * aSB6[count][3]		//Total
		
		aAux[posC6NUMOP] 	:= "0"
		
		somaPalet += aSB6[count][5]
		
		
		aAux[len(aHeader)+1] 	:= .F.
		
		Aadd(aAuxOrig,aAux)
		//Aadd(M->acols,aAux)
		aAux := aClone(aAuxLimpo)
	
	Next count	
	
	If nQtdPallet > 0
		//Aadd(aAuxOrig,aAux)
		M->acols := aAuxOrig
	Endif 		// aAuxOrig [1][13]
	
	//Alert("1")
	SysRefresh()
	GETDREFRESH()
	//Alert("2")
	
	// Casos tem nao resta mais paletes de clientes
	cCodPale 	:= GETMV("MV_XCODPLT")
	 
	if somaPalet < nQtdPallet
		 incPalet(cCodPale, nQtdPallet - somaPalet  , "SM", maxItem, aAuxOrig )
	Endif
	
Return aAux


Static Function incPalet(cCodPale, nQtdPallet, cOperac, maxItem, aAux2Orig)


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
	//Local posC6CLAFIS   := GdFieldPos("C6_CLASFIS", aHeader)
	Local posC6DESCRI 	:= GdFieldPos("C6_DESCRI",	aHeader)
	//Local posC6LOTECTL	:= GdFieldPos("C6_LOTECTL",	aHeader)
	Local posC6NUMOP	:= GdFieldPos("C6_XNUMOP",	aHeader)
	Local nI
	Local posC6RECWT	:= GdFieldPos("C6_REC_WT",	aHeader)
	
	dbSelectArea("SB1")

	
	SB1->(dbSetorder(1))
	If !SB1->(dbSeek(xFilial("SB1")+cCodPale))
		MsgAlert("Produto do Palete não localizado, código: " + cCodPale, "INCPALLET.PRW")
		RestArea(_aArea)
		Return
	Endif
    
    
    // calcula as notas de entrada que possuem paletes
    
    
    
    //aSB6 := querySB6(cCodPale, M->C5_CLIENTE, M->C5_LOJACLI, nQtdPallet)
    
	aAux:={}
	aAuxOrig :=aclone(acols) //?
	
	aAux := Array(Len(aHeader)+1)
   
	
	For nI := 1 To Len( aHeader )
		
		If ! (aHeader[nI,2] $ "C6_ALI_WT/C6_REC_WT")
			aAux[nI] := CriaVar(aHeader[nI,2],.T.)
		Else
			aAux[nI] :=	aCols[1][nI]
	
		Endif
	
	Next nI
	
	aAuxLimpo := aclone(aAux)
	
	
	_nPreco:=  CalPreco(M->C5_TABELA,  SB1->B1_COD)
	
	aAux[posC6ITEM] 	:= Strzero(maxItem + 1, 2) //Strzero(Len(acols)+1,2) 	//Item
	aAux[posC6PRODUTO] 	:= SB1->B1_COD		   		//Produto
	aAux[posC6UM] 		:= SB1->B1_UM              	//Unidade de Medida
	aAux[posC6QTDVEN] 	:= nQtdPallet				//Quantidade
	aAux[posC6PRCVEN] 	:= _nPreco					//Preço de venda
	aAux[posC6VALOR] 	:= nQtdPallet * _nPreco		//Total
	aAux[posC6QTDLIB] 	:= 0                   		//Quantidade Liberada
	aAux[posC6OPER] 	:= cOperac					//Operação
	
	_cTes := getTes(cOperac, M->C5_CLIENTE,  M->C5_LOJACLI, SB1->B1_COD )//TES (Gatilho da TES inteligente
	_cCF := Posicione("SF4",1,xFilial("SF4")+ _cTes,"F4_CF")
	
	If AllTrim(estFil) == AllTrim(estCli)
		_cCF :=  "5" + Substr(_cCF, 2, 3)
	Else
		_cCF :=  "6" + Substr(_cCF, 2, 3)
	Endif
	
	aAux[posC6TES] 		:= _cTes
	//aAux[posC6CLAFIS] 	:= CodSitTri()					//Operação
	aAux[posC6CF] 		:= _cCF
	aAux[posC6LOCAL] 	:= cLocal					//Armazem
	aAux[posC6DESCRI] 	:= SB1->B1_DESC				//Descrição
	aAux[posC6RECWT] 	:= 0						//Recno do acols
	
	aAux[posC6NUMOP] 	:= "0"
	
	aAux[len(aHeader)+1] 	:= .F.
	
	If nQtdPallet > 0
		Aadd(aAuxOrig,aAux)
		M->acols := aAuxOrig
	Endif
	
Return aAux

Static Function CalPreco(cTabela,  cProduto )

	Local _nPreco :=0
	
	DbSelectArea("DA1")
	DA1->(dbSetOrder(1))	//DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM
	DA1->(dbSeek(xFilial("DA1")+cTabela+cProduto))
	
	IF !(DA1->(EOF()))
		_nPreco:= DA1->DA1_PRCVEN
	Else
		If ! Empty(cTabela)
			MsgAlert("Favor cadastrar o Palete na tabela de preço: " + cTabela, "INCPALLET.PRW")
		Endif
	EndIf

Return _nPreco

Static Function getTes(cOper, cCliente, cLoja,cProd )

	Local cTes:=""
	Local _aArea:=getArea()
	cTes:= MaTesInt(2,cOper,cCliente,cLoja,If(M->C5_TIPO$'DB',"F","C"),cProd,"C6_TES")

	RestArea(_aArea)
Return cTes


// 
Static function querySB6(cProduto, cCliente, cLoja, nQuant)

	Local _aItens := {}
	Local saldoAtual := 0
	Local nSaldo := nQuant

	Private cQLinha   := Chr(13) + Chr(10)

	If Select("TMSB6")<>0
		dbselectarea("TMSB6")
		dbclosearea()
	Endif

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
	cQuery += "AND B6_PRODUTO 	= '"+cProduto+"'							"+cQLinha
	cQuery += "AND B6_SALDO 	> 0	 AND B6_ATEND NOT IN ('S')				"+cQLinha
	cQuery += "ORDER BY B6_EMISSAO ASC										"+cQLinha


	TCQUERY cQuery ALIAS TMSB6 NEW
	dbSelectArea("TMSB6")
	dbGoTop()

	If TMSB6->(EOF())
		//LGS#20200131 - Adequação de release 12.1.25 e posteriores
		//ConOut("A Query nao retornou dados - fonte INCTA.prw")
     	FwLogMSG( "INFO", , 'SIGAFAT', funname(), '', '01', "A Query nao retornou dados - fonte INCPALLET.prw", 0 )

	Endif

	While !TMSB6->(EOF()) .AND.  nSaldo > 0

		saldoAtual := TMSB6->B6_SALDO - TMSB6->QTD_PED

		If saldoAtual <= 0
			TMSB6->(dbSkip())
			loop
		Endif

		If nSaldo <= saldoAtual //TMSB6->B6_SALDO
			nQtd := nSaldo
			nSaldo :=  0
		Else
			nQtd 	:=  saldoAtual // TMSB6->B6_SALDO
			nSaldo  -=  saldoAtual // B6_SALDO

		Endif

		 //quando a quantidade do item for a mesma quantidade da nota, o total do pedido deve ser o mesmo total da nota
		 //caso contrario, ocorre o erro  A410TOTAL
		nTotal := 0
		If TMSB6->D1_QUANT == nQtd
			nTotal := TMSB6->TOTALD1
		Endif

		aadd(_aItens,{TMSB6->B6_DOC ,  TMSB6->B6_SERIE, TMSB6->B6_PRUNIT, TMSB6->D1_ITEM, nQtd, TMSB6->D1_TIPO, TMSB6->D1_TES, TMSB6->B6_IDENT, TMSB6->OPERACAO, nTotal})
	//					 1				 2			         3					4	           5  	     6			7            		8				9			10
		TMSB6->(dbSkip())
	EndDo


Return _aItens
