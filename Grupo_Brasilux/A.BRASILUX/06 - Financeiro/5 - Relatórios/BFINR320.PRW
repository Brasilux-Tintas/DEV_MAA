#INCLUDE "BFINR320.CH"
#include "PROTHEUS.CH"
#include "TOPCONN.CH"

Static lFWCodFil := FindFunction("FWCodFil")

// 17/08/2009 - Compilacao para o campo filial de 4 posicoes
// 18/08/2009 - Compilacao para o campo filial de 4 posicoes

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FINR320  ³ Autora³ Adrianne Furtado      ³ Data ³ 06/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Posi‡„o Geral da Cobran‡a.								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FINR320()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BFINR320()

//Local oReport
Local aArea		  := GetArea()
//Local cPerg       := "BFINR320"		// Nome do grupo de perguntas   (FIN320)
PRIVATE aReturn := { OemToAnsi(STR0003), 1,OemToAnsi(STR0004), 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
     u_zcfga01( 'BFINR320' ) //LGS#2021202 - Gravação de log de utilização da rotina
/*
If FindFunction("TRepInUse") .And. TRepInUse()
	oReport := ReportDef( cPerg )
	oReport:PrintDialog()
Else
*/
	Return BFINR320R3( ) // Executa versão anterior do fonte
//Endif

RestArea( aArea )  

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ReportDef º Autor ³ Adrianne Furtado   º Data ³  06/06/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Definicao do objeto do relatorio personalizavel e das      º±±
±±º          ³ secoes que serao utilizadas                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPC1 - Grupo de perguntas do relatorio                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Planejamento e Controle Orcamentario                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*
Static Function ReportDef( cPerg )

Local cReport	:= "BFINR320" // Nome do relatorio
Local cTitulo	:= STR0005	 // Titulo do relatorio -> "Posicao Geral do Contas a Receber"
Local cDescri	:= STR0001 +" "+ STR0002// Descricao do relatorio ->"Este programa ir  emitir a posi‡„o geral da cobran‡a no mˆs"
									//"referente a data base do sistema."
Local oReport
Local oSection1        
Local oSection2

Pergunte( cPerg, .F. )
                   
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
//"Este relatorio irá apresentar a posiçäo geral da cobrança no mês referente a data base do sistema."
oReport  := TReport():New( cReport , cTitulo, cPerg, { |oReport| BFINR320Imp( oReport ) }, cDescri ) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a 1a. secao do relatorio                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1 := TRSection():New( oReport, STR0059, {"SA1"}, )//"Dados do Cliente"*/
//TRCell():New( oSection1, "A1_COD"	,"SA1",,/*Picture*/,,/*lPixel*/,/*{|| code-block de impressao }*/)
//TRCell():New( oSection1, "A1_LOJA"	,"SA1",,/*Picture*/,,/*lPixel*/,/*{|| code-block de impressao }*/)
//TRCell():New( oSection1, "A1_NOME"	,"SA1",,/*Picture*/,,/*lPixel*/,/*{|| code-block de impressao }*/)
/*
oSection1:SetNoFilter({"SA1"})
oSection1:HideHeader()
oSection1:Hide()

oSection2 := TRSection():New( oSection1, STR0060, {"SE1","SED"}, ) // "Faturamento (no mes)"*/
//TRCell():New( oSection2, "CelDesc"	,,STR0058					,/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/)	// Descricao
//TRCell():New( oSection2, "CelValor"	,,STR0054+GetMv("MV_SIMB1"),/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/)	// Valor
//TRCell():New( oSection2, "CelQuant"	,,STR0055					,/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/)	// Quantidade
/*
//Faz o alinhamento do cabecalho das celulas
oSection2:Cell("CelValor"):SetHeaderAlign("RIGHT")
oSection2:Cell("CelQuant"):SetHeaderAlign("RIGHT")

oSection3 := TRSection():New( oSection1, STR0061, {"SE1","SED"} )	// "Valores Baixados"*/
//TRCell():New( oSection3, "CelDesc"	,,STR0058,/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/)					// Descricao
//TRCell():New( oSection3, "CelValor"	,,STR0054+GetMv("MV_SIMB1"),/*Picture*/,/*lPixel*/,/*{|| code-block de impressao }*/)					// Valor
//TRCell():New( oSection3, "CelQuant"	,,STR0055,/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/)					// Quantidade

//oSection4 := TRSection():New( oSection1, STR0062, {"SE1","SED"} )	// "Titulos a vencer"
//TRCell():New( oSection4, "CelDesc"	,,STR0058,/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/)					// Descricao
//TRCell():New( oSection4, "CelValor"	,,STR0054+GetMv("MV_SIMB1"),/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/)					// Valor
//TRCell():New( oSection4, "CelQuant"	,,STR0055,/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/)					// Quantidade

//oSection5 := TRSection():New( oSection1, STR0063, {"SE1","SED"} )	// "Titulos vencidos"
//TRCell():New( oSection5, "CelDesc"	,,STR0058,/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/)					// Descricao
//TRCell():New( oSection5, "CelValor"	,,STR0054+GetMv("MV_SIMB1"),/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/)					// Valor
//TRCell():New( oSection5, "CelQuant"	,,STR0055,/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/)					// Quantidade

//oSection6 := TRSection():New( oSection1, STR0064, {"SE1","SED"} )	// "Recebimento e notas de credito"
//TRCell():New( oSection6, "CelDesc"	,,STR0058,/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/)					// Descricao
//TRCell():New( oSection6, "CelValor"	,,STR0054+GetMv("MV_SIMB1"),/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/)					// Valor
//TRCell():New( oSection6, "CelQuant"	,,STR0055,/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/)					// Quantidade

//oSection7 := TRSection():New( oSection1, STR0065, {"SE1","SED"} )	// "Distribuicao da cobranca"
//TRCell():New( oSection7, "CelDesc"	,,STR0058,/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/)					// Descricao
//TRCell():New( oSection7, "CelValor"	,,STR0054+GetMv("MV_SIMB1"),/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/)					// Valor
//TRCell():New( oSection7, "CelQuant"	,,STR0055,/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/)					// Quantidade

//oSection8 := TRSection():New( oSection1, STR0066, {"SE1","SED"} )	// "Por tipo de titulo"
//TRCell():New( oSection8, "CelDesc"	,,STR0058,/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/)					// Descricao
//TRCell():New( oSection8, "CelValor"	,,STR0054+GetMv("MV_SIMB1"),/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/)					// Valor
//TRCell():New( oSection8, "CelQuant"	,,STR0055,/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/)					// Quantidade

//oSection9 := TRSection():New( oSection1, STR0067, {"SE1","SED"} )	// "Carteira de pedidos a entregar"
//TRCell():New( oSection9, "CelDesc"	,,STR0058,/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/)					// Descricao
//TRCell():New( oSection9, "CelValor"	,,STR0054+GetMv("MV_SIMB1"),/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/)					// Valor
//TRCell():New( oSection9, "CelQuant"	,,STR0055,/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/)					// Quantidade

//oSection10 := TRSection():New( oSection1, STR0068, {"SE1","SED"} )	// "Prazos medios e quociente de atraso"
//TRCell():New( oSection10, "CelDesc"	,,STR0058,/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/)					// Descricao
//TRCell():New( oSection10, "CelValor"	,,STR0054+GetMv("MV_SIMB1"),/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/)					// Valor
//TRCell():New( oSection10, "CelQuant"	,,STR0055,/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/)					// Quantidade

//Return oReport                   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BFINR320Imp ºAutor³Adrianne Furtado    º Data ³  07/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPO1 - Objeto TReport do relatorio                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*
Static Function BFINR320Imp( oReport )
Local oCliente  := oReport:Section(1)
Local oSection1 := oReport:Section(1):Section(1) 
Local oSection2 := oReport:Section(1):Section(1)
Local oSection3 := oReport:Section(1):Section(1)
Local oSection4 := oReport:Section(1):Section(1)
Local oSection5 := oReport:Section(1):Section(1)
Local oSection6 := oReport:Section(1):Section(1)
Local oSection7 := oReport:Section(1):Section(1)
Local oSection8 := oReport:Section(1):Section(1)
Local oSection9 := oReport:Section(1):Section(1)
Local nLinha	:= 0
Local aVal
Local aValor	:={}
//Local nX
//Local nMeter	:= 0          
Local cFiltSE1 := oReport:Section(1):GetAdvplExp("SE1")
Local cFiltSED := oReport:Section(1):GetAdvplExp("SED")

aVal := BFA320Calc(cFiltSE1,cFiltSED)

aADD(aValor,{STR0010,aVal[1,1]+aVal[2,1],aVal[1,2]+aVal[2,2]}) 		//"FATURAMENTO (no mes)"
aADD(aValor,{STR0011,aVal[1,1],aVal[1,2]})	 						//"A Vista"
aADD(aValor,{STR0012,aVal[2,1],aVal[2,2]}) 							//"A Prazo"

aADD(aValor,{STR0051,""					 ,""		}) 				//"VALORES BAIXADOS"
aADD(aValor,{STR0013,aVal[40,1]			 ,""		}) 				//"RECEBIDO"
aADD(aValor,{STR0014,aVal[41,1]			 ,""		}) 				//"TAXA DE PERMANENCIA"          
aADD(aValor,{STR0015,aVal[42,1]			 ,""		}) 				//"Multa"
aADD(aValor,{STR0016,aVal[43,1]			 ,""		}) 				//"CORRECAO"
aADD(aValor,{STR0017,aVal[44,1]			 ,""		}) 				//"DESCONTO"
aADD(aValor,{STR0018,aVal[45,1]			 ,""		}) 				//"ORIGINAL"

//"TITULOS A VENCER"
aADD(aValor,{STR0019,(aVal[39,1]+aVal[7,1]+aVal[8,1]+aVal[9,1]+aVal[10,1])  ,(aVal[39,2]+aVal[7,2]+aVal[8,2]+aVal[9,2]+aVal[10,2])}) 
aADD(aValor,{STR0052,aVal[39,1]			 ,aVal[39,2]	}) 				//"Ate 15 Dias"
aADD(aValor,{STR0053,aVal[07,1]    		 ,aVal[07,2]	}) 				//"De 16 a 30 dias"
aADD(aValor,{STR0023,aVal[08,1]    		 ,aVal[08,2]	}) 				//"De 31 a 60 dias"
aADD(aValor,{STR0024,aVal[09,1]    		 ,aVal[09,2]	}) 				//"De 61 a 90 dias"
aADD(aValor,{STR0025,aVal[10,1]   		 ,aVal[10,2]	}) 				//"Acima de 90 Dias

//"TITULOS VENCIDOS"
aADD(aValor,{STR0026,(aVal[38,1]+aVal[3,1]+aVal[4,1]+aVal[5,1]+aVal[6,1])  ,(aVal[38,2]+aVal[3,2]+aVal[4,2]+aVal[5,2]+aVal[6,2])}) 
aADD(aValor,{STR0052,aVal[38,1]			 ,aVal[38,2]	}) 				//"Ate 15 Dias"
aADD(aValor,{STR0053,aVal[03,1]    		 ,aVal[03,2]	}) 				//"De 16 a 30 dias"
aADD(aValor,{STR0023,aVal[04,1]    		 ,aVal[04,2]	}) 				//"De 31 a 60 dias"
aADD(aValor,{STR0024,aVal[05,1]    		 ,aVal[05,2]	}) 				//"De 61 a 90 dias"
aADD(aValor,{STR0025,aVal[06,1]   		 ,aVal[06,2]	}) 				//"Acima de 90 Dias

aADD(aValor,{STR0020,aVal[24,1]   		 ,aVal[24,2]	}) 				//"Recebimento Antecipado"
aADD(aValor,{STR0021,aVal[36,1]			 ,aVal[36,2]	}) 				//"Notas de Credito"

aADD(aValor,{STR0027,""					 ,""			}) 				//"DISTRIBUICAO DA COBRANCA"
aADD(aValor,{STR0028,aVal[25,1]			 ,aVal[25,2]	}) 				//"Carteira"
aADD(aValor,{STR0029,aVal[26,1]			 ,aVal[26,2]	}) 				//"Cobranca Simples"
aADD(aValor,{STR0030,aVal[27,1]			 ,aVal[27,2]	}) 				//"Cobranca Descontada"
aADD(aValor,{STR0031,aVal[28,1]			 ,aVal[28,2]	}) 				//"Cobranca Caucionada"
aADD(aValor,{STR0032,aVal[29,1]			 ,aVal[29,2]	}) 				//"Cobranca Vinculada"
aADD(aValor,{STR0033,aVal[30,1]			 ,aVal[30,2]	}) 				//"Cobranca Extra-Judicial" "Cobrança c/Advogado"
aADD(aValor,{STR0034,aVal[31,1]			 ,aVal[31,2]	}) 				//"Cobranca Cartorio" "Cobranca Judicial"
aADD(aValor,{STR0035,aVal[37,1]			 ,aVal[37,2]	}) 				//"Cobr Cauc Descont"

aADD(aValor,{STR0036,""					 ,""			}) 				//"POR TIPO DE TITULO"
aADD(aValor,{STR0037,aVal[11,1]			 ,aVal[11,2]	}) 				//"Duplicatas"
aADD(aValor,{STR0038,aVal[12,1]			 ,aVal[12,2]	}) 				//"Notas Fiscais"
aADD(aValor,{STR0039,aVal[13,1]			 ,aVal[13,2]	}) 				//"Cheques Pre-Datados"
aADD(aValor,{STR0040,aVal[14,1]			 ,aVal[14,2]	}) 				//"Carnet De Pagamento"
aADD(aValor,{STR0041,aVal[15,1]			 ,aVal[15,2]	}) 				//"Impostos"
aADD(aValor,{STR0042,aVal[35,1]			 ,aVal[35,2]	}) 				//"Abatimentos"
aADD(aValor,{STR0043,aVal[16,1]			 ,aVal[16,2]	}) 				//"Outros"

//"CARTEIRA DE PEDIDOS A ENTREGAR"
aADD(aValor,{STR0044,(aVal[17,1]+aVal[18,1]+aVal[19,1]+aVal[20,1]+aVal[21,1])  ,(aVal[17,2]+aVal[18,2]+aVal[19,2]+aVal[20,2]+aVal[21,2])}) 
aADD(aValor,{STR0045,aVal[21,1]			 ,aVal[21,2]	}) 				//"Itens de Pedidos Vencidos"
aADD(aValor,{STR0022,aVal[17,1]    		 ,aVal[17,2]	}) 				//"Ate 30 Dias"
aADD(aValor,{STR0023,aVal[18,1]    		 ,aVal[18,2]	}) 				//"De 31 a 60 dias"
aADD(aValor,{STR0024,aVal[19,1]    		 ,aVal[19,2]	}) 				//"De 61 a 90 dias"
aADD(aValor,{STR0025,aVal[20,1]   		 ,aVal[20,2]	}) 				//"Acima de 90 Dias

aADD(aValor,{STR0047,"" 	,(aVal[22,1]/aVal[22,2])	}) 				//"Prazo Medio Absoluto"
aADD(aValor,{STR0048,""  	,(aVal[23,1]/aVal[23,2])	}) 				//"Prazo Medio Ponderado"
aADD(aValor,{STR0049,""  	,(((aVal[38,1]+aVal[3,1]+aVal[4,1]+aVal[5,1]+aVal[6,1])/aVal[34,1]))*100})	//"Quociente De Atraso"

oReport:SetMeter(Len(aValor))       

oCliente:Init()
oCliente:PrintLine()
oCliente:Finish()

// primeira secao  --> FATURAMENTO
oSection1:Init()                 
oSection1:Cell("CelDesc" ):SetBlock( { || aValor[nLinha,1] } )
oSection1:Cell("CelValor"):SetBlock( { || aValor[nLinha,2] } )
oSection1:Cell("CelQuant"):SetBlock( { || aValor[nLinha,3] } )
oSection1:Cell("CelValor"):SetPicture(TM(aValor[1,2],18, MsDecimais(MV_PAR08)))
For nLinha := 1 to 3
	oReport:IncMeter()
	oSection1:PrintLine()
Next 
oSection1:Finish()      

// segunda secao --> VALORES BAIXADOS
oSection2:Init()     
oSection2:SetHeaderSection(.F.)
oReport:ThinLine()
oSection2:Cell("CelDesc" ):SetBlock( { || aValor[nLinha,1] } )
oSection2:Cell("CelValor"):SetBlock( { || aValor[nLinha,2] } )
oSection2:Cell("CelQuant"):SetBlock( { || aValor[nLinha,3] } )   
For nLinha := 4 to 10
	If nLinha == 4
		oSection1:Cell("CelValor"):SetPicture("") //Não deve utilizar picture no titulo da secao que n imprime valores
	ElseIf nLinha == 5
		oSection1:Cell("CelValor"):SetPicture(PesqPict("SE5","E5_VALOR",oSection1:Cell("CelValor"):nSize,MV_PAR08))
	EndIf
	oReport:IncMeter()
	oSection2:PrintLine()
Next 
oSection2:Finish()      

// terceira secao --> TITULOS A VENCER
oSection3:Init()
oReport:ThinLine()
oSection3:Cell("CelDesc" ):SetBlock( { || aValor[nLinha,1] } )
oSection3:Cell("CelValor"):SetBlock( { || aValor[nLinha,2] } )
oSection3:Cell("CelQuant"):SetBlock( { || aValor[nLinha,3] } )
oSection3:Cell("CelValor"):SetPicture(PesqPict("SE5","E5_VALOR",oSection3:Cell("CelValor"):nSize,MV_PAR08))
For nLinha := 11 to 16
	oReport:IncMeter()
	oSection3:PrintLine()
Next 
oSection3:Finish()      

// quarta secao --> TITULOS VENCIDOS
oSection4:Init()
oReport:ThinLine()
oSection4:Cell("CelDesc" ):SetBlock( { || aValor[nLinha,1] } )
oSection4:Cell("CelValor"):SetBlock( { || aValor[nLinha,2] } )
oSection4:Cell("CelQuant"):SetBlock( { || aValor[nLinha,3] } )
oSection4:Cell("CelValor"):SetPicture(PesqPict("SE5","E5_VALOR",oSection4:Cell("CelValor"):nSize,MV_PAR08))
For nLinha := 17 to 22
	oReport:IncMeter()
	oSection4:PrintLine()
Next 
oSection4:Finish()      

// quinta secao --> RECEBIMENTO ANTECIPADO E NOTAS DE CREDITO
oSection5:Init()
oReport:ThinLine()
oSection5:Cell("CelDesc" ):SetBlock( { || aValor[nLinha,1] } )
oSection5:Cell("CelValor"):SetBlock( { || aValor[nLinha,2] } )
oSection5:Cell("CelQuant"):SetBlock( { || aValor[nLinha,3] } )
oSection5:Cell("CelValor"):SetPicture(PesqPict("SE5","E5_VALOR",oSection5:Cell("CelValor"):nSize,MV_PAR08))
For nLinha := 23 to 24
	oReport:IncMeter()
	oSection5:PrintLine()
Next 
oSection5:Finish()      

// sexta secao -->DISTRIBUICAO DA COBRANCA
oSection6:Init()
oReport:ThinLine()
oSection6:Cell("CelDesc" ):SetBlock( { || aValor[nLinha,1] } )
oSection6:Cell("CelValor"):SetBlock( { || aValor[nLinha,2] } )
oSection6:Cell("CelQuant"):SetBlock( { || aValor[nLinha,3] } )
For nLinha := 25 to 33
	If nLinha == 25
		oSection6:Cell("CelValor"):SetPicture("") //Não deve utilizar picture no titulo da secao que n imprime valores
	ElseIf nLinha == 26
		oSection6:Cell("CelValor"):SetPicture(PesqPict("SE5","E5_VALOR",oSection6:Cell("CelValor"):nSize,MV_PAR08))
	EndIf
	oReport:IncMeter()
	oSection6:PrintLine()
Next 
oSection6:Finish()      

// sétima secao  --> POR TIPO DE TITULO
oSection7:Init()
oReport:ThinLine()
oSection7:Cell("CelDesc" ):SetBlock( { || aValor[nLinha,1] } )
oSection7:Cell("CelValor"):SetBlock( { || aValor[nLinha,2] } )
oSection7:Cell("CelQuant"):SetBlock( { || aValor[nLinha,3] } )
For nLinha := 34 to 41
	If nLinha == 34
		oSection7:Cell("CelValor"):SetPicture("") //Não deve utilizar picture no titulo da secao que n imprime valores
	ElseIf nLinha == 35
		oSection7:Cell("CelValor"):SetPicture(PesqPict("SE5","E5_VALOR",oSection7:Cell("CelValor"):nSize,MV_PAR08))
	EndIf
	oReport:IncMeter()
	oSection7:PrintLine()
Next 
oSection7:Finish()      

// oitava secao  -->CARTEIRA DE PEDIDOS A ENTREGAR
oSection8:Init()
oReport:ThinLine()
oSection8:Cell("CelDesc" ):SetBlock( { || aValor[nLinha,1] } )
oSection8:Cell("CelValor"):SetBlock( { || aValor[nLinha,2] } )
oSection8:Cell("CelQuant"):SetBlock( { || aValor[nLinha,3] } )   
oSection8:Cell("CelValor"):SetPicture(PesqPict("SE5","E5_VALOR",oSection8:Cell("CelValor"):nSize,MV_PAR08))
For nLinha := 42 to 47
	oReport:IncMeter()
	oSection8:PrintLine()
Next 
oSection8:Finish()      

// nona secao --> PRAZO MEDIO E QUOCIENTE DE ATRASO
oSection9:Init()
oReport:ThinLine()
oSection9:Cell("CelDesc" ):SetBlock( { || aValor[nLinha,1] } )
oSection9:Cell("CelValor"):SetBlock( { || aValor[nLinha,2] } )
oSection9:Cell("CelQuant"):SetBlock( { || aValor[nLinha,3] } )
oSection9:Cell("CelValor"):SetPicture("")
oSection9:Cell("CelQuant"):SetPicture("999.99")
For nLinha := 48 to 50
	oReport:IncMeter()
	oSection9:PrintLine()
Next 
oSection9:Finish()      

Return*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FINR320  ³ Autor ³ Paulo Boschetti       ³ Data ³ 05.06.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Posi‡„o Geral da Cobran‡a.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FINR320(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function BFINR320R3()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL wnrel
LOCAL cString:="SE1"
LOCAL cDesc1 := STR0001 //"Este programa ir  emitir a posi‡„o geral da cobran‡a no mˆs"
LOCAL cDesc2 := STR0002 //"referente a data base do sistema."
LOCAL cDesc3 :=""
LOCAL Tamanho := "M"
//Local aPergs	:= {}
Local dOldDtBase := dDataBase

PRIVATE titulo
PRIVATE cabec1
PRIVATE cabec2 
PRIVATE aReturn := { OemToAnsi(STR0003), 1,OemToAnsi(STR0004), 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
PRIVATE nomeprog:="BFINR320"
PRIVATE cPerg   :="BFINR320"
PRIVATE nLastKey:= 0
PRIVATE nJuros  := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao dos cabecalhos                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
titulo := OemToAnsi(STR0005)  //"Posicao Geral do Contas a Receber"
cabec1 := OemToAnsi(STR0006)+GetMv("MV_SIMB1")+OemToAnsi(STR0007)  //"                                             Valores ("###")            Quantidade"
cabec2 := ""

//Nao retire esta chamada. Verifique antes !!!
//Ela é necessaria para o correto funcionamento da pergunte 13 (Data Base)
//PutDtBase()  //LGS#20200130 - Adequação para release 12.1.25 e posteriores
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                        ³
//³ mv_par01            // Imprime Por Filial ou Empresa.       ³
//³ mv_par02            // Nas baixas, Dt Baixa, Digit ou Dispo ³
//³ mv_par03            // Seleciona tipos ( Sim / Nao ).       ³
//³ mv_par04            // Prefixo inicial                      ³
//³ mv_par05            // Prefixo final                        ³
//³ XXXXmv_par06            // Considera Juros                  ³ (EXCLUI MV_PAR06 ORIGIMAL!
//³ mv_par06            // Considera TES para Pedido Venda      ³
//³ MV_PAR07            // Considera data base                  ³
//³ MV_PAR08            // Qual moeda                           ³
//³ MV_PAR09            // Outras moedas                        ³
//³ MV_PAR10            // Considerar Abatimentos(Sim/Nao)      ³
//³ MV_PAR11            // Considerar Pedidos Vendas(Sim/Nao)   ³
//³ MV_PAR12            // Data Base									 ³
//³ MV_PAR13            // Tit. Emissao Futura 						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:="BFINR320"            //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif
dDataBase := MV_PAR12 // Altera data base conforme parametro
RptStatus({|lEnd| BFa320Imp(@lEnd,wnRel,cString)},titulo)
dDataBase := dOldDtBase // Restaura Data base

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FINR320  ³ Autor ³ Paulo Boschetti       ³ Data ³ 05.06.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Posi‡„o Geral da Cobran‡a.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ BFA320Imp(lEnd,wnRelm,Cstring)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Parametro 1 - lEnd    - A‡Æo do CodeBlock                  ³±±
±±³          ³ Parametro 2 - wnRel   - T¡tulo do relat¢rio                ³±±
±±³          ³ Parametro 3 - cString - Mensagem                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function BFA320Imp(lEnd,wnRel,cString)

LOCAL CbCont,CbTxt
LOCAL tamanho:="M"
LOCAL I:=0,J:=0
//Local nSaldo :=0,nSaldoAtu:=0, nDias:=0
//LOCAL nFirst :=1,nFirst1:=1
LOCAL aVal[39,2]
LOCAL nRecebido:=0
LOCAL nValJuros:=0
LOCAL nDesconto:=0
LOCAL nCorrecao:=0
LOCAL nMulta   :=0
LOCAL nOriginal:=0
//LOCAL dDataBaixa
Local cCondSC6,cTpQry
Local cFiltSql
Local dOldDtBase := dDataBase
//LOCAL nX,nIndex
Local cCondFil
Local cQuery,cAux
Local cFilterUser := aReturn[7]
Local aSitua := ARRAY(8)
//Local nI:=0
//Local nMoedaBco := 1
Local nDecs := MsDecimais(MV_PAR08)
Local cAliasTmp, cAbat, cProvis,cWhere
//Local cFiltro, nQtdeReg, cIndTmp, cQry1
Local nTipoData := 1
//Local lAdto
Local cAliasSC6,nContRegua
//Local nValAbat := 0
//Local nAbt		:= 0
//Local nTamFilial:= IIf( lFWCodFil, FWGETTAMFILIAL, 2 )
Local lPrjCni := FindFunction("ValidaCNI") .And. ValidaCNI()
Local _aRetInf := FWGetSX5 ( "07" ) //LGS#20200130 - Adequação para release 12.1.25
Local _nX

aSitua[1] := OemtoAnsi(STR0028)		//"Carteira"
aSitua[2] := OemtoAnsi(STR0029)		//"Cobranca Simples"
aSitua[3] := OemToAnsi(STR0030) 		//"Cobranca Descontada"
aSitua[4] := OemToAnsi(STR0031) 		//"Cobranca Caucionada"
aSitua[5] := OemToAnsi(STR0032)		//"Cobranca Vinculada"
aSitua[6] := OemToAnsi(STR0033)		//"Cobranca Extra-Judicial"
aSitua[7] := OemToAnsi(STR0034)	   //"Cobranca Cartorio"
aSitua[8] := OemToAnsi(STR0035) 	   //"Cobr Cauc Descont"

//Tipo da data para a composicao do saldo via SaldoTit()
If mv_par02 == 1			// Data da baixa (E5_BAIXA)
	nTipoData := 1
ElseIf mv_par02 == 2 	//Data de Digitacao (E5_DTDIGIT)
	nTipoData := 3
Else							//Data de Disponibilidade (E5_DTDISPO)
	nTipoData := 2
Endif

/********************************************************************************************************************************/
/*** BLOCO ALTERADO EM 30/01/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
//dbSelectArea("SX5")
//dbSeek( Space( nTamFilial ) + "07")

//While !Eof() .and. X5_TABELA == "07"

//	nI++
//	If nI > Len(aSitua)
//		Aadd(aSitua," ")		// garante um novo elemento
//	Endif
//	aSitua[nI] := TRIM(X5Descri())
//	dbSkip()
//Enddo
For _nX := 1 To Len( _aRetInf )
    If _nX > Len(aSitua)
       Aadd( aSitua, " " )
    Endif
    aSitua[_nX] := TRIM( _aRetInf[_nX][4] )
Next
/********************************************************************************************************************************/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1
PRIVATE  cTipos := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se seleciona tipos para total faturamento         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTpQry := ""
If mv_par03 == 1
	finaTipos()
	if !empty(cTipos)
		cTpQry := "'"+strtran(cTipos,"/","','")+"'"
	endif 
Endif 
//Filtro Query Abatimentos
cAbat := ""
if !empty(MVABATIM)
	cAbat := strtran(MVABATIM,"|","','")
	cAbat := "'"+strtran(cAbat,"/","','")+"'"
endif 

//Filtro Query Provisorios
cProvis := ""
if !empty(MVPROVIS)
	cProvis := strtran(MVPROVIS,"|","','")
	cProvis := "'"+strtran(cProvis,"/","','")+"'"
endif 

dbSelectArea("SE1")
dbSetOrder(1)
If mv_par01 == 1
	dbSeek(xFilial("SE1"))
Else 
	dbGotop()
Endif

For i := 1 to 39
	For j := 1 to 2
		aVal[I,J] := 0
	Next j
Next i
SetRegua(10)
nContRegua := 0

				cAliasSe5 := "NEWSE5"
				cCondFil := ""
				cCondFil := "WITH TMP AS (SELECT E5_FILIAL,E5_PREFIXO,E5_NUMERO,E5_PARCELA,E5_TIPO,E5_CLIFOR,E5_LOJA,E5_SEQ,E5_TIPODOC,"+;
				"E5_RECPAG,E5_DTDIGIT,E5_DTDISPO,E5_DATA,E5_BANCO,E5_AGENCIA,E5_CONTA,E5_SITUACA,E5_MOTBX,E5_VALOR,"+;
				"E5_TXMOEDA,ISNULL(A6_MOEDA,1) AS A6_MOEDA"
				cCondFil += ",SE5.R_E_C_N_O_ RECNO, "+;
				"BXCANC = ISNULL((SELECT TOP 1 ESTORNO = 1 FROM "+RetSqlName("SE5") + " WHERE "+;
   					"(E5_FILIAL= SE5.E5_FILIAL) AND "+;
				   	"(E5_PREFIXO = SE5.E5_PREFIXO) AND "+;
					"(E5_NUMERO = SE5.E5_NUMERO) AND "+;
					"(E5_PARCELA = SE5.E5_PARCELA) AND "+;
					"(E5_TIPO = SE5.E5_TIPO) AND "+;
					"(E5_CLIFOR = SE5.E5_CLIFOR) AND "+;
					"(E5_LOJA = SE5.E5_LOJA) AND "+;
					"(E5_SEQ = SE5.E5_SEQ) AND "+;
					"(E5_TIPODOC = 'ES') AND "+;
					"(E5_DATA <= '"+DTOS(dDataBase)+"') AND "+;
					"(D_E_L_E_T_ <> '*')),0), "
					If mv_par02 == 1
		  				cCondFil += "E5_DATA"
					ElseIf mv_par02 == 2
				  		cCondFil += "E5_DTDIGIT"
					ElseIf mv_par02 == 3
				  		cCondFil += "E5_DTDISPO"
					Endif				
					cCondFil += " AS DATABAIXA,'"+cPaisLoc+"' AS PAISLOC,"+ALLTRIM(STR(MV_PAR08))+" AS MVPAR09,"+ alltrim(str(nDecs+1))+" AS DECS,"+;
					"ISNULL(MOTBX.MOVBCO,'N') AS MOVBCO "

				cCondFil += "FROM "+RetSqlName("SE5") + " SE5 WITH (NOLOCK) "
				cCondFil += "LEFT OUTER JOIN "+RetSqlName("SA6") + " SA6 WITH (NOLOCK) ON (SA6.D_E_L_E_T_<> '*') AND (A6_FILIAL = '"+xFilial("SA6")+"') AND (E5_BANCO = A6_COD) AND (E5_AGENCIA = A6_AGENCIA) AND (E5_CONTA = A6_NUMCON) "
				cCondFil += "LEFT OUTER JOIN MOTBX WITH (NOLOCK) ON (E5_MOTBX = MOTBX.CODIGO) "
				
				cCondFil += "WHERE " 
				If mv_par01 == 1
					cCondFil += "(E5_FILIAL='" + xFilial("SE5") + "') AND "
				Endif
				cCondFil += "E5_TIPODOC IN ('VL','V2','JR','J2','CM','C2','MT','M2','DC','D2','TL','BA') AND E5_RECPAG = 'R' AND "
				cCondFil += "E5_PREFIXO >= '"+MV_PAR04+"' AND "	
				cCondFil += "E5_PREFIXO <= '"+MV_PAR05+"' AND "
        	    If mv_par02 == 1
					cCondFil += "E5_DATA >= '"
				ElseIf mv_par02 == 2
					cCondFil += "E5_DTDIGIT >= '"
				ElseIf mv_par02 == 3
					cCondFil += "E5_DTDISPO >= '"
				Endif				
				cCondFIl += Subs(dtos(dDataBase),1,6)+"01"+"' AND "
            	If mv_par02 == 1
					cCondFil += "E5_DATA <= '"
				ElseIf mv_par02 == 2
					cCondFil += "E5_DTDIGIT <= '"
				ElseIf mv_par02 == 3
					cCondFil += "E5_DTDISPO <= '"
				Endif				
				cCondFIl += Dtos(LastDay(dDataBase))+"' AND "
	        	// Ignora registros que nao sao da moeda quando escolhido nao imprimir
				if MV_PAR09 == 2 
					cCondFil += "(ISNULL(A6_MOEDA, 1) = "+alltrim(str(MV_PAR08))+") AND "
				endif 
				cCondFil += "(SE5.D_E_L_E_T_<> '*')) "
				cCondFil += "SELECT SUM("+;
				"CASE WHEN ('"+SUBSTR(DTOS(dDatabase),1,6)+"' = SUBSTRING(DATABAIXA,1,6)) AND "+;
				"(E5_RECPAG = 'R') AND (DATABAIXA <= '"+DTOS(dDatabase)+"') AND "+;
				"(E5_TIPODOC IN ('VL','V2','BA')) AND "+ ;
				"(E5_SITUACA <> 'C') AND "+;
				"((MOVBCO = 'S') OR "+;
				"((E5_MOTBX = 'CMP') AND (E5_TIPO IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')))) "+;
				"THEN dbo.xMoeda(E5_VALOR,A6_MOEDA,MVPAR09,E5_DATA,DECS,0,CASE WHEN PAISLOC = 'BRA' THEN E5_TXMOEDA ELSE 0 END) "+;
				"ELSE 0 END) AS RECEBIDOS, SUM("+;
				"CASE WHEN ('"+SUBSTR(DTOS(dDatabase),1,6)+"' = SUBSTRING(DATABAIXA,1,6)) AND "+;
				"(E5_RECPAG = 'R') AND (DATABAIXA <= '"+DTOS(dDatabase)+"') AND "+;
	        	"(E5_SITUACA <> 'C') AND (MOVBCO = 'S') AND "+;
	        	"(E5_TIPODOC IN ('JR','J2','TL')) "+;
				"THEN dbo.xMoeda(E5_VALOR,A6_MOEDA,MVPAR09,E5_DATA,DECS,0,CASE WHEN PAISLOC = 'BRA' THEN E5_TXMOEDA ELSE 0 END) "+;
				"ELSE 0 END) AS JUROS, SUM("+;
				"CASE WHEN ('"+SUBSTR(DTOS(dDatabase),1,6)+"' = SUBSTRING(DATABAIXA,1,6)) AND "+;
				"(E5_RECPAG = 'R') AND (DATABAIXA <= '"+DTOS(dDatabase)+"') AND "+;
	        	"(E5_SITUACA <> 'C') AND (MOVBCO = 'S') AND "+;
	        	"(E5_TIPODOC IN ('CM','C2')) "+;
				"THEN dbo.xMoeda(E5_VALOR,A6_MOEDA,MVPAR09,E5_DATA,DECS,0,CASE WHEN PAISLOC = 'BRA' THEN E5_TXMOEDA ELSE 0 END) "+;
				"ELSE 0 END) AS CORRECAO, SUM("+;
				"CASE WHEN ('"+SUBSTR(DTOS(dDatabase),1,6)+"' = SUBSTRING(DATABAIXA,1,6)) AND "+;
				"(E5_RECPAG = 'R') AND (DATABAIXA <= '"+DTOS(dDatabase)+"') AND "+;
	        	"(E5_SITUACA <> 'C') AND (MOVBCO = 'S') AND "+;
	        	"(E5_TIPODOC IN ('MT','M2')) "+;
				"THEN dbo.xMoeda(E5_VALOR,A6_MOEDA,MVPAR09,E5_DATA,DECS,0,CASE WHEN PAISLOC = 'BRA' THEN E5_TXMOEDA ELSE 0 END) "+;
				"ELSE 0 END) AS MULTA, SUM("+;
				"CASE WHEN ('"+SUBSTR(DTOS(dDatabase),1,6)+"' = SUBSTRING(DATABAIXA,1,6)) AND "+;
				"(E5_RECPAG = 'R') AND (DATABAIXA <= '"+DTOS(dDatabase)+"') AND "+;
	        	"(E5_SITUACA <> 'C') AND (MOVBCO = 'S') AND "+;
	        	"(E5_TIPODOC IN ('DC','D2')) "+;
				"THEN dbo.xMoeda(E5_VALOR,A6_MOEDA,MVPAR09,E5_DATA,DECS,0,CASE WHEN PAISLOC = 'BRA' THEN E5_TXMOEDA ELSE 0 END) "+;
				"ELSE 0 END) AS DESCONTO "+;
				"FROM TMP"

				//cCondFil := ChangeQuery(cCondFil)
  	
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cCondFil),cAliasSe5,.T.,.T.)
		DbSelectArea(cAliasSe5)
		DbGoTop()     
		nRecebido += (cAliasSe5)->RECEBIDOS
  		nValJuros += (cAliasSe5)->JUROS
    	nCorrecao += (cAliasSe5)->CORRECAO
     	nMulta    += (cAliasSe5)->MULTA
      	ndesconto += (cAliasSe5)->DESCONTO

		dbSelectArea(cAliasSe5)
		dbCloseArea()
		IncRegua()
		nContRegua++
		IncRegua()
		nContRegua++


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula T.Carteira pedidos a entregar / item 6 da analise    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if MV_PAR11 == 1
		cAliasSC6 := 'NEWSC6'	
		cCondSC6 := "WITH TMP AS (SELECT C5_MOEDA,C5_EMISSAO,C6_ENTREG,SUM(C6_PRCVEN*(C6_QTDVEN - C6_QTDENT)) AS SALDO, "+;
		"DATEDIFF(day,CONVERT(DATETIME,'"+dtos(dDatabase)+"',102),  CONVERT(DATETIME,C6_ENTREG,102)) AS DIAS "+;
		"FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "+;
		"LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C6_FILIAL = C5_FILIAL) AND (C6_NUM = C5_NUM) "+;
		"LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (C6_TES = F4_CODIGO) "+;
		"WHERE (SC6.D_E_L_E_T_ <> '*') AND (C6_QTDVEN > C6_QTDENT) AND (C6_BLQ <> 'R') "
		If mv_par01 == 1
			cCondSC6 += "AND (C6_FILIAL = '"+xFilial("SC6")+"') "
		ENDIF 
		IF MV_PAR06 == 1		// Verifica se ir  considerar o TES (F4_DUPLIC)
			cCondSC6 += "AND (F4_DUPLIC = 'S') "
		ENDIF 
	 	// Calcula se moeda for igual a escolhida ou for para converter
		cCondSC6 += "AND ((C5_MOEDA = "+alltrim(str(MV_PAR08))+") OR ("+ALLTRIM(STR(MV_PAR09))+" = 1)) "
		cCondSC6 += "GROUP BY C5_MOEDA,C5_EMISSAO,C6_ENTREG HAVING SUM(C6_PRCVEN*(C6_QTDVEN - C6_QTDENT)) > 0) "+;
		"SELECT SUM(CASE WHEN (DIAS > 0) AND ( DIAS <= 30) THEN 1 ELSE 0 END) AS VAL17_2,"+;
		"SUM(CASE WHEN (DIAS > 0) AND ( DIAS <= 30) THEN dbo.xMoeda(SALDO,C5_MOEDA,"+ALLTRIM(STR(MV_PAR08))+",C5_EMISSAO,"+ALLTRIM(STR(nDecs+1))+",0,0) ELSE 0 END) AS VAL17_1,"+;
		"SUM(CASE WHEN (DIAS > 30) AND ( DIAS <= 60) THEN 1 ELSE 0 END) AS VAL18_2,"+;
		"SUM(CASE WHEN (DIAS > 30) AND ( DIAS <= 60) THEN dbo.xMoeda(SALDO,C5_MOEDA,"+ALLTRIM(STR(MV_PAR08))+",C5_EMISSAO,"+ALLTRIM(STR(nDecs+1))+",0,0) ELSE 0 END) AS VAL18_1,"+;
		"SUM(CASE WHEN (DIAS > 60) AND ( DIAS <= 90) THEN 1 ELSE 0 END) AS VAL19_2,"+;
		"SUM(CASE WHEN (DIAS > 60) AND ( DIAS <= 90) THEN dbo.xMoeda(SALDO,C5_MOEDA,"+ALLTRIM(STR(MV_PAR08))+",C5_EMISSAO,"+ALLTRIM(STR(nDecs+1))+",0,0) ELSE 0 END) AS VAL19_1,"+;
		"SUM(CASE WHEN (DIAS > 90) THEN 1 ELSE 0 END) AS VAL20_2,"+;
		"SUM(CASE WHEN (DIAS > 90) THEN dbo.xMoeda(SALDO,C5_MOEDA,"+ALLTRIM(STR(MV_PAR08))+",C5_EMISSAO,"+ALLTRIM(STR(nDecs+1))+",0,0) ELSE 0 END) AS VAL20_1,"+;
		"SUM(CASE WHEN (DIAS <= 0) THEN 1 ELSE 0 END) AS VAL21_2,"+;
		"SUM(CASE WHEN (DIAS <= 0) THEN dbo.xMoeda(SALDO,C5_MOEDA,"+ALLTRIM(STR(MV_PAR08))+",C5_EMISSAO,"+ALLTRIM(STR(nDecs+1))+",0,0) ELSE 0 END) AS VAL21_1 "+;
		"FROM TMP"
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cCondSC6),cAliasSC6,.T.,.T.)
		aVal[17,2] += (cAliasSC6)->VAL17_2
		aVal[17,1] += (cAliasSC6)->VAL17_1
		aVal[18,2] += (cAliasSC6)->VAL18_2
		aVal[18,1] += (cAliasSC6)->VAL18_1
		aVal[19,2] += (cAliasSC6)->VAL19_2
		aVal[19,1] += (cAliasSC6)->VAL19_1
		aVal[20,2] += (cAliasSC6)->VAL20_2
		aVal[20,1] += (cAliasSC6)->VAL20_1
		aVal[21,2] += (cAliasSC6)->VAL21_2
		aVal[21,1] += (cAliasSC6)->VAL21_1
		dbselectarea(cAliasSC6)
		dbclosearea()
		IncRegua()
		nContRegua++
	Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra APENAS os emitidos antes da database, pois este rela³
