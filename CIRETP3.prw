#Include 'TOTVS.ch'
#Include 'FWMVCDef.ch'
#Include 'FWbrowse.ch'

/*/{Protheus.doc} CIRETP3
Retorno de poder de terceiros
@type function MVC processamento
@version  1.00
@author mantonaccio
@since 27/03/2024
@return character, sem retorno
/*/
User Function CIRETP3()

	Local aArea            := GetArea()
	Local aBrowse          := {}
	Local aSeek            := {}
	Private aCabNFE        := {}
	Private aCabPVD        := {}
	Private aFields        := {}
	Private aItmNFE        := {}
	Private aItmPVD        := {}
	Private cAlias
	Private cAliasTmp      := "PDTERC"
	Private cNFNumDV       := "NAO GERADA"
	Private cNFNumVD       := "NAO GERADA"
	Private cPVNum         := "NAO GERADO"
	Private cTableName
	Private lAutoErrNoFile := .F.
	Private lMsErroAuto    := .F.
	Private nTotQtd        := 0
	Private nTotQtdSl      := 0
	Private nTotVal        := 0
	Private nTotValSl      := 0
	Private oBrowse
	Private oTempTable     := NIL

	//Cria a temporária
	oTempTable := FWTemporaryTable():New(cAliasTMP)

	//Adiciona no array das colunas as que serão incluidas (Nome do Campo, Tipo do Campo, Tamanho, Decimais)
	aFields := {}
	aadd(aFields, {"CLIENTE", "C", TamSX3("B6_CLIFOR")[1] , TamSX3("B6_CLIFOR")[2]})
	aadd(aFields, {"LOJA"   , "C", TamSX3("B6_LOJA")[1]   , TamSX3("B6_LOJA")[2]})
	aadd(aFields, {"NOME"   , "C", TamSX3("A1_NOME")[1]   , TamSX3("A1_NOME")[2]})
	aadd(aFields, {"TIPO"   , "C", TamSX3("B1_POSIPI")[1] , TamSX3("B1_POSIPI")[2]})
	aadd(aFields, {"SALDO"  , "N", TamSX3("B6_SALDO")[1]  , TamSX3("B6_SALDO")[2]})
	aadd(aFields, {"NOTAS"  , "N", TamSX3("NQD_CONT")[1]  , TamSX3("NQD_CONT")[2]})
	aadd(aFields, {"DESDE"  , "D", TamSX3("B6_EMISSAO")[1], TamSX3("B6_EMISSAO")[2]})

	//Define as colunas usadas
	oTempTable:SetFields( aFields )
	oTempTable:AddIndex("01", {"CLIENTE","LOJA","TIPO"} )
	oTempTable:AddIndex("02", {"NOME","CLIENTE","LOJA","TIPO"} )
	oTempTable:AddIndex("03", {"DESDE","CLIENTE","LOJA","TIPO"} )
	oTempTable:AddIndex("04", {"DESDE","NOME","TIPO"} )

	//Efetua a criação da tabela
	oTempTable:Create()
	cAlias := oTempTable:GetAlias()
	cTableName := oTempTable:GetRealName()

	Processa( {|| CIRETP301() } , "Aguarde...","Carregando dados de Poder Terceiros..." , .F. )

	//Definindo as colunas que serão usadas no browse
	aadd(aBrowse, {"Cliente"     , "CLIENTE", "C", TamSX3("B6_CLIFOR")[1] , TamSX3("B6_CLIFOR")[2] , "@!"})
	aadd(aBrowse, {"Loja"        , "LOJA"   , "C", TamSX3("B6_LOJA")[1]   , TamSX3("B6_LOJA")[2]   , "@!"})
	aadd(aBrowse, {"Nome Cliente", "NOME"   , "C", TamSX3("A1_NOME")[1]   , TamSX3("A1_NOME")[2]   , "@!"})
	aadd(aBrowse, {"Tipo "       , "TIPO"   , "C", TamSX3("B1_POSIPI")[1] , TamSX3("B1_POSIPI")[2] , "@"})
	aadd(aBrowse, {"Saldo Qtd"   , "SALDO"  , "N", TamSX3("B6_SALDO")[1]  , TamSX3("B6_SALDO")[2]  , "@ER 999,999,999.99"})
	aadd(aBrowse, {"Qtd.Notas"   , "NOTAS"  , "N", TamSX3("NQD_CONT")[1]  , TamSX3("NQD_CONT")[2]  , "@ER 9,999,999,999"})
	aadd(aBrowse, {"Em 3o. Desde", "DESDE"  , "D", TamSX3("B6_EMISSAO")[1], TamSX3("B6_EMISSAO")[2], "@D"})

	//Cria índice com colunas setadas anteriormente
	aadd(aSeek, {"Cliente+Loja+Tipo CLIFOR"  , {{"","C",TamSx3("B6_CLIFOR")[1]+TamSx3("B6_LOJA")[1],TamSx3("B6_CLIFOR")[1]+TamSX3("B1_POSIPI")[1],"CLIENTE+LOJA+TIPO" ,"@!"}}})
	aadd(aSeek, {"Nome CLiente+Tipo CLIFOR"  , {{"","C",TamSx3("A1_NOME")[1]+TamSX3("B1_POSIPI")[1],0,"NOME+TIPO" ,"@!"}}})
	aadd(aSeek, {"Desde (Codigo)+Tipo CLIFOR", {{"","D",TamSx3("B6_EMISSAO")[1]+TamSx3("B6_CLIFOR")[1]+TamSx3("B6_LOJA")[1],TamSx3("B6_CLIFOR")[1]+TamSX3("B1_POSIPI")[1],"DTOS(DESDE)+CLIENTE+LOJA+TIPO" ,"@!"}}})
	aadd(aSeek, {"Desde (Nome)+Tipo CLIFOR"  , {{"","D",TamSx3("B6_EMISSAO")[1]+TamSx3("A1_NOME")[1],TamSx3("B6_CLIFOR")[1]+TamSX3("B1_POSIPI")[1],"DTOS(DESDE)+NOME+TIPO" ,"@!"}}})

	SetFunName("CIRETP3")

	//Criando o browse da temporária
	oBrowse:= FWMBrowse():New()
	oBrowse:SetAlias((cAliasTmp))
	oBrowse:SetTemporary(.T.)
	oBrowse:SetFields(aBrowse)
	oBrowse:DisableDetails()
	oBrowse:SetDescription("Poder de Terceiros com Saldo")
	oBrowse:SetMenuDef("CIRETP3")
	oBrowse:SetSeek(.T.,aSeek)
	oBrowse:Activate()

	oTempTable:Delete()

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} MenuDef
Menu de Opções em MVC
@type function Tela
@version  1.00
@author mantonaccio
@since 27/03/2024
@return array, array com as opções de mneu
/*/
Static Function MenuDef()

	Local aRot := {}

	ADD OPTION aRot TITLE "Visualizar" ACTION "U_CIRTP302('V')"	OPERATION 2 ACCESS 0
	ADD OPTION aRot TITLE "Retornar"    ACTION "U_CIRTP302('R')"	OPERATION 3 ACCESS 0
	//ADD OPTION aRot TITLE "Alterar"    ACTION "VIEWDEF.CIRETP3"	OPERATION 4 ACCESS 0
	//ADD OPTION aRot TITLE "Excluir"    ACTION "VIEWDEF.CIRETP3"	OPERATION 5 ACCESS 0
	//ADD OPTION aRot TITLE "Imprimir"   ACTION "VIEWDEF.CIRETP3"	OPERATION 8 ACCESS 0

Return aRot

/*/{Protheus.doc} CIRETP301
Carregamento Inicial da tela
@type function Processamento
@version 1.00
@author mantonaccio
@since 20/08/2024
@return character, sem retorno
/*/
Static Function CIRETP301()
	Local nReg
	Local cNome
	Local cTipo:=SuperGetMv("CI_P3DVFIL",.F.,"C")

	cTipo:="%"+FormatIn(cTipo,"/")+"%"

	BeginSql Alias "XSB6"
		SELECT
			SB6.B6_CLIFOR AS CLIENTE,
			SB6.B6_LOJA AS LOJA,
			SUM(SB6.B6_SALDO) AS SALDO,
			MIN(SB6.B6_EMISSAO) AS DESDE,
			SB6.B6_TPCF AS TIPO,
			COUNT(*) AS NOTAS
		FROM
			%Table:SB6% SB6
		WHERE
			SB6.%NotDel%
			AND SB6.B6_SALDO > 0
			AND SB6.B6_TIPO = 'E'
			AND SB6.B6_PODER3 = 'R'
			AND SB6.B6_FILIAL = %XFILIAL:SB6%
			AND SB6.B6_TPCF IN %Exp:cTipo%
		GROUP BY
			SB6.B6_FILIAL,
			SB6.B6_CLIFOR,
			SB6.B6_LOJA,
			SB6.B6_TPCF
		ORDER BY
			SB6.B6_FILIAL,
			SB6.B6_CLIFOR,
			SB6.B6_LOJA
	EndSql

	nReg:=Contar("XSB6","!EOF()")

	XSB6->(dbGoTop())

	ProcRegua(nReg)

	While XSB6->(!EOF())
		IncProc()
		If XSB6->TIPO == "F"
			cNome:=GetAdvFVal("SA2","A2_NOME",xFilial("SA2")+XSB6->CLIENTE+XSB6->LOJA,1,"Fornecedor Nao Encontrado")
		ElseIf 	 XSB6->TIPO == "C"
			cNome:=GetAdvFVal("SA1","A1_NOME",xFilial("SA1")+XSB6->CLIENTE+XSB6->LOJA,1,"Cliente Nao Encontrado")
		End
		RecLock((cAliasTMP),.T.)
		(cAliasTMP)->CLIENTE:=XSB6->CLIENTE
		(cAliasTMP)->LOJA:=XSB6->LOJA
		(cAliasTMP)->NOME:=  cNome
		(cAliasTMP)->TIPO:=  If(XSB6->TIPO == "F","Fornecedor","Cliente")
		(cAliasTMP)->SALDO:= XSB6->SALDO
		(cAliasTMP)->NOTAS:= XSB6->NOTAS
		(cAliasTMP)->DESDE:= STOD(XSB6->DESDE)
		MsUnLock()
		XSB6->(dbSkip())
	End

	XSB6->(dbCloseArea())

Return

/*/{Protheus.doc} CIRTP302
Mota tela de seleção de notas para retorno
@type function Tela
@version  1.0
@author mantonaccio
@since 20/08/2024
@param TIPO, character, indica se é processamento ou visualizacao
@return character, sem retorno
/*/
User Function CIRTP302(TIPO)
	Processa( {|| CIRTP312(TIPO) } , "Processando dados..." , "Aguarde" , .F. )
Return

/*/{Protheus.doc} CIRTP312
Processamnto de dados
@type function Processamento
@version  1.00
@author mantonaccio
@since 20/08/2024
@param TIPO, character, indica se é processamento ou visualizacao
@return character, sem retorno
/*/
Static Function CIRTP312(TIPO)
	// Variaveis Locais da Funcao
	Local oGet1
	Local oGet2
	Local oGet3
	Local oGet4
	Local oGet5
	Local oGet6
	Local bConfirm
	Local bSair
	Local nOpcao
	Local nObjLinha := c(160)
	Local nObjColun := c(400)
	Local nObjColun1 := c(450)
	Local nObjLargu := 55
	Local nObjAltur := 15
	Local aPergs   := {}
	Local nOperacao:=0
	Local nPos
	Local cNotaDev
	Local cSeriDev
	Private oBtnObj0
	Private oBtnObj1
	Private oGet7
	Private oGet8

	// Variaveis Private da Funcao
	Private oDlgNf				// Dialog Principal
	// Variaveis que definem a Acao do Formulario
	Private VISUAL := .F.
	Private INCLUI := .F.
	Private ALTERA := .F.
	Private DELETA := .F.
	// Privates das ListBoxes
	Private aListBox1 := {}
	Private oListBox1
	Private cFontNome   := 'Tahoma'
	Private oFontPadrao := TFont():New(cFontNome, , -12)
	Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .F.

	bConfirm := {|| oDlgNf:End(),nOpcao:=1}
	If TIPO == "R"
		bSair    := {|| Iif(MsgYesNo( 'Você tem certeza que deseja sair da rotina? ','Sair da rotina'),(oDlgNF:End()),nOpcao:=2) }
	Else
		bSair    := {|| oDlgNF:End(),nOpcao:=2 }
	End
	DEFINE MSDIALOG oDlgNf TITLE "Relacao de Notas Fiscais Terceiros com Saldo" FROM C(178),C(181) TO C(548),C(1200) PIXEL

	// Cria Componentes Padroes do Sistema
	@ C(007),C(014) Say "Cliente" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgNf
	@ C(007),C(086) Say "Loja" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgNf
	@ C(007),C(159) Say "Nome" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgNf
	@ C(007),C(390) Say "Cliente/Fornecedor" Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgNf
	@ C(019),C(014) MsGet oGet1 Var (cAliasTmp)->CLIENTE Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgNf
	@ C(019),C(086) MsGet oGet2 Var (cAliasTmp)->LOJA  Size C(030),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgNf
	@ C(019),C(159) MsGet oGet3 Var (cAliasTmp)->NOME  Size C(220),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgNf
	@ C(019),C(390) MsGet oGet6 Var (cAliasTmp)->TIPO  Size C(060),C(009) COLOR CLR_BLACK Picture "@" PIXEL OF oDlgNf
	oBtnObj0  := TButton():New(nObjLinha, nObjColun, "Sair", oDlgNf, bSair, nObjLargu, nObjAltur, , oFontPadrao, , .T.)
	If TIPO == "R"
		oBtnObj1  := TButton():New(nObjLinha, nObjColun1, "Confirma Retorno", oDlgNf, bConfirm, nObjLargu, nObjAltur, , oFontPadrao, , .T.)

		//Total Selecionado
		@ C(163),C(220) Say "Qtd.Sel." Size C(018),C(008) COLOR CLR_GREEN PIXEL OF oDlgNf
		@ C(160),C(240) MsGet oGet7 Var nTotQtdSl Size C(050),C(009) COLOR CLR_BLACK Picture "@ER 999,999,999.99" PIXEL OF oDlgNf
		@ C(163),C(300) Say "Valor Sel." Size C(030),C(008) COLOR CLR_GREEN PIXEL OF oDlgNf
		@ C(160),C(320) MsGet oGet8 Var nTotValSl Size C(050),C(009) COLOR CLR_BLACK Picture "@ER 999,999,999.99" PIXEL OF oDlgNf
	End
	@ C(163),C(010) Say "Qtd.Total" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgNf
	@ C(160),C(040) MsGet oGet4 Var nTotQtd Size C(060),C(009) COLOR CLR_BLACK Picture "@ER 999,999,999.99" PIXEL OF oDlgNf
	@ C(163),C(110) Say "Valor Total" Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgNf
	@ C(160),C(140) MsGet oGet5 Var nTotVal Size C(060),C(009) COLOR CLR_BLACK Picture "@ER 999,999,999.99" PIXEL OF oDlgNf

	// Cria ExecBlocks dos Componentes Padroes do Sistema
	oGet1:bWhen      := {|| .F. }
	oGet2:bWhen      := {|| .F. }
	oGet3:bWhen      := {|| .F. }
	oGet4:bWhen      := {|| .F. }
	oGet5:bWhen      := {|| .F. }
	oGet6:bWhen      := {|| .F. }
	If TIPO == "R"
		oGet7:bWhen      := {|| .F. }
		oGet8:bWhen      := {|| .F. }
	End
	// Chamadas das ListBox do Sistema
	fListBox1(TIPO)

	ACTIVATE MSDIALOG oDlgNf CENTERED

	If nOpcao == 1

		aAdd(aPergs,{3,"Operacao a Realizar",1,{"Retorno e Faturamento","Somente Retorno"},70,"",.T.})
		// Tipo 3 -> Radio
		//           [2]-Descricao
		//           [3]-Numerico contendo a opcao inicial do Radio
		//           [4]-Array contendo as opcoes do Radio
		//           [5]-Tamanho do Radio
		//           [6]-Validacao
		//           [7]-Flag .T./.F. Parametro Obrigatorio ?

		If ParamBox(aPergs, "Informe os parâmetros")
			nOperacao:=mv_par01
		Else
			Return(.F.)
		End

		Processa( {||CIRTP32A(nOperacao)}, "Aguarde...", "Gerando Nota de Entrada...",.T.)

		//Se tudo Ok
		lRet:=(cNFNumDV <> "NAO GERADA" .and. cNFNumVD <> "NAO GERADA" .and. cPVNum <> "NAO GERADO")

		cMsg := "Resumo da Operação "+CRLF+CRLF+CRLF
		cMsg += If(lRet,"Operação "+If(mv_par01==1,"Retorno/Faturamento","Retorno"),"Houveram Falhas na operação..Verifique")+CRLF+CRLF+CRLF
		cMsg += "Cliente: "+(cAliasTMP)->CLIENTE+"/"+(cAliasTMP)->LOJA+"-"+(cAliasTMP)->NOME+CRLF+CRLF
		cMsg += "NF Devolucao Gerada: "+If(!Empty(cNFNumDV),cNFNumDV,"NAO GERADO") +CRLF+CRLF
		cMsg += "PV Gerado: "+If(!Empty(cPVNum),cPVNum,"NAO GERADO") +CRLF+CRLF
		cMsg += "NF Venda Gerada: "+If(!Empty(cNFNumVD),cNFNumVD,"NAO GERADO")

		If lRet
			FWAlertSucess(cMsg,"Processo Concluido")
			Processa( {||CIRTP32D((cAliasTMP)->CLIENTE+(cAliasTMP)->LOJA+(cAliasTMP)->TIPO)}, "Aguarde...", "Atualizando Registros...",.T.)
		Else
			FWAlertError(cMsg,"Processo Incompleto")
			If !Empty(cNfNumDV) .and. cNFNumDV <> "NAO GERADA"

				If FWAlertNoYes("Deseja Excluir a NF de Devolucao : "+cNFNumDV,"Excluir NF DEvolucao")

					nPos:=AT("/",cNFNumDV)
					cNotaDev:=PADR(Substr(cNFNUMDV,1,nPos-1),9," ")
					cSeriDev:=PADR(Substr(cNFNUMDV,nPos+1,Len(cNFNumDV)),TamSX3("F1_SERIE")[01]," ")

					SF1->(dbSetOrder(1))
					SF1->(dbSeek(xFilial("SF1")+cNotaDev+cSeriDev))

					SD1->(dbSetOrder(1))
					SD1->(dbSeek(xFilial("SD1")+cNotaDev+cSeriDev))

					lMsErroAuto    := .F.
					Begin Transaction
						MSExecAuto({|x,y,z,a| MATA103(x,y,z)},aCabNFE,aItmNFE,5)
					End Transaction

					If !lMsErroAuto
						FWAlertSucess("Nota Fiscal "+ cNFNumDV+" Excluida com sucesso!","Exclusao de Nota")
					Else
						MostraErro()
						FWAlertError("Nao foi possivel excluir a Nota Fiscal "+cNFNumDV+CRLF+"Efetuar Exclusão Manual" ,"Falha Exclusao NF")
					End

				End
			End

			If !Empty(cPVNum ) .and. cPVNum <> "NAO GERADO"

				If FWAlertNoYes("Deseja Excluir o Pedido de Vendas : "+cPVNum ,"Exclui Pedido de Venda")

					SC5->(dbSetOrder(1))
					SC5->(dbSeek(xFilial("SC5")+cPVNum))

					SC6->(dbSetOrder(1))
					SC6->(dbSeek(xFilial("SC6")+cPVNum))

					lMsErroAuto    := .F.
					Begin Transaction
						MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabPDV, aItmPDV, 5, .F.)
					End Transaction

					If !lMsErroAuto
						FWAlertSucess("Pedido de Venda "+ cPVNum+" Excluido com sucesso!","Exclusao de Pedido de Venda")
					Else
						MostraErro()
						FWAlertError("Nao foi possivel excluir o Pedido de Venda  "+cPVNum+CRLF+" Efetuar Exclusão Manual" ,"Falha Exclusao PV")
					End

				End

			End

		End
	End
Return(.T.)

/*/{Protheus.doc} fListBox1
Array com as Notas Fiscais
@type function Tela
@version  1.0
@author mantonaccio
@since 20/08/2024
@param TIPO, character, indica se é processamento ou visualizacao
@return Character, sem retorno
/*/
Static Function fListBox1(TIPO)
	Local oOk 	   := LoadBitmap( GetResources(), "LBOK"       )
	Local oNo 	   := LoadBitmap( GetResources(), "LBNO"       )
	nTotQtd:=0
	nTotVal:=0

	If SELECT("TMP") > 0
		TMP->(dbCloseArea())
	End

	BeginSql Alias "TMP"
		SELECT
			SB6.B6_DOC,
			SB6.B6_SERIE,
			SB6.B6_EMISSAO,
			SB6.B6_PRODUTO,
			SB6.B6_UM,
			SB6.B6_SALDO,
			SB6.B6_IDENT,
			SB6.B6_LOCAL,
			SB6.B6_PRUNIT,
			SB6.B6_TPCF,
			SB1.B1_DESC
		FROM
			%Table:SB6% SB6
		INNER JOIN %Table:SB1% SB1
		ON SB6.B6_PRODUTO = SB1.B1_COD
			AND SB1.%NotDel%
			AND SB1.B1_FILIAL = %XFILIAL:SB1%
		WHERE
			SB6.%NotDel%
			AND SB6.B6_SALDO > 0
			AND SB6.B6_TIPO = 'E'
			AND SB6.B6_PODER3 = 'R'
			AND SB6.B6_FILIAL = %XFILIAL:SB6%
			AND SB6.B6_CLIFOR = %Exp:(cAliasTMP)->CLIENTE%
			AND SB6.B6_LOJA = %Exp:(cAliasTMP)->LOJA%
			AND SB6.B6_TPCF = %Exp:Substr((cAliasTMP)->TIPO,1,1)%
		ORDER BY
			SB6.B6_DOC,
			SB6.B6_SERIE,
			SB6.B6_PRODUTO
	EndSql

	nReg:=CONTAR("TMP","!EOF()")

	TMP->(dbGoTop())
	ProcRegua(nReg)
	aListBox1:={}

	While TMP->( ! EOF())
		IncProc()
		// Carrege aqui sua array da Listbox
		If TIPO == "R"
			Aadd(aListBox1,{.F.,;
				TMP->B6_DOC,;
				TMP->B6_SERIE,;
				STOD(TMP->B6_EMISSAO),;
				TMP->B6_PRODUTO,;
				TMP->B1_DESC,;
				TMP->B6_SALDO,;
				TMP->B6_IDENT,;
				TMP->B6_UM,;
				TMP->B6_LOCAL,;
				TMP->B6_PRUNIT})
		Else
			Aadd(aListBox1,{;
				TMP->B6_DOC,;
				TMP->B6_SERIE,;
				STOD(TMP->B6_EMISSAO),;
				TMP->B6_PRODUTO,;
				TMP->B1_DESC,;
				TMP->B6_SALDO,;
				TMP->B6_IDENT,;
				TMP->B6_UM,;
				TMP->B6_LOCAL,;
				TMP->B6_PRUNIT})
		End
		nTotQtd+=TMP->B6_SALDO
		nTotVal+=TMP->B6_SALDO * TMP->B6_PRUNIT
		TMP->(dbSkip())
	End
	TMP->(dbCloseArea())

	If TIPO == "R"
		@ C(038),C(014) ListBox oListBox1 Fields ;
			HEADER " ","Nota Fiscal","Serie","Dt.Emissao","Produto","Descricao","Saldo","Ident.PD3","UM","Local","Preco Unit";
			Size C(500),C(117) Of oDlgNf Pixel;
			ColSizes 50,50,30,50,050,050,50,30,30,30,30;
			On DBLCLICK ( aListBox1[oListBox1:nAt,1] := !(aListBox1[oListBox1:nAt,1]), FSomaSel(), oListBox1:Refresh() )
		oListBox1:SetArray(aListBox1)

		// Cria ExecBlocks das ListBoxes
		oListBox1:bLine 		:= {|| {;
			If(aListBox1[oListBox1:nAT,1],oOk,oNo),;
			aListBox1[oListBox1:nAT,02],;
			aListBox1[oListBox1:nAT,03],;
			aListBox1[oListBox1:nAT,04],;
			aListBox1[oListBox1:nAT,05],;
			aListBox1[oListBox1:nAT,06],;
			aListBox1[oListBox1:nAT,07],;
			aListBox1[oListBox1:nAT,08],;
			aListBox1[oListBox1:nAT,09],;
			aListBox1[oListBox1:nAT,10],;
			aListBox1[oListBox1:nAT,11]}}
	Else
		@ C(038),C(014) ListBox oListBox1 Fields ;
			HEADER "Nota Fiscal","Serie","Dt.Emissao","Produto","Descricao","Saldo","Ident.PD3","UM","Local","Prc Unit";
			Size C(500),C(117) Of oDlgNf Pixel;
			ColSizes 50,30,50,050,050,50,30,50,50
		oListBox1:SetArray(aListBox1)

		// Cria ExecBlocks das ListBoxes
		oListBox1:bLine 		:= {|| {;
			aListBox1[oListBox1:nAT,01],;
			aListBox1[oListBox1:nAT,02],;
			aListBox1[oListBox1:nAT,03],;
			aListBox1[oListBox1:nAT,04],;
			aListBox1[oListBox1:nAT,05],;
			aListBox1[oListBox1:nAT,06],;
			aListBox1[oListBox1:nAT,07],;
			aListBox1[oListBox1:nAT,08],;
			aListBox1[oListBox1:nAT,09],;
			aListBox1[oListBox1:nAT,10]}}
	End
Return Nil

/*/{Protheus.doc} FSOMASEL
Soma Valores e Quantidades das Notas Selecionadas
@type function Processamento
@version  1.00
@author mantonaccio
@since 16/09/2024
@return character, sem retorno definido
/*/
Static Function FSOMASEL()
	Local nI

	nTotQtdSL:=0
	nTotValSL:=0

	For nI := 1 To Len(aListBox1)
		If ! aListBox1[nI][1]
			Loop
		End
		nTotQtdSL+=aListBox1[nI][7]
		nTotValSL+=aListBox1[nI][7] * aListBox1[nI][11]
	Next
	oGet7:Refresh()
	oGet8:Refresh()
Return

/*/{Protheus.doc} C
Reposiciona tela
@type function Tela
@version 1.0
@author mantonaccio
@since 20/08/2024
@param nTam, numeric, posicao a ajustar
@return numeric, posicao ajustada
/*/
Static Function C(nTam)
	Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
		nTam *= 0.8
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
		nTam *= 1
	Else	// Resolucao 1024x768 e acima
		nTam *= 1.28
	EndIf

	//³Tratamento para tema "Flat"³
	If "MP8" $ oApp:cVersion
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
			nTam *= 0.90
		EndIf
	EndIf
Return Int(nTam)

/*/{Protheus.doc} CIRTP32A
Gera Nf de Entrada de devolucao de Poder terceiro
@type function Processamento
@version 1.0
@author mantonaccio
@since 20/08/2024
@param nOperacao, numeric, Indica qual operação a ser executada
/*/

Static Function CIRTP32A(nOperacao)
	Local aCab     := {}
	Local aItem    := {}
	Local aItens   := {}
	Local cArmazem := Space(TamSX3("D1_LOCAL")[01])
	Local cItNFOri
	Local nI       := 0
	Local nItemNF
	Local aPergs:={}

	cArmazem := SuperGetMv("CI_P3LOCAL",.F.,"03")

	lMsErroAuto := .F.
	lMsHelpAuto := .T.

	aCab        := {}
	aItem       := {}
	aItens      := {}

	If Substr((cAliasTmp)->TIPO,1,1) == "C"
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1")+(cAliasTmp)->CLIENTE+(cAliasTmp)->LOJA))
			If SA1->A1_MSBLQL == "1"
				cNFNumDV:="NAO GERADA"
				cNFNumVD:="NAO GERADA"
				cPVNum :="NAO GERADO"
				FWAlertError("Cliente: "+(cAliasTmp)->CLIENTE+"-"+(cAliasTmp)->LOJA+" Bloqueado para uso...Verifique!!","Cliente Bloqueado (NFE)")
				Return(.F.)
			End
		End
		//Verifica Outros Bloqueios
		ZZN->(dbSetOrder(1))
		If ZZN->(dbSeek(xFilial("ZZN")+(cAliasTmp)->CLIENTE+(cAliasTmp)->LOJA))
			If ZZN->ZZN_BLQOUT == "1"
				cNFNumDV:="NAO GERADA"
				cNFNumVD:="NAO GERADA"
				cPVNum :="NAO GERADO"
				FWAlertError("Cliente: "+(cAliasTmp)->CLIENTE+"-"+(cAliasTmp)->LOJA+" Bloqueado para outr.Movimentacoes...Verifique!!","Cliente Bloqueado(NFE)")
				Return(.F.)
			End
			If ZZN->ZZN_BLOQ == "1" .and. nOperacao == 1
				If ! FWAlertYesNo("O Cliente tem BLOQUEIO DE FATURAMENTO"+CRLF+CRLF+;
						"É possível Gerar a NF de DEVOLUÇÃO PORÉM não será possivel gerar faturamento "+CRLF+CRLF+;
						"para esse Cliente "+CRLF+CRLF+;
						"Deseja Continuar? ","Cliente com Bloqueio Faturamento")
					cNFNumDV := "NAO GERADA"
					cNFNumVD := "NAO GERADA"
					cPVNum   := "NAO GERADO"
					Return (.F.)
				End
			End
		End
	ElseIf Substr((cAliasTmp)->TIPO,1,1) == "F"
		SA2->(dbSetOrder(1))
		If SA2->(dbSeek(xFilial("SA2")+(cAliasTmp)->CLIENTE+(cAliasTmp)->LOJA))
			If SA2->A2_MSBLQL == "1"
				cNFNumDV:="NAO GERADA"
				cNFNumVD:="NAO GERADA"
				cPVNum :="NAO GERADO"
				FWAlertError("Fornecedor: "+(cAliasTmp)->CLIENTE+"-"+(cAliasTmp)->LOJA+" Bloqueado para uso...Verifique!!","Fornecedor Bloqueado(NFE)")
				Return(.F.)
			End
		End
	End

	//Solicitação para  escolher armazem entrada
	aadd(aPergs, {1, "Armazem para Entrada"   , cArmazem, "", ".T.", "NNR"   , ".T.", 80, .T.})
	If ParamBox(aPergs, "Informe os parâmetros")
		cArmazem := MV_PAR01
	EndIf
	cArmazem:=If(Empty(cArmazem),aListBox1[nI][10],cArmazem)
	// Fim Solicitação para escolher armazem entrada

	cNum :=  NxtSx5Nota(SuperGetMv("CI_P3DVSNF",.F.,"DNF"), .T., GetNewPar("MV_TPNRNFS","1"))

	nItemNF:=0
	For nI := 1 To Len(aListBox1)

		If ! aListBox1[nI][1]
			Loop
		End

		nItemNF++
		//Verifica Bloqueios
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1")+aListBox1[nI][5]))
			If SB1->B1_MSBLQL == "1"
				cNFNumDV:="NAO GERADA"
				cNFNumVD:="NAO GERADA"
				cPVNum :="NAO GERADO"
				FWAlertError("Produto: "+aListBox1[nI][05]+ " Bloqueado para uso...Verifique!","Produto Bloqueado")
				Return(.F.)
			End
		End

		//1		2           3         4           5         6          7        8          9     10      11
		//" ","Nota Fiscal","Serie","Dt.Emissao","Produto","Descricao","Saldo","Ident.PD3","UM","Local","Preco Unit";

		If Len(aCab) == 0
			aadd(aCab, {"F1_DOC"    , cNum                              , NIL})
			aadd(aCab, {"F1_SERIE"  , SuperGetMv("CI_P3DVSNF",.F.,"DNF"), NIL})
			aadd(aCab, {"F1_FORNECE", (cAliasTmp)->CLIENTE              , NIL})
			aadd(aCab, {"F1_LOJA"   , (cAliasTmp)->LOJA                 , NIL})
			aadd(aCab, {"F1_EMISSAO", DDATABASE                         , NIL})
			aadd(aCab, {"F1_DTDIGIT", DDATABASE                         , NIL})
			aadd(aCab, {"F1_TIPO"   , "B"                               , NIL})
			aadd(aCab, {"F1_FORMUL" , "S"                               , NIL})
			aadd(aCab, {"F1_ESPECIE", "NF"                              , NIL})
			aadd(aCab, {"F1_COND"   , SuperGetMv("CI_P3DVCPG",.F.,"011") , NIL})
			aadd(aCab, {"F1_DESPESA", 0                                 , Nil})
			aadd(aCab, {"F1_DESCONT", 0                                 , Nil})
			aadd(aCab, {"F1_SEGURO" , 0                                 , Nil})
			aadd(aCab, {"F1_FRETE"  , 0                                 , Nil})
			aadd(aCab, {"F1_MOEDA"  , 1                                 , Nil})
			aadd(aCab, {"F1_TXMOEDA", 1                                 , Nil})
			aadd(aCab, {"F1_STATUS" , "A"                               , Nil})
			aadd(aCab, {"F1_VOLUME1", 0                                 , Nil})
			aadd(aCab, {"F1_PLIQUI" , 0                                 , Nil})
			aadd(aCab, {"F1_PBRUTO" , 0                                 , Nil})
		End

		BeginSql Alias "XSD2"
			SELECT
				SD2.D2_ITEM
			FROM
				%Table:SD2% SD2
			WHERE
				SD2.%NotDel%
				AND SD2.D2_DOC = %Exp:aListBox1[nI][02]%
				AND SD2.D2_SERIE = %Exp:aListBox1[nI][03]%
				AND SD2.D2_COD = %Exp:aListBox1[nI][05]%
				AND SD2.D2_IDENTB6 = %Exp:aListBox1[nI][08]%
		EndSql
		cItNFOri:=XSD2->D2_ITEM
		XSD2->(dbCloseArea())
		If Empty(cItNfOri)
			cItNfOri:=Posicione("SD2",3,xFilial("SD2")+aListBox1[nI][02]+aListBox1[nI][03],"D2_ITEM")
		End

		aItem := {}
		aadd(aItem , {"D1_ITEM"   , StrZero(nItemNF,4,0)               , NIL})
		aadd(aItem , {"D1_COD"    , aListBox1[nI][05]                  , NIL})
		aadd(aItem , {"D1_UM"     , aListBox1[nI][09]                  , NIL})
		aadd(aItem , {"D1_LOCAL"  , cArmazem		                   , NIL})
		aadd(aItem , {"D1_QUANT"  , aListBox1[nI][07]                  , NIL})
		aadd(aItem , {"D1_VUNIT"  , aListBox1[nI][11]                  , NIL})
		aadd(aItem , {"D1_TOTAL"  , aListBox1[nI][07]*aListBox1[nI][11], NIL})
		aadd(aItem , {"D1_NFORI"  , aListBox1[nI][02]                  , NIL})
		aadd(aItem , {"D1_SERIORI", aListBox1[nI][03]                  , NIL})
		aadd(aItem , {"D1_ITEMORI", cItNfOri                           , NIL})
		aadd(aItem , {"D1_IDENTB6", aListBox1[nI][08]                  , NIL})
		aadd(aItem , {"D1_TES"    , SuperGetMv("CI_P3DVTES",.F.,"3P4") , NIL}) //TES DEVOLUCAO - Poder3
		aadd(aItens, aItem)

	Next

	If Len(aCab)+Len(aItens) > 0

		Begin Transaction

			MSExecAuto({|x,y,z,a| MATA103(x,y,z)},aCab,aItens,3)

		End Transaction

		If ! lMsErroAuto

			aItmNFE:=aClone(aItens)
			aCabNFE=aClone(aCab)

			cNFNumDV  :=SF1->F1_DOC+"/"+SF1->F1_SERIE
			FWAlertSucess("NF de Devolucao "+cNFNumDV+" Gerada com Sucesso !!!","NF Entrada Gerada")

			If nOperacao == 1
				Processa( {||CIRTP32B()}, "Aguarde...", "Gerando Pedido de Venda...",.T.)
			Else
				cPVNum:="Nao Necessario "
				cNFNumVD:="Nao Necessario"
			End
		Else
			cNFNumDV:="NAO GERADA"
			cNFNumVD:="NAO GERADA"
			cPVNum :="NAO GERADO"
			MostraErro()
		EndIf

	Else
		FWAlertError("Nao foram selecionadas Notas Fiscais para Devolucao","Nao Selecionado")
	End

Return (NIL)

/*/{Protheus.doc} CIRTP32B
Gera Pedido de Venda  para poder Terceiros
@type function Processamento
@version 1.0
@author mantonaccio
@since 20/08/2024
/*/
Static Function CIRTP32B()
	Local cDoc             := "" //Numero do Pedido de Vendas (alteracao ou exclusao)
	Local aCabec           := {}
	Local aItens           := {}
	Local aLinha           := {}
	Local nItemPV          := 0
	Local nI
	Local aPergs           := {}
	Local cCondPG          := Space(TamSX3("C5_CONDPAG")[01])
	Local cCliVda          := Space(TamSX3("C5_CLIENTE")[01])
	Local cLojVda          := Space(TamSX3("C5_LOJACLI")[01])
	Local cRotVda          := Space(TamSX3("C5_XROTA")[01])
	Local cIdCrga          := Space(TamSX3("C5_IDCARGA")[01])
	Local cTabPrc          := Space(TamSX3("C5_TABELA")[01])
	Local cMenNota         := "Fat.Ref. NF(s): "
	Local cArmazem		   := Space(TamSX3("C6_LOCAL")[01])

	lMsErroAuto    := .F.
	lAutoErrNoFile := .F.

/*
	//Verifica Bloqueios
	If Substr((cAliasTmp)->TIPO,1,1) == "C"
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1")+(cAliasTmp)->CLIENTE+(cAliasTmp)->LOJA))
			If SA1->A1_MSBLQL == "1"
			//	cNFNumVD:="NAO GERADA"
			//	cPVNum :="NAO GERADO"
			//	FWAlertError("Cliente: "+(cAliasTmp)->CLIENTE+"-"+(cAliasTmp)->LOJA+" Bloqueado para uso...Verifique!!","Cliente Bloqueado(NFS)")
			//		Return(.F.)
				If ! FWAlertYesNo("O Cliente tem BLOQUEIO TOTAL"+CRLF+CRLF+;
						"Deseja Continuar Alterando o Cliente? ","Cliente com Bloqueio TOTAL (NFS)")
					cNFNumVD:="NAO GERADA"
					cPVNum :="NAO GERADO"
					Return (.F.)
				End
			End
		End
		//Verifica Outros Bloqueios
		ZZN->(dbSetOrder(1))
		If ZZN->(dbSeek(xFilial("ZZN")+(cAliasTmp)->CLIENTE+(cAliasTmp)->LOJA))
			If ZZN->ZZN_BLOQ == "1"
				//cNFNumVD:="NAO GERADA"
				//cPVNum :="NAO GERADO"
				//FWAlertError("Cliente: "+(cAliasTmp)->CLIENTE+"-"+(cAliasTmp)->LOJA+" Bloqueado para Faturamento..Verifique!!","Cliente Bloqueado(NFS)")
				//Return(.F.)
					If ! FWAlertYesNo("O Cliente tem BLOQUEIO para Faturamento"+CRLF+CRLF+;
						"Deseja Continuar Alterando o Cliente? ","Cliente com Bloqueio para Faturamento (NFS)")
					cNFNumDV:="NAO GERADA"
					cNFNumVD:="NAO GERADA"
					cPVNum :="NAO GERADO"
					Return (.F.)
				End
			
			End
		End
	ElseIf Substr((cAliasTmp)->TIPO,1,1) == "F"
		SA2->(dbSetOrder(1))
		If SA2->(dbSeek(xFilial("SA2")+(cAliasTmp)->CLIENTE+(cAliasTmp)->LOJA))
			If SA2->A2_MSBLQL == "1"
				cNFNumVD:="NAO GERADA"
				cPVNum :="NAO GERADO"
				FWAlertError("Fornecedor: "+(cAliasTmp)->CLIENTE+"-"+(cAliasTmp)->LOJA+" Bloqueado para uso...Verifique!!","Fornecedor Bloqueado(NFS)")
				Return(.F.)
			End
		End
	End
*/

	//Carrega variaveis previamente
	cCliVda  := (cAliasTmp)->CLIENTE
	cLojVda  := (cAliasTmp)->LOJA
	cCondPG  := SuperGetMv("CI_P3VDCPG",.F.,"011")
	cRotVda  := SuperGetMv("CI_P3XROTA",.F.,"MG02")
	cIdCrga  := SuperGetMv("CI_P3IDCRG",.F.,"DEVPD3")
	cTabPrc  := SuperGetMv("CI_P3ITPRC",.F.,"001")
	// Solicitação para colocar armazem onde será feita a venda
	cArmazem := SuperGetMv("CI_P3LOCAL",.F.,"03")

	//Conforme Definido a Condição de Pagamento e outras informações deverá ser selecionada
	aadd(aPergs, {1, "Condicao de Pagamento", cCondPg , "", ".T.", "SE4", ".T.", 80, .T.})
	aadd(aPergs, {1, "Cliente para Venda"   , cCliVda , "", ".T.", "SA1", ".T.", 80, .T.})
	aadd(aPergs, {1, "Loja Cliente p/Venda" , cLojVda , "", ".T.", "SA1", ".T.", 80, .T.})
	aadd(aPergs, {1, "Tabela Preco"         , cTabPrc , "", ".T.", "DA0", ".T.", 80, .F.})
	aadd(aPergs, {1, "Rota p/Venda"         , cRotVda , "", ".T.", "ZZD", ".T.", 80, .T.})
	aadd(aPergs, {1, "ID Carga p/Venda"     , cIdCrga , "", ".T.", ""   , ".T.", 80, .T.})
	// Solicitação para colocar armazem onde será feita a venda
	aadd(aPergs, {1, "Armazem para Venda"   , cArmazem, "", ".T.", "NNR", ".T.", 80, .T.})

	If ParamBox(aPergs, "Informe os parâmetros")
		cCondPG  := MV_PAR01
		cCliVda  := MV_PAR02
		cLojVda  := MV_PAR03
		cTabPrc  := MV_PAR04
		cRotVda  := MV_PAR05
		cIdCrga  := MV_PAR06
		cArmazem := MV_PAR07
	Else
		Return(.F.)
	EndIf

	//Verifica Cliente
	If Substr((cAliasTmp)->TIPO,1,1) == "C"
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1")+cCliVda+cLojVda))
			If SA1->A1_MSBLQL == "1"
				cNFNumVD:="NAO GERADA"
				cPVNum :="NAO GERADO"
				FWAlertError("Cliente: "+cCliVda+"-"+cLojVda+" Bloqueado para uso...Verifique!!","Cliente Bloqueado(NFS)")
				Return(.F.)
			End
		End
		
		//Verifica Outros Bloqueios
		ZZN->(dbSetOrder(1))
		If ZZN->(dbSeek(xFilial("ZZN")+cCliVda+cLojVda))
			If ZZN->ZZN_BLOQ == "1"
				cNFNumVD:="NAO GERADA"
				cPVNum :="NAO GERADO"
				FWAlertError("Cliente: "+cCliVda+cLojVda+" Bloqueado para Faturamento..Verifique!!","Cliente Bloqueado(NFS)")
				Return(.F.)				
			End
		End
	
	ElseIf Substr((cAliasTmp)->TIPO,1,1) == "F"
		SA2->(dbSetOrder(1))
		If SA2->(dbSeek(xFilial("SA2")+cCliVda+cLojVda))
			If SA2->A2_MSBLQL == "1"
				cNFNumVD:="NAO GERADA"
				cPVNum :="NAO GERADO"
				FWAlertError("Fornecedor: "+cCliVda+cLojVda+" Bloqueado para uso...Verifique!!","Fornecedor Bloqueado(NFS)")
				Return(.F.)
			End
		End
	End
	//Fim verificacao de CLientes

	//Mensagem Nota
	For nI := 1 To Len(aListBox1)

		If ! aListBox1[nI][1]
			Loop
		End

		//Verifica Bloqueios de produto
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1")+aListBox1[nI][5]))
			If SB1->B1_MSBLQL == "1"
				cNFNumVD:="NAO GERADA"
				cPVNum :="NAO GERADO"
				FWAlertError("Produto: "+aListBox1[nI][05]+ " Bloqueado para uso...Verifique!","Produto Bloqueado")
				Return(.F.)
			End
		End

		// Verifica se o produto consta na tabela
		If ! Empty(cTabPrc)
			DA1->(dbSetOrder(1))
			If ! DA1->(dbSeek(xFilial("DA1")+cTabPrc+aListBox1[nI][05]))
				cNFNumVD:="NAO GERADA"
				cPVNum :="NAO GERADO"
				FWAlertError("Produto "+aListBox1[nI][05]+CRLF+"Nao consta da Tabela de Precos "+cTabPrc+CRLF+"Favor Verificar","Nao encontrado na Tabela")
				Return(.F.)
			End
		End

		If  ! (aListBox1[nI][02] $ cMenNota)
			cMenNota+=aListBox1[nI][02]+"/"
		End

	Next
	cMenNota:=Substr(cMenNota,1,Len(cMenNota)-1)

	//Montagem Pedido
	nItemPV:=0

	cDoc := GetSxeNum("SC5", "C5_NUM")
	RollBackSx8()

	For nI := 1 To Len(aListBox1)

		If ! aListBox1[nI][1]
			Loop
		End

		nItemPV++

		If Len(aCabec) == 0
			aadd(aCabec, {"C5_NUM"    , cDoc     , Nil})
			aadd(aCabec, {"C5_TIPO"   , "N"      , Nil})
			aadd(aCabec, {"C5_CLIENTE", cCliVda  , Nil})
			aadd(aCabec, {"C5_LOJACLI", cLojVda  , Nil})
			aadd(aCabec, {"C5_LOJAENT", cLojVda  , Nil})
			aadd(aCabec, {"C5_EMISSAO", DDATABASE, Nil})
			aadd(aCabec, {"C5_IDCARGA", cIdCrga  , Nil})
			aadd(aCabec, {"C5_XROTA"  , cRotVda  , Nil})
			aadd(aCabec, {"C5_VEND1"  , "000001" , Nil})
			aadd(aCabec, {"C5_VOLUME1", 1        , Nil})
			aadd(aCabec, {"C5_ESPECI1", "CAIXA"  , Nil})
			aadd(aCabec, {"C5_TPFRETE", "S"      , Nil})
			aadd(aCabec, {"C5_MENNOTA", cMenNota , Nil})
			aadd(aCabec, {"C5_CONDPAG", cCondPG  , Nil})
			If !Empty(cTabPrc)
				aadd(aCabec, {"C5_TABELA", cTabPrc  , Nil})
			End
		End

		aLinha := {}
		aadd(aLinha, {"C6_ITEM"   , StrZero(nItemPV,2)                 , Nil})
		aadd(aLinha, {"C6_PRODUTO", aListBox1[nI][05]                  , Nil})
		aadd(aLinha, {"C6_QTDVEN" , aListBox1[nI][07]                  , Nil})
		aadd(aLinha, {"C6_QTDLIB" , aListBox1[nI][07]                  , Nil})
		aadd(aLinha, {"C6_LOCAL"  , cArmazem		                   , Nil})
		aadd(aLinha, {"C6_TES"    , SuperGetMv("CI_P3VDTES",.F.,"6L2") , Nil})
		If Empty(cTabPrc)
			aadd(aLinha, {"C6_PRCVEN" , aListBox1[nI][11]                  , Nil})
			aadd(aLinha, {"C6_PRUNIT" , aListBox1[nI][11]                  , Nil})
			aadd(aLinha, {"C6_VALOR"  , aListBox1[nI][07]*aListBox1[nI][11], Nil})
		End
		aadd(aItens, aLinha)
	Next

	If Len(aCabec) + Len(aItens) > 0
		Begin Transaction

			MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabec, aItens, 3, .F.)

		End Transaction

		If !lMsErroAuto

			aItmPDV:=aClone(aItens)
			aCabPDV=aClone(aCabec)

			FWAlertSucess("Pedido de Venda "+ cDoc + " Gerado com Sucesso !!!","Pedido de Venda Gerado")

			cPVNum :=cDoc
			Processa( {||CIRTP32C()}, "Aguarde...", "Gerando Nota Fiscal de Venda...",.T.)
		Else
			cNFNumVD:="NAO GERADA"
			cPVNum :="NAO GERADO"
			MOSTRAERRO()
		EndIf
	Else
		cNFNumVD:="NAO GERADA"
		cPVNum :="NAO GERADO"
	EndIf

