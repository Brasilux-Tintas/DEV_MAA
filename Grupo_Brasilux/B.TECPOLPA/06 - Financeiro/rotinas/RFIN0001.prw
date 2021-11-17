//============================================================================//
// Autor    | Dyego Figueiredo / www.chaus.com.br                             //
//----------------------------------------------------------------------------//
// Data     | 31/05/2015                                                      //
//----------------------------------------------------------------------------//
// Desc.    | Esta rotina e chamada em varios pontos de entrada do financeiro.//
//----------------------------------------------------------------------------//
// Objetivo | Validar se o fornecedor do titulo possui algum titulo PA ou NCF //
//          | que pode ser compensado.						              	  //
//----------------------------------------------------------------------------//
// Programa |																  //
// Fonte	| RFIN0001.PRW													  //
//----------------------------------------------------------------------------//
// Partida  | Pontos de entrada:F090TIT, F240TDOK, F240TIT, FA080TIT          // 
//============================================================================//

#include 'totvs.ch'
#include "protheus.ch"
#include "TOPCONN.CH"
#include "rwmake.ch"


User Function RFIN0001(cFornece, cLoja, cNumTit, cParcela, cPrefixo)

Local i,  _aAmb 	:= {}, lRetorno := .t., _aTitulos := {}, _cTitulos := "", _nSaldo := 0

//Parametro que define se o somente exibira o aviso, se exibira e bloqueara o usuario ou se nao vai ocorrer nada.
Local xTitPa := GETMV("MV_XTITPA")


If Upper(xTitPa) == 'N'
 	Return .T.
Endif 

//ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//Salva o Ambiente.
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
_aAmb := GetArea()

_cquery := " "
_cquery += " SELECT E2_NOMFOR, E2_FILIAL, E2_FORNECE, E2_LOJA, E2_NUM, E2_PREFIXO, E2_PARCELA, SUM(E2_SALDO) AS E2_SALDO "
_cquery += " FROM "+RetSqlName("SE2") + " SE2 "
_cquery += " WHERE SE2.E2_FILIAL = '" 	+ xFilial("SE2") + "' 	"
_cquery += "   AND SE2.E2_FORNECE = '" 	+ cFornece + "' 		"
_cquery += "   AND SE2.E2_LOJA = '" 	+ cLoja + "' 			"
_cquery += "   AND SE2.D_E_L_E_T_ = ' ' 						"
_cquery += "   AND (SE2.E2_TIPO = 'PA' OR SE2.E2_TIPO = 'NCF') 	"
_cquery += "   AND E2_SALDO > 0  					"
_cquery += " GROUP BY E2_NOMFOR, E2_FILIAL, E2_FORNECE, E2_LOJA, E2_NUM, E2_PREFIXO, E2_PARCELA "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"TMPPA",.F.,.T.)

Dbselectarea("TMPPA")
TMPPA->(Dbgotop())

cNomeFor := ""

While !eof()
	aadd(_aTitulos,{AllTrim(TMPPA->E2_NUM) + " " + AllTrim(TMPPA->E2_PREFIXO) + iif(Len(AllTrim(TMPPA->E2_PARCELA)) > 0, " Parc.: " + AllTrim(TMPPA->E2_PARCELA),""),TMPPA->E2_SALDO})
	_nSaldo += TMPPA->E2_SALDO
	
	If Empty(cNomeFor)
		cNomeFor := AllTrim(TMPPA->E2_NOMFOR)
	Endif
	TMPPA->(dbSkip())
EndDo

If Len(_aTitulos)>0
	for i := 1 to Len(_aTitulos)
		_cTitulos += iif(i > 1,", ","") + _aTitulos[i][1]
	next i
EndIf


If _nSaldo > 0 .AND. (Upper(xTitPa) == 'A' .OR. Upper(xTitPa) == 'B'  )

	If  Upper(xTitPa) == 'B' 
		 lRetorno := .f.
	Endif

 	If Empty(cNumTit) 
 		msgbox("Existe em aberto o saldo de " + AllTrim(Transform(_nSaldo,"@ze 999,999,999.99"))  + chr(13) + chr(13);
				+ " Título(s) PA/NCF: " + AllTrim(_cTitulos), "Tecpolpa - RFIN0001.PRW", "ALERT")
 	Else
		msgbox("Existe em aberto o saldo de " + AllTrim(Transform(_nSaldo,"@ze 999,999,999.99")) + " em títulos PA/NCF para o fornecedor " + cFornece+" Loja: " + cLoja + " - " + cNomeFor + "! Utilize a rotina de compensação para baixar o título/prefixo/parcela: " + cNumTit + " / " + cPrefixo + " / " + cParcela+ "!" + chr(13) + chr(13);
				+ " Título(s) PA/NCF: " + AllTrim(_cTitulos), "Tecpolpa - RFIN0001.PRW", "ALERT")
 	
	Endif
	
	
Endif

Dbselectarea("TMPPA")
TMPPA->(DbCloseArea())

//ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//Restaura o Ambiente.
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
RestArea(_aAmb)


Return(lRetorno)


