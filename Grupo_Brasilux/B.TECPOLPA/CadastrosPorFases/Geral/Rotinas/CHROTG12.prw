#Include 'Protheus.ch'
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH" 


/*
  Retorna a menor etapa
*/
User Function CHROTG12 (cTipo,etapaAtu,_nMaxEtapa)
                          
Local lRet := .T.
Local i,j , _tabela   
Local aCampos, cCampos, iVar
                   
Local maxEtapa := 0
                                                        

 If cTipo ==  "C" 
	 _tabela := "SA1"
 ElseIf  cTipo == "F"  
	 _tabela := "SA2" 
 ElseIf  cTipo == "P" 
	 _tabela := "SB1"
 Endif
 

If _nMaxEtapa < 1
  return 1
Endif

For i := etapaAtu to _nMaxEtapa// maxima etapa  1 - compras, 2 - logistica, 3 - fiscal, 4 - contabilidade
                             
   	// retorna os campos da etapa passada por parametro
   	cCampos := u_CHROTG06(cTipo, i)
     
    iVar := Replace(cCampos, ",", ";")
	iVar := Replace(iVar, ".", ";")
	iVar := Replace(iVar, "-", ";")
	iVar := Replace(iVar, " ", "")
		 
	aCampos := Separa(iVar,";",.T.)   

	//verifica se todos campos foram preenchidos
	For j:= 1 to Len(aCampos)  
	       
	  	DbSelectArea("SX3")
		SX3->(DbSetOrder(2))
  		If !SX3->(DbSeek( aCampos[j]))   .or. Empty(AllTrim(aCampos[j]))   
	   		 loop // se nao achou o campo , pula 
  		Endif 
   		
		If Upper(Substr(AllTrim(aCampos[j]),4, 9)) != "FILIAL" .And. Empty(&(_tabela +"->"+AllTrim(aCampos[j])))      
		                       
			DbSelectArea("SX3")
			SX3->(DbSetOrder(2))
   			If SX3->(DbSeek( aCampos[j]))
	   	
	   			lRet :=  .F.  
				exit
   			Endif  	
		    
	    Endif  	    
	Next j   
	
	
	If !lRet 
		exit
	Endif
Next i

               
Return   i
