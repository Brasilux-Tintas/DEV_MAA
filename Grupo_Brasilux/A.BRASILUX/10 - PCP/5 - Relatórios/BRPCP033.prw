#Include "RWMAKE.CH"
#Include "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFun็ใo    ณ BRPCP032 บ Autor ณ Nelieder Corneta   บ Data ณ  22/11/2021 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Etiqueta de volume via paramentros			              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function BRPCP033()
Local cPerg   := Padr("BRPCP033",10)

u_zcfga01("BRPCP033")

if Pergunte(cPerg,.T.) 

    consulta()
    ReportPrint()

endif





Return


Static Function consulta()

          

cBordero1 = alltrim(mv_par01) // nบ bordero de pedidos
dDtBord1 = mv_par02 // dt 1 bordero de pedidos
dDtBord2 = mv_par03 // dt 2 bordero de pedidos
cBordesp = alltrim(mv_par04) // nบ de bordero de despacho 
cPedido1 = mv_par05 // Pedido de ?
cPedido2 = mv_par06 // Pedido Ate ?

cProd1 = mv_par07 // produto de ?
cProd2 = mv_par08 // produto ate ?

cLocaliz1 = mv_par09 // quadrante de ?
cLocaliz2 = mv_par10 // quadrante de ?

cImpePed = mv_par11 // imprimir nบ do pedido

cPrint = mv_par12 // qual impressora

ordem = mv_par13 // ordem de impressใo

cEmpresa = ''

cQry  = " SELECT C9_PEDIDO,C9_CLIENTE,SC5.C5_VOLUME1,"
cQry += " CODBARRA = CASE WHEN (B1PED.B1_TIPO = 'PA') AND (LEN(B1PED.B1_COD) = 12) AND (B1PED.B1_CODBAR > '') THEN '1'+B1_CODBAR ELSE '' END," 

//IIF(!EMPTY(cBordesp),"ZB_LOCALIZ",IIF(!empty(cBordero1),"ZG_LOCALIZ","''"))+" AS ZG_LOCALIZ,"+;

if!EMPTY(cBordesp)
cQry += " ZB_LOCALIZ"

    IF(!empty(cBordero1))
       cQry += "ZG_LOCALIZ "
    else   
       cQry +=" " 
    endif   
       cQry +=" AS ZG_LOCALIZ ,"

endif       

/*IIF(ordem == 1,"","dbo.DetVol(C9_FILIAL,C9_PRODUTO) AS RELVOL,C9_PRODUTO,"+;
"C9_QTDLIB,EMBA2 = CASE WHEN LEN(C9_PRODUTO) = 12 THEN SUBSTRING(C9_PRODUTO,11,2) ELSE '' END,"+;
"ISNULL(B2_LOCALIZ,'') AS B2_LOCALIZ,ISNULL(Z1_VOLJUNT,'S') AS Z1_VOLJUNT,")+;*/

cQry += " ISNULL(A1_NOME,'') AS A1_NOME,ISNULL(A1_MUN,'') AS A1_MUN,ISNULL(A1_EST,'') AS A1_EST,"
cQry += " ISNULL(A2_NOME,'') AS A2_NOME,ISNULL(A2_MUN,'') AS A2_MUN,ISNULL(A2_EST,'') AS A2_EST,"
cQry += " A4_NOME,A4_REGIAO "
// ,CODANT = IIF(cEmpresa == "07","B1PED.B1_XCODANT ","'' ")

IF ordem == 3
	cQry += ",REFORDEM = CASE WHEN (SB2.B2_LOCALIZ = '') THEN '0' WHEN (SUBSTRING(SC9.C9_PRODUTO,1,3) IN ('BM ','BL ')) THEN '1' ELSE '2' END,GRPEMBA = ISNULL((SELECT TOP 1 B1_GRUPO2 FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "+;
	"LEFT OUTER JOIN "+RetSqlName("SB1")+" B1E WITH (NOLOCK) ON (B1E.D_E_L_E_T_ = '') AND (G1_FILIAL = B1E.B1_FILIAL) AND (G1_COMP = B1E.B1_COD) "+;
	"WHERE (SG1.D_E_L_E_T_ = '') AND (G1_FILIAL = SC9.C9_FILIAL) AND (G1_COD = SC9.C9_PRODUTO) AND (B1E.B1_GRUPO LIKE 'E%') AND (B1E.B1_GRUPO2 > '')),'99') "
