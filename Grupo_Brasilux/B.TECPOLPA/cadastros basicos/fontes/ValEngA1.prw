
#INCLUDE "PROTHEUS.CH" 
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±?Programa  =ValEngA1   ?Autor  =Dyego Figueiredo     ? Data =  18/03/16  ?±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕp±±
±±?Desc.     =Valida campo de engenharia da tabela de cliente			  ?±±
±±?          =   	                                                      ?±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕp±±
±±?Uso       = Tecpolpa					                                  ?±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
?????????????????????????????????????????????????????????????????????????????
*/


User Function ValEngA1()

	Local aArea			:= GetArea()
	Local cCod			:= M->A1_COD
	Local cCodRedz		:= M->A1_XCODENG
	Local lOk			:= .T.  
	Local recnoA1 		:= SA1->(RECNO())  
	
	Local codEng 		:= u_RCliCodLj("ENG") 
	
    If M->A1_XCODENG = "AAA"    //Codigo de Engenharia da Tecpolpa, clientes Mercado Nacional
		dbGoto(recnoA1)	
	    RestArea(aArea)
		Return lOk    	
    EndIf
              		
	DbSetOrder(12)			//A1_FILIAL A1_XCODENG
	DbSelectArea("SA1")  	
	If DbSeek( xFilial("SA1") + M->A1_XCODENG)	
	
		 If SA1->A1_COD <> cCod  
		 		lOk := .F.
		 Endif		
	
	EndIf       
	
	//verifica se tem o codigo de engenharia do cliente com a mesma base de cnpj  
	If !Empty(codEng) .and. !Empty(cCodRedz) .and. codEng <>  cCodRedz
	    Alert("O código da engenharia do cliente não poderá ser alterado, pois deve ser único por cliente (com a mesma base de cnpj) - MA030TOK.PRW")
		Return .F.
	Endif 

	dbGoto(recnoA1)	
    RestArea(aArea)

Return lOk
					      