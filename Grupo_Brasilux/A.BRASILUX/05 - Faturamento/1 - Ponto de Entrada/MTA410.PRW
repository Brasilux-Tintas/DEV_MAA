#include 'rwmake.ch'
#include 'topconn.ch'
#include 'protheus.ch'
#include 'DIRECTRY.CH'
#INCLUDE "AP5MAIL.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³  MTA410  ºAutor  ³ Cleber O. Dominguesº Data ³  12/09/01   º±±F
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º 12/09/01 ³ Ponto de entrada na confirmação da inclusão/alteração do - º±±
±±º          ³ pedido de vendas.                                          º±±
±±º 16/04/04 ³ Se for inclusão e a venda for a vista colocar automatica - º±±
±±º          ³ mente como boleto sim.                                     º±±
±±º 09/11/04 ³ Retirado a pedido do Florivaldo, ajuste no campo boleto -  º±±
±±º          ³ para não gerar caso a condição de pagamento for a prazo.   º±±
±±º 02/01/06 ³ Ajuste linha 80                                          - º±±
±±º 29/09/06 ³ Preenchimento de C5_VEND2 E COMIS 1% P/ GERENTE DE VEND  - º±±
±±º 15/05/09 ³ Nova politica comercial de descontos                     - º±±
±±º 02/07/09 ³ Determinar CST pois nao grava corretamente.              - º±±
±±º 25/09/19 ³ Luís Gustavo - Adequação para release 12.1.25              º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function MTA410()
	//////////////////////////////////////////////////////
	// Calculo da comissao de acordo com o lucro minimo //
	//////////////////////////////////////////////////////
	// aCols[2] : Cod.Produto                           //
	// aCols[5] : qtde na 1a. unidade de medida         //
	// aCols[6] : Preco de venda unitario               //
	// aCols[8] : Preco de venda total                  //
	// aCols[19]: comissao %                            //
	// aCols[9] : TES                                   //
	// aCols[10] : CFOP                                 //
	//////////////////////////////////////////////////////
	Local cArea := Alias()
	Local aVenctos       := {}  //Vetor com prazos de pagamentos
	Local aPrazos        := {}  //Vetor com prazos em dias
	Local aAuxEmba       := {}
	//Local aPedGOP        := {}  //Matriz com Pedidos que irão gerar
	Local aPrecos		  := {}  //Vetor que receberá os precos minimos para um item de produto de acordo com as 6 faixas de desconto definidas
	Local aPrcMin   	  := {0,0,0,0,0,0}  //Vetor com a soma dos preços mínimos a serem praticados de acordo com a politica de venda
	Local cUf            := ""  //Estado do Cliente ou Fornecedor
	Local cInscr         := ""  //Inscrição Estadual do Cliente ou Fornecedor
	Local cComp,lVolJunto,_x
	Local cMensErro      := ""
	Local nPrazoMedio    := 0   //Prazo médio em dias da venda
	Local _nVlrTotPed    := 0   //Valor total do pedido
	Local _nVlrTotDup    := 0   //Valor total que gera FINANCEIRO!
	Local _nVlrTotMin    := 0   //Valor total mínimo para entrar dentro da Política de Vendas!
	Local nSomaVlrTab    := 0   //Valor total do pedido (apenas itens que GERAM FINANCEIRO!) pelo valor de tabela
	Local nPesoBrut      := 0
	Local nQtdeMinEst    := 0   //Quantidade mínima para entrar na tabela 1
	Local nPerInt        := 0   //Soma de percentuais internos na formação de preços, exceto lucro e comissão
	Local nLc1           := 0   //Lucro + Comissão na tabela 1
	Local nLc2           := 0   //Lucro + Comissão na tabela 2
	Local nValTab        := 0   //Valor total de tabela do item
	Local nValUnTab      := 0   //Valor unitário de tabela do item
	Local nVlrProd       := 0   //Valor total do produto do item
	Local nVolTotal      := 0
	Local nPesoLiquTotal := 0
	Local nPesoBrutTotal := 0
	Local _nPercIcms     := 0 //GETMV("MV_ICMPAD")
	Local nValorHoje     := 0
	Local nQtdeParc      := 0
	Local nSaldoVend     := 0 //Saldo de vendas do mês para o cliente
	Local _nLucroItem    := 0
	Local _nValReal      := 0 //Total de LUCRO+COMISSAO
	Local _nMedComiss    := 0 // Comissão de referência ponderada, cadastrada nos produtos
	Local _nMedLucro     := 0 // Lucro mínimo de referência, pré-definido nos produtos
	Local _nVlrCDesc     := 0
	Local _nVlrComiss    := 0
	Local _nVlrLucro     := 0
	Local _nPorcComiss 
	Local nJuros         := GETMV("MV_JUROS")
	Local nTxPIS         := GETMV("MV_TXPIS")
	Local nTxCofin       := GETMV("MV_TXCOFIN")
	Local cEstado        := GETMV("MV_ESTADO")
	Local nICMPAD        := GETMV("MV_ICMPAD")
	//Local lXHABBOR       := GETMV("MV_XHABBOR")
	Local lXHABBOR		 := .F.   
	Local lGeraDup       := .f. //Verifica se gera duplicata ou não
	Local lMisturado 	  := .f. //Informa se há itens de estoque misturados c/ itens Não Estoque!
	Local lMudouEst := .f. // Identifica se mudou item de estoque p/ não estoque ou vice versa para verificar se existe itens misturados
	Local cDeposito      := "" //Auxiliar para determinar se pedido é remessa pra depósito ou não.
	Local cCodCid		  := "" //Código da Cidade do Cliente
	Local lRet           := .t. //Variavel lógica que retorna a validação geral do ponto de entrada, se aceita(.t.) ou nao(.f.)
	Local lProdEstoque   := .f. //Verifica se é produto de estoque
	Local nEntrega		  := 5 //Prazo de entrega em dias a ser contado à partir da data de liberação do pedido
	Local lSisRev        := .f. //Participa de política de venda p/ Comércio/Revenda? Caso positivo, verificar se o pedido atende à regra.
	Local lProblPrazo    := .f. //Bloquear pedido caso prazo médio não seja respeitado, independente de qualquer coisa
	Local lDescOk,cCnpj
	Local lRegB1
	Local lEmbaemG1,nContItens,lAux,_cGrpEmp,_cNumEmp
	Local nPosPRUNIT     := aScan(aHeader, {|x| Trim(x[2]) == "C6_PRUNIT" }) //Posicionamento do campo C6_PRUNIT  no aHeader
	Local nPosDESCONT    := aScan(aHeader, {|x| Trim(x[2]) == "C6_DESCONT"}) //Posicionamento do campo C6_DESCONT no aHeader
	Local nPosVALDESC    := aScan(aHeader, {|x| Trim(x[2]) == "C6_VALDESC"}) //Posicionamento do campo C6_VALDESC no aHeader
	Local nPosPRODUTO    := aScan(aHeader, {|x| Trim(x[2]) == "C6_PRODUTO"}) //Posicionamento do campo C6_PRODUTO no aHeader
	Local nPosQTDVEN     := aScan(aHeader, {|x| Trim(x[2]) == "C6_QTDVEN" }) //Posicionamento do campo C6_QTDVEN no aHeader
	Local nPosTES        := aScan(aHeader, {|x| Trim(x[2]) == "C6_TES"    }) //Posicionamento do campo C6_TES no aHeader
	Local nPosCF         := aScan(aHeader, {|x| Trim(x[2]) == "C6_CF"     }) //Posicionamento do campo C6_CF no aHeader
	Local nPosVALOR      := aScan(aHeader, {|x| Trim(x[2]) == "C6_VALOR"  }) //Posicionamento do campo C6_VALOR no aHeader
	Local nPosPRCVEN     := aScan(aHeader, {|x| Trim(x[2]) == "C6_PRCVEN" }) //Posicionamento do campo C6_PRCVEN no aHeader
	Local nPosVolItem    := aScan(aHeader, {|x| Trim(x[2]) == "C6_VOLITEM"}) //Posicionamento do campo C6_VOLITEM no aHeader
	Local nPosVlrLucr    := aScan(aHeader, {|x| Trim(x[2]) == "C6_VLRLUCR"}) //Posicionamento do campo C6_VLRLUCR no aHeader
	Local nPosLucrEsp    := aScan(aHeader, {|x| Trim(x[2]) == "C6_LUCRESP"}) //Posicionamento do campo C6_LUCRESP no aHeader
	Local nPosCst        := aScan(aHeader, {|x| Trim(x[2]) == "C6_CLASFIS"}) //Posicionamento do campo C6_CLASFIS no aHeader
	Local nPosFCI        := aScan(aHeader, {|x| Trim(x[2]) == "C6_FCICOD"}) //Posicionamento do campo C6_FCICOD no aHeader
	Local nPosC6_LOCAL   := aScan(aHeader, {|x| Trim(x[2]) == "C6_LOCAL"}) //Posicionamento do campo C6_LOCAL no aHeader
	Local nPosENTREG     := aScan(aHeader, {|x| Trim(x[2]) == "C6_ENTREG"}) //Posicionamento do campo C6_ENTREG no aHeader
	Local nPosC6SIM3G    := aScan(aHeader, {|x| Trim(x[2]) == "C6_X_SIM3G"}) //Posicionamento do campo C6_X_SIM3G no aHeader
	//Local nPosC6XVLRFRE  := aScan(aHeader, {|x| Trim(x[2]) == "C6_XVLRFRE"}) //Posicionamento do campo C6_XVLRFRE no aHeader

	Local nQtdComp,cCst,cObs,cCondPag,nDescPerm,nPos1,nPos2
	Local nVar, nAux, cAux, i,nAuxQtde,nAuxLucro,nAuxVol,nQtdeVol,_cFilial
	Local nInd, nIndAnt, cTipoCons,_nComisCal,cTrpBrz
	Local nDesc1, nDesc2, _nPisCof,cPerCal,cPerVen,nMes,nAno,nTolerancia
	//Local nIndA, nIndB, nIndC, nIndD, nIndE, nIndF, nIndG
	Local aStrut := {},cCursorTemp, nTotalTipo9,j,cAuxMens,dDiaFat
	Local aEmba := {}  //Tipos de Embalagens utilizada, Colunas: 1-Cód Emba; 2-Qtde de Embal; 3-Qtde p/ Juntar Vol; 4-Qtde Vol. produtos que não juntam vol; 5-Qtde BL p/ verif. se fecham vol; 6-Rel. Volume
	Local lCalcVol     := .t. // Det. se vai incluir a relação de volume, auxiliar para prevenir probl. de numeração de pedido
	Local lSoSolventes := .t. // determina se o pedido é exclusivo de solventes para poder entrar na política de desconto extra para esse tipo de prod(20/03/2012)
	Local aArea,lVolQuebr,cProdsVolQuebr,nCubagem,nRegB1,lIpiZeroM,nIpiAnt
