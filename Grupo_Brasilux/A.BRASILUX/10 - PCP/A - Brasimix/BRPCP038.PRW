#Include "Protheus.ch"
#Include "TopConn.ch"

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ BRPCP038  ∫Autor  ≥ Nelieder Corneta  ∫ Data ≥  17/12/2021 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫DescriÁ„o ≥ Etiquetas Identif. Volumes Diferenciados				       ±±
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
 
User Function BRPCP038  ()

Local nTipo       := 1

//Fontes
Private cFontUti  := "Tahoma"
Private oFontAno  := TFont():New(cFontUti, , -38)
Private oFontBtn  := TFont():New(cFontUti, , -14)
Private oFontSub  := TFont():New(cFontUti, , -16)
Private oFontSubN := TFont():New(cFontUti, , -20, , .T.)

//Tamanho da Janela
Private nJanLarg  := 730
Private nJanAltu  := 335

Private oOP
Private cOP       := space(13)

Private oLote
Private cLote     := space(6)

Private oQtde1
Private cQtde1    := space(6)

Private oQtde2
Private cQtde2    := space(6)

Private oObs
Private cObs      := space(6)

Private aBrowse   := {}


Private lEditar   := .T.
Private oBtnFech

Private cFlag     := .F.

Private oLPT,cLPT

Private oEan
Private cEan := space(12)

Private oProduto,cProduto
Private aProduto :={}

Private oCodPro,cCodPro

Private cDescPro,oDescPro

Private oQtVol,cQtVol
//Private aQtVol :={}

Private aLPT      :={}

/* define padr„o de data */
Set(_SET_DATEFORMAT, 'dd/mm/yy' )

    
DEFINE MSDIALOG oDlg TITLE "Estiquetas Identif. Volumes Diferenciados" FROM 000, 000 TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL

@ 004, 003 MSPANEL oPanel SIZE 260, 130 OF oDlg COLORS 0, 14215660 CENTERED RAISED

@ 010, 010 SAY OemToAnsi("N∫ da OP.: ") SIZE 060,009 PIXEL OF oDlg FONT oFontBtn
@ 008, 070 MSGET oOP VAR cOP PICTURE "@!" SIZE 070,010 COLOR CLR_BLUE F3 "SC2" PIXEL ON CHANGE PCP038_03() OF  oDlg FONT oFontBtn
@ 010, 155 SAY OemToAnsi("N∫ do Lote.: ") SIZE 060,009 PIXEL OF oDlg FONT oFontBtn
@ 008, 200 MSGET oLote VAR cLote PICTURE "@!" SIZE 040,010 COLOR  CLR_BLUE F3 "ZC2" ON CHANGE PCP038_01() PIXEL OF  oDlg FONT oFontBtn

@ 030, 010 SAY OemToAnsi("Codigo EAN ") SIZE 100,009 PIXEL OF oDlg FONT oFontBtn
@ 028, 070 MSGET oEan VAR cEan PICTURE "@!" SIZE 060,010 COLOR CLR_BLUE  ON CHANGE PCP038_04() PIXEL OF oDlg FONT oFontBtn

@ 050, 010 SAY OemToAnsi("Codigo Prod..: ") SIZE 100,009 PIXEL OF oDlg FONT oFontBtn
@ 048, 070 MSGET oCodPro VAR cCodPro  SIZE 060,010 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn When .F.
@ 048, 130 MSGET oDescPro VAR cDescPro  SIZE 100,010 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn

@ 070, 010 SAY OemToAnsi("Produto ") SIZE 100,009 PIXEL OF oDlg FONT oFontBtn
@ 068, 068 MSCOMBOBOX oProduto VAR cProduto ITEMS aProduto SIZE 180, 007 OF oPanel COLORS 0, 16777215 PIXEL ON CHANGE PCP038_02(cProduto) FONT oFontBtn

@ 090, 010 SAY OemToAnsi("Qtde Itens no Vol") SIZE 100,009 PIXEL OF oDlg FONT oFontBtn
//@ 088, 068 MSCOMBOBOX oQtVol VAR cQtVol ITEMS aQtVol SIZE 070, 007 OF oPanel COLORS 0, 16777215 PIXEL FONT oFontBtn
@ 088, 068 MSGET oQtVol VAR cQtVol SIZE 070, 007 OF oPanel COLORS 0, 16777215 PIXEL FONT oFontBtn


/*oQtVol:lEditable := .T.
oQtVol:lListOnly := .F.*/


@ 110, 010 SAY OemToAnsi("Qtde Etiq ") SIZE 100,009 PIXEL OF oDlg FONT oFontBtn
@ 108, 070 MSGET oQtde1 VAR cQtde1 PICTURE "999" SIZE 060,010 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn

