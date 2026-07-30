#INCLUDE "RWMAKE.CH"
#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³pedido   ³ Autor ³ Roberto Blagin         ³ Data ³31.08.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do Pedido de Vendas  - TmsPrinter                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Especifico Roland                                           ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PEDBRA()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cString	:= "SC5"
lOCAL aArea:=GetArea()
//a_Ret:={}

PRIVATE titulo 	:= ""
PRIVATE nLastKey:= 0
PRIVATE cPerg	:= "PVBRAS"
PRIVATE nomeProg:= FunName()
Private cFileLogo    := GetSrvProfString('Startpath','') + 'brasemba' + '.bmp'
Private nTotal	:= 0
Private mv_par01:=SPACE(06) //m->C5_NUM
Private nSubTot	:= 0
Private oDlg //:= NIL
Private aPos:={}
Private lVend:=.T.

Private cUserID := RetCodUsr() // Função de recuperação do ID do usuário

cUserVendID := Posicione("SA3",7,xFilial("SA3")+cUserID,"A3_COD")  // Busca Código do vendedor através ID usuário

If Alltrim(cUserVendID) = ""
	lVend:=.F.
End



AADD(aPos,0070)  // Item
AADD(aPos,0120)  // Quantidade
AADD(aPos,0250) // Codigo
AADD(aPos,0450) // Descrição
AADD(aPos,0850) //medidas
AADD(aPos,1150)// Papel
AADD(aPos,1250)//Impressao
AADD(aPos,1600) //Modelo
AADD(aPos,1800) //Fechamento
AADD(aPos,1950) //Preço Unitario
AADD(aPos,2100) //Preço Total
AADD(aPos,2300) // % ipi

If !(NomeProg$"MATA410/BFILPED")
	//AjustaSx1()
	If ! Pergunte(cPerg,.T.)
		Return
	End
	dbSelectArea("SC5")
	dbSetOrder(1)
	If ! dbSeek(xFilial("SC5")+mv_par01,.T.)
		MsgInfo("Pedido Nao Encontrado","Nao Encontrado","INFO")
		Return
	End

Else           
//	dbSelectArea("SC5")
//	mv_par01:=iF(m->C5_NUM == nil,SC5->C5_NUM,M->c5_num)

Endif
    
// Verifica se pode imprimir                          
IF Empty(SC5->C5_liberok)
	AVISO("Nao Liberado","Pedido Nao Liberado.Nao Sera Possivel a Impressao do mesmo",{"Ok"})
	RestArea(aArea)
	Return
End	

//If !empty(MV_PAR02)               //Envia E-mail
//	U_MailPV(AllTrim(mv_par01),AllTrim(mv_par02))
//EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros					  		³
//³ mv_par01				// Numero da PT                   		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := FunName()            //Nome Default do relatorio em Disco

PRIVATE cTitulo := "Impressão do Pedido de Vendas"
PRIVATE oPrn    := NIL
//Private cPerg := "FATR05"
Private nLastKey := 0
Private nLin := 1650 // Linha de inicio da impressao das clausulas contratuais

