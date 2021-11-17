#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "rwmake.ch" 
#INCLUDE "AP5MAIL.CH"

 
#INCLUDE "TCBROWSE.CH"

/*
Programa  =GZZMCOMP ?Autor  =Dyego  - Chaus      ? Data =  17/05/2018  
Desc.     =Gatilho usado no preenchimento dos campos ZZM_QTMOD1,ZZM_QTMOD2 ,ZZM_QTMOD3				
          =Objetivo: Gravar as quantidade das MODs a partir de uma competencia  					 
*/

// u_GZZMCOMP(M->ZZM_COMPET, 'MOD147T1001')  'MOD147T1001', 'MOD147T1002', 'MOD147T1003'
User Function GZZMCOMP(anoMes, codMod)
 
Local nRet := {}

nRet := query01(anoMes, codMod)

Return nRet


Static Function query01(anoMes, codMod)


Local cQLinha   := Chr(13) + Chr(10)
Local nRet	:= 0  


If Select("TMPCUSTO")<>0
	dbselectarea("TMPCUSTO")
	dbclosearea()
Endif

cQuery := "SELECT  D3_COD, B1_DESC, SUM(D3_QUANT) D3_QUANT 										"+cQLinha
cQuery += "FROM    "+RetSqlName("SD3")+" SD3													"+cQLinha
cQuery += "            INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND  D3_COD = B1_COD AND SB1.D_E_L_E_T_= ' '			"+cQLinha
cQuery += "WHERE   SD3.D_E_L_E_T_= ' '															"+cQLinha
cQuery += "AND 	   D3_FILIAL = '"+xFilial("SD3")+"'  											"+cQLinha
cQuery += "AND     D3_COD IN ('"+codMod+"')   													"+cQLinha
cQuery += "AND     D3_ESTORNO = ' '   															"+cQLinha
cQuery += "AND     SUBSTRING(D3_EMISSAO, 1,6) IN ( '"+anoMes+"')  								"+cQLinha
cQuery += "GROUP BY SUBSTRING(D3_EMISSAO, 1,6), D3_COD, B1_DESC									"+cQLinha
cQuery += "ORDER BY 1																			"+cQLinha
	                                                                                  	                        

TCQUERY cQuery ALIAS TMPCUSTO NEW
dbSelectArea("TMPCUSTO")
dbGoTop()

 
If TMPCUSTO->(EOF())
//   MsgAlert("Não foram localizados dados nessa competência!" )
Endif
    
If TMPCUSTO->(!EOF())
	nRet := TMPCUSTO->D3_QUANT 	                      
Endif
		
	
Return nRet