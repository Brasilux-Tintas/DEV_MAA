#INCLUDE "PROTHEUS.CH"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PES011A2  ³ Autor ³FSW TOTVS CASCAVEL     ³ Data ³ 19/10/2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ponto de Entrada genérico no WebService WSSIM3G_PEDIDOVENDA  ³±±
±±³          ³ IMPORTACAO DE PEDIDOS MASTERSALES (Wealth Systems)           ³±±
±±³          ³ Possibilita validação antes de processar e alteração dos     ³±±
±±³          ³ vetores aCABEC e aITENS do MsExecAuto()                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³PARAMIXB[1]: identifica a origem da chamada do PE, sendo:     ³±±
±±³          ³"VLDANTES", "ACABEC", "AITEM", "ANTESPEDIDO", "APOSPEDIDO"    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TOTVS CASCAVEL            B1                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//25/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function PES011A2()

Local cOrigem := alltrim(Upper( PARAMIXB[1] ))
	Local cArea      := Alias()
	Local aAreaAnt := U_PegaArea({"SA1","SA3","SB1","SA4","SC5"})
	Local xRet  	:= .T.
	Local aItensAux  := {} 	// Vetor auxiliar que conterá os itens válidos do pedido
	Local cObsPedido := "" 	// Variável para a observação com os itens excluídos
	Local lProdExcluido  := .F.	// Indica se um item será excluído
	Local i,cRepres,cBco,cCodCli,cLojaCli,cProd,nQtde,cAux,nValor,nQtdItens,cObsAntes,cAuxTrans,cMens
	Local _cGrpEmp,_cFilial,_cNumEmp,_cFilPed,dEmissao,_cDep,_cPvsim
     u_zcfga01( 'PES011A2' ) //LGS#2021201 - Gravação de log de utilização da rotina
	_cGrpEmp := ALLTRIM(FWGrpCompany())
	_cFilial := FWCodFil()
	_cNumEmp := _cGrpEmp+alltrim(_cFilial)
	_cFilPed := ""
	DbSelectarea("SA3")
	DbSetOrder(1)
	DbSelectarea("SA4")
	DbSetOrder(1)
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSelectArea("SB1")
	DbSetOrder(1)
	dbselectarea("SC5")
	DbOrderNickName("PVSIM") //C5_X_PVSIM
	nQtdItens := 1

DO CASE 