//³ torio pode ser retroativo.                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cFiltSql := U_FILTSQL(cFilterUser)

		cAliasTmp := "FINR320"
		cQuery := "WITH TMP AS (SELECT E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_NATUREZ,E1_MOEDA,E1_VALOR,E1_SALDO,"+;
		"E1_TXMOEDA,E1_EMISSAO,E1_VENCREA,E1_VENCTO,E1_BAIXA,E1_VENCORI,E1_CLIENTE,E1_LOJA,	E1_FILIAL,E1_SITUACA "+;
		",DATEDIFF(day,CONVERT(DATETIME,E1_EMISSAO,102),  CONVERT(DATETIME,E1_VENCREA,102)) AS DIAS "+;
		",DATEDIFF(day,CONVERT(DATETIME,'"+dtos(dDataBase)+"',102),  CONVERT(DATETIME,E1_VENCREA,102)) AS DIASDTB, "+;
		"SALDOATU =  "
		
	If MV_PAR07 == 1                            
		if mv_par02 == 1
			cQuery += "CASE WHEN (E1_BAIXA = '') AND (E1_SALDO = 0) AND (E1_BAIXA <= '"+DTOS(dDataBase)+"') THEN 0 ELSE "
		ENDIF     
		
		cAux := "dbo.SaldoTit(E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,'R',E1_CLIENTE,"+ALLTRIM(STR(MV_PAR08))+",E1_MOEDA,'"+dtos(dDataBase)+"','"+dtos(dDataBase)+"',E1_LOJA,"+;
		IIf(cPaisLoc=="BRA","E1_TXMOEDA","0")+",'"+cPaisLoc+"',"+alltrim(str(nTipoData))+", E1_VALOR+E1_SDACRES-E1_SDDECRE,'"+dtos(dDataBase)+"')"
		cQuery += cAux+" - CASE WHEN (E1_DECRESC > 0) AND (E1_SDDECRE = 0) AND (ROUND("+cAux+",2) = ROUND(E1_VALOR,2)) THEN E1_DECRESC ELSE 0 END "
		cQuery += "+ CASE WHEN (E1_ACRESC > 0) AND (E1_SDACRES = 0) AND (ROUND("+cAux+",2) = ROUND(E1_VALOR,2)) THEN E1_ACRESC ELSE 0 END "

		if mv_par02 == 1
			cQuery += " END"
		endif 
		
			
	Else       
		If cPaisLoc == "BRA"
			cQuery += "dbo.xMoeda(E1_SALDO+E1_SDACRES-E1_SDDECRE,E1_MOEDA,"+alltrim(str(MV_PAR08))+",'"+dtos(dDatabase)+"',"+alltrim(str(nDecs+1))+","+If(cPaisLoc=="BRA","E1_TXMOEDA","0")+",0)"
		Else
			cQuery += "dbo.xMoeda(E1_SALDO+E1_SDACRES-E1_SDDECRE,E1_MOEDA,"+alltrim(str(MV_PAR08))+",E1_EMISSAO,"+alltrim(str(nDecs+1))+","+If(cPaisLoc=="BRA","E1_TXMOEDA","0")+",0)"
		EndIf
	Endif
	cQuery += ",VALABAT = "+;
	"CASE WHEN (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG+"|"+MVABATIM,"|","','"),"/","','")+"')) THEN "+;   
	"dbo.SomaAbat(E1_PREFIXO,E1_NUM,E1_PARCELA,'R',1,'"+dtos(dDataBase)+"',E1_CLIENTE,E1_LOJA,E1_FILIAL,'"+If(MV_PAR13==1,dtos(dDataBase+(30*480)),dtos(dDataBase))+"','"+cPaisLoc+"') "+;
	"ELSE 0.0 END

		cQuery +=         ",R_E_C_N_O_ RECNO "
		cQuery += "FROM "+RetSqlName("SE1")+ " SE1 WITH (NOLOCK) "
		cWhere := "WHERE "
		If mv_par01 == 1
			cWhere += "(SE1.E1_FILIAL ='"+xFilial("SE1")+"') AND "
		Endif	
		If MV_PAR13 == 2 //Nao considerar titulos com emissao futura
			cWhere += "(SE1.E1_EMISSAO <= '"+Dtos(dDataBase)+"') AND "
		Endif	
		cWhere += "(SE1.E1_PREFIXO >= '"+MV_PAR04+"') AND "	
		cWhere += "(SE1.E1_PREFIXO <= '"+MV_PAR05+"') AND " 
		If lPrjCni
			cWhere += "(SE1.E1_BAIXA = '') AND "
		EndIf
		If MV_PAR09 == 2 
			cWhere += "(SE1.E1_MOEDA = "+Str(MV_PAR08,2)+") AND "
		Endif	         
		If lPrjCni

			cWhere += "((SE1.E1_FATURA = '      ') OR (SE1.E1_FATURA = 'NOTFAT')) AND "
			cWhere += "(SE1.E1_DTFATUR > '"+Dtos(dDataBase)+"' OR SE1.E1_DTFATUR = '        ') AND "
		EndIf
		If mv_par01 == 1
			cWhere += "(SE1.E1_FILIAL = '" + xFilial("SE1")+"') AND "
		Endif	                         
		if !empty(cTpQry)
			cWhere += "(SE1.E1_TIPO IN (" + cTpQry+")) AND "
		Endif	                         
		cWhere += "(SE1.E1_SALDO >= 0) AND "		         
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Considera filtro do usuario                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if !empty(cFiltSql)
			cWhere += cFiltSql+" AND "		         
		endif 
		
		cWhere += "(SE1.D_E_L_E_T_<> '*') "
		cQuery += cWhere+") "+;
		"SELECT "+; 
		"SUM(CASE WHEN (E1_TIPO IN ("+cAbat+")) AND ("+alltrim(str(MV_PAR10))+" = 1) THEN "+;
		"CASE WHEN (E1_BAIXA > '"+DTOS(dDatabase)+"') THEN dbo.xMoeda(E1_VALOR,E1_MOEDA,"+alltrim(str(MV_PAR08))+",'"+dtos(dDatabase)+"',"+alltrim(str(nDecs+1))+","+If(cPaisLoc=="BRA","E1_TXMOEDA","0")+",0) "+;
		"ELSE dbo.xMoeda(E1_SALDO,E1_MOEDA,"+alltrim(str(MV_PAR08))+",'"+dtos(dDatabase)+"',"+alltrim(str(nDecs+1))+","+If(cPaisLoc=="BRA","E1_TXMOEDA","0")+",0) END "+;
		"ELSE 0.0 END) AS VAL351,"+;
		"SUM(CASE WHEN (E1_TIPO IN ("+cAbat+")) AND ("+alltrim(str(MV_PAR10))+" = 1) THEN "+;
		"CASE WHEN (E1_BAIXA > '"+DTOS(dDatabase)+"') THEN case when dbo.xMoeda(E1_VALOR,E1_MOEDA,"+alltrim(str(MV_PAR08))+",'"+dtos(dDatabase)+"',"+alltrim(str(nDecs+1))+","+If(cPaisLoc=="BRA","E1_TXMOEDA","0")+",0) > 0 then 1 else 0 end "+;
		"ELSE case when dbo.xMoeda(E1_SALDO,E1_MOEDA,"+alltrim(str(MV_PAR08))+",'"+dtos(dDatabase)+"',"+alltrim(str(nDecs+1))+","+If(cPaisLoc=="BRA","E1_TXMOEDA","0")+",0) > 0 then 1 else 0 end END "+;
		"ELSE 0.0 END) AS VAL352,"+;
		"SUM(CASE WHEN (E1_TIPO IN ("+cProvis+")) THEN "+;
		"dbo.xMoeda(E1_SALDO,E1_MOEDA,"+alltrim(str(MV_PAR08))+",'"+dtos(dDatabase)+"',"+alltrim(str(nDecs+1))+","+If(cPaisLoc=="BRA","E1_TXMOEDA","0")+",0) "+;
		"ELSE 0.0 END) AS VAL1611,"+;
		"SUM(CASE WHEN (E1_TIPO IN ("+cProvis+")) AND (E1_SALDO > 0) THEN "+;
		"1 ELSE 0 END ) AS VAL1621, "+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND (SUBSTRING(E1_EMISSAO,1,6) = '"+substr(dtos(dDatabase),1,6)+"') AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+;
		"AND (DIAS <= 1) THEN dbo.xMoeda(E1_VALOR,E1_MOEDA,"+alltrim(str(MV_PAR08))+",'"+dtos(dDatabase)+"',"+alltrim(str(nDecs+1))+","+If(cPaisLoc=="BRA","E1_TXMOEDA","0")+",0) "+;
		"ELSE 0 END) AS VAL011,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND (SUBSTRING(E1_EMISSAO,1,6) = '"+substr(dtos(dDatabase),1,6)+"') AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+;
		"AND (DIAS <= 1) THEN 1 "+;
		"ELSE 0 END) AS VAL012,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND (SUBSTRING(E1_EMISSAO,1,6) = '"+substr(dtos(dDatabase),1,6)+"') AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+;
		"AND (DIAS > 1) THEN dbo.xMoeda(E1_VALOR,E1_MOEDA,"+alltrim(str(MV_PAR08))+",'"+dtos(dDatabase)+"',"+alltrim(str(nDecs+1))+","+If(cPaisLoc=="BRA","E1_TXMOEDA","0")+",0) "+;
		"ELSE 0 END) AS VAL021,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND (SUBSTRING(E1_EMISSAO,1,6) = '"+substr(dtos(dDatabase),1,6)+"') AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+;
		"AND (DIAS > 1) THEN 1 "+;
		"ELSE 0 END) AS VAL022,"
		cAux := "round(dbo.NoRound(SALDOATU - CASE WHEN (SALDOATU > 0) "+IIF(MV_PAR10 == 1,"","AND (ROUND(SALDOATU,2) = ROUND(VALABAT,2)) ")+"THEN VALABAT ELSE 0 END,3),2) "
		cQuery += ""+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND ((DIASDTB < 0) OR ((DIASDTB > 0) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')))) "+;
		"THEN "+cAux+" ELSE 0 END) AS VAL341,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (DIASDTB < 0) AND (ABS(DIASDTB) BETWEEN 0 AND 15) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+;
		"THEN "+cAux+" ELSE 0 END) AS VAL381,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (DIASDTB < 0) AND (ABS(DIASDTB) BETWEEN 0 AND 15) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+;
		"THEN 1 ELSE 0 END) AS VAL382,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (DIASDTB < 0) AND (ABS(DIASDTB) BETWEEN 16 AND 30) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+;
		"THEN "+cAux+" ELSE 0 END) AS VAL031,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (DIASDTB < 0) AND (ABS(DIASDTB) BETWEEN 16 AND 30) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+;
		"THEN 1 ELSE 0 END) AS VAL032,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (DIASDTB < 0) AND (ABS(DIASDTB) BETWEEN 31 AND 60) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+;
		"THEN "+cAux+" ELSE 0 END) AS VAL041,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (DIASDTB < 0) AND (ABS(DIASDTB) BETWEEN 31 AND 60) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+;
		"THEN 1 ELSE 0 END) AS VAL042,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (DIASDTB < 0) AND (ABS(DIASDTB) BETWEEN 61 AND 90) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+;
		"THEN "+cAux+" ELSE 0 END) AS VAL051,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (DIASDTB < 0) AND (ABS(DIASDTB) BETWEEN 61 AND 90) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+;
		"THEN 1 ELSE 0 END) AS VAL052,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (DIASDTB < 0) AND (ABS(DIASDTB) > 90) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+;
		"THEN "+cAux+" ELSE 0 END) AS VAL061,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (DIASDTB < 0) AND (ABS(DIASDTB) > 90) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+;
		"THEN 1 ELSE 0 END) AS VAL062,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (DIASDTB >= 0) AND (ABS(DIASDTB) BETWEEN 0 AND 15) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+;
		"THEN "+cAux+" ELSE 0 END) AS VAL391,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (DIASDTB >= 0) AND (ABS(DIASDTB) BETWEEN 0 AND 15) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+;
		"THEN 1 ELSE 0 END) AS VAL392,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (DIASDTB >= 0) AND (ABS(DIASDTB) BETWEEN 16 AND 30) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+;
		"THEN "+cAux+" ELSE 0 END) AS VAL071,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (DIASDTB >= 0) AND (ABS(DIASDTB) BETWEEN 16 AND 30) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+;
		"THEN 1 ELSE 0 END) AS VAL072,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (DIASDTB >= 0) AND (ABS(DIASDTB) BETWEEN 31 AND 60) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+;
		"THEN "+cAux+" ELSE 0 END) AS VAL081,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (DIASDTB >= 0) AND (ABS(DIASDTB) BETWEEN 31 AND 60) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+;
		"THEN 1 ELSE 0 END) AS VAL082,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (DIASDTB >= 0) AND (ABS(DIASDTB) BETWEEN 61 AND 90) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+;
		"THEN "+cAux+" ELSE 0 END) AS VAL091,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (DIASDTB >= 0) AND (ABS(DIASDTB) BETWEEN 61 AND 90) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+;
		"THEN 1 ELSE 0 END) AS VAL092,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (DIASDTB >= 0) AND (ABS(DIASDTB) > 90) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+;
		"THEN "+cAux+" ELSE 0 END) AS VAL101,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (DIASDTB >= 0) AND (ABS(DIASDTB) > 90) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+;
		"THEN 1 ELSE 0 END) AS VAL102,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+; 
		"AND ((E1_SITUACA = '') OR (E1_SITUACA IN ('0','F','G'))) "+;
		"THEN "+cAux+" ELSE 0 END) AS VAL251,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+;
		"AND ((E1_SITUACA = '') OR (E1_SITUACA IN ('0','F','G'))) "+;
		"THEN 1 ELSE 0 END) AS VAL252,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+; 
		"AND (E1_SITUACA IN ('1','H')) "+;
		"THEN "+cAux+" ELSE 0 END) AS VAL261,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+;
		"AND (E1_SITUACA IN ('1','H')) "+;
		"THEN 1 ELSE 0 END) AS VAL262,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+; 
		"AND (E1_SITUACA = '2') "+;
		"THEN "+cAux+" ELSE 0 END) AS VAL271,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+;
		"AND (E1_SITUACA = '2') "+;
		"THEN 1 ELSE 0 END) AS VAL272,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+; 
		"AND (E1_SITUACA = '3') "+;
		"THEN "+cAux+" ELSE 0 END) AS VAL281,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+;
		"AND (E1_SITUACA = '3') "+;
		"THEN 1 ELSE 0 END) AS VAL282,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+; 
		"AND (E1_SITUACA = '4') "+;
		"THEN "+cAux+" ELSE 0 END) AS VAL291,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+;
		"AND (E1_SITUACA = '4') "+;
		"THEN 1 ELSE 0 END) AS VAL292,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+; 
		"AND (E1_SITUACA = '5') "+;
		"THEN "+cAux+" ELSE 0 END) AS VAL301,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+;
		"AND (E1_SITUACA = '5') "+;
		"THEN 1 ELSE 0 END) AS VAL302,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+; 
		"AND (E1_SITUACA = '6') "+;
		"THEN "+cAux+" ELSE 0 END) AS VAL311,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+;
		"AND (E1_SITUACA = '6') "+;
		"THEN 1 ELSE 0 END) AS VAL312,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+; 
		"AND (E1_SITUACA = '7') "+;
		"THEN "+cAux+" ELSE 0 END) AS VAL371,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) AND (E1_TIPO NOT IN ('"+strtran(strtran(MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"')) "+;
		"AND (E1_SITUACA = '7') "+;
		"THEN 1 ELSE 0 END) AS VAL372,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) "+IIF(MV_PAR13 == 1,"","AND (E1_EMISSAO <= '"+dtos(dDataBase)+"') ")+;
		"AND (E1_TIPO IN ('"+strtran(strtran(MVDUPLIC,"|","','"),"/","','")+"')) "+; 
		"THEN "+cAux+" ELSE 0 END) AS VAL111,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) "+IIF(MV_PAR13 == 1,"","AND (E1_EMISSAO <= '"+dtos(dDataBase)+"') ")+;
		"AND (E1_TIPO IN ('"+strtran(strtran(MVDUPLIC,"|","','"),"/","','")+"')) "+; 
		"THEN 1 ELSE 0 END) AS VAL112,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) "+IIF(MV_PAR13 == 1,"","AND (E1_EMISSAO <= '"+dtos(dDataBase)+"') ")+;
		"AND (E1_TIPO IN ('"+strtran(strtran(MVNOTAFIS,"|","','"),"/","','")+"')) "+; 
		"THEN "+cAux+" ELSE 0 END) AS VAL121,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) "+IIF(MV_PAR13 == 1,"","AND (E1_EMISSAO <= '"+dtos(dDataBase)+"') ")+;
		"AND (E1_TIPO IN ('"+strtran(strtran(MVNOTAFIS,"|","','"),"/","','")+"')) "+; 
		"THEN 1 ELSE 0 END) AS VAL122,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) "+IIF(MV_PAR13 == 1,"","AND (E1_EMISSAO <= '"+dtos(dDataBase)+"') ")+;
		"AND (E1_TIPO IN ('"+strtran(strtran(MVCHEQUES,"|","','"),"/","','")+"')) "+; 
		"THEN "+cAux+" ELSE 0 END) AS VAL131,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) "+IIF(MV_PAR13 == 1,"","AND (E1_EMISSAO <= '"+dtos(dDataBase)+"') ")+;
		"AND (E1_TIPO IN ('"+strtran(strtran(MVCHEQUES,"|","','"),"/","','")+"')) "+; 
		"THEN 1 ELSE 0 END) AS VAL132,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) "+IIF(MV_PAR13 == 1,"","AND (E1_EMISSAO <= '"+dtos(dDataBase)+"') ")+;
		"AND (E1_TIPO = 'CN') "+; 
		"THEN "+cAux+" ELSE 0 END) AS VAL141,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) "+IIF(MV_PAR13 == 1,"","AND (E1_EMISSAO <= '"+dtos(dDataBase)+"') ")+;
		"AND (E1_TIPO = 'CN') "+; 
		"THEN 1 ELSE 0 END) AS VAL142,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) "+IIF(MV_PAR13 == 1,"","AND (E1_EMISSAO <= '"+dtos(dDataBase)+"') ")+;
		"AND (E1_TIPO IN ('"+strtran(strtran(MVTAXA,"|","','"),"/","','")+"')) "+; 
		"THEN "+cAux+" ELSE 0 END) AS VAL151,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) "+IIF(MV_PAR13 == 1,"","AND (E1_EMISSAO <= '"+dtos(dDataBase)+"') ")+;
		"AND (E1_TIPO IN ('"+strtran(strtran(MVTAXA,"|","','"),"/","','")+"')) "+; 
		"THEN 1 ELSE 0 END) AS VAL152,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) "+IIF(MV_PAR13 == 1,"","AND (E1_EMISSAO <= '"+dtos(dDataBase)+"') ")+;
		"AND (E1_TIPO IN ('"+strtran(strtran(MVRECANT,"|","','"),"/","','")+"')) "+; 
		"THEN "+cAux+" ELSE 0 END) AS VAL241,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) "+IIF(MV_PAR13 == 1,"","AND (E1_EMISSAO <= '"+dtos(dDataBase)+"') ")+;
		"AND (E1_TIPO IN ('"+strtran(strtran(MVRECANT,"|","','"),"/","','")+"')) "+; 
		"THEN 1 ELSE 0 END) AS VAL242,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+"',"+strtran(strtran(MVDUPLIC+"|"+MVNOTAFIS+"|"+MVCHEQUES+"|"+MVTAXA+"|"+MVRECANT,"|","','"),"/","','")+"','CN')) AND ("+cAux+" > 0) "+IIF(MV_PAR13 == 1,"","AND (E1_EMISSAO <= '"+dtos(dDataBase)+"') ")+;
		"AND (E1_TIPO IN ('"+strtran(strtran(MV_CRNEG,"|","','"),"/","','")+"')) "+; 
		"THEN "+cAux+" ELSE 0 END) AS VAL361,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+"',"+strtran(strtran(MVDUPLIC+"|"+MVNOTAFIS+"|"+MVCHEQUES+"|"+MVTAXA+"|"+MVRECANT,"|","','"),"/","','")+"','CN')) AND ("+cAux+" > 0) "+IIF(MV_PAR13 == 1,"","AND (E1_EMISSAO <= '"+dtos(dDataBase)+"') ")+;
		"AND (E1_TIPO IN ('"+strtran(strtran(MV_CRNEG,"|","','"),"/","','")+"')) "+; 
		"THEN 1 ELSE 0 END) AS VAL362,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) "+IIF(MV_PAR13 == 1,"","AND (E1_EMISSAO <= '"+dtos(dDataBase)+"') ")+;
		"AND (E1_TIPO NOT IN ('"+strtran(strtran(MVDUPLIC+"|"+MVNOTAFIS+"|"+MVCHEQUES+"|"+MVTAXA+"|"+MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"','CN')) "+; 
		"THEN "+cAux+" ELSE 0 END) AS VAL1612,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) "+IIF(MV_PAR13 == 1,"","AND (E1_EMISSAO <= '"+dtos(dDataBase)+"') ")+;
		"AND (E1_TIPO NOT IN ('"+strtran(strtran(MVDUPLIC+"|"+MVNOTAFIS+"|"+MVCHEQUES+"|"+MVTAXA+"|"+MVRECANT+"|"+MV_CRNEG,"|","','"),"/","','")+"','CN')) "+; 
		"THEN 1 ELSE 0 END) AS VAL1622,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) "+;
		"THEN DIAS ELSE 0 END) AS VAL221,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) "+;
		"THEN 1 ELSE 0 END) AS VAL222,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) "+;
		"THEN DIAS*dbo.xMoeda("+cAux+",E1_MOEDA,"+ALLTRIM(STR(MV_PAR08))+",E1_EMISSAO,"+ALLTRIM(STR(nDecs+1))+","+If(cPaisLoc=="BRA","E1_TXMOEDA","0")+",0) ELSE 0 END) AS VAL231,"+;
		"SUM(CASE WHEN (E1_TIPO NOT IN ("+cProvis+","+cAbat+")) AND ("+cAux+" > 0) "+;
		"THEN dbo.xMoeda("+cAux+",E1_MOEDA,"+ALLTRIM(STR(MV_PAR08))+",E1_EMISSAO,"+ALLTRIM(STR(nDecs+1))+","+If(cPaisLoc=="BRA","E1_TXMOEDA","0")+",0) ELSE 0 END) AS VAL232 "+;
		"FROM TMP"

		cAux := strtran(cQuery,"'","''")
		TCQUERY "SELECT CONVERT(varchar,getdate(),121) AS CNOME" ALIAS "TMPTAB" NEW
		cId := "TMP"+STRTRAN(STRTRAN(STRTRAN(TMPTAB->CNOME,":",""),"-","")," ","")  
		cId := strtran(cId,".","")
		dbclosearea()
		TCSQLEXEC("INSERT INTO TMPCONSULTAS (ID, QUERY) VALUES ('"+cId+"','"+cAux+"')")
		
		cAux := "EXEC BIGQUERY '"+cId+"'

	
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cAux),cAliasTmp,.T.,.T.)	

