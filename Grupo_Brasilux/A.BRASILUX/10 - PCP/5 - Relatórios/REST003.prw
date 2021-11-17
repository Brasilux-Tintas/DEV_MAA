#include "rwmake.ch"
#include "protheus.ch"
#define DMPAPER_A4 9
User Function REST003()
	local oReport
	//local cPerg := PadR('REST003',10)
 
	oReport := reportDef()
	oReport:printDialog()
Return
 
static function reportDef()
	local oReport
	Local oSection1
	//Local oSection2
	local cTitulo := '[REST003] - Impressão de Produtos'
 
	oReport := TReport():New('REST003', cTitulo, , {|oReport| PrintRepor(oReport)},"Este relatorio ira imprimir as Fichas de Analises de Produtos.")
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()
 
	oSection1 := TRSection():New(oReport,"Filial",{"Z02"})
	oSection1:SetTotalInLine(.F.)
 
	TRCell():New(oSection1, "Z02_COD"	  , "Z02" , 'CODIGO'	 ,PesqPict('Z02',"Z02_COD")    , TamSX3("Z02_COD")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "Z02_PROD"	  , "Z02" , 'MATERIAL'	 ,PesqPict('Z02',"Z02_PROD")   , TamSX3("Z02_PROD")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "Z02_FORN"	  , "Z02" , 'FORNECEDOR' ,PesqPict('Z02',"Z02_FORN")   , TamSX3("Z02_FORN")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "Z02_TIPO"	  , "Z02" , 'TIPO'	     ,PesqPict('Z02',"Z02_TIPO")   , TamSX3("Z02_TIPO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "Z02_TESTES" , "Z02" , 'TESTES'	     ,PesqPict('Z02',"Z02_TESTES") , TamSX3("Z02_TESTES")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "Z02_RESULT" , "Z02" , 'RESULT'     ,PesqPict('Z02',"Z02_RESULT") , TamSX3("Z02_RESULT")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "Z02_LAUDO"	  , "Z02" , 'LAUDO'	     ,PesqPict('Z02',"Z02_LAUDO")	, TamSX3("Z02_LAUDO")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "Z02_CONTDS" , "Z02" , 'CONTDS'  	 ,PesqPict('Z02',"Z02_CONTDS")	, TamSX3("Z02_CONTDS")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "Z02_ALTERA" , "Z02" , 'ALTERA'	     ,PesqPict('Z02',"Z02_ALTERA")	, TamSX3("Z02_ALTERA")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "Z02_APROV"  , "Z02" , 'APROV'	     ,PesqPict('Z02',"Z02_APROV")  , TamSX3("Z02_APROV")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "Z02_GEREN"  , "Z02" , 'GEREN'	     ,PesqPict('Z02',"Z02_COD")    , TamSX3("Z02_GEREN")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():new(oSection1, "Z02_DATA"   , "Z02" , 'DATA'	     ,PesqPict('Z02',"Z02_DATA")   , TamSX3("Z02_DATA")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
 
	oBreak := TRBreak():New(oSection1,oSection1:Cell("Z02_COD"),,.F.)
 
	TRFunction():New(oSection1:Cell("Z02_COD"),"TOTAL FILIAL","COUNT",oBreak,,"@E 999999",,.F.,.F.)
 
	TRFunction():New(oSection1:Cell("Z02_COD"),"TOTAL GERAL" ,"COUNT",,,"@E 999999",,.F.,.T.)	
 
return (oReport)
 
Static Function PrintRepor(oReport)
	Local oSection1 := oReport:Section(1)
	oSection1:Init()
	oSection1:SetHeaderSection(.T.)
 
	DbSelectArea('Z02')
	dbGoTop()
	oReport:SetMeter(Z02->(RecCount()))
	While Z02->(!Eof())
		If oReport:Cancel()
			Exit
		EndIf
 
		oReport:IncMeter()
 
		oSection1:Cell("Z02_COD"):SetValue(Z02->Z02_COD)
		oSection1:Cell("Z02_COD"):SetAlign("LEFT")
 
		oSection1:Cell("Z02_PROD"):SetValue(Z02->Z02_PROD)
		oSection1:Cell("Z02_PROD"):SetAlign("LEFT")
 
		oSection1:Cell("Z02_FORN"):SetValue(Z02->Z02_FORN)
		oSection1:Cell("Z02_FORN"):SetAlign("RIGHT")
 
		oSection1:Cell("Z02_TIPO"):SetValue(Z02->Z02_TIPO)
		oSection1:Cell("Z02_TIPO"):SetAlign("LEFT")
 
		oSection1:Cell("Z02_TESTES"):SetValue(Z02->Z02_TESTES)
		oSection1:Cell("Z02_TESTES"):SetAlign("LEFT")
 
		oSection1:Cell("Z02_RESULT"):SetValue(Z02->Z02_RESULT)
		oSection1:Cell("Z02_RESULT"):SetAlign("LEFT")
 
		oSection1:Cell("Z02_LAUDO"):SetValue(Posicione("Z02",1,xFilial("Z02")+Z02->Z02_LAUDO,"Z02_LAUDO"))
		oSection1:Cell("Z02_LAUDO"):SetAlign("LEFT")
 
		oSection1:Cell("Z02_CONTDS"):SetValue(Z02->Z02_CONTDS)
		oSection1:Cell("Z02_CONTDS"):SetAlign("LEFT")
 
		oSection1:Cell("Z02_ALTERA"):SetValue(Posicione("Z02", 1, xFilial("Z02")+Z02->Z02_ALTERA,"Z02_ALTERA"))
		oSection1:Cell("Z02_ALTERA"):SetAlign("LEFT")
 
		oSection1:Cell("Z02_APROV"):SetValue(Posicione("Z02", 2, xFilial("Z02")+Z02->Z02_APROV,"Z02_APROV"))
		oSection1:Cell("Z02_APROV"):SetAlign("LEFT")
		
		oSection1:Cell("Z02_GEREN"):SetValue(Posicione("Z02",2 ,xFilial("Z02")+Z02->Z02_GEREN,"Z02_GEREN"))
		oSection1:Cell("Z02_GEREN"):SetAlign("LEFT")
       
 		oSection1:Cell("Z02_DATA"):SetValue(Posicione("Z02" ,2,xFilial("Z02")+DTOC(Z02->Z02_DATA),"Z02_DATA"))
 		oSection1:Cell("Z02_DATA"):SetAlign("LEFT")
 
		oSection1:PrintLine()
 
		dbSelectArea("Z02")
		Z02->(dbSkip())
	EndDo
	oSection1:Finish()
Return