#Include "RWMAKE.CH"
#Include "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫FunÁ„o    ≥ BRPCP030 ∫ Autor ≥ Nelieder Corneta   ∫ Data ≥  26/10/2021 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫DescriÁ„o ≥ RelatÛrio ProgramaÁ„o da ProduÁ„o BrasTintas               ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/


User Function BRPCP030()

   Local oReport := nil
   Local cPerg   := Padr("BRPCP030",10)
   Local xNome   := "ProgramaÁ„o da ProduÁ„o"
   Local Xdescri := "ProgramaÁ„o da ProduÁ„o baseada no bordero de pedidos"
   Pergunte(cPerg,.F.)              
   oReport := RptDef(cPerg,xNome,Xdescri)
   oReport:PrintDialog()

   //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
    //≥ Variaveis utilizadas para parametros	  								≥
    //≥ mv_par01		 // Do Produto                      					≥
    //≥ mv_par02		 // Ate Produto                   						≥
    //≥ mv_par03		 // Do Tipo                       						≥
    //≥ mv_par04		 // Ate Tipo                       						≥
    //≥ mv_par05		 // Do Grupo                      						≥
    //≥ mv_par06		 // Ate Grupo                     						≥
    //≥ mv_par07		 // Apenas Linha                  	  				    ≥
    //≥ mv_par08		 // Do Bordero de Pedidos         						≥
    //≥ mv_par09		 // Ate Bodero de Pedidos          						≥
    //≥ mv_par10		 // Puxar todos especificos Border						≥
    //≥ mv_par11		 // Bordero de Despacho           						≥
    //≥ mv_par12		 // N∫ Pedido de Vendas           						≥
    //≥ mv_par13		 // Apenas Itens do Estoque       						≥
    //≥ mv_par14		 // Somento c/Lib de Credito      						≥
    //≥ mv_par15		 // Apenas itens nao Estoque      						≥
    //≥ mv_par16		 // Lista itens zerados           						≥
    //≥ mv_par17		 // Trazer somente Frabrica 1     						≥
    //≥ mv_par18		 // Trazer somente Frabrica 2     						≥
    //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ


Return


/*/{Protheus.doc} RptDef
Gera impress„o relatÛrio
@type function 
@version 12.1.25 
@author neliedercorneta
@since 29/10/2021
@param pPergunta, character, variavel pergunta
@param xNome, character, nome do relatÛrio
@param Xdescri, character, descriÁ„o detalhada do relatÛrio
@return variant, retorna impress„o do relatÛrio
/*/
Static Function RptDef(xPergunta,xNome,Xdescri)
    
	Local oReport := Nil
    Local oSection1:= Nil
    
    oReport := TReport():New(xPergunta,xNome,xPergunta,{|oReport| ReportPrint(oReport)},Xdescri)
    oReport:SetPortrait(.F.) // retrato    
	oReport:SetLandscape(.T.) // paisagem
    oReport:SetTotalInLine(.F.) // Define se os totalizadores ser„o impressos em linha ou coluna
    
    oSection1:= TRSection():New(oReport,xNome,,, .F., .T.)

    /* campos para impress„o do relatÛrio */
    TRCell():New(oSection1,"B1_COD"        ,"TMPP","Produto"          ,"@!",20)
    TRCell():New(oSection1,"B1_DESC"  ,"TMPP","DescriÁ„o"    ,"@!",55)
	TRCell():New(oSection1,"B2_LOCALIZ"  ,"TMPP","LocalizaÁ„o"    ,"@!",30)
	TRCell():New(oSection1,"B2_SALDO"  ,"TMPP","Saldo Atual"    ,"@E 99999,999",30, , ,"CENTER", , "CENTER")
	TRCell():New(oSection1,"VR_LBC"  ,"TMPP","Lib CrÈdito"    ,"@E 99999,999",30, , ,"CENTER", , "CENTER")
    TRCell():New(oSection1,"VR_OPC"  ,"TMPP","OPs Colocadas"    ,"@!",30, , ,"CENTER", , "CENTER")
    TRCell():New(oSection1,"VR_PNL"  ,"TMPP","Ped N„o Lib"    ,"@!",30, , ,"CENTER", , "CENTER")
    TRCell():New(oSection1,"VR_M3M"  ,"TMPP","MÈd 3 m"    ,"@E 99999,999",30, , ,"CENTER", , "CENTER")
    TRCell():New(oSection1,"VR_MP3"  ,"TMPP","MÈd P 3 m"    ,"@!",30, , ,"CENTER", , "CENTER")
    TRCell():New(oSection1,"VR_OP3"  ,"TMPP","OPs 3m"    ,"@!",30, , ,"CENTER", , "CENTER")
    TRCell():New(oSection1,"VR_CLI"  ,"TMPP","Clientes"    ,"@!",30, , ,"CENTER", , "CENTER")
    TRCell():New(oSection1,"VR_SPU"  ,"TMPP","Sug Prod Ult Fat"    ,"@!",30, , ,"CENTER", , "CENTER")
    TRCell():New(oSection1,"VR_FAT"  ,"TMPP","Fat"    ,"@!",30, , ,"CENTER", , "CENTER")
       
