#INCLUDE "PROTHEUS.CH" 
#INCLUDE "RWMAKE.CH"

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбддддддддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    Ё ImpRpa   Ё Autor Ё MARINALDO DE JESUS         Ё Data Ё 31/05/00 Ё╠╠
╠╠цддддддддддеддддддддддадддддддаддддддддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё RPA - RECIBO DE PAGAMENTO DE AUTONOMOS                          Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё Chamada padr└o para programas em RdMake                         Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ                                                                 Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё Generico                                                        Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁObservacaoЁ -Para a Impressao do Numero de Inscricao do Autonomo no INSS    Ё╠╠
╠╠Ё          Ё do Tipo de Servico e do Orgao Emissor do RG, sera necessario    Ё╠╠
╠╠Ё          Ё estar incluido, no Cadastro de Funcionarios, os Campos:         Ё╠╠
╠╠Ё          Ё                                                                 Ё╠╠
╠╠Ё          Ё RA_NUMINSC - Tipo Caracter,Tamanho 11 Masc @R 9999.9999.999     Ё╠╠
╠╠Ё          Ё RA_SERVICO - Tipo Caracter,Tamanho 60 Masc @!                   Ё╠╠
╠╠Ё          Ё RA_ORGEMRG - Tipo Caracter,Tamanho 05 Masc @R! NNN/NN           Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.                  Ё╠╠╠╠╠╠╠
╠╠цддддддддддддбддддддддбддддддддддддддддбдддддддддддддддддддддддддддддддддддддадддд©╠╠
╠╠ЁProgramador Ё Data   Ё Chd./Requisito Ё  Motivo da Alteracao                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддддддддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Ademar Jr. Ё18/03/13|Requisito:      Ё-Unificacao dos fontes da fase padrao com Ё╠╠
╠╠Ё            Ё        ЁRHU210_09_12    Ё a fase 4 (localizacoes).                 Ё╠╠
╠╠Ё            Ё        Ё                Ё                                          Ё╠╠  
╠╠ЁChristiane VЁ17/06/14|    TPUSHG      ЁCorreГЦo do posicion. do campo RA_SERVICO Ё╠╠
╠╠ЁRaquel HagerЁ29/06/16|TVGHFB          ЁAjuste no filtro de Categorias.           Ё╠╠
╠╠ЁRaquel HagerЁ06/06/16|TVGHFB          ЁRemoГЦo de tratamento para Valores Extras.Ё╠╠
╠╠юддддддддддддаддддддддаддддддддддддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
**/
User Function ZGPER04()

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Define Variaveis Basicas Genericas                           Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/  
Private CSTRING,AORD,CDESC1,CDESC2,CDESC3,LEND,NLASTKEY,CPERG,NOMEPROG,;
ARETURN,TITULO,LI,NTAMANHO,WNREL,NORDEM,NTIPORPA,CSEMANA,CFILDE,CFILATE,;
CCCDE,CCCATE,CMATDE,CMATATE,CNOMEDE,CNOMEATE,CSITUACAO,CCATEGORIA,CNUMRPA,DDATAREF,LATUAL,;
CARQANT,CARQNEW,LIGUAL,CSAVSCR1,CSAVCUR1,CSAVROW1,;
CSAVCOL1,CSAVCOR1,CINDRC,CRCNTX,NPOSANOMES,CDATAANT,;
CEXCLUI,CINICIO,CFIM,CFILIALANT,CCCANT,CNUMANT,;
CFILMAT,CDESC_FIL,CDESC_CC,CDESC_CGC,CLOCAL_FIL,AINFO,;
ACODFOL,NVALORAUT,NINSSAUT,NIRRFAUT,NOUTVENC,NOUTDESC,;
NTOTVENC,NTOTDESC,NLIQUIDO,NOUTVEN,CQUERY,;
AIMPRPA,NCOLUNAS,CRET1,CRET2,CEXTENSO,NPOSRPA,AREGS, DDATAPGTO

Private lFase4  := (cPaisLoc $ "ANG|ARG|COL|PTG|VEN")
Private cMes	:= ""
Private cAno    := ""

Private aPerAberto	:= {}
Private aPerFechado	:= {}
Private cProcesso	:= "" // Armazena o processo selecionado na Pergunte GPR040 (mv_par01).
Private cRoteiro	:= "" // Armazena o Roteiro selecionado na Pergunte GPR040 (mv_par02).
Private cPeriodo	:= "" // Armazena o Periodo selecionado na Pergunte GPR040 (mv_par03).
     u_zcfga01( 'ZGPER04' ) //LGS#2021202 - GravaГЦo de log de utilizaГЦo da rotina