//	Local cProdEsp     := "" //Enviar e-mail para pessoal de Materias caso haja item específico sendo que existe alternativa de estoque
	Local nVlrTot      := 0,nVlrFrete := 0,nPercFrete := 0 //,lCalcFrete := .t.
	Local lMasterS     := .f. // Enviar pedido para MasterSales
	Local oTempTable,lCampanha,cTabCampanha,nIcmCampanha,cCondCamp
     u_zcfga01( 'MTA410' ) //LGS#2021214 - Gravação de log de utilização da rotina
	_cGrpEmp := alltrim(FWGrpCompany())
	if empty(_cGrpEmp)
		_cGrpEmp := "01"
	endif 
	_cFilial := alltrim(FWCodFil())
	if empty(_cFilial)
		_cFilial := "010101" //Alguns Pedidos MasterSales não identificam filial!!
	endif 
	_cNumEmp := alltrim(_cGrpEmp)+alltrim(_cFilial)


	//(Cleber 23/09/20) -> Caso a origem do pedido for do Gestão de Contratos desconsiderar customizações Brasilux
	IF (SC5->(FieldPos("C5_APROVA")) > 0)
		IF !EMPTY(M->C5_MDCONTR) .OR. !EMPTY(M->C5_MDNUMED) .OR. !EMPTY(M->C5_MDPLANI)
			M->C5_APROVA := "1" //Considerar pedido aprovado(na aprovação customizada) caso venha do módulo Gestão de Contratos
		ENDIF
	Endif

	//Se estiver nas empresas de Gestão Imobiliária não executar
	IF (_cGrpEmp = "01") .and. (SUBSTR(_cFilial,1,2) >= "07")
		return(.t.)
	endif

	//(Cleber 24/07/19) -> Marcador quando estiver em aprovação de pedido frete CIF, não passar pelo ponto de entrada!
	IF (SC5->(FieldPos("C5_USRAPR")) > 0)
	 	if (M->C5_USRAPR = "#*#CIF#*#")
	 		Return(.t.)
	 	endif
	Endif

	//Marcar, em princípio, para não enviar pedido para MasterSales
	IF (SC5->(FieldPos("C5_X_SIM3G")) > 0)
		M->C5_X_SIM3G := "N"
		M->C5_X_EXPO := " "
	ENDIF

	//Marcar, em princípio, comissão variável, pode inclusive participar de compensação de comissão
	
	IF (SC5->(FieldPos("C5_XCONF")) > 0)
		M->C5_XCONF := .F. //Comissão fixa
	ENDIF 
	
	aArea := U_PegaArea({"SB9","CFD","SB1","SB2","SF4","SA1","SE4","SA2","SA3","SB5","SZ5","SZ7","ZZO","SA4","SX5"})

	DbSelectArea("SA1")  //Clientes
	DbSetOrder(1)

	DbSelectArea("SF4")  //Tipos de Entradas e Saídas
	DbSetOrder(1)

	lCampanha := .t. //Chamado 020971, criar política de campanhas. Em princípio considerar verdadeiro que pedido é participante de campanha, validar em seguida

	If (_cGrpEmp = "11")  //Empresas que  são do grupo 11(Tecpolpa).
		lCampanha := .f. //TecPolpa não participa de campanha até o momento
		IF (M->C5_TIPO = "N")
			DbSelectArea("SA1")
			DbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI)
			IF FOUND()
				IF !EMPTY(M->C5_X_PVSIM)
					M->C5_X_SIM3G := "S"
					If INCLUI 
						M->C5_VEND1 := SA1->A1_VEND
						M->C5_EMISSAO := DATE()
						M->C5_FRETE := 0.0
						M->C5_SEGURO := 0.0
						//Cleber(07/01/21) -> Descobri que desde outubro/2020 não está gravando banco
						IF !EMPTY(SA1->A1_BCO1) .AND. EMPTY(M->C5_BANCO)
							M->C5_BANCO := SA1->A1_BCO1
						ENDIF 
					Endif
				ENDIF 
				IF empty(M->C5_VEND1)
					M->C5_VEND1 := SA1->A1_VEND
				ENDIF 
			ENDIF 
		ENDIF 
		For _x := 1 to Len(aCols)
			If !aCols[_x][Len(aHeader)+1] //Se não for registro deletado
				// Zerar Descontos para não aparecer valor maior em Valor Contabil em SF3
				nAux := TamSX3("C6_PRCVEN")[2]
				aCols[_x][nPosPRUNIT]  := aCols[_x][nPosPRCVEN]
				aCols[_x][nPosDESCONT] := 0
				aCols[_x][nPosVALDESC] := 0
				nAux := TamSX3("C6_VALOR")[2]
				IF M->C5_TIPO = "N"
					aCols[_x][nPosValor] := round(aCols[_x][nPosPRCVEN]*aCols[_x][nPosQTDVEN],nAux)
				ENDIF
				//*****************
				// Checar consistências
				DbSelectArea("SF4") //Tipo de Entrada e Saída
				DbSeek(xFilial("SF4")+aCols[_x][nPosTES])
				If !Found()
					lRet := .f.
					cAuxMens := "Não encontrado o TES "+aCols[_x,nPosTES]+" no cadastro. Contacte o Adm. do Sistema!"
					If (ValAtrib("l410Auto") <> "U" .and. l410Auto) //release 12.1.25 if ( Type("l410Auto") <> "U" .And. l410Auto )
						//ConOut(cAuxMens)
						FwLogMSG( "WARN", , 'SIGAFAT', funname(), '', '01', cAuxMens, 0 )
					else
						MsgBox(cAuxMens, "Atenção", "STOP")
					endif
					exit
				endif

				If (SF4->F4_DUPLIC $ 'S ') 
					lGeraDup := .t.
				Endif

				//Enviar pedido p/ MasterSales
				IF (M->C5_X_SIM3G = "S") .AND. lGeraDup
					aCols[_x,nPosC6SIM3G] := "S"
				ELSE
					aCols[_x,nPosC6SIM3G] := "N"
				ENDIF

				//*****************
				//Chamado 024692, compatibilizar a data de entrega do cabeçalho com a data de entrega de SC6
				if !empty(M->C5_FECENT) .AND. (M->C5_FECENT != aCols[_x][nPosENTREG])
					aCols[_x][nPosENTREG] :=  M->C5_FECENT
				endif 
			Endif
		Next
		// Zerar Descontos para não aparecer valor maior em Valor Contabil em SF3
		M->C5_DESC1 := 0
		M->C5_DESC2 := 0
		M->C5_DESC3 := 0
		M->C5_DESC4 := 0
		
		

	Else // if _cGrpEmp = "11"


		cProdsVolQuebr := "" //Solic. Cleiton em 15/10/14, relacionar produtos vendidos com volume quebrado na Dissoltex e enviar por e-mail.
		cObs := alltrim(M->C5_OBS)
		//Itens de IPI Zero Misturados com itens de IPI maior que zero. Chamado 007956
		lIpiZeroM := .f.
		nIpiAnt := 0.0

		nTotalTipo9 := 0 // Valor total dos valores das parcelas tipo 9
		M->C5_NAOCONF := "N"
		//Cleber (26/09/2019) -> Caso não venha preenchido o tipo de frete, preencher com FOB
		IF EMPTY(ALLTRIM(M->C5_TPFRETE))
			M->C5_TPFRETE := "F"
		ENDIF

		DbSelectArea("SZ7")  // Cadastro de Cidades
		DbOrderNickName("SZ7001")

		DbSelectArea("SZ1")  // Qtde de Volumes por Embalagem
		DbOrderNickName("SZ1001")

		DbSelectArea("ZZO")  // Qtde de Volumes por Embalagem
		dbsetorder(1)

		dbselectarea("CFD") // FICHA DE CONTEUDO DE IMPORTAÇÃO
