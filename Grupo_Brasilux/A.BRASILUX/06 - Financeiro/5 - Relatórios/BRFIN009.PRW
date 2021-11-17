/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ BRFINR009 ³ Autor ³ Cleber O. Domingues  ³ Data ³ 14.01.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Posi‡„o dos Titulos a Receber 							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRFIN009()
Local cDesc1 :=OemToAnsi("Imprime a posi‡„o dos titulos a receber relativo a data ba-")  //"Imprime a posi‡„o dos titulos a receber relativo a data ba-"
Local cDesc2 :=OemToAnsi("se do sistema.")  //"se do sistema."
Local cDesc3 :=""
Local wnrel
Local cString:="SE1"
Local nRegEmp:=SM0->(RecNo())
Local dOldDtBase := dDataBase

Private titulo  :=""
Private cabec1  :=""
Private cabec2  :=""
Private cPerg   :="BRFIN130"

Private aLinha  :={}
Private aReturn :={ OemToAnsi("Zebrado"), 1,OemToAnsi("Administracao"), 1, 2, 1, "",1 }  //"Zebrado"###"Administracao"
Private nJuros  :=0
Private nLastKey:=0
Private nomeprog:="BRFIN009"
Private tamanho :="G"
     
  if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Defini‡„o dos cabe‡alhos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
titulo := OemToAnsi("Posicao dos Titulos a Receber")  //"Posicao dos Titulos a Receber"
cabec1 := OemToAnsi("Codigo Nome do Cliente      Prf-Numero         TP  Natureza    Data de  Vencto   Vencto  Banco  Valor Original |        Titulos Vencidos          | Titulos a Vencer | Num        Vlr.juros ou  Dias   Historico     ")  //"Codigo Nome do Cliente      Prf-Numero         TP  Natureza    Data de  Vencto   Vencto  Banco  Valor Original |        Titulos Vencidos          | Titulos a Vencer | Num        Vlr.juros ou  Dias   Historico     "
cabec2 := OemToAnsi("                            Parcela                            Emissao  Titulo    Real                         |  Valor Nominal   Valor Corrigido |   Valor Nominal  | Banco       permanencia  Atraso               ")  //"                            Parcela                            Emissao  Titulo    Real                         |  Valor Nominal   Valor Corrigido |   Valor Nominal  | Banco       permanencia  Atraso               "

CriaSX1(cPerg)
Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros   ³
//³ mv_par01		 // Do Cliente 		   ³
//³ mv_par02		 // Ate o Cliente 	   ³
//³ mv_par03		 // Do Prefixo 		   ³
//³ mv_par04		 // Ate o prefixo 	   ³
//³ mv_par05		 // Do Titulo	       ³
//³ mv_par06		 // Ate o Titulo	   ³
//³ mv_par07		 // Do Banco		   ³
//³ mv_par08		 // Ate o Banco		   ³
//³ mv_par09		 // Do Vencimento 	   ³
//³ mv_par10		 // Ate o Vencimento   ³
//³ mv_par11		 // Da Natureza		   ³
//³ mv_par12		 // Ate a Natureza     ³
//³ mv_par13		 // Da Emissao 		   ³
//³ mv_par14		 // Ate a Emissao 	   ³
//³ mv_par15		 // Qual Moeda 		   ³
//³ mv_par16		 // Imprime provisorios³
//³ mv_par17		 // Reajuste pelo vecto³
//³ mv_par18		 // Impr Tit em Descont³
//³ mv_par19		 // Relatorio Anal/Sint³
//³ mv_par20		 // Consid Data Base?  ³
//³ mv_par21		 // Consid Filiais  ?  ³
//³ mv_par22		 // da filial          ³
//³ mv_par23		 // a flial            ³
//³ mv_par24		 // Da loja            ³
//³ mv_par25		 // Ate a loja         ³
//³ mv_par26		 // Consid Adiantam.?  ³
//³ mv_par27		 // Da data contab. ?  ³
//³ mv_par28		 // Ate data contab.?  ³
//³ mv_par29		 // Imprime Nome    ?  ³
//³ mv_par30		 // Outras Moedas   ?  ³
//³ mv_par31       // Imprimir os Tipos  ³
//³ mv_par32       // Nao Imprimir Tipos ³
//³ mv_par33       // Listar abatimentos ³
//³ mv_par34       // Consid. Fluxo Caixa³
//³ mv_par35       // Salt Pag por Client³
//³ mv_par36       // Ignora abatimentos ³
//³ mv_par37       // Data Base          ³
//³ mv_par38       // Verifica Baixa por ³
//³ mv_par39       // Filtra Lucros/Perdas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a fun‡„o SETPRINT ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

#IFDEF TOP
	IF TcSrvType() == "AS/400" .and. Select("__SE1") == 0
		ChkFile("SE1",.f.,"__SE1")
	Endif
#ENDIF

wnrel:="BRFINR130"            //Nome Default do relatorio em Disco
aOrd :={	OemToAnsi("Por Cliente"),;	//"Por Cliente"
	OemToAnsi("Por Prefixo/Numero"),;	//"Por Prefixo/Numero"
	OemToAnsi("Por Banco"),; //"Por Banco"
	OemToAnsi("Por Venc/Cli"),;	//"Por Venc/Cli"
	OemToAnsi("Por Natureza"),;	//"Por Natureza"
	OemToAnsi("Por Emissao"),; //"Por Emissao"
	OemToAnsi("Por Ven\Bco"),;	//"Por Ven\Bco"
	OemToAnsi("Por Cod.Cli."),; //"Por Cod.Cli."
	OemToAnsi("Banco/Situacao"),; //"Banco/Situacao"
	OemToAnsi("Por Numero/Tipo/Prefixo"),; //"Por Numero/Tipo/Prefixo"
	OemToAnsi("Por Vendedor/Cli") }

wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

RptStatus({|lEnd| BFA130Imp(@lEnd,wnRel,cString)},titulo)  // Chamada do Relatorio

SM0->(dbGoTo(nRegEmp))
cFilAnt := SM0->M0_CODFIL

//Acerta a database de acordo com a database real do sistema
If mv_par20 == 1    // Considera Data Base
	dDataBase := dOldDtBase
Endif	

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FA130Imp ³ Autor ³ Paulo Boschetti		³ Data ³ 01.06.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime relat¢rio dos T¡tulos a Receber			    	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FA130Imp(lEnd,WnRel,cString)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd	  - A‡Æo do Codeblock				    			  ³±±
±±³			 ³ wnRel   - T¡tulo do relat¢rio 							  ³±±
±±³			 ³ cString - Mensagem										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function BFA130Imp(lEnd,WnRel,cString)
Local CbCont
Local CbTxt
//Local limite := 220
Local nOrdem
Local lContinua := .T.
Local _nComp := GetMv("MV_COMP")
Local cCond1,cCond2,cCarAnt
Local nTit0:=0
Local nTit1:=0
Local nTit2:=0
Local nTit3:=0
Local nTit4:=0
Local nTit5:=0
Local nTotJ:=0
Local nTot0:=0
Local nTot1:=0
Local nTot2:=0
Local nTot3:=0
Local nTot4:=0
Local nTotTit:=0
Local nTotJur:=0
Local nTotFil0:=0
Local nTotFil1:=0
Local nTotFil2:=0
Local nTotFil3:=0
Local nTotFil4:=0
Local nTotFilTit:=0
Local nTotFilJ:=0
//Local aCampos:={}
//Local aTam:={}
Local nAtraso:=0
Local nTotAbat:=0
Local nSaldo:=0
Local dDataReaj
Local dDataAnt := dDataBase
Local lQuebra
Local nMesTit0 := 0
Local nMesTit1 := 0
Local nMesTit2 := 0
Local nMesTit3 := 0
Local nMesTit4 := 0
Local nMesTTit := 0
Local nMesTitj := 0
Local cIndexSe1
Local cChaveSe1
Local nIndexSE1
Local dDtContab
Local cTipos  := ""
Local aStru := SE1->(dbStruct()), ni
Local nTotsRec := SE1->(RecCount())
Local aTamCli := TAMSX3("E1_CLIENTE")
// variavel  abaixo criada p/pegar o nr de casas decimais da moeda
Local ndecs := Msdecimais(mv_par15)

