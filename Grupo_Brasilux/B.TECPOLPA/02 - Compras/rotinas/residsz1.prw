#include "protheus.ch"
#include "TOPCONN.CH"
#include "rwmake.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ResidSz1  ºAutor  ³Dyego Figueiredo/Chaus ºData³ 01/05/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ * Funcao chamada no menu do compras.           		      º±±
±±ºObjetivo  ³ * Encerrar os Pedidos de compra  com residuos.       	  º±±
±±º          ³ *								   	 				 	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

                  

User Function ResidSz1()
    
	LOCAL nOpca := 0
	Local aSays:={}, aButtons := {}
	Local lRet := .T.

	Private cCadastro := OemToAnsi("Elim. de residuos dos Pedidos de Compras Terceiros")

	//AjustaSX1()
	pergunte("RESISZ1",.F.)

	// mv_par01 - Percentual maximo                        
	// mv_par02 - Data de Emissao de:                      
	// mv_par03 - Data de Emissao ate:                     
	// mv_par04 - Pedido de  :                             
	// mv_par05 - Pedido ate :                             
	// mv_par06 - Produto de :                             
	// mv_par07 - Produto ate:                             
	// mv_par08 - Elimina residuo por: 1-Pedido 2-Aut.Entr.
	//                      3-Pedido e Autor. 4-Solicitacao
	// mv_par09 - Fornecedor de   :                        
	// mv_par10 - Fornecedor ate  :                        
	// mv_par11 - Data Entrega de :                        
	// mv_par12 - Data Entrega ate:                        
	// mv_par13 - Elimina SC com OP? 1-Sim  2-Nao          


	AADD(aSays,OemToAnsi("Este programa tem como objetivo fechar os Pedidos de Compra de Terceiros,  "))
	AADD(aSays,OemToAnsi("com resíduos baixados, baseado na porcentagem digitada nos Parâmetros. "))
	AADD(aSays,OemToAnsi(""))

	AADD(aButtons, { 5,.T.,{|| Pergunte("RESISZ1",.t.) } } )
	AADD(aButtons, { 1,.T.,{|o| nOpca:= 1, o:oWnd:End() } } )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( cCadastro, aSays, aButtons,,200,445 )

	If nOpca == 1 .And. mv_par01 > 0
	
	
		If lRet
			Do Case
			Case mv_par08 < 4  // 1=pedido  2=Aut.Entrega  3=Pedido e Autorizacao
				Processa({|lEnd| MA235PC(mv_par01,mv_par08,mv_par02,mv_par03,mv_par04,mv_par05,mv_par06,mv_par07,mv_par09,mv_par10,mv_par11,mv_par12,mv_par13,mv_par14)})
		
			EndCase
		EndIf
	EndIf
Return

