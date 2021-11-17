#Include 'Protheus.ch'
//============================================================================//
// Autor    | Dyego Figueiredo / www.chaus.com.br                             //
//----------------------------------------------------------------------------//
// Data     | 31/05/2015                                                      //
//----------------------------------------------------------------------------//
// Descricao| O ponto de entrada F110TIT sera chamado na funcao FA110Marca()  //
//          | que trata o valor para marcar e desmarcar item para baixa.      //
//----------------------------------------------------------------------------//
// Objetivo | Verificar se cliente do titulo a ser baixado possui um RA ou NCC// 
//          | em aberto, e sugere a compensação.						      //
//----------------------------------------------------------------------------//
// Programa  |																  //
// Fonte	| FINA110.PRW													  //
//----------------------------------------------------------------------------//
// Partida  | Menu de programa                                                //
//============================================================================//
//26/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function F110TIT()
     Local aArea := GetArea()
     Local lRet
     If ALLTRIM(FWGrpCompany()) == '11' //Empresas que são do grupo 11(Tecpolpa).
        lRet := u_RFIN0002(SE1->E1_CLIENTE, SE1->E1_LOJA,SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_PREFIXO )
        RestArea(aArea)
     Endif
Return lRet

