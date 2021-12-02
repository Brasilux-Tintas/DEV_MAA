#INCLUDE "PROTHEUS.CH"
#DEFINE CHRCOMP If(aReturn[4]==1,15,18)

//#INCLUDE "FINRSRF.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³FINRSRF   ³ Autor ³ Eduardo Riera         ³ Data ³26.06.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio de impressao do Darf grafico a partir dos titulos ³±±
±±³          ³de contas a pagar                                           ³±±
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

User Function BRFINRSRF()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define Variaveis                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cPerg   := "BRFINSRF"  // Pergunta do Relatorio
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica as Perguntas Seleciondas                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//AjustaSX1(cPerg) //LGS#20200131 - Adequação para release 12.1.25 e posteriores
If Pergunte(cPerg,.T.)
	RptStatus({|lEnd| ImpDet(lEnd)},"Processando - DARF") //"Processando - DARF"
EndIf
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ ImpDet   ³ Autor ³ Eduardo Riera         ³ Data ³26.06.2003³±±
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
Static Function ImpDet(lEnd)

Local aDarf     := {}
Local aInfo     := {}
Local lQuery    := .F.
Local cAliasSE2 := "SE2"
Local dDataIni  := MV_PAR01
Local dDataFim  := MV_PAR02
Local nX        := 0
Local nValorImp := 0
Local cAliasAux
Local cCodIni   := MV_PAR03
Local cCodFim   := MV_PAR04

#IFDEF TOP
	Local aStru     := {}
	Local cQuery    := ""
#ENDIF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre o SE2 com outro alias para ser localizado o titulo 	 ³
//³ principal do imposto                   							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !( ChkFile("SE2",.F.,"NEWSE2") )
	Return(Nil)
EndIf	
	
dbSelectArea("SE2")
SetRegua(LastRec())
dbSetOrder(3)

