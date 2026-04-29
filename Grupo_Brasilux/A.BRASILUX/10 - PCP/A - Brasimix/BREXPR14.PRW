#Include "Protheus.ch"
#Include "TopConn.ch"

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ BREXPR14  ∫Autor  ≥ Jose Uliana       ∫ Data ≥  28/03/2025 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫DescriÁ„o ≥ Etiquetas EndereÁamento CD Araraquara (Etiqueta de Produtos)±±
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
  
User Function  BREXPR14()

//Bibliotecas
#Define STR_PULA    Chr(13)+Chr(10)

Local nTipo       := 1
Local _cGrpEmp

Local _cPerg :="BREXPR14" // Jose 28/03/2025


//Fontes
Private cFontUti  := "Tahoma"
Private oFontAno  := TFont():New(cFontUti, , -38)
Private oFontBtn  := TFont():New(cFontUti, , -14)
Private oFontSub  := TFont():New(cFontUti, , -16)
Private oFontSubN := TFont():New(cFontUti, , -20, , .T.)

//Tamanho da Janela
Private nJanLarg  := 400  // Jose 31/03/2025   730
Private nJanAltu  := 218  // Jose 31/03/2025   500

//Private cCodTam /* Codigo Tambor */

//Private oOP
//Private cOP       := space(13)

Private oLote
Private cLote     := space(6)

//Private oCodi
//Private cCodi     := space(11)

Private oQtde2
Private cQtde2    := space(6)

Private oCodf
Private cCodf     := space(11)

//Private oTambor
//Private cTambor   := space(10)

//Private oTbFab
//Private cTbFab    := cTod("  /  /  ")


//Private oCont
//Private cCont     := space(3)

Private aBrowse   := {}
Private oBrowse

//Private _ZPPAR0214 := GetMV( "ZP_PAR0214" ) // Habilita impressao do QrCode para o WMS SaaS    
//Private _ZPPAR0217 := GetMV( "ZP_PAR0217" ) // Tempo em milissegundos Impress„o contador Dissoltex

//_ZPPAR0214 := .T.



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
17 - REG(R_E_C_N_O_)
18 - C2_NUM
19 - C2_ITEM
20 - C2_SEQUEN
*/

//Private lEditar   := .T.
Private oBtnFech

//Private cFlag     := .F.

Private oLPT,cLPT

//Private aLPT      :={}
Private aLPT        :={"LPT1", "LPT2", "LPT3", "LPT4", "LPT5"}

Private oPrint,cPrint

//Private oPort,cPort

//Private _ZP_P200 := GETMV('ZP_PAR0200') //LINHA DE PRODUTO
//Private _ZP_P201 := GETMV('ZP_PAR0201') // CARACTERISTICA DO PRODUTO



_cGrpEmp := alltrim(FWGrpCompany())


if _cGrpEmp == "11"
	MessageBox("Esta operaÁ„o n„o pode ser executada na empresa TECPOLPA!","",48)
	return
endif


If !Pergunte( _cPerg ) 
   Return() //Se cancelar as perguntas sai do programa
Endif

/* define padr„o de data */
//  jOSE 28/03/2025  Set(_SET_DATEFORMAT, 'dd/mm/yy' )

    
//DEFINE MSDIALOG oDlg TITLE "Estiquetas de Localidade CD Araraquara (Etiqueta de Produtos)" FROM 000, 000 TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
DEFINE MSDIALOG oDlg TITLE "Estiquetas de Localidade CD Araraquara" FROM 000, 000 TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL

//jOSE 28/03/2025  @ 004, 003 MSPANEL oPanel SIZE 260, 100 OF oDlg COLORS 0, 14215660 CENTERED RAISED

//@ 010, 010 SAY OemToAnsi("N∫ da OP.: ") SIZE 060,009 PIXEL OF oDlg FONT oFontBtn
//@ 008, 060 MSGET oOP VAR cOP PICTURE "@!" SIZE 090,010 COLOR CLR_BLUE F3 "SC2" PIXEL ON CHANGE PCP037_99(nTipo) OF oDlg FONT oFontBtn

//@ 030, 010 SAY OemToAnsi("N∫ do Lote.: ") SIZE 060,009 PIXEL  OF oDlg FONT oFontBtn
//@ 028, 060 MSGET oLote VAR cLote PICTURE "@!" SIZE 045,010 COLOR CLR_BLUE F3 "ZC2" PIXEL ON CHANGE PCP037_99(nTipo) OF oDlg FONT oFontBtn

//cCodi      := ""
//@ 050, 010 SAY OemToAnsi("Cod. Inicial.: ") SIZE 100,009 PIXEL OF oDlg FONT oFontBtn
//@ 048, 060 MSGET oCodi VAR cCodi PICTURE "@!" SIZE 045,010 COLOR CLR_BLUE F3 "SB1" PIXEL ON CHANGE PCP037_02() OF oDlg FONT oFontBtn 

//cCodf      := ""
//@ 050, 130 SAY OemToAnsi("Cod. Final.:  ") SIZE 100,009 PIXEL OF oDlg FONT oFontBtn
//@ 048, 170 MSGET oCodf VAR cCodf PICTURE "@!" SIZE 045,010 COLOR CLR_BLUE F3 "SB1" PIXEL ON CHANGE PCP037_02() OF oDlg FONT oFontBtn

//cQtde2         := 0
//@ 070, 010 SAY OemToAnsi("Qtde Adic. de Ident. Vol.: ") SIZE 100,009 PIXEL OF oDlg FONT oFontBtn
//@ 068, 108 MSGET oQtde2 VAR cQtde2 PICTURE "999" SIZE 045,010 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn

/* Nelieder 13/06/2022 */
//@ 070, 160 SAY OemToAnsi("Contador Inicial Cx: ") SIZE 100,009 PIXEL OF oDlg FONT oFontBtn
//@ 068, 222 MSGET oCont VAR cCont PICTURE "999" SIZE 021,010 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn When .T.



/* Incluido em 04/11/2022 solicitado por Sabrina */
//@ 090, 010 SAY OemToAnsi("Clientes Tambor : ") SIZE 100,009 PIXEL OF oDlg FONT oFontBtn
//@ 088, 108 MSGET oTambor VAR cTambor PICTURE "@!" SIZE 045,010 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn // When .F.

/* Incluido em 04/11/2022 solicitado por Sabrina */
//@ 090, 160 SAY OemToAnsi("Dt Fabric:") SIZE 110,009 PIXEL OF oDlg FONT oFontBtn
//@ 088, 200 MSGET oTbFab VAR cTbFab SIZE 055,010 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn // When .F.

/*  jose 27/03/2025
oCont:bHelp := {||    ShowHelpCpo(    "cCont",;
                                {"Contador sequÍncial das caixas"+STR_PULA+"Utilizado apenas para etiquetas 100x69mm"},2,;
                                {""},2)}
// /**********************************************************
*/
@ 004, 002 MSPANEL oPanel SIZE 728, 525 OF oDlg COLORS 0, 14215660 FONT oFontBtn CENTERED RAISED // Jose 31/03/2025    004, 265  -   100, 100  

//@ 004, 004 RADIO oTipo VAR nTipo PROMPT "Zebra","26x15mm(Xarope)","44x15mm","75x35mm","100x69mm","100x50mm","100x200mm(Tambor)" ON CHANGE VLDRAD(nTipo)  OF oPanel PIXEL SIZE 75,20 //
@ 004, 004 RADIO oTipo VAR nTipo PROMPT "Zebra","100x70mm" ON CHANGE VLDRAD(nTipo)  OF oPanel PIXEL SIZE 75,20 //

/* funÁ„o que atualiza campo Cliente Tambor */
VLDRAD(nTipo)

@ 035, 004 SAY OemToAnsi("Porta\Impressora") SIZE 100,009 PIXEL OF oPanel FONT oFontBtn // Jose 31/03/2025  075, 004
@ 045, 004 MSCOMBOBOX oLPT VAR cLPT ITEMS aLPT SIZE 050, 007 OF oPanel COLORS 0, 16777215 PIXEL FONT oFontBtn // Jose 31/03/2025  085, 004
//ListPort()
//cLPT := GETMV('MV_PCP037') 

@ 065, 004 BUTTON oBtnFech PROMPT "Imprimir" SIZE 060, 018 OF oDlg ACTION PCP037_09(nTipo) FONT oFontBtn PIXEL // Jose 31/03/2025  120, 289
//@ 160,289 BUTTON oBtnFech PROMPT "Visualizar" SIZE 060, 018 OF oDlg ACTION ReportPrint(nTipo) FONT oFontBtn PIXEL
@ 085, 004 BUTTON oBtnFech PROMPT "Fechar" SIZE 060, 018 OF oDlg ACTION (oDlg:End()) FONT oFontBtn PIXEL // Jose 31/03/2025   195, 289

// Cria Browse
//aBrowse := {{ '' , '' , '' }}
//oBrowse  := TCBrowse():New(115, 004, 260, 130, , {'Produto', 'Produto', 'Qtde Etiq.' }, {130,50,10}, oDlg, , , , , {||lEditCell (@aBrowse, oBrowse, "999", 3)}, , oFontSub, , , , , .F., , .T., , .F., , ,)
oBrowse  := TCBrowse():New(115, 004, 260, 130, , { '', '', '' }, {130,50,10}, oDlg, , , , , {||lEditCell (@aBrowse, oBrowse, "999", 3)}, , oFontSub, , , , , .F., , .T., , .F., , ,)


// Seta vetor para a browse
oBrowse:SetArray(aBrowse)

// Monta a linha a ser exibina no Browse
//oBrowse:bLine  := {||{ aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAT,03], }}

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
/*  Jose 28/03/2025
Static Function PCP037_99(nTipo)

	// consultar por OP //
	if !Empty(cOP) .and. Empty(cLote)
// jose 28/03/2025		cLote := PCP037_02(cOP)
		 if !Empty(cLote)
		 	PCP037_01(nTipo)
		 EndIf	
		Return()
	Endif

	// consultar por Lote //
	if Empty(cOP) .and. !Empty(cLote)
		PCP037_01(nTipo)
		Return()
	Endif

	aBrowse := {{ '' , '' , '' }}
	oBrowse:SetArray(aBrowse)
	oBrowse:Refresh()

Return()
/*  Jose 28/03/2025  */

