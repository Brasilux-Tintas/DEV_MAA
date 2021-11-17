#INCLUDE "rwmake.ch"

#INCLUDE "topconn.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "rwmake.ch"

/*
Gatilha o preco da moeda
*/

User Function GatCustB1()

	Local aArea			:= GetArea()
	Local nRet := 0
	Local cMoeda := Substr(M->B1_XMOEDA, 1,1)
	Local nCusto := M->B1_XCusto
	Local nPrcMoeda := 0

	if Empty(cMoeda)
		cMoeda := '1'
	Endif

	If  Empty(cMoeda) .or. cMoeda == "1"
		nPrcMoeda := 1
	Else
		nPrcMoeda := FBuscaPreco(cMoeda)
	Endif

	nRet := nPrcMoeda * nCusto
	RestArea(aArea)
Return nRet


Static Function FBuscaPreco(cMoeda)
	//Local _cAlias := Alias()
	Local nValorMoeda := 0
	Local cQry1  := ''

	If Select("TMPSB1")<>0
		dbselectarea(TMPSB1)
		dbclosearea()
	Endif

	cQry1 := "SELECT  TOP 1 M2_MOEDA"+cMoeda+" AS VALOR FROM "+RetSQLName("SM2")+" SM2" +" WHERE   D_E_L_E_T_ = '' AND M2_MOEDA"+cMoeda+" > 0 ORDER BY M2_DATA DESC"
	TcQuery cQry1 ALIAS "TMPSB1" NEW
	DbSelectArea("TMPSB1")
	nValorMoeda := TMPSB1->VALOR
	TMPSB1->( DbCloseArea())

Return nValorMoeda