#Include 'Protheus.ch'
//============================================================================//
// Autor    | Dyego Figueiredo / www.chaus.com.br                             //
//----------------------------------------------------------------------------//
// Data     | 31/05/2015                                                      //
//----------------------------------------------------------------------------//
// Descricao| Ponto de Entrada cujo objetivo é a criação de regra de validação//
//          | para permitir ou bloquear a seleção do título na geração do     //
//          | borderô, por meio da rotina Transferências (FINA060)			  //
//----------------------------------------------------------------------------//
// Objetivo | Verificar se cliente do titulo a ser baixado possui um RA ou NCC// 
//          | em aberto, e sugere a compensação.						      //
//----------------------------------------------------------------------------//
// Programa  |																  //
// Fonte	| FINA060.PRW													  //
//----------------------------------------------------------------------------//
// Partida  | Menu de programa                                                //
//============================================================================//
//26/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function FA060VLD                                             
     Local cMarca := ParamIxb[1]
     Local cAlias := ParamIxb[2]
     Local lRet   := .T.
     Local aArea  := GetArea()

     If ALLTRIM(FWGrpCompany()) == '11' //Empresas que são do grupo 11(Tecpolpa).
        //Desmarcado
        If ! IsMark("E1_OK", cMarca)
           lRet := u_RFIN0002((cAlias)->E1_CLIENTE, (cAlias)->E1_LOJA,(cAlias)->E1_NUM, (cAlias)->E1_PARCELA, (cAlias)->E1_PREFIXO )
        Endif
        RestArea(aArea)
     Endif
Return lRet

//IsMark("E1_OK", cMarca)

