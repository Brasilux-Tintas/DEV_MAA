#Include "Protheus.ch"
#Include "TopConn.ch"

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ BRPCP037  ∫Autor  ≥ Nelieder Corneta  ∫ Data ≥  17/12/2021 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫DescriÁ„o ≥ Estiquetas de volume Diferenciadas (Etiqueta de Produtos)   ±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ BRASILUX TINTAS T…CNICAS LTDA.                             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
 
/*
/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
# Codigos de Barras #
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
/*
MB01 - Interleaved 2 of 5 / EAN14
MB02 - Code 39
MB03 - EAN 8
MB04 - EAN 13
MB05 - UPC A
MB06 - UPC E
MB07 - CODE 128
*/
 
User Function  BRPCP037()

Local nTipo       := 1

//Fontes
Private cFontUti  := "Tahoma"
Private oFontAno  := TFont():New(cFontUti, , -38)
Private oFontBtn  := TFont():New(cFontUti, , -14)
Private oFontSub  := TFont():New(cFontUti, , -16)
Private oFontSubN := TFont():New(cFontUti, , -20, , .T.)

//Tamanho da Janela
Private nJanLarg  := 730
Private nJanAltu  := 400

Private oOP
Private cOP       := space(11)

Private oLote
Private cLote     := space(6)

Private oQtde1
Private cQtde1    := space(6)

Private oQtde2
Private cQtde2    := space(6)

Private oObs
Private cObs      := space(15)

Private aBrowse   := {}

/*
Estrtura do Array aBrowse
1 - Nome Produto
2 - Codigo Produto
3 - Qtd
4 - ProdTexto
5 - Unidade(RELVOL)
6 - Validade(Z1_VALIDAD)
7 - PREVF
8 - Lote
9 - CodBar
10 - PrazoVali (Z1_VALIDAD)
11 - Nome Principal
12 - ProxNVol
13 - VOLUME
14 - UMEMB
15 - Catalis
16 - RelCat1
*/


Private lEditar   := .T.
Private oBtnFech

Private cFlag     := .F.

Private oLPT,cLPT

Private aLPT      :={}

Private oPrint,cPrint

Private oPort,cPort

/* define padr„o de data */
Set(_SET_DATEFORMAT, 'dd/mm/yy' )

    
DEFINE MSDIALOG oDlg TITLE "Estiquetas de volume Diferenciadas (Etiqueta de Produtos)" FROM 000, 000 TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL

@ 004, 003 MSPANEL oPanel SIZE 260, 080 OF oDlg COLORS 0, 14215660 CENTERED RAISED

@ 010, 010 SAY OemToAnsi("N∫ da OP.: ") SIZE 060,009 PIXEL OF oDlg FONT oFontBtn
@ 008, 060 MSGET oOP VAR cOP PICTURE "@!" SIZE 090,010 COLOR CLR_BLUE F3 "SC2" PIXEL ON CHANGE PCP037_99(nTipo) OF oDlg FONT oFontBtn

@ 030, 010 SAY OemToAnsi("N∫ do Lote.: ") SIZE 060,009 PIXEL  OF oDlg FONT oFontBtn
@ 028, 060 MSGET oLote VAR cLote PICTURE "@!" SIZE 045,010 COLOR CLR_BLUE F3 "ZC2" PIXEL ON CHANGE PCP037_99(nTipo) OF oDlg FONT oFontBtn

cQtde1         := 0
@ 050, 010 SAY OemToAnsi("Qtde Adic. de Etiq. Prod.: ") SIZE 100,009 PIXEL OF oDlg FONT oFontBtn
@ 048, 108 MSGET oQtde1 VAR cQtde1 PICTURE "999" SIZE 045,010 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn

cQtde2         := 0
@ 070, 010 SAY OemToAnsi("Qtde Adic. de Ident. Vol.: ") SIZE 100,009 PIXEL OF oDlg FONT oFontBtn
@ 068, 108 MSGET oQtde2 VAR cQtde2 PICTURE "999" SIZE 045,010 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn

@ 057, 160 SAY OemToAnsi("Obs Etiq.: ") SIZE 100,009 PIXEL OF oDlg FONT oFontBtn
@ 055, 205 MSGET oObs VAR cObs PICTURE "@!" SIZE 045,010 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn

@ 004, 265 MSPANEL oPanel SIZE 100, 080 OF oDlg COLORS 0, 14215660 FONT oFontBtn CENTERED RAISED

@ 004, 004 RADIO oTipo VAR nTipo PROMPT "Zebra","26x15mm(Xarope)","44x15mm","75x35mm","100x69mm" OF oPanel PIXEL SIZE 75,20

@ 055, 004 SAY OemToAnsi("Porta\Impressora") SIZE 100,009 PIXEL OF oPanel FONT oFontBtn
@ 065, 004 MSCOMBOBOX oLPT VAR cLPT ITEMS aLPT SIZE 050, 007 OF oPanel COLORS 0, 16777215 PIXEL FONT oFontBtn
ListPort()

@ 100,289 BUTTON oBtnFech PROMPT "Imprimir" SIZE 060, 018 OF oDlg ACTION PCP037_03(nTipo) FONT oFontBtn PIXEL
@ 140,289 BUTTON oBtnFech PROMPT "Visualizar" SIZE 060, 018 OF oDlg ACTION ReportPrint(nTipo) FONT oFontBtn PIXEL
@ 175,289 BUTTON oBtnFech PROMPT "Fechar" SIZE 060, 018 OF oDlg ACTION (oDlg:End()) FONT oFontBtn PIXEL

// Cria Browse
oBrowse  := TCBrowse():New(092, 004, 260, 105, , {'Produto', 'Produto', 'Qtde Etiq.' }, {130,50,10}, oDlg, , , , , {||lEditCell (@aBrowse, oBrowse, "999", 3)}, , oFontSub, , , , , .F., , .T., , .F., , ,)
aBrowse := {{ '' , '' , '' }}

// Seta vetor para a browse
oBrowse:SetArray(aBrowse)

// Monta a linha a ser exibina no Browse
oBrowse:bLine  := {||{ aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAT,03], }}

/* habilita fechar tela no bot„o esc */
oDlg:lEscClose := .T.

ACTIVATE MSDIALOG oDlg CENTERED

Return

/*/{Protheus.doc} PCP037_99
Identifica se a consulta È por OP ou Lote
@type function
@author neliedercorneta
@since 23/12/2021
@param nTipo, numeric, Etiqueta Selecionada
/*/
Static Function PCP037_99(nTipo)

	/* consultar por OP */
	if !Empty(cOP) .and. Empty(cLote)
		cLote := PCP037_02(cOP)
		PCP037_01(nTipo)
		Return()
	Endif

	/* consultar por Lote */
	if Empty(cOP) .and. !Empty(cLote)
		PCP037_01(nTipo)
		Return()
	Endif

	aBrowse:= {}
	oBrowse:SetArray(aBrowse)
	oBrowse:Refresh()

Return()


/*/{Protheus.doc} PCP037_01
Consulta Etiquetas por Lote
@type function
@author neliedercorneta
@since 12/01/2022
@param nTipo, numeric, tamanho de etiqueta selecionada
/*/
Static Function PCP037_01(nTipo)
local qtd

if Empty(cOP) .and. Empty(cLote)
	MsgInfo( 'Necess·rio informar uma OP ou Lote ! ' , 'Etiquetas Produtos' )
	Return()
Endif

oBrowse         := TCBrowse():New(092, 004, 260, 105, , {'Produto','Produto', 'Qtde Etiq.' }, {130,50,10}, oDlg, , , , , {||lEditCell (@aBrowse, oBrowse, "@!", 3)}, , oFontSub, , , , , .F., , .T., , .F., , ,)
oBrowse:nLinhas := 2

