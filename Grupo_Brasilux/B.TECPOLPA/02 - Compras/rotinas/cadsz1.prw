#include "protheus.ch"
#include "TOPCONN.CH"
#include "rwmake.ch"

#DEFINE VALMERC  	 1  // Valor total do mercadoria
#DEFINE VALDESC 	 2  // Valor total do desconto
#DEFINE FRETE   	 3  // Valor total do Frete
#DEFINE VALDESP 	 4  // Valor total da despesa
#DEFINE TOTF1		 5  // Total de Despesas Folder 1
#DEFINE TOTPED		 6  // Total do Pedido
#DEFINE SEGURO		 7  // Valor total do seguro
#DEFINE TOTF3		 8  // Total utilizado no Folder 3
#DEFINE IMPOSTOS    9  // Array contendo Os Valores de Impostos Exibidos no ListBox
#DEFINE	 NTRIB		 10 // Valor das despesas nao tributadas - Portugal
#DEFINE TARA        11 // Valor da Tara - Portugal


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CadSZ1  ºAutor  ³Dyego Figueiredo/Chaus ºData³ 01/05/16     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ * Funcao chamada no menu do compras.           		      º±±
±±ºObjetivo  ³ * Incluir os Pedidos de compra de recebimento de terceiros.º±±
±±º          ³ *								   	 				 	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function CadSZ1()
     Local aCores       := {}
     Local _lOpen        := .F. //LGS#20200207 - Adequação para release 12.1.25
     Private cCadastro := "Pedido de compra Terceiros"
     Private aRotina := {}
     Private _cAliasSX3  := GetNextAlias() //LGS#20200207 - Adequação para release 12.1.25
	
     // ABERTURA DO DICIONÁRIO SX3 - LGS#20200207 - Adequação para release 12.1.25
     OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
     _lOpen := Select( _cAliasSX3 ) > 0

     If _lOpen
        AADD( aRotina, {"Pesquisar",	"AxPesqui" ,0,1})
        AADD( aRotina, {"Visualizar",	'U_SZ1Inc',0,2})
        AADD( aRotina, {"Incluir",		'U_SZ1Inc',0,3})
        AADD( aRotina, {"Alterar",		'U_SZ1Inc',0,4})
        AADD( aRotina, {"Excluir",		'U_SZ1Inc',0,5})
        AAdd(aRotina,  {"Legenda",		"u_SZ1Legen", 0, 2})

        dbSelectArea("SZ1")
        dbSetOrder(1)
        dbGoTop()

        aAdd(aCores,    { '!Empty(Z1_RESIDUO)'						, 'BR_CINZA'})	 //-- Eliminado por Residuo
        aAdd(aCores,    { 'Z1_QUJE==0 .And. Z1_QTDACLA==0'   		, 'ENABLE'})	  //-- Pendente
        aAdd(aCores,    { 'Z1_QUJE<>0.And.Z1_QUJE<Z1_QUANT'			, 'BR_AMARELO'}) //-- Pedido Parcialmente Atendido
        aAdd(aCores,    { 'Z1_QUJE>=Z1_QUANT'   					, 'DISABLE'})	  //-- Pedido Atendido

        mBrowse( ,,,,"SZ1", ,,,,,aCores)

        DbSelectArea( _cAliasSX3 )
        DbCloseArea()
     Else
        MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
     Endif
Return


//+--------------------------------------------------------------------+
//| Descr. | Rotina para criar a legenda |
//+--------------------------------------------------------------------+
User Function SZ1Legen()

	Local aLegenda	 := {}
	//Local aLegeUsr   := {}

	aAdd(aLegenda,{"ENABLE" 		,"Pendente"})
	aAdd(aLegenda,{"BR_AMARELO"		,"Pedido Parcialmente Atendido"})
	aAdd(aLegenda,{"DISABLE"		,'Pedido Atendido'})
	aAdd(aLegenda,{"BR_CINZA"		,"Eliminado por Residuo"})

	BrwLegenda(cCadastro,"Legenda", aLegenda )

Return .T.


