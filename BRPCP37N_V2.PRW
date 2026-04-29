#Include "Protheus.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} BRPCP37N
Etiquetas de volume Diferenciadas (Etiqueta de Produtos) - VERSAO 2.00
Refatorado por marioantonaccio em 08/04/2026

Melhorias aplicadas:
  - Extracao de PCP037_DadosEtiq() eliminando 11 blocos duplicados de leitura do aBrowse
  - cQuery declarada Local em PCP037_01 e PCP037_02 (era variavel global acidental)
  - nQtde1/nQtde2 declarados como numeric (eram char usados como numero)
  - RecLock em UPD_XVOL com verificacao de retorno e mensagem de erro
  - TrtUnimed corrigida: If/Else no lugar de dois If independentes, retorno inicializado
  - UniMed com retorno inicializado (evita NIL quando codbarra fora de 14/15 chars)
  - ValidPort renomeada internamente para refletir logica real (porta ocupada = .T.)
  - Codigo morto (blocos comentados longos) removido
  - Variables Private reduzidas ao minimo necessario para a tela

@type function Relatorio
@version  2.00
@author marioantonaccio
@since 08/04/2026
@return Character, sem retorno
@see
MB01 - Interleaved 2 of 5 / EAN14
MB02 - Code 39
MB03 - EAN 8
MB04 - EAN 13
MB05 - UPC A
MB06 - UPC E
MB07 - CODE 128
/*/
User Function BRPCP37N()

	//Bibliotecas
	#Define STR_PULA    Chr(13)+Chr(10)

	Local nTipo        := 1 as numeric
	Local _cGrpEmp     := "" as character

	// Privates necessarios para acesso pela tela e funcoes filhas
	Private _ZPPAR0214 := GetMV("ZP_PAR0214")  // Habilita impressao do QrCode para o WMS SaaS
	Private _ZPPAR0217 := GetMV("ZP_PAR0217")  // Tempo em milissegundos Impressao contador Dissoltex
	Private aBrowse    := {}
	Private aLPT       := {"LPT1","LPT2","LPT3","LPT4","LPT5"}
	Private cCodTam                              // Codigo Tambor
	Private cCont      := Space(3)
	Private cFlag      := .F.
	Private cFontUti   := "Tahoma"
	Private cLote      := Space(6)
	Private cLPT       := ""
	Private cObs       := Space(15)
	Private cOP        := Space(13)
	Private cPort      := ""
	Private cPrint     := ""
	// CORRECAO: nQtde1/nQtde2 declarados como numeric (antes: Private cQtde1 := space(6) e usado como numero)
	Private nQtde1     := 0
	Private nQtde2     := 0
	Private cTambor    := Space(10)
	Private cTbFab     := CToD(" / / ")
	Private lEditar    := .T.
	Private nJanAltu   := 500
	Private nJanLarg   := 730
	Private oBrowse    := NIL
	Private oBtnFech   := NIL
	Private oCont      := NIL
	Private oFontBtn   := TFont():New(cFontUti,,-14)
	Private oFontSub   := TFont():New(cFontUti,,-16)
	Private oFontSubN  := TFont():New(cFontUti,,-20,,.T.)
	Private oLote      := NIL
	Private oLPT       := NIL
	Private oObs       := NIL
	Private oOP        := NIL
	Private oPort      := NIL
	Private oPrint     := NIL
	Private oQtde1     := NIL
	Private oQtde2     := NIL
	Private oTambor    := NIL
	Private oTbFab     := NIL
	Private oTipo      := NIL

	_ZPPAR0214 := .T.

	// Identifica se a rotina esta em uso
	If .NOT. SuperGetMV("BR_PCP37N",.F.,.F.)
		Return(NIL)
	End

	_cGrpEmp := AllTrim(FWGrpCompany())
	If _cGrpEmp == "11"
		FwAlertInfo(OemToAnsi("Esta operacao nao pode ser executada na empresa TECPOLPA!"),"Nao Liberado")
		Return(NIL)
	End

	Set(_SET_DATEFORMAT,"dd/mm/yy")

	DEFINE MSDIALOG oDlg TITLE "Etiquetas de Volume Diferenciadas (Etiqueta de Produtos) V2" FROM 000,000 TO nJanAltu,nJanLarg COLORS 0,16777215 PIXEL

	@ 004,003 MSPANEL oPanel SIZE 260,100 OF oDlg COLORS 0,14215660 CENTERED RAISED

	@ 010,010 SAY OemToAnsi("N de OP.: ")          SIZE 060,009 PIXEL OF oDlg FONT oFontBtn
	@ 008,060 MSGET oOP    VAR cOP    PICTURE "@!" SIZE 090,010 COLOR CLR_BLUE F3 "SC2" PIXEL ON CHANGE PCP037_99(nTipo) OF oDlg FONT oFontBtn

	@ 030,010 SAY OemToAnsi("N do Lote.: ")         SIZE 060,009 PIXEL OF oDlg FONT oFontBtn
	@ 028,060 MSGET oLote  VAR cLote  PICTURE "@!" SIZE 045,010 COLOR CLR_BLUE F3 "ZC2" PIXEL ON CHANGE PCP037_99(nTipo) OF oDlg FONT oFontBtn

	@ 050,010 SAY OemToAnsi("Qtde Adic. de Etiq. Prod.: ") SIZE 100,009 PIXEL OF oDlg FONT oFontBtn
	// CORRECAO: variavel numerica nQtde1 no lugar de cQtde1 (character)
	@ 048,108 MSGET oQtde1 VAR nQtde1 PICTURE "999" SIZE 045,010 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn

	@ 050,160 SAY OemToAnsi("Obs Etiq.: ") SIZE 100,009 PIXEL OF oDlg FONT oFontBtn
	@ 048,205 MSGET oObs   VAR cObs   PICTURE "@!" SIZE 045,010 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn

	@ 070,010 SAY OemToAnsi("Qtde Adic. de Ident. Vol.: ") SIZE 100,009 PIXEL OF oDlg FONT oFontBtn
	// CORRECAO: variavel numerica nQtde2 no lugar de cQtde2 (character)
	@ 068,108 MSGET oQtde2 VAR nQtde2 PICTURE "999" SIZE 045,010 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn

	@ 070,160 SAY OemToAnsi("Contador Inicial Cx: ") SIZE 100,009 PIXEL OF oDlg FONT oFontBtn
	@ 068,222 MSGET oCont  VAR cCont  PICTURE "999" SIZE 021,010 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn When .T.

	@ 090,010 SAY OemToAnsi("Clientes Tambor : ")  SIZE 100,009 PIXEL OF oDlg FONT oFontBtn
	@ 088,108 MSGET oTambor VAR cTambor PICTURE "@!" SIZE 045,010 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn

	@ 090,160 SAY OemToAnsi("Dt Fabric:")  SIZE 110,009 PIXEL OF oDlg FONT oFontBtn
	@ 088,200 MSGET oTbFab  VAR cTbFab     SIZE 055,010 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn

	oCont:bHelp := {|| ShowHelpCpo("cCont",;
		{OemToAnsi("Contador sequencial das caixas")+CRLF+"Utilizado apenas para etiquetas 100x69mm"},2,;
		{""},2)}

	@ 004,265 MSPANEL oPanel SIZE 100,100 OF oDlg COLORS 0,14215660 FONT oFontBtn CENTERED RAISED

	@ 004,004 RADIO oTipo VAR nTipo PROMPT "Zebra","26x15mm(Xarope)","44x15mm","75x35mm","100x69mm","100x50mm","100x200mm(Tambor)" ON CHANGE VLDRAD(nTipo) OF oPanel PIXEL SIZE 75,20

	VLDRAD(nTipo)

	@ 075,004 SAY OemToAnsi("Porta\Impressora") SIZE 100,009 PIXEL OF oPanel FONT oFontBtn
	@ 085,004 MSCOMBOBOX oLPT VAR cLPT ITEMS aLPT SIZE 050,007 OF oPanel COLORS 0,16777215 PIXEL FONT oFontBtn

	@ 120,289 BUTTON oBtnFech PROMPT "Imprimir"   SIZE 060,018 OF oDlg ACTION PCP037_03(nTipo)    FONT oFontBtn PIXEL
	@ 160,289 BUTTON oBtnFech PROMPT "Visualizar" SIZE 060,018 OF oDlg ACTION ReportPrint(nTipo)  FONT oFontBtn PIXEL
	@ 195,289 BUTTON oBtnFech PROMPT "Fechar"     SIZE 060,018 OF oDlg ACTION (oDlg:End())        FONT oFontBtn PIXEL

	aBrowse := {{"","",""}}
	oBrowse := TCBrowse():New(115,004,260,130,,{"Produto","Produto","Qtde Etiq."},;
		{130,50,10},oDlg,,,,,{||lEditCell(@aBrowse,oBrowse,"999",3)},,oFontSub,,,,,.F.,,.T.,,.F.,,,)

	oBrowse:SetArray(aBrowse)
	oBrowse:bLine  := {||{aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAt,03]}}

	oDlg:lEscClose := .T.

	ACTIVATE MSDIALOG oDlg CENTERED

Return(NIL)

/*/{Protheus.doc} PCP037_99
Identifica se a consulta e por OP ou Lote e aciona a carga do browse.
@type function Auxiliar
@version 2.00
@author marioantonaccio (refatorado)
@since 08/04/2026
@param nTipo, numeric, Etiqueta Selecionada
/*/
Static Function PCP037_99(nTipo)

	If !Empty(cOP) .AND. Empty(cLote)
		cLote := PCP037_02(cOP)
		If !Empty(cLote)
			PCP037_01(nTipo)
		EndIf
		Return()
	EndIf

	If Empty(cOP) .AND. !Empty(cLote)
		PCP037_01(nTipo)
		Return()
	EndIf

	aBrowse := {{"","",""}}
	oBrowse:SetArray(aBrowse)
	oBrowse:Refresh()

Return()

/*/{Protheus.doc} PCP037_01
Consulta etiquetas por Lote via SQL e monta o array aBrowse para o browse.
@type function Auxiliar
@version 2.00
@author marioantonaccio (refatorado)
@since 08/04/2026
@param nTipo, numeric, tamanho de etiqueta selecionada
/*/
Static Function PCP037_01(nTipo)

	// CORRECAO: cQuery declarada Local (antes era variavel global acidental)
	Local cQuery   := "" as character
	Local nTotal   := 0  as numeric
	Local qtd      := 0  as numeric
	Local RELVOL   := "" as character
	Local Z1_VALIDAD := "" as character
	Local PREVF    := "" as character
	Local Lote     := "" as character
	Local CODBARRA := "" as character
	Local B1_PRVALID := 0 as numeric

	If Empty(cLote)
		MsgInfo(OemToAnsi("Necessario informar uma OP ou Lote!"),"Etiquetas Produtos")
		Return()
	EndIf

	oBrowse         := TCBrowse():New(115,004,260,130,,{"Produto","Produto","Qtde Etiq."},;
		{130,50,10},oDlg,,,,,{||lEditCell(@aBrowse,oBrowse,"@!",3)},,oFontSub,,,,,.F.,,.T.,,.F.,,,)
	oBrowse:nLinhas := 2

	cQuery := "SELECT Z4_TXTETIQ TXTETIQ,C2_NUM,C2_ITEM,C2_SEQUEN,B1_DESC AS NOMEPROD,"
	cQuery += "       Z1_DESCR AS TEXTO,B1_DESCLIN AS TEXTO2,B1_PRVALID,"
	cQuery += "       Z1_VALIDAD,C2_PRODUTO AS CODIGO,C2_QUANT AS QTDE,"
	cQuery += "       C2_LOTE AS LOTE,C2_DATPRF AS PREVF,B1_CODBAR AS CODBARRA,B1_CODGTIN,"
	cQuery += "       B1_CATALIS,B1_RELCAT1,B1_XCODANT,"
	cQuery += "       dbo.DetVol(C2_FILIAL,C2_PRODUTO) AS RELVOL,"
	cQuery += "       ISNULL(Z5_VOLUME,0) AS VOLUME,"
	cQuery += "       ISNULL(Z5_UMEMB,'') AS UMEMB,"
	cQuery += "       C2_XIDVOL,SC2.R_E_C_N_O_ AS REG "
	cQuery += "FROM " + RetSqlName("SC2") + " SC2 WITH (NOLOCK) "
	cQuery += "LEFT OUTER JOIN " + RetSqlName("SB1") + " SB1 WITH (NOLOCK) "
	cQuery += "  ON (C2_FILIAL = SB1.B1_FILIAL) AND (C2_PRODUTO = SB1.B1_COD) AND (SB1.D_E_L_E_T_ <> '*') "
	cQuery += "LEFT OUTER JOIN " + RetSqlName("SZ1") + " SZ1 WITH (NOLOCK) "
	cQuery += "  ON (LEN(C2_PRODUTO) = 12) AND (SUBSTRING(C2_PRODUTO,4,2) = SZ1.Z1_LINHA) "
	cQuery += "  AND (SZ1.D_E_L_E_T_ <> '*') AND (Z1_FILIAL = '" + xFilial("SZ1") + "') "
	cQuery += "LEFT OUTER JOIN " + RetSqlName("SZ5") + " SZ5 WITH (NOLOCK) "
	cQuery += "  ON (LEN(C2_PRODUTO) = 12) AND (SUBSTRING(C2_PRODUTO,11,2) = SZ5.Z5_EMB) "
	cQuery += "  AND (SZ5.D_E_L_E_T_ <> '*') AND (Z5_FILIAL = '" + xFilial("SZ5") + "') "
	cQuery += "LEFT OUTER JOIN " + RetSqlName("SZ4") + " SZ4 WITH (NOLOCK) "
	cQuery += "  ON (LEN(C2_PRODUTO) = 12) AND (SUBSTRING(C2_PRODUTO,4,2) = SZ4.Z4_LINHA) "
	cQuery += "  AND (SZ4.D_E_L_E_T_ <> '*') AND (Z4_FILIAL = '" + xFilial("SZ4") + "') "
	cQuery += "  AND (SUBSTRING(C2_PRODUTO,1,2)) = Z4_CARAC "
	cQuery += "WHERE (C2_FILIAL = '" + xFilial("SC2") + "') "
	cQuery += "  AND (C2_LOTE = '" + AllTrim(cLote) + "') AND (SB1.B1_TIPO = 'PA') AND (SC2.D_E_L_E_T_ <> '*') "
	cQuery += "ORDER BY LOTE,CODIGO"

	If Select("TMP") <> 0
		DbSelectArea("TMP")
		DbCloseArea()
	EndIf

	TCQuery cQuery New Alias "TMP"
	Count To nTotal

	If nTotal == 0
		MsgStop("Nenhum Registro Localizado","Consulta")
		aBrowse := {{"","",""}}
		oBrowse:SetArray(aBrowse)
		oBrowse:bLine := {||{aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAt,03]}}
		oBrowse:Refresh()
		Return()
	EndIf

	TMP->(DbGoTop())

	SB5->(DbSetOrder(1))
	If SB5->(DbSeek(xFilial("SB5")+TMP->CODIGO))
		If !Empty(SB5->B5_XNORMA)
			oTipo:SetOption(6)
			oTipo:Refresh()
			MsgAlert(OemToAnsi("Atencao: Produto atende a norma ")+SB5->B5_XNORMA+OemToAnsi(" ! Verifique o modelo de etiqueta!"))
		EndIf
		If !Empty(SB5->B5_GREIF)
			cCodTam := AllTrim(SB5->B5_GREIF)
			oTipo:SetOption(7)
			nTipo   := 7
			oTipo:Refresh()
			MsgAlert(OemToAnsi("Atencao: Produto possui Codigo Tambor!"))
		EndIf
	EndIf

	aBrowse := {}

	While !TMP->(EoF())
		RELVOL    := AllTrim(TMP->RELVOL)
		Z1_VALIDAD := AllTrim(TMP->Z1_VALIDAD)
		PREVF     := AllTrim(TMP->PREVF)
		Lote      := AllTrim(TMP->LOTE)
		CODBARRA  := AllTrim(TMP->CODBARRA)
		B1_PRVALID := TMP->B1_PRVALID

		AAdd(aBrowse,{;
			TMP->TEXTO,;
			TMP->CODIGO,;
			PadR(TMP->QTDE,4),;
			TMP->TEXTO,;
			RELVOL,;
			Z1_VALIDAD,;
			PREVF,;
			Lote,;
			CODBARRA,;
			B1_PRVALID,;
			Replace(TMP->NOMEPROD,Chr(186),Chr(167)),;
			TMP->C2_XIDVOL,;
			TMP->VOLUME,;
			TMP->UMEMB,;
			TMP->B1_CATALIS,;
			TMP->B1_RELCAT1,;
			TMP->REG,;
			TMP->C2_NUM,;
			TMP->C2_ITEM,;
			TMP->C2_SEQUEN,;
			TMP->TEXTO2,;
			TMP->TXTETIQ,;
			TMP->B1_CODGTIN})

		If (nTipo != 2) .AND. (nTipo != 7) .AND. !Empty(AllTrim(TMP->RELVOL))
			qtd := (TMP->QTDE / Val(RELVOL))
			AAdd(aBrowse,{;
				"**IDENTIF DE VOLUME**",;
				TMP->CODIGO,;
				PadR(qtd,4),;
				TMP->TEXTO,;
				RELVOL,;
				Z1_VALIDAD,;
				PREVF,;
				Lote,;
				CODBARRA,;
				B1_PRVALID,;
				Replace(TMP->NOMEPROD,Chr(186),Chr(167)),;
				TMP->C2_XIDVOL,;
				TMP->VOLUME,;
				TMP->UMEMB,;
				TMP->B1_CATALIS,;
				TMP->B1_RELCAT1,;
				TMP->REG,;
				TMP->C2_NUM,;
				TMP->C2_ITEM,;
				TMP->C2_SEQUEN,;
				TMP->TEXTO2,;
				TMP->TXTETIQ,;
				TMP->B1_CODGTIN})
		EndIf
		TMP->(DbSkip())
	EndDo

	oBrowse:SetArray(aBrowse)
	oBrowse:bLine := {||{aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAt,03]}}
	oBrowse:Refresh()

Return()

/*/{Protheus.doc} PCP037_02
Consulta Lote pela Ordem de Producao.
@type function Auxiliar
@version 2.00
@author marioantonaccio (refatorado)
@since 08/04/2026
@param xOP, character, Ordem de Producao
@return character, Lote localizado ou vazio
/*/
Static Function PCP037_02(xOP)

	// CORRECAO: cQuery declarada Local (antes era variavel global acidental)
	Local cQuery := "" as character
	Local cRet   := "" as character

	xOP := U_ChrTran(xOP,'"!@#$%\&*()/',"")
	xOP := U_ChrTran(xOP,"'","")

	cQuery := "SELECT C2_LOTE,C2_ITEM,C2_SEQUEN,C2_PRODUTO "
	cQuery += "FROM "  + RetSqlName("SC2") + " SC2 WITH (NOLOCK) "
	cQuery += "WHERE (C2_FILIAL = '" + xFilial("SC2") + "') "
	cQuery += "  AND (C2_NUM+C2_ITEM+C2_SEQUEN = '" + SubStr(xOP,1,11) + "') AND (D_E_L_E_T_ <> '*') "
	cQuery += "ORDER BY C2_ITEM,C2_SEQUEN"

	If Select("TEMP") <> 0
		DbSelectArea("TEMP")
		DbCloseArea()
	EndIf

	TCQuery cQuery New Alias "TEMP"

	While !TEMP->(EoF())
		cRet := AllTrim(TEMP->C2_LOTE)
		TEMP->(DbSkip())
	EndDo

	If Empty(cRet)
		MsgAlert(OemToAnsi("Lote nao Localizado"),"Atencao")
	EndIf

Return(cRet)

/*/{Protheus.doc} PCP037_03
Loop com a Qtd e Tipo de Etiquetas a ser impressa.
@type function Auxiliar
@version 2.00
@author marioantonaccio (refatorado)
@since 08/04/2026
@param nTipo, numeric, Etiqueta Selecionada
/*/
Static Function PCP037_03(nTipo)

	Local n      := 1 as numeric
	Local i      := 1 as numeric
	Local linhas := Len(aBrowse) as numeric
	Local qtd    := 0 as numeric
	Local qtdReal := 0 as numeric

	If Len(aBrowse) < 1 .OR. Empty(aBrowse[1][1])
		MsgInfo(OemToAnsi("Necessario Consultar uma OP ou Lote"),"Etiquetas Produtos")
		Return()
	EndIf

	// CORRECAO: ValidPort retorna .T. quando porta esta OCUPADA/indisponivel
	If ValidPort(cLPT)
		MsgInfo("Impressora Zebra (Etiqueta) nao esta pronta. Verifique a porta selecionada!")
		Return()
	EndIf

	For n := 1 To linhas

		qtd := Ceiling(Val(aBrowse[n][3]))

		If AllTrim(aBrowse[n][1]) == "**IDENTIF DE VOLUME**"
			// CORRECAO: nQtde2 e numeric (antes cQtde2 era character somado como numero)
			qtdReal := qtd + nQtde2
		Else
			qtdReal := qtd + nQtde1
		EndIf

		// Excecoes para etiquetas duplas e triplas
		If nTipo == 3
			qtdReal := Ceiling(qtdReal/2)
		EndIf
		If nTipo == 2
			qtdReal := Ceiling(qtdReal/3)
		EndIf

		For i := 1 To qtdReal
			Do Case
				Case nTipo == 1
					If AllTrim(aBrowse[n][1]) == "**IDENTIF DE VOLUME**"
						PCP037_05(n,i)
					Else
						PCP037_04(n,i)
					EndIf
				Case nTipo == 2
					If AllTrim(aBrowse[n][1]) <> "**IDENTIF DE VOLUME**"
						PCP037_11(n,i)
					EndIf
				Case nTipo == 3
					PCP037_06(n,i)
				Case nTipo == 4
					If AllTrim(aBrowse[n][1]) == "**IDENTIF DE VOLUME**"
						PCP037_07(n,i)
					Else
						PCP037_08(n,i)
					EndIf
				Case nTipo == 5
					If AllTrim(aBrowse[n][1]) == "**IDENTIF DE VOLUME**"
						PCP037_09(n,i)
					Else
						PCP037_10(n,i)
					EndIf
				Case nTipo == 6
					If AllTrim(aBrowse[n][1]) == "**IDENTIF DE VOLUME**"
						PCP037_05(n,i)
					Else
						PCP037_13(n,i)
					EndIf
				Case nTipo == 7
					If AllTrim(aBrowse[n][1]) <> "**IDENTIF DE VOLUME**"
						PCP037_14(n,i)
					EndIf
			EndCase
		Next i
	Next n

	If !Empty(cOP)
		oOP:SetFocus()
	Else
		oLote:SetFocus()
	EndIf

	cOP     := Space(13)
	cLote   := Space(6)
	cCont   := Space(3)
	aBrowse := {{"","",""}}
	oBrowse:SetArray(aBrowse)
	oBrowse:bLine := {||{aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAt,03]}}
	oBrowse:Refresh()

Return()

/*/{Protheus.doc} PCP037_DadosEtiq
Extrai e prepara todos os dados de uma linha do aBrowse para impressao de etiqueta.
Elimina o bloco de leitura repetido nas 11 funcoes de impressao originais.

