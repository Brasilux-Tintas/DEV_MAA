#Include 'Protheus.ch'
#include "rwmake.ch"
#INCLUDE "topconn.ch"
//============================================================================//
// Autor    | Dyego Figueiredo / www.chaus.com.br                             //
//----------------------------------------------------------------------------//
// Data     | 31/05/2015                                                      //
//----------------------------------------------------------------------------//
//Desc.     | Este ponto de entrada e executado na rotina de Baixa Auto- 	  //
//          | matica de titulos a pagar.		    						  //
//----------------------------------------------------------------------------//
//Objetivo  | Validar a selecao de titulos verificando se algum titulo        //
//          | marcado pode ser compensado com um PA ou NCF.              	  //
//----------------------------------------------------------------------------//
//Programa  |																  //
//Fonte		|FINA090.PRW													  //
//----------------------------------------------------------------------------//
// Partida  | Menu de programa                                                //
//============================================================================//
//26/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function F090TIT()
     Local _aAmb     := {}
     Local lRetorno  := .t.
     
     If ALLTRIM(FWGrpCompany()) = '11' //Empresas que são do grupo 11(Tecpolpa).
        _aAmb := GetArea()
        //avisa o usuario que existe titulos PA/ que podem ser negociados
        lRetorno := u_RFIN0001(SE2->E2_FORNECE, SE2->E2_LOJA,SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_PREFIXO )
        RestArea(_aAmb)
     Endif
Return(lRetorno)

