#Include "Protheus.ch"
#Include "TopConn.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRPCP041  บAutor  ณ Nelieder Corneta  บ Data ณ  19/01/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Etiquetas para Palets Entrada MP                            ฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX TINTAS TษCNICAS LTDA.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function  BRPCP041()

//Fontes
Private cFontUti  := "Tahoma"
Private oFontAno  := TFont():New(cFontUti, , -38)
Private oFontBtn  := TFont():New(cFontUti, , -14)
Private oFontBtnn  := TFont():New(cFontUti, , -14, ,.T.)
Private oFontSub  := TFont():New(cFontUti, , -16)
Private oFontSubN := TFont():New(cFontUti, , -20, , .T.)

//Tamanho da Janela
Private nJanLarg  := 700
Private nJanAltu  := 550

// Browse 
Private aBrowse := {}
Private oBrowse 

//Pedido
Private cPedido := SPACE(9)
Private oPedido 

// NF
Private cNF := SPACE(9)
Private oNF 

// NF
Private cSerie := SPACE(3)
Private oSerie 

// Fornecedor
Private oFornecedor,cFornecedor
Private aFornecedor :={}

//Data
Private oData 
Private cData := cTod("  /  /  ")

DEFINE MSDIALOG oDlg TITLE "Etiquetas para Palets Entrada MP" FROM 000, 000 TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL

@ 010, 010 SAY OemToAnsi("Pedido de Compra: ") SIZE 080,009 PIXEL OF oDlg FONT oFontBtn
@ 008, 075 MSGET oPedido VAR cPedido PICTURE "@!" SIZE 070,010 COLOR CLR_BLUE F3 "SC7" PIXEL OF  oDlg FONT oFontBtn

@ 030, 010 SAY OemToAnsi("Nro NF.: ") SIZE 080,009 PIXEL OF oDlg FONT oFontBtn
@ 028, 045 MSGET oNF VAR cNF PICTURE "@!" SIZE 050,010 COLOR CLR_BLUE F3 "SF2" PIXEL  OF  oDlg FONT oFontBtn

@ 030, 100 SAY OemToAnsi("S้rie.: ") SIZE 080,009 PIXEL OF oDlg FONT oFontBtn
@ 028, 122 MSGET oSerie VAR cSerie PICTURE "@!" SIZE 015,010 COLOR CLR_BLUE PIXEL  OF  oDlg FONT oFontBtn

@ 030, 160 SAY OemToAnsi("Fornecedor.: ") SIZE 080,009 PIXEL OF oDlg FONT oFontBtn
@ 028, 200 MSCOMBOBOX oFornecedor VAR cFornecedor ITEMS aFornecedor SIZE 145, 007 OF oDlg COLORS 0, 16777215 PIXEL FONT oFontBtn

@ 050, 010 SAY OemToAnsi("Data.: ") SIZE 080,009 PIXEL OF oDlg FONT oFontBtn
@ 048, 045 MSGET oData VAR cData PICTURE "@!" SIZE 050,010 COLOR CLR_BLUE PIXEL  OF  oDlg FONT oFontBtn


@ 005, 285 BUTTON oBtnFech PROMPT "Incluir" SIZE 060, 018 OF oDlg ACTION Zebra() FONT oFontBtn PIXEL

// Cria Browse
oBrowse  := TCBrowse():New(065, 010, 333, 160, , {'C๓d Produto', 'Nome Prod', 'Qtde Palets' , 'Obs' }, {50,130,20,20}, oDlg, , , , , {||lEditCell (@aBrowse, oBrowse, "999", 3)}, , oFontSub, , , , , .F., , .T., , .F., , ,)
aBrowse := {{ '' , '' , '' , '' }}

// Seta vetor para a browse
oBrowse:SetArray(aBrowse)

// Monta a linha a ser exibina no Browse
oBrowse:bLine  := {||{ aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAT,03],aBrowse[oBrowse:nAT,04], }}



@ 240, 075 BUTTON oBtnFech PROMPT "Imprimir" SIZE 060, 018 OF oDlg ACTION ReportPrint() FONT oFontBtn PIXEL
@ 240, 145 BUTTON oBtnFech PROMPT "Visualizar" SIZE 060, 018 OF oDlg ACTION ReportPrint() FONT oFontBtn PIXEL
@ 240, 215 BUTTON oBtnFech PROMPT "Apagar Tudo" SIZE 060, 018 OF oDlg ACTION ReportPrint() FONT oFontBtn PIXEL
@ 240, 285 BUTTON oBtnFech PROMPT "Fechar" SIZE 060, 018 OF oDlg ACTION (oDlg:End()) FONT oFontBtn PIXEL

oDlg:lEscClose := .T.

ACTIVATE MSDIALOG oDlg CENTERED

Return


return()
