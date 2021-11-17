#include "TOPCONN.CH"
#include "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
//Dyego Figueredo
//M410LIOK - Validação de linha de pedido
//26/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function MA440VLD()
     Local lRet := .T.

     If FWCodEmp() == '11' //Empresas que são do grupo 11(Tecpolpa).
        If (lRet .AND. GETMV("ZP_PAR0001"))		
           lRet := valLote()
        Endif
     Endif
Return lRet

Static Function valLote()
	Local lRet := .T.
	Local cProduto  := ACols[n,Ascan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})]
	Local cLote     := ACols[n,Ascan(aHeader,{|x| AllTrim(x[2]) == "C6_LOTECTL"})]
	Local cLocal    := ACols[n,Ascan(aHeader,{|x| AllTrim(x[2]) == "C6_LOCAL"})]
	Local nRede   := GETMV("ZP_PAR0002")
	Local nMarcaP := GETMV("ZP_PAR0003")
	
	cQuery :="SELECT B1_COD,B1_TIPO,B1_RASTRO,B8_DATA,B8_DTVALID,B8_LOCAL,B8_LOTECTL,DATEDIFF(DD,B8_DATA,B8_DTVALID) AS VALIDADE,DATEDIFF(DD,GETDATE(),B8_DTVALID) AS VENCIMENTO "
	cQuery +="FROM "+RetSqlName("SB8")+" SB8 "
	cQuery +="LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON B8_FILIAL = B1_FILIAL AND B8_PRODUTO = B1_COD AND SB1.D_E_L_E_T_ <> '*' "
	cQuery +="WHERE SB8.D_E_L_E_T_<> '*' AND B8_FILIAL ='"+xFilial("SB8")+"' AND B8_PRODUTO = '"+cProduto+"' AND B8_LOTECTL = '"+cLote+"' AND B8_LOCAL = '"+cLocal+"' "
	
	TCQUERY cQuery ALIAS "TCQ" NEW
	dbselectarea("TCQ")
		
	If ((TCQ->B1_TIPO == "PA" .OR. TCQ->B1_TIPO == "TA") .AND. (TCQ->B1_RASTRO == "L"))
		If (substr(cProduto,1,1) == "1" )
			If (TCQ->VENCIMENTO <= INT(TCQ->VALIDADE *(nMarcaP/100)))
				lRet := .F.
				MsgBox("Produto "+cProduto+" está com validade vencida!!!", "Atenção - MA440VLD.prw", "ALERT")
			EndIf
		ElseIf (substr(cProduto,1,1) == "2")
			If (TCQ->VENCIMENTO <= INT(TCQ->VALIDADE*(nRede/100)))
				lRet := .F.
				MsgBox("Produto "+cProduto+" está com validade vencida!!!", "Atenção - MA440VLD.prw", "ALERT")
			EndIf
		EndIf
	EndIf
	dbSelectArea("TCQ")
    dbCloseArea()    
Return lRet