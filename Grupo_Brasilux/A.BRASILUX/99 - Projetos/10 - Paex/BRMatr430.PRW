//#INCLUDE "MATR430.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PROTHEUS.CH"  
#include 'tbiconn.ch'
#include 'error.ch'
#include 'topconn.ch'


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR430  ³ Autor ³ Ricardo Berti         ³ Data ³07.07.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao da Planilha de Formacao de Precos                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Alterações      ³ Tiago Lucio/Chaus 26/05/2014                        ³±±
±±³ Inclusção dos produtos bloqueados na estrutura na formação de preço   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRMatr430()

Local oReport

If FindFunction("TRepInUse") .And. TRepInUse()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	MATR430R3()
EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ Ricardo Berti 		³ Data ³07.07.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatorio                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR430                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

//Local oCell         
Local cPerg	:= "MTR430"
Local oReport 
Local oSection
//Local nI
Local cPicQuant	:=PesqPictQt("G1_QUANT",13)
Local cPicUnit	:=PesqPict("SB1","B1_CUSTD",18)
Local cPicTot	:=PesqPict("SB1","B1_CUSTD",19)

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
oReport := TReport():New("MATR430","Planilha de Formacao de Precos",cPerg, {|oReport| ReportPrin(oReport)},"Emite um relatorio com os calculos da planilha selecionada para cada produto. Os valores calculados sao os mesmos  referentes as formulas da planilha.")  	//"Emite um relatorio com os calculos da planilha selecionada pa-"##"ra cada produto. Os valores calculados sao os mesmos  referen-"###"tes as formulas da planilha."

//AjustaSx1()  //LGS#20200210 - Adequação de release 12.1.25 e posteriores
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01     // Produto inicial                              ³
//³ mv_par02     // Produto final                                ³
//³ mv_par03     // Nome da planilha utilizada                   ³
//³ mv_par04     // Imprime estrutura : Sim / Nao                ³
//³ mv_par05     // Moeda Secundaria  : 1 2 3 4 5                ³
//³ mv_par06     // Nivel de detalhamento da estrutura           ³
//³ mv_par07     // Qual a Quantidade Basica                     ³
//³ mv_par08     // Considera Qtde Neg na estrutura: Sim/Nao     ³
//³ mv_par09     // Considera Estrutura / Pre Estrutura          ³
//³ mv_par10     // Revisao da Estrutura 				         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Forca utilizacao da estrutura caso nao tenha SGG               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("SGG") == 0
	mv_par09 := 1
EndIf
oSection := TRSection():New(oReport,"Produtos",{"SB1"}) //"Produtos"
oSection:SetHeaderPage()

TRCell():New(oSection,"CEL"		,"","Cel." /*Titulo*/,"99999"/*Picture*/,5/*Tamanho*/,/*lPixel*/,/*{|| Code block }*/) //"Cel."
TRCell():New(oSection,"NIVEL"	,"",RetTitle("G1_NIV"),"XXXXXX",6)
TRCell():New(oSection,"B1_COD"	,"SB1")
TRCell():New(oSection,"B1_DESC"	,"SB1",,,30)
TRCell():New(oSection,"B1_UM"	,"SB1")
TRCell():New(oSection,"QUANT"	,"",RetTitle("G1_QUANT"),cPicQuant)
TRCell():New(oSection,"VALUNI"	,"","Valor Unitario",cPicUnit) //"Valor Unitario"
TRCell():New(oSection,"VALTOT"	,"","Valor Total",cPicTot) //"Valor Total"
TRCell():New(oSection,"VALUNI2" ,"","Valor Unitario",cPicUnit) //"Valor Unitario"
TRCell():New(oSection,"VALTOT2" ,"","Valor Total",cPicTot) //"Valor Total"
TRCell():New(oSection,"PERCENT","","% PART","999.999",7) //"% Part"

Return(oReport)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrin³ Autor ³ Ricardo Berti 		³ Data ³07.07.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatorio                           ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrin(oReport)

Local aArray	:= {}
Local aArray1	:= {}
Local aPar		:= Array(20)
Local aParC010	:= Array(20)
Local lFirstCb	:= .T.
Local nReg
Local nI, nX
Local oSection  := oReport:Section(1)
LOCAL cCondFiltr:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis privadas exclusivas deste programa                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cProg:="R430"  // Usada na funcao externa MontStru()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Custo a ser considerado nos calculos                           ³
//³ 1 = STANDARD    2 = MEDIO     3 = MOEDA2     4 = MOEDA3        ³
//³ 5 = MOEDA4      6 = MOEDA5    7 = ULTPRECO   8 = PLANILHA      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE nQualCusto := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Vetor declarado para inversao do calculo do Valor Unitario   ³
//³ Utilizado no MATC010X -> M010Forma e CalcTot                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aAuxCusto

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nome do arquivo que contem a memoria de calculo desta planilha ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cArqMemo := "STANDARD"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Direcao do calculo .T. para baixo .F. para cima                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE lDirecao := .T.