for i := nContRegua+1 to 9
	IncRegua()
	nContRegua++      
next 

dbSelectArea(cAliasTmp)
dbgotop()
aVal[35,1] += (cAliasTmp)->VAL351
aVal[35,2] += (cAliasTmp)->VAL352
aVal[16,1] += (cAliasTmp)->VAL1611
aVal[16,2] += (cAliasTmp)->VAL1621
	
aVal[1,1] += (cAliasTmp)->VAL011
aVal[1,2] += (cAliasTmp)->VAL012
aVal[2,1] += (cAliasTmp)->VAL021
aVal[2,2] += (cAliasTmp)->VAL022
	
aVal[34,1] += (cAliasTmp)->VAL341

					aVal[38,1] += (cAliasTmp)->VAL381
					aVal[38,2] += (cAliasTmp)->VAL382
					aVal[3,1] += (cAliasTmp)->VAL031
					aVal[3,2] += (cAliasTmp)->VAL032
					aVal[4,1] += (cAliasTmp)->VAL041
					aVal[4,2] += (cAliasTmp)->VAL042           
					aVal[5,1] += (cAliasTmp)->VAL051
					aVal[5,2] += (cAliasTmp)->VAL052
					aVal[6,1] += (cAliasTmp)->VAL061
					aVal[6,2] += (cAliasTmp)->VAL062
    	   	  		aVal[39,1] += (cAliasTmp)->VAL391
    		   		aVal[39,2] += (cAliasTmp)->VAL392
    	        	aVal[7,1] += (cAliasTmp)->VAL071
        	    	aVal[7,2] += (cAliasTmp)->VAL072
    	       		aVal[8,1] += (cAliasTmp)->VAL081
        	    	aVal[8,2] += (cAliasTmp)->VAL082
    	       		aVal[9,1] += (cAliasTmp)->VAL091
        	    	aVal[9,2] += (cAliasTmp)->VAL092
    	       		aVal[10,1] += (cAliasTmp)->VAL101
        	    	aVal[10,2] += (cAliasTmp)->VAL102
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula a distribuicao de cobranca / item 4  analise         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aVal[25,1] += (cAliasTmp)->VAL251
					aVal[25,2] += (cAliasTmp)->VAL252
					aVal[26,1] += (cAliasTmp)->VAL261
					aVal[26,2] += (cAliasTmp)->VAL262
					aVal[27,1] += (cAliasTmp)->VAL271
					aVal[27,2] += (cAliasTmp)->VAL272
					aVal[28,1] += (cAliasTmp)->VAL281
					aVal[28,2] += (cAliasTmp)->VAL282
					aVal[29,1] += (cAliasTmp)->VAL291
					aVal[29,2] += (cAliasTmp)->VAL292
					aVal[30,1] += (cAliasTmp)->VAL301
					aVal[30,2] += (cAliasTmp)->VAL302
					aVal[31,1] += (cAliasTmp)->VAL311
					aVal[31,2] += (cAliasTmp)->VAL312
					aVal[37,1] += (cAliasTmp)->VAL371
					aVal[37,2] += (cAliasTmp)->VAL372
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula a distribuicao por tipo de titulo / item 5 analise   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aVal[11,1] += (cAliasTmp)->VAL111
	            aVal[11,2] += (cAliasTmp)->VAL112
				aVal[12,1] += (cAliasTmp)->VAL121
				aVal[12,2] += (cAliasTmp)->VAL122
				aVal[13,1] += (cAliasTmp)->VAL131
				aVal[13,2] += (cAliasTmp)->VAL132
				aVal[14,1] += (cAliasTmp)->VAL141
				aVal[14,2] += (cAliasTmp)->VAL142
				aVal[15,1] += (cAliasTmp)->VAL151
				aVal[15,2] += (cAliasTmp)->VAL152
				aVal[24,1] += (cAliasTmp)->VAL241
				aVal[24,2] += (cAliasTmp)->VAL242
				aVal[36,1] += (cAliasTmp)->VAL361
				aVal[36,2] += (cAliasTmp)->VAL362
				aVal[16,1]  += (cAliasTmp)->VAL1612
				aVal[16,2]  += (cAliasTmp)->VAL1622
    
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula o P.M.A e P.M.P - indices / item 7 da analise        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aVal[22,1] += (cAliasTmp)->VAL221
		aVal[22,2] += (cAliasTmp)->VAL222
		aVal[23,1] += (cAliasTmp)->VAL231
		aVal[23,2] +=  (cAliasTmp)->VAL232

