//============================================================================//
// Autor    | Dyego Figueiredo / www.chaus.com.br                             //
//----------------------------------------------------------------------------//
// Data     | 31/05/2015                                                      //
//----------------------------------------------------------------------------//
//Desc.     | Retorna o icms do estado do cliente passado por parametro 	  //
//----------------------------------------------------------------------------//
//Programa  |																  //
//Fonte		|Usado na rotina RMarkup.PRW	    							  //
//----------------------------------------------------------------------------//
// Partida  | Menu de programa                                                //
//============================================================================//

#Include 'Protheus.ch'
#INCLUDE "AP5MAIL.CH"
#include 'topconn.ch'
#include "rwmake.ch"



User Function RICMSCLI(_cliente, _loja)

	Local cEstCli := Posicione("SA1",1,XFILIAL("SA1")+_cliente+ _loja,"A1_EST")

	nAliqEst := Val(Subs(GetMV("mv_esticm"), AT(cEstCli,GetMV("mv_esticm"))+2,2))
	
	
Return nAliqEst