/*/{Protheus.doc} PCP037_01
Consulta Etiquetas por Lote
@type function
@author neliedercorneta
@since 12/01/2022
@param nTipo, numeric, tamanho de etiqueta selecionada
/*/
/* jose 28/03/2025
Static Function PCP037_01(nTipo)
local qtd

if Empty(cLote)
	MsgInfo( 'Necess·rio informar uma OP ou Lote ! ' , 'Etiquetas Produtos' )
	Return()
Endif

oBrowse         := TCBrowse():New(115, 004, 260, 130, , {'Produto','Produto', 'Qtde Etiq.' }, {130,50,10}, oDlg, , , , , {||lEditCell (@aBrowse, oBrowse, "@!", 3)}, , oFontSub, , , , , .F., , .T., , .F., , ,)
oBrowse:nLinhas := 2

cQuery := "SELECT Z4_TXTETIQ TXTETIQ,C2_NUM,C2_ITEM,C2_SEQUEN,B1_DESC AS NOMEPROD,Z1_DESCR AS TEXTO,B1_DESCLIN AS TEXTO2,B1_PRVALID,"
cQuery += "Z1_VALIDAD,C2_PRODUTO AS CODIGO,C2_QUANT AS QTDE,"
cQuery += "C2_LOTE AS LOTE,C2_DATPRF AS PREVF,B1_CODBAR AS CODBARRA,B1_CODGTIN,"
cQuery += "B1_CATALIS,B1_RELCAT1,B1_XCODANT,dbo.DetVol(C2_FILIAL,C2_PRODUTO) AS RELVOL,"
cQuery += "ISNULL(Z5_VOLUME,0) AS VOLUME,"
cQuery += " ISNULL(Z5_UMEMB, '' ) AS UMEMB, "
cQuery += "C2_XIDVOL,SC2.R_E_C_N_O_ AS REG "
cQuery += "FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "
cQuery += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (C2_FILIAL = SB1.B1_FILIAL) AND (C2_PRODUTO = SB1.B1_COD) AND (SB1.D_E_L_E_T_ <> '*' ) "
cQuery += "LEFT OUTER JOIN "+RetSqlName("SZ1")+" SZ1 WITH (NOLOCK) ON (LEN(C2_PRODUTO) = 12) AND (SUBSTRING(C2_PRODUTO,4,2) = SZ1.Z1_LINHA) AND (SZ1.D_E_L_E_T_ <> '*' ) AND (Z1_FILIAL = '"+xFilial("SZ1")+"' ) "
cQuery += "LEFT OUTER JOIN "+RetSqlName("SZ5")+" SZ5 WITH (NOLOCK) ON (LEN(C2_PRODUTO) = 12) AND (SUBSTRING(C2_PRODUTO,11,2) = SZ5.Z5_EMB) AND (SZ5.D_E_L_E_T_ <> '*' ) AND (Z5_FILIAL = '"+xFilial("SZ5")+"' ) "
cQuery += "LEFT OUTER JOIN "+RetSqlName("SZ4")+" SZ4 WITH (NOLOCK) ON (LEN(C2_PRODUTO) = 12) AND (SUBSTRING(C2_PRODUTO,4,2) = SZ4.Z4_LINHA) "

cQuery += "AND (SZ4.D_E_L_E_T_ <> '*' ) AND (Z4_FILIAL = '"+xFilial("SZ4")+"' ) AND  (SUBSTRING(C2_PRODUTO,1,2)) = Z4_CARAC "

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

SB5->(DbSetOrder(1)) //SB5_FILIAL+SB5_COD
If SB5->(DbSeek(Xfilial('SB5')+TMP->CODIGO))
	
	If !Empty(SB5->B5_XNORMA)
		// Etiqueta 100x50mm //
		oTipo:SetOption(6)
		oTipo:Refresh()
		MsgAlert('AtenÁ„o: <br> Produto atende a norma '+SB5->B5_XNORMA+' ! <br>verifique o modelo de etiqueta !')
		
	EndIf	

	If !Empty(SB5->B5_GREIF)
		// Etiqueta Greif//
		cCodTam := Alltrim(SB5->B5_GREIF)
		oTipo:SetOption(7)
		nTipo := 7
		oTipo:Refresh()
		MsgAlert('AtenÁ„o: <br> Produto possui Codigo Tambor !')
		
	EndIf	

Endif


aBrowse         := {}
While !TMP->(EoF())

    //trata excec„o para produtos que precisam de catalise do PA e n„o do PI
	//SUBSTR(TMP->CODIGO,4,2) LINHA
	//SUBSTR(TMP->CODIGO,1,2) CARACTERISTICA
	//_ZP_PAR0200 LINHA DE PRODUTO
	//_ZP_PAR0201 CARACTERISTICA DO PRODUTO

	//If ( SUBSTR(TMP->CODIGO,4,2) $ _ZP_P200 ) .AND. ( SUBSTR(TMP->CODIGO,1,2) $ _ZP_P201 )
		//CATALIPA(AllTrim(cLote))
	//EndIf

	// adiciona array produto //
	aAdd(aBrowse, { ;
		TMP->TEXTO,;
		TMP->CODIGO,;
		Padr(TMP->QTDE,4),;
		TMP->TEXTO,;
		RELVOL,;
		Z1_VALIDAD,;
		PREVF,;
		Lote,;
		CODBARRA,;
		B1_PRVALID,;
		REPLACE(TMP->NOMEPROD, "∫", "ß"),;
		TMP->c2_xidvol,;
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
		TMP->B1_CODGTIN;
		})

	if  (nTipo != 2) .AND. (nTipo != 7)   .AND. !EMPTY(ALLTRIM(TMP->RELVOL))
		
		// adiciona array volume //
		//qtd := U_DetVolEmba(substr(TMP->CODIGO,11,2), TMP->QTDE )
		qtd             := (TMP->QTDE / val(RELVOL))
		aAdd(aBrowse, { ;
			"**IDENTIF DE VOLUME**",;
			TMP->CODIGO,;
			Padr(qtd,4),;
			TMP->TEXTO,;
			RELVOL,;
			Z1_VALIDAD,;
			PREVF,;
			Lote,;
			CODBARRA,;
			B1_PRVALID,;
			REPLACE(TMP->NOMEPROD, "∫", "ß"),;
			TMP->c2_xidvol,;
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
			TMP->B1_CODGTIN;
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
     Jose 28/03/2025 */

/*/{Protheus.doc} PCP037_02
Consulta Etiquetas por Ordem de ProduÁ„o
@type function
@author neliedercorneta
@since 23/12/2021
@param xOP, variant, Ordem de ProduÁ„o
@return variant, Lote
/*/
/*  Jose 28/03/2025
Static Function PCP037_02()
Local cRet := ''

// remove caracteres //
//xCod := U_ChrTran(xCod, '!@#$%"&*()', '')
//xCod := U_ChrTran(xCod, "'", '')
 
cQuery := " SELECT C2_LOTE,C2_ITEM,C2_SEQUEN,C2_PRODUTO "
cQuery += " FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "
cQuery += " WHERE (C2_FILIAL = '"+xFilial("SC2")+"' ) AND "
cQuery += " (C2_NUM+C2_ITEM+C2_SEQUEN = '"+SUBSTR(xOP,1,11)+"' ) AND (D_E_L_E_T_ <> '*' ) "
cQuery += " ORDER BY C2_ITEM,C2_SEQUEN "
 

//cQuery :="SELECT B1_COD AS 'PRODUTO', B1_DESC AS 'DESCRICAO', B2_LOCAL AS 'ESTOQUE', B2_LOCALIZ AS 'PROVISORIO', " + CHR(13) + CHR(10)  
//cQuery +="       '' AS 'OBSERVACAO', '' AS 'EMISSAO', '' AS 'HIFEM', '' AS 'HORAS' " + CHR(13) + CHR(10)
//cQuery +="  FROM "+RetSqlName("SB1")+" SB1 "
//cQuery +="       INNER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON B2_FILIAL = '010108' " + CHR(13) + CHR(10)
//cQuery +="                                    AND B1_COD = B2_COD AND SB2.D_E_L_E_T_ ='' AND B2_LOCAL = 'A3' " + CHR(13) + CHR(10)
//cQuery += "WHERE SB1.D_E_L_E_T_ ='' AND B1_FILIAL ='"+xFilial("SB1")+"' " + CHR(13) + CHR(10)
//cQuery +="   AND B2_LOCALIZ <>'' AND B1_TIPO = 'PA' AND LEN(B1_COD) = '12' " + CHR(13) + CHR(10) 
//cQuery +="   AND B1_COD BETWEEN 'BT 010500701' AND B1_COD = 'BM 000110301'  " + CHR(13) + CHR(10)
//cQuery +="GROUP BY B1_COD, B1_DESC, B2_LOCALIZ, B2_LOCAL "  + CHR(13) + CHR(10)                         
//cQuery +="ORDER BY B2_LOCALIZ" + CHR(13) + CHR(10)        

IF Select("TEMP") <> 0
	DbSelectArea("TEMP")
	DbCloseArea()
ENDIF

TCQuery cQuery New Alias "TEMP"

While !TEMP->(EoF())
	cRet   := AllTrim(TEMP->PRODUTO)
	TEMP->(DbSkip())
EndDo

if empty(cRet)
	MsgAlert('Produto n„o Localizado', 'AtenÁ„o')
endif

Return(cRet)
  Jose 28/03/2025 */

/*/{Protheus.doc} PCP037_03
Loop com a Qtd e Tipo de Etiquetas a ser impressa
@type function
@author neliedercorneta
@since 23/12/2021
@param nTipo, numeric, Etiqueta Selecionada
/*/

/*    Jose 28/03/2025
Static Function PCP037_03(nTipo)

	local n      := 1
	local i      := 1
	local linhas := len(aBrowse)
	local qtd

	// valida se array pois dados //
	if len(aBrowse) < 1 .OR. (empty(aBrowse[1][1]))
		MsgInfo( 'Necess·rio Consultar uma OP ou Lote' , 'Etiquetas Produtos' )
		Return()
	Endif

	if ValidPort(cLPT) 
	    MsgInfo("Impressora Zebra (Etiqueta) nao esta pronta, Verifique a  Porta selecionada !")
		Return()
	Endi

	// Loop nas linhas do Array /
	For n := 1 to linhas

		// qtd de etiquetas a ser impressa //
		qtd          := Ceiling(val(aBrowse[n][3]))
		
		// soma qtd adicional de etiquetas //
		if AllTrim(aBrowse[n][1]) == "**IDENTIF DE VOLUME**"
			qtdReal      := qtd + cQtde2
		Else
			qtdReal      := qtd + cQtde1

		Endif

		///‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
		//	# exceÁ„o para etiquetas duplas e triplas #
		//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ/
		//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	    //	# Impress„o de Etiquetas 44x15mm (2 etiquetas por linha) #
		//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ//
		if nTipo == 3
		 qtdReal      := Ceiling(qtdReal/2)
		Endif	

		//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
		//# Impress„o de Etiquetas 26x15mm(xarope) (3 etiquetas por linha) #
		//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ//
		if nTipo == 2
		 qtdReal      := Ceiling(qtdReal/3)
		Endif	

		// loop na qtd de etiquetas a ser impressa //
		For i        := 1 to qtdReal

			Do Case
			Case nTipo == 1

				//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
				//# Impress„o de Etiquetas Zembras #
				//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ//
				if AllTrim(aBrowse[n][1]) == "**IDENTIF DE VOLUME**"
					PCP037_05(n,i)
				else
					PCP037_04(n,i)
				Endif

			Case nTipo == 2
				//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
				//# Impress„o de Etiquetas 26x15mm(xarope) #
				//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ//
				if AllTrim(aBrowse[n][1]) <> "**IDENTIF DE VOLUME**"
					PCP037_11(n,i)
				Endif

			Case nTipo == 3

				//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
				//# Impress„o de Etiquetas 44x15mm #
				ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ//
				PCP037_06(n,i)

			Case nTipo == 4
				//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
				//# Impress„o de Etiquetas 75x35mm #
				//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ//
				if AllTrim(aBrowse[n][1]) == "**IDENTIF DE VOLUME**"
					PCP037_07(n,i)
				else
					PCP037_08(n,i)
				Endif
			Case nTipo == 5

				//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
				//# Impress„o de Etiquetas 100x69mm #
				//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ//
				if AllTrim(aBrowse[n][1]) == "**IDENTIF DE VOLUME**"
					PCP037_09(n,i)
				else
					PCP037_10(n,i)
				Endif

			Case nTipo == 6
				//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
				//# Impress„o de Etiquetas Novo modelo 100x50mm #
				//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ//
				if AllTrim(aBrowse[n][1]) == "**IDENTIF DE VOLUME**"
					PCP037_05(n,i)
				else
					PCP037_13(n,i)	
				EndIf	

			Case nTipo == 7
				//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
				//# Impress„o de Etiquetas Tambor 100x200mm #
				//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ//
				if AllTrim(aBrowse[n][1]) <> "**IDENTIF DE VOLUME**"
					PCP037_14(n,i)
				EndIf
				
			EndCase
		NEXT
	NEXT

if !empty(cOP)
	oOP:SetFocus()
else
	oLote:SetFocus()	
Endif

cOP := space(13)
cLote := space(6)
cCont := space(3)
aBrowse  := {{ '' , '' , '' }}
oBrowse:SetArray(aBrowse)
oBrowse:bLine   := {||{ aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAT,03], }}
oBrowse:Refresh()


Return
    jose 28/03/2025 */

