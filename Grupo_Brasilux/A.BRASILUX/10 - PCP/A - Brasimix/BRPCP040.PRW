#Include "Protheus.ch"
#Include "TopConn.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRPCP040  บAutor  ณ Nelieder Corneta  บ Data ณ  19/01/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Etiquetas de Mat.Prima (BrasTintas)                         ฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX TINTAS TษCNICAS LTDA.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
 
User Function  BRPCP040()

//Fontes
Private cFontUti  := "Tahoma"
Private oFontAno  := TFont():New(cFontUti, , -38)
Private oFontBtn  := TFont():New(cFontUti, , -14)
Private oFontBtnn  := TFont():New(cFontUti, , -14, ,.T.)
Private oFontSub  := TFont():New(cFontUti, , -16)
Private oFontSubN := TFont():New(cFontUti, , -20, , .T.)

//Tamanho da Janela
Private nJanLarg  := 700
Private nJanAltu  := 500
Private oLPT,cLPT

//Produto
Private cCodigo := SPACE(12)
Private oCodigo 

// Browse 
Private aBrowse := {}
Private oBrowse 

// Qtde
Private cQTDE := SPACE(4)
Private oQtde 

Private aLPT      :={}

DEFINE MSDIALOG oDlg TITLE "Etiqueta p/Mat. Prima" FROM 000, 000 TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL

@ 010, 010 SAY OemToAnsi("C๓digo Prod.: ") SIZE 080,009 PIXEL OF oDlg FONT oFontBtn
@ 008, 055 MSGET oCodigo VAR cCodigo PICTURE "@!" SIZE 070,010 COLOR CLR_BLUE F3 "SB1" PIXEL OF  oDlg FONT oFontBtn

@ 010, 150 SAY OemToAnsi("Qtde.: ") SIZE 080,009 PIXEL OF oDlg FONT oFontBtn
@ 008, 172 MSGET oQtde VAR cQtde PICTURE "@!" SIZE 050,010 COLOR CLR_BLUE PIXEL  OF  oDlg FONT oFontBtn



@ 005, 285 BUTTON oBtnFech PROMPT "Incluir" SIZE 060, 018 OF oDlg ACTION Incluir() FONT oFontBtn PIXEL

// Cria Browse
oBrowse  := TCBrowse():New(045, 010, 333, 160, , {'C๓d Produto', 'Nome Produto', 'Qtde' }, {50,170,10}, oDlg, , , , , {||lEditCell (@aBrowse, oBrowse, "999", 3)}, , oFontSub, , , , , .F., , .T., , .F., , ,)
aBrowse := {{ '' , '' , '' }}
oBrowse:nLinhas := 2

// Seta vetor para a browse
oBrowse:SetArray(aBrowse)

// Monta a linha a ser exibina no Browse
oBrowse:bLine  := {||{ aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAT,03], }}

@ 225, 010 MSCOMBOBOX oLPT VAR cLPT ITEMS aLPT SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL FONT oFontBtn
ListPort()

@ 220, 075 BUTTON oBtnFech PROMPT "Imprimir" SIZE 060, 018 OF oDlg ACTION Imprimir() FONT oFontBtn PIXEL
@ 220, 145 BUTTON oBtnFech PROMPT "Visualizar" SIZE 060, 018 OF oDlg ACTION ReportPrint() FONT oFontBtn PIXEL
@ 220, 215 BUTTON oBtnFech PROMPT "Apagar Tudo" SIZE 060, 018 OF oDlg ACTION apagartudo() FONT oFontBtn PIXEL
@ 220, 285 BUTTON oBtnFech PROMPT "Fechar" SIZE 060, 018 OF oDlg ACTION (oDlg:End()) FONT oFontBtn PIXEL

oDlg:lEscClose := .T.

ACTIVATE MSDIALOG oDlg CENTERED

Return


return()


Static Function incluir()


if empty(cQtde)
    MsgAlert('Favor informar a quantidade das Etiquetas', 'Aten็ใo')
    oQtde:SetFocus()
    return()
endif

if empty(cCodigo)
    MsgAlert('Favor informar o Codigo do Produto', 'Aten็ใo')
    oCodigo:SetFocus()
    return()
endif

cQuery := " SELECT SB1.B1_COD AS PRODUTO,SB1.B1_DESC AS NOME  "
cQuery += " FROM "+RetSqlName("SB1")+" SB1 WITH (NOLOCK)  "
cQuery += " WHERE (SB1.B1_FILIAL = '"+xFilial("SB1")+"') AND (SB1.D_E_L_E_T_ <> '*') AND  "
cQuery += " (SB1.B1_COD = '"+ALLTRIM(cCodigo)+"')  "

IF Select("TEMP") <> 0
	DbSelectArea("TEMP")
	DbCloseArea()
ENDIF

TCQuery cQuery New Alias "TEMP"

Count To nTotal 


If nTotal == 0
      MsgAlert('Produto nใo localizado!', 'Aten็ใo')
    return()
endif

TEMP->(dbGoTop())

if  empty(aBrowse[1][1]) 
    aBrowse := {}
endif    