CASE cOrigem == "ANTESPEDIDO"
		nQtdItens := 0
		//conout('PES011A2 - ANTESPEDIDO') release 12.1.25
		cMens := 'PES011A2 - ANTESPEDIDO'
		FwLogMSG( "INFO", , 'SIGAFAT', funname(), '', '01', cMens, 0 )
		//*************************************************************************************
		// Primeira parte: validações gerais para permitir ou não a inclusão do pedido
		// Retornar .F. para não permitir e indicar uma mensagem na variável PRIVATE cMsgVldPE
		//*************************************************************************************

		_cFilial := alltrim(cFilAnt)
		cRepres := ""
		cBco := ""
		cCodCli := fPegaCampo(aCabecPE,"C5_CLIENTE")
		cLojaCli := fPegaCampo(aCabecPE,"C5_LOJACLI")
		if empty(cCodCli)
				xRet := .f.
				cMsgVldPE := "Código do Cliente ESTA EM BRANCO !!"
		endif

		if xRet .and. empty(cLojaCli)
			if _cGrpEmp == "11"
				xRet := .f.
				cMsgVldPE := "Loja do Cliente "+cCodCli+" ESTA EM BRANCO !!"
			else
				cLojaCli := "01"
			endif
		endif 

		//Verificar se número do pedido no MasterSales já existe! Não incluir caso existir
		if xRet
			_cPvsim := fPegaCampo(aCabecPE,"C5_X_PVSIM")
			if !empty(_cPvsim)
				dbselectarea("SC5")
				dbseek(_cPvsim)
				if found()
					if alltrim(_cPvsim) == alltrim(SC5->C5_X_PVSIM)
						xRet := .f.
						cMsgVldPE := "Pedido MasterSales "+_cPvsim+" já EXISTE, inclusão ABORTADA !!"
					endif 
				endif 
			endif 
		endif 


		if xRet .and. !empty(cCodCli)
			DbSelectArea("SA1")
			DbSeek(xFilial("SA1")+cCodCli+cLojaCli)
			if found()
				cRepres := SA1->A1_VEND
				cBco := ALLTRIM(SA1->A1_BCO1)
				do case
				case (SA1->(FieldPos("A1_X_SIM3G")) > 0) .AND. (SA1->(FieldPos("A1_MSBLQL") > 0)) .AND. (SA1->A1_MSBLQL = "1")
					xRet := .f.
				case (SA1->(FieldPos("A1_X_SIM3G")) > 0) .AND. (SA1->(FieldPos("A1_INATIVO") > 0)) .AND. !EMPTY(ALLTRIM(SA1->A1_INATIVO))
					xRet := .f.
				endcase
				if !xRet
					cMsgVldPE := "Cliente "+cCodCli+"/"+cLojaCli+"-"+ALLTRIM(SA1->A1_NOME)+" ESTÁ BLOQUEADO!!"
				endif
			endif
		endif
		
		if xRet .and. !empty(cRepres)

			DbSelectArea("SA3")
			DbSeek(xFilial("SA3")+cRepres)
			If Found()
				If (SA3->(FieldPos("A3_ENVPED") > 0)) .AND. (SA3->A3_ENVPED != "S")
					xRet := .f.
					cMsgVldPE := "REPRESENTANTE "+cRepres+" ESTA BLOQUEADO !!"
				Endif
			Else
				xRet := .f.
				cMsgVldPE := "NAO ENCONTRADO O REPRESENTANTE "+cRepres+" NO CADASTRO!!"
			Endif
		endif

		if xRet .and. !empty(cRepres)
			fAltCampo(aCabecPE,"C5_VEND1",cRepres)
		endif 

		if xRet .and. !empty(cBco)
			fAltCampo(aCabecPE,"C5_BANCO",cBco)
		endif 

		cAuxTrans := ALLTRIM(fPegaCampo(aCabecPE,"C5_TRANSP"))
		IF !empty(cAuxTrans)
			dbselectarea("SA4")
			dbseek(xFilial("SA4")+cAuxTrans)
			if found() .and. (SA4->(FieldPos("A4_OCORREN") > 0)) .AND. (SA4->A4_OCORREN = "B")
				cObsPedido += chr(13)+chr(10)+"Cód Transp. "+cAuxTrans+" BLOQUEADO! Apagado para que o pedido pudesse ser incluso!"
				fAltCampo(aCabecPE,"C5_TRANSP","")
			endif
		endif 
		cAuxTrans := ALLTRIM(fPegaCampo(aCabecPE,"C5_REDESP"))
		IF !empty(cAuxTrans)
			dbselectarea("SA4")
			dbseek(xFilial("SA4")+cAuxTrans)
			if found() .and. (SA4->(FieldPos("A4_OCORREN") > 0)) .AND. (SA4->A4_OCORREN = "B")
				cObsPedido += chr(13)+chr(10)+"Cód Redesp. "+cAuxTrans+" BLOQUEADO! Apagado para que o pedido pudesse ser incluso!"
				fAltCampo(aCabecPE,"C5_REDESP","")
			endif
		endif 

		if xRet
			dEmissao := fPegaCampo(aCabecPE,"C5_EMISSAO")
			if dEmissao != date()
				fAltCampo(aCabecPE,"C5_EMISSAO",DATE())
			endif
		endif 
