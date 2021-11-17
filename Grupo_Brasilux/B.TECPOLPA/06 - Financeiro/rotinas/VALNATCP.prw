//============================================================================//
// Autor    | Dyego Figueiredo / www.chaus.com.br                             //
//----------------------------------------------------------------------------//
// Data     | 31/05/2015                                                      //
//----------------------------------------------------------------------------//
// Desc.    | Esta rotina e chamada na validacao dos campos E2_NATUREZ,   	  //
//          | E5_NATUREZ												      //
//----------------------------------------------------------------------------//
// Objetivo | Validar se a natureza passada por parametro foi classificada    //
//          | como a pagar no cadastro de natureza (campo ED_USO)          	  //
//----------------------------------------------------------------------------//
// Programa |																  //
// Fonte	| VALNATCP.PRW													  //
//----------------------------------------------------------------------------//
// Partida  | Validacao dos campos: E2_NATUREZ, E5_NATUREZ                    //                                    
//============================================================================//


#include 'totvs.ch'
#include "protheus.ch"
#include "TOPCONN.CH"
#include "rwmake.ch"



User Function VALNATCP(_natureza)


Local lRet := .T.
Local xvalNat := GETMV("MV_XNATPAG")

Local cED_USO := Posicione("SED",1,XFILIAL("SED")+_natureza,"ED_USO")

/*
n - não faz nada                                  
a- só avisa que a natureza não é do contas a pagar
b- avisa e bloqueia se natureza não é do c. pagar 
*/
If Upper(xvalNat) == 'A' .AND. cED_USO != '2' .AND. cED_USO != '3' 
	Alert("A natureza selecionada não foi classificada como a pagar! (campo Uso Natureza - ED_USO)")
ElseIf Upper(xvalNat) == 'B' .AND. cED_USO != '2' .AND. cED_USO != '3' 
	 lRet := .F.
	 Alert("A natureza selecionada não foi classificada como a pagar (campo Uso Natureza - ED_USO). Selecione uma natureza válida!")
Endif


Return lRet