/*/{Protheus.doc} PCP037_04
Etiqueta Zebra de Produto
@type function
@author neliedercorneta 
@since 23/12/2021
@param linha, logical, linha
@param qtd, variant, qtd de produtos
/*/
/*     Jose 28/03/2025
Static Function PCP037_04(linha,qtd)
	Local cModelo 	:= "ZEBRA"

	Local Prod,ProdTxt,Cod,Unid,CodBar
	Local Validade,Prevf,PrazoVali,Dias,cLote
	Local DtVenc,cEmb
	Local Volume,UMEMB

	Local Catalis,RelCat1
	Local B1_CODGTIN

	Cod        := AllTrim(aBrowse[linha][2])
	
	
	  
	//	Quando B1_DESCLIN for diferente de branco pegar B1_DESCLIN
    
	
	if !empty(AllTrim(aBrowse[linha][21]))
		ProdTxt    := AllTrim(aBrowse[linha][21])
	else
		ProdTxt    := AllTrim(aBrowse[linha][4])
	endif

	
	B1_CODGTIN := aBrowse[linha][23]

	
	Unid       := SUBSTR(aBrowse[linha][5],1,2)
	Unid       := AllTrim(Unid)
	Unid       := StrZero(val(Unid),2)
	Validade   := aBrowse[linha][6]
	Prevf      := AllTrim(aBrowse[linha][7])
	cLote      := AllTrim(aBrowse[linha][8])
	CodBar     := AllTrim(aBrowse[linha][9])
	PrazoVali  := aBrowse[linha][10]
	Prod       := AllTrim(aBrowse[linha][11])

	cXidvol    := AllTrim(aBrowse[linha][12])
	cXidvol    := StrZero(val(cXidvol),4)
	Volume     := CValToChar(aBrowse[linha][13])

	// trata produtos com volume menor que 1 transformando em ml //
	if val(Volume) < 1
		UMEMB  := TrtUnimed(Alltrim(aBrowse[linha][14]),val(volume))
		Volume := CValToChar (val(Volume) * 1000)
	else
		//UMEMB 	   := CValToChar(aBrowse[linha][14])
		UMEMB  := TrtUnimed(Alltrim(aBrowse[linha][14]),val(volume))
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

	// calcula vencimento do produto //
	IF(PrazoVali > 0)
		Dias := (PrazoVali * 30)
		DtVenc := DaySum(STOD(Prevf), Dias  )
	else
		Dias := (Validade * 30)
		DtVenc := DaySum(STOD(Prevf), Dias  )
	Endif

	// alteraÁ„o solicitada por Sabrina via chamado 026547 23/06/2022 //
	
	// Chamado 026762  solicitado cancelar alterar demanda do chamado 02654 19/10/2022 //
    if !empty(AllTrim(aBrowse[linha][22]))
		ProdTxt    := AllTrim(aBrowse[linha][22])
	endif


	// chamado 026762 (Sabrina) //
	// Chamado 026762  solicitado cancelar alterar demanda do chamado 02654 19/10/2022 
	//If SUBSTR(Cod,1,10) == "VN 0900030"
	//	Prod	   := "VERNIZ COPAL BRILHANTE"	
	//	ProdTxt    := "VERNIZ INCOLOR INTERIOR"
	//EndIf

	// identifica embalagem //
	If len(Alltrim(Cod)) == 12

		//   Tratativa para produtos com inicio BM
		//   Exemplo BM 00.23.157-01   	
		//   Neste caso, n„o utilizar o codigo da embalagem e sim 157
	 
		if substr(Cod,1,2) == "BM"
			cEmb          := substr(Cod,8,3)
		else
			cEmb          := substr(Cod,11,2)
		endif	
	Endif

	// inicio de impress„o das etiquetas //
	MSCBPRINTER(cModelo, cLPT,,12,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBLOADGRF("SIGA.GRF")
	MSCBBEGIN(1)

	MSCBSAY(05,02   ,SUBSTR(Prod,1,30), "N", "0", "025,025") // negrito

	// 21/03/2023 - Nelieder
	// trativa chamado R542
	//SolicitaÁ„o de Desenvolvimento de Etiqueta linha BM 00 AUMENTO DA INFORMA«√O 163 NO CANTO DA ETIQUETA
	if (Substr(Cod,1,5) == "BM 00") 
		//MSCBSAY(65,02   ,cEmb, "N", "0", GetMV( "ZP_PAR0111" ) ) // negrito ZP_PAR0111
		MSCBSAY(GetMV( "ZP_PAR0113" ),02   ,cEmb, "N", "0", GetMV( "ZP_PAR0111" ) ) // negrito ZP_PAR0111
	else
		//MSCBSAY(68,02   ,cEmb, "N", "0", GetMV( "ZP_PAR0112" ) ) // negrito ZP_PAR0112 "025,025"
		MSCBSAY(GetMV( "ZP_PAR0114" ),02   ,cEmb, "N", "0", GetMV( "ZP_PAR0112" ) ) // negrito ZP_PAR0112 "025,025"
	EndIf
		
	MSCBSAY(05,06   ,ProdTxt, "N", "0", "025,025") // negrito
		
	MSCBSAY(05,11,"COD:", "N", "0", "025,022") // negrito
	Cod = TRANSFORM(Cod, "@R XX 99.99.999-XX")
	MSCBSAY(11,11,Cod, "N", "0", "025,022") 
	
	MSCBSAY(05,15,"LOTE:", "N", "0", "020,022") // negrito
	MSCBSAY(12,15,cLote, "N", "0", "020,022") 
		
	//Alterado por Nelieder em 02/08/2023 chamado R2104
	//MSCBSAY(21,15,"Val.: "+CValToChar(DtVenc), "N", "0", "020,022") // negrito
	MSCBSAY(21,15,"Val.: "+R2104(DtVenc), "N", "0", "020,022") // negrito
	
	//If _ZPPAR0214 // .T. Habilita padr„o WMS
	
	//	nQtd := Replace(Transform( Val("1"), "@E 9999"), ",", "") 
	//	nQtd := AllTrim(nQtd)
	//	nQtd := (StrZero(Val(nQtd),6))

	//	//sK := "02"+StrZero(Val(B1_CODGTIN),14)

	//	If len(AllTrim(B1_CODGTIN)) <> 13
	//		MsgAlert("Codigo Gtin invalido.."+B1_CODGTIN)
	//		return()
	//	Endif
	//	sK := "020"+Alltrim(B1_CODGTIN)
    //	QTD := "9537"+nQtd+""
    //	cLote := "10"+cLote+""
    //	cValid := "12"+Substr(DToS(DtVenc),3,6)+""
		
    //	cConteudo := sK+QTD+cLote+cValid

	//EndIf	

	//If _ZPPAR0214 // .T. Habilita padr„o WMS
	//	MSCBLineH(00,10,045,3, 'B' )
	//	if Empty(Catalis)
	//		MSCBSAY(05,18,"CONTEUDO "+Volume+" "+UMEMB, "N", "0","068,068") // negrito

	//		MSCBWRITE("^FT380,150^BQN,4,4")
	//		MSCBWRITE("^FH\^FDLA,"+cConteudo+"^FS")
	//	else
	//		MSCBSAY(05,21,"CONTEUDO "+Volume+" "+UMEMB, "N", "0","030,030") // negrito

	//		MSCBWRITE("^FT380,150^BQN,4,4")
	//		MSCBWRITE("^FH\^FDLA,"+cConteudo+"^FS")

	//		Catalis = TRANSFORM(Catalis, "@R XX 99.99.999-XX")
	//		MSCBSAY(35,22,"CAT: "+Catalis+" ("+RelCat1+")", "N", "0","025,025") // negrito

	//	Endif	
	
	//else
		MSCBLineH(00,10,190,3,'B')
		if Empty(Catalis)
			MSCBSAY(05,18,"CONTEUDO "+Volume+" "+UMEMB, "N", "0","068,068") // negrito
			MSCBSAYBAR(48,11,CodBar,"N","MB04",5, .F., .T., .F., ,02,02, .F., .F., "1", .T.)
		else
			MSCBSAY(05,21,"CONTEUDO "+Volume+" "+UMEMB, "N", "0","030,030") // negrito
			Catalis = TRANSFORM(Catalis, "@R XX 99.99.999-XX")
			MSCBSAY(35,22,"CAT: "+Catalis+" ("+RelCat1+")", "N", "0","025,025") // negrito
			MSCBSAYBAR(48,11,CodBar,"N","MB04",7, .F., .T., .F., ,02,02, .F., .F., "1", .T.)
		Endif	

	//Endif
	

	MSCBEND()
	MSCBCLOSEPRINTER()


Return()
   Jose 28/03/2025 */


/*/{Protheus.doc} PCP037_05
Etiqueta Zebra de Volume
@type function
@author neliedercorneta
@since 23/12/2021
@param linha, logical, linha
@param qtd, variant, qtd produtos
/*/

/*    JOse 28/03/2025

Static Function PCP037_05(linha,qtd)

Local cModelo := "ZEBRA"
Local Prod,ProdTxt,Cod,Unid,CodBar
Local Validade,Prevf,PrazoVali,Dias,cLote
Local DtVenc,cEmb,UMEMB
Local cEmb_Bar
Local REG,C2_NUM,C2_ITEM,C2_SEQUEN
Local B1_CODGTIN
Local cConteudo
Local nQtd


	Cod           := AllTrim(aBrowse[linha][2])

 
	//	Quando B1_DESCLIN for diferente de branco pegar B1_DESCLIN
 
	
	if !empty(AllTrim(aBrowse[linha][21]))
		ProdTxt    := AllTrim(aBrowse[linha][21])
	else
		ProdTxt    := AllTrim(aBrowse[linha][4])
	endif


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

	NcXidvol	  := StrZero( (val(cXidvol))+qtd , 4)	

	REG		      := aBrowse[linha][17]
	C2_NUM		  := aBrowse[linha][18]
	C2_ITEM		  := aBrowse[linha][19]
	C2_SEQUEN	  := aBrowse[linha][20]


	B1_CODGTIN	  := aBrowse[linha][23]



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

	// chamado 026762 (Sabrina) //
	//If SUBSTR(Alltrim(Cod),1,10) == "VN 0900030"
	//	Prod	   := "VERNIZ COPAL BRILHANTE"	
	//	ProdTxt    := "VERNIZ INCOLOR INTERIOR"
	//EndIf


	// identifica embalagem //
	If len(Alltrim(Cod)) == 12
		 
		//   Tratativa para produtos com inicio BM
		//   Exemplo BM 00.23.157-01   	
		//   Neste caso, n„o utilizar o codigo da embalagem e sim 157

		if substr(Cod,1,2) == "BM"
			cEmb          := substr(Cod,8,3)
			cEmb_Bar	  := substr(Cod,11,2)
		else
			cEmb          := substr(Cod,11,2)
			cEmb_Bar	  := substr(Cod,11,2)
		endif	

	Endif

	CodBar        := cLote+cEmb_Bar+Unid+NcXidvol
	UMEMB         := UniMed(CodBar,Cod)
	nQtd		  := Substr(UMEMB,1,2)	

	MSCBPRINTER(cModelo, cLPT,,12,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBLOADGRF("SIGA.GRF")
	MSCBBEGIN(1)

	MSCBSAY(05,02 ,Prod, "N", "0", "025,025") // negrito

	//Alterado por Nelieder em 02/08/2023 chamado R2104
	//MSCBSAY(05,05 ,"**Val.: "+ CValToChar(DtVenc)+"** IDENTIF VOL *", "N", "0", "025,025") // negrito
	MSCBSAY(05,05 ,"**Val.: "+ R2104(DtVenc)+"** IDENTIF VOL *", "N", "0", "025,025") // negrito
	
	
	If _ZPPAR0214 // .T. Habilita padr„o WMS
		MSCBLineH(00,10,050,3, 'B' )
	else
		MSCBLineH(00,10,190,3, 'B' )
	EndIf				
	
	MSCBSAY(05,11,"COD:", "N", "0", "026,026") // negrito
	Cod = TRANSFORM(Cod, "@R XX 99.99.999-XX")
	MSCBSAY(12,11,Cod, "N", "0", "026,026") // negrito
	
	
	If _ZPPAR0214 // .T. Habilita padr„o WMS
		MSCBSAY(40,11, AllTrim(UMEMB), "N", "0", "026,026") // negrito		
		//MSCBSAY(05,15, AllTrim(UMEMB), "N", "0", "026,026") // negrito
		//MSCBSAY(05,19, "Lote: "+cLote, "N", "0", "026,026") // negrito
	else
		MSCBSAY(57,11, AllTrim(UMEMB), "N", "0", "026,026") // negrito		
	EndIf		

	If _ZPPAR0214 // .T. Habilita padr„o WMS
		//B1_CODGTIN:="07893866340495"
		
		//nQtd := Replace(Transform( Val("1"), "@E 9999"), ",", "") 
		nQtd := Replace(Transform( Val(nQtd), "@E 9999"), ",", "") 
		nQtd := AllTrim(nQtd)
		nQtd := (StrZero(Val(nQtd),6))

		//sK := "02"+StrZero(Val(B1_CODGTIN),14)
		If len(AllTrim(B1_CODGTIN))<> 13
			MsgAlert("Codigo Gtin invalido.."+B1_CODGTIN)
			return()
		Endif
		sK := "021"+Alltrim(B1_CODGTIN)
    	QTD := "9537"+nQtd+""
    	cLote := "10"+cLote+""
    	cValid := "12"+Substr(DToS(DtVenc),3,6)+""
		
    	cConteudo := sK+QTD+cLote+cValid

	EndIf	

	
    If (IsDigit(SubStr(cEmb_Bar,2,1))) .AND. (IsDigit(SubStr(cEmb_Bar,1,1)))
	    // Emabalagem apenas com numeros
		If _ZPPAR0214 // .T. Habilita padr„o WMS
			//MSCBWRITE("^FT415,215^BQN,6,6")
			MSCBWRITE("^FT470,145^BQN,4,4")
			MSCBWRITE("^FH\^FDLA,"+cConteudo+"^FS")
	      //MSCBSAYBAR(25, 16,CodBar,"N","MB01",5, .F., .F., .F., ,3,02, .F., .F., "1", .T.) // Jose 06/03/2025
			MSCBSAYBAR(06, 15,CodBar,"N","MB07",6, .F., .T., .F., ,2,01, .F., .F., "1", .T.) // Jose 06/03/2025
		else	
			MSCBSAYBAR(18, 15,CodBar,"N","MB01",6, .F., .T., .F., ,3,02, .F., .F., "1", .T.)
		EndIf
		
   	Else
		// Embalagem com numero e letras
		If _ZPPAR0214 // .T. Habilita padr„o WMS
			MSCBWRITE("^FT470,145^BQN,4,4")
			MSCBWRITE("^FH\^FDLA,"+cConteudo+"^FS")
			MSCBSAYBAR(06, 15,CodBar,"N","MB07",6, .F., .T., .F., ,2,01, .F., .F., "1", .T.)
		else
			MSCBSAYBAR(14, 15,CodBar,"N","MB07",9, .F., .T., .F., ,2,01, .F., .F., "1", .T.)
		EndIf	
	EndIf
	
	MSCBEND()
	MSCBCLOSEPRINTER()

	UPD_XVOL(NcXidvol,REG,C2_NUM,C2_ITEM,C2_SEQUEN,cLote)


Return()
   Jose 28/03/2025 */