PRIVATE lConsNeg := (mv_par08 = 1)     // Esta variavel sera' usada na funcao MC010FORMA

//Salvar variaveis existentes
For ni := 1 to 20
	aPar[ni] := &("mv_par"+StrZero(ni,2))
Next ni
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclui pergunta no SX1                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MTC010SX1()
Pergunte("MTC010", .F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Forca utilizacao da estrutura caso nao tenha SGG               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("SGG") == 0
	mv_par09 := 1
EndIf
//Salvar variaveis existentes
For ni := 1 to 20
	aParC010[ni] := &("mv_par"+StrZero(ni,2))
Next ni
//Forca mesmo valor do relatorio na pergunta 09
mv_par09     := aPar[09]
aParC010[09] := aPar[09]

// Restaura parametros MTR430
For ni := 1 to 20
	&("mv_par"+StrZero(ni,2)) := aPar[ni]
Next ni

oReport:NoUserFilter()  // Desabilita a aplicacao do filtro do usuario no filtro/query das secoes

dbSelectArea("SB1")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtragem do relatorio                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transforma parametros Range em expressao Advpl                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeAdvplExpr(oReport:uParam)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mantem o Cad.Produtos posicionado para cada linha impressa da planilha   ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRPosition():New(oSection,"SB1",1,{|| xFilial("SB1") + aArray[nX][04] })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o nome padrao da planilha com o nome selecionado pelo usuario ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArqMemo := apar[03]

If MR430Plan(.T.,aPar)

	If apar[05] == 1
		oSection:Cell("VALUNI2"):Disable()
		oSection:Cell("VALTOT2"):Disable()
	EndIf	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicio da impressao do fluxo do relatorio                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:SetMeter(SB1->(LastRec()))
	dbSeek(xFilial("SB1")+apar[01],.T.)

	oSection:Init() 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Este procedimento e' necessario p/ transformar o filtro selecionado  ³
	//³ pelo usuario em uma condicao de IF, isto porque o filtro age em todo ³
	//³ o arquivo e devido `a posterior explosao de niveis da estrutura, em  ³
	//³ MATC010X-> M010Forma(), o filtro deve ser validado apenas no While   ³
	//³ principal															 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCondFiltr := oSection:GetAdvplExp()
	If Empty(cCondFiltr)
		cCondFiltr := ".T."
	EndIf

	While !oReport:Cancel() .And. !SB1->(Eof()) .And. ;
		SB1->B1_FILIAL == xFilial("SB1") .And. SB1->B1_COD <= apar[02]
		If oReport:Cancel()
			Exit
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Considera filtro escolhido                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If &(cCondFiltr)
			nReg := Recno()

			// Restaura parametros MTC010
			For ni := 1 to 20
				&("mv_par"+StrZero(ni,2)) := aParc010[ni]
			Next ni

			aArray1 := MC010Forma("SB1",nReg,99,apar[07],,.F.,apar[10])

			// Restaura parametros MTR430
			For ni := 1 to 20
				&("mv_par"+StrZero(ni,2)) := aPar[ni]
			Next ni

			aArray	:= aClone(aArray1[2])

			MR430ImpTR(aArray1[1],aArray1[2],aArray1[3],oReport,aPar,aParC010,@nx,@lFirstCb)

			dbSelectArea("SB1")
			dbGoTo(nReg)
		EndIf
		dbSkip()
		oReport:IncMeter()
	EndDo
	oSection:Finish()
EndIf
dbSelectArea("SB1")
dbClearFilter()
dbSetOrder(1) 

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MR430ImpTR³ Autor ³ Ricardo Berti 		³ Data ³07.07.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime os dados ja' calculados                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MR430ImpTR(ExpC1,ExpA1,ExpN1,ExpO1,ExpA2,ExpA3,ExpN2)      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Titulo do custo utilizado                          ³±±
±±³          ³ ExpA1 = Array com os dados ja' calculados                  ³±±
±±³          ³ ExpN1 = Numero do elemento inicial a imprimir              ³±±
±±³          ³ ExpO1 = obj Report                                         ³±±
±±³          ³ ExpA2 = Array com os parametros de MTR430                  ³±±
±±³          ³ ExpA2 = Array com os parametros de MTC010                  ³±±
±±³          ³ ExpN2 = elemento do aArray, passado por referencia		  ³±±
±±³          ³ ExpL1 = indica primeiro acesso, para montagem de cabec.	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR430                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MR430ImpTR(cCusto,aArray,nPosForm,oReport,aPar,aParC010,nx,lFirstCb)

Local oSection  := oReport:Section(1)
LOCAL cMoeda1,cMoeda2
LOCAL nDecimal	:=0
Local lFirst	:= .T.
Local cOldAlias
Local nOrder
Local nRecno
Local nValUnit, nCotacao
Local cTit1,cTit2,cTit3,cTit4                                             

DEFAULT lFirstCb := .T.

cCusto := If(cCusto=Nil,'',AllTrim(Upper(cCusto)))
If cCusto == 'ULT PRECO'
	nDecimal := TamSX3('B1_UPRC')[2]
ElseIf 'MEDIO' $ cCusto
	nDecimal := TamSX3('B2_CM1')[2]
Else
	nDecimal := TamSX3('B1_CUSTD')[2]
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ De acordo com o custo da planilha lida monta a cotacao de    ³
//³ conversao e a variavel cMoeda1 usada no cabecalho.           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Str(nQualCusto,1) $ "3/4/5/6"
	nCotacao:=ConvMoeda(dDataBase,,1,Str(nQualCusto-1,1))
	cMoeda1	:=GetMV("MV_SIMB"+Str(nQualCusto-1,1,0))
	If Empty(cMoeda1)
		cMoeda1	:=GetMV("MV_MOEDA"+Str(nQualCusto-1,1,0))
	EndIf
Else
	nCotacao:=1
	cMoeda1	:=GetMV("MV_SIMB1")
EndIf

If lFirstCb
	cMoeda1	:= PADC(Alltrim(cMoeda1),12)
	cTit1:=oSection:Cell("VALUNI"):Title()
	cTit2:=oSection:Cell("VALTOT"):Title()
	oSection:Cell("VALUNI"):SetTitle(cTit1+CRLF+cMoeda1) //"Valor Unitario"
	oSection:Cell("VALTOT"):SetTitle(cTit2+CRLF+cMoeda1) //"Valor Total"
	lFirstCb := .F.
EndIf

If apar[05] <> 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ De acordo com o parametro da segunda moeda (mv_par05) remonta³
	//³ os titulos de valores no cabecalho p/ moeda secundaria		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMoeda2	:= GetMV("MV_SIMB"+Str(apar[05],1,0))
	If Empty(cMoeda2)
		cMoeda2 := GetMV("MV_MOEDA"+Str(apar[05],1,0))
	EndIf           
	cMoeda2	:= PADC(Alltrim(cMoeda2),12)
	cTit3:= oSection:Cell("VALUNI2"):Title()
	cTit4:= oSection:Cell("VALTOT2"):Title()
	oSection:Cell("VALUNI2"):SetTitle(cTit3+CRLF+PadC(AllTrim(cMoeda2),12)) //"Valor Unitario"
	oSection:Cell("VALTOT2"):SetTitle(cTit4+CRLF+PadC(AllTrim(cMoeda2),12)) //"Valor Total"
EndIf

For nX := 1 To Len(aArray)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o nivel da estrutura para ser impresso ou nao  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If apar[04] == 1
		If Val(apar[06]) != 0
			If Val(aArray[nX,2]) > Val(apar[06])
				Loop
			Endif
		Endif
	Endif

	If If( (Len(aArray[ nX ])==12),aArray[nX,12],.T. )

		If lFirst
			oReport:SkipLine()
			lFirst := .F.
		EndIf
		oSection:Cell("CEL"):SetValue(aArray[nX][01])
		oSection:Cell("NIVEL"):SetValue(aArray[nX][02])
		oSection:Cell("B1_COD"):SetValue(aArray[nX][04])
		oSection:Cell("B1_DESC"):SetValue(aArray[nX][03])
		If aArray[nX][04] == Replicate("-",15)
			oSection:Cell("VALTOT"):Hide()
			oSection:Cell("PERCENT"):Hide()
			If apar[05] <> 1
				oSection:Cell("VALUNI2"):Hide()
				oSection:Cell("VALTOT2"):Hide()
			EndIf
		Else
			If nX < nPosForm-1
				If aParc010[02] == 1
					nValUnit := Round(aAuxCusto[nX]/aArray[nX][05], nDecimal)
				Else
					nValUnit := NoRound(aAuxCusto[nX]/aArray[nX][05], nDecimal)
				EndIf
			EndIf
			oSection:Cell("VALTOT"):SetValue(aArray[nX][06])
			oSection:Cell("PERCENT"):SetValue(aArray[nX][07])
			oSection:Cell("VALTOT"):Show()
			oSection:Cell("PERCENT"):Show()
			If apar[05] <> 1
				If nX < nPosForm-1
					oSection:Cell("VALUNI2"):SetValue(Round(ConvMoeda(dDataBase,,nValUnit/nCotacao,Str(apar[05],1)), nDecimal))
					oSection:Cell("VALUNI2"):Show()
				Else
					oSection:Cell("VALUNI2"):Hide()
				EndIf
				oSection:Cell("VALTOT2"):SetValue(ConvMoeda(dDataBase,,(aArray[nX][06]/nCotacao),Str(apar[05],1)))
				oSection:Cell("VALTOT2"):Show()
			EndIf	
		EndIf
		If aArray[nX][04] == Replicate("-",15) .Or. nX >= nPosForm-1
			oSection:Cell("B1_UM"):Hide()
			oSection:Cell("QUANT"):Hide()
			oSection:Cell("VALUNI"):Hide()
		Else
			oSection:Cell("B1_UM"):Show()
			oSection:Cell("QUANT"):Show()
			oSection:Cell("VALUNI"):Show()
			cOldAlias:=Alias()
			dbSelectArea("SB1")
			nOrder:=IndexOrd()
			nRecno:=Recno()
			dbSetOrder(1)
			dbSeek(xFilial()+aArray[nX][04])
			oSection:Cell("B1_UM"):SetValue(SB1->B1_UM)
			dbSetOrder(nOrder)
			dbGoTo(nRecno)
			dbSelectArea(cOldAlias)
			oSection:Cell("QUANT"):SetValue(aArray[nX][05])
			oSection:Cell("VALUNI"):SetValue(nValUnit)
		EndIf

		oSection:PrintLine()

		If nX == 1 .And. apar[04] == 2
			nX += (nPosForm-3)
		EndIf
	EndIf
Next
If !lFirst
	oReport:ThinLine()
EndIf	

Return NIL



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR430R3³ Autor ³ Eveli Morasco         ³ Data ³ 30/03/93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao da Planilha de Formacao de Precos                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo Pim.³25/11/97³ 7515A³ Incluir perg. p/ determinar qual nivel de³±±
±±³            ³        ³ 7515A³ detalhamento da estrutura.(mv_par06).    ³±±
±±³Marcelo Pim.³04/12/97³12092A³ Ajust.p/que a 2.moeda nao imp. se a moeda³±±
±±³            ³        ³12092A³ selecionada for moeda 1.                 ³±±
±±³Marcelo Pim.³05/12/97³ 7514A³ Incluir perg. p/ informar a qtde.Basica. ³±±
±±³Bruno Sobies³23.12.98³melhor³ Aumento do tamanho das colunas de descri-³±±
±±³            ³        ³      ³ cao, valor unit e total, e das casas do %³±±
±±³CesarValadao³30/03/99³XXXXXX³ Manutencao na SetPrint()                 ³±±
±±³Fernando J. ³27/05/99³21327A³ Arredondar o Valor Unit rio com o n£mero ³±±
±±³            ³        ³      ³ de casas decimais do Campo Original.     ³±±
±±³CesarValadao³22/07/99³22152A³ Passar mv_par07 (QtdBas) p/ Mc010Forma().³±±
±±³CesarValadao³30/08/99³21448A³ Fazer a inversao do calculo do Valor     ³±±
±±³            ³        ³      ³ Unitario com o maximo de casas decimais. ³±±
±±³CesarValadao³08/10/99³XXXXXX³ Considerar Pergunte() do MTC010.         ³±±
±±³            ³        ³      ³ mv_par02 - Arredonda ou Trunca.          ³±±
±±³Iuspa       ³24/08/00³  5742³ mv_par08 - Considera componente qtd. neg.³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MATR430R3()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL Tamanho
LOCAL cDesc1   := "Emite um relatorio com os calculos da planilha selecionada pa-"
LOCAL cDesc2   :=  "ra cada produto. Os valores calculados sao os mesmos  referen-"
LOCAL cDesc3   :=  "tes as formulas da planilha."
LOCAL cString  := "SB1"
LOCAL nI       := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Estas variaveis foram deixadas em separado para lembrar que  ³
//³ elas devem ser definidas novamente na funcao MR430Impr()     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL titulo   := OemToAnsi("Planilha de Formacao de Precos")	//"Planilha de Formacao de Precos"
LOCAL wnrel := "MATR430"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis tipo Private padrao de todos os relatorios         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aReturn := { OemToAnsi("Zebrado"), 1,OemToAnsi("Administracao"), 2, 2, 1, "",1 }		//"Zebrado"###"Administracao"
PRIVATE nLastKey := 0 ,cPerg := "MTR430",aPar:=Array(20),aParC010:=Array(20)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01     // Produto inicial                              ³
//³ mv_par02     // Produto final                                ³
//³ mv_par03     // Nome da planilha utilizada                   ³
//³ mv_par04     // Imprime estrutura : Sim / Nao                ³
//³ mv_par05     // Moeda Secundaria  : 1 2 3 4 5                ³
//³ mv_par06     // Nivel de detalhamento da estrutura           ³
//³ mv_par07     // Qual a Quantidade Basica                     ³
//³ mv_par08     // Considera Qtde Neg na estrutura: Sim/Nao     ³
//³ mv_par09     // Considera Estrutura / Pre Estrutura          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AjustaSx1()
pergunte(cPerg,.F.)   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Forca utilizacao da estrutura caso nao tenha SGG               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("SGG") == 0
	mv_par09:=1
EndIf
//Salvar variaveis existentes
For ni := 1 to 20
	aPar[ni] := &("mv_par"+StrZero(ni,2))
Next ni

Tamanho := IIF(apar[05]==1,"M","G")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

If nLastKey = 27
	Set Filter to
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Set Filter to
	Return
Endif

//Salvar variaveis existentes
For ni := 1 to 20
	aPar[ni] := &("mv_par"+StrZero(ni,2))
Next ni

RptStatus({|lEnd| C430Imp(@lEnd,wnRel,cString,titulo,Tamanho)},titulo)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C430IMP  ³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 14.12.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR430                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C430Imp(lEnd,WnRel,cString,titulo,Tamanho)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis locais exclusivas deste programa                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cRodaTxt := ""
LOCAL nCntImpr := 0,nReg
LOCAL aArray   := {} ,cCondFiltr,lRet
LOCAL nI       := 0
LOCAL cProdFim :=""
Local nX
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Contadores de linha e pagina                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE li := 80 ,m_pag := 1,cProg:="R430"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis privadas exclusivas deste programa                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Custo a ser considerado nos calculos                           ³
//³ 1 = STANDARD    2 = MEDIO     3 = MOEDA2     4 = MOEDA3        ³
//³ 5 = MOEDA4      6 = MOEDA5    7 = ULTPRECO   8 = PLANILHA      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE nQualCusto := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Vetor declarado para inversao do calculo do Valor Unitario   ³
//³ Utilizado no MATC010X -> M010Forma e CalcTot                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aAuxCusto

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nome do arquivo que contem a memoria de calculo desta planilha ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cArqMemo := "STANDARD"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Direcao do calculo .T. para baixo .F. para cima                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE lDirecao := .T.

PRIVATE lConsNeg := apar[08] = 1     // Esta variavel será usada na função MC010FORMA

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclui pergunta no SX1                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MTC010SX1()
PERGUNTE("MTC010", .F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Forca utilizacao da estrutura caso nao tenha SGG               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("SGG") == 0
	mv_par09:=1
EndIf
//Salvar variaveis existentes
For ni := 1 to 20
	aParC010[ni] := &("mv_par"+StrZero(ni,2))
Next ni
//Forca mesmo valor do relatorio na pergunta 09
mv_par09     := aPar[09]
aParC010[09] := aPar[09]
	      	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Este procedimento foi necessario para transformar o filtro sele- ³
//³ cionado pelo usuario em uma condicao de IF ,isto porque o filtro ³
//³ age em todo o arquivo e eu preciso dele apenas no While principal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCondFiltr := aReturn[7]
If Empty(cCondFiltr)
	cCondFiltr := ".T."
EndIf

DbSelectArea("SB1")
Set Filter to

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o nome padrao da planilha com o nome selecionado pelo ³
//³ usuario                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArqMemo := apar[03]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa os codigos de caracter Comprimido/Normal da impressora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTipo  := IIF(aReturn[4]==1,15,18)


dbSelectArea("SB1")
SetRegua(LastRec())

Set SoftSeek On
dbSeek(xFilial()+apar[01])
Set SoftSeek Off
lRet:=MR430Plan(.T.,aPar)
IF !lRet
	SET DEVICE TO SCREEN
	Return Nil
ENDIF

cProdFim:=apar[02]

While !EOF() .And. B1_FILIAL+B1_COD <= xFilial()+cProdFim .And. lRet

	If lEnd
		@ PROW()+1,001 PSay "CANCELADO PELO OPERADOR"
		Exit
	EndIf

	IncRegua()
	nReg := Recno()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Considera filtro escolhido                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If &(cCondFiltr)
		BEGIN TRANSACTION 
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Alterado por Tiago Lucio/Chaus  26/05/2014=> Inclui produtos  bloqueados na estrura do produto na formação de preço 
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		dbSelectArea("SG1")
		SG1->(dbSetOrder(1))	//G1_FILIAL, G1_COD, G1_COMP, G1_TRT, R_E_C_N_O_, D_E_L_E_T_
		SG1->(dbSeek(xFilial("SG1")+SB1->B1_COD))
		aBloq:={}
		
		While !(SG1->(EOF())) .And. Trim(SB1->B1_COD)==Trim(SG1->G1_COD)
			IF !(SG1->(EOF())) .And. dtos(SG1->G1_FIM) < dtos(date())
				
				cQuery:= " SELECT B1_COD, B1_TIPO FROM "+RetSqlName("SB1")+" "
				cQuery +=" WHERE  D_E_L_E_T_ <> '*' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = '"+SG1->G1_COMP+"' "
				
				IF (Select("TMPSB1") > 0 )
   					TMPSB1->(DbCloseArea())
				EndIf

				TCQuery cQuery  ALIAS "TMPSB1" NEW
				
				iF Trim(TMPSB1->B1_TIPO)=='MC'
					cQuery := " UPDATE "+RetSqlName("SB1")+" SET B1_TIPO = 'MP' "
					cQuery += " WHERE  D_E_L_E_T_ <> '*' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = '"+SG1->G1_COMP+"' AND B1_TIPO='MC' "
					TCSQLExec(cQuery)
					AAdd(aBloq,{SG1->G1_COMP, SG1->G1_FIM,'MC'})
				Else
					AAdd(aBloq,{SG1->G1_COMP, SG1->G1_FIM,'MP'})
				EndIf
				RecLock("SG1",.F.)
				SG1->G1_FIM:=ctod('31/12/2049')
				MsUnLock() 

				
			EndIf
			SG1->(dbSkip())
		EndDo
		
		aArray := MC010Forma(cString,nReg,99,apar[07],,.F.,apar[10])
		
		For nX := 1 To Len(aBloq)
				SG1->(dbSetOrder(1))
				SG1->(dbSeek(xFilial("SG1")+SB1->B1_COD+aBloq[nX][1] )) //G1_FILIAL, G1_COD, G1_COMP, G1_TRT, R_E_C_N_O_, D_E_L_E_T_
				RecLock("SG1",.F.)
				SG1->G1_FIM:=aBloq[nX][2]
				MsUnLock() 
				
				iF Trim(aBloq[nX][3]) =='MC'
					cQuery := " UPDATE "+RetSqlName("SB1")+" SET B1_TIPO = 'MC' "
					cQuery += " WHERE  D_E_L_E_T_ <> '*' AND B1_FILIAL = '"+xFilial("SB1")+"' AND Rtrim(B1_COD) = '"+Trim(aBloq[nX][1])+"' "
					TCSQLExec(cQuery)
				EndIf
			
		Next nX	
		
			END TRANSACTION
		
		//aArray1 := MC010Forma(cString,nReg,99,apar[07],,.T.,apar[10])
	//	aArray2 := MC010FORM2(cString,nReg,99,apar[07],,.t.,apar[10])
//		aArray3 := MC010FORM2(cString,nReg,99,apar[07],,.f.,apar[10])
		
		MR430Impr(aArray[1],aArray[2],aArray[3])
		dbGoTo(nReg)
	EndIf
	
	dbSelectArea("SB1")
	dbSkip()
End

If li != 80 .And. lRet
	Roda(nCntImpr,cRodaTxt,Tamanho)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve a condicao original do arquivo principal             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cString)
Set Filter To
Set Order To 1

If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MR430Impr ³ Autor ³ Eveli Morasco         ³ Data ³ 30/03/93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime os dados ja' calculados                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MR430Impr(ExpC1,ExpA1,ExpN1)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Titulo do custo utilizado                          ³±±
±±³          ³ ExpA1 = Array com os dados ja' calculados                  ³±±
±±³          ³ ExpN1 = Numero do elemento inicial a imprimir              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR430                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MR430Impr(cCusto,aArray,nPosForm)
LOCAL nX
LOCAL nCotacao,nValUnit,nValUnit2
LOCAL cPicQuant:=PesqPictQt("G1_QUANT",13)
LOCAL cPicUnit :=PesqPict("SB1","B1_CUSTD",18)
LOCAL cPicTot	:=PesqPict("SB1","B1_CUSTD",19)
LOCAL cMoeda1,cMoeda2
Local nDecimal :=0
LOCAL nI       :=0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Estas variaveis foram deixadas em separado para lembrar que  ³
//³ elas foram definidas no programa principal MATR430 e estao   ³
//³ sendo redefinidas para nao ter que defini-las como PRIVATE.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL Tamanho  := IIF(apar[05]==1,"M","G")
LOCAL titulo   := "Planilha de Formacao de Precos"
LOCAL nTipo    := 0
LOCAL wnrel := "MATR430"
LOCAL cOldAlias,nOrder,nRecno
LOCAL cabec1,cabec2
LOCAL Limite   := IIF(apar[05]==1,132,220)
//Local nX
Local nY

cCusto := If(cCusto=Nil,'',AllTrim(Upper(cCusto)))
If cCusto == 'ULT PRECO'
	nDecimal := TamSX3('B1_UPRC')[2]
ElseIf 'MEDIO' $ cCusto
	nDecimal := TamSX3('B2_CM1')[2]
Else
	nDecimal := TamSX3('B1_CUSTD')[2]
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ De acordo com o custo da planilha lida monta a cotacao de    ³
//³ conversao e a variavel cMoeda1 usada no cabecalho.           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Str(nQualCusto,1) $ "3/4/5/6"
	nCotacao:=ConvMoeda(dDataBase,,1,Str(nQualCusto-1,1))
	cMoeda1:=GetMV("MV_MOEDA"+Str(nQualCusto-1,1,0))
Else
	nCotacao:=1
	cMoeda1:=GetMV("MV_MOEDA1")
EndIf
cMoeda1:=PADC(Alltrim(cMoeda1),35)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ De acordo com o parametro da segunda moeda (mv_par05) monta  ³
//³ a variavel cMoeda2 usada no cabecalho.                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMoeda2:=PADC(Alltrim(GetMV("MV_MOEDA"+Str(apar[05],1,0))),38)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os Cabecalhos de acordo com a moeda                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If apar[05] == 1
	Cabec1 := "CEL. NIVEL  CODIGO          DESCRICAO                      UM    QUANTIDADE "+cMoeda1+"% PART"			//"CEL.  NIVEL  CODIGO          DESCRICAO                      UM    QUANTIDADE "###"% PART"
	Cabec2 :=  "                                                                              VALOR UNITARIO       VALOR TOTAL"										//"                                                                              VALOR UNITARIO      VALOR TOTAL"
Else
	Cabec1 := "CEL. NIVEL  CODIGO          DESCRICAO                      UM    QUANTIDADE "+cMoeda1+cMoeda2+"% PART"	//"CEL.  NIVEL  CODIGO          DESCRICAO                      UM    QUANTIDADE "###"% PART"
	Cabec2 := "                                                                              VALOR UNITARIO       VALOR TOTAL   VALOR UNITARIO       VALOR TOTAL"										//"                                                                              VALOR UNITARIO      VALOR TOTAL   VALOR UNITARIO       VALOR TOTAL"
Endif
********                                           99999 999999 123456789012345 123456789012345678901234567890 12 9999999999.99 9.999.999.999,99 99.999.999.999,99 9.999.999.999,99 99.999.999.999,99 999.99
********   														0         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15
********   														01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa os codigos de caracter Comprimido/Normal da impressora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTipo  := IIF(aReturn[4]==1,15,18)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alterado por Tiago Lucio/Chaus  26/05/2014=> Marca os produtos bloqueados na estrutura e acrescenta uma leganda no final do relátório 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aBloq)
	For nY := 1 To Len(aArray)
		If Trim(aBloq[nX][1])==Trim(aArray[nY][4])
			aArray[nY][4]:=Trim(aArray[nY][4])+' *'
		EndIf			
	Next nY		
