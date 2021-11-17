#INCLUDE "PROTHEUS.CH"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MVDATAFIN ³ Autor ³ Claudio Ferreira      ³ Data ³03/11/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³                  ³Contato ³                                 ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function D1XQTDVL(_nQtd,_nVol,_cProduto)                         
// Variaveis Locais da Funcao
Private cEdit1	 := Transform(IIF(_nVol>0,_nVol,_nVol)," @E 999,999,999.99")
Private cEdit2	 := Transform(_nVol," @E 999,999,999.99")
Private oEdit1
Private oEdit2
Private _oDlg				// Dialog Principal

cImpEtiq := Posicione("SB1",1,xFilial("SB1")+_cProduto,"B1_XETIQUE")

if cImpEtiq!="S"

	Return Val(cEdit2)
EndIf



DEFINE MSDIALOG _oDlg TITLE "Atualiza Qtde por Volume" FROM C(350),C(575) TO C(487),C(721) PIXEL
@ C(007),C(007) Say "Valor Atual" Size C(027),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
@ C(015),C(007) MsGet oEdit1 Var cEdit1 Size C(060),C(009) COLOR CLR_BLACK WHEN .F. PIXEL OF _oDlg
@ C(030),C(007) Say "Novo Valor" Size C(028),C(008) COLOR CLR_BLACK  PIXEL OF _oDlg
@ C(037),C(007) MsGet oEdit2 Var cEdit2 Size C(060),C(009) COLOR CLR_BLACK  PIXEL OF _oDlg HASBUTTON
DEFINE SBUTTON FROM C(055),C(007) TYPE 1 ENABLE OF _oDlg ACTION _bOk(cEdit2)
DEFINE SBUTTON FROM C(055),C(040) TYPE 2 ENABLE OF _oDlg ACTION _oDlg:End()
ACTIVATE MSDIALOG _oDlg CENTERED


Return Val(StrTran(StrTran(cEdit2,'.',''), ',', '.'))

//**************************
Static Function _bOk(cEdit2)
//**************************
_oDlg:End()
//PutMv("MV_XFRTCOM",Alltrim(cEdit2))
Return Val(StrTran(StrTran(cEdit2,'.',''), ',', '.'))

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³   C()   ³ Autores ³ Norbert/Ernani/Mansano ³ Data ³10/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C(nTam)
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
	nTam *= 0.8
ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
	nTam *= 1
Else	// Resolucao 1024x768 e acima
	nTam *= 1.28
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para tema "Flat"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If "MP8" $ oApp:cVersion
	If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
		nTam *= 0.90
	EndIf
EndIf
Return Int(nTam)