/*/
	
±±Descriacao  Fechar os Pedidos de Compras com residuos.                 ±±
±±ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±Parametros nPar1 : Percentual de residuo a ser eliminado              ±±
±±           cTipo2: 1-Pedido, 2-Autor.Entrega, 3-Ambos                 ±±
±±           dPar3 : Filtrar da Data de Emissao de                      ±±
±±           dPar4 : Filtrar da Data de Emissao Ate                     ±±
±±           cPar5 : Filtrar da Solicitacao de                          ±±
±±           cPar6 : Filtrar da Solicitacao Ate                         ±±
±±           cPar7 : Filtrar Produto de                                 ±±
±±           cPar8 : Filtrar Produto Ate                                ±±
±±           cPar9 : Filtrar Fornecedor de                              ±±
±±           cPar10: Filtrar Fornecedor Ate                             ±±
±±           dPar11: Filtrar Data Entrega de                            ±±
±±           dPar12: Filtrar Data Entrega de                            ±±
±±           cPar13: Filtrar Item de                                    ±±
±±           cPar14: Filtrar Item Ate                                   ±±
±±           lPar15: Filtra pedido de origem do EIC                     ±±
±±ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±± Uso       Generico                                                   ±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
STATIC Function MA235PC(nPerc, cTipo, dEmisDe, dEmisAte, cCodigoDe, cCodigoAte, cProdDe, cProdAte, cFornDe, cFornAte, dDatprfde, dDatPrfAte, cItemDe, cItemAte, lConsEIC)

	//Local aRefImp   := {}
	Local nRes      := 0
	//Local nPosRef1  := 0
	//Local nPosRef2  := 0
	Local lProcessa := .T.
	Local cAlias    := "SZ1"
	Local cQuery    := ""
	Local nNaoProc  := 0
	//Local lRet      := .T.

	Local   nQtdRes:= 0
	
	Local aNumPed	:= {}

	DEFAULT cItemDe := Space(4)
	DEFAULT cItemAte:= "ZZZZ"
	DEFAULT lConsEIC:= .T.


	ProcRegua(SZ1->(RecCount())*5)
	#IFDEF TOP
		cQuery := "SELECT Z1_FILIAL, Z1_NUM,   Z1_EMISSAO, Z1_RESIDUO, Z1_DATPRF, Z1_PRODUTO, Z1_FORNECE,"
		cQuery += "       Z1_LOJA,   Z1_QUANT, Z1_QUJE,    Z1_TIPO,    Z1_APROV,  Z1_MOEDA,   Z1_TXMOEDA, Z1_ORIGEM, "
		cQuery += "       R_E_C_N_O_ SZ1RECNO
		cQuery += "  FROM " + RetSqlName("SZ1") + " SZ1 "
		cQuery += " WHERE Z1_EMISSAO  >= '"+Dtos(dEmisDe)+"' AND Z1_EMISSAO <= '"+Dtos(dEmisAte)+"' "
		cQuery += "   AND Z1_NUM      >= '"+cCodigoDe+"' AND Z1_NUM     <= '"+cCodigoAte+"' "
		cQuery += "   AND Z1_ITEM     >= '"+cItemDe+"'   AND Z1_ITEM    <= '"+cItemAte+"' "
		cQuery += "   AND Z1_PRODUTO  >= '"+cProdDe+"'   AND Z1_PRODUTO <= '"+ cProdAte + "' "
		cQuery += "   AND Z1_FORNECE  >= '"+cFornDe+"'   AND Z1_FORNECE <= '"+cFornAte+"' "
	
		If !Empty(dDatPrfDe) .And. !Empty(dDatPrfAte)
			cQuery += " AND Z1_DATPRF >= '"+Dtos(dDatPrfDe)+"' AND Z1_DATPRF<='"+Dtos(dDatPrfAte)+"' "
		Endif
	
		cQuery += " AND Z1_FILIAL ='" + xFilial("SZ1") + "' "
	    //cQuery += If(cTipo==1," AND Z1_TIPO = 1 ",If(cTipo==2," AND Z1_TIPO = 2 ",""))
		cQuery += " AND Z1_RESIDUO = ' ' "
	
		If lConsEIC
			cQuery += " AND Z1_ORIGEM <> 'EICPO400' "
		Endif
	
		cQuery += " AND SZ1.D_E_L_E_T_<>'*'"
		cAlias := CriaTrab(,.F.)
		cQuery := ChangeQuery(cQuery)
	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	#ELSE
		dbSelectArea("SZ1")
		dbSetOrder(1)
		dbSeek(xFilial("SZ1")+cCodigoDe,.t.)
	#ENDIF
//PcoIniLan('000056')

	While !Eof() .And. Z1_FILIAL == xFilial("SZ1") .And. Z1_NUM <= cCodigoAte
		IncProc()

		#IFNDEF TOP
		//ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//Monta condicao de filtragem
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			If (Z1_EMISSAO < dEmisDe .Or. Z1_EMISSAO > dEmisAte .Or. !Empty(Z1_RESIDUO) .Or.;
					Z1_PRODUTO > cProdAte .Or. Z1_PRODUTO < cProdDe .Or. ;
					Z1_ITEM    > cItemAte .Or. Z1_ITEM < cItemDe .Or. ;
					Z1_FORNECE > cFornAte .Or. Z1_FORNECE < cFornDe) .Or.;
					(!Empty(dDatPrfAte) .And. !Empty(dDatPrfDe).And.;
					(Z1_DATPRF<dDatPrfDe .Or. Z1_DATPRF>dDatPrfAte)) .Or.;
					( IIF(lConsEIC,Alltrim(Z1_ORIGEM) == "EICPO400",.F.) ) //.Or.;
			// (cTipo==1 .And. Z1_TIPO == 2) .Or. (cTipo == 2 .And. Z1_TIPO == 1)
					lProcessa := .F.
			EndIf
		#ELSE
			dbSelectArea("SZ1")
			SZ1->(MsGoto((cAlias)->SZ1RECNO))
			lProcessa := .T.
	
			
		#ENDIF

		If lProcessa
			If !Empty(cQuery)
				dbSelectArea("SZ1")
				dbGoto((cAlias)->(SZ1RECNO))
			EndIf
		
			Aadd(aNumPed,{xFilial("SZ1"),SZ1->Z1_NUM,'PC'})

		//ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		// Calcular o Residuo maximo da Compra.                         
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			nRes := (Z1_QUANT * nPerc)/100
		//ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		// Verifica se o Pedido deve ser Encerrado.                     
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ    
			If (Z1_QUANT - Z1_QUJE <= nRes .And. Z1_QUANT > Z1_QUJE)
			//-- Chama funcao que processa a eliminacao de residuos, acumulados e vinculados
			//Ma235ElRes(@nNaoProc,aRefImp)
			
				Begin Transaction
					If !Empty(cQuery)
						dbSelectArea("SZ1")
						dbGoTo((cAlias)->(SZ1RECNO))
					EndIf
					nTotItem := SZ1->Z1_PRECO * (SZ1->Z1_QUANT - SZ1->Z1_QUJE)
					SCR->(dbSeek(xFilial("SCR")+"PC"+SZ1->Z1_NUM,.T.))

					If SimpleLock("SZ1") .And. IIF(xFilial("SCR")+"PC"+SZ1->Z1_NUM == SCR->CR_FILIAL+SCR->CR_TIPO+Subs(SCR->CR_NUM,1,Len(SZ1->Z1_NUM)),SimpleLock("SCR"),.T.)

						RecLock("SZ1",.F.)
						Replace Z1_RESIDUO with "S"
						Replace Z1_ENCER with "E"

						nQtdRes++
						MsUnlock()
		          
					Else
						nNaoProc ++
					EndIf
				End Transaction
			Endif
	
		EndIf
		dbSelectArea(cAlias)
		dbSkip()
	
	Enddo

		
	If nNaoProc > 0  //" itens nao foram processados por estar em uso em outra estacao!"
		alert(" itens nao foram processados por estar em uso em outra estacao!")
	EndIf


	If !Empty(cQuery)
		dbSelectArea(cAlias)
		dbCloseArea()
	EndIf


	If nQtdRes > 0
		MSGBOX("Os resíduos foram eliminados com sucesso!")
	Endif

	dbSelectArea("SZ1")
Return








    