cString   := 'SRA'                                                                          //Alias do arquivo principal (Base).
//aOrd      := {'Matricula', "C.Custo", "Nome", "C.Custo + Nome" }                          //'Matricula'###'C.Custo'###'Nome'###'C.Custo + Nome'
aOrd      := {'Matricula', "C.Custo", "Nome", "C.Custo + Nome", "Depto.", "Depto. + Nome" } //"Matricula"###"C.Custo"###"Nome"###"C.Custo + Nome"###"Depto."###"Depto. + Nome"
cDesc1    := 'EmissЦo de Recibos de Pagamento de Autonomo.'                                 //'Emiss└o de Recibos de Pagamento de Autonomo.'
cDesc2    := 'Ser═ impresso de acordo com os parametros solicitados pelo'                   //'Ser═ impresso de acordo com os parametros solicitados pelo'
cDesc3    := 'usuario.'                                                                     //'usuario.'
lEnd      := .F.
nLastKey  := 0
cPerg     := 'ZGPER04'
nomeprog  := 'RPA'
aReturn   := { 'Zebrado', 1, 'AdministraГЦo', 2, 2, 1, '',1 }   //'Zebrado'###'Administra┤└o'

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Titulo do Relatorio                                          Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Titulo		:= cDesc1

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Variaveis Para a Funcao fImpRpa()                            Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Li			:= 0
nTamanho	:= "P"

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Variaveis de Acesso do Usuario                               Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
cAcessaSRA	:= &( " { || " + ChkRH( "IMPRPA" , "SRA" , "2" ) + " } " )

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Verifica as Perguntas Selecionadas nos Parametros            Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Pergunte(cPerg,.F.)

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Envia controle para a funcao SETPRINT                        Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
WnRel := 'RPA' // Nome Default do relatorio em Disco.
WnRel := SetPrint(cString,Wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,nTamanho)

IF nLastKey == 27
	Return Nil
EndIF

SetDefault(aReturn,cString)

IF nLastKey == 27
	Return Nil
EndIF

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Chamada do Relatorio.                                        Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
RptStatus( { |lEnd| fIncRpa() } , Titulo )

Return Nil


/***********************/
Static Function fIncRpa()
/***********************/

Local cAliasAux		:= "SRC"
Local cPrefixo		:= "RC_"
Local cAcessaVLD	:= ""

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Verifica Ordem do Relatorio                                  Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
nOrdem    := aReturn[8]

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Verifica as Perguntas Selecionadas nos Parametros            Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Pergunte(cPerg,.F.)

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Carregando variaveis MV_PAR?? para Variaveis do Sistema.     Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
cProcesso  := mv_par01
cRoteiro   := mv_par02
cPeriodo   := mv_par03
cSemana    := mv_par04

//Carregar os periodos abertos (aPerAberto) e/ou 
// os periodos fechados (aPerFechado), dependendo 
// do periodo (ou intervalo de periodos) selecionado
RetPerAbertFech(cProcesso	,; // Processo selecionado na Pergunte.
				cRoteiro	,; // Roteiro selecionado na Pergunte.
				cPeriodo	,; // Periodo selecionado na Pergunte.
				cSemana		,; // Numero de Pagamento selecionado na Pergunte.
				NIL			,; // Periodo Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um periodo.
				NIL			,; // Numero de Pagamento Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um numero de pagamento.
				@aPerAberto	,; // Retorna array com os Periodos e NrPagtos Abertos
				@aPerFechado ) // Retorna array com os Periodos e NrPagtos Fechados
				
// Retorna o mes e o ano do periodo selecionado na pergunte.
AnoMesPer(	cProcesso	,; // Processo selecionado na Pergunte.
			cRoteiro	,; // Roteiro selecionado na Pergunte.
			cPeriodo	,; // Periodo selecionado na Pergunte.
			@cMes		,; // Retorna o Mes do Processo + Roteiro + Periodo selecionado
			@cAno		,; // Retorna o Ano do Processo + Roteiro + Periodo selecionado     
			cSemana		 ) // Retorna a Semana do Processo + Roteiro + Periodo selecionado

If !Empty(aPerAberto)
	dDataRef 	:= aPerAberto[1,7]
	cAliasAux	:= "SRC"
	cPrefixo	:= "RC_"
	cAcessaVLD	:= &( " { || " + ChkRH( "IMPRPA" , "SRC" , "2" ) + " } " )
ElseIf !Empty(aPerFechado)
	dDataRef 	:= aPerFechado[1,7]
	cAliasAux	:= "SRD"
	cPrefixo	:= "RD_"
	cAcessaVLD	:= &( " { || " + ChkRH( "IMPRPA" , "SRD" , "2" ) + " } " )
Else			
	dDataRef := CtoD("01/" + cMes + "/" + cAno)
EndIf