oFont08I :=	TFONT():New("Arial",08,08,,.T.,,,,.T.,.F.)
oFont06I :=	TFONT():New("Arial",06,06,,.F.,,,,.T.,.F.)
oFont08 :=	TFONT():New("Arial",08,08,,.F.,,,,.F.,.F.)
oFont16N :=	TFONT():New("Arial",16,16,,.T.,,,,.F.,.F.)
oFont06 :=	TFONT():New("Arial",06,06,,.F.,,,,.F.,.F.)
oFont12 :=	TFONT():New("Arial",12,12,,.F.,,,,.F.,.F.)
oFont10 :=	TFONT():New("Arial",10,10,,.F.,,,,.F.,.F.)
oFont10S :=	TFONT():New("Arial",10,10,,.F.,,,,.F.,.T.)
oFont12S :=	TFONT():New("Arial",12,12,,.F.,,,,.F.,.T.)
oFont08N:=	TFONT():New("Arial",08,08,,.T.,,,,.F.,.F.)
oFont10N:=	TFONT():New("Arial",10,10,,.T.,,,,.F.,.F.)
oFont12N:=	TFONT():New("Arial",12,12,,.T.,,,,.F.,.F.)
oFont12NI:=	TFONT():New("Arial",12,12,,.T.,,,,.T.,.F.)
oFont12NS:=	TFONT():New("Arial",12,12,,.T.,,,,.F.,.T.)
oFont12NS:=	TFONT():New("Arial",12,12,,.T.,,,,.F.,.T.)
oFntTela :=	TFONT():New("Arial Italic",08,08,,.T.,,,,.T.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela de Entrada de Dados - Parametros                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLastKey  := IIf(LastKey() == 27,27,nLastKey)

If nLastKey == 27
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio do lay-out / impressao                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If SC5->C5_IMPRESS == "S"
	If Aviso("Ja Impresso","Pedido Ja Impresso.ReImprime?",{"Sim","Nao"}) == 2
		Return
	End
End		 



oPrn := TMSPrinter():New(cTitulo)
oPrn:Setup()
//oPrn:SetLandsCape()//SetPortrait() //SetLansCape()
oPrn:SetPortrait()
oPrn:StartPage()
cBitMap :="brasemba.bmp"

Imprimir()
oPrn:EndPage()
oPrn:End()


DEFINE MSDIALOG oDlg TITLE cTitulo FROM 264,182 TO 441,613 PIXEL

@ 004,010 TO 082,157 LABEL "" OF oDlg PIXEL

@ 015,017 SAY "Esta rotina tem por objetivo de"	OF oDlg PIXEL Size 150,010 FONT oFntTELA COLOR CLR_HBLUE
@ 030,017 SAY "imprimir o impresso customizado:"					OF oDlg PIXEL Size 150,010 FONT oFntTELA COLOR CLR_HBLUE
@ 045,017 SAY "Pedido de Venda" 						OF oDlg PIXEL Size 150,010 FONT oFntTELA COLOR CLR_HBLUE

@ 06,167 BUTTON "&Imprime" 		SIZE 036,012 ACTION oPrn:Print()   	OF oDlg PIXEL
@ 28,167 BUTTON "Pre&view" 		SIZE 036,012 ACTION oPrn:Preview() 	OF oDlg PIXEL
@ 49,167 BUTTON "Sai&r"    		SIZE 036,012 ACTION oDlg:End()     	OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg CENTERED

IF MsgYesNo('Imprime Solicitacao de Compra (S/N) ?','Solicitacao de Compra')
	u_OsBras(sc5->c5_num)
End

RestArea(aArea)
Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ IMPRIMIR  ¦ Autor ¦ Roberto Blagin       ¦ Data ¦31.08.2007¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Impressao Pedido de Vendas   					          ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Roland                                                     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
STATIC FUNCTION Imprimir()

Orcamento()
Ms_Flush()                            
Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ORCAMENTO ¦ Autor ¦ Roberto Blagin       ¦ Data ¦31.08.2007¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Impressao 										          ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Roland                                                     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
STATIC FUNCTION Orcamento()

Local nTotIpi:=0
Local nValItem:=0
Local nTotPed:=0
Local cIpi:=""
Local nLin ,cMedidas

dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)

dbSelectArea("SA3")
dbSetOrder(01)
dbSeek(xFilial()+SC5->C5_VEND1)

dbSelectArea("SA4")
dbSetOrder(01)
dbSeek(xFilial("SA4")+SC5->C5_TRANSP)

dbSelectArea("SA3")
dbSetOrder(01)
dbSeek(xFilial("SA3")+SC5->C5_VEND1)

dbSelectArea("SF4")
dbSetOrder(01)
dbSeek(xFilial("SF4")+SC6->C6_TES)

dbSelectArea("SE4")
dbSetOrder(01)
dbSeek(xFilial("SE4")+SC5->C5_CONDPAG)

dbSelectArea("SC6")
dbSetOrder(01)
dbSeek(xFilial("SC6")+SC5->C5_NUM)


// Cabecalho
CabPV()
nLin    :=0960

dbSelectArea("SC6")
dbSetOrder(1)
dbSeek(xFilial("SC6")+SC5->C5_NUM)

