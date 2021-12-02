#include "BRFINR68.CH"
#Include "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ BRFINR68 ³ Autor ³ Paulo Boschetti       ³ Data ³ 25.10.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Extrato Bancaria - Via CNAB                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ BRFINR68(void)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Sigafin.Adv                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRFINR68()

//Local oReport
Local aAreaR4	:= GetArea()
     u_zcfga01( 'BRFINR68' ) //LGS#2021202 - Gravação de log de utilização da rotina
//AjustaSX1() //LGS#20200130 - Adequação para release 12.1.25 e posteriores

/*
If FindFunction("TRepInUse") .And. TRepInUse()
	oReport := ReportDef()
	oReport:PrintDialog()
Else 
*/
	Return FINR68R3() // Executa versão anterior do fonte
//Endif

RestArea(aAreaR4)  

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ReportDef º Autor ³ Marcio Menon		   º Data ³  14/08/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Definicao do objeto do relatorio personalizavel e das      º±±
±±º          ³ secoes que serao utilizadas.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPC1 - Grupo de perguntas do relatorio                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 												                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()

Local oReport
Local oSection1
Local cReport 	:= "BRFINR68" 				// Nome do relatorio
Local cDescri 	:= STR0001 +;				//"Este relat¢rio ir  emitir o extrato bancario via padr„o CNAB."
						STR0002 +;				//"Para que o mesmo seja emitido, dever  ser efetuado a configu-"
						STR0003    				//"ra‡„o conforme documenta‡„o do banco."