dbSelectArea(cAliasTmp)
dbCloseArea()
IncRegua()
dbSelectArea("SE1")

IF li > 58
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
Endif

@Li ,  0 PSAY OemToAnsi(STR0010)  //"FATURAMENTO (no mes)"
@Li , 40 PSAY aVal[1,1]+aVal[2,1]    PICTURE TM(aVal[1,1]+aVal[2,1],18, nDecs)
@Li , 72 PSAY aVal[1,2]+aVal[2,2]    PICTURE "999999"
Li++
@Li ,  0 PSAY OemToAnsi(STR0011)  //"A Vista"
@Li , 40 PSAY aVal[1,1]	     	 PICTURE TM(aVal[1,1],18,nDecs)
@Li , 72 PSAY aVal[1,2]   	      PICTURE "999999"
Li++
@Li ,  0 PSAY OemToAnsi(STR0012)  //"A Prazo"
@Li , 40 PSAY aVal[2,1]	     	 PICTURE TM(aVal[2,1],18,nDecs)
@Li , 72 PSAY aVal[2,2]   	      PICTURE "999999"
Li++
@Li ,  0 PSAY REPLICATE("-",80) 
li++
nOriginal := nRecebido-(nValJuros+nMulta+nCorrecao-nDesconto)
@li,   0 PSAY OemToAnsi(STR0051)  //"VALORES BAIXADOS"
li++
@li,   0 PSAY OemToAnsi(STR0013)  //"Recebido"
@li,  40 PSAY nRecebido			Picture PesqPict("SE5","E5_VALOR",18,MV_PAR08)
li++
@li,   0 PSAY OemToAnsi(STR0014)  //"Taxa Permanencia"
@li,  40 PSAY nValJuros            Picture PesqPict("SE5","E5_VALOR",18,MV_PAR08)
li++
@li,   0 PSAY OemToAnsi(STR0015)  //"Multa"
@li,  40 PSAY nMulta           Picture PesqPict("SE5","E5_VALOR",18,MV_PAR08)
li++
@li,   0 PSAY OemToAnsi(STR0016)  //"Correcao"
@li,  40 PSAY nCorrecao        Picture PesqPict("SE5","E5_VALOR",18,MV_PAR08)
li++
@li,   0 PSAY OemToAnsi(STR0017)  //"Descontos"
@li,  40 PSAY nDesconto			Picture PesqPict("SE5","E5_VALOR",18,MV_PAR08)
li++
@li,   0 PSAY OemToAnsi(STR0018)  //"Original"
@li,  40 PSAY nOriginal        Picture PesqPict("SE5","E5_VALOR",18,MV_PAR08)
li++
@Li ,  0 PSAY REPLICATE("-",80) 
li++
@Li ,  0 PSAY OemToAnsi(STR0019)  //"TITULOS A VENCER"
@Li , 40 PSAY (aVal[39,1]+aVal[7,1]+aVal[8,1]+aVal[9,1]+aVal[10,1])             PICTURE PesqPict("SE5","E5_VALOR",18,MV_PAR08)
@Li , 72 PSAY aVal[39,2]+aVal[7,2]+aVal[8,2]+aVal[9,2]+aVal[10,2]               PICTURE "999999"
Li++
@Li ,  0 PSAY OemToAnsi(STR0052)  //"Ate 15 Dias"
@Li , 40 PSAY aVal[39,1]   PICTURE PesqPict("SE5","E5_VALOR",18,MV_PAR08)
@Li , 72 PSAY aVal[39,2]   PICTURE "999999"
Li++
@Li ,  0 PSAY OemToAnsi(STR0053)  //"De 16 a 30 Dias"
@Li , 40 PSAY aVal[7,1]    PICTURE PesqPict("SE5","E5_VALOR",18,MV_PAR08)
@Li , 72 PSAY aVal[7,2]    PICTURE "999999"
Li++
@Li ,  0 PSAY OemToAnsi(STR0023)  //"De 31 a 60 dias"
@Li , 40 PSAY aVal[8,1]    PICTURE PesqPict("SE5","E5_VALOR",18,MV_PAR08)
@Li , 72 PSAY aVal[8,2]    PICTURE "999999"
Li++
@Li ,  0 PSAY OemToAnsi(STR0024)  //"De 61 a 90 dias"
@Li , 40 PSAY aVal[9,1]    PICTURE PesqPict("SE5","E5_VALOR",18,MV_PAR08)
@Li , 72 PSAY aVal[9,2]    PICTURE "999999"
Li++
@Li ,  0 PSAY OemToAnsi(STR0025)  //"Acima de 90 Dias"
@Li , 40 PSAY aVal[10,1]   PICTURE PesqPict("SE5","E5_VALOR",18,MV_PAR08)
@Li , 72 PSAY aVal[10,2]   PICTURE "999999"
Li++
@Li ,  0 PSAY REPLICATE("-",80) 
Li++
@Li ,  0 PSAY OemToAnsi(STR0026)  //"TITULOS VENCIDOS"
@Li , 40 PSAY (aVal[38,1]+aVal[3,1]+aVal[4,1]+aVal[5,1]+aVal[6,1])    PICTURE PesqPict("SE5","E5_VALOR",18,MV_PAR08)
@Li , 72 PSAY aVal[38,2]+aVal[3,2]+aVal[4,2]+aVal[5,2]+aVal[6,2]    PICTURE "999999"
Li++
@Li ,  0 PSAY OemToAnsi(STR0052)  //"Ate 15 Dias"
@Li , 40 PSAY aVal[38,1]	PICTURE PesqPict("SE5","E5_VALOR",18,MV_PAR08)
@Li , 72 PSAY aVal[38,2]	PICTURE "999999"
Li++
@Li ,  0 PSAY OemToAnsi(STR0053)  //"De 16 a 30 Dias"
@Li , 40 PSAY aVal[3,1]	   PICTURE PesqPict("SE5","E5_VALOR",18,MV_PAR08)
@Li , 72 PSAY aVal[3,2]		PICTURE "999999"
Li++
@Li ,  0 PSAY OemToAnsi(STR0023)  //"De 31 a 60 dias"
@Li , 40 PSAY aVal[4,1]	   PICTURE PesqPict("SE5","E5_VALOR",18,MV_PAR08)
@Li , 72 PSAY aVal[4,2]   	PICTURE "999999"
Li++
@Li ,  0 PSAY OemToAnsi(STR0024)  //"De 61 a 90 dias"
@Li , 40 PSAY aVal[5,1]	   PICTURE PesqPict("SE5","E5_VALOR",18,MV_PAR08)
@Li , 72 PSAY aVal[5,2]		PICTURE "999999"
Li++
@Li ,  0 PSAY OemToAnsi(STR0025)  //"Acima de 90 Dias"
@Li , 40 PSAY aVal[6,1]		PICTURE PesqPict("SE5","E5_VALOR",18,MV_PAR08)
@Li , 72 PSAY aVal[6,2]		PICTURE "999999"
Li++
@Li ,  0 PSAY REPLICATE("-",80) 
li++
@Li ,  0 PSAY OemToAnsi(STR0020)   //"Recebimento Antecipado"
@Li , 40 PSAY aVal[24,1]   PICTURE PesqPict("SE5","E5_VALOR",18,MV_PAR08)
@Li , 72 PSAY aVal[24,2]   PICTURE "999999"
Li++
@Li ,  0 PSAY OemToAnsi(STR0021)  //"Notas de Credito"
@Li , 40 PSAY aVal[36,1]   PICTURE PesqPict("SE5","E5_VALOR",18,MV_PAR08)
@Li , 72 PSAY aVal[36,2]   PICTURE "999999"
Li++
@Li ,  0 PSAY REPLICATE("-",80) 
li++
@Li ,  0 PSAY OemToAnsi(STR0027)  //"DISTRIBUICAO DA COBRANCA"
Li++