/*/{Protheus.doc} PCP037_06
Etiqueta 44x15 mm
@type function
@author neliedercorneta
@since 23/12/2021
@param linha, logical, linha
@param qtd, variant, qtd de produtos
/*/

/*   Jose 28/03/2025

Static Function PCP037_06(linha,qtd)
	
	Local cModelo := "ZEBRA"
	Local Prod,ProdTxt,Cod,Unid,CodBar
	Local Validade,Prevf,PrazoVali,Dias,cLote
	Local DtVenc,cEmb
	Local Volume,UMEMB
	Local cColuna := 0

	Cod           := AllTrim(aBrowse[linha][2])
	

	//	Quando B1_DESCLIN for diferente de branco pegar B1_DESCLIN
	
	if !empty(AllTrim(aBrowse[linha][21]))
		ProdTxt    := AllTrim(aBrowse[linha][21])
	else
		ProdTxt    := AllTrim(aBrowse[linha][4])
	endif

	
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
	//UMEMB         := CValToChar(aBrowse[linha][14])

	// trata produtos com volume menor que 1 transformando em ml //
	if val(Volume) < 1

		UMEMB  := TrtUnimed(Alltrim(aBrowse[linha][14]),val(volume))
		Volume := CValToChar (val(Volume) * 1000)
	else
		//UMEMB 	   := CValToChar(aBrowse[linha][14])
		UMEMB  := TrtUnimed(Alltrim(aBrowse[linha][14]),val(volume))
	endif
	
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


	// identifica embalagem //
	If len(Alltrim(Cod)) == 12
		cEmb          := substr(Cod,11,2)
	Endif

	// identifica etiqueta par //
	//if mod(qtd,2)==0
	//	cColuna := 10
	//else
	//	cColuna := 0
	//endi

	MSCBPRINTER(cModelo, cLPT,,12,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBLOADGRF("SIGA.GRF")
	MSCBBEGIN(1)

	If len(Prod) >= 25
		MSCBSAY(02+cColuna,02,Prod,"N","0","018,018")
	else
		MSCBSAY(02+cColuna,02,Prod,"N","0","022,022")
	EndIf	
	
	Cod = TRANSFORM(Cod, "@R XX 99.99.999-XX")
	MSCBSAY(02+cColuna,05,Cod, "N", "0", "022,022")
	
	MSCBSAY(02+cColuna,08,Volume+UMEMB+" Lote: "+cLote, "N", "0","022,022") // negrito
	
	//Alterado por Nelieder em 02/08/2023 chamado R2104
	//MSCBSAY(02+cColuna,11,"Val.: "+CValToChar(DtVenc), "N", "0", "022,022") // negrito
	MSCBSAY(02+cColuna,11,"Val.: "+R2104(DtVenc), "N", "0", "022,022") // negrito
	
	if AllTrim(aBrowse[linha][1]) <> "**IDENTIF DE VOLUME**"
		MSCBSAYBAR(25+cColuna,5,CodBar,"N","MB04",7, .F., .T., .F., ,1,1, .F., .F., "1", .T.)
	Endif


	// impress„o da segunda coluna //

	cColuna := 49

	If len(Prod) >= 25
		MSCBSAY(02+cColuna,02,Prod,"N","0","018,018")
	else
		MSCBSAY(02+cColuna,02,Prod,"N","0","022,022")
	Endif
	MSCBSAY(02+cColuna,05,Cod, "N", "0", "022,022")
	
	MSCBSAY(02+cColuna,08,Volume+UMEMB+" Lote: "+cLote, "N", "0","022,022") // negrito
	
	//Alterado por Nelieder em 02/08/2023 chamado R2104
	//MSCBSAY(02+cColuna,11,"Val.: "+CValToChar(DtVenc), "N", "0", "022,022") // negrito
	MSCBSAY(02+cColuna,11,"Val.: "+R2104(DtVenc), "N", "0", "022,022") // negrito
	
	//if AllTrim(aBrowse[linha][1]) <> "**IDENTIF DE VOLUME**"
		MSCBSAYBAR(25+cColuna,5,CodBar,"N","MB04",7, .F., .T., .F., ,1,1, .F., .F., "1", .T.)
	//Endif


	MSCBEND()
	MSCBCLOSEPRINTER()


Return()

    Jose  28/03/2025 */


/*/{Protheus.doc} PCP037_07
Etiqueta 75x35mm volume
@type function
@author neliedercorneta
@since 23/12/2021
@param linha, logical, linha
@param qtd, variant, qtd produtos
/*/

/*   JosÈ   28/03/2025

Static Function PCP037_07(linha,qtd)

Local cModelo := "ZEBRA"
Local Prod,ProdTxt,Cod,Unid,CodBar
Local Validade,Prevf,PrazoVali,Dias,cLote
Local DtVenc,cEmb,UMEMB
Local REG,C2_NUM,C2_ITEM,C2_SEQUEN


	Cod           := AllTrim(aBrowse[linha][2])
	

	//	Quando B1_DESCLIN for diferente de branco pegar B1_DESCLIN
	
	if !empty(AllTrim(aBrowse[linha][21]))
		ProdTxt    := AllTrim(aBrowse[linha][21])
	else
		ProdTxt    := AllTrim(aBrowse[linha][4])
	endif

	
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

	NcXidvol	  := StrZero( (val(cXidvol))+qtd , 4)	

	REG		      := aBrowse[linha][17]
	C2_NUM		  := aBrowse[linha][18]
	C2_ITEM		  := aBrowse[linha][19]
	C2_SEQUEN	  := aBrowse[linha][20]

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

//identifica embalagem //

	If len(Alltrim(Cod)) == 12
		cEmb          := substr(Cod,11,2)
	Endif

	CodBar        := cLote+cEmb+Unid+NcXidvol
	UMEMB   	  := UniMed(CodBar,Cod)


	MSCBPRINTER(cModelo, cLPT,,12,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBLOADGRF("SIGA.GRF")
	MSCBBEGIN(1)

	MSCBSAY(03,02 ,Prod, "N", "0", "025,025") // negrito
	MSCBSAY(65,02 ,cEmb, "N", "0", "025,025") // negrito
	
	//Alterado por Nelieder em 02/08/2023 chamado R2104
	//MSCBSAY(03,05 ,"**Val.: "+ CValToChar(DtVenc)+"** IDENTIF VOL *", "N", "0", "025,030") // negrito
	MSCBSAY(03,05 ,"**Val.: "+ R2104(DtVenc)+"** IDENTIF VOL *", "N", "0", "025,030") // negrito
	
	MSCBLineH(00,10,190,3, 'B' )
	
	MSCBSAY(03,11,"COD:", "N", "0", "025,025") // negrito

	Cod = TRANSFORM(Cod, "@R XX 99.99.999-XX")

	MSCBSAY(10,11,Cod, "N", "0", "025,025") // negrito
	MSCBSAY(57,11, AllTrim(UMEMB), "N", "0", "026,026") // negrito

	
	MSCBSAYBAR(10,18,CodBar,"N","MB01",8, .F., .T., .F., ,3,3, .F., .F., "1", .T.)

	MSCBEND()
	MSCBCLOSEPRINTER()

	UPD_XVOL(NcXidvol,REG,C2_NUM,C2_ITEM,C2_SEQUEN,cLote)


Return()
   JosÈ 28/03/2025 */


/*/{Protheus.doc} PCP037_08
Etiqueta Produto 75x35mm
@type function
@author neliedercorneta
@since 23/12/2021
@param linha, logical, linha
@param qtd, variant, qtd de produtos
/*/

/*  Jose 28/03/2025

Static Function PCP037_08(linha,qtd)
	
	Local cModelo 	:= "ZEBRA"
	Local Prod,ProdTxt,Cod,Unid,CodBar
	Local Validade,Prevf,PrazoVali,Dias,cLote
	Local DtVenc,cEmb
	Local Volume,UMEMB

	Local Catalis,RelCat1
	
	
	Cod        := AllTrim(aBrowse[linha][2])
	 
	//	Quando B1_DESCLIN for diferente de branco pegar B1_DESCLIN
 
	if !empty(AllTrim(aBrowse[linha][21]))
		ProdTxt    := AllTrim(aBrowse[linha][21])
	else
		ProdTxt    := AllTrim(aBrowse[linha][4])
	endif


	Unid       := SUBSTR(aBrowse[linha][5],1,2)
	Unid       := AllTrim(Unid)
	Unid       := StrZero(val(Unid),2)
	Validade   := aBrowse[linha][6]
	Prevf      := AllTrim(aBrowse[linha][7])
	cLote      := AllTrim(aBrowse[linha][8])
	CodBar     := AllTrim(aBrowse[linha][9])
	PrazoVali  := aBrowse[linha][10]
	Prod       := AllTrim(aBrowse[linha][11])

	cXidvol    := AllTrim(aBrowse[linha][12])
	cXidvol    := StrZero(val(cXidvol),4)
	Volume     := CValToChar(aBrowse[linha][13])
	UMEMB 	   := CValToChar(aBrowse[linha][14])

	Catalis	   := AllTrim(aBrowse[linha][15])	
	RelCat1    := AllTrim(aBrowse[linha][16])

	if val(Volume) < 1
		UMEMB  := TrtUnimed(Alltrim(aBrowse[linha][14]),val(volume))
		Volume := CValToChar (val(Volume) * 1000)
	else
		//UMEMB 	   := CValToChar(aBrowse[linha][14])
		UMEMB  := TrtUnimed(Alltrim(aBrowse[linha][14]),val(volume))
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


	// identifica embalagem //
	If len(Alltrim(Cod)) == 12
		cEmb := substr(Cod,11,2)
	Endif

	MSCBPRINTER(cModelo, cLPT,,12,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBLOADGRF("SIGA.GRF")
	MSCBBEGIN(1)

	MSCBSAY(03,02   ,Prod, "N", "0", "025,025") // negrito
	MSCBSAY(65,02   ,cEmb, "N", "0", "025,025") // negrito
	MSCBSAY(03,06   ,ProdTxt, "N", "0", "025,025") // negrito
	
	MSCBLineH(00,10,190,3,'B')
	
	MSCBSAY(03,11,"COD:", "N", "0", "025,022") // negrito
	Cod = TRANSFORM(Cod, "@R XX 99.99.999-XX")
	MSCBSAY(09,11,Cod, "N", "0", "025,022") 
	
	MSCBSAY(03,15,"LOTE:", "N", "0", "020,022") // negrito
	MSCBSAY(10,15,cLote, "N", "0", "020,022") 

	//Alterado por Nelieder em 02/08/2023 chamado R2104
	//MSCBSAY(19,15,"Val.: "+CValToChar(DtVenc), "N", "0", "020,022") // negrito
	MSCBSAY(19,15,"Val.: "+R2104(DtVenc), "N", "0", "020,022") // negrito
	
	
	if Empty(Catalis)
		MSCBSAY(03,23,"CONTEUDO "+Volume+" "+UMEMB, "N", "0","068,068") // negrito
		MSCBSAYBAR(45,11,CodBar,"N","MB04",6, .F., .T., .F., ,03,03, .F., .F., "1", .T.)
		MSCBSAY(45,20,cObs, "N", "0","022,022") // negrito
	else
		MSCBSAY(03,23,"CONTEUDO "+Volume+" "+UMEMB, "N", "0","068,068") // negrito
		Catalis = TRANSFORM(Catalis, "@R XX 99.99.999-XX")
		MSCBSAY(03,19,"CAT: "+Catalis+" ("+RelCat1+")", "N", "0","022,022") // negrito
		MSCBSAY(45,20,cObs, "N", "0","022,022") // negrito
		MSCBSAYBAR(45,11,CodBar,"N","MB04",6, .F., .T., .F., ,02,02, .F., .F., "1", .T.)
	Endif	

	

	MSCBEND()
	MSCBCLOSEPRINTER()


Return()

    Jose 28/03/2025 */