Local cTitulo 	:= OemToAnsi(STR0004)  //"Extrato Bancario - Via CNAB"
Local cPerg		:= "FIN680"					// Nome do grupo de perguntas


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte("FIN680",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros 	 ³
//³ mv_par01       // Do Banco         	     ³
//³ mv_par02       // Da Agencia       	     ³
//³ mv_par03       // Da Conta       	     ³
//³ mv_par04       // Da SubConta    	     ³
//³ mv_par05       // Arquivo Config   	     ³
//³ mv_par06       // Arquivo Extrato  	     ³
//³ mv_par07       // Padrao Banco/Febraban  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := TReport():New(cReport, cTitulo, cPerg, {|oReport| ReportPrint(oReport)}, cDescri) 

oReport:SetPortrait()	//Imprime o relatorio no formato retrato

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³                      Definicao das Secoes                              ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Secao 01                                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1 := TRSection():New(oReport,STR0004)		//"Extrato Bancario - Via CNAB"

TRCell():New(oSection1, "DATA"   , "" , STR0011 ,/*Picture*/, 08 ,/*lPixel*/,/*CodeBlock*/)	//"DATA"
TRCell():New(oSection1, "DOCUM"  , "" , STR0012 ,/*Picture*/, 06 ,/*lPixel*/,/*CodeBlock*/)	//"DOCUM"
TRCell():New(oSection1, "AGENCIA", "" , STR0013 ,/*Picture*/, 05 ,/*lPixel*/,/*CodeBlock*/)	//"AGEN."
TRCell():New(oSection1, "CONTA"  , "" , STR0014 ,/*Picture*/, 10 ,/*lPixel*/,/*CodeBlock*/)	//"CTA."
TRCell():New(oSection1, "HIST"   , "" , STR0015 ,/*Picture*/, 30 ,/*lPixel*/,/*CodeBlock*/)	//"HISTORICO"
TRCell():New(oSection1, "CREDITO", "" , STR0016 , TM(0,17)  , 18 ,/*lPixel*/,/*CodeBlock*/)	//"CREDITO"
TRCell():New(oSection1, "DEBITO" , "" , STR0017 , TM(0,17)  , 18 ,/*lPixel*/,/*CodeBlock*/)	//"DEBITO"
TRCell():New(oSection1, "SALDO"  , "" , STR0018 , TM(0,17)  , 18 ,/*lPixel*/,/*CodeBlock*/)	//"SALDO"

oSection1:Cell("CREDITO"):SetHeaderAlign("RIGHT")
oSection1:Cell("DEBITO" ):SetHeaderAlign("RIGHT")
oSection1:Cell("SALDO"  ):SetHeaderAlign("RIGHT")


Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportPrint ºAutor³ Marcio Menon       º Data ³  14/08/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Imprime o objeto oReport definido na funcao ReportDef.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPO1 - Objeto TReport do relatorio                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint(oReport)

Local oSection1 		:= oReport:Section(1) 
//Local CbTxt 			:= space(10)
//Local CbCont 			:= 0
//Local tamanho 			:= "M"
Local nHdlConf       := 0
Local nHdlBco        := 0
Local cData, dData , nValor , nTotCred , nTotDeb
Local nLidos 			:= 0
Local aPosicoes		:={}
Local nSaldoInicial 	:= 0
Local lFebraban 		:= .F.
Local cSitLanc 		:= ""
Local cCtaArq 			:= ""
Local cAgeArq 			:= "" 
Local cNum				:= ""
Local cDesc				:= ""
Local lSaldo			:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no cadastro de bancos.                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbselectarea("SA6")
dbsetorder(1)
If !(SA6->(dbSeek(xFilial("SA6") + mv_par01 + mv_par02 + mv_par03)))
	Help(" ",1, "AFR680BCO")
	Return
Endif
dbSelectArea("SEE")     
dbsetorder(1)
SEE->(dbSeek(xFilial("SEE") + mv_par01 + mv_par02 + mv_par03 + mv_par04 ))
If !SEE->(Found())
	Help(" ",1,"PAR150")
	Return .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso esteja usando configuracao 240 bytes/linha p/bancos	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par07 == 1
	lFebraban := IIF(EE_BYTESXT > 200 , .T., .F.)
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abertura do arquivo Configurador.                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nHdlConf := Fopen(mv_par05, 64)
If nHdlConf < 0
	Help(" ",1, "AFR680CFG" )
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abertura do arquivo Configurador.                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nHdlBco := Fopen(mv_par06, 64)
If nHdlBco < 0
	Help(" ",1, "AFR680BCO" )
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Lˆ arquivo de configura‡„o ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLidos  := 0
Fseek(nHdlConf, 0, 0)
nTamArq := FSEEK(nHdlConf, 0, 2)
Fseek(nHdlConf, 0, 0)

While nTamArq >= 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o tipo de qual registro foi lido ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	xBuffer := Space(85)
	FREAD(nHdlConf,@xBuffer,85)
	If mv_par07 == 1   // Padrao bancos
		IF SubStr(xBuffer, 1, 1) == CHR(1)
			nTamArq -= 85
			Loop
		EndIF
	Endif
	Aadd(aPosicoes,{Substr(xBuffer, 2, 15), Val(Substr(xBuffer, 17, 3)),;
						1 + Int(Val(Substr(xBuffer, 20, 3))) - Int(Val(Substr(xBuffer, 17, 3)))})
	nTamArq -= 85
Enddo

nTamArq := Fseek(nHdlBco, 0, 2)
Fseek(nHdlBco, 0, 0)
nBytes  := 0
nTamLin := IIF(SEE->EE_BYTESXT > 0, SEE->EE_BYTESXT + 2, 202)
xBuffer := Space(nTamLin)				// Registro Header 
Fread(nHdlBco, @xBuffer, nTamLin)

oReport:SetMeter(nTamArq / Len(xBuffer))

oSection1:Cell("AGENCIA"):SetBlock ( { || cAgeArq } )
oSection1:Cell("CONTA"  ):SetBlock ( { || cCtaArq } )
oSection1:Cell("DATA"	):Hide()
oSection1:Cell("DATA"   ):SetBlock ( { || dData } )
oSection1:Cell("DOCUM"  ):SetBlock ( { || cNum } )
oSection1:Cell("HIST"	):SetBlock ( { || IIF(!lSaldo,(lSaldo:=.T.,STR0008 + Dtoc(dData)), Substr(cDesc,1,30)) } )		//"SALDO INICIAL EM "

oSection1:Init()

While .T. 

	xBuffer := Space(nTamLin)			// Lancamentos
	Fread(nHdlBco, @xBuffer, nTamLin)

	If	Empty(xBuffer)
		Exit
	Endif

	If (lFebraban .And.(SubStr(xBuffer, 8, 1) == "1")) .Or. (!lFebraban .And. SubStr(xBuffer, 1, 1) == "1" .And. SubStr(xBuffer, aPosicoes[4,2], aPosicoes[4,3]) == "0")
                
		cAgeArq := SubStr(xBuffer, aPosicoes[2,2], aPosicoes[2,3])
		cCtaArq := SubStr(xBuffer, aPosicoes[3,2], aPosicoes[3,3])
		
		If mv_par07 == 1  //Bancos
			cData := SubStr(xBuffer, aPosicoes[6,2], aPosicoes[6,3])
		ElseIf mv_par07 == 2 // Febraban
			cData := SubStr(xBuffer, aPosicoes[4,2], aPosicoes[4,3])
		Endif

		cData := ChangDate(cData, SEE->EE_TIPODAT)
		dData := CtoD(Substr( cData, 1, 2) + "/" +;
						  SubStr( cData, 3, 2) + "/" +;
						  SubStr( cData, 5, 2), "ddmmyy")

		cSitLanc := IIF (mv_par07 == 1 ,;
								SubStr(xBuffer, aPosicoes[7,2], aPosicoes[7,3]),;
								SubStr(xBuffer, aPosicoes[5,2], aPosicoes[5,3]))
	
		nSaldoInicial := IIF (mv_par07 == 1 ,;
										Val(SubStr(xBuffer, aPosicoes[5,2], aPosicoes[5,3])) / 100,;
										Val(SubStr(xBuffer, aPosicoes[3,2], aPosicoes[3,3])) / 100)
		
		oSection1:Cell("CREDITO"):SetBlock ( { || If (cSitLanc == "C", nSaldoInicial, ) } )
		oSection1:Cell("DEBITO" ):SetBlock ( { || If (cSitLanc == "C",, nSaldoInicial ) } )
 	
		nSaldoInicial *= Iif(cSitLanc == "C", 1, -1) // Inverte o sinal, caso o saldo inicial seja negativo.	  			

	  	oReport:IncMeter()   
		oSection1:PrintLine()

		oReport:PrintText("")
		oSection1:Cell("DATA"	):Show()
		oSection1:Cell("AGENCIA"):Hide()
		oSection1:Cell("CONTA"  ):Hide()

	ElseIf (lFebraban .And.(SubStr(xBuffer, 8, 1) == "3")) .Or. (!lFebraban .And. SubStr(xBuffer, 1, 1) == "1" .And. SubStr(xBuffer, aPosicoes[4,2], aPosicoes[4,3]) == "1")

		cCodMov := Substr(xBuffer, aPosicoes[11,2], aPosicoes[11,3])

		dbSelectArea("SEJ") 
		If dbSeek(xFilial("SEJ") + mv_par01 + cCodMov)
			cSitLanc := SEJ->EJ_DEBCRE 
		Else                      
			Help(" ",1,"FA470OCOR",, "Código da ocorrência: " + cCodMov + " Codigo do banco: " + mv_par01, 4, 0)
			lSaida := .T.
			Exit
		Endif
	
		cData  := SubStr(xBuffer, aPosicoes[9,2], aPosicoes[9,3])
		cData  := ChangDate(cData, SEE->EE_TIPODAT)
		dData  := CtoD(SubStr( cData, 1, 2) + "/" +;
					 	   SubStr( cData, 3, 2) + "/" +;
					      SubStr( cData, 5, 2), "ddmmyy")
		cNum   := SubStr(xBuffer, aPosicoes[8,2], aPosicoes[8,3])
		cDesc  := SubStr(xBuffer, aPosicoes[12,2], aPosicoes[12,3])
		nValor := Val(SubStr(xBuffer, aPosicoes[10,2], aPosicoes[10,3])) / 100

		If cSitLanc == "C" 
			nSaldoInicial += nValor
		Else
			nSaldoInicial -= nValor
		Endif

		oSection1:Cell("CREDITO"):SetBlock ( { || If (cSitLanc == "C", nValor, ) } )
		oSection1:Cell("DEBITO" ):SetBlock ( { || If (cSitLanc == "C",, nValor ) } )    
      oSection1:Cell("SALDO" ):SetBlock ( { || nSaldoInicial } )				   	

	  	oReport:IncMeter()   
		oSection1:PrintLine()	  	

	ElseIf (lFebraban .And.(SubStr(xBuffer, 8, 1) == "5")) .Or. (SubStr(xBuffer, aPosicoes[4,2], aPosicoes[4,3]) == "2" .And. !lFebraban)	

		cSitLanc := SubStr(xBuffer, aPosicoes[16,2], aPosicoes[16,3])
		nValor 	:= Val(SubStr(xBuffer, aPosicoes[15,2], aPosicoes[15,3])) / 100
		cData 	:= SubStr(xBuffer, aPosicoes[14,2], aPosicoes[14,3])
		cData		:= ChangDate(cData, SEE->EE_TIPODAT)
		dData 	:= CtoD(Substr( cData, 1, 2)+ "/" +;
							  SubStr( cData, 3, 2)+ "/" +;
							  SubStr( cData, 5, 2), "ddmmyy")

		oReport:PrintText("")
		oSection1:Cell("DATA"   ):Hide()
		oSection1:Cell("DOCUM"  ):Hide()
		oSection1:Cell("HIST"   ):SetBlock ( { || STR0019 + Dtoc(dData) } )		//"SALDO FINAL EM "
		oSection1:Cell("CREDITO"):SetBlock ( { || If( cSitLanc == "C", nValor, ) } )
		oSection1:Cell("DEBITO" ):SetBlock ( { || If( cSitLanc == "C", , nValor ) } )
		oSection1:Cell("SALDO"  ):Hide()

	  	oReport:IncMeter()   
		oSection1:PrintLine()

		If lFebraban
			nTotCred := Val(SubStr(xBuffer, aPosicoes[19,2], aPosicoes[19,3])) / 100
			nTotDeb  := Val(SubStr(xBuffer, aPosicoes[18,2], aPosicoes[18,3])) / 100

			oSection1:Cell("HIST"   ):SetBlock ( { || OemToAnsi(STR0009) } )		//"TOTAL CREDITOS"
			oSection1:Cell("CREDITO"):SetBlock ( { || nTotCred } )   	

		  	oReport:IncMeter()
			oSection1:PrintLine()		  	   

			oSection1:Cell("HIST"   ):SetBlock ( { || OemToAnsi(STR0010) } )		//"TOTAL DEBITOS "
			oSection1:Cell("CREDITO"):SetBlock ( { || nTotDeb } )			

			oSection1:PrintLine()
		Endif
	
	ElseIf (SubStr(xBuffer, 1, 1) == "9" .And. !lFebraban)	
	
		nTotCred := Val(SubStr(xBuffer, aPosicoes[19,2], aPosicoes[19,3])) / 100
		nTotDeb  := Val(SubStr(xBuffer, aPosicoes[18,2], aPosicoes[18,3])) / 100

		oSection1:Cell("HIST"   ):SetBlock ( { || OemToAnsi(STR0009) } )		//"TOTAL CREDITOS"
		oSection1:Cell("CREDITO"):SetBlock ( { || nTotCred } )   	

	  	oReport:IncMeter()   
		oSection1:PrintLine()

		oSection1:Cell("HIST"   ):SetBlock ( { || OemToAnsi(STR0010) } )		//"TOTAL DEBITOS "
		oSection1:Cell("CREDITO"):SetBlock ( { || nTotDeb } )			

		oSection1:PrintLine()
	Endif
Enddo

oSection1:Finish()

Fclose(nHdlBco)  // Fecha sequencial enviado pelo banco
Fclose(nHdlConf) // Fecha sequencial do configurador

Return

/*
---------------------------------------------- Release 3 ---------------------------------------------------------
*/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ BRFINR68 ³ Autor ³ Paulo Boschetti       ³ Data ³ 25.10.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Extrato Bancaria - Via CNAB                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ BRFINR68(void)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Sigafin.Adv                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FINR68R3()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cDesc1 := STR0001  //"Este relat¢rio ir  emitir o extrato bancario via padr„o CNAB."
LOCAL cDesc2 := STR0002  //"Para que o mesmo seja emitido, dever  ser efetuado a configu-"
LOCAL cDesc3 := STR0003  //"ra‡„o conforme documenta‡„o do banco."
LOCAL cString:=" "
LOCAL Tamanho:="M"

PRIVATE titulo := OemToAnsi(STR0004)  //"Extrato Bancario - Via CNAB"
PRIVATE cabec1 := OemToAnsi(STR0005)  //"DATA      DOCUM     HISTORICO                             CREDITO              DEBITO               SALDO"
PRIVATE cabec2 := "" , wnrel
PRIVATE aReturn := { OemToAnsi(STR0006), 1,OemToAnsi(STR0007), 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
PRIVATE nomeprog := "BRFINR68"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   := "FIN680"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte("FIN680",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros 	 ³
//³ mv_par01       // Do Banco         	     ³
//³ mv_par02       // Da Agencia       	     ³
//³ mv_par03       // Da Conta       	     ³
//³ mv_par04       // Da SubConta    	     ³
//³ mv_par05      // Arquivo Config   	     ³
//³ mv_par06       // Arquivo Extrato  	     ³
//³ mv_par07       // Padrao Banco/Febraban  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:="BRFINR68"            //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

RptStatus({|lEnd| FIN68Imp(@lEnd,wnRel,cString)},Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³ FA680Imp ³ Autor ³ Lu¡s C. Cunha         ³ Data ³ 05/11/93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Retorno do Extrato Banc rio                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FIN68Imp(lEnd,wnRel,cString)

LOCAL CbTxt := space(10)
LOCAL CbCont := 0
LOCAL tamanho := "M"
LOCAL nHdlConf
LOCAL nHdlBco
LOCAL cData, dData , nValor , nTotCred , nTotDeb
LOCAL nLidos := 0
LOCAL aPosicoes:={ }
LOCAL nSaldoInicial := 0
Local lFebraban := .F.
Local cSitLanc := ""
Local cCtaArq := ""
Local cAgeArq := ""
Local _nComp  := GetMv("MV_COMP")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no cadastro de bancos.                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! (SA6->(dbSeek( xFilial("SA6")+mv_par01+mv_par02+mv_par03 ) ) )
	Set Device To Screen
	Help(" ",1, "AFR680BCO" )
	Return
Endif
dbSelectArea("SEE")
SEE->(dbSeek(xFilial("SEE")+mv_par01+mv_par02+mv_par03+mv_par04))
If !SEE->( found() )
	Set Device To Screen
	Help(" ",1,"PAR150")
	Return .F.
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso esteja usando configuracao 240 bytes/linha p/bancos	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par07 == 1
	lFebraban := IIF(EE_BYTESXT > 200 , .t., .f.)
Endif	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abertura do arquivo Configurador.                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nHdlConf := Fopen(mv_par05 ,64)
If nHdlConf < 0
	Set Device To Screen
	Help(" ",1, "AFR680CFG" )
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abertura do arquivo Configurador.                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nHdlBco := Fopen( mv_par06 ,64)
If nHdlBco < 0
	Set Device To Screen
	Help(" ",1, "AFR680BCO" )
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Lˆ arquivo de configura‡„o ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLidos:=0
Fseek(nHdlConf,0,0)
nTamArq:=FSEEK(nHdlConf,0,2)
Fseek(nHdlConf,0,0)

While nTamArq >= 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o tipo de qual registro foi lido ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	xBuffer:=Space(85)
	FREAD(nHdlConf,@xBuffer,85)
	If mv_par07 == 1   // Padrao bancos
		IF SubStr(xBuffer,1,1) == CHR(1)
			nTamArq-=85
			Loop
		EndIF
	Endif
	Aadd( aPosicoes, { Substr(xBuffer,2,15),Val(Substr(xBuffer,17,3)),;
							1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3))) })
	nTamArq -=85
Enddo

nTamArq := Fseek( nHdlBco,0, 2 )
Fseek( nHdlBco, 0, 0 )
nBytes := 0
li := 80  // Inicia com quebra de cabecalho
nTamLin := IIF(SEE->EE_BYTESXT > 0, SEE->EE_BYTESXT + 2, 202 )
xBuffer := Space(nTamLin)				// Registro Header 
Fread( nHdlBco, @xBuffer, nTamLin )

SetRegua(nTamArq/Len(xBuffer))

cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP") )

While .T. 

	xBuffer := Space( nTamLin )			// Lancamentos
	Fread( nHdlBco, @xBuffer, nTamLin )

	If	Empty(xBuffer)
		Exit
	Endif

	If (lFebraban .And.(SubStr(xBuffer,8,1 ) == "1")) .Or. (!lFebraban .And. SubStr(xBuffer,1,1) == "1" .And. SubStr(xBuffer,aPosicoes[4,2],aPosicoes[4,3]) == "0")
		If li + 5 > 58
		   //LGS#20200130 - Adequação para release 12.1.25 e posteriores
		   //cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP") )
		   cabec( titulo, cabec1, cabec2, nomeprog, tamanho, _nComp )
		Endif
	
		li++                     
		@ li,17 PSAY repl("*",16)
		@ li,35 PSAY repl("*",45)
		li++                      
		                
		cAgeArq := SubStr(xBuffer,aPosicoes[2,2],aPosicoes[2,3] )
		cCtaArq := SubStr(xBuffer,aPosicoes[3,2],aPosicoes[3,3] )
		
		@ li, 17 PSAY cAgeArq + "/"+ cCtaArq
		
		@ li, 35 PSAY OemToAnsi(STR0008)  //"SALDO INICIAL EM "
		If mv_par07 == 1  //Bancos
			cData := SubStr(xBuffer,aPosicoes[6,2],aPosicoes[6,3] )
		ElseIf mv_par07 == 2 // Febraban
			cData := SubStr(xBuffer,aPosicoes[4,2],aPosicoes[4,3] )
		Endif
		cData :=ChangDate(cData,SEE->EE_TIPODAT)
		dData := CtoD(Substr( cData,1,2)+"/"+;
						  SubStr( cData,3,2)+"/"+;
						  SubStr( cData,5,2),"ddmmyy" )
	
		@ li, 52 PSAY dData 
	
		cSitLanc := IIF ( mv_par07 == 1 ,;
								SubStr(xBuffer,aPosicoes[7,2],aPosicoes[7,3] ),;
								SubStr(xBuffer,aPosicoes[5,2],aPosicoes[5,3] ) )
	
		nSaldoInicial := IIF ( mv_par07 == 1 ,;
										Val(SubStr(xBuffer,aPosicoes[5,2],aPosicoes[5,3] ))/100 ,;
										Val(SubStr(xBuffer,aPosicoes[3,2],aPosicoes[3,3] ))/100 )
	
		@ li,    Iif( cSitLanc == "C", 65,85 ) PSAY nSaldoInicial Picture "@E 9999,999,999.99"
		li++                     
		@ li,17 PSAY repl("*",16)
		@ li,35 PSAY repl("*",45)
		IncRegua()
		li++
		nSaldoInicial *= Iif( cSitLanc == "C", 1,-1) // Inverte o sinal, caso o saldo inicial seja negativo.
	                               
	ElseIf (lFebraban .And.(SubStr(xBuffer,8,1 ) == "3")) .Or. (!lFebraban .And. SubStr(xBuffer,1,1) == "1" .And. SubStr(xBuffer,aPosicoes[4,2],aPosicoes[4,3]) == "1")

		If li > 58
		   //LGS#20200130 - Adequação para release 12.1.25 e posteriores
 		   //cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP") )
 		   cabec( titulo, cabec1, cabec2, nomeprog, tamanho, _nComp )
		Endif
		
		cCodMov	:=Substr(xBuffer,aPosicoes[11,2],aPosicoes[11,3])
		dbSelectArea("SEJ") 
		If dbSeek(xFilial("SEJ")+mv_par01+cCodMov)
			cSitLanc := SEJ->EJ_DEBCRE 
		Else                      
			Help(" ",1,"FA470OCOR",, "Código da ocorrência: " + cCodMov + " Codigo do banco: " + mv_par01, 4, 0)
			lSaida := .T.
			Exit
		Endif
	
		cData := SubStr(xBuffer,aPosicoes[9,2],aPosicoes[9,3] )
		cData := ChangDate(cData,SEE->EE_TIPODAT)
		dData := CtoD(Substr( cData,1,2)+"/"+;
						  SubStr( cData,3,2)+"/"+;
						  SubStr( cData,5,2),"ddmmyy" )
		cNum  := SubStr(xBuffer,aPosicoes[8,2],aPosicoes[8,3] )
		cDesc := SubStr(xBuffer,aPosicoes[12,2],aPosicoes[12,3] )
		nValor := Val(SubStr(xBuffer,aPosicoes[10,2],aPosicoes[10,3] ))/100
		If cSitLanc == "C" 
			nSaldoInicial += nValor
		Else
			nSaldoInicial -= nValor
		Endif
	
		@ li,00 PSAY dData 
		@ li,10 PSAY cNum 
		@ li,35 PSAY Substr(cDesc,1,30)
	   @ li, Iif( cSitLanc == "C"  ,65,85) PSAY nValor Picture "@E 9999,999,999.99"
		@ li,105 PSAY nSaldoInicial Picture "@E 9999,999,999.99" 
		li++
	   IncRegua()

	ElseIf (lFebraban .And.(SubStr(xBuffer,8,1 ) == "5")) .Or. (SubStr(xBuffer,aPosicoes[4,2],aPosicoes[4,3]) == "2" .And. !lFebraban)	
	
		@ li,35 PSAY repl("*",45)
		IncRegua()
		li++
		cSitLanc := SubStr(xBuffer,aPosicoes[16,2],aPosicoes[16,3] )
		nValor := Val(SubStr(xBuffer,aPosicoes[15,2],aPosicoes[15,3] ))/100
		cData := SubStr(xBuffer,aPosicoes[14,2],aPosicoes[14,3] )
		cData := ChangDate(cData,SEE->EE_TIPODAT)
		dData := CtoD(Substr( cData,1,2)+"/"+;
						  SubStr( cData,3,2)+"/"+;
						  SubStr( cData,5,2),"ddmmyy" )

		@ li, 35 PSAY "SALDO FINAL EM "
		@ li, 52 PSAY dData 
	   @ li,    Iif( cSitLanc == "C", 65, 85)  PSAY nValor Picture "@E 9999,999,999.99"
		li++

		If lFebraban
			nTotCred := Val(SubStr(xBuffer,aPosicoes[19,2],aPosicoes[19,3] ))/100
			nTotDeb  := Val(SubStr(xBuffer,aPosicoes[18,2],aPosicoes[18,3] ))/100
			@ li,35 PSAY OemToAnsi(STR0009)  //"TOTAL CREDITOS"
			@ li,65 PSAY nTotCred Picture "@E 9999,999,999.99" 
			IncRegua()
			li++
			@ li,35 PSAY OemToAnsi(STR0010)  //"TOTAL DEBITOS "
			@ li,65 PSAY nTotDeb Picture "@E 9999,999,999.99" 
			li++
			@ li,35 PSAY repl("*",45)
			li++
		Endif
	ElseIf (SubStr(xBuffer,1,1) == "9" .And. !lFebraban)	
		nTotCred := Val(SubStr(xBuffer,aPosicoes[19,2],aPosicoes[19,3] ))/100
		nTotDeb  := Val(SubStr(xBuffer,aPosicoes[18,2],aPosicoes[18,3] ))/100
		@ li,35 PSAY OemToAnsi(STR0009)  //"TOTAL CREDITOS"
		@ li,65 PSAY nTotCred Picture "@E 9999,999,999.99" 
		IncRegua()
		li++
		@ li,35 PSAY OemToAnsi(STR0010)  //"TOTAL DEBITOS "
		@ li,65 PSAY nTotDeb Picture "@E 9999,999,999.99" 
		li++
		@ li,35 PSAY repl("*",45)
		li++
	Endif
Enddo

Roda(cbcont,cbtxt,"M")
Set( 20, "SCREEN" )
Fclose( nHdlBco )  // Fecha sequencial enviado pelo banco
Fclose( nHdlConf ) // Fecha sequencial do configurador
If aReturn[5] = 1
    Set( 24, "" )
    dbCommitAll()
    OurSpool(wnrel)
Endif
MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³AjustaSX1 ³ Autor ³ Gustavo Henrique      ³ Data ³ 08/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza perguntas no SX1                              	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³AjustaSX1 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³BRFINR68	    											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//LGS#20200130 - Adequação para release 12.1.25 e posteriores
/*
Static Function AjustaSX1()

Local aArea		:= GetArea()
Local aAreaSX1	:= SX1->( GetArea() )
Local aHelpPor	:= {}
Local aHelpSpa	:= {}
Local aHelpEng	:= {}                       

Local nTamGrupo	:= Len(SX1->X1_GRUPO)

// Se a 4a pergunta nao for subconta, a mesma nao existe no grupo FIN680 padrao,
// entao deve alterar a ordem das perguntas jah existentes para inclusao da subconta
If	SX1->( MsSeek( PadR( "FIN680", nTamGrupo ) + "04" ) ) .And.;
	! ( "SUBCONTA" $ AllTrim( Upper( SX1->X1_PERGUNT ) ) )

	// Altera os dados da atual pergunta 06 para a ordem 07
	If SX1->( MsSeek( PadR( "FIN680", nTamGrupo ) + "06" ) )

 		SX1->( RecLock( "SX1", .F. ) )
 		SX1->X1_ORDEM	:= "07"
 		SX1->X1_VARIAVL	:= "mv_ch7"
 		SX1->X1_VAR01	:= "mv_par07"
 		SX1->X1_HELP	:= ".FIN68007."
 		SX1->( MsUnlock() )    	      
 		
		aHelpPor := {}
		aHelpSpa := {}
		aHelpEng := {}
	                       
		Aadd(aHelpPor,'Selecione o modelo do extrato: "Bancos"'		)
		Aadd(aHelpPor,'ou "Febraban". Os arquivos do modelo'		)
		Aadd(aHelpPor,'"Bancos" podem possuir 200 ou 240'			)
		Aadd(aHelpPor,'posições/linha. Os arquivos modelo'			)
		Aadd(aHelpPor,'"Bancos" de 200 posições geralmente são' 	)
		Aadd(aHelpPor,'compostas por Header, Detalhe e Trailer.'	)
		Aadd(aHelpPor,'Os arquivos modelo Banco de 240 posições'	)
		Aadd(aHelpPor,'são geralmente compostos por Header de'		)
		Aadd(aHelpPor,'Arquivo, Header de Lote, Detalhe,'			)
		Aadd(aHelpPor,'Trailer de Lote e Trailer de Arquivo.'		)
		Aadd(aHelpPor,'Os arquivos do modelo Febraban possuem'		)
		Aadd(aHelpPor,'Header, Detalhe e Trailer com 240'			)
		Aadd(aHelpPor,'posições/linha'								)
                          
		Aadd(aHelpSpa,'Elija el modelo del extracto: "Bancos" o'	)
		Aadd(aHelpSpa,'"Febraban". Los archivos del modelo'			)
		Aadd(aHelpSpa,'"Bancos" pueden poseer 200 o 240'			)
		Aadd(aHelpSpa,'posiciones / lineas. Los archivos modelo'	)
		Aadd(aHelpSpa,'"Bancos" de 200 posiciones generalmente'		)
		Aadd(aHelpSpa,'son compuestos por Header, Detalle y'		)
		Aadd(aHelpSpa,'Trailer. Los archivos modelo Banco de'		)
		Aadd(aHelpSpa,'240 posiciones son generalmente'				)
		Aadd(aHelpSpa,'compuestos por Header de Archivo, Header'	)
		Aadd(aHelpSpa,'de Lote, Detalle, Trailer de Lote y'			)
		Aadd(aHelpSpa,'Trailer de Archivo.'							)
		Aadd(aHelpSpa,'Los archivos del modelo Febraban posen'		)
		Aadd(aHelpSpa,'Header, Detalle y Trailer con 240'			)
		Aadd(aHelpSpa,'posiciones / lineas.'						)
                       
		Aadd(aHelpEng,'Select the statement model: "Banks" or'	)
		Aadd(aHelpEng,'"Febraban". The "Banks" file can have'	)
		Aadd(aHelpEng,'220 or 240 positions. The bans fiel of'	)
		Aadd(aHelpEng,'200 positions are generally composed'	)
		Aadd(aHelpEng,'Header, Detail and Trailer. The banks'	)
		Aadd(aHelpEng,'files that have 240 positions are'		)
		Aadd(aHelpEng,'generally composed by File Header, Lot'	)
		Aadd(aHelpEng,'Header, Detail, Lot Trailer and' 		)
		Aadd(aHelpEng,'File Trailer. The "Febraban" files have'	)
		Aadd(aHelpEng,'Header, Detail and Trailer with 240' 	)
		Aadd(aHelpEng,'positions/lines.'						)
		
		PutSX1Help("P.FIN68007.",aHelpPor,aHelpEng,aHelpSpa)
 		
	EndIf

	// Altera os dados da atual pergunta 05 para a ordem 06
	If SX1->( MsSeek( PadR( "FIN680", nTamGrupo ) + "05" ) )

 		SX1->( RecLock( "SX1", .F. ) )
 		SX1->X1_ORDEM	:= "06"
 		SX1->X1_VARIAVL	:= "mv_ch6"
 		SX1->X1_VAR01	:= "mv_par06"
 		SX1->X1_HELP	:= ".FIN68006."
 		SX1->( MsUnlock() )    	      
 		
		aHelpPor := {}
		aHelpSpa := {}
		aHelpEng := {}

		Aadd(aHelpPor,"Informe o nome do arquivo de entrada" )
		Aadd(aHelpPor,"gerado pelo banco, quando da" )
		Aadd(aHelpPor,"gravação deste em meio magnético." )

		Aadd(aHelpSpa,"Digite el nombre del archivo de entrada" )
		Aadd(aHelpSpa,"generado por el banco, en el momento de" )
		Aadd(aHelpSpa,"la grabacion de este en medio magnetico." )
	                   
		Aadd(aHelpEng,"Enter the name of the inflow file" )
		Aadd(aHelpEng,"generated by the bank when this file was" )
		Aadd(aHelpEng,"written in magnetic meida." )
	                        
		PutSX1Help("P.FIN68006.",aHelpPor,aHelpEng,aHelpSpa)
 		
	EndIf

	// Altera os dados da atual pergunta 04 para a ordem 05
	If SX1->( MsSeek( PadR( "FIN680", nTamGrupo ) + "04" ) )

 		SX1->( RecLock( "SX1", .F. ) )
 		SX1->X1_ORDEM	:= "05"
 		SX1->X1_VARIAVL	:= "mv_ch5"
 		SX1->X1_VAR01	:= "mv_par05"
 		SX1->X1_HELP	:= ".FIN68005."
 		SX1->( MsUnlock() )    	      
 		
		aHelpPor := {}
		aHelpSpa := {}
		aHelpEng := {}

		Aadd(aHelpPor,"Informe o nome do arquivo de"	 			)
		Aadd(aHelpPor,"configuração do lay-out do arquivo de"		)
		Aadd(aHelpPor,"retorno definido ao banco." 					)

		Aadd(aHelpSpa,"Digite el nombre del archivo de"				)
		Aadd(aHelpSpa,"configuracion del lay-out del archivo de"	)
		Aadd(aHelpSpa,"retorno definido al banco."					)

		Aadd(aHelpEng,"Enter the file name of the lay-out" 			)
		Aadd(aHelpEng,"configuration related to the return file" 	)
		Aadd(aHelpEng,"defined to the bank." 						)
		
		PutSX1Help("P.FIN68005.",aHelpPor,aHelpEng,aHelpSpa)
 		
	EndIf

EndIf

// Incluir a pergunta "SubConta" na ordem 04 se nao existir pergunta na numeracao
If ! SX1->( MsSeek( PadR( "FIN680", nTamGrupo ) + "04" ) )

	PutSx1( "FIN680", "04","Da SubConta?","¿De SubCuenta?","From SubAccount?","mv_ch4","C",3,0,0,"G","","","","",;
		"mv_par04","","","","","","","","","","","","","","","","",,,,".FIN68004." )
	
	aHelpPor := {}
	aHelpSpa := {}
	aHelpEng := {}

	Aadd(aHelpPor,"Informe o código da subconta no" )
	Aadd(aHelpPor,"banco que enviou o arquivo de "  )
	Aadd(aHelpPor,"retorno do CNAB."                )
                        
	Aadd(aHelpSpa,"Digite el codigo de la subcuenta en" )
	Aadd(aHelpSpa,"el banco que envio el archivo de"    )
	Aadd(aHelpSpa,"de retorno del CNAB."                )
                   
	Aadd(aHelpEng,"Enter the code of the sub-account" )
	Aadd(aHelpEng,"of the bank that has sent the"     )
	Aadd(aHelpEng,"file of EDTB ."                    )
	
	PutSX1Help("P.FIN68004.",aHelpPor,aHelpEng,aHelpSpa)
                                              
EndIf

RestArea( aAreaSX1 )
RestArea( aArea )

Return*/
