#Include "Protheus.ch"
#Include "TopConn.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRPCP041  บAutor  ณ Nelieder Corneta  บ Data ณ  19/01/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ  Palets Entrada MP                                         ฑฑ
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
Private nJanLarg  := 800
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
Private cData := dDataBase



Private oLPT,cLPT
Private aLPT      :={}

DEFINE MSDIALOG oDlg TITLE "Etiquetas para Palets Entrada MP" FROM 000, 000 TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL

@ 010, 010 SAY OemToAnsi("Pedido de Compra: ") SIZE 080,009 PIXEL OF oDlg FONT oFontBtn
@ 008, 075 MSGET oPedido VAR cPedido PICTURE "@!" SIZE 070,010 COLOR CLR_BLUE F3 "SC7" PIXEL OF  oDlg FONT oFontBtn

@ 030, 010 SAY OemToAnsi("Nro NF.: ") SIZE 080,009 PIXEL OF oDlg FONT oFontBtn
@ 028, 045 MSGET oNF VAR cNF PICTURE "@!" SIZE 050,010 COLOR CLR_BLUE F3 "SF2" PIXEL ON CHANGE IncFor() OF  oDlg FONT oFontBtn

@ 030, 110 SAY OemToAnsi("S้rie.: ") SIZE 080,009 PIXEL OF oDlg FONT oFontBtn
@ 028, 150 MSGET oSerie VAR cSerie PICTURE "@!" SIZE 015,010 COLOR CLR_BLUE PIXEL ON CHANGE IncFor()  OF  oDlg FONT oFontBtn

@ 050, 010 SAY OemToAnsi("Data.: ") SIZE 080,009 PIXEL OF oDlg FONT oFontBtn
@ 048, 045 MSGET oData VAR cData PICTURE "@!" SIZE 050,010 COLOR CLR_BLUE PIXEL  OF  oDlg FONT oFontBtn

@ 050, 110 SAY OemToAnsi("Fornecedor.: ") SIZE 080,009 PIXEL OF oDlg FONT oFontBtn
@ 048, 150 MSCOMBOBOX oFornecedor VAR cFornecedor ITEMS aFornecedor SIZE 230, 007 OF oDlg COLORS 0, 16777215 PIXEL FONT oFontBtn


@ 005, 285 BUTTON oBtnFech PROMPT "Incluir" SIZE 060, 018 OF oDlg ACTION Incluir() FONT oFontBtn PIXEL

// Cria Browse
oBrowse  := TCBrowse():New(065, 010, 380, 160, , {'C๓d Produto', 'Nome Prod', 'Qtde Palets', 'Qtde Etiq' , 'Obs' }, {50,140,40,40,40}, oDlg, , , , , , , oFontSub, , , , , .F., , .T., , .F., , ,)
oBrowse:blDblClick:= {|| editaTRB(@aBrowse)}

aBrowse := {{ '' , '' , '' , '', '' }}
oBrowse:nLinhas := 2

// Seta vetor para a browse
oBrowse:SetArray(aBrowse)

// Monta a linha a ser exibina no Browse
oBrowse:bLine  := {||{ aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAT,03],aBrowse[oBrowse:nAT,04],,aBrowse[oBrowse:nAT,05], }}


@ 245, 010 MSCOMBOBOX oLPT VAR cLPT ITEMS aLPT SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL FONT oFontBtn
ListPort()


@ 240, 075 BUTTON oBtnFech PROMPT "Imprimir" SIZE 060, 018 OF oDlg ACTION Imprimir() FONT oFontBtn PIXEL
@ 240, 145 BUTTON oBtnFech PROMPT "Visualizar" SIZE 060, 018 OF oDlg ACTION ReportPrint() FONT oFontBtn PIXEL
@ 240, 215 BUTTON oBtnFech PROMPT "Apagar Tudo" SIZE 060, 018 OF oDlg ACTION apagartudo('2') FONT oFontBtn PIXEL
@ 240, 285 BUTTON oBtnFech PROMPT "Fechar" SIZE 060, 018 OF oDlg ACTION (oDlg:End()) FONT oFontBtn PIXEL

oDlg:lEscClose := .T.

ACTIVATE MSDIALOG oDlg CENTERED

Return


return()


static Function Incluir 

    if !Empty(cPedido) .AND. !Empty(cNF)
        MsgAlert('Aten็ใo, informar apenas Nบ do Pedido ou Nota Fiscal !')
    endif
    
    
    if !Empty(cPedido)
        PedCompra()
        return()
    Endif

    if !Empty(cNF)
        //IncFor()
        incNfe()
        return()
    Endif


    
    
return()



static Function PedCompra()

apagartudo('1')