cFilDe		:= MV_PAR05
cFilAte		:= MV_PAR06
cCcDe		:= MV_PAR07
cCcAte		:= MV_PAR08
cMatDe		:= MV_PAR09
cMatAte		:= MV_PAR10
cNomeDe		:= MV_PAR11
cNomeAte	:= MV_PAR12
cSituacao	:= MV_PAR13
cCategoria	:= MV_PAR14
cNumRpa		:= MV_PAR15
cDeptoDe	:= mv_par16
cDeptoAte	:= mv_par17

cMesAnoRef := StrZero(Month(dDataRef),2) + StrZero(Year(dDataRef),4)

/*
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁBloco que definira a Consistencia da Parametrizacao dos Intervalos seleЁ
Ёcionados nas Perguntas De? Ate? para o Skip/Loop e Para a SetRegua()   Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
cExclui := ""
cExclui := cExclui + "{ || "
cExclui := cExclui + "(RA_FILIAL  < cFilDe     .or. RA_FILIAL  > cFilAte    ).or."
cExclui := cExclui + "(RA_MAT     < cMatDe     .or. RA_MAT     > cMatAte    ).or."
cExclui := cExclui + "(RA_CC      < cCcDe      .or. RA_CC      > cCCAte     ).or."
cExclui := cExclui + "(RA_NOME    < cNomeDe    .or. RA_NOME    > cNomeAte   ).or."
cExclui := cExclui + "(RA_DEPTO   < cDeptoDe   .or. RA_DEPTO   > cDeptoAte  ).or."
cExclui := cExclui + "!(RA_SITFOLH$cSituacao).or.!(RA_CATFUNC$'A')"
cExclui := cExclui + " } "

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Seleciona Arquivo Principal e Carrega Regua de Processamento Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
dbSelectArea('SRA')
SetRegua( SRA->( RecCount() ) )
dbGotop()

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Posicionando no Primeiro Registro do Parametro               Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
IF nOrdem == 1
	dbSetOrder(nOrdem)
	dbSeek( cFilDe + cMatDe, .T. )
	cInicio := '{ || RA_FILIAL + RA_MAT }'
	cFim    := cFilAte + cMatAte
ElseIF nOrdem == 2
	dbSetOrder(nOrdem)
	dbSeek( cFilDe + cCcDe + cMatDe, .T. )
	cInicio  := '{ || RA_FILIAL + RA_CC + RA_MAT }'
	cFim     := cFilAte + cCcAte + cMatAte
ElseIF nOrdem == 3
	dbSetOrder(nOrdem)
	dbSeek( cFilDe + cNomeDe + cMatDe, .T. )
	cInicio := '{ || RA_FILIAL + RA_NOME + RA_MAT }'
	cFim    := cFilAte + cNomeAte + cMatAte
ElseIF nOrdem == 4
	dbSetOrder(08)
	dbSeek( cFilDe + cCcDe + cNomeDe, .T. )
	cInicio  := '{ || RA_FILIAL + RA_CC + RA_NOME } '
	cFim     := cFilAte + cCcAte + cNomeAte
ElseIf nOrdem == 5
	dbSetOrder(21)
	dbSeek(cFilDe + cDeptoDe + cMatDe, .T.)
	cInicio  := '{ || RA_FILIAL + RA_DEPTO + RA_MAT } '
	cFim     := cFilAte + cDeptoAte + cMatAte
ElseIf nOrdem == 6
	dbSetOrder(22)
	dbSeek(cFilDe + cDeptoDe + cNomeDe, .T.)
	cInicio  := '{ || RA_FILIAL + RA_DEPTO + RA_NOME } '
	cFim     := cFilAte + cDeptoAte + cNomeAte
EndIF

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Variaveis Para Impressao dos Dados da Empresa/Autonomo       Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
cFilialAnt	:= Space(FWGETTAMFILIAL)
cCcAnt		:= Space(GetSx3Cache("RA_CC", "X3_TAMANHO"))
cNumAnt		:= cNumRpa
cFilMat		:= ""
cDesc_Fil	:= ""
cDesc_Cc	:= ""
cDesc_CGC	:= ""
cLocal_Fil  := ""
aInfo		:= {}
aCodFol		:= {}
nValorAut	:= 0
nINSSAut	:= 0
nIRRFAut	:= 0
nOutVenc	:= 0
nOutDesc	:= 0
nTotVenc	:= 0
nTotDesc	:= 0
nLiquido	:= 0

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Ira Executar Enquanto Estiver dentro do Escopo dos ParametrosЁ
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
While SRA->( !Eof() .and. Eval( &(cInicio) ) <= cFim )
	
	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Reinicializa Variaveis                                       Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	nValorAut := 0 ; nIRRFAut := 0 ; nINSSAut := 0
	nOutVenc  := 0 ; nOutDesc := 0 ; nTotVenc := 0
 	nTotDesc  := 0 
	
	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Movimenta Regua Processamento                                Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	IncRegua()
	
	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Cancela Impresфo                                             Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	IF lEnd
		@ Prow()+1,0 PSAY cCancel
		Exit
	EndIF
	
	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Consiste Parametrizacao do Intervalo de Impressao            Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	IF SRA->( Eval ( &(cExclui) ) )
		dbSelectArea("SRA")
		dbSkip()
		Loop
	EndIF
	
	cFilMat := SRA->( RA_FILIAL + RA_MAT )
	
	/*
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁConsiste Filiais e Acessos                                             Ё
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	IF !( SRA->RA_FILIAL $ fValidFil() .and. Eval( cAcessaSRA ) )
		dbSelectArea("SRA")
		dbSkip()
		Loop
	EndIF
	
	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Carregando Informacoes das Verbas e da Filial                Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	IF SRA->RA_FILIAL != cFilialAnt
		IF !Fp_CodFol(@aCodFol,SRA->RA_FILIAL) .or. !fInfo(@aInfo,SRA->RA_FILIAL)
			/*
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Encerra o Loop se Nao Existir Cadastro de Verbas ou Filial   Ё
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
			Exit
		EndIF
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Descricao da Filial e do CGC                                 Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		cDesc_Fil	:= aInfo[3]
		cLocal_FIl	:= aInfo[5]
		cDesc_CGC	:= aInfo[8]
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Atualiza a Variavel cFilialAnt                               Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		dbSelectArea("SRA")
		cFilialAnt := SRA->RA_FILIAL
	EndIF
	
	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё TIPO DE ROTEIRO (cTipoRot)                                   Ё
	Ё ==========================                                   Ё
	Ё 1- Folha de Pagamento                                        Ё
	Ё 2- Adiantamento                                              Ё
	Ё 3- Ferias                                                    Ё
	Ё 4- Rescisao                                                  Ё
	Ё 5- 1a.Parcela 13o.Salario                                    Ё
	Ё 6- 2a.Parcela 13o.Salario                                    Ё
	Ё 7- Outros                                                    Ё
	Ё 8- Vale Transporte                                           Ё
	Ё 9- Autonomos                                                 Ё
	Ё A- Provisao                                                  Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	
	dbSelectArea(cAliasAux)
	dbSetOrder(1)
	IF dbSeek( cFilMat , .T. )
		While (cAliasAux)->( !Eof() .and. &(cPrefixo+"FILIAL") + &(cPrefixo+"MAT") == cFilMat )
			
			/*
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Cancela Impressao.                                           Ё
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
			IF lEnd
				Exit
			EndIF
			
			If !Eval(cAcessaVLD)
				dbSelectArea(cAliasAux)
				dbSkip()
				Loop
			EndIf
			
			/*
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Faz as verificacoes iniciais basicas                         Ё
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
			If (cAliasAux)->&(cPrefixo+"PROCES") <> cProcesso
				dbSelectArea(cAliasAux)
				dbSkip()
				Loop
			EndIf
			
			If (cAliasAux)->&(cPrefixo+"ROTEIR") <> cRoteiro
				dbSelectArea(cAliasAux)
				dbSkip()
				Loop
			EndIf
			
			If (cAliasAux)->&(cPrefixo+"PERIODO") <> cPeriodo
				dbSelectArea(cAliasAux)
				dbSkip()
				Loop
			EndIf
			
			IF (cAliasAux)->&(cPrefixo+"SEMANA") # cSemana .And. cSemana # "99"
				dbSelectArea(cAliasAux)
				dbSkip()
				Loop
			EndIF
			
			/*
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Identificador de Calculo da Verba de Desconto do AdiantamentoЁ
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
			IF (cAliasAux)->&(cPrefixo+"PD") $ aCodFol[007,1] +"*"+ aCodFol[008,1] +"*"+ aCodFol[022,1] .AND. (cAliasAux)->&(cPrefixo+"ROTEIR") == "ADI"
				nOutVenc += (cAliasAux)->&(cPrefixo+"VALOR")
				
				/*
				здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				Ё Identificador de Calculo da Verba de I.R.R.F. Sobre o Adto.  Ё
				юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
			ElseIF (cAliasAux)->&(cPrefixo+"PD") $ aCodFol[066,1] +"*"+ aCodFol[071,1]
				nIRRFAut += (cAliasAux)->&(cPrefixo+"VALOR")
				
				/*
				здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				Ё Identificador de Calculo da Verba de Pagamento de Autonomo.  Ё
				юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
			ElseIF (cAliasAux)->&(cPrefixo+"PD") == aCodFol[218,1]
				nValorAut += (cAliasAux)->&(cPrefixo+"VALOR")
				dDataPgto := (cAliasAux)->&(cPrefixo+"DTREF") //LGS#20181114 - CRIAгцO DE DATA DE PAGAMENTO PARA RECIBO, BUSCANDO INFORMAгцO DA REFERENCIA
				/*
				здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				ЁIdentificadores de Calculo da Verba de IRRF,  do INSS AutonomoЁ
				Ёdo INSS de Folha, Ferias e de 13o. Salario.                   Ё
				юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
			ElseIF (cAliasAux)->&(cPrefixo+"PD") $ aCodFol[222,1] +"*"+ aCodFol[064,1] +"*"+ aCodFol[065,1] +"*"+ aCodFol[070,1]
				nINSSAut += (cAliasAux)->&(cPrefixo+"VALOR")
				
			Else
				/*
				здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				Ё Verifica as Verbas de Proventos que se Referem a AdiantamentoЁ
				юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
				IF PosSrv( (cAliasAux)->&(cPrefixo+"PD") , SRA->RA_FILIAL, "RV_TIPOCOD") == "1" //Proventos
				
					IF !( (cAliasAux)->&(cPrefixo+"PD") == aCodFol[218,1] )
						/*
						здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						Ё Outros Vencimentos                                           Ё
						юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
						nOutVenc += (cAliasAux)->&(cPrefixo+"VALOR")
					EndIF
					/*
					здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					Ё Verifica as Verbas de Descontos que se Referem a AdiantamentoЁ
					юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
				ElseIF PosSrv( (cAliasAux)->&(cPrefixo+"PD") , SRA->RA_FILIAL, "RV_TIPOCOD") == "2" //Descontos
				
					IF !( (cAliasAux)->&(cPrefixo+"PD") $ aCodFol[222,1] +"*"+ aCodFol[064,1] +"*"+ aCodFol[065,1] +"*"+ aCodFol[070,1] )
						/*
						здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						ЁOutros Descontos                                              Ё
						юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
						nOutDesc += (cAliasAux)->&(cPrefixo+"VALOR")
					EndIF
				EndIF
			EndIF
			
			dbSelectArea(cAliasAux)
			dbSkip()
		Enddo
	EndIF
	
	nTotVenc := nValorAut + nOutVenc
	nTotDesc := nIRRFAut  + nINSSAut + nOutDesc
	
	nLiquido := Max( nTotVenc - nTotDesc , 0 )
	
	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Se Nao Tiver Valores a Imprimir, Salta Para o Proximo RegitroЁ
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	dbSelectArea("SRA")
	IF nTotVenc == 0 .and. nTotDesc == 0
		dbSkip()
		Loop
	EndIF
	
	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Numeracao do Recibo                                          Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	IF cNumAnt != cNumRpa
		cNumRpa := StrZero( Val(cNumRpa) + 1 , 10 )
	EndIF
	
	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Imprime os Recibos de Autonomo                               Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	fImpRPA()
	
	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Proximo Registro                                             Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	dbSelectArea("SRA")
	dbSkip()
	cNumAnt := ""
Enddo

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Grava o Ultimo Numero Impresso no SX1                        Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
//LGS#20200130 - AdequaГЦo para release 12.1.25 e posteriores
/*dbSelectArea( "SX1" )
dbSetOrder(1)
IF dbSeek( cPerg + "15" )	//-MV_PAR15
	RecLock("SX1",.F.,.T.)
	SX1->X1_CNT01 := cNumRpa
	MsUnlock()
EndIF*/

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Restaura a Ordem Primaria dos Indices.                       Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
dbSelectArea("SRC") ; dbSetOrder(1)
dbSelectArea("SRD") ; dbSetOrder(1)
dbSelectArea("SRA") ; dbSetOrder(1)