/*/{Protheus.doc} PCP037_09
Etiqueta 100x70mm de Volume
@type function
@author neliedercorneta
@since 23/12/2021
@param linha, logical, linha
@param qtd, variant, qtd produtos
/*/
Static Function PCP037_09(linha,qtd)

Local cModelo := "ZEBRA"
//Local Cod    Jose 28/04/2025
//Local Prod   Jose 28/04/2025

Local Descric // Jose 28/04/2025
Local Localiz

cQuery :=" SELECT BE_LOCALIZ, BE_DESCRIC "      + CHR(13) + CHR(10) 
cQuery +="   FROM "+RetSqlName("SBE")+" SBE "   + CHR(13) + CHR(10) 
cQuery +="  WHERE SBE.D_E_L_E_T_= '' "          + CHR(13) + CHR(10) 
cQuery +="   AND SBE.BE_LOCAL = 'A3'  "         + CHR(13) + CHR(10) 
If (MV_PAR01 <> ' ' .AND.  MV_PAR01 <> '')  
// cQuery +="   AND (SUBSTRING(SBE.BE_LOCALIZ,1,2) = ('"+MV_PAR01+"') ) " + CHR(13) + CHR(10)  // Jose 29/04/2025 Aterado por SolicitaÁ„o do Sr. Roberto via Teams
   cQuery +="   AND (SUBSTRING(SBE.BE_DESCRIC,3,2) = ('"+MV_PAR01+"') ) " + CHR(13) + CHR(10)  // Jose 29/04/2025 Aterado por SolicitaÁ„o do Sr. Roberto via Teams
Endif
If (MV_PAR02 <> ' ' .AND.  MV_PAR02 <> '')   
// cQuery +="   AND (SUBSTRING(SBE.BE_LOCALIZ,3,3) = ('"+MV_PAR02+"') ) " + CHR(13) + CHR(10)  // Jose 29/04/2025 Aterado por SolicitaÁ„o do Sr. Roberto via Teams
   cQuery +="   AND (SUBSTRING(SBE.BE_DESCRIC,8,3) = ('"+MV_PAR02+"') ) " + CHR(13) + CHR(10)  // Jose 29/04/2025 Aterado por SolicitaÁ„o do Sr. Roberto via Teams

Endif
If (MV_PAR03 <> ' ' .AND.  MV_PAR03<> '')   
// cQuery +="   AND (SUBSTRING(SBE.BE_LOCALIZ,6,1) = ('"+MV_PAR03+"') ) " + CHR(13) + CHR(10)  // Jose 29/04/2025 Aterado por SolicitaÁ„o do Sr. Roberto via Teams 
   cQuery +="   AND (SUBSTRING(SBE.BE_DESCRIC,14,1) = ('"+MV_PAR03+"') ) " + CHR(13) + CHR(10)  // Jose 29/04/2025 Aterado por SolicitaÁ„o do Sr. Roberto via Teams  
Endif
cQuery +="GROUP BY SBE.BE_LOCALIZ, SBE.BE_DESCRIC   "  + CHR(13) + CHR(10)
cQuery +="ORDER BY SBE.BE_DESCRIC ASC "                + CHR(13) + CHR(10) 

/*      jOSE 28/04/2025 ------------------------------------------------------------    
cQuery :="SELECT ZZL_PRODUT AS 'PRODUTO', B1_DESC AS 'DESCRICAO', B2_LOCAL AS 'ESTOQUE', "                + CHR(13) + CHR(10)  // B2_LOCALIZ AS 'ESTOQUE', "  
cQuery +="       ZZL_LOCALI AS 'PROVISORIO'  "                                                            + CHR(13) + CHR(10) // ZZL_LOCALI AS 'PROVISORIO','' AS 'OBSERVACAO', '' AS 'EMISSAO', '' AS 'HIFEM', '' AS 'HORAS'
cQuery +="  FROM "+RetSqlName("ZZL")+" ZZL "                                                              + CHR(13) + CHR(10)
cQuery +="       LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON SB1.B1_FILIAL = '010101' "    + CHR(13) + CHR(10)
cQuery +="                                                              AND SB1.B1_COD = ZZL.ZZL_PRODUT " + CHR(13) + CHR(10)
cQuery +="                                                              AND SB1.D_E_L_E_T_ = '' "         + CHR(13) + CHR(10)
cQuery +="       INNER      JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON SB2.B2_FILIAL = '010108' "    + CHR(13) + CHR(10)
cQuery +="                                                              AND SB2.B2_COD = ZZL.ZZL_PRODUT " + CHR(13) + CHR(10)
cQuery +="                                                              AND SB2.D_E_L_E_T_ = '' "         + CHR(13) + CHR(10)
cQuery +="                                                              AND SB2.B2_LOCAL = 'A3'  "        + CHR(13) + CHR(10) 
cQuery +=" WHERE (ZZL_FILIAL= '010101') AND (ZZL.D_E_L_E_T_='') AND LEN(B1_COD) = '12' "                  + CHR(13) + CHR(10)
cQuery +="   AND (B1_COD BETWEEN  ('"+MV_PAR01+"') AND ('"+MV_PAR02+"')) "                                + CHR(13) + CHR(10)
cQuery +="   AND ZZL_LOCALI <> '' "                                                                       + CHR(13) + CHR(10)
cQuery +="GROUP BY ZZL_PRODUT, B1_DESC, B2_LOCAL, ZZL_LOCALI "                                            + CHR(13) + CHR(10)
cQuery +="ORDER BY ZZL_LOCALI"                                                                            + CHR(13) + CHR(10)
/*------------------       AT… AQUI JOSE 28/04/2025 ----------------------------------------------------
/* -----------------------------------------------   jOSE 25/04/2025
cQuery :="SELECT B1_COD AS 'PRODUTO', B1_DESC AS 'DESCRICAO', B2_LOCAL AS 'ESTOQUE', B2_LOCALIZ AS 'PROVISORIO', " + CHR(13) + CHR(10)  
cQuery +="       '' AS 'OBSERVACAO', '' AS 'EMISSAO', '' AS 'HIFEM', '' AS 'HORAS' " + CHR(13) + CHR(10)
cQuery +="  FROM "+RetSqlName("SB1")+" SB1 "
cQuery +="       INNER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON B2_FILIAL = '010101' " + CHR(13) + CHR(10)
cQuery +="                                    AND B1_COD = B2_COD AND SB2.D_E_L_E_T_ ='' AND B2_LOCAL = '"+MV_PAR03+"' " + CHR(13) + CHR(10)
cQuery += "WHERE SB1.D_E_L_E_T_ ='' AND B1_FILIAL ='"+xFilial("SB1")+"' " + CHR(13) + CHR(10)
cQuery +="   AND B2_LOCALIZ <>'' AND B1_TIPO = 'PA' AND LEN(B1_COD) = '12' " + CHR(13) + CHR(10) // Jose 09/10/2023 jOSE 14/03/2025 AND SB2.B2_LOCAL = SB1.B1_LOCPAD
cQuery +="   AND (B1_COD BETWEEN  ('"+MV_PAR01+"') AND ('"+MV_PAR02+"'))  " + CHR(13) + CHR(10)
cQuery +="GROUP BY B1_COD, B1_DESC, B2_LOCALIZ, B2_LOCAL "  + CHR(13) + CHR(10)   // Jose 09/10/2023                       
cQuery +="ORDER BY B2_LOCALIZ ASC" + CHR(13) + CHR(10)   
---------------------------------------------     jOSE 25/04/2025 */

IF Select("QRYPRO") <> 0
	DbSelectArea("QRYPRO")
	DbCloseArea()
ENDIF
TCQuery cQuery New Alias "QRYPRO"

If (QRYPRO->(EoF()))
   Messagebox("EndereÁo N„o Existe "+MV_PAR01+MV_PAR02+MV_PAR03+"  !!!","AtenÁ„o...",48)	  		
   Return
EndIf