nItem:=0
While !Eof() .And. SC6->C6_NUM ==SC5->C5_NUM
	                        
	lCor2:=.F.                             
	lCor3:=.F.                             
	lCor4:=.F.                             
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+SC6->C6_PRODUTO)
	
	dbSelectArea("SC6")
	
	cMedidas:=Transform(SC6->C6_COMPR ,"@E 9.999")+" x "+;
	Transform(SC6->C6_LARGURA  ,"@E 9.999")+" x "+;
	Transform(SC6->C6_ALTURA,"@E 9.999")
	
	cIPI	:=Posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_IPI")
	
	cMontag:=Posicione("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_MONTAG")
	
	cFechto:=Posicione("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_TPFECH")
	If cFechto == "G"
		cFechto:="Grampo"
	ElseIf	cFechto == "F"
		cFechto:="Fita"
	ElseIf cFechto == "C"
		cFechto:= "Cola"
	Else
		cFechto:= "S/Fech"
	End
	
	If cMontag == "M"
		cMontag:="Maleta"
	ElseIf cMontag == "C"
		cMontag:="Corte Vinco"
	ElseIf cMontag == "A"
		cMontag:="AbaTranspassada"
	ElseIf cMontag=="I"
		cMontag:="Aba Inferior"
	ElseIf cMontag == "S"
		cMontag:="Aba Superior"
	ElseIf cMontag =="T"
		cMontag:="S/Aba Inferior"
	ElseIf cMontag=="F"
		cMontag:="S/Aba Superior"
	ElseIf cMontag == "B"
		cMontag:="Bobina"
	ElseIf cMontag =="N"
		cMontag:="S/Aba"
	ElseIf cMontag=="R"
		cMontag:="Cinta S/Cola"
	Else
		cMontag:="Nao Definido"
	End		         
	
	cCor:=""                             
    If SB1->B1_BRAIMP='S'
		If !EMPTY(SB1->B1_COR1)
				cCor+=AllTrim(Tabela("70",SB1->B1_COR1,.F.))
		End
		If !EMPTY(SB1->B1_COR2)
			cCor+="/"+AllTrim(Tabela("70",SB1->B1_COR2,.F.))
		End
		If !EMPTY(SB1->B1_COR3) 
			cCor+="/"+AllTrim(Tabela("70",SB1->B1_COR3,.F.))
		End
		If !EMPTY(SB1->B1_COR4)
			cCor+="/"+AllTrim(Tabela("70",SB1->B1_COR4,.F.))
		End	
		If Empty(SB1->B1_COR1+SB1->B1_COR2+SB1->B1_COR3+SB1->B1_COR4)		
			If !Empty(SB1->B1_ESPCOR)
				cCor:=AllTrim(SB1->B1_ESPCOR)
			Else      
				cCor:="Sem Impressao"
			End	
		End                       
	Else
			cCor:="Sem Impressao"
	EndIf			
	
	
	oPrn:Say(nLin,aPos[01],OemToAnsi(SC6->C6_ITEM),			   oFont08)
	oPrn:Say(nLin,aPos[02],OemToAnsi(TRANSFORM(SC6->C6_QTDVEN,"@E 999,999")),		   oFont08)