#IFDEF TOP
	lQuery := .T.
	aStru  := SE2->(dbStruct())
	cAliasSE2 := "IMPDET"
	
	cQuery := "SELECT * "
	cQuery += "FROM "+RetSqlName("SE2")+" SE2 WITH (NOLOCK) "
	cQuery += "WHERE SE2.E2_FILIAL='"+xFilial("SE2")+"' AND "
	cQuery += "SE2.E2_VENCREA>='"+DTOS(dDataIni)+"' AND "
	cQuery += "SE2.E2_VENCREA<='"+DTOS(dDataFim)+"' AND "
	cQuery += "SE2.E2_CODRET > '' AND "
	cQuery += "SE2.E2_CODRET>='"+cCodIni+"' AND "
	cQuery += "SE2.E2_CODRET<='"+cCodFim+"' AND "
	cQuery += "SE2.E2_DIRF IN ('1','S') AND "
	cQuery += "(SE2.D_E_L_E_T_ <> '*') "
	cQuery += "ORDER BY E2_FILIAL,E2_VENCREA,E2_FORNECE,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FILORIG"
	//+SqlOrder(SE2->(IndexKey()))
	
   //	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE2)
	For nX := 1 To Len(aStru)
		If aStru[nX][2]<>"C"
			TcSetField(cAliasSE2,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
		EndIf
	Next nX
#ELSE
	MsSeek(xFilial("SE2")+DTOS(dDataIni),.T.)
#ENDIF
While ( !Eof() .And. xFilial("SE2")==(cAliasSE2)->E2_FILIAL .And.;
		(cAliasSE2)->E2_VENCREA <= dDataFim )

	If !Empty((cAliasSE2)->E2_CODRET) .And.;
		(cAliasSE2)->E2_CODRET >= cCodIni .And.;
		(cAliasSE2)->E2_CODRET <= cCodFim .And.;
		(cAliasSE2)->E2_DIRF == "1"
		
		// Posiciona no titulo pai para obter o valor total do titulo
		lAchouPai := FrSrfPai(cAliasSe2)
		cAliasAux := If(lAchouPai,"NEWSE2", cAliasSE2)
		dbSelectArea("SA2")
		MsSeek(xFilial("SA2")+(cAliasAux)->(E2_FORNECE+E2_LOJA))
		dbSelectArea(cAliasSE2)
		
		If mv_par05 == 1 // Agrupa por fornecedor
			nX := aScan(aDarf,{|x|	x[1] == (cAliasSE2)->E2_CODRET .And.;
											x[2] == (cAliasSE2)->E2_VENCREA .And.;
											x[4] == SA2->A2_COD })
		Else
			nX := aScan(aDarf,{|x| x[1] == (cAliasSE2)->E2_CODRET .And. x[2] == (cAliasSE2)->E2_VENCREA})
		Endif
		// Obtem o valor do imposto
		// Se nao achou o titulo pai, esta no proprio titulo pai e entao
		// o valor do imposto sera o valor do campo de imposto, senao sera
		// o valor do titulo de imposto (SE2->E2_VALOR)
		If !lAchouPai   
			nValorImp := NEWSE2->E2_VALOR
			/*
			Do Case 
			Case Alltrim((cAliasSE2)->E2_NATUREZ) $ AllTrim(GetMv("MV_PISAPNC")) 
				nValorImp := NEWSE2->E2_PIS
			Case Alltrim((cAliasSE2)->E2_NATUREZ) $ AllTrim(GetMv("MV_COFAPUR")) 
				nValorImp := NEWSE2->E2_COFINS
			Case Alltrim((cAliasSE2)->E2_NATUREZ) $ AllTrim(GetMv("MV_CSLL")) 
				nValorImp := NEWSE2->E2_CSLL
			OtherWise
				nValorImp := NEWSE2->E2_IRRF
			EndCase	  
			*/
		Else
			nValorImp := (cAliasSE2)->E2_VALOR
		Endif
		If nX == 0
			aadd(aDarf,{(cAliasSE2)->E2_CODRET,;
							(cAliasSE2)->E2_VENCREA,;
							xMoeda(nValorImp,(cAliasSE2)->E2_MOEDA,1),;
							SA2->A2_COD,;
							SA2->A2_NOME })
		Else
			aDarf[nX][3] += xMoeda(nValorImp,(cAliasSE2)->E2_MOEDA,1)
		EndIf
	EndIf
	dbSelectArea(cAliasSE2)
	dbSkip()
	IncRegua()
	If lEnd
		Exit
	EndIf
EndDo

NEWSE2->(dbCloseArea())

If lQuery
	dbSelectArea(cAliasSE2)
	dbCloseArea()
	dbSelectArea("SE2")
EndIf

For nX := 1 To Len(aDarf)
	aadd(aInfo,{{SM0->M0_NOMECOM,SM0->M0_TEL},;
		dDataBase,;
		TransForm(SM0->M0_CGC,"@R 99.999.999/9999-99"),;
		aDarf[nX][1],;
		"",;
		aDarf[nX][2],;
		aDarf[nX][3],;
		0,;
		0,;
		aDarf[nX][3],;
		aDarf[nX][5]})
Next nX

If Len(aInfo) > 0
	PrtDarf(aInfo)
Else
	Aviso("Mensagem","Nao há dados no periodo informado",{"Ok"}) //"Mensagem"###"Nao há dados no periodo informado"###"Ok"
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PrtDarf   ³ Autor ³Eduardo Riera          ³ Data ³26/06/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do formulario DARF grafico conforme layout da SRF³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PrtDarf(aInfo)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1: [1][1] Nome                                         ³±±
±±³          ³        [1][2] Telefone                                     ³±±
±±³          ³        [2] Periodo de Apuracao ( DATA )                    ³±±
±±³          ³        [3] CNPJ                                            ³±±
±±³          ³        [4] Codigo da Receita                               ³±± 
±±³          ³        [5] Numero de Referencia                            ³±±
±±³          ³        [6] Data de Vencimento (Data)                       ³±±
±±³          ³        [7] Valor do Principal                              ³±±
±±³          ³        [8] Valor da Multa                                  ³±±
±±³          ³        [9] Valor dos Juros e/ou Encargos DL - 1.025/69     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function  PrtDarf(aInfo)

Local cBmp 		 := ""
Local cStartPath := GetSrvProfString("StartPath","")
Local nX         := 030
Local nY         := 0
Local nW         := 0
Local oFont07    := TFont():New("Arial",07,10,,.F.,,,,.T.,.F.)
Local oFont09    := TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)  
Local oFont10    := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
Local oFont10n   := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
Local oFont11    := TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
Local oFont15    := TFont():New("Arial",15,15,,.F.,,,,.T.,.F.)
Local oFont21n   := TFont():New("Arial",21,21,,.T.,,,,.T.,.F.)
Local oPrint

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializacao do objeto grafico                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrint 	:= TMSPrinter():New("DARF - Guia de Recolhimento DARF")
oPrint:Setup()
oPrint:SetPortrait()
cBmp := cStartPath + "Receita.BMP" //Logo da Receita Federal
For nW := 1 To Len(aInfo)
	oPrint:StartPage()
	nX := 030		
	For nY := 1 To 2
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Definicao do Box grafico                                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Box(nX,0030,nX+1100,2350)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inclusao do logotipo do Ministerio da Fazenda                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If File(cBmp)
			oPrint:SayBitmap(nX+10,040,cBmp,200,180)
		EndIf
		oPrint:Say(nX+020,250,"MINISTÉRIO DA FAZENDA",oFont15)
		oPrint:Say(nX+070,250,"Secretaria da Receita Federal")
		oPrint:Say(nX+120,250,"Documento de Arrecadação de Receitas Federais",oFont10)
		oPrint:Say(nX+170,250,"DARF",oFont21n)
		oPrint:Line(nX,1300,nX+1100,1300)
		oPrint:Line(nX,1800,nX+810,1800)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Definicao do Quadro 01                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Line(nX+270,030,nX+270,1300) 
		oPrint:Say(nX+280,040,"01",oFont10)
		oPrint:Say(nX+290,110,"NOME / TELEFONE",oFont10)
		oPrint:Say(nX+350,110,Left(aInfo[nW][1][1],37),oFont10) 
		oPrint:Say(nX+380,110,aInfo[nW][1][2],oFont10)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Definicao do Quadro 02                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Line(nX+490,030,nX+490,1300)
		oPrint:Line(nX+650,030,nX+650,1300)
		oPrint:Say(nX+020,1305,"02",oFont10)
		oPrint:Say(nX+030,1360,"PERíODO DE APURACAO",oFont09)
