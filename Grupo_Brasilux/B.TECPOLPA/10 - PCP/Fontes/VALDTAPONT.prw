#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"
#include "totvs.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TBICONN.CH"


//Dyego Figueiredo / Chaus
//Nao permite o apontamento ser maior que a data final da producao

User Function VALDTAPO 

Local lRet := .T.

If M->H6_DTAPONT != M->H6_DATAFIN
	 MsgInfo('A data do apontamento deve ser igual à data final da OP, mas para isso, volte a data base do sistema para a data final da OP', 'VALDTAPONT.PRW')
	  
 	 lRet := .F.
Endif


Return lRet
