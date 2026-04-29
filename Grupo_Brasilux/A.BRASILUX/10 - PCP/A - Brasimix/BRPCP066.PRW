#Include "Protheus.ch"
#Include "TopConn.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRPCP041  บAutor  ณ Nelieder Corneta  บ Data ณ  15/05/2023 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ  Etiqueta MP recebimento                                    ฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX TINTAS TษCNICAS LTDA.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function  BRPCP066()

//Fontes
Private cFontUti  := "Tahoma"
Private oFontAno  := TFont():New(cFontUti, , -38)
Private oFontBtn  := TFont():New(cFontUti, , -14)
Private oFontBtnn  := TFont():New(cFontUti, , -14, ,.T.)
Private oFontSub  := TFont():New(cFontUti, , -16)
Private oFontSubN := TFont():New(cFontUti, , -20, , .T.)

//Tamanho da Janela
Private nJanLarg  := 800
Private nJanAltu  := 550

// Browse 
Private aBrowse := {}
Private oBrowse 

//Pedido
Private cPedido := SPACE(9)
Private oPedido 

// NF
Private cLote := SPACE(18)
Private oLote 


Private oLPT,cLPT
Private aLPT      :={}

DEFINE MSDIALOG oDlg TITLE "Etiquetas MP" FROM 000, 000 TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL

@ 010, 010 SAY OemToAnsi("Pedido de Compra: ") SIZE 080,009 PIXEL OF oDlg FONT oFontBtn
@ 008, 075 MSGET oPedido VAR cPedido PICTURE "@!" SIZE 070,010 COLOR CLR_BLUE F3 "SC7" PIXEL OF  oDlg FONT oFontBtn

@ 030, 010 SAY OemToAnsi("Lote.: ") SIZE 080,012 PIXEL OF oDlg FONT oFontBtn
@ 028, 045 MSGET oLote VAR cLote PICTURE "@!" SIZE 100,010 COLOR CLR_BLUE  PIXEL OF  oDlg FONT oFontBtn

@ 005, 285 BUTTON oBtnFech PROMPT "Incluir" SIZE 060, 018 OF oDlg ACTION Incluir() FONT oFontBtn PIXEL

// Cria Browse
oBrowse    := TCBrowse():New(065, 010, 380, 160, , {'C๓d Produto', 'Nome Prod','Qtde Etiq' }, {50,140,40}, oDlg, , , , ,{||lEditCell (@aBrowse, oBrowse, "999", 3)} , , oFontSub, , , , , .F., , .T., , .F., , ,)

aBrowse := {{ '' , '' , '' }}
oBrowse:nLinhas := 2

// Seta vetor para a browse
oBrowse:SetArray(aBrowse)

// Monta a linha a ser exibina no Browse
oBrowse:bLine  := {||{ aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAT,03], }}




@ 245, 010 MSCOMBOBOX oLPT VAR cLPT ITEMS aLPT SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL FONT oFontBtn
ListPort()


@ 240, 075 BUTTON oBtnFech PROMPT "Imprimir" SIZE 060, 018 OF oDlg ACTION Imprimir() FONT oFontBtn PIXEL
//@ 240, 145 BUTTON oBtnFech PROMPT "Visualizar" SIZE 060, 018 OF oDlg ACTION ReportPrint() FONT oFontBtn PIXEL
@ 240, 215 BUTTON oBtnFech PROMPT "Apagar Tudo" SIZE 060, 018 OF oDlg ACTION apagartudo('2') FONT oFontBtn PIXEL
@ 240, 285 BUTTON oBtnFech PROMPT "Fechar" SIZE 060, 018 OF oDlg ACTION (oDlg:End()) FONT oFontBtn PIXEL

oDlg:lEscClose := .T.

ACTIVATE MSDIALOG oDlg CENTERED

Return


return()


static Function Incluir 

    if Empty(cPedido) 
        MsgAlert('Aten็ใo, informar apenas Nบ do Pedido!')
    endif
    
    
    if !Empty(cPedido)
        PedCompra()
        return()
    Endif



    
    
return()



static Function PedCompra()

apagartudo('1')

cQuery := " SELECT C7_PRODUTO,C7_DESCRI,C7_NUM,C7_QUANT,A2_NOME,C7_EMISSAO FROM "+RetSqlName("SC7")+" SC7"
cQuery += " INNER JOIN "+RetSqlName("SA2")+" SA2 ON A2_COD = C7_FORNECE AND SA2.D_E_L_E_T_ = '' "
cQuery += " WHERE SC7.D_E_L_E_T_ = '' AND C7_NUM = '"+cPedido+"' AND C7_FILIAL = '"+xFilial("SC7")+"'  "
cQuery += " ORDER BY SC7.C7_NUM DESC "

IF Select("TEMP") <> 0
	DbSelectArea("TEMP")
	DbCloseArea()
ENDIF

TCQuery cQuery New Alias "TEMP"

Count To nTotal 


If nTotal == 0
      MsgAlert('Nenhum Registro localizado!', 'Aten็ใo')
    return()
endif

TEMP->(dbGoTop())

if  empty(aBrowse[1][1]) 
    aBrowse := {}
endif 

While !TEMP->(EoF())

    aAdd(aBrowse,{ ;
			TEMP->C7_PRODUTO,;
			TEMP->C7_DESCRI,;
            PADR(TEMP->C7_QUANT,3),;
            TEMP->C7_NUM,;
            TEMP->A2_NOME,;
            TEMP->C7_EMISSAO;
			})


	TEMP->(DbSkip())
    