//		oPrint:Say(nX+030,2190,Dtoc(aInfo[nW][2]),oFont10)
		oPrint:Say(nX+030,2190,dtoc(MV_PAR06),oFont10)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Definicao do Quadro 03                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Line(nX+090,1300,nX+90,2350)
		oPrint:Say(nX+120,1305,"03",oFont10)
		oPrint:Say(nX+130,1360,"NÚMERO DO CPF OU CGC",oFont09)
		oPrint:Say(nX+130,2010,aInfo[nW][3],oFont10)  
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Definicao do Quadro 04                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Line(nX+180,1300,nX+180,2350)
		oPrint:Say(nX+200,1305,"04",oFont10)
		oPrint:Say(nX+210,1360,"CODIGO DA RECEITA",oFont09)
		oPrint:Say(nX+210,2245,aInfo[nW][4],oFont10)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Definicao do Quadro 05                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Line(nX+270,1300,nX+270,2350)
		oPrint:Say(nX+290,1305,"05",oFont10)
		oPrint:Say(nX+300,1360,"NÚMERO DE REFERÊNCIA",oFont09)
		oPrint:Say(nX+300,2035,aInfo[nW][5],oFont10)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Definicao do Quadro 06                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Line(nX+360,1300,nX+360,2350)
		oPrint:Say(nX+380,1305,"06",oFont10)
		oPrint:Say(nX+390,1360,"DATA DE VENCIMENTO",oFont09)
		oPrint:Say(nX+390,2190,Dtoc(aInfo[nW][6]),oFont10)  
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Definicao do Quadro 07                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Line(nX+450,1300,nX+450,2350)
		oPrint:Say(nX+470,1305,"07",oFont10)
		oPrint:Say(nX+480,1360,"VALOR DO PRINCIPAL",oFont09)
		oPrint:Say(nX+480,2100,Transform(aInfo[nW][7],"@E 9,999,999,999.99"),oFont10)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Definicao do Quadro 08                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Line(nX+ 540,1300,nX+540,2350)
		oPrint:Say(nX+560,1305,"08",oFont10)
		oPrint:Say(nX+570,1360,"VALOR DA MULTA",oFont09)
		oPrint:Say(nX+570,2100,Transform(aInfo[nW][8],"@E 9,999,999,999.99"),oFont10)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Definicao do Quadro 09                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Line(nX+630,1300,nX+630,2350)
		oPrint:Say(nX+650,1305,"09",oFont10)
		oPrint:Say(nX+640,1360,"VALOR DOS JUROS E / OU",oFont09)
		oPrint:Say(nX+670,1370,"ENCARGOS DL 1025/69",oFont09)
		oPrint:Say(nX+670,2100,Transform(aInfo[nW][9],"@E 9,999,999,999.99"),oFont10)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Definicao do Quadro 10                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Line(nX+720,1300,nX+720,2350)
		oPrint:Say(nX+740,1305,"10",oFont10)
		oPrint:Say(nX+750,1360,"VALOR TOTAL",oFont09)
		oPrint:Say(nX+750,2100,Transform(aInfo[nW][7]+aInfo[nW][8]+aInfo[nW][9],"@E 9,999,999,999.99"),oFont10)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Definicao do Quadro 11                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Line(nX+810,1300,nX+810,2350)
		oPrint:Say(nX+830,1305,"11",oFont10)
		oPrint:Say(nX+830,1370,"AUTENTICAÇÃO BANCÁRIA (SOMENTE NAS 1 E 2 VIAS)",oFont10n)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Definicao do Quadro de aviso                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Say(nX+0680,600,"ATENÇÃO",oFont10n)
		oPrint:Say(nX+0740,040,"É vedado o recolhimento de tributos e contribuições administrados pela",oFont07)
		oPrint:Say(nX+0780,040,"Secretaria da Receita Federal cujo valor seja inferior a R$ 10,00. ",oFont07)
		oPrint:Say(nX+0820,040,"Ocorrendo tal situação, adicione esse valor ao tributo/contribuição de",oFont07)
		oPrint:Say(nX+0860,040,"mesmo código de períodos subsequentes, até que o total seja igual ou",oFont07)
		oPrint:Say(nX+0900,040,"superior a R$10,00.",oFont07)
		oPrint:Say(nX+0940,040,"Valores expressos em reais",oFont07)
		
		If mv_par05 == 1
			oPrint:Say(nX+1030,040,"Recolhido em nome de " + aInfo[nW][11],oFont07)
		Else
			oPrint:Say(nX+1030,040,"DARF Manual",oFont07)
		Endif	

		If nY == 1
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Definicao do picote                                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oPrint:Say(nX+1250,000,Replicate("-",132),oFont11)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Segunda via do Darf                                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
			nX := 1480
		EndIf
	Next nY
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Finaliza a pagina                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 	
	oPrint:EndPage()