@Li ,  0 PSAY aSitua[1]
@Li , 40 PSAY aVal[25,1]	PICTURE PesqPict("SE5","E5_VALOR",18,MV_PAR08)
@Li , 72 PSAY aVal[25,2]	PICTURE "999999"
Li++
@Li ,  0 PSAY aSitua[2]
@Li , 40 PSAY aVal[26,1]  	PICTURE PesqPict("SE5","E5_VALOR",18,MV_PAR08)
@Li , 72 PSAY aVal[26,2]	PICTURE "999999"
Li++
@Li ,  0 PSAY aSitua[3]
@Li , 40 PSAY aVal[27,1]  	PICTURE PesqPict("SE5","E5_VALOR",18,MV_PAR08)
@Li , 72 PSAY aVal[27,2]	PICTURE "999999"
Li++
@Li ,  0 PSAY aSitua[4]
@Li , 40 PSAY aVal[28,1]	PICTURE PesqPict("SE5","E5_VALOR",18,MV_PAR08)
@Li , 72 PSAY aVal[28,2]	PICTURE "999999"
Li++
@Li ,  0 PSAY aSitua[5]
@Li , 40 PSAY aVal[29,1]  	PICTURE PesqPict("SE5","E5_VALOR",18,MV_PAR08)
@Li , 72 PSAY aVal[29,2]	PICTURE "999999"
Li++
@Li ,  0 PSAY aSitua[6]
@Li , 40 PSAY aVal[30,1]	PICTURE PesqPict("SE5","E5_VALOR",18,MV_PAR08)
@Li , 72 PSAY aVal[30,2]	PICTURE "999999"
Li++
@Li ,  0 PSAY aSitua[7]
@Li , 40 PSAY aVal[31,1]	PICTURE PesqPict("SE5","E5_VALOR",18,MV_PAR08)
@Li , 72 PSAY aVal[31,2]	PICTURE "999999"
Li++
@Li ,  0 PSAY aSitua[8]
@Li , 40 PSAY aVal[37,1]	PICTURE PesqPict("SE5","E5_VALOR",18,MV_PAR08)
@Li , 72 PSAY aVal[37,2]	PICTURE "999999"
Li++