/*
		if xRet
			_cFilPed := cFilAnt //fPegaCampo(aCabecPE,"C5_FILIAL")
			If _cFilPed <> nil
				cAux := fPegaCampo(aCabecPE,"C5_RASTR")
				IF cAux <> nil
					fAltCampo(aCabecPE,"C5_RASTR",_cFilPed)
				else
					aAdd(aCabecPE, {"C5_RASTR", _cFilPed ,NIL} )
				ENDIF
			Endif
		endif
*/

		//iif(posicione("SA4",1,xFilial("SA4")+M->C5_TRANSP,"A4_OCORREN") = 'B',.F.,.T.)  

		// Simulação de um Vendedor inválido por um motivo qualquer
		/*
		cVendedor := fPegaCampo(aCabecPE,"C5_VEND1")
		If cVendedor == "000001" // .and. ..........
		cMsgVldPE := "* Vendedor/Representante bloqueado - inclusao abortada *"
		xRet := .F.
		Endif
		*/

		// Simulação de uma Condição inválida
		/*
		cCondPg := fPegaCampo(aCabecPE,"C5_CONDPAG")
		If xRet .and. cCondPg == "999" // .and. ..........
		cMsgVldPE := "* Condicao de pagamento invalida - inclusao abortada *"
		xRet := .F.
		Endif
		*/
		//*****************************************************************************************
		// Segunda parte: validações sobre todos os itens do pedido para montar um vetor auxiliar
		// somente com os itens válidos e montar um campo de observação contendo os itens removidos
		//*****************************************************************************************
		If xRet

			For i := 1 to Len(aItensPE)
				cProd := fPegaCampo(aItensPE[i],"C6_PRODUTO")
				nQtde := fPegaCampo(aItensPE[i],"C6_QTDVEN")
				nValor := fPegaCampo(aItensPE[i],"C6_PRCVEN")

				lProdExcluido := .F.
				//*****************
				dbselectarea("SB1")
				DbSeek(_cFilial+cProd) //Obs. É aberto apenas um environment, pedidos com filiais distintas o xFilial() pode trazer filial do environment aberto!!
				If found()
					
					DO CASE
					CASE (_cGrpEmp <> "11") .AND. (SB1->B1_VEND = "N")
						cAux := "Produto Excluido: "+cProd+", Qtde "+Alltrim(Str(nQtde))+;
						",Valor "+cValToChar(nValor)+" - VENDA BLOQUEADA"
						cObsPedido += chr(13)+chr(10)+cAux
						lProdExcluido := .t.

					CASE (_cGrpEmp <> "11") .AND. !U_QtdMinProd(cProd,nQtde)
						cAux := "Produto Excluido: "+cProd+", Qtde "+Alltrim(Str(nQtde))+;
						",Valor "+cValToChar(nValor)+" - QTDE ABAIXO DO MINIMO"
						cObsPedido += chr(13)+chr(10)+cAux
						lProdExcluido := .t.
					CASE (SB1->B1_MSBLQL = "1") 
						cAux := "Produto Excluido: "+cProd+", Qtde "+Alltrim(Str(nQtde))+;
						",Valor "+cValToChar(nValor)+" - PRODUTO BLOQUEADO!"
						cObsPedido += chr(13)+chr(10)+cAux
						lProdExcluido := .t.
					ENDCASE
				Else
					lProdExcluido := .t.
					cObsPedido += chr(13)+chr(10)+"NAO ENCONTRADO produto "+cProd+"! O pedido poderá ficar inconsistente!"
				Endif
				If !lProdExcluido .and. (_cGrpEmp <> "11")
					lProdExcluido := U_VolQuebrado(cProd, nQtde)
					If lProdExcluido
						cAux := "Produto Excluido: "+cProd+", Qtde "+cValToChar(nQtde)+;
						",Valor "+cValToChar(nValor)+" - VOLUME INCOMPLETO!"
						cObsPedido  += chr(13)+chr(10)+cAux
					Endif
				Endif

				//*****************
				/*
				// Simulação de um Produto inválido que não poderia ir para o pedido
				If alltrim(cProd) == "000002" // .and. .......

				// Monta observação com o item removido
				cObsPedido += "Produto Excluido: "+ cProd +" Quantidade: "+ cValToChar(nQtde) +" VENDA BLOQUEADA "+ chr(13)+chr(10)
				lProdExcluido := .T.
				Endif

				// Simulação de um Produto inválido que não poderia ir para o pedido
				If alltrim(cProd) == "000003" // .and. .......

				// Monta observação com o item removido
				cObsPedido += "Produto Excluido: "+ cProd +" Quantidade: "+ cValToChar(nQtde) +" VOLUME INVALIDO "+ chr(13)+chr(10)
				lProdExcluido := .T.
				Endif
				*/
				// Se o item não foi excluído, adiciona o item no vetor auxiliar
				If ! lProdExcluido
					nQtdItens++
					aAdd(aItensAux, aItensPE[i])
				Endif
			Next i
			//**********
			// Após validar os itens, ajusta os vetores aCabec e aItens se necessário
			If ! Empty(cObsPedido)

				// Valida se já existe uma observação no Pedido
				cObsAntes := fPegaCampo(aCabecPE,"C5_OBS")
				If cObsAntes <> nil
					cObsAntes += cObsPedido
					// Altera o campo com a nova observação
					fAltCampo(aCabecPE,"C5_OBS",cObsAntes)
				Else
					// Adiciona a observação no pedido
					aAdd(aCabecPE, {"C5_OBS", cObsPedido ,NIL} )
				Endif

				// Retorna o vetor auxiliar com os itens válidos para o pedido
				aItensPE := aClone(aItensAux)
				aItensAux := nil
				//cObsPedido := ""
			Endif
			//*********
			//xRet := .T.
		EndIf
		/*
		if xRet 
			_cDep := ""
			//Forçar depósito fechado igual a N para Dissoltex
			if _cFilial == "060101"
				_cDep := "N"
			endif
			if len(_cFilial) == 6
				cAux := fPegaCampo(aCabecPE,"C5_DEPOSI")
				if cAux = nil
					aAdd(aCabecPE, {"C5_DEPOSI", _cDep ,NIL} )
				else
					fAltCampo(aCabecPE,"C5_DEPOSI",_cDep)
				endif 
			endif
		endif 
		*/
	// Se não adicionou nenhum item retornar falso (Cleber)
	if xRet .and. (nQtdItens == 0)
		xRet := .F.
		if !empty(cObsPedido)
			cMsgVldPE := cObsPedido
		else
			cMsgVldPE := "Pedido está SEM ITENS!!!!"
		endif
	endif
	cObsPedido := ""