While !(QRYPRO->(EoF()))
//	Cod           := QRYPRO->PRODUTO
//	Prod          := QRYPRO->DESCRICAO
//	Localiz       := QRYPRO->PROVISORIO

    Localiz       := QRYPRO->BE_LOCALIZ // Jose 28/04/2025
	Descric       := QRYPRO->BE_DESCRIC // Jose 28/04/2025

	MSCBPRINTER(cModelo, cLPT,,12,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBLOADGRF("SIGA.GRF")
	MSCBBEGIN(1)

//	MSCBSAY(03,06 ,substr(Prod,1,30),"N", "0", "035,035") 
//  MSCBLineH(00,22,190,3, 'B' )
//  MSCBSAY(03,04,"COD:", "N", "0", "045,045")
//    Cod = TRANSFORM(Cod, "@R XX 99.99.999-XX")     jose 25/04/2025
//  MSCBSAY(04,04,Cod, "N", "0", "070,085")          jose 25/04/2025

/*---------------------------------------------------------------------------------------*/
//  JOSE 16/04/2025
//	MSCBSAYBAR(04, 40,Cod,"N","MB07",6, .F., .T., .F., ,2,01, .F., .F., "1", .T.)  Jose 25/04/2025
//  ATE AQUI 16/04/2025
/*---------------------------------------------------------------------------------------*/

//	MSCBSAY(03,30,"DESC:", "N", "0", "045,045") 
//    MSCBSAY(04,30,substr(Prod,1,50),"N", "0", "050,050")   Jose 25/04/2025

/*---------------------------------------------------------------------------------------*/
//  JOSE 16/04/2025

	MSCBSAYBAR(10, 40,Localiz,"N","MB07",20, .F., .T., .F., ,3,01, .F., .F., "1", .T.)
//  ATE AQUI 16/04/2025
/*---------------------------------------------------------------------------------------*/

//	MSCBSAY(03,50,"LOCAL:", "N", "0", "045,045")   Jose 25/04/205
//  MSCBSAY(10,05,substr(Localiz,1,50),"N", "0", "070,060") // Jose 25/04/2025

    MSCBSAY(10,05,"ARARAQUARA ", "N", "0", "060,050") 

    MSCBSAY(70,10,"Brasilux ", "N", "0", "060,050")   // Jose 28/04/2025
    MSCBSAY(80,17,"Tintas "  , "N", "0", "030,020")   // Jose 28/04/2025

	MSCBSAY(10,25,"Rua ", "N", "0", "060,050") 
    MSCBSAY(23,25,substr(Descric,03,02),"N", "0", "060,050") //substr(Descric,01,02)

	MSCBSAY(30,25,"; Coluna ", "N", "0", "060,050") 
    MSCBSAY(53,25,substr(Descric,08,03),"N", "0", "060,050") // substr(Descric,03,03)

	MSCBSAY(65,25,"; Andar ", "N", "0", "060,050") 
    MSCBSAY(85,25,substr(Descric,14,01),"N", "0", "060,050") // substr(Descric,06,03)

	MSCBEND()
	MSCBCLOSEPRINTER()

     QRYPRO->(DbSkip())
EndDo
   
Return()

/*/{Protheus.doc} PCP037_10
Etiqueta 100x69mm de Produto
@type function
@author neliedercorneta
@since 23/12/2021
@param linha, logical, linha
@param qtd, variant, qtd de produtos
/*/

/*   Jose 28/03/2025  

Static Function PCP037_10(linha,qtd)
	
	Local cModelo := "ZEBRA"
	Local Prod,ProdTxt,Cod,Unid,CodBar
	Local Validade,Prevf,PrazoVali,Dias,cLote
	Local DtVenc,cEmb
	Local Volume,UMEMB

	Local Catalis,RelCat1

	Local REG,C2_NUM,C2_ITEM,C2_SEQUEN

	If Empty(cCont)
		cCont := "1"
	EndIf
	
	
	Cod           := AllTrim(aBrowse[linha][2])
 
	///	Quando B1_DESCLIN for diferente de branco pegar B1_DESCLIN
 
	if !empty(AllTrim(aBrowse[linha][21]))
		ProdTxt    := AllTrim(aBrowse[linha][21])
	else
		ProdTxt    := AllTrim(aBrowse[linha][4])
	endif

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

	NcXidvol	  := StrZero( (val(cXidvol))+qtd , 4)	

	REG		      := aBrowse[linha][17]
	C2_NUM		  := aBrowse[linha][18]
	C2_ITEM		  := aBrowse[linha][19]
	C2_SEQUEN	  := aBrowse[linha][20]


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


	// identifica embalagem //
	If len(Alltrim(Cod)) == 12
		cEmb          := substr(Cod,11,2)
	Endif

	if val(Volume) < 1
		UMEMB  := TrtUnimed(Alltrim(aBrowse[linha][14]),val(volume))
		Volume := CValToChar (val(Volume) * 1000)
	else
		//UMEMB 	   := CValToChar(aBrowse[linha][14])
		UMEMB  := TrtUnimed(Alltrim(aBrowse[linha][14]),val(volume))
	endif

	CodBar        := cLote+cEmb+Unid+NcXidvol

	MSCBPRINTER(cModelo, cLPT,,12,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBLOADGRF("SIGA.GRF")
	MSCBBEGIN(1)

	MSCBSAY(04,05 ,substr(Prod,1,30),"N", "0", "045,045") // negrito
	MSCBSAY(90,05 ,cEmb, "N", "0", "045,055") // negrito
	MSCBSAY(04,12 ,ProdTxt, "N", "0", "045,055") // negrito

	MSCBLineH(00,17,190,3, 'B' )
	MSCBSAY(04,20.5,"COD:", "N", "0", "035,035") // negrito
	Cod = TRANSFORM(Cod, "@R XX 99.99.999-XX")
	MSCBSAY(15,20,Cod, "N", "0", "050,060") // negrito

	MSCBSAY(80,19,"Lote:", "N", "0", "030,030") // negrito
	MSCBSAY(80,23,cLote, "N", "0", "040,040") // negrito

	MSCBSAY(04,27,"DT FABR:", "N", "0", "030,030") // negrito
	MSCBSAY(04,31,CValToChar(STOD(Prevf)), "N", "0", "040,040") // negrito

	MSCBSAY(32,27,"VALIDADE:", "N", "0", "030,030") // negrito
	//Alterado por Nelieder em 02/08/2023 chamado R2104
	//MSCBSAY(32,31,CValToChar(DtVenc), "N", "0", "040,040") // negrito
	MSCBSAY(32,31,R2104(DtVenc), "N", "0", "040,040") // negrito

	MSCBSAY(04,38,"PESO LIQ.:", "N", "0", "040,040") // negrito
	MSCBSAY(04,43,Volume+UMEMB, "N", "0", "060,065") // negrito

	
	// Nelieder - Incluido em 13/06/20222, solicitado por Fernando Dissoltex //
	// Verifica se foi preenchido contador //
	if val(cCont) > 0
		MSCBSAY(32,38,"CX", "N", "0", "040,040") // negrito
		MSCBSAY(32,43,strzero(val(cCont),3), "N", "0", "040,040") // negrito
		cCont := val(cCont) + 1
		cCont := strzero(cCont,3)
	
	//retirado em 04/05/23
	//Else
	//	MSCBSAY(32,38,"CX", "N", "0", "040,040") // negrito
	//	MSCBSAY(32,43,strzero(qtd,3), "N", "0", "040,040") // negrito∑

	EndIf	


	If !empty(AllTrim(Prod)) .and. (Val(Volume) > 0)
		MSCBSAY(04,52,OemToAnsi("TEMPERATURA DE CURA: 200 ßC - 10 Minutos"), "N", "0", "035,035") // negrito
	Endif

	
	MSCBSAYBAR(55,35,CodBar,"N","MB04",8, .F., .T., .F., ,3,3, .F., .F., "1", .T.)

	MSCBEND()
	MSCBCLOSEPRINTER()

	// Temporizador incluido para impress„o em Rede para a Dissoltex
	Sleep(_ZPPAR0217)

	UPD_XVOL(NcXidvol,REG,C2_NUM,C2_ITEM,C2_SEQUEN,cLote)


	


Return()
    Jose 28/03/2025 */

/*/{Protheus.doc} PCP037_11
Etiqueta 26x15mm(xarope)
@type function
@author neliedercorneta
@since 23/12/2021
@param linha, logical, linha
@param qtd, variant, qtd de produtos
/*/

/* Jose 28/03/2025

Static Function PCP037_11(linha,qtd)
	
	Local cModelo := "ZEBRA"
	Local Prod,ProdTxt,Cod,Unid,CodBar
	Local Validade,Prevf,PrazoVali,Dias,cLote
	Local DtVenc,cEmb
	Local Volume,UMEMB

	Local Catalis,RelCat1

	Cod           := AllTrim(aBrowse[linha][2])
 
	//	Quando B1_DESCLIN for diferente de branco pegar B1_DESCLIN
 	
	if !empty(AllTrim(aBrowse[linha][21]))
		ProdTxt    := AllTrim(aBrowse[linha][21])
	else
		ProdTxt    := AllTrim(aBrowse[linha][4])
	endif

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

	// identifica embalagem //
	If len(Alltrim(Cod)) == 12
		cEmb          := substr(Cod,11,2)
	Endif

	MSCBPRINTER(cModelo, cLPT,,12,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBBEGIN(1)
	
	//Alterado por Nelieder em 02/08/2023 chamado R2104

	MSCBSAY(05.5,03,"Lt "+cLote , "N", "0", "024,027") // negrito
	MSCBSAY(05.5,07,"Fab "+CValToChar(STOD(Prevf)), "N", "0", "024,027") // negrito
	//MSCBSAY(05.5,11,"Val  "+CValToChar(DtVenc), "N", "0", "024,027") // negrito
	MSCBSAY(05.5,11,"Val  "+R2104(DtVenc), "N", "0", "024,027") // negrito

	MSCBSAY(32.5,03,"Lt "+cLote , "N", "0", "024,027") // negrito
	MSCBSAY(32.5,07,"Fab "+CValToChar(STOD(Prevf)), "N", "0", "024,027") // negrito
	//MSCBSAY(32.5,11,"Val  "+CValToChar(DtVenc), "N", "0", "024,027") // negrito
	MSCBSAY(32.5,11,"Val  "+R2104(DtVenc), "N", "0", "024,027") // negrito

	MSCBSAY(58.5,03,"Lt "+cLote , "N", "0", "024,027") // negrito
	MSCBSAY(58.5,07,"Fab "+CValToChar(STOD(Prevf)), "N", "0", "024,027") // negrito
	//MSCBSAY(58.5,11,"Val  "+CValToChar(DtVenc), "N", "0", "024,027") // negrito
	MSCBSAY(58.5,11,"Val  "+R2104(DtVenc), "N", "0", "024,027") // negrito

	MSCBEND()
	MSCBCLOSEPRINTER()

Return()
   Jose 28/03/2025 */


/*/{Protheus.doc} PCP037_13
Nova Etiqueta 100X50
@type function
@author neliedercorneta
@since 21/10/2021
@param linha, logical, linha
@param qtd, variant, qtd de produtos
/*/

/*    Jose 28/03/2025

Static Function PCP037_13(linha,qtd)
	Local cModelo 	:= "ZEBRA"

	Local Prod,ProdTxt,Cod,Unid,CodBar
	Local Validade,Prevf,PrazoVali,Dias,cLote
	Local DtVenc,cEmb
	Local Volume,UMEMB

	Local Catalis,RelCat1

	Cod        := AllTrim(aBrowse[linha][2])
 	
	//	Quando B1_DESCLIN for diferente de branco pegar B1_DESCLIN

	if !empty(AllTrim(aBrowse[linha][21]))
		ProdTxt    := AllTrim(aBrowse[linha][21])
	else
		ProdTxt    := AllTrim(aBrowse[linha][4])
	endif

	Unid       := SUBSTR(aBrowse[linha][5],1,2)
	Unid       := AllTrim(Unid)
	Unid       := StrZero(val(Unid),2)
	Validade   := aBrowse[linha][6]
	Prevf      := AllTrim(aBrowse[linha][7])
	cLote      := AllTrim(aBrowse[linha][8])
	CodBar     := AllTrim(aBrowse[linha][9])
	PrazoVali  := aBrowse[linha][10]
	Prod       := AllTrim(aBrowse[linha][11])

	cXidvol    := AllTrim(aBrowse[linha][12])
	cXidvol    := StrZero(val(cXidvol),4)
	Volume     := CValToChar(aBrowse[linha][13])

	// trata produtos com volume menor que 1 transformando em ml //
	if val(Volume) < 1
		UMEMB  := TrtUnimed(Alltrim(aBrowse[linha][14]),val(volume))
		Volume := CValToChar (val(Volume) * 1000)
	else
		//UMEMB 	   := CValToChar(aBrowse[linha][14])
		UMEMB  := TrtUnimed(Alltrim(aBrowse[linha][14]),val(volume))
	endif

	Catalis	   := AllTrim(aBrowse[linha][15])	
	
	// verifica se existe catalizador //
	if !Empty(Catalis)
		// separa componente A e B //
		RelCat1    := strtokarr (UPPER(AllTrim(aBrowse[linha][16])), "X")

		if Len(RelCat1) <> 2
			MsgAlert('Verifique o campo Rel.Cat.Vol no cadastro do Produto '+Prod)
		Endif

	EndIf	

	IF Empty(PrazoVali)
		PrazoVali := 0
		Dias := 0
	Endif

	IF Empty(Validade)
		Validade := 0
	Endif

	// calcula vencimento do produto //
	IF(PrazoVali > 0)
		Dias := (PrazoVali * 30)
		DtVenc := DaySum(STOD(Prevf), Dias  )
	else
		Dias := (Validade * 30)
		DtVenc := DaySum(STOD(Prevf), Dias  )
	Endif

	// alteraÁ„o solicitada por Sabrina via chamado 026547 23/06/2022 //
	
	// Chamado 026762  solicitado cancelar alterar demanda do chamado 02654 19/10/2022 //
    if !empty(AllTrim(aBrowse[linha][22]))
		ProdTxt    := AllTrim(aBrowse[linha][22])
	endif

	// identifica embalagem //
	If len(Alltrim(Cod)) == 12

		//   Tratativa para produtos com inicio BM
		//   Exemplo BM 00.23.157-01   	
		//   Neste caso, n„o utilizar o codigo da embalagem e sim 157
 
		if substr(Cod,1,2) == "BM"
			cEmb          := substr(Cod,8,3)
		else
			cEmb          := substr(Cod,11,2)
		endif	

	Endif

	// inicio de impress„o das etiquetas//
	MSCBPRINTER(cModelo, cLPT,,12,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBLOADGRF("SIGA.GRF")
	MSCBBEGIN(1)

	MSCBSAY(05,02   ,SUBSTR(Prod,1,30), "N", "0", "042,042") // negrito
	MSCBSAY(90,03   ,cEmb, "N", "0", "030,030") // negrito
	MSCBSAY(05,08   ,ProdTxt, "N", "0", "028,028") // negrito
	
	MSCBSAY(05,12,"COD:", "N", "0", "025,022") // negrito
	Cod = TRANSFORM(Cod, "@R XX 99.99.999-XX")
	MSCBSAY(11,12,Cod, "N", "0", "025,022") 
	
	MSCBSAY(35,12,"LOTE:", "N", "0", "025,022") // negrito
	MSCBSAY(44,12,cLote, "N", "0", "025,022") 

	MSCBLineH(00,16,100,3,'B')

	//MSCBLineV(inicio_H,inicio_v,fim_h,tamho_linha,'B')
	MSCBLineV (24       ,21      ,30   ,    3      ,'B')	

	//MSCBLineV(inicio_H,inicio_v,fim_h,tamho_linha,'B')
	MSCBLineV (48       ,16      ,40   ,    3      ,'B')

	//MSCBLineV(inicio_H,inicio_v,fim_h,tamho_linha,'B')
	MSCBLineV (79       ,16      ,30   ,    3      ,'B')



	MSCBSAY(05,17,"RELA«√O DE MISTURA EM VOLUME ", "N", "0", "026,022") // negrito
	MSCBSAY(50,18,"ATENDE NORMA", "N", "0", "033,033") 
	
	
   

	SB5->(DbSetOrder(1)) //SB5_FILIAL+SB5_COD
	If SB5->(DbSeek(Xfilial('SB5')+AllTrim(aBrowse[linha][2])))
		If !Empty(SB5->B5_XNORMA)
			MSCBSAY(60,24,"Nß "+SB5->B5_XNORMA, "N", "0", "035,035") 
		EndIf	
	Endif

	
	MSCBSAY(81,18,"FABRICA«√O", "N", "0", "020,022") 
	MSCBSAY(81,21,CValToChar(STOD(Prevf)), "N", "0", "020,022") 
	
	MSCBSAY(81,24,"VALIDADE", "N", "0", "020,022") 
	
	//Alterado por Nelieder em 02/08/2023 chamado R2104
	//MSCBSAY(81,27,CValToChar(DtVenc), "N", "0", "020,022") 
	MSCBSAY(81,27,R2104(DtVenc), "N", "0", "020,022") 
	
	
	MSCBLineH(00,21,48,3,'B')
	
	MSCBSAY(05,23,"COMPONENTE A", "N", "0", "020,022") 
	MSCBSAY(27,23,"COMPONENTE B", "N", "0", "020,022") 
	
	MSCBLineH(00,26,48,3,'B')
	
	
	// verifica se existe catalizador //
	if !Empty(Catalis)

		MSCBSAY(05,27,RelCat1[1], "N", "0", "020,022") 
		MSCBSAY(27,27,RelCat1[2], "N", "0", "020,022") 

		MSCBSAY(05,32,"CATALISADOR ", "N", "0","034,034") 
		MSCBSAY(05,36, TRANSFORM(Catalis, "@R XX 99.99.999-XX"), "N", "0","034,034") 

	EndIf	
	
	MSCBLineH(00,30,100,3,'B')

	SB5->(DbSetOrder(1)) //SB5_FILIAL+SB5_COD
	If SB5->(DbSeek(Xfilial('SB5')+AllTrim(aBrowse[linha][2])))
		If !Empty(SB5->B5_DILUENT)

				// Diluente especifico no cadastro de Produto //
				MSCBSAY(50,32,"DILUENTE RECOMENDADO", "N", "0", "034,034") 
				MSCBSAY(50,36,TRANSFORM(SB5->B5_DILUENT, "@R XX 99.99.999"), "N", "0", "034,034") 

		Else
			ZAB->(DbSetOrder(1)) //ZAB_FILIAL+ZAB_DILUEN+ZAB_LINHA
   			If ZAB->(DbSeek(Xfilial('ZAB')+ SUBSTR(AllTrim(aBrowse[linha][2]),4,2) ))
				
				// Diluente Padr„o por linha //
				MSCBSAY(50,32,"DILUENTE RECOMENDADO", "N", "0", "034,034") 
				MSCBSAY(50,36,TRANSFORM(ZAB->ZAB_DILUEN, "@R XX 99.99.999"), "N", "0", "034,034") 

			EndIf	
		EndIf	
	Endif
    	
	MSCBLineH(00,40,100,3,'B')
	
	MSCBSAY(04,42,"CONTEUDO LIQUIDO", "N", "0","068,068") 
	MSCBSAY(80,42,Volume+" "+UMEMB , "N", "0","068,068") 
	MSCBSAYBAR(67,07,CodBar,"N","MB04",5, .F., .T., .F., ,02,02, .F., .F., "1", .T.)
                 
	MSCBEND()
	MSCBCLOSEPRINTER()

Return()
    Jose 28/03/2025 */

/*/{Protheus.doc} PCP037_14
Etiqueta Tambor 100X50
@type function
@author neliedercorneta
@since 26/10/2022
@param linha, logical, linha
@param qtd, variant, qtd de produtos
/*/
/*     Jose 28/03/2025
Static Function PCP037_14(linha,qtd)

	Local cModelo 	:= "ZEBRA"

	Local Prod,ProdTxt,Cod,Unid,CodBar
	Local Validade,Prevf,PrazoVali,Dias,cLote
	Local DtVenc,cEmb
	Local Volume,UMEMB

	Local Catalis,RelCat1

	// especifica tambores //
	Local cONU := ""

	Cod        := AllTrim(aBrowse[linha][2])
		
 	//	Quando B1_DESCLIN for diferente de branco pegar B1_DESCLIN
	
	if !empty(AllTrim(aBrowse[linha][21]))
		ProdTxt    := AllTrim(aBrowse[linha][21])
	else
		ProdTxt    := AllTrim(aBrowse[linha][4])
	endif
	
	Unid       := SUBSTR(aBrowse[linha][5],1,2)
	Unid       := AllTrim(Unid)
	Unid       := StrZero(val(Unid),2)
	Validade   := aBrowse[linha][6]
	Prevf      := AllTrim(aBrowse[linha][7])
	cLote      := AllTrim(aBrowse[linha][8])
	CodBar     := AllTrim(aBrowse[linha][9])
	PrazoVali  := aBrowse[linha][10]
	Prod       := AllTrim(aBrowse[linha][11])

	cXidvol    := AllTrim(aBrowse[linha][12])
	cXidvol    := StrZero(val(cXidvol),4)
	Volume     := CValToChar(aBrowse[linha][13])

	// trata produtos com volume menor que 1 transformando em ml //
	if val(Volume) < 1
		UMEMB  := TrtUnimed(Alltrim(aBrowse[linha][14]),val(volume))
		Volume := CValToChar (val(Volume) * 1000)
	else
		//UMEMB 	   := CValToChar(aBrowse[linha][14])
		UMEMB  := TrtUnimed(Alltrim(aBrowse[linha][14]),val(volume))
	endif

	Catalis	   := AllTrim(aBrowse[linha][15])	
	
	// verifica se existe catalizador //
	if !Empty(Catalis)
		// separa componente A e B //
		RelCat1    := strtokarr (UPPER(AllTrim(aBrowse[linha][16])), "X")

		if Len(RelCat1) <> 2
			MsgAlert('Verifique o campo Rel.Cat.Vol no cadastro do Produto '+Prod)
		Endif

	EndIf	

	IF Empty(PrazoVali)
		PrazoVali := 0
		Dias := 0
	Endif

	IF Empty(Validade)
		Validade := 0
	Endif

	// calcula vencimento do produto //
	IF(PrazoVali > 0)
		Dias := (PrazoVali * 30)
		DtVenc := DaySum(STOD(Prevf), Dias  )
	else
		Dias := (Validade * 30)
		DtVenc := DaySum(STOD(Prevf), Dias  )
	Endif


	// AlteraÁ„o especifica para etiquetas tambores //
	SB1->(DbSeek(xFilial("SB1")+PadR(Cod, tamsx3('B1_COD') [1])))
	cONU := ""
	
	dbSelectArea("SYD")
	dbSetOrder(1)
	SYD->(dbGoTop())
	If dbSeek(xFilial("SYD")+PadR(SB1->B1_POSIPI,TamSx3("YD_TEC")[1]))
		cONU := SYD->YD_XONU
	EndIf 

	if cTbFab <> cTod("  /  /  ")
		Prevf := DToS(cTbFab)
	Endif
		

	// alteraÁ„o solicitada por Sabrina via chamado 026547 23/06/2022 //
	
	// Chamado 026762  solicitado cancelar alterar demanda do chamado 02654 19/10/2022 //
    if !empty(AllTrim(aBrowse[linha][22]))
		ProdTxt    := AllTrim(aBrowse[linha][22])
	endif

	// identifica embalagem //
	If len(Alltrim(Cod)) == 12

		//   Tratativa para produtos com inicio BM
		//   Exemplo BM 00.23.157-01   	
		//   Neste caso, n„o utilizar o codigo da embalagem e sim 157
 
		if substr(Cod,1,2) == "BM"
			cEmb          := substr(Cod,8,3)
		else
			cEmb          := substr(Cod,11,2)
		endif	

	Endif

	MSCBPRINTER(cModelo, cLPT,,20,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBLOADGRF("SIGA.GRF")
	MSCBBEGIN(1)

	MSCBSAY(005,130 ,"CODIGO "+cTambor, "B", "0", "080,060") //ok
	MSCBSAY(005,025 ,padr(SB5->B5_GREIF,20,""), "B", "0", "080,060") //ok
	
	//MSCBLineV(inicio_H,inicio_v,fim_h,tamho_linha,'B')
	MSCBLineV (20       ,02      ,194   ,    3      ,'B')

	MSCBLineH (00       ,100      ,100   ,    3      ,'B')
	
	
	Cod = TRANSFORM(Cod, "@R XX 99.99.999-XX")

		// Correta
	MSCBSAY(026,130 ,Cod, "B", "0", "080,060") //ok)
	MSCBSAY(026,000 ,SUBSTR(Prod,1,30), "B", "0", "060,050") //ok)	
	
	// Correta
	//MSCBSAY(026,130 ,Cod, "B", "0", "080,060") //ok)
	//MSCBSAY(026,040 ,SUBSTR(Prod,1,30), "B", "0", "080,060") //ok)

	//MSCBLineV(inicio_H,inicio_v,fim_h,tamho_linha,'B')
	MSCBLineV (40       ,02      ,194   ,    3      ,'B')

	MSCBSAY(046,148 ,"FABRICA«√O :", "B", "0", "080,060") //ok
	MSCBSAY(046,110 ,CValToChar(STOD(Prevf)), "B", "0", "080,060") //ok

	MSCBSAY(046,055 ,"VALIDADE :", "B", "0", "080,060") //ok
	
	//Alterado por Nelieder em 02/08/2023 chamado R2104
	//MSCBSAY(046,016 ,CValToChar(DtVenc), "B", "0", "080,060") //ok
    MSCBSAY(046,016 ,R2104(DtVenc), "B", "0", "080,060") //ok

	//MSCBLineV(inicio_H,inicio_v,fim_h,tamho_linha,'B')
	MSCBLineV (60       ,02      ,194   ,    3      ,'B')
	
	MSCBSAY(066,145 ,"PESO LIQUIDO:", "B", "0", "080,060") //ok
	MSCBSAY(066,120 ,"180 LT", "B", "0", "080,060") //ok

	MSCBSAY(066,048 ,"CAPACIDADE:", "B", "0", "080,060") 
	MSCBSAY(066,016 ,"200 LT", "B", "0", "080,060") 
	
	//MSCBLineV(inicio_H,inicio_v,fim_h,tamho_linha,'B')
	MSCBLineV (80       ,02      ,194   ,    3      ,'B')

	MSCBSAY(086,175 ,"LOTE : ", "B", "0", "080,060") //ok
	MSCBSAY(086,150 ,cLote, "B", "0", "080,060") //ok

	MSCBSAY(086,125 ,"ONU : ", "B", "0", "080,060") //ok
	MSCBSAY(086,105 ,cONU    , "B", "0", "080,060") //ok

	MSCBSAYBAR(82,35,CodBar,"B","MB04",GETMV('MV_PCP37_1'), .F., .T., .F., ,GETMV('MV_PCP37_2'),GETMV('MV_PCP37_3'), .F., .F., "1", .T.)
	
	MSCBEND()
	MSCBCLOSEPRINTER()

Return()
    Jose 28/03/2025 */


Static Function ReportPrint(nTipo)

local n      := 1
local i      := 1
local linhas := len(aBrowse)
local qtd
local linha,Prevf,UMEMB,Volume
Local Letiq := 0

Private oPrint
Private oFont9     := TFont():New('Arial',,9,,.F.,,,,.F.,.F.)
Private oFont9n    := TFont():New('Arial',,9,,.T.,,,,.F.,.F.)

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

	
	/* valida se array pois dados */
	if len(aBrowse) < 1 .OR. (empty(aBrowse[1][1]))
		MsgInfo( 'Necess·rio Consultar uma OP ou Lote' , 'Etiquetas Produtos' )
		Return()
	Endif
    
	/* Loop nas linhas do Array */
	For n        := 1 to linhas

	linha := n

	Cod           := AllTrim(aBrowse[linha][2])
	
	/* 
		Quando B1_DESCLIN for diferente de branco pegar B1_DESCLIN
    */
	
	if !empty(AllTrim(aBrowse[linha][21]))
		ProdTxt    := AllTrim(aBrowse[linha][21])
	else
		ProdTxt    := AllTrim(aBrowse[linha][4])
	endif

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
	

	/* verifica se existe catalizador */
	if !Empty(Catalis) .AND. nTipo == 6
		/* separa componente A e B */
		RelCat1    := strtokarr (UPPER(AllTrim(aBrowse[linha][16])), "X")

		if Len(RelCat1) <> 2
			MsgAlert('Verifique 1 o campo Rel.Cat.Vol no cadastro do Produto '+Prod)
		Endif
	Else
		RelCat1    := AllTrim(aBrowse[linha][16])
	EndIf	

	/* alteraÁ„o solicitada por Sabrina via chamado 026547 23/06/2022 */
	if !empty(AllTrim(aBrowse[linha][22]))
		ProdTxt    := AllTrim(aBrowse[linha][22])
	endif

	
	/* chamado 026762 (Sabrina) */
	/*If SUBSTR(Cod,1,10) == "VN 0900030"
		Prod	   := "VERNIZ COPAL BRILHANTE"	
		ProdTxt    := "VERNIZ INCOLOR INTERIOR"
	EndIf*/

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

			/* 
				Tratativa para produtos com inicio BM
				Exemplo BM 00.23.157-01   	
				Neste caso, n„o utilizar o codigo da embalagem e sim 157

			*/

			if substr(Cod,1,2) == "BM"
				cEmb          := substr(Cod,8,3)
				cEmb_Bar	  := substr(Cod,11,2)
			else
				cEmb          := substr(Cod,11,2)
				cEmb_Bar	  := substr(Cod,11,2)
			endif	

	Endif

	/* formata codigo produto */
	Cod 		  := TRANSFORM(Cod, "@R XX 99.99.999-XX")
		

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
					CodBar        := cLote+cEmb_Bar+Unid+StrZero( (val(cXidvol))+i , 4)
					MSBAR3( 'CODE128', 2.2+Letiq , 2, CodBar, oPrint, .T.,10, .T., 0.030,1.2, .T.,,, .F. )
					nLin  += 300
					Letiq += 4.2 
				
				else

					if val(Volume) < 1
						UMEMB  := TrtUnimed(Alltrim(aBrowse[linha][14]),val(Volume))
						Volume := CValToChar (val(Volume) * 1000)
					else
						//UMEMB 	   := CValToChar(aBrowse[linha][14])
						UMEMB  := TrtUnimed(Alltrim(aBrowse[linha][14]),val(Volume))
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
					oPrint:Say(nLin,0050,OemToAnsi("LOTE: "+cLote),oFont12n,,,,0)
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
					oPrint:Say(nLin,0050,OemToAnsi(Volume+UMEMB+" Lote: "+cLote),oFont12n,,,,0)
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
						UMEMB  := TrtUnimed(Alltrim(aBrowse[linha][14]),val(volume))
						Volume := CValToChar (val(Volume) * 1000)
					else
						//UMEMB 	   := CValToChar(aBrowse[linha][14])
						UMEMB  := TrtUnimed(Alltrim(aBrowse[linha][14]),val(volume))
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
					oPrint:Say(nLin,0050,OemToAnsi("LOTE: "+cLote),oFont12n,,,,0)
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
						UMEMB  := TrtUnimed(Alltrim(aBrowse[linha][14]),val(volume))
						Volume := CValToChar (val(Volume) * 1000)
					else
						//UMEMB 	   := CValToChar(aBrowse[linha][14])
						UMEMB  := TrtUnimed(Alltrim(aBrowse[linha][14]),val(volume))
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
						oPrint:Say(nLin,0050,OemToAnsi("TEMPERATURA DE CURA: 200 ßC - 10 Minutos"),oFont12n,,,,0)
					Endif
					
					
					MSBAR3( 'CODE128', 2.7+Letiq , 4, CodBar+U_DigEan13(CodBar), oPrint, .T.,10, .T., 0.025,1, .T.,,, .F. )
					
					nLin += 130
					oPrint:Line (nLin,0010,nLin,850)
					nLin += 150
					Letiq += 6.15 	

				Endif


				Case nTipo == 6

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
						CodBar        := cLote+cEmb_Bar+Unid+StrZero( (val(cXidvol))+i , 4)
						MSBAR3( 'CODE128', 2.2+Letiq , 2, CodBar, oPrint, .T.,10, .T., 0.030,1.2, .T.,,, .F. )
						nLin  += 300
						Letiq += 4.2 
						
						
					else

						if val(Volume) < 1
							UMEMB  := TrtUnimed(Alltrim(aBrowse[linha][14]),val(Volume))
							Volume := CValToChar (val(Volume) * 1000)
						else
							//UMEMB 	   := CValToChar(aBrowse[linha][14])
							UMEMB  := TrtUnimed(Alltrim(aBrowse[linha][14]),val(Volume))
						endif

						oPrint:Line (nLin,0010,nLin,1200)
						nLin += 020
						oPrint:Say(nLin,0050,OemToAnsi(Prod),oFont15n,,,,0)
						oPrint:Say(nLin,1150,OemToAnsi(cEmb),oFont15n,,,,0)
						nLin += 050
						oPrint:Say(nLin,0050,OemToAnsi(ProdTxt),oFont15n,,,,0)
						nLin += 060
						oPrint:Say(nLin,0050,OemToAnsi("COD: "+Cod),oFont12n,,,,0)
						oPrint:Say(nLin,0450,OemToAnsi("LOTE: "+cLote),oFont12n,,,,0)
						MSBAR3( 'CODE128', 0.6+Letiq , 6, CodBar+U_DigEan13(CodBar), oPrint, .T.,10, .T., 0.025,1, .T.,,, .F. )
						nLin += 065
						oPrint:Line (nLin,0010,nLin,1200)

						oPrint:Line (nLin,0600,nLin+215,0600)/* linha vertical */

						oPrint:Line (nLin,0950,nLin+215,0950)/* linha vertical apÛs atende a norma */
						
						nLin  += 035
						
						oPrint:Say(nLin,0050,OemToAnsi("RELACAO DE MISTURA EM VOLUME"),oFont10n,,,,0)

						oPrint:Say(nLin,0620,OemToAnsi("ATENDE A NORMA"),oFont12n,,,,0)	

						oPrint:Say(nLin,1000,OemToAnsi("FabricaÁ„o"),oFont10n,,,,0)

						nLin  += 040
						oPrint:Say(nLin,0050,OemToAnsi("COMPONENTE A"),oFont9,,,,0)
						oPrint:Say(nLin,0300,OemToAnsi("COMPONENTE B"),oFont9,,,,0)

						SB5->(DbSetOrder(1)) //SB5_FILIAL+SB5_COD
						If SB5->(DbSeek(Xfilial('SB5')+AllTrim(aBrowse[linha][2])))
							If !Empty(SB5->B5_XNORMA)
								oPrint:Say(nLin,0620,OemToAnsi(SB5->B5_XNORMA),oFont12n,,,,0)
							EndIf	
						Endif

						oPrint:Say(nLin,1000,OemToAnsi(CValToChar(STOD(Prevf))),oFont9,,,,0) /* FabricaÁ„o */
						
						
						

						nLin  += 040
						if len(RelCat1) > 1
							oPrint:Say(nLin,0050,OemToAnsi(RelCat1[1]),oFont9,,,,0)
							oPrint:Say(nLin,0300,OemToAnsi(RelCat1[2]),oFont9,,,,0)
						EndIf	

						oPrint:Say(nLin,1000,OemToAnsi("Validade"),oFont10n,,,,0)
						nLin  += 040
						oPrint:Say(nLin,1000,OemToAnsi(CValToChar(DtVenc) ),oFont9,,,,0) /* validade */
						nLin += 055
						oPrint:Line (nLin,0010,nLin,1200)

						oPrint:Say(nLin,0050,OemToAnsi("CATALISADOR"),oFont12n,,,,0) 

						oPrint:Say(nLin,0620,OemToAnsi("DILUENTE RECOMENDADO"),oFont12n,,,,0)

						nLin += 055

						oPrint:Say(nLin,0050,OemToAnsi(TRANSFORM(Catalis, "@R XX 99.99.999-XX")),oFont12n,,,,0)
						

						SB5->(DbSetOrder(1)) //SB5_FILIAL+SB5_COD
						If SB5->(DbSeek(Xfilial('SB5')+AllTrim(aBrowse[linha][2])))
							If !Empty(SB5->B5_DILUENT)

								/* Diluente especifico no cadastro de Produto */ 
								oPrint:Say(nLin,0620,OemToAnsi(TRANSFORM(SB5->B5_DILUENT, "@R XX 99.99.999")),oFont12n,,,,0)

							Else
								ZAB->(DbSetOrder(1)) //ZAB_FILIAL+ZAB_DILUEN+ZAB_LINHA
								If ZAB->(DbSeek(Xfilial('ZAB')+ SUBSTR(AllTrim(aBrowse[linha][2]),4,2) ))
									
									/* Diluente Padr„o por linha */
									oPrint:Say(nLin,0620,OemToAnsi(TRANSFORM(ZAB->ZAB_DILUEN, "@R XX 99.99.999")),oFont12n,,,,0)

								EndIf	
							EndIf	
						Endif
						nLin += 055
						oPrint:Line (nLin,0010,nLin,1200) 
						oPrint:Say(nLin,0050,OemToAnsi("CONTEUDO LIQUIDO "+CValToChar(Volume)+" "+CValToChar(UMEMB)),oFont30n,,,,0)
						nLin += 100
						oPrint:Line (nLin,0010,nLin,1200) 

						nLin += 90
						Letiq += 5.95 	
						
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

/* quando È produto BM */
if  (len( AllTrim(codbarra)) == 15)

		retorno :=	substr(codbarra,10,2)
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

/*     Jose 28/03/2025
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
     Jose 28/03/2025 */

	 
/*/{Protheus.doc} UPD_XVOL
Atualiza da Sequencia do Campo C2_XIDVOL
@type function
@author neliedercorneta
@since 13/01/2022
@param XIDVOL, variant, XIDVOL
@param REG, variant, R_E_C_N_O_
@param C2_NUM, character, C2_NUM
@param C2_ITEM, character, C2_ITEM
@param C2_SEQUEN, character, C2_SEQEUN
@param C2_LOTE, character, C2_LOTE
/*/

/*  Jose  28/03/2025
Static Function UPD_XVOL(XIDVOL,REG,C2_NUM,C2_ITEM,C2_SEQUEN,C2_LOTE)


	DbSelectARea("SC2")
	DbSetOrder(1)
	if DbSeek(xFilial("SC2")+C2_NUM+C2_ITEM+C2_SEQUEN)
		WHILE !EOF() 
			If RECNO() == REG
				RecLock("SC2",.F.) 
					Replace C2_XIDVOL With XIDVOL
				MsUnLock()
				exit
			Endif
            Dbskip()
		Enddo			 
		
	Endif

return
   Jose 28/03/2025 */

/*   Jose 28/03/2025 
Static Function TrtUnimed(Unid,vol)
Local UMEMB

	
   if vol < 1	
	
		if Unid == 'L'
				UMEMB 	   := "ml"
		Endif							

		if Unid == 'K'
				// Alterado conforme solicitado no chamado R5234
				//UMEMB 	   := "gr" Alterado de gr para g
				UMEMB 	   := "g"
				
		endif		
	endif	

	if vol >= 1	

		if Unid == 'L'
				UMEMB 	   := "L"
		Endif							

		if Unid == 'K'
				UMEMB 	   := "Kg"
		endif		
	endif	

return(UMEMB)

   Jose 28/03/2025 */

/* funÁ„o que valida e atualiza o campo de Cliente Tambor */
Static Function VLDRAD(xtipo)
 
/* 
 if xtipo == 7
	oTambor:Enable()
	oTbFab:Enable()
 else		
	oTambor:disable()
	cTambor := space(10)
	oTambor:Refresh()

	oTbFab:disable()
	cTbFab := cTod("  /  /  ")
	oTbFab:Refresh()

 endif
 
*/
return()

// Altera catalise do produto PA
// FunÁ„o desabilitada

/*    Jose 28/03/2025

Static Function CATALIPA(cLote)

DbSelectARea("SC2")
DbSetOrder(13)
if DbSeek(xFilial("SC2")+cLote)
	While !(SC2->(Eof())) .AND. ((XFilial("SC2") == SC2->C2_FILIAL) .AND. Alltrim(cLote) == Alltrim(SC2->C2_LOTE)) 
		
		SB1->(DbSeek(xFilial("SB1")+PadR(SC2->C2_PRODUTO, tamsx3('B1_COD') [1])))
			If (SB1->B1_TIPO == "PA")
				RecLock("TMP",.F.) 
					Replace TMP->B1_RELCAT1 With SB1->B1_RELCAT1
					Replace TMP->B1_CATALIS With SB1->B1_CATALIS
				MsUnLock()
			EndIf	
		SC2->(DbSkip())

	Enddo

	
Endif

return()


   Jose 28/03/2025 */

// FunÁ„o trata chamado R2104 - alteraÁ„o da data de DD/MM/AAAA para MM/AA

/*  Jose 28/03/2025

Static Function R2104(cData)
Local cret := ""
Local cAno := ""
Local cDia := ""
Local cMes := "99/99"

	// Verificar se campo È data
	If ValType(cData) == "D"
		cAno := SubStr(Year2Str(cData),3,2)
		cMes := Month2Str(cData)
		cDia :=	Day(cData)
		
		If cDia >= 20
			cData := MonthSum(cData,1)	// Altera Vencimento para o proximo mÍs
			cAno := SubStr(Year2Str(cData),3,2)
			cMes := Month2Str(cData)
		EndIf
		
		cret :=  cMes+"/"+cAno
	EndIf	

return(cret)
    Jose 28/03/2025  */