Next nX

//aAux:=aArray[][]
nTam:=Len(aArray)

AADD(aArray,{Len(aArray)+1,aArray[nTam][2],aArray[nTam][3],aArray[nTam][4],aArray[nTam][5],aArray[nTam][6],aArray[nTam][7],aArray[nTam][8],aArray[nTam][9],aArray[nTam][10],aArray[nTam][11],aArray[nTam][12],aArray[nTam][13],' '})
AADD(aArray,{Len(aArray)+1,aArray[nTam][2],' ','(*) PRODUTOS BLOQUEADOS NA ESTRUTURA POR DATA DE VALIDADE',' ',' ',aArray[nTam][7],aArray[nTam][8],aArray[nTam][9],aArray[nTam][10],aArray[nTam][11],aArray[nTam][12],aArray[nTam][13],' '})

//Fim alteração

For nX := 1 To Len(aArray)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o nivel da estrutura para ser impresso ou nao  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If apar[04] == 1
		If Val(apar[06]) != 0
			If Val(aArray[nX,2]) > Val(apar[06])
				Loop
			Endif
		Endif
	Endif

	If If( (Len(aArray[ nX ])==12),aArray[nX,12],.T. )
		If li > 60
			// Restaura variaveis existentes
			For ni := 1 to 20
				&("mv_par"+StrZero(ni,2)) := aPar[ni]
			Next ni
			Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
			// Restaura variaveis existentes
			For ni := 1 to 20
				&("mv_par"+StrZero(ni,2)) := aParc010[ni]
			Next ni
		EndIf
		If nX < nPosForm-1
			If mv_par02 == 1
				nValUnit := Round(aAuxCusto[nX]/aArray[nX][05], nDecimal)
			Else
				nValUnit := NoRound(aAuxCusto[nX]/aArray[nX][05], nDecimal)
			EndIf
			nValUnit2:= Round(ConvMoeda(dDataBase,,nValUnit/nCotacao,Str(apar[05],1)), nDecimal)
		EndIf
		@ li,000 PSay aArray[nX][01] Picture "99999"
		@ li,006 PSay aArray[nX][02]
		@ li,013 PSay aArray[nX][04]
		@ li,029 PSay Left(aArray[nX][03],30)
		If aArray[nX][04] != Replicate("-",15)
			If nX < nPosForm-1
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona na UM correta do produto ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cOldAlias:=Alias()
				dbSelectArea("SB1")
				nOrder:=IndexOrd()
				nRecno:=Recno()
				dbSetOrder(1)
				dbSeek(xFilial()+aArray[nX][04])
				@ li,068 PSay SB1->B1_UM
				dbSetOrder(nOrder)
				dbGoTo(nRecno)
				dbSelectArea(cOldAlias)
				@ li,072 PSay aArray[nX][05] Picture cPicQuant
				@ li,087 PSay nValUnit Picture cPicUnit
			EndIf
			@ li,105 PSay aArray[nX][06] Picture cPictot
			If apar[05] == 1
				@ li,125 PSay aArray[nX][07] Picture "999.999"
			Else
				If nX < nPosForm-1
					@ li,125 PSay nValUnit2 Picture cPicUnit
				EndIf
				@ li,143 PSay ConvMoeda(dDataBase,,(aArray[nX][06]/nCotacao),Str(apar[05],1)) Picture cPictot
				@ li,163 PSay aArray[nX][07] Picture "999.999"
			Endif
		EndIf
		li++
		If nX == 1 .And. apar[04] == 2
			nX += (nPosForm-3)
		EndIf
	EndIf
