#Include 'Protheus.ch'
#include 'rwmake.ch'
#INCLUDE 'TOPCONN.CH'


User Function TECPCP01()
 	Local   oReport := nil      /* //// */     
	Local   cPerg   := Padr("TECPCP01",08)     /* ///// */  
	
/*       Incluo/Altero as perguntas na tabela SX1 */

/*	AjustaSX1(cPerg)	     ////// */

/*       gero a pergunta de modo oculto, ficando disponível no botão ações relacionadas    */

/*	Pergunte(cPerg,.F.)	     //////      */     
		
    oReport := RptDef(cPerg)     /* /////// */   
    oReport:PrintDialog()        /* /////// */   

 
Return

Static Function RptDef(cNome)
	Local oReport  := Nil
	Local oSection1:= Nil    /* ///// */
	Local oSection2:= Nil
/*	Local oFunction          ////// */
	
/*       Sintaxe: TReport():New(cNome,cTitulo,cPerguntas,bBlocoCodigo,cDescricao)*/
	oReport := TReport():New(cNome,"Relatório Produtos com Empenho no SB2(Tabela de Saldos Fisicos) Sem OP Empenhada",cNome,{|oReport| ReportPrint(oReport)},"Descrição do meu relatório")
	oReport:SetPortrait()    
	oReport:SetTotalInLine(.F.)
	
/*    Monstando a primeira seção
	  Neste exemplo, a primeira seção será composta por duas colunas, código do PRODUTO e sua descrição
	  Iremos disponibilizar para esta seção apenas a tabela SD2, pois quando você for em personalizar
	  e entrar na primeira seção, você terá todos os outros campos disponíveis, com isso, será
	  permitido a inserção dos outros campos
	  Neste exemplo, também, já deixarei definido o nome dos campos, mascara e tamanho, mas você
	  terá toda a liberdade de modificá-los via relatorio. */

	oSection1:= TRSection():New(oReport, "SAL", {"SD4"}, , .F., .T.)              /*  ,"SB2","SB8","SBF",'SB1"   ///////  */
/*	TRCell():New(oSection1,"D4_FILIAL"  ,"TRBSAL","FILIAL"  	       ,"@!",08)                     ///////  */

	oSection2:= TRSection():New(oReport, "DETALHE", {"SB1"}, NIL, .F., .T.)
	TRCell():New(oSection2,"D4_COD"	    ,"TRBSAL","CODIGO"  	         ,"@!",15)
  	TRCell():New(oSection2,"B1_DESC"    ,"TRBSAL","DESCRIÇÃO"            ,"@!",50)
	TRCell():New(oSection2,"D4_LOCAL"   ,"TRBSAL","LOCAL"                ,"@!",16)
	TRCell():New(oSection2,"REQEMPENHA" ,"TRBSAL",".        REQ.EMPENHADAS" ,"@E 99999,999,999,999.9999",23)
	TRCell():New(oSection2,"SALDOEMPEN" ,"TRBSAL",".       SALDO EMPENHADO" ,"@E 99999,999,999,999.9999",23)
	TRCell():New(oSection2,"SALPORLOTE" ,"TRBSAL",".        SALDO POR LOTE" ,"@E 99999,999,999,999.9999",23)
	TRCell():New(oSection2,"SALPORENDE" ,"TRBSAL",".    SALDO POR ENDEREÇO" ,"@E 99999,999,999,999.9999",23)

	oReport:SetTotalInLine(.F.)
       
/*      Aqui, farei uma quebra  por seção   */
    	oSection1:SetPageBreak(.T.)       /* /////  */
    	oSection1:SetTotalText(" ")	     /* //////  */ 			
Return(oReport)

Static Function ReportPrint(oReport)
	Local oSection1 := oReport:Section(1)  /* ////// */
	Local oSection2 := oReport:Section(2)	 

	Local cQuery    := ""		
/*	Local cCod      := ""        //////    */
	Local ccFilial   := ""      /* ////// */

/*      Monto minha consulta conforme parametros passado   */
/*      JOSE COMECEI AQUI ---------------------------------------------   */

