#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#Include "RWMAKE.CH"
#Include "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFun็ใo    ณ BRPCP032 บ Autor ณ Nelieder Corneta   บ Data ณ  10/11/2021 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Etiqueta de volume							              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function BRPCP032(cPedido,cProduto)
//User Function BRPCP032()

//Local cPedido	:= '541683'
//Local cProduto	:= 'BT 260901514'

	u_zcfga01("BRPCP032")
	MsAguarde({|| Imprimir(cPedido,cProduto) },"Impressใo de etiqueta","Aguarde...")

Return


Static Function Imprimir(cPedido,cProduto)

/* Fun็ใo de Pesquisar e impressใo da Etiqueta */

Local cPorta 	:= "LPT1"
Local cModelo 	:= "ZEBRA"
Local cCod		:= ''
Local cEspe		:= ''
Local qLib		:= ''
Local qtdevol	:= ''






	cQuery := "SELECT DISTINCT C6_NUM AS C9_PEDIDO,C6_CLI AS C9_CLIENTE,SC5.C5_VOLUME1, "
    cQuery += " ISNULL(ZG_LOCALIZ,'') AS ZG_LOCALIZ,"
    cQuery += " dbo.DetVol(C6_FILIAL,C6_PRODUTO) AS RELVOL,C6_PRODUTO AS C9_PRODUTO, "
    cQuery += " C6_QTDVEN AS C9_QTDLIB,EMBA2 = CASE WHEN LEN(C6_PRODUTO) = 12 THEN SUBSTRING(C6_PRODUTO,11,2) ELSE '' END,"
    cQuery += " ISNULL(B2_LOCALIZ,'') AS B2_LOCALIZ,ISNULL(Z1_VOLJUNT,'S') AS Z1_VOLJUNT,"
    cQuery += " ISNULL(A1_NOME,'') AS A1_NOME,ISNULL(A1_MUN,'') AS A1_MUN,ISNULL(A1_EST,'') AS A1_EST,"
    cQuery += " ISNULL(A2_NOME,'') AS A2_NOME,ISNULL(A2_MUN,'') AS A2_MUN,ISNULL(A2_EST,'') AS A2_EST,"
    cQuery += " A4_NOME,A4_REGIAO,CODANT = '',C5_VOLUME1 AS QTDEVOL "
    cQuery += " FROM "+RETSQLNAME("SC6")+" SC6 WITH (NOLOCK) "
    cQuery += " LEFT OUTER JOIN "+RETSQLNAME("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = C6_FILIAL) AND (C5_NUM = C6_NUM) "
    cQuery += " LEFT OUTER JOIN "+RETSQLNAME("SA4")+" SA4 WITH (NOLOCK) ON (SC5.C5_REDESP = A4_COD) AND (SA4.D_E_L_E_T_ <> '*') "
    cQuery += " LEFT OUTER JOIN "+RETSQLNAME("SB2")+" SB2 WITH (NOLOCK) ON (SB2.D_E_L_E_T_ <> '*') AND (B2_FILIAL = C6_FILIAL) AND (B2_COD = C6_PRODUTO) AND (B2_LOCAL = C6_LOCAL) "
    cQuery += " LEFT OUTER JOIN "+RETSQLNAME("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (C5_TIPO NOT IN ('D','B')) AND (A1_COD = C6_CLI) "
    cQuery += " LEFT OUTER JOIN "+RETSQLNAME("SA2")+" SA2 WITH (NOLOCK) ON (SA2.D_E_L_E_T_ <> '*') AND (C5_TIPO IN ('D','B')) AND (A2_COD = C6_CLI) "    
    cQuery += " LEFT OUTER JOIN "+RETSQLNAME("SZ1")+" SZ1 WITH (NOLOCK) ON (SZ1.D_E_L_E_T_ <> '*') AND (LEN(C6_PRODUTO) = 12) AND (Z1_FILIAL = SUBSTRING(C6_FILIAL,1,2)) AND (Z1_LINHA = SUBSTRING(C6_PRODUTO,4,2)) "
    cQuery += " LEFT OUTER JOIN "+RETSQLNAME("SZG")+" SZG WITH (NOLOCK) ON (SZG.D_E_L_E_T_ <> '*') AND (ZG_FILIAL = C6_FILIAL) AND (C6_NUM = RIGHT(ZG_PEDIDO,6)) "
    cQuery += " WHERE (SC6.D_E_L_E_T_ <> '*') "
    cQuery += " AND (C6_FILIAL = '"+xFilial("SC6")+"') "
    cQuery += " AND (C6_NUM = '"+cPedido+"') "                    
    cQuery += " AND (C6_PRODUTO = '"+cProduto+"') "    
    cQuery += " ORDER BY B2_LOCALIZ,C9_PRODUTO,C9_PEDIDO "   

	IF Select("TMP") <> 0
        DbSelectArea("TMP")
        DbCloseArea()
    ENDIF     


	TcQuery cQuery New Alias "TMP"
	
	Count To nTotal

	TMP->(DbGoTop())

	if nTotal == 0
		MsgStop('Etiqueta nใo localizada', 'Etique Volume')
		return()
	endif

	While TMP->(!Eof())

		cCod = Alltrim(TMP->C9_PRODUTO)
		
		qtdevol = TMP->QTDEVOL
		qLib = TMP->C9_QTDLIB

		// Formata codigo do produto
		cCod = TRANSFORM(cCod, "@R XX 99.99.999-99") 
		MSCBPRINTER(cModelo, cPorta,,12,.F.,,,,,,.F.,)
		MSCBCHKSTATUS(.F.)
		MSCBBEGIN(1,6)

		/* regras produto */
		//iif(empty(b2_localiz),"*"," ")+allt(c9_produto)+"("+allt(str(c9_qtdlib))+"/"+allt(str(qtdevol))+")"
		
		if Empty(TMP->B2_LOCALIZ)
			cEspe = '*'
		else
			cEspe = ''
		endif			

		
		/* Pedido e Codigo do Produto */
		MSCBSAY(03,04,"PEDIDO:","N","A","015,008")
		MSCBSAY(14,03.5,Alltrim(TMP->C9_PEDIDO), "N", "0", "030,040") // negrito
		MSCBSAY(31,04,cEspe+cCod+"("+cValToChar(qLib)+"/"+cValToChar(qtdevol)+")", "N","0","020,028")
  	    MSCBLineH(00,7,190,3,'B')
		

		/* Nome do Cliente  */

		cCliente = Alltrim(TMP->A1_NOME)
		//cCliente = 'FIGUEIRA E SOARES COMERCIO DE TINTAS LTD'

		MSCBSAY(03,09,cCliente, "N", "0", "020,026") // negrito
		MSCBLineH(00,12,190,3,'B')

		/* Cidade */
		MSCBSAY(03,14,"Cidade: ","N","A","015,008") // negrito
		MSCBSAY(13,14,Alltrim(TMP->A1_MUN)+"-"+Alltrim(TMP->A1_EST), "N", "0", "020,030")
		MSCBLineH(00,17,190,3,'B')

		/* Transportadora */
		MSCBSAY(03,19,"REDESP: ","N","A","015,008")
		MSCBSAY(13,19,Alltrim(TMP->A4_NOME), "N", "0", "020,025")
		MSCBLineH(00,22,190,3,'B')

		/* volume */
		MSCBSAY(03,24,"Q VOL.: ","N","A","015,008")
		MSCBSAY(14,23.5,Alltrim(STR(TMP->QTDEVOL))+" L.: ", "N", "0", "030,040") // negrito
		MSCBLineH(00,27,190,3,'B')

		MSCBSAY(02,30,"Q:"+Alltrim(TMP->ZG_LOCALIZ),  "N", "0","40,70") // negrito
		MSCBEND()

		MSCBCLOSEPRINTER()
		TMP->(DbSkip())
	EndDo

return