cQuery := "SELECT B1_DESC AS NOMEPROD,Z1_DESCR AS TEXTO,B1_DESCLIN AS TEXTO2,B1_PRVALID,"
cQuery += "Z1_VALIDAD,C2_PRODUTO AS CODIGO,C2_QUANT AS QTDE,"
cQuery += "C2_LOTE AS LOTE,C2_DATPRF AS PREVF,B1_CODBAR AS CODBARRA,"
cQuery += "B1_CATALIS,B1_RELCAT1,B1_XCODANT,dbo.DetVol(C2_FILIAL,C2_PRODUTO) AS RELVOL,"
cQuery += "ISNULL(Z5_VOLUME,0) AS VOLUME,"
cQuery += " ISNULL(Z5_UMEMB, '' ) AS UMEMB, "
cQuery += "C2_XIDVOL,SC2.R_E_C_N_O_ AS REG "
cQuery += "FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "
cQuery += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (C2_FILIAL = SB1.B1_FILIAL) AND (C2_PRODUTO = SB1.B1_COD) AND (SB1.D_E_L_E_T_ <> '*' ) "
cQuery += "LEFT OUTER JOIN "+RetSqlName("SZ1")+" SZ1 WITH (NOLOCK) ON (LEN(C2_PRODUTO) = 12) AND (SUBSTRING(C2_PRODUTO,4,2) = SZ1.Z1_LINHA) AND (SZ1.D_E_L_E_T_ <> '*' ) AND (Z1_FILIAL = '"+xFilial("SZ1")+"' ) "
cQuery += "LEFT OUTER JOIN "+RetSqlName("SZ5")+" SZ5 WITH (NOLOCK) ON (LEN(C2_PRODUTO) = 12) AND (SUBSTRING(C2_PRODUTO,11,2) = SZ5.Z5_EMB) AND (SZ5.D_E_L_E_T_ <> '*' ) AND (Z5_FILIAL = '"+xFilial("SZ5")+"' ) "
cQuery += "WHERE (C2_FILIAL = '"+xFilial("SC2")+"' ) AND "
cQuery += "(C2_LOTE = '"+AllTrim(cLote)+"' ) AND (SB1.B1_TIPO = 'PA' ) AND (SC2.D_E_L_E_T_ <> '*' ) "
cQuery += "ORDER BY LOTE,CODIGO"

IF Select("TMP") <> 0
	DbSelectArea("TMP")
	DbCloseArea()
ENDIF

TCQuery cQuery New Alias "TMP"
Count To nTotal 

If nTotal == 0
	MsgStop('Nenhum Registro Localizado', 'Consulta')
	aBrowse  := {{ '' , '' , '' }}
	oBrowse:SetArray(aBrowse)
	oBrowse:bLine   := {||{ aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAT,03], }}
	oBrowse:Refresh()
	return()
Endif

TMP->(dbGoTop())

aBrowse         := {}
While !TMP->(EoF())

	/* adiciona array produto */
	aAdd(aBrowse, { ;
		TMP->TEXTO,;
		TMP->CODIGO,;
		Padr(TMP->QTDE,3),;
		TMP->TEXTO,;
		RELVOL,;
		Z1_VALIDAD,;
		PREVF,;
		Lote,;
		CODBARRA,;
		B1_PRVALID,;
		TMP->NOMEPROD,;
		TMP->c2_xidvol,;
		TMP->VOLUME,;
		TMP->UMEMB,;
		TMP->B1_CATALIS,;
		TMP->B1_RELCAT1;
		})

	if (nTipo != 2) .AND. !EMPTY(ALLTRIM(TMP->RELVOL))
		
		/* adiciona array volume */
		//qtd := U_DetVolEmba(substr(TMP->CODIGO,11,2), TMP->QTDE )
		qtd             := (TMP->QTDE / val(RELVOL))
		aAdd(aBrowse, { ;
			"**IDENTIF DE VOLUME**",;
			TMP->CODIGO,;
			Padr(qtd,3),;
			TMP->TEXTO,;
			RELVOL,;
			Z1_VALIDAD,;
			PREVF,;
			Lote,;
			CODBARRA,;
			B1_PRVALID,;
			TMP->NOMEPROD,;
			TMP->c2_xidvol,;
			TMP->VOLUME,;
			TMP->UMEMB,;
			TMP->B1_CATALIS,;
			TMP->B1_RELCAT1;
			})
	Endif
	TMP->(DbSkip())
EndDo

// Seta vetor para a browse
oBrowse:SetArray(aBrowse)

// Monta a linha a ser exibina no Browse
oBrowse:bLine   := {||{ aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAT,03], }}

oBrowse:Refresh()


Return


/*/{Protheus.doc} PCP037_02
Consulta Etiquetas por Ordem de ProduÁ„o
@type function
@author neliedercorneta
@since 23/12/2021
@param xOP, variant, Ordem de ProduÁ„o
@return variant, Lote
/*/
Static Function PCP037_02(xOP)
Local cRet

cQuery := " SELECT C2_LOTE,C2_ITEM,C2_SEQUEN,C2_PRODUTO "
cQuery += " FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "
cQuery += " WHERE (C2_FILIAL = '"+xFilial("SC2")+"' ) AND "
cQuery += " (C2_NUM+C2_ITEM+C2_SEQUEN = '"+xOP+"' ) AND (D_E_L_E_T_ <> '*' ) "
cQuery += " ORDER BY C2_ITEM,C2_SEQUEN "



IF Select("TEMP") <> 0
	DbSelectArea("TEMP")
	DbCloseArea()
ENDIF

TCQuery cQuery New Alias "TEMP"

While !TEMP->(EoF())
	cRet   := AllTrim(TEMP->C2_LOTE)
	TEMP->(DbSkip())
EndDo

Return(cRet)


/*/{Protheus.doc} PCP037_03
Loop com a Qtd e Tipo de Etiquetas a ser impressa
@type function
@author neliedercorneta
@since 23/12/2021
@param nTipo, numeric, Etiqueta Selecionada
/*/
Static Function PCP037_03(nTipo)

	local n      := 1
	local i      := 1
	local linhas := len(aBrowse)
	local qtd

	/* valida se array pois dados */
	if len(aBrowse) < 1
		MsgInfo( 'Necess·rio Consultar uma OP ou Lote' , 'Etiquetas Produtos' )
		Return()
	Endif

	if ValidPort(cLPT) 
	    MsgInfo("Impressora Zebra (Etiqueta) nao esta pronta, Verifique a  Porta selecionada !")
		Return()
	Endi

	/* Loop nas linhas do Array */
	For n := 1 to linhas

		/* qtd de etiquetas a ser impressa */
		qtd          := Ceiling(val(aBrowse[n][3]))
		
		/* soma qtd adicional de etiquetas */
		if AllTrim(aBrowse[n][1]) == "**IDENTIF DE VOLUME**"
			qtdReal      := qtd + cQtde2
		Else
			qtdReal      := qtd + cQtde1

		Endif

		/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
			# exceÁ„o para etiquetas duplas e triplas #
		ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
		/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
			# Impress„o de Etiquetas 44x15mm (2 etiquetas por linha) #
		ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
		if nTipo == 3
		 qtdReal      := Ceiling(qtdReal/2)
		Endif	

		/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
		# Impress„o de Etiquetas 26x15mm(xarope) (3 etiquetas por linha) #
		ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
		if nTipo == 2
		 qtdReal      := Ceiling(qtdReal/3)
		Endif	

		/* loop na qtd de etiquetas a ser impressa */
		For i        := 1 to qtdReal

			Do Case
			Case nTipo == 1

				/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
				# Impress„o de Etiquetas Zembras #
				ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
				if AllTrim(aBrowse[n][1]) == "**IDENTIF DE VOLUME**"
					PCP037_05(n,i)
				else
					PCP037_04(n,i)
				Endif

			Case nTipo == 2
				/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
				# Impress„o de Etiquetas 26x15mm(xarope) #
				ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
				if AllTrim(aBrowse[n][1]) <> "**IDENTIF DE VOLUME**"
					PCP037_11(n,i)
				Endif

			Case nTipo == 3

				/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
				# Impress„o de Etiquetas 44x15mm #
				ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
				PCP037_06(n,i)

			Case nTipo == 4
				/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
				# Impress„o de Etiquetas 75x35mm #
				ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
				if AllTrim(aBrowse[n][1]) == "**IDENTIF DE VOLUME**"
					PCP037_07(n,i)
				else
					PCP037_08(n,i)
				Endif
			Case nTipo == 5

				/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
				# Impress„o de Etiquetas 100x69mm #
				ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
				if AllTrim(aBrowse[n][1]) == "**IDENTIF DE VOLUME**"
					PCP037_09(n,i)
				else
					PCP037_10(n,i)
				Endif
				
			EndCase
		NEXT
	NEXT