@ 004, 265 MSPANEL oPanel SIZE 100, 130 OF oDlg COLORS 0, 14215660 FONT oFontBtn CENTERED RAISED

@ 004,004 RADIO oTipo VAR nTipo PROMPT "Zebra","26x15mm(Xarope)","44x15mm","75x35mm","100x69mm" OF oPanel PIXEL SIZE 75,20

@ 060, 004 MSCOMBOBOX oLPT VAR cLPT ITEMS aLPT SIZE 050, 007 OF oPanel COLORS 0, 16777215 PIXEL FONT oFontBtn
ListPort()
//cLPT := GETMV('MV_PCP038') 

@ 140,004 BUTTON oBtnFech PROMPT "Imprimir" SIZE 060, 018 OF oDlg ACTION PCP038_05(nTipo,cQtde1) FONT oFontBtn PIXEL
@ 140,070 BUTTON oBtnFech PROMPT "Visualizar" SIZE 060, 018 OF oDlg ACTION ReportPrint(nTipo) FONT oFontBtn PIXEL
@ 140,135 BUTTON oBtnFech PROMPT "Fechar" SIZE 060, 018 OF oDlg ACTION (oDlg:End()) FONT oFontBtn PIXEL


oDlg:lEscClose := .T.

ACTIVATE MSDIALOG oDlg CENTERED

Return

/*/{Protheus.doc} PCP038_01
Pesquisa Itens por Lote
@type function
@author neliedercorneta
@since 12/01/2022
/*/
Static Function PCP038_01()
Local Index 

cQuery := " "
cQuery += " SELECT C2_NUM,C2_ITEM,C2_SEQUEN,B1_DESC AS NOMEPROD,Z1_DESCR AS TEXTO,B1_DESCLIN AS TEXTO2,B1_PRVALID, "
cQuery += " Z1_VALIDAD,C2_PRODUTO AS CODIGO,C2_QUANT AS QTDE, "
cQuery += " C2_LOTE AS LOTE,C2_DATPRF AS PREVF,B1_CODBAR AS CODBARRA, "
cQuery += " B1_CATALIS,B1_RELCAT1,B1_XCODANT,dbo.DetVol(C2_FILIAL,C2_PRODUTO) AS RELVOL, "
cQuery += " ISNULL(Z5_VOLUME,0) AS VOLUME,ISNULL(Z5_UMEMB,'') AS UMEMB, "
cQuery += " C2_XIDVOL,SC2.R_E_C_N_O_ AS REG " 
cQuery += " FROM SC2010 SC2 WITH (NOLOCK) "
cQuery += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (C2_FILIAL = SB1.B1_FILIAL) AND (C2_PRODUTO = SB1.B1_COD) AND (SB1.D_E_L_E_T_ <> '*')  "
cQuery += " LEFT OUTER JOIN "+RetSqlName("SZ1")+" SZ1 WITH (NOLOCK) ON (LEN(C2_PRODUTO) = 12) AND (SUBSTRING(C2_PRODUTO,4,2) = SZ1.Z1_LINHA) AND (SZ1.D_E_L_E_T_ <> '*') AND (Z1_FILIAL = '"+xFilial("SZ1")+"')  "
cQuery += " LEFT OUTER JOIN "+RetSqlName("SZ5")+" SZ5 WITH (NOLOCK) ON (LEN(C2_PRODUTO) = 12) AND (SUBSTRING(C2_PRODUTO,11,2) = SZ5.Z5_EMB) AND (SZ5.D_E_L_E_T_ <> '*') AND (Z5_FILIAL = '"+xFilial("SZ5")+"')  "
cQuery += " WHERE (C2_FILIAL = '"+xFilial("SC2")+"') AND  "
cQuery += " (C2_LOTE = '"+cLote+"') AND (SB1.B1_TIPO IN ('PA','PI')) AND (SC2.D_E_L_E_T_ <> '*') "
cQuery += " ORDER BY LOTE,CODIGO "

IF Select("TMP") <> 0
	DbSelectArea("TMP")
	DbCloseArea()
ENDIF

TCQuery cQuery New Alias "TMP"

Count To nTotal 

If nTotal == 0
	MsgStop('Nenhum Registro Localizado', 'Consulta')
	return()
Endif

TMP->(dbGoTop())
aProduto := {}
//aQtVol := {}
cQtVol := ''

Index := 1
cCod := CValToChar(Index)+'-'+Alltrim(TMP->CODIGO)+'-'+Alltrim(TMP->NOMEPROD)