@Li ,  0 PSAY REPLICATE("-",80) 
Li++
@Li ,  0 PSAY OemToAnsi(STR0036)  //"POR TIPO DE TITULO"
Li++
@Li ,  0 PSAY OemToAnsi(STR0037)  //"Duplicatas"
@Li , 40 PSAY aVal[11,1]	PICTURE PesqPict("SE5","E5_VALOR",18,MV_PAR08)
@Li , 72 PSAY aVal[11,2]	PICTURE "999999"
Li++
@Li ,  0 PSAY OemToAnsi(STR0038)  //"Notas Fiscais"
@Li , 40 PSAY aVal[12,1]	PICTURE PesqPict("SE5","E5_VALOR",18,MV_PAR08)
@Li , 72 PSAY aVal[12,2]	PICTURE "999999"
Li++
@Li ,  0 PSAY OemToAnsi(STR0039)  //"Cheques Pre-Datados"
@Li , 40 PSAY aVal[13,1]	PICTURE PesqPict("SE5","E5_VALOR",18,MV_PAR08)
@Li , 72 PSAY aVal[13,2]	PICTURE "999999"
Li++
@Li ,  0 PSAY OemToAnsi(STR0040)  //"Carne De Pagamento"
@Li , 40 PSAY aVal[14,1]	PICTURE PesqPict("SE5","E5_VALOR",18,MV_PAR08)
@Li , 72 PSAY aVal[14,2]	PICTURE "999999"
Li++
@Li ,  0 PSAY OemToAnsi(STR0041)  //"Impostos"
@Li , 40 PSAY aVal[15,1]	PICTURE PesqPict("SE5","E5_VALOR",18,MV_PAR08)
@Li , 72 PSAY aVal[15,2]			      PICTURE "999999"
Li++
@Li ,  0 PSAY OemToAnsi(STR0042)  //"Abatimentos"
@Li , 40 PSAY aVal[35,1]        			PICTURE PesqPict("SE5","E5_VALOR",18,MV_PAR08)
@Li , 72 PSAY aVal[35,2]        			PICTURE "999999"
Li++
@Li ,  0 PSAY OemToAnsi(STR0043)  //"Outros"
@Li , 40 PSAY aVal[16,1]				  	PICTURE PesqPict("SE5","E5_VALOR",18,MV_PAR08)
@Li , 72 PSAY aVal[16,2]					PICTURE "999999"
Li++
@Li ,  0 PSAY REPLICATE("-",80) 
Li++
@Li ,  0 PSAY OemToAnsi(STR0044)  //"CARTEIRA DE PEDIDOS A ENTREGAR"
@Li , 43 PSAY aVal[17,1]+aVal[18,1]+aVal[19,1]+aVal[20,1]+aVal[21,1]  Picture PesqPict("SC6","C6_VALOR",16,MV_PAR08)
@Li , 72 PSAY aVal[17,2]+aVal[18,2]+aVal[19,2]+aVal[20,2]+aVal[21,2]  Picture "999999"
Li++
@Li ,  0 PSAY OemToAnsi(STR0045)  //"Itens de Pedidos Vencidos"
@Li , 43 PSAY aVal[21,1]             PICTURE  PesqPict("SC6","C6_VALOR",16,MV_PAR08)
@Li , 72 PSAY aVal[21,2]             PICTURE  "999999"
Li++
@Li ,  0 PSAY OemToAnsi(STR0022)  //"Ate 30 Dias"
@Li , 43 PSAY aVal[17,1]             PICTURE PesqPict("SC6","C6_VALOR",16,MV_PAR08)
@Li , 72 PSAY aVal[17,2]             PICTURE "999999"
Li++
@Li ,  0 PSAY OemToAnsi(STR0023)  //"De 31 a 60 Dias"
@Li , 43 PSAY aVal[18,1]             PICTURE PesqPict("SC6","C6_VALOR",16,MV_PAR08)
@Li , 72 PSAY aVal[18,2]             PICTURE "999999"
Li++
@Li ,  0 PSAY OemToAnsi(STR0024)  //"De 61 a 90 Dias"
@Li , 43 PSAY aVal[19,1]             PICTURE PesqPict("SC6","C6_VALOR",16,MV_PAR08)
@Li , 72 PSAY aVal[19,2]             PICTURE "999999"
Li++
@Li ,  0 PSAY OemToAnsi(STR0025)  //"Acima De 90 Dias"
@Li , 43 PSAY aVal[20,1]             PICTURE PesqPict("SC6","C6_VALOR",16,MV_PAR08)
@Li , 72 PSAY aVal[20,2]             PICTURE "999999"
Li++
@Li ,  0 PSAY REPLICATE("-",80) 
Li++
@Li ,  0 PSAY OemToAnsi(STR0047)  //"Prazo Medio Absoluto"
@Li , 72 PSAY (aVal[22,1]/aVal[22,2])   	      PICTURE "999.99"
Li++
@Li ,  0 PSAY OemToAnsi(STR0048)  //"Prazo Medio Ponderado"
@Li , 72 PSAY (aVal[23,1]/aVal[23,2])   	      PICTURE "999.99"
Li++
@Li ,  0 PSAY OemToAnsi(STR0049)  //"Quociente De Atraso"
@Li , 72 PSAY  (((aVal[38,1]+aVal[3,1]+aVal[4,1]+aVal[5,1]+aVal[6,1])/aVal[34,1]))*100 PICTURE "999.99"
Li++

Set Device To Screen
dbSelectArea("SE1")
dbSetOrder(1)
Set Filter to
dbSelectArea("SE5")
dbSetOrder(1)
Set Filter to

If aReturn[5] = 1
    Set Printer TO
    dbCommitAll()
    Ourspool(wnrel)
Endif
MS_FLUSH()

dDataBase := dOldDtBase // Restaura Data base

Return

Static Function InSide(cTp)
Return (cTp$cTipos)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Fa320Saldo³ Autor ³ Alessandro Freire     ³ Data ³ 16.01.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o saldo do item do pedido                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Fa320Saldo()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fa320Saldo()
LOCAL nRetSaldo := 0

If (C6_QTDVEN-C6_QTDENT) > 0 .And. C6_BLQ != "R"
	If !Empty( SC6->C6_TES )
		dbSelectArea("SF4")
 		dbSetOrder(1)
		dbSeek( xFilial("SF4")+SC6->C6_TES )
		nRetSaldo := SC6->C6_PRCVEN * (SC6->C6_QTDVEN - SC6->C6_QTDENT)
		If MV_PAR06 == 1		// Verifica se ir  considerar o TES (F4_DUPLIC)
			nRetSaldo := 0
			If SF4->F4_DUPLIC == "S"
				nRetSaldo := SC6->C6_PRCVEN * (SC6->C6_QTDVEN - SC6->C6_QTDENT)
			Endif
		EndIf
	EndIf