Return (NIL)

/*/{Protheus.doc} CIRTP32C
Gerar NF de Venda de poder Terceiros
@type function Processamento
@version 1.0
@author mantonaccio
@since 20/08/2024
/*/
Static Function CIRTP32C()
	Local aPvlDocS := {}
	Local cDoc    := ""

	If Substr((cAliasTmp)->TIPO,1,1) == "C"
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1")+(cAliasTmp)->CLIENTE+(cAliasTmp)->LOJA))
			If SA1->A1_MSBLQL == "1"
				cNFNumVD:="NAO GERADA"
				FWAlertError("Cliente: "+(cAliasTmp)->CLIENTE+"-"+(cAliasTmp)->LOJA+" Bloqueado para uso...Verifique!!","Cliente Bloqueado")
				Return(.F.)
			End
		End
		//Verifica Outros Bloqueios
		ZZN->(dbSetOrder(1))
		If ZZN->(dbSeek(xFilial("ZZN")+(cAliasTmp)->CLIENTE+(cAliasTmp)->LOJA))
			If ZZN->ZZN_BLOQ == "1"
				cNFNumVD:="NAO GERADA"
				FWAlertError("Cliente: "+(cAliasTmp)->CLIENTE+"-"+(cAliasTmp)->LOJA+" Bloqueado para Faturamento..Verifique!!","Cliente Bloqueado")
				Return(.F.)
			End
		End
	ElseIf Substr((cAliasTmp)->TIPO,1,1) == "F"
		SA2->(dbSetOrder(1))
		If SA2->(dbSeek(xFilial("SA2")+(cAliasTmp)->CLIENTE+(cAliasTmp)->LOJA))
			If SA2->A2_MSBLQL == "1"
				cNFNumVD:="NAO GERADA"
				FWAlertError("Fornecedor: "+(cAliasTmp)->CLIENTE+"-"+(cAliasTmp)->LOJA+" Bloqueado para uso...Verifique!!","Fornecedor Bloqueado")
				Return(.F.)
			End
		End
	End

	SC5->(DbSetOrder(1))
	SC5->(MsSeek(xFilial("SC5")+cPVNum))

	SC6->(dbSetOrder(1))
	SC6->(MsSeek(xFilial("SC6")+SC5->C5_NUM))

	//É necessário carregar o grupo de perguntas MT460A, se não será executado com os valores default.
	Pergunte("MT460A",.F.)

	// Obter os dados de cada item do pedido de vendas liberado para gerar o Documento de Saída
	While SC6->( ! EOF() .And. C6_FILIAL == xFilial("SC6")) .And. SC6->C6_NUM == SC5->C5_NUM

		SC9->(DbSetOrder(1))
		SC9->(MsSeek(xFilial("SC9")+SC6->(C6_NUM+C6_ITEM))) //FILIAL+NUMERO+ITEM

		//Libero automaticamete pois não precisa de crivo
		RecLock("SC9",.F.)
		SC9->C9_BLEST := "  "
		SC9->C9_BLCRED:="  "
		MsUnLock()

		SE4->(DbSetOrder(1))
		SE4->(MsSeek(xFilial("SE4")+SC5->C5_CONDPAG) )  //FILIAL+CONDICAO PAGTO

		SB1->(DbSetOrder(1))
		SB1->(MsSeek(xFilial("SB1")+SC6->C6_PRODUTO))    //FILIAL+PRODUTO

		SB2->(DbSetOrder(1))
		SB2->(MsSeek(xFilial("SB2")+SC6->(C6_PRODUTO+C6_LOCAL))) //FILIAL+PRODUTO+LOCAL

		SF4->(DbSetOrder(1))
		SF4->(MsSeek(xFilial("SF4")+SC6->C6_TES))   //FILIAL+TES

		If AllTrim(SC9->C9_BLEST) == "" .And. AllTrim(SC9->C9_BLCRED) == ""
			AAdd(aPvlDocS,{ SC9->C9_PEDIDO,;
				SC9->C9_ITEM,;
				SC9->C9_SEQUEN,;
				SC9->C9_QTDLIB,;
				SC9->C9_PRCVEN,;
				SC9->C9_PRODUTO,;
				.F.,;
				SC9->(RecNo()),;
				SC5->(RecNo()),;
				SC6->(RecNo()),;
				SE4->(RecNo()),;
				SB1->(RecNo()),;
				SB2->(RecNo()),;
				SF4->(RecNo())})
		EndIf

		SC6->(DbSkip())
	EndDo

	SetFunName("MATA461")

	If Len(aPvlDocS) > 0
		//Begin Transaction

		cDoc := MaPvlNfs(  /*aPvlNfs*/         aPvlDocS,;  // 01 - Array com os itens a serem gerados
			/*cSerieNFS*/       SuperGetMv("CI_P3VDSNF",.F.,"1  "),;    // 02 - Serie da Nota Fiscal
			/*lMostraCtb*/      .F.,;       // 03 - Mostra Lançamento Contábil
			/*lAglutCtb*/       .F.,;       // 04 - Aglutina Lançamento Contábil
			/*lCtbOnLine*/      .F.,;       // 05 - Contabiliza On-Line
			/*lCtbCusto*/       .T.,;       // 06 - Contabiliza Custo On-Line
			/*lReajuste*/       .F.,;       // 07 - Reajuste de preço na Nota Fiscal
			/*nCalAcrs*/        0,;         // 08 - Tipo de Acréscimo Financeiro
			/*nArredPrcLis*/    0,;         // 09 - Tipo de Arredondamento
			/*lAtuSA7*/         .T.,;       // 10 - Atualiza Amarração Cliente x Produto
			/*lECF*/            .F.,;       // 11 - Cupom Fiscal
			/*cEmbExp*/         "",;   		// 12 - Número do Embarque de Exportação
			/*bAtuFin*/         {||},;      // 13 - Bloco de Código para complemento de atualização dos títulos financeiros
			/*bAtuPGerNF*/      {||},;      // 14 - Bloco de Código para complemento de atualização dos dados após a geração da Nota Fiscal
			/*bAtuPvl*/         {||},;      // 15 - Bloco de Código de atualização do Pedido de Venda antes da geração da Nota Fiscal
			/*bFatSE1*/         {|| .T. },; // 16 - Bloco de Código para indicar se o valor do Titulo a Receber será gravado no campo F2_VALFAT quando o parâmetro MV_TMSMFAT estiver com o valor igual a "2".
			/*dDataMoe*/        dDatabase,; // 17 - Data da cotação para conversão dos valores da Moeda do Pedido de Venda para a Moeda Forte
			/*lJunta*/          .F.)        // 18 - Aglutina Pedido Iguais

		//End Transaction

		If !Empty(cDoc)
			cNFNumVD:= cSerie + "-" + cDoc
			FWAlertSucess("Documento de Saída: "+cNFNumVD + ", gerado com sucesso!!!","NF Saida Gerada")
		Else
			cNFNumVD:="NAO GERADA"
		EndIf
	Else
		cNFNumVD:="NAO GERADA"
	End