While !TEMP->(EoF())

    aAdd(aBrowse,{ ;
			TEMP->PRODUTO,;
			TEMP->NOME,;
			cQtde;
			})


	TEMP->(DbSkip())
    
EndDo

// Cria Browse
oBrowse  := TCBrowse():New(045, 010, 333, 160, , {'C๓d Produto', 'Nome Produto', 'Qtde' }, {50,170,10}, oDlg, , , , , {||lEditCell (@aBrowse, oBrowse, "999", 3)}, , oFontSub, , , , , .F., , .T., , .F., , ,)

oBrowse:nLinhas := 2

// Seta vetor para a browse
oBrowse:SetArray(aBrowse)

// Monta a linha a ser exibina no Browse
oBrowse:bLine  := {||{ aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAT,03], }}
oBrowse:Refresh()



Return 

Static Function Imprimir()
local n,i     := 1
local linhas := len(aBrowse)
local qtd
local produto
local descricao
Local cModelo 	:= "ZEBRA"
local cLPT := "LPT1"

For n := 1 to linhas
    produto   := aBrowse[n][1]
    descricao := aBrowse[n][2]
    qtd       := aBrowse[n][3]
    
        For i := 1 to Val(qtd)
            /* imprimi etiqueta */
            MSCBPRINTER(cModelo, cLPT,,12,.F.,,,,,,.F.,)
            MSCBCHKSTATUS(.F.)
            MSCBLOADGRF("SIGA.GRF")
            MSCBBEGIN(1,4)

            //MSCBSAY(horizontal,vertical)
            MSCBSAY(021,15   ,produto  , "N", "0", "260,260") // negrito

            MSCBSAY(005,43   ,descricao, "N", "0", "035,035",,,,,.T.) // negrito
            MSCBSAY(005,48   ,"Usuแrio Sistema : "+PswChave(RetCodUsr()), "N", "0", "035,035",,,,,.T.) // negrito

            MSCBEND()
            MSCBCLOSEPRINTER()
    Next

    
Next

return

/*/{Protheus.doc} ListPort
Carrega Array com as portas disponiveis para impressใo
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

Static function apagartudo()

// Cria Browse
oBrowse  := TCBrowse():New(045, 010, 333, 160, , {'C๓d Produto', 'Nome Produto', 'Qtde' }, {50,170,10}, oDlg, , , , , {||lEditCell (@aBrowse, oBrowse, "999", 3)}, , oFontSub, , , , , .F., , .T., , .F., , ,)

oBrowse:nLinhas := 2
aBrowse := {}
aAdd(aBrowse,{'','',''})


// Seta vetor para a browse
oBrowse:SetArray(aBrowse)

// Monta a linha a ser exibina no Browse
oBrowse:bLine  := {||{ aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAT,03], }}
oBrowse:Refresh()

return


Static Function ReportPrint(nTipo)

local n,i      := 1
local linhas := len(aBrowse)
local qtd
//local Prevf,UMEMB,Volume
Local Letiq := 0
local produto
local descricao

Private oPrint
Private oFont10     := TFont():New('Arial',,10,,.F.,,,,.F.,.F.)
Private oFont10n    := TFont():New('Arial',,10,,.T.,,,,.F.,.F.)

Private oFont12     := TFont():New('Arial',,12,,.F.,,,,.F.,.F.)
Private oFont12n    := TFont():New('Arial',,12,,.T.,,,,.F.,.F.)

Private oFont15     := TFont():New('Arial',,15,,.F.,,,,.F.,.F.)
Private oFont15n    := TFont():New('Arial',,15,,.T.,,,,.F.,.F.)

Private oFont60     := TFont():New('Arial',,60,,.F.,,,,.F.,.F.)
Private oFont60n    := TFont():New('Arial',,60,,.T.,,,,.F.,.F.)


oPrint := TMSPrinter():New(OemToAnsi('Etiqueta de produto'))
oPrint:SetPortrait()

oPrint:StartPage()  
nLin  := 0050
nRow1 := 0
cPage := 0
cont := 0


For n := 1 to linhas

    produto   := aBrowse[n][1]
    descricao := aBrowse[n][2]
    qtd       := aBrowse[n][3]
    
        For i := 1 to Val(qtd)
           	oPrint:Say(nLin,0050,OemToAnsi(produto),oFont60n,,,,0)
            nLin += 200
            oPrint:Say(nLin,0050,OemToAnsi(descricao),oFont15n,,,,0)
            nLin += 150
            oPrint:Say(nLin,0050,"Usuแrio Sistema : "+PswChave(RetCodUsr()),oFont10,,,,0)
            nLin += 060
            oPrint:Line (nLin,0010,nLin,850)
            nLin += 060

            
	/* pula pagina */
	if nLin >= 3200
		oPrint:EndPage()
		cPage := 0
		nRow1 := 0
		nLin  := 0050
		Letiq := 0
	endif 
         Next

        
	/* pula pagina */
	if nLin >= 3200
		oPrint:EndPage()
		cPage := 0
		nRow1 := 0
		nLin  := 0050
		Letiq := 0
	endif  

Next


	






oPrint:Preview()
oPrint:end()

return
