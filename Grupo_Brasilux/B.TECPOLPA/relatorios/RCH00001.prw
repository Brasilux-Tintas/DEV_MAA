#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH"

// Dyego Figueiredo/Chaus
// Relatorio de Pallets nao retornados
User Function RCH00001()


	Local oReport := nil
	Local cPerg:= Padr("RCH00001",10)
	Private cQLinha   := Chr(13) + Chr(10)
	Private nDiasAtr 	:= GETMV("MV_XATRPLT")
	Private cCodPallet 	:= GETMV("MV_XCODPLT")
	
	//Incluo/Altero as perguntas na tabela SX1
	//AjustaSX1(cPerg)  //LGS#20200214 - Adequação de release 12.1.25 e posteriores
	//gero a pergunta de modo oculto, ficando disponível no botão ações relacionadas
	Pergunte(cPerg,.F.)
		
	//oReport := RptDef(cPerg)
	//oReport:PrintDialog()
	
	oReport := RptDef(cPerg)
	oReport:PrintDialog()
Return




Static Function RptDef(cNome)

	Local oReport := Nil
	Local oSection1:= Nil
	//Local oBreak
	//Local oFunction
	
	
	oReport := TReport():New(cNome,"Pallets em poder de terceiros não retornados",cNome,{|oReport| ReportPrin(oReport)},"Descrição do meu relatório")
	
	//oreport:nfontbody:=10
	oreport:cfontbody:="Arial"


	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
	
	

	oSection1:= TRSection():New(oReport, "Produtos", {"SB1"}, NIL, .F., .T.)
	TRCell():New(oSection1,"A1_COD"		,"TRBNCM","CODIGO"  		,"@!",10)
	TRCell():New(oSection1,"A1_LOJA"	,"TRBNCM","LOJA"  		,"@!",5)
	TRCell():New(oSection1,"A1_NOME"  	,"TRBNCM","NOME"	,"@!",40)
	TRCell():New(oSection1,"B6_EMISSAO" ,"TRBNCM","EMISSAO"		,"@!",10)
	TRCell():New(oSection1,"B6_DOC"  	,"TRBNCM","DOCUMENTO"	,"@!",12)
	TRCell():New(oSection1,"B6_SERIE"	,"TRBNCM","SERIE"		,"@!",5)
	TRCell():New(oSection1,"B6_LOCAL"	,"TRBNCM","ARMAZEM"		,"@!",4)
	TRCell():New(oSection1,"B6_QUANT"	,"TRBNCM","QUANTIDADE"	,"@E 999,999,999",6)
	TRCell():New(oSection1,"QTDCLI"		,"TRBNCM","DIAS DECORRIDOS"	,"@E 999,999,999",10)
	TRCell():New(oSection1,"CATRASO"	,"TRBNCM","EM ATRASO"	,"@!",5)
	TRFunction():New(oSection1:Cell("B6_QUANT"),NIL,"SUM",,,,,.F.,.T.)



	
	oReport:SetTotalInLine(.T.)
       
        //Aqui, farei uma quebra  por seção
	//oSection1:SetPageBreak(.T.)
	
	
	oSection1:SetTotalText("Total de Pallets com .. ")
Return(oReport)



Static Function ReportPrin(oReport) 

	Local oSection1 := oReport:Section(1)
		 
	Local cQuery    := ""
	//Local cNcm      := ""
	//Local lPrim 	:= .T.
	
	
	cQuery := query()
		
		
		
	//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
	IF Select("TRBNCM") <> 0
		DbSelectArea("TRBNCM")
		DbCloseArea()
	ENDIF
	
	//crio o novo alias
	TCQUERY cQuery NEW ALIAS "TRBNCM"
	
	dbSelectArea("TRBNCM")
	TRBNCM->(dbGoTop())
	
	oReport:SetMeter(TRBNCM->(LastRec()))

	//inicializo a primeira seção
	oSection1:Init()
		
		
	//Irei percorrer todos os meus registros
	While !Eof()
		
		If oReport:Cancel()
			Exit
		EndIf
	
		

		oReport:IncMeter()
					
		cCliente:= TRBNCM->A1_COD
		cLoja 	:= TRBNCM->A1_LOJA
		
		IncProc("Imprimindo cliente "+alltrim(TRBNCM->A1_COD))
		
		//imprimo a primeira seção				
		oSection1:Cell("A1_COD"):SetValue(TRBNCM->A1_COD)
		oSection1:Cell("A1_LOJA"):SetValue(TRBNCM->A1_LOJA)
		oSection1:Cell("A1_NOME"):SetValue(TRBNCM->A1_NOME)
		
		oSection1:Cell("B6_EMISSAO"):SetValue( DTOC(STOD(TRBNCM->B6_EMISSAO)) )
		oSection1:Cell("B6_DOC"):SetValue(TRBNCM->B6_DOC)
		oSection1:Cell("B6_SERIE"):SetValue(TRBNCM->B6_SERIE)
		oSection1:Cell("B6_LOCAL"):SetValue(TRBNCM->B6_LOCAL)
		oSection1:Cell("B6_QUANT"):SetValue(TRBNCM->B6_QUANT)
				
				
		oSection1:Cell("QTDCLI"):SetValue(TRBNCM->QTDCLI)
		oSection1:Cell("CATRASO"):SetValue(TRBNCM->CATRASO)
			
		
		oSection1:Printline()
	
		TRBNCM->(dbSkip())
 				
 		
 		
 		//imprimo uma linha para separar uma NCM de outra
		oReport:ThinLine()
		//oReport:ThinLine()
 		
 		
	Enddo
	
	//finalizo a primeira seção
	oSection1:Finish()
		
