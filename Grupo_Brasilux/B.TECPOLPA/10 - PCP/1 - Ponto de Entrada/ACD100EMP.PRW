#Include "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ACD100EMP  ³ Autor ³ Nelieder M Corneta   ³ Data ³ 11/11/22 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ O PE ACD100EMP O Ponto de entrada permite ou não o         ³±±
±±³		       ³ a separação de um determinado produto.                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function ACD100EMP()
Local cCod:= ParamIXB[2]
Local lRet:= .T. 

 // Executa apenas para Tecpolpa
  If FWCodEmp() <> '11'
  	Return(lRet)
  EndIf

DbSelectArea("SB1")
DbSetOrder(1) //B1_FILIAL+B1_COD
DbSeek(xFilial("SB1")+PadR(cCod,TamSx3("B1_COD")[1]), .f.)

/*
SB1-> B1_NAOSEPA
1 = Sim
2 = Não
3 = Valida Produto
*/

If SB1->B1_NAOSEPA == "1"
    lRet := .F.
EndIf


Return(lRet)