IF aReturn[5] == 1
	Set Printer To
	dbCommit()
	OurSpool(WnRel)
EndIF

MS_FLUSH()
Return


/*
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁfImpRPA   Ё Autor ЁMarinaldo de Jesus     Ё Data Ё02/06/2000Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁImprime Recibo de Pagamento de Autonomo                     Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function fImpRPA()

Local nCarCH
Local nPosRpa

aImpRpa		:= {}
nColunas	:= IF(nTamanho == "P" , 80 , IF( nTamanho == "G", 220 , 132) )
cRet1		:= ""
cRet2		:= ""

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Extraindo o Extenso do Liquido.                              Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
cExtenso	:= Extenso(nLiquido,.F.,1 )

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Separando o Extenso para impressao em 2 Linhas.              Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
SepExt(cExtenso,43,80,@cRet1,@cRet2)

cRet1 := IF( !Empty(cRet1), "(" + cRet1 , cRet1 )
cRet1 := IF( !Empty(cRet1) .and. Len(AllTrim(cRet1)) < 43 .and. Empty(cRet2), AllTrim(cRet1) + ")",cRet1)
cRet2 := IF( !Empty(cRet2), AllTrim(cRet2) + ".****)" , cRet2 )

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Carrega a Mascara do Recibo.                                 Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
//                                  10        20        30        40        50        60        70        80
//                          12345678901234567890123456789012345678901234567890123456789012345678901234567890
aAdd( aImpRpa, '       RECIBO DE PAGAMENTO DE AUTONOMO  - RPA     +-------- No.RECIBO ---------+' ) // 01
aAdd( aImpRpa, '                                                  |                            |' ) // 02
aAdd( aImpRpa, '+-------------------------------------------------+----------------------------+' ) // 03
aAdd( aImpRpa, '| NOME OU RAZAO SOCIAL DA EMPRESA                 |   MATRICULA (GCG ou INSS)  |' ) // 04
aAdd( aImpRpa, '|                                                 |                            |' ) // 05
aAdd( aImpRpa, '+-------------------------------------------------+----------------------------+' ) // 06
aAdd( aImpRpa, '           RECEBI DA EMPRESA ACIMA IDENTIFICADA, PELA PRESTACAO DOS SERVICOS  DE' ) // 07
aAdd( aImpRpa, '                                                                                ' ) // 08
aAdd( aImpRpa, 'A IMPORTANCIA DE:                                                               ' ) // 09
aAdd( aImpRpa, '                                                                                ' ) // 10
aAdd( aImpRpa, '+--------- NUMERO DE INSCRICAO ---------+ ESPECIFICACAO:                        ' ) // 11
aAdd( aImpRpa, '| NO INSS :                             | I VALOR DO SERVICO.....               ' ) // 12
aAdd( aImpRpa, '| NO CPF  :                             | II OUTROS..............               ' ) // 13
aAdd( aImpRpa, '+------------- IDENTIDADE --------------+      SOMA..............               ' ) // 14
aAdd( aImpRpa, '| NUMERO :                              |                                       ' ) // 15
aAdd( aImpRpa, '| ORGAO EMISSOR :          UF :         | DESCONTOS:                            ' ) // 16
aAdd( aImpRpa, '+-------------- ENDERECO ---------------+ III  I.R.R.F...........               ' ) // 17
aAdd( aImpRpa, '|                                       | IV   INSS..............               ' ) // 18
aAdd( aImpRpa, '|                                       | V    OUTROS............               ' ) // 19
aAdd( aImpRpa, '|                                       |                                       ' ) // 20
aAdd( aImpRpa, '|                                       | VALOR LIQUIDO..........               ' ) // 21
aAdd( aImpRpa, '+------- LOCALIDADE -------+--- DATA ---+ +------------ ASSINATURA ------------+' ) // 22
aAdd( aImpRpa, '|                          |            | |                                    |' ) // 23
aAdd( aImpRpa, '+--------------------------+------------+ +------------------------------------+' ) // 24
aAdd( aImpRpa, 'C.CUSTO:                                  +----------- NOME COMPLETO ----------+' ) // 25
aAdd( aImpRpa, '                                          |                                    |' ) // 26
aAdd( aImpRpa, '                                          +------------------------------------+' ) // 27

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Inclui as Informacoes da Empresa/Autonomo                    Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
For nPosRpa := 1 To Len(aImpRpa)
	
	IF nPosRpa == 2
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega o Numero do Recibo.                                  Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 69 , Len(cNumRpa) , cNumRpa )
	
	ElseIF nPosRpa == 4 .And. cPaisLoc != "BRA"
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Configura o titulo como RUC.                                 Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/            
		IF SRA->( FieldPos("RA_SERVICO") != 0 )
			cString := RetTitle("RA_CIC",5)+"/"+RetTitle("RA_SERVICO",5)+")"
		Else
			cString := RetTitle("RA_CIC",5)+")"
		EndIf
		
        If Len(cString) < 12
        	cString := cString+Space(12-Len(cString))
        EndIf
      	nTam := Len(cString)

		aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 66 , nTam, cString)
	
	ElseIF nPosRpa == 5
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega o Nome da Empresa                                    Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 03 , Len(AllTrim( cDesc_Fil) ) , AllTrim( cDesc_Fil ) )
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega o CGC da Empresa                                     Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		If cPaisLoc != "BRA"
			cString := Transform(cDesc_CGC, PesqPict("SA1","A1_CGC"))
			
	        If Len(cString) < 17
	        	cString := cString+Space(17-Len(cString))
	        EndIf
	      	nTam := Len(cString)

			aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 61 , nTam , cString )
		Else
			aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 61 , Len(Transform(cDesc_CGC, "@R ##.###.###/####-##")) , Transform(cDesc_CGC, "@R ##.###.###/####-##") )
		EndIf
	
	ElseIF nPosRpa == 08
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Se Existir o Campo no Cadastro de Funcionarios, Carrega a DesЁ
		Ё cricao do Tipo de Servico Prestado.(Tipo Caract., Tamanho 80)Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		IF SRA->( FieldPos("RA_SERVICO") != 0 )
			aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 02 , Len(AllTrim(SRA->RA_SERVICO) ) , AllTrim(SRA->RA_SERVICO ) )
		EndIF
	
	ElseIF nPosRpa == 09
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega o Valor Liquido                                      Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 19 , Len(AllTrim('R$ '))  , AllTrim('R$ ') )
		aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 22 , Len(TransForm(nLiquido, "@E 999,999,999.99")) , TransForm(nLiquido, "@E 999,999,999.99") )
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega o Extenso (1a. Linha)                                Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 36 , Len( cRet1 ) , cRet1 )
	
	ElseIF nPosRpa == 10
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega o Extenso (2a. Linha)                                Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 03 , Len( cRet2 ) , cRet2 )
	
	ElseIF nPosRpa == 12
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega o Numero de Inscricao no INSS (Autonomo)             Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		IF SRA->( FieldPos("RA_NUMINSC") != 0 ) .And. !Empty(SRA->RA_NUMINSC)
			aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 13 , Len(TransForm(SRA->RA_NUMINSC, "@R 9999.9999.999")) , TransForm(SRA->RA_NUMINSC, "@R 9999.9999.999") )
		Else
			aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 13 , Len(TransForm(SRA->RA_PIS, "@R 9999.9999.999")) , TransForm(SRA->RA_PIS, "@R 9999.9999.999") )
		EndIF
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega o Valor da Prestacao de Servico                      Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		If cPaisLoc != "BRA"
			IF SRA->( FieldPos("RA_SERVICO") != 0 )
				aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 06 , 06, RetTitle("RA_SERVICO",5)+":" )
			Else
				aImpRpa[nPosRpa] := StrTran( aImpRpa[nPosRpa], SubStr(aImpRpa[nPosRpa],2,10), Space(10) )
			EndIf
		EndIf
		aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 66 , Len(TransForm(nValorAut, "@E 999,999,999.99")) , TransForm(nValorAut, "@E 999,999,999.99") )
	
	ElseIF nPosRpa == 13
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega o Numero do CPF do Autonomo                          Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		If cPaisLoc <> "BRA"
			aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 06 , 06, RetTitle("RA_CIC",5)+":" )
			cString := TransForm(SRA->RA_CIC, PesqPict("SRA","RA_CIC"))
			If Len(cString) < 14
				cString := cString+Space(14-Len(cString))
			EndIf
			nTam := Len(cString)
			
			aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 13 , nTam , cString )
		Else
			aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 13 , Len(TransForm(SRA->RA_CIC, "@R 999.999.999-99")) , TransForm(SRA->RA_CIC, "@R 999.999.999-99") )
		EndIf
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega o Valor de Outros Vencimentos                        Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 66 , Len(TransForm(nOutVenc, "@E 999,999,999.99")) , TransForm(nOutVenc, "@E 999,999,999.99") )
	
	ElseIF nPosRpa == 14
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega a Soma dos Vencimentos                               Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 66 , Len(TransForm(nTotVenc, "@E 999,999,999.99")) , TransForm(nTotVenc, "@E 999,999,999.99") )
	
	ElseIF nPosRpa == 15
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega o Numero do RG do Autonomo                           Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 13 , Len(TransForm(SRA->RA_RG, "@R 999.999.999-99")) , TransForm(SRA->RA_RG, "@R 999.999.999-99") )
	
	ElseIF nPosRpa == 16
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		ЁSe Existir o Campo RA_ORGEMRG, no Cadastro de Funcionarios,CarЁ
		Ёrega o Orgao Emissor do RG e a U.F.(Tipo Caracter, Tam 05)    Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		IF SRA->( FieldPos("RA_ORGEMRG") != 0 ) .And. !Empty(SRA->RA_ORGEMRG)
			aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 19 , Len(Subst(SRA->RA_ORGEMRG,1,3)) , Subst(SRA->RA_ORGEMRG,1,3) )
			aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 33 , Len(Subst(SRA->RA_ORGEMRG,4,2)) , Subst(SRA->RA_ORGEMRG,4,2) )
		Else
			aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 19 , Len(TransForm(SRA->RA_RGORG, "@R 999")) , SRA->RA_RGORG )

			If SRA->( FieldPos("RA_RGUF") != 0 ) .And. !Empty(SRA->RA_RGUF)
				aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 33 , Len(TransForm(SRA->RA_RGUF, "@R 99")) , SRA->RA_RGUF )
			Endif
		EndIF
	
	ElseIF nPosRpa == 17
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega o Valor do I.R.R.F.                                  Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		If cPaisLoc != "BRA"
			aImpRpa[nPosRpa] := StrTran( aImpRpa[nPosRpa], SubStr(aImpRpa[nPosRpa],48,18), Replicate(".",18) )
		EndIf
		aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 66 , Len(TransForm(nIRRFAut, "@E 999,999,999.99")) , TransForm(nIRRFAut, "@E 999,999,999.99") )
	
	ElseIF nPosRpa == 18
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega o Endereco do Funcionario                            Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 03 , Len(AllTrim(SRA->RA_ENDEREC)) , AllTrim(SRA->RA_ENDEREC) )
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega o Valor do INSS de Autonomos                         Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		If cPaisLoc != "BRA"
			aImpRpa[nPosRpa] := StrTran( aImpRpa[nPosRpa], SubStr(aImpRpa[nPosRpa],48,18), Replicate(".",18) )
		EndIf
		aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 66 , Len(TransForm(nINSSAut, "@E 999,999,999.99")) , TransForm(nINSSAut, "@E 999,999,999.99") )
	
	ElseIF nPosRpa == 19
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega o Complemento do Endereco do Funcionario             Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 03 , Len(AllTrim(SRA->RA_COMPLEM)) , AllTrim(SRA->RA_COMPLEM) )
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega o Valor de Outros Descontos                          Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 66 , Len(TransForm(nOutDesc, "@E 999,999,999.99")) , TransForm(nOutDesc, "@E 999,999,999.99") )
	
	ElseIF nPosRpa == 20
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega o Bairro do Funcionario                              Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		If cPaisLoc == "PER"
			aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 03 , Len(AllTrim(RetContUbigeo("SRA->RA_CEP", "RA_BAIRRO"))) , AllTrim(RetContUbigeo("SRA->RA_CEP", "RA_BAIRRO")) )
		Else
			aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 03 , Len(AllTrim(SRA->RA_BAIRRO)) , AllTrim(SRA->RA_BAIRRO) )		
		Endif	

	ElseIF nPosRpa == 21
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega a Cidade do Funcionario                              Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		If cPaisLoc == "PER"
			aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 03 , Len(AllTrim(RetContUbigeo("SRA->RA_CEP", "RA_MUNICIP"))) , AllTrim(RetContUbigeo("SRA->RA_CEP", "RA_MUNICIP")) )		
		Else
			aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 03 , Len(AllTrim(SRA->RA_MUNICIP)) , AllTrim(SRA->RA_MUNICIP) )
		Endif
		
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega o Valor Liquido                                      Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 66 , Len(TransForm(nLiquido, "@E 999,999,999.99")) , TransForm(nLiquido, "@E 999,999,999.99") )
	
	ElseIF nPosRpa == 23
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega o Local                                              Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 03 , Len(AllTrim(cLocal_Fil)) , AllTrim(cLocal_Fil) )
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega o Data                                               Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		If mv_par18 == 1 //LGS#20181114 - IMPRIME DATA DO PERIODO. MELHORIA FEITA PARA ATENDER ESOCIAL
		   aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 30 , Len(Dtoc(dDataRef)) , Dtoc(dDataRef) )
		Else //LGS#20181114 - IMPRIME DATA DE REFERENCIA QUE и A DATA REAL DO PAGAMENTO AO AUTONOMO. MELHORIA FEITA PARA ATENDER ESOCIAL
	       aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 30 , Len(Dtoc(dDataPgto)) , Dtoc(dDataPgto) )
	    Endif
	ElseIF nPosRpa == 25
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega o Codigo do Centro de Custo                          Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 13 , Len(AllTrim(SRA->RA_CC)) , AllTrim(SRA->RA_CC) )
	
	ElseIF nPosRpa == 26
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega a Descricao do Centro de Custo                       Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		cDesc_CC := fDesc("SI3",SRA->RA_CC,"I3_DESC")
		aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 03 , Len(AllTrim(cDesc_CC)) , AllTrim(cDesc_CC) )
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega o Nome do Funcionario                                Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		aImpRpa[nPosRpa] := Stuff( aImpRpa[nPosRpa], 45 , Len(AllTrim(SRA->RA_NOME)) , AllTrim(SRA->RA_NOME)   )
	EndIF
	
Next nPosRpa

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Imprime o Recibo                                             Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
@ Li, 00 PSAY AvalImp( nColunas ) 
For nCarCH := 1 To Len(aImpRpa)
	
	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Cancela Impresфo ao se pressionar <ALT> + <A>                Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	IF lEnd == .T.
		Exit
	EndIF
	
	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Impressao do Recibo                                          Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	Li := Li + 1
	@ Li, 00 PSAY aImpRpa[nCarCH]
	
Next nCarCH

Li := Li + 2

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Imprime o Separador de Recibo ou Reinicializa Li             Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
IF Li == 29
	@ Li, 00 PSAY Replicate("-",nColunas)
	Li := Li + 1
Else
	Li := 0
EndIF

Return