cQuery := " SELECT C7_PRODUTO,C7_DESCRI,C7_NUM FROM SC7010 WHERE D_E_L_E_T_ = ''   "
cQuery += " AND C7_NUM = '"+cPedido+"' AND C7_FILIAL = '"+xFilial("SC7")+"'  "
cQuery += " ORDER BY SC7010.C7_NUM DESC "

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
			PADR(,3),;
            PADR(,3),;
            PADR(,20),;
            TEMP->C7_NUM,;
            '';
			})


	TEMP->(DbSkip())
    
EndDo

// Seta vetor para a browse
oBrowse:SetArray(aBrowse)

// Monta a linha a ser exibina no Browse
oBrowse:bLine  := {||{ aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAT,03],aBrowse[oBrowse:nAT,04],aBrowse[oBrowse:nAT,05], }}
oBrowse:Refresh()



return


Static function IncFor()

local fornecec

/* consula dados por nf */
cQuery := " SELECT D1_FORNECE,D1_COD,B1_DESC,RAZAO = (CASE WHEN A2_NOME IS NULL THEN A1_NOME ELSE A2_NOME END),D1_DOC,"
cQuery += " CASE WHEN D1_DTDIGIT > '' THEN D1_DTDIGIT ELSE D1_EMISSAO END AS D1_EMISSAO,D1_PEDIDO"
cQuery += " FROM "+RetSqlName("SD1")+" SD1 "
cQuery += " INNER JOIN "+RetSqlName("SB1")+" B1 ON B1_COD = D1_COD AND B1.D_E_L_E_T_ = '' AND B1_FILIAL = D1_FILIAL"
cQuery += " LEFT OUTER JOIN "+RetSqlName("SA2")+" SA2 WITH (NOLOCK) ON (SA2.D_E_L_E_T_ <> '*') AND (D1_FORNECE = A2_COD)  "
cQuery += " LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (D1_FORNECE = A1_COD)  "
cQuery += " WHERE D1_DOC = '"+ALLTRIM(cNF)+"' AND D1_SERIE = '"+ALLTRIM(cSerie)+"' AND D1_FILIAL = '"+xFilial("SB1")+"' "

IF Select("TMP") <> 0
	DbSelectArea("TMP")
	DbCloseArea()
ENDIF

TCQuery cQuery New Alias "TMP" 

Count To nTotal 

cFornecedor := ''
aFornecedor := {}

If nTotal == 0
      //MsgAlert('Nenhum Registro localizad!', 'Aten็ใo')
      cFornecedor := ''
      aFornecedor := {}
      oFornecedor:SetItems(aFornecedor)
    return()
endif

TMP->(dbGoTop())

/* carrega fornecedor  */
fornecec := TMP->RAZAO
aAdd(aFornecedor,alltrim(TMP->RAZAO)+' # '+alltrim(TMP->D1_FORNECE)+' # '+alltrim(TMP->D1_EMISSAO))


While !TMP->(EoF()) 

   if fornecec <> TMP->RAZAO
     aAdd(aFornecedor,alltrim(TMP->RAZAO)+' # '+alltrim(TMP->D1_FORNECE)+' # '+alltrim(TMP->D1_EMISSAO))
   endif  

   fornecec := TMP->RAZAO

   TMP->(DbSkip())

EndDo    

oFornecedor:SetItems(aFornecedor)

return() 

STATIC FUNCTION incNfe()
local fornecec,aString

apagartudo('1')

aString := strtokarr (cFornecedor, "#")

if len(aString) == 0
    return
endif    


fornecec := aString[2]
cData := STOD(alltrim(aString[3]))

/* consula dados por nf */
cQuery := " SELECT D1_FORNECE,D1_COD,B1_DESC,RAZAO = (CASE WHEN A2_NOME IS NULL THEN A1_NOME ELSE A2_NOME END),D1_DOC,D1_PEDIDO,"
cQuery += " CASE WHEN D1_DTDIGIT > '' THEN D1_DTDIGIT ELSE D1_EMISSAO END AS D1_EMISSAO,D1_PEDIDO"
cQuery += " FROM "+RetSqlName("SD1")+" SD1 "
cQuery += " INNER JOIN "+RetSqlName("SB1")+" B1 ON B1_COD = D1_COD AND B1.D_E_L_E_T_ = '' AND B1_FILIAL = D1_FILIAL"
cQuery += " LEFT OUTER JOIN "+RetSqlName("SA2")+" SA2 WITH (NOLOCK) ON (SA2.D_E_L_E_T_ <> '*') AND (D1_FORNECE = A2_COD)  "
cQuery += " LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (D1_FORNECE = A1_COD)  "
cQuery += " WHERE D1_DOC = '"+ALLTRIM(cNF)+"' AND D1_SERIE = '"+ALLTRIM(cSerie)+"' AND D1_FILIAL = '"+xFilial("SB1")+"' "
cQuery += " AND (D1_FORNECE = '"+ALLTRIM(fornecec)+"' )  "

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

cData := STOD(TEMP->D1_EMISSAO)

if  empty(aBrowse[1][1]) 
    aBrowse := {}