cQuery :=""
cQuery += "SELECT SD4.D4_FILIAL, SD4.D4_COD, SB1.B1_DESC, SD4.D4_LOCAL, SUM(SD4.D4_QUANT) AS REQEMPENHA, SB2.B2_QEMP AS SALDOEMPEN, " 
cQuery += "                                 SUM(SB8.B8_EMPENHO) AS SALPORLOTE, SUM(SBF.BF_EMPENHO) AS SALPORENDE "
cQuery += "FROM SD4110 SD4 "
cQuery += "LEFT JOIN SB2110 SB2 ON SB2.B2_FILIAL = SD4.D4_FILIAL AND SB2.D_E_L_E_T_ = ' ' AND SB2.B2_COD     = SD4.D4_COD AND " 
cQuery += "                       SB2.B2_LOCAL  = SD4.D4_LOCAL "
cQuery += "LEFT JOIN SB8110 SB8 ON SB8.B8_FILIAL = SD4.D4_FILIAL AND SB8.D_E_L_E_T_ = ' ' AND SB8.B8_PRODUTO = SD4.D4_COD AND "
cQuery += "                       SB8.B8_LOCAL  = SD4.D4_LOCAL "
cQuery += "LEFT JOIN SBF110 SBF ON SBF.BF_FILIAL = SD4.D4_FILIAL AND SBF.D_E_L_E_T_ = ' ' AND SBF.BF_PRODUTO = SD4.D4_COD AND " 
cQuery += "                        SBF.BF_LOCAL  = SD4.D4_LOCAL "
cQuery += "LEFT JOIN SB1110 SB1 ON SB1.D_E_L_E_T_ = ' '          AND SB1.B1_COD     = SD4.D4_COD "
cQuery += "WHERE SD4.D4_FILIAL = '11' "
cQuery += "  AND SD4.D_E_L_E_T_ = ' ' "
cQuery += "  AND SB2.B2_QEMP <> 0 "
cQuery += "  AND SD4.D4_QUANT = 0 "
cQuery += "  AND (SB8.B8_EMPENHO = 0 OR SB8.B8_EMPENHO IS NULL) "
cQuery += "  AND (SBF.BF_EMPENHO = 0 OR SBF.BF_EMPENHO <> 0 OR SBF.BF_EMPENHO IS NULL) "
cQuery += "GROUP BY SD4.D4_FILIAL, SD4.D4_COD, SB1.B1_DESC, SD4.D4_LOCAL, SB2.B2_QEMP "
cQuery += "ORDER BY SD4.D4_COD "

/*       Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros    */

	IF Select("TRBSAL") <> 0
		DbSelectArea("TRBSAL")
		DbCloseArea()
	ENDIF
	
/*      Crio o novo alias   */

	TCQUERY cQuery NEW ALIAS "TRBSAL"	
	
	dbSelectArea("TRBSAL")
	TRBSAL->(dbGoTop())
	
	oReport:SetMeter(TRBSAL->(LastRec()))	

/*  	   Irei percorrer todos os meus registros   */

	While !Eof()
		// produto de custeio
   		If U_IsProdCusto(TRBSAL->D4_COD)
      		TRBSAL->(dbSkip())
      		Loop
   		Endif   
		
		If oReport:Cancel()
			Exit
		EndIf
	
/*        Inicializo a primeira seção   */

    		oSection1:Init()        /* ////// */
    		oReport:IncMeter()      /* ///// */

/*       Imprimo a primeira seção filial	 */
				
		ccFilial 	:= TRBSAL->D4_FILIAL
		IncProc("Imprimindo FILIAL "+alltrim(TRBSAL->D4_FILIAL))
    	oSection1:Printline()       /* ///////  */

/*        Inicializo a segunda seção    */

		oSection2:init()
		
/*         Verifico se o codigo do FILIAL é mesmo, se sim, imprimo o produto   */

     	While (TRBSAL->D4_Filial = ccFilial)
/*	    oReport:IncMeter()		      /////// */
 
			IncProc("Imprimindo Produto "+alltrim(TRBSAL->D4_COD))

			oSection2:Printline()
	
 			TRBSAL->(dbSkip())
 		EndDo		

/*         Finalizo a segunda seção para que seja reiniciada para o proximo registro   */

     	oSection2:Finish()

/*         Imprimo uma linha para separar um VEN de outro    */

     	oReport:ThinLine()

/*      Finalizo a primeira seção                  */

    	oSection1:Finish()         /* ///// */
	Enddo
Return

