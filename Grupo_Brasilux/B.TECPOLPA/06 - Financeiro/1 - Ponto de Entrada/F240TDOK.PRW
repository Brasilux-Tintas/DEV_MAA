#Include 'Protheus.ch'
//============================================================================//
// Autor    | Dyego Figueiredo / www.chaus.com.br                             //
//----------------------------------------------------------------------------//
// Data     | 31/05/2015                                                      //
//----------------------------------------------------------------------------//
// Descricao| O ponto de entrada F240TDOK é utilizado para validações comple- //
//          | mentares dos títulos selecionados na geração do borderô, será   //
//			| executado apenas se for confirmada esta geração.				  //
//----------------------------------------------------------------------------//
// Objetivo | Objetivo do mesmo e verificar se os titulos selecionados poderao//
//          | ser compensados com um PA ou NCF. 	     					  //
//----------------------------------------------------------------------------//
// Programa |																  //
// Fonte		|FINA240.PRW												  //
//----------------------------------------------------------------------------//
// Partida  | Menu de programa                                                //
//============================================================================//
//26/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function F240TDOK
	Local peAliasSE2 := paramixb[2]
	Local lRetorno := .t.
	Local aArea

    If ALLTRIM(FWGrpCompany()) = '11' //Empresas que são do grupo 11(Tecpolpa).
       aArea	:= GetArea()
       If !Empty( paramixb[1] )
          While !(peAliasSE2)->(Eof())
                lRetorno := u_RFIN0001(E2_FORNECE, E2_LOJA,SE2->E2_NUM, E2_PARCELA, E2_PREFIXO )
                If !lRetorno
                   Exit
                Endif
                dbSkip()
          End
       EndIf
       RestArea(aArea)
    Endif
Return lRetorno