EndDo

// Seta vetor para a browse
oBrowse:SetArray(aBrowse)

// Monta a linha a ser exibina no Browse
oBrowse:bLine  := {||{ aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAT,03], }}
oBrowse:Refresh()



return

Static Function Imprimir()


local n,i     := 1
local linhas := len(aBrowse)
local qtd
local produto,pedido,razao
local descricao
Local cModelo 	:= "ZEBRA"
Local Fifo

If (linhas <= 0) .OR. (Empty(aBrowse[1][1]))
     MsgAlert("Favor Adicionar Pedido!")
     return
EndIf

For n := 1 to linhas
    produto   := aBrowse[n][1]
    descricao := aBrowse[n][2]
    qtd       := aBrowse[n][3]
    pedido    := aBrowse[n][4]
    razao     := aBrowse[n][5]
    emissao   := SToD(aBrowse[n][6])
    Fifo      := MesAbre(MONTH(dDataBase))+"/"+SubStr(Year2Str(dDataBase),3,2)
    
        For i := 1 to Val(qtd)
           
            MSCBPRINTER(cModelo, cLPT,,12,.F.,,,,,,.F.,)
            MSCBCHKSTATUS(.F.)
            MSCBLOADGRF("SIGA.GRF")
            MSCBBEGIN(1,4)

            
            //Linha topo
            MSCBLineH(02,02,098,2,'B')
            
            // linha Down
            MSCBLineH(02,68,098,2,'B')

            // linha 1 Vertical
            //MSCBLineV(inicio_H,inicio_v,fim_h,tamho_linha,'B')
            MSCBLineV (02       ,02      ,68   ,    2      ,'B')

            // linha 2 Vertical
            MSCBLineV (98       ,02      ,68   ,    2      ,'B')

            //Quadrado
            MSCBLineV (70       ,02      ,15   ,    2      ,'B')
            //MSCBLineH(InicioH,AlturaV,FimH,,)       
            MSCBLineH(70,15,98,2,'B')
            

            //MSCBSAY(horizontal,vertical)
            MSCBSAY(076,04   ,"M๊s/Ano/FIFO"  , "N", "0", "025,025") // negrito
            
            MSCBSAY(074,08   ,Fifo  , "N", "0", "060,060") // negrito

            MSCBSAY(005,05   ,produto  , "N", "0", "210,210") // negrito

            MSCBSAY(005,32   ,descricao, "N", "0", "035,035",,,,,.T.) // negrito

            MSCBSAY(005,42   ,"Status:", "N", "0", "025,025",,,,,.T.) // negrito

            MSCBSAY(020,42   ,"Aprovado:", "N", "0", "025,025",,,,,.T.) // negrito
            
            
            //Aprovado
            MSCBLineV (34       ,41      ,45   ,    2      ,'B')
            MSCBLineV (38       ,41      ,45   ,    2      ,'B')
            
            //MSCBLineH(InicioH,AlturaV,FimH,,)       
            MSCBLineH(34,41,38,2,'B')
            MSCBLineH(34,45,38,2,'B')

            //Reprovado
            MSCBLineV (66       ,41      ,45   ,    2      ,'B')
            MSCBLineV (70       ,41      ,45   ,    2      ,'B')

            //MSCBLineH(InicioH,AlturaV,FimH,,)       
            MSCBLineH(66,41,70,2,'B')
            MSCBLineH(66,45,70,2,'B')

            MSCBSAY(050,42   ,"Reprovado:", "N", "0", "025,025",,,,,.T.) // negrito
            
            MSCBSAY(005,53   ,"Fornec:"+razao , "N", "0", "025,025",,,,,.T.) // negrito
                
            MSCBSAY(005,58   ,"Data: "+DToC(emissao), "N", "0", "025,025",,,,,.T.) // negrito
            MSCBSAY(005,63   ,"Lote : "+cLote, "N", "0", "025,025",,,,,.T.) // negrito
            
            
            MSCBEND()
            MSCBCLOSEPRINTER()
    Next

    
Next

return

Static function apagartudo(tipo)

    if tipo == '2'
        cPedido := SPACE(9)
        cLote   := SPACE(9)
    endif

    aBrowse := {}
    aAdd(aBrowse,{'','',''})

    // Seta vetor para a browse
    oBrowse:SetArray(aBrowse)

    // Monta a linha a ser exibina no Browse
    oBrowse:bLine  := {||{ aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAT,03], }}
    oBrowse:Refresh()

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



Static Function MesAbre(nMes)
Local lRetorno

 Do Case
        Case nMes == 1
             lRetorno := "JAN"
        Case nMes == 2
             lRetorno := "FEV"
        Case nMes == 3
             lRetorno := "MAR"             
        Case nMes == 4
             lRetorno := "ABR"                          
        Case nMes == 5
             lRetorno := "MAI"
        Case nMes == 6
             lRetorno := "JUN"
        Case nMes == 7
             lRetorno := "JUL"             
        Case nMes == 8
             lRetorno := "AGO"                          
        Case nMes == 9
             lRetorno := "SET"
        Case nMes == 10
             lRetorno := "OUT"
        Case nMes == 11
             lRetorno := "NOV"             
        Case nMes == 12
             lRetorno := "DEZ"                                                    

EndCase



return(lRetorno)

