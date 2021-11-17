#include 'totvs.ch'
#include "protheus.ch"
#include "TOPCONN.CH"
#include "rwmake.ch"
//============================================================================//
// Autor    | Dyego Figueiredo / www.chaus.com.br                             //
//----------------------------------------------------------------------------//
// Data     | 31/05/2015                                                      //
//----------------------------------------------------------------------------//
// Desc.    | Este ponto de entrada e executado na rotina de Geraçao de che-  //
//          | ques. 							    						  //
//----------------------------------------------------------------------------//
// Objetivo | Validar se o fornecedor do cheque possui algum titulo PA ou NCF //
//          | que pode ser compensado.						              	  //
//----------------------------------------------------------------------------//
// Programa |																  //
// Fonte	| FINA390.PRW													  //
//----------------------------------------------------------------------------//
// Partida  | Menu de programa                                                //
//============================================================================//
//26/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function FA390TOK() 
     Private _cAlias, nOyder, nReg, nRetorno, cparam, cMacrMemo
     Private xValrMacr, xTemporaria, nCampo

     If ALLTRIM(FWGrpCompany()) == '11' //Empresas que são do grupo 11(Tecpolpa).
        _cAlias   := Alias()
        nOrder    := Indexord()
        nReg      := Recno()
        nRetorno  := .T. //Alterado por Igor Manrique - estava como .F. e não estava trazendo nenhum título
        If !Empty(cForn390)
           U_ValidaPA(cForn390)
        Endif

        dbSelectArea(_cAlias)
        dbSetOrder(nOrder)
        dbGoTo(nReg)
     Else
        nRetorno := .t.
     Endif
Return(nRetorno)

User Function ValidaPA(cFornece)
     Local i
     Private _aAmb := {}, lRetorno := .t., _aTitulos := {}, _cTitulos := "", _nSaldo := 0


//ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//Salva o Ambiente.
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
_aAmb := GetArea()

_cquery := " "
_cquery += " SELECT E2_NOMFOR, E2_FILIAL, E2_FORNECE, E2_LOJA, E2_NUM, E2_PREFIXO, E2_PARCELA, SUM(E2_SALDO) AS E2_SALDO "
_cquery += " FROM "+RetSqlName("SE2") + " SE2 "
_cquery += " WHERE SE2.E2_FILIAL = '" 	+ xFilial("SE2") + "' 	"
_cquery += "   AND SE2.E2_FORNECE = '" 	+ cFornece + "' 		"
//_cquery += "   AND SE2.E2_LOJA = '" 	+ cLoja + "' 			"
_cquery += "   AND SE2.D_E_L_E_T_ = ' ' 						"
_cquery += "   AND (SE2.E2_TIPO = 'PA' OR SE2.E2_TIPO = 'NCF') 	"
_cquery += "   AND (E2_SALDO) > 0  					"
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


If _nSaldo > 0 
 	msgbox("Existe em aberto o saldo de " + AllTrim(Transform(_nSaldo,"@ze 999,999,999.99")) + " em títulos PA/NCF para o fornecedor " + cFornece+" - "  + cNomeFor + "!" + chr(13) + chr(13);
				+ " Título(s) PA/NCF: " + AllTrim(_cTitulos), "FA390TOK.PRW", "ALERT")
 	
	
	lRetorno := .f.
Endif

Dbselectarea("TMPPA")
TMPPA->(DbCloseArea())

//ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//Restaura o Ambiente.
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
RestArea(_aAmb)


Return(lRetorno)