Return(oReport)


/*/{Protheus.doc} ReportPrint
Imprime RelatÛrio
@type function
@version  12.1.25
@author neliedercorneta
@since 29/10/2021
@param oReport, object, variavel impress„o
@return variant, sem retorno
/*/
Static Function ReportPrint(oReport)
    Local oSection1 := oReport:Section(1)
    Local cQuery    := ""        
    Local xVarProd  := ""        
    Local xVarLib   := ""
    Local xOPsc     := 0
    Local X_VR_M3M  := 0
    Local X_VR_PNL  := 0
    Local cUsuario  := ""
    
    IncProc()
    /* imprime regua progress„o */
    oReport:SetMsgPrint("Aguarde selecionando Registros...")

    /* 021063 bordero teste de pedido */

 	cQuery := "    SELECT DISTINCT B1_COD, B1_DESC, B1_TIPO , B1_UM , B1_GRUPO,B2_LOCALIZ, "
    cQuery += "    (SELECT SUM(B2_QATU) FROM "+RETSQLNAME("SB2")+" SB2 WHERE SB2.B2_COD = SB1.B1_COD  AND SB2.D_E_L_E_T_ = '')B2_SALDO "
    cQuery += "    ,SB1.B1_UM AS UNIMED   "
    cQuery += "    FROM "+RETSQLNAME("SB1")+" SB1 WITH (NOLOCK)  "
    cQuery += "    LEFT JOIN "+RETSQLNAME("SB2")+" SB2 WITH (NOLOCK) ON (SB2.D_E_L_E_T_ <> '*') AND (B1_FILIAL = B2_FILIAL) AND (B1_COD = B2_COD) AND (B1_LOCPAD = B2_LOCAL)   "
    
    
    
    /* puxa todos os especificos do bordero */
    If (mv_par10 == 1)
        cQuery += "    INNER JOIN "+RETSQLNAME("SZG")+" BORDPED WITH (NOLOCK) ON (BORDPED.D_E_L_E_T_ <> '*') AND (BORDPED.ZG_FILIAL = '"+xFilial("SZG")+"')   "
        cQuery += "     AND (BORDPED.ZG_CODIGO BETWEEN '"+alltrim(mv_par08)+"' AND '"+alltrim(mv_par09)+"')  "
        cQuery += "    INNER JOIN "+RETSQLNAME("SC6")+" SC6 WITH (NOLOCK) ON (SC6.D_E_L_E_T_ <> '*') AND  "
        cQuery += "    (C6_FILIAL = '"+xFilial("SC6")+"') AND (SUBSTRING(BORDPED.ZG_PEDIDO,3,6) = C6_NUM) AND (SUBSTRING(C6_PRODUTO,1,10) = SUBSTRING(B1_COD,1,10)) "
        
    else
        cQuery += "  INNER JOIN "+RETSQLNAME("ZZC")+" BORDPED WITH (NOLOCK) ON (BORDPED.D_E_L_E_T_ <> '*') AND (BORDPED.ZZC_FILIAL = '"+xFilial("ZZC")+"') AND (BORDPED.ZZC_BORDER BETWEEN '"+mv_par08+"' AND '"+mv_par09+"')   "
        cQuery += "  AND ((ZZC_QUANTI - ZZC_RETIRA) > 0)  "
        cQuery += "  AND (SUBSTRING(B1_COD,1,10) = SUBSTRING(BORDPED.ZZC_PRODUT,1,10))  "
        
    EndIf
    
    /* filtra bordero de despacho */
    If !empty(alltrim(mv_par11))
        cQuery += "    LEFT OUTER JOIN "+RETSQLNAME("ZZC")+" BORDDESP WITH (NOLOCK) ON (BORDDESP.D_E_L_E_T_ <> '*') AND (BORDDESP.ZZC_FILIAL = '"+xFilial("ZZC")+"') AND (BORDDESP.ZZC_CARGA = '"+alltrim(mv_par11)+"') AND ((ZZC_QUANTI - ZZC_RETIRA) > 0) AND (SUBSTRING(B1_COD,1,10) = SUBSTRING(BORDDESP.ZZC_PRODUT,1,10)) "
    ENDIF

	cQuery += " WHERE SB1.D_E_L_E_T_ = '' AND B1_FILIAL = '"+xFilial("SB1")+"' "
    cQuery += " AND B1_COD BETWEEN '"+alltrim(mv_par01)+"' AND '"+alltrim(mv_par02)+"'  "	
    cQuery += " AND B1_TIPO BETWEEN '"+alltrim(mv_par03)+"' AND '"+alltrim(mv_par04)+"' "
	cQuery += " AND B1_GRUPO BETWEEN '"+alltrim(mv_par05)+"' AND '"+alltrim(mv_par06)+"'  "		
    
    
    If !empty(alltrim(mv_par07)) 
        /* apenas linha do produto */
        cQuery += " AND (SUBSTRING(B1_COD,4,2)) = '"+alltrim(mv_par07)+"' "
    Endif 

    If (mv_par10 == 1)
        /* puxa todos os especificos dos bordero */
         cQuery += " AND (B2_LOCALIZ = '')  "
    Endif

    If !empty(alltrim(mv_par11))
    /* filtra bordero de despacho */
		cQuery += " AND (BORDDESP.R_E_C_N_O_ IS NOT NULL) "
	ENDIF
    
    If !empty((mv_par12)) 
        /* filtra pedido de venda */
        cQuery += "    AND C6_NUM = '"+mv_par12+"' "    
    Endif   

    If (mv_par13 == 1)
        /* apenas itens estoque */
        cQuery += " AND (SB2.B2_COD IS NOT NULL)     "
    Endif 

    If !empty(alltrim(mv_par14)) 
        /* somento com liberaÁ„o de crÈdito */
        // cQuery += " AND C5_LIBCRE = 'T' "
    Endif 

    If (mv_par15 == 1)
        /* apenas itens n„o estoque */
        cQuery += " AND (B2_LOCALIZ = '')     "
    Endif 

    If (mv_par16 == 1)
        /* lista itens zerados */
        cQuery += "    AND (SB2.B2_QATU <> 0.0) "
    Endif

    If (mv_par17 == 1)
        /* filtra fabrica 1*/
        cQuery += " AND (B1_LOCPAD IN ('02','P1'))  "
    Endif   

    If (mv_par18 == 1)
        /* filtra fabrica 2*/
        cQuery += " AND (B1_LOCPAD IN ('20','P2'))   "
    Endif 
  

    /* ordena codigo do produto */
    cQuery += "    ORDER BY B1_COD "

    /* verifica quem È o usu·rio */
    cUsuario = PswChave(RetCodUsr())
    if (cUsuario == 'neliedercorneta') 
        /* gera log do script sql */
        GravaSQL(cQuery)
    Endif
    
    /* verifica se arquivo est· aberto e finaliza */
    IF Select("TMPP") <> 0
        DbSelectArea("TMPP")
        DbCloseArea()
    ENDIF
    
    TCQUERY cQuery NEW ALIAS "TMPP"  
    Count To nTotal 
    oReport:SetMsgPrint("Registros encontrados "+cValToChar(nTotal)) 
    
    dbSelectArea("TMPP")
    TMPP->(dbGoTop())
    
    oReport:SetMeter(TMPP->(LastRec()))    
    /* percorre registros */
    While !TMPP->(eof())
        
        If oReport:Cancel()
            Exit
        EndIf
    
        /* inicializo a primeira seÁ„o */
        oSection1:Init()
        /* incrementa a regua do relatÛrio */
        oReport:IncMeter()

        oReport:SetMsgPrint("Analisando Produto "+cValToChar(alltrim(TMPP->B1_COD)))

        xVarProd = SUBSTRING(alltrim(TMPP->B1_COD),1,10)
        
        //imprimo a primeira seÁ„o                
        oSection1:Cell("B1_COD"):SetValue(TMPP->B1_COD)
        oSection1:Cell("B1_DESC"):SetValue(TMPP->B1_DESC)                
		oSection1:Cell("B2_LOCALIZ"):SetValue(TMPP->B2_LOCALIZ)                
		oSection1:Cell("B2_SALDO"):SetValue( ROUND(TMPP->B2_SALDO,2) )  
		
        xVarLib = F_VR_LBC(alltrim(TMPP->B1_COD))
        
        oSection1:Cell("VR_LBC"):SetValue(xVarLib)  
        
        
        xOPsc = F_VR_OPC(alltrim(TMPP->B1_COD))
        oSection1:Cell("VR_OPC"):SetValue(ROUND(xOPsc,2))  
        
        /* pedidos n„o liberados */
        X_VR_PNL = F_VR_PNL(alltrim(TMPP->B1_COD))
         
        oSection1:Cell("VR_PNL"):SetValue(X_VR_PNL)  
        

        X_VR_M3M = F_VR_M3M(alltrim(TMPP->B1_COD))
        oSection1:Cell("VR_M3M"):SetValue(X_VR_M3M)  

        oSection1:Cell("VR_MP3"):SetValue( F_VR_MP3(alltrim(TMPP->B1_COD),xVarLib,xOPsc,X_VR_M3M,X_VR_PNL) )  
        oSection1:Cell("VR_OP3"):SetValue(F_VR_OP3(alltrim(TMPP->B1_COD)))  
        oSection1:Cell("VR_CLI"):SetValue(F_VR_CLI(alltrim(TMPP->B1_COD)))  
        oSection1:Cell("VR_SPU"):SetValue(F_VR_SUP(alltrim(TMPP->B1_COD)))  
        oSection1:Cell("VR_FAT"):SetValue(F_VR_FAT(alltrim(TMPP->B1_COD)))  
        
               
        
        
        oSection1:Printline()
        TMPP->(dbSkip())

        //if SUBSTRING(alltrim(TMPP->B1_COD),1,10) <> xVarProd
            //linha horizontal
            //oReport:ThinLine()
        //EndIf    
      
    Enddo
	   //finalizo a primeira seÁ„o
        oSection1:Finish()
