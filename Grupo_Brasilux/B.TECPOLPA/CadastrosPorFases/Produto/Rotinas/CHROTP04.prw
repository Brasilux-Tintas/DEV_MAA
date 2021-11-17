#Include 'Protheus.ch'
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH" 


/*
 Chamado no ponto de entrada MT010COR. 
 Objetivo: incluir legendas de cores no cadastro de produto
*/

User function CHROTP04()

	aCores := query01( ) 
	
Return aCores




// Retorna as legendas
Static Function query01( ) 
  
Local cQLinha   := Chr(13) + Chr(10)
Local aCores	:= {}  
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
   Alert("Dados das cores da legenda não cadastrados!")
Endif
    
While !EOF()
	aAdd(aCores,{'Alltrim(B1_XCETAPA) == "'+AllTrim(TMPSZQ->ETAPA)+'"'	,	AllTrim(TMPSZQ->COR_LEGENDA)			, ""		}) // -> Cadastro OK    	
	dbSkip()                       
EndDo   
 
aAdd(aCores,{'Alltrim(B1_XCETAPA) == "'+AllTrim(GETMV("CF_ETAPAP") )+'"'	,	"BR_VERDE"		, ""		}) // -> Cadastro OK    	
		
	
Return aCores