Next nW
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Finaliza a Impressão                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oPrint:Preview()

Return(.T.)

Static Function FrSrfPai(cAliasSe2)
LOCAL nRegSE2:= NEWSE2->(Recno())
LOCAL lAchou:= .F.
LOCAL cPrefixo := (cAliasSe2)->E2_PREFIXO
LOCAL cNum		:= (cAliasSe2)->E2_NUM
LOCAL cParcela := (cAliasSe2)->E2_PARCELA
LOCAL cTipoPai	:= (cAliasSe2)->E2_TIPO
LOCAL cParcPai 
//LOCAL cValorcPai 
//Local aArea := GetArea()
Local lPai := .F.

If (cAliasSe2)->E2_TIPO $ MVTAXA+"/"+MVTXA
	If (cAliasSe2)->E2_FORNECE == GetMv("MV_MUNIC")
		cValorPai := "NEWSE2->E2_ISS" 
		cParcPai := "E2_PARCISS"
	Else
		Do Case 
		Case Alltrim((cAliasSe2)->E2_NATUREZ) $ AllTrim(GetMv("MV_PISAPNC")) 
			cValorPai := "NEWSE2->E2_PIS"
			cParcPai := "E2_PARCPIS"
		Case Alltrim((cAliasSe2)->E2_NATUREZ) $ AllTrim(GetMv("MV_COFAPUR")) 
			cValorPai := "NEWSE2->E2_COFINS"
			cParcPai := "E2_PARCCOF"
		Case Alltrim((cAliasSe2)->E2_NATUREZ) $ AllTrim(GetMv("MV_CSLL")) 
			cValorPai := "NEWSE2->E2_CSLL"
			cParcPai := "E2_PARCSLL"
		OtherWise
			cValorPai := "NEWSE2->E2_IRRF"
			cParcPai := "E2_PARCIR"
		EndCase	
	Endif
Else
	lPai := .T.	
Endif

// Se nao estiver no titulo pai, procura o titulo Pai.
If !lPai
	dbSelectArea("NEWSE2")
	dbSetOrder(1)
	nRegSE2:= Recno()
	If MsSeek(xFilial("SE2")+cPrefixo+cNum)
		While !Eof() .and. NEWSE2->(E2_FILIAL+E2_PREFIXO+E2_NUM) == xFilial("SE2")+cPrefixo+cNum
			If &(cParcPai) == cParcela .and. IIF(cTipoPai $ MVTXA,NEWSE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG,.T.)
				If &(cValorPai) != 0
					lAchou := .T.
					Exit
				EndIf
			EndIf
			DbSkip()
		Enddo
	EndIf
