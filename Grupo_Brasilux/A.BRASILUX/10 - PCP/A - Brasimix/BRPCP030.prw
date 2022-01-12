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
    
    oReport:nfontbody:=7
    oReport:cfontbody:="Arial"
    
    oReport:SetPortrait(.F.) // retrato    
	oReport:SetLandscape(.T.) // paisagem
    oReport:SetTotalInLine(.F.) // Define se os totalizadores ser„o impressos em linha ou coluna
   
    //oReport:SetPaperSize(9)
    
    oSection1:= TRSection():New(oReport,xNome,,, .F., .T.)

    /* campos para impress„o do relatÛrio */
    TRCell():New(oSection1,"B1_COD"        ,"TMPP","Produto"  ,"@!",50, , ,"LEFT", , "LEFT")
    TRCell():New(oSection1,"B1_DESC"  ,"TMPP","DescriÁ„o"    ,"@!",55, , ,"LEFT", , "LEFT")
	TRCell():New(oSection1,"B2_LOCALIZ"  ,"TMPP","LocalizaÁ„o"    ,"@!",30, , ,"CENTER", , "CENTER")
	TRCell():New(oSection1,"B2_SALDO"  ,"TMPP","Saldo Atual"    ,"@E 999,999",30, , ,"CENTER", , "CENTER")
	TRCell():New(oSection1,"VR_LBC"  ,"TMPP","Lib CrÈdito"    ,"@E 999,999.99",30, , ,"CENTER", , "CENTER")
    TRCell():New(oSection1,"VR_OPC"  ,"TMPP","OPs Colocadas"    ,"@E 999,999.99",30, , ,"CENTER", , "CENTER")
    TRCell():New(oSection1,"VR_PNL"  ,"TMPP","Ped N„o Lib"    ,"@E 999,999.99",30, , ,"CENTER", , "CENTER")
    TRCell():New(oSection1,"VR_M3M"  ,"TMPP","MÈd 3 m"    ,"@E 999,999.99",30, , ,"CENTER", , "CENTER")
    TRCell():New(oSection1,"VR_MP3"  ,"TMPP","MÈd P 3 m"    ,"@E 999,999.99",30, , ,"CENTER", , "CENTER")
    TRCell():New(oSection1,"VR_OP3"  ,"TMPP","OPs 3m"    ,"@E 999,999.99",30, , ,"CENTER", , "CENTER")
    TRCell():New(oSection1,"VR_CLI"  ,"TMPP","Clientes"    ,"@E 999,999.99",30, , ,"CENTER", , "CENTER")
    TRCell():New(oSection1,"VR_SPU"  ,"TMPP","Sug Prod Ult Fat"    ,"@E 999,999",30, , ,"CENTER", , "CENTER")
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
    Local cQuery1    := ""        
    Local xVarProd  := ""        
    Local xVarLib   := ""
    Local xOPsc     := 0
    Local X_VR_M3M  := 0
    Local X_VR_PNL  := 0
    Local cUsuario  := ""
    Local conta     := 0
    Local porc      := 0
    Local V_PEDLIB  := 0
    
    IncProc()
    /* imprime regua progress„o */
    oReport:SetMsgPrint("Aguarde selecionando Registros...")

    /* 021063 bordero teste de pedido */
    
    //u_zcfga01("BRPCP030")

    cQuery1 := ""
    cQuery1 += " WITH SB2 AS (SELECT B2_COD,SUM(B2_QATU) AS SALDO "
	cQuery1 += " FROM "+RETSQLNAME("SB2")+" WITH (NOLOCK)  "
	cQuery1 += " WHERE (D_E_L_E_T_ <> '*') AND (B2_FILIAL = '"+xFilial("SB2")+"') AND " 
	cQuery1 += " (B2_LOCAL NOT IN ('13','90')) AND (B2_COD BETWEEN '"+mv_par01+"' AND '"+mv_par02+"') "

    IF (mv_par13 == 1) //thisform.lEstoque.Value
		cQuery1 += " AND (B2_LOCALIZ > '') "
	ELSE 
		IF (mv_par15 == 1) //thisform.lNaoestoque.Value
			cQuery1 += " AND (B2_LOCALIZ = '') "
		ENDIF 
	ENDIF 
	IF (mv_par10 == 1) //thisform.lEspeBord.Value
		cQuery1 += " AND (B2_LOCALIZ = '') " 
	ENDIF

	cQuery1 += " GROUP BY B2_COD) "

 	cQuery1 += "    SELECT DISTINCT B1_COD, B1_DESC, B1_TIPO , B1_UM , B1_GRUPO,B2_LOCALIZ, "
    cQuery1 += "    (SELECT SUM(B2_QATU) FROM "+RETSQLNAME("SB2")+" SB2 WHERE SB2.B2_COD = SB1.B1_COD  AND SB2.D_E_L_E_T_ = '')B2_SALDO "
    cQuery1 += "    ,SB1.B1_UM AS UNIMED   "
    cQuery1 += "    FROM "+RETSQLNAME("SB1")+" SB1 WITH (NOLOCK)  "
    cQuery1 += "    LEFT JOIN "+RETSQLNAME("SB2")+" SB2 WITH (NOLOCK) ON (SB2.D_E_L_E_T_ <> '*') AND (B1_FILIAL = B2_FILIAL) AND (B1_COD = B2_COD) AND (B1_LOCPAD = B2_LOCAL)   "
    
    
    
    /* puxa todos os especificos do bordero */

    cSC6 = .F.
    //mv_par08 thisform.cBordero1.Value
    //mv_par09 thisform.cBordero2.Value
    if ( !empty( alltrim(mv_par08) ) .and. !empty( alltrim( (mv_par09) )) )

            If (mv_par10 == 1) //thisform.lEspeBord.Value 
                cQuery1 += "    INNER JOIN "+RETSQLNAME("SZG")+" BORDPED WITH (NOLOCK) ON (BORDPED.D_E_L_E_T_ <> '*') AND (BORDPED.ZG_FILIAL = '"+xFilial("SZG")+"')   "
                cQuery1 += "     AND (BORDPED.ZG_CODIGO BETWEEN '"+alltrim(mv_par08)+"' AND '"+alltrim(mv_par09)+"')  "
                cQuery1 += "    INNER JOIN "+RETSQLNAME("SC6")+" SC6 WITH (NOLOCK) ON (SC6.D_E_L_E_T_ <> '*') AND  "
                cQuery1 += "    (C6_FILIAL = '"+xFilial("SC6")+"') AND (SUBSTRING(BORDPED.ZG_PEDIDO,3,6) = C6_NUM) AND (SUBSTRING(C6_PRODUTO,1,10) = SUBSTRING(B1_COD,1,10)) "
                cSC6 = .T.
                
            else
                cQuery1 += "  INNER JOIN "+RETSQLNAME("ZZC")+" BORDPED WITH (NOLOCK) ON (BORDPED.D_E_L_E_T_ <> '*') AND (BORDPED.ZZC_FILIAL = '"+xFilial("ZZC")+"') AND (BORDPED.ZZC_BORDER BETWEEN '"+mv_par08+"' AND '"+mv_par09+"')   "
                cQuery1 += "  AND ((ZZC_QUANTI - ZZC_RETIRA) > 0)  "
                cQuery1 += "  AND (SUBSTRING(B1_COD,1,10) = SUBSTRING(BORDPED.ZZC_PRODUT,1,10))  "

               
                
            EndIf
    endif    

    IF !empty(alltrim(mv_par12)) .AND. cSC6 == .F.
        /* filtra pedido de vendas */
	    cQuery1 +=  "LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON (SC6.D_E_L_E_T_ <> '*') AND (C6_FILIAL = '"+xFilial("SC6")+"') AND (C6_NUM = '"+mv_par12+"') AND (SUBSTRING(C6_PRODUTO,1,10) = SUBSTRING(B1_COD,1,10)) "
	ENDIF        
    
    
    /* filtra bordero de despacho */
    If !empty(alltrim(mv_par11))
        cQuery1 += "    LEFT OUTER JOIN "+RETSQLNAME("ZZC")+" BORDDESP WITH (NOLOCK) ON (BORDDESP.D_E_L_E_T_ <> '*') AND (BORDDESP.ZZC_FILIAL = '"+xFilial("ZZC")+"') AND (BORDDESP.ZZC_CARGA = '"+alltrim(mv_par11)+"') AND ((ZZC_QUANTI - ZZC_RETIRA) > 0) AND (SUBSTRING(B1_COD,1,10) = SUBSTRING(BORDDESP.ZZC_PRODUT,1,10)) "
    ENDIF

	cQuery1 += " WHERE SB1.D_E_L_E_T_ = '' AND B1_FILIAL = '"+xFilial("SB1")+"'  "

    If !empty(alltrim(mv_par02)) 
        cQuery1 += " AND (B1_COD BETWEEN '"+mv_par01+"' AND '"+mv_par02+"') "
    Endif

    If !empty(alltrim(MV_PAR04)) 
        cQuery1 += " AND (B1_TIPO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"') "
    Endif


    If !empty(alltrim(MV_PAR06)) 
        cQuery1 += " AND (B1_GRUPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"') "
    Endif
    

    If !empty(alltrim(mv_par07)) 
        /* apenas linha do produto */
        cQuery1 += " AND (SUBSTRING(B1_COD,4,2)) = '"+alltrim(mv_par07)+"' "
    Endif 
    

   // If (mv_par10 == 1)
        /* puxa todos os especificos dos bordero */
       //  cQuery += " AND (B2_LOCALIZ = '')  "
    //Endif

    If !empty(alltrim(mv_par11))
    /* filtra bordero de despacho */
		cQuery1 += " AND (BORDDESP.R_E_C_N_O_ IS NOT NULL) "
	ENDIF
    
    If !empty((mv_par12)) 
        /* filtra pedido de venda */
        cQuery1 += "    AND C6_NUM = '"+mv_par12+"' "    
    Endif   

    If (mv_par13 == 1)
        /* apenas itens estoque */
        cQuery1 += " AND (SB2.B2_COD IS NOT NULL)     "
        cQuery1 += " AND (ISNULL(SB2.B2_LOCALIZ,'') > '') "
    Endif 

    //If !empty(alltrim(mv_par14)) 

       //  cQuery1 += " AND C5_LIBCRE = 'T' "
   // Endif 

    If mv_par14 == 1 
    /* somento com liberaÁ„o de crÈdito */
     cQuery1 += "  AND ( "
     cQuery1 += " SELECT SUM(C6.C6_QTDVEN ) AS QTDLIB  "
     cQuery1 += " FROM "+RETSQLNAME("SC6")+" C6 WITH (NOLOCK) "
     cQuery1 += " LEFT OUTER JOIN "+RETSQLNAME("SC5")+" C5 WITH (NOLOCK) ON (C5.D_E_L_E_T_ = '') AND (C6_FILIAL = C5.C5_FILIAL) AND (C6.C6_NUM = C5.C5_NUM)  "
     cQuery1 += " LEFT OUTER JOIN "+RETSQLNAME("SB1")+" B1 WITH (NOLOCK) ON (B1.D_E_L_E_T_ = '') AND (C6_FILIAL = B1.B1_FILIAL) AND (C6.C6_PRODUTO = B1.B1_COD)  "

        IF (mv_par13 == 1) //.OR. (mv_par16 <> 1) 
            cQuery1 += " LEFT OUTER JOIN "+RETSQLNAME("SB2")+" B2 WITH (NOLOCK) ON (B2.D_E_L_E_T_ <> '*') AND (B1.B1_FILIAL = B2.B2_FILIAL) AND (B1.B1_COD = B2.B2_COD) "
            cQuery1 += " AND (B1.B1_LOCPAD = B2.B2_LOCAL)  "
        endif

    cQuery1 += " WHERE (C6.D_E_L_E_T_ <> '*') AND (C6.C6_FILIAL = '"+xFilial("SC6")+"') AND "
    cQuery1 += " (C6.C6_PRODUTO = SB1.B1_COD ) "
    cQuery1 += " AND (C5.C5_APROVA <> '2') AND (C6.C6_NOTA = '') AND (C5.C5_LIBPED = 'T') AND (C5.C5_LIBCRE = 'T') "

    If !empty((mv_par12)) 
        /* filtra pedido de venda */
        cQuery1 += "AND C6_NUM = '"+mv_par12+"' "    
    Endif   

    If !empty(alltrim(mv_par07)) 
        /* linha */
        cQuery1 += "AND (SUBSTRING(C6_PRODUTO,4,2) = '"+alltrim(mv_par07)+"') "
    ENDIF

    /*IF  (mv_par16 <> 1) */
        /* zerados */
        //cQuery3 += "AND (SB2.B2_QATU <> 0.0) "
    /* ENDIF */

   	///IF thisform.lEstoque.Value
    IF (mv_par13 == 1)   
		cQuery1 += "AND (ISNULL(SB2.B2_LOCALIZ,'') > '') "
	ENDIF


    cQuery1 += " GROUP BY C6.C6_PRODUTO ) > 0 "


    Endif

    If (mv_par15 == 1)
        /* apenas itens n„o estoque */
        cQuery1 += " AND (B2_LOCALIZ = '')     "
    Endif 

    /* If (mv_par16 == 1) */
        /* lista itens zerados */
        /* cQuery1 += "    AND (SB2.B2_QATU <> 0.0) " */
    /* Endif */

    If (mv_par17 == 1)
        /* filtra fabrica 1*/
        cQuery1 += " AND (B1_LOCPAD IN ('02','P1'))  "
    Endif   

    If (mv_par18 == 1)
        /* filtra fabrica 2*/
        cQuery1 += " AND (B1_LOCPAD IN ('20','P2'))   "
    Endif 
  
      /* ordena codigo do produto */
    cQuery1 += "    ORDER BY B1_COD "

    /* verifica quem È o usu·rio */
    cUsuario = PswChave(RetCodUsr())
    if (cUsuario == 'neliedercorneta') 
        /* gera log do script sql */
        GravaSQL(cQuery1)
    Endif
    
    /* verifica se arquivo est· aberto e finaliza */
    IF Select("QCON") <> 0
        DbSelectArea("QCON")
        DbCloseArea()
    ENDIF
    
    //TMPP QCON
    TCQUERY cQuery1 NEW ALIAS "QCON"  
    Count To nTotal 
    oReport:SetMsgPrint("Registros encontrados "+cValToChar(nTotal)) 
    
    dbSelectArea("QCON")
    QCON->(dbGoTop())
    
    oReport:SetMeter(QCON->(LastRec()))    
    /* percorre registros */
    conta := 0
    porc  := 0
    While !QCON->(eof())
        
        conta++
        porc = (conta/nTotal)*100
        porc = round(porc,2) 
        If oReport:Cancel()
            Exit
        EndIf
    
        /* inicializo a primeira seÁ„o */
        oSection1:Init()
        /* incrementa a regua do relatÛrio */
        oReport:IncMeter()

        oReport:SetMsgPrint("Registros encontrados " +cValToChar(conta)+ " de " +cValToChar(nTotal)+ " --> "+cValToChar(porc)+"%") 

        cCod = alltrim(QCON->B1_COD)
        
        xVarProd = SUBSTRING(cCod,1,10)

        //cCod = TRANSFORM(cCod, "@R XX 99.99.999-99") 
        //cCod = AllTrim(cCod)
        
        
        
        //Produto
        oSection1:Cell("B1_COD"):SetValue(AllTrim(cCod))
        
        //DescriÁ„o
        oSection1:Cell("B1_DESC"):SetValue(AllTrim(QCON->B1_DESC))                
		
        //LocalizaÁ„o
        oSection1:Cell("B2_LOCALIZ"):SetValue(AllTrim(QCON->B2_LOCALIZ))                
		
        //Saldo Atual
        oSection1:Cell("B2_SALDO"):SetValue(QCON->B2_SALDO)  
		
        // Lib Credito
        xVarLib = F_VR_LBC(alltrim(QCON->B1_COD))
        oSection1:Cell("VR_LBC"):SetValue(xVarLib)  
        
        // OPs Colocadas
        xOPsc = F_VR_OPC(QCON->B1_COD)
        oSection1:Cell("VR_OPC"):SetValue(xOPsc)  
        
        // Ped Nao Lib
        X_VR_PNL = F_VR_PNL(alltrim(QCON->B1_COD))
        C_VR_PNL  = X_VR_PNL - xVarLib
        oSection1:Cell("VR_PNL"):SetValue(C_VR_PNL)  
        
        // MÈd 3 m
        X_VR_M3M = F_VR_M3M(alltrim(QCON->B1_COD))
        oSection1:Cell("VR_M3M"):SetValue(X_VR_M3M)  
        
        // MÈd P 3M
        V_PEDLIB = F_PEDLIB(alltrim(QCON->B1_COD))
        cMedP = V_PEDLIB
        cMedP = (cMedP/3)
        oSection1:Cell("VR_MP3"):SetValue(cMedP)  

        //OPS 3m
        nMedPro = F_VR_OP3(alltrim(QCON->B1_COD))
        oSection1:Cell("VR_OP3"):SetValue(nMedPro)  

        //Clientes
        oSection1:Cell("VR_CLI"):SetValue(F_VR_CLI(alltrim(QCON->B1_COD)))  

       nQtdPrd = xOPsc 
       nQtdLib = C_VR_PNL
       QTDATU = QCON->B2_SALDO
       nMedPed = X_VR_M3M
       nQTDPED = xVarLib
        
        /*/ F_VR_SUP(nQtdPrd,nQtdLib,QTDATU,nMedPed,nMedPro,nQTDPED,cProd)
            @param nQtdPrd, numeric, ops colocadas -> xOPsc
            @param nQTDLIB, numeric, Lib CrÈdito ->xVarLib
            @param QTDATU, numeric, Saldo Atual ->QCON->B2_SALDO
            @param nMedPed, numeric, MÈd P 3 m -> cMedP 
            @param nMedPro, numeric, MÈd 3 m -> X_VR_M3M
            @param nQTDPED, numeric, Ped N„o Liberado -> C_VR_PNL
            @param cProd, numeric, Codigo do Produto QCON->B1_COD
        /*/
        oSection1:Cell("VR_SPU"):SetValue( F_VR_SUP(xOPsc,xVarLib,QCON->B2_SALDO,cMedP,X_VR_M3M,C_VR_PNL,QCON->B1_COD) )  


        // Ult Fat
        oSection1:Cell("VR_FAT"):SetValue(F_VR_FAT(alltrim(QCON->B1_COD)))  

        oSection1:Printline()
       
        QCON->(dbSkip())

        if SUBSTRING(alltrim(QCON->B1_COD),1,10) <> xVarProd
            //linha horizontal
            oReport:ThinLine()
        EndIf    
      
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
  Local cQuery3    := ""        
  
	cQuery3 := " SELECT C6_PRODUTO AS CODPRO,SUM(SC6.C6_QTDVEN ) AS QTDLIB "
	cQuery3 += "FROM "+RETSQLNAME("SC6")+" SC6 WITH (NOLOCK) "
	cQuery3 += "LEFT OUTER JOIN "+RETSQLNAME("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ = '') AND (C6_FILIAL = SC5.C5_FILIAL) AND (C6_NUM = SC5.C5_NUM) "
	cQuery3 += "LEFT OUTER JOIN "+RETSQLNAME("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ = '') AND (C6_FILIAL = B1_FILIAL) AND (C6_PRODUTO = B1_COD) "

    //IF thisform.lEstoque.Value OR !thisform.lZerados.Value 
	IF (mv_par13 == 1) /* .OR. (mv_par16 <> 1)  */
    cQuery3 += "LEFT OUTER JOIN "+RETSQLNAME("SB2")+" SB2 WITH (NOLOCK) ON (SB2.D_E_L_E_T_ <> '*') AND (B1_FILIAL = B2_FILIAL) AND (B1_COD = B2_COD) AND (B1_LOCPAD = B2_LOCAL) "
	endif

    cQuery3 += "WHERE (SC6.D_E_L_E_T_ <> '*') AND (SC6.C6_FILIAL = '"+xFilial("SC6")+"') AND "
	cQuery3 += "(SC6.C6_PRODUTO BETWEEN '"+cProduto+"' AND '"+cProduto+"') "
	cQuery3 += "AND (C5_APROVA <> '2') AND (SC6.C6_NOTA = '') AND (C5_LIBPED = 'T') AND (C5_LIBCRE = 'T') "

    If !empty((mv_par12)) 
        /* filtra pedido de venda */
        cQuery3 += "AND C6_NUM = '"+mv_par12+"' "    
    Endif   

    If !empty(alltrim(mv_par07)) 
        /* linha */
        cQuery3 += "AND (SUBSTRING(C6_PRODUTO,4,2) = '"+alltrim(mv_par07)+"') "
    ENDIF

    /* IF  (mv_par16 <> 1)*/
        /* zerados */
        //cQuery3 += "AND (SB2.B2_QATU <> 0.0) "
    /* ENDIF */

   	///IF thisform.lEstoque.Value
    IF (mv_par13 == 1)   
		cQuery3 += "AND (ISNULL(SB2.B2_LOCALIZ,'') > '') "
	ENDIF 
    

	cQuery3 += "GROUP BY C6_PRODUTO ORDER BY CODPRO "

    IF Select("QCON3") <> 0
        DbSelectArea("QCON3")
        DbCloseArea()
    ENDIF

    TCQUERY cQuery3 NEW ALIAS "QCON3"    
    
    dbSelectArea("QCON3")
	return_var = QCON3->QTDLIB

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
  
	cQuery2 := " SELECT SUM(ROUND((SC2.C2_QUANT-SC2.C2_QUJE),2)) AS QTDPRD "
    cQuery2 += " FROM "+RETSQLNAME("SC2")+" SC2 WITH (NOLOCK) "
    cQuery2 += " WHERE (SC2.D_E_L_E_T_ <> '*') AND (SC2.C2_FILIAL  = '"+xFilial("SC2")+"') AND "
    cQuery2 += " (SC2.C2_PRODUTO = '"+cProduto+"') AND (SC2.C2_DATRF = '') "
    cQuery2 += " AND (SC2.C2_QUANT > SC2.C2_QUJE) "

    IF Select("QCON2") <> 0
        DbSelectArea("QCON2")
        DbCloseArea()
    ENDIF

    TCQUERY cQuery2 NEW ALIAS "QCON2"    
    
    dbSelectArea("QCON2")
	return_var = ROUND(QCON2->QTDPRD,2)

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
    Local cQuery4    := ""  

    cQuery4 := " SELECT C6_PRODUTO AS CODPRO,SUM(SC6.C6_QTDVEN ) "
    cQuery4 += " AS QTDPED " 
    cQuery4 += " FROM SC6010 SC6 WITH (NOLOCK) " 
    cQuery4 += " LEFT OUTER JOIN SC5010 SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ = '') AND (C6_FILIAL = SC5.C5_FILIAL) AND (C6_NUM = SC5.C5_NUM) " 
    cQuery4 += " LEFT OUTER JOIN SB1010 SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ = '') AND (C6_FILIAL = B1_FILIAL) AND (C6_PRODUTO = B1_COD) " 
    
    IF (mv_par13 == 1) /*.OR. (mv_par16 <> 1) */
        cQuery4 += " LEFT OUTER JOIN SB2010 SB2 WITH (NOLOCK) ON (SB2.D_E_L_E_T_ <> '*') AND (B1_FILIAL = B2_FILIAL) AND (B1_COD = B2_COD) AND (B1_LOCPAD = B2_LOCAL) " 
    Endif
    
    cQuery4 += " WHERE (SC6.D_E_L_E_T_ <> '*') AND (SC6.C6_FILIAL = '"+xFilial("SC6")+"')AND (SC6.C6_PRODUTO BETWEEN '"+cProduto+"' AND '"+cProduto+"') " 
    cQuery4 += " AND (SC6.C6_NOTA = '') AND (C5_LIBPED = 'T') AND (C5_APROVA <> 2) " 
    
    If !empty((mv_par12)) 
        /* filtra pedido de venda */
        cQuery4 += "AND C6_NUM = '"+mv_par12+"' "    
    Endif   

    If !empty(alltrim(mv_par07)) 
        /* linha */
        cQuery4 += "AND (SUBSTRING(C6_PRODUTO,4,2) = '"+alltrim(mv_par07)+"') "
    ENDIF

    /*IF  (mv_par16 <> 1)*/
        /* zerados */
        //cQuery4 += "AND (SB2.B2_QATU <> 0.0) "
   /* ENDIF */

   	///IF thisform.lEstoque.Value
    IF (mv_par13 == 1)   
		cQuery4 += "AND (ISNULL(SB2.B2_LOCALIZ,'') > '') "
	ENDIF 
    
    
    
    cQuery4 += " GROUP BY C6_PRODUTO ORDER BY CODPRO " 
    
  
	IF Select("QCON4") <> 0
        DbSelectArea("QCON4")
        DbCloseArea()
    ENDIF

    TCQUERY cQuery4 NEW ALIAS "QCON4"    
    
    dbSelectArea("QCON4")
	
    return_var = QCON4->QTDPED

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

/*/{Protheus.doc} F_VR_SUP
MÈdia de Pedidos os ultimos 3 meses
@type function
@version 12.1.25 
@author neliedercorneta
@since 29/10/2021
@param nQtdPrd, numeric, ops colocadas
@param nQTDLIB, numeric, Lib CrÈdito
@param QTDATU, numeric, Saldo Atual
@param nMedPed, numeric, MÈd P 3 m
@param nMedPro, numeric, MÈd 3 m
@param nQTDPED, numeric, Ped N„o Liberado
@param cProd, numeric, Codigo do Produto
/*/
Static Function F_VR_SUP(nQtdPrd,nQtdLib,QTDATU,nMedPed,nMedPro,nQTDPED,cProd)

Local return_var  := ""        
Local nQTDSUG     := ""        
        

	nQTDSUG = nQTDLIB - QTDATU - nQtdPrd
		
		IF nQTDSUG <= 0
			nQTDSUG = 0
		ELSE 
			if nMedPed < 3
                nQTDSUG = nQTDSUG
            elseif (nMedPed >= 3) .and. (nMedPed < 6)
                nQTDSUG = nQTDSUG + nMedPro * 2
            elseif (nMedPed >= 6)
                nQTDSUG = nQTDSUG + nQTDPED + nMedPro * 3
            Endif            
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

    IF (mv_par13 == 1) /*.OR. (mv_par16 <> 1) */
        cQuery2 += " LEFT OUTER JOIN SB2010 SB2 WITH (NOLOCK) ON (SB2.D_E_L_E_T_ <> '*') AND (B1_FILIAL = B2_FILIAL) AND (B1_COD = B2_COD) AND (B1_LOCPAD = B2_LOCAL) " 
    Endif


    cQuery2 += " WHERE (SC2.D_E_L_E_T_ <> '*') AND (C2_FILIAL = '"+xFilial("SC2")+"')   "
    cQuery2 += " AND SC2.C2_PRODUTO = '"+cProduto+"'  "
    cQuery2 += " AND (C2_DATRF >= CONVERT(VARCHAR,GETDATE()-90,112))  "

    If !empty(alltrim(mv_par07)) 
        /* linha */
        cQuery2 += "AND (SUBSTRING(C2_PRODUTO,4,2) = '"+alltrim(mv_par07)+"') "
    ENDIF

    /* IF  (mv_par16 <> 1)*/
        /* zerados */
        //cQuery2 += "AND (SB2.B2_QATU <> 0.0) "
    /* ENDIF */
    
   	///IF thisform.lEstoque.Value
    IF (mv_par13 == 1)   
		cQuery2 += "AND (ISNULL(SB2.B2_LOCALIZ,'') > '') "
	ENDIF 

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
Local cQuery    := ""        
Local nMedPed    := 0

    cQuery := " SELECT C9_PRODUTO AS CODPRO,COUNT(C9_PRODUTO) AS QTDE  "
    cQuery += " FROM "+RetSqlName("SC9")+" SC9 WITH (NOLOCK) "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C9_FILIAL = C5_FILIAL) AND (C9_PEDIDO = C5_NUM) "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON (SC6.D_E_L_E_T_ <> '*') AND (C6_FILIAL = C9_FILIAL) AND (C9_PEDIDO = C6_NUM) AND (C6_ITEM = C9_ITEM)  "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (F4_CODIGO = C6_TES)  "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (C9_FILIAL = B1_FILIAL) AND (C9_PRODUTO = B1_COD) "
    /* AQUI TEM UM IF */

    IF (mv_par13 == 1) /* .OR. (mv_par16 <> 1)  */
        cQuery += "LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON (SB2.D_E_L_E_T_ <> '*') AND (B1_FILIAL = B2_FILIAL) AND (B1_COD = B2_COD) AND (B1_LOCPAD = B2_LOCAL) "
    ENDIF

    cQuery += " WHERE (SC9.D_E_L_E_T_ <> '*') AND (C9_FILIAL = '"+xFilial("SC9")+"') "
    //cQuery2 += " AND (SC9.C9_PRODUTO BETWEEN '"+mv_par01+"' AND '"+mv_par02+"') "
    cQuery += " AND (SC9.C9_PRODUTO = '"+cProduto+"' ) "
    cQuery += " AND (SC5.C5_TIPO = 'N') AND (SC5.C5_APROVA = '1') AND (F4_ESTOQUE <> 'N') AND (F4_DUPLIC <> 'N') "
    /* AQUI TEM UM IF */
    cQuery += " AND (C9_GRUPO BETWEEN '"+mv_par05+"' AND '"+mv_par06+"')   "
    cQuery += " AND C6_PRODUTO =  '"+cProduto+"'  "
    cQuery += " AND (C5_EMISSAO >= CONVERT(VARCHAR,GETDATE()-90,112))   "


    If !empty((mv_par12)) 
        /* filtra pedido de venda */
        cQuery += "AND C6_NUM = '"+mv_par12+"' "    
    Endif   

    If !empty(alltrim(mv_par07)) 
        /* linha */
        cQuery += "AND (SUBSTRING(C6_PRODUTO,4,2) = '"+alltrim(mv_par07)+"') "
    ENDIF

    /* IF  (mv_par16 <> 1)*/
        /* zerados */
        //cQuery += "AND (SB2.B2_QATU <> 0.0) "
    /* ENDIF */

   	///IF thisform.lEstoque.Value
    IF (mv_par13 == 1)   
		cQuery += "AND (ISNULL(SB2.B2_LOCALIZ,'') > '') "
	ENDIF 



    cQuery += " GROUP BY C9_PRODUTO ORDER BY CODPRO  "

    IF Select("QCON6") <> 0
        DbSelectArea("QCON6")
        DbCloseArea()
    ENDIF

    TCQUERY cQuery NEW ALIAS "QCON6"    
    
    dbSelectArea("QCON6")
    nMedPed = nMedPed + QCON6->QTDE
	//nMedPed = ROUND(nMedPed/3,1)
    return_var = nMedPed


Return return_var

Static Function GravaSQL(script)

Local cArq := ""


cArq := "C:\Temp\sql.txt" //a pasta deve ser v·lida.


MemoWrite ( cArq , script )


Return

