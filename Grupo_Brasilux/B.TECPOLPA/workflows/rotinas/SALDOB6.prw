#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TOTVS.CH"

//Dyego Figueredo
//Rotina gerar um tabela com os saldos de terceiros por tras dos TAs ainda nao retornados
User Function SALDOB6()

MsgRun('Calculando Saldo de Insumos em TAs..','Aguarde...',{|| U_INSUMOS_SB6(  )  })

CallIReport("R15",{"0",1,.T.,.T.})

Return

//Gera dados e incluir na tabela INSUMOS_SB6
User Function INSUMOS_SB6()
	Local i := 0
	Local j := 0

	PREPARE ENVIRONMENT EMPRESA '11' FILIAL '11'

	//apaga os dados
	TCSQLExec("DROP TABLE INSUMOS_SB6 " )

	TCSQLExec("CREATE TABLE INSUMOS_SB6 (COD_TA	VARCHAR(12),LOTE_TA	VARCHAR(30),QTD_TA	FLOAT, COD_INS	VARCHAR(12),QTD_INS FLOAT) ")



	// busca os produtos com saldo no E1PA
	aSB8 := Query01( )

	For i := 1  to len(aSB8)

		cCodTA 		:= aSB8[i][1] // cProduto
		cLoteTA 	:= aSB8[i][4] // cLote
		nSaldoTa 	:= aSB8[i][3] // nSaldo

		TCSQLExec("INSERT INTO INSUMOS_SB6 (COD_TA, LOTE_TA, QTD_TA) VALUES ('"+cCodTA+"', '"+cLoteTA+"', "+STR(nSaldoTa)+")" )


		aSD3 := Query02(cCodTA, cLoteTA, nSaldoTa ) // cProduto, cLote, nSaldo

		For j := 1 to len(aSD3)
			cCodIns := aSD3[j][1] //B1_COD
			nQtdIns := aSD3[j][2] //QTD_INSUMO_CALC

			TCSQLExec("INSERT INTO INSUMOS_SB6 (COD_TA, LOTE_TA, QTD_TA,  COD_INS, QTD_INS) VALUES ('"+cCodTA+"', '"+cLoteTA+"', "+STR(0)+" , '"+cCodIns+"' , '"+STR(nQtdIns)+"')" )

		Next j

	Next i




Return


// produto no E1PA com saldo
Static function Query01( )

	Private cQLinha   := Chr(13) + Chr(10)

	If Select("TMREST")<>0
		dbselectarea("TMREST")
		dbclosearea()
	Endif


	/*cQuery := "SELECT B1_COD, B1_DESC, B8_SALDO, B8_LOTECTL, B8_LOCAL	"+cQLinha
	cQuery += "FROM  "+RetSqlName("SB8")+" SB8							"+cQLinha
	cQuery += "		 	INNER JOIN "+RetSqlName("SB1")+" SB1 (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = B8_PRODUTO AND SB1.D_E_L_E_T_ = '' AND B1_MSBLQL <> '1'"+cQLinha
	cQuery += "WHERE SB8.D_E_L_E_T_ = ''								"+cQLinha
	cQuery += "AND B8_LOCAL != 'D1PA'									"+cQLinha
	cQuery += "AND B8_SALDO > 0											"+cQLinha
	cQuery += "AND B1_TIPO = 'TA' 										"+cQLinha
	cQuery += "AND B8_FILIAL = '"+xFilial("SB8")+"'						"+cQLinha
	*/

	cQuery := "SELECT  B1_COD, B1_DESC,  BJ_QINI B8_SALDO, BJ_LOTECTL B8_LOTECTL, BJ_LOCAL B8_LOCAL	"
	cQuery += "FROM  SBJ110 SBJ							"
	cQuery += "		 	INNER JOIN SB1110 SB1 (NOLOCK) ON B1_FILIAL = '11' AND B1_COD = BJ_COD AND SB1.D_E_L_E_T_ = '' AND B1_MSBLQL <> '1' "
	cQuery += "WHERE SBJ.D_E_L_E_T_ = '' "
	cQuery += "AND BJ_LOCAL != 'D1PA'		"
	cQuery += "AND BJ_QINI > 0				"
	cQuery += "AND B1_TIPO = 'TA' "
	cQuery += "AND BJ_DATA = '20171231' "
	cQuery += "AND BJ_FILIAL = '11'	"


	TCQUERY cQuery ALIAS TMREST NEW
	dbSelectArea("TMREST")
	dbGoTop()

	arrayb8 = {}
	While !TMREST->(EOF())
		aadd(arrayb8, {TMREST->B1_COD, TMREST->B1_DESC, TMREST->B8_SALDO, TMREST->B8_LOTECTL, TMREST->B8_LOCAL})
		TMREST->(dbskip())
	EndDO



Return	arrayb8



// faz a regra de 3 e retorna a quantidade dos insumos nao retornados
Static function Query02(cProduto, cLote, nSaldo )

	Private cQLinha   := Chr(13) + Chr(10)

	If Select("TMD3")<>0
		dbselectarea("TMD3")
		dbclosearea()
	Endif


	cQuery := "SELECT B1_COD, QTD_INSUMO_CALC												"+cQLinha
	cQuery += "FROM [dbo].[FN_QTD_INSUMOS] ( '"+cProduto+"',  '"+cLote+"', "+STR(nSaldo)+")	"+cQLinha

	TCQUERY cQuery ALIAS TMD3 NEW
	dbSelectArea("TMD3")
	dbGoTop()

	arrayd3 = {}
	While !TMD3->(EOF())
		aadd(arrayd3, {TMD3->B1_COD, TMD3->QTD_INSUMO_CALC})
		TMD3->(dbskip())
	EndDO


Return	arrayd3



