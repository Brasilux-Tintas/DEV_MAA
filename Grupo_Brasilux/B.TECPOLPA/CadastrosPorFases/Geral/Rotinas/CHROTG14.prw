#INCLUDE "PROTHEUS.CH"  
#include "Rwmake.ch"
#INCLUDE "FWMVCDEF.CH"  
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"



/**  
*** Retorna a etapa do usuario logado
*** tipo: P-Produto;C-Cliente;F-Fornecedor)
***/ 

User Function CHROTG14(tipo)
                     
  
Local i         
//Local cUsuario := RetCodUsr()//Funcao que retorna o Cod do Usuario
Local menorEtapa := "99"   
Local _aGrpUsr := UsrRetGrp( UsrRetName( RetCodUsr() ) ) //LGS#20200214 - Adequação de release 12.1.25 e posteriores         
      
	//varre todos os grupos que pertencem ao usuario  
//LGS#20200214 - Adequação de release 12.1.25 e posteriores
//For i:= 1 to len(UsrRetGrp(UsrRetName(RetCodUsr())))     
For i:= 1 to len( _aGrpUsr )
	//cCodGru := UsrRetGrp(UsrRetName(RetCodUsr()))[i]
	cCodGru := _aGrpUsr[i]
	//para cada grupo do usuario tenta localizar os campos disponiveis no cadastro
	DbSelectArea("SZP")
	SZP->(DBSetOrder(1))   //  -ZP_FILIAL, ZP_CAD, ZP_GRUPO, ZP_CODRET, 
		    
	 SZP->(DBSeek(xFilial("SZP")+ tipo + cCodGru )) 
	 While SZP->(!EOF()) .And. ALLTRIM(SZP->ZP_CAD) == ALLTRIM(tipo) .And. ALLTRIM(SZP->ZP_GRUPO) == ALLTRIM(cCodGru) 
     	
     	If SZP->ZP_CODRET  <  menorEtapa
     		 menorEtapa := SZP->ZP_CODRET     
		Endif
		      
	 	SZP->(DBSkip())
	 EndDo   
	   
Next i

If menorEtapa == "99"  
	menorEtapa := "0"  
End

Return Val(menorEtapa)     

                   
	