Next nX
@ li,000 PSay Replicate("-",Limite)
li += 2
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MR430Plan ³ Autor ³ Eveli Morasco         ³ Data ³ 30/03/93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a Planilha escolhida existe                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR430                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MR430Plan(lGravado,aPar)
Local cArq := ""     
Local lRet := .T.
DEFAULT lGravado:=.F.
cArq:=AllTrim(If(lGravado,apar[03],&(ReadVar())))+".PDV"
If !File(cArq)
	Help(" ",1,"MR430NOPLA")
	lRet := .F.
EndIf
Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AjustaSX1    ³Autor ³ Ricardo Berti        ³Data³07/07/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ajusta perguntas do SX1                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//LGS#20200210 - Adequação de release 12.1.25 e posteriores
/*Static Function AjustaSX1()

Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}
Local aArea		:=GetArea()
Local nTamSX1*/
/*-----------------------MV_PAR09--------------------------*/
/*Aadd( aHelpPor, "Identifica se a montagem da composicao  " )
Aadd( aHelpPor, "do produto deve ser feita pela estrutura" )
Aadd( aHelpPor, " ou pela pre-estrutura.                 " )

Aadd( aHelpEng, "Identifies if the product composition   " )
Aadd( aHelpEng, "preparation must be made by the         " )
Aadd( aHelpEng, "structure or by the pre-structure.      " )

Aadd( aHelpSpa, "Identifica si el montaje de composicion " )
Aadd( aHelpSpa, "del producto debe ser hecha por la      " )
Aadd( aHelpSpa, "estructura o por la pre-estructura.     " )

PutSX1("MTR430","09","Mostra ?","¿Muestra?","Show?","mv_ch9","N",1,0,1,"C","","","","N","mv_par09",;
"Estrutura","Estructura","Structure","","Pre-Estrutura","Estructura Previa","Previous Structure","","","","","","","","","")

PutSX1Help("P.MTR43009.",aHelpPor,aHelpEng,aHelpSpa)	 

aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}*/

