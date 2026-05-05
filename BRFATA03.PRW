#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'INKEY.CH'
#INCLUDE 'vkey.CH'
#xtranslate bsetget(<uvar>) => { | u | If( PCount() == 0, <uvar>, <uvar> := u ) }


/*/{Protheus.doc} BRFATA03
Bordero de Pedidos Aprovados.  Antigo BRFAT065.
@type function Tela
@version  1.00
@author Luís G. de Souza /  Modificado por Mario Antonaccio
@since 23/02/06 -  Alterado em 30/04/2026
@return character, sem retorno
/*/
User Function BRFATA03()

	Private aCores    := {}                          as Array
	Private aRotina   := {}                          as Array
	Private cAcessos  := ""                          as character
	Private cCadastro := "Bordero de Pedidos (Novo)" as character
	Private cOpcMen   := ''                          as character

	aRotina :={{ OemToAnsi( '&Pesquisa' ) , "AxPesqui" , 0, 1},;
		{OemToAnsi( '&Visualizar' )                    , 'u_FATA03_1("V")', 0, 2},;
		{OemToAnsi( '&Incluir' )                       , 'u_FATA03_1("I")', 0, 3},;
		{OemToAnsi( '&Alterar' )                       , 'u_FATA03_1("A")', 0, 4},;
		{OemToAnsi( '&Excluir' )                       , 'u_FATA03_1("E")', 0, 5},;
		{OemToAnsi("Atualiza Status" )                 , 'u_FATA02_9()   ', 0, 6 }}


	If GETMV("MV_QUALCON") == 1
		AADD(aRotina, {OemToAnsi( '&Consultar' )  , 'u_FATA03_3("M")', 0, 9})
	ElseIf GETMV("MV_QUALCON") == 2
		AADD(aRotina, {OemToAnsi( 'Consultar II' ), 'u_FATA03_A("M")', 0, 9})
	Else
		AADD(aRotina, {OemToAnsi( '&Consultar' )  , 'u_FATA03_3("M")', 0, 9})
		AADD(aRotina, {OemToAnsi( 'Consultar II' ), 'u_FATA03_A("M")', 0, 9})
	Endif

	SZW->(DbSetOrder(4))
	IF SZW->(DbSeek(xFilial("SZW")+'BRFATA03  '+RetCodUsr()+substr(cNumEmp,1,2)+substr(cNumEmp,FWSizeFilial()+1,2)))
		cAcessos := SZW->ZW_ACESSOS
	Endif

	If SubStr(cAcessos, 10, 1) $ '*' //Usuário Ativo
		If SUBSTR(cNumEmp,3,2) ='06'
			If SubStr(cAcessos, 1, 1) $ '*'
				aadd(aRotina,    { OemToAnsi('E&ndereçar')    , 'u_FATA03_4("1")', 0, 9 } )
			Endif
			If SubStr(cAcessos, 2, 1) $ '*'
				aadd(aRotina,   { OemToAnsi('E&xclui End.')  , 'u_FATA03_4("2")', 0, 9 } )
			Endif
			If SubStr(cAcessos, 3, 1) $ '*'
				aadd(aRotina,    { OemToAnsi('Retirada')      , 'u_FATA03_5("1")', 0, 9 } )
			Endif
			If SubStr(cAcessos, 4, 1) $ '*'
				aadd(aRotina,   { OemToAnsi('Baixa Retirada'), 'u_FATA03_5("2")', 0, 9 } )
			Endif
		Endif
		If SubStr(cAcessos, 5, 1) $ '*'
			aadd(aRotina,  { OemToAnsi('Monta Despacho'), 'u_FATA03_8()   ', 0 , 9 } )
		Endif
		If Substr(cAcessos, 6, 1) $ '*'
			aadd(aRotina,  { OemToAnsi('Transfere Bordero'), 'u_TransfBorPed() ', 0 , 9 } )
		Endif
		If SubStr(cAcessos, 7, 1) $ '*'
			aAdd(aRotina,  { OemToAnsi('Baixa Retirada Bord Bipado'), 'u_BxRetBipe()', 0, 9} ) //Gerar relatório de Faltas para bordero monta compra
		Endif
		If SubStr(cAcessos, 8, 1) $ '*'
			aAdd(aRotina,  { OemToAnsi('Reprocessa Faltas Pedido'), 'u_BRRepFal()', 0, 9} ) //Reprocessa relatório de faltas pra um determinado pedido
		Endif
		If SubStr(cAcessos, 9, 1) $ '*'
			aAdd(aRotina,  { OemToAnsi('Acessa Localiz. Provis.'), 'fAbrLoc()', 0, 9} )
		Endif
	Endif
	aadd(aRotina,          { OemToAnsi("Le&genda")      , 'u_FATA03_9()   ', 0 , 9 } )

	aCores    := { { 'SZF->ZF_FLAG == "D"', 'ENABLE'    },; //Bordero digitado
		{ 'SZF->ZF_FLAG == "Y"', 'BR_MARRON' },; //Baixa Retirada
		{ 'SZF->ZF_FLAG == "X"', 'BR_LARANJA'},; //Totalmente Destinado
		{ 'SZF->ZF_FLAG == "Z"', 'BR_BRANCO' } } //Totalmente Bipado

	u_zcfga01( 'BRFATA03' ) //LGS#2021201 - Gravação de log de utilização da rotina

	SC5->(DbSetOrder(1))
	SZF->(DbSetOrder(1))

	mBrowse(06, 01, 22, 80, "SZF",,,,,, aCores)

Return

/*/{Protheus.doc} FATA03_1
Visualização / Inclusão / Alteração / Exclusão do Bordero de Pedidos
 FATA03_2 - Validação da digitação do campo pedido e localização
 fVldPed  - Verificação de pedido não liberado
@type function Processamento
@version  1.00
@author ? / Alterado por Mario Antonaccio
@since  ? / Alterado em 30/04/2026
@param cOpcMen, character, opcao de menu selecionada para definir o comportamento da função
@return Character, sem retorno
/*/
User Function FATA03_1(cOpcMen)

	Local cAliasSX3 := GetNextAlias() as character // Adequação para release 12.1.25
	Local cAux                        as character
	Local cValCpo                     as character
	Local lOpen     := .F.            as logical // Adequação para release 12.1.25
	Local nI                          as numeric
	Local nPosLOCAL                   as numeric
	Local nPosPEDIDO                  as numeric
	Local nPosRAZAO                   as numeric
	Local nY                          as numeric
	Private aTroBor := {}             as array

	// ABERTURA DO DICIONÁRIO SX3 - Adequação para release 12.1.25
	OpenSXs( NIL, NIL, NIL, NIL, Nil, cAliasSX3, "SX3", NIL, .F. )
	lOpen := Select(cAliasSX3 ) > 0

	If .NOT. _lOpen // Adequação para release 12.1.25
		FWAlertError( "Não foi possível abrir dicionário de dados.", "Atenção" )
		Return (NIL)
	Endif

	Do Case
		Case cOpcMen == "I" .or. cOpcMen == "A"
			nOpcE   := 3
			nOpcG   := 3
		Case cOpcMen == "V" .or. cOpcMen == "E"
			nOpcE   := 2
			nOpcG   := 2
	EndCase

	If cOpcMen == 'A' .and. SZF->ZF_FLAG $ 'E.P.T.R.X.Y.Z'
		FWAlertErro("Esse bordero não pode ser alterado!", "Atenção")
		Return (NIL)
	ElseIf cOpcMen == 'E' .and. SZF->ZF_FLAG $ 'E.P.T.R.X.Y.Z'
		FWAlertError( "Esse bordero não pode ser excluido!", "Atenção" )
		Return
	EndIf

	RegToMemory("SZF", (cOpcMen == "I"))
	aHeader := {}
	nUsado := 0

	( cAliasSX3 )->( DbSetOrder(1) )
	( cAliasSX3 )->( DbSeek("SZG") )
	While .NOT. ( cAliasSX3 )->(Eof()) .and. ( cAliasSX3 )->( X3_ARQUIVO ) == "SZG"

		If AllTRIM( ( cAliasSX3 )->( X3_CAMPO ) ) == "ZG_CODIGO"
			( cAliasSX3 )->(DbSkip())
			Loop
		Endif

		If X3Uso( ( cAliasSX3 )->( X3_USADO ) ) .and. cNivel >= ( cAliasSX3 )->( X3_NIVEL )

			nUsado++

			If AllTRIM( ( cAliasSX3 )->( X3_CAMPO ) ) == "ZG_PEDIDO"
				cValCpo := Iif(cOpcMen $ 'I.A', 'u_FATA03_2("P", "I", @aTroBor)', 'u_FATA03_2("P")')
			ElseIf AllTRIM( ( cAliasSX3 )->( X3_CAMPO ) ) == "ZG_LOCALIZ"
				cValCpo := Iif(cOpcMen $ 'I.A', 'u_FATA03_2("L", "I")', 'u_FATA03_2("L")')
			Else
				cValCpo := "AllwaysTrue()"
			Endif

			aadd(aHeader, { ( cAliasSX3 )->(X3_TITULO),;
				( cAliasSX3 )->( X3_CAMPO ),;
				( cAliasSX3 )->( X3_PICTURE ),;
				( cAliasSX3 )->( X3_TAMANHO ),;
				( cAliasSX3 )->( X3_DECIMAL ),;
				cValCpo,;
				( cAliasSX3 )->( X3_USADO ),;
				( cAliasSX3 )->( X3_TIPO) ,;
				( cAliasSX3 )->( X3_ARQUIVO ),;
				( cAliasSX3 )->( X3_CONTEXT ) } )
		Endif
		( cAliasSX3 )->(DbSkip())
	EndDo

	nPosPEDIDO := aScan(aHeader, {|x| Trim(x[2]) == "ZG_PEDIDO" })
	nPosRAZAO  := aScan(aHeader, {|x| Trim(x[2]) == "ZG_RAZAO"  })
	nPosLOCAL  := aScan(aHeader, {|x| Trim(x[2]) == "ZG_LOCALIZ"})

	( cAliasSX3 )->(DbCloseArea())

	SZF->(DbSetOrder(1))
	SZG->(DbSetOrder(1))

	aCols := {Array(nUsado+1)}
	aCols[1][nUsado+1] := .F.
	For nI := 1 To nUsado
		aCols[1][nI] := CriaVar(aHeader[nI][2])
	Next
	If cOpcMen == "I"
		M->ZF_EMISSAO := dDatabase
	Else
		aCols := {}
		SZG->(dbSetOrder(1))
		SZG->(DbSeek(xFilial("SZG")+M->ZF_CODIGO))
		While  .NOT. SZG->(EOF()) .and. (SZG->ZG_FILIAL == xFilial("SZG")) .and. (SZG->ZG_CODIGO == M->ZF_CODIGO)
			aAdd(aCols, Array(nUsado+1))
			For nI := 1 To nUsado
				cAux := Upper(Alltrim(aHeader[nI][2]))
				If cAux # "ZG_RAZAO" //Campo Virtual não entra no FieldGet
					aCols[Len(aCols)][nI] := FieldGet(FieldPos(aHeader[nI][2]))
				Endif
			Next
			M->ZF_PESO   += Posicione("SC5", 1, xFilial("SC5")+SubStr(aCols[Len(aCols)][nPosPEDIDO], 3, 6), "C5_PBRUTO")
			M->ZF_VOLUME += Posicione("SC5", 1, xFilial("SC5")+SubStr(aCols[Len(aCols)][nPosPEDIDO], 3, 6), "C5_VOLUME1")
			aCols[Len(aCols)][nUsado+1]  := .F.
			aCols[Len(aCols)][nPosRAZAO] := Posicione("SA1", 1, xFilial("SA1")+Posicione("SC5", 1, xFilial("SC5")+SubStr(aCols[Len(aCols)][nPosPEDIDO], 3, 6), "C5_CLIENTE"), "A1_NOME")
			SZG->(DbSkip())
		EndDo
	Endif
	//MAA - 30/04/2026 - Início - Validação de pedidos não liberados, bloqueados ou não encontrados
	If Len(aCols) > 0
		fVldPed(aCols, cOpcMen)
		cTitulo        := "Bordero de Pedidos Aprovados"
		cAliasEnchoice := "SZF"
		cAliasGetD     := "SZG"
		cLinOk         := "U_LinFATA03_1()"
		cTudOk         := "AllwaysTrue()"
		cFieldOk       := "AllwaysTrue()"
		aCpoEnchoice   := {"ZG_PEDIDO"}

		lRet          := Modelo3(cTitulo, cAliasEnchoice, cAliasGetD, aCpoEnchoice, cLinOk, cTudOk, nOpcE, nOpcG, cFieldOk, , 1000)

		If lRet

			nPosPEDIDO := aScan(aHeader, {|x| Trim(x[2]) == "ZG_PEDIDO"})
			nPosLOCAL  := aScan(aHeader, {|x| Trim(x[2]) == "ZG_LOCALIZ"})

			//Inclusao
			If cOpcMen == "I"
				M->ZF_CODIGO := U_NumSeqLot("SZF")
				lGrv:=.F.
				//Roda o Acols primeiro, se Ok, grava o Aheadr
				For nY := 1 To Len(aCols)
					If aCols[nY][Len(aHeader)+1]
						Loop
					End

					cAux            := alltrim(aCols[nY][nPosPEDIDO])
					cAux            := Substr(cNumEmp,1,2)+Substr(cAux,Len(cAux)-5,6)
					RecLock("SZG", .T.)
					SZG->ZG_FILIAL  := xFilial("SZG")
					SZG->ZG_CODIGO  := M->ZF_CODIGO
					SZG->ZG_PEDIDO  := cAux //aCols[nY][nPosPEDIDO]
					SZG->ZG_LOCALIZ := aCols[nY][nPosLOCAL]
					MsUnlock()
					lGrv:=.T.
				Next

				//Se gravaou algo, gera o cabec
				If lGrv
					DbSelectArea("SZF")
					RecLock("SZF", .T.)
					SZF->ZF_FILIAL  := xFilial("SZF")
					SZF->ZF_CODIGO  := M->ZF_CODIGO
					SZF->ZF_EMISSAO := M->ZF_EMISSAO
					SZF->ZF_TIPOBOR := M->ZF_TIPOBOR
					SZF->ZF_FLAG    := 'D'
					MsUnLock()
				End
			End
			// FIm Inclusao
			//Alteração

			If cOpcMen == "A"
				lGrv:=.F.
				For nY := 1 To Len(aCols)

					//Deleta o registro da localização na tabela de detalhes para depois excluir no Arquivo header
					If aCols[nY][Len(aHeader)+1]
						ZZC->(DbSetOrder(1))
						If ZZC->(DbSeek(xFilial("ZZC")+M->ZF_CODIGO+Substr(aCols[nY][nPosPEDIDO],3,6)))
							While .NOT. ZZC->(EOF()) .and. ;
									(ZZC->ZZC_FILIAL == xFilial("ZZC")) .and.;
									(Substr(aCols[nY][nPosPEDIDO],3,6) == ZZC->ZZC_PEDIDO)
								RecLock("ZZC", .F.)
								ZZC->(DbDelete())
								ZZC->(MsUnLock())
								ZZC->(dbSkip())
							Enddo
						Endif
						ZZC->(DbCloseArea())

						RecLock("SZG", .f.)
						SZG->(DbDelete())
						MsUnLock()
						Loop
					End

					SZG->(DbSetOrder(1))
					If SZG->(DbSeek(xFilial("SZG")+M->ZF_CODIGO+aCols[nY][nPosPEDIDO]))
						RecLock("SZG", .F.)
						cAux := alltrim(aCols[nY][nPosPEDIDO])
						cAux := Substr(cNumEmp,1,2)+Substr(cAux,Len(cAux)-5,6)
						SZG->ZG_PEDIDO  := cAux //aCols[nY][nPosPEDIDO]
						SZG->ZG_LOCALIZ := aCols[nY][nPosLOCAL]
						MsUnLock()
					Else
						//Se nao encontrou. então é linha nova ai inclui
						cAux := alltrim(aCols[nY][nPosPEDIDO])
						cAux := substr(cNumEmp,1,2)+substr(cAux,len(cAux)-5,6)
						RecLock("SZG", .t.)
						SZG->ZG_FILIAL  := xFilial("SZG")
						SZG->ZG_CODIGO  := M->ZF_CODIGO
						SZG->ZG_PEDIDO  := cAux //aCols[nY][nPosPEDIDO]
						SZG->ZG_LOCALIZ := aCols[nY][nPosLOCAL]
						MsUnlock()
						lGrv:=.T.
					Endif
				Next
				If lgrv
					DbSelectArea("SZF")
					RecLock("SZF", .F.)
					SZF->ZF_EMISSAO := M->ZF_EMISSAO
					SZF->ZF_TIPOBOR := M->ZF_TIPOBOR
					MsUnLock()
				End
			Endif

			//Verifica se foi gravado, se nao deleta
			SZG->(DbSetOrder(1))
			If SZG->(DbSeek(xFilial("SZG")+SZF->ZF_CODIGO ,.t.))

				While .NOT. SZG->(EOF()) .and.;
						(SZG->ZG_FILIAL == xFilial("SZG")) .and.;
						(SZG->ZG_CODIGO == SZF->ZF_CODIGO)
					nPos := aScan(aCols, { |x| Upper(AllTrim(x[nPosPEDIDO])) == SZG->ZG_PEDIDO })
					If nPos == 0
						RecLock("SZG", .f.)
						SZG->(DbDelete())
						MsUnLock()
					Endif

					SZG->(DbSkip())
				Enddo
			Endif
			//Fim Alteração

			//Exclusao
			If cOpcMen == "E"
				SZG->(DbSetOrder(1))
				If SZG->(DbSeek(xFilial("SZG")+SZF->ZF_CODIGO))
					While .NOT. SZG->(EOF()) .and. ;
							(SZG->ZG_FILIAL == xFilial("SZG")) .and.;
							(SZG->ZG_CODIGO == SZF->ZF_CODIGO)
						RecLock("SZG", .f.)
						SZG->(DbDelete())
						MsUnLock()
						DbSkip()
					Enddo
					DbSelectArea("SZF")
					RecLock("SZF", .f.)
					SZF->(DbDelete())
					MsUnLock()
				Endif

			Endif
			//Fim Exclusao

		Else
			If cOpcMen $ "I_A_E"
				RecLock("SZF", .f.)
				SZF->(DbDelete())
				MsUnLock()
			Endif
		End
	End
Return

/*/{Protheus.doc} LinFATA03_1
?
@type function Processamento
@version  1.00
@author marioantonaccio
@since 30/04/2026
@return logical, segue o processo
/*/
User Function LinFATA03_1()
	Local nTotPes := 0
	Local nTotVol := 0
	Local nY
	For nY := 1 To Len(aCols)
		If .NOT. aCols[nY][Len(aHeader)+1]
			nTotPes += Posicione("SC5", 1, xFilial("SC5")+SubStr(aCols[nY][1], 3, 6), "C5_PBRUTO")
			nTotVol += Posicione("SC5", 1, xFilial("SC5")+SubStr(aCols[nY][1], 3, 6), "C5_VOLUME1")
		Endif
	Next
	M->ZF_PESO   := nTotPes
	M->ZF_VOLUME := nTotVol
Return(.T.)

/******************************************************************************************************************/
/*** FATA03_2 - Validação do pedido e da localização digitada pelo usuário.                                     ***/
/******************************************************************************************************************/
User Function FATA03_2(cOpcVal, cOpcTip, aTroBor)
	//Local nPosPEDIDO := aScan(aHeader, {|x| Trim(x[2]) == "ZG_PEDIDO" })
	Local nPosRAZAO  := aScan(aHeader, {|x| Trim(x[2]) == "ZG_RAZAO"  })
	//Local nPosLOCAL  := aScan(aHeader, {|x| Trim(x[2]) == "ZG_LOCALIZ"})
	Local cAprova    := ""
	Local nArea, lRet, nRecNo, nNumOr, nY
	Local cNumNot := ""
	Local cMsgNot := ""
	lRet  := .t.
	nArea := Alias()
	If cOpcVal $ 'P' //Validação do Pedido
		DbSelectArea("SZG")
		nRecNo := RecNo()
		nNumOr := IndexOrd()

		//Não permitir inclusão de ped amostras (solic. Ramon)
		//If U_BRTEMAMOSTRA(M->ZG_PEDIDO)
		//lRet = .f.
		//aCols[n][1]  := ''
		//M->ZG_PEDIDO := ''
		//MsgBox("Este pedido é de Amostra, não misturar com pedidos normais!", "Atenção...", "STOP")
		//Return(lRet)
		//Endif
		If cNumEmp <> "01060101"
			If U_BrVerPed(M->ZG_PEDIDO,M->ZF_CODIGO)
				lRet = .f.
				aCols[n][1]  := ''
				M->ZG_PEDIDO := ''
				Msgstop("Atenção, divergência entre tipo de pedido (Depósito/Regiao-Retira/Exportação) e o tipo do bordero!")
				Return(lRet)
			Endif
		Endif
		DbSelectArea("SZG")
		DbSetOrder(2)
		DbSeek(xFilial("SZG")+M->ZG_PEDIDO, .t.)
		If Found() .and. (SZG->ZG_FILIAL == XFILIAL("SZG")) .and. (cOpcTip == "I") .and. (M->ZF_CODIGO # SZG->ZG_CODIGO)
			If SZG->ZG_CODIGO $ '000000'
				aAdd(aTroBor, {'000000', space(06)})
				MsgBox("Pedido será trocado de bordero no final do processo", "Informação", "INFO")
			Else
				lRet = .f.
				aCols[n][1]  := ''
				M->ZG_PEDIDO := ''
				MsgBox("Pedido já digitado anteriormente!", "Atenção...", "STOP")
			Endif
			Return(lRet)
		Endif

		DbSetOrder(nNumOr)
		DbGoto(nRecNo)
		For nY := 1 To Len(aCols)
			If nY <> n
				If aCols[nY][1] == M->ZG_PEDIDO
					lRet = .f.
					aCols[n][1]  := ''
					M->ZG_PEDIDO := ''
					MsgBox("Pedido já digitado nesse bordero!", "Atenção...", "STOP")
					Return(lRet)
				Endif
			Endif
		Next
		cAprova := Posicione("SC5", 1, xFilial("SC5")+SubStr(M->ZG_PEDIDO, 3, 6), "C5_APROVA")
		If cAprova != "1"
			lRet = .f.
			aCols[n][1]  := ''
			M->ZG_PEDIDO := ''
			MsgBox("Pedido NAO está Liberado!", "Atenção", "STOP")
			Return(lRet)
		Else
			If !Empty(Posicione("SC5", 1, xFilial("SC5")+SubStr(M->ZG_PEDIDO, 3, 6), "C5_NOTA"))
				MsgBox("Pedido já foi faturado!", "Atenção", "INFO")
			Endif
			SA1->(DbSetOrder(1))
			If SA1->(DbSeek(xFilial("SA1")+Posicione("SC5", 1, xFilial("SC5")+SubStr(M->ZG_PEDIDO, 3, 6), "C5_CLIENTE"), .t.))
				aCols[n][nPosRAZAO] := Posicione("SA1", 1, xFilial("SA1")+SC5->C5_CLIENTE, "A1_NOME")
				M->ZG_RAZAO         := Posicione("SA1", 1, xFilial("SA1")+SC5->C5_CLIENTE, "A1_NOME")
			Endif
			lRet := .T.
		Endif
		nTotPes := 0
		nTotVol := 0
		For nY := 1 To Len(aCols)
			If .NOT. aCols[nY][Len(aHeader)+1]
				nTotPes += Posicione("SC5", 1, xFilial("SC5")+SubStr(M->ZG_PEDIDO, 3, 6), "C5_PBRUTO")
				nTotVol += Posicione("SC5", 1, xFilial("SC5")+SubStr(M->ZG_PEDIDO, 3, 6), "C5_VOLUME1")
			Endif
		Next
		M->ZF_PESO   := nTotPes
		M->ZF_VOLUME := nTotVol
	ElseIf cOpcVal $ 'L' //Validação da Localização
		SC5->(DbSetOrder(1))
		IF SC5->(DbSeek(xFilial("SC5")+Substr(aCols[n][1],3,6), .t.))
			cNumNot := SC5->C5_NOTA
		Endif
		If .NOT. Empty(cNumNot)
			cMsgNot := "        ATENÇÃO: Esse pedido está faturado!        "+CRLF
			cMsgNot += "Verifique com a Expedição se o mesmo será retirado!"
			FWAlertWarning(cMsgNot, "Atenção")
		Endif
		lRet := .T.
	Endif
	DbSelectArea(nArea)
Return(lRet)

/******************************************************************************************************************/
/*** fVldPed - Verificação de pedido não liberado.                                                              ***/
/******************************************************************************************************************/
Static Function fVldPed(aCols, cOpcao)
	Local nPedNLi := 0
	Local cPedNLi := ""
	Local nPedLib := 0
	Local nPedBlo := 0
	Local cPedBlo := ""
	Local nPedNEn := 0
	Local cPedNEn := ""
	Local cAuxPed := ""
	Local _nI, nY
	For _ni := 1 To Len(aCols)
		DbSelectArea("SC5")
		DbGoTop()
		DbSetOrder(1)
		DbSeek(xFilial("SC5")+SubStr(aCols[_ni][1], 3, 6), .t.)
		If Found()
			If SC5->C5_APROVA == '0'
				nPedNLi += 1
				cPedNLi += SC5->C5_NUM+'/'
			ElseIf SC5->C5_APROVA == '1'
				nPedLib += 1
			ElseIf SC5->C5_APROVA == '2'
				nPedBlo += 1
				cPedBlo += SC5->C5_NUM+'/'
			Endif
			cAuxPed += SC5->C5_NUM+"', '"
		Else
			nPedNEn += 1
			cPedNEn += SubStr(aCols[_ni][1], 3, 6)+'/'
		Endif
	Next
	If cOpcMen $ "A_V"
		cMsg := ""
		If nPedNLi > 0
			cMsg += "Existe(m) "+TransForm(nPedNLi, "@E 9999")+" pedido(s) não liberado(s): "+chr(13)+chr(10)
			cMsg += cPedNLi+chr(13)+chr(10)
		Endif
		If nPedBlo > 0
			cMsg += "Existe(m) "+TransForm(nPedBlo, "@E 9999")+" pedido(s) bloqueado(s): "+chr(13)+chr(10)
			cMsg += cPedBlo+chr(13)+chr(10)
		Endif
		If nPedNEn > 0
			cMsg += "Existe(m) "+TransForm(nPedNEn, "@E 9999")+" pedido(s) não encontrado (excluido): "+chr(13)+chr(10)
			cMsg += cPedNEn+chr(13)+chr(10)
		Endif
		If !Empty(cMsg)
			MsgBox(cMsg, "Atenção", "STOP")
		Endif
		aPedSC9 := {}
		cQry1 := ""
		cQry1 += "SELECT C9_PEDIDO "
		cQry1 += "FROM "+RetSqlName("SC9")+" SC9 WITH (NOLOCK) "
		cQry1 += "WHERE SC9.C9_FILIAL  = '"+xFilial("SC9")+"' "
		cQry1 += "  AND SC9.D_E_L_E_T_ = '' "
		cQry1 += "  AND SC9.C9_PEDIDO IN('"+SubStr(cAuxPed, 1, Len(cAuxPed)-3)+") "
		cQry1 += "  AND SC9.C9_BLEST   <> '' "
		cQry1 += "  AND SC9.C9_BLCRED  <> '' "
		TCQuery cQry1 ALIAS "XC9" NEW
		DbSelectArea("XC9")
		While !Eof()
			If aScan(aPedSC9, {|x| x[1] == XC9->C9_PEDIDO}) == 0
				aAdd(aPedSC9, {XC9->C9_PEDIDO, 1})
			Else
				aPedSC9[aScan(aPedSC9, {|x| x[1] == XC9->C9_PEDIDO})][2] += 1
			Endif
			DbSelectArea("XC9")
			DbSkip()
		Enddo
		DbSelectArea("XC9")
		DbCloseArea()

		aPedSC5 := {}
		cQry1 := ""
		cQry1 += "SELECT C5_NUM "
		cQry1 += "FROM "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) "
		cQry1 += "WHERE (D_E_L_E_T_ <> '*') AND (SC5.C5_FILIAL = '"+xFilial("SC5")+"') "
		cQry1 += "  AND C5_NOTA = '' "
		cQry1 += "  AND SC5.C5_LIBCAD = 'T' "
		cQry1 += "  AND SC5.C5_LIBPED = 'T' "
		cQry1 += "  AND SC5.C5_LIBCRE = 'T' "
		cQry1 += "  AND SC5.C5_LIBDIR = 'T' "
		cQry1 += "  AND SC5.C5_APROVA = 0 "
		TCQuery cQry1 ALIAS "XC5" NEW
		DbSelectArea("XC5")
		While !Eof()
			If aScan(aPedSC5, {|x| x[1] == XC5->C5_NUM}) == 0
				aAdd(aPedSC5, {XC5->C5_NUM, 1})
			Else
				aPedSC5[aScan(aPedSC5, {|x| x[1] == XC5->C5_NUM})][2] += 1
			Endif
			DbSelectArea("XC5")
			DbSkip()
		Enddo
		DbSelectArea("XC5")
		DbCloseArea()
		If Len(aPedSC9) > 0.0
			cMsgSC9 := ''
			cMsgSC9 += 'O(s) pedido(s) abaixo, esta(ão) com problema na liberação de crédito!'+chr(13)+chr(10)
			cMsgSC9 += '                  AVISAR A ADMINISTRAÇÃO DO SISTEMA                  '+chr(13)+chr(10)
			For nY := 1 To Len(aPedSC9)
				cMsgSC9 += Transform(aPedSC9[nY][2], "@E 9999")+' item(ns) do pedido: '+aPedSC9[nY][1]+'.'+chr(13)+chr(10)
			Next
		Endif
		If Len(aPedSC5) > 0.0
			cMsgSC5 := ''
			cMsgSC5 += 'O(s) pedido(s) abaixo, esta(ão) com problema na liberação de crédito!'+chr(13)+chr(10)
			cMsgSC5 += '                  AVISAR A ADMINISTRAÇÃO DO SISTEMA                  '+chr(13)+chr(10)
			For nY := 1 To Len(aPedSC5)
				cMsgSC5 += 'Pedido: '+aPedSC5[nY][1]+'.'+chr(13)+chr(10)
			Next
		Endif
	Endif
Return

/******************************************************************************************************************/
/*** FATA03RE - Faz a liberação de estoque do pedido permitindo que neste momento seja feita a reserva dos itens***/
/*** FATA03RE - no estoque	 12/05/14               															***/

User Function FATA03RE()

Return


/******************************************************************************************************************/
/*** FATA03_3 - Consulta da posição do pedido em relação aos borderos.                                          ***/
/***            fMonArq - Monta arquivo de trabalho para borderos que contem o produto.                         ***/
/***            fMarDes - Marca e desmarca pedidos em bordero de despacho.                                      ***/
/***            fMarPed - Marca e desmarca pedidos em bordero de pedidos.                                       ***/
/***            fAtuRet - Atualiza pedidos retirados e/ou produção.                                             ***/
/***            fValPro - Valida produto e monta browses de borderos de pedidos/despacho.                       ***/
/***                      fMonDad - Monta browses dos borderos com dados do produto.                            ***/
/******************************************************************************************************************/
User Function FATA03_3(cOpc)
	//Local nOpcC   := 0
	Local cDesPro := space(30)
	Local cCodLoc := space(15)
	Local nSalEst := 0
	Local nQtdOrd := 0
	Local nQtdSep3 := 0
	Local nQtdG3  := 0
	//   Local nQtdA3  := 0   // Jose 05/07/2024
	Local nQtdApt := 0
	Local aHeaPED := {}
	Local aDespac := {}
	Local lSaidaC := .f.
	Local aCodLot := {}
	Local cCodLot := ""
	Local lInverte := .f.
	Local cFecha  := '       '
	Local aFecha  := {'       ', 'TOTAL  ', 'PARCIAL'}
	Private cCodPro := space(15)
	Private oOK   := LoadBitmap( GetResources(), "ENABLE"  )
	Private oNo   := LoadBitmap( GetResources(), "DISABLE" )
	Private hOK   := LoadBitmap( GetResources(), "LBTIK"   )
	Private hNo   := LoadBitmap( GetResources(), "LBNO"    )
	Private oTempTbl7
	aAdd(aDespac, {.t., .f., space(06), space(06), space(40), Ctod('  /  / '), space(06), 0, space(03), space(03), space(01), ''})
	fMonArq()

	aadd(aHeaPED, {"PED_FLAG"  , "", OemToAnsi(""           ), ""               } )
	aadd(aHeaPED, {"PED_NUMBOR", "", OemToAnsi("Bord. Ped." ), "999999"         } )
	aadd(aHeaPED, {"PED_EMISSA", "", OemToAnsi("Emissão"    ), ""               } )
	aadd(aHeaPED, {"PED_PEDIDO", "", OemToAnsi("Pedido"     ), "999999"         } )
	aadd(aHeaPED, {"PED_QUANTI", "", OemToAnsi("Quantidade" ), "@E 99,999.9999" } )
	aadd(aHeaPED, {"PED_GAVETA", "", OemToAnsi("Gaveta"     ), ""               } )
	aadd(aHeaPED, {"PED_LOCEXP", "", OemToAnsi("Expedição"  ), ""               } )
	aadd(aHeaPED, {"PED_LOCAL",  "", OemToAnsi("Local"      ), ""               } ) // Jose 21/08/2024


	DEFINE MSDIALOG oDlgC FROM 000,000 TO 032,100 TITLE OemToAnsi("Consulta Produto") OF oMainWnd
	DEFINE FONT oFont  SIZE 9,0 BOLD
	DEFINE FONT oFont1 SIZE 7,0 BOLD
	@ 002, 657 BTNBMP oBtnSCo RESOURCE "CANCEL"         SIZE 127,24 ACTION(lSaidaC := .t., oDlgC:End()) PIXEL OF oDlgC
	oBtnSCo:cCaption := PADR(OemToAnsi("Sair Consulta"), 20)
	oBtnSCo:cToolTip := OemToAnsi("Sai da consulta de Produtos...")
	oBtnLoc := TButton():New( 001, 100, "Localização", oDlgC, { || fAbrLoc() }, 037, 012, , , , .T., , "", , , , .F. )
	@ 002, 510 BTNBMP oBtnCEv RESOURCE "CONTAINR" SIZE 127,024 ACTION(fConNecPed(1, cCodPro)             ) PIXEL OF oDlgC
	oBtnCEv:cCaption := PADR(OemToAnsi("Cons. Neces."), 20)
	oBtnCEv:cToolTip := OemToAnsi("Consultar necessidade do envase...")

	@ 002, 363 BTNBMP oBtnCPe RESOURCE "ANALITICO" SIZE 127,024 ACTION(fConNecPed(2, cCodPro)              ) PIXEL OF oDlgC
	oBtnCPe:cCaption := PADR(OemToAnsi("Pedidos"), 20)
	oBtnCPe:cToolTip := OemToAnsi("Consultar ultimos pedidos...")

	@ 014, 001 GROUP oGrp2 TO 015,395 LABEL OemToAnsi('')                        COLOR CLR_HRED PIXEL OF oDlgC
	@ 014, 001 SAY   OemToAnsi("Produto")                           SIZE 030,009                PIXEL OF oDlgC
	@ 022, 001 MSGET oCodPro VAR cCodPro PICTURE "@R!"              SIZE 080,10 COLOR CLR_BLUE PIXEL OF oDlgC FONT oFont
	@ 014, 086 SAY   OemToAnsi("Descrição")                         SIZE 030,009                PIXEL OF oDlgC
	@ 022, 086 MSGET oDesPro VAR cDesPro PICTURE "@!"               SIZE 210,10 COLOR CLR_BLUE PIXEL OF oDlgC FONT oFont
	@ 014, 301 SAY   OemToAnsi("Localização")                       SIZE 050,009                PIXEL OF oDlgC
	@ 022, 301 MSGET oCodLoc VAR cCodLoc PICTURE "@!"               SIZE 090,10 COLOR CLR_BLUE PIXEL OF oDlgC FONT oFont

	@ 034, 001 GROUP oGrp0 TO 069,395 LABEL OemToAnsi('Produção / Estoque...' )  COLOR CLR_HRED PIXEL OF oDlgC
	@ 040, 003 SAY   OemToAnsi("Saldo Almox Padrão")                       SIZE 055,009                PIXEL OF oDlgC
	@ 048, 003 MSGET oSalEst VAR nSalEst PICTURE "@E 99999"         SIZE 040,10 COLOR CLR_BLUE PIXEL OF oDlgC FONT oFont

	@ 080, 370 BTNBMP oBtnEnv RESOURCE "SUMARIO" SIZE 127,050 ACTION(fBaiOPE(cCodPro, @aCodLot, @oQtdPro, @nQtdOrd, @oQtdSep3, @nQtdSep3, @oQtdG3, @nQtdG3, @oQtdApt, @nQtdApt, aDespac, @cFecha, @oFecha)) PIXEL OF oDlgC
	oBtnEnv:cCaption := PADR(OemToAnsi("Lotes em Produção"), 20)
	oBtnEnv:cToolTip := OemToAnsi("Marcar Lotes para apontamento de produção do envase...")

	@ 036, 250 SAY   OemToAnsi("Qtde. O.P.")                        SIZE 030,009                PIXEL OF oDlgC
	@ 043, 250 MSGET oQtdPro VAR nQtdOrd PICTURE "@E 9999"          SIZE 030,10 COLOR CLR_BLUE PIXEL OF oDlgC FONT oFont
	@ 036, 285 SAY   OemToAnsi("Marcados")                          SIZE 030,009                PIXEL OF oDlgC
	@ 043, 285 MSGET oQtdSep3 VAR nQtdSep3 PICTURE "@E 9999"          SIZE 030,10 COLOR CLR_BLUE PIXEL OF oDlgC FONT oFont
	@ 036, 320 SAY   OemToAnsi("Estoque")                           SIZE 030,009                PIXEL OF oDlgC
	@ 043, 320 MSGET oQtdG3 VAR nQtdG3 PICTURE "@E 9999"          SIZE 030,10 COLOR CLR_BLUE PIXEL OF oDlgC FONT oFont
	@ 036, 355 SAY   OemToAnsi("TOTAL")                             SIZE 030,009                PIXEL OF oDlgC
	@ 043, 355 MSGET oQtdApt VAR nQtdApt PICTURE "@E 9999"          SIZE 030,10 COLOR CLR_BLUE PIXEL OF oDlgC FONT oFont
	@ 055, 320 MSCOMBOBOX oFecha VAR cFecha ITEMS aFecha            SIZE 065,007 COLOR CLR_BLUE PIXEL OF oDlgC FONT oFont1

	@ 069, 001 GROUP oGrp1 TO 149,510 LABEL OemToAnsi('Bordero de Despacho...') COLOR CLR_HRED PIXEL OF oDlgC // Jose 05/07/2024  395
	@ 074, 003 LISTBOX oDespac VAR cDespac FIELDS HEADER '','',"Despacho", "Bord. Ped.", "Região", "Previsão", "Pedido", "Quantidade", "Gaveta", "Expedição", '' ON DBLCLICK (fMarDes(@nQtdSep3, @oQtdSep3, @nQtdG3, @oQtdG3, @nQtdApt, @oQtdApt, @aCodLot, @cCodLot, nQtdOrd, @cFecha, @oFecha)) SIZE 390,070 OF oDlgC PIXEL
	oDespac:SetArray(aDespac)
	oDespac:bLine:= { || {Iif(aDespac[oDespac:nAt][1], oOk, oNo), Iif(aDespac[oDespac:nAt][2], hOk, hNo), aDespac[oDespac:nAt][3], aDespac[oDespac:nAt][4], aDespac[oDespac:nAt][5], aDespac[oDespac:nAt][6], aDespac[oDespac:nAt][7], aDespac[oDespac:nAt][8], oDespac:aArray[oDespac:nAt][10], oDespac:aArray[oDespac:nAt][9], oDespac:aArray[oDespac:nAt][12]}}

	@ 149, 001 GROUP oGrp2 TO 229,510 LABEL OemToAnsi('Bordero de Pedidos....')    COLOR CLR_HRED  PIXEL OF oDlgC // Jose 05/07/2024 395
	DbSelectArea("PED")
	oPED := MsSelect():New("PED", "PED_FLAG", , aHeaPED, @lInverte, "XX", {154, 003, 224, 393}, , , oDlgC)
	oPED:oBrowse:lHasMark := .t.
	oPED:oBrowse:lCanAllMark := .t.
	oPED:bMark := {|| fMarPed(@nQtdSep3, @oQtdSep3, @nQtdG3, @oQtdG3, @nQtdApt, @oQtdApt, @aCodLot, @cCodLot, nQtdOrd)}
	oPED:oBrowse:Refresh()

	@ 460,679 BTNBMP oBtnCon RESOURCE "OK" SIZE 110,24 ACTION(fAtuRet(cCodPro, cOpc, @aDespac, @oDespac, @aCodLot, @nQtdOrd, @oQtdPro, @nQtdSep3, @oQtdSep3, @nQtdG3, @oQtdG3, @nQtdApt, @oQtdApt, @cFecha, @oFecha))   PIXEL OF oDlgC
	oCodPro:bLostFocus := {|| fValPro(@oCodPro, @cCodPro, @oDesPro, @cDesPro, @oCodLoc, @cCodLoc, cOpc, @aDespac, @nSalEst, @oSalEst, @aCodLot, @nQtdOrd, @oQtdPro, @nQtdSep3, @oQtdSep3, @nQtdG3, @oQtdG3, @nQtdApt, @oQtdApt)}
	oQtdG3:bLostFocus := {|| fValEst(@oQtdSep3, @nQtdSep3, @oQtdG3, @nQtdG3, @oQtdApt, @nQtdApt, nQtdOrd, aCodLot, @cFecha, @oFecha)}
	oDesPro:lReadOnly := .t. ; oCodLoc:lReadOnly := .t.
	oSalEst:lReadOnly := .t. ; oQtdPro:lReadOnly := .t. ; oQtdSep3:lReadOnly := .t. ; oQtdApt:lReadOnly := .t.
	oBtnCon:cCaption := PADR(OemToAnsi("Atualizar"), 20)
	oBtnCon:cToolTip := OemToAnsi("Atualiza retirada dos itens marcados...")
	//oBtnCon:lReadOnly:= .t.
	oDlgC:nStyle    := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
	ACTIVATE MSDIALOG oDlgC VALID lSaidaC CENTERED
	oTempTbl7:Delete()
Return

Static Function fValEst(oQtdSep3, nQtdSep3, oQtdG3, nQtdG3, oQtdApt, nQtdApt, nQtdOrd, aCodLot, cFecha, oFecha)
	If nQtdG3 < 0
		MsgBox("Quantidade não pode ser menor que zero.", "Atenção", "STOP")
		nQtdG3 := 0
		oQtdG3:Refresh()
		oQtdG3:SetFocus()
		Return(.f.)
	Endif
	If Len(aCodLot) == 1 .and. aCodLot[1][2] $ 'TRANSF'
		If aCodLot[1][1]
			nQtdApt := nQtdSep3 + nQtdG3
			cFecha  := '       '
		Else
			nQtdG3 := 0
			cFecha  := '       '
		Endif
	Else
		If nQtdOrd > 0
			nQtdApt := nQtdSep3 + nQtdG3
			If nQtdApt > 0
				If nQtdApt < nQtdOrd
					cFecha  := 'PARCIAL'
				Else
					cFecha  := 'TOTAL'
				Endif
			Else
				cFecha  := '       '
			Endif
		Else
			nQtdG3 := 0
			cFecha  := '       '
		Endif
	Endif
	oFecha:Refresh()
	oQtdG3:Refresh()
	oQtdApt:Refresh()
Return(.t.)

Static Function fBaiOPE(cCodPro, aCodLot, oQtdPro, nQtdOrd, oQtdSep3, nQtdSep3, oQtdG3, nQtdG3, oQtdApt, nQtdApt, aDespac, cFecha, oFecha)
	Private oNoK  := LoadBitmap( Getresources(), "LBNO"    )
	Private oTiK  := LoadBitmap( Getresources(), "LBTIK"   )
	If Empty(cCodPro)
		Return
	Endif
	If Len(aCodLot) <= 0
		aAdd(aCodLot, {.f., 'TRANSF', 0, ''})
	Endif
	DEFINE MSDIALOG oDlgB FROM 000,000 TO 10,020 TITLE OemToAnsi("Baixa de Ops. Envase") OF oMainWnd
	DEFINE FONT oFont2 NAME 'ARIAL BACK' SIZE 08,0 BOLD
	@ 002, 002 LISTBOX oCodLot VAR cCodLot FIELDS HEADER '', 'Lote' ON DBLCLICK(fMarOPE(cCodPro, aCodLot, @nQtdOrd, @nQtdSep3, @nQtdG3, @nQtdApt, aDespac, @cFecha, @oFecha)) SIZE 077,073 PIXEL OF oDlgB FONT oFont
	oCodLot:SetArray(aCodLot)
	oCodLot:bLine := { || {Iif(aCodLot[oCodLot:nAt][1], oTiK, oNoK), aCodLot[oCodLot:nAt][2], aCodLot[oCodLot:nAt][3] }}
	oCodLot:Refresh()
	ACTIVATE MSDIALOG oDlgB CENTERED
Return

Static Function fMarOPE(cCodPro, aCodLot, nQtdOrd, nQtdSep3, nQtdG3, nQtdApt, aDespac, cFecha, oFecha)
	Local nY
	If !aCodLot[oCodLot:nAt][2] $ 'TRANSF'
		cQry1 := ""
		cQry1 += "SELECT C2_NUM,C2_ITEM,C2_SEQUEN "
		cQry1 += "FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "
		cQry1 += "WHERE SC2.C2_FILIAL  = '"+xFilial("SC2")+"' "
		cQry1 += "  AND SC2.D_E_L_E_T_ = '' "
		cQry1 += "  AND SC2.C2_LOTE    = '"+aCodLot[oCodLot:nAt][2]+"' "
		cQry1 += "  AND SC2.C2_PRODUTO = '"+Alltrim(SubStr(StrTran(StrTran(cCodPro, "."), "-"), 1, 10))+"00' "
		TCQuery cQry1 ALIAS "TCQ" NEW
		If !Empty(TCQ->C2_NUM)
			cQry1 := ""
			cQry1 += "SELECT * "
			cQry1 += "FROM PRODUCAO PRO WITH (NOLOCK) "
			cQry1 += "WHERE ('"+xFilial("SC2")+"' = '010101') AND (PRO.ORDEM = '"+TCQ->C2_NUM+TCQ->C2_ITEM+TCQ->C2_SEQUEN+"') "
			cQry1 += "  AND PRO.LOTE  = '"+aCodLot[oCodLot:nAt][2]+"' "
			TCQuery cQry1 ALIAS "APT" NEW
			If !Empty(APT->ORDEM)
				If Empty(APT->FIM)
					MsgBox("Ordem de produção para o PI não foi finalizada!", "ATENÇÃO", "STOP")
					DbSelectArea("TCQ")
					DbCloseArea()
					DbSelectArea("APT")
					DbCloseArea()
					Return(.f.)
				Else
					DbSelectArea("TCQ")
					DbCloseArea()
					DbSelectArea("APT")
					DbCloseArea()
				Endif
			Else
				MsgBox("Ordem de produção para o PI não foi apontada!", "ATENÇÃO", "STOP")
				DbSelectArea("TCQ")
				DbCloseArea()
				DbSelectArea("APT")
				DbCloseArea()
				Return(.f.)
			Endif
		Else
			MsgBox("Não foi encontrada Ordem de produção para o PI. Pode ser que tenha sido excluido!", "ATENÇÃO", "STOP")
			DbSelectArea("TCQ")
			DbCloseArea()
			Return(.f.)
		Endif
	Endif
	aCodLot[oCodLot:nAt][1] := Iif(!Empty(aCodLot[oCodLot:nAt][2]), !aCodLot[oCodLot:nAt][1], aCodLot[oCodLot:nAt][1])
	nQtdOrd := 0
	nQtdSep3 := 0
	For nY := 1 To Len(aCodLot)
		If aCodLot[nY][1]
			//nQtdOrd += aCodLot[nY][3]
			//Buscar Quantidade pendente para esse lote
			cQry1 := ""
			cQry1 += "SELECT SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN AS NUMERO, (SC2.C2_QUANT - SC2.C2_QUJE) AS PENDENTE "
			cQry1 += "FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "
			cQry1 += "WHERE SC2.C2_FILIAL  = '"+xFilial("SC2")+"' "
			cQry1 += "  AND SC2.D_E_L_E_T_ = '' "
			cQry1 += "  AND SC2.C2_LOTE    = '"+aCodLot[oCodLot:nAt][2]+"' "
			cQry1 += "  AND SC2.C2_PRODUTO = '"+StrTran(StrTran(cCodPro, "."), "-")+"' "
			TCQuery cQry1 ALIAS "TCQ" NEW
			DbSelectArea("TCQ")
			cNumOrd := TCQ->NUMERO
			nQtdOrd += TCQ->PENDENTE
			DbSelectArea("TCQ")
			DbCloseArea()

			cQry1 := ""
			cQry1 += "SELECT SUM(ISNULL(EMP.QUANT, 0.0)) AS QUANT "
			cQry1 += "FROM EMPENHO EMP "
			cQry1 += "WHERE ('"+xFilial("SC2")+"' = '010101') AND (EMP.ORDEM  = '"+cNumOrd+"') "
			cQry1 += "  AND EMP.LOTE   = '"+aCodLot[oCodLot:nAt][2]+"' "
			cQry1 += "  AND EMP.CODIGO = '"+StrTran(StrTran(cCodPro, "."), "-")+"' "
			cQry1 += "  AND EMP.FLAG   = '' "
			TCQuery cQry1 ALIAS "TCQ" NEW
			DbSelectArea("TCQ")
			nQtdOrd -= TCQ->QUANT
			DbSelectArea("TCQ")
			DbCloseArea()
			If nQtdOrd <= 0.0
				aCodLot[nY][1] := !aCodLot[nY][1]
				nQtdOrd := 0
			Endif
		Endif
	Next
	For nY := 1 TO Len(aDespac)
		If aDespac[nY][2]
			nQtdSep3 += aDespac[nY][8]
		Endif
	Next
	DbSelectArea("PED")
	DbGoTop()
	While !Eof()
		If MarKed("PED_FLAG")
			nQtdSep3 += PED_QUANTI
		Endif
		DbSelectArea("PED")
		DbSkip()
	Enddo
	DbSelectArea("PED")
	DbGoTop()
	If nQtdOrd <= 0
		nQtdApt := 0
		nQtdSep3 := 0
		nQtdG3 := 0
		cFecha  := '       '
	Else
		nQtdApt := nQtdSep3 + nQtdG3
		If nQtdApt > 0
			If nQtdApt < nQtdOrd
				cFecha  := 'PARCIAL'
			Else
				cFecha  := 'TOTAL'
			Endif
		Else
			cFecha  := '       '
		Endif
	Endif
	oFecha:Refresh()
	oQtdPro:Refresh() ; oQtdSep3:Refresh() ; oQtdG3:Refresh() ; oQtdApt:Refresh()
Return

Static Function fConNecPed(nOpc, cCodPro)
	If !Empty(cCodPro)
		If nOpc == 1
			aMatEmb := {}
			cQry1 := ""
			cQry1 += "SELECT SUBSTRING(ZZC.ZZC_PRODUT, 11, 2) AS EMBALAGEM, SUM(ZZC.ZZC_QUANTI - ZZC.ZZC_RETIRA) AS QUANTIDADE "
			cQry1 += "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
			cQry1 += "WHERE ZZC.ZZC_FILIAL  = '"+xFilial("ZZC")+"' "
			cQry1 += "  AND ZZC.D_E_L_E_T_ = '' "
			cQry1 += "  AND ZZC.ZZC_DESPAC NOT IN('S') "
			cQry1 += "  AND ZZC.ZZC_SEPARA NOT IN('S') "
			cQry1 += "  AND ZZC.ZZC_GAVETA <> '' "
			cQry1 += "  AND SUBSTRING(ZZC.ZZC_PRODUT, 1, 10) = '"+SubStr(Alltrim(StrTran(StrTran(cCodPro, '.'), '-')), 1, 10)+"' "
			cQry1 += "GROUP BY SUBSTRING(ZZC.ZZC_PRODUT, 11, 2) "
			cQry1 += "ORDER BY 1 "

			TCQuery cQry1 ALIAS "TCQ" NEW
			DbSelectArea("TCQ")
			While !Eof()
				nPos := aScan(aMatEmb, {|x| x[1] == TCQ->EMBALAGEM})
				If nPos == 0
					aAdd(aMatEmb, {TCQ->EMBALAGEM, TCQ->QUANTIDADE, 0, TCQ->QUANTIDADE})
				Else
					aMatEmb[nPos][2] += TCQ->QUANTIDADE
					aMatEmb[nPos][4] += TCQ->QUANTIDADE
				Endif
				DbSelectArea("TCQ")
				DbSkip()
			Enddo
			DbSelectArea("TCQ")
			DbCloseArea()

			cQry1 := ""
			cQry1 += "SELECT SUBSTRING(ZZC.ZZC_PRODUT, 11, 2) AS EMBALAGEM, SUM(ZZC.ZZC_QUANTI - ZZC.ZZC_RETIRA) AS QUANTIDADE "
			cQry1 += "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
			cQry1 += "WHERE ZZC.ZZC_FILIAL  = '"+xFilial("ZZC")+"' "
			cQry1 += "  AND ZZC.D_E_L_E_T_ = '' "
			cQry1 += "  AND ZZC.ZZC_DESPAC NOT IN('S') "
			cQry1 += "  AND ZZC.ZZC_SEPARA NOT IN('S') "
			cQry1 += "  AND ZZC.ZZC_GAVETA = '' "
			cQry1 += "  AND SUBSTRING(ZZC.ZZC_PRODUT, 1, 10) = '"+SubStr(Alltrim(StrTran(StrTran(cCodPro, '.'), '-')), 1, 10)+"' "
			cQry1 += "GROUP BY SUBSTRING(ZZC.ZZC_PRODUT, 11, 2) "
			cQry1 += "ORDER BY 1 "
			TCQuery cQry1 ALIAS "TCQ" NEW
			DbSelectArea("TCQ")
			While !Eof()
				nPos := aScan(aMatEmb, {|x| x[1] == TCQ->EMBALAGEM})
				If nPos == 0
					aAdd(aMatEmb, {TCQ->EMBALAGEM, 0, TCQ->QUANTIDADE, TCQ->QUANTIDADE})
				Else
					aMatEmb[nPos][3] += TCQ->QUANTIDADE
					aMatEmb[nPos][4] += TCQ->QUANTIDADE
				Endif
				DbSelectArea("TCQ")
				DbSkip()
			Enddo
			DbSelectArea("TCQ")
			DbCloseArea()
			aSort(aMatEmb, , , {|x, y| x[1] < y[1]})
			If Len(aMatEmb) > 0
				DEFINE MSDIALOG oDlgM TITLE OemToAnsi("") From 9,0 to 20,48 of oMainWnd
				@ 001, 003 LISTBOX oQtdEmb VAR cQtdEmb FIELDS HEADER 'Embalagem','Gaveta','Outros', 'TOTAL' SIZE 185,080 OF oDlgM PIXEL
				oQtdEmb:SetArray(aMatEmb)
				oQtdEmb:bLine:= { || {aMatEmb[oQtdEmb:nAt][1], aMatEmb[oQtdEmb:nAt][2], aMatEmb[oQtdEmb:nAt][3], aMatEmb[oQtdEmb:nAt][4]}}
				oDlgM:nStyle    := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
				ACTIVATE MSDIALOG oDlgM CENTERED
			Else
				ApMsgStop('Não existe necessidade especifica para esse produto')
			Endif
		ElseIf nOpc == 2
			aMatEmb := {}
			lProEst := !Empty(Posicione("SB2", 1, xFilial("SB2")+Posicione("SB1", 1, xFilial("SB1")+Alltrim(StrTran(StrTran(cCodPro, '.'), '-')), "B1_LOCPAD"), "B2_LOCALIZ"))
			cQry1 := ""
			cQry1 += "SELECT TOP 15 SC6.C6_FILIAL, SC6.C6_NUM, SC6.C6_QTDVEN, SC6.C6_VOLITEM, "+;
				"SC5.C5_VOLUME1, SC5.C5_PEDPROG, SC6.D_E_L_E_T_ AS DELETADO, SC6.R_E_C_N_O_, (SELECT SUM(TC6.C6_PALLET) "+;
				"FROM "+RetSqlName("SC6")+" TC6 WHERE TC6.C6_FILIAL = SC6.C6_FILIAL AND TC6.D_E_L_E_T_ = '' AND TC6.C6_NUM = SC6.C6_NUM) AS PALLETS "
			cQry1 += "FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "
			cQry1 += "LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.C5_FILIAL = SC6.C6_FILIAL) AND (SC5.C5_NUM = SC6.C6_NUM) "
			cQry1 += "WHERE (SC6.D_E_L_E_T_ <> '*') AND (SC6.C6_FILIAL  = '"+xFilial("SC6")+"') "
			cQry1 += "  AND SC6.C6_PRODUTO = '"+Alltrim(StrTran(StrTran(cCodPro, '.'), '-'))+"' "
			cQry1 += "  AND SC6.C6_NOTA    = '' "
			cQry1 += "ORDER BY SC6.R_E_C_N_O_ DESC "
			TCQuery cQry1 ALIAS "TCQ" NEW
			DbSelectArea("TCQ")
			While !Eof()
				cQry1 := ""
				cQry1 += "SELECT TOP 1 ZZB_IDLOG,ZZB_DATLOG,ZZB_HORLOG "
				cQry1 += "FROM "+RetSqlName("ZZB")+" ZZB WITH (NOLOCK) "
				cQry1 += "WHERE ZZB.ZZB_FILIAL = '"+xFilial("ZZB")+"' "
				cQry1 += "  AND ZZB.D_E_L_E_T_ = '' "
				cQry1 += "  AND ZZB.ZZB_PEDIDO = '"+TCQ->C6_NUM+"' "
				cQry1 += "  AND ZZB.ZZB_IDLOG IN('INC', 'ALT', 'EXC', 'LCA', 'LVE', 'LCR', 'LDI', 'APR') "
				cQry1 += "ORDER BY ZZB.ZZB_DATLOG+ZZB.ZZB_HORLOG DESC "
				TCQuery cQry1 ALIAS "TLG" NEW
				DbSelectArea("TLG")
				cLogPed := ""
				If TLG->ZZB_IDLOG $ 'INC'
					cLogPed := TLG->ZZB_IDLOG+' - Inclusão - '+SubStr(TLG->ZZB_DATLOG, 7, 2)+'/'+SubStr(TLG->ZZB_DATLOG, 5, 2)+'/'+SubStr(TLG->ZZB_DATLOG, 1, 4)+' - '+TLG->ZZB_HORLOG
				ElseIf TLG->ZZB_IDLOG $ 'ALT'
					cLogPed := TLG->ZZB_IDLOG+' - Alteração - '+SubStr(TLG->ZZB_DATLOG, 7, 2)+'/'+SubStr(TLG->ZZB_DATLOG, 5, 2)+'/'+SubStr(TLG->ZZB_DATLOG, 1, 4)+' - '+TLG->ZZB_HORLOG
				ElseIf TLG->ZZB_IDLOG $ 'EXC'
					cLogPed := TLG->ZZB_IDLOG+' - Exclusão - '+SubStr(TLG->ZZB_DATLOG, 7, 2)+'/'+SubStr(TLG->ZZB_DATLOG, 5, 2)+'/'+SubStr(TLG->ZZB_DATLOG, 1, 4)+' - '+TLG->ZZB_HORLOG
				ElseIf TLG->ZZB_IDLOG $ 'LCA'
					cLogPed := TLG->ZZB_IDLOG+' - Liberação Cadastro - '+SubStr(TLG->ZZB_DATLOG, 7, 2)+'/'+SubStr(TLG->ZZB_DATLOG, 5, 2)+'/'+SubStr(TLG->ZZB_DATLOG, 1, 4)+' - '+TLG->ZZB_HORLOG
				ElseIf TLG->ZZB_IDLOG $ 'LVE'
					cLogPed := TLG->ZZB_IDLOG+' - Liberação Vendas - '+SubStr(TLG->ZZB_DATLOG, 7, 2)+'/'+SubStr(TLG->ZZB_DATLOG, 5, 2)+'/'+SubStr(TLG->ZZB_DATLOG, 1, 4)+' - '+TLG->ZZB_HORLOG
				ElseIf TLG->ZZB_IDLOG $ 'LCR'
					cLogPed := TLG->ZZB_IDLOG+' - Liberação Credito - '+SubStr(TLG->ZZB_DATLOG, 7, 2)+'/'+SubStr(TLG->ZZB_DATLOG, 5, 2)+'/'+SubStr(TLG->ZZB_DATLOG, 1, 4)+' - '+TLG->ZZB_HORLOG
				ElseIf TLG->ZZB_IDLOG $ 'LDI'
					cLogPed := TLG->ZZB_IDLOG+' - Liberação Diretoria - '+SubStr(TLG->ZZB_DATLOG, 7, 2)+'/'+SubStr(TLG->ZZB_DATLOG, 5, 2)+'/'+SubStr(TLG->ZZB_DATLOG, 1, 4)+' - '+TLG->ZZB_HORLOG
				ElseIf TLG->ZZB_IDLOG $ 'APR'
					cLogPed := TLG->ZZB_IDLOG+' - Aprovação - '+SubStr(TLG->ZZB_DATLOG, 7, 2)+'/'+SubStr(TLG->ZZB_DATLOG, 5, 2)+'/'+SubStr(TLG->ZZB_DATLOG, 1, 4)+' - '+TLG->ZZB_HORLOG
				Endif
				DbSelectArea("TLG")
				DbCloseArea()

				cNumPed := TCQ->C6_NUM
				nQtdPed := TransForm(TCQ->C6_QTDVEN, "@E 999999")
				cBorPed := Posicione("SZG", 2, xFilial("SZG")+TCQ->C6_FILIAL+TCQ->C6_NUM, "ZG_CODIGO")
				cBorDes := Posicione("SZB", 2, xFilial("SZB")+TCQ->C6_FILIAL+TCQ->C6_NUM, "ZB_CODIGO")+' - '+Posicione("SZA", 1, xFilial("SZA")+Posicione("SZB", 2, xFilial("SZB")+TCQ->C6_FILIAL+TCQ->C6_NUM, "ZB_CODIGO"), "ZA_DESCR")+' - '+DTOC(Posicione("SZA", 1, xFilial("SZA")+Posicione("SZB", 2, xFilial("SZB")+TCQ->C6_FILIAL+TCQ->C6_NUM, "ZB_CODIGO"), "ZA_PREVDSP"))
				nVolIte := TransForm(TCQ->C6_VOLITEM, "@E 9999" )
				nVolPed := TransForm(TCQ->C5_VOLUME1, "@E 9999" )
				nTotPal := TransForm(TCQ->PALLETS   , "@E 99.99")
				cSepara := Iif(Empty(Posicione("ZZC", 2, xFilial("ZZC")+TCQ->C6_NUM+Alltrim(StrTran(StrTran(cCodPro, '.'), '-')), "ZZC_SEPARA")), 'Não', Iif(Posicione("ZZC", 2, xFilial("ZZC")+TCQ->C6_NUM+Alltrim(StrTran(StrTran(cCodPro, '.'), '-')), "ZZC_SEPARA") $ 'N', 'Não', 'Sim'))

				aAdd(aMatEmb, {cNumPed, nQtdPed, cBorPed, cBorDes, nVolIte, nVolPed, nTotPal, cSepara, SubStr(TCQ->C5_PEDPROG, 7, 2)+'/'+SubStr(TCQ->C5_PEDPROG, 5, 2)+'/'+SubStr(TCQ->C5_PEDPROG, 1, 4), cLogPed, Iif(TCQ->DELETADO = '*', 'Item Excluido', '')})
				DbSelectArea("TCQ")
				DbSkip()
			Enddo
			DbSelectArea("TCQ")
			DbCloseArea()

			//aSort(aMatEmb, , , {|x, y| x[1] < y[1]})
			If Len(aMatEmb) > 0
				cEndExp := Space(09)
				DEFINE MSDIALOG oDlgM TITLE OemToAnsi("Pedidos do item") From 10,018 to 29,98 of oMainWnd
				@ 001, 003 LISTBOX oLstExp VAR cLstExp FIELDS HEADER 'Pedido', 'Qtde.', 'Bordero','Despacho', 'Vol. Item', 'Vol. Pedido', 'Pallet', 'Separado', 'Ped. Prog.', 'Status do Pedido', 'Status do Item' SIZE 310,110 OF oDlgM PIXEL
				oLstExp:SetArray(aMatEmb)
				oLstExp:bLine:= { || {aMatEmb[oLstExp:nAt][1], aMatEmb[oLstExp:nAt][2], aMatEmb[oLstExp:nAt][3], aMatEmb[oLstExp:nAt][4], aMatEmb[oLstExp:nAt][5], aMatEmb[oLstExp:nAt][6], aMatEmb[oLstExp:nAt][7], aMatEmb[oLstExp:nAt][8], aMatEmb[oLstExp:nAt][9], aMatEmb[oLstExp:nAt][10], aMatEmb[oLstExp:nAt][11]}}
				oLstExp:bChange := {|| fTroEnd() }
				oLstExp:lAdjustColSize := .t.
				oLstExp:aColSizes := {25, 15, 25, 160, 25, 25, 15, 25, 25, 117}

				oDlgM:nStyle    := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )

				@ 121, 001 SAY   oTxtExp VAR OemToAnsi("Expedição:")  SIZE 030,009                PIXEL OF oDlgM
				@ 120, 031 MSGET oEndExp VAR cEndExp PICTURE "@!"     SIZE 050,10 COLOR CLR_BLUE PIXEL OF oDlgM FONT oFont
				DEFINE SBUTTON oBtnCfr FROM 120,100 TYPE 1 ENABLE OF oDlgM ACTION(fGrvExp())
				ACTIVATE MSDIALOG oDlgM ON INIT fTroEnd()
			Else
				ApMsgStop('Não existe necessidade especifica para esse produto')
			Endif
		Endif
	Else
		ApMsgStop('Favor informar código do produto')
	Endif
Return

Static Function fTroEnd()
	If Empty(aMatEmb[oLstExp:nAt][3])
		If SubStr(aMatEmb[oLstExp:nAt][10], 1, 3) $ 'APR'
			If !lProEst
				oEndExp:lReadOnly := .f.
				oEndExp:SetFocus()
				cEndExp := Space(09)
			Else
				oEndExp:lReadOnly := .t.
				cEndExp := Space(09)
			Endif
		ElseIf SubStr(aMatEmb[oLstExp:nAt][10], 1, 3) $ 'EXC' .or. Empty(SubStr(aMatEmb[oLstExp:nAt][10], 1, 3))
			oEndExp:lReadOnly := .t.
			cEndExp := Space(09)
		Else
			oEndExp:lReadOnly := .f.
			cEndExp := Space(09)
			oEndExp:SetFocus()
		Endif
	Else
		DbSelectArea("SZG")
		DbSetOrder(2)
		DbSeek(xFilial("SZG")+'01'+aMatEmb[oLstExp:nAt][1], .t.)
		If Found()
			If Empty(SZG->ZG_LOCALIZ)
				If !lProEst
					oEndExp:lReadOnly := .f.
					oEndExp:SetFocus()
					cEndExp := Space(09)
				Else
					oEndExp:lReadOnly := .t.
				Endif
			Else
				oEndExp:lReadOnly := .t.
				cEndExp := SZG->ZG_LOCALIZ
			Endif
		Endif
	Endif
	oLstExp:Refresh()
	oEndExp:Refresh()
Return

Static Function fGrvExp()
	If !SubStr(aMatEmb[oLstExp:nAt][10], 1, 3) $ 'EXC'
		If Empty(cEndExp)
			Return
		Endif
		If Empty(aMatEmb[oLstExp:nAt][3])
			DbSelectArea("SZF")
			DbSetOrder(1)
			DbSeek(xFilial("SZF")+'000000', .t.)
			If !Found()
				RecLock("SZF", .t.)
				SZF->ZF_FILIAL  := xFilial("SZF")
				SZF->ZF_CODIGO  := '000000'
				SZF->ZF_EMISSAO := CTOD('01/01/2002')
				SZF->ZF_FLAG    := 'D'
				MsUnLock()
			EndIf
			DbSelectArea("SZG")
			DbSetOrder(2)
			DbSeek(xFilial("SZG")+substr(cNumEmp,1,2)+aMatEmb[oLstExp:nAt][3], .t.)
			If Found()
				RecLock("SZG", .f.)
				SZG->ZG_LOCALIZ := cEndExp
				cNumBor         := SZG->ZG_CODIGO
				MsUnLock()
			Else
				RecLock("SZG", .t.)
				SZG->ZG_FILIAL  := xFilial("SZG")
				SZG->ZG_CODIGO  := '000000'
				SZG->ZG_PEDIDO  := substr(cNumEmp,1,2)+aMatEmb[oLstExp:nAt][1]
				SZG->ZG_LOCALIZ := cEndExp
				cNumBor         := '000000'
				MsUnLock()
			Endif
			DbSelectArea("ZZC")
			DbSetOrder(2)
			DbSeek(xFilial("ZZC")+aMatEmb[oLstExp:nAt][1], .t.)
			If Found()
				While !Eof()
					RecLock("ZZC", .f.)
					ZZC->ZZC_LOCEXP := cEndExp
					MsUnLock()
					DbSelectArea("ZZC")
					DbSkip()
				Enddo
			Else //Senão encontrado incluí-los na tabela de reservas/retirada
				DbSelectArea("SC6")
				DbSetOrder(1)
				DbSeek(xFilial("SC6")+aMatEmb[oLstExp:nAt][1], .t.)
				If Found()
					While !Eof() .and. (SC6->C6_FILIAL == xFilial("SC6")) .and. SC6->C6_NUM == aMatEmb[oLstExp:nAt][1]

						RecLock("ZZC", .t.)
						ZZC->ZZC_FILIAL := xFilial("SC6")
						ZZC->ZZC_BORDER := '000000'
						ZZC->ZZC_PEDIDO := SC6->C6_NUM
						ZZC->ZZC_PRODUT := SC6->C6_PRODUTO
						ZZC->ZZC_QUANTI := SC6->C6_QTDVEN
						ZZC->ZZC_RETIRA := 0.0
						ZZC->ZZC_RESERV := 0.0
						ZZC->ZZC_GAVETA := Iif(Empty(Posicione("SB2", 1, xFilial("SB2")+SC6->C6_PRODUTO+Posicione("SB1", 1, xFilial("SB1")+SC6->C6_PRODUTO, "B1_LOCPAD"), "B2_LOCALIZ")), '000', '')
						ZZC->ZZC_VOLUME := SC6->C6_VOLITEM
						ZZC->ZZC_VOLRET := 0.0
						ZZC->ZZC_CARGA  := ''
						ZZC->ZZC_OCUPAC := 0.0
						ZZC->ZZC_DESPAC := ''
						ZZC->ZZC_SEPARA := 'N'
						ZZC->ZZC_LOTE   := ''
						ZZC->ZZC_SEMID  := ''
						ZZC->ZZC_DTHOT  := ''
						ZZC->ZZC_TPINCL := ''
						ZZC->ZZC_LOCEXP := cEndExp
						MsUnLock()
						DbSelectArea("SC6")
						DbSkip()
					EndDo
				Endif
			Endif
			aMatEmb[oLstExp:nAt][3] := '000000'
		Else
			DbSelectArea("SZG")
			DbSetOrder(1)
			DbSeek(xFilial("SZG")+aMatEmb[oLstExp:nAt][3], .t.)
			If Found()
				RecLock("SZG", .f.)
				SZG->ZG_LOCALIZ := cEndExp
				MsUnLock()
			Endif
			DbSelectArea("ZZC")
			DbSetOrder(2)
			DbSeek(xFilial("ZZC")+aMatEmb[oLstExp:nAt][1], .t.)
			If Found()
				While !Eof() .and. (ZZC->ZZC_FILIAL == xFilial("ZZC")) .and. ZZC->ZZC_BORDER == aMatEmb[oLstExp:nAt][3] .and. ZZC->ZZC_PEDIDO == aMatEmb[oLstExp:nAt][1]
					RecLock("ZZC", .f.)
					ZZC->ZZC_LOCEXP := cEndExp
					MsUnLock()
					DbSelectArea("ZZC")
					DbSkip()
				Enddo
			Endif
		Endif
	Endif
	oLstExp:Refresh()
Return
/******************************************************************************************************************/
/*** FMonArq - Valida a Saida da digitação do numero da O.P. na consulta de produtos.                           ***/
/******************************************************************************************************************/
Static Function fMonArq()
	Local cDrvArq := ""
	//Local cTrbArq := ""
	//Local cPatArq := "\DADOSADV\"
	Local aStrArq := {}
	//Local cQry1   := ""

	#IFDEF WNTX
		cDrvArq := "DBFNTX"
	#ENDIF
	#IFDEF WCDX
		cDrvArq := "DBFCDX"
	#ENDIF
	#IFDEF WASX
		cDrvArq := "DBFCDXAX"
	#ENDIF
	#IFDEF WCODEBASE
		cDrvArq := "DBFCDXTTS"
	#ENDIF

	If ChkFile("PED")
		DbSelectArea("PED")
		DbCloseArea()
	Endif
	aStrArq := {}
	aadd(aStrArq, {"PED_FLAG"  , "C", 02, 0}) //Flag de marcação
	aadd(aStrArq, {"PED_NUMBOR", "C", 06, 0}) //Numero do Bordero de Pedidos
	aadd(aStrArq, {"PED_EMISSA", "D", 08, 0}) //Emissão do Bordero de Pedidos
	aadd(aStrArq, {"PED_PEDIDO", "C", 06, 0}) //Pedido
	aadd(aStrArq, {"PED_QUANTI", "N", 06, 0}) //Quantidade do Produto
	aadd(aStrArq, {"PED_LOCEXP", "C", 09, 0}) //Localização na expedição
	aadd(aStrArq, {"PED_GAVETA", "C", 03, 0}) //Gaveta na expedição
	aadd(aStrArq, {"PED_LOCAL",  "C", 03, 0}) //LOCAL PEDIDO / joSE 21/08/2024


	/********************************************************************************************************************************/
	oTempTbl7 := FWTemporaryTable():New( 'PED' )
	oTempTbl7:SetFields( aStrArq )
	oTempTbl7:Create()
	/********************************************************************************************************************************/
Return

/******************************************************************************************************************/
/*** fMarDes - Atualiza browse com marca e desmarca - produtos em bordero de despacho.                          ***/
/******************************************************************************************************************/
Static Function fMarDES(nQtdSep3, oQtdSep3, nQtdG3, oQtdG3, nQtdApt, oQtdApt, aCodLot, cCodLot, nQtdOrd, cFecha, oFecha)
	Local nOpcB := 0
	Local nQtdPed := oDespac:aArray[oDespac:nAt][8]

	If !oDespac:aArray[oDespac:nAt][2] .and. nQtdPed <> 0
		DEFINE MSDIALOG oDlgM TITLE OemToAnsi("Ajuste de Quantidade") From 9,0 to 11,38 of oMainWnd
		DEFINE FONT oFont SIZE 9,0 BOLD
		@ 005, 005   SAY OemToAnsi("Quantidade: ")               SIZE 65,09 PIXEL OF oDlgM FONT oFont
		@ 004, 070 MSGET oQtdPed VAR nQtdPed PICTURE "@E 999999" SIZE 35,09 PIXEL OF oDlgM FONT oFont
		DEFINE SBUTTON oBtnM FROM 003,120 TYPE 1 ACTION (nOpcB := 1, oDlgM:End()) ENABLE OF oDlgM PIXEL
		oDlgM:nStyle    := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
		oBtnM:cCaption := "Atualiza"
		ACTIVATE MSDIALOG oDlgM CENTERED
		If nOpcB == 1
			oDespac:aArray[oDespac:nAt][2] := !oDespac:aArray[oDespac:nAt][2]
			oDespac:aArray[oDespac:nAt][8] := nQtdPed
			nQtdSep3 += nQtdPed
		Endif
	Else
		If nQtdPed <> 0
			oDespac:aArray[oDespac:nAt][2] := !oDespac:aArray[oDespac:nAt][2]
			nQtdSep3 -= oDespac:aArray[oDespac:nAt][8]
		Else
		Endif
	Endif
	If nQtdOrd <= 0
		nQtdSep3 := 0
		cFecha  := '       '
	Endif
	nQtdApt := nQtdSep3 + nQtdG3
	If nQtdApt > 0
		If nQtdApt < nQtdOrd
			cFecha  := 'PARCIAL'
		Else
			cFecha  := 'TOTAL'
		Endif
	Else
		cFecha  := '       '
	Endif
	oFecha:Refresh()
	oDespac:Refresh()
	oQtdSep3:Refresh()
	oQtdG3:Refresh()
	oQtdApt:Refresh()
Return(.t.)

/******************************************************************************************************************/
/*** fMarPed - Atualiza browse com marca e desmarca - produtos em bordero de pedidos.                           ***/
/******************************************************************************************************************/
Static Function fMarPED(nQtdSep3, oQtdSep3, nQtdG3, oQtdG3, nQtdApt, oQtdApt, aCodLot, cCodLot, nQtdOrd)
	Local nOpcB   := 0
	Local nQtdPed := PED->PED_QUANTI

	If Marked("PED_FLAG")
		DEFINE MSDIALOG oDlgM TITLE OemToAnsi("Ajuste de Quantidade") From 9,0 to 11,38 of oMainWnd
		DEFINE FONT oFont SIZE 9,0 BOLD
		@ 005, 005   SAY OemToAnsi("Quantidade: ")               SIZE 65,09 PIXEL OF oDlgM
		@ 004, 070 MSGET oQtdPed VAR nQtdPed PICTURE "@E 999999" SIZE 35,09 PIXEL OF oDlgM
		DEFINE SBUTTON oBtnM FROM 003,120 TYPE 1 ACTION (nOpcB := 1, oDlgM:End()) ENABLE OF oDlgM PIXEL
		oBtnM:cCaption := "Atualiza"
		oDlgM:nStyle    := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
		ACTIVATE MSDIALOG oDlgM CENTERED
		If nOpcB == 1
			RecLock("PED", .f.)
			PED->PED_QUANTI := nQtdPed
			MsUnLock()
			nQtdSep3 += nQtdPed
		Endif
	Else
		nQtdSep3 -= PED->PED_QUANTI
	Endif
	If nQtdOrd <= 0
		nQtdSep3 := 0
	Endif
	nQtdApt := nQtdSep3 + nQtdG3
	If nQtdApt > 0
		If nQtdApt < nQtdOrd
			cFecha  := 'PARCIAL'
		Else
			cFecha  := 'TOTAL'
		Endif
	Else
		cFecha  := '       '
	Endif
	oFecha:Refresh()
	oPED:oBrowse:Refresh()
	oQtdSep3:Refresh()
	oQtdG3:Refresh()
	oQtdApt:Refresh()
	DbSelectArea("PED")
Return(.t.)

/******************************************************************************************************************/
/*** fAtuRet - Atualiza baixa de produtos retirados e/ou produção.                                              ***/
/***           fCalVol - Calcula volume dos produtos no pedido                                                  ***/
/******************************************************************************************************************/
Static Function fAtuRet(cCodPro, cOpc, aDespac, oDespac, aCodLot, nQtdOrd, oQtdPro, nQtdSep3, oQtdSep3, nQtdG3, oQtdG3, nQtdApt, oQtdApt, cFecha, oFecha)
	Local nY, nX
	Local cAPTOPCO := GETMV("MV_APTOPCO")
	Local cQry1    := ""
	/**************************************************************/
	/*** Baixa Ordens de Produção por item na consulta.         ***/
	/**************************************************************/
	//Gravar quantidade a baixar no arquivo producao e empenho
	If GETMV("MV_APTOPCO") $ 'S'
		lAptLot := .f.
		For nY := 1 To Len(aCodLot)
			If aCodLot[nY][1]
				lAptLot := .t.
			Endif
		Next
		If !lAptLot
			If Len(aCodLot) == 1
				If !aCodLot[1][2] $ 'TRANSF'
					MsgBox('Atenção, nenhum lote de produção foi marcado!', 'Atenção', 'STOP')
					Return
				Endif
			Else
				MsgBox('Atenção, nenhum lote de produção foi marcado!', 'Atenção', 'STOP')
				Return
			Endif
		Endif
	Endif
	For nY := 1 To Len(aCodLot)
		If aCodLot[nY][1]
			If nQtdApt == 0.0
				MsgBox('Atenção, quantidade total apontada igual a zero, inválida!!!', 'Atenção...', 'STOP')
				Return
			Endif
			//If (GETMV("MV_APTOPCO") $ 'S') .AND. (cNumEmp = "01010101") // DESABILITADO RELEASE 12.1.25
			If Alltrim(cAPTOPCO) == 'S' .AND. (cNumEmp = "01010101")
				cQry1 := ""
				cQry1 += "SELECT TOP 1 * "
				cQry1 += "FROM PRODUCAO PRO WITH (NOLOCK) "
				cQry1 += "WHERE ('"+xFilial("SC2")+"' = '010101') AND (PRO.ORDEM = '"+aCodLot[nY][4]+"') "
				cQry1 += "  AND PRO.LOTE = '"+aCodLot[nY][2]+"' "
				cQry1 += "ORDER BY PRO.SEQPRO DESC "
				TCQuery cQry1 ALIAS "BXA" NEW
				If Empty(BXA->FIM)
					cQry1 := ""
					cQry1 += "UPDATE PRODUCAO SET FIM = '"+dTOS(dDataBase)+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+"', SEQPRO = '01', TP = '"+SubStr(cFecha, 1, 1)+"' WHERE ORDEM = '"+aCodLot[nY][4]+"' AND LOTE = '"+aCodLot[nY][2]+"' "
					nRetQry := TCSQLExec(cQry1)
				Else
					cQry1 := ""
					cQry1 += "INSERT PRODUCAO (ORDEM, LOTE, INICIO, FIM, FLAG, QTDE, SEQPRO, TP) VALUES ('"+aCodLot[nY][4]+"', '"+aCodLot[nY][2]+"', '"+BXA->INICIO+"', '"+dTOS(dDataBase)+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+"', '', "+TransForm(0, "@E 9999")+", '"+StrZero(Val(BXA->SEQPRO)+1, 2)+"', '"+SubStr(cFecha, 1, 1)+"')"
					nRetQry := TCSQLExec(cQry1)
				Endif
				If nRetQry >= 0
					cQry1 := ""
					cQry1 += "INSERT EMPENHO (ORDEM, LOTE, CODIGO, SEQ, QUANT, FLAG, SEQPRO) VALUES('"+aCodLot[nY][4]+"', '"+aCodLot[nY][2]+"', '"+Alltrim(StrTran(StrTran(cCodPro, '.'), '-'))+"', '', "+TransForm(nQtdApt, "@E 9999")+", '', '"+StrZero(Val(BXA->SEQPRO)+1, 2)+"') "
					TCSQLExec(cQry1)
				Endif
				DbSelectArea("BXA")
				DbCloseArea()
			Endif
			aCodLot[nY][1] := .f.
		Endif
	Next
	nQtdOrd := 0
	nQtdSep3 := 0
	nQtdG3 := 0
	nQtdApt := 0
	oQtdPro:Refresh()
	oQtdSep3:Refresh()
	oQtdG3:Refresh()
	oQtdApt:Refresh()
	If GetMv("MV_ATURETE") $ 'N' //Método antigo de baixa do pedido. Será apagado depois de estar funcionando o novo.
		/**************************************************************/
		/*** Bordero de despacho - Somente com gavetas cadastradas. ***/
		/**************************************************************/
		For nY := 1 To Len(aDespac)
			If aDespac[nY][2]
				DbSelectArea("ZZC")
				DbSetOrder(1)
				DbSeek(xFilial("ZZC")+aDespac[nY][4]+aDespac[nY][7]+Alltrim(StrTran(StrTran(cCodPro, '.'), '-')), .t.)
				If Found()
					lNaoAtu := .f.
					RecLock("ZZC", .f.)
					ZZC->ZZC_RETIRA += aDespac[nY][8]
					ZZC->ZZC_SEPARA := Iif(ZZC->ZZC_RETIRA >= ZZC->ZZC_QUANTI, 'S', 'N')
					ZZC->ZZC_VOLRET += fCalVol(ZZC->ZZC_PRODUT, ZZC->ZZC_RETIRA)
					ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
					DbSelectArea("ZZC")
					MsUnLock()
					If ZZC->ZZC_RETIRA >= ZZC->ZZC_QUANTI
						oDespac:aArray[nY][11] := 'S'
						lNaoAtu := .t.
					Else
						oDespac:aArray[nY][8] := (ZZC->ZZC_QUANTI - ZZC->ZZC_RETIRA)
						oDespac:aArray[nY][2] := .f.
					Endif
					If cOpc $ 'R' //Somente para retirada do estoque
						If !lNaoAtu
							nPos := aScan(aCols, {|x| Alltrim(x[1]) == Alltrim(StrTran(StrTran(cCodPro, '.'), '-'))})
							If nPos > 0
								aCols[nPos][5] := (aCols[nPos][5] - aDespac[nY][8])
								If aCols[nPos][5] == 0
									aCols[nPos][5] := 999999
									aCols[nPos][6] := space(03)
								Endif
							Endif
						Endif
					Endif
				Endif
			Endif
		Next
		aVetExc := {}
		For nY := 1 To Len(aDespac)
			If aDespac[nY][11] $ 'S'
				aAdd(aVetExc, nY)
			Endif
		Next
		For nY := 1 To Len(aVetExc)
			For nX := 1 To Len(aDespac)
				If nX <= Len(aDespac)
					If aDespac[nX][11] $ 'S'
						aSize(aDel(aDespac, nX), Len(aDespac)-1)
					Endif
				Endif
			Next
		Next
		oDespac:Refresh()
	Else //Método novo, de baixa do pedido. Apagar linhas de código do antigo depois de estar funcionando.
		/**************************************************************/
		/*** Bordero de DESPACHO - Somente com gavetas cadastradas. ***/
		/**************************************************************/
		aNewDes := {}
		For nY := 1 To Len(aDespac)
			If aDespac[nY][2]
				DbSelectArea("ZZC")
				DbSetOrder(1)
				DbSeek(xFilial("ZZC")+aDespac[nY][4]+aDespac[nY][7]+Alltrim(StrTran(StrTran(cCodPro, '.'), '-')), .t.)
				If Found()
					lNaoAtu := .f.
					RecLock("ZZC", .f.)
					ZZC->ZZC_RETIRA += aDespac[nY][8]
					ZZC->ZZC_SEPARA := Iif(ZZC->ZZC_RETIRA >= ZZC->ZZC_QUANTI, 'S', 'N')
					ZZC->ZZC_VOLRET += fCalVol(ZZC->ZZC_PRODUT, ZZC->ZZC_RETIRA)
					ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
					DbSelectArea("ZZC")
					MsUnLock()
					If ZZC->ZZC_RETIRA >= ZZC->ZZC_QUANTI
						oDespac:aArray[nY][11] := 'S'
						lNaoAtu := .t.
					Else
						oDespac:aArray[nY][8] := (ZZC->ZZC_QUANTI - ZZC->ZZC_RETIRA)
						oDespac:aArray[nY][2] := .f.
						aAdd(aNewDes, {oDespac:aArray[nY][01], oDespac:aArray[nY][02], oDespac:aArray[nY][03], oDespac:aArray[nY][04], oDespac:aArray[nY][05], oDespac:aArray[nY][06], oDespac:aArray[nY][07], oDespac:aArray[nY][08], oDespac:aArray[nY][09], oDespac:aArray[nY][10], oDespac:aArray[nY][11], oDespac:aArray[nY][12] })
					Endif
					If cOpc $ 'R' //Somente quando chamar a rotina dentro da retirada de estoque.
						If !lNaoAtu
							nPos := aScan(aCols, {|x| Alltrim(x[1]) == Alltrim(StrTran(StrTran(cCodPro, '.'), '-'))})
							If nPos > 0
								BEGINSQL Alias "FAL"
								SELECT 
								SUM(ZZC.ZZC_QUANTI - ZZC.ZZC_RETIRA) AS FALTA 
								FROM 
								%TABLE:ZZC% ZZC 
								WHERE 
								ZZC.ZZC_FILIAL = %XFILIAL:SZF%
								AND ZZC.%NOTDEL%
								AND ZZC.ZZC_BORDER = %EXP:SZF->ZF_CODIGO%
								AND ZZC.ZZC_PRODUT = %EXP:Alltrim(StrTran(StrTran(cCodPro, '.'), '-'))%
								AND ZZC.ZZC_SEPARA <> 'S' 
								ENDSQL
								If FAL->FALTA == 0
									aCols[nPos][5] := 999999
									aCols[nPos][6] := space(03)
								Else
									aCols[nPos][5] := FAL->FALTA
								Endif
								FAL->(DbCloseArea())

							Endif
						Endif
					Endif
				Endif
			Else
				aAdd(aNewDes, {oDespac:aArray[nY][01], oDespac:aArray[nY][02], oDespac:aArray[nY][03], oDespac:aArray[nY][04], oDespac:aArray[nY][05], oDespac:aArray[nY][06], oDespac:aArray[nY][07], oDespac:aArray[nY][08], oDespac:aArray[nY][09], oDespac:aArray[nY][10], oDespac:aArray[nY][11], oDespac:aArray[nY][12] })
			Endif
		Next
		aDespac := {}
		aDespac := aNewDes
		oDespac:SetArray(aDespac)
		oDespac:bLine := { || {Iif(aDespac[oDespac:nAt][1], oOk, oNo), Iif(aDespac[oDespac:nAt][2], hOk, hNo), aDespac[oDespac:nAt][3], aDespac[oDespac:nAt][4], aDespac[oDespac:nAt][5], aDespac[oDespac:nAt][6], aDespac[oDespac:nAt][7], aDespac[oDespac:nAt][8], oDespac:aArray[oDespac:nAt][10], oDespac:aArray[oDespac:nAt][9], oDespac:aArray[oDespac:nAt][12]}}
		/**************************************************************/
	Endif
	/**************************************************************/
	/*** Bordero de PEDIDOS - Somente com gavetas cadastradas.  ***/
	/**************************************************************/
	DbSelectArea("PED")
	DbGoTop()
	While !Eof()
		If Marked("PED_FLAG")
			DbSelectArea("ZZC")
			DbSetOrder(1)
			DbSeek(xFilial("ZZC")+PED->PED_NUMBOR+PED->PED_PEDIDO+StrTran(StrTran(cCodPro, '.'), '-'), .t.)
			If Found()
				lNaoAtu := .f.
				RecLock("ZZC", .f.)
				ZZC->ZZC_RETIRA += PED->PED_QUANTI
				ZZC->ZZC_SEPARA := Iif(ZZC->ZZC_RETIRA >= ZZC->ZZC_QUANTI, 'S', 'N')
				ZZC->ZZC_VOLRET += fCalVol(ZZC->ZZC_PRODUT, ZZC->ZZC_RETIRA)
				ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
				DbSelectArea("ZZC")
				MsUnLock()
				If ZZC->ZZC_RETIRA >= ZZC->ZZC_QUANTI
					RecLock("PED", .f.)
					PED->(Delete())
					MsUnLock()
					lNaoAtu := .t.
				Else
					RecLock("PED", .f.)
					PED->PED_QUANTI := (ZZC->ZZC_QUANTI - ZZC->ZZC_RETIRA)
					PED->PED_FLAG   := '  '
					MsUnLock()
				Endif
				If cOpc $ 'R' //Somente para retirada do estoque
					If !lNaoAtu
						nPos := aScan(aCols, {|x| Alltrim(x[1]) == Alltrim(StrTran(StrTran(cCodPro, '.'), '-'))})
						If nPos > 0
							aCols[nPos][5] := (aCols[nPos][5] - ZZC->ZZC_RETIRA)
							If aCols[nPos][5] == 0
								aCols[nPos][5] := 999999
								aCols[nPos][6] := space(03)
							Endif
						Endif
					Endif
				Endif
			Endif
		Endif
		PED->(DbSkip())
	Enddo
	DbSelectArea("PED")
	DbGoTop()
	If Eof() .and. Bof()
		PED->(ZAP)
	Endif
	oPed:oBrowse:Refresh()
	DbSelectArea("ZZC")
Return

/******************************************************************************************************************/
/*** fValPro - Valida a Saida da digitação do código do produto, na consulta de produtos.                       ***/
/***           fMonDad - Monta browses dos borderos com dados do produto.                                       ***/
/******************************************************************************************************************/
Static Function fValPro(oCodPro, cCodPro, oDesPro, cDesPro, oCodLoc, cCodLoc, cOpc, aDespac, nSalEst, oSalEst, aCodLot, nQtdOrd, oQtdPro, nQtdSep3, oQtdSep3, nQtdG3, oQtdG3, nQtdApt, oQtdApt)
	cCodPro := StrTran(StrTran(cCodPro, '-'), '.')
	aCodLot := {}
	nQtdOrd := 0
	nQtdSep3 := 0
	nQtdG3 := 0
	nQtdApt := 0
	If Empty(cCodPro)
		//ApMsgStop("Codigo Inválido !!!")
		cCodPro := space(15)
		cDesPro := space(30)
		cCodLoc := space(15)
		oQtdPro:Refresh() ; oQtdSep3:Refresh() ; oQtdG3:Refresh() ; oQtdApt:Refresh()
		oCodPro:SetFocus()
		DbSelectArea("PED")
		Return(.f.)
	Else
		SB1->(DbSetOrder(1))
		If DbSeek(xFilial("SB1")+cCodPro, .t.)
			If SB1->B1_TIPO $ 'PA' .or. (Len(Alltrim(SB1->B1_COD)) <= 5 .and. SB1->B1_TIPO $ 'MP.MC.PI')
				cCodPro := Iif(Len(Alltrim(SB1->B1_COD)) <= 5, SB1->B1_COD, TransForm(cCodPro, "@R! XX 99.99.999-XX"))
				cDesPro := SB1->B1_DESC
				DbSelectArea("SB2")
				DbSetOrder(1)
				DbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD, .t.)
				If Found()
					cCodLoc := Alltrim(SB2->B2_LOCALIZ)
					nSalEst := SB2->B2_QATU
				Endif
				MsAguarde( {|| fMonDad(cCodPro, cOpc, @aDespac)}, "Aguarde...", "Buscando registros...")
				oSalEst:Refresh()
				cQry1 := ""
				cQry1 += "SELECT SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN AS ORDEM, SC2.C2_LOTE AS LOTE, (SC2.C2_QUANT - SC2.C2_QUJE) AS PENDENTE "
				cQry1 += "FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "
				cQry1 += "WHERE SC2.C2_FILIAL  = '"+xFilial("SC2")+"' "
				cQry1 += "  AND SC2.D_E_L_E_T_ = '' "
				cQry1 += "  AND SC2.C2_PRODUTO = '"+StrTran(StrTran(cCodPro, '-'), '.')+"' "
				cQry1 += "  AND SC2.C2_DATRF   = '' "
				TCQuery cQry1 ALIAS "BSC" NEW
				DbSelectArea("BSC")
				While !Eof()
					cQry1 := ""
					cQry1 += "SELECT SUM(EMP.QUANT) AS QUANT "
					cQry1 += "FROM EMPENHO EMP "
					cQry1 += "WHERE ('"+xFilial("SC2")+"' = '010101') AND (EMP.ORDEM = '"+BSC->ORDEM+"') "
					cQry1 += "  AND EMP.LOTE  = '"+BSC->LOTE+"' "
					cQry1 += "  AND EMP.FLAG = '' "
					TCQuery cQry1 ALIAS "APT" NEW
					DbSelectArea("APT")
					If (BSC->PENDENTE - APT->QUANT) > 0.0
						aAdd(aCodLot, {.f., BSC->LOTE, (BSC->PENDENTE - APT->QUANT), BSC->ORDEM})
					Endif
					DbSelectArea("APT")
					DbCloseArea()
					DbSelectArea("BSC")
					DbSkip()
				Enddo
				DbSelectArea("BSC")
				DbCloseArea()
				oQtdPro:Refresh() ; oQtdSep3:Refresh() ; oQtdG3:Refresh() ; oQtdApt:Refresh()
				DbSelectArea("PED")
				Return(.t.)
			Else
				ApMsgStop("Codigo Inválido !!!")
				cCodPro := space(15)
				cDesPro := space(30)
				cCodLoc := space(15)
				oQtdPro:Refresh() ; oQtdSep3:Refresh() ; oQtdG3:Refresh() ; oQtdApt:Refresh()
				oCodPro:SetFocus()
				DbSelectArea("PED")
				Return(.f.)
			Endif
		Else
			ApMsgStop("Codigo Inválido !!!")
			cCodPro := space(15)
			cDesPro := space(30)
			cCodLoc := space(15)
			oQtdPro:Refresh() ; oQtdSep3:Refresh() ; oQtdG3:Refresh() ; oQtdApt:Refresh()
			oCodPro:SetFocus()
			DbSelectArea("PED")
			Return(.f.)
		Endif
	Endif
Return(.f.)

/******************************************************************************************************************/
/*** fMonDad - Monta matrizes com os dados que irão aparecer na consulta de produtos                            ***/
/******************************************************************************************************************/
Static Function fMonDad(cCodPro, cOpc, aDespac)
	Local cQry1 := ""
	Local cAux1 := ""
	Local cREFTAL := GetMv("MV_RETFAL")

	aDespac := {}

	cQry1 := ""
	cQry1 += "SELECT ISNULL(SZB.ZB_CODIGO, '') AS DESPACHO, ISNULL(SZA.ZA_DESCR, '') AS REGIAO, ISNULL(ZA_PREVDSP, '') AS PREVISAO, ZZC.ZZC_PEDIDO AS PEDIDO, ZZC.ZZC_QUANTI AS QUANTIDADE, SZA.ZA_FLAG AS FLAG "
	cQry1 += "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
	cQry1 += "LEFT OUTER JOIN "+RetSqlName("SZB")+" SZB WITH (NOLOCK) ON ZZC.ZZC_FILIAL  = SZB.ZB_FILIAL AND ZZC.ZZC_PEDIDO = SUBSTRING(SZB.ZB_PEDIDO, 3, 6) AND SZB.D_E_L_E_T_ = '' "
	cQry1 += "LEFT OUTER JOIN "+RetSqlName("SZA")+" SZA WITH (NOLOCK) ON SZB.ZB_FILIAL  = SZA.ZA_FILIAL AND SZB.ZB_CODIGO = SZA.ZA_CODIGO AND SZA.D_E_L_E_T_ = '' "
	cQry1 += "WHERE ZZC.ZZC_FILIAL  = '"+xFilial("ZZC")+"' "
	cQry1 += "  AND ZZC.D_E_L_E_T_ = '' "
	cQry1 += "  AND ZZC.ZZC_DESPAC NOT IN('S') "
	cQry1 += "  AND ZZC.ZZC_PRODUT = '"+StrTran(StrTran(cCodPro, '-'), '.')+"' "
	cQry1 += "  AND ISNULL(SZB.ZB_CODIGO, '') NOT IN('') "
	cQry1 += "ORDER BY 3, 1, 4 "
	TCQuery cQry1 ALIAS "TCQ" NEW
	DbSelectArea("TCQ")
	DbGoTop()

	BEGINSQL Alias "TCQ"
	SELECT 
		ISNULL(SZB.ZB_CODIGO, '') AS DESPACHO, 
		ISNULL(SZA.ZA_DESCR, '') AS REGIAO, 
		ISNULL(ZA_PREVDSP, '') AS PREVISAO, 
		ZZC.ZZC_PEDIDO AS PEDIDO, 
		ZZC.ZZC_QUANTI AS QUANTIDADE, 
		SZA.ZA_FLAG AS FLAG 
		FROM 
		%TABLE:ZZC% ZZC WITH (NOLOCK) 
		LEFT OUTER JOIN %TABLE:SZB% SZB WITH (NOLOCK) 
			ON ZZC.ZZC_FILIAL  = SZB.ZB_FILIAL 
			AND ZZC.ZZC_PEDIDO = SUBSTRING(SZB.ZB_PEDIDO, 3, 6) 
			AND %NOTDEL%
		LEFT OUTER JOIN %TABLE:SZA% SZA WITH (NOLOCK) 
			ON SZB.ZB_FILIAL  = SZA.ZA_FILIAL 
			AND SZB.ZB_CODIGO = SZA.ZA_CODIGO 
			AND SZA.%NOTDEL%
			WHERE 
			ZZC.ZZC_FILIAL  = %XFILIAL:ZZC%
			AND ZZC.%NOTDEL%
			AND ZZC.ZZC_DESPAC <> 'S'
			AND ZZC.ZZC_PRODUT = %EXP:StrTran(StrTran(cCodPro, '-'), '.')%
			AND ISNULL(SZB.ZB_CODIGO, '') <> '' 
			ORDER BY 3, 1, 4 
	ENDSQL
	
While .NOT. TCQ->(Eof())
		cBorPed := Posicione("SZG", 2, xFilial("SZG")+'01'+TCQ->PEDIDO, "ZG_CODIGO")
		If .NOT. Empty(cBorPed)
			ZZC->(DbSetOrder(1))
			cCodProd:=StrTran(cCodPro, '-')
			cCodProd:=StrTran(cCodPro, '.')
			If ZZC->(DbSeek(xFilial("ZZC")+cBorPed+TCQ->PEDIDO+cCodProd))
			
				RecLock("ZZC", .t.)
				ZZC->ZZC_FILIAL := xFilial("ZZC")
				ZZC->ZZC_BORDER := Posicione("SZG", 2, xFilial("SZG")+'01'+TCQ->PEDIDO, "ZG_CODIGO")
				ZZC->ZZC_PEDIDO := TCQ->PEDIDO
				ZZC->ZZC_PRODUT := cCodProd
				ZZC->ZZC_QUANTI := TCQ->QUANTIDADE
				ZZC->ZZC_RETIRA := 0
				ZZC->ZZC_VOLUME := fCalVol(cCodProd, TCQ->QUANTIDADE)
				ZZC->ZZC_VOLRET := 0
				ZZC->ZZC_CARGA  := TCQ->DESPACHO
				ZZC->ZZC_OCUPAC := 0
				ZZC->ZZC_DESPAC := ""
				ZZC->ZZC_GAVETA := ""
				ZZC->ZZC_SEPARA := ""
				ZZC->ZZC_TPINCL := "B"
				MsUnLock()
			Else
				If ZZC->ZZC_SEPARA <> 'S'
					If !Empty(ZZC->ZZC_GAVETA)
						aAdd(aDespac, {Iif(TCQ->FLAG $ 'C', .f., .t.), .f., TCQ->DESPACHO, cBorPed, TCQ->REGIAO, CTOD(SubStr(TCQ->PREVISAO, 7, 2)+'/'+SubStr(TCQ->PREVISAO, 5, 2)+'/'+SubStr(TCQ->PREVISAO, 1, 4)), TCQ->PEDIDO, Iif(Alltrim(cREFTAL) == 'S', ZZC->ZZC_QUANTI, (ZZC->ZZC_QUANTI - ZZC->ZZC_RETIRA)), Posicione("SZG", 1, xFilial("SZG")+ZZC->ZZC_BORDER+'01'+TCQ->PEDIDO, "ZG_LOCALIZ"), ZZC->ZZC_GAVETA, 'N', ''})
						cAux1 += TCQ->PEDIDO+"', '"
					Endif
				Endif
			Endif
		Else
			ZZC->(DbSetOrder(4))
			If ZZC->(DbSeek(xFilial("ZZC")+TCQ->DESPACHO+TCQ->PEDIDO))
				While .NOT. EOF() .and. (ZZC->ZZC_FILIAL == xFilial("ZZC")) .and. ZZC->ZZC_CARGA == TCQ->DESPACHO .and. ZZC->ZZC_PEDIDO == TCQ->PEDIDO
					If Alltrim(ZZC->ZZC_PRODUT) == Alltrim(StrTran(StrTran(cCodPro, '.'), '-'))
						If ZZC->ZZC_SEPARA <> 'S'
							If .NOT. Empty(ZZC->ZZC_GAVETA)
								aAdd(aDespac, {Iif(TCQ->FLAG $ 'C', .f., .t.), .f., TCQ->DESPACHO, cBorPed, TCQ->REGIAO, STOD(TCQ->PREVISAO), TCQ->PEDIDO, Iif(Alltrim(cREFTAL) == 'S', ZZC->ZZC_QUANTI, (ZZC->ZZC_QUANTI - ZZC->ZZC_RETIRA)), Posicione("SZG", 1, xFilial("SZG")+ZZC->ZZC_BORDER+'01'+TCQ->PEDIDO, "ZG_LOCALIZ"), ZZC->ZZC_GAVETA, 'N', ''})
								cAux1 += TCQ->PEDIDO+"', '"
							Endif
						Endif
					Endif
					ZZC->(DbSkip())
				Enddo
			Endif
		Endif
		TCQ->(DbSkip())
	Enddo
	TCQ->(DbCloseArea())
	If Len(aDespac) <= 0
		aAdd(aDespac, {.t., .f., space(06), space(06), space(20), Ctod('  /  / '), space(06), 0, space(03), space(03), space(01), ''})
	Endif
	oDespac:nAt := 1
	oDespac:SetArray(aDespac)
	oDespac:bLine:= { || {Iif(aDespac[oDespac:nAt][1], oOk, oNo), Iif(aDespac[oDespac:nAt][2], hOk, hNo), aDespac[oDespac:nAt][3], aDespac[oDespac:nAt][4], aDespac[oDespac:nAt][5], aDespac[oDespac:nAt][6], aDespac[oDespac:nAt][7], aDespac[oDespac:nAt][8], oDespac:aArray[oDespac:nAt][10], oDespac:aArray[oDespac:nAt][9], oDespac:aArray[oDespac:nAt][12]}}
	oDespac:Refresh()

	/***          MONTANDO BORDERO DE PEDIDOS          ***/
	If ChkFile("PED")
		DbSelectArea("PED")
		PED->(ZAP)	
	Endif
	cQry1 := ""
	cQry1 += "SELECT ISNULL(SZG.ZG_CODIGO, '') AS BORDERO, ISNULL(SZF.ZF_EMISSAO, '') AS EMISSAO, ZZC.ZZC_PEDIDO AS PEDIDO, ZZC.ZZC_QUANTI AS QUANTIDADE "
	cQry1 += "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
	cQry1 += "LEFT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH (NOLOCK) ON ZZC.ZZC_FILIAL = SZG.ZG_FILIAL AND ZZC.ZZC_PEDIDO = SUBSTRING(SZG.ZG_PEDIDO, 3, 6) AND SZG.D_E_L_E_T_ = '' "
	cQry1 += "LEFT OUTER JOIN "+RetSqlName("SZF")+" SZF WITH (NOLOCK) ON SZG.ZG_FILIAL  = SZF.ZF_FILIAL AND SZG.ZG_CODIGO = SZF.ZF_CODIGO AND SZF.D_E_L_E_T_ = '' "
	cQry1 += "WHERE ZZC.ZZC_FILIAL = '"+xFilial("ZZC")+"' "
	cQry1 += "  AND ZZC.D_E_L_E_T_ = '' "
	cQry1 += "  AND ZZC.ZZC_DESPAC IN('', 'N') "
	cQry1 += "  AND ZZC.ZZC_PRODUT = '"+StrTran(StrTran(cCodPro, '-'), '.')+"' "
	cQry1 += "  AND ISNULL(SZG.ZG_CODIGO, '') NOT IN('') "
	cQry1 += Iif(!Empty(cAux1), "  AND ZZC.ZZC_PEDIDO NOT IN('"+SubStr(cAux1, 1, Len(cAux1) - 3)+") ", "")
	cQry1 += "ORDER BY 3, 1, 4 "
	TCQuery cQry1 ALIAS "TCQ" NEW
	DbSelectArea("TCQ")
	DbGoTop()
	While !Eof()
		DbSelectArea("ZZC")
		DbSetOrder(1)
		DbSeek(xFilial("ZZC")+TCQ->BORDERO+TCQ->PEDIDO+StrTran(StrTran(cCodPro, '.'), '-'), .t.)
		If Found()
			If ZZC->ZZC_SEPARA <> 'S'
				If !Empty(ZZC->ZZC_GAVETA)
					RecLock("PED", .t.)
					PED->PED_FLAG   := '  '
					PED->PED_NUMBOR := TCQ->BORDERO
					PED->PED_EMISSA := CTOD(SubStr(TCQ->EMISSAO, 7, 2)+'/'+SubStr(TCQ->EMISSAO, 5, 2)+'/'+SubStr(TCQ->EMISSAO, 1, 4))
					PED->PED_PEDIDO := TCQ->PEDIDO
					//PED->PED_QUANTI := Iif(GetMv("MV_RETFAL") $ 'S', ZZC->ZZC_QUANTI, (ZZC->ZZC_QUANTI - ZZC->ZZC_RETIRA)) DESABILITADO RELEASE 12.1.25
					PED->PED_QUANTI := Iif(Alltrim(cREFTAL) == 'S', ZZC->ZZC_QUANTI, (ZZC->ZZC_QUANTI - ZZC->ZZC_RETIRA))
					PED->PED_LOCEXP := Posicione("SZG", 1, xFilial("SZG")+TCQ->BORDERO+'01'+TCQ->PEDIDO, "ZG_LOCALIZ")
					PED->PED_GAVETA := ZZC->ZZC_GAVETA
					MsUnLock()
				Endif
			Endif
		Endif
		DbSelectArea("TCQ")
		DbSkip()
	Enddo
	DbSelectArea("TCQ")
	DbCloseArea()
	DbSelectArea("PED")
	DbGoTop()
	oPED:oBrowse:Refresh()
	DbSelectArea("PED")
	DbGoTop()
Return

/******************************************************************************************************************/
/*** FATA03_4 - 25/01/06 - ENDEREÇAMENTO DE PEDIDOS NA EXPEDIÇÃO.                                               ***/
/***            fVlPer1    - Valida Pergunta para endereçamento                                                 ***/
/***          u_fBusEndLiv - Busca Endereços livres                                                             ***/
/***            fEndBor    - Endereça bordero de pedidos                                                        ***/
/***            fExcEnd    - Exclui endereços do bordero de pedidos                                             ***/
/******************************************************************************************************************/
User Function FATA03_4(cOpc)
	If cOpc $ '1' //Endereça
		/*
        If SZF->ZF_TIPOBOR $ '1.2' .or. Empty(Alltrim(SZF->ZF_TIPOBOR)) // POR EQTO SÓ PRA SP
			Messagebox("Bordero não pode ser endereçado!","Atenção...",48)
			Return
		Endif        	*/
		If SZF->ZF_FLAG $ 'D'
			//fVlPer1() desabilitado release 12.1.25
			If Pergunte("FATA03", .t.)
				aPallet := {}
				aQuadra := {}
				aProPal := {}
				aProQua := {}

				U_fBusEndLiv(@aPallet, @aQuadra, @aProPal, @aProQua) //Montas Matrizes para endereços livres

				Processa({|| fEndBor(mv_par01, @aPallet, @aQuadra, @aProPal, @aProQua)}, OemToAnsi("Endereçamento de pedidos na expedição"))
			Endif
		Else
			MsgBox("Bordero não pode ser endereçado!", "Atenção", "STOP")
			Return
		Endif
	ElseIf cOpc $ '2' //Exclui endereços
		/*
        If SZF->ZF_TIPOBOR $ '1.2' // POR EQTO SÓ PRA SP
			Messagebox("Bordero não pode ter seus endereços excluídos !","Atenção...",48)
			Return
		Endif        	*/


		If SZF->ZF_FLAG $ 'E'
			Processa({|| fExcEnd()}, OemToAnsi("Exclusão de endereçamento na expedição"))
		ElseIf SZF->ZF_FLAG $ 'T'
			MsgBox("Esse bordero já foi totalmente separado.", "Atenção", "STOP")
			Return Nil
		Else
			MsgBox("Esse bordero não foi endereçado ou já está sendo separado.", "Atenção", "STOP")
			Return Nil
		Endif
	Endif
Return

/******************************************************************************************************************/
/*** fVlPer1   - Pergunta sobre o método de endereçamento que será utilizado.                                   ***/
/******************************************************************************************************************/
/*
Static Function fVlPer1()
       PutSX1("FATA03", "01", "Endereçar ?", "", "", "mv_ch1", "N", 1, 0, 1, "C", " ", " ", " ", " ", "mv_par01", "Não Endereça", " ", " ", " ", "Endereça", " ", " ", "End. Especifico", " ", " ", "End. Manualmente", " ", " ", "", " ", " ", Nil, Nil, Nil, "FATA03" )
Return
*/
/******************************************************************************************************************/
/*** fEndBor - 25/01/06 - ROTINA DE ENDEREÇAMENTO DE PEDIDOS NA EXPEDIÇÃO.                                      ***/
/***            fVlPer2    - Valida pergunta para endereçamento especial de cargas fechadas                     ***/
/***            fValEnd    - Valida entrada manual de endereço para pedido                                      ***/
/***          u_fEndPedExp - Função utilizada para endereçamento automático de pedidos na expedição             ***/
/******************************************************************************************************************/
Static Function fEndBor(nEndereca, aPallet, aQuadra, aProPal, aProQua)
	Local aEndere := {}
	Local nTipEnd := '1'
	Local _nA, nA, nY

	If SZF->ZF_FLAG $ 'D'                         //Bordero Digitado e não endereçado
		If nEndereca == 3 //Endereçamento Especial para cargas fechadas.
			//fVlPer2()
			If Pergunte("XFATA3", .t.)
				cLocaliz := mv_par01
			Else
				cLocaliz := '   '
			Endif
		Endif
		/****************************************************************************************/
		/*** Verificar se o bordero já teve algum endereçamento anterior e exclui-lo.         ***/
		/****************************************************************************************/
		cQry1 := ""
		cQry1 += "UPDATE "+RetSqlName("ZZC")+" SET D_E_L_E_T_ = '' WHERE ZZC_FILIAL = '"+xFilial("ZZC")+"' AND D_E_L_E_T_ = '' AND ZZC_BORDER = '"+SZF->ZF_CODIGO+"' "
		TCSQLEXEC(cQry1)
		/****************************************************************************************/
		/*** Incluir pedidos do bordero em uma matriz para ordenar em ordem de transportadora ***/
		/*** para facilitar o carregamento.                                                   ***/
		/****************************************************************************************/
		aMatBor := {}
		DbSelectArea("SZG")
		DbSetOrder(1)
		DbGoTop()
		DbSeek(xFilial("SZG")+SZF->ZF_CODIGO, .t.) //Busca os pedidos do Bordero
		If Found()
			While !Eof() .and. SZG->ZG_FILIAL == SZF->ZF_FILIAL .and. SZG->ZG_CODIGO == SZF->ZF_CODIGO
				aadd(aMatBor, {SubStr(SZG->ZG_PEDIDO, 3, 6), Posicione("SC5", 1, xFilial("SC5")+SubStr(SZG->ZG_PEDIDO, 3, 6), "C5_TRANSP"), Posicione("SC5", 1, xFilial("SC5")+SubStr(SZG->ZG_PEDIDO, 3, 6), "C5_REDESP") })
				DbSelectArea("SZG")
				DbSkip()
			Enddo
		Endif
		aSort(aMatBor,,, {|x, y| x[2]+x[3] > y[2]+y[3]})
		If Len(aMatBor) > 0
			ProcRegua(Len(aMatBor))
			For _nA := 1 To Len(aMatBor)
				IncProc("Endereçando pedido: "+aMatBor[_nA][1])
				cPedido := aMatBor[_nA][1]
				cRegiao := Posicione("SZ7", 1, xFilial("SZ7")+Posicione("SA1", 1, xFilial("SA1")+Posicione("SC5", 1, xFilial("SC5")+cPedido, "C5_CLIENTE"), "A1_CODCID"), "Z7_REGIAO")
				lContin := .t.
				While lContin
					DbSelectArea("ZZC")
					DbSetOrder(1)
					DbSeek(xFilial("ZZC")+SZF->ZF_CODIGO+cPedido, .t.) //Busca endereçamentos por Bordero+Pedido
					If !Found()
						DbSelectArea("SC6")
						DbSetOrder(1)
						DbSeek(xFilial("SC6")+cPedido, .t.) //Busca os pedidos por item
						If Found()
							nPallet := 0
							nQtdVol := 0
							nQtdVaz := 0
							While !Eof() .and. (SC6->C6_FILIAL == xFilial("SC6")) .and. (SC6->C6_NUM == cPedido)
								If SC6->C6_PALLET == 0.0
									nCapProd := Iif(Len(Alltrim(SC6->C6_PRODUTO)) == 12, Iif( SubStr(Alltrim(SC6->C6_PRODUTO), 11, 2) == '11' .and. SubStr(Alltrim(SC6->C6_PRODUTO), 01, 2) $ 'CT.ED', Posicione("SZ5", 1, xFilial("SZ5")+SubStr(Alltrim(SC6->C6_PRODUTO), 11, 2), "Z5_CAPMIN"), Posicione("SZ5", 1, xFilial("SZ5")+SubStr(Alltrim(SC6->C6_PRODUTO), 11, 2), "Z5_CAPACID")), 1)
									If SC6->C6_QTDVEN == 0.0
										nQtdOcu := 0.0
									Else
										If nCapProd == 1
											nQtdOcu := 0.0
										Else
											nQtdOcu := SC6->C6_QTDVEN / nCapProd
										Endif
									Endif
								Else
									nQtdOcu := SC6->C6_PALLET
								Endif
								RecLock("ZZC", .t.)
								ZZC->ZZC_FILIAL := xFilial("ZZC")
								ZZC->ZZC_BORDER := SZF->ZF_CODIGO
								ZZC->ZZC_PEDIDO := SC6->C6_NUM
								ZZC->ZZC_PRODUT := SC6->C6_PRODUTO
								ZZC->ZZC_QUANTI := SC6->C6_QTDVEN
								ZZC->ZZC_RETIRA := 0
								ZZC->ZZC_VOLUME := SC6->C6_VOLITEM
								ZZC->ZZC_VOLRET := 0.0
								ZZC->ZZC_CARGA  := Posicione("SZB", 2, xFilial("SZB")+'01'+SC6->C6_NUM, "ZB_CODIGO")
								ZZC->ZZC_OCUPAC := nQtdOcu
								ZZC->ZZC_TPINCL := "B"
								MsUnLock()
								nQtdVaz += Iif(nQtdOcu == 0.0, 1, 0.0)
								nPallet += nQtdOcu
								nQtdVol += SC6->C6_VOLITEM
								DbSelectArea("SC6")
								DbSkip()
							Enddo
							If nPallet > 0.22
								If (nPallet - Int(nPallet)) > 0.0
									nPallet := Int(nPallet) + 1
								ElseIf (nPallet - Int(nPallet)) == 0.0
									nPallet += 1
								Endif
								nTipEnd := '1' //Pallet
							Else
								nTipEnd := '2' //Quadrante
							Endif
							If nEndereca == 2     //Endereçamento Automático
								aAdd(aEndere, {nTipEnd, nPallet, SZF->ZF_CODIGO, cPedido, cRegiao, 'E'})
							ElseIf nEndereca == 4 //Endereçamento manual pedido a pedido
								lSaida  := .f.
								nOpcB   := 0
								cEnder1 := Iif(nTipEnd == '1', space(03), space(05))
								cEnder2 := space(03)
								DEFINE MSDIALOG oDlgM TITLE OemToAnsi("Endereço - "+Iif(nTipEnd == '1', 'Pallet', 'Quadrante')) From 9,0 to 11,48 of oMainWnd
								DEFINE FONT oFont SIZE 9,0 BOLD
								@ 005, 005   SAY OemToAnsi("Pedido: "+cPedido)               SIZE 65,09 PIXEL OF oDlgM
								@ 004, 050 MSGET oEnder1 VAR cEnder1 PICTURE "@!" SIZE 15,09 PIXEL OF oDlgM
								@ 005, 085   SAY OemToAnsi("a")                              SIZE 05,09 PIXEL OF oDlgM
								@ 004, 090 MSGET oEnder2 VAR cEnder2 PICTURE "999" SIZE 15,09 PIXEL OF oDlgM
								oDlgM:nStyle    := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )

								@ 006,250 BTNBMP oBtnCon RESOURCE "OK" SIZE 110,24 ACTION(Iif(!Empty(cEnder1), nOpcB := 1, nOpcB := 0), If(nOpcB == 1, lSaida := .t., lSaida := .f.), If(nOpcB == 1, oDlgM:End(), MsgBox("Endereço não pode ser vazio!", "Atenção", "ALERT")))   PIXEL OF oDlgM
								oBtnCon:cCaption   := PADR(OemToAnsi("Atualizar"), 20)
								oBtnCon:cToolTip   := OemToAnsi("Atualiza endereço para o pedido...")
								//oBtnCon:lReadOnly  := .t.
								oEnder2:bWhen      := Iif(nTipEnd == '1', {|| .t.}, {|| .f.} )
								oEnder1:bValid     := {|| fValEnd(1, nTipEnd)}
								ACTIVATE MSDIALOG oDlgM CENTERED VALID lSaida
								If nOpcB == 1
									If cRegiao $ '999'
										cEndere := '('
										If Val(cEnder1) >= 500 .and. Val(cEnder1) < 900
											cEndere += cEnder1
											cEndere += ')'
										Else
											cEndere += cEnder1
											cEndere += '/'
											cEndere += Iif(Empty(cEnder2), cEnder1, cEnder2 )
											cEndere += ')'
										Endif
									Else
										cEndere := '*'
										If Val(cEnder1) >= 500 .and. Val(cEnder1) < 900
											cEndere += StrZero(Val(cEnder1), 3)
										Else
											cEndere += StrZero(Val(cEnder1), 3)
											cEndere += '/'
											cEndere += Iif(Empty(cEnder2), StrZero(Val(cEnder1), 3), StrZero(Val(cEnder2), 3) )
										Endif
									Endif
									DbSelectArea("SZG")
									DbSetOrder(2)
									DbSeek(xFilial("SZG")+'01'+cPedido, .t.)
									If Found()
										RecLock("SZG", .f.)
										SZG->ZG_LOCALIZ := cEndere
										MsUnLock()
									Endif
									If nTipEnd == '1' //Pallets
										For nA := Val(cEnder1) To Val(cEnder2)
											DbSelectArea("SBE")
											DbSetOrder(9)
											DbSeek(xFilial("SBE")+StrZero(nA, 3), .t.)
											If Found()
												RecLock("SBE", .f.)
												SBE->BE_STATUS  := '2'
												SBE->BE_BORDERO := SZF->ZF_CODIGO
												SBE->BE_PEDIDO  := cPedido
												MsUnLock()
											Endif
										Next
									Else              //Quadrantes
										DbSelectArea("SBE")
										DbSetOrder(9)
										DbSeek(xFilial("SBE")+cEnder1, .t.)
										If Found()
											RecLock("SBE", .f.)
											SBE->BE_STATUS  := '2'
											SBE->BE_BORDERO := SZF->ZF_CODIGO
											SBE->BE_PEDIDO  := cPedido
											MsUnLock()
										Endif
									Endif
								Endif
							Endif
						Endif
					Else
						//Verificar se não existe nenhum produto retirado
						lJaReti := .f.
						While !Eof() .and. ZZC->ZZC_FILIAL == SZG->ZG_FILIAL .and. ZZC->ZZC_BORDER == SZG->ZG_CODIGO .and. ZZC->ZZC_PEDIDO == SubStr(SZG->ZG_PEDIDO, 3, 6)
							If ZZC->ZZC_RETIRA > 0
								lJaReti := .t.
							Endif
							DbSelectArea("ZZC")
							DbSkip()
						Enddo
						If !lJaReti //Se não havia nenhum produto retirado, deleta todos os itens e re-endereça o mesmo
							DbSelectArea("ZZC")
							DbSetOrder(1)
							DbSeek(xFilial("ZZC")+SZF->ZF_CODIGO+cPedido, .t.) //Busca endereçamentos por Bordero+Pedido
							While !Eof() .and. ZZC->ZZC_FILIAL == SZG->ZG_FILIAL .and. ZZC->ZZC_BORDER == SZG->ZG_CODIGO .and. ZZC->ZZC_PEDIDO == SubStr(SZG->ZG_PEDIDO, 3, 6)
								RecLock("ZZC", .f.)
								DbDelete()
								MsUnLock()
								DbSelectArea("ZZC")
								DbSkip()
							Enddo
							DbSelectArea("SZG")
							Loop
						Endif
					Endif
					If nEndereca == 3 //Endereçamento Especial para cargas fechadas.
						DbSelectArea("SZG")
						DbSetOrder(2)
						DbSeek(xFilial("SZG")+'01'+cPedido, .t.)
						If Found()
							RecLock("SZG", .f.)
							SZG->ZG_LOCALIZ := cLocaliz
							MsUnLock()
						Endif
					Endif
					lContin := .f.
				Enddo
			Next
			If nEndereca == 2 //Endereçamento Automático
				aSort(aEndere,,, {|x, y| x[2] > y[2]})
				ProcRegua(Len(aEndere))
				For nY := 1 To Len(aEndere)
					IncProc("Endereçando pedido: "+aEndere[nY][4])
					cEndere := U_fEndPedExp(aEndere[nY][6], aEndere[nY][1], aEndere[nY][3], aEndere[nY][4], aEndere[nY][5], aEndere[nY][2], @aPallet, @aQuadra, @aProPal, @aProQua)
					DbSelectArea("SZG")
					DbSetOrder(2)
					DbSeek(xFilial("SZG")+'01'+aEndere[nY][4], .t.)
					If Found()
						RecLock("SZG", .f.)
						SZG->ZG_LOCALIZ := cEndere
						MsUnLock()
					Endif
				Next
			ElseIf nEndereca == 3 //Endereçamento Especial para cargas fechadas.
				If !Empty(cLocaliz)
					IncProc("Endereçando...")
					DbSelectArea("SBE")
					DbSetOrder(9)
					DbSeek(xFilial("SBE")+cLocaliz, .t.)
					If Found()
						RecLock("SBE", .f.)
						SBE->BE_STATUS  := '2'
						SBE->BE_BORDERO := SZF->ZF_CODIGO
						SBE->BE_PEDIDO  := 'ZZZZZZ'
						MsUnLock()
					Endif
				Endif
			Endif
			RecLock("SZF", .f.)
			SZF->ZF_FLAG = 'E'
			MsUnLock()
		Else                                       //Caso não encontre nenhum pedido no bordero
			MsgBox("Nenhum pedido foi encontrado, verifique.", "Atenção", "STOP")
		Endif
	ElseIf SZF->ZF_FLAG $ 'E' //Bordero já endereçado
		MsgBox("Esse bordero já foi endereçao.", "Atenção", "STOP")
		Return Nil
	ElseIf SZF->ZF_FLAG $ 'P' //Bordero sendo separado pela producao
		MsgBox("Bordero está separado parcialmente.", "Atenção", "STOP")
		Return Nil
	ElseIf SZF->ZF_FLAG $ 'Y' //
		MsgBox("Bordero está separado comprado na Rampa", "Atenção", "STOP")
		Return Nil
	ElseIf SZF->ZF_FLAG $ 'Z' //
		MsgBox("Bordero está totalmente separado e bipado", "Atenção", "STOP")
		Return Nil
	ElseIf SZF->ZF_FLAG $ 'X' //
		MsgBox("Bordero está sendo comprado na Rampa", "Atenção", "STOP")
		Return Nil
	ElseIf SZF->ZF_FLAG $ 'T' //Bordero totalmente separado
		MsgBox("Bordero totalmente separado.", "Atenção", "STOP")
		Return Nil
	Endif
Return

/******************************************************************************************************************/
/*** fVlPer2 - Pergunta sobre o endereço especifico.                                                            ***/
/******************************************************************************************************************/
/*
Static Function fVlPer2()
       PutSX1("XFATA3", "01", "Endereço Especifico", "", "", "mv_ch1", "C", 3, 0, 0, "G", "!Vazio(mv_par01)", "XBE", " ", " ", "mv_par01", "", " ", " ", " ", "", " ", " ", "", " ", " ", "", " ", " ", "", " ", " ", Nil, Nil, Nil, "XFATA3" )

       cAlias := Alias()
       nOrdem := IndexOrd()

       DbSelectArea("SX1")
       DbSetOrder(1)
       DbSeek('XFATA301')
       If Found()
          RecLock("SX1", .f.)
             SX1->X1_CNT01 := ''
          MsUnLock()
       Endif
       DbSelectArea(cAlias)
       DbSetOrder(nOrdem)
Return
*/
/******************************************************************************************************************/
/*** fValEnd  - 20/06/06 - VALIDA ENDEREÇAMENTO MANUAL DE PEDIDOS.                                              ***/
/******************************************************************************************************************/
Static Function fValEnd(nOpc, nTipEnd)
	Local lRet := .f.
	If Empty(cEnder1)
		MsgBox("Endereço não pode ser vazio!", "Atenção", "ALERT")
		oEnder1:SetFocus()
		Return(.f.)
	Endif
	If nOpc == 1 //Validação do Primeiro endereço digitado
		DbSelectArea("SBE")
		DbSetOrder(9)
		DbSeek(xFilial("SBE")+cEnder1, .t.)
		If Found()
			If nTipEnd == '1' //Pallet
				cEnder2       := StrZero(((Val(cEnder1) + nPallet) - 1), 3)
				oEnder2:bWhen := {|| .t.}
				oEnder2:Refresh()
				lRet := .t.
			Else              //Quadrante
				cEnder2 := space(03)
				oEnder2:bWhen := {|| .f.}
				oEnder2:Refresh()
				If Alltrim(cEnder1) $ '-'
					If Val(SubStr(Alltrim(cEnder1), 1, 3)) >= 500 .and. Val(SubStr(Alltrim(cEnder1), 1, 3)) < 900
						lRet := .t.
					Endif
				Else
					If Val(cEnder1) >= 500 .and. Val(cEnder1) < 900 //Se for quadrante
						lRet := .t.
					Else                                            //Caso seja digitado 1 pallet, também aceitar, porém ajustar endereço 2
						cEnder2 := space(03)
						oEnder2:bWhen := {|| .t.}
						oEnder2:Refresh()
						lRet := .t.
					Endif
				Endif
			Endif
		Else
			MsgBox('Endereço não encontrado!', 'Atenção', 'ALERT')
			cEnder2 := space(03)
			If nTipEnd == '1'
				oEnder2:bWhen := {|| .t.}
				cEnder1 := space(03)
			Else
				oEnder2:bWhen := {|| .f.}
				cEnder1 := space(05)
			Endif
			oEnder1:Refresh()
			oEnder2:Refresh()
			oEnder1:SetFocus()
			lRet    := .f.
		Endif
	Else //Validação do Segundo endereço digitado
		DbSelectArea("SBE")
		DbSetOrder(9)
		DbSeek(xFilial("SBE")+cEnder2, .t.)
		If Found()
			If Val(cEnder2) < Val(cEnder1)
				MsgBox('Atenção, segundo endereço inválido. Não pode ser menor que o primeiro!', 'Atenção', 'ALERT')
				cEnder2 := space(03)
				oEnder2:Refresh()
				lRet := .f.
			Endif
			If (Val(cEnder2) - Val(cEnder1)) == 0 //Significa que somente 1 endereço será alocado
				lRet    := .t.
			ElseIf (Val(cEnder2) - Val(cEnder1)) > 0 //Mais que 1 endereço
				nQtdDig := (Val(cEnder2) - Val(cEnder1))
				If nQtdDig == nPallet //Quantidade digitada igual a quantidade de pallets informada
					lRet := .t.
				ElseIf nQtdDig <> nPallet //Quantidade digitada menor que a quantidade de pallets informada
					If MsgYesNo('Atenção, Quantidade de pallets digitada: '+Transform(nQtdDig, '@E 999')+' diferente da quantidade solicitada: '+Transform(nPallet, '@E 999')+', continua ?', 'Atenção', 'ALERT')
						lRet := .t.
					Else
						cEnder2 := space(03)
						oEnder2:Refresh()
						lRet := .f.
					Endif
				Endif
			Endif
		Else
			cEnder2 := space(03)
			oEnder2:Refresh()
			lRet    := .f.
		Endif
	Endif
Return(lRet)

/******************************************************************************************************************/
/*** fExcEnd - 25/01/06 - ROTINA DE EXCLUSÃO DE ENDEREÇAMENTO DE PEDIDOS NA EXPEDIÇÃO                           ***/
/******************************************************************************************************************/
Static Function fExcEnd()
	ProcRegua(50)
	DbSelectArea("SZG") //Limpar SZG campo ZG_LOCALIZ
	DbSetOrder(1)
	DbSeek(xFilial("SZG")+SZF->ZF_CODIGO, .t.)
	If Found()
		While !Eof() .and. (SZG->ZG_FILIAL == SZF->ZF_FILIAL)  .and. (SZG->ZG_CODIGO == SZF->ZF_CODIGO)
			IncProc('Excluindo endereço do Pedido: '+SubStr(SZG->ZG_PEDIDO, 3, 6))
			RecLock("SZG", .f.)
			SZG->ZG_LOCALIZ := ""
			MsUnLock()
			DbSelectArea("SZG")
			DbSkip()
		Enddo
		//Liberar endereços
		/* cQry1 := ""
          cQry1 += "UPDATE "+RetSqlName("SBE")+" SET BE_BORDERO = '', BE_PEDIDO = '', BE_STATUS = '1' WHERE BE_FILIAL = '"+xFilial("SBE")+"' AND BE_BORDERO = '"+SZF->ZF_CODIGO+"' "
          TCSqlExec(cQry1)

          //Excluir ZZC
          cQry1 := ""
          cQry1 += "UPDATE "+RetSqlName("ZZC")+" SET D_E_L_E_T_ = '*' WHERE ZZC_FILIAL = '"+xFilial("ZZC")+"' AND ZZC_BORDER = '"+SZF->ZF_CODIGO+"' "
		TCSqlExec(cQry1) */

		RecLock("SZF", .f.)
		SZF->ZF_FLAG := "D"
		MsUnLock()
	Else
		MsgBox("Atenção, não foi possível excluir o endereçamento do Borderô "+SZF->ZF_CODIGO+" !", "Atenção", "ALERT")
	Endif
Return

/******************************************************************************************************************/
/*** FATA03_5 - 25/01/06 - RETIRADA PELO BORDERO DE PEDIDOS.                                                    ***/
/***            fRetBor    - Retirada/Baixa de produtos do bordero.                                             ***/
/******************************************************************************************************************/
User Function FATA03_5(cOpc)
	/*
    If SZF->ZF_TIPOBOR $ '1.2' .or. Empty(Alltrim(SZF->ZF_TIPOBOR)) // POR EQTO SÓ PRA SP
		Messagebox("Bordero não pode ser endereçado!","Atenção...",48)
		Return
	Endif      */
	If cOpc $ '1' //Retirada do estoque pela expedição
		fRetBor("R")
	ElseIf cOpc $ '2' //Baixa Retirada do estoque pela expedição
		fRetBor("B")
	Endif
Return

/******************************************************************************************************************/
/*** fRetBor - Retirada por bordero de pedidos.                                                                 ***/
/***         u_FATA03_6 - Validação da retirada de produtos.                                                    ***/
/******************************************************************************************************************/
Static Function fRetBor(cOpc)
	Local oDlg, nX, nY
	Local nOpcA     := 0
	Local nOpcE     := Iif(cOpc $ 'R', 4, 2)
	Local cLinOk    := 'AllwaysTrue()'
	Local cTudoOk   := 'AllwaysTrue()'
	Local cFieldOk  := "U_FATA03_6(aCols, aHeader, @aMatPed, oGetD)"
	//Local nLinhas   := 400
	Local aAltGet   := {"ZZC_RETIRA", "ZZC_GAVETA"}
	Local lPriCar   := .f.
	Local _lOpen    := .F. // Adequação para release 12.1.25
	Local _cAliasSX3:= GetNextAlias() // Adequação para release 12.1.25
	Local cQry1     := ""
	Local cRETFAL   := GetMv("MV_RETFAL")
	// ABERTURA DO DICIONÁRIO SX3 - Adequação para release 12.1.25
	Private aCols   := {}
	Private aHeader := {}
	Private nUsado  := 0
	Private aMatPed := {}
	Private aMatTCQ := {}

	OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
	_lOpen := Select( _cAliasSX3 ) > 0


	If SZF->ZF_FLAG $ 'T.X'
		If !SZF->ZF_CODIGO $ '000000'
			ApMsgStop("Bordero já foi totalmente destinado.")
			Return
		Endif
	ElseIf SZF->ZF_FLAG $ 'D'
		ApMsgStop("Bordero não está endereçado.")
		Return
	ElseIf SZF->ZF_FLAG $ 'E'
		RecLock("SZF", .f.)
		SZF->ZF_FLAG    := 'P'
		SZF->ZF_DATAINI := dDataBase
		SZF->ZF_HORAINI := Time()
		MsUnLock()
		lPriCar := .t.
	Endif

	//Montagem do aHeader
	/*
       DbSelectArea("SX3")
       DbSetOrder(1)
       DbSeek("ZZC")
       While !Eof() .And. (X3_ARQUIVO == "ZZC")
             IF X3USO(X3_USADO) .And. cNivel >= X3_NIVEL .And. !(TRIM(X3_CAMPO) $ "ZZC_FILIAL") .And. !(TRIM(X3_CAMPO) $ "ZZC_BORDERO") .And. !(TRIM(X3_CAMPO) $ "ZZC_PEDIDO") .And. !(TRIM(X3_CAMPO) $ "ZZC_CARGA") .And. !(TRIM(X3_CAMPO) $ "ZZC_OCUPAC") .And. !(TRIM(X3_CAMPO) $ "ZZC_LOCEXP") .And. !(TRIM(X3_CAMPO) $ "ZZC_RESERV")
	            nUsado += 1
	            AADD(aHeader, { Trim(X3_TITULO), X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )
             EndIf
             dbSkip()
       Enddo
	*/
	DbSelectArea( _cAliasSX3 )
	( _cAliasSX3 )->( DbSetOrder(1) )
	( _cAliasSX3 )->( DbSeek("ZZC") )
	While !Eof() .and. ( _cAliasSX3 )->( X3_ARQUIVO ) == "ZZC"
		IF X3Uso( ( _cAliasSX3 )->( X3_USADO ) ) .and. cNivel >= ( _cAliasSX3 )->( X3_NIVEL ) .And. !(AllTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "ZZC_FILIAL") .And. !(AllTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) ==  "ZZC_BORDERO") .And. !(AllTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "ZZC_PEDIDO") .And. !(AllTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "ZZC_CARGA") .And. !(AllTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "ZZC_OCUPAC") .And. !(AllTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "ZZC_LOCEXP") .And. !(AllTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "ZZC_RESERV")
			nUsado += 1
			AADD(aHeader, { ( _cAliasSX3 )->(X3_TITULO), ( _cAliasSX3 )->(X3_CAMPO), ( _cAliasSX3 )->(X3_PICTURE), ( _cAliasSX3 )->(X3_TAMANHO), ( _cAliasSX3 )->(X3_DECIMAL), ( _cAliasSX3 )->(X3_VALID), ( _cAliasSX3 )->(X3_USADO), ( _cAliasSX3 )->(X3_TIPO), ( _cAliasSX3 )->(X3_ARQUIVO), ( _cAliasSX3 )->(X3_CONTEXT) } )
		EndIf
		DbSkip()
	EndDo

	DbSelectArea( _cAliasSX3 )
	DbCloseArea()

	If GetMv("MV_RETFAL") $ 'N' //Padrão N (faltante)
		aHeader[aScan(aHeader, {|x| Alltrim(x[2]) == "ZZC_RETIRA"})][1] := "Qtd Faltante"
	Endif

	//Montagem do aCols
	If !SZF->ZF_CODIGO $ '000000'
		cQry1 := ""
		cQry1 += "SELECT ZZC.ZZC_PRODUT AS PRODUTO, SB1.B1_DESC AS DESCRICAO, SB2.B2_LOCALIZ AS LOCALIZ, ZZC.ZZC_QUANTI AS QUANTIDADE, ZZC.ZZC_RETIRA AS RETIRA, ZZC.ZZC_GAVETA AS GAVETA, ZZC.ZZC_VOLUME AS VOLUME, ZZC.ZZC_VOLRET, ZZC.ZZC_SEPARA AS SEPARA "
		cQry1 += "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
		cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON ZZC.ZZC_FILIAL = SB1.B1_FILIAL AND ZZC.ZZC_PRODUT = SB1.B1_COD AND SB1.D_E_L_E_T_ = '' "
		cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON SB1.B1_FILIAL = SB2.B2_FILIAL AND SB1.B1_COD = SB2.B2_COD AND SB1.B1_LOCPAD = SB2.B2_LOCAL AND SB2.D_E_L_E_T_ = '' "
		cQry1 += "WHERE ZZC.ZZC_FILIAL = '"+xFilial("ZZC")+"' "
		cQry1 += "  AND ZZC.D_E_L_E_T_ = '' "
		cQry1 += "  AND ZZC.ZZC_BORDER = '"+SZF->ZF_CODIGO+"' "
		cQry1 += "  AND (ZZC.ZZC_SEPARA <> 'S' AND (ZZC.ZZC_QUANTI <> ZZC.ZZC_RETIRA)) "
		cQry1 += "ORDER BY 3, 1 "
	Else
		//Nesse caso, verificar antes se todos os itens estão carregados depois refazer a query novamente com os dados já gravados
		cQry1 := ""
		cQry1 += "SELECT SZF.ZF_CODIGO, SUBSTRING(SZG.ZG_PEDIDO, 3, 6) AS ZG_PEDIDO, SC6.C6_ITEM, SC6.C6_PRODUTO, SC6.C6_QTDVEN, SC6.C6_VOLITEM, ZZC.ZZC_PRODUT AS PRODUTO, SB1.B1_DESC AS DESCRICAO, SB2.B2_LOCALIZ AS LOCALIZ, ZZC.ZZC_QUANTI AS QUANTIDADE, ZZC.ZZC_RETIRA AS RETIRA, ZZC.ZZC_GAVETA AS GAVETA, ZZC.ZZC_VOLUME AS VOLUME, ZZC.ZZC_VOLRET, ZZC.ZZC_SEPARA AS SEPARA "
		cQry1 += "FROM "+RetSqlName("SZF")+" SZF WITH (NOLOCK) "
		cQry1 += "LEFT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH (NOLOCK) ON SZG.ZG_FILIAL = SZF.ZF_FILIAL AND SZG.ZG_CODIGO = SZF.ZF_CODIGO AND SZG.D_E_L_E_T_ = '' "
		cQry1 += "LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON SC6.C6_FILIAL = SZG.ZG_FILIAL AND SC6.C6_NUM    = SUBSTRING(SZG.ZG_PEDIDO, 3, 6) AND SC6.D_E_L_E_T_ = '' "
		cQry1 += "LEFT OUTER JOIN "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) ON ZZC.ZZC_FILIAL = SC6.C6_FILIAL AND ZZC.ZZC_BORDER = SZF.ZF_CODIGO AND ZZC.ZZC_PEDIDO = SC6.C6_NUM AND ZZC.ZZC_PRODUT = SC6.C6_PRODUTO AND ZZC.D_E_L_E_T_ = '' "
		cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON SB1.B1_FILIAL  = ZZC.ZZC_FILIAL AND SB1.B1_COD = ZZC.ZZC_PRODUT AND SB1.D_E_L_E_T_ = '' "
		cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON SB2.B2_FILIAL = SB1.B1_FILIAL AND SB2.B2_COD = SB1.B1_COD AND SB2.B2_LOCAL = SB1.B1_LOCPAD AND SB2.D_E_L_E_T_ = '' "
		cQry1 += "WHERE SZF.ZF_FILIAL  = '"+xFilial("SZF")+"' "
		cQry1 += "  AND SZF.D_E_L_E_T_ = '' "
		cQry1 += "  AND SZF.ZF_CODIGO  = '000000' "
		cQry1 += "ORDER BY SZG.ZG_PEDIDO, SC6.C6_ITEM "

		TCQuery cQry1 ALIAS "TCQ" NEW
		DbSelectArea("TCQ")
		DbGoTop()
		While !Eof()
			If Empty(TCQ->PRODUTO)
				RecLock("ZZC", .t.)
				ZZC->ZZC_FILIAL := xFilial("SC6")
				ZZC->ZZC_BORDER := '000000'
				ZZC->ZZC_PEDIDO := TCQ->ZG_PEDIDO
				ZZC->ZZC_PRODUT := TCQ->C6_PRODUTO
				ZZC->ZZC_QUANTI := TCQ->C6_QTDVEN
				ZZC->ZZC_RETIRA := 0.0
				ZZC->ZZC_RESERV := 0.0
				ZZC->ZZC_GAVETA := Iif(Empty(Posicione("SB2", 1, xFilial("SB2")+SC6->C6_PRODUTO+Posicione("SB1", 1, xFilial("SB1")+SC6->C6_PRODUTO, "B1_LOCPAD"), "B2_LOCALIZ")), '000', '')
				ZZC->ZZC_VOLUME := TCQ->C6_VOLITEM
				ZZC->ZZC_VOLRET := 0.0
				ZZC->ZZC_CARGA  := ''
				ZZC->ZZC_OCUPAC := 0.0
				ZZC->ZZC_DESPAC := ''
				ZZC->ZZC_SEPARA := 'N'
				ZZC->ZZC_LOTE   := ''
				ZZC->ZZC_SEMID  := ''
				ZZC->ZZC_DTHOT  := ''
				ZZC->ZZC_TPINCL := ''
				ZZC->ZZC_LOCEXP := ''
				MsUnLock()
			Endif
			DbSelectArea("TCQ")
			DbSkip()
		Enddo
		DbSelectArea("TCQ")
		DbCloseArea()
		cQry1 := ""
		cQry1 += "SELECT ZZC.ZZC_PRODUT AS PRODUTO, SB1.B1_DESC AS DESCRICAO, SB2.B2_LOCALIZ AS LOCALIZ, ZZC.ZZC_QUANTI AS QUANTIDADE, ZZC.ZZC_RETIRA AS RETIRA, ZZC.ZZC_GAVETA AS GAVETA, ZZC.ZZC_VOLUME AS VOLUME, ZZC.ZZC_VOLRET, ZZC.ZZC_SEPARA AS SEPARA "
		cQry1 += "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
		cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 ON ZZC.ZZC_FILIAL = SB1.B1_FILIAL AND ZZC.ZZC_PRODUT = SB1.B1_COD AND SB1.D_E_L_E_T_ = '' "
		cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 ON SB1.B1_FILIAL = SB2.B2_FILIAL AND SB1.B1_COD = SB2.B2_COD AND SB1.B1_LOCPAD = SB2.B2_LOCAL AND SB2.D_E_L_E_T_ = '' "
		cQry1 += "WHERE ZZC.ZZC_FILIAL = '"+xFilial("ZZC")+"' "
		cQry1 += "  AND ZZC.D_E_L_E_T_ = '' "
		cQry1 += "  AND ZZC.ZZC_BORDER = '"+SZF->ZF_CODIGO+"' "
		cQry1 += "  AND (ZZC.ZZC_SEPARA <> 'S' AND (ZZC.ZZC_QUANTI <> ZZC.ZZC_RETIRA)) "
		cQry1 += "ORDER BY 3, 1 "
	Endif
	TCQuery cQry1 ALIAS "TCQ" NEW
	DbSelectArea("TCQ")
	While !Eof()
		//If GetMv("MV_RETFAL") $ 'S' //Quantidade Retirada DESABILITADO RELEASE 12.1.25
		If Alltrim(cRETFAL) == 'S' //Quantidade Retirada
			If aScan(aMatTCQ, {|x| x[1] == TCQ->PRODUTO}) == 0
				If TCQ->QUANTIDADE > TCQ->RETIRA
					If TCQ->SEPARA == 'N'
						nQtdRet := 0
						nQtdVol := 0
					ElseIf Empty(TCQ->SEPARA)
						nQtdRet := 999999
						nQtdVol := TCQ->VOLUME
					ElseIf TCQ->SEPARA $ 'S'
						nQtdRet := TCQ->RETIRA
						nQtdVol := TCQ->ZZC_VOLRET
					Endif
					aadd(aMatTCQ, {TCQ->PRODUTO, TCQ->DESCRICAO, TCQ->LOCALIZ, TCQ->QUANTIDADE, nQtdRet, TCQ->GAVETA, TCQ->VOLUME, nQtdVol, .f. })
				ElseIf TCQ->QUANTIDADE == TCQ->RETIRA
					aadd(aMatTCQ, {TCQ->PRODUTO, TCQ->DESCRICAO, TCQ->LOCALIZ, TCQ->QUANTIDADE, TCQ->QUANTIDADE, TCQ->GAVETA, TCQ->VOLUME, TCQ->VOLUME, .f. })
				Endif
			Else
				If TCQ->SEPARA == 'N'
					nQtdRet := 0
					nQtdVol := 0
				ElseIf Empty(TCQ->SEPARA)
					nQtdRet := 999999
					nQtdVol := TCQ->VOLUME
				ElseIf TCQ->SEPARA $ 'S'
					nQtdRet := TCQ->RETIRA
					nQtdVol := TCQ->ZZC_VOLRET
					aMatTCQ[aScan(aMatTCQ, {|x| x[1] == TCQ->PRODUTO})][5] += nQtdRet
					aMatTCQ[aScan(aMatTCQ, {|x| x[1] == TCQ->PRODUTO})][8] += nQtdVol
				Endif
				If Empty(aMatTCQ[aScan(aMatTCQ, {|x| x[1] == TCQ->PRODUTO})][6])
					aMatTCQ[aScan(aMatTCQ, {|x| x[1] == TCQ->PRODUTO})][6] := TCQ->GAVETA
				Endif
				aMatTCQ[aScan(aMatTCQ, {|x| x[1] == TCQ->PRODUTO})][4] += TCQ->QUANTIDADE
				aMatTCQ[aScan(aMatTCQ, {|x| x[1] == TCQ->PRODUTO})][7] += TCQ->VOLUME
			Endif
		Else //Quantidade Faltante
			If aScan(aMatTCQ, {|x| x[1] == TCQ->PRODUTO}) == 0
				If TCQ->QUANTIDADE > TCQ->RETIRA
					If Empty(TCQ->SEPARA)
						nQtdRet := 0
						nQtdVol := TCQ->VOLUME
					Else
						If TCQ->SEPARA == 'N'
							nQtdRet := TCQ->QUANTIDADE - TCQ->RETIRA
							nQtdVol := TCQ->ZZC_VOLRET
						ElseIf TCQ->SEPARA $ 'S'
							nQtdRet := 0
							nQtdVol := TCQ->ZZC_VOLRET
						Endif
					Endif
					aadd(aMatTCQ, {TCQ->PRODUTO, TCQ->DESCRICAO, TCQ->LOCALIZ, TCQ->QUANTIDADE, nQtdRet, TCQ->GAVETA, TCQ->VOLUME, nQtdVol, .f. })
				ElseIf TCQ->QUANTIDADE == TCQ->RETIRA
					aadd(aMatTCQ, {TCQ->PRODUTO, TCQ->DESCRICAO, TCQ->LOCALIZ, TCQ->QUANTIDADE, 0, TCQ->GAVETA, TCQ->VOLUME, TCQ->VOLUME, .f. })
				Endif
			Else
				If Empty(TCQ->SEPARA)
					nQtdRet := 0
					nQtdVol := TCQ->VOLUME
				Else
					If TCQ->SEPARA == 'N'
						nQtdRet := TCQ->QUANTIDADE - TCQ->RETIRA
						nQtdVol := TCQ->ZZC_VOLRET
						aMatTCQ[aScan(aMatTCQ, {|x| x[1] == TCQ->PRODUTO})][5] += nQtdRet
						aMatTCQ[aScan(aMatTCQ, {|x| x[1] == TCQ->PRODUTO})][8] += nQtdVol
					ElseIf TCQ->SEPARA == 'S'
						nQtdRet := 0
						nQtdVol := TCQ->ZZC_VOLRET
					Endif
				Endif
				If Empty(aMatTCQ[aScan(aMatTCQ, {|x| x[1] == TCQ->PRODUTO})][6])
					aMatTCQ[aScan(aMatTCQ, {|x| x[1] == TCQ->PRODUTO})][6] := TCQ->GAVETA
				Endif
				aMatTCQ[aScan(aMatTCQ, {|x| x[1] == TCQ->PRODUTO})][4] += TCQ->QUANTIDADE
				aMatTCQ[aScan(aMatTCQ, {|x| x[1] == TCQ->PRODUTO})][7] += TCQ->VOLUME
			Endif
		Endif
		DbSelectArea("TCQ")
		DbSkip()
	Enddo
	DbSelectArea("TCQ")
	DbCloseArea()

	//Ordem matriz com dados do Bordero de Pedidos
	cOrdAtu  := "N"
	cLocaliz := ""
	aMatOrd  := {}
	For nY := 1 To Len(aMatTCQ)
		cLocaliz := SubStr(Alltrim(aMatTCq[nY][3]), 1, 3)
		If Empty(cLocaliz)
			If aScan(aMatOrd, {|x| Alltrim(x[1]) == Alltrim(cLocaliz)}) == 0
				aadd(aMatOrd, {cLocaliz, "N"})
			Endif
		Else
			For nX := 1 To Len(aMatTCQ)
				If cLocaliz == SubStr(Alltrim(aMatTCQ[nY][3]), 1, 3)
					If aScan(aMatOrd, {|x| Alltrim(x[1]) == Alltrim(cLocaliz)}) == 0
						aadd(aMatOrd, {SubStr(cLocaliz, 1, 3), cOrdAtu})
					Endif
				Endif
			Next
			cOrdAtu := Iif(cOrdAtu == "I", "N", "I")
		Endif
	Next
	For nY := 1 To Len(aMatOrd)
		aMatAux := {}
		For nX := 1 To Len(aMatTCQ)
			If SubStr(Alltrim(aMatTCQ[nX][3]), 1, 3) == aMatOrd[nY][1]
				lSepDep := .f.
				If lPriCar
					If Len(Alltrim(aMatTCQ[nX][1])) == 4
						//lSepDep := .t.
					ElseIf Len(Alltrim(aMatTCQ[nX][1])) == 12
						If Empty(aMatTCQ[nX][3]) //Produto sem endereços (Produto Específico)
							lSepDep := .t.
						Endif
					Endif
				Endif
				If lSepDep
					DbSelectArea("ZZC")
					DbGoTop()
					DbSetOrder(3)
					DbSeek(xFilial("ZZC")+SZF->ZF_CODIGO+aMatTCQ[nX][1], .t.)
					If Found()
						While !Eof() .and. (ZZC->ZZC_FILIAL == xFilial("ZZC")) .and. (ZZC->ZZC_BORDER == SZF->ZF_CODIGO) .and. (ZZC->ZZC_PRODUT == aMatTCQ[nX][1])
							RecLock("ZZC", .f.)
							ZZC->ZZC_RETIRA :=  0
							ZZC->ZZC_VOLRET :=  0
							ZZC->ZZC_GAVETA := '999'
							ZZC->ZZC_SEPARA := 'N'
							ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
							MsUnLock()
							DbSelectArea("ZZC")
							DbSkip()
						Enddo
					Endif
				Endif
				aadd(aMatAux, { aMatTCQ[nX][1], aMatTCQ[nX][2], aMatTCQ[nX][3], aMatTCQ[nX][4], Iif(lSepDep, aMatTCQ[nX][4], aMatTCQ[nX][5]), Iif(lSepDep, '999',aMatTCQ[nX][6]), aMatTCQ[nX][7], aMatTCQ[nX][8], .f. })
			Endif
		Next
		//Ordena Matriz
		If aMatOrd[nY][2] $ 'I'
			aSort(aMatAux, , , {|x, y| x[4] > y[4]})
		Endif
		For nX := 1 To Len(aMatAux)
			If SZF->ZF_CODIGO $ '000000'
				If Empty(aMatAux[nX][3])//Somente produtos específicos para o bordero 000000
					aAdd(aCols, {aMatAux[nX][01], aMatAux[nX][02], aMatAux[nX][03], aMatAux[nX][04], Iif(aMatAux[nX][05] == 0, 999999, aMatAux[nX][05]), Iif(aMatAux[nX][05] == 0, '   ', aMatAux[nX][06]), aMatAux[nX][07], aMatAux[nX][08], aMatAux[nX][09] })
				Endif
			Else
				aAdd(aCols, {aMatAux[nX][01], aMatAux[nX][02], aMatAux[nX][03], aMatAux[nX][04], Iif(aMatAux[nX][05] == 0, 999999, aMatAux[nX][05]), Iif(aMatAux[nX][05] == 0, '   ', aMatAux[nX][06]), aMatAux[nX][07], aMatAux[nX][08], aMatAux[nX][09] })
			Endif
		Next
	Next

	//Monta tela para Retirada / Baixa Bordero
	DbSelectArea("ZZC")
	DEFINE MSDIALOG oDlg FROM 000,000 TO 032,100 TITLE OemToAnsi("Retirada de itens do estoque - "+SZF->ZF_CODIGO) OF oMainWnd
	oGetD := MsGetDados():New( 020, 004, 240, 393, nOpcE, cLinOk, cTudoOk, "", .f., aAltGet, 2, , Len(aCols), cFieldOk )
	If cOpc $ 'B'
		@ 001,001 GROUP oGrp1 TO 020,071 LABEL OemToAnsi('')    COLOR CLR_HRED                        PIXEL OF oDlg
		@ 10,008 BTNBMP oBtnCRe RESOURCE "OK"             SIZE 127,24 ACTION(nOpca := 1, oDlg:End()) PIXEL OF oDlg
	Endif
	@ 001,325 GROUP oGrp2 TO 020,395 LABEL OemToAnsi('')    COLOR CLR_HRED                        PIXEL OF oDlg
	@ 10,657 BTNBMP oBtnSRe RESOURCE "CANCEL"         SIZE 127,24 ACTION(nOpca := 0, oDlg:End()) PIXEL OF oDlg

	If cOpc $ 'R'
		If GETMV("MV_QUALCON") == 1
			@ 001,250 GROUP oGrp3 TO 020,320 LABEL OemToAnsi('')    COLOR CLR_HRED                        PIXEL OF oDlg
			@ 10,507 BTNBMP oBtnPRe RESOURCE "PESQUISA_OCEAN" SIZE 127,24 ACTION(U_FATA03_3("R"))        PIXEL OF oDlg
		ElseIf GETMV("MV_QUALCON") == 2
			@ 001,250 GROUP oGrp3 TO 020,320 LABEL OemToAnsi('')    COLOR CLR_HRED                        PIXEL OF oDlg
			@ 10,507 BTNBMP oBtnCII RESOURCE "PESQUISA_OCEAN" SIZE 127,24 ACTION(U_FATA03_A("R"))     PIXEL OF oDlg
		Else
			@ 001,250 GROUP oGrp3 TO 020,320 LABEL OemToAnsi('')    COLOR CLR_HRED                        PIXEL OF oDlg
			@ 10,507 BTNBMP oBtnPRe RESOURCE "PESQUISA_OCEAN" SIZE 127,24 ACTION(U_FATA03_3("R"))        PIXEL OF oDlg
			@ 001,175 GROUP oGrp3 TO 020,320 LABEL OemToAnsi('')    COLOR CLR_HRED                        PIXEL OF oDlg
			@ 10,357 BTNBMP oBtnCII RESOURCE "PESQUISA_OCEAN" SIZE 127,24 ACTION(U_FATA03_A("R"))        PIXEL OF oDlg
		Endif
	Endif
	If cOpc $ 'B'
		oBtnCRe:cCaption := PADR(OemToAnsi("Confirma Retirada"), 20)
		oBtnCRe:cToolTip := OemToAnsi("Confirma retirada dos itens...")
	Endif

	oBtnSRe:cCaption := PADR(OemToAnsi("Sair Retirada"), 20)
	oBtnSRe:cToolTip := OemToAnsi("Sai da retirada sem atualizar...")

	If cOpc $ 'R'
		If GETMV("MV_QUALCON") == 1
			oBtnPRe:cCaption := PADR(OemToAnsi("Consulta Produto"), 20)
			oBtnPRe:cToolTip := OemToAnsi("Consulta produtos em outros borderos...")
		ElseIf GETMV("MV_QUALCON") == 2
			oBtnCII:cCaption := PADR(OemToAnsi("Consulta II Produto"), 20)
			oBtnCII:cToolTip := OemToAnsi("Consulta II produtos em outros borderos...")
		Else
			oBtnPRe:cCaption := PADR(OemToAnsi("Consulta Produto"), 20)
			oBtnPRe:cToolTip := OemToAnsi("Consulta produtos em outros borderos...")
			oBtnCII:cCaption := PADR(OemToAnsi("Consulta II Produto"), 20)
			oBtnCII:cToolTip := OemToAnsi("Consulta II produtos em outros borderos...")
		Endif
	Endif

	ACTIVATE MSDIALOG oDlg CENTERED
	If nOpca == 1
		lValGav := .f.
		cMsgGav := "Atenção, existe produto sem gaveta cadastrada. VERIFIQUE!!!"+Chr(13)+Chr(10)
		For nX := 1 To Len(aCols)
			If aCols[nX][5] <> 999999
				DbSelectArea("ZZC")
				DbSetOrder(3)
				DbSeek(xFilial("ZZC")+SZF->ZF_CODIGO+aCols[nX][1], .t.)
				If Found()
					If ZZC->ZZC_RETIRA < ZZC->ZZC_QUANTI .and. aCols[nX][5] <> 999999
						If Empty(ZZC->ZZC_GAVETA)
							lValGav := .t.
							cMsgGav += aCols[nX][1]+Chr(13)+Chr(10)
						Endif
					Endif
				Endif
			Endif
		Next
		If lValGav
			MsgStop(cMsgGav)
			Return
		Endif
		If MsgYesNo("Confirma todos os itens retirados do estoque ?", "Atenção")
			//Ajuste das retiradas totais
			For nX := 1 To Len(aCols)
				//If GetMv("MV_RETFAL") $ 'S' DESABILITADA RELEASE 12.1.25
				If Alltrim(cREFFAL) == 'S'
					If aCols[nX][5] == 0                                            //Retira igual a zero
						//Não há a necessidade de nenhuma atualização, pois a mesma já é feita on-line;
					ElseIf aCols[nX][5] == 999999 .or. aCols[nX][5] == aCols[nX][4] //Retira igual a 999999 ou Retira igual a quantidade solicitada
						DbSelectArea("ZZC")
						DbSetOrder(3)
						DbSeek(xFilial("ZZC")+SZF->ZF_CODIGO+aCols[nX][1], .t.)
						If Found()
							While !Eof() .and. (ZZC->ZZC_FILIAL == xFilial("ZZC")) .and. (ZZC->ZZC_BORDER == SZF->ZF_CODIGO) .and. (ZZC->ZZC_PRODUT == aCols[nX][1])
								RecLock("ZZC", .f.)
								ZZC->ZZC_RETIRA := ZZC->ZZC_QUANTI
								ZZC->ZZC_VOLRET := ZZC->ZZC_VOLUME
								ZZC->ZZC_SEPARA := 'S'
								ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
								MsUnLock()
								DbSelectArea("ZZC")
								DbSkip()
							EndDo
						Endif
					ElseIf aCols[nX][5] < aCols[nX][4]  //Retira menor do que a quantidade solicidado
						//Ajuste de retiradas parciais
						For nY := 1 To Len(aMatPed)
							DbSelectArea("ZZC")
							DbSetOrder(1)
							DbSeek(xFilial("ZZC")+SZF->ZF_CODIGO+aMatPed[nY][1]+aMatPed[nY][2], .t.)
							If Found()
								RecLock("ZZC", .f.)
								ZZC->ZZC_RETIRA := aMatPed[nY][3]
								ZZC->ZZC_VOLRET := fCalVol(aMatPed[nY][2], aMatPed[nY][3])
								ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
								MsUnLock()
							Endif
						Next
					Endif
				Else
					/**********************************************************************************************/
					//Quantidade Faltante
					If aCols[nX][5] == 0 .OR. aCols[nX][5] == aCols[nX][4] //Retira igual a zero ou Retira igual a quantidade solicitada
						DbSelectArea("ZZC")
						DbSetOrder(3)
						DbSeek(xFilial("ZZC")+SZF->ZF_CODIGO+aCols[nX][1], .t.)
						If Found()
							While !Eof() .and. (ZZC->ZZC_FILIAL == xFilial("ZZC")) .and. ZZC->ZZC_BORDER == SZF->ZF_CODIGO .and. ZZC->ZZC_PRODUT == aCols[nX][1]
								If ZZC->ZZC_SEPARA <> "S"
									RecLock("ZZC", .f.)
									ZZC->ZZC_RETIRA := 0
									ZZC->ZZC_VOLRET := 0
									ZZC->ZZC_SEPARA := 'N'
									ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
									MsUnLock()
								Endif
								DbSelectArea("ZZC")
								DbSkip()
							EndDo
						Endif
					ElseIf aCols[nX][5] == 999999  //Quantidade igual a 999999, tudo retirado.
						DbSelectArea("ZZC")
						DbSetOrder(3)
						DbSeek(xFilial("ZZC")+SZF->ZF_CODIGO+aCols[nX][1], .t.)
						If Found()
							While !Eof() .and. (ZZC->ZZC_FILIAL == xFilial("ZZC")) .and. ZZC->ZZC_BORDER == SZF->ZF_CODIGO .and. ZZC->ZZC_PRODUT == aCols[nX][1]
								RecLock("ZZC", .f.)
								ZZC->ZZC_RETIRA := ZZC->ZZC_QUANTI
								ZZC->ZZC_VOLRET := ZZC->ZZC_VOLUME
								ZZC->ZZC_SEPARA := 'S'
								ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
								MsUnLock()
								DbSelectArea("ZZC")
								DbSkip()
							EndDo
						Endif
					ElseIf aCols[nX][4] > aCols[nX][5]
						DbSelectArea("ZZC")
						DbSetOrder(3)
						DbSeek(xFilial("ZZC")+SZF->ZF_CODIGO+aCols[nX][1], .t.)
						If Found()
							While !Eof() .and. (ZZC->ZZC_FILIAL == xFilial("ZZC")) .and. ZZC->ZZC_BORDER == SZF->ZF_CODIGO .and. ZZC->ZZC_PRODUT == aCols[nX][1]
								If ZZC->ZZC_SEPARA $ ' .S'
									RecLock("ZZC", .f.)
									ZZC->ZZC_RETIRA := ZZC->ZZC_QUANTI
									ZZC->ZZC_VOLRET := ZZC->ZZC_VOLUME
									ZZC->ZZC_SEPARA := 'S'
									ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
									MsUnLock()
								Endif
								DbSelectArea("ZZC")
								DbSkip()
							EndDo
						Endif
					Endif
					/**********************************************************************************************/
				Endif
			Next
			DbSelectArea("SZF")
			RecLock("SZF", .f.)
			SZF->ZF_FLAG    := 'T'
			SZF->ZF_DATAFIM := dDataBase
			SZF->ZF_HORAFIM := Time()
			MsUnLock()
		Endif
	Endif
	//Verificação se o bordero foi totalmente retirado.
	//nConReg := 0
	//aRetTot := {}
	//DbSelectArea("ZZC")
	//DbSetOrder(1)
	//DbGoTop()
	//DbSeek(xFilial("ZZC")+SZF->ZF_CODIGO, .t.)
	//If Found()
	//   While !Eof() .and. ZZC->ZZC_BORDER == SZF->ZF_CODIGO
	//         nConReg += 1
	//         If ZZC->ZZC_SEPARA $ 'S'
	//            aadd(aRetTot, 'S')
	//         Endif
	//         DbSelectArea("ZZC")
	//         DbSkip()
	//   Enddo
	//Endif
	//If Len(aRetTot) == nConReg
	//   RecLock("SZF", .f.)
	//      SZF->ZF_FLAG := 'T'
	//      SZF->ZF_DATAFIM := dDataBase
	//      SZF->ZF_HORAFIM := Time()
	//   MsUnLock()
	//Endif
Return

/******************************************************************************************************************/
/*** FATA03_6 - Validação da retirada de produtos do bordero                                                    ***/
/***            fMonPed - Monta dados com os pedidos do produto que está sendo retirado                         ***/
/***            fCalVol - Calcula volume dos pedidos dos produtos                                               ***/
/******************************************************************************************************************/
User Function FATA03_6(aCols, aHeader, aMatPed, oGetD)
	Local nPosPro := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZC_PRODUT" } ) //Código do Produto
	Local nPosQtI := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZC_QUANTI" } ) //Quantidade do Item
	Local nPosQtR := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZC_RETIRA" } ) //Quantidade Retirada
	//Local nPosVlI := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZC_VOLUME" } ) //Volume do Item
	Local nPosVlR := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZC_VOLRET" } ) //Volume Retirado
	Local nPosGav := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZC_GAVETA" } ) //Gaveta
	Local nPosicao:= 0
	If oGetD == Nil
		oDlg := GetWndDefault()
		oDlg := oGetD:oWnd
	Endif

	If __ReadVar $ "M->ZZC_RETIRA"
		If GETMV("MV_RETFAL") $ 'S'
			If M->ZZC_RETIRA > aCols[n][nPosQtI] .AND. M->ZZC_RETIRA <> 999999
				ApMsgStop("Atenção, quantidade retirada não pode ser maior que a quantidade solicitada")
				Return(.f.)
			ElseIf M->ZZC_RETIRA < aCols[n][nPosQtI] .and. M->ZZC_RETIRA > 0
				nPosicao          := n
				nQtdRet           := fMonPed(@aHeader, @aCols, SZF->ZF_CODIGO, aCols[n][nPosPro], aCols[n][nPosQtI], @aMatPed)
				If nQtdRet == 0
					n := Iif(n < 1, 1, Iif((n - 1) == 0, 1, (n - 1)) )
					M->ZZC_RETIRA := aCols[n][5]
				Else
					n                 := nPosicao
					M->ZZC_RETIRA     := nQtdRet
					aCols[n][nPosQtR] := nQtdRet
					aCols[n][nPosVlR] := Iif(nQtdRet == 0, 0, Iif(nQtdRet == 999999, fCalVol(aCols[n][nPosPro], aCols[n][nPosQtI]), fCalVol(aCols[n][nPosPro], nQtdRet) ))
				Endif
			ElseIf M->ZZC_RETIRA == 0
				aCols[n][nPosVlR] := Iif(M->ZZC_RETIRA == 0, 0, fCalVol(aCols[n][nPosPro], M->ZZC_RETIRA))
				DbSelectArea("ZZC")
				DbGoTop()
				DbSetOrder(3)
				DbSeek(xFilial("ZZC")+SZF->ZF_CODIGO+aCols[n][nPosPro], .t.)
				If Found()
					While !Eof() .AND. (ZZC->ZZC_FILIAL == xFilial("ZZC")) .AND. ZZC->ZZC_BORDER == SZF->ZF_CODIGO .AND. ZZC->ZZC_PRODUT == aCols[n][nPosPro]
						RecLock("ZZC", .f.)
						ZZC->ZZC_RETIRA := 0
						ZZC->ZZC_VOLRET := 0
						ZZC->ZZC_SEPARA := "N"
						ZZC->ZZC_GAVETA := aCols[n][nPosGav]
						ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
						MsUnLock()
						DbSelectArea("ZZC")
						DbSkip()
					Enddo
				Endif
			ElseIf M->ZZC_RETIRA == 999999
				aCols[n][nPosVlR] := Iif(M->ZZC_RETIRA == 0, 0, fCalVol(aCols[n][nPosPro], aCols[n][nPosQtI]))
				aCols[n][nPosGav] := space(03)
				DbSelectArea("ZZC")
				DbGoTop()
				DbSetOrder(3)
				DbSeek(xFilial("ZZC")+SZF->ZF_CODIGO+aCols[n][nPosPro], .t.)
				If Found()
					While !Eof() .AND. (ZZC->ZZC_FILIAL == xFilial("ZZC"))  .AND. ZZC->ZZC_BORDER == SZF->ZF_CODIGO .AND. ZZC->ZZC_PRODUT == aCols[n][nPosPro]
						RecLock("ZZC", .f.)
						ZZC->ZZC_RETIRA := 0
						ZZC->ZZC_SEPARA := ""
						ZZC->ZZC_GAVETA := space(03)
						ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
						MsUnLock()
						DbSelectArea("ZZC")
						DbSkip()
					Enddo
				Endif
			Endif
		Else //Quantidade Faltante
			If M->ZZC_RETIRA == 0 .or. M->ZZC_RETIRA == 999999
				cQry1 := ""
				cQry1 += "SELECT SUM(ZZC.ZZC_QUANTI) AS ZZC_QUANTI, SUM(ZZC.ZZC_RETIRA) AS ZZC_RETIRA "
				cQry1 += "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
				cQry1 += "WHERE ZZC.ZZC_FILIAL = '"+xFilial("ZZC")+"' "
				cQry1 += "  AND ZZC.D_E_L_E_T_ = '' "
				cQry1 += "  AND ZZC.ZZC_BORDER = '"+SZF->ZF_CODIGO+"' "
				cQry1 += "  AND ZZC.ZZC_PRODUT = '"+aCols[n][nPosPro]+"' "
				cQry1 += "  AND ZZC.ZZC_SEPARA <> 'S' "
				TCQuery cQry1 Alias "DIF" NEW
				If DIF->ZZC_RETIRA > 0
					If DIF->ZZC_QUANTI > DIF->ZZC_RETIRA
						MsgBox("Atenção esse item já possui retirada parcial.", "Atenção", "STOP")
						DbSelectArea("DIF")
						DbCloseArea()
						Return(.f.)
					ElseIf DIF->ZZC_QUANTI == DIF->ZZC_RETIRA
						MsgBox("Atenção esse item já foi retirado.", "Atenção", "STOP")
						DbSelectArea("DIF")
						DbCloseArea()
						Return(.f.)
					Endif
				Else
					M->ZZC_RETIRA     := 999999
					aCols[n][nPosQtR] := 999999
					aCols[n][nPosVlR] := fCalVol(aCols[n][nPosPro], aCols[n][nPosQtI])
					aCols[n][nPosGav] := space(03)
					DbSelectArea("ZZC")
					DbGoTop()
					DbSetOrder(3)
					DbSeek(xFilial("ZZC")+SZF->ZF_CODIGO+aCols[n][nPosPro], .t.)
					If Found()
						While !Eof() .AND. (ZZC->ZZC_FILIAL == xFilial("ZZC")) .AND. ZZC->ZZC_BORDER == SZF->ZF_CODIGO .AND. ZZC->ZZC_PRODUT == aCols[n][nPosPro]
							RecLock("ZZC", .f.)
							ZZC->ZZC_RETIRA := 0
							ZZC->ZZC_SEPARA := ""
							ZZC->ZZC_GAVETA := space(03)
							ZZC->ZZC_VOLRET := 0
							ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
							MsUnLock()
							DbSelectArea("ZZC")
							DbSkip()
						Enddo
					Endif
				Endif
				DbSelectArea("DIF")
				DbCloseArea()
			ElseIf M->ZZC_RETIRA > aCols[n][nPosQtI] .and. M->ZZC_RETIRA <> 999999
				ApMsgStop("Atenção, quantidade retirada não pode ser maior que a quantidade solicitada")
				Return(.f.)
			ElseIf M->ZZC_RETIRA < aCols[n][nPosQtI] .and. M->ZZC_RETIRA < 0
				ApMsgStop("Atenção, quantidade retirada não pode ser menor que zero")
				Return(.f.)
			ElseIf M->ZZC_RETIRA == aCols[n][nPosQtI]
				aCols[n][nPosQtR] := M->ZZC_RETIRA
				DbSelectArea("ZZC")
				DbSetOrder(3)
				DbSeek(xFilial("ZZC")+SZF->ZF_CODIGO+aCols[n][nPosPro], .t.)
				If Found()
					While !Eof() .AND. (ZZC->ZZC_FILIAL == xFilial("ZZC")) .AND. ZZC->ZZC_BORDER == SZF->ZF_CODIGO .AND. ZZC->ZZC_PRODUT == aCols[n][nPosPro]
						If ZZC->ZZC_SEPARA <> 'S'
							RecLock("ZZC", .f.)
							ZZC->ZZC_RETIRA := 0
							ZZC->ZZC_SEPARA := "N"
							ZZC->ZZC_VOLRET := 0
							ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
							MsUnLock()
						Endif
						DbSelectArea("ZZC")
						DbSkip()
					Enddo
				Endif
			ElseIf M->ZZC_RETIRA < aCols[n][nPosQtI] .and. M->ZZC_RETIRA > 0
				nPosicao          := n
				nQtdRet           := fMonPed(@aHeader, @aCols, SZF->ZF_CODIGO, aCols[n][nPosPro], aCols[n][nPosQtI], @aMatPed)
				//If nQtdRet == 0
				//   n := Iif(n < 1, 1, Iif((n - 1) == 0, 1, (n - 1)) )
				//   M->ZZC_RETIRA := aCols[nPosicao][5]
				//Else
				n                 := nPosicao
				M->ZZC_RETIRA     := nQtdRet
				aCols[n][nPosQtR] := nQtdRet
				aCols[n][nPosVlR] := Iif(nQtdRet == 0, 0, Iif(nQtdRet == 999999, fCalVol(aCols[n][nPosPro], aCols[n][nPosQtI]), fCalVol(aCols[n][nPosPro], nQtdRet) ))
				//Endif
			Endif
		Endif
	ElseIf __ReadVar $ "M->ZZC_GAVETA"
		If aCols[n][nPosQtR] <= aCols[n][nPosQtI]
			M->ZZC_GAVETA     := StrZero(Val(Iif(Empty(M->ZZC_GAVETA), aCols[n][nPosGav], M->ZZC_GAVETA)), 3)
			aCols[n][nPosGav] := StrZero(Val(Iif(Empty(M->ZZC_GAVETA), aCols[n][nPosGav], M->ZZC_GAVETA)), 3)
		ElseIf aCols[n][nPosQtR] == 0 .or. aCols[n][nPosQtR] == 999999
			M->ZZC_GAVETA     := space(03)
			aCols[n][nPosGav] := space(03)
		Endif
		DbSelectArea("ZZC")
		DbGoTop()
		DbSetOrder(3)
		DbSeek(xFilial("ZZC")+SZF->ZF_CODIGO+aCols[n][nPosPro], .t.)
		If Found()
			While !Eof() .AND. (ZZC->ZZC_FILIAL == xFilial("ZZC")) .AND. ZZC->ZZC_BORDER == SZF->ZF_CODIGO .AND. ZZC->ZZC_PRODUT == aCols[n][nPosPro]
				If ZZC->ZZC_QUANTI <> ZZC->ZZC_RETIRA
					RecLock("ZZC", .f.)
					ZZC->ZZC_GAVETA := aCols[n][nPosGav]
					MsUnLock()
				Endif
				DbSelectArea("ZZC")
				DbSkip()
			Enddo
		Endif
	Endif
	oGetD:oBrowse:Refresh()
	DbSelectArea("ZZC")
Return(.t.)

/******************************************************************************************************************/
/*** fMonPed - Monta dados com os pedidos do produto que está sendo retirado                                    ***/
/***         u_FATA03_7 - Validação da tela de retirada de produtos por pedido                                  ***/
/***           fCalVol  - Calcula volume dos produtos no pedido                                                 ***/
/******************************************************************************************************************/
Static Function fMonPed(aHeaderA, aColsA, cBorder, cProdu, nQuant, aMatPed)
	Local nOpcB     := 0
	Local nOpcG     := 3
	Local aAltGet   := {"ZZC_RETIRA"}
	Local cLinOk    := 'AllwaysTrue()'
	Local cTudoOk   := 'AllwaysTrue()'
	Local cFieldOk  := "U_FATA03_7(aCols, aHeader, oGetE)"
	Local nQtdRet   := 0
	Local aBkpCol   := {}
	Local nY, nX
	Local _lOpen        := .F. // Adequação para release 12.1.25
	Local _cAliasSX3 := GetNextAlias() // Adequação para release 12.1.25
	Local cQry1     := ""
	Local cRETFAL   := GetMv("MV_RETFAL")
	Private aHeader := {}
	Private aCols   := {}
	Private nUsado  := 0

	// ABERTURA DO DICIONÁRIO SX3 - Adequação para release 12.1.25
	OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
	_lOpen := Select( _cAliasSX3 ) > 0

	If !_lOpen // Adequação para release 12.1.25
		MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
		Return
	Endif


	//Montagem do aHeader
	/* DESABILITADO RELEASE 12.1.25
       DbSelectArea("SX3")
       DbSetOrder(1)
       DbSeek("ZZC")
       While !Eof() .And. (X3_ARQUIVO == "ZZC")
             IF X3USO(X3_USADO) .And. cNivel >= X3_NIVEL
               If (TRIM(X3_CAMPO) $ "ZZC_PEDIDO") .OR. (TRIM(X3_CAMPO) $ "ZZC_QUANTI") .OR. (TRIM(X3_CAMPO) $ "ZZC_RETIRA")
                  nUsado += 1
                  AADD(aHeader, { Trim(X3_TITULO), X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )
               Endif
             Else
                If TRIM(X3_CAMPO) $ "ZZC_SEPARA"
                   AADD(aHeader, { Trim(''), X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )
                Endif
             EndIf
             dbSkip()
       Enddo
	*/

	DbSelectArea( _cAliasSX3 )
	( _cAliasSX3 )->( DbSetOrder(1) )
	( _cAliasSX3 )->( DbSeek("ZZC") )
	While !Eof() .and. ( _cAliasSX3 )->( X3_ARQUIVO ) == "ZZC"

		IF X3Uso( ( _cAliasSX3 )->( X3_USADO ) ) .and. cNivel >= ( _cAliasSX3 )->( X3_NIVEL )
			If (AllTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) ==  "ZZC_PEDIDO") .OR. (ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "ZZC_QUANTI") .OR. (ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "ZZC_RETIRA")
				nUsado += 1
				AADD(aHeader, { ( _cAliasSX3 )->(X3_TITULO), ( _cAliasSX3 )->(X3_CAMPO), ( _cAliasSX3 )->(X3_PICTURE), ( _cAliasSX3 )->(X3_TAMANHO), ( _cAliasSX3 )->(X3_DECIMAL), ( _cAliasSX3 )->(X3_VALID), ( _cAliasSX3 )->(X3_USADO), ( _cAliasSX3 )->(X3_TIPO), ( _cAliasSX3 )->(X3_ARQUIVO), ( _cAliasSX3 )->(X3_CONTEXT) } )
			Endif
		Else
			If AllTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "ZZC_SEPARA"
				AADD(aHeader, { Trim(''), ( _cAliasSX3 )->(X3_CAMPO), ( _cAliasSX3 )->(X3_PICTURE), ( _cAliasSX3 )->(X3_TAMANHO), ( _cAliasSX3 )->(X3_DECIMAL), ( _cAliasSX3 )->(X3_VALID), ( _cAliasSX3 )->(X3_USADO), ( _cAliasSX3 )->(X3_TIPO), ( _cAliasSX3 )->(X3_ARQUIVO), ( _cAliasSX3 )->(X3_CONTEXT) } )
			Endif
		EndIf
		dbSkip()
	EndDo


	DbSelectArea( _cAliasSX3 )
	DbCloseArea()


	If GetMv("MV_RETFAL") $ 'N'
		aHeader[aScan(aHeader, {|x| Alltrim(x[2]) == "ZZC_RETIRA"})][1] := "Qtd Faltante"
	Endif

	cQry1 := ""
	cQry1 += "SELECT ZZC.ZZC_PEDIDO AS PEDIDO, SUM(ZZC.ZZC_QUANTI) AS QUANTIDADE, SUM(ZZC.ZZC_RETIRA) AS RETIRA, ZZC.ZZC_GAVETA AS GAVETA, ZZC.ZZC_SEPARA AS SEPARA "
	cQry1 += "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
	cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON ZZC.ZZC_FILIAL = SB1.B1_FILIAL AND ZZC.ZZC_PRODUT = SB1.B1_COD AND SB1.D_E_L_E_T_ = '' "
	cQry1 += "WHERE ZZC.ZZC_FILIAL = '"+xFilial("ZZC")+"' "
	cQry1 += "  AND ZZC.D_E_L_E_T_ = '' "
	cQry1 += "  AND ZZC.ZZC_BORDER = '"+cBorder+"' "
	cQry1 += "  AND ZZC.ZZC_PRODUT = '"+cProdu+"' "
	cQry1 += "  AND (ZZC.ZZC_SEPARA <> 'S' AND (ZZC.ZZC_QUANTI <> ZZC.ZZC_RETIRA)) "
	cQry1 += "GROUP BY ZZC.ZZC_PEDIDO, ZZC.ZZC_GAVETA, ZZC.ZZC_SEPARA "
	cQry1 += "ORDER BY 1 "
	TCQuery cQry1 ALIAS "TCQ" NEW
	DbSelectArea("TCQ")
	While !Eof()
		If Empty(TCQ->SEPARA)
			xQtdRet := 999999
		Else
			If TCQ->SEPARA $ 'S'
				xQtdRet := 999999
			Else
				xQtdRet := TCQ->QUANTIDADE - TCQ->RETIRA
			Endif
		Endif
		aAdd(aCols, {TCQ->PEDIDO, TCQ->QUANTIDADE, xQtdRet, '',.f.})
		DbSelectArea("TCQ")
		DbSkip()
	Enddo
	DbSelectArea("TCQ")
	DbCloseArea()
	For nY := 1 To Len(aCols)
		aadd(aBkpCol, {aCols[nY][1], aCols[nY][2], aCols[nY][3]})
	Next

	DbSelectArea("ZZC")
	DEFINE MSDIALOG oDlgE TITLE OemToAnsi("Pedidos do Produto") From 9,0 to 20,50 of oMainWnd
	oGetE := MsGetDados():New( 15, 1, 80, 195, nOpcG, cLinOk, cTudoOk, "", .f., aAltGet, nOpcG, , Len(aCols), cFieldOk)
	ACTIVATE MSDIALOG oDlgE ON INIT EnchoiceBar(oDlgE, {|| nOpcB := 1, oDlgE:End() },{|| oDlgE:End() } ) CENTERED
	If nOpcB == 1
		nQtdRet := 0
		For nX := 1 To Len(aCols)
			//If GetMv("MV_RETFAL") $ 'S' desabilitado release 12.1.25
			If Alltrim(cRETFAL) == 'S'
				If aCols[nX][3] > 0
					If aScan(aMatPed, {|x| x[1] == aCols[nX][1]}) == 0
						aadd(aMatPed, {aCols[nX][1], cProdu, aCols[nX][3]})
					Else
						aMatPed[aScan(aMatPed, {|x| x[1] == aCols[nX][1]})][2] := aCols[nX][3]
					Endif
					DbSelectArea("ZZC")
					DbSetOrder(1)
					DbSeek(xFilial("ZZC")+cBorder+aCols[nX][1]+cProdu, .t.)
					If Found()
						RecLock("ZZC", .f.)
						ZZC->ZZC_RETIRA := aCols[nX][3]
						ZZC->ZZC_VOLRET := fCalVol(cProdu, aCols[nX][3])
						ZZC->ZZC_SEPARA := "S"
						ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
						MsUnLock()
					Endif
					nQtdRet += aCols[nX][3]
				ElseIf aCols[nX][3] == 0
					DbSelectArea("ZZC")
					DbSetOrder(1)
					DbSeek(xFilial("ZZC")+cBorder+aCols[nX][1]+cProdu, .t.)
					If Found()
						RecLock("ZZC", .f.)
						ZZC->ZZC_RETIRA := 0
						ZZC->ZZC_VOLRET := 0
						ZZC->ZZC_SEPARA := "N"
						ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
						MsUnLock()
					Endif
				Endif
			Else //Quantidade Faltante
				If aCols[nX][3] == 0 .or. aCols[nX][3] == 999999
					DbSelectArea("ZZC")
					DbSetOrder(1)
					DbSeek(xFilial("ZZC")+cBorder+aCols[nX][1]+cProdu, .t.)
					If Found()
						RecLock("ZZC", .f.)
						//nDifer := ZZC->ZZC_QUANTI - ZZC->ZZC_RETIRA
						ZZC->ZZC_RETIRA := 0
						ZZC->ZZC_VOLRET := 0
						ZZC->ZZC_SEPARA := ""
						ZZC->ZZC_GAVETA := ""
						ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
						DbSelectArea("ZZC")
						MsUnLock()
					Endif
					//nQtdRet := aCols[nX][3]
				ElseIf aCols[nX][3] > 0 .and. aCols[nX][3] <= aCols[nX][2]
					DbSelectArea("ZZC")
					DbSetOrder(1)
					DbSeek(xFilial("ZZC")+cBorder+aCols[nX][1]+cProdu, .t.)
					If Found()
						RecLock("ZZC", .f.)
						ZZC->ZZC_RETIRA := aCols[nX][2] - aCols[nX][3]
						ZZC->ZZC_VOLRET := Iif((aCols[nX][2] - aCols[nX][3]) == 0, 0, fCalVol(cProdu, (aCols[nX][2] - aCols[nX][3])))
						ZZC->ZZC_SEPARA := "N"
						ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
						DbSelectArea("ZZC")
						MsUnLock()
						nQtdRet += aCols[nX][3]
					Endif
				Endif
			Endif
		Next
		//If nQtdRet == 0 //Quando o valor for 0 deletar o item do aColsA pois td foi retirado.
		//   aSize(aDel(aColsA, aScan(aColsA, {|x| Alltrim(x[1]) == Alltrim(cProdu) })), Len(aColsA)-1)
		//Endif
	Else
		For nY := 1 To Len(aBkpCol)
			//If GetMv("MV_RETFAL") $ 'S' desabilitado release 12.1.25
			If Alltrim(cRETFAL) =='S'
				nQtdRet += aBkpCol[nY][3]
			Else
				If aBkpCol[nY][3] <> 999999
					nQtdRet += aBkpCol[nY][3]
				Endif
			Endif
		Next
	Endif
	aHeader := aHeaderA
	aCols   := aColsA
Return(nQtdRet)

/******************************************************************************************************************/
/*** FATA03_7 - Validação da retirada de produtos por pedido.                                                   ***/
/******************************************************************************************************************/
User Function FATA03_7(aCols, aHeader, oGetE)
	//Local nPosPed := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZC_PEDIDO" } ) //Numero do Pedido
	Local nPosQtI := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZC_QUANTI" } ) //Quantidade do Item
	//Local nPosQtR := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZC_RETIRA" } ) //Quantidade Retirada

	If oGetE == Nil
		oDlg := GetWndDefault()
		oDlg := oGetE:oWnd
	Endif

	If __ReadVar $ "M->ZZC_RETIRA"
		If M->ZZC_RETIRA > aCols[n][nPosQtI] .and. !M->ZZC_RETIRA == 999999
			ApMsgStop("Atenção, quantidade retirada não pode ser maior que a quantidade solicitada")
			Return(.f.)
		ElseIf M->ZZC_RETIRA == 0 .or. M->ZZC_RETIRA == 999999
			M->ZZC_RETIRA := 999999
			aCols[n][3]   := 999999
		Endif
	Endif
Return(.t.)

/******************************************************************************************************************/
/*** fCalVol - Calcula volume dos produtos no pedido                                                            ***/
/******************************************************************************************************************/
Static Function fCalVol(cProduto, nQuantid)
	Local nQtdeVol := 0

	/**
** Cleber (05/03/10) -> Retirado gravação de volume por item pois um pedido pode juntar volumes, etc..
	*/
Return(nQtdeVol)

/******************************************************************************************************************/
/*** FATA03_8 - Montagem de Bordero de despacho.                                                                ***/
/***            fMarCar - Marca e desmarca Cargas                                                               ***/
/***            fNewBor - Grava um novo bordero de despacho                                                     ***/
/***            fBorJaE - Grava em um bordero já existente                                                      ***/
/***            fTroPed - Ajusta observação na troca dos pedidos                                                ***/
/******************************************************************************************************************/
User Function FATA03_8()
	Local cDrvArq := ""
	//Local cTrbArq := ""
	//Local cPatArq := "\DADOSADV\"
	Local aStrArq := {}
	Local cQry1   := ""
	Local aMatDad := {}
	Local aMatReg := {}
	Local aHeaCar := {}
	Local cCarga  := ""
	Local aCarga  := {}
	Local cObsMsg := ""
	Local nX, nY
	Local cREGTRA := GETMV("MV_REGTRA")
	Private hOK   := LoadBitmap( GetResources(), "LBTIK" )
	Private hNo   := LoadBitmap( GetResources(), "LBNO" )
	Private oTempTbl8
	If !SZF->ZF_FLAG $ 'Y'
		MsgBox("Somente borderos parcialmente ou totalmente retirados podem ter a carga montada.", "Atenção...", "STOP")
		Return
	Endif
	#IFDEF WNTX
		cDrvArq := "DBFNTX"
	#ENDIF
	#IFDEF WCDX
		cDrvArq := "DBFCDX"
	#ENDIF
	#IFDEF WASX
		cDrvArq := "DBFCDXAX"
	#ENDIF
	#IFDEF WCODEBASE
		cDrvArq := "DBFCDXTTS"
	#ENDIF

	If ChkFile("CAR")
		DbSelectArea("CAR")
		DbCloseArea()
	Endif
	aStrArq := {}
	aadd(aStrArq, {"CAR_FLAG"  , "C", 02, 0}) //Flag de marcação
	aadd(aStrArq, {"CAR_REGIAO", "C", 06, 0}) //Região
	aadd(aStrArq, {"CAR_PEDIDO", "C", 06, 0}) //Pedido
	aadd(aStrArq, {"CAR_CLIENT", "C", 50, 0}) //Cliente
	aadd(aStrArq, {"CAR_VOLUME", "N", 06, 0}) //Quantidade do Produto
	aadd(aStrArq, {"CAR_LOCALI", "C", 09, 0}) //Localização
	aadd(aStrArq, {"CAR_PERSEP", "N", 06, 0}) //Gaveta na expedição
	aadd(aStrArq, {"CAR_ORDEMA", "C", 08, 0}) //Ordem do Arquivo


	/********************************************************************************************************************************/
	/*** BLOCO ALTERADO EM 28/10/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/

	/*  cTrbArq := CriaTrab(aStrArq, .t.)
     DbUseArea(.t., cDrvArq, cTrbArq, "CAR", Iif(.f. .or. .t., !.t., Nil), .f.)
     cKey01  := "CAR_ORDEMA"
     cInd01  := SubStr(cTrbArq, 1, 10)+"_1"
     DbCreateIndex(cInd01, cKey01, {||cKey01} )
	*/
	//cTrbArq := U_NovoArqTrab("dbf")
	//dbcreate(cTrbArq+".dbf", aStrArq, "DBFCDXADS")
	//Use (cTrbArq+".Dbf") Alias "CAR" VIA "DBFCDXADS" New
	//cKey01  := "CAR_ORDEMA"
	//cInd01  := cTrbArq+"_1"
	//DbCreateIndex(cInd01+".cdx", cKey01, {||cKey01} )

	//DbClearIndex()
	//DbSetIndex(cInd01)
	//DbSetOrder(1)
	oTempTbl8 := FWTemporaryTable():New( 'CAR' )
	oTempTbl8:SetFields( aStrArq )
	oTempTbl8:AddIndex( "cInd01", { "CAR_ORDEMA" } )
	oTempTbl8:Create()
	/********************************************************************************************************************************/

	aadd(aHeaCAR, {"CAR_FLAG"  , "", OemToAnsi(""       )    , ""          } )
	aadd(aHeaCAR, {"CAR_PEDIDO", "", OemToAnsi("Pedido" )    , "999999"    } )
	aadd(aHeaCAR, {"CAR_CLIENT", "", OemToAnsi("Cliente")    , ""          } )
	aadd(aHeaCAR, {"CAR_VOLUME", "", OemToAnsi("Volume" )    , "@E 999999" } )
	aadd(aHeaCAR, {"CAR_LOCALI", "", OemToAnsi("Localização"), ""          } )
	aadd(aHeaCAR, {"CAR_PERSEP", "", OemToAnsi("% Sep." )    , "@E 999.99" } )

	cQry1 += "SELECT ZZC.ZZC_BORDER, ZZC.ZZC_CARGA, ZZC.ZZC_PEDIDO, ZZC.ZZC_SEPARA, SUM(ZZC.ZZC_VOLUME) AS QTDE "
	cQry1 += "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
	cQry1 += "WHERE ZZC.ZZC_FILIAL = '"+xFilial("ZZC")+"' "
	cQry1 += "  AND D_E_L_E_T_ = '' "
	cQry1 += "  AND ZZC.ZZC_BORDER = '"+SZF->ZF_CODIGO+"' "
	cQry1 += "  AND ZZC.ZZC_CARGA  = '' "
	cQry1 += "GROUP BY ZZC.ZZC_BORDER, ZZC.ZZC_CARGA, ZZC.ZZC_PEDIDO, ZZC.ZZC_SEPARA "
	cQry1 += "ORDER BY ZZC.ZZC_PEDIDO, ZZC.ZZC_SEPARA "
	TCQuery cQry1 ALIAS "TCQ" NEW
	DbSelectArea("TCQ")
	DbGoTop()
	While !Eof()
		nPosDad := aScan(aMatDad, {|x| x[1] == TCQ->ZZC_PEDIDO})
		If nPosDad == 0                                                      // +>> 13 - Volume do Pedido
			aadd(aMatDad, {' ', ' ', ' ', ' ', ' ', ' ', 0, 0, 0, ' ', ' ', ' ', 0})
			//              |    |    |    |    |    |   |  |  |   |    |    +--->>> 12 - Endereço na Expedição
			//              |    |    |    |    |    |   |  |  |   |    +-------->>> 11 -
			//              |    |    |    |    |    |   |  |  |   +------------->>> 10 - Região (Passou a ser transportadora)
			//              |    |    |    |    |    |   |  |  +----------------->>> 09 - Quantidade TOTAL
			//              |    |    |    |    |    |   |  +-------------------->>> 08 - Quantidade não separada
			//              |    |    |    |    |    |   +----------------------->>> 07 - Quantidade já separada
			//              |    |    |    |    |    +--------------------------->>> 06 - Região (Passou a ser transportadora)
			//              |    |    |    |    +-------------------------------->>> 05 - Código da Cidade do Cliente
			//              |    |    |    +------------------------------------->>> 04 - Nome do Cliente
			//              |    |    +------------------------------------------>>> 03 - Loja do Cliente
			//              |    +----------------------------------------------->>> 02 - Código do Cliente
			//              +---------------------------------------------------->>> 01 - Numero do Pedido

			aMatDad[Len(aMatDad)][01] := TCQ->ZZC_PEDIDO                                                                                      //Pedido
			aMatDad[Len(aMatDad)][02] := Posicione("SC5", 1, xFilial("SC5")+aMatDad[Len(aMatDad)][01], "C5_CLIENTE")                          //Cliente
			aMatDad[Len(aMatDad)][03] := Posicione("SC5", 1, xFilial("SC5")+aMatDad[Len(aMatDad)][01], "C5_LOJACLI")                          //Loja Cliente
			aMatDad[Len(aMatDad)][04] := Posicione("SA1", 1, xFilial("SA1")+aMatDad[Len(aMatDad)][02]+aMatDad[Len(aMatDad)][03], "A1_NOME")   //Razão Social
			aMatDad[Len(aMatDad)][05] := Posicione("SA1", 1, xFilial("SA1")+aMatDad[Len(aMatDad)][02]+aMatDad[Len(aMatDad)][03], "A1_CODCID") //Código da Cidade
			//If GETMV("MV_REGTRA") $ 'R' desabilitado release 12.1.25
			If Alltrim(cREGTRA) == 'R'
				aMatDad[Len(aMatDad)][06] := Posicione("SZ7", 1, xFilial("SZ7")+aMatDad[Len(aMatDad)][05], "Z7_REGIAO")                        //Código da Região (Transportadora)
			Else
				aMatDad[Len(aMatDad)][06] := Posicione("SC5", 1, xFilial("SC5")+aMatDad[Len(aMatDad)][01], "C5_TRANSP")                        //Código da Região (Transportadora)
			Endif
			aMatDad[Len(aMatDad)][12] := Posicione("SZG", 2, xFilial("SZG")+'01'+aMatDad[Len(aMatDad)][01], "ZG_LOCALIZ")                     //Endereço na Expedição
			If TCQ->ZZC_SEPARA $ 'S'
				aMatDad[Len(aMatDad)][07] := TCQ->QTDE
			Else
				aMatDad[Len(aMatDad)][08] := TCQ->QTDE
			Endif
			aMatDad[Len(aMatDad)][09] += TCQ->QTDE
			aMatDad[Len(aMatDad)][10] := aMatDad[Len(aMatDad)][06]
			aMatDad[Len(aMatDad)][13] := Posicione("SC5", 1, xFilial("SC5")+aMatDad[Len(aMatDad)][01], "C5_VOLUME1")
			nPosReg := aScan(aMatReg, aMatDad[Len(aMatDad)][06] )
			If nPosReg == 0
				aadd(aMatReg, aMatDad[Len(aMatDad)][06])
			Endif
		Else
			If TCQ->ZZC_SEPARA $ 'S'
				aMatDad[nPosDad][07] += TCQ->QTDE
			Else
				aMatDad[nPosDad][08] += TCQ->QTDE
			Endif
			aMatDad[nPosDad][09] += TCQ->QTDE
		Endif
		DbSelectArea("TCQ")
		DbSkip()
	Enddo
	aSort(aMatReg)
	DbSelectArea("TCQ")
	DbCloseArea()

	For nY := 1 To Len(aMatReg)
		aMatImp := {}
		For nX := 1 To Len(aMatDad)
			If aMatDad[nX][06] == aMatReg[nY]
				aadd(aMatImp, {aMatDad[nX][01], aMatDad[nX][02], aMatDad[nX][03], aMatDad[nX][04], aMatDad[nX][05], aMatDad[nX][06], aMatDad[nX][07], aMatDad[nX][08], aMatDad[nX][09], aMatDad[nX][10], aMatDad[nX][11], aMatDad[nX][12], (Iif(aMatDad[nX][09] == 0, 0, aMatDad[nX][07] / aMatDad[nX][09]) * 100), '', aMatDad[nX][13] })
			Endif
		Next
		aSort(aMatImp,,,{|x,y| x[13] > y[13]})
		For nX := 1 To Len(aMatImp)
			aMatImp[nX][14] := aMatImp[nX][10]+StrZero(nX, 3)//StrZero(aMatImp[nX][13], 3)
		Next
		RecLock("CAR", .t.)
		CAR->CAR_FLAG   := '  '
		CAR->CAR_REGIAO := aMatReg[nY]
		CAR->CAR_PEDIDO := ''
		//CAR->CAR_CLIENT := aMatReg[nY]+' - '+Iif(GETMV("MV_REGTRA") $ 'R', Alltrim(Posicione("SX5", 1, xFilial("SX5")+'98'+aMatReg[nY], "X5_DESCRI")), Alltrim(Posicione("SA4", 1, xFilial("SA4")+aMatReg[nY], "A4_NOME")) ) release 12.1.25
		CAR->CAR_CLIENT := aMatReg[nY]+' - '+Iif(Alltrim(cREGTRA) == 'R', Alltrim(Posicione("SX5", 1, xFilial("SX5")+'98'+aMatReg[nY], "X5_DESCRI")), Alltrim(Posicione("SA4", 1, xFilial("SA4")+aMatReg[nY], "A4_NOME")) )
		CAR->CAR_VOLUME := 0
		CAR->CAR_LOCALI := ''
		CAR->CAR_PERSEP := 0
		CAR->CAR_ORDEMA := aMatReg[nY]+'000'
		MsUnLock()
		For nX := 1 To Len(aMatImp)
			RecLock("CAR", .t.)
			CAR->CAR_FLAG   := '  '
			CAR->CAR_REGIAO := aMatImp[nX][06]
			CAR->CAR_PEDIDO := aMatImp[nX][01]
			CAR->CAR_CLIENT := aMatImp[nX][02]+'/'+aMatImp[nX][03]+' - '+aMatImp[nX][04]
			CAR->CAR_VOLUME := aMatImp[nX][15]
			CAR->CAR_LOCALI := aMatImp[nX][12]
			CAR->CAR_PERSEP := aMatImp[nX][13]
			CAR->CAR_ORDEMA := aMatImp[nX][14]
			MsUnLock()
		Next
	Next
	DbSelectArea("CAR")
	DbGoTop()
	While !Eof()
		aadd(aCarga, {.f., CAR->CAR_PEDIDO, CAR->CAR_CLIENT, CAR->CAR_VOLUME, CAR->CAR_LOCALI, CAR->CAR_PERSEP, CAR->CAR_REGIAO, CAR->CAR_ORDEMA })
		DbSelectArea("CAR")
		DBSkip()
	Enddo
	If Len(aCarga) <= 0
		MsgBox("Não existem pedidos para serem separados em cargas!", "Atenção", "STOP")
		Return
	Endif
	DEFINE MSDIALOG oDlg FROM 000,000 TO 032,100 TITLE OemToAnsi("Montagem do Bordero de Depacho") OF oMainWnd
	DEFINE FONT oFont1 NAME 'COURIER NEW' SIZE 6,0
	@ 020,003 LISTBOX oCarga VAR cCarga FIELDS HEADER '',"Pedido", "Cliente", "Volume", "Localização", "% Separado" ON DBLCLICK (fMarCar()) SIZE 390,160 OF oDlg PIXEL
	@ 186,001 GROUP oGrp9 TO 241,395 LABEL  OemToAnsi('QTDE.   PRODUTOS                 DESCRIÇÃO                                               EMBALAGEM            QUADRANTE         OPs.      ') OF oDlg PIXEL //FONT oFont1
	@ 191,003 GET oObsMsg VAR cObsMsg MEMO READONLY SIZE 390,045                                                                                    OF oDlg PIXEL FONT oFont1

	oCarga:SetArray(aCarga)
	oCarga:bLine := { || { Iif(aCarga[oCarga:nAt][1], hOk, hNo), aCarga[oCarga:nAt][2], aCarga[oCarga:nAt][3], aCarga[oCarga:nAt][4], aCarga[oCarga:nAt][5], aCarga[oCarga:nAt][6] }}
	oCarga:bChange := { || fTroPed(@cObsMsg)}

	@ 001,001 GROUP oGrp1 TO 020,071 LABEL OemToAnsi('')    COLOR CLR_HRED             PIXEL OF oDlg
	@ 10,008 BTNBMP oBtnNov RESOURCE "EDITABLE"        SIZE 127,24 ACTION(fNewBor()) PIXEL OF oDlg

	@ 001,175 GROUP oGrp3 TO 020,245 LABEL OemToAnsi('')    COLOR CLR_HRED             PIXEL OF oDlg
	@ 10,357 BTNBMP oBtnAdc RESOURCE "BPMSDOCI"        SIZE 127,24 ACTION(fBorJaE()) PIXEL OF oDlg

	@ 001,325 GROUP oGrp2 TO 020,395 LABEL OemToAnsi('')    COLOR CLR_HRED             PIXEL OF oDlg
	@ 10,657 BTNBMP oBtnCan RESOURCE "CANCEL"          SIZE 127,24 ACTION(nOpca := 0, oDlg:End()) PIXEL OF oDlg

	oBtnNov:cCaption := PADR(OemToAnsi("Novo Bordero"), 20)
	oBtnNov:cToolTip := OemToAnsi("Adiciona um novo bordero...")
	oBtnAdc:cCaption := PADR(OemToAnsi("Bordero Existente"), 20)
	oBtnAdc:cToolTip := OemToAnsi("Adiciona em bordero já existente...")
	oBtnCan:cCaption := PADR(OemToAnsi("Sair Retirada"), 20)
	oBtnCan:cToolTip := OemToAnsi("Sai da retirada sem atualizar...")
	oDlg:nStyle    := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
	ACTIVATE MSDIALOG oDlg CENTERED
	oTempTbl8:Delete()
Return

/******************************************************************************************************************/
/*** fMarCar - Marca e desmarca Cargas                                                                          ***/
/******************************************************************************************************************/
Static Function fMarCar()
	Local nX
	If !Empty(oCarga:aArray[oCarga:nAt][2])
		oCarga:aArray[oCarga:nAt][1] := !oCarga:aArray[oCarga:nAt][1]
	Else
		nPos := oCarga:nAt
		For nX := 1 To Len(oCarga:aArray)
			If nX <> nPos .and. oCarga:aArray[nX][7] == oCarga:aArray[nPos][7]
				oCarga:aArray[nX][1] := !oCarga:aArray[nX][1]
			Endif
		Next
	Endif
	oCarga:Refresh()
Return

/******************************************************************************************************************/
/*** fTroPed - Ajusta observação na troca dos pedidos                                                           ***/
/******************************************************************************************************************/
Static Function fTroPed(cObsMsg)
	cObsMsg := ""
	nQtdPro := 0
	DbSelectArea("ZZC")
	If !Empty(oCarga:aArray[oCarga:nAt][2])
		DbSelectArea("ZZC")
		DbSetOrder(1)
		DbSeek(xFilial("ZZC")+SZF->ZF_CODIGO+oCarga:aArray[oCarga:nAt][2], .t.)
		If Found()
			While !Eof() .and. (ZZC->ZZC_FILIAL == xFilial("ZZC")) .and. ZZC->ZZC_BORDER == SZF->ZF_CODIGO .and. ZZC->ZZC_PEDIDO == oCarga:aArray[oCarga:nAt][2]
				If ZZC->ZZC_SEPARA <> 'S'
					//                  1         2         3         4         5         6         7         8         9         10
					//         1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
					//         99999  XX 99.99.999-99 - *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX    99999  XXXXXXXXX
					cEstoque := Iif(Posicione("SB1", 1, xFilial("SB1")+ZZC->ZZC_PRODUT, "B1_ESTOQUE") == 'S', "*", " ")
					cObsMsg += Transform(Iif(ZZC->ZZC_SEPARA <> 'S', ZZC->ZZC_QUANTI - ZZC->ZZC_RETIRA, ZZC->ZZC_QUANTI), "@E 99999")+'  '+Transform(ZZC->ZZC_PRODUT, "@R XX 99.99.999-XX")+' - '+cEstoque+SubStr(Posicione("SB1", 1, xFilial("SB1")+ZZC->ZZC_PRODUT, "B1_DESC"), 1, 30)+'  '+SubStr(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(ZZC->ZZC_PRODUT, 11, 2), "Z5_DESCR"), 1, 15)+'  '+SubStr(Posicione("SB2", 1, xFilial("SB2")+ZZC->ZZC_PRODUT+Posicione("SB1", 1, xFilial("SB1")+ZZC->ZZC_PRODUT, "B1_LOCPAD"), "B2_LOCALIZ"), 1, 15)+'  '+Transform(nQtdPro, "@E 99999")+CHR(13)+CHR(10)
				Endif
				DbSelectArea("ZZC")
				DbSkip()
			Enddo
		Endif
	Endif
	oObsMsg:SetText(cObsMsg)
	oObsMsg:Refresh()
Return

/******************************************************************************************************************/
/*** fNewBor - Grava um novo bordero de despacho                                                                ***/
/******************************************************************************************************************/
Static Function fNewBor()
	Local aMatReg := {}
	Local aRet    := {}
	Local nY, nX, nA, nB
	//1º) Verificar quais regiões que possuen cargas marcadas e gravar na matriz aMatReg
	For nY := 1 To Len(oCarga:aArray)
		If oCarga:aArray[nY][1]
			If aScan(aMatReg, {|x| x[1] == oCarga:aArray[nY][7]}) == 0
				aadd(aMatReg, {oCarga:aArray[nY][7]})
			Endif
		Endif
	Next
	If Len(aMatReg) > 0
		//2º) Separar por região para montar as novas cargas
		For nA := 1 To Len(aMatReg)
			//Monta aCols por região
			aCols := {}
			For nX := 1 to Len(oCarga:aArray)
				If oCarga:aArray[nX][1] .and. oCarga:aArray[nX][7] == aMatReg[nA][1]
					aAdd(aCols, {'01'+oCarga:aArray[nX][2], SubStr(oCarga:aArray[nX][3], 13), .f.})
				Endif
			Next
			//Atualiza variáveis da tela de cargas
			nTotPes := 0 ; nTotVol := 0
			For nX := 1 To Len(aCols)
				nTotPes += Posicione("SC5", 1, xFilial("SC5")+SubStr(aCols[nX][1], 3, 6), "C5_PBRUTO")
				nTotVol += Posicione("SC5", 1, xFilial("SC5")+SubStr(aCols[nX][1], 3, 6), "C5_VOLUME1")
			Next
			//Chama função para montagem da carga da região
			aRet := U_FATA01_1("I", aCols, nTotPes, nTotVol, aMatReg[nA][1]) //CHAMADA DA INCLUSÃO DE UM NOVO BORDERO DE DESPACHO

			If Len(aRet) > 0 //DELETAR ITENS DA TELA DE BORDEROS
				//Tirar da Matriz aArray por Pedido
				For nB := 1 To Len(aRet)
					nPosPri := aScan(oCarga:aArray, {|x| Alltrim(x[2]) == Alltrim(SubStr(aRet[nB][1], 3, 6))})
					If nPosPri > 0
						aSize(aDel(oCarga:aArray, nPosPri), Len(oCarga:aArray) - 1)
					Endif
				Next
				//Verificar se todos os itens da região foi retirado, caso afirmativo, retirar a Região da tela
				lAinExi := .f.
				For nB := 1 To Len(oCarga:aArray)
					If !Empty(oCarga:aArray[nB][2]) .and. Alltrim(oCarga:aArray[nB][7]) == Alltrim(aMatReg[nA][1])
						lAinExi := .t.
					ElseIf Empty(oCarga:aArray[nB][2]) .and. Alltrim(oCarga:aArray[nB][7]) == Alltrim(aMatReg[nA][1])
						nPosReg := nB
					Endif
				Next
				If !lAinExi
					If nPosReg > 0
						aSize(aDel(oCarga:aArray, nPosReg), Len(oCarga:aArray) - 1)
					Endif
					lAinExi := .f.
				Endif
			Endif
		Next
	Else
		MsgBox("Não havia nenhum pedido marcardo para geração de uma nova carga.", "Atenção", "STOP")
	Endif
	oCarga:Refresh()
Return

/******************************************************************************************************************/
/*** fBorJaE - Grava em um bordero já existente                                                                 ***/
/***           fMarBor - Marca bordero já existente para inclusão de novos pedidos                              ***/
/***           fAddBor - Adiciona pedidos marcados no bordero existente                                         ***/
/******************************************************************************************************************/
Static Function fBorJaE()
	Local aMatReg := {}
	Local aCarMon := {}
	Local nY
	Local cQry1   := ""
	//1º) Verificar se existe pedidos marcados por região
	For nY := 1 To Len(oCarga:aArray)
		If oCarga:aArray[nY][1]
			If aScan(aMatReg, {|x| x[1] == oCarga:aArray[nY][7]}) == 0
				aadd(aMatReg, {oCarga:aArray[nY][7]})
			Endif
		Endif
	Next
	If Len(aMatReg) > 0
		cQry1 := ""
		cQry1 += "SELECT SZA.ZA_CODIGO, SUBSTRING(SZA.ZA_EMISSAO, 7, 2)+'/'+SUBSTRING(SZA.ZA_EMISSAO, 5, 2)+'/'+SUBSTRING(SZA.ZA_EMISSAO, 1, 4) AS ZA_EMISSAO, SUBSTRING(SZA.ZA_PREVDSP, 7, 2)+'/'+SUBSTRING(SZA.ZA_PREVDSP, 5, 2)+'/'+SUBSTRING(SZA.ZA_PREVDSP, 1, 4) AS ZA_PREVDSP, SZA.ZA_REGIAO+' - '+SZA.ZA_DESCR AS ZA_REGIAO, SZA.ZA_PESO, SZA.ZA_VOLUME "
		cQry1 += "FROM "+RetSqlName("SZA")+" SZA WITH (NOLOCK) "
		cQry1 += "WHERE SZA.ZA_FILIAL  = '"+xFilial("SZA")+"' "
		cQry1 += "  AND SZA.D_E_L_E_T_ = '' "
		cQry1 += "  AND SZA.ZA_DTDESPA = '' "
		cQry1 += "ORDER BY SZA.ZA_PREVDSP, SZA.ZA_REGIAO "
		TCQuery cQry1 ALIAS "PRE" NEW
		DbSelectArea("PRE")
		While !Eof()
			aAdd(aCarMon, {.F., PRE->ZA_CODIGO, CTOD(PRE->ZA_EMISSAO), CTOD(PRE->ZA_PREVDSP), PRE->ZA_REGIAO, PRE->ZA_PESO, PRE->ZA_VOLUME})
			DbSelectArea("PRE")
			DbSkip()
		Enddo
		DbSelectArea("PRE")
		DbCloseArea()

		DEFINE MSDIALOG oDlgM FROM 000,000 TO 020,070 TITLE OemToAnsi("Adicionar pedidos em bordero já existente") OF oMainWnd
		@ 020,005 LISTBOX oCarMon VAR cCarMon FIELDS HEADER '',"Bordero", "Emissão", "Previsão", "Região", "Peso", "Volume" ON DBLCLICK (fMarBor()) SIZE 270,130 OF oDlgM PIXEL
		oCarMon:SetArray(aCarMon)
		oCarMon:bLine:= { || { Iif(aCarMon[oCarMon:nAt][1], hOk, hNo), aCarMon[oCarMon:nAt][2], aCarMon[oCarMon:nAt][3], aCarMon[oCarMon:nAt][4], aCarMon[oCarMon:nAt][5], aCarMon[oCarMon:nAt][6], aCarMon[oCarMon:nAt][7] }}

		@ 001,005 GROUP oGrp1 TO 020,075 LABEL OemToAnsi('')    COLOR CLR_HRED             PIXEL OF oDlgM
		@ 10,015 BTNBMP oBtnNov RESOURCE "BPMSDOCI"        SIZE 127,24 ACTION(fAddBor()) PIXEL OF oDlgM

		@ 001,205 GROUP oGrp2 TO 020,275 LABEL OemToAnsi('')    COLOR CLR_HRED             PIXEL OF oDlgM
		@ 10,415 BTNBMP oBtnCan RESOURCE "CANCEL"          SIZE 127,24 ACTION(nOpca := 0, oDlgM:End()) PIXEL OF oDlgM

		oBtnNov:cCaption := PADR(OemToAnsi("Inclui no Bordero"), 20)
		oBtnNov:cToolTip := OemToAnsi("Adiciona pedidos no bordero...")
		oBtnCan:cCaption := PADR(OemToAnsi("Sair Retirada"), 20)
		oBtnCan:cToolTip := OemToAnsi("Sai da retirada sem atualizar...")
		ACTIVATE MSDIALOG oDlgM CENTERED
	Else
		MsgBox("Não havia nenhum pedido marcardo para inclusão em uma carga.", "Atenção", "STOP")
	Endif
Return

/******************************************************************************************************************/
/*** fMarBor - Marca bordero já existente para inclusão de novos pedidos                                        ***/
/******************************************************************************************************************/
Static Function fMarBor()
	Local nB
	For nB := 1 To Len(oCarMon:aArray)
		If nB <> oCarMon:nAt
			oCarMon:aArray[nB][1] := .f.
		Endif
	Next
	oCarMon:aArray[oCarMon:nAt][1] := !oCarMon:aArray[oCarMon:nAt][1]
	oCarMon:Refresh()
	oBtnNov:SetFocus()
Return

/******************************************************************************************************************/
/*** fAddBor - Adiciona pedidos marcados no bordero existente                                                   ***/
/******************************************************************************************************************/
Static Function fAddBor()
	Local nPosCar := 0
	Local nB, nA
	For nB := 1 To Len(oCarMon:aArray)
		If oCarMon:aArray[nB][1]
			nPosCar := nB
		Endif
	Next
	If nPosCar == 0
		MsgBox("Carga não selecionada.", "Atenção", "ALERT")
		Return
	Endif
	//1º) Adicionar na tabela SZB (Pedidos x Carga).
	aPedCar := {}
	For nB := 1 To Len(oCarga:aArray)
		If oCarga:aArray[nB][1] .and. !Empty(oCarga:aArray[nB][2])
			aAdd(aPedCar, {oCarga:aArray[nB][2], oCarga:aArray[nB][7]})
		Endif
	Next
	nTotPes := 0
	nTotVol := 0
	For nB := 1 To Len(aPedCar)
		RecLock("SZB", .t.)
		SZB->ZB_FILIAL := xFilial("SZB")
		SZB->ZB_CODIGO := oCarMon:aArray[nPosCar][2]
		SZB->ZB_PEDIDO := '01'+aPedCar[nB][1]
		SZB->ZB_RAZAO  := Posicione("SA1", 1, xFilial("SA1")+Posicione("SC5", 1, xFilial("SC5")+aPedCar[nB][1], "C5_CLIENTE"), "A1_NOME")
		MsUnLock()
		DbSelectArea("ZZC")
		DbSetOrder(2)
		DbSeek(xFilial("ZZC")+aPedCar[nB][1], .t.)
		If Found()
			While !Eof() .and. ZZC->ZZC_FILIAL == xFilial("ZZC") .AND. ZZC->ZZC_PEDIDO == aPedCar[nB][1]
				RecLock("ZZC", .F.)
				ZZC->ZZC_CARGA := oCarMon:aArray[nPosCar][2]
				MsUnLock()
				DbSelectArea("ZZC")
				DbSkip()
			Enddo
		Endif
		nTotPes += Posicione("SC5", 1, xFilial("SC5")+aPedCar[nB][1], "C5_PBRUTO")
		nTotVol += Posicione("SC5", 1, xFilial("SC5")+aPedCar[nB][1], "C5_VOLUME1")
	Next
	DbSelectArea("SZA")
	DbSetOrder(1)
	DbSeek(xFilial("SZA")+oCarMon:aArray[nPosCar][2], .t.)
	If Found()
		RecLock("SZA", .f.)
		SZA->ZA_PESO   += nTotPes
		SZA->ZA_VOLUME += nTotVol
		MsUnLock()
	Endif

	//2º) Apagar pedidos da Matriz aCarga, que contém todos os pedidos.
	For nB := 1 To Len(aPedCar)
		nPosPri := aScan(oCarga:aArray, {|x| Alltrim(x[2]) == Alltrim(aPedCar[nB][1])})
		If nPosPri > 0
			aSize(aDel(oCarga:aArray, nPosPri), Len(oCarga:aArray) - 1)
		Endif
	Next
	For nA := 1 To Len(aPedCar)
		//Verificar se todos os itens da região foi retirado, caso afirmativo, retirar a Região da tela
		lAinExi := .f.
		For nB := 1 To Len(oCarga:aArray)
			If !Empty(oCarga:aArray[nB][2]) .and. Alltrim(oCarga:aArray[nB][7]) == Alltrim(aPedCar[nA][2])
				lAinExi := .t.
			ElseIf Empty(oCarga:aArray[nB][2]) .and. Alltrim(oCarga:aArray[nB][7]) == Alltrim(aPedCar[nA][2])
				nPosReg := nB
			Endif
		Next
		If !lAinExi
			If nPosReg > 0
				aSize(aDel(oCarga:aArray, nPosReg), Len(oCarga:aArray) - 1)
			Endif
		Endif
	Next
	oCarga:Refresh()
	oDlgM:End()
Return

/******************************************************************************************************************/
/*** FATA03_9 - Mostra a legenda com cores correspondentes.                                                     ***/
/******************************************************************************************************************/
User Function FATA03_9()
	Local cCadastro := OemToAnsi('Bordero de Pedidos')
	BrwLegenda(cCadastro, "Status",{ {"ENABLE"     ,"Digitado"               	 	} ,;
		{"BR_MARRON"  ,"Comple. Bipe na Rampa"  	 	} ,;
		{"BR_LARANJA" ,"Totalmente Destinado"      	} ,;
		{"BR_BRANCO"  ,"Totalmente Destinado e Bipado"} })

	//{"BR_AMARELO" ,"Endereçado"             	 } ,;
	//{"BR_AZUL"    ,"Parcialmente Separado"  	 } ,;
	//{"DISABLE"    ,"Totalmente Separado"    	 } ,;
	//{"BR_PRETO"   ,"Totalmente Destinado"   	 } ,;

Return(.t.)

/**************************** FUNÇÕES NÃO MAIS UTILIZADAS. ***/
/*
Static Function fBaiFin()
       Local oDlgF, oFont1, oNumOrd, oNumLot, oCodOrd, oDesOrd, oCodEn1, oEnvas1, oCodEn2, oEnvas2, oCodEn3, oEnvas3, oCodEn4, oEnvas4, oGetEnv, oBtnESa, oBtnECf
       Local lSaidaF   := .f.
       Local cNumOrd   := space(11)
       Local cNumLot   := space(06)
       Local cCodOrd   := space(15)
       Local cDesOrd   := space(30)
       Local cCodEn1   := space(05)
       Local cCodEn2   := space(05)
       Local cCodEn3   := space(05)
       Local cCodEn4   := space(05)
       Local cEnvas1   := space(30)
       Local cEnvas2   := space(30)
       Local cEnvas3   := space(30)
       Local cEnvas4   := space(30)
       Local nUsado    := 0
       Private aCols   := {}
       Private aHeader := {}

       //Montagem do aHeader
       DbSelectArea("SX3")
       DbSetOrder(2)
       MsSeek("C2_OP")
       nUsado += 1
       AADD(aHeader, { 'O.P.'       , 'NUMORD', '999999'   ,  6, 0, '', X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )
       MsSeek("C2_PRODUTO")
       nUsado += 1
       AADD(aHeader, { 'Produto'    , 'CODORD', '99'       ,  2, 0, '', X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )
       MsSeek("C2_QUANT")
       nUsado += 1
       AADD(aHeader, { 'Qtd. Solic.', 'QTDSOL', '@E 999999',  6, 0, '', X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )
       MsSeek("C2_QUANT")
       nUsado += 1
       AADD(aHeader, { 'Qtd. Apont.', 'QTDAPT', '@E 999999',  6, 0, '', X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )
       MsSeek("C2_PRODUTO")
       nUsado += 1
       AADD(aHeader, { 'Embalagem'  , 'CODEMB', '9999'     ,  4, 0, '', X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )

       DEFINE MSDIALOG oDlgF FROM 000,000 TO 023,085 TITLE OemToAnsi("Ops. de Envase - Finalizadas") OF oMainWnd
       DEFINE FONT oFont1 SIZE 9,0 BOLD
       DEFINE FONT oFont2 NAME 'ARIAL' SIZE 10,0 BOLD
       DEFINE CURSOR oCursor RESOURCE "BR_AZUL"
              @ 001, 003 SAY   OemToAnsi("Ordem Prod.")              SIZE 030,009                PIXEL OF oDlgF
              @ 009, 003 MSGET oNumOrd VAR cNumOrd PICTURE "@R!"     SIZE 065,10 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
              @ 001, 070 SAY   OemToAnsi("Lote")                     SIZE 030,009                PIXEL OF oDlgF
              @ 009, 070 MSGET oNumLot VAR cNumLot PICTURE "@R!"     SIZE 040,10 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
              @ 001, 112 SAY   OemToAnsi("Produto")                  SIZE 030,009                PIXEL OF oDlgF
              @ 009, 112 MSGET oCodOrd VAR cCodOrd PICTURE "@R!"     SIZE 078,10 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
              @ 001, 192 SAY   OemToAnsi("Descrição")                SIZE 030,009                PIXEL OF oDlgF
              @ 009, 192 MSGET oDesOrd VAR cDesOrd PICTURE "@R!"     SIZE 143,10 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
              @ 021, 003 SAY   OemToAnsi("Envasador 1")              SIZE 035,009                PIXEL OF oDlgF
              @ 029, 003 MSGET oCodEn1 VAR cCodEn1 PICTURE "@R!"     SIZE 035,10 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
              @ 029, 040 MSGET oEnvas1 VAR cEnvas1 PICTURE "@R!"     SIZE 128,10 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
              @ 021, 170 SAY   OemToAnsi("Envasador 2")              SIZE 035,009                PIXEL OF oDlgF
              @ 029, 170 MSGET oCodEn2 VAR cCodEn2 PICTURE "@R!"     SIZE 035,10 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
              @ 029, 207 MSGET oEnvas2 VAR cEnvas2 PICTURE "@R!"     SIZE 128,10 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
              @ 041, 003 SAY   OemToAnsi("Envasador 3")              SIZE 035,009                PIXEL OF oDlgF
              @ 049, 003 MSGET oCodEn3 VAR cCodEn3 PICTURE "@R!"     SIZE 035,10 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
              @ 049, 040 MSGET oEnvas3 VAR cEnvas3 PICTURE "@R!"     SIZE 128,10 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
              @ 041, 170 SAY   OemToAnsi("Envasador 4")              SIZE 035,009                PIXEL OF oDlgF
              @ 049, 170 MSGET oCodEn4 VAR cCodEn4 PICTURE "@R!"     SIZE 035,10 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
              @ 049, 207 MSGET oEnvas4 VAR cEnvas4 PICTURE "@R!"     SIZE 128,10 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
              oGetEnv := MsGetDados():New( 065, 003, 160, 335, 3, "AllwaysTrue()", "AllwaysTrue()", "", .f., {"QTDAPT"}, 3, , Len(aCols), "AllwaysTrue()" )

              DEFINE SBUTTON oBtnECf FROM 161, 260 TYPE 1 ACTION(lSaida := .t., oDlgF:End()) ENABLE OF oDlgF
              DEFINE SBUTTON oBtnESa FROM 161, 300 TYPE 2 ACTION(lSaida := .t., oDlgF:End()) ENABLE OF oDlgF

              oNumLot:lReadOnly  := .t. ; oCodOrd:lReadOnly := .t. ; oDesOrd:lReadOnly := .t. ; oEnvas1:lReadOnly := .t. ; oEnvas2:lReadOnly := .t. ; oEnvas3:lReadOnly := .t. ; oEnvas4:lReadOnly := .t.
              oNumOrd:bLostFocus := {|| fValOrd(@cNumOrd, @oNumOrd, @cNumLot, @oNumLot, @cCodOrd, @oCodOrd, @cDesOrd, @oDesOrd, @aCols, @oGetEnv)}
              oDlgF:nStyle       := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
              oGetEnv:oBrowse:lUseDefaultColors  := .f.
              oGetEnv:oBrowse:oFont              := oFont2
              oGetEnv:oBrowse:nClrText           := CLR_BLACK
              oGetEnv:oBrowse:nClrBackFocus      := CLR_WHITE
              oGetEnv:oBrowse:nClrForeFocus      := CLR_WHITE
              oGetEnv:oBrowse:lAdjustColSize     := .t.
       ACTIVATE MSDIALOG oDlgF VALID lSaidaF CENTERED
Return
*/
/******************************************************************************************************************/
/*** fValOrd - Valida a Saida da digitação do numero da O.P. na consulta de produtos.   FUNCAO INATIVA          ***/
/******************************************************************************************************************/
/*
Static Function fValOrd(oNumOrd, cNumOrd, cCodPro, nQtdOrd, oQtdPro, nQtdJaE, oQtdJaE, nQtdAbe, oQtdAbe, nQtdApt, oQtdApt)
       Local cQry1 :=""
       If Empty(cNumOrd)
          Return(.t.)
       Else
          //1º) Buscar numero do lote
          cQry1 := ""
          cQry1 += "SELECT SC2.C2_LOTE, SC2.C2_NUM "
          cQry1 += "FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "
          cQry1 += "WHERE SC2.C2_FILIAL  = '"+xFilial("SC2")+"' "
          cQry1 += "  AND SC2.D_E_L_E_T_ = '' "
          cQry1 += "  AND SC2.C2_NUM     = '"+SubStr(cNumOrd, 01, 6)+"' "
          cQry1 += "  AND SC2.C2_ITEM    = '"+SubStr(cNumOrd, 07, 2)+"' "
          cQry1 += "  AND SC2.C2_SEQUEN  = '"+SubStr(cNumOrd, 09, 3)+"' "
          cQry1 += "ORDER BY SC2.C2_EMISSAO "
          TCQuery cQry1 ALIAS "BXO" NEW
          DbSelectArea("BXO")
          If Empty(BXO->C2_NUM)
             ApMsgStop("Ordem de produção não existe.")
             cNumOrd := space(13)
             oNumOrd:Refresh()
             oNumOrd:SetFocus()
             DbSelectArea("BXO")
             DbCloseArea()
             Return(.t.)
          Else
             If SubStr(cNumOrd, 1, 6) == BXO->C2_NUM
                cNumLot := BXO->C2_LOTE
             Else
                ApMsgStop("Essa ordem de produção não foi encontrada.")
                cNumOrd := space(13)
                oNumOrd:Refresh()
                oNumOrd:SetFocus()
                DbSelectArea("BXO")
                DbCloseArea()
                Return(.t.)
             Endif
          Endif
          DbSelectArea("BXO")
          DbCloseArea()

          //2º) Buscar dados da Ordem de Produção
          cQry1 := ""
          cQry1 += "SELECT SC2.C2_LOTE, SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_QUANT, SC2.C2_QUJE, SC2.C2_DATRF "
          cQry1 += "FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "
          cQry1 += "WHERE SC2.C2_FILIAL  = '"+xFilial("SC2")+"' "
          cQry1 += "  AND SC2.D_E_L_E_T_ = '' "
          cQry1 += "  AND SC2.C2_LOTE    = '"+cNumLot+"' "
          cQry1 += "  AND SC2.C2_PRODUTO = '"+StrTran(StrTran(cCodPro, '.'), '-')+"' "
          cQry1 += "ORDER BY SC2.C2_EMISSAO "
          TCQuery cQry1 ALIAS "BXO" NEW
          DbSelectArea("BXO")
          If Empty(BXO->C2_DATRF)
             nQtdOrd := BXO->C2_QUANT
             nQtdJaE := BXO->C2_QUJE
             nQtdAbe := nQtdOrd - nQtdJaE
             oQtdApt:SetFocus()
             If nQtdOrd <= nQtdJaE
                ApMsgStop("Está ordem de produção está com algum problema de baixa, verifique com o responsável!")
                cNumOrd := space(13)
                oNumOrd:Refresh()
                oNumOrd:SetFocus()
                DbSelectArea("BXO")
                DbCloseArea()
                Return(.t.)
             Else
                oQtdPro:Refresh()
                oQtdJaE:Refresh()
                oQtdAbe:Refresh()
             Endif
          Else
             ApMsgStop("Ordem de produção já foi baixada.")
             cNumOrd := space(13)
             oNumOrd:Refresh()
             oNumOrd:SetFocus()
             DbSelectArea("BXO")
             DbCloseArea()
             Return(.t.)
          Endif
          DbSelectArea("BXO")
          DbCloseArea()
       Endif
Return(.f.)
*/
/*
Static Function fValOrd(cNumOrd, oNumOrd, cNumLot, oNumLot, cCodOrd, oCodOrd, cDesOrd, oDesOrd, aCols, oGetEnv)
       Local cQry1 := ""
       If !Empty(cNumOrd)
          //1º) Verificar se a Ordem de Produção do PI foi iniciada e finalizada.
          oNumOrd:lReadOnly := .t.
          cQry1 += "SELECT * "
          cQry1 += "FROM PRODUCAO WITH (NOLOCK) "
          cQry1 += "WHERE ORDEM = '"+cNumOrd+"' "
          TCQuery cQry1 ALIAS "TCQ" NEW
          DbSelectArea("TCQ")
          cNumPro := TCQ->ORDEM
          cLotPro := TCQ->LOTE
          cIniPro := TCQ->INICIO
          cFimPro := TCQ->FIM
          cFlgPro := TCQ->FLAG
          DbSelectArea("TCQ")
          DbCloseArea()
          If Empty(cNumPro)
             ApMsgStop('Atenção a Ordem de Produção do "PI" ainda não foi iniciada.')
             cNumOrd := space(11)
             oNumOrd:lReadOnly := .f.
             oNumOrd:SetFocus()
             oNumOrd:Refresh()
             Return(.f.)
          Else
             If Empty(cFimPro)
                ApMsgStop('Atenção a Ordem de Produção do "PI" ainda não foi finalizada.')
                cNumOrd := space(11)
                oNumOrd:lReadOnly := .f.
                oNumOrd:SetFocus()
                oNumOrd:Refresh()
                Return(.f.)
             Else
                cQry1 := ""
                cQry1 += "SELECT SUBSTRING(SB1.B1_COD, 11, 2) AS PRODUTO "
                cQry1 += "FROM "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) "
                cQry1 += "WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
                cQry1 += "  AND SB1.D_E_L_E_T_ = '' "
                cQry1 += "  AND SUBSTRING(SB1.B1_COD, 1, 10) = '"+SubStr(Posicione("SC2", 1, xFilial("SC2")+cNumOrd, "C2_PRODUTO"), 1, 10)+"' "
                cQry1 += "  AND SUBSTRING(SB1.B1_COD, 11, 2) <> '00' "
                cQry1 += "ORDER BY SUBSTRING(SB1.B1_COD, 11, 2) "
                TCQuery cQry1 ALIAS "TCQ" NEW
                DbSelectArea("TCQ")
                While !Eof()
                      aAdd(aCols, {'', TCQ->PRODUTO, 0.0, 0.0, '', .f.})
                      DbSelectArea("TCQ")
                      DbSkip()
                EndDo
                DbSelectArea("TCQ")
                DbCloseArea()
                cQry1 := ""
                cQry1 += "SELECT * "
                cQry1 += "FROM PRODUCAO WITH (NOLOCK) "
                cQry1 += "WHERE LOTE = '"+cLotPro+"' "
                cQry1 += "  AND ORDEM <> '"+cNumOrd+"' "
                TCQuery cQry1 ALIAS "TCQ" NEW
                DbSelectArea("TCQ")
                While !Eof()
                      nPos := aScan(aCols, {|x| x[2] == Posicione("SC2", 1, xFilial("SC2")+TCQ->ORDEM, "C2_PRODUTO")})
                      If nPos > 0.0
                         aCols[nPos][1] := SubStr(TCQ->ORDEM, 1, 6)
                         aCols[nPos][3] := Posicione("SC2", 1, xFilial("SC2")+TCQ->ORDEM, "C2_QUANT")
                      Endif
                      DbSkip()
                EndDo
                DbSelectArea("TCQ")
                DbCloseArea()
                oGetEnv:oBrowse:Refresh()
                cNumLot := cLotPro
                oNumLot:Refresh()
                cCodOrd := Posicione("SC2", 1, xFilial("SC2")+cNumOrd, "C2_PRODUTO")
                oCodOrd:Refresh()
                cDesOrd := Posicione("SB1", 1, xFilial("SB1")+Posicione("SC2", 1, xFilial("SC2")+cNumOrd, "C2_PRODUTO"), "B1_DESC")
                oDesOrd:Refresh()
             Endif
          Endif
          oNumOrd:lReadOnly := .f.
       Endif
Return(.t.)
*/


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FATA03_A ³ Autor ³ Luís G. de Souza      ³ Data ³ 23/06/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³                  ³Contato ³                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ CONSULTA DE PRODUTOS NA SAÍDA DO ENVASE                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³  /  /  ³                                               ³±±
±±³              ³  /  /  ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function FATA03_A(cOpcCon)

	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
   ±± Declaração de cVariable dos componentes                                 ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	//Private cOpcCon    := Iif(cOpcCon == Nil, "M", cOpcCon)

	Private aCores     := { { ' ZT1->ZT1_FLAG $ "C" ' , "BR_VERMELHO"}, { '!ZT1->ZT1_FLAG $ "C" ' , "BR_VERDE"} }
	Private cSayPro    := Space(1)
	Private cCodPro    := Space(15)
	Private cSayDes    := Space(1)
	Private cDesPro    := Space(30)
	Private cSayLoc    := Space(1)
	Private cLocPro    := Space(15)

	Private cLocProA    := Space(15)  // Jose 21/08/2024
	Private cLocProG    := Space(15)  // Jose 21/08/2024

	Private cSayOrd    := Space(1)
	Private cOrdPro    := Space(11)
	Private aOrdPro    := {}
	Private cCodLot    := Space(06)
	Private cSayCon    := Space(1)
	Private nQtdOrd    := 0
	Private cSayMar    := Space(1)
	Private nQtdSep3   := 0
	Private cSayEst    := Space(1)
	Private nQtdG3     := 0
	Private nQtdA3     := 0     // Jose 05/07/2024
	Private nQtdSepA   := 0     // Jose 05/07/2024
	Private nQtdDispA  := 0     // Jose 05/07/2024
	Private cSayEnv    := Space(1)
	Private nQtdSepG   := 0
	Private cSayAtu    := Space(1)
	Private nQtd03     := 0
	Private nQtd30     := 0
	Private nQtdMark   := 0
	Private cSayDis    := Space(1)
	Private nQtdDis    := 0
	Private cSaySep    := Space(1)
	Private nQtdDispG  := 0
	Private cMarca     := GetMark()
	Private cAuxPed    := ""
	Private nQtdPro    := 0
	Private lProest    := .f.
	Private oTempTbl1                //Variável criada para arquivo temporário compatibilização com release 12.1.25
	Private oTempTbl2                //Variável criada para arquivo temporário compatibilização com release 12.1.25
	Private oTempTbl3                //Variável criada para arquivo temporário compatibilização com release 12.1.25
	Private oTempTbl4                //Variável criada para arquivo temporário compatibilização com release 12.1.25
	Private oTempTbl5                //Variável criada para arquivo temporário compatibilização com release 12.1.25
	Private oTempTbl6                //Variável criada para arquivo temporário compatibilização com release 12.1.25

	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
   ±± Declaração de Variaveis Private dos Objetos                             ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	SetPrvt("oFont1" , "oFont2" , "oDlg1"  , "oBtnPed", "oBtnNes", "oBtnAtu", "oBtnSai", "oGrpDiv", "oSayPro", "oCodPro")
	SetPrvt("oSayDes", "oDesPro", "oSayLoc", "oLocPro", "oGrpPrE", "oSayOrd", "oOrdPro", "oSayPro", "oQtdPro", "oSaySep3")
	SetPrvt("oQtdSep3", "oSayG3", "oQtdG3", "oSaySepG", "oQtdSepG", "oSay03", "oQtd03", "oSayDispG", "oQtdDispG", "oSayDis", "oQtdA3", "oSaySepA", "oQtdSepA", "oSayDispA", "oQtdDispA")
	SetPrvt("oQtdDis", "oGrpDes", "oBrwDes", "oGrpPed", "oBrwPed", "oSay30", "oQtd30")
	SetPrvt("oBtnSal", "oBtnTra", "oBtnMoP", "oBtnTrP","oBtnINF", "oSayMark", "oQtdMark")


	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
   ±± Definicao do Dialog e todos os seus componentes.                        ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

	oFont1     := TFont():New( "Courier New", 0, -11, , .F., 0, , 400, .F., .F., , , , , , )
	oFont2     := TFont():New( "Courier New", 0, -13, , .T., 0, , 700, .F., .F., , , , , , )
	// oDlg1      := MSDialog():New( 265, 241, 850, 1470, "Consulta de Produtos", , , .F., , , , , , .T., , , .T. ) //   jose 05/05/2025
	oDlg1      := MSDialog():New( 255, 231, 850, 1470, "Consulta de Produtos", , , .F., , , , , , .T., , , .T. ) // Jose onde 1270 era 1020 ERA 1270  jose 05/05/2025 265, 241, 850, 1470,

	oBtnPed    := TButton():New( 004, 001, "Pedidos"     , oDlg1, {|| fConPed()   }, 037, 012, , , , .T., , "", , , , .F. )
	oBtnNes    := TButton():New( 004, 044, "Necessidade" , oDlg1, {|| fConNec()   }, 037, 012, , , , .T., , "", , , , .F. )
	oBtnLoc    := TButton():New( 004, 088, "Localização" , oDlg1, {|| fAbrLoc()   }, 037, 012, , , , .T., , "", , , , .F. )

	//  jOSE 05/05/2025 ---------------------------------------
	oBtnLoc    := TButton():New( 004, 160, "Etiq. Arara" , oDlg1, {|| fIEtProA()   }, 037, 012, , , , .T., , "", , , , .F. )
	// ATÉ AQUI jOSE 05/05/2025 ------------------------------
	// desativado botão de saldo em estoque na tela de consulta 2 por conta da rampa não enxergar o saldo do produto e não transferir pela consulta do saldo. 26/01/16
	// Jose 05/07/2024 pedido André TI     oBtnSal    := TButton():New( 003, 100, "Saldos Est." , oDlg1, {|| MATA225()   }, 037, 012, , , , .F., , "", , , , .F. ) // Jose 05/07/2024 antes 132
	//oBtnTra    := TButton():New( 004, 176, "Transfer."   , oDlg1, {|| MATA260()   }, 037, 012, , , , .T., , "", , , , .F. )
	//oBtnTra    := TButton():New( 004, 176, "Transfer."   , oDlg1, {|| MsgStop('Rotina desativada,transferências somente de pallets. Atenção !')   }, 037, 012, , , , .T., , "", , , , .F. )

	oBtnMoP    := TButton():New( 004, 220, "Monta Pallet", oDlg1, {|| u_BRFATX64()}, 037, 012, , , , .T., , "", , , , .F. )
	oBtnTrP    := TButton():New( 004, 264, "Trans Pallet", oDlg1, {|| u_BRFATX65()}, 037, 012, , , , .T., , "", , , , .F. )
	oBtnINF    := TButton():New( 004, 303, "i", oDlg1, {|| fResProd()}, 010, 012, , , , .T., , "", , , , .F. )

	//oBtnAtu  := TButton():New( 004, 308, "Atualizar"   , oDlg1, {|| MsAguarde( {|| fAtuDad(cOpcCon)}, "Aguarde...", "Atualizando...") }, 037, 012, , , , .T., , "", , , , .F. )
	oBtnSai    := TButton():New( 004, 550, "Sair"        , oDlg1, {|| oDlg1:End() }, 037, 012, , , , .T., , "", , , , .F. ) // Jose 05/05/2025      004, 352, "Sair"

	oGrpDiv    := TGroup():New( 016, 004, 016, 392, "", oDlg1, CLR_BLACK, CLR_WHITE, .T., .F. )
	oSayPro    := TSay():New( 024, 004, {||"Produto:"}                               , oDlg1  , ,oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 032, 008)
	oCodPro    := TGet():New( 032, 004, {|u| If(PCount() > 0, cCodPro := u, cCodPro)}, oDlg1  , 072, 10, '@!', , CLR_BLACK, CLR_WHITE, oFont2, , , .T., "", , , .F., .F., , .F., .F., "", "cCodPro", , )
	oCodPro:bLostFocus := {|| fCodPro(), Iif(!Empty(cCodPro), MsAguarde( {|| oTbl1(2)}, "Aguarde...", "Buscando despachos..."), ), Iif(!Empty(cCodPro), MsAguarde( {|| oTbl2(2)}, "Aguarde...", "Buscando pedidos..."), )}
	oSayDes    := TSay():New( 024, 084, {||"Descrição:"}                             , oDlg1  , , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 036, 008)
	oDesPro    := TGet():New( 032, 084, {|u| If(PCount() > 0, cDesPro := u, cDesPro)}, oDlg1  , 200, 10, ''  , , CLR_BLACK, CLR_WHITE, oFont2, , , .T., "", , , .F., .F., , .T., .F., "", "cDesPro", , )
	// Jose 21/08/2024 oSayLoc    := TSay():New( 024, 292, {||"Localização:"}                           , oDlg1  , , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 044, 008)
	oSayLoc    := TSay():New( 024, 292, {||"Matão:"}                                 , oDlg1  , , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 044, 008)
	oLocPro    := TGet():New( 032, 292, {|u| If(PCount() > 0, cLocPro := u, cLocPro)}, oDlg1  , 096, 10, ''  , , CLR_BLACK, CLR_WHITE, oFont2, , , .T., "", , , .F., .F., , .T., .F., "", "cLocPro", , )

	//-------- acrescentado por Jose 21/08/2024 ------------------
	oSayLoc    := TSay():New( 024, 392, {||"Araraquara:"}                                 , oDlg1  , , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 044, 008)
	oLocPro    := TGet():New( 032, 392, {|u| If(PCount() > 0, cLocProA := u, cLocProA)}, oDlg1  , 096, 10, ''  , , CLR_BLACK, CLR_WHITE, oFont2, , , .T., "", , , .F., .F., , .T., .F., "", "cLocProA", , )
	oSayLoc    := TSay():New( 024, 492, {||"Guarulhos:"}                                 , oDlg1  , , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 044, 008)
	oLocPro    := TGet():New( 032, 492, {|u| If(PCount() > 0, cLocProG := u, cLocProG)}, oDlg1  , 096, 10, ''  , , CLR_BLACK, CLR_WHITE, oFont2, , , .T., "", , , .F., .F., , .T., .F., "", "cLocProG", , )
	//
	oGrpPrE    := TGroup():New( 048, 004, 080, 550, "Estoque...", oDlg1, CLR_BLACK, CLR_WHITE, .T., .F. )  // Jose 05/07/2024 antes 388 agora 510
	oSayPro    := TSay():New( 056, 007, {||"P1 / P2"}                              , oGrpPrE, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 042, 008)
	oQtdPro    := TGet():New( 064, 007, {|u| If(PCount() > 0, nQtdPro := u, nQtdPro)}, oGrpPrE, 032, 10, '@E 999999', , CLR_BLACK, CLR_WHITE, oFont2, , , .T., "", , , .F., .F., , .T., .F., "", "nQtdPro", , )
	oSay30     := TSay():New( 056, 050, {||"Almo. 30"}                              , oGrpPrE, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 042, 008)
	oQtd30     := TGet():New( 064, 050, {|u| If(PCount() > 0, nQtd30 := u, nQtd30)}, oGrpPrE, 032, 10, '@E 999999', , CLR_BLACK, CLR_WHITE, oFont2, , , .T., "", , , .F., .F., , .T., .F., "", "nQtd30", , )
	oSay03     := TSay():New( 056, 092, {||"Almo. 03"}                                 , oGrpPrE, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 042, 008)
	oQtd03     := TGet():New( 064, 092, {|u| If(PCount() > 0, nQtd03 := u, nQtd03)}, oGrpPrE, 032, 10, '@E 999999', , CLR_BLACK, CLR_WHITE, oFont2, , , .T., "", , , .F., .F., , .T., .F., "", "nQtd03", , )
	oSaySep3   := TSay():New( 056, 134, {||"Separado03"}                              , oGrpPrE, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 042, 008)
	oQtdSep3   := TGet():New( 064, 134, {|u| If(PCount() > 0, nQtdSep3 := u, nQtdSep3)}, oGrpPrE, 032, 10, '@E 999999', , CLR_BLACK, CLR_WHITE, oFont2, , , .T., "", , , .F., .F., , .T., .F., "", "nQtdSep3", , )
	oSayDis    := TSay():New( 056, 176, {||"Disp. 03"}                            , oGrpPrE, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 045, 008)
	oQtdDis    := TGet():New( 064, 176, {|u| If(PCount() > 0, nQtdDis := u, nQtdDis)}, oGrpPrE, 032, 10, '@E 999999', , CLR_BLACK, CLR_WHITE, oFont2, , , .T., "", , , .F., .F., , .T., .F., "", "nQtdDis", , )
	oSayG3     := TSay():New( 056, 218, {||"Saldo G3"}                               , oGrpPrE, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 042, 008)
	oQtdG3     := TGet():New( 064, 218, {|u| If(PCount() > 0, nQtdG3 := u, nQtdG3)}, oGrpPrE, 032, 10, '@E 999999', {|| positivo() }, CLR_BLACK, CLR_WHITE, oFont2, , , .T., "", , , .F., .F., , .F., .F., "", "nQtdG3", , )
	oSaySepG   := TSay():New( 056, 260, {||"SeparadoG3"}                            , oGrpPrE, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 042, 008)
	oQtdSepG   := TGet():New( 064, 260, {|u| If(PCount() > 0, nQtdSepG := u, nQtdSepG)}, oGrpPrE, 032, 10, '@E 999999', , CLR_BLACK, CLR_WHITE, oFont2, , , .T., "", , , .F., .F., , .T., .F., "", "nQtdSepG", , )
	oSayDispG  := TSay():New( 056, 302, {||"Disp. G3"}                              , oGrpPrE, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 044, 008)
	oQtdDispG  := TGet():New( 064, 302, {|u| If(PCount() > 0, nQtdDispG := u, nQtdDispG)}, oGrpPrE, 032, 10, '@E 999999', , CLR_BLACK, CLR_WHITE, oFont2, , , .T., "", , , .F., .F., , .T., .F., "", "nQtdDispG", , )
	/*-----------   Jose 05/07/2024 ----------------------------------------*/
	oSayA3     := TSay():New( 056, 344, {||"Saldo A3"}                               , oGrpPrE, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 042, 008)
	oQtdA3     := TGet():New( 064, 344, {|u| If(PCount() > 0, nQtdA3 := u, nQtdA3)}, oGrpPrE, 032, 10, '@E 999999', {|| positivo() }, CLR_BLACK, CLR_WHITE, oFont2, , , .T., "", , , .F., .F., , .F., .F., "", "nQtdA3", , )
	oSaySepA   := TSay():New( 056, 386, {||"SeparadoA3"}                            , oGrpPrE, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 042, 008)
	oQtdSepA   := TGet():New( 064, 386, {|u| If(PCount() > 0, nQtdSepA := u, nQtdSepA)}, oGrpPrE, 032, 10, '@E 999999', , CLR_BLACK, CLR_WHITE, oFont2, , , .T., "", , , .F., .F., , .T., .F., "", "nQtdSepA", , )
	oSayDispA  := TSay():New( 056, 428, {||"Disp. A3"}                              , oGrpPrE, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 044, 008)
	oQtdDispA  := TGet():New( 064, 428, {|u| If(PCount() > 0, nQtdDispA := u, nQtdDispA)}, oGrpPrE, 032, 10, '@E 999999', , CLR_BLACK, CLR_WHITE, oFont2, , , .T., "", , , .F., .F., , .T., .F., "", "nQtdDispA", , )
	/*-------------- Aqui Jose 05/072024  ------------------------------------*/
	oSayMark   := TSay():New( 056, 470, {||"Marcados"}                            , oGrpPrE, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 042, 008)  // Jose 05/07/2024   056, 344,
	oQtdMark   := TGet():New( 064, 470, {|u| If(PCount() > 0, nQtdMark := u, nQtdMark)}, oGrpPrE, 032, 10, '@E 999999', , CLR_BLACK, CLR_WHITE, oFont2, , , .T., "", , , .F., .F., , .T., .F., "", "nQtdMark", , )  // Jose 05/07/2024   056, 344,

	// maa
	nQtdAvar	:= 0
	oSayMark   := TSay():New( 056, 510, {||"Avarias"}                            , oGrpPrE, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 042, 008)  // Jose 05/07/2024   056, 344,
	oQtdMark   := TGet():New( 064, 510, {|u| If(PCount() > 0, nQtdAvar := u, nQtdAvar)}, oGrpPrE, 032, 10, '@E 999999', , CLR_BLACK, CLR_WHITE, oFont2, , , .T., "", , , .F., .F., , .T., .F., "", "nQtdAvar", , )  // Jose 05/07/2024   056, 344,

	//oQtdG3:bLostFocus := {|| nQtdSepG := nQtdG3 + nQtdSep3, oQtdG3:Refresh(), oQtdSepG:Refresh() }

	oGrpDes    := TGroup():New( 084,004,160,510,"Bordero de Despacho",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )  // Jose 05/07/2024 388

	oTbl1(1)
	DbSelectArea("ZT1")
	DbGoTop()
	oBrwDes    := MsSelect():New( "ZT1", "ZT1_MARCA", "", { {"ZT1_MARCA", "", "", ""}, {"ZT1_BORDES", "", "Despacho", ""}, {"ZT1_BORPED", "", "Pedido", ""}, {"ZT1_REGIAO", "", "Regiao", ""}, {"ZT1_PREVIS", "", "Previsão", ""}, {"ZT1_PEDIDO", "", "Pedido", ""}, {"ZT1_QUANTI", "", "Quantidade", ""}, {"ZT1_LOCALI", "", "Expedição", ""},{"ZT1_GAVETA", "", "Vol. Ped.", ""} }, .F., cMarca, {092, 008, 156, 506}, , , oGrpDes, , aCores ) // Jose 05/07/2024 384
	oBrwDes:oBrowse:bChange := {||DbSelectArea("ZT1") }
	oBrwDes:bAval := {||ZT1Mark()}
	oBrwDes:oBrowse:lHasMark := .T.
	oBrwDes:oBrowse:lCanAllmark := .F.

	oGrpPed    := TGroup():New( 164, 004, 280, 510, "Bordero de Pedidos",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )  // Jose 05/07/2024 388   Jose 05/05/2025   164, 004, 240, 510,
	oTbl2(1)
	DbSelectArea("ZT2")
	oBrwPed    := MsSelect():New( "ZT2", "ZT2_MARCA", "", { {"ZT2_MARCA", "", "", ""}, {"ZT2_NUMBOR", "", "Bord. Ped.", "@R 999999"}, {"ZT2_EMISSA", "", "Emissão"   , ""}, {"ZT2_PEDIDO", "", "Pedido"    , "999999"}, {"ZT2_QUANTI", "", "Quantidade", "@E 99,999.9999"},  {"ZT2_LOCEXP", "", "Expedição" , ""},  {"ZT2_LOCAL", "", "Local Ped" , ""} , {"ZT2_GAVETA", "", "Vol. Ped."    , ""} }, .F., cMarca, {172, 008, 276, 506}, , , oGrpPed )  // Jose 05/07/2024 384 // Jose 21/08/2024  jose 05/05/2025  172, 008, 236, 506}
	oBrwPed:oBrowse:bChange := {||DbSelectArea("ZT2") }
	oBrwPed:bAval               := {||ZT2Mark()}
	oBrwPed:oBrowse:lHasMark    := .T.
	oBrwPed:oBrowse:lCanAllmark := .F.
	//oBrwPed:oBrowse:bLDBLClick  := { || fBordEspec() }

	oDlg1:nStyle := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
	oCodPro:SetFocus()
	oDlg1:Activate(,,,.T.)
	DbSelectArea("ZT1")
	DbCloseArea()
	oTempTbl1:Delete()
	DbSelectArea("ZT2")
	DbCloseArea()
	oTempTbl2:Delete()

Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fResProd() - Ver os pallets que o produto esta separado.
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

Static Function fResProd()

	Local nY
	Local aResPal := {}
	Local cMsgRes := ""
	Local nTQtd   := 0

	cQry1 := " "
	cQry1 += "  SELECT C6_PRODUTO AS 'CODIGO', C6_LOCAL AS 'ALMOX', ZZK_CODIGO AS 'PALLET', SUM(ZZK_QUANT) AS QTDESEPARADA, "
	cQry1 += "  CASE WHEN ZZJ_FLAG ='5' AND ZZJ_LOCDES <> '' THEN '5-HOUVE TRANSF INTERNA E NF GERADA' ELSE "
	cQry1 += "  CASE WHEN ZZJ_FLAG ='5' AND ZZJ_LOCDES =  ''  THEN '5-NF GERADA SEM TRANF INTERNA' ELSE "
	cQry1 += "  CASE WHEN ZZJ_FLAG ='4' AND ZZJ_LOCDES <> '' THEN '4-TRANSF INTERNA SEM NF TRANSF' ELSE "
	cQry1 += "  CASE WHEN ZZJ_FLAG ='4' AND ZZJ_LOCALI = 'FAB1' THEN '4-PALLET FAB1 - SEM NF TRANSF' ELSE "
	cQry1 += "  CASE WHEN ZZJ_FLAG ='3' AND ZZJ_LOCDES =  ''  THEN '3-PALLET MONTADO' END END END END END AS 'STATUS', "
	cQry1 += "  ZZJ_FLAG AS 'STATUSPALLET', CASE WHEN ZZJ_LOCDES <>'' THEN 'TRANSF. ALMOX' ELSE 'NÃO HOUVE TRANSF.' END AS 'STATUSPALLET', "
	cQry1 += "  ZZJ_LOCORI AS 'ORIGEM', ZZJ_LOCDES AS 'DESTINO', ZZJ_TIPBOR  AS 'TIPOBORDERO', ZZJ_LOCALI AS 'LOCALORIGEM' "
	cQry1 += "  FROM "+RetSqlName("SC6")+" SC6 WITH(NOLOCK)  "
	cQry1 += "  LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH(NOLOCK) ON ZZK_FILIAL = C6_FILIAL AND ZZK_PRODUT = C6_PRODUTO AND ZZK_PEDIDO = C6_NUM AND ZZK.D_E_L_E_T_ =''  "
	cQry1 += "  LEFT OUTER JOIN "+RetSqlName("ZZJ")+" ZZJ WITH(NOLOCK) ON ZZJ_FILIAL = ZZK_FILIAL AND ZZJ_CODIGO = ZZK_CODIGO AND ZZJ.D_E_L_E_T_ ='' "
	cQry1 += "  WHERE SC6.D_E_L_E_T_ =''  "
	cQry1 += "  AND C6_FILIAL = '"+xFilial("ZZK")+"'"
	cQry1 += "  AND C6_PRODUTO = '"+Alltrim(StrTran(StrTran(cCodPro, '.'), '-'))+"' "
	cQry1 += "  AND C6_NOTA =''  "
	cQry1 += "  AND ZZK_CODIGO IS NOT NULL "
	cQry1 += "  GROUP BY C6_PRODUTO, C6_LOCAL, ZZK_CODIGO, ZZJ_FLAG, ZZJ_LOCORI, ZZJ_LOCDES, ZZJ_TIPBOR, ZZJ_LOCALI "
	cQry1 += "  ORDER BY C6_LOCAL, ZZJ_FLAG, ZZK_CODIGO "

	TCQuery cQry1 ALIAS "TCQ" NEW

	DbSelectArea("TCQ")
	DbGoTop()
	If !Eof()
		While !Eof()
			aAdd(aResPal, {TCQ->PALLET ,TCQ->STATUS ,TCQ->QTDESEPARADA, TCQ->LOCALORIGEM})
			nTQtd += TCQ->QTDESEPARADA
			DbSelectArea("TCQ")
			DbSkip()
		Enddo
	Endif
	DbSelectArea("TCQ")
	DbCloseArea()

	If Len(aResPal) > 0
		cMsgRes += '    RESUMO DA MONTAGEM DO PRODUTO '+Alltrim(cCodPro)+'   '+Chr(13)+Chr(10)
		cMsgRes += '+------------+-----------------------------------+-----+------+'+Chr(13)+Chr(10)
		cMsgRes += '|  PALLET    |   STATUS                          |QTDE |ORIGEM|'+Chr(13)+Chr(10)
		cMsgRes += '+------------+-----------------------------------+-----+------+'+Chr(13)+Chr(10)
		For nY := 1 To Len(aResPal)
			cMsgRes += '| '+Substr(aResPal[nY][1],1,12)+'| '+Substr(aResPal[nY][2],1,35)+'|'+Transform(aResPal[nY][3], "@E 9999")+' | '+aResPal[nY][4]+' |'+Chr(13)+Chr(10)
		Next
		cMsgRes += '+------------+-----------------------------------+-----+------+'+Chr(13)+Chr(10)
		cMsgRes += '|            |                     TOTAIS        |'+Transform(nTQtd, "@E 99999")+'|      |'+Chr(13)+Chr(10)
		cMsgRes += '+------------+-----------------------------------+-----+------+'+Chr(13)+Chr(10)

	Endif

	If !Empty(cMsgRes)
		/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
      ±± Declaração de cVariable dos componentes                                 ±±
		Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
		Private cMGet1Ms

		/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
      ±± Declaração de Variaveis Private dos Objetos                             ±±
		Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
		SetPrvt("oFontMsg", "oDlg1Msg", "oMGet1Ms")

		/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
      ±± Definicao do Dialog e todos os seus componentes.                        ±±
		Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
		cMGet1Ms   := cMsgRes
		oFontMsg   := TFont():New( "Courier New", 0, -12, , .F., 0, , 480, .F., .F., , , , , , )
		oDlg1Msg   := MSDialog():New( 229, 262, 650, 800, "Resumo do Produto nos Pallets", , , .F., , , , , , .T., , , .T. ) // Jose  05/07/2024 730
		oMGet1Ms   := TMultiGet():New( 003, 003, {|u| If(PCount() > 0, cMGet1Ms := u, cMGet1Ms)}, oDlg1Msg, 230,230, oFontMsg, , CLR_BLACK, CLR_WHITE, , .T., "", , , .F., .F., .F., , , .F., , )
		oDlg1Msg:Activate(, , , .T.)

		If ChkFile("TMPITE")
			DbSelectArea("TMPITE")
			DbSetOrder(1)
			DbGoTop()

			oBrw1Env:oBrowse:GoTop()
			oBrw1Env:oBrowse:Refresh()
		Endif
	Endif
Return()


/*
Static Function fBordEspec()
       If ZT2->ZT2_NUMBOR $ '000000'
          MsgStop("Bordero 000000")
       Endif
Return .T.
*/
/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fConPed() - Busca informações de pedidos de vendas
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fConPed()
	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
   ±± Declaração de cVariable dos componentes                                 ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	Private cEndExp    := Space(1)
	Private cSayExp    := Space(1)

	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
   ±± Declaração de Variaveis Private dos Objetos                             ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	SetPrvt("oFont1", "oFont2", "oDlg2", "oSayExp", "oBrwXXX", "oEndExp")

	If Empty(cCodPro)
		ApMsgStop('Favor informar código do produto')
		Return
	Else
		/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
      ±± Definicao do Dialog e todos os seus componentes.                        ±±
		Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
		oFont1     := TFont():New( "Courier New", 0, -13, , .F., 0, , 400, .F., .F., , , , , , )
		oFont2     := TFont():New( "Courier New", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
		oDlg2      := MSDialog():New( 500, 449, 850, 1200, "Pedidos do Item", , , .F., , , , , , .T., , , .T. )
		oSayExp    := TSay():New( 154, 004, {||"Expedição:"}, oDlg2, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 044, 008)
		oTbl4()
		DbSelectArea("TPD")
		DbGoTop()
		oBrwXXX    := MsSelect():New( "TPD", "", "", { {"TPD_PEDIDO", "", "Pedido", "999999"}, {"TPD_QTDE", "", "Qtde.", "99999"},{"TPD_SEPAR", "", "Bipado", "99999"}, {"TPD_BORPED", "", "Bordero", "999999"}, {"TPD_DESPAC", "", "Despacho", "@!"}, {"TPD_VOLITE", "", "Vol.Item", "99999"}, {"TPD_VOLPED", "", "Vol.Ped", "99999"}, {"TPD_PALLET", "", "Local", "@!"}, {"TPD_PEDPRO", "", "Ped. Prog.", ""}, {"TPD_STAPED", "", "Status Ped.", ""} }, .F., , {000, 000, 147, 375}, , , oDlg2 )
		oBrwXXX:oBrowse:bChange := {|| fMosExp() }
		oEndExp    := TGet():New( 152, 052, {|u| If(PCount() > 0, cEndExp := u, cEndExp) }, oDlg2, 060, 011, '', , CLR_BLACK, CLR_WHITE, oFont2, , , .T., "", , , .F., .F., , .T., .F., "", "cEndExp", , )

		oDlg2:Activate(,,,.T.)
		DbSelectArea("TPD")
		DbCloseArea()
		oTempTbl4:Delete()
	Endif
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTbl4() - Cria temporario para o Alias: TMP
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTbl4()
	Local cQry1 := ""
	Local aFds := {}
	//Local cTmp

	aAdd( aFds , {"TPD_PEDIDO", "C", 006, 000} )
	aAdd( aFds , {"TPD_QTDE"  , "N", 005, 000} )
	aAdd( aFds , {"TPD_BORPED", "C", 006, 000} )
	aAdd( aFds , {"TPD_DESPAC", "C", 050, 000} )
	aAdd( aFds , {"TPD_VOLITE", "N", 005, 000} )
	aAdd( aFds , {"TPD_VOLPED", "N", 005, 000} )
	aAdd( aFds , {"TPD_PALLET", "C", 002, 000} )
	aAdd( aFds , {"TPD_SEPAR" , "N", 005, 000} )
	aAdd( aFds , {"TPD_PEDPRO", "D", 008, 000} )
	aAdd( aFds , {"TPD_STAPED", "C", 030, 000} )
	//aAdd( aFds , {"TPD_STAITE", "C", 020, 000} )

	oTempTbl4 := FWTemporaryTable():New( 'TPD' )
	oTempTbl4:SetFields( aFds )
	oTempTbl4:AddIndex( "cInd01", { "TPD_PALLET"},{"TPD_PEDIDO" } )
	//oTempTbl4:AddIndex( "cInd01", { "TPD_PEDIDO" } )
	oTempTbl4:Create()
	/********************************************************************************************************************************/

	cQry1 := ""
	cQry1 += " SELECT SC6.C6_FILIAL, SC6.C6_NUM, SC6.C6_QTDVEN, SC6.C6_VOLITEM, SC5.C5_VOLUME1, SC5.C5_PEDPROG, SC6.R_E_C_N_O_, ISNULL(SUM(ZZK_QUANT),0) AS 'QTDBIPADO' , SC6.C6_LOCAL AS 'ALMOXARIDADO' "
	cQry1 += " FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "
	cQry1 += " LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND  SC5.C5_FILIAL = SC6.C6_FILIAL AND SC5.C5_NUM = SC6.C6_NUM "
	cQry1 += " LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) ON (ZZK.D_E_L_E_T_ <> '*') AND ZZK.ZZK_FILIAL = SC6.C6_FILIAL AND ZZK_PEDIDO = SC6.C6_NUM AND ZZK_PRODUT = SC6.C6_PRODUTO "
	cQry1 += " WHERE (SC6.D_E_L_E_T_ <> '*') AND (SC6.C6_FILIAL  = '"+xFilial("SC6")+"') "
	cQry1 += "  AND SC6.C6_PRODUTO = '"+Alltrim(StrTran(StrTran(cCodPro, '.'), '-'))+"' "
	cQry1 += "  AND SC6.C6_NOTA    = '' "
	cQry1 += "  AND C5_APROVA      ='1' "
	cQry1 += " GROUP BY SC6.C6_FILIAL, SC6.C6_NUM, SC6.C6_QTDVEN, SC6.C6_VOLITEM, SC5.C5_VOLUME1, SC5.C5_PEDPROG, SC6.R_E_C_N_O_, SC6.C6_LOCAL "
	cQry1 += " ORDER BY SC6.C6_LOCAL, SC6.C6_NUM  "

	TCQuery cQry1 ALIAS "TCQ" NEW
	DbSelectArea("TCQ")

	While !Eof()
		cQry1 := ""
		cQry1 += "SELECT TOP 1 * "
		cQry1 += "FROM "+RetSqlName("ZZB")+" ZZB WITH (NOLOCK) "
		cQry1 += "WHERE ZZB.ZZB_FILIAL = '"+xFilial("ZZB")+"' "
		cQry1 += "  AND ZZB.D_E_L_E_T_ = '' "
		cQry1 += "  AND ZZB.ZZB_PEDIDO = '"+TCQ->C6_NUM+"' "
		//cQry1 += "  AND ZZB.ZZB_IDLOG IN('INC', 'ALT', 'EXC', 'LCA', 'LVE', 'LCR', 'LDI', 'APR') "
		cQry1 += "  AND ZZB.ZZB_IDLOG IN('LDI', 'APR') "
		cQry1 += "ORDER BY ZZB.ZZB_DATLOG+ZZB.ZZB_HORLOG DESC "
		TCQuery cQry1 ALIAS "TLG" NEW
		DbSelectArea("TLG")
		cLogPed := ""
		If TLG->ZZB_IDLOG $ 'INC'
			cLogPed := TLG->ZZB_IDLOG+' - Inclusão - '+SubStr(TLG->ZZB_DATLOG, 7, 2)+'/'+SubStr(TLG->ZZB_DATLOG, 5, 2)+'/'+SubStr(TLG->ZZB_DATLOG, 1, 4)+' - '+TLG->ZZB_HORLOG
		ElseIf TLG->ZZB_IDLOG $ 'ALT'
			cLogPed := TLG->ZZB_IDLOG+' - Alteração - '+SubStr(TLG->ZZB_DATLOG, 7, 2)+'/'+SubStr(TLG->ZZB_DATLOG, 5, 2)+'/'+SubStr(TLG->ZZB_DATLOG, 1, 4)+' - '+TLG->ZZB_HORLOG
		ElseIf TLG->ZZB_IDLOG $ 'EXC'
			cLogPed := TLG->ZZB_IDLOG+' - Exclusão - '+SubStr(TLG->ZZB_DATLOG, 7, 2)+'/'+SubStr(TLG->ZZB_DATLOG, 5, 2)+'/'+SubStr(TLG->ZZB_DATLOG, 1, 4)+' - '+TLG->ZZB_HORLOG
		ElseIf TLG->ZZB_IDLOG $ 'LCA'
			cLogPed := TLG->ZZB_IDLOG+' - Liberação Cadastro - '+SubStr(TLG->ZZB_DATLOG, 7, 2)+'/'+SubStr(TLG->ZZB_DATLOG, 5, 2)+'/'+SubStr(TLG->ZZB_DATLOG, 1, 4)+' - '+TLG->ZZB_HORLOG
		ElseIf TLG->ZZB_IDLOG $ 'LVE'
			cLogPed := TLG->ZZB_IDLOG+' - Liberação Vendas - '+SubStr(TLG->ZZB_DATLOG, 7, 2)+'/'+SubStr(TLG->ZZB_DATLOG, 5, 2)+'/'+SubStr(TLG->ZZB_DATLOG, 1, 4)+' - '+TLG->ZZB_HORLOG
		ElseIf TLG->ZZB_IDLOG $ 'LCR'
			cLogPed := TLG->ZZB_IDLOG+' - Liberação Credito - '+SubStr(TLG->ZZB_DATLOG, 7, 2)+'/'+SubStr(TLG->ZZB_DATLOG, 5, 2)+'/'+SubStr(TLG->ZZB_DATLOG, 1, 4)+' - '+TLG->ZZB_HORLOG
		ElseIf TLG->ZZB_IDLOG $ 'LDI'
			cLogPed := TLG->ZZB_IDLOG+' - Liberação Diretoria - '+SubStr(TLG->ZZB_DATLOG, 7, 2)+'/'+SubStr(TLG->ZZB_DATLOG, 5, 2)+'/'+SubStr(TLG->ZZB_DATLOG, 1, 4)+' - '+TLG->ZZB_HORLOG
		ElseIf TLG->ZZB_IDLOG $ 'APR'
			cLogPed := TLG->ZZB_IDLOG+' - Aprovação - '+SubStr(TLG->ZZB_DATLOG, 7, 2)+'/'+SubStr(TLG->ZZB_DATLOG, 5, 2)+'/'+SubStr(TLG->ZZB_DATLOG, 1, 4)+' - '+TLG->ZZB_HORLOG
		Endif

		DbSelectArea("TLG")
		DbCloseArea()

		RecLock("TPD", .t.)
		TPD->TPD_PEDIDO := TCQ->C6_NUM
		TPD->TPD_QTDE   := TCQ->C6_QTDVEN
		TPD->TPD_BORPED := Posicione("SZG", 2, xFilial("SZG")+substr(cnumemp,1,2)+TCQ->C6_NUM, "ZG_CODIGO")
		TPD->TPD_DESPAC := Posicione("SZB", 2, xFilial("SZB")+substr(cnumemp,1,2)+TCQ->C6_NUM, "ZB_CODIGO")+' - '+Posicione("SZA", 1, xFilial("SZA")+Posicione("SZB", 2, xFilial("SZB")+substr(cnumemp,1,2)+TCQ->C6_NUM, "ZB_CODIGO"), "ZA_DESCR")+' - '+DTOC(Posicione("SZA", 1, xFilial("SZA")+Posicione("SZB", 2, xFilial("SZB")+substr(cnumemp,1,2)+TCQ->C6_NUM, "ZB_CODIGO"), "ZA_PREVDSP"))
		TPD->TPD_VOLITE := TCQ->C6_VOLITEM
		TPD->TPD_VOLPED := TCQ->C5_VOLUME1
		TPD->TPD_PALLET := TCQ->ALMOXARIDADO
		TPD->TPD_SEPAR  := TCQ->QTDBIPADO
		TPD->TPD_PEDPRO := stod(TCQ->C5_PEDPROG)
		TPD->TPD_STAPED := cLogPed
		//TPD->TPD_STAITE := Iif(TCQ->DELETADO = '*', 'Item Excluido', '')
		MsUnLock()

		DbSelectArea("TCQ")
		DbSkip()
	Enddo

	DbSelectArea("TCQ")
	DbCloseArea()

Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fMosExp() - Mostra endereços da expedição
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fMosExp()
	If Empty(TPD->TPD_BORPED)
		If SubStr(TPD->TPD_STAPED, 1, 3) $ 'APR'
			If !lProEst
				oEndExp:lReadOnly := .f.
				//oEndExp:SetFocus()
				cEndExp := Space(09)
			Else
				oEndExp:lReadOnly := .t.
				cEndExp := Space(09)
			Endif
		ElseIf SubStr(TPD->TPD_STAPED, 1, 3) $ 'EXC' .or. Empty(SubStr(TPD->TPD_STAPED, 1, 3))
			oEndExp:lReadOnly := .t.
			cEndExp := Space(09)
		Else
			oEndExp:lReadOnly := .f.
			cEndExp := Space(09)
			//oEndExp:SetFocus()
		Endif
	Else
		DbSelectArea("SZG")
		DbSetOrder(2)
		DbSeek(xFilial("SZG")+substr(cnumemp,1,2)+TPD->TPD_PEDIDO, .t.)
		If Found()
			If Empty(SZG->ZG_LOCALIZ)
				If !lProEst
					oEndExp:lReadOnly := .f.
					//oEndExp:SetFocus()
					cEndExp := Space(09)
				Else
					oEndExp:lReadOnly := .t.
				Endif
			Else
				oEndExp:lReadOnly := .t.
				cEndExp := SZG->ZG_LOCALIZ
			Endif
		Endif
	Endif
	oBrwXXX:oBrowse:Refresh()
	oEndExp:Refresh()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fConNec() - Busca informações de todas as embalagens necessárias do produto
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fConNec()
	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de cVariable dos componentes                                 ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	//Local nOpc        := GD_INSERT+GD_DELETE+GD_UPDATE
	Private aCoBrwNec := {}
	Private aHoBrwNec := {}
	Private noBrwNec  := 0

	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de Variaveis Private dos Objetos                             ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	SetPrvt("oDlg2", "oBrwNec")

	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Definicao do Dialog e todos os seus componentes.                        ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	oTbl3()
	DbSelectArea("TNE")
	If RecCount() <= 0
		ApMsgStop('Não existe necessidade especifica para esse produto')
	Else
		oDlg3      := MSDialog():New( 226,455,396,838,"Necessidade por Embalagem",,,.F.,,,,,,.T.,,,.T. )
		DbSelectArea("TNE")
		DbSetOrder(1)
		DbGotop()
		oBrwNec    := MsSelect():New( "TNE", "", "", { {"TNE_PRODU", "", "Produto", "XXX999999999"}, {"TNE_EMBAL", "", "Embalagem", "99"}, {"TNE_TOTAL", "", "Total", "99999"} }, .F., , {000, 000, 080, 188}, , , oDlg3 )
		oDlg3:Activate( , , , .T.)
	Endif
	DbSelectArea("TNE")
	DbGotop()
	DbCloseArea()
	oTempTbl3:Delete()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTbl3() - Cria temporario para o Alias: TNE
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTbl3()

	Local aFds := {}
	//Local cTmp
	Local cQry := ""

	aAdd( aFds , {"TNE_PRODU" , "C", 012, 000} )
	aAdd( aFds , {"TNE_EMBAL" , "C", 002, 000} )
	aAdd( aFds , {"TNE_TOTAL" , "N", 005, 000} )

	oTempTbl3 := FWTemporaryTable():New( 'TNE' )
	oTempTbl3:SetFields( aFds )
	oTempTbl3:AddIndex( "cInd01", { "TNE_EMBAL" } )
	oTempTbl3:Create()
	/********************************************************************************************************************************/
	cQry := ""
	cQry += " SELECT ZZC_PRODUT AS PRODUTO, SUBSTRING(ZZC_PRODUT,11,2) AS EMB, SUM(ZZC.ZZC_QUANTI) AS QUANTIDADE "
	cQry += " FROM "+RetSqlName("ZZC")+"  ZZC WITH (NOLOCK)  "
	cQry += " LEFT OUTER JOIN "+RetSqlName("SZB")+" SZB WITH (NOLOCK) ON ZZC.ZZC_FILIAL  = SZB.ZB_FILIAL AND ZZC.ZZC_PEDIDO = SUBSTRING(SZB.ZB_PEDIDO, 3, 6) AND SZB.D_E_L_E_T_ = ''  "
	cQry += " LEFT OUTER JOIN "+RetSqlName("SZA")+" SZA WITH (NOLOCK) ON SZB.ZB_FILIAL  = SZA.ZA_FILIAL AND SZB.ZB_CODIGO = SZA.ZA_CODIGO AND SZA.D_E_L_E_T_ = ''  "
	cQry += " WHERE ZZC.ZZC_FILIAL = '"+xFilial("ZZC")+"' "
	cQry += " AND ZZC.D_E_L_E_T_ = '' "
	cQry += " AND ZZC.ZZC_DESPAC NOT IN('S')  "
	cQry += " AND ZZC.ZZC_SEPARA <>'S' "
	cQry += " AND ZZC.ZZC_GAVETA <>'' "
	cQry += " AND SUBSTRING(ZZC.ZZC_PRODUT, 1, 10) = '"+SubStr(Alltrim(StrTran(StrTran(cCodPro, '.'), '-')), 1, 10)+"' "
	cQry += " AND ISNULL(SZB.ZB_CODIGO, '') NOT IN('')  "
	cQry += " GROUP BY ZZC_PRODUT, SUBSTRING(ZZC_PRODUT,11,2) "
	cQry += " ORDER BY ZZC_PRODUT "

	TCQuery cQry ALIAS "NEC" NEW
	DbSelectArea("NEC")
	While !Eof()
		RecLock("TNE", .t.)
		TNE->TNE_PRODU  := NEC->PRODUTO
		TNE->TNE_EMBAL  := NEC->EMB
		TNE->TNE_TOTAL  := NEC->QUANTIDADE
		MsUnLock()
		DbSelectArea("NEC")
		DbSkip()
	Enddo
	DbSelectArea("NEC")
	DbGotop()
	DbCloseArea()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fCodPro() - Busca informações de tela após da digitação do código de barras ou do produto
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fCodPro()

	cCodPro   := StrTran(StrTran(cCodPro, '-'), '.')
	cOrdPro   := space(11)
	nQtdOrd   := 0
	nQtdSep3  := 0
	nQtdG3    := 0
	nQtdA3    := 0   //  Jose 05/07/2024
	nQtdSepA  := 0   //  Jose 05/07/2024
	nQtdDispA := 0   //  Jose 05/07/2024
	nQtdSepG  := 0
	nQtdSepG  := 0
	nQtd30    := 0
	nQtd03    := 0
	nQtdDispG := 0
	nQtdDis   := 0
	nQtdPro   := 0
	nQtdMark  := 0
	nQtdAvar  := 0  // MAA 20260430
	//oOrdPro:Refresh()
	//oQtdPro:Refresh()
	oQtdSep3:Refresh()
	oQtdG3:Refresh()
	oQtdSepG:Refresh()
	oQtdSepG:Refresh()
	oQtd30:Refresh()
	oQtd03:Refresh()
	oQtdDispG:Refresh()
	oQtdDis:Refresh()

	lProEst := !Empty(Posicione("SB2", 1, xFilial("SB2")+Posicione("SB1", 1, xFilial("SB1")+Alltrim(StrTran(StrTran(cCodPro, '.'), '-')), "B1_LOCPAD"), "B2_LOCALIZ"))
	If Empty(cCodPro)
		Return
	ElseIf SubStr(cCodPro, 1, 3) $ '789'
		DbSelectArea("SB1")
		DbSetOrder(5)
		DbSeek(xFilial("SB1")+Substr(cCodPro,1,12), .t.)
		If !Found()
			ApMsgStop("Codigo Inválido !!!")
			cCodPro := space(15)
			oCodPro:Refresh()
			cDesPro := space(30)
			oDesPro:Refresh()
			cLocPro := space(15)

			cLocProA := space(15) // Jose 21/08/2024
			cLocProG := space(15) // Jose 21/08/2024

			oLocPro:Refresh()
			oCodPro:SetFocus()
			cLocPro := space(15)

			cLocProA := space(15) // Jose 21/08/2024
			cLocProG := space(15) // Jose 21/08/2024

			oLocPro:Refresh()
			nQtd03 := 0
			oQtd03:Refresh()
			nQtd30 := 0
			oQtd30:Refresh()
			nQtdMark :=0
			oQtdMark:Refresh()
			nQtdAvar :=0 //MAA 20260430
			oQtdAvar:Refresh() //MAA 20260430
			Return(.f.)
		Else
			If !SB1->B1_TIPO $ 'PA'
				ApMsgStop("Codigo Inválido !!!")
				cCodPro := space(15)
				oCodPro:Refresh()
				cDesPro := space(30)
				oDesPro:Refresh()
				cLocPro := space(15)

				cLocProA := space(15) // Jose 21/08/2024
				cLocProG := space(15) // Jose 21/08/2024

				oLocPro:Refresh()
				oCodPro:SetFocus()
				cLocPro := space(15)

				cLocProA := space(15) // Jose 21/08/2024
				cLocProG := space(15) // Jose 21/08/2024

				oLocPro:Refresh()
				nQtd03 := 0
				oQtd03:Refresh()
				nQtd30 := 0
				oQtd30:Refresh()
				nQtdMark :=0
				oQtdMark:Refresh()
				nQtdAvar :=0 // MAA 20260430
				oQtdAvar:Refresh() // MAA 20260430
				Return(.f.)
			Else
				cCodPro := SB1->B1_COD
			Endif
		Endif
	Endif

	If Len(Alltrim(cCodPro)) == 14
		DbSelectArea("SC2")
		DbSetOrder(13)
		DbSeek(xFilial("SC2")+Alltrim(Substr(cCodPro,1,6)), .t.)
		If Found()
			While !(SC2->(Eof())) .AND. (XFilial("SC2") == SC2->C2_FILIAL) .AND. (Substr(cCodPro,1,6) == Alltrim(SC2->C2_LOTE))
				If Substr(cCodPro,7,2) == Substr(SC2->C2_PRODUTO,11,2)
					cCodPro := (SC2->C2_PRODUTO)
				Endif
				DbSelectArea("SC2")
				DbSkip()
			Enddo
		Else
			ApMsgStop("Codigo Inválido !!!")
			cCodPro := space(15)
			oCodPro:Refresh()
			cDesPro := space(30)
			oDesPro:Refresh()
			cLocPro := space(15)

			cLocProA := space(15) // Jose 21/08/2024
			cLocProG := space(15) // Jose 21/08/2024

			oLocPro:Refresh()
			oCodPro:SetFocus()
			cLocPro := space(15)

			cLocProA := space(15) // Jose 21/08/2024
			cLocProG := space(15) // Jose 21/08/2024

			oLocPro:Refresh()
			nQtd03 := 0
			oQtd03:Refresh()
			nQtd30 := 0
			oQtd30:Refresh()
			nQtdMark:=0
			oQtdMark:Refresh()
			nQtdAvar :=0 // MAA 20260430
			oQtdAvar:Refresh() // MAA 20260430
			Return(.f.)
		Endif
		DbSelectArea("SC2")
		DbCloseArea()
	Endif

	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+cCodPro, .t.)
	If !Found()
		ApMsgStop("Codigo Inválido !!!")
		cCodPro := space(18)
		oCodPro:Refresh()
		cDesPro := space(30)
		oDesPro:Refresh()
		cLocPro := space(15)

		cLocProA := space(15) // Jose 21/08/2024
		cLocProG := space(15) // Jose 21/08/2024

		oLocPro:Refresh()
		oCodPro:SetFocus()
		cLocPro := space(15)

		cLocProA := space(15) // Jose 21/08/2024
		cLocProG := space(15) // Jose 21/08/2024

		oLocPro:Refresh()
		nQtd03 := 0
		oQtd03:Refresh()
		nQtd30 := 0
		oQtd30:Refresh()
		nQtdMark:=0
		oQtdMark:Refresh()
		nQtdAvar :=0 // MAA 20260430
		oQtdAvar:Refresh() // MAA 20260430
		Return(.f.)
	Else
		If !SB1->B1_TIPO $ 'PA' .and. !Substr(Alltrim(cCodPro),4,2) $ '96.97.98.99'
			ApMsgStop("Codigo Inválido !!!")
			cCodPro := space(18)
			oCodPro:Refresh()
			cDesPro := space(30)
			oDesPro:Refresh()
			cLocPro := space(15)

			cLocProA := space(15) // Jose 21/08/2024
			cLocProG := space(15) // Jose 21/08/2024

			oLocPro:Refresh()
			oCodPro:SetFocus()
			cLocPro := space(15)

			cLocProA := space(15) // Jose 21/08/2024
			cLocProG := space(15) // Jose 21/08/2024

			oLocPro:Refresh()
			nQtd03 := 0
			oQtd03:Refresh()
			nQtd30 := 0
			oQtd30:Refresh()
			nQtdMark:=0
			oQtdMark:Refresh()
			nQtdAvar :=0 // MAA 20260430
			oQtdAvar:Refresh() // MAA 20260430
			Return(.f.)
		Else
			cCodPro := TransForm(SB1->B1_COD, "@R! XX 99.99.999-XX")
			oCodPro:Refresh()
			cDesPro := SB1->B1_DESC
			oDesPro:Refresh()
			DbSelectArea("SB2")
			DbSetOrder(1)
			DbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD, .t.)
			If !Found()
				cLocPro := space(15)

				cLocProA := space(15) // Jose 21/08/2024
				cLocProG := space(15) // Jose 21/08/2024

				oLocPro:Refresh()
				nQtd03 := 0
				oQtd03:Refresh()
				nQtdSep3 := 0
				oQtdSep3:Refresh()
				nQtdG3 := 0
				oQtdG3:Refresh()
				nQtdA3 := 0       //  Jose 05/07/2024
				oQtdA3:Refresh()  //  Jose 05/07/2024
				nQtdSepG := 0
				oQtdSepG:Refresh()
				nQtdSepA := 0      //  Jose 05/07/2024
				oQtdSepA:Refresh() //  Jose 05/07/2024
				nQtd30 := 0
				oQtd30:Refresh()
				nQtdMark:=0
				oQtdMark:Refresh()
				nQtdAvar :=0 // MAA 20260430
				oQtdAvar:Refresh() // MAA 20260430
			Else
				cLocPro := SB2->B2_LOCALIZ
				oLocPro:Refresh()
				nQtdSep3 := 0
				oQtdSep3:Refresh()
				nQtdG3 := 0
				oQtdG3:Refresh()
				nQtdA3 := 0         // Jose 05/07/2024
				oQtdA3:Refresh()    // Jose 05/07/2024
				nQtdSepG := 0
				oQtdSepG:Refresh()
				nQtdSepA := 0       // Jose 05/07/2024
				oQtdSepA:Refresh()  // Jose 05/07/2024
			Endif
			//---------    Acescentado por Jose 21/08/2024 ----------------------

			DbSelectArea("SB2")
			DbSetOrder(1)
			DbSeek(xFilial("SB2")+SB1->B1_COD+"A3", .t.)
			//       DbSeek("010108"+SB1->B1_COD+"A3", .t.) // jose 28/05/2025   só para testes
			If !Found()
				cLocProA := space(15)
				oLocPro:Refresh()
				nQtd03 := 0
				oQtd03:Refresh()
				nQtdSep3 := 0
				oQtdSep3:Refresh()
				nQtdG3 := 0
				oQtdG3:Refresh()
				nQtdA3 := 0       //  Jose 05/07/2024
				oQtdA3:Refresh()  //  Jose 05/07/2024
				nQtdSepG := 0
				oQtdSepG:Refresh()
				nQtdSepA := 0      //  Jose 05/07/2024
				oQtdSepA:Refresh() //  Jose 05/07/2024
				nQtd30 := 0
				oQtd30:Refresh()
				nQtdMark:=0
				oQtdMark:Refresh()
				nQtdAvar :=0 // MAA 20260430
				oQtdAvar:Refresh() // MAA 20260430
			Else
				cLocProA:= SB2->B2_LOCALIZ
				oLocPro:Refresh()
				nQtdSep3 := 0
				oQtdSep3:Refresh()
				nQtdG3 := 0
				oQtdG3:Refresh()
				nQtdA3 := 0         // Jose 05/07/2024
				oQtdA3:Refresh()    // Jose 05/07/2024
				nQtdSepG := 0
				oQtdSepG:Refresh()
				nQtdSepA := 0       // Jose 05/07/2024
				oQtdSepA:Refresh()  // Jose 05/07/2024
			Endif

			DbSelectArea("SB2")
			DbSetOrder(1)
			DbSeek(xFilial("SB2")+SB1->B1_COD+"G3", .t.)
			If !Found()
				cLocProG := space(15)
				oLocPro:Refresh()
				nQtd03 := 0
				oQtd03:Refresh()
				nQtdSep3 := 0
				oQtdSep3:Refresh()
				nQtdG3 := 0
				oQtdG3:Refresh()
				nQtdA3 := 0       //  Jose 05/07/2024
				oQtdA3:Refresh()  //  Jose 05/07/2024
				nQtdSepG := 0
				oQtdSepG:Refresh()
				nQtdSepA := 0      //  Jose 05/07/2024
				oQtdSepA:Refresh() //  Jose 05/07/2024
				nQtd30 := 0
				oQtd30:Refresh()
				nQtdMark:=0
				oQtdMark:Refresh()
			Else
				cLocProG:= SB2->B2_LOCALIZ
				oLocPro:Refresh()
				nQtdSep3 := 0
				oQtdSep3:Refresh()
				nQtdG3 := 0
				oQtdG3:Refresh()
				nQtdA3 := 0         // Jose 05/07/2024
				oQtdA3:Refresh()    // Jose 05/07/2024
				nQtdSepG := 0
				oQtdSepG:Refresh()
				nQtdSepA := 0       // Jose 05/07/2024
				oQtdSepA:Refresh()  // Jose 05/07/2024
			Endif

			//---------    Acrescentado por MAA 20260430 ----------------------
			SB2->(DbSetOrder(1))
			If .NOT. SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+"AV"))
				cLocProA := space(15)
				nQtd03 := 0
				nQtdSep3 := 0
				nQtdG3 := 0
				nQtdA3 := 0
				nQtdSepG := 0
				nQtdSepA := 0
				nQtd30 := 0
				nQtdMark:=0
				nQtdAvar :=0

				oLocPro:Refresh()
				oQtd03:Refresh()
				oQtdSep3:Refresh()
				oQtdG3:Refresh()
				oQtdA3:Refresh()
				oQtdSepG:Refresh()
				oQtdSepA:Refresh()
				oQtd30:Refresh()
				oQtdMark:Refresh()
				oQtdAvar:Refresh()
			Else
				cLocProA:= SB2->B2_LOCALIZ
				nQtdMark:=SB2->B2_QATU
				oQtdMark:Refresh()

				oLocPro:Refresh()
				nQtdSep3 := 0
				oQtdSep3:Refresh()
				nQtdG3 := 0
				oQtdG3:Refresh()
				nQtdA3 := 0         // Jose 05/07/2024
				oQtdA3:Refresh()    // Jose 05/07/2024
				nQtdSepG := 0
				oQtdSepG:Refresh()
				nQtdSepA := 0       // Jose 05/07/2024
				oQtdSepA:Refresh()  // Jose 05/07/2024
			Endif
			//---------   Fim do  Acrescentado por MAA 20260430 ----------------------

			//----------    Até aqui Jose  021/08/2024 ----------------------------------
		Endif
		cQry1 := ""
		cQry1 += " WITH TMP AS( "
		cQry1 += " SELECT B2_COD AS CODIGO, B2_LOCAL AS ALMOX, B2_QATU AS SALDOATUAL, 0 AS QTDESEPARADA "
		cQry1 += "   FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) "
		cQry1 += "  WHERE SB2.D_E_L_E_T_ ='' "
		cQry1 += "    AND B2_FILIAL = '"+xFilial("SB2")+"' "
		cQry1 += "    AND B2_LOCAL IN('03','30','G3','P1','P2','G1','A3') "
		cQry1 += "    AND B2_COD ='"+SB1->B1_COD+"' "
		cQry1 += " UNION ALL "
		cQry1 += " SELECT C6_PRODUTO AS CODIGO, C6_LOCAL AS ALMOX, 0 AS SALDOATUAL, SUM(ZZK_QUANT) AS QTDESEPARADA "
		cQry1 += "   FROM SC6010 SC6 WITH(NOLOCK) "
		cQry1 += "        LEFT OUTER JOIN ZZK010 ZZK ON ZZK_FILIAL = C6_FILIAL AND ZZK_PRODUT = C6_PRODUTO AND ZZK_PEDIDO = C6_NUM AND ZZK.D_E_L_E_T_ ='' "
		cQry1 += "  WHERE SC6.D_E_L_E_T_ ='' "
		cQry1 += "    AND C6_FILIAL ='"+xFilial("SC6")+"' "
		cQry1 += "    AND C6_PRODUTO ='"+SB1->B1_COD+"' "
		cQry1 += "    AND C6_NOTA ='' "
		cQry1 += " GROUP BY C6_PRODUTO, C6_LOCAL) "
		cQry1 += " SELECT CODIGO, ALMOX, SUM(SALDOATUAL) AS SALDOTOTAL, SUM(QTDESEPARADA) AS QTDESEPARADA  "
		cQry1 += " FROM TMP "
		cQry1 += " GROUP BY CODIGO, ALMOX "

		TCQuery cQry1 ALIAS "TCQ" NEW
		DbSelectArea("TCQ")

		While !Eof()
			If TCQ->ALMOX $ 'P1|P2'
				nQtdPro := nQtdPro+TCQ->SALDOTOTAL
				oQtdPro:Refresh()
			Elseif TCQ->ALMOX == '03'
				nQtd03   := (TCQ->SALDOTOTAL)
				nQtdSep3 := (TCQ->QTDESEPARADA)
				nQtdDis  := TCQ->SALDOTOTAL-TCQ->QTDESEPARADA
				oQtd03:Refresh()
				oQtdSep3:Refresh()
				oQtdDis:Refresh()
			Elseif TCQ->ALMOX == '30'
				nQtd30   := (TCQ->SALDOTOTAL)
				oQtd30:Refresh()
			Elseif SUBSTR(TCQ->ALMOX,1,1) == 'G'
				nQtdG3   := (TCQ->SALDOTOTAL)
				nQtdSepG := (TCQ->QTDESEPARADA)
				nQtdDispG:= TCQ->SALDOTOTAL-TCQ->QTDESEPARADA
				oQtdG3:Refresh()
				oQtdSepG:Refresh()
				oQtdDispG:Refresh()
			Elseif TCQ->ALMOX == 'A3'              // Jose 05/07/2024
				nQtdA3   := (TCQ->SALDOTOTAL)      // Jose 05/07/2024
				nQtdSepA := (TCQ->QTDESEPARADA)    // Jose 05/07/2024
				nQtdDispA:= TCQ->SALDOTOTAL-TCQ->QTDESEPARADA  // Jose 05/07/2024
				oQtdA3:Refresh()       // Jose 05/07/2024
				oQtdSepA:Refresh()     // Jose 05/07/2024
				oQtdDispA:Refresh()    // Jose 05/07/2024
			Endif

			DbSelectArea("TCQ")
			DbSkip()
		Enddo
	Endif

	DbSelectArea("TCQ")
	DbCloseArea()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTbl1() - Cria temporario para o Alias: ZT1
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTbl1(nOpcTbl)
	Local aFds 	 := {}
	Local cRETFAL := GetMv("MV_RETFAL")
	Local cQry1   := ""
	Local cAuxPed := ""


	Aadd( aFds , {"ZT1_FLAG"  , "C", 001, 000} )
	Aadd( aFds , {"ZT1_MARCA" , "C", 002, 000} )
	Aadd( aFds , {"ZT1_BORDES", "C", 006, 000} )
	Aadd( aFds , {"ZT1_BORPED", "C", 006, 000} )
	Aadd( aFds , {"ZT1_REGIAO", "C", 030, 000} )
	Aadd( aFds , {"ZT1_PREVIS", "D", 008, 000} )
	Aadd( aFds , {"ZT1_PEDIDO", "C", 006, 000} )
	Aadd( aFds , {"ZT1_QUANTI", "N", 007, 000} )
	Aadd( aFds , {"ZT1_LOCALI", "C", 015, 000} )
	Aadd( aFds , {"ZT1_GAVETA", "N", 005, 000} )
	Aadd( aFds , {"ZT1_EXCLUI", "C", 001, 000} )

	/********************************************************************************************************************************/
	/*** BLOCO ALTERADO EM 28/10/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
	If Select("ZT1") > 0
		DbSelectArea("ZT1")
		DbCloseArea()
	Endif
	oTempTbl1 := FWTemporaryTable():New( 'ZT1' )
	oTempTbl1:SetFields( aFds )
	oTempTbl1:AddIndex( "cInd01", { "ZT1_PREVIS" } )
	oTempTbl1:Create()
	/********************************************************************************************************************************/
	cQry1 := ""
	cQry1 += "SELECT ISNULL(SZB.ZB_CODIGO, '') AS DESPACHO, ISNULL(SZA.ZA_DESCR, '') AS REGIAO, ISNULL(ZA_PREVDSP, '') AS PREVISAO, ZZC.ZZC_PEDIDO AS PEDIDO, ZZC.ZZC_QUANTI AS QUANTIDADE, SZA.ZA_FLAG AS FLAG "
	cQry1 += "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
	cQry1 += "LEFT OUTER JOIN "+RetSqlName("SZB")+" SZB WITH (NOLOCK) ON ZZC.ZZC_FILIAL  = SZB.ZB_FILIAL AND ZZC.ZZC_PEDIDO = SUBSTRING(SZB.ZB_PEDIDO, 3, 6) AND SZB.D_E_L_E_T_ = '' "
	cQry1 += "LEFT OUTER JOIN "+RetSqlName("SZA")+" SZA WITH (NOLOCK) ON SZB.ZB_FILIAL  = SZA.ZA_FILIAL AND SZB.ZB_CODIGO = SZA.ZA_CODIGO AND SZA.D_E_L_E_T_ = '' "
	cQry1 += "WHERE ZZC.ZZC_FILIAL  = '"+xFilial("ZZC")+"' "
	cQry1 += "  AND ZZC.D_E_L_E_T_ = '' "
	cQry1 += "  AND ZZC.ZZC_DESPAC NOT IN('S') "//AND ZZC.ZZC_RESERV < ZZC.ZZC_QUANTI "
	cQry1 += "  AND ZZC.ZZC_PRODUT = '"+StrTran(StrTran(cCodPro, '-'), '.')+"' "
	cQry1 += "  AND ISNULL(SZB.ZB_CODIGO, '') NOT IN('') "
	cQry1 += "ORDER BY 3, 1, 4 "
	TCQuery cQry1 ALIAS "TCQ" NEW
	DbSelectArea("TCQ")
	DbGoTop()
	While !Eof()
		cBorPed := Posicione("SZG", 2, xFilial("SZG")+'01'+TCQ->PEDIDO, "ZG_CODIGO")
		If !Empty(cBorPed)
			DbSelectArea("ZZC")
			DbSetOrder(1)
			DbSeek(xFilial("ZZC")+cBorPed+TCQ->PEDIDO+StrTran(StrTran(cCodPro, '-'), '.'), .t.)
			If !Found()
				RecLock("ZZC", .t.)
				ZZC->ZZC_FILIAL := xFilial("ZZC")
				ZZC->ZZC_BORDER := Posicione("SZG", 2, xFilial("SZG")+'01'+TCQ->PEDIDO, "ZG_CODIGO")
				ZZC->ZZC_PEDIDO := TCQ->PEDIDO
				ZZC->ZZC_PRODUT := StrTran(StrTran(cCodPro, '.'), '-')
				ZZC->ZZC_QUANTI := TCQ->QUANTIDADE
				ZZC->ZZC_RETIRA := 0
				ZZC->ZZC_VOLUME := fCalVol(StrTran(StrTran(cCodPro, '.'), '-'), TCQ->QUANTIDADE)
				ZZC->ZZC_VOLRET := 0
				ZZC->ZZC_CARGA  := TCQ->DESPACHO
				ZZC->ZZC_OCUPAC := 0
				ZZC->ZZC_DESPAC := ""
				ZZC->ZZC_GAVETA := ""
				ZZC->ZZC_SEPARA := ""
				ZZC->ZZC_TPINCL := "B"
				MsUnLock()
			Else
				If ZZC->ZZC_SEPARA <> 'S'
					If !Empty(ZZC->ZZC_GAVETA)
						RecLock("ZT1", .t.)
						ZT1->ZT1_FLAG   := TCQ->FLAG
						ZT1->ZT1_MARCA  := space(02)
						ZT1->ZT1_BORDES := TCQ->DESPACHO
						ZT1->ZT1_BORPED := cBorPed
						ZT1->ZT1_REGIAO := TCQ->REGIAO
						ZT1->ZT1_PREVIS := STOD(TCQ->PREVISAO)
						ZT1->ZT1_PEDIDO := TCQ->PEDIDO
						//ZT1->ZT1_QUANTI := Iif(GetMv("MV_RETFAL") $ 'S', ZZC->ZZC_QUANTI, (ZZC->ZZC_QUANTI - ZZC->ZZC_RESERV))
						ZT1->ZT1_QUANTI := Iif(Alltrim(cRETFAL) == 'S', ZZC->ZZC_QUANTI, (ZZC->ZZC_QUANTI - ZZC->ZZC_RETIRA))
						ZT1->ZT1_LOCALI := Posicione("SZG", 1, xFilial("SZG")+ZZC->ZZC_BORDER+'01'+TCQ->PEDIDO, "ZG_LOCALIZ")
						ZT1->ZT1_GAVETA := Posicione("SC5", 1, xFilial("SC5")+ZZC->ZZC_PEDIDO, "C5_VOLUME1")
						ZT1->ZT1_EXCLUI := 'N'
						MsUnLock()
						cAuxPed += TCQ->PEDIDO+"', '"
					Endif
				Endif
			Endif
		Else
			DbSelectArea("ZZC")
			DbSetOrder(4)
			DbSeek(xFilial("ZZC")+TCQ->DESPACHO+TCQ->PEDIDO, .t.)
			If Found()
				While !Eof() .and. (ZZC->ZZC_FILIAL == xFilial("ZZC")) .and. ZZC->ZZC_CARGA == TCQ->DESPACHO .and. ZZC->ZZC_PEDIDO == TCQ->PEDIDO
					If Alltrim(ZZC->ZZC_PRODUT) == Alltrim(StrTran(StrTran(cCodPro, '.'), '-'))
						If ZZC->ZZC_SEPARA <> 'S'
							If !Empty(ZZC->ZZC_GAVETA)
								RecLock("ZT1", .t.)
								ZT1->ZT1_FLAG   := TCQ->FLAG
								ZT1->ZT1_MARCA  := space(02)
								ZT1->ZT1_BORDES := TCQ->DESPACHO
								ZT1->ZT1_BORPED := cBorPed
								ZT1->ZT1_REGIAO := TCQ->REGIAO
								ZT1->ZT1_PREVIS := STOD(TCQ->PREVISAO)
								ZT1->ZT1_PEDIDO := TCQ->PEDIDO
								//ZT1->ZT1_QUANTI := Iif(GetMv("MV_RETFAL") $ 'S', ZZC->ZZC_QUANTI, (ZZC->ZZC_QUANTI - ZZC->ZZC_RESERV))
								ZT1->ZT1_QUANTI := Iif(Alltrim(cRETFAL)== 'S', ZZC->ZZC_QUANTI, (ZZC->ZZC_QUANTI - ZZC->ZZC_RETIRA))
								ZT1->ZT1_LOCALI := Posicione("SZG", 1, xFilial("SZG")+ZZC->ZZC_BORDER+'01'+TCQ->PEDIDO, "ZG_LOCALIZ")
								ZT1->ZT1_GAVETA := Posicione("SC5", 1, xFilial("SC5")+ZZC->ZZC_PEDIDO, "C5_VOLUME1")
								ZT1->ZT1_EXCLUI := 'N'
								MsUnLock()
								cAuxPed += TCQ->PEDIDO+"', '"
							Endif
						Endif
					Endif
					DbSelectArea("ZZC")
					DbSkip()
				Enddo
			Endif
		Endif
		DbSelectArea("TCQ")
		DbSkip()
	Enddo
	DbSelectArea("TCQ")
	DbCloseArea()
	DbSelectArea("ZT1")
	DbGoTop()
	If nOpcTbl == 2
		oBrwDes:oBrowse:Refresh()
	Endif
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTbl2() - Cria temporario para o Alias: ZT2
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTbl2(nOpcTbl)

	Local aFds := {}
	Local cQry1 :=""
	//Local cRETFAL := GetMv("MV_RETFAL")
	//Local cTmp

	Aadd( aFds , {"ZT2_MARCA" , "C", 002, 0} ) //Flag de marcação
	Aadd( aFds , {"ZT2_NUMBOR", "C", 006, 0} ) //Numero do Bordero de Pedidos
	aadd( aFds , {"ZT2_EMISSA", "D", 008, 0} ) //Emissão do Bordero de Pedidos
	aadd( aFds , {"ZT2_PEDIDO", "C", 006, 0} ) //Pedido
	aadd( aFds , {"ZT2_QUANTI", "N", 007, 0} ) //Quantidade do Produto
	aadd( aFds , {"ZT2_LOCEXP", "C", 009, 0} ) //Localização na expedição
	// ---- Acrescentado por Jose 21/08/2024 ----------------------------
	aadd( aFds , {"ZT2_LOCAL",  "C", 009, 0} ) //Local Pedido
	//----- Até Aqui Jose 21/08/2024 ------------------------------------
	aadd( aFds , {"ZT2_GAVETA", "N", 005, 0} ) //Vol. Pedido

	/********************************************************************************************************************************/
	/*** BLOCO ALTERADO EM 28/10/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
	If Select("ZT2") > 0
		DbSelectArea("ZT2")
		DbCloseArea()
	Endif

	oTempTbl2 := FWTemporaryTable():New( 'ZT2' )
	oTempTbl2:SetFields( aFds )
	oTempTbl2:Create()

	/********************************************************************************************************************************/
	//Cleber (15/09/09) => inclusão no Join da sentença  AND (ZZC_BORDER = ZG_CODIGO) para que não traga
	//itens de borderô que foi excluído manualmente.

	cQry1 := ""
	cQry1 += " SELECT ZF_FILIAL, ZF_CODIGO AS BORDERO, ISNULL(SZF.ZF_EMISSAO, '') AS EMISSAO, C6_NUM AS PEDIDO, C6_PRODUTO, C6_QTDVEN AS QUANTIDADE , SUM(ISNULL(ZZK_QUANT,0)) AS ZZK_QUANT, ZG_LOCALIZ AS LOCALIZ, C5_VOLUME1 AS VOLUME, C6_LOCAL AS LOCALL  "
	cQry1 += " FROM "+RetSqlName("SZF")+" SZF WITH (NOLOCK) "
	cQry1 += " LEFT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH(NOLOCK) ON ZG_FILIAL = ZF_FILIAL AND ZG_CODIGO = ZF_CODIGO AND SZG.D_E_L_E_T_ ='' "
	cQry1 += " LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH(NOLOCK) ON C5_FILIAL = ZG_FILIAL AND C5_NUM = SUBSTRING(ZG_PEDIDO,3,6) AND SC5.D_E_L_E_T_ ='' "
	cQry1 += " LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH(NOLOCK) ON C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM AND SC6.D_E_L_E_T_ ='' "
	cQry1 += " LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH(NOLOCK) ON ZZK_FILIAL = C6_FILIAL AND ZZK_PEDIDO = C6_NUM AND ZZK_PRODUT = C6_PRODUTO AND ZZK.D_E_L_E_T_ ='' "
	cQry1 += " WHERE SZF.D_E_L_E_T_ ='' "
	cQry1 += " AND ZF_FLAG = 'D' "
	cQry1 += " AND ZF_FILIAL= '"+xFilial("SZF")+"' "
	cQry1 += " AND C5_APROVA ='1' "
	cQry1 += " AND C6_PRODUTO = '"+StrTran(StrTran(cCodPro, '-'), '.')+"' "
	cQry1 += " GROUP BY ZF_FILIAL, ZF_CODIGO, ZF_EMISSAO, C6_NUM, C6_PRODUTO, C6_QTDVEN, ZG_LOCALIZ, C5_VOLUME1, C6_LOCAL "
	cQry1 += " HAVING  SUM(ISNULL(ZZK_QUANT,0))=0 "
	cQry1 += " ORDER BY ZF_FILIAL, ZF_CODIGO, C6_NUM "

	TCQuery cQry1 ALIAS "TCQ" NEW

	DbSelectArea("TCQ")
	DbGoTop()

	While !Eof()
		RecLock("ZT2", .t.)
		ZT2->ZT2_MARCA  := '  '
		ZT2->ZT2_NUMBOR := TCQ->BORDERO
		ZT2->ZT2_EMISSA := CTOD(SubStr(TCQ->EMISSAO, 7, 2)+'/'+SubStr(TCQ->EMISSAO, 5, 2)+'/'+SubStr(TCQ->EMISSAO, 1, 4))
		ZT2->ZT2_PEDIDO := TCQ->PEDIDO
		ZT2->ZT2_QUANTI := TCQ->QUANTIDADE
		ZT2->ZT2_LOCEXP := TCQ->LOCALIZ
		ZT2->ZT2_LOCAL  := TCQ->LOCALL // jOSE 21/08/2024
		ZT2->ZT2_GAVETA := TCQ->VOLUME
		MsUnLock()
		DbSelectArea("TCQ")
		DbSkip()
	Enddo
	DbSelectArea("TCQ")
	DbCloseArea()

	DbSelectArea("ZT2")
	DbGoTop()

	If nOpcTbl == 2
		oBrwPed:oBrowse:Refresh()
	Endif

Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ ZT1Mark() - Funcao para marcar o MsSelect
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function ZT1Mark()
	Local lDesMarca := ZT1->(IsMark("ZT1_MARCA", cMarca))
	//Local nOpca     := 0
	Private nGetQtd := ZT1->ZT1_QUANTI

	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de Variaveis Private dos Objetos                             ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	SetPrvt("oFont3", "oDlg2", "oSay1", "oGetQtd", "oBtn1")

	RecLock("ZT1", .F.)
	If lDesmarca
		ZT1->ZT1_MARCA := "  "
		nQtdMark -= nGetQtd
	Else
		ZT1->ZT1_MARCA  := cMarca
		ZT1->ZT1_QUANTI := nGetQtd
		nQtdMark += nGetQtd
	Endif
	oQtdMark:Refresh()
	ZT1->(MsUnlock())
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ ZT2Mark() - Funcao para marcar o MsSelect
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function ZT2Mark()
	Local lDesMarca := ZT2->(IsMark("ZT2_MARCA", cMarca))
	//Local nOpca     := 0
	Private nGetQtd := ZT2->ZT2_QUANTI

	RecLock("ZT2", .F.)
	If lDesmarca
		ZT2->ZT2_MARCA := "  "
		nQtdMark -= nGetQtd
	Else
		ZT2->ZT2_MARCA  := cMarca
		ZT2->ZT2_QUANTI := nGetQtd
		nQtdMark += nGetQtd
	Endif
	oQtdMark:Refresh()
	ZT2->(MsUnlock())
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fOrdPro() - Funcao para carregar dados da Ordem de Produção
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fOrdPro()
	Local cQry1     := ""
	Local nOpcEnv   := 0
	Private aAptOrd := {}

	SetPrvt("oDlgSel", "oSayMsg", "oBrwSel", "oBtnCon")

	If Empty(cOrdPro)
		Return
	Endif

	cQry1 += "SELECT ZZK_LOTE "
	cQry1 += "FROM "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) "
	cQry1 += "WHERE ZZK.ZZK_FILIAL = '"+xFilial("ZZA")+"' "
	cQry1 += "  AND ZZK.D_E_L_E_T_ = ''
	cQry1 += "  AND ZZK.ZZK_CODIGO = '"+cOrdPro+"'
	cQry1 += "  AND ZZK.ZZK_PRODUT = '"+StrTran(StrTran(cCodPro, "."), "-")+"' "
	//cQry1 += "SELECT * "
	//cQry1 += "FROM "+RetSqlName("ZZA")+" ZZA WITH (NOLOCK) "
	//cQry1 += "WHERE ZZA.ZZA_FILIAL = '"+xFilial("ZZA")+"' "
	//cQry1 += "  AND ZZA.D_E_L_E_T_ = '' "
	//cQry1 += "  AND ZZA.ZZA_ORDEM  = '"+SubStr(cOrdPro, 1, 11)+"' "
	TCQuery cQry1 ALIAS "TCQ" NEW
	DbSelectArea("TCQ")
	DbGoTop()
	If !Empty(TCQ->ZZK_LOTE)
		cCodLot := TCQ->ZZK_LOTE
		aAptOrd := {}
		DbSelectArea("TCQ")
		DbCloseArea()
		cQry1 := ""
		cQry1 += "SELECT ZZA_QUANT,ZZA_FLAG,ZZA_RAMPA,ZZA_SEQENV "
		cQry1 += "FROM "+RetSqlName("ZZA")+" ZZA WITH (NOLOCK) "
		cQry1 += "WHERE ZZA.ZZA_FILIAL = '"+xFilial("ZZA")+"' "
		cQry1 += "  AND ZZA.D_E_L_E_T_ = ''
		cQry1 += "  AND ZZA.ZZA_LOTE   = '"+cCodLot+"'
		cQry1 += "  AND ZZA.ZZA_PRODUT = '"+StrTran(StrTran(cCodPro, "."), "-")+"'
		cQry1 += "  AND ZZA.ZZA_RAMPA <> 'S' "
		cQry1 += "  AND SUBSTRING(ZZA.ZZA_PRODUT, 11, 2) <> '00'
		TCQuery cQry1 ALIAS "TCQ" NEW
		DbSelectArea("TCQ")
		DbGoTop()
		While !Eof()
			cTxtSta := ''
			If TCQ->ZZA_QUANT == 0
				cTxtSta := 'ORDEM DE PRODUÇÃO INICIADA'
			Else
				If TCQ->ZZA_FLAG == '6'
					cTxtSta := 'ORDEM DE PRODUÇÃO INICIADA'
				ElseIf TCQ->ZZA_FLAG == '5'
					cTxtSta := 'ORDEM DE PRODUÇÃO BAIXADA'
				ElseIf TCQ->ZZA_FLAG == '7'
					cTxtSta := 'ENCERRADA PARCIAL'
				ElseIf TCQ->ZZA_FLAG == '8'
					cTxtSta := 'ENCERRADA TOTAL'
				Endif
				If TCQ->ZZA_RAMPA == 'S'
					cTxtSta := 'DISTRIBUIDA'
				Endif
				aAdd(aAptOrd, {TCQ->ZZA_SEQENV, TCQ->ZZA_QUANT, cTxtSta, TCQ->ZZA_FLAG})
			Endif
			DbSelectArea("TCQ")
			DbSkip()
		Enddo
		DbSelectArea("TCQ")
		DbCloseArea()
		aOrdPro := {}
		If Len(aAptOrd) <= 0
			ApMsgStop('Não existe Ordem de Produção para distribuir!')
			cOrdPro := space(11)
			cCodLot := space(06)
			//oOrdPro:Refresh()
			//oOrdPro:SetFocus()
			Return
		ElseIf Len(aAptOrd) == 1
			If aAptOrd[1][2] <= 0
				ApMsgStop('Ordem de produção ainda não encerrada pelo envase!')
				cOrdPro := space(11)
				cCodLot := space(06)
				//oOrdPro:Refresh()
				//oOrdPro:SetFocus()
				Return
			ElseIf aAptOrd[1][2] > 0
				If aAptOrd[1][4] $ '7.8'
					nQtdOrd := aAptOrd[1][2]
					oQtdPro:Refresh()
					aAdd(aOrdPro, {aAptOrd[1][1], aAptOrd[1][2]})
					Return
				Else
					ApMsgStop('Ordem de Produção não pode ser conferida, STATUS: '+aAptOrd[1][3])
					cOrdPro := space(11)
					cCodLot := space(06)
					//oOrdPro:Refresh()
					//oOrdPro:SetFocus()
					Return
				Endif
			Endif
		Else
			/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
             ±± Definicao do Dialog e todos os seus componentes.                        ±±
			Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
			oDlgSel    := MSDialog():New( 088, 232, 297, 525, "Ordens de produções apontadas", , , .F., , , , , , .T., , , .T. )
			oSayMsg    := TSay():New( 078, 000, {|| "Selecione as ordens de produção para serem conferidas."}, oDlgSel, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 216, 008)
			oTblSel()
			DbSelectArea("TMP")
			oBrwSel    := MsSelect():New( "TMP", "MARCA", "", { {"MARCA", "", "", ""}, {"SEQENV", "", "Seq.", "99"}, {"QUANT", "", "Quantidade", "@E 999999"}, {"Status", "", "Status", "@!"} }, .F., cMarca, {000, 000, 076, 148}, , , oDlgSel )
			oBrwSel:bAval := {||TMPMark()}
			oBrwSel:oBrowse:lHasMark := .T.
			oBrwSel:oBrowse:lCanAllmark := .F.
			oBtnCon    := TButton():New( 088, 110, "Confirma", oDlgSel, {|| nOpcEnv := 1, oDlgSel:End() }, 037, 012, , , , .T., , "", , , , .F. )

			oDlgSel:Activate(, , , .T.)
			If nOpcEnv == 1
				nQtdOrd := 0
				DbSelectArea("TMP")
				DbGoTop()
				While !Eof()
					If TMP->(IsMark("MARCA", cMarca))
						nQtdOrd += TMP->QUANT
						aAdd(aOrdPro, {TMP->SEQENV, TMP->QUANT})
					Endif
					DbSelectArea("TMP")
					DbSkip()
				Enddo
				oQtdPro:Refresh()
			Else
				nQtdOrd := 0
				oQtdPro:Refresh()
				cOrdPro := space(11)
				cCodLot := space(06)
				//oOrdPro:Refresh()
				//oOrdPro:SetFocus()
			Endif
			DbSelectArea("TMP")
			DbCloseArea()
			oTempTbl5:Delete()
			Return
		Endif
	Else
		ApMsgStop('Código de Pallet inválido!')
		DbSelectArea("TCQ")
		DbCloseArea()
		cOrdPro := space(11)
		//oOrdPro:Refresh()
		//oOrdPro:SetFocus()
		Return
	Endif
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTblSel() - Cria temporario para o Alias: TMP
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTblSel()
	Local aFds := {}
	//Local cTmp
	Local nY

	aAdd( aFds , {"MARCA"  , "C", 002,000} )
	aAdd( aFds , {"SEQENV" , "C", 002,000} )
	aAdd( aFds , {"QUANT"  , "N", 006,000} )
	aAdd( aFds , {"STATUS" , "C", 020,000} )
	aAdd( aFds , {"FLAG"   , "C", 001,000} )

	/********************************************************************************************************************************/
	/*** BLOCO ALTERADO EM 28/10/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
	/*     cTmp := CriaTrab( aFds, .T. )
       Use (cTmp) Alias TMP New Exclusive
       Index On SEQENV To (cTmp)
	*/
	//cTmp := U_NovoArqTrab("dbf")
	//dbcreate(cTmp+".dbf", aFds, "DBFCDXADS")
	//Use (cTmp+".Dbf") Alias "TMP" VIA "DBFCDXADS" New Exclusive
	//Index On SEQENV To (cTmp)
	oTempTbl5 := FWTemporaryTable():New( 'TMP' )
	oTempTbl5:SetFields( aFds )
	oTempTbl5:AddIndex( "cInd01", { "SEQENV" } )
	oTempTbl5:Create()
	/********************************************************************************************************************************/

	For nY := 1 To Len(aAptOrd)
		RecLock("TMP", .t.)
		TMP->MARCA  := space(02)
		TMP->SEQENV := aAptOrd[nY][1]
		TMP->QUANT  := aAptOrd[nY][2]
		TMP->STATUS := aAptOrd[nY][3]
		TMP->FLAG   := aAptOrd[nY][4]
		MsUnLock()
	Next
	DbSelectArea("TMP")
	DbGoTop()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ TMPMark() - Funcao para marcar o MsSelect
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function TMPMark()
	Local lDesMarca := TMP->(IsMark("MARCA", cMarca))
	RecLock("TMP", .F.)
	If lDesmarca
		TMP->MARCA := "  "
	Else
		TMP->MARCA  := cMarca
	Endif
	TMP->(MsUnlock())
	oBrwSel:oBrowse:Refresh()
Return

Static Function fAbrLoc() // jOSE 24/04/2025  aqui
	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de cVariable dos componentes                                 ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	Private cGetCod := Space(15)
	Private cMarca  := GetMark()
	Private cNumOrd := "00"
	Private lCheck  :=.T.

	If Empty(StrTran(StrTran(cCodPro, '.'), '-'))
		MsgStop("Favor informar o código do produto...")
		Return
	Endif
	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	SetPrvt("oFont1", "oDlg2", "oGetCod", "oGetDes", "oBtnVol", "oBtnCon", "oBrwLoc", "oBtnDel","oBtnAlt")

	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	oFont1     := TFont():New( "MS Sans Serif",0,-16,,.F.,0,,400,.F.,.F.,,,,,, )
	oDlg4      := MSDialog():New( 187,392,461,660,"Localização provisória",,,.F.,,,,,,.T.,,,.T. )
	oGetCod    := TGet():New( 004,004,{|u| If(PCount()>0,cGetCod:=u,cGetCod)},oDlg4,060,015,'',,CLR_BLACK,CLR_WHITE,oFont1,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGetCod",,)
	oBtnVol    := TButton():New( 120,092,"Voltar",oDlg4,{ || oDlg4:End() },037,015,,,,.T.,,"",,,,.F. )
	//oBtnCon    := TButton():New( 120,048,"Confirmar",oDlg4,{ || fGrvLoc() },037,012,,,,.T.,,"",,,,.F. )
	oTblLoc()

	DbSelectArea("LOC")
	DbSetOrder(1)
	oBrwLoc    := MsSelect():New( "LOC","LOC_DEL","",{ {"LOC_DEL", "", "", ""}, {"LOC_ORD", "", "Ordem", "@!"}, {"LOC_LOC", "", "Localizacao", "@!"}},.F.,cMarca,{024,004,084,128},,, oDlg4 )
	oBrwLoc:bAval := {||TMPLocM()}
	oBrwLoc:oBrowse:lHasMark := .T.
	oBrwLoc:oBrowse:lCanAllmark := .F.
	DbSelectArea("SZW")
	DbSetOrder(4)
	DbSeek(xFilial("SZW")+'BRFATA03  '+RetCodUsr()+substr(cNumEmp,1,2)+substr(cNumEmp,FWSizeFilial()+1,2), .t.)
	If Found()
		cAcessos := SZW->ZW_ACESSOS
	Endif
	If SubStr(cAcessos, 10, 1) $ '*' //Usuário Ativo
	Endif
	If SubStr(cAcessos, 9, 1) $ '*' // booes da Localização Provisória
		oBtnDel    := TButton():New  ( 088,004,"Deleta"  ,oDlg4,{ || fDelIte() },037,012,,,,.T.,,"",,,,.F. )
		oBtnAlt    := TButton():New  ( 088,048,"Altera"  ,oDlg4,{ || fAltIte() },037,012,,,,.T.,,"",,,,.F. )
		oBtnAdd    := TButton():New  ( 088,092,"Adiciona",oDlg4,{ || fAddIte() },037,012,,,,.T.,,"",,,,.F. )
	Endif
	oCBox1     := TCheckBox():New( 108,090,"Etiqueta",{|u| If(PCount() > 0, lCheck := u, lCheck)},oDlg4,080,012,,,oFont,,CLR_BLUE ,CLR_WHITE,,.t.,"Imprime Etiqueta Localização",, )
	oGetCod:SetFocus()
	oDlg4:Activate(,,,.T.)
	DbSelectArea("LOC")
	DbCloseArea()
Return


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fIEtProv() - Impressão da Etiqueta com a localização
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fIEtProv()  // Jose 24/04/2025

	//Verificação de Impressora ativa
	//oPrint   := TMSPrinter():New("Impressão de Etiquetas")
	//lPrinter := oPrint:IsPrinterActive()

	cModelo   := "ZEBRA"
	cPorta    := "LPT1" //Porta da impressora
	nTam      := 120    //Tamanho da etiqueta
	lTipo     := .f.    //.f.=Local; .t.=Servidor ou Outro Servidor
	lDrvWin   := .t.    //Usa Drive do Windows

	MSCBPRINTER(cModelo, cPorta, , nTam, lTipo, , , , , , lDrvWin)

	If !MSCBIsPrinter('LPT1')
		Messagebox("Impressora não encontrada!","Atenção",48)
		MSCBCLOSEPRINTER()
	Else

		MSCBBEGIN(1, 6, , .f.)
		/*
		MB01 - Interleaved 2 of 5 / EAN14
		MB02 - Code 39
		MB03 - EAN 8
		MB04 - EAN 13
		MB05 - UPC A
		MB06 - UPC E
		MB07 - CODE 128 */
		MSCBSAYBAR(15, 01, ALLTRIM(cGetCod), "N", "MB07", 08, .F., .T., .F., , 3, 2)
		MSCBSay(03,17," "+Alltrim(cGetCod) ,"N","0","100,100") // JOSE 25/04/2025  "N","0","120,120"
		MSCBCHKSTATUS(.f.)
		cText := MSCBEND()
		MSCBCLOSEPRINTER()

	Endif

Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTblLoc() - Cria temporario para o Alias: TMP
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTblLoc() // Jose 24/04/2025
	Local aFds := {}
	//Local cTmp
	If ChkFile("LOC")
		DbSelectArea("LOC")
		DbCloseArea()
	Endif

	aAdd( aFds , {"LOC_DEL" ,"C", 002, 000} )
	aAdd( aFds , {"LOC_ORD" ,"C", 003, 000} )
	aAdd( aFds , {"LOC_LOC" ,"C", 20, 000} ) //  Jose 25/04/2025  , 15, 000}

	/********************************************************************************************************************************/
	/*** BLOCO ALTERADO EM 28/10/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
	/*    cTmp := CriaTrab( aFds, .T. )
       Use (cTmp) Alias LOC New Exclusive
       Index On LOC_ORD To (cTmp)
	*/
	//cTmp := U_NovoArqTrab("dbf")
	//dbcreate(cTmp+".dbf", aFds, "DBFCDXADS")
	//Use (cTmp+".Dbf") Alias "LOC" VIA "DBFCDXADS" New Exclusive
	//Index On LOC_ORD To (cTmp)
	oTempTbl6 := FWTemporaryTable():New( 'LOC' )
	oTempTbl6:SetFields( aFds )
	oTempTbl6:AddIndex( "cInd01", { "LOC_ORD" } )
	oTempTbl6:Create()
	/********************************************************************************************************************************/

	DbSelectArea("ZZL")
	DbSetOrder(1)
	DbSeek(xFilial("ZZL")+Alltrim(StrTran(StrTran(cCodPro, '.'), '-')), .t.)
	While !Eof() .and. ZZL->ZZL_FILIAL == xFilial("ZZL") .and. Alltrim(ZZL->ZZL_PRODUT) == Alltrim(StrTran(StrTran(cCodPro, '.'), '-'))
		RecLock("LOC", .t.)
		LOC->LOC_DEL := "  "
		LOC->LOC_ORD := ZZL->ZZL_ORDEM
		LOC->LOC_LOC := ZZL->ZZL_LOCALI
		MsUnLock()
		cNumOrd := ZZL->ZZL_ORDEM
		DbSelectArea("ZZL")
		DbSkip()
	Enddo
	DbSelectArea("LOC")
	DbGoTop()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ TMPLocM() - Funcao para marcar o MsSelect
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function TMPLocM()
	Local lDesMarca := LOC->(IsMark("LOC_DEL", cMarca))
	RecLock("LOC", .F.)
	If lDesmarca
		LOC->LOC_DEL := "  "
	Else
		LOC->LOC_DEL := cMarca
	Endif

	LOC->(MsUnlock())
Return

Static Function fAddIte()         // Função Adicionar Localização Provisória   // Jose 24/04/2025
	If !Empty(cGetCod)
		cNumOrd := Soma1(cNumOrd)
		RecLock("LOC", .t.)
		LOC->LOC_DEL := "  "
		LOC->LOC_ORD := cNumOrd
		LOC->LOC_LOC := cGetCod
		MsUnLock()
		RecLock("ZZL", .t.)
		ZZL->ZZL_FILIAL := xFilial("ZZL")
		ZZL->ZZL_PRODUT := Alltrim(StrTran(StrTran(cCodPro, '.'), '-'))
		ZZL->ZZL_ORDEM  := cNumOrd
		ZZL->ZZL_LOCALI := Upper(cGetCod)
		ZZL->ZZL_DTINC  := dDataBase
		ZZL->ZZL_HRINC  := SubStr(StrTran(Time(), ":"), 1, 4)
		MsUnLock()
	Else
		MsgStop("Atenção, preencha a nova Localização/Qtde do produto!!")
		Return
	Endif

	If lCheck .and. len(Alltrim(StrTran(StrTran(cCodPro, '.'), '-')))==12 // se for PA e o flag etiqueta estiver marcado
		fIEtProv() // Imprime Etiqueta
	Endif
	cGetCod := Space(20) // Jose 25/04/2025   Space(15)
	oGetCod:Refresh()

	If ChkFile("LOC")
		DbSelectArea("LOC")
		DbCloseArea()
		oTblLoc()
	Endif
	//oBrwLoc:oBrowse:bGoTop()
	oBrwLoc:oBrowse:Refresh()
	oGetCod:SetFocus()

Return(NIL)

Static Function fDelIte()            // Função Excluir Localização Provisória Marcada
	Local cEnd := ""

	DbSelectArea("LOC")
	DbGoTop()
	While !Eof()
		If LOC->(IsMark("LOC_DEL", cMarca))
			DbSelectArea("ZZL")
			DbSetOrder(1)
			DbSeek(xFilial("ZZL")+Alltrim(StrTran(StrTran(cCodPro, '.'), '-'))+space( 15 - len(Alltrim(StrTran(StrTran(cCodPro, '.'), '-'))))+LOC->LOC_ORD, .T.)
			If Found()
				cEnd += TRIM(ZZL->ZZL_LOCALI)+ Chr(13) + Chr(10)
			Endif
		Endif
		DbSelectArea("LOC")
		DbSkip()
	Enddo

	/*Adicionado por Lucas - 17-09-2025. Chamado R9351*/
	If MsgYesNo('Atenção, deleta os itens marcados?'+ Chr(13) + Chr(10)+cEnd, 'Atenção', 'ALERT')
		DbSelectArea("LOC")
		DbGoTop()
		While !Eof()
			If LOC->(IsMark("LOC_DEL", cMarca))
				DbSelectArea("ZZL")
				DbSetOrder(1)
				DbSeek(xFilial("ZZL")+Alltrim(StrTran(StrTran(cCodPro, '.'), '-'))+space( 15 - len(Alltrim(StrTran(StrTran(cCodPro, '.'), '-'))))+LOC->LOC_ORD, .T.)
				If Found()
					cEnd += TRIM(ZZL->ZZL_LOCALI)+" - "
					RecLock("ZZL", .f.)
					ZZL->ZZL_DTDEL  := dDataBase
					ZZL->ZZL_HRDEL  := SubStr(StrTran(Time(), ":"), 1, 4)
					DbDelete()
					MsUnLock()
				Endif
				RecLock("LOC", .f.)
				DbDelete()
				MsUnLock()
			Endif
			DbSelectArea("LOC")
			DbSkip()
		Enddo
		If cEnd <> ""
			Messagebox("Endereços excluídos -> "+cEnd,"Atenção",48)
		Endif
	Else
		DbSelectArea("LOC")
		DbGoTop()
		While !Eof()
			RecLock("LOC", .f.)
			LOC->LOC_DEL := "  "
			MsUnLock()
			DbSelectArea("LOC")
			DbSkip()
		Enddo
	Endif
	If ChkFile("LOC")
		DbSelectArea("LOC")
		DbCloseArea()
		oTblLoc()
	Endif
	//oBrwLoc:oBrowse:bGoTop()
	oBrwLoc:oBrowse:Refresh()
	oGetCod:SetFocus()
	/*

	   If ChkFile("LOC")
    	   DbSelectArea("LOC")
       	   DbSetOrder(1)
	       DbGoTop()
       Endif
       oBrwLoc:oBrowse:bGoTop
       oBrwLoc:oBrowse:Refresh()
	oGetCod:SetFocus() */

Return

Static Function fAltIte()            // Função Alterar Localização Provisória Marcada
	If Empty(cGetCod)
		MsgStop("Atenção, preencha a nova Qtde ou Localização do produto!!")
	Else
		If MsgYesNo('Atenção, alterar a Quantidade/Localização do primeiro item MARCADO ?', 'Atenção', 'ALERT')
			DbSelectArea("LOC")
			DbGoTop()
			While !Eof()
				If LOC->(IsMark("LOC_DEL", cMarca))
					DbSelectArea("ZZL")
					DbSetOrder(1)
					DbSeek(xFilial("ZZL")+Alltrim(StrTran(StrTran(cCodPro, '.'), '-'))+space( 15 - len(Alltrim(StrTran(StrTran(cCodPro, '.'), '-'))))+LOC->LOC_ORD, .T.)
					If Found()
						RecLock("ZZL", .f.)
						ZZL->ZZL_LOCALI := Upper(cGetCod)
						MsUnLock()
					Endif
					DbSelectArea("LOC")
					DbGoTop()
					cGetCod := Space(15)
					oGetCod:Refresh()
					oGetCod:SetFocus()
					Exit
				Endif
				DbSelectArea("LOC")
				DbSkip()
			Enddo
		Endif
		DbSelectArea("LOC")
		DbGoTop()
		cGetCod := Space(15)
		oGetCod:Refresh()
		oGetCod:SetFocus()
	Endif
	If ChkFile("LOC")
		DbSelectArea("LOC")
		DbCloseArea()
		oTblLoc()
	Endif
	//oBrwLoc:oBrowse:bGoTop()
	oBrwLoc:oBrowse:Refresh()
	oGetCod:SetFocus()

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TransfBorPed ³ Autor ³  André Maester     ³ Data ³ 23/09/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³ 23/09/13³  Uso inicial do programa                     ³±±
±±³              ³  /  /   ³  Tranfere Pedido de um Bordero para outro    ³±±
±±³      					  existente ou cria um novo bordero           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function TransfBorPed()
	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de cVariable dos componentes                                 ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	Private cGet1TBo   := Space(6)
	Private cGet2TBo   := Space(6)
	Private cGet3TBo   := Space(8)
	Private cGet4TBo   := Space(8)
	Private cSay1TBo   := Space(1)
	Private cSay2TBo   := Space(1)
	Private nRMenu1T
	Private cMarca     := GetMark()
	Private oTempTbl9

	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	SetPrvt("oFont1", "oDlg1TBo", "oSay1TBo", "oSay2TBo", "oSay3TBo", "oSay4TBo", "oRMenu1T", "oGet1TBo", "oGet2TBo", "oGet3TBo", "oGet4TBo", "oBtn1TBo", "oBtn2TBo", "oBtn3TBo")

	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	oFont1     := TFont():New( "MS Sans Serif", 0, -17, , .T., 0, , 700, .F., .F., , , , , , )
	oDlg1TBo   := MSDialog():New( 091, 232, 556, 757, "Transferência de Borderos de Pedido", , , .F., , , , , , .T., , , .T. )
	oSay1TBo   := TSay():New( 020, 004, {||"Do Bordero:"}  , oDlg1TBo, , oFont1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 064, 012)
	oGet1TBo   := TGet():New( 019, 060, {|u| If(PCount() > 0, cGet1TBo := u, cGet1TBo)}, oDlg1TBo, 040, 012, '', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .F., .F., "SZF", "cGet1TBo", , )
	oSay2TBo   := TSay():New( 020, 135, {||"Para Bordero:"}, oDlg1TBo, , oFont1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 068, 012)
	oGet2TBo   := TGet():New( 019, 204, {|u| If(PCount() > 0, cGet2TBo := u, cGet2TBo)}, oDlg1TBo, 040, 012, '', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .F., .F., "SZF", "cGet2TBo", , )
	oSay3TBo   := TSay():New( 215, 004, {||"Volumes:"}, oDlg1TBo, , oFont1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 068, 012)
	oGet3TBo   := TGet():New( 214, 060, {|u| If(PCount() > 0, cGet3TBo := u, cGet3TBo)}, oDlg1TBo, 040, 012, '', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .F., .F.,      , "cGet3TBo", , )
	oSay4TBo   := TSay():New( 215, 145, {||"Peso:"}, oDlg1TBo, , oFont1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 068, 012)
	oGet4TBo   := TGet():New( 214, 204, {|u| If(PCount() > 0, cGet4TBo := u, cGet4TBo)}, oDlg1TBo, 040, 012, '', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .F., .F.,      , "cGet4TBo", , )
	//GoRMenu1   := TGroup():New( 004, 004, 034, 080, "", oDlg1TBo, CLR_BLACK, CLR_WHITE, .T., .F. )
	//oRMenu1T   := TRadMenu():New( 008, 010, {"1 Pedido", "Multiplos Pedidos"}, {|u| If(PCount() > 0, nRMenu1T := u, nRMenu1T)}, oDlg1TBo, , , CLR_BLACK, CLR_WHITE, "", , , 056, 16, , .F., .F., .T. )

	oBtn1TBo   := TButton():New( 002, 226, "Sair"        , oDlg1TBo, { || oDlg1TBo:End() }, 037, 012, , , , .T., , "", , , , .F. )
	oBtn2TBo   := TButton():New( 002, 176, "Confirma"    , oDlg1TBo, { || fComTran()     }, 037, 012, , , , .T., , "", , , , .F. )
	oBtn3TBo   := TButton():New( 002, 126, "Novo Bordero", oDlg1TBo, { || fGerNewB()     }, 037, 012, , , , .T., , "", , , , .F. )

	oTbl1TBo()
	DbSelectArea("TMPTBO")
	oBrw1TBo   := MsSelect():New( "TMPTBO", "MARCA", "", { {"MARCA", "", "", ""}, {"PEDID", "", "Pedido", "99999999"}, {"NOMCL", "", "Nome Cliente", "@!"}, {"_LOCAL", "", "Localizacao", "@!"}, {"VOLUM", "", "Volume", "9999"} }, .F., cMarca, {036, 004, 210, 262}, , , oDlg1TBo )
	oBrw1TBo:oBrowse:lColDrag    := .t.
	oBrw1TBo:oBrowse:lHasMark    := .t.
	oBrw1TBo:oBrowse:lCanAllmark := .t.
	oBrw1TBo:oBrowse:bAllMark    := {|| InvTrans(cMarca, @oBrw1TBo) }
	oGet1TBo:bValid := {|| fValBorDe() }
	oGet2TBo:bValid := {|| fValBorPa() }
	oDlg1TBo:Activate(,,,.T.)
	DbSelectArea("TMPTBO")
	DbCloseArea()
	oTempTbl9:Delete()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTbl1TBo() - Cria temporario para o Alias: TMPTBO
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTbl1TBo()
	Local aFds := {}
	//Local cTmp

	Aadd( aFds , {"MARCA", "C", 002, 000} )
	Aadd( aFds , {"PEDID", "C", 008, 000} )
	Aadd( aFds , {"NOMCL", "C", 040, 000} )
	Aadd( aFds , {"_LOCAL", "C", 015, 000} )
	Aadd( aFds , {"VOLUM", "N", 005, 000} )

	/********************************************************************************************************************************/
	/*** BLOCO ALTERADO EM 28/10/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
	/*     cTmp := CriaTrab( aFds, .T. )
       Use (cTmp) Alias TMPTBO New Exclusive
       Index On PEDID To (cTmp)
	*/
	//cTmp := U_NovoArqTrab("dbf")
	//dbcreate(cTmp+".dbf", aFds, "DBFCDXADS")
	//Use (cTmp+".Dbf") Alias "TMPTBO" VIA "DBFCDXADS" New Exclusive
	//Index On PEDID To (cTmp)

	oTempTbl9 := FWTemporaryTable():New( 'TMPTBO' )
	oTempTbl9:SetFields( aFds )
	oTempTbl9:AddIndex( "cInd01", { "PEDID" } )
	oTempTbl9:Create()
	/********************************************************************************************************************************/
Return

Static Function fValBorDe()
	Local nVolBor :=0
	Local nPesBor :=0
	DbSelectArea("TMPTBO")
	Zap
	If !Posicione("SZF", 1, xFilial("SZF")+cGet1TBo, "ZF_FLAG") $ 'D' //DIGITADO
		MsgStop("Atenção, o status desse bordero não permite fazer a transferência.")
		cGet1TBo := space(06)
		oGet1TBo:Refresh()
		Return
	Endif
	cGet2TBo := space(06)
	oGet2TBo:Refresh()
	DbSelectArea("SZG")
	DbSetOrder(1)
	DbSeek(xFilial("SZG")+cGet1TBo, .t.)
	If Found()
		While !Eof() .and. (SZG->ZG_FILIAL == xFilial("SZG"))  .and. SZG->ZG_CODIGO == cGet1TBo
			RecLock("TMPTBO", .t.)
			TMPTBO->PEDID := SZG->ZG_PEDIDO
			TMPTBO->NOMCL := Posicione("SA1", 1, xFilial("SA1")+Posicione("SC5", 1, xFilial("SC5")+SubStr(SZG->ZG_PEDIDO, 3, 6), "C5_CLIENTE"), "A1_NOME")
			TMPTBO->_LOCAL := SZG->ZG_LOCALIZ
			TMPTBO->VOLUM := Posicione("SC5", 1, xFilial("SC5")+SubStr(SZG->ZG_PEDIDO, 3, 6), "C5_VOLUME1")
			MsUnLock()
			nPesBor += Posicione("SC5", 1, xFilial("SC5")+SubStr(SZG->ZG_PEDIDO, 3, 6), "C5_PBRUTO")
			nVolBor += TMPTBO->VOLUM
			DbSelectArea("SZG")
			DbSkip()
		EndDo
	Endif
	DbSelectArea("TMPTBO")
	DbGoTop()
	oBrw1TBo:oBrowse:lReadOnly := .t.
	oBrw1TBo:oBrowse:Refresh()
	cGet3TBo := nVolBor
	cGet4TBo := Transform(nPesBor, '@E 999,999,999.99')
	oGet2TBo:SetFocus()
Return

Static Function fValBorPa()
	If Empty(cGet1TBo)
		MsgStop("Atenção, o 'Bordero De' não pode ser vazio.")
		cGet2TBo := space(06)
		oGet2TBo:Refresh()
		oGet1TBo:SetFocus()
		oGet1TBo:Refresh()
	ElseIf cGet2TBo == cGet1TBo
		MsgStop("Atenção, não pode transferir um pedido de um bordero para ele mesmo.")
		cGet2TBo := space(06)
		oGet2TBo:Refresh()
		oGet2TBo:SetFocus()
		Return
	ElseIf !Empty(cGet2TBo) .and. !Posicione("SZF", 1, xFilial("SZF")+cGet2TBo, "ZF_FLAG") $ 'D'
		MsgStop("Atenção, o status desse bordero não permite fazer a transferência ou o borderô de destino ainda não existe!!.")
		cGet2TBo := space(06)
		oGet2TBo:Refresh()
		oGet2TBo:SetFocus()
		Return
	Endif
	oBrw1TBo:oBrowse:lReadOnly := .f.
Return

Static Function InvTrans(cMarca, oBrw1TBo)
	Local nReg := TMPTBO->(Recno())
	DbSelectArea("TMPTBO")
	DbGoTop()
	While !Eof()
		RecLock("TMPTBO", .f.)
		If TMPTBO->MARCA == cMarca
			TMPTBO->MARCA := "  "
		Else
			TMPTBO->MARCA := cMarca
		Endif
		MsUnLock()
		DbSkip()
	Enddo
	TMPTBO->(dbGoto(nReg))
	oBrw1TBo:oBrowse:Refresh(.t.)
Return

Static Function fGerNewB()

	//Local cQry1 := ""
	Local nRecSZF := 0
	Local cCodBor := 0
	/*
       cQry1 := " "
       cQry1 += "SELECT (MAX(ZF_CODIGO)+1) AS ZF_PROXIMO "
       cQry1 += "FROM "+RetSqlName("SZF")+" SZF WITH (NOLOCK) "
       cQry1 += "WHERE SZF.ZF_FILIAL  = '"+xFilial("SZF")+"' "
       cQry1 += "  AND SZF.D_E_L_E_T_ = '' "
       TCQuery cQry1 ALIAS "TMP" NEW
       DbSelectArea("TMP")
       If !Eof()
		   cCodBor := StrZero(TMP->ZF_PROXIMO, 6)
 	   Else
 	   	   cCodBor := "000001"
 	   Endif
	   DbSelectArea("TMP")
	DbCloseArea()    */

	If !Empty(cGet1TBo)
		cCodBor := U_NumSeqLot("SZF")
		DbSelectArea("SZF")
		nRecSZF := SZF->(Recno())
		cGet2TBo := StrZero(Val(cCodBor), 6)
		TMPTBO->(dbGoto(nRecSZF))
		oGet2TBo:lReadOnly := .f.
		oGet2TBo:Refresh()
		oBrw1TBo:oBrowse:SetFocus()
		SZF->(dbGoto(nRecSZF))
		oBrw1TBo:oBrowse:Refresh()
	Endif
Return

Static Function fComTran()
	Local cBusTipo :=""
	If Empty(cGet1TBo) .or. Empty(cGet2TBo)
		MsgStop("A transferência não poderá ser realizada devido a um dos borderos estarem em branco.")
		Return
	Endif
	cStrSZG := "('"
	cStrZZC := "('"
	cBusTipo:= Posicione("SZF", 1, xFilial("SZF")+cGet1TBo, "ZF_TIPOBOR")
	DbSelectArea("TMPTBO")
	DbGoTop()
	While !Eof()
		If IsMark("MARCA", cMarca)
			cStrSZG += TMPTBO->PEDID+"', '"
			cStrZZC += SubStr(TMPTBO->PEDID, 3, 6)+"', '"
		Endif
		DbSelectArea("TMPTBO")
		DbSkip()
	EndDo
	cStrSZG := SubStr(cStrSZG, 1, Len(cStrSZG)-3)+")"
	cStrZZC := SubStr(cStrZZC, 1, Len(cStrZZC)-3)+")"

	If Len(Alltrim(cStrSZG)) >5 // Verificar se existe pelo menos um pedido marcado

		// CRIAR NOVO BORDERÔ DE PEDIDOS CASO SEJA ESCOLHIDO UM NOVO
		DbSelectArea("SZF")
		DbSetOrder(1)
		DbSeek(xFilial("SZF")+cGet2TBo, .t.)
		If !Found()
			If MsgYesNo("Confirma a transferência do(s) pedido(s) marcado(s) para o novo borderô de número "+cGet2TBo+" ?", "Atenção")
				RecLock("SZF", .t.)
				SZF->ZF_FILIAL  := xFilial("SZF")
				SZF->ZF_CODIGO  := cGet2TBo
				SZF->ZF_EMISSAO := dDataBase
				SZF->ZF_FLAG    := 'D'
				If GetMv("MV_XHABBOR")
					SZF->ZF_TIPOBOR := cBusTipo  // TRAZER PARA UM NOVO BORDERO O TIPO DO BORDERO ANTIGO
				Endif
				MsUnlock()
				DbSelectArea("SZF")
				DbCloseArea()
			Else
				Return
			Endif
		Endif

		//TROCAR SZG  -- ITENS BORDERO DE PEDIDOS
		cQry1 := " "
		cQry1 += " UPDATE SZG010 "
		cQry1 += "SET ZG_CODIGO = '"+cGet2TBo+"' "
		cQry1 += "WHERE ZG_FILIAL = '"+xFilial("SZG")+"' "
		cQry1 += "  AND D_E_L_E_T_ = '' "
		cQry1 += "  AND ZG_PEDIDO IN "+cStrSZG
		TCSQLExec(cQry1)
		//TROCAR ZZC    -- SEPARAÇÃO DE PRODUTOS
		cQry1 := " "
		cQry1 += "UPDATE ZZC010 "
		cQry1 += "SET ZZC_BORDER = '"+cGet2TBo+"' "
		cQry1 += "WHERE ZZC_FILIAL = '"+xFilial("ZZC")+"' "
		cQry1 += "  AND D_E_L_E_T_ = '' "
		cQry1 += "  AND ZZC_PEDIDO IN "+cStrZZC
		TCSQLExec(cQry1)

		DbSelectArea("SZG")
		DbSetOrder(1)
		DbSeek(xFilial("SZG")+cGet1TBo,.t.)
		If !Found()
			If MsgYesNo("O borderô de número "+cGet1TBo+" ficou vazio após a transferência. Deseja Excluí-lo ?", "Atenção")
				DbSelectArea("SZF")
				DbSetOrder(1)
				DbSeek(xFilial("SZF")+cGet1TBo, .t.)
				If Found()
					RecLock("SZF", .f.)
					DbDelete()
					MsUnLock()
				Else
					MsgBox("Borderô não foi excluído. Verifique na no cadastro de borderôs", "Informação", "INFO")
				Endif
				DbSelectArea("SZF")
				DbCloseArea()
			Endif
		Endif
		DbSelectArea("SZG")
		DbCloseArea()

		oDlg1TBo:End()
	Else
		MsgBox("É preciso marcar algum pedido antes de tentar transferir", "Atenção", "INFO")
		oBrw1TBo:oBrowse:SetFocus()
		oBrw1TBo:oBrowse:Refresh()
	Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ REMONPED³ Autor ³ Luís G. de Souza      ³ Data ³ 27/10/10  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³                  ³Contato ³                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Re-Monta Bordero de Pedidos                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³  /  /  ³                                               ³±±
±±³              ³  /  /  ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function REMONPED()
	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de cVariable dos componentes                                 ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	Private cMGet1Re
	Private oTempTblA

	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	SetPrvt("oDlg1Rem", "oBrw1Rem", "oBtn1Rem", "oBtn2Rem", "oGrp1Rem", "oMGet1Re", "oBtn3Rem")

	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	oDlg1Rem   := MSDialog():New( 287, 235, 766, 1217, "Re-Monta Borderô de Pedidos", , , .F., , , , , , .T., , , .T. )
	oTbl1Rem()
	DbSelectArea("TMPREM")
	oBrw1Rem   := MsSelect():New( "TMPREM", "MARCA", "", { {"PEDID", "", "Pedido", ""}, {"CLIEN", "", "Cliente", ""}, {"VOLUM", "", "Volume", ""}, {"CARGA", "", "Carga", ""}, {"_LOCAL", "", "Localizacao", "@!"}, {"ESTOQ", "", "Estoque", "@E 9999999999"}, {"NAOES", "", "Não Est.", "@E 9999999999"}, {"PERSE", "", "% Separado", "@R 999.99%"} }, .F., , {020, 004, 140, 480}, , , oDlg1Rem )
	oBrw1Rem:oBrowse:bChange := { || fTrocaPed() }
	oBtn1Rem   := TButton():New( 004, 412, "Sair"     , oDlg1Rem, { || oDlg1Rem:End() }, 068, 012, , , , .T., , "", , , , .F. )
	//oBtn2Rem   := TButton():New( 004, 208, "Transfere", oDlg1Rem, , 068, 012, , , , .T., , "", , , , .F. )
	oGrp1Rem   := TGroup():New( 144, 004, 232, 480, "Itens Faltantes", oDlg1Rem, CLR_BLACK, CLR_WHITE, .T., .F. )
	oMGet1Re   := TMultiGet():New( 152, 008, {|u| If(PCount() > 0, cMGet1Re := u, cMGet1Re)}, oGrp1Rem, 468, 076, , , CLR_BLACK, CLR_WHITE, , .T., "", , , .F., .F., .F., , , .F., , )
	//oBtn3Rem   := TButton():New( 004, 004, "Novo Bordero", oDlg1Rem, , 068, 012, , , , .T., , "", , , , .F. )

	oDlg1Rem:Activate(,,,.T.)
	DbSelectArea("TMPREM")
	DbCloseArea()
	oTempTblA:Delete()
Return

Static Function fTrocaPed()
	If TMPREM->PERSE < 100
		cObsMsg := "| QTDE. PRODUTO          DESCRIÇÃO                      VOLUME     LOCALIZAÇÃO     PRX. DESP.            |"+CHR(13)+CHR(10)
		cObsMsg += "+--------------------------------------------------------------------------------------------------------+"+CHR(13)+CHR(10)

		cMGet1Re := cObsMsg
	Else
		cMGet1Re := ""
	Endif
	oMGet1Re:Refresh()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTbl1Rem() - Cria temporario para o Alias: TMPREM
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTbl1Rem()
	Local aFds := {}
	//Local cTmp

	aAdd( aFds, {"MARCA", "C", 002, 000} )
	aAdd( aFds, {"PEDID", "C", 006, 000} )
	aAdd( aFds, {"CLIEN", "C", 042, 000} )
	aAdd( aFds, {"VOLUM", "N", 004, 000} )
	aAdd( aFds, {"CARGA", "C", 006, 000} )
	aAdd( aFds, {"_LOCAL", "C", 009, 000} )
	aAdd( aFds, {"PERSE", "N", 006, 002} )
	aAdd( aFds, {"JASEP", "N", 010, 000} )
	aAdd( aFds, {"NASEP", "N", 010, 000} )
	aAdd( aFds, {"ESTOQ", "N", 010, 000} )
	aAdd( aFds, {"NAOES", "N", 010, 000} )

	/********************************************************************************************************************************/
	/*** BLOCO ALTERADO EM 28/10/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
	/*     cTmp := CriaTrab( aFds, .T. )
       Use (cTmp) Alias TMPREM New Exclusive
	*/
	//cTmp := U_NovoArqTrab("dbf")
	//dbcreate(cTmp+".dbf", aFds, "DBFCDXADS")
	//Use (cTmp+".Dbf") Alias "TMPREM" VIA "DBFCDXADS" New Exclusive
	//Index On STR(PERSE   ) Tag &("TMPREM1") To (cTmp)
	//Index On PEDID         Tag &("TMPREM2") To (cTmp)

	oTempTblA := FWTemporaryTable():New( 'TMPREM' )
	oTempTblA:SetFields( aFds )
	oTempTblA:AddIndex( "cInd01", { "STR(PERSE   )" } )
	oTempTblA:AddIndex( "cInd02", { "PEDID" } )
	oTempTblA:Create()
	/********************************************************************************************************************************/
	cQry1 := ""
	cQry1 += "SELECT ZZC.ZZC_BORDER, ZZC.ZZC_CARGA, ZZC.ZZC_PEDIDO, ZZC.ZZC_SEPARA, SUM(ZZC.ZZC_VOLUME) AS QTDE, SC5.C5_CLIENTE+'/'+SC5.C5_LOJACLI+' - '+SA1.A1_NOME AS CLIENTE, SZG.ZG_LOCALIZ "
	cQry1 += "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
	cQry1 += "LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON SC5.C5_FILIAL = ZZC.ZZC_FILIAL AND SC5.C5_NUM = ZZC.ZZC_PEDIDO AND SC5.D_E_L_E_T_ = '' "
	cQry1 += "LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.A1_FILIAL = '"+xFilial("SA1")+"') AND SA1.A1_COD = SC5.C5_CLIENTE AND SA1.A1_LOJA = SC5.C5_LOJACLI AND SA1.D_E_L_E_T_ = '' "
	cQry1 += "LEFT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH (NOLOCK) ON SZG.ZG_FILIAL = ZZC.ZZC_FILIAL AND SZG.ZG_CODIGO = ZZC.ZZC_BORDER AND SUBSTRING(SZG.ZG_PEDIDO, 3, 6) = ZZC.ZZC_PEDIDO AND SZG.D_E_L_E_T_ = '' "
	cQry1 += "WHERE ZZC.ZZC_FILIAL = '"+xFilial("ZZC")+"' "
	cQry1 += "  AND ZZC.D_E_L_E_T_ = '' "
	cQry1 += "  AND ZZC.ZZC_BORDER = '"+SZF->ZF_CODIGO+"' "
	cQry1 += "GROUP BY ZZC.ZZC_BORDER, ZZC.ZZC_CARGA, ZZC.ZZC_PEDIDO, ZZC.ZZC_SEPARA, SC5.C5_CLIENTE+'/'+SC5.C5_LOJACLI+' - '+SA1.A1_NOME, SZG.ZG_LOCALIZ  "
	cQry1 += "ORDER BY ZZC.ZZC_PEDIDO, ZZC.ZZC_SEPARA "
	TCQuery cQry1 ALIAS "TCQ" NEW
	DbSelectArea("TCQ")
	DbGoTop()
	While !Eof()
		DbSelectArea("TMPREM")
		DbSetOrder(2)
		DbSeek(TCQ->ZZC_PEDIDO, .t.)
		If Found()
			RecLock("TMPREM", .f.)
			TMPREM->VOLUM += TCQ->QTDE
			If TCQ->ZZC_SEPARA $ 'S'
				TMPREM->JASEP += TCQ->QTDE
			Else
				TMPREM->NASEP += TCQ->QTDE
			Endif
			TMPREM->PERSE := (TMPREM->JASEP / TMPREM->VOLUM) * 100
		Else
			cQry1 := ""
			cQry1 += " SELECT COUNT(SC6.R_E_C_N_O_) AS QTDE "
			cQry1 += " FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "
			cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.B1_FILIAL = SC6.C6_FILIAL) AND (SB1.B1_COD = SC6.C6_PRODUTO) AND (SB1.D_E_L_E_T_ = '') "
			cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON (SB2.B2_FILIAL = SB1.B1_FILIAL) AND (SB2.B2_COD = SB1.B1_COD) AND (SB2.B2_LOCAL = SB1.B1_LOCPAD) AND (SB2.D_E_L_E_T_ = '') "
			cQry1 += " WHERE (SC6.C6_FILIAL   = '"+xFilial("SC6")+"') "
			cQry1 += "  AND SC6.D_E_L_E_T_  = '' "
			cQry1 += "  AND SC6.C6_NUM      = '"+TCQ->ZZC_PEDIDO+"' "
			cQry2 := "  AND SB2.B2_LOCALIZ <> '' "
			cQry3 := "  AND SB2.B2_LOCALIZ  = '' "
			/* Itens em Estoque */
			cQryA := cQry1 + cQry2
			TCQuery cQryA ALIAS "TMPEST" NEW
			DbSelectArea("TMPEST")
			DbGoTop()
			nEstoque := TMPEST->QTDE
			DbSelectArea("TMPEST")
			DbCloseArea()

			/* Itens não Estoque */
			cQryA := cQry1 + cQry3
			TCQuery cQryA ALIAS "TMPEST" NEW
			DbSelectArea("TMPEST")
			DbGoTop()
			nNaoEsto := TMPEST->QTDE
			DbSelectArea("TMPEST")
			DbCloseArea()

			RecLock("TMPREM", .t.)
			TMPREM->PEDID := TCQ->ZZC_PEDIDO
			TMPREM->CARGA := TCQ->ZZC_CARGA
			TMPREM->CLIEN := TCQ->CLIENTE
			TMPREM->VOLUM := TCQ->QTDE
			If TCQ->ZZC_SEPARA $ 'S'
				TMPREM->JASEP := TCQ->QTDE
			Else
				TMPREM->NASEP := TCQ->QTDE
			Endif
			TMPREM->PERSE := (TMPREM->JASEP / TMPREM->VOLUM) * 100
			TMPREM->_LOCAL := TCQ->ZG_LOCALIZ
			TMPREM->ESTOQ := nEstoque
			TMPREM->NAOES := nNaoEsto
		Endif
		MsUnLock()
		DbSelectArea("TCQ")
		DbSkip()
	EndDo
	DbSelectArea("TCQ")
	DbCloseArea()
	DbSelectArea("TMPREM")
	DbSetOrder(1)
	DbGoTop()

Return

//  Jose   05/05/2025 -----------------------------------------------------------------------
/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fIEtProA() - Impressão da Etiqueta com a localização Provisório Araraquara
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fIEtProA()  // Jose 24/04/2025

	//Verificação de Impressora ativa
	//oPrint   := TMSPrinter():New("Impressão de Etiquetas")
	//lPrinter := oPrint:IsPrinterActive()


	If ALLTRIM(cLocProA) = ""
		Messagebox("Sem Local Padrão Araraquara!","Atenção",48)
		Return
	EndIF
	cModelo   := "ZEBRA"
	cPorta    := "LPT1" //Porta da impressora
	nTam      := 120    //Tamanho da etiqueta
	lTipo     := .f.    //.f.=Local; .t.=Servidor ou Outro Servidor
	lDrvWin   := .t.    //Usa Drive do Windows

	MSCBPRINTER(cModelo, cPorta, , nTam, lTipo, , , , , , lDrvWin)

	If !MSCBIsPrinter('LPT1')
		Messagebox("Impressora não encontrada!","Atenção",48)
		MSCBCLOSEPRINTER()
	Else
		MSCBBEGIN(1, 6, , .f.)
		/*
		 MB01 - Interleaved 2 of 5 / EAN14
	 	 MB02 - Code 39
		 MB03 - EAN 8
		 MB04 - EAN 13
		 MB05 - UPC A
		 MB06 - UPC E
		 MB07 - CODE 128
		*/
		MSCBSAYBAR(20, 05, ALLTRIM(cLocProA), "N", "MB07", 10, .F., .T., .F., , 3, 2) // Jose 28/05/2025 15, 01 ,08,
		MSCBSay(15,40," "+Alltrim(cLocProA) ,"N","0","190,120") // Jose 28/05/2025  03,17    "100,100"
		MSCBCHKSTATUS(.f.)
		cText := MSCBEND()
		MSCBCLOSEPRINTER()
	Endif

Return
// Até Aqui Jose 05/05/2025 ----------------------------------------------------------------------------------


// Jose 07/05/2025 por Solicitação do André TI ---------------------------------------------------------------
User Function fArLoc2()
	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
   ±± Declaração de cVariable dos componentes                                 ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	Private cGetCod := Space(15)
	Private cCodPro := Space(12)
	Private cGetFix := Space(15)
	Private cDesPro := Space(35)
	Private cMarca  := GetMark()
	Private cNumOrd := "000"
	Private lCheck  :=.T.

	//If Empty(StrTran(StrTran(cCodPro, '.'), '-'))
	//   MsgStop("Favor informar o código do produto...")
	//   Return
	//Endif
	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
   ±± Declaração de Variaveis Private dos Objetos                             ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	SetPrvt("oFont1", "oDlg2", "oGetCod", "oGetDes", "oBtnVol", "oBtnCon", "oBrwLoc", "oBtnDel","oBtnAlt","oDesPro","oGetFix")

	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
   ±± Definicao do Dialog e todos os seus componentes.                        ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	oFont1     := TFont():New( "MS Sans Serif",0,-18,,.F.,0,,600,.F.,.F.,,,,,, )
	oDlg4      := MSDialog():New( 187,322,491,850,"Manutenção de localização de produtos",,,.F.,,,,,,.T.,,,.T. )
	oCodPro    := TGet():New( 010,004,{|u| If(PCount()> 0,CCODPRO:=u,CCODPRO)},oDlg4,080,15,'@!',,CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .F., .F., "", "cCodPro", , )
	//oCodPro:bLostFocus := {|| fCodPr2(), Iif(!Empty(cCodPro), MsAguarde( {|| oTbl1(2)}, "Aguarde...", "Buscando dados..."), ), Iif(!Empty(cCodPro), MsAguarde( {|| oTbl2(2)}, "Aguarde...", "Buscando dados..."), )}
	oCodPro:bLostFocus := {|| fCodPr2(),  Iif(!Empty(cCodPro), MsAguarde( {||  oTblLoc()}, "Aguarde...", "Buscando dados..."), ) }
	oDesPro    := TGet():New( 010,088,{|u| If(PCount()> 0,cDesPro:=u,cDesPro)},oDlg4, 180, 15,'' , , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .T., .F., "", "cDesPro", , )
	oGetCod    := TGet():New( 034,004,{|u| If(PCount()>0,cGetCod:=u,cGetCod)},oDlg4,080,015,'',,CLR_BLACK,CLR_WHITE,oFont1,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGetCod",,)
	oGetFix    := TGet():New( 034,170,{|u| If(PCount()>0,cGetFix:=u,cGetFix)},oDlg4,080,015,'',,CLR_BLACK,CLR_WHITE,oFont1, , , .T., "", , , .F., .F., , .T., .F., "","cGetFix",,)
	oTblLoc()

	DbSelectArea("LOC")
	DbSetOrder(1)
	oBrwLoc    := MsSelect():New( "LOC","LOC_DEL","",{ {"LOC_DEL", "", "", ""}, {"LOC_ORD", "", "Ordem", "@!"}, {"LOC_LOC", "", "Localizacao", "@!"}},.F.,cMarca,{054,004,124,228},,, oDlg4 )
	oBrwLoc:bAval := {||TMPLocM()}

	oBrwLoc:oBrowse:lHasMark := .T.
	oBrwLoc:oBrowse:lCanAllmark := .F.

	oBtnDel    := TButton():New  ( 135,004,"Deleta"  ,oDlg4,{ || fDelIte() } ,037,015,,,,.T.,,"",,,,.F. )
	oBtnAlt    := TButton():New  ( 135,064,"Altera"  ,oDlg4,{ || fAltIte() } ,037,015,,,,.T.,,"",,,,.F. )
	oBtnAdd    := TButton():New  ( 135,124,"Adiciona",oDlg4,{ || fAddIte() } ,037,015,,,,.T.,,"",,,,.F. )
	oBtnVol    := TButton():New  ( 135,184,"Voltar"  ,oDlg4,{ || oDlg4:End()},037,015,,,,.T.,,"",,,,.F. )
	//oCBox1     := TCheckBox():New( 108,090,"Etiqueta",{|u| If(PCount() > 0, lCheck := u, lCheck)},oDlg4,080,012,,,oFont,,CLR_BLUE ,CLR_WHITE,,.t.,"Imprime Etiqueta Localização",, )?????
	lCheck :=.F.
	oCodPro:SetFocus()
	oDlg4:Activate(,,,.T.)

	DbSelectArea("LOC")
	DbCloseArea()

Return


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fCodPr2() - Busca informações de tela após da digitação do código de barras ou do produto
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fCodPr2()

	cCodPro   := StrTran(StrTran(cCodPro, '-'), '.')
	cGetFix   := Space(15)
	oGetFix:Refresh()

	If Empty(cCodPro)
		Return
	ElseIf SubStr(cCodPro, 1, 3) $ '789'
		DbSelectArea("SB1")
		DbSetOrder(5)
		DbSeek(xFilial("SB1")+Substr(cCodPro,1,12), .t.)
		If !Found()
			ApMsgStop("Codigo Inválido !!!")
			cCodPro := space(15)
			oCodPro:Refresh()
			cDesPro := space(30)
			oDesPro:Refresh()
			oCodPro:SetFocus()
			Return(.f.)
		Else
			If !SB1->B1_TIPO $ 'PA'
				ApMsgStop("Codigo Inválido !!!")
				cCodPro := space(15)
				oCodPro:Refresh()
				cDesPro := space(30)
				oDesPro:Refresh()
				oCodPro:SetFocus()
				Return(.f.)
			Else
				cCodPro := SB1->B1_COD
			Endif
		Endif
	ElseIf Len(Alltrim(cCodPro)) == 42
		DbSelectArea("SB1")
		DbSetOrder(5)
		DbSeek(xFilial("SB1")+Substr(cCodPro,04,12), .t.)
		If !Found()
			ApMsgStop("Codigo Inválido !!!")
			cCodPro := space(42)
			oCodPro:Refresh()
			cDesPro := space(30)
			oDesPro:Refresh()
			cLocPro := space(15)
			oCodPro:SetFocus()
			cLocPro := space(15)
			Return(.f.)
		Else
			If !SB1->B1_TIPO $ 'PA'
				ApMsgStop("Codigo Inválido !!!")
				cCodPro := space(42)
				oCodPro:Refresh()
				cDesPro := space(30)
				oDesPro:Refresh()
				oCodPro:SetFocus()
				Return(.f.)
			Else
				cCodPro := SB1->B1_COD
			Endif
		Endif
	Endif

	If Len(Alltrim(cCodPro)) == 14
		DbSelectArea("SC2")
		DbSetOrder(13)
		DbSeek(xFilial("SC2")+Alltrim(Substr(cCodPro,1,6)), .t.)
		If Found()
			While !(SC2->(Eof())) .AND. (XFilial("SC2") == SC2->C2_FILIAL) .AND. (Substr(cCodPro,1,6) == Alltrim(SC2->C2_LOTE))
				If Substr(cCodPro,7,2) == Substr(SC2->C2_PRODUTO,11,2)
					cCodPro := (SC2->C2_PRODUTO)
				Endif
				DbSelectArea("SC2")
				DbSkip()
			Enddo
		Else
			ApMsgStop("Codigo Inválido !!!")
			cCodPro := space(15)
			oCodPro:Refresh()
			cDesPro := space(30)
			oDesPro:Refresh()
			oCodPro:SetFocus()
			Return(.f.)
			Endif?
			DbSelectArea("SC2")
			DbCloseArea()
		Endif

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+cCodPro, .t.)
		If !Found()
			ApMsgStop("Codigo Inválido !!!")
			cCodPro := space(18)
			oCodPro:Refresh()
			cDesPro := space(30)
			oDesPro:Refresh()
			oCodPro:SetFocus()
			Return(.f.)
		Else
			If !SB1->B1_TIPO $ 'PA' .and. !Substr(Alltrim(cCodPro),4,2) $ '96.97.98.99'
				ApMsgStop("Codigo Inválido !!!")
				cCodPro := space(18)
				oCodPro:Refresh()
				cDesPro := space(30)
				oDesPro:Refresh()
				oCodPro:SetFocus()
				Return(.f.)
			Else
				//cCodPro := TransForm(SB1->B1_COD, "@R! XX 99.99.999-99")
				cCodPro := SB1->B1_COD
				oCodPro:Refresh()
				cDesPro := SB1->B1_DESC
				oDesPro:Refresh()
				DbSelectArea("SB2")
				DbSetOrder(1)
				DbSeek(xFilial("SB2")+SB1->B1_COD+'A3', .t.)
				If !Found()
					cGetFix := space(15)
					oGetFix:Refresh()
				Else
					cGetFix := SB2->B2_LOCALIZ
					oGetFix:Refresh()
				Endif
			Endif
		Endif
		If ChkFile("LOC")
			DbSelectArea("LOC")
			DbCloseArea()
			oTblLoc()
		Endif
		oBrwLoc:oBrowse:Refresh()
		oGetCod:SetFocus()
		Return

		//  Até Aqui Jose 07/05/2025 por Solicitação do André TI -------------------------------------------------------
