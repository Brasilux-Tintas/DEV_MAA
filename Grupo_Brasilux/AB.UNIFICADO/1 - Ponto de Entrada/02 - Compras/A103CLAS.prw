#INCLUDE "PROTHEUS.CH"

/*
* Funcao			: A103CLAS 
* Autor				: Marcos Bortoluci
* Data				: 30/01/2020
* Descrição			:  
* Observacoes		: 
*/       
User Function A103CLAS()
	Local cAliasSD1 := PARAMIXB[1]
	Local cTes := (cAliasSD1)->D1_ZZTES
	
	If !Empty(cTes)
		GdFieldPut("D1_TES",cTes,Len(aCols))
	EndIf
	
Return() 