EndIf
dbSelectArea("SC6")
Return(nRetSaldo)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PutDtBase³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 18/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Acerta parametro database do relatorio                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Finr320.prx                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//LGS#20200130 - Adequação para release 12.1.25 e posteriores
/*
Static Function PutDtBase()
Local _sAlias	:= Alias()

dbSelectArea("SX1")
dbSetOrder(1)
If MsSeek( Padr( "FIN320" , Len( X1_GRUPO ) , ' ' ) + "13")
	//Acerto o parametro com a database
	RecLock("SX1",.F.)

	Replace x1_cnt01 With "'"+DTOC(dDataBase)+"'"

	MsUnlock()	
Endif

dbSelectArea(_sAlias)
Return*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³BFA320Calc ³ Autor ³ Adrianne Furtado      ³ Data ³ 07.06.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calculo dos valores do relatorio Posi‡„o Geral da Cobran‡a.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FA320Calc(cFiltSE1)                            				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function BFA320Calc(cFiltSE1,cFiltSED)

//LOCAL CbCont,CbTxt
//LOCAL tamanho:="M"
LOCAL nSaldo :=0,nDias:=0,I:=0,J:=0,nSaldoAtu:=0
LOCAL nFirst :=1,nFirst1:=1
LOCAL aVal[45,2]
LOCAL nRecebido:=0
LOCAL nValJuros:=0
LOCAL nDesconto:=0
LOCAL nCorrecao:=0
LOCAL nMulta   :=0
//LOCAL nOriginal:=0
LOCAL dDataBaixa
Local cCondSC6
Local dOldDtBase := dDataBase
LOCAL nX,cCondFil,nIndex
Local cQuery
Local aSitua := ARRAY(8)
//Local nI:=0
Local nMoedaBco := 1
Local nDecs := MsDecimais(MV_PAR08)
//Local cFiltro
Local cIndTmp, cAliasTmp
Local nTipoData := 1
Local lAdto
Local nValAbat := 0
Local nAbt		:= 0
//Local nTamFilial:= IIf( lFWCodFil, FWGETTAMFILIAL, 2 )
Local dDataBase:=MV_PAR12
Local _aRetInf := FWGetSX5 ( "07" ) //LGS#20200130 - Adequação para release 12.1.25
Local _nX

DEFAULT cFiltSE1 := ""
DEFAULT cFiltSED := ""

aSitua[1] := OemtoAnsi(STR0028)		//"Carteira"
aSitua[2] := OemtoAnsi(STR0029)		//"Cobranca Simples"
aSitua[3] := OemToAnsi(STR0030) 		//"Cobranca Descontada"
aSitua[4] := OemToAnsi(STR0031) 		//"Cobranca Caucionada"
aSitua[5] := OemToAnsi(STR0032)		//"Cobranca Vinculada"
aSitua[6] := OemToAnsi(STR0033)		//"Cobranca Extra-Judicial"
aSitua[7] := OemToAnsi(STR0034)	   //"Cobranca Cartorio"
aSitua[8] := OemToAnsi(STR0035) 	   //"Cobr Cauc Descont"

//Tipo da data para a composicao do saldo via SaldoTit()
If mv_par02 == 1			// Data da baixa (E5_BAIXA)
	nTipoData := 1
ElseIf mv_par02 == 2 	//Data de Digitacao (E5_DTDIGIT)
	nTipoData := 3
Else							//Data de Disponibilidade (E5_DTDISPO)
	nTipoData := 2
Endif

/********************************************************************************************************************************/
/*** BLOCO ALTERADO EM 30/01/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
//dbSelectArea("SX5")
//dbSeek( Space( nTamFilial ) +"07")
//While !Eof() .and. X5_TABELA == "07"
//	nI++
//	If nI > Len(aSitua)
//		Aadd(aSitua," ")		// garante um novo elemento
//	Endif
//	aSitua[nI] := TRIM(X5Descri())
//	dbSkip()
//Enddo
For _nX := 1 To Len( _aRetInf )
    If _nX > Len(aSitua)
       Aadd( aSitua, " " )
    Endif
    aSitua[_nX] := TRIM( _aRetInf[_nX][4] )
Next
/********************************************************************************************************************************/

PRIVATE  cTipos := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se seleciona tipos para total faturamento         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par03 == 1
	finaTipos()
Endif

dbSelectArea("SE1")
dbSetOrder(1)
If mv_par01 == 1
	dbSeek(xFilial("SE1"))
Else 
	dbGotop()
Endif

For i := 1 to 45
	For j := 1 to 2
		aVal[I,J] := 0
	Next j
Next i

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra APENAS os emitidos antes da database, pois este rela³
//³ torio pode ser retroativo.                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aStru  := SE1->(dbStruct())
		cAliasTmp := "FINR320"
		cQuery := ""
		aEval(aStru,{|x| cQuery += ","+AllTrim(x[1])})
		cQuery := "SELECT "+SubStr(cQuery,2)
		cQuery +=         ",R_E_C_N_O_ RECNO "
		cQuery += "FROM "+RetSqlName("SE1")+ " SE1 "
		cQuery += "WHERE "
		If mv_par01 == 1
			cQuery += "SE1.E1_FILIAL ='"+xFilial("SE1")+"' AND "
		Endif	
		If MV_PAR13 == 2 //Nao considerar titulos com emissao futura
			cQuery += "SE1.E1_EMISSAO <= '"+Dtos(dDataBase)+"' AND "
		Endif	
		cQuery += "SE1.E1_PREFIXO >= '"+MV_PAR04+"' AND "	
		cQuery += "SE1.E1_PREFIXO <= '"+MV_PAR05+"' AND "
		If MV_PAR09 == 2 
			cQuery += "SE1.E1_MOEDA = "+Str(MV_PAR08,2)+" AND "
		Endif 
		cQuery += "SE1.E1_SALDO >= '0' AND "	
		cQuery += "SE1.D_E_L_E_T_=' ' "
   	
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)	         //LEANDRO
		For nX :=  1 To Len(aStru)
			If aStru[nX][2] <> "C"
				TcSetField(cAliasTmp,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
			EndIf
		Next nX

dbSelectArea(cAliasTmp)

While !Eof()

	dbSelectArea(cAliasTmp)
   
	If mv_par03 == 1
		If !Inside(E1_TIPO)
			dbSkip()
			Loop
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Considera filtro do usuario - SE1                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cFiltSE1).and.!(&cFiltSE1)
		dbSkip()
		Loop
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Considera filtro do usuario - SED                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cFiltSED)                       
		SED->(DbSetOrder(1))
		SED->(MsSeek(xFilial()+SE1->E1_NATUREZ)) 
		If SED->(!&(cFiltSED))
			SE1->(DbSkip())		
			Loop
		Endif
	Endif		
		
	IF !Empty(E1_FATURA) .and. Substr(E1_FATURA,1,6) != "NOTFAT" .and. E1_DTFATUR <= dDataBase
		dbSkip()
		Loop
	Endif
		
	If mv_par01 == 1 .and. E1_FILIAL != xFilial("SE1")
		Exit
	EndIF
   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica se ‚ provis¢rio ou abatimento ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If E1_TIPO $ MVPROVIS+"/"+MVABATIM
    	If E1_TIPO $ MVABATIM	//Somo o valor caso seja abatimento 
      		If MV_PAR10 == 1  
				nAbt := IIF(dDatabase < E1_BAIXA, xMoeda(E1_VALOR,E1_MOEDA,MV_PAR08,,,If(cPaisLoc=="BRA",E1_TXMOEDA,0)), xMoeda(E1_SALDO,E1_MOEDA,MV_PAR08,,,If(cPaisLoc=="BRA",E1_TXMOEDA,0)))		// no resumo por tipo de titulos
				aVal[35,1] += nAbt
				aVal[35,2] += IIF(nAbt > 0,1,0)
			Endif
		Else            
        	aVal[16,1] += xMoeda(E1_SALDO,E1_MOEDA,MV_PAR08,,,If(cPaisLoc=="BRA",E1_TXMOEDA,0))
			aVal[16,2] += IIF(SE1->E1_SALDO > 0,1,0)
		Endif
		dbSkip()
		Loop
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula o faturamento baseado na data base/item 1 analise    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Month(E1_EMISSAO) == Month(dDatabase) .and. Year(E1_EMISSAO) == Year(dDataBase)
		If !(E1_TIPO $MV_CRNEG+"/"+MVRECANT)
			nDias := (E1_VENCREA - E1_EMISSAO)
			If nDias <= 1 
				aVal[1,1] += xMoeda(E1_VALOR,E1_MOEDA,MV_PAR08,,,If(cPaisLoc=="BRA",E1_TXMOEDA,0))
				aVal[1,2] += 1
			Else
				aVal[2,1] += xMoeda(E1_VALOR,E1_MOEDA,MV_PAR08,,,If(cPaisLoc=="BRA",E1_TXMOEDA,0))
				aVal[2,2] += 1
			Endif
		Endif
	Endif
    
	nSaldoAtu := 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Acumula titulos vencidos/vencer / Item 2 e 3 da analise      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#IFDEF TOP
		IF TcSrvType() != "AS/400"
			// Posiciona SE2 ou SE1 para pegar o saldo do titulo correto
			SE1->(DbGoto((cAliasTmp)->RECNO))
		Endif	
	#ENDIF 
	
	
	
If MV_PAR07 == 1    // Considera Data Base
	 dDataBase := MV_PAR12