endif 

While !TEMP->(EoF())

    aAdd(aBrowse,{ ;
			TEMP->D1_COD,;
			TEMP->B1_DESC,;
			PADR(,3),;
            PADR(,3),;
            PADR(,20),;
            TEMP->D1_PEDIDO,;
            TEMP->D1_DOC;
			})


	TEMP->(DbSkip())
    
EndDo

// Seta vetor para a browse
oBrowse:SetArray(aBrowse)

// Monta a linha a ser exibina no Browse
oBrowse:bLine  := {||{ aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAT,03],aBrowse[oBrowse:nAT,04],aBrowse[oBrowse:nAT,05], }}


return()


Static Function Imprimir()


local n,i     := 1
local linhas := len(aBrowse)
local qtd,obs
local produto,pedido,doc
local descricao
Local cModelo 	:= "ZEBRA"
Local nCarac
Local cposic

For n := 1 to linhas
    produto   := aBrowse[n][1]
    descricao := aBrowse[n][2]

    /* alterado em 17/02/2022 */
    //qtd       := aBrowse[n][3]
    qtd       := aBrowse[n][4]
    obs       := aBrowse[n][5]
    pedido    := aBrowse[n][6]
    DOC    := aBrowse[n][7]

    if empty(alltrim(pedido))
        pedido := DOC
    Endif
    
        For i := 1 to Val(qtd)
            /* imprimi etiqueta */
            MSCBPRINTER(cModelo, cLPT,,12,.F.,,,,,,.F.,)
            MSCBCHKSTATUS(.F.)
            MSCBLOADGRF("SIGA.GRF")
            MSCBBEGIN(1,4)

            //MSCBSAY(horizontal,vertical)
            MSCBSAY(19,15   ,produto  , "N", "0", "260,260") // negrito

            nCarac := len(AllTrim(descricao))
            cposic := 72
            MSCBSAY(005,45   ,descricao, "N", "0", "035,035",,,,,.T.) // negrito
            MSCBSAY(005,50   ,"PED N: "+pedido, "N", "0", "035,035",,,,,.T.) // negrito
            MSCBSAY(040,50   ,"DATA: "+DTOC(cData), "N", "0", "035,035",,,,,.T.) // negrito
            MSCBSAY(005,55   ,"Qtde Palets : "+alltrim(qtd), "N", "0", "035,035",,,,,.T.) // negrito
            MSCBSAY(005,60   ,"Usuแrio Sistema : "+PswChave(RetCodUsr()), "N", "0", "035,035",,,,,.T.) // negrito
            
            if !empty(alltrim(obs))
                MSCBSAY(005,65   ,"Obs : "+alltrim(obs), "N", "0", "035,035",,,,,.T.) // negrito
            endif                

            MSCBEND()
            MSCBCLOSEPRINTER()
    Next

    
Next

return

Static function apagartudo(tipo)

    if tipo == '2'
        cPedido := SPACE(9)
        cNF     := SPACE(9)
        cSerie  := SPACE(3)
        cFornecedor := ''
        aFornecedor := {}
        oFornecedor:SetItems(aFornecedor)
    endif

    aBrowse := {}
    aAdd(aBrowse,{'','','','',''})

    // Seta vetor para a browse
    oBrowse:SetArray(aBrowse)

    // Monta a linha a ser exibina no Browse
    oBrowse:bLine  := {||{ aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAT,03],aBrowse[oBrowse:nAT,04],aBrowse[oBrowse:nAT,05], }}
    oBrowse:Refresh()

return


Static Function ReportPrint()

local n,i      := 1
local linhas := len(aBrowse)
local qtd
//local Prevf,UMEMB,Volume
Local Letiq := 0
local produto
local descricao
local obs
local pedido

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
    qtd       := aBrowse[n][4]
    obs       := aBrowse[n][5]
    pedido    := cPedido
    
        For i := 1 to Val(qtd)
           	oPrint:Say(nLin,0050,OemToAnsi(produto),oFont60n,,,,0)
            nLin += 250
            oPrint:Say(nLin,0050,OemToAnsi(descricao),oFont15n,,,,0)
            nLin += 60
            oPrint:Say(nLin,0050,OemToAnsi("PED N: "+pedido),oFont15n,,,,0)
            oPrint:Say(nLin,0400,OemToAnsi("DATA : "+DTOC(cData)),oFont15n,,,,0)
            nLin += 60
            oPrint:Say(nLin,0050,OemToAnsi("Qtde Palets : "+alltrim(qtd)),oFont15n,,,,0)
            
            if !empty(alltrim(obs))
                nLin += 60
                oPrint:Say(nLin,0050,"Obs : "+obs,oFont10,,,,0)
            endif                
            
            nLin += 60
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

static function editaTRB(_Dados)

lEditCell(@aBrowse,oBrowse,"",oBrowse:ColPos())

Return