CASE cOrigem == "APOSPEDIDO"
//	cNumPed := alltrim(PARAMIXB[2])
 // Complemento após inclusão do Pedido

 //Cleber(09/10/20) -> Desmarcar depósito fechado errado para dar um alterar via Schedule por SigaAuto (BRFAT101) pois os pedidos
 //quando estão vindo do MasterSales são inclusos através do ambiente BRASILUX/MATRIZ independente da filial, embora a filial no xml venha correta
 //a mesma não é identificada corretamente no MTA410 quando chegam pedidos de filiais diferentes. Criada essa solução de contorno.

	IF (SC5->C5_FILIAL = "060101") .OR. (SC5->C5_FILIAL = "010101")
		IF ((SC5->C5_FILIAL = "060101") .AND. (SC5->C5_DEPOSI = "S")) .OR. ((SC5->C5_FILIAL = "010101") .AND. (SC5->C5_DEPOSI = "N") .AND. (ALLTRIM(SC5->C5_TRANSP) $ "00700-00573-00800"))
			dbSelectArea("SC5")
			RecLock("SC5",.F.)
			SC5->C5_DEPOSI := ""
			msUnlock() 
			//desmarcar C6_CF pois está dando problema
			dbselectarea("SC6")
			dbsetorder(1)
			dbseek(SC5->C5_FILIAL+SC5->C5_NUM)
			do while !eof() .and. (SC5->C5_FILIAL == SC6->C6_FILIAL) .AND. (SC5->C5_NUM == SC6->C6_NUM)
				RecLock("SC6",.F.)
				SC6->C6_CF := ""
				msUnlock() 
				dbskip()
			enddo 
		ENDIF 
	ENDIF

	//Cleber(07/01/2021) -> Descoberto que não preenche banco no MATA410 desde Outubro/2020, criada solução contorno. Colocada também em MTA410
	dbselectarea("SA1")
	DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
	if found() .and. (empty(ALLTRIM(SC5->C5_BANCO)) .OR. (SC5->C5_TPFRETE != "F") .OR. (SC5->C5_VEND1 != SA1->A1_VEND) .OR. (SC5->C5_FRETE != 0.0)  .OR. (SC5->C5_SEGURO != 0.0))
		dbSelectArea("SC5")
		RecLock("SC5",.F.)
		if empty(ALLTRIM(SC5->C5_BANCO)) .AND. !empty(ALLTRIM(SA1->A1_BCO1))
			SC5->C5_BANCO := SA1->A1_BCO1
		endif 
		IF !empty(SA1->A1_VEND) .AND. (SC5->C5_VEND1 != SA1->A1_VEND)
			SC5->C5_VEND1 := SA1->A1_VEND
		ENDIF 
		if _cGrpEmp == "01"
			SC5->C5_TPFRETE := "F"
		endif
		SC5->C5_EMISSAO := DATE()
		SC5->C5_FRETE := 0.0
		SC5->C5_SEGURO := 0.0
		msUnlock() 
	endif 



ENDCASE



U_VoltaArea(aAreaAnt)

if !empty(cArea)
	dbselectarea(cArea)
endif
Return xRet

//************************************************************************
// Função auxiliar para localizar um campo no vetor recebido como
// parâmetro: aCabec ou aItens[N] e retornar o seu conteúdo
//************************************************************************
Static Function fPegaCampo(aVetor,cCampo)

	Local xRet
	Local n

	n := aScan(aVetor, {|x| Alltrim(x[1]) == Alltrim(cCampo)  })
	If n > 0
		xRet := aVetor[n][2]
	Endif

Return xRet

//************************************************************************
// Função auxiliar para localizar um campo no vetor recebido como
// parâmetro: aCabec ou aItens[N] e alterar o seu conteúdo
//************************************************************************
Static Function fAltCampo(aVetor,cCampo,xConteudo)

	Local xRet
	Local n

	n := aScan(aVetor, {|x| Alltrim(x[1]) == Alltrim(cCampo)  })
	If n > 0
		aVetor[n][2] := xConteudo
		xRet := xConteudo
	Endif

Return xRet