Return


/*/{Protheus.doc} F_VR_LBC
Lib Credito, soma qtd produtos
@type function
@version 12.1.25  
@author neliedercorneta
@since 29/10/2021
@param cProduto, character, codigo do produto
@return variant, valor lib credito
/*/
Static Function F_VR_LBC(cProduto)
  Local return_var
  Local cQuery1    := ""        
  
	cQuery1 := " SELECT C6_PRODUTO AS CODPRO,SUM(SC6.C6_QTDVEN ) AS QTDLIB "
	cQuery1 += "FROM "+RETSQLNAME("SC6")+" SC6 WITH (NOLOCK) "
	cQuery1 += "LEFT OUTER JOIN "+RETSQLNAME("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ = '') AND (C6_FILIAL = SC5.C5_FILIAL) AND (C6_NUM = SC5.C5_NUM) "
	cQuery1 += "LEFT OUTER JOIN "+RETSQLNAME("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ = '') AND (C6_FILIAL = B1_FILIAL) AND (C6_PRODUTO = B1_COD) "
	cQuery1 += "LEFT OUTER JOIN "+RETSQLNAME("SB2")+" SB2 WITH (NOLOCK) ON (SB2.D_E_L_E_T_ <> '*') AND (B1_FILIAL = B2_FILIAL) AND (B1_COD = B2_COD) AND (B1_LOCPAD = B2_LOCAL) "
	cQuery1 += "WHERE (SC6.D_E_L_E_T_ <> '*') AND (SC6.C6_FILIAL = '"+xFilial("SC6")+"') AND "
	cQuery1 += "(SC6.C6_PRODUTO BETWEEN '"+cProduto+"' AND '"+cProduto+"') "
	cQuery1 += "AND (C5_APROVA <> '2') AND (SC6.C6_NOTA = '') AND (C5_LIBPED = 'T') AND (C5_LIBCRE = 'T') "
	cQuery1 += "GROUP BY C6_PRODUTO ORDER BY CODPRO "

    IF Select("TLIB") <> 0
        DbSelectArea("TLIB")
        DbCloseArea()
    ENDIF

    TCQUERY cQuery1 NEW ALIAS "TLIB"    
    
    dbSelectArea("TLIB")
	return_var = TLIB->QTDLIB

Return return_var


/*/{Protheus.doc} F_VR_OPC
OPs Colocadas
@type function
@version 12.1.25  
@author neliedercorneta
@since 29/10/2021
@param cProduto, character, codigo do produto
@return variant, qtd op n„o colocadas
/*/
Static Function F_VR_OPC(cProduto)
  Local return_var
  Local cQuery2    := ""        
  
	cQuery2 := " SELECT SUM(SC2.C2_QUANT) AS QTDPRD "
    cQuery2 += " FROM "+RETSQLNAME("SC2")+" SC2 WITH (NOLOCK) "
    cQuery2 += " WHERE (SC2.D_E_L_E_T_ <> '*') AND (SC2.C2_FILIAL  = '"+xFilial("SC2")+"') AND "
    cQuery2 += " (SC2.C2_PRODUTO = '"+cProduto+"') AND (SC2.C2_DATRF = '') "
    cQuery2 += " AND (SC2.C2_QUANT > SC2.C2_QUJE) "

    IF Select("TOPR") <> 0
        DbSelectArea("TOPR")
        DbCloseArea()
    ENDIF

    TCQUERY cQuery2 NEW ALIAS "TOPR"    
    
    dbSelectArea("TOPR")
	return_var = ROUND(TOPR->QTDPRD,2)

Return return_var


/*/{Protheus.doc} F_VR_PNL
Pedidos n„o liberados
@type function
@version  12.1.25
@author neliedercorneta
@since 29/10/2021
@param cProduto, character, codigo do produto
@return variant, qtd pedidos
/*/
Static Function F_VR_PNL(cProduto)

   /* regra para calculo de pedidos n„o liberados */
   /* pega o resultado da query QCON3.QTDLIB
      soma com a variavel nQtdlib = nQtdlib + pedrelac.qtde */
    Local cQuery2    := ""  

    cQuery2 := " SELECT C6_PRODUTO AS CODPRO,SUM(SC6.C6_QTDVEN ) AS QTDLIB "
    cQuery2 += " FROM "+RETSQLNAME("SC6")+" SC6 WITH (NOLOCK) 
    cQuery2 += " LEFT OUTER JOIN "+RETSQLNAME("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ = '') AND (C6_FILIAL = SC5.C5_FILIAL) AND (C6_NUM = SC5.C5_NUM) 
    cQuery2 += " LEFT OUTER JOIN "+RETSQLNAME("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ = '') AND (C6_FILIAL = B1_FILIAL) AND (C6_PRODUTO = B1_COD) 

	/*	IF thisform.lEstoque.Value OR !thisform.lZerados.Value */ 
		cQuery2 += " LEFT OUTER JOIN "+RETSQLNAME("SB2")+" SB2 WITH (NOLOCK) ON (SB2.D_E_L_E_T_ <> '*') AND (B1_FILIAL = B2_FILIAL) AND (B1_COD = B2_COD) AND (B1_LOCPAD = B2_LOCAL) "
	/*	ENDIF */ 
    cQuery2 += " WHERE (SC6.D_E_L_E_T_ <> '*') AND (SC6.C6_FILIAL = '"+xFilial("SC6")+"') AND (SC6.C6_PRODUTO BETWEEN '"+alltrim(mv_par08)+"' AND '"+alltrim(mv_par09)+"') "

	cQuery2 += " AND (C5_APROVA <> '2') AND (SC6.C6_NOTA = '') AND (C5_LIBPED = 'T') AND (C5_LIBCRE = 'T') "

    If !empty((mv_par12)) 
        /* filtra pedido*/
		cQuery2 += " AND (C6_NUM = '') "
	ENDIF 

    If !empty(alltrim(mv_par07)) 
        /* linha */
        cQuery2 += " AND (SUBSTRING(C6_PRODUTO,4,2) = '') "
    ENDIF

	If (mv_par16 == 1)
		/* zerados */
        cQuery2 += " AND (SB2.B2_QATU <> 0.0) "
	ENDIF  

	If (mv_par15 == 1)
        /* apenas itens n„o estoque */
        cQuery2 += " AND (ISNULL(SB2.B2_LOCALIZ,'') > '') "
	ENDIF 

		cQuery2 += " GROUP BY C6_PRODUTO ORDER BY CODPRO  "    
  
	IF Select("TPNL") <> 0
        DbSelectArea("TPNL")
        DbCloseArea()
    ENDIF

    TCQUERY cQuery2 NEW ALIAS "TPNL"    
    
    dbSelectArea("TPNL")
	
    return_var = TPNL->QTDLIB

Return return_var



/*/{Protheus.doc} F_VR_M3M
MÈdia ultimos 3 meses
@type function
@version  12.1.25
@author neliedercorneta
@since 29/10/2021
@param cProduto, character,codigo do produto
@return variant, calculo da mÈdia
/*/
Static Function F_VR_M3M(cProduto)
  Local return_var
  Local cQuery2    := ""        
  
	cQuery2 := " SELECT ZZ2_MEDIA AS MEDPRO  "
    cQuery2 += " FROM "+RETSQLNAME("ZZ2")+" ZZ2 WITH (NOLOCK)"
    cQuery2 += " WHERE  (ZZ2.ZZ2_FILIAL = '"+xFilial("ZZ2")+"') AND (ZZ2.ZZ2_COD = '"+cProduto+"') AND (D_E_L_E_T_ <> '*')  "

    IF Select("TMEP") <> 0
        DbSelectArea("TMEP")
        DbCloseArea()
    ENDIF

    TCQUERY cQuery2 NEW ALIAS "TMEP"    
    
    dbSelectArea("TMEP")
	return_var = TMEP->MEDPRO

Return return_var

/*/{Protheus.doc} F_VR_MP3
MÈdia de Pedidos os ultimos 3 meses
@type function
@version 12.1.25 
@author neliedercorneta
@since 29/10/2021
@param cProduto, character, codigo do produto
@param nQTDLIB, numeric, qtd pedidos liberados
@param nQtdPrd, numeric, qtd de produtos
@param nMedPro, numeric, media de produtos
@param NQTDPED, numeric, qtd pedidos
/*/
Static Function F_VR_MP3(cProduto,nQTDLIB,nQtdPrd,nMedPro,NQTDPED)

  Local return_var  := ""        
  Local cQuery2     := ""        
  Local nQTDSUG     := ""        
  LOCAL nMedPed     := 0

  /* nQTDPED pedidos n„o liberados */  

    cQuery2 := " SELECT SUM(SB2.B2_QATU) AS QTDATU,  "
    cQuery2 += " MAX(SB2.B2_LOCALIZ) AS LOCALIZ"
    cQuery2 += " FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) "
    cQuery2 += " WHERE (SB2.D_E_L_E_T_ <> '*') "
    cQuery2 += " AND (SB2.B2_FILIAL = '"+xFilial("SB2")+"') "
    cQuery2 += " AND (SB2.B2_COD = '"+cProduto+"')"
    cQuery2 += " AND (SB2.B2_LOCAL NOT IN ('13','90','98'))"

     IF Select("TMP3") <> 0
        DbSelectArea("TMP3")
        DbCloseArea()
    ENDIF

    TCQUERY cQuery2 NEW ALIAS "TMP3"    
    
    dbSelectArea("TMP3")

    /* pedidos liberados */ 
    nMedPed = F_PEDLIB(cProduto)
        
    nQTDSUG = nQTDLIB - TMP3->QTDATU - nQtdPrd
		
		IF nQTDSUG <= 0
			nQTDSUG = 0
		ELSE 
			if nMedPed < 3
                nQTDSUG = nQTDSUG
            elseif (nMedPed >= 3) .and. (nMedPed < 6)
                nQTDSUG = nQTDSUG + nMedPro * 2
            elseif (nMedPed >= 6)
                nQTDSUG = nQTDSUG + nQTDPED + nMedPro * 3
                nQTDSUG = 0
            Endif            
            /*DO case
			CASE nMedPed < 3
				nQTDSUG = nQTDSUG
			CASE (nMedPed >= 3) AND (nMedPed < 6)
				nQTDSUG = nQTDSUG + nMedPro*2
			CASE (nMedPed >= 6)
				nQTDSUG = nQTDSUG + nQTDPED + nMedPro*3
			ENDCASE */
		ENDIF 			   

return_var = nQTDSUG

Return return_var


/*/{Protheus.doc} F_VR_OP3
Ordens de ProduÁ„o e meses
@type function
@version 12.1.25 
@author neliedercorneta
@since 29/10/2021
@param cProduto, character, codigo do produto

/*/
Static Function F_VR_OP3(cProduto)
  Local return_var
  Local cQuery2    := ""        
  
	cQuery2 := " SELECT C2_PRODUTO AS CODPRO,COUNT(SC2.R_E_C_N_O_) AS QTDEOPS   "
    cQuery2 += " FROM "+RETSQLNAME("SC2")+" SC2 WITH (NOLOCK) "
    cQuery2 += " LEFT OUTER JOIN "+RETSQLNAME("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (C2_FILIAL = B1_FILIAL) AND (C2_PRODUTO = B1_COD)  "
    cQuery2 += " WHERE (SC2.D_E_L_E_T_ <> '*') AND (C2_FILIAL = '"+xFilial("SC2")+"')   "
    cQuery2 += " AND SC2.C2_PRODUTO = '"+cProduto+"'  "
    cQuery2 += " AND (C2_DATRF >= CONVERT(VARCHAR,GETDATE()-90,112))  "
    cQuery2 += " GROUP BY C2_PRODUTO ORDER BY CODPRO  "
    

    IF Select("TOP3") <> 0
        DbSelectArea("TOP3")
        DbCloseArea()
    ENDIF

    TCQUERY cQuery2 NEW ALIAS "TOP3"    
    
    dbSelectArea("TOP3")
	return_var = TOP3->QTDEOPS



Return return_var

/*/{Protheus.doc} F_VR_CLI
Quantidade de clientes
@type function
@version  12.1.25
@author neliedercorneta
@since 29/10/2021
@param cProduto, character, codigo do produto
/*/
Static Function F_VR_CLI(cProduto)
  Local return_var
  Local cQuery2    := ""        

  cQuery2 := " WITH TMP AS (SELECT DISTINCT C5_CLIENTE,C6_PRODUTO   "
  cQuery2 += " FROM "+RETSQLNAME("SC6")+" SC6 WITH (NOLOCK)  "
  cQuery2 += " LEFT OUTER JOIN "+RETSQLNAME("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C6_FILIAL = C5_FILIAL) AND (C6_NUM = C5_NUM)  "
  cQuery2 += " WHERE (SC6.D_E_L_E_T_ <> '*') AND (C6_FILIAL = '"+xFilial("SC6")+"') AND   "
  cQuery2 += " (C5_TIPO = 'N') AND (C5_EMISSAO >= CONVERT(VARCHAR,GETDATE()-90,112)) AND C6_PRODUTO = '"+cProduto+"'  )   "
  cQuery2 += " SELECT C6_PRODUTO AS CODPRO,COUNT(C5_CLIENTE) AS QTDECLI FROM TMP GROUP BY C6_PRODUTO ORDER BY CODPRO  "
    

    IF Select("CLI") <> 0
        DbSelectArea("CLI")
        DbCloseArea()
    ENDIF

    TCQUERY cQuery2 NEW ALIAS "CLI"    
    
    dbSelectArea("CLI")
	return_var = CLI->QTDECLI

Return return_var

Static Function F_VR_SUP(cProduto)
Local return_var

return_var = ''
Return return_var


/*/{Protheus.doc} F_VR_FAT
data do ultimo faturamento
@type function
@version  12.1.25
@author neliedercorneta
@since 29/10/2021
@param cProduto, character, codigo do produto
/*/
Static Function F_VR_FAT(cProduto)
/* ultimo faturamento */
Local return_var
Local cQuery2    := ""        

    cQuery2 := " SELECT TOP 1 D2_EMISSAO AS ULTSAI FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK)   "
    cQuery2 += " WHERE (D_E_L_E_T_ <> '*') AND (D2_FILIAL = '"+xFilial("SD2")+"') AND (D2_ESTOQUE = 'S') AND (D2_COD = '"+cProduto+"') "
    cQuery2 += " ORDER BY ULTSAI DESC "
    
    IF Select("FAT") <> 0
        DbSelectArea("FAT")
        DbCloseArea()
    ENDIF

    TCQUERY cQuery2 NEW ALIAS "FAT"    
    
    dbSelectArea("FAT")
    return_var = STOD(FAT->ULTSAI)


Return return_var

/*/{Protheus.doc} F_PEDLIB
Pedidos Liberados
@type function
@version 12.1.25 
@author neliedercorneta
@since 29/10/2021
@param cProduto, character, codigo do produto
/*/
Static Function F_PEDLIB(cProduto)

/* funÁ„o que pega qtd de pedidos liberados */

Local return_var := ""        
Local cQuery2    := ""        
Local nMedPed    := 0

    cQuery2 := " SELECT C9_PRODUTO AS CODPRO,COUNT(C9_PRODUTO) AS QTDE  "
    cQuery2 += " FROM "+RetSqlName("SC9")+" SC9 WITH (NOLOCK) "
    cQuery2 += " LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C9_FILIAL = C5_FILIAL) AND (C9_PEDIDO = C5_NUM) "
    cQuery2 += " LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON (SC6.D_E_L_E_T_ <> '*') AND (C6_FILIAL = C9_FILIAL) AND (C9_PEDIDO = C6_NUM) AND (C6_ITEM = C9_ITEM)  "
    cQuery2 += " LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (F4_CODIGO = C6_TES)  "
    cQuery2 += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (C9_FILIAL = B1_FILIAL) AND (C9_PRODUTO = B1_COD) "
    /* AQUI TEM UM IF */
    cQuery2 += " WHERE (SC9.D_E_L_E_T_ <> '*') AND (C9_FILIAL = '"+xFilial("SC9")+"') "
    //cQuery2 += " AND (SC9.C9_PRODUTO BETWEEN '"+mv_par01+"' AND '"+mv_par02+"') "
    cQuery2 += " AND (SC9.C9_PRODUTO = '"+cProduto+"' ) "
    cQuery2 += " AND (SC5.C5_TIPO = 'N') AND (SC5.C5_APROVA = '1') AND (F4_ESTOQUE <> 'N') AND (F4_DUPLIC <> 'N') "
    /* AQUI TEM UM IF */
    cQuery2 += " AND (C9_GRUPO BETWEEN '"+mv_par05+"' AND '"+mv_par06+"')   "
    cQuery2 += " AND C6_PRODUTO =  '"+cProduto+"'  "
    cQuery2 += " AND (C5_EMISSAO >= CONVERT(VARCHAR,GETDATE()-90,112))   "
    cQuery2 += " GROUP BY C9_PRODUTO ORDER BY CODPRO  "

    IF Select("PLIB") <> 0
        DbSelectArea("PLIB")
        DbCloseArea()
    ENDIF

    TCQUERY cQuery2 NEW ALIAS "PLIB"    
    
    dbSelectArea("PLIB")
    nMedPed = nMedPed + PLIB->QTDE
	//nMedPed = ROUND(nMedPed/3,1)
    return_var = nMedPed


Return return_var

Static Function GravaSQL(script)

Local cArq := ""


cArq := "C:\Temp\sql.txt" //a pasta deve ser v·lida.


MemoWrite ( cArq , script )


Return

