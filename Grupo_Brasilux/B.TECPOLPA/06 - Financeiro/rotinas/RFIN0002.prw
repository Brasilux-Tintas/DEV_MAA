//============================================================================//
// Autor    | Dyego Figueiredo / www.chaus.com.br                             //
//----------------------------------------------------------------------------//
// Data     | 31/05/2015                                                      //
//----------------------------------------------------------------------------//
// Desc.    | Esta rotina e chamada em varios pontos de entrada do financeiro.//
//----------------------------------------------------------------------------//
// Objetivo | Validar se o cliente do titulo possui algum titulo RA ou NCC    //
//          | que pode ser compensado.						              	  //
//----------------------------------------------------------------------------//
// Programa |																  //
// Fonte	| RFIN0002.PRW													  //
//----------------------------------------------------------------------------//
// Partida  | Pontos de entrada:F110TIT,FA060VLD, FA070TIT			          //   
//============================================================================//


#include 'totvs.ch'
#include "protheus.ch"
#include "TOPCONN.CH"
#include "rwmake.ch"


User Function RFIN0002(cCliente, cLoja, cNumTit, cParcela, cPrefixo)

Local i,  _aAmb 	:= {}, lRetorno := .t., _aTitulos := {}, _cTitulos := "", _nSaldo := 0

//Parametro que define se o somente exibira o aviso, se exibira e bloqueara o usuario ou se nao vai ocorrer nada.
Local xTitRa := GETMV("MV_XTITRA")


If Upper(xTitRa) == 'N'
 	Return .T.
Endif 

//ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//Salva o Ambiente.
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
_aAmb := GetArea()

_cquery := " "
_cquery += " SELECT E1_NOMCLI, E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_NUM, E1_PREFIXO, E1_PARCELA, SUM(E1_SALDO) AS E1_SALDO "
_cquery += " FROM "+RetSqlName("SE1") + " SE1 "
_cquery += " WHERE SE1.E1_FILIAL = '" 	+ xFilial("SE1") + "' 	"
_cquery += "   AND SE1.E1_CLIENTE = '" 	+ cCliente + "' 		"
_cquery += "   AND SE1.E1_LOJA = '" 	+ cLoja + "' 			"
_cquery += "   AND SE1.D_E_L_E_T_ = ' ' 						"
_cquery += "   AND (SE1.E1_TIPO = 'RA' OR SE1.E1_TIPO = 'NCC') 	"
_cquery += "   AND E1_SALDO > 0  					"
_cquery += " GROUP BY E1_NOMCLI, E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_NUM, E1_PREFIXO, E1_PARCELA "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"TMPPA",.F.,.T.)

Dbselectarea("TMPPA")
TMPPA->(Dbgotop())

cNomeFor := ""

While !eof()
	aadd(_aTitulos,{AllTrim(TMPPA->E1_NUM) + " " + AllTrim(TMPPA->E1_PREFIXO) + iif(Len(AllTrim(TMPPA->E1_PARCELA)) > 0, " Parc.: " + AllTrim(TMPPA->E1_PARCELA),""),TMPPA->E1_SALDO})
	_nSaldo += TMPPA->E1_SALDO
	
	If Empty(cNomeFor)
		cNomeCli := AllTrim(TMPPA->E1_NOMCLI)
	Endif
	TMPPA->(dbSkip())
EndDo

If Len(_aTitulos)>0
	for i := 1 to Len(_aTitulos)
		_cTitulos += iif(i > 1,", ","") + _aTitulos[i][1]
	next i
EndIf


If _nSaldo > 0 .AND. (Upper(xTitRa) == 'A' .OR. Upper(xTitRa) == 'B'  )

	If  Upper(xTitRa) == 'B' 
		 lRetorno := .f.
	Endif

 	If Empty(cNumTit) 
 		msgbox("Existe em aberto o saldo de " + AllTrim(Transform(_nSaldo,"@ze 999,999,999.99"))  + chr(13) + chr(13);
				+ " Título(s) RA/NCC: " + AllTrim(_cTitulos), " - RFIN0002.PRW", "ALERT")
 	Else
		msgbox("Existe em aberto o saldo de " + AllTrim(Transform(_nSaldo,"@ze 999,999,999.99")) + " em títulos RA/NCC para o cliente " + cCliente+" Loja: " + cLoja + " - " + cNomeCli + "! Utilize a rotina de compensação para baixar o título/prefixo/parcela: " + cNumTit + " / " + cPrefixo + " / " + cParcela+ "!" + chr(13) + chr(13);
				+ " Título(s) RA/NCC: " + AllTrim(_cTitulos), " - RFIN0002.PRW", "ALERT")
 	
	Endif
	
	
Endif

Dbselectarea("TMPPA")
TMPPA->(DbCloseArea())

//ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//Restaura o Ambiente.
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
RestArea(_aAmb)


Return(lRetorno)