Estrutura do array retornado (aD):
  aD[01] = Cod          codigo do produto (AllTrim)
  aD[02] = Prod         nome principal (B1_DESC)
  aD[03] = ProdTxt      texto da etiqueta (B1_DESCLIN ou B1_TXTETIQ ou B1_DESC)
  aD[04] = Unid         unidade (2 digits, zero-padded)
  aD[05] = cLote        lote
  aD[06] = CodBar       codigo de barras do produto
  aD[07] = DtVenc       data de vencimento calculada (tipo Date)
  aD[08] = Prevf        data prev. fabricacao (string AAAAMMDD)
  aD[09] = Volume       volume como string (ja convertido se < 1)
  aD[10] = UMEMB        unidade de medida tratada
  aD[11] = cEmb         codigo de embalagem extraido do cod. produto
  aD[12] = cXidvol      identificador de volume (zero-padded 4 digitos)
  aD[13] = Catalis      catalisador
  aD[14] = RelCat1      relacao catalisador
  aD[15] = REG          R_E_C_N_O_ do SC2
  aD[16] = C2_NUM       numero da OP
  aD[17] = C2_ITEM      item da OP
  aD[18] = C2_SEQUEN    sequencia da OP
  aD[19] = B1_CODGTIN   codigo GTIN
  aD[20] = cEmb_Bar     codigo embalagem para codigo de barras
  aD[21] = lVolume      .T. se linha e identificacao de volume