ENDIF 

cQry += "FROM "+RetSqlName("SC9")+" SC9 WITH (NOLOCK) "

if !empty(cBordero1) .OR. !empty(dDtBord2)
	cQry += "RIGHT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH (NOLOCK) ON (SZG.D_E_L_E_T_ <> '*') AND (ZG_FILIAL = '"+xFilial("SZG")+"') AND (C9_PEDIDO = RIGHT(ZG_PEDIDO,6)) "
	IF !empty(cBordero1)
		cQry += "AND (ZG_CODIGO = '"+cBordero1+"') "
	ENDIF 
	IF !empty(dDtBord2) 
		cQry += "LEFT OUTER JOIN "+RetSqlName("SZF")+" SZF WITH (NOLOCK) ON (SZF.D_E_L_E_T_ <> '*') AND (ZF_FILIAL = '"+xFilial("SZF")+"') AND (ZG_CODIGO = ZF_CODIGO) "
	ENDIF 
ENDIF 

IF !EMPTY(cBordesp)
	cQry += "RIGHT OUTER JOIN "+RetSqlName("SZB")+" SZB WITH (NOLOCK) ON (SZB.D_E_L_E_T_ <> '*') AND (ZB_FILIAL = '"+xFilial("SZB")+"') AND (ZB_CODIGO = '"+cBordesp+"') AND (C9_PEDIDO = RIGHT(ZB_PEDIDO,6)) "
ENDIF 
cQry += "LEFT OUTER JOIN "+RetSqlName("SB1")+" B1PED WITH (NOLOCK) ON (C9_FILIAL = B1PED.B1_FILIAL) AND (C9_PRODUTO = B1PED.B1_COD) AND (B1PED.D_E_L_E_T_ <> '*') "
cQry += "LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (C9_CLIENTE = A1_COD) AND (SA1.D_E_L_E_T_ <> '*') AND (LEN(C9_CLIENTE) = 6) "
cQry += "LEFT OUTER JOIN "+RetSqlName("SA2")+" SA2 WITH (NOLOCK) ON (C9_CLIENTE = A2_COD) AND (SA2.D_E_L_E_T_ <> '*') AND (LEN(C9_CLIENTE) = 5) "

//IIF(ordem == 1,""," LEFT OUTER JOIN "+RetSqlName("SZ1")+" SZ1 WITH (NOLOCK) ON (SUBSTRING(C9_PRODUTO,4,2) = Z1_LINHA) "+;
//"AND (SZ1.D_E_L_E_T_ <> '*') AND (Z1_FILIAL = '"+xFilial("SZ1")+"') ")+;

cQry += "LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (C9_FILIAL = C5_FILIAL) AND (C9_PEDIDO = C5_NUM) AND (SC5.D_E_L_E_T_ <> '*') "
cQry += "LEFT OUTER JOIN "+RetSqlName("SA4")+" SA4 WITH (NOLOCK) ON (SC5.C5_REDESP = A4_COD) AND (SA4.D_E_L_E_T_ <> '*') "
cQry += "LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON (SB2.D_E_L_E_T_ <> '*') AND (B2_FILIAL = '"+xFilial("SB2")+"') AND (B1PED.B1_COD = B2_COD) AND (B1PED.B1_LOCPAD = B2_LOCAL) "
cQry += "WHERE "
cQry +=  "(SC9.D_E_L_E_T_ <>  '*') AND (SC9.C9_FILIAL = '"+xFilial('SC9')+"') AND (SC5.C5_APROVA = '1') AND (LEN(B2_LOCALIZ) > 0) "
if !empty(cPedido2) .and. (cPedido2 >= cPedido1)
	cQry +=  "AND (SC9.C9_PEDIDO BETWEEN '"+cPedido1+"' AND '"+cPedido2+"') "