//	oPrn:Say(nLin,aPos[02],OemToAnsi(TRANSFORM(SC6->C6_QTDVEN,"@E 99,999.99")),		   oFont08)
	oPrn:Say(nLin,aPos[03],OemToAnsi(SC6->C6_PRODUTO),		   oFont08)
	oPrn:Say(nLin,aPos[04],OemToAnsi(Alltrim(Substr(SC6->C6_DESCRI,1,20))),		   oFont08)
	oPrn:Say(nLin,aPos[05],OemToAnsi(cMedidas)		,		   oFont08)
	oPrn:Say(nLin,aPos[06],OemToAnsi(SC6->C6_TPPAP)	,		   oFont08)
	oPrn:Say(nLin,aPos[07],If(Len(cCor)>20,OemToAnsi(Alltrim(Substr(cCor,1,20))),OemToAnsi(Alltrim(cCor))),		   oFont08)
	oPrn:Say(nLin,aPos[08],OemToAnsi(Alltrim(Substr(cMontag,1,15))),		   oFont08)
	oPrn:Say(nLin,aPos[09],OemToAnsi(cFechto),		   oFont08)          
	oPrn:Say(nLin,aPos[10],OemToAnsi(TRANSFORM(SC6->C6_PRCMIX,"@E 999,999.99")),		   oFont08)
	oPrn:Say(nLin,aPos[11],OemToAnsi(TRANSFORM(SC6->C6_PRCMIX * SC6->C6_QTDVEN,"@E 999,999.99")),		   oFont08)
	oPrn:Say(nLin,aPos[12],OemToAnsi(If(cIPI=="S",TRANSFORM(SC6->C6_IPI,"@E 99")," ")),		   oFont08)

	nTotIPI   	+= 	Iif(cIPI=="S",(SC6->C6_PRCMIX * SC6->C6_QTDVEN)*(SC6->C6_IPI/100),0)
	nTotPed		+=	(SC6->C6_PRCMIX * SC6->C6_QTDVEN)
	nLin+=0050
	If Len(cCor) > 20
		oPrn:Say(nLin,aPos[07],OemToAnsi(Alltrim(Substr(cCor,20,Len(cCor)))),		   oFont08)
    	nLin+=50
    End

	nItem++
	If nItem > 40 .OR. NlIN > 1800
    	nLin+=20
		oPrn:Line(nLin,040,nLin,2350)                                                                  
    	nLin+=20
		oPrn:Say(nLin,100,OemToAnsi("Continua na Pagina Seguinte..."),		   oFont12S)

		oPrn:EndPage()
		
		CabPV()
		
		oPrn:Say(0360,700," (Continuacao)",oFont10N)
		
		nItem:=0		
		nLin    :=0960
	End
	dbSelectArea("SC6")
	dbSkip()
End
oPrn:Line(2000,040,2000,2350)
oPrn:Box(2000,1700,2200,2350)//box totais

oPrn:Say(2030,1725,"Sub Total"      	            	,oFont12N)
oPrn:Say(2030,2080,Transform(nTotPed,"@E 999,999.99",),oFont12)

If nTotIPI > 0
	oPrn:Say(2080,1725,"IPI"         	            	,oFont12N)
	oPrn:Say(2080,2080,Transform(nTotIPI,"@E 999,999.99"),oFont12)
End
oPrn:Say(2150,1725,"Total Pedido "         	            	,oFont12N)
oPrn:Say(2150,2080,Transform(nTotPed+nTotIPI,"@E 999,999.99",),oFont12)
              
/*/
IF !EMPTY(SC5->C5_MENNOTA)
	nLinha:=2030
	If !Empty(Substr(SC5->C5_MENNOTA,1,85))
		oPrn:Say(nLinha,0065,OemToAnsi(Substr(SC5->C5_MENNOTA,1,85)),oFont10)
		nLinha+=50
	End	
	If !Empty(Substr((SC5->C5_MENNOTA,85,86))
		oPrn:Say(nLinha,0065,OemToAnsi(Substr(SC5->C5_MENNOTA,86,85)),oFont10)
		nLinha+=50
	End	
	If !Empty(Substr((SC5->C5_MENNOTA,171,85))
		oPrn:Say(nLinha,0065,OemToAnsi(Substr(SC5->C5_MENNOTA,171,86)),oFont10)
		nLinha+=50
	End	                                      

ENDIF
/*/
////imprimir observação para o cliente
nLinha:=1980 // Alterar caso tenha mensagfem nota
if !EMPTY(SC5->C5_MENPED)
	nLinha1:=nLinha+50
	If !Empty(Substr(SC5->C5_MENPED,1,75))
		oPrn:Say(nLinha1,0065,OemToAnsi(Substr(SC5->C5_MENPED,1,75)),oFont10)
		nLinha1+=50
	End	
	If !Empty(Substr(SC5->C5_MENPED,76,75))
		oPrn:Say(nLinha1,0065,OemToAnsi(Substr(SC5->C5_MENPED,76,75)),oFont10)
		nLinha1+=50
	End	
	If !Empty(Substr(SC5->C5_MENPED,151,75))
		oPrn:Say(nLinha1,0065,OemToAnsi(Substr(SC5->C5_MENPED,151,75)),oFont10)
		nLinha1+=50
	End	                                      
	If !Empty(Substr(SC5->C5_MENPED,226,25))
		oPrn:Say(nLinha1,0065,OemToAnsi(Substr(SC5->C5_MENPED,226,25)),oFont10)
		nLinha1+=50
	End	                                      