@type function Auxiliar
@version 1.00
@author marioantonaccio
@since 08/04/2026
@param nLinha, numeric, indice da linha no aBrowse
@return array, dados tratados da etiqueta
/*/
Static Function PCP037_DadosEtiq(nLinha)

	Local aD        := {} as array
	Local Cod       := "" as character
	Local Prod      := "" as character
	Local ProdTxt   := "" as character
	Local Unid      := "" as character
	Local cLoteL    := "" as character
	Local CodBar    := "" as character
	Local Prevf     := "" as character
	Local cEmb      := "" as character
	Local cEmb_Bar  := "" as character
	Local cXidvol   := "" as character
	Local Volume    := "" as character
	Local UMEMB     := "" as character
	Local Catalis   := "" as character
	Local RelCat1   := "" as character
	Local Validade  := 0  as numeric
	Local PrazoVali := 0  as numeric
	Local Dias      := 0  as numeric
	Local DtVenc    := CToD("") as date
	Local lVolume   := .F. as logical

	Cod      := AllTrim(aBrowse[nLinha][2])
	lVolume  := (AllTrim(aBrowse[nLinha][1]) == "**IDENTIF DE VOLUME**")

	// Texto da etiqueta: prioridade TXTETIQ > B1_DESCLIN > TEXTO (B1_DESC)
	If !Empty(AllTrim(aBrowse[nLinha][22]))
		ProdTxt := AllTrim(aBrowse[nLinha][22])
	ElseIf !Empty(AllTrim(aBrowse[nLinha][21]))
		ProdTxt := AllTrim(aBrowse[nLinha][21])
	Else
		ProdTxt := AllTrim(aBrowse[nLinha][4])
	EndIf

	Prod     := AllTrim(aBrowse[nLinha][11])
	Unid     := StrZero(Val(AllTrim(SubStr(aBrowse[nLinha][5],1,2))),2)
	Validade := aBrowse[nLinha][6]
	Prevf    := AllTrim(aBrowse[nLinha][7])
	cLoteL   := AllTrim(aBrowse[nLinha][8])
	CodBar   := AllTrim(aBrowse[nLinha][9])
	PrazoVali := aBrowse[nLinha][10]
	cXidvol  := StrZero(Val(AllTrim(aBrowse[nLinha][12])),4)
	Volume   := CValToChar(aBrowse[nLinha][13])
	Catalis  := AllTrim(aBrowse[nLinha][15])
	RelCat1  := AllTrim(aBrowse[nLinha][16])

	// Calculo do vencimento
	If Empty(PrazoVali)
		PrazoVali := 0
	EndIf
	If Empty(Validade)
		Validade := 0
	EndIf
	Dias   := If(PrazoVali > 0, PrazoVali * 30, Validade * 30)
	DtVenc := DaySum(STOD(Prevf), Dias)

	// CORRECAO: TrtUnimed com If/Else no lugar de dois If independentes
	If Val(Volume) < 1
		UMEMB  := TrtUnimed(AllTrim(aBrowse[nLinha][14]), Val(Volume))
		Volume := CValToChar(Val(Volume) * 1000)
	Else
		UMEMB  := TrtUnimed(AllTrim(aBrowse[nLinha][14]), Val(Volume))
	EndIf

	// Identificacao de embalagem
	cEmb    := ""
	cEmb_Bar := ""
	If Len(AllTrim(Cod)) == 12
		If SubStr(Cod,1,2) == "BM"
			cEmb     := SubStr(Cod,8,3)
			cEmb_Bar := SubStr(Cod,11,2)
		Else
			cEmb     := SubStr(Cod,11,2)
			cEmb_Bar := SubStr(Cod,11,2)
		EndIf
	EndIf

	// Monta array de retorno
	AAdd(aD, Cod)                      // 01
	AAdd(aD, Prod)                     // 02
	AAdd(aD, ProdTxt)                  // 03
	AAdd(aD, Unid)                     // 04
	AAdd(aD, cLoteL)                   // 05
	AAdd(aD, CodBar)                   // 06
	AAdd(aD, DtVenc)                   // 07
	AAdd(aD, Prevf)                    // 08
	AAdd(aD, Volume)                   // 09
	AAdd(aD, UMEMB)                    // 10
	AAdd(aD, cEmb)                     // 11
	AAdd(aD, cXidvol)                  // 12
	AAdd(aD, Catalis)                  // 13
	AAdd(aD, RelCat1)                  // 14
	AAdd(aD, aBrowse[nLinha][17])      // 15 REG
	AAdd(aD, aBrowse[nLinha][18])      // 16 C2_NUM
	AAdd(aD, aBrowse[nLinha][19])      // 17 C2_ITEM
	AAdd(aD, aBrowse[nLinha][20])      // 18 C2_SEQUEN
	AAdd(aD, aBrowse[nLinha][23])      // 19 B1_CODGTIN
	AAdd(aD, cEmb_Bar)                 // 20
	AAdd(aD, lVolume)                  // 21

Return(aD)

/*/{Protheus.doc} PCP037_04
Impressao Zebra - Etiqueta de Produto.
@type function Auxiliar
@version 2.00
@author marioantonaccio (refatorado)
@since 08/04/2026
@param nLinha, numeric, linha do aBrowse
@param nQtd,   numeric, numero da etiqueta no loop
/*/
Static Function PCP037_04(nLinha, nQtd)

	Local cModelo  := "ZEBRA" as character
	Local aD       := {}      as array
	Local Cod      := ""      as character
	Local cEmb     := ""      as character

	aD     := PCP037_DadosEtiq(nLinha)
	Cod    := TRANSFORM(aD[01],"@R XX 99.99.999-XX")
	cEmb   := aD[11]

	MSCBPRINTER(cModelo,cLPT,,12,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBLOADGRF("SIGA.GRF")
	MSCBBEGIN(1)

	MSCBSAY(05,02,SubStr(aD[02],1,30),"N","0","025,025")

	If SubStr(aD[01],1,5) == "BM 00"
		MSCBSAY(GetMV("ZP_PAR0113"),02,cEmb,"N","0",GetMV("ZP_PAR0111"))
	Else
		MSCBSAY(GetMV("ZP_PAR0114"),02,cEmb,"N","0",GetMV("ZP_PAR0112"))
	EndIf

	MSCBSAY(05,06,aD[03],"N","0","025,025")
	MSCBSAY(05,11,"COD:","N","0","025,022")
	MSCBSAY(11,11,Cod,"N","0","025,022")
	MSCBSAY(05,15,"LOTE:","N","0","020,022")
	MSCBSAY(12,15,aD[05],"N","0","020,022")
	MSCBSAY(21,15,"Val.: "+R2104(aD[07]),"N","0","020,022")

	MSCBLineH(00,10,190,3,"B")
	If Empty(aD[13])
		MSCBSAY(05,18,"CONTEUDO "+aD[09]+" "+aD[10],"N","0","068,068")
		MSCBSAYBAR(48,11,aD[06],"N","MB04",5,.F.,.T.,.F.,,02,02,.F.,.F.,"1",.T.)
	Else
		MSCBSAY(05,21,"CONTEUDO "+aD[09]+" "+aD[10],"N","0","030,030")
		MSCBSAY(35,22,"CAT: "+TRANSFORM(aD[13],"@R XX 99.99.999-XX")+" ("+aD[14]+")","N","0","025,025")
		MSCBSAYBAR(48,11,aD[06],"N","MB04",7,.F.,.T.,.F.,,02,02,.F.,.F.,"1",.T.)
	EndIf

	MSCBEND()
	MSCBCLOSEPRINTER()

Return()

/*/{Protheus.doc} PCP037_05
Impressao Zebra - Etiqueta de Volume.
@type function Auxiliar
@version 2.00
@author marioantonaccio (refatorado)
@since 08/04/2026
@param nLinha, numeric, linha do aBrowse
@param nQtd,   numeric, numero da etiqueta no loop
/*/
Static Function PCP037_05(nLinha, nQtd)

	Local cModelo  := "ZEBRA" as character
	Local aD       := {}      as array
	Local Cod      := ""      as character
	Local CodBar   := ""      as character
	Local NcXidvol := ""      as character
	Local nQtdStr  := ""      as character
	Local cEmb_Bar := ""      as character

	aD       := PCP037_DadosEtiq(nLinha)
	NcXidvol := StrZero(Val(aD[12]) + nQtd, 4)
	cEmb_Bar := aD[20]
	CodBar   := aD[05] + cEmb_Bar + aD[04] + NcXidvol
	Cod      := TRANSFORM(aD[01],"@R XX 99.99.999-XX")

	MSCBPRINTER(cModelo,cLPT,,12,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBLOADGRF("SIGA.GRF")
	MSCBBEGIN(1)

	MSCBSAY(05,02,aD[02],"N","0","025,025")
	MSCBSAY(05,05,"**Val.: "+R2104(aD[07])+"** IDENTIF VOL *","N","0","025,025")

	If _ZPPAR0214
		MSCBLineH(00,10,050,3,"B")
	Else
		MSCBLineH(00,10,190,3,"B")
	EndIf

	MSCBSAY(05,11,"COD:","N","0","026,026")
	MSCBSAY(12,11,Cod,"N","0","026,026")

	If _ZPPAR0214
		MSCBSAY(40,11,AllTrim(UniMed(CodBar,aD[01])),"N","0","026,026")
	Else
		MSCBSAY(57,11,AllTrim(UniMed(CodBar,aD[01])),"N","0","026,026")
	EndIf

	If _ZPPAR0214
		nQtdStr := StrZero(Val(AllTrim(Replace(Transform(Val(SubStr(UniMed(CodBar,aD[01]),1,2)),"@E 9999"),",",""))),6)
		If Len(AllTrim(aD[19])) <> 13
			MsgAlert("Codigo Gtin invalido: "+aD[19])
			MSCBEND()
			MSCBCLOSEPRINTER()
			Return()
		EndIf
	EndIf

	If (IsDigit(SubStr(cEmb_Bar,2,1))) .AND. (IsDigit(SubStr(cEmb_Bar,1,1)))
		If _ZPPAR0214
			MSCBWRITE("^FT470,145^BQN,4,4")
			MSCBWRITE("^FH\^FDLA,"+CodBar+"^FS")
			SB5->(DbSetOrder(1))
			If !Empty(SB5->B5_2CODBAR)
				MSCBSAYBAR(06,15,AllTrim(SB5->B5_2CODBAR),"N","MB07",6,.F.,.T.,.F.,,2,01,.F.,.F.,"1",.T.)
				MSCBWRITE("^FO16,120^A0B,025,025^FH_^FDDUN^FS")
				MSCBWRITE("^FO460,150^A0N,026,026^FH_^FD"+aD[05]+"^FS")
			Else
				MSCBSAYBAR(06,15,AllTrim(SB1->B1_CODGTIN),"N","MB07",6,.F.,.T.,.F.,,2,01,.F.,.F.,"1",.T.)
				MSCBWRITE("^FO460,150^A0N,026,026^FH_^FD"+aD[05]+"^FS")
			EndIf
		Else
			MSCBSAYBAR(18,15,CodBar,"N","MB07",6,.F.,.T.,.F.,,2,01,.F.,.F.,"1",.T.)
		EndIf
	Else
		If _ZPPAR0214
			MSCBSAYBAR(06,15,CodBar,"N","MB07",6,.F.,.T.,.F.,,2,01,.F.,.F.,"1",.T.)
		Else
			MSCBSAYBAR(14,15,CodBar,"N","MB07",9,.F.,.T.,.F.,,2,01,.F.,.F.,"1",.T.)
		EndIf
	EndIf

	MSCBEND()
	MSCBCLOSEPRINTER()

	UPD_XVOL(NcXidvol,aD[15],aD[16],aD[17],aD[18],aD[05])

Return()

/*/{Protheus.doc} PCP037_06
Impressao Etiqueta 44x15mm (dupla coluna).
@type function Auxiliar
@version 2.00
@author marioantonaccio (refatorado)
@since 08/04/2026
@param nLinha, numeric, linha do aBrowse
@param nQtd,   numeric, numero da etiqueta no loop
/*/
Static Function PCP037_06(nLinha, nQtd)

	Local cModelo  := "ZEBRA" as character
	Local aD       := {}      as array
	Local Cod      := ""      as character
	Local nCol     := 0       as numeric

	aD  := PCP037_DadosEtiq(nLinha)
	Cod := TRANSFORM(aD[01],"@R XX 99.99.999-XX")

	MSCBPRINTER(cModelo,cLPT,,12,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBLOADGRF("SIGA.GRF")
	MSCBBEGIN(1)

	// Primeira coluna
	nCol := 0
	If Len(aD[02]) >= 25
		MSCBSAY(02+nCol,02,aD[02],"N","0","018,018")
	Else
		MSCBSAY(02+nCol,02,aD[02],"N","0","022,022")
	EndIf
	MSCBSAY(02+nCol,05,Cod,"N","0","022,022")
	MSCBSAY(02+nCol,08,aD[09]+aD[10]+" Lote: "+aD[05],"N","0","022,022")
	MSCBSAY(02+nCol,11,"Val.: "+R2104(aD[07]),"N","0","022,022")
	If AllTrim(aBrowse[nLinha][1]) <> "**IDENTIF DE VOLUME**"
		MSCBSAYBAR(25+nCol,5,aD[06],"N","MB04",7,.F.,.T.,.F.,,1,1,.F.,.F.,"1",.T.)
	EndIf

	// Segunda coluna
	nCol := 49
	If Len(aD[02]) >= 25
		MSCBSAY(02+nCol,02,aD[02],"N","0","018,018")
	Else
		MSCBSAY(02+nCol,02,aD[02],"N","0","022,022")
	EndIf
	MSCBSAY(02+nCol,05,Cod,"N","0","022,022")
	MSCBSAY(02+nCol,08,aD[09]+aD[10]+" Lote: "+aD[05],"N","0","022,022")
	MSCBSAY(02+nCol,11,"Val.: "+R2104(aD[07]),"N","0","022,022")
	MSCBSAYBAR(25+nCol,5,aD[06],"N","MB04",7,.F.,.T.,.F.,,1,1,.F.,.F.,"1",.T.)

	MSCBEND()
	MSCBCLOSEPRINTER()

Return()

/*/{Protheus.doc} PCP037_07
Impressao Etiqueta 75x35mm - Volume.
@type function Auxiliar
@version 2.00
@author marioantonaccio (refatorado)
@since 08/04/2026
@param nLinha, numeric, linha do aBrowse
@param nQtd,   numeric, numero da etiqueta no loop
/*/
Static Function PCP037_07(nLinha, nQtd)

	Local cModelo  := "ZEBRA" as character
	Local aD       := {}      as array
	Local Cod      := ""      as character
	Local CodBar   := ""      as character
	Local NcXidvol := ""      as character

	aD       := PCP037_DadosEtiq(nLinha)
	NcXidvol := StrZero(Val(aD[12]) + nQtd, 4)
	CodBar   := aD[05] + aD[11] + aD[04] + NcXidvol
	Cod      := TRANSFORM(aD[01],"@R XX 99.99.999-XX")

	MSCBPRINTER(cModelo,cLPT,,12,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBLOADGRF("SIGA.GRF")
	MSCBBEGIN(1)

	MSCBSAY(03,02,aD[02],"N","0","025,025")
	MSCBSAY(65,02,aD[11],"N","0","025,025")
	MSCBSAY(03,05,"**Val.: "+R2104(aD[07])+"** IDENTIF VOL *","N","0","025,030")
	MSCBLineH(00,10,190,3,"B")
	MSCBSAY(03,11,"COD:","N","0","025,025")
	MSCBSAY(10,11,Cod,"N","0","025,025")
	MSCBSAY(57,11,AllTrim(UniMed(CodBar,aD[01])),"N","0","026,026")
	MSCBSAYBAR(10,18,CodBar,"N","MB07",6,.F.,.T.,.F.,,2,01,.F.,.F.,"1",.T.)

	MSCBEND()
	MSCBCLOSEPRINTER()

	UPD_XVOL(NcXidvol,aD[15],aD[16],aD[17],aD[18],aD[05])

Return()

/*/{Protheus.doc} PCP037_08
Impressao Etiqueta 75x35mm - Produto.
@type function Auxiliar
@version 2.00
@author marioantonaccio (refatorado)
@since 08/04/2026
@param nLinha, numeric, linha do aBrowse
@param nQtd,   numeric, numero da etiqueta no loop
/*/
Static Function PCP037_08(nLinha, nQtd)

	Local cModelo  := "ZEBRA" as character
	Local aD       := {}      as array
	Local Cod      := ""      as character

	aD  := PCP037_DadosEtiq(nLinha)
	Cod := TRANSFORM(aD[01],"@R XX 99.99.999-XX")

	MSCBPRINTER(cModelo,cLPT,,12,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBLOADGRF("SIGA.GRF")
	MSCBBEGIN(1)

	MSCBSAY(03,02,aD[02],"N","0","025,025")
	MSCBSAY(65,02,aD[11],"N","0","025,025")
	MSCBSAY(03,06,aD[03],"N","0","025,025")
	MSCBLineH(00,10,190,3,"B")
	MSCBSAY(03,11,"COD:","N","0","025,022")
	MSCBSAY(09,11,Cod,"N","0","025,022")
	MSCBSAY(03,15,"LOTE:","N","0","020,022")
	MSCBSAY(10,15,aD[05],"N","0","020,022")
	MSCBSAY(19,15,"Val.: "+R2104(aD[07]),"N","0","020,022")

	If Empty(aD[13])
		MSCBSAY(03,23,"CONTEUDO "+aD[09]+" "+aD[10],"N","0","068,068")
		MSCBSAYBAR(45,11,aD[06],"N","MB04",6,.F.,.T.,.F.,,03,03,.F.,.F.,"1",.T.)
		MSCBSAY(45,20,cObs,"N","0","022,022")
	Else
		MSCBSAY(03,23,"CONTEUDO "+aD[09]+" "+aD[10],"N","0","068,068")
		MSCBSAY(03,19,"CAT: "+TRANSFORM(aD[13],"@R XX 99.99.999-XX")+" ("+aD[14]+")","N","0","022,022")
		MSCBSAY(45,20,cObs,"N","0","022,022")
		MSCBSAYBAR(45,11,aD[06],"N","MB04",6,.F.,.T.,.F.,,02,02,.F.,.F.,"1",.T.)
	EndIf

	MSCBEND()
	MSCBCLOSEPRINTER()

Return()

/*/{Protheus.doc} PCP037_09
Impressao Etiqueta 100x69mm - Volume.
@type function Auxiliar
@version 2.00
@author marioantonaccio (refatorado)
@since 08/04/2026
@param nLinha, numeric, linha do aBrowse
@param nQtd,   numeric, numero da etiqueta no loop
/*/
Static Function PCP037_09(nLinha, nQtd)

	Local cModelo  := "ZEBRA" as character
	Local aD       := {}      as array
	Local Cod      := ""      as character
	Local CodBar   := ""      as character
	Local NcXidvol := ""      as character

	aD       := PCP037_DadosEtiq(nLinha)
	NcXidvol := StrZero(Val(aD[12]) + nQtd, 4)
	CodBar   := aD[05] + aD[11] + aD[04] + NcXidvol
	Cod      := TRANSFORM(aD[01],"@R XX 99.99.999-XX")

	MSCBPRINTER(cModelo,cLPT,,12,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBLOADGRF("SIGA.GRF")
	MSCBBEGIN(1)

	MSCBSAY(04,06,SubStr(aD[02],1,30),"N","0","045,045")
	MSCBSAY(90,06,aD[11],"N","0","045,055")
	MSCBSAY(04,16,"**Val.: "+R2104(aD[07])+"** IDENTIF VOL *","N","0","045,055")
	MSCBLineH(00,22,190,3,"B")
	MSCBSAY(04,26.5,"COD:","N","0","035,035")
	MSCBSAY(15,26,Cod,"N","0","050,060")
	MSCBSAY(80,26,UniMed(CodBar,aD[01]),"N","0","040,040")
	MSCBSAYBAR(9,35,CodBar,"N","MB07",6,.F.,.T.,.F.,,2,01,.F.,.F.,"1",.T.)

	MSCBEND()
	MSCBCLOSEPRINTER()

	UPD_XVOL(NcXidvol,aD[15],aD[16],aD[17],aD[18],aD[05])

Return()

/*/{Protheus.doc} PCP037_10
Impressao Etiqueta 100x69mm - Produto.
@type function Auxiliar
@version 2.00
@author marioantonaccio (refatorado)
@since 08/04/2026
@param nLinha, numeric, linha do aBrowse
@param nQtd,   numeric, numero da etiqueta no loop
/*/
Static Function PCP037_10(nLinha, nQtd)

	Local cModelo  := "ZEBRA" as character
	Local aD       := {}      as array
	Local Cod      := ""      as character
	Local CodBar   := ""      as character
	Local NcXidvol := ""      as character

	If Empty(cCont)
		cCont := "1"
	EndIf

	aD       := PCP037_DadosEtiq(nLinha)
	NcXidvol := StrZero(Val(aD[12]) + nQtd, 4)
	CodBar   := aD[05] + aD[11] + aD[04] + NcXidvol
	Cod      := TRANSFORM(aD[01],"@R XX 99.99.999-XX")

	MSCBPRINTER(cModelo,cLPT,,12,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBLOADGRF("SIGA.GRF")
	MSCBBEGIN(1)

	MSCBSAY(04,05,SubStr(aD[02],1,30),"N","0","045,045")
	MSCBSAY(90,05,aD[11],"N","0","045,055")
	MSCBSAY(04,12,aD[03],"N","0","045,055")
	MSCBLineH(00,17,190,3,"B")
	MSCBSAY(04,20.5,"COD:","N","0","035,035")
	MSCBSAY(15,20,Cod,"N","0","050,060")
	MSCBSAY(80,19,"Lote:","N","0","030,030")
	MSCBSAY(80,23,aD[05],"N","0","040,040")
	MSCBSAY(04,27,"DT FABR:","N","0","030,030")
	MSCBSAY(04,31,CValToChar(STOD(aD[08])),"N","0","040,040")
	MSCBSAY(32,27,"VALIDADE:","N","0","030,030")
	MSCBSAY(32,31,R2104(aD[07]),"N","0","040,040")

	If AllTrim(cNumEmp) <> "01060101"
		MSCBSAY(04,38,"PESO LIQ.:","N","0","040,040")
		MSCBSAY(04,43,aD[09]+aD[10],"N","0","060,065")
		If Val(cCont) > 0
			MSCBSAY(32,38,"CX","N","0","040,040")
			MSCBSAY(32,43,StrZero(Val(cCont),3),"N","0","040,040")
			cCont := StrZero(Val(cCont)+1,3)
		EndIf
		If !Empty(AllTrim(aD[02])) .AND. (Val(aD[09]) > 0)
			MSCBSAY(04,52,OemToAnsi("TEMPERATURA DE CURA: 200 §C - 10 Minutos"),"N","0","035,035")
		EndIf
		MSCBSAYBAR(55,35,CodBar,"N","MB04",8,.F.,.T.,.F.,,3,3,.F.,.F.,"1",.T.)
	Else
		MSCBSAY(04,43,"PESO LIQ.:","N","0","040,040")
		MSCBSAY(04,48,aD[09]+aD[10],"N","0","060,065")
		If Val(cCont) > 0
			MSCBSAY(32,43,"CX","N","0","040,040")
			MSCBSAY(32,48,StrZero(Val(cCont),3),"N","0","040,040")
			cCont := StrZero(Val(cCont)+1,3)
		EndIf
		MSCBSAYBAR(55,40,CodBar,"N","MB04",8,.F.,.T.,.F.,,3,3,.F.,.F.,"1",.T.)
	EndIf

	MSCBEND()
	MSCBCLOSEPRINTER()

	Sleep(_ZPPAR0217)

	UPD_XVOL(NcXidvol,aD[15],aD[16],aD[17],aD[18],aD[05])

Return()

/*/{Protheus.doc} PCP037_11
Impressao Etiqueta 26x15mm (xarope - triple coluna).
@type function Auxiliar
@version 2.00
@author marioantonaccio (refatorado)
@since 08/04/2026
@param nLinha, numeric, linha do aBrowse
@param nQtd,   numeric, numero da etiqueta no loop
/*/
Static Function PCP037_11(nLinha, nQtd)

	Local cModelo := "ZEBRA" as character
	Local aD      := {}      as array

	aD := PCP037_DadosEtiq(nLinha)

	MSCBPRINTER(cModelo,cLPT,,12,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBBEGIN(1)

	// Tres colunas identicas (etiqueta tripla)
	MSCBSAY(05.5,03,"Lt "+aD[05],"N","0","024,027")
	MSCBSAY(05.5,07,"Fab "+CValToChar(STOD(aD[08])),"N","0","024,027")
	MSCBSAY(05.5,11,"Val  "+R2104(aD[07]),"N","0","024,027")

	MSCBSAY(32.5,03,"Lt "+aD[05],"N","0","024,027")
	MSCBSAY(32.5,07,"Fab "+CValToChar(STOD(aD[08])),"N","0","024,027")
	MSCBSAY(32.5,11,"Val  "+R2104(aD[07]),"N","0","024,027")

	MSCBSAY(58.5,03,"Lt "+aD[05],"N","0","024,027")
	MSCBSAY(58.5,07,"Fab "+CValToChar(STOD(aD[08])),"N","0","024,027")
	MSCBSAY(58.5,11,"Val  "+R2104(aD[07]),"N","0","024,027")

	MSCBEND()
	MSCBCLOSEPRINTER()

Return()

/*/{Protheus.doc} PCP037_13
Impressao Etiqueta 100x50mm - Produto (com catalisador e diluente).
@type function Auxiliar
@version 2.00
@author marioantonaccio (refatorado)
@since 08/04/2026
@param nLinha, numeric, linha do aBrowse
@param nQtd,   numeric, numero da etiqueta no loop
/*/
Static Function PCP037_13(nLinha, nQtd)

	Local cModelo  := "ZEBRA" as character
	Local aD       := {}      as array
	Local Cod      := ""      as character
	Local aRelCat1 := {}      as array

	aD  := PCP037_DadosEtiq(nLinha)
	Cod := TRANSFORM(aD[01],"@R XX 99.99.999-XX")

	If !Empty(aD[13])
		aRelCat1 := StrTokArr(Upper(AllTrim(aD[14])),"X")
		If Len(aRelCat1) <> 2
			MsgAlert("Verifique o campo Rel.Cat.Vol no cadastro do Produto "+aD[02])
		EndIf
	EndIf

	MSCBPRINTER(cModelo,cLPT,,12,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBLOADGRF("SIGA.GRF")
	MSCBBEGIN(1)

	MSCBSAY(05,02,SubStr(aD[02],1,30),"N","0","042,042")
	MSCBSAY(90,03,aD[11],"N","0","030,030")
	MSCBSAY(05,08,aD[03],"N","0","028,028")
	MSCBSAY(05,12,"COD:","N","0","025,022")
	MSCBSAY(11,12,Cod,"N","0","025,022")
	MSCBSAY(35,12,"LOTE:","N","0","025,022")
	MSCBSAY(44,12,aD[05],"N","0","025,022")
	MSCBLineH(00,16,100,3,"B")
	MSCBLineV(24,21,30,3,"B")
	MSCBLineV(48,16,40,3,"B")
	MSCBLineV(79,16,30,3,"B")
	MSCBSAY(05,17,OemToAnsi("RELACAO DE MISTURA EM VOLUME"),"N","0","026,022")
	MSCBSAY(50,18,"ATENDE NORMA","N","0","033,033")

	SB5->(DbSetOrder(1))
	If SB5->(DbSeek(xFilial("SB5")+AllTrim(aD[01])))
		If !Empty(SB5->B5_XNORMA)
			MSCBSAY(60,24,OemToAnsi("N§ "+SB5->B5_XNORMA),"N","0","035,035")
		EndIf
	EndIf

	MSCBSAY(81,18,OemToAnsi("FABRICACAO"),"N","0","020,022")
	MSCBSAY(81,21,CValToChar(STOD(aD[08])),"N","0","020,022")
	MSCBSAY(81,24,"VALIDADE","N","0","020,022")
	MSCBSAY(81,27,R2104(aD[07]),"N","0","020,022")
	MSCBLineH(00,21,48,3,"B")
	MSCBSAY(05,23,"COMPONENTE A","N","0","020,022")
	MSCBSAY(27,23,"COMPONENTE B","N","0","020,022")
	MSCBLineH(00,26,48,3,"B")

	If !Empty(aD[13]) .AND. Len(aRelCat1) == 2
		MSCBSAY(05,27,aRelCat1[1],"N","0","020,022")
		MSCBSAY(27,27,aRelCat1[2],"N","0","020,022")
		MSCBSAY(05,32,"CATALISADOR","N","0","034,034")
		MSCBSAY(05,36,TRANSFORM(aD[13],"@R XX 99.99.999-XX"),"N","0","034,034")
	EndIf

	MSCBLineH(00,30,100,3,"B")

	SB5->(DbSetOrder(1))
	If SB5->(DbSeek(xFilial("SB5")+AllTrim(aD[01])))
		If !Empty(SB5->B5_DILUENT)
			MSCBSAY(50,32,"DILUENTE RECOMENDADO","N","0","034,034")
			MSCBSAY(50,36,TRANSFORM(SB5->B5_DILUENT,"@R XX 99.99.999"),"N","0","034,034")
		Else
			ZAB->(DbSetOrder(1))
			If ZAB->(DbSeek(xFilial("ZAB")+SubStr(AllTrim(aD[01]),4,2)))
				MSCBSAY(50,32,"DILUENTE RECOMENDADO","N","0","034,034")
				MSCBSAY(50,36,TRANSFORM(ZAB->ZAB_DILUEN,"@R XX 99.99.999"),"N","0","034,034")
			EndIf
		EndIf
	EndIf

	MSCBLineH(00,40,100,3,"B")
	MSCBSAY(04,42,"CONTEUDO LIQUIDO","N","0","068,068")
	MSCBSAY(80,42,aD[09]+" "+aD[10],"N","0","068,068")
	MSCBSAYBAR(67,07,aD[06],"N","MB04",5,.F.,.T.,.F.,,02,02,.F.,.F.,"1",.T.)

	MSCBEND()
	MSCBCLOSEPRINTER()

Return()

/*/{Protheus.doc} PCP037_14
Impressao Etiqueta Tambor 100x200mm.
@type function Auxiliar
@version 2.00
@author marioantonaccio (refatorado)
@since 08/04/2026
@param nLinha, numeric, linha do aBrowse
@param nQtd,   numeric, numero da etiqueta no loop
/*/
Static Function PCP037_14(nLinha, nQtd)

	Local cModelo  := "ZEBRA" as character
	Local aD       := {}      as array
	Local Cod      := ""      as character
	Local cONU     := ""      as character
	Local aRelCat1 := {}      as array
	Local PrevfL   := ""      as character

	aD     := PCP037_DadosEtiq(nLinha)
	PrevfL := aD[08]
	Cod    := TRANSFORM(aD[01],"@R XX 99.99.999-XX")

	If !Empty(aD[13])
		aRelCat1 := StrTokArr(Upper(AllTrim(aD[14])),"X")
		If Len(aRelCat1) <> 2
			MsgAlert("Verifique o campo Rel.Cat.Vol no cadastro do Produto "+aD[02])
		EndIf
	EndIf

	// Busca codigo ONU via NCM (tabela SYD)
	SB1->(DbSeek(xFilial("SB1")+PadR(aD[01],TamSx3("B1_COD")[1])))
	DbSelectArea("SYD")
	DbSetOrder(1)
	If DbSeek(xFilial("SYD")+PadR(SB1->B1_POSIPI,TamSx3("YD_TEC")[1]))
		cONU := SYD->YD_XONU
	EndIf

	// Data de fabricacao: usa cTbFab quando informada na tela
	If cTbFab <> CToD("  /  /  ")
		PrevfL := DToS(cTbFab)
	EndIf

	MSCBPRINTER(cModelo,cLPT,,20,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBLOADGRF("SIGA.GRF")
	MSCBBEGIN(1)

	MSCBSAY(005,130,"CODIGO "+cTambor,"B","0","080,060")
	MSCBSAY(005,025,PadR(SB5->B5_GREIF,20,""),"B","0","080,060")
	MSCBLineV(20,02,194,3,"B")
	MSCBLineH(00,100,100,3,"B")
	MSCBSAY(026,130,Cod,"B","0","080,060")
	MSCBSAY(026,000,SubStr(aD[02],1,30),"B","0","060,050")
	MSCBLineV(40,02,194,3,"B")
	MSCBSAY(046,148,OemToAnsi("FABRICACAO :"),"B","0","080,060")
	MSCBSAY(046,110,CValToChar(STOD(PrevfL)),"B","0","080,060")
	MSCBSAY(046,055,"VALIDADE :","B","0","080,060")
	MSCBSAY(046,016,R2104(aD[07]),"B","0","080,060")
	MSCBLineV(60,02,194,3,"B")
	MSCBSAY(066,145,"PESO LIQUIDO:","B","0","080,060")
	MSCBSAY(066,120,"180 LT","B","0","080,060")
	MSCBSAY(066,048,"CAPACIDADE:","B","0","080,060")
	MSCBSAY(066,016,"200 LT","B","0","080,060")
	MSCBLineV(80,02,194,3,"B")
	MSCBSAY(086,175,"LOTE : ","B","0","080,060")
	MSCBSAY(086,150,aD[05],"B","0","080,060")
	MSCBSAY(086,125,"ONU : ","B","0","080,060")
	MSCBSAY(086,105,cONU,"B","0","080,060")
	MSCBSAYBAR(82,35,aD[06],"B","MB04",GetMV("MV_PCP37_1"),.F.,.T.,.F.,,GetMV("MV_PCP37_2"),GetMV("MV_PCP37_3"),.F.,.F.,"1",.T.)

	MSCBEND()
	MSCBCLOSEPRINTER()

Return()

/*/{Protheus.doc} ReportPrint
Visualizacao em tela (TMSPrinter) das etiquetas para todos os tipos.
@type function Auxiliar
@version 2.00
@author marioantonaccio (refatorado)
@since 08/04/2026
@param nTipo, numeric, tipo de etiqueta selecionado
/*/
Static Function ReportPrint(nTipo)

	Local n      := 1 as numeric
	Local i      := 1 as numeric
	Local linhas := Len(aBrowse) as numeric
	Local qtd    := 0 as numeric
	Local qtdReal := 0 as numeric
	Local nLin   := 0 as numeric
	Local nRow1  := 0 as numeric
	Local cPage  := 0 as numeric
	//Local cont   := 0 as numeric
	Local Letiq  := 0 as numeric

	Local aD       := {} as array
	Local Cod      := "" as character
	Local CodBar   := "" as character
	Local aRelCat1 := {} as array

	Private oPrint
	Private oFont9n  := TFont():New("Arial",,9,,.T.,,,,.F.,.F.)
	Private oFont10n := TFont():New("Arial",,10,,.T.,,,,.F.,.F.)
	Private oFont12n := TFont():New("Arial",,12,,.T.,,,,.F.,.F.)
	Private oFont15n := TFont():New("Arial",,15,,.T.,,,,.F.,.F.)
	Private oFont30n := TFont():New("Arial",,30,,.T.,,,,.F.,.F.)
	Private oFont9   := TFont():New("Arial",,9,,.F.,,,,.F.,.F.)
	Private oFont10  := TFont():New("Arial",,10,,.F.,,,,.F.,.F.)
	Private oFont12  := TFont():New("Arial",,12,,.F.,,,,.F.,.F.)
	Private oFont15  := TFont():New("Arial",,15,,.F.,,,,.F.,.F.)
	Private oFont30  := TFont():New("Arial",,30,,.F.,,,,.F.,.F.)

	If Len(aBrowse) < 1 .OR. Empty(aBrowse[1][1])
		MsgInfo(OemToAnsi("Necessario Consultar uma OP ou Lote"),"Etiquetas Produtos")
		Return()
	EndIf

	oPrint := TMSPrinter():New(OemToAnsi("Etiqueta de produto"))
	oPrint:SetPortrait()
	oPrint:StartPage()

	For n := 1 To linhas

		aD       := PCP037_DadosEtiq(n)
		Cod      := TRANSFORM(aD[01],"@R XX 99.99.999-XX")

		qtd     := Val(CValToChar(aBrowse[n][3]))
		qtdReal := If(aD[21], qtd + nQtde2, qtd + nQtde1)

		If !Empty(aD[13]) .AND. nTipo == 6
			aRelCat1 := StrTokArr(Upper(AllTrim(aD[14])),"X")
			If Len(aRelCat1) <> 2
				MsgAlert("Verifique o campo Rel.Cat.Vol no cadastro do Produto "+aD[02])
			EndIf
		Else
			aRelCat1 := {}
		EndIf

		For i := 1 To qtdReal

			Do Case
				Case nTipo == 1
					If aD[21]  // IDENTIF DE VOLUME
						CodBar := aD[05]+aD[11]+aD[04]+StrZero(Val(aD[12])+Val(CValToChar(aBrowse[n][3])),4)
						oPrint:Say(nLin,0050,OemToAnsi(aD[02]),oFont15n,,,,0)
						oPrint:Say(nLin,0800,OemToAnsi(aD[11]),oFont15n,,,,0)
						nLin += 050
						oPrint:Say(nLin,0050,"**Val.: "+CValToChar(aD[07])+"** IDENTIF VOL *",oFont15n,,,,0)
						nLin += 060
						oPrint:Line(nLin,0010,nLin,850)
						nLin += 040
						oPrint:Say(nLin,0050,OemToAnsi("COD: "+Cod),oFont12n,,,,0)
						oPrint:Say(nLin,0700,OemToAnsi(AllTrim(UniMed(CodBar,aD[01]))),oFont12n,,,,0)
						nLin += 050
						CodBar := aD[05]+aD[20]+aD[04]+StrZero(Val(aD[12])+i,4)
						MSBAR3("CODE128",2.2+Letiq,2,CodBar,oPrint,.T.,10,.T.,0.030,1.2,.T.,,,,.F.)
						nLin  += 300
						Letiq += 4.2
					Else
						oPrint:Line(nLin,0010,nLin,850)
						nLin += 020
						oPrint:Say(nLin,0050,OemToAnsi(aD[02]),oFont15n,,,,0)
						oPrint:Say(nLin,0800,OemToAnsi(aD[11]),oFont15n,,,,0)
						nLin += 050
						oPrint:Say(nLin,0050,OemToAnsi(aD[03]),oFont15n,,,,0)
						nLin += 060
						oPrint:Line(nLin,0010,nLin,850)
						nLin += 040
						oPrint:Say(nLin,0050,OemToAnsi("COD: "+Cod),oFont12n,,,,0)
						nLin += 060
						oPrint:Say(nLin,0050,OemToAnsi("LOTE: "+aD[05]),oFont12n,,,,0)
						oPrint:Say(nLin,0252,OemToAnsi("Val: "+CValToChar(aD[07])),oFont12n,,,,0)
						nLin += 040
						MSBAR3("CODE128",1.7+Letiq,4,aD[06]+U_DigEan13(aD[06]),oPrint,.T.,10,.T.,0.025,1,.T.,,,,.F.)
						nLin += 030
						oPrint:Say(nLin,0040,OemToAnsi("Conteudo: "+aD[09]+" "+aD[10]),oFont30n,,,,0)
						nLin += 100
						oPrint:Line(nLin,0010,nLin,850)
						nLin += 150
						Letiq += 4.64
					EndIf

				Case nTipo == 2
					If !aD[21]
						oPrint:Say(nLin,0050,OemToAnsi("LT "+aD[05]),oFont12n,,,,0)
						nLin += 050
						oPrint:Say(nLin,0050,OemToAnsi("Fab "+CValToChar(STOD(aD[08]))),oFont12n,,,,0)
						nLin += 050
						oPrint:Say(nLin,0050,OemToAnsi("Val "+CValToChar(aD[07])),oFont12n,,,,0)
						nLin += 150
					EndIf

				Case nTipo == 3
					oPrint:Say(nLin,0050,OemToAnsi(aD[02]),oFont12n,,,,0)
					nLin += 050
					oPrint:Say(nLin,0050,OemToAnsi(Cod),oFont12n,,,,0)
					nLin += 050
					oPrint:Say(nLin,0050,OemToAnsi(aD[09]+aD[10]+" Lote: "+aD[05]),oFont12n,,,,0)
					nLin += 050
					oPrint:Say(nLin,0050,OemToAnsi("Val "+CValToChar(aD[07])),oFont12n,,,,0)
					CodBar := aD[05]+aD[11]+aD[04]+StrZero(Val(aD[12])+i,4)
					MSBAR3("CODE128",0.8+Letiq,3,CodBar,oPrint,.T.,8,.T.,0.022,0.85,.T.,,,,.F.)
					nLin  += 150
					Letiq += 2.55

				Case nTipo == 4
					If aD[21]
						CodBar := aD[05]+aD[11]+aD[04]+StrZero(Val(aD[12])+i,4)
						oPrint:Say(nLin,0050,OemToAnsi(aD[02]),oFont12n,,,,0)
						oPrint:Say(nLin,0800,OemToAnsi(aD[11]),oFont12n,,,,0)
						nLin += 040
						oPrint:Say(nLin,0050,"**Val.: "+CValToChar(aD[07])+"** IDENTIF VOL *",oFont12n,,,,0)
						nLin += 060
						oPrint:Line(nLin,0010,nLin,850)
						nLin += 030
						oPrint:Say(nLin,0050,OemToAnsi("COD: "+Cod),oFont12n,,,,0)
						oPrint:Say(nLin,0500,OemToAnsi(AllTrim(UniMed(CodBar,aD[01]))),oFont12n,,,,0)
						nLin += 060
						MSBAR3("CODE128",1.4+Letiq,2,CodBar,oPrint,.T.,8,.T.,0.022,0.85,.T.,,,,.F.)
						nLin  += 300
						Letiq += 4.2
					Else
						oPrint:Line(nLin,0010,nLin,850)
						nLin += 020
						oPrint:Say(nLin,0050,OemToAnsi(aD[02]),oFont12n,,,,0)
						oPrint:Say(nLin,0800,OemToAnsi(aD[11]),oFont12n,,,,0)
						nLin += 040
						oPrint:Say(nLin,0050,OemToAnsi(aD[03]),oFont12n,,,,0)
						nLin += 060
						oPrint:Line(nLin,0010,nLin,850)
						nLin += 040
						oPrint:Say(nLin,0050,OemToAnsi("COD: "+Cod),oFont12n,,,,0)
						nLin += 050
						oPrint:Say(nLin,0050,OemToAnsi("LOTE: "+aD[05]),oFont12n,,,,0)
						oPrint:Say(nLin,0252,OemToAnsi("Val: "+CValToChar(aD[07])),oFont12n,,,,0)
						nLin += 040
						If Empty(aD[13])
							oPrint:Say(nLin,0050,OemToAnsi("CONTEUDO "+aD[09]+" "+aD[10]),oFont15n,,,,0)
							nLin += 060
							MSBAR3("CODE128",1.2+Letiq,4,aD[06],oPrint,.T.,10,.T.,0.025,1,.T.,,,,.F.)
						Else
							oPrint:Say(nLin,0050,OemToAnsi("CONTEUDO "+aD[09]+" "+aD[10]),oFont12n,,,,0)
							nLin += 060
							oPrint:Say(nLin,0050,OemToAnsi(TRANSFORM(aD[13],"@R XX 99.99.999-XX")),oFont12n,,,,0)
							nLin += 055
							oPrint:Line(nLin,0010,nLin,1200)
							nLin += 020
							MSBAR3("CODE128",1.2+Letiq,4,aD[06],oPrint,.T.,10,.T.,0.025,1,.T.,,,,.F.)
						EndIf
						nLin += 150
						Letiq += 4.64
					EndIf

			EndCase

			If nLin >= 3200
				oPrint:EndPage()
				cPage := 0
				nRow1 := 0
				nLin  := 0050
				Letiq := 0
			EndIf

		Next i

		If nLin >= 3200
			oPrint:EndPage()
			cPage := 0
			nRow1 := 0
			nLin  := 0050
			Letiq := 0
		EndIf

	Next n

	oPrint:Preview()
	oPrint:End()

Return()

/*/{Protheus.doc} UniMed
Calcula Unidade de Medida a partir do codigo de barras e codigo do produto.
CORRECAO: retorno inicializado para evitar NIL quando codbarra fora de 14/15 chars.
@type function Auxiliar
@version 2.00
@author marioantonaccio (refatorado)
@since 08/04/2026
@param codbarra, character, codigo de barras
@param codigo,   character, codigo do produto
@return character, unidade de medida (ex: "12 Kg", "05 L", "03 Unid")
/*/
Static Function UniMed(codbarra, codigo)

	// CORRECAO: inicializado para evitar NIL quando len fora de 14/15
	Local retorno := "" as character

	If Len(AllTrim(codbarra)) == 14
		retorno := SubStr(codbarra,9,2)
		If SubStr(codigo,11,2) == "99"
			retorno += " Kg"
		ElseIf SubStr(codigo,11,2) == "00"
			retorno += " L"
		Else
			retorno += " Unid"
		EndIf
	EndIf

	// Produto BM (15 caracteres)
	If Len(AllTrim(codbarra)) == 15
		retorno := SubStr(codbarra,10,2)
		If SubStr(codigo,11,2) == "99"
			retorno += " Kg"
		ElseIf SubStr(codigo,11,2) == "00"
			retorno += " L"
		Else
			retorno += " Unid"
		EndIf
	EndIf

Return(retorno)

/*/{Protheus.doc} ValidPort
Verifica se a porta/impressora esta indisponivel (ocupada ou sem resposta).
Retorna .T. quando a impressora NAO esta pronta (porta ocupada).
CORRECAO: nome e logica documentados explicitamente para evitar confusao futura.
@type function Auxiliar
@version 2.00
@author marioantonaccio (refatorado)
@since 08/04/2026
@param cPorta, character, nome da porta (ex: "LPT1")
@return logical, .T. = porta INDISPONIVEL / .F. = porta OK para imprimir
/*/
Static Function ValidPort(cPorta)
	// IsPrinter retorna .T. quando impressora esta PRONTA
	// Portanto: !IsPrinter = .T. quando INDISPONIVEL
Return(!IsPrinter(cPorta))

/*/{Protheus.doc} ListPort
Carrega array com as portas disponiveis para impressao.
@type function Auxiliar
@version 2.00
@author marioantonaccio (refatorado)
@since 08/04/2026
/*/
Static Function ListPort()

	Local i     := 0  as numeric
	Local porta := "" as character

	For i := 1 To 9
		porta := "LPT" + CValToChar(i)
		If IsPrinter(porta)
			AAdd(aLPT, porta)
			oLPT:SetItems(aLPT)
		EndIf
	Next

Return()

/*/{Protheus.doc} UPD_XVOL
Atualiza a sequencia do campo C2_XIDVOL no SC2.
CORRECAO: verificacao do retorno do RecLock com mensagem de erro em caso de falha.
@type function Auxiliar
@version 2.00
@author marioantonaccio (refatorado)
@since 08/04/2026
@param XIDVOL,    character, novo valor do volume sequencial
@param REG,       numeric,   R_E_C_N_O_ do registro
@param C2_NUM,    character, numero da OP
@param C2_ITEM,   character, item da OP
@param C2_SEQUEN, character, sequencia da OP
@param C2_LOTE,   character, lote
/*/
Static Function UPD_XVOL(XIDVOL, REG, C2_NUM, C2_ITEM, C2_SEQUEN, C2_LOTE)

	DbSelectArea("SC2")
	DbSetOrder(1)

	If DbSeek(xFilial("SC2")+C2_NUM+C2_ITEM+C2_SEQUEN)
		While !EOF()
			If RECNO() == REG
				// CORRECAO: verificacao do retorno do RecLock
				If RecLock("SC2",.F.)
					Replace C2_XIDVOL With XIDVOL
					MsUnLock()
				Else
					MsgAlert(OemToAnsi("Registro SC2 em uso. Nao foi possivel atualizar C2_XIDVOL.")+CRLF+;
						"OP: "+C2_NUM+" Item: "+C2_ITEM+" Lote: "+C2_LOTE)
				EndIf
				Exit
			EndIf
			DbSkip()
		EndDo
	EndIf

Return()

/*/{Protheus.doc} TrtUnimed
Trata a unidade de medida conforme o volume do produto.
CORRECAO: If/Else no lugar de dois If independentes; retorno inicializado.
@type function Auxiliar
@version 2.00
@author marioantonaccio (refatorado)
@since 08/04/2026
@param Unid, character, unidade base ("L" ou "K")
@param vol,  numeric,   volume do produto
@return character, unidade formatada ("ml","L","g","Kg")
/*/
Static Function TrtUnimed(Unid, vol)

	// CORRECAO: inicializado para evitar retorno NIL em casos nao cobertos
	Local UMEMB := "" as character

	// CORRECAO: If/Else no lugar de dois If independentes (antes: gap quando vol == 0)
	If vol < 1
		If Unid == "L"
			UMEMB := "ml"
		ElseIf Unid == "K"
			UMEMB := "g"
		EndIf
	Else
		If Unid == "L"
			UMEMB := "L"
		ElseIf Unid == "K"
			UMEMB := "Kg"
		EndIf
	EndIf

Return(UMEMB)

/*/{Protheus.doc} VLDRAD
Habilita ou desabilita os campos de Tambor e Data de Fabricacao conforme tipo selecionado.
@type function Auxiliar
@version 2.00
@author marioantonaccio (refatorado)
@since 08/04/2026
@param xtipo, numeric, tipo de etiqueta selecionado no radio
/*/
Static Function VLDRAD(xtipo)

	If xtipo == 7
		oTambor:Enable()
		oTbFab:Enable()
	Else
		oTambor:Disable()
		cTambor := Space(10)
		oTambor:Refresh()
		oTbFab:Disable()
		cTbFab := CToD("  /  /  ")
		oTbFab:Refresh()
	EndIf

Return()

/*/{Protheus.doc} R2104
Converte data de DD/MM/AAAA para MM/AA.
Quando o dia for >= 20, avanca para o mes seguinte (regra de vencimento).
@type function Auxiliar
@version 2.00
@author marioantonaccio (refatorado)
@since 08/04/2026
@param cData, date, data a ser formatada
@return character, data no formato MM/AA ou vazio
/*/
Static Function R2104(cData)

	Local cRet := "" as character
	Local cAno := "" as character
	Local cMes := "" as character
	Local nDia := 0  as numeric

	If ValType(cData) == "D" .AND. !Empty(cData)
		nDia := Day(cData)
		If nDia >= 20
			cData := MonthSum(cData,1)
		EndIf
		cAno := SubStr(Year2Str(cData),3,2)
		cMes := Month2Str(cData)
		cRet := cMes + "/" + cAno
	EndIf

Return(cRet)
