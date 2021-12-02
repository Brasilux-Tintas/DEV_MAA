#Include "CTBR180.Ch"
#Include "PROTHEUS.Ch"
                                                                                                                 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±                                                    
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ CTBR180  ³ Autor ³ Cicero J. Silva   	³ Data ³ 04.08.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±                    
±±³Descri‡…o ³ Balancete Centro de Custo/Conta         			 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Ctbr180()    											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nenhum       											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso 		 ³ SIGACTB      											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±                            
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
user Function BRCTBR18()

Local aArea := GetArea()
Local oReport

Local lOk 			:= .T.
Local aCtbMoeda		:= {}
Local nDivide		:= 1

PRIVATE cTipoAnt	:= ""
PRIVATE cPerg	 	:= "CTR180"
PRIVATE nomeProg  := "CTBR180"
PRIVATE titulo
PRIVATE aSelFil	:= {}

CtAjustSx1(cPerg)


	U_DESPCC() // Executa versão anterior do fonte

RestArea(aArea)

Return

/*

------------------------------------------------------- RELESE 4 ---------------------------------------------------------------

*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ CTBR180R3³ Autor ³ Gustavo Henrique  	³ Data ³ 24.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Balancete Centro de Custo/Conta         			 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Ctbr180R3()    											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nenhum       											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso    	 ³ Generico     											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
user Function DESPCC()

Local aSetOfBook
Local aCtbMoeda		:= {}

Local cSayCC		:= CtbSayApro("CTT")
Local cDesc1 		:= OemToAnsi(STR0001)+ Upper(cSayCC)+ " / " + Upper(OemToAnsi(STR0021))	//"Este programa ira imprimir o Balancete de  / Conta "
Local cDesc2 		:= OemToansi(STR0002)  //"de acordo com os parametros solicitados pelo Usuario"
Local cString		:= "CT1"

Local lRet			:= .T.

Local nDivide		:= 1

Local wnrel
Local titulo 		:= OemToAnsi(STR0003)+ Upper(cSayCC)+ " / " +  Upper(OemToAnsi(STR0021))	//"Balancete de Verificacao  / Conta"
Local cArqTmp		:= ""
Local cCCSup		:= ""//Centro de Custo Superior do centro de custo atual


PRIVATE aReturn 	:= { OemToAnsi(STR0015), 1,OemToAnsi(STR0016), 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
PRIVATE aLinha		:= {}
PRIVATE cPerg	 	:= "CTR180"
PRIVATE nLastKey 	:= 0
PRIVATE nomeProg  	:= "CTBR180"
PRIVATE Tamanho		:="M"

//If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
//	Return
//EndIf

li 		:= 80
m_pag	:= 1

Pergunte("CTR180",.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros					  	   	³
//³ mv_par01				// Data Inicial              	       	³
//³ mv_par02				// Data Final                          	³
//³ mv_par03				// Conta Inicial                       	³
//³ mv_par04				// Conta Final  					   	³
//³ mv_par05				// Do Centro de Custo                  	³
//³ mv_par06				// Ate Centro de Custo                 	³
//³ mv_par07				// Imprime Contas: Sintet/Analit/Ambas 	³
//³ mv_par08				// Set Of Books				    	   	³
//³ mv_par09				// Saldos Zerados?			     	  	³
//³ mv_par10				// Moeda?          			     	   	³
//³ mv_par11				// Pagina Inicial  		     		   	³
//³ mv_par12				// Saldos? Reais / Orcados	/Gerenciais	³
//³ mv_par13				// Quebra por Grupo Contabil?		   	³
//³ mv_par14				// Imprimir ate o Segmento?			   	³
//³ mv_par15				// Filtra Segmento?					   	³
//³ mv_par16				// Conteudo Inicial Segmento?		   	³
//³ mv_par17				// Conteudo Final Segmento?		       	³
//³ mv_par18				// Conteudo Contido em?				   	³
//³ mv_par19				// Imprime Coluna Mov ?				   	³
//³ mv_par20				// Pula Pagina                         	³
//³ mv_par21				// Salta linha sintetica ?			    ³
//³ mv_par22				// Imprime valor 0.00    ?			    ³
//³ mv_par23				// Imprimir CC?Normal / Reduzido       	³
//³ mv_par24				// Divide por ?                   		³
//³ mv_par25				// Imprime Cod. Conta ? Normal/Reduzido ³
//³ mv_par26				// Posicao Ant. L/P? Sim / Nao         	³
//³ mv_par27 				// Data Lucros/Perdas?                	³
//³ mv_par28				// C.Custo ate o Segmento?			   	³
//³ mv_par29				// Filtra Segmento?					   	³
//³ mv_par30				// Conteudo Inicial Segmento?		   	³
//³ mv_par31				// Conteudo Final Segmento?		       	³
//³ mv_par32				// Conteudo Contido em?				   	³
//³ mv_par33				// Imprime C.C: Sintet/Analit/Ambas 	³
//³ mv_par34				// Rec./Desp. Anterior Zeradas?			³
//³ mv_par35				// Grupo Receitas/Despesas?      		³
//³ mv_par36				// Data de Zeramento Receita/Despesas?	³
//³ mv_par37				// Selecao de Filiais					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano³
//³ Gerencial -> montagem especifica para impressao)			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. mv_par37 == 1 .And. Len( aSelFil ) <= 0
	aSelFil := AdmGetFil()
	If Len( aSelFil ) <= 0
		lRet := .F.
	EndIf 
EndIf    

//wnrel	:= "CTBR180"            //Nome Default do relatorio em Disco
//wnrel := SetPrint(cString,wnrel,,@titulo,cDesc1,cDesc2,,.F.,"",,Tamanho)

//If nLastKey == 27
	//Set Filter To
	//Return
//Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano³
//³ Gerencial -> montagem especifica para impressao)			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ct040Valid(mv_par08)
	lRet := .F.
Else
	aSetOfBook := CTBSetOf(mv_par08)
Endif

If mv_par24 == 2			// Divide por cem
	nDivide := 100
ElseIf mv_par24 == 3		// Divide por mil
	nDivide := 1000
ElseIf mv_par24 == 4		// Divide por milhao
	nDivide := 1000000
EndIf

If lRet
	aCtbMoeda  	:= CtbMoeda(mv_par10,nDivide)
	If Empty(aCtbMoeda[1])
		Help(" ",1,"NOMOEDA")
		lRet := .F.
	Endif
Endif

If lRet
	If (mv_par34 == 1) .and. ( Empty(mv_par35) .or. Empty(mv_par36) )
		cMensagem	:= STR0023	// "Favor preencher os parametros Grupos Receitas/Despesas e Data Sld Ant. Receitas/Despesas ou "
		cMensagem	+= STR0024	// "deixar o parametro Ignora Sl Ant.Rec/Des = Nao "
		MsgAlert(cMensagem,STR0025) //"Ignora Sl Ant.Rec/Des"
		lRet    	:= .F.
	EndIf
EndIf

If !lRet
	Set Filter To
	Return
EndIf

If mv_par19 == 1			// Se imprime coluna movimento -> relatorio 220 colunas
	tamanho := "G"
EndIf

If nLastKey == 27
	Set Filter To
	Return
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao					     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dDataLP		:= mv_par27
lImpAntLP	:= Iif(mv_par26 == 1,.T.,.F.)
lVlrZerado	:= Iif(mv_par09==1,.T.,.F.)
lRecDesp0		:= Iif(mv_par34==1,.T.,.F.)
cRecDesp		:= mv_par35
dDtZeraRD		:= mv_par36
lCttSint 		:= Iif(mv_par33 == 1 .or. mv_par33 == 3,.T.,.F.)
l132			:= .T.

MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
						mv_par01,mv_par02,"CT3","",mv_par03,mv_par04,mv_par05,mv_par06,,,,,mv_par10,;
						mv_par12,aSetOfBook,mv_par15,mv_par16,mv_par17,mv_par18,;
						l132,.T.,,"CTT",lImpAntLP,dDataLP, nDivide,lVlrZerado,,,;
						mv_par29,mv_par30,mv_par31,mv_par32,,,,,,,,,aReturn[7],lRecDesp0,;
						cRecDesp,dDtZeraRD,,,,,,,,,aSelFil,,,,,,,,lCttSint)},;
				OemToAnsi(OemToAnsi(STR0014)),;  //"Criando Arquivo Tempor rio..."
				OemToAnsi(STR0003)+Upper(cSayCC)+ " / "+Upper(OemToAnsi(STR0021)))     //"Balancete Verificacao "

cArq1  := CriaTrab(NIL,.F.)
IndRegua("cArqTmp",cArq1,"DESCCC+CUSTO+TIPOCONTA+CONTA",,,"Selecionando dados...")

cEOL := "CHR(13)+CHR(10)"
cEOL := &cEOL

caminho := "C:\TEMP\despesas_" + dtos(mv_par01) + "_" + dtos(mv_par02) + ".xml"

nHdl := fCreate(caminho)
//If nHdl != -1 

//cabeçalho
_Str := '<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?><Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:o="urn:schemas-microsoft-com:office:office"  xmlns:x="urn:schemas-microsoft-com:office:excel"  xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"  xmlns:html="http://www.w3.org/TR/REC-html40">' + CEOL
_Str += '<Worksheet ss:Name="DESPESAS_' + dtos(mv_par01) + '_' + dtos(mv_par02) + '">' + CEOL
_Str += '<Table ss:ExpandedColumnCount="5" ss:ExpandedRowCount="695" x:FullColumns="1"  x:FullRows="1" ss:DefaultRowHeight="15">' + CEOL
_Str += '<Row>'+ CEOL
_Str += '<Cell><Data ss:Type="String">CENTRO DE CUSTO</Data></Cell><Cell><Data ss:Type="String">GRUPO</Data></Cell>'+ CEOL
_Str += '<Cell><Data ss:Type="String">SUBGRUPO</Data></Cell>'+ CEOL
_Str += '<Cell><Data ss:Type="String">RUBRICA</Data></Cell>'+ CEOL
_Str += '<Cell><Data ss:Type="String">VALOR</Data></Cell>'+ CEOL
_Str += '</Row>' + CEOL
fWrite(nHdl,_Str,Len(_Str))

DbSelectArea("cArqTmp")
DbGotop()

aSint := {}
cCCAnt := cArqTmp->CUSTO

while !eof()
	if alltrim(cArqTmp->TIPOCONTA) == '1'
		if cCCAnt <> cArqTmp->CUSTO
			aSint := {}
			cCCAnt := cArqTmp->CUSTO
		endif
		if len(alltrim(cArqTmp->CONTA))==3 .or. len(alltrim(cArqTmp->CONTA))==5 
			aadd(aSint,{cArqTmp->CONTA,cArqTmp->DESCCTA,cArqTmp->SUPERIOR})
		endif
	else
		if cArqTmp->(SALDODEB - SALDOCRD) > 0 //teve despesa
			conta5 := cArqTmp->DESCCTA
			valor  := cArqTmp->(SALDODEB) //- SALDOCRD)
			
			conta3 := ""
			conta4 := ""
			nPosAux := aScan(aSint, { | _x | _x[1] == cArqTmp->SUPERIOR } )
			if nPosAux > 0
				conta4 := aSint[nPosAux][2]
				nPosAux := aScan(aSint, { | _x | _x[1] == aSint[nPosAux][3] } )
				if nPosAux > 0
					conta3 := aSint[nPosAux][2]
				endif
			endif
			
			_Str :='<Row>' + CEOL
			_Str +='<Cell><Data ss:Type="String">' + cArqTmp->DESCCC + '</Data></Cell>' + CEOL
    		_Str +='<Cell><Data ss:Type="String">' + conta3 + '</Data></Cell>' + CEOL
    		_Str +='<Cell><Data ss:Type="String">' + conta4 + '</Data></Cell>' + CEOL
    		_Str +='<Cell><Data ss:Type="String">' + conta5 + '</Data></Cell>' + CEOL
    		_Str +='<Cell><Data ss:Type="Number">' + alltrim(str(valor)) + '</Data></Cell>' + CEOL
			_Str +='</Row>' + CEOL
			
			//_Str := cArqTmp->DESCCC + '|' + conta3 + '|' + conta4 + '|' + conta5 + '|' + strtran(alltrim(str(valor)),'.',',') +  CEOL
			fWrite(nHdl,_Str,Len(_Str))
		ENDIF
	endif
	
	dbskip()
enddo

_Str :='</Table></Worksheet></Workbook>' //+ CEOL
fWrite(nHdl,_Str,Len(_Str))
                  
fClose(nHdl)                  

msginfo("Arquivo de custos gerado com sucesso: '" + caminho + "'")

Return