While !TMP->(EoF())
	cValor := CValToChar(Index)+'-'+Alltrim(TMP->CODIGO)+'-'+Alltrim(TMP->NOMEPROD)
	aAdd(aProduto,cValor)
	
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
	TMP->TEXTO2;
	})
	
	Index += 1
	TMP->(DbSkip())
EndDo

PCP038_02(cCod)
oProduto:SetItems(aProduto)

return

/*/{Protheus.doc} PCP038_02
identificar volume do produto
@type function
@author neliedercorneta
@since 12/01/2022
@param cProd, character, codigo do produto
/*/
Static Function PCP038_02(cProd)
Local xPro

aString := strtokarr (cProd, "-")

if !Empty(cEan)
	xPro := aString[1]
else
	xPro := aString[2]
endif

cQuery := "SELECT dbo.DetVol('"+xFilial("SC2")+"','"+xPro+"') RELVOL "

IF Select("TEMP") <> 0
	DbSelectArea("TEMP")
	DbCloseArea()
ENDIF

TCQuery cQuery New Alias "TEMP"

cQtVol := ''
cQtVol := Padr(Alltrim(TEMP->RELVOL),5)

/*aQtVol := {}
aAdd(aQtVol,Alltrim(TEMP->RELVOL))
oQtVol:SetItems(aQtVol)*/

return

/*/{Protheus.doc} PCP038_03
Pesquisa itens por OP
@type function
@author neliedercorneta
@since 12/01/2022
/*/
Static Function PCP038_03()


cQuery := " SELECT C2_LOTE,C2_ITEM,C2_SEQUEN,C2_PRODUTO,C2_NUM+C2_ITEM+C2_SEQUEN "
cQuery += " FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK)  "
cQuery += " WHERE (C2_FILIAL = '"+xFilial("SC2")+"') AND " 
cQuery += " (D_E_L_E_T_ <> '*') AND C2_NUM+C2_ITEM+C2_SEQUEN = '"+SUBSTR(cOP,1,11)+"' "
cQuery += " ORDER BY C2_ITEM,C2_SEQUEN "

IF Select("TEMP") <> 0
	DbSelectArea("TEMP")
	DbCloseArea()
ENDIF

TCQuery cQuery New Alias "TEMP"

Count To nTotal 

If nTotal == 0
    MsgAlert('Nenhum Registro localizado!', 'AtenÁ„o')
    return()
endif

TEMP->(dbGoTop())

cLote := TEMP->C2_LOTE
oLote:Refresh()

PCP038_01()

return

/*/{Protheus.doc} PCP038_04
Pesquisa Itens por Codigo EAN
@type function
@author neliedercorneta
@since 12/01/2022
/*/
Static Function PCP038_04()

cEan := Alltrim(cEan)

/*if len(cEan) < 12
  MsgAlert('CodÌgo de barras invalido !', cTitle)
  return()
endif*/

if len(cEan) == 12 .AND. isdigit(cEan)
	cQry := " SELECT dbo.DigVer('"+cEan+"') DIGITO "

	IF Select("TPI") <> 0
        DbSelectArea("TPI")
        DbCloseArea()
	ENDIF

	TCQuery cQry New Alias "TPI"

	cEan := cEan+TPI->DIGITO
endif

cQuery := " SELECT B1_CODBAR,B1_COD,B1_DESC,B1_RESUMO,dbo.DetVol(B1_FILIAL,B1_COD) RELVOL "
cQuery += " FROM "+RetSqlName("SB1")+" WHERE D_E_L_E_T_ = ''  "
cQuery += " AND B1_FILIAL = '"+xFilial("SB1")+"'   " 

if len(cEan) == 13
	cQuery += " AND B1_CODBAR = '"+SUBSTR(cEan,1,12)+"'"
else
	cQuery += " AND B1_COD = '"+cEan+"'"
endif

/*if len(cEan) == 4
	cQuery += " AND B1_COD = '"+cEan+"'"
endif*/

IF Select("TEMP") <> 0
        DbSelectArea("TEMP")
        DbCloseArea()
ENDIF

TCQuery cQuery New Alias "TEMP"

aProduto := {}

//aQtVol := {}
cQtVol := ''

Count To nTotal 
TEMP->(dbGoTop())

While !TEMP->(EoF())
    cCodPro := TEMP->B1_COD
    cDescPro := AllTrim(TEMP->B1_DESC)

    aAdd(aProduto,TEMP->B1_COD)
    oProduto:SetItems(aProduto)

    /*aAdd(aQtVol,Alltrim(TEMP->RELVOL))
    oQtVol:SetItems(aQtVol)*/
	cQtVol := Alltrim(TEMP->RELVOL)

    
    TEMP->(DbSkip())
