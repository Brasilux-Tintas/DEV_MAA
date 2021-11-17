#INCLUDE "PROTHEUS.CH"  
#include "Rwmake.ch"
#INCLUDE "FWMVCDEF.CH"  
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"



/**  
*** Retorna a menor etapa do usuario logado
*** tipo: P-Produto;C-Cliente;F-Fornecedor)
***/ 

User Function CHROTG15(tipo)
                     

Local nEtapa := 999  
Local i         
//Local cUsuario := RetCodUsr()//Funcao que retorna o Cod do Usuario
//Local campos := " "   
Local _aGrpUsr := UsrRetGrp( UsrRetName( RetCodUsr() ) ) //LGS#20200214 - Adequação de release 12.1.25 e posteriores
       
	//LGS#20200214 - Adequação de release 12.1.25 e posteriores
	//varre todos os grupos que pertencem ao usuario  
	//For i:= 1 to len(UsrRetGrp(UsrRetName(RetCodUsr())))     
	For i:= 1 to len( _aGrpUsr )
		//cCodGru := UsrRetGrp(UsrRetName(RetCodUsr()))[i]
	    cCodGru := _aGrpUsr[i]
		//para cada grupo do usuario tenta localizar os campos disponiveis no cadastro
		DbSelectArea("SZP")
		SZP->(DBSetOrder(1))   //  -ZP_FILIAL, ZP_CAD, ZP_GRUPO, ZP_CODET, 
		    
		 SZP->(DBSeek(xFilial("SZP")+ tipo + cCodGru )) 
		 While SZP->(!EOF()) .And. ALLTRIM(SZP->ZP_CAD) == ALLTRIM(tipo) .And. ALLTRIM(SZP->ZP_GRUPO) == ALLTRIM(cCodGru) 
		      If VAL(SZP->ZP_CODRET) < nEtapa
		      	nEtapa := Val(SZP->ZP_CODRET)
		      Endif	
		      
		 	SZP->(DBSkip())
		 EndDo   
	   
	Next i


Return Str(nEtapa)     

                   
	