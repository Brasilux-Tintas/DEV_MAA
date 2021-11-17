#Include "Topconn.ch"
#Include "Protheus.ch"
//============================================================================//
// Autor    | Dyego Figueiredo / www.chaus.com.br                             //
//----------------------------------------------------------------------------//
// Data     | 31/05/2015                                                      //
//----------------------------------------------------------------------------//
// Descricao| O ponto de entrada FA080TIT sera utilizado na confirmacao da    //
//          | tela de baixa do contas a pagar, antes da gravacao dos dados.   //
//----------------------------------------------------------------------------//
// Objetivo | Verifica se o fornecedor possui titulos PA em aberto.           //
//----------------------------------------------------------------------------//
// Programa |																  //
// Fonte	|FINA080.PRW													  //
//----------------------------------------------------------------------------//
// Partida  | Menu de programa                                                //
//============================================================================//
//26/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function FA080TIT()
     Local lREt := .T.
     Local aArea:= GetArea()

     If ALLTRIM(FWGrpCompany()) == '11' //Empresas que são do grupo 11(Tecpolpa).
        aArea:= GetArea()
        lRet := u_RFIN0001(SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_PREFIXO)
        RestArea(aArea)
     Endif
Return(lRet)