Endif	

	If MV_PAR07 == 1
		IF !Empty(SE1->E1_BAIXA) .and. IIF(mv_par02 == 1,(SE1->E1_SALDO == 0 .and. SE1->E1_BAIXA <= dDataBase),.F.)
			nSaldoAtu := 0
		Else
			nSaldoAtu := SaldoTit( 	E1_PREFIXO,;
										E1_NUM,;
										E1_PARCELA,;
										E1_TIPO,;
										E1_NATUREZ,;
										"R",;
										E1_CLIENTE,;
										MV_PAR08,;
										dDataBase,;
										dDataBase,;
										E1_LOJA,;
										E1_FILIAL,;
										IIf(cPaisLoc=="BRA",E1_TXMOEDA,0),nTipoData )

			// Subtrai decrescimo para recompor o saldo na data escolhida.
			If Str(SE1->E1_VALOR,17,2) == Str(nSaldoAtu,17,2) .And. SE1->E1_DECRESC > 0 .And. SE1->E1_SDDECRE == 0
				nSaldoAtu -= SE1->E1_DECRESC
			Endif
			// Soma Acrescimo para recompor o saldo na data escolhida.
			If Str(SE1->E1_VALOR,17,2) == Str(nSaldoAtu,17,2) .And. SE1->E1_ACRESC > 0 .And. SE1->E1_SDACRES == 0
				nSaldoAtu += SE1->E1_ACRESC
			Endif
			
		Endif
	Else       
		If cPaisLoc == "BRA"
			nSaldoAtu := xMoeda((SE1->E1_SALDO+SE1->E1_SDACRES-SE1->E1_SDDECRE),E1_MOEDA,MV_PAR08,,,If(cPaisLoc=="BRA",E1_TXMOEDA,0))
		Else
			nSaldoAtu := xMoeda((SE1->E1_SALDO+SE1->E1_SDACRES-SE1->E1_SDDECRE),E1_MOEDA,MV_PAR08,E1_EMISSAO,nDecs+1,If(cPaisLoc=="BRA",E1_TXMOEDA,0))
		EndIf
	Endif
	
	nSaldoAtu -= FaDescFin("SE1",dDataBase,nSaldoAtu,1)
	
	nValAbat := 0		
	If !(E1_TIPO $MV_CRNEG+"/"+MVRECANT+"/"+MVABATIM)
		// Se considerar titulos com emissao futura, envia a data de ref. para Somaabat para que ela considere os
		// titulos de abatimento com emissao <= Database + 40 anos (30 * 480) - Emissao futura
		nValAbat := SomaAbat(E1_PREFIXO,E1_NUM,E1_PARCELA,"R",1,,E1_CLIENTE,E1_LOJA,E1_FILIAL,If(MV_PAR13==1,dDataBase+(30*480),dDataBase))
	Endif
	
	If nSaldoAtu > 0 .and. (MV_PAR10 == 1 .or. STR(nSaldoAtu,17,2) == STR(nValAbat,17,2))
		nSaldoAtu-= nValAbat
	Endif  
  	nSaldoAtu:=Round(NoRound(nSaldoAtu,3),2)

	If nSaldoAtu > 0
		dBaixa := dDataBase
		nJuros := 0
		/*
		If mvpar06 == 1
			fa070juros(MV_PAR08)
		Endif
       */
		lAdto := E1_TIPO $ MVRECANT+"/"+MV_CRNEG

		If E1_VENCREA < dDataBase
			nSaldoAtu+=nJuros
			nDias := (dDatabase - E1_VENCTO)
	
			aVal[34,1] += nSaldoAtu

			If !lAdto
				If nDias <= 15
					aVal[38,1] += nSaldoAtu
					aVal[38,2] += 1
				ElseIf nDias > 15 .And. nDias <= 30
					aVal[3,1] += nSaldoAtu
					aVal[3,2] += 1
				ElseIf nDias > 30 .And. nDias <= 60
					aVal[4,1] += nSaldoAtu
					aVal[4,2] += 1
				ElseIf nDias > 60 .And. nDias <= 90
					aVal[5,1] += nSaldoAtu
					aVal[5,2] += 1
				Else
					aVal[6,1] += nSaldoAtu
					aVal[6,2] += 1
				Endif
			Endif
		Else
			If !lAdto
				aVal[34,1] += nSaldoAtu
	         	nDias      := (E1_VENCREA - dDatabase)
				If nDias <= 15
    	   	  		aVal[39,1] += nSaldoAtu
    		   		aVal[39,2] += 1
	            ElseIf nDias > 15 .And. nDias <= 30
    	        	aVal[7,1] += nSaldoAtu
        	    	aVal[7,2] += 1
	         	ElseIf nDias > 30 .And. nDias <= 60
    	       		aVal[8,1] += nSaldoAtu
        	    	aVal[8,2] += 1
	         	ElseIf nDias > 60 .And. nDias <= 90
    	       		aVal[9,1] += nSaldoAtu
        	    	aVal[9,2] += 1
	         	Else
    	       		aVal[10,1] += nSaldoAtu
        	    	aVal[10,2] += 1
	         	EndIF
			Endif
		EndIF
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula a distribuicao de cobranca / item 4  analise         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nSaldoAtu > 0
		IF !(E1_TIPO $MV_CRNEG+"/"+MVRECANT)
			Do Case
				Case E1_SITUACA   $ " 0FG"
					aVal[25,1] += nSaldoAtu
					aVal[25,2] += 1
				Case E1_SITUACA   $ "1H"
					aVal[26,1] += nSaldoAtu
					aVal[26,2] += 1
				Case E1_SITUACA   = "2"
					aVal[27,1] += nSaldoAtu
					aVal[27,2] += 1
				Case E1_SITUACA   = "3"
					aVal[28,1] += nSaldoAtu
					aVal[28,2] += 1
				Case E1_SITUACA   = "4"
					aVal[29,1] += nSaldoAtu
					aVal[29,2] += 1
				Case E1_SITUACA   = "5"
					aVal[30,1] += nSaldoAtu
					aVal[30,2] += 1
				Case E1_SITUACA   = "6"
					aVal[31,1] += nSaldoAtu
					aVal[31,2] += 1
				Case E1_SITUACA   = "7"
					aVal[37,1] += nSaldoAtu
					aVal[37,2] += 1
			EndCase
		Endif
	Endif
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valor Recebido.     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nFirst1 == 1
		SA6->(dbSetorder(1)) // para pegar a moeda do banco.
		dbSelectArea("SE5") 
		If mv_par01 == 1
			dbSeek(xFilial("SE5"))
		Else
			dbGotop()
		Endif
		#IFDEF TOP
			IF TcSrvType() != "AS/400"
				aStru  := SE5->(dbStruct())
				cAliasSe5 := "NEWSE5"
				cCondFil := ""
				aEval(aStru,{|x| cCondFil += ","+AllTrim(x[1])})
				cCondFil := "SELECT "+SubStr(cCondFil,2)
				cCondFil +=         ",R_E_C_N_O_ RECNO "
				cCondFil += "FROM "+RetSqlName("SE5") + " SE5 "
				cCondFil += "WHERE " 
				If mv_par01 == 1
					cCondFil += "E5_FILIAL='" + xFilial("SE5") + "' AND "
				Endif
				cCondFil += "E5_TIPODOC IN ('VL','V2','JR','J2','CM','C2','MT','M2','DC','D2','TL','BA') AND E5_RECPAG = 'R' AND "
				cCondFil += "E5_PREFIXO >= '"+MV_PAR04+"' AND "	
				cCondFil += "E5_PREFIXO <= '"+MV_PAR05+"' AND "
	            If mv_par02 == 1
					cCondFil += "E5_DATA >= '"
				ElseIf mv_par02 == 2
					cCondFil += "E5_DTDIGIT >= '"
				ElseIf mv_par02 == 3
					cCondFil += "E5_DTDISPO >= '"
				Endif				
				cCondFIl += Subs(dtos(dDataBase),1,6)+"01"+"' AND "
	            If mv_par02 == 1
					cCondFil += "E5_DATA <= '"
				ElseIf mv_par02 == 2
					cCondFil += "E5_DTDIGIT <= '"
				ElseIf mv_par02 == 3
					cCondFil += "E5_DTDISPO <= '"
				Endif				
				cCondFIl += Dtos(LastDay(dDataBase))+"' AND "
				cCondFil += "D_E_L_E_T_=' ' "
		   	
				cCondFil := ChangeQuery(cCondFil)
		   	
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cCondFil),cAliasSe5,.T.,.T.)
				For nX :=  1 To Len(aStru)
					If aStru[nX][2] <> "C"
						TcSetField(cAliasSe5,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
					EndIf
				Next nX
			Else
		#ENDIF
				cCondFil := ""
				If mv_par01 == 1
					cCondFil += "E5_FILIAL=='" + xFilial("SE5") + "' .And. "
				Endif
				cCondFil += "E5_TIPODOC$'VL/V2/JR/J2/CM/C2/MT/M2/DC/D2/TL/BA' .and. E5_RECPAG == 'R' .and. "
				cCondFil += "E5_PREFIXO>='"+MV_PAR04+"'.And."	
				ccondFil += "E5_PREFIXO<='"+MV_PAR05+"'.And."
	            If mv_par02 == 1
					cCondFil += "DTOS(E5_DATA) >= '"
				ElseIf mv_par02 == 2
					cCondFil += "DTOS(E5_DTDIGIT) >= '"
				ElseIf mv_par02 == 3
					cCondFil += "DTOS(E5_DTDISPO) >= '"
				Endif				
				cCOndFIl += Subs(dtos(dDataBase),1,6)+"01"+"'.and."
	            If mv_par02 == 1
					cCondFil += "DTOS(E5_DATA) <= '"
				ElseIf mv_par02 == 2
					cCondFil += "DTOS(E5_DTDIGIT) <= '"
				ElseIf mv_par02 == 3
					cCondFil += "DTOS(E5_DTDISPO) <= '"
				Endif				
				cCOndFIl += Dtos(LastDay(dDataBase))+"'"
				cArq :=CriaTrab(NIL,.F.)
				IndRegua("SE5",cArq,IndexKey(),,)
				nIndex:=RetIndex("SE5")
				#IFNDEF TOP
					dbSetIndex(cArq+OrdBagExt())
				#ENDIF					 
				dbSetOrder(nIndex+1)
				cAliasSe5 := "SE5"
				DbGoTop()
		#IFDEF TOP
			Endif
		#ENDIF
		
		DbSelectArea(cAliasSe5)
		DbGoTop()
       
		While (mv_par01 != 1 .OR. xFilial("SE5") == (cAliasSe5)->E5_FILIAL) .AND. !Eof()
		

        	// Ignora registros que nao sao da moeda quando escolhido nao imprimir
			SA6->(dbSeek(xFilial()+(cAliasSe5)->E5_BANCO+(cAliasSe5)->E5_AGENCIA+(cAliasSe5)->E5_CONTA))
         If MV_PAR09 == 2 .AND. Max(SA6->A6_MOEDA, 1) != MV_PAR08 
         	dbSkip()
            Loop
			Endif                 
     
	     	nMoedaBco := If(SA6->(Found()), Max(SA6->A6_MOEDA, 1), 1)

			If mv_par02 == 1
		  		dDataBaixa := (cAliasSe5)->E5_DATA
			ElseIf mv_par02 == 2
		  		dDataBaixa := (cAliasSe5)->E5_DTDIGIT
			ElseIf mv_par02 == 3
		  		dDataBaixa := (cAliasSe5)->E5_DTDISPO
			Endif				
            
         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ Valor Recebido.   ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Month(dDatabase)== Month(dDataBaixa) .and.;
				Year(dDataBase) ==Year(dDataBaixa)   .and.;
				(cAliasSe5)->E5_RECPAG=="R" .and. dDataBaixa <= dDatabase .AND.;
				(cAliasSe5)->E5_TIPODOC$"VL/V2/BA" ;
				.and.  (cAliasSe5)->E5_SITUACA <> "C" .and. ;
				(	MovBcoBx((cAliasSe5)->E5_MOTBX) .or. ;
				((cAliasSe5)->E5_MOTBX=="CMP" .and. (cAliasSe5)->E5_TIPO $ MVRECANT+"#"+MV_CRNEG ) )			

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se existe estorno para esta baixa                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				#IFDEF TOP
					IF TcSrvType() != "AS/400"
						SE5->(dbGoto((cAliasSe5)->RECNO))
					Endif
				#ENDIF	
				If !TemBxCanc((cAliasSe5)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ))
					nRecebido += xMoeda((cAliasSe5)->E5_VALOR,nMoedaBco,MV_PAR08,(cAliasSe5)->E5_DATA,nDecs+1,,If(cPaisLoc=="BRA",(cAliasSe5)->E5_TXMOEDA,0))
				EndIf
			EndIf

	      If Month(dDatabase) = Month(dDataBaixa) .and. ;
	      	Year(dDataBase)  = Year(dDataBaixa)  .and. (cAliasSe5)->E5_RECPAG=="R" .and. ;
	         dDataBaixa <= dDatabase .and. (cAliasSe5)->E5_SITUACA <> "C" .and. ;
	         MovBcoBx((cAliasSe5)->E5_MOTBX) 
   	         nValorE5 := xMoeda((cAliasSe5)->E5_VALOR,nMoedaBco,MV_PAR08,(cAliasSe5)->E5_DATA,nDecs+1,,If(cPaisLoc=="BRA",(cAliasSe5)->E5_TXMOEDA,0))
	         Do Case 
	         	Case (cAliasSe5)->E5_TIPODOC $ "JR/J2/TL"  //Valor juros
	            	nValJuros += nValorE5
					Case (cAliasSe5)->E5_TIPODOC $ "CM/C2"     //Valor da correcao
	            	nCorrecao += nValorE5
					Case (cAliasSe5)->E5_TIPODOC $ "MT/M2"     //Valor da Multa
	            	nMulta    += nValorE5
					Case (cAliasSe5)->E5_TIPODOC $ "DC/D2"     //Valor do Desconto
	            	ndesconto += nValorE5
				EndCase
			EndIf
			dbSelectArea(cAliasSe5)
	      dbSkip()
		Enddo
		#IFDEF TOP
			IF TcSrvType() != "AS/400"
				dbSelectArea(cAliasSe5)
				dbCloseArea()
				dbSelectArea("SE5")
			Else
		#ENDIF
				dbSelectArea("SE5")
				DbClearFil()
				RetIndex("SE5")
				FErase(cArq+OrdBagExt())
		#IFDEF TOP
			Endif
		#ENDIF
		nFirst1++
		dbSelectArea(cAliasTmp)
	EndIf
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula a distribuicao por tipo de titulo / item 5 analise   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nSaldoAtu > 0 .and. (MV_PAR13 == 1 .Or. E1_EMISSAO <= dDatabase)
		Do Case
			Case E1_TIPO  $ MVDUPLIC
				aVal[11,1] += nSaldoAtu
            aVal[11,2] += 1
			Case E1_TIPO  $ MVNOTAFIS
				aVal[12,1] += nSaldoAtu
				aVal[12,2] += 1
			Case E1_TIPO  $ MVCHEQUES
				aVal[13,1] += nSaldoAtu
				aVal[13,2] += 1
			Case E1_TIPO   = "CN"
				aVal[14,1] += nSaldoAtu
				aVal[14,2] += 1
			Case E1_TIPO  $ MVTAXA
				aVal[15,1] += nSaldoAtu
				aVal[15,2] += 1
			Case E1_TIPO  $ MVRECANT
				aVal[24,1] += nSaldoAtu
				aVal[24,2] += 1
			Case E1_TIPO $ MV_CRNEG				
				aVal[36,1] += nSaldoAtu
				aVal[36,2] += 1
			OtherWise
				aVal[16,1]  += nSaldoAtu
				aVal[16,2]  += 1	
		EndCase
	End
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula T.Carteira pedidos a entregar / item 6 da analise    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nFirst == 1 .and. MV_PAR11 == 1	
		dbSelectArea("SC6")
		cCondSC6 := 'C6_QTDVEN > C6_QTDENT '
		cArq :=CriaTrab("",.F.)
		nIndex:=RetIndex("SC6")
/*		#IFNDEF TOP
			dbSetIndex(cArq+OrdBagExt())
		#ENDIF
		dbSetOrder(nIndex+1)*/
		If mv_par01 == 1
			dbSeek(cFilial)
		Else
			dbGotop()
		Endif
        
		While !Eof()

         IF mv_par01 == 1 .and. cFilial != C6_FILIAL
				Exit
         Endif

         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ Posicionar do SC5 para localiza moeda do pedido              ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         dbSelectArea( "SC5" )
         dbSeek( cFilial + SC6->C6_NUM )
         dbSelectArea( "SC6" )

		 	// Calcula se moeda for igual a escolhida ou for para converter
		 	If SC5->C5_MOEDA == MV_PAR08 .OR. MV_PAR09 == 1             
            nSaldo := xMoeda(fa320Saldo(),SC5->C5_MOEDA, MV_PAR08,SC5->C5_EMISSAO,nDecs+1)
            If nSaldo > 0
					If dDatabase < C6_ENTREG // itens a vencer					 
						nDias := (C6_ENTREG - dDatabase)
						If nDias <= 30
							aVal[17,2]++
							aVal[17,1]+= nSaldo
						ElseIf nDias > 30 .And. nDias <= 60
							aVal[18,2]++
							aVal[18,1]+= nSaldo
						ElseIf nDias > 60 .And. nDias <= 90
							aVal[19,2]++
							aVal[19,1]+= nSaldo
						Else
							aVal[20,2]++
							aVal[20,1]+= nSaldo
						Endif
					Else // itens vencidos
						nDias := (dDatabase - C6_ENTREG)
						aVal[21,2]++
						aVal[21,1]+= nSaldo
					EndIf
				Endif
			Endif
			dbSkip()
		EndDo
		RetIndex("SC6")
		Set Filter to
		Ferase(cArq+OrdBagExt())
		nFirst++
		dbSelectArea(cAliasTmp)
	Endif
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula o P.M.A e P.M.P - indices / item 7 da analise        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nSaldoAtu != 0
		aVal[22,1] += (E1_VENCREA-E1_EMISSAO)
		aVal[22,2] += 1
		aVal[23,1] += (E1_VENCREA-E1_EMISSAO)*;
					   xMoeda(nSaldoAtu,E1_MOEDA,MV_PAR08,E1_EMISSAO,nDecs+1,If(cPaisLoc=="BRA",E1_TXMOEDA,0))
		aVal[23,2] +=  xMoeda(nSaldoAtu,E1_MOEDA,MV_PAR08,E1_EMISSAO,nDecs+1,If(cPaisLoc=="BRA",E1_TXMOEDA,0))
	EndIf
	dbSelectArea(cAliasTmp)
	nSaldoAtu:=0
	dbSkip()
Enddo
#IFDEF TOP
	IF TcSrvType() != "AS/400"
		dbSelectArea(cAliasTmp)
		dbCloseArea()
		dbSelectArea("SE1")
	Else
#ENDIF
		dbSelectArea("SE1")
		DbClearFil()
		RetIndex("SE1")
		FErase(cIndTmp+OrdBagExt())
#IFDEF TOP
	Endif
#ENDIF

dbSelectArea("SE1")
dbSetOrder(1)
Set Filter to
dbSelectArea("SE5")
dbSetOrder(1)
Set Filter to

aVal[40,1] := nRecebido
aVal[41,1] := nValJuros
aVal[42,1] := nMulta           
aVal[43,1] := nCorrecao        
aVal[44,1] := nDesconto			
aVal[45,1] := nRecebido-(nValJuros+nMulta+nCorrecao-nDesconto)  
dDataBase := dOldDtBase // Restaura Data base

Return aVal