endif

/*/
oPrn:Box(2480,0050,2630,1550)//box observação interna
oPrn:Say(2490,0060,"Obs.Interna:" 				          	,oFont10N)
oPrn:Say(2490,0280,Substr(SC5->C5_OBSINT,001,070)           	,oFont08)
oPrn:Say(2540,0060,Substr(SC5->C5_OBSINT,071,080)           	,oFont08)
oPrn:Say(2590,0060,Substr(SC5->C5_OBSINT,152,048)           	,oFont08)

// Acresceenta o final da variavel -MAA
//	oPrn:Say(2590,0450,Substr(SC5->C5_OBSINT,161,40)           	,oFont10)
/*/
oPrn:Line(2450,070,2450,700	,oFont10)
oPrn:Say(2450,300,If(lVend,"Representante","Vendedor"),oFont10)   

if !EMPTY(SC5->C5_OBSTRAN)
	nLinha1:=2500
	If !Empty(Substr(SC5->C5_OBSTRAN,1,40))
		oPrn:Say(nLinha1,0065,OemToAnsi(Substr(SC5->C5_OBSTRAN,1,40)),oFont10)
		nLinha1+=50
	End	
	If !Empty(Substr(SC5->C5_OBSTRAN,41,40))
		oPrn:Say(nLinha1,0065,OemToAnsi(Substr(SC5->C5_OBSTRAN,41,40)),oFont10)
		nLinha1+=50
	End	
	If !Empty(Substr(SC5->C5_OBSTRAN,81,40))
		oPrn:Say(nLinha1,0065,OemToAnsi(Substr(SC5->C5_OBSTRAN,81,40)),oFont10)
		nLinha1+=50
	End	                                      
	If !Empty(Substr(SC5->C5_OBSTRAN,121,40))
		oPrn:Say(nLinha1,0065,OemToAnsi(Substr(SC5->C5_OBSTRAN,121,40)),oFont10)
		nLinha1+=50
	End	                                      


endif


oPrn:Line(2450,1600,2450,2350,oFont10)
oPrn:Say(2450,1750,"Nome Por Extenso COMPRADOR",oFont10)
oPrn:Say(2500,1750,"ASSINATURA E CARIMBO",oFont10)

oPrn:Say(2550,1600,"* Declaro estar de acordo com todos os dados",oFont08N)
oPrn:Say(2600,1600,"descritos acima para a fabricação do pedido",oFont08N)
oPrn:Say(2650,1600,"e eventuais mudanças fico sujeito a custos extras"	,oFont08n)

oPrn:Say(2750,0070,"___________________________________________________ CONDICOES DE VENDA________________________________________________________" 	,oFont10N)
oPrn:Say(2850,0070,"1) FAVOR CONFIRMAR OU CANCELAR VIA FAX DENTRO DE 24 HORAS DA DATA DE RECEBIMENTO DESTE PEDIDO."  	,oFont08N)
oPrn:Say(2830,1750," FAX (11)  3971-3419"  	,oFont12NS)
//oPrn:Say(2900,0070,"2) A BRASEMBA NAO SE RESPONSABILIZA POR QUAISQUER PROMESSAS OU CONSIDERAÇÕES VERBAIS DOS VENDEDORES."  	,oFont08N)
oPrn:Say(2900,0070,"2) A BRASEMBA NAO SE RESPONSABILIZA POR QUAISQUER PROMESSAS OU CONSIDERAÇÕES VERBAIS DOS "+If(lVend,"REPRESENTANTES","VENDEDORES")+"."  	,oFont08N)
oPrn:Say(2950,0070,"   TODOS OS DADOS E DEMAIS PARTICULARIDADES DEVEM SER REGISTRADAS POR ESCRITO NESTE PEDIDO, SEM EXCESSOES"  	,oFont08N)
oPrn:Say(3000,0070,"3) O PEDIDO NAO PODERA SER CANCELADO EM HIPOTESE ALGUMA , UMA VEZ QUE GERA SERVIÇOS ESPECIFICOS E MERCADORIAS "  	,oFont08N)
oPrn:Say(3050,0070,"   FABRICADAS SOB MEDIDA E DE USO EXCLUSIVO DE SUA EMPRESA"  	,oFont08N)
oPrn:Say(3100,0070,"4) SO ACEITAMOS DEVOLUCOES DE PRODUTOS POR DEFEITO DE FABRICACAO NO PRAZO DE 7 DIAS, RESSALVANDO AS CONDICOES DE ARMAZENAGEM",oFont08N)
oPrn:Say(3150,0070,"5) PRODUTOS SUJIETOS A VARIACOES CLIMATICAS"  	,oFont08N)
oPrn:Say(3200,0070,"6) AS QUANTIDADES SOLICITADAS ´PODERAO OSCILAR EM 10% A MAIS OU A MENOS"  	,oFont08N)
oPrn:EndPage()
 