Private nRegSM0 := SM0->(Recno())
Private nAtuSM0 := SM0->(Recno())
PRIVATE dBaixa := dDataBase
PRIVATE cFilDe,cFilAte

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para Filtrar os tipos sem entrar na tela do ³
//³ FINRTIPOS(), localizacao Argentina.                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄJose Lucas, Localiza‡”es ArgentinaÄÙ
IF EXISTBLOCK("F130FILT")
	cTipos	:=	EXECBLOCK("F130FILT",.f.,.f.)
ENDIF

nOrdem:=aReturn[8]
cMoeda:=Str(mv_par15,1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Vari veis utilizadas para Impress„o do Cabe‡alho e Rodap‚ ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt 	:= "Teste" //OemtoAnsi(STR0046)
cbcont	:= 1
li 		:= 80
m_pag 	:= 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ POR MAIS ESTRANHO QUE PARE€A, ESTA FUNCAO DEVE SER CHAMADA AQUI! ³
//³                                                                  ³
//³ A fun‡„o SomaAbat reabre o SE1 com outro nome pela ChkFile para  ³
//³ efeito de performance. Se o alias auxiliar para a SumAbat() n„o  ³
//³ estiver aberto antes da IndRegua, ocorre Erro de & na ChkFile,   ³
//³ pois o Filtro do SE1 uptrapassa 255 Caracteres.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SomaAbat("","","","R")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atribui valores as variaveis ref a filiais                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par21 == 2
	cFilDe  := cFilAnt
	cFilAte := cFilAnt
ELSE
	cFilDe := mv_par22	// Todas as filiais
	cFilAte:= mv_par23
Endif

//Acerta a database de acordo com o parametro
If mv_par20 == 1    // Considera Data Base
	dDataBase := mv_par37
Endif	

dbSelectArea("SM0")
dbSeek(cEmpAnt+cFilDe,.T.)

nRegSM0 := SM0->(Recno())
nAtuSM0 := SM0->(Recno())

While !Eof() .and. M0_CODIGO == cEmpAnt .and. M0_CODFIL <= cFilAte
	
	dbSelectArea("SE1")
	cFilAnt := SM0->M0_CODFIL
	Set Softseek On
	
	If mv_par19 == 1
		titulo := titulo + OemToAnsi(" - Analitico")  //" - Analitico"
	Else
		titulo := titulo + OemToAnsi(" - Sintetico")  //" - Sintetico"
		cabec1 := OemToAnsi("                                                                                                               |        Titulos Vencidos          | Titulos a Vencer |            Vlr.juros ou             (Vencidos+Vencer)")
		cabec2 := OemToAnsi("                                                                                                               |  Valor Nominal   Valor Corrigido |   Valor Nominal  |             permanencia                              ")
	EndIf
	
	#IFDEF TOP
		if TcSrvType() != "AS/400"
			cQuery := "SELECT * "
			cQuery += "  FROM "+	RetSqlName("SE1")
			cQuery += " WHERE E1_FILIAL = '" + xFilial("SE1") + "'"
			cQuery += "   AND D_E_L_E_T_ <> '*' "
		endif
	#ENDIF
	
	IF nOrdem = 1
		cChaveSe1 := "E1_FILIAL+E1_NOMCLI+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO"
		#IFDEF TOP
			if TcSrvType() == "AS/400"
				cIndexSe1 := CriaTrab(nil,.f.)
				IndRegua("SE1",cIndexSe1,cChaveSe1,,Fr130IndR(),OemToAnsi("Seleccionando Registros..."))
				nIndexSE1 := RetIndex("SE1")
				dbSetOrder(nIndexSe1+1)
				dbSeek(xFilial("SE1"))
			else
				cOrder := SqlOrder(cChaveSe1)
			endif
		#ELSE
			cIndexSe1 := CriaTrab(nil,.f.)
			IndRegua("SE1",cIndexSe1,cChaveSe1,,Fr130IndR(),OemToAnsi("Seleccionando Registros..."))
			nIndexSE1 := RetIndex("SE1")
			dbSetIndex(cIndexSe1+OrdBagExt())
			dbSetOrder(nIndexSe1+1)
			dbSeek(xFilial("SE1"))
		#ENDIF
		cCond1 := "E1_CLIENTE <= mv_par02"
		cCond2 := "E1_CLIENTE + E1_LOJA"
		titulo := titulo + OemToAnsi(" - Por Cliente")  //" - Por Cliente"
		
	Elseif nOrdem = 2
		SE1->(dbSetOrder(1))
		#IFNDEF TOP
			dbSeek(cFilial+mv_par03+mv_par05)
		#ELSE
			if TcSrvType() == "AS/400"
				dbSeek(cFilial+mv_par03+mv_par05)
			else
				cOrder := SqlOrder(IndexKey())
			endif
		#ENDIF
		cCond1 := "E1_NUM <= mv_par06"
		cCond2 := "E1_NUM"
		titulo := titulo + OemToAnsi(" - Por Numero")
	Elseif nOrdem = 3
		SE1->(dbSetOrder(4))
		#IFNDEF TOP
			dbSeek(cFilial+mv_par07)
		#ELSE
			if TcSrvType() == "AS/400"
				dbSeek(cFilial+mv_par07)
			else
				cOrder := SqlOrder(IndexKey())
			endif
		#ENDIF
		cCond1 := "E1_PORTADO <= mv_par08"
		cCond2 := "E1_PORTADO"
		titulo := titulo + OemToAnsi(" - Por Banco")
	Elseif nOrdem = 4
		SE1->(dbSetOrder(7))
		#IFNDEF TOP
			dbSeek(cFilial+DTOS(mv_par09))
		#ELSE
			if TcSrvType() == "AS/400"
				dbSeek(cFilial+DTOS(mv_par09))
			else
				cOrder := SqlOrder(IndexKey())
			endif
		#ENDIF
		cCond1 := "E1_VENCREA <= mv_par10"
		cCond2 := "E1_VENCREA"
		titulo := titulo + OemToAnsi(" - Por Data de Vencimento")
	Elseif nOrdem = 5
		SE1->(dbSetOrder(3))
		#IFNDEF TOP
			dbSeek(cFilial+mv_par11)
		#ELSE
			if TcSrvType() == "AS/400"
				dbSeek(cFilial+mv_par11)
			else
				cOrder := SqlOrder(IndexKey())
			endif
		#ENDIF
		cCond1 := "E1_NATUREZ <= mv_par12"
		cCond2 := "E1_NATUREZ"
		titulo := titulo + OemToAnsi(" - Por Natureza")
	Elseif nOrdem = 6
		SE1->(dbSetOrder(6))
		#IFNDEF TOP
			dbSeek( cFilial+DTOS(mv_par13))
		#ELSE
			if TcSrvType() == "AS/400"
				dbSeek( cFilial+DTOS(mv_par13))
			else
				cOrder := SqlOrder(IndexKey())
			endif
		#ENDIF
		cCond1 := "E1_EMISSAO <= mv_par14"
		cCond2 := "E1_EMISSAO"
		titulo := titulo + OemToAnsi(" - Por Emissao")
	Elseif nOrdem == 7
		cChaveSe1 := "E1_FILIAL+DTOS(E1_VENCREA)+E1_PORTADO+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO"
		#IFNDEF TOP
			cIndexSe1 := CriaTrab(nil,.f.)
			IndRegua("SE1",cIndexSe1,cChaveSe1,,Fr130IndR(),OemToAnsi("Seleccionando Registros..."))
			nIndexSE1 := RetIndex("SE1")
			dbSetIndex(cIndexSe1+OrdBagExt())
			dbSetOrder(nIndexSe1+1)
			dbSeek(xFilial("SE1"))
		#ELSE
			if TcSrvType() == "AS/400"
				cIndexSe1 := CriaTrab(nil,.f.)
				IndRegua("SE1",cIndexSe1,cChaveSe1,,Fr130IndR(),OemToAnsi("Seleccionando Registros..."))
				nIndexSE1 := RetIndex("SE1")
				dbSetOrder(nIndexSe1+1)
				dbSeek(xFilial("SE1"))
			else
				cOrder := SqlOrder(cChaveSe1)
			endif
		#ENDIF
		cCond1 := "E1_VENCREA <= mv_par10"
		cCond2 := "DtoS(E1_VENCREA)+E1_PORTADO"
		titulo := titulo + OemToAnsi(" - Por Vencto/Banco")
	Elseif nOrdem = 8
		SE1->(dbSetOrder(2))
		#IFNDEF TOP
			dbSeek(cFilial+mv_par01,.T.)
		#ELSE
			if TcSrvType() == "AS/400"
				dbSeek(cFilial+mv_par01,.T.)
			else
				cOrder := SqlOrder(IndexKey())
			endif
		#ENDIF
		cCond1 := "E1_CLIENTE <= mv_par02"
		cCond2 := "E1_CLIENTE"
		titulo := titulo + OemToAnsi(" - Por Cod.Cliente")
	Elseif nOrdem = 9
		cChave := "E1_FILIAL+E1_PORTADO+E1_SITUACA+E1_NOMCLI+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO"
		#IFNDEF TOP
			dbSelectArea("SE1")
			cIndex := CriaTrab(nil,.f.)
			IndRegua("SE1",cIndex,cChave,,fr130IndR(),OemToAnsi("Seleccionando Registros..."))
			nIndex := RetIndex("SE1")
			dbSetIndex(cIndex+OrdBagExt())
			dbSetOrder(nIndex+1)
			dbSeek(xFilial("SE1"))
		#ELSE
			if TcSrvType() == "AS/400"
				dbSelectArea("SE1")
				cIndex := CriaTrab(nil,.f.)
				IndRegua("SE1",cIndex,cChave,,fr130IndR(),OemToAnsi("Seleccionando Registros..."))
				nIndex := RetIndex("SE1")
				dbSetOrder(nIndex+1)
				dbSeek(xFilial("SE1"))
			else
				cOrder := SqlOrder(cChave)
			endif
		#ENDIF
		cCond1 := "E1_PORTADO <= mv_par08"
		cCond2 := "E1_PORTADO+E1_SITUACA"
		titulo := titulo + OemToAnsi(" - Por Banco e Situacao")
	ElseIf nOrdem == 10
		cChave := "E1_FILIAL+E1_NUM+E1_TIPO+E1_PREFIXO+E1_PARCELA"
		#IFNDEF TOP
			dbSelectArea("SE1")
			cIndex := CriaTrab(nil,.f.)
			IndRegua("SE1",cIndex,cChave,,,OemToAnsi("Seleccionando Registros..."))
			nIndex := RetIndex("SE1")
			dbSetIndex(cIndex+OrdBagExt())
			dbSetOrder(nIndex+1)
			dbSeek(xFilial("SE1")+mv_par05)
		#ELSE
   	   if TcSrvType() == "AS/400"
				dbSelectArea("SE1")
				cIndex := CriaTrab(nil,.f.)
				IndRegua("SE1",cIndex,cChave,,,OemToAnsi("Seleccionando Registros..."))
				nIndex := RetIndex("SE1")
				dbSetOrder(nIndex+1)
				dbSeek(xFilial("SE1")+mv_par05)
			else
				cOrder := SqlOrder(cChave)
			endif
		#ENDIF
		cCond1 := "E1_NUM <= mv_par06"
		cCond2 := "E1_NUM"
		titulo := titulo + OemToAnsi(" - Numero/Prefixo")
	elseif nOrdem = 11
		cChaveSe1 := "E1_FILIAL+E1_VEND1+E1_CLIENTE+DTOS(E1_VENCREA)+E1_PREFIXO+E1_NUM+E1_PARCELA"
		// "E1_FILIAL+E1_VEND1+DTOS(E1_VENCREA)+E1_NOMCLI+E1_PREFIXO+E1_NUM+E1_PARCELA"
		cOrder := SqlOrder(cChaveSe1)
		cCond1 := "E1_VEND1 <= 'ZZZZZZ'"
		cCond2 := "E1_VEND1" // E1_CLIENTE + E1_LOJA"
		titulo := titulo + OemToAnsi(" - Por Vendedor")
	Endif
	
	If mv_par19 == 1
		titulo := titulo + OemToAnsi(" - Analitico")
	Else
		titulo := titulo + OemToAnsi(" - Sintetico")
		cabec1 := OemToAnsi("Nome do Cliente      |        Titulos Vencidos          | Titulos a Vencer |            Vlr.juros ou             (Vencidos+Vencer)")
		cabec2 := OemToAnsi("|  Valor Nominal   Valor Corrigido |   Valor Nominal  |             permanencia                              ")
	EndIf
	
	cFilterUser:=aReturn[7]
	Set Softseek Off
	
	#IFDEF TOP
		if TcSrvType() != "AS/400"
			cQuery += " AND E1_CLIENTE between '" + mv_par01        + "' AND '" + mv_par02 + "'"
			cQuery += " AND E1_PREFIXO between '" + mv_par03        + "' AND '" + mv_par04 + "'"
			cQuery += " AND E1_NUM     between '" + mv_par05        + "' AND '" + mv_par06 + "'"
			cQuery += " AND E1_PORTADO between '" + mv_par07        + "' AND '" + mv_par08 + "'"
			cQuery += " AND E1_VENCREA between '" + DTOS(mv_par09)  + "' AND '" + DTOS(mv_par10) + "'"
			cQuery += " AND (E1_MULTNAT = '1' OR (E1_NATUREZ BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"'))"
			cQuery += " AND E1_EMISSAO between '" + DTOS(mv_par13)  + "' AND '" + DTOS(mv_par14) + "'"
			cQuery += " AND E1_LOJA    between '" + mv_par24        + "' AND '" + mv_par25 + "'"
			cQuery += " AND E1_EMISSAO <=      '" + DTOS(mv_par37)  + "'"
			cQuery += " AND ((E1_EMIS1  Between '"+ DTOS(mv_par27)+"' AND '"+DTOS(mv_par28)+"') OR E1_EMISSAO Between '"+DTOS(mv_par27)+"' AND '"+DTOS(mv_par28)+"')"
			If !Empty(mv_par31) // Deseja imprimir apenas os tipos do parametro 31
				cQuery += " AND E1_TIPO IN "+FormatIn(mv_par31,";")
			ElseIf !Empty(Mv_par32) // Deseja excluir os tipos do parametro 32
				cQuery += " AND E1_TIPO NOT IN "+FormatIn(mv_par32,";")
			EndIf
			If mv_par18 == 2
				cQuery += " AND E1_SITUACA NOT IN ('2','7')"
			Endif
			If mv_par20 == 2
				cQuery += ' AND E1_SALDO <> 0'
			Endif
			If mv_par34 == 1
				cQuery += " AND E1_FLUXO <> 'N'"
			Endif
			cQuery += " ORDER BY "+ cOrder
			
			cQuery := ChangeQuery(cQuery)
			
			dbSelectArea("SE1")
			dbCloseArea()
			dbSelectArea("SA1")
			
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE1', .F., .T.)
			
			For ni := 1 to Len(aStru)
				If aStru[ni,2] != 'C'
					TCSetField('SE1', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
				Endif
			Next
		endif
	#ENDIF
	SetRegua(nTotsRec)
	
	If MV_MULNATR .And. nOrdem == 5
		Finr135(cTipos, lEnd, @nTot0, @nTot1, @nTot2, @nTot3, @nTotTit, @nTotJ )
		#IFDEF TOP
			If TcSrvType() != "AS/400"
				dbSelectArea("SE1")
				dbCloseArea()
				ChKFile("SE1")
				dbSelectArea("SE1")
				dbSetOrder(1)
			Endif
		#ENDIF
		If Empty(xFilial("SE1"))
			Exit
		Endif
		dbSelectArea("SM0")
		dbSkip()
		Loop
	Endif
	
	While &cCond1 .and. !Eof() .and. lContinua .and. E1_FILIAL == xFilial("SE1")
		
		IF	lEnd
			@PROW()+1,001 PSAY OemToAnsi("CANCELADO PELO OPERADOR")
			Exit
		Endif
		
		IncRegua()
		
		Store 0 To nTit1,nTit2,nTit3,nTit4,nTit5
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega data do registro para permitir ³
		//³ posterior analise de quebra por mes.   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dDataAnt := Iif(nOrdem == 6 , SE1->E1_EMISSAO,  SE1->E1_VENCREA)
		
		cCarAnt := &cCond2
		
		While &cCond2==cCarAnt .and. !Eof() .and. lContinua .and. E1_FILIAL == xFilial("SE1")
			
			IF lEnd
				@PROW()+1,001 PSAY OemToAnsi("CANCELADO PELO OPERADOR")
				lContinua := .F.
				Exit
			EndIF
			
			IncRegua()
			
			dbSelectArea("SE1")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Filtrar com base no Pto de entrada do Usuario...             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄJose Lucas, Localiza‡”es ArgentinaÄÙ
			If !Empty(cTipos)
				If !(SE1->E1_TIPO $ cTipos)
					dbSkip()
					Loop
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Considera filtro do usuario                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cFilterUser).and.!(&cFilterUser)
				dbSkip()
				Loop
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Filtrar Lucros e Perdas(Natur 801004)-Cleber(14-07-03)          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (mv_par39 == 1) .and. (SE1->E1_NATUREZ = '801004')
				dbSkip()
				Loop
			Endif


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se titulo, apesar do E1_SALDO = 0, deve aparecer ou ³
			//³ nÆo no relat¢rio quando se considera database (mv_par20 = 1) ³
			//³ ou caso nÆo se considere a database, se o titulo foi totalmen³
			//³ te baixado.																  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SE1")
			IF !Empty(SE1->E1_BAIXA) .and. Iif(mv_par20 == 2 ,SE1->E1_SALDO == 0 ,;
					IIF(mv_par38 == 1,(SE1->E1_SALDO == 0 .and. SE1->E1_BAIXA <= dDataBase),.F.))
				dbSkip()
				Loop
			EndIF
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se trata-se de abatimento ou somente titulos³
			//³ at‚ a data base. 									         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF (SE1->E1_TIPO $ MVABATIM .And. mv_par33 != 1) .Or.;
				SE1->E1_EMISSAO>dDataBase
				dbSkip()
				Loop
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se ser  impresso titulos provis¢rios		   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF E1_TIPO $ MVPROVIS .and. mv_par16 == 2
				dbSkip()
				Loop
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se ser  impresso titulos de Adiantamento	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF SE1->E1_TIPO $ MVRECANT .and. mv_par26 == 2
				dbSkip()
				Loop
			Endif
			
			// dDtContab para casos em que o campo E1_EMIS1 esteja vazio
			dDtContab := Iif(Empty(SE1->E1_EMIS1),SE1->E1_EMISSAO,SE1->E1_EMIS1)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se esta dentro dos parametros ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SE1")
			IF SE1->E1_CLIENTE < mv_par01 .OR. SE1->E1_CLIENTE > mv_par02 .OR. ;
				SE1->E1_PREFIXO < mv_par03 .OR. SE1->E1_PREFIXO > mv_par04 .OR. ;
				SE1->E1_NUM	 	 < mv_par05 .OR. SE1->E1_NUM 		> mv_par06 .OR. ;
				SE1->E1_PORTADO < mv_par07 .OR. SE1->E1_PORTADO > mv_par08 .OR. ;
				SE1->E1_VENCREA < mv_par09 .OR. SE1->E1_VENCREA > mv_par10 .OR. ;
				SE1->E1_NATUREZ < mv_par11 .OR. SE1->E1_NATUREZ > mv_par12 .OR. ;
				SE1->E1_EMISSAO < mv_par13 .OR. SE1->E1_EMISSAO > mv_par14 .OR. ;
				SE1->E1_LOJA    < mv_par24 .OR. SE1->E1_LOJA    > mv_par25 .OR. ;
				dDtContab       < mv_par27 .OR. dDtContab       > mv_par28 .OR. ;
				SE1->E1_EMISSAO > dDataBase .Or. !&(fr130IndR())
				dbSkip()
				Loop
			Endif
			
			If mv_par18 == 2 .and. E1_SITUACA $ "27"
				dbSkip()
				Loop
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se deve imprimir outras moedas³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par30 == 2 // nao imprime
				if SE1->E1_MOEDA != mv_par15 //verifica moeda do campo=moeda parametro
					dbSkip()
					Loop
				endif
			Endif
			dDataReaj := IIF(SE1->E1_VENCREA < dDataBase ,;
				IIF(mv_par17=1,dDataBase,E1_VENCREA),;
				dDataBase)
			
			If mv_par20 == 1	// Considera Data Base
				nSaldo :=SaldoTit(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE,mv_par15,dDataReaj,,SE1->E1_LOJA,,IIF(mv_par38 == 1,.F.,.T.))
			Else
				nSaldo := xMoeda((SE1->E1_SALDO+SE1->E1_SDACRES-SE1->E1_SDDECRE),SE1->E1_MOEDA,mv_par15,dDataReaj,ndecs+1)
			Endif
			
			If ! SE1->E1_TIPO $ MVABATIM
				If ! (SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG) .And. ;
					!( MV_PAR20 == 2 .And. nSaldo == 0 )                     	// deve olhar abatimento pois e zerado o saldo na liquidacao final do titulo
					nSaldo-=SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",mv_par15,dDataReaj,SE1->E1_CLIENTE,SE1->E1_LOJA)
				EndIf
			Endif	
			nSaldo:=Round(NoRound(nSaldo,3),2)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Desconsidera caso saldo seja menor ou igual a zero   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nSaldo <= 0
				dbSkip()
				Loop
			Endif
			
	
			dbSelectArea("SA1")
			MSSeek(cFilial+SE1->E1_CLIENTE+SE1->E1_LOJA)
			dbSelectArea("SA6")
			MSSeek(cFilial+SE1->E1_PORTADO)
			dbselectarea("SA3")            
			MSSeek(cFilial+SE1->E1_VEND1)
			dbSelectArea("SE1")
			
			IF li > 58
				nAtuSM0 := SM0->(Recno())
				SM0->(dbGoto(nRegSM0))
				//LGS#20200130 - Adequação para release 12.1.25 e posteirores
				//cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
				cabec( titulo, cabec1, cabec2, nomeprog, tamanho, _nComp )
				SM0->(dbGoTo(nAtuSM0))
			EndIF
			
			If mv_par19 == 1
				@li,	0 PSAY SE1->E1_CLIENTE + "-" + SE1->E1_LOJA + "-" +;
					SubStr( SE1->E1_NOMCLI, 1, 17 )
				li := IIf (aTamCli[1] > 6,li+1,li)
				@li, 28 PSAY SE1->E1_PREFIXO+"-"+alltrim(SE1->E1_NUM)+"-"+SE1->E1_PARCELA
				If SE1->E1_TIPO$MVABATIM
					@li,46 PSAY "["
				Endif	
				@li, 47 PSAY SE1->E1_TIPO
				If SE1->E1_TIPO$MVABATIM
					@li,50 PSAY "]"
				Endif
				@li, 51 PSAY SE1->E1_NATUREZ
				@li, 62 PSAY SE1->E1_EMISSAO
				@li, 73 PSAY SE1->E1_VENCTO
				@li, 84 PSAY SE1->E1_VENCREA
				@li, 95 PSAY SE1->E1_PORTADO+" "+SE1->E1_SITUACA
				@li,101 PSAY xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1) * If(SE1->E1_TIPO$MVABATIM, -1,1) Picture PesqPict("SE1","E1_VALOR",14,MV_PAR15)
			Endif
			
			If dDataBase > E1_VENCREA	//vencidos
				If mv_par19 == 1
					If !(SE1->E1_TIPO $ MVABATIM)				
						@li, 116 PSAY nSaldo  Picture PesqPict("SE1","E1_SALDO",14,MV_PAR15)
					Endif
				EndIf
				nJuros:=0
				fa070Juros(mv_par15)
				dbSelectArea("SE1")
				If mv_par19 == 1
					If !(SE1->E1_TIPO $ MVABATIM)				
						@li,133 PSAY nSaldo+nJuros Picture PesqPict("SE1","E1_SALDO",14,MV_PAR15)
					Endif
				EndIf
				If SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG
					nTit0 -= xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1)
					nTit1 -= (nSaldo)
					nTit2 -= (nSaldo+nJuros)
					nMesTit0 -= xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1)
					nMesTit1 -= (nSaldo)
					nMesTit2 -= (nSaldo+nJuros)
					nTotJur  -= nJuros
					nMesTitj -= nJuros
					nTotFilJ -= nJuros
				Else
					If !SE1->E1_TIPO $ MVABATIM
						nTit0 += xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1)
						nTit1 += (nSaldo)
						nTit2 += (nSaldo+nJuros)
						nMesTit0 += xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1)
						nMesTit1 += (nSaldo)
						nMesTit2 += (nSaldo+nJuros)
						nTotJur  += nJuros
						nMesTitj += nJuros
						nTotFilJ += nJuros
					Endif	
				Endif
			Else						//a vencer
				If mv_par19 == 1
					If !(SE1->E1_TIPO $ MVABATIM)				
						@li,149 PSAY nSaldo Picture PesqPict("SE1","E1_SALDO",14,MV_PAR15)
					Endif
				EndIf
				If ! ( SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG)
					If !SE1->E1_TIPO $ MVABATIM
						nTit0 += xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1)
						nTit3 += (nSaldo-nTotAbat)
						nTit4 += (nSaldo-nTotAbat)
						nMesTit0 += xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1)
						nMesTit3 += (nSaldo-nTotAbat)
						nMesTit4 += (nSaldo-nTotAbat)
					EndIf
				Else
					nTit0 -= xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1)
					nTit3 -= (nSaldo-nTotAbat)
					nTit4 -= (nSaldo-nTotAbat)
					nMesTit0 -= xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1)
					nMesTit3 -= (nSaldo-nTotAbat)
					nMesTit4 -= (nSaldo-nTotAbat)
				Endif
			Endif
			
			If mv_par19 == 1
				@ li, 164 PSAY SE1->E1_NUMBCO
			EndIf
			If nJuros > 0
				If mv_par19 == 1
					@ Li,181 PSAY nJuros Picture PesqPict("SE1","E1_JUROS",10,MV_PAR15)
				EndIf
				nJuros := 0
			Endif
			
			IF dDataBase > SE1->E1_VENCREA
				nAtraso:=dDataBase-SE1->E1_VENCTO
				IF Dow(SE1->E1_VENCTO) == 1 .Or. Dow(SE1->E1_VENCTO) == 7
					IF Dow(dBaixa) == 2 .and. nAtraso <= 2
						nAtraso := 0
					EndIF
				EndIF
				nAtraso:=IIF(nAtraso<0,0,nAtraso)
				IF nAtraso>0
					If mv_par19 == 1
						@li ,195 PSAY nAtraso Picture "9999"
					EndIf
				EndIF
			EndIF
			If mv_par19 == 1
				@li,200 PSAY SubStr(SE1->E1_HIST,1,20)+ ;
					IIF(E1_TIPO $ MVPROVIS,"*"," ")+ ;
					Iif(nSaldo == xMoeda(E1_VALOR,E1_MOEDA,mv_par15,dDataReaj,ndecs+1)," ","P")
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Carrega data do registro para permitir ³
			//³ posterior an lise de quebra por mes.   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dDataAnt := Iif(nOrdem == 6, SE1->E1_EMISSAO, SE1->E1_VENCREA)
			dbSkip()
			nTotTit ++
			nMesTTit ++
			nTotFiltit++
			nTit5 ++
			If mv_par19 == 1
				li++
			EndIf
		Enddo
		
		IF nTit5 > 0 .and. nOrdem != 2 .and. nOrdem != 10
			SubTot130(nTit0,nTit1,nTit2,nTit3,nTit4,nOrdem,cCarAnt,nTotJur)
			If mv_par19 == 1
				Li++
			EndIf
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica quebra por mˆs	  			   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lQuebra := .F.
		If nOrdem == 4  .and. (Month(SE1->E1_VENCREA) # Month(dDataAnt) .or. SE1->E1_VENCREA > mv_par10)
			lQuebra := .T.
		Elseif nOrdem == 6 .and. (Month(SE1->E1_EMISSAO) # Month(dDataAnt) .or. SE1->E1_EMISSAO > mv_par14)
			lQuebra := .T.
		Endif
		If lQuebra .and. nMesTTit # 0
			ImpMes130(nMesTit0,nMesTit1,nMesTit2,nMesTit3,nMesTit4,nMesTTit,nMesTitJ)
			nMesTit0 := nMesTit1 := nMesTit2 := nMesTit3 := nMesTit4 := nMesTTit := nMesTitj := 0
		Endif
		nTot0+=nTit0
		nTot1+=nTit1
		nTot2+=nTit2
		nTot3+=nTit3
		nTot4+=nTit4
		nTotJ+=nTotJur
		
		nTotFil0+=nTit0
		nTotFil1+=nTit1
		nTotFil2+=nTit2
		nTotFil3+=nTit3
		nTotFil4+=nTit4
		Store 0 To nTit0,nTit1,nTit2,nTit3,nTit4,nTit5,nTotJur,nTotAbat
	Enddo
	
	dbSelectArea("SE1")		// voltar para alias existente, se nao, nao funciona
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprimir TOTAL por filial somente quan-³
	//³ do houver mais do que 1 filial.        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if mv_par21 == 1 .and. SM0->(Reccount()) > 1
		ImpFil130(nTotFil0,nTotFil1,nTotFil2,nTotFil3,nTotFil4,nTotFiltit,nTotFilJ)
	Endif
	Store 0 To nTotFil0,nTotFil1,nTotFil2,nTotFil3,nTotFil4,nTotFilTit,nTotFilJ
	If Empty(xFilial("SE1"))
		Exit
	Endif
	
	#IFDEF TOP
		if TcSrvType() != "AS/400"
			dbSelectArea("SE1")
			dbCloseArea()
			ChKFile("SE1")
			dbSelectArea("SE1")
			dbSetOrder(1)
		endif
	#ENDIF
	
	dbSelectArea("SM0")
	dbSkip()
Enddo

SM0->(dbGoTo(nRegSM0))
cFilAnt := SM0->M0_CODFIL
IF li != 80
	IF li > 58
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
	EndIF
	TotGer130(nTot0,nTot1,nTot2,nTot3,nTot4,nTotTit,nTotJ)
	Roda(cbcont,cbtxt,"G")
EndIF

Set Device To Screen

#IFNDEF TOP
	dbSelectArea("SE1")
	dbClearFil(NIL)
	RetIndex( "SE1" )
	If !Empty(cIndexSE1)
		FErase (cIndexSE1+OrdBagExt())
	Endif
	dbSetOrder(1)
#ELSE
	if TcSrvType() != "AS/400"
		dbSelectArea("SE1")
		dbCloseArea()
		ChKFile("SE1")
		dbSelectArea("SE1")
		dbSetOrder(1)
	else
		dbSelectArea("SE1")
		dbClearFil()
		RetIndex( "SE1" )
		If !Empty(cIndexSE1)
			FErase (cIndexSE1+OrdBagExt())
		Endif
		dbSetOrder(1)
	endif
#ENDIF

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	Ourspool(wnrel)
Endif
MS_FLUSH()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³SubTot130 ³ Autor ³ Paulo Boschetti 		  ³ Data ³ 01.06.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Imprimir SubTotal do Relatorio										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ SubTot130()																  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³																				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	    ³ Generico																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SubTot130(nTit0,nTit1,nTit2,nTit3,nTit4,nOrdem,cCarAnt,nTotJur)
LOCAL aSituaca := {OemToAnsi("Carteira"),OemToAnsi("Simples"),;  			//"Carteira"###"Simples"
	OemToAnsi("Descontada"),OemToAnsi("Caucionada"),OemToAnsi("Vinculada"),;  //"Descontada"###"Caucionada"###"Vinculada"
	OemToAnsi("Advogado"),OemToAnsi("Judicial"),OemToAnsi("Cauc Desc")}  //"Advogado"###"Judicial"###"Cauc Desc"
If mv_par19 == 1
	li++
EndIf
IF li > 58
	nAtuSM0 := SM0->(Recno())
	SM0->(dbGoto(nRegSM0))
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
	SM0->(dbGoTo(nAtuSM0))
EndIF
If nOrdem = 1
	@li,000 PSAY IIF(mv_par29 == 1,SA1->A1_NREDUZ,SA1->A1_NOME)+" "+SA1->A1_DDD+"-"+SA1->A1_TEL+ " "+ "Loja - " + Right(cCarAnt,2)+Iif(mv_par21==1," Filial - "+cFilAnt,"") //"Loja - "###" Filial - "
Elseif nOrdem == 4 .or. nOrdem == 6
	@li,000 PSAY OemToAnsi("S U B - T O T A L ----> ")  // "S U B - T O T A L ----> "
	@li,028 PSAY cCarAnt
	@li,PCOL()+2 PSAY Iif(mv_par21==1,cFilAnt,"  ")
Elseif nOrdem = 3
	@li,000 PSAY OemToAnsi("S U B - T O T A L ----> ")  // "S U B - T O T A L ----> "
	@li,028 PSAY Iif(Empty(SA6->A6_NREDUZ),OemToAnsi("Carteira"),SA6->A6_NREDUZ) + " " + Iif(mv_par21==1,cFilAnt,"")
ElseIf nOrdem == 5
	dbSelectArea("SED")
	MsSeek(cFilial+cCarAnt)
	@li,000 PSAY OemToAnsi("S U B - T O T A L ----> ")  // "S U B - T O T A L ----> "
	@li,028 PSAY cCarAnt + " "+ED_DESCRIC + " " + Iif(mv_par21==1,cFilAnt,"")
	dbSelectArea("SE1")
Elseif nOrdem == 7
	@li,000 PSAY OemToAnsi("S U B - T O T A L ----> ")  // "S U B - T O T A L ----> "
	@li,028 PSAY SubStr(cCarAnt,7,2)+"/"+SubStr(cCarAnt,5,2)+"/"+SubStr(cCarAnt,3,2)+" - "+SubStr(cCarAnt,9,3) + " " +Iif(mv_par21==1,cFilAnt,"")
ElseIf nOrdem = 8
	@li,000 PSAY SA1->A1_COD+" "+SA1->A1_NOME+" "+SA1->A1_DDD+"-"+SA1->A1_TEL + " " + Iif(mv_par21==1,cFilAnt,"")
ElseIf nOrdem = 9
	@li,000 PSAY SubStr(cCarant,1,3)+" "+SA6->A6_NREDUZ + SubStr(cCarant,4,1) + " "+aSituaca[Val(SubStr(cCarant,4,1))+1] + " " + Iif(mv_par21==1,cFilAnt,"")
ElseIf nOrdem = 11
	@li,000 PSAY "REPRESENTANTE : "+SA3->A3_COD+"-"+IIF(mv_par29 == 1,SA3->A3_NREDUZ,SA3->A3_NOME)+" "+"-"+SA3->A3_TEL +Iif(mv_par21==1," Filial - "+cFilAnt,"") //"Loja - "###" Filial - "
Endif
If mv_par19 == 1
	@li,101 PSAY nTit0		  Picture PesqPict("SE1","E1_VALOR",14,MV_PAR15)
Endif
@li,116 PSAY nTit1		  Picture PesqPict("SE1","E1_SALDO",14,MV_PAR15)
@li,133 PSAY nTit2		  Picture PesqPict("SE1","E1_SALDO",14,MV_PAR15)
@li,149 PSAY nTit3		  Picture PesqPict("SE1","E1_SALDO",14,MV_PAR15)
If nTotJur > 0
	@li,179 PSAY nTotJur  Picture PesqPict("SE1","E1_JUROS",12,MV_PAR15)
Endif
@li,204 PSAY nTit2+nTit3 Picture PesqPict("SE1","E1_SALDO",16,MV_PAR15)
li++
If (nOrdem = 1 .Or. nOrdem == 8 .or. nOrdem == 11) .And. mv_par35 == 1 // Salta pag. por cliente
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
Endif	
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ TotGer130³ Autor ³ Paulo Boschetti       ³ Data ³ 01.06.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprimir total do relatorio										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ TotGer130()																  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³																				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function TotGer130(nTot0,nTot1,nTot2,nTot3,nTot4,nTotTit,nTotJ)

li++
@li,000 PSAY OemToAnsi("T O T A L   G E R A L ----> ") //"T O T A L   G E R A L ----> " + " " + Iif(mv_par21==1,cFilAnt,"")
@li,028 PSAY "("+ALLTRIM(STR(nTotTit))+" "+IIF(nTotTit > 1,OemToAnsi("TITULOS"),OemToAnsi("TITULO"))+")"		//"TITULOS"###"TITULO"
If mv_par19 == 1
	@li,101 PSAY nTot0		  Picture PesqPict("SE1","E1_VALOR",14,MV_PAR15)
Endif
@li,116 PSAY nTot1		  Picture PesqPict("SE1","E1_SALDO",14,MV_PAR15)
@li,133 PSAY nTot2		  Picture PesqPict("SE1","E1_SALDO",14,MV_PAR15)
@li,149 PSAY nTot3		  Picture PesqPict("SE1","E1_SALDO",14,MV_PAR15)
@li,179 PSAY nTotJ		  Picture PesqPict("SE1","E1_JUROS",12,MV_PAR15)
@li,204 PSAY nTot2+nTot3 Picture PesqPict("SE1","E1_SALDO",16,MV_PAR15)
li++
li++
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ImpMes130 ³ Autor ³ Vinicius Barreira	  ³ Data ³ 12.12.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³IMPRIMIR TOTAL DO RELATORIO - QUEBRA POR MES					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ImpMes130() 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 																			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function ImpMes130(nMesTot0,nMesTot1,nMesTot2,nMesTot3,nMesTot4,nMesTTit,nMesTotJ)
li++
IF li > 58
	nAtuSM0 := SM0->(Recno())
	SM0->(dbGoto(nRegSM0))
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
	SM0->(dbGoTo(nAtuSM0))
EndIF
@li,000 PSAY OemToAnsi("T O T A L   D O  M E S ---> ")  //"T O T A L   D O  M E S ---> "
@li,028 PSAY "("+ALLTRIM(STR(nMesTTit))+" "+IIF(nMesTTit > 1,OemToAnsi("TITULOS"),OemToAnsi("TITULO"))+")"  //"TITULOS"###"TITULO"
If mv_par19 == 1
	@li,101 PSAY nMesTot0   Picture PesqPict("SE1","E1_VALOR",14,MV_PAR15)
Endif
@li,116 PSAY nMesTot1	Picture PesqPict("SE1","E1_SALDO",14,MV_PAR15)
@li,133 PSAY nMesTot2	Picture PesqPict("SE1","E1_SALDO",14,MV_PAR15)
@li,149 PSAY nMesTot3	Picture PesqPict("SE1","E1_SALDO",14,MV_PAR15)
@li,179 PSAY nMesTotJ	Picture PesqPict("SE1","E1_JUROS",12,MV_PAR15)
@li,204 PSAY nMesTot2+nMesTot3 Picture PesqPict("SE1","E1_SALDO",16,MV_PAR15)
li+=2
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ ImpFil130³ Autor ³ Paulo Boschetti  	  ³ Data ³ 01.06.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprimir total do relatorio										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ImpFil130()																  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³																				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	    ³ Generico																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function ImpFil130(nTotFil0,nTotFil1,nTotFil2,nTotFil3,nTotFil4,nTotFilTit,nTotFilJ)
li++
IF li > 58
	nAtuSM0 := SM0->(Recno())
	SM0->(dbGoto(nRegSM0))
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
	SM0->(dbGoTo(nAtuSM0))
EndIF
@li,000 PSAY OemToAnsi("T O T A L   F I L I A L ----> ")+" "+Iif(mv_par21==1,cFilAnt,"")  //"T O T A L   F I L I A L ----> "
If mv_par19 == 1
	@li,101 PSAY nTotFil0        Picture PesqPict("SE1","E1_VALOR",14,MV_PAR15)
Endif
@li,116 PSAY nTotFil1          Picture PesqPict("SE1","E1_SALDO",14,MV_PAR15)
@li,133 PSAY nTotFil2          Picture PesqPict("SE1","E1_SALDO",14,MV_PAR15)
@li,149 PSAY nTotFil3          Picture PesqPict("SE1","E1_SALDO",14,MV_PAR15)
@li,179 PSAY nTotFilJ		   Picture PesqPict("SE1","E1_JUROS",12,MV_PAR15)
@li,204 PSAY nTotFil2+nTotFil3 Picture PesqPict("SE1","E1_SALDO",16,MV_PAR15)
li+=2
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³fr130Indr ³ Autor ³ Wagner           	  ³ Data ³ 12.12.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta Indregua para impressao do relat¢rio						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fr130IndR()
Local cString

cString := 'E1_FILIAL=="'+xFilial("SE1")+'".And.'
cString += 'E1_CLIENTE>="'+mv_par01+'".and.E1_CLIENTE<="'+mv_par02+'".And.'
cString += 'E1_PREFIXO>="'+mv_par03+'".and.E1_PREFIXO<="'+mv_par04+'".And.'
cString += 'E1_NUM>="'+mv_par05+'".and.E1_NUM<="'+mv_par06+'".And.'
cString += 'DTOS(E1_VENCREA)>="'+DTOS(mv_par09)+'".and.DTOS(E1_VENCREA)<="'+DTOS(mv_par10)+'".And.'
cString += '(E1_MULTNAT == "1" .OR. (E1_NATUREZ>="'+mv_par11+'".and.E1_NATUREZ<="'+mv_par12+'")).And.'
cString += 'DTOS(E1_EMISSAO)>="'+DTOS(mv_par13)+'".and.DTOS(E1_EMISSAO)<="'+DTOS(mv_par14)+'"'
If !Empty(mv_par31) // Deseja imprimir apenas os tipos do parametro 31
	cString += '.And.E1_TIPO$"'+mv_par31+'"'
ElseIf !Empty(Mv_par32) // Deseja excluir os tipos do parametro 32
	cString += '.And.!(E1_TIPO$'+'"'+mv_par32+'")'
EndIf
IF mv_par34 == 1  // Apenas titulos que estarao no fluxo de caixa
	cString += '.And.(E1_FLUXO!="N")'	
Endif
Return cString

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AjustaSX1³ Autor ³ Lucas                 ³ Data ³ 11/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica as perguntas inclu¡ndo-as caso n„o existam        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Remito .prx                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//LGS#20200130 - Adequação para release 12.1.25 e posteirores
/*
Static Function CriaSX1(cPerg)
//Local _sAlias	:= Alias()
//Local cOrdem,nX
Local aRegs		:= {}

PutSX1(cPerg, "01",   "Do cliente    ?    		", "", "", "mv_ch1", "C",  6, 0, 0, "G", " ", "SA1", " ", " ", "mv_par01", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "02",   "Até o cliente ?    		", "", "", "mv_ch2", "C",  6, 0, 0, "G", " ", "SA1", " ", " ", "mv_par02", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "03",   "Do prefixo    ?    		", "", "", "mv_ch2", "C",  3, 0, 0, "G", " ",    "", " ", " ", "mv_par03", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "04",   "Até o prefixo ?    		", "", "", "mv_ch3", "C",  3, 0, 0, "G", " ",    "", " ", " ", "mv_par04", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "05",   "Do Titulo     ?    		", "", "", "mv_ch5", "C",  9, 0, 0, "G", " ", 	 "", " ", " ", "mv_par05", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "06",   "Até o Titulo  ?    		", "", "", "mv_ch5", "C",  9, 0, 0, "G", " ", 	 "", " ", " ", "mv_par06", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "07",   "Do Banco      ?    		", "", "", "mv_ch6", "C",  3, 0, 0, "G", " ", "SA6", " ", " ", "mv_par07", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "08",   "Até o Banco   ? 	     	", "", "", "mv_ch7", "C",  3, 0, 0, "G", " ", "SA6", " ", " ", "mv_par08", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "09",   "Do Vencimento ? 		    ", "", "", "mv_ch8", "D",  8, 0, 0, "G", " ",    "", " ", " ", "mv_par09", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "10",   "Até Vencimento?    		", "", "", "mv_ch9", "D",  8, 0, 0, "G", " ",    "", " ", " ", "mv_par10", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "11",   "Da Natureza   ?    		", "", "", "mv_cha", "C", 10, 0, 0, "G", " ", "SED", " ", " ", "mv_par11", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "12",   "Até Natureza  ?    		", "", "", "mv_chb", "C", 10, 0, 0, "G", " ", "SED", " ", " ", "mv_par12", ""				 , " ", " "     , " "   , ""				, " "     , " "     , ""				, " "     , " "     , ""				, " "     , " "     , ""  		    ,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "13",   "Da Emissão    ?    		", "", "", "mv_chc", "D",  8, 0, 0, "G", " ",    "", " ", " ", "mv_par13", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "14",   "Até Emissão   ?    		", "", "", "mv_chd", "D",  8, 0, 0, "G", " ",    "", " ", " ", "mv_par14", ""				 , " ", " "     , " "   , ""				, " "     , " "     , ""				, " "     , " "     , ""				, " "     , " "     , ""	        ,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "15",   "Qual Moeda    ?   		", "", "", "mv_che", "N",  2, 0, 0, "G", " ", 	 "", " ", " ", "mv_par15", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "16",   "Impr. Provisórios ?  	", "", "", "mv_chf", "N",  1, 0, 2, "C", " ", 	 "", " ", " ", "mv_par16", "Sim"             , " ", " "     , " "   , "Não"             , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "17",   "Conver Venci Pela ?	    ", "", "", "mv_chg", "N",  1, 0, 1, "C", " ",    "", " ", " ", "mv_par17", "Database"        , " ", " "     , " "   , "Data Vencimento" , " "     , " "     , ""                , " "     , " "     , ""                , " "     , " "     , ""            ,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "18",   "Impr Tit. em Desc ?   	", "", "", "mv_chh", "N",  1, 0, 1, "C", " ",    "", " ", " ", "mv_par18", "Sim"             , " ", " "     , " "   , "Não"             , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "19",   "Impr Relatório    ?		", "", "", "mv_chi", "N",  1, 0, 1, "C", " ",   " ", " ", " ", "mv_par19", "Analitico"       , " ", " "     , " "   , "Sintético"       , " "     , " "     , ""				, " "     , " "     , ""				, " "     , " "     , ""       		,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "20",   "Compõe Saldo Retroativo? ", "", "", "mv_chj", "N",  1, 0, 1, "C", " ",   " ", " ", " ", "mv_par20", "Sim"             , " ", " "     , " "   , "Não"             , " "     , " "     , "" 				, " "     , " "     , "" 				, " "     , " "     , ""			,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "21",   "Consid. filiais abaixo ? ", "", "", "mv_chl", "N",  1, 0, 2, "C", " ",   " ", " ", " ", "mv_par21", "Sim"             , " ", " "     , " "   , "Não"             , " "     , " "     , ""			    , " "     , " "     , "" 				, " "     , " "     , ""			,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "22",   "Da Filial          ?     ", "", "", "mv_chm", "C",  2, 0, 0, "G", " ",   " ", " ", " ", "mv_par22", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""			    , " "     , " "     , ""				, " "     , " "     , ""			,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "23",   "Até Filial         ?     ", "", "", "mv_chn", "C",  2, 0, 0, "G", " ",   " ", " ", " ", "mv_par23", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""			    , " "     , " "     , "" 				, " "     , " "     , ""			,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "24",   "Da Loja            ?     ", "", "", "mv_cho", "C",  2, 0, 0, "G", " ",   " ", " ", " ", "mv_par24", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""			    , " "     , " "     , "" 				, " "     , " "     , ""			,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "25",   "Até a Loja         ?     ", "", "", "mv_chp", "C",  2, 0, 0, "G", " ",   " ", " ", " ", "mv_par25", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , "" 				, " "     , " "     , ""			,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "26",   "Consid. Adiantamento    ?", "", "", "mv_chq", "N",  1, 0, 0, "C", " ",   " ", " ", " ", "mv_par26", "Sim"             , " ", " "     , " "   , "Não"             , " "     , " "     , ""			    , " "     , " "     , "" 				, " "     , " "     , ""			,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "27",   "Da data Contábil     ?	", "", "", "mv_chr", "D",  8, 0, 0, "G", " ",    "", " ", " ", "mv_par27", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , ""                , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "28",   "Até data Contábil    ?	", "", "", "mv_chs", "D",  8, 0, 0, "G", " ",    "", " ", " ", "mv_par28", ""				 , " ", " "     , " "   , ""				, " "     , " "     , ""				, " "     , " "     , ""				, " "     , " "     , ""       		,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "29",   "Imprime Nom    ?         ", "", "", "mv_cht", "N",  1, 0, 1, "C", " ",   " ", " ", " ", "mv_par29", "Sim"             , " ", " "     , " "   , "Não"             , " "     , " "     , "" 				, " "     , " "     , "" 				, " "     , " "     , ""			,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "30",   "Outras Moedas  ?         ", "", "", "mv_chu", "N",  1, 0, 1, "C", " ",   " ", " ", " ", "mv_par30", "Sim"             , " ", " "     , " "   , "Não"             , " "     , " "     , "" 				, " "     , " "     , "" 				, " "     , " "     , ""			,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "31",   "Imprimir Tipos ?         ", "", "", "mv_cho", "C",TamSx3("E1_TIPO")[1]*10,0,0, "C", " ", " ", " ", " ", "mv_par31", "", " ", " "     , " "   , ""                , " "     , " "     , "" 				, " "     , " "     , "" 				, " "     , " "     , ""			,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "32",   "Não Imprimir Tipos ?     ", "", "", "mv_chp", "C",TamSx3("E1_TIPO")[1]*10,0,0, "C", " ", " ", " ", " ", "mv_par32", "", " ", " "     , " "   , ""                , " "     , " "     , "" 				, " "     , " "     , "" 				, " "     , " "     , ""			,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "33",   "Lista Abatimentos       ?", "", "", "mv_chq", "N",  1, 0, 1, "C", " ",   " ", " ", " ", "mv_par33", "Sim"             , " ", " "     , " "   , "Não"             , " "     , " "     , "" 				, " "     , " "     , "" 				, " "     , " "     , ""			,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "34",   "Somente Tit.p/Fluxo?     ", "", "", "mv_chr", "N",  1, 0, 1, "C", " ",   " ", " ", " ", "mv_par34", "Sim"             , " ", " "     , " "   , "Não"             , " "     , " "     , "" 				, " "     , " "     , "" 				, " "     , " "     , ""			,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "35",   "Salta pag.p/Cliente?     ", "", "", "mv_chs", "N",  1, 0, 2, "C", " ",   " ", " ", " ", "mv_par35", "Sim"             , " ", " "     , " "   , "Não"             , " "     , " "     , "" 				, " "     , " "     , "" 				, " "     , " "     , ""			,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "36",   "Despreza abatimentos?    ", "", "", "mv_cht", "N",  1, 0, 2, "C", " ",   " ", " ", " ", "mv_par36", "Sim"             , " ", " "     , " "   , "Não"             , " "     , " "     , "" 				, " "     , " "     , "" 				, " "     , " "     , ""			,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "37",   "Database    ?    		", "", "", "mv_chr", "D",  8, 0, 0, "G", " ",    "", " ", " ", "mv_par37", ""                , " ", " "     , "'"+Dtoc(dDataBase)+"'"   , ""                , " "     , " "     , ""                , " "     			, " "     , " "     , " "     		, " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "38",   "Compõe Saldo Por     ?   ", "", "", "mv_chu", "N",  1, 0, 1, "C", " ",   " ", " ", " ", "mv_par38", "Data de Baixa"   , " ", " "     , " "   , "Data de Crédito" , " "     , " "     , "" 				, " "     , " "     , "" 				, " "     , " "     , ""			,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )
PutSX1(cPerg, "39",   "Filtra Lucros/Perdas ?   ", "", "", "mv_chv", "N",  1, 0, 1, "C", " ",   " ", " ", " ", "mv_par39", "Sim"             , " ", " "     , " "   , "Não"             , " "     , " "     , "" 				, " "     , " "     , "" 				, " "     , " "     , ""			,  " ",  " "     , Nil  , Nil     , Nil     , "BRFIN130" )

/*
AAdd(aRegs,{"Imprimir Tipos      ","Imprimir Tipos      ","Print Types            ","mv_cho","C",TamSx3("E1_TIPO")[1]*10,0,0,"G","","mv_par31","","","","","","","","","",""})
AAdd(aRegs,{"Nao Imprimir Tipos  ","No Imprimir Tipos   ","Do not Print Types     ","mv_chp","C",TamSx3("E1_TIPO")[1]*10,0,0,"G","","mv_par32","","","","","","","","","",""})
AAdd(aRegs,{"Lista abatimentos  ?","¨Lista Rebajas     ?","Print Allowwances      ","mv_chq","N",1,0,1,"C","","mv_par33","Sim","Si","Yes","","","Nao","No","No","",""})
AAdd(aRegs,{"Somente Tit.p/Fluxo?","¨Solo Tit.p/Flujo  ?","Just Bills to C.Flow   ","mv_chr","N",1,0,2,"C","","mv_par34","Sim","Si","Yes","","","Nao","No","No","",""})
AAdd(aRegs,{"Salta pag.p/Cliente?","¨Salta pg.p/Cliente?","Eject pg by customer   ","mv_chs","N",1,0,2,"C","","mv_par35","Sim","Si","Yes","","","Nao","No","No","",""})
AAdd(aRegs,{"Despreza abatimentos?","No lista Abatimentos?","Ignore descounts     ","mv_cht","N",1,0,2,"C","","mv_par36","Sim","Si","Yes","","","Nao","No","No","",""})
AAdd(aRegs,{"Data Base           ","Data de Hoy         ","Base Date              ","mv_chu","D",8,0,0,"G","","mv_par37","","","","'"+Dtoc(dDataBase)+"'","","","","","",""})
AAdd(aRegs,{"Compoe Saldo por    ","Compone Saldo por   ","Arrange Remaider by    ","mv_chv","N",1,0,1,"C","","mv_par38","Data de Baixa","Fecha de Cancel.","Posting Date","","","Data de Credito","Fecha de Credito","Credit Date","",""})
AAdd(aRegs,{"Filtra Lucros/Perdas?","Filtra Lucros/Perdas?","Filtra Lucros/Perdas?","mv_chq","N",1,0,1,"C","","mv_par39","Sim","Si","Yes","","","Nao","No","No","",""})
*/


/*
dbSelectArea("SX1")
dbSetOrder(1)
For nX:=1 to Len(aRegs)
	cOrdem := StrZero(nX+30,2)
	If !(MsSeek(cPerg+cOrdem))
		RecLock("SX1",.T.)
		Replace X1_GRUPO		With cPerg
		Replace X1_ORDEM		With cOrdem
		Replace x1_pergunte	With aRegs[nx][01]
		Replace x1_perspa		With aRegs[nx][02]
		Replace x1_pereng		With aRegs[nx][03]
		Replace x1_variavl	With aRegs[nx][04]
		Replace x1_tipo		With aRegs[nx][05]
		Replace x1_tamanho	With aRegs[nx][06]
		Replace x1_decimal	With aRegs[nx][07]
		Replace x1_presel		With aRegs[nx][08]
		Replace x1_gsc			With aRegs[nx][09]
		Replace x1_valid		With aRegs[nx][10]
		Replace x1_var01		With aRegs[nx][11]
		Replace x1_def01		With aRegs[nx][12]
		Replace x1_defspa1	With aRegs[nx][13]
		Replace x1_defeng1	With aRegs[nx][14]
		Replace x1_cnt01		With aRegs[nx][15]
		Replace x1_var02		With aRegs[nx][16]
		Replace x1_def02		With aRegs[nx][17]
		Replace x1_defspa2	With aRegs[nx][18]
		Replace x1_defeng2	With aRegs[nx][19]
		Replace x1_f3			With aRegs[nx][20]
		Replace x1_grpsxg		With aRegs[nx][21]
		MsUnlock()
	ElseIf cOrdem == "37"  //DataBase
		//Acerto o parametro com a database
		RecLock("SX1",.F.)
		Replace x1_cnt01		With aRegs[nx][15]
		MsUnlock()	
	Endif
Next
dbSelectArea(_sAlias)
*/
*/
//Return