EndDo



return


/*/{Protheus.doc} PCP038_05
Bot„o Imprimir Etiquetas
@type function
@author neliedercorneta
@since 12/01/2022
@param nTipo, numeric, tamanho da Etiqueta
@param qtd, variant, Qtd de Etiqueta
/*/
Static Function PCP038_05(nTipo,qtd)
Local i 
Local aString
Local linha

if Empty(cQtVol) .OR. Empty(cQtde1)

	MsgInfo( 'Necess·rio informar Volume e Qtd de Etiquetas' , 'Etiquetas Produtos' )
	Return()

endif	
//BN 880673900 822171
/* valida se array pois dados */
	if len(aBrowse) < 1

			/* impress„o por codigo EAN  */
			if !Empty(cCodPro) 
				Do Case
					Case nTipo == 1
						For i := 1 to val(qtd)
							PCP037_E05()
						Next	

						/* limpa memoria objeo */
						PUTMV('MV_PCP038', cLPT)
						FreeObj(oDlg)

						/* carrega tela novamente */
						U_BRPCP038()


					Return()
				EndCase	

			else
				MsgInfo( 'Necess·rio Consultar uma OP ou Lote' , 'Etiquetas Produtos' )
				Return()
			endif	
	Endif

aString := strtokarr (cProduto, "-")
linha := val(aString[1])
    
/* loop na qtd de etiquetas a ser impressa */
For i := 1 to val(qtd)

	Do Case
	Case nTipo == 1

		/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
		# Impress„o de Etiquetas Zembras #
		ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
		PCP037_05(linha,i)

	Case nTipo == 2
		/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
		# Impress„o de Etiquetas 26x15mm(xarope) #
		ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
		if AllTrim(aBrowse[linha][1]) <> "**IDENTIF DE VOLUME**"
			PCP037_11(linha,i)
		Endif

	Case nTipo == 3

		/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
		# Impress„o de Etiquetas 44x15mm #
		ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
		PCP037_06(linha,i)

	Case nTipo == 4
		/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
		# Impress„o de Etiquetas 75x35mm #
		ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
		PCP037_07(linha,i)

	Case nTipo == 5

		/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
		# Impress„o de Etiquetas 100x69mm #
		ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
		PCP037_09(linha,i)

	EndCase
NEXT

/* limpa memoria objeo */
PUTMV('MV_PCP038', cLPT)
FreeObj(oDlg)

/* carrega tela novamente */
U_BRPCP038()

return


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
Local DtVenc,cEmb,UMEMB,cEmb_Bar
Local REG,C2_NUM,C2_ITEM,C2_SEQUEN

Cod           := AllTrim(aBrowse[linha][2])

/* 
	Quando B1_DESCLIN for diferente de branco pegar B1_DESCLIN
	*/

if !empty(AllTrim(aBrowse[linha][21]))
	ProdTxt    := AllTrim(aBrowse[linha][21])
else
	ProdTxt    := AllTrim(aBrowse[linha][4])
endif