dbSelectArea("SC5")
RecLock("SC5",.F.)
SC5->C5_IMPRESS:="S"
MsUnLock()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-¿±±
±±³Fun‡…o    ³ AjustaSX1    ³Autor ³  J.Marcelino Correa  ³    03.06.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-´±±
±±³Descri‡…o ³ Ajusta perguntas do SX1                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSX1()

Local aArea := GetArea()
PutSx1(cPerg,"01","No Pedido Vendas               ?"," "," ","mv_ch1","C",6,0,0,	"G","","   ","","","mv_par01"," "," "," ","",	" "," "," "," "," "," ", " "," "," "," ",	" "," ",{"Informe numero do Pedido Vendas"},{"Informe o numero do Pedido de Vendas de"},{"Informe o Numero do Pedido de Vendas"})
//PutSx1(cPerg,"02","Email a ser enviado            ?"," "," ","mv_ch2","C",50,0,0,	"G","","   ","","","mv_par02"," "," "," ","",	" "," "," "," "," "," ", " "," "," "," ",	" "," ",{"Informe endereco de email para enviar"},{"Informe endereco de email para enviar"},{"Informe endereco de email para enviar"})
//PutSx1(cPerg,"02","Pedido Vendas Ate             ?"," "," ","mv_ch2","C",6,0,0,	"G","","   ","","","mv_par02"," "," "," ","",	" "," "," "," "," "," ", " "," "," "," ",	" "," ",{"Informe o numero do Orcamento"},{"Informe o numero do Pedido de Vendas ate"},{"Informe o Numero do Pedido de Compras ate"})

RestArea(aArea)

Return

//Processo para salvar relatório como imagem

aCaminho           := {"\\192.168.1.8\teste.jpg"}
filepath          := "\192.168.1.8"
nwidthpage      := 630
nheightpage     := 870