Return


/*/{Protheus.doc} PCP037_04
Etiqueta Zebra de Produto
@type function
@author neliedercorneta
@since 23/12/2021
@param linha, logical, linha
@param qtd, variant, qtd de produtos
/*/
Static Function PCP037_04(linha,qtd)
	Local cModelo 	:= "ZEBRA"

	Local Prod,ProdTxt,Cod,Unid,CodBar
	Local Validade,Prevf,PrazoVali,Dias,cLote
	Local DtVenc,cEmb
	Local Volume,UMEMB

	Local Catalis,RelCat1

	Cod        := AllTrim(aBrowse[linha][2])
	ProdTxt    := AllTrim(aBrowse[linha][4])
	Unid       := SUBSTR(aBrowse[linha][5],1,2)
	Unid       := AllTrim(Unid)
	Unid       := StrZero(val(Unid),2)
	Validade   := aBrowse[linha][6]
	Prevf      := AllTrim(aBrowse[linha][7])
	cLote      := AllTrim(aBrowse[linha][8])
	CodBar     := AllTrim(aBrowse[linha][9])
	PrazoVali  := AllTrim(aBrowse[linha][10])
	Prod       := AllTrim(aBrowse[linha][11])

	cXidvol    := AllTrim(aBrowse[linha][12])
	cXidvol    := StrZero(val(cXidvol),4)
	Volume     := CValToChar(aBrowse[linha][13])

	/* trata produtos com volume menor que 1 transformando em ml */
	if val(Volume) < 1
		Volume := CValToChar (val(Volume) * 1000)
		UMEMB 	   := "ml"
	else
		UMEMB 	   := CValToChar(aBrowse[linha][14])
	endif

	Catalis	   := AllTrim(aBrowse[linha][15])	
	RelCat1    := AllTrim(aBrowse[linha][16])

	IF Empty(PrazoVali)
		PrazoVali := 0
		Dias := 0
	Endif

	IF Empty(Validade)
		Validade := 0
	Endif

	/* calcula vencimento do produto */
	IF(PrazoVali > 0)
		Dias := (PrazoVali * 30)
		DtVenc := DaySum(STOD(Prevf), Dias  )
	else
		Dias := (Validade * 30)
		DtVenc := DaySum(STOD(Prevf), Dias  )
	Endif


	/* identifica embalagem */
	If len(Alltrim(Cod)) == 12
		cEmb := substr(Cod,11,2)
	Endif

	/* inicio de impress„o das etiquetas */
	MSCBPRINTER(cModelo, cLPT,,12,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBLOADGRF("SIGA.GRF")
	MSCBBEGIN(1,6)

	MSCBSAY(03,02   ,SUBSTR(Prod,1,27), "N", "0", "025,035") // negrito
	MSCBSAY(70,02   ,cEmb, "N", "0", "025,035") // negrito
	MSCBSAY(03,06   ,ProdTxt, "N", "0", "025,035") // negrito
	
	MSCBLineH(00,10,190,3,'B')
	
	MSCBSAY(03,11,"COD:", "N", "0", "025,022") // negrito
	Cod = TRANSFORM(Cod, "@R XX 99.99.999-99")
	MSCBSAY(09,11,Cod, "N", "0", "025,022") 
	
	MSCBSAY(03,15,"LOT:", "N", "0", "020,022") // negrito
	MSCBSAY(09,15,cLote, "N", "0", "020,022") 
		
	MSCBSAY(19,15,"Val.: "+CValToChar(DtVenc), "N", "0", "020,022") // negrito
	
	
	if Empty(Catalis)
		MSCBSAY(03,18,"CONTEUDO "+Volume+" "+UMEMB, "N", "0","068,068") // negrito
		MSCBSAYBAR(50,11,CodBar,"N","MB04",5, .F., .T., .F., ,02,02, .F., .F., "1", .T.)
	else
		MSCBSAY(03,21,"CONTEUDO "+Volume+" "+UMEMB, "N", "0","030,030") // negrito
		Catalis = TRANSFORM(Catalis, "@R XX 99.99.999-99")
		MSCBSAY(35,22,"CAT: "+Catalis+" ("+RelCat1+")", "N", "0","025,025") // negrito
		MSCBSAYBAR(50,11,CodBar,"N","MB04",7, .F., .T., .F., ,02,02, .F., .F., "1", .T.)
	Endif	

	

	MSCBEND()
	MSCBCLOSEPRINTER()


Return()

/*/{Protheus.doc} PCP037_05
Etiqueta Zebra de Volume
@type function
@author neliedercorneta
@since 23/12/2021
@param linha, logical, linha
@param qtd, variant, qtd produtos
/*/
Static Function PCP037_05(linha,qtd)

Local cModelo := "ZEBRA"
Local Prod,ProdTxt,Cod,Unid,CodBar
Local Validade,Prevf,PrazoVali,Dias,cLote
Local DtVenc,cEmb,UMEMB

	Cod           := AllTrim(aBrowse[linha][2])
	ProdTxt       := AllTrim(aBrowse[linha][4])
	Unid          := SUBSTR(aBrowse[linha][5],1,2)
	Unid          := AllTrim(Unid)
	Unid          := StrZero(val(Unid),2)
	Validade      := aBrowse[linha][6]
	Prevf         := AllTrim(aBrowse[linha][7])
	cLote         := AllTrim(aBrowse[linha][8])
	PrazoVali     := aBrowse[linha][10]
	Prod          := AllTrim(aBrowse[linha][11])

	cXidvol       := AllTrim(aBrowse[linha][12])
	cXidvol       := StrZero(val(cXidvol),4)


	IF Empty(PrazoVali)
		PrazoVali     := 0
		Dias          := 0
	Endif

	IF Empty(Validade)
		Validade      := 0
	Endif


	IF(PrazoVali > 0)
		Dias          := (PrazoVali * 30)
		DtVenc        := DaySum(STOD(Prevf), Dias )
	else
		Dias          := (Validade * 30)
		DtVenc        := DaySum(STOD(Prevf), Dias )
	Endif

	/* identifica embalagem */
	If len(Alltrim(Cod)) == 12
		cEmb          := substr(Cod,11,2)
	Endif


	CodBar        := cLote+cEmb+Unid+StrZero( (val(cXidvol))+qtd , 4)
	UMEMB         := UniMed(CodBar,Cod)


	MSCBPRINTER(cModelo, cLPT,,12,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBLOADGRF("SIGA.GRF")
	MSCBBEGIN(1,6)

	MSCBSAY(03,02 ,SUBSTR(Prod,1,27), "N", "0", "025,035") // negrito
	MSCBSAY(70,02 ,cEmb, "N", "0", "025,035") // negrito
	MSCBSAY(03,05 ,"**Val.: "+ CValToChar(DtVenc)+"** IDENTIF VOL *", "N", "0", "025,030") // negrito
	
	MSCBLineH(00,10,190,3, 'B' )
	
	MSCBSAY(03,11,"COD:", "N", "0", "025,022") // negrito
	Cod = TRANSFORM(Cod, "@R XX 99.99.999-99")
	MSCBSAY(09,11,Cod, "N", "0", "025,022") // negrito
	MSCBSAY(57,11, AllTrim(UMEMB), "N", "0", "026,026") // negrito
	
	MSCBSAYBAR(18, 15,CodBar,"N","MB01",6, .F., .T., .F., ,3,02, .F., .F., "1", .T.)

	MSCBEND()
	MSCBCLOSEPRINTER()


Return()

/*/{Protheus.doc} PCP037_06
Etiqueta 44x15 mm
@type function
@author neliedercorneta
@since 23/12/2021
@param linha, logical, linha
@param qtd, variant, qtd de produtos
/*/
Static Function PCP037_06(linha,qtd)
	
	Local cModelo := "ZEBRA"
	Local Prod,ProdTxt,Cod,Unid,CodBar
	Local Validade,Prevf,PrazoVali,Dias,cLote
	Local DtVenc,cEmb
	Local Volume,UMEMB
	Local cColuna := 0

	Cod           := AllTrim(aBrowse[linha][2])
	ProdTxt       := AllTrim(aBrowse[linha][4])
	Unid          := SUBSTR(aBrowse[linha][5],1,2)
	Unid          := AllTrim(Unid)
	Unid          := StrZero(val(Unid),2)
	Validade      := aBrowse[linha][6]
	Prevf         := AllTrim(aBrowse[linha][7])
	cLote         := AllTrim(aBrowse[linha][8])
	CodBar        := AllTrim(aBrowse[linha][9])
	PrazoVali     := aBrowse[linha][10]
	Prod          := AllTrim(aBrowse[linha][11])

	cXidvol       := AllTrim(aBrowse[linha][12])
	cXidvol       := StrZero(val(cXidvol),4)
	Volume        := CValToChar(aBrowse[linha][13])
	UMEMB         := CValToChar(aBrowse[linha][14])
			  


	IF Empty(PrazoVali)
		PrazoVali     := 0
		Dias          := 0
	Endif

	IF Empty(Validade)
		Validade      := 0
	Endif

	IF(PrazoVali > 0)
		Dias          := (PrazoVali * 30)
		DtVenc        := DaySum(STOD(Prevf), Dias )
	else
		Dias          := (Validade * 30)
		DtVenc        := DaySum(STOD(Prevf), Dias )
	Endif


	/* identifica embalagem */
	If len(Alltrim(Cod)) == 12
		cEmb          := substr(Cod,11,2)
	Endif

	/* identifica etiqueta par */
	if mod(qtd,2)==0
		cColuna := 10
	else
		cColuna := 0
	endif

	MSCBPRINTER(cModelo, cLPT,,12,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBLOADGRF("SIGA.GRF")
	MSCBBEGIN(1,6)

	MSCBSAY(02+cColuna,02,Prod,"N","0","020,020")
	
	Cod = TRANSFORM(Cod, "@R XX 99.99.999-99")
	MSCBSAY(02+cColuna,06,Cod, "N", "0", "018,018")
	
	MSCBSAY(02+cColuna,08.5,Volume+UMEMB+" Lot: "+cLote, "N", "0","018,018") // negrito
	
	MSCBSAY(02+cColuna,11,"Val.: "+CValToChar(DtVenc), "N", "0", "018,018") // negrito
	
	if AllTrim(aBrowse[linha][1]) <> "**IDENTIF DE VOLUME**"
		MSCBSAYBAR(23+cColuna,5,CodBar,"N","MB04",7, .F., .T., .F., ,1,1, .F., .F., "1", .T.)
	Endif


	/* impress„o da segunda coluna */

	cColuna := 49

	MSCBSAY(02+cColuna,02,Prod,"N","0","020,020")
	
	MSCBSAY(02+cColuna,06,Cod, "N", "0", "018,018")
	
	MSCBSAY(02+cColuna,08.5,Volume+UMEMB+" Lot: "+cLote, "N", "0","018,018") // negrito
	
	MSCBSAY(02+cColuna,11,"Val.: "+CValToChar(DtVenc), "N", "0", "018,018") // negrito
	
	//if AllTrim(aBrowse[linha][1]) <> "**IDENTIF DE VOLUME**"
		MSCBSAYBAR(23+cColuna,5,CodBar,"N","MB04",7, .F., .T., .F., ,1,1, .F., .F., "1", .T.)
	//Endif


	

	MSCBEND()
	MSCBCLOSEPRINTER()


Return()


/*/{Protheus.doc} PCP037_07
Etiqueta 75x35mm volume
@type function
@author neliedercorneta
@since 23/12/2021
@param linha, logical, linha
@param qtd, variant, qtd produtos
/*/
Static Function PCP037_07(linha,qtd)

Local cModelo := "ZEBRA"
Local Prod,ProdTxt,Cod,Unid,CodBar
Local Validade,Prevf,PrazoVali,Dias,cLote
Local DtVenc,cEmb,UMEMB


	Cod           := AllTrim(aBrowse[linha][2])
	ProdTxt       := AllTrim(aBrowse[linha][4])
	Unid          := SUBSTR(aBrowse[linha][5],1,2)
	Unid          := AllTrim(Unid)
	Unid          := StrZero(val(Unid),2)
	Validade      := aBrowse[linha][6]
	Prevf         := AllTrim(aBrowse[linha][7])
	cLote         := AllTrim(aBrowse[linha][8])
	PrazoVali     := aBrowse[linha][10]
	Prod          := AllTrim(aBrowse[linha][11])
	cXidvol       := AllTrim(aBrowse[linha][12])
	cXidvol       := StrZero(val(cXidvol),4)

	IF Empty(PrazoVali)
		PrazoVali     := 0
		Dias          := 0
	Endif

	IF Empty(Validade)
		Validade      := 0
	Endif


	IF(PrazoVali > 0)
		Dias          := (PrazoVali * 30)
		DtVenc        := DaySum(STOD(Prevf), Dias )
	else
		Dias          := (Validade * 30)
		DtVenc        := DaySum(STOD(Prevf), Dias )
	Endif

/* identifica embalagem */
	If len(Alltrim(Cod)) == 12
		cEmb          := substr(Cod,11,2)
	Endif

	CodBar        := cLote+cEmb+Unid+StrZero( (val(cXidvol))+qtd , 4)
	UMEMB   	  := UniMed(CodBar,Cod)


	MSCBPRINTER(cModelo, cLPT,,12,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBLOADGRF("SIGA.GRF")
	MSCBBEGIN(1,6)

	MSCBSAY(03,02 ,Prod, "N", "0", "025,035") // negrito
	MSCBSAY(65,02 ,cEmb, "N", "0", "025,035") // negrito
	MSCBSAY(03,05 ,"**Val.: "+ CValToChar(DtVenc)+"** IDENTIF VOL *", "N", "0", "025,030") // negrito
	
	MSCBLineH(00,10,190,3, 'B' )
	
	MSCBSAY(03,11,"COD:", "N", "0", "025,022") // negrito

	Cod = TRANSFORM(Cod, "@R XX 99.99.999-99")

	MSCBSAY(09,11,Cod, "N", "0", "025,025") // negrito
	MSCBSAY(57,11, AllTrim(UMEMB), "N", "0", "026,026") // negrito

	
	MSCBSAYBAR(03,16,CodBar,"N","MB01",7, .F., .T., .F., ,3,3, .F., .F., "1", .T.)

	MSCBEND()
	MSCBCLOSEPRINTER()


Return()


/*/{Protheus.doc} PCP037_08
Etiqueta volume 75x35mm
@type function
@author neliedercorneta
@since 23/12/2021
@param linha, logical, linha
@param qtd, variant, qtd de produtos
/*/
Static Function PCP037_08(linha,qtd)
	
	Local cModelo 	:= "ZEBRA"
	Local Prod,ProdTxt,Cod,Unid,CodBar
	Local Validade,Prevf,PrazoVali,Dias,cLote
	Local DtVenc,cEmb
	Local Volume,UMEMB

	Local Catalis,RelCat1
	
	
	Cod        := AllTrim(aBrowse[linha][2])
	ProdTxt    := AllTrim(aBrowse[linha][4])
	Unid       := SUBSTR(aBrowse[linha][5],1,2)
	Unid       := AllTrim(Unid)
	Unid       := StrZero(val(Unid),2)
	Validade   := aBrowse[linha][6]
	Prevf      := AllTrim(aBrowse[linha][7])
	cLote      := AllTrim(aBrowse[linha][8])
	CodBar     := AllTrim(aBrowse[linha][9])
	PrazoVali := AllTrim(aBrowse[linha][10])
	Prod       := AllTrim(aBrowse[linha][11])

	cXidvol    := AllTrim(aBrowse[linha][12])
	cXidvol    := StrZero(val(cXidvol),4)
	Volume     := CValToChar(aBrowse[linha][13])
	UMEMB 	   := CValToChar(aBrowse[linha][14])

	Catalis	   := AllTrim(aBrowse[linha][15])	
	RelCat1    := AllTrim(aBrowse[linha][16])

	if val(Volume) < 1
		Volume := CValToChar (val(Volume) * 1000)
		UMEMB 	   := "ml"
	else
		UMEMB 	   := CValToChar(aBrowse[linha][14])
	endif


	IF Empty(PrazoVali)
		PrazoVali := 0
		Dias := 0
	Endif

	IF Empty(Validade)
		Validade := 0
	Endif

	IF(PrazoVali > 0)
		Dias := (PrazoVali * 30)
		DtVenc := DaySum(STOD(Prevf), Dias  )
	else
		Dias := (Validade * 30)
		DtVenc := DaySum(STOD(Prevf), Dias  )
	Endif


	/* identifica embalagem */
	If len(Alltrim(Cod)) == 12
		cEmb := substr(Cod,11,2)
	Endif

	MSCBPRINTER(cModelo, cLPT,,12,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBLOADGRF("SIGA.GRF")
	MSCBBEGIN(1,6)

	MSCBSAY(03,02   ,Prod, "N", "0", "025,035") // negrito
	MSCBSAY(65,02   ,cEmb, "N", "0", "025,035") // negrito
	MSCBSAY(03,06   ,ProdTxt, "N", "0", "025,035") // negrito
	
	MSCBLineH(00,10,190,3,'B')
	
	MSCBSAY(03,11,"COD:", "N", "0", "025,022") // negrito
	Cod = TRANSFORM(Cod, "@R XX 99.99.999-99")
	MSCBSAY(09,11,Cod, "N", "0", "025,022") 
	
	MSCBSAY(03,15,"LOT:", "N", "0", "020,022") // negrito
	MSCBSAY(09,15,cLote, "N", "0", "020,022") 
		
	MSCBSAY(19,15,"Val.: "+CValToChar(DtVenc), "N", "0", "020,022") // negrito
	
	
	if Empty(Catalis)
		MSCBSAY(03,23,"CONTEUDO "+Volume+" "+UMEMB, "N", "0","068,068") // negrito
		MSCBSAYBAR(45,11,CodBar,"N","MB04",6, .F., .T., .F., ,03,03, .F., .F., "1", .T.)
		MSCBSAY(45,20,cObs, "N", "0","022,022") // negrito
	else
		MSCBSAY(03,23,"CONTEUDO "+Volume+" "+UMEMB, "N", "0","068,068") // negrito
		Catalis = TRANSFORM(Catalis, "@R XX 99.99.999-99")
		MSCBSAY(03,19,"CAT: "+Catalis+" ("+RelCat1+")", "N", "0","022,022") // negrito
		MSCBSAY(45,20,cObs, "N", "0","022,022") // negrito
		MSCBSAYBAR(45,11,CodBar,"N","MB04",6, .F., .T., .F., ,02,02, .F., .F., "1", .T.)
	Endif	

	

	MSCBEND()
	MSCBCLOSEPRINTER()


Return()



/*/{Protheus.doc} PCP037_09
Etiqueta 100x69mm de Volume
@type function
@author neliedercorneta
@since 23/12/2021
@param linha, logical, linha
@param qtd, variant, qtd produtos
/*/
Static Function PCP037_09(linha,qtd)

Local cModelo := "ZEBRA"
Local Prod,ProdTxt,Cod,Unid,CodBar
Local Validade,Prevf,PrazoVali,Dias,cLote
Local DtVenc,cEmb
Local Volume,UMEMB,Catalis,RelCat1


	Cod           := AllTrim(aBrowse[linha][2])
	ProdTxt       := AllTrim(aBrowse[linha][4])
	Unid          := SUBSTR(aBrowse[linha][5],1,2)
	Unid          := AllTrim(Unid)
	Unid          := StrZero(val(Unid),2)
	Validade      := aBrowse[linha][6]
	Prevf         := AllTrim(aBrowse[linha][7])
	cLote         := AllTrim(aBrowse[linha][8])
	PrazoVali     := aBrowse[linha][10]
	Prod          := AllTrim(aBrowse[linha][11])

	cXidvol       := AllTrim(aBrowse[linha][12])
	cXidvol       := StrZero(val(cXidvol),4)

	Volume     := CValToChar(aBrowse[linha][13])

	UMEMB 	   := CValToChar(aBrowse[linha][14])

	Catalis	   := AllTrim(aBrowse[linha][15])	
	RelCat1    := AllTrim(aBrowse[linha][16])

	IF Empty(PrazoVali)
		PrazoVali     := 0
		Dias          := 0
	Endif

	IF Empty(Validade)
		Validade      := 0
	Endif


	IF(PrazoVali > 0)
		Dias          := (PrazoVali * 30)
		DtVenc        := DaySum(STOD(Prevf), Dias )
	else
		Dias          := (Validade * 30)
		DtVenc        := DaySum(STOD(Prevf), Dias )
	Endif

/* identifica embalagem */
	If len(Alltrim(Cod)) == 12
		cEmb          := substr(Cod,11,2)
	Endif

	CodBar        := cLote+cEmb+Unid+StrZero( (val(cXidvol))+qtd , 4)
	UMEMB   := UniMed(CodBar,Cod)


	MSCBPRINTER(cModelo, cLPT,,12,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBLOADGRF("SIGA.GRF")
	MSCBBEGIN(1,6)

	MSCBSAY(04,06 ,substr(Prod,1,24),"N", "0", "045,055") // negrito
	MSCBSAY(90,06 ,cEmb, "N", "0", "045,055") // negrito
	MSCBSAY(04,16 ,"**Val.: "+ CValToChar(DtVenc)+"** IDENTIF VOL *", "N", "0", "045,055") // negrito
	
	MSCBLineH(00,22,190,3, 'B' )
	MSCBSAY(04,26.5,"COD:", "N", "0", "035,035") // negrito
	Cod = TRANSFORM(Cod, "@R XX 99.99.999-99")
	MSCBSAY(15,26,Cod, "N", "0", "050,060") // negrito
	MSCBSAY(80,26,UMEMB, "N", "0", "040,040") // negrito
	
	MSCBSAYBAR(9,35,CodBar,"N","MB01",12, .F., .T., .F., ,5,5, .F., .F., "1", .T.)


	MSCBEND()
	MSCBCLOSEPRINTER()


Return()







/*/{Protheus.doc} PCP037_10
Etiqueta 100x69mm de Produto
@type function
@author neliedercorneta
@since 23/12/2021
@param linha, logical, linha
@param qtd, variant, qtd de produtos
/*/
Static Function PCP037_10(linha,qtd)
	
	Local cModelo := "ZEBRA"
	Local Prod,ProdTxt,Cod,Unid,CodBar
	Local Validade,Prevf,PrazoVali,Dias,cLote
	Local DtVenc,cEmb
	Local Volume,UMEMB

	Local Catalis,RelCat1

	Cod           := AllTrim(aBrowse[linha][2])
	ProdTxt       := AllTrim(aBrowse[linha][4])
	Unid          := SUBSTR(aBrowse[linha][5],1,2)
	Unid          := AllTrim(Unid)
	Unid          := StrZero(val(Unid),2)
	Validade      := aBrowse[linha][6]
	Prevf         := AllTrim(aBrowse[linha][7])
	cLote         := AllTrim(aBrowse[linha][8])
	CodBar        := AllTrim(aBrowse[linha][9])
	PrazoVali     := aBrowse[linha][10]
	Prod          := AllTrim(aBrowse[linha][11])

	cXidvol       := AllTrim(aBrowse[linha][12])
	cXidvol       := StrZero(val(cXidvol),4)
	Volume        := CValToChar(aBrowse[linha][13])
	UMEMB         := CValToChar(aBrowse[linha][14])

	Catalis       := AllTrim(aBrowse[linha][15])
	RelCat1       := AllTrim(aBrowse[linha][16])


	IF Empty(PrazoVali)
		PrazoVali     := 0
		Dias          := 0
	Endif

	IF Empty(Validade)
		Validade      := 0
	Endif

	IF(PrazoVali > 0)
		Dias          := (PrazoVali * 30)
		DtVenc        := DaySum(STOD(Prevf), Dias )
	else
		Dias          := (Validade * 30)
		DtVenc        := DaySum(STOD(Prevf), Dias )
	Endif


	/* identifica embalagem */
	If len(Alltrim(Cod)) == 12
		cEmb          := substr(Cod,11,2)
	Endif

	if val(Volume) < 1
		Volume := CValToChar (val(Volume) * 1000)
		UMEMB 	   := "ml"
	else
		UMEMB 	   := CValToChar(aBrowse[linha][14])
	endif

	MSCBPRINTER(cModelo, cLPT,,12,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBLOADGRF("SIGA.GRF")
	MSCBBEGIN(1,6)

	MSCBSAY(04,05 ,substr(Prod,1,24),"N", "0", "045,055") // negrito
	MSCBSAY(90,05 ,cEmb, "N", "0", "045,055") // negrito
	MSCBSAY(04,12 ,ProdTxt, "N", "0", "045,055") // negrito

	MSCBLineH(00,17,190,3, 'B' )
	MSCBSAY(04,20.5,"COD:", "N", "0", "035,035") // negrito
	Cod = TRANSFORM(Cod, "@R XX 99.99.999-99")
	MSCBSAY(15,20,Cod, "N", "0", "050,060") // negrito

	MSCBSAY(80,19,"Lote:", "N", "0", "030,030") // negrito
	MSCBSAY(80,23,cLote, "N", "0", "040,040") // negrito

	MSCBSAY(04,27,"DT FABR:", "N", "0", "030,030") // negrito
	MSCBSAY(04,31,CValToChar(STOD(Prevf)), "N", "0", "040,040") // negrito

	MSCBSAY(32,27,"VALIDADE:", "N", "0", "030,030") // negrito
	MSCBSAY(32,31,CValToChar(DtVenc), "N", "0", "040,040") // negrito

	MSCBSAY(04,38,"PESO LIQ.:", "N", "0", "040,040") // negrito
	MSCBSAY(04,43,Volume+UMEMB, "N", "0", "060,065") // negrito

	If !empty(AllTrim(Prod)) .and. (Val(Volume) > 0)
		MSCBSAY(04,52,OemToAnsi("TEMPERATURA DE CURA: 200 ∫C - 10 Minutos"), "N", "0", "035,035") // negrito
	Endif

	CodBar        := cLote+cEmb+Unid+StrZero( (val(cXidvol))+qtd , 4)
	MSCBSAYBAR(55,35,CodBar,"N","MB04",8, .F., .T., .F., ,3,3, .F., .F., "1", .T.)

	MSCBEND()
	MSCBCLOSEPRINTER()


	


Return()


/*/{Protheus.doc} PCP037_11
Etiqueta 26x15mm(xarope)
@type function
@author neliedercorneta
@since 23/12/2021
@param linha, logical, linha
@param qtd, variant, qtd de produtos
/*/
Static Function PCP037_11(linha,qtd)
	
	Local cModelo := "ZEBRA"
	Local Prod,ProdTxt,Cod,Unid,CodBar
	Local Validade,Prevf,PrazoVali,Dias,cLote
	Local DtVenc,cEmb
	Local Volume,UMEMB

	Local Catalis,RelCat1

	Cod           := AllTrim(aBrowse[linha][2])
	ProdTxt       := AllTrim(aBrowse[linha][4])
	Unid          := SUBSTR(aBrowse[linha][5],1,2)
	Unid          := AllTrim(Unid)
	Unid          := StrZero(val(Unid),2)
	Validade      := aBrowse[linha][6]
	Prevf         := AllTrim(aBrowse[linha][7])
	cLote         := AllTrim(aBrowse[linha][8])
	CodBar        := AllTrim(aBrowse[linha][9])
	PrazoVali     := aBrowse[linha][10]
	Prod          := AllTrim(aBrowse[linha][11])

	cXidvol       := AllTrim(aBrowse[linha][12])
	cXidvol       := StrZero(val(cXidvol),4)
	Volume        := CValToChar(aBrowse[linha][13])
	UMEMB         := CValToChar(aBrowse[linha][14])

	Catalis       := AllTrim(aBrowse[linha][15])
	RelCat1       := AllTrim(aBrowse[linha][16])


	IF Empty(PrazoVali)
		PrazoVali     := 0
		Dias          := 0
	Endif

	IF Empty(Validade)
		Validade      := 0
	Endif

	IF(PrazoVali > 0)
		Dias          := (PrazoVali * 30)
		DtVenc        := DaySum(STOD(Prevf), Dias )
	else
		Dias          := (Validade * 30)
		DtVenc        := DaySum(STOD(Prevf), Dias )
	Endif

	/* identifica embalagem */
	If len(Alltrim(Cod)) == 12
		cEmb          := substr(Cod,11,2)
	Endif

	MSCBPRINTER(cModelo, cLPT,,12,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBBEGIN(1,6)
	
	MSCBSAY(05.5,03,"Lt "+cLote , "N", "0", "024,027") // negrito
	MSCBSAY(05.5,07,"Fab "+CValToChar(STOD(Prevf)), "N", "0", "024,027") // negrito
	MSCBSAY(05.5,11,"Val  "+CValToChar(DtVenc), "N", "0", "024,027") // negrito

	MSCBSAY(32.5,03,"Lt "+cLote , "N", "0", "024,027") // negrito
	MSCBSAY(32.5,07,"Fab "+CValToChar(STOD(Prevf)), "N", "0", "024,027") // negrito
	MSCBSAY(32.5,11,"Val  "+CValToChar(DtVenc), "N", "0", "024,027") // negrito

	MSCBSAY(58.5,03,"Lt "+cLote , "N", "0", "024,027") // negrito
	MSCBSAY(58.5,07,"Fab "+CValToChar(STOD(Prevf)), "N", "0", "024,027") // negrito
	MSCBSAY(58.5,11,"Val  "+CValToChar(DtVenc), "N", "0", "024,027") // negrito


	MSCBEND()
	MSCBCLOSEPRINTER()


Return()





Static Function ReportPrint(nTipo)

local n      := 1
local i      := 1
local linhas := len(aBrowse)
local qtd
local linha,Prevf,UMEMB,Volume
Local Letiq := 0

Private oPrint
Private oFont10     := TFont():New('Arial',,10,,.F.,,,,.F.,.F.)
Private oFont10n    := TFont():New('Arial',,10,,.T.,,,,.F.,.F.)

Private oFont12     := TFont():New('Arial',,12,,.F.,,,,.F.,.F.)
Private oFont12n    := TFont():New('Arial',,12,,.T.,,,,.F.,.F.)

Private oFont15     := TFont():New('Arial',,15,,.F.,,,,.F.,.F.)
Private oFont15n    := TFont():New('Arial',,15,,.T.,,,,.F.,.F.)

Private oFont30     := TFont():New('Arial',,30,,.F.,,,,.F.,.F.)
Private oFont30n    := TFont():New('Arial',,30,,.T.,,,,.F.,.F.)


    oPrint := TMSPrinter():New(OemToAnsi('Etiqueta de produto'))
    oPrint:SetPortrait()
    
    oPrint:StartPage()  
    nLin  := 0050
    nRow1 := 0
    cPage := 0
    cont := 0
    
	/* Loop nas linhas do Array */
	For n        := 1 to linhas

	linha := n
	Cod           := AllTrim(aBrowse[linha][2])
	Cod 		  := TRANSFORM(Cod, "@R XX 99.99.999-99")

	ProdTxt       := AllTrim(aBrowse[linha][4])
	Unid          := SUBSTR(aBrowse[linha][5],1,2)
	Unid          := AllTrim(Unid)
	Unid          := StrZero(val(Unid),2)
	Validade      := aBrowse[linha][6]
	Prevf         := AllTrim(aBrowse[linha][7])
	cLote         := AllTrim(aBrowse[linha][8])
	CodBar        := AllTrim(aBrowse[linha][9])
	PrazoVali     := aBrowse[linha][10]
	Prod          := AllTrim(aBrowse[linha][11])

	cXidvol       := AllTrim(aBrowse[linha][12])
	cXidvol       := StrZero(val(cXidvol),4)
	Volume        := CValToChar(aBrowse[linha][13])
	UMEMB         := CValToChar(aBrowse[linha][14])

	Catalis	   := AllTrim(aBrowse[linha][15])	
	RelCat1    := AllTrim(aBrowse[linha][16])


	IF Empty(PrazoVali)
		PrazoVali     := 0
		Dias          := 0
	Endif

	IF Empty(Validade)
		Validade      := 0
	Endif


	IF(PrazoVali > 0)
		Dias          := (PrazoVali * 30)
		DtVenc        := DaySum(STOD(Prevf), Dias )
	else
		Dias          := (Validade * 30)
		DtVenc        := DaySum(STOD(Prevf), Dias )
	Endif

	/* identifica embalagem */
	If len(Alltrim(Cod)) >= 12
		cEmb          := substr(Cod,11,2)
	Endif

		/* qtd de etiquetas a ser impressa */
		qtd          := CValToChar(aBrowse[n][3])
		
		/* soma qtd adicional de etiquetas */
		if AllTrim(aBrowse[n][1]) == "**IDENTIF DE VOLUME**"
			qtdReal      := val(qtd) + cQtde2
		Else
			qtdReal      := val(qtd) + cQtde1

		Endif


		/* loop na qtd de etiquetas a ser impressa */
		For i        := 1 to qtdReal
		
			Do Case
			Case nTipo == 1
				/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
				# Impress„o de Etiquetas Zembras #
				ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
				
				if AllTrim(aBrowse[n][1]) == "**IDENTIF DE VOLUME**"

					CodBar        := cLote+cEmb+Unid+StrZero( (val(cXidvol))+val(qtd) , 4)
					UMEMB         := UniMed(CodBar,Cod)

					oPrint:Say(nLin,0050,OemToAnsi(Prod),oFont15n,,,,0)
					oPrint:Say(nLin,0800,OemToAnsi(cEmb),oFont15n,,,,0)
					nLin += 050
					oPrint:Say(nLin,0050,"**Val.: "+ CValToChar(DtVenc)+"** IDENTIF VOL *",oFont15n,,,,0)
					nLin += 060
					oPrint:Line (nLin,0010,nLin,850)
					nLin  += 040
					
					oPrint:Say(nLin,0050,OemToAnsi("COD: "+Cod),oFont12n,,,,0)
					oPrint:Say(nLin,0700,OemToAnsi(AllTrim(UMEMB)),oFont12n,,,,0)
					nLin  += 050
					CodBar        := cLote+cEmb+Unid+StrZero( (val(cXidvol))+i , 4)
					MSBAR3( 'CODE128', 2.2+Letiq , 2, CodBar, oPrint, .T.,10, .T., 0.030,1.2, .T.,,, .F. )
					nLin  += 300
					Letiq += 4.2 
					
					
				else

					if val(Volume) < 1
						Volume := CValToChar (val(Volume) * 1000)
						UMEMB 	   := "ml"
					else
						UMEMB 	   := CValToChar(aBrowse[linha][14])
					endif

					oPrint:Line (nLin,0010,nLin,850)
					nLin += 020
					oPrint:Say(nLin,0050,OemToAnsi(Prod),oFont15n,,,,0)
					oPrint:Say(nLin,0800,OemToAnsi(cEmb),oFont15n,,,,0)
					nLin += 050
					oPrint:Say(nLin,0050,OemToAnsi(ProdTxt),oFont15n,,,,0)
					nLin += 060
					oPrint:Line (nLin,0010,nLin,850)
					nLin  += 040
					
					oPrint:Say(nLin,0050,OemToAnsi("COD: "+Cod),oFont12n,,,,0)
					nLin += 060
					oPrint:Say(nLin,0050,OemToAnsi("LOT: "+cLote),oFont12n,,,,0)
					oPrint:Say(nLin,0250,OemToAnsi("Val: "+CValToChar(DtVenc)),oFont12n,,,,0)
					nLin += 040
					MSBAR3( 'CODE128', 1.7+Letiq , 4, CodBar+U_DigEan13(CodBar), oPrint, .T.,10, .T., 0.025,1, .T.,,, .F. )
					nLin += 030
					oPrint:Say(nLin,0040,OemToAnsi("Conteudo: "+CValToChar(Volume)+" "+CValToChar(UMEMB)),oFont30n,,,,0)
					nLin += 100
					oPrint:Line (nLin,0010,nLin,850)
					nLin += 150
					Letiq += 4.64 	
					
				Endif

			Case nTipo == 2
				/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
				# Impress„o de Etiquetas 26x15mm(xarope) #
				ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
				if AllTrim(aBrowse[n][1]) <> "**IDENTIF DE VOLUME**"

					oPrint:Say(nLin,0050,OemToAnsi("LT "+cLote),oFont12n,,,,0)
					nLin += 050
					oPrint:Say(nLin,0050,OemToAnsi("Fab "+CValToChar(STOD(Prevf))),oFont12n,,,,0)
					nLin += 050
					oPrint:Say(nLin,0050,OemToAnsi("Val "+CValToChar(DtVenc)),oFont12n,,,,0)
					nLin  += 150

				Endif

			Case nTipo == 3

				/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
				# Impress„o de Etiquetas 44x15mm #
				ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/

					oPrint:Say(nLin,0050,OemToAnsi(Prod),oFont12n,,,,0)
					nLin += 050
					oPrint:Say(nLin,0050,OemToAnsi(Cod),oFont12n,,,,0)
					nLin += 050
					oPrint:Say(nLin,0050,OemToAnsi(Volume+UMEMB+" Lot: "+cLote),oFont12n,,,,0)
					nLin += 050
					oPrint:Say(nLin,0050,OemToAnsi("Val "+CValToChar(DtVenc)),oFont12n,,,,0)
					CodBar        := cLote+cEmb+Unid+StrZero( (val(cXidvol))+i , 4)
					MSBAR3( 'CODE128', 0.8+Letiq , 3, CodBar, oPrint, .T.,8, .T., 0.022,0.85, .T.,,, .F. )
					nLin  += 150
					Letiq += 2.55


			Case nTipo == 4
				/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
				# Impress„o de Etiquetas 75x35mm #
				ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
				if AllTrim(aBrowse[n][1]) == "**IDENTIF DE VOLUME**"
					CodBar        := cLote+cEmb+Unid+StrZero( (val(cXidvol))+val(qtd) , 4)
					UMEMB         := UniMed(CodBar,Cod)

					oPrint:Say(nLin,0050,OemToAnsi(Prod),oFont15n,,,,0)
					oPrint:Say(nLin,0800,OemToAnsi(cEmb),oFont15n,,,,0)
					nLin += 050
					oPrint:Say(nLin,0050,"**Val.: "+ CValToChar(DtVenc)+"** IDENTIF VOL *",oFont15n,,,,0)
					nLin += 060
					oPrint:Line (nLin,0010,nLin,850)
					nLin  += 040
					
					oPrint:Say(nLin,0050,OemToAnsi("COD: "+Cod),oFont12n,,,,0)
					oPrint:Say(nLin,0700,OemToAnsi(AllTrim(UMEMB)),oFont12n,,,,0)
					nLin  += 050
					
					MSBAR3( 'CODE128', 2.2+Letiq , 2, CodBar, oPrint, .T.,10, .T., 0.030,1.2, .T.,,, .F. )
					nLin  += 300
					Letiq += 4.2 

				else

					if val(Volume) < 1
						Volume := CValToChar (val(Volume) * 1000)
						UMEMB 	   := "ml"
					else
						UMEMB 	   := CValToChar(aBrowse[linha][14])
					endif

					oPrint:Line (nLin,0010,nLin,850)
					nLin += 020
					oPrint:Say(nLin,0050,OemToAnsi(Prod),oFont15n,,,,0)
					oPrint:Say(nLin,0800,OemToAnsi(cEmb),oFont15n,,,,0)
					nLin += 050
					oPrint:Say(nLin,0050,OemToAnsi(ProdTxt),oFont15n,,,,0)
					nLin += 060
					oPrint:Line (nLin,0010,nLin,850)
					nLin  += 040
					
					oPrint:Say(nLin,0050,OemToAnsi("COD: "+Cod),oFont12n,,,,0)
					nLin += 060
					oPrint:Say(nLin,0050,OemToAnsi("LOT: "+cLote),oFont12n,,,,0)
					oPrint:Say(nLin,0250,OemToAnsi("Val: "+CValToChar(DtVenc)),oFont12n,,,,0)
					nLin += 040
					MSBAR3( 'CODE128', 1.7+Letiq , 4, CodBar+U_DigEan13(CodBar), oPrint, .T.,10, .T., 0.025,1, .T.,,, .F. )
					nLin += 010

					if !Empty(Catalis)
						oPrint:Say(nLin,0050,OemToAnsi("CAT: "+Catalis+" ("+RelCat1+")"+CValToChar(UMEMB)),oFont12n,,,,0)
					Endif
					nLin += 020	
					oPrint:Say(nLin,0040,OemToAnsi("Conteudo: "+CValToChar(Volume)+" "+CValToChar(UMEMB)),oFont30n,,,,0)
					nLin += 130
					oPrint:Line (nLin,0010,nLin,850)
					nLin += 150
					Letiq += 4.9 	

				Endif
			Case nTipo == 5

				/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
				# Impress„o de Etiquetas 100x69mm #
				ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
				if AllTrim(aBrowse[n][1]) == "**IDENTIF DE VOLUME**"
					CodBar        := cLote+cEmb+Unid+StrZero( (val(cXidvol))+val(qtd) , 4)
					UMEMB         := UniMed(CodBar,Cod)

					oPrint:Say(nLin,0050,OemToAnsi(Prod),oFont15n,,,,0)
					oPrint:Say(nLin,0800,OemToAnsi(cEmb),oFont15n,,,,0)
					nLin += 050
					oPrint:Say(nLin,0050,"**Val.: "+ CValToChar(DtVenc)+"** IDENTIF VOL *",oFont15n,,,,0)
					nLin += 060
					oPrint:Line (nLin,0010,nLin,850)
					nLin  += 040
					
					oPrint:Say(nLin,0050,OemToAnsi("COD: "+Cod),oFont15n,,,,0)
					oPrint:Say(nLin,0700,OemToAnsi(AllTrim(UMEMB)),oFont15n,,,,0)
					nLin  += 050

					MSBAR3( 'CODE128', 2.2+Letiq , 2, CodBar, oPrint, .T.,10, .T., 0.030,1.2, .T.,,, .F. )
					nLin  += 300
					Letiq += 4.2 

				else

					if val(Volume) < 1
						Volume := CValToChar (val(Volume) * 1000)
						UMEMB 	   := "ml"
					else
						UMEMB 	   := CValToChar(aBrowse[linha][14])
					endif

					oPrint:Line (nLin,0010,nLin,850)
					nLin += 020
					oPrint:Say(nLin,0050,OemToAnsi(Prod),oFont15n,,,,0)
					oPrint:Say(nLin,0800,OemToAnsi(cEmb),oFont15n,,,,0)
					nLin += 050
					oPrint:Say(nLin,0050,OemToAnsi(ProdTxt),oFont15n,,,,0)
					nLin += 060
					oPrint:Line (nLin,0010,nLin,850)
					nLin  += 040
					
					oPrint:Say(nLin,0050,OemToAnsi("COD: "+Cod),oFont15n,,,,0)
					nLin -= 020
					oPrint:Say(nLin,0700,OemToAnsi("LOTE: "),oFont12n,,,,0)
					nLin += 040
					oPrint:Say(nLin,0700,OemToAnsi(cLote),oFont12n,,,,0)
					nLin += 040
					oPrint:Say(nLin,0050,OemToAnsi("DT FABR: "),oFont12n,,,,0)
					oPrint:Say(nLin,0250,OemToAnsi("DT VALIDADE: "),oFont12n,,,,0)
					nLin += 040
					oPrint:Say(nLin,0050,OemToAnsi(CValToChar(STOD(Prevf))),oFont12n,,,,0)
					oPrint:Say(nLin,0250,OemToAnsi(CValToChar(DtVenc)),oFont12n,,,,0)
					nLin += 040
					oPrint:Say(nLin,0050,OemToAnsi("PESO LIQ.:"),oFont15n,,,,0)
					nLin += 040
					oPrint:Say(nLin,0050,OemToAnsi(CValToChar(Volume)+" "+CValToChar(UMEMB)),oFont30n,,,,0)
					nLin += 100
					If !empty(AllTrim(Prod)) .and. (Val(Volume) > 0)
						oPrint:Say(nLin,0050,OemToAnsi("TEMPERATURA DE CURA: 200 ∫C - 10 Minutos"),oFont12n,,,,0)
					Endif
					
					
					MSBAR3( 'CODE128', 2.7+Letiq , 4, CodBar+U_DigEan13(CodBar), oPrint, .T.,10, .T., 0.025,1, .T.,,, .F. )
					
					nLin += 130
					oPrint:Line (nLin,0010,nLin,850)
					nLin += 150
					Letiq += 6.15 	

				Endif
				
			EndCase
				if nLin >= 3200
					oPrint:EndPage()
					cPage := 0
					nRow1 := 0
					nLin  := 0050
					Letiq := 0
				endif 
		NEXT

		 if nLin >= 3200
            oPrint:EndPage()
            cPage := 0
            nRow1 := 0
            nLin  := 0050
			Letiq := 0
        endif 

	NEXT
    
		
                
                  


    oPrint:Preview()
    oPrint:end()

return

/*/{Protheus.doc} UniMed
Calcula Unidade de Medida
@type function
@author neliedercorneta
@since 12/01/2022
@param codbarra, character, codigo de barra
@param codigo, character, codigo do produto
@return variant, unidade de medida
/*/
Static function UniMed(codbarra,codigo)
local retorno

if  (len( AllTrim(codbarra)) == 14)
		retorno :=	substr(codbarra,9,2)

		if (SUBSTR(codigo,11,2) == "99")
			retorno :=	retorno + " Kg"
		endif	
			
		if (SUBSTR(codigo,11,2) == "00")
			retorno := retorno + " L"
			else
			retorno := retorno +  " Unid"
		endif	

endif
/* funÁ„o no fox pro */
//iif(len(allt(codbarra)) = 14,substr(codbarra,9,2)+IIF(SUBSTR(codigo,11,2) == "99"," Kg",IIF(SUBSTR(codigo,11,2) == "00"," L"," Unid")),"")

return(retorno)


/*/{Protheus.doc} ValidPort
FunÁ„o que Verifica se impressora est· disponÌvel
@type function
@author neliedercorneta
@since 12/01/2022
/*/
Static function ValidPort(cLPT)
local retorno := .F.

	if !IsPrinter(cLPT)
		  retorno := .T.
	endif  


return(retorno)


/*/{Protheus.doc} ListPort
Carrega Array com as portas disponiveis para impress„o
@type function
@author neliedercorneta
@since 12/01/2022
/*/
Static function ListPort()
local i
local porta

for i := 1 to 9
	
	porta := "LPT"+CValToChar(i)

	if IsPrinter(Porta)
		  aAdd(aLPT,Porta)
		  oLPT:SetItems(aLPT)
	endif  
next

return