Endif
	
dbSelectArea("NEWSE2")
// Se nao encontrou o registro pai, restaura o ponteiro do alias alternativo
// Pois o registro pode ja estar posicionado no titulo principal.
If !lAchou .And. !lPai
	dbGoto(nRegSE2)
Elseif !lAchou
	NEWSE2->(MsSeek(xFilial("SE2")+(cAliasSe2)->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)))
Endif	

Return lAchou
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AjustaSX1 ºAutor  ³Sueli . dos Santos  º Data ³ 14/06/2007  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Criacao do grupo de perguntas                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       |CDAR011                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//LGS#20200131 - Adequação para release 12.1.25 e posteriores
/*
Static Function AjustaSX1(cPerg)    

Local aHelpP  := {}
Local aHelpE  := {}
Local aHelpS  := {}  
// mv_par01 - Vencimento Inicial?
Aadd( aHelpP, "Informe a data de vencimento inicial     " )
Aadd( aHelpE, "Informe a data de vencimento inicial     " )
Aadd( aHelpS, "Informe a data de vencimento inicial     " )
PutSX1(cPerg	,"01","Vencimento Inicial?","Vencimento Inicial?","Vencimento Inicial?","mv_ch1","D",8,0,0,"G"," "," "," "," ","mv_par01"," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," ",aHelpP,aHelpE,aHelpS) 

aHelpP := {}
aHelpE := {}
aHelpS := {}
// mv_par02 - Vencimento Final ?
Aadd( aHelpP, "Informe a data de vencimento final    " )
Aadd( aHelpE, "Informe a data de vencimento final    " )
Aadd( aHelpS, "Informe a data de vencimento final    " )
PutSX1(cPerg,"02","Vendimento final?","Vendimento final?","Vendimento final?","mv_ch2","D",8,0,0,"G"," "," "," "," ","mv_par02"," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," ",aHelpP,aHelpE,aHelpS) 

aHelpP := {}
aHelpE := {}
aHelpS := {}
// mv_par03 - Codigo srf
Aadd( aHelpP, "Informe código SRF Inicial" )
Aadd( aHelpE, "Informe código SRF Inicial" )
Aadd( aHelpS, "Informe código SRF Inicial" )
PutSX1(cPerg,"03","Codigo SRF Inicial?","Codigo SRF Inicial?","Codigo SRF Inicial?","mv_ch3","C",4,0,0,"G"," ","37"," "," ","mv_par03"," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," ",aHelpP,aHelpE,aHelpS) 

// mv_par04 - Codigo srf
Aadd( aHelpP, "Informe código SRF Final" )
Aadd( aHelpE, "Informe código SRF Final" )
Aadd( aHelpS, "Informe código SRF Final" )
PutSX1(cPerg,"04","Codigo SRF Final?","Codigo SRF Final?","Codigo SRF Final?","mv_ch4","C",4,0,0,"G"," ","37"," "," ","mv_par04"," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," ",aHelpP,aHelpE,aHelpS) 

aHelpP := {}
aHelpE := {}
aHelpS := {}
Aadd( aHelpP, "Agrupa por?" )
Aadd( aHelpE, "Agrupa por?" )
Aadd( aHelpS, "Agrupa por?" )
PutSx1( cPerg,"05","Agrupa por?" , "Agrupa por?" , "Agrupa por?" ,"mv_ch5","N",1,0,2,"C","","","","",;
				"mv_par05","1.Fornec./Cod.SRF","1.Fornec./Cod.SRF","1.Fornec./Cod.SRF","","2.Apenas Cod. SRF","2.Apenas Cod. SRF","2.Apenas Cod. SRF",;
				"","","","","","","","","",aHelpP,aHelpE,aHelpS)

aHelpP := {}
aHelpE := {}
aHelpS := {}
Aadd( aHelpP, "Periodo de Apuração?" )
Aadd( aHelpE, "Periodo de Apuração?" )
Aadd( aHelpS, "Periodo de Apuração?" )
PutSX1(cPerg,"06","Periodo de Apuração?","Periodo de Apuração?","Periodo de Apuração?","mv_ch6","D",8,0,0,"G"," "," "," "," ","mv_par06"," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," ",aHelpP,aHelpE,aHelpS) 

Return*/