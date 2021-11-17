#Include 'Protheus.ch'
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH" 

/**
	MT010LEG - PE Adiciona Legendas no MATA010                           
**/

User Function CHROTP05()

Local _aArea := GetArea()

	aLegenda := query01( ) 
	If len(aLegenda) > 0
		BrwLegenda("Legendas","Legenda de Produtos", aLegenda )		
	Endif
		
RestArea(_aArea)
							
Return


// Retorna as legendas
Static Function query01( ) 
  
Local cQLinha   := Chr(13) + Chr(10)
Local aLegenda	:= {}  
Local cQuery 

If Select("TMPSZQ")<>0
	dbselectarea("TMPSZQ")
	dbclosearea()
Endif
	                         
cQuery := "SELECT  		ZQ_LEGENDA		LEGENDA, 		"+cQLinha
cQuery += "				ZQ_CORLEGE		COR_LEGENDA,  	"+cQLinha
cQuery += "				ZQ_CODET		ETAPA			"+cQLinha
cQuery += "												"+cQLinha
cQuery += "FROM	"+RetSqlName("SZQ")+" SZQ				"+cQLinha
cQuery += "												"+cQLinha
cQuery += "WHERE	D_E_L_E_T_ = ' '					"+cQLinha
cQuery += "		AND ZQ_FILIAL = '"+xFilial("SZQ")+"'  	"+cQLinha
cQuery += "		AND ZQ_TIPO = 'P'						"+cQLinha
cQuery += "												"+cQLinha
cQuery += "GROUP  BY ZQ_LEGENDA,ZQ_CORLEGE, ZQ_CODET    "+cQLinha
cQuery += "												"+cQLinha
cQuery += "ORDER BY ZQ_CODET							"+cQLinha
           
//conout(cQuery)                                                          	                         
 

TCQUERY cQuery ALIAS TMPSZQ NEW
dbSelectArea("TMPSZQ")
dbGoTop()

If TMPSZQ->(EOF())
   Alert("Dados da legenda não cadastrados!")
Endif
    
While !EOF()
	aAdd(aLegenda,{ AllTrim(TMPSZQ->COR_LEGENDA)	,	AllTrim(TMPSZQ->LEGENDA)	} ) 	
	dbSkip()                       
EndDo   
 
aAdd(aLegenda,{"BR_VERDE"	,	AllTrim(GETMV("CF_STATUSP"))	} ) 	

	
Return aLegenda


