#INCLUDE "PROTHEUS.CH"
#include "RWMAKE.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DescCliForºAutor  ³Claudio Vilarinho   º Data ³  06/01/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tras a descrição do nome do cliente ou fornecedor no browerº±±
±±º          ³ do contrado                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DescCliFor()
Local aArea	  := GetArea()    
Local cDescCF := ""


IF CN9->CN9_ESPCTR == "1"
	dbSelectArea("CNC")
	CNC->(dbSetOrder(1))
	CNC->(dbSeek(xFilial("CNC")+CN9->CN9_NUMERO))
	
	cDescCF := POSICIONE("SA2",1,XFILIAL("SA2")+CNC->CNC_CODIGO+CNC->CNC_LOJA,"A2_NOME")
	
	RestArea(aArea)
ELSEIF CN9->CN9_ESPCTR == "2"
	dbSelectArea("CNC")
	CNC->(DbSetOrder(3))
	CNC->(dbSeek(XFILIAL("CNC")+CN9->CN9_NUMERO))
	
	cDescCF := POSICIONE("SA1",1,XFILIAL("SA1")+CNC->CNC_CLIENT+CNC->CNC_LOJACL,"A1_NOME")
	
	RestArea(aArea)
ENDIF




Return cDescCF 