ENDIF

IF !EMPTY(cLocaliz2)
	cQry +=  "AND (SB2.B2_LOCALIZ BETWEEN '"+ALLTRIM(cLocaliz1)+"' AND '"+cLocaliz2+"') "
endif
	

if !empty(cProd2) .and. (cProd2 >= cProd1)
	cQry += "AND (SC9.C9_PRODUTO >= '"+cProd1+"') AND (SC9.C9_PRODUTO <= '"+cProd2+"') "
endif

if !empty(dDtBord2)
	cQry += "AND SZF.ZF_EMISSAO BETWEEN '"+dtos(dDtBord1)+"' AND '"+dtos(dDtBord2)+"')"
endif

/* verifica quem ้ o usuแrio */
    cUsuario = PswChave(RetCodUsr())
    if (cUsuario == 'neliedercorneta') 
        /* gera log do script sql */
        GravaSQL(cQry)
    Endif

 /* verifica se arquivo estแ aberto e finaliza */
    IF Select("QCON") <> 0
        DbSelectArea("QCON")
        DbCloseArea()
    ENDIF
    
    //TMPP QCON
    TCQUERY cQry NEW ALIAS "QCON"  
    //Count To nTotal 

    dbSelectArea("QCON")
    QCON->(dbGoTop())

return()

Static Function ReportPrint()
Private oPrint
Private oFont10     := TFont():New('Arial',,10,,.F.,,,,.F.,.F.)
Private oFont10n    := TFont():New('Arial',,10,,.T.,,,,.F.,.F.)

dbSelectArea("QCON")
QCON->(dbGoTop())

    oPrint := TMSPrinter():New(OemToAnsi('Etiqueta de produto'))
    oPrint:SetPortrait()
    

    While !QCON->(eof())

    //QCON->C9_PEDIDO
    nRow1 := 0
     oPrint:StartPage()  
 
            nLin  := 0010
            oPrint:Say(nLin,0010,OemToAnsi('Pedido : '),oFont10,,,,0)
            oPrint:Say(nLin,0120,OemToAnsi(QCON->C9_PEDIDO),oFont10n,,,,0)
            nLin += 0030
            oPrint:Line (nRow1+0050,010,nRow1+0050,900)
            //TMSPrinter(): Line ( [ nTop], [ nLeft], [ nBottom], [ nRight], [ uParam5] ) -->
            oPrint:EndPage()
        
        QCON->(dbSkip())
    
    enddo

    oPrint:Preview()
    oPrint:end()

return


Static Function GravaSQL(script)

Local cArq := ""


cArq := "C:\Temp\sql.txt" //a pasta deve ser vแlida.


MemoWrite ( cArq , script )


Return


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
    //ณ Variaveis utilizadas para parametros	  								ณ
    //ณ mv_par01		 // Do Produto                      					ณ
    //ณ mv_par02		 // Ate Produto                   						ณ
    //ณ mv_par03		 // Do Tipo                       						ณ
    //ณ mv_par04		 // Ate Tipo                       						ณ
    //ณ mv_par05		 // Do Grupo                      						ณ
    //ณ mv_par06		 // Ate Grupo                     						ณ
    //ณ mv_par07		 // Apenas Linha                  	  				    ณ
    //ณ mv_par08		 // Do Bordero de Pedidos         						ณ
    //ณ mv_par09		 // Ate Bodero de Pedidos          						ณ
    //ณ mv_par10		 // Puxar todos especificos Border						ณ
    //ณ mv_par11		 // Bordero de Despacho           						ณ
    //ณ mv_par12		 // Nบ Pedido de Vendas           						ณ
    //ณ mv_par13		 // Apenas Itens do Estoque       						ณ
    //ณ mv_par14		 // Somento c/Lib de Credito      						ณ
    //ณ mv_par15		 // Apenas itens nao Estoque      						ณ
    //ณ mv_par16		 // Lista itens zerados           						ณ
    //ณ mv_par17		 // Trazer somente Frabrica 1     						ณ
    //ณ mv_par18		 // Trazer somente Frabrica 2     						ณ
    //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

