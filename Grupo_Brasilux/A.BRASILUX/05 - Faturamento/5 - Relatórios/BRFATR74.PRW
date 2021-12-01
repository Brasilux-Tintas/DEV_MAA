#INCLUDE "BRFATR74.CH" 
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BRFATR74 ³ Autor ³ Cleber Orati          ³ Data ³ 10/02/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emissao da Pr‚-Nota                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFAT-R4                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function BRFATR74()

Local oReport
Private lM415SOL := ExistBlock("M415SOLI")
Private lM415ICM := ExistBlock("M415ICM")
     u_zcfga01( 'BRFATR74' ) //LGS#2021201 - Gravação de log de utilização da rotina
If FindFunction("TRepInUse") .And. TRepInUse()
	//-- Interface de impressao
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	BRFT74R3()
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ Marco Bianchi         ³ Data ³ 10/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

Local oReport
Local oPreNota
Local nValImp  	:= 0
Local nUltLib  	:= 0
Local nItem 	:= 0
Local nTamData  := Len(DTOC(MsDate()))
Local aCabPed	:= {}
Local aItemPed  := {}

Private aCodImps:= {}
Private nI		:= 0
Private nTotQtd := 0
Private nTotVal := 0

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
     
  if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 


oReport := TReport():New("BRFATR74",STR0050,"BRFATR74", {|oReport| ReportPrint(oReport,oPreNota,@nItem,aItemPed,aCabPed)},STR0051 + " " + STR0052)	// "Emissao da Confirmacao do Orcamento"###"Emissao da confirmacao dos orcamentos de venda, de acordo com"###"intervalo informado na opcaoo Parametros."
oReport:SetLandscape() 
oReport:SetTotalInLine(.F.)