/* Especifico para o BRPCP038 */
/*	Unid          := SUBSTR(aBrowse[linha][5],1,2) */
Unid          := SUBSTR(Alltrim(cQtVol),1,2)

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

	/* identifica embalagem */
	If len(Alltrim(Cod)) == 12
		

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



	CodBar        := cLote+cEmb_Bar+Unid+NcXidvol
	UMEMB         := UniMed(CodBar,Cod)
	
	MSCBPRINTER(cModelo, cLPT,,12,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBLOADGRF("SIGA.GRF")
	MSCBBEGIN(1,4)

	MSCBSAY(03,02 ,Prod, "N", "0", "025,025") // negrito
	MSCBSAY(70,02 ,cEmb, "N", "0", "025,025") // negrito
	MSCBSAY(03,05 ,"**Val.: "+ CValToChar(DtVenc)+"** IDENTIF VOL *", "N", "0", "025,025") // negrito
	
	MSCBLineH(00,10,190,3, 'B' )
	
	MSCBSAY(03,11,"COD:", "N", "0", "025,022") // negrito
	Cod = TRANSFORM(Cod, "@R XX 99.99.999-99")
	MSCBSAY(09,11,Cod, "N", "0", "025,022") // negrito
	MSCBSAY(57,11, AllTrim(UMEMB), "N", "0", "026,026") // negrito
	
//	MSCBWRITE("^FT470,145^BQN,4,4")         // Jose 14/03/2025
//	MSCBWRITE("^FH\^FDLA,"+cConteudo+"^FS")  //Jose 14/03/2025
	MSCBSAYBAR(14, 15,CodBar,"N","MB07",6, .F., .T., .F., ,2,03, .F., .F., "1", .T.) // Jose 06/03/2025
//	MSCBSAYBAR(18, 15,CodBar,"N","MB01",6, .F., .T., .F., ,3,02, .F., .F., "1", .T.) // Jose 14/03/2025

	MSCBEND()
	MSCBCLOSEPRINTER()

	UPD_XVOL(NcXidvol,REG,C2_NUM,C2_ITEM,C2_SEQUEN,cLote)
	

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
	
	/* 
	Quando B1_DESCLIN for diferente de branco pegar B1_DESCLIN
	*/

	if !empty(AllTrim(aBrowse[linha][21]))
		ProdTxt    := AllTrim(aBrowse[linha][21])
	else
		ProdTxt    := AllTrim(aBrowse[linha][4])
	endif
	
	/* Especifico para o BRPCP038 */
	/*	Unid          := SUBSTR(aBrowse[linha][5],1,2) */
	Unid          := SUBSTR(Alltrim(cQtVol),1,2)
	
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
	/*if mod(qtd,2)==0
		cColuna := 10
	else
		cColuna := 0
	endif*/

	MSCBPRINTER(cModelo, cLPT,,12,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBLOADGRF("SIGA.GRF")
	MSCBBEGIN(1,4)

	MSCBSAY(02+cColuna,02,Prod,"N","0","020,020")
	
	Cod = TRANSFORM(Cod, "@R XX 99.99.999-99")
	MSCBSAY(02+cColuna,06,Cod, "N", "0", "018,018")
	
	MSCBSAY(02+cColuna,08.5,Volume+UMEMB+" Lote: "+cLote, "N", "0","018,018") // negrito
	
	MSCBSAY(02+cColuna,11,"Val.: "+CValToChar(DtVenc), "N", "0", "018,018") // negrito
	
	if AllTrim(aBrowse[linha][1]) <> "**IDENTIF DE VOLUME**"
		MSCBSAYBAR(23+cColuna,5,CodBar,"N","MB04",7, .F., .T., .F., ,1,1, .F., .F., "1", .T.)
	Endif


	/* impress„o da segunda coluna */

	cColuna := 49

	MSCBSAY(02+cColuna,02,Prod,"N","0","020,020")
	
	MSCBSAY(02+cColuna,06,Cod, "N", "0", "018,018")
	
	MSCBSAY(02+cColuna,08.5,Volume+UMEMB+" Lote: "+cLote, "N", "0","018,018") // negrito
	
	MSCBSAY(02+cColuna,11,"Val.: "+CValToChar(DtVenc), "N", "0", "018,018") // negrito
	
	//if AllTrim(aBrowse[linha][1]) <> "**IDENTIF DE VOLUME**"
		MSCBSAYBAR(23+cColuna,5,CodBar,"N","MB04",7, .F., .T., .F., ,1,1, .F., .F., "1", .T.)
	//Endif


	

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
Static Function PCP037_07(linha,qtd)

Local cModelo := "ZEBRA"
Local Prod,ProdTxt,Cod,Unid,CodBar
Local Validade,Prevf,PrazoVali,Dias,cLote
Local DtVenc,cEmb,UMEMB
Local REG,C2_NUM,C2_ITEM,C2_SEQUEN




	Cod           := AllTrim(aBrowse[linha][2])

	/* 
	Quando B1_DESCLIN for diferente de branco pegar B1_DESCLIN
	*/

	if !empty(AllTrim(aBrowse[linha][21]))
		ProdTxt    := AllTrim(aBrowse[linha][21])
	else
		ProdTxt    := AllTrim(aBrowse[linha][4])
	endif
	
	/* Especifico para o BRPCP038 */
	/*	Unid          := SUBSTR(aBrowse[linha][5],1,2) */
	Unid          := SUBSTR(Alltrim(cQtVol),1,2)

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

/* identifica embalagem */
	If len(Alltrim(Cod)) == 12
		cEmb          := substr(Cod,11,2)
	Endif

	CodBar  := cLote+cEmb+Unid+NcXidvol
	UMEMB   := UniMed(CodBar,Cod)

	MSCBPRINTER(cModelo, cLPT,,12,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBLOADGRF("SIGA.GRF")
	MSCBBEGIN(1,4)

	MSCBSAY(03,02 ,Prod, "N", "0", "025,025") // negrito
	MSCBSAY(65,02 ,cEmb, "N", "0", "025,025") // negrito
	MSCBSAY(03,05 ,"**Val.: "+ CValToChar(DtVenc)+"** IDENTIF VOL *", "N", "0", "025,030") // negrito
	
	MSCBLineH(00,10,190,3, 'B' )
	
	MSCBSAY(03,11,"COD:", "N", "0", "025,025") // negrito

	Cod = TRANSFORM(Cod, "@R XX 99.99.999-99")

	MSCBSAY(10,11,Cod, "N", "0", "025,025") // negrito
	MSCBSAY(57,11, AllTrim(UMEMB), "N", "0", "026,026") // negrito

//	MSCBWRITE("^FT470,145^BQN,4,4")         // Jose 14/03/2025
//	MSCBWRITE("^FH\^FDLA,"+cConteudo+"^FS")  //Jose 14/03/2025
//	MSCBSAYBAR(14, 15,CodBar,"N","MB07",6, .F., .T., .F., ,2,03, .F., .F., "1", .T.) // Jose 06/03/2025
// 	MSCBSAYBAR(10,18,CodBar,"N","MB01",8, .F., .T., .F., ,3,3, .F., .F., "1", .T.) // Jose 14/03/2025   24/04/2025
 	MSCBSAYBAR(10,18,CodBar,"N","MB07",6, .F., .T., .F., ,2,01, .F., .F., "1", .T.) // Jose 24/04/2025
	MSCBEND()
	MSCBCLOSEPRINTER()

	UPD_XVOL(NcXidvol,REG,C2_NUM,C2_ITEM,C2_SEQUEN,cLote)


Return()





/*/{Protheus.doc} PCP037_09
Etiqueta Zebra de Volume
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
Local REG,C2_NUM,C2_ITEM,C2_SEQUEN




	Cod           := AllTrim(aBrowse[linha][2])
	
	/* 
	Quando B1_DESCLIN for diferente de branco pegar B1_DESCLIN
	*/

	if !empty(AllTrim(aBrowse[linha][21]))
		ProdTxt    := AllTrim(aBrowse[linha][21])
	else
		ProdTxt    := AllTrim(aBrowse[linha][4])
	endif
	
	/* Especifico para o BRPCP038 */
	/*	Unid          := SUBSTR(aBrowse[linha][5],1,2) */
	Unid          := SUBSTR(Alltrim(cQtVol),1,2)

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

	REG		      := aBrowse[linha][17]
	C2_NUM		  := aBrowse[linha][18]
	C2_ITEM		  := aBrowse[linha][19]
	C2_SEQUEN	  := aBrowse[linha][20]

	NcXidvol	  := StrZero( (val(cXidvol))+qtd , 4)

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

	CodBar  := cLote+cEmb+Unid+NcXidvol
	UMEMB   := UniMed(CodBar,Cod)


	MSCBPRINTER(cModelo, cLPT,,12,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBLOADGRF("SIGA.GRF")
	MSCBBEGIN(1,4)

	MSCBSAY(04,06 ,substr(Prod,1,24),"N", "0", "045,055") // negrito
	MSCBSAY(90,06 ,cEmb, "N", "0", "045,055") // negrito
	MSCBSAY(04,16 ,"**Val.: "+ CValToChar(DtVenc)+"** IDENTIF VOL *", "N", "0", "045,055") // negrito
	
	MSCBLineH(00,22,190,3, 'B' )
	MSCBSAY(04,26.5,"COD:", "N", "0", "035,035") // negrito
	Cod = TRANSFORM(Cod, "@R XX 99.99.999-99")
	MSCBSAY(15,26,Cod, "N", "0", "050,060") // negrito
	MSCBSAY(80,26,UMEMB, "N", "0", "040,040") // negrito

//	MSCBWRITE("^FT470,145^BQN,4,4")         // Jose 14/03/2025
//	MSCBWRITE("^FH\^FDLA,"+cConteudo+"^FS")  //Jose 14/03/2025
//	MSCBSAYBAR(14, 15,CodBar,"N","MB07",6, .F., .T., .F., ,2,03, .F., .F., "1", .T.) // Jose 06/03/2025
//	MSCBSAYBAR(9,35,CodBar,"N","MB01",12, .F., .T., .F., ,5,5, .F., .F., "1", .T.) // jose 14/03/2025   24/04/2025
	MSCBSAYBAR(9,35,CodBar,"N","MB07",06, .F., .T., .F., ,2,01, .F., .F., "1", .T.) // jose 24/04/2025


	MSCBEND()
	MSCBCLOSEPRINTER()

	UPD_XVOL(NcXidvol,REG,C2_NUM,C2_ITEM,C2_SEQUEN,cLote)


Return()


/*/{Protheus.doc} PCP037_11
Etiqueta Xarope
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
	
	/* 
	Quando B1_DESCLIN for diferente de branco pegar B1_DESCLIN
	*/

	if !empty(AllTrim(aBrowse[linha][21]))
		ProdTxt    := AllTrim(aBrowse[linha][21])
	else
		ProdTxt    := AllTrim(aBrowse[linha][4])
	endif
	
	/* Especifico para o BRPCP038 */
	/*	Unid          := SUBSTR(aBrowse[linha][5],1,2) */
	Unid          := SUBSTR(Alltrim(cQtVol),1,2)

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
	MSCBBEGIN(1,4)
	
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

Static Function ReportPrint(nTipo)

//local n      := 1
local i      := 1
//local linhas := len(aBrowse)
local qtd
local Prevf,UMEMB,Volume
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

If len(aBrowse) == 0
	MsgAlert('Impress„o disponivel apenas para etiquetas com o Lote !')
	return()
EndIf


oPrint := TMSPrinter():New(OemToAnsi('Etiqueta de produto'))
oPrint:SetPortrait()

oPrint:StartPage()  
nLin  := 0050
nRow1 := 0
cPage := 0
cont := 0

aString := strtokarr (cProduto, "-")
linha := val(aString[1])

Cod           := AllTrim(aBrowse[linha][2])
Cod 		  := TRANSFORM(Cod, "@R XX 99.99.999-99")

	/* 
	Quando B1_DESCLIN for diferente de branco pegar B1_DESCLIN
	*/

if !empty(AllTrim(aBrowse[linha][21]))
	ProdTxt    := AllTrim(aBrowse[linha][21])
else
	ProdTxt    := AllTrim(aBrowse[linha][4])
endif

/* Especifico para o BRPCP038 */
/*	Unid          := SUBSTR(aBrowse[linha][5],1,2) */
Unid          := SUBSTR(Alltrim(cQtVol),1,2)

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
qtd          := val(cQtde1)


/* loop na qtd de etiquetas a ser impressa */
For i        := 1 to qtd

Do Case
Case nTipo == 1

	/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	# Impress„o de Etiquetas Zembras #
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/

	CodBar        := cLote+cEmb+Unid+StrZero( (val(cXidvol))+qtd , 4)
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

Case nTipo == 2

	/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	# Impress„o de Etiquetas 26x15mm(xarope) #
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
	oPrint:Say(nLin,0050,OemToAnsi("LT "+cLote),oFont12n,,,,0)
	nLin += 050
	oPrint:Say(nLin,0050,OemToAnsi("Fab "+CValToChar(STOD(Prevf))),oFont12n,,,,0)
	nLin += 050
	oPrint:Say(nLin,0050,OemToAnsi("Val "+CValToChar(DtVenc)),oFont12n,,,,0)
	nLin  += 150

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

	CodBar        := cLote+cEmb+Unid+StrZero( (val(cXidvol))+qtd , 4)
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

Case nTipo == 5

	/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	# Impress„o de Etiquetas 100x69mm #
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/

	CodBar        := cLote+cEmb+Unid+StrZero( (val(cXidvol))+qtd , 4)
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
	
EndCase

	/* pula pagina */
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


/*/{Protheus.doc} PCP037_05
Etiqueta Zebra de Volume
@type function
@author neliedercorneta
@since 23/12/2021
@param linha, logical, linha
@param qtd, variant, qtd produtos
/*/
Static Function PCP037_E05()

Local cModelo := "ZEBRA"
Local Empresa := '01'
Local Cod,xCod,cEmb
Local cIDVOL

	
	/* identifica qual empresa È, nos padroes da Tabela CODBAR */
	if SUBSTR(xFilial("SB1"),1,2) = '01'
		Empresa := '01'
	endif

	if SUBSTR(xFilial("SB1"),1,2) = '06'		
		Empresa := '06'
	endif	
/*----  jOSE 17/10/2023------------------------------------------------------
	cQuery := " SELECT B1_CODBAR,B1_COD,B1_DESC,IDVOL "
	cQuery += " FROM "+RetSqlName("SB1")+"   "
	cQuery += " INNER JOIN CODBAR ON PRODUTO = B1_COD AND EMPRESA = "+Empresa+" "
	cQuery += " WHERE D_E_L_E_T_ = ''  "
	cQuery += " AND B1_FILIAL = '"+xFilial("SB1")+"'   " 
	cQuery += " AND B1_COD = '"+cProduto+"'"
------------------------------------------------------------------------------*/

//---  jOSE 17/10/2023------------------------------------------------------
	cQuery := " SELECT B1_CODBAR, B1_COD, B1_DESC, ZA1.ZA1_SEQCOD,IsNull(IDVOL,0)IDVOL "
	cQuery += " FROM "+RetSqlName("SB1")+" SB1  "
	cQuery += " INNER JOIN  "+RetSqlName("ZA1")+" ZA1 ON ZA1.ZA1_PRODUT = B1_COD AND ZA1.ZA1_FILIAL = '"+Empresa+"' "
	cQuery += " LEFT JOIN CODBAR ON PRODUTO = B1_COD AND EMPRESA = "+Empresa+" "
	cQuery += " WHERE SB1.D_E_L_E_T_ = ''  "
	cQuery += " AND B1_FILIAL = '"+xFilial("SB1")+"'   " 
	cQuery += " AND B1_COD = '"+cProduto+"'"
//------------------------------------------------------------------------------ 

	IF Select("TEMP") <> 0
			DbSelectArea("TEMP")
			DbCloseArea()
	ENDIF

	TCQuery cQuery New Alias "TEMP"

	Cod  := TEMP->B1_COD
	xCod := Cod
	Prod := TEMP->B1_DESC

	/* identifica embalagem */
	If len(Alltrim(Cod)) == 12
		/* 
		   Tratativa para produtos com inicio BM
		   Exemplo BM 00.23.157-01   	
		   Neste caso, n„o utilizar o codigo da embalagem e sim 157

		*/

		if substr(Cod,1,2) == "BM"
			cEmb          := substr(Cod,8,3)
			cEmb_Bar	  := substr(Cod,11,2)
		endif

			cEmb          := substr(Cod,11,2)
			cEmb_Bar	  := substr(Cod,11,2)
			
	Endif

	//cIDVOL := TEMP->IDVOL Ajustado Nelieder
	
	aIDVOL := TEMP->IDVOL
	cIDVOL := Val(TEMP->ZA1_SEQCOD) 

	If aIDVOL > cIDVOL
		cIDVOL := aIDVOL
	EndIf

	cIDVOL++
	CodBar	:= Alltrim(TEMP->B1_CODBAR)+AllTrim(StrZero(cIDVOL,6))
	/*CodBar        := cLote+cEmb+Unid+NcXidvol
	UMEMB         := UniMed(CodBar,Cod)*/
	
	MSCBPRINTER(cModelo, cLPT,,12,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBLOADGRF("SIGA.GRF")
	MSCBBEGIN(1,4)

	MSCBSAY(03,02 ,Prod, "N", "0", "025,025") // negrito
	MSCBSAY(70,02 ,cEmb, "N", "0", "025,025") // negrito
	MSCBSAY(03,05 ,"** IDENTIF VOL **", "N", "0", "025,025") // negrito
	
	MSCBLineH(00,10,190,3, 'B' )
	
	MSCBSAY(03,11,"COD:", "N", "0", "025,022") // negrito
	Cod = TRANSFORM(Cod, "@R XX 99.99.999-99")
	MSCBSAY(09,11,Cod, "N", "0", "025,022") // negrito
	
//	MSCBWRITE("^FT470,145^BQN,4,4")         // Jose 14/03/2025
//	MSCBWRITE("^FH\^FDLA,"+cConteudo+"^FS")  //Jose 14/03/2025
//	MSCBSAYBAR(14, 15,CodBar,"N","MB07",6, .F., .T., .F., ,2,03, .F., .F., "1", .T.) // Jose 06/03/2025
	MSCBSAYBAR(18, 15,CodBar,"N","MB01",6, .F., .T., .F., ,3,02, .F., .F., "1", .T.) // Jose 14/03/2025

	MSCBEND()
	MSCBCLOSEPRINTER()

	//cQry1 := "" Ajustado por Nelieder
	//cQry1 := "UPDATE CODBAR SET IDVOL = '"+str(cIDVOL)+"' WHERE (EMPRESA = '"+Empresa+"') AND (PRODUTO = '"+xCod+"') AND (CODBAR > '')"
    //TcSQLExec(cQry1)

	cQry1 := "" 
	cQry1 := "UPDATE "+RetSqlName("ZA1")+" SET ZA1_SEQCOD = '"+AllTrim(StrZero(cIDVOL,5))+"' WHERE (ZA1_FILIAL = '"+xFilial("ZA1")+"') AND (ZA1_PRODUT = '"+AllTrim(xCod)+"') AND (ZA1_GTIN > '')"
    TcSQLExec(cQry1)

Return()
