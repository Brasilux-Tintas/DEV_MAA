//============================================================================//
// Autor    | Dyego Figueiredo / www.chaus.com.br                             //
//----------------------------------------------------------------------------//
// Data     | 31/05/2015                                                      //
//----------------------------------------------------------------------------//
//Desc.     | Caso seja o item do Pv seja um produto da tecpolpas, faz um adi //
//          | cional no preco, com base na alicota de icms do estado do clien-//
//          | te e no % de markup do parametro   							  //
//----------------------------------------------------------------------------//
//Programa  |																  //
//Fonte		|chamado em A410CONS e no gatilho C6_PRODUTO					  //
//----------------------------------------------------------------------------//
// Partida  | Menu de programa                                                //
//============================================================================//

#Include 'Protheus.ch'
#include "rwmake.ch"


User Function RMarkup (nPreco, cCliente, cLoja, cProduto)

 
Local nIcmsCli := 0


If Subs(cProduto, 2, 3) == "AAA" .AND.  Posicione("SB1",1,XFILIAL("SB1")+cProduto,"B1_TIPO") $ "MC/MP/EM"

	//nPreco := Posicione("SB1",1,XFILIAL("SB1")+cProduto,"B1_XUPRC") // DYEGO 21/11/16
	nPreco := Posicione("SB1",1,XFILIAL("SB1")+cProduto,"B1_XMAXPRC") // DYEGO 21/11/16

	nIcmsCli := u_RICMSCLI(cCliente, cLoja)
	nPreco := (nPreco + (nPreco * nIcmsCli/100.0 )) * (1+GETMV("MV_XPMARKU")/100)
Endif

Return nPreco