//ValidPerg(oReport:uParam)
Pergunte(oReport:uParam,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³                                                                        ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3_Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de código para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Secao dos itens do Orcamento de Vendas                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPreNota := TRSection():New(oReport,STR0108,{"SCJ","SCK"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)	// "Emissao da Confirmacao do Orcamento"
oPreNota:SetTotalInLine(.F.)

TRCell():New(oPreNota,"AITEM01",/*Tabela*/,STR0053					 ,PesqPict("SCK","CK_ITEM"		),TamSx3("CK_ITEM"		)[1],/*lPixel*/,{|| aItemPed[nItem][01] 																	})	// "IT"
TRCell():New(oPreNota,"AITEM02",/*Tabela*/,RetTitle("CK_PRODUTO"	),PesqPict("SCK","CK_PRODUTO"	),TamSx3("CK_PRODUTO"	)[1],/*lPixel*/,{|| aItemPed[nItem][02] 																	})	// Codigo do Produto
TRCell():New(oPreNota,"AITEM03",/*Tabela*/,RetTitle("CK_DESCRI"	    ),PesqPict("SCK","CK_DESCRI"    ),TamSx3("CK_DESCRI"	)[1],/*lPixel*/,{|| IIF(Empty(aItemPed[nItem][03]),SB1->B1_DESC, aItemPed[nItem][03])						})	// Descricao do Produto
TRCell():New(oPreNota,"AITEM04",/*Tabela*/,STR0054					 ,PesqPict("SCK","CK_TES"		),TamSx3("CK_TES"		)[1],/*lPixel*/,{|| aItemPed[nItem][04] 																	})	// "TES"
TRCell():New(oPreNota,"AITEM05",/*Tabela*/,STR0055					 ,PesqPict("SCK","CK_CLASFIS"	),TamSx3("CK_CLASFIS"	)[1],/*lPixel*/,{|| aItemPed[nItem][05] 																	})	// "CF"
TRCell():New(oPreNota,"AITEM06",/*Tabela*/,STR0056					 ,PesqPict("SCK","CK_UM"		),TamSx3("CK_UM"		)[1],/*lPixel*/,{|| aItemPed[nItem][06] 																	})	// "UM"
TRCell():New(oPreNota,"AITEM07",/*Tabela*/,STR0057					 ,PesqPictQt("CK_QTDVEN"	    ),TamSx3("CK_QTDVEN"	)[1],/*lPixel*/,{|| aItemPed[nItem][07] 																	})	// "Quant."
TRCell():New(oPreNota,"AITEM08",/*Tabela*/,RetTitle("CK_PRCVEN"	),PesqPict("SCK","CK_PRCVEN"	    ),TamSx3("CK_PRCVEN"	)[1],/*lPixel*/,{|| aItemPed[nItem][08] 																	})	// Preco Unitario
If cPaisLoc == "BRA"
	TRCell():New(oPreNota,"NALIQIPI",/*Tabela*/	,STR0058,"@e 99.99"				,5,/*lPixel*/,{|| MaFisRet(nItem,"IT_ALIQIPI") 																											})	// "IPI"
	TRCell():New(oPreNota,"NALIQICM",/*Tabela*/	,STR0059,"@e 99.99"				,5,/*lPixel*/,{|| MaFisRet(nItem,"IT_ALIQICM") 																											})	// "ICM"
	TRCell():New(oPreNota,"NALIQISS",/*Tabela*/	,STR0060,"@e 99.99"				,5,/*lPixel*/,{|| MaFisRet(nItem,"IT_ALIQISS") 																											})	// "ISS"
Else
	TRCell():New(oPreNota,"NVALIMP"	,/*Tabela*/	,STR0058,Tm(nValImp,10,2)	,5,/*lPixel*/,{|| Tm(nValImp,10,2) 																														})	// "IPI"
EndIf
TRCell():New(oPreNota,"AITEM13",/*Tabela*/,STR0061						,PesqPict("SCK","CK_VALOR"		),TamSx3("CK_VALOR"		)[1],/*lPixel*/,{|| aItemPed[nItem][13]+nValImp 														})	// "Vl.Tot.C/IPI"
TRCell():New(oPreNota,"AITEM14",/*Tabela*/,RetTitle("CK_ENTREG"	)	    ,PesqPict("SCK","CK_ENTREG"		),nTamData					,/*lPixel*/,{|| aItemPed[nItem][14] 																},,,,,,.F.)	// Data de Entrega
TRCell():New(oPreNota,"AITEM15",/*Tabela*/,RetTitle("CK_DESCONT"	)	,PesqPict("SCK","CK_DESCONT"	),TamSx3("CK_DESCONT"	)[1],/*lPixel*/,{|| aItemPed[nItem][15] 																})	// % Desconto
TRCell():New(oPreNota,"AITEM16",/*Tabela*/,STR0062						,PesqPict("SCK","CK_LOCAL"		),TamSx3("CK_LOCAL"		)[1],/*lPixel*/,{|| aItemPed[nItem][16] 																})	// "Loc."
TRCell():New(oPreNota,"AITEM17",/*Tabela*/,STR0063						,PesqPictQt("C6_QTDLIB"		    ),TamSx3("C6_QTDLIB"	)[1],/*lPixel*/,{|| aItemPed[nItem][17] 												  				})	// "Qtd.a Fat."
TRCell():New(oPreNota,"NSALDO" ,/*Tabela*/,STR0064						,PesqPictQt("C6_QTDLIB"		    ),TamSx3("C6_QTDLIB"	)[1],/*lPixel*/,{|| aItemPed[nItem][07]-aItemPed[nItem][17]+aItemPed[nItem][18]-aItemPed[nItem][19]	})	// "Saldo"
TRCell():New(oPreNota,"NULTLIB",/*Tabela*/,STR0065						,PesqPictQt("D2_QUANT",10	    ),TamSx3("D2_QUANT"		)[1],/*lPixel*/,{|| nUltLib 																			})	// "Ult.Fat."

TRFunction():New(oPreNota:Cell("AITEM07"),"AITEM07"/* cID */,"ONPRINT",/*oBreak*/,/*cTitle*/,PesqPict("SCK","CK_QTDVEN",20),{|| nTotQtd }/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oPreNota:Cell("AITEM13"),"AITEM13"/* cID */,"ONPRINT",/*oBreak*/,/*cTitle*/,/*cPicture*/,{|| nTotVal }/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Secao dos Impostos                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oImpostos := TRSection():New(oReport,STR0109,{"SCJ","SCK","SD1","SB1","SD2","SA1","SA2","SA4","SE4","SA3","SX3"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)	// "Emissao da Confirmacao do Orcamento"
oImpostos:SetTotalInLine(.F.)
If cPaisLoc == "BRA"
	TRCell():New(oImpostos,"NF_BASEICM"	,/*Tabela*/,STR0087,PesqPict("SF2","F2_BASEICM"),TamSx3("F2_BASEICM"		)[1],/*lPixel*/,{|| MaFisRet(,"NF_BASEICM") 	})	// "Base Icms"
	TRCell():New(oImpostos,"NF_VALICM"	,/*Tabela*/,STR0088,PesqPict("SF2","F2_VALICM") ,TamSx3("F2_VALICM"		)[1],/*lPixel*/,{|| MaFisRet(,"NF_VALICM"	) 	})	// "Valor Icms"
	TRCell():New(oImpostos,"NF_BASEIPI"	,/*Tabela*/,STR0089,PesqPict("SF2","F2_BASEIPI"),TamSx3("F2_BASEIPI"		)[1],/*lPixel*/,{|| MaFisRet(,"NF_BASEIPI") 	})	// "Base Ipi"
	TRCell():New(oImpostos,"NF_VALIPI"	,/*Tabela*/,STR0090,PesqPict("SF2","F2_VALIPI") ,TamSx3("F2_VALIPI"		)[1],/*lPixel*/,{|| MaFisRet(,"NF_VALIPI"	) 	})	// "Valor Ipi"
	TRCell():New(oImpostos,"NF_BASESOL"	,/*Tabela*/,STR0091,PesqPict("SF2","F2_BRICMS") ,TamSx3("F2_BRICMS"		)[1],/*lPixel*/,{|| MaFisRet(,"NF_BASESOL") 	})	// "Base Retido"
	TRCell():New(oImpostos,"NF_VALSOL"	,/*Tabela*/,STR0092,PesqPict("SF2","F2_ICMSRET"),TamSx3("F2_ICMSRET"		)[1],/*lPixel*/,{|| MaFisRet(,"NF_VALSOL"	) 	})	// "Valor Retido"
	TRCell():New(oImpostos,"NF_TOTAL"	,/*Tabela*/,STR0093,PesqPict("SF2","F2_VALBRUT"),TamSx3("F2_VALBRUT"	    	)[1],/*lPixel*/,{|| MaFisRet(,"NF_TOTAL"	) 	})	// "Valor Total"
	TRCell():New(oImpostos,"NF_BASEISS"	,/*Tabela*/,STR0094,PesqPict("SF2","F2_BASEISS"),TamSx3("F2_BASEISS"		)[1],/*lPixel*/,{|| MaFisRet(,"NF_BASEISS") 	})	// "Base Iss"
	TRCell():New(oImpostos,"NF_VALISS"	,/*Tabela*/,STR0095,PesqPict("SF2","F2_VALISS") ,TamSx3("F2_VALISS"		)[1],/*lPixel*/,{|| MaFisRet(,"NF_VALISS"	) 	})	// "Valor Iss"
Else
	TRCell():New(oImpostos,"aCodImps2"	,/*Tabela*/,STR0096,/*Picture*/			,13,/*lPixel*/,{|| aCodImps[nI][2] 		})	// "Imposto"
	TRCell():New(oImpostos,"aCodImps3"	,/*Tabela*/,STR0097,"@E 99,999,999.99"	,13,/*lPixel*/,{|| aCodImps[nI][3] 		})	// "Base"
	TRCell():New(oImpostos,"aCodImps4"	,/*Tabela*/,STR0098,"@E 99,999,999.99"	,13,/*lPixel*/,{|| aCodImps[nI][4] 		})	// "Aliquota"
	TRCell():New(oImpostos,"aCodImps5"	,/*Tabela*/,STR0099,"@E 99,999,999.99"	,13,/*lPixel*/,{|| aCodImps[nI][5]			})	// "Valor"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Troca descricao do total dos itens                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:Section(1):SetTotalText(STR0085)	// "T O T A I S "

TRPosition():New(oPreNota,"SCK",1,{|| xFilial("SCJ") + aCabPed[07]+aItemPed[nItem][01]})
TRPosition():New(oPreNota,"SCJ",1,{|| xFilial("SCK") + aCabPed[07]+aItemPed[nItem][01]})

oReport:Section(2):SetEdit(.F.) 
oReport:Section(1):SetUseQuery(.F.) // Novo compomente tReport para adcionar campos de usuario no relatorio qdo utiliza query

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alinhamento a direita as colunas de valor                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPreNota:Cell("AITEM07"):SetHeaderAlign("RIGHT")
oPreNota:Cell("AITEM08"):SetHeaderAlign("RIGHT")
If cPaisLoc == "BRA"
	oPreNota:Cell("NALIQIPI"):SetHeaderAlign("RIGHT")
	oPreNota:Cell("NALIQICM"):SetHeaderAlign("RIGHT")
	oPreNota:Cell("NALIQISS"):SetHeaderAlign("RIGHT")

	oImpostos:Cell("NF_BASEICM"):SetHeaderAlign("RIGHT")
	oImpostos:Cell("NF_VALICM"):SetHeaderAlign("RIGHT")
	oImpostos:Cell("NF_BASEIPI"):SetHeaderAlign("RIGHT")
	oImpostos:Cell("NF_VALIPI"):SetHeaderAlign("RIGHT")
	oImpostos:Cell("NF_BASESOL"):SetHeaderAlign("RIGHT")
	oImpostos:Cell("NF_VALSOL"):SetHeaderAlign("RIGHT")
	oImpostos:Cell("NF_TOTAL"):SetHeaderAlign("RIGHT")
	oImpostos:Cell("NF_BASEISS"):SetHeaderAlign("RIGHT")
	oImpostos:Cell("NF_VALISS"):SetHeaderAlign("RIGHT")

Else
	oPreNota:Cell("NVALIMP"):SetHeaderAlign("RIGHT")	

	oImpostos:Cell("aCodImps2"):SetHeaderAlign("RIGHT")	
	oImpostos:Cell("aCodImps3"):SetHeaderAlign("RIGHT")	
	oImpostos:Cell("aCodImps4"):SetHeaderAlign("RIGHT")	
	oImpostos:Cell("aCodImps5"):SetHeaderAlign("RIGHT")	
EndIf
oPreNota:Cell("AITEM13"):SetHeaderAlign("RIGHT")	
oPreNota:Cell("AITEM17"):SetHeaderAlign("RIGHT")	
oPreNota:Cell("NSALDO"):SetHeaderAlign("RIGHT")	
oPreNota:Cell("NULTLIB"):SetHeaderAlign("RIGHT")	
Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrin³ Autor ³ Marco Bianchi         ³ Data ³ 10/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport,oPreNota,nItem,aItemPed,aCabPed)

Local lQuery    := .F.
#IFNDEF TOP
	Local cCondicao := ""
#ENDIF

Local aPedCli    := {}
Local aC5Rodape  := {}
Local aRelImp    := MaFisRelImp("MT100",{"SF2","SD2"})
Local aFisGet    := Nil
Local aFisGetSCJ := Nil
Local cKey 	     := ""
Local cAliasSCJ  := "SCJ"
Local cAliasSCK  := "SCK"
Local cQryAd     := ""
Local cPedido    := ""
Local cCliEnt	 := ""
Local cNfOri     := Nil
Local cSeriOri   := Nil
Local nDesconto  := 0
Local nPesLiq    := 0
Local nRecnoSD1  := Nil
Local nG		 := 0
Local nFrete	 := 0
Local nSeguro	 := 0
Local nFretAut	 := 0
Local nDespesa	 := 0
Local nDescCab	 := 0
Local nPDesCab	 := 0
Local nY         := 0
Local nValMerc   := 0
Local nPrcLista  := 0
Local nAcresFin  := 0
Local nCont		 := 0
Local cAux := ""
Local aSolid := {}
Private aHeader := {}, aCols := {},_VALICM,_ALIQICM
FisGetInit(@aFisGet,@aFisGetSCJ)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transforma parametros Range em expressao SQL                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeSqlExpr(oReport:uParam)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtragem do relatório                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP
	If TcSrvType() <> "AS/400"
	
		cQryAd := "%"
		For nY := 1 To Len(aFisGet)
			cQryAd += ","+aFisGet[nY][2]
		Next nY
		For nY := 1 To Len(aFisGetSCJ)
			cQryAd += ","+aFisGetSCJ[nY][2]
		Next nY		
		cQryAd += "%"
	
		cAliasSCJ:= cAliasSCK:= GetNextAlias()
		lQuery    := .T.
		
		oReport:Section(1):BeginQuery()
		if MV_PAR03 == 1
			cAux = "A"
			BeginSql Alias cAliasSCJ
			SELECT SCJ.R_E_C_N_O_ SCJREC,SCK.R_E_C_N_O_ SCKREC,
			SCJ.CJ_FILIAL,SCJ.CJ_NUM,SCJ.CJ_CLIENTE,SCJ.CJ_LOJA,
			SCJ.CJ_TRANSP,SCJ.CJ_REDESP,SCJ.CJ_DESC1,
			SCJ.CJ_DESC2,SCJ.CJ_DESC3,SCJ.CJ_DESC4,SCJ.CJ_EMISSAO,SCJ.CJ_STATUS,
			SCJ.CJ_CONDPAG,SCJ.CJ_FRETE,SCJ.CJ_DESPESA,SCJ.CJ_FRETAUT,SCJ.CJ_SEGURO,SCJ.CJ_TABELA,
			SCJ.CJ_MOEDA,
			SCJ.CJ_VEND1,
			SCJ.CJ_PDESCAB,SCJ.CJ_DESCONT,
			SCJ.CJ_CLIENT,
			SCK.CK_FILIAL,SCK.CK_NUM,SCK.CK_PEDCLI,SCK.CK_PRODUTO,
			SCK.CK_TES,SCK.CK_CLASFIS,SCK.CK_QTDVEN,SCK.CK_PRUNIT,SCK.CK_VALDESC,
			SCK.CK_VALOR,SCK.CK_ITEM,SCK.CK_DESCRI,SCK.CK_UM,
			SCK.CK_PRCVEN,SCK.CK_CLIENTE,
			SCK.CK_LOJA,SCK.CK_ENTREG,SCK.CK_DESCONT,SCK.CK_LOCAL 
			%Exp:cQryAd%
			FROM %Table:SCJ% SCJ, %Table:SCK% SCK
			WHERE
			SCJ.CJ_FILIAL = %xFilial:SCJ% AND  
			SCJ.CJ_STATUS = %Exp:cAux% AND
			SCJ.CJ_NUM >= %Exp:mv_par01% AND
			SCJ.CJ_NUM <= %Exp:mv_par02% AND
			SCJ.%notdel% AND
			SCK.CK_FILIAL = %xFilial:SCK% AND
			SCK.CK_NUM   = SCJ.CJ_NUM AND
			SCK.%notdel%
			ORDER BY SCJ.CJ_NUM    
			EndSql
		ELSE 
			BeginSql Alias cAliasSCJ
			SELECT SCJ.R_E_C_N_O_ SCJREC,SCK.R_E_C_N_O_ SCKREC,
			SCJ.CJ_FILIAL,SCJ.CJ_NUM,SCJ.CJ_CLIENTE,SCJ.CJ_LOJA,
			SCJ.CJ_TRANSP,SCJ.CJ_REDESP,SCJ.CJ_DESC1,
			SCJ.CJ_DESC2,SCJ.CJ_DESC3,SCJ.CJ_DESC4,SCJ.CJ_EMISSAO,SCJ.CJ_STATUS,
			SCJ.CJ_CONDPAG,SCJ.CJ_FRETE,SCJ.CJ_DESPESA,SCJ.CJ_FRETAUT,SCJ.CJ_SEGURO,SCJ.CJ_TABELA,
			SCJ.CJ_MOEDA,
			SCJ.CJ_VEND1,
			SCJ.CJ_PDESCAB,SCJ.CJ_DESCONT,
			SCJ.CJ_CLIENT,
			SCK.CK_FILIAL,SCK.CK_NUM,SCK.CK_PEDCLI,SCK.CK_PRODUTO,
			SCK.CK_TES,SCK.CK_CLASFIS,SCK.CK_QTDVEN,SCK.CK_PRUNIT,SCK.CK_VALDESC,
			SCK.CK_VALOR,SCK.CK_ITEM,SCK.CK_DESCRI,SCK.CK_UM,
			SCK.CK_PRCVEN,SCK.CK_CLIENTE,
			SCK.CK_LOJA,SCK.CK_ENTREG,SCK.CK_DESCONT,SCK.CK_LOCAL 
			%Exp:cQryAd%
			FROM %Table:SCJ% SCJ, %Table:SCK% SCK
			WHERE
			SCJ.CJ_FILIAL = %xFilial:SCJ% AND
			SCJ.CJ_NUM >= %Exp:mv_par01% AND
			SCJ.CJ_NUM <= %Exp:mv_par02% AND
			SCJ.%notdel% AND
			SCK.CK_FILIAL = %xFilial:SCK% AND
			SCK.CK_NUM   = SCJ.CJ_NUM AND
			SCK.%notdel%
			ORDER BY SCJ.CJ_NUM    
			EndSql
		ENDIF 
		oReport:section(1):endQuery()

	Else
#ENDIF	
	cAliasSCJ := "SCJ"
	dbSelectArea(cAliasSCJ)
	cKey := IndexKey()	
	cCondicao := '(CJ_FILIAL == "'+xFilial("SCJ")+')" .And. (CJ_NUM >= "'+mv_par01+'" .And. CJ_NUM <= "'+mv_par02+'")'
	if mv_par03 == 1
		cCondicao += " .and. (CJ_STATUS = 'A')"
	endif 
	oReport:Section(1):SetFilter(cCondicao,"",,cAliasSCJ)	
	(cAliasSCJ)->( dbGoTop() )
	
	#IFDEF TOP
	Endif
	#ENDIF	
	(cAliasSCJ)->( dbEval( {|| nCont++ } ) )
	(cAliasSCJ)->( dbGoTop() )
	oReport:SetMeter(nCont)		// Total de Elementos da regua


Aadd(aHeader,{"CK_QTDVEN","CK_QTDVEN","",0,0,"", "","","","" })
Aadd(aHeader,{"CK_PRCVEN","CK_PRCVEN","",0,0,"", "","","","" })
Aadd(aHeader,{"CK_PRODUTO","CK_PRODUTO","",0,0,"", "","","","" })
Aadd(aHeader,{"CK_TES","CK_TES","",0,0,"", "","","","" })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio da impressao do fluxo do relatório                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !oReport:Cancel() .And. !((cAliasSCJ)->(Eof())) .and. xFilial("SCJ")==(cAliasSCJ)->CJ_FILIAL

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a validacao dos filtros do usuario           	     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAliasSCJ)

	cCliEnt := IIf(!Empty((cAliasSCJ)->(FieldGet(FieldPos("CJ_CLIENT")))),(cAliasSCJ)->CJ_CLIENT,(cAliasSCJ)->CJ_CLIENTE)
	aCabPed := {}

	MaFisIni(cCliEnt,;						// 1-Codigo Cliente/Fornecedor
		(cAliasSCJ)->CJ_LOJA,;			// 2-Loja do Cliente/Fornecedor
		"C",;	// 3-C:Cliente , F:Fornecedor
		"N",;				// 4-Tipo da NF
		Posicione("SA1", 1, xFilial("SA1")+(cAliasSCJ)->CJ_CLIENTE, "A1_TIPO"),;			// 5-Tipo do Cliente/Fornecedor
		aRelImp,;							// 6-Relacao de Impostos que suportados no arquivo
		,;						   			// 7-Tipo de complemento
		,;									// 8-Permite Incluir Impostos no Rodape .T./.F.
		"SB1",;								// 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
		"MATA461")							// 10-Nome da rotina que esta utilizando a funcao
	//Na argentina o calculo de impostos depende da serie.
	If cPaisLoc == 'ARG'
		SA1->(DbSetOrder(1))
		SA1->(MsSeek(xFilial()+(cAliasSCJ)->CJ_CLIENTE+(cAliasSCJ)->CJ_LOJA))
		MaFisAlt('NF_SERIENF',LocXTipSer('SA1',MVNOTAFIS))
	Endif

	nFrete		:= (cAliasSCJ)->CJ_FRETE
	nSeguro		:= (cAliasSCJ)->CJ_SEGURO
	nFretAut	:= (cAliasSCJ)->CJ_FRETAUT
	nDespesa	:= (cAliasSCJ)->CJ_DESPESA
	nDescCab	:= (cAliasSCJ)->CJ_DESCONT
	nPDesCab	:= (cAliasSCJ)->CJ_PDESCAB

	aItemPed:= {}
	aCabPed := {	"N"	,;
		(cAliasSCJ)->CJ_CLIENTE				,;
		(cAliasSCJ)->CJ_LOJA				,;
		(cAliasSCJ)->CJ_TRANSP				,;
		(cAliasSCJ)->CJ_CONDPAG				,;
		(cAliasSCJ)->CJ_EMISSAO				,;
		(cAliasSCJ)->CJ_NUM					,;
		(cAliasSCJ)->CJ_VEND1				,;
		""				,;
		""				,;
		""				,;
		""				,;
		0				,;
		0				,;
		0				,;
		0				,;
		0				,;
		(cAliasSCJ)->CJ_FRETE				,;
		"F"				,;
		(cAliasSCJ)->CJ_SEGURO				,;
		(cAliasSCJ)->CJ_TABELA				,;
		-1				,;
		""				,;
		(cAliasSCJ)->CJ_MOEDA				,;
		""				,;
		""				,;
		0			    ,;
		(cAliasSCJ)->CJ_REDESP               ;
		}
	nTotQtd := 0
	nTotVal := 0
	nPesBru	:= 0
	nPesLiq	:= 0
	aPedCli	:= {}
	If !lQuery
		dbSelectArea(cAliasSCK)
		dbSetOrder(1)
		dbSeek(xFilial("SCK")+(cAliasSCJ)->CJ_NUM)
	EndIf
	cPedido    := (cAliasSCJ)->CJ_NUM
	aC5Rodape  := {}
	aadd(aC5Rodape,{0,0,(cAliasSCJ)->CJ_DESC1,(cAliasSCJ)->CJ_DESC2,;
		(cAliasSCJ)->CJ_DESC3,(cAliasSCJ)->CJ_DESC4,""})

	aPedCli := Mtr730Cli(cPedido)

	dbSelectArea(cAliasSCJ)
	For nY := 1 to Len(aFisGetSCJ)
		If !Empty(&(aFisGetSCJ[ny][2]))
			If aFisGetSCJ[ny][1] == "NF_SUFRAMA"
				MaFisAlt(aFisGetSCJ[ny][1],Iif(&(aFisGetSCJ[ny][2]) == "1",.T.,.F.),Len(aItemPed),.T.)		
			Else
				MaFisAlt(aFisGetSCJ[ny][1],&(aFisGetSCJ[ny][2]),Len(aItemPed),.T.)
			Endif	
		EndIf
	Next nY



	While !oReport:Cancel() .And. !((cAliasSCK)->(Eof())) .And. xFilial("SCK")==(cAliasSCK)->CK_FILIAL .And.;
			(cAliasSCK)->CK_NUM == cPedido

		oReport:IncMeter()

		cNfOri     := Nil
		cSeriOri   := Nil
		nRecnoSD1  := Nil
		nDesconto  := 0

		dbSelectArea(cAliasSCK)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calcula o preco de lista                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nValMerc  := (cAliasSCK)->CK_VALOR
		nPrcLista := (cAliasSCK)->CK_PRUNIT
		If ( nPrcLista == 0 )
			nPrcLista := NoRound(nValMerc/(cAliasSCK)->CK_QTDVEN,TamSX3("CK_PRCVEN")[2])
		EndIf
		nAcresFin := A410Arred((cAliasSCK)->CK_PRCVEN*0/100,"D2_PRCVEN")
		nValMerc  += A410Arred((cAliasSCK)->CK_QTDVEN*nAcresFin,"D2_TOTAL")		
		nDesconto := a410Arred(nPrcLista*(cAliasSCK)->CK_QTDVEN,"D2_DESCON")-nValMerc
		nDesconto := IIf(nDesconto==0,(cAliasSCK)->CK_VALDESC,nDesconto)
		nDesconto := Max(0,nDesconto)
		nPrcLista += nAcresFin
		If cPaisLoc=="BRA"
			nValMerc  += nDesconto
		EndIf			
		
		MaFisAdd((cAliasSCK)->CK_PRODUTO	,;	// 1-Codigo do Produto ( Obrigatorio )
			(cAliasSCK)->CK_TES				,;	// 2-Codigo do TES ( Opcional )
			(cAliasSCK)->CK_QTDVEN			,;	// 3-Quantidade ( Obrigatorio )
			nPrcLista						,;	// 4-Preco Unitario ( Obrigatorio )
			nDesconto						,;	// 5-Valor do Desconto ( Opcional )
			cNfOri							,;	// 6-Numero da NF Original ( Devolucao/Benef )
			cSeriOri						,;	// 7-Serie da NF Original ( Devolucao/Benef )
			nRecnoSD1						,;	// 8-RecNo da NF Original no arq SD1/SD2
			0								,;	// 9-Valor do Frete do Item ( Opcional )
			0								,;	// 10-Valor da Despesa do item ( Opcional )
			0								,;	// 11-Valor do Seguro do item ( Opcional )
			0								,;	// 12-Valor do Frete Autonomo ( Opcional )
			nValMerc						,;	// 13-Valor da Mercadoria ( Obrigatorio )
			0								,;	// 14-Valor da Embalagem ( Opiconal )
			0								,;	// 15-RecNo do SB1
			0								)	// 16-RecNo do SF4
	
						

		aadd(aItemPed,	{	(cAliasSCK)->CK_ITEM	,;
			(cAliasSCK)->CK_PRODUTO					,;
			(cAliasSCK)->CK_DESCRI					,;
			(cAliasSCK)->CK_TES						,;
			(cAliasSCK)->CK_CLASFIS					,;
			(cAliasSCK)->CK_UM						,;
			(cAliasSCK)->CK_QTDVEN					,;
			(cAliasSCK)->CK_PRCVEN					,;
			""					,;
			""					,;
			(cAliasSCK)->CK_CLIENTE						,;
			(cAliasSCK)->CK_LOJA					,;
			(cAliasSCK)->CK_VALOR					,;
			(cAliasSCK)->CK_ENTREG					,;
			(cAliasSCK)->CK_DESCONT					,;
			(cAliasSCK)->CK_LOCAL					,;
			0					,;
			0					,;
			0					,;
			})							
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Forca os valores de impostos que foram informados no SCK.              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea(cAliasSCK)
		For nY := 1 to Len(aFisGet)
			If !Empty(&(aFisGet[ny][2]))
				MaFisAlt(aFisGet[ny][1],&(aFisGet[ny][2]),Len(aItemPed))
			EndIf
		Next nY

/*
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calculo do ISS                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SF4->(dbSetOrder(1))
		SF4->(MsSeek(xFilial("SF4")+(cAliasSCK)->CK_TES))
		If ( (cAliasSCJ)->CJ_INCISS == "N" )
			If ( SF4->F4_ISS=="S" )
				nPrcLista := a410Arred(nPrcLista/(1-(MaAliqISS(Len(aItemPed))/100)),"D2_PRCVEN")
				nValMerc  := a410Arred(nValMerc/(1-(MaAliqISS(Len(aItemPed))/100)),"D2_PRCVEN")
				MaFisAlt("IT_PRCUNI",nPrcLista,Len(aItemPed))
				MaFisAlt("IT_VALMERC",nValMerc,Len(aItemPed))
			EndIf
		EndIf	
*/		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Altera peso para calcular frete              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SB1->(dbSetOrder(1))
		SB1->(MsSeek(xFilial("SB1")+(cAliasSCK)->CK_PRODUTO))			
		MaFisAlt("IT_PESO",(cAliasSCK)->CK_QTDVEN*SB1->B1_PESO,Len(aItemPed))
		MaFisAlt("IT_PRCUNI",nPrcLista,Len(aItemPed))
		MaFisAlt("IT_VALMERC",nValMerc,Len(aItemPed))


        DbSelectArea("SA1")
        dbsetorder(1)
   	    DbSeek(xFilial("SA1")+(cAliasSCJ)->CJ_CLIENTE)


		Aadd(aCols,Array(len(aHeader)+1))
		aCols[Len(aItemPed)][len(aHeader)+1] := .F.
		aCols[Len(aItemPed),1] := (cAliasSCK)->CK_QTDVEN
		aCols[Len(aItemPed),2] := (cAliasSCK)->CK_PRCVEN
		aCols[Len(aItemPed),3] := (cAliasSCK)->CK_PRODUTO
		aCols[Len(aItemPed),4] := (cAliasSCK)->CK_TES
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pontos de Entrada 								     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//If (ExistBlock("M415ICM")) release 12.1.25
		If lM415ICM
			_ALIQICM    := MaFisRet(Len(aItemPed),"IT_ALIQICM")
			_VALICM    := MaFisRet(Len(aItemPed),"IT_VALICM")
			ExecBlock("M415ICM",.F.,.F.,{Len(aItemPed)})
			MaFisAlt("IT_ALIQICM",_ALIQICM,Len(aItemPed))
			MaFisAlt("IT_VALICM",_VALICM,Len(aItemPed))
		endif 


		aSolid := {}
		If (ExistTemplate("M415SOLI"))
			aSolid := ExecTemplate("M415SOLI",.F.,.F.,{Len(aItemPed)})
		else 
			//If (ExistBlock("M415SOLI")) release 12.1.25
			If lM415SOL
				aSolid := ExecBlock("M415SOLI",.F.,.F.,{Len(aItemPed)}) 
			Endif
		endif
		IF ValType(aSolid) == "A"
			IF Len(aSolid) >= 2  
				/*
				nAux := MaFisRet(,"NF_BASESOL")
				MaFisAlt("NF_BASESOL",nAux - MaFisRet(Len(aItemPed),"IT_BASESOL") + NoRound(aSolid[1],2))
				nAux := MaFisRet(,"NF_VALSOL")
				MaFisAlt("NF_VALSOL",nAux - MaFisRet(Len(aItemPed),"IT_BASESOL") + NoRound(aSolid[2],2))
				*/	
				MaFisAlt("IT_BASESOL",NoRound(aSolid[1],2),Len(aItemPed))
				MaFisAlt("IT_VALSOL" ,NoRound(aSolid[2],2),Len(aItemPed))
			Endif
		Endif

		If !lQuery
			dbSelectArea(cAliasSCK)
		EndIf

		(cAliasSCK)->(dbSkip())
	EndDo
	MaFisAlt("NF_FRETE"   ,nFrete)
	MaFisAlt("NF_SEGURO"  ,nSeguro)
	MaFisAlt("NF_AUTONOMO",nFretAut)
	MaFisAlt("NF_DESPESA" ,nDespesa)

	If nDescCab > 0
		MaFisAlt("NF_DESCONTO",Min(MaFisRet(,"NF_VALMERC")-0.01,nDescCab+MaFisRet(,"NF_DESCONTO")))
	EndIf
	If nPDesCab > 0
		MaFisAlt("NF_DESCONTO",A410Arred(MaFisRet(,"NF_VALMERC")*nPDesCab/100,"CK_VALOR")+MaFisRet(,"NF_DESCONTO"))
	EndIf

	ImpCabecR4(aPedCli,oReport,aCabPed)

	oReport:Section(1):Init()
	nItem := 0
	For nG := 1 To Len(aItemPed)
		nItem += 1
		If oReport:Row() > 1500
			oReport:Section(1):Finish()
			ImpRodapR4(nPesLiq,nPesBru,aC5Rodape,.F.,oReport)
			oReport:EndPage(.T.)
			oReport:Section(1):Init()
		 	ImpCabecR4(aPedCli,oReport,aCabPed)
		Endif
		ImpItemR4(nItem,@nPesLiq,@nPesBru,oReport,oPreNota,aCabPed,aItemPed)
	Next
	oReport:Section(1):Finish()
	ImpRodapR4(nPesLiq,nPesBru,aC5Rodape,.T.,oReport)
	oReport:EndPage(.T.)		// Finaliza pagina de impressao (zeras as linhas e colunas)

	MaFisEnd()

	If !lQuery
		dbSelectArea(cAliasSCJ)
		dbSkip()
	Endif

EndDo


Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ImpCabecR4³ Autor ³ Marco Bianchi         ³ Data ³ 11/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emissao da Pr‚-Nota                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ImpCabec(void)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRFATR74                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpCabecR4(aPedCli,oReport,aCabPed)

Local nPed		:= 0
Local i         := 0
Local cMoeda	:= ""
Local cPedCli   := ""
Local cPictCgc  := ""
Local oBox
Local nPrinLin  := 0
Local nInicio   := 20
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  array acabped                                              ³
//³  -------------                                              ³
//³  01 CJ_TIPO           10 CJ_VEND3     	19 CJ_TPFRETE       ³
//³  02 CJ_CLIENTE        11 CJ_VEND4     	20 CJ_SEGURO        ³
//³  03 CJ_LOJA        12 CJ_VEND5     	21 CJ_TABELA        ³
//³  04 CJ_TRANSP         13 CJ_COMIS1    	22 CJ_VOLUME1       ³
//³  05 CJ_CONDPAG        14 CJ_COMIS2    	23 CJ_ESPECI1       ³
//³  06 CJ_EMISSAO        15 CJ_COMIS3    	24 CJ_MOEDA         ³
//³  07 CJ_NUM            16 CJ_COMIS4    	25 CJ_REAJUST       ³
//³  08 CJ_VEND1          17 CJ_COMIS5    	26 CJ_BANCO         ³
//³  09 CJ_VEND2          18 CJ_FRETE     	27 CJ_ACRSFIN       ³
//³                                         28 CJ_REDESP        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona registro no cliente do pedido                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SA1")
dbSeek(xFilial("SA1")+aCabped[2]+aCabped[3])  //CJ_CLIENTE + CJ_LOJA
cPictCgc := PesqPict("SA1","A1_CGC")	

dbSelectArea("SA4")
dbSetOrder(1)
dbSeek(xFilial("SA4")+aCabPed[4])	   				// CJ_TRANSP
dbSelectArea("SE4")
dbSetOrder(1)
dbSeek(xFilial("SE4")+aCabPed[5])	  				// CJ_CONDPAG
aSort(aPedCli)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa impressao do cabecalho                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:HideHeader()			// Nao imprime cabecalho padrao do Protheus
oReport:SkipLine()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desenha as caixas do cabecalho                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:Box(20,10,200,750,oBox)
oReport:Box(20,750,200,1800,oBox)
oReport:Box(20,1800,200,3000,oBox)

   nPrinLin := nInicio
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Informacoes do Quadro 1: Dados da Empresa                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:PrintText("",nPrinLin,10)
	oReport:PrintText(SM0->M0_NOME,nPrinLin,20)
	nPrinLin += 30
	oReport:PrintText(SM0->M0_ENDCOB,nPrinLin,20)
	nPrinLin += 30
	oReport:PrintText(STR0067+SM0->M0_TEL,nPrinLin,20)	// "TEL: "
	nPrinLin += 30
	oReport:PrintText(Iif(cPaisLoc=="BRA",STR0071,Alltrim(Posicione('SX3',2,'A1_CGC','SX3->X3_TITULO'))+":")+;	// "CGC: "
						Transform(SM0->M0_CGC,cPictCgc)+ " " +Subs(SM0->M0_CIDCOB,1,15),nPrinLin,20)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Informacoes do Quadro 2: Dados do Cliente                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   nPrinLin := nInicio
	oReport:PrintText(SA1->A1_COD+"/"+SA1->A1_LOJA+" "+SA1->A1_NOME,nPrinLin,760)	
	nPrinLin += 30
	oReport:PrintText(IF( !Empty(SA1->A1_ENDENT) .And. SA1->A1_ENDENT # SA1->A1_END,SA1->A1_ENDENT, SA1->A1_END ),nPrinLin,760)
	nPrinLin += 30
	oReport:PrintText(IF( !Empty(SA1->A1_CEPE) .And. SA1->A1_CEPE # SA1->A1_CEP,SA1->A1_CEPE, SA1->A1_CEP )+" "+;
						IF( !Empty(SA1->A1_MUNE) .And. SA1->A1_MUNE # SA1->A1_MUN,SUBSTR(SA1->A1_MUNE,1,60), SUBSTR(SA1->A1_MUN,1,60))+" "+;
						IF( !Empty(SA1->A1_ESTE) .And. SA1->A1_ESTE # SA1->A1_EST,SA1->A1_ESTE, SA1->A1_EST ),nPrinLin,760)
	nPrinLin += 30
	oReport:PrintText(subs(transform(SA1->A1_CGC,PicPesFJ(RetPessoa(SA1->A1_CGC))),1,at("%",transform(SA1->A1_CGC,PicPes(RetPessoa(SA1->A1_CGC))))-1),nPrinLin,760)
	If cPaisLoc == "BRA"	
		oReport:PrintText(STR0069+SA1->A1_INSCR,nPrinLin,1050)		// "IE: "
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Informacoes do Quadro 3: Dados do Pedido                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   nPrinLin := nInicio
	oReport:PrintText(STR0066,nPrinLin,1810)							// "CONFIRMACAO DO PEDIDO"
	nPrinLin += 60
	oReport:PrintText(STR0068+DTOC(aCabPed[6]),nPrinLin,1500)		// "EMISSAO: "
	nPrinLin += 30
	oReport:PrintText(STR0070+aCabPed[7],nPrinLin,1810)			// "PEDIDO N. "
	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pedidos do Cliente                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:SkipLine(6)
If Len(aPedCli) > 0
	oReport:PrintText("PEDIDO(S) DO CLIENTE: ",oReport:Row(),20)
	cPedCli:=""
	For nPed := 1 To Len(aPedCli)
		cPedCli += aPedCli[nPed]+Space(02)
		If Len(cPedCli) > 100 .or. nPed == Len(aPedCli)
			oReport:PrintText(cPedCli,oReport:Row(),350)
			cPedCli:=""
 		   oReport:SkipLine(2)
		Endif
	Next
	oReport:Line(oReport:Row(),10,oReport:Row()+5,3000)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Transportadora e Redespacho                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:SkipLine()
oReport:PrintText(STR0072+aCabPed[4]+" - "+SUBSTR(SA4->A4_NOME,1,40)+"    REDESPACHO...: "+Posicione("SA4", 1, xFilial("SA4")+aCabPed[28], "A4_NOME"),oReport:Row(),20)		// "TRANSP...: "		//CJ_TRANSP + CJ_REDESP

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Vendedores                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:SkipLine()
For i := 8 to 8 //12
	dbSelectArea("SA3")
	dbSetOrder(1)
	If dbSeek(xFilial("SA3")+aCabPed[i])														// CJ_VENDi
		If i == 8
			oReport:PrintText(STR0073,oReport:Row(),20)										// "VENDEDOR.: "
			//oReport:PrintText(STR0074,oReport:Row(),1000)										// "COMISSAO: "
		EndIf
		oReport:PrintText(aCabPed[i] + " - "+SA3->A3_NOME,oReport:Row(),300)
		//oReport:PrintText(Transform(aCabPed[i+5],"99.99"),oReport:Row(),1150)
		oReport:SkipLine()
	EndIf	
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Condicao de Pagto, Frete e Seguro                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:PrintText(STR0075+aCabPed[5]+" - "+SE4->E4_DESCRI,oReport:Row(),20)					// "COND.PGTO: "		//CJ_CONDPAG
oReport:PrintText(STR0076,oReport:Row(),1000)													// "FRETE...: "
oReport:PrintText(Transform(aCabPed[18],"@EZ 999,999,999.99"),oReport:Row(),1050)				// CJ_FRETE
oReport:PrintText(TipoFrete(aCabPed[19]),oReport:Row(),1300)					// CJ_TPFRETE
oReport:PrintText(STR0077,oReport:Row(),2000)													// "SEGURO: "
oReport:PrintText(Transform(aCabPed[20],"@EZ 999,999,999.99"),oReport:Row(),2050)				// CJ_SEGURO
oReport:SkipLine()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tabela, Volume e Especie                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:PrintText(STR0078+aCabPed[21],oReport:Row(),20)										// "TABELA...: "	// CJ_TABELA
oReport:PrintText(STR0079+Transform(aCabPed[22],"@EZ 999,999"),oReport:Row(),1000)				// "VOLUMES.: "		// CJ_VOLUME1s
oReport:PrintText(STR0080+aCabPed[23],oReport:Row(),2000) 										// "ESPECIE: "		// CJ_ESPECIE1
oReport:SkipLine()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Reajuste, Moeda, Banco e Acrescimo Financeiro               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMoeda:=Strzero(aCabPed[24],1,0)																// CJ_MOEDA
oReport:PrintText(STR0081+aCabPed[25]+STR0082 +IIF(cMoeda < "2","1",cMoeda),oReport:Row(),20)	// "REAJUSTE.: "###"   Moeda : " 	//CJ_REAJUST
oReport:PrintText(STR0083 + aCabPed[26],oReport:Row(),1000)				   					// "BANCO: "		//CJ_BANCO
oReport:PrintText(STR0084 + Str(aCabPed[27],6,2),oReport:Row(),2000)							// "ACRES.FIN.: "	//CJ_ACRSFIN
oReport:SkipLine()
oReport:Line(oReport:Row(),10,oReport:Row()+5,3000)

Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImpItemR4³ Autor ³ Marco Bianchi         ³ Data ³ 11/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emissao da Pr‚-Nota                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ImpItem(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRFATR74                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpItemR4(nItem,nPesLiq,nPesBru,oReport,oPreNota,aCabPed,aItemPed)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  array aitemped                                             ³
//³  --------------                                             ³
//³  01 CK_item           08 CK_prcven         15 CK_descont    ³
//³  02 CK_produto        09 CK_nota           16 CK_local      ³
//³  03 CK_descri         10 CK_serie          17 CK_qtdemp     ³
//³  04 CK_tes            11 CK_cliENTE            18 CK_qtdlib(Campo Inexistente, Cleber em 30/01/20!!!)     ³
//³  05 CK_CLASFIS             12 CK_loja           19 CK_qtdent     ³
//³  06 CK_um             13 CK_valor                           ³
//³  07 CK_qtdven         14 CK_entreg                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cChaveD2	:= ""
//Local nDecs	    := MsDecimais(Max(1,aCabPed[24]))  //CJ_MOEDA//

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SetBlock: faz com que as variaveis locais possam ser                   ³
//³ utilizadas em outras funcoes nao precisando declara-las                ³
//³ como private.                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc <> "BRA"
	oReport:Section(1):Cell("NVALIMP"):SetBlock({|| nValImp})
Else	
	oReport:Section(1):Cell("AITEM13"):SetBlock({|| aItemPed[nItem][13]+nValImp})
EndIf
oReport:Section(1):Cell("NULTLIB"):SetBlock({|| nUltLib})
nValImp := 0
nUltLib := 0
If cPaisLoc == "BRA"
	If aCabPed[1] == "P"
		nValImp := 0
	Else
		nValImp	:=	MaFisRet(nItem,"IT_VALIPI")
	Endif
Else
	nValImp	:=	MaRetIncIV(nItem,"2")
Endif

dbSelectArea("SB1")
dbSeek(xFilial("SB1")+aItemPed[nItem][2])  //CK_PRODUTO

//CK_nota CK_serie CK_cliENTE CK_loja CK_produto
cChaveD2 := xFilial("SD2")+aItemPed[nItem][09]+aItemPed[nItem][10]+aItemPed[nItem][11]+aItemPed[nItem][12]+aItemPed[nItem][02]
dbSelectArea("SD2")
dbSetOrder(3)
dbSeek(cChaveD2)
While !Eof() .and. cChaveD2 = xFilial("SD2")+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD
	nUltLib := D2_QUANT
	dbSkip()
EndDo

oReport:Section(1):PrintLine()

nTotQtd += aItemPed[nItem][07]						//CK_QTDVEN
nTotVal += aItemPed[nItem][13]+nValImp				//CK_VALOR
nPesLiq	+= SB1->B1_PESO * aItemPed[nItem][07]		//CK_QTDVEN
nPesBru += SB1->B1_PESBRU * aItemPed[nItem][07]	//CK_QTDVEN

Return (Nil)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ImpRodapR4³ Autor ³ Marco Bianchi         ³ Data ³ 11/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emissao da Pr‚-Nota                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ImpRoadpe(void)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRFATR74                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpRodapR4(nPesLiq,nPesBru,aC5Rodape,lFinal,oReport)

Local I     := 0
DEFAULT lFinal := .F.

If lFinal

	oReport:SkipLine()
	oReport:Line(oReport:Row(),10,oReport:Row(),3000)

	If cPaisLoc == 'BRA'
		oReport:SkipLine()
		oReport:PrintText(SubStr(STR0038,1,15))
		oReport:Section(2):Init()
		oReport:Section(2):PrintLine()
		oReport:Section(2):Finish()
	Else
		aCodImps	:=	{}
		aCodImps := MaFisRet(,"NF_IMPOSTOS") //Descricao / /Aliquota / Valor / Base
		oReport:Section(2):Init()
		For I:=1 To Len(aCodImps)// Vetor com os impostos
			nI := I
			oReport:Section(2):PrintLine()
		Next
		oReport:Section(2):Finish()
	Endif
Endif	

oReport:SkipLine()
oReport:PrintText(STR0100+STR(If(aC5Rodape[1][1] > 0,aC5Rodape[1][1],nPesBru)),1880,30)	// "PESO BRUTO ------>"
oReport:PrintText(STR0101+STR(If(aC5Rodape[1][2] > 0,aC5Rodape[1][2],nPesLiq)),1910,30)	// "PESO LIQUIDO ---->"
/*
oReport:PrintText(STR0102,1940,30)															// "VOLUMES --------->"
oReport:PrintText(STR0103,1970,30)															// "SEPARADO POR ---->"
oReport:PrintText(STR0104,2000,30)															// "CONFERIDO POR --->"
oReport:PrintText(STR0105,2030,30)															// "D A T A --------->"
*/
oReport:PrintText(STR0106,2090,30)															// "DESCONTOS: "
oReport:PrintText(Transform(aC5Rodape[1][3],"99.99"),2090,200)
oReport:PrintText(Transform(aC5Rodape[1][4],"99.99"),2090,300)
oReport:PrintText(Transform(aC5Rodape[1][5],"99.99"),2090,400)
oReport:PrintText(Transform(aC5Rodape[1][6],"99.99"),2090,500)

oReport:PrintText(STR0107+AllTrim(aC5Rodape[1][7]),2150,30)								// "MENSAGEM PARA NOTA FISCAL: "

Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³BRFT74R3³ Autor ³ Eduardo José Zanardo  ³ Data ³ 26.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Emissao da Pr‚-Nota                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function BRFT74R3

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define Variaveis                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local Titulo  := OemToAnsi(STR0001) //"Emissao da Confirmacao do Pedido"
Local cDesc1  := OemToAnsi(STR0002) //"Emiss„o da confirmac„o dos pedidos de venda, de acordo com"
Local cDesc2  := OemToAnsi(STR0003) //"intervalo informado na op‡„o Parƒmetros."
Local cDesc3  := " "
Local cString := "SCJ"  // Alias utilizado na Filtragem
Local lDic    := .F. // Habilita/Desabilita Dicionario
Local lComp   := .F. // Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro := .F. // Habilita/Desabilita o Filtro
Local wnrel   := "BRFATR74" // Nome do Arquivo utilizado no Spool
Local nomeprog:= "BRFATR74"
Local cPerg   := "BRFATR74"

Private Tamanho := "G" // P/M/G
Private Limite  := 220 // 80/132/220
Private aOrdem  := {}  // Ordem do Relatorio
Private aReturn := { STR0004, 1,STR0005, 2, 2, 1, "",0 } //"Zebrado"###"Administracao"
//[1] Reservado para Formulario
//[2] Reservado para N§ de Vias
//[3] Destinatario
//[4] Formato => 1-Comprimido 2-Normal
//[5] Midia   => 1-Disco 2-Impressora
//[6] Porta ou Arquivo 1-LPT1... 4-COM1...
//[7] Expressao do Filtro
//[8] Ordem a ser selecionada
//[9]..[10]..[n] Campos a Processar (se houver)

Private lEnd    := .F.// Controle de cancelamento do relatorio
Private m_pag   := 1  // Contador de Paginas
Private nLastKey:= 0  // Controla o cancelamento da SetPrint e SetDefault

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica as Perguntas Seleciondas                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ValidPerg(cPerg)
Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia para a SetPrinter                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP
	lFiltro := .F.
#ENDIF	

wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,lDic,aOrdem,lComp,Tamanho,lFiltro)
If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	dbClearFilter()
	Return
Endif
SetDefault(aReturn,cString)
If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	dbClearFilter()
	Return
Endif

RptStatus({|lEnd| C730Imp(@lEnd,wnRel,cString,nomeprog,Titulo)},Titulo)


Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ C730Imp   ³ Autor ³ Eduardo J. Zanardo   ³ Data ³26.12.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Controle de Fluxo do Relatorio.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function C730Imp(lEnd,wnrel,cString,nomeprog,Titulo)

Local aPedCli    := {}
Local aStruSCJ   := {}
Local aStruSCK   := {}
Local aC5Rodape  := {}
Local aRelImp    := MaFisRelImp("MT100",{"SF2","SD2"})
Local aFisGet    := Nil
Local aFisGetSCJ := Nil

Local li         := 100 // Contador de Linhas
//Local lImp       := .F. // Indica se algo foi impresso
Local lRodape    := .F.

//Local cbCont     := 0   // Numero de Registros Processados
//Local cbText     := ""  // Mensagem do Rodape
Local cKey 	     := ""
Local cFilter    := ""
Local cAliasSCJ  := "SCJ"
Local cAliasSCK  := "SCK"
Local cIndex     := CriaTrab(nil,.f.)
Local cQuery     := ""
Local cQryAd     := ""
Local cName      := ""
Local cPedido    := ""
Local cCliEnt	 := ""
Local cNfOri     := Nil
Local cSeriOri   := Nil

Local nItem      := 0
Local nTotQtd    := 0
Local nTotVal    := 0
Local nDesconto  := 0
Local nPesLiq    := 0
Local nSCJ       := 0
Local nSCK       := 0
Local nX         := 0
Local nRecnoSD1  := Nil
Local nG		 := 0
Local nFrete	 := 0
Local nSeguro	 := 0
Local nFretAut	 := 0
Local nDespesa	 := 0
Local nDescCab	 := 0
Local nPDesCab	 := 0
Local nY         := 0
Local nValMerc   := 0
Local nPrcLista  := 0
Local nAcresFin  := 0
Local aSolid := {}
Private aHeader := {}, aCols := {},_ALIQICM,_VALICM
Private aItemPed := {}
Private aCabPed	 := {}

FisGetInit(@aFisGet,@aFisGetSCJ)

#IFDEF TOP
	If TcSrvType() <> "AS/400"
		cAliasSCJ:= "C730Imp"
		cAliasSCK:= "C730Imp"
		lQuery    := .T.
		aStruSCJ  := SCJ->(dbStruct())		
		aStruSCK  := SCK->(dbStruct())		
		cQuery := "SELECT SCJ.R_E_C_N_O_ SCJREC,SCK.R_E_C_N_O_ SCKREC,"
		cQuery += "SCJ.CJ_FILIAL,SCJ.CJ_NUM,SCJ.CJ_CLIENTE,SCJ.CJ_LOJA,"
		cQuery += "SCJ.CJ_TRANSP,SCJ.CJ_REDESP,SCJ.CJ_DESC1,"
		cQuery += "SCJ.CJ_DESC2,SCJ.CJ_DESC3,SCJ.CJ_DESC4,SCJ.CJ_EMISSAO,"
		cQuery += "SCJ.CJ_CONDPAG,SCJ.CJ_FRETE,SCJ.CJ_DESPESA,SCJ.CJ_FRETAUT,SCJ.CJ_SEGURO,SCJ.CJ_TABELA,"
		cQuery += "SCJ.CJ_MOEDA,"
		cQuery += "SCJ.CJ_VEND1,"
		cQuery += "SCJ.CJ_PDESCAB,SCJ.CJ_DESCONT,"
		If SCJ->(FieldPos("CJ_CLIENT"))>0
			cQuery += "SCJ.CJ_CLIENT,"			
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Esta rotina foi escrita para adicionar no select os campos         ³
		//³usados no filtro do usuario quando houver, a rotina acrecenta      ³
		//³somente os campos que forem adicionados ao filtro testando         ³
		//³se os mesmo já existem no select ou se forem definidos novamente   ³
		//³pelo o usuario no filtro                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		If !Empty(aReturn[7])
			For nX := 1 To SCJ->(FCount())
				cName := SCJ->(FieldName(nX))
				If AllTrim( cName ) $ aReturn[7]
					If aStruSCJ[nX,2] <> "M"
						If !cName $ cQuery .And. !cName $ cQryAd
							cQryAd += cName +","
						Endif 	
					EndIf
				EndIf 			       	
			Next nX
		Endif
		For nY := 1 To Len(aFisGet)
			cQryAd += aFisGet[nY][2]+","
		Next nY
		For nY := 1 To Len(aFisGetSCJ)
			cQryAd += aFisGetSCJ[nY][2]+","
		Next nY		
		cQuery += cQryAd
		cQuery += "SCK.CK_FILIAL,SCK.CK_NUM,SCK.CK_PEDCLI,SCK.CK_PRODUTO,"
		cQuery += "SCK.CK_TES,SCK.CK_CLASFIS,SCK.CK_QTDVEN,SCK.CK_PRUNIT,SCK.CK_VALDESC,"
		cQuery += "SCK.CK_VALOR,SCK.CK_ITEM,SCK.CK_DESCRI,SCK.CK_UM, "
		cQuery += "SCK.CK_PRCVEN,SCJ.CJ_STATUS,SCK.CK_CLIENTE,"
		cQuery += "SCK.CK_LOJA,SCK.CK_ENTREG,SCK.CK_DESCONT,SCK.CK_LOCAL "
		cQuery += "FROM "
		cQuery += RetSqlName("SCJ") + " SCJ WITH (NOLOCK) ,"
		cQuery += RetSqlName("SCK") + " SCK WITH (NOLOCK) "		
		cQuery += "WHERE "
		cQuery += "SCJ.CJ_FILIAL = '"+xFilial("SCJ")+"' AND "		
		cQuery += "SCJ.CJ_NUM >= '"+mv_par01+"' AND "
		cQuery += "SCJ.CJ_NUM <= '"+mv_par02+"' AND "
		if mv_par03 == 1
			cQuery += "(SCJ.CJ_STATUS = 'A') AND "
		endif 
		cQuery += "SCJ.D_E_L_E_T_ = ' ' AND "
		cQuery += "SCK.CK_FILIAL = '"+xFilial("SCK")+"' AND "		
		cQuery += "SCK.CK_NUM   = SCJ.CJ_NUM AND "
		cQuery += "SCK.D_E_L_E_T_ = ' ' "
		cQuery += "ORDER BY SCJ.CJ_NUM"

		//cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSCJ,.T.,.T.)

		For nSCJ := 1 To Len(aStruSCJ)
			If aStruSCJ[nSCJ][2] <> "C" .and.  FieldPos(aStruSCJ[nSCJ][1]) > 0
				TcSetField(cAliasSCJ,aStruSCJ[nSCJ][1],aStruSCJ[nSCJ][2],aStruSCJ[nSCJ][3],aStruSCJ[nSCJ][4])
			EndIf
		Next nSCJ
		For nSCK := 1 To Len(aStruSCK)
			If aStruSCK[nSCK][2] <> "C" .and. FieldPos(aStruSCK[nSCK][1]) > 0
				TcSetField(cAliasSCK,aStruSCK[nSCK][1],aStruSCK[nSCK][2],aStruSCK[nSCK][3],aStruSCK[nSCK][4])
			EndIf
		Next nSCK		    	
	Else
#ENDIF	
	cAliasSCJ := cString
	dbSelectArea(cAliasSCJ)
	cKey := IndexKey()	
	cFilter := dbFilter()
	cFilter += If( Empty( cFilter ),""," .And. " )
	cFilter += 'CJ_FILIAL == "'+xFilial("SCJ")+'" .And. (CJ_NUM >= "'+mv_par01+'" .And. CJ_NUM <= "'+mv_par02+'")'
	if mv_par03 == 1
		cFilter += " .AND. (CJ_STATUS = 'A') "
	endif 
	IndRegua(cAliasSCJ,cIndex,cKey,,cFilter,STR0006)		//"Selecionando Registros..."
	#IFNDEF TOP
		DbSetIndex(cIndex+OrdBagExt())
	#ENDIF
	SetRegua(RecCount())		// Total de Elementos da regua
	DbGoTop()
	#IFDEF TOP
	Endif
	#ENDIF	

Aadd(aHeader,{"CK_QTDVEN","CK_QTDVEN","",0,0,"", "","","","" })
Aadd(aHeader,{"CK_PRCVEN","CK_PRCVEN","",0,0,"", "","","","" })
Aadd(aHeader,{"CK_PRODUTO","CK_PRODUTO","",0,0,"", "","","","" })
Aadd(aHeader,{"CK_TES","CK_TES","",0,0,"", "","","","" })

While !((cAliasSCJ)->(Eof())) .and. xFilial("SCJ")==(cAliasSCJ)->CJ_FILIAL

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a validacao dos filtros do usuario           	     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAliasSCJ)
	lFiltro := IIf((!Empty(aReturn[7]).And.!&(aReturn[7])),.F.,.T.)

	If lFiltro

		cCliEnt   := IIf(!Empty((cAliasSCJ)->(FieldGet(FieldPos("CJ_CLIENT")))),(cAliasSCJ)->CJ_CLIENT,(cAliasSCJ)->CJ_CLIENTE)

		aCabPed := {}

		MaFisIni(cCliEnt,;							// 1-Codigo Cliente/Fornecedor
			(cAliasSCJ)->CJ_LOJA,;			// 2-Loja do Cliente/Fornecedor
			"C",;	// 3-C:Cliente , F:Fornecedor
			"N",;				// 4-Tipo da NF
			Posicione("SA1", 1, xFilial("SA1")+(cAliasSCJ)->CJ_CLIENTE, "A1_TIPO"),;			// 5-Tipo do Cliente/Fornecedor
			aRelImp,;							// 6-Relacao de Impostos que suportados no arquivo
			,;						   			// 7-Tipo de complemento
			,;									// 8-Permite Incluir Impostos no Rodape .T./.F.
			"SB1",;							// 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
			"MATA461")							// 10-Nome da rotina que esta utilizando a funcao
		//Na argentina o calculo de impostos depende da serie.
		If cPaisLoc == 'ARG'
			SA1->(DbSetOrder(1))
			SA1->(MsSeek(xFilial()+(cAliasSCJ)->CJ_CLIENTE+(cAliasSCJ)->CJ_LOJA))
			MaFisAlt('NF_SERIENF',LocXTipSer('SA1',MVNOTAFIS))
		Endif

		nFrete		:= (cAliasSCJ)->CJ_FRETE
		nSeguro		:= (cAliasSCJ)->CJ_SEGURO
		nFretAut	:= (cAliasSCJ)->CJ_FRETAUT
		nDespesa	:= (cAliasSCJ)->CJ_DESPESA
		nDescCab	:= (cAliasSCJ)->CJ_DESCONT
		nPDesCab	:= (cAliasSCJ)->CJ_PDESCAB

		aItemPed:= {}
		aCabPed := {	"N",;
			(cAliasSCJ)->CJ_CLIENTE,;
			(cAliasSCJ)->CJ_LOJA,;
			(cAliasSCJ)->CJ_TRANSP,;
			(cAliasSCJ)->CJ_CONDPAG,;
			(cAliasSCJ)->CJ_EMISSAO,;
			(cAliasSCJ)->CJ_NUM,;
			(cAliasSCJ)->CJ_VEND1,;
			"",;
			"",;
			"",;
			"",;
			0,;
			0,;
			0,;
			0,;
			0,;
			(cAliasSCJ)->CJ_FRETE,;
			"F",;
			(cAliasSCJ)->CJ_SEGURO,;
			(cAliasSCJ)->CJ_TABELA,;
			-1,;
			"",;
			(cAliasSCJ)->CJ_MOEDA,;
			"",;
			"",;
			0,;
			(cAliasSCJ)->CJ_REDESP;
			}
		nTotQtd:=0
		nTotVal:=0
		nPesBru:=0
		nPesLiq:=0
		aPedCli:= {}
		If !lQuery
			dbSelectArea(cAliasSCK)
			dbSetOrder(1)
			dbSeek(xFilial("SCK")+(cAliasSCJ)->CJ_NUM)
		EndIf
		cPedido    := (cAliasSCJ)->CJ_NUM
		aC5Rodape  := {}
		aadd(aC5Rodape,{0,0,(cAliasSCJ)->CJ_DESC1,(cAliasSCJ)->CJ_DESC2,;
			(cAliasSCJ)->CJ_DESC3,(cAliasSCJ)->CJ_DESC4,""})

		aPedCli := Mtr730Cli(cPedido)


		dbSelectArea(cAliasSCJ)
		For nY := 1 to Len(aFisGetSCJ)
			If !Empty(&(aFisGetSCJ[ny][2]))
				If aFisGetSCJ[ny][1] == "NF_SUFRAMA"
					MaFisAlt(aFisGetSCJ[ny][1],Iif(&(aFisGetSCJ[ny][2]) == "1",.T.,.F.),Len(aItemPed),.T.)		
				Else
					MaFisAlt(aFisGetSCJ[ny][1],&(aFisGetSCJ[ny][2]),Len(aItemPed),.T.)
				Endif	
			EndIf
		Next nY


		While !((cAliasSCK)->(Eof())) .And. xFilial("SCK")==(cAliasSCK)->CK_FILIAL .And.;
				(cAliasSCK)->CK_NUM == cPedido

			cNfOri     := Nil
			cSeriOri   := Nil
			nRecnoSD1  := Nil
			nDesconto  := 0

			dbSelectArea(cAliasSCK)

			If lEnd
				@ Prow()+1,001 PSAY STR0007 //"CANCELADO PELO OPERADOR"
				Exit
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calcula o preco de lista                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nValMerc  := (cAliasSCK)->CK_VALOR
			nPrcLista := (cAliasSCK)->CK_PRUNIT
			If ( nPrcLista == 0 )
				nPrcLista := NoRound(nValMerc/(cAliasSCK)->CK_QTDVEN,TamSX3("CK_PRCVEN")[2])
			EndIf
			nAcresFin := A410Arred((cAliasSCK)->CK_PRCVEN*0/100,"D2_PRCVEN")
			nValMerc  += A410Arred((cAliasSCK)->CK_QTDVEN*nAcresFin,"D2_TOTAL")		
			nDesconto := a410Arred(nPrcLista*(cAliasSCK)->CK_QTDVEN,"D2_DESCON")-nValMerc
			nDesconto := IIf(nDesconto==0,(cAliasSCK)->CK_VALDESC,nDesconto)
			nDesconto := Max(0,nDesconto)
			nPrcLista += nAcresFin
			If cPaisLoc=="BRA"
				nValMerc  += nDesconto
			EndIf			
						
			MaFisAdd((cAliasSCK)->CK_PRODUTO,; 	  // 1-Codigo do Produto ( Obrigatorio )
				(cAliasSCK)->CK_TES,;			  // 2-Codigo do TES ( Opcional )
				(cAliasSCK)->CK_QTDVEN,;		  // 3-Quantidade ( Obrigatorio )
				nPrcLista,;		  // 4-Preco Unitario ( Obrigatorio )
				nDesconto,;       // 5-Valor do Desconto ( Opcional )
				cNfOri,;		                  // 6-Numero da NF Original ( Devolucao/Benef )
				cSeriOri,;		                  // 7-Serie da NF Original ( Devolucao/Benef )
				nRecnoSD1,;			          // 8-RecNo da NF Original no arq SD1/SD2
				0,;							  // 9-Valor do Frete do Item ( Opcional )
				0,;							  // 10-Valor da Despesa do item ( Opcional )
				0,;            				  // 11-Valor do Seguro do item ( Opcional )
				0,;							  // 12-Valor do Frete Autonomo ( Opcional )
				nValMerc,;// 13-Valor da Mercadoria ( Obrigatorio )
				0,;							  // 14-Valor da Embalagem ( Opiconal )
				0,;		     				  // 15-RecNo do SB1
				0) 							  // 16-RecNo do SF4

			aadd(aItemPed,	{	(cAliasSCK)->CK_ITEM,;
				(cAliasSCK)->CK_PRODUTO,;
				(cAliasSCK)->CK_DESCRI,;
				(cAliasSCK)->CK_TES,;
				(cAliasSCK)->CK_CLASFIS,;
				(cAliasSCK)->CK_UM,;
				(cAliasSCK)->CK_QTDVEN,;
				(cAliasSCK)->CK_PRCVEN,;
				"",;
				"",;
				(cAliasSCK)->CK_CLIENTE,;
				(cAliasSCK)->CK_LOJA,;
				(cAliasSCK)->CK_VALOR,;
				(cAliasSCK)->CK_ENTREG,;
				(cAliasSCK)->CK_DESCONT,;
				(cAliasSCK)->CK_LOCAL,;
				0,;
				0,;
				0,;
				})							
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Forca os valores de impostos que foram informados no SCK.              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea(cAliasSCK)
			For nY := 1 to Len(aFisGet)
				If !Empty(&(aFisGet[ny][2]))
					MaFisAlt(aFisGet[ny][1],&(aFisGet[ny][2]),Len(aItemPed))
				EndIf
			Next nY
/*
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calculo do ISS                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SF4->(dbSetOrder(1))
			SF4->(MsSeek(xFilial("SF4")+(cAliasSCK)->CK_TES))
			If ( (cAliasSCJ)->CJ_INCISS == "N" )
				If ( SF4->F4_ISS=="S" )
					nPrcLista := a410Arred(nPrcLista/(1-(MaAliqISS(Len(aItemPed))/100)),"D2_PRCVEN")
					nValMerc  := a410Arred(nValMerc/(1-(MaAliqISS(Len(aItemPed))/100)),"D2_PRCVEN")
					MaFisAlt("IT_PRCUNI",nPrcLista,Len(aItemPed))
					MaFisAlt("IT_VALMERC",nValMerc,Len(aItemPed))
				EndIf
			EndIf	
*/			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Altera peso para calcular frete              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SB1->(dbSetOrder(1))
			SB1->(MsSeek(xFilial("SB1")+(cAliasSCK)->CK_PRODUTO))			
			MaFisAlt("IT_PESO",(cAliasSCK)->CK_QTDVEN*SB1->B1_PESO,Len(aItemPed))
			MaFisAlt("IT_PRCUNI",nPrcLista,Len(aItemPed))
			MaFisAlt("IT_VALMERC",nValMerc,Len(aItemPed))
			

	        DbSelectArea("SA1")
    	    dbsetorder(1)
   	    	DbSeek(xFilial("SA1")+(cAliasSCJ)->CJ_CLIENTE)


			Aadd(aCols,Array(len(aHeader)+1))
			aCols[Len(aItemPed)][len(aHeader)+1] := .F.
			aCols[Len(aItemPed),1] := (cAliasSCK)->CK_QTDVEN
			aCols[Len(aItemPed),2] := (cAliasSCK)->CK_PRCVEN
			aCols[Len(aItemPed),3] := (cAliasSCK)->CK_PRODUTO
			aCols[Len(aItemPed),4] := (cAliasSCK)->CK_TES
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pontos de Entrada 								     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//If (ExistBlock("M415ICM")) release 12.1.25
			If lM415ICM
				_ALIQICM    := MaFisRet(Len(aItemPed),"IT_ALIQICM")
				_VALICM    := MaFisRet(Len(aItemPed),"IT_VALICM")
				ExecBlock("M415ICM",.F.,.F.,{Len(aItemPed)})
				MaFisAlt("IT_ALIQICM",_ALIQICM,Len(aItemPed))
				MaFisAlt("IT_VALICM",_VALICM,Len(aItemPed))
			endif 


			aSolid := {}
			If (ExistTemplate("M415SOLI"))
				aSolid := ExecTemplate("M415SOLI",.F.,.F.,{Len(aItemPed)})
			Endif
			//If (ExistBlock("M415SOLI")) release 12.1.25
			If lM415SOL
				aSolid := ExecBlock("M415SOLI",.F.,.F.,{Len(aItemPed)}) 
			Endif
			IF ValType(aSolid) == "A"
				IF Len(aSolid) == 2  
					MaFisAlt("IT_BASESOL",NoRound(aSolid[1],2),Len(aItemPed))
					MaFisAlt("IT_VALSOL" ,NoRound(aSolid[2],2),Len(aItemPed))
				Endif
			Endif

			If !lQuery
				dbSelectArea(cAliasSCK)
			EndIf

			(cAliasSCK)->(dbSkip())
		EndDo
		
		MaFisAlt("NF_FRETE"   ,nFrete)
		MaFisAlt("NF_SEGURO"  ,nSeguro)
		MaFisAlt("NF_AUTONOMO",nFretAut)
		MaFisAlt("NF_DESPESA" ,nDespesa)

		If nDescCab > 0
			MaFisAlt("NF_DESCONTO",Min(MaFisRet(,"NF_VALMERC")-0.01,nDescCab+MaFisRet(,"NF_DESCONTO")))
		EndIf
		If nPDesCab > 0
			MaFisAlt("NF_DESCONTO",A410Arred(MaFisRet(,"NF_VALMERC")*nPDesCab/100,"CK_VALOR")+MaFisRet(,"NF_DESCONTO"))
		EndIf

		nItem := 0
		For nG := 1 To Len(aItemPed)
			nItem += 1
			IF li > 45
				IF lRodape
					ImpRodape(nPesLiq,nTotQtd,nTotVal,@li,nPesBru,aC5Rodape,cAliasSCJ,,cAliasSCK)
				Endif
				li := 0
				lRodape := ImpCabec(@li,aPedCli,cAliasSCJ)
			Endif
			ImpItem(nItem,@nPesLiq,@li,@nTotQtd,@nTotVal,@nPesBru,cAliasSCK,cAliasSCJ)
			li++
		Next

		IF lRodape
			ImpRodape(nPesLiq,nTotQtd,nTotVal,@li,nPesBru,aC5Rodape,cAliasSCJ,.T.,cAliasSCK)
			lRodape:=.F.
		Endif

		MaFisEnd()

		If !lQuery
			IncRegua()
			dbSelectArea(cAliasSCJ)
			dbSkip()
		Endif

	Else
		dbSelectArea(cAliasSCJ)
		dbSkip()
	EndIf

EndDo

If lQuery
	dbSelectArea(cAliasSCJ)
	dbCloseArea()
Endif	

Set Device To Screen
Set Printer To

RetIndex("SCJ")
dbSelectArea("SCJ")
dbClearFilter()

Ferase(cIndex+OrdBagExt())

dbSelectArea("SCK")
dbClearFilter()
dbSetOrder(1)
dbGotop()

If ( aReturn[5] = 1 )
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()
Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImpItem  ³ Autor ³ Claudinei M. Benzi    ³ Data ³ 05.11.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emissao da Pr‚-Nota                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ImpItem(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRFATR74                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpItem(nItem,nPesLiq,li,nTotQtd,nTotVal,nPesBru,cAliasSCK,cAliasSCJ)
/*
01 CK_item
02 CK_produto
03 CK_descri
04 CK_tes
05 CK_CLASFIS
06 CK_um
07 CK_qtdven
08 CK_prcven
09 CK_nota
10 CK_serie
11 CK_cliENTE
12 CK_loja
13 CK_valor
14 CK_entreg
15 CK_descont
16 CK_local
17 CK_qtdemp
18 CK_qtdlib ->Campo Inexistente!!! (Cleber 30/01/20)
19 CK_qtdent
*/
Local nUltLib  := 0
Local cChaveD2 := ""
Local nDecs	:=	MsDecimais(Max(1,aCabPed[24]))  //CJ_MOEDA
Local nValImp	:=0
dbSelectArea("SB1")
dbSeek(xFilial("SB1")+aItemPed[nItem][2])  //CK_PRODUTO

@li,000 psay aItemPed[nItem][01]	//CK_ITEM
@li,003 psay aItemPed[nItem][02]	//CK_PRODUTO
@li,019 psay SUBS(IIF(Empty(aItemPed[nItem][03]),SB1->B1_DESC, aItemPed[nItem][03]),1,35)		//CK_DESCRI
@li,055 psay aItemPed[nItem][04]	//CK_TES
@li,059 psay aItemPed[nItem][05]	//CK_CLASFIS
@li,064 psay aItemPed[nItem][06]	//CK_UM
@li,067 psay aItemPed[nItem][07] Picture "@E 99999"	//CK_QTDVEN
@li,072 psay aItemPed[nItem][08] Picture  "@E 9,999,999.9999"	//CK_PRCVEN

If cPaisLoc == "BRA"
	If aCabPed[1] == "P"
		nValImp := 0
	Else
		nValImp	:=	MaFisRet(nItem,"IT_VALIPI")
	Endif
	@li,089 psay MaFisRet(nItem,"IT_ALIQIPI") Picture "@e 99.99"
Else
	nValImp	:=	MaRetIncIV(nItem,"2")
	@li,089 psay  nValImp	Picture Tm(nValImp,10,nDecs)
Endif
         

If ( cPaisLoc=="BRA" )
	@li,095 psay MaFisRet(nItem,"IT_ALIQICM") Picture "@e 99.99" //Aliq de ICMS
	@li,101 psay MaFisRet(nItem,"IT_ALIQISS") Picture "@e 99.99" //Aliq de ISS	
EndIf
//CK_nota CK_serie CK_cliENTE CK_loja CK_produto
cChaveD2 := xFilial("SD2")+aItemPed[nItem][09]+aItemPed[nItem][10]+aItemPed[nItem][11]+aItemPed[nItem][12]+aItemPed[nItem][02]
dbSelectArea("SD2")
dbSetOrder(3)
dbSeek(cChaveD2)
While !Eof() .and. cChaveD2 = xFilial("SD2")+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD
	nUltLib := D2_QUANT
	dbSkip()
EndDo

@li,106   psay aItemPed[nItem][13]+nValImp Picture PesqPict("SCK","CK_VALOR",16,nDecs)		//CK_VALOR
//@li,123   psay aItemPed[nItem][14]		//CK_ENTREG
//@li,133   psay aItemPed[nItem][15]    Picture "99.9"  //CK_DESCONT
//@li,139   psay aItemPed[nItem][16]		//CK_LOCAL
//@li,141   psay aItemPed[nItem][17] Picture PesqPictQt("CK_QTDLIB")		//CK_QTDEMP
//CK_QTDVEN CK_QTDEMP CK_QTDLIB CK_QTDENT
//@li,155   psay aItemPed[nItem][07] - aItemPed[nItem][17] + aItemPed[nItem][18] - aItemPed[nItem][19] Picture PesqPictQt("CK_QTDLIB")
//@li,169   psay nUltLib Picture PesqPictQt("D2_QUANT")

nTotQtd += aItemPed[nItem][07]						//CK_QTDVEN
nTotVal += aItemPed[nItem][13]+nValImp				//CK_VALOR
nPesLiq	+= SB1->B1_PESO * aItemPed[nItem][07]		//CK_QTDVEN
nPesBru += SB1->B1_PESBRU * aItemPed[nItem][07]	//CK_QTDVEN
Return (Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImpRodape³ Autor ³ Claudinei M. Benzi    ³ Data ³ 05.11.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emissao da Pr‚-Nota                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ImpRoadpe(void)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRFATR74                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpRodape(nPesLiq,nTotQtd,nTotVal,li,nPesBru,aC5Rodape,cAliasSCJ,lFinal,cAliasSCK)
Local aCodImps	:=	{}
Local I     := 0

DEFAULT lFinal := .F.

@ li,000 psay Replicate("-",limite-37)
li++
@ li,000 psay STR0029	//" T O T A I S "
@ li,061 psay nTotQtd    Picture PesqPict("SCK","CK_QTDVEN",20)
@ li,105 psay nTotVal    Picture PesqPict("SCK","CK_VALOR",17)
If lFinal
	li++
	@ li,000 psay Replicate("-",limite-37)
	If cPaisLoc == 'BRA'
		li++
		@ li,000 psay STR0038
		@ li,026 PSay STR0039
		@ li,046 PSay STR0040
		@ li,067 PSay STR0041
		@ li,087 PSay STR0042
		@ li,107 PSay STR0043
		@ li,128 PSay STR0044
		@ li,149 PSay STR0045	
		li++
		@ li,022 PSay Transform(MaFisRet(,"NF_BASEICM"),PesqPict("SF2","F2_BASEICM"))
		@ li,042 PSay Transform(MaFisRet(,"NF_VALICM") ,PesqPict("SF2","F2_VALICM") )
		@ li,062 PSay Transform(MaFisRet(,"NF_BASEIPI"),PesqPict("SF2","F2_BASEIPI"))
		@ li,083 PSay Transform(MaFisRet(,"NF_VALIPI") ,PesqPict("SF2","F2_VALIPI") )
		@ li,105 PSay Transform(MaFisRet(,"NF_BASESOL"),PesqPict("SF2","F2_ICMSRET"))
		@ li,127 PSay Transform(MaFisRet(,"NF_VALSOL") ,PesqPict("SF2","F2_VALBRUT"))
		@ li,147 PSay Transform(MaFisRet(,"NF_TOTAL")  ,PesqPict("SF2","F2_VALBRUT"))
		li++                                                                            	
		@ li,026 psay STR0046
		@ li,046 PSay STR0047
		li++                                                                            		
		@ li,022 PSay Transform(MaFisRet(,"NF_BASEISS"),PesqPict("SF2","F2_BASEISS"))
		@ li,042 PSay Transform(MaFisRet(,"NF_VALISS") ,PesqPict("SF2","F2_VALISS") )
	Else

		aCodImps := MaFisRet(,"NF_IMPOSTOS") //Descricao / /Aliquota / Valor / Base
		li++
		@ li,000 psay STR0038
		@ li,025 PSay STR0049 //"Imposto                                 Base      Aliquota         Valor"
		li++         			
		@ li,025 PSay           "------------------------------ ------------- ------------- -------------"
		li++
		For I:=1 To Len(aCodImps)// Vetor com os impostos
			@ li,25 PSay aCodImps[I][2]
			@ li,57 PSay aCodImps[I][3] Picture TM(aCodImps[I][4],12,MsDecimais(1))
			@ li,71 PSay aCodImps[I][4] Picture TM(aCodImps[I][4],12,MsDecimais(1))
			@ li,85 PSay aCodImps[I][5] Picture TM(aCodImps[I][4],12,MsDecimais(1))
			li++
		Next

	Endif
Endif	

@ 51,005 psay STR0030+STR(If(aC5Rodape[1][1] > 0,aC5Rodape[1][1],nPesBru))	//"PESO BRUTO ------>"
@ 52,005 psay STR0031+STR(If(aC5Rodape[1][2] > 0,aC5Rodape[1][2] ,nPesLiq))	//"PESO LIQUIDO ---->"
/*
@ 53,005 psay STR0032	//"VOLUMES --------->"
@ 54,005 psay STR0033	//"SEPARADO POR ---->"
@ 55,005 psay STR0034	//"CONFERIDO POR --->"
@ 56,005 psay STR0035	//"D A T A --------->"
*/
@ 58,000 psay STR0036	//"DESCONTOS: "
@ 58,011 psay aC5Rodape[1][3] Picture "99.99"
@ 58,019 psay aC5Rodape[1][4] picture "99.99"
@ 58,027 psay aC5Rodape[1][5] picture "99.99"
@ 58,035 psay aC5Rodape[1][6] picture "99.99"

@ 60,000 psay STR0037+AllTrim(aC5Rodape[1][7])			//"MENSAGEM PARA NOTA FISCAL: "
@ 61,000 psay ""

li := 80

Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImpCabec ³ Autor ³ Claudinei M. Benzi    ³ Data ³ 05.11.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emissao da Pr‚-Nota                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ImpCabec(void)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRFATR74                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpCabec(li,aPedCli,cAliasSCJ)

Local cHeader	:= ""
Local nPed		:= 0
Local i         := 0
Local cMoeda	:= ""
Local cPedCli   := ""
Local cPictCgc  := ""
If cPaisLoc == "BRA"
//	cHeader := STR0008	// It Codigo          Desc. do Material              TES CF   UM        Quant.  Valor Unit. IPI   ICMS   ISS     Vl.Tot.C/IPI Entrega   Desc Loc.    Qtd.a Fat         Saldo      Ult.Fat.
	cHeader := 			  'It Codigo          Desc. do Material                   TES CF   UM   Quant.  Valor Unit. IPI   ICMS   ISS     Vl.Tot.C/IPI															  '
                                                                                                                                                     
		//          		   0         1         2         3         4         5         6         7         8         9        10        11        12        13        14
	//                     0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234
Else
	cHeader := STR0048	//"It Codigo          Desc de Material                    TES CF   UM   Quant.  Valor Unit.        Imp.Inc.       Valor Total Entrega   Desc Loc.      Ctd.Ent         Saldo     Ult.Entr."
	//        			   0         1         2         3         4         5         6         7         8         9        10        11        12        13        14
	//                     0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234
Endif

/* array acabped
01 CJ_TIPO
02 CJ_CLIENTE
03 CJ_LOJA
04 CJ_TRANSP
05 CJ_CONDPAG
06 CJ_EMISSAO
07 CJ_NUM
08 CJ_VEND1
09 CJ_VEND2
10 CJ_VEND3
11 CJ_VEND4
12 CJ_VEND5
13 CJ_COMIS1
14 CJ_COMIS2
15 CJ_COMIS3
16 CJ_COMIS4
17 CJ_COMIS5
18 CJ_FRETE
19 CJ_TPFRETE
20 CJ_SEGURO
21 CJ_TABELA
22 CJ_VOLUME1
23 CJ_ESPECI1
24 CJ_MOEDA
25 CJ_REAJUST
26 CJ_BANCO
27 CJ_ACRSFIN
28 CJ_REDESP
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona registro no cliente do pedido                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	dbSelectArea("SA1")
	dbSeek(xFilial("SA1")+aCabped[2]+aCabped[3])  //CJ_CLIENTE + CJ_LOJA
	cPictCgc := PesqPict("SA1","A1_CGC")	

dbSelectArea("SA4")
dbSetOrder(1)
dbSeek(xFilial("SA4")+aCabPed[4])		//CJ_TRANSP
dbSelectArea("SE4")
dbSetOrder(1)
dbSeek(xFilial("SE4")+aCabPed[5])		//CJ_CONDPAG

aSort(aPedCli)
@ 00,000 psay AvalImp(limite)
@ 01,000 psay Replicate("-",limite-37)
@ 02,000 psay SM0->M0_NOME
@ 02,041 psay "| "+Left(SA1->A1_COD+"/"+SA1->A1_LOJA+" "+SA1->A1_NOME, 56)
@ 02,100 psay STR0009		//"| CONFIRMACAO DO PEDIDO "
@ 03,000 psay SM0->M0_ENDCOB
@ 03,041 psay "| "+IF( !Empty(SA1->A1_ENDENT) .And. SA1->A1_ENDENT # SA1->A1_END,SA1->A1_ENDENT, SA1->A1_END )
@ 03,100 psay "|"
@ 04,000 psay STR0010+SM0->M0_TEL			//"TEL: "
@ 04,041 psay "| "
@ 04,043 psay IF( !Empty(SA1->A1_CEPE) .And. SA1->A1_CEPE # SA1->A1_CEP,SA1->A1_CEPE, SA1->A1_CEP )
@ 04,053 psay ALLTRIM(IF( !Empty(SA1->A1_MUNE) .And. SA1->A1_MUNE # SA1->A1_MUN,SA1->A1_MUNE, SA1->A1_MUN ))
@ 04,114 psay IF( !Empty(SA1->A1_ESTE) .And. SA1->A1_ESTE # SA1->A1_EST,SA1->A1_ESTE, SA1->A1_EST )
@ 04,117 psay "| EMISSAO: "
@ 04,128 psay aCabPed[6]	//CJ_EMISSAO
@ 05,000 psay Iif(cPaisLoc=="BRA",STR0012,Alltrim(Posicione('SX3',2,'A1_CGC','SX3->X3_TITULO'))+":")		//"CGC: "
@ 05,006 psay SM0->M0_CGC    Picture cPictCGC //"@R 99.999.999/9999-99"
@ 05,025 psay Subs(SM0->M0_CIDCOB,1,15)
@ 05,041 psay "|"
@ 05,043 psay subs(transform(SA1->A1_CGC,PicPes(RetPessoa(SA1->A1_CGC))),1,at("%",transform(SA1->A1_CGC,PicPes(RetPessoa(SA1->A1_CGC))))-1)
If cPaisLoc == "BRA"	
	@ 05,062 psay STR0013+SA1->A1_INSCR			//"IE: "
Endif
@ 05,100 psay STR0014+aCabPed[7]			//"| PEDIDO N. "	//CJ_NUM
li:= 6
If Len(aPedCli) > 0
	@ li,000 psay Replicate("-",limite-37)
	li++
	@ li,000 psay "ORÇAMENTO(S) DO CLIENTE:"
	cPedCli:=""
	For nPed := 1 To Len(aPedCli)
		cPedCli += aPedCli[nPed]+Space(02)
		If Len(cPedCli) > 100 .or. nPed == Len(aPedCli)
			@ li,23 psay cPedCli
			cPedCli:=""
			li++
		Endif
	Next
Endif
@ li,000 psay Replicate("-",limite-37)
li++
@ li,000 psay STR0016+aCabPed[4]+" - "+SUBSTR(SA4->A4_NOME,1,39)+"    REDESPACHO...: "+Posicione("SA4", 1, xFilial("SA4")+aCabPed[28], "A4_NOME")			//"TRANSP...: "		//CJ_TRANSP
li++

For i := 8 to 8 //12
	dbSelectArea("SA3")
	dbSetOrder(1)
	If dbSeek(xFilial("SA3")+aCabPed[i])	//CJ_VENDi
		If i == 8
			@ li,000 psay STR0017		//"VENDEDOR.: "
		EndIf
		@ li,013 psay aCabPed[i] + " - "+SA3->A3_NOME	//CJ_VENDi
		If i == 8
			//@ li,065 psay STR0018		//"COMISSAO: "
		EndIf
		//@ li,075 psay aCabPed[i+5] Picture "99.99"		//CJ_COMISi+5
		li++
	EndIf	
Next

@ li,000 psay STR0019+aCabPed[5]+" - "+SE4->E4_DESCRI			//"COND.PGTO: "		//CJ_CONDPAG
@ li,065 psay STR0020		//"FRETE...: "
@ li,075 psay aCabPed[18] Picture "@EZ 999,999,999.99"		//CJ_FRETE
@ li,090 psay Iif(!Empty(TipoFrete(aCabPed[19])),TipoFrete(aCabPed[19]),'(FOB)')		//CJ_TPFRETE
@ li,100 psay STR0021		//"SEGURO: "
@ li,108 psay aCabPed[20] Picture "@EZ 999,999,999.99"		//CJ_SEGURO
li++
@ li,000 psay STR0022+aCabPed[21]		//"TABELA...: "		//CJ_TABELA
@ li,065 psay STR0023		//"VOLUMES.: "
@ li,075 psay aCabPed[22]    Picture "@EZ 999,999"		//CJ_VOLUME1s
@ li,100 psay STR0024+aCabPed[23]		//"ESPECIE: "	//CJ_ESPECIE1
li++
cMoeda:=Strzero(aCabPed[24],1,0)		//CJ_MOEDA
@ li,000 psay STR0025+aCabPed[25]+STR0026 +IIF(cMoeda < "2","1",cMoeda)		//"REAJUSTE.: "###"   Moeda : " 	//CJ_REAJUST
@ li,065 psay STR0027 + aCabPed[26]					//"BANCO: "		//CJ_BANCO
@ li,100 psay STR0028+Str(aCabPed[27],6,2)		//"ACRES.FIN.: "	//CJ_ACRSFIN
li++
@ li,000 psay Replicate("-",limite-37)
li++
@ li,000 psay cHeader
li++
@ li,000 psay Replicate("-",limite-37)
li++

Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Mtr730Cli ³ Autor ³ Henry Fila            ³ Data ³ 26.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função que retorna os pedidos do cliente                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Mtr730Cli(cPedido)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Numero do pedido                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRFATR74                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Mtr730Cli(cPedido)

Local aPedidos := {}
Local aArea    := GetArea()
Local aAreaSCK := SCK->(GetArea())

SCK->(dbSetOrder(1))
SCK->(MsSeek(xFilial("SCK")+cPedido))

While !(SCK->(Eof())) .And. xFilial("SCK")==SCK->CK_FILIAL .And.;
		SCK->CK_NUM == cPedido

	If !Empty(SCK->CK_PEDCLI) .and. Ascan(aPedidos,SCK->CK_PEDCLI) = 0
		Aadd(aPedidos, SCK->CK_PEDCLI )
	Endif		

	SCK->(dbSkip())
Enddo

RestArea(aAreaSCK)
RestArea(aArea)

Return(aPedidos)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FisGetInit³ Autor ³Eduardo Riera          ³ Data ³17.11.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inicializa as variaveis utilizadas no Programa              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function FisGetInit(aFisGet,aFisGetSCJ)

Local cValid      := ""
Local cReferencia := ""
Local nPosIni     := 0
Local nLen        := 0
Local _lOpen      := .F. // Adequação para release 12.1.25
Local _cAliasSX3  := GetNextAlias() // Adequação para release 12.1.25


If aFisGet == Nil

    // ABERTURA DO DICIONÁRIO SX3 - Adequação para release 12.1.25
    OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
    _lOpen := Select( _cAliasSX3 ) > 0
    
	aFisGet	:= {}

/* release 12.1.25
	dbSelectArea("SX3")
	dbSetOrder(1)
	MsSeek("SCK")
	While !Eof().And.X3_ARQUIVO=="SCK"
		cValid := UPPER(X3_VALID+X3_VLDUSER)
		If 'MAFISGET("'$cValid
			nPosIni 	:= AT('MAFISGET("',cValid)+10
			nLen		:= AT('")',Substr(cValid,nPosIni,Len(cValid)-nPosIni))-1
			cReferencia := Substr(cValid,nPosIni,nLen)
			aAdd(aFisGet,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
		EndIf
		If 'MAFISREF("'$cValid
			nPosIni		:= AT('MAFISREF("',cValid) + 10
			cReferencia	:=Substr(cValid,nPosIni,AT('","MT410",',cValid)-nPosIni)
			aAdd(aFisGet,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
		EndIf
		dbSkip()
	EndDo
*/
    DbSelectArea( _cAliasSX3 )
    ( _cAliasSX3 )->( DbSetOrder(1) )
    ( _cAliasSX3 )->( DbSeek("SCK") )
    While !Eof() .and. ( _cAliasSX3 )->( X3_ARQUIVO ) == "SCK"
		cValid := UPPER(( _cAliasSX3 )->(X3_VALID)+( _cAliasSX3 )->(X3_VLDUSER))
		If 'MAFISGET("'$cValid
			nPosIni 	:= AT('MAFISGET("',cValid)+10
			nLen		:= AT('")',Substr(cValid,nPosIni,Len(cValid)-nPosIni))-1
			cReferencia := Substr(cValid,nPosIni,nLen)
			aAdd(aFisGet,{cReferencia,( _cAliasSX3 )->(X3_CAMPO),MaFisOrdem(cReferencia)})
		EndIf
		If 'MAFISREF("'$cValid
			nPosIni		:= AT('MAFISREF("',cValid) + 10
			cReferencia	:=Substr(cValid,nPosIni,AT('","MT410",',cValid)-nPosIni)
			aAdd(aFisGet,{cReferencia,( _cAliasSX3 )->(X3_CAMPO),MaFisOrdem(cReferencia)})
		EndIf
		dbSkip()
    EndDo       

	aSort(aFisGet,,,{|x,y| x[3]<y[3]})

    DbSelectArea( _cAliasSX3 )
    DbCloseArea()

EndIf

If aFisGetSCJ == Nil

    // ABERTURA DO DICIONÁRIO SX3 - Adequação para release 12.1.25
    OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
    _lOpen := Select( _cAliasSX3 ) > 0

	
	aFisGetSCJ	:= {}

	/* release 12.1.25
	dbSelectArea("SX3")
	dbSetOrder(1)
	MsSeek("SCJ")
	While !Eof().And.X3_ARQUIVO=="SCJ"
		cValid := UPPER(X3_VALID+X3_VLDUSER)
		If 'MAFISGET("'$cValid
			nPosIni 	:= AT('MAFISGET("',cValid)+10
			nLen		:= AT('")',Substr(cValid,nPosIni,Len(cValid)-nPosIni))-1
			cReferencia := Substr(cValid,nPosIni,nLen)
			aAdd(aFisGetSCJ,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
		EndIf
		If 'MAFISREF("'$cValid
			nPosIni		:= AT('MAFISREF("',cValid) + 10
			cReferencia	:=Substr(cValid,nPosIni,AT('","MT410",',cValid)-nPosIni)
			aAdd(aFisGetSCJ,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
		EndIf
		dbSkip()
	EndDo
	*/
	
	DbSelectArea( _cAliasSX3 )
    ( _cAliasSX3 )->( DbSetOrder(1) )
    ( _cAliasSX3 )->( DbSeek("SCJ") )
    While !Eof() .and. ( _cAliasSX3 )->( X3_ARQUIVO ) == "SCJ"

		cValid := UPPER(( _cAliasSX3 )->(X3_VALID)+( _cAliasSX3 )->(X3_VLDUSER))
		If 'MAFISGET("'$cValid
			nPosIni 	:= AT('MAFISGET("',cValid)+10
			nLen		:= AT('")',Substr(cValid,nPosIni,Len(cValid)-nPosIni))-1
			cReferencia := Substr(cValid,nPosIni,nLen)
			aAdd(aFisGetSCJ,{cReferencia,( _cAliasSX3 )->(X3_CAMPO),MaFisOrdem(cReferencia)})
		EndIf
		If 'MAFISREF("'$cValid
			nPosIni		:= AT('MAFISREF("',cValid) + 10
			cReferencia	:=Substr(cValid,nPosIni,AT('","MT410",',cValid)-nPosIni)
			aAdd(aFisGetSCJ,{cReferencia,( _cAliasSX3 )->(X3_CAMPO),MaFisOrdem(cReferencia)})
		EndIf
		dbSkip()
    EndDo      
	
	aSort(aFisGetSCJ,,,{|x,y| x[3]<y[3]})
	
    DbSelectArea( _cAliasSX3 )
    DbCloseArea()
	
	
EndIf

MaFisEnd()

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TipoFrete ³ Autor ³Vendas e CRM           ³ Data ³23/02/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Texto do tipo de frete                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Texto do tipo de frete                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Sigla do frete                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function TipoFrete(cTipofrete)
Local cReturn := ''

Do Case
	Case cTipofrete = 'C'
		cReturn := '(CIF)'
	Case cTipofrete = 'F'
		cReturn := '(FOB)'
	Case cTipofrete = 'T'
		cReturn := '(TER)'
	Case cTipofrete = 'S'
		cReturn := '(SEM)'		
End

Return cReturn
                        
/* desabilitado release 12.1.25
Static Function ValidPerg(cPergP)
Local _sAlias,cPerg
_sAlias := Alias()
cPerg := PADR(cPergP,10)

	PutSX1(cPerg, "01",  "Orçam de ?", "Orçam de ?", "Orçam de ?", "mv_ch1", "C",  6, 0, 0, "G", " ", "SCJ", " ", " ", "mv_par01", ""                , " "        , " "     , " "   , ""                 , " "        , " "        , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , cPerg )
	PutSX1(cPerg, "02",  "Orçam ate ?", "Orçam ate ?", "Orçam ate ?", "mv_ch2", "C",  6, 0, 0, "G", " ", "SCJ", " ", " ", "mv_par02", ""                , " "        , " "     , " "   , ""                 , " "        , " "        , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , cPerg )
	PutSX1(cPerg, "03"  ,"Orc em Aberto?", "Orc em Aberto?", "Orc em Aberto?", "mv_ch3", "N",  1, 0, 1, "C"  , "","","","", "mv_par03","Sim", "Si", "Yes"   , ""   , "Não", "No", "No", "", "", "" , "", "", "", "", "", "",{},{},{}, cPerg )

dbSelectArea(_sAlias)
Return

*/