//		dbsetorder(2) //CFD_FILIAL+CFD_COD+CFD_PERCAL+CFD_PERVEN
		dbsetorder(3) //CFD_FILIAL+CFD_FCICOD                                                                                                                                           

		DbSelectArea("SB1")  //Produtos
		DbSetOrder(1)

		DbSelectArea("SB2")  //Saldos em Estoque
		DbSetOrder(1)

		DbSelectArea("SX5")  //Tabelas
		DbSetOrder(1)

		DbSelectArea("DA1")  //Itens da Tabela de Preço  
		DbSetOrder(1) //Cod. Tabela + Cod.Produto + Faixa + Item                                                                                 

		DbSelectArea("DA0")  //Tabela de Preço  
		DbSetOrder(1) //Cod. Tabela                                                                                                             

		//Gravar se pedido possui solvente, marcar primeiro como N para, quando achar algum, marcar como S
		if (len(_cNumEmp) == 8) .and. (_cNumEmp $ "01010101$01060101")
			DbSelectArea("SX5")  //Tabelas
			dbseek(xFilial("SC5")+"96"+M->C5_NUM)
			if found()
				reclock("SX5",.F.)
				SX5->X5_DESCRI := "N"
				SX5->X5_DESCSPA := "N"
				SX5->X5_DESCENG := "N"
				msunlock()
			endif
		else
			lCampanha := .f. // Campanha somente implantar para Brasilux/Matriz e Dissoltex
		endif

		dDiaFat := dDataBase //Considerar dia do Faturamento data de hoje para cálculo do prazo médio
		cCondPag := M->C5_CONDPAG //Guarda o código da cond. de pagamento digitada
		DbSelectArea("SE4")  // Condição de Pagamento
		DbSetOrder(1)
		DbSeek(xFilial("SE4")+cCondPag)
		IF Found() // Cria vetor com prazos de pagamento
			//Cleber(24/07/18) Solicitação Eliana, chamado 010813 -> pedidos com cond. pgto até 7 dias calcular comissão como se fosse à vista
			cCondPag := EhAvista(M->C5_CONDPAG)
			If (SE4->E4_TIPO # "9")
				aVenctos := Condicao(100, cCondPag, 0.00, dDiaFat, 0.00)
			Else
				aVenctos  := {}
				nQtdeParc := 0
				For i := 1 to 4
					cAux := "M->C5_DATA"+Alltrim(Str(i))
					If !Empty(&cAux)
						aAdd(aVenctos, {&cAux, 0})
						cAux  := "M->C5_PARC"+Alltrim(Str(i))
						if &cAux <= 0
							lRet := .f.
							cAuxMens := "Preencha Todos os Valores para os Vencimentos Apontados!"
							If (ValAtrib("l410Auto") <> "U" .and. l410Auto) //if ( Type("l410Auto") <> "U" .And. l410Auto ) release 12.1.25
								//ConOut(cAuxMens)
								/*** Substituido em 08/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
								FwLogMSG( "WARN", , 'SIGAFAT', funname(), '', '01', cAuxMens, 0 )
							else
								MsgBox(cAuxMens, "Atenção", "STOP")
							endif
							exit
						endif
						nTotalTipo9 += &cAux
						aVenctos[i,2] := &cAux
						nQtdeParc++
					else
						cAux  := "M->C5_PARC"+Alltrim(Str(i))
						if &cAux > 0
							lRet := .f.
							cAuxMens := "Preencha Todos os Vencimentos para os Valores Apontados!"
							If (ValAtrib("l410Auto") <> "U" .and. l410Auto)  //if ( Type("l410Auto") <> "U" .And. l410Auto ) release 12.1.25
								//ConOut(cAuxMens)
								/*** Substituido em 08/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
								FwLogMSG( "WARN", , 'SIGAFAT', funname(), '', '01', cAuxMens, 0 )
							else
								MsgBox(cAuxMens, "Atenção", "STOP")
							endif
							exit
						endif
					Endif
				Next
				If nQtdeParc == 0
					nQtdeParc  := 1
					nTotalTipo9 := 1
					M->C5_DATA1 := dDataBase
					aAdd(aVenctos, {dDataBase, 1})
				Endif
				/*
				If AllTrim(SE4->E4_COND) == "%"
				nAux := 0 // Soma dos percentuais ou valores
				For i := 1 to nQtdeParc
				cAux  := "M->C5_PARC"+Alltrim(Str(i))
				&cAux := Round(100 / nQtdeParc, 0)
				nAux += &cAux
				Next
				&cAux := &cAux + 100 - nAux
				Endif */
			Endif
		Else
			nTotalTipo9 := 1
			aVenctos := {}
			aAdd(aVenctos, {dDataBase, 1})
		Endif
		//Chamado 014805, problema com cond. pgto datas fixas vencto, comissionamento muda devido a não se saber dia do faturamento,
		//considerar data do ped programado como ref. para cálculo do prazo médio
		if (nTotalTipo9 > 0) .and. (SC5->(FieldPos("C5_PEDPROG")) > 0)
			IF !empty(M->C5_PEDPROG)
				dDiaFat := M->C5_PEDPROG //Considerar dia do Faturamento data do pedido programado para o caso de datas fixas de vencimento (Chamado 014805)
			ENDIF
		endif

		aPrazos     := {} // Vetor com prazos em dias + % de cada parcela sobre total e cálculo do prazo médio
		nPrazoMedio := 0
		For i := 1 to Len(aVenctos)
			aadd(aPrazos, {aVenctos[i,1] - dDiaFat + 1,iif(nTotalTipo9 > 0,aVenctos[i,2]/nTotalTipo9,1/len(aVenctos))})
			nPrazoMedio += aPrazos[i,1]
		Next
		If Len(aVenctos) > 0
			nPrazoMedio := nPrazoMedio / Len(aVenctos)
		Endif

		DbSelectArea("SA2")  //Fornecedores
		DbSetOrder(1)

		DbSelectArea("SA3")  //Representantes
		DbSetOrder(1)

		DbSelectArea("SB5")  //Tabela de Preços 2
		DbSetOrder(1)

		cUf    := ""
		cInscr := ""
		cTipoCons := ""
		cCodCid := ""
		cCnpj := ""
		If M->C5_TIPO $ "D_B"
			DbSelectArea("SA2")
			DbSeek(xFilial("SA2")+M->C5_CLIENTE)
			If Found()
				cUf    := SA2->A2_EST
				cInscr := SA2->A2_INSCR
				cTipoCons := SA2->A2_CLAS
				cCodCid := SA2->A2_CODCID
				cCnpj := alltrim(SA2->A2_CGC)
			Endif
			//Cleber(13/09/21), pedido não passa por análise se não existir id de quem cadastrou. Identificação de quem está incluindo/alterando o pedido. 
			If INCLUI .OR. EMPTY(M->C5_CAD)
				M->C5_CAD   := Iif(!Empty(M->C5_PEDREPR) .OR. !EMPTY(M->C5_X_PVSIM), M->C5_VEND1, rtrim(cUserName))
				M->C5_DTCAD := dDataBase
				M->C5_FLAG  := "N" // Flag informando que o pedido não foi impresso
			Endif
			lCampanha := .f.
		Else
			DbSelectArea("SA1")
			DbSeek(xFilial("SA1")+M->C5_CLIENTE)
			If Found()
				cUf       := SA1->A1_EST
				cInscr    := SA1->A1_INSCR
				cTipoCons := SA1->A1_CLAS
				If INCLUI
					IF (SA1->A1_BOLETO = 'S') .AND. (cCondPag == "001")  // Cleber(16/04/04) =>Se for venda à vista, colocar automaticamente como boleto
						M->C5_BOLETO := "S"
					ENDIF
					IF !EMPTY(M->C5_X_PVSIM) 
						M->C5_TIPOVEN := "E"
						M->C5_DESCON1 := 0
						M->C5_VEND1 := SA1->A1_VEND
						M->C5_EMISSAO := DATE()
						M->C5_FRETE := 0.0
						M->C5_SEGURO := 0.0
					ENDIF
					if EMPTY(M->C5_VEND1)
						M->C5_VEND1 := SA1->A1_VEND
					endif 
					//Cleber(07/01/21) -> Descobri que desde outubro/2020 não está gravando banco
					IF !EMPTY(SA1->A1_BCO1) .AND. EMPTY(M->C5_BANCO)
						M->C5_BANCO := SA1->A1_BCO1
					ENDIF 
				Endif
				cCodCid := SA1->A1_CODCID
				cCnpj := alltrim(SA1->A1_CGC)
				//Chamado 020971, campanha pra revenda
				//Chamado 024742-> Extender campanha pra TODOS os segmentos
				/*
				if !(ALLTRIM(SA1->A1_CLAS) == "V")
					lCampanha := .f.
				endif 
				*/
			Endif
		Endif
		cDeposito := ALLTRIM(M->C5_DEPOSI)
		if cDeposito = nil
			cDeposito := ""
		endif 
		//Vefificar se cidade NÃO ESTÁ HABILITADA PARA Dep. Fechado
		if !(substr(_cNumEmp,1,4) == "0101") // somente a empresa 01 opera com deposito
			cDeposito := "N"
		endif

		cDeposito := iif(!((_cNumEmp = "01010101") .OR. (_cNumEmp = "01010106") .OR. (_cNumEmp = "01010107")),"N",cDeposito) //Se não for Brasilux/Matriz não sai pelo depósito a não ser que tenha sido solicitado pelo usuário
		if ((M->C5_TRANSP = "00700") .OR. (M->C5_TRANSP = "00573") .OR. (M->C5_TRANSP = "00800") ) .and. empty(cDeposito)
			cDeposito := "S"
		endif
		/*
		if !empty(cCodCid)
		dbselectarea("SZ7")
		dbseek(xFilial("SZ7")+cCodCid)
		if found()
		if SZ7->Z7_DEPOSI = 'N'
		cDeposito = "N"
		Endif
		endif
		endif */
		//endif

		// Criar tabela para aglutinar volumes por cor, para ver se o produto atinge cota de 60 litros p/ não bloquear separação de pedido
		/*
		cNomArq := CriaTrab(aCampos)
		cKey01  := "PEDIDO"
		cInd01  := SubStr(cNomArq, 1, 10)+"_1" //"SC"+SubStr(cNomArq, 8, 6)+"_1"
		cKey02  := "SubStr(CLIENTE, 01, 06)"
		cInd02  := SubStr(cNomArq, 1, 10)+"_2" //"SC"+SubStr(cNomArq, 8, 6)+"_2"
		cKey03  := "SubStr(CLIENTE, 13, 40)"
		cInd03  := SubStr(cNomArq, 1, 10)+"_3" //"SC"+SubStr(cNomArq, 8, 6)+"_3"
		cKey04  := "SubStr(VENDEDOR, 10, 35)"
		cInd04  := SubStr(cNomArq, 1, 10)+"_4" //"SC"+SubStr(cNomArq, 8, 6)+"_4"
		DbUseArea(.t., , cNomArq, "TMP", .t., .f.)
		DbCreateIndex(cInd01, cKey01, {||cKey01} )
		DbCreateIndex(cInd02, cKey02, {||cKey02} )
		DbCreateIndex(cInd03, cKey03, {||cKey03} )
		DbCreateIndex(cInd04, cKey04, {||cKey04} )
		DbClearIndex()
		DbSetIndex(cInd01)
		DbSetIndex(cInd02)
		DbSetIndex(cInd03)
		DbSetIndex(cInd04)*/
		aadd(aStrut,{"PRODUTO"   , "C", 10, 0})
		aadd(aStrut,{"VOLUME"  , "N", 15, 4})
		/********************************************************************************************************************************/
		/*** BLOCO ALTERADO EM 23/09/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
		//       cArqTemp := U_NovoArqTrab("dbf")
		//       dbcreate(cArqTemp+".dbf", aStrut, "DBFCDXADS")
		//       cCursorTemp := U_NovoCursor()
		//       Use (cArqTemp+".Dbf") Alias (cCursorTemp) VIA "DBFCDXADS" New Exclusive
		//     cKey01  := "PRODUTO"
		//     cInd01  := cArqTemp+"_1" //"SC"+SubStr(cNomArq, 8, 6)+"_1"
		//     DbCreateIndex(cInd01, cKey01, {||cKey01} )
		//     DbClearIndex()
		//     DbSetIndex(cInd01)

		cCursorTemp := "ZTMP"
		If SELECT( cCursorTemp ) <> 0
			DbSelectArea( cCursorTemp )
			DbCloseArea()
		Endif
		oTempTable := FWTemporaryTable():New( cCursorTemp )
		oTemptable:SetFields( aStrut )
		oTempTable:AddIndex( "cInd01", { "PRODUTO" } )
		oTempTable:Create()
		/********************************************************************************************************************************/
		DbSelectArea(cCursorTemp)
		DbSetOrder(1)

		_nVlrTotPed := 0   //Valor Total do Pedido
		_nVlrTotDup := 0   // Valor Total que gera FINANCEIRO
		nSomaVlrTab := 0   //Valor Total do Pedido (de itens que GERAM FINANCEIRO) pelo Valor de Tabela
		lGeraDup    := .f. //Verifica se gera duplicata ou não
		nContItens := 0 // Conta a qtde de itens do pedido
		lProdEstoque := .f.

		//Chamado 020971, campanha pra revenda
		cTabCampanha := ALLTRIM(M->C5_TABELA)
		if lCampanha .and. empty(cTabCampanha)
			lCampanha := .f.
		endif 
		cTabCampanha := padr(cTabCampanha, TamSX3("C5_TABELA")[1]," ")

		DbSelectArea("SZ5")
		DbSetOrder(1)
		For _x := 1 to Len(aCols)
			If !aCols[_x][Len(aHeader)+1] //Se não for registro deletado
				nContItens ++
				aCols[_x][nPosVolItem] := 0

				cAux := alltrim(aCols[_x][nPosProduto])
				if (len(cAux) == 12) .and. (substr(cAux,4,2) $ "87-88")
					cAux := "Pedido possui item(ns) da linha 87 e/ou 88"
					if !(cAux $ cObs)
						cObs += chr(13)+chr(10)+cAux
					endif
				endif

				cAux := alltrim(aCols[_x][nPosProduto])

				// Determinar em lVolJunto se produto junta volume c/ outros ou não, p/ efeito de cálculo de volumes
				lVolJunto := U_VolJunto(aCols[_x][nPosProduto])
				nQtdeVol     := 0
				nPesoLiqu    := 0
				nPesoBrut    := 0
				_nBaseIcms   := 0
				nQtdeMinEst  := 999999   //Quantidade mínima para considerar tabela de preço de produtos de estoque
				nPerint      := 0
				nLc1         := 0
				nLc2         := 0
				nValTab      := 0
				nValUnTab      := 0
				lProdEstoque := .f. //Verifica se é produto de estoque, para det. de lucro
				DbSelectArea("SB1") //Produtos
				DbSeek(xFilial("SB1")+aCols[_x][nPosProduto])
				If Found()
					lProdEstoque := iif((SB1->B1_ESTOQUE == "S"),.t.,.f.)
					//Itens de IPI Zero Misturados com itens de IPI maior que zero. Chamado 007956
					IF !lIpiZeroM .AND. (nContItens > 1) .AND. ((SB1->B1_IPI = 0.0) .AND. (nIpiAnt > 0.0)) .OR. ((SB1->B1_IPI > 0.0) .AND. (nIpiAnt = 0.0))
						lIpiZeroM := .T.
					ENDIF
					nIpiAnt := SB1->B1_IPI

					if (len(alltrim(SB1->B1_COD)) == 12)

						if !lProdEstoque
							DbSelectArea("SZ5")
							DbSeek(xFilial("SZ5")+SubStr(aCols[_x][nPosProduto], 11, 2))
							If Found()
								nQtdeMinEst := SZ5->Z5_QTDVEN
								if ((aCols[_x][nPosQtdVen] ) >= nQtdeMinEst) //Se atingir qtde mínima considerar como prod. de estoque
									lProdEstoque := .t.
								endif
							endif
						endif

						/*
						//--INICIO--Verificar se está se utilizando produto NÃO estoque com alternativa de estoque. Mandar email
						dbselectarea("SB2")
						dbseek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD)
						if found() .and. empty(alltrim(SB2->B2_LOCALIZ)) //Produto Específico à vista da Produção
							dbselectarea("SB1")
							nRegB1 := recno()
							dbseek(xFilial("SB1")+substr(aCols[_x][nPosProduto],1,10),.t.)
							do while !eof() .and. (SB1->B1_FILIAL == xFilial("SB1")) .AND. (SUBSTR(SB1->B1_COD,1,10) == substr(aCols[_x][nPosProduto],1,10))
								if !(SB1->B1_COD == aCols[_x][nPosProduto]) .AND. (SB1->B1_MSBLQL <> "1") .AND. (SB1->B1_VEND != "N") .AND. (SB1->B1_TIPO = "PA")
									dbselectarea("SB2")
									dbseek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD)
									if found() .and. !empty(alltrim(SB2->B2_LOCALIZ)) //Tem alternativa de estoque?
										cProdEsp += 'Produto específico de código '+aCols[_x][nPosProduto]+' possui embalagem alternativa de estoque, por ex.: '+SB2->B2_COD+chr(13)+chr(10)
										exit
									endif
								endif
								dbselectarea("SB1")
								dbskip()
							enddo
							dbselectarea("SB1")
							dbgoto(nRegB1)
						endif
						//--FIM--Verificar se está se utilizando produto NÃO estoque com alternativa de estoque. Mandar email
						*/
					endif //FIM (len(alltrim(SB1->B1_COD)) == 12)

					nLc1    := SB1->B1_COMIS + SB1->B1_LUCRO
					nLc2    := SB1->B1_COMIS + SB1->B1_LUCRO2
					nValUnTab := SB1->B1_PRV1
					If !lProdEstoque
						DbSelectArea("SB5")
						DbSeek(xFilial("SB5")+aCols[_x][nPosProduto])
						If Found()
							nValUnTab := SB5->B5_PRV2
						Endif
						nEntrega := 15 //Se tiver produtos específicos o prazo se estende para 15 dias úteis
					Endif

					nValTab := nValUnTab * aCols[_x][nPosQTDVEN] // * Iif(!Empty(Alltrim(M->C5_ESPECI4)), 2, 1) //Em princípio, fica com o valor tabela 1, logo abaixo, se for o caso troca caso não seja produto de estoque
					nPerInt := SB1->B1_PERINT/100
					aCols[_x][nPosLucrEsp] := iif(lProdEstoque,SB1->B1_LUCRO,SB1->B1_LUCRO2) // % de Lucro esperado para o item

				else
					lRet := .f.
					cAuxMens := "Não encontrado o PRODUTO "+aCols[_x][nPosProduto]+" no cadastro. Contacte o Adm. do Sistema!"
					If (ValAtrib("l410Auto") <> "U" .and. l410Auto) //release 12.1.25 if ( Type("l410Auto") <> "U" .And. l410Auto )
						//ConOut(cAuxMens) DESABILITADO 12.1.25
						FwLogMSG( "WARN", , 'SIGAFAT', funname(), '', '01', cAuxMens, 0 )
					else
						MsgBox(cAuxMens, "Atenção", "STOP")
					endif
					exit
				Endif

				//(01/08/12) - Cleber - Determinar saída sempre da fábrica 1 na Matriz
				//IF ((Substr(_cNumEmp,1,4) = "0101") .OR. (Substr(_cNumEmp,1,4) = "0106")) //.AND. (ALLTRIM(SB1->B1_TIPO) $ "MP_PI_PA")
				IF ((Substr(_cFilial,1,2) = "01") .OR. (Substr(_cFilial,1,2) = "06")) //.AND. (ALLTRIM(SB1->B1_TIPO) $ "MP_PI_PA")
					//16-09-2014 -> Cond. temporaria para separar estoque de Guarulhos até implantar estoque por endereços
					do case
						case _cFilial = "010106"  //Depósito Guarulhos
						do case
							case SB1->B1_TIPO = "MP"
							cAux := "G1"
							case SB1->B1_TIPO = "PI"
							cAux := "G2"
							case SB1->B1_TIPO = "PA"
							cAux := "G3"
							case SB1->B1_TIPO = "MC"
							cAux := "G4"
						endcase
						case _cFilial = "010107"//Depósito Matão
						do case
							case SB1->B1_TIPO = "MP"
							cAux := "M1"
							case SB1->B1_TIPO = "PI"
							cAux := "M2"
							case SB1->B1_TIPO = "PA"
							cAux := "M3"
							case SB1->B1_TIPO = "MC"
							cAux := "M4"
						endcase

						case _cFilial = "010101"//Brasilux/Matriz -> Se for operação com Depósito atualizar almoxarifado.
						if !aCols[_x][nPosC6_LOCAL] $ "90.98"
							do case
								case SB1->B1_TIPO = "MP"
								cAux := iif(cDeposito = "S","G1","01")
								case SB1->B1_TIPO = "PI"
								cAux := iif(cDeposito = "S","G2","02")
								case SB1->B1_TIPO = "PA"
								cAux := iif(cDeposito = "S","G3","03")
								otherwise
								cAux := iif((cDeposito = "S") .AND. (SUBSTR(aCols[_x][nPosC6_LOCAL],1,1) == "0"),"G"+SUBSTR(aCols[_x][nPosC6_LOCAL],2,1),aCols[_x][nPosC6_LOCAL])
							endcase
						else
							cAux := aCols[_x][nPosC6_LOCAL]
						endif
						case _cFilial = "060101"  //Dissoltex -> Permitir Inclusão de Pedidos de devolução de material de terceiros ALMO TE
						if !aCols[_x][nPosC6_LOCAL] $ "TE.90.98"
							do case
								case SB1->B1_TIPO = "MP"
								cAux := "01"
								case SB1->B1_TIPO = "PI"
								cAux := "02"
								case SB1->B1_TIPO = "PA"
								cAux := "03"
								case SB1->B1_TIPO = "MC"
								cAux := "04"
								otherwise
								cAux := aCols[_x][nPosC6_LOCAL]
							endcase
						else
							cAux := aCols[_x][nPosC6_LOCAL]
						endif
						otherwise
						do case
							case SB1->B1_TIPO = "MP"
							cAux := "01"
							case SB1->B1_TIPO = "PI"
							cAux := "02"
							case SB1->B1_TIPO = "PA"
							cAux := "03"
							case SB1->B1_TIPO = "MC"
							cAux := "04"
							otherwise
							cAux := aCols[_x][nPosC6_LOCAL]
						endcase
					endcase

					if !(aCols[_x][nPosC6_LOCAL] == cAux)
						aCols[_x][nPosC6_LOCAL] := cAux
					endif
				ENDIF

				//12/05/14 - André - Atualizar o Campo C6_ENTREG com o valor do campo C5_PEDPROG
				//If GETMV("MV_XHABBOR") release 12.1.25
				If lXHABBOR	
					If !EMPTY(M->C5_PEDPROG) .AND. (M->C5_PEDPROG > M->C5_EMISSAO)
						aCols[_x][nPosENTREG] :=  M->C5_PEDPROG
					Elseif(EMPTY(M->C5_PEDPROG))
						aCols[_x][nPosENTREG] :=  M->C5_EMISSAO
					Endif
				Endif

				// Zerar Descontos para não aparecer valor maior em Valor Contabil em SF3
				//DescPed(nVlrTab,nVlrOrig,nDesc1,nDesc2,nDesc3)
				nAux := TamSX3("C6_PRCVEN")[2]
				aCols[_x][nPosPRCVEN] := round(U_DescPed(nValUnTab,aCols[_x][nPosPRCVEN],M->C5_DESCON1,M->C5_DESCON2,M->C5_DESCON3),nAux)
				aCols[_x][nPosPRUNIT]  := aCols[_x][nPosPRCVEN]
				aCols[_x][nPosDESCONT] := 0
				aCols[_x][nPosVALDESC] := 0
				nAux := TamSX3("C6_VALOR")[2]
				IF M->C5_TIPO = "N"
					aCols[_x][nPosValor] := round(aCols[_x][nPosPRCVEN]*aCols[_x][nPosQTDVEN],nAux)
				ELSE
					lCampanha := .f. //Chamado 020971, campanha somente pra pedidos de venda normais
				ENDIF
				M->C5_DESC1 := 0
				M->C5_DESC2 := 0
				M->C5_DESC3 := 0
				M->C5_DESC4 := 0

				// Checar consistências
				DbSelectArea("SF4") //Tipo de Entrada e Saída
				DbSeek(xFilial("SF4")+aCols[_x][nPosTES])
				If !Found()
					lRet := .f.
					cAuxMens := "Não encontrado o TES "+aCols[_x,nPosTES]+" no cadastro. Contacte o Adm. do Sistema!"
					If (ValAtrib("l410Auto") <> "U" .and. l410Auto) //release 12.1.25 if ( Type("l410Auto") <> "U" .And. l410Auto )
						//ConOut(cAuxMens)
						FwLogMSG( "WARN", , 'SIGAFAT', funname(), '', '01', cAuxMens, 0 )
					else
						MsgBox(cAuxMens, "Atenção", "STOP")
					endif
					exit
				endif

				If (SF4->F4_DUPLIC $ 'S ') .OR. (SF4->F4_CODIGO = "519")
					lGeraDup := .t.
				Endif

				//Enviar pedido p/ MasterSales
				IF (M->C5_TIPO = "N") .AND. (SF4->F4_DUPLIC $ 'S ') .AND. ((_cFilial == "010101") .OR. (_cFilial == "060101"))
					lMasterS := .T.
					aCols[_x,nPosC6SIM3G] := "S"
				ELSE
					aCols[_x,nPosC6SIM3G] := "N"
				ENDIF

				IF lMasterS
					M->C5_X_SIM3G := "S"
				ENDIF

				if lGeraDup .AND. (M->C5_TIPO = "N") 
					IF ((len(alltrim(aCols[_x][nPosProduto])) != 12) .or. !(substr(aCols[_x][nPosProduto],4,2) $ "71-10"))
						// Não é pedido exclusivo de Solventes linhaS 71 e 10!
						lSoSolventes := .f.
					ENDIF 
				endif

				//Se não tiver TES para depósito equivalente então não passa por depósito
				/*	if empty(SF4->F4_TESSIMB)
				cDeposito := "N"
				endif
				*/

				/*
				cAux = cDeposito
				if empty(cAux) .and. (Len(Alltrim(aCols[_x][nPosProduto])) == 12)
				dbselectarea("SZ1")
				dbseek(xFilial("SZ1")+substr(aCols[_x][nPosProduto],4,2))
				if !found()
				cAux := "N"
				else
				if SZ1->Z1_DEPOSI = "N"
				cAux := "N"
				endif
				endif
				endif

				if empty(cDeposito) .and. !emptY(cAux)
				cDeposito := cAux
				endif

				if !empty(cAux) .and. !empty(cDeposito) .and. (cDeposito != cAux)
				lRet := .f.
				cAuxMens := "Produto "+aCols[_x][nPosProduto]+" faz como que haja mistura de remessa para depósito e remessa normal!"
				if ( Type("l410Auto") <> "U" .And. l410Auto )
				ConOut(cAuxMens)
				else
				MsgBox(cAuxMens, "Atenção", "STOP")
				endif
				exit
				endif
				*/

				/*
				IF (M->C5_TIPO = "N") .AND. !empty(SF4->F4_TESSIMB) .and. (_cNumEmp <> "01010106") .and. (cDeposito == "S") .and. (aCols[_x][nPosTES] <> SF4->F4_TESSIMB)
				aCols[_x][nPosTES] := SF4->F4_TESSIMB
				DbSelectArea("SF4") //Tipo de Entrada e Saída
				DbSeek(xFilial("SF4")+aCols[_x][nPosTES])
				If !Found()
				lRet := .f.
				cAuxMens := "Não encontrado o TES "+aCols[_x,nPosTES]+" no cadastro. Contacte o Adm. do Sistema!"
				if ( Type("l410Auto") <> "U" .And. l410Auto )
				ConOut(cAuxMens)
				else
				MsgBox(cAuxMens, "Atenção", "STOP")
				endif
				exit
				endif
				ENDIF
				*/

				// Determinar o CST -> Cleber
				cCst := ""
				cAux := dtos(date())
				cPerVen := substr(cAux,5,2)+substr(cAux,1,4)
				//Período de cálculo
				nAno := year(date())
				nMes := month(date()) - 2
				if nMes <= 0
					nMes := 12+nMes
					nAno--
				endif
				cPerCal := padl(alltrim(str(nMes)),2,"0")+padl(alltrim(str(nAno)),4,"0")

				/*
				//Cleber (2021)->FCI passou a ser determinado automaticamente pelo Protheus
				if nPosFCI > 0 // Não encontrado campo FCI qdo se usa a ferramenta Copiar!
					dbselectarea("CFD")
					//CFD_FILIAL+CFD_COD+CFD_PERCAL+CFD_PERVEN
					cAux := iif((_cNumEmp == "01010106") .OR. (_cNumEmp == "01010107"),"010101",xFilial("CFD"))
					dbseek(cAux+SB1->B1_COD+cPerCal+cPerVen,.T.)
					if found()
						cCst := CFD->CFD_ORIGEM
						if M->C5_TIPO = "N"
							aCols[_x][nPosFCI] := CFD->CFD_FCICOD
						endif
					endif
				endif
				*/
				//Cleber (2021)->FCI passou a ser determinado automaticamente pelo Protheus (substituição ao código situação anterior)
				if nPosFCI > 0 // Não encontrado campo FCI qdo se usa a ferramenta Copiar!
					IF !empty(aCols[_x][nPosFCI]) .and. (M->C5_TIPO = "N") //Caso o código fci esteja preenchido
						dbselectarea("CFD")
						//CFD_FILIAL+CFD_FCICOD                                                                                                                                           
						dbseek(xFilial("CFD")+aCols[_x][nPosFCI])
						if found()
							cCst := CFD->CFD_ORIGEM
						endif
					endif
				endif
				IF EMPTY(cCst)
					if !empty(SB1->B1_ORIGEM)
						cCst := trim(SB1->B1_ORIGEM)
					else
						if cUf != "EX"
							cCst := "0"
						else
							cCst := "1"
						endif
					endif
				endif
				if empty(cCst)
					cCst := "0"
				endif
				cCst += ALLTRIM(SF4->F4_SITTRIB)

				//Preenchimento correto do CST (02/07/09) -> Cleber
				//Correção do CST (15/05/13) -> Cleber
				if (len(alltrim(aCols[_x][nPosCst])) != 3) .OR. (M->C5_TIPO = "N")
					aCols[_x][nPosCst] := cCst
				endif

				//Verificar se volumes ficam incompletos
				lVolQuebr := (M->C5_TIPO = "N") .AND. U_VolQuebrado(aCols[_x][nPosProduto], aCols[_x][nPosQTDVEN] )
				If lVolQuebr .AND. (SF4->F4_VOLQUEB != "S")  //* Iif(!Empty(Alltrim(M->C5_ESPECI4)), 2, 1)
					//Ped. funcionários podem ter volume quebrado (Solic. Ramon em 03/10/14)
					lAux := .f. //Flag que identifica se é funcionário
					if len(cCnpj) == 11
						cQry1 := "SELECT RA_MAT FROM "+RetSqlName("SRA")+" SRA WITH (NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND (RA_CIC = '"+cCnpj+"') AND (RA_SITFOLH <> 'D')"
						TCQuery cQry1 ALIAS "TCQRA" NEW
						DbSelectArea("TCQRA")
						dbgotop()
						if !eof() .and. !bof()
							lAux := .t.
						endif
						DbSelectArea("TCQRA")
						dbclosearea()

					endif
					if !lAux //Se não for funcionário
						lRet      := .f.
						cMensErro := "Quantidade de Volumes para o produto "+aCols[_x][nPosProduto]+" não permitida!"
						If (ValAtrib("l410Auto") <> "U" .and. l410Auto) //release 12.1.25 if ( Type("l410Auto") <> "U" .And. l410Auto )
							//ConOut(cMensErro)
							FwLogMSG( "WARN", , 'SIGAFAT', funname(), '', '01', cMensErro, 0 )
						else
							MsgBox(cMensErro, "Atenção", "STOP")
						endif
						exit
					Endif
				endif

				//Solic. Cleiton em 15/10/2014-> Enviar e-mail pro Caio e Cleiton quando for volume quebrado na Dissoltex
				if lVolQuebr //.and. (_cNumEmp = "06")
					if !empty(cProdsVolQuebr)
						cProdsVolQuebr += chr(13)+chr(10)
					endif
					cProdsVolQuebr += aCols[_x][nPosProduto]
				endif

				//Determinação dos Pesos Liquido/Bruto, da quantidade de volumes e volume por cor
				nPesoLiqu := (SB1->B1_PESO * aCols[_x][nPosQTDVEN] ) //* Iif(!Empty(Alltrim(M->C5_ESPECI4)), 2, 1)
				//nPesoBrut := nPesoLiqu
				nPesoBrut := (SB1->B1_PESBRU * aCols[_x][nPosQTDVEN] )

				DbSelectArea("SG1")
				DbSetOrder(1)

				//Determinação dos Pesos Liquido/Bruto, da quantidade de volumes, volume por cor e cubagem
				aAuxEmba := {}
				If (Len(Alltrim(aCols[_x][nPosProduto])) == 12) .and. !(Substr(aCols[_x][nPosProduto], 11, 2) $ "00.99")
					aAdd(aAuxEmba, {Alltrim(Substr(aCols[_x][nPosProduto], 11, 2)),0,0,0,0,"",0})
					lRegB1 := .f.
					DbSelectArea("SZ5")
					DbSeek(xFilial("SZ5")+SubStr(aCols[_x][nPosProduto], 11, 2))
					If Found()
						DbSelectArea("SB1")
						nRegB1 := Recno()
						lRegB1 := .t.
						dbselectarea(cCursorTemp)
						dbseek(substr(aCols[_x][nPosProduto],1,10),.t.)
						if !found()
							reclock(cCursorTemp,.t.)
							(cCursorTemp)->PRODUTO := substr(aCols[_x][nPosProduto],1,10)
						else
							reclock(cCursorTemp,.f.)
						endif
						(cCursorTemp)->VOLUME += SZ5->Z5_VOLUME
						msunlock()
					Endif

					lEmbaemG1 := .f. //Identifica se há tipo de embalagem na estrutura, caso contrário pega dos 2 díg. finais do código do produto
					IF SB1->B1_RELVOL > 0
						aAuxEmba[1][6] := alltrim(STR(SB1->B1_RELVOL))
						nAuxVol := U_DetVolEmba(aAuxEmba[1][6], aCols[_x][nPosQTDVEN] ) //* Iif(!Empty(Alltrim(M->C5_ESPECI4)), 2, 1)
						aAuxEmba[1][2] := aCols[_x][nPosQTDVEN] // * Iif(!Empty(Alltrim(M->C5_ESPECI4)), 2, 1)
						aAuxEmba[1][3] := iif(lVolJunto,aCols[_x][nPosQTDVEN],0)
						aAuxEmba[1][4] := iif(!lVolJunto,nAuxVol,0)
						aAuxEmba[1][5] := iif(lVolJunto .and. (SF4->F4_VOLQUEB != "S") .and.  (substr(aCols[_x][nPosProduto],1,2) $ "BL"),aCols[_x][nPosQTDVEN],0)
						aCols[_x][nPosVolItem] += nAuxVol //* Iif(!Empty(Alltrim(M->C5_ESPECI4)), 2, 1)
					else

						DbSelectArea("SG1")
						DbSetOrder(1)
						DbSeek(xFilial("SG1")+aCols[_x][nPosProduto], .F.)
						If Found()
							While !Eof() .AND. (SG1->G1_FILIAL == xFilial("SG1")) .AND. (SG1->G1_COD = aCols[_x][nPosProduto]) .AND. (Len(RTrim(SG1->G1_COMP)) == 4)
								cComp    := RTrim(SG1->G1_COMP)
								nQtdComp := 0
								While !Eof() .AND. (SG1->G1_FILIAL == xFilial("SG1")) .AND. (SG1->G1_COD = aCols[_x][nPosProduto]) .AND. (Len(RTrim(SG1->G1_Comp)) == 4) .AND. (RTrim(SG1->G1_COMP) == cComp)
									nQtdComp += SG1->G1_QUANT
									DbSkip()
								Enddo

								DbSelectArea("SB1")
								DbSeek(xFilial("SB1")+cComp, .F.)
								If Found() .and. !Empty(SB1->B1_RELCAT1)
									lEmbaemG1 := .t.
									DbSelectArea("SZ5")
									DbSeek(xFilial("SZ5")+alltrim(SB1->B1_RELCAT1))
									If !Found()
										dbselectarea("SG1")
										loop
									endif

									lAchou := .f.
									for i = 1 to len(aAuxEmba)
										if (empty(aAuxEmba[i][6]) .or. (aAuxEmba[i][6] == alltrim(SZ5->Z5_RELVOL)))
											lAchou := .t.
											nVar := i
										endif
									next
									if !lAchou
										nVar := len(aAuxEmba)+1
										aAdd(aAuxEmba, {Alltrim(Substr(aCols[_x][nPosProduto], 11, 2)),0,0,0,0,alltrim(SZ5->Z5_RELVOL),0})
									else
										if empty(aAuxEmba[nVar][6])
											aAuxEmba[nVar][6] := alltrim(SZ5->Z5_RELVOL)
										endif
									endif

									nAuxQtde := aCols[_x][nPosQTDVEN] * nQtdComp
									nAuxVol := U_DetVolEmba(aAuxEmba[nVar][6], nAuxQtde ) //* Iif(!Empty(Alltrim(M->C5_ESPECI4)), 2, 1)
									aAuxEmba[nVar][2] := aAuxEmba[nVar][2] + nAuxQtde // * Iif(!Empty(Alltrim(M->C5_ESPECI4)), 2, 1)
									aAuxEmba[nVar][3] := aAuxEmba[nVar][3] + iif(lVolJunto,nAuxQtde,0)
									aAuxEmba[nVar][4] := aAuxEmba[nVar][4] + iif(!lVolJunto,nAuxVol,0)
									aAuxEmba[nVar][5] := aAuxEmba[nVar][5] + iif(lVolJunto .and. (SF4->F4_VOLQUEB != "S") .and. (substr(aCols[_x][nPosProduto],1,2) $ "BL"),nAuxQtde,0)

									aCols[_x][nPosVolItem] += nAuxVol //* Iif(!Empty(Alltrim(M->C5_ESPECI4)), 2, 1)
								Endif
								DbSelectArea("SG1")
							EndDo
						Endif
						// Se não tiver embalagem na estrutura considerar código final.
						If !lEmbaemG1 .and. !(Substr(aCols[_x][nPosProduto], 11, 2) $ "00.99") // Se não tiver cód. de embalagem na estrutura, pegar pelo final do cód. do prod.
							DbSelectArea("SZ5")
							DbSeek(xFilial("SZ5")+aAuxEmba[1][1])
							If Found()
								aAuxEmba[1][6] := alltrim(SZ5->Z5_RELVOL)
							endif
							nAuxVol := U_DetVolEmba(aAuxEmba[1][6], aCols[_x][nPosQTDVEN] ) //* Iif(!Empty(Alltrim(M->C5_ESPECI4)), 2, 1)
							aAuxEmba[1][2] := aCols[_x][nPosQTDVEN] // * Iif(!Empty(Alltrim(M->C5_ESPECI4)), 2, 1)
							aAuxEmba[1][3] := iif(lVolJunto,aCols[_x][nPosQTDVEN],0)
							aAuxEmba[1][4] := iif(!lVolJunto,nAuxVol,0)
							aAuxEmba[1][5] := iif(lVolJunto .and. (SF4->F4_VOLQUEB != "S") .and.  (substr(aCols[_x][nPosProduto],1,2) $ "BL"),aCols[_x][nPosQTDVEN],0)
							aCols[_x][nPosVolItem] += nAuxVol //* Iif(!Empty(Alltrim(M->C5_ESPECI4)), 2, 1)
						Endif
					endif

					DbSelectArea("SB1")
					If lRegB1
						DbGoto(nRegB1)
					Endif
				Else // Se não PA de 12 dígitos(Tinta) !
					IF (Len(Alltrim(aCols[_x][nPosProduto])) == 12)
						nQtdeVol := nQtdeVol + 1
						aAuxEmba := {}
						aAdd(aAuxEmba, {substr(aCols[_x][nPosProduto],11,2),aCols[_x][nPosQTDVEN],0,1,0,alltrim(str(aCols[_x][nPosQTDVEN])),0})
						aCols[_x][nPosVolItem] += 1
					ELSE

						nAux := IIF(SB1->B1_RELVOL > 0,round(aCols[_x][nPosQTDVEN]  / SB1->B1_RELVOL,3),0)   //* Iif(!Empty(Alltrim(M->C5_ESPECI4)), 2, 1)
						If Int(nAux) < nAux
							nAux := Int(nAux) + 1
						Endif
						nQtdeVol := nQtdeVol + nAux
						aAuxEmba := {}
						aAdd(aAuxEmba, {"--",aCols[_x][nPosQTDVEN],0,nAux,0,alltrim(str(SB1->B1_RELVOL)),0})
						aCols[_x][nPosVolItem] += nAux
					ENDIF

				Endif

				for j := 1 to len(aAuxEmba)
					//Det. da Cubagem
					nCubagem := iif(j == 1,DetCubagem(aCols[_x][nPosProduto])*aCols[_x][nPosQTDVEN],0)

					lAchou = .f.
					For i := 1 to Len(aEmba)
						If (aEmba[i][1] == aAuxEmba[j,1]) .and. (aEmba[i][6] == aAuxEmba[j,6])
							lAchou := .t.
							nVar   := i
						Endif
					Next
					If !lAchou
						nVar := Len(aEmba)+1
						//Tipo de embalagem correspondente armazenado
						aAdd(aEmba, {aAuxEmba[j,1],0,0,0,0,aAuxEmba[j,6],0 })
					endif
					aEmba[nVar,2] += aAuxEmba[j,2]
					aEmba[nVar,3] += aAuxEmba[j,3]
					aEmba[nVar,4] += aAuxEmba[j,4]
					aEmba[nVar,5] += aAuxEmba[j,5]
					aEmba[nVar,7] += nCubagem

				next
				// término cálc. volumes p/ o item

				//            nVolTotal      := nVolTotal + nQtdeVol
				nPesoLiquTotal := nPesoLiquTotal + nPesoLiqu
				nPesoBrutTotal := nPesoBrutTotal + nPesoBrut

				// Definição da CFOP
				cCf := alltrim(aCols[_x][nPosCF])
				if empty(cCf)
					cCf := alltrim(SF4->F4_CF)
				endif
				If (cUf != "EX")
					DO CASE
						//CASE ((cCf = "6107") .OR. (alltrim(SF4->F4_CF) = "6107")) .AND. (GETMV("MV_ESTADO") = cUf) // Antes era "618" RELEASE 12.1.25
					CASE ((cCf = "6107") .OR. (alltrim(SF4->F4_CF) = "6107")) .AND. (cEstado = cUf) // Antes era "618"
						cCf := "5101"
						//Cleber (12/04/16) -> Solic. Nadia inclusão para o CFOP 6108 semelhante à situação do 6107
						//CASE ((cCf = "6108") .OR. (alltrim(SF4->F4_CF) = "6108")) .AND. (GETMV("MV_ESTADO") = cUf) Release 12.1.25
					CASE ((cCf = "6108") .OR. (alltrim(SF4->F4_CF) = "6108")) .AND. (cEstado = cUf)
						cCf := "5102"
					OTHERWISE
						//If (GETMV("MV_ESTADO") != cUf) .and. (substr(cCf,1,1) == "5") release 12.1.25
						If (cEstado != cUf) .and. (substr(cCf,1,1) == "5")
							cCf := "6"+substr(cCf,2,len(cCf)-1)
							//           				cCf := Str(Val(Substr(SF4->F4_CF, 1, 1))+1, 1)
							//                     	cCf := cCf + Substr(SF4->F4_CF, 2, 3)
						Endif

					ENDCASE

				Else
					if substr(cCf,1,1) == "5"
						cCf := "7"+substr(cCf,2,len(cCf)-1)
					endif
					/*               	cCf := Str(Val(Substr(SF4->F4_CF, 1, 1))+2, 1)
					cCf := cCf + Substr(SF4->F4_CF, 2, 3) */
				Endif
				IF (cDeposito = "S") .and. !empty(ALLTRIM(SF4->F4_XCFODEP))
					cCf := substr(cCf,1,1)+substr(SF4->F4_XCFODEP,2,3)
				ENDIF
				aCols[_x][nPosCF] := cCf
				// Definição da Base de ICMS p/ fins de apuração de Lucro e Comissão
				_nPercIcms := 0
				If SF4->F4_ICM = "S"
					_nBaseIcms := aCols[_x][nPosVALOR] / Iif(!Empty(Alltrim(M->C5_ESPECI4)), 0.7, 1)
					If (SF4->F4_IPI == "S") .AND. (SF4->F4_INCIDE == "S")
						_nBaseIcms := _nBaseIcms * (1 + (SB1->B1_IPI / 100))
					Endif
					if cUf = "EX"
						_nPercIcms := 0
						lCampanha := .f.
					else
						//If (cTipoCons = "N") .OR. (GETMV("MV_ESTADO") = cUf) release 12.1.25
						If (cTipoCons = "N") .OR. (cEstado = cUf)
							//IF (GETMV("MV_ESTADO") = cUf) .AND. (GETMV("MV_ESTADO") = "SP") .AND. (SB1->B1_GRTRIB = '003') release 12.1.25
							IF (cEstado = cUf) .AND. (cEstado = "SP") .AND. (SB1->B1_GRTRIB = '003')
								//25% ICMS para produtos 100% solvente puro
								_nPercIcms = 25
							else
								//_nPercIcms = GETMV("MV_ICMPAD") // release 12.1.25
								_nPercIcms = nICMPAD
							endif
						Else
							//FCI -> ICMS 4%
							if substr(aCols[_x][nPosCst],1,1) $ "1,3,8"
								_nPercIcms = 4
							else
								If cUf $ "MG_PR_RJ_RS_SC_SP"
									_nPercIcms = 12
								Else
									_nPercIcms = 7
								Endif
							Endif
						endif
					endif
				Endif

				//Chamado 020971, campanha de venda
				
				if lCampanha
					do case 
					case cEstado = cUf
						nIcmCampanha := 18
					case cUf $ "MG_PR_RJ_RS_SC_SP"
						nIcmCampanha := 12
					otherwise
						nIcmCampanha := 7
					endcase
					//Verificar se preencheu com uma das tabelas de campanha de região de ICMS, validar se foi pra região de ICMS correto
					dbselectarea("DA0")
					dbseek(xFilial("DA0")+cTabCampanha)
					if !found()
						lCampanha := .f.
					endif 
				endif 
				if lCampanha .and. ((DA0->DA0_DATDE > M->C5_EMISSAO) .OR. (DA0->DA0_DATATE < M->C5_EMISSAO))				
					lCampanha := .f.
				endif 
				if lCampanha
					cCondCamp := EhAvista(DA0->DA0_CONDPG) //Converter cond. pgto pra à vista (menos de 7 dias é consid à vista)
					if (DA0->DA0_REGICM > 0) .AND. (DA0->DA0_REGICM != nIcmCampanha)
						cAux := "Tabela de Campanha "+cTabCampanha+" NÃO pertence à região de icms correta!"
						If (ValAtrib("l410Auto") <> "U" .and. !l410Auto)//release 12.1.25 If  ( Type("l410Auto") = "U" .or. !l410Auto )
							MsgBox(cAux, "Atenção", "STOP")
						else
							//ConOut(cAux)
							FwLogMSG( "WARN", , 'SIGAFAT', funname(), '', '01', cAux, 0 )
						endif
						lCampanha := .f.
					endif 
				endif 
				if lCampanha
					if !empty(alltrim(DA0->DA0_CONDPG)) .AND. !(cCondPag == cCondCamp)
						cAux := "Condição de Pgto diverge do cad da Tabela, deveria ser "+DA0->DA0_CONDPG+"!"
						If (ValAtrib("l410Auto") <> "U" .and. !l410Auto)//release 12.1.25 If  ( Type("l410Auto") = "U" .or. !l410Auto )
							MsgBox(cAux, "Atenção", "STOP")
						else
							//ConOut(cAux)
							FwLogMSG( "WARN", , 'SIGAFAT', funname(), '', '01', cAux, 0 )
						endif
						lCampanha := .f.
					endif 
				endif 

				// Verificar se tem desconto de Pis/Cofins
				_nPisCof := 0 // Valor a ser descontado de Pis/Cofins
				if empty(SF4->F4_PISCOF) .or. (SF4->F4_PISCOF = "N")

					//_nPisCof :=  (aCols[_x][nPosVALOR] / Iif(!Empty(Alltrim(M->C5_ESPECI4)), 0.7, 1)) * ((GETMV("MV_TXPIS") + GETMV("MV_TXCOFIN"))/100) release 12.1.25
					_nPisCof :=  (aCols[_x][nPosVALOR] / Iif(!Empty(Alltrim(M->C5_ESPECI4)), 0.7, 1)) * ((nTXPIS + nTXCOFIN)/100)
				endif

				nVlrProd := (aCols[_x][nPosVALOR]/Iif(!Empty(Alltrim(M->C5_ESPECI4)), 0.7, 1)) // * Iif(!Empty(Alltrim(M->C5_ESPECI4)), 2, 1)
				_nVlrTotPed := _nVlrTotPed + nVlrProd

				if (SF4->F4_DUPLIC = "S") .OR. (SF4->F4_CODIGO = "519")
					_nVlrTotDup := _nVlrTotDup + nVlrProd

					//Somar em aCl os valores minimos do item para depois definir o valor minimo do pedido permitido de acordo com a pol. vendas
					/*
					//Em 18/01/10 definida política específica para os ST 55
					//Retirada a regra com autorização Eliana em 25/04/15
					IF (substr(SB1->B1_COD,1,5) == "ST 55") .and. (B1_TIPO = 'PA') .and. ((SB1->B1_PRV1 = 5.9) .OR. (SB1->B1_PRV1 = 7.2) .OR. (SB1->B1_PRV1 = 10.95))
					aPrecos := {}
					nAux := SB1->B1_PRV1
					do case
					case (SB1->B1_PRV1 = 5.9) .AND. (_nPercIcms <= 7)
					nAux = 4
					case (SB1->B1_PRV1 = 5.9) .AND. (_nPercIcms <= 12)
					nAux = 4.5
					case (SB1->B1_PRV1 = 5.9) .AND. (_nPercIcms <= 18)
					nAux = 5
					case (SB1->B1_PRV1 = 7.2) .AND. (_nPercIcms <= 7)
					nAux = 5
					case (SB1->B1_PRV1 = 7.2) .AND. (_nPercIcms <= 12)
					nAux = 5.5
					case (SB1->B1_PRV1 = 7.2) .AND. (_nPercIcms <= 18)
					nAux = 6
					case (SB1->B1_PRV1 = 10.95) .AND. (_nPercIcms <= 7)
					nAux = 7.5
					case (SB1->B1_PRV1 = 10.95) .AND. (_nPercIcms <= 12)
					nAux = 8
					case (SB1->B1_PRV1 = 10.95) .AND. (_nPercIcms <= 18)
					nAux = 8.5
					endcase

					aadd(aPrecos,nAux*aCols[_x][nPosQTDVEN])
					aadd(aPrecos,nAux*aCols[_x][nPosQTDVEN])
					aadd(aPrecos,nAux*aCols[_x][nPosQTDVEN])
					aadd(aPrecos,nAux*aCols[_x][nPosQTDVEN])
					aadd(aPrecos,nAux*aCols[_x][nPosQTDVEN])
					aadd(aPrecos,nAux*aCols[_x][nPosQTDVEN])
					ELSE */
					aPrecos := U_PrcMinimo(nValTab,iif(len(alltrim(SB1->B1_COD)) == 12,SUBSTR(SB1->B1_GRUPO2,2,1),"X"),_nPercIcms,IIF(SF4->F4_INCIDE == "S",.T.,.F.),cCondPag)

					aPrcMin[1] += noround(aPrecos[1],2)
					aPrcMin[2] += noround(aPrecos[2],2)
					aPrcMin[3] += noround(aPrecos[3],2)
					aPrcMin[4] += noround(aPrecos[4],2)
					aPrcMin[5] += noround(aPrecos[5],2)
					aPrcMin[6] += noround(aPrecos[6],2)

					nValorHoje := 0
					nQtdeParc  := Len(aPrazos)
					For i := 1 To nQtdeParc
						nAux := ((aCols[_x][nPosVALOR]/Iif(!Empty(Alltrim(M->C5_ESPECI4)), 0.7, 1)) * aPrazos[i,2]) / ((1 + (nJuros / 100)) ^ ((12 * aPrazos[i,1]) / 365)) //* Iif(!Empty(Alltrim(M->C5_ESPECI4)), 2, 1)
						nValorHoje := nValorHoje + nAux
					Next

					//Valor do lucro+comissao da empresa no preco praticado do pedido.
					_nLucroItem := nValorHoje - ((aCols[_x][nPosVALOR]/Iif(!Empty(Alltrim(M->C5_ESPECI4)), 0.7, 1)) * (SB1->B1_PERINT / 100)) - (SB1->B1_CUSTOR * aCols[_x][nPosQTDVEN] ) - (_nBaseIcms * _nPercIcms / 100) - _nPisCof //* Iif(!Empty(Alltrim(M->C5_ESPECI4)), 2, 1)
					aCols[_x][nPosVlrLucr] := _nLucroItem*Iif(!Empty(Alltrim(M->C5_ESPECI4)), 0.7, 1) // Valor do Lucro + Comissão, p/ posterior apuração de lucro obtido por linha de prod

					_nValReal   := _nValReal + _nLucroItem

					//Media de Comissao e Lucro Minimo.
					If !lProdEstoque
						nAuxLucro := SB1->B1_LUCROM2
					Else
						nAuxLucro := SB1->B1_LCRMIN
					Endif
					_nMedComiss := _nMedComiss + (SB1->B1_COMIS * aCols[_x][nPosVALOR] / Iif(!Empty(Alltrim(M->C5_ESPECI4)), 0.7, 1))
					_nMedLucro  := _nMedLucro  + (nAuxLucro * aCols[_x][nPosVALOR] / Iif(!Empty(Alltrim(M->C5_ESPECI4)), 0.7, 1))

					//Descontos para produtos de estoque e Não Estoque
					//nQtdeParc = Len(aPrazos)
					nInd := 0
					For i := 1 To nQtdeParc
						nAux := (aPrazos[i,2]) / ((1 + (nJuros / 100)) ^ ((12 * aPrazos[i,1]) / 365))
						nInd := nInd + nAux
					Next
					nIndAnt     := (1 + (nJuros / 100)) ^ ((12 * 60) / 365) // 60 dias
					//nDesc1      := (nInd - (1 / nIndAnt) + (GETMV("MV_ICMPAD") / 100) - (_nPercIcms / 100)) / (nInd - nPerint - (nLC1 / 100) - (_nPercIcms / 100)) release 12.1.25
					nDesc1      := (nInd - (1 / nIndAnt) + (nICMPAD / 100) - (_nPercIcms / 100)) / (nInd - nPerint - (nLC1 / 100) - (_nPercIcms / 100))

					//nDesc2      := (nInd - (1 / nIndAnt) + (GETMV("MV_ICMPAD") / 100) - (_nPercIcms / 100)) / (nInd - nPerint - (nLC2 / 100) - (_nPercIcms / 100)) release 12.1.25
					nDesc2      := (nInd - (1 / nIndAnt) + (nICMPAD / 100) - (_nPercIcms / 100)) / (nInd - nPerint - (nLC2 / 100) - (_nPercIcms / 100))

					_nVlrCDesc  := nValTab * (1 - Iif(lProdEstoque, nDesc1, nDesc2)) // Somar vlr tabela c/ desconto p/ 60 dias em regioes de icms diferentes
					nSomaVlrTab += nValTab // _nVlrCDesc , a partir de 15/05/09 passou a aplicar descontos tendo ref. apenas a tabela 18%
					If (M->C5_TIPO = "N") .AND. (Len(Alltrim(aCols[_x][nPosPRODUTO])) == 12) .and. (((_nVlrCDesc / 1.165) > (aCols[_x][nPosPRCVEN] * aCols[_x][nPosQTDVEN] / Iif(!Empty(Alltrim(M->C5_ESPECI4)),0.7, 1))) .and. (_nLucroItem <= 0))
						cAux := "Valor para o produto "+Alltrim(aCols[_x][nPosPRODUTO])+" muito pequeno em relação à tabela!!! CONFIRA!"
						If (ValAtrib("l410Auto") <> "U" .and. !l410Auto)//release 12.1.25 If  ( Type("l410Auto") = "U" .or. !l410Auto )
							MsgBox(cAux, "Atenção", "STOP")
						else
							//ConOut(cAux)
							FwLogMSG( "WARN", , 'SIGAFAT', funname(), '', '01', cAux, 0 )
						endif
						if !(cAux $ cObs)
							cObs += chr(13)+chr(10)+cAux
						endif
					Endif
					If (M->C5_TIPO = "N") .AND. (nValUnTab > 0) .AND. (aCols[_x][nPosPRCVEN] > (nValUnTab*1.5) )
						cAux := "Valor para o produto "+Alltrim(aCols[_x][nPosPRODUTO])+" MUITO ALTO em relação à tabela!!! CONFIRA!"
						If (ValAtrib("l410Auto") <> "U" .and. !l410Auto) //release 12.1.25 If  ( Type("l410Auto") = "U" .or. !l410Auto )
							MsgBox(cAux, "Atenção", "STOP")
						else
							//ConOut(cAux)
							FwLogMSG( "WARN", , 'SIGAFAT', funname(), '', '01', cAux, 0 )
						endif
						if !(cAux $ cObs)
							cObs += chr(13)+chr(10)+cAux
						endif
					Endif
					//Chamado 018057, quantidades mínimas de venda para específicos
					//Caso não seja venda via MasterSales o bloqueio não está sendo feito porém alerta será colocado na Observação
					IF (M->C5_TIPO = "N")  
						IF !U_QtdMinProd(aCols[_x][nPosPRODUTO],aCols[_x][nPosQTDVEN])
							cAux := alltrim(aCols[_x][nPosPRODUTO])+", Qtde "+Alltrim(Str(aCols[_x][nPosQTDVEN]))+;
							",Valor "+cValToChar(aCols[_x][nPosPRCVEN])+" - QTDE ABAIXO DO MINIMO"
							If (ValAtrib("l410Auto") <> "U" .and. !l410Auto) //release 12.1.25 If  ( Type("l410Auto") = "U" .or. !l410Auto )
								MsgBox("Produto : "+cAux, "Atenção", "STOP")
							else
								//ConOut(cAux)
								FwLogMSG( "WARN", , 'SIGAFAT', funname(), '', '01', "Produto : "+cAux, 0 )
							endif
							if !(cAux $ cObs)
								cObs += chr(13)+chr(10)+"Produto : "+cAux
							endif
						ENDIF 
					ENDIF 
					//Definição de campanha de venda, chamado 020971
					if lCampanha
						dbselectarea("DA1")
						dbseek(xFilial("DA1")+cTabCampanha+aCols[_x][nPosPRODUTO])
						if !found()
							lCampanha := .f.
						else 
							if (aCols[_x][nPosPRCVEN] == 0.0) .or. (DA1->DA1_PRCVEN == 0.0)
								lCampanha := .f.
							else 
								if abs((aCols[_x][nPosPRCVEN] - DA1->DA1_PRCVEN)*100/DA1->DA1_PRCVEN) > 0.5
									lCampanha := .f.
								endif 
							endif 
						endif 
					endif 
				else
					lCampanha := .f. //Chamado 020971, campanhas de venda, se existir produto sem gerar financeiro então pedido não participa de campanha
				endif // FIM if SF4->F4_DUPLIC = 'S'
				//Se estiver com o valor do frete CIF do item já preenchido, não calcular frete CIF no final
				//pois pode se tratar de preenchimento automático no momento da liberação e essa é a deixa
				//para concluir o frete CIF.
				/*
				if lCalcFrete .and. (aCols[_x][nPosC6XVLRFRE] > 0.0)
				lCalcFrete := .f.
				endif */
			Else //Se for registro deletado

			Endif
		Next

		//Chamado 020971, campanha de vendas. Verificar se foi estabelecido valor mínimo de venda
		if lCampanha .AND. (DA0->DA0_PEDMIN > 0) .AND. (_nVlrTotDup < DA0->DA0_PEDMIN)
			lCampanha := .f.
			cAuxMens = "Pedido de Campanha abaixo do Vlr Mínimo!"
			If (ValAtrib("l410Auto") <> "U" .and. l410Auto) //release 12.1.25 if ( Type("l410Auto") <> "U" .And. l410Auto )
				FwLogMSG( "WARN", , 'SIGAFAT', funname(), '', '01', cAuxMens, 0 )
			else
				MsgBox(cAuxMens, "Atenção", "STOP")
			endif
		endif 

		if lSoSolventes .and. !lCampanha
			//Gravar que pedido possui solvente
			dbselectarea("SX5")
			dbseek(xFilial("SC5")+"96"+M->C5_NUM)
			IF !FOUND()
				reclock("SX5",.T.)
				SX5->X5_FILIAL := xFilial("SC5")
				SX5->X5_TABELA := "96"
				SX5->X5_CHAVE := M->C5_NUM 
			ELSE
				reclock("SX5",.F.)
			ENDIF 
			SX5->X5_DESCRI := "S"
			SX5->X5_DESCSPA := "S"
			SX5->X5_DESCENG := "S"
			msunlock()
		ENDIF 

		if (cUf != "EX") .AND. (nContItens > 150)
			//lRet = .f.
			cAuxMens = "Qtde de Itens maior que 150! Poderá não ser possível a transmissão da NFe!"
			If (ValAtrib("l410Auto") <> "U" .and. l410Auto) //release 12.1.25 if ( Type("l410Auto") <> "U" .And. l410Auto )
				//ConOut(cAuxMens)
				/*** Substituido em 08/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
				FwLogMSG( "WARN", , 'SIGAFAT', funname(), '', '01', cAuxMens, 0 )
			else
				MsgBox(cAuxMens, "Atenção", "STOP")
			endif
		endif
		if lRet .and. empty(cDeposito)
			cDeposito := "N"
		endif
		//if (substr(_cNumEmp,1,2) == "01") .and. (_cNumEmp != "01010106") .and. (_cNumEmp != "01010107")
		M->C5_DEPOSI := cDeposito
		//endif

		//Solic. Cleiton em 15/10/14, enviar e-mail p/ Caio e Eliana caso sejam vendidos produtos com quebra de volume na Dissoltex
		if !empty(cProdsVolQuebr)
			M->C5_VOLQUEB := "S"
			if (_cFilial = "060101") //Enviar email qdo for Dissoltex
				cAuxMens := "Os seguintes produtos foram vendidos em volumes incompletos na Dissotex: "+chr(13)+chr(10) +cProdsVolQuebr+;
				chr(13)+chr(10)+"Usuário que incluiu/alterou o pedido: "+rtrim(cUserName)+;
				chr(13)+chr(10)+"Nro do Pedido: "+M->C5_NUM+;
				CHR(13)+CHR(10)+"Cliente: "+M->C5_CLIENTE+"-"+SA1->A1_NOME
				U_EnvMail("DISSOLTEX - Pedido "+M->C5_NUM+" vendido com VOLUMES INCOMPLETOS" ,cAuxMens,"caio@brasilux.com.br","eliana@brasilux.com.br","")
			Endif
		Endif

		//Solic. Michelly em 07/10/2015 -> Enviar email pro Ramon quando o pedido tiver marcado para acompanhar laudo
		IF (_cNumEmp == "01010101") .and. (M->C5_LAUDO = "S")
			cAuxMens := "O Pedido nro "+M->C5_NUM+", CLIENTE : "+M->C5_CLIENTE+"-"+ ALLTRIM(IIF(M->C5_TIPO $ "D_B",SA2->A2_NOME,SA1->A1_NOME))+;
			" acompanha LAUDO!"
			U_EnvMail("Pedido "+M->C5_NUM+" possui laudo" ,cAuxMens,"faturamento@brasilux.com.br","")
		ENDIF

		//Enviar e-mail para grupo de Materiais quando houver itens específicos no pedido com alternativa de produto de estoque
		/* Michelly solicitou desativação desse email em 07/05/2021
		IF (_cNumEmp = "01010101") .and. !empty(cProdEsp)
			U_EnvMail("Pedido "+M->C5_NUM+" com Prod Específico com Alternativa de Estoque" ,cProdEsp,"materiais@brasilux.com.br")
		ENDIF
		*/
		
		//Checar se existe item de estoque misturado com Não estoque(23/06/20)
		if nContItens == 1
			lMudouEst :=  lProdEstoque
		else 
			if !lMisturado .and. (lProdEstoque <> lMudouEst)
				lMisturado := .t.
			endif 
		endif 

		//Cleber (18/01/07)
		//Eliana pediu p/ não mais bloquear pedidos c/ itens misturados!!
		//
		/*
		lMisturado := .f. // Marca se existem produtos de Estoque Misturados c/ produtos Não Estoque
		lProdEstoque := .f.
		nContItens := 0
		For _x := 1 to Len(aCols)
		If !aCols[_x][Len(aHeader)+1] //Se não for registro deletado
		lAux = .f.
		nContItens++
		if len(alltrim(aCols[_x][nPosProduto])) == 12
		dbselectarea(cCursorTemp)
		dbseek(substr(aCols[_x][nPosProduto],1,10),.t.)
		if found() .and. ( (cCursorTemp)->VOLUME >= 57 )
		lAux = .t.
		endif
		endif
		if !lAux
		DbSelectArea("SB1") //Produtos
		DbSeek(xFilial("SB1")+aCols[_x][nPosProduto])
		If Found()
		lAux = iif((SB1->B1_ESTOQUE = "S"),.t.,.f.)
		endif
		endif
		IF (nContItens > 1) .AND. !lMisturado .AND. (lAux != lProdEstoque)
		lMisturado = .t.
		exit
		endif
		lProdEstoque := lAux
		endif
		next */

		//Qtde de Volumes à partir de vetor gerado e/ou Volume Total Gerado
		lCalcVol := .t.
		if lRet
			if !INCLUI
				cQry1 := "DELETE FROM "+retsqlname("ZZO")+" WHERE (ZZO_FILIAL = '"+xFilial("ZZO")+"') AND (ZZO_PEDIDO = '"+M->C5_NUM+"')"
				lRet := (TcSQLExec(cQry1) >= 0)
				If !lRet
					MsgStop(TcSqlError())
					//DisarmTrans()
				Endif 

			else
				dbselectarea("ZZO")
				dbseek(xFilial("ZZO")+M->C5_NUM)
				if found()
					cMensErro := "Cálculo de VOLUMES ficará errado! Salve novamente o PEDIDO!!"
					If (ValAtrib("l410Auto") <> "U" .and. l410Auto) //release 12.1.25 if ( Type("l410Auto") <> "U" .And. l410Auto )
						//ConOut(cMensErro)
						FwLogMSG( "INFO", , 'SIGAFAT', FunName(), '', '01', cMensErro, 0 )
					else
						MsgBox(cMensErro, "Atenção", "STOP")
					endif
					lCalcVol := .f.
					M->C5_NAOCONF := "S"
					if !empty(cObs)
						cObs += chr(13)+chr(10)
					endif
					cObs += cMensErro

				endif
			endif
		endif
		nCubagem := 0
		if lRet .and. lCalcVol
			For i := 1 to Len(aEmba)
				nQtdeVol := aEmba[i][4]
				if lRet .and. (aEmba[i][5] > 0)
					lRet := U_volcompl(aEmba[i][6], aEmba[i][5])
					if !lRet
						cMensErro := "Pedido não fecha volumes devido a BL!"
						If (ValAtrib("l410Auto") <> "U" .and. l410Auto) //release 12.1.25 If ( Type("l410Auto") <> "U" .And. l410Auto )
							//ConOut(cMensErro)
							FwLogMSG( "INFO", , 'SIGAFAT', FunName(), '', '01', cMensErro, 0 )
						else
							MsgBox(cMensErro, "Atenção", "STOP")
						endif
						exit
					endif
				endif
				If aEmba[i][3] > 0
					nQtdeVol += U_DetVolEmba(aEmba[i][6], aEmba[i][3])
				Endif
				nVolTotal += nQtdeVol
				dbselectarea("ZZO")
				dbseek(xFilial("ZZO")+M->C5_NUM+aEmba[i][1])
				if !found()
					reclock("ZZO",.t.)
					ZZO->ZZO_FILIAL := xFilial("ZZO")
					ZZO->ZZO_PEDIDO := M->C5_NUM
					ZZO->ZZO_EMBA := aEmba[i][1]
				else
					reclock("ZZO",.f.)
				endif
				ZZO->ZZO_QTDE += aEmba[i][2]
				ZZO->ZZO_QTDVOL += nQtdeVol
				ZZO->ZZO_CUBAGE += aEmba[i][7]
				msunlock()
				nCubagem += aEmba[i][7]
			Next
		endif
		If (nCubagem > 0)
			M->C5_VOLUME2 := nCubagem
		Endif
		/*
		//ATENÇÃO!!! SE SALVAR C5_ESPECI2 O PROGRAMA NFESEFAZ IRÁ SOMAR AO TOTAL DE VOLUMES A QTDE DE C5_VOLUME2!!
		If Empty(M->C5_ESPECI2) .AND. (nCubagem > 0)
		M->C5_ESPECI2 := "CUBAGEM"
		Endif
		*/
		if cUf = "EX" //Exportação não paga comissão
			_nMedComiss := 0
		endif

		// % de lucro obtido
		if _nVlrTotDup > 0
			_nMedComiss := _nMedComiss / _nVlrTotDup
			_nMedLucro  := _nMedLucro / _nVlrTotDup
			_nLucroCal  := ((_nValReal - (_nVlrTotDup * (_nMedComiss / 100))) / _nVlrTotDup) * 100

			// Gerente de Vendedor, comissão de 1%
			M->C5_COMIS2 := iif(!empty(alltrim(M->C5_VEND2)),1,0) // 1% DE COMISSÃO P/ GERENTE, CASO EXISTA.
		else
			_nLucroCal := 0
			_nMedComiss := 0
			_nMedLucro  := 0
			_nLucroCal  := 0
			M->C5_COMIS2 := 0
		endif

		// À partir de 01/03/06 todos participam de comissão fixa 5%
		lSisRev     := .f. // Participa de pol. nova para revenda?
		if cUf = "EX" //Exportação nao participa de compensação, não há comissionamento!
			M->C5_COMPENS := "N" // Não participa de compensação de comissão!
			lSisRev       := .f.
		else
			If !(M->C5_TIPO $ "D_B") // .AND. (SA1->A1_CLAS == "V")
				IF Empty(M->C5_VEND1) .AND. !EMPTY(SA1->A1_VEND)
					M->C5_VEND1 := SA1->A1_VEND
				ENDIF 
				IF !EMPTY(M->C5_VEND1)
					DbSelectArea("SA3")
					DbSeek(xFilial("SA3")+M->C5_VEND1)
					If Found() 
						IF (SA3->A3_SISREV == "S") .AND. !lCampanha .AND. (SA3->A3_COMIS <= 0.0) // Se o representante aderiu à política de revenda, 5% fixos de comissão.  Chamado 020971, verificar campanha de venda. Chamado 024740, verificar comissão fixa
							M->C5_COMPENS := "S" // Participa de compensação de comissão!
							lSisRev       := .t.
						ENDIF 
						//Chamado 024740, definir comissão fixa. Combinado que quando o cadastro do representante contiver percentual de comissão então a mesma será fixa
						IF !lSoSolventes .AND. (SA3->A3_COMIS > 0.0)  //Pedidos de solventes não participam de comissão fixa
							M->C5_XCONF := .T. //Comissão fixa
							lSisRev := .f.
						ENDIF 
					Endif
				ENDIF
			Endif
		endif


		// Gravar desconto aplicado sobre o geral de tabela. Solic. Eliana em Fev/2008
		M->C5_DESCON4 := IIF(nSomaVlrTab > 0,ROUND((1-(_nVlrTotDup/nSomaVlrTab))*100,2),0)

		// Se o lucro da empresa praticado no preco do pedido for menor que o Lucro Minimo
		// abate esta diferenca da comissao do representante.
		If (_nLucroCal >= _nMedLucro) 
			_nComisCal := _nMedComiss
		Else
			_nLucroCal   := _nMedLucro
			_nComisCal   := iif(_nVlrTotDup <= 0,0,((_nValReal - ((_nLucroCal * _nVlrTotDup) / 100)) / _nVlrTotDup) * 100)
			// aCols[_x,16] := _nComisCal
		Endif
		lDescOk       := .t.
		//     M->C5_NAOCONF := "N"



		//Política padrão de comissionamento
		If lSisRev .and. lRet .and. (M->C5_TIPO =  "N")
			cQry1 := "SELECT SUM(C6_VALOR/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1.0 END)) AS SALDO "+;
			"FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "+;
			"LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C6_FILIAL = C5_FILIAL) AND (C6_NUM = C5_NUM) "+;
			"LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (F4_CODIGO = C6_TES) "+;
			"WHERE (SC6.D_E_L_E_T_ <> '*') AND (C6_FILIAL = '"+xFilial("SC6")+"') AND (C5_CLIENTE = '"+M->C5_CLIENTE+"') "+;
			"AND (C6_NUM <> '"+M->C5_NUM+"') AND (C5_EMISSAO LIKE '"+SUBSTR(DTOS(M->C5_EMISSAO),1,6)+"%') AND (C5_EMISSAO <= '"+DTOS(M->C5_EMISSAO)+"') AND "+;
			"(C5_TIPO NOT IN ('D','B')) AND ((F4_DUPLIC = 'S') OR (C6_TES = '519'))"
			IF !INCLUI //Considerar registros anteriores apenas para manter regra
				cQry1 += " AND (SC5.R_E_C_N_O_ < "+alltrim(str( SC5->(Recno()) ))+")"
			ENDIF
			TCQuery cQry1 ALIAS "TCQSLD" NEW
			DBSELECTAREA("TCQSLD")
			if !eof() .and. !bof()
				nSaldoVend := TCQSLD->SALDO
			else
				nSaldoVend := 0
			endif
			DBSELECTAREA("TCQSLD")
			dbclosearea()
			nSaldoVend += _nVlrTotDup
			_nVlrTotMin := 750 // Fev/2017 mudou de 450 para 750

			IF  (M->C5_TIPO = 'N')
				If (nPrazoMedio > 75) .and. (_nComisCal < _nMedComiss) // Prazo máximo 60 dias porém coloquei 65 como forma de tolerância para vencimentos reais maiores. (10/09/21)-> Caio pediu pra colocar 75 dias em off!!
					lProblPrazo := .t. //Não respeita prazo mínimo!!
					lDescOk := .f.
				else
					nTolerancia := 0.005
					do case
						case nSaldoVend < 750
						lDescOk := .f.
						case nSaldoVend <= 3000
						_nVlrTotMin := aPrcMin[1]

						case nSaldoVend <= 5000
						_nVlrTotMin := aPrcMin[2]

						case nSaldoVend <= 8000
						_nVlrTotMin := aPrcMin[3]

						case nSaldoVend <= 11000
						_nVlrTotMin := aPrcMin[4]

						case nSaldoVend <= 15000
						_nVlrTotMin := aPrcMin[5]

						otherwise
						_nVlrTotMin := aPrcMin[6]

					endcase
					If _nVlrTotDup < _nVlrTotMin
						//M->C5_DESCON4 := IIF(nSomaVlrTab > 0,ROUND((1-(_nVlrTotDup/nSomaVlrTab))*100,2),0)
						nDescPerm := IIF(nSomaVlrTab > 0,ROUND((1-(_nVlrTotMin/nSomaVlrTab))*100,2),0)
						if (M->C5_DESCON4 - nDescPerm) > (nTolerancia*100)
							lDescOk := .f.
						endif
						/*
						If ((_nVlrTotMin - _nVlrTotDup) / _nVlrTotMin) > nTolerancia // Se distorção maior que tolerancia
						lDescOk := .f.
						Endif
						*/
					Endif

				endif
			endif

			//Ajusta comissão Fixa
			If (_nComisCal > _nMedComiss) .OR. lDescOk
				_nComisCal := _nMedComiss
			Endif

			//Não permitir que comissão seja maior que 5%, por segurança (30/10/09) => Cleber
			if _nComisCal > 5
				_nComisCal := 5
			endif

			if  (M->C5_TIPO = 'N') .and. lSoSolventes .and. !lDescOk .and. (_nVlrTotDup > 0) // .AND. !lProblPrazo //Permissão de desconto adicional para as linhas 71,10 - solventes
				//Chamado 004437(Eliana) em que solicita que se aplique desconto máximo independente do valor vendido
				_nVlrTotMin := aPrcMin[6]
				if _nVlrTotMin <= _nVlrTotDup
					_nComisCal := 5
					lDescOk := .t.
				else 
					nAux := _nVlrTotMin*0.95
					if nAux <= _nVlrTotDup
						_nComisCal := 4
						lDescOk := .t.
					else
						nAux := nAux*0.95
						if nAux <= _nVlrTotDup
							_nComisCal := 3
							lDescOk := .t.
						else
							nAux := nAux*0.95
							if nAux <= _nVlrTotDup
								_nComisCal := 2
								lDescOk := .t.
							else
								nAux := nAux*0.95
								if nAux <= _nVlrTotDup
									_nComisCal := 1
									lDescOk := .t.
								/*
								else
									nAux := nAux*0.95
									if nAux <= _nVlrTotDup
										_nComisCal := 0
										lDescOk := .t.
									endif
								*/
								endif
							endif
						endif
					endif
				endif 
			endif


			if _nVlrTotDup > 0
				_nLucroCal := ((_nValReal - (((_nComisCal + M->C5_COMIS2) * _nVlrTotDup) / 100)) / _nVlrTotDup) * 100
			else
				_nLucroCal := 0
			endif

			//Marcar pedido, caso não esteja em conformidade com a política p/ revenda. Desconsiderar depósito fechado
			if !lDescOk .and. lGeraDup .and. (_cNumEmp != "01010106") .and. (_cNumEmp != "01010107")
				//Cleber (27/11/2013) => Eliana pediu pra não mais bloquear pedidos por probl. pol. vendas
				//M->C5_NAOCONF := "S"
			endif
			If !lDescOk .and. (M->C5_NAOCONF = "S")
				cMensErro := "Atencao! Pedido "+M->C5_NUM+" NAO RESPEITA as Politicas Comerciais Para Revenda!"
				If (ValAtrib("l410Auto") <> "U" .and. l410Auto) //release 12.1.25 if ( Type("l410Auto") <> "U" .And. l410Auto )
					//ConOut(cMensErro)
					FwLogMSG( "WARN", , 'SIGAFAT', FunName(), '', '01', cMensErro, 0 )
				else
					MsgBox(cMensErro, "Atenção", "STOP")
				endif
			Endif
		else // If lSisRev .and. lRet .and. (M->C5_TIPO =  "N")
			if (_nComisCal < 0) .and. lGeraDup .and. !(alltrim(_cNumEmp) $ "01010106-01010107")
				//Cleber (27/11/2013) => Eliana pediu pra não mais bloquear pedidos por probl. pol. vendas
				//M->C5_NAOCONF := "S"
			endif

		Endif //Fim if lSisRev

		//Chamado 020971, campanha de vendas
		if lCampanha .and. !empty(cTabCampanha)
			dbselectarea("DA0")
			dbseek(xFilial("DA0")+cTabCampanha)
			if found() .and. (DA0->DA0_COMIS > 0)
				_nComisCal := DA0->DA0_COMIS
			else
				_nComisCal := 1 //Por precaução colocar 1% que é a comissão mínima
			endif 
			M->C5_XCONF := .T. //Comissão fixa
		endif 
		//Chamado 024740, definir comissão fixa. Combinado que quando o cadastro do representante contiver percentual de comissão então a mesma será fixa
		if !lCampanha .and. M->C5_XCONF 
			_nComisCal := SA3->A3_COMIS
		endif 
		IF M->C5_XCONF
			_nMedComiss := _nComisCal //Fixar comissão padrão igual à comissão de campanha ou igual à cadastrada em SA3
			if _nVlrTotDup > 0
				_nLucroCal := ((_nValReal - (((_nComisCal + M->C5_COMIS2) * _nVlrTotDup) / 100)) / _nVlrTotDup) * 100
			else
				_nLucroCal := 0
			endif
		ENDIF 

		dbselectarea("DA0")
		dbgotop()
		/*
		//Cleber (23/06/20) -> Apenas complementar a Obs quando houver itens de estoque misturado
		IF (M->C5_NAOCONF != "S") .and. lMisturado
			M->C5_NAOCONF := "S"
			cMensErro := "Atencao! Pedido "+M->C5_NUM+" possui itens de Estoque Misturados aos itens Não Estoque!"
			If (ValAtrib("l410Auto") <> "U" .and. l410Auto) //release 12.1.25 if ( Type("l410Auto") <> "U" .And. l410Auto )
				//ConOut(cMensErro)
				FwLogMSG( "INFO", , 'SIGAFAT', FunName(), '', '01', cMensErro, 0 )
			else
				MsgBox(cMensErro, "Atenção", "STOP")
			endif
		endif
		*/
		if lMisturado .AND. (M->C5_TIPO = 'N') .AND. (_nVlrTotDup > 0)
			cAux := "Atencao! Pedido "+M->C5_NUM+" possui itens de Estoque Misturados aos itens Não Estoque!"
			/*
			if !(cAux $ cObs)
				cObs += chr(13)+chr(10)+cAux
			endif 
			*/
		endif 

		IF !(M->C5_TIPO = "N")
			M->C5_NAOCONF := "N"
		ENDIF

		// Recalcula comissao.
		IF _nVlrTotDup == 0 //Se o pedido não tiver financeiro zerar comissão
			_nComisCal := 0
		ENDIF 
		_nPorcComiss := _nComisCal //Se o pedido não tiver financeiro zerar comissão
		M->C5_PORCOM  := _nPorcComiss //Cleber(03/08/21)->Eliana pediu para mostrar a comissão realizada para poder ter parâmetros de aprovação. Como foi acertado no MasterSales para passar a mostrar C5_COMIS1 então estou deixando C5_PORCOM como informativo apenas
		if (M->C5_TIPO = "N") .AND. (_nVlrTotDup > 0) .AND. (_nComisCal < 1)
			_nComisCal := 1.0 //Nova política de comissionamento, não deverá ser menor que 1%
			_nPorcComiss := _nComisCal
			_nLucroCal := ((_nValReal - (((_nComisCal + M->C5_COMIS2) * _nVlrTotDup) / 100)) / _nVlrTotDup) * 100
		endif 

		_nVlrComiss  := _nVlrTotDup * _nComisCal * Iif(!Empty(Alltrim(M->C5_ESPECI4)), 0.7, 1)/ 100
		// Calcula Lucro da empresa.
		_nVlrLucro   := _nVlrTotDup * _nLucroCal * Iif(!Empty(Alltrim(M->C5_ESPECI4)), 0.7, 1) / 100
		_nPorcLucro  := _nLucroCal
		//Atualiza variaveis do pedido.
		IF _nVlrTotDup == 0
			_nPorcComiss := 0
		ENDIF 
		M->C5_COMIS1  := _nPorcComiss
		M->C5_VLRCOM  := _nVlrComiss
		M->C5_LUCRO   := _nPorcLucro
		M->C5_MEDCOM  := _nMedComiss
		M->C5_MEDLUCR := _nMedLucro
		If nPesoLiquTotal > 0
			M->C5_PESOL := nPesoLiquTotal
		Endif
		If (nPesoBrutTotal > 0)
			M->C5_PBRUTO := nPesoBrutTotal
		Endif
		If M->C5_PBRUTO < M->C5_PESOL
			M->C5_PBRUTO := M->C5_PESOL
		Endif
		If (nVolTotal > 0) .and. lCalcVol
			M->C5_VOLUME1 := nVolTotal
		Endif
		If Empty(M->C5_ESPECI1) .AND. (M->C5_VOLUME1 > 0)
			M->C5_ESPECI1 := "VOLUME"
		Endif
		If Empty(M->C5_ESPECI3)
			M->C5_ESPECI3 := "VOLUME"
		Endif
		//Identificação de quem está incluindo/alterando o pedido
		If INCLUI .OR. EMPTY(M->C5_CAD)
			M->C5_CAD   := Iif(!Empty(M->C5_PEDREPR) .OR. !EMPTY(M->C5_X_PVSIM), M->C5_VEND1, rtrim(cUserName))
			M->C5_DTCAD := dDataBase
			M->C5_FLAG  := "N" // Flag informando que o pedido não foi impresso
		Endif
		IF !EMPTY(M->C5_X_PVSIM) .AND. ((M->C5_TIPOVEN <> "E") .OR. (M->C5_CAD <> M->C5_VEND1))
			M->C5_CAD := M->C5_VEND1
			M->C5_TIPOVEN := "E"
		ENDIF

		M->C5_ALT    := rtrim(cUserName)
		M->C5_DTALT  := dDataBase
		M->C5_ALTERAD := "S"
		If (M->C5_TIPO <> 'N') .OR. (substr(cCnpj,1,8) == SUBSTR(alltrim(SM0->M0_CGC),1,8))
			M->C5_LIBCAD := 'T'
			M->C5_USRCAD := rtrim(cUserName)
			M->C5_LIBPED := 'T'
			M->C5_USRPED := rtrim(cUserName)
			IF !lGeraDup
				M->C5_LIBCRE := 'T'
				M->C5_USRCRE := rtrim(cUserName)
				M->C5_LIBDIR := 'T'
				M->C5_USRDIR := rtrim(cUserName)
				IF M->C5_APROVA <> "1"
					M->C5_APROVA := "1"
					M->C5_DTAPR := dDataBase
					M->C5_SUGENT := dDataBase+1
				ENDIF
				M->C5_USRAPR := rtrim(cUserName)
			ENDIF
		Else
			M->C5_LIBPED := 'F'
			M->C5_USRPED := ""
			IF INCLUI .OR. (!INCLUI .AND. (ROUND(_nVlrTotDup*Iif(!Empty(Alltrim(M->C5_ESPECI4)), 0.7, 1),2) != M->C5_VLRDUP))
				M->C5_LIBCRE := 'F'
				M->C5_USRCRE := ""
			ENDIF
			M->C5_LIBDIR := 'F'
			M->C5_USRDIR := ""
			IF INCLUI .OR. (!INCLUI .AND. (M->C5_APROVA <> '2'))
				M->C5_APROVA := "0"
				M->C5_SUGENT := CTOD(SPACE(8))
				M->C5_DTAPR := CTOD(SPACE(8))
			ENDIF
			M->C5_USRAPR := ""
		Endif
		M->C5_VLRDUP := ROUND(_nVlrTotDup*Iif(!Empty(Alltrim(M->C5_ESPECI4)), 0.7, 1),2)

		//Itens de IPI Zero Misturados com itens de IPI maior que zero. Chamado 007956. Relacionado a clientes Suframa
		if lIpiZeroM .AND. (M->C5_TIPO = "N") .AND. (_nVlrTotDup > 0.0) .AND. !EMPTY(SA1->A1_SUFRAMA) .AND. ((SA1->A1_CALCSUF = "N") .OR. EMPTY(SA1->A1_CALCSUF)) .AND. EMPTY(SA1->A1_CODMUN)
			cAux := "*Pedido possui item(ns) com IPI zero misturado com item(ns) de IPI maior que zero*"
			if !(cAux $ cObs)
				cObs += chr(13)+chr(10)+cAux
			endif
		endif

		M->C5_TIPLIB := '2' //Garantir que seja liberado por pedido e não por item

		//25/04/16 -> Cleber - Atualizar campo C5_SUGENT (Dt. Sugestão de Entrega) com o valor da data programada para entrega
		IF !EMPTY(M->C5_PEDPROG) .AND. !(M->C5_SUGENT == M->C5_PEDPROG)
			M->C5_SUGENT := M->C5_PEDPROG
		ENDIF
		//Atualizar prazo de entrega (em dias úteis)
		M->C5_ENTREGA := nEntrega

		//Grava log de inclusao / alteração do pedido
		if lRet
			RecLock("ZZB", .t.)
			ZZB->ZZB_FILIAL := xFilial("ZZB")
			ZZB->ZZB_PEDIDO := M->C5_NUM
			ZZB->ZZB_IDLOG  := iif(INCLUI, 'INC', 'ALT')
			ZZB->ZZB_USRLOG := rtrim(cUserName)
			ZZB->ZZB_DATLOG := dDataBase
			ZZB->ZZB_HORLOG := Time()
			MsUnLock()
		endif

		//Cleber(09/01/19) -> Uso cálculo Frete CIF
		//nVlrTot := Ma410Impos(3,.T.) // Cálculo do valor total da NF
		IF (M->C5_TIPO = "N") .AND. (M->C5_TPFRETE = "C") // .AND. !EMPTY(M->C5_REDESP) //.AND. lCalcFrete
			M->C5_COMPENS := "N" //Não participa de compensação de comissão
			cTrpBrz := "00250 " //Transp. para cálc frete Brasilux
			dbselectarea("Z15")
			dbsetorder(1)
			dbseek(xFilial("Z15")+cTrpBrz+SA1->A1_CODCID)
			IF !FOUND()
				M->C5_XVLRFRE := 0.0
			ELSE
				IF !Empty(Alltrim(M->C5_ESPECI4))
					M->C5_XVLRFRE := 0.0
					M->C5_TPFRETE := "F"
					nPos1 := AT("<CIF>",cObs)
					if nPos1 > 0
						nPos2 := AT("<CIF>",cObs,nPos1+5)
						cAux := substr(cObs,1,nPos1-1)+substr(cObs,nPos2+5,len(cObs)-nPos2-4)
						cObs := cAux
					endif
					cAuxMens := "Linha 70 NÃO PODE TER FRETE CIF!!"
					If (ValAtrib("l410Auto") <> "U" .and. l410Auto) //release 12.1.25 if ( Type("l410Auto") <> "U" .And. l410Auto )
						//ConOut(cAuxMens) release 12.1.25
						FwLogMSG( "WARN", , 'SIGAFAT', FunName(), '', '01', cAuxMens, 0 )
					else
						MsgBox(cAuxMens, "Atenção", "STOP")
					endif
					cObs += "<CIF>"+cAuxMens+"<CIF>"
				ELSE
					nVlrTot := Ma410Impos(3,.T.) // Cálculo do valor total da NF

					//Varrer transportadoras para ver qual a que tem menor frete
					nAux := 9999999.9
					dbselectarea("SA4")
					dbsetorder(1)
					dbselectarea("Z15")
					DbOrderNickName("Z15CID")
					dbseek(xFilial("Z15")+SA1->A1_CODCID)
					do while !eof() .and. (Z15->Z15_FILIAL == xFilial("Z15")) .AND. (Z15->Z15_CODCID == SA1->A1_CODCID)
						nVlrFrete := 0.0
						nPercFrete := Z15->Z15_ADVALO
						nVlrFrete += Z15->Z15_VLRFPE
						IF M->C5_PBRUTO > Z15->Z15_PESLIM
							nVlrFrete += Z15->Z15_VLREXC*(M->C5_PBRUTO - Z15->Z15_PESLIM)
						ENDIF
						dbselectarea("SA4")
						dbseek(xFilial("SA4")+Z15->Z15_CODTRA)
						if found()
							nPercFrete += SA4->A4_FREPERC
							nVlrFrete += M->C5_PBRUTO*SA4->A4_FREPED
							nVlrFrete += SA4->A4_FRETX
						endif
						nVlrFrete += (nPercFrete*nVlrTot/100.0)
						if (SA4->(FieldPos("A4_ICMFRET")) > 0)
							IF SA4->A4_ICMFRET > 0.0
								nVlrFrete := round(nVlrFrete/SA4->A4_ICMFRET,2) // Indice de icms de frete. Por ex., se for agregar 7% então A4_ICMFRET será 0.93
							ENDIF
						endif

						IF Z15->Z15_CODTRA = cTrpBrz
							M->C5_XVLRFRE := nVlrFrete
							nPos1 := AT("<CIF>",cObs)
							if nPos1 > 0
								nPos2 := AT("<CIF>",cObs,nPos1+5)
								cAux := substr(cObs,1,nPos1-1)+substr(cObs,nPos2+5,len(cObs)-nPos2-4)
								cObs := cAux
							endif
							cObs += "<CIF>Valor do Frete CIF: "+TRANSFORM(nVlrFrete, "@E 999,999.99") +"<CIF>"
						ELSE
							if nAux >= nVlrFrete
								M->C5_REDESP := Z15->Z15_CODTRA
								nAux := nVlrFrete
							endif
						ENDIF
						dbselectarea("Z15")
						dbskip()
					enddo
				ENDIF
			ENDIF
		ENDIF

		M->C5_OBS := cObs

		dbselectarea(cCursorTemp)
		dbclosearea()
		oTempTable:Delete()
/*
		aEval(Directory("tmp*.dtc"), { |aFile| FERASE(aFile[F_NAME]) })
		aEval(Directory("tmp*.cdx"), { |aFile| FERASE(aFile[F_NAME]) })
*/		
	Endif
	U_VoltaArea(aArea)
	If !empty(cArea)
		DbSelectArea(cArea)
	Endif
Return(lRet)

Static Function DetCubagem(cProd)
	Local nRet,cQuery,cCursor
	cCursor := U_NovoCursor()
	cQuery := "SELECT ISNULL(SUM(B1_ESP05),0) AS CUBAGEM FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "+;
	"LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = '"+xFilial("SB1")+"') AND (B1_COD = G1_COMP) "+;
	"WHERE (SG1.D_E_L_E_T_ <> '*') AND (G1_FILIAL = '"+xFilial("SG1")+"') AND (G1_COD = '"+alltrim(cProd)+"') "
	TCQuery cQuery NEW ALIAS (cCursor)
	nRet := (cCursor)->CUBAGEM
	dbSelectArea(cCursor)
	dbclosearea()
	if nRet <= 0
		cQuery := "SELECT ISNULL(B1_ESP05,0) AS CUBAGEM FROM "+RetSqlName("SB1")+" WITH (NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND (B1_FILIAL = '"+xFilial("SB1")+"') AND (B1_COD = '"+cProd+"')"
		TCQuery cQuery NEW ALIAS (cCursor)
		nRet := (cCursor)->CUBAGEM
		dbSelectArea(cCursor)
		dbclosearea()
	endif
return(nRet)


static Function ValAtrib(atributo)
Return (type(atributo) )

//Função p/ Brasilux que verifica se cond. for menor que 7 dias então considera cond à vista (001)
Static Function EhAvista(_cCond)
Local _cArea := Alias()
Local aAreaAnt := U_PegaArea({"SE4"})
Local _cRet
_cRet := _cCond
		DbSelectArea("SE4")  // Condição de Pagamento
		DbSetOrder(1)
		DbSeek(xFilial("SE4")+_cCond)
		IF Found() // Cria vetor com prazos de pagamento
			//Cleber(24/07/18) Solicitação Eliana, chamado 010813 -> pedidos com cond. pgto até 7 dias calcular comissão como se fosse à vista
			IF (SE4->E4_TIPO = "1") .AND. (LEN((ALLTRIM(SE4->E4_COND))) == 1)
				IF VAL(ALLTRIM(SE4->E4_COND)) <= 7
					_cRet := "001"
				ENDIF
			ENDIF
		ENDIF 
U_VoltaArea(aAreaAnt)
if !empty(_cArea)
   dbSelectArea(_cArea)
endif 

return(_cRet)
