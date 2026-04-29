#Include "Protheus.ch"
#Include "TopConn.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRPCP043  บAutor  ณ Nelieder Corneta  บ Data ณ  16/03/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Vendas/Faturamento por Representante                        ฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX TINTAS TษCNICAS LTDA.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

 
User Function  BRPCP060()

//Fontes
Private cFontUti  := "Tahoma"
Private oFontAno  := TFont():New(cFontUti, , -38)
Private oFontBtn  := TFont():New(cFontUti, , -14)
Private oFontSub  := TFont():New(cFontUti, , -16)
Private oFontSubN := TFont():New(cFontUti, , -20, , .T.)

//Tamanho da Janela
Private nJanLarg  := 730
Private nJanAltu  := 400

Private oNped
Private cNped := SPACE(6)




/* define padrรฃo de data */
Set(_SET_DATEFORMAT, 'dd/mm/yy' )

DEFINE MSDIALOG oDlg TITLE "Etiquetas de Volume Especificos" FROM 000, 000 TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL

@ 005, 010 SAY  OemToAnsi("Nบ Pedido")  SIZE 045,009  PIXEL  OF oDlg FONT oFontBtn
@ 015, 005 MSGET oNped VAR cNped SIZE 055,010 COLOR CLR_BLUE PIXEL ON CHANGE PCP060_01(cNped) OF oDlg FONT oFontBtn

// Cria Browse
oBrowse  := TCBrowse():New(035, 005, 350, 120, , {'Produto', 'Descri็ใo', 'Qtde Etiq.' }, {130,50,10}, oDlg, , , , , {||lEditCell (@aBrowse, oBrowse, "999", 3)}, , oFontSub, , , , , .F., , .T., , .F., , ,)
aBrowse := {{ '' , '' , '' }}

// Seta vetor para a browse
oBrowse:SetArray(aBrowse)

// Monta a linha a ser exibina no Browse
oBrowse:bLine  := {||{ aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAT,03], }}


/*@ 005, 075 SAY OemToAnsi("Atรฉ a Emissรฃo: ") SIZE 040,009 PIXEL OF oDlg FONT oFontBtn
@ 015, 075 MSGET oEmissa2 VAR cEmissa2 SIZE 055,010 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn

@ 005, 150 SAY OemToAnsi("Do Repres.: ") SIZE 045,009 PIXEL OF oDlg FONT oFontBtn
@ 015, 150 MSGET oEmissa1 VAR cEmissa1 SIZE 055,010 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn

@ 005, 225 SAY OemToAnsi("atรฉ o Repres: ") SIZE 040,009 PIXEL OF oDlg FONT oFontBtn
@ 015, 225 MSGET oEmissa2 VAR cEmissa2 SIZE 055,010 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn*/


@ 175,004 BUTTON oBtnFech PROMPT "Imprimir" SIZE 060, 018 OF oDlg ACTION PCP038_05(nTipo,cQtde1) FONT oFontBtn PIXEL
@ 175,135 BUTTON oBtnFech PROMPT "Fechar" SIZE 060, 018 OF oDlg ACTION (oDlg:End()) FONT oFontBtn PIXEL

/* habilita fechar tela no botรฃo esc */
oDlg:lEscClose := .T.

ACTIVATE MSDIALOG oDlg CENTERED


return()

Static Function PCP060_01(xNped)

MsgAlert(xNped)


return