//+--------------------------------------------------------------------+
//| Descr. | Rotina para incluir dados. |
//+--------------------------------------------------------------------+
User Function SZ1Inc( cAlias, nReg, nOpc )
	Local oDlg
	//Local oGet
	//Local oTPanel1
	//Local oTPAnel2

	//Local dData   := dDataBase

	Local lInclui := .F.
	Local lAltera := .F.
	Local lVisual := .F.
	Local lExclui := .F.
	//Local aCombo	 := CarregaTipoFrete()

	//Local aObj2[2]	 // Array 2 com objetos utilizados no Folder

	Private aObj	      // Array com os objetos utilizados no Folder

	If cPaisLoc == "PTG"
		aObj:= Array(28)
	Else
		aObj:= Array(24)
	EndIf


	DEFAULT lCopia   := .F.
	DEFAULT l120Auto := .F.

	If nOpc == 3 // Inclusao
		lInclui := .T.
	EndIf

	If nOpc == 4 // Alteracao
		lAltera := .T.
	Endif

	If nOpc == 2 // Visualiza
		lVisual := .T.
	Endif

	If nOpc == 5 // lExclui
		lExclui := .T.
	EndIf

	PRIVATE aValores	:= {0,0,0,0,0,0,0,0,{{'','',0,0,0}},0,0}
	PRIVATE bGDRefresh    := {|| If(l120Auto,.T.,(oGetDados:oBrowse:Refresh())) }
	PRIVATE cA120Num   	  := If(lInclui,GetSXENum("SZ1","Z1_NUM"),	SZ1->Z1_NUM)  //-- O Tratamento desta variavel serah feito logo abaixo...
	PRIVATE dA120Emis     := If(lInclui,CriaVar("Z1_EMISSAO"),	SZ1->Z1_EMISSAO)
	PRIVATE cA120Forn     := If(lInclui,CriaVar("Z1_FORNECE"),	SZ1->Z1_FORNECE)
	PRIVATE cA120Loj      := If(lInclui,CriaVar("Z1_LOJA"),		SZ1->Z1_LOJA)
	PRIVATE cCondicao     := If(lInclui,CriaVar("Z1_COND"),		SZ1->Z1_COND)
	PRIVATE cDescCond     := If(lInclui,CriaVar("E4_DESCRI"),	SE4->E4_DESCRI)
	PRIVATE cContato      := If(lInclui,CriaVar("Z1_CONTATO"),	SZ1->Z1_CONTATO)
	PRIVATE cFilialEnt    := If(lInclui,CriaVar("Z1_FILENT"),	SZ1->Z1_FILENT)
	PRIVATE cA120ProvEnt  := If(lInclui,If(SZ1->(FieldPos("Z1_PROVENT"))>0,CriaVar("Z1_PROVENT"),""),Iif(SZ1->(FieldPos("Z1_PROVENT"))>0,SZ1->Z1_PROVENT,"") )
	PRIVATE cMsg          := If(lInclui,CriaVar("Z1_MSG"),		SZ1->Z1_MSG)
	PRIVATE cReajuste     := If(lInclui,CriaVar("Z1_REAJUST"),	SZ1->Z1_REAJUST)
	PRIVATE cTpFrete      := If(lInclui,CriaVar("Z1_TPFRETE"),	SZ1->Z1_TPFRETE) //If(lInclui,RetTipoFrete(CriaVar("Z1_TPFRETE",.T.)),RetTipoFrete(SZ1->Z1_TPFRETE))
	PRIVATE nDesc1        := If(lInclui,CriaVar("Z1_DESC1"),	SZ1->Z1_DESC1)
	PRIVATE nDesc2        := If(lInclui,CriaVar("Z1_DESC2"),	SZ1->Z1_DESC2)
	PRIVATE nDesc3	      := If(lInclui,CriaVar("Z1_DESC3"),	SZ1->Z1_DESC3)
	PRIVATE lNaturez      := .T. //SZ1->(FieldPos("Z1_NATUREZ")) > 0
	PRIVATE cCodNatu      := "" //If(lInclui,CriaVar("Z1_NATUREZ"),	SZ1->Z1_NATUREZ)
	PRIVATE cTpOP	   	  := If(lInclui,CriaVar("C1_TPOP"),		SZ1->Z1_TPOP)

	PRIVATE nMoedaPed     := If(lInclui,1,Max(SZ1->Z1_MOEDA,1))
	PRIVATE cDescMoed     := SuperGetMv("MV_MOEDA"+AllTrim(Str(nMoedaPed,2)))
	PRIVATE nTxMoeda 	  := If(lInclui,0,SZ1->Z1_TXMOEDA)

	Private aHeader := {}
	Private aCOLS := {}
	Private aREG := {}
	PRIVATE oFolder


	PRIVATE aTitles     := {"Totais"} //,; //"Totais"

	//Declarando os objetos de cores para usar na coluna de status do grid
	Private oVerde  	:= LoadBitmap( GetResources(), "BR_VERDE")
	Private oAzul  		:= LoadBitmap( GetResources(), "BR_AZUL")
	Private oVermelho	:= LoadBitmap( GetResources(), "BR_VERMELHO")
	Private oAmarelo	:= LoadBitmap( GetResources(), "BR_AMARELO")





	//aSizeAut   := {0,0,495,272,990,580,17}
	aSizeAut   := MsAdvSize () //MsAdvSize(,.F.,400)
	//aSizeAut   :=  MsAdvSize()

	If lInclui
		DBSELECTAREA("SZ1")
		dbSetOrder(1)
		While !Eof() .AND. ( DbSeek(xFilial("SZ1") + cA120Num)  )
			cA120Num := Soma1(cA120Num, LEN(SZ1->Z1_NUM) )
		End
	Endif


	aObjects := {}
	AAdd( aObjects, { 0,    75, .T., .F. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 0,    85, .T., .F. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )
	aPosGet := MsObjGetPos(aSizeAut[3]-aSizeAut[1],305,;
		{{10,40,105,140,200,234,275,200,225,260,285,265},;
		{10,40,105,140,200,234,63},;
		{5,70,160,205,295},;
		{6,34,200,215},;
		{6,34,80,113,160,185},;
		{6,34,245,268,260},;
		{10,50,150,190},;
		{273,130,190},;
		{8,45,80,103,139,173,200,235,270},;
		{133,190,144,190,289,293},;
		{142,293,140},;
		{9,47,188,148,9,146} } )

/*
AAdd( aObjects, { 343, 200, .T., .T. } ) //Browse
AAdd( aObjects, { 280, 007, .T., .F. } ) //Linha horizontal
AAdd( aObjects, { 040, 010, .F., .F. } ) //Botao
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )
*/




	dbSelectArea( cAlias )
	dbSetOrder(1)
	Mod2aHeade( cAlias )
	Mod2aCOLS( cAlias, nReg, nOpc )



	//DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd  //"Rateios Externos"
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From 0,0 To 132,160  OF oMainWnd  //"Rateios Externos"


	DEFINE FONT oFnt NAME "Arial" Size 10,15


	@ aPosObj[1][1],aPosObj[1][2] TO aPosObj[1][3]-16,aPosObj[1][4] LABEL '' OF oDlg PIXEL

	@ aPosObj[1][1]+5,aPosGet[1,1] SAY   "Numero" OF oDlg PIXEL SIZE 031,006               // "Numero"
	@ aPosObj[1][1]+4,aPosGet[1,2] MSGET cA120Num ;
		PICTURE PesqPict('SZ1','Z1_NUM') F3 CpoRetF3('Z1_NUM');
		WHEN    lInclui .And. VisualSX3('Z1_NUM') ;
		VALID   CheckSX3('Z1_NUM',cA120Num)  /*.And. !ChkChaveSZ1(cA120Num,.T.) */ OF oDlg PIXEL SIZE 031,006

	@ aPosObj[1][1]+5,aPosGet[1,3] SAY   "Data de Emissao" OF oDlg PIXEL SIZE 050,006               // "Data de Emissao"
	@ aPosObj[1][1]+4,aPosGet[1,4] MSGET dA120Emis ;
		PICTURE PesqPict('SZ1','Z1_EMISSAO') F3 CpoRetF3('Z1_EMISSAO');
		WHEN    lInclui .And. VisualSX3('Z1_EMISSAO') ;
		VALID   CheckSX3('Z1_EMISSAO',dA120Emis)  OF oDlg PIXEL SIZE 048,006 HASBUTTON

	@ aPosObj[1][1]+5,aPosGet[1,5]-12 SAY   "Fornecedor"    OF oDlg PIXEL SIZE 036,006            // "Fornecedor"
	@ aPosObj[1][1]+4,aPosGet[1,6]-25 MSGET oca120Forn VAR cA120Forn;
		PICTURE PesqPict('SZ1','Z1_FORNECE') F3 CpoRetF3('Z1_FORNECE');
		WHEN    lInclui .And. VisualSX3('Z1_FORNECE') ;
		VALID   /*A120Forn(cA120Forn,@cA120Loj,@aInfForn,IIF(lWhenGet,.F.,.T.),lCopia) .And.*/ CheckSX3('Z1_FORNECE',cA120Forn)  OF oDlg PIXEL SIZE 080,006 HASBUTTON

	@ aPosObj[1][1]+5,aPosGet[1,12]+10 SAY OemToAnsi( "Loja") OF oDlg PIXEL SIZE 019,006	   // "Loja"
	@ aPosObj[1][1]+4,aPosGet[1,7]+15 MSGET oca120Loj VAR cA120Loj;
		PICTURE PesqPict('SZ1','Z1_LOJA')  F3 CpoRetF3('Z1_LOJA');
		WHEN    lInclui.And. VisualSX3('Z1_LOJA');
		VALID    CheckSX3('Z1_LOJA',cA120Loj) OF oDlg PIXEL SIZE 019,006

	@ aPosObj[1][1]+17,aPosGet[2,1] SAY   "Cond. Pagto" OF oDlg PIXEL SIZE 030,006               // "Cond. Pagto"
	@ aPosObj[1][1]+16,aPosGet[2,2] MSGET oCond   VAR cCondicao  ;
		PICTURE PesqPict('SZ1','Z1_COND') F3 CpoRetF3('Z1_COND');
		VALID   CheckSX3('Z1_COND',cCondicao) .And. A120DescCn(cCondicao,@oDescCond,@cDescCond,oGetDados)/* .And. A120ValCond(cCondicao)*/;
		WHEN    (lInclui .OR. lAltera) /*!lMt120Ped*/ OF oDlg PIXEL SIZE 025,006 HASBUTTON

	@ aPosObj[1][1]+17,aPosGet[2,3] SAY   "Contato" OF oDlg PIXEL SIZE 038,006               // "Contato"
	@ aPosObj[1][1]+16,aPosGet[2,4] MSGET cContato  ;
		PICTURE PesqPict('SZ1','Z1_CONTATO') F3 CpoRetF3('Z1_CONTATO');
		WHEN    (lInclui .OR. lAltera) .and.  VisualSX3('Z1_CONTATO')  ;
		VALID   (lInclui .OR. lAltera) .AND. CheckSX3('Z1_CONTATO',cContato) OF oDlg PIXEL SIZE 074,006

	@ aPosObj[1][1]+16,aPosGet[2,7] MSGET oDescCond VAR cDescCond PICTURE PesqPict('SE4','E4_DESCRI') WHEN .F. OF oDlg PIXEL SIZE 055,006

	@ aPosObj[1][1]+17,aPosGet[2,5]-12 SAY    "Filial p/ Entrega" OF oDlg PIXEL SIZE 050,006               // "Filial p/ Entrega"
	@ aPosObj[1][1]+16,aPosGet[2,6]-25 MSGET cFilialEnt  ;
		PICTURE PesqPict('SZ1','Z1_FILENT') F3 CpoRetF3('Z1_FILENT');
		WHEN    (lInclui .OR. lAltera) ;
		VALID   CheckSX3('Z1_FILENT',cFilialEnt) .And.	Eval(bGDRefresh) OF oDlg PIXEL SIZE 050,006 HASBUTTON

	@ aPosObj[1][1]+29,aPosGet[2,1] SAY   "Moeda"   OF oDlg PIXEL SIZE 030,006             // "Moeda"
	@ aPosObj[1][1]+28,aPosGet[2,2] MSGET oGetMoeda VAR nMoedaPed ;
		PICTURE PesqPict("SZ1","Z1_MOEDA") ;
		VALID   /*M->NMOEDAPED <= MoedFin().And. M->NMOEDAPED <> 0 .And.*/ A120DescMo(nMoedaPed,@oDescMoed,@cDescMoed,@nTxMoeda,Nil); // A120DescMo(nMoedaPed,@oDescMoed,@cDescMoed,@nTxMoeda,aObj)
	WHEN   (lInclui .OR. lAltera)  PIXEL SIZE 25,06 OF oDlg

	@ aPosObj[1][1]+28,aPosGet[2,7] MSGET oDescMoed VAR cDescMoed  WHEN .F. OF oDlg PIXEL SIZE 055,006

	@ aPosObj[1][1]+29,aPosGet[2,3] SAY   "Taxa" OF oDlg PIXEL SIZE 030,006               // "Taxa da Moeda"
	@ aPosObj[1][1]+28,aposget[2,4] MSGET nTxMoeda OF oDlg ;
		PICTURE PesqPict("SZ1","Z1_TXMOEDA",11) F3 CpoRetF3('Z1_TXMOEDA');
		WHEN    (lInclui .OR. lAltera) .AND.  VisualSX3('Z1_TXMOEDA')  ;
		VALID   CheckSX3('Z1_TXMOEDA',nMoedaped) PIXEL SIZE 074,006 HASBUTTON


	//Criacao da Area da MsGetDados do PC
	If nOpc == 4 .OR. nOpc == 3
		oGetDados := MSGetDados():New(aPosObj[2,1]-20,aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"U_SZ1LOk()",	 "U_SZ1TOk" ,"+Z1_ITEM",.T.)
	Else
		oGetDados := MSGetDados():New(aPosObj[2,1]-20,aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc)
	Endif

	//teste
	//oCabec:oBox:Align := CONTROL_ALIGN_TOP
	//oGetDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT


	//Criacao dos Folders da Area do Rodape do PC
	oFolder := TFolder():New(aPosObj[3,1],aPosObj[3,2],aTitles,{"HEADER"},oDlg,,,, .T., .F.,aPosObj[3,4]-aPosObj[3,2],aPosObj[3,3]-aPosObj[3,1],)


	///MsGets do Folder dos totais
	oFolder:aDialogs[1]:oFont := oDlg:oFont

	If cPaisLoc <> "PTG"
		@ 006,aPosGet[3,1] SAY   "Valor da Mercadoria"  OF  oFolder:aDialogs[1] PIXEL SIZE 055,009 // "Valor da Mercadoria"
		@ 005,aPosGet[3,2] MSGET aObj[01] VAR aValores[VALMERC]   PICTURE    PesqPict('SZ1','Z1_TOTAL',,nMoedaPed)   OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
		@ 006,aPosGet[3,3] SAY   "Descontos"  OF  oFolder:aDialogs[1] PIXEL SIZE 049,009 // "Descontos"
		@ 005,aPosGet[3,4] MSGET aObj[02] VAR aValores[VALDESC]   PICTURE    PesqPict('SZ1','Z1_VLDESC',,nMoedaPed)  OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
		@ 020,aPosGet[3,1] SAY   "Frete"  OF  oFolder:aDialogs[1] PIXEL SIZE 050,009  // "Frete"
		@ 019,aPosGet[3,2] MSGET aObj[03] VAR aValores[FRETE]     PICTURE    PesqPict('SZ1','Z1_FRETE',,nMoedaPed)   OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
		@ 020,aPosGet[3,3] SAY   "Despesas"  OF  oFolder:aDialogs[1] PIXEL SIZE 050,009  // "Despesas"
		@ 019,aPosGet[3,4] MSGET aObj[22] VAR aValores[VALDESP]   PICTURE    PesqPict('SZ1','Z1_DESPESA',,nMoedaPed) OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
		@ 034,aPosGet[3,3] SAY   "Seguro"  OF  oFolder:aDialogs[1] PIXEL SIZE 050,009  // "Seguro"
		@ 033,aPosGet[3,4] MSGET aObj[23] VAR aValores[SEGURO]    PICTURE    PesqPict('SZ1','Z1_DESPESA',,nMoedaPed) OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
		@ 051,aPosGet[3,3] SAY   "Total do Pedido"  OF  oFolder:aDialogs[1] PIXEL SIZE 058,009 // "Total do Pedido"
		@ 049,aPosGet[3,4] MSGET aObj[04] VAR aValores[TOTPED]    PICTURE    PesqPict('SZ1','Z1_TOTAL',,nMoedaPed)   OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
		@ 043,003 TO 46 ,aPosGet[3,5] LABEL '' OF oFolder:aDialogs[1] PIXEL
	Else
		@ 005,aPosGet[3,1] SAY   "Valor da Mercadoria"  OF  oFolder:aDialogs[1] PIXEL SIZE 055,009 // "Valor da Mercadoria"
		@ 004,aPosGet[3,2] MSGET aObj[01] VAR aValores[VALMERC]   PICTURE    PesqPict('SZ1','Z1_TOTAL',17,nMoedaPed)   OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
		@ 005,aPosGet[3,3] SAY   "Descontos"  OF  oFolder:aDialogs[1] PIXEL SIZE 049,009 // "Descontos"
		@ 004,aPosGet[3,4] MSGET aObj[02] VAR aValores[VALDESC]   PICTURE    PesqPict('SZ1','Z1_VLDESC',17,nMoedaPed)  OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
		@ 005,aPosGet[3,5] SAY   "Frete"  OF  oFolder:aDialogs[1] PIXEL SIZE 050,009  // "Frete"
		@ 004,aPosGet[3,6] MSGET aObj[03] VAR aValores[FRETE]     PICTURE    PesqPict('SZ1','Z1_FRETE',17,nMoedaPed)   OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
		@ 019,aPosGet[3,1] SAY   "Seguro"  OF  oFolder:aDialogs[1] PIXEL SIZE 050,009  // "Seguro"
		@ 018,aPosGet[3,2] MSGET aObj[23] VAR aValores[SEGURO]    PICTURE    PesqPict('SZ1','Z1_DESPESA',17,nMoedaPed) OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
		@ 019,aPosGet[3,3] SAY   "Despesas"  OF  oFolder:aDialogs[1] PIXEL SIZE 050,009  // "Despesas"
		@ 018,aPosGet[3,4] MSGET aObj[22] VAR aValores[VALDESP]   PICTURE    PesqPict('SZ1','Z1_SEGURO',17,nMoedaPed) OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
		@ 019,aPosGet[3,5] SAY   "Despesas n„o trib."  OF  oFolder:aDialogs[1] PIXEL SIZE 050,009  // "Despesas n„o trib."
		@ 018,aPosGet[3,6] MSGET aObj[25] VAR aValores[NTRIB]     PICTURE    PesqPict('SZ1','Z1_DESNTRB',17,nMoedaPed) OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
		@ 033,aPosGet[3,1] SAY   "Tara"  OF  oFolder:aDialogs[1] PIXEL SIZE 050,009  // "Tara"
		@ 032,aPosGet[3,2] MSGET aObj[26] VAR aValores[TARA]      PICTURE    PesqPict('SZ1','Z1_TARA',17,nMoedaPed) OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
		@ 051,aPosGet[3,5] SAY   "Total do Pedido"  OF  oFolder:aDialogs[1] PIXEL SIZE 058,009 // "Total do Pedido"
		@ 049,aPosGet[3,6] MSGET aObj[04] VAR aValores[TOTPED]    PICTURE    PesqPict('SZ1','Z1_TOTAL',17,nMoedaPed)   OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
		@ 046,aPosGet[3,1] TO 047,aPosGet[3,7] LABEL '' OF oFolder:aDialogs[1] PIXEL
	Endif

	//teste
	xA120Refre(@aValores)
	yA120FRefr(aObj)




	ACTIVATE MSDIALOG oDlg CENTER ON INIT 	EnchoiceBar(oDlg,{|| IIF((lInclui .OR. lAltera) .AND. u_SZ1TOk(nOPc)  , IIf(lAltera, Mod2GrvA(oDlg), Mod2GrvI(lInclui, oDlg)), IIF( nOpc==5, Mod2GrvE(oDlg), /*oDlg:End()*/ )  ) },{|| oDlg:End() })



Return



//+--------------------------------------------------------------------+
//| Descr. | Inclui a descricao da moeda |
//+--------------------------------------------------------------------+
Static Function A120DescMo(nMoedaPed,oDescMoed,cDescMoed,nTxMoeda,aObj)

	Local lMoedLocTx  := GetNewPar("MV_MOEDLOC",.F.) //Param criado para atualizar a TX da moeda no PC em outros paises o DEFAULT nao atualiza a Taxa.
	//local cDescMoedBKP:= cDescMoed
	//Local nPosCodTab  := aScan(aHeader,{|x| AllTrim(x[2]) == "Z1_CODTAB"})
	//Local nX		  := 0
	//Local nBkp		  := 0

	cDescMoed := SuperGetMv("MV_MOEDA"+AllTrim(Str(nMoedaPed,2)))

	If oDescMoed != Nil
		oDescMoed:Refresh()
	EndIf

	IF cPaisLoc=="BRA" .Or. lMoedLocTx
		nTxMoeda:=RecMoeda(dDataBase,nMoedaPed)
	EndIf

//ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
// Redefine as Pictures dos objetos dos Folders do PC quando a Moeda e
// alterada, necessaria para paises onde nao existe o uso de casas deci
// mais na moeda corrente. Exemplo: PESOS no Chile com PC em Dolar.
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	If aObj != Nil .and. cPaisLoc != "BRA"
		aObj[01]:PICTURE:=PesqPict('SZ1','Z1_TOTAL',17,nMoedaPed)
		aObj[02]:PICTURE:=PesqPict('SZ1','Z1_VLDESC',17,nMoedaPed)
		aObj[03]:PICTURE:=PesqPict('SZ1','Z1_FRETE',17,nMoedaPed)
		aObj[04]:PICTURE:=PesqPict('SZ1','Z1_TOTAL',17,nMoedaPed)
		aObj[12]:PICTURE:=PesqPict('SZ1','Z1_FRETE',14,nMoedaPed)
		aObj[13]:PICTURE:=PesqPict('SZ1','Z1_FRETE',14,nMoedaPed)
		aObj[14]:PICTURE:=PesqPict('SZ1','Z1_FRETE',14,nMoedaPed)
		aObj[15]:PICTURE:=PesqPict('SZ1','Z1_DESC1',,nMoedaPed)
		aObj[16]:PICTURE:=PesqPict('SZ1','Z1_DESC2',,nMoedaPed)
		aObj[17]:PICTURE:=PesqPict('SZ1','Z1_DESC3',,nMoedaPed)
		aObj[18]:PICTURE:=PesqPict('SZ1','Z1_VLDESC',14,nMoedaPed)
		aObj[19]:PICTURE:=PesqPict('SZ1','Z1_TOTAL',14,nMoedaPed)
		aObj[22]:PICTURE:=PesqPict('SZ1','Z1_FRETE',14,nMoedaPed)
		aObj[23]:PICTURE:=PesqPict('SZ1','Z1_FRETE',14,nMoedaPed)
		aObj[24]:PICTURE:=PesqPict('SZ1','Z1_FRETE',14,nMoedaPed)
		If cPaisLoc == "PTG"
			aObj[25]:PICTURE:=PesqPict('SZ1','Z1_DESNTRB',14,nMoedaPed)
			aObj[26]:PICTURE:=PesqPict('SZ1','Z1_TARA',14,nMoedaPed)
			aObj[27]:PICTURE:=PesqPict('SZ1','Z1_DESNTRB',14,nMoedaPed)
			aObj[28]:PICTURE:=PesqPict('SZ1','Z1_TARA',14,nMoedaPed)
		Endif
	EndIf


Return .T.


//+--------------------------------------------------------------------+
//| Descr. |  Descricao da condicao de pagamento |
//+--------------------------------------------------------------------+
Static Function A120DescCn(cCondicao,oDescCond,cDescCond,oGetDados)

	dbSelectArea("SE4")
	dbSetOrder(1)
	If MsSeek(xFilial("SE4")+cCondicao)
		cDescCond := SE4->E4_DESCRI
		If oDescCond != Nil
			oDescCond:Refresh()
		EndIf
	EndIf

	If oGetDados <> Nil
		oGetDados:oBrowse:Refresh()
	EndIf

Return .T.


//+--------------------------------------------------------------------+
//| Descr. |  Rotina para montar o vetor aHeader |
//+--------------------------------------------------------------------+
Static Function Mod2aHeade( cAlias )
       Local aArea := GetArea()

       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 07/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek( cAlias )
	While !EOF() .And. X3_ARQUIVO == cAlias
		If X3Uso(X3_USADO) .And. cNivel >= X3_NIVEL
			AADD( aHeader, { Trim( X3Titulo() ),;
				X3_CAMPO,;
				X3_PICTURE,;
				X3_TAMANHO,;
				X3_DECIMAL,;
				X3_VALID,;
				X3_USADO,;
				X3_TIPO,;
				X3_ARQUIVO,;
				X3_CONTEXT})
		Endif
		dbSkip()
	End*/
       dbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( dbSetOrder(1) )
       ( _cAliasSX3 )->( dbSeek( cAlias ) )
       While !EOF() .And. ( _cAliasSX3 )->( X3_ARQUIVO ) == cAlias
             If X3Uso( ( _cAliasSX3 )->( X3_USADO ) ) .And. cNivel >= ( _cAliasSX3 )->( X3_NIVEL )
                AADD( aHeader, { ( _cAliasSX3 )->( X3_Titulo ), ( _cAliasSX3 )->( X3_CAMPO ), ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), ( _cAliasSX3 )->( X3_VALID ), ( _cAliasSX3 )->( X3_USADO ), ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_ARQUIVO ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
             Endif
             dbSkip()
       End
       RestArea(aArea)
Return

//+--------------------------------------------------------------------+
//| Descr. |  Rotina para montar o vetor aCOLS. |
//+--------------------------------------------------------------------+
Static Function Mod2aCOLS( cAlias, nReg, nOpc )
	Local aArea := GetArea()
	Local cChave := SZ1->Z1_NUM
	Local nI := 0
	If nOpc <> 3
		dbSelectArea( cAlias )
		dbSetOrder(1)
		dbSeek( xFilial( cAlias ) + cChave )
		While !EOF() .And. ;
				SZ1->( Z1_FILIAL + Z1_NUM ) == xFilial( cAlias ) + cChave
			AADD( aREG, SZ1->( RecNo() ) )
			AADD( aCOLS, Array( Len( aHeader ) + 1 ) )
			For nI := 1 To Len( aHeader )
				If aHeader[nI,10] == "V"
					aCOLS[Len(aCOLS),nI] := CriaVar(aHeader[nI,2],.T.)
				Else
					aCOLS[Len(aCOLS),nI] :=	FieldGet(FieldPos(aHeader[nI,2]))
				Endif

			Next nI
			aCOLS[Len(aCOLS),Len(aHeader)+1] := .F.
			dbSkip()
		End
	Else
		AADD( aCOLS, Array( Len( aHeader ) + 1 ) )
		For nI := 1 To Len( aHeader )
			aCOLS[1, nI] := CriaVar( aHeader[nI, 2], .T. )
		Next nI
		aCOLS[1, GdFieldPos("Z1_ITEM")] := "0001"
		aCOLS[1, Len( aHeader )+1 ] := .F.

		//aCOLS[1, GdFieldPos("IMAGEM")] := oVerde

	Endif
	Restarea( aArea )
Return


//+--------------------------------------------------------------------+
//| Descr. |  Rotina para gravar os dados na inclusao |
//+--------------------------------------------------------------------+
Static Function Mod2GrvI(lInclui, oDlg)
	Local aArea := GetArea()
	Local nI := 0
	Local nX := 0

	Private lMsErroAuto := .F.


	dbSelectArea("SZ1")
	dbSetOrder(1)
	For nI := 1 To Len( aCOLS )
		If ! aCOLS[nI,Len(aHeader)+1]

			If lInclui
				RecLock("SZ1",.T.)
				SZ1->Z1_FILIAL 	:= xFilial("SZ1")
				SZ1->Z1_NUM 	:= cA120Num
				SZ1->Z1_EMISSAO := dA120Emis
				SZ1->Z1_FORNECE	:= cA120Forn
				SZ1->Z1_LOJA	:= cA120Loj
			Else
				RecLock("SZ1",.F.)
			Endif


			SZ1->Z1_COND	:= cCondicao
			SZ1->Z1_CONTATO	:= cContato
			SZ1->Z1_FILENT	:= cFilialEnt
			SZ1->Z1_MSG		:= cMsg
			SZ1->Z1_REAJUST	:= cReajuste
			SZ1->Z1_TPFRETE	:= cTpFrete
			SZ1->Z1_DESC1	:= nDesc1
			SZ1->Z1_DESC2	:= nDesc2
			SZ1->Z1_DESC3	:= nDesc3
	      	//SZ1->Z1_NATUREZ	:= cCodNatu
			SZ1->Z1_TPOP	:= cTpOP
			SZ1->Z1_MOEDA := nMoedaPed
			SZ1->Z1_TXMOEDA := nTxMoeda



			For nX := 1 To Len( aHeader )
				FieldPut( FieldPos( aHeader[nX, 2] ), aCOLS[nI, nX] )
			Next nX
			MsUnLock()
		Endif
	Next nI
	RestArea(aArea)



	If lMsErroAuto
		RollBackSX8()
		MostraErro()
		lRet := .F.
		Alert("Erro na gravação!")
	Else
		ConfirmSX8()
		//Alert('Gravação realizada!')
		MSGBOX("Gravação realizada!")
	EndIf



	oDlg:End()
Return


//+--------------------------------------------------------------------+
//| Descr. |  Rotina para gravar os dados na alteracao |
//+--------------------------------------------------------------------+
Static Function Mod2GrvA(oDlg)
	Local aArea := GetArea()
	Local nI := 0
	Local nX := 0
	dbSelectArea("SZ1")
	For nI := 1 To Len( aCOLS )//Len( aREG )
		If nI <= Len( aREG )
			dbGoTo( aREG[nI] )
			RecLock("SZ1",.F.)
			If aCOLS[nI, Len(aHeader)+1]
				dbDelete()
			Endif
		Else
			RecLock("SZ1",.T.)
		Endif
		If !aCOLS[nI, Len(aHeader)+1]

			SZ1->Z1_FILIAL 	:= xFilial("SZ1")
			SZ1->Z1_NUM 	:= cA120Num
			SZ1->Z1_EMISSAO := dA120Emis
			SZ1->Z1_FORNECE	:= cA120Forn
			SZ1->Z1_LOJA	:= cA120Loj


			SZ1->Z1_COND	:= cCondicao
			SZ1->Z1_CONTATO	:= cContato
			SZ1->Z1_FILENT	:= cFilialEnt
			SZ1->Z1_MSG		:= cMsg
			SZ1->Z1_REAJUST	:= cReajuste
			SZ1->Z1_TPFRETE	:= cTpFrete
			SZ1->Z1_DESC1	:= nDesc1
			SZ1->Z1_DESC2	:= nDesc2
			SZ1->Z1_DESC3	:= nDesc3
	      	//SZ1->Z1_NATUREZ	:= cCodNatu
			SZ1->Z1_TPOP	:= cTpOP
			SZ1->Z1_MOEDA := nMoedaPed
			SZ1->Z1_TXMOEDA := nTxMoeda

			For nX := 1 To Len( aHeader )
				FieldPut( FieldPos( aHeader[nX, 2] ), aCOLS[nI, nX] )
			Next nX
		Endif
		MsUnLock()
	Next nI


	RestArea( aArea )

	MSGBOX("Pedido alterado com sucesso!")
	oDlg:End()
Return


//+--------------------------------------------------------------------+
//| Descr. |  Rotina para excluir os registros. |
//+--------------------------------------------------------------------+
Static Function Mod2GrvE(oDlg)
	Local nI := 0
	dbSelectArea("SZ1")
	For nI := 1 To Len( aCOLS )
		dbGoTo(aREG[nI])
		RecLock("SZ1",.F.)
		dbDelete()
		MsUnLock()
	Next nI

	MSGBOX("Pedido excluido com sucesso!")

	oDlg:End()
Return


//+--------------------------------------------------------------------+
//| Descr. | Rotina para validar a linha de dados.|
//+--------------------------------------------------------------------+
User Function SZ1LOk( )
	Local lRet := .T.
	//Local cMensagem := "Nao serao permitido linhas sem o produto."

	////Poliester Moreira - Chaus - Se não colocar a variável o pré-compilador não deixa passar
	Local nI	:= 0

	If !aCOLS[n, Len(aHeader)+1]
		For nI := 1 To Len( aHeader )

			If !aCOLS[n, Len(aHeader)+1]
				If Empty(aCOLS[n,GdFieldPos(aHeader[nI][2])]) .AND. X3Obrigat(aHeader[nI][2])
					MsgAlert("Preencha o campo: " + AllTrim(aHeader[nI][1]),cCadastro)
					lRet := .F.
					Exit
				Endif
			Endif

		Next nI
	Endif

	If lRet
		xA120Refre(@aValores)
		yA120FRefr(aObj)
	Endif

Return( lRet )



//+--------------------------------------------------------------------+
//| Descr. | Rotina para validar toda as linhas de dados. |
//+--------------------------------------------------------------------+
User Function SZ1TOk(nOpc)
	Local lRet := .T.
	Local nI := 0
	Local nJ := 0
	//Local cMensagem := "Não será permitido linhas sem produto."

	If nOpc == 2 .Or. nOpc == 5
		return .T.
	Endif

	If Empty(cA120Forn) .or.  Empty(cA120Loj)   .or.  Empty(cCondicao)
		Alert("Preencha o cabeçalho do pedido!")
		return .F.
	Endif

	For nI := 1 To Len( aCOLS )
		For nJ := 1 To Len( aHeader )
			If aCOLS[nI, Len(aHeader)+1]
				Loop
			Endif
			If !aCOLS[nI, Len(aHeader)+1]
				If Empty(aCOLS[nI,GdFieldPos(aHeader[nJ][2])]) .AND. X3Obrigat(aHeader[nJ][2])
					MsgAlert("Preencha o campo: " + AllTrim(aHeader[nJ][1]),cCadastro)
					lRet := .F.
					Exit
				Endif
			Endif
		Next nJ
	Next nI

	If lRet
		xA120Refre(@aValores)
		yA120FRefr(aObj)
	Endif



Return( lRet )



//+--------------------------------------------------------------------+
//| Descr. | Executa o Refresh do Folder.  |
//+--------------------------------------------------------------------+
Static Function xA120Refre(aValores)

	Local aArea	:= GetArea()
	Local nI := 0

	nMerc 	:= 0
	nDesc 	:= 0
	nFrete 	:= 0
	nSeguro := 0
	nDesp 	:= 0
	nIPI 	:= 0
	nEmb	:= 0
	nIcmRet := 0

	For nI := 1 To Len( aCOLS )
		If aCOLS[nI, Len(aHeader)+1]
			Loop
		Endif
		If !aCOLS[nI, Len(aHeader)+1]

			nMerc 	+= aCOLS[nI,GdFieldPos("Z1_TOTAL")]
			nDesc 	+= aCOLS[nI,GdFieldPos("Z1_VLDESC")]
			nFrete 	+= 0 //aCOLS[nI,GdFieldPos("Z1_VALFRE")] //nao
			nSeguro += 0// aCOLS[nI,GdFieldPos("Z1_SEGURO")] //NAO
			nDesp 	+= 0 //aCOLS[nI,GdFieldPos("Z1_DESPESA")] //NAO
			nIPI	+= aCOLS[nI,GdFieldPos("Z1_VALIPI")]
			nEmb	+= 0 // aCOLS[nI,GdFieldPos("Z1_VALEMB")] // NAO
			nIcmRet += aCOLS[nI,GdFieldPos("Z1_ICMSRET")]
		Endif
	Next nI

	aValores[VALMERC]	:= nMerc
	aValores[VALDESC]	:= nDesc
	aValores[FRETE]		:= nFrete
	aValores[SEGURO]	:= nSeguro
	aValores[VALDESP]	:= nDesp

//aValores[VALMERC]	:= MaFisRet(,"NF_VALMERC")
//aValores[VALDESC]	:= MaFisRet(,"NF_DESCONTO")
//aValores[FRETE]		:= MaFisRet(,"NF_FRETE")
//aValores[TOTPED]	:= MaFisRet(,"NF_TOTAL")
//aValores[SEGURO]	:= MaFisRet(,"NF_SEGURO")
//aValores[VALDESP]	:= MaFisRet(,"NF_DESPESA")

//If cPaisLoc == "PTG"
//	aValores[NTRIB]	:= MaFisRet(,"NF_DESNTRB")
//	aValores[TARA]	:= MaFisRet(,"NF_TARA")
//Endif

//nTotalB += (SZ1->Z1_VALFRE) + (SZ1->Z1_VALIPI) +	(SZ1->Z1_ICMSRET) + (SZ1->Z1_TOTAL) + (SZ1->Z1_VALEMB) -
//(SZ1->Z1_VLDESC) + (SZ1->Z1_DESPESA)

	aValores[TOTPED] := nFrete + nIPI + nIcmRet + nMerc + nEmb - nDesc + nDesp

//aValores[TOTF1]	:= aValores[VALDESP]+aValores[SEGURO]+Iif(cPaisLoc=="PTG",aValores[NTRIB]+aValores[TARA],0)
//aValores[TOTF3]	:= aValores[FRETE]+aValores[SEGURO]+aValores[VALDESP]+Iif(cPaisLoc=="PTG",aValores[NTRIB]+aValores[TARA],0)
//aValores[IMPOSTOS]	:= aClone(MaFisRet(,"NF_IMPOSTOS"))

	RestArea(aArea)

Return .T.



//+--------------------------------------------------------------------+
//| Descr. |  Executa o refresh nos objetos do array.  |
//+--------------------------------------------------------------------+
Static Function yA120FRefr(aObj)

	Local nX := 0

	For nX := 1 to Len(aObj)

		If cPaisLoc <> "PTG" .and. (nX == 1 .OR. nX == 2 .OR. nX == 3 .OR. nX == 4 .OR. nX == 22 .OR. nX == 23  ) //# "1|2|3|4|22|23"
			aObj[nX]:Refresh()
		Elseif cPaisLoc == "PTG" .and. (nX == 11 .OR. nX == 2 .OR. nX == 3 .OR. nX == 4 .OR. nX == 22 .OR. nX == 23 .OR. nX == 25 .OR. nX == 26  )
			aObj[nX]:Refresh()
		Endif

	Next nX

Return .T.


//+--------------------------------------------------------------------+
//| Descr. |  Monta a legenda |
//+--------------------------------------------------------------------+
/*Static function Legenda()
	Local aLegenda := {}
	AADD(aLegenda,{"BR_AMARELO"     ,"   Tipo não definido" })
	AADD(aLegenda,{"BR_AZUL"    	,"   Tipo PC" })
	AADD(aLegenda,{"BR_VERDE"    	,"   Tipo UN" })
	AADD(aLegenda,{"BR_VERMELHO" 	,"   Tipo MT" })

	BrwLegenda("Legenda", "Legenda", aLegenda)
Return Nil*/