Return

//LGS#20200214 - Adequação de release 12.1.25 e posteriores
/*
static function ajustaSx1(cPerg)
	//Aqui utilizo a função putSx1, ela cria a pergunta na tabela de perguntas
	putSx1(cPerg, "01", "Cliente de ?"	  , "", "", "mv_ch1", "C", tamSx3("A1_COD")[1], 0, 0, "G", "", "SA1", "", "", "mv_par01")
	putSx1(cPerg, "02", "Cliente ate?"	  , "", "", "mv_ch2", "C", tamSx3("A1_COD")[1], 0, 0, "G", "", "SA1", "", "", "mv_par02")
	
	
	putSx1(cPerg, "03", "Emissao de ?"	  , "", "", "mv_ch3", "D", 8, 0, 0, "G", "", "", "", "", "mv_par03")
	putSx1(cPerg, "04", "Emissao de ?"	  , "", "", "mv_ch4", "D", 8, 0, 0, "G", "", "", "", "", "mv_par04")
	
	putSx1(cPerg, "05", "Somente em Atraso (MV_XATRPLT) ?"	  , "", "", "mv_ch5", "C", 3, 0, 0, "C", "", "", "", "", "mv_par05", 'Sim','Sim','Sim','Sim','Nao','Nao','Nao')
	

return */

Static Function query()



	cQuery := "SELECT  A1_COD, 	"+cQLinha
	cQuery += "        A1_LOJA, 	"+cQLinha
	cQuery += "        A1_NOME,		"+cQLinha
	cQuery += "        B6_LOCAL, 	"+cQLinha
	cQuery += "        B6_DOC, 		"+cQLinha
	cQuery += "        B6_SERIE, 	"+cQLinha
	cQuery += "        B6_EMISSAO, 	"+cQLinha
	cQuery += "        B6_QUANT, 	"+cQLinha
	cQuery += "        B6_PRODUTO , "+cQLinha
	cQuery += "        B1_DESC,		"+cQLinha
	cQuery += "        DATEDIFF( day, B6_EMISSAO, GETDATE()) QTDCLI , 							"+cQLinha
	cQuery += "        CASE 																	"+cQLinha
	cQuery += "        	 WHEN         DATEDIFF( day, B6_EMISSAO, GETDATE()) > "+Str(nDiasAtr)+" THEN 'SIM' 	"+cQLinha
	cQuery += "          ELSE 'NAO'						 										"+cQLinha
	cQuery += "        END CATRASO   					 							 			"+cQLinha
	cQuery += "FROM    "+RetSqlName("SB6")+"  SB6 		 							 			"+cQLinha
	cQuery += "            INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = B6_PRODUTO AND  SB1.D_E_L_E_T_ = ' '	"+cQLinha
	cQuery += "            INNER JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND A1_COD = B6_CLIFOR AND A1_LOJA = B6_LOJA AND  SA1.D_E_L_E_T_ = ' '  	"+cQLinha
	cQuery += "WHERE   SB6.D_E_L_E_T_ = ' '				"+cQLinha
	cQuery += "AND B6_FILIAL  = '"+xFilial("SB6")+"'	"+cQLinha
	cQuery += "AND B6_PRODUTO  = '"+cCodPallet+"' 		"+cQLinha // -- CODIGO DO PALLET
	cQuery += "AND B6_TIPO     = 'E' 					"+cQLinha // -- EM TERCEIROS
	cQuery += "AND B6_PODER3   = 'R' 					"+cQLinha // -- R-REMASSA OU D-DEVOLUCAO
	cQuery += "AND B6_ATEND = ' ' 						"+cQLinha //  -- INDICA SE ATENDIDO??
	cQuery += "AND B6_QUANT > 0							"+cQLinha
	cQuery += "AND A1_COD BETWEEN '"+(MV_PAR01)+"' AND '"+(MV_PAR02)+"' "+cQLinha
	cQuery += "AND B6_EMISSAO BETWEEN '"+dtos(MV_PAR03)+"' AND '"+dtos(MV_PAR04)+"' "+cQLinha
	
	If MV_PAR05 == 1
		cQuery += "AND 	 DATEDIFF( day, B6_EMISSAO, GETDATE()) > "+Str(nDiasAtr)+" "+cQLinha
	Endif
	
	cQuery += "ORDER BY  A1_COD, A1_LOJA, B6_EMISSAO	"+cQLinha
		

Return cQuery