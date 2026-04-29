#Include "Protheus.ch"
#Include "TopConn.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRPCP042  บAutor  ณ Nelieder Corneta  บ Data ณ  10/03/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Vendas/Faturamento por Representante                        ฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX TINTAS TษCNICAS LTDA.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
 
User Function  BRPCP042()

//Fontes
Private cFontUti  := "Tahoma"
Private oFontAno  := TFont():New(cFontUti, , -38)
Private oFontBtn  := TFont():New(cFontUti, , -14)
Private oFontSub  := TFont():New(cFontUti, , -16)
Private oFontSubN := TFont():New(cFontUti, , -20, , .T.)

//Tamanho da Janela
Private nJanLarg  := 730
Private nJanAltu  := 400

Private oEmissa1
Private cEmissa1 := cTod("  /  /  ")


Private oEmissa2
Private cEmissa2 := cTod("  /  /  ")

Private pEmissa1


/* define padrใo de data */
Set(_SET_DATEFORMAT, 'dd/mm/yy' )

DEFINE MSDIALOG oDlg TITLE "Vendas/Faturamento por Representante" FROM 000, 000 TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL

/*@ 005, 010 SAY  OemToAnsi("Emissใo Ped de:")  SIZE 045,009  PIXEL  OF oDlg FONT oFontBtn
@ 015, 005 MSGET oEmissa1 VAR cEmissa1 SIZE 055,010 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn


@ 005, 075 SAY OemToAnsi("At้ a Emissใo: ") SIZE 040,009 PIXEL OF oDlg FONT oFontBtn
@ 015, 075 MSGET oEmissa2 VAR cEmissa2 SIZE 055,010 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn

@ 005, 150 SAY OemToAnsi("Do Repres.: ") SIZE 045,009 PIXEL OF oDlg FONT oFontBtn
@ 015, 150 MSGET oEmissa1 VAR cEmissa1 SIZE 055,010 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn

@ 005, 225 SAY OemToAnsi("at้ o Repres: ") SIZE 040,009 PIXEL OF oDlg FONT oFontBtn
@ 015, 225 MSGET oEmissa2 VAR cEmissa2 SIZE 055,010 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn*/

MsgAlert(FWCodEmp()) //01
MsgAlert(FWCodFil()) //010101
MsgAlert(FWGrpCompany()) //01



/* habilita fechar tela no botใo esc */
oDlg:lEscClose := .T.

ACTIVATE MSDIALOG oDlg CENTERED


return()
