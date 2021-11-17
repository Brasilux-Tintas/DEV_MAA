#Include 'Protheus.ch'
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH" 


/*
  Retorna a maior etapa
*/
User Function CHROTG11 (cTipo)
  
Local cQLinha   := Chr(13) + Chr(10)
Local nMaxEtapa	:= 0  
Local cQuery 

If Select("TMPSZQ")<>0
	dbselectarea("TMPSZQ")
	dbclosearea()
Endif
	                         
cQuery := "SELECT  	MAX(ZQ_CODET)		ETAPA			"+cQLinha
cQuery += "												"+cQLinha
cQuery += "FROM	"+RetSqlName("SZQ")+" SZQ				"+cQLinha
cQuery += "												"+cQLinha
cQuery += "WHERE	D_E_L_E_T_ = ' '					"+cQLinha
cQuery += "		AND ZQ_FILIAL = '"+xFilial("SZQ")+"'  	"+cQLinha
cQuery += "		AND ZQ_TIPO = '"+cTipo+"'				"+cQLinha
cQuery += "												"+cQLinha
           
//conout(cQuery)                                                          	                         
 

TCQUERY cQuery ALIAS TMPSZQ NEW
dbSelectArea("TMPSZQ")
dbGoTop()

If !TMPSZQ->(EOF())
		nMaxEtapa := Val(TMPSZQ->ETAPA)    		                     
EndIf
 
	
Return nMaxEtapa