Return (NIL)

/*/{Protheus.doc} CIRTP32D
Atualiza saldo de browse de poder Terceiros
@type function Processamento
@version 1.0
@author mantonaccio
@since 20/08/2024
/*/
Static Function CIRTP32D(CLIENTE,LOJA,TIPO)

	If SELECT("TMP") > 0
		TMP->(dbCloseArea())
	End

	BeginSql Alias "TMP"
		SELECT
			SUM(SB6.B6_SALDO) AS SALDO,
			COUNT(*) AS NOTAS
		FROM
			%Table:SB6% SB6
		WHERE
			SB6.%NotDel%
			AND SB6.B6_SALDO > 0
			AND SB6.B6_TIPO = 'E'
			AND SB6.B6_PODER3 = 'R'
			AND SB6.B6_FILIAL = %XFILIAL:SB6%
			AND SB6.B6_CLIFOR = %Exp:(cAliasTMP)->CLIENTE%
			AND SB6.B6_LOJA = %Exp:(cAliasTMP)->LOJA%
			AND SB6.B6_TPCF = %Exp:Substr((cAliasTMP)->TIPO,1,1)%
	EndSql

	If TMP->NOTAS == 0
		(cAlias)->(dbSetOrder(1))
		If (cAlias)->(dbSeek((cAliasTmp)->CLIENTE+(cAliasTmp)->LOJA+(cAliasTMP)->TIPO))
			RecLock((cAlias),.F.)
			(cAlias)->(dbDelete())
			MsUnlock()
		End
	Else
		(cAlias)->(dbSetOrder(1))
		If (cAlias)->(dbSeek((cAliasTmp)->CLIENTE+(cAliasTmp)->LOJA+(cAliasTMP)->TIPO))
			RecLock((cAlias),.F.)
			(cAliasTMP)->SALDO:= TMP->SALDO
			(cAliasTMP)->NOTAS:= TMP->NOTAS
			MsUnlock()
		End
	End
	TMP->(dbCloseArea())
	oBrowse:Refresh()

Return (NIL)
