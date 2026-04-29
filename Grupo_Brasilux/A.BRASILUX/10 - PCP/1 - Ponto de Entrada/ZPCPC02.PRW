#Include 'Protheus.ch'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} ZPCPC02
Programa que informa o lote Bloqueado
@type function
@version  v.2022.05
@author Luís Gustavo Souza
@since 22/07/2022
/*/
User Function ZPCPC02(cLote)
//Local cLote := "881753"
Local nLargBtn      := 50 // Largura botões
 
 

Private aBrowser := {}
//Tamanho da janela Automatico
Private aSize := MsAdvSize(.F.)
Private nJanLarg := ( aSize[5] - (aSize[5] * 0.50) ) // reduz 5% da tela altura
Private nJanAltu := ( aSize[6] - (aSize[6] * 0.30) ) // reduz 10% da tela altura

//Fontes
Private cFontUti    := "Tahoma"
Private oFontMod    := TFont():New(cFontUti, , -32)
Private oFontSub    := TFont():New(cFontUti, , -20)
Private oFontSubN   := TFont():New(cFontUti, ,  28)
Private oFontBtn    := TFont():New(cFontUti, , -14)
Private oFontSay    := TFont():New(cFontUti, , -12)



// valida existencia do Lote
DbSelectArea("SC2")
DbSetOrder(13)
If !DbSeek(xFilial("SC2")+cLote, .F.)
    return(.F.)
EndIf

// valida existencia do Lote
DbSelectArea("ZAE")
DbSetOrder(2)
If !DbSeek(xFilial("ZAE")+cLote, .F.)
    return(.F.)
EndIf

// Lote Desbloqueado
If ZAE->ZAE_TIPO <> "1"
    return(.F.)
ENDIF

SB1->(DBSetOrder(1))      
SB1->(dbSeek(xFilial("SB1")+ZAE->ZAE_PRODUT))


DEFINE MsDIALOG oDlg TITLE 'Lote Bloqueado' From 0, 4 To  nJanAltu, nJanLarg  Pixel

 @ 003,005 SAY OemToAnsi("Lote Bloqueado : "+AllTrim(ZAE->ZAE_LOTE))  SIZE 400,20 Font oFontMod   PIXEL OF oDlg
 
 @ 035,005 SAY OemToAnsi("Produto :"+AllTrim(ZAE->ZAE_PRODUT)+" - "+AllTrim(SB1->B1_DESC))  SIZE 350,15 Font oFontSubN   PIXEL OF oDlg
  
 @ 058,005 SAY OemToAnsi("Motivo do Bloqueio : ")  SIZE 120,15 Font oFontSubN   PIXEL OF oDlg
 @ 074,005 GET ZAE->ZAE_MOTIVO MEMO SIZE 255,60 Font oFontSubN PIXEL OF oDlg

 @ 150,005 SAY OemToAnsi("Usuário : "+AllTrim(ZAE->ZAE_USUARI))  SIZE 250,15 Font oFontSubN   PIXEL OF oDlg
 
 @ 150,160 SAY OemToAnsi("Data : "+dToC(ZAE->ZAE_DATAB))  SIZE 120,15 Font oFontSubN   PIXEL OF oDlg
 
 oBtnSair := TButton():New(185, 003 , "Fechar", oDlg, {|| oDlg:End()}, nLargBtn, 018, , oFontBtn, , .T., , , , , , )

Activate MsDialog oDlg

Return(.T.)