aFiles := Directory(aCaminho[1])
For i:=1 to Len(aFiles)
	fErase("\\192.168.1.8\"+aFiles[1])
Next i

oPrint:SaveAllAsJpeg(filepath,nwidthpage,nheightpage,100)   //Gera arquivos JPEG na Pasta \Protheus_data\Images\

aFiles := {}
aFiles := Directory(aCaminho[1])

//Visualizacao e finalizacao do relatorio

oPrint:Setup()
oPrint:Preview()
oPrint:EndPage()
MS_FLUSH()

If MV_PAR03 = 1               //Envia E-mail
	EMAIL()
EndIF

Return
//********************************************************************************************************************
Static Function CABPV()

oPrn:StartPage()

oPrn:SayBitmap(0040,0070,cBitMap,0300,0300)			// Imprime logo da Empresa: comprimento X altura

//oPrn:Say(0030,1200,"BRASEMBA INDUSTRIA DE EMBALAGENS LTDA"            ,oFont16N,,,,2)
oPrn:Say(0030,1200,AllTrim(SM0->M0_NOMECOM)            ,oFont16N,,,,2)
oPrn:Say(0080,1200,"Caixas, Chapas e Bobinas de Papelão Ondulado"     ,oFont08I,,,,2)

oPrn:Say(0150,1200,"Rua  Monte Azul Paulista, 389 - Parada de Taipas - S.P. - Capital"            ,oFont08,,,,2)
oPrn:Say(0200,1200,"C E P  02883-050   Telefone (011) 3972-2182 Fax (011) 3971-3419"            ,oFont08,,,,2)
//oPrn:Say(0250,1200,"C.N.P.J 56.695.620/0001-47 Inscrição Estadual: 111.706.860.115"            ,oFont08,,,,2)  
oPrn:Say(0250,1200,"C.N.P.J "+Transform(SM0->M0_CGC,"@ER 99.999.999/9999-99")+" Inscrição Estadual: "+Transform(SM0->M0_INSC,"@ER 999.999.999.999"),oFont08,,,,2)  

// Liberado por
// Incluido por
oPrn:Say(0250,2100,"Incluido por: "+SC5->C5_USERINC,ofont08,,,,2)
oPrn:Say(0300,2100,"Liberado por: "+SC5->C5_USERLIB,ofont08,,,,2)

If lVend
	oPrn:Say(0300,1200," "            ,oFont08,,,,2)
Else
	oPrn:Say(0300,1200,"www.brasemba.com.br  E-mail : grupobrasemba@brasemba.com.br"            ,oFont08,,,,2)
End
oPrn:Line(0350,040,0350,2350)

oPrn:Say(0360,070,"Pedido de Venda No.: "+SC5->C5_NUM,oFont12)       

oPrn:Say(0360,1200,"Orcamento No.: "+SC5->C5_XNUMORC,oFont12)       

oPrn:Say(0360,1960,"Emissao: ",oFont12)
oPrn:Say(0360,2160,DTOC(SC5->C5_EMISSAO),oFont12N)

If SC6->C6_TES != "914"  .and. !Empty(SC5->C5_FLAG)   // SN
   oPrn:Say(380,040,Replicate("_ ",92),oFont08)
Else
	oPrn:Line(0410,040,0410,2350)
End
If SC6->C6_TES == "914"    // SN
	oPrn:Line(0420,040,0420,2350)
End

dataHora:=Time()
oPrn:Say(0415,2220,Time(),oFont08)
oPrn:Say(0460,2220,Str(SC5->C5_XIMPRES,2)+" via(s)",oFont08)

//oPrn:Box(0180,2350,0630,3350)

oPrn:Say(0420,0070,"Cliente:",oFont10)
oPrn:Say(0420,0350,OemToAnsi(SA1->A1_NOME)+" ("+SA1->A1_COD+")",oFont12n)

oPrn:Say(0470,0350,Alltrim(OemToAnsi(SA1->A1_END)),oFont10)
oPrn:Say(0470,1350,OemToAnsi("CEP: "+TRANSFORM(SA1->A1_CEP,"@r 99999-999")),oFont10)

oPrn:Say(0520,0350,Alltrim(OemToAnsi(SA1->A1_BAIRRO)),oFont10)
oPrn:Say(0520,1350,Alltrim(OemToAnsi(SA1->A1_MUN+" - "+SA1->A1_EST)),oFont10)

If Len(AllTrim(SA1->A1_CGC)) > 11
	oPrn:Say(0570,0350,"C.N.P.J.: "+Transform(Alltrim(SA1->A1_CGC),"@R 99.999.999/9999-99"),oFont10)
Else
	oPrn:Say(0570,0350,"C.P.F.: "+Transform(Alltrim(SA1->A1_CGC),"@R 999.999.999-99"),oFont10)
End
oPrn:Say(0570,1350,"I.E.:"+SA1->A1_INSCR,oFont10)

oPrn:Say(0620,0350,"Fone/Fax: ("+SA1->A1_DDD+") "+Alltrim(SA1->A1_TEL)+"  /  ("+SA1->A1_DDD+") "+Alltrim(SA1->A1_FAX),oFont10)
//oPrn:Say(0620,1350,"Vendedor:  ("+SC5->C5_VEND1+") - "+If(Empty(SA3->A3_NREDUZ),Substr(SA3->A3_NOME,1,15),Alltrim(SA3->A3_NREDUZ)) 	,oFont10)
oPrn:Say(0620,1350,If(lVend,"Representante","Vendedor:")+"  ("+SC5->C5_VEND1+")"+If(lVend," "," - "+If(Empty(SA3->A3_NREDUZ),Substr(SA3->A3_NOME,1,15),Alltrim(SA3->A3_NREDUZ))) 	,oFont10)

oPrn:Say(0670,0350,"Condições de Pagamento: " ,oFont10)
oPrn:Say(0665,0780,AlLtrim(OemToAnsi(SE4-> E4_DESCRI)),oFont12N)

oPrn:Say(0670,1350,OemToAnsi("Entrega: "),oFont10)
oPrn:Say(0665,1500,IF(sc5->c5_tpentre="1","ATE ",""),oFont12N)
oPrn:Say(0670,1615,DTOC(sc5->c5_dtentr),oFont10S )

oPrn:Line(0720,040,0720,2350)

oPrn:Say(0730,0070,"Transp: ",oFont10)
oPrn:Say(0730,0350,SA4->A4_COD+" - "+Alltrim(SA4->A4_NOME),oFont12)

oPrn:Line(0780,040,0780,2350)

oPrn:Say(0790,0070,"Local Cobrança:  ",oFont10)
oPrn:Say(0790,0350,Alltrim(SA1->A1_ENDCOB),oFont10)
oPrn:Say(0790,1350,"Contato: "+Alltrim(SA1->A1_CONTATO),oFont10)
oPrn:Say(0790,1900,"Ped.Cliente: "+Alltrim(SC5->C5_PEDCLI),oFont10)

oPrn:Say(0840,0070,"Local Entrega:  ",oFont10)
oPrn:Say(0840,0350,Alltrim(SA1->A1_ENDENT)+" - "+AllTrim(SA1->A1_BAIRROE)+" - "+AllTRIM(SA1->A1_MUNE)+" - "+SA1->A1_ESTE+" - "+"CEP "+Transform(SA1->A1_CEPE,"@ER 99999-999"),oFont10)

//oPrn:Line(0840,040,0840,2350)
/*/
oPrn:Box(0890,0040,0900,2350)//box itens de pedido
oPrn:Say(0910,0070,"IT"  	            	,oFont10N)
oPrn:Say(0910,0120,"Quant"	            	,oFont10N)
oPrn:Say(0910,0250,"Um"		  	            ,oFont10N)
oPrn:Say(0910,0320,"Codigo"                	,oFont10N)
oPrn:Say(0910,0600,"Descricao"             	,oFont10N)
oPrn:Say(0910,0940,"Medidas (CxLxA)"        ,oFont10N)
oPrn:Say(0910,1260,"Papel"	            	,oFont10N)
oPrn:Say(0910,1390,"Impressao"              ,oFont10N)
oPrn:Say(0910,1765,"Fechto"                	,oFont10N)
oPrn:Say(0910,1900,"Unitario"             	,oFont10N)
oPrn:Say(0910,2100,"Valor Total"           	,oFont10N)
oPrn:Say(0910,2300,"IPI"   	        		,oFont10N)
/*/



oPrn:Say(0910,aPos[01],"IT"  	            	,oFont10N)
oPrn:Say(0910,aPos[02],"Quant"	            	,oFont10N)
oPrn:Say(0910,aPos[03],"Codigo"                	,oFont10N)
oPrn:Say(0910,aPos[04],"Descricao"             	,oFont10N)
oPrn:Say(0910,aPos[05],"Medidas (CxLxA)"        ,oFont10N)
oPrn:Say(0910,aPos[06],"Papel"	            	,oFont10N)
oPrn:Say(0910,aPos[07],"Impressao"              ,oFont10N)
oPrn:Say(0910,aPos[08],"Mont."  	            ,oFont10N)
oPrn:Say(0910,aPos[09],"Fechto"                	,oFont10N)
oPrn:Say(0910,aPos[10],"Unitario"             	,oFont10N)
oPrn:Say(0910,aPos[11],"Valor Total"           	,oFont10N)
oPrn:Say(0910,aPos[12],"IPI"   	        		,oFont10N)

Return