/*-----------------------MV_PAR10--------------------------*/
/*Aadd( aHelpPor, "Informar a Revisao da Estrutura do      " )
Aadd( aHelpPor, "Produto                                 " )
      
Aadd( aHelpEng, "Enter the Product Structure Revision    " )

Aadd( aHelpSpa, "Informe la Revision de la Estructura del" )
Aadd( aHelpSpa, "Producto                                " )

PutSX1("MTR430","10","Qual Revisao da Estrutura ?","¿Que Revis.Estruct. ?","Structure Revision ?","mv_chA","C",TamSX3("B1_REVATU")[1],0,0,"G","","",;
"","N","mv_par10","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

dbSelectArea("SX1")
dbSetOrder(1)
nTamSX1 := Len(SX1->X1_GRUPO)
If dbSeek(PADR("MTR430",nTamSX1)+"06",.F.)
	If X1_TAMANHO < 3
		RecLock("SX1",.F.)
		Replace X1_TAMANHO With 3
		Replace X1_CNT01 With "999"
		MsUnlock()
	EndIf
EndIf

RestArea(aArea)
Return*/

/*Static Function getSB1(filial,cProd, cRetorno)

cArea:=getArea()
			dbSelectArea("SB1")
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(filial+cProd))
			
			if cRetorno=='B1_DESC' 
				cRetorno:=SB1->B1_DESC
			ElseIf cRetorno=='B1_TIPO' 
				cRetorno:=SB1->B1_TIPO
			ElseIf cRetorno=='B1_UM' 
				cRetorno:=SB1->B1_UM
			EndIf
	RestArea(cArea)
Return cRetorno*/