#INCLUDE "BRSPEDFIS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWCOMMAND.CH"
#INCLUDE "SPEDXDEF.CH"

/*
> CRIADO PROGRAMA SPEDXFUN QUE DEVERAH CONTER TODAS AS FUNCTIONS (PUBLICAS) DO SPED <

Programa  ³SPEDFISCAL³ Autor ³Gustavo G. Rueda ³ Data ³11.03.2011³±±
Descri‡…o ³Preparacao do meio-magnetico SPEDFISCAL

*/
// Chamada das funcoes de cache do dicionario na inicializacao do SPEDXFUN.

STATIC aSPDSX2 := SpedLoadX2()
STATIC aSPDSX3 := SpedLoadX3()
STATIC aSPDSX6 := SpedLoadX6()						      
STATIC aExistBloc := SPDFRetPEs()                                

User Function BRSPEDFIS()
Local	lEnd		:=	.F.
Local	cNomWiz		:=	"SPEDFIS" + FWGRPCOMPANY() + FWGETCODFILIAL
Local	cNomeAnt	:=	Iif(File(cNomWiz+".cfp"),"","SPEDFIS" + FWGETCODFILIAL)
Local	cFileDest	:=	"SPEDFISCAL.TXT"
Local 	cPerfil	:=	aSPDSX6[MV_PRFSPED]
Local	lCmpsVld	:=	.F.
Local	lTabComp	:=	.F.
Local	lTabCDT		:=	.F.
Local	lTabCD0		:=	.F.
Local	lTabCD1		:=	.F.
Local	lTabCE5		:=	.F.
Local	lIntTMS		:=	.F.
Local	cCmpsNaoEx	:=	""
Local	lJob		:=	.F.  
//Local  cNew       := "HMNew()"

Private cVersao		:=	""
Private oProcess	:=	Nil	//Utilizo private pq faco varias consistencias com VALTYPE
Private aReg0205	:=	{}	//O array aReg0205 e aReg0206 precisou ser declarado Private para que a mudanca de estrutura do reg. 0200 nao influencie em todo o
							//proces da rotina. Como os reg 0205 e 0220 passaram a ter um relacionamento com o reg pai 0200, foi necessario efetuar
							//esse tratamento, evitando maiores impactos nas chamadas da funcao SFRG0200(() e no desenv de outros Pontos de Entrada.
Private aReg0206	:=	{}
Private lBuild    := .f. //GetBuild() >= "7.00.131227A"
Private oHash0200
Private aWizScreen	:=	{}	//Wizard preenchido antes de chamar function SpedFiscal, permitindo utilizar SpedFiscal via Job/RPC
     u_zcfga01( 'BRSPEDFIS' ) //LGS#2021201 - Gravação de log de utilização da rotina
If lBuild
    oHash0200 := &cNew
EndIf 

aSPDSX6 := SpedLoadX6()

lJob := IIF(Len(aWizScreen) > 0,.T.,.F.)

if !lJob
	//SpedBanner() //banner do TAF
endif

//³funcao de inicializacao de ambiente³
cCmpsNaoEx	:=	SPEDOpenEnv(@lTabComp,@lTabCDT,@lTabCD0,@lIntTMS,@lCmpsVld,@lTabCE5,@lTabCD1)

//³Msg de alerta quando nao existir os campos criados pelo UPDFIS e que sao utilizados pela rotina³
If lJob .Or. lCmpsVld .Or. (!lCmpsVld .And. MsgYesNo(STR0020+CRLF+CRLF+"Campos: "+cCmpsNaoEx,STR0021)) //"Alguns campos import. criados pelo compatib UPDFIS não foram encontrados na base de dados para o correto proces do SPED Fiscal. Deseja continuar mesmo sem esses campos ? (As informações poderão ser geradas de forma divergente) "###"Atenção!!!"
	
	//³Chamada da funcao que monta o Wizard da rotina³
	If lJob .Or. SpedMntWiz(cNomWiz,cPerfil,cNomeAnt)
		If !lJob
			oProcess := FISProgress():New({|lEnd| PrSped(@lEnd,@cFileDest,cPerfil,@oProcess,lTabComp,lTabCDT,lTabCD0,lTabCE5,lIntTMS,aWizScreen,lTabCD1)},STR0022) 	//"Processamento SPED Fiscal"
			oProcess:Activate()
		Else
			Processa({|lEnd|PrSped(@lEnd,@cFileDest,cPerfil,@oProcess,lTabComp,lTabCDT,lTabCD0,lTabCE5,lIntTMS,aWizScreen,lTabCD1)})
		EndIf
	EndIf
EndIf
Return
/*
Programa  ³  PrSped  ³ Autor ³Gustavo G. Rueda ³ 15.03.2011
*/
Static Function PrSped (lEnd,cFileDest,cPerfil,oProcess,lTabComp,lTabCDT,lTabCD0,lTabCE5,lIntTMS,aWizScreen,lTabCD1)
//³Variaveis de diversos controles³
Local	aAreaSM0		:=	SM0->(GetArea ())
Local	aPartDoc		:=	{}
Local	cAlsSF			:=	""
Local	cAlsSD			:=	""
Local	cAlsSA			:=	""
Local	cEntSai			:=	""
Local	aTotaliza		:=	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
Local	cEspecie		:=	""
Local	nRelacDoc		:=	0
Local	nItem			:=	0
Local	nX				:=	0
//Local	nY				:=	0
Local	nI				:=	0
Local	lCompIcm		:=	.F.
Local	lIss			:=	.F.
Local	cIndEmit		:=	""
Local	lConvC115		:=	aSPDSX6[MV_CONV115]
Local	cMVSUBTRIB		:=	""
Local   cMV_DifTr		:=	IIf(FindFunction("GETSUBTRIB"), GetSubTrib("",.T.), SuperGetMv("MV_SUBTRIB")) // Pega IE de Difal
Local	cMVEstado		:=	""
Local	cMVCFE210		:=	SpedPrSeq("MV_CFE210","1410,1411,1414,1415,1660,1661,1662,2410,2411,2414,2415,2660,2661,2662")
Local	lHistTab		:=	aSPDSX6[MV_HISTTAB]
Local	lMVCF3ENTR		:=	aSPDSX6[MV_CF3ENTR]
//Local	aAidf			:=	{}
Local 	lResF3FT		:=	aSPDSX6[MV_RESF3FT]    
Local   cCodRefLj       := aSPDSX6[MV_LJSPED] // Codigo dat Tabela CCE para Cupom Referenciado  
Local	aTpMov			:=	{'E','S'} //Tip de Mov
Local	nContMov		:=	0  //- Contador do tipo de mov
Local	aWizard			:=	{}
Local	cOpSemF			:=	""
Local	cMVCOMPFRT		:=	aSPDSX6[MV_COMPFRT] //1-Valor do frete por peso/volume, 2-Valores do SEC/CAT, 3-Valores de despacho, 4-Valores de pedagio
Local   cMvD162     :=  aSPDSX6[MV_NGD162] //Identifica os CFOP s, que nao gera registro D162.
Local	aMVCOMPFRT		:=	Iif(Len(&(cMVCOMPFRT))<>4,{},&(cMVCOMPFRT))
Local	nPosGener		:=	0
Local	aLanCDA			:=	{}
Local aInfE313			:= {}
Local	aLanCDA2		:=	{}
Local	lCstPis 		:=	.T.
Local	lCstCof 		:=	.T.
Local	lUsaSelo		:=	.F.
Local	lIpiPauta		:=	.F.
Local	aClasFis		:=	{"","","",""}
Local	aProd			:=	{"","","","","","","","","","",""}
Local	cSituaDoc		:=	""
Local	cNomeCfp		:=	"SPEDFIS" + FWGRPCOMPANY() + FWGETCODFILIAL
Local	lTop			:=	.F.  // Verifica se esta usando o Top.
Local	aArq			:=	{}
Local	aParFil			:=	{}
Local	aParFil2		:=	{}
Local	dDataDe			:=	CToD ("//")
Local	dDataAte		:=	CToD ("//")
Local	cNrLivro		:=	""
Local	cFilDe			:=	""
Local	cFilAte			:=	""
Local	cDir			:=	""
Local	lImpCrdST		:=	.F.
Local	nApurIpi		:=	0
Local	aLisFil			:=	{}
Local	nFilial			:=	0
Local	cIndex			:=	""
//Local	nIndex			:=	0
Local	cChvSeek		:=	""
Local	cFrete			:=	""
Local	dDtarec			:=	CToD("  /  /  ")
Local	cSitExt			:=	""
Local	cUnid			:=	""
Local	cProd			:=	""
Local	nValST			:=	0
Local	aCmpAntSFT		:=	{}
Local	cFormul			:=	""
Local	lSPDFIS02		:=	aExistBloc[01]
Local	lCadParti		:=	aExistBloc[02]
Local	lSpedRTms		:=	aExistBloc[03]
Local	AHistSA			:=	{}
Local	AHistSA4		:=	{}
Local	AHistSB1		:=	{}
Local	aProdB1			:=	{}
Local	aInfCompl		:=	{"",""}
Local	aSpdInfC		:=	{}
Local	aAreaSA			:=	{}
Local	cCdMunOri		:=	""
Local	aPartREM		:=	{}
Local	cCdMunDes		:=	""
Local	aPartDES		:=	{}
Local	aPartCON		:=	{}
Local	aPartDPC		:=	{}
Local	aRetPart		:=	{}
Local	aRetAux			:=	{}
Local	lGerouC170		:=	.F.
Local	aParcTit		:=	{}
Local	aF2EspVol		:=	{}
Local	nRedBSICM		:=	0
Local	lMVSFRBCD2		:=	aSPDSX6[MV_SFRBCD2]    
Local	nCtdFil			:=	0
Local	nCountTot		:=	0
Local	nRegsProc		:=	0
Local	nEmpProc		:=	0
Local	cTimeDocs		:=	Time()
Local	nDocsXTime		:=	0
//Local	cFilSoma		:=	""
Local	nCtdSFA			:=	0
Local	cAliasSFA		:=	"SF9"
Local	bWhileSM0		:=	{||!SM0->(Eof ()) .And. ((!"1"$aWizard[1][12] .And. cEmpAnt==SM0->M0_CODIGO .And. FWGETCODFILIAL<=cFilAte) .Or. ("1"$aWizard[1][12] .And. Len(aLisFil)>0 .And. cEmpAnt==SM0->M0_CODIGO))}
Local	nRecnoSF3		:=	Nil
//Local	nRecnoCD0		:=	Nil
Local	nRecnoCD1		:=	Nil
Local	nRecnoCD3		:=	Nil
Local	nRecnoCD7		:=	Nil
Local	nRecnoCD8		:=	Nil
Local	nRecnoCD9		:=	Nil
Local	nRecnoSFU		:=	Nil
Local	nRecnoSFX		:=	Nil
Local	nRecnoDT6		:=	Nil
Local	nRecnoCCE		:=	Nil
Local 	cMV_StUf		:=	aSPDSX6[MV_STUF]  // Define os estados a serem utilizados para o artigo 281
Local 	cMV_StUfS		:=	aSPDSX6[MV_STUFS] // Define os estados a serem utilizados para o artigo 281 - para as saidas
Local	lUsaSped		:=	aSPDSX6[MV_USASPED]
Local	cMVSTNIEUF		:=	aSPDSX6[MV_STNIEUF]
Local	aVlrMovST		:=	{}
Local	aResF3FT		:=	{}
Local	aIcmPago		:=	{}
Local	lSPDFIS08		:=	aExistBloc[04]
Local	dDtEntSai		:=	CToD("  /  /  ")
Local	aSpdFis02		:=	{}
Local	nQtde			:=	0
Local 	lSigaEEC		:= aSPDSX6[MV_EECFAT]   
Local lEECSPED      := aSPDSX6[MV_EECSPED] 
Local 	lSigaEIC		:= aSPDSX6[MV_EASY] == "S"
Local	cAliasExp		:=	Iif(lSigaEEC,If(lEECSPED,"EEC","CDL"),"CDL")
Local	nCtdExp			:=	0
Local	aAvImport		:=	{}
Local	aSM0			:=	FWLoadSM0()
Local	lIsBlind		:=	IsBlind()
Local	cMsgProcess		:=	""
Local 	cMVDTINCB1		:= 	IIF(AllTrim(aSPDSX6[MV_DTINCB1]) != "", AllTrim(aSPDSX6[MV_DTINCB1]),"B1_DATREF")
Local	cPRDPRIB5		:=	Alltrim(aSPDSX6[MV_PRDPRI])
Local	nRecSF3DBF		:=	Nil
Local	cAlertCfop		:=	STR0030
Local	cSolucCfop		:=	STR0031+cMVCFE210+"."
Local	lLogCfop		:=	.F.
Local	aPTransp		:=	{}
Local	lNotaC350		:=	.T.
Local	lNotaC300		:=	.T.
Local	lNotaD300		:=	.T.
//Local	lGera0450		:=	.F.
Local	lMVSpedAz 		:=	aSPDSX6[MV_SPEDAZ]
Local   lSpedNat		:=  aSPDSX6[MV_SPEDNAT]
Local	lPisZero		:=	.F.
Local	lCofZero		:=	.F.
Local	cAliasCE6		:=	"CE6"
Local	lIcmStTran		:=	.F.
Local	nFatorPE		:=	0
Local	nAbatNT			:=	0
Local   cUFRESpd		:= aSPDSX6[MV_UFRESPD] // Acrescentado UF de GO como Default para atender Chamado:TDSAFI
Local	lFirstNF		:=	.T.
Local	cAntUnid		:=	""
Local	cMVCFC195		:= aSPDSX6[MV_CFC195]
//Local	cStartPath		:=	AllTrim( GetSrvProfString( "StartPath" , "" ) )
Local	lJob			:=	.F.
//Local 	cApurSep		:=	Alltrim(aSPDSX6[MV_APUSEP])
Local	lNewCFrt		:=	.F.
//Local	nCtdRegs		:=	0
//Local	aTabela			:=	{"SFT"}
//Local	nSkip			:=	0
//Local	cChvC600		:=	""
Local	cCDTChv			:=	""
Local	cCDCChv			:=	""
Local	cDTCChv			:=	""
Local	cCodTes			:=	""
Local	cCodNat			:=	""
Local	cDescNat		:=	""
Local	aNatOper		:=	{ "" , "" }
Local	nMVSPDIFC		:=	aSPDSX6[MV_SPDIFC]
Local	cMVSPDTC95		:=	aSPDSX6[MV_SPDTC95]
Local	lOperGar		:=	.F.
Local	lLegisPer		:=	.F.
Local	lGera			:=	.F.

//³Variaveis para nomes de campos³
Local	cCmpUm			:=	""
Local	cCmpTrans		:=	""
Local	cCmpEst			:=	""
Local	cCmpTipo		:=	""
Local	cCmpTes			:=	""
Local	cCmpNFCupom		:=	""
Local	cCmpPrefixo		:=	""
Local	cCmpDupl		:=	""
//Local	cNFCupom		:=	""
Local	cCmpPBruto		:=	""
Local	cCmpPLiqui		:=	""
Local	cCmpVeic1		:=	""
Local	cCmpVeic2		:=	""
Local	cCmpVeic3		:=	""
Local	cCmpSimpN		:=	""
Local	cCmpRegPB		:=	""
Local	cCmpFrete		:=	""
Local	cCmpHawb		:=	""
Local	cCmpTPCTE		:=	""
Local	cCmpDescIcm		:=	""
Local	cCmpMenNota		:=	""
Local	cProtocolo		:=	""
//³Variaveis de FLAG de seek³
Local	lAchouCD0		:=	.F.
Local	lAchouCD1		:=	.F.
Local	lAchouCD2		:=	.F.
Local	lAchouCD3		:=	.F.
Local	lAchouCD4		:=	.F.
Local	lAchouCD5		:=	.F.
Local	lAchouCD6		:=	.F.
Local	lAchouCD7		:=	.F.
Local	lAchouCD8		:=	.F.
Local	lAchouCD9		:=	.F.
Local	lAchouCDC		:=	.F.
Local	lAchouCDD		:=	.F.
Local	lAchouCDE		:=	.F.
Local	lAchouCDF		:=	.F.
Local	lAchouCDG		:=	.F.
Local	lAchouCDT		:=	.F.
Local	lSitDocCDT		:=	.F.
Local	lAchouDA3		:=	.F.
Local	lAchouDT5		:=	.F.
Local	lAchouDT6		:=	.F.
Local	lAchouDT8		:=	.F.
Local	lAchouDTC		:=	.F.
Local	lAchouDUD		:=	.F.
Local	lAchouDUL		:=	.F.
Local	lAchouSF4		:=	.T.
Local	lAchouSFU		:=	.T.
Local	lAchouSFX		:=	.T.
Local	lAchSFSD		:=	.F.
Local	lAchouCCE		:=	.T.
Local	lAchouDTQ		:=	.F.
Local	lAchouDTR		:=	.F.
Local	lAchou2DUL		:=	.F.

//³Variaveis de alias de tabelas³
Local	cAlias			:=	""
Local	cAliasCD2		:=	"CD2"
Local	cAliasCD4		:=	"CD4"
Local	cAliasCD5		:=	"CD5"
Local	cAliasCD6		:=	"CD6"
Local	cAliasCDC		:=	"CDC"
Local	cAliasCDD		:=	"CDD"
Local	cAliasCDE		:=	"CDE"
Local	cAliasCDF		:=	"CDF"
Local	cAliasCDG		:=	"CDG"
Local	cAliasCDT		:=	"CDT"
Local	cAliasDT5		:=	"DT5"
Local	cAliasDT8		:=	"DT8"
Local	cAliasDTC		:=	"DTC"
Local	cAliasDUD		:=	"DUD"
Local	cAliasDUL		:=	"DUL"
Local	cAliasSB1		:=	"SB1"
Local	cAliasSB5		:=	"SB5"
Local	cAliasSF4		:=	"SF4"
Local	cAliasSFT		:=	"SFT"
Local	cAliasSA4		:=	"SA4"
Local	cAliasSF6		:=	"SF6"
Local	cAliasDTQ		:=	"DTQ"
Local	cALiasDTR		:=	"DTR"
Local	cAliasSD1		:= 	"SD1"
//³Variaveis de relacionamento de registros atraves de posicao³
Local	nPosC110		:= 0
Local	nPosC300		:= 0
Local	nPosC600		:= 0
Local	nPosC700		:= 0
Local	nPosD300		:= 0
Local	nPosD600		:= 0
//³Variaveis de FLAG para gravacao de registrso³
Local	lGrava0150		:= .F.
Local	lGrava0200		:= .F.
Local	lGrava1500		:= .F.
Local	lGravaC500		:= .F.
Local	lGravaC700		:= .F.
Local	lGravaD500		:= .F.
Local	lGravaG126		:= .F.
//³Variaveis de registros³
Local	aReg0150		:=	{}
Local	aReg0190		:=	{}
Local	aReg0200		:=	{}
Local	aReg0220		:=	{}
Local	aReg0400		:=	{}
Local	aReg0450		:=	{}
Local	aReg0460		:=	{}
Local	aRegC100		:=	{}
Local	aRegC110		:=	{}
Local	aRegC111		:=	{}
Local	aRegC112		:=	{}
Local	aRegC113		:=	{}
Local	aRegC114		:=	{}
Local	aRegC115		:=	{}
Local	aRegC116		:=  {}
Local	aRegC130		:=	{"C130", 0, 0, 0, 0, 0, 0, 0}
Local	aRegC165		:=	{}
Local	aRegC170		:=	{}
Local	aRegC190		:=	{}
Local	aLancFis		:=	{}
Local	aRegC300		:=	{}
Local	aRegC310		:=	{}
Local	aRegC320		:=	{}
Local	aRegC321		:=	{}
Local	aRegC390		:=	{}
Local	aRegC400		:=	{}
Local	aRegC405		:=	{}
Local	aRegC410		:=	{}
Local	aRegC420		:=	{}
Local	aRegC425		:=	{}
Local	aRegC460		:=	{}
Local	aRegC470		:=	{}
Local	aRegC490		:=	{}
Local	aRegC495		:=	{}
Local	aRegC500		:=	{}
Local	aRegC510		:=	{}
Local	aRegC590		:=	{}
Local	aRegC600		:=	{}
Local	aRegC601		:=	{}
Local	aRegC610		:=	{}
Local	aRegC690		:=	{}
Local	aRegC700		:=	{}
Local	aRegC790		:=	{}
Local	aRegC791		:=	{}
Local	aRegC800		:=	{}
Local	aRegC850		:=	{}
Local	aRegC860		:=	{}
Local	aRegC890		:=	{}
Local	aRegD190		:=	{}
Local	aRegD300		:=	{}
Local	aRegD301		:=	{}
Local	aRegD310		:=	{}
Local	aRegD500		:=	{}
Local	aRegD510		:=	{}
Local	aRegD590		:=	{}
Local	aRegD610		:=	{}
Local	aRegD600		:=	{}
Local	aRegD695		:=	{}
Local	aRegD696		:=	{}
Local	aRegD697		:=	{}
Local	aRegE510		:=	{}
Local	aReg1400		:=	{}
Local	aReg1600		:=	{} // Array para guardar os dados dos cartoes de Credito e Debito para o Bloco 1000 Registro 1600
Local	aReg1700		:=	{}
Local	aReg1710		:=	{}
Local	aRegD690		:=	{}
Local	aReg1010		:=	{}
Local	aReg1300		:=	{}
Local	aReg1310		:=	{}
Local	aReg1320		:=	{}
Local	aReg1350		:=	{}
Local	aReg1360		:=	{}
Local	aReg1370		:=	{}
Local	aLiv1900		:=	{}
Local	aReg0210		:=	{}
Local	aAreaCDE		:=	{}
Local	lCondC120		:=	.F.

Local	lPCLLOJA		:=	FindFunction("T_TpPcSped") .And. aSPDSX2[AI_LF1] .AND. aSPDSX2[AI_LEG] .AND. ;
							aSPDSX2[AI_LEJ] .AND. aSPDSX2[AI_LEI] .AND. !aExistBloc[07]
Local	lOldLan			:= aSPDSX3[FP_CC6_TIPOAJ]
Local	nQtReg0200		:= 0 //Variavel auxiliar apenas para controlar a quantidde de registros existentes no array "aReg0200"
Local	nKeyCD2			:= 1
Local	aMVRLCSPD		:= {}
Local	lGr2001400		:= .F.
Local	lRefazInd		:= .F.
Local  lDifal			:= .F.
Local  nDifalDest			:= 0
Local  nDifalOrig			:= 0
Local  nDifalFEcp			:= 0
Local  aMovSemIe			:= {}
Local  nPosSemIe			:= 0
Local  nRetCpy 	:= 0

//Novos campos ressarcimento ICMS ST - C176
Local lCmpCD0	:= 	aSPDSX3[FP_CD0_CHVNFE] .And. aSPDSX3[FP_CD0_ITENFE] .And. aSPDSX3[FP_CD0_VLUNOP] .And.;
					aSPDSX3[FP_CD0_PICMSE] .And. aSPDSX3[FP_CD0_ALQSTE] .And. aSPDSX3[FP_CD0_RESPRE] .And.;
					aSPDSX3[FP_CD0_MOTRES] .And. aSPDSX3[FP_CD0_CHNFRT] .And. aSPDSX3[FP_CD0_PANFRT] .And.;
					aSPDSX3[FP_CD0_SRNFRT] .And. aSPDSX3[FP_CD0_NRNFRT] .And. aSPDSX3[FP_CD0_ITNFRT] .And.;
					aSPDSX3[FP_CD0_CODDA]  .And. aSPDSX3[FP_CD0_NUMDA]  .And. aSPDSX3[FP_CD0_VLUNRE] .And.;
					aSPDSX3[FP_CD0_BSULMT]  .And. aSPDSX3[FP_CD0_VLUNCR]

#IFDEF TOP
//	Local	cL2Temp			:= ""	// Pega o proximo Alias Disponivel
//	Local	nCountSD2		:= 0

	If TcSrvType() <> "AS/400"
		lTop	:= .T.
	Endif
#ENDIF

DEFAULT aWizScreen	:= {} //Recebe via Job/Rpc aWizard preenchida
Private lConcFil	:= .T.
Private cLib		:= ""
Private _lValPro := Type("oProcess")=="O" //LGS#20200131 - Adequação para release 12.1.25 e posteriores
Private oTempTbl01
//³Verifica se aWizScreen preenchido, sinalizando processamento via Job/Rpc³
lJob := Iif(Len(aWizScreen) > 0, .T.,.F.)

//³Atribuo o conteudo do CFP gerado pelo wizard no array aWizard³
If !lJob
	cNomeCFP := Iif(File(cNomeCfp+".cfp"),cNomeCfp,"SPEDFIS")

	If !xMagLeWiz(cNomeCfp,@aWizard,.T.)
		Return	//Se por algum motivo a leitura do CFP falhar aborto a rotina.
	EndIf

//³Wizard preenchido antes de chamar function SpedFiscal, tratamento para RPC³
Else
	aWizard := aWizScreen
EndIf

//³Consistencias do SIGALOJA antes de iniciar o processamento do SPED Fiscal³
If ("1"$aWizard[1][9]) //Removida condição de checar a tabela SLG por estourar error.log para quem não configurou módulo de loja e entrou com a opção de emitir ECF.

	If !ChkFile("SLX")
		MsgAlert(STR0016)	//"Deve ser criado arquivo Log de Cancelamento(SLX). Verificar os procedimentos para execução do U_UPDLOJ28 conforme o Boletim Tecnico do SPED Fiscal"
		Return
	EndIf

	If !SIX->(MsSeek("SFI"+"3"))
		MsgAlert(STR0019)	//"Deve ser criado um indice no arquivo SFI. Verificar os procedimentos para execução do U_UPDLOJ28 conforme o Boletim Tecnico do SPED Fiscal"
		Return
	EndIf

EndIf
//³Quando o perfil nao for informado no parametro, pego o que foi configurado no WIZARD³
If Empty(cPerfil)
	cPerfil 	:= SubStr(aWizard[2][4],1,1)
EndIf

//³Criacao do TRB para ser alimentado durante o processamento da rotina³
SPDGerTrb(1,@aArq,@cAlias)

dDataDe		:=	SToD(aWizard[1][1])
dDataAte	:=	SToD(aWizard[1][2])
cNrLivro	:=	aWizard[1][3]
cFilDe		:=	aWizard[2][2]
cFilAte		:=	aWizard[2][3]
cDir		:=	AllTrim(aWizard[1][4])
lImpCrdST	:=	Iif("1"$aWizard[1][11],.T.,.F.)
nApurIpi	:=	Iif(!Empty(aWizard[1][13]),Val(aWizard[1][13]),0)

lDifal	:= dDataDe >= ctod('01/01/2016') .AND. '1' $ aWizard[1][18] .and. aSPDSX2[AI_F0I] .and. aSPDSX2[AI_F0J] .and. ;
		   aSPDSX2[AI_F0K] .AND.	 SFT->(ColumnPos('FT_DIFAL')) > 0 .AND. SFT->(ColumnPos('FT_VFCPDIF')) > 0

//³Tratamento para Linux onde a barra e invertida³
If GetRemoteType() == 2 // REMOTE_LINUX
	If !Empty(cDir) .And. (SubStr (cDir, Len (cDir), 1)<>"/")
		cDir	+=	"/"
	EndIf
Else
	If !Empty(cDir) .And. (SubStr (cDir, Len (cDir), 1)<>"\")
		cDir	+=	"\"
	EndIf
EndIf
cFileDest	:=	AllTrim(cDir)+AllTrim(aWizard[1][5])

//³Verifico se devo abrir a tela para fazer o proces de multifiliais³
If !lJob .And. "1"$aWizard[1][12]
	aLisFil  :=	MatFilCalc(.T.,,,IIf("1"$aWizard[2][6],.T.,.F.),,IIf("1"$aWizard[2][6],1,0))
	If !Empty(aLisFil)
		cFilDe	:=	PadR("",FWGETTAMFILIAL)
		cFilAte	:=	Repl("Z",FWGETTAMFILIAL)
	Else
		MsgAlert(OemToAnsi(STR0018))	//"Nenhuma filial foi selecionada para o proces. Será considerada a filial corrente."
		//³Para considerar a filial corrente, preciso alem de atribuir o cFilAnt, preciso forcar a ³
		//³opcao 2 neste array que eh o resultado do wizard
		aWizard[1][12]	:=	"2 - Não"
		cFilDe			:=	cFilAnt
		cFilAte			:=	cFilAnt
	EndIf
ElseIf lJob
	aWizard[1][12]	:=	"2 - Não"
	cFilDe			:=	cFilAnt
	cFilAte			:=	cFilAnt
EndIf

If (Empty (cFilDe) .And. Empty (cFilAte))
	cFilDe	:=	cFilAnt
	cFilAte	:=	cFilAnt
EndIf

Reg0000 (aWizard, cAlias, dDataDe, dDataAte)

Reg0005 (aWizard, cAlias, aSM0, lIsBlind )

Reg0100 (aWizard, cAlias, dDataDe, dDataAte)

SpedRg1010 (aWizard, cAlias, @aReg1010)

//³Monta a quantidade de filiais que estao no processamento para montar³
//³ a regua de processamento corretamente com as informacoes dos       |
//| registros mais significantes (os outros sao muito rapidos)         ³
DbSelectArea ("SM0")
SM0->(DbGoTop ())
SM0->(MsSeek (cEmpAnt+cFilDe, .T.))	//Pego a filial mais proxima 
Do While Eval(bWhileSM0)

	cFilAnt := FWGETCODFILIAL

	If Len(aLisFil)>0 .And. cFilAnt <= cFilAte
		nFilial := Ascan(aLisFil,{|x|x[2]==cFilAnt})
		If nFilial==0 .Or. !(aLisFil[nFilial,1])  //Filial não marcada, vai para proxima
			SM0->( dbSkip() )
			Loop
		EndIf
	Else
		If "1"$aWizard[1][12]  //Somente faz skip se a opção de selecionar filiais estiver como Sim.
			SM0->(dbSkip())
			Loop
		EndIf
	EndIf

	aSPDSX6 := SpedLoadX6()
	//³Armazeno o numero preciso de registros que serao processados³	
	nCountTot	+=	SPEDQryPri(1,"E",dDataDe,dDataAte,lCstPis,lCstCof,@aF2EspVol,lTabComp,lIntTMS,cNrLivro,@cAliasSFT,lTabCD1)
	nCountTot	+=	SPEDQryPri(1,"S",dDataDe,dDataAte,lCstPis,lCstCof,@aF2EspVol,lTabComp,lIntTMS,cNrLivro,@cAliasSFT,lTabCD1)
	
	//³Contagem dos registros de CIAP que serao processados pelo Bloco G³
	SPEDFFiltro(1,"SF92",@cAliasSFA,{DToS(dDataDe),DToS(dDataAte)},@nCtdSFA)
	nCountTot	+=	nCtdSFA

	//³Contagem dos registros de EXPORTACAO que serao processados pelo Bloco 1³
	If lSigaEEC
		If lEECSPED
			SPEDFFiltro(1,"EEC",@cAliasExp,{DToS(dDataDe),DToS(dDataAte)},@nCtdExp)
			nCountTot	+=	nCtdExp
		Else
			SPEDFFiltro(1,"CDL",@cAliasExp,{DToS(dDataDe),DToS(dDataAte)},@nCtdExp)
			nCountTot	+=	nCtdExp
		EndIf
	ElseIf lTabComp
		SPEDFFiltro(1,"CDL",@cAliasExp,{DToS(dDataDe),DToS(dDataAte)},@nCtdExp)
		nCountTot	+=	nCtdExp
	EndIf

	If lTabCE5
		SPEDFFiltro(1,"CE6",@cAliasCE6,{DToS(dDataDe),DToS(dDataAte)},@nCtdExp)
		nCountTot	+=	nCtdExp
	Endif

	nCtdFil		+=	1

	SM0->(dbSkip())
End
nCtdFil	:=	Iif(nCtdFil==0,1,nCtdFil)

//³No caso de o objeto oProcess existir, significa que a nova barra
//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,
//| portanto deve ser efetuado os controles para demonstrar o
//| resultado do processamento.

//³Definicao dos tamanhos da regua para o processamento
If Type("oProcess")=="O"
	oProcess:Set1Progress(nCtdFil)
	oProcess:Set2Progress(nCountTot)
Else
	ProcRegua(nCountTot)
EndIf

SM0->(DbGoTop ())
SM0->(MsSeek (cEmpAnt+cFilDe, .T.))	//Pego a filial mais proxima 

//³Quando a opcao de seleciona filiais estiver configurada como sim, serah
//³    considerado as filiais selecionadas no browse. Caso contrario, valera o
//³    que estiver configurado na pergunta 'Filial DE/ATE'
Do While Eval(bWhileSM0)

	cFilAnt := FWGETCODFILIAL

	If Len(aLisFil)>0 .And. cFilAnt <= cFilAte
		nFilial := Ascan(aLisFil,{|x|x[2]==cFilAnt})
		If nFilial==0 .Or. !(aLisFil[nFilial,1])  //Filial não marcada, vai para proxima
			SM0->( dbSkip() )
			Loop
		EndIf
	Else
		If "1"$aWizard[1][12]  //Somente faz skip se a opção de selecionar filiais estiver como Sim.
			SM0->(dbSkip())
			Loop
		EndIf
	EndIf

	aSPDSX6 := SpedLoadX6()
	nEmpProc	+=	1

	//³No caso de o objeto oProcess existir, significa que a nova barra
	//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,
	//| portanto deve ser efetuado os controles para demonstrar o
	//| resultado do processamento.
	//³Definicao o primeiro incremento da regua
	//LGS#20200131 - Adequação para release 12.1.25 e posteriores
	//If Type("oProcess")=="O"
	If _lValPro
		oProcess:Inc1Progress(STR0023+cEmpAnt+"/"+cFilAnt,StrZero(nEmpProc,3)+"/"+StrZero(nCtdFil,3))	//"Processando empresa :"
		oProcess:Inc2Progress(STR0024,"")	//"Processando documentos"

		//³Controle do cancelamento da rotina
		If oProcess:Cancel()
			Exit
		EndIf
	Else		
		//³Controle do cancelamento da rotina³		
		If Interrupcao(@lEnd)
			Exit
		EndIf
	EndIf

	//³              *** Processamento do SIGALOJA ***

	//³REGISTRO C400 - EQUIPAMENTO ECF
	//³REGISTRO C405 - REDUCAO Z
	//³REGISTRO C410 - PIS E COFINS TOTALIZADOS NO DIA
	//³REGISTRO C420 - TOTALIZADORES PARCIAIS DA REDUCAO Z
	//³REGISTRO C425 - RESUMO DE ITENS DO MOVIMENTO DIARIO
	//³REGISTRO C460 - DOCUMENTO FISCAL EMITIDO POR ECF
	//³REGISTRO C470 - ITENS DO DOCUMENTO FISCAL EMITIDO POR ECF
	//³REGISTRO C490 - REGISTRO ANALITICO DO MOVIMENTO DIARIO
	//³REGISTRO C495 - RESUMO MENSAL DE ITENS DO ECF POR ESTABELECIMENTO
	cMVSUBTRIB		:= SpedPrSeq("MV_SUBTRI")
	cMVEstado 		:= 	aSPDSX6[MV_ESTADO]
	lConcFil		:=  aSPDSX6[MV_COFLSPD]	

	If cMVEstado=="PE".And.cPerfil=="B"
		lLegisPer	:=.T.
	EndIf

	If ("1"$aWizard[1][9])
		If lTop //Ambiente TopConnect

			//Qdo é um job ele nao atribui o objeto, por isso deve-se vetar o acesso ao objeto senão nao executa a função por Job
			If !lJob
				oProcess:Inc1Progress(STR0023+cEmpAnt+"/"+cFilAnt,StrZero(nEmpProc,3)+"/"+StrZero(nCtdFil,3))	//"Processando empresa :"
				oProcess:Set2Progress(SLG->(RecCount()))
			EndIf

			RegEcfTOP(	@aRegC400,	@aRegC405, 	@aRegC410,	@aRegC420,;	
						@aRegC425,	@aRegC460,	@aRegC470,	@aRegC490,;
						@aRegC495, 	@aProdB1,	dDataDe,	dDataAte,;
						cPerfil,	cAlias, 	@aReg0200,	@aReg0190,;
						lCstPis,	lCstCof,	@aReg0220,  @aReg1600,;
						@aReg0150,  aWizard,	lTop, 		cMVEstado,;
						@nQtReg0200 ,  lJob,	lLegisPer,  cNrLivro ,;
						aArq       , @lRefazInd )
		Else
			RegEcf(	@aRegC400,	@aRegC405, 	@aRegC410,	@aRegC420,;	
					@aRegC425,	@aRegC460,	@aRegC470,	@aRegC490,;
					@aRegC495, 	@aProdB1,	dDataDe,	dDataAte,;
					cPerfil,	cAlias, 	@aReg0200,	@aReg0190,;
					lCstPis,	lCstCof,	@aReg0220,  @aReg1600,;
					@aReg0150,  aWizard,	lTop, 		cMVEstado,;
					lLegisPer,cNrLivro )
		EndIf
	EndIf
	//³FOR criado para inserir o campo FT_TIPOMOV na query para usar o indice 1 da tabela SFT
	For nContMov := 1 to Len(aTpMov)

		//³Chamando funcao que monta a query principal de processamento do SPED Fiscal		
		SPEDQryPri(2,aTpMov[nContMov],dDataDe,dDataAte,lCstPis,lCstCof,@aF2EspVol,lTabComp,lIntTMS,cNrLivro,@cAliasSFT,lTabCD1)

		//³Para ambiente TOP, as tabelas abaixos estao no JOIN e o alias eh o mesmo da query³
		If lTop
			cAliasSF4		:=	cAliasSFT
			cAliasSB1		:=	cAliasSFT
			cAliasSA4		:=	cAliasSFT
			cAliasSB5		:=	cAliasSFT
			cAliasSD1		:= cAliasSFT
		EndIf

		Do While !(cAliasSFT)->(Eof ())
			//³No caso de o objeto oProcess existir, significa que a nova barra
			//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,
			//| portanto deve ser efetuado os controles para demonstrar o
			//| resultado do processamento.

			//³Tratamento para cancelamento de processamento
	        //LGS#20200131 - Adequação para release 12.1.25 e posteriores
            //If Type("oProcess")=="O"
            If _lValPro
				//³Controle do cancelamento da rotina³				
				If oProcess:Cancel()
					Exit
				EndIf
			Else
				//³Controle do cancelamento da rotina³
				If Interrupcao(@lEnd)
					Exit
				EndIf
			EndIf

			//Inicializacao de variaveis utilizadas no processamento
			cEspecie		:=	AModNot((cAliasSFT)->FT_ESPECIE)		//Modelo NF

			//FT_PDV somente estarah alimentado quando se referir a nota fiscais de saida geradas pelo SIGALOJA.
			If !Empty((cAliasSFT)->FT_PDV) .AND. AllTrim((cAliasSFT)->FT_ESPECIE)$"CF"
				cEspecie	:=	"2D"
			EndIf

			//Determina o Alias para as Tabelas SF1/SF2 e SD1/SD2.
			cEntSai			:=	Iif ("E"$(cAliasSFT)->FT_TIPOMOV, "1", "2")
			cAlsSF			:=	"SF"+cEntSai	//Determina o Alias para as Tabelas SF1/SF2
			cAlsSD			:=	"SD"+cEntSai	//Determina o Alias para as Tabelas SD1/SD2

			cAlsSA			:=	"SA"+Iif ((cEntSai=="1" .And. !(cAliasSFT)->FT_TIPO$"BD") .or.;
										  (cEntSai=="2" .And. (cAliasSFT)->FT_TIPO$"BD"), "2", "1")	//Determina o Alias para as Tabelas SA1/SA2

			//Trata Devolução de Serviço
			if cEntSai == "1" .And. ;
			   cAlsSA=="SA2" .And. ;
			   cAlsSD="SD1" .And. ;
			   (cAlsSD)->D1_TIPO = "D" .And. ;
			   (cAliasSFT)->FT_TIPO=="S"
			   
			   // Garante que trata-se de um item da mesma nota. 
				If (cAliasSFT)->(FT_FILIAL+FT_NFISCAL+FT_SERIE) == (cAlsSD)->(D1_FILIAL+D1_DOC+D1_SERIE) 
			   		cAlsSA:="SA1"
				EndIf		  

			Endif

							//   1  2  3  4  5   6  7  8  9  10 11 12 13 14 15 16  17 18 19 20 21 22 23 24 25 26
			aTotaliza		:=	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
			//
			nRelacDoc++		//Utilizado para relacionar os doc fiscais aos seus elementos inferiores/dependentes
			nItem			:=	1
			aLanCDA			:=	{}
			lCompIcm		:=	.F.
			cOpSemF			:=	SpedPrSeq("MV_OPSEMF")
			cFrete			:=	""
			dDtarec			:=	CToD("  /  /  ")
			cSitExt			:=	""
			cIndEmit		:=	""
			aParFil			:=	{}
			aParFil2		:=	{}
			AHistSA			:=	{}
			AHistSA4		:=	{}
			AHistSB1		:=	{}
			aInfCompl		:=	{"",""}
			aAreaSA			:=	{}
			cCdMunOri		:=	""
			aPartREM		:=	{}
			cCdMunDes		:=	""
			aPartDES		:=	{}
			aPartCON		:=	{}
			aPartDPC		:=	{}
			lGerouC170		:=	.F.
			aParcTit		:=	{}
			cFormul			:=	Iif(Empty((cAliasSFT)->FT_FORMUL),Iif((cAliasSFT)->FT_TIPOMOV == "S","S"," "),(cAliasSFT)->FT_FORMUL)
			nPosGener		:=	0
			nPosC600		:=	0
			nPosC700		:=	0
			nPosD600		:=	0
			nRecnoSF3		:=	Iif(lTop,(cAliasSFT)->SF3RECNO,Nil)
			nRecnoDT6		:=	Iif(lTop .And. lIntTMS,(cAliasSFT)->DT6RECNO,Nil)
			aResF3FT		:=	{}
			aAvImport		:=	{}
			aPTransp		:=	{}
			lPisZero		:=	.F.
			lCofZero		:=	.F.
			lFirstNF		:=	.T.
			//Variaveis de registros
			aRegC500		:=	{}
			aRegC510		:=	{}
			aRegC100		:=	{}
			aRegC190		:=	{}
			aLancFis		:=	{}
			aRegC390		:=	{}
			aRegC590		:=	{}
			aRegD190		:=	{}
			aRegD590		:=	{}
			aRegC110		:=	{}
			aRegC111		:=	{}
			aRegC112		:=	{}
			aRegC113		:=	{}
			aRegC114		:=	{}
			aRegC116		:=	{}
			aRegC115		:=	{}
			aRegD500		:=	{}
			aRegD510		:=	{}
			aRegC130		:=	{"C130", 0, 0, 0, 0, 0, 0, 0}
			//Variaveis de seek
			lAchouSFU		:=	.F.
			lAchouSFX		:=	.F.
			lAchouCD0		:=	.F.
			lAchouCD2		:=	.F.
			lAchouCDG		:=	.F.
			lAchouCDT		:=	.F.
			lAchouCDC		:=	.F.
			lAchouCDD		:=	.F.
			lAchouCDE		:=	.F.
			lAchouCDF		:=	.F.
			lAchouCD3		:=	.F.
			lAchouCD4		:=	.F.
			lAchouCD5		:=	.F.
			lAchouCD6		:=	.F.
			lAchouDA3		:=	.F.
			lAchouSF4		:=	.F.
			lAchouDT5		:=	.F.
			lAchouDT6		:=	.F.
			lAchouDT8		:=	.F.
			lAchouDTC		:=	.F.
			lAchouDUD		:=	.F.
			lAchouDUL		:=	.F.
			lAchSFSD		:=	.F.
			lAchouCCE		:=	.F.
			lAchou2DUL		:=	.F.
			lAchouDTQ		:=	.F.
			lAchouDTR		:=	.F.

			//³Flag de gravacoes³

			lGravaC500		:=	.F.
			lGravaC700		:=	.F.
			lGrava1500		:=	.F.
			lGravaD500		:=	.F.
			lGrava0150		:=	.F.
			lGravaG126		:=	.F.
			nDifalDest			:= 0
			nDifalOrig			:= 0
			nDifalFEcp			:= 0                           

			//³Campos das tabelas SF/SD³

			cCmpEst			:=	SubStr(cAlsSA,2,2)+"_EST"
			cCmpUm			:=	SubStr(cAlsSD,2,2)+"_UM"
			cCmpTipo		:=	SubStr(cAlsSD,2,2)+"_TIPO"
			cCmpTes			:=	SubStr(cAlsSD,2,2)+"_TES"
			cCmpDescIcm		:=	SubStr(cAlsSD,2,2)+"_DESCICM"
			cCmpPrefixo		:=	SubStr(cAlsSF,2,2)+"_PREFIXO"
			cCmpDupl		:=	SubStr(cAlsSF,2,2)+"_DUPL"
			cCmpMenNota		:=	SubStr(cAlsSF,2,2)+"_MENNOTA"
			cCmpMenNota		:=	Iif((cAlsSF)->(FieldPos(cCmpMenNota))>0, cCmpMenNota, "")
			cCmpTrans		:=	Iif(cEntSai=="2",SubStr(cAlsSF,2,2)+"_TRANSP","")
			cCmpNFCupom		:=	Iif(cEntSai=="2",SubStr(cAlsSF,2,2)+"_NFCUPOM","")
			cCmpPBruto		:=	Iif(cEntSai=="2",SubStr(cAlsSF,2,2)+"_PBRUTO","")
			cCmpPLiqui		:=	Iif(cEntSai=="2",SubStr(cAlsSF,2,2)+"_PLIQUI","")
			cCmpVeic1		:=	Iif(cEntSai=="2",SubStr(cAlsSF,2,2)+"_VEICUL1","")
			cCmpVeic2		:=	Iif(cEntSai=="2",SubStr(cAlsSF,2,2)+"_VEICUL2","")
			cCmpVeic3		:=	Iif(cEntSai=="2",SubStr(cAlsSF,2,2)+"_VEICUL3","")
			cCmpSimpN		:=	SubStr(cAlsSA,2,2)+"_SIMPNAC"
			cCmpSimpN		:=	cCmpSimpN
			cCmpRegPB		:=	SubStr(cAlsSA,2,2)+"_REGPB"
			cCmpRegPB		:=	Iif((cAlsSA)->(FieldPos(cCmpRegPB))>0, cCmpRegPB, "")
			cCmpFrete		:=	SubStr(cAlsSF, 2, 2)+"_FRETE"
			cCmpHawb		:=	"F1_HAWB"
			cCmpTPCTE		:=	"F1_TPCTE"
			cCmpTPCTE		:=	Iif((cAlsSF)->(FieldPos(cCmpTPCTE))>0,cCmpTPCTE,"")
			//³Variaveis de Alias de tabelas³
			cAliasCDT		:=	"CDT"
			cAliasDT5		:=	"DT5"
			cAliasDT8		:=	"DT8"
			cAliasDTC		:=	"DTC"
			cAliasDUD		:=	"DUD"
			cAliasDUL		:=	"DUL"
			cAliasCDC		:=	"CDC"
			cAliasCDD		:=	"CDD"
			cAliasCDE		:=	"CDE"
			cAliasCDF		:=	"CDF"
			cAliasCDG		:=	"CDG"
			cAliasCD5		:=	"CD5"
			cAliasCD2		:=	"CD2"
			cAliasCD4		:=	"CD4"
			cAliasCD6		:=	"CD6"

			//Efetuo o pocisionamento da tabela SF3 para utilizar a tabela na funcao SPEDSitDoc 
			cChvSeek		:=	xFilial("SF3")+(cAliasSFT)->(DToS (FT_ENTRADA)+FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_CFOP+STR(FT_ALIQICM,5,2))
			SPEDSeek("SF3",,cChvSeek,nRecnoSF3)

			If lTop
				//Se for ambiente top irei utilizar campo da própria query
				cProtocolo	:= (cAliasSFT)->F3_PROTOC
			Else
				//Se for ambiente DBF terei que utilizar campo da SF3 que foi posicionada com SPEDSeek logo acima
				cProtocolo	:= SF3->F3_PROTOC
			EndIF

			//Efetuo o pocisionamento da tabela SA(1/2) para utilizar a tabela na funcao SPEDSitDoc
			If !lTop
				SPEDSeek(cAlsSA,,xFilial(cAlsSA)+(cAliasSFT)->(FT_CLIEFOR+FT_LOJA))
			EndIf

			//Tratamento para o campo FRETE
			//| 1 - Verifica existencia do campo CDT_INDFRT no complemento da Nota Fiscal
			//| 	Se existir e estiver preenchido, utiliza o que foi selecionado
			//| 2 - Senao, verifica parametro MV_OPSEMF
			//|		Se o parametro estiver configurado, utilizar "Sem Frete"
			//|		Senao, faz a verificacao 'padrao'
			//| 3 - Verificacao padrao: se for CIF ou FOB, entao e' Emitente

			//³				Tratamento para Situação extemporânea de documentos	        	|

			//| 1 - Verifica existencia dos campo na variavel lSitDocExt                	|
			//| 2 - Atraves da função SPEDSitDoc encontra a situação de extemporaneidade    |

			aParFil	:=	{}
			aAdd(aParFil,(cAliasSFT)->FT_TIPOMOV)
			aAdd(aParFil,(cAliasSFT)->FT_NFISCAL)
			aAdd(aParFil,(cAliasSFT)->FT_SERIE)
			aAdd(aParFil,(cAliasSFT)->FT_CLIEFOR)
			aAdd(aParFil,(cAliasSFT)->FT_LOJA)

			If lTabCDT
				//³Funcao que efetua um SELECT ou INDREGUA na tabela CDT conforme param passados   ³
				//³Se existir mais de um CDT para a mesma NF, utilizo somente o primeiro, pois con-³
				//³ forme manual, soh pode existir um por documento                                ³

				cCDTChv := xFilial("CDT")+aParFil[1]+aParFil[2]+aParFil[3]+aParFil[4]+aParFil[5] 
				lAchouCDT := SPEDSeek(cAliasCDT,1,cCDTChv)

				lSitDocCDT	:= lAchouCDT

				If lAchouCDT
					dDtarec := (cAliasCDT)->CDT_DTAREC
					cSitExt := (cAliasCDT)->CDT_SITEXT
					cFrete := (cAliasCDT)->CDT_INDFRT

					//³Como o registro da CDT pode ter  as configuracoes basicas, sem relacionar      ³
					//³  o codigo das informacoes complementares, utilizo o campo acima para definir o³
					//³  frete e depois valido novamente para saber se posso utilizar nos tratamentos ³
					//³  seguintes.
					lAchouCDT	:= !Empty((cAliasCDT)->CDT_IFCOMP)

				EndIf
			EndIf

			cSituaDoc  := SPEDSitDoc(,cAliasSFT,Iif(lTop,cAliasSFT,cAlsSA),cCmpSimpN,,,(cMVEstado$cUFRESpd),lSitDocCDT,cSitExt)
			cSitDocInf := SPEDSitInf(cAliasSFT,)
		
			If !(cEspecie$"01#1B#02#2D#04#06#07#08#09#10#11#13#14#15#16#21#22#26#27#28#29#55#57#59#65") // SPED = 55
				(cAliasSFT)->(DbSkip ())
				Loop
			EndIf

			//³As informacoes CTR e NFST necessarias para o SPED somente estao disponiveis               |
			//³ quando o TMS estiver envolvido (SAIDAS) ou ENTRADAS quando envolver aviso de recebimento.³
			If ((cEspecie$"07#08") .And. (!lIntTMS .And. !lSpedRTms .And. "S"$(cAliasSFT)->FT_TIPOMOV))
				(cAliasSFT)->(DbSkip ())
				Loop
			EndIf

			//³Para as notas fiscais de transportes vindas do TMS sempre deverah      ³
			//³   haver um DT6 correspondente, caso nao haja, saltar para a proxima   |
			//|   nota. Instrucoes passadas pela equipe do TMS.                       ³
			If cEspecie$"#07#08#09#10#11#26#27#57" .And. "S"$(cAliasSFT)->FT_TIPOMOV .And. lIntTMS
				cChvSeek := xFilial("DT6")+(cAliasSFT)->(FT_FILIAL+FT_NFISCAL+FT_SERIE)
				If !(lAchouDT6 := SPEDSeek("DT6",,cChvSeek,nRecnoDT6)) .And. !cSituaDoc$"02/04/05/03" //Cancelado
					(cAliasSFT)->(DbSkip ())
					Loop
				EndIf
			EndIf

			//Inicio do processamento da rotina apos execucao dos filtros anteriores

			//³Quando for TOP, os referidos campos já estao no SELECT³
			If lTop
				lAchSFSD	:=	!cSituaDoc$"02/04/05/03"

				If lAchSFSD
					lCompIcm	:=	(cAliasSFT)->(&(cCmpTipo))	//D1/D2_TIPO
					//³Nesta execucao do FOR, altero o conteudo do array de onte estah o nome dos campos para seus conteudos.³
					//³Este array tem a mesma finalidade do aCmpAntSFT. Como nao posso utiliza-lo, tive de criar outro, pois ³
					//³ os campos sao variaveis e depende da base.                                                           ³
					For nX := 1 To Len(aF2EspVol)
						aF2EspVol[nX,2]	:=	(cAliasSFT)->(&(aF2EspVol[nX,1]))
						aF2EspVol[nX,4]	:=	(cAliasSFT)->(&(aF2EspVol[nX,3]))
					Next nX
				EndIf
			Else
				SPEDSeek(cAlsSA,,xFilial(cAlsSA)+(cAliasSFT)->(FT_CLIEFOR+FT_LOJA))

				lAchSFSD	:=	SPEDSeek(cAlsSF,,xFilial(cAlsSF)+(cAliasSFT)->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA))

				If lAchSFSD
					lCompIcm	:=	(&(cAlsSF+"->"+SubStr (cAlsSF,2,2)+"_TIPO")=="I") // Indica se NF de complemento de ICMS
					//³Nesta execucao do FOR, altero o conteudo do array de onte estah o nome dos campos para seus conteudos.³
					//³Este array tem a mesma finalidade do aCmpAntSFT. Como nao posso utiliza-lo, tive de criar outro, pois ³
					//³ os campos sao variaveis e depende da base.                                                           ³
					For nX := 1 To Len(aF2EspVol)
						aF2EspVol[nX,2]	:=	(cAlsSF)->(&(aF2EspVol[nX,1]))
						aF2EspVol[nX,4]	:=	(cAlsSF)->(&(aF2EspVol[nX,3]))
					Next nX
				EndIf
			EndIf

			//³Obtendo o historico de alteracoes cadastrais³
			If lHistTab
				//SA1/SA2
				AHistSA	:=	MsConHist(cAlsSA,(cAliasSFT)->FT_CLIEFOR,(cAliasSFT)->FT_LOJA,dDataDe)

				//SA4
				If cEntSai=="2" .And. lAchSFSD
					If lTop .And. !Empty(&(cAliasSFT+"->"+cCmpTrans))
						AHistSA4	:=	MsConHist("SA4",,,dDataDe,,,&(cAliasSFT+"->"+cCmpTrans))
						aPTransp	:=	InfPartDoc("SA4",dDataDe,dDataAte,cAliasSFT,,AHistSA4)
					ElseIf !lTop .And. !Empty(&(cAlsSF+"->"+cCmpTrans)) .And. SPEDSeek(cAliasSA4,,xFilial(cAliasSA4)+&(cAlsSF+"->"+cCmpTrans))
						AHistSA4	:=	MsConHist("SA4",,,dDataDe,,,&(cAlsSF+"->"+cCmpTrans))
						aPTransp	:=	InfPartDoc("SA4",dDataDe,dDataAte,cAliasSFT,,AHistSA4)
					EndIf
				EndIf
			ElseIf cEntSai=="2" .And. lAchSFSD .And. !lTop .And. !Empty(&(cAlsSF+"->"+cCmpTrans))
				SPEDSeek(cAliasSA4,,xFilial(cAliasSA4)+&(cAlsSF+"->"+cCmpTrans))
				aPTransp	:=	InfPartDoc("SA4",dDataDe,dDataAte,cAliasSFT,,AHistSA4)
			EndIf

			//|                       SAIDA                         |
			//|Quanto for NF de Saida e houver integracao com o TMS |
			//|  utilizo a regra do modulo TMS para obter alguns    |
			//|  dados do transporte                                |
			If lAchouDT6
				aParFil2	:=	{}
				If DT6->DT6_DOCTMS<>StrZero(8,Len(DT6->DT6_DOCTMS))
					aAdd(aParFil2,DT6->DT6_FILDOC)
					aAdd(aParFil2,DT6->DT6_DOC)
					aAdd(aParFil2,DT6->DT6_SERIE)
					aAdd(aParFil2,DT6->DT6_FILORI)
				Else
					aAdd(aParFil2,DT6->DT6_FILDCO)
					aAdd(aParFil2,DT6->DT6_DOCDCO)
					aAdd(aParFil2,DT6->DT6_SERDCO)
					aAdd(aParFil2,DT6->DT6_FILORI)
				EndIf

				cChvSeekv := xFilial(cAliasDUD)+aParFil2[1]+aParFil2[2]+aParFil2[3]+aParFil2[4]
				lAchouDUD := SpedSeek(cAliasDUD,1,cChvSeek)

				cChvSeekv := xFilial(cAliasDT5) + aParFil2[1] + aParFil2[2]+ aParFil2[3]
				If (lAchouDT5 := SPEDSeek(cAliasDT5,3, cChvSeekv))
					lAchou2DUL := SPEDSeek(cAliasDUL,3,xFilial(cAliasDUL)+(cAliasDT5)->(DT5_CODSOL+DT5_SEQEND) )
				EndIf

				cChvSeekv	:=  xFilial(cAliasDT8)+aParFil2[1]+aParFil2[2]+ aParFil2[3]
				lAchouDT8	:=  SPEDSeek(cAliasDT8,2,cChvSeekv)

				cDTCChv		:= xFilial(cAliasDTC)+aParFil2[1]+aParFil2[2]+ aParFil2[3]
				lAchouDTC	:= SPEDSeek(cAliasDTC,3,cDTCChv)

				If lAchouDTC
					aParFil2	:=	{}
					aAdd(aParFil2,DT6->DT6_CLIDES)
					aAdd(aParFil2,DT6->DT6_LOJDES)
					aAdd(aParFil2,(cAliasDTC)->DTC_SQEDES)
					lAchouDUL := SPEDSeek(cAliasDUL,2,xFilial(cAliasDUL)+aParFil2[1]+aParFil2[2]+aParFil2[3]) 
				EndIf

				//³Se lAchouDUD estiver como .F., eh porque o select nao retornou registro nenhum,e nao adianta dar seek.³
				If lAchouDUD
					//³Posicionando tabelas do TMS. O modulo SIGATMS NAO possui base DBF/ADS, somente TOP³

					If (lAchouDTQ:=SpedSeek(cAliasDTQ,2, ( xFilial(cAliasDTQ)+(cAliasDUD)->(DUD_FILORI+DUD_VIAGEM) ) ))  ;
						.AND. (lAchouDTR:=SpedSeek(cAliasDTR,1, ( xFilial(cAliasDTR)+(cAliasDTQ)->(DTQ_FILORI+DTQ_VIAGEM)  ) )) 
						If !(lAchouDA3 := SPEDSeek("DA3",1, (xFilial("DA3")+(cAliasDTR)->DTR_CODVEI))) // Se nao encontrar com DTR_CODVEI
							lAchouDA3 := SPEDSeek("DA3",1, (xFilial("DA3")+(cAliasDTR)->DTR_CODRB1)) // Procura por DTR_CODRB1  
						EndIf
					EndIf
				EndIf

			//|                     ENTRADA                         |
			//³                                                     ³
			//³Utilizo o aviso de recebimento do compras para obter ³
			//|   alguns dados do transporte na entrada             |
			ElseIf cEntSai=="1"
				cChvSeek	:=	xFilial("DB2")+(cAliasSFT)->(FT_NFISCAL+FT_SERIE)
				If SPEDSeek("DB2",,cChvSeek)
					cChvSeek	:=	xFilial("DB1")+DB2->DB2_NRAVRC
					If SPEDSeek("DB1",,cChvSeek)
						cChvSeek	:=	xFilial("DB3")+DB2->DB2_NRAVRC+DB2->DB2_ITEM
						If SPEDSeek("DB3",,cChvSeek)
							cChvSeek	:=	xFilial("DA3")+DB1->DB1_IDVEI
							lAchouDA3	:=	SPEDSeek("DA3",,cChvSeek)
						EndIf
					EndIf
				EndIf
			EndIf

			//³lNewCFrt - Verifica se deve adotar a nova regra do codigo Indicador tipo frete³
			//³Conforme publicado no guia pratico Versão 2.0.7                               ³
			lNewCFrt := ((cAliasSFT)->FT_EMISSAO >= CtoD("01/01/2012"))  

			//³Tratamento para obter o tipo de frete quando houver integracao com o TMS³

			If cEspecie$"#07#08#09#10#11#26#27#57" .And. "S"$(cAliasSFT)->FT_TIPOMOV .And. lIntTMS .And. lAchouDT6
				If !Empty(cOpSemF) .And. AllTrim((cAliasSFT)->FT_CFOP)$cOpSemF
					cFrete	:= "9"
				ElseIf (DT6->DT6_DEVFRE$"1")
					cFrete	:=	Iif(lNewCFrt,"0","1") 			//Por conta do emitente = CIF = 1
				ElseIf (DT6->DT6_DEVFRE$"2")
					cFrete	:=	Iif(lNewCFrt,"1","2") 			//Por conta do destinatario = FOB = 2
				Else
					cFrete	:=	Iif(lNewCFrt,"2","0") 			//Apesar do sistema gravar 2=FOB, o devedor do frete pode ser o consignatario, espachante ou outros.
				EndIf
			//Tratamento para obter o tipo de frete quando for simples faturamento/compras atraves do pedido
			Else
				If Empty(cFrete)
					If !Empty(cOpSemF) .And. AllTrim((cAliasSFT)->FT_CFOP)$cOpSemF
						cFrete	:= "9"
					Else
						//Utilizo a informacao configurada nos pedidos de venda/campra
						cFrete	:=  SPEDSitFrt(cAliasSFT,cAlsSD,lTop,cAlsSF,cCmpFrete,lAchSFSD)
					EndIf
				EndIf
				If lNewCFrt .AND. lAchouCDT
					//0- Por conta do emitente
					If Alltrim(cFrete)=="1"
						cFrete := "0" 
					//1- Por conta do destinatário/remetente
					ElseIf Alltrim(cFrete)=="2"
						cFrete := "1" 
					//2- Por conta de terceiros
					ElseIf Alltrim(cFrete)=="0"
						cFrete := "2"
					EndIf
				EndIf
			EndIf

			//³Tratamento para verificar o tipo de emissao do doc fiscal
			//Emissao de Terceiros
			If (Empty ((cAliasSFT)->FT_FORMUL)) .And. cEntSai=="1"
				cIndEmit := "1"
			//Emissao Propria
			ElseIf (Empty ((cAliasSFT)->FT_FORMUL)) .And. cEntSai=="2"
				cIndEmit := "0"
			Else
				//Emissao Propria
				If ("S"$(cAliasSFT)->FT_FORMUL)
					cIndEmit := "0"
				//Emissao de Terceiros
				Else
					cIndEmit := "1"
				EndIf
			EndIf

			//³Efetua o tratamento da data de entrada/saida atraves do PE SPDFIS08 se existir,³
			//³ ou atraves do parametro MV_CF3ENTR                                            ³
			If lSPDFIS08
				dDtEntSai	:=	ExecBlock("SPDFIS08", .F., .F., {cAliasSFT})
			Else
				dDtEntSai	:=	Iif((cEntSai=="2" .And. lMVCF3ENTR) .Or. cEntSai=="1", (cAliasSFT)->FT_ENTRADA, CToD("  /  /  "))
			Endif

			//³Campos que se referem ao cabecalho do documento fiscal³
			aCmpAntSFT	:=	{	(cAliasSFT)->FT_NFISCAL,;												//01 - Doc. Fiscal
								(cAliasSFT)->FT_SERIE,;													//02 - Serie NF
								(cAliasSFT)->FT_CLIEFOR,;												//03 - Cliente/Fornecedor
								(cAliasSFT)->FT_LOJA,;													//04 - Codigo Loja
								dDtEntSai,;																//05 - Data Docto.
								(cAliasSFT)->FT_EMISSAO,;	 											//06 - Data Emissao
								(cAliasSFT)->FT_DTCANC,;	   											//07 - Data Canc.
								(cAliasSFT)->FT_FORMUL,;												//08 - Formulario Proprio
								(cAliasSFT)->FT_CFOP,;													//09 - CFOP
								"",;																	//10 - 
								(cAliasSFT)->FT_ALIQICM,;												//11 - Aliq. ICMS
								(cAliasSFT)->FT_PDV,;													//12 - Nro. PDV
								(cAliasSFT)->FT_BASEICM,;												//13 - Base  ICMS
								(cAliasSFT)->FT_ALIQICM,;												//14 - Aliq. ICMS
								(cAliasSFT)->FT_VALICM,;												//15 - Valor ICMS
								(cAliasSFT)->FT_ISENICM,;												//16 - Valor Isento ICMS
								(cAliasSFT)->FT_OUTRICM,;												//17 - Outros ICMS
								(cAliasSFT)->FT_ICMSRET,;												//18 - ICMS Retido ST
								(cAliasSFT)->FT_CONTA,;													//19 - Conta Contabil
								(cAliasSFT)->FT_TIPO,;													//20 - Tipo Lancamento
								cFrete,;																//21 - Tipo Frete
								(cAliasSFT)->FT_FILIAL,;												//22 - Filial
								(cAliasSFT)->FT_ESTADO,;												//23 - Estado
								(cAliasSFT)->FT_OBSERV,;												//24 - Observacao
								(cAliasSFT)->FT_CHVNFE,;												//25 - Chave NFE
								cIndEmit,;																//26 - Tipo Emissao
								Iif(lAchSFSD,(Iif(lTop,cAliasSFT,cAlsSF))->(&(cCmpPrefixo)),""),;		//27 - Prefixo
								Iif(lAchSFSD,(Iif(lTop,cAliasSFT,cAlsSF))->(&(cCmpDupl)),""),;		//28 - Duplicata
								Iif(lAchSFSD,(Iif(lTop,cAliasSFT,cAlsSF))->(&(cCmpNFCupom)),""),;		//29 - Cupom Fiscal
								Iif(lAchSFSD,(Iif(lTop,cAliasSFT,cAlsSF))->(&(cCmpTrans)),""),;		//30 - Transportadora
								Iif(lAchSFSD,(Iif(lTop,cAliasSFT,cAlsSF))->(&(cCmpPBruto)),0),;		//31 - Peso Bruto
								Iif(lAchSFSD,(Iif(lTop,cAliasSFT,cAlsSF))->(&(cCmpPLiqui)),0),;		//32 - Peso Liquido
								Iif(lAchSFSD,(Iif(lTop,cAliasSFT,cAlsSF))->(&(cCmpVeic1)),""),;		//33 - Veiculo1
								Iif(lAchSFSD,(Iif(lTop,cAliasSFT,cAlsSF))->(&(cCmpVeic2)),""),;		//34 - Veiculo2
								Iif(lAchSFSD,(Iif(lTop,cAliasSFT,cAlsSF))->(&(cCmpVeic3)),""),;		//35 - Veiculo3
								(Iif(lTop,cAliasSFT,cAlsSA))->(&(cCmpSimpN)),;							//36 - Optante Simples Nacional
								(Iif(lTop,cAliasSFT,cAlsSA))->(&(cCmpRegPB)),;							//37 - Regime Paraiba
								(cAliasSFT)->FT_NFORI,;                                                	//38 - Nota Fiscal Original
								(cAliasSFT)->FT_SERORI,;												//39 - Serie da Nota fiscal original
								(Iif(lTop,cAliasSFT,cAlsSF))->(Iif(!Empty(cCmpTPCTE) .And. cEntSai=="1",&(cCmpTPCTE),"")),;	//40 - Flag de tipo de CTE na entrada
								dDtarec,; 																//41 - Data de Recebimento para Lançamento extemporâneo de documento fiscal.
								(cAliasSFT)->FT_ESPECIE,;                                               //42 - Especie do Docuemnto
								(cAliasSFT)->FT_TIPOMOV,;                                              //43 - Tipo Mov.
								Iif(lAchSFSD,(Iif(lTop,cAliasSFT,cAlsSF))->(&(cCmpMenNota)),""),; //44 - Mensagem da Nota Fiscal
								(cAliasSFT)->FT_PRODUTO,; //45 Produto
								(cAliasSFT)->FT_ITEM,; //46 Item
								(cAliasSFT)->FT_FORMULA}								

			//³Posicionamento das tabelas complementares conforme documento fiscal em processamento³
			If lTabComp
				//³Somente para documentos de entrada, pois se refere ao registro de importacao³
				If cEntSai=="1"
					cChvSeek := xFilial(cAliasCD5)+aParFil[2]+aParFil[3]+aParFil[4]+aParFil[5]
					lAchouCD5 := SpedSeek(cAliasCD5,1,cChvSeek)
				EndIf

				cCDCChv := xFilial(cAliasCDC)+aParFil[1]+aParFil[2]+aParFil[3]+aParFil[4]+aParFil[5]
				lAchouCDC := SpedSeek(cAliasCDC,1,cCDCChv)

				cChvSeek := xFilial(cAliasCDD)+aParFil[1]+aParFil[2]+aParFil[3]+aParFil[4]+aParFil[5]
				lAchouCDD := SpedSeek(cAliasCDD,1,cChvSeek)

				cChvSeek := xFilial(cAliasCDE)+aParFil[1]+aParFil[2]+aParFil[3]+aParFil[4]+aParFil[5]                                                         
				lAchouCDE := (SpedSeek(cAliasCDE,1,cChvSeek).AND.SpedSeek("CCE",1,xFilial("CCE")+(cAliasCDE)->CDE_IFCOMP) ) // JOIN CCE

				cChvSeek := xFilial(cAliasCDF)+aParFil[1]+aParFil[2]+aParFil[3]+aParFil[4]+aParFil[5]  
				lAchouCDF := (SpedSeek(cAliasCDF,1,cChvSeek).AND.SpedSeek("CCE",1,xFilial("CCE")+(cAliasCDF)->CDF_IFCOMP) )  // JOIN CCE

				cChvSeek := xFilial(cAliasCDG)+aParFil[1]+aParFil[2]+aParFil[3]+aParFil[4]+aParFil[5]                                                                                     
				lAchouCDG := (SpedSeek(cAliasCDG,1,cChvSeek).AND.SpedSeek("CCE",1,xFilial("CCE")+(cAliasCDG)->CDG_IFCOMP) )  // JOIN CCE    

				//³Ao adaptar o processamento das notas fiscais modelo 29 (NFFA), percebeu-se uma falha na
				//³   implantacao deste complemento.
				//³Inicialmente, ao desenvolver foram criados os campos CD4_ITEM e CD4_COD (Produto),
				//³  porem concluiu-se que este complemento eh feito por nota e nao por item, ou seja,
				//³  sempre ira possuir apenas um registro da tabela CD4 para cada nota fiscal.
				//³Por este motivo, os campos CD4_ITEM e CD4_COD foram inutilizados, mas como fazem
				//³  parte da Chave Primaria nao puderam ser deletados.

				lAchouCD4 := SpedSeek(cAliasCD4,1,xFilial(cAliasCD4)+aParFil[1]+aParFil[3]+aParFil[2]+aParFil[4]+aParFil[5]  )
			EndIf

			//³Retornando dados do participante em um array e efetuo a gravacao dos registros:³
			aPartDoc	:=	InfPartDoc(cAlsSA,dDataDe,dDataAte,cAliasSFT,lCadParti,aHistSA,lHistTab)

			//³Retorna as informacoes de importacao caso tenha integracao com o SIGAEIC³
			//|          FUNCAO DISPONIB. PELA AVEGARE - FONTE AVGERAL.PRW       |
   			If	lSigaEIC .And. cEntSai == "1"
				aAvImport:=  (cAliasSFT)->(AvGetImpSped(xFilial("SF1"),FT_NFISCAL,FT_SERIE,FT_CLIEFOR,FT_LOJA))
			Endif

			//³REGISTRO C160 - VOLUMES TRANSPORTADOS                                           ³
			//|Funca independ., gera a estrutura e efetua a gravacao no TRB documento fiscal|
			lGera := Iif( lLegisPer .And. aTpMov[nContMov]$"S",.F.,.T.)
			If lGera
				If !cSituaDoc$"02/04/05/03" .And. cEspecie$"01#04" .And. cEntSai=="2" .And. cPerfil <> "C"
					RegC160(cAlias,nRelacDoc,@aReg0150,aWizard,aCmpAntSFT,lCadParti,aHistSA4,lAchouDA3,cAliasSA4,aF2EspVol)
				EndIf
			EndIf

			//³Processando os itens do documento fiscal.³
			cChave	:=	(cAliasSFT)->(FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA)
			Do While !(cAliasSFT)->(Eof ()) .And.	cChave==(cAliasSFT)->(FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA)
				//³Inicializacao de variaveis utilizadas no proces do item³
				nRegsProc	+=	1
				lAchouSF4	:=	.F.
				cUnid		:=	""
				cAntUnid	:=	""
				cProd		:=	""
				aRegC165	:=	{}
				aRegC170	:=	{}
				lGrava0200	:=	.F.
				nValST		:=	0
				lIss		:=	(cAliasSFT)->FT_TIPO=="S"
				lUsaSelo	:=	.F.
				lIpiPauta	:=	.F.
				aProd		:=	{"","","","","","","","","","",""}
				AHistSB1	:=	{}
				nPosC300	:=	0
				nRedBSICM	:=	0
				//nRecnoCD0	:=	Iif(lTop .And. lTabCD0 ,(cAliasSFT)->CD0RECNO,Nil)
				nRecnoCD1	:=	Iif(lTop .And. lTabCD1 ,(cAliasSFT)->CD1RECNO,Nil)
				nRecnoCD3	:=	Iif(lTop .And. lTabComp,(cAliasSFT)->CD3RECNO,Nil)
				nRecnoCD7	:=	Iif(lTop .And. lTabComp,(cAliasSFT)->CD7RECNO,Nil)
				nRecnoCD8	:=	Iif(lTop .And. lTabComp,(cAliasSFT)->CD8RECNO,Nil)
				nRecnoCD9	:=	Iif(lTop .And. lTabComp,(cAliasSFT)->CD9RECNO,Nil)
				nRecnoSFU	:=	Iif(lTop .And. lTabComp,(cAliasSFT)->SFURECNO,Nil)
				nRecnoSFX	:=	Iif(lTop .And. lTabComp,(cAliasSFT)->SFXRECNO,Nil)
				nRecnoCCE	:=	Iif(lTop .And. lTabComp,(cAliasSFT)->CCERECNO,Nil)
				nRecnoSF3	:=	Iif(lTop,(cAliasSFT)->SF3RECNO,Nil)
				nQtde		:=	(cAliasSFT)->FT_QUANT
				nRecSF3DBF	:=	Nil
				nFatorPE	:=	0
				lAchouCD2	:=	.F.
				cAliasCD2	:=	"CD2"
				aParFil		:=	{}
				nAbatNT		:=	0
				lCondC120	:=	.F.
				nKeyCD2		:=	1
				lRegEspPr	:= cMVEstado=="PR" .And. cEntSai=="1" .And. cSituaDoc$"08" .And. aCmpAntSFT[8]=="S" .And. !Empty(aCmpAntSFT[47])

				//³No caso de o objeto oProcess existir, significa que a nova barra
				//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,
				//| portanto deve ser efetuado os controles para demonstrar o
				//| resultado do processamento.
				//³Definindo o segundo incremento da regua e seu controle de detalhes
      	        //LGS#20200131 - Adequação para release 12.1.25 e posteriores
                //If Type("oProcess")=="O"
                If _lValPro
					oProcess:Inc2Progress(STR0024+" ("+(cAliasSFT)->FT_TIPOMOV+") "+STR0025+" "+DToC((cAliasSFT)->FT_ENTRADA),StrZero(nRegsProc,6)+"/"+StrZero(nCountTot,6))	//"Processando documentos"###do dia

					//³Condicao implementada para controlar os numeros apresentadas na tela³
					//³  de processamento da rotina, os detalhes.                          ³
					If cTimeDocs<>Time()
						oProcess:SetDetProgress(STR0026,nCountTot,;					//"Total de registros do periodo solicitado"
								STR0027,nDocsXTime,;								//"Total de registros processados por segundo"
								STR0028,nCountTot-nRegsProc,;						//"Total de registros pendentes para processamento"
								STR0029,Round((nCountTot-nRegsProc)/nDocsXTime,0))	//"Tempo estimado para termino do processamento (Seg.)"
						cTimeDocs	:=	Time()
						nDocsXTime	:=	1
					Else
						nDocsXTime	+=	1
					EndIf

					//³Controle do cancelamento da rotina³
					If oProcess:Cancel()
						Exit
					EndIf
				Else
					aEval(aSM0,{|x| cMsgProcess := Iif(x[SM0_GRPEMP]==cEmpAnt .And. x[SM0_CODFIL]==cFilAnt .And. x[SM0_USEROK] .And. (x[SM0_EMPOK] .Or. lIsBlind),x[SM0_CODFIL]+"/"+x[SM0_FILIAL],"")})
					cMsgProcess	:=	AllTrim(cMsgProcess)

					IncProc(STR0004+cMsgProcess) //"Processando filial: "

					//³Controle do cancelamento da rotina³
					If Interrupcao(@lEnd)
						Exit
					EndIf
				EndIf

				//³Executando filtros nas tabelas complementares conforme documento fiscal³
				aParFil	:=	{}
				aAdd(aParFil,(cAliasSFT)->FT_TIPOMOV)
				aAdd(aParFil,(cAliasSFT)->FT_NFISCAL)
				aAdd(aParFil,(cAliasSFT)->FT_SERIE)
				aAdd(aParFil,(cAliasSFT)->FT_CLIEFOR)
				aAdd(aParFil,(cAliasSFT)->FT_LOJA)
				aAdd(aParFil,(cAliasSFT)->FT_ITEM)
				aAdd(aParFil,(cAliasSFT)->FT_PRODUTO)
				aAdd(aParFil,"ICM")

				cChvSeek := xFilial(cAliasCD2)+aParFil[1]+aParFil[3]+aParFil[2]+aParFil[4]+aParFil[5]+aParFil[6]+aParFil[7]+aParFil[8]

				If (cAliasSFT)->FT_TIPOMOV == "S"
					nKeyCD2 := IIf( (cAliasSFT)->FT_TIPO $"DB" , 2 , 1 )
				Else
					nKeyCD2 := IIf( (cAliasSFT)->FT_TIPO $"DB" , 1 , 2 )
				EndIf

				lAchouCD2 := SpedSeek(cAliasCD2,nKeyCD2,cChvSeek)
				//³Pode haver mais de um CD6por item, porque a chave principal da tabela eh ateh o numero de Tanque.³
				cChvSeek := xFilial(cAliasCD6)+aParFil[1]+aParFil[3]+aParFil[2]+aParFil[4]+aParFil[5]+aParFil[6]+aParFil[7]
				lAchouCD6 := SpedSeek(cAliasCD6,1,cChvSeek)

				//Efetuo o pocisionamento da tabela SF3 para utilizar a tabela na funcao SPEDSitDoc 
				cChvSeek		:=	xFilial("SF3")+(cAliasSFT)->(DToS (FT_ENTRADA)+FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_CFOP+STR(FT_ALIQICM,5,2))
				SPEDSeek("SF3",,cChvSeek,nRecnoSF3)

				//³Para Top nao preciso fazer este while, pois jah estah posicionado conforme recno correto pela query principal³
				If !lTop
					//³Tratamento para Apurar alguns valores durante o processamento da SFT, como se estivesse
					//³  executando a RESUMEF3.
					//³Como na resumeF3 tem a opcao de obter as informacoes das tabelas SF3 ou SFT, tenho tambem
					//³  que replicar isso aqui, para isso tenho que criar um controle para a tabela SF3, pois
					//|  ela pode duplicar para cada SFT, entao tenho que garantir que estou processando somente
					//|   1 vez.
					If !lResF3FT
						While SF3->(!Eof() .And. F3_FILIAL+DTOS(F3_ENTRADA)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA+F3_CFO+STR(F3_ALIQICM,5,2)==cChvSeek)
							//³Garanto a leitura do IDENT correto³
							If SF3->F3_IDENTFT==(cAliasSFT)->FT_IDENTF3
								nRecSF3DBF	:=	SF3->(Recno())
								Exit
							EndIf
							SF3->(dbSkip())
						End
					EndIf
				EndIf

				//³Posicionando tabelas de acordo com os itens dos documentos fiscais.
				If lTop
					If (lAchouSF4	:=	!Empty((cAliasSFT)->(&(cCmpTes))))
						cCodTes	:=	(cAliasSFT)->(&(cCmpTes))
					Endif
					cUnid 		:=	(cAliasSFT)->(&(cCmpUm))
				Else
					If (cAlsSD)->(MsSeek (xFilial(cAlsSD)+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA+(cAliasSFT)->FT_PRODUTO+(cAliasSFT)->FT_ITEM))
						If (lAchouSF4	:=	SPEDSeek("SF4",,xFilial ("SF4")+(cAlsSD)->(&(cCmpTes))))
							cCodTes	:= (cAlsSD)->(&(cCmpTes))
						Endif
						cUnid 		:=	(cAlsSD)->(&(cCmpUm))
					Else
						lAchouSF4	:=	.F.
					EndIf
					SPEDSeek("SB1",,xFilial("SB1")+(cAliasSFT)->FT_PRODUTO)
					SPEDSeek("SB5",,xFilial("SB5")+(cAliasSFT)->FT_PRODUTO)
				EndIf

				//Caso nao encontre a NF, utilizo do produto
				If Empty(cUnid)
					cUnid := (cAliasSB1)->B1_UM
				EndIf

				//³Posicionamento das tabelas complementares conforme documento fiscal em processamento por item³
				cChvSeek	:=	(cAliasSFT)->(FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO)
				If lTabComp
					lAchouCD3	:=	SPEDSeek("CD3",,xFilial("CD3")+cChvSeek,nRecnoCD3)
					lAchouCD7	:=	SPEDSeek("CD7",,xFilial("CD7")+cChvSeek,nRecnoCD7)
					lAchouCD8	:=	SPEDSeek("CD8",,xFilial("CD8")+cChvSeek,nRecnoCD8)
					lAchouCD9	:=	SPEDSeek("CD9",,xFilial("CD9")+cChvSeek,nRecnoCD9)
					lAchouSFU	:=	SPEDSeek("SFU",,xFilial("SFU")+cChvSeek,nRecnoSFU)
					lAchouSFX	:=	SPEDSeek("SFX",,xFilial("SFX")+cChvSeek,nRecnoSFX)
					If lAchouSF4
						lAchouCCE	:=	SPEDSeek("CCE",,xFilial("CCE")+SF4->F4_CODOBSE,nRecnoCCE)
					Endif
				EndIf

				If lTabCD0
					lAchouCD0	:=	SPEDSeek("CD0",,xFilial("CD0")+cChvSeek)
				EndIf

				//Verifica se o item possui vinculo com Cadastro de Natureza da Operacao/Prestacao
				If lTabCD1
					lAchouCD1	:=	SPEDSeek("CD1",,xFilial("CD1")+(cAliasSFT)->FT_NATOPER,nRecnoCD1)
				Endif

				//³Obtendo o historico de alteracoes cadastrais³
				//SB1
				If lHistTab
					AHistSB1	:=	MsConHist("SB1","","",dDataDe,,(cAliasSFT)->FT_PRODUTO)
				EndIf

				//³Ponto de entrada para tratamento da inform de produtos quando o mesmo estah fora do padrao do sistema³
				cProd	:=	(cAliasSFT)->FT_PRODUTO+ Iif(lConcFil,xFilial("SB1"),"")
				If aExistBloc[05]
					aProd := Execblock("SPEDPROD", .F., .F., {cAliasSFT,"1105"})
					If Len(aProd)>=11
						cProd 	:= 	aProd[1]
						cUnid	:=	aProd[5]
					Else
						aProd := {"","","","","","","","","","","",""}
					EndIf
				EndIf

				//|Este PE eh utilizado para quando se deseja alterar a UM e a |
				//| quantidade padrao calculada pelo sistema. Eh mais utilizado|
				//| quando se utiliza a quantidade na segunda unidade de medida|
				If lSPDFIS02 .And. lAchouSF4
					cAntUnid  := cUnid
					aSpdFis02 := ExecBlock("SPDFIS02", .F., .F., { Iif(!lTop,cAlsSD,cAliasSFT) , (cAliasSFT)->FT_TIPOMOV })
					If ValType(aSpdFis02)=="A"
						cUnid     := aSpdFis02[1]
						nQtde     := aSpdFis02[2]
						If Len(aSpdFis02) > 2
							nFatorPE  := aSpdFis02[3]
						EndIf
					Else
						cUnid     := ExecBlock("SPDFIS02", .F., .F., { Iif(!lTop,cAlsSD,cAliasSFT) , (cAliasSFT)->FT_TIPOMOV })
						//³Caso o retorno do PE seja Nil deve-se ignorar o PE e seguir com a geracao³
						//³dos registros utilizando a unidade de medida principal do produto (0200) ³
						If ValType(cUnid) == "U"
							cUnid := cAntUnid
						EndIf
					EndIf
				EndIf

				//³Calculo da reducao de base do ICMS para o item em processamento³
				nRedBSICM	:=	SPEDVLBSRD(lAchouCD2,cAliasCD2,lAchouSF4,cAliasSF4,cAliasSFT,lMVSFRBCD2)

				//³Tratamento para flag de controle de SELO de produto³
				If cSituaDoc == "00" .And. cEntSai == "2" .And. lAchouSF4 .And. (cAliasSB1)->B1_SELO=="1" .And. (cAliasSF4)->F4_SELO=="1"
					lUsaSelo	:=	.T.
				EndIf

				//³Tratamento para flag de controle de IPI de Pauta³
				If (cAliasSFT)->FT_PAUTIPI>0
					lIpiPauta := .T.
				ElseIf !Empty((cAliasSB1)->B1_TAB_IPI) .And. (cAliasSB1)->B1_VLR_IPI>0
					lIpiPauta := .T.
				EndIf

				//³Tratamento para flag de Nota Fiscal de ICMS-ST para Transportes
				//³Mesmo que o campo F4_CREDST seja = 4, deve-se considerar que os valores
				//³do ICMS-ST estao lancados na apuracao, na linha de Outros Debitos.
				If Iif(lTop,(cAliasSFT)->F4_OBSSOL,(cAliasSF4)->F4_OBSSOL)=="5" .And. (cAliasSFT)->FT_CREDST == "4"
					lIcmStTran	:=	.T.
				Endif

				//Verifico o codigo da natureza da operacao/prestacao para preenchimento do registro 0400 e campo 12 do registro C170
				//Se utiliza Cadastro de Natureza da Operacao (tabela CD1)
				aNatOper	:= SpedNatOper( lAchouCD1, lSpedNat , cAliasSFT , cAliasSF4 , lAchouSF4 )
				cCodNat		:= aNatOper[ 1 ]
				cDescNat	:= aNatOper[ 2 ]

				//³verifica se este item da nota NAO eh um servico e a configuracao do Credito ST.     |
				If !lIss
					If	(cEntSai=="2" .And. (Empty(cMv_StUfS) .Or. (cAliasSFT)->FT_ESTADO$cMv_StUfS)) .Or.;
						(cEntSai=="2" .And. (Empty(cMv_StUf ) .Or. (cAliasSFT)->FT_ESTADO$cMv_StUf)).Or.;	//Debito por saida
						(cEntSai=="1" .And. (Empty(cMv_StUf ) .Or. (cAliasSFT)->FT_ESTADO$cMv_StUf) .And.(cAliasSFT)->FT_TIPO=="D")//Credito por entrada (devolucoes)

						//³Apesar dos valores de SF3 e SFT serem os mesmos, a gravacao das tabelas nao sao,
						//|e se for considerado os campos correspondentes, os valores apresentados serao
						//|diferentes, e para resolver isso preciso temos que saber qual tabela esta sendo
						//|considerada na apuracao de ICMS, para isso faco o tratamento abaixo.
						//|Se o parametro MV_RESF3FT estiver configurado para considerar a tabela SFT,
						//| tenho que somar os campos de retido+isento+outros, pois nao eh gravado conforme
						//| conforme a SF3, que grava sempre o ICMS retido independente da escrituracao.
						If (cAliasSFT)->FT_CREDST <> "4" .Or. lIcmStTran
							If lResF3FT
								//Na tabela SFT o valor de ICMS Retido pode alternar nas colunas dependendo da escrituracao
								nValST	:=	(cAliasSFT)->(FT_ICMSRET+FT_OUTRRET+FT_ISENRET)
								nValST	:=	(cAliasSFT)->(Iif(nValST>0,nValST,FT_OBSSOL))
							Else
								//Na tabela SF3 o valor do ICMS Retido sempre eh gravado em ICMSRET, independente da escrituracao
								nValST	:=	(cAliasSFT)->FT_ICMSRET
								nValST	:=	(cAliasSFT)->(Iif(nValST>0,nValST,FT_OBSSOL))
							EndIf
						EndIF

					//³As ENTRADAS com ICMS/ST nao estao sendo consideradas devido ao SPED Fiscal assumir os valores
					//³  como credito, ou seja, esses valores de ST dos documentos de entrada devem ser lancados no E210
					//³  campo 06 - VL_OUT_CRED_ST conforme observacao do layout para o referido campo.
					//³O SPED Fiscal utiliza um conceito de nao haver creditos de ST em operacoes interestaduais nos
					//³  documentos de entrada, salvo algumas excecoes de escrituracao particulares do estado, que deve
					//|  utilizar ajustes manuais na Apuracao para descrever o lancamento. Podemos citar como exemplo,
					//|  a ANTECIPACAO DE ICMS/ST, que deve ser lancado o valor em Debitos Especiais, a GNRE deve ser
					//|  gerada pelo documento fiscal, portanto pode-se cancelar a tela de geracao da apuracao. A GNRE
					//|  gerada pela NF deve ser amarrada via Complemento de NFs.
					ElseIf cEntSai=="1" .And.;
							(cAliasSFT)->FT_ESTADO==cMVEstado .And. (!(cAliasSFT)->FT_CREDST$"34")

						//Credito por entrada (do mesmo estado)
						//³        MESMA REGRA DA APURACAO (MATA953/FISXAPUR)
						//³Credito de ICMS-ST na entrada, somente considera quando do
						//³mesmo estado do conrtibuinte, variando de acordo com o que
						//³foi selecionado na pergunta Imprime Cred ST
						If lImpCrdSt .And. (cAliasSFT)->FT_SOLTRIB > 0
							nValST := (cAliasSFT)->FT_SOLTRIB

						ElseIf lImpCrdSt
							//³Apesar dos valores de SF3 e SFT serem os mesmos, a gravacao das tabelas nao sao,|
							//|e se for considerado os campos correspondentes, os valores apresentados serao   |
							//|diferentes, e para resolver isso preciso temos que saber qual tabela esta sendo |
							//|considerada na apuracao de ICMS, para isso faco o tratamento abaixo.            |
							//|Se o parametro MV_RESF3FT estiver configurado para considerar a tabela SFT,     |
							//| tenho que somar os campos de retido+isento+outros, pois nao eh gravado conforme|
							//| conforme a SF3, que grava sempre o ICMS retido independente da escrituracao.   |
							If lResF3FT
								//Na tabela SFT o valor de ICMS Retido pode alternar nas colunas dependendo da escrituracao
								nValST	:=	(cAliasSFT)->(FT_ICMSRET+FT_OUTRRET+FT_ISENRET)
								nValST	:=	(cAliasSFT)->(Iif(nValST>0,nValST,FT_OBSSOL))
							Else
								//Na tabela SF3 o valor do ICMS Retido sempre eh gravado em ICMSRET, independente da escrituracao
								nValST	:=	(cAliasSFT)->FT_ICMSRET
								nValST	:=	(cAliasSFT)->(Iif(nValST>0,nValST,FT_OBSSOL))
							EndIf
						EndIf
					EndIf

					//³Para as notas fiscais de entrada tipo devolucao, apos retorno da SEFAZ e analise das regras do layout e validacao do PVA,³
					//³  chegou-se a seguinte conclusao:                                                                                        ³
					//³Para as notas fiscais de entrada tipo devolucao, o valor de ICMS/ST somente deverah ser considerado nos registro C100,   ³
					//³  C170, C190 e E210, quando o contribuinte tiver IE no estado emitente do documento (FT_ESTADO estah contido no          ³
					//³  SUBTRIB), caso contrario deverah levar ZERO nos respectivos campos, pois a NF original, a de saida, teve o ICMS/ST     ³
					//³  recolhido antecipadamente, nao tendo como compensar o credito. Quando houver IE no estado do emitente, segue o fluxo   ³
					//³  normal, pois como o valor do ICMS/ST serah recolhido via Auracao, terah com compensar o debito pelo credito.           ³
					//³Base legal: Alteracao efetuada conforme FNC 00000001419/2011, que contem uma consulta da SEFAZ embasando o entendimento  ³
					//|  acmia.                                                                                                                 |
					//³ Alteracao 19.08.2011 - FNC 00000016165/2011-01                                                                          ³
					//³ Tratamento para acordo entre os estados preenchidos no parametro MV_STNIEUF, quando em um movimento com ICMS-ST NAO e'  ³
					//³ necessario ter Incsc.Est. (MV_SUBTRIB NAO preenchido) Este tratamento foi feit a partir da necessidade das UF d MG p/ PR³
					//³ onde existe esse acordo. PROTOCOLO ICMS CONSELHO NACIONAL DE POLÍTICA FAZENDÁRIA - CONFAZ Nº 191 DE 11.12.2009          ³
					If (cAliasSFT)->FT_TIPO=="D" .And. !(cAliasSFT)->FT_ESTADO==cMVEstado .And. !(cAliasSFT)->FT_ESTADO$cMVSUBTRIB
						If (cEntSai=="1" .And. AllTrim((cAliasSFT)->FT_CFOP)$cMVCFE210) .AND. !((cMVEstado+(cAliasSFT)->FT_ESTADO)$AllTrim(aSPDSX6[MV_STNIEUF])) .Or. cEntSai=="2"
							nValST		:=	0
						ElseIf cEntSai=="1" .And. !AllTrim((cAliasSFT)->FT_CFOP)$cMVCFE210
							lLogCfop	:=	.T.
						EndIf
					EndIf
				EndIf

				//³Tratamento para processar o SF3 sem duplicar³
				//|lResF3FT = .T., processa via SFT, .F. = SF3 |
				If nValST>0
					If !cSituaDoc$"02/04/05/03" .And. !Empty(UfCodIBGE((cAliasSFT)->FT_ESTADO)) .And. (lResF3FT .Or. aScan(aResF3FT,{|aX|aX==SF3->(Recno())})==0)
						SpedApDoc(cEntSai,cMv_StUfS,cMv_StUf,lResF3FT,cAliasSFT,lUsaSped,lImpCrdST,aCmpAntSFT,cMVEstado,@aVlrMovST)
					EndIf

					//Reposicionado a tabela SF3 caso tenha sido efetuado o SEEK anterior
					If !lResF3FT .And. aScan(aResF3FT,{|aX|aX==SF3->(Recno())})==0
						aAdd(aResF3FT,SF3->(Recno()))
						If !lTop
							cChvSeek		:=	xFilial("SF3")+(cAliasSFT)->(DToS (FT_ENTRADA)+FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_CFOP+STR(FT_ALIQICM,5,2))
							SPEDSeek("SF3",,cChvSeek,nRecSF3DBF)
						EndIf
					EndIf
				EndIf

				//³Obtem a classificacao fiscal da nota fiscal, tanto do ICMS quanto do IPI, PIS e COFINS³

				aClasFis	:= SPDRetCCST(cAliasSFT,lAchouSF4,lCstPis,lCstCof,cEspecie,cAliasSF4,cAliasSB1,aPartDoc[13])

				//³Tratamento para alíquota zero de Pis e Cofins.³
				//³Se o item estiver com CST entre 04, 05, 06, 07³
				//³08 ou 09, será desconsiderado a alíquota e    ³
				//³valor de PIS COFINS, considerando comente     ³
				//³a base de cálculo.                            ³
				If lMVSpedAz //MV_SPEDAZ
					lPisZero := .F.
					If (cAliasSFT)->FT_CSTPIS$"#04#05#06#07#08#09#" 
						If lAchouSF4 .And. (cAliasSF4)->F4_PISDSZF <> "1"   //Não tem desconto para ZFM de PIS
							lPisZero := .T.
						EndIf
					EndIF

					lCofZero := .F.
					If (cAliasSFT)->FT_CSTCOF$"#04#05#06#07#08#09#" 
						If lAchouSF4 .And. (cAliasSF4)->F4_COFDSZF <> "1"   //Não tem desconto para ZFM de COFINS
							lCofZero := .T.
						EndIf
					EndIF
				EndIF
				//Operação com garantia
				lOperGar := .F.
				If lAchouSF4 .And. (cAliasSF4)->F4_OPERGAR=="1" .And.;
					(cAliasSF4)->F4_CSTPIS=="98" .And. (cAliasSF4)->F4_CSTCOF=="98"
					lOperGar := .T.
				Endif
			
				//|O array aRegC170 deve ser zerado por item                                               |				
				lGerouC170 := RegC170(cAlias,nRelacDoc,nItem,@aRegC170,cEspecie,cAliasSFT,lIss,aClasFis,lAchouSF4,nApurIpi,cSituaDoc,cUnid,;
										cProd,aCmpAntSFT,nValST,dDataAte,aWizard,cAliasSF4,cAliasSB1,AHistSB1,nQtde,lPisZero,lCofZero,lAchouCD0,;
										cMvEstado,cCodNat,cPerfil,lOperGar,lResF3FT,cAliasSD1)

				//³A chamada da funcao abaixo "SPLancCDA" obtem os lancamentos dos dos itens amarrado no   ³
				//| proprio documento  fiscal, atraves do TES ou manualmente.                              |
				//³O array retornado por referencia, possui as informacoes dos lancamentos de todo o docu- ³
				//³     mento fiscal.                                                                      |
				//³Obs: A posica 13 estah sendo retornada em BRANCO, porem deverah ser atualizada a medida ³
				//³     que os itens do SFT forem sendo passados, pois preciso deste codigo para montar o  ³
				//³     C197 por nfe. Como neste momento nao tenho a variavel cProd para todos os itens,   ³
				//|     necessito atualizar depois, jah que a query vai apenas uma vez por documento no BD |
				//|     e retorna todos os lancamentos do documento.                                       ³
				If lFirstNF		//Garanto que soh chamo a funcao uma vez por documento fiscal, conforme orientacoes acima
					If lTabComp
						//³- aLanCDA serah gerado somente para lancamentos de NF, para gerar os registros C195/C197|
						//³  Segundo o manual, nao eh somente para os modelos 01 e 55, este codigo tambem eh exigido|
						//|    nos registros: C320, C390, C790, C590, C690, D190, etc...                           ³
						//|- aLanCDA2 serah gerado somente quando envolver lancamentos de Apuracao, para gerar os  |
						//|  E113 e Registro E240.                                                                 ³
						
						If CDA->(MsSeek(xFilial("CDA") +;
										 (cAliasSFT)->FT_TIPOMOV + ;
										 (cAliasSFT)->FT_ESPECIE + ;
										 Iif(Empty((cAliasSFT)->FT_FORMUL),Iif((cAliasSFT)->FT_TIPOMOV == "S","S"," "),(cAliasSFT)->FT_FORMUL) +;
										 (cAliasSFT)->FT_NFISCAL + ;
										 (cAliasSFT)->FT_SERIE + ;
										 (cAliasSFT)->FT_CLIEFOR +;
										 (cAliasSFT)->FT_LOJA))
												
							SPLancCDA(cAliasSFT,"",@aLanCDA,cMVEstado,lAchouCDT,cAliasCDT,aPartDoc[1],@aLanCDA2,lOldLan,cEspecie,cProd,@aInfE313,lDifal)
						
						EndIf
						
						For nX := 1 to Len(aLanCDA)
							//³Adiciono os lancamentos de observacoes dos documentos a medida³
							//³ que forem encontrados.
							Reg0460(@aReg0460,{aLanCDA[nX][7],aLanCDA[nX][20]})
						Next nX
					EndIf
				EndIf

				//³Quando este array estiver com conteudo, jah terah de todos os itens,  ³
				//³ neste caso, preciso atualizar somente o codigo de produto conforme   ³
				//³ o cProd - aLanCDA (Notas Fiscais) e aLanCDA2(Apuracao).			     ³
				// De acordo com o EFD de Rondonia não será considerado o 0200 para o  	 ³
				// C197 pois se trata de Redução, Isenção e Estorno de débito(RO20000002)³
				// não irá preencher o COD_ITEM
				For nX := 1 To Len(aLanCDA)
					If aLanCDA[nX,14]==(cAliasSFT)->FT_ITEM
						IF !aLanCDA[nX,1] $ "RO10000012/RO10000006/RO10000007/RO10000003/RO40000001/RO40000002/RO99990009/RO99990016/RO99990017/RO99990068/RO99990165/RO99990195/RO99990166/RO99990170/RO99990183/RO99990175/RO99990021/RO99990130/RO99990022/RO99990037/RO99990086/RO99990116/RO20000002/RO99990078/RO99990083"
							aLanCDA[nX,13]	:=	cProd
						EndIF
					EndIf

					//³Para o código RO99990009, o valor de ICMS deverá ser gerado no campo 05,
					//³e não 06, mesmo sendo operação e código se referindo a isenção de ICMS.
					//³conforme item 1º o anexo da instrução normativa 005/12 para o Estado de Rondoônia
					IF aLanCDA[nX,1] $ "RO99990009/RO99990016/RO99990017/RO99990068/RO99990130/RO99990021/RO99990022/RO99990037/RO99990086/RO99990116/RO99990078/RO99990083"
						aLanCDA[nX,5] := aLanCDA[nX,6]
						aLanCDA[nX,6] := 0
					EndIF

					//³Para os códigos RO40000001/RO40000002 deverá ser levado no campo 6,
					//³o valor da alíquota interna, conforme item 5º e 6º do anexo da instrução
					//³normativa 005/12 para o Estado de Rondoônia
					IF aLanCDA[nX,1] $ "RO40000001/RO40000002"
						//³Tratamento para obter a aliquota interna do produto³
						If ValType(aProd[11]) == "N"
							aLanCDA[nX,6]:=	aProd[11]
							
						ElseIf (cAliasSB1)->B1_PICM>0
							aLanCDA[nX,6]:=(cAliasSB1)->B1_PICM	
						Else
							aLanCDA[nX,6]:=aSPDSX6[MV_ICMPAD]
						EndIf
					EndIF

					If aLanCDA[nX,1] $ "RO99990165/RO99990195/RO99990166/RO99990170/RO99990183/RO99990175"

						//³Tratamento para obter o Percentaul de redução      ³

						If (cAliasSF4)->F4_BASEICM>0 .AND. lAchouCD2
							If (cAliasSF4)->F4_CONSUMO == "S"
								If (cAliasSF4)->F4_LFICM == "I"
									aLanCDA[nX,5]:= (cAliasSFT)->FT_OUTRICM * ((cAliasCD2)->CD2_ALIQ/100)
								Elseif (cAliasSF4)->F4_LFICM == "O"
									aLanCDA[nX,5]:= (cAliasSFT)->FT_ISENICM * ((cAliasCD2)->CD2_ALIQ/100)
								Endif
							Elseif (cAliasSF4)->F4_CONSUMO == "O"
								aLanCDA[nX,5]:=(cAliasSFT)->FT_OUTRICM +(cAliasSFT)->FT_ISENICM
							Endif
							aLanCDA[nX,6]:=(cAliasSF4)->F4_BASEICM
						Endif
					Endif
				Next nX
				For nX := 1 To Len(aLanCDA2)

					//³Verifica a chave, senao corre-se o risco de sobrescrever o produto³

					If aLanCDA2[nX,14] == (cAliasSFT)->FT_ITEM .And.;
						(cAliasSFT)->(FT_TIPOMOV+FT_NFISCAL+FT_SERIE+FT_ESPECIE+aPartDoc[1])==aLanCDA2[nX,11]+aLanCDA2[nX,10]+aLanCDA2[nX,9]+aLanCDA2[nX,8]+aLanCDA2[nX,15]
						aLanCDA2[nX,13]	:=	cProd
					EndIf
				Next nX

				//|Novo tratamento implementado para gerar as informacoes de lancamentos fiscais de docu-
				//| mento baseado em um campo no TES que determina o codigo da observacao do lancamento
				//| fiscal (F4_CODOBSE), com as informacoes do livro e formula.
				//| O parametro MV_CFC195 eh utilizado para indicar quais CFOP's serao desconsideradas no
				//| processamento automatico do registro C195.
				If lAchouSF4 .AND. lAchouCCE .And. !(Alltrim((cAliasSFT)->FT_CFOP)$cMVCFC195) .And. cEspecie$"01#1B#04#55"
					SPEDLC195( cAliasSFT , @aLancFis , cAliasSF4 , cMVSPDTC95 , lAchouCCE )
				Endif

				If lDifal .AND. cEspecie $ '55/57' .AND. !cSituaDoc $ "02/03/04/05" .AND. (cAliasSFT)->FT_DIFAL > 0 
 				
					If  (!(cAliasSFT)->FT_ESTADO $  cMVSUBTRIB .Or. (cAliasSFT)->FT_ESTADO $ cMV_DifTr ) 
						 nPosSemIe	:= aScan(aMovSemIe,{|aX| aX[1]==(cAliasSFT)->FT_ESTADO })
						//Tenho movimentação porém não sou inscrito
						//Adiciona o estado que possui movimentação porém não tem IE						
						If nPosSemIe == 0
							aAdd(aMovSemIe, {})
							nPosSemIe	:=	Len (aMovSemIe)
							aAdd (aMovSemIe[nPosSemIe], (cAliasSFT)->FT_ESTADO)
							aAdd (aMovSemIe[nPosSemIe], 0)
							aAdd (aMovSemIe[nPosSemIe], 0)															
						EndIF
						
						If cEntSai=="2"
							aMovSemIe[nPosSemIe][2] += (cAliasSFT)->FT_DIFAL
							aMovSemIe[nPosSemIe][3] += (cAliasSFT)->FT_VFCPDIF
						EndIF							
					EndIf

					If cEntSai=="2"
						nDifalDest			+= (cAliasSFT)->FT_DIFAL //deverá ver se é inscrito
						nDifalOrig			+= (cAliasSFT)->FT_ICMSCOM
						nDifalFEcp			+= (cAliasSFT)->FT_VFCPDIF //sempre ve se é inscrito
					ElseIf  cEntSai=="1" .AND. (cAliasSFT)->FT_TIPO $ "B/D"
					
						//Para devolução ´recisa inverter, o destino é o próprio contribuinte.
						nDifalDest			+= (cAliasSFT)->FT_ICMSCOM
						
						If (cAliasSFT)->FT_ESTADO $  cMVSUBTRIB .Or. (cAliasSFT)->FT_ESTADO $ cMV_DifTr
							nDifalOrig			+= (cAliasSFT)->FT_DIFAL  //deverá ver se é inscrito
							nDifalFEcp			+= (cAliasSFT)->FT_VFCPDIF //sempre ve se é inscrito
						EndIf
						
					EndIF
					//zera campo 4 registro c101 e d101 quando Difal for apurada na apucaração do ICMS Proprio
					IF aSPDSX6[MV_ESTADO] $ aSPDSX6[MV_ESTE310]
						nDifalOrig := 0
					Endif
				EndIF

				//³SOMENTE MODELOS:
				//³01 - NOTA FISCAL NORMAL
				//³1B - NOTA FISCAL AVULSA
				//³02 - NOTA FISCAL DE VENDA A CONSUMIDOR FINAL
				//³03 - NOTA FISCAL DE SERVICO
				//³04 - NOTA FISCAL PRODUTOR
				//³06 - NOTA FISCAL/CONTA DE ENERGIA ELETRICA
				//³21 - NOTA FISCAL DE SERVICO DE COMUNICACAO
				//³22 - NOTA FISCAL DE SERVICO DE TELECOMUNICACAO
				//³65 - NOTA FISCAL ELETRONICA AO CONSUMIDOR FINAL

				If cEspecie$"01#1B#02#2D#04#06#21#22#28#29#55#65"
					If cEspecie$"01#1B#04#55#65"
						//³REGISTRO C130 - ISS/IR/PREV
						//|A gravacao do array aRegC130 deverah ser efetua ao final de leitura da NF

						If cEntSai=="2" .And. cEspecie$"01#04"
							RegC130(cAliasSFT,@aRegC130,lIss)
						EndIf

						//³Se gravaou registro c170, gravo os registros complementares caso haja³
						If lGerouC170
							If (cEspecie$"01#55#04#1B" .And. !cSituaDoc$"02#04#05#03") .Or. (cEspecie$"55" .And. cSituaDoc$"02#03" .And. cSitDocInf$"08")
								//³REGISTRO C171 - Armazenamento de Combustivel
								//|Funcao independ., gera a estrutura e jah grava, nao precisa retornar nada
								If !(cEspecie$"55" .And. cSituaDoc$"02#03" .And. cSitDocInf$"08")
									If cEntSai=="1" .And. lAchouCD6	
										lGera:= !lLegisPer
										If lGera
											RegC171(cAlias,nRelacDoc,nItem,cAliasSFT,cAliasCD6)
										EndIf
										//³REGISTRO C165 - TRANSPORTE DE COMBUSTIVEIS
										//|Funca independ., gera a estrutura e efetua a gravacao no TRB
										//|  documento fiscal
									ElseIf cEntSai=="2" .And. cEspecie$"01" .And. lAchouCD6 .And. Len(aPTransp)>0
										lGera:=Iif(lLegisPer .And. aTpMov[nContMov]$"S",.F.,.T.)
										If lGera
											RegC165(@aRegC165,aPTransp,cAliasSFT)
										EndIf
									EndIf

									//³REGISTRO C172 - ISS
									//|Funcao independ., gera a estrutura e jah grava, nao precisa retornar nada|
									lGera:=Iif(lLegisPer .And. aTpMov[nContMov]$"S",.F.,.T.)
									If lGera
										If cEspecie$"01" .And. lIss .And. cEntSai == "2"
											RegC172(cAliasSFT,cAlias,nRelacDoc,nItem)
										EndIf
									EndIf
									//³REGISTRO C173 - OPERACOES COM MEDICAMENTOS
									//|Funcao independ., gera a estrutura e jah grava, nao precisa retornar nada|
									lGera:=Iif(lLegisPer .And. aTpMov[nContMov]$"S",.F.,.T.)
									If lGera
										If lAchouCD7
											RegC173(cAlias,nRelacDoc,nItem)
										EndIf
									EndIf
									//³REGISTRO C174 - OPERACOES COM ARMAS DE FOGO
									//|Funcao independ., gera a estrutura e jah grava, nao precisa retornar nada|
									lGera:=Iif(lLegisPer .And. aTpMov[nContMov]$"S",.F.,.T.)
									If lGera
										If cEspecie$"01" .And. lAchouCD8 .And. cEntSai == "2"
											RegC174(cAlias,nRelacDoc,nItem)
										EndIf
									EndIf
									//³REGISTRO C175 - OPERACOES COM VEICULOS NOVOS
									//|Funcao independ., gera a estrutura e jah grava, nao precisa retornar nada|
									lGera:= !lLegisPer
									If lGera
										If lAchouCD9
											RegC175(cAlias,nRelacDoc,nItem,aPartDoc)
										EndIf
									EndIf
									//³REGISTRO C176 - RESSARCIMENTO
									//|Funcao independ., gera a estrutura e jah grava, nao precisa retornar nada|
									lGera:=Iif(lLegisPer .And. aTpMov[nContMov]$"S",.F.,.T.)
									If lGera
										If lAchouCD0 .AND. cEntSai$"2"
											RegC176(cAlias,nRelacDoc,nItem,aCmpAntSFT,@aReg0150,aWizard,lCmpCD0)
										EndIf
									EndIf
									//³REGISTRO C177 - OPERACOES COM PRODUTOS SUJEITOS A SELO DE CONTROLE IPI      ³
									//|Funcao independ., gera a estrutura e jah grava, nao precisa retornar nada|
									lGera:=Iif(lLegisPer .And. aTpMov[nContMov]$"S",.F.,.T.)
									If lGera
										If cEspecie$"01" .And. lUsaSelo
											RegC177(cAlias,nRelacDoc,cAliasSFT,nItem,cAliasSB1,aRegC170)
										EndIf
									EndIf

									lGrava0200 := .T.

									//³REGISTRO 0400 - TABELA DE NATUREZA DA OPERACAO/PRESTACAO
									//|A gravacao do array aReg0400 deverah ser efetua da no final do processamento|
									If !cSituaDoc$"02#04#05#03"
										Reg0400(cCodNat,@aReg0400,cDescNat)
									EndIf
								EndIf
							EndIf
							//³REGISTRO C178 - OPERACOES COM PRODUTOS SUJEITOS A TRIBUTACAO DO IPI POR UNIDADE OU POR
							//|                QUANTIDADE
							//|Funcao independ., gera a estrutura e jah grava, nao precisa retornar nada
							lGera:=Iif(lLegisPer .And. aTpMov[nContMov]$"S",.F.,.T.)
							If lGera
								If lIpiPauta .And. cEntSai == "2"
									RegC178(cAlias,cAliasSFT,nRelacDoc,nItem,cAliasSB1,aRegC170)
								EndIf
							EndIf
						EndIf

						//³REGISTRO C190 - REGISTRO ANALITICO DO DOCUMENTO
						//|A gravacao do array aRegC190 deverah ser efetua ao final de leitura da NF|
						RegC190(aRegC170,cAliasSFT,@aRegC190,cSituaDoc,aLanCda,nRedBSICM,cAliasSF4,cMVCFC195,cSitDocInf)
					ElseIf (cEspecie$"02") .And. cEntSai == "2"
						If cPerfil$"B/C"
							//³REGISTRO C300 - RESUMO DIARIO DAS NOTAS FISCAIS DE VENDA A CONSUMIDOR (CODIGO 02)³
							//|A gravacao do array aRegC300 deverah ser efetua da no final do processamento     |
							nPosC300	:=	RegC300(cSituaDoc,cEspecie,@aRegC300,cAliasSFT,@lNotaC300,aWizard)
							
							//³REGISTRO C310 - DOCUMENTOS CANCELADOS DE NOTAS FISCAIS DE VENDA A CONSUMIDOR (CODIGO 02)³
							//|A gravacao do array aRegC310 deverah ser efetua da no final do processamento            |

							//³Processamento de documentos cancelados
							If cSituaDoc$"02|03"
								RegC310(nPosC300,@aRegC310,cAliasSFT)

							//³Nao processa para notas fiscais canceladas³
							ElseIf !cSituaDoc$"02#04#05#03"
								//|REGISTRO C320 - REGISTRO ANALITICO DO RESUMO DIARIO DAS NOTAS FISCAIS DE VENDA A |
								//|                CONSUMIDOR(MODELO 02)
								//³REGISTRO C321 - ITENS DO RESUMO DIARIO DOS DOCUMENTOS(MODELO 02)
								//|A gravacao do array aRegC320 e aRegC321 deverah ser efetua da no final do proces |
								C320C321(nPosC300,aRegC170,@aRegC320,@aRegC321,cAliasSFT,aLanCDA,nRedBSICM,cAliasSF4,aLancFis,@aReg0460,aWizard,cPerfil)
							EndIf

							If !cSituaDoc$"02#03"
								lGrava0200 := .T.
							EndIf

						ElseIf !cSituaDoc$"02#04#05#03" .And. cPerfil <> "C"	//02=Situacao de cancelada
							//³REGISTRO C370 - ITENS DO DOCUMENTO (MODELO 02)
							//|Funcao independ., gera a estrutura e jah grava, nao precisa retornar nada|
							RegC370(cAlias,nRelacDoc,aRegC170,nItem)

							//³REGISTRO C390 - REGISTRO ANALITICO DAS NOTAS FISCAIS DE VENDA A CONSUMIDOR (CODIGO 02)  ³
							//|A gravacao do array aRegC390 eh efetua ao final do processamento do documento fiscal    |
							RegC390(aRegC170,cAliasSFT,@aRegC390,cSituaDoc,aLanCDA,nRedBSICM,cAliasSF4,aLancFis,@aReg0460)

							lGrava0200 := .T.
						EndIf
					ElseIf (cEspecie$"06#28#29")

						//³Quando o contribuinte estah obrigado ao convenio 115, ele deve gerar os registros³
						//³ 700, 790, 1500 e 1510
						If cEntSai=="2" .And. cEspecie$"06#28#" .And. lConvC115  .And. cPerfil <> "C"
							lGravaC700 := .T.
							//|1510 - ITENS DO DOCUMENTO NOTA FISCAL/CONTA DE ENERGIA ELETRICA (CODIGO 06)
							//|Funcao independ., calcula e efetua a gravacao das informacoes
							If cEspecie$"06" .And. Substr((cAliasSFT)->FT_CFOP,1,1)=="6" .And. !cSituaDoc$"02#04#05#03" .And. "S"$aReg1010[1][7]
								Reg1510(cAlias,nRelacDoc,aRegC170,aPartDoc,nItem,lAchouSFU,aWizard)
								lGrava1500 := .T.
								lGrava0200 := .T.
							EndIf
						EndIf

						//³Os registro C500, C510 e C590 sao a base para os outros registros, por isso deve ³
						//| sempre entrar na funcao para montar os arrays, porem:                           |
						//³Soh irah gerar no arquivo texto quando o contribuinte NAO estiver obrigado ao    ³
						//³ convenio 115, pos gerarah os registros C500, C510 e C590 para o perfil A e      ³
						//| C600, C601, C610 e C620 para o perfil B                                         |
						If !lGravaC700 .And. ((cEntSai=="2" .And. cPerfil=="A") .Or. cEntSai=="1")
							lGravaC500 := .T.
						EndIf

						//|REGISTRO C510 - ITENS DO DOCUMENTO (MODELO 06)
						//|Funcao independ., calcula e efetua a gravacao das informacoes no TRB
						RegC510(cAlias,nRelacDoc,aRegC170,aPartDoc,@aRegC510,nItem,lAchouSFU,lGravaC500,@lGrava0150,cSituaDoc,@lGrava0200,cEntSai,aWizard)

						//|Como o registro C610 eh do perfil B e eh gerado com base no C510, preciso fazer o trata-|
						//| mento abaixo, pois o C510 nao deve ter seus filhos gerados quando for documento cance- |
						//| lado, transformando a variavel lGrava0200 como .F.. Mas  o  registro C610 exige tanto  ³
						//| documentos cancelados quanto normais, tendo entao, que gerar o 0200.
						If cEntSai=="2" .And. cPerfil=="B" .And. !lGravaC500 .And. !lGravaC700
							lGrava0200 := .T.
						EndIf

						//|REGISTRO C590 - REGISTRO ANALITICO DOS DOCUMENTOS FISCAIS (MODELOS 06, 28 E 29)
						//|A gravacao do array aRegC590 eh efetua ao final do processamento do documento fiscal
						RegC590(cAliasSFT,@aRegC590,cSituaDoc,aClasFis,aRegC170,aLanCDA,nRedBSICM,cAliasSF4,aLancFis,@aReg0460)

					ElseIf (cEspecie$"21#22")	//Somente modelo 21 e 22
						If Len(aRegC170)>0

							//³Conforme layout, o registro D510 deve ser gravado somente quando for
							//³ saida, prefil A nao obrigado ao Convenio 115
							If (cPerfil=="A" .And. cEntSai=="2" .And. !lConvC115) .Or. (cEntSai == "1")
								lGravaD500 := .T.
								If !cSituaDoc$"02#04#05#03" .And. cPerfil=="A" 
									lGrava0150 := .T.
								EndIF
							EndIf
							//³Conforme layout,  o registro D600 deve ser gravado somente quando for³
							//³ saida, prefil B nao obrigado ao Convenio 115
							If !cSituaDoc$"02#04#05#03"
								If cPerfil=="B" .And. cEntSai=="2" .And. !lConvC115
									lGrava0200 := .T.
								EndIf
								//|REGISTRO D510 - ITENS NOTA FISCAL DE SERVICO DE COMUNICACAO (MODELO 21) E NOTA FISCAL DE³
								//|                SERVICO DE TELECOMUNICACAO (MODELO 22)
								//|Funcao independ., calcula e efetua a gravacao das informacoes no TRB
								RegD510(cAlias,nRelacDoc,aRegC170,@aRegD510,aPartDoc,nItem,lAchouSFX,cEntSai,;
										lGravaD500,cPerfil,@lGrava0200,aWizard)

								If lGravaD500
									If cEntSai == "2"
										//|TERMINAL FATURADO (MODELO 21 E 22)
										//|Funcao independ., calcula e efetua a gravacao das informacoes no TRB
										If lAchouSFX
											RegD530(cAlias,nRelacDoc)
										EndIf
									EndIf
								EndIf

								//|REGISTRO D590 - REGISTRO ANALITICO DO DOCUMENTO
								//|A gravacao do array aRegD590 eh efetua ao final do processamento do documento fiscal
								RegD590(aRegC170,cAliasSFT,@aRegD590,aLanCDA,nRedBSICM,cSituaDoc,cAliasSF4,aLancFis,@aReg0460)
							EndIf
						EndIf
					EndIf

				ElseIf (cEspecie$"07#08#09#10#11#26#57")
					If (cEntSai=="1" .Or. (cEntSai=="2" .And. (lIntTMS .Or. lSpedRTMS))) .And. !lIss .And. !(cSituaDoc$"02#03#05")  //Cancelado
						If cEntSai=="2" .And. cEspecie=="07" .And. cPerfil <> "C"
							//|REGISTRO D110 - NOTA FISCAL DE SERVICO DE TRANSPORTE (MODELO 07)
							//|Funcao independ., calcula e efetua a gravacao das informacoes no TRB
							lGera:=Iif(lLegisPer .And. aTpMov[nContMov]$"S",.F.,.T.)
							If lGera
								RegD110(cAlias,cAliasSFT,nRelacDoc,nItem,cProd,lSpedRTms,aCmpAntSFT)
							EndIf
							//|REGISTRO - D120 COMPLEMENTO DA NOTA FISCAL (MODELO 07)
							//|Funcao independ., calcula e efetua a gravacao das informacoes no TRB
							lGera:=Iif(lLegisPer .And. aTpMov[nContMov]$"S",.F.,.T.)
							If lGera
								RegD120(cAlias,nRelacDoc,lAchouDA3,nItem,lSpedRTms,cAliasSFT,aCmpAntSFT)
							EndIf
							lGrava0200 := .T.
						EndIf

						//|REGISTRO D190 - REGISTRO ANALITICO DO DOCUMENTO
						//|A gravacao do array aRegD190 eh efetua ao final do processamento do documento fiscal
						lGera:=Iif(lLegisPer .And. aTpMov[nContMov]$"S",.F.,.T.)
						If lGera
							RegD190(aRegC170,cAliasSFT,@aRegD190,lSpedRTMS,aLanCDA,nRedBSICM,aCmpAntSFT,@aReg0460,cAliasSF4,aLancFis,@aReg0460)
						EndIf
					EndIf

				ElseIf cEspecie$"#13#14#15#16" .And. cEntSai=="2"

					//³REGISTRO D300 - REGISTRO ANALÍTICO DOS BILHETES CONSOLIDADOS DE PASSAGEM RODOVIÁRIO (CÓDIGO 13), DE PASSAGEM
					//| AQUAVIÁRIO (CÓDIGO 14), DE PASSAGEM E NOTA DE BAGAGEM (CÓDIGO 15) E DE PASSAGEM FERROVIÁRIO (CÓDIGO 16).

					nPosD300	:= RegD300(@aRegD300,cEspecie,cSituaDoc,nRedBSICM,@lNotaD300,cAliasSFT,aLanCDA,@aReg0460,aLancFis)

					//³REGISTRO D301 - DOCUMENTOS CANCELADOS DOS BILHETES DE PASSAGEM RODOVIÁRIO (CÓDIGO 13), DE PASSAGEM AQUAVIÁRIO
					//|(CÓDIGO 14), DE PASSAGEM E NOTA DE BAGAGEM (CÓDIGO 15) E DE PASSAGEM FERROVIÁRIO (CÓDIGO 16).

					//³Processamento de documentos cancelados³
					If cSituaDoc$"02#03"
						RegD301(nPosD300,@aRegD301,cAliasSFT)
					EndIf

					//³REGISTRO D310 -  COMPLEMENTO DOS BILHETES (CÓDIGO 13, 14, 15 E 16)     ³
					If cPerfil$"A/B"
						RegD310(nPosD300,@aRegD310,cAliasSFT,cSituaDoc,cAlsSD,lTop)
					EndIf

				ElseIf cEspecie$"#59" .And. cEntSai=="2"
					If cPerfil$"A"
						nPosC800 := RegC800(aRegC800,cAliasSFT,cSituaDoc,aPartDoc)
						RegC850(nPosC800,aRegC850,cAliasSFT,cSituaDoc,aClasFis)
					ElseIf cPerfil$"B"
						nPosC860 := RegC860(aRegC860,cAliasSFT,cSituaDoc)
						RegC890(nPosC860,aRegC890,cAliasSFT,cSituaDoc,aClasFis)
					Endif
				EndIf

				//³REGISTRO 1400 - INFORMACOES SOBRE VALORES AGREGADOS

				//|A gravacao do array aReg1400 eh efetuada ao final do processamento da rotina

				//|Tratamento utilizado para gerar o registro para todas as situacoes que o campo
				//|    F4_VLAGREG estiver configurado diferente de ' '
				If lAchouSF4 .And. !Empty((cAliasSF4)->F4_VLAGREG) .And.;
				   !Empty(aPartDoc[7]) .And. "S"$aReg1010[1][6]
					If lAchouDT6 //TMS
						If DUY->(MsSeek(XFilial("DUY")+DT6->DT6_CDRORI))
							If cMVEstado==DUY->DUY_EST .And. !AllTrim((cAliasSF4)->FT_CFOP) $ "1949|2949|3949|5949|6949|7949"	//Conforme Versão 2.0.15 do guia pratico EFD
								SPDReg1400(@aReg1400,cProd,UFCodIBGE(DUY->DUY_EST)+DUY->DUY_CODMUN,cAliasSFT,cAliasSF4,.F.,@lGr2001400,cMVEstado)
							ElseIf AllTrim((cAliasSF4)->FT_CFOP) $ "1949|2949|3949|5949|6949|7949"
								SPDReg1400(@aReg1400,cProd,Alltrim(SM0->M0_CODMUN)+DUY->DUY_CODMUN,cAliasSFT,cAliasSF4,.F.,@lGr2001400,cMVEstado)
							EndIf
						ElseIf cMVEstado==(cAliasSFT)->FT_ESTADO .And. !AllTrim((cAliasSF4)->FT_CFOP) $ "5949|6949|7949"//Conforme Versão 2.0.15 do guia pratico EFD
							SPDReg1400(@aReg1400,cProd,aPartDoc[7],cAliasSFT,cAliasSF4,.F.,@lGr2001400,cMVEstado)
						ElseIf AllTrim((cAliasSF4)->FT_CFOP) $ "1949|2949|3949|5949|6949|7949"
							SPDReg1400(@aReg1400,cProd,Alltrim(SM0->M0_CODMUN),cAliasSFT,cAliasSF4,.F.,@lGr2001400,cMVEstado)
						Endif
					ElseIf cMVEstado==(cAliasSFT)->FT_ESTADO .And. !AllTrim((cAliasSF4)->FT_CFOP) $ "1949|2949|3949|5949|6949|7949"//Conforme Versão 2.0.15 do guia pratico EFD
						SPDReg1400(@aReg1400,cProd,aPartDoc[7],cAliasSFT,cAliasSF4,.F.,@lGr2001400,cMVEstado)
					ElseIf AllTrim((cAliasSF4)->FT_CFOP) $ "1949|2949|3949|5949|6949|7949" 
						SPDReg1400(@aReg1400,cProd,Alltrim(SM0->M0_CODMUN),cAliasSFT,cAliasSF4,.F.,@lGr2001400,cMVEstado)
					Endif

					// Nao usei a lGrava0200 pois se a flag vier como .T. de qualquer condicao acima e o reg. 1400 nao for gerado
					// ela ficará .F. e o 0200 nao será gerado mais abaixo, ocasionando erros na validacao.
					If lGr2001400 .And. !(cMVEstado$"MG/SP" .And. cFormul == "S" )
						//³REGISTRO 0190 - UNIDADES DE MEDIDA
						//³REGISTRO 0200 - TABELA DE IDENTIFICACAO DO ITEM
						//³REGISTRO 0205 - ALTERACOES DO ITEM
						//³REGISTRO 0220 - FATORES DE CONVERSAO DAS UNIDADES
						SFRG0200(cAlias,@aReg0200,@aReg0190,dDataDe,dDataAte,aProd,cProd,@aReg0220,cAliasSB1,cUnid,cMVDTINCB1,lSPDFIS02,nFatorPe,cMVEstado,cPRDPRIB5,cAliasSB5,cAliasCD6,lAchouCD6,Nil,cAliasSFT,,,,,,,aWizard)
						Reg0190(cAlias,cUnid,@aReg0190)
					EndIf
				Endif
				// A validacao para modelo 55(NFe) de Emissao propria foi retirada da funcao C195C197() - esta validacao
				// fazia com que o campo 04 - COD_ITEM do Registro C197 ficasse em branco - pois segundo o Guia Pratico
				// quando se enquadrar nesta situacao, o campo 04 deve ser gerado e o item deve gerar um registro 0200 para
				// este produto.  

				If Len(aLanCDA) > 0 .And. aCmpAntSFT[26]=="0" .And. cEspecie=="55"
					If aScan(aLanCDA,{|aX| aX[14]==(cAliasSFT)->FT_ITEM})>0
						lGrava0200 := .T.
					Endif
				Endif
				//Validação conforme EFD – Manual de Orientações da Escrituração Fiscal Digital para Contribuintes do Estado de Rondônia.
				//Se o registro C197 campo 04 - COD_ITEM estiver em branco e a operação for de Rondonia com código de lançamento 
				// não será gerado o registro 0200 de acordo com EFD
				If cMVEstado=="RO" .And. aCmpAntSFT[26]=="0" .And. cEspecie=="55" .And. (( Len(aLanCDA) > 0 .Or. Len(aLancFis) > 0 )) .Or. ;
				  (cMVEstado=="MG" .And. cFormul == "S" .And. lGr2001400)
					lGrava0200 := .F.
				Endif

				//³REGISTRO 0190 - UNIDADES DE MEDIDA
				//³REGISTRO 0200 - TABELA DE IDENTIFICACAO DO ITEM
				//³REGISTRO 0205 - ALTERACOES DO ITEM
				//³REGISTRO 0220 - FATORES DE CONVERSAO DAS UNIDADES
				//|Funcao independ., monta a estrutura dos registros e efetua as gravacoes no TRB
				If lGrava0200
					SFRG0200(cAlias,@aReg0200,@aReg0190,dDataDe,dDataAte,aProd,cProd,@aReg0220,cAliasSB1,cUnid,cMVDTINCB1,lSPDFIS02,nFatorPe,cMVEstado,cPRDPRIB5,cAliasSB5,cAliasCD6,lAchouCD6,,cAliasSFT,,,,,,,aWizard)

					//³REGISTRO 0190 - UNIDADES DE MEDIDA
					//|Funcao independ., monta a estrutura dos registros e efetua as gravacoes no TRB
					Reg0190(cAlias,cUnid,@aReg0190)
				EndIf

				//|REGISTRO E510 - CONSOLIDACAO DOS VALORES DE IPI POR CFOP E CODIGO DE SITUACAO TRIBUTARIA
				//|A gravacao do array aRegE510 eh efetuada ao final do processamento da rotina
				If !cSituaDoc$"02#04#05#03" .And. "0"$aWizard[2][5] .And. cEspecie$"2D#01#1B#04#55"
					RegE510(cAliasSFT,@aRegE510,cSituaDoc,aClasFis)
				EndIf
				/*Como esta tabela possui escrituracao fiscal por item de documento fiscal, acumulo valores
				necessarios independente dos itens, ou seja,por NF.*/
				aTotaliza[1]	+=	(cAliasSFT)->FT_VALCONT	   							//Totliza o valor contabil do documento		
				aTotaliza[8]	+=	nQtde						   						//Totaliza a quantidade do item
				aTotaliza[9]	+=	(cAliasSFT)->FT_DESCONT	   							//Totaliza o valor de desconto do documento
				aTotaliza[10]	+=	(cAliasSFT)->FT_TOTAL + (cAliasSFT)->FT_DESCZFR		//Totaliza o documento fiscal
				//Adiciona valor de IPI ou ST não creditado ao valmerc
				If cEntSai == "1" .And. (!(cAliasSF4)->F4_LFIPI$"T" .Or. (cAliasSFT)->FT_CREDST $ "3|4" ) .And. !(cAliasSFT)->FT_TIPO$"DB"
				     If !(cAliasSF4)->F4_LFIPI$"T"
				    	aTotaliza[10]	 +=	 (cAliasSD1)->D1_VALIPI
				    EndIf       
				    
						If (cAliasSFT)->FT_CREDST $ "3|4"						
							aTotaliza[10]	+= 	RetStSpd(lResF3FT, cAliasSFT)								
						EndIf
				     
				EndIf
				aTotaliza[11]	+=	(cAliasSFT)->FT_FRETE	   							//Totaliza o valor de frete do documento
				aTotaliza[12]	+=	(cAliasSFT)->FT_SEGURO	   	   						//Totaliza o valor de seguro das mercadorias do documento

				//Tratamento para nao levar valor negativo
				If (cAliasSFT)->(FT_DESPESA-(FT_SEGURO+FT_FRETE))>0
					aTotaliza[13]	+=	(cAliasSFT)->(FT_DESPESA-(FT_SEGURO+FT_FRETE))	//Totaliza as outras despesas do documento fiscal. Este tratamento se faz necessario porque FRETE e SEGURO incorporam o valor da despesa no sistema
				EndIf
				aTotaliza[19]	+=	Iif(lPisZero .Or. lOperGar,0,(cAliasSFT)->FT_VALPIS)	//Totaliza o valor de PIS do documento
				aTotaliza[20]	+=	Iif(lPisZero .Or. lOperGar,0,((cAliasSFT)->FT_VALCOF - (cAliasSFT)->FT_MVALCOF))//Totaliza o valor da Cofins do documento
				aTotaliza[21]	+=	(cAliasSFT)->FT_VALPS3 //Totaliza o valor de PIS/ST do documento
				aTotaliza[22]	+=	(cAliasSFT)->FT_VALCF3 //Totaliza o valor da Cofins/ST do documento

				/*Valor deve corresponder ao Abatimento não tributado e não comercial
				 -Considerando o VALOR do ICMS correspondente à redução da base de
				  cálculo quando este é descontado do valor contábil (F4_AGREG="D")
				 -Considerar também o desconto para Zona Franca de Manaus*/

				nAbatNT := (cAliasSFT)->FT_DESCZFR

				/* Tenta utilizar o campo FT_DESCICM criado para ter o mesmo valor que
				   já era gravado em SD2/SD1(D2_DESCICM) e o campo FT_AGREG criado
				   para gravar o conteúdo do F4_AGREG no momento da emissão da NF
				   caso não existam/não estejam preenchidos, verificar em SD1/SD2/SF4*/

				If (cAliasSFT)->FT_AGREG =="D" .And. (cAliasSFT)->FT_DESCICM >0
					nAbatNT += (cAliasSFT)->FT_DESCICM
				Else
					If lAchouSF4 .And. (cAliasSF4)->F4_AGREG=="D" .And. (Iif(!lTop,cAlsSD,cAliasSFT))->(&(cCmpDescIcm))>0
						nAbatNT += (Iif(!lTop,cAlsSD,cAliasSFT))->(&(cCmpDescIcm))
					EndIf
				EndIf
				aTotaliza[26]	+=	IIf(nAbatNT>0,nAbatNT,0)	//Totaliza o valor do Abatimento não tributado e não comercial

				//Valores que devem ser acumulados somente se nao for item de servico
				If !lIss
					aTotaliza[2]	+=	(cAliasSFT)->FT_BASEICM							//Totaliza a base de ICMS do documento
					aTotaliza[3]	+=	(cAliasSFT)->FT_VALICM							//Totaliza o valor de ICMS do documento
					If nValST > 0
						aTotaliza[4]	+=	(cAliasSFT)->FT_BASERET			 			//Totaliza a base de ICMS/ST do documento
						aTotaliza[5]	+=	nValST										//Totaliza o valor de ICMS/ST do documento
					EndIf
					
					If cEntSai == "1" .And. (cAliasSF4)->F4_LFIPI$"T"
						If !(cAliasSFT)->FT_TIPO$"DB"
							aTotaliza[6]	+=	Iif((cAliasSF4)->F4_LFIPI$"T",(cAliasSD1)->D1_VALIPI,0)    //Totaliza o valor de IPI do documento
						Else
							aTotaliza[6]	+= (cAliasSFT)->FT_VALIPI
						EndIf					
					ElseIf cEntSai == "2" 
						aTotaliza[6]	+=	(cAliasSFT)->FT_VALIPI							//Totaliza o valor de IPI do documento
					EndIF
					aTotaliza[7] 	+=	(cAliasSFT)->(FT_OUTRICM+FT_ISENICM)			//Totaliza a parte do valor da mercadoria que nao tributada pelo ICMS
					aTotaliza[14]	+=	(cAliasSFT)->(FT_OUTRICM+FT_OUTRRET+FT_ISENICM+FT_ISENRET)	//Totaliza a parte do valor da mercadoria que nao foi tributada
					aTotaliza[15]	+=	(cAliasSFT)->FT_BASEIPI							//Totaliza a base do IPI do documento
					aTotaliza[16]	+=	(cAliasSFT)->FT_ISENIPI							//Totaliza a parte isenta do IPI
					aTotaliza[17]	+=	(cAliasSFT)->FT_OUTRIPI							//Totaliza outras escrituracoes do IPI
					aTotaliza[18]	+=	(cAliasSFT)->FT_ICMSCOM							//Totaliza o ICMS Complementar do documento - Diferencial de aliquota
				EndIf

				lFirstNF	:=	.F.	//Tratamento de um flag para indicar um processamento unico de nota fiscal
				nItem++
				(cAliasSFT)->(DbSkip ())
			EndDo	//ENDDO do item
			//³No caso de o objeto oProcess existir, significa que a nova barra
			//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,
			//| portanto deve ser efetuado os controles para demonstrar o
			//| resultado do processamento.

			//³Tratamento para cancelamento de processamento
   	        //LGS#20200131 - Adequação para release 12.1.25 e posteriores
            //If Type("oProcess")=="O"
            If _lValPro
				//Controle do cancelamento da rotina
				If oProcess:Cancel()
					Exit
				EndIf
			Else
				//Controle do cancelamento da rotina³
				If Interrupcao(@lEnd)
					Exit
				EndIf
			EndIf

			//³SOMENTE MODELOS:
			//³01 - NOTA FISCAL NORMAL
			//³1B - NOTA FISCAL AVULSA
			//³02 - NOTA FISCAL PRODUTOR
			//³03 - NOTA FISCAL DE SERVICOS
			//³04 - NOTA FISCAL DE VENDA A CONSUMIDOR FINAL
			//³06 - NOTA FISCAL/CONTA DE ENERGIA ELETRICA
			//³21 - NOTA FISCAL DE SERVICO DE COMUNICACAO
			//³22 - NOTA FISCAL DE SERVICO DE TELECOMUNICACAO
			//³28 - NOTA FISCAL/CONTA DE FORNECIMENTO DE GAS
			//³29 - NOTA FISCAL/CONTA DE FORNECIMENTO D'AGUA CANALIZADA
			//³55 - NOTA FISCAL ELETRONICA
			//³65 - NOTA FISCAL ELETRONICA AO CONSUMIDOR FINAL
			If cEspecie$"01#1B#02#2D#04#06#13#14#15#16#21#22#28#29#55" + Iif(cEntSai=="1","","#65")

				//³REGISTRO C100 - NOTA FISCAL CODIGO 01, NOTA FISCAL PRODUTOR CODIGO 04
				//³REGISTRO C140 - FATURA e C141 - VENCIMENTO DA FATURA (CODIGO 01)
				//|Funca que retorna as parcelas dos titulos do documento fiscal.
				If cEntSai=="1"
					aParcTit	:=	SpedProSE2(aCmpAntSFT)
				Else
					aParcTit	:=	SpedProSE1(aCmpAntSFT)
				EndIf
				//³REGISTRO C100 - NOTA FISCAL CODIGO 01, NOTA FISCAL PRODUTOR CODIGO 04
				//|Funca independ., monto a estrutura e efetuo a gravacao. Porem, processo para todos,  |
				//|  pois utilizo o array para montar outros registros e ter um unico lugar com as         |
				//|  informacoes base.				
				RegC100(cEntSai,aPartDoc,cEspecie,cAlias,nRelacDoc,aCmpAntSFT,aTotaliza,@aRegC100,cSituaDoc,@lGrava0150,aParcTit,lPisZero,lCofZero,cVersao,aWizard,lOperGar,cSitDocInf)

				//Grava registro C101 para informações do FECP
				If cEspecie == '55' .AND. !cSituaDoc $ "02/03/04/05" .AND. nDifalDest+nDifalOrig+nDifalFEcp > 0
					GrvRegTrS(cAlias,nRelacDoc,{{'C101',nDifalFEcp,nDifalDest,nDifalOrig}})
				EndIF

				//³REGISTRO 1700 - DOCUMENTOS FISCAIS UTILIZADOS
				//³REGISTRO 1710 - DOCUMENTOS FISCAIS CANCELADOS/INUTILIZADOS
				//|Funca que gera a estrutura dos registros acima e os grava no final do processamento da
				//|  rotina, pois se referem a um aglutinado de documentos por codigo de dispositivo,
				//|  especie e serie

				If "S"$aReg1010[1][9]  .And. cEntSai=="2"  // Para documento de saida, pois se trata de AIDF vide Guia Pratico EFD
					SpdFRg1700(aRegC100,@aReg1700,@aReg1710,cSituaDoc)
				Endif
				If (cEspecie$"01#1B#04#55#65")
					If !cSituaDoc$"02#04#05#03" .Or. (cSituaDoc$"02" .And. cSitDocInf$"08")
						lCondC120 := (cEntSai=="1" .And. (lAchouCD5 .Or. (lSigaEIC .And. !Empty((Iif(lTop,cAliasSFT,cAlsSF))->(cCmpHawb)) .And. Len(aAvImport)>0)))
						If lGerouC170 .OR. (cEspecie$"55" .AND. (lAchouCDT .OR. lCondC120 .OR. aExistBloc[18] .OR. cSitDocInf$"08" .OR. lRegEspPr)) .And. cPerfil <> "C"						
							//³REGISTRO C111 - PROCESSO REFERENCIADO

							//|Funcao que gera a estrutura do registro acima, mais o G110 e 0450. A gravacao do C111
							//| ocorre no final do processamento do documento fiscal
							If lAchouCDG .Or. (cSituaDoc$"02#03" .And. cSitDocInf$"08")
								RegC111(cAliasCDG,@aRegC110,@aReg0450,@aRegC111,lTop,aCmpAntSFT)
							EndIf

							//³REGISTRO C112 - GUIA REFERENCIADA
							//|Funcao que gera a estrutura do registro acima, mais o G110 e 0450. A gravacao do C112
							//| ocorre no final do processamento do documento fiscal
							If lAchouCDC
								RegC112(cAliasCDC,@aRegC110,lTop,@aReg0450,@aRegC112,@aIcmPago,aCmpAntSFT)
							EndIf
							//³REGISTRO C113 - DOCUMENTO FISCAL REFERENCIADO
							//|Funcao que gera a estrutura do registro acima, mais o G110 e 0450. A gravacao do C113
							//| ocorre no final do processamento do documento fiscal
							If lAchouCDD
								RegC113(cAlias,cAliasCDD,@aRegC110,@aReg0450,cEntSai,aCmpAntSFT,@aReg0150,@aRegC113,aWizard,lTop)
							EndIf

							//³REGISTRO C114 - CUPOM FISCAL REFERENCIADO                                               ³
							//|REGISTRO C116 - CUPOM FISCAL ELETRÔNICO REFERENCIADO - SATCE                            |
							//|Funcao que gera a estrutura do registro acima, mais o G110 e 0450. A gravacao do C114   |
							//| ocorre no final do processamento do documento fiscal                                   |
							lGera:= !lLegisPer
							If lGera
								//Nota sobre cupom
								If lAchouCDE .And. (cEntSai=="2" .Or. (cEntSai=="1" .And. aCmpAntSFT[20] == "D"))
									aAreaCDE := (cAliasCDE)->(GetArea())
									RegC114(cAliasCDE,@aRegC110,@aReg0450,aCmpAntSFT,@aRegC114,,aCmpAntSFT[29],lTop,cEntSai)
									RestArea(aAreaCDE)
									RegC116(cAliasCDE,@aRegC110,@aReg0450,aCmpAntSFT,@aRegC116,,aCmpAntSFT[29],lTop,cEntSai)
									RestArea(aAreaCDE)
								//³Se nao existir CDT, tenho que fazer verificacao se existe cupom fiscal referenciado³
								//³  quando tem integracao com o SIGALOJA. Para isso foi criado o parametro necessario³
								//³  para indicar um codigo de CCE valido para criar o lancamento corretamente
								ElseIf lAchouCDE .AND. cEntSai=="2" .And. !Empty(cCodRefLj)

									//³Tratamento para alterar o ALIAS da tabela SF? quando for TOP ou DBF, pois em TOP³
									//³  os campos estao no SELECT
									If !Empty(aCmpAntSFT[29])

										//³REGISTRO C114 - CUPOM FISCAL REFERENCIADO                                               ³
										//|REGISTRO C116 - CUPOM FISCAL ELETRÔNICO REFERENCIADO - SATCE                            |
										//|Funcao que gera a estrutura do registro acima, mais o G110 e 0450. A gravacao do C114   |
										//| ocorre no final do processamento do documento fiscal                                   |
										aAreaCDE := (cAliasCDE)->(GetArea())
										RegC114(cAliasCDE,@aRegC110,@aReg0450,aCmpAntSFT,@aRegC114,cCodRefLj,aCmpAntSFT[29],lTop,cEntSai)
										RestArea(aAreaCDE)
										RegC116(cAliasCDE,@aRegC110,@aReg0450,aCmpAntSFT,@aRegC116,cCodRefLj,aCmpAntSFT[29],lTop,cEntSai)
										RestArea(aAreaCDE)
									EndIf
								ElseIf lAchouCDE .AND. cEntSai=="1" .And. aCmpAntSFT[20] == "D" .And. !Empty(cCodRefLj)
									aAreaCDE := (cAliasCDE)->(GetArea())
									RegC114(cAliasCDE,@aRegC110,@aReg0450,aCmpAntSFT,@aRegC114,cCodRefLj,aCmpAntSFT[29],lTop,cEntSai)
									RestArea(aAreaCDE)
									RegC116(cAliasCDE,@aRegC110,@aReg0450,aCmpAntSFT,@aRegC116,cCodRefLj,aCmpAntSFT[29],lTop,cEntSai)
									RestArea(aAreaCDE)
								EndIf
							EndIf
							//³REGISTRO C115 - LOCAL DE COLETA ENTREGA
							//|Funcao que gera a estrutura do registro acima, mais o G110 e 0450. A gravacao do C115
							//| ocorre no final do processamento do documento fiscal
							If lAchouCDF .And. cEspecie$"01#1B#04" .And. cEntSai=="2"  .And. cPerfil <> "C"
								RegC115(cAliasCDF,@aRegC110,@aReg0450,aCmpAntSFT,@aRegC115,lTop)
							EndIf

							//³REGISTRO C110 - INFORMACAO COMPLEMENTAR DA NOTA FISCAL (CODIGO 01, 04 E 55)
							//³Funcao que gera apenas o registro C110 - Informação complementar
							If (lAchouCDT .Or. (cSituaDoc$"02#03" .And. cSitDocInf$"08") .OR. lRegEspPr)  .And. cPerfil <> "C"
								RegC110(@aInfCompl,@aRegC110,@nPosC110,@aReg0450,cAliasCDT,lTop,,aCmpAntSFT,nMVSPDIFC,,lRegEspPr)

							//³Geracao dos registros C110 e 0450 a partir do Ponto de Entrada SPDPISIC	³
							Elseif aExistBloc[18] .And. cPerfil<>"C"
								aSpdInfC	:=	ExecBlock("SPDPISIC",.F.,.F.,{	aCmpAntSFT[1],; 	//FT_NFISCAL
																				aCmpAntSFT[2],; 	//FT_SERIE
																				aCmpAntSFT[3],; 	//FT_CLIEFOR
																				aCmpAntSFT[4],; 	//FT_LOJA
																				aCmpAntSFT[5],;		//FT_ENTRADA
																				cEntSai})			//Entrada/Saida

								For nI := 1 To Len(aSpdInfC)
									RegC110(,@aRegC110,@nPosC110,@aReg0450,,,aSpdInfC[nI],,,,lRegEspPr)
								Next nI
							EndIf

							//GRAVACAO DOS COMPLEMENTOS PROCESSADOS ANTERIORMENTE

							//REGISTRO C110 - INFORMACAO COMPLEMENTAR DA NOTA FISCAL (CODIGO 01, 04 E 55)
							//REGISTRO C111 - PROCESSO REFERENCIADO
							//REGISTRO C112 - GUIA REFERENCIADA
							//REGISTRO C113 - DOCUMENTO FISCAL REFERENCIADO
							//REGISTRO C114 - CUPOM FISCAL REFERENCIADO
							//REGISTRO C115 - LOCAL DE COLETA ENTREGA

							//|Funca que gera a estrutura dos registros acima e os grava no final do processamento do
							//|  documento fiscal

							GrRegDep(cAlias, aRegC110, aRegC111,,,,nRelacDoc)
							GrRegDep(cAlias, aRegC110, aRegC112,.T.,,.F.,nRelacDoc)
							GrRegDep(cAlias, aRegC110, aRegC113,.T.,,.F.,nRelacDoc)
							GrRegDep(cAlias, aRegC110, aRegC114,.T.,,.F.,nRelacDoc)
							GrRegDep(cAlias, aRegC110, aRegC115,.T.,,.F.,nRelacDoc)
							GrRegDep(cAlias, aRegC110, aRegC116,.T.,,.F.,nRelacDoc)
							If cEspecie$"01#55"  .And. cPerfil <> "C"
								//³REGISTRO C120 - DECLARACAO/BASE DE CALCULO DE IMPORTACAO (MODELO 01)
								//|Funca independ., gera a estrutura e efetua a gravacao no TRB
								//|  documento fiscal
								lGera:=Iif(lLegisPer .And. aTpMov[nContMov]$"E",.F.,.T.)
								If lGera
									If lCondC120
									//If cEntSai=="1" .And. (lAchouCD5 .Or. (lSigaEIC .And. !Empty((Iif(lTop,cAliasSFT,cAlsSF))->(cCmpHawb)) .And. Len(aAvImport)>0))
										RegC120(cAlias,nRelacDoc,cAliasCD5,lSigaEIC,aAvImport,lAchouCD5,aWizard)
									EndIf
								EndIf
								//³REGISTRO C140 - FATURA e C141 - VENCIMENTO DA FATURA
								//|Funca independ., gera a estrutura e efetua a gravacao no TRB
								//|  documento fiscal
								lGera:= !lLegisPer
								If lGera
									If !(cEspecie$"55")
										C140C141(cAlias,nRelacDoc,aRegC100,aParcTit,cEntSai,aCmpAntSFT)
									EndIf
								EndIf
							EndIf

							//Somente para documentos de SAIDA

							If cEntSai == "2"
								//³REGISTRO C130 - ISS

								//|Funca de gravacao do registro no arquivo de trabalho (TRB) da rotina
								//|Obs: Soh devo gravar se houver valores. Este array sempre terah 1 indice, por isso tenho|
								//|     que ver os valores
								lGera:=Iif(lLegisPer .And. aTpMov[nContMov]$"S",.F.,.T.)
								If lGera
									If aRegC130[2]+aRegC130[3]+aRegC130[4]+aRegC130[5]+aRegC130[6]+aRegC130[7]+aRegC130[8]>0
										GrvRegTrS (cAlias,nRelacDoc,{aRegC130})
									EndIf
								EndIf
								//³REGISTRO C160 - VOLUMES TRANSPORTADOS

								//|Funca independ., gera a estrutura e efetua a gravacao no TRB
								//|  documento fiscal

								//If cEspecie$"01#04" .And. cEntSai=="2"
								//	RegC160(cAlias,nRelacDoc,@aReg0150,aWizard,aCmpAntSFT,lCadParti,aHistSA4,lAchouDA3,cAliasSA4,aF2EspVol)
								//EndIf

								//³REGISTRO C165 - TRANSPORTE DE COMBUSTIVEIS
								//|Funca independ., efetua a gravacao no TRB das informacoes do registro processadas
								//|  anteriormente

								If Len(aRegC165)>0
									GrvRegTrS(cAlias,nRelacDoc,aRegC165)
								EndIf
							EndIf

						//³Tratamento para quando for modelo 55(NF-e), gerar as informacoes da GNRE por NF
						//³  somente para agregar ao registro E250, jah que conforme manual, para esta especie de
						//³  NF somente o registro C100 e C190 devem ser gerados

						EndIf
						
						If cEspecie == "55" .And. lAchouCDC
							SpdGnreDoc(@aIcmPago, cAliasSF6, cAliasCDC, cCDCChv)
						EndIf

						//³REGISTRO C190 - REGISTRO ANALITICO DO DOCUMENTO
						//|Funca de gravacao do registro no arquivo de trabalho (TRB) da rotina
						GrvRegTrS(cAlias,nRelacDoc,aRegC190)

						//³REGISTRO C195 - OBSERVACOES DO LANCAMENTO FISCAL (CODIGO 01 E 55)
						//³REGISTRO C197 - OUTRAS OBRIGACOES TRIBUTARIAS, AJUSTES E INFORMACOES DE VALORES
						//|                PROVENIENTES DE DOCUMENTO FISCAL

						//|Funca independ., gera a estrutura e efetua a gravacao no TRB
						//|  documento fiscal

						If Len(aLanCDA) > 0 .OR. Len(aLancFis) > 0  .Or. aExistBloc[23]
							C195C197( cAlias, nRelacDoc, aLanCDA, @aReg0460, aCmpAntSFT, cEspecie, aLancFis, cMVEstado,;
							          @aReg0200, @aReg0190, @aReg0220, dDataDe, dDataAte,cMVSPDTC95, aWizard )
						EndIf

					EndIf

				ElseIf (cEspecie$"02") .And. cEntSai == "2" .And. !(cSituaDoc$"02#04#05#03")	//02=Situacao de cancelada
					If cPerfil == "A" .And. !(cSituaDoc$"02#04#05#03")

						//³REGISTRO C350 - NOTA FISCAL DE VENDA A CONSUMIDOR (CODIGO 02)
						//|Funcao independ., pois processa e grava as informacoes do registro C350 e efetua
						//| tambem a gravacao do C390 com base nas informacoes processadas anteriormente
						C350C390(cAlias,nRelacDoc,aRegC100,aPartDoc,cAliasSFT,aRegC390,@lNotaC350,aWizard)
					EndIf

				ElseIf (cEspecie$"06#28#29")

					If lGravaC700
						lGera:=Iif(lLegisPer .And. aTpMov[nContMov]$"S",.F.,.T.)
						If lGera
							//|C700 - CONSOLIDACAO DOS DOCUMENTOS NF/CONTA DE ENERGIA ELETRICA (COD 06), EMITIDAS EM
							//|       VIA UNICA (EMPRESAS OBRIGADAS A ENTREGA DO ARQUIVO PREVISTO NO CONVENIO ICMS
							//|       115/03) E NOTA FISCAL/CONTA DE FORNECIMENTO DE GAS CANALIZADO (COD 28)

							//|Atribui os valores do array aRegC700 para efetuar a gravacao no final do processamento
							//|  da rotina.
							nPosC700	:=	RegC700(aRegC100,@aRegC700,lAchouSFU,aCmpAntSFT,lAchouCD3,cEspecie,cSituaDoc)

							//|C790 - REGISTRO ANALITICO DO DOCUMENTO (MODELO 06)
							//|Atribui os valores do array aRegC790 para efetuar a gravacao no final do processamento
							//|  da rotina.
							RegC790(aRegC590,nPosC700,@aRegC790,@aRegC700,@aRegC791,aCmpAntSFT,cMVSUBTRIB,cSituaDoc)
							//|1500 - NOTA FISCAL CONTA DE ENERGIA ELETRICA (MODELO 06)
							//|Funcao independ., montagem e gravacao das informacoes do registro 1500
							If lGrava1500 .And. "S"$aReg1010[1][7]
								Reg1500(cAlias,nRelacDoc,aRegC100,aTotaliza,lAchouSFU,@lGrava0150,aCmpAntSFT,aWizard)
							EndIf
						EndIf
					Else
						//³REGISTRO 0450 - TABELA DE INFORMACAO COMPLEMENTAR/OBSERVACAO
						//|Atribui os valores do array aReg0450 para efetuar a gravacao no final do processamento
						//| da rotina.
						If lAchouCDT
							If !(cAliasCDT)->(Empty(CDT_IFCOMP))
								aInfCompl	:=	{(cAliasCDT)->CDT_IFCOMP,}
								Reg0450(@aInfCompl,@aReg0450)
							EndIf
						EndIf

						//|REGISTRO C500 - NOTA FISCAL/CONTA ENERGIA ELETRICA (MODELO 06)
						//|Funcao independ., montagem e gravacao das informacoes do registro C500
						//|Retorna por parametro o array aRegC500 para ser utilizado por outras funcoes
						RegC500(cAlias,nRelacDoc,aRegC100,aTotaliza,@aRegC500,nItem,lAchouSFU,lAchouCD3,lGravaC500,@lGrava0150,aCmpAntSFT,lAchouCD4,aInfCompl,cAliasCD4,aWizard)
						//³Tratamento para geracao dos registros do perfil B³
						If !lGravaC500 .And. cEntSai=="2" .And. cPerfil=="B"							
							//³REGISTRO C600 - CONSOLIDACAO DIARIA DE NOTAS FISCAIS/CONTA DE ENERGIA ELETRICA
							//|                (MODELO 06), NOTA FISCAL/CONTA DE FORNECIMENTO D'AGUA CANALIZADA
							//|                (CODIGO 29) E NOTA FISCAL/CONTA DE FORNECIMENTO DE GAS (CODIGO 28)
							//|Atribui os valores do array aRegC600 para efetuar a gravacao no final do processamento
							//| da rotina.
							lGera:=Iif(lLegisPer .And. aTpMov[nContMov]$"S",.F.,.T.)
							If lGera
								nPosC600:=	RegC600(aRegC500,aPartDoc,@aRegC600,lAchouSFU,lAchouCD3,lAchouCD4,cAliasCD4,cSituaDoc,aWizard)
							EndIf
							//³REGISTRO C601 - DOCUMENTOS CANCELADOS - CONSOLIDACAO DIARIA DE NOTAS FISCAIS/CONTA DE   |
							//|                ENERGIA ELETRICA (MODELO 06), NOTA FISCAL/CONTA DE FORNECIMENTO D'AGUA  |
							//|                CANALIZADA (CODIGO 29) E NOTA FISCAL/CONTA DE FORNECIMENTO DE GAS       |
							//|                (CODIGO 28)                                                             |
							//|                                                                                        |
							//|Atribui os valores do array aRegC601 para efetuar a gravacao no final do processamento  |
							//| da rotina.                                                                             |
							lGera:=Iif(lLegisPer .And. aTpMov[nContMov]$"S",.F.,.T.)
							If lGera
								RegC601(aCmpAntSFT,@aRegC600,@aRegC601,nPosC600,aRegC500)
							EndIf
							//³REGISTRO C610 - ITENS DO DOCUMENTO CONSOLIDADO (NOTAS FISCAIS/CONTA DE ENERGIA ELETRICA |
							//|                (MODELO 06), NOTA FISCAL/CONTA DE FORNECIMENTO D'AGUA CANALIZADA        |
							//|                (CODIGO 29) E NOTA FISCAL/CONTA DE FORNECIMENTO DE GAS (CODIGO 28)      |
							//|                                                                                        |
							//|Atribui os valores do array aRegC610 para efetuar a gravacao no final do processamento  |
							//| da rotina.                                                                             |
							lGera:=Iif(lLegisPer .And. aTpMov[nContMov]$"S",.F.,.T.)
							If lGera
								RegC610(aRegC500,aRegC510,lAchouSFU,@aRegC610,nPosC600,cSituaDoc,aWizard)
							EndIf
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³REGISTRO C690 - REGISTRO ANALITICO  DOS DOCUMENTOS (NOTAS FISCAIS/CONTA DE ENERGIA ELE- |
							//|                TRICA (MODELO 06), NOTA FISCAL/CONTA DE FORNECIMENTO D'AGUA CANALIZADA  |
							//|                (CODIGO 29) E NOTA FISCAL/CONTA DE FORNECIMENTO DE GAS (CODIGO 28)      |
							//|                                                                                        |
							//|Atribui os valores do array aRegC610 para efetuar a gravacao no final do processamento  |
							//| da rotina.                                                                             |
							lGera:=Iif(lLegisPer .And. aTpMov[nContMov]$"S",.F.,.T.)
							If lGera
								RegC690(aRegC590,nPosC600,@aRegC690)
							EndIf
						ElseIf lGravaC500 .And. !cSituaDoc$"02#04#05#03"
							//³Gravacao do REGISTRO C590   ³
							GrvRegTrS (cAlias,nRelacDoc,aRegC590)
						EndIf
					EndIf


				ElseIf (cEspecie$"21#22") //  Somente para o Modelo 21 e 22

					//³REGISTRO 0450 - TABELA DE INFORMACAO COMPLEMENTAR/OBSERVACAO                            ³
					//|                                                                                        |
					//|Atribui os valores do array aReg0450 para efetuar a gravacao no final do processamento  |
					//| da rotina.                                                                             |
					If lAchouCDT
						If !(cAliasCDT)->(Empty(CDT_IFCOMP))
							aInfCompl	:=	{(cAliasCDT)->CDT_IFCOMP,}
							Reg0450(@aInfCompl,@aReg0450)
						EndIf
					EndIf

					//³REGISTRO D500 - NOTA FISCAL DE SERVICO DE COMUNICACAO (MODELO 21) E NOTA FISCAL DE      |
					//|                SERVICO DE TELECOMUNICACAO (MODELO 22)                                  |
					//|                                                                                        |
					//|Funcao independ., montagem e gravacao das informacoes do registro D500               |
					RegD500(cAlias,nRelacDoc,aRegC100,aTotaliza,aCmpAntSFT,@aRegD500,nItem,lAchouSFX,lGravaD500,cSituaDoc,aInfCompl,aWizard)

					//³GRAVACAO - REGISTRO D590 - REGISTRO ANALITICO DO DOCUMENTO                              |
					If lGravaD500 .And. Len(aRegD590)>0
						GrvRegTrS(cAlias,nRelacDoc,aRegD590)

						lGrava0150 := .T.
					EndIf
					
					//³Tratamento para gerar os registros pertinentes ao perfil B, pois apesar de gerar as in- |
					//| formacoes nos arrays C500, C510 e C590, os mesmo nao sao gravados no TRB, pois servirao|
					//| de base para montar os outros registros.                                               |
					If !lGravaD500
						If cPerfil == "B" .And. cEntSai == "2" .And. !lConvC115
							//³REGISTRO D600 - CONSOLIDACAO DE NOTA FISCAL DE SERVICO DE COMUNICACAO (MODELO 21) E NOTA| 
							//|                FISCAL DE SERVICO DE TELECOMUNICACAO (MODELO 22)                        ³
							//³REGISTRO D610 - ITENS CONSOLIDADO DE NOTA FISCAL DE SERVICO DE COMUNICACAO (MODELO 21) E|
							//|                NOTA FISCAL DE SERVICO DE TELECOMUNICACAO (MODELO 22)                   ³
							//|                                                                                        |
							//|Atribui os valores nos arrays aRegD600 e aRegD610 para efetuar a gravacao no final do   |
							//| processamento da rotina.                                                               |
							lGera:=Iif(lLegisPer .And. aTpMov[nContMov]$"S",.F.,.T.)
							If lGera
								nPosD600 := D600D610(aRegD500,aPartDoc,aCmpAntSFT,@aRegD600,aRegD510,@aRegD610,lAchouSFX,aWizard)
							EndIf
							//|REGISTRO D690 - REGISTRO ANALITICO DOS DOCUMENTOS NOTA FISCAL DE SERVICO DE COMUNICACAO |
							//|                (MODELO 21) E NOTA FISCAL DE SERVICO DE TELECOMUNICACAO (MODELO 22)     ³
							//|                                                                                        |
							//|Funcao independ., montagem e gravacao das informacoes do registro D690               |
							lGera:=Iif(lLegisPer .And. aTpMov[nContMov]$"S",.F.,.T.)
							If lGera
								RegD690(aRegD590,cAlias,@aRegD690,nPosD600)
							EndIf
						ElseIf cEntSai=="2" .And. lConvC115
							//³D696 - REGISTRO ANALITICO DO DOCUMENTO (MODELOS 21 e 22 )                               | 
							//³D695 - CONSOLIDACAO DOS DOCUMENTOS NFSC ou NFST EMITIDA EM VIA UNICA (CPN. ICMS 115/03) |
							//|                                                                                        |
							//|Atribui os valores nos arrays aRegD600 e aRegD610 para efetuar a gravacao no final do   |
							//| processamento da rotina.                                                               |
							lGera:= !lLegisPer
							If lGera
								D695D696(@aRegD696,@aRegD695,lAchouSFX,aRegD590,aRegC100,aCmpAntSFT,@aRegD697,cSituaDoc)
							EndIf
						EndIf
					EndIf
				EndIf

			//³SOMENTE MODELOS:                                          ³
			//³07 - NOTA FISCAL SERVICO DE TRANSPORTE - SAIDA/ENTRADA    ³
			//³08 - CONHECIMENTO DE TRANSPORTE RODOVIARIO - SAIDA/ENTRADA³
			//³09 - CONHECIMENTO DE TRANSPORTE AQUAVIARIO - ENTRADA      ³
			//³10 - CONHECIMENTO DE TRANSPORTE AEREO - ENTRADA           ³
			//³11 - CONHECIMENTO DE TRANSPORTE FERROVIARIO - ENTRADA     ³
			//³26 -                                                      ³
			//³57 - CONHECIMENTO DE TRANSPORTE ELETRONICO                ³
			ElseIf cEspecie$"#07#08#09#10#11#26#57"
				//³As informacoes CTR e NFST necessarias para o SINTEGRA somente estao disponiveis           |
				//³ quando o TMS estiver envolvido (SAIDAS) ou ENTRADAS quando envolver aviso de recebimento.³
				If (!lIss .And. cEntSai=="1") .Or. (cEntSai=="2" .And. (lIntTMS .Or. lSpedRTMS))

					If lAchouCDT
						//|Neste ponto utilizo somente o primeiro lancamento da CDT para gerar nos|
						//| documentos que exigem somente um codigo. Por exemplo: D100            |
						While !(cAliasCDT)->(Eof()) .AND. ((cAliasCDT)->(CDT_FILIAL+CDT_TPMOV+CDT_DOC+CDT_SERIE+CDT_CLIFOR+CDT_LOJA)==cCDTChv)
							If !Empty((cAliasCDT)->CDT_IFCOMP)	//Se houver algum preenchido, devo utilizar, senao nao eh inf. complementar
								Exit
							EndIF
							(cAliasCDT)->(dbSkip())
						End
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³DBF/ADS nao tem JOIN, preciso fazer o SEEK, e a funcao Reg0450³
						//|faz automaticamente quando a descricao estah com NIL          |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !(cAliasCDT)->(Eof())
							aInfCompl	:=	{(cAliasCDT)->CDT_IFCOMP,}
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³REGISTRO 0450 - TABELA DE INFORMACAO COMPLEMENTAR/OBSERVACAO                            ³
							//|                                                                                        |
							//|Atribui os valores do array aReg0450 para efetuar a gravacao no final do processamento  |
							//| da rotina.                                                                             |
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							Reg0450(aInfCompl,@aReg0450)
						EndIf
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³REGISTRO D100:                                                                          ³
					//³07 - NOTA FISCAL SERVICO DE TRANSPORTE                                                  ³
					//³08 - CONHECIMENTO DE TRANSPORTE RODOVIARIO                                              ³
					//³09 - CONHECIMENTO DE TRANSPORTE AQUAVIARIO                                              ³
					//³10 - CONHECIMENTO DE TRANSPORTE AEREO                                                   ³
					//³11 - CONHECIMENTO DE TRANSPORTE FERROVIARIO                                             ³
					//³26 - CONHECIMENTO DE TRANSPORTE FERROVIARIO                                             ³
					//³27 - NF SERVICO DE TRANSPORTE FERROVIARIO                                               ³
					//³57 - CONHECIMENTO DE TRANSPORTE ELETRONICO                                              ³
					//|                                                                                        |
					//|Funcao independ., montagem e gravacao das informacoes do registro D100               |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lGera:=Iif(lLegisPer .And. aTpMov[nContMov]$"S",.F.,.T.)
					If lGera
						RegD100(cAlias,cEntSai,aPartDoc,aTotaliza,nRelacDoc,cEspecie,aCmpAntSFT,cSituaDoc,;
							@lGrava0150,cOpSemF,lSpedRTms,lIntTMS,aInfCompl,cAliasSFT,@aReg0450,cVersao)

						//Grava registro C101 para informações do FECP
						If cEspecie == '57' .AND. !cSituaDoc $ "02/03/04/05" .AND.	nDifalDest+nDifalOrig+nDifalFEcp > 0
							GrvRegTrS(cAlias,nRelacDoc,{{'D101',nDifalFEcp,nDifalDest,nDifalOrig}})
						EndIF
					
					EndIf
					
					If cEspecie == "57" .And. lAchouCDC
						SpdGnreDoc(@aIcmPago, cAliasSF6, cAliasCDC, cCDCChv)
					EndIf					

					If cEntSai=="2" .And. ("1"$aWizard[1][7]) // Somente o prestador deve informar estes registros

						If cEspecie$"08#09#10#11#26#27#57" .And. !cSituaDoc$"02#03"  //Cancelado

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Para TOP, nao uso o posicionamento da tabela SA1/SA2, pois jah estah na query³
							//³ principal da tabela SFT e nao tem problema desposicionar                    ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !lTop
								aAreaSA	:=	(cAlsSA)->(GetArea())
							EndIf

							//-- Ponto de entrada para informar os participantes para clientes que nao usam SIGATMS.
							If aExistBloc[06] 
								aRetPart := ExecBlock("SPEDPTMS",.F.,.F.,{cAliasSFT,aCmpAntSFT})
								If ValType(aRetPart) == "A" .And. Len(aRetPart) > 0
									If ValType(aRetPart[1]) <> "A"
										aRetAux := aClone(aRetPart)
										aRetPart := {aRetAux}
									EndIf
									For nX := 1 To Len(aRetPart)
										SDPF150175(@aReg0150,aRetPart[nX],cAlias,aWizard,aExistBloc)
									Next
								EndIf
							EndIf

							//³Remetente do conhecimento³
							If (cAlsSA)->(MsSeek(xFilial(cAlsSA)+DT6->(DT6_CLIREM+DT6_LOJREM)))
								If Upper(&(cAlsSA+"->"+cCmpEst))=="EX"
									cCdMunOri := TMSCodMun(DT6->DT6_CDRCAL)
								Else
									cCdMunOri := TMSCodMun(DT6->DT6_CDRORI)
								EndIf
								aPartREM := InfPartDoc(cAlsSA)
							Else
								aPartREM := aClone(aPartDoc)
							EndIf

							//³Destinatario do conhecimento³
							If (cAlsSA)->(MsSeek(xFilial(cAlsSA)+DT6->(DT6_CLIDES+DT6_LOJDES)))
								If Upper(&(cAlsSA+"->"+cCmpEst))=="EX"
									cCdMunDes := TMSCodMun(DT6->DT6_CDRCAL)
								Else
									cCdMunDes := TMSCodMun(DT6->DT6_CDRDES)
								EndIf
								aPartDES := InfPartDoc(cAlsSA)
							Else
								aPartDES := aClone(aPartDoc)
							EndIf

							//³Consignatario do conhecimento³
							If (cAlsSA)->(MsSeek(xFilial(cAlsSA)+DT6->(DT6_CLICON+DT6_LOJCON)))
								aPartCON := InfPartDoc(cAlsSA)
							EndIf

							//³Despachante da mercadoria³
							If (cAlsSA)->(MsSeek(xFilial(cAlsSA)+DT6->(DT6_CLIDPC+DT6_LOJDPC)))
								aPartDPC := InfPartDoc(cAlsSA)
							EndIf

							If cPerfil <> "C"
								If cEspecie$"08"
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³REGISTRO D130 - COMPLEMENTO DO CONHECIMENTO RODOVIARIO (MODELO 08)                      ³
									//|                                                                                        |
									//|Funcao independ., montagem e gravacao das informacoes do registro D130               |
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									lGera:=Iif(lLegisPer .And. aTpMov[nContMov]$"S",.F.,.T.)
									If lGera
										RegD130(cAlias,nRelacDoc,lAchouDA3,cSituaDoc,aMVCOMPFRT,lSpedRTms,lAchouDT8,cAliasDT8,;
											cCdMunOri,aPartREM,cCdMunDes,aPartDES,aPartCON,aPartDPC,@aReg0150,aWizard,cAliasSFT,aCmpAntSFT)
									EndIf
								ElseIf cEspecie$"09"
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³REGISTRO D140 - COMPLEMENTO DO CONHECIMENTO AQUAVIARIO (MODELO 08)                      ³
									//|                                                                                        |
									//|Funcao independ., montagem e gravacao das informacoes do registro D140               |
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									lGera:=Iif(lLegisPer .And. aTpMov[nContMov]$"S",.F.,.T.)
									If lGera
										RegD140(cAlias,nRelacDoc,lSpedRTms,lAchouDA3,lAchouDUD,lAchouDT8,cAliasDT8,aPartREM,aPartDES,aPartCON,cAliasSFT,aCmpAntSFT)
									EndIf
								ElseIf cEspecie$"10"
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³REGISTRO D150 - COMPLEMENTO DO CONHECIMENTO AEREO (MODELO 08)                           ³
									//|                                                                                        |
									//|Funcao independ., montagem e gravacao das informacoes do registro D150               |
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									lGera:=Iif(lLegisPer .And. aTpMov[nContMov]$"S",.F.,.T.)
									If lGera
										RegD150(cAlias,nRelacDoc,lSpedRTms,lAchouDA3,lAchouDUD,lAchouDT8,cAliasDT8,aPartREM,aPartDES,cAliasSFT,aCmpAntSFT)
									EndIf
								EndIf

								If cEspecie <>"57"
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³REGISTRO D160 - CARGA TRANSPORTADA (MODELO 08)                                          ³
									//|                                                                                        |
									//|Funcao independ., montagem e gravacao das informacoes do registro D160               |
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									lGera:=Iif(lLegisPer .And. aTpMov[nContMov]$"S",.F.,.T.)
									If lGera
										RegD160(cAlias,nRelacDoc,cEspecie,lSpedRTms,aPartREM,cCdMunOri,aPartDES,cCdMunDes,cAliasSFT,aCmpAntSFT)

										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³Montagem dos registro para o perfil "A", o "B" nao os exige                             ³
										//|                                                                                        |
										//³REGISTRO D161 - LOCAL DE COLETA ENTREGA                                                 ³
										//³REGISTRO D162 - IDENTIFICACAO DOS DOCUMENTOS FISCAIS                                    ³
										//|                                                                                        |
										//|Funcao independ., montagem e gravacao das informacoes dos registros D161 e d162      |
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										D161D162(cAlias,nRelacDoc,cEspecie,aCmpAntSFT,cMvD162,lSpedRTms,aPartREM,cCdMunOri,aPartDES,cCdMunDes,cAliasSFT,cPerfil,;
										lAchouDT5,cAliasDT5,lAchouDUL,cAliasDUL,lAchouDTC,cAliasDTC,lAchou2DUL,cDTCChv)            
									EndIf
								EndIf
							EndIf

							If !lTop
								RestArea(aAreaSA)
							EndIf
						EndIf
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³REGISTRO D190 - REGISTRO ANALITICO DO DOCUMENTO                                         ³
					//|                                                                                        |
					//|Funcao de gravacao das informacoes do registro D190                                     |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !(cSituaDoc$"02#03")
						GrvRegTrS(cAlias,nRelacDoc,aRegD190)
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³REGISTRO D195 - OBSERVACOES DO LANCAMENTO FISCAL 				                       ³
					//³REGISTRO D197 - OUTRAS OBRIGACOES TRIBUTARIAS, AJUSTES E INFORMACOES DE VALORES         ³
					//|                PROVENIENTES DE DOCUMENTO FISCAL                                        |
					//|                                                                                        |
					//|Funca independ., gera a estrutura e efetua a gravacao no TRB                         |
					//|  documento fiscal                                                                      |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lGera:=Iif(lLegisPer .And. aTpMov[nContMov]$"S",.F.,.T.)
					If lGera
						If cVersao >="006" .And. Len(aLanCDA) > 0 .Or. Len(aLancFis) > 0
							D195D197(cAlias,nRelacDoc,aLanCDA,@aReg0460,aCmpAntSFT,cEspecie,aLancFis,lLegisPer)
						EndIf
					EndIf
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³GRAVACAO REGISTRO 0150 - TABELA DE CADASTRO DE PARTICIPANTES                            ³
			//³GRAVACAO REGISTRO 0175 - ALTERACAO DA TABELA DE CADASTRO DE PARTICIPANTE                ³
			//|                                                                                        |
			//|Funcao de gravacao das informacoes dos registros 0150 e 0175                            |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lGrava0150
				SDPF150175(@aReg0150,aPartDoc,cAlias,aWizard,aExistBloc)
			EndIf

		EndDo	//ENDDO da NF

		#IFDEF TOP
			If (TcSrvType ()<>"AS/400")
				DbSelectArea (cAliasSFT)
				(cAliasSFT)->(DbCloseArea())
			Else
		#ENDIF
				RetIndex("SFT")
				FErase(cIndex+OrdBagExt())
		#IFDEF TOP
			EndIf
		#ENDIF

		cAliasSFT	:=	"SFT"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³No caso de o objeto oProcess existir, significa que a nova barra  ³
		//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
		//| portanto deve ser efetuado os controles para demonstrar o        |
		//| resultado do processamento.                                      |
		//|                                                                  |
		//³Tratamento para cancelamento de processamento                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        //LGS#20200131 - Adequação para release 12.1.25 e posteriores
        //If Type("oProcess")=="O"
        If _lValPro
			//³Controle do cancelamento da rotina³
			If oProcess:Cancel()
				Exit
			EndIf
		Else
			//³Controle do cancelamento da rotina³
			If Interrupcao(@lEnd)
				Exit
			EndIf
		EndIf
	Next nContMov

	//³Chama a função para processar os registros de PCL³
	lGera:=  !lLegisPer
	If lGera
		If lPCLLOJA .AND. "S"$aReg1010[1][4]
			SPEDPCL(@aReg1300,@aReg1310,@aReg1320,@aReg1350,@aReg1360,@aReg1370,@aReg0190,@aReg0200,@aReg0220,cAlias,dDataDe,dDataAte,aWizard)
		EndIF
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³No caso de o objeto oProcess existir, significa que a nova barra  ³
	//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
	//| portanto deve ser efetuado os controles para demonstrar o        |
	//| resultado do processamento.                                      |
	//|                                                                  |
	//³Tratamento para cancelamento de processamento                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    //LGS#20200131 - Adequação para release 12.1.25 e posteriores
    //If Type("oProcess")=="O"
    If _lValPro
		//³Controle do cancelamento da rotina³
		If oProcess:Cancel()
			Exit
		EndIf
	Else
		//³Controle do cancelamento da rotina³
		If Interrupcao(@lEnd)
			Exit
		EndIf
	EndIf

	SM0->(DbSkip ())
EndDo	//ENDDO da SM0 para a mesma EMPRESA

//³Restauro a area do SM0³

RestArea(aAreaSM0)
cFilAnt := FWGETCODFILIAL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³No caso de o objeto oProcess existir, significa que a nova barra  ³
//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
//| portanto deve ser efetuado os controles para demonstrar o        |
//| resultado do processamento.                                      |
//|                                                                  |
//³Tratamento para cancelamento de processamento                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("oProcess")=="O"
	//³Controle do cancelamento da rotina³
	If oProcess:Cancel()
		//³Funcao de fechamento do TRB criado³
		SPDGerTrb(2,@aArq,@cAlias)
		Return
	EndIf
Else
	//³Controle do cancelamento da rotina³
	If Interrupcao(@lEnd)
		//³Funcao de fechamento do TRB criado³
		SPDGerTrb(2,@aArq,@cAlias)
		Return
	EndIf
EndIf

//³Processamento das informacoes do BLOCO E - APURACAO DE ICMS E DO IPI³
BlocoE(lTabComp,aWizard,cFilDe,cFilAte,cAlias,cMVEstado,lTop,cMVSUBTRIB,aRegE510,@oProcess,aVlrMovST,aIcmPago,aLanCDA,@aLanCDA2,cMVSTNIEUF,lOldLan, @aReg0200, @aReg0190, @aReg0220,aInfE313 ,lDifal,aMovSemIe)

//³Processamento das subApurações do ICMS pelo registro 1900 e filhos ³
If !cMVEstado$"RS"
	aMVRLCSPD:= &(aSPDSX6[MV_RLCSPD])
	For nX := 1 to Len(aMVRLCSPD)
		Aadd(aLiv1900,{aMVRLCSPD[nX,1],aMVRLCSPD[nX,2] , aMVRLCSPD[nX,3]})    
	Next nX
	If !Empty(aLiv1900)
		Grupo1900(lTabComp,aWizard,cFilDe,cFilAte,cAlias,cMVEstado,lTop,@oProcess,aLanCDA,@aLanCDA2,aLiv1900,lOldLan)
	Endif
EndIf

//³Geração e Gravação do Bloco G CIAP³
If cVersao >= "004"
	U_BRBlocoG(cAlias,lTop,aWizard,@aReg0200,@aReg0190,@aReg0220,@aReg0150,cFilDe,cFilAte,aLisFil,bWhileSM0,@lEnd,nCtdFil,nCountTot,@nRegsProc,@oProcess)
EndIf

//³REGISTROS DE EXPORTACAO ³
If lSigaEEC .And. "S"$aReg1010[1][2]
	If lEECSPED
		Reg1100Av(cAlias,@aReg0200,@aReg0190,@aReg0220,@aReg0150,aWizard,cFilDe,cFilAte,aLisFil,@oProcess,nCtdFil,@lEnd,bWhileSM0,nCountTot,@nRegsProc)
	Else
		Reg1100Spd(cAlias,@aReg0200,@aReg0190,@aReg0220,@aReg0150,aWizard,cFilDe,cFilAte,aLisFil,@oProcess,nCtdFil,@lEnd,bWhileSM0,nCountTot,@nRegsProc)		
	EndIf
ElseIf lTabComp .And. "S"$aReg1010[1][2]
	Reg1100Spd(cAlias,@aReg0200,@aReg0190,@aReg0220,@aReg0150,aWizard,cFilDe,cFilAte,aLisFil,@oProcess,nCtdFil,@lEnd,bWhileSM0,nCountTot,@nRegsProc)
EndIf

//³REGISTROS DE CONTROLE DE CRÉDITO DE ICMS ³
If lTabCE5 .And. "S"$aReg1010[1][3]
	R12001210(bWhileSM0,cFilDe,dDataDe,dDataAte,cAlias,aWizard,oProcess,nRegsProc,nCtdFil,aLisFil,nCountTot,@lEnd,cFilAte)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO H005 - TOTAIS DO  INVENTARIO³
//³GRAVACAO - REGISTRO H010 - INVENTARIO           |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If "1"$aWizard[1][6]
	SPDBlocoH(cAlias,bWhileSM0,aWizard,cFilDe,aLisFil,aReg0190,@aReg0200,@aReg0220,@aReg0150,@oProcess,nCtdFil,@lEnd,cFilAte)
EndIf

//Bloco K
IF aWizard[1][16]=="1-Sim" .Or. aWizard[1][16]=="3-Sim - K200/K280"
    BlocoK(cAlias, bWhileSM0,aWizard,cFilDe,cFilAte,aLisFil, aReg0150,aReg0200,aReg0220,aReg0190, aReg0150, lConcFil, @aReg0210, oProcess, aWizard[1][16]=="3-Sim - K200/K280")
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³PE que possibilita a geracao dos registros 1300, 1310, 1320, 1350, 1360, e 1370  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lPCLLOJA .AND. aExistBloc[07] .And. "S"$aReg1010[1][4]
	ExecBlock("SPED1300", .F., .F., {cAlias,dDataDe,dDataAte,aReg0200,aReg0190})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³PE que possibilita a geracao dos registros 1390, 1391 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cVersao >= "006" .And. aExistBloc[08] .And. "S"$aReg1010[1][5]
	ExecBlock("SPED1390", .F., .F., {cAlias,dDataDe,dDataAte})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO 1700 - Registro Doc Fiscais Utilizados       ³
//³GRAVACAO 1710 - Registro Doc Fiscais Canc/Inutilizados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aReg1700) > 0
	GrRegDep(cAlias,aReg1700,aReg1710,.F.,,,,.F.)
	//Zera variaveis para desalocar memoria
	aSize(aReg1700, 0)
	aSize(aReg1710, 0)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gravacao do REGISTRO 0200 - TABELA DE IDENTIFICACAO DO ITEM³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GrRegDep(cAlias,aReg0200,aReg0205,.F.,,,,.T.)
GrRegDep(cAlias,aReg0200,aReg0206,.T.,,,,.T.)
GrRegDep(cAlias,aReg0200,aReg0210,.T.,,,,.T.)
GrRegDep(cAlias,aReg0200,aReg0220,.T.,,,,.T.)
//Zera variaveis para desalocar memoria
aSize(aReg0200, 0)
aSize(aReg0220, 0)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gravacao do REGISTRO 0400 - TABELA DE NATUREZA DA OPERACAO/PRESTACAO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GrvRegTrS (cAlias,, aReg0400)
//Zera variaveis para desalocar memoria
aSize(aReg0400, 0)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gravacao do REGISTRO 0450 - TABELA DE INFORMACAO COMPLEMENTAR ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GrvRegTrS (cAlias,,aReg0450)
//Zera variaveis para desalocar memoria
aSize(aReg0450, 0)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gravacao do REGISTRO 0460 - TABELA DE OBSERVACOES             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GrvRegTrS (cAlias,,aReg0460)
//Zera variaveis para desalocar memoria
aSize(aReg0460, 0)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³REGISTRO C300 - RESUMO DIARIO DAS NOTAS FISCAIS DE VENDA A CONSUMIDOR(MODELO 02)                      ³
//³REGISTRO C320 - REGISTRO ANALITICO DO RESUMO DIARIO DAS NOTAS FISCAIS DE VENDA A CONSUMIDOR(MODELO 02)³
//³REGISTRO C321 - ITENS DO RESUMO DIARIO DOS DOCUMENTOS(MODELO 02)                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SPEDRegs(cAlias,{aRegC300,aRegC320,aRegC321})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³REGISTRO C310 - DOCUMENTOS CANCELADOS(MODELO 02)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GrRegDep(cAlias,aRegC300,aRegC310,.T.)
//Zera variaveis para desalocar memoria
aSize(aRegC300, 0)
aSize(aRegC310, 0)
aSize(aRegC320, 0)
aSize(aRegC321, 0)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gravacao da hierarquia dos registros tipo C400   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GrRegDep(cAlias,aRegC400,aRegC405, .F. , 405, Nil, Nil, !lTop )
GrRegDep(cAlias,aRegC405,aRegC410, .T.,NIL,.F.)
GrRegDep(cAlias,aRegC405,aRegC420, .T. , 420 )
GrRegDep(cAlias,aRegC420,aRegC425, .T.)
//Somente grava aqui no TRB os registros C460 e C470 caso nao seja ambiente TOP, pois em ambiente Top Connect jah foram carregados dentro de sua funcao de processamento em MultiThread
If !lTop
	GrRegDep(cAlias,aRegC405,aRegC460, .T.,,,,.F.)
	GrRegDep(cAlias,aRegC460,aRegC470, .T.)
EndIf
GrRegDep(cAlias,aRegC405,aRegC490, .T.)
GrRegDep(cAlias,aRegC400,aRegC495, .T.)
//Zera variaveis para desalocar memoria
aSize(aRegC400, 0)
aSize(aRegC405, 0)
aSize(aRegC410, 0)
aSize(aRegC420, 0)
aSize(aRegC425, 0)
aSize(aRegC460, 0)
aSize(aRegC470, 0)
aSize(aRegC490, 0)
aSize(aRegC495, 0)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|                              GRAVACAO DOS REGISTROS :                                  |
//|                                                                                        |
//³REGISTRO C600 - CONSOLIDACAO DIARIA DE NOTAS FISCAIS/CONTA DE ENERGIA ELETRICA          |
//|                (MODELO 06), NOTA FISCAL/CONTA DE FORNECIMENTO D'AGUA CANALIZADA        |
//|                (CODIGO 29) E NOTA FISCAL/CONTA DE FORNECIMENTO DE GAS (CODIGO 28)      |
//|                                                                                        |
//³REGISTRO C601 - DOCUMENTOS CANCELADOS - CONSOLIDACAO DIARIA DE NOTAS FISCAIS/CONTA DE   |
//|                ENERGIA ELETRICA (MODELO 06), NOTA FISCAL/CONTA DE FORNECIMENTO D'AGUA  |
//|                CANALIZADA (CODIGO 29) E NOTA FISCAL/CONTA DE FORNECIMENTO DE GAS       |
//|                (CODIGO 28)                                                             |
//|                                                                                        |
//³REGISTRO C610 - ITENS DO DOCUMENTO CONSOLIDADO (NOTAS FISCAIS/CONTA DE ENERGIA ELETRICA |
//|                (MODELO 06), NOTA FISCAL/CONTA DE FORNECIMENTO D'AGUA CANALIZADA        |
//|                (CODIGO 29) E NOTA FISCAL/CONTA DE FORNECIMENTO DE GAS (CODIGO 28)      |
//|                                                                                        |
//³REGISTRO C690 - REGISTRO ANALITICO  DOS DOCUMENTOS (NOTAS FISCAIS/CONTA DE ENERGIA ELE- |
//|                TRICA (MODELO 06), NOTA FISCAL/CONTA DE FORNECIMENTO D'AGUA CANALIZADA  |
//|                (CODIGO 29) E NOTA FISCAL/CONTA DE FORNECIMENTO DE GAS (CODIGO 28)      |
//|                                                                                        |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GrRegDep(cAlias, aRegC600, aRegC601)
GrRegDep(cAlias, aRegC600, aRegC610, .T.)
GrRegDep(cAlias, aRegC600, aRegC690, .T.)
//Zera variaveis para desalocar memoria
aSize(aRegC600, 0)
aSize(aRegC601, 0)
aSize(aRegC610, 0)
aSize(aRegC690, 0)

//³Gravacao do REGISTRO C700, C790 e C791 ³
If Len(aRegC790)>0
	GrRegDep(cAlias,aRegC700,aRegC790)
EndIf
If Len(aRegC791)>0
	GrRegDep(cAlias, aRegC790, aRegC791, .T.)
EndIf
//Zera variaveis para desalocar memoria
aSize(aRegC700, 0)
aSize(aRegC790, 0)
aSize(aRegC791, 0)

//³Gravacao do REGISTRO C800, C850, C860, C890 ³
If Len(aRegC800)>0
	GrRegDep(cAlias,aRegC800,aRegC850)
EndIf
If Len(aRegC860)>0
	GrRegDep(cAlias,aRegC860,aRegC890)
EndIf
//Zera variaveis para desalocar memoria
aSize(aRegC800, 0)
aSize(aRegC850, 0)
aSize(aRegC860, 0)
aSize(aRegC890, 0)    

If lBuild

    FreeObj(oHash0200)

EndIf 

//³Gravacao do REGISTRO D300, D301 e D310  ³
GrRegDep(cAlias,aRegD300,aRegD301)
GrRegDep(cAlias,aRegD300,aRegD310,.T.)

//³Gravacao do REGISTRO D695, D696 e D697  ³
If Len(aRegD695)>0
	GrRegDep(cAlias,aRegD695,aRegD696)
EndIf
If Len(aRegD697)>0
	GrRegDep(cAlias, aRegD696, aRegD697, .T.)
EndIf
//Zera variaveis para desalocar memoria
aSize(aRegD695, 0)
aSize(aRegD696, 0)
aSize(aRegD697, 0)

//³GRAVACAO REGISTRO D600 - CONSOLIDACAO DE NOTA FISCAL DE SERVICO DE COMUNICACAO (MODELO 21)|
//|                  E NOTA FISCAL DE SERVICO DE TELECOMUNICACAO (MODELO 22)                 ³
//³GRAVACAO REGISTRO D610 - ITENS CONSOLIDADO DE NOTA FISCAL DE SERVICO DE COMUNICACAO       |
//|                     (MODELO 21) E NOTA FISCAL DE SERVICO DE TELECOMUNICACAO (MODELO 22)  ³
aSort(aRegD610,,,{|aX, aY| Str( aX[1],20 )+PadL( aX[3],10 )<Str( aY[1],20 )+PadL( aY[3],10 )})	//Ordenando o array filho pelo indice+item
GrRegDep(cAlias,aRegD600,aRegD610)
GrRegDep(cAlias,aRegD600,aRegD690,.T.)
//Zera variaveis para desalocar memoria
aSize(aRegD600, 0)
aSize(aRegD610, 0)
aSize(aRegD690, 0)

//³Gravação do Registro 1300/1310/1320/1350/1360/1370³
SPEDRegs(cAlias,{aReg1300,aReg1310,aReg1320})
SPEDRegs(cAlias,{aReg1350,aReg1360,{aReg1370,1}})
//Zera variaveis para desalocar memoria
aSize(aReg1300, 0)
aSize(aReg1310, 0)
aSize(aReg1320, 0)
aSize(aReg1350, 0)
aSize(aReg1360, 0)
aSize(aReg1370, 0)

//³Gravacao do REGISTRO 1400 - INFORMACOES SOBRE VALORES AGREGADOS³
If aExistBloc[26]
If GetApoInfo("SPEDXFUN.PRW")[4] >= CTOD("31/03/2016") .And. cMVEstado == "MG"
	If "1" $ aWizard[4,10] .And. Month(CTOD(Substr(aWizard[1,2],7,2)+"/"+Substr(aWizard[1,2],5,2)+"/"+Substr(aWizard[1,2],1,4))) == 12
		Reg1400Ano(@aReg1400,cProd,cAliasSFT,cAliasSF4,@lGr2001400,cMVEstado,aWizard)
	Endif
Endif
	aReg1400 := ExecBlock("SPED1400",.F.,.F.,{dDataDe,dDataAte,cFilDe,cFilAte,aLisFil,aReg1400})
	If Valtype(aReg1400) == "A"
		For nX := 1 to Len(aReg1400)
			If aReg1400[nX][4]>0
				GrvRegTrS (cAlias,,{aReg1400[nX]})
			Endif
		Next nX
	Endif
Else
	For nX := 1 to Len(aReg1400)
		If aReg1400[nX][4]>0
			GrvRegTrS (cAlias,,{aReg1400[nX]})
		Endif
	Next nX
Endif
//Zera variaveis para desalocar memoria
aSize(aReg1400, 0)

//³Chamada para o PE SPEDREGD, que pode ser utilizado para manipular o arquivo de ³
//³  trabalho gerado pela rotina                                                  ³
If aExistBloc[09] 
	Execblock("SPEDREGD", .F., .F., {cAlias,aLisFil})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³No caso de o objeto oProcess existir, significa que a nova barra  ³
//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
//| portanto deve ser efetuado os controles para demonstrar o        |
//| resultado do processamento.                                      |
//|                                                                  |
//³Tratamento para cancelamento de processamento                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("oProcess")=="O"
	//³Controle do cancelamento da rotina³
	If oProcess:Cancel()
		//³Funcao de fechamento do TRB criado³
		SPDGerTrb(2,@aArq,@cAlias)
		MsgAlert(OemToAnsi(STR0003)) //"Não foi possível gerar o arquivo!"

		Return
	EndIf
Else
	//³Controle do cancelamento da rotina³
	If Interrupcao(@lEnd)
		//³Funcao de fechamento do TRB criado³
		SPDGerTrb(2,@aArq,@cAlias)
		MsgAlert(OemToAnsi(STR0003)) //"Não foi possível gerar o arquivo!"

		Return
	EndIf
EndIf

//³Gravacao dos Totais Das Operacoes com Cartao de Credito E/OU Debito ³
If "S"$aReg1010[1][8]
	GrReg1600(cAlias,aReg1600,dDataDe,dDataAte,@aReg0150,aWizard)
Endif
//Zera variaveis para desalocar memoria
aSize(aReg0150, 0)
aSize(aReg1600, 0)

If lRefazInd //Refaz o indice, devido novos registros terem sido incluidos no TRB atraves de MultiThread (REG C460 e C470)
	SPDGerTrb(0,aArq,@cAlias)
EndIf

//³Gravacao dos indicadores de movimento dos registros ³
SpdGrIndM(cAlias,aWizard)

//³Funcao responsave geracao meio-magnetico com base no TRB³
OrgTxt(cAlias,cFileDest,@oProcess,@lEnd,lTop,@nRetCpy)

//³Funcao de fechamento do TRB criado³
SPDGerTrb(2,@aArq,@cAlias)	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para avisar ao usuario um dos possiveis erros quanto ao registro E210 que serah mais comum conforme regra     ³
//³  definida na geracao do arquivo magnetico.                                                                              ³
//³                                                                                                                         ³
//³Para as notas fiscais de entrada tipo devolucao, apos retorno da SEFAZ e analise das regras do layout e validacao do PVA,³
//³  chegou-se a seguinte conclusao:                                                                                        ³
//³                                                                                                                         ³
//³Para as notas fiscais de entrada tipo devolucao, o valor de ICMS/ST somente deverah ser considerado nos registro C100,   ³
//³  C170, C190 e E210, quando o contribuinte tiver IE no estado emitente do documento (FT_ESTADO estah contido no          ³
//³  SUBTRIB), caso contrario deverah levar ZERO nos respectivos campos, pois a NF original, a de saida, teve o ICMS/ST     ³
//³  recolhido antecipadamente, nao tendo como compensar o credito. Quando houver IE no estado do emitente, segue o fluxo   ³
//³  normal, pois como o valor do ICMS/ST serah recolhido via Auracao, terah com compensar o debito pelo credito.           ³
//³                                                                                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLogCfop
	xMagHelpFis("Atenção...",cAlertCfop,cSolucCfop)
EndIf

//³Mensgem de final de processamento da rotina³
If (File(cFileDest) .OR. nRetCpy == 0 )
	GetRemoteType( @cLib )
	QOut( cLib )

	If !lNotaC350 .Or. !lNotaC300
		MsgInfo(STR0032+; //"Existe(m) Nota(s) Fiscai(s) com numeração maior do que a permitida pelo " 
		        STR0033+; //"layout para geração dos registros C300 e C350, serão consideradas apenas os últimos "
		        STR0034)  //"6 dígitos para geração destes registros!"
	EndIf

	If !lNotaD300
		MsgInfo(STR0032+;
		        STR0035+; //"layout para geração dos registros D300 e D301, serão consideradas apenas os últimos"
		        STR0034)
	EndIf
    IF	"HTML" $ cLib
		MsgInfo(OemToAnsi(STR0001+" "+STR0002)) //"Arquivo gerado com sucesso!"
	ELSE
		MsgInfo(OemToAnsi(STR0001+cFileDest+STR0002)) //"Arquivo "###" gerado com sucesso!"
	ENDIF
Else
	MsgAlert(OemToAnsi(STR0003)) //"Não foi possível gerar o arquivo!"
EndIf

Return (.T.)
/*
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Reg0000   | Autor ³Gustavo G. Rueda              ³ Data ³03.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ABERTURA DO ARQUIVO DIGITAL E IDENTIFICACAO DO CONTRIBUINTE        ³±±
±±³          ³- Geracao do Registro 0000 e gravacao do mesmo                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpL1 := Reg0000(aWizard,cAlias,dDataDe,dDataAte)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> informacoes preenchidas no Wizard                       ³±±
±±³          ³cAlias -> Alias do TRB que recebera as informacoes                 ³±±
±±³          ³dDataDe -> Data incial do periodo de apuracao.                     ³±±
±±³          ³dDataAte -> Data final do periodo de apuracao.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 - Sempre .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
*/
Static Function Reg0000(aWizard, cAlias, dDataDe, dDataAte)
Local	aReg	:= {}
Local	lRet	:= .T.
Local	nPos	:=	0

//LAYOUT 2010       

Do Case
	Case(Year(dDataDe)<=2008)
		cVersao := "001"
	Case(Year(dDataDe)==2009)
		cVersao := "002"
	Case(Year(dDataDe)==2010)
		cVersao := "003"
	Case(Year(dDataDe)==2011)
		cVersao := "004"
	Case(Year(dDataDe)==2012)
		If DTOS(dDataDe) <= "20120630"
			cVersao := "005"
		Else
			cVersao := "006"
		Endif
	Case(Year(dDataDe)==2013)
		cVersao	:= "007" 
	Case(Year(dDataDe)==2014)
		cVersao := "008"	 
	Case(Year(dDataDe)==2015)
		cVersao := "009"
	Case(Year(dDataDe)==2016)	
		cVersao := "010"	   
	Case(Year(dDataDe)>=2017)  
        cVersao := "011" 	    
EndCase

aAdd(aReg, {})
nPos	:=	Len (aReg)
aAdd (aReg[nPos], "0000")													//01 - REG
aAdd (aReg[nPos], cVersao)													//02 - COD_VER
aAdd (aReg[nPos], SubStr (aWizard[2][1], 1, 1))				    	    	//03 - COD_FIN
aAdd (aReg[nPos], dDataDe)										   			//04 - DT_INI
aAdd (aReg[nPos], dDataAte)										   			//05 - DT_FIM
aAdd (aReg[nPos], SM0->M0_NOMECOM)											//06 - NOME
aAdd (aReg[nPos], SPEDConType(SPEDVldIE(Iif (RetPessoa(SM0->M0_CGC) == "J", SM0->M0_CGC, ""))))	//07 - CNPJ
aAdd (aReg[nPos], SPEDConType(SPEDVldIE(Iif (RetPessoa(SM0->M0_CGC) == "F", SM0->M0_CGC, ""))))	//08 - CPF
aAdd (aReg[nPos], SM0->M0_ESTENT)											//09 - UF
aAdd (aReg[nPos], SPEDConType(SPEDVldIE(SM0->M0_INSC,.F.,.F.)))							//10 - IE
aAdd (aReg[nPos], Iif (Upper(SM0->M0_ESTENT) == "EX","",Iif(Len(Alltrim(SM0->M0_CODMUN))<=5,UfCodIBGE(SM0->M0_ESTENT),"")+SM0->M0_CODMUN))	//10 - COD_MUN
aAdd (aReg[nPos], SPEDConType(SM0->M0_INSCM))									//12 - IM
aAdd (aReg[nPos], SPEDConType(SM0->M0_INS_SUF))								//13 - SUFRAMA
aAdd (aReg[nPos], SubStr (aWizard[2][4], 1, 1))							//14 - IND_PERFIL
aAdd (aReg[nPos], SubStr (aWizard[2][5], 1, 1))							//15 - IND_ATIV

GrvRegTrS (cAlias,, aReg)
Return (lRet)
/*
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Reg0005   | Autor ³Gustavo G. Rueda              ³ Data ³03.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³DADOS COMPLEMENTARES DO CONTRIBUINTE                               ³±±
±±³          ³- Geracao do Registro 0000 e gravacao do mesmo                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpL1 := Reg0005 (aWizard, cAlias)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> informacoes preenchidas no Wizard                       ³±±
±±³          ³cAlias -> Alias do TRB que recebera as informacoes                 ³±±
±±³          ³aSM0 -> Array contem informacoes da Tabela SM0 e XX8               ³±±
±±³          ³lIsBlind -> Determina se a conexao efetuada com o Protheus nao 	 ³±±
±±³          ³			  possui interface com o usuário.               		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 - Sempre .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
*/
Static Function Reg0005 (aWizard, cAlias, aSM0, lIsBlind)
Local	aReg		:=	{}
Local	lRet		:=	.T.
Local	nPos		:=	0
Local	cTel		:=	""
Local	cFax		:=	""
Local 	lUsaXX8		:=	aSPDSX6[MV_USAXX8] //Parametro define se as informacoes da empresa virao do XX8
Local	cNomeFant	:=	""
Local	cRetPE		:=	""

If Len(SM0->M0_CODFIL) > 2
	If lUsaXX8	//Tabela XX8
		aEval(aSM0,{|x| cNomeFant := Iif(x[SM0_GRPEMP]==cEmpAnt .And. x[SM0_CODFIL]==cFilAnt .And. x[SM0_USEROK], x[SM0_NOMRED], cNomeFant)})	
	Else
		cNomeFant := SM0->M0_FILIAL
	EndIf
Else
	cNomeFant := SM0->M0_NOME
EndIf

If aExistBloc[25]
	//-- PE usado para alterar campo 02-FANTASIA
	cRetPE := ExecBlock("SPEDFANT",.F.,.F.)
	If  ValType(cRetPE) == "C"
		cNomeFant := cRetPE
	EndIf
EndIf

aAdd(aReg, {})
nPos	:=	Len(aReg)
aAdd (aReg[nPos], "0005")																										//01 - REG
aAdd (aReg[nPos], cNomeFant)																									//02 - FANTASIA
aAdd (aReg[nPos], SPEDConType(SM0->M0_CEPENT))																				  	//03 - CEP
aAdd (aReg[nPos], SPEDConType(FisGetEnd(SM0->M0_ENDENT,SM0->M0_ESTENT)[1]))				 									//04 - END
aAdd (aReg[nPos], Iif(!Empty(FisGetEnd(SM0->M0_ENDENT,SM0->M0_ESTENT)[2]),FisGetEnd(SM0->M0_ENDENT,SM0->M0_ESTENT)[3],"SN"))	//05 - NUM
aAdd (aReg[nPos], SPEDConType(Iif(!Empty(SM0->M0_COMPENT),SM0->M0_COMPENT,FisGetEnd(SM0->M0_ENDENT,SM0->M0_ESTENT)[4]))	)	//06 - COMPL
aAdd (aReg[nPos], SPEDConType(SM0->M0_BAIRENT))																					//07 - BAIRRO

cTel := SPEDConType(SPEDVldIE(SM0->M0_TEL)) // Tira espaços e caracteres especiais
cFax := SPEDConType(SPEDVldIE(SM0->M0_FAX)) // Tira espaços e caracteres especiais

aAdd (aReg[nPos], Iif(Len(Alltrim(cTel))==10,cTel,SubStr(cTel,(Len(cTel)-9),Len(cTel))))				 						//08 - FONE
aAdd (aReg[nPos], Iif(Len(Alltrim(cFax))==10,cFax,SubStr(cFax,(Len(cFax)-9),Len(cFax))))			  							//09 - FAX
aAdd (aReg[nPos], aWizard[2][7])																	 							//10 - EMAIL

GrvRegTrS (cAlias,, aReg)
Return (lRet)
/*
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Reg0015   | Autor ³Gustavo G. Rueda              ³ Data ³03.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³0015 - DADOS DO CONTRIBUINTE SUBSTITUTO                            ³±±
±±³          ³- Geracao do Registro 0015.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpA1 := Reg0015(cMVSUBTRIB,cAlias)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cMVSUBTRIB -> Conteudo do parametro MV_SUBTRIB                     ³±±
±±³          ³cAlias -> Alias do TRB que recebera as informacoes                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1 - Array com a estrutura do registro                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
*/
Static Function Reg0015(cMVSUBTRIB,cAlias,lExtratTAF)
Local	nPosI		:=	0
Local	nPosF		:=	0
Local	nPosY		:=	0
Local	nX			:=	0
Local	aUf			:=	UfCodIBGE("",.F.)
Local	aReg0015	:=	{}
                                              
Default lExtratTAF := .F.
//Pega IE de difal
If FindFunction("GetSubTrib")
	cMVSUBTRIB+=GetSubTrib("",.T.)
Endif

For nX := 1 to len(aUf)
	//³REGISTRO 0015 - DADOS DO CONTRIBUINTE SUBSTITUTO³
	If At (aUf[nX][1], cMVSUBTRIB)>0	//Se tiver inscricao no estado
		If (aScan (aReg0015, {|aX| aX[2]==aUf[nX][1]})==0)
			aAdd(aReg0015, {})
			nPosY	:=	Len (aReg0015)
			aAdd (aReg0015[nPosY], "0015")								//01 - REG
			aAdd (aReg0015[nPosY], aUf[nX][1])							//02 - UF_ST
	
			nPosI	:=	At (aUf[nX][1], cMVSUBTRIB)+2
			nPosF	:=	At ("/", SubStr (cMVSUBTRIB, nPosI))-1
			nPosF	:=	IIf(nPosF<=0,len(cMVSUBTRIB),nPosF)
	
			aAdd (aReg0015[nPosY], SubStr (cMVSUBTRIB, nPosI, nPosF))	//03 - IE_ST
		EndIf
	EndIf
Next

If !lExtratTAF
	GrvRegTrS(cAlias,,aReg0015)
EndIf

Return aReg0015
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Reg0100   | Autor ³Gustavo G. Rueda              ³ Data ³03.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³DADOS DO CONTABILISTA                                              ³±±
±±³          ³- Geracao do Registro 0100 e gravacao do mesmo                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpL1 := Reg0100(aWizard,cAlias, dDataDe, dDataAte)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> informacoes preenchidas no Wizard                       ³±±
±±³          ³cAlias -> Alias do TRB que recebera as informacoes                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 - Sempre .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
*/
Static Function Reg0100(aWizard,cAlias, dDataDe, dDataAte)
Local	aReg		:=	{}
Local	lRet		:=	.T.
Local	nPos		:=	0
Local 	cCNPJ		:= ""     
Local 	lInclui		:= .F.
Local	cAliasCVB	:=	"CVB"


If (!Empty(aWizard[3][1]) .And. !Empty(aWizard[3][7]))
// se o nome e o endereco estiver informado na wizard, continuo a pegar as informacoes da wizard.
	aAdd (aReg, {})
	nPos	:=	Len (aReg)
	aAdd (aReg[nPos], "0100")					//01 - REG
	aAdd (aReg[nPos], aWizard[3][1])			//02 - NOME
	aAdd (aReg[nPos], aWizard[3][3])			//03 - CPF
	aAdd (aReg[nPos], aWizard[3][4])			//04 - CRC
	aAdd (aReg[nPos], aWizard[3][2])			//05 - CNPJ
	aAdd (aReg[nPos], aWizard[3][5])			//06 - CEP
	aAdd (aReg[nPos], aWizard[3][7])			//07 - END
	aAdd (aReg[nPos], aWizard[3][8])			//08 - NUM
	aAdd (aReg[nPos], aWizard[3][9])			//09 - COMPL
	aAdd (aReg[nPos], aWizard[3][10])			//10 - BAIRRO
	aAdd (aReg[nPos], aWizard[3][11])			//11 - FONE
	aAdd (aReg[nPos], aWizard[3][12])			//12 - FAX
	aAdd (aReg[nPos], aWizard[3][13])			//13 - EMAIL
	aAdd (aReg[nPos], aWizard[3][6])			//14 - COD_MUN
Else
	lInclui := .F.
	If !Empty(aWizard[3][3])
		// se o CPF estiver informado, mas sem o nome e endereco, pesquiso na tabela CVB - contabilista pelo num. documento.
		lInclui := SPEDFFiltro(1,"CVB",@cAliasCVB,{DToS(dDataDe),DToS(dDataAte),aWizard[3][3],""})
	ElseIf !Empty(aWizard[3][2])
		// se o CNPJ estiver informado, mas sem o nome e endereco, pesquiso na tabela CVB - contabilista pelo num. documento.
		cCNPJ := Iif(!Empty(aWizard[3][2]), aWizard[3][2], aWizard[3][3])	 
		cCNPJ := Padr(SubStr(cCNPJ,1,TamSx3("A2_CGC")[1]),TamSx3("A2_CGC")[1])
		lInclui := SPEDFFiltro(1,"CVB",@cAliasCVB,{DToS(dDataDe),DToS(dDataAte),"",cCNPJ})
	Else
		// senao pego o primeiro contabilista informado para a filial corrente.
		lInclui := SPEDFFiltro(1,"CVB",@cAliasCVB,{DToS(dDataDe),DToS(dDataAte),"",""})
	Endif	
    
	If lInclui
		aAdd (aReg, {})
		nPos	:=	Len (aReg)
		aAdd (aReg[nPos], "0100")				   																				//01 - REG
		aAdd (aReg[nPos], (cAliasCVB)->CVB_NOME )																						//02 - NOME
		aAdd (aReg[nPos], Alltrim((cAliasCVB)->CVB_CPF))																				//03 - CPF
		aAdd (aReg[nPos], SPEDConType((cAliasCVB)->CVB_CRC))																				//04 - CRC
		aAdd (aReg[nPos], SPEDConType(Iif(Len(Alltrim((cAliasCVB)->CVB_CGC))>11,Alltrim((cAliasCVB)->CVB_CGC),"")))								//05 - CNPJ
		aAdd (aReg[nPos], SPEDConType((cAliasCVB)->CVB_CEP)) 											   									//06 - CEP
		aAdd (aReg[nPos], SPEDConType(FisGetEnd((cAliasCVB)->CVB_END,(cAliasCVB)->CVB_UF)[1]))						 							//07 - END
		aAdd (aReg[nPos], Iif(!Empty(FisGetEnd((cAliasCVB)->CVB_END,(cAliasCVB)->CVB_UF)[2]),FisGetEnd((cAliasCVB)->CVB_END,(cAliasCVB)->CVB_UF)[3],"SN"))	//08 - NUM
		aAdd (aReg[nPos], SPEDConType((cAliasCVB)->CVB_COMPL))											   								//09 - COMPL
		aAdd (aReg[nPos], SPEDConType((cAliasCVB)->CVB_BAIRRO))																			//10 - BAIRRO
		aAdd (aReg[nPos], SPEDConType((cAliasCVB)->CVB_TEL))																				//11 - FONE
		aAdd (aReg[nPos], SPEDConType((cAliasCVB)->CVB_FAX))																				//12 - FAX
		aAdd (aReg[nPos], (cAliasCVB)->CVB_EMAIL)																						//13 - EMAIL
		aAdd (aReg[nPos], "")																					   				//14 - COD_MUN
		aReg[nPos][14] := IIF( Len(Alltrim((cAliasCVB)->CVB_CODMUN)) <= 5 , UfCodIBGE((cAliasCVB)->CVB_UF) + Alltrim((cAliasCVB)->CVB_CODMUN) , Alltrim((cAliasCVB)->CVB_CODMUN) )
		SPEDFFiltro(2,,cAliasCVB)
	Endif     
Endif

GrvRegTrS(cAlias,,aReg)

Return (lRet)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Reg0190   ³ Autor ³Gustavo G. Rueda       ³ Data ³22.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³            REGISTRO 0190 - UNIDADES DE MEDIDA              ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao do Registro 0190 e gravacao do mesmo              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³1(1 por arquivo)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
*/
Static Function Reg0190(cAlias,cUnid,aReg0190)
Local	nPos	 	:=	0

//³REGISTRO 0190 - UNIDADES DE MEDIDA              ³
If aScan(aReg0190, {|aX| aX[2]==cUnid})==0 .And. SPEDSeek("SAH",,xFilial("SAH")+cUnid)
	aAdd(aReg0190, {})
	nPos	:=	Len (aReg0190)
	aAdd (aReg0190[nPos], "0190")											//01 - REG
	aAdd (aReg0190[nPos], cUnid)											//02 - UNI
	aAdd (aReg0190[nPos], SAH->AH_DESCPO)									//03 - DESCR
	
	GrvRegTrS(cAlias,,{aReg0190[nPos]})
EndIf

Return
/*
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SFRG0200  | Autor ³Gustavo G. Rueda              ³ Data ³03.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³TABELA DE IDENTIFICACAO DO ITEM                                    ³±±
±±³          ³                                                                   ³±±
±±³          ³- Geracao dos Registros 0190, 0200, 205 e 0220                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpL1 :=SFRG0200(cAlias,aReg0200,aReg0190,dDataDe,dDataAte,aProd,; ³±±
±±³          ³                 cProd,aReg0220,cAliasSB1,cUnid)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias do TRB que recebera as informacoes                 ³±±
±±³          ³aReg0200 -> Array com as informacoes a sere retornadads por        ³±±
±±³          ³ referencia para gerar o registro 0200                             ³±±
±±³          ³aReg0190 -> Array com as informacoes a sere retornadads por        ³±±
±±³          ³ referencia para gerar o registro 0190                             ³±±
±±³          ³dDataDe  -> Data inicial do processamento do SPED Fiscal           ³±±
±±³          ³dDataAte -> Data final do processamento do SPED Fiscal             ³±±
±±³          ³aProd    -> Array com as informacoes de produtos alimentadas       ³±±
±±³          ³ por PE                                                            ³±±
±±³          ³cProd    -> Codigo do produto formatado pela rotian                ³±±
±±³          ³aReg0220 -> Array com as informacoes a sere retornadads por        ³±±
±±³          ³ referencia para gerar o registro 0220                             ³±±
±±³          ³cAliasSB1-> Pode ser o proprio SB1 ou um alias gerado por uma      ³±±
±±³          ³ query                                                             ³±±
±±³          ³cUnid    -> Unidade de medida do item contemplando PE              ³±±
±±³          ³cMVDTINCB1-> Conteudo do parametro MV_DTINCB1 que determina o campo³±±
±±³          ³             da tabela SB1 ou uma chamada para um RDMAKE para      ³±±
±±³          ³             retornar a data de inclusao do produto                ³±±
±±³          ³lSpdFis02 -> Ponto de entrada SPDFIS02                             ³±±
±±³          ³nFatorPe -> Fator de conversão retornado pelo ponto de entrada	 ³±±
±±³          ³             SPDFIS02											     ³±±      
±±³          ³cMvEstado -> UF do MV_ESTADO 									     ³±±
±±³          ³cPRDPRIB5 -> Campo da tabela SB5 que indica Produto primario	     ³±±
±±³          ³cAliasSB5-> Pode ser o proprio SB5 ou um alias gerado por uma      ³±±
±±³          ³ query                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 - Sempre .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
*/
Static Function SFRG0200(cAlias,aReg0200,aReg0190,dDataDe,dDataAte,aProd,cProd,aReg0220,cAliasSB1,cUnid,cMVDTINCB1,lSPDFIS02,nFatorPe,cMVEstado,cPRDPRIB5,cAliasSB5,cALiasCD6,lAchouCD6,aSegUnid,cAliasSFT,lAchouSB1,aCmpsSF9,lGera0210, cCodK230,cAli0210, aReg0210, aWizard, lExtFisxTaf)
Local	lRet		:= .T.
Local	lHistTab	:=	aSPDSX6[MV_HISTTAB]
Local	nICMPAD 	:= 	aSPDSX6[MV_ICMPAD]
Local	lGer0220	:=	aSPDSX6[MV_GER0220]//parâmetro (MV_GER0220), informa se deve gerar o registro 0220 do SpedFiscal.
Local	nTipo		:= 1
Local	nX			:= 0
Local	nFldPrdPri	:= 0
Local	cTipo		:= "99"
Local	cCodIss		:= ""
Local	aHist		:= {}
//Local	aReg200		:= {}
//Local	aAuxDesc	:= {}
Local	dDataFinal	:= CToD("  /  /  ")
Local	dDataInici	:= CToD("  /  /  ")
Local	dDataCont	:= CToD("01/01/2000")
Local	cDescProd	:= ""
Local	cCodBarra	:= ""
Local	lProdPrim	:= .F.
Local	lSegUnid	:= valtype(cAliasSB1)== "C"
Local	lProcSegUn	:= .F.
Local	nAlqProd	:= 0
Local	nPos		:= 0
Local	nPos0205	:= 0
Local	nPos0206	:= 0
Local	nPos0210	:= 0
Local	nPos0220	:= 0
Local	aMod		:= {}
Local	cCmpDTINCB1	:= ""
Local	cSegUnid	:= ""
Local	cTpConv		:= ""
Local	cAliasIt	:= ""
//Local	cAliasSD	:= ""
Local	nConv		:= 0
Local	aSPED0205	:= {}
Local	cTipo00		:= IIf(aSPDSX6[MV_BLKTP00]==" ","ME",(aSPDSX6[MV_BLKTP00])) // 00 - Mercadoria para Revenda
Local	cTipo01		:= IIf(aSPDSX6[MV_BLKTP01]==" ","MP",(aSPDSX6[MV_BLKTP01])) // 01 - Materia-prima
Local	cTipo02		:= IIf(aSPDSX6[MV_BLKTP02]==" ","EM",(aSPDSX6[MV_BLKTP02])) // 02 - Embalagem
Local	cTipo03		:= IIF(aSPDSX6[MV_BLKTP03]==" ","PP",(aSPDSX6[MV_BLKTP03])) // 03 - Produto em Processo
Local	cTipo04		:= IIf(aSPDSX6[MV_BLKTP04]==" ","PA",(aSPDSX6[MV_BLKTP04])) // 04 - Produto Acabado
Local	cTipo05		:= IIf(aSPDSX6[MV_BLKTP05]==" ","SP",(aSPDSX6[MV_BLKTP05])) // 05 - SubProduto
Local	cTipo06		:= IIf(aSPDSX6[MV_BLKTP06]==" ","PI",(aSPDSX6[MV_BLKTP06])) // 06 - Produto Intermediario
Local	cTipo10		:= IIf(aSPDSX6[MV_BLKTP10]==" ","OI",(aSPDSX6[MV_BLKTP10])) // 10 - Outros insumos
Local	aTipo		:=	{ {cTipo00,"00"},;
						  {cTipo01,"01"},;
						  {cTipo02,"02"},;
						  {cTipo03,"03"},;
						  {cTipo04,"04"},;
						  {cTipo05,"05"},;
						  {cTipo06,"06"},;
						  {"MC"   ,"07"},;
						  {"AI"   ,"08"},;
						  {"MO"   ,"09"},;
						  {cTipo10,"10"} }
//Local	aAreaAux	:= {}
Local	cProdCDN	:= ""
Local cChave    := ""

DEFAULT cAliasSB1	:= "SB1"
DEFAULT cAliasSB5	:= "SB5"
DEFAULT cAliasCD6	:= "CD6"
DEFAULT lAchouCD6	:= .F.
DEFAULT cProd		:= (cAliasSB1)->B1_COD+ Iif(lConcFil,xFilial("SB1"),"")
DEFAULT aProd		:= {"","","","","","","","","","","",""}
DEFAULT dDataDe		:= Date()
DEFAULT dDataAte	:= Date()
DEFAULT cUnid		:= (cAliasSB1)->B1_UM
DEFAULT cMVDTINCB1	:= IIF(AllTrim(aSPDSX6[MV_DTINCB1]) != "", AllTrim(aSPDSX6[MV_DTINCB1]),"B1_DATREF")
DEFAULT lSPDFIS02	:= .F.
DEFAULT cPRDPRIB5	:= Alltrim(aSPDSX6[MV_PRDPRI])
DEFAULT aSegUnid	:= {}
DEFAULT cAliasSFT	:= ""
DEFAULT lAchouSB1	:= .T.
DEFAULT lGera0210	:= .F.
DEFAULT cCodK230	:= ""
DEFAULT cAli0210	:= ""
DEFAULT aReg0210	:= {}
DEFAULT aWizard	:= {}  
DEFAULT lExtFisxTaf := .F.

If (cAliasSB1)->(FieldPos("FT_CFOP")) > 0
	cAliasIt := IIf (Substr((cAliasSB1)->FT_CFOP,1,1)>="5", "SD2", "SD1")
EndIf

//Verifica existencia do campo indicado no parametro MV_PRDPRI
nFldPrdPri := Iif( Empty(cPRDPRIB5), 0, (cAliasSB5)->(FieldPos(cPRDPRIB5)) )

IF lSegUnid // Se está com alias da SB1 irá preencher as variáveis
	cSegUnid	:=(cAliasSB1)->B1_SEGUM
	nConv		:=(cAliasSB1)->B1_CONV
	cTpConv		:=(cAliasSB1)->B1_TIPCONV
	lProcSegUn	:= .T.
ElseIF Len(aSegUnid) > 0  //Se não está com alias da SB1 então irá verificar se as informações estão no array.
	cSegUnid	:=aSegUnid[1]
	nConv		:=aSegUnid[2]
	cTpConv		:=aSegUnid[3]
	lProcSegUn	:= .T.	
EndIF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se existir o ponto de entrada SPDFIS02, nao devo gravar no registro    ³
//³0200 a segunda unidade de medida (Que o PE retornou), e sim a primeira.³
//³O registro 0190 deve ser gerado para as 2 unidades de medida.          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lSPDFIS02
	//³REGISTRO 0190 - UNIDADES DE MEDIDA              ³
	Reg0190(cAlias,(cAliasSB1)->B1_UM,@aReg0190)	
Else
	Reg0190(cAlias,cUnid,@aReg0190)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³REGISTRO 0200 - TABELA DE IDENTIFICACAO DO ITEM         ³
//³                                                        ³
//³Verifico a existencia do produto para evitar duplicidade³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF lBuild
    cChave := cProd
    nPos   := FindHash(oHash0200, cChave)
Else
    nPos := aScan(aReg0200,{|aX| aX[2]==cProd})
EndIf

If (nPos == 0)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada para o usuario relacionar tipos de produto criados com o codigo da ³
	//³ tabela de tipos do ATO COTEPE 09/2008 (layout SPED Fiscal)                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aExistBloc[10]
		aTipo := ExecBlock("SPDFIS001", .F., .F., {aTipo})
	EndIf

	//³Obtendo o tipo de item para montar o campo do registro³
	For nTipo := 1 To len(aTipo)
		If (cAliasSB1)->B1_TIPO $ aTipo[nTipo][1]
			cTipo := aTipo[nTipo][2]
			Exit
		EndIf
	Next nTipo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica o tamanho do código de barras. Deve estar dentro do padrão GTIN (8,12,13,14)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If	Len(AllTrim((cAliasSB1)->B1_CODBAR)) ==  8 .Or. Len(AllTrim((cAliasSB1)->B1_CODBAR)) == 12 .Or.;
		Len(AllTrim((cAliasSB1)->B1_CODBAR)) == 13 .Or. Len(AllTrim((cAliasSB1)->B1_CODBAR)) == 14
		cCodBarra := (cAliasSB1)->B1_CODBAR
	Endif

	aAdd(aReg0200,{})
	nPos	:=	Len (aReg0200)
	aAdd(aReg0200[nPos], "0200")																//01 - REG
	aAdd(aReg0200[nPos], cProd)																	//02 - COD_ITEM

	//³Tratamento para pegar a informacao valida do cadastro dentro do prazo de geracao do spedifscal³
	If lHistTab .And. dDataDe <> NIL
		aMod := MsConHist("SB1","","",dDataDe,,Substr(cProd,1,TamSx3("B1_COD")[1]))
	EndIf
	cContCampo := If(lAchouSB1,RetCmpHist(cAliasSB1+"->B1_DESC",aMod,dDataAte,lHistTab),If(!Empty(aCmpsSF9[26]),aCmpsSF9[26],RetCmpHist(cAliasSB1+"->B1_DESC",aMod,dDataAte,lHistTab)))

	aAdd (aReg0200[nPos], Iif(!Empty(aProd[2]),aProd[2],cContCampo))							//03 - DESCR_ITEM	
	aAdd (aReg0200[nPos], Iif(!Empty(aProd[3]),aProd[3],cCodBarra))							//04 - COD_BARRA
	aAdd (aReg0200[nPos], "")																	//05 - COD_ANT_IETM
	If lSPDFIS02
		aAdd (aReg0200[nPos], (cAliasSB1)->B1_UM)												//06 - UNI_INV
	Else
		aAdd (aReg0200[nPos], cUnid)															//06 - UNI_INV
	EndIf
	aAdd (aReg0200[nPos], Iif(!Empty(aProd[6]),aProd[6],cTipo))								//07 - TIPO_ITEM
	If Len(aWizard)>0
		if ( (!lExtFisxTaf .and. SubStr(aWizard[2][5], 1, 1) == "0") .or. (lExtFisxTaf .and. SubStr(aWizard[1][15], 1, 1) == "0") ) .And. (Iif(!Empty(aProd[6]), aProd[6] $ "07|08|09|10|99", cTipo $ "07|08|09|10|99" ))
			aAdd (aReg0200[nPos], "")																//08 - COD_NCM
		Else
			aAdd (aReg0200[nPos], Iif(!Empty(aProd[7]),aProd[7],(cAliasSB1)->B1_POSIPI))				//08 - COD_NCM		
		EndIf
	Else
		aAdd (aReg0200[nPos], Iif(!Empty(aProd[7]),aProd[7],(cAliasSB1)->B1_POSIPI))				//08 - COD_NCM
	EndIf
	aAdd (aReg0200[nPos], Iif(!Empty(aProd[8]),aProd[8],(cAliasSB1)->B1_EX_NCM))				//09 - EX_IPI

	//Ponto de Entrada
	If !Empty(aProd[9])
		aAdd (aReg0200[nPos],aProd[9])															//10 - COD_GEN

	//Verifico se trata-se de um servico
	Elseif Empty((cAliasSB1)->B1_CODISS)

		//Verifico se utiliza o parametro MV_PRDPRI
		//Este paramentro indica se eh referente a um produto primario, conforme guia pratico, o preenchimento deste campo
		//eh obrigatorio apenas para produtos primarios
		If nFldPrdPri <> 0
			lProdPrim	:=	!((cAliasSB5)->(FieldGet(nFldPrdPri)) $ "N")
			aAdd (aReg0200[nPos],Iif(lProdPrim,Left((cAliasSB1)->B1_POSIPI,2),""))				//10 - COD_GEN
		Else
			aAdd (aReg0200[nPos],Left((cAliasSB1)->B1_POSIPI,2))								//10 - COD_GEN
		Endif

	//Para servico, utilizo sempre "00"
	Else
		aAdd (aReg0200[nPos],"00")																//10 - COD_GEN
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtendo o codigo do ISS atraves do cadastro da tabela CDN. Este codigo deverah            ³
	//³estar conforme LC 116/03                                                                  ³
	//³Tratamento para considerar também mais de um Cod LST por Cod ISS, conforme a legislação   ³
	//³existe a possibilidade de ser n / n                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCodIss := Iif(!Empty(aProd[10]),SubStr (aProd[10], 1, 4),SubStr ((cAliasSB1)->B1_CODISS, 1, 5))
	cProdCDN := Alltrim((cAliasSB1)->B1_COD)
	If aSPDSX2[AI_CDN]
		If CDN->(MsSeek(xFilial("CDN")+PadR(cCodIss,8)+cProdCDN))
			cCodIss := SubStr (CDN->CDN_CODLST, 1, 4)
		Elseif CDN->(MsSeek(xFilial("CDN")+PadR(cCodIss,8)))
			cCodIss := SubStr (CDN->CDN_CODLST, 1, 4)
		EndIf
	EndIf

	//Tiro todos os pontos que estiverem no cadastro.
	cCodIss := StrTran(cCodIss,".","")	

	IF(LEN(ALLTRIM(cCodIss))<4 .AND. !EMPTY (ALLTRIM(cCodIss)) )
		cCodIss := "0" + cCodIss
	ENDIF

	If !Empty(cCodIss)
		IF ddatade >= ctod('01/01/2015') //a partir de 2015 o formato do código lst deverá ser NN.NN
			//Coloco ponto na terceita posição do código de serviço
			cCodIss	:= SubStr(cCodIss,1,2) + '.' + SubStr(cCodIss,3,2)
		EndIF
	EndIF

	aAdd (aReg0200[nPos], cCodIss)												//11 - COD_LST

	//³Tratamento para obter a aliquota interna do produto³
	If ValType(aProd[11]) == "N"
		nAlqProd := aProd[11]

	ElseIf (cAliasSB1)->B1_PICM>0
		If cMVEstado == "RJ"
			nAlqProd := (cAliasSB1)->B1_PICM+(cAliasSB1)->B1_FECP
		Else
			nAlqProd := (cAliasSB1)->B1_PICM
		EndIf
	Else
		If cMVEstado == "RJ"
			nAlqProd := nICMPAD+(cAliasSB1)->B1_FECP
		Else
			nAlqProd := nICMPAD
		EndIf
	EndIf
	aAdd(aReg0200[nPos], nAlqProd)																//12 - ALIQ_ICM

	IF cVersao >= "011"
		If(aSPDSX3[FP_B1_CEST])
			aAdd(aReg0200[nPos],Iif(len(aProd)>=12,Iif(!Empty(aProd[12]),aProd[12],(cAliasSB1)->B1_CEST),(cAliasSB1)->B1_CEST))
		Else
			aAdd(aReg0200[nPos], '')                                                      //13 - CEST
		Endif	   
	EndIf
    
    IF lBuild
       AddHash(oHash0200, cChave, nPos) 
    EndIf  
    
	//³REGISTRO 0205 - ALTERACOES DO ITEM              ³
	If dDataDe<>Nil
		//conforme manual o, caso não tenha ocorrido movimentação no período da alteração do item, 
		//deverá ser informada no primeiro período em que houver movimentação do item
		aHist := MsConHist("SB1","","",dDataDe,dDataAte,Substr(cProd,1,TamSx3("B1_COD")[1]))

		//Exclui alteracoes que nao sejam de "B1_DESC"
		nX := 1
		While nX <= Len(aHist)
			If Alltrim(aHist[nX][1])<>"B1_DESC"
				aDel(aHist, nX)
				aSize(aHist, Len(aHist) - 1)
				nX := 0
			ElseIf cAliasIt $ "SD1/SD2"
				DbSelectArea(cAliasIt)
				(cAliasIt)->(DbSetOrder(1))
				If ((cAliasIt)->(DbSeek(xFilial(cAliasIt)+Substr(cProd,1,TamSx3("B1_COD")[1]))))
					cCampData	:= SubStr (cAliasIt,2,2)+"_EMISSAO"
					cCampCod	:= SubStr (cAliasIt,2,2)+"_COD"
					While !(cAliasIt)->(Eof()) .AND. ((cAliasIt)->&cCampData>= aHist[nX][3]) .AND. ((cAliasIt)->&cCampData<= dDataAte) .And. (cAliasIt)->&cCampCod == Substr(cProd,1,TamSx3("B1_COD")[1])
						If (cAliasIt)->&cCampCod == Substr(cProd,1,TamSx3("B1_COD")[1]) .And. !((cAliasIt)->&cCampData >= dDataDe)
							aHist := {}
							Exit
						EndIf
						(cAliasIt)->(dbSkip())
					EndDo
				EndIf
			EndIf
			nX++
		EndDo

		If aExistBloc[20]
			aSped0205 := Execblock("SPED0205", .F., .F., {dDataDe,dDataAte,Substr(cProd,1,TamSx3("B1_COD")[1])})
			//Ira verificar se o retorno do ponto de entrada tem todas as informacoes necessarias
			If ValType(aSped0205[1]) <> "A"
				If Len(aSped0205) >= 4
					aAdd(aReg0205, {})
					nPos0205	:=	Len(aReg0205)
					aAdd(aReg0205[nPos0205], nPos)										//00-Relacionamento com o PAI
					aAdd(aReg0205[nPos0205], "0205")									//01 - REG
					aAdd(aReg0205[nPos0205], aSped0205[1])								//02 - DESCR_ANT_ITEM
					aAdd(aReg0205[nPos0205], aSped0205[2])								//03 - DT_INI
					aAdd(aReg0205[nPos0205], aSped0205[3])								//04 - DT_FIM
					If cVersao >= "003"
						aAdd(aReg0205[nPos0205], aSped0205[4])
					EndIf
				EndIf
			Else
				For nX := 1 To Len(aSped0205)
					If Len(aSped0205[nX]) >= 4
						aAdd(aReg0205, {})
						nPos0205	:=	Len(aReg0205)
						aAdd(aReg0205[nPos0205], nPos)									//00-Relacionamento com o PAI
						aAdd(aReg0205[nPos0205], "0205")								//01 - REG
						aAdd(aReg0205[nPos0205], aSped0205[nX][1])						//02 - DESCR_ANT_ITEM
						aAdd(aReg0205[nPos0205], aSped0205[nX][2])						//03 - DT_INI
						aAdd(aReg0205[nPos0205], aSped0205[nX][3])						//04 - DT_FIM
						If cVersao >= "003"
							aAdd(aReg0205[nPos0205], aSped0205[nX][4])					//05 - COD_ANT_ITEM - LAYOUT 2010
						EndIf
					EndIf
				Next nX
			EndIf
		EndIf

		//Verificando se a função MsConHist retornou pelo menos um array
		If Len(aHist) > 0

			//Exclui alteracoes de "B1_DESC" que sejam do mesmo dia com horarios menores, deixa a ultima
			nY := 1
			While nY <= Len(aHist)
				For nX := 1 To Len(aHist)
					If Len(aHist)>1 .And. nX<=Len(aHist)
						If nX > 1 .And. nX<Len(aHist)
							If (aHist[nX][3]=aHist[nX-1][3]) .And. (aHist[nX][4]>=aHist[nX-1][4])
								aDel(aHist, nX-1)
								aSize(aHist, Len(aHist) - 1)
								nX := 0
							ElseIf (aHist[nX][3]=aHist[nX+1][3]) .And. (aHist[nX][4]<=aHist[nX+1][4])
								aDel(aHist, nX+1)
								aSize(aHist, Len(aHist) - 1)
								nX := 0
							EndIf
						ElseIf nX > 1 .And. nX=Len(aHist)
							If (aHist[nX][3]=aHist[nX-1][3]) .And. (aHist[nX][4]>=aHist[nX-1][4])
								aDel(aHist, nX-1)
								aSize(aHist, Len(aHist) - 1)
								nX := 0
							EndIf
						EndIf
					Else
						Exit
					EndIf
				Next nX
				nY++
			Enddo

			cCmpDTINCB1 := cAliasSB1 + "->" +cMVDTINCB1 //Campo configurado no parametro MV_DTINCB1

			//Passando para um array auxiliar os arrays que são do campo B1_DESC, para ordenar corretamente por DATA e HORA de alteração
			For nX := 1 To Len(aHist)
				//Atribuindo a variavel cDescProd o valor da 'DESCRIçãO ANTERIOR DO PRODUTO' da ultima alteração
				cDescProd := aHist[nX][2]

				//Atribuindo a ultima data de alteração a variavel dDataFinal
				dDataFinal := aHist[nX][3]-1
				If nX==1

					dDataInici := &(cCmpDTINCB1)

					If Empty(dDataInici)
						dDataInici := aHist[nX][3]
					Endif
				Else
					//Atribuindo a penultima data de alteração a variavel dDataInici independente se houve alteracao ou não no mesmo dia
					dDataInici := aHist[nX-1][3]

					//----->>
					//Este tratamento abaixo foi efetuado para tratar alteracoes de produto validas por um dia
					//Neste caso, leva a data fim como sendo a data contida no historico
					//Devido a restricoes no layout
					If nX = Len(aHist) .And. dDataFinal = dDataInici
						dDataFinal := aHist[nX][3]
					EndIf
					//----->>
				Endif

				If Valtype(dDataInici) != Valtype(dDataFinal) .And. !Empty(dDataInici)
					dDataInici := IIF(Valtype(dDataInici) == "C" .And. Valtype(dDataFinal) == "D", cTod(dDataInici)  ,dDataInici )
				EndIf

				//tratamento na geracao do registro 0205 - Alteracao do Item quando um item for alterado na data final do arquivo do Sped Fiscal
				//----->>
				//Este tratamento abaixo de <= foi efetuado para tratar alteracoes de produto validas por um dia
				//Neste caso, o registro e gerado com data
				//Devido a restricoes no layout
				If dDataFinal <= dDataAte .And. Alltrim(aHist[nX][1])$"B1_DESC"
					If dDataInici < dDataFinal
						aAdd(aReg0205, {})
						nPos0205	:=	Len(aReg0205)
						aAdd(aReg0205[nPos0205], nPos)												//00-Relacionamento com o PAI
						aAdd(aReg0205[nPos0205], "0205")											//01 - REG
						aAdd(aReg0205[nPos0205], cDescProd)											//02 - DESCR_ANT_ITEM
						IF dDataInici < dDataCont
							aAdd(aReg0205[nPos0205], dDataCont)										//03 - DT_INI
						Else
							aAdd(aReg0205[nPos0205], dDataInici)									//03 - DT_INI
						EndIF
						aAdd(aReg0205[nPos0205], dDataFinal)										//04 - DT_FIM
						If cVersao >= "003"
							//Se a versão for inferior a 008 deverá preencher CODANT, pois PVA aceita somente um registro 0205
							IF cVersao < "008"
								aAdd(aReg0205[nPos0205], (cAliasSB1)->B1_CODANT)					//05 - COD_ANT_ITEM - LAYOUT 2010
							Else
								//A partir da versão 008 o PVA aceita dois registros 0205, então não deverá informar neste registro CODANT
								//pois o PVA não aceita mais o CODANT e DescProd no mesmo 0205. CODANT será informado em outro registro 0205 abaixo.
								aAdd(aReg0205[nPos0205], '')										//05 - COD_ANT_ITEM - LAYOUT 2010
							EndIF
						EndIf

						If cVersao >= "008" .AND. !Empty(Alltrim((cAliasSB1)->B1_CODANT))
							//Segundo registro 0205 com o CODANT e sem Descricção anterior.
							aAdd(aReg0205, {})
							nPos0205	:=	Len(aReg0205)
							aAdd(aReg0205[nPos0205], nPos)											//00-Relacionamento com o PAI
							aAdd(aReg0205[nPos0205], "0205")										//01 - REG
							aAdd(aReg0205[nPos0205], '')											//02 - DESCR_ANT_ITEM
							IF dDataInici < dDataCont
								aAdd(aReg0205[nPos0205], dDataCont)									//03 - DT_INI
							Else
								aAdd(aReg0205[nPos0205], dDataInici)								//03 - DT_INI
							EndIF
							aAdd(aReg0205[nPos0205], dDataFinal)									//04 - DT_FIM
							aAdd(aReg0205[nPos0205], (cAliasSB1)->B1_CODANT)						//05 - COD_ANT_ITEM - LAYOUT 2010							
						EndIF

					EndIf
				EndIf
			Next nX
		EndIf
		//³REGISTRO 0206 - CODIGO DE PRODUTO CONFORME TABELA PUBLICADA PELA ANP (COMBUSTIVEIS)  ³
		If lAchouCD6 .AND. aScan (aReg0206, {|aX| aX[2]==AllTrim((cALiasCD6)->CD6_CODANP)}) == 0
			aAdd(aReg0206, {})
			nPos0206 := Len(aReg0206)
			aAdd(aReg0206[nPos0206], nPos)
			aAdd (aReg0206[nPos0206], "0206")							//01 - REG
			aAdd (aReg0206[nPos0206], AllTrim((cALiasCD6)->CD6_CODANP))	//02 - COD_COMB
		EndIF
	EndIf
EndIf

//Registro 0210 //BLOCO K
If lGera0210
    (cAli0210)->(DbGoTop ())
    Do While !(cAli0210)->(Eof ())
        IF  aScan(aReg0210,{|aX|aX[1]== nPos .And. aX[3] == (cAli0210)->COD_I_COMP+Iif(lConcFil,xFilial("SB1"),"")}) == 0 .And.  cCodK230 == (cAli0210)->COD_ITEM
            aAdd(aReg0210, {})
            nPos0210    :=  Len(aReg0210)
            aAdd(aReg0210[nPos0210], nPos)                                                          //00-Relacionamento com o PAI
            aAdd(aReg0210[nPos0210], "0210")                                                        //01 - REG
            aAdd(aReg0210[nPos0210], (cAli0210)->COD_I_COMP+Iif(lConcFil,xFilial("SB1"),""))    //02 - COD_ITEM_COMP 
            aAdd(aReg0210[nPos0210], {(cAli0210)->QTD_COMP,6})                              //03 - QTD_COMP
           aAdd(aReg0210[nPos0210], {(cAli0210)->PERDA,4})                                 //04 - PERDA
        EndIf
    (cAli0210)->(DbSkip())
    EndDo
EndIf

//³REGISTRO 0220 - FATORES DE CONVERSAO DAS UNIDADES ³
If 	(lSPDFIS02) .And. !Empty(cUnid) .And. aReg0220<>Nil .And.;
		aScan(aReg0220,{|aX| aX[1]==nPos .And. aX[3]==cUnid})==0

	If cUnid <> (cAliasSB1)->B1_UM
		aAdd(aReg0220, {})
		nPos0220	:=	Len (aReg0220)
		aAdd (aReg0220[nPos0220], nPos)												//00-Relacionamento com o PAI
		aAdd (aReg0220[nPos0220], "0220")											//01 - REG				
		aAdd (aReg0220[nPos0220], cUnid)											//02 - UNID_CONV				
		If nFatorPe > 0
			If SB1->B1_TIPCONV == "D"
				aAdd (aReg0220[nPos0220], {(1/nFatorPe), 6} )						//03 - FAT_CONV
			Else
				aAdd (aReg0220[nPos0220], {nFatorPe, 6} )							//03 - FAT_CONV
			EndIf
		Else
			If SB1->B1_TIPCONV == "D"
				aAdd (aReg0220[nPos0220], {(1/(cAliasSB1)->B1_CONV), 6} )			//03 - FAT_CONV
			Else
				aAdd (aReg0220[nPos0220], {(cAliasSB1)->B1_CONV, 6} )				//03 - FAT_CONV
			EndIf
		EndIF
		Reg0190(cAlias,cUnid,@aReg0190)
	EndIf
ElseIF lGer0220 .And. lProcSegUn .AND. !Empty(cSegUnid) .AND. cSegUnid <> cUnid .And. aReg0220<>Nil .And.;
		aScan(aReg0220,{|aX| aX[1]==nPos .And. aX[3]==cSegUnid})==0

	aAdd(aReg0220, {})
	nPos0220	:=	Len (aReg0220)
	aAdd (aReg0220[nPos0220], nPos)												//00-Relacionamento com o PAI
	aAdd (aReg0220[nPos0220], "0220")											//01 - REG				
	aAdd (aReg0220[nPos0220], cSegUnid)											//02 - UNID_CONV				
	If cTpConv == "D"
		aAdd (aReg0220[nPos0220], {(1/nConv), 6} )			//03 - FAT_CONV
	Else
		aAdd (aReg0220[nPos0220], {nConv, 6} )				//03 - FAT_CONV
	EndIf
	Reg0190(cAlias,cSegUnid,@aReg0190)
EndIf

Return (lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Reg0400   ³ Autor ³Gustavo G. Rueda       ³ Data ³04.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³        TABELA DE NATUREZA DA OPERACAO/PRESTACAO            ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao do Registro 0400                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com os CFOPs utilizados nos documentos.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³2(varios por arquivo)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCodNat -> Codigo da Natureza da Operacao/Prestacao         ³±±
±±³          ³aReg0400 -> Array com o conteudo do registro para posteior  ³±±
±±³          ³ gravacao.                                                  ³±±
±±³          ³cDescNat -> Descriacao da Natureza da Operacao/Prestacao    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Reg0400(cCodNat,aReg0400,cDescNat)
Local	lRet	:=	.T.
Local	nPos	:=	aScan (aReg0400, {|aX| aX[2]==cCodNat})

If (nPos==0)
	aAdd (aReg0400, {})
	nPos	:=	Len (aReg0400)
	aAdd (aReg0400[nPos], "0400")			//REG
	aAdd (aReg0400[nPos], cCodNat)			//COD_NAT
	aAdd (aReg0400[nPos], cDescNat)			//DESCR_NAT
EndIf

Return (lRet)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Reg0450   ³ Autor ³Gustavo G. Rueda       ³ Data ³11.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³        TABELA DE INFORMACAO COMPLEMENTAR/OBSERVACAO        ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro 0450                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as observacoes do documeto referen-³±±
±±³          ³ ciado                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³2(varios por arquivo)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aInfCompl -> Array com as informacoes complementares do     ³±±
±±³          ³             documento. [1]=codigo e [2]=descricao          ³±±
±±³          |aReg0450  -> Array de estrutura do registro 0450 a ser gra- ³±±
±±³          ³             vado no final do processamento da rotina       ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Reg0450(aInfCompl,aReg0450)
Local	nPos		:=	0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gravacao do REGISTRO 0450³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aInfCompl)==2 .And. !Empty(aInfCompl[1]) .And. aScan(aReg0450,{|aX|aX[2]==aInfCompl[1]})==0
	//³Tratamento para quando a descricao do lancamento nao for passada³
	If (aInfCompl[2]==Nil  .Or. Empty(aInfCompl[2])) .And. CCE->(MsSeek(xFilial("CCE")+aInfCompl[1]))
		aInfCompl[2]	:=	CCE->CCE_DESCR
	EndIf

	aAdd(aReg0450, {})
	nPos	:=	Len (aReg0450)
	aAdd (aReg0450[nPos], "0450")			   		//REG
	aAdd (aReg0450[nPos], aInfCompl[1])       		//COD_INF
	aAdd (aReg0450[nPos], aInfCompl[2]) 			//TXT
EndIf                                          	

Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Reg0460   ³ Autor ³Gustavo G. Rueda       ³ Data ³10.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³        TABELA DE INFORMACAO COMPLEMENTAR/OBSERVACAO        ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro 0460                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as observacoes do documeto referen-³±±
±±³          ³ ciado                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³2(varios por arquivo)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aReg0460 -> Array com a estrutura do registro 0460 a ser    ³±±
±±³          ³ gravado no TRB no final do processamento da rotina         ³±±
±±³          ³aObs     -> Array contendo o codigo da obs[1] e a observacao³±±
±±³          ³ em si[2]                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Reg0460(aReg0460,aObs)
Local	nPos		:=	0
//³Gravacao do REGISTRO 0460³
If Len(aObs)==2 .And. aScan(aReg0460,{|aX| aX[2]==aObs[1]})==0
	aAdd(aReg0460, {})
	nPos	:=	Len (aReg0460)
	aAdd (aReg0460[nPos], "0460")					//REG			
	aAdd (aReg0460[nPos], aObs[1])                 //COD_OBS
	aAdd (aReg0460[nPos], aObs[2])                 //TXT
EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC100   ³ Autor ³Gustavo G. Rueda       ³ Data ³14.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³               NOTA FISCAL (MODELO 01 E 04)                 ³±±
±±³          ³                                                            ³±±
±±³          ³Geracao e gravacao do Registro C100                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoes de todos os docu-   ³±±
±±³          ³ mentos fiscais processados.                                ³±±
±±³          ³Somente sera gravado os documentos fiscais modelo 01 e 04   ³±±
±±³          ³ nos outros casos, sera utilizdo para gerar outros registros³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³2                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cEntSai -> Flag de indicacao do documento fiscal, 1=Entrada/³±±
±±³          ³ 2=Saida.                                                   ³±±
±±³          ³aPartDoc -> Array com todas as informacoes do Cliente/Forne-³±±
±±³          ³ cedor.                                                     ³±±
±±³          ³cEspecie -> Modelo do documento fiscal                      ³±±
±±³          ³cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          ³nRelac -> Flag de relacionamento com os sub-registros       ³±±
±±³          ³aCmpAntSFT -> Informacoes de cabecalho do documento fiscal  ³±±
±±³          ³aTotaliza -> Totalizacao de valores da tabela SFT do docu-  ³±±
±±³          ³ mento fiscal do processamento atual no while               ³±±
±±³          ³aRegC100 -> Informacoes sobre todos documentos fiscais pro- ³±±
±±³          ³ cessados no while da funcao principal.                     ³±±
±±³          ³cSituaDoc -> Situacao do documento fiscal conforme funcao   ³±±
±±³          ³ SPEDSitDoc                                                 ³±±
±±³          ³lGrava0150 -> Flag para indicar se deve gerar 0150          ³±±
±±³          ³aParcTit -> Array com os titulos gerados para o documento   ³±±
±±³          ³lPisZero -> Indica se zera o valor do Pis                   ³±±   
±±³          ³lCofZero -> Indica se zera o valor do Cofins                ³±±   
±±³          ³cVesao -> numero da versao do leiaute                       ³±±   
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegC100(cEntSai,aPartDoc,cEspecie,cAlias,nRelac,aCmpAntSFT,aTotaliza,aRegC100,cSituaDoc,lGrava0150,aParcTit,lPisZero,lCofZero,cVersao,aWizard,lOperGar,cSitDocInf)
Local	nPos		:=	0
Local	nX			:=	0
Local   aSpedC100   := {}
//Local   cAuxFrete := ""      

Default	aParcTit	:=	{}	
Default aWizard		:= {}
Default cSitDocInf	:= ""

//³Tratamento para evitar duplicidade no registro³
If aScan(aRegC100,{|aX| aX[7]==aCmpAntSFT[2] .And. aX[8]==aCmpAntSFT[1] .And. aX[10]==aCmpAntSFT[6]})==0
	//³Inicio da montagem do registro³
	aAdd(aRegC100, {})
	nPos	:=	Len (aRegC100)
	aAdd (aRegC100[nPos], "C100")					   								//01 - REG
	aAdd (aRegC100[nPos], Str(Val(cEntSai)-1,1)) 	   								//02 - IND_OPER
	aAdd (aRegC100[nPos], aCmpAntSFT[26])											//03 - IND_EMIT
	aAdd (aRegC100[nPos], "")														//04 - COD_PART
	aAdd (aRegC100[nPos], cEspecie)   							 					//05 - COD_MOD
	aAdd (aRegC100[nPos], cSituaDoc)												//06 - COD_SIT
	aAdd (aRegC100[nPos], IIF(Empty(aCmpAntSFT[2]) .And. cEspecie$"55#65","000",aCmpAntSFT[2]))			//07 - SER
	aAdd (aRegC100[nPos], aCmpAntSFT[1])  			   								//08 - NUM_DOC
		
	//³Obtem a chave da NF-e³
	If cEspecie$"55#65" 
		If aCmpAntSFT[6] >= CToD("01/01/2011")                    		// LayOut posterior a 01/01/2011 leva ChaveNFE
			aAdd (aRegC100[nPos], aCmpAntSFT[25])			 			//09 - CHV_NFE
		EndIf
		If aCmpAntSFT[6] < CToD("01/01/2011") .And. cSituaDoc=="02#03"     // LayOut anterior a 01/01/2011 e cancelado nao leva ChaveNFE    	
			aAdd (aRegC100[nPos], "")	
		EndIf	
		If aCmpAntSFT[6] < CToD("01/01/2011") .And. cSituaDoc<>"02#03"    // LayOut anterior a 01/01/2011 nao cancelado leva ChaveNFE    	
			aAdd (aRegC100[nPos], aCmpAntSFT[25])
		EndIf	
	Else
		aAdd (aRegC100[nPos], "")						  			//09 - CHV_NFE
	EndIf

	//³Tratamento para documentos cancelados, onde o menual diz que³
	//³  somente alguns campos devem ser informadoes               ³
	If cSituaDoc$"02#04#05#03"
		For nx := 10 to 29
			aAdd (aRegC100[nPos], "") 								//10 - N INFORMAR PARA DOC CANCELADO
		Next 
		If cSitDocInf$"08"
			aRegC100[nPos,10]	:= aCmpAntSFT[6]
			aRegC100[nPos,4]	:= Iif(cEspecie=="65","",aPartDoc[1])	//04 - COD_PART
		Endif 		
	Else
		aRegC100[nPos,4]	:= Iif(cEspecie=="65","",aPartDoc[1])	//04 - COD_PART		
		aAdd (aRegC100[nPos], aCmpAntSFT[6])		   				//10 - DT_DOC
		aAdd (aRegC100[nPos], Iif(!Empty(aCmpAntSFT[41]),aCmpAntSFT[41],aCmpAntSFT[5])) //11 - DT_E_S
		aAdd (aRegC100[nPos], aTotaliza[1])			 			//12 - VL_DOC
		//³Tratamento para gerar a condicao de pagamento da NF³
		If Len(aParcTit)==0
			aAdd (aRegC100[nPos], Iif(cVersao >= "006","2","9"))		//13 - IND_PAGTO - SEM PAGAMENTO
		ElseIf Len(aParcTit)>1
			aAdd (aRegC100[nPos], "1")	  						  	//13 - IND_PAGTO - A PRAZO
		ElseIf Len(aParcTit)==1 .And. aCmpAntSFT[6]==aParcTit[1,7]
			aAdd (aRegC100[nPos], "0")								//13 - IND_PAGTO - A VISTA			
		Else
			aAdd (aRegC100[nPos], "1")	  						  	//13 - IND_PAGTO - A PRAZO - campo é obrigatorio e nao pode ser levado em branco
		EndIf
		aAdd (aRegC100[nPos], aTotaliza[9])						//14 - VL_DESC
		aAdd (aRegC100[nPos], aTotaliza[26])						//15 - VL_ABAT_NT
		//³Tratamento para o valor da mercadoria quando a nota for Compl. ICMS/IPI³
		If cSituaDoc$"08" .Or. ( aCmpAntSFT[20] $ "IP" )			
			aAdd (aRegC100[nPos], 0)								//16 - VL_MERC
		Else
			aAdd (aRegC100[nPos], aTotaliza[10])					//16 - VL_MERC
		Endif
		aAdd (aRegC100[nPos], aCmpAntSFT[21])						//17 - IND_FRT
		aAdd (aRegC100[nPos], aTotaliza[11])						//18 - VL_FRT		-	FT_FRETE
		aAdd (aRegC100[nPos], aTotaliza[12])						//19 - VL_SEG		-	FT_SEGURO
		aAdd (aRegC100[nPos], aTotaliza[13])						//20 - VL_OUT_DA	-	FT_DESPESA
		aAdd (aRegC100[nPos], aTotaliza[2])					   	//21 - VL_BC_ICMS	-	FT_BASEICM
		aAdd (aRegC100[nPos], aTotaliza[3])					   	//22 - VL_ICMS		-	FT_VALICM
		aAdd (aRegC100[nPos], Iif(cEspecie=="65","",aTotaliza[4]))	//23 - VL_BC_ICMS_ST-	FT_BASERET
		aAdd (aRegC100[nPos], Iif(cEspecie=="65","",aTotaliza[5]))	//24 - VL_ICMS_ST	-	FT_ICMSRET
		aAdd (aRegC100[nPos], Iif(cEspecie=="65","",aTotaliza[6]))	//25 - VL_IPI		-	FT_VALIPI
		aAdd (aRegC100[nPos], Iif(cEspecie=="65","",Iif("1"$aWizard[1][15],Iif(lPisZero .Or. lOperGar,0,aTotaliza[19]),"")))		//26 - VL_PIS		-	FT_VALPIS 
		aAdd (aRegC100[nPos], Iif(cEspecie=="65","",Iif("1"$aWizard[1][15],Iif(lPisZero .Or. lOperGar,0,aTotaliza[20]),"")))		//27 - VL_COFINS	-	FT_VALCOF
		aAdd (aRegC100[nPos], Iif(cEspecie=="65","",Iif("1"$aWizard[1][15],aTotaliza[21],0)))//28 - VL_PIS_ST	-	FT_VALPS3
		aAdd (aRegC100[nPos], Iif(cEspecie=="65","",Iif("1"$aWizard[1][15],aTotaliza[22],0)))//29 - VL_COF_ST	-	FT_VALCF3
		//³Ponto de entrada para os campos 13(IND_PAGTO) e 17(IND_FRT)³
		If aExistBloc[11]
		   	aSpedC100 := ExecBlock("SPDFIS05",.F.,.F.,{"SFT",aCmpAntSFT,aRegC100}) 	
			aRegC100[nPos][13] := aSpedC100[01]
			aRegC100[nPos][17] := aSpedC100[02]
			If Len(aSpedC100) > 2
				aRegC100[nPos][03] := aSpedC100[03]
			Endif			
		Endif
	EndIf
	If cEspecie$"01#1B#04#55#65" 
		GrvRegTrS(cAlias,nRelac,aRegC100)
		lGrava0150 := !(cSituaDoc$"02#04#05#03") .and. !(cEspecie == "65") .Or. (cSituaDoc$"02#03" .And. cSitDocInf$"08")
	EndIf
EndIf
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC110   ³ Autor ³Gustavo G. Rueda       ³ Data ³14.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³           INFO COMPLEMENTAR DA NOTA FISCAL                 ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro c110                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com o embasamento legal para tais      ³±±
±±³          ³ observacoes (NAO EH NECESSARIAMENTE OBRIGATORIO            ³±±
±±³          ³ PARA CADA 0450)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3(1:N) Para cada C100                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aInfCompl -> Array com o registro do CDT                    ³±±
±±³          ³aRegC110  -> Array de estrutura do registro C110            ³±±
±±³          ³nPosC110  -> Posicao do array para relacionamento com os    ³±±
±±³          ³             registros filhos                               ³±±
±±³          ³aReg0450  -> Array de estrutura do registro 0450            ³±±
±±³          ³cAliasCDT -> Alias da tabela CDT				              ³±±
±±³          ³lTop  	-> Indica se eh ambiente top connect	          ³±±
±±³          ³aSpdInfC  -> Conteudo do PE SPDPISIC				          ³±±
±±³          ³aCmpAntSFT-> Campos da tabela SFT com informacoes do        ³±±
±±³          ³             documento em processamento                     ³±±
±±³          ³nMVSPDIFC -> Configuracao do parametro MV_SPDIFC	          ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegC110(aInfCompl,aRegC110,nPosC110,aReg0450,cAliasCDT,lTop,aSpdInfC,aCmpAntSFT,nMVSPDIFC,cOrigem,lRegEspPr)  
Local	cCDTChv		:= ""
Local	cTxtCompl	:= ""
Local	lSeekCCE	:=	.F.
Local	aInfSit	:= {"CANNFE",STR0036}
Default	aSpdInfC	:=	{}
Default	cAliasCDT 	:= ""
Default	cOrigem		:=	""
Default	lTop		:= .F.
Default	nMVSPDIFC	:=	aSPDSX6[MV_SPDIFC]
Default	lCmpDscComp	:=	aSPDSX3[FP_CDT_DCCOMP]
Default    lRegEspPr     := .F. 

//³ Gera C110 para registros que conte'm apenas INFORMACAO COMPLEMENTAR ³
//Crédito presumido Paraná
//Art. 69. Para a apropriação do crédito presumido, de que trata o Anexo III
If lRegEspPr
	aInfSit[1]	:=	"CRP"+right(alltrim(aCmpAntSFT[1]),3)	//NF	
	aInfSit[2]	:=	Formula(aCmpAntSFT[47])		//Obs
 	//³ Adiciona o registro C110 a ser gerado ³
	aAdd(aRegC110, {})
	nPosC110 :=	Len (aRegC110)
	aAdd(aRegC110[nPosC110], "C110")			//01 - REG
	aAdd(aRegC110[nPosC110], aInfSit[1])		//02 - COD_INF
	aAdd(aRegC110[nPosC110], aInfSit[2])		//03 - TXT_COMPL   
	//REGISTRO 0450 - TABELA DE INFORMACAO COMPLEMENTAR/OBSERVACAO
	Reg0450(aInfSit,@aReg0450)
Endif
If !Empty(cAliasCDT)                     
	cCDTChv := (cAliasCDT)->(CDT_FILIAL+CDT_TPMOV+CDT_DOC+CDT_SERIE+CDT_CLIFOR+CDT_LOJA) 
	While !(cAliasCDT)->(Eof())  .AND. ((cAliasCDT)->(CDT_FILIAL+CDT_TPMOV+CDT_DOC+CDT_SERIE+CDT_CLIFOR+CDT_LOJA)==cCDTChv)
		//³ Verifica se a informacao complementar ja foi encontrada nos outros complementos³
		If !(cAliasCDT)->(Empty(CDT_IFCOMP))  .And. (aScan(aRegC110,{|aX| aX[2]==(cAliasCDT)->CDT_IFCOMP}))==0
			lSeekCCE	:=	CCE->(MsSeek(xFilial("CCE")+(cAliasCDT)->CDT_IFCOMP))
			//----------------------------------
			//Composicao do Campo 03 - TXT_COMPL
			//----------------------------------
			cTxtCompl	:=	""
			Do Case
				//Descricao similar a do registro 0450
				Case nMVSPDIFC == 0 .And. lSeekCCE
					cTxtCompl	:=	CCE->CCE_DESCR					
				//Verifica Descricao Complementar a partir da tabela CDT (CDT_DCCOMP)
				Case nMVSPDIFC == 1 .And. !Empty((cAliasCDT)->CDT_DCCOMP)
					cTxtCompl	:=	(cAliasCDT)->CDT_DCCOMP
				//a posicao 44 do array aCmpAntSFT possui conte	udo do campo _MENNOTA (cabecalho da NF - F1 ou F2)
				Case nMVSPDIFC == 2 .And. aCmpAntSFT <> Nil .And. aCmpAntSFT[44] <> Nil .And. !Empty(aCmpAntSFT[44])
					cTxtCompl	:=	aCmpAntSFT[44]
			EndCase
			//Composicao do array a InfCompl    
			aInfCompl	:=	{(cAliasCDT)->CDT_IFCOMP, Iif( lSeekCCE , CCE->CCE_DESCR , ""  ) }       			
			//³ Adiciona o registro C110 a ser gerado ³
			aAdd(aRegC110, {})
			nPosC110 :=	Len (aRegC110)
			aAdd (aRegC110[nPosC110], "C110")											//01 - REG
			aAdd (aRegC110[nPosC110], aInfCompl[1])            						//02 - COD_INF
			aAdd (aRegC110[nPosC110], cTxtCompl)										//03 - TXT_COMPL   
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³REGISTRO 0450 - TABELA DE INFORMACAO COMPLEMENTAR/OBSERVACAO                            ³
			//|                                                                                        |
			//|Atribui os valores do array aReg0450 para efetuar a gravacao no final do processamento  |
			//| da rotina.                                                                             |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Reg0450(aInfCompl,@aReg0450)   
		EndIf
		(cAliasCDT)->(DbSkip()) 
	Enddo   

//³ Gera C110 a partir do Ponto de Entrada SPDPISIC	³
Elseif Len(aSpdInfC) > 0

 	//³ Adiciona o registro C110 a ser gerado ³
	aAdd(aRegC110, {})
	nPosC110 :=	Len (aRegC110)
	aAdd (aRegC110[nPosC110], "C110")			//01 - REG
	aAdd (aRegC110[nPosC110], aSpdInfC[1])		//02 - COD_INF
	aAdd (aRegC110[nPosC110], aSpdInfC[2])		//03 - TXT_COMPL   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³REGISTRO 0450 - TABELA DE INFORMACAO COMPLEMENTAR/OBSERVACAO                            ³
	//|                                                                                        |
	//|Atribui os valores do array aReg0450 para efetuar a gravacao no final do processamento  |
	//| da rotina.                                                                             |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Reg0450(aSpdInfC,@aReg0450)	

ElseIf cSitDocInf$"08"

 	//³ Adiciona o registro C110 a ser gerado ³
	aAdd(aRegC110, {})
	nPosC110 :=	Len (aRegC110)
	aAdd (aRegC110[nPosC110], "C110")			//01 - REG
	aAdd (aRegC110[nPosC110], aInfSit[1])		//02 - COD_INF
	aAdd (aRegC110[nPosC110], aInfSit[2])		//03 - TXT_COMPL   

	//³REGISTRO 0450 - TABELA DE INFORMACAO COMPLEMENTAR/OBSERVACAO                            ³
	//|Atribui os valores do array aReg0450 para efetuar a gravacao no final do processamento  |
	//| da rotina.                                                                             |	
	Reg0450(aInfSit,@aReg0450)	


Else 

	If Len(aInfCompl)==2 .And. !Empty(aInfCompl[1])
		
			//³Tratamento para quando a descricao do lancamento nao for passada³
			
	 Do Case
	       // Tratamento implemtado através do chamado TSCFIU, caso a RegC110 ³
		   // seja invocada sem os parammetros necessários, preciso validar se³
		   // as condições para respeitar o parâmetro MV_SPDIFC são atendidas.³
		   
    	 Case nMVSPDIFC == 0 .And.  CCE->(MsSeek(xFilial("CCE")+aInfCompl[1]))
				If (aInfCompl[2]==Nil  .Or. Empty(aInfCompl[2])) 
					aInfCompl[2]	:=	CCE->CCE_DESCR
				EndIf 
		Case nMVSPDIFC == 1 	.And. lCmpDscComp .And. CDT->(MsSeek(xFilial("CDT")+aCmpAntSFT[43]+aCmpAntSFT[1]+aCmpAntSFT[2]+aCmpAntSFT[3]+aCmpAntSFT[4]))
		      If (aInfCompl[2]==Nil  .Or. Empty(aInfCompl[2])) 
					aInfCompl[2]	:=	CDT->CDT_DCCOMP
			  EndIf  
		Case nMVSPDIFC == 2 .And. aCmpAntSFT <> Nil .And. aCmpAntSFT[44] <> Nil .And. !Empty(aCmpAntSFT[44])
					aInfCompl[2]	:=	aCmpAntSFT[44]
		EndCase	
			//³Tratamento para quando a descricao do lancamento nao for passada³
			If (aInfCompl[2]==Nil  .Or. Empty(aInfCompl[2])) .And. CCE->(MsSeek(xFilial("CCE")+aInfCompl[1]))
				aInfCompl[2]	:=	CCE->CCE_DESCR
			EndIf 
			//³Tratamento para retornar o nPos do C110 para amarrar aos outros registros³
			If (nPosC110 := aScan(aRegC110,{|aX| aX[2]==aInfCompl[1]}))==0
				aAdd(aRegC110, {})
				nPosC110 :=	Len (aRegC110)
				aAdd (aRegC110[nPosC110], "C110")											//01 - REG
				aAdd (aRegC110[nPosC110], aInfCompl[1])            						//02 - COD_INF
				aAdd (aRegC110[nPosC110], Iif(Empty(cTxtCompl),aInfCompl[2],cTxtCompl))	//03 - TXT_COMPL
			EndIf
	EndIf    
EndIf 
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC111   ³ Autor ³Gustavo G. Rueda       ³ Data ³14.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³                     NORMA REFERENCIADA                     ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro 0450, C110 e C111          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com o embasamento legal para tais      ³±±
±±³          ³ observacoes                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³4(1:N) Para cada C110                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAliasCDG-> Alias da tabela CDG filtrada (query ou indregua)³±±
±±³          ³aRegC110 -> Array com a estrutura do C110 gerado ateh o     ³±±
±±³          ³            momento.                                        ³±±
±±³          ³aReg0450 -> Array com a estrutura do 0450 gerado ateh o     ³±±
±±³          ³            momento.                                        ³±±
±±³          ³aRegC111 -> Array com a estrutura do registro a ser gravado ³±±
±±³          ³lTop     -> Flag de indicacao de ambiente TOP ou DBF        ³±± 
±±³          ³aCmpAntSFT-> Campos da tabela SFT com informacoes do        ³±±
±±³          ³             documento em processamento                     ³±± 
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegC111(cAliasCDG,aRegC110,aReg0450,aRegC111,lTop,aCmpAntSFT,cSitDocInf,cProtocolo)
Local	nPosC111	:=	1
Local	nPosC110	:=	1
Local	aInfCompl	:=	{}
Local 	cCDGChv		:= (cAliasCDG)->(CDG_FILIAL+CDG_TPMOV+CDG_DOC+CDG_SERIE+CDG_CLIFOR+CDG_LOJA)                                                        

Default cSitDocInf := "" 
//³Esta tabela jah estah filtrada, QUERY ou INDREGUA³
While !(cAliasCDG)->(Eof()) .AND. ( (cAliasCDG)->(CDG_FILIAL+CDG_TPMOV+CDG_DOC+CDG_SERIE+CDG_CLIFOR+CDG_LOJA)==cCDGChv)

	//³Processo o mesmo codigo de OBS da CDT e da CDG³
	If !(cAliasCDG)->(Empty(CDG_IFCOMP))

		//³Tratamento para evitar duplicidade no registro C110³
		If (nPosC110 := aScan(aRegC110,{|aX|aX[2]==(cAliasCDG)->CDG_IFCOMP}))==0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³DBF/ADS nao tem JOIN, preciso fazer o SEEK, e a funcao Reg0450³
			//|faz automaticamente quando a descricao estah com NIL          |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aInfCompl	:=	{(cAliasCDG)->CDG_IFCOMP,}
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³REGISTRO C110 - INFORMACAO COMPLEMENTAR DA NOTA FISCAL (CODIGO 01, 04 E 55)             ³
			//|                                                                                        |
			//|Funca que gera a estrutura dos registros acima e os grava no final do processamento do  |
			//|  documento fiscal                                                                      |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RegC110(@aInfCompl,@aRegC110,@nPosC110,,,,,aCmpAntSFT)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³REGISTRO 0450 - TABELA DE INFORMACAO COMPLEMENTAR/OBSERVACAO                            ³
			//|                                                                                        |
			//|Atribui os valores do array aReg0450 para efetuar a gravacao no final do processamento  |
			//| da rotina.                                                                             |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Reg0450(aInfCompl,@aReg0450)
		EndIf
		//³verifica se jah nao foi adicionado antes³
		If (nPosC111 := aScan(aRegC111,{|aX| aX[1]==nPosC110 .And. aX[3]==(cAliasCDG)->CDG_PROCES}))==0
			aAdd(aRegC111, {})
			nPosC111 := Len(aRegC111)
			aAdd (aRegC111[nPosC111], nPosC110)						//Relacionamento com o registro pai
			aAdd (aRegC111[nPosC111], "C111")			 			//01 - REG
			aAdd (aRegC111[nPosC111], (cAliasCDG)->CDG_PROCES)		//02 - NUM_PROC
			aAdd (aRegC111[nPosC111], (cAliasCDG)->CDG_TPPROC)		//03 - IND_PROC			
		EndIf
	Endif
	(cAliasCDG)->(DbSkip())	
End
If cSitDocInf$"08"		
		//³REGISTRO C110 - INFORMACAO COMPLEMENTAR DA NOTA FISCAL (CODIGO 01, 04 E 55)             ³
		//|Funca que gera a estrutura dos registros acima e os grava no final do processamento do  |
		//|  documento fiscal                                                                      |
		If (nPosC110 := aScan(aRegC110,{|aX|aX[2]==cProtocolo}))==0
			RegC110(aInfSit,@aRegC110,@nPosC110,@aReg0450,,,,aCmpAntSFT)
			//³REGISTRO 0450 - TABELA DE INFORMACAO COMPLEMENTAR/OBSERVACAO                            ³
			//|Atribui os valores do array aReg0450 para efetuar a gravacao no final do processamento  |
			//| da rotina.                                                                             |
			Reg0450(aInfSit,@aReg0450)
		Endif
		
		If (nPosC111 := aScan(aRegC111,{|aX| aX[1]==nPosC110 .And. aX[3]==cProtocolo}))==0
			aAdd(aRegC111, {})
			nPosC111 := Len(aRegC111)
			aAdd (aRegC111[nPosC111], nPosC110)						//Relacionamento com o registro pai
			aAdd (aRegC111[nPosC111], "C111")			 			//01 - REG
			aAdd (aRegC111[nPosC111], cProtocolo)		//02 - NUM_PROC
			aAdd (aRegC111[nPosC111], "9")		//03 - IND_PROC			
		EndIf
Endif

Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC112   ³ Autor ³Gustavo G. Rueda       ³ Data ³14.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³           DOCUMENTO DE ARRECADACAO REFERENCIADO            ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro 0450, C110 e C112          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com todas as guias de recolhimento com ³±±
±±³          ³ a data de referencia no periodo apurado.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³4(1:N) para cada Registro C110                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAliasCDC-> Alias da tabela CDC filtrada (query ou indregua)³±±
±±³          ³aRegC110 -> Array com a estrutura do C110 gerado ateh o     ³±±
±±³          ³            momento.                                        ³±±
±±³          ³lTop     -> Flag de ambiente TOP(.t.) ou DBF                ³±±
±±³          ³aReg0450 -> Array com a estrutura do 0450 gerado ateh o     ³±±
±±³          ³            momento.                                        ³±±
±±³          ³aRegC112 -> Array com a estrutura do registro a ser gravado ³±±
±±³          ³aIcmPago -> Array com as GNREs de ICMSST para gerar o       ³±±
±±³          ³            registro E250                                   ³±±
±±³          ³aCmpAntSFT-> Campos da tabela SFT com informacoes do        ³±±
±±³          ³             documento em processamento                     ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegC112(cAliasCDC,aRegC110,lTop,aReg0450,aRegC112,aIcmPago,aCmpAntSFT)

//Local	lRet		:= .T.
Local	nPosC112	:= 1
Local	nPosC110	:= 1 
Local	nMVSPDIFC	:=	aSPDSX6[MV_SPDIFC]
Local	cAliasSF6	:= "SF6"
Local	aInfCompl	:= {}
Local 	cCDCChv		:= ""

cCDCChv :=  (cAliasCDC)->(CDC_FILIAL+CDC_TPMOV+CDC_DOC+CDC_SERIE+CDC_CLIFOR+CDC_LOJA) 
//³Esta tabela jah estah filtrada, QUERY ou INDREGUA³
While !(cAliasCDC)->(Eof()) .AND. ( (cAliasCDC)->(CDC_FILIAL+CDC_TPMOV+CDC_DOC+CDC_SERIE+CDC_CLIFOR+CDC_LOJA)==cCDCChv)

	//³Processo o mesmo codigo de OBS da CDT e da CDG³
	If !(cAliasCDC)->(Empty(CDC_IFCOMP))
		//³Tratamento para evitar duplicidade no registro C110³
		If (nPosC110 := aScan(aRegC110,{|aX|aX[2]==(cAliasCDC)->CDC_IFCOMP}))==0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³DBF/ADS nao tem JOIN, preciso fazer o SEEK, e a funcao Reg0450³
			//|faz automaticamente quando a descricao estah com NIL          |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aInfCompl	:=	{(cAliasCDC)->CDC_IFCOMP,(cAliasCDC)->CDC_DCCOMP}
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³REGISTRO C110 - INFORMACAO COMPLEMENTAR DA NOTA FISCAL (CODIGO 01, 04 E 55)             ³
			//|                                                                                        |
			//|Funca que gera a estrutura dos registros acima e os grava no final do processamento do  |
			//|  documento fiscal                                                                      |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RegC110(@aInfCompl,@aRegC110,@nPosC110,@aReg0450,,,,aCmpAntSFT,nMVSPDIFC,"CDC")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³REGISTRO 0450 - TABELA DE INFORMACAO COMPLEMENTAR/OBSERVACAO                            ³
			//|                                                                                        |
			//|Atribui os valores do array aReg0450 para efetuar a gravacao no final do processamento  |
			//| da rotina.                                                                             |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aInfCompl	:=	{(cAliasCDC)->CDC_IFCOMP,}	//tratamento para que o registro 0450 seja gerado a partir da CCE
			Reg0450(aInfCompl,@aReg0450)
		EndIf
		//³verifica se jah nao foi adicionado antes³
		If (nPosC112 := aScan(aRegC112,{|aX| aX[1]==nPosC110 .And. aX[4]==(cAliasCDC)->CDC_UF .And. aX[5]==(cAliasCDC)->CDC_GUIA}))==0
			//³Para TOP nao preciso dar SEEK, pois jah estah no JOIN³
			If SpedSeek( cAliasSF6,1,xFilial(cAliasSF6)+(cAliasCDC)->(CDC_UF+CDC_GUIA))
				aAdd(aRegC112, {})
				nPosC112 := Len(aRegC112)
				aAdd (aRegC112[nPosC112], nPosC110)								//Relacionamento com o registro pai
				aAdd (aRegC112[nPosC112], "C112")								//01 - REG
				If (cAliasSF6)->F6_TIPOIMP=="0"
					aAdd (aRegC112[nPosC112], "0")								//02 - COD_DA - Uso 0 quando for uma guia estadual. Exemplo ES=DUA (documento unico de arrecadacao)
				Else
					aAdd (aRegC112[nPosC112], "1")								//02 - COD_DA
				EndIf
				aAdd (aRegC112[nPosC112], (cAliasCDC)->CDC_UF)					//03 - UF
				aAdd (aRegC112[nPosC112], (cAliasCDC)->CDC_GUIA)				//04 - NUM_DA
				aAdd (aRegC112[nPosC112],(cAliasSF6)->F6_AUTENT)		    //05 - COD_AUT
				aAdd (aRegC112[nPosC112], (cAliasSF6)->F6_VALOR)				//06 - VL_DA
				aAdd (aRegC112[nPosC112], (cAliasSF6)->F6_DTVENC)				//07 - DT_VCTO
				aAdd (aRegC112[nPosC112], Iif(!Empty((cAliasSF6)->F6_DTPAGTO), (cAliasSF6)->F6_DTPAGTO, (cAliasSF6)->F6_DTVENC))			//08 - DT_PGTO
			EndIf
		EndIf
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para adicionar em um array as GNREs de ICMS/ST geradas por           ³
	//³  documento fiscal para gerar depois as respectivas informacoes no registro E250³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	SpdGnreDoc(@aIcmPago, cAliasSF6, cAliasCDC)
	
	(cAliasCDC)->(DbSkip())
Enddo
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC113   ³ Autor ³Gustavo G. Rueda       ³ Data ³14.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³               DOCUMENTO FISCAL REFERENCIADO                ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro 0450, C110 e C113          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoes de todos os docu-   ³±±
±±³          ³ mentos fiscais processados.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³4(1:N) Para cada Registro C110                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias   -> Alias da tabela de trabalho da rotina           ³±±
±±³          ³cAliasCDD-> Alias da tabela CDD filtrada (query ou indregua)³±±
±±³          ³aRegC110 -> Array com a estrutura do C110 gerado ateh o     ³±±
±±³          ³            momento.                                        ³±±
±±³          ³aReg0450 -> Array com a estrutura do 0450 gerado ateh o     ³±±
±±³          ³            momento.                                        ³±±
±±³          ³cEntSai -> Flag de indicacao do documento fiscal, 1=Entrada/³±±
±±³          ³ 2=Saida.                                                   ³±±
±±³          ³aCmpAntSFT-> Campos da tabela SFT com informacoes do        ³±±
±±³          ³             documento em processamento                     ³±±
±±³          ³aReg0150  -> Array com as informacoes do participante       ³±±
±±³          ³aRegC113 -> Array com a estrutura do registro a ser gravado ³±±
±±³          ³aWizard  -> Array com as informacoes do wizard da rotina    ³±±
±±³          ³lTop     -> Flag de indicacao de ambiente TOP ou DBF        ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegC113(cAlias,cAliasCDD,aRegC110,aReg0450,cEntSai,aCmpAntSFT,aReg0150,aRegC113,aWizard,lTop)
Local	lRet   		:=	.T.
Local	nPos		:=	0
Local	nPosC110	:=	1
Local	aInfCompl	:=	{}
Local	aAreaSF1	:=	SF1->(GetArea ())
Local	aAreaSA1	:=	SA1->(GetArea ())
Local	aAreaSF2	:=	SF2->(GetArea ())
Local	aAreaSA2	:=	SA2->(GetArea ()) 
Local	aPartDoc	:=	{}
Local	cIndEmit 	:=	""
Local	cIndOper 	:=	""
Local	cCodMod  	:=	""
Local	dDtEmiss 	:=	CToD ("//")                                                                
Local 	cCDDChv		:= (cAliasCDD)->(CDD_FILIAL+CDD_TPMOV+CDD_DOC+CDD_SERIE+CDD_CLIFOR+CDD_LOJA)
Local  cCodPArt		:= ''


//Esta tabela jah estah filtrada, QUERY ou INDREGUA

While !(cAliasCDD)->(Eof())  .AND. ((cAliasCDD)->(CDD_FILIAL+CDD_TPMOV+CDD_DOC+CDD_SERIE+CDD_CLIFOR+CDD_LOJA)==cCDDChv)

	//Processo o mesmo codigo de OBS da CDT e da CDG
	
	If !(cAliasCDD)->(Empty(CDD_IFCOMP))
		
		//Posiciono o documento orifinal para obter algumas informacoes
		//  para montar o registro
		
		If (cEntSai=="1" .And. aCmpAntSFT[20]$"DB") .Or. (cEntSai=="2" .And. !aCmpAntSFT[20]$"DB")

	 		If cEntSai=="2" .And. Empty(aCmpAntSFT[20]) //Tratamento para Devolução de Beneficiamento - Poder de Terceiros - Saída Normal
	 			If !SF1->(MsSeek(xFilial("SF1")+(cAliasCDD)->(CDD_DOCREF+CDD_SERREF+CDD_PARREF+CDD_LOJREF)))
					lRet := .F.
				Else
					cIndEmit := Iif(SF1->F1_FORMUL=="N","1","0")
					cIndOper := "1"
					cCodMod  := aModNot(SF1->F1_ESPECIE)
					dDtEmiss := SF1->F1_EMISSAO		
					
					If SA1->(MsSeek (xFilial ("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))
						aPartDoc :=	InfPartDoc ("SA1")
						
						//GRAVACAO REGISTRO 0150 - TABELA DE CADASTRO DE PARTICIPANTES
						//GRAVACAO REGISTRO 0175 - ALTERACAO DA TABELA DE CADASTRO DE PARTICIPANTE
						
						SDPF150175(@aReg0150,aPartDoc,cAlias,aWizard,aExistBloc)
					Else
						lRet := .F.
					EndIf	
				Endif
	 		Else
	 			If !SF2->(MsSeek(xFilial("SF2")+(cAliasCDD)->(CDD_DOCREF+CDD_SERREF+CDD_PARREF+CDD_LOJREF)))
					lRet := .F.
				Else
					cIndEmit := Iif(SF2->F2_FORMUL=="N","1","0")
					cIndOper := "1"
					cCodMod  := aModNot(SF2->F2_ESPECIE)
					dDtEmiss := SF2->F2_EMISSAO		

					//Armazeno código participante documento original
					cCodPArt		:= SF2->F2_CLIENTE+SF2->F2_LOJA					
					If cEntSai=="1" .AND. cCodMod == '65' .And. aCmpAntSFT[20]$"DB"
						//Caso for devolução de venda de NFCE, então irei considerar o participante do documento de devolução
						//pois pode ser diferente do participante do documento de venda para este modelo de documento.
						cCodPArt		:= aCmpAntSFT[3]+aCmpAntSFT[4]
					EndIF

					If SA1->(MsSeek (xFilial ("SA1")+ cCodPArt))					
						aPartDoc :=	InfPartDoc ("SM0")
						
						//GRAVACAO REGISTRO 0150 - TABELA DE CADASTRO DE PARTICIPANTES
						//GRAVACAO REGISTRO 0175 - ALTERACAO DA TABELA DE CADASTRO DE PARTICIPANTE
						
						SDPF150175(@aReg0150,aPartDoc,cAlias,aWizard,aExistBloc)
					Else
						lRet := .F.
					EndIf			
				Endif
	 		EndIf
		Else
			If !SF1->(MsSeek(xFilial("SF1")+(cAliasCDD)->(CDD_DOCREF+CDD_SERREF+CDD_PARREF+CDD_LOJREF)))
				
				//Nos casos de nota fiscal de remessa o array aCmpAntSFT[20] esta vazio,
				//e o manual pede que seja gerado o registro C113, desta forma foi incluido
				//o tratamento abaixo, onde caso a NF de origem nao seja encontrada na entrada 
				//(SF1) eh realizada uma busca nas saidas (SF2), em seguida busca-se na SA2
				//as informacaoes do fornecedor, pois a nota de saida eh de remessa, ou seja,
				//utiliza fornecedor ao inves de cliente.
						
				If !SF2->(MsSeek(xFilial("SF2")+(cAliasCDD)->(CDD_DOCREF+CDD_SERREF+CDD_PARREF+CDD_LOJREF)))
					lRet := .F.
				Else
					cIndEmit := Iif(SF2->F2_FORMUL=="N","1","0")
					cIndOper := "1"
					cCodMod  := aModNot(SF2->F2_ESPECIE)
					dDtEmiss := SF2->F2_EMISSAO							
					
					If SA2->(MsSeek (xFilial ("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA))
						aPartDoc :=	InfPartDoc ("SM0")
		
						//GRAVACAO REGISTRO 0150 - TABELA DE CADASTRO DE PARTICIPANTES
						//GRAVACAO REGISTRO 0175 - ALTERACAO DA TABELA DE CADASTRO DE PARTICIPANTE
						
						SDPF150175(@aReg0150,aPartDoc,cAlias,aWizard,aExistBloc)
					Else
						lRet := .F.
					EndIf									
				EndIf								
			Else
				cIndEmit := Iif(SF1->F1_FORMUL=="S","0","1")
				cIndOper := "0"
				cCodMod  := aModNot(SF1->F1_ESPECIE)
				dDtEmiss := SF1->F1_EMISSAO

				If SA2->(MsSeek (xFilial ("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA))
					aPartDoc :=	InfPartDoc ("SA2")
					
					//GRAVACAO REGISTRO 0150 - TABELA DE CADASTRO DE PARTICIPANTES
					//GRAVACAO REGISTRO 0175 - ALTERACAO DA TABELA DE CADASTRO DE PARTICIPANTE
					
					SDPF150175(@aReg0150,aPartDoc,cAlias,aWizard,aExistBloc)
				Else
					lRet := .F.
				EndIf
			Endif
		Endif
		
		//Nao preciso verificar a existencia antes de incluir, pois a chave unica da tabela
		//  jah nao permite repetir o cadastro
		
		If lRet
			
			//Tratamento para evitar duplicidade no registro C110
			
			If (nPosC110 := aScan(aRegC110,{|aX|aX[2]==(cAliasCDD)->CDD_IFCOMP}))==0
				
				//DBF/ADS nao tem JOIN, preciso fazer o SEEK, e a funcao Reg0450
				//faz automaticamente quando a descricao estah com NIL
				
				aInfCompl	:=	{(cAliasCDD)->CDD_IFCOMP,}
				
				//REGISTRO C110 - INFORMACAO COMPLEMENTAR DA NOTA FISCAL (CODIGO 01, 04 E 55)
				//Funca que gera a estrutura dos registros acima e os grava no final do processamento do
				// documento fiscal
				
				RegC110(@aInfCompl,@aRegC110,@nPosC110,,,,,aCmpAntSFT)
				
				//REGISTRO 0450 - TABELA DE INFORMACAO COMPLEMENTAR/OBSERVACAO
				//Atribui os valores do array aReg0450 para efetuar a gravacao no final do processamento
				// da rotina.

				Reg0450(aInfCompl,@aReg0450)
			EndIf
			aAdd(aRegC113, {})
			nPos	:=	Len (aRegC113)
			aAdd (aRegC113[nPos], nPosC110)									//Relacionamento com o registro pai
			aAdd (aRegC113[nPos], "C113")	 	   							//01 - REG
			aAdd (aRegC113[nPos], cIndOper)									//02 - IND_OPER	
			aAdd (aRegC113[nPos], cIndEmit)	 				   				//03 - IND_EMIT
			aAdd (aRegC113[nPos], Iif(Len(aPartDoc)>=1,aPartDoc[1],""))	//04 - COD_PART
			aAdd (aRegC113[nPos], cCodMod)		 							//05 - COD_MOD
			aAdd (aRegC113[nPos], (cAliasCDD)->CDD_SERREF)	 				//06 - SER
			aAdd (aRegC113[nPos], "")				 						//07 - SUB
			aAdd (aRegC113[nPos], (cAliasCDD)->CDD_DOCREF) 				//08 - NUM_DOC
			aAdd (aRegC113[nPos], dDtEmiss)	 			   					//09 - DT_DOC 
			IF cVersao >= "011"				
				aAdd (aRegC113[nPos], Iif(aSPDSX3[FP_CDD_CHVNFE],(cAliasCDD)->CDD_CHVNFE,'')) 			//10 - CHV_DOCe
			Endif
		EndIf
    EndIf
	(cAliasCDD)->(dbSkip())
End
RestArea(aAreaSF1)
RestArea(aAreaSF2)
RestArea(aAreaSA1)
RestArea(aAreaSA2)

Return(lRet)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC114   ³ Autor ³Gustavo G. Rueda       ³ Data ³14.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³                CUPOM FISCAL REFERENCIADO                   ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro 0450, C110 e C114          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoes de todos os docu-   ³±±
±±³          ³ mentos fiscais processados.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³4(1:N) Para cada Registro C110                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAliasCDE-> Alias da tabela CDE filtrada (query ou indregua)³±±
±±³          ³aRegC110 -> Array com a estrutura do C110 gerado ateh o     ³±±
±±³          ³            momento.                                        ³±±
±±³          ³aReg0450 -> Array com a estrutura do 0450 gerado ateh o     ³±±
±±³          ³            momento.                                        ³±±
±±³          ³aCmpAntSFT-> Campos da tabela SFT com informacoes do        ³±±
±±³          ³             documento em processamento                     ³±±
±±³          ³aRegC114 -> Array com a estrutura do registro a ser gravado ³±±
±±³          ³lSemCDE  -> Quando nao tiver CDE (.T.), deve processar uma  ³±±
±±³          ³            unica vez e fazer o mesmo fluxo como se tivesse,³±± 
±±³          ³            pois eh um tratamento para quando houver        ³±±
±±³          ³            integracao com o SIGALOJA, com isso nao exigimos³±± 
±±³          ³            uma amarracao via complemento, uso a integracao ³±±
±±³          ³            direto                                          ³±±
±±³          ³cNFCupom -> Conteudo do campo F2_NFCUPOM                    ³±±
±±³          ³lTop     -> Flag de indicacao de ambiente TOP ou DBF        ³±±  
±±³          ³cEntSai -> Flag de indicacao do documento fiscal, 1=Entrada/³±±
±±³          ³2=Saida.  												  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegC114(cAliasCDE,aRegC110,aReg0450,aCmpAntSFT,aRegC114,cCodCompl,cNFCupom,lTop,cEntSai)
Local	lRet   		:=	.T.
Local	nPos		:=	0
Local	aAreaSF2	:=	SF2->(GetArea())
Local	cSerCp		:=	""
Local	cCupom		:=	""
Local	cEspecCp	:=	""
Local	dDtCupom	:=	""
Local   cECFFAB     := 	""
Local   cECFCX		:= 	""
Local   cCPREF		:= 	""
Local   cPdv        := 	""
Local	lProcUma	:=	Iif(cCodCompl==Nil,.F.,Iif(Empty(cCodCompl),.F.,.T.))	//Irah processar quando houver CDE ou quando houver pelo menos 1 codigo (cCodCompl<>"")
Local	nPosC110	:=	1
Local	aInfCompl	:=	{}
Local	cDescCompl	:=	Nil     
Local 	cCDEChv		:= (cAliasCDE)->(CDE_FILIAL+CDE_TPMOV+CDE_DOC+CDE_SERIE+CDE_CLIFOR+CDE_LOJA)

Default	cCodCompl	:=	""
Default	cNFCupom	:=	""

cSerCp		:=	Padr(SubStr(cNFCupom,1,TamSx3("F2_SERIE")[1]),TamSx3("F2_SERIE")[1])
cCupom		:=	Padr(SubStr(cNFCupom,TamSx3("F2_SERIE")[1]+1,TamSx3("F2_DOC")[1]+TamSx3("F2_SERIE")[1]),TamSx3("F2_DOC")[1])

//³Esta tabela jah estah filtrada, QUERY ou INDREGUA³
While ( !(cAliasCDE)->(Eof()) .AND. ((cAliasCDE)->(CDE_FILIAL+CDE_TPMOV+CDE_DOC+CDE_SERIE+CDE_CLIFOR+CDE_LOJA)==cCDEChv)   ) .Or. lProcUma

	cCodCompl	:=	Iif(!lProcUma,(cAliasCDE)->CDE_IFCOMP,cCodCompl)    

	//³Processo o mesmo codigo de OBS da CDT e da CDG³
	If !Empty(cCodCompl)
		//³Posiciona no cupom de origem³
		If cEntSai == "1" .And. aCmpAntSFT[20]$"DB"		
			cCupom	:=	aCmpAntSFT[38]
			cSerCp	:=	aCmpAntSFT[39]        
		//³Tratamento para quando nao tiver SIGALOJA, ae o complemento eh ³
		//³   feito manualemten no documento.                             ³
		//³                                                               ³
		//³Se tiver SIGALOJA, o campo NFCUPOM vai estar preenchido        ³
        ElseIf Empty(cNFCupom)
			cCupom	:=	(cAliasCDE)->CDE_CPREF
			cSerCp	:=	(cAliasCDE)->CDE_SERREF										
        EndIF
		cCPREF		:= cCupom
		If !SF2->(MsSeek(xFilial("SF2")+cCupom+cSerCp))
			lRet 		:= 	.F.
		Else
			//FT_PDV somente estarah alimentado quando se referir a nota fiscais de saida geradas pelo SIGALOJA.
           If !Empty(SF2->F2_PDV) .AND. AllTrim(SF2->F2_ESPECIE)$"CF|ECF"           
              cEspecCp	:=	"2D"
           Else          
              cEspecCp 	:= 	aModNot(SF2->F2_ESPECIE)
           Endif
              dDtCupom 	:= 	SF2->F2_EMISSAO
              cPdv 		:= 	SF2->F2_PDV
		Endif

        If lRet
			//³Se tiver PDV relacionado ao documento fiscal e o mesmo existir na tabela SFI,³
			//³ utilizo os dados da mesma, caso contrario, utilizo os dados do complemento  ³
		    If !Empty(cPdv) .And. SFI->(MsSeek(xFilial("SFI")+Iif(SFI->(IndexOrd())==1,Dtos(dDtCupom)+cPdv,cPdv+Dtos(dDtCupom))))
		    	
		    	cECFFAB     := SFI->FI_SERPDV
				cECFCX		:= SFI->FI_PDV
			Else 
				cECFFAB     := (cAliasCDE)->CDE_ECFFAB
				cECFCX		:= (cAliasCDE)->CDE_ECFCX
			EndIf
			//³Tratamento para evitar duplicidade no registro C110³
			If (nPosC110 := aScan(aRegC110,{|aX|aX[2]==cCodCompl}))==0
				aInfCompl	:=	{cCodCompl,cDescCompl}
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³REGISTRO C110 - INFORMACAO COMPLEMENTAR DA NOTA FISCAL (CODIGO 01, 04 E 55)             ³
				//|                                                                                        |
				//|Funca que gera a estrutura dos registros acima e os grava no final do processamento do  |
				//|  documento fiscal                                                                      |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RegC110(@aInfCompl,@aRegC110,@nPosC110,,,,,aCmpAntSFT)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³REGISTRO 0450 - TABELA DE INFORMACAO COMPLEMENTAR/OBSERVACAO                            ³
				//|                                                                                        |
				//|Atribui os valores do array aReg0450 para efetuar a gravacao no final do processamento  |
				//| da rotina.                                                                             |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Reg0450(aInfCompl,@aReg0450)
			EndIf	
			//³verifica se jah nao foi adicionado antes³
			If (nPos := aScan(aRegC114,{|aX| aX[1]==nPosC110 .And. aX[3]==cEspecCp .And. aX[4]==cECFFAB .And. aX[5]==Right(AllTrim(cECFCX),3) .And. aX[6]==cCPREF .And. aX[7]==dDtCupom}))==0	
				aAdd(aRegC114, {})
				nPos	:=	Len(aRegC114)
				aAdd (aRegC114[nPos], nPosC110)					//Relacionamento com o registro pai
				aAdd (aRegC114[nPos], "C114")	 	   			//01 - REG
				aAdd (aRegC114[nPos], cEspecCp)					//02 - COD_MOD
				aAdd (aRegC114[nPos], cECFFAB)					//03 - ECF_FAB
				aAdd (aRegC114[nPos], Right(AllTrim(cECFCX),3))//04 - ECF_CX
				aAdd (aRegC114[nPos], cCPREF)			 		//05 - NUM_DOC
				aAdd (aRegC114[nPos], dDtCupom)	 				//06 - DT_DOC
			EndIf
		EndIf
    EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quando for para processar somente uma vez, deve fazer o mesmo fluxo         ³
	//³ como se tivesse, pois eh um tratamento para quando houver integracao com o ³
	//³ SIGALOJA, com isso nao exigimos uma amarracao via complemento, uso a       ³
	//³ integracao direto                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If lProcUma
    	Exit
    EndIf
    (cAliasCDE)->(dbSkip())
End
RestArea(aAreaSF2)
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC115   ³ Autor ³Gustavo G. Rueda       ³ Data ³14.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³               LOCAL DE COLETA/ENTREGA                      ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro 0450, C110 e C115          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoes de todos os docu-   ³±±
±±³          ³ mentos fiscais processados.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³4(1:N) Para cada Registro C110                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAliasCDF-> Alias da tabela CDE filtrada (query ou indregua)³±±
±±³          ³aRegC110 -> Array com a estrutura do C110 gerado ateh o     ³±±
±±³          ³            momento.                                        ³±±
±±³          ³aReg0450 -> Array com a estrutura do 0450 gerado ateh o     ³±±
±±³          ³            momento.                                        ³±±
±±³          ³aCmpAntSFT-> Campos da tabela SFT com informacoes do        ³±±
±±³          ³             documento em processamento                     ³±±
±±³          ³aRegC115 -> Array com a estrutura do registro a ser gravado ³±±
±±³          ³lTop     -> Flag de indicacao de ambiente TOP ou DBF        ³±±  
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegC115(cAliasCDF,aRegC110,aReg0450,aCmpAntSFT,aRegC115,lTop)
Local	nPos		:=	0
Local	aAreaSA1	:=	SA1->(GetArea())
Local	aAreaSA2	:=	SA2->(GetArea())
Local	cCnpjCol	:=	""
Local	cIeCol		:=	""
Local	cCpfCol		:=	""
Local	cMunCol		:=	""
Local	cCnpjEnt	:=	""
Local	cIeEnt		:=	""
Local	cCpfEnt		:=	""
Local	cMunEnt		:=	""
Local	cChaveCol	:=	""
Local	cChaveEnt	:=	""
Local	nPosC110	:=	1
Local	aInfCompl	:=	{}       
Local 	cCDFChv		:= (cAliasCDF)->(CDF_FILIAL+CDF_TPMOV+CDF_DOC+CDF_SERIE+CDF_CLIFOR+CDF_LOJA)
                                                                          
//³Esta tabela jah estah filtrada, QUERY ou INDREGUA³
While !(cAliasCDF)->(Eof())   .AND. ( (cAliasCDF)->(CDF_FILIAL+CDF_TPMOV+CDF_DOC+CDF_SERIE+CDF_CLIFOR+CDF_LOJA)==cCDFChv)
	//³Processo o mesmo codigo de OBS da CDT e da CDG³
	If !(cAliasCDF)->(Empty(CDF_IFCOMP))

		//³Dados da   coleta³
		cChaveCol	:=	(cAliasCDF)->(CDF_COLETA+CDF_LOJCOL)
		cChaveCol	:=	Iif(Empty(cChaveCol),aCmpAntSFT[3]+aCmpAntSFT[4],cChaveCol)
		//³Dados da entrega³
		cChaveEnt	:=	(cAliasCDF)->(CDF_ENTREG+CDF_LOJENT)
		cChaveEnt	:=	Iif(Empty(cChaveEnt),aCmpAntSFT[3]+aCmpAntSFT[4],cChaveEnt)

		If aCmpAntSFT[20]$"DB"
			If SA2->(MsSeek(xFilial("SA2")+cChaveCol)) .AND. !Empty((cAliasCDF)->(CDF_COLETA))
				If Len (AllTrim(SA2->A2_CGC))>=14
					cCnpjCol	:=	SA2->A2_CGC
				Else
					cCpfCol		:=	SA2->A2_CGC
				EndIf
				cIeCol			:=	SPEDConType(SPEDVldIE(SA2->A2_INSCR))
				cMunCol			:=	Iif(Upper(SA2->A2_EST)=="EX","9999999",IIF(Len(SA2->A2_COD_MUN)<=5,UfCodIBGE(SA2->A2_EST),"")+SA2->A2_COD_MUN)
			EndIf

			If SA2->(MsSeek(xFilial("SA2")+cChaveEnt))
				If Len (AllTrim (SA2->A2_CGC))>=14
					cCnpjEnt	:=	SA2->A2_CGC
				Else
					cCpfEnt		:=	SA2->A2_CGC
				EndIf
				cIeEnt			:=	SPEDConType(SPEDVldIE(SA2->A2_INSCR))
				cMunEnt			:=	Iif(Upper(SA2->A2_EST) == "EX","9999999",IIF(Len(SA2->A2_COD_MUN)<=5,UfCodIBGE(SA2->A2_EST),"")+SA2->A2_COD_MUN)
			EndIf

		Else
			If SA1->(MsSeek(xFilial("SA1")+cChaveCol)) .AND. !Empty((cAliasCDF)->(CDF_COLETA))
				If Len (AllTrim (SA1->A1_CGC))>=14
					cCnpjCol	:=	SA1->A1_CGC
				Else
					cCpfCol		:=	SA1->A1_CGC
				EndIf
				cIeCol			:=	SPEDConType(SPEDVldIE(SA1->A1_INSCR))
				cMunCol			:=	Iif(Upper(SA1->A1_EST)=="EX","9999999",IIF(Len(SA1->A1_COD_MUN)<=5,UfCodIBGE(SA1->A1_EST),"")+SA1->A1_COD_MUN)
			EndIf
			//
			If SA1->(MsSeek(xFilial("SA1")+cChaveEnt))
				If Len (AllTrim (SA1->A1_CGC))>=14
					cCnpjEnt	:=	SA1->A1_CGC
				Else
					cCpfEnt		:=	SA1->A1_CGC
				EndIf
				cIeEnt			:=	SPEDConType(SPEDVldIE(SA1->A1_INSCR))
				cMunEnt			:=	Iif(Upper(SA1->A1_EST) == "EX","9999999",IIF(Len(SA1->A1_COD_MUN)<=5,UfCodIBGE(SA1->A1_EST),"")+SA1->A1_COD_MUN)
			EndIf
		EndIf
		//³Tratamento para evitar duplicidade no registro C110³
		If (nPosC110 := aScan(aRegC110,{|aX|aX[2]==(cAliasCDF)->CDF_IFCOMP}))==0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³DBF/ADS nao tem JOIN, preciso fazer o SEEK, e a funcao Reg0450³
			//|faz automaticamente quando a descricao estah com NIL          |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aInfCompl	:=	{(cAliasCDF)->CDF_IFCOMP,}
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³REGISTRO C110 - INFORMACAO COMPLEMENTAR DA NOTA FISCAL (CODIGO 01, 04 E 55)             ³
			//|                                                                                        |
			//|Funca que gera a estrutura dos registros acima e os grava no final do processamento do  |
			//|  documento fiscal                                                                      |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RegC110(@aInfCompl,@aRegC110,@nPosC110,,,,,aCmpAntSFT)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³REGISTRO 0450 - TABELA DE INFORMACAO COMPLEMENTAR/OBSERVACAO                            ³
			//|                                                                                        |
			//|Atribui os valores do array aReg0450 para efetuar a gravacao no final do processamento  |
			//| da rotina.                                                                             |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Reg0450(aInfCompl,@aReg0450)
		EndIf	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Nao preciso verificar a existencia antes de incluir, pois a chave unica da tabela ³
		//³  jah nao permite repetir o cadastro                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd(aRegC115, {})
		nPos	:=	Len (aRegC115)
		aAdd (aRegC115[nPos], nPosC110)			            	//Relacionamento com o registro pai
		aAdd (aRegC115[nPos], "C115")	 	   					//01 - REG
		aAdd (aRegC115[nPos], (cAliasCDF)->CDF_TPTRAN)			//02 - IND_CARGA
		aAdd (aRegC115[nPos], cCnpjCol)		   					//03 - CNPJ_COL
		aAdd (aRegC115[nPos], cIeCol)			 				//04 - IE_COL
		aAdd (aRegC115[nPos], cCpfCol)							//05 - CPF_COL
		aAdd (aRegC115[nPos], cMunCol)			 				//06 - COD_MUN_COL
		aAdd (aRegC115[nPos], cCnpjEnt)	 			   			//07 - CNPJ_ENTG
		aAdd (aRegC115[nPos], cIeEnt)			 				//08 - IE_ENTG
		aAdd (aRegC115[nPos], cCpfEnt)	 						//09 - CPF_ENTG
		aAdd (aRegC115[nPos], cMunEnt)	 						//10 - COD_MUN_ENTG
    EndIf           
    
    (cAliasCDF)->(dbSkip())
End

RestArea(aAreaSA1)
RestArea(aAreaSA2)
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC116   ³ Autor ³Gustavo G. Rueda       ³ Data ³14.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³      CUPOM FISCAL ELETRÔNICO REFERENCIADO                  ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro 0450, C110 e C116          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoes de todos os docu-   ³±±
±±³          ³ mentos fiscais processados.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³4(1:N) Para cada Registro C110                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAliasCDE-> Alias da tabela CDE filtrada (query ou indregua)³±±
±±³          ³aRegC110 -> Array com a estrutura do C110 gerado ateh o     ³±±
±±³          ³            momento.                                        ³±±
±±³          ³aReg0450 -> Array com a estrutura do 0450 gerado ateh o     ³±±
±±³          ³            momento.                                        ³±±
±±³          ³aCmpAntSFT-> Campos da tabela SFT com informacoes do        ³±±
±±³          ³             documento em processamento                     ³±±
±±³          ³aRegC114 -> Array com a estrutura do registro a ser gravado ³±±
±±³          ³lSemCDE  -> Quando nao tiver CDE (.T.), deve processar uma  ³±±
±±³          ³            unica vez e fazer o mesmo fluxo como se tivesse,³±± 
±±³          ³            pois eh um tratamento para quando houver        ³±±
±±³          ³            integracao com o SIGALOJA, com isso nao exigimos³±± 
±±³          ³            uma amarracao via complemento, uso a integracao ³±±
±±³          ³            direto                                          ³±±
±±³          ³cNFCupom -> Conteudo do campo F2_NFCUPOM                    ³±±
±±³          ³lTop     -> Flag de indicacao de ambiente TOP ou DBF        ³±±  
±±³          ³cEntSai -> Flag de indicacao do documento fiscal, 1=Entrada/³±±
±±³          ³2=Saida.  												  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegC116(cAliasCDE,aRegC110,aReg0450,aCmpAntSFT,aRegC116,cCodCompl,cNFCupom,lTop,cEntSai)
Local	lRet   		:=	.T.
Local	nPos		:=	0
Local	aAreaSF2	:=	SF2->(GetArea())
Local	cSerCp		:=	""
Local	cCupom		:=	""
Local	cEspecCp	:=	""
Local	dDtCupom	:=	""
Local   cECFFAB     := 	""
Local   cECFCX		:= 	""
Local   cCPREF		:= 	""
Local   cPdv        := 	""
Local	lProcUma	:=	Iif(cCodCompl==Nil,.F.,Iif(Empty(cCodCompl),.F.,.T.))	//Irah processar quando houver CDE ou quando houver pelo menos 1 codigo (cCodCompl<>"")
Local	nPosC110	:=	1
Local	aInfCompl	:=	{}
Local	cDescCompl	:=	Nil     
Local 	cCDEChv		:= (cAliasCDE)->(CDE_FILIAL+CDE_TPMOV+CDE_DOC+CDE_SERIE+CDE_CLIFOR+CDE_LOJA)

Default	cCodCompl	:=	""
Default	cNFCupom	:=	""

cSerCp		:=	Padr(SubStr(cNFCupom,1,TamSx3("F2_SERIE")[1]),TamSx3("F2_SERIE")[1])
cCupom		:=	Padr(SubStr(cNFCupom,TamSx3("F2_SERIE")[1]+1,TamSx3("F2_DOC")[1]+TamSx3("F2_SERIE")[1]),TamSx3("F2_DOC")[1])
While ( !(cAliasCDE)->(Eof()) .AND. ((cAliasCDE)->(CDE_FILIAL+CDE_TPMOV+CDE_DOC+CDE_SERIE+CDE_CLIFOR+CDE_LOJA)==cCDEChv)   ) .Or. lProcUma
	cCodCompl	:=	Iif(!lProcUma,(cAliasCDE)->CDE_IFCOMP,cCodCompl)    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processo o mesmo codigo de OBS da CDT e da CDG³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cCodCompl)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona no cupom de origem³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cEntSai == "1" .And. aCmpAntSFT[20]$"DB"
			cCupom	:=	aCmpAntSFT[38]
			cSerCp	:=	aCmpAntSFT[39]        
    	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para quando nao tiver SIGALOJA, ae o complemento eh ³
		//³   feito manualemten no documento.                             ³
		//³                                                               ³
		//³Se tiver SIGALOJA, o campo NFCUPOM vai estar preenchido        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        ElseIf Empty(cNFCupom)
			cCupom	:=	(cAliasCDE)->CDE_CPREF
			cSerCp	:=	(cAliasCDE)->CDE_SERREF
        EndIF
		cCPREF		:= cCupom
		If !SF2->(MsSeek(xFilial("SF2")+cCupom+cSerCp))
			lRet 		:= 	.F.
		Else
		    //FT_PDV somente estarah alimentado quando se referir a nota fiscais de saida geradas pelo SIGALOJA.
           If !Empty(SF2->F2_PDV) .AND. AllTrim(SF2->F2_ESPECIE)$"SATCE"
              cEspecCp	:=	"59"
           Else          
              cEspecCp 	:= 	aModNot(SF2->F2_ESPECIE)
           Endif
              dDtCupom 	:= 	SF2->F2_EMISSAO
              cPdv 		:= 	SF2->F2_PDV
		Endif
        If lRet .And. cEspecCp == "59"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se tiver PDV relacionado ao documento fiscal e o mesmo existir na tabela SFI,³
			//³ utilizo os dados da mesma, caso contrario, utilizo os dados do complemento  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    If !Empty(cPdv) .And. SFI->(MsSeek(xFilial("SFI")+Iif(SFI->(IndexOrd())==1,Dtos(dDtCupom)+cPdv,cPdv+Dtos(dDtCupom))))
		    	cECFFAB     := SFI->FI_SERPDV
				cECFCX		:= SFI->FI_PDV
			Else 
				cECFFAB     := (cAliasCDE)->CDE_ECFFAB
				cECFCX		:= (cAliasCDE)->CDE_ECFCX
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tratamento para evitar duplicidade no registro C110³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (nPosC110 := aScan(aRegC110,{|aX|aX[2]==cCodCompl}))==0
				aInfCompl	:=	{cCodCompl,cDescCompl}
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³REGISTRO C110 - INFORMACAO COMPLEMENTAR DA NOTA FISCAL (CODIGO 01, 04 E 55)             ³
				//|Funca que gera a estrutura dos registros acima e os grava no final do processamento do  |
				//|  documento fiscal                                                                      |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RegC110(@aInfCompl,@aRegC110,@nPosC110,,,,,aCmpAntSFT)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³REGISTRO 0450 - TABELA DE INFORMACAO COMPLEMENTAR/OBSERVACAO                            ³
				//|Atribui os valores do array aReg0450 para efetuar a gravacao no final do processamento  |
				//| da rotina.                                                                             |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Reg0450(aInfCompl,@aReg0450)
			EndIf	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³verifica se jah nao foi adicionado antes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPos := Ascan(aRegC116, {|x| x[4]==SF2->F2_SERSAT .And. x[6]==(cAliasCDE)->CDE_CPREF .And. x[7]==SF2->F2_EMISSAO})
			If nPos == 0
				aAdd(aRegC116, {})
				nPos	:=	Len(aRegC116)
				aAdd (aRegC116[nPos], nPosC110)					//Relacionamento com o registro pai
				aAdd (aRegC116[nPos], "C116")	 	   			//01 - REG
				aAdd (aRegC116[nPos], "59")						//02 - COD_MOD
				aAdd (aRegC116[nPos], SF2->F2_SERSAT)			//03 - NR_SAT
				aAdd (aRegC116[nPos], SF2->F2_CHVNFE)			//04 - CHV_CFE
				aAdd (aRegC116[nPos], (cAliasCDE)->CDE_CPREF)	//05 - NUM_CFE
				aAdd (aRegC116[nPos], SF2->F2_EMISSAO)			//06 - DT_DOC 
			EndIf
		EndIf
    EndIf
    If lProcUma
    	Exit
    EndIf
    (cAliasCDE)->(dbSkip())
End
RestArea(aAreaSF2)
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC120   ³ Autor ³Gustavo G. Rueda       ³ Data ³15.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³  DECLARACAO/BASE DE CALCULO DE IMPORTACAO (MODELO 01 e 04) ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro C120                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoes de D.I. dos documen-³±±
±±³          ³ tos fiscais processados.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3(1:1) Para cada Registro C100                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias    -> Alias do TRB que recebera as informacoes       ³±±
±±³          ³nRelac    -> Flag de relacionamento com os sub-registros    ³±±
±±³          ³cAliasCD5 -> Alias jah filtrado da tabela CD5, Indregua ou  ³±±
±±³          ³             query                                          ³±±
±±³          ³lSigaEIC  -> Flag de tratamento via SIGAEIC                 ³±±
±±³          ³aAvImport -> Informacoes de importacao vindas do SIGAEIC    ³±±
±±³          ³             para o documento fiscal em processamento       ³±±
±±³          ³lAchouCD5 -> Flag de seek da tabela CD5                     ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegC120(cAlias,nRelac,cAliasCD5,lSigaEIC,aAvImport,lAchouCD5, aWizard)
	Local	aRegC120	:=	{}
	Local	nPos		:=	0
	Local	cAcDraw		:=	""
	Local	cDocImp		:=	""     
	Local 	cCD5Chv		:=  ""
	Default	aWizard		:= {}
	//³Tratamento para quando houver integracao com o SIGAEIC³
	If lSigaEIC .And. Len(aAvImport)>0	//Se houver elementos, sempre serah nestas dimensoes
		aAdd(aRegC120, {})
   		nPos	:=	Len (aRegC120)
		aAdd (aRegC120[nPos], "C120")	 						//01 - REG	
		aAdd (aRegC120[nPos], aAvImport[1,2,1,2,1])			//02 - COD_DOC_IMP    
		aAdd (aRegC120[nPos], aAvImport[1,2,2,2,1])			//03 - NUM_DOC_IMP
		aAdd (aRegC120[nPos], Iif("1"$aWizard[1][15],aAvImport[1,2,3,2,1],""))			//04 - PIS_IMP
		aAdd (aRegC120[nPos], Iif("1"$aWizard[1][15],aAvImport[1,2,4,2,1],""))			//05 - COF_IMP
		aAdd (aRegC120[nPos], "")								//06 - NUM_ACDRAW - LAYOUT 2010
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se NAO houver integracao com o SIGAEIC, a tabela CD5 jah estah posicionada, ³
	//³  senao NAO entraria na funcao                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf lAchouCD5
		cCD5Chv := (cAliasCD5)->(CD5_FILIAL+CD5_DOC+CD5_SERIE+CD5_FORNEC+CD5_LOJA)
		While !(cAliasCD5)->(Eof()) .AND. ( (cAliasCD5)->(CD5_FILIAL+CD5_DOC+CD5_SERIE+CD5_FORNEC+CD5_LOJA)==cCD5Chv)	
			
			cAcDraw	:=	(cAliasCD5)->CD5_ACDRAW
			cDocImp	:=	(cAliasCD5)->CD5_DOCIMP
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Nao podem ser informados para um mesmo documento fiscal, dois ou mais registros  ³
			//³ com o mesmo conteudo no campo NUM_DOC_IMP e NUM_ACDRAW                			³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (nPos := aScan(aRegC120, {|aZ| aZ[6] == cAcDraw .And. aZ[3] == cDocImp})) == 0
				aAdd(aRegC120, {})
				nPos	:=	Len (aRegC120)
				aAdd (aRegC120[nPos], "C120")	 						//01 - REG	
				aAdd (aRegC120[nPos], (cAliasCD5)->CD5_TPIMP)			//02 - COD_DOC_IMP
				aAdd (aRegC120[nPos], (cAliasCD5)->CD5_DOCIMP)		//03 - NUM_DOC_IMP
				aAdd (aRegC120[nPos], Iif((cAliasCD5)->CD5_VLPIS>0,(cAliasCD5)->CD5_VLPIS,0))			//04 - PIS_IMP
				aAdd (aRegC120[nPos], Iif((cAliasCD5)->CD5_VLCOF>0,(cAliasCD5)->CD5_VLCOF,0))			//05 - COF_IMP
				If cVersao >= "003"
					aAdd (aRegC120[nPos], (cAliasCD5)->CD5_ACDRAW)	//06 - NUM_ACDRAW - LAYOUT 2010
				EndIf
			Else
				aRegC120[nPos][4]	+=	(cAliasCD5)->CD5_VLPIS			//04 - PIS_IMP
				aRegC120[nPos][5]	+=	(cAliasCD5)->CD5_VLCOF			//05 - COF_IMP	
			Endif

			(cAliasCD5)->(DbSkip())
		End
		If (aRegC120[nPos][4] <= 0)
			aRegC120[nPos][4] := ""									//04 - PIS_IMP
		EndIf
		If (aRegC120[nPos][5] <= 0)
			aRegC120[nPos][5] := ""									//05 - COF_IMP
		EndIf
	EndIf
	GrvRegTrS(cAlias,nRelac,aRegC120)
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC130   ³ Autor ³Gustavo G. Rueda       ³ Data ³04.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³                  ISS - IR - INSS (MODELO 01 E 04)          ³±±
±±³          ³- Geracao e gravacao do Registro C130                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoes de ISS/IRRF/PREV dos³±±
±±³          ³ documentos fiscais processados.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3(1:1) Para cada Registro C100                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAliasSFT-> Alias da tabela SFT posicionada                 ³±±
±±³          ³aRegC130 -> Informacoes sobre ISS/IRRF/PREV para o documento³±±
±±³          ³ fiscal processado no while da funcao principal.            ³±±
±±³          ³lIss     -> Identifica se o item em processamento eh servico³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegC130(cAliasSFT,aRegC130,lIss)

If lIss
	aRegC130[2]	+=	(cAliasSFT)->FT_VALCONT			  			//02 - VL_SERV_NT
	aRegC130[3]	+=	(cAliasSFT)->FT_BASEICM						//03 - VL_BC_ISS
	aRegC130[4]	+=	(cAliasSFT)->FT_VALICM			 			//04 - VL_ISS
EndIf
aRegC130[5]	+=	(cAliasSFT)->FT_BASEIRR			  				//05 - VL_BC_IRRF
aRegC130[6]	+=	(cAliasSFT)->FT_VALIRR		   					//06 - VL_IRRF
aRegC130[7]	+=	(cAliasSFT)->FT_BASEINS		   					//07 - VL_BC_PREV
aRegC130[8]	+=	(cAliasSFT)->FT_VALINS		  					//08 - VL_PREV
		
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³C140C141  ³ Autor ³Gustavo G. Rueda       ³ Data ³15.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³             C140 - FATURA (MODELO 01 e 04)                 ³±±
±±³          ³         C141 - VENCIMENTO FATURA (MODELO 01 e 04)          ³±±
±±³          ³- Geracao e gravacao do Registro C140 e C141                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoes dos titulos e seus  ³±±
±±³          ³ vencimentos para cada documento fiscal processado.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³C140 - 3(1:N) Para cada Registro C100                       ³±±
±±³          ³C141 - 4(1:N) Para cada Registro C140                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          ³nRelac -> Flag de relacionamento com os sub-registros       ³±±
±±³          ³aRegC100 -> Array contendo o cabecalho da nota fiscal modelo³±±
±±³          ³ 01 e 04.                                                   ³±±
±±³          ³aParcTit -> Array contendo as parcelas financeiras do       ³±±
±±³          ³ documento fiscal                                           ³±±
±±³          ³cEntSai -> Identifica ENTRADA=1/SAIDA=2                     ³±±
±±³          ³aCmpAntSFT -> Campos da tabela SFT por documento fiscal     ³±±     
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C140C141(cAlias,nRelac,aRegC100,aParcTit,cEntSai,aCmpAntSFT)
Local	aReg		:=	{}
Local	aReg2		:=	{}
Local	nVlTit		:=	0
Local	nX			:=	0
Local	nPos		:=	0
Local	nPosC141	:=	0
//Local	nItem		:=	1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento de verificacao da condicao de pagamento.³
//³Para pagamento a vista nao pode haver fatura       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aRegC100[1][13]!="0"

	If aExistBloc[19]
		aParcTit := ExecBlock("SPDFIS09", .F., .F.,{cEntSai,{aCmpAntSFT[1],aCmpAntSFT[2],aCmpAntSFT[3],aCmpAntSFT[4],aCmpAntSFT[27]}}) 	
	EndIF

	aParcTit	:=	aSort (aParcTit,,,{|x, y| x[4]<y[4]})

	//³Obtendo o valor total dos titulos lancados para o documento, todas as parcelas³
	aEval (aParcTit, {|x| nVlTit += x[6]})

	For nX := 1 To Len (aParcTit)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REGISTRO C140 - COMPLEMENTO DO DOCUMENTO - FATURA             ³
		//|Somente a primeira vez para utilizar as informacoes do titulo.|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nX==1
			aReg	:=	{}
			aAdd(aReg, {})
			nPos	:=	Len (aReg)
			aAdd (aReg[nPos], "C140")						  		//01 - REG
			aAdd (aReg[nPos], aRegC100[1][3])						//02 - IND_EMIT

			If (AllTrim (aParcTit[nX][1])$"BOL#DP#NF")				//03 - IND_TIT
				aAdd (aReg[nPos], "00")

			ElseIf (AllTrim (aParcTit[nX][1])$"CH")  				//03 - IND_TIT
				aAdd (aReg[nPos], "01")

			ElseIf (AllTrim (aParcTit[nX][1])$"NP")  				//03 - IND_TIT
				aAdd (aReg[nPos], "02")                	

			ElseIf (AllTrim (aParcTit[nX][1])$"RC")  				//03 - IND_TIT
				aAdd (aReg[nPos], "03")

			Else
				aAdd (aReg[nPos], "99")								//03 - IND_TIT
			EndIf

			If "99"$aReg[nPos,3]
				If Empty( aParcTit[nX][2] )
					aAdd (aReg[nPos], "Titulo de Nota Fiscal")		//04 - DESC_TIT
				Else                                            	
					aAdd (aReg[nPos], aParcTit[nX][2])				//04 - DESC_TIT
				EndIf
			Else
				aAdd (aReg[nPos], "")								//04 - DESC_TIT
			EndIf

			aAdd (aReg[nPos], aParcTit[nX][3])						//05 - NUM_TIT
			aAdd (aReg[nPos], Alltrim(STR(Len (aParcTit))))		//06 - QTD_PARC
			aAdd (aReg[nPos], nVlTit)		   						//07 - VL_TIT
		EndIf
		//³REGISTRO C141 - VENCIMENTO DA FATURA³
		aAdd(aReg2, {})
		nPosC141	:=	Len (aReg2)
		aAdd (aReg2[nPosC141], nPos)				  				//00 - Relacionamento
		aAdd (aReg2[nPosC141], "C141")				  				//01 - REG
		aAdd (aReg2[nPosC141], Alltrim(STR(nX)) )					//02 - NUM_PARC
		aAdd (aReg2[nPosC141], aParcTit[nX][5])					//03 - DT_VECTO
		aAdd (aReg2[nPosC141], aParcTit[nX][6])					//04 - VL_PARC
	Next nX
	
	GrRegDep(cAlias,aReg,aReg2,,,,nRelac,.F.)
	
EndIf
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC160   ³ Autor ³Gustavo G. Rueda       ³ Data ³15.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³    REGISTRO C160 - VOLUMES TRANSPORTADOS (CODIGO 01 E 04)   ³±±
±±³          ³                  EXCETO COMBUSTIVEIS                       ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro C160                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoes dos volumes dos     ³±±
±±³          ³ documentos fiscais processados.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3(1:1) Para cada Registro C100                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          ³nRelac -> Flag de relacionamento com os sub-registros       ³±±
±±³          ³aReg0150 -> Array com a estrutura do registro 0150          ³±±
±±³          ³aWizard  -> Array com as informacoes do wizard da rotina    ³±±
±±³          ³aCmpAntSFT-> Campos do documento em processamento           ³±±
±±³          ³lCadParti-> Flag que identifica a existencia do PE SPDFIS06 ³±±
±±³          |aHistSA4 -> Array com os historicos de alteracoes do SA4    ³±±
±±³          |lAchouDA3-> Flag de posicionamento da tabela DA3            ³±±
±±³          |cAliasSA4-> Alias da tabela SA4                             ³±±
±±³          |aF2EspVol-> Campos de Especie/Volume para gerar o registro  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegC160(cAlias,nRelac,aReg0150,aWizard,aCmpAntSFT,lCadParti,aHistSA4,lAchouDA3,cAliasSA4,aF2EspVol)
Local	aReg   		:=	{}
Local	cCodPart	:=	""
Local	cUfId		:=	""
Local	cVeicId		:=	""
Local	aPartDoc	:=	{}
Local   nVolume     := 	0  
Local	nX			:=	0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Acumulo a quantidade de volumes do documento fiscal ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aF2EspVol)
	If ValType(aF2EspVol[nX,4])<>'U'
		nVolume	+=	aF2EspVol[nX,4]
	EndIf	
Next nX

If !Empty(aCmpAntSFT[30])	//Conteudo do campos F2_TRANSP
	aPartDoc	:=	InfPartDoc("SA4",SToD(aWizard[1][1]),SToD(aWizard[1][2]),cAliasSA4,lCadParti,aHistSA4)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GRAVACAO REGISTRO 0150 - TABELA DE CADASTRO DE PARTICIPANTES            ³
	//³GRAVACAO REGISTRO 0175 - ALTERACAO DA TABELA DE CADASTRO DE PARTICIPANTE³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SDPF150175(@aReg0150,aPartDoc,cAlias,aWizard,aExistBloc)

	cCodPart	:=	aPartDoc[1]
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Para veiculos do exterior, a placa e a UF nao devem ser informadas  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAchouDA3 .And. DA3->DA3_ESTPLA<>"EX"  
	cUfId	:= Alltrim(DA3->DA3_ESTPLA)
	cVeicId := SubStr(StrTran(DA3->DA3_PLACA,"-",""),1,7)
	
ElseIf !lAchouDA3
	If !Empty(aCmpAntSFT[33]) .And. DA3->(MsSeek(xFilial("DA3")+aCmpAntSFT[33])) .And.  DA3->DA3_ESTPLA<>"EX"  
		cUfId	:= Alltrim(DA3->DA3_ESTPLA)
		cVeicId := SubStr(StrTran(DA3->DA3_PLACA,"-",""),1,7)
	
	ElseIf !Empty(aCmpAntSFT[34]) .And. DA3->(MsSeek(xFilial("DA3")+aCmpAntSFT[34])) .And. DA3->DA3_ESTPLA<>"EX"  
		cUfId	:= Alltrim(DA3->DA3_ESTPLA)
		cVeicId := SubStr(StrTran(DA3->DA3_PLACA,"-",""),1,7)
			
	ElseIf !Empty(aCmpAntSFT[35]) .And. DA3->(MsSeek(xFilial("DA3")+aCmpAntSFT[35])) .And. DA3->DA3_ESTPLA<>"EX"
		cUfId	:= Alltrim(DA3->DA3_ESTPLA)
		cVeicId := SubStr(StrTran(DA3->DA3_PLACA,"-",""),1,7)

	Else  
		cUfId	:= ""  
		cVeicId := ""  
	Endif
EndIf
    
//³Montagem e gravacao do registro³
aAdd (aReg, {})
nPos	:=	Len (aReg)
aAdd (aReg[nPos], "C160")	 							//01 - REG
aAdd (aReg[nPos], cCodPart)								//02 - COD_PART
aAdd (aReg[nPos], cUfId + cVeicId)						//03 - VEIC_ID
aAdd (aReg[nPos], {nVolume,0}) 	                    //04 - QTD_VOL
aAdd (aReg[nPos], aCmpAntSFT[31])						//05 - PESO_BRT
aAdd (aReg[nPos], aCmpAntSFT[32])						//06 - PESO_LIQ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Para declaracoes superiores a 2008, deve-se informar um campo a mais conforme layout³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Year(SToD(aWizard[1][1]))>=2009
	aReg[nPos][03] := cVeicId							//03 - VEIC_ID
	aAdd (aReg[nPos], cUfId)							//07 - UF_ID
EndIf

GrvRegTrS(cAlias,nRelac,aReg)

Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC165   ³ Autor ³Gustavo G. Rueda       ³ Data ³15.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³           DOCUMENTO DE ARRECADACAO REFERENCIADO            ³±±
±±³          ³                                                            ³±±
±±³Descri‡…o ³Geracao da estrutura do Registro C165                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com todas as guias de recolhimento com ³±±
±±³          ³ a data de referencia no periodo apurado.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3(1:N) para cada Registro C100                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aRegC165-> Array com a estrutura do registro C165           ³±±
±±³          ³aPTransp-> Informacoes da transportadora do documento fiscal³±±
±±³          ³cAliasSFT-> Alias da tabela SFT em processamento            ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegC165(aRegC165,aPTransp,cAliasSFT)
Local	nPos		:=	0 

While !CD6->(Eof()) .And.;
	xFilial("CD6")+(cAliasSFT)->(FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO)==;
	CD6->(CD6_FILIAL+CD6_TPMOV+CD6_SERIE+CD6_DOC+CD6_CLIFOR+CD6_LOJA+CD6_ITEM+CD6_COD)
    
	//³Tratamento para evitar duplicidade no registro³
	If aScan(aRegC165,{|aX|aX[2]==aPTransp[1] .And. aX[3]==CD6->CD6_PLACA})==0
		aAdd(aRegC165, {})
		nPos	:=	Len (aRegC165)
		aAdd (aRegC165[nPos], "C165")						//01 - REG
		aAdd (aRegC165[nPos], aPTransp[1])					//02 - COD_PART
		aAdd (aRegC165[nPos], CD6->CD6_PLACA)				//03 - VEIC_ID
		aAdd (aRegC165[nPos], CD6->CD6_SEFAZ)				//04 - COD_AUT
		aAdd (aRegC165[nPos], CD6->CD6_PASSE)				//05 - NR_PASSE
		aAdd (aRegC165[nPos], Alltrim(CD6->CD6_HORA)+"00")	//06 - HORA
		aAdd (aRegC165[nPos], {CD6->CD6_TEMP,1})			//07 - TEMPER
		aAdd (aRegC165[nPos], STR(CD6->CD6_VOLUME))		//08 - QTD_VOL
		aAdd (aRegC165[nPos], CD6->CD6_PBRUTO)				//09 - PESO_BRT
		aAdd (aRegC165[nPos], CD6->CD6_PLIQUI)				//10 - PESO_LIQ
		aAdd (aRegC165[nPos], CD6->CD6_MOTOR)				//11 - NOM_MOT
		aAdd (aRegC165[nPos], CD6->CD6_CPFMOT)				//12 - CPF
		aAdd (aRegC165[nPos], CD6->CD6_UFPLAC)				//13 - UF_ID
	EndIf
		
	CD6->(dbSkip())
End

Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC170   ³ Autor ³Gustavo G. Rueda       ³ Data ³04.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³         ITENS DO DOCUMENTO (MODELO 01 E 04)                ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro C170                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com a informacao de cada item do docu- ³±±
±±³          ³ mento fiscal processado no while da funcao principal.      ³±±
±±³          ³Somente sera gravado os documentos fiscais modelo 01 e 04   ³±±
±±³          ³ nos outros casos, sera utilizdo para gerar outros registros³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3(1:N) Para cada Registro C100                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias    -> Alias do TRB que recebera as informacoes       ³±±
±±³          ³nRelac    -> Flag de relacionamento com os sub-registros    ³±±
±±³          ³nItem     -> Contador do item para cada documento fiscal.   ³±±
±±³          ³aRegC170  -> Informacoes sobre os itens do documento fiscal ³±±
±±³          ³ processado no while da funcao principal.                   ³±±
±±³          ³cEspecie  -> Modelo do documento fiscal                     ³±±
±±³          ³cAliasSFT -> Alias da tabela SFT posicionada                ³±±
±±³          ³cAlsSD    -> Alias da tabela SD? posicionada                |±±
±±³          |lIss      -> Indica se o documento incide ISS.              ³±±
±±³          |aClasFis  -> Classificacao fiscal do ICMS.                  ³±±
±±³          |lAchouSF4 -> Indicador do SEEK na tabela SF4.               ³±±
±±³          |nApurIPI  -> Identificador de Apuracao de IPI no periodo    ³±±
±±³          |cSituaDoc -> Situacao do documento fiscal                   ³±±
±±³          |cUnid     -> Unidade de medida do item em processamento     ³±±
±±³          |cProd     -> Codigo de produto do item emm processamento    ³±±
±±³          |aCmpAntSFT-> Campos da tabela SFT a serem utilizados        ³±±
±±³          |nValST    -> Valor da substituicao tributaria conforme calcu³±±
±±³          |             lado na apuracao de icms/st, jah considerando o³±±
±±³          |             CREDST.                                        ³±±
±±³          |dDataAte  -> Data final de processamento do periodo         ³±±
±±³          |aWizard   -> Array com as informacoes do wizard             ³±±
±±³          |cAliasSF4 -> Alias da tabela SF4, pode ser alias de query   ³±±
±±³          |cAliasSB1 -> Alias da tabela Sb1, pode ser alias de query   ³±±
±±³          |AHistSB1  -> Array com o historico de alteracoes do produto,³±±
±±³          |             caso esteja habilitado                         ³±±
±±³          |nQtde     -> Quantidade do item. Esta quantidade pode ser o ³±±
±±³          |             proprio FT_QUANT ou o retorno do PE SPDFIS0,   ³±±
±±³          |             onde pode ser atribuido a quantidade na segunda³±±
±±³          |             UM.                                            ³±±
±±³          ³lPisZero  -> Indica se zera o valor do Pis                  ³±±
±±³          ³lCofZero  -> Indica se zera o valor do Cofins               ³±±
±±³          ³lAchouCD0  -> Indica que existe registro de Ressarcimento   ³±±
±±³          ³cMvEstado  -> Conteudo do parametro MV_ESTADO               ³±±
±±³          ³lAchouCD1  -> Indica que existe registro de Natureza da Oper³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegC170(cAlias,nRelac,nItem,aRegC170,cEspecie,cAliasSFT,lIss,aClasFis,lAchouSF4,nApurIPI,cSituaDoc,cUnid,;
						cProd,aCmpAntSFT,nValST,dDataAte,aWizard,cAliasSF4,cAliasSB1,AHistSB1,nQtde,lPisZero,lCofZero,lAchouCD0,;
						cMvEstado,cCodNat,cPerfil,lOperGar,lResF3FT,cAliasSD1)
Local	lRet		:=	.F.
Local	nPos		:=	0
Local	nQuant 		:=	0
Local	nPisPauta 	:= 	0
Local	nQtdBPis  	:= 	0
Local	nBasePis 	:= 	0
Local	nAliqPis  	:= 	0
Local	nCofPauta 	:= 	0
Local	nQtdBCof  	:= 	0
Local	nBaseCof  	:= 	0
Local	nAliqCof  	:= 	0
Local	nMV_SPEDQTD	:=	aSPDSX6[MV_SPEDQTD]	//Parametro utilizado para definir o tratamento da quantidade quando a mesma for ZERO
Local	cChvSeek	:=	""
Local	cContCtb	:= RetCOD_CTA(cAliasSFT, "C170")

Default	dDataAte	:=	CToD ("//")
Default	cAliasSF4	:=	"SF4"
Default	cAliasSB1	:=	"SB1"
Default	lResF3FT	:= .F.

//³A quantidade do item nao pode ser ZERO, o validador acusa erro³
nQuant := Iif(nQtde==0,nMV_SPEDQTD,nQtde)

//³Montando array com a estrutura do registro C170³
aAdd(aRegC170, Array(37))
nPos	:=	Len (aRegC170)
aRegC170[nPos][1] := "C170"																//01 - REG
aRegC170[nPos][2] := AllTrim(Str(nItem))												//02 - NUM_ITEM
aRegC170[nPos][3] := cProd																//03 - COD_ITEM

If aExistBloc[01] 
	aRegC170[nPos][5] := Iif(nQuant==0, "", {nQuant,5})								//05 - QTD
	aRegC170[nPos][6] := cUnid															//06 - UNID
Else
	aRegC170[nPos][5] := Iif(nQuant==0, "", {Iif((cAliasSFT)->FT_QUANT == 0, nMV_SPEDQTD, (cAliasSFT)->FT_QUANT),5})//{nQuant,5})		//05 - QTD
	aRegC170[nPos][6] := (cAliasSB1)->B1_UM												//06 - UNID
EndIf	

aRegC170[nPos][7] := (cAliasSFT)->FT_TOTAL + (cAliasSFT)->FT_DESCZFR					//07 - VL_ITEM
If (cAliasSFT)->FT_TIPOMOV == "E" .And. (!(cAliasSF4)->F4_LFIPI$"T" .Or. (cAliasSFT)->FT_CREDST $ "3|4" ) .And. !(cAliasSFT)->FT_TIPO$"DB"
	If !(cAliasSF4)->F4_LFIPI$"T" 
		  aRegC170[nPos][7] +=	 (cAliasSD1)->D1_VALIPI       
	EndIf
	If (cAliasSFT)->FT_CREDST $ "3|4"
		aRegC170[nPos][7]	+= 	RetStSpd(lResF3FT, cAliasSFT )
	Endif
EndIf
//³Tratamento para as notas de complementos³
If ((cAliasSFT)->FT_TIPO$"IPC")
	//³Para Notas Fiscais de complemento de IPI/ICMS o campo referente³
	//³ao valor do item deve ser zero.                                ³
	If ((cAliasSFT)->FT_TIPO$"IP")
		aRegC170[nPos][7] := 0							   				 						//07 - VL_ITEM
	EndIf
	aRegC170[nPos][9] := "1"
Else
	//³Tratamento movimentacao fisica sem movimentacao de estoque³
	If lAchouSF4 .AND.;
		((cAliasSF4)->F4_MOVFIS=="N" .Or. Empty((cAliasSF4)->F4_MOVFIS))
		aRegC170[nPos][9] := "1"															//09 - IND_MOV				
	Else
		aRegC170[nPos][9] := "0"													   		//09 - IND_MOV				
	EndIf
EndIf
//³Codigo de CST para SIMPLES NACIONAL³
aRegC170[nPos][10] := aClasFis[1]							   			  					//10 - CST
If aCmpAntSFT[36]$"1S"	//A2_SIMPNAC
	If aSPDSX3[FP_FT_CSOSN] .And. !Empty((cAliasSFT)->FT_CSOSN)
		aRegC170[nPos][10] := (cAliasSFT)->FT_CSOSN							   					//10 - CST	
	ElseIf !Empty((cAliasSF4)->F4_CSOSN)
		aRegC170[nPos][10] := (cAliasSF4)->F4_CSOSN							   					//10 - CST
	Endif		
EndIf
aRegC170[nPos][11] := (cAliasSFT)->FT_CFOP  			   				  						//11 - CFOP   
aRegC170[nPos][13] 	:= 0
aRegC170[nPos][15]	:= 0
If !(cSituaDoc$"02#04#05#03")  
	aRegC170[nPos][4]	:=	RetCmpHist(cAliasSB1+"->B1_DESC",AHistSB1,aCmpAntSFT[5])			//04 - DESCR_COMPL
	//³Ponto de Entrada para alterar a descrição do produto             ³  
	If aExistBloc[12]
		aRegC170[nPos][4] := ExecBlock("SPDFIS04", .F., .F., {(cAliasSFT)->FT_FILIAL,;
							(cAliasSFT)->FT_TIPOMOV,;
							(cAliasSFT)->FT_SERIE,;
							(cAliasSFT)->FT_NFISCAL,;
							(cAliasSFT)->FT_CLIEFOR,;
							(cAliasSFT)->FT_LOJA,;
							(cAliasSFT)->FT_ITEM,;
							(cAliasSFT)->FT_PRODUTO})
	EndIf
	
	aRegC170[nPos][8] 	:= 	(cAliasSFT)->FT_DESCONT		 										//08 - VL_DESC_I
	aRegC170[nPos][12] 	:= 	cCodNat																//12 - COD_NAT
	aRegC170[nPos][13] 	:= 	IIf(lIss,0,(cAliasSFT)->FT_BASEICM)								//13 - VL_BC_ICMS_I
	//³Quando o documento nao tiver aliquota e for algum documento complementar, devo utilizar a aliquota do original. ³
	//³Somente nas situacoes em que o CST seja 00,20,30 e 70 conforme manual                                           ³
	If (cAliasSFT)->(!lIss .And. FT_ALIQICM==0 .And. Substr(FT_CLASFIS,2,2)$"00#10#20#70" .And. !Empty(FT_NFORI+FT_SERORI))
		cChvSeek		:=	xFilial("SF3")+(cAliasSFT)->(FT_SERORI+FT_NFORI+FT_CLIEFOR+FT_LOJA)
		If SPEDSeek("SF3",5,cChvSeek)
	 		aRegC170[nPos][14] := IIf(lIss,0,SF3->F3_ALIQICM)									//14 - ALIQ_ICMS
      	EndIF
	Else
		aRegC170[nPos][14] := IIf(lIss,0,(cAliasSFT)->FT_ALIQICM)	  							//14 - ALIQ_ICMS
	EndIf	                                                                	
	aRegC170[nPos][15] := IIf(lIss,0,(cAliasSFT)->FT_VALICM)		  							//15 - VL_ICMS_I
   	aRegC170[nPos][16] := IIf(nValST==0,0,(cAliasSFT)->FT_BASERET)				   			//16 - VL_BC_ST_I
	aRegC170[nPos][17] := IIf(nValST==0,0,(cAliasSFT)->FT_ALIQSOL)							//17 - ALIQ_ST
	aRegC170[nPos][18] := nValST
		
	If (cAliasSFT)->FT_VALIPI>0
		aRegC170[nPos][19] := STR(nApurIPI,1)						 				  			//19 - IND_APUR
	Else
		aRegC170[nPos][19] := ""																//19 - IND_APUR
	EndIf
	
	aRegC170[nPos][20] := Iif("0"$aWizard[2][5],aClasFis[2],"")	 							//20 - CST_IPI
	aRegC170[nPos][21] := "" 																	//21 - COD_ENQ
	aRegC170[nPos][22] := (cAliasSFT)->FT_BASEIPI					 							//22 - VL_BC_IPI
	aRegC170[nPos][23] := (cAliasSFT)->FT_ALIQIPI												//23 - ALIQ_IPI
	If (cAliasSFT)->FT_TIPOMOV == "E" 
		If !(cAliasSFT)->FT_TIPO$"DB"
			aRegC170[nPos][24] := Iif((cAliasSF4)->F4_LFIPI$"T",(cAliasSD1)->D1_VALIPI,0)									//24 - VL_IPI
		Else
			aRegC170[nPos][24] := (cAliasSFT)->FT_VALIPI
		Endif
	ElseIf (cAliasSFT)->FT_TIPOMOV == "S"
	    aRegC170[nPos][24] := (cAliasSFT)->FT_VALIPI
	EndIf
	aRegC170[nPos][25] := Iif("1"$aWizard[1][15],aClasFis[3],"")	  							//25 - CST_PIS
	//³Tratamento para o PIS³
	If (cAliasSFT)->FT_VALPIS > 0
		//³Verifica se o valor de PIS é de PAUTA³
		If (cAliasSFT)->FT_PAUTPIS > 0
			nPisPauta := (cAliasSFT)->FT_PAUTPIS
			nQtdBPis  := nQtde

		ElseIf (cAliasSB1)->B1_VLR_PIS>0
			nPisPauta := (cAliasSB1)->B1_VLR_PIS
			nQtdBPis  := nQtde

		Else
			nBasePis  := (cAliasSFT)->FT_BASEPIS
			nAliqPis  := (cAliasSFT)->FT_ALIQPIS
		EndIf
	EndIf
	
	aRegC170[nPos][26] := Iif("1"$aWizard[1][15],Iif(lOperGar,0,nBasePis),"")				   						 					//26 - VL_BC_PIS
	aRegC170[nPos][27] := Iif("1"$aWizard[1][15],Iif(lPisZero .Or. lOperGar,0,nAliqPis),"")											//27 - ALIQ_PIS
	aRegC170[nPos][28] := Iif("1"$aWizard[1][15],IIf(lOperGar,0,nQtdBPis),"")					 										//28 - QUANT_BC_PIS
	aRegC170[nPos][29] := Iif("1"$aWizard[1][15],Iif(lPisZero .or. lOperGar,0,nPisPauta),"")										//29 - ALIQ_PIS - Reais
	aRegC170[nPos][30] := Iif("1"$aWizard[1][15],Iif(lPisZero .or. lOperGar,0,(cAliasSFT)->FT_VALPIS),"")							//30 - VL_PIS
	aRegC170[nPos][31] := Iif("1"$aWizard[1][15],aClasFis[4],"")			 						  					//31 - CST_COFINS
	//³Tratamento para COFINS ³
	If (cAliasSFT)->FT_VALCOF>0
		//³Verifica se o valor de COFINS é de PAUTA³
		If (cAliasSFT)->FT_PAUTCOF>0
			nCofPauta := (cAliasSFT)->FT_PAUTCOF
			nQtdBCof  := nQtde				
		ElseIf (cAliasSB1)->B1_VLR_COF>0
			nCofPauta := (cAliasSB1)->B1_VLR_COF
			nQtdBCof  := nQtde			
		Else
			nBaseCof  := (cAliasSFT)->FT_BASECOF
			nAliqCof  := (cAliasSFT)->FT_ALIQCOF - (cAliasSFT)->FT_MALQCOF
		EndIf
	EndIf	
	aRegC170[nPos][32] := Iif("1"$aWizard[1][15],IIf(lOperGar,0,nBaseCof),"")									 				//32 - VL_BC_COFINS
	aRegC170[nPos][33] := Iif("1"$aWizard[1][15],Iif(lCofZero .Or. lOperGar,0,nAliqCof),"")										//33 - ALIQ_COFINS
	aRegC170[nPos][34] := Iif("1"$aWizard[1][15],IIf(lOperGar,0,nQtdBCof),"")					 								//34 - QUANT_BC_COFINS
	aRegC170[nPos][35] := Iif("1"$aWizard[1][15],Iif(lCofZero .Or. lOperGar,0,nCofPauta),"")										//25 - ALIQ_COFINS - Reais
	aRegC170[nPos][36] := Iif("1"$aWizard[1][15],Iif(lCofZero .Or. lOperGar,0,(cAliasSFT)->FT_VALCOF-(cAliasSFT)->FT_MVALCOF),"")//36 - VL_COFINS
	aRegC170[nPos][37] := Iif(!Empty(cContCtb),cContCtb,(cAliasSFT)->FT_CONTA)												//37 - COD_CTA
EndIf
//³PARA NF-e de emissao propria nao deve gerar C170 (nesse caso o CHVNFE estara preenchido)³
If !cSituaDoc$"02#04#05#03" .And. (cEspecie$"01#1B#04" .Or. (cEspecie$"55" .And. (aCmpAntSFT[26]=="1" .Or. lAchouCD0 ))) .And. cPerfil <> "C"
	GrvRegTrS(cAlias,nRelac,aRegC170,nItem,,IIf(cVersao <= "003",.F.,.T.))
	lRet := .T.
EndIf

Return(lRet)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC171   ³ Autor ³Gustavo G. Rueda       ³ Data ³04.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³              ARMAZENAMENTO DE COMBUSTIVEIS                 ³±±
±±³          ³                                                            ³±±
±±³Descri‡…o ³Geracao e gravacao do Registro C171                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com todas as guias de recolhimento com ³±±
±±³          ³ a data de referencia no periodo apurado.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3(1:N) para cada Registro 450                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          ³nRelac -> Flag de relacionamento com os sub-registro        ³±±
±±³          ³nItem -> Flag de relacionamento com os sub-registro         ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegC171(cAlias,nRelac,nItem,cAliasSFT,cAliasCD6)
Local	aRegC171	:=	{}
Local	lRet		:=	.T.
Local	nPos		:=	0                                      
Local 	cCD6Chv		:= (cAliasCD6)->(CD6_FILIAL+CD6_TPMOV+CD6_SERIE+CD6_DOC+CD6_CLIFOR+CD6_LOJA+CD6_ITEM+CD6_COD)
Local aAreaCD6 := (cAliasCD6)-> (GetArea ())

//³Como o layout permite mais de um TANQUE por item, deve-se fazer este WHILE³
While !(cAliasCD6)->(Eof()) .AND. ((cAliasCD6)->(CD6_FILIAL+CD6_TPMOV+CD6_SERIE+CD6_DOC+CD6_CLIFOR+CD6_LOJA+CD6_ITEM+CD6_COD)==cCD6Chv)
    
	//³Tratamento para evitar duplicidade no registro³
	If !Empty((cALiasCD6)->CD6_TANQUE) .And. aScan(aRegC171,{|aX|aX[2]==(cALiasCD6)->CD6_TANQUE})==0
		aAdd(aRegC171, {})
		nPos	:=	Len (aRegC171)
		aAdd (aRegC171[nPos], "C171")						//01 - REG
		aAdd (aRegC171[nPos], (cALiasCD6)->CD6_TANQUE)		 		//02 - NUM_TANQUE
		aAdd (aRegC171[nPos], STR((cALiasCD6)->CD6_VOLUME))		//03 - QTDE
	EndIf
		
	(cALiasCD6)->(dbSkip())
End

RestArea(aAreaCD6)
GrvRegTrS(cAlias,nRelac,aRegC171,nItem)	

Return (lRet)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC172   ³ Autor ³Gustavo G. Rueda       ³ Data ³04.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³              OPERACOES COM ISS (MODELO 01)                 ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro C172                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com a informacao de ISS do Livro Fiscal³±±
±±³          ³ por item SFT posicionado no momento.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³4(1:1) Para cada Registro C170                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          ³nRelac -> Flag de relacionamento com os sub-registros       ³±±
±±³          ³cAliasSFT -> Alias da tabela SFT posicionada                ³±±
±±³          ³nItem -> Contador do item para cada documento fiscal.       ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegC172(cAliasSFT,cAlias,nRelac,nItem)
	Local	lRet   		:=	.T.
	Local	nPos		:=	0
	Local	aRegC172	:=	{}
	//
	aAdd(aRegC172, {})
	nPos := Len (aRegC172)
	aAdd (aRegC172[nPos], "C172" )	 	   		   		//01 - REG 
	aAdd (aRegC172[nPos], (cAliasSFT)->FT_BASEICM )		//02 - VL_BC_ISS_I
	aAdd (aRegC172[nPos], (cAliasSFT)->FT_ALIQICM )		//03 - ALIQ_ISS
	aAdd (aRegC172[nPos], (cAliasSFT)->FT_VALICM  )		//04 - VL_ISS_I
	//
	GrvRegTrS(cAlias,nRelac,aRegC172,nItem)	
Return (lRet)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC173   ³ Autor ³Gustavo G. Rueda       ³ Data ³04.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³           OPERACOES COM MEDICAMENTOS (MODELO 01)           ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro C173                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³da funcao GrvRegTrS com a informacao do lote do produto(SB8)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³4(1:1) Para cada Registro C170                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          ³nRelac -> Flag de relacionamento com os sub-registros       ³±±
±±³          ³nItem -> Contador do item para cada documento fiscal.  	  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegC173(cAlias,nRelac,nItem)
	Local	lRet		:=	.T.
	Local	aReg		:=	{}
	Local	nPos		:=	0

	aAdd(aReg, {})
	nPos	:=	Len (aReg)
	aAdd (aReg[nPos], "C173")								//01 - REG
	aAdd (aReg[nPos], CD7->CD7_LOTE )						//02 - LOTE_MED
	aAdd (aReg[nPos], STR(CD7->CD7_QTDLOT))					//03 - QTD_ITEM
	aAdd (aReg[nPos], CD7->CD7_FABRIC )						//04 - DT_FAB
	aAdd (aReg[nPos], CD7->CD7_VALID )						//05 - DT_VAL
	aAdd (aReg[nPos], CD7->CD7_REFBAS )						//06 - IND_MED
	aAdd (aReg[nPos], CD7->CD7_TPPROD )						//07 - TP_PROD
	aAdd (aReg[nPos], CD7->CD7_PRECO)						//08 - VL_TAB_MAX

	GrvRegTrS(cAlias,nRelac,aReg,nItem)
Return (lRet)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC174   ³ Autor ³Gustavo G. Rueda       ³ Data ³04.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³          OPERACOES COM ARMAS DE FOGO (MODELO 01)           ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro C174                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com a informacao de cada complemento   ³±±
±±³          ³ de produto (SB5) posicionado no momento.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³4(1:1) Para cada Registro C170                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          ³nRelac -> Flag de relacionamento com os sub-registros       ³±±
±±³          ³nItem -> Contador do item para cada documento fiscal.       ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegC174(cAlias,nRelac,nItem)
	Local	lRet		:=	.T.
	Local	aReg		:=	{}
	Local	nPos		:=	0

	aAdd(aReg, {})
	nPos	:=	Len (aReg)
	aAdd (aReg[nPos], "C174")											//01 - REG
	aAdd (aReg[nPos], CD8->CD8_TPARMA)									//02 - IND_ARM
	aAdd (aReg[nPos], CD8->CD8_NUMARM)									//03 - NUM_ARM
	aAdd (aReg[nPos], CD8->CD8_DESCR)									//04 - DESCR_COMPL

	GrvRegTrS(cAlias,nRelac,aReg,nItem)
Return (lRet)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC175   ³ Autor ³Gustavo G. Rueda       ³ Data ³04.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³          OPERACOES COM VEICULOS NOVOS (MODELO 01)          ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro C175                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com a informacao de cada complemento   ³±±
±±³          ³ de produto (SB5) posicionado no momento.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³4(1:1) Para cada Registro C170                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          ³nRelac -> Flag de relacionamento com os sub-registros       ³±±
±±³          ³nItem -> Contador do item para cada documento fiscal.       ³±±
±±³          ³aPartDoc -> Informacoes sobre o participante do documento.  |±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegC175(cAlias,nRelac,nItem,aPartDoc)
	Local	aReg		:=	{}
	Local	nPos		:=	0

	aAdd(aReg, {})
	nPos	:=	Len (aReg)
	aAdd (aReg[nPos], "C175")										//01 - REG
	aAdd (aReg[nPos], CD9->CD9_TPOPER)								//02 - IND_VEIC_OPER
	aAdd (aReg[nPos], aPartDoc[4])									//03 - CNPJ
	aAdd (aReg[nPos], aPartDoc[13])									//04 - UF
	aAdd (aReg[nPos], CD9->CD9_CHASSI)								//05 - CHASSI_VEIC

	GrvRegTrS(cAlias,nRelac,aReg,nItem)
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC176   ³ Autor ³Gustavo G. Rueda       ³ Data ³28.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³                        RESSARCIMENTO                       ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro C176                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com a informacao de ISS do Livro Fiscal³±±
±±³          ³ por item SFT posicionado no momento.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³4(1:1) Para cada Registro C176                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias    -> Alias do TRB que recebera as informacoes       ³±±
±±³          ³nRelac    -> Flag de relacionamento com os sub-registros    ³±±
±±³          ³nItem     -> Contador do item para cada documento fiscal.   ³±±
±±³          ³aCmpAntSFT-> Campos de cabecalho da tabela SFT              ³±±     
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegC176(cAlias,nRelac,nItem,aCmpAntSFT,aReg0150,aWizard,lCmpCD0)
Local 	nPos 		:= 	0
Local 	aRegC176 	:= 	{}
Local	aPartDoc	:=	{}
Local	aAreaSA2	:=	SA2->(GetArea())
Local  cChav		:= CD0->(CD0_FILIAL+CD0_TPMOV+CD0_DOC+CD0_SERIE+CD0_CLIFOR+CD0_LOJA)

	While !CD0->(Eof()) .and. 	cChav == CD0->(CD0_FILIAL+CD0_TPMOV+CD0_DOC+CD0_SERIE+CD0_CLIFOR+CD0_LOJA)
		If CD0->CD0_EMISSAO<=aCmpAntSFT[5] .And. Alltrim(STR(nitem)) == Alltrim(STR(Val(CD0->CD0_ITEM)))
			
			//³GRAVACAO - REGISTRO 0150

			If SA2->(MsSeek(xFilial("SA2")+CD0->(CD0_FORNE+CD0_LOJENT)))
				aPartDoc :=	InfPartDoc("SA2")
			EndIf
				
			//³GRAVACAO REGISTRO 0150 - TABELA DE CADASTRO DE PARTICIPANTES
			//³GRAVACAO REGISTRO 0175 - ALTERACAO DA TABELA DE CADASTRO DE PARTICIPANTE


			SDPF150175(@aReg0150,aPartDoc,cAlias,aWizard,aExistBloc)
					
		
			//³GRAVACAO REGISTRO C176 - RESSARCIMENTO


			aAdd(aRegC176, {})
			nPos	:=	Len (aRegC176)
			aAdd (aRegC176[nPos], "C176")      				 //01-REG
			aAdd (aRegC176[nPos], AModNot(CD0->CD0_ESPECIE)) //02-COD_MOD_ULT_E
			aAdd (aRegC176[nPos], CD0->CD0_DOCENT) 			 //03-NUM_DOC_ULT_E
			aAdd (aRegC176[nPos], CD0->CD0_SERENT)	 		 //04-SER_ULT_E
			aAdd (aRegC176[nPos], CD0->CD0_EMISSAO)			 //05-DT_ULT_E
			aAdd (aRegC176[nPos], Iif(Len(aPartDoc)>0,aPartDoc[1],""))	//06-COD_PART_ULT_E
		   	aAdd (aRegC176[nPos], {CD0->CD0_QUANT,3})		 //07-QUANT_ULT_E - quantidade da ultima entrada
			aAdd (aRegC176[nPos], {CD0->CD0_VUNIT,3})	   	 //08-VL_UNIT_ULT_E
			aAdd (aRegC176[nPos], {CD0->CD0_VALBST,3})		 //09-VL_UNIT_BC_ST			
			
			If cVersao >= "011"			
				If lCmpCD0 // Verifica se campos existem
					//³GRAVACAO - REGISTRO 0150 - 21 COD_PART_NFE_RET
					IF !Empty(CD0->CD0_PANFRT) .And. !Empty(CD0->CD0_LJPANF)
						If SA2->(MsSeek(xFilial("SA2")+CD0->(CD0_PANFRT+CD0_LJPANF)))
							aPartDoc :=	InfPartDoc("SA2")
							SDPF150175(@aReg0150,aPartDoc,cAlias,aWizard,aExistBloc)
						EndIf
					Else
						aPartDoc	:=	{}
					Endif
					
					aAdd (aRegC176[nPos], CD0->CD0_CHVNFE)		//10-CHAVE_NFE_ULT_E				
					aAdd (aRegC176[nPos], CD0->CD0_ITENFE)		//11-NUM_ITEM_ULT_E				
					aAdd (aRegC176[nPos], CD0->CD0_VLUNOP)		//12-VL_UNIT_BC_ICMS_ULT_E				
					aAdd (aRegC176[nPos], CD0->CD0_PICMSE)		//13-ALIQ_ICMS_ULT_E	
					aAdd (aRegC176[nPos], CD0->CD0_BSULMT)		//14-VL_UNIT_LIMITE_BC_ICMS_ULT_E
					aAdd (aRegC176[nPos], CD0->CD0_VLUNCR) 		//15-VL_UNIT_ICMS_ULT_E
					aAdd (aRegC176[nPos], CD0->CD0_ALQSTE)		//16-ALIQ_ST_ULT_E 								 				
					aAdd (aRegC176[nPos], {CD0->CD0_VLUNRE,3})	//17-VL_UNIT_RES
					aAdd (aRegC176[nPos], CD0->CD0_RESPRE)		//18-COD_RESP_RET 	
					aAdd (aRegC176[nPos], CD0->CD0_MOTRES)		//19-COD_MOT_RES				
					aAdd (aRegC176[nPos], CD0->CD0_CHNFRT)		//20-CHAVE_NFE_RET				
					aAdd (aRegC176[nPos], Iif(Len(aPartDoc)>0,aPartDoc[1],""))	//21-COD_PART_NFE_RET							
					aAdd (aRegC176[nPos], CD0->CD0_SRNFRT)		//22-SER_NFE_RET				
					aAdd (aRegC176[nPos], CD0->CD0_NRNFRT)		//23-NUM_NFE_RET				
					aAdd (aRegC176[nPos], CD0->CD0_ITNFRT)		//24-ITEM_NFE_RET				
					aAdd (aRegC176[nPos], CD0->CD0_CODDA)		//25-COD_DA				
					aAdd (aRegC176[nPos], CD0->CD0_NUMDA)		//26-NUM_DA	
				Else
					aAdd (aRegC176[nPos], '')	//10-CHAVE_NFE_ULT_E				
					aAdd (aRegC176[nPos], '')	//11-NUM_ITEM_ULT_E				
					aAdd (aRegC176[nPos], 0)	//12-VL_UNIT_BC_ICMS_ULT_E				
					aAdd (aRegC176[nPos], 0)	//13-ALIQ_ICMS_ULT_E	
					aAdd (aRegC176[nPos], 0)	//14-VL_UNIT_LIMITE_BC_ICMS_ULT_E 				
					aAdd (aRegC176[nPos], 0)	//15-VL_UNIT_ICMS_ULT_E
					aAdd (aRegC176[nPos], 0)	//16-ALIQ_ST_ULT_E 								 				
					aAdd (aRegC176[nPos], 0)	//17-VL_UNIT_RES
					aAdd (aRegC176[nPos], '')	//18-COD_RESP_RET 	
					aAdd (aRegC176[nPos], '')	//19-COD_MOT_RES				
					aAdd (aRegC176[nPos], '')	//20-CHAVE_NFE_RET				
					aAdd (aRegC176[nPos], '')	//21-COD_PART_NFE_RET							
					aAdd (aRegC176[nPos], '')	//22-SER_NFE_RET				
					aAdd (aRegC176[nPos], '')	//23-NUM_NFE_RET				
					aAdd (aRegC176[nPos], '')	//24-ITEM_NFE_RET				
					aAdd (aRegC176[nPos], '')	//25-COD_DA				
					aAdd (aRegC176[nPos], '')	//26-NUM_DA	
				Endif	
			Endif

			RestArea(aAreaSA2)
		EndIf
		CD0->(DbSkip())
	EndDo
	//Ordenando Array pela emissao da ultima entrada e número de documento
	aRegC176 := aSort(aRegC176,,,{|x,y| x[5] < y[5] })	
	GrvRegTrS(cAlias,nRelac,aRegC176,nItem)			
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC177   ³ Autor ³Gustavo G. Rueda       ³ Data ³04.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³          OPERACOES COM SELO DE CONTROLE DE IPI             ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro C177                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com a informacao de ISS do Livro Fiscal³±±
±±³          ³ por item SFT posicionado no momento.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³4(1:1) Para cada Registro C177                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias    -> Alias do TRB que recebera as informacoes       ³±±
±±³          ³nRelac    -> Flag de relacionamento com os sub-registros    ³±±
±±³          ³cAliasSFT -> Alias da tabela SFT posicionada                ³±±
±±³          ³nItem     -> Contador do item para cada documento fiscal.   ³±±
±±³          ³cAliasSB1 -> Alias da tabela SB1, podendo ser query         ³±±
±±³          ³aRegC170  -> Informacoes do registro C170                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegC177(cAlias,nRelac,cAliasSFT,nItem,cAliasSB1,aRegC170)
	Local	lRet   		:=	.T.
	Local	aReg		:=	{}
	Local	nPos		:=	0

	aAdd(aReg, {})
	nPos	:=	Len (aReg)
	aAdd (aReg[nPos], "C177")	 	   	   					//01 - REG
	aAdd (aReg[nPos], (cAliasSB1)->B1_CLASSE)				//02 - COD_SELO_IPI
	aAdd (aReg[nPos], aRegC170[Len(aRegC170),5])	   		//03 - QT_SELO_IPI

	GrvRegTrS(cAlias,nRelac,aReg,nItem)
Return (lRet)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC178   ³ Autor ³Gustavo G. Rueda       ³ Data ³04.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³ PRODUTOS SUJEITOS A TRIBUTACAO DE IPI POR UNIDADE OU QTD   ³±±
±±³          ³                                                            ³±±
±±³Descri‡…o ³Geracao e gravacao do Registro C178                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com todas as guias de recolhimento com ³±±
±±³          ³ a data de referencia no periodo apurado.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3(1:N) para cada Registro 450                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias   -> Alias do TRB que recebera as informacoes        ³±±
±±³          ³nRelac   -> Flag de relacionamento com os sub-registro      ³±±
±±³          ³nItem    -> Flag de relacionamento com os sub-registro      ³±±
±±³          ³cAliasSB1-> Alias da tabela SB1, podendo ser query          ³±±
±±³          ³aRegC170  -> Informacoes do registro C170                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegC178(cAlias,cAliasSFT,nRelac,nItem,cAliasSB1,aRegC170)
	Local	aRegC178	:=	{}
	Local	lRet		:=	.T.
	Local	nPos		:=	0
	Local	nPauta		:=	0   

	If (cAliasSFT)->FT_PAUTIPI>0
		nPauta	:=	(cAliasSFT)->FT_PAUTIPI
	ElseIf !Empty((cAliasSB1)->B1_TAB_IPI) .And. (cAliasSB1)->B1_VLR_IPI>0
		nPauta	:=	(cAliasSB1)->B1_VLR_IPI
	EndIf				

	aAdd(aRegC178, {})
	nPos	:=	Len (aRegC178)
	aAdd (aRegC178[nPos], "C178")							//01 - REG
	aAdd (aRegC178[nPos], (cAliasSB1)->B1_TAB_IPI)			//02 - CL_ENQ
	aAdd (aRegC178[nPos], nPauta)							//03 - VL_UNID
	aAdd (aRegC178[nPos], {aRegC170[Len(aRegC170),5,1],3})		//04 - QUANT_PAD

	GrvRegTrS(cAlias,nRelac,aRegC178,nItem)	
Return (lRet)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC190   ³ Autor ³Gustavo G. Rueda       ³ Data ³04.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³      REGISTRO ANALITICO DO DOCUMENTO (MODELO 01, 04 e 55)  ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao do Registro C190                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoes contidas no array   ³±±
±±³          ³ aRegC170(Itens) aglutinados CFOP, CST e ALIQ.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3(1:N) Para cada Registro C100                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aRegC170  -> Informacoes dos Itens do documento fiscal      ³±±
±±³          ³cAliasSFT -> Alias da tabela SFT posicionada no momento     ³±±
±±³          ³aRegC190  -> Array contendo as informacoes aglutinadas do   ³±±
±±³          ³ do documento fiscal para posterior geracao na funcao prin- ³±±
±±³          ³ cipal.                                                     |±±
±±³          ³cSituaDoc -> Situacao do documento fiscal                   |±±
±±³          ³aLanCda   -> Lancamentos do documento fiscal - CDA		  |±±
±±³          ³nRedBSICM -> Valor de reducao da base de calculo do ICMS    |±±
±±³          ³cAliasSF4-> Informa qual o alias da tabela SF4, podendo ser ³±±
±±³          ³            query                                           ³±±
±±³          ³cMVCFC195 -> CFOP's que nao vao gerar C195			      |±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegC190(aRegC170,cAliasSFT,aRegC190,cSituaDoc,aLanCda,nRedBSICM,cAliasSF4,cMVCFC195,cSitDocInf)
	Local	nPos		:=	0
	Local  lConsumo	:= .F.
	Local	lAtvPerm	:= .F.
	Local	nPosIt		:=	0
	Local	lRedBSICM	:=	cSituaDoc$"00/01" .AND. substr(aRegC170[1][10],2,2)$'20/70'

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Identificacao de material de uso e consumo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Substr(Alltrim((cAliasSFT)->FT_CFOP),2,3)$"97 " .Or.;
		(Substr(Alltrim((cAliasSFT)->FT_CFOP),2,3)$"556" .And. Substr(Alltrim((cAliasSFT)->FT_CLASFIS),2,2)<>"40") 
    	lConsumo := .t.             
	EndIf

	//³Identificacao de ativo permanente³
	If Substr(Alltrim((cAliasSFT)->FT_CFOP),2,3)$"91 " .Or. Substr(Alltrim((cAliasSFT)->FT_CFOP),2,3)$"551"
    	 lAtvPerm := .t.
	EndIf
	
	If (nPos := aScan (aRegC190, {|aX| aX[2]==aRegC170[1][10] .And. aX[3]==aRegC170[1][11] .And. aX[4]==aRegC170[1][14]}) ) == 0
		aAdd(aRegC190, {})
		nPos	:=	Len(aRegC190)
		aAdd (aRegC190[nPos], "C190")	 	   					//01 - REG
		aAdd (aRegC190[nPos], aRegC170[1][10])				//02 - CST
		aAdd (aRegC190[nPos], aRegC170[1][11])				//03 - CFOP
		aAdd (aRegC190[nPos], aRegC170[1][14])				//04 - ALIQ_ICMS
		aAdd (aRegC190[nPos], 0)		 		 				//05 - VL_OPR
		aAdd (aRegC190[nPos], 0)								//06 - VL_BC_ICMS
		aAdd (aRegC190[nPos], 0)	 		  					//07 - VL_ICMS
		aAdd (aRegC190[nPos], 0)	 							//08 - VL_BC_ICMS_ST
		aAdd (aRegC190[nPos], 0)	 		  					//09 - VL_ICMS_ST
		aAdd (aRegC190[nPos], 0)  			  				//10 - VL_RED_BC
		aAdd (aRegC190[nPos], 0)	 							//11 - VL_IPI

		If cVersao >= "003"
			aAdd (aRegC190[nPos], "") 		  				//12 - COD_OBS - LAYOUT 2010
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando este array estiver com conteudo, jah terah de todos os itens,³
			//³ neste caso, preciso obter somente o lancamento do referido item    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len(aLanCDA)>0 .And. (nPosIt := aScan(aLanCDA,{|aX|aX[14]==(cAliasSFT)->FT_ITEM}))>0
				aRegC190[nPos][12]  :=  aLanCDA[nPosIt,7]
			Elseif Empty(aRegC190[nPos][12])
				If !Empty((cAliasSF4)->F4_CODOBSE) .And. !(Alltrim((cAliasSFT)->FT_CFOP)$cMVCFC195)
			   		aRegC190[nPos][12] := (cAliasSF4)->F4_CODOBSE
		   		EndIf 
		   	EndIf					
  		EndIf
	EndIf
	If !cSituaDoc$"02#04#05#03"
		aRegC190[nPos][5]		+=	(cAliasSFT)->FT_VALCONT	 		  	//05 - VL_OPR
		aRegC190[nPos][6]		+=	aRegC170[1][13]					  	//06 - VL_BC_ICMS
		aRegC190[nPos][7]		+=	aRegC170[1][15]					  	//07 - VL_ICMS
		aRegC190[nPos][8]		+=	aRegC170[1][16]			  		  	//08 - VL_BC_ICMS_ST
		aRegC190[nPos][9]		+=	aRegC170[1][18]			  		  	//09 - VL_ICMS_ST
		aRegC190[nPos][10]	+=	Iif(nRedBSICM < 0, 0 ,iif(lRedBSICM,nRedBSICM,0))		//10 - VL_RED_BC - Validacao utilizada para casos em que a reducao de base eh maior do que 100%
		aRegC190[nPos][11]	+=	aRegC170[1][24]				   		//11 - VL_IPI
	Endif
		
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  ³C195C197  ³ Autor ³Gustavo G. Rueda       ³ Data ³15.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³     REGISTRO C195 - OBSERVACOES DO LANCAMENTO FISCAL       ³±±
±±³          ³                    (CODIGO 01 E 55)                        ³±±
±±³          ³REGISTRO C197 - OUTRAS OBRIGACOES TRIBUTARIAS, AJUSTES E    ³±±
±±³          ³                INFORMACOES DE VALORES                      ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao dos Registros C195 e C197              ³±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com o embasamento legal para tais      ³±±
±±³          ³ observacoes                                                ³±±
±±³Nivel Hier³3(1:N) Para cada C100                                       ³±±
±±³          ³4(1:N) Para cada C195                                       ³±±
±±³Retorno   ³Nil                                                         ³±±
±±³Parametros³cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          ³nRelac -> Flag de relacionamento com os sub-registros       ³±±
±±³          ³aLanCDA-> Array com os lancamentos da tabela CDA            ³±±
±±³          ³aReg0460-> Array com a estrutura do registro 0460           ³±±
±±³          ³aCmpAntSFT-> Campos da tabela SFT do documento em           ³±±
±±³          ³             processamento                                  ³±±
±±³          ³cEspecie-> Especie do document fiscal                       ³±±
±±³          ³aC195aux-> Array auxiliar com o codigo da observacao do     ³±±
±±			 ³lancamento fiscal (F4_CODOBSE)           					  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C195C197( cAlias, nRelac, aLanCDA, aReg0460, aCmpAntSFT, cEspecie, aC195aux, cMVEstado, aReg0200, aReg0190, aReg0220, dDataDe, dDataAte,cMVSPDTC95, aWizard  )

Local	nPos		:=	0
Local	nPosC195	:=	0
Local	nX			:=	0
Local	nPos195	:=	0
Local	aRegC195	:=	{}
Local	aRegC197	:=	{}
Local	cCodItem	:=	""
Local 	aSpdInfo	:= {}
Local 	cEntSai	:=	Iif ("E"$aCmpAntSFT[43], "1", "2")

Default aC195aux 	:=	{}
Default cMVSPDTC95 := "1"
DEFAULT aWizard	:= {}

//³Processando lancamentos do documento fiscal relacionados no CDA³
For nX := 1 to len(aLanCDA)

	// -------------------------------------------------------------------------------------------------------
	// A validacao para modelo 55(NFe) de Emissao propria foi retirada da funcao C195C197() - esta validacao
	// fazia com que o campo 04 - COD_ITEM do Registro C197 ficasse em branco - pois segundo o Guia Pratico
	// quando se enquadrar nesta situacao, o campo 04 deve ser gerado e o item deve gerar um registro 0200 para
	// este produto.
	//
	// Campo 04 - Preenchimento: deve ser informado se o ajuste/benefício for relacionado ao produto. Porém, quando não
	// houver registro C170, como NF-e de emissão própria, o COD_ITEM deverá ser informado no registro 0200.
	// -------------------------------------------------------------------------------------------------------
	cCodItem	:=	aLanCDA[nX,13]
	
	//³Para lançamentos com código RO10000012, no registro C197 não deverá preencher o campo COT_ITEM, ³
	//³conforme item 1, 3, 6, 7 e 8 do anexo da instrução normativa 005/12 para o Estado de Rondoônia. ³
	IF aLanCDA[nX,1] $ "RO10000012/RO10000006/RO10000007/RO10000003/RO40000001/RO40000002/RO99990009/RO99990016/RO99990017/RO99990068/RO99990165/RO99990195/RO99990166/RO99990170/RO99990183/RO99990175/RO99990021/RO99990130/RO99990022/RO99990037/RO99990086/RO99990116/RO20000002/RO99990078/RO99990083"
		cCodItem	:=	""
	EndIF

	//³Geracao do REGISTRO C195 ³
	If (nPosC195 := aScan(aRegC195,{|aX| aX[2]==aLanCDA[nX][07]}))==0
		aAdd(aRegC195, {})
		nPosC195	:=	Len (aRegC195)
		aAdd (aRegC195[nPosC195], "C195")		 	   					//01 - REG
		aAdd (aRegC195[nPosC195], aLanCDA[nX][07])						//02 - COD_OBS
		aAdd (aRegC195[nPosC195], If(AllTrim(cMVSPDTC95) <> "4",aLanCDA[nX][17], " "))	//03 - TXT_COMPL		
		
		//³REGISTRO 0460 - TABELA DE OBSERVACOES DO LANCAMENTO FISCAL      ³
		Reg0460(@aReg0460,{aLanCDA[nX][7],aLanCDA[nX][20]})
	EndIf 
	
	//³AQUISIÇÃO, EM OUTRA UNIDADE DA FEDERAÇÃO, DE BENS OU MERCADORIAS DESTINADOS AO USO, CONSUMO OU ATIVO FIXO (INCISO VI   ³
	//³DO ART. 5º DA LEI N. 1.810/1997), POR CONTRIBUINTE SUJEITO À APURAÇÃO E PAGAMENTO DO ICMS, NA MODALIDADE DE DIFERENCIAL³
	//³DE ALÍQUOTA, NO PRAZO ESTABELECIDO NO CALENDÁRIO FISCAL OU NO MOMENTO DA ENTRADA EM TERRITÓRIO ESTADUAL.               ³
	//³GOVERNO DO ESTADO DE MATO GROSSO DO SUL - CÓDIGO DE AJUSTE MS70000001 / MS40000001  									  ³	
	//³ http://www.efd.ms.gov.br/index.php?inside=1&tp=3&comp=&show=4728 - DIFAL												  ³
	If cMVEstado$"MS" .And. aLanCDA[nX,1]$"MS70000001/MS40000001" 
		aLanCDA[nX][4] := aLanCDA[nX][4] - aCmpAntSFT[11] 
	Endif

	//³Geracao do REGISTRO C197 ³
	If cMVEstado<>"PE"
		If (nPos := aScan(aRegC197,{|x| x[5]==cCodItem .And. x[3]==aLanCDA[nX,1]}))==0
			aAdd(aRegC197, {})
			nPos	:=	Len (aRegC197)
			aAdd (aRegC197[nPos], nPosC195)									//01 - RELACIONAMENTO COM C195 (PAI)
			aAdd (aRegC197[nPos], "C197")	   								//02 - REG
			aAdd (aRegC197[nPos], aLanCDA[nX,1])				       		//03 - COD_AJ
			aAdd (aRegC197[nPos], aLanCDA[nX][2])					   		//04 - DESCR_COMPL_AJ
			aAdd (aRegC197[nPos], cCodItem)									//05 - COD_ITEM
			aAdd (aRegC197[nPos], aLanCDA[nX][3])							//06 - VL_BC_ICMS
			aAdd (aRegC197[nPos], aLanCDA[nX][4])	 						//07 - ALIQ_ICMS
			aAdd (aRegC197[nPos], aLanCDA[nX][5])							//08 - VL_ICMS
			aAdd (aRegC197[nPos], aLanCDA[nX][6])							//09 - VL_OUTROS
		Else
		    aRegC197[nPos][6]	+= aLanCDA[nX][3]							//06 - VL_BC_ICMS
			aRegC197[nPos][8]	+= aLanCDA[nX][5]							//08 - VL_ICMS
			aRegC197[nPos][9]	+= aLanCDA[nX][6]							//09 - VL_OUTROS
		EndIf    
	EndIf	
	//³Tratamento para que os itens utilizados seja gerados no 0200³
	If !Empty( cCodItem ) .And.  aScan ( aReg0200, { |aX| aX[2] == cCodItem }) == 0
		SFRG0200( cAlias, @aReg0200, @aReg0190, dDataDe, dDataAte, ,cCodItem , @aReg0220,,,,,,,,,,,,,,,,,,,aWizard  )
	EndIf	
Next        

If !aExistBloc[23] 
	//³Geracao do REGISTRO C195 ³
	For nX := 1 To Len(aC195aux)  
		If (nPos195 := aScan(aRegC195,{|aX| aX[2]==aC195aux[nX][1]}))==0
			aAdd(aRegC195, {})
			nPos195	:=	Len (aRegC195)
			aAdd (aRegC195[nPos195], "C195")		 	   					//01 - REG
			aAdd (aRegC195[nPos195], aC195aux[nX][1])						//02 - COD_OBS
			aAdd (aRegC195[nPos195], aC195aux[nX][3])		   				//03 - TXT_COMPL
			
			//³REGISTRO 0460 - TABELA DE OBSERVACOES DO LANCAMENTO FISCAL      ³
			Reg0460(@aReg0460,{aC195aux[nX][1],aC195aux[nX][4]})
		Endif			
	Next nX

Else

	// Geração do registro C195 e 0460 apartir do PE SPDPINFO //
	aSpdInfo	:=	ExecBlock("SPDPINFO",.F.,.F.,{	aCmpAntSFT[1],; 	//FT_NFISCAL
														aCmpAntSFT[2],; 	//FT_SERIE
														aCmpAntSFT[3],; 	//FT_CLIEFOR
														aCmpAntSFT[4],; 	//FT_LOJA
														aCmpAntSFT[5],;	//FT_ENTRADA
														cEntSai})			//Entrada/Saida
	//³Geracao do REGISTRO C195 ³
	For nX := 1 To Len(aSpdInfo)  
		If (nPos195 := aScan(aRegC195,{|aX| aX[2]==aSpdInfo[nX][1]}))==0
			aAdd(aRegC195, {})
			nPos195	:=	Len (aRegC195)
			aAdd (aRegC195[nPos195], "C195")		 	   					//01 - REG
			aAdd (aRegC195[nPos195], aSpdInfo[nX][1])		 				//02 - COD_OBS
			aAdd (aRegC195[nPos195], aSpdInfo[nX][2])		   				//03 - TXT_COMPL
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³REGISTRO 0460 - TABELA DE OBSERVACOES DO LANCAMENTO FISCAL      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Reg0460(@aReg0460,aSpdInfo[nX])
		Endif			
	Next nX
Endif


GrRegDep(cAlias,aRegC195,aRegC197,,,,nRelac)

Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³RegC300   | Autor ³Gustavo G. Rueda 			   ³ Data ³09.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao que efetua a criaca do array responsavel pela geracao do    ³±±
±±³          ³ registro C300 - RESUMO DIARIO DAS NOTAS FISCAIS DE VENDA A        ³±±
±±³          ³ CONSUMIDOR FINAL (CODIGO 02). Este array eh gravado no arquivo de ³±±
±±³          ³ trabalho do SPED Fiscal no final do processamento da rotina.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpL1 := RegC300(cSituaDoc,cEspecie,aRegC300,cAliasSFT)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cPar1 - Variavel que possui o status do documento fiscal           ³±±
±±³          ³cPar2 - Variavel que possui a especie do documento fiscal          ³±±
±±³          ³aPar3 - Variavel array com as informacoes para geracao do registro ³±±
±±³          ³cPar4 - Alias da tabela SFT em processamento                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1 - Posicao de gravacao do registro para relacionamento com    ³±±
±±³          ³        seus registros filhos, C310, C320 e C321.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegC300(cSituaDoc,cEspecie,aRegC300,cAliasSFT,lNotaC300,aWizard)

Local  nPosC300	 :=	0   
Local  cNotaC300 := ""
Local	cContCtb	:= RetCOD_CTA(cAliasSFT, "C300")
Default aWizard	 := {}

If Len(AllTrim((cAliasSFT)->FT_NFISCAL)) > 6 .And.  Val(Left(AllTrim((cAliasSFT)->FT_NFISCAL),Len(AllTrim((cAliasSFT)->FT_NFISCAL))-6)) > 0
	lNotaC300   := .F.
EndIf
cNotaC300   := Right(AllTrim((cAliasSFT)->FT_NFISCAL),6)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³REGISTRO C300 - RESUMO DIARIO DAS NOTAS FISCAIS DE VENDA A CONSUMIDOR(MODELO 02)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nPosC300 := aScan(aRegC300,{|aX| aX[2]==cEspecie .And. aX[3]==(cAliasSFT)->FT_SERIE .And. aX[7]==(cAliasSFT)->FT_ENTRADA}))==0
	aAdd(aRegC300, {})
	nPosC300	:=	Len (aRegC300)
	aAdd (aRegC300[nPosC300], "C300")	 	   		   		//01 - REG
	aAdd (aRegC300[nPosC300], cEspecie)		  				//02 - COD_MOD
	aAdd (aRegC300[nPosC300], (cAliasSFT)->FT_SERIE)		//03 - SER
	aAdd (aRegC300[nPosC300], "")							//04 - SUB
	aAdd (aRegC300[nPosC300], cNotaC300)					//05 - NUM_DOC_INI
	aAdd (aRegC300[nPosC300], cNotaC300)		   			//06 - NUM_DOC_FIN
	aAdd (aRegC300[nPosC300], (cAliasSFT)->FT_ENTRADA)		//07 - DT_DOC
	aAdd (aRegC300[nPosC300], 0)							//08 - VL_DOC
	aAdd (aRegC300[nPosC300], 0)							//09 - VL_PIS
	aAdd (aRegC300[nPosC300], 0)							//10 - VL_COFINS
	aAdd (aRegC300[nPosC300], Iif(!Empty(cContCtb),cContCtb,(cAliasSFT)->FT_CONTA))		//11 - COD_CTA
EndIf

//³Range de Numero de Documentos³
If cNotaC300 < aRegC300[nPosC300][5]
	aRegC300[nPosC300][5]	:=	cNotaC300		//05 - NUM_DOC_INI
EndIf

If (cNotaC300 > aRegC300[nPosC300][6])
	aRegC300[nPosC300][6]	:=	cNotaC300		//06 - NUM_DOC_FIN
EndIf

If !cSituaDoc$"02#03"	//02=Situacao de cancelada
	aRegC300[nPosC300][8]	+=	(cAliasSFT)->FT_TOTAL		//08 - VL_DOC
	If ("1"$aWizard[1][15] .And. (cAliasSFT)->FT_VALPIS > 0)
		aRegC300[nPosC300][9]	+=	(cAliasSFT)->FT_VALPIS	//09 - VL_PIS
	Else
		aRegC300[nPosC300][9]	:=	""							//09 - VL_PIS
	EndIf
	
	If ("1"$aWizard[1][15] .And. (cAliasSFT)->FT_VALCOF > 0)
		aRegC300[nPosC300][10]	+=	(cAliasSFT)->FT_VALCOF	//10 - VL_COFINS
	Else
		aRegC300[nPosC300][10]	:=	""							//10 - VL_COFINS
	EndIf
EndIf
Return nPosC300
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³RegC310   | Autor ³Gustavo G. Rueda 			   ³ Data ³09.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao que efetua a criaca do array responsavel pela geracao do    ³±±
±±³          ³ registro C310 - DOCUMENTOS CANCELADOS DE NOTAS FISCAIS DE VENDA A ³±±
±±³          ³ CONSUMIDOR FINAL (CODIGO 02). Este array eh gravado no arquivo de ³±±
±±³          ³ trabalho do SPED Fiscal no final do processamento da rotina.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³RegC310(nPosC300,aRegC310,cAliasSFT)   			                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nPar1 - Variavel que possui a posicao de relacionamento com o C300 ³±±
±±³          ³aPar2 - Variavel array com as informacoes para geracao do registro ³±±
±±³          ³cPar3 - Alias da tabela SFT em processamento                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegC310(nPosC300,aRegC310,cAliasSFT)
Local	nPosC310	:=	0     
Local 	cNFiscal  	:= Right(AllTrim((cAliasSFT)->FT_NFISCAL),6)

If aScan(aRegC310,{|aX| aX[1]==nPosC300 .And. aX[3]==cNFiscal})==0
	aAdd(aRegC310, {})
	nPosC310	:=	Len (aRegC310)
	aAdd (aRegC310[nPosC310], nPosC300)	 	   			//CHAVE PARA RELACIONAMENTO COM REGISRO PAI
	aAdd (aRegC310[nPosC310], "C310")					//01 - REG
	aAdd (aRegC310[nPosC310], cNFiscal)					//02 - NUM_DOC_CANC
EndIf
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³C320C321  | Autor ³Gustavo G. Rueda 			   ³ Data ³09.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao que efetua a criaca do array responsavel pela geracao do    ³±±
±±³          ³ registro C320 - REGISTRO ANALITIDO DO RESUMO DIARIO DAS NOTAS     ³±±
±±³          ³ FISCAIS DE VENDA A CONSUMIDOR FINAL (CODIGO 02) e registro C321 - ³±±
±±³          ³ ITENS DO RESUMO DIARIO DOS DOCUMENTOS (CODIGO 02). Este array eh  ³±±
±±³          ³ gravado no arquivo de trabalho do SPED Fiscal no final do         ³±±
±±³          ³ processamento da rotina.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³C320C321(nPosC300,cSituaDoc,aRegC170,aRegC320,aRegC321,cAliasSFT,  ³±±
±±³						cAliasSF4)												 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nPar1 - Variavel que possui a posicao de relacionamento com o C300 ³±±
±±³          ³aPar2 - Variavel array com as informacoes jah processadas e armaze-³±±
±±³          ³        nadas anteriormente, assim fica uma unica origem           ³±±
±±³          ³aPar3 - Variavel array com as informacoes para geracao do registro ³±±
±±³          ³aPar4 - Variavel array com as informacoes para geracao do registro ³±±
±±³          ³cPar5 - Alias da tabela SFT em processamento                       ³±±
±±³          ³aPar6 - array com os lancamentos do documento fiscal               ³±±
±±³          ³nPar7 - Valor de reducao da base de calculo do ICMS                |±±
±±³          ³cPar8 -> Alias da tabela SF4 em processamento   					 ³±±
±±³          ³aPar9 -> Array com lancamentos de documento nao amarrados ao C197  ³±±
±±³          ³aPar10-> Array com a estrutura do 0460 gerado ateh o momento.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C320C321(nPosC300,aRegC170,aRegC320,aRegC321,cAliasSFT,aLanCDA,nRedBSICM,cAliasSF4,aLancFis,aReg0460,aWizard,cPerfil)
Local	nPosC320	:=	0
Local	nPosC321	:=	0	
Default aWizard		:= {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³REGISTRO C320 - REGISTRO ANALITICO DO RESUMO DIARIO DAS NOTAS FISCAIS DE VENDA A CONSUMIDOR  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nPosC320 := aScan(aRegC320,{|aX| aX[1]==nPosC300 .And. aX[3]==aRegC170[1][10] .And. aX[4]==aRegC170[1][11] .And. aX[5]==aRegC170[1][14]}))==0
	aAdd(aRegC320, {})
	nPosC320	:=	Len (aRegC320)
	aAdd (aRegC320[nPosC320], nPosC300)	 	   						//CHAVE PARA RELACIONAMENTO COM REGISRO PAI		
	aAdd (aRegC320[nPosC320], "C320")	 	   						//01 - REG
	aAdd (aRegC320[nPosC320], aRegC170[1][10])						//02 - CST_ICM
	aAdd (aRegC320[nPosC320], aRegC170[1][11])						//03 - CFOP
	aAdd (aRegC320[nPosC320], aRegC170[1][14])						//04 - ALIQ_ICM
	aAdd (aRegC320[nPosC320], 0 )									//05 - VL_OPR
	aAdd (aRegC320[nPosC320], 0 )									//06 - VL_BC_ICM
	aAdd (aRegC320[nPosC320], 0 )									//07 - VL_ICMS
	aAdd (aRegC320[nPosC320], 0 )									//08 - VL_RED_BC
	aAdd (aRegC320[nPosC320], "")						

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se houver lancamento fiscal nao amarrado ao C197, devo prioriza-lo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aLancFis)>=1
   		aRegC320[nPosC320,10] := aLancFis[1,1]

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REGISTRO 0460 - TABELA DE OBSERVACOES DO LANCAMENTO FISCAL      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   		Reg0460(@aReg0460,{aLancFis[1,1],aLancFis[1,2]})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quando este array estiver com conteudo, jah terah de todos os itens,³
	//³ neste caso, preciso obter somente o lancamento do referido item    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	ElseIf Len(aLanCDA)>0 .And. (nPosIt := aScan(aLanCDA,{|aX|aX[14]==(cAliasSFT)->FT_ITEM}))>0
		aRegC320[nPosC320,10]  :=  aLanCDA[nPosIt,7]				//09 - COD_OBS

	EndIf
EndIf
aRegC320[nPosC320][6]		+=	aRegC170[1][7]						//05 - VL_OPR
aRegC320[nPosC320][7]		+=	aRegC170[1][13]						//06 - VL_BC_ICMS
aRegC320[nPosC320][8]		+=	aRegC170[1][15]						//07 - VL_ICMS
aRegC320[nPosC320][9]		+=	nRedBSICM							//08 - VL_RED_BC

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³REGISTRO C321 - ITENS DO RESUMO DIARIO DOS DOCUMENTOS(MODELO 02)                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
If  !cPerfil$"C"
	If (nPosC321 := aScan(aRegC321,{|aX| aX[1]==nPosC320 .And. aX[3]==aRegC170[1][3]}))==0  
		aAdd(aRegC321, {})
		nPosC321	:=	Len (aRegC321)
		aAdd (aRegC321[nPosC321], nPosC320)	 	   				//CHAVE PARA RELACIONAMENTO COM REGISRO PAI
		aAdd (aRegC321[nPosC321], "C321")	 	   				//01 - REG
		aAdd (aRegC321[nPosC321], aRegC170[1][3])				//02 - COD_ITEM
		aAdd (aRegC321[nPosC321], {0,3})						//03 - QTD
		aAdd (aRegC321[nPosC321], aRegC170[1][6])				//04 - UNID
		aAdd (aRegC321[nPosC321], 0)							//05 - VL_ITEM
		aAdd (aRegC321[nPosC321], 0)							//06 - VL_DESC
		aAdd (aRegC321[nPosC321], 0)							//07 - VL_BC_ICMS
		aAdd (aRegC321[nPosC321], 0)					   		//08 - VL_ICMS
		aAdd (aRegC321[nPosC321], 0)					   		//09 - VL_PIS
		aAdd (aRegC321[nPosC321], 0)					   		//10 - VL_COFINS
	EndIf
	aRegC321[nPosC321][4][1]	+=	aRegC170[1][5][1]	   		//04 - QTD
	aRegC321[nPosC321][6]		+=	aRegC170[1][7]				//05 - VL_ITEM // FT_TOTAL
	aRegC321[nPosC321][7]		+=	aRegC170[1][8]		  		//06 - VL_DESC
	aRegC321[nPosC321][8]		+=	aRegC170[1][13]		   		//07 - VL_BC_ICMS
	aRegC321[nPosC321][9]		+=	aRegC170[1][15]		  		//08 - VL_ICMS
	If ("1"$aWizard[1][15] .And. aRegC170[1][30]> 0)
		aRegC321[nPosC321][10]		+=	aRegC170[1][30]	   		//09 - VL_PIS	
	Else
		aRegC321[nPosC321][10]		:= ""					   		//09 - VL_PIS
	EndIf
	
	If ("1"$aWizard[1][15] .And. aRegC170[1][36] > 0)		  
		aRegC321[nPosC321][11]		+=	aRegC170[1][36]	   		//10 - VL_COFINS	
	Else
		aRegC321[nPosC321][11]		:=	""					   		//10 - VL_COFINS
	EndIf	  
EndIf
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³C350C390  ³ Autor ³Gustavo G. rueda       ³ Data ³09.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³       NOTA FISCAL DE VENDA A CONSUMIDOR (CODIGO 02)        ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro C350                       ³±±
±±³          ³- gravacao do Registro C390                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoe contidas no array    ³±±
±±³          ³ aRegC100.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³2(varios por arquivo)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cPar1 - Alias do arquivo de trabalho                        ³±±
±±³          ³nPar2 - Variavel de controle de relacionamento de documentos³±±
±±³          ³aPar3 - Variavel array com as informacoes jah processadas e ³±±
±±³          ³        armazenadas anteriormente, assim fica uma unica ori-³±±
±±³          ³        para as informacoes do cabecalho do documento       ³±±
±±³          ³aPar4 - Variavel array com as informacoes do participante   ³±±
±±³          ³cPar5 - Alias da tabela SFT em processamento                ³±±
±±³          ³aPar6 - Variavel array com as informacoes processadas ante- ³±±
±±³          ³        para a geracado do registro neste momento, junto com³±±
±±³          ³lPar7 - Variavel que indica se existem notas fiscais com    ³±±
±±³          ³		  mais de 6 caracteres no arquivo do Sped             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C350C390(cAlias,nRelac,aRegC100,aPartDoc,cAliasSFT,aRegC390,lNotaC350,aWizard)
Local	nPos		:=	0
Local	aRegC350	:=	{}  
Local	cContCtb	:= RetCOD_CTA(cAliasSFT, "C350")
Local   cNotaC350   := 	""
Default aWizard		:= {}

If Len(AllTrim(aRegC100[1][8]))>6 .And.;
    Val(Left(AllTrim(aRegC100[1][8]),Len(AllTrim(aRegC100[1][8]))-6))>0
	lNotaC350   := .F.
EndIf
cNotaC350   := Right(AllTrim(aRegC100[1][8]),6)

aAdd(aRegC350, {})
nPos	:=	Len (aRegC350)
aAdd (aRegC350[nPos], "C350")	 	   										//01 - REG
aAdd (aRegC350[nPos], aRegC100[1][7])	   									//02 - SER
aAdd (aRegC350[nPos], "")													//03 - SUB
aAdd (aRegC350[nPos], cNotaC350)		   									//04 - NUM_DOC
aAdd (aRegC350[nPos], aRegC100[1][10])	   									//05 - DT_DOC
aAdd (aRegC350[nPos], Iif(Empty(aPartDoc[04]),aPartDoc[05],aPartDoc[04]))	//06 - CPF_CNPJ
aAdd (aRegC350[nPos], aRegC100[1][16])	   									//07 - VL_MERC
aAdd (aRegC350[nPos], aRegC100[1][12])	   									//08 - VL_DOC
aAdd (aRegC350[nPos], aRegC100[1][14])	   									//09 - VL_DESC
aAdd (aRegC350[nPos], Iif("1"$aWizard[1][15],Iif(aRegC100[1][26]>0,aRegC100[1][26],""),""))	   									//10 - VL_PIS
aAdd (aRegC350[nPos], Iif("1"$aWizard[1][15],Iif(aRegC100[1][27]>0,aRegC100[1][27],""),""))	   									//11 - VL_COFINS
aAdd (aRegC350[nPos], Iif(!Empty(cContCtb),cContCtb,(cAliasSFT)->FT_CONTA )) 								//12 - COD_CTA
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gravacao das informacoes dos registros respeitando o relacionamento ³
//³  de documentos (RelacDoc)                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GrvRegTrS (cAlias, nRelac, aRegC350)
GrvRegTrS (cAlias, nRelac, aRegC390)

Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC370   ³ Autor ³Gustavo G. Rueda       ³ Data ³09.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³               ITENS DO DOCUMENTO (CODIGO 02)               ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro C370                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoe contidas no array    ³±±
±±³          ³ aRegC170 para o Modelo 06.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3(1:N) Para cada C350                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegC370 (cAlias, nRelac, aRegC170, nItem)
Local	lRet   		:=	.T.
Local	nPos		:=	0
Local	aRegC370	:=	{}

aAdd(aRegC370, {})
nPos	:=	Len (aRegC370)
aAdd (aRegC370[nPos], "C370")	 	   					//01 - REG
aAdd (aRegC370[nPos], aRegC170[1][2])	   				//02 - NUM_ITEM
aAdd (aRegC370[nPos], aRegC170[1][3])	   				//03 - COD_ITEM
aAdd (aRegC370[nPos], aRegC170[1][5][1])				//04 - QTD
aAdd (aRegC370[nPos], aRegC170[1][6])	   				//05 - UNID
aAdd (aRegC370[nPos], aRegC170[1][7])	   				//06 - VL_ITEM
aAdd (aRegC370[nPos], aRegC170[1][8])	   				//07 - VL_DESC

GrvRegTrS(cAlias,nRelac,aRegC370,nItem)

Return (lRet)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC390   ³ Autor ³Gustavo G. Rueda       ³ Data ³09.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³         REGISTRO ANALITICO DO DOCUMENTO (MODELO 02)        ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao do Registro C390                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoes contidas no array   ³±±
±±³          ³ aRegC170(Itens) aglutinados CFOP, CST e ALIQ.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3(1:N) Para cada Registro C350                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aRegC170  -> Informacoes dos Itens do documento fiscal      ³±±
±±³          ³cAliasSFT -> Alias da tabela posicionada no momento         ³±±
±±³          ³aRegC390  -> Array contendo as informacoes aglutinadas do   ³±±
±±³          ³ do documento fiscal para posterior geracao na funcao prin- ³±±
±±³          ³ cipal.                                                     |±±
±±³          ³cSituaDoc -> Situacao do documento fiscal                   |±± 
±±³          ³aLanCDA - array com os lancamentos do documento fiscal      ³±±
±±³          ³nRedBSICM -> Valor de reducao da base de calculo do ICMS    |±±
±±³          ³cAliasSF4-> Informa qual o alias da tabela SF4, podendo ser ³±±
±±³          ³            query                                           ³±±
±±³          ³aLancFis-> Array com lancamentos de documento nao amarrados³±±
±±³          ³            ao C197                                         ³±±
±±³          ³aReg0460  -> Array com a estrutura do 0460 gerado ateh o    ³±±
±±³          ³            momento.                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegC390(aRegC170,cAliasSFT,aRegC390,cSituaDoc,aLanCDA,nRedBSICM,cAliasSF4,aLancFis,aReg0460)
Local	lRet   		:=	.T.
Local	nPos		:=	0

If (nPos := aScan (aRegC390, {|aX| aX[2]==aRegC170[1][10] .And. aX[3]==aRegC170[1][11] .And. aX[4]==aRegC170[1][14]}) ) == 0
	aAdd(aRegC390, {})
	nPos	:=	Len (aRegC390)
	aAdd (aRegC390[nPos], "C390")	 	   		 				//01 - REG
	aAdd (aRegC390[nPos], aRegC170[1][10])		 				//02 - CST
	aAdd (aRegC390[nPos], aRegC170[1][11])						//03 - CFOP
	aAdd (aRegC390[nPos], aRegC170[1][14])						//04 - ALIQ_ICMS
	aAdd (aRegC390[nPos], 0)	 		   						//05 - VL_OPR
	aAdd (aRegC390[nPos], 0)					   				//06 - VL_BC_ICMS
	aAdd (aRegC390[nPos], 0)	 		  		 				//07 - VL_ICMS
	aAdd (aRegC390[nPos], 0)	 		  		 				//08 - VL_RED_BC
	aAdd (aRegC390[nPos], "")	 				 				//09 - CODOBS
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se houver lancamento fiscal nao amarrado ao C197, devo prioriza-lo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aLancFis)>=1
		aRegC390[nPos,9]	:=	aLancFis[1,1]
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REGISTRO 0460 - TABELA DE OBSERVACOES DO LANCAMENTO FISCAL      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   		Reg0460(@aReg0460,{aLancFis[1,1],aLancFis[1,2]})
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quando este array estiver com conteudo, jah terah de todos os itens,³
	//³ neste caso, preciso obter somente o lancamento do referido item    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf Len(aLanCDA)>0 .And. (nPosIt := aScan(aLanCDA,{|aX|aX[14]==(cAliasSFT)->FT_ITEM}))>0
		aRegC390[nPos,9]  :=  aLanCDA[nPosIt,7]
	EndIf     
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campos totalizados    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !(cSituaDoc$"02#03#04#05")    
	aRegC390[nPos][5] 	+= (cAliasSFT)->FT_VALCONT 		 		//05 - VL_OPR
	aRegC390[nPos][6]	+=	aRegC170[1][13]		 				//06 - VL_BC_ICMS
	aRegC390[nPos][7]	+=	aRegC170[1][15]	   					//07 - VL_ICMS
	aRegC390[nPos][8]	+=	nRedBSICM							//08 - VL_RED_BC
Endif

Return (lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RegC400   ³ Autor ³ Vendas e CRM          ³ Data ³ 29/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a carga dos dados dos registros C400                ³±±
±±³          ³ REGISTRO C400 - EQUIPAMENTO ECF                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/		
Static Function RegC400(	aRegC400, cIMPFISC, cSERPDV, cPDV,;
					nPos400 )

Local lRet   	:= .T.
Local nPos		:= 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Preenchimento do registro C400                            ³
	//³Validacao para nao repetir ECF com o mesmo numero de serie³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aRegC400) == 0 .OR. (Ascan(aRegC400, {|x| x[4] == cSERPDV}) == 0)
		aAdd(aRegC400, {})
		nPos :=	Len (aRegC400)
		
		aAdd (aRegC400[nPos], "C400"					)	 	//00 - REG
		aAdd (aRegC400[nPos], "2D"						)	 	//02 - COD_MOD
		aAdd (aRegC400[nPos], Left(cIMPFISC,20)			)	 	//03 - ECF_MOD
		aAdd (aRegC400[nPos], cSERPDV					)	 	//04 - ECF_FAB
		aAdd (aRegC400[nPos], Right(cPDV,3)				)	 	//05 - ECF_CX 
	Else
		nPos := Ascan(aRegC400, {|x| x[4] == cSERPDV})
	EndIf 

	nPos400 := nPos

Return(lRet) 
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RegC405   ³ Autor ³ Vendas e CRM          ³ Data ³ 29/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a carga dos dados dos registros C405                ³±±
±±³			 ³ REGISTRO C405 - REDUCAO Z                                  ³±±         
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/		
Static Function RegC405(	aRegC405 	, nRegPai , dDtMovto	, cCRO		,;
					cNUMREDZ 	, cNUMFIM , nGTFINAL	, nVALCON	,;
					nPos405 	, nValDesc, nValCanc )

Local lRet   	:= .T.
Local nPos		:= 0
Local nNumFim	:= 0   

DEFAULT nValDesc := 0
DEFAULT nValCanc := 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Preenchimento do registro 405³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aRegC405, {})
	nPos :=	Len (aRegC405) 
	
	aAdd (aRegC405[nPos], nRegPai		)		//00 - RELACIONAMENTO COM O CABECALHO C625
	aAdd (aRegC405[nPos], "C405"		) 	   	//01 - REG
	aAdd (aRegC405[nPos], dDtMovto		)	 	//02 - DT_DOC
	aAdd (aRegC405[nPos], cCRO   		) 	   	//03 - CRO
	aAdd (aRegC405[nPos], cNUMREDZ		)	 	//04 - CRZ

	nNumFim := Val(cNUMFIM)+1
	aAdd (aRegC405[nPos], StrZero(nNumFim,Len(AllTrim(Str(nNumFim))))) 	   	//05 - NUM_COO_FIN
	aAdd (aRegC405[nPos], nGTFINAL		)	 	//06 - GT_FIN
	aAdd (aRegC405[nPos], nVALCON+nValDesc+nValCanc ) 	//07 - VL_BRT

	nPos405 := nPos         

Return lRet
                   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RegC410   ³ Autor ³ Vendas e CRM          ³ Data ³ 29/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a carga dos dados dos registros C410                ³±±
±±³          ³ REGISTRO C410 - PIS E COFINS TOTALIZADOS NO DIA            ³±±     
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/		
Static Function RegC410(	aRegC410	, nRegPai , nTotCof 		, nTotPis ,;
					dDtMovim	, cPDV    , lUsaQuery )

Local lRet   	:= .T.
Local nPos		:= 0
Local aAreaLoc	:= {}
Local aAreaSF2	:= {}

DEFAULT nTotPis	:= 0
DEFAULT nTotCof	:= 0
DEFAULT dDtMovim:= CToD("  /  /  ")
DEFAULT cPDV    := ""

If !lUsaQuery .AND. (nTotPis + nTotCof) = 0
	aAreaLoc	:= GetArea()
	aAreaSF2	:= SF2->(GetArea())
	DbSelectArea ("SF2")
	DbSetOrder (3) //F2_FILIAL + F2_ECF + DTOS(F2_EMISSAO) + F2_PDV + F2_SERIE+F2_MAPA+F2_DOC
	MsSeek (xFilial("SF2") + "S" + DtoS(dDtMovim) + cPDV, .T.)
	
	Do While !SF2->(Eof ()) .AND. SF2->F2_ECF == 'S' .AND.;
			dDtMovim == SF2->F2_EMISSAO .AND. cPDV == SF2->F2_PDV  
			
		nTotPis += SF2->F2_VALPIS	  		//02 - VL_PIS
		nTotCof += SF2->F2_VALCOFI  		//03 - VL_COFINS

		SF2->(dbSkip())
	EndDo
	
	RestArea(aAreaLoc) 
	RestArea(aAreaSF2)
EndIf

If nTotPis > 0 .OR. nTotCof > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Preenchimento do registro 410     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd (aRegC410, {})
	nPos := Len(aRegC410)    
	
	aAdd (aRegC410[nPos], nRegPai) 	//posicao do registro pai para gerar relacionamento
	aAdd (aRegC410[nPos], "C410")
	aAdd (aRegC410[nPos], nTotPis)	//02 - VL_PIS
	aAdd (aRegC410[nPos], nTotCof) 	//03 - VL_COFINS			
EndIf	

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RegC420   ³ Autor ³ Vendas e CRM          ³ Data ³ 29/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a carga dos dados dos registros C420                ³±±
±±³          ³ REGISTRO C420 - TOTALIZADORES PARCIAIS DA REDUCAO Z        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RegC420 (	aRegC420, 	nRegPai, cCRO, cNUMREDZ,;
					aTotaliz, 	aPos420 )

Local lRet	:= .T.
Local nPos	:= 0
Local nI	:= 0

aPos420	 := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenchimento do registro 420     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
For nI:=1 to Len(aTotaliz) 

	aAdd(aRegC420, {})
	nPos := Len (aRegC420)
	
	aAdd (aRegC420[nPos], nRegPai			)	//00 - RELACIONA COM O REGISTRO PAI
	aAdd (aRegC420[nPos], "C420"			)  	//01 - REG

	aAdd (aRegC420[nPos], aTotaliz[nI][1]	)  	//02 - COD_TOT_PAR		
	aAdd (aRegC420[nPos], aTotaliz[nI][2]	)	//03 - VLR_ACUM_TOT

	aAdd (aRegC420[nPos], aTotaliz[nI][3]	)  	//04 - NR_TOT
	aAdd (aRegC420[nPos], ""				)	//05 - DESCR_NR_TOT	  
	
	aAdd (aPos420, { nPos , aTotaliz[nI][1]})	// Posicao do registro + codigo da tributacao
	
Next nI      

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RegC425   ³ Autor ³ Vendas e CRM          ³ Data ³ 29/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a carga dos dados dos registros C425                ³±±
±±³          ³ REGISTRO C425 - RESUMO DE ITENS DO MOVIMENTO DIARIO        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/		
Static Function RegC425(	aRegC425 , aProdB1	, dDtMovim	, cPdv		,;
						aLinhaPai, cAlias	, aReg0200,	aReg0190,;
						aReg0220 , lGer490	, lCstPis , lCstCof	,;
						aRegC490 , nPos405  , dDataDe , dDataAte,;
						aWizard  , nQuantD 	, lUsaQuery )

Local lRet 		:= .F.   				// Retorno Logico
Local nPosAux	:= 0					// Posicao Auxiliar
Local nPos		:= 0     				// Posicao atual
Local aAreaLoc	:= GetArea()  			// Guarda a area local
Local aAreaSFT	:= SFT->(GetArea ())    // Guarda a Area do SFT
Local aAreaSD2	:= SD2->(GetArea ())    // Guarda a Area do SD2
Local aAreaSF2	:= SF2->(GetArea ())	// Guarda a Area do SF2
Local nX		:= 0                    // Contador do For
Local cSitTrib 	:= ""					// Retorno da situação tributaria do produto
Local cSitSFT 	:= ""					// Retorno da situação tributaria do produto
Local cAliqIcm	:= ""					// Aliquota de ICMS
Local cTemp		:= GetNextAlias()		// Pega o proximo Alias Disponivel
//Local aClasFis	:= {"","","",""}		// Array com a classificacao fiscal do produto
//Local nAliqSft	:= 0					// Aliquota de ICMS 
//Local nBCIcms	:= 0					// Base de calculo do ICMS
Local nPosLin	:= 0					// Posicao da Linha do registro pai
Local cFilB1	:= xFilial("SB1")     	// Filial do SB1
Local cProd		:= ""
Local cUnid		:= ""
Local aProd 	:= {"","","","","","","","","","",""}

DEFAULT aLinhaPai 	:= {}  
DEFAULT lGer490		:= .F.
DEFAULT aRegC490	:= {}
DEFAULT nPos405		:= 0		
DEFAULT dDataDe 	:= dDtMovim
DEFAULT dDataAte	:= dDtMovim
DEFAULT aWizard		:= {}

If lUsaQuery
	lGer490 := .T.
	BeginSql alias cTemp
	SELECT SFT.FT_PRODUTO ,
       SUM(FT_VALICM) FT_VALICM , SUM(FT_VALCONT) FT_VALCONT , SUM(FT_VALPIS) FT_VALPIS , 
       SUM(FT_VALCOF) FT_VALCOF ,SUM(FT_QUANT) FT_QUANT      , SUM(FT_BASEICM) FT_BASEICM,
       SD2.D2_SITTRIB
				
		FROM %table:SFT% SFT  , %table:SD2% SD2 
		WHERE   SFT.FT_FILIAL   = %xfilial:SFT%  		AND
				SFT.FT_TIPOMOV  = 'S'   				AND
				SFT.FT_ENTRADA  = %exp:DTOS(dDtMovim)% AND
				SFT.FT_PDV      = %exp:cPdv%			AND 
				SFT.FT_ESPECIE	= 'CF'					AND
				SFT.FT_DTCANC	= ' '					AND
                SFT.%notDel%       						AND
   				SFT.FT_FILIAL   = SD2.D2_FILIAL   		AND 
			    SFT.FT_PDV      = SD2.D2_PDV     		AND 
			    SFT.FT_NFISCAL	= SD2.D2_DOC        	AND
                SFT.FT_SERIE	= SD2.D2_SERIE			AND	
                SFT.FT_ITEM 	= SD2.D2_ITEM			AND
   				SD2.%notDel%
   				                        
   	     GROUP BY FT_PRODUTO,FT_FILIAL,FT_TIPOMOV,SD2.D2_SITTRIB        	 
         ORDER BY FT_FILIAL       
	EndSql
    
	While !(cTemp)->(Eof ())
		cSitTrib := (cTemp)->D2_SITTRIB
	   	nPosLin 	:= Ascan(aLinhaPai,{|x| AllTrim(x[2]) == AllTrim(cSitTrib) })
		
		If nPosLin > 0 
			cProd	:= (cTemp)->FT_PRODUTO+Iif(lConcFil,cFilB1,"")
			If aExistBloc[05]
				aProd := Execblock("SPEDPROD", .F., .F., {cTemp,"C425"})
				If Len(aProd)>=11
					cProd 	:= 	aProd[1]
				Else
					aProd := {"","","","","","","","","","","",""}
				EndIf
			EndIf			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Preenchimento do registro 425    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		  		aAdd(aRegC425, {})        
				nPos :=	Len (aRegC425)
		
				aAdd (aRegC425[nPos], aLinhaPai[nPosLin][1]						) 	//00 - POSICAO DO REG. PAI
				aAdd (aRegC425[nPos], "C425"		 								) 	//01 - REG
				aAdd (aRegC425[nPos], cProd							       	    	) 	//02 - COD_ITEM
				aAdd (aRegC425[nPos], {(cTemp)->FT_QUANT , nQuantD }           	) 	//03 - QTD
				aAdd (aRegC425[nPos], RetUMProd(@aProdB1,(cTemp)->FT_PRODUTO)[1]	)  	//04 - UNID
				aAdd (aRegC425[nPos], (cTemp)->FT_VALCONT 							)	//05 - VL_ITEM  	
				aAdd (aRegC425[nPos], Iif("1"$aWizard[1][15],(cTemp)->FT_VALPIS,0))  	//06 - VL_PIS
				aAdd (aRegC425[nPos], Iif("1"$aWizard[1][15],(cTemp)->FT_VALCOF,0)) 	//07 - VL_COFINS 
		
				
			If aScan (aReg0200, {|aX| aX[2]==cProd}) == 0
				SFRG0200(cAlias, @aReg0200, @aReg0190, dDataDe, dDataAte, ,cProd ,@aReg0220,,,,,,,,,,,,,,,,,,,aWizard)
			EndIf
	
			lRet := .T.
		EndIf
		
		(cTemp)->(dbSkip())
	End
	
	DbSelectArea(cTemp)
	(cTemp)->(DbCloseArea())
Else
	For nX:=1 to Len(aLinhaPai) 
		DbSelectArea("SFT")
		DbSetOrder(2)   //FT_FILIAL+FT_TIPOMOV+DTOS(FT_ENTRADA)+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
		MsSeek(xFilial("SFT")+"S"+DtoS(dDtMovim), .T.)
			
		While !SFT->(Eof ()) .AND. xFilial("SFT") == SFT->FT_FILIAL .AND.;
			SFT->FT_TIPOMOV == "S" .AND. dDtMovim = SFT->FT_EMISSAO 
		
			If cPdv == SFT->FT_PDV .AND. (AllTrim(SFT->FT_ESPECIE)$"CF|NF") .AND. Empty(SFT->FT_DTCANC)   
	
				DbSelectArea("SD2")			         
				DbSetOrder(3)		// D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
				If MsSeek(xFilial("SD2")+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA+SFT->FT_PRODUTO+AllTrim(SFT->FT_ITEM))
			        
			        cSitTrib 	    := LjSitTrib("SD2")    // Verifica a situacao tributaria
			        
			        If cSitTrib $ aLinhaPai[nX][2] .AND. cSitTrib <> "N"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³No caso de Tributado , tem que ser da mesma aliquota ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		        
				        If "T" $ cSitTrib 
				        	cAliqIcm:=AllTrim(Str(SFT->FT_ALIQICM))
					        cSitSFT := StrTran(cAliqIcm,".","") 
					        If Len(cSitSFT) == 1 .OR. Len(SubStr(cAliqIcm,1,At(".",cAliqIcm)-1)) == 1
								cSitSFT := "0"+cSitSFT
					        EndIf
					        cSitSFT := PadR( cSitSFT ,4,"0")
					        If cSitSFT <> SubStr(aLinhaPai[nX][2],2,5)
			        			SFT->(DbSkip())
			        			Loop
			        		EndIf	
			            EndIf	
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Preenchimento do registro 425    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cProd	:= SFT->FT_PRODUTO+Iif(lConcFil,xFilial("SB1"),"") 
						If aExistBloc[05]
							aProd := Execblock("SPEDPROD", .F., .F., {"SFT","C425"})
							If Len(aProd)>=11
								cProd 	:= 	aProd[1]
								cUnid	:=	aProd[5]
							Else
								aProd := {"","","","","","","","","","","",""}
							EndIf
						EndIf
						
						nPosAux := Ascan(aRegC425, {|x| x[3] == cProd .AND. x[1] == aLinhaPai[nX][1]})
										
						If nPosAux ==  0			
							aAdd(aRegC425, {})        
							nPos :=	Len (aRegC425)
				
							aAdd (aRegC425[nPos], aLinhaPai[nX][1]						)	 	   	//00 - POSICAO DO REG. PAI
							aAdd (aRegC425[nPos], "C425"		 						)	 	   	//01 - REG
							aAdd (aRegC425[nPos], cProd		)	 	   								//02 - COD_ITEM
							aAdd (aRegC425[nPos], {SFT->FT_QUANT, nQuantD }			)	 	   	//03 - QTD
							aAdd (aRegC425[nPos], RetUMProd(@aProdB1, SFT->FT_PRODUTO)	)	 	   	//04 - UNID
							aAdd (aRegC425[nPos], SFT->FT_VALCONT 						)			//05 - VL_ITEM  	
							aAdd (aRegC425[nPos], Iif("1"$aWizard[1][15],SFT->FT_VALPIS,0)	)	 	//06 - VL_PIS
							aAdd (aRegC425[nPos], Iif("1"$aWizard[1][15],SFT->FT_VALCOF,0)	)	 	//07 - VL_COFINS 
						Else 
							aRegC425[nPosAux][4][1] += SFT->FT_QUANT			   						//03 - QTD			
							aRegC425[nPosAux][6]    += SFT->FT_VALCONT 								//05 - VL_ITEM
							If ("1"$aWizard[1][15] .And. SFT->FT_VALPIS > 0)
								aRegC425[nPosAux][7] += SFT->FT_VALPIS		//06 - VL_PIS
							Else
								aRegC425[nPosAux][7] := ""					//06 - VL_PIS
							EndIf
	
							If ("1"$aWizard[1][15] .And. SFT->FT_VALCOF > 0)
									aRegC425[nPosAux][8] += SFT->FT_VALCOF		//07 - VL_COFINS
							Else
									aRegC425[nPosAux][8] := ""					//07 - VL_COFINS
							EndIf							 	   	//07 - VL_COFINS 
						EndIf
						
						If aScan (aReg0200, {|aX| aX[2]==SFT->FT_PRODUTO+xFilial("SB1")}) == 0
							SFRG0200(cAlias, @aReg0200, @aReg0190, dDataDe, dDataAte, , ,@aReg0220,,,,,,,,,,,,,,,,,,,aWizard)
						EndIf
			
						lRet := .T.
					EndIf
				EndIf		
			EndIf
			SFT->(dbSkip())
		End
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Preenchimento do registro 425  para o caso de Nao Tributado ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If "N" $ aLinhaPai[nX][2]
			LjNaoTrib(aLinhaPai[nX] , dDtMovim 	, cPdv 		, @aProdB1 ,;
						cAlias 		, @aReg0200	, @aReg0190	, @aReg0220,;
						@aRegC425 	, dDataDe   , dDataAte  , aWizard)
		EndIf	
			
	Next nX
EndIf	
	
RestArea(aAreaLoc)
RestArea(aAreaSFT)	
RestArea(aAreaSD2)
RestArea(aAreaSF2)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RegC460470³ Autor ³ Vendas e CRM          ³ Data ³ 29/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a carga dos dados dos registros C460 e C470         ³±±
±±³          ³ REGISTRO C460 - DOCUMENTO FISCAL EMITIDO POR ECF           ³±±
±±³          ³ REGISTRO C470 - ITENS DO DOCUMENTO FISCAL EMITIDO POR ECF  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/		
Static Function RegC460470(	aRegC460, aRegC470	, dDtMovim	, cPdv		,;
							aProdB1	, cCOO		, nLinhaPai	, cAlias	,;
							aReg0200, aReg0190	, lCstPis	, lCstCof	,;
							aReg0220, lGer490	, aRegC490  , dDataDe   ,;
							dDataAte, aWizard  	, nQuantD 	, lUsaQuery )

Local lRet 		:= .T.   
Local nPosAux	:= 0
Local nPos460	:= 0
Local nPosPai	:= 0     
Local aAreaLoc	:= GetArea()
Local aClasFis	:= {"","","",""}
Local cSituaDoc	:= ""
Local aAreaSFT	:= SFT->(GetArea ())
Local cFilSB1   := xFilial("SB1")
Local nQtCanc  	:= 0
Local cSFTTemp	:= GetNextAlias()			// Pega o proximo Alias Disponivel
Local cProdUN	:= ""
Local nAliqSft	:= 0
//Local nALIQRed	:= 0
Local nBCIcms	:= 0
Local cCpoQry	:= "%"
Local cProdSft	:= ""
Local aDadosProd:= {}
Local cSitTrib	:= ""
Local lCancSft  := .T.
Local aInfPart  := {"","","","",""}
Local cCpfCNPJ	:= ""
Local cProd		:= ""
Local aProd		:= {}

DEFAULT dDataDe := dDtMovim
DEFAULT dDataAte := dDtMovim
DEFAULT aWizard	 := {}

If lUsaQuery
	lGer490 := .T.
	If lCstPis
		cCpoQry += ", SFT.FT_CSTPIS "
	EndIf
	If lCstCof
		cCpoQry += ", SFT.FT_CSTCOF "
	EndIf
	cCpoQry += ", SFT.FT_RGESPST "
	cCpoQry	+= "%"
	
	BeginSql alias cSFTTemp
		SELECT 	SFT.FT_NFISCAL 	, SFT.FT_EMISSAO , SFT.FT_VALCONT, SFT.FT_VALPIS  , SFT.FT_VALCOF  	,
		 		SFT.FT_VALCONT 	, SFT.FT_QUANT 	 , SFT.FT_ITEM	 , SFT.FT_PRODUTO , SFT.FT_PRCUNIT 	,
		 		SFT.FT_CFOP 	, SFT.FT_ALIQICM , SFT.FT_LOJA	 , SFT.FT_CLIEFOR , SFT.FT_TIPO		,
		 		SFT.FT_CLASFIS  , SFT.FT_CTIPI 	 , SFT.FT_TIPOMOV, SFT.FT_DTCANC  , SFT.FT_BASEICM  ,
		 		SFT.FT_VALICM 	, SFT.FT_FORMUL	 , SFT.FT_ESPECIE, SFT.FT_SERIE	  , SD2.D2_SITTRIB	,
		 		SFT.FT_ENTRADA  ,

		 		(SELECT SUM(LX_QTDE) 
		 		 FROM  %table:SLX% SLX 
		 		 WHERE 	SLX.LX_FILIAL 	= SFT.FT_FILIAL  AND 
		 		 		SLX.LX_PDV 		= SFT.FT_PDV 	 AND
		 		 		SLX.LX_CUPOM 	= SFT.FT_NFISCAL AND 
		 		 		SLX.LX_SERIE 	= SFT.FT_SERIE 	 AND
		 		 		SLX.LX_DTMOVTO	= SFT.FT_EMISSAO AND
		 		 		SLX.LX_PRODUTO  = SFT.FT_PRODUTO AND 
		 		 		SLX.LX_ITEM		= SFT.FT_ITEM    AND
					  SLX.%notDel% ) AS LX_QTDCANC                                                                         
				%Exp:cCpoQry%
                                                               
		FROM %table:SFT% SFT LEFT JOIN %table:SD2% SD2 ON 
				SD2.D2_FILIAL = %xfilial:SD2%	AND 
				SFT.FT_PDV      = SD2.D2_PDV	AND 
				SFT.FT_NFISCAL	= SD2.D2_DOC	AND
        	    SFT.FT_SERIE    = SD2.D2_SERIE	AND     
                SFT.FT_ITEM     = SD2.D2_ITEM	AND
                SD2.%notDel%                
                
		WHERE   SFT.FT_FILIAL   = %xfilial:SFT%			AND
				SFT.FT_TIPOMOV  = 'S'					AND
				SFT.FT_ENTRADA  = %exp:DTOS(dDtMovim)%  AND
				SFT.FT_PDV      = %exp:cPdv%			AND 
				SFT.FT_ESPECIE	= 'CF'					AND
				SFT.%notDel%
	EndSql
	
	While !(cSFTTemp)->(Eof ())
	
		nPosAux := Ascan(aRegC460, {|x| x[5] == (cSFTTemp)->FT_NFISCAL .AND. x[1] == nLinhaPai})  //SFT->FT_NFISCAL
		lCancSft := Empty(AllTrim((cSFTTemp)->FT_DTCANC))	
			
		If nPosAux ==  0			
			If SA1->(MsSeek(xFilial("SA1") + (cSFTTemp)->FT_CLIEFOR + (cSFTTemp)->FT_LOJA)) 
				aInfPart := InfPartDoc("SA1")
				cCpfCNPJ := IIf(Empty(aInfPart[4]),aInfPart[5],aInfPart[4])
				If LJAnalisaLEG(58)[1] 				// Para a Nota Fiscal Gaucha pega os dados do cupom
					DbSelectArea("SL1")
					DbSetOrder(2) 					//L1_FILIAL + L1_SERIE + L1_DOC 
					If MsSeek(xFilial("SL1")+(cSFTTemp)->FT_SERIE+(cSFTTemp)->FT_NFISCAL) 
						cCpfCNPJ := AllTrim(SL1->L1_CGCCLI)
					EndIf
				EndIf
			EndIf			

			SPEDSeek("SF3",,xFilial("SF3")+(cSFTTemp)->(FT_ENTRADA+FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_CFOP+STR(FT_ALIQICM,5,2)))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Preenchimento do registro 460  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSituaDoc := SPEDSitDoc(,cSFTTemp)
			
			aAdd(aRegC460, {})        
			nPos460 :=	Len (aRegC460)      
			
			aAdd (aRegC460[nPos460], nLinhaPai		 				)	 	   	//00 - RELACIONAMENT0 COM REGISTRO PAI
			aAdd (aRegC460[nPos460], "C460"		 					)	 	   	//01 - REG
			aAdd (aRegC460[nPos460], "2D"		 					)	 	   	//02 - COD_MOD
			aAdd (aRegC460[nPos460], cSituaDoc						)	 	   	//03 - COD_SIT
			aAdd (aRegC460[nPos460], (cSFTTemp)->FT_NFISCAL			)	 	   	//04 - NUM_DOC
			If lCancSft
				aAdd (aRegC460[nPos460], StoD((cSFTTemp)->FT_EMISSAO)	)	 	//05 - DT_DOC
				aAdd (aRegC460[nPos460], (cSFTTemp)->FT_VALCONT		    ) 	    //06 - VL_DOC
				aAdd (aRegC460[nPos460], Iif("1"$aWizard[1][15] .And. (cSFTTemp)->FT_VALPIS>0,(cSFTTemp)->FT_VALPIS,""))	 			 //07 - VL_PIS
				aAdd (aRegC460[nPos460], Iif("1"$aWizard[1][15] .And. (cSFTTemp)->FT_VALCOF>0,(cSFTTemp)->FT_VALCOF,""))	 			 //08 - VL_COFINS
				aAdd (aRegC460[nPos460], cCpfCNPJ						)		//09 - CPF_CNPJ
				aAdd (aRegC460[nPos460], aInfPart[2]					)	   		     //10 - NOM_ADQ
			Else 
				aAdd (aRegC460[nPos460], ""  	)	 	   	//05 - DT_DOC
				aAdd (aRegC460[nPos460], ""		) 	     	//06 - VL_DOC
				aAdd (aRegC460[nPos460], ""		)	 	   	//07 - VL_PIS
				aAdd (aRegC460[nPos460], ""		)	 	   	//08 - VL_COFINS
				aAdd (aRegC460[nPos460], ""	    )	 	   	//09 - CPF_CNPJ
				aAdd (aRegC460[nPos460], ""  	)	 	   	//10 - NOM_ADQ 	
			EndIf
		Else 
			If lCancSft
				aRegC460[nPosAux][7] += (cSFTTemp)->FT_VALCONT					//05 - VL_DOC
				aRegC460[nPosAux][8] += Iif("1"$aWizard[1][15],(cSFTTemp)->FT_VALPIS,0)				 	//06 - VL_PIS
				If ("1"$aWizard[1][15] .And. (cSFTTemp)->FT_VALCOF > 0)
					aRegC460[nPosAux][9] += (cSFTTemp)->FT_VALCOF		//07 - VL_COFINS
				Else
					aRegC460[nPosAux][9] := ""							//07 - VL_COFINS
				EndIf
			EndIf
		EndIf

		nQtCanc  := (cSFTTemp)->LX_QTDCANC
		cProdSft := (cSFTTemp)->FT_PRODUTO
				
		cSitTrib :=	(cSFTTemp)->D2_SITTRIB		
		If ("T" $ cSitTrib)
			If Len(cSitTrib) > 4
				nAliqSft := Val(SubStr(cSitTrib,2,2)+"."+SubStr(cSitTrib,4,Len(cSitTrib)))
			Else
				nAliqSft := Val(SubStr(cSitTrib,2,Len(cSitTrib)))
			EndIf		
			nBCIcms	 := (cSFTTemp)->FT_VALCONT		
		ElseIf ("S" $ cSitTrib)
			nAliqSft := 0
			nBCIcms	 :=	0
		Else 
			nAliqSft := (cSFTTemp)->FT_ALIQICM	
			nBCIcms	 :=	(cSFTTemp)->FT_BASEICM
		EndIf

		nPosPai  := If(nPosAux == 0, nPos460, nPosAux)
		If lCancSft
			
			aDadosProd	:= RetUMProd(@aProdB1, cProdSft)
			cProdUN		:= aDadosProd[1]
			
			aClasFis := SPDRetCCST (cSFTTemp,.F.,lCstPis,lCstCof)
			cProd	:= SB1->B1_COD + Iif(lConcFil,cFilSB1,"")
			If aExistBloc[05]
				aProd := Execblock("SPEDPROD", .F., .F., {"SB1","C470"})
				If Len(aProd)>=11
					cProd 	:= 	aProd[1]
				Else
					aProd := {"","","","","","","","","","","",""}
				EndIf
			EndIf			
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Preenchimento do registro 470  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			RegC470 (@aRegC470			, cProd			, (cSFTTemp)->FT_QUANT	, (cSFTTemp)->FT_VALCONT,;
					 (cSFTTemp)->FT_CFOP, nAliqSft				, (cSFTTemp)->FT_VALPIS	, (cSFTTemp)->FT_VALCOF ,;
					 aClasFis[1]		, nQtCanc				, @aProdB1				, nPosPai		 		,;
					 cFilSB1			, cProdUN				, aWizard  				, nQuantD)
					 
			If AScan(aReg0200, {|aX| aX[2]==cProd}) == 0
				SFRG0200(cAlias, @aReg0200, @aReg0190, dDataDe, dDataAte, , cProd, @aReg0220,,,,,,,,,,,,,,,,,,,aWizard)
			EndIf	
		EndIf	
		(cSFTTemp)->(dbSkip())
	End	   
	
	DbSelectArea(cSFTTemp)
	(cSFTTemp)->( DbCloseArea())
Else

	DbSelectArea("SFT")
	DbSetOrder(2)   //FT_FILIAL+FT_TIPOMOV+DTOS(FT_ENTRADA)+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
	MsSeek(xFilial("SFT")+"S"+DtoS(dDtMovim), .T.)
	
	While !SFT->(Eof ()) .AND. xFilial("SFT") == SFT->FT_FILIAL .AND. SFT->FT_TIPOMOV == "S" .AND. dDtMovim = SFT->FT_EMISSAO
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Somente para cupom e que nao tenha sido cancelado ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPdv == SFT->FT_PDV .AND. (AllTrim(SFT->FT_ESPECIE)$"CF|NF") .AND. Empty(SFT->FT_DTCANC)

			nPosAux := Ascan(aRegC460, {|x| x[5] == SFT->FT_NFISCAL .AND. x[1] == nLinhaPai})
			
			If nPosAux ==  0			
				If SA1->(MsSeek(xFilial("SA1") + SFT->FT_CLIEFOR + SFT->FT_LOJA)) 
					aInfPart := InfPartDoc("SA1")
				EndIf			

				SPEDSeek("SF3",,xFilial("SF3")+SFT->(DtoS(FT_ENTRADA)+FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_CFOP+STR(FT_ALIQICM,5,2)))
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Preenchimento do registro 460  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				cSituaDoc := SPEDSitDoc(,"SFT")
				
				aAdd(aRegC460, {})        
				nPos460 :=	Len (aRegC460)      
				
				aAdd (aRegC460[nPos460], nLinhaPai		 			)	 	   			 //00 - RELACIONAMENT0 COM REGISTRO PAI
				aAdd (aRegC460[nPos460], "C460"		 				)	 	   			 //01 - REG
				aAdd (aRegC460[nPos460], "2D"		 				)	 	   	         //02 - COD_MOD
				aAdd (aRegC460[nPos460], cSituaDoc					)	 	   	         //03 - COD_SIT
				aAdd (aRegC460[nPos460], SFT->FT_NFISCAL			)	 	   	         //04 - NUM_DOC
				aAdd (aRegC460[nPos460], SFT->FT_EMISSAO			)	 	   	         //05 - DT_DOC
				aAdd (aRegC460[nPos460], SFT->FT_VALCONT			)	 	   	         //06 - VL_DOC
				aAdd (aRegC460[nPos460], Iif("1"$aWizard[1][15],SFT->FT_VALPIS,0))	 	   	         //07 - VL_PIS
				aAdd (aRegC460[nPos460], Iif("1"$aWizard[1][15],SFT->FT_VALCOF,0))	 	   	         //08 - VL_COFINS
				aAdd (aRegC460[nPos460], IIf(Empty(aInfPart[4]),aInfPart[5],aInfPart[4]))//09 - CPF_CNPJ
				aAdd (aRegC460[nPos460], aInfPart[2]				)	 	   	         //10 - NOM_ADQ
			Else 
				aRegC460[nPosAux][7] += SFT->FT_VALCONT					 	   	//05 - VL_DOC
				aRegC460[nPosAux][8] += Iif("1"$aWizard[1][15],SFT->FT_VALPIS,0)//06 - VL_PIS
				If ("1"$aWizard[1][15] .And. (cSFTTemp)->FT_VALCOF > 0)
					aRegC460[nPosAux][9] += (cSFTTemp)->FT_VALCOF						//07 - VL_COFINS
				Else
					aRegC460[nPosAux][9] := ""											//07 - VL_COFINS
				EndIf
			EndIf
			       
			aClasFis := SPDRetCCST ("SFT",.F.,lCstPis,lCstCof) 
			
			cProdSft    := SFT->FT_PRODUTO
		    aDadosProd	:= RetUMProd(@aProdB1, cProdSft)
		    cProdUN		:= aDadosProd[1]
						
			nQtCanc := QtdeCanc(SFT->FT_PDV, SFT->FT_NFISCAL, SFT->FT_SERIE, SFT->FT_EMISSAO)   
			
			nPosPai := If(nPosAux == 0, nPos460, nPosAux)
			
			cProd	:= SB1->B1_COD+ Iif(lConcFil,xFilial("SB1"),"") 
			If aExistBloc[05]
				aProd := Execblock("SPEDPROD", .F., .F., {"SB1","C470"})
				If Len(aProd)>=11
					cProd 	:= 	aProd[1]
				Else
					aProd := {"","","","","","","","","","","",""}
				EndIf
			EndIf			
						
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Preenchimento do registro 470  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			RegC470 (@aRegC470   , 	cProd 			, SFT->FT_QUANT ,	SFT->FT_VALCONT,;
					 SFT->FT_CFOP, 	SFT->FT_ALIQICM             , SFT->FT_VALPIS,	SFT->FT_VALCOF ,;
					 aClasFis[1] , 	nQtCanc                     , @aProdB1      ,	nPosPai        ,;
					 cFilSB1	 , cProdUN						, aWizard 		, 	nQuantD) 
					 
			If aScan (aReg0200, {|aX| aX[2]==cProd}) == 0
				SFRG0200(cAlias, @aReg0200, @aReg0190, dDataDe, dDataAte,,cProd, @aReg0220,,,,,,,,,,,,,,,,,,,aWizard)
			EndIf
		EndIf     
		
		SFT->(dbSkip())
	End  
EndIf

RestArea(aAreaLoc)	
RestArea(aAreaSFT)

Return(lRet)


/*
³Fun‡…o    ³RegC470   ³ Autor ³ Vendas e CRM          ³ Data ³ 29/01/09 ³

³Descri‡…o ³ Efetua a carga dos dados dos registros C470                ³
³          ³ REGISTRO C470 - ITENS DO DOCUMENTO FISCAL EMITIDO POR ECF  ³

³ Uso      ³ SIGAFIS                                                    ³
*/		
Static Function RegC470(	aRegC470	, cProduto	, nQUANT	, nValCont		,;
					cCFOP		, nALIQICM	, nVALPIS	, nVALCOF		,; 
					cCST		, nQtCanc	, aProdB1	, nLinhaPai 	,;
					cFilSB1 	, cProdUN 	, aWizard 	, nQuantD )

Local lRet 		:= .T.   
Local nPosAux	:= 0
Local nPos470	:= 0    

Default aWizard := {}
Default nQuantD   := Min(TAMSX3("FT_QUANT")[2],3)

	nPosAux := Ascan(aRegC470, {|x| x[3] == cProduto .AND. x[8] == cCST .AND. x[1] == nLinhaPai})

	If nPosAux == 0 		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Preenchimento do registro 470  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		      
		aAdd(aRegC470, {})        
		nPos470 :=	Len (aRegC470)                  
		
		aAdd (aRegC470[nPos470], nLinhaPai		       )		//00 - RELACIONAMENTO COM REGISTRO PAI
		aAdd (aRegC470[nPos470], "C470"			       )	 	//01 - REG
		aAdd (aRegC470[nPos470], cProduto        	   )	 	//02 - COD_ITEM
		aAdd (aRegC470[nPos470], {nQUANT+nQtCanc , nQuantD }   )	 	//03 - QTD
		aAdd (aRegC470[nPos470], nQtCanc	           )	 	//04 - QTD_CANC
		aAdd (aRegC470[nPos470], cProdUN		       )		//05 - UNID         
		aAdd (aRegC470[nPos470], nValCont  		       )	 	//06 - VL_ITEM     
		aAdd (aRegC470[nPos470], cCST			       )	 	//07 - CST_ITEM
		aAdd (aRegC470[nPos470], cCFOP			       )	 	//08 - CFOP
		aAdd (aRegC470[nPos470], nALIQICM		       )	   	//09 - ALIQ_ICMS
		aAdd (aRegC470[nPos470], Iif("1"$aWizard[1][15],Iif(nVALPIS>0,nVALPIS,""),""))	   	//10 - VL_PIS
		aAdd (aRegC470[nPos470], Iif("1"$aWizard[1][15],Iif(nVALCOF>0,nVALCOF,""),""))	    //11 - VL_COFINS
	Else
		aRegC470[nPosAux][4][1]  += nQUANT	+ nQtCanc   			//03 - QTD		   		   
		aRegC470[nPosAux][7]  += nValCont		 	   			//06 - VL_ITEM     
		aRegC470[nPosAux][5]  += nQtCanc			 		   	//04 - QTD_CANC
		If ("1"$aWizard[1][15] .And. nVALPIS > 0)
			aRegC470[nPosAux][11] += nVALPIS	//10 - VL_PIS
		Else
			aRegC470[nPosAux][11] := ""			//10 - VL_PIS
		EndIf
	
		If ("1"$aWizard[1][15] .And. nVALCOF > 0)
			aRegC470[nPosAux][12] += nVALCOF	//11 - VL_COFINS
		Else
			aRegC470[nPosAux][12] := ""			//11 - VL_COFINS
		EndIf
	EndIf
	

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RegC490   ³ Autor ³ Vendas e CRM          ³ Data ³ 29/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a carga dos dados dos registros C490                ³±±
±±³          ³ REGISTRO C490 - REGISTRO ANALITICO DO MOVIMENTO DIARIO     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/		
Static Function RegC490(aRegC490	, dDtMovim	, nLinhaPai	, lCstPis	,;
						 lCstCof	, cPdv		, aProdB1	, nPos405	,;
						 aReg0200	, cAlias    , AREG0190	,AREG0220	,;
						 nValCof	, nValPis	)

Local lRet 		:= .T.
Local nPosAux   := 0
Local aAreaLoc	:= GetArea()
Local aClasFis	:=	{"","","",""}   
Local aAreaSFT	:=	SFT->(GetArea ())
Local nALIQRed	:= 0
Local nALIQICM	:= 0
Local nBCIcms	:= 0
//Local cCpoQry	:= "%"					// String para acrescentar mais campos na query	
Local lUsaQuery := .F.  
Local cTemp1     := GetNextAlias()		// Pega o proximo Alias Disponivel
Local nAliqSFT  := 0
//Local cFilB1	:= xFilial("SB1")     	// Filial do SB1
Local aAuxReg   := {}
Local nValIcm	:= 0					// Valor do ICM

Default lCstPis  := .F.
Default lCstCof  := .F.       
Default aReg0200 := {}
Default cAlias   := ""
Default AREG0190 := {}
Default AREG0220 := {}
Default nValCof	 := 0
Default nValPis	 := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se utiliza Query³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP
	If TcSrvType() <> "AS/400"
		lUsaQuery 	:= .T.		
	Endif
#ENDIF

If lUsaQuery
	
	BeginSql alias cTemp1
		SELECT 	SUM(FT_VALICM) FT_VALICM,SUM(FT_VALCONT) FT_VALCONT,SUM(FT_VALPIS) FT_VALPIS,SUM(FT_VALCOF) FT_VALCOF,SUM(FT_QUANT) FT_QUANT,
				SUM(FT_BASEICM) FT_BASEICM,FT_FILIAL,FT_CLASFIS,FT_CFOP,FT_ALIQICM,D2_SITTRIB, FT_CTIPI,FT_CSTPIS,FT_CSTCOF, FT_TIPO
		FROM %table:SFT% SFT  , %table:SD2% SD2 
		WHERE   SFT.FT_FILIAL   = %xfilial:SFT%  		AND
				SFT.FT_TIPOMOV  = 'S'   				AND
				SFT.FT_ENTRADA  = %exp:DTOS(dDtMovim)%  AND
				SFT.FT_PDV      = %exp:cPdv%			AND 
				SFT.FT_ESPECIE	= 'CF'					AND
				SFT.FT_DTCANC	= ' '					AND
                SFT.%notDel%       						AND
                SFT.FT_FILIAL   = SD2.D2_FILIAL   		AND 
			    SFT.FT_PDV      = SD2.D2_PDV     		AND 
			    SFT.FT_NFISCAL	= SD2.D2_DOC        	AND
                SFT.FT_SERIE	= SD2.D2_SERIE			AND	
                SFT.FT_ITEM 	= SD2.D2_ITEM			AND
   				SD2.%notDel%
		GROUP BY FT_FILIAL,FT_CLASFIS,FT_CFOP,FT_ALIQICM,D2_SITTRIB,FT_CTIPI,FT_CSTPIS,FT_CSTCOF,FT_TIPO
        ORDER BY FT_FILIAL,FT_CFOP,FT_CLASFIS,FT_ALIQICM
	EndSql
    
	While !(cTemp1)->(Eof ())
		cSitTrib := (cTemp1)->D2_SITTRIB	
		lRet := .T.		
		
		If ("T" $ cSitTrib)
			If Len(cSitTrib) > 4
				nAliqSft := Val(SubStr(cSitTrib,2,2)+"."+SubStr(cSitTrib,4,Len(cSitTrib)))
			Else
				nAliqSft := Val(SubStr(cSitTrib,2,Len(cSitTrib)))
			EndIf		
			nBCIcms	 := (cTemp1)->FT_VALCONT		   
			nValIcm	 := (cTemp1)->FT_VALICM
		ElseIf ("S" $ cSitTrib)
			nAliqSft := 0
			nBCIcms	 :=	0
			nValIcm	 := 0
		Else
			nAliqSft := (cTemp1)->FT_ALIQICM	
			nBCIcms	 :=	(cTemp1)->FT_BASEICM
			nValIcm	 := (cTemp1)->FT_VALICM			
		EndIf	
		
		aClasFis := SPDRetCCST (cTemp1,.F.,lCstPis,lCstCof)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Guarda os valores de PIS e Confins para 490 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	     
		nValCof += (cTemp1)->FT_VALCOF
		nValPis += (cTemp1)->FT_VALPIS
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Foi criado o array aAuxReg para que nao seja necessario dar o Ascan o array aReg490, ³
		//³ pois estava ocasionando uma lentidao no sistema pelo tamanho. 						³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	   		  
	    nPosAux := Ascan(aAuxReg, {|x| x[1] == nPos405 .AND. x[3] == aClasFis[1] .AND.  x[4] == (cTemp1)->FT_CFOP .AND. x[5] == nAliqSft })   
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Preenchimento do registro C490 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	     	    
	    If nPosAux ==  0   
			aAdd(aRegC490, {})        
			nPos :=	Len (aRegC490)
			
			aAdd (aRegC490[nPos], nPos405		 		)	  	//00 - RELACIONAMENTO COM O REGISTRO PAI
			aAdd (aRegC490[nPos], "C490"		 		) 	   	//01 - REG
			aAdd (aRegC490[nPos], aClasFis[1]			)	   	//02 - CST_ITEM
			aAdd (aRegC490[nPos], (cTemp1)->FT_CFOP	)	   	//03 - CFOP
			aAdd (aRegC490[nPos], nAliqSft				)	   	//04 - ALIQ_ICMS
			aAdd (aRegC490[nPos], (cTemp1)->FT_VALCONT	)	   	//05 - VL_OPR
			aAdd (aRegC490[nPos], nBCIcms				)	   	//06 - VL_BC_ICMS
			aAdd (aRegC490[nPos], nValIcm				)	   	//07 - VL_ICMS
			aAdd (aRegC490[nPos], ""					)		//08 - COD_OBS
			nPos490 := nPos
			aAdd(aAuxReg, {})
			nPos :=	Len (aAuxReg)   
			aAdd (aAuxReg[nPos], nPos405		 		)	  	//01 - RELACIONAMENTO COM O REGISTRO PAI
			aAdd (aAuxReg[nPos], "C490"		 	   		) 	   	//02 - REG
			aAdd (aAuxReg[nPos], aClasFis[1]			)	   	//03 - CST_ITEM
			aAdd (aAuxReg[nPos], (cTemp1)->FT_CFOP		)	   	//04 - CFOP
			aAdd (aAuxReg[nPos], nAliqSft				)	   	//05 - ALIQ_ICMS    
			aAdd (aAuxReg[nPos], nPos490				)	   	//06 - Posicao do ARegC490    
			
		Else 
			nPos490 := AauxReg[nPosAux][6]			
			aRegC490[nPos490][6] += (cTemp1)->FT_VALCONT		 	//05 - VL_OPR
			aRegC490[nPos490][7] += nBCIcms					   		//06 - VL_BC_ICMS
			aRegC490[nPos490][8] += (cTemp1)->FT_VALICM			 	//07 - VL_ICMS
		EndIf	
							
		(cTemp1)->(dbSkip())
	End
	
	DbSelectArea(cTemp1)
	(cTemp1)->(DbCloseArea())   

Else

	DbSelectArea("SFT")
	DbSetOrder(2)   //FT_FILIAL+FT_TIPOMOV+DTOS(FT_ENTRADA)+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
	MsSeek(xFilial("SFT")+"S"+DtoS(dDtMovim), .T.)
	
		While !SFT->(Eof ()) .And. xFilial("SFT") == SFT->FT_FILIAL .AND. SFT->FT_TIPOMOV == "S" .And.; 
			dDtMovim = SFT->FT_EMISSAO
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Somente para cupom e que nao tenha sido cancelado ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(SFT->FT_PDV) .AND. Empty(SFT->FT_DTCANC) .AND. AllTrim(cPdv) == AllTrim(SFT->FT_PDV) .AND. SFT->FT_TIPO <> "S"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Preenchimento do registro 490 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aClasFis := SPDRetCCST ("SFT",.F.,lCstPis,lCstCof)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Preenchimento do registro 470  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
				nALIQRed:= RetUMProd(aProdB1, SFT->FT_PRODUTO)[2]
				If nALIQRed > 0
					nALIQICM := nALIQRed
					nBCIcms	 := SFT->FT_VALCONT
				Else 
					nALIQICM := SFT->FT_ALIQICM	
					nBCIcms	 :=	SFT->FT_BASEICM
				EndIf	
				      
				//Guarda os valores de PIS e Confins para 490      
				nValCof += SFT->FT_VALCOF
				nValPis += SFT->FT_VALPIS  
				
				nPosAux := Ascan(aRegC490, {|x| x[1] == nLinhaPai .AND. x[3] == aClasFis[1] .AND.  x[4] == SFT->FT_CFOP .AND. x[5] == nALIQICM })
				
				If nPosAux ==  0			
					aAdd(aRegC490, {})        
					nPos :=	Len (aRegC490)
					
					aAdd (aRegC490[nPos], nLinhaPai		 		)	 	   	//00 - RELACIONAMENTO COM O REGISTRO PAI
					aAdd (aRegC490[nPos], "C490"		 		)	 	   	//01 - REG
					aAdd (aRegC490[nPos], aClasFis[1]			)	 	   	//02 - CST_ITEM
					aAdd (aRegC490[nPos], SFT->FT_CFOP			)	 	   	//03 - CFOP
					aAdd (aRegC490[nPos], nALIQICM				)	 	   	//04 - ALIQ_ICMS
					aAdd (aRegC490[nPos], SFT->FT_VALCONT		)	 	   	//05 - VL_OPR
					aAdd (aRegC490[nPos], nBCIcms				)	 	   	//06 - VL_BC_ICMS
					aAdd (aRegC490[nPos], SFT->FT_VALICM		)	 	   	//07 - VL_ICMS
					aAdd (aRegC490[nPos], ""					)			//08 - COD_OBS
				Else 
					aRegC490[nPosAux][6] += SFT->FT_VALCONT				 	//05 - VL_OPR
					aRegC490[nPosAux][7] += nBCIcms			 				//06 - VL_BC_ICMS
					aRegC490[nPosAux][8] += SFT->FT_VALICM				 	//07 - VL_ICMS
				EndIf
			EndIf
			
			SFT->(dbSkip())
		End  

EndIf
RestArea(aAreaLoc)	 
RestArea(aAreaSFT)		

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RegC495   ³ Autor ³ Vendas e CRM                 ³ Data ³ 29/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a carga dos dados dos registros C495                       ³±±
±±³          ³ REGISTRO C495 - RESUMO MENSAL DE ITENS DO ECF POR ESTABELECIMENTO ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/		
Static Function RegC495( 	aRegC495, aProdB1		, nRegPai 	, dDataIni	,;
					dDataFim, cPdv	 		, aReg0200	, cAlias	,;
					aReg0190, aReg0220	, aSLX 	  	, cFilB1, aWizard )

Local lRet 		:= .T.
Local nPosAux   := 0
Local aAreaLoc	:= GetArea()   
Local nPosSlx	:= 0 
Local aAreaSFT	:=	SFT->(GetArea ())
Local nALIQRed	:= 0
Local nALIQICM	:= 0
Local nBCIcms	:= 0
Local cProd		:= ""
Local aProd		:= {}
Local lMVC495TRI	:=	aSPDSX6[MV_C495TRI]

DbSelectArea("SLX")
SLX->(DbSetOrder(2)) //DTMOVTO + PDV

If Len(aSLX) == 0
	If MsSeek(xFilial("SLX")+ DtoS(dDataIni), .T.)
		While !SLX->(Eof ()) .AND. SLX->LX_DTMOVTO <= dDataFim
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Preenchimento do registro 470  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			nALIQRed:= RetUMProd(aProdB1, SLX->LX_PRODUTO)[2]
			If nALIQRed > 0 .AND. lMVC495TRI
				nALIQICM := nALIQRed
			Else 
				nALIQICM := SLX->LX_ALIQICM	
			EndIf	
			
			nPosAux	:= Ascan(aSLX, {|x| x[1] == SLX->LX_PRODUTO .AND. x[2] == nALIQICM})
			
			If nPosAux == 0		
				aAdd(aSLX, {})        
				nPosSlx :=	Len (aSLX)           
				
				aAdd (aSLX[nPosSlx], SLX->LX_PRODUTO+cFilB1	)	 	
				aAdd (aSLX[nPosSlx], nALIQICM		)
				aAdd (aSLX[nPosSlx], SLX->LX_QTDE	)	   	
				aAdd (aSLX[nPosSlx], SLX->LX_VALOR	)	   	
			Else 
				aSLX[nPosAux][3] += SLX->LX_QTDE
				aSLX[nPosAux][4] += SLX->LX_VALOR
			EndIf
						
			SLX->(dbSkip())
		End
	EndIf
EndIf

DbSelectArea("SFT")
DbSetOrder(2)   //FT_FILIAL+FT_TIPOMOV+DTOS(FT_ENTRADA)+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
MsSeek(xFilial("SFT")+"S"+DtoS(dDataIni), .T.)
	
	While !SFT->(Eof ()) .AND. xFilial("SFT") == SFT->FT_FILIAL .AND. SFT->FT_TIPOMOV == "S" .AND. SFT->FT_EMISSAO >= dDataIni;
			.AND. SFT->FT_EMISSAO <= dDataFim
			
		If AllTrim(SFT->FT_PDV) == AllTrim(cPdv) .AND. Empty(SFT->FT_DTCANC) .AND. SFT->FT_TIPO <> "S"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Preenchimento do registro 470  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			nALIQRed:= RetUMProd(aProdB1, SFT->FT_PRODUTO)[2]
			If nALIQRed > 0 .AND. lMVC495TRI
				nALIQICM := nALIQRed
				nBCIcms	 := SFT->FT_VALCONT
			Else 
				nALIQICM := SFT->FT_ALIQICM	
				nBCIcms	 :=	SFT->FT_BASEICM	
			EndIf	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Preenchimento do registro 495 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cProd	:= SFT->FT_PRODUTO+Iif(lConcFil,cFilB1,"")
			If aExistBloc[05]
				aProd := Execblock("SPEDPROD", .F., .F., {"SFT","C495"})
				If Len(aProd)>=11
					cProd 	:= 	aProd[1]
				Else
					aProd := {"","","","","","","","","","","",""}
				EndIf
			EndIf			
			
			nPosAux := Ascan(aRegC495, {|x| x[4] == cProd})
			
			nPosSlx	:= Ascan(aSLX, {|x| x[1] == cProd .AND. x[2] == nALIQICM })
					
			If nPosAux ==  0			
				aAdd(aRegC495, {})        
				nPos :=	Len (aRegC495)
	
				aAdd (aRegC495[nPos], nRegPai		 						)	 	//00 - RELACIONAMENTO COM O REGISTRO PAI
				aAdd (aRegC495[nPos], "C495"		 						)	   	//01 - REG
				aAdd (aRegC495[nPos], nALIQICM								)	   	//02 - ALIQ_ICMS
				aAdd (aRegC495[nPos], cProd									)	   	//03 - COD_ITEM
				aAdd (aRegC495[nPos], SFT->FT_QUANT							) 	   	//04 - QTD
	            
				If nPosSlx > 0 
					aAdd (aRegC495[nPos], aSLX[nPosSlx][3]					)	   	//05 - QTD_CANC			
				Else
					aAdd (aRegC495[nPos], 0									)	   	//05 - QTD_CANC
				EndIf
				
				aAdd (aRegC495[nPos], RetUMProd(@aProdB1, SFT->FT_PRODUTO)[1])		//06 - UNID      
				aAdd (aRegC495[nPos], SFT->FT_PRCUNIT						) 	   	//07 - VL_ITEM
				aAdd (aRegC495[nPos], SFT->FT_DESCONT						)	   	//08 - VL_DESC 
				
				If nPosSlx > 0 
					aAdd (aRegC495[nPos], aSLX[nPosSlx][4]					)	   	//09 - VL_CANC 			
				Else
					aAdd (aRegC495[nPos], 0									)	   	//09 - VL_CANC 
				EndIf
				
				aAdd (aRegC495[nPos], SFT->FT_DESPESA						) 	   	//10 - VL_ACMO
				aAdd (aRegC495[nPos], nBCIcms								) 	   	//11 - VL_BC_ICMS
				aAdd (aRegC495[nPos], SFT->FT_VALICM						)	   	//12 - VL_ICMS
				aAdd (aRegC495[nPos], SFT->FT_ISENICM						) 	   	//13 - VL_ISEN
				aAdd (aRegC495[nPos], 0										)	   	//14 - VL_NT
				aAdd (aRegC495[nPos], SFT->FT_ICMSRET						) 	   	//15 - VL_ICMS_ST

				SB1->(DbSetOrder(1))
				SB1->(MsSeek(cFilB1+SFT->FT_PRODUTO))

				//Gera Registro 0200
				If AScan(aReg0200, {|aX| aX[2]==cProd}) == 0
					SFRG0200(cAlias, @aReg0200, @aReg0190, dDataIni, dDataFim, ,cProd , @aReg0220,,,,,,,,,,,,,,,,,,,aWizard)
				EndIf
			Else 
				aRegC495[nPosAux][5]  += SFT->FT_QUANT								//04 - QTD
				
				If nPosSlx > 0 
					aRegC495[nPosAux][6] += aSLX[nPosSlx][3]					   	//05 - QTD_CANC			
				EndIf
	
				aRegC495[nPosAux][8]  += SFT->FT_PRCUNIT		 	   				//07 - VL_ITEM
				aRegC495[nPosAux][9]  += SFT->FT_DESCONT		 	  			 	//08 - VL_DESC 
				
				If nPosSlx > 0 
					aRegC495[nPosAux][10] += aSLX[nPosSlx][3]					   	//09 - VL_CANC 
				EndIf
				
				aRegC495[nPosAux][11] += SFT->FT_DESPESA		 	  			 	//10 - VL_ACMO
				aRegC495[nPosAux][12] += nBCIcms				 	  			 	//11 - VL_BC_ICMS
				aRegC495[nPosAux][13] += SFT->FT_VALICM		 	  		  		 	//12 - VL_ICMS
				aRegC495[nPosAux][14] += SFT->FT_ISENICM		 	 			  	//13 - VL_ISEN
				aRegC495[nPosAux][15] += 0											//14 - VL_NT
				aRegC495[nPosAux][16] += SFT->FT_ICMSRET		 	 			  	//15 - VL_ICMS_ST
			EndIf
		EndIf
		SFT->(dbSkip())
	End
	
RestArea(aAreaLoc)    
RestArea(aAreaSFT)

Return(lRet)
/*
±±³Programa  ³RegC500   ³ Autor ³Gustavo G. Rueda       ³ Data ³09.03.2011³±±

±±³Descri‡…o ³                                                            ³±±
±±³          ³     NOTA FISCAL CONTA DE ENERGIA ELETRICA (MODELO 06)      ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro C500                       ³±±

±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoe contidas no array    ³±±
±±³          ³ aRegC100 para o Modelo 06.                                 ³±±

±±³Nivel Hier³2(varios por arquivo)                                       ³±±

±±³Retorno   ³.T.                                                         ³±±

±±³Parametros³cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          ³nRelac -> Flag de relacionamento com os sub-registros       ³±±
±±³          |aRegC100 -> Informacoes sobre todos documentos fiscais pro- ³±±
±±³          ³ cessados no while da funcao principal.                     ³±±
±±³          ³aTotaliza -> Totalizadores de valores para a tabela SFT.    ³±±
±±³          ³aRegC500 -> Conteudo gravado do registro C500 para utiliza- ³±±
±±³          ³ cao em outros registros da funcao principal.               ³±±
±±³          ³nItem -> Contador do item para cada documento fiscal.       ³±±
±±³          ³lAchouSFU -> Flag de localizacao do SFU para o NF em proces-³±±
±±³          ³ samento.                                                   ³±±
±±³          ³lAchouCD3 -> Flag de localizacao do CD3 para o NF em proces-³±±
±±³          ³ samento.                                                   ³±±
±±³          ³lGravaC500-> Flag de gravacao do registro conforme regras   ³±±
±±³          ³ anteriores de processamento                                ³±±
±±³          ³lGrava0150-> Flag de gravacao do registro conforme regras   ³±±
±±³          ³ anteriores de processamento                                ³±±
±±³          ³aCmpAntSFT-> Campos da tabela SFT por documento fiscal      ³±±
±±³          ³lAchouCD4 -> Flag de localizacao do CD4 para o NF em proces-³±±
±±³          ³ samento.                                                   ³±±
±±³          ³aInfCompl -> Array com as informacoes complementares do     ³±±
±±³          ³cAliasCD4 -> Alias da tabela CD4 baseado em SELECT ou Ind-  |±±
±±³          ³             regua                                          |±±
*/
Static Function RegC500(cAlias,nRelac,aRegC100,aTotaliza,aRegC500,nItem,lAchouSFU,lAchouCD3,lGravaC500,lGrava0150,aCmpAntSFT,lAchouCD4,aInfCompl,cAliasCD4,aWizard)
Local	lRet   		:=	.T.
Local	nPos		:=	0
Local	cCodCons	:= ""
Local	nVlTerc  	:=	0
Local   cTpLiga     := ""
Local   cGrpTens    := ""
Local 	nVlFornec	:= 0
Default aWizard		:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para energia eletrica³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aRegC100[1][5] == "06" .And. lAchouSFU
	cCodCons 	:= SFU->FU_CLASCON
	nVlTerc  	:= SFU->FU_VALTERC
	nVlFornec	:= SFU->FU_VLFORN
	cGrpTens 	:= SFU->FU_GRUPT
	cTpLiga		:= SFU->FU_TIPLIGA	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para Gas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf aRegC100[1][5] == "28" .And. lAchouCD3
	cCodCons := CD3->CD3_CLASCO
	nVlTerc  := CD3->CD3_VLTERC

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para Agua canalizada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf aRegC100[1][5] == "29" .And. lAchouCD4
	cCodCons := (cAliasCD4)->CD4_CLASCO
	nVlTerc  := (cAliasCD4)->CD4_VLTERC

EndIf

aAdd(aRegC500, {})
nPos	:=	Len (aRegC500)
aAdd (aRegC500[nPos], "C500")	 	   										//01 - REG
aAdd (aRegC500[nPos], aRegC100[1][2])	   			  						//02 - IND_OPER
aAdd (aRegC500[nPos], aRegC100[1][3])	   			  						//03 - IND_EMIT
aAdd (aRegC500[nPos], aRegC100[1][4])	   			  						//04 - COD_PART
aAdd (aRegC500[nPos], aRegC100[1][5])	   			  						//05 - COD_MOD
aAdd (aRegC500[nPos], aRegC100[1][6])	   			   						//06 - COD_SIT
aAdd (aRegC500[nPos], aRegC100[1][7])	   									//07 - SER
aAdd (aRegC500[nPos], "")	   						   						//08 - SUB
aAdd (aRegC500[nPos], cCodCons )					   						//09 - COD_CONS
aAdd (aRegC500[nPos], aRegC100[1][8])	   			   						//10 - NUM_DOC
aAdd (aRegC500[nPos], aCmpAntSFT[6])	   			   						//11 - DT_DOC
aAdd (aRegC500[nPos], aRegC100[1][11])	   									//12 - DT_E_S
aAdd (aRegC500[nPos], aRegC100[1][12])										//13 - VL_DOC  
aAdd (aRegC500[nPos], aRegC100[1][14])	   				   					//14 - VL_DESC
aAdd (aRegC500[nPos], IIF(nVlFornec>0,nVlFornec,aRegC100[1][16]))			//15 - VL_FORN
aAdd (aRegC500[nPos], IIF(!(aRegC100[1][6]$"02#04#05"),aTotaliza[7],""))	//16 - VL_SERV_NT
aAdd (aRegC500[nPos], IIF(!(aRegC100[1][6]$"02#04#05"),nVlTerc,""))		//17 - VL_TERC
aAdd (aRegC500[nPos], aRegC100[1][20])	   				  					//18 - VL_DA
aAdd (aRegC500[nPos], aRegC100[1][21])	   									//19 - VL_BC_ICMS
aAdd (aRegC500[nPos], aRegC100[1][22])	   									//20 - VL_ICMS
aAdd (aRegC500[nPos], aRegC100[1][23])				   						//21 - VL_BC_ICMS_ST
aAdd (aRegC500[nPos], aRegC100[1][24])	   									//22 - VL_ICMS_ST
aAdd (aRegC500[nPos], aInfCompl[1])										//23 - COD_INF
aAdd (aRegC500[nPos], Iif("1"$aWizard[1][15],aRegC100[1][26],""))	   									//24 - VL_PIS
aAdd (aRegC500[nPos], Iif("1"$aWizard[1][15],aRegC100[1][27],""))	   									//25 - VL_COFINS
If cVersao >= "003"
	aAdd (aRegC500[nPos], cTpLiga)  		   								//26 - TP_LIGACAO - LAYOUT 2010
	aAdd (aRegC500[nPos], cGrpTens)											//27 - COD_GRUPO_TENSAO - LAYOUT 2010
EndIf

If lGravaC500
	GrvRegTrS(cAlias,nRelac,aRegC500,nItem)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³No registro C100, quando este campo estiver em branco, eh pq nao deve       ³
	//³ ser enviado o codigo do participante, assim nao precisa gerar tambem o 0150³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aRegC100[1][4])
		lGrava0150 := .T.
	EndIf
EndIf

Return (lRet)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC510   ³ Autor ³Gustavo G. Rueda       ³ Data ³09.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³               ITENS DO DOCUMENTO (MODELO 06)               ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro C510                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoe contidas no array    ³±±
±±³          ³ aRegC170 para o Modelo 06.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3(1:N) Para cada C500                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias     -> Alias do TRB que recebera as informacoes      ³±±
±±³          ³nRelac     -> Flag de relacionamento com os sub-registros   ³±±
±±³          |aRegC170   -> Informacoes sobre os itens dos documentos     ³±±
±±³          ³              fiscais processados no while da funcao prin-  ³±±
±±³          ³              cipal.                                        ³±±
±±³          ³aPartDoc   -> Array com informacoes sobre o participante do ³±±
±±³          ³ 				documento fiscal, este array eh montado pela  ³±±
±±³          ³ 				funcao principal                              ³±±
±±³          ³aRegC510   -> Conteudo gravado do registro C510 para utili- ³±±
±±³          ³              zacao em outros registros da funcao principal.³±±
±±³          ³nItem      -> Contador do item para cada documento fiscal.  ³±±
±±³          ³lAchouSFU  -> Flag de seek da tabela SFU                    ³±±
±±³          ³lGravaC500 -> Flag para determinar se deverah gravar o C500 ³±±
±±³          ³lGrava0150 -> Flag para determinar se deverah gravar o 0150 ³±±
±±³          ³cSituaDoc  -> Status do documento fiscal.                   ³±±
±±³          ³lGrava0200 -> Flag para determinar se deverah gravar o 0200 ³±±
±±³          ³cEntSai    -> Identifica ENTRADA=1/SAIDA=2.                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegC510(cAlias,nRelac,aRegC170,aPartDoc,aRegC510,nItem,lAchouSFU,lGravaC500,;
	lGrava0150,cSituaDoc,lGrava0200,cEntSai,aWizard)
	
Local	nPos		:=	0
Local	cCodClas	:= ""
Default aWizard		:= {}

If lAchouSFU
	If TamSx3("FU_GRPCLAS")[1] == 2
		cCodClas	:= SFU->FU_GRPCLAS+SFU->FU_CLASSIF
	Else
		cCodClas	:= "0"+SFU->FU_GRPCLAS+SFU->FU_CLASSIF
	EndIf	
EndIf

aAdd(aRegC510, {})
nPos	:=	Len (aRegC510)
aAdd (aRegC510[nPos], "C510")	 	   					//01 - REG
aAdd (aRegC510[nPos], aRegC170[1][2])	   				//02 - NUM_ITEM
aAdd (aRegC510[nPos], aRegC170[1][3])	   				//03 - COD_ITEM
aAdd (aRegC510[nPos], cCodClas)							//04 - COD_CLASS
aAdd (aRegC510[nPos], aRegC170[1][5][1])				//05 - QTD
aAdd (aRegC510[nPos], aRegC170[1][6])	   				//06 - UNID
aAdd (aRegC510[nPos], aRegC170[1][7])	   				//07 - VL_ITEM
aAdd (aRegC510[nPos], aRegC170[1][8])	   				//08 - VL_DESC
aAdd (aRegC510[nPos], aRegC170[1][10])	   				//09 - CST_ICM
aAdd (aRegC510[nPos], aRegC170[1][11])	   				//10 - CFOP
aAdd (aRegC510[nPos], aRegC170[1][13])	   				//11 - VL_BC_ICMS
aAdd (aRegC510[nPos], aRegC170[1][14])	   				//12 - ALIQ_ICMS
aAdd (aRegC510[nPos], aRegC170[1][15])	   				//13 - VL_ICMS
aAdd (aRegC510[nPos], aRegC170[1][16])	   				//14 - VL_BC_ICMS_ST
aAdd (aRegC510[nPos], aRegC170[1][17])	   				//15 - ALIQ_ICMS_ST
aAdd (aRegC510[nPos], aRegC170[1][18])	   				//16 - VL_ICMS_ST
aAdd (aRegC510[nPos], "0")			   					//17 - IND_REC
aAdd (aRegC510[nPos], aPartDoc[1])	   					//18 - COD_PART
aAdd (aRegC510[nPos], Iif("1"$aWizard[1][15],Iif(aRegC170[1][30]>0,aRegC170[1][30],""),""))	   				//19 - VL_PIS
aAdd (aRegC510[nPos], Iif("1"$aWizard[1][15],Iif(aRegC170[1][36]>0,aRegC170[1][36],""),""))	   				//20 - VL_COFINS
aAdd (aRegC510[nPos], aRegC170[1][37])					//21 - COD_CTA

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Segundo manual, para documentos cancelados, somente o registro³
//³ pai deve ser gravado (alguns campos), nao deve gerar nenhum  ³
//| do filhos                                                    |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lGravaC500 .And. !cSituaDoc$"02#04#05#03" .And. cEntSai=="2"
	GrvRegTrS(cAlias,nRelac,{aRegC510[nPos]},nItem)           

	lGrava0200 := .T.

	lGrava0150 := .T.
EndIf
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RegC590   ³ Autor ³Gustavo G. Rueda       ³ Data ³09.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³C590 - REGISTRO ANALITICO DO DOCUMENTO (MODELOS 06, 28 E 29)³±±
±±³          ³                                                            ³±±
±±³          ³- Acumula valores para a gravacao do registro E105 junto com³±±
±±³          ³ a gravacao do registro E100.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoe contidas na tabela   ³±±
±±³          ³ SFT.                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³E760 - 3(1:N) Para cada E700                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAliasSFT-> Alias da tabela SFT aberta no momento.          ³±±
±±³          ³aRegC590 -> Array com as informacoes acumuladas             ³±±
±±³          ³cSituaDoc-> Situação do documento                           ³±±
±±³          ³aClasFis -> Codigo da Situação Tributaria                   ³±±
±±³          ³aRegC170 -> Array com as informacoes jah processadas        ³±±
±±³          ³aLanCDA - array com os lancamentos do documento fiscal      ³±±
±±³          ³nRedBSICM -> Valor de reducao da base de calculo do ICMS    |±±
±±³          ³cAliasSF4-> Informa qual o alias da tabela SF4, podendo ser ³±±
±±³          ³            query                                           ³±±
±±³          ³aLancFis-> Array com lancamentos de documento nao amarrados³±±
±±³          ³            ao C197                                         ³±±
±±³          ³aReg0460  -> Array com a estrutura do 0460 gerado ateh o    ³±±
±±³          ³            momento.                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegC590(cAliasSFT,aRegC590,cSituaDoc,aClasFis,aRegC170,aLanCDA,nRedBSICM,cAliasSF4,aLancFis,aReg0460)
Local	nPos	:=	0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³REGISTRO C590 - REGISTRO ANALITICO DOS DOCUMENTOS (MODELOS 06, 28 E 29)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nPos := aScan(aRegC590,{|aX| aX[2]==aClasFis[1] .And. aX[3]==aRegC170[1][11] .And. aX[4]==aRegC170[1][14]}))==0
	aAdd (aRegC590, {})
	nPos	:=	Len (aRegC590)
	aAdd (aRegC590[nPos], "C590")							//01 - REG
	aAdd (aRegC590[nPos], aClasFis[1])						//02 - CST_ICMS
	aAdd (aRegC590[nPos], aRegC170[1][11])	   	  		   	//03 - CFOP
	aAdd (aRegC590[nPos], aRegC170[1][14])			   		//04 - ALIQ_ICMS
	aAdd (aRegC590[nPos], 0)						   		//05 - VL_OPR
	aAdd (aRegC590[nPos], 0)						   		//06 - VL_BC_ICMS
	aAdd (aRegC590[nPos], 0)						   		//07 - VL_ICMS
	aAdd (aRegC590[nPos], 0)						   		//08 - VL_BC_ICMS_ST
	aAdd (aRegC590[nPos], 0)						   		//09 - VL_ICMS_ST
	aAdd (aRegC590[nPos], 0)						   		//10 - VL_RED_BC
	aAdd (aRegC590[nPos], "")						  		//11 - COD_OBS
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se houver lancamento fiscal nao amarrado ao C197, devo prioriza-lo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aLancFis)>=1
		aRegC590[nPos,11] := aLancFis[1,1]
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REGISTRO 0460 - TABELA DE OBSERVACOES DO LANCAMENTO FISCAL      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   		Reg0460(@aReg0460,{aLancFis[1,1],aLancFis[1,2]})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quando este array estiver com conteudo, jah terah de todos os itens,³
	//³ neste caso, preciso obter somente o lancamento do referido item    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf Len(aLanCDA)>0 .And. (nPosIt := aScan(aLanCDA,{|aX|aX[14]==(cAliasSFT)->FT_ITEM}))>0
		aRegC590[nPos,11] := aLanCDA[nPosIt,7] 			
	EndIf
EndIf

If !cSituaDoc$"02#04#05#03"
	aRegC590[nPos][5]	+=	(cAliasSFT)->FT_VALCONT	 		//05 - VL_OPR
	aRegC590[nPos][6]	+=	aRegC170[1][13]					//06 - VL_BC_ICMS
	aRegC590[nPos][7]	+=	aRegC170[1][15]					//07 - VL_ICMS
	aRegC590[nPos][8]	+=	aRegC170[1][16]					//08 - VL_BC_ICMS_ST
	aRegC590[nPos][9]	+=	aRegC170[1][18]					//09 - VL_ICMS_ST
	aRegC590[nPos][10]	+=	nRedBSICM						//10 - VL_RED_BC
Endif
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC600   ³ Autor ³Gustavo G. Rueda       ³ Data ³10.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³            REGISTRO C600 - CONSOLIDACAO DIARIA:            ³±±
±±³          ³    NOTAS FISCAIS/CONTA DE ENERGIA ELETRICA (MODELO 06),    ³±±
±±³          ³    NOTA FISCAL/CONTA DE FORNECIMENTO D'AGUA CANALIZADA     ³±±
±±³          ³      (CODIGO 29) E NOTA FISCAL/CONTA DE FORNECIMENTO       ³±±
±±³          ³                      DE GAS (CODIGO 28)                    ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao da estrutura do Registro C600                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS no final do processamento da rotina    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³C600 - 2(varios por arquivo)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1    -> Posicao de gravacao do registro C600 para       ³±±
±±³          ³            relacionamento com os registros filhos          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|aRegC500 -> Conteudo gravado do registro C500 para utiliza- ³±±
±±³          ³ cao em outros registros da funcao principal.               ³±±
±±³          ³aPartDoc -> Informacoes sobre o participante do  documentos ³±±
±±³          ³aRegC600 -> Array contendo as informacoes processadas pela  ³±±
±±³          ³ funcao a ser retornado para gravacao pela funcao principal.³±±
±±³          ³lAchouSFU-> Flag do resultado do seek na tabela SFU         ³±±
±±³          ³lAchouCD3-> Flag do resultado do seek na tabela CD3         ³±±
±±³          ³lAchouCD4-> Flag do resultado do seek na tabela CD4         ³±±
±±³          ³cAliasCD4 -> Alias da tabela CD4 baseado em SELECT ou Ind-  |±±
±±³          ³             regua                                          |±±
±±³          ³cSituaDoc-> Situacao do documento                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegC600(aRegC500,aPartDoc,aRegC600,lAchouSFU,lAchouCD3,lAchouCD4,cAliasCD4,cSituaDoc,aWizard)
Local	nPos		:=	0
Local	cCodCons	:=	""
Local	nVlTerc  	:=	0
Local	nConskwh  	:=	0

Default aWizard		:= {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obtendo valores das tabelas complementares³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aRegC500[1][5] == "06" .And. lAchouSFU
	cCodCons := SFU->FU_CLASCON
	nVlTerc  := SFU->FU_VALTERC
	nConskwh := SFU->FU_CONSTOT

ElseIf aRegC500[1][5] == "28" .And. lAchouCD3
	cCodCons := CD3->CD3_CLASCO
	nVlTerc  := CD3->CD3_VLTERC

ElseIf aRegC500[1][5] == "29" .And. lAchouCD4
	cCodCons := (cAliasCD4)->CD4_CLASCO
	nVlTerc  := (cAliasCD4)->CD4_VLTERC
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Para as notas canceladas do modelo 29 (NFFA), existe o tratamento na tabela SF3 para gravar a classe de consumo.			 |
//³Como o complemento foi excluido ao deletar a nota, deve-se pegar o codigo na tabela SF3, pois na CD4 nao ira existir mais.|
//|Tratamento feito para evitar que o C600 seja gerado sem a classe de consumo, o que ocasiona erro no validador.			 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cSituaDoc$"02#04#05#03" .And. Empty(cCodCons) .And. aRegC500[1][5] == "29"
	cCodCons	:=	SF3->F3_CLASCO
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³REGISTRO C600 - CONSOLIDACAO DE NOTAS FISCAIS/CONTA DE ENERGIA ELETRICA (MODELO 06)|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nPos := aScan(aRegC600,{|aX| aX[2]==aRegC500[1][5] .And. aX[3]==aPartDoc[7] .And. aX[6]==cCodCons}))==0
	aAdd(aRegC600, {})
	nPos	:=	Len (aRegC600)
	aAdd (aRegC600[nPos], "C600")	 	 	  					//01 - REG
	aAdd (aRegC600[nPos], aRegC500[1][5]) 	   					//02 - COD_MOD
	aAdd (aRegC600[nPos], aPartDoc[7])	 	   					//03 - COD_MUN
	aAdd (aRegC600[nPos], aRegC500[1][7]) 	   					//04 - SER
	aAdd (aRegC600[nPos], aRegC500[1][8]) 	   					//05 - SUB
	aAdd (aRegC600[nPos], cCodCons) 		   					//06 - COD_CONS
	aAdd (aRegC600[nPos], "0") 	   								//07 - QTD_CONS
	aAdd (aRegC600[nPos], "0") 	   								//08 - QTD_CANC
	aAdd (aRegC600[nPos], aRegC500[1][11])						//09 - DT_DOC
	aAdd (aRegC600[nPos], 0) 	   								//10 - VL_DOC
	aAdd (aRegC600[nPos], 0) 	   								//11 - VL_DESC
	aAdd (aRegC600[nPos], {0,0}) 		   						//12 - CONS
	aAdd (aRegC600[nPos], 0) 	   								//13 - VL_FORN
	aAdd (aRegC600[nPos], 0) 	   								//14 - VL_SERV_NT
	aAdd (aRegC600[nPos], 0) 	   								//15 - VL_TERC
	aAdd (aRegC600[nPos], 0) 	   								//16 - VL_DA
	aAdd (aRegC600[nPos], 0) 	   								//17 - VL_BC_ICMS
	aAdd (aRegC600[nPos], 0) 	   								//18 - VL_ICMS
	aAdd (aRegC600[nPos], 0) 	   								//19 - VL_BC_ICMS_ST
	aAdd (aRegC600[nPos], 0) 	   								//20 - VL_ICMS_ST
	aAdd (aRegC600[nPos], 0) 	   								//21 - VL_PIS
	aAdd (aRegC600[nPos], 0) 	   								//22 - VL_COFINS
EndIf
//
aRegC600[nPos][7]		:=	Alltrim(STR(Val(aRegC600[nPos][7])+1))//07 - QTD_CONS
If !cSituaDoc$"02#04#05#03"
	aRegC600[nPos][10]		+=	aRegC500[1][13]						//10 - VL_DOC
	aRegC600[nPos][11]		+=	aRegC500[1][14]						//11 - VL_DESC
	aRegC600[nPos][12][1]	+=	nConskwh  							//12 - CONS
	aRegC600[nPos][13]		+=	aRegC500[1][15]						//13 - VL_FORN
	aRegC600[nPos][14]		+=	aRegC500[1][16]						//14 - VL_SERV_NT
	aRegC600[nPos][15]		+=	nVlTerc								//15 - VL_TERC
	aRegC600[nPos][16]		+=	aRegC500[1][18]						//16 - VL_DA
	aRegC600[nPos][17]		+=	aRegC500[1][19]						//17 - VL_BC_ICMS
	aRegC600[nPos][18]		+=	aRegC500[1][20]						//18 - VL_ICMS
	aRegC600[nPos][19]		+=	aRegC500[1][21]						//19 - VL_BC_ICMS_ST
	aRegC600[nPos][20]		+=	aRegC500[1][22]						//20 - VL_ICMS_ST
	If("1"$aWizard[1][15] .And. VALTYPE(aRegC500[1][24])=="N")
		aRegC600[nPos][21] 	+= aRegC500[1][24]						//21 - VL_PIS
	Else
		aRegC600[nPos][21]	:= ""										//21 - VL_PIS
	EndIf	
	If ("1"$aWizard[1][15] .And. VALTYPE(aRegC500[1][25])=="N") 
		aRegC600[nPos][22]   += aRegC500[1][25]						//22 - VL_COFINS
	Else
		aRegC600[nPos][22]	:= ""										//22 - VL_COFINS
	EndIf

Endif
Return nPos
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC601   ³ Autor ³Gustavo G. Rueda       ³ Data ³10.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³REGISTRO C601 - DOCUMENTOS CANCELADOS - CONSOLIDACAO DIARIA:³±±
±±³          ³    NOTAS FISCAIS/CONTA DE ENERGIA ELETRICA (MODELO 06),    ³±±
±±³          ³    NOTA FISCAL/CONTA DE FORNECIMENTO D'AGUA CANALIZADA     ³±±
±±³          ³      (CODIGO 29) E NOTA FISCAL/CONTA DE FORNECIMENTO       ³±±
±±³          ³                      DE GAS (CODIGO 28)                    ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao da estrutura do Registro C601                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS no final do processamento da rotina    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³C600 - 2(varios por arquivo)                                ³±±
±±³          ³C601 - 3(1:N) Para cada C600                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|aCmpAntSFT -> Informacoes sobre o cabecalho dos documentos. ³±±
±±³          ³aRegC600 -> Array contendo as informacoes processadas pela  ³±±
±±³          ³ funcao a ser retornado para gravacao pela funcao principal.³±±
±±³          ³aRegC601 -> Array contendo as informacoes processadas pela  ³±±
±±³          ³ funcao a ser retornado para gravacao pela funcao principal.³±±
±±³          ³nPosC600 -> Posicao de gravacao do registro C600 para       ³±±
±±³          ³            relacionamento com os registros filhos          ³±±
±±³          ³aRegC500 -> Conteudo gravado do registro C500 para utiliza- ³±±
±±³          ³ cao em outros registros da funcao principal.               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegC601(aCmpAntSFT,aRegC600,aRegC601,nPosC600,aRegC500)
Local	nPos	:=	0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³REGISTRO C601 - DOCUMENTOS CANCELADOS - CONSOLIDACAO DIARIA DE NOTAS FISCAIS/CONTA |
//|                DE ENERGIA ELETRICA (MODELO 06), NOTA FISCAL/CONTA DE FORNECIMENTO |
//|                D'AGUA CANALIZADA (CODIGO 29) E NOTA FISCAL/CONTA DE FORNECIMENTO  |
//|                DE GAS (CODIGO 28)                                                 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty (aCmpAntSFT[7]) //Documento cancelado		
	If (nPos := aScan(aRegC601,{|aX| aX[1]==nPosC600 .And. aX[3]==aRegC500[1][10]}))==0
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para contagem dos documentos cancelados do registro C600³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRegC600[nPosC600][8]	:=	Alltrim(STR(Val(aRegC600[nPosC600][8])+1))//08 - QTD_CANC

		aAdd(aRegC601, {})
		nPos	:=	Len (aRegC601)
		aAdd (aRegC601[nPos], nPosC600)	 	 	  					//01 - CHAVE RELACIONAMENTO
		aAdd (aRegC601[nPos], "C601")	 	 	  					//01 - REG
		aAdd (aRegC601[nPos], aRegC500[1][10])	 	 	  			//02 - NUM_DOC_CANC
	EndIf
EndIf
Return
/*
±±³Programa  ³RegC610   ³ Autor ³Gustavo G. Rueda       ³ Data ³10.03.2011³±±

±±³Descri‡…o ³                                                            ³±±
±±³          ³    REGISTRO C610 - ITENS DOS DOCUMENTOS CONSOLIDADOS:      ³±±
±±³          ³    NOTAS FISCAIS/CONTA DE ENERGIA ELETRICA (MODELO 06),    ³±±
±±³          ³    NOTA FISCAL/CONTA DE FORNECIMENTO D'AGUA CANALIZADA     ³±±
±±³          ³      (CODIGO 29) E NOTA FISCAL/CONTA DE FORNECIMENTO       ³±±
±±³          ³                      DE GAS (CODIGO 28)                    ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao da estrutura do Registro C610                     ³±±

±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS no final do processamento da rotina    ³±±

±±³Nivel Hier³C600 - 2(varios por arquivo)                                ³±±
±±³          ³C610 - 3(1:N) Para cada C600                                ³±±

±±³Retorno   ³Nil                                                         ³±±

±±³Parametros|aRegC500 -> Conteudo gravado do registro C500 para utiliza- ³±±
±±³          ³ cao em outros registros da funcao principal.               ³±±
±±³          ³aRegC510 -> Conteudo gravado do registro C510 para utiliza- ³±±
±±³          ³ cao em outros registros da funcao principal.               ³±±
±±³          ³lAchouSFU-> Flag do resultado do seek na tabela SFU         ³±±
±±³          ³aRegC610 -> Array contendo as informacoes processadas pela  ³±±
±±³          ³ funcao a ser retornado para gravacao pela funcao principal.³±±
±±³          ³nPosC600 -> Posicao de gravacao do registro C600 para       ³±±
±±³          ³            relacionamento com os registros filhos          ³±±
±±³          ³cSituaDoc-> Situacao do documento                           ³±±
*/
Static Function RegC610(aRegC500,aRegC510,lAchouSFU,aRegC610,nPosC600,cSituaDoc,aWizard)
Local	nI		:=	0
Local	nPos	:=	0
Local	cCodClas	:=	""
Default aWizard	:= {}

If aRegC500[1][5] == "06" .And. lAchouSFU
	If TamSx3("FU_GRPCLAS")[1] == 2
		cCodClas	:= SFU->FU_GRPCLAS+SFU->FU_CLASSIF
	Else
		cCodClas	:= "0"+SFU->FU_GRPCLAS+SFU->FU_CLASSIF
	EndIf
EndIf
//³REGISTRO C610 - ITENS DO DOCUMENTO CONSOLIDADO (MODELO 06)                         ³
For nI := 1 To Len (aRegC510)
	If (nPos := aScan(aRegC610,{|aX| aX[1]==nPosC600 .And. aX[3]==cCodClas .And. aX[4]==aRegC510[nI][3] .And. aX[11]==aRegC510[nI][12]}))==0
		aAdd(aRegC610, {})
		nPos	:=	Len (aRegC610)
		aAdd(aRegC610[nPos], nPosC600)	 	 	  				//01 - CHAVE RELACIONAMENTO
		aAdd(aRegC610[nPos], "C610")	 	 	  				//02 - REG
		aAdd(aRegC610[nPos], cCodClas) 			  				//03 - COD_CLASS
		aAdd(aRegC610[nPos], aRegC510[nI][3]) 	  				//04 - COD_ITEM
		aAdd(aRegC610[nPos], aRegC510[nI][5])					//05 - QTD
		aAdd(aRegC610[nPos], aRegC510[nI][6]) 	  				//06 - UNID
		aAdd(aRegC610[nPos], aRegC510[nI][7]) 	  				//07 - VL_ITEM
		aAdd(aRegC610[nPos], aRegC510[nI][8]) 	  				//08 - VL_DESC
		aAdd(aRegC610[nPos], aRegC510[nI][9]) 	  				//09 - CST
		aAdd(aRegC610[nPos], aRegC510[nI][10]) 	  				//10 - CFOP
		aAdd(aRegC610[nPos], aRegC510[nI][12])	 				//11 - ALIQ_ICMS
		aAdd(aRegC610[nPos], 0)	 	   						  	//12 - VL_BC_ICMS
		aAdd(aRegC610[nPos], 0)		  						  	//13 - VL_ICMS
		aAdd(aRegC610[nPos], 0)	 	 						  	//14 - VL_BC_ICMS_ST
		aAdd(aRegC610[nPos], 0)	   							  	//15 - VL_ICMS_ST
		aAdd(aRegC610[nPos], 0)		 						  	//16 - VL_PIS
		aAdd(aRegC610[nPos], 0)								  	//17 - VL_COFINS
		aAdd(aRegC610[nPos], aRegC510[nI][21])			 	 	//18 - COD_CTA
	
	EndIf
	If !cSituaDoc$"02#04#05#03"
		aRegC610[nPos][12] += aRegC510[nI][11] 		   		  	//12 - VL_BC_ICMS
		aRegC610[nPos][13] += aRegC510[nI][13]		   		  		//13 - VL_ICMS
		aRegC610[nPos][14] += aRegC510[nI][14] 		   		  	//14 - VL_BC_ICMS_ST
		aRegC610[nPos][15] += aRegC510[nI][16]		   		  		//15 - VL_ICMS_ST
		If ("1"$aWizard[1][15] .And. ValType(aRegC610[nPos][16])=="N")
			aRegC610[nPos][16] += Iif(Valtype(aRegC510[nI][19])=="N" .And. aRegC510[nI][19]>0, aRegC510[nI][19],0) 		 
			If(aRegC610[nPos][16]==0) 								//16 - VL_PIS
				aRegC610[nPos][16] :=""								//16 - VL_PIS
			EndIf
		Else
			aRegC610[nPos][16] :=""	//16 - VL_PIS
		EndIF
		
		If ("1"$aWizard[1][15] .And. ValType(aRegC610[nPos][17])=="N")
			aRegC610[nPos][17] += Iif(ValTYpe(aRegC510[nI][20])=="N" .And. aRegC510[nI][20]>0, aRegC510[nI][20],0)
			If (aRegC610[nPos][17]==0)								//17 - VL_COFINS
				aRegC610[nPos][17] :=""								//17 - VL_COFINS	
			EndIf
		Else
			aRegC610[nPos][17] :=""	//17 - VL_COFINS
		EndIf	

	Endif
Next nI
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC690   ³ Autor ³Gustavo G. Rueda       ³ Data ³10.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³    REGISTRO C690 - REGISTRO ANALITICO  DOS DOCUMENTOS:     ³±±
±±³          ³    NOTAS FISCAIS/CONTA DE ENERGIA ELETRICA (MODELO 06),    ³±±
±±³          ³    NOTA FISCAL/CONTA DE FORNECIMENTO D'AGUA CANALIZADA     ³±±
±±³          ³      (CODIGO 29) E NOTA FISCAL/CONTA DE FORNECIMENTO       ³±±
±±³          ³                      DE GAS (CODIGO 28)                    ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao da estrutura do Registro C690                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS no final do processamento da rotina    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³C600 - 2(varios por arquivo)                                ³±±
±±³          ³C690 - 3(1:N) Para cada C600                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|aRegC590 -> Conteudo gravado do registro C590 para utiliza- ³±±
±±³          ³ cao em outros registros da funcao principal.               ³±±
±±³          ³nPosC600 -> Posicao de gravacao do registro C600 para       ³±±
±±³          ³            relacionamento com os registros filhos          ³±±
±±³          ³aRegC690 -> Array contendo as informacoes processadas pela  ³±±
±±³          ³ funcao a ser retornado para gravacao pela funcao principal.³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegC690(aRegC590,nPosC600,aRegC690)
Local	nPos	:=	0
Local	nI		:=	0
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³REGISTRO C690 - ITENS DO DOCUMENTO CONSOLIDADO (MODELO 06)                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len (aRegC590)
	If (nPos := aScan(aRegC690,{|aX| aX[1]==nPosC600 .And. aX[3]==aRegC590[nI][2] .And. aX[4]==aRegC590[nI][3] .And. aX[5]==aRegC590[nI][4]}))==0
		aAdd (aRegC690, {})
		nPos	:=	Len (aRegC690)
		aAdd (aRegC690[nPos], nPosC600)	 	 	  	 			//01 - CHAVE RELACIONAMENTO
		aAdd (aRegC690[nPos], "C690")				 			//02 - REG
		aAdd (aRegC690[nPos], aRegC590[nI][02])		 			//03 - CST_ICMS
		aAdd (aRegC690[nPos], aRegC590[nI][03])	   	 			//04 - CFOP
		aAdd (aRegC690[nPos], aRegC590[nI][04])	   	 			//05 - ALIQ_ICMS
		aAdd (aRegC690[nPos], aRegC590[nI][05])		 	  		//06 - VL_OPR
		aAdd (aRegC690[nPos], aRegC590[nI][06])		 	  		//07 - VL_BC_ICMS
		aAdd (aRegC690[nPos], aRegC590[nI][07])		   			//08 - VL_ICMS
		aAdd (aRegC690[nPos], aRegC590[nI][10])		   			//09 - VL_RED_BC
		aAdd (aRegC690[nPos], aRegC590[nI][08])			   		//10 - VL_BC_ICMS_ST
		aAdd (aRegC690[nPos], aRegC590[nI][09])			   		//11 - VL_ICMS_ST
		aAdd (aRegC690[nPos], aRegC590[nI][11])			   		//12 - COD_OBS
	Else
		aRegC690[nPos][6]	+=	aRegC590[nI][05]				//06 - VL_OPR
		aRegC690[nPos][7]	+=	aRegC590[nI][06]				//07 - VL_BC_ICMS
		aRegC690[nPos][8]	+=	aRegC590[nI][07]				//08 - VL_ICMS
		aRegC690[nPos][9]	+=	aRegC590[nI][10]				//09 - VL_RED_BC
		aRegC690[nPos][10]	+=	aRegC590[nI][08]				//10 - VL_BC_ICMS_ST
		aRegC690[nPos][11]	+=	aRegC590[nI][09]				//11 - VL_ICMS_ST
	EndIf
Next nI
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RegC700   ³ Autor ³Gustavo G. Rueda       ³ Data ³09.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³C700 - CONSOLIDACAO DOS DOCUMENTOS NF/CONTA DE ENERGIA ELET.³±±
±±³          ³ EMITIDAS EM VIA UNICA (CPN. ICMS 115/03)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoe contidas na tabela   ³±±
±±³          ³ SFT.                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³C700 - 2(1:N)                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1 -> Posicao de relacionamento entre o C700 e C790      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|aRegC100 -> Array com as informacoes jah processadas.       ³±±
±±³          ³aRegC700 -> Array com as informacoes acumuladas para serem  ³±±
±±³          ³            gravadas ao final do processamento da rotina    ³±±
±±³          ³lAchouSFU-> Variavel de posicionamento da tabela SFU        ³±±
±±³          ³aCmpAntSFT-> Campos da tabela SFT posicionado por docuemto  ³±±
±±³          ³lAchouCD3-> Flag de posicionamento da tabela CD3            ³±±  
±±³          ³cEspecie  -> Modelo do documento fiscal                     ³±±  
±±³          ³cSituaDoc -> Situacao do documento fiscal                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegC700(aRegC100,aRegC700,lAchouSFU,aCmpAntSFT,lAchouCD3,cEspecie,cSituaDoc)
Local	nPos1	:=	0
Local	cChv115	:=	""
Local	cVol115	:=	""
//Local	nI		:=	0

If !cSituaDoc$"02#03"          
	If cEspecie$"28"
		If lAchouCD3
	     	cChv115	:=	CD3->CD3_CHV115
		    cVol115	:=	CD3->CD3_VOL115	
		EndIf
	Else		
		If lAchouSFU
			cChv115	:=	SFU->FU_CHV115
			cVol115	:=	SFU->FU_VOL115	
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³REGISTRO C700 - CONSOLIDACAO                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nPos1 := aScan(aRegC700,{|aX| aX[3]==aRegC100[1][7] .And. aX[9]==cChv115}))==0
		aAdd (aRegC700, {})
		nPos1	:=	Len (aRegC700)
		aAdd (aRegC700[nPos1], "C700")						//01 - REG
		aAdd (aRegC700[nPos1], aRegC100[1][5])				//02 - COD_MOD
		aAdd (aRegC700[nPos1], aRegC100[1][7])	   			//03 - SER
		aAdd (aRegC700[nPos1], aRegC100[1][8])	   	 		//04 - NRO_INI
		aAdd (aRegC700[nPos1], aRegC100[1][8])				//05 - NRO_FIN
		aAdd (aRegC700[nPos1], aCmpAntSFT[6])	   	 		//06 - DT_DOC_INI
		aAdd (aRegC700[nPos1], aCmpAntSFT[6])	   	 		//07 - DT_DOC_FIM
		aAdd (aRegC700[nPos1], cVol115) 					//08 - NOM_MEST
		aAdd (aRegC700[nPos1], cChv115)						//09 - CHV_COD_DIG
	EndIf
	aRegC700[nPos1][5]	:=	aRegC100[1][8]					//05 - NRO_FIN
	aRegC700[nPos1][7]	:=	aCmpAntSFT[6]		   			//07 - DT_DOC_FIM
EndIf
Return nPos1
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC790   ³ Autor ³Gustavo G. Rueda       ³ Data ³09.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³     C790 - REGISTRO ANALITICO DO DOCUMENTO (MODELO 06)     ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao da estrutura do Registro C790                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS no final do processamento da rotina    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³C700 - 2(varios por arquivo)                                ³±±
±±³          ³C790 - 3(1:N) Para cada C700                                ³±±
±±³          ³C791 - 4(1:N) Para cada C790                                ³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|aRegC590 -> Conteudo gravado do registro C590 para utiliza- ³±±
±±³          ³ cao em outros registros da funcao principal.               ³±±
±±³          ³nPosC700 -> Posicao de gravacao do registro C700 para       ³±±
±±³          ³            relacionamento com os registros filhos          ³±±
±±³          ³aRegC790 -> Array contendo as informacoes processadas pela  ³±±
±±³          ³ funcao a ser retornado para gravacao pela funcao principal.³±±
±±³          ³aRegC700 -> Array contendo as informacoes do registro C700  ³±±
±±³          ³aRegC791 -> Array contendo as informacoes do regsitro C791  ³±±
±±³          ³aCmpAntSFT->Array contendo as informacoes da SFT			  ³±±
±±³          ³cMVSUBTRIB-> Conteudo do parametro MV_SUBTRIB               ³±±
±±³          ³cSituaDoc -> Situacao do documento fiscal                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegC790(aRegC590,nPosC700,aRegC790,aRegC700,aRegC791,aCmpAntSFT,cMVSUBTRIB,cSituaDoc)
Local	nPos	:=	0
//Local   nPos1   :=  0
Local   nPos2   :=  0
Local	nI		:=	0

If !cSituaDoc$"02#03"  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³REGISTRO C790 - REGISTRO ANALITICO DOS DOCUMENTOS (MODELO 06)          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 To Len (aRegC590)
		If (nPos := aScan(aRegC790,{|aX| aX[1]==nPosC700 .And. aX[3]==aRegC590[nI][02] .And. aX[4]==aRegC590[nI][03] .And. aX[5]==aRegC590[nI][04]}))==0
			aAdd (aRegC790, {})
			nPos	:=	Len (aRegC790)
			aAdd (aRegC790[nPos], nPosC700)							   	//Relacionamento, serah manipulado na funcao REGC700
			aAdd (aRegC790[nPos], "C790")						   		//01 - REG
			aAdd (aRegC790[nPos], aRegC590[nI][02])					   	//02 - CST_ICMS
			aAdd (aRegC790[nPos], aRegC590[nI][03])	   	  		   		//03 - CFOP
			aAdd (aRegC790[nPos], aRegC590[nI][04])   			   		//04 - ALIQ_ICMS
			aAdd (aRegC790[nPos], 0)						   	   		//05 - VL_OPR
			aAdd (aRegC790[nPos], 0)						   	   		//06 - VL_BC_ICMS
			aAdd (aRegC790[nPos], 0)						   	   		//07 - VL_ICMS
			aAdd (aRegC790[nPos], 0)						   	   		//08 - VL_BC_ICMS_ST
			aAdd (aRegC790[nPos], 0)						   	   		//09 - VL_ICMS_ST
			aAdd (aRegC790[nPos], 0)						   	   		//10 - VL_RED_BC
			aAdd (aRegC790[nPos], aRegC590[nI][11])			   	   		//11 - COD_OBS
		EndIf 
		aRegC790[nPos][6]	+=	aRegC590[nI][05]					//05 - VL_OPR
		aRegC790[nPos][7]	+=	aRegC590[nI][06]			   		//06 - VL_BC_ICMS
		aRegC790[nPos][8]	+=	aRegC590[nI][07]			  		//07 - VL_ICMS
		aRegC790[nPos][9]	+=	aRegC590[nI][08]					//08 - VL_BC_ICMS_ST
		aRegC790[nPos][10]	+=	aRegC590[nI][09]					//09 - VL_ICMS_ST
	 	aRegC790[nPos][11]	+=	aRegC590[nI][10]		 			//10 - VL_RED_BC
	
		If aRegC790[nPos][9]+aRegC790[nPos][10] > 0 .And. aCmpAntSFT[23]$cMVSUBTRIB
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³REGISTRO C791 - REGISTRO DE INFORMACOES DE ST POR UF DOCUMENTOS (MODELO 06) ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	   	    If (nPos2 := aScan(aRegC791,{|aX|  aX[1] == nPos .And. aX[3]==aCmpAntSFT[23]}))==0
	             aAdd (aRegC791, {})
	             nPos2	:=	Len (aRegC791)
	   	         aAdd (aRegC791[nPos2], nPos)			    //Relacionamento, serah manipulado na funcao REGC791
	   	    	 aAdd (aRegC791[nPos2], "C791")				//02 - REG
		   		 aAdd (aRegC791[nPos2], aCmpAntSFT[23])		//03 - UF
		         aAdd (aRegC791[nPos2], 0)     	            //04 - VL_BC_ICMS_ST
		         aAdd (aRegC791[nPos2], 0)  	            //05 - VL_CIMS_ST		
		    EndIf
	        aRegC791[nPos2][04]	+=	aRegC790[nPos][09]		//04 - VL_BC_ICMS_ST
	        aRegC791[nPos2][05]	+=	aRegC790[nPos][10]		//05 - VL_ICMS_ST
	    EndIf
	Next nI
EndIf
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegD100   ³ Autor ³Gustavo G. Rueda       ³ Data ³11.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                       D100                                 ³±±
±±³          ³     NOTA FISCAL DE SERVICO DE TRANSPORTE (MODELO 07)       ³±±
±±³          ³ CONHECIMENTO DE TRANSPORTE RODOVIARIO DE CARGAS (MODELO 08)³±±
±±³          ³- Geracao e gravacao do Registro D100                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoes contidas no array   ³±±
±±³          ³ aTotaliza/aPartDoc/aCmpAntSFT para os Modelos 07/08.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³D100 - 2(varios por arquivo)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias do TRB que recebera as informacoes.         ³±±
±±³          |cEntSai -> Flag Entrada(1)/Saida(2).                        ³±±
±±³          ³aPartDoc -> Array com informacoes sobre o participante do   ³±±
±±³          ³ documento fiscal, este array eh montado pela funcao princi-³±±
±±³          ³ pal.                                                       ³±±
±±³          |aTotaliza -> Totalizadores de valores para a tabela SFT.    ³±±
±±³          ³nRelac    -> Flag de relacionamento com os sub-registros    ³±±
±±³          ³cEspecie  -> Modelo do documento fiscal                     ³±±
±±³          |aCmpAntSFT-> Informacoes sobre o cabecalho dos documentos.  ³±±
±±³          ³cSituaDoc -> Situacao do documento fiscal                   ³±±
±±³          ³lGrava0150-> Flag de geracao do registro 0150               ³±±
±±³          ³cOpSemF   -> Conteudo do parametro MV_OPSEMF                ³±±
±±³          ³lSpedRTms -> Flag de existencia do PESPEDRTMS               ³±±
±±³          ³lIntTMS   -> Retorno da chamada da funcao INTTMS()          ³±±
±±³          ³aInfCompl -> Informacao complementar da tabela CDT          ³±±
±±³          ³cAliasSFT -> Alias da tabela SFT posicionada no momento     ³±±
±±³          ³aReg0450  -> Array com a estrutura do 0450 gerado ateh o    ³±±
±±³          ³            momento.                                        ³±±
±±³          ³cVersao -> numero da versao do leiaute                      ³±±   
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegD100(cAlias,cEntSai,aPartDoc,aTotaliza,nRelac,cEspecie,aCmpAntSFT,cSituaDoc,;
						lGrava0150,cOpSemF,lSpedRTms,lIntTMS,aInfCompl,cAliasSFT,aReg0450,cVersao)
Local aReg      := {}
Local aRetPE    := {}
Local cDoctms   := ""
Local cChvCte   := aCmpAntSFT[25]
Local nPos      := 0
Local nPosIt    := 0
Local cCodInf   := ""
Local cRetPE    := ""              
Local dDT_A_P	 := aCmpAntSFT[5]
Local cConta		 := ""
Local cContCtb	:= RetCOD_CTA(cAliasSFT, "D100") 

aAdd (aReg, {})
nPos := Len(aReg)
             
//-- Permite alterar o calculo padrao atraves do PE SPEDRTMS
If lSpedRTMS
	aRetPE := ExecBlock("SPEDRTMS",.F.,.F.,{nPos,"D100",cAliasSFT,aCmpAntSFT})
	If ValType(aRetPE) == "A" .And. Len(aRetPE) > 0
		aReg := {}
		aEval(aRetPE,{|x| AAdd(aReg, x)})
		lGrava0150 := .T.
		If aExistBloc[13] 
			For nPosIt := 1 To Len(aReg)
				//-- Ponto de entrada para gravar informacoes complementares
				cCodInf := aReg[nPosIt,22] //22 - COD_INF
				cRetPE  := ExecBlock("SPEDR450", .F., .F., {cCodInf})
				If  ValType(cRetPE) == "C"
					Reg0450({cCodInf, cRetPE},@aReg0450)
				EndIf
			Next PosIt
		EndIf
	EndIf
EndIf

//-- Tratamento para o conhecimento Transporte Eletronico
If cEspecie=='57'
	//-- Se for SAIDA e com Integracao com o TMS, o DT6 jah estah posicionado
	If	cEntSai=="2" .And. lIntTMS
		cDoctms := "0"
		// Situacao do CT-e:
		// 00 - Normal
		// 02 - Cancelado
		// 04 - Uso Denegado
		// 05 - Inutilizacao
		// 06 - Complemento
		// 08 - Regime especial ou norma especifica
		If !cSituaDoc$"02#03#05"
			// Tipo do CT-e:                      
			// 0 - CT-e Normal,                   
			// 1 - CT-e de Complemento de Valores,
			// 2 - CT-e de Anulação de Valores,   
			// 3 - CT-e Substituto                
			Do Case
				Case DT6->DT6_DOCTMS $ "1/2/5/6/9/A/B/C/D/F/G/H/I/J/K/N/O"
					cDoctms := "0" //- CT-e Normal
				Case DT6->DT6_DOCTMS $ "7/8/E/L"
					cDoctms := "1" //- CT-e de Complemento de Valores
				Case DT6->DT6_DOCTMS $ "M"
					cDoctms := "2" //- CT-e de Anulação de Valores
				Case DT6->DT6_DOCTMS $ "P"
					cDoctms := "3" //- CT-e Substituto
			EndCase
			If Empty(cChvCte)
				cChvCte := DT6->DT6_CHVCTE
			EndIf
		EndIf
	Else
	    Do Case
		   Case aCmpAntSFT[40]=="N"
		     	cDoctms := "0" //- CT-e Normal
		   Case aCmpAntSFT[40]=="C"
		    	cDoctms := "1" //- CT-e de Complemento de Valores
		   Case aCmpAntSFT[40]=="A"
		    	cDoctms := "2" //- CT-e de Anulação de Valores
		   Case aCmpAntSFT[40]=="S"
		    	cDoctms := "3" //- CT-e Substituto
	    EndCase
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Somente deve gerar a chave da NFE/CTE no registro D100 se a nota fiscal for modelo 57  ³
//³e o formulario proprio seja sim (a partir de 2012, para qualquer caso)                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
If !(cEspecie$"57")
    cChvCte := ""
Else
    If cVersao<="004" .And. aCmpAntSFT[26] == "1"
	    cChvCte := ""
    EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para nota de Conhecimento de Frete - Gerada via MATA116                     ³
//³ Verifica se existe amarracao na SF8 (significa q foi gerado pela rotina MATA116)      ³
//³ e se for sit. 06 (complemento), altera o cod. sit. para '00' conforme boletim tecnico ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SF8")
SF8->(dbSetOrder(1))  // FILIAL + DOC + SERIE + CLIENTE + LOJA 
If cSituaDoc=="06" .And. SF8->(MsSeek( xFilial("SF8") + aCmpAntSFT[1] + aCmpAntSFT[2] + aCmpAntSFT[3] + aCmpAntSFT[4] ))
	cSituaDoc := '00'
EndIf
                          
//Se for doc extemporaneo pega data da CDT, caso não seja digitada pega a data do doc
If cSituaDoc$"01,07"
	dDT_A_P := If(Empty(aCmpAntSFT[41]),dDT_A_P,aCmpAntSFT[41])		
Endif

dbSelectArea("SB1")
SB1->(dbSetOrder(1))  
If SB1->(MsSeek( xFilial("SB1") + aCmpAntSFT[45]))
	cConta := SB1->B1_CONTA
EndIf  

//-- Verifica se o PE nao alterou a criacao do registro
If Len(aReg[nPos])==0
	aAdd (aReg[nPos], "D100")														//01 - REG
	aAdd (aReg[nPos], STR(Val (cEntSai)-1,1))								//02 - IND_OPER
	aAdd (aReg[nPos], aCmpAntSFT[26])											//03 - IND_EMIT
	aAdd (aReg[nPos], "")															//04 - COD_PART
	aAdd (aReg[nPos], cEspecie)													//05 - COD_MOD
	aAdd (aReg[nPos], cSituaDoc)													//06 - COD_SIT
	aAdd (aReg[nPos], aCmpAntSFT[2])												//07 - SER
	aAdd (aReg[nPos], "")															//08 - SUB
	aAdd (aReg[nPos], aCmpAntSFT[1])												//09 - NUM_DOC
	aAdd (aReg[nPos], cChvCte)														//10 - CHV_CTE
	aAdd (aReg[nPos], "")															//11 - DT_DOC
	aAdd (aReg[nPos], "")															//12 - DT_A_P
	aAdd (aReg[nPos], "")															//13 - TP_CTE
	aAdd (aReg[nPos], "")															//14 - CHV_CTE_REF
	aAdd (aReg[nPos], "")															//15 - VL_DOC
	aAdd (aReg[nPos], "")															//16 - VL_DESC
	aAdd (aReg[nPos], "")															//17 - IND_FRT
	aAdd (aReg[nPos], "")															//18 - VL_SERV
	aAdd (aReg[nPos], "")															//19 - VL_BC_ICMS
	aAdd (aReg[nPos], "")															//20 - VL_ICMS
	aAdd (aReg[nPos], "")															//21 - VL_NT
	aAdd (aReg[nPos], "")															//22 - COD_INF
	aAdd (aReg[nPos], "")															//23 - COD_CTA

	If !cSituaDoc$"02#03#05"
		aReg[nPos, 4] := aPartDoc[1]												//04 - COD_PART
		aReg[nPos,11] := aCmpAntSFT[6]											//11 - DT_DOC
		aReg[nPos,12] := dDT_A_P													//12 - DT_A_P (se for extemporaneo pega data da CDT)
		aReg[nPos,13] := cDoctms													//13 - TP_CTE
		aReg[nPos,15] := aTotaliza[1]												//15 - VL_DOC
		aReg[nPos,16] := aTotaliza[9]												//16 - VL_DESC
		//³Campo 17 - Valores validos: [0, 1, 2, 9]                                                             |
		//³Preenchimento: usar o valor 0 (por conta de terceiros)                                               |
		//³     para os casos em que o tomador e' diferente do emitente ou destinatario.                        |
		//³Tem-se por tomador quem efetuou o contrato junto a transportadora, arcando com o valor do servico.   |
		//³Somente a este deve ser enviada a primeira via do conhecimento e so ele tera direito ao credito.     ³
		If cEntSai=="2" .And. lIntTMS
			aReg[nPos,17] := aCmpAntSFT[21]										//17 - IND_FRT
		Else	
			If Len(aCmpAntSFT[21])>0 .And.  AllTrim(aCmpAntSFT[21])<>"9"
				aReg[nPos,17] := aCmpAntSFT[21]									//17 - IND_FRT

			ElseIf AllTrim(aCmpAntSFT[9])$cOpSemF
				aReg[nPos,17] := "9"													//17 - IND_FRT

			ElseIf Len(aCmpAntSFT[24])>0 .And.  AllTrim(aCmpAntSFT[24])== "CONHEC. FRETE" 	//17 - IND_FRT
				aReg[nPos,17] := "2"

			Else
				aReg[nPos,17] := "1"													//17 - IND_FRT
			EndIf
		EndIf

		aReg[nPos,18] := aTotaliza[1]												//18 - VL_SERV
		aReg[nPos,19] := aTotaliza[2]												//19 - VL_BC_ICMS
		aReg[nPos,20] := aTotaliza[3]												//20 - VL_ICMS
		aReg[nPos,21] := aTotaliza[14]												//21 - VL_NT
		aReg[nPos,22] := Iif(Len(aInfCompl)>0,aInfCompl[1],"")		   			//22 - COD_INF
		cConta	:= Iif(!Empty(aCmpAntSFT[19]),aCmpAntSFT[19],cConta)				//37 - COD_CTA
		aReg[nPos,23] := Iif(!Empty(cContCtb),cContCtb,cConta)					//23 - COD_CTA


		lGrava0150 := .T.
	EndIf
EndIf

GrvRegTrS(cAlias,nRelac,aReg)

Return
/*
±±³Programa  ³RegD110   ³ Autor ³Gustavo G. Rueda       ³ Data ³11.03.2011³±±

±±³Descri‡…o ³                                                            ³±±
±±³          ³                         D110                               ³±±
±±³          ³  ITENS DA NOTA FISCAL DE SERVICO DE TRANSPORTE (MODELO 07) ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro D110                       ³±±

±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoes contidas na tabela  ³±±
±±³          ³ SFT.                                                       ³±±

±±³Nivel Hier³D120 - 3(1:N) Para cada D100                                ³±±

±±³Retorno   ³Nil                                                         ³±±

±±³Parametros³cAlias -> Alias do TRB que recebera as informacoes.         ³±±
±±³          ³cAliasSFT -> Alias da tabela SFT posicionada no momento do  ³±±
±±³          | processamento.                                             ³±±
±±³          |nRelac -> Flag de relacionamento de registro para gravar no ³±±
±±³          | TRB.                                                       ³±±
±±³          |nItem  -> Numero do item em processamento para gravar no TRB³±±
±±³          |cProd  -> Codigo do produto montado pela rotina             ³±±
±±³          |lSpedRTms -> Flag de existencia do PE SPEDRTMS              ³±±
±±³          |aCmpAntSFT-> Informacoes sobre o cabecalho dos documentos.  ³±±
*/
Static Function RegD110(cAlias,cAliasSFT,nRelac,nItem,cProd,lSpedRTms,aCmpAntSFT)
local nPos     := 0
Local aRegD110 := {}
Local aRetPE   := {}

aAdd (aRegD110, {})
nPos := Len(aRegD110)

//-- Ponto de entrada para substituir o calculo do sistema
If lSpedRTMS
	aRetPE := ExecBlock("SPEDRTMS",.F.,.F.,{nPos,"D110",cAliasSFT,aCmpAntSFT})
	If ValType(aRetPE) == "A" .And. Len(aRetPE) > 0
		aRegD110 := {}
		aEval(aRetPE,{|x| AAdd(aRegD110, x)})
	EndIf
EndIf

//-- Se nao foi alterado nada via PE, faco o padrao
If Len(aRegD110[nPos]) == 0
	aAdd (aRegD110[nPos], "D110")								//01 - REG
	aAdd (aRegD110[nPos], {Val((cAliasSFT)->FT_ITEM), 0})		//02 - NUM_ITEM
	aAdd (aRegD110[nPos], cProd)								//03 - COD_ITEM
	aAdd (aRegD110[nPos], (cAliasSFT)->FT_TOTAL)				//04 - VL_SERV
	aAdd (aRegD110[nPos], (cAliasSFT)->FT_DESPESA)				//05 - VL_OUT
EndIf

GrvRegTrS(cAlias,nRelac,aRegD110,nItem)

Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegD120   ³ Autor ³Gustavo G. Rueda       ³ Data ³11.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³                         D120                               ³±±
±±³          ³    COMPLEMENTO DA NOTA FISCAL DE SERVICO DE TRANSPORTE     ³±±
±±³          ³                     (MODELO 07)                            ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro D120                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoes contidas nas tabelas³±±
±±³          ³ DT6/DA3/DUY/SA1 caso tenham integracao com o TMS.          ³±±
±±³          ³O DA3 utilizado nesta funcao pode estar posicionado de acor-³±±
±±³          ³ do com a tabela  DTR quando envolver TMS ou DB1 quando     ³±±
±±³          ³ envolver o recebimento no compras (MATR145).               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³D120 - 3(1:1) Para cada D100                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias do TRB que recebera as informacoes.         ³±±
±±³          ³nRelac -> Flag de relacionamento com os sub-registros       ³±±
±±³          ³lAchouDA3 -> Flag que identifica se a tabela DA3 foi posi-  ³±±
±±³          ³ cionada.                                                   ³±±
±±³          ³nItem  -> Numero do item para controle do TRB               ³±±
±±³          |lSpedRTms -> Flag de existencia do PE SPEDRTMS              ³±±
±±³          |aCmpAntSFT-> Informacoes sobre o cabecalho dos documentos.  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegD120(cAlias,nRelac,lAchouDA3,nItem,lSpedRTms,cAliasSFT,aCmpAntSFT)
Local aReg     := {}
Local aAreaSA1 := SA1->(GetArea())
Local cCodMun  := ''
Local aRetPE   := {}

aAdd (aReg, {})
nPos := Len(aReg)

//-- Ponto de entrada para substituir o calculo do sistema
If lSpedRTMS
	aRetPE := ExecBlock("SPEDRTMS",.F.,.F.,{nPos,"D120",cAliasSFT,aCmpAntSFT})
	If ValType(aRetPE) == "A" .And. Len(aRetPE) > 0
		aReg := {}
		aEval(aRetPE,{|x| AAdd(aReg, x)})
	EndIf
EndIf

//-- Se nao foi alterado nada via PE, faco o padrao
If Len(aReg[nPos])==0
	aAdd (aReg[nPos], "D120")												//01 - REG

	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³Remetente³
	//ÀÄÄÄÄÄÄÄÄÄÙ
	If SA1->(MsSeek(xFilial("SA1")+DT6->DT6_CLIREM+DT6->DT6_LOJREM))
		cCodMun:= TMSCodMun(DT6->DT6_CDRORI)
		AAdd (aReg[nPos],cCodMun)											//02 - COD_MUN_ORIG	
	Else
		aAdd (aReg[nPos], "")												//02 - COD_MUN_ORIG
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Destinatario³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SA1->(MsSeek(xFilial("SA1")+DT6->DT6_CLIDES+DT6->DT6_LOJDES))
		If Upper(SA1->A1_EST) == "EX"
			cCodMun:= TMSCodMun(DT6->DT6_CDRCAL)
		Else
			cCodMun:= TMSCodMun(DT6->DT6_CDRDES)
		EndIf
		aAdd (aReg[nPos], cCodMun)											//03 - COD_MUN_DEST
	Else
		aAdd (aReg[nPos], "")												//03 - COD_MUN_DEST
	EndIf

	//-- Obtendo dados do veiculo de transporte
	If lAchouDA3
		aAdd (aReg[nPos], SubStr(StrTran(DA3->DA3_PLACA,"-",""),1,7))		//04 - VEIC_ID
		aAdd (aReg[nPos], DA3->DA3_ESTPLA)									//05 - VEIC_ID
	Else
		aAdd (aReg[nPos], "")												//04 - VEIC_ID
		aAdd (aReg[nPos], "")												//05 - VEIC_ID
	EndIf
EndIf

GrvRegTrS(cAlias,nRelac,aReg,nItem)

RestArea(aAreaSA1)

Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegD130   ³ Autor ³Gustavo G. Rueda       ³ Data ³11.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³                         D130                               ³±±
±±³          ³           COMPLEMENTO DO DOCUMENTO (MODELO 08)             ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro D130                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoes contidas nas tabelas³±±
±±³          ³ DT6/DA3/DT8 caso tenham integracao com o TMS.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3(1:1) Para cada D100                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias do TRB que recebera as informacoes.         ³±±
±±³          ³nRelac -> Flag de relacionamento com os sub-registros       ³±±
±±³          ³lAchouDA3 -> Flag que identifica se a tabela DA3 estah      ³±±
±±³          ³   posicionada e pronta para ser lida                       ³±±
±±³          ³cSituaDoc -> Situacao do documento fiscal conforme funcao   ³±±
±±³          ³aMVCOMPFRT -> Array com os códigos de componentes que serão ³±±
±±³          ³ relacionados com registros do DT8, no seguinte formato:    ³±±
±±³          ³ {"FretePV","SEC/CAT","Despacho","Pedágio"}                 ³±±
±±³          ³lSpedRTms-> Flag de existencia do PE SPEDRTMS               ³±±
±±³          ³lAchouDT8 -> Flag de posicionamento da tabela DT8           ³±±
±±³          ³cAliasDT8 -> Alias da tabela DT8 a ser utilizada            ³±±
±±³          ³cCdMunOri -> Municipio de origem calculado pelo DT6         ³±±
±±³          ³aPartREM  -> Array com as informacoes do participante       ³±±
±±³          ³             Remetente                                      ³±±
±±³          ³cCdMunDes -> Municipio de destino calculado pelo DT6        ³±±
±±³          ³aPartDES  -> Array com as informacoes do participante       ³±±
±±³          ³             destinatario                                   ³±±
±±³          ³aPartCON  -> Array com as informacoes do participante       ³±±
±±³          ³             consignatario                                  ³±±
±±³          ³aPartDPC  -> Array com as informacoes do participante       ³±±
±±³          ³             despachante                                    ³±±
±±³          ³aReg0150  -> Array com a estrutura do registro 0150         ³±±
±±³          |aWizard   -> Array com as informacoes do wizard             ³±±
±±³          ³cAliasSFT -> Alias da tabela SFT posicionada no momento     ³±±
±±³          |aCmpAntSFT-> Informacoes sobre o cabecalho dos documentos.  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegD130(cAlias,nRelac,lAchouDA3,cSituaDoc,aMVCOMPFRT,lSpedRTms,lAchouDT8,cAliasDT8,;
					cCdMunOri,aPartREM,cCdMunDes,aPartDES,aPartCON,aPartDPC,aReg0150,aWizard,cAliasSFT,aCmpAntSFT)
Local aReg     := {}
Local aRetPE   := {}
Local nPos     := 0
Local nVlFrete := 0
Local cDT8Chv		:= ""

//-- Inicio da montagem do registro
aAdd (aReg, {})
nPos := Len(aReg)

//-- Gera registro dos participantes
If !cSituaDoc$"02#04#05#03"
	If Len(aPartCON) > 0
		SDPF150175(@aReg0150,aPartCON,cAlias,aWizard,aExistBloc)
	EndIf
	If Len(aPartDPC) > 0
		SDPF150175(@aReg0150,aPartDPC,cAlias,aWizard,aExistBloc)
	EndIf
EndIf

//-- Ponto de entrada para substituir o calculo do sistema
If lSpedRTMS
	aRetPE := ExecBlock("SPEDRTMS",.F.,.F.,{nPos,"D130",cAliasSFT,aCmpAntSFT})
	If ValType(aRetPE) == "A" .And. Len(aRetPE) > 0
		aReg := {}
		aEval(aRetPE,{|x| AAdd(aReg, x)})
	EndIf
EndIf

//-- Se nao foi alterado nada via PE, faco o padrao
If Len(aReg[nPos])==0
	aAdd (aReg[nPos], "D130")																//01 - REG
	aAdd (aReg[nPos], IIf (cSituaDoc$"02#04#05#03" .Or. Empty(aPartCON), "", aPartCON[1]))	//02 - COD_PART_CONSG
	aAdd (aReg[nPos], IIf (cSituaDoc$"02#04#05#03" .Or. Empty(aPartDPC), "", aPartDPC[1]))	//03 - COD_PART_RED

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tipo de frete³
	//³1=CIF, 2=FOB ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (DT6->DT6_TIPFRE$"1")
		aAdd (aReg[nPos],"0")															//04 - IND_FRT_RED
	Else
		aAdd (aReg[nPos],"1")															//04 - IND_FRT_RED
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Municipio de origem³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cCdMunOri)   //Não encontrou registro no SA1
		aAdd (aReg[nPos], aPartREM[7])													//05 - COD_MUN_ORIG
	Else
		aAdd (aReg[nPos], cCdMunOri)													//05 - COD_MUN_ORIG
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Municipio de destino³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cCdMunDes)   //Não encontrou registro no SA1
		aAdd (aReg[nPos], aPartDES[7])													//06 - COD_MUN_DEST	
	Else
		aAdd (aReg[nPos], cCdMunDes)													//06 - COD_MUN_DEST	
	EndIf

	aAdd (aReg[nPos], Iif(lAchouDA3,SubStr(StrTran(DA3->DA3_PLACA,"-",""),1,7),""))	//07 - VEIC_ID
	aAdd (aReg[nPos], 0)																//08 - VL_LIQ_FRT
	aAdd (aReg[nPos], 0)																//09 - VL_SEC_CAT
	aAdd (aReg[nPos], 0)																//10 - VL_DESP
	aAdd (aReg[nPos], 0)																//11 - VL_PEDG
	aAdd (aReg[nPos], 0)																//12 - VL_OUT
	aAdd (aReg[nPos], 0)																//13 - VL_FRT
	aAdd (aReg[nPos], Iif(lAchouDA3,DA3->DA3_ESTPLA,""))								//14 - UF_ID

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quando lAchouDT8 estiver verdadeiro, significa que encontrou  o registro³
	//³ para o conhecimento em questao e que a tabela esta posicionada no      ³
	//³ primeiro registro.                                                     ³
	//³                                                                        ³
	//³NAO PRECISO DE TRATAMENTO DE TOP OU DBF PORQUE O TMS EH SOH AMBIENTE TOP³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAchouDT8 
		cDT8Chv := (cAliasDT8)->(DT8_FILIAL+DT8_FILDOC+DT8_DOC+DT8_SERIE)
		Do While !(cAliasDT8)->(Eof ()) .AND. ((cAliasDT8)->(DT8_FILIAL+DT8_FILDOC+DT8_DOC+DT8_SERIE)==cDT8Chv)

			//--Campo DT3_TIPCMP (Tipo do componente de frete) criado para complementar o conhecimento rodoviario de cargas do SPEDFISCAL.
			If Empty(aMVCOMPFRT[1]) .And. Empty(aMVCOMPFRT[2]) .And. Empty(aMVCOMPFRT[3]) .And. Empty(aMVCOMPFRT[4])

				//Valor Total do frete
				If (cAliasDT8)->DT8_CODPAS$"TF"
					aReg[nPos][13]	+=	(cAliasDT8)->DT8_VALTOT								//13 - VL_FRT

				ElseIf SpedSeek("DT3",1,xFilial("DT3")+(cAliasDT8)->DT8_CODPAS) // Posiciona na DT3
					
					//Valor do frete por peso/volume
					If DT3->DT3_TIPCMP=="1"
						aReg[nPos][08]	+=	(cAliasDT8)->DT8_VALTOT								//08 - VL_FRT_PV
	
					//Valores do SEC/CAT
					ElseIf DT3->DT3_TIPCMP=="2"
						aReg[nPos][09]	+=	(cAliasDT8)->DT8_VALTOT								//09 - VL_SEC_CAT
	
					//Valores de despacho
					ElseIf DT3->DT3_TIPCMP=="3"
						aReg[nPos][10]	+=	(cAliasDT8)->DT8_VALTOT								//10 - VL_DESP
	
					//Valores de pedagio
					ElseIf DT3->DT3_TIPCMP=="4"
						aReg[nPos][11]	+=	(cAliasDT8)->DT8_VALTOT								//11 - VL_PEDG
                    
                    //Outros valores
                    Else
                    	aReg[nPos][12]	+=	(cAliasDT8)->DT8_VALTOT								//12 - VL_OUT
                    EndIf 
                    
				//Outros valores
				Else
					aReg[nPos][12]	+=	(cAliasDT8)->DT8_VALTOT								//12 - VL_OUT
				EndIf

			ElseIf Len(aMVCOMPFRT)==4
				//Valor Total do frete
				If (cAliasDT8)->DT8_CODPAS$"TF"
					aReg[nPos][13]	+=	(cAliasDT8)->DT8_VALTOT								//13 - VL_FRT

				//Valor do frete por peso/volume
				ElseIf (cAliasDT8)->DT8_CODPAS$aMVCOMPFRT[1]
					aReg[nPos][08]	+=	(cAliasDT8)->DT8_VALTOT								//08 - VL_FRT_PV

				//Valores do SEC/CAT
				ElseIf (cAliasDT8)->DT8_CODPAS$aMVCOMPFRT[2]
					aReg[nPos][09]	+=	(cAliasDT8)->DT8_VALTOT								//09 - VL_SEC_CAT

				//Valores de despacho
				ElseIf (cAliasDT8)->DT8_CODPAS$aMVCOMPFRT[3]
					aReg[nPos][10]	+=	(cAliasDT8)->DT8_VALTOT								//10 - VL_DESP

				//Valores de pedagio
				ElseIf (cAliasDT8)->DT8_CODPAS$aMVCOMPFRT[4]
					aReg[nPos][11]	+=	(cAliasDT8)->DT8_VALTOT								//11 - VL_PEDG

				//Outros valores
				Else
					aReg[nPos][12]	+=	(cAliasDT8)->DT8_VALTOT								//12 - VL_OUT
				EndIf

			//Valor Total do Frete
			ElseIf (cAliasDT8)->DT8_CODPAS$"TF"
				aReg[nPos][13]	+=	(cAliasDT8)->DT8_VALTOT									//13 - VL_FRT

			//Outros valores
			Else
				aReg[nPos][12]	+=	(cAliasDT8)->DT8_VALTOT									//12 - VL_OUT
			EndIf

			(cAliasDT8)->(DbSkip ())
		EndDo
		//-- Suprimir decimais: converte campo Volume (DTC_QTDVOL) para caracter
		AEval(aReg,{|x|nVlFrete+=x[8]})
		If	nVlFrete == 0
			aReg[nPos,4] := "9"																//04 - IND_FRT_RED
		EndIf
	EndIf
EndIf
//-- Gravacao do registro no TRB
If Len(aReg[nPos]) > 0
	GrvRegTrS(cAlias,nRelac,aReg)
EndIf
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegD140   ³ Autor ³Gustavo G. Rueda       ³ Data ³11.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³                         D140                               ³±±
±±³          ³           COMPLEMENTO DO DOCUMENTO (MODELO 09)             ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro D140                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoes contidas nas tabelas³±±
±±³          ³ DT6/DA3/DT8 caso tenham integracao com o TMS.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3(1:1) Para cada D100                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias do TRB que recebera as informacoes.         ³±±
±±³          ³nRelac -> Flag de relacionamento com os sub-registros       ³±±
±±³          ³lSpedRTms-> Flag de existencia do PE SPEDRTMS               ³±±
±±³          ³aWizard -> Informacoes digitadas no wizard da rotina        ³±±
±±³          ³lAchouDA3 -> Flag que identifica se a tabela DA3 estah      ³±±
±±³          ³   posicionada e pronta para ser lida                       ³±±
±±³          ³lAchouDUD -> Flag que identifica se a tabela DUD estah      ³±±
±±³          ³   posicionada e pronta para ser lida                       ³±±
±±³          ³lAchouDT8 -> Flag de posicionamento da tabela DT8           ³±±
±±³          ³cAliasDT8 -> Alias da tabela DT8 a ser utilizada            ³±±
±±³          ³aPartREM  -> Array com as informacoes do participante       ³±±
±±³          ³             Remetente                                      ³±±
±±³          ³aPartDES  -> Array com as informacoes do participante       ³±±
±±³          ³             destinatario                                   ³±±
±±³          ³aPartCON  -> Array com as informacoes do participante       ³±±
±±³          ³             consignatario                                  ³±±
±±³          ³cAliasSFT -> Alias da tabela SFT posicionada no momento     ³±±
±±³          |aCmpAntSFT-> Informacoes sobre o cabecalho dos documentos.  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegD140(cAlias,nRelac,lSpedRTms,lAchouDA3,lAchouDUD,lAchouDT8,cAliasDT8,aPartREM,aPartDES,aPartCON,cAliasSFT,aCmpAntSFT)
Local aReg   := {}
Local aRetPE := {}
Local cDT8Chv := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio da montagem do registro ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd (aReg, {})
nPos := Len(aReg)

//-- Ponto de entrada para substituir o calculo do sistema
If lSpedRTMS
	aRetPE := ExecBlock("SPEDRTMS",.F.,.F.,{nPos,"D140",cAliasSFT,aCmpAntSFT})
	If ValType(aRetPE) == "A" .And. Len(aRetPE) > 0
		aReg := {}
		aEval(aRetPE,{|x| AAdd(aReg, x)})
	EndIf
EndIf

//-- Se nao foi alterado nada via PE, faco o padrao
If Len(aReg[nPos])==0
	aAdd (aReg[nPos], "D140")															//01 - REG
	aAdd (aReg[nPos], If(Empty(aPartCON),"",aPartCON[1]))								//02 - COD_PART_CONSG
	aAdd (aReg[nPos], aPartREM[7])														//03 -
	aAdd (aReg[nPos], aPartDES[7])														//04 - COD_MUN_DEST
	aAdd (aReg[nPos], "0")																//05 - IND_VEIC
	aAdd (aReg[nPos], Iif (lAchouDA3, SubStr(StrTran(DA3->DA3_PLACA,"-",""),1,7), ""))	//06 - VEIC_ID
	aAdd (aReg[nPos], "0")																//07 - IND_NAV
	aAdd (aReg[nPos], Iif (lAchouDUD, DUD->DUD_VIAGEM, ""))							//08 - VIAGEM
	aAdd (aReg[nPos], 0)																//09 - VL_LIQ_FRT
	aAdd (aReg[nPos], 0)																//10 - VL_DESP_PORT
	aAdd (aReg[nPos], 0)																//11 - VL_DESP_CAR_DESC
	aAdd (aReg[nPos], 0)																//12 - VL_OUT
	aAdd (aReg[nPos], 0)																//13 - VL_FRT_BRT
	aAdd (aReg[nPos], 0)																//14 - VL_FRT_MM

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quando lAchouDT8 estiver verdadeiro, significa que encontrou  o registro³
	//³ para o conhecimento em questao e que a tabela esta posicionada no      ³
	//³ primeiro registro.                                                     ³
	//³                                                                        ³
	//³NAO PRECISO DE TRATAMENTO DE TOP OU DBF PORQUE O TMS EH SOH AMBIENTE TOP³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAchouDT8  
		cDT8Chv := (cAliasDT8)->(DT8_FILIAL+DT8_FILDOC+DT8_DOC+DT8_SERIE) 
		Do While !(cAliasDT8)->(Eof ()) .AND. ((cAliasDT8)->(DT8_FILIAL+DT8_FILDOC+DT8_DOC+DT8_SERIE)==cDT8Chv)

			//Valor Total do frete
			If (cAliasDT8)->DT8_CODPAS$"TF"
				aReg[nPos][13]	+=	(cAliasDT8)->DT8_VALTOT								//13 - VL_FRT_BRT
			Else //Outros valores
				aReg[nPos][12]	+=	(cAliasDT8)->DT8_VALTOT								//12 - VL_OUT
			EndIf
			
			(cAliasDT8)->(DbSkip ())
		EndDo
	EndIf
EndIf
//-- Gravacao do registro no TRB
If Len(aReg[nPos]) > 0
	GrvRegTrS(cAlias,nRelac,aReg)
EndIf
Return
/*
³Programa  ³RegD150   ³ Autor ³Gustavo G. Rueda       ³ Data ³11.03.2011³

³Descri‡…o ³                                                            ³
³          ³                         D150                               ³
³          ³           COMPLEMENTO DO DOCUMENTO (MODELO 09)             ³
³          ³                                                            ³
³          ³- Geracao e gravacao do Registro D150                       ³

³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³
³          ³ da funcao GrvRegTrS com as informacoes contidas nas tabelas³
³          ³ DT6/DA3/DT8 caso tenham integracao com o TMS.              ³
³Nivel Hier³3(1:1) Para cada D100                                       ³

³Retorno   ³Nil                                                         ³

³Parametros³cAlias -> Alias do TRB que recebera as informacoes.         ³
³          ³nRelac -> Flag de relacionamento com os sub-registros       ³
³          ³lSpedRTms-> Flag de existencia do PE SPEDRTMS               ³
³          ³lAchouDA3 -> Flag que identifica se a tabela DA3 estah      ³
³          ³   posicionada e pronta para ser lida                       ³
³          ³lAchouDUD -> Flag que identifica se a tabela DUD estah      ³
³          ³   posicionada e pronta para ser lida                       ³
³          ³lAchouDT8 -> Flag de posicionamento da tabela DT8           ³
³          ³cAliasDT8 -> Alias da tabela DT8 a ser utilizada            ³
³          ³aPartREM  -> Array com as informacoes do participante       ³
³          ³             Remetente                                      ³
³          ³aPartDES  -> Array com as informacoes do participante       ³
³          ³             destinatario                                   ³
³          ³cAliasSFT -> Alias da tabela SFT posicionada no momento     ³
³          |aCmpAntSFT-> Informacoes sobre o cabecalho dos documentos.  ³
*/
Static Function RegD150(cAlias,nRelac,lSpedRTms,lAchouDA3,lAchouDUD,lAchouDT8,cAliasDT8,aPartREM,aPartDES,cAliasSFT,aCmpAntSFT)
Local aReg   := {}
Local aRetPE := {}
Local cDT8Chv := ""

//-- Inicio da montagem do registro
aAdd (aReg, {})
nPos := Len(aReg)

//-- Ponto de entrada para substituir o calculo do sistema
If lSpedRTMS
	aRetPE := ExecBlock("SPEDRTMS",.F.,.F.,{nPos,"D150",cAliasSFT,aCmpAntSFT})
	If ValType(aRetPE) == "A" .And. Len(aRetPE) > 0
		aReg := {}
		aEval(aRetPE,{|x| AAdd(aReg, x)})
	EndIf
EndIf

//-- Se nao foi alterado nada via PE, faco o padrao
If Len(aReg[nPos]) == 0
	aAdd (aReg[nPos], "D150")															//01 - REG
	aAdd (aReg[nPos], aPartREM[7])														//02 - COD_MUN_ORIG
	aAdd (aReg[nPos], aPartDES[7])														//03 - COD_MUN_DEST
	aAdd (aReg[nPos], Iif (lAchouDA3, SubStr(StrTran(DA3->DA3_PLACA,"-",""),1,7), ""))	//04 - VEIC_ID
	aAdd (aReg[nPos], Iif (lAchouDUD, DUD->DUD_VIAGEM, ""))							//05 - VIAGEM
	aAdd (aReg[nPos], "0")																//06 - IND_TFA
	aAdd (aReg[nPos], 0)																//07 - VL_PESO_TX
	aAdd (aReg[nPos], 0)																//08 - VL_TX_TERR
	aAdd (aReg[nPos], 0)																//09 - VL_TX_RED
	aAdd (aReg[nPos], 0)																//10 - VL_OUT
	aAdd (aReg[nPos], 0)																//11 - VL_TX_ADV


	//³Quando lAchouDT8 estiver verdadeiro, significa que encontrou  o registro³
	//³ para o conhecimento em questao e que a tabela esta posicionada no      ³
	//³ primeiro registro.                                                     ³
	//³                                                                        ³
	//³NAO PRECISO DE TRATAMENTO DE TOP OU DBF PORQUE O TMS EH SOH AMBIENTE TOP³
	If lAchouDT8                
		cDT8Chv := (cAliasDT8)->(DT8_FILIAL+DT8_FILDOC+DT8_DOC+DT8_SERIE)
		Do While !(cAliasDT8)->(Eof ()) .AND. ((cAliasDT8)->(DT8_FILIAL+DT8_FILDOC+DT8_DOC+DT8_SERIE)==cDT8Chv)

			//Valor Total do frete
			If (cAliasDT8)->DT8_CODPAS$"TF"
				aReg[nPos][07]	+=	(cAliasDT8)->DT8_VALTOT								//13 - VL_FRT_BRT
			Else //Outros valores
				aReg[nPos][10]	+=	(cAliasDT8)->DT8_VALTOT								//12 - VL_OUT
			EndIf

			(cAliasDT8)->(DbSkip ())
		EndDo
	EndIf
EndIf
//-- Gravacao do registro no TRB
If Len(aReg[nPos]) > 0
	GrvRegTrS(cAlias,nRelac,aReg)
EndIf
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegD160   ³ Autor ³Gustavo G. Rueda       ³ Data ³14.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³          D160 - CARGA TRANSPORTADA (MODELO 08)             ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro D160                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoes contidas nas tabelas³±±
±±³          ³ DT6/SA1/SFT caso tenham integracao com o TMS.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³D160 - 3(1:1) Para cada D100                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias do TRB que recebera as informacoes.         ³±±
±±³          ³nRelac -> Flag de relacionamento com os sub-registros       ³±±
±±³          ³cEspecie -> Modelo do documento fiscal                      ³±±
±±³          |lSpedRTms -> Flag de existencia do PE SPEDRTMS              ³±±
±±³          ³aPartREM  -> Array com as informacoes do participante       ³±±
±±³          ³             Remetente                                      ³±±
±±³          ³cCdMunOri -> Municipio de origem calculado pelo DT6         ³±±
±±³          ³aPartDES  -> Array com as informacoes do participante       ³±±
±±³          ³cCdMunDes -> Municipio de destino calculado pelo DT6        ³±±
±±³          ³cAliasSFT -> Alias da tabela SFT posicionada no momento     ³±±
±±³          |aCmpAntSFT-> Informacoes sobre o cabecalho dos documentos.  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegD160(cAlias,nRelac,cEspecie,lSpedRTms,aPartREM,cCdMunOri,aPartDES,cCdMunDes,cAliasSFT,aCmpAntSFT)
Local aRegD160 := {}
Local nPos     := 0
Local cIndCg   := "0"
Local aRetPE   := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do indicador do tipo de carga.³
//³0=Rodoviario;                          ³
//³1=Ferroviario                          ³
//³2=Rodo-ferroviario                     ³
//³3=Aquaviario                           ³
//³4=Dutoviario                           ³
//³5=Aereo                                ³
//³9=Outros                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cEspecie=="09"
	cIndCg 	:= 	"2"
ElseIf cEspecie=="10"
	cIndCg 	:= 	"4"
ElseIf cEspecie=="11"
	cIndCg	:= 	"1"
ElseIf cEspecie=="26"
	cIndCg 	:= 	"9"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³REGISTRO D160 - CARGA TRANSPORTADA - Inicio da montagem do registro    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd (aRegD160, {})
nPos := Len(aRegD160)

//-- Ponto de entrada para substituir o calculo do sistema
If lSpedRTMS
	aRetPE := ExecBlock("SPEDRTMS",.F.,.F.,{nPos,"D160",cAliasSFT,aCmpAntSFT})
	If ValType(aRetPE) == "A" .And. Len(aRetPE) > 0
		aRegD160 := {}
		aEval(aRetPE,{|x| AAdd(aRegD160, x)})
	EndIf
EndIf

//-- Se nao foi alterado nada via PE, faco o padrao
If Len(aRegD160[nPos]) == 0
	aAdd (aRegD160[nPos], "D160")	 										//01 - REG
	aAdd (aRegD160[nPos], "")				 								//02 - DESPACHO
	aAdd (aRegD160[nPos], If(Empty(aPartREM[4]),aPartREM[5],aPartREM[4]))	//03 - CNPJ_CPF_REM
	aAdd (aRegD160[nPos], aPartREM[6])										//04 - IE_REM

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Municipio de origem³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cCdMunOri)   //Nao encontrou registro no SA1
		aAdd (aRegD160[nPos], aPartREM[7])									//05 - COD_MUN_ORI
	Else
		aAdd (aRegD160[nPos], cCdMunOri)									//05 - COD_MUN_ORI
	EndIf

	aAdd (aRegD160[nPos], aPartDES[4])										//06 - CNPJ_CPF_DEST
	aAdd (aRegD160[nPos], aPartDES[6])										//07 - IE_DEST

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Municipio de destino³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cCdMunDes)   //Nao encontrou registro no SA1
		aAdd (aRegD160[nPos], aPartDES[7])									//08 - CPD_MUN_DEST
	Else
		aAdd (aRegD160[nPos], cCdMunDes)									//08 - CPD_MUN_DEST
	EndIf
EndIf
//-- Gravacao do registro no TRB
If Len(aRegD160[nPos]) > 0
	GrvRegTrS(cAlias,nRelac,aRegD160)
EndIf
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³D161D162  ³ Autor ³Gustavo G. Rueda       ³ Data ³14.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³       D161 - LOCAL DE COLETA/ENTREGA (MODELO 08)           ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao dos Registros D160, D161 e D162        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoes contidas nas tabelas³±±
±±³          ³ DT6/SA1/SFT caso tenham integracao com o TMS.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³D120 - 3(1:1) Para cada D100                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias do TRB que recebera as informacoes.         ³±±
±±³          ³nRelac -> Flag de relacionamento com os sub-registros       ³±±
±±³          ³cEspecie -> Modelo do documento fiscal                      ³±±
±±³          |aCmpAntSFT -> Informacoes sobre o cabecalho dos documentos. ³±±
±±³          |cMvD162 -> Conteudo do parametro MV_NGD162                  ³±±
±±³          |lSpedRTms -> Flag de existencia do PE SPEDRTMS              ³±±
±±³          ³aPartREM  -> Array com as informacoes do participante       ³±±
±±³          ³             Remetente                                      ³±±
±±³          ³cCdMunOri -> Municipio de origem calculado pelo DT6         ³±±
±±³          ³aPartDES  -> Array com as informacoes do participante       ³±±
±±³          ³cCdMunDes -> Municipio de destino calculado pelo DT6        ³±±
±±³          ³cAliasSFT -> Alias da tabela SFT posicionada no momento     ³±±
±±³          ³cPerfil   -> Variavel com o perfil de processamento         ³±±
±±³          ³lAchouDT5 -> Flag de posicionamento da tabela DT5           ³±±
±±³          ³cAliasDT5 -> Alias da tabela DT5 posicionada no momento     ³±±
±±³          ³lAchouDUL -> Flag de posicionamento da tabela DUL           ³±±
±±³          ³cAliasDUL -> Alias da tabela DUL posicionada no momento     ³±±
±±³          ³lAchouDTC -> Flag de posicionamento da tabela DTC           ³±±
±±³          ³cAliasDTC -> Alias da tabela DTC posicionada no momento     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function D161D162(cAlias,nRelac,cEspecie,aCmpAntSFT,cMvD162,lSpedRTms,aPartREM,cCdMunOri,aPartDES,cCdMunDes,;
							cAliasSFT,cPerfil,lAchouDT5,cAliasDT5,lAchouDUL,cAliasDUL,lAchouDTC,cAliasDTC,lAchou2DUL,cDTCChv)
Local aRegD161  := {}
Local aRegD162  := {}
Local nPos      := 0
Local cIndCg    := "0"
Local aRetPE    := {}
//Local aPar      := {}
Local cColCNPJ  := ""
Local cColIE    := ""
Local cCdMunCol := ""
Local cEntCNPJ  := ""
Local cEntIE    := ""
Local cCdMunEnt := ""
Local lRegD161  := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do indicador do tipo de carga.³
//³0=Rodoviario;                          ³
//³1=Ferroviario                          ³
//³2=Rodo-ferroviario                     ³
//³3=Aquaviario                           ³
//³4=Dutoviario                           ³
//³5=Aereo                                ³
//³9=Outros                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cEspecie=="09"
	cIndCg := "2"
ElseIf cEspecie=="10"
	cIndCg := "4"
ElseIf cEspecie=="11"
	cIndCg := "1"
ElseIf cEspecie=="26"
	cIndCg := "9"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³REGISTRO D161 - LOCAL DA COLETA E ENTREGA                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPerfil == "A"

	//-- Inicio da montagem do registro
	aAdd (aRegD161, {})
	nPos := Len(aRegD161)

	//-- Ponto de entrada para substituir o calculo do sistema
	If lSpedRTMS
		aRetPE := ExecBlock("SPEDRTMS",.F.,.F.,{nPos,"D161",cAliasSFT,aCmpAntSFT})
		If ValType(aRetPE) == "A" .And. Len(aRetPE) > 0
			aRegD161 := {}
			aEval(aRetPE,{|x| AAdd(aRegD161, x)})
		EndIf
	EndIf

	//-- Se nao foi alterado nada via PE, faco o padrao
	If Len(aRegD161[nPos])==0
		cColCNPJ  := ""
		cColIE    := ""
		cCdMunCol := ""
		cEntCNPJ  := ""
		cEntIE    := ""
		cCdMunEnt := ""
		lRegD161  := .F.

		//-- Busca endereco de coleta diferente do remetente
		If	lAchouDT5  
			If lAchou2DUL 
				cColCNPJ  := DUL->DUL_CGC
		   		cColIE    := DUL->DUL_INSCR
		   		cCdMunCol := UfCodIBGE(DUL->DUL_EST)+DUL->DUL_CODMUN   
		  	EndIf 
			If	!Empty(cColCNPJ) .And. cColCNPJ <> If(Empty(aPartREM[4]),aPartREM[5],aPartREM[4])
				lRegD161  := .T.
			EndIf
		EndIf

		//-- Busca endereco de entrega diferente do destinatario
		If	lAchouDUL
			cEntCNPJ  := (cAliasDUL)->DUL_CGC
			cEntIE    := (cAliasDUL)->DUL_INSCR
			cCdMunEnt := UfCodIBGE((cAliasDUL)->DUL_EST)+(cAliasDUL)->DUL_CODMUN
			If	!Empty(cEntCNPJ) .And. cEntCNPJ <> If(Empty(aPartDES[4]),aPartDES[5],aPartDES[4])
				lRegD161  := .T.
			EndIf
		EndIf
	EndIf
	
	If	lRegD161
		aAdd (aRegD161[nPos], "D161")			//01 - REG
		aAdd (aRegD161[nPos], cIndCg)			//02 - IND_CARGA
		aAdd (aRegD161[nPos], cColCNPJ)			//03 - CNPJ_COL
		aAdd (aRegD161[nPos], cColIE)			//04 - IE_COL
		aAdd (aRegD161[nPos], cCdMunCol)		//05 - COD_MUN_COL
		aAdd (aRegD161[nPos], cEntCNPJ)			//06 - CNPJ_ENTG
		aAdd (aRegD161[nPos], cEntIE)			//07 - IE_ENTG
		aAdd (aRegD161[nPos], cCdMunEnt)		//08 - COD_MUN_ENTG
	EndIf
	//-- Gravacao do registro no TRB
	If Len(aRegD161[nPos]) > 0
		GrvRegTrS(cAlias,nRelac,aRegD161)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³REGISTRO D162 - IDENTIFICACAO DOS DOCUMENTOS FISCAIS                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//-- Ponto de entrada para substituir o calculo do sistema
If lSpedRTMS
	aRetPE := ExecBlock("SPEDRTMS",.F.,.F.,{nPos,"D162",cAliasSFT,aCmpAntSFT})
	If ValType(aRetPE) == "A" .And. Len(aRetPE) > 0
		aEval(aRetPE,{|x| AAdd(aRegD162, x)})
		nPos := Len(aRegD162)
	EndIf
EndIf

//-- Se nao foi alterado nada via PE, faco o padrao
If Empty(aRegD162)

	If lAchouDTC
		//-- Parametro MV_NGD162 - Identifica os CFOP s, que nao gera registro D162.
		If !Alltrim(aCmpAntSFT[9])$cMvD162
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tabela jah estah filtrada³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			While !(cAliasDTC)->(Eof()) .AND. ( (cAliasDTC)->(DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE)==cDTCChv)
				//-- Tratamento para evitar duplicidade no registro.
				If (nPos := aScan(aRegD162,{|aX| aX[3]==(cAliasDTC)->DTC_SERNFC .And. aX[4]==(cAliasDTC)->DTC_NUMNFC}))==0
					aAdd (aRegD162, {})
					nPos := Len(aRegD162)
					aAdd (aRegD162[nPos], "D162")							//01 - REG
					aAdd (aRegD162[nPos], "01")								//02 - COD_MOD
					aAdd (aRegD162[nPos], (cAliasDTC)->DTC_SERNFC)			//03 - SER
					aAdd (aRegD162[nPos], (cAliasDTC)->DTC_NUMNFC)			//04 - NUM_DOC
					aAdd (aRegD162[nPos], (cAliasDTC)->DTC_EMINFC)			//05 - DT_DOC
					aAdd (aRegD162[nPos], (cAliasDTC)->DTC_VALOR)			//06 - VL_DOC
					aAdd (aRegD162[nPos], (cAliasDTC)->DTC_VALOR)			//07 - VL_MERC
					aAdd (aRegD162[nPos], (cAliasDTC)->DTC_QTDVOL)			//08 - QTD_VOL
					aAdd (aRegD162[nPos], (cAliasDTC)->DTC_PESO)			//09 - PESO_BRT
					aAdd (aRegD162[nPos], (cAliasDTC)->DTC_PESO)			//10 - PESO_LIQ
				Else
					aRegD162[nPos,06] += (cAliasDTC)->DTC_VALOR			//06 - VL_DOC
					aRegD162[nPos,07] += (cAliasDTC)->DTC_VALOR			//07 - VL_MERC
					aRegD162[nPos,08] += (cAliasDTC)->DTC_QTDVOL			//08 - QTD_VOL
					aRegD162[nPos,09] += (cAliasDTC)->DTC_PESO				//09 - PESO_BRT
					aRegD162[nPos,10] += (cAliasDTC)->DTC_PESO				//10 - PESO_LIQ
				EndIf
				(cAliasDTC)->(DbSkip())
			EndDo
			//-- Suprimir decimais: converte campo Volume (DTC_QTDVOL) para caracter
			AEval(aRegD162,{|x|x[8]:=Alltrim(Str(x[8]))})
		EndIf
	EndIf
EndIf
//-- Gravacao do registro no TRB
If !Empty(aRegD162) .And. Len(aRegD162[nPos]) > 0
	GrvRegTrS(cAlias,nRelac,aRegD162)
EndIf

Return
/*
±±³Programa  ³RegD190   ³ Autor ³Gustavo G. Rueda       ³ Data ³11.03.2011³±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³      REGISTRO ANALITICO DO DOCUMENTO (MODELO 07,08,26,27)  ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao do Registro D190                                  ³±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoes contidas no array   ³±±
±±³          ³ aRegC170(Itens) aglutinados CFOP, CST e ALIQ.              ³±±

±±³Nivel Hier³3(1:N) Para cada Registro D100                              ³±±

±±³Retorno   ³.T.                                                         ³±±

±±³Parametros³aRegC170  -> Informacoes dos Itens do documento fiscal      ³±±
±±³          ³cAliasSFT -> Alias da tabela SFT posicionada no momento     ³±±
±±³          ³aRegD190  -> Array contendo as informacoes aglutinadas do   ³±±
±±³          ³ do documento fiscal para posterior geracao na funcao prin- ³±±
±±³          ³ cipal.                                                     |±±
±±³          |lSpedRTms -> Flag de existencia do PE SPEDRTMS              ³±±
±±³          |aLanCDA   -> Lancamento do documento fiscal                 ³±±
±±³          ³nRedBSICM -> Valor de reducao da base de calculo do ICMS    |±±
±±³          ³aCmpAntSFT-> Informacoes de cabecalho do documento fiscal   ³±±
±±³          ³aReg0460  -> Array com a estrutura do 0460 gerado ateh o    ³±±
±±³          ³            momento.                                        ³±±
±±³          ³cAliasSF4-> Informa qual o alias da tabela SF4, podendo ser ³±±
±±³          ³            query                                           ³±±
±±³          ³aLancFis-> Array com lancamentos de documento nao amarrados³±±
±±³          ³            ao C197                                         ³±±
±±³          ³aReg0460  -> Array com a estrutura do 0460 gerado ateh o    ³±±
±±³          ³            momento.                                        ³±±
*/
Static Function RegD190(aRegC170,cAliasSFT,aRegD190,lSpedRTMS,aLanCDA,nRedBSICM,aCmpAntSFT,aReg0460,cAliasSF4,aLancFis,aReg0460)
Local nPos     := 0
Local aRetPE   := {}
Local cRetPE   := ""
Local cCodObs  := ""
Local lDefault := .T.
Local nPosIt   := 0  

Default aLancFis := {}

If (nPos := aScan(aRegD190,{|aX| aX[2]==aRegC170[1][10] .And. aX[3]==aRegC170[1][11] .And. aX[4]==aRegC170[1][14]}))==0

	aAdd(aRegD190, {})
	nPos := Len(aRegD190)

	//-- Ponto de entrada para substituir o calculo do sistema
	If lSpedRTMS
		aRetPE := ExecBlock("SPEDRTMS",.F.,.F.,{nPos,"D190",cAliasSFT,aCmpAntSFT})
		If ValType(aRetPE) == "A" .And. Len(aRetPE) > 0
			aRegD190 := {}
			aEval( aRetPE, {|x| AAdd(aRegD190, x) } )
			If Len(aRegD190[nPos]) > 0
				lDefault:= .F.
				If aExistBloc[14]
					For nPosIt := 1 To Len(aRegD190)
						//-- Ponto de entrada para gravar lancamentos de observacoes dos documentos
						cCodObs := aRegD190[nPosIt,9] //09 - COD_OBS
						cRetPE  := ExecBlock("SPEDR460",.F.,.F.,{cCodObs})
						If ValType(cRetPE) == "C"
							Reg0460(@aReg0460,{cCodObs,cRetPE})
						EndIf
					Next nPosIt
				EndIf
			EndIf
		EndIf
	EndIf

	//-- Se o PE nao montar o registro, executo o padrao
	If lDefault
		aAdd (aRegD190[nPos], "D190")						//01 - REG
		aAdd (aRegD190[nPos], aRegC170[1][10])				//02 - CST
		aAdd (aRegD190[nPos], aRegC170[1][11])				//03 - CFOP
		aAdd (aRegD190[nPos], aRegC170[1][14])				//04 - ALIQ_ICMS
		aAdd (aRegD190[nPos], 0)							//05 - VL_OPR
		aAdd (aRegD190[nPos], 0)							//06 - VL_BC_ICMS
		aAdd (aRegD190[nPos], 0)							//07 - VL_ICMS
		aAdd (aRegD190[nPos], 0)							//08 - VL_RED_BC
		aAdd (aRegD190[nPos], "")							//09 - COD_OBS
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se houver lancamento fiscal nao amarrado ao D197, devo prioriza-lo³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aLancFis)>=1
			aRegD190[nPos,9] := aLancFis[1,1]
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³REGISTRO 0460 - TABELA DE OBSERVACOES DO LANCAMENTO FISCAL      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   		Reg0460(@aReg0460,{aLancFis[1,1],aLancFis[1,2]})
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Quando este array estiver com conteudo, jah terah de todos os itens,³
		//³ neste caso, preciso obter somente o lancamento do referido item    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf Len(aLanCDA)>0 .And. (nPosIt := aScan(aLanCDA,{|aX|aX[14]==(cAliasSFT)->FT_ITEM}))>0
			aRegD190[nPos,9] := aLanCDA[nPosIt,7]
		EndIf
	EndIf
EndIf

//-- Execucao padrao
If lDefault
	aRegD190[nPos][5]		+=	(cAliasSFT)->FT_VALCONT	 		//05 - VL_OPR
	aRegD190[nPos][6]		+=	aRegC170[1][13]					//06 - VL_BC_ICMS
	aRegD190[nPos][7]		+=	aRegC170[1][15]					//07 - VL_ICMS
	aRegD190[nPos][8]		+=	nRedBSICM						//08 - VL_RED_BC
EndIf

Return
/*
±±³Programa  ³RegD500   ³ Autor ³Gustavo G. Rueda       ³ Data ³10.03.2011³±±

±±³Descri‡…o ³                                                            ³±±
±±³          ³  NOTA FISCAL DE SERVICO DE COMUNICACAO (MODELO 21) E NOTA  ³±±
±±³          ³      FISCAL DE SERVICO DE TELECOMUNICACAO (MODELO 22)      ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro D500                       ³±±

±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoe contidas no array    ³±±
±±³          ³ aRegC100/aTotaliza/aCmpAntSFT para os Modelos(21 e 22)     ³±±

±±³Nivel Hier³2(varios por arquivo)                                       ³±±

±±³Retorno   ³.T.                                                         ³±±

±±³Parametros³cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          ³nRelac -> Flag de relacionamento.                           ³±±
±±³          |aRegC100 -> Informacoes sobre todos documentos fiscais pro- ³±±
±±³          ³ cessados no while da funcao principal.                     ³±±
±±³          |aTotaliza -> Totalizadores de valores para a tabela SFT.    ³±±
±±³          |aCmpAntSFT -> Informacoes sobre o cabecalho dos documentos. ³±±
±±³          ³aRegD500 -> Array contendo as informacoes processadas pela  ³±±
±±³          ³ funcao a ser retornado para utilizacao pela funcao         ³±±
±±³          ³ principal                                                  ³±±
±±³          ³nItem -> Contador do item para cada documento fiscal.       ³±±
±±³          ³lAchouSFX -> Flag de localizacao do registro da NF na tabela³±±
±±³          ³ SFX.                                                       ³±±
±±³          ³aInfCompl -> Informacao complementar da tabela CDT          ³±±
*/
Static Function RegD500(cAlias,nRelac,aRegC100,aTotaliza,aCmpAntSFT,aRegD500,nItem,lAchouSFX,lGravaD500,cSituaDoc,aInfCompl,aWizard)
Local nPos    := 0
Local nVlTerc := 0
Local cTpAss  := ""
Local	cContCtb	:= RetCOD_CTA(,"D500", aCmpAntSFT )
Default cSituaDoc := ""
Default aWizard	:= {}

If lAchouSFX
	nVlTerc  := SFX->FX_VALTERC
	cTpAss   := SFX->FX_TPASSIN
EndIf
 		
aAdd(aRegD500, {})
nPos	:=	Len (aRegD500)
aAdd (aRegD500[nPos], "D500")			 	   					//01 - REG
aAdd (aRegD500[nPos], aRegC100[1][2])			   				//02 - IND_OPER
aAdd (aRegD500[nPos], aRegC100[1][3])	   						//03 - IND_EMIT
aAdd (aRegD500[nPos], IIF(cSituaDoc$"02#03#05","",aRegC100[1][4]))	//04 - COD_PART
aAdd (aRegD500[nPos], aRegC100[1][5])			   				//05 - COD_MOD
aAdd (aRegD500[nPos], aRegC100[1][6])	   						//06 - COD_SIT
aAdd (aRegD500[nPos], aRegC100[1][7])	   						//07 - SER
aAdd (aRegD500[nPos], "")										//08 - SUB
aAdd (aRegD500[nPos], aRegC100[1][8])	   			 			//09 - NUM_DOC
aAdd (aRegD500[nPos], aCmpAntSFT[6])			   				//10 - DT_DOC
aAdd (aRegD500[nPos], IIF(cSituaDoc$"02#03#05","",aRegC100[1][11]))	   						//11 - DT_A_P
aAdd (aRegD500[nPos], IIF(cSituaDoc$"02#03#05","",aRegC100[1][12]))			   				//12 - VL_DOC
aAdd (aRegD500[nPos], IIF(cSituaDoc$"02#03#05","",aRegC100[1][14]))	   						//13 - VL_DESC
aAdd (aRegD500[nPos], IIF(cSituaDoc$"02#03#05","",aRegC100[1][16]))	   						//14 - VL_SERV
aAdd (aRegD500[nPos], IIF(cSituaDoc$"02#03#05","",aRegC100[1][15]))  						//15 - VL_SERV_NT
aAdd (aRegD500[nPos], IIF(!(aRegC100[1][6]$"02#04#05"),nVlTerc,""))	//16 - VL_TERC
aAdd (aRegD500[nPos], IIF(cSituaDoc$"02#03#05","",aRegC100[1][20]))			   				//17 - VL_DA
aAdd (aRegD500[nPos], IIF(cSituaDoc$"02#03#05","",aRegC100[1][21]))	   						//18 - VL_BC_ICMS
aAdd (aRegD500[nPos], IIF(cSituaDoc$"02#03#05","",aRegC100[1][22]))	   						//19 - VL_ICMS
aAdd (aRegD500[nPos], Iif(Len(aInfCompl)>0,aInfCompl[1],""))									//20 - COD_INF
aAdd (aRegD500[nPos], Iif("1"$aWizard[1][15],IIF(cSituaDoc$"02#03#05","",Iif(aRegC100[1][26]>0, aRegC100[1][26],"")),""))	   						//21 - VL_PIS
aAdd (aRegD500[nPos], Iif("1"$aWizard[1][15],IIF(cSituaDoc$"02#03#05","",Iif(aRegC100[1][27]>0, aRegC100[1][27],"")),""))	   						//22 - VL_COFINS
aAdd (aRegD500[nPos], IIF(cSituaDoc$"02#03#05","",Iif(!Empty(cContCtb),cContCtb,aCmpAntSFT[19])))	   						//23 - COD_CTA  	
aAdd (aRegD500[nPos], IIF(cSituaDoc$"02#03#05","",If(cVersao >= "003",cTpAss,"")))	//24 - TP_ASSINANTE - LAYOUT 2010

If lGravaD500
	GrvRegTrS(cAlias,nRelac,aRegD500,nItem)
EndIF

Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegD510   ³ Autor ³Gustavo G. Rueda       ³ Data ³10.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³           ITENS DO DOCUMENTO (MODELOS 21 E 22)             ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro D510                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoes contidas no array   ³±±
±±³          ³ aRegC170/aPartDoc para os Modelos(21 e 22) .               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3(1:N) Para cada D500                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          ³nRelac -> Flag de relacionamento.                           ³±±
±±³          |aRegC170 -> Informacoes sobre os itens dos documentos       ³±±
±±³          ³  fiscais processados no while da funcao principal.         ³±±
±±³          |aRegD510 -> Array contendo a estrutura do registro gravado  ³±±
±±³          | para utilizacao pelo funcao principal.                     ³±±
±±³          ³aPartDoc -> Array com informacoes sobre o participante do   ³±±
±±³          ³ documento fiscal, este array eh montado pela funcao        ³±±
±±³          ³ principal                                                  ³±±
±±³          ³nItem -> Contador do item para cada documento fiscal.       ³±±
±±³          ³lAchouSFX -> Flag de retorno do seek para a tabela SFX      ³±±
±±³          ³cEntSai -> Flag de entrada=1/Saida=2                        ³±±
±±³          ³lGravaD500 -> Flag que determina a gravacao do registro D500³±±
±±³          ³cPerfil    -> Variavel com o perfil de processamento        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegD510(cAlias,nRelac,aRegC170,aRegD510,aPartDoc,nItem,lAchouSFX,cEntSai,lGravaD500,cPerfil,lGrava0200,aWizard)
	Local	nPos		:=	0
	Local	cCodClass	:=	""
	Local	cIndRec		:=	""
	Default aWizard		:= {}

	If lAchouSFX
		If TamSx3("FX_GRPCLAS")[1] == 2
			cCodClass	:= SFX->FX_GRPCLAS+SFX->FX_CLASSIF
		Else
			cCodClass	:= Iif("A"$SFX->FX_GRPCLAS,"10","0"+SFX->FX_GRPCLAS)+SFX->FX_CLASSIF
		EndIf
		cIndRec		:= SFX->FX_TIPOREC
	EndIf

	aAdd(aRegD510, {})
	nPos	:=	Len (aRegD510)
	aAdd (aRegD510[nPos], "D510")	 	   					//01 - REG
	aAdd (aRegD510[nPos], aRegC170[1][2])	   				//02 - NUM_ITEM
	aAdd (aRegD510[nPos], aRegC170[1][3])	   				//03 - COD_ITEM
	aAdd (aRegD510[nPos], cCodClass)						//04 - COD_CLASS
	aAdd (aRegD510[nPos], aRegC170[1][5][1])  				//05 - QTD
	aAdd (aRegD510[nPos], aRegC170[1][6])	   				//06 - UNID
	aAdd (aRegD510[nPos], aRegC170[1][7])	   				//07 - VL_ITEM
	aAdd (aRegD510[nPos], aRegC170[1][8])	   				//08 - VL_DESC
	aAdd (aRegD510[nPos], aRegC170[1][10])	   				//09 - CST_ICMS
	aAdd (aRegD510[nPos], aRegC170[1][11])	   				//10 - CFOP
	aAdd (aRegD510[nPos], aRegC170[1][13])	   				//11 - VL_BC_ICMS
	aAdd (aRegD510[nPos], aRegC170[1][14])	   				//12 - ALIQ_ICMS
	aAdd (aRegD510[nPos], aRegC170[1][15])	   				//13 - VL_ICMS
	aAdd (aRegD510[nPos], aRegC170[1][16])	   				//14 - VL_BC_ICMS_ST
	aAdd (aRegD510[nPos], aRegC170[1][18])	   				//15 - VL_ICMS_ST
	aAdd (aRegD510[nPos], cIndRec )							//16 - IND_REC
	aAdd (aRegD510[nPos], aPartDoc[1])	   					//17 - COD_PART
	aAdd (aRegD510[nPos], Iif("1"$aWizard[1][15],IIf(aRegC170[1][30]>0,aRegC170[1][30],""),"")) 	   				//18 - VL_PIS
	aAdd (aRegD510[nPos], Iif("1"$aWizard[1][15],IIf(aRegC170[1][36]>0,aRegC170[1][36],""),""))	   				//19 - VL_COFINS
	aAdd (aRegD510[nPos], aRegC170[1][37])	   				//20 - COD_CTA

	If lGravaD500 .And. cEntSai=="2"
		GrvRegTrS(cAlias,nRelac,{aRegD510[nPos]},nItem)
		lGrava0200 := .T.
	EndIf
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegD530   ³ Autor ³Gustavo G. Rueda       ³ Data ³10.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³           TERMINAL FATURADO (MODELOS 21 E 22)              ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro D530                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoes contidas na tabela  ³±±
±±³          ³ SFX posicionada.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3(1:1) Para cada D500                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          ³nRelac -> Flag de relacionamento.                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegD530 (cAlias, nRelac)
	Local	nPos		:=	0
	Local	aReg		:=	{}

	aAdd(aReg, {})
	nPos	:=	Len (aReg)
	aAdd (aReg[nPos], "D530")	 	   					//01 - REG
	aAdd (aReg[nPos], SFX->FX_TIPSERV)	   				//02 - IND_SERV
	aAdd (aReg[nPos], SFX->FX_DTINI)	   				//03 - DT_INI_SERV
	aAdd (aReg[nPos], SFX->FX_DTFIM)	   	 			//04 - DT_FIN_SERV
	aAdd (aReg[nPos], SFX->FX_PERFIS)	   				//05 - PER_FISCAL
	aAdd (aReg[nPos], SFX->FX_AREATER)	   				//06 - COD_AREA
	aAdd (aReg[nPos], SFX->FX_TERMINA)	   				//07 - TERMINAL

	GrvRegTrS(cAlias,nRelac,aReg)
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegD590   ³ Autor ³Gustavo G. Rueda       ³ Data ³10.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³      REGISTRO ANALITICO DO DOCUMENTO (MODELO 07,08,26,27)  ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao do Registro D590                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoes contidas no array   ³±±
±±³          ³ aRegC170(Itens) aglutinados CFOP, CST e ALIQ.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3(1:N) Para cada Registro D100                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aRegC170 -> Informacoes dos Itens do documento fiscal       ³±±
±±³          ³cAliasSFT -> Alias da tabela SFT posicionada no momento     ³±±
±±³          ³aRegD590 -> Array contendo as informacoes aglutinadas do    ³±±
±±³          ³ do documento fiscal para posterior geracao na funcao prin- ³±±
±±³          ³ cipal.                                                     |±±
±±³          ³aLanCDA - array com os lancamentos do documento fiscal      ³±±
±±³          ³nRedBSICM -> Valor de reducao da base de calculo do ICMS    |±±
±±³          ³cAliasSF4-> Informa qual o alias da tabela SF4, podendo ser ³±±
±±³          ³            query                                           ³±±
±±³          ³aLancFis-> Array com lancamentos de documento nao amarrados³±±
±±³          ³            ao C197                                         ³±±
±±³          ³aReg0460  -> Array com a estrutura do 0460 gerado ateh o    ³±±
±±³          ³            momento.                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegD590(aRegC170,cAliasSFT,aRegD590,aLanCDA,nRedBSICM,cSituaDoc,cAliasSF4,aLancFis,aReg0460)
Local	nPos		:=	0

If (nPos := aScan(aRegD590,{|aX| aX[2]==aRegC170[1][10] .And. aX[3]==aRegC170[1][11] .And. aX[4]==aRegC170[1][14]}) )==0
	aAdd(aRegD590, {})
	nPos	:=	Len (aRegD590)
	aAdd (aRegD590[nPos], "D590")	 	   				//01 - REG
	aAdd (aRegD590[nPos], aRegC170[1][10])				//02 - CST
	aAdd (aRegD590[nPos], aRegC170[1][11])				//03 - CFOP
	aAdd (aRegD590[nPos], aRegC170[1][14])				//04 - ALIQ_ICMS
	aAdd (aRegD590[nPos], 0)		 		 			//05 - VL_OPR
	aAdd (aRegD590[nPos], 0)							//06 - VL_BC_ICMS
	aAdd (aRegD590[nPos], 0)	 		  				//07 - VL_ICMS
	aAdd (aRegD590[nPos], 0)	 						//08 - VL_BC_ICMS_ST
	aAdd (aRegD590[nPos], 0)	 		  				//09 - VL_ICMS_ST
	aAdd (aRegD590[nPos], 0)	 		  				//10 - VL_RED_BC
	aAdd (aRegD590[nPos], "")	 						//11 - COD_OBS
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se houver lancamento fiscal nao amarrado ao C197, devo prioriza-lo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aLancFis)>=1
		aRegD590[nPos,11] := aLancFis[1,1]
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REGISTRO 0460 - TABELA DE OBSERVACOES DO LANCAMENTO FISCAL      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   		IF(!EMPTY(aLancFis[1,2]) .AND. !EMPTY(aLancFis[1,3]))
	   			Reg0460(@aReg0460,{aLancFis[1,1],aLancFis[1,2]})
		ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quando este array estiver com conteudo, jah terah de todos os itens,³
	//³ neste caso, preciso obter somente o lancamento do referido item    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf Len(aLanCDA)>0 .And. (nPosIt := aScan(aLanCDA,{|aX|aX[14]==(cAliasSFT)->FT_ITEM}))>0
		aRegD590[nPos,11]  :=  aLanCDA[nPosIt,7]
	EndIf
EndIf
aRegD590[nPos][5]	+=	(cAliasSFT)->FT_VALCONT	 					//05 - VL_OPR
aRegD590[nPos][6]	+=	Iif(cSituaDoc$"02#04#05#03",0,aRegC170[1][13])//06 - VL_BC_ICMS
aRegD590[nPos][7]	+=	Iif(cSituaDoc$"02#04#05#03",0,aRegC170[1][15])//07 - VL_ICMS
aRegD590[nPos][8]	+=	Iif(cSituaDoc$"02#04#05#03",0,aRegC170[1][16])//08 - VL_BC_ICMS_ST
aRegD590[nPos][9]	+=	Iif(cSituaDoc$"02#04#05#03",0,aRegC170[1][18])//09 - VL_ICMS_ST
aRegD590[nPos][10]	+=	nRedBSICM									//10 - VL_RED_BC

Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |D600D610  ³ Autor ³Gustavo G. Rueda       ³ Data ³10.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³D600 - CONSOLIDACAO DE NOTA FISCAL DE SERVICO DE COMUNICACAO³±±
±±³          ³  (MODELO 21) E NOTA FISCAL DE SERVICO DE TELECOMUNICACAO   ³±±
±±³          ³                           (MODELO 22)                      ³±±
±±³          ³                                                            ³±±
±±³          ³   D610 - ITENS CONSOLIDADO DE NOTA FISCAL DE SERVICO DE    ³±±
±±³          ³    COMUNICACAO (MODELO 21) E NOTA FISCAL DE SERVICO DE     ³±±
±±³          ³                TELECOMUNICACAO (MODELO 22)                 ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao do Registro D600 e D610                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoe contidas no array    ³±±
±±³          ³ aRegD500/aRegD510/aTotaliza/aPartDoc/aCmpAntSFT para os mo-³±±
±±³          ³ delos 21 e 22 que serao gravados no final da funcao        ³±±
±±³          ³ principal                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³D600 - 2(varios por arquivo)                                ³±±
±±³          ³D610 - 3(1:N) Para cada D600                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³nPos                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|aRegD500 -> Informacoes ja gravadas no registro D500 para   ³±±
±±³          ³ utilizacao.                                                ³±±
±±³          |aTotaliza -> Totalizadores de valores para a tabela SFT.    ³±±
±±³          ³aPartDoc -> Array com informacoes sobre o participante do   ³±±
±±³          ³ documento fiscal, este array eh montado pela funcao princi-³±±
±±³          ³ pal.                                                       ³±±
±±³          |aCmpAntSFT -> Informacoes sobre o cabecalho dos documentos. ³±±
±±³          ³aRegD600 -> Array contendo as informacoes processadas pela  ³±±
±±³          ³ funcao a ser retornado para gravacao pela funcao principal.³±±
±±³          ³aRegD510 -> Informacoes ja gravadas no registro D510 para   ³±±
±±³          ³ utilizacao.                                                ³±±
±±³          ³aRegD610 -> Array contendo as informacoes processadas pela  ³±±
±±³          ³ funcao a ser retornado para gravacao pela funcao principal.³±±
±±³          ³lAchouSFX -> Flag de posicionamento da tabela SFX           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function D600D610(aRegD500,aPartDoc,aCmpAntSFT,aRegD600,aRegD510,aRegD610,lAchouSFX,aWizard)
	Local	nPos		:=	0
	Local	nPos2		:=	0
	Local	nI			:=	0
	Local	cCodCons	:=	""
	Default aWizard		:= {}

	If lAchouSFX
		cCodCons := SFX->FX_CLASCON
	EndIf
   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³REGISTRO D600 - CONSOLIDACAO DE NOTA FISCAL DE SERVICO DE COMUNICACAO (MODELO 21) E NOTA FISCAL DE SERVICO DE TELECOMUNICACAO (MODELO 22)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(aCmpAntSFT[7])	//NOTA FISCAL CANCELADA.
		If (nPos := aScan(aRegD600,{|aX| aX[2]==aRegD500[1][5] .And. aX[3]==aPartDoc[7] .And. aX[4]==aRegD500[1][7] .And. aX[6]==cCodCons .And. aX[8]==aRegD500[1][10]}))==0
			aAdd(aRegD600, {})
			nPos	:=	Len (aRegD600)
			aAdd (aRegD600[nPos], "D600")	 	 	  					//01 - REG
			aAdd (aRegD600[nPos], aRegD500[1][5]) 	   					//02 - COD_MOD
			aAdd (aRegD600[nPos], aPartDoc[7]) 		   					//03 - COD_MUN
			aAdd (aRegD600[nPos], aRegD500[1][7]) 	   					//04 - SER
			aAdd (aRegD600[nPos], "" )			 	   					//05 - SUB
			aAdd (aRegD600[nPos], cCodCons)				 	   			//06 - COD_CONS
			aAdd (aRegD600[nPos], "1")	 	   							//07 - QTD_CONS
			aAdd (aRegD600[nPos], aRegD500[1][10])						//08 - DT_DOC
			aAdd (aRegD600[nPos], aRegD500[1][12])						//09 - VL_DOC
			aAdd (aRegD600[nPos], aRegD500[1][13])	  					//10 - VL_DESC
			aAdd (aRegD600[nPos], aRegD500[1][14])						//11 - VL_SERV
			aAdd (aRegD600[nPos], aRegD500[1][15])						//12 - VL_SERV_N
			aAdd (aRegD600[nPos], aRegD500[1][16])						//13 - VL_TERC
			aAdd (aRegD600[nPos], aRegD500[1][17])						//14 - VL_DA
			aAdd (aRegD600[nPos], aRegD500[1][18])						//15 - VL_BC_ICMS
			aAdd (aRegD600[nPos], aRegD500[1][19])						//16 - VL_ICMS
			aAdd (aRegD600[nPos], Iif("1"$aWizard[1][15],aRegD500[1][21],""))	//17 - VL_PIS
			aAdd (aRegD600[nPos], Iif("1"$aWizard[1][15],aRegD500[1][22],""))	//18 - VL_COFINS
		Else
			aRegD600[nPos][7]	:=	Alltrim(STR(Val(aRegD600[nPos][7])+1))	//07 - QTD_CONS
			aRegD600[nPos][9]	+=	aRegD500[1][12]						//09 - VL_DOC
			aRegD600[nPos][10]	+=	aRegD500[1][13]						//10 - VL_DESC
			aRegD600[nPos][11]	+=	aRegD500[1][14]						//11 - VL_SERV
			aRegD600[nPos][12]	+=	aRegD500[1][15]						//12 - VL_SERV_N
			aRegD600[nPos][13]	+=	aRegD500[1][16]						//13 - VL_TERC
			aRegD600[nPos][14]	+=	aRegD500[1][17]						//14 - VL_DA
			aRegD600[nPos][15]	+=	aRegD500[1][18]						//15 - VL_BC_ICMS
			aRegD600[nPos][16]	+=	aRegD500[1][19]						//16 - VL_ICMS
			If ("1"$aWizard[1][15] .And. aRegD500[1][21] > 0)
				aRegD600[nPos][17] += aRegD500[1][21]		//17 - VL_PIS
			Else
				aRegD600[nPos][17] := ""					//17 - VL_PIS
			EndIf
	
			If ("1"$aWizard[1][15] .And. aRegD500[1][22] > 0)
				aRegD600[nPos][18] += aRegD500[1][22]		//18 - VL_COFINS
			Else
				aRegD600[nPos][18] := ""					//18 - VL_COFINS
			EndIf
			If(aRegD600[nPos][17]==0)
				aRegD600[nPos][17] := ""
			EndIf
			If(aRegD600[nPos][18]==0)
				aRegD600[nPos][18] := ""
			EndIf

		EndIf
	
		//³REGISTRO D610 - ITENS CONSOLIDADO DE NOTA FISCAL DE SERVICO DE COMUNICACAO (MODELO 21) E NOTA FISCAL DE SERVICO DE TELECOMUNICACAO (MODELO 22)³
		For nI := 1 To Len (aRegD510)
			If (nPos2 := aScan(aRegD610,{|aX| aX[1]==nPos .And. aX[3]==aRegD510[nI][4] .And. aX[4]==aRegD510[nI][3] .And. aX[11]==aRegD510[nI][12] .And. aX[10]==aRegD510[nI][10]}))==0
				aAdd(aRegD610, {})
				nPos2	:=	Len (aRegD610)
				aAdd (aRegD610[nPos2], nPos)	 	 	  				//00 - RELACIONAMENTO COM O REGISTRO D600
				aAdd (aRegD610[nPos2], "D610")	 	 	  				//01 - REG
				aAdd (aRegD610[nPos2], aRegD510[nI][4])	  			//02 - COD_CLASS
				aAdd (aRegD610[nPos2], aRegD510[nI][3])	  			//03 - COD_ITEM
				aAdd (aRegD610[nPos2], aRegD510[nI][5])				//04 - QTD
				aAdd (aRegD610[nPos2], aRegD510[nI][6])	  			//05 - UNID
				aAdd (aRegD610[nPos2], aRegD510[nI][7])	 	  		//06 - VL_ITEM
				aAdd (aRegD610[nPos2], aRegD510[nI][8])	 	  		//07 - VL_DESC
				aAdd (aRegD610[nPos2], aRegD510[nI][9]) 	  			//08 - CST_ICMS
				aAdd (aRegD610[nPos2], aRegD510[nI][10]) 	  			//09 - CFOP
				aAdd (aRegD610[nPos2], aRegD510[nI][12]) 	  			//10 - ALIQ_ICMS
				aAdd (aRegD610[nPos2], aRegD510[nI][11])	 			//11 - VL_BC_ICMS
				aAdd (aRegD610[nPos2], aRegD510[nI][13])			 	//12 - VL_ICMS
				aAdd (aRegD610[nPos2], aRegD510[nI][14])	 			//13 - VL_BC_ICMS_ST
				aAdd (aRegD610[nPos2], aRegD510[nI][15])			 	//14 - VL_ICMS_ST
				aAdd (aRegD610[nPos2], 0)	 			  				//15 - VL_RED_BC_ICMS
				aAdd (aRegD610[nPos2], Iif("1"$aWizard[1][15],aRegD510[nI][18],""))	 			//16 - VL_PIS
				aAdd (aRegD610[nPos2], Iif("1"$aWizard[1][15],aRegD510[nI][19],""))			 	//17 - VL_COFINS
				aAdd (aRegD610[nPos2], aRegD510[nI][20])	  			//18 - COD_CTA
			Else				 			
				aRegD610[nPos2][05] += aRegD510[nI][05]	 			//04 - QTD
				aRegD610[nPos2][07] += aRegD510[nI][07]	 			//06 - VL_ITEM
				aRegD610[nPos2][08] += aRegD510[nI][08]	 			//07 - VL_DESC
				aRegD610[nPos2][12] += aRegD510[nI][11]	 			//11 - VL_BC_ICMS
				aRegD610[nPos2][13] += aRegD510[nI][13]			 	//12 - VL_ICMS
				aRegD610[nPos2][14] += aRegD510[nI][14]	 			//13 - VL_BC_ICMS_ST
				aRegD610[nPos2][15] += aRegD510[nI][15]			 	//14 - VL_ICMS_ST
				If ("1"$aWizard[1][15] .And. aRegD510[nI][18] > 0)
					aRegD610[nPos2][17] += aRegD510[nI][18]		//16 - VL_PIS
				Else
					aRegD610[nPos2][17] := ""						//16 - VL_PIS
				EndIf
	
				If ("1"$aWizard[1][15] .And. aRegD510[nI][19] >0)
					aRegD610[nPos2][18] += aRegD510[nI][19]		//17 - VL_COFINS	
				Else
					aRegD610[nPos2][18] := ""						//17 - VL_COFINS	
				EndIf			
			
			EndIf		
		Next nI
	EndIf
Return nPos
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegD690   ³ Autor ³Gustavo G. Rueda       ³ Data ³10.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³      REGISTRO ANALITICO DO DOCUMENTO (MODELO 07,08,26,27)  ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao do Registro D690                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoes contidas no array   ³±±
±±³          ³ aRegD590(Itens) aglutinados CFOP, CST e ALIQ.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3(1:N) Para cada Registro D100                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aRegD590 -> Array base para geracao deste registro          ³±±
±±³          ³cAlias -> Alias do arquivo de trabalho para gravacao das    |±±
±±³          ³ informacoes do registro                                    |±±
±±³          ³aRegD690  -> Array para gravacao dos valores do registro    |±±
±±³			 ³ "D690".													  |±±
±±³          ³nPosD600  -> Posicao do registro pai "D600"                 |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegD690(aRegD590,cAlias,aRegD690,nPosD600)
Local	nPos		:=	0
Local	nI			:=	0

For nI := 1 To Len(aRegD590)
	If (nPos := aScan(aRegD690,{|aX| aX[1]==nPosD600 .And. aX[3]==aRegD590[nI][02] .And. aX[4]==aRegD590[nI][03] .And. aX[5]==aRegD590[nI][04]}))==0
		aAdd(aRegD690, {})
		nPos	:=	Len (aRegD690)  
		aAdd (aRegD690[nPos], nPosD600)	 	   				//01 - RELACIONAMENTO
		aAdd (aRegD690[nPos], "D690")	 	   				//02 - REG
		aAdd (aRegD690[nPos], aRegD590[nI][02])			//03 - CST
		aAdd (aRegD690[nPos], aRegD590[nI][03])			//04 - CFOP
		aAdd (aRegD690[nPos], aRegD590[nI][04])			//05 - ALIQ_ICMS
		aAdd (aRegD690[nPos], 0)		 		 			//06 - VL_OPR
		aAdd (aRegD690[nPos], 0)							//07 - VL_BC_ICMS
		aAdd (aRegD690[nPos], 0)	 		  				//08 - VL_ICMS
		aAdd (aRegD690[nPos], 0)	 						//09 - VL_BC_ICMS_ST
		aAdd (aRegD690[nPos], 0)	 		  				//10 - VL_ICMS_ST
		aAdd (aRegD690[nPos], 0)	 		  				//11 - VL_RED_BC
		aAdd (aRegD690[nPos], aRegD590[nI][11])			//12 - COD_OBS
	EndIf
	
	//        
	aRegD690[nPos][6]	+=	aRegD590[nI][05]	 	  		//06 - VL_OPR
	aRegD690[nPos][7]	+=	aRegD590[nI][06]				//07 - VL_BC_ICMS
	aRegD690[nPos][8]	+=	aRegD590[nI][07]				//08 - VL_ICMS
	aRegD690[nPos][9]	+=	aRegD590[nI][08]				//09 - VL_BC_ICMS_ST
	aRegD690[nPos][10]	+=	aRegD590[nI][09]				//10 - VL_ICMS_ST
	aRegD690[nPos][11]	+=	aRegD590[nI][10]				//11 - VL_RED_BC
Next nI


Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |D695D696  ³ Autor ³Gustavo G. Rueda       ³ Data ³10.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³D696 - REGISTRO ANALITICO DO DOCUMENTO (MODELOS 21 e 22 )   ³±±
±±³          ³D695 - CONSOLIDACAO DOS DOCUMENTOS NFSC ou NFST EMITIDA     ³±±
±±³          ³       EM VIA UNICA (CPN. ICMS 115/03)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoe contidas na tabela   ³±±
±±³          ³ SFT.                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³D696 - 3(1:N) Para cada D695                                ³±±
±±³           D697 - 4(1:N) Para cada D696                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|aRegD696 -> Array com as informacoes acumuladas             ³±±
±±³          ³aRegD695 -> Array com as informacoes acumuladas             ³±±
±±³          ³lAchouSFX-> Flag de posicionamento da tabela SFX            ³±±
±±³          ³aRegD590 -> Array base para geracao do registro D696        ³±±
±±³          ³aRegC100 -> Array base para geracao do registro D695        ³±±
±±³          ³aCmpAntSFT-> Campos salvos da tabela SFT antes do skip      ³±±
±±³          ³aRegD697 -> Array com as informacoes do registro D697       ³±±
±±³          ³cSituaDoc -> Situacao do documento fiscal                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function D695D696(aRegD696,aRegD695,lAchouSFX,aRegD590,aRegC100,aCmpAntSFT,aRegD697,cSituaDoc)
Local	nPos	:=	0
Local	nPos1	:=	0
Local   nPos2   :=  0
Local	cChv115	:=	""
Local	cVol115	:=	""
Local	nI		:=	0
	
If !cSituaDoc$"02#03"		
	If lAchouSFX
		cChv115	:=	SFX->FX_CHV115
		cVol115	:=	SFX->FX_VOL115	
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³REGISTRO C700 - CONSOLIDACAO                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nPos1 := aScan(aRegD695,{|aX| aX[3]==aRegC100[1][7] .And. aX[9]==cChv115}))==0
		aAdd (aRegD695, {})
		nPos1	:=	Len (aRegD695)
		aAdd (aRegD695[nPos1], "D695")						//01 - REG
		aAdd (aRegD695[nPos1], aRegC100[1][5])				//02 - COD_MOD
		aAdd (aRegD695[nPos1], aRegC100[1][7])	   			//03 - SER
		aAdd (aRegD695[nPos1], aRegC100[1][8])	   	 		//04 - NRO_INI
		aAdd (aRegD695[nPos1], aRegC100[1][8])				//05 - NRO_FIN
		aAdd (aRegD695[nPos1], aCmpAntSFT[6])	   	 		//06 - DT_DOC_INI
		aAdd (aRegD695[nPos1], aCmpAntSFT[6])	   	 		//07 - DT_DOC_FIM
		aAdd (aRegD695[nPos1], cVol115) 					//08 - NOM_MEST
		aAdd (aRegD695[nPos1], cChv115)						//09 - CHV_COD_DIG
	EndIf
	aRegD695[nPos1][5]	:=	aRegC100[1][8]					//05 - NRO_FIN
	aRegD695[nPos1][7]	:=	aCmpAntSFT[6]		   			//07 - DT_DOC_FIM
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³REGISTRO D696 - REGISTRO ANALITICO DOS DOCUMENTOS                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 To Len(aRegD590)
		If (nPos := aScan(aRegD696,{|aX| aX[1]==nPos1 .And. aX[3]==aRegD590[nI][02] .And. aX[4]==aRegD590[nI][03] .And. aX[5]==aRegD590[nI][04]}))==0
			aAdd(aRegD696, {})
			nPos	:=	Len (aRegD696)
			aAdd (aRegD696[nPos], nPos1)	 	   				//01 - Relacionamento
			aAdd (aRegD696[nPos], "D696")	 	   				//02 - REG
			aAdd (aRegD696[nPos], aRegD590[nI][02])			//03 - CST
			aAdd (aRegD696[nPos], aRegD590[nI][03])			//04 - CFOP
			aAdd (aRegD696[nPos], aRegD590[nI][04])			//05 - ALIQ_ICMS
			aAdd (aRegD696[nPos], 0)		 		 			//06 - VL_OPR
			aAdd (aRegD696[nPos], 0)							//07 - VL_BC_ICMS
			aAdd (aRegD696[nPos], 0)	 		  				//08 - VL_ICMS
			aAdd (aRegD696[nPos], 0)	 						//09 - VL_BC_ICMS_ST
			aAdd (aRegD696[nPos], 0)	 		  				//10 - VL_ICMS_ST
			aAdd (aRegD696[nPos], 0)	 		  				//11 - VL_RED_BC
			aAdd (aRegD696[nPos], aRegD590[nI][11])			//12 - COD_OBS
		EndIf
		//
		aRegD696[nPos][6]	+=	aRegD590[nI][05]	 	  		//06 - VL_OPR
		aRegD696[nPos][7]	+=	aRegD590[nI][06]				//07 - VL_BC_ICMS
		aRegD696[nPos][8]	+=	aRegD590[nI][07]				//08 - VL_ICMS
		aRegD696[nPos][9]	+=	aRegD590[nI][08]				//09 - VL_BC_ICMS_ST
		aRegD696[nPos][10]	+=	aRegD590[nI][09]				//10 - VL_ICMS_ST
		aRegD696[nPos][11]	+=	aRegD590[nI][10]				//11 - VL_RED_BC
		
	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	    //³REGISTRO D697 - REGISTRO SERVICOS NAO MEDIDOS DE TELEVISAO POR ASSINATURA POR UF ³
	    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    If lAchouSFX
		    If (SFX->FX_GRPCLAS=="A" .And. SFX->FX_CLASSIF=="03") .Or. SFX->FX_GRPCLAS=="10" .And. SFX->FX_CLASSIF=="03"	
	           	If (nPos2 := aScan(aRegD697,{|aX| aX[3]==aCmpAntSFT[23]}))==0			
	  		        aAdd (aRegD697, {})
				    nPos2	:=	Len (aRegD697)
				    aAdd (aRegD697[nPos2], nPos)	 	   				//01 - Relacionamento
				    aAdd (aRegD697[nPos2], "D697")						//02 - REG
				    aAdd (aRegD697[nPos2], aCmpAntSFT[23])				//03 - UF
	  				aAdd (aRegD697[nPos2], 0)   	   			        //04 - VL_BC_ICMS
				    aAdd (aRegD697[nPos2], 0)	   	 		            //05 - VL_ICMS		    
			    EndIf
				aRegD697[nPos2][04]	+=	aRegD696[nPos][7]			    //04 - VL_BC_ICMS
				aRegD697[nPos2][05]	+=	aRegD696[nPos][8]			    //05 - VL_ICMS
		    EndIf
		EndIf
	Next nI         
EndIf
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³BlocoE    | Autor ³Gustavo G. Rueda 			   ³ Data ³22.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³                        GERACAO DO BLOCO E                         ³±± 
±±³          ³REGISTRO E100 - PERIODO DA APURACAO DO ICMS                        ³±± 
±±³          ³REGISTRO E110 - APURACAO DE ICMS - OPERACOES PROPRIAS              ³±± 
±±³          ³REGISTRO E111 - AJUSTES/BENEFICIOS/INCENTIVO DA APURACAO DE ICMS   ³±± 
±±³          ³REGISTRO E112 - INFORMACOES ADICIONAIS DOS AJUSTES DE APURACAO DO  ³±± 
±±³          ³                ICMS                                               ³±± 
±±³          ³REGISTRO E115- INF. ADICIONAIS DA APURACAO DO ICMS                 ³±± 
±±³          ³REGISTRO E116 - OBRIGACOES DO ICMS A RECOLHER - OPERACOES PROPRIAS ³±± 
±±³          ³REGISTRO E200 - PERIODO DA APURACAO DO ICMS ST                     ³±± 
±±³          ³REGISTRO E210 - APURACAO DO ICMS - SUBSTITUICAO TRIBUTARIA         ³±±  
±±³          ³REGISTRO E220 - AJUSTES/BENEFICIOS/INCENTIVOS DA APURACAO DO ICMS  ³±± 
±±³          ³                SUBSTITUICAO TRIBUTARIA                            ³±±  
±±³          ³REGISTRO E230 - INFORMACOES ADICIONAIS DOS AJUSTES DE APURACAO DO  ³±± 
±±³          ³                ICMS SUBSTITUICAO TRIBUTARIA                       ³±±  
±±³          ³REGISTRO E250 - OBRIGACOES DO ICMS A RECOLHER - SUBSTITUICAO       ³±± 
±±³          ³                TRIBUTARIA                                         ³±± 
±±³          ³REGISTRO E500 - PERIODO DA APURACAO DO IPI                         ³±± 
±±³          ³REGISTRO E510 - CONSOLIDACAO DOS VALROES DE IPI POR CFOP E CODIGO  ³±±
±±³          ³                DE TRIBUTACAO DO IPI                               ³±±
±±³          ³REGISTRO E520 - APURACAO DO IPI                                    ³±±
±±³          ³REGISTRO E530 - AJUSTES DA APURACAO DO IPI                         ³±±
±±³          ³                                                                   ³±±
±±³          ³Funcao utilizada para montar a estrutura dos registros acima e     ³±±
±±³          ³  gravar no TRB para geracao do TXT                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lTabComp - Flag de existencia das tabelas complementares           ³±±
±±³          ³aWizard  - Informacoes do assistente da rotina                     ³±±
±±³          ³cFilDe   - Filial inicial para processament multifilial            ³±±
±±³          ³cFilAte  - Filial final para processament multifilial              ³±±
±±³          ³cAlias   - Alias do TRB                                            ³±±
±±³          ³cMVEstado- Conteudo do parametro MV_ESTADO                         ³±±
±±³          ³lTop     - Flag para identificar ambiente TOP                      ³±±
±±³          ³cMVSUBTRIB-Conteudo do parametro MV_SUBTRIB                        ³±±
±±³          |oProcess -> Objeto da nova barra de progressao                     ³±±
±±³          |aVlrMovST- Valores de apuracao obtidos durante o processamento     ³±±
±±³          |aIcmPago - Informacoes das GNREs de documentos fiscais para o E250 ³±±
±±³			 |aLanCDA - Array com informacoes da tabela CDA.					 ³±±
±±³			 |aLanCDA2 - Array com informacoes da tabela CDA (Totalizador).		 ³±±
±±³			 |cMVSTNIEUF - Conteudo do parametro MV_STNIEUF, auxilia do MV_SUBTRIB³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function BlocoE(lTabComp,aWizard,cFilDe,cFilAte,cAlias,cMVEstado,lTop,cMVSUBTRIB,aRegE510,;
						oProcess,aVlrMovST,aIcmPago,aLanCDA,aLanCDA2,cMVSTNIEUF,lOldLan, aReg0200,;
						aReg0190, aReg0220 ,aInfRgE313,lDifal,aMovSemIe,lExtratTAF, aRegT020, aRegT020AA,;
						aRegT020AB, aRegT020AC, aRegT020AD, aRegT020AE, aRegT020AG, aRegT021Val, aRegT021Est,;
						aRegT021AA, aRegT021AB, aRegT021AC, aRegT021AD, aRegT022, aRegT022AA, aRegT051, aRegT051ax,;
						aRegT051AA, aRegT051AB, aRegT051AC, aRegT051AD )
						
Local	dDataDe	:=	''
Local	dDataAte	:=	''
Local	aRegE110	:=	{"E110",0,0,0,0,0,0,0,0,0,0,0,0,0,0}
Local	lImpCrdST	:= 	.F.
Local	nApurIpi	:=	0
Local	nApuracao	:=	3
Local	nPeriodo	:=	1
Local	cNrLivro	:=	''
Local	cArqAnt	:=	''
Local	lSeekCDH	:=	.F.
Local	aRegE200	:=	{}
Local	aRegE210	:=	{}
Local	aRegE250	:=	{}
Local	aApICM		:=	{}
Local	cICMGNR	:=	""
Local	aRegE116 	:= 	{}
Local	aApICMST	:=	{}
Local	cICMSTGNR	:=	""
Local	nUf			:=	0
Local	cMvSFUfGnr	:=	aSPDSX6[MV_SFUFGNR]
Local	cCodRec		:=	""

Default aInfRgE313	:= {}
Default aMovSemIe		:= {}
Default lExtratTAF   := .F.

Default aRegT020    :=  {}	 
Default aRegT020AA  :=  {}  
Default aRegT020AB  :=  {}  
Default aRegT020AC  :=  {}  
Default aRegT020AE  :=  {}  
Default aRegT020AG  :=  {}  
Default aRegT020AD  :=  {}

Default aRegT021Val := {}
Default aRegT021Est := {}
Default aRegT021AA  := {}
Default aRegT021AB  := {}
Default aRegT021AC  := {}
Default aRegT021AD  := {}
Default aRegT022    := {}
Default aRegT022AA  := {}   

Default aRegT051 		:= {}
Default aRegT051ax	:= {}
Default aRegT051AA	:= {}
Default aRegT051AB	:= {}
Default aRegT051AC	:= {}
Default aRegT051AD	:= {}

if !lExtratTAF
	dDataDe	  := SToD(aWizard[1][1])
	dDataAte  := STod(aWizard[1][2])
	nApurIpi  := Iif(!Empty(aWizard[1][13]),Val(aWizard[1][13]),0)
	lImpCrdST := Iif("1"$aWizard[1][11],.T.,.F.)
	cNrLivro  := aWizard[1][3]
	cArqAnt   := aWizard[1][10]
else
	dDataDe  :=	aWizard[1][3]
	dDataAte :=	aWizard[1][4]	
	nApurIpi := Iif(!Empty(aWizard[1][6]),Val(aWizard[1][6]),0)
	cNrLivro :=	'*'
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³REGISTRO E100 - PERIODO DA APURACAO DO ICMS                                  ³
//³REGISTRO E110 - APURACAO DE ICMS - OPERACOES PROPRIAS                        ³
//³REGISTRO E111 - AJUSTES/BENEFICIOS/INCENTIVO DA APURACAO DE ICMS             ³
//³REGISTRO E112 - INFORMACOES ADICIONAIS DOS AJUSTES DE APURACAO DO            ³
//³                ICMS 														³
//³REGISTRO E113 - INFORMACOES ADICIONAIS DOS AJUSTES DA APURACAO DO			³
//³ 			   ICMS E IDENTIFICACAOO DOS DOCUMENTOS FISCAIS.				³
//³REGISTRO E115- INF. ADICIONAIS DA APURACAO DO ICMS                           ³
//³REGISTRO E116 - OBRIGACOES DO ICMS A RECOLHER - OPERACOES PROPRIAS           ³
//³                                                                             ³
//³- Funcao independ.   , geracao e gravacao das informacoes dos registros acima³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTabComp	//Flag de existencia das tabelas complementares do SPED

	lSeekCDH	:=	SPDAPICMS(cFilDe,cFilAte,nApuracao,nPeriodo,cNrLivro,"IC",cAlias,dDataDe,dDataAte,;
								cMVEstado,lTop,lImpCrdST,cArqAnt,@oProcess,,,cMVSUBTRIB,aLanCDA,;
								@aLanCDA2,cMVSTNIEUF, , lExtratTAF,@aRegT020,@aRegT020AA,@aRegT020AB,@aRegT020AC,;
								@aRegT020AE,@aRegT021Val,@aRegT021Est,@aRegT021AA,@aRegT021AB,@aRegT021AC,@aRegT021AD,, @aReg0200,;
								@aReg0190, @aReg0220,cMvSFUfGnr, @aRegT020AG,aWizard, @aRegT020AD )
																											      									
EndIf

If !lSeekCDH
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GRAVACAO DO REGISTRO E100 - PERIODO DA APURACAO DO ICMS                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lExtratTAF //Para ir ao TAF tem que possuir tabela CDH 
		RegE100(cAlias,dDataDe,dDataAte)	
    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Leio o arquivo de apuracao ICMS ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aApICM			:=	FisApur("IC",Year(dDataAte),Month(dDataAte),nApuracao,nPeriodo,cNrLivro,.F.,{},1,.F.,"")
		
		aRegE110[2]		:=	Iif (aScan(aApICM, {|a| a[1]=="001"}   )<>0, aApICM[aScan(aApICM, {|a| a[1]=="001"   })][3],0)
		aRegE110[3]		:=	0
		aRegE110[4]		:=	Iif (aScan(aApICM, {|a| a[4]=="002.00"})<>0, aApICM[aScan(aApICM, {|a| a[4]=="002.00"})][3],0)
		aRegE110[5]		:=	Iif (aScan(aApICM, {|a| a[4]=="003.00"})<>0, aApICM[aScan(aApICM, {|a| a[4]=="003.00"})][3],0)
		aRegE110[6]		:=	Iif (aScan(aApICM, {|a| a[1]=="005"   })<>0, aApICM[aScan(aApICM, {|a| a[1]=="005"   })][3],0)
		aRegE110[7]		:=	0
		aRegE110[8]		:=	Iif (aScan(aApICM, {|a| a[4]=="006.00"})<>0, aApICM[aScan(aApICM, {|a| a[4]=="006.00"})][3],0)
		aRegE110[9]		:=	Iif (aScan(aApICM, {|a| a[4]=="007.00"})<>0, aApICM[aScan(aApICM, {|a| a[4]=="007.00"})][3],0)
		aRegE110[10]	:=	Iif (aScan(aApICM, {|a| a[1]=="009"   })<>0, aApICM[aScan(aApICM, {|a| a[1]=="009"   })][3],0)
		aRegE110[11]	:=	Iif (aScan(aApICM, {|a| a[1]=="011"   })<>0, aApICM[aScan(aApICM, {|a| a[1]=="011"   })][3],0)
		aRegE110[12]	:=	Iif (aScan(aApICM, {|a| a[4]=="012.00"})<>0, aApICM[aScan(aApICM, {|a| a[4]=="012.00"})][3],0)
		aRegE110[13]	:=	Iif (aScan(aApICM, {|a| a[1]=="013"   })<>0, aApICM[aScan(aApICM, {|a| a[1]=="013"   })][3],0)
		aRegE110[14]	:=	Iif (aScan(aApICM, {|a| a[1]=="014"   })<>0, aApICM[aScan(aApICM, {|a| a[1]=="014"   })][3],0)
		aRegE110[15]	:=	Iif (aScan(aApICM, {|a| a[4]=="900.00"})<>0, aApICM[aScan(aApICM, {|a| a[4]=="900.00"})][3],0)
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³USASPED = .F.                                                                                                        ³
		//³Obtencao da GNRE do .IC0 para gerar o registro E116. A GNRE somente sera considerada se o valor da mesma             ³
		//³  for igual ao "Imposto a recolher", pois eh a unica amarracao que se consegue fazer, caso contrario, o contribuinte ³
		//³  deverá informar manualmente no SPED Fiscal as informacoes do registro E116 e/ou E250.                              ³
		//³                                                                                                                     ³
		//³USASPED = .T.                                                                                                        ³
		//³Funciona normalment.                                                                                                ³
		//³                                                                                                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aRegE110[13]>0
			cICMGNR  := Iif(aScan(aApICM,{|a| a[1]=="GNR" .And. Val(a[4])==aRegE110[13]})<>0, aApICM[aScan(aApICM, {|a| a[1]=="GNR" .And. Val(a[4])==aRegE110[13]})][2],"")
			cICMGNR	 :=	SubStr(cICMGNR,1,At("/",cICMGNR)-3)
			
			//  Verifico se a UF de Recolhimento do ICMS Proprio deve apresentar o campo 05 - COD_REC
			//  considerando o Codigo da Receita + Classe de Vencimento ( F6_CODREC + F6_CLAVENC )
			cCodRec	:=	Iif( cMvEstado $ cMvSFUfGnr , "SF6->( Alltrim( F6_CODREC ) + Alltrim( F6_CLAVENC ) )" , "SF6->F6_CODREC" )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posicionamento da tabela SF6, conforme dados do .IC0    ³
			If SPEDSeek("SF6",1,xFilial("SF6")+cMVESTADO+cICMGNR)
				aAdd(aRegE116, {})
				nPos	:=	Len (aRegE116)
				aAdd(aRegE116[nPos], "E116")									//01 - REG
				aAdd(aRegE116[nPos], Iif(!SF6->F6_COBREC$"",SF6->F6_COBREC,"000"))	//02 - COD_OR
				aAdd(aRegE116[nPos], SF6->F6_VALOR)  							//03 - VL_OR
				aAdd(aRegE116[nPos], SF6->F6_DTVENC)  							//04 - DT_VCTO
				aAdd(aRegE116[nPos], &( cCodRec ))								//05 - COD_REC		
				aAdd(aRegE116[nPos], "")											//06 - NUM_PROC
				aAdd(aRegE116[nPos], "")											//07 - IND_PROC
				aAdd(aRegE116[nPos], "")											//08 - PROC
				aAdd(aRegE116[nPos], SF6->F6_OBSERV)							//09 - TXT_COMPL 
				
				If cVersao >= "004" 
					aAdd(aRegE116[nPos],SF6->(StrZero(F6_MESREF,2)+cValToChar(F6_ANOREF)))//10 - MES_REF
				EndIf
			EndIf
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³GRAVACAO DO REGISTRO E110 - APURACAO DE ICMS - OPERACOES PROPRIAS                       ³			
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		GrvRegTrS(cAlias,,{aRegE110})
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³GRAVACAO DO REGISTRO E116 - OBRIGACOES DO ICMS A RECOLHER - OPERACOES PROPRIAS          ³	
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		GrvRegTrS(cAlias,,aRegE116)
	 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³GRAVACAO DO REGISTRO E200 - PERIODO DA APURACAO DO ICMS/ST                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao responsabe pela geracao das informacoes do registro E200 e E210³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PrcE200E21(@aRegE200,@aRegE210,cMVSUBTRIB,cAlias,aVlrMovST,dDataDe,dDataAte,cMVSTNIEUF,cMVEstado)
	    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Apos o fim do processamento das informacoes da apuracao, eh necessario³
		//³ complementa-los com algumas que faltaram                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	  
		SpedApE200(aRegE200,@aRegE210,@aRegE250,aVlrMovST,nApuracao,nPeriodo,cNrLivro,cArqAnt,cMVEstado,aIcmPago,cMVSUBTRIB)
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Leio o arquivo de apuracao ICMS/ST³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aApICMST		:=	FisApur("ST",Year(dDataAte),Month(dDataAte),nApuracao,nPeriodo,cNrLivro,.F.,{},1,.F.,"")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³USASPED = .F.                                                                                                        ³
		//³Obtencao da GNRE do .IC0 para gerar o registro E116. A GNRE somente sera considerada se o valor da mesma             ³
		//³  for igual ao "Imposto a recolher", pois eh a unica amarracao que se consegue fazer, caso contrario, o contribuinte ³
		//³  deverá informar manualmente no SPED Fiscal as informacoes do registro E116 e/ou E250.                              ³
		//³                                                                                                                     ³
		//³USASPED = .T.                                                                                                        ³
		//³Funciona normalment.                                                                                                ³
		//³                                                                                                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aApICMST)>0 .And. aApICMST[14,3]>0
			cICMSTGNR		:=	Iif(aScan(aApICM,{|a| a[1]=="GNR" .And. AllTrim(a[4])==AllTrim(Str(aApICMST[14,3],15,2))})<>0, aApICM[aScan(aApICM, {|a| a[1]=="GNR" .And. AllTrim(a[4])==AllTrim(Str(aApICMST[14,3],15,2))})][2],"")
			cICMSTGNR		:=	SubStr(cICMSTGNR,1,At("/",cICMSTGNR)-3)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³REGISTRO E250 - OBRIGACOES DO ICMS A RECOLHER - SUBSTITUICAO TRIBUTARIA                       ³
	            //|                                                                                              |
			//³Gero registro E250 para todas as GNREs geradas pela Apuracao de ICMS/ST atraves do .ST0       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SPEDSeek("SF6",1,xFilial("SF6")+cMVESTADO+cICMSTGNR) .And. (nUf := aScan(aRegE200,{|x|x[2]==SF6->F6_EST}))>0
				
				//  Verifico se a UF de Recolhimento do ICMS Proprio deve apresentar o campo 05 - COD_REC
				//  considerando o Codigo da Receita + Classe de Vencimento ( F6_CODREC + F6_CLAVENC )
				cCodRec	:=	Iif( cMvEstado $ cMvSFUfGnr , "SF6->( Alltrim( F6_CODREC ) + Alltrim( F6_CLAVENC ) )" , "SF6->F6_CODREC" )
				
				aAdd(aRegE250, {})
				nPos	:=	Len (aRegE250)
				aAdd(aRegE250[nPos], nUF)									//Relacionamento com o PAI - E210
				aAdd(aRegE250[nPos], "E250")								//01 - REG
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Definindo o codigo da obrigacao a recolher³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SF6->F6_OPERNF == "1"
					aAdd (aRegE250[nPos], "001")							//02 - COD_OR - Entradas
					
				ElseIf SF6->F6_EST==cMvEstado
					aAdd (aRegE250[nPos], "002")							//02 - COD_OR - Saidas p/ Estado
					
				Else	
					aAdd (aRegE250[nPos], "999")							//02 - COD_OR - Saidas fora Estado
					
				EndIf
			
				aAdd(aRegE250[nPos], SF6->F6_VALOR)							//03 - VL_OR
				aAdd(aRegE250[nPos], SF6->F6_DTVENC)						//04 - DT_VCTO
				aAdd(aRegE250[nPos], &( cCodRec ))							//05 - COD_REC			
				aAdd(aRegE250[nPos], SF6->F6_NUMPROC)						//06 - NUM_PROC
				aAdd(aRegE250[nPos], SF6->F6_INDPROC)						//07 - IND_PROC
				aAdd(aRegE250[nPos], SF6->F6_DESCOMP)						//08 - PROC
			    aAdd(aRegE250[nPos], SF6->F6_OBSERV)						//09 - TXT_COMPL    
			
				If cVersao >= "004" //A partir de janeiro de 2011 incluir o campo 10 mmaaaa
					aAdd(aRegE250[nPos], SF6->(StrZero(F6_MESREF,2)+cValToChar(F6_ANOREF)))//10 - MES_REF
				EndIf
	
			EndIf
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³GRAVACAO DO REGISTRO E200 - PERIODO DA APURACAO DO ICMS ST                                                ³
		//|GRAVACAO DO REGISTRO E210 - APURACAO DO ICMS - SUBSTITUICAO TRIBUTARIA                                    |
		//³GRAVACAO DO REGISTRO E250 - OBRIGACOES DO ICMS A RECOLHER - SUBSTITUICAO TRIBUTARIA                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		SPEDRegs(cAlias,{aRegE200,aRegE210,aRegE250})
	EndIf
Else
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³REGISTRO E200 - PERIODO DA APURACAO DO ICMS ST                               ³
	//³REGISTRO E210 - APURACAO DO ICMS - SUBSTITUICAO TRIBUTARIA                   ³
	//³REGISTRO E220 - AJUSTES/BENEFICIOS/INCENTIVOS DA APURACAO DO ICMS            ³
	//³                SUBSTITUICAO TRIBUTARIA                                      ³
	//³REGISTRO E230 - INFORMACOES ADICIONAIS DOS AJUSTES DE APURACAO DO            ³
	//³                ICMS SUBSTITUICAO TRIBUTARIA                                 ³
	//³REGISTRO E240 - INFORMACOES ADICIONAIS DOS AJUSTES DA APURACAO DO			³
	//³				   ICMS ST E IDENTIFICACAO DOS DOCUMENTOS FISCAIS.              ³
	//³REGISTRO E250 - OBRIGACOES DO ICMS A RECOLHER - SUBSTITUICAO                 ³
	//³                TRIBUTARIA                                                   ³
	//³- Funcao independ.   , geracao e gravacao das informacoes dos registros acima³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	SPDAPICMS(cFilDe,cFilAte,nApuracao,nPeriodo,cNrLivro,"ST",cAlias,dDataDe,dDataAte,cMVEstado,lTop,;
   				lImpCrdST,cArqAnt,@oProcess,aVlrMovST,aIcmPago,cMVSUBTRIB,aLanCDA,aLanCDA2,cMVSTNIEUF,;
   				lOldLan, lExtratTAF,@aRegT020,@aRegT020AA,@aRegT020AB,@aRegT020AC,@aRegT020AE,;
   				@aRegT021Val,@aRegT021Est,@aRegT021AA,@aRegT021AB,@aRegT021AC,@aRegT021AD,, @aReg0200, @aReg0190,;
   				@aReg0220, cMvSFUfGnr, @aRegT020AG,aWizard, @aRegT020AD )
   				   				
EndIf

If "0"$aWizard[2][5] .or. lExtratTAF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³No caso de o objeto oProcess existir, significa que a nova barra  ³
	//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
	//| portanto deve ser efetuado os controles para demonstrar o        |
	//| resultado do processamento.                                      |
	//|                                                                  |
	//³Alterando a mensagem do segundo incremento da regua, pois nao     |
	//| preciso fazer o mesmo para o primeiro que se refere a filiais,   |
	//| pois a apuracao jah estah consolidada                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Type("oProcess")=="O"
		oProcess:Inc2Progress("Obtendo Informações de Apuração de IPI","")
	Else
		IncProc("Obtendo Informações de Apuração de IPI")
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GRAVACAO - REGISTRO E500 - PERIODO DA APURACAO DO IPI ³
	//|                                                      |
	//| - Funcao independ.   , geracao e gravacao do registro|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if !lExtratTAF
		RegE500(cAlias,dDataDe,dDataAte,nApurIpi)
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GRAVACAO - REGISTRO E510 - CONSOLIDACAO DOS VALROES DE IPI POR CFOP E CODIGO DE TRIBUTACAO DO IPI³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if !lExtratTAF
		GrvRegTrS(cAlias,,aRegE510)
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³REGISTRO E520 - APURACAO DO IPI                       ³
	//³REGISTRO E530 - AJUSTES DA APURACAO DO IPI            ³
	//                                                       |
	//| - Funcao independ.   , geracao e gravacao do registro|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SPDE520530(cAlias,dDataDe,cNrLivro,nApuracao,lTop,lExtratTAF, @aRegT022, @aRegT022AA, aRegE510 )	
EndIf

//----------------------------------------------------
//PROCESSA FAMÍLIA DO REGISTRO E300 - APURAÇÃO DIFAL
//----------------------------------------------------
IF lDifal 
	//Se geração for posterior a janeiro de 2016 e tabelas da apuração do difal existirem será processado
	//registros da família do E300
	If Type("oProcess")=="O"
		oProcess:Inc2Progress("Obtendo Informações de Apuração do DIFAL","")
	Else
		IncProc("Obtendo Informações de Apuração do DIFAL")
	EndIf
	
	ApurDifal (dDataDe, dDataAte, cNrLivro, aInfRgE313,cAlias,aMovSemIe,aIcmPago,@aRegT051, @aRegT051ax, @aRegT051AA, @aRegT051AB, @aRegT051AC, @aRegT051AD, lExtratTAF)
EndIF

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RegE100   ³ Autor ³Gustavo G. Rueda       ³ Data ³21.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³               PERIODO DE APURACAO DO ICMS                  ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro E100                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³2(um por periodo)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAlias -> Alias do TRB que devera conter as informacoes do  ³±±
±±³          ³ meio-magnetico.                                            ³±±
±±³          ³dDataDe -> Data incial do periodo de apuracao.              ³±±
±±³          ³dDataAte -> Data final do periodo de apuracao.              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegE100(cAlias,dDataDe,dDataAte)
Local	aReg		:=	{}
Local	nPos		:=	0

aAdd (aReg, {})
nPos	:=	Len (aReg)
aAdd (aReg[nPos], "E100")								//01 - REG
aAdd (aReg[nPos], dDataDe)								//02 - DT_INI
aAdd (aReg[nPos], dDataAte)								//03 - DT_FIN

GrvRegTrS(cAlias,,aReg)
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RegE115   ³ Autor ³Gustavo G. Rueda       ³ Data ³22.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³        INFORMAÇÕES ADICIONAIS DA APURAÇÃO                  ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro E115                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³2(um por periodo)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aRegE115 - Array populado com o registro                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAlias -> Alias do TRB que devera conter as informacoes do  ³±±
±±³          ³ meio-magnetico.                                            ³±±
±±³          ³dDataDe -> Data incial do periodo de apuracao.              ³±±
±±³          ³dDataAte -> Data final do periodo de apuracao.              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegE115(cAlias,dDataDe,dDataAte,lExtratTAF)
Local	aRegE115	:=	{}
Local	nPos		:=	0
Local   cPeriodo    :=	StrZero(Year(dDataDe),4)+StrZero(Month(dDataDe),2)
Local 	cDados		:= "" 

Default lExtratTAF := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tabela de complemento criado para amarrar as informacoes pertinentes³
//³  ao registr E115                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aSPDSX2[AI_CDV] 	 
	dbSelectArea("CDV")
    CDV->(DbSetOrder(1)) 
	CDV->(MsSeek(xFilial("CDV")+cPeriodo))
	While !CDV->(Eof()) .And. CDV->CDV_FILIAL==xFilial("CDV") .And. CDV->CDV_PERIOD==cPeriodo
		cDados:= "NF: " + Alltrim(CDV->CDV_DOC) + " SERIE: " + Alltrim(CDV->CDV_SERIE) + " CLI/FOR: " + Alltrim(CDV->CDV_CLIFOR) + " LOJA: " + Alltrim(CDV->CDV_LOJA)

		aAdd (aRegE115, {})
		nPos :=Len(aRegE115)
		aAdd (aRegE115[nPos], "E115")							//01 - REG
		aAdd (aRegE115[nPos], CDV->CDV_CODAJU)					//02 - COD_INF_ADIC
		aAdd (aRegE115[nPos], CDV->CDV_VALOR)					//03 - VL_INF_ADIC
		aAdd (aRegE115[nPos], CDV->CDV_DESCR + cDados)					//04 - DESCR_COMPL_AJ

		CDV->(DbSkip())
	EndDo
		
	if !lExtratTAF	
		GrvRegTrS(cAlias,,aRegE115)	
	endif
Endif
Return aRegE115

*/
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RegE500   ³ Autor ³Gustavo G. Rueda       ³ Data ³23.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³               PERIODO DE APURACAO DO IPI                   ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro E500                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³2(um por periodo)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAlias -> Alias do TRB que devera conter as informacoes do  ³±±
±±³          ³ meio-magnetico.                                            ³±±
±±³          ³dDataDe -> Data incial do periodo de apuracao.              ³±±
±±³          ³dDataAte -> Data final do periodo de apuracao.              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegE500 (cAlias, dDataDe, dDataAte, nApuracao)
	Local	aReg		:=	{}
	Local	nPos		:=	0

	aAdd (aReg, {})
	nPos	:=	Len (aReg)
	aAdd (aReg[nPos], "E500")							//01 - REG
	aAdd (aReg[nPos], STR(nApuracao,1))				//02 - IND_APUR
	aAdd (aReg[nPos], dDataDe)							//03 - DT_INI
	aAdd (aReg[nPos], dDataAte)							//04 - DT_FIN

	GrvRegTrS(cAlias,,aReg)
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RegE510   ³ Autor ³Gustavo G. Rueda       ³ Data ³15.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³    CONSOLIDACAO DOS VALORES DE IPI POR CFOP E CODIGO DE    ³±±
±±³          ³                   TRIBUTACAO DO IPI                        ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao do Registros E510                                 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoe contidas na tabela   ³±±
±±³          ³ SFT somente para operacoes TRIBUTADAS                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3(varios por periodo)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAliasSFT -> Alias da tabela SFT aberta no momento.         ³±±
±±³          ³ funcao a ser retornado para gravacao pela funcao principal.³±±
±±³          |aRegE510 -> Array contendo as informacoes processadas pela  ³±±
±±³          ³ funcao a ser retornado para gravacao pela funcao principal.³±±
±±³          ³cSituaDoc -> Situação do documento.						  ³±±
±±³          ³aClasFis -> Array contendo os CSTs de PIS/COFINS/ICMS       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegE510(cAliasSFT,aRegE510,cSituaDoc,aClasFis)
	Local	nPos		:=	0

	If (nPos := aScan(aRegE510,{|aX| aX[2]==(cAliasSFT)->FT_CFOP .And. aX[3]==aClasFis[2]}))==0
		aAdd(aRegE510, {})
		nPos	:=	Len (aRegE510)
		aAdd (aRegE510[nPos], "E510")	   					//01 - REG
		aAdd (aRegE510[nPos], (cAliasSFT)->FT_CFOP)		//02 - CFOP
		aAdd (aRegE510[nPos], aClasFis[2])					//03 - CST_IPI
		aAdd (aRegE510[nPos], 0)							//04 - VL_CONT_IPI
		aAdd (aRegE510[nPos], 0)							//05 - VL_BC_IPI
		aAdd (aRegE510[nPos], 0)							//06 - VL_IPI
	EndIf
	aRegE510[nPos][4]	+=	(cAliasSFT)->FT_VALCONT		//04 - VL_CONT_IPI
	aRegE510[nPos][5]	+=	(cAliasSFT)->FT_BASEIPI		//05 - VL_BC_IPI
	aRegE510[nPos][6]	+=	(cAliasSFT)->FT_VALIPI		//06 - VL_IPI
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |SPDE520530³ Autor ³Gustavo G. Rueda       ³ Data ³23.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³REGISTRO E520 - APURACAO DO IPI                             ³±±
±±³          ³REGISTRO E530 - AJUSTES DA APURACAO DO IPI                  ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao dos Registros E520 e E530              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoe contidas na apuracao ³±±
±±³          ³ de IPI.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³E520 - 3(varios por periodo)                                ³±±
±±³          ³E530 - 4(para cada E520)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAlias    -> Alias do TRB para gravacao.                    ³±±
±±³          ³dDataDe   -> Data do inicio do periodo de apuracao.         ³±±
±±³          ³cNrLivro  -> Numero do livro selecionado no wizard.         ³±±
±±³          ³nApuracao -> Periodo de Apuracao (1=Mensal e 3=Decendial)   ³±±
±±³          ³lTop      -> Flag de processamento via TOP                  ³±±
±±³          ³lExtratTAF-> Indica se a origem da chamada eh o Extrator TAF³±±
±±³          ³aRegT022  -> Array de Retorno para o Extrator gerar T022    ³±±
±±³          ³aRegT022AA  -> Array de Retorno para o Extrator gerar T022AA³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SPDE520530(cAlias,dDataDe,cNrLivro,nApuracao,lTop,lExtratTAF, aRegT022, aRegT022AA,aRegE510  )
Local	nPos		:=	0
Local	nPeriodo	:=	1
Local	cIndAj		:=	""
Local	aReg		:=	{}
Local	aRegE530	:=	{}
Local	aApIPI		:=	{}
Local	nVLSdAnt	:=	0
Local	nVLDbIpi	:=	0
Local	nVLCdIpi	:=	0
Local	nVLOdIpi	:=	0
Local	nVLOcIpi	:=	0
Local	nVLScIpi	:=	0
Local	nVLSdIpi	:=	0
Local	nVLTcIpi	:=	0
Local  nE020OIPI  := 0
Local  cChave     := ""
Local	cAliasCDP	:=	"CDP"
Local	aParFil		:=	{}
Local	nRecnoCCK	:=	Nil
Local	lAchouCCK	:=	.F.
Local	cSequen		:=	""
Local	cSomaSeq	:=	""    
Local	nX 			:= 0   

Default lExtratTAF  := .F. 
Default aRegT022    := {}    
Default aRegT022AA  := {}
Default aRegE510	 := {}


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O periodo de geracao podera ser somente 0 - Mensal ou 1 - Descendial ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nApuracao<>1)
	nApuracao	:=	3
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Para ambiente ADS/DBF, devo pegar a ultima sequencia para montar o indregua³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTop
	cChave	:=	STR(nApuracao,1)+STR(nPeriodo,1)+DTOS(dDataDe)+cNrLivro
	
	If CDP->(MsSeek(xFilial("CDP")+"IP"+cChave))
		cSomaSeq  		:= 	CDP->CDP_SEQUEN

		While CDP->(MsSeek(xFilial("CDP")+"IP"+cChave+cSomaSeq)) // Posiciona na ultima sequencia
			cSequen  	:= 	CDP->CDP_SEQUEN
			cSomaSeq 	:= 	Soma1(cSequen)
		EndDo
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montando array de parametros para SPEDFFiltro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aParFil,"IP")
aAdd(aParFil,STR(nApuracao,1))
aAdd(aParFil,STR(nPeriodo,1))
aAdd(aParFil,DTOS(dDataDe))
aAdd(aParFil,cNrLivro)
aAdd(aParFil,cSequen)
             
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para quando existir a tabela de APuração de IP³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SPEDFFiltro(1,"CDP",@cAliasCDP,aParFil)                                                     

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³A tabela de Apuracao jah estah filtrada neste momento ³
	//³  atraves da funcao SPEDFFiltr acima                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !(cAliasCDP)->(Eof())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Para ambiente TOP devo pegar o recno retornado na query, se nao for TOP,³
		//³ devo deixar como declarado, igual a Nil                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lTop
			nRecnoCCK	:=	(cAliasCDP)->CCKRECNO
		EndIf
		
		lAchouCCK	:=	SPEDSeek("CCK",,xFilial("CCK")+(cAliasCDP)->CDP_CODLAN,nRecnoCCK)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REGISTRO E530 - AJUSTES DA APURACAO DO IPI³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAchouCCK .And. !(cAliasCDP)->CDP_LINHA=="007"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Define o tipo de utilizacao do lancamento.³
			//³C=Credito;                                ³
			//³D=Debito                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If "C"$CCK->CCK_TPUTI
				cIndAj:="1"
			Else
				cIndAj:="0"
			EndIf
			  
			aAdd(aRegE530, {})
			nPos	:=	Len (aRegE530)
			aAdd(aRegE530[nPos], "E530")	   	   						//01 - REG
			aAdd(aRegE530[nPos], cIndAj)				 				//02 - IND_AJ
			aAdd(aRegE530[nPos], (cAliasCDP)->CDP_VALOR)				//03 - VL_AJ
			aAdd(aRegE530[nPos], (cAliasCDP)->CDP_CODLAN)				//04 - COD_AJ
			aAdd(aRegE530[nPos], (cAliasCDP)->CDP_INDDOC)				//05 - IND_DOC
			aAdd(aRegE530[nPos], (cAliasCDP)->CDP_NUMDOC)				//06 - NUM_DOC
			aAdd(aRegE530[nPos], (cAliasCDP)->CDP_DESC)				//07 - DESCR_AJ
			
			nE020OIPI += iif(cIndAj=='1',(cAliasCDP)->CDP_VALOR,0) // aglutino o valor para gerar o campo 6 do E020
		EndIf		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Obtendo valores da apuracao do IPI para montar o registro E520 na sequencia³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Do Case

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valor total dos "Creditos por entrada"  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
           	Case (cAliasCDP)->CDP_LINHA$"001/002/003"
		      nVLCdIpi	+=	(cAliasCDP)->CDP_VALOR

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valor total de "Outros Creditos"        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		      
		    Case (cAliasCDP)->(CDP_LINHA=="005" .And. Upper(AllTrim(CDP_DESC))=="OUTROS CREDITOS") 
		      nVLOcIpi	+=	(cAliasCDP)->CDP_VALOR

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Saldo credor do IPI transferido do periodo anterior³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    Case (cAliasCDP)->CDP_LINHA=="007"
		      nVLSdAnt	+= 	(cAliasCDP)->CDP_VALOR
		      
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valor Total de cretido do imposto                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    Case (cAliasCDP)->CDP_LINHA=="006"
		      nVLTcIpi	+= 	(cAliasCDP)->CDP_VALOR 

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valor total dos "Saidas com debito do imposto"³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    Case (cAliasCDP)->CDP_LINHA=="009"
		      nVLDbIpi	+= 	(cAliasCDP)->CDP_VALOR
		         
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valor de "Outros debitos do IPI"³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case((cAliasCDP)->CDP_LINHA=="011" .And. Upper(AllTrim(CDP_DESC))=="RESSARCIMENTO DE CRÉDITOS") .Or.;
				(cAliasCDP)->(CDP_LINHA == "012" .And. Upper(AllTrim(CDP_DESC))=="OUTROS DEBITOS") .Or.;
				(cAliasCDP)->(CDP_LINHA == "010" .And. Upper(AllTrim(CDP_DESC))=="ESTORNO DE CREDITOS")
		      nVLOdIpi	+= 	(cAliasCDP)->CDP_VALOR

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valor do saldo devedor do IPI³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    Case (cAliasCDP)->CDP_LINHA=="016"
		      nVLSdIpi	+= 	(cAliasCDP)->CDP_VALOR

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valor do saldo credor do IPI³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    Case (cAliasCDP)->CDP_LINHA=="017"
		      nVLScIpi	+= 	(cAliasCDP)->CDP_VALOR
		      
		EndCase
		
		(cAliasCDP)->(dbSkip())		
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GRAVACAO DO REGISTRO E530 - AJUSTES DA APURACAO DO IPI³
	//|                                                      |
	//|A gravacao eh feita somente quando existe lancamentos |
	//|  de apuracao com codigos relacionados, e para isso,  |
	//|  eh necessario que as tabelas CDP e CCK estejam em   |
	//|  uso.                                                |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSort(aRegE530,,,{|x,y| x[2]<y[2]})

	if !lExtratTAF
		GrvRegTrS (cAlias,, aRegE530)
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Fecho query ou indregua criada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SPEDFFiltro(2,,cAliasCDP)

Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtendo valores da Apuracao de IPI gerado no modo antigo, atraves do arquivo *.IP³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aApIPI	:=	FisApur("IP",Year(dDataDe),Month(dDataDe),nApuracao,nPeriodo,cNrLivro,.F.,{},1,.F.,"")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valor total dos "Creditos por entrada"  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVLCdIpi	:=	Iif (aScan (aApIPI, {|a| a[1]=="001"})<>0, aApIPI[aScan (aApIPI, {|a| a[1]=="001"})][3], 0)
	nVLCdIpi	+=	Iif (aScan (aApIPI, {|a| a[1]=="002"})<>0, aApIPI[aScan (aApIPI, {|a| a[1]=="002"})][3], 0)
	nVLCdIpi	+=	Iif (aScan (aApIPI, {|a| a[1]=="003"})<>0, aApIPI[aScan (aApIPI, {|a| a[1]=="003"})][3], 0)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valor total de "Outros Creditos"        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVLOcIpi	:=	Iif (aScan (aApIPI, {|a| a[1]=="005"})<>0, aApIPI[aScan (aApIPI, {|a| a[1]=="005"})][3], 0)
	//nVLOcIpi 	+= 	Iif (aScan (aApIPI, {|a| a[1]=="004"})<>0, aApIPI[aScan (aApIPI, {|a| a[1]=="004"})][3], 0)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Saldo credor do IPI transferido do periodo anterior³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	nVLSdAnt	:=	Iif (aScan (aApIPI, {|a| a[1]=="007"})<>0, aApIPI[aScan (aApIPI, {|a| a[1]=="007"})][3], 0)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valor Total de cretido do imposto                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    nVLTcIpi	:=	Iif (aScan (aApIPI, {|a| a[1]=="006"})<>0, aApIPI[aScan (aApIPI, {|a| a[1]=="006"})][3], 0)
    	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valor total dos "Saidas com debito do imposto"³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	nVLDbIpi	:=	Iif (aScan (aApIPI, {|a| a[1]=="009"})<>0, aApIPI[aScan (aApIPI, {|a| a[1]=="009"})][3], 0)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valor de "Outros debitos do IPI"³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVLOdIpi	:=	Iif (aScan (aApIPI, {|a| a[1]=="012"})<>0, aApIPI[aScan (aApIPI, {|a| a[1]=="012"})][3], 0)
	nVLOdIpi 	+= 	Iif (aScan (aApIPI, {|a| a[1]=="011"})<>0, aApIPI[aScan (aApIPI, {|a| a[1]=="011"})][3], 0)
	nVLOdIpi 	+= 	Iif (aScan (aApIPI, {|a| a[1]=="010"})<>0, aApIPI[aScan (aApIPI, {|a| a[1]=="010"})][3], 0)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valor do saldo devedor do IPI³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVLSdIpi	:=	Iif (aScan (aApIPI, {|a| a[1]=="016"})<>0, aApIPI[aScan (aApIPI, {|a| a[1]=="016"})][3], 0)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valor do saldo credor do IPI³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	nVLScIpi	:=	Iif (aScan (aApIPI, {|a| a[1]=="017"})<>0, aApIPI[aScan (aApIPI, {|a| a[1]=="017"})][3], 0)
EndIf

If Len(aRegE510) > 0
	nVLCdIpi := 0
	For nX := 1 to Len(aRegE510)
		If SUBSTR(aRegE510[nX][2],1,1)$"1/2/3" 
			nVLCdIpi += aRegE510[nX][6]
		EndIf
	Next nX
Else
	nVLCdIpi := nVLCdIpi + nVLOcIpi
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³REGISTRO E520 - APURACAO DO IPI                                             ³
//³                                                                            ³
//³Neste momento tambem eh efetuado a gravacao do mesmo no TRB de processamento³
//³  da rotina.                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aReg, {})
nPos	:=	Len (aReg)
aAdd (aReg[nPos], "E520")	   				//01 - REG
aAdd (aReg[nPos], nVLSdAnt)					//02 - VL_SD_ANT_IPI
aAdd (aReg[nPos], nVLDbIPI)					//03 - VL_DEB_IPI
aAdd (aReg[nPos], nVLCdIpi)               //04 - VL_CRED_IPI
aAdd (aReg[nPos], nVLOdIPI)					//05 - VL_OD_IPI
aAdd (aReg[nPos], Iif (Len(aRegE530)>0,nE020OIPI,0))//06 - VL_OC_IPI
aAdd (aReg[nPos], nVLScIPI)					//07 - VL_SC_IPI
aAdd (aReg[nPos], nVLSdIPI)					//08 - VL_SD_IPI

If !lExtratTAF
	GrvRegTrS(cAlias,,aReg)
Else
	aRegT022 := aReg        
	aRegT022AA := aRegE530
EndIf

Return
  	
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |SPDBlocoH ³ Autor ³Gustavo G. Rueda       ³ Data ³29.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³REGISTRO H005 - TOTAIS DE INVENTARIO                        ³±±
±±³          ³REGISTRO H010 - INVENTARIO                                  ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao dos Registros H005 e H010              |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoes obtidas pela funcao ³±±
±±³          ³ FsEstInv.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³2 H005 (um por data)                                        ³±±
±±³          ³3 H010 (para cada H005)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAlias    -> Alias do TRB que recebe a gravacao dos registro³±±
±±³          ³bWhileSM0 -> Condicao do while do SIGAMAT                   ³±±
±±³          ³aWizard   -> Informacoes do assistente da rotina            ³±±
±±³          ³cFilDe    -> Filial de inicio de processamento da rotina    ³±±
±±³          ³aLisFil   -> Filiais selecionadas no assistente da rotina   ³±±
±±³          ³aReg0190  -> Informacoes a serem atualizadas da sobre a UM  ³±±
±±³          ³aReg0200  -> Informacoes a serem atualizadas da sobre o     ³±±
±±³          ³             Produto                                        ³±±
±±³          ³aReg0220  -> Informacoes a serem atualizadas da sobre a     ³±±
±±³          ³             alteracao de produto                           ³±±
±±³          ³aReg0150  -> Informacoes a serem atualizadas da sobre o     ³±±
±±³          ³             participante                                   ³±±
±±³          ³nCtdFil   -> Quantidade de registros da tabela SM0 que serao³±±
±±³          ³             processados                                    ³±±
±±³          ³lEnd      -> Flag de cancelamento do processamento          ³±±
±±³          ³cFilAte   -> Filial final para processamento                ³±±
±±³          ³lExtTaf   -> Indica que a chamada da funcao eh o Extrator   ³±±
±±³          ³			   TAF											  ³±±
±±³          ³aRegT079  -> Array para geracao do Registro T079 do Extrator³±±
±±³          ³aRegT079AA-> Array para geracao do Registro T079AA do       ³±±
±±³          ³			   Extrator  								      ³±±
±±³          ³aRegT079AB-> Array para geracao do Registro T079AB do       ³±±
±±³          ³			   Extrator  								      ³±±
±±³			 |cExtVer   -> Versao do Sped Que o Extrator TAF considera    ³±±   
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SPDBlocoH(cAlias,bWhileSM0,aWizard,cFilDe,aLisFil,aReg0190,aReg0200,aReg0220,aReg0150,oProcess,nCtdFil,lEnd,cFilAte,lExtTAF,aRegT079,aRegT079AA,aRegT079AB,cExtVer)
Local	aPartDoc	:=	{}
Local	aRegH010	:=	{}
Local	aRegH020	:=	{}
Local	aRegH005	:=	{}
Local	aAuxH005	:=	{}
Local	nAcVlrEst	:=	0
Local	lExistF0M	:=	aSPDSX2[AI_F0M]
Local	aAreaSM0	:=	SM0->(GetArea())
Local   nTamProd	:=	TamSX3("B1_COD")[1]
//Local	nDecVal		:= 	TamSX3("B2_CM1")[2]
local 	ntamCli		:= 	TamSX3("F0M_CLIFOR")[1]
Local 	nTamLoj		:= 	TamSX3("F0M_LOJA")[1]
Local 	nTamCOD		:= 	TamSX3("F0M_CODIGO")[1]
Local	nFilial		:= 	0
Local	nH			:=	0
Local	nI			:=	0
Local	nY			:=	0
Local	nPos		:=	0
Local	nPosH020	:=	0
Local	nX			:=	0
//Local	nTpInv  	:= 	0
//Local	nTpProc 	:= 	0
//Local	cArqInv 	:= 	""
Local	cMotInv		:=	""
Local	dDataDe		:=	cToD( "  / /  ") 
Local	dDataAte	:=	cToD( "  / /  ") 
Local	dDataFec	:=	cToD( "  / /  ") 
Local	nEmpProc	:=	0
Local	cTimeDocs	:=	""
Local	nDocsXTime	:=	0
Local	nRecCount	:=	0
Local	nRegsProc	:=	0
Local	nCtdInv		:=	0
Local	nInv		:=	0
Local	cUnid		:=	Nil
Local	aProd		:=	Nil
Local	cProd		:=	""
Local	nQuant    	:=	0
Local 	nVlrIte   	:=	0
Local 	nVlIteIR   	:=	0
Local 	nValUnit 	:=  0
Local	nAliqProd	:=	0
Local	cClasFis	:=	""
Local	lTipoinv	:= aSPDSX2[AI_F0Q]    .And. aSPDSX3[FP_F0Q_PERIOD] .And. aSPDSX3[FP_F0Q_ID]
Local 	lNvcampos 	:= aSPDSX3[FP_F0M_UM] .And. aSPDSX3[FP_F0M_VUNIT]  .And. aSPDSX3[FP_F0M_TPCF] .And. aSPDSX3[FP_F0M_CONTA]
Local	aQtdArq		:= {}
Local   cSegUnid	:= ""
Local   cTpUnid		:= ""
Local   nConvUnid	:= 0
//Local	lInvent		:= .T.
//Local	lFilial		:= .F.
Local aPeH020		:= {}
//Local aRelacProd	:= {}
//Local nRelacProd	:= 0
Local cMsgh020		:= ""
Local cMVH020		:= ""
Local lGeraH020		:= .T.
Local lAchouF0M		:= .F.
Local nRegPai		:= 0
Local nArquivos		:= 1
Local nBasIcm 		:= 0
Local nTotICM 		:= 0
Local cAliBLH		:= ''
Local cAliasF0Q		:= ''
Local cPerF0Q 		:= ''
Local lATribF0Q		:= .F.
Local nAliqint		:= 0
Local cSituacao		:= ''
Local lSPDBlocH		:= FindFunction("SPDBlocH")
Local _lVerProc     := Type("oProcess")=="O"
Default lExtTAF := .F.   
Default cExtVer := ""

cMotInv	 :=	Iif( !lExtTAF, Substr(aWizard[1][19],1,2), Substr(aWizard[2][7],1,2) )

dDataDe	 :=	Iif( !lExtTAF, SToD(aWizard[1][1]), aWizard[1][3] )
dDataAte :=	Iif( !lExtTAF, SToD(aWizard[1][2]), aWizard[1][4] )
dDataFec :=	Iif( !lExtTAF, SToD(aWizard[1][8]), aWizard[2][9] )

cPerF0Q := cvaltochar(strzero(month(dDataDe),2)) + cvaltochar(year(dDataAte ))

If lExtTAF
	cVersao := cExtVer
EndIf
        
//³No caso de o objeto oProcess existir, significa que a nova barra  ³
//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
//| portanto deve ser efetuado os controles para demonstrar o        |
//| resultado do processamento.                                      |
//|                                                                  |
//|Jah que estah rotina efetua o processamento multi-filiais, preciso³
//| corrigir a posicao da regua, pois no while principal da SFT      |
//| deixou a barra no final, pois processou todas as filiais.        |
If !lExtTAF
	If Type("oProcess")=="O"
		oProcess:Set1Progress(nCtdFil)
	EndIf
EndIf

//³Montando o processamento de multi empresas conforme selecionado nos³
//³  parametros da rotina³
If !(("1" $ aWizard[1][12]) .And. Len(aLisFil) > 0) .And. !lExtTAF
	SM0->(MsSeek(cEmpAnt+cFilDe,.T.))
EndIf	
While Eval(bWhileSM0)
	
	cFilAnt   := FWGETCODFILIAL
	
	//³Quando a rotina for chamada pelo Extrator TAF ja estou posicionado na filial³
	//³correta, sendo assim nao eh necessario realizar validacoes                  ³
	If !lExtTAF	
		If Len(aLisFil)>0 .And. cFilAnt <= cFilAte
		   nFilial := Ascan(aLisFil,{|x|x[2]==cFilAnt})
		   If nFilial==0 .Or. !(aLisFil[nFilial,1])  //Filial não marcada, vai para proxima
				SM0->( dbSkip() ) 
				Loop
			EndIf
		Else
			If "1"$aWizard[1][12]  //Somente faz skip se a opção de selecionar filiais estiver como Sim.
				 SM0->(dbSkip())
				 Loop
			EndIf		
		EndIf
	EndIf
	
	nArquivos := 1
	aQtdArq	  := {}
	aAdd(aQtdArq,{})
	aAdd(aQtdArq[nArquivos],dDataFec)
	aAdd(aQtdArq[nArquivos],cMotInv)
	
	//F0Q_FILIAL+DTOS(F0Q_DTFECH)+F0Q_MOTINV
	If lTipoinv			
		cAliasF0Q := GetNextAlias()
			
		BeginSql Alias cAliasF0Q
		COLUMN F0Q_DTFECH AS DATE 
		
		SELECT DISTINCT F0Q_MOTINV,F0Q_DTFECH
		FROM 	%TABLE:F0Q% F0Q
			WHERE  F0Q.F0Q_FILIAL=%XFILIAL:F0Q%
			AND F0Q.F0Q_PERIOD = %Exp:cPerF0Q%
			AND F0Q.%NOTDEL%
			ORDER BY F0Q_DTFECH
		EndSql
	
		DbSelectArea (cAliasF0Q)
		
		While (cAliasF0Q)->(!Eof())
			nArquivos ++ 
			aAdd(aQtdArq,{})
			aAdd(aQtdArq[nArquivos],(cAliasF0Q)->F0Q_DTFECH)
			aAdd(aQtdArq[nArquivos],(cAliasF0Q)->F0Q_MOTINV)
			
			(cAliasF0Q)->(dbSkip())
		ENDDO
		
		(cAliasF0Q)->(DbCloseArea())
		
	Endif
	nEmpProc := 0 

	
	For nY:= 1 to nArquivos
		
		dDataFec :=	Iif( !lExtTAF, aQtdArq[nY][1], aWizard[2][9] )
		cMotInv	 := Iif( !lExtTAF, aQtdArq[nY][2], Substr(aWizard[2][7],1,2) )		
	
		cMVH020		:= aSPDSX6[MV_TXTH020]		
		nRegsProc 	:= 0		
		nEmpProc	+=	1
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para identificar a quantidade de processamento que serah ³
		//³  efetuado conforme selecao das opcoes no assistente da rotina      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nCtdInv		:=	nArquivos		
		nInv		:=	nEmpProc
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³No caso de o objeto oProcess existir, significa que a nova barra  ³
		//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
		//| portanto deve ser efetuado os controles para demonstrar o        |
		//| resultado do processamento.                                      |
		//|                                                                  |
		//|Efetuando o primeiro incremento da regua.                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lExtTAF
			//LGS#20200203 - Adequação de release 12.1.25 e posteriores
			//If Type("oProcess")=="O"
			If _lVerProc
				oProcess:Inc1Progress(STR0023+cEmpAnt+"/"+cFilAnt,StrZero(nEmpProc,3)+"/"+StrZero(nCtdFil,3))	//"Processando empresa :"
				
				oProcess:Set2Progress(1)
				oProcess:Inc2Progress("Processando Inventário("+Str(nInv,3)+"/"+Str(nCtdInv,3)+")","Obtendo informações, aguarde...")
		
				oProcess:SetDetProgress("Obtendo informações, aguarde...","",;
					"Obtendo informações, aguarde...","",;
					"Obtendo informações, aguarde...","",;
					"Obtendo informações, aguarde...","")
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Controle do cancelamento da rotina³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If oProcess:Cancel()
					Exit
				EndIf
			Else
			
				IncProc(STR0006) // "Filtrando base inventário..."
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Controle do cancelamento da rotina³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Interrupcao(@lEnd)
					Exit
				EndIf
			EndIf  
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|Processando os Saldos em Estoque(1)	|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		lAchouF0M	:= .F.
		nAliqint := aSPDSX6[MV_ICMPAD]
		
		If aExistBloc[29]//ExistBlock("SPEDALTH") 			

			cAliBLH := ExecBlock("SPEDALTH",.F.,.F.,{dDataFec,cMotInv})

			//Verifica se arquivo existe
			//LGS#20200204 - Adequação de release 12.1.25 e posteriores
			//IF MSFile(cAliBLH+GetDBExtension(),,__LocalDriver)
			IF Select(cAliBLH) > 0
				lAchouF0M := .F.
				
				dbSelectArea(cAliBLH) 
				(cAliBLH)->(dbGoTop())				
			Else
			    //LGS#20200204 - Adequação de release 12.1.25 e posteriores
				//Conout("Não foi encontrado dados no ponto de entrada SPEDALTH para compor Bloco H")
				FwLogMSG( "INFO", , 'SIGAFIS', funname(), '', '01', "Não foi encontrado dados no ponto de entrada SPEDALTH para compor Bloco H", 0 )
				Loop
			Endif
			
		ElseIF cMotInv == "02" .and. lNvcampos .and. !aExistBloc[26] .And. lExistF0M .And. F0M->(MsSeek( xFilial("F0M") + DTOS(dDataFec)))		
			lAchouF0M := .T.
			
			cAliBLH := GetNextAlias()
			
			BeginSql Alias cAliBLH
			
			COLUMN F0M_DTFECH AS DATE 

			SELECT F0M_CODIGO,F0M_UM,F0M_QUANT,F0M_VUNIT,F0M_VALCMD,F0M_CLIFOR,F0M_LOJA,F0M_SITUA,F0M_TPCF,F0M_CONTA,F0M_CST,F0M_ALIQ,F0M_BASICM,F0M_TOTICM
			FROM 	%TABLE:F0M% F0M
				WHERE  F0M.F0M_FILIAL=%XFILIAL:F0M%
				AND F0M.F0M_DTFECH = %Exp:DToS(dDataFec)%					
				AND F0M.%NOTDEL%	
			EndSql
			
			DbSelectArea (cAliBLH)
			
			
		ElseIF lSPDBlocH
			SPDBlocH(@cAliBLH,'',dDataFec)
			lAchouF0M := .F.
			
			dbSelectArea(cAliBLH) 
			(cAliBLH)->(dbGoTop())
		Else
		    //LGS#20200204 - Adequação de release 12.1.25 e posteriores
			//Conout("Não foi encontrada função SPDBlocH ou Dados na tabela F0M")
			FwLogMSG( "INFO", , 'SIGAFIS', funname(), '', '01', "Não foi encontrada função SPDBlocH ou Dados na tabela F0M", 0 )
			Loop
		Endif
		
		nRecCount := (cAliBLH)->(RecCount())
		nI	:= 0
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³No caso de o objeto oProcess existir, significa que a nova barra  ³
		//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
		//| portanto deve ser efetuado os controles para demonstrar o        |
		//| resultado do processamento.                                      |
		//|                                                                  |
		//|Jah que estah rotina efetua o processamento multi-filiais, preciso³
		//| corrigir a posicao da regua, pois no loop a barra fica cheia     |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lExtTAF
			//LGS#20200203 - Adequação de release 12.1.25 e posteriores
			//If Type("oProcess")=="O"
			If _lVerProc
				oProcess:Set2Progress(nRecCount)
			EndIf
		EndIf
		
		Do While (cAliBLH)->(!Eof())
			nI++			
			nBasIcm		:= 0
			nTotICM		:= 0
			cClifor	:=	Space(ntamCli)
			cLoja	:=	Space(nTamLoj)
			cTPCF 		:= ""
			
			lATribF0Q 	:= .F.
			cSegUnid 	:= ''			
			cTpUnid 	:= ''
			nConvUnid 	:= 0
			nVlIteIR	:= 0
			
			//Processa registros ja gravados na tabela F0M
			IF lAchouF0M
				cProd		:= PadR(Alltrim((cAliBLH)->F0M_CODIGO),nTamProd)   	// 01 - Produto.
				cUnid		:= (cAliBLH)->F0M_UM       	// 02 - Unidade.
				nQuant		:= (cAliBLH)->F0M_QUANT 		// 03 - Quantidade.
				nValUnit	:= (cAliBLH)->F0M_VUNIT	 	// 04 - Valor Unidade.
				nVlrIte 	:= (cAliBLH)->F0M_VALCMD     	// 05 - Valor Total.
				cClifor		:= (cAliBLH)->F0M_CLIFOR     	// 06 - Codigo do Cliente/Fornecedor.
				cLoja		:= (cAliBLH)->F0M_LOJA       	// 07 - Codigo da loja Cliente/Fornecedor.
				cSituacao 	:= (cAliBLH)->F0M_SITUA   	// 08 - Situacao do estoque.
				cTPCF		:= (cAliBLH)->F0M_TPCF       	// 09 - Cliente/Fornecedor.
				//F0M->F0M_FILIAL		// 10 - Filial.
				cCodCtaH010 := (cAliBLH)->F0M_CONTA		// 11 - Conta contabil
				cClasFis	:= (cAliBLH)->F0M_CST			// 12 - Classificacao fiscal
				nAliqProd	:= (cAliBLH)->F0M_ALIQ		// 13 - Aliquota Produto
				nBasIcm 	:= (cAliBLH)->F0M_BASICM		// 14 - Base ICMS H020
				nTotICM		:= (cAliBLH)->F0M_TOTICM		// 15 - Total ICMS H020
				
				//Tratamento para cadastros F0M antes da criação do campo F0M_VUNIT
				//Calculo realizado conforme MATXSPED
				IF nValUnit = 0
					nValUnit := Round(nVlrIte / nQuant,6)
				Endif
			Else
			//Processa Retorno da rotina SPDBlocH
				//Tratamento cliente e loja para produtos Em/De terceiro				
				IF (cAliBLH)->IND_PROP <> '0'
					cClifor		:= SubsTring((cAliBLH)->COD_PART,4,ntamCli)
					cLoja		:= SubsTring((cAliBLH)->COD_PART,4+ntamCli,nTamLoj)
					//Define cadastro  F = Fornecedor SA2 ou C =  Cliente SA1
					If SubsTring((cAliBLH)->COD_PART,1,3) == 'SA1'
						cTPCF		:= 'C'
					Else
						cTPCF		:= 'F'
					Endif
				Endif
				
				//(cAliBLH)->FILIAL,;		// 10 - Filial.
				cProd		:= PadR(Alltrim((cAliBLH)->COD_ITEM),nTamProd)   	// 01 - Produto.
				cUnid		:= (cAliBLH)->UNID      	// 02 - Unidade.
				nQuant		:= (cAliBLH)->QTD 			// 03 - Quantidade.
				nValUnit	:= (cAliBLH)->VL_UNIT		// 04 - Valor Unidade.
				nVlrIte		:= (cAliBLH)->VL_ITEM   	// 05 - Valor Total.
				cSituacao	:= (cAliBLH)->IND_PROP		// 08 - Situacao do estoque.

				nVlIteIR	:= IF((cAliBLH)->VL_ITEM_IR > 0,(cAliBLH)->VL_ITEM_IR,nVlrIte)	//11 - Valor do item para efeitos do Imposto de Renda.
				cCodCtaH010	:= (cAliBLH)->COD_CTA	// 11 - Conta contabil
				cClasFis	:= (cAliBLH)->COD_ORIG + (cAliBLH)->CL_CLASS	// 12 - Classificacao fiscal
				nAliqProd	:= (cAliBLH)->ALQ_PICM	// 13 - Aliquota Produto
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³No caso de o objeto oProcess existir, significa que a nova barra  ³
			//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
			//| portanto deve ser efetuado os controles para demonstrar o        |
			//| resultado do processamento.                                      |
			//|                                                                  |
			//³Definindo o segundo incremento da regua e seu controle de detalhes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lExtTAF
    			//LGS#20200203 - Adequação de release 12.1.25 e posteriores
	    		//If Type("oProcess")=="O"
		    	If _lVerProc
					oProcess:Inc2Progress("Processando Inventário("+Str(nInv,3)+"/"+Str(nCtdInv,3)+")",StrZero(nI,6)+"/"+StrZero(nRecCount,6))
		
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Condicao implementada para controlar os numeros apresentadas na tela³
					//³  de processamento da rotina, os detalhes.                          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If cTimeDocs<>Time()
						oProcess:SetDetProgress(STR0026,nRecCount,;	  			//"Total de registros do periodo solicitado"
								STR0027,nDocsXTime,;			   		  			//"Total de registros processados por segundo"
								STR0028,nRecCount-nI,;		   		  			//"Total de registros pendentes para processamento"
								STR0029,Round((nRecCount-nI)/nDocsXTime,0))		//"Tempo estimado para termino do processamento (Seg.)"
								
						cTimeDocs	:=	Time()
						nDocsXTime	:=	1
					Else
						nDocsXTime	+=	1
					EndIf
		
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Controle do cancelamento da rotina³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If oProcess:Cancel()
						Exit
					EndIf
				Else
					IncProc(STR0004+SM0->M0_CODFIL+" / "+AllTrim(SM0->M0_FILIAL)) //"Processando filial: "
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Controle do cancelamento da rotina³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Interrupcao(@lEnd)
						Exit
					EndIf
				EndIf  
			EndIf
			
			//verifica se produto esta cadastrado na F0Q, caso sim não precisa verificar B5_ALTTRIB
			If lTipoinv .And. cMotInv $ "02|03|04|05" .And. F0Q->(MsSeek(xFilial("F0Q")+DTOS(dDataFec)+PadR(Alltrim(cProd),nTamCOD)))
				lATribF0Q := .T.
			Endif
			
			IF nAliqProd <= 0 //Caso produto sem aliquota usa do parametro MV_ICMPAD
				nAliqProd	:= nAliqint
			Endif
			
			//Verifica se existe F0M, caso sim não precisa validar B5_ALTTRIB ou F0Q, validação foi feita na rotina FISA116
			If lAchouF0M .or. lATribF0Q .Or. SpedMotInv(cMotInv,cProd,@nAliqProd)
				
				//Quando operação De/Em Terceiro grava 0150 e flhos
				//³GRAVACAO REGISTRO 0150 - TABELA DE CADASTRO DE PARTICIPANTES
				//³GRAVACAO REGISTRO 0175 - ALTERACAO DA TABELA DE CADASTRO DE PARTICIPANTE
				If cSituacao $ '1|2' .And. !Empty(cClifor)
					If cTPCF=="F"
						If SA2->(MsSeek(xFilial("SA2")+cClifor+cLoja))
							aPartDoc :=	InfPartDoc("SA2")
						EndIf
					ElseIf cTPCF=="C"
						If SA1->(MsSeek(xFilial("SA1")+cClifor+cLoja))
							aPartDoc :=	InfPartDoc("SA1")
						EndIf
					Endif
					
					If !lExtTAF .And. Len(aPartDoc) > 0
						SDPF150175(@aReg0150,aPartDoc,cAlias,aWizard,aExistBloc)
					EndIf
					
					//Atualiza para Cliente/fornecedor conforme aPartDoc do registro 0150
					cClifor := Iif(Len(aPartDoc)>0,aPartDoc[1],"")
				Endif				
				
				If lExtTAF			    
					cProd 			:= 	cProd
				Else
					cProd 			:= 	cProd+Iif(lConcFil,xFilial ("SB1"),"") 
				EndIF
				
				//Posicionando o cadastro de produtos para verificacao da funcao SFRG0200 // Gerar registro 0220 - Fatores de Conversão de Unidades
				If SB1->(MsSeek(xFilial("SB1")+PadR(Alltrim(cProd),nTamProd)))
					cSegUnid		:= SB1->B1_SEGUM
					nConvUnid		:= SB1->B1_CONV
					cTpUnid			:= SB1->B1_TIPCONV
					//Caso não tenha sido informada conta pego do produto.
					IF Empty(cCodCtaH010)
						cCodCtaH010		:= SB1->B1_CONTA
					Endif
					//Caso não tenha sido informada Unidade pego do produto.
					IF Empty(cUnid)
						cUnid		:= SB1->B1_UM
					Endif
				Endif
				
				//Verificando se existe o PE SPDFIS07 para alterar a conta contabil obtida pelo sistema padrao
				If aExistBloc[16]
					cCodCtaH010 := 	ExecBlock("SPDFIS07", .F., .F., {cProd,cSituacao,''}) //Removido armazem
				EndIf
	
				//Ponto de entrada para taratmento da informação de produtos quando o mesmo estah fora do padrao do sistema
				If aExistBloc[05] 
					aProd := Execblock("SPEDPROD", .F., .F., {"SB1","H010",cUnid})
					If Len(aProd)>=11
						cProd 	:= 	aProd[1]
						cUnid	:=	aProd[5]
					Else
						aProd := {"","","","","","","","","","","",""}
					EndIf					
				EndIf
								
				If !lExtTAF
					//³GRAVACAO - REGISTRO 0200 PARA PRODUTOS DO INVENTARIO        ³
					SFRG0200(cAlias,@aReg0200,@aReg0190,dDataDe,dDataAte,aProd,cProd,@aReg0220,,cUnid,,,,,,,,,{cSegUnid,nConvUnid,cTpUnid},,,,,,,,aWizard)
				EndIf
				
				nRegsProc	+=	1				

				/*No caso de o objeto oProcess existir, significa que a nova barra
				 de processamento (CLASSE Fiscal) estah em uso pela rotina,
				 portanto deve ser efetuado os controles para demonstrar o
				 resultado do processamento.
				 Definindo o segundo incremento da regua e seu controle de detalhes*/
				If !lExtTAF
         			//LGS#20200203 - Adequação de release 12.1.25 e posteriores
		         	//If Type("oProcess")=="O"
         			If _lVerProc
						oProcess:Inc1Progress("Processando Inventário - Gravando estruturas H005/H010",StrZero(nRegsProc,6)+"/"+StrZero(nRecCount,6))
				
						//Condicao implementada para controlar os numeros apresentadas na tela
						//  de processamento da rotina, os detalhes.
						If cTimeDocs<>Time()
							oProcess:SetDetProgress(STR0026,nRecCount,;					//"Total de registros do periodo solicitado"
									STR0027,nDocsXTime,;	  							//"Total de registros processados por segundo"
									STR0028,nRecCount-nRegsProc,;						//"Total de registros pendentes para processamento"
									STR0029,Round((nRecCount-nRegsProc)/nDocsXTime,0))	//"Tempo estimado para termino do processamento (Seg.)"
									
							cTimeDocs	:=	Time()
							nDocsXTime	:=	1
						Else
							nDocsXTime	+=	1
						EndIf
				
						//Controle do cancelamento da rotina
						If oProcess:Cancel()
							Exit
						EndIf
					Else
						IncProc(STR0004+SM0->M0_CODFIL+" / "+AllTrim(SM0->M0_FILIAL)) //"Processando filial: "
						
						//Controle do cancelamento da rotina
						If Interrupcao(@lEnd)
							Exit
						EndIf
					EndIf      
				EndIf
							

				nX := aScan(aAuxH005, {|aX| aX[1]+Dtos(aX[3])==cMotInv+DTOS(dDataFec)})		
				If nX == 0
					aAdd (aAuxH005, {})
					nX	:=	Len(aAuxH005)			
					aAdd (aAuxH005[nX], cMotInv)			
					aAdd (aAuxH005[nX], 0)
					aAdd (aAuxH005[nX], dDataFec)
				Endif
				nRegPai := nX
				
				nPos		:=	aScan(aRegH010,{ |x| x[1]==nRegPai .And. x[3]+x[8]+x[9] == cProd+cSituacao+cClifor})
				cMsgh020	:= ""				
				lProcF0M	:= .F.
				lGeraH020 := IF(nPos==0,.T.,.F.) //Verifica se esta incluindo H010
				
				IF cMotInv<>"01".And. nVlrIte > 0
					cMsgh020  := cMVH020
					IF  !aExistBloc[26] .And. (lAchouF0M .Or. F0M->(MsSeek( xFilial("F0M") + DTOS(dDataFec) + PadR(Alltrim(cProd),nTamCOD)+cClasFis+cSituacao+SubsTring(cClifor,4+len(Iif(lConcFil,cFilAnt,"")),ntamCli+nTamLoj))))
						lProcF0M := .T.
					Endif
				Endif
				
				If nPos==0
					aAdd (aRegH010, {})
					nPos := Len(aRegH010)
					aAdd (aRegH010[nPos], nRegPai) 				//00 - RELACIONAMENTO COM O CABECALHO
					aAdd (aRegH010[nPos], Iif( !lExtTAF, "H010", "T079AA" ))		//01-REG
					aAdd (aRegH010[nPos], cProd)				//02-COD_ITEM
					aAdd (aRegH010[nPos], cUnid)				//03-UNID
					aAdd (aRegH010[nPos], Iif( !lExtTAF , {nQuant,3}, nQuant))								//04-QTD
					aAdd (aRegH010[nPos], Iif( !lExtTAF, {nValUnit,6}, Val2Str( nValUnit, 16, 6 ) ) )		//05-VL_UNIT
					aAdd (aRegH010[nPos], nVlrIte)				//06-VL_ITEM							
					aAdd (aRegH010[nPos], cSituacao)			//07-IND_PROP
					aAdd (aRegH010[nPos], cClifor)				//08-COD_PART
					aAdd (aRegH010[nPos], cMsgh020)				//09-TXT_COMPL
					aAdd (aRegH010[nPos], cCodCtaH010)			//10-COD_CTA
					IF ddatade >= ctod('01/01/2015') 
						aAdd (aRegH010[nPos], nVlIteIR)			//11-VL_ITEM_IR
					EndIF
				Else
					If !lExtTAF
						aRegH010[nPos,5, 1]		+=	nQuant
					Else
						aRegH010[nPos,5]		+=	nQuant
					EndIf
					aRegH010[nPos,7]			+=	nVlrIte
					If !lExtTAF
						aRegH010[nPos,6, 1]		+=	nValUnit
					Else
						aRegH010[nPos,6]		+=	nValUnit
					EndIf
					If ddatade >= ctod('01/01/2015')
						aRegH010[nPos,12]		+=	nVlIteIR
					EndIF		
				Endif	
				
				aAuxH005[nX][2] += nVlrIte 			
				
				If cMotInv<>"01" //.And. nVlrIte > 0 //H020 é obrigatorio para motivo de inventário diferente de 01
				
					//Caso esteja incluindo H010 e possuir PE ou F0M processa somente uma vez H020
					If lGeraH020 .And. (aExistBloc[27] .Or. lProcF0M)
						aPeH020	:= {}
						aAdd (aRegH020, {})
						nPosH020	:=	Len(aRegH020)
						aAdd (aRegH020[nPosH020], nPos)
						aAdd (aRegH020[nPosH020], Iif( !lExtTAF, "H020", "T079AB" ) )
						
						IF aExistBloc[27]
								aPeH020 := Execblock("SPEDH020", .F., .F., {aRegH010[nPos][3]})
						EndIF
						
						IF Valtype(aPeH020) == 'A' .AND. Len(aPeH020) >= 1 .AND. Len(aPeH020[1]) >=3
							//Preencher H020 com informações do PE
							aAdd (aRegH020[nPosH020], aPeH020[1][1])
							aAdd (aRegH020[nPosH020], aPeH020[1][2])
							aAdd (aRegH020[nPosH020], aPeH020[1][3])
							
						ElseIf lExistF0M .And. lProcF0M
							//Novo tratamento pela rotina FISA116 (tabela F0M)
							aAdd (aRegH020[nPosH020], cClasFis)
							aAdd (aRegH020[nPosH020], nBasIcm)
							aAdd (aRegH020[nPosH020], nTotICM)			
						Endif
					Endif
					
					//Caso esteja não exista PE ou F0M processa Soma H010
					IF  !aExistBloc[27] .And. !lProcF0M
						If (nH:= Ascan(aRegH020,{|x|x[1]==nPos})) == 0
							aAdd (aRegH020, {})
							nPosH020	:=	Len(aRegH020)
							aAdd (aRegH020[nPosH020], nPos)
							aAdd (aRegH020[nPosH020], Iif( !lExtTAF, "H020", "T079AB" ) )
							//Preencher H020 com informações do Inventário
							aAdd (aRegH020[nPosH020], cClasFis)
							aAdd (aRegH020[nPosH020], nVlrIte/nQuant)
							aAdd (aRegH020[nPosH020], ((nVlrIte/nQuant)*nAliqProd) / 100)
						Else
							aRegH020[nH][4] += nVlrIte/nQuant
							aRegH020[nH][5]	+= (((nVlrIte/nQuant)*nAliqProd) / 100)
						EndIF
					EndIF
				Endif	
			
			EndIf		
			
			(cAliBLH)->(dbSkip())
		Enddo
		//Caso Processe F0M não existirar tabela temporia
		If !lAchouF0M
			(cAliBLH)->(dbCloseArea())
			Ferase(cAliBLH+GetDBExtension())
		Endif
		
	Next nY
	SM0->(DbSkip ())	
End
	
//³Restauro a area de processamento do SIGAMAT³
RestArea(aAreaSM0)
cFilAnt := FWGETCODFILIAL

//³Avalio o controle de cancelamento de execucao, antes de prosseguir³
If !lExtTAF
	If Type("oProcess")=="O"
		//³Controle do cancelamento da rotina³
		If oProcess:Cancel()
			Return
		EndIf
	Else
		//³Controle do cancelamento da rotina³
		If Interrupcao(@lEnd)
			Return
		EndIf
	EndIf      
EndIf

If len(aAuxH005) > 0
	For nX := 1 To  len(aAuxH005)
		//³REGISTRO H005 - TOTAIS DO INVENTARIOS³
		aAdd(aRegH005, {})
		nY := Len(aRegH005)	
		aAdd (aRegH005[nY], Iif( !lExtTAF, "H005", "T079" ) )	//01 - REG
		aAdd (aRegH005[nY], aAuxH005[nX][3])							//02 - DT_FIN
		aAdd (aRegH005[nY], aAuxH005[nX][2])  		 			//03 - VL_INV
		If cVersao >= "006"
			aAdd (aRegH005[nY],	aAuxH005[nX][1])				//04 - MOT_INV
		Endif	
	Next

	If !lExtTAF	
		SPEDRegs(cAlias,{aRegH005,aRegH010,aRegH020})
		//GrRegDep(cAlias,aRegH010,aRegH020,.T.)	
		//GrRegDep(cAlias,aRegH005,aRegH010)	
	Else
		aRegT079AA := aRegH010
		aRegT079AB := aRegH020		
	EndIf

	If lExtTAF
		aRegT079 := aRegH005
	EndIf
Else
	dDataFec :=	Iif( !lExtTAF, SToD(aWizard[1][8]), aWizard[2][9] )
	cMotInv	 :=	Iif( !lExtTAF, Substr(aWizard[1][19],1,2), Substr(aWizard[2][7],1,2) )	
	aAdd(aRegH005, {})
	aAdd (aRegH005[Len(aRegH005)], Iif( !lExtTAF, "H005", "T079" ) )	//01 - REG
	aAdd (aRegH005[Len(aRegH005)], dDataFec)					//02 - DT_FIN
	aAdd (aRegH005[Len(aRegH005)], nAcVlrEst)  		 		//03 - VL_INV
	If cVersao >= "006"
		aAdd (aRegH005[Len(aRegH005)],	cMotInv)				//04 - MOT_INV
	Endif

	If !lExtTAF	
		GrvRegTrS (cAlias,,aRegH005)
	Else
		aRegT079 := aRegH005
	EndIf
Endif
	
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Reg1100Spd | Autor ³Gustavo G. Rueda             ³ Data ³03.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³OPERACEOS DE EXPORTACAO DIRETA E INDIRETA                          ³±±
±±³          ³                                                                   ³±±
±±³          ³- Geracao e gravacao dos Registros 1100, 1105, 1110                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpL1 := Reg1100spd(cAlias,dDataDe,dDataAte,aReg0200,aReg0190,;    ³±±
±±³          ³                 aReg0220,aReg0150)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias do TRB que recebera as informacoes                 ³±±
±±³          ³dDataDe  -> Data inicial do processamento do SPED Fiscal           ³±±
±±³          ³dDataAte -> Data final do processamento do SPED Fiscal             ³±±
±±³          ³aReg0200 -> Array com as informacoes a sere retornadads por        ³±±
±±³          ³ referencia para gerar o registro 0200                             ³±±
±±³          ³aReg0190 -> Array com as informacoes a sere retornadads por        ³±±
±±³          ³ referencia para gerar o registro 0190                             ³±±
±±³          ³aReg0220 -> Array com as informacoes a sere retornadads por        ³±±
±±³          ³ referencia para gerar o registro 0220                             ³±±
±±³          ³aReg0150 -> Array com as informacoes a serem retornadas por refe-  ³±±
±±³          ³ rencia para gerar o registro 0150                                 ³±±
±±³          ³aWizard  -> Informacoes do wizard da rotina                        ³±±
±±³          ³cFilDe -> Filial inicial para processament multifilial             ³±±
±±³          ³cFilAte -> Filial final para processament multifilial              ³±±
±±³          ³aLisFil -> Listas das filiais validas para processament multifilial³±±
±±³          |oProcess -> Objeto da nova barra de progressao                     ³±±
±±³          ³lEnd -> Flag de cancelamento de execucao                           ³±±
±±³          ³nCtdFil   -> Quantidade de registros da tabela SM0 que serao       ³±±
±±³          ³lEnd     -> Flag de encerramento do processamento da regua         ³±±
±±³          ³bWhileSM0 -> Condicao padrao para o while do SM0                   ³±±
±±³          ³             processados                                           ³±±
±±³          ³nCountTot -> Total de registros a serem processados no periodo     ³±±
±±³          ³nRegsProc -> Registros jah processados antes da chamada desta funca³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 - Sempre .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Reg1100Spd(cAlias,aReg0200,aReg0190,aReg0220,aReg0150,aWizard,cFilDe,cFilAte,aLisFil,oProcess,nCtdFil,lEnd,bWhileSM0,nCountTot,nRegsProc, lExtratTaf, aRegT066, aRegT066AA, aRegT066AB)

Local	aReg1100	:=	{}
Local	aReg1105	:=	{}
Local	aReg1110	:=	{}
Local	lRet		:=	.T.
Local	cAliasCDL	:=	"CDL"
Local	cProd		:=	""
Local 	cCFOPInd 	:= 	aSPDSX6[MV_EXPIND]  
Local	cAliasQry	:=	"SFT"
//Local	aPar		:=	{}
Local	lTop		:=	.F.
Local	cAliasSB1	:=	"SB1"
//Local	cAliasSA1	:=	"SA1"
//Local	cAliasSA2	:=	"SA2"
Local	nPos1100	:=	0	
Local	nPos1105    :=	0
Local	nIndex		:= 	0  
Local   nRecnoCDL   :=  0
Local	cIndex		:= 	""
Local	cFiltro		:= 	""
Local	aGrava		:=	{}
Local	aProd		:=	Nil
Local	cUnid		:=	Nil
Local	aSpdFis02	:=	{}  
//Local   aRecnoCDL   :=  {}
Local	dDataDe		:=	''
Local	dDataAte	:=	''
Local	nFilial		:=	0
Local	nEmpProc	:=	0
Local	cTimeDocs	:=	""
Local	nDocsXTime	:=	1
Local	aAreaSM0	:=	SM0->(GetArea())
Local	nSv1Progress:=	0
Local	nSv2Progress:=	0  
Local   lReprocCDL  := 	.F.            
Local	cChvCDL		:=	""     
Local   cOrdBy      :=  ""
Local   aItemCDL    :=  {}
Local	nDBFRecOri	:=	0  
Local   lUltReg     := .F.
Local   _lVerProc   := Type("oProcess")=="O"
Local 	cSFTChv 	:= ""    
Local 	cChvWhl		:= ""        

Default lExtratTaf := .F. 

if !lExtratTAF
	dDataDe	  := SToD(aWizard[1][1])
	dDataAte  := STod(aWizard[1][2])
else
	dDataDe  :=	aWizard[1][3]
	dDataAte :=	aWizard[1][4]	
endif

SFT->(DbSetOrder (1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³No caso de o objeto oProcess existir, significa que a nova barra  ³
//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
//| portanto deve ser efetuado os controles para demonstrar o        |
//| resultado do processamento.                                      |
//|                                                                  |
//|Jah que estah rotina efetua o processamento multi-filiais, preciso³
//| corrigir a posicao da regua, pois no while principal da SFT      |
//| deixou a barra no final, pois processou todas as filiais.        |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("oProcess")=="O" .and. !lExtratTaf
	oProcess:Set1Progress(nCtdFil)
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processamento de multifiliais³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea ("SM0")
SM0->(DbGoTop ())
SM0->(MsSeek (cEmpAnt+cFilDe, .T.))	//Pego a filial mais proxima 
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quando a opcao de seleciona filiais estiver configurada como sim, serah    ³
//³    considerado as filiais selecionadas no browse. Caso contrario, valera o³
//³    que estiver configurado na pergunta 'Filial DE/ATE'                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do While Eval(bWhileSM0)
	
	cFilAnt 	:= 	FWGETCODFILIAL
	
	If Len(aLisFil)>0 .And. cFilAnt <= cFilAte
       nFilial := Ascan(aLisFil,{|x|x[2]==cFilAnt})
	   If nFilial==0 .Or. !(aLisFil[nFilial,1])  //Filial não marcada, vai para proxima
			SM0->(dbSkip()) 
			Loop
		EndIf
	Else
		If (!lExtratTAF .and. "1" $ aWizard[1][12]) .or. (lExtratTAF .and. "1" $ aWizard[1][5])  //Somente faz skip se a opção de selecionar filiais estiver como Sim.
			 SM0->( dbSkip())
			 Loop
		EndIf		
	EndIf
	
	nEmpProc	+=	1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³No caso de o objeto oProcess existir, significa que a nova barra  ³
	//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
	//| portanto deve ser efetuado os controles para demonstrar o        |
	//| resultado do processamento.                                      |
	//|                                                                  |
	//³Definicao o primeiro incremento da regua                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//LGS#20200203 - Adequação de release 12.1.25 e posteriores
	//If Type("oProcess")=="O"
	If _lVerProc

		if !lExtratTaf
			oProcess:Inc1Progress(STR0023+cEmpAnt+"/"+cFilAnt,StrZero(nEmpProc,3)+"/"+StrZero(nCtdFil,3))	//"Processando empresa :"
			oProcess:Inc2Progress("Processando documentos de exportacao...",StrZero(nRegsProc,6)+"/"+StrZero(nCountTot,6))
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Controle do cancelamento da rotina³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If oProcess:Cancel()
				Exit
			EndIf          
		endif
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Controle do cancelamento da rotina³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Interrupcao(@lEnd)
			Exit
		EndIf
	EndIf 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query para pegar todas as declaracoes de exportacao cadastrados na³
	//³ CDL e com data de avebacao no periodo                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#IFDEF TOP
	    If (TcSrvType ()<>"AS/400")
	    	lTop		:=	.T.
	    	cAliasCDL	:=	GetNextAlias()
	    	cOrdBy      := "%"+SqlOrder(CDL->(IndexKey()))+"%"	    		    		    	
	    	
	    	BeginSql Alias cAliasCDL
			
			COLUMN CDL_DTDE AS DATE
			COLUMN CDL_DTREG AS DATE
	    	COLUMN CDL_DTCHC AS DATE
	    	COLUMN CDL_DTAVB AS DATE
	      	COLUMN CDL_EMIEXP AS DATE 
	    	
			SELECT * FROM %Table:CDL% CDL
			WHERE 
				CDL.CDL_FILIAL=%xFilial:CDL% AND 
				CDL.CDL_DTAVB>=%Exp:DToS(dDataDe)% AND 
				CDL.CDL_DTAVB<=%Exp:DToS(dDataAte)% AND 
				CDL.%NotDel%
			ORDER BY
				%Exp:cOrdBy%
			EndSql
		Else
	#ENDIF
		    cIndex	:= CriaTrab(NIL,.F.)                                                                                                      	
		    	    			    
		    cFiltro	:= 'CDL_FILIAL=="'+xFilial ("CDL")+'".And.'
		   	cFiltro += 'DToS (CDL_DTAVB)>="'+DToS(dDataDe)+'".And.DToS(CDL_DTAVB)<="'+DToS(dDataAte)+'" '
			cOrdBy  := CDL->(IndexKey())
			
		    IndRegua (cAliasCDL,cIndex,cOrdBy,,cFiltro)
		    nIndex := RetIndex(cAliasCDL)
			
			#IFNDEF TOP
				DbSetIndex(cIndex+OrdBagExt())
			#ENDIF
			
			DbSelectArea(cAliasCDL)
		    DbSetOrder(nIndex+1) 
		    CDL->(DBGOTOP()) 
		    
	#IFDEF TOP
		Endif
	#ENDIF
	
	ProcRegua ((cAliasCDL)->(RecCount ()))
	
	lReprocCDL 	:= .F.       
	lUltReg     := .F.	
	nRecnoCDL  	:= 	0
	nDBFRecOri	:=	0
	cAlsCDLOld	:=	cAliasCDL 
	
	Do While !(cAliasCDL)->(Eof())
		
		nRegsProc	+=	1
		 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento abaixo (IF) se refere a uma implementacao no MATA926 que permite o usuario      ³
		//³  amarrar por item de documento fiscal a tabela CDL. Tambem foi implementado um facilitador³
		//³  que caso o item esteja em branco, ele possa ser considerado para os itens que nao foram  ³
		//³  amarrados 1:1. Ex: Em uma NF com 3 itens, pode-se incluir um CDL para o Item 1 e outro   ³
		//³  com o item em branco que passa a valer para o item 2 e 3.                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    If !lUltReg .And. ;	//Tratamento somente para quando existir o campo CDL_ITEMNF, caso contrario, nada muda, fica como sempre esteve antes
	    	( cChvCDL <> (cAliasCDL)->( CDL_SERIE+CDL_DOC+CDL_CLIENT+CDL_LOJA ) .Or. ;		//Se mudar a NF e tiver recno para processar
	    	( cChvCDL == (cAliasCDL)->( CDL_SERIE+CDL_DOC+CDL_CLIENT+CDL_LOJA ) .And. Empty( (cAliasCDL)->CDL_ITEMNF ) ) )	//Se for a mesma nota e o item em branco nao for o primeiro da CDL

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tratamento para o Recno do registro do CDL_ITEMNF em branco, pois preciso processa-lo quando mudar a chave³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    	If nRecnoCDL > 0
	    		If !lTop	//Para TOP tenho duas tabelas de trabalho, a QUERY e a tabela FISICA CDL, em DBF nao, soh a CDL
	    			nDBFRecOri	:=	(cAliasCDL)->( Recno() )
	    		EndIf
   				CDL->(DbGoTo(nRecnoCDL))	//Posiciono no RECNO do CDL_ITEMNF em branco para processa-lo com os mesmos tratamentos abaixo, no final do SKIP, retorno as variaveis e o registro de onde parei para continuar o processamento
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Troco o alias da tabela somente para processar o registro em com o item em ³
				//³   branco que teve o recno armazenado. Depois de processar este CDL, volto ³
				//³   o alias da query e continuo da posicao que havia parado                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cAliasCDL	:=	"CDL"
	   			nRecnoCDL 	:= 	0

	    	Else
				cChvCDL		:=	(cAliasCDL)->( CDL_SERIE+CDL_DOC+CDL_CLIENT+CDL_LOJA )
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Para o CDL_ITEMNF em branco, quando for encontrado, armazeno o registro    ³
				//³  para processa-lo ao final da quebra por documento ou no final do arquivo.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    		If Empty( (cAliasCDL)->CDL_ITEMNF )
			    	nRecnoCDL	:=	(cAliasCDL)->( Iif( lTop , R_E_C_N_O_ , Recno() ) )
	    	        	    			
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Avanco para proximo registro³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			    	(cAliasCDL)->( dbSkip() )
			    				    	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se estiver em final de arquivo eu devo processar o while mais uma vez caso³
					//³possua RECNO armazenado                                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			    	If (cAliasCDL)->( Eof() )
   			    		If !lTop	//Para TOP tenho duas tabelas de trabalho, a QUERY e a tabela FISICA CDL, em DBF nao, soh a CDL
			    			nDBFRecOri	:=	(cAliasCDL)->( Recno() )
			    		EndIf
		   				CDL->(DbGoTo(nRecnoCDL))	//Posiciono no RECNO do CDL_ITEMNF em branco para processa-lo com os mesmos tratamentos abaixo, no final do SKIP, retorno as variaveis e o registro de onde parei para continuar o processamento
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Troco o alias da tabela somente para processar o registro em com o item em ³
						//³   branco que teve o recno armazenado. Depois de processar este CDL, volto ³
						//³   o alias da query e continuo da posicao que havia parado                 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   				cAliasCDL	:=	"CDL"
		   				nRecnoCDL 	:= 	0
			    	Else
				    	Loop
				    EndIf
				EndIf
		    EndIf
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³No caso de o objeto oProcess existir, significa que a nova barra  ³
		//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
		//| portanto deve ser efetuado os controles para demonstrar o        |
		//| resultado do processamento.                                      |
		//|                                                                  |
		//|Efetuando o incremento da segunda regua com as informacoes        |       
		//| atualizadas e atualizando os detalhes do processamento           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	//LGS#20200203 - Adequação de release 12.1.25 e posteriores
	    //If Type("oProcess")=="O"
    	If _lVerProc
			if !lExtratTaf
				oProcess:Inc2Progress("Processando documentos de exportacao...",StrZero(nRegsProc,6)+"/"+StrZero(nCountTot,6))
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Condicao implementada para controlar os numeros apresentadas na tela³
				//³  de processamento da rotina, os detalhes.                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cTimeDocs<>Time()
					oProcess:SetDetProgress(STR0026,nCountTot,;	  				//"Total de registros do periodo solicitado"
							STR0027,nDocsXTime,;	 							//"Total de registros processados por segundo"
							STR0028,nCountTot-nRegsProc,;  						//"Total de registros pendentes para processamento"
							STR0029,Round((nCountTot-nRegsProc)/nDocsXTime,0))	//"Tempo estimado para termino do processamento (Seg.)"
				
					cTimeDocs	:=	Time()
					nDocsXTime	:=	1
				Else
					nDocsXTime	+=	1
				EndIf
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Controle do cancelamento da rotina³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If oProcess:Cancel()
					Exit
				EndIf 
			endif
		Else
		
			IncProc("Processando documentos de exportacao...")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Controle do cancelamento da rotina³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Interrupcao(@lEnd)
				Exit
			EndIf
		EndIf
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gerando a estutura do registro 1100³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nPos1100 := aScan(aReg1100,{|aX| aX[3]==(cAliasCDL)->CDL_NUMDE .And. aX[4]==(cAliasCDL)->CDL_DTDE .And. aX[6]==(cAliasCDL)->CDL_NRREG}))==0
			aAdd(aReg1100, {})
			nPos1100 := Len (aReg1100)                           
			aAdd (aReg1100[nPos1100], "1100")							//01 - REG
			aAdd (aReg1100[nPos1100], (cAliasCDL)->CDL_INDDOC)			//02 - IND_DOC
			aAdd (aReg1100[nPos1100], (cAliasCDL)->CDL_NUMDE)			//03 - NRO_DE
			aAdd (aReg1100[nPos1100], (cAliasCDL)->CDL_DTDE)			//04 - DT_DE
			aAdd (aReg1100[nPos1100], (cAliasCDL)->CDL_NATEXP)			//05 - NAT_EXP
			aAdd (aReg1100[nPos1100], (cAliasCDL)->CDL_NRREG)			//06 - NRO_DE
			aAdd (aReg1100[nPos1100], If((cAliasCDL)->CDL_INDDOC == "0",(cAliasCDL)->CDL_DTREG,""))			//07 - DT_RE
			aAdd (aReg1100[nPos1100], (cAliasCDL)->CDL_CHCEMB)			//08 - CHC_EMB
			aAdd (aReg1100[nPos1100], Iif(Empty((cAliasCDL)->CDL_DTCHC),"",(cAliasCDL)->CDL_DTCHC))			//09 - DT_CHC
			aAdd (aReg1100[nPos1100], (cAliasCDL)->CDL_DTAVB)			//10 - DT_AVB
			aAdd (aReg1100[nPos1100], (cAliasCDL)->CDL_TPCHC)			//11 - TP_CHC
			aAdd (aReg1100[nPos1100], (cAliasCDL)->CDL_PAIS)			//12 - PAIS
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Montando filtro para a tabela SFT que serah utilizada no processamento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	                                             
		cSFTChv := xFilial(cAliasQry)+"S"+(cAliasCDL)->CDL_SERIE+(cAliasCDL)->CDL_DOC+(cAliasCDL)->CDL_CLIENT+(cAliasCDL)->CDL_LOJA
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para o campo CDL_ITEMNF, que deve fazer parte da query na SFT se existir na base de dados³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSFTChv += (cAliasCDL)->CDL_ITEMNF 

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Para TOP faco um SELECT com JOIN nas tabelas SFT,SB1,SA1,SA1,³
		//³Para DBF faco um indregua na tabela SFT                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SPedSeek(cAliasQry,1,cSFTChv)            
		
			cChvWhl := (cAliasQry)->(FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA)  
			cChvWhl += (cAliasQry)->FT_ITEM
			                                                                  
			Do While !(cAliasQry)->(Eof()) .AND. (cChvWhl==cSFTChv)   
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Tratamento para quando existir o campo CDL_ITEMNF³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Empty( (cAliasCDL)->CDL_ITEMNF ) .And. ;
					(cAliasQry)->( aScan( aItemCDL, { |x| x == FT_NFISCAL + FT_SERIE + FT_CLIEFOR + FT_LOJA + FT_ITEM } ) ) > 0
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Tratamento para armazenar os itens jah processados, para quando for processar a CDL³
					//³  em branco nao repetir os itens jah processados.                                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					(cAliasQry)->(DbSkip())
					Loop
			 	Else				
					Aadd( aItemCDL , (cAliasQry)->( FT_NFISCAL + FT_SERIE + FT_CLIEFOR + FT_LOJA + FT_ITEM ) )
				EndIf

	   			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Identifica se, sendo uma exportacao indireta, se trata da remessa     ³
				//³com fim exclusivo de exportacao a uma comercial exportadora (Trading).³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lExpInd := 	(cAliasCDL)->CDL_NATEXP == "1" .And. Alltrim((cAliasQry)->FT_CFOP)$cCFOPInd

				If !Empty((cAliasCDL)->CDL_PRODNF)
					cProd	:=	(cAliasCDL)->CDL_PRODNF+Iif(lConcFil,xFilial("SB1"),"")				
				Else
					cProd	:=	(cAliasQry)->FT_PRODUTO+Iif(lConcFil,xFilial("SB1"),"")
				EndIf

	            SB1->(MsSeek(xFilial("SB1")+(cAliasQry)->FT_PRODUTO))
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ponto de entrada para taratmento da informação de produtos quando o mesmo estah fora do padrao do sistema³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aExistBloc[05] 
					aProd := Execblock("SPEDPROD", .F., .F., {cAliasQry,"1105"})
					If Len(aProd)>=11
						cProd 	:= 	aProd[1]
						cUnid	:=	aProd[5]
					Else
						aProd := {"","","","","","","","","","","",""}
					EndIf					
				EndIf
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Processamento do ponto de entrada para alteracao da unidade de medida caso exista³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aExistBloc[01]
   					aSpdFis02 := ExecBlock("SPDFIS02", .F., .F., {cAliasQry,(cAliasQry)->FT_TIPOMOV,"1105"})
	
				   If ValType(aSpdFis02)=="A"
				      cUnid     := aSpdFis02[1]
				   Else   
				      cUnid     := ExecBlock("SPDFIS02", .F., .F., {cAliasQry,(cAliasQry)->FT_TIPOMOV,"1105"})
				   EndIf
				EndIf
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³REGISTRO 0200 - TABELA DE IDENTIFICACAO DO ITEM³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aScan(aReg0200, {|aX| aX[2]==cProd})==0 .and. !lExtratTaf
					SFRG0200(cAlias,@aReg0200,@aReg0190,dDataDe,dDataAte,aProd,cProd,@aReg0220,cAliasSB1,cUnid,,,,,,,,,,,,,,,,,aWizard,lExtratTaf)
				EndIf
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³REGISTRO 1105 - DOCUMENTOS FISCAIS DE EXPORTACAO³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	            nPos1105	:=	SPDReg1105(cAliasCDL,cProd,lExpInd,@aReg1105,nPos1100,cAliasQry)
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³REGISTRO 1110 - OPERACOES DE EXPORTACOES INDIRETAS - MERCADORIAS DE TERCEIROS³
				//|                        So para exportacao indireta                          |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nPos1105>0 .And. lExpInd .And. !Empty((cAliasCDL)->CDL_FORNEC)
	
					SPDReg1110(cAliasCDL,@aReg1110,nPos1105,cProd,@aReg0150,cAlias,aWizard,lExtratTaf)
				EndIf
	            
	  	   		(cAliasQry)->(DbSkip()) 
	  	   		
	  	   		cChvWhl := (cAliasQry)->(FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA)  
				cChvWhl += (cAliasQry)->FT_ITEM
			Enddo
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³No caso de o objeto oProcess existir, significa que a nova barra  ³
			//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
			//| portanto deve ser efetuado os controles para demonstrar o        |
			//| resultado do processamento.                                      |
			//|                                                                  |
			//|Tratamento para o cancelamento de execucao da rotina              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			//LGS#20200203 - Adequação de release 12.1.25 e posteriores
			//If Type("oProcess")=="O"
			If _lVerProc
				if !lExtratTaf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Controle do cancelamento da rotina³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If oProcess:Cancel()
						Exit
					EndIf
				endif
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Controle do cancelamento da rotina³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Interrupcao(@lEnd)
					Exit
				EndIf
			EndIf
		
		EndIf		
						
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o alias nao mudou significa que estah no processamento padrao da rotina.                  ³
		//³  Para ambiente TOP indica que nao foi encontrado o CDL_ITEMNF e posso seguir em frente      ³
		//³  Para ambiente DBF, o alias sempre serah CDL, entao tenho a consistencia abaixo que verifica³
		//³     se tive de mudar de registro em algum momento.                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cAliasCDL == cAlsCDLOld
    		If nDBFRecOri > 0	//Se houver numeracao de RECNO quer dizer que foi encontrado o CDL_ITEMNF e que jah foi processado, portanto devo continuar de onde parou.
    			(cAliasCDL)->( DbGoTo( nDBFRecOri ) )
    			nDBFRecOri	:=	0	//Restauro ZERO quando voltar no registro original, para nao deixar sujeira na variavel
    		EndIf

			(cAliasCDL)->(DbSkip())				

	    	If (cAliasCDL)->( Eof() ) .And. nRecnoCDL > 0
	    		If !lTop	//Para TOP tenho duas tabelas de trabalho, a QUERY e a tabela FISICA CDL, em DBF nao, soh a CDL
	    			nDBFRecOri	:=	(cAliasCDL)->( Recno() )
	    		EndIf
   				CDL->(DbGoTo(nRecnoCDL))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Troco o alias da tabela somente para processar o registro em com o item em ³
				//³   branco que teve o recno armazenado. Depois de processar este CDL, volto ³
				//³   o alias da query e continuo da posicao que havia parado                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   				cAliasCDL	:=	"CDL" 	   				
   				nRecnoCDL 	:= 	0   
   				lUltReg     := .T.
   			EndIf
   		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Utilizo o ALIAS inicial do processamento para continuar a executar o³
			//³while do ponto em que parou para gerar o registro com item em branco³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    		cAliasCDL	:=	cAlsCDLOld
		Endif
	EndDo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³No caso de o objeto oProcess existir, significa que a nova barra  ³
	//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
	//| portanto deve ser efetuado os controles para demonstrar o        |
	//| resultado do processamento.                                      |
	//|                                                                  |
	//|Tratamento para o cancelamento de execucao da rotina              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
	//LGS#20200203 - Adequação de release 12.1.25 e posteriores
	//If Type("oProcess")=="O"
	If _lVerProc
	
		if !lExtratTaf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Controle do cancelamento da rotina³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If oProcess:Cancel()
				Exit
			EndIf
		endif
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Controle do cancelamento da rotina³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Interrupcao(@lEnd)
			Exit
		EndIf
	EndIf
	
	SM0->(dbSkip())
End		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restauro a area do SM0³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaSM0)
cFilAnt := FWGETCODFILIAL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³No caso de o objeto oProcess existir, significa que a nova barra  ³
//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
//| portanto deve ser efetuado os controles para demonstrar o        |
//| resultado do processamento.                                      |
//|                                                                  |
//|Tratamento para o cancelamento de execucao da rotina              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
If Type("oProcess")=="O"

	if !lExtratTaf
		nSv1Progress	:=	oProcess:Ret1Progress()
		nSv2Progress	:=	oProcess:Ret2Progress()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Controle do cancelamento da rotina³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If oProcess:Cancel()
			Return
		EndIf    
	endif
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Controle do cancelamento da rotina³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Interrupcao(@lEnd)
		Return
	EndIf
EndIf

if lExtratTaf
	
	aRegT066   := aReg1100
	aRegT066AA := aReg1105
	aRegT066AB := aReg1110
	
else
	
	aAdd(aGrava,aReg1100)
	aAdd(aGrava,aReg1105)
	aAdd(aGrava,aReg1110)
	
	SPEDRegs(cAlias,aGrava,"1100/1105/1110")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³No caso de o objeto oProcess existir, significa que a nova barra  ³
	//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
	//| portanto deve ser efetuado os controles para demonstrar o        |
	//| resultado do processamento.                                      |
	//|                                                                  |
	//|Tratamento para retornar a posicao da barra salva anteriormente   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
	//LGS#20200203 - Adequação de release 12.1.25 e posteriores
	//If Type("oProcess")=="O" .and. !lExtratTaf
	If _lVerProc .and. !lExtratTaf
		oProcess:Set1Progress(nCtdFil,nSv1Progress)
		oProcess:Set2Progress(nCountTot,nSv2Progress)
	EndIf
	
endif
		
Return(lRet)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SPDReg1105| Autor ³Gustavo G. Rueda              ³ Data ³03.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³DOCUMENTOS FISCAIS DE EXPORTACAO                                   ³±±
±±³          ³                                                                   ³±±
±±³          ³- Geracao do Registro 1105                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpN1 := SPDReg1105(cAliasCDL,cProd,lExpInd,aReg1105,nPos1100,;       ³±±
±±³          ³                 cAliasQry)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAliasCDL -> Alias para utilizacao da tabela CDL                   ³±±
±±³          ³cProd     -> Codigo do produto formatado pelo SPED Fiscal          ³±±
±±³          ³lExpInd   -> Flag de indicacao de uma exportacao indireta          ³±±
±±³          ³aReg1105  -> Array com a estrutura do registro 1105 a ser          ³±±
±±³          ³             gravado no futuro.                                    |±±
±±³          ³nPos1100  -> Posicao para relacionamento com o registro 1100       ³±±
±±³          ³cAliasQry -> Alias para a query/indregua na tabela SFT             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1 - Posicao da informacao dentro do array aReg1105             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SPDReg1105(cAliasCDL,cProd,lExpInd,aReg1105,nPos1100,cAliasQry)
	Local	nProc 		:= 	0
	Local   nPos        :=	0 
	
	// conforme chamado TTBGRC, foi verificado que este bloco não deve olhar a CDL
	// Pois o mesmo estará informando apenas a nota de exportação
	// as notas informadas no complemento dever ser registradas no registro 1110
	nProc := aScan(aReg1105, {|aX| aX[1]==nPos1100 .And.; 
							aX[3]==aModNot((cAliasQry)->FT_ESPECIE) .And.;
						 	aX[4]==(cAliasQry)->FT_SERIE .And. ;
						 	aX[5]==(cAliasQry)->FT_NFISCAL .And. ;
						 	aX[6]==(cAliasQry)->FT_CHVNFE .And. ;
						 	aX[7]==(cAliasQry)->FT_EMISSAO .And. ;
						 	aX[8]==cProd})  
	If nProc==0
		aAdd(aReg1105, {})
		nPos	:=	Len (aReg1105)
		
		aAdd (aReg1105[nPos], nPos1100)										//Posicao de relacionamento com o registro 1100
		aAdd (aReg1105[nPos], "1105" )										//01 - REG	
		aAdd (aReg1105[nPos], aModNot((cAliasQry)->FT_ESPECIE))			//02 - COD_MOD
		aAdd (aReg1105[nPos], (cAliasQry)->FT_SERIE)				   		//03 - SERIE
		aAdd (aReg1105[nPos], (cAliasQry)->FT_NFISCAL)						//04 - NUM_DOC
		aAdd (aReg1105[nPos], (cAliasQry)->FT_CHVNFE)		//05 - CHV_NFE
		aAdd (aReg1105[nPos], (cAliasQry)->FT_EMISSAO)						//06 - DT_DOC
		aAdd (aReg1105[nPos], cProd)			   			  					//07 - COD_ITEM
	Else	     
		nPos	:= nProc
	EndIf
	
Return (nPos)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SPDReg1110| Autor ³Gustavo G. Rueda              ³ Data ³03.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³DOCUMENTOS FISCAIS DE EXPORTACAO INDIRETA                          ³±±
±±³          ³                                                                   ³±±
±±³          ³- Geracao do Registro 1110                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpN1 := SPDReg1110(cAliasCDL,aReg1110,nPos1105,cProd,aReg0150,cAlias)³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAliasCDL -> Alias para utilizacao da tabela CDL                   ³±±
±±³          ³aReg1110  -> Array com a estrutura do registro 1110 a ser          ³±±
±±³          ³             gravado no futuro.                                    |±±
±±³          ³nPos1105  -> Posicao para relacionamento com o registro 1105       ³±±
±±³          ³cProd     -> Codigo do produto formatado pelo SPED Fiscal          ³±±
±±³          ³aReg0150  -> Array com a estrutura do registro 0150 a ser          ³±±
±±³          ³             gravado no futuro.                                    |±±
±±³          ³cAlias    -> Alias do arquivo temporario para geracao do TXT       |±±
±±³          ³aWizard   -> Informacoes do wizard da rotina                       ³±±
±±³          ³lExtTaf   -> Indica se a chamada da rotina foi o Extrator          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 - Sempre .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SPDReg1110(cAliasCDL,aReg1110,nPos1105,cProd,aReg0150,cAlias,aWizard,lExtTaf)
Local	lRet		:=	.T.
Local	nPos		:=	0
Local	aPartDoc	:=	{}
Local	cUnid		:=	SD2->D2_UM
Local	nQtde		:=	SD2->D2_QUANT
Local	nDecimal	:= TamSX3("D2_QUANT")[2]	  

Default lExtTaf     := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciono o fornecedor do documento fiscal para utilizar mais abaixo³
//| na gravacao dos registro 0150 e 0175                               |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SPEDSeek("SA2",,xFilial("SA2")+(cAliasCDL)->(CDL_FORNEC+CDL_LOJFOR))
	aPartDoc	:=	InfPartDoc("SA2",,,,,,,lExtTaf)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GRAVACAO REGISTRO 0150 - TABELA DE CADASTRO DE PARTICIPANTES            ³
	//³GRAVACAO REGISTRO 0175 - ALTERACAO DA TABELA DE CADASTRO DE PARTICIPANTE³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lExtTaf
		SDPF150175(@aReg0150,aPartDoc,cAlias,aWizard,aExistBloc)
	EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Este seek na tabela SF3 eh para pegar a nota de entreda da mercadoria de exportacao.³
	//³ Serah utilizada algumas informacoes dela para montar o registro                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SPEDSeek("SF3",5,xFilial("SF3")+(cAliasCDL)->(CDL_SERORI+CDL_DOCORI+CDL_FORNEC+CDL_LOJFOR))
		aAdd(aReg1110, {})
		nPos	:=	Len (aReg1110)
		
		aAdd (aReg1110[nPos], nPos1105)							//Posicao de relacionamento com o registro pai, 1105
		aAdd (aReg1110[nPos], "1110" )							//01 - REG			
		aAdd (aReg1110[nPos], aPartDoc[1])										//02 - COD_PART FORNECEDOR DA MERCADORIA DESTINADA A EXPORTACAO
		aAdd (aReg1110[nPos], aModNot(SF3->F3_ESPECIE))			//02 - COD_MOD DO DOCUMENTO FISCAL DE ENTRADA
		aAdd (aReg1110[nPos], SF3->F3_SERIE)							//03 - SERIE DO DOC DE ENTRADA
		aAdd (aReg1110[nPos], SF3->F3_NFISCAL)							//04 - NUM_DOC DO DOC DE ENTRADA
		aAdd (aReg1110[nPos], SF3->F3_EMISSAO)							//05 - DT_DOC DE EMISSAO DO DOC DE ENTRADA
		aAdd (aReg1110[nPos], SF3->F3_CHVNFE)							//06 - CHV_NFE DO DOC DE ENTRADA
		aAdd (aReg1110[nPos], (cAliasCDL)->CDL_NRMEMO)				//07 - NR_MEMO DE EXPORTACAO
		aAdd (aReg1110[nPos], 0)							      		//08 - QTD EFETIVAMENTE EXPORTADA
		aAdd (aReg1110[nPos], "")					   					//09 - UNID DO PRODUTO
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Este seek se faz necessario porque as duas ultimas informacoes do registro  ³
		//³ sao referentes a nota de exportacao e para exportacao indireta, temos outro³
		//³ documento para este fim, portanto temos que posiciona-lo e utilizar o      ³
		//| produto correspondente                                                     |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SPEDSeek("SD2",3,xFilial("SD2")+(cAliasCDL)->(CDL_NFEXP+CDL_SEREXP))		
			While !SD2->(Eof()) .And. SD2->(D2_DOC+D2_SERIE)==(cAliasCDL)->(CDL_NFEXP+CDL_SEREXP)
				If SD2->D2_COD==SubStr(cProd,1,TamSx3("D2_COD")[1])				
					cUnid	:=	SD2->D2_UM
					nQtde	:=	SD2->D2_QUANT							
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³IF lAchouSF4, significa que achou o SD1/SD2 e tambem o SF4,      ³
					//³  por isso faco este tratamento, senao nao executo o PE, mantendo³
					//³  a regra definida anteriormente.                                ³
					//|                                                                 |
					//|Este PE eh utilizado para quando se deseja alterar a UM e a      |
					//| quantidade padrao calculada pelo sistema. Eh mais utilizado     |
					//| quando se utiliza a quantidade na segunda unidade de medida     |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If aExistBloc[01]
 						aSpdFis02 := ExecBlock("SPDFIS02", .F., .F., {"SD2","S"})
					   If ValType(aSpdFis02)=="A"
					      cUnid     := aSpdFis02[1]
					      nQtde     := aSpdFis02[2]
					   Else   
	  				      cUnid     := ExecBlock("SPDFIS02", .F., .F., {"SD2","S"})
					   EndIf
					EndIf	
					
					aReg1110[nPos][10] :=	{nQtde,Iif(nDecimal > 3,3,nDecimal)}	 		//08 - QTD EFETIVAMENTE EXPORTADA
					aReg1110[nPos][11] :=	cUnid			   			//09 - UNID DO PRODUTO												
					Exit
				EndIf				
				SD2->(dbSkip())
			End
		EndIf
	EndIf	        	
EndIf

Return (lRet)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Reg1100Av | Autor ³Gustavo G. Rueda              ³ Data ³07.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³OPERACEOS DE EXPORTACAO DIRETA E INDIRETA                          ³±±
±±³          ³                                                                   ³±±
±±³          ³- Geracao e gravacao dos Registros 1100, 1105, 1110                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpL1 := eg1100Av(cAlias,dDataDe,dDataAte,aReg0200,aReg0190,;      ³±±
±±³          ³                 aReg0220,aReg0150)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias do TRB que recebera as informacoes                 ³±±
±±³          ³aReg0200 -> Array com as informacoes a sere retornadads por        ³±±
±±³          ³ referencia para gerar o registro 0200                             ³±±
±±³          ³aReg0190 -> Array com as informacoes a sere retornadads por        ³±±
±±³          ³ referencia para gerar o registro 0190                             ³±±
±±³          ³aReg0220 -> Array com as informacoes a sere retornadads por        ³±±
±±³          ³ referencia para gerar o registro 0220                             ³±±
±±³          ³aReg0150 -> Array com as informacoes a serem retornadas por refe-  ³±±
±±³          ³ rencia para gerar o registro 0150                                 ³±±
±±³          ³aWizard  -> Informacoes do wizard da rotina                        ³±±
±±³          ³cFilDe -> Filial inicial para processament multifilial             ³±±
±±³          ³cFilAte -> Filial final para processament multifilial              ³±±
±±³          ³aLisFil -> Listas das filiais validas para processament multifilial³±±
±±³          |oProcess -> Objeto da nova barra de progressao                     ³±±
±±³          ³lEnd -> Flag de cancelamento de execucao                           ³±±
±±³          ³nCtdFil   -> Quantidade de registros da tabela SM0 que serao       ³±±
±±³          ³lEnd     -> Flag de encerramento do processamento da regua         ³±±
±±³          ³bWhileSM0 -> Condicao padrao para o while do SM0                   ³±±
±±³          ³             processados                                           ³±±
±±³          ³nCountTot -> Total de registros a serem processados no periodo     ³±±
±±³          ³nRegsProc -> Registros jah processados antes da chamada desta funca³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Reg1100Av(cAlias,aReg0200,aReg0190,aReg0220,aReg0150,aWizard,cFilDe,cFilAte,aLisFil,oProcess,nCtdFil,lEnd,bWhileSM0,nCountTot,nRegsProc,lExtratTaf, aRegT066, aRegT066AA, aRegT066AB )
Local	aReg1100	:=	{}
Local	aReg1105	:=	{}
Local	aReg1110	:=	{}
Local	nPos1100	:=	0	
Local	nPos1105    :=	0
Local	dDataDe		:=	''
Local	dDataAte	:=	''
Local	aGrava		:=	{}
Local	nFilial		:=	0
Local	nEmpProc	:=	0
Local	cTimeDocs	:=	""
Local	nDocsXTime	:=	1
Local	aAreaSM0	:=	SM0->(GetArea())
Local	nSv1Progress:=	0
Local	nSv2Progress:=	0    
Local   _lVerProc   := Type("oProcess")=="O"
Default lExtratTaf := .F.

if !lExtratTAF
	dDataDe	  := SToD(aWizard[1][1])
	dDataAte  := STod(aWizard[1][2])
else
	dDataDe  :=	aWizard[1][3]
	dDataAte :=	aWizard[1][4]	
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³No caso de o objeto oProcess existir, significa que a nova barra  ³
//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
//| portanto deve ser efetuado os controles para demonstrar o        |
//| resultado do processamento.                                      |
//|                                                                  |
//|Jah que estah rotina efetua o processamento multi-filiais, preciso³
//| corrigir a posicao da regua, pois no while principal da SFT      |
//| deixou a barra no final, pois processou todas as filiais.        |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("oProcess")=="O"  .and. !lExtratTaf
	oProcess:Set1Progress(nCtdFil)
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processamento de multifiliais³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea ("SM0")
SM0->(DbGoTop ())
SM0->(MsSeek (cEmpAnt+cFilDe, .T.))	//Pego a filial mais proxima 
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quando a opcao de seleciona filiais estiver configurada como sim, serah    ³
//³    considerado as filiais selecionadas no browse. Caso contrario, valera o³
//³    que estiver configurado na pergunta 'Filial DE/ATE'                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do While Eval(bWhileSM0) 
		
	cFilAnt 	:= 	FWGETCODFILIAL
	
	If Len(aLisFil)>0 .And. cFilAnt <= cFilAte
       nFilial := Ascan(aLisFil,{|x|x[2]==cFilAnt})
	   If nFilial==0 .Or. !(aLisFil[nFilial,1])  //Filial não marcada, vai para proxima
			SM0->(dbSkip()) 
			Loop
		EndIf
	Else
		If (!lExtratTAF .and. "1" $ aWizard[1][12]) .or. (lExtratTAF .and. "1" $ aWizard[1][5])  //Somente faz skip se a opção de selecionar filiais estiver como Sim.
			 SM0->( dbSkip())
			 Loop
		EndIf		
	EndIf
	
	nEmpProc	+=	1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³No caso de o objeto oProcess existir, significa que a nova barra  ³
	//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
	//| portanto deve ser efetuado os controles para demonstrar o        |
	//| resultado do processamento.                                      |
	//|                                                                  |
	//³Definicao o primeiro incremento da regua                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//LGS#20200203 - Adequação de release 12.1.25 e posteriores
	//If Type("oProcess")=="O"
	If _lVerProc
	
		if !lExtratTaf
			oProcess:Inc1Progress(STR0023+cEmpAnt+"/"+cFilAnt,StrZero(nEmpProc,3)+"/"+StrZero(nCtdFil,3))	//"Processando empresa :"
			oProcess:Inc2Progress("Processando documentos de exportacao...",StrZero(nRegsProc,6)+"/"+StrZero(nCountTot,6))
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Controle do cancelamento da rotina³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If oProcess:Cancel()
				Exit
			EndIf
		endif
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Controle do cancelamento da rotina³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Interrupcao(@lEnd)
			Exit
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processamento da funcao da Average que retorna os avisos de embarque conforme regras do SIGAEEC³
	//|                                                                                               |
	//|                     FUNCAO DISPONIB. PELA AVEGARE - FONTE AVGERAL.PRW                         |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AvGetExpSped(dDataDe,dDataAte)
	
	If Select("SPED1100")>0
		DbSelectArea("SPED1100")
		SPED1100->(DbGoTop())
	
		While !SPED1100->(Eof())
		
			nRegsProc	+=	1
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³No caso de o objeto oProcess existir, significa que a nova barra  ³
			//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
			//| portanto deve ser efetuado os controles para demonstrar o        |
			//| resultado do processamento.                                      |
			//|                                                                  |
			//|Efetuando o incremento da segunda regua com as informacoes        |
			//| atualizadas e atualizando os detalhes do processamento           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//LGS#20200203 - Adequação de release 12.1.25 e posteriores
			//If Type("oProcess")=="O"
			If _lVerProc
				
				if !lExtratTaf
					oProcess:Inc2Progress("Processando documentos de exportacao...",StrZero(nRegsProc,6)+"/"+StrZero(nCountTot,6))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Condicao implementada para controlar os numeros apresentadas na tela³
					//³  de processamento da rotina, os detalhes.                          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If cTimeDocs<>Time()
						oProcess:SetDetProgress(STR0026,nCountTot,;	 				//"Total de registros do periodo solicitado"
								STR0027,nDocsXTime,;	  							//"Total de registros processados por segundo"
								STR0028,nCountTot-nRegsProc,; 						//"Total de registros pendentes para processamento"
								STR0029,Round((nCountTot-nRegsProc)/nDocsXTime,0))	//"Tempo estimado para termino do processamento (Seg.)"
					
						cTimeDocs	:=	Time()
						nDocsXTime	:=	1
					Else
						nDocsXTime	+=	1
					EndIf
		
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Controle do cancelamento da rotina³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If oProcess:Cancel()
						Exit
					EndIf  
				endif
			Else
			
				IncProc("Processando documentos de exportacao...")
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Controle do cancelamento da rotina³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Interrupcao(@lEnd)
					Exit
				EndIf
			EndIf		
		         
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Gerando a estutura do registro 1100³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  		
	        If (nPos1100 := aScan(aReg1100,{|aX| aX[3]== SPED1100->NRO_DE .And. aX[4]== SPED1100->DT_DE .And. aX[6]== SPED1100->NRO_RE}))==0
				aAdd(aReg1100,{})
				nPos1100 := Len(aReg1100)
				aAdd (aReg1100[nPos1100], "1100")							//01 - REG
				aAdd (aReg1100[nPos1100], SPED1100->IND_DOC)		 		//02 - IND_DOC
				aAdd (aReg1100[nPos1100], SPED1100->NRO_DE)		 			//03 - NRO_DE
				aAdd (aReg1100[nPos1100], SPED1100->DT_DE)			 		//04 - DT_DE
				aAdd (aReg1100[nPos1100], SPED1100->NAT_EXP)		 		//05 - NAT_EXP
				aAdd (aReg1100[nPos1100], SPED1100->NRO_RE)		   			//06 - NRO_RE
				aAdd (aReg1100[nPos1100], If(SPED1100->IND_DOC == "0",SPED1100->DT_RE,""))		   	   		//07 - DT_RE
				aAdd (aReg1100[nPos1100], SPED1100->CHC_EMB)				//08 - CHC_EMB
				aAdd (aReg1100[nPos1100], SPED1100->DT_CHC)		   			//09 - DT_CHC
				aAdd (aReg1100[nPos1100], SPED1100->DT_AVB)		   			//10 - DT_AVB
				aAdd (aReg1100[nPos1100], SPED1100->TP_CHC)		   			//11 - TP_CHC
				aAdd (aReg1100[nPos1100], SPED1100->PAIS)		   			//12 - PAIS
	        EndIf
	        
			If Select("SPED1105")>0	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³REGISTRO 1105 - DOCUMENTOS FISCAIS DE EXPORTACAO³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nPos1105	:=	Reg1105Av(SPED1100->PREEMB,SPED1100->ID,nPos1100,@aReg1105,@aReg0200,@aReg0190,dDataDe,dDataAte,@aReg0220,cAlias,aWizard,lExtratTaf)
	
				If Select("SPED1110")>0	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³REGISTRO 1110 - OPERACOES DE EXPORTACOES INDIRETAS - MERCADORIAS DE TERCEIROS³
					//|                        So para exportacao indireta                          |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
					Reg1110Av(SPED1100->PREEMB,SPED1100->ID,@aReg1110,nPos1105,@aReg0150,cAlias,aWizard,lExtratTaf)
				EndIf
			EndIf
			
			SPED1100->(dbSkip ())	
		End
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³No caso de o objeto oProcess existir, significa que a nova barra  ³
		//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
		//| portanto deve ser efetuado os controles para demonstrar o        |
		//| resultado do processamento.                                      |
		//|                                                                  |
		//|Tratamento para o cancelamento de execucao da rotina              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
     	//LGS#20200203 - Adequação de release 12.1.25 e posteriores
    	//If Type("oProcess")=="O" .and. !lExtratTaf
		If _lVerProc  .and. !lExtratTaf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Controle do cancelamento da rotina³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If oProcess:Cancel()
				Exit
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Controle do cancelamento da rotina³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Interrupcao(@lEnd)
				Exit
			EndIf
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³No caso de o objeto oProcess existir, significa que a nova barra  ³
	//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
	//| portanto deve ser efetuado os controles para demonstrar o        |
	//| resultado do processamento.                                      |
	//|                                                                  |
	//|Tratamento para o cancelamento de execucao da rotina              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
   	//LGS#20200203 - Adequação de release 12.1.25 e posteriores
   	//If Type("oProcess")=="O" .and. !lExtratTaf
	If _lVerProc  .and. !lExtratTaf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Controle do cancelamento da rotina³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If oProcess:Cancel()
			Exit
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Controle do cancelamento da rotina³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Interrupcao(@lEnd)
			Exit
		EndIf
	EndIf
	
	SM0->(dbSkip())
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restauro a area do SM0³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaSM0)
cFilAnt := FWGETCODFILIAL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³No caso de o objeto oProcess existir, significa que a nova barra  ³
//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
//| portanto deve ser efetuado os controles para demonstrar o        |
//| resultado do processamento.                                      |
//|                                                                  |
//|Tratamento para o cancelamento de execucao da rotina              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
If Type("oProcess")=="O"
	if !lExtratTaf
		nSv1Progress	:=	oProcess:Ret1Progress()
		nSv2Progress	:=	oProcess:Ret2Progress()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Controle do cancelamento da rotina³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If oProcess:Cancel()
			Return
		EndIf
	endif
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Controle do cancelamento da rotina³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Interrupcao(@lEnd)
		Return
	EndIf
EndIf	

if lExtratTaf
	aRegT066   := aReg1100
	aRegT066AA := aReg1105
	aRegT066AB := aReg1110
	
else
	aAdd(aGrava,aReg1100)
	aAdd(aGrava,aReg1105)
	aAdd(aGrava,aReg1110)
	SPEDRegs(cAlias,aGrava,"1100/1105/1110")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³No caso de o objeto oProcess existir, significa que a nova barra  ³
	//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
	//| portanto deve ser efetuado os controles para demonstrar o        |
	//| resultado do processamento.                                      |
	//|                                                                  |
	//|Tratamento para retornar a posicao da barra salva anteriormente   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
	If Type("oProcess")=="O" 
		oProcess:Set1Progress(nCtdFil,nSv1Progress)
		oProcess:Set2Progress(nCountTot,nSv2Progress)
	EndIf

endif

Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Reg1105Av | Autor ³Gustavo G. Rueda              ³ Data ³07.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³DOCUMENTOS FISCAIS DE EXPORTACAO                                   ³±±
±±³          ³                                                                   ³±±
±±³          ³- Geracao do Registro 1105                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpN1 := Reg1105Av(cEmbarque,nPos1100,aReg1105,aReg0200,aReg0190,; ³±±
±±³          ³                 dDataDe,dDataAte,aReg0220,cAlias)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cEmbarque -> Numero de embarque                                    ³±±
±±³          ³nPos1100  -> Posicao para relacionamento com o registro 1100       ³±±
±±³          ³aReg1105  -> Array com a estrutura do registro 1105 a ser          ³±±
±±³          ³             gravado no futuro.                                    |±±
±±³          ³aReg0200 -> Array com as informacoes a sere retornadads por        ³±±
±±³          ³ referencia para gerar o registro 0200                             ³±±
±±³          ³aReg0190 -> Array com as informacoes a sere retornadads por        ³±±
±±³          ³ referencia para gerar o registro 0190                             ³±±
±±³          ³dDataDe  -> Data inicial do processamento do SPED Fiscal           ³±±
±±³          ³dDataAte -> Data final do processamento do SPED Fiscal             ³±±
±±³          ³aReg0220 -> Array com as informacoes a sere retornadads por        ³±±
±±³          ³ referencia para gerar o registro 0220                             ³±±
±±³          ³cAlias -> Alias do TRB que recebera as informacoes                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1 - Posicao da informacao dentro do array aReg1105             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Reg1105Av(cEmbarque,cID,nPos1100,aReg1105,aReg0200,aReg0190,dDataDe,dDataAte,aReg0220,cAlias,aWizard,lExtratTaf)
Local   nPos1105	:=	0
Local 	cProd		:= 	""
Local	aProd		:=	Nil
Local	aSpdFis02	:=	{}  
Local	cUnid		:=	""

Default cEmbarque	:= 	""

SPED1105->(MsSeek(cEmbarque+cID))
While !SPED1105->(Eof()) .And. cEmbarque+cID==SPED1105->(PREEMB+ID)
	aAdd(aReg1105, {})
	nPos1105 := Len (aReg1105)
	aAdd (aReg1105[nPos1105], nPos1100)								//Posicao de relacionamento com o registro 1100
	aAdd (aReg1105[nPos1105], "1105")				   				//01 - REG	
	aAdd (aReg1105[nPos1105], SPED1105->COD_MOD)	   				//02 - COD_MOD
	aAdd (aReg1105[nPos1105], SPED1105->SERIE)						//03 - SERIE
	aAdd (aReg1105[nPos1105], SPED1105->NUM_DOC)					//04 - NUM_DOC
	aAdd (aReg1105[nPos1105], SPED1105->CHV_NFE)					//05 - CHV_NFE
	aAdd (aReg1105[nPos1105], SPED1105->DT_DOC)					//06 - DT_DOC
	aAdd (aReg1105[nPos1105], SPED1105->COD_ITEM)		  			//07 - COD_ITEM
	
	If SB1->(MsSeek(xFilial("SB1")+SPED1105->COD_ITEM))
		
		cProd 	:= 	SB1->B1_COD+xFilial("SB1")
		cUnid	:=	SB1->B1_UM
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de entrada para taratmento da informação de produtos quando o mesmo estah fora do padrao do sistema³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aExistBloc[05] 
			aProd := Execblock("SPEDPROD", .F., .F., {"SPED1105","1105"})
			If Len(aProd)>=11
				cProd 	:= 	aProd[1]
				cUnid	:=	aProd[5]
			Else
				aProd := {"","","","","","","","","","","",""}
			EndIf					
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processamento do ponto de entrada para alteracao da unidade de medida caso exista³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aExistBloc[01]
			aSpdFis02 := ExecBlock("SPDFIS02", .F., .F., {"SPED1105","S","1105"})

		   If ValType(aSpdFis02)=="A"
		      cUnid     := aSpdFis02[1]
		   Else   
			  cUnid     := ExecBlock("SPDFIS02", .F., .F., {"SPED1105","S","1105"})
		   EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REGISTRO 0200 - TABELA DE IDENTIFICACAO DO ITEM³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aScan(aReg0200,{|aX| aX[2]==cProd})==0 .and. !lExtratTaf
			SFRG0200(cAlias,@aReg0200,@aReg0190,dDataDe,dDataAte,aProd,cProd,@aReg0220,,cUnid,,,,,,,,,,,,,,,,,aWizard,lExtratTaf)
		EndIf
	EndIf 	

	SPED1105->(dbSkip())
End
Return nPos1105
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Reg1110Av | Autor ³Gustavo G. Rueda              ³ Data ³07.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³DOCUMENTOS FISCAIS DE EXPORTACAO INDIRETA                          ³±±
±±³          ³                                                                   ³±±
±±³          ³- Geracao do Registro 1110                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Reg1110Av(cEmbarque,aReg1110,nPos1105,aReg0150,cAlias,aWizard)     ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cEmbarque -> Numero do aviso de embarque                           ³±±
±±³          ³aReg1110  -> Array com a estrutura do registro 1110 a ser          ³±±
±±³          ³             gravado no futuro.                                    |±±
±±³          ³nPos1105  -> Posicao para relacionamento com o registro 1105       ³±±
±±³          ³aReg0150  -> Array com a estrutura do registro 0150 a ser          ³±±
±±³          ³             gravado no futuro.                                    |±±
±±³          ³cAlias    -> Alias do arquivo temporario para geracao do TXT       |±±
±±³          ³aWizard   -> Informacoes do wizard da rotina                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Reg1110Av(cEmbarque,cID,aReg1110,nPos1105,aReg0150,cAlias,aWizard,lExtratTaf)
Local	nPos		:=	0
Local	cCodLoj		:=	""
Local	aPartDoc	:=	{}
Local	nDecimal	:= TamSX3("EYY_QUANT")[2]

Default cEmbarque	:= ""

SPED1110->(MsSeek(cEmbarque+cID))
While !SPED1110->(Eof ()) .And. cEmbarque+cID==SPED1110->(PREEMB+ID)

	cCodLoj	:=	Right(Alltrim(SPED1110->COD_PART),TamSx3("A2_COD")[1]+TamSx3("A2_LOJA")[1])

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GRAVACAO - REGISTRO 0150        ³    
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SA2->(MsSeek(xFilial("SA2")+cCodLoj))
		aPartDoc	:=	InfPartDoc("SA2",,,,,,,lExtratTaf)
	EndIf
	
	aAdd(aReg1110, {})
	nPos	:=	Len(aReg1110)
	aAdd (aReg1110[nPos], nPos1105)	  						//Posicao de relacionamento com o registro pai, 1105
	aAdd (aReg1110[nPos], "1110")				   			//01 - REG
	aAdd (aReg1110[nPos], aPartDoc[1] )					//02 - COD_PART FORNECEDOR DA MERCADORIA DESTINADA A EXPORTACAO
	aAdd (aReg1110[nPos], SPED1110->COD_MOD)				//02 - COD_MOD DO DOCUMENTO FISCAL DE ENTRADA
	aAdd (aReg1110[nPos], SPED1110->SER)					//03 - SERIE DO DOC DE ENTRADA
	aAdd (aReg1110[nPos], SPED1110->NUM_DOC)				//04 - NUM_DOC DO DOC DE ENTRADA
	aAdd (aReg1110[nPos], SPED1110->DT_DOC)					//05 - DT_DOC DE EMISSAO DO DOC DE ENTRADA
	aAdd (aReg1110[nPos], SPED1110->CHV_NFE)				//06 - CHV_NFE DO DOC DE ENTRADA
	aAdd (aReg1110[nPos], SPED1110->NR_MEMO)				//07 - NR_MEMO DE EXPORTACAO
	aAdd (aReg1110[nPos], {Val(StrTran(SPED1110->QTD,',','.')),Iif(nDecimal > 3,3,nDecimal)})		   	   		//08 - QTD EFETIVAMENTE EXPORTADA
	aAdd (aReg1110[nPos], SPED1110->UNID)			   		//09 - UNID DO PRODUTO
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GRAVACAO REGISTRO 0150 - TABELA DE CADASTRO DE PARTICIPANTES            ³
	//³GRAVACAO REGISTRO 0175 - ALTERACAO DA TABELA DE CADASTRO DE PARTICIPANTE³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if !lExtratTaf
		SDPF150175(@aReg0150,aPartDoc,cAlias,aWizard,,lExtratTaf)
	endif
	
	SPED1110->(dbSkip())
End
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡ao    ³R12001210 | Autor ³Luccas Curcio                 ³ Data ³18/08/2011³±±
±±³Descri‡ao ³CONTROLE DE CRÉDITOS FISCAIS                               		 ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function R12001210(bWhileSM0,cFilDe,dDataDe,dDataAte,cAlias,aWizard,oProcess,nRegsProc,nCtdFil,aLisFil,nCountTot,lEnd,cFilAte,lExtratTaf,aRegT067,aRegT067AA)
Local 	nPos1200	:=	0
Local 	nPos1210	:=	0
Local 	nSaldAnt	:=	0
Local	nFilial		:=	0
Local	nEmpProc	:=	0
Local	nDocsXTime	:=	1
Local 	aParamCE6	:=	{}
//Local 	aParamCE5	:=	{}
Local 	aReg1200	:=	{}
Local 	aReg1210	:=	{}
Local	lTop		:=	.F.
Local 	cPeriodo	:=	""
Local 	cCodLan		:=	""
Local 	cAliasQry	:=	"CE6"
Local	cChaveCE6	:=	""
Local	cTimeDocs	:=	""
Local	cAliasCE5	:=	"CE5"
Local 	aAreaSM0	:=	SM0->(GetArea())
Local   _lVerProc   := Type("oProcess")=="O"
Default lExtratTaf := .F.

//³No caso de o objeto oProcess existir, significa que a nova barra  ³
//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
//| portanto deve ser efetuado os controles para demonstrar o        |
//| resultado do processamento.                                      |
//|                                                                  |
//|Jah que estah rotina efetua o processamento multi-filiais, preciso³
//| corrigir a posicao da regua, pois no while principal da SFT      |
//| deixou a barra no final, pois processou todas as filiais.        |
If Type("oProcess")=="O" .and. !lExtratTaf
	oProcess:Set1Progress(nCtdFil)
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processamento de multifiliais³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea ("SM0")
SM0->(DbGoTop ())
SM0->(MsSeek (cEmpAnt+cFilDe, .T.))	//Pego a filial mais proxima

//³Quando a opcao de seleciona filiais estiver configurada como sim, serah    ³
//³    considerado as filiais selecionadas no browse. Caso contrario, valera o³
//³    que estiver configurado na pergunta 'Filial DE/ATE'                    ³
Do While Eval(bWhileSM0)
	
	cFilAnt 	:= 	FWGETCODFILIAL
	
	If Len(aLisFil)>0 .And. cFilAnt <= cFilAte
       nFilial := Ascan(aLisFil,{|x|x[2]==cFilAnt})
	   If nFilial==0 .Or. !(aLisFil[nFilial,1])  //Filial não marcada, vai para proxima
			SM0->(dbSkip()) 
			Loop
		EndIf
	Else
		If (!lExtratTAF .and. "1" $ aWizard[1][12]) .or. (lExtratTAF .and. "1" $ aWizard[1][5])  //Somente faz skip se a opção de selecionar filiais estiver como Sim.
			 SM0->( dbSkip())
			 Loop
		EndIf		
	EndIf
	
	nEmpProc	+=	1
	//³No caso de o objeto oProcess existir, significa que a nova barra  ³
	//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
	//| portanto deve ser efetuado os controles para demonstrar o        |
	//| resultado do processamento.                                      |
	//|                                                                  |
	//³Definicao o primeiro incremento da regua                          ³
   	//LGS#20200203 - Adequação de release 12.1.25 e posteriores
  	//If Type("oProcess")=="O"
	If _lVerProc
		if !lExtratTaf
			oProcess:Inc1Progress(STR0023+cEmpAnt+"/"+cFilAnt,StrZero(nEmpProc,3)+"/"+StrZero(nCtdFil,3))	//"Processando empresa :"
			oProcess:Inc2Progress("Processando Controle de Crédito Fiscal...",StrZero(nRegsProc,6)+"/"+StrZero(nCountTot,6))
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Controle do cancelamento da rotina³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If oProcess:Cancel()
				Exit
			EndIf  
		endif
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Controle do cancelamento da rotina³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Interrupcao(@lEnd)
			Exit
		EndIf
	EndIf
	
	#IFDEF TOP
		If (TcSrvType ()<>"AS/400")
			lTop	:=	.T.
		Endif
	#ENDIF
    
	aParamCE6	:=	{}
	aAdd(aParamCE6,Substr(DTOS(dDataDe),1,6))
	If SPEDFFiltro(1,"CE6",@cAliasQry,aParamCE6)
	    
		While !(cAliasQry)->(Eof())

			If lTop
				cAliasCE5	:=	cAliasQry
			Else
				SPEDSeek("CE5",2,xFilial("CE5")+cCodLan+cPeriodo)
			Endif
		
			nRegsProc	+=	1
			//³No caso de o objeto oProcess existir, significa que a nova barra  ³
			//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
			//| portanto deve ser efetuado os controles para demonstrar o        |
			//| resultado do processamento.                                      |
			//|                                                                  |
			//|Efetuando o incremento da segunda regua com as informacoes        |
			//| atualizadas e atualizando os detalhes do processamento           ³
			//LGS#20200203 - Adequação de release 12.1.25 e posteriores
			//If Type("oProcess")=="O"
			If _lVerProc
				if !lExtratTaf
					oProcess:Inc2Progress("Processando Controle de Crédito Fiscal...",StrZero(nRegsProc,6)+"/"+StrZero(nCountTot,6))
					//³Condicao implementada para controlar os numeros apresentadas na tela³
					//³  de processamento da rotina, os detalhes.                          ³
					If cTimeDocs<>Time()
						oProcess:SetDetProgress(STR0026,nCountTot,;	  				//"Total de registros do periodo solicitado"
								STR0027,nDocsXTime,;	 							//"Total de registros processados por segundo"
								STR0028,nCountTot-nRegsProc,;  						//"Total de registros pendentes para processamento"
								STR0029,Round((nCountTot-nRegsProc)/nDocsXTime,0))	//"Tempo estimado para termino do processamento (Seg.)"
					
						cTimeDocs	:=	Time()
						nDocsXTime	:=	1
					Else
						nDocsXTime	+=	1
					EndIf
		
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Controle do cancelamento da rotina³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If oProcess:Cancel()
						Exit
					EndIf   
				endif
			Else
			
				IncProc("Processando Controle de Crédito...")
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Controle do cancelamento da rotina³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Interrupcao(@lEnd)
					Exit
				EndIf
			EndIf

			cPeriodo	:=	(cAliasQry)->CE6_PERIOD
			cCodLan		:=	(cAliasQry)->CE6_CODLAN
			nSaldAnt	:=	(cAliasQry)->CE6_SALDO + ((cAliasQry)->CE6_TOTUTI - ((cAliasQry)->CE6_TOTCRE + (cAliasQry)->CE6_TOTTRA))
			
			If (nPos1200 := aScan(aReg1200, {|aZ| aZ[2] == cCodLan})) == 0 .And.;
			((cAliasQry)->CE6_TOTCRE > 0 .Or. (cAliasQry)->CE6_TOTTRA > 0 .Or.; 
			(cAliasQry)->CE6_TOTUTI > 0 .Or. (cAliasQry)->CE6_SALDO > 0)					
				aAdd (aReg1200, {})
				nPos1200	:=	Len(aReg1200)
				aAdd (aReg1200[nPos1200], "1200")								//01 - REG
				aAdd (aReg1200[nPos1200], cCodLan)								//02 - COD_AJ_APUR
				aAdd (aReg1200[nPos1200], nSaldAnt)								//03 - SLD_CRED
				aAdd (aReg1200[nPos1200], (cAliasQry)->CE6_TOTCRE)				//04 - CRED_APR
				aAdd (aReg1200[nPos1200], (cAliasQry)->CE6_TOTTRA)				//05 - CRED_RECEB 
				aAdd (aReg1200[nPos1200], (cAliasQry)->CE6_TOTUTI)				//06 - CRED_UTIL 
				aAdd (aReg1200[nPos1200], (cAliasQry)->CE6_SALDO)				//07 - SLD_CRED_FIM 						 

			Elseif (nPos1200 := aScan(aReg1200, {|aZ| aZ[2] == cCodLan })) > 0 .And. cChaveCE6 <> (cAliasQry)->CE6_FILIAL+cCodLan+cPeriodo
				aReg1200[nPos1200,4]	+= (cAliasQry)->CE6_TOTCRE				//04 - CRED_APR
				aReg1200[nPos1200,5]	+= (cAliasQry)->CE6_TOTTRA				//05 - CRED_RECEB 
				aReg1200[nPos1200,6]	+= (cAliasQry)->CE6_TOTUTI				//06 - CRED_UTIL 
				aReg1200[nPos1200,7]	+= (cAliasQry)->CE6_SALDO				//07 - SLD_CRED_FIM
			Endif
			
			cChaveCE6	:=	(cAliasQry)->CE6_FILIAL+cCodLan+cPeriodo
			
			While !(cAliasCE5)->(Eof()) .And. (cAliasCE5)->CE5_FILIAL+(cAliasCE5)->CE5_CODLAN+(cAliasCE5)->CE5_PERIOD == cChaveCE6                                  
			
				If (cAliasQry)->CE6_TOTUTI > 0 .And. (cAliasQry)->CE5_TPMOV == "U"

					If (nPos1210 := aScan(aReg1210, {|aY| aY[3] == (cAliasCE5)->CE5_CODUTI})) == 0 .Or. ;
						(nPos1210 := aScan(aReg1210, {|aY| aY[3] == (cAliasCE5)->CE5_CODUTI .And. aY[4] <> Alltrim((cAliasCE5)->CE5_NUMDOC) .And. aY[1]==nPos1200})) == 0
	
						aAdd (aReg1210, {})
						nPos1210	:=	Len(aReg1210)
						aAdd (aReg1210[nPos1210], nPos1200)							//Relacionamento com Registro Pai - 1200
						aAdd (aReg1210[nPos1210], "1210")							//01 - REG
						aAdd (aReg1210[nPos1210], (cAliasQry)->CE5_CODUTI)			//02 - TIPO_UTIL
						aAdd (aReg1210[nPos1210], (cAliasQry)->CE5_NUMDOC)			//03 - NR_DOC
						aAdd (aReg1210[nPos1210], (cAliasQry)->CE5_VALOR)			//04 - VL_CRED_UTIL
						IF cVersao >= "011"
							aAdd (aReg1210[nPos1210], Iif(aSPDSX3[FP_CE5_CHVNFE],(cAliasQry)->CE5_CHVNFE,''))			//05 - CHV_DOCe
						Endif
					Else
						aReg1210[nPos1210,5]	+=	(cAliasQry)->CE5_VALOR			//04 - VL_CRED_UTIL
					Endif
				
				EndIf
				
				(cAliasCE5)->(DbSkip())
			End
			 
		End
		SPEDFFiltro(2,,cAliasQry)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³No caso de o objeto oProcess existir, significa que a nova barra  ³
	//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
	//| portanto deve ser efetuado os controles para demonstrar o        |
	//| resultado do processamento.                                      |
	//|                                                                  |
	//|Tratamento para o cancelamento de execucao da rotina              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
   	//LGS#20200203 - Adequação de release 12.1.25 e posteriores
  	//If Type("oProcess")=="O"
	If _lVerProc   
		if !lExtratTaf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Controle do cancelamento da rotina³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If oProcess:Cancel()
				Exit
			EndIf
		endif
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Controle do cancelamento da rotina³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Interrupcao(@lEnd)
			Exit
		EndIf
	EndIf
			
	SM0->(dbSkip())
End		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restauro a area do SM0³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaSM0)
cFilAnt := FWGETCODFILIAL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³No caso de o objeto oProcess existir, significa que a nova barra  ³
//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
//| portanto deve ser efetuado os controles para demonstrar o        |
//| resultado do processamento.                                      |
//|                                                                  |
//|Tratamento para o cancelamento de execucao da rotina              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
If Type("oProcess")=="O"   

	if !lExtratTaf
		nSv1Progress	:=	oProcess:Ret1Progress()
		nSv2Progress	:=	oProcess:Ret2Progress()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Controle do cancelamento da rotina³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If oProcess:Cancel()    
			Return
		EndIf
	endif
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Controle do cancelamento da rotina³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Interrupcao(@lEnd)
		Return
	EndIf
EndIf  

if !lExtrattaf
	GrRegDep(cAlias,aReg1200,aReg1210)
else
	aRegT067   :=  aReg1200    	
	aRegT067AA :=  aReg1210
endif

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SPDReg1400³ Autor ³Gustavo G. Rueda       ³ Data ³15.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³            INFORMACAO SOBRE VALORES AGREGADOS              ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro 1400                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoe contidas no array    ³±±
±±³          ³ aReg1400.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³2(varios por arquivo)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aReg1400-> Array a ser retornado com a estrutura do registro³±±
±±³          ³cProd   -> Codigo do produto montado pela rotina            ³±±
±±³          ³cCodMun -> Codigo do municipio do participante              |±±
±±³          ³cAliasSFT-> Alias da tabela SFT                             |±±
±±³          ³cAliasSF4-> Alias da tabela SF4                             |±±
±±³          ³lExtTaf  -> Indica se a chamada da Funcao eh o Extrator TAF |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SPDReg1400(aReg1400,cProd,cCodMun,cAliasSFT,cAliasSF4,lExtTaf,lGr2001400,cMVEstado)

Local	nPos		:=	0    
Local	cIte		:= 	AllTrim(cProd) 
Local 	cMVUFIPM	:=	Alltrim(aSPDSX6[MV_UFIPM])                                         

Default lExtTaf := .F.
Default lGr2001400 := .F.

IF aSPDSX2[AI_F09]
	DbSelectArea("F09")
	F09->(DbSetOrder(1))
EndIF

//Código do item - Tabela própria da unidade da federação - Participação dos Municípios
//Versão 2.0.15 do guia pratico EFD             
If cVersao == "008"
	cIte :=	cProd
ElseIF aSPDSX2[AI_F09] .AND. Alltrim(cMVEstado) $ cMVUFIPM .AND. F09->(MsSeek(XFilial("F09")+(cAliasSF4)->F4_CODIGO+ Alltrim(cMVEstado)))
	//Este tratamento é para todos os estados que tiverem configurados IPM para o registro 1400
	cIte	:= AllTrim(F09->F09_CODIPM) 
Endif   
     
If (nPos := aScan(aReg1400, {|aX| AllTrim(aX[2])==cIte .And. aX[3]==cCodMun})) == 0
	aAdd(aReg1400, {})
	nPos	:=	Len (aReg1400)   
	aAdd (aReg1400[nPos], Iif( !lExtTaf, "1400", "T072" ) )	//01 - REG
	aAdd (aReg1400[nPos], cIte)						   	   //02 - COD_ITEM
 	aAdd (aReg1400[nPos], cCodMun)							//03 - MUN
  	aAdd (aReg1400[nPos], 0)	                            	//04 - VALOR
Endif
                                             
If (cAliasSF4)->F4_VLAGREG=="D"
	aReg1400[nPos][4] -= (cAliasSFT)->FT_VALCONT		
Else
	aReg1400[nPos][4] += (cAliasSFT)->FT_VALCONT		
EndIf

lGr2001400 := aReg1400[nPos][4] > 0
	  	
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Reg1500   ³ Autor ³Gustavo G. Rueda       ³ Data ³09.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³     NOTA FISCAL CONTA DE ENERGIA ELETRICA (MODELO 06)      ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro 1500                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoe contidas no array    ³±±
±±³          ³ aRegC100 para o Modelo 06.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³2(varios por arquivo)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias   -> Alias do arquivo de trabalho                    ³±±
±±³          ³nRelac   -> Variavel de relacionamento do registro          ³±±
±±³          ³aRegC100 -> Array com as informacoes jah processadas        |±±
±±³          ³aTotaliza-> Array com os totalizadores por documento        |±±
±±³          ³lAchouSFU-> Flag de seek da tabela SFU                      |±±
±±³          ³lGrava0150-> Flag de geracao do registro 0150               |±±
±±³          ³aCmpAntSFT-> Campos do documento processados (registro      |±±
±±³          ³             anterior)                                      |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Reg1500(cAlias,nRelac,aRegC100,aTotaliza,lAchouSFU,lGrava0150,aCmpAntSFT,aWizard)
Local	nPos		:=	0
Local	cCodCons	:=	""
Local	nVlTerc  	:=	0
Local	aReg1500	:=	{}
Local   cTpLiga     :=  ""
Local   cGrpTens    :=  ""
Default aWizard		:= {}

If lAchouSFU
	cCodCons := SFU->FU_CLASCON
	nVlTerc  := SFU->FU_VALTERC
	cGrpTens := SFU->FU_GRUPT
	Do Case
		Case SFU->FU_TIPLIGA == '0'
			cTpLiga := "1"
		Case SFU->FU_TIPLIGA == '1'
			cTpLiga := "2"
		Case SFU->FU_TIPLIGA == '2'
			cTpLiga := "3"
	EndCase
EndIf

aAdd(aReg1500, {})
nPos	:=	Len (aReg1500)
aAdd (aReg1500[nPos], "1500")	 	   										//01 - REG
aAdd (aReg1500[nPos], aRegC100[1][2])	   			  						//02 - IND_OPER
aAdd (aReg1500[nPos], aRegC100[1][3])	   			  						//03 - IND_EMIT
aAdd (aReg1500[nPos], aRegC100[1][4])	   			  						//04 - COD_PART
aAdd (aReg1500[nPos], aRegC100[1][5])	   			  						//05 - COD_MOD
aAdd (aReg1500[nPos], aRegC100[1][6])	   			   						//06 - COD_SIT
aAdd (aReg1500[nPos], aRegC100[1][7])	   									//07 - SER
aAdd (aReg1500[nPos], "")	   						   						//08 - SUB
aAdd (aReg1500[nPos], cCodCons )					   						//09 - COD_CONS
aAdd (aReg1500[nPos], aRegC100[1][8])	   			   						//10 - NUM_DOC
aAdd (aReg1500[nPos], aCmpAntSFT[6])	   			   						//11 - DT_DOC
aAdd (aReg1500[nPos], aRegC100[1][11])	   									//12 - DT_E_S
aAdd (aReg1500[nPos], aRegC100[1][12])	   			   						//13 - VL_DOC
aAdd (aReg1500[nPos], aRegC100[1][14])	   				   					//14 - VL_DESC
aAdd (aReg1500[nPos], aRegC100[1][16])	   									//15 - VL_FORN
aAdd (aReg1500[nPos], IIF(!(aRegC100[1][6]$"02#04#05"),aTotaliza[7],""))	//16 - VL_SERV_NT
aAdd (aReg1500[nPos], IIF(!(aRegC100[1][6]$"02#04#05"),nVlTerc,""))		//17 - VL_TERC
aAdd (aReg1500[nPos], aRegC100[1][20])	   				  					//18 - VL_DA
aAdd (aReg1500[nPos], aRegC100[1][21])	   									//19 - VL_BC_ICMS
aAdd (aReg1500[nPos], aRegC100[1][22])	   									//20 - VL_ICMS
aAdd (aReg1500[nPos], aRegC100[1][23])				   						//21 - VL_BC_ICMS_ST
aAdd (aReg1500[nPos], aRegC100[1][24])	   									//22 - VL_ICMS_ST
aAdd (aReg1500[nPos], "" )	   												//23 - COD_INF
aAdd (aReg1500[nPos], Iif("1"$aWizard[1][15],aRegC100[1][26],0))	   									//24 - VL_PIS
aAdd (aReg1500[nPos], Iif("1"$aWizard[1][15],aRegC100[1][27],0))	   									//25 - VL_COFINS
If cVersao >= "003"
	aAdd (aReg1500[nPos], cTpLiga)		   									//26 - TP_LIGACAO - LAYOUT 2010
	aAdd (aReg1500[nPos], cGrpTens)		   									//27 - COD_GRUPO_TENSAO - LAYOUT 2010
EndIf

GrvRegTrS(cAlias,nRelac,aReg1500)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³No registro C100, quando este campo estiver em branco, eh pq nao deve       ³
//³ ser enviado o codigo do participante, assim nao precisa gerar tambem o 0150³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aRegC100[1][4])
	lGrava0150 := .T.
EndIf

Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Reg1510   ³ Autor ³Gustavo G. Rueda       ³ Data ³09.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³               ITENS DO DOCUMENTO (MODELO 06)               ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro 1510                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com as informacoe contidas no array    ³±±
±±³          ³ aRegC170 para o Modelo 06.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3(1:N) Para cada C500                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias do arquivo de trabalho em processamento     ³±±
±±³          ³nRelac -> Flag de relacionamento por documento              ³±±
±±³          ³aRegC170 -> Array com as informacoes jah processadas.       |±±
±±³          ³aPartDoc -> array com as informacoes do participante        ³±±
±±³          ³nItem    -> Numero do item em processamento                 ³±±
±±³          ³lAchouSFU-> Flag que determina se encontrou a tabela SFU    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Reg1510(cAlias,nRelac,aRegC170,aPartDoc,nItem,lAchouSFU,aWizard)
Local	nPos		:=	0
Local	cCodClas	:=	""
Local	aReg1510	:=	{}
Default aWizard		:= {}

If lAchouSFU
	If TamSx3("FU_GRPCLAS")[1] == 2
		cCodClas	:= SFU->FU_GRPCLAS+SFU->FU_CLASSIF
	Else
		cCodClas	:= "0"+SFU->FU_GRPCLAS+SFU->FU_CLASSIF
	EndIf
EndIf

aAdd(aReg1510,{})
nPos	:=	Len(aReg1510)
aAdd(aReg1510[nPos], "1510")	 	   					//01 - REG
aAdd(aReg1510[nPos], aRegC170[1][2])	   				//02 - NUM_ITEM
aAdd(aReg1510[nPos], aRegC170[1][3])	   				//03 - COD_ITEM
aAdd(aReg1510[nPos], cCodClas)							//04 - COD_CLASS
aAdd(aReg1510[nPos], aRegC170[1][5][1])				//05 - QTD
aAdd(aReg1510[nPos], aRegC170[1][6])	   				//06 - UNID
aAdd(aReg1510[nPos], aRegC170[1][7])	   				//07 - VL_ITEM
aAdd(aReg1510[nPos], aRegC170[1][8])	   				//08 - VL_DESC
aAdd(aReg1510[nPos], aRegC170[1][10])	   				//09 - CST_ICM
aAdd(aReg1510[nPos], aRegC170[1][11])	   				//10 - CFOP
aAdd(aReg1510[nPos], aRegC170[1][13])	   				//11 - VL_BC_ICMS
aAdd(aReg1510[nPos], aRegC170[1][14])	   				//12 - ALIQ_ICMS
aAdd(aReg1510[nPos], aRegC170[1][15])	   				//13 - VL_ICMS
aAdd(aReg1510[nPos], aRegC170[1][16])	   				//14 - VL_BC_ICMS_ST
aAdd(aReg1510[nPos], aRegC170[1][17])	   				//15 - ALIQ_ICMS_ST
aAdd(aReg1510[nPos], aRegC170[1][18])	   				//16 - VL_ICMS_ST
aAdd(aReg1510[nPos], "0")			   					//17 - IND_REC
aAdd(aReg1510[nPos], aPartDoc[1])	   					//18 - COD_PART
aAdd(aReg1510[nPos], Iif("1"$aWizard[1][15],Iif(aRegC170[1][30]>0,aRegC170[1][30],""),""))	   				//19 - VL_PIS
aAdd(aReg1510[nPos], Iif("1"$aWizard[1][15],Iif(aRegC170[1][36]>0,aRegC170[1][36],""),""))	   				//20 - VL_COFINS
aAdd(aReg1510[nPos], aRegC170[1][37])					//21 - COD_CTA

GrvRegTrS(cAlias,nRelac,aReg1510,nItem)           
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |OrgTxt    ³ Autor ³Gustavo G. Rueda       ³ Data ³16.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³             GRAVACAO DO TRB EM MEIO-MAGNETICO              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Funcao de gravacao do meio-magnetico de acordo com o TRB.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAlias -> Alias do TRB gerado na funcao principal.          ³±±
±±³          |cFile -> Nome do meio-magnetico a ser gerado.               ³±±
±±³          |oProcess -> Objeto da nova barra de progressao              ³±±
±±³          |lEnd     -> Flag de cancelamento de processamento           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function OrgTxt(cAlias,cFile,oProcess,lEnd,lTop,nRetCpy)
Local	lRet		:=	.T.
Local	lGravaReg1	:=	.F.
Local	lGravaReg9	:=	.F.
Local	lCopied		:=	.F.
Local	nHandle		:=	-1
Local	cRelac		:=	""
Local	cChave		:=	""
Local   aAreaLoc	:= {}
Local   aArea2		:= {}
Local	aArea3		:= {}
Local	nTamTRBIt	:=	Len((cAlias)->TRB_RELAC)/2	//Efetuo divisao por dois porque faco dois controles em um mesmo campo. O relacionamento e sequencia. Ex: ...0001...1, ...0001...2
Local	nRecCount	:=	(cAlias)->(RecCount())
Local	nRegsProc	:=	0
Local	cTimeDocs	:=	Time()
Local	nDocsXTime	:=	0    
Local   cTrab	    := CriaTrab(,.F.)+".TXT"
Local	cDrive		:=	""
Local	cPath		:=	""
Local	cNewFile	:=	""
Local	cExt		:=	""
Local 	cStartPath 	:= 	AllTrim(GetSrvProfString("StartPath",""))
Local 	aArea1300	:= {}
Local   nISuperPai	:= 0
Local  nItem 		:= 0
Local  aStrtk    := {}
Local  aAreaC310 := {}
Local _lVerProc  := Type("oProcess")=="O"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para Linux onde a barra e invertida                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetRemoteType()==2 // REMOTE_LINUX  
	If (SubStr(cStartPath,1,1)<>"/") .And. (SubStr(cStartPath,1,1)<>"\")
		cStartPath	:=	"/"+cStartPath
	EndIf
	
	If (SubStr(cStartPath,Len(cStartPath),1)<>"/") .And. (SubStr(cStartPath,Len(cStartPath),1)<>"\")
		cStartPath	+=	"/"
	EndIf
Else    
	If (SubStr(cStartPath,1,1)<>"\") .And. (SubStr(cStartPath,1,1)<>"/")
		cStartPath	:=	"\"+cStartPath
	EndIf
	If (SubStr(cStartPath,Len(cStartPath),1)<>"\") .And. (SubStr(cStartPath,Len(cStartPath),1)<>"/")
		cStartPath	+=	"\"
	EndIf	                
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para consistir o arquivo caso exista³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (File(cTrab))		
	FErase (cTrab)
Endif
nHandle	:=	MsFCreate(cTrab)

DbSelectArea (cAlias)  
(cAlias)->(DbSetOrder (1))
(cAlias)->(DbGoTop ())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³No caso de o objeto oProcess existir, significa que a nova barra  ³
//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
//| portanto deve ser efetuado os controles para demonstrar o        |
//| resultado do processamento.                                      |
//|                                                                  |
//|Definicao do incremento das reguas e atualizacao dos detalhes,    |
//| pois neste momento os detalhes nao refere-se ao primeiro histori-|
//| co, pois este se trata da geracao do arquivo e nao tinha como    |
//| contemplar este numeros sem ter os registros na tabela.          ³
//|                                                                  |
//|      DESTE PONTO EM DIANTE, OS DETALHES DEVEM SER ISOLADOS       |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("oProcess")=="O"
	oProcess:Set1Progress(nRecCount)
	
	oProcess:Set2Progress(1)
	oProcess:Inc2Progress("","")
	
	oProcess:SetDetProgress(STR0026,nRecCount,;		//"Total de registros do periodo solicitado"
				STR0027,0,;							//"Total de registros processados por segundo"
				STR0028,0,;							//"Total de registros pendentes para processamento"
				STR0029,0) 							//"Tempo estimado para termino do processamento (Seg.)"
Else
	ProcRegua(nRecCount)
EndIf


Do While !(cAlias)->(Eof ())
	
	If (Empty((cAlias)->TRB_FLAG))
	
		nRegsProc	+=	1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³No caso de o objeto oProcess existir, significa que a nova barra  ³
		//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
		//| portanto deve ser efetuado os controles para demonstrar o        |
		//| resultado do processamento.                                      |
		//|                                                                  |
		//|Atualizando o incremento desta rotina, ela irah utilizar somente a|
		//| primeira regua, a outra virah "cheia"                            |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//LGS#20200203 - Adequação de release 12.1.25 e posteriores
		//If Type("oProcess")=="O"
		If _lVerProc
			oProcess:Inc1Progress(STR0008,StrZero(nRegsProc,6)+"/"+StrZero(nRecCount,6))	 // "Gerando arquivo texto"				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Condicao implementada para controlar os numeros apresentadas na tela³
			//³  de processamento da rotina, os detalhes.                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cTimeDocs<>Time()
				oProcess:SetDetProgress(STR0026,nRecCount,;	 				//"Total de registros do periodo solicitado"
						STR0027,nDocsXTime,;	   		  					//"Total de registros processados por segundo"
						STR0028,nRecCount-nRegsProc,; 						//"Total de registros pendentes para processamento"
						STR0029,Round((nRecCount-nRegsProc)/nDocsXTime,0))	//"Tempo estimado para termino do processamento (Seg.)"

				cTimeDocs	:=	Time()
				nDocsXTime	:=	1
			Else
				nDocsXTime	+=	1
			EndIf
					
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Controle do cancelamento da rotina³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If oProcess:Cancel()
				Exit
			EndIf

		Else
			IncProc(STR0008) // "Gerando arquivo texto"
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Controle do cancelamento da rotina³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Interrupcao(@lEnd)
				Exit
			EndIf
		EndIf

		cRelac	 :=	(cAlias)->TRB_RELAC
		aAreaLoc :=	(cAlias)->(GetArea ())

		If ("0150"$(cAlias)->TRB_TPREG)
			SPDLeRegRel(nHandle,cAlias,"0150",{"0175"},cRelac)
			
		ElseIf ("0200"$(cAlias)->TRB_TPREG)		
			SPDLeRegRel(nHandle,cAlias,"0200",{"0205","0206","0210", "0220"},cRelac)
			
		ElseIf ("0300"$(cAlias)->TRB_TPREG)
			SPEDGrvLin(nHandle,cAlias)
			
			SPDRePorNf(nHandle,cAlias,"0305",cRelac)	

		ElseIf ("C100"$(cAlias)->TRB_TPREG)
			SPEDGrvLin(nHandle,cAlias)

			SPDRePorNf(nHandle,cAlias,"C101",cRelac)

   			SPDLeRegRel(nHandle,cAlias,"C110",{"C111","C112","C113","C114","C115","C116"},cRelac,2)

			SPDRePorNf(nHandle,cAlias,"C120",cRelac)

			SPDRePorNf(nHandle,cAlias,"C130",cRelac)

			SPDLeRegRel(nHandle,cAlias,"C140",{"C141"},cRelac,2)

			SPDRePorNf(nHandle,cAlias,"C160",cRelac)

			SPDRePorNf(nHandle,cAlias,"C165",cRelac)

			SPDLeRegRel(nHandle,cAlias,"C170",{"C171","C172","C173","C174","C175","C176","C177","C178","C179"},cRelac)

			SPDRePorNf(nHandle,cAlias,"C190",cRelac)
			
			SPDLeRegRel(nHandle,cAlias,"C195",{"C197"},cRelac,2)

		ElseIf ("C300"$(cAlias)->TRB_TPREG)		
			SPEDGrvLin (nHandle, cAlias)

			aStrtk := StrToKarr((cAlias)->TRB_CONT,"|")
			If Val(aStrtk[7]) == 0 			                                     
                      aAreaC310	:=	(cAlias)->(GetArea ())
		              
	                     While !(cAlias)->(Eof ()) 
					           If (cAlias)->TRB_TPREG == "C310" .And. (cAlias)->TRB_FLAG <> "*"
						            If SubStr((cAlias)->TRB_CONT,7,6) >=  aStrtk[4] .And. SubStr((cAlias)->TRB_CONT,7,6) <= aStrtk[5]
			                         SPEDLeRegs(nHandle,cAlias,{{"C310",0}},(cAlias)->TRB_RELAC)			                        	                           
			                       EndIf 
		                      EndIf    
	                     (cAlias)->(DbSkip ())                
	                     EndDo	

	                  RestArea (aAreaC310)     		    

			   SPEDLeRegs(nHandle,cAlias,{{"C320",0},"C321"},cRelac)
			Else
			   SPEDLeRegs(nHandle,cAlias,{"C310",{"C320",0},"C321"},cRelac)
			EndIf
					
		ElseIf ("C350"$(cAlias)->TRB_TPREG)
			SPEDGrvLin(nHandle,cAlias)

			SPDRePorNf(nHandle,cAlias,"C370",cRelac,(cAlias)->TRB_ITEM)

			SPDRePorNf(nHandle,cAlias,"C390",cRelac,(cAlias)->TRB_ITEM)
			
		ElseIf ("C400"$(cAlias)->TRB_TPREG)
			SPEDGrvLin (nHandle, cAlias)

			cChave	:="C405"+cRelac
			If ((cAlias)->(MsSeek (cChave)))
				Do While !(cAlias)->(Eof ()) .And. cChave==(cAlias)->TRB_TPREG+(cAlias)->TRB_RELAC
					aArea2	:=	(cAlias)->(GetArea ())
					SPEDGrvLin (nHandle, cAlias)
					SPDRePorNf (nHandle, cAlias, "C410", StrZero((cAlias)->TRB_ITEM, nTamTRBIt, 0)+StrZero((cAlias)->TRB_ITEM, nTamTRBIt, 0), (cAlias)->TRB_ITEM) 
					//
					cChave	:=	"C420" + StrZero((cAlias)->TRB_ITEM, nTamTRBIt, 0)+StrZero((cAlias)->TRB_ITEM, nTamTRBIt, 0)
					If ((cAlias)->(MsSeek (cChave)))

						Do While !(cAlias)->(Eof ()) .And. cChave==(cAlias)->TRB_TPREG+(cAlias)->TRB_RELAC
							SPEDGrvLin (nHandle, cAlias)
							SPDRePorNf (nHandle, cAlias, "C425", StrZero((cAlias)->TRB_ITEM, nTamTRBIt, 0)+StrZero((cAlias)->TRB_ITEM, nTamTRBIt, 0))
							(cAlias)->(DbSkip ())
						EndDo
					EndIf
					//
					//retorna ao registro c405
					RestArea (aArea2)
					cChave	:=	"C460"+ StrZero((cAlias)->TRB_ITEM, nTamTRBIt, 0) + StrZero((cAlias)->TRB_ITEM, nTamTRBIt, 0)
					nISuperPai := (cAlias)->TRB_ITEM //Referencia de relacionamento com o Registro C405 (Super Pai)- Usado para Ambiente TOP
					If ((cAlias)->(MsSeek (cChave)))
						nItem := Nil
						Do While !(cAlias)->(Eof ()) .And. cChave==(cAlias)->TRB_TPREG+(cAlias)->TRB_RELAC
							SPEDGrvLin (nHandle, cAlias) //gera linha c460
							If lTop
								nItem := (cAlias)->TRB_ITEM															
							Else
								nISuperPai := (cAlias)->TRB_ITEM 
							EndIf
							SPDRePorNf (nHandle, cAlias, "C470", StrZero(nISuperPai, nTamTRBIt, 0)+StrZero((cAlias)->TRB_ITEM, nTamTRBIt, 0), nItem)
							(cAlias)->(DbSkip ())
						EndDo                                     
					EndIf
					//retorna ao registro c405
					RestArea (aArea2)            
											
					SPDRePorNf (nHandle, cAlias, "C490", StrZero((cAlias)->TRB_ITEM, nTamTRBIt, 0)+StrZero((cAlias)->TRB_ITEM, nTamTRBIt, 0))
					
					(cAlias)->(DbSkip ()) 
					
					cChave	:="C405"+cRelac
				EndDo
			EndIf
			
		ElseIf ("C500"$(cAlias)->TRB_TPREG)
			SPEDGrvLin (nHandle, cAlias)

			SPDRePorNf(nHandle,cAlias,"C510",cRelac)

			SPDRePorNf(nHandle,cAlias,"C590",cRelac)
			
		ElseIf ("C600"$(cAlias)->TRB_TPREG)
		
			SPDLeRegRel(nHandle,cAlias,"C600",{"C601","C610","C690"},cRelac,2)
			
		ElseIf ("C700"$(cAlias)->TRB_TPREG)
			SPEDGrvLin(nHandle,cAlias)

			SPDLeRegRel(nHandle,cAlias,"C790",{"C791"},cRelac)
			
		ElseIf ("C800"$(cAlias)->TRB_TPREG)  
			SPDLeRegRel(nHandle,cAlias,"C800",{"C850"},cRelac)
		
		ElseIf ("C860"$(cAlias)->TRB_TPREG)  
			SPDLeRegRel(nHandle,cAlias,"C860",{"C890"},cRelac)	
		
		ElseIf ("D100"$(cAlias)->TRB_TPREG)
			SPEDGrvLin(nHandle,cAlias)

			SPDRePorNf(nHandle,cAlias,"D101",cRelac)

			SPDLeRegRel(nHandle,cAlias,"D110",{"D120"},cRelac)

			SPDRePorNf(nHandle,cAlias,"D130",cRelac,(cAlias)->TRB_ITEM)

			SPDRePorNf(nHandle,cAlias,"D140",cRelac,(cAlias)->TRB_ITEM)

			SPDRePorNf(nHandle,cAlias,"D150",cRelac,(cAlias)->TRB_ITEM)

			SPDLeRegRel(nHandle,cAlias,"D160",{"D161","D162"},cRelac)

			SPDRePorNf(nHandle,cAlias,"D170",cRelac,(cAlias)->TRB_ITEM)
			
			SPDRePorNf(nHandle,cAlias,"D180",cRelac,(cAlias)->TRB_ITEM)
			
			SPDRePorNf(nHandle,cAlias,"D190",cRelac,(cAlias)->TRB_ITEM)

			SPDLeRegRel(nHandle,cAlias,"D195",{"D197"},cRelac,2)

		ElseIf ("D300"$(cAlias)->TRB_TPREG)
			SPEDGrvLin(nHandle,cAlias)

			SPDRePorNf(nHandle,cAlias,"D301",cRelac)

			SPDRePorNf(nHandle,cAlias,"D310",cRelac)
			
		ElseIf ("D350"$(cAlias)->TRB_TPREG)
			SPEDGrvLin (nHandle, cAlias)

			SPEDLeRegs(nHandle,cAlias,{"D355","D360",{"D365",1},"D370",{"D390",1}},cRelac)
		
		ElseIf ("D400"$(cAlias)->TRB_TPREG)
			SPEDGrvLin(nHandle,cAlias)

			SPDLeRegRel(nHandle,cAlias,"D410",{"D411"},cRelac)

			SPDRePorNf(nHandle,cAlias,"D420",cRelac)
						
		ElseIf ("D500"$(cAlias)->TRB_TPREG)
			SPEDGrvLin(nHandle,cAlias)

			SPDRePorNf(nHandle,cAlias,"D510",cRelac)

			SPDRePorNf(nHandle,cAlias,"D530",cRelac)

			SPDRePorNf(nHandle,cAlias,"D590",cRelac)
			
		ElseIf ("D600"$(cAlias)->TRB_TPREG)
			SPEDGrvLin(nHandle,cAlias)

			SPDRePorNf(nHandle,cAlias,"D610",cRelac)

			SPDRePorNf(nHandle,cAlias,"D690",cRelac)
			
		ElseIf ("D695"$(cAlias)->TRB_TPREG)
			SPEDGrvLin(nHandle,cAlias)

			SPDLeRegRel(nHandle,cAlias,"D696",{"D697"},cRelac)

		ElseIf ("E110"$(cAlias)->TRB_TPREG)
			SPEDGrvLin(nHandle,cAlias)

			SPEDLeRegs(nHandle,cAlias,{"E111","E112",{"E113",1}},cRelac)

		ElseIf ("E200"$(cAlias)->TRB_TPREG)
			SPEDGrvLin(nHandle,cAlias)
			
			SPEDLeRegs(nHandle,cAlias,{"E210","E220",{"E230",2},{"E240",2},{"E250",1}},cRelac)

		ElseIf ("E300"$(cAlias)->TRB_TPREG)
			SPEDGrvLin(nHandle,cAlias)
			
			SPEDLeRegs(nHandle,cAlias,{"E310","E311","E312",{"E313",2},{"E316",1}},cRelac)
		
		ElseIf ("E500"$(cAlias)->TRB_TPREG)
			SPEDGrvLin(nHandle,cAlias)

			SPDRePorNf(nHandle,cAlias,"E510",cRelac,(cAlias)->TRB_ITEM)

			SPDLeRegRel(nHandle,cAlias,"E520",{"E530"},cRelac)
		
		ElseIf ("G125"$(cAlias)->TRB_TPREG)

			SPEDGrvLin(nHandle,cAlias)		
			
			SPEDLeRegs(nHandle,cAlias,{"G126"},cRelac)
			SPEDLeRegs(nHandle,cAlias,{"G130","G140"},cRelac)
	
		ElseIf ( "1" $ Substr((cAlias)->TRB_TPREG,1,1))
			lGravaReg1 := .T.
			
		ElseIf ( "9" $ Substr((cAlias)->TRB_TPREG,1,1))
			lGravaReg9 := .T.
		
		Elseif ("H005"$(cAlias)->TRB_TPREG)
		
			SPEDGrvLin(nHandle,cAlias)
			
			SPEDLeRegs(nHandle,cAlias,{"H010","H020"},cRelac)	
		Elseif ("K100"$(cAlias)->TRB_TPREG)   
            //LGS#20200204 - Adequação de release 12.1.25 e posteriores
            //Conout("*** SPEDFISCAL Inicio OrgTXT Bloco K: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))  
			FwLogMSG( "INFO", , 'SIGAFIS', funname(), '', '01', "*** SPEDFISCAL Inicio OrgTXT Bloco K: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()), 0 )

            SPEDGrvLin(nHandle,cAlias)
               
        Elseif ("K200"$(cAlias)->TRB_TPREG) 
                
            SPEDGrvLin(nHandle,cAlias)  
        Elseif ("K210"$(cAlias)->TRB_TPREG)   
                
            SPEDGrvLin(nHandle,cAlias)
            
            SPEDLeRegs(nHandle,cAlias,{"K215"},cRelac)      
        Elseif ("K220"$(cAlias)->TRB_TPREG) 
                
            SPEDGrvLin(nHandle,cAlias)  
        Elseif ("K230"$(cAlias)->TRB_TPREG) 
                
            SPEDGrvLin(nHandle,cAlias)
            
            SPEDLeRegs(nHandle,cAlias,{"K235"},cRelac)  
        Elseif ("K250"$(cAlias)->TRB_TPREG) 
                
            SPEDGrvLin(nHandle,cAlias)
            
            SPEDLeRegs(nHandle,cAlias,{"K255"},cRelac)      
    
        Elseif ("K260"$(cAlias)->TRB_TPREG)   
                
            SPEDGrvLin(nHandle,cAlias)
            
            SPEDLeRegs(nHandle,cAlias,{"K265"},cRelac)  
       Elseif ("K270"$(cAlias)->TRB_TPREG)  
                
            SPEDGrvLin(nHandle,cAlias)
            
            SPEDLeRegs(nHandle,cAlias,{"K275"},cRelac)
       Elseif ("K280"$(cAlias)->TRB_TPREG)  
                
            SPEDGrvLin(nHandle,cAlias)
            //LGS#20200204 - Adequação de release 12.1.25 e posteriores
            //Conout("*** SPEDFISCAL Fim OrgTXT Bloco K: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))  
			FwLogMSG( "INFO", , 'SIGAFIS', funname(), '', '01', "*** SPEDFISCAL Fim OrgTXT Bloco K: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()), 0 )

       Else
            SPEDGrvLin(nHandle,cAlias)     
       EndIf      
                    
        RestArea (aAreaLoc)
	EndIf

	(cAlias)->(DbSkip ())
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pela ordem definida no layout, os registros comecando com "1" e "9" devem ser  ³
//³impressos no final do arquivo magnetico                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
If lGravaReg1
	(cAlias)->(MsSeek("1"))
	Do While !(cAlias)->(Eof ()) .And. Substr((cAlias)->TRB_TPREG,1,1) == "1"
	
		If (Empty((cAlias)->TRB_FLAG))
	
			If ("1100"$(cAlias)->TRB_TPREG)
	
				aArea3	:=	(cAlias)->(GetArea())
	
				SPEDGrvLin(nHandle,cAlias)
	
				SPEDLeRegs(nHandle,cAlias,{"1105","1110"},(cAlias)->TRB_RELAC)
	
				RestArea(aArea3)
			
			Elseif ("1200"$(cAlias)->TRB_TPREG)
				cRelac	 :=	(cAlias)->TRB_RELAC
				SPEDGrvLin(nHandle,cAlias)
				
				SPDRePorNf(nHandle,cAlias,"1210",cRelac)
				
   			ElseIf ("1300"$(cAlias)->TRB_TPREG)
   	  	 		aArea1300	:=	(cAlias)->(GetArea())
				SPEDGrvLin (nHandle, cAlias)

			   	SPEDLeRegs(nHandle,cAlias,{"1310","1320"},(cAlias)->TRB_RELAC)
			   	RestArea(aArea1300)
			   	
			ElseIf ("1350"$(cAlias)->TRB_TPREG)
				SPEDGrvLin (nHandle, cAlias)
				
				SPDRePorNf(nHandle,cAlias,"1360",(cAlias)->TRB_RELAC)

				SPDRePorNf(nHandle,cAlias,"1370",(cAlias)->TRB_RELAC)
				
			ElseIf ("1390"$(cAlias)->TRB_TPREG)
   	  	 		aArea3	:=	(cAlias)->(GetArea())
				
				SPEDGrvLin (nHandle, cAlias)

			   	SPDRePorNf(nHandle,cAlias,"1391",(cAlias)->TRB_RELAC)
			   	
			   	RestArea(aArea3)			   						   	   	
	
			ElseIf ("1500"$(cAlias)->TRB_TPREG)
				SPEDGrvLin(nHandle,cAlias)
	
				SPDRePorNf(nHandle,cAlias,"1510",(cAlias)->TRB_RELAC)
			
			ElseIf ("1700"$(cAlias)->TRB_TPREG)
				SPEDGrvLin (nHandle, cAlias)
				
				SPDRePorNf(nHandle,cAlias,"1710",(cAlias)->TRB_RELAC)

			ElseIf ("1900"$(cAlias)->TRB_TPREG)
				aArea3	:=	(cAlias)->(GetArea())
							
				SPEDGrvLin(nHandle,cAlias)

				SPEDLeRegs(nHandle,cAlias,{"1910","1920","1921","1922",{"1923",3},{"1925",2},{"1926",2}},(cAlias)->TRB_RELAC)
                
				RestArea(aArea3)
				
			Else
				SPEDGrvLin(nHandle,cAlias)
	   		EndIf
		EndIf
		(cAlias)->(DbSkip ())
	EndDo
EndIf
If lGravaReg9
	(cAlias)->(MsSeek("9"))
	Do While !(cAlias)->(Eof ()) .And. Substr((cAlias)->TRB_TPREG,1,1) == "9"
		If (Empty ((cAlias)->TRB_FLAG))
			SPEDGrvLin (nHandle, cAlias)
		EndIf
		(cAlias)->(DbSkip ())
	EndDo
EndIf

If (nHandle>=0)
	FClose (nHandle)
Endif

If (File(cFile))		
	FErase (cFile)
Endif             

SplitPath(cFile,@cDrive,@cPath, @cNewFile,@cExt)
cNewFile	:=	cNewFile+cExt                    

GetRemoteType( @cLib )
QOut( cLib )

If Empty(cDrive)  
	IF	"HTML" $ cLib
		msg:=	FISMSG("HTML")
		msgAlert(msg)
		nRetCpy := CPYS2TW(cStartPath+cTrab)
		if nRetCpy == 0
			FErase (cTrab)
   	 		If File(cStartPath+cTrab)
     			FRename(cStartPath+cTrab,cFile)
    		EndIf
   		endIf
	ELSE	
		lCopied := __CopyFile(cTrab,cDrive+cPath+cNewFile)
		If lCopied
			FErase (cTrab)
			If File(cDrive+cPath+cTrab)
				FRename(cDrive+cPath+cTrab,cFile)
			EndIf
		EndIf
	ENDIF
Else          
	If Substr(cStartPath,Len(AllTrim(cStartPath)),1) <> "\"
		cStartPath := cStartPath + "\"
	EndIf
	IF	"HTML" $ cLib
		msg:=	FISMSG("HTML")
		msgAlert(msg)
		nRetCpy := CPYS2TW(cStartPath+cTrab)
		if nRetCpy == 0
			FErase (cTrab)
	 		If File(cStartPath+cTrab)
	 			FRename(cStartPath+cTrab,cFile)
			EndIf
		endIf
	ELSE	
		//Se o drive nao existir, pergunto ao usuario se deseja cria-lo atraves da funcao LjDirect()
		If !ExistDir(cDrive+cPath)
			LjDirect(cDrive+cPath,.T.)
		Endif
			
		If ExistDir(cDrive+cPath)
			lCopied := CpyS2T( cStartPath+cTrab,cDrive+cPath, .F. )
			If lCopied
				FErase (cTrab)
				If File(cDrive+cPath+cTrab)
					FRename(cDrive+cPath+cTrab,cFile)
				EndIf
			EndIf
			//Se o usuario nao criar o diretorio, apresento mensagem de erro
		Else
			Alert("Erro ao copiar o arquivo magnético. Diretório inválido","Erro de Diretório")
		Endif
	ENDIF
ENDIF    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³No caso de o objeto oProcess existir, significa que a nova barra  ³
//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
//| portanto deve ser efetuado os controles para demonstrar o        |
//| resultado do processamento.                                      |
//|                                                                  |
//|Atualizando o incremento da regua no final da execucao, pois pode |
//| ocorrer dos numeros nao estarem "redondos", assim os corrijo     |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("oProcess")=="O"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Condicao implementada para controlar os numeros apresentadas na tela³
	//³  de processamento da rotina, os detalhes.                          ³
	//³Ao final do processamento, para este caso da funcao, atualizo altero³
	//³  o tratamento de registros lidos, pois a funcao utiliza bastante   |		
	//³  a funcao SPDRePorNf e ela nao tem o controle de soma da variavel  ³		
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oProcess:Inc1Progress(STR0008,StrZero(nRecCount,6)+"/"+StrZero(nRecCount,6))	 // "Gerando arquivo texto"
	oProcess:SetDetProgress(STR0026,nRecCount,;		//"Total de registros do periodo solicitado"
			STR0027,nDocsXTime,;					//"Total de registros processados por segundo"
			STR0028,0,;								//"Total de registros pendentes para processamento"
			STR0029,0)								//"Tempo estimado para termino do processamento (Seg.)"
EndIf
Return (lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SPDAPICMS | Autor ³Gustavo G. Rueda 			   ³ Data ³22.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³                        GERACAO DO BLOCO E                         ³±± 
±±³          ³REGISTRO E100 - PERIODO DA APURACAO DO ICMS                        ³±± 
±±³          ³REGISTRO E110 - APURACAO DE ICMS - OPERACOES PROPRIAS              ³±± 
±±³          ³REGISTRO E111 - AJUSTES/BENEFICIOS/INCENTIVO DA APURACAO DE ICMS   ³±± 
±±³          ³REGISTRO E112 - INFORMACOES ADICIONAIS DOS AJUSTES DE APURACAO DO  ³±± 
±±³          ³                ICMS                                               ³±± 
±±³          ³REGISTRO E115- INF. ADICIONAIS DA APURACAO DO ICMS                 ³±± 
±±³          ³REGISTRO E116 - OBRIGACOES DO ICMS A RECOLHER - OPERACOES PROPRIAS ³±± 
±±³          ³REGISTRO E200 - PERIODO DA APURACAO DO ICMS ST                     ³±± 
±±³          ³REGISTRO E210 - APURACAO DO ICMS - SUBSTITUICAO TRIBUTARIA         ³±±  
±±³          ³REGISTRO E220 - AJUSTES/BENEFICIOS/INCENTIVOS DA APURACAO DO ICMS  ³±± 
±±³          ³                SUBSTITUICAO TRIBUTARIA                            ³±±  
±±³          ³REGISTRO E230 - INFORMACOES ADICIONAIS DOS AJUSTES DE APURACAO DO  ³±± 
±±³          ³                ICMS SUBSTITUICAO TRIBUTARIA                       ³±±  
±±³          ³REGISTRO E250 - OBRIGACOES DO ICMS A RECOLHER - SUBSTITUICAO       ³±± 
±±³          ³                TRIBUTARIA                                         ³±± 
±±³          ³REGISTRO E520 - APURACAO DO IPI                                    ³±±
±±³          ³REGISTRO E500 - PERIODO DA APURACAO DO IPI                         ³±± 
±±³          ³REGISTRO E510 - CONSOLIDACAO DOS VALROES DE IPI POR CFOP E CODIGO  ³±±
±±³          ³                DE TRIBUTACAO DO IPI                               ³±±
±±³          ³                                                                   ³±±
±±³          ³Funcao utilizada para montar a estrutura dos registros acima e     ³±±
±±³          ³  gravar no TRB para geracao do TXT                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 -> Identifica se houve movimento no periodo ou nao           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cFilDe   - Filial inicial para processament multifilial            ³±±
±±³          ³cFilAte  - Filial final para processament multifilial              ³±±
±±³          ³nApuracao -> Tipo de apuracao, padrao 3                            ³±±
±±³          ³nPeriodo  -> Periodo de apuracao, padrao 1                         ³±±
±±³          ³cNrLivro  -> Numero do livro selecionado no wizard                 ³±±
±±³          ³cImp -> imposto de processamento. IC=ICMS,ST=SUBST. TRIBUTARIA     ³±±
±±³          ³cAlias   - Alias do TRB                                            ³±±
±±³          ³dDataDe -> Data inicio de processamento inf. no wizard             ³±±
±±³          ³dDataAte -> Data final de processamento inf. no wizard             ³±±
±±³          ³lTop     - Flag para identificar ambiente TOP                      ³±±
±±³          ³lImpCrdST -> Flago de processamento do CredST conforme wizard      ³±±
±±³          ³cArqAnt- Arquivo de apuraao do periodo anterior inf. no wizard     ³±±
±±³          ³oProcess - Objeto do novo controle de processamento                ³±±
±±³          ³aVlrMovST- Valores de apuracao obtidos durante o processamento dos ³±±
±±³          ³           documentos                                              ³±±
±±³          |aIcmPago - Informacoes das GNREs de documentos fiscais para o E250 ³±±
±±³          |cMVSUBTRIB -> Conteudo do parametro MV_SUBTRIB 					 ³±±
±±³			 |aLanCDA -> Array contendo a tabela CDA.		                     ³±±
±±³			 |aLanCDA2 -> Array contendo a tabela CDA. (Totalizador)             ³±±
±±³			 |cMVSTNIEUF - Conteudo do parametro MV_STNIEUF, auxilia do MV_SUBTRIB³±±
±±³			 |aLanCDA2 -> Array contendo a tabela CDA. (Totalizador)             ³±±
±±³			 |lExtratTAF -> Indica se a chamada da funcao eh o Extrator TAF      ³±±
±±³			 |aRegT020 -> Gera informacoes do Registro T020 do TAF               ³±±
±±³			 |aRegT020AA -> Gera informacoes do Registro T020AA do TAF           ³±±
±±³			 |aRegT020AB -> Gera informacoes do Registro T020AB do TAF           ³±±
±±³			 |aRegT020AC -> Gera informacoes do Registro T020AC do TAF           ³±±
±±³			 |aRegT020AE -> Gera informacoes do Registro T020AE do TAF           ³±±
±±³			 |cVerSPDFis -> Versao do Sped Fiscal                                ³±± 
±±³			 |cMvSFUfGnr - UF's que geram Classe de Vencimento no campo 05 		 ³±±
±±³			 |				do registro E116									 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SPDAPICMS(	cFilDe,		cFilAte,	nApuracao,	nPeriodo,	cNrLivro,	cImp,		cAlias,		dDataDe,;	
					dDataAte,	cMVEstado,	lTop,		lImpCrdST,	cArqAnt,	oProcess,	aVlrMovST,	aIcmPago,;
					cMVSUBTRIB,	aLanCDA,	aLanCDA2,	cMVSTNIEUF, lOldLan, 	lExtratTAF, aRegT020, 	aRegT020AA,;
					aRegT020AB,	aRegT020AC, aRegT020AE,	aRegT021Val,	aRegT021Est,	aRegT021AA,	aRegT021AB,	aRegT021AC,;
					aRegT021AD,	cVerSPDFis,	aReg0200,	aReg0190,	aReg0220,	cMvSFUfGnr, aRegT020AG, aWizard, aRegT020AD )

Local 	cChave	 	:= 	STR(nApuracao,1)+STR(nPeriodo,1)+DTOS(dDataDe)+cNrLivro
Local 	lRet		:= 	.T.
Local	lAjusteNF 	:= 	.F.
Local	nPosAj	 	:= 	0
Local	nUf		 	:= 	0
Local 	nPos		:= 	0
Local 	cSomaSeq	:= 	""
Local 	cSequen	 	:= 	""
Local	nRecnoSF6	:=	Nil
//Local 	cAliasSF6  	:= 	'SF6'
Local	aParametros	:=	{}
Local 	cUf		 	:= 	cMvEstado
Local 	cCodAjApur 	:= 	""
Local	lAchouSF6	:=	.F.
Local	cAliasCDH	:=	"CDH"
Local 	nPosE111	:=	0
Local  nPosT020AG := 0
//Local	aApuracao	:=	{}
Local	aRegE110	:=	{"E110",0,0,0,0,0,0,0,0,0,0,0,0,0,0}
Local	aRegE111 	:= 	{}
Local	aRegE112 	:= 	{}
Local	aRegE113	:=	{}
Local	aRegE240 	:= 	{}    
Local	aRegE116 	:= 	{}
Local	aRegE200 	:= 	{}
Local	aRegE210 	:= 	{}
Local	aRegE220 	:= 	{}
Local	aRegE230 	:= 	{}
Local	aRegE250 	:= 	{}
Local	nX			:=	0
Local   nPosE220	:=  0
Local 	lCmpsE113	:=	cUf $ aSPDSX6[MV_ESTE113]
Local 	lCmpsE240	:=	cUf $ aSPDSX6[MV_ESTE240]	
Local	cCodE240	:=	""
Local	aRegE115	:=	{}

Local	cTamProd 	:=	TamSx3("B1_COD")[1]

Default aVlrMovST	:=	{}
Default aLanCDA		:=	{}          
Default lOldLan	 	:= 	aSPDSX3[FP_CC6_TIPOAJ]
Default aRegT020    :=  {}	 
Default aRegT020AA  :=  {}  
Default aRegT020AB  :=  {}  
Default aRegT020AC  :=  {} 
Default aRegT020AD  :=  {} 
Default aRegT020AE  :=  {}
Default aRegT020AG  :=  {}

Default aRegT021Val :=  {} 
Default aRegT021Est :=  {} 
Default aRegT021AA  :=  {} 
Default aRegT021AB  :=  {} 
Default aRegT021AC  :=  {}
Default aRegT021AD  :=  {}  
Default aReg0200    :=  {} 
Default aReg0190    :=  {} 
Default aReg0220    :=  {}
Default lExtratTAF  := .F.
Default cVerSPDFis  := cVersao
Default	cMvSFUfGnr	:=	aSPDSX6[MV_SFUFGNR]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³No caso de o objeto oProcess existir, significa que a nova barra  ³
//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
//| portanto deve ser efetuado os controles para demonstrar o        |
//| resultado do processamento.                                      |
//|                                                                  |
//|Incremento da regua, como o processamento da funcao eh muito      |
//| rapido nao preciso de mais detalhes                              |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("oProcess")=="O"
	oProcess:Inc2Progress(STR0005,"") // "Obtendo Informações de Apuração de ICMS"  
Else
	IncProc(STR0005) // "Obtendo Informações de Apuração de ICMS"
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Para ambiente TOP nao preciso pegar a ultima sequencia, pois isso eh resolvido na propria query³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTop
	If CDH->(MsSeek(xFilial("CDH")+cImp+cChave))
		cSomaSeq  := CDH->CDH_SEQUEN
		While CDH->(MsSeek(xFilial("CDH")+cImp+cChave+cSomaSeq)) // Posiciona na ultima sequencia
			cSequen  := CDH->CDH_SEQUEN
			cSomaSeq := Soma1(cSequen)
		EndDo
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montando parametros para a query ou indregua³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aParametros,cImp)
aAdd(aParametros,STR(nApuracao,1))
aAdd(aParametros,STR(nPeriodo,1))
aAdd(aParametros,DTOS(dDataDe))
aAdd(aParametros,cNrLivro)
aAdd(aParametros,cSequen)

If SPEDFFiltro(1,"CDH",@cAliasCDH,aParametros)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³REGISTRO E110 - APURACAO DE ICMS - OPERACOES PROPRIAS³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cImp=="IC"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega ajustes na apuracao ICMS ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		While !(cAliasCDH)->(Eof())
			
			cCodAjApur 	:= 	(cAliasCDH)->CDH_CODLAN
			nPosE111	:=	0
			nPosT020AG := 0
			lGeraE111	:=	.F.
			lGeraE116	:=	.F.
			nRecnoSF6	:=	Iif(lTop,(cAliasCDH)->SF6RECNO,Nil)
			lAchouSF6	:=	.F.
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posicionamento da tabela SF6, tanto para TOP (RECNO) quanto para DBF/ADS    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty((cAliasCDH)->(CDH_ESTGNR+CDH_GNRE))
				lAchouSF6	:=	SPEDSeek("SF6",1,xFilial("SF6")+(cAliasCDH)->(CDH_ESTGNR+CDH_GNRE),nRecnoSF6)
			EndIf
			
			Do Case
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Case que determina o calculo do (2)VL_TOT_DEBITOS = Valor total dos debitos  ³
				//³     por "SAIDAS E PRESTACOES COM DEBITO DO IMPOSTO"                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Case (cAliasCDH)->CDH_LINHA == "001"
					aRegE110[2] += (cAliasCDH)->CDH_VALOR
					
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Case que determina o calculo de 2 lancamentos:                               |
				//|- (3)VL_AJ_DEBITOS = Valor total dos ajustes a debitos provenitentes de NF   ³
				//³- (4)VL_TOT_AJ_DEBITOS = Valor total dos ajustes a debitos                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Case (cAliasCDH)->CDH_LINHA $ "002" .And. Alltrim((cAliasCDH)->CDH_SUBITE) <> "002.00" .And. !Empty((cAliasCDH)->CDH_CODLAN)	//Lancamentos a outros debitos
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Tratamento para o codigo no formato antigo (NAO SE UTILIZA MAIS) ou para o novo de 10 posicoes³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (lOldLan .And. SubStr((cAliasCDH)->CDH_CODLAN,1,1)=="1") .Or.;	//No formato antigo, os que iniciam por 1 sao lancamentos de NF
					   (!lOldLan .And. Len(Alltrim((cAliasCDH)->CDH_CODLAN))==10)		//Tamanho 10 eh soh os lancamentos de NF
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se for ajuste com origem em NF, ja vai estar lancado no C197³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aRegE110[3] += (cAliasCDH)->CDH_VALOR
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Conforme cadastro de ajuste manual, quando a terceira posicao do codigo for ³
						//³   0=ICMS e a quarta for 0=Outros Debitos, considero este valor.            ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If SubStr((cAliasCDH)->CDH_CODLAN,3,1)=="0" .And. SubStr((cAliasCDH)->CDH_CODLAN,4,1)== "0"
							aRegE110[4] += (cAliasCDH)->CDH_VALOR
						EndIf
						
						lGeraE111	:=	.T.
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se for ajuste de apuracao precisa lancar no E111³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lOldLan	//Codigo de lancamento antigo tem outro formato, e precisa ser convertido para um DEFAULT para nao apresentar erro de validacao
							cCodAjApur := cUf+"0"+"0"+"9999"
						EndIf
					EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Case que determina o calculo de 2 lancamentos:                               |
				//|- (3)VL_AJ_DEBITOS = Valor total dos ajustes a debitos provenitentes de NF   ³
				//³- (5)VL_ESTORNOS_CRED = Valor total dos ajustes "ESTORNO DE CREDITOS"        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
				Case (cAliasCDH)->CDH_LINHA $ "003" .And. Alltrim((cAliasCDH)->CDH_SUBITE) <> "003.00" .And. !Empty((cAliasCDH)->CDH_CODLAN)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Tratamento para o codigo no formato antigo (NAO SE UTILIZA MAIS) ou para o novo de 10 posicoes³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (lOldLan .And. SubStr((cAliasCDH)->CDH_CODLAN,1,1)=="1") .Or.;	//No formato antigo, os que iniciam por 1 sao lancamentos de NF
					   (!lOldLan .And. Len(Alltrim((cAliasCDH)->CDH_CODLAN))==10)		//Tamanho 10 eh soh os lancamentos de NF
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se for ajuste com origem em NF, ja vai estar lancado no C197³
						//|                                                            |
						//|Um lancacamento a ESTORNO DE CREDITO proveniente de NF,     |
						//|  tambem entra como DEBITO(3)                               |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aRegE110[3] += (cAliasCDH)->CDH_VALOR
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Conforme cadastro de ajuste manual, quando a terceira posicao do codigo for ³
						//³   0=ICMS e a quarta for 1=Estorno de Credito, considero este valor.        ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If SubStr((cAliasCDH)->CDH_CODLAN,3,1)=="0" .And. SubStr((cAliasCDH)->CDH_CODLAN,4,1)== "1"
							aRegE110[5] += (cAliasCDH)->CDH_VALOR
						EndIf
						
						lGeraE111	:=	.T.

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se for ajuste de apuracao precisa lancar no E111³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lOldLan
							cCodAjApur := cUf+"0"+"1"+"9999"
						EndIf
					EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Case que determina o calculo do (6)VL_TOT_CREDITOS = Valor total dos creditos³
				//³     por "ENTRADAS E AQUISICOES COM CREDITO DO IMPOSTO"                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Case (cAliasCDH)->CDH_LINHA == "005"
					aRegE110[6] += (cAliasCDH)->CDH_VALOR

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Case que determina o calculo de 2 lancamentos:                               |
				//|- (7)VL_AJ_CREDITOS = Valor total dos ajustes a creditos provenitentes de NF ³
				//³- (8)VL_TOT_AJ_CREDITOS = Valor total dos "AJUSTES A CREDITO"                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Case (cAliasCDH)->CDH_LINHA $ "006" .And. Alltrim((cAliasCDH)->CDH_SUBITE) <> "006.00" .And. !Empty((cAliasCDH)->CDH_CODLAN)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Tratamento para o codigo no formato antigo (NAO SE UTILIZA MAIS) ou para o novo de 10 posicoes³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (lOldLan .And. SubStr((cAliasCDH)->CDH_CODLAN,1,1)=="1") .Or.;	//No formato antigo, os que iniciam por 1 sao lancamentos de NF
					   (!lOldLan .And. Len(Alltrim((cAliasCDH)->CDH_CODLAN))==10)		//Tamanho 10 eh soh os lancamentos de NF
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se for ajuste com origem em NF, ja vai estar lancado no C197³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aRegE110[7] += (cAliasCDH)->CDH_VALOR
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Conforme cadastro de ajuste manual, quando a terceira posicao do codigo for ³
						//³   0=ICMS e a quarta for 2=Outros Creditos, considero este valor.           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					    If SubStr((cAliasCDH)->CDH_CODLAN,3,1)=="0" .And. SubStr((cAliasCDH)->CDH_CODLAN,4,1)== "2"
							aRegE110[8] += (cAliasCDH)->CDH_VALOR
						EndIf
						
						lGeraE111	:=	.T.

						//³Se for ajuste de apuracao precisa lancar no E111³
						
						If lOldLan
							cCodAjApur := cUf+"0"+"2"+"9999"
						EndIf
					EndIf

				//³Case que determina o calculo de 2 lancamentos:                               |
				//|- (7)VL_AJ_CREDITOS = Valor total dos ajustes a creditos provenitentes de NF ³
				//³- (9)VL_ESTORNOS_DEB = Valor total dos ajustes "ESTORNO DE DEBITOS"          ³
			
				Case (cAliasCDH)->CDH_LINHA $ "007" .And. Alltrim((cAliasCDH)->CDH_SUBITE) <> "007.00" .And. !Empty((cAliasCDH)->CDH_CODLAN)
					//³Tratamento para o codigo no formato antigo (NAO SE UTILIZA MAIS) ou para o novo de 10 posicoes³
					If (lOldLan .And. SubStr((cAliasCDH)->CDH_CODLAN,1,1)=="1") .Or.;	//No formato antigo, os que iniciam por 1 sao lancamentos de NF
					   (!lOldLan .And. Len(Alltrim((cAliasCDH)->CDH_CODLAN))==10)		//Tamanho 10 eh soh os lancamentos de NF
						//³Se for ajuste com origem em NF, ja vai estar lancado no C197³
						aRegE110[7] += (cAliasCDH)->CDH_VALOR
					Else
						//³Conforme cadastro de ajuste manual, quando a terceira posicao do codigo for ³
						//³   0=ICMS e a quarta for 3=Estorno de debitos, considero este valor.        ³
						If SubStr((cAliasCDH)->CDH_CODLAN,3,1)=="0" .And. SubStr((cAliasCDH)->CDH_CODLAN,4,1)=="3"
							aRegE110[9] += (cAliasCDH)->CDH_VALOR
						EndIf
						
						lGeraE111	:=	.T.

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se for ajuste de apuracao precisa lancar no E111³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lOldLan
							cCodAjApur := cUf+"0"+"3"+"9999"
						EndIf
					EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Case que determina o calculo do (10)VL_SLD_CREDOR_ANT = Valor total do "SALDO|
				//³  CREDOR DO PERIODO ANTERIOR"                                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Case (cAliasCDH)->CDH_LINHA == "009"
					aRegE110[10] += (cAliasCDH)->CDH_VALOR
					
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Case que determina o calculo do (10)VL_SLD_APURADO = Valor do saldo devedor  |
				//³  apurado                                                                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
				Case (cAliasCDH)->CDH_LINHA == "011"
					aRegE110[11] += (cAliasCDH)->CDH_VALOR

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Case que determina o calculo de 2 lancamentos:                               |
				//|- (7)VL_AJ_CREDITOS = Valor total dos ajustes a creditos provenitentes de NF ³
				//³- (12)VL_TOT_DED = Valor total de "DEDUCOES"                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Case (cAliasCDH)->CDH_LINHA $ "012" .And. Alltrim((cAliasCDH)->CDH_SUBITE) <> "012.00" .And. !Empty((cAliasCDH)->CDH_CODLAN)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Tratamento para o codigo no formato antigo (NAO SE UTILIZA MAIS) ou para o novo de 10 posicoes³
					//³																								 ³
					//³O valor informado deve corresponder ao somatorio do campo VL_ICMS dos registros C197 e D197,se³
					//³o terceiro caractere do codigo de ajuste dos registros C197 ou D197 for '0', '1' ou '2' e o	 ³
					//³quarto caractere for '0', '3', '4' ou '5'.													 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (lOldLan .And. SubStr((cAliasCDH)->CDH_CODLAN,1,1)=="1") .Or.;	//No formato antigo, os que iniciam por 1 sao lancamentos de NF
					   (!lOldLan .And. Len(Alltrim((cAliasCDH)->CDH_CODLAN))==10 .And. SubStr((cAliasCDH)->CDH_CODLAN,3,1)$'012' .And. SubStr((cAliasCDH)->CDH_CODLAN,4,1)$'0345' ) //Tamanho 10 eh soh os lancamentos de NF
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se for ajuste com origem em NF, ja vai estar lancado no C197³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aRegE110[7] += (cAliasCDH)->CDH_VALOR
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Conforme cadastro de ajuste manual, quando a terceira posicao do codigo for 0=ICMS e a quarta		³
					//³for 4=Deducoes, considero este valor.               												    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Elseif ( Len(Alltrim((cAliasCDH)->CDH_CODLAN))==8 .And. SubStr((cAliasCDH)->CDH_CODLAN,3,1)=="0" .And. SubStr((cAliasCDH)->CDH_CODLAN,4,1)=="4" )
						aRegE110[12] += (cAliasCDH)->CDH_VALOR
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se for ajuste de apuracao precisa lancar no E111³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						lGeraE111	:=	.T.
						If lOldLan
							cCodAjApur := cUf+"0"+"4"+"9999"
						EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Quando se tratar dos codigos de 10 posicoes (documento):												³
					//³o valor informado deve corresponder ao somatorio do campo VL_ICMS dos registros C197 e D197, se o	³ 
					//³terceiro caractere do codigo de ajuste do registro C197 ou D197, for '6' e o quarto caractere for '0'³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Elseif	( Len(Alltrim((cAliasCDH)->CDH_CODLAN))==10 .And. SubStr((cAliasCDH)->CDH_CODLAN,3,1)$'6' .And. SubStr((cAliasCDH)->CDH_CODLAN,4,1)$'0' ) //Tamanho 10 eh soh os lancamentos de NF
						aRegE110[12] += (cAliasCDH)->CDH_VALOR
					Endif	
					
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Case que determina o calculo do (13)VL_ICMS_RECOLHER = Valor total de        |
				//³  "ICMS A RECOLHER"                                                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Case (cAliasCDH)->CDH_LINHA == "013"
					aRegE110[13] += (cAliasCDH)->CDH_VALOR
					
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Case que determina o calculo do (14)VL_SLD_CREDOR_TRANSPORTAR = Valor total  |
				//³  de "SALDO CREDOR A TRANSPORTAR PARA O PERIODO SEGUINTE"                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Case (cAliasCDH)->CDH_LINHA == "014"
					aRegE110[14] += (cAliasCDH)->CDH_VALOR 				
					
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Case que determina o calculo de 2 lancamentos:                               |
				//|- (15)DEB_ESP = valores recolhidos ou a recolher extra-apuracao              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Case (cAliasCDH)->CDH_LINHA$"900" .And. Alltrim((cAliasCDH)->CDH_SUBITE)<>"900.00" .And. !Empty((cAliasCDH)->CDH_CODLAN)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Tratamento para o codigo no formato antigo (NAO SE UTILIZA MAIS) ou para o novo de 10 posicoes³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (lOldLan .And. SubStr((cAliasCDH)->CDH_CODLAN,1,1)=="1") .Or.;	//No formato antigo, os que iniciam por 1 sao lancamentos de NF
					   (!lOldLan .And. Len(Alltrim((cAliasCDH)->CDH_CODLAN))==10)		//Tamanho 10 eh soh os lancamentos de NF
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se for ajuste com origem em NF, ja vai estar lancado no C197³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aRegE110[15] += (cAliasCDH)->CDH_VALOR
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Conforme cadastro de ajuste manual, quando a terceira posicao do codigo for ³
						//³   0=ICMS e a quarta for 5=Debitos especiais, considero este valor.         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If SubStr((cAliasCDH)->CDH_CODLAN,3,1)=="0" .And. SubStr((cAliasCDH)->CDH_CODLAN,4,1)=="5"
							aRegE110[15] += (cAliasCDH)->CDH_VALOR
						EndIf
						
						lGeraE111	:=	.T.

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se for ajuste de apuracao precisa lancar no E111³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lOldLan
							cCodAjApur := cUf+"0"+"5"+"9999"
						EndIf
					
					EndIf
				
			EndCase   
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|REGISTRO E111 - AJUSTES/BENEFICIOS/INCENTIVO DA APURACAO DE ICMS            |
			//|                                                                            |
			//³Tratamento para gerar a estrutura do retgistro E111 conforme condicoes acima³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lGeraE111
				aAdd(aRegE111, {})
				nPosE111	:=	Len(aRegE111)
				aAdd (aRegE111[nPosE111], 1)								//01 - REG
				aAdd (aRegE111[nPosE111], "E111")							//01 - REG
				aAdd (aRegE111[nPosE111], cCodAjApur)						//02 - COD_AJ_APUR
				aAdd (aRegE111[nPosE111], (cAliasCDH)->CDH_DESC)			//03 - DESCR_COMPL_AJ
				aAdd (aRegE111[nPosE111], (cAliasCDH)->CDH_VALOR)			//04 - VL_AJ_APUR
				If lExtratTAF
					aAdd (aRegE111[nPosE111], (cAliasCDH)->CDH_SUBITE)			//05 - SUBITEM
					
					//creditos acumulados-
					If Alltrim((cAliasCDH)->CDH_SUBITE ) $ ("002.20|002.21|007.40|007.41|002.23|007.44|007.45")
						aAdd(aRegT020AG, {})
						nPosT020AG	:=	Len(aRegT020AG)
						aAdd (aRegT020AG[nPosT020AG], (cAliasCDH)->CDH_DESC)						//01 - COD_AUTO
						aAdd (aRegT020AG[nPosT020AG], (cAliasCDH)->CDH_VALOR)						//02 - VALOR
					Endif
					
				Endif
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³REGISTRO E112 - INFORMACOES ADICIONAIS DOS AJUSTES DE APURACAO DO ICMS³
			//|                                                                      |
			//|Segundo o manuel, eh necessario haver um DA (Documento de arrecadacao |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPosE111>0 .And. lAchouSF6
				aAdd(aRegE112, {})
				nPos	:=	Len (aRegE112)
				aAdd (aRegE112[nPos], nPosE111)					   			//RELACIONAMENTO COM O E111
				aAdd (aRegE112[nPos], "E112")								//01 - REG
				aAdd (aRegE112[nPos], SF6->F6_NUMERO)						//02 - NUM_DA
				aAdd (aRegE112[nPos], SF6->F6_NUMPROC)						//03 - NUM_PROC
				aAdd (aRegE112[nPos], SF6->F6_INDPROC)						//04 - IND_PROC
				aAdd (aRegE112[nPos], (cAliasCDH)->CDH_DESC)				//05 - PROC
				aAdd (aRegE112[nPos], SF6->F6_DESCOMP)						//06 - TXT_COMPL
				If lExtratTAF
					aAdd (aRegE112[nPos], IIF(Empty(SF6->F6_NUMERO),"",IIF(SF6->F6_TIPOIMP=="0","0","1")))		
				Endif
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³REGISTRO E113: INFORMACOES ADICIONAIS DOS AJUSTES DA APURACAO DO ICMS ³
			//³ IDENTIFICACAO DOS DOCUMENTOS FISCAIS.								 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lCmpsE113 .And. nPosE111>0 .And. Len(aLanCDA2)>0
				For nX := 1 To Len(aLanCDA2)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Vai percorrer todo o Array aLanCDA2 (Totalizador CDA) em busca dos registro referentes ao Codigo de Ajuste do E111³
					//³e Filtrando por ICMS proprio, terceiro digito do Codigo de Ajuste = 0 e assim Gerar um E113 por documento.		 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If cUf<>"PE"
						If AllTrim(aLanCDA2[nX][1]) == AllTrim(cCodAjApur) .And. SubStr(AllTrim(aLanCDA2[nX][1]),3,1) == "0"
							If (cAliasCDH)->CDH_TPLANC <> "M"
								aAdd(aRegE113, {})
								nPos :=	Len(aRegE113)
								aAdd (aRegE113[nPos], nPosE111)								//RELACIONAMENTO COM O E111
								aAdd (aRegE113[nPos], "E113")								//01 - REG
								aAdd (aRegE113[nPos], aLanCDA2[nX][15])					//02 - COD_PART
								aAdd (aRegE113[nPos], AModNot(aLanCDA2[nX][8]))			//03 - COD_MOD
								aAdd (aRegE113[nPos], aLanCDA2[nX][9])						//04 - SER
								aAdd (aRegE113[nPos], "")									//05 - SUB
								aAdd (aRegE113[nPos], aLanCDA2[nX][10])					//06 - NUM_DOC 
								aAdd (aRegE113[nPos], StrZero(Day(aLanCDA2[nX][16]),2)+;
													  StrZero(Month(aLanCDA2[nX][16]),2)+;
								  					  StrZero(Year(aLanCDA2[nX][16]),4))	//07 - DT_DOC							
								aAdd (aRegE113[nPos], IIf(cUf<>"MS",aLanCDA2[nX][13],""))	//08 - COD_ITEM
								aAdd (aRegE113[nPos], aLanCDA2[nX][5])						//09 - VL_AJ_ITEM
								IF cVersao >= "011"
									aAdd (aRegE113[nPos], aLanCDA2[nX][17])					//10 - CHV_DOCe
								Endif
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Caso exista produto incluo no 0200³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If !Empty(aLanCDA2[nX,13]) .And. cUf<>"MS" .And. !lExtratTAF
									If aScan ( aReg0200, { |aX| aX[2] == aLanCDA2[nX][13] }) == 0
									     //CH: TRQFF0 - Neste momento não tenho as informações do aProd pra passar nas posições 6 e 7 da SFRG0200()
									     //Como a SB1 já está aberta, porém desposicionada (está posicionada no primeiro registro da tabela)
									     //Monto um seek apenas para posicionar no produto que será carregado para 0200, assim o 0200 ficará em acordo com o E113
									    SPEDSeek("SB1",,xFilial("SB1")+AllTRIM(Substr(aLanCDA2[nX][13],1,cTamProd)))
						
										SFRG0200( cAlias, @aReg0200, @aReg0190, dDataDe, dDataAte, , , @aReg0220,,,,,,,,,,,,,,,,,,,aWizard )
									EndIf								
								EndIf													
							EndIf	
						EndIf
                    EndIf
				Next(nX)
			EndIf        
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³REGISTRO E116 - OPERACOES DO ICMS A RECOLHER - OPERACOES PROPRIAS     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        	If lAchouSF6 .And. !Empty((cAliasCDH)->CDH_CODLAN)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Condicao para tratar GNRE(Outros Debito) lancada manualmente na apuracao para gravar registro E116³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        		If (cAliasCDH)->(Len(Alltrim(CDH_CODLAN))==8 .And. SubStr(CDH_CODLAN,4,1)=="0")
        			lGeraE116	:=	.T.

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Condicao para tratar GNRE(Debito) lancada atraves do NF na apuracao para gravar registro E116 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        		ElseIf (cAliasCDH)->(Len(Alltrim(CDH_CODLAN))==10 .And. SubStr(CDH_CODLAN,3,1)=="4")
        			lGeraE116	:=	.T.
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Condicao para tratar GNRE(Debitos especiais) gerada pela apuracao atraves de um lancamento    ³
				//| manual ou por NF, para gravar registro E116                                                  |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				ElseIf	(cAliasCDH)->(Len(Alltrim(CDH_CODLAN))==08 .And.  SubStr(CDH_CODLAN,4,1)=="5") .Or.;		//Manual
						(cAliasCDH)->(Len(Alltrim(CDH_CODLAN))==10 .And.  SubStr(CDH_CODLAN,3,1)=="7")			//Por NF
        			lGeraE116	:=	.T.
        			
    			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Condicao para tratar GNRE(ICMS a recolher) gerada pela apuracao para gravar registro E116     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			ElseIf lAchouSF6 .And. (cAliasCDH)->(CDH_LINHA=="GNR" .And. Alltrim(CDH_GNREF3)$"/RECSALDO/RDBESP/RDBESPST/RICDIF/RFECP/RICDIFRJ")
        		lGeraE116	:=	.T.
    		EndIf
    		
    		//  Verifico se a UF de Recolhimento do ICMS Proprio deve apresentar o campo 05 - COD_REC
			//  considerando o Codigo da Receita + Classe de Vencimento ( F6_CODREC + F6_CLAVENC )
			cCodRec	:=	Iif( cMvEstado $ cMvSFUfGnr , "SF6->( Alltrim( F6_CODREC ) + Alltrim( F6_CLAVENC ) )" , "SF6->F6_CODREC" )
        		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se algumas das condicoes acima mandar gerar a GNRE, faco isso neste momento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   			If lGeraE116
				aAdd(aRegE116, {})
				nPos	:=	Len (aRegE116)
				aAdd(aRegE116[nPos], "E116")							//01 - REG
				aAdd(aRegE116[nPos], Iif(!SF6->F6_COBREC$"",SF6->F6_COBREC,"000"))	//02 - COD_OR
				aAdd(aRegE116[nPos], SF6->F6_VALOR)					//03 - VL_OR
				aAdd(aRegE116[nPos], SF6->F6_DTVENC)					//04 - DT_VCTO
				aAdd(aRegE116[nPos], &( cCodRec ))						//05 - COD_REC
				aAdd(aRegE116[nPos], "")									//06 - NUM_PROC
				aAdd(aRegE116[nPos], "")									//07 - IND_PROC
				aAdd(aRegE116[nPos], "")									//08 - PROC
				aAdd(aRegE116[nPos], SF6->F6_OBSERV)					//09 - TXT_COMPL 
				
				If cVerSPDFis >= "004"
					aAdd(aRegE116[nPos],SF6->(StrZero(F6_MESREF,2)+cValToChar(F6_ANOREF)))//10 - MES_REF
				EndIf
				
				//Para o extrator fiscal preciso levar o número e o Tipo (0=Doc. Arrecad. 1= GNRE) da GNRE para amarrar no TAF
				if lExtratTAF
					aAdd(aRegE116[nPos], SF6->F6_NUMERO)					//11-Numero da Guia
					aAdd(aRegE116[nPos], IIF(Empty(SF6->F6_NUMERO),"",IIF(SF6->F6_TIPOIMP=="0","0","1")))	
				endif
			EndIf
		
			(cAliasCDH)->(dbSkip())		
		EndDo	//Fim do processamento da Apuracao de ICMS
		
		If !lExtratTAF
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³GRAVACAO DO REGISTRO E100 - PERIODO DA APURACAO DO ICMS                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RegE100(cAlias,dDataDe,dDataAte)	
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³GRAVACAO DO REGISTRO E110 - APURACAO DE ICMS - OPERACOES PROPRIAS                       ³			
			//|GRAVACAO DO REGISTRO E111 - AJUSTES/BENEFICIOS/INCENTIVO DA APURACAO DE ICMS            |
			//³GRAVACAO DO REGISTRO E112 - INFORMACOES ADICIONAIS DOS AJUSTES DE APURACAO DO ICMS      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SPEDRegs(cAlias,{{aRegE110},aRegE111,aRegE112,{aRegE113,2}})
		endif
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³GRAVACAO DO REGISTRO E115- INF. ADICIONAIS DA APURACAO DO ICMS                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cUf<>"PE"
			aRegE115 := RegE115(cAlias,dDataDe,dDataAte,lExtratTAF)
        EndIf     
       
       If !lExtratTAF
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³GRAVACAO DO REGISTRO E116 - OBRIGACOES DO ICMS A RECOLHER - OPERACOES PROPRIAS          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			GrvRegTrS(cAlias,,aRegE116)
		EndIf			

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³REGISTRO E210 - APURACAO DO ICMS - SUBSTITUICAO TRIBUTARIA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cImp == "ST"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao responsabe pela geracao das informacoes do registro E200 e E210³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lExtratTAF		
			PrcE200E21(@aRegE200,@aRegE210,cMVSUBTRIB,cAlias,aVlrMovST,dDataDe,dDataAte,cMVSTNIEUF,cMVEstado)
		Else		
			PrcE200E21(@aRegE200,@aRegE210,cMVSUBTRIB,,aVlrMovST,dDataDe,dDataAte,cMVSTNIEUF,cMVEstado,lExtratTAF)
		EndIf	

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega ajustes na apuracao ICMS/ST ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While !(cAliasCDH)->(Eof())

			nRecnoSF6	:=	Iif(lTop,(cAliasCDH)->SF6RECNO,Nil)
			lAchouSF6	:=	.F.
			nUf 		:= 	0
			cUF 		:= 	Left((cAliasCDH)->CDH_CODLAN,2)
			cCodAjApur 	:= 	(cAliasCDH)->CDH_CODLAN
			nPosAj		:=	0
			cCodE240	:=	""

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posicionamento da tabela SF6, tanto para TOP (RECNO) quanto para DBF/ADS    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty((cAliasCDH)->(CDH_ESTGNR+CDH_GNRE))
				lAchouSF6	:=	SPEDSeek("SF6",1,xFilial("SF6")+(cAliasCDH)->(CDH_ESTGNR+CDH_GNRE),nRecnoSF6)
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Processamento de subitens que tenha codigo de lancamento conforme manual SPED Fiscal³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If !Empty((cAliasCDH)->CDH_CODLAN) .And. (nUf := aScan(aRegE200,{|x|x[2]==cUf}))>0

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Tratamento para verificar se o lancamento em processamento se refere a³
				//³  lancamento de NF ou manual na apuracao                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lOldLan
					lAjusteNF  := SubStr((cAliasCDH)->CDH_CODLAN,1,1)=="1"
				Else
					If Len(Alltrim((cAliasCDH)->CDH_CODLAN))==8
						lAjusteNF  := .F.

					ElseIf Len(Alltrim((cAliasCDH)->CDH_CODLAN))==10 
						lAjusteNF := .T.
                      
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se existir codigo de ajuste da CDH associado com  ³
						//³a tabela CC6, este valor deve ser utilizado para a³
						//³montagem do registro E240                         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						
						If CC6->(MsSeek(xFilial("CC6")+(cAliasCDH)->CDH_CODLAN)) .And. !Empty(CC6->CC6_CLANAP)
							cCodE240	:=	CC6->CC6_CLANAP
						EndIf
					EndIf
				EndIf
			
		   		Do Case

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Processamento dos subitens de "OUTROS DEBITOS", para gerar os campos:         ³
					//³(9)VL_OUT_DEB_ST = Valor total de ajustes "OUTROS DEBITOS ST ou               ³
					//³                                         ESTORNO DE CREDITOS ST"              ³
					//³(10)VL_AJ_DEBITOS_ST =  Valor total dos ajustes a debitos de ST, provenientes ³
					//³                                         de NF                                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Case (cAliasCDH)->(CDH_LINHA$"002" .And. Alltrim(CDH_SUBITE)<>"002.00") .Or.;
						(cAliasCDH)->(CDH_LINHA$"003" .And. Alltrim(CDH_SUBITE)<>"003.00")
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Definicao de qual coluna o valor estara composto³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nPosAj := Iif(lAjusteNF,11,10)
	
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Para o codigo no formato antigo, devo remontar para o novo formato para nao³
						//³  apresentar erro de validacao                                             ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !lAjusteNF .And. lOldLan
							If (cAliasCDH)->CDH_LINHA$"002"
								cCodAjApur := cMvEstado+"1"+"0"+"9999"
							Else
								cCodAjApur := cMvEstado+"1"+"1"+"9999"
							EndIf
						EndIf
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Processamento dos subitens de "OUTROS CREDITOS", para gerar os campos:        ³
					//³(6)VL_OUT_CRED_ST = Valor total de ajustes "OUTROS CREDITOS ST ou             ³
					//³                                         ESTORNO DE DEBITOS ST"               ³
					//³(7)VL_AJ_CREDITOS_ST =  Valor total dos ajustes a creditos de ST, provenientes³
					//³                                         de NF                                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Case (cAliasCDH)->(CDH_LINHA$"007" .And. Alltrim(CDH_SUBITE)<>"007.00") .Or.;
						(cAliasCDH)->(CDH_LINHA$"008" .And. Alltrim(CDH_SUBITE)<>"008.00")
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Definicao de qual coluna o valor estara composto³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nPosAj 	:= 	Iif(lAjusteNF,8,7)
	
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Para o codigo no formato antigo, devo remontar para o novo formato para nao³
						//³  apresentar erro de validacao                                             ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !lAjusteNF .And. lOldLan
							If (cAliasCDH)->CDH_LINHA$"007"
								cCodAjApur := cMvEstado+"1"+"2"+"9999"
							Else
								cCodAjApur := cMvEstado+"1"+"3"+"9999"
							EndIf
						EndIf
						
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Processamento dos subitens de "ESTORNO DE DEBITOS", para gerar os campos:     ³
					//³(6)VL_OUT_CRED_ST = Valor total de ajustes "OUTROS CREDITOS ST ou             ³
					//³                                         ESTORNO DE DEBITOS ST"               ³
					//³(7)VL_AJ_CREDITOS_ST =  Valor total dos ajustes a creditos de ST, provenientes³
					//³                                         de NF                                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Case (cAliasCDH)->(CDH_LINHA$"008" .And. Alltrim(CDH_SUBITE)<>"008.00")
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Definicao de qual coluna o valor estara composto³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nPosAj 	:= 	Iif(lAjusteNF,8,7)
	
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Para o codigo no formato antigo, devo remontar para o novo formato para nao³
						//³  apresentar erro de validacao                                             ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !lAjusteNF .And. lOldLan
							cCodAjApur := cMvEstado+"1"+"3"+"9999"
						EndIf
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Processamento dos subitens de "DEDUCOES", para gerar o campo:                 ³
					//³(12)VL_DEDUCOES_ST = Valor total dos ajustes "DEDUCOES ST"                    ³
					//³                                         ESTORNO DE DEBITOS ST"               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Case (cAliasCDH)->(CDH_LINHA$"014" .And. Alltrim(CDH_SUBITE)<>"014.00")
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Definicao de qual coluna o valor estara composto³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nPosAj := 13
	
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Para o codigo no formato antigo, devo remontar para o novo formato para nao³
						//³  apresentar erro de validacao                                             ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !lAjusteNF .And. lOldLan
							cCodAjApur := cMvEstado+"1"+"4"+"9999"
						EndIf
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Processamento dos subitens de "DEBITOS ESPECIAIS", para gerar o campo:        ³
					//³(15)DEB_ESP_ST = Valores recolhidos ou a recolher extra-apuracao              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Case (cAliasCDH)->(CDH_LINHA$"901" .And. Alltrim(CDH_SUBITE)<>"901.00")
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Definicao de qual coluna o valor estara composto³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nPosAj := 16
	
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Para o codigo no formato antigo, devo remontar para o novo formato para nao³
						//³  apresentar erro de validacao                                             ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !lAjusteNF .And. lOldLan
							cCodAjApur := cMvEstado+"1"+"5"+"9999"
						EndIf
						
				EndCase
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Gero quando achar um registro correspondente e quando o valor for maior que ZERO³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nUf>0 .And. nPosAj>0 .And. (cAliasCDH)->CDH_VALOR>0
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//|REGISTRO E210 - APURACAO DO ICMS - SUBSTITUICAO TRIBUTARIA    |
					//|                                                              |
					//³Atualizo o valor do lancamento selecionado nas condicoes acima³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aRegE210[nUf][nPosAj] 	+= 	(cAliasCDH)->CDH_VALOR
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//|REGISTRO E220 - AJUSTES/BENEFICIOS/INCENTIVOS DA APURACAO DO ICMS SUBSTITUICAO TRIBUTARIA |
					//|                                                                                          |
					//³Para lancamentos manuais, devo gerar o registro E220                                      |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (!lAjusteNF) .Or. (!Empty(cCodE240) .And. lCmpsE240) 
						aAdd(aRegE220, {})	
						nPosE220	:=	Len (aRegE220)
						aAdd (aRegE220[nPosE220], nUF)							   			//Relacionamento com o registro E210
						aAdd (aRegE220[nPosE220], "E220")						   			//01 - REG
						aAdd (aRegE220[nPosE220], Iif(!Empty(cCodE240),cCodE240,cCodAjApur))	//02 - COD_AJ_APUR
						aAdd (aRegE220[nPosE220], (cAliasCDH)->CDH_DESC)					//03 - DESCR_COMPL_AJ
						aAdd (aRegE220[nPosE220], (cAliasCDH)->CDH_VALOR)					//04 - VL_AJ_APUR
						If lExtratTAF
							aAdd (aRegE220[nPosE220], (cAliasCDH)->CDH_SUBITE)					//05 - VL_AJ_APUR
						Endif
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³REGISTRO E230 - INFORMACOES ADICIONAIS DOS AJUSTES DE APURACAO DO ICMS SUBSTITUICAO TRIBUTARIA³
					//|                                                                                              |
					//|Segundo o manuel, eh necessario haver um DA (Documento de arrecadacao                         |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nPosE220>0 .And. lAchouSF6
						aAdd(aRegE230, {})
						nPos	:=	Len (aRegE230)
						aAdd (aRegE230[nPos], nPosE220)	 						   			//RELACIONAMENTO COM O E220
						aAdd (aRegE230[nPos], "E230")										//01 - REG
						aAdd (aRegE230[nPos], SF6->F6_NUMERO)								//02 - NUM_DA
						aAdd (aRegE230[nPos], SF6->F6_NUMPROC)								//03 - NUM_PROC
						aAdd (aRegE230[nPos], SF6->F6_INDPROC)								//04 - IND_PROC
						aAdd (aRegE230[nPos], (cAliasCDH)->CDH_DESC)						//05 - PROC
						aAdd (aRegE230[nPos], SF6->F6_DESCOMP)								//06 - TXT_COMPL
						If lExtratTAF
							aAdd (aRegE230[nPos], IIF(Empty(SF6->F6_NUMERO),"",IIF(SF6->F6_TIPOIMP=="0","0","1")))		//07 - COD_DA
						Endif
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³REGISTRO E240 - INFORMACOES ADICIONAIS DOS AJUSTES DE APURACAO DO ICMS SUBSTITUICAO TRIBUTARIA³
					//|                                                                                              |
					//|Este registro deve ser apresentado para identificação dos documentos fiscais relacionados 	 |
					//|ao ajuste                         															 |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If cUf<>"PE"
						If lCmpsE240 .And. nPosE220>0 .And. Len(aLanCDA2)>0
							For nX := 1 To Len(aLanCDA2)
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Vai percorrer todo o Array aLanCDA2 (Totalizador CDA) em busca dos registro referentes ao Codigo de Ajuste do E111³
								//³e Filtrando por ICMS Solidario, terceiro digito do Codigo de Ajuste = 0 e assim Gerar um E113 por documento.		 ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If AllTrim(aLanCDA2[nX][1]) == AllTrim(cCodAjApur) .And. SubStr(AllTrim(aLanCDA2[nX][1]),3,1) == "1"
									If (cAliasCDH)->CDH_TPLANC <> "M"
										aAdd(aRegE240, {})
										nPos :=	Len(aRegE240)
										aAdd (aRegE240[nPos], nPosE220)								//RELACIONAMENTO COM O E111
										aAdd (aRegE240[nPos], "E240")								//01 - REG
										aAdd (aRegE240[nPos], aLanCDA2[nX][15])					//02 - COD_PART
										aAdd (aRegE240[nPos], AModNot(aLanCDA2[nX][8]))			//03 - COD_MOD
										aAdd (aRegE240[nPos], aLanCDA2[nX][9])						//04 - SER
										aAdd (aRegE240[nPos], "")									//05 - SUB
										aAdd (aRegE240[nPos], aLanCDA2[nX][10])					//06 - NUM_DOC 
										aAdd (aRegE240[nPos], StrZero(Day(aLanCDA2[nX][16]),2)+StrZero(Month(aLanCDA2[nX][16]),2)+StrZero(Year(aLanCDA2[nX][16]),4))	//07 - DT_DOC
										aAdd (aRegE240[nPos], aLanCDA2[nX][13])					//08 - COD_ITEM
										aAdd (aRegE240[nPos], aLanCDA2[nX][5])						//09 - VL_AJ_ITEM
										IF cVersao >= "011"
											aAdd (aRegE240[nPos], aLanCDA2[nX][17])					//10 - CHV_DOCe
										Endif
										IF aScan( aReg0200, { |aX| aX[2] == aLanCDA2[nX][13] }) == 0									     
											SPEDSeek("SB1",,xFilial("SB1")+AllTRIM(Substr(aLanCDA2[nX][13],1,cTamProd)))
											SFRG0200( cAlias, @aReg0200, @aReg0190, dDataDe, dDataAte, , , @aReg0220,,,,,,,,,,,,,,,,,,,aWizard )
										EndIf
									EndIf
								EndIf
							Next(nX)
						EndIf 
					EndIf
				EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³REGISTRO E250 - OBRIGACOES DO ICMS A RECOLHER - SUBSTITUICAO TRIBUTARIA                       ³
            //|                                                                                              |
			//³Gero registro E250 para todas as GNREs geradas pela Apuracao de ICMS/ST                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf (cAliasCDH)->CDH_LINHA=="GNR" .And. lAchouSF6 .And. (nUf := aScan(aRegE200,{|x|x[2]==SF6->F6_EST}))>0

				//  Verifico se a UF de Recolhimento do ICMS Proprio deve apresentar o campo 05 - COD_REC
				//  considerando o Codigo da Receita + Classe de Vencimento ( F6_CODREC + F6_CLAVENC )
				cCodRec	:=	Iif( cMvEstado $ cMvSFUfGnr , "SF6->( Alltrim( F6_CODREC ) + Alltrim( F6_CLAVENC ) )" , "SF6->F6_CODREC" )
								
				aAdd(aRegE250, {})
				nPos	:=	Len (aRegE250)
				aAdd(aRegE250[nPos], nUF)									//Relacionamento com o PAI - E210
				aAdd(aRegE250[nPos], "E250")								//01 - REG

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Definindo o codigo da obrigacao a recolher³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SF6->F6_OPERNF == "1"
					aAdd (aRegE250[nPos], "001")							//02 - COD_OR - Entradas
					
				ElseIf SF6->F6_EST==cMvEstado
					aAdd (aRegE250[nPos], "002")							//02 - COD_OR - Saidas p/ Estado
					
				Else	
					aAdd (aRegE250[nPos], "999")							//02 - COD_OR - Saidas fora Estado
					
				EndIf
			
				aAdd(aRegE250[nPos], SF6->F6_VALOR)							//03 - VL_OR
				aAdd(aRegE250[nPos], SF6->F6_DTVENC)						//04 - DT_VCTO
				aAdd(aRegE250[nPos], &( cCodRec ))							//05 - COD_REC				
				aAdd(aRegE250[nPos], SF6->F6_NUMPROC)						//06 - NUM_PROC
				aAdd(aRegE250[nPos], SF6->F6_INDPROC)						//07 - IND_PROC
				aAdd(aRegE250[nPos], SF6->F6_DESCOMP)						//08 - PROC
				aAdd(aRegE250[nPos], SF6->F6_OBSERV)						//09 - TXT_COMPL    
			
				If cVerSPDFis >= "004" //A partir de janeiro de 2011 incluir o campo 10 mmaaaa
					aAdd(aRegE250[nPos], SF6->(StrZero(F6_MESREF,2)+cValToChar(F6_ANOREF)))//10 - MES_REF
				EndIf

				//Para o extrator fiscal preciso levar o número da GNRE para amarrar no TAF
				if lExtratTAF
					aAdd(aRegE250[nPos], SF6->F6_NUMERO)					//11-Numero da Guia
					aAdd(aRegE250[nPos], IIF(Empty(SF6->F6_NUMERO),"",iIF(SF6->F6_TIPOIMP=="0","0","1")) )//12 - COD_DA	
				endif
				
			EndIf

			(cAliasCDH)->(dbSkip())			
	    EndDo
         
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Apos o fim do processamento das informacoes da apuracao, eh necessario³
		//³ complementa-los com algumas que faltaram                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	  
		SpedApE200(aRegE200,@aRegE210,@aRegE250,aVlrMovST,nApuracao,nPeriodo,cNrLivro,cArqAnt,cMVEstado,aIcmPago,cMVSUBTRIB,lExtratTAF)

		If !lExtratTAF
			SPEDRegs(cAlias,{aRegE200,aRegE210,aRegE220,aRegE230,{aRegE240,3},{aRegE250,2}})
		EndIF    

	EndIf          
	
	//Alimento os Arrays de Retorno do Extrator TAF
	If lExtratTAF
		If cImp=="IC"
			aRegT020   := aRegE110 
			aRegT020AA := aRegE111 
			aRegT020AB := aRegE112 
			aRegT020AC := aRegE113 
			aRegT020AD := aRegE115 
			aRegT020AE := aRegE116 
			
		Elseif cImp=="ST"
			aRegT021Est := aRegE200
			aRegT021Val := aRegE210     
			aRegT021AA  := aRegE220   
			aRegT021AB  := aRegE230
			aRegT021AC  := aRegE240	
			aRegT021AD  := aRegE250			
		endif
	EndIf		
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Fecho query ou indregua criada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SPEDFFiltro(2,,cAliasCDH)
Else
	lRet := .F.
EndIf

Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³PrcE200E21| Autor ³Gustavo G. Rueda 			   ³ Data ³04.05.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³                        GERACAO DO BLOCO E                         ³±± 
±±³          ³REGISTRO E200 - PERIODO DA APURACAO DO ICMS ST                     ³±± 
±±³          ³REGISTRO E210 - APURACAO DO ICMS - SUBSTITUICAO TRIBUTARIA         ³±±  
±±³          ³                                                                   ³±±
±±³          ³Funcao utilizada para montar a estrutura dos registros acima       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 -> Identifica se houve movimento no periodo ou nao           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aRegE200 -> Array com as informacoes do registro E200              ³±±
±±³          ³aRegE210 -> Array com as informacoes do registro E210              ³±±
±±³          ³cMVSUBTRIB -> Conteudo do parametro MV_SUBTRIB                     ³±±
±±³          ³cAlias   -> Alias do TRB                                           ³±±
±±³          ³aVlrMovST- Valores de apuracao obtidos durante o processamento dos ³±±
±±³          ³           documentos                                              ³±±
±±³			 |dDataDe -> Data inicial do periodo base do arquivo.                ³±±
±±³			 |dDataAte -> Data final do periodo base do arquivo.                 ³±±
±±³			 |cMVSTNIEUF - Conteudo do parametro MV_STNIEUF, auxilia do MV_SUBTRIB³±±
±±³			 |cMVEstado -> Conteudo do parametro MV_ESTADO                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PrcE200E21(aRegE200,aRegE210,cMVSUBTRIB,cAlias,aVlrMovST,dDataDe,dDataAte,cMVSTNIEUF,cMVEstado,lExtratTAF )
Local	aReg0015	:=	{}
Local	nX			:=	0
Local	cUf			:=	""
Local	nUf			:=	0  

Default lExtratTAF := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³0015 - DADOS DO CONTRIBUINTE SUBSTITUTO                              ³
//³                                                                     ³
//³Verifico todas as UFs onde ha inscricao, porem nao houve movimentacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
aReg0015	:=	Reg0015(cMVSUBTRIB,cAlias,lExtratTAF)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montando os registros E200 e E210 conforme parametro MV_SUBTRIB   ³
//³Este parametro determina os estados que pago o ICMS/ST, portanto  ³
//| sao os estados que posso vender com ICMS/ST retido               |
//|                                                                  |
//|O registro E200 soh posso ter 1 por UF + PERIODO                  |
//|O registro E210 soh posso ter 1 para cada E200                    |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aReg0015)
	cUF	:=	aReg0015[nX,2]			
	If aScan(aRegE200,{|x|x[2]==cUf})==0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Crio uma entrada no array E200  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd(aRegE200,{"E200",cUf,dDataDe,dDataAte})				

		//Crio um relacionamento com o filho, E210
		nUf := Len(aRegE200)			
		aAdd(aRegE210,{nUf,"E210","0",0,0,0,0,0,0,0,0,0,0,0,0,0})			
	EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montando os registros E200 e E210 conforme movimento de documentos³
//|                                                                  |
//|O registro E200 soh posso ter 1 por UF + PERIODO                  |
//|O registro E210 soh posso ter 1 para cada E200                    |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aVlrMovST)
	cUF	:=	aVlrMovST[nX,1]			
	If aScan(aRegE200,{|x|x[2]==cUf})==0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Crio uma entrada no array E200  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd(aRegE200,{"E200",cUf,dDataDe,dDataAte})				

		//Crio um relacionamento com o filho, E210
		nUf := Len(aRegE200)			
		aAdd(aRegE210,{nUf,"E210","0",0,0,0,0,0,0,0,0,0,0,0,0,0})			
	EndIf		
Next nX
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|Parametro MV_STNIEUF                                                                  |
//³Tratamento para acordo entre os estados preenchidos no parametro MV_STNIEUF, quando em³
//³ um movimento com ICMS-ST nao e' necessario ter incscricao estadual.                  ³ 
//³Este tratamento foi feito a partir da necessidade das UF de MG p/ PR,onde existe esse ³ 
//³ acordo PROTOCOLO ICMS CONSELHO NACIONAL DE POLÍTICA FAZENDÁRIA - CONFAZ Nº 191 DE    ³ 
//| 11.12.2009                                                                           |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(cMVSTNIEUF)>=4
	For nX := 1 To Len(cMVSTNIEUF) Step 5
		cUF	:=	SubStr(cMVSTNIEUF,nX,2)
		If cUF==cMVEstado
			cUF	:=	SubStr(cMVSTNIEUF,nX+2,2)
			If aScan(aRegE200,{|x|x[2]==cUf})==0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Crio uma entrada no array E200  |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd(aRegE200,{"E200",cUf,dDataDe,dDataAte})				
		
				//Crio um relacionamento com o filho, E210
				nUf := Len(aRegE200)			
				aAdd(aRegE210,{nUf,"E210","0",0,0,0,0,0,0,0,0,0,0,0,0,0})			
			EndIf
		EndIf
	Next
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RegEcf    ³ Autor ³ Vendas e CRM          ³ Data ³ 29/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a carga dos arrays dos registros de ECF             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RegEcf (aRegC400, aRegC405, aRegC410, 	aRegC420,;
						aRegC425, aRegC460, aRegC470, 	aRegC490,;
						aRegC495, aProdB1, 	dDataDe, 	dDataAte,;
						cPerfil,  cAlias, 	aReg0200, 	aReg0190,;
						lCstPis,  lCstCof,	aReg0220,   aReg1600,;
						aReg0150, aWizard,	lTop, 		cUf		,;
						lLegisPer, cNrlivro  )

Local   aAreaSFT    :=  SFT->(GetArea())
Local 	lRet   		:= 	.T.
Local 	nPos400		:= 	0
Local 	nPos405		:= 	0
Local 	aPos420		:= 	{}
Local 	aTotaliz	:= 	{}
Local 	nX			:= 	0
Local 	lGer490		:= 	.F.
Local   lGer410		:= .F.

//Novos
Local 	aParametros	:=	{}
Local	cAliasSFI	:=	"SFI"
Local	nRecSFI		:=	0
Local 	nValCof 	:= 0
Local	nValPis 	:= 0
Local 	nQuantD   	:= Min(TAMSX3("FT_QUANT")[2],3)
Local  	aSLX 		:= {}
Local  cEspecie 	:= PadR("CF",TamSX3("FT_ESPECIE")[1])

SLG->(MsSeek (cFilAnt,.T.))
While SLG->(!Eof() .AND. cFilAnt==LG_FILIAL)

	aParametros	:=	{}
	aAdd(aParametros,DToS(dDataDe))
	aAdd(aParametros,DToS(dDataAte))
	aAdd(aParametros,SLG->LG_PDV)
	aAdd(aParametros,SLG->LG_SERPDV)
	If SPEDFFiltro(1,"SFI",@cAliasSFI,aParametros,,1)

		While !(cAliasSFI)->(Eof())

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tratamento para armazenar o recno da tabela SFI para um processamento seguinte, e³
			//³  no caso de TOP, posiciono o SFI de acordo com o RECNO do SELECT                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lTop
				nRecSFI := (cAliasSFI)->SFIRECNO
				SPEDSeek("SFI",,,nRecSFI)
			EndIf
			nRecSFI := SFI->(Recno())
			
			DbSelectArea("SFT")
			SFT->(DbSetOrder(7))
			If SFT->(DbSeek( xFilial("SFT")+"S"+SFI->FI_PDV+cEspecie+DToS(SFI->FI_DTMOVTO)))//FT_FILIAL, FT_TIPOMOV, FT_PDV, FT_ESPECIE, FT_ENTRADA, R_E_C_N_O_, D_E_L_E_T_
				
				If SFT->FT_NRLIVRO == cNrlivro .OR. Alltrim(cNrlivro) == "*"
				
					RegC400 (@aRegC400, SLG->LG_IMPFISC, SLG->LG_SERPDV, AllTrim(SLG->LG_PDV),;
							@nPos400) 
	
					RegC405 (@aRegC405		, nPos400, 			SFI->FI_DTMOVTO, 	SFI->FI_CRO, ;
							 SFI->FI_NUMREDZ, SFI->FI_NUMFIM, 	SFI->FI_GTFINAL, 	(SFI->FI_VALCON+SFI->FI_ISS),;
							 @nPos405		, SFI->FI_DESC, 	SFI->FI_CANCEL) 
	
					If lLegisPer
						lGer410 := .F.
					Else
						lGer410 := .T.
					EndIf
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Carrego todos os codigos e valores que foram contabilizados no SFI³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aTotaliz := TotalizSFI(nRecSFI, .T.)
					lGer490	 := .F.
	
					RegC420 (@aRegC420, 	nPos405,   	SFI->FI_CRO, 		SFI->FI_NUMREDZ,;
							 aTotaliz,		@aPos420) 
	
					If cUf <> "BA" .OR. (cUf == 'BA' .AND. cVersao >= '008')  
						If cPerfil == "B"
							If !RegC425 (@aRegC425	, @aProdB1	, SFI->FI_DTMOVTO, SFI->FI_PDV	,;
										 aPos420	, cAlias	, @aReg0200		 , @aReg0190  	,;
										 @aReg0220	, @lGer490	, lCstPis		 , lCstCof		,;
										 @aRegC490	, nPos405	, dDataDe		 , dDataAte		,;
										 aWizard 	, nQuantD	, lTop  )
	
								//Se nao for encontrado registro 425 para o 420, remove a ultima linha 
								//dos registros 405, 410 e 420
								If Len(aRegC405) > 0 
									aDel(aRegC405, nPos405)
									aSize(aRegC405, nPos405 -1)
								EndIf
	
								// No caso do C420 possui varias linhas para serem excluidas
								nX := 1
								While( Len(aRegC420) >= nX )
									If aRegC420[nX][1] == nPos405
										aDel(aRegC420, nX)
										aSize(aRegC420, Len(aRegC420)-1)
									Else
										nX++
									EndIf		
								End
								lGer410 := .F.
							EndIf
						ElseIF !cPerfil$"B/C"									
							RegC460470 (@aRegC460, @aRegC470	, SFI->FI_DTMOVTO, SFI->FI_PDV	,;
									@aProdB1 , SFI->FI_COO	, nPos405		 , cAlias		,;
									@aReg0200, @aReg0190	, lCstPis		 , lCstCof		,;
									@aReg0220, @lGer490		, @aRegC490		 , dDataDe		,;
									dDataAte , aWizard 		, nQuantD 		 , lTop )
						EndIf
					EndIf
	
					nValCof := 0
					nValPis := 0
	
					RegC490 (@aRegC490	, SFI->FI_DTMOVTO	, nPos405  	, lCstPis	,;
							 lCstCof  	, SFI->FI_PDV		, @aProdB1	, nPos405	,;
							 @aReg0200	, cAlias			,@AREG0190 	, @AREG0220 ,;
							 @nValCof	, @nValPis 	)
	
					//Perfil C nao deve gerar C410
					If lGer410 .And. cPerfil<>"C" .And. "1"$aWizard[1][15]// Depois de ter os valores de PIS e COFINS gera o C410
						RegC410 (  @aRegC410	   , nPos405 	 , nValCof 	, nValPis  ,;
								   SFI->FI_DTMOVTO , SFI->FI_PDV , lTop ) 					 
					EndIf				                                                         
				EndIf
			EndIf				 
			(cAliasSFI)->(dbSkip())		
		End

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Encerro o alias criado anteriormente³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SPEDFFiltro(2,,cAliasSFI)
	EndIf	
	
	If cUf == "BA"  .And. cPerfil <> "C" .AND. cVersao < '008'
		If nPos400 > 0 //So gera o Registro C495, caso tenha gerado tambem o Registro C400
			RegC495 (@aRegC495	, @aProdB1				, nPos400	, dDataDe	,;
					 dDataAte	, AllTrim(SLG->LG_PDV)	, @aReg0200	, cAlias 	,;
					 @aReg0190 	, @aReg0220 			, @aSLX 	, xFilial("SB1"), aWizard )
		EndIf
	EndIf
			
	SLG->(dbSkip()) 		
End 

//Verifica se deve gerar registro 1600
If "1"$aWizard[4][7]
	GerDad1600(@aReg1600,@aReg0150,dDataDe,dDataAte,cAlias,aWizard)
EndIf

RestArea(aAreaSFT)

Return(lRet)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LjNaoTrib ³ Autor ³ Vendas e CRM				   ³ Data ³ 09/09/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tratamento especial quando for o tipo de tributacao for "N" ou "O"³±±
±±³          ³ Nao tributado ou Outros.											 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjNaoTrib( aLinhaPai , dDtMovim , cPdv 		, aProdB1  ,;
							cAlias	 , aReg0200	, aReg0190	, aReg0220 ,;
							aRegC425 , dDataDe	, dDataAte  , aWizard)

Local cSituaTrib := "" 					 // Situacao Tributaria
Local nTamFTItem := TamSx3("FT_ITEM")[1] // Tamamanho do FT_ITEM
Local nPosAux	 := 0					 // Posicao Auxiliar
Local nPos		 := 0					 // Posicao do array
Local lRet		 := .F.					 // Retorno Logico
Local cProd		 := ""
Local aProd		 := {}

DEFAULT dDatade  := dDtMovim
DEFAULT dDataAte := dDtMovim
DEFAULT aWizard  := {}

DbSelectArea("SF2")
DbSetOrder(3)   //F2_FILIAL+F2_ECF+DTOS(F2_EMISSAO)+F2_PDV+F2_SERIE+F2_MAPA+F2_DOC
If MsSeek(xFilial("SF2")+"S"+DtoS(dDtMovim)+cPdv)     
	
	While !SF2->(Eof()) .AND. xFilial("SF2") == SF2->F2_FILIAL .AND.;
			dDtMovim = SF2->F2_EMISSAO .AND. cPdv == SF2->F2_PDV
	
		DbSelectArea("SD2")			         
		DbSetOrder(3)		// D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		If MsSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)  
			   
			While !SD2->(Eof()) .AND.(xFilial("SD2") == SD2->D2_FILIAL) .AND.;
				   (SD2->D2_FILIAL+ SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA) ==;
				   (SF2->F2_FILIAL+ SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
				
				cSituaTrib := LjSitTrib("SD2",.T.)	  // Retorna a Situacao Tributaria 
				If cSituaTrib == "N"	// Nao Tributado					
					cProd	:= SD2->D2_COD+Iif(lConcFil,xFilial("SB1"),"")
					cProd	:= SD2->D2_COD+xFilial("SB1")
					If aExistBloc[05]
						aProd := Execblock("SPEDPROD", .F., .F., {"SD2","C425"})
						If Len(aProd)>=11
							cProd 	:= 	aProd[1]
						Else
							aProd := {"","","","","","","","","","","",""}
						EndIf
					EndIf									
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Preenchimento do registro 425    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nPosAux := Ascan(aRegC425, {|x| x[3] == cProd .AND. x[1] == aLinhaPai[1]})
									
					If nPosAux ==  0			
						aAdd(aRegC425, {})        
						nPos :=	Len (aRegC425)
			
						aAdd (aRegC425[nPos], aLinhaPai[1]							)	 	   	//00 - POSICAO DO REG. PAI
						aAdd (aRegC425[nPos], "C425"		 						)	 	   	//01 - REG
						aAdd (aRegC425[nPos], cProd									)	 	   	//02 - COD_ITEM
						aAdd (aRegC425[nPos], SD2->D2_QUANT							)	 	   	//03 - QTD
						aAdd (aRegC425[nPos], RetUMProd(@aProdB1, SD2->D2_COD)[1]	)	 	   	//04 - UNID
						aAdd (aRegC425[nPos], SD2->D2_TOTAL							)			//05 - VL_ITEM  	
						aAdd (aRegC425[nPos], 0										)	 	   	//06 - VL_PIS
						aAdd (aRegC425[nPos], 0										)	 	   	//07 - VL_COFINS 
					Else 
						aRegC425[nPosAux][4] += SD2->D2_QUANT			   						//03 - QTD			
						aRegC425[nPosAux][6] += SD2->D2_TOTAL									//05 - VL_ITEM
					EndIf
					
					If aScan (aReg0200, {|aX| aX[2]==cProd}) == 0
						SFRG0200(cAlias, @aReg0200, @aReg0190, dDataDe, dDataAte,,cProd,@aReg0220,,,,,,,,,,,,,,,,,,,aWizard)
					EndIf
		
					lRet := .T.
					
				ElseIf cSituaTrib == "O"           // Outros
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Preenchimento do registro 425    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("SFT")
					DbSetOrder(1) //FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
					If MsSeek( xFilial("SFT") + "S"+ SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA+;
								Padr(SD2->D2_ITEM,nTamFTItem) + SD2->D2_COD )					
					
						cProd	:= SFT->FT_PRODUTO+Iif(lConcFil,xFilial("SB1"),"")
						If aExistBloc[05]
							aProd := Execblock("SPEDPROD", .F., .F., {"SFT","C425"})
							If Len(aProd)>=11
								cProd 	:= 	aProd[1]
							Else
								aProd := {"","","","","","","","","","","",""}
							EndIf
						EndIf					    
					
						nPosAux := Ascan(aRegC425, {|x| x[3] == cProd .AND. x[1] == aLinhaPai[1]})
										
						If nPosAux ==  0			
							aAdd(aRegC425, {})        
							nPos :=	Len (aRegC425)
				
							aAdd (aRegC425[nPos], aLinhaPai[1]							 )	 	   	//00 - POSICAO DO REG. PAI
							aAdd (aRegC425[nPos], "C425"		 						 )	 	   	//01 - REG
							aAdd (aRegC425[nPos], cProd									 )	 	   	//02 - COD_ITEM
							aAdd (aRegC425[nPos], SFT->FT_QUANT							 )	 	   	//03 - QTD
							aAdd (aRegC425[nPos], RetUMProd(@aProdB1, SFT->FT_PRODUTO)[1])	 	   	//04 - UNID
							aAdd (aRegC425[nPos], SFT->FT_OUTRICM						 )			//05 - VL_ITEM  	
							aAdd (aRegC425[nPos], Iif("1"$aWizard[1][15],SFT->FT_VALPIS,0))	 	   	//06 - VL_PIS
							aAdd (aRegC425[nPos], Iif("1"$aWizard[1][15],SFT->FT_VALCOF,0))	 	   	//07 - VL_COFINS 
						Else 
							aRegC425[nPosAux][4] += SFT->FT_QUANT			   						//03 - QTD			
							aRegC425[nPosAux][6] += SFT->FT_OUTRICM									//05 - VL_ITEM
							aRegC425[nPosAux][7] += Iif("1"$aWizard[1][15],SFT->FT_VALPIS,0)							 	   	//06 - VL_PIS
							aRegC425[nPosAux][8] += Iif("1"$aWizard[1][15],SFT->FT_VALCOF,0)							 	   	//07 - VL_COFINS 
						EndIf
						
						If aScan (aReg0200, {|aX| aX[2]==cProd}) == 0
							SFRG0200(cAlias, @aReg0200, @aReg0190, dDataDe, dDataAte,,cProd,@aReg0220,,,,,,,,,,,,,,,,,,,aWizard)
						EndIf      
						
						lRet := .T.
					EndIf	
				EndIf
				   
				SD2->(dbSkip())				
            End	
        EndIf
		SF2->(dbSkip())
	End
EndIf	
Return (lRet)	  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GerDad1600  ³ Autor ³ Vendas e CRM           ³ Data ³ 08/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera os Dados do Cadastro das Administradoras de Cartao para  ³±±
±±³          ³ gravacao do Registro 150 e o Registro 1600                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ PARAM01 - Array com os Dados das Vendas dos Cartoes           ³±±   
±±³          ³ PARAM02 - Array com o Cadastro de Clientes para a gravacao    ³±± 
±±³          ³ do Registro 150						                         ³±±  
±±³          ³ PARAM03 - Variavel data com a data inicial			         ³±±
±±³          ³ PARAM04 - Variavel data com a data final                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GerDad1600(aReg1600,aReg0150,dDataDe,dDataAte,cAlias,aWizard) 
Local aArea := GetArea()
Local cQuery    := ""
Local cAliasTrb := ""
Local cCodADM   := ""      				 // Cod da administradora
Local cDesADM   := ""       			 // Descricao da administradora
//Local nRat      := 0       				 // Variavel auxiliar     
Local nValCC    := 0        			 // Valor do CC
Local nValCD    := 0       				 // Valor do CD    
Local cCodReg   := ""      				 // Codigo cartao        
Local nCodSAE   := TamSx3("AE_COD")[1]  // Tamanho do codigo do SAE     
//Local aDadCart  := {}                    // Dados dos cartoes   
Local nI        := 0                     // tamanho do array para adicinar os itens
Local nCount    := 0                                          
Local nIniFor 	:= 1
Local cRede     := ""                    // Nome da Administradora da rede de Cartoes  
Local nPosRede  := 0                     // Posicao da Administradora da Rede     
Local aCampos   := {}                    // Array para criar os campo p/ tabela temporaria
Local cSL4      := ""                    // Campo para Verificar se houve troca do registro. 
//Local cArqTrab1 := ""                    // variavel auxiliar para criacao de tabela temporaria.
Local _aRetInf := FWGetSX5 ( "L9" )
Local _nY
#IFDEF TOP
   If TcSrvType() != "AS/400"
		cQuery   := "SELECT SL4.L4_FILIAL,SL4.L4_ADMINIS,SL4.L4_FORMA,SUM(L4_VALOR) VALOR "
		cQuery   += "FROM " + RetSQLTab('SL4') 
		cQuery   += "LEFT JOIN " + RetSQLTab('SL1') + " ON SL4.L4_NUM = SL1.L1_NUM AND "
		cQuery   += "SL4.L4_FILIAL = SL1.L1_FILIAL "
		cQuery   += "WHERE SL1.L1_EMISNF >= '" + DToS (dDataDe) + "'" 
		cQuery   += " AND SL1.L1_EMISNF <= '" + DToS (dDataAte) + "'"
		cQuery   += " AND SL1.L1_FILIAL = '" + cFilAnt + "'"
		cQuery   += " AND SL1.L1_PDV <> '' " 
		cQuery   += " AND SL1.L1_DOC <> '' "    
		cQuery   += " AND (SL1.L1_CARTAO > 0 OR SL1.L1_VLRDEBI > 0 ) "
		cQuery   += " AND (SL4.L4_FORMA = 'CC' OR SL4.L4_FORMA = 'CD' )"
		cQuery   += " AND SL1.D_E_L_E_T_ = ' ' " 
		cQuery   += " AND SL4.D_E_L_E_T_ = ' '  "
		cQuery   += " GROUP BY SL4.L4_FILIAL,SL4.L4_ADMINIS,SL4.L4_FORMA "
		
		cAliasTrb := GetNextAlias()
		cQuery    := ChangeQuery( cQuery )
		DbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cAliasTrb, .T., .F. )
		//cIndice := CriaTrab( NIL, .F. )
		(cAliasTrb)->(DbGoTop() )   
   ELSE	
#ENDIF
	    AADD(aCampos,{ "L4_FILIAL"	,"C",02,0 } )
		AADD(aCampos,{ "L4_ADMINIS"	,"C",20,0 } )
		AADD(aCampos,{ "L4_FORMA"	,"C",15,0 } )
		AADD(aCampos,{ "VALOR"	    ,"N",16,2 } )
	    
	    /********************************************************************************************************************************/
        /*** BLOCO ALTERADO EM 04/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
	    cAliasTrb := "CRT"
		//cArqTrab1 := CriaTrab(aCampos)
		//USE &cArqTrab1 ALIAS CRT NEW  
		//IndRegua(cAliasTrb,"indece" ,"L4_FILIAL+L4_ADMINIS" ,,,"" )	//"Selecionando Registros..."   
        oTempTbl01 := FWTemporaryTable():New( cAliasTrb )
        oTempTbl01:SetFields( aCampos )
        oTempTbl01:AddIndex( "cInd01", { "L4_FILIAL", "L4_ADMINIS" } )
        oTempTbl01:Create()
        /********************************************************************************************************************************/
	    SL1->(DbSelectarea("SL1"))
	    SL1->(DbSetOrder(4))
	    SL1->(MsSeek(cFilAnt + DToS(dDataDe),.T.))
	    While !SL1->(Eof()) .AND. (SL1->L1_EMISSAO <= dDataAte  .AND. SL1->L1_EMISSAO >= dDataDe )
	        If !Empty (AllTrim(SL1->L1_DOC))
				SL4->(DbSelectArea("SL4"))
				SL4->(DbSetOrder(1) )
				SL4->(MsSeek(xFilial("SL4") + SL1->L1_NUM) )  
				cSL4 := xFilial("SL4") + SL1->L1_NUM  
				While cSL4 == xFilial("SL4") + SL4->L4_NUM 
					If AllTrim(SL4->L4_FORMA) $ "CC|CD"    
						(cAliasTrb)->(MsSeek("", .T.) )	 
						If (cAliasTrb)->(MsSeek(xFilial("SL4") + SL4->L4_ADMINIS ) )
							Reclock( cAliasTrb ,.F.)
							(cAliasTrb)->VALOR := (cAliasTrb)->VALOR + SL4->L4_VALOR   
							(cAliasTrb)->(MsUnLock())						
						Else
							Reclock( cAliasTrb ,.T.)
						    (cAliasTrb)->L4_FILIAL  := SL4->L4_FILIAL
						    (cAliasTrb)->L4_ADMINIS := SL4->L4_ADMINIS
						    (cAliasTrb)->L4_FORMA   := SL4->L4_FORMA
						    (cAliasTrb)->VALOR      := SL4->L4_VALOR 
						    (cAliasTrb)->(MsUnLock())	
	 					EndIf  
	 					(cAliasTrb)->(DbCommit())								
					EndIf
					SL4->(DbSkip())
				End	
			EndIf
			SL1->(DbSkip())
		End	   
		(cAliasTrb)->(MsSeek("",.T.) )  
#IFDEF TOP
    Endif
#ENDIF				

//Define a proxima posicao do array a ser considerada no FOR, para garantir que nao vai reprocessar registros da filial anterior que ja foram processados. 
//Este tratamento eh necessario no caso de processar mais de uma filial.
nIniFor := Len(aReg1600)+1 
	
While !(cAliasTrb)->( Eof() )
	cCodADM := PadR( SubStr( (cAliasTrb)->L4_ADMINIS, 1, nCodSAE ) ,nCodSAE   )	
	cDesADM := SubStr((cAliasTrb)->L4_ADMINIS, nCodSAE +3 , Len((cAliasTrb)->L4_ADMINIS) ) 
	cCodReg := "SA1" + Iif(lConcFil,cFilAnt,"") + AllTrim(cCodADM) + "01"  // AllTrim(cEmpAnt) + AllTrim(cFilDoc) + AllTrim(cCodADM)						
	nValCC  := If( AllTrim( (cAliasTrb)->L4_FORMA ) == "CC",(cAliasTrb)->VALOR, 0 )
	nValCD  := If( AllTrim( (cAliasTrb)->L4_FORMA ) == "CD",(cAliasTrb)->VALOR, 0 )
	
	SAE->(DbSetOrder(1) )	
	If SAE->(MsSeek(xFilial("SAE") + cCodADM )  ) 
		If  Len(aReg1600) == 0 .OR. (nPosRede := aScan(aReg1600, { |x| x[6] == SAE->AE_REDE }) )  == 0  
            /********************************************************************************************************************************/
            /*** BLOCO ALTERADO EM 03/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
		    //SX5->(DbSetOrder(1) )
		    //If SX5->(MsSeek(xFilial("SX5") + "L9" + SAE->AE_REDE ) )
		    //	cRede := SX5->X5_DESCRI	
		    //EndIf
		    For _nY := 1 To Len( _aRetInf )
		        If Upper( Alltrim( _aRetInf[_nY][3] ) ) == Upper( Alltrim( SAE->AE_REDE ) )
		           cRede := Alltrim( _aRetInf[_nY][4] )
		        Endif
		    Next
		    If Empty(cRede)
		       cRede := cDesADM
		    EndIf
		    /********************************************************************************************************************************/
		    Aadd(aReg1600, {} )
			nI := Len(aReg1600)
			AAdd(aReg1600[nI], (cAliasTrb)->L4_FILIAL )   // Filial
			AAdd(aReg1600[nI], cCodReg 			       )   // CodAdm
			AAdd(aReg1600[nI], cRede				   )   // Descicao da Administradora
			AAdd(aReg1600[nI], nValCC				   )   // Valor de CC 
			AAdd(aReg1600[nI], nValCD				   )   // Valor do CD     
			AAdd(aReg1600[nI], SAE->AE_REDE			   )   // Rede dos Cartoes     
			AAdd(aReg1600[nI], cCodADM				   )   // Rede dos Cartoes     			 
		Else 
	    	aReg1600[nPosRede][5] += nValCD  
			aReg1600[nPosRede][4] += nValCC  		    	
		EndIf                       
	EndIf  	 
	(cAliasTrb)->(DbSkip() )				
End                          
If Len(aReg1600) > 0 
   	For nCount := nIniFor to Len(aReg1600) 
   		CriCliCC(aReg1600[nCount][7],(cAliasTrb)->L4_FILIAL,"01",@aReg0150,aReg1600[nCount][3],cAlias,aWizard)
   	Next nCount  	
EndIf
RestArea(aArea) 
(cAliasTrb)->(DbCloseArea() )
If Type("oTempTbl01") == "O"
   oTempTbl01:Delete()
Endif
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CriCliCC  ³ Autor ³ Vendas e CRM           ³ Data ³ 08/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera o Cadastro das Administradoras de Cartao para gravacao ³±±
±±³          ³ do Registro 150                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ PARAM01 - Codigo do cartao na tabela SA1                    ³±±   
±±³          ³ PARAM02 - Filial onde foi feita a venda                     ³±±
±±³          ³ PARAM03 - Loja onde foi feita a venda                       ³±± 
±±³          ³ PARAM04 - Array com o Cadastro de Clientes para a gravacao  ³±± 
±±³          ³ do Registro 150						                       ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/		
Static Function CriCliCC(cCodcli,cFilCli,cloja,aReg0150,cAdmin,cAlias,aWizard) 
Local lRet     := .F.
Local aArea    := GetArea()
Local aDadCli  := {}          // Array para gravacao das Administradoras no Registro 150 
Local cCodReg  := ""          // Campo 02 Cod Reg partic.
Local cNome    := ""          // Nome da empresa ou participante  
Local cCodPais := "01058"     // Cod do Pais Valor fixo da tabela
Local cCNPJ    := ""          // CNPJ do cliente
Local cCPF     := ""          // CPF do cliente 
Local cUF      := ""          // Estado do Cliente
Local cIE      := ""          // Inscricao Estadual
Local cCodMuni := ""          // Codigo do Municipio
Local cCodSufr := ""          // Codigo de inscricao do participante na SuFrama  
Local cEnd     := ""          // Endereco  
Local cNum     := ""          // Numero   
Local cComple  := ""          // Complemento do endereco   
Local aEnderc  := {}          // Array para retorno do enderco e numero e complemento 
Local cBairro  := ""          // Bairro
Local cClient  := ""

Default cCodCli := ""
Default cFilCli := ""  
Default cloja   := ""   

cClient := PadR(cCodCli,TamSX3("A1_COD")[1] )
DbSelectArea("SA1")
DbSetorder(1)
If MsSeek(xFilial("SA1") + cClient + cLoja )
	cCodReg  	:= 	"SA1" + Iif(lConcFil,cFilAnt,"") + AllTrim(cClient) + AllTrim(SA1->A1_LOJA)   //AllTrim(cEmpAnt) + AllTrim(cFilCli) + AllTrim(cCodCli )
	cNome    	:= 	If(AllTrim(cAdmin) <> "", cAdmin ,  SA1->A1_NOME )
	cCNPJ    	:= 	SA1->A1_CGC
	cUF      	:= 	SA1->A1_EST  
	cIE      	:= 	SPEDVldIE(SA1->A1_INSCR)
	cCodMuni 	:= 	Iif (Upper(SA1->A1_EST) == "EX","9999999",IIF(Len(SA1->A1_COD_MUN) <= 5,UfCodIBGE(SA1->A1_EST),"") + SA1->A1_COD_MUN)
	cCodSufr 	:= 	SA1->A1_SUFRAMA  
	aEnderc  	:= 	FisGetEnd(SA1->A1_END,SA1->A1_EST)  //{cEnderec,nNumero,cNumero,cComplemen} 
    cEnd     	:= 	aEnderc[1]
	cNum     	:= 	str(aEnderc[2])
	cComple  	:= 	aEnderc[4]  
	cBairro  	:= 	SA1->A1_BAIRRO
    aDadCli  	:= 	{cCodReg,cNome,cCodPais,cCNPJ,cCPF,cIE,cCodMuni,cCodSufr,cEnd,cNum,cComple,cBairro }  
   	SDPF150175(@aReg0150,aDadCli,cAlias,aWizard)
EndIf
Restarea(aArea)
Return(lRet)    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GrReg1600 ³ Autor ³ Vendas e CRM           ³ Data ³ 08/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera o Registro 1600 - Total das Operacoes com cartao de    ³±±
±±³          ³ Credito  Cartao de Debito                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias - cAlias   - Alias do TRB   						   ³±±   
±±³          ³ aReg1600 - Array para geracao do registro 1600   		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/	
Static Function GrReg1600(cAlias,aReg1600,dDataDe,dDataAte,aReg0150,aWizard)  
Local aRet      := {}     // Array para gravaco no Alias
Local nI        := 0      // Auxiliar do For
Local nRelac    := 0      // Relacionamento Com outras Tabelas  
Local nItem     := 0      // Item para gravaco no alias
Local cCodCli	:= ""
Local cLoja		:= ""
Local aPE1600	:= {}	  // Array utilizado para processar informacoes do ponto de entrada SPDFIS10  
Local cFil1600 	:= ""	  // Filial		
Local nIndexReg := 0

Default aReg1600 := {}

If aExistBloc[17]
	aPE1600 :=	ExecBlock("SPDFIS10", .F., .F., {dDataDe,dDataAte})
	For nI:= 1 to Len(aPE1600)
		//Composicao do codigo do cliente
		cFil1600 :=	Substr ( aPE1600[nI][2] , 3 + 1 ,Len(cFilAnt) )
		//Composicao do codigo do cliente
		cCodCli :=	AllTrim(Substr ( aPE1600[nI][2] , 3 + Len(cFilAnt) + 1 , TamSX3("A1_COD")[1] ))
		//Composicao da loja do cliente
		cLoja	:=	AllTrim(Substr ( aPE1600[nI][2] , 3 + Len(cFilAnt) + TamSX3("A1_COD")[1] + 1 , TamSX3("A1_LOJA")[1] ))
		
		nIndexReg := AScan(aReg1600, {|aX| AllTrim(aX[2]) == "SA1"+Iif(lConcFil,cFil1600,"")+cCodCli+cLoja})
		
		// Se o registro já existir, soma os créditos e débitos p/ n duplicar o reg. 1600
		If nIndexReg > 0
			aReg1600[nIndexReg][4] += aPE1600[nI][4]
			aReg1600[nIndexReg][5] += aPE1600[nI][5]		 
		Else		   
			AADD(aReg1600,{,"SA1"+Iif(lConcFil,cFil1600,"")+cCodCli+cLoja,,aPE1600[nI][4],aPE1600[nI][5],,})			
			//Chamada da funcao para gerar o registro 0150
		 	CriCliCC(cCodCli,NIL ,cLoja,@aReg0150,,cAlias,aWizard)
		EndIf		   
	Next nI	 
EndIf

If Len(aReg1600) > 0
	// filial - CodCli - Admin - ValorCC -ValorCD 		
	For nI:= 1 to Len(aReg1600)
		AADD(aRet,{"1600",aReg1600[nI][2],aReg1600[nI][4],aReg1600[nI][5]} )
	Next nI
		    
	GrvRegTrS (cAlias, nRelac, aRet, nItem)	
EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±³±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³±±
±±³Programa  ³Grupo1900 ³ Autor ³Caio Oliveira               ³ 20.12.2011 		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³±±
±±³Descri‡ao ³         GERACAO DO REGISTRO 1900 E FILHOS                         ³±± 
±±³          ³REGISTRO 1910 - PERIODO DA APURACAO DO ICMS                        ³±± 
±±³          ³REGISTRO 1920 - APURACAO DE ICMS - OPERACOES PROPRIAS              ³±± 
±±³          ³REGISTRO 1921 - AJUSTES/BENEFICIOS/INCENTIVO DA APURACAO DE ICMS   ³±± 
±±³          ³REGISTRO 1922 - INFORMACOES ADICIONAIS DOS AJUSTES DE APURACAO DO  ³±± 
±±³          ³                ICMS                                               ³±± 
±±³          ³REGISTRO 1923 - INF. ADICIONAIS DA APURACAO DO ICMS                ³±± 
±±³          ³REGISTRO 1926 - OBRIGACOES DO ICMS A RECOLHER - OPERACOES PROPRIAS ³±±
±±³          ³                                                                   ³±±
±±³          ³Funcao utilizada para montar a estrutura dos registros acima e     ³±±
±±³          ³  gravar no TRB para geracao do TXT                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lTabComp - Flag de existencia das tabelas complementares           ³±±
±±³          ³aWizard  - Informacoes do assistente da rotina                     ³±±
±±³          ³cFilDe   - Filial inicial para processament multifilial            ³±±
±±³          ³cFilAte  - Filial final para processament multifilial              ³±±
±±³          ³cAlias   - Alias do TRB                                            ³±±
±±³          ³cMVEstado- Conteudo do parametro MV_ESTADO                         ³±±
±±³          ³lTop     - Flag para identificar ambiente TOP                      ³±±
±±³          |oProcess -> Objeto da nova barra de progressao                     ³±±
±±³			 |aLanCDA - Array com informacoes da tabela CDA.					 ³±±
±±³			 |aLanCDA2 - Array com informacoes da tabela CDA (Totalizador).		 ³±±
±±³			 |aLiv1900 - Contém os números de Livro para buscar a SubApuração	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Grupo1900(lTabComp, aWizard, cFilDe,cFilAte,cAlias,cMVEstado,lTop,oProcess,aLanCDA,aLanCDA2,aLiv1900,lOldLan,lExtratTAF,aRegsT020)

Local	aReg1900	:=  {}
Local	aReg1910	:=	{}
Local	aReg1920	:=	{}
Local	aReg1921 	:= 	{}
Local	aReg1922 	:= 	{}
Local	aReg1923	:=	{}
Local	aReg1925	:=  {}
Local	aReg1926 	:= 	{}
Local	aApICM		:=	{}

Local	cICMGNR	:=	""
Local	cMvSFUfGnr	:=	aSPDSX6[MV_SFUFGNR]
Local	cCodRec	:=	""

Local	dDataDe	    :=	''
Local	dDataAte	:=	''

Local	lSeekCDH	:=	.F.

Local	nYY			:=  0
Local	nPos		:=	0
Local	nPos1900	:=	0
Local	nPos1920	:=	0 
Local	nPos1925	:=  0
Local	nPeriodo	:=	1
Local	nApuracao	:=	3
Local	nZZ			:=  0
Local	nCnt		:=  1
Local   cPeriodo    :=	''

Default lExtratTAF  := .F.
Default aRegsT020   :=  {}	 

aSort(aLiv1900,,,{|x, y| x[1]<y[1]})

If !lExtratTAF
	dDataDe  	:=	SToD(aWizard[1][1])
	dDataAte	:=	STod(aWizard[1][2])		
	cPeriodo    :=	StrZero(Year(dDataDe),4)+StrZero(Month(dDataDe),2)
	
else	
	dDataDe		:=	aWizard[1][3]
	dDataAte	:=	aWizard[1][4]
	cPeriodo    :=	StrZero(Year(dDataDe),4)+StrZero(Month(dDataAte),2)

EndIf

For nYY := 1 to Len(aLiv1900)
	
	lSeekCDH	:=	.F.
	aApICM		:=	{}
	cICMGNR		:=	""
	
	If lTabComp	.And. FindFunction("AP1900ICM")//Flag de existencia das tabelas complementares do SPED
		lSeekCDH	:=	AP1900ICM(cFilDe,cFilAte,nApuracao,nPeriodo,aLiv1900[nYY][2],"IC",cAlias,dDataDe,dDataAte,cMVEstado,lTop,@oProcess,aLanCDA,@aLanCDA2, {aLiv1900[nYY][1],aLiv1900[nYY][3]},@aReg1900,@aReg1910,@aReg1920,@aReg1921,@aReg1922,@aReg1923,@aReg1926,lOldLan,,,lExtratTAF)			
	EndIf
	
	If !lSeekCDH
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Leio o arquivo de apuracao ICMS ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		aApICM			:=	FisApur("IC",Year(dDataAte),Month(dDataAte),nApuracao,nPeriodo,aLiv1900[nYY][2],.F.,{},1,.F.,"")
		
		If Len(aApICM)>0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³GRAVACAO DO REGISTRO 1900 - INDICAÇÃO DA SUB-APURACAO                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAdd (aReg1900, {})
			nPos1900	:=	Len (aReg1900)
			aAdd (aReg1900[nPos1900], "1900")								//01 - REG
			aAdd (aReg1900[nPos1900], aLiv1900[nYY][1])						//02 - IND_APUR_ICM
			aAdd (aReg1900[nPos1900], aLiv1900[nYY][3])					   	//03 - DESCR_COMPL_OUT_APUR
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³GRAVACAO DO REGISTRO 1910 - PERIODO DA APURACAO DO ICMS                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAdd (aReg1910, {})
			nPos	:=	Len (aReg1910)
			aAdd (aReg1910[nPos], nPos1900)								//01 - REG
			aAdd (aReg1910[nPos], "1910")								//01 - REG
			aAdd (aReg1910[nPos], dDataDe)								//02 - DT_INI
			aAdd (aReg1910[nPos], dDataAte)								//03 - DT_FIN
			
			aAdd(aReg1920, {nPos,"1920",0,0,0,0,0,0,0,0,0,0,0,0})
			nPos1920	:= Len(aReg1920)
			
			aReg1920[nPos1920][3]		:=	Iif (aScan(aApICM, {|a| a[1]=="001"}   )<>0, aApICM[aScan(aApICM, {|a| a[1]=="001"   })][3],0)
			aReg1920[nPos1920][4]		:=	Iif (aScan(aApICM, {|a| a[4]=="002.00"})<>0, aApICM[aScan(aApICM, {|a| a[4]=="002.00"})][3],0)
			aReg1920[nPos1920][5]		:=	Iif (aScan(aApICM, {|a| a[4]=="003.00"})<>0, aApICM[aScan(aApICM, {|a| a[4]=="003.00"})][3],0)
			aReg1920[nPos1920][6]		:=	Iif (aScan(aApICM, {|a| a[1]=="005"   })<>0, aApICM[aScan(aApICM, {|a| a[1]=="005"   })][3],0)
			aReg1920[nPos1920][7]		:=	Iif (aScan(aApICM, {|a| a[4]=="006.00"})<>0, aApICM[aScan(aApICM, {|a| a[4]=="006.00"})][3],0)
			aReg1920[nPos1920][8]		:=	Iif (aScan(aApICM, {|a| a[4]=="007.00"})<>0, aApICM[aScan(aApICM, {|a| a[4]=="007.00"})][3],0)
			aReg1920[nPos1920][9]		:=	Iif (aScan(aApICM, {|a| a[1]=="009"   })<>0, aApICM[aScan(aApICM, {|a| a[1]=="009"   })][3],0)
			aReg1920[nPos1920][10]		:=	Iif (aScan(aApICM, {|a| a[1]=="011"   })<>0, aApICM[aScan(aApICM, {|a| a[1]=="011"   })][3],0)
			aReg1920[nPos1920][11]		:=	Iif (aScan(aApICM, {|a| a[4]=="012.00"})<>0, aApICM[aScan(aApICM, {|a| a[4]=="012.00"})][3],0)
			aReg1920[nPos1920][12]		:=	Iif (aScan(aApICM, {|a| a[1]=="013"   })<>0, aApICM[aScan(aApICM, {|a| a[1]=="013"   })][3],0)
			aReg1920[nPos1920][13]		:=	Iif (aScan(aApICM, {|a| a[1]=="014"   })<>0, aApICM[aScan(aApICM, {|a| a[1]=="014"   })][3],0)
			aReg1920[nPos1920][14]		:=	Iif (aScan(aApICM, {|a| a[4]=="900.00"})<>0, aApICM[aScan(aApICM, {|a| a[4]=="900.00"})][3],0)
			
			If aReg1920[nPos1920][13]>0
				cICMGNR			:=	Iif(aScan(aApICM,{|a| a[1]=="GNR" .And. AllTrim(a[4])==AllTrim(aReg1920[nPos1920][13])})<>0, aApICM[aScan(aApICM, {|a| a[1]=="GNR" .And. AllTrim(a[4])==AllTrim(aReg1920[nPos1920][13])})][2],"")
				cICMGNR			:=	SubStr(cICMGNR,1,At("/",cICMGNR)-3)
				
				//  Verifico se a UF de Recolhimento do ICMS Proprio deve apresentar o campo 05 - COD_REC
				//  considerando o Codigo da Receita + Classe de Vencimento ( F6_CODREC + F6_CLAVENC )
				cCodRec	:=	Iif( cMvEstado $ cMvSFUfGnr , "SF6->( Alltrim( F6_CODREC ) + Alltrim( F6_CLAVENC ) )" , "SF6->F6_CODREC" )
								
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Posicionamento da tabela SF6, conforme dados do .IC0    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SPEDSeek("SF6",1,xFilial("SF6")+cMVESTADO+cICMGNR)
					aAdd(aReg1926, {})
					nPos	:=	Len (aReg1926)
					aAdd(aReg1926[nPos], nPos1920 )									//01 - RELACIONAMENTO
					aAdd(aReg1926[nPos], "E116")									//01 - REG
					aAdd(aReg1926[nPos], Iif(!SF6->F6_COBREC$"",SF6->F6_COBREC,"000"))		//02 - COD_OR
					aAdd(aReg1926[nPos], SF6->F6_VALOR)  							//03 - VL_OR
					aAdd(aReg1926[nPos], SF6->F6_DTVENC)  							//04 - DT_VCTO
					aAdd(aReg1926[nPos], &( cCodRec ))								//05 - COD_REC
					aAdd(aReg1926[nPos], "")										//06 - NUM_PROC
					aAdd(aReg1926[nPos], "")										//07 - IND_PROC
					aAdd(aReg1926[nPos], "")										//08 - PROC
					aAdd(aReg1926[nPos], SF6->F6_OBSERV)							//09 - TXT_COMPL
					
					If cVersao >= "004"
						aAdd(aReg1926[nPos],SF6->(StrZero(F6_MESREF,2)+cValToChar(F6_ANOREF)))//10 - MES_REF
					EndIf           

					//Para o extrator fiscal preciso levar o número e o Tipo (0=Doc. Arrecad. 1= GNRE) da GNRE para amarrar no TAF
					if lExtratTAF
						aAdd(aReg1926[nPos], SF6->F6_NUMERO)						//11-Numero da Guia
						aAdd(aReg1926[nPos], IIF(Empty(SF6->F6_NUMERO),"",IIF(SF6->F6_TIPOIMP=="0","0","1")))			
					EndIf
										
				EndIf
			EndIf
		EndIf
	EndIf 
	
	//Grava no array do extrator
	If lExtratTAF
			If(Len(aReg1920) > 0)
				aAdd(aReg1920[1], aReg1900[1][2])
				aAdd(aReg1920[1], aReg1900[1][3])
				aAdd(aRegsT020,{aReg1920,;
							    aReg1921,;
								aReg1922,;
								aReg1923,;
								aReg1925,;
								aReg1926})	
								 
				//Limpo os arrays
				aReg1920 := {}
				aReg1921 := {}
				aReg1922 := {}
				aReg1923 := {}
				aReg1925 := {}
				aReg1926 := {}
			EndIf				 
			
												 
	EndIf	
	
Next nYY
If Len(aReg1900)>0
	If aSPDSX2[AI_CDV] 	.OR. lExtratTAF
		dbSelectArea("CDV")
	    CDV->(DbSetOrder(2)) 
	    For nYY := 1 To Len(aLiv1900)
			CDV->(MsSeek(xFilial("CDV")+cPeriodo+aLiv1900[nYY][2]))
			While !CDV->(Eof()) .And. CDV->CDV_FILIAL==xFilial("CDV") .And. CDV->CDV_PERIOD==cPeriodo .And. CDV->CDV_LIVRO == aLiv1900[nYY][2]
				cDados:= "NF: " + Alltrim(CDV->CDV_DOC) + " SERIE: " + Alltrim(CDV->CDV_SERIE) + " CLI/FOR: " + Alltrim(CDV->CDV_CLIFOR) + " LOJA: " + Alltrim(CDV->CDV_LOJA)
                nZZ += 1
				aAdd (aReg1925, {})
				nPos1925 :=Len(aReg1925)
				aAdd (aReg1925[nPos1925], nZZ )
				aAdd (aReg1925[nPos1925], "1925")					//01 - REG
				aAdd (aReg1925[nPos1925], CDV->CDV_CODAJU)			//02 - COD_INF_ADIC
				aAdd (aReg1925[nPos1925], CDV->CDV_VALOR)			//03 - VL_INF_ADIC
				aAdd (aReg1925[nPos1925], CDV->CDV_DESCR + cDados)	//04 - DESCR_COMPL_AJ
				
    			//Grava no array do extrator
				If lExtratTAF
    				//sobreponhe o array aRegs1925 usado no extrator
    				aAdd(aRegsT020[nCnt][5], aReg1925[nPos1925])				
    			EndIf				
    	
				CDV->(DbSkip())
			EndDo
			If !Empty(aLiv1900[nYY][1]) .AND. lExtratTAF
				nCnt++
			EndIf
		Next nYY
	Endif	
	SPEDRegs(cAlias,{aReg1900,aReg1910,aReg1920,aReg1921,aReg1922,{aReg1923,4},{aReg1925,3},{aReg1926,3}})
EndIf

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³AP1900ICM | Autor ³Caio Oliveira	 			   ³ Data ³20.12.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³                        GERACAO DO BLOCO E                         ³±± 
±±³          ³REGISTRO 1910 - PERIODO DA APURACAO DO ICMS                        ³±± 
±±³          ³REGISTRO 1920 - APURACAO DE ICMS - OPERACOES PROPRIAS              ³±± 
±±³          ³REGISTRO 1921 - AJUSTES/BENEFICIOS/INCENTIVO DA APURACAO DE ICMS   ³±± 
±±³          ³REGISTRO 1922 - INFORMACOES ADICIONAIS DOS AJUSTES DE APURACAO DO  ³±± 
±±³          ³                ICMS                                               ³±± 
±±³          ³REGISTRO 1923- INF. ADICIONAIS DA APURACAO DO ICMS                 ³±± 
±±³          ³REGISTRO 1926 - OBRIGACOES DO ICMS A RECOLHER - OPERACOES PROPRIAS ³±± 
±±³          ³                                                                   ³±±
±±³          ³Funcao utilizada para montar a estrutura dos registros acima e     ³±±
±±³          ³  gravar no TRB para geracao do TXT                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 -> Identifica se houve movimento no periodo ou nao           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cFilDe   - Filial inicial para processament multifilial            ³±±
±±³          ³cFilAte  - Filial final para processament multifilial              ³±±
±±³          ³nApuracao -> Tipo de apuracao, padrao 3                            ³±±
±±³          ³nPeriodo  -> Periodo de apuracao, padrao 1                         ³±±
±±³          ³cNrLivro  -> Numero do livro selecionado no wizard                 ³±±
±±³          ³cImp -> imposto de processamento. IC=ICMS,ST=SUBST. TRIBUTARIA     ³±±
±±³          ³cAlias   - Alias do TRB                                            ³±±
±±³          ³dDataDe -> Data inicio de processamento inf. no wizard             ³±±
±±³          ³dDataAte -> Data final de processamento inf. no wizard             ³±±
±±³          ³cMVEstado-> Conteúdo do MV_ESTADO						             ³±±
±±³          ³lTop     - Flag para identificar ambiente TOP                      ³±±
±±³          ³oProcess - Objeto do novo controle de processamento                ³±±
±±³			 |aLanCDA -> Array contendo a tabela CDA.		                     ³±±
±±³			 |aLanCDA2 -> Array contendo a tabela CDA. (Totalizador)             ³±±
±±³			 |a1900	  -> Array contendo o número do livro para buscar a apuração ³±±
±±³			 |aReg1900  -> Array para geração do registro 1900					 ³±±
±±³			 |aReg1910  -> Array para geração do registro 1910					 ³±±
±±³			 |aReg1920  -> Array para geração do registro 1920					 ³±±
±±³			 |aReg1921  -> Array para geração do registro 1921					 ³±±
±±³			 |aReg1922  -> Array para geração do registro 1922					 ³±±
±±³			 |aReg1923  -> Array para geração do registro 1923					 ³±±
±±³			 |aReg1926  -> Array para geração do registro 1926					 ³±±   
±±³			 |cExtVer   -> Versao do Sped Que o Extrator TAF considera    		 ³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AP1900ICM(cFilDe,cFilAte,nApuracao,nPeriodo,cNrLivro,cImp,cAlias,dDataDe,dDataAte,cMVEstado,lTop,oProcess,aLanCDA,aLanCDA2,a1900,aReg1900,aReg1910,aReg1920,aReg1921,aReg1922,aReg1923,aReg1926,lOldLan,cExtVer,aRegT020AG,lExtratTAF)

Local 	cChave	 	:= 	STR(nApuracao,1)+STR(nPeriodo,1)+DTOS(dDataDe)+cNrLivro
Local 	cSomaSeq	:= 	""
Local 	cSequen	 	:= 	""
Local 	cUf		 	:= 	cMvEstado
Local 	cCodAjApur 	:= 	""
Local	cAliasCDH	:=	"CDH"

Local 	nPos		:= 	0
Local 	nPos1921	:=	0
Local	nX			:=	0
Local	nPos1920	:=	0
Local	nRecnoSF6	:=	Nil

Local 	lRet		:= 	.T.
Local	lAchouSF6	:=	.F.

Local 	lCmps1923	:=	cUf $ aSPDSX6[MV_ESTE113]

Local	aParametros	:=	{}

Default aLanCDA		:=	{}
Default a1900		:=	{}
Default	aReg1900	:=	{}
Default	aReg1910	:=	{}
Default	aReg1920	:=	{0,"1920",0,0,0,0,0,0,0,0,0,0,0,0}
Default	aReg1921 	:= 	{}
Default	aReg1922 	:= 	{}
Default	aReg1923	:=	{}
Default	aReg1926 	:= 	{}    
Default lOldLan	 	:= 	aSPDSX3[FP_CC6_TIPOAJ]  

Default cExtVer  := ""
Default lExtratTAF	:=  .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³No caso de o objeto oProcess existir, significa que a nova barra  ³
//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
//| portanto deve ser efetuado os controles para demonstrar o        |
//| resultado do processamento.                                      |
//|                                                                  |
//|Incremento da regua, como o processamento da funcao eh muito      |
//| rapido nao preciso de mais detalhes                              |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("oProcess")=="O"
	oProcess:Inc2Progress("Obtendo Informações de Apuração de ICMS","") // "Obtendo Informações de Apuração de ICMS"
Else
	IncProc("Obtendo Informações de Apuração de ICMS") // "Obtendo Informações de Apuração de ICMS"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Para ambiente TOP nao preciso pegar a ultima sequencia, pois isso eh resolvido na propria query³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTop
	If CDH->(MsSeek(xFilial("CDH")+cImp+cChave))
		cSomaSeq  := CDH->CDH_SEQUEN
		While CDH->(MsSeek(xFilial("CDH")+cImp+cChave+cSomaSeq)) // Posiciona na ultima sequencia
			cSequen  := CDH->CDH_SEQUEN
			cSomaSeq := Soma1(cSequen)
		EndDo
	EndIf
EndIf  

If !Empty( cExtVer )
	cVersao := cExtVer
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montando parametros para a query ou indregua³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aParametros,cImp)
aAdd(aParametros,STR(nApuracao,1))
aAdd(aParametros,STR(nPeriodo,1))
aAdd(aParametros,DTOS(dDataDe))
aAdd(aParametros,cNrLivro)
aAdd(aParametros,cSequen)

If SPEDFFiltro(1,"CDH",@cAliasCDH,aParametros)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³REGISTRO E110 - APURACAO DE ICMS - OPERACOES PROPRIAS³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	aAdd (aReg1900, {})
	nPos1900	:=	Len (aReg1900)
	aAdd (aReg1900[nPos1900], "1900")								//01 - REG
	aAdd (aReg1900[nPos1900], a1900[1])								//02 - IND_APUR_ICM
	aAdd (aReg1900[nPos1900], a1900[2])							   	//03 - DESCR_COMPL_OUT_APUR
	
	aAdd (aReg1910, {})
	nPos	:=	Len (aReg1910)
	aAdd (aReg1910[nPos], nPos1900)								//01 - REG
	aAdd (aReg1910[nPos], "1910")								//01 - REG
	aAdd (aReg1910[nPos], dDataDe)								//02 - DT_INI
	aAdd (aReg1910[nPos], dDataAte)								//03 - DT_FIN
	
	aAdd(aReg1920, {nPos,"1920",0,0,0,0,0,0,0,0,0,0,0,0})
	nPos1920	:= Len(aReg1920)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega ajustes na apuracao ICMS ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !(cAliasCDH)->(Eof())
		
		cCodAjApur 	:= 	(cAliasCDH)->CDH_CODLAN
		nPos1921	:=	0
		lGera1921	:=	.F.
		lGera1926	:=	.F.
		nRecnoSF6	:=	Iif(lTop,(cAliasCDH)->SF6RECNO,Nil)
		lAchouSF6	:=	.F.
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posicionamento da tabela SF6, tanto para TOP (RECNO) quanto para DBF/ADS    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty((cAliasCDH)->(CDH_ESTGNR+CDH_GNRE))
			lAchouSF6	:=	SPEDSeek("SF6",1,xFilial("SF6")+(cAliasCDH)->(CDH_ESTGNR+CDH_GNRE),nRecnoSF6)
		EndIf
		
		Do Case
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Case que determina o calculo do (2)VL_TOT_DEBITOS = Valor total dos debitos  ³
			//³     por "SAIDAS E PRESTACOES COM DEBITO DO IMPOSTO"                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case (cAliasCDH)->CDH_LINHA == "001"
				aReg1920[nPos1920][3] += (cAliasCDH)->CDH_VALOR
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Case que determina o calculo de 2 lancamentos:                               |
				//|- (3)VL_AJ_DEBITOS = Valor total dos ajustes a debitos provenitentes de NF   ³
				//³- (4)VL_TOT_AJ_DEBITOS = Valor total dos ajustes a debitos                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case (cAliasCDH)->CDH_LINHA $ "002" .And. Alltrim((cAliasCDH)->CDH_SUBITE) <> "002.00" .And. !Empty((cAliasCDH)->CDH_CODLAN)	//Lancamentos a outros debitos
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Tratamento para o codigo no formato antigo (NAO SE UTILIZA MAIS) ou para o novo de 10 posicoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !(lOldLan .And. SubStr((cAliasCDH)->CDH_CODLAN,1,1)=="1") .And.;	//No formato antigo, os que iniciam por 1 sao lancamentos de NF
					!(!lOldLan .And. Len(Alltrim((cAliasCDH)->CDH_CODLAN))==10)		//Tamanho 10 eh soh os lancamentos de NF
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se for ajuste com origem em NF, ja vai estar lancado no C197³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Conforme cadastro de ajuste manual, quando a terceira posicao do codigo for ³
					//³   0=ICMS e a quarta for 0=Outros Debitos, considero este valor.            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SubStr((cAliasCDH)->CDH_CODLAN,3,1)=="0" .And. SubStr((cAliasCDH)->CDH_CODLAN,4,1)== "0"
						aReg1920[nPos1920][4] += (cAliasCDH)->CDH_VALOR
					EndIf
					
					lGera1921	:=	.T.
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se for ajuste de apuracao precisa lancar no 1921³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lOldLan	//Codigo de lancamento antigo tem outro formato, e precisa ser convertido para um DEFAULT para nao apresentar erro de validacao
						cCodAjApur := cUf+"0"+"0"+"9999"
					EndIf
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Case que determina o calculo de 2 lancamentos:                               |
				//|- (3)VL_AJ_DEBITOS = Valor total dos ajustes a debitos provenitentes de NF   ³
				//³- (5)VL_ESTORNOS_CRED = Valor total dos ajustes "ESTORNO DE CREDITOS"        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case (cAliasCDH)->CDH_LINHA $ "003" .And. Alltrim((cAliasCDH)->CDH_SUBITE) <> "003.00" .And. !Empty((cAliasCDH)->CDH_CODLAN)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Tratamento para o codigo no formato antigo (NAO SE UTILIZA MAIS) ou para o novo de 10 posicoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !(lOldLan .And. SubStr((cAliasCDH)->CDH_CODLAN,1,1)=="1") .And.;	//No formato antigo, os que iniciam por 1 sao lancamentos de NF
					!(!lOldLan .And. Len(Alltrim((cAliasCDH)->CDH_CODLAN))==10)		//Tamanho 10 eh soh os lancamentos de NF
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se for ajuste com origem em NF, ja vai estar lancado no C197³
					//|                                                            |
					//|Um lancacamento a ESTORNO DE CREDITO proveniente de NF,     |
					//|  tambem entra como DEBITO(3)                               |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Conforme cadastro de ajuste manual, quando a terceira posicao do codigo for ³
					//³   0=ICMS e a quarta for 1=Estorno de Credito, considero este valor.        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SubStr((cAliasCDH)->CDH_CODLAN,3,1)=="0" .And. SubStr((cAliasCDH)->CDH_CODLAN,4,1)== "1"
						aReg1920[nPos1920][5] += (cAliasCDH)->CDH_VALOR
					EndIf
					
					lGera1921	:=	.T.
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se for ajuste de apuracao precisa lancar no E111³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lOldLan
						cCodAjApur := cUf+"0"+"1"+"9999"
					EndIf
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Case que determina o calculo do (6)VL_TOT_CREDITOS = Valor total dos creditos³
				//³     por "ENTRADAS E AQUISICOES COM CREDITO DO IMPOSTO"                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case (cAliasCDH)->CDH_LINHA == "005"
				aReg1920[nPos1920][6] += (cAliasCDH)->CDH_VALOR
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Case que determina o calculo de 2 lancamentos:                               |
				//|- (7)VL_AJ_CREDITOS = Valor total dos ajustes a creditos provenitentes de NF ³
				//³- (8)VL_TOT_AJ_CREDITOS = Valor total dos "AJUSTES A CREDITO"                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case (cAliasCDH)->CDH_LINHA $ "006" .And. Alltrim((cAliasCDH)->CDH_SUBITE) <> "006.00" .And. !Empty((cAliasCDH)->CDH_CODLAN)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Tratamento para o codigo no formato antigo (NAO SE UTILIZA MAIS) ou para o novo de 10 posicoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !(lOldLan .And. SubStr((cAliasCDH)->CDH_CODLAN,1,1)=="1") .And.;	//No formato antigo, os que iniciam por 1 sao lancamentos de NF
					!(!lOldLan .And. Len(Alltrim((cAliasCDH)->CDH_CODLAN))==10)		//Tamanho 10 eh soh os lancamentos de NF
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se for ajuste com origem em NF, ja vai estar lancado no C197³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Conforme cadastro de ajuste manual, quando a terceira posicao do codigo for ³
					//³   0=ICMS e a quarta for 2=Outros Creditos, considero este valor.           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SubStr((cAliasCDH)->CDH_CODLAN,3,1)=="0" .And. SubStr((cAliasCDH)->CDH_CODLAN,4,1)== "2"
						aReg1920[nPos1920][7] += (cAliasCDH)->CDH_VALOR
					EndIf
					
					lGera1921	:=	.T.
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se for ajuste de apuracao precisa lancar no E111³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lOldLan
						cCodAjApur := cUf+"0"+"2"+"9999"
					EndIf
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Case que determina o calculo de 2 lancamentos:                               |
				//|- (7)VL_AJ_CREDITOS = Valor total dos ajustes a creditos provenitentes de NF ³
				//³- (9)VL_ESTORNOS_DEB = Valor total dos ajustes "ESTORNO DE DEBITOS"          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case (cAliasCDH)->CDH_LINHA $ "007" .And. Alltrim((cAliasCDH)->CDH_SUBITE) <> "007.00" .And. !Empty((cAliasCDH)->CDH_CODLAN)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Tratamento para o codigo no formato antigo (NAO SE UTILIZA MAIS) ou para o novo de 10 posicoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !(lOldLan .And. SubStr((cAliasCDH)->CDH_CODLAN,1,1)=="1") .And.;	//No formato antigo, os que iniciam por 1 sao lancamentos de NF
					!(!lOldLan .And. Len(Alltrim((cAliasCDH)->CDH_CODLAN))==10)		//Tamanho 10 eh soh os lancamentos de NF
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se for ajuste com origem em NF, ja vai estar lancado no C197³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Conforme cadastro de ajuste manual, quando a terceira posicao do codigo for ³
					//³   0=ICMS e a quarta for 3=Estorno de debitos, considero este valor.        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SubStr((cAliasCDH)->CDH_CODLAN,3,1)=="0" .And. SubStr((cAliasCDH)->CDH_CODLAN,4,1)=="3"
						aReg1920[nPos1920][8] += (cAliasCDH)->CDH_VALOR
					EndIf
					
					lGera1921	:=	.T.
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se for ajuste de apuracao precisa lancar no E111³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lOldLan
						cCodAjApur := cUf+"0"+"3"+"9999"
					EndIf
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Case que determina o calculo do (10)VL_SLD_CREDOR_ANT = Valor total do "SALDO|
				//³  CREDOR DO PERIODO ANTERIOR"                                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case (cAliasCDH)->CDH_LINHA == "009"
				aReg1920[nPos1920][9] += (cAliasCDH)->CDH_VALOR
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Case que determina o calculo do (10)VL_SLD_APURADO = Valor do saldo devedor  |
				//³  apurado                                                                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case (cAliasCDH)->CDH_LINHA == "011"
				aReg1920[nPos1920][10] += (cAliasCDH)->CDH_VALOR
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Case que determina o calculo de 2 lancamentos:                               |
				//|- (7)VL_AJ_CREDITOS = Valor total dos ajustes a creditos provenitentes de NF ³
				//³- (12)VL_TOT_DED = Valor total de "DEDUCOES"                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case (cAliasCDH)->CDH_LINHA $ "012" .And. Alltrim((cAliasCDH)->CDH_SUBITE) <> "012.00" .And. !Empty((cAliasCDH)->CDH_CODLAN)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Tratamento para o codigo no formato antigo (NAO SE UTILIZA MAIS) ou para o novo de 10 posicoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !(lOldLan .And. SubStr((cAliasCDH)->CDH_CODLAN,1,1)=="1") .And.;	//No formato antigo, os que iniciam por 1 sao lancamentos de NF
					!(!lOldLan .And. Len(Alltrim((cAliasCDH)->CDH_CODLAN))==10)		//Tamanho 10 eh soh os lancamentos de NF
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se for ajuste com origem em NF, ja vai estar lancado no C197³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Conforme cadastro de ajuste manual, quando a terceira posicao do codigo for ³
					//³   0=ICMS e a quarta for 4=Deducoes, considero este valor.                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SubStr((cAliasCDH)->CDH_CODLAN,3,1)=="0" .And. SubStr((cAliasCDH)->CDH_CODLAN,4,1)=="4"
						aReg1920[nPos1920][11] += (cAliasCDH)->CDH_VALOR
					EndIf
					
					lGera1921	:=	.T.
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se for ajuste de apuracao precisa lancar no E111³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lOldLan
						cCodAjApur := cUf+"0"+"4"+"9999"
					EndIf
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Case que determina o calculo do (13)VL_ICMS_RECOLHER = Valor total de        |
				//³  "ICMS A RECOLHER"                                                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case (cAliasCDH)->CDH_LINHA == "013"
				aReg1920[nPos1920][12] += (cAliasCDH)->CDH_VALOR
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Case que determina o calculo do (14)VL_SLD_CREDOR_TRANSPORTAR = Valor total  |
				//³  de "SALDO CREDOR A TRANSPORTAR PARA O PERIODO SEGUINTE"                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case (cAliasCDH)->CDH_LINHA == "014"
				aReg1920[nPos1920][13] += (cAliasCDH)->CDH_VALOR
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Case que determina o calculo de 2 lancamentos:                               |
				//|- (15)DEB_ESP = valores recolhidos ou a recolher extra-apuracao              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case (cAliasCDH)->CDH_LINHA$"900" .And. Alltrim((cAliasCDH)->CDH_SUBITE)<>"900.00" .And. !Empty((cAliasCDH)->CDH_CODLAN)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Tratamento para o codigo no formato antigo (NAO SE UTILIZA MAIS) ou para o novo de 10 posicoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (lOldLan .And. SubStr((cAliasCDH)->CDH_CODLAN,1,1)=="1") .Or.;	//No formato antigo, os que iniciam por 1 sao lancamentos de NF
					(!lOldLan .And. Len(Alltrim((cAliasCDH)->CDH_CODLAN))==10)		//Tamanho 10 eh soh os lancamentos de NF
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se for ajuste com origem em NF, ja vai estar lancado no C197³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aReg1920[nPos1920][14] += (cAliasCDH)->CDH_VALOR
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Conforme cadastro de ajuste manual, quando a terceira posicao do codigo for ³
					//³   0=ICMS e a quarta for 5=Debitos especiais, considero este valor.         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SubStr((cAliasCDH)->CDH_CODLAN,3,1)=="0" .And. SubStr((cAliasCDH)->CDH_CODLAN,4,1)=="5"
						aReg1920[nPos1920][14] += (cAliasCDH)->CDH_VALOR
					EndIf
					
					lGera1921	:=	.T.
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se for ajuste de apuracao precisa lancar no E111³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lOldLan
						cCodAjApur := cUf+"0"+"5"+"9999"
					EndIf
					
				EndIf
				
		EndCase
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|REGISTRO 1921 - AJUSTES/BENEFICIOS/INCENTIVO DA APURACAO DE ICMS            |
		//|                                                                            |
		//³Tratamento para gerar a estrutura do retgistro E111 conforme condicoes acima³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lGera1921
			aAdd(aReg1921, {})
			nPos1921	:=	Len(aReg1921)
			aAdd (aReg1921[nPos1921], nPos1920)						//01 - RELACIONAMENTO
			aAdd (aReg1921[nPos1921], "1921")							//02 - REG
			aAdd (aReg1921[nPos1921], cCodAjApur)						//03 - COD_AJ_APUR
			aAdd (aReg1921[nPos1921], (cAliasCDH)->CDH_DESC)			//04 - DESCR_COMPL_AJ
			aAdd (aReg1921[nPos1921], (cAliasCDH)->CDH_VALOR)			//05 - VL_AJ_APUR
			If !Empty(cExtVer)
				aAdd (aReg1921[nPos1921], (cAliasCDH)->CDH_SUBITE)			//06 - SUBITEM
				
				
				
				//creditos acumulados
				If Alltrim((cAliasCDH)->CDH_SUBITE) $ ("002.20|002.21|007.40|007.41|002.23|007.44|007.45")
					aAdd(aRegT020AG, {})
					nPosT020AG	:=	Len(aRegT020AG)
					aAdd (aRegT020AG[nPosT020AG], (cAliasCDH)->CDH_DESC)						//01 - COD_AUTO
					aAdd (aRegT020AG[nPosT020AG], (cAliasCDH)->CDH_VALOR)						//02 - VALOR
				Endif
			Endif
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REGISTRO 1922 - INFORMACOES ADICIONAIS DOS AJUSTES DE APURACAO DO ICMS³
		//|                                                                      |
		//|Segundo o manuel, eh necessario haver um DA (Documento de arrecadacao |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nPos1921>0 .And. lAchouSF6
			aAdd(aReg1922, {})
			nPos	:=	Len (aReg1922)
			aAdd (aReg1922[nPos], nPos1921)					   			//RELACIONAMENTO COM O E111
			aAdd (aReg1922[nPos], "1922")								//01 - REG
			aAdd (aReg1922[nPos], SF6->F6_NUMERO)						//02 - NUM_DA
			aAdd (aReg1922[nPos], SF6->F6_NUMPROC)						//03 - NUM_PROC
			aAdd (aReg1922[nPos], SF6->F6_INDPROC)						//04 - IND_PROC
			aAdd (aReg1922[nPos], (cAliasCDH)->CDH_DESC)				//05 - PROC
			aAdd (aReg1922[nPos], SF6->F6_DESCOMP)						//06 - TXT_COMPL
			If lExtratTAF
				aAdd (aReg1922[nPos], IIF(Empty(SF6->F6_NUMERO),"",IIF(SF6->F6_TIPOIMP=="0","0","1")))		
			Endif			
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REGISTRO E113: INFORMACOES ADICIONAIS DOS AJUSTES DA APURACAO DO ICMS ³
		//³ IDENTIFICACAO DOS DOCUMENTOS FISCAIS.								 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCmps1923 .And. nPos1921>0 .And. Len(aLanCDA2)>0
			For nX := 1 To Len(aLanCDA2)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Vai percorrer todo o Array aLanCDA2 (Totalizador CDA) em busca dos registro referentes ao Codigo de Ajuste do E111³
				//³e Filtrando por ICMS proprio, terceiro digito do Codigo de Ajuste = 0 e assim Gerar um E113 por documento.		 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If AllTrim(aLanCDA2[nX][1]) == AllTrim(cCodAjApur) .And. SubStr(AllTrim(aLanCDA2[nX][1]),3,1) == "0"
					aAdd(aReg1923, {})
					nPos :=	Len(aReg1923)
					aAdd (aReg1923[nPos], nPos1921)								//RELACIONAMENTO COM O E111
					aAdd (aReg1923[nPos], "1923")								//01 - REG
					aAdd (aReg1923[nPos], aLanCDA2[nX][15])					//02 - COD_PART
					aAdd (aReg1923[nPos], AModNot(aLanCDA2[nX][8]))			//03 - COD_MOD
					aAdd (aReg1923[nPos], aLanCDA2[nX][9])						//04 - SER
					aAdd (aReg1923[nPos], "")									//05 - SUB
					aAdd (aReg1923[nPos], aLanCDA2[nX][10])					//06 - NUM_DOC
					aAdd (aReg1923[nPos], StrZero(Day(aLanCDA2[nX][16]),2)+;
					StrZero(Month(aLanCDA2[nX][16]),2)+;
					StrZero(Year(aLanCDA2[nX][16]),4))	//07 - DT_DOC
					aAdd (aReg1923[nPos], aLanCDA2[nX][13])					//08 - COD_ITEM
					aAdd (aReg1923[nPos], aLanCDA2[nX][5])						//09 - VL_AJ_ITEM
					IF cVersao >= "011"
						aAdd (aReg1923[nPos], aLanCDA2[nX][17])					//10 - CHV_DOCe
					Endif
				EndIf
			Next(nX)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REGISTRO E116 - OPERACOES DO ICMS A RECOLHER - OPERACOES PROPRIAS     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAchouSF6 .And. !Empty((cAliasCDH)->CDH_CODLAN)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Condicao para tratar GNRE(Outros Debito) lancada manualmente na apuracao para gravar registro E116³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (cAliasCDH)->(Len(Alltrim(CDH_CODLAN))==8 .And. SubStr(CDH_CODLAN,4,1)=="0")
				lGera1926	:=	.T.
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Condicao para tratar GNRE(Debito) lancada atraves do NF na apuracao para gravar registro E116 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf (cAliasCDH)->(Len(Alltrim(CDH_CODLAN))==10 .And. SubStr(CDH_CODLAN,3,1)=="4")
				lGera1926	:=	.T.
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Condicao para tratar GNRE(Debitos especiais) gerada pela apuracao atraves de um lancamento    ³
				//| manual ou por NF, para gravar registro E116                                                  |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf	(cAliasCDH)->(Len(Alltrim(CDH_CODLAN))==08 .And.  SubStr(CDH_CODLAN,4,1)=="5") .Or.;		//Manual
				(cAliasCDH)->(Len(Alltrim(CDH_CODLAN))==10 .And.  SubStr(CDH_CODLAN,3,1)=="7")			//Por NF
				lGera1926	:=	.T.
				
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Condicao para tratar GNRE(ICMS a recolher) gerada pela apuracao para gravar registro E116     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf lAchouSF6 .And. (cAliasCDH)->(CDH_LINHA=="GNR" .And. Alltrim(CDH_GNREF3)$"/RECSALDO/RDBESP/RDBESPST/RICDIF/RFECP")
			lGera1926	:=	.T.
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se algumas das condicoes acima mandar gerar a GNRE, faco isso neste momento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lGera1926
			aAdd(aReg1926, {})
			nPos	:=	Len (aReg1926)
			aAdd(aReg1926[nPos], nPos1920)						//01 - RELACIONAMENTO
			aAdd(aReg1926[nPos], "1926")							//01 - REG
			aAdd(aReg1926[nPos], Iif(!SF6->F6_COBREC$"",SF6->F6_COBREC,"000"))		//02 - COD_OR
			aAdd(aReg1926[nPos], SF6->F6_VALOR)						//03 - VL_OR
			aAdd(aReg1926[nPos], SF6->F6_DTVENC)					//04 - DT_VCTO
			aAdd(aReg1926[nPos], SF6->F6_CODREC)					//05 - COD_REC
			aAdd(aReg1926[nPos], "")								//06 - NUM_PROC
			aAdd(aReg1926[nPos], "")								//07 - IND_PROC
			aAdd(aReg1926[nPos], "")								//08 - PROC
			aAdd(aReg1926[nPos], SF6->F6_OBSERV)					//09 - TXT_COMPL
			
			If cVersao >= "004"
				aAdd(aReg1926[nPos],SF6->(StrZero(F6_MESREF,2)+cValToChar(F6_ANOREF)))//10 - MES_REF
			EndIf              

			//Para o extrator fiscal preciso levar o número e o Tipo (0=Doc. Arrecad. 1= GNRE) da GNRE para amarrar no TAF
			if lExtratTAF
				aAdd(aReg1926[nPos], SF6->F6_NUMERO)						//11-Numero da Guia
				aAdd(aReg1926[nPos], IIF(Empty(SF6->F6_NUMERO),"",IIF(SF6->F6_TIPOIMP=="0","0","1")))			
			EndIf			
			
		EndIf
		
		(cAliasCDH)->(dbSkip())
	EndDo	//Fim do processamento da Apuracao de ICMS
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Fecho query ou indregua criada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SPEDFFiltro(2,,cAliasCDH)
Else
	lRet := .F.
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³D195D197  ³ Autor ³Luccas Curcio          ³ Data ³25.07.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³     REGISTRO D195 - OBSERVACOES DO LANCAMENTO FISCAL       ³±±
±±³          ³                    				                          ³±±
±±³          ³REGISTRO D197 - OUTRAS OBRIGACOES TRIBUTARIAS, AJUSTES E    ³±±
±±³          ³                INFORMACOES DE VALORES                      ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao dos Registros D195 e D197              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com o embasamento legal para tais      ³±±
±±³          ³ observacoes                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3(1:N) Para cada D100                                       ³±±
±±³          ³4(1:N) Para cada D195                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          ³nRelac -> Flag de relacionamento com os sub-registros       ³±±
±±³          ³aLanCDA-> Array com os lancamentos da tabela CDA            ³±±
±±³          ³aReg0460-> Array com a estrutura do registro 0460           ³±±
±±³          ³aCmpAntSFT-> Campos da tabela SFT do documento em           ³±±
±±³          ³             processamento                                  ³±±
±±³          ³cEspecie-> Especie do document fiscal                       ³±±
±±³          ³aD195aux-> Array auxiliar com o codigo da observacao do     ³±±
±±³			 ³lancamento fiscal (F4_CODOBSE)           					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function D195D197(cAlias,nRelac,aLanCDA,aReg0460,aCmpAntSFT,cEspecie,aD195aux, lLegisPer)
Local	nPos		:=	0
Local	nPosD195	:=	0
Local	nX			:=	0
Local	nPos195		:=	0
Local	aRegD195	:=	{}
Local	aRegD197	:=	{}
Local	cCodItem	:=	""

Default lLegisPer	:= .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processando lancamentos do documento fiscal relacionados no CDA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to len(aLanCDA)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Campo 04 - Preenchimento: deve ser informado se o ajuste/benefício for relacionado ao servico. Porém, quando não       |
 	//|   houver registro D110 o COD_ITEM nao devera ser informado.												              |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCodItem	:=	""
	If (aCmpAntSFT[26]=="0" .And. cEspecie=="07")
		cCodItem	:=	aLanCDA[nX,13]
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Geracao do REGISTRO D195 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nPosD195 := aScan(aRegD195,{|aX| aX[2]==aLanCDA[nX][07]}))==0
		aAdd(aRegD195, {})
		nPosD195	:=	Len (aRegD195)
		aAdd (aRegD195[nPosD195], "D195")		 	   					//01 - REG
		aAdd (aRegD195[nPosD195], aLanCDA[nX][07])						//02 - COD_OBS
		aAdd (aRegD195[nPosD195], aLanCDA[nX][17])		   				//03 - TXT_COMPL		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REGISTRO 0460 - TABELA DE OBSERVACOES DO LANCAMENTO FISCAL      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Reg0460(@aReg0460,{aLanCDA[nX][7],aLanCDA[nX][20]})
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Geracao do REGISTRO D197 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lLegisPer
			If (nPos := aScan(aRegD197,{|x| x[5]==cCodItem .And. x[3]==aLanCDA[nX,1]}))==0
				aAdd(aRegD197, {})
				nPos	:=	Len (aRegD197)
				aAdd (aRegD197[nPos], nPosD195)									//01 - RELACIONAMENTO COM D195 (PAI)
				aAdd (aRegD197[nPos], "D197")	   								//02 - REG
				aAdd (aRegD197[nPos], aLanCDA[nX,1])				       		//03 - COD_AJ
				aAdd (aRegD197[nPos], aLanCDA[nX][2])					   		//04 - DESCR_COMPL_AJ
				aAdd (aRegD197[nPos], cCodItem)									//05 - COD_ITEM
				aAdd (aRegD197[nPos], aLanCDA[nX][3])							//06 - VL_BC_ICMS
				aAdd (aRegD197[nPos], aLanCDA[nX][4])							//07 - ALIQ_ICMS
				aAdd (aRegD197[nPos], aLanCDA[nX][5])							//08 - VL_ICMS
				aAdd (aRegD197[nPos], aLanCDA[nX][6])							//09 - VL_OUTROS
			Else
			    aRegD197[nPos][6]	+= aLanCDA[nX][3]							//06 - VL_BC_ICMS
				aRegD197[nPos][8]	+= aLanCDA[nX][5]							//08 - VL_ICMS
				aRegD197[nPos][9]	+= aLanCDA[nX][6]							//09 - VL_OUTROS
			EndIf
		EndIf
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Geracao do REGISTRO D195 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aD195aux)  
	IF !(EMPTY(aD195aux[nX][3]))
		If (nPos195 := aScan(aRegD195,{|aX| aX[2]==aD195aux[nX][1]}))==0
			aAdd(aRegD195, {})
			nPos195	:=	Len (aRegD195)
			aAdd (aRegD195[nPos195], "D195")		 	   					//01 - REG
			aAdd (aRegD195[nPos195], aD195aux[nX][1])						//02 - COD_OBS
			aAdd (aRegD195[nPos195], aD195aux[nX][3])		   				//03 - TXT_COMPL
			
			//³REGISTRO 0460 - TABELA DE OBSERVACOES DO LANCAMENTO FISCAL      ³
			Reg0460(@aReg0460,{aD195aux[nX][1],aD195aux[nX][2]})
		Endif
	ENDIF			
Next nX

GrRegDep(cAlias,aRegD195,aRegD197,,,,nRelac)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RegEcfTOP ³ Autor ³ Vendas e CRM          ³ Data ³ 31/01/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua a carga dos arrays dos registros de ECF-Cupom Fiscal ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL (Ambiente TOP)                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegEcfTOP (aRegC400	, aRegC405	, aRegC410	, aRegC420	,;
							aRegC425	, aRegC460	, aRegC470	, aRegC490	,;
							aRegC495	, aProdB1	, dDataDe	, dDataAte	,;
							cPerfil		, cAlias	, aReg0200	, aReg0190	,;
							lCstPis		, lCstCof	, aReg0220	, aReg1600	,;
							aReg0150	, aWizard	, lTop		, cUf	  	,;
							nQtReg0200 , lJob 	, lLegisPer, cNrLivro,;
							aArq 		, lRefazInd)

Do Case
	Case cPerfil == "A"
		
		//-----------------------------
		// Processa Registros Perfil A
		//-----------------------------
		SPDFCFPrfA(	@aRegC400	,	@aRegC405	,	@aRegC410	,	@aRegC420	,;	
						@aRegC425	,	@aRegC460	,	@aRegC470	,	@aRegC490	,;
						@aRegC495	, 	@aProdB1	,	dDataDe		,	dDataAte	,;
						cPerfil		,	cAlias		, 	@aReg0200	,	@aReg0190	,;
						lCstPis		,	lCstCof		,	@aReg0220	,  	@aReg1600	,;
						@aReg0150	,	aWizard		,	lTop		, 	cUf			,;
						@nQtReg0200,	lJob 		, 	lLegisPer	, 	cNrLivro 	,;
						aArq )
		
		lRefazInd := .T. //Seta para que seja reconstruido o indice do TRB
	
	Case cPerfil == "B"
	
		//-----------------------------
		// Processa Registros Perfil B
		//-----------------------------
		SPDFCFPrfB(	@aRegC400	,	@aRegC405	, 	@aRegC410	,	@aRegC420	,;	
						@aRegC425	,	@aRegC460	,	@aRegC470	,	@aRegC490	,;
						@aRegC495	, 	@aProdB1	,	dDataDe		,	dDataAte	,;
						cPerfil		,	cAlias 		, 	@aReg0200	,	@aReg0190	,;
						lCstPis		,	lCstCof		,	@aReg0220	,	@aReg1600	,;
						@aReg0150	,	aWizard		,	lTop		, 		cUf		,;
						@nQtReg0200,	lJob		,	lLegisPer, cNrLivro )
	
	Case cPerfil == "C"
	
		//-----------------------------
		// Processa Registros Perfil C
		//-----------------------------
		SPDFCFPrfC(	@aRegC400	, @aRegC405	, @aRegC410	, @aRegC420	,;
						@aRegC425	, @aRegC460	, @aRegC470	, @aRegC490	,;
						@aRegC495	, @aProdB1		, dDataDe		, dDataAte		,;
						cPerfil		, cAlias		, @aReg0200	, @aReg0190	,;
						lCstPis		, lCstCof		, @aReg0220	, @aReg1600	,;
						@aReg0150	, aWizard		, lTop			, cUf			,;
						@nQtReg0200, lJob			, lLegisPer, cNrLivro )
	
EndCase

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  ³RegD300  ³ Autor ³Simone Oliveira         ³ Data ³30.07.2014      ³±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄ¿±±
±±³Descri‡…o ³     REGISTRO D300 - REGISTRO ANALÍTICO DOS BILHETES              ³±±
±±³          ³     CONSOLIDADOS DE PASSAGEM RODOVIÁRIO (CÓDIGO 13),             ³±±
±±³          ³     DE PASSAGEM AQUAVIÁRIO (CÓDIGO 14), DE PASSAGEM E NOTA       ³±± 
±±³          ³      DE BAGAGEM (CÓDIGO 15) E DE PASSAGEMFERROVIÁRIO             ³±±
±±³          ³     (CÓDIGO 16).                                                 ³±±
±±³          ³                                                                  ³±±
±±³          ³- Geracao do Registro D300                                        ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegD300(aRegD300,cEspecie,cSituaDoc,nRedBSICM,lNotaD300,cAliasSFT,aLanCDA,aReg0460,aLancFis)

Local nPosD300	:= 0
//Local nPos1		:= 0
//Local nPosIt		:= 0
Local nVlOutrDes	:= 0
Local cNotaD300	:= ""
Local lNovo		:= .F.
Local cContCtb	:= RetCOD_CTA(cAliasSFT, "D300")

If Len(AllTrim((cAliasSFT)->FT_NFISCAL)) > 6 .And.  Val(Left(AllTrim((cAliasSFT)->FT_NFISCAL),Len(AllTrim((cAliasSFT)->FT_NFISCAL))-6)) > 0
	lNotaD300   := .F.
EndIf

cNotaD300	:= Right(AllTrim((cAliasSFT)->FT_NFISCAL),6)
nVlOutrDes	:= (cAliasSFT)->(FT_DESPESA-(FT_SEGURO+FT_FRETE))	//Totaliza as outras despesas do documento fiscal. Este tratamento se faz necessario porque FRETE e SEGURO incorporam o valor da despesa no sistema
				

nPosD300 := aScan(aRegD300,{|aX| aX[7]==(cAliasSFT)->FT_CLASFIS .And. aX[8]==(cAliasSFT)->FT_CFOP .And. aX[9]== (cAliasSFT)->FT_ALIQICM .And. ;
		 aX[2]==cEspecie .And. aX[3]==(cAliasSFT)->FT_SERIE .And. aX[10]==(cAliasSFT)->FT_EMISSAO })	
		 
If nPosD300 == 0 .Or. (nPosD300 > 0 .And. cNotaD300 > aRegD300[nPosD300][6] .And. cNotaD300 > aRegD300[Len(aRegD300)][6] .And.;
	 Val(aRegD300[nPosD300][6])+1 <> Val(cNotaD300) )
	lNovo:= .T.
EndIf
	
IF lNovo	
	aAdd(aRegD300, {})
	nPosD300	:=	Len (aRegD300)
	aAdd (aRegD300[nPosD300], "D300")												//01 - REG
	aAdd (aRegD300[nPosD300], cEspecie)							              //02 - COD_MOD
	aAdd (aRegD300[nPosD300], (cAliasSFT)->FT_SERIE)								//03 - SER
	aAdd (aRegD300[nPosD300], "")													//04 - SUB
	aAdd (aRegD300[nPosD300], cNotaD300)											//05 - NUM_DOC_INI 
	aAdd (aRegD300[nPosD300], cNotaD300)											//06 - NUM_DOC_FIN
	aAdd (aRegD300[nPosD300], (cAliasSFT)->FT_CLASFIS)							//07 - CST_ICMS 
	aAdd (aRegD300[nPosD300], (cAliasSFT)->FT_CFOP)								//08 - CFOP 
	aAdd (aRegD300[nPosD300], (cAliasSFT)->FT_ALIQICM)    						//09 - ALIQ_ICMS
	aAdd (aRegD300[nPosD300], (cAliasSFT)->FT_EMISSAO)							//10 - DT_DOC
	aAdd (aRegD300[nPosD300], 0)													//11 - VL_OPR 
	aAdd (aRegD300[nPosD300], 0)													//12 - VL_DESC 
	aAdd (aRegD300[nPosD300], 0)													//13 - VL_SERV
	aAdd (aRegD300[nPosD300], 0)													//14 - VL_SEG
	aAdd (aRegD300[nPosD300], 0)													//15 - VL_OUT DESP
	aAdd (aRegD300[nPosD300], 0)													//16 - VL_BC_ICMS
	aAdd (aRegD300[nPosD300], 0)													//17 - VL_ICMS 
	aAdd (aRegD300[nPosD300], 0)													//18 - VL_RED_BC 
	aAdd (aRegD300[nPosD300], "")													//19 - COD_OBS 
	aAdd (aRegD300[nPosD300], Iif(!Empty(cContCtb),cContCtb,(cAliasSFT)->FT_CONTA))								//20 - COD_CTA
EndIf

If !cSituaDoc$"02#03"	//02=Situacao de cancelada
	aRegD300[nPosD300][11]	+= (cAliasSFT)->FT_VALCONT								//11 - VL_OPR
	aRegD300[nPosD300][12]	+= (cAliasSFT)->FT_DESCONT								//12 - VL_DESC
	aRegD300[nPosD300][13]	+= (cAliasSFT)->FT_TOTAL									//13 - VL_SERV
	aRegD300[nPosD300][14]	+= (cAliasSFT)->FT_SEGURO								//14 - VL_SEG
	aRegD300[nPosD300][15]	+= nVlOutrDes 											//15 - VL_OUT DESP					
	aRegD300[nPosD300][16]	+= (cAliasSFT)->FT_BASEICM								//16 - VL_BC_ICMS
	aRegD300[nPosD300][17]	+= (cAliasSFT)->FT_VALICM								//17 - VL_ICMS
	aRegD300[nPosD300][18]	+= IIf(nRedBSICM < 0, 0 ,nRedBSICM)					//18 - VL_RED_BC
EndIf

//Código observação 
	If Len(aLancFis)>=1
   		aRegD300[nPosD300][19]  := aLancFis[1,1]

		//³REGISTRO 0460 - TABELA DE OBSERVACOES DO LANCAMENTO FISCAL      
   		Reg0460(@aReg0460,{aLancFis[1,1],aLancFis[1,2]})
	EndIf	

//³Range de Numero de Documentos
If cNotaD300 < aRegD300[nPosD300][5]
	aRegD300[nPosD300][5]	:=	cNotaD300		//05 - NUM_DOC_INI
EndIf

If cNotaD300 > aRegD300[nPosD300][6]
	aRegD300[nPosD300][6]	:=	cNotaD300		//06 - NUM_DOC_FIN
EndIf

Return nPosD300

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  ³RegD301  ³ Autor ³Simone Oliveira         ³ Data ³30.07.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³     REGISTRO D301 - DOCUMENTOS CANCELADOS DOS BILHETES     ³±±
±±³          ³     CONSOLIDADOS DE PASSAGEM RODOVIÁRIO (CÓDIGO 13),       ³±±
±±³          ³     DE PASSAGEM AQUAVIÁRIO (CÓDIGO 14), DE PASSAGEM E NOTA ³±± 
±³          ³      DE BAGAGEM (CÓDIGO 15) E DE PASSAGEMFERROVIÁRIO        ³±±
±±³          ³     (CÓDIGO 16).                                           ³±±
±±³          ³- Geracao do Registro D301                                  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegD301(nPosD300,aRegD301,cAliasSFT)

Local	nPosD301	:=	0     
Local 	cNFiscal  	:= Right(AllTrim((cAliasSFT)->FT_NFISCAL),6)

If (nPosD301:= aScan(aRegD301,{|aX| aX[1]==nPosD300 .And. aX[3]==cNFiscal}))==0
	aAdd(aRegD301, {})
	nPosD301	:=	Len (aRegD301)
	aAdd (aRegD301[nPosD301], nPosD300)	 	   		//CHAVE PARA RELACIONAMENTO COM REGISRO PAI
	aAdd (aRegD301[nPosD301], "D301")					//01 - REG
	aAdd (aRegD301[nPosD301], cNFiscal)				//02 - NUM_DOC_CANC
EndIf

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  ³RegD310  ³ Autor ³Simone Oliveira         ³ Data ³30.07.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³    REGISTRO D310 - COMPLEMENTO DOS BILHETES (CÓDIGO 13, 14,³±±
±±³          ³    15 E 16).                                               ³±±
±±³          ³- Geracao e gravacao do Registro D310                       ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegD310(nPosD300,aRegD310,cAliasSFT,cSituaDoc,cAlsSD,lTop)

Local	nPosD310	:=	0     
Local  cMunOrig	:= ""
Local 	cMvD310MUN	:= Alltrim(aSPDSX6[MV_D310MUN])
	         
If lTop
	If (cAliasSFT)->(FieldPos(cMvD310MUN))>0  
		cMunOrig := (cAliasSFT)->(&cMvD310MUN)
	EndIf
Else
	If (cAlsSD)->(FieldPos(cMvD310MUN))>0  
		cMunOrig := (cAlsSD)->(&cMvD310MUN)
	EndIf
EndIf

If cSituaDoc$"02#03"
	cMunOrig:=  Alltrim(SM0->M0_CODMUN)
EndIf
	
If (nPosD310:= aScan(aRegD310,{|aX| aX[1]==nPosD300 .And. aX[3]==cMunOrig}))==0
	aAdd(aRegD310, {})
	nPosD310	:=	Len (aRegD310)
	aAdd (aRegD310[nPosD310], nPosD300)	 	   			//CHAVE PARA RELACIONAMENTO COM REGISRO PAI
	aAdd (aRegD310[nPosD310], "D310")						//01 - REG
	aAdd (aRegD310[nPosD310], cMunOrig)					//02 - COD_MUN_ORIG
	aAdd (aRegD310[nPosD310], 0)							//03 - VL_SERV
	aAdd (aRegD310[nPosD310], 0)							//04 - VL_BC_ICMS
	aAdd (aRegD310[nPosD310], 0)							//05 - VL_ICMS
EndIf

If !cSituaDoc$"02#03"
	aRegD310[nPosD310][4]	+= (cAliasSFT)->FT_TOTAL			//03 - VL_SERV
	aRegD310[nPosD310][5]	+= (cAliasSFT)->FT_BASEICM		//04 - VL_BC_ICMS	
	aRegD310[nPosD310][6]	+= (cAliasSFT)->FT_VALICM		//05 - VL_ICMS
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} REGC800
@description REGISTRO C800: CUPOM FISCAL ELETRÔNICO – SAT (CF-E-SAT) (CÓDIGO 59) - Perfil A
@author Mauro A. Gonçalves 
@since 06/08/2015
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function RegC800(aRegC800,cAliasSFT,cSituaDoc,aPartDoc)
Local cNF  	:= Right(AllTrim((cAliasSFT)->FT_NFISCAL),6)
Local nPos	:= 0 

	If cSituaDoc$"02/03"
		nPos := Ascan(aRegC800, {|x| x[2]=="59" .AND. x[3]==cSituaDoc .AND. x[4]==cNF .AND. x[10]==(cAliasSFT)->FT_SERSAT})
		If nPos == 0 		
			aAdd(aRegC800, {})        
			nPos := Len(aRegC800)                  
			aAdd(aRegC800[nPos], "C800")	 				//01 - REG
			aAdd(aRegC800[nPos], "59")		 				//02 - Modelo
			aAdd(aRegC800[nPos], cSituaDoc)	 				//03 - Sit Doc
			aAdd(aRegC800[nPos], cNF)						//04 - Nr Cupom 
			aAdd(aRegC800[nPos], "")							//05 - Data Cupom         
			aAdd(aRegC800[nPos], "")							//06 - Vl Cupom     
			aAdd(aRegC800[nPos], "")	 						//07 - Vl PIS
			aAdd(aRegC800[nPos], "")					 		//08 - Vl COFINS
			aAdd(aRegC800[nPos], "") 						//09 - CNPJ/CPF dest.
			aAdd(aRegC800[nPos], (cAliasSFT)->FT_SERSAT) 	//10 - Nr Série SAT
			aAdd(aRegC800[nPos], (cAliasSFT)->FT_CHVNFE)	//11 - Chave Cupom
			aAdd(aRegC800[nPos], "")	 						//12 - Vl descontos 
			aAdd(aRegC800[nPos], "")							//13 - Vl merc/serv         
			aAdd(aRegC800[nPos], "")            	 		//14 - Vl despesas/acréscimos     
			aAdd(aRegC800[nPos], "")							//15 - Vl ICMS
			aAdd(aRegC800[nPos], "")					 		//16 - Vl PIS ret ST  ???? (cAliasSFT)->FT_VRETPIS
			aAdd(aRegC800[nPos], "")					   		//17 - Vl COF ret ST  ???? (cAliasSFT)->FT_VRETCOF
		Endif
	Else	
		nPos := Ascan(aRegC800, {|x| x[2]=="59" .AND. x[3]==cSituaDoc .AND. x[4]==cNF .AND. x[10]==(cAliasSFT)->FT_SERSAT .AND. x[5]==(cAliasSFT)->FT_EMISSAO})	
		If nPos == 0 		
			aAdd(aRegC800, {})        
			nPos := Len(aRegC800)                  
			aAdd(aRegC800[nPos], "C800")	 												//01 - REG
			aAdd(aRegC800[nPos], "59")		 												//02 - Modelo
			aAdd(aRegC800[nPos], cSituaDoc)	 												//03 - Sit Doc
			aAdd(aRegC800[nPos], cNF)						 								//04 - Nr Cupom 
			aAdd(aRegC800[nPos], (cAliasSFT)->FT_EMISSAO)									//05 - Data Cupom         
			aAdd(aRegC800[nPos], (cAliasSFT)->FT_VALCONT)								 	//06 - Vl Cupom     
			aAdd(aRegC800[nPos], (cAliasSFT)->FT_VALPIS)									//07 - Vl PIS
			aAdd(aRegC800[nPos], (cAliasSFT)->FT_VALCOF)	 								//08 - Vl COFINS
			aAdd(aRegC800[nPos], Iif(Empty(aPartDoc[04]),aPartDoc[05],aPartDoc[04])) 	//09 - CNPJ/CPF dest.
			aAdd(aRegC800[nPos], (cAliasSFT)->FT_SERSAT)	  							 	//10 - Nr Série SAT
			aAdd(aRegC800[nPos], (cAliasSFT)->FT_CHVNFE)									//11 - Chave Cupom
			aAdd(aRegC800[nPos], (cAliasSFT)->FT_DESCONT)									//12 - Vl descontos 
			aAdd(aRegC800[nPos], (cAliasSFT)->FT_TOTAL)									//13 - Vl merc/serv         
			aAdd(aRegC800[nPos], (cAliasSFT)->FT_DESPESA)	 								//14 - Vl despesas/acréscimos     
			aAdd(aRegC800[nPos], (cAliasSFT)->FT_VALICM)								 	//15 - Vl ICMS
			aAdd(aRegC800[nPos], (cAliasSFT)->FT_VALPS3)	 								//16 - Vl PIS ret ST  ???? (cAliasSFT)->FT_VRETPIS
			aAdd(aRegC800[nPos], (cAliasSFT)->FT_VALCF3)	   								//17 - Vl COF ret ST  ???? (cAliasSFT)->FT_VRETCOF
		Else
			aRegC800[nPos][06] += (cAliasSFT)->FT_VALCONT	//06 - Vl Cupom		   
			aRegC800[nPos][07] += (cAliasSFT)->FT_VALPIS	//07 - Vl PIS     
			aRegC800[nPos][08] += (cAliasSFT)->FT_VALCOF	//08 - Vl COFINS
			aRegC800[nPos][12] += (cAliasSFT)->FT_DESCONT	//12 - Vl descontos
			aRegC800[nPos][13] += (cAliasSFT)->FT_TOTAL	//13 - Vl merc/serv     
			aRegC800[nPos][14] += (cAliasSFT)->FT_DESPESA	//14 - Vl despesas/acréscimos          
			aRegC800[nPos][15] += (cAliasSFT)->FT_VALICM	//15 - Vl ICMS
			aRegC800[nPos][16] += (cAliasSFT)->FT_VALPS3	//16 - Vl PIS ret ST
			aRegC800[nPos][17] += (cAliasSFT)->FT_VALCF3	//17 - Vl COF ret ST     
		EndIf
	EndIf
Return nPos

//-------------------------------------------------------------------
/*/{Protheus.doc} REGC850
@description REGISTRO C850: REGISTRO ANALÍTICO DO CF-E-SAT (CODIGO 59) - Perfil A
@author Mauro A. Gonçalves 
@since 06/08/2015
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function RegC850(nPosC800,aRegC850,cAliasSFT,cSituaDoc,aClasFis)
Local nPos := Ascan(aRegC850, {|x| x[1]==nPosC800 .AND. x[3]==aClasFis[1] .AND. x[4]==(cAliasSFT)->FT_CFOP .AND. x[5]==(cAliasSFT)->FT_ALIQICM})

	If cSituaDoc$"02/03"
		Return .T.
	Endif	

	If nPos == 0 		
		aAdd(aRegC850, {})        
		nPos := Len(aRegC850)                  
		
		aAdd(aRegC850[nPos], nPosC800)					//00 - RELACIONAMENTO
		aAdd(aRegC850[nPos], "C850")				 	//01 - REG
		aAdd(aRegC850[nPos], aClasFis[1]) 				//02 - CST ICMS
		aAdd(aRegC850[nPos], (cAliasSFT)->FT_CFOP)	//03 - CFOP
		aAdd(aRegC850[nPos], (cAliasSFT)->FT_ALIQICM)	//04 - Alíq ICMS 
		aAdd(aRegC850[nPos], (cAliasSFT)->FT_VALCONT)	//05 - Valor CF-e  ????
		aAdd(aRegC850[nPos], (cAliasSFT)->FT_BASEICM)	//06 - Base ICMS     
		aAdd(aRegC850[nPos], (cAliasSFT)->FT_VALICM)	//07 - Valor ICMS
		aAdd(aRegC850[nPos], "")	 						//08 - Código observação

	Else
		aRegC850[nPos][06] += (cAliasSFT)->FT_VALCONT	//06 - Valor total CF-e		   
		aRegC850[nPos][07] += (cAliasSFT)->FT_BASEICM	//07 - Base ICMS     
		aRegC850[nPos][08] += (cAliasSFT)->FT_VALICM	//08 - Valor ICMS
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} REGC860
@description REGISTRO C860: IDENTIFICAÇÃO DO EQUIPAMENTO SAT-CF-E - Perfil B
@author Mauro A. Gonçalves 
@since 06/08/2015
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function RegC860(aRegC860,cAliasSFT,cSituaDoc)
Local cNF	:= Right(AllTrim((cAliasSFT)->FT_NFISCAL),6)
Local nPos	:= aScan(aRegC860, {|aX| aX[2]=="59" .And. aX[3]==(cAliasSFT)->FT_SERSAT})

If cSituaDoc$"02/03"
	Return 0
Endif	

IF nPos == 0
	aAdd(aRegC860, {})        
	nPos := Len(aRegC860)                  
	aAdd(aRegC860[nPos], "C860")					 	//01 - REG
	aAdd(aRegC860[nPos], "59")						 	//02 - Código modelo documento
	aAdd(aRegC860[nPos], (cAliasSFT)->FT_SERSAT)	 	//03 - Nr Série SAT
	aAdd(aRegC860[nPos], (cAliasSFT)->FT_EMISSAO)	 	//04 - Data de emissão
	aAdd(aRegC860[nPos], cNF)							//05 - Número documento inicial         
	aAdd(aRegC860[nPos], cNF)	 						//06 - Número documento final
Else
	If (cAliasSFT)->FT_NFISCAL < aRegC860[nPos][5]
		aRegC860[nPos][5] := cNF
	Endif	
	
	If (cAliasSFT)->FT_NFISCAL > aRegC860[nPos][6]
		aRegC860[nPos][5] := cNF
	Endif	    
Endif
Return nPos

//-------------------------------------------------------------------
/*/{Protheus.doc} REGC890
@description REGISTRO C890: RESUMO DIÁRIO DO CF-E-SAT (CÓDIGO 59) POR EQUIPAMENTO SAT-CF-E - Perfil B
@author Mauro A. Gonçalves
@since 06/08/2015
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function RegC890(nPosC860,aRegC890,cAliasSFT,cSituaDoc,aClasFis)
Local nPos := Ascan(aRegC890, {|x| x[1]==nPosC860 .AND. x[3]==aClasFis[1] .AND. x[4]==(cAliasSFT)->FT_CFOP .AND. x[5]==(cAliasSFT)->FT_ALIQICM})

If cSituaDoc$"02/03"
	Return .t.
Endif	

If nPos == 0 		
	aAdd(aRegC890, {})        
	nPos := Len(aRegC890)                  
	aAdd(aRegC890[nPos], nPosC860)					//00 - RELACIONAMENTO COM REGISTRO PAI
	aAdd(aRegC890[nPos], "C890")	 				//01 - REG
	aAdd(aRegC890[nPos], aClasFis[1])				//02 - CST ICMS
	aAdd(aRegC890[nPos], (cAliasSFT)->FT_CFOP)	//03 - Código CFOP
	aAdd(aRegC890[nPos], (cAliasSFT)->FT_ALIQICM)	//04 - Alíq ICMS 
	aAdd(aRegC890[nPos], (cAliasSFT)->FT_VALCONT)	//05 - Valor CF-e  ????
	aAdd(aRegC890[nPos], (cAliasSFT)->FT_BASEICM)	//06 - Base ICMS     
	aAdd(aRegC890[nPos], (cAliasSFT)->FT_VALICM)	//07 - Valor ICMS
	aAdd(aRegC890[nPos], "")	 						//08 - Código observação
Else
	aRegC890[nPos][06] += (cAliasSFT)->FT_VALCONT	//06 - Valor total CF-e		   
	aRegC890[nPos][07] += (cAliasSFT)->FT_BASEICM	//07 - Base ICMS     
	aRegC890[nPos][08] += (cAliasSFT)->FT_VALICM	//08 - Valor ICMS
EndIf
	
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} ApurDifal
Função para geração do registro E313
@param dDtIni 		- Data inicial de processamento
@param dDtFim 		- Data final de processamento
@param cLivro 		- Livro processado
@param aInfRgE313 - Array com informações de documento com ajuste da apuração
@param cAlias  	- alias do arquivo temporário
@param aMovSemIe  - Array com UF de destino sem IE que tiveram movimentações em C101/D101


@author Erick G Dias
@since 20/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ApurDifal (dDtIni, dDtFim, cLivro, aInfRgE313,cAlias,aMovSemIe,aIcmPago,aT051_300,aT051_310,aT051_311,aT051_312,aT051_313,aT051_316,lExtratTAF)

Local cAliasF0I	:= 'F0I'
Local cSlctF0I	:= ''
Local cFiltro		:= ''
Local cTabela		:= ''
Local aRegE300	:= {}
Local aRegE310	:= {}
Local aRegE311	:= {}
Local aRegE312	:= {}
Local aRegE313	:= {}
Local aRegE316	:= {}
Local nX			:= 0
Local nPosE300	:= 0
Local nIcmPg		:= 0
Local cCodRec		:= ''
Local cMesRef		:= ''   
local nPosUfPg	:= 0
Local cMVSUBTRIB	:=	GetSubTrib("",.T.)//SpedPrSeq("MV_SUBTRI")
Local aUf			:=	UfCodIBGE("",.F.)     
Local lDIFCamp		:= aSPDSX3[FP_F0I_OUTDBF] .And. aSPDSX3[FP_F0I_OUTCRF] .And. aSPDSX3[FP_F0I_DEVFCP] .And. aSPDSX3[FP_F0I_DEDFCP] .And. aSPDSX3[FP_F0I_DBESPF] .And. aSPDSX3[FP_F0I_ESTDBF] .And. aSPDSX3[FP_F0I_ESTCRF]
Local _lVerProc     := Type("oProcess")=="O"
Default aMovSemIe	:= {}                                         
Default lExtratTAF:= .F.                                       

cSlctF0I:= '%'
cSlctF0I+= 'F0I.F0I_DEBDIF,		F0I.F0I_OUTDEB,		F0I.F0I_ESTCRD,		F0I.F0I_OUTCRE,'
cSlctF0I+= 'F0I.F0I_SADIF ,		F0I.F0I_CRDDIF,		F0I.F0I_ESTDEB,		F0I.F0I_DEVDIF,'
cSlctF0I+= 'F0I.F0I_DEDDIF ,	F0I.F0I_DIFREC,		F0I.F0I_SPDIF ,		F0I.F0I_DEBESP,'
cSlctF0I+= 'F0I.F0I_DEBFCP ,	F0I.F0I_SAFCP ,		F0I.F0I_CRDFCP ,		F0I.F0I_FCPREC,'
cSlctF0I+= 'F0I.F0I_SPFCP ,		F0I_UF    '
// Novos campos Difal
IF lDIFCamp
	cSlctF0I+= ', F0I_OUTDBF , F0I_OUTCRF, F0I_DEVFCP, F0I_DEDFCP, F0I_DBESPF, F0I_ESTDBF, F0I_ESTCRF'
Endif

cSlctF0I+= '%'

cTabela := '% ' +RetSqlName('F0I')+ ' F0I %'

cFiltro := "%"
cFiltro += "F0I.F0I_FILIAL= '"+ xFilial('F0I')+ "' AND "
cFiltro += "F0I.F0I_PER>= '" + %Exp:DToS (dDtIni)% + "' AND "
cFiltro += "F0I.F0I_PER<= '" + %Exp:DToS (dDtFim)% + "' AND "
If !lExtratTAF
	cFiltro += "F0I.F0I_LIVRO = '"+ cLivro+ "' AND "
Endif
cFiltro += "F0I.D_E_L_E_T_ = '' "
cFiltro += 'ORDER BY F0I.F0I_UF '
cFiltro += "%"

cAliasF0I	:=	GetNextAlias()
BeginSql Alias cAliasF0I

	SELECT
		%Exp:cSlctF0I%
	FROM
		%Exp:cTabela%
	WHERE
		%Exp:cFiltro%		
EndSql

DbSelectArea (cAliasF0I)
(cAliasF0I)->(DbGoTop ())
Do While !(cAliasF0I)->(Eof ())

	//LGS#20200203 - Adequação de release 12.1.25 e posteriores
	//If Type("oProcess")=="O"
	If _lVerProc
		oProcess:Inc2Progress("Processando apuração Difal do Estado - " + (cAliasF0I)->F0I_UF,"")
	Else
		IncProc("Processando apuração Difal do Estado - " + (cAliasF0I)->F0I_UF)
	EndIf
	
	RegE300310(@aRegE300, @aRegE310, cAliasF0I, dDtIni, dDtFim,'1',(cAliasF0I)->F0I_UF, , ,lExtratTAF,lDIFCamp)	
	
		
	(cAliasF0I)->(DbSkip ())
EndDo
DbSelectArea (cAliasF0I)
(cAliasF0I)->(DbCloseArea())

If Type("oProcess")=="O"
	oProcess:Inc2Progress("Finalizando Apuração Difal " ,"")
Else
	IncProc("Finalizando Apuração Difal " )
EndIf

//Aqui serão processados os ajustes de apuração realizados
For nX:= 1 to Len(aRegE310)
	
	RegE311312 (@aRegE311, @aRegE312, aRegE300[ aRegE310[nX][1] ][2], dDtIni, dDtFim ,cLivro, nX, lExtratTaf)
	
	RegE316(@aRegE316, aRegE300[ aRegE310[nX][1] ][2], dDtIni, dDtFim ,cLivro, nX, lExtratTAF)	

Next nX

For nX	:= 1 to Len(aRegE311)
	
	RegE313(@aRegE313, aInfRgE313, nX, aRegE311[nX][3])

next nX

For nX := 1 to len(aUf)
		
	If At (aUf[nX][1], cMVSUBTRIB)>0	//Se tiver inscricao no estado		
		
		nPosE300 := aScan(aRegE300,{|aX| aX[2]==aUf[nX][1] }) 
		If nPosE300 == 0
			//Se não existir E300 para UF, então será adicionado E300 e E310 com valores zerados
			//e indicador de sem movimentação. Caso existir não fará nenhuma ação
			RegE300310(@aRegE300, @aRegE310, cAliasF0I, dDtIni, dDtFim,'0',aUf[nX][1],,,lExtratTaf,lDIFCamp)
		EndIF
		
	EndIf
	
Next nX

//Ordeno por UF
aIcmPago := Asort(aIcmPago,,,{|x,y|x[1]<y[1]})

For nX := 1 to len(aMovSemIe)		

	If !Empty(aMovSemIe[nX][1])
		
		nPosE300 := aScan(aRegE300,{|aX| aX[2]==aMovSemIe[nX][1] }) 
		If nPosE300 == 0
			//Se não existir E300 para UF, então será adicionado E300 e E310 com valores zerados
			//e indicador de sem movimentação. Caso existir não fará nenhuma ação
			RegE300310(@aRegE300, @aRegE310, cAliasF0I, dDtIni, dDtFim,'0',aMovSemIe[nX][1],aMovSemIe[nX][2],aMovSemIe[nX][3],lExtratTaf,lDIFCamp)
			
			nPosUfPg	:= aScan(aIcmPago,{|aX| aX[1]==aMovSemIe[nX][1] })
			//Gera E316 com as GNRE geradas no documento fiscal
			If nPosUfPg > 0 .AND. nPosUfPg <= Len(aIcmPago)
			
				For nIcmPg	:= nPosUfPg To Len(aIcmPago)
					
					If aIcmPago[nIcmPg][1]==aMovSemIe[nX][1] .AND. aIcmPago[nIcmPg][12] == 'B' //Considera valores do Difal em E316
		
						If SPEDSeek("SF6",1,xFilial("SF6")+aIcmPago[nIcmPg][1]+aIcmPago[nIcmPg][3])
						
							cCodRec	:= Alltrim(SF6->F6_CODREC) + Iif(aIcmPago[nIcmPg][1] $ aSPDSX6[MV_SFUFGNR],Alltrim(SF6->F6_CLAVENC) , '')
							cMesRef	:= Alltrim( STRzero( SF6->F6_MESREF,2 ) ) + Alltrim(STR(SF6->F6_ANOREF))
							nPosE300 := aScan(aRegE300,{|aX| aX[2]==aMovSemIe[nX][1] })
							
							AddE316(@aRegE316,nPosE300,cCodRec,cMesRef, ;
									 SF6->F6_COBREC, SF6->F6_DTVENC , SF6->F6_NUMPROC ,;
									 SF6->F6_INDPROC, SF6->F6_DESCOMP, SF6->F6_OBSERV  ,;
									 SF6->F6_VALOR )
						EndIf		
					
					ElseIf aIcmPago[nIcmPg][1]<>aMovSemIe[nX][1]
						Exit			
					EndIF
				
				Next nIcmPg
			EndIf
			
		EndIF
	EndIF
	
Next nX

If !lExtratTAF
	SPEDRegs(cAlias,{aRegE300,aRegE310,aRegE311,aRegE312,{aRegE313,3},{aRegE316,2}})
Else					
	aT051_300 := aRegE300  
	aT051_310 := aRegE310
	aT051_311 := aRegE311   
	aT051_312 := aRegE312   
	aT051_313 := aRegE313
	aT051_316 := aRegE316
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RegE300310
Função para geração do registro E313
@param aRegE300 	- array com registros E300
@param aRegE310 	- array com registros E310
@param cAliasF0I 	- Alias com informações da tabela F0i apuração do DIFAL
@param dDtIni  	- Data inicial de processamento
@param dDtFim  	- Data final de processamento
@param cIndMov   	- Indicador de movimentação
@param cUf   		- UF processada

@author Erick G Dias
@since 20/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegE300310(aRegE300, aRegE310, cAliasF0I,dDtIni, dDtFim, cIndMov, cUf, nDifSemIe, nFcpSemIe, lExtratTAF,lDIFCamp)

Local nPos	:= 0
Local nE300	:= 0

Default nDifSemIe		:= 0
Default nFcpSemIe		:= 0
Default lExtratTAF		:= .F.
Default	lDIFCamp		:= .F.


//Adiciona registro E300
aAdd(aRegE300, {})
nE300	:=	Len (aRegE300)
aAdd (aRegE300[nE300], "E300")				 				//01 - REG
aAdd (aRegE300[nE300], cUf)	   								//02 - UF
aAdd (aRegE300[nE300], dDtIni)				   				//03 - DT_INI
aAdd (aRegE300[nE300], dDtFim)				   				//04 - DT_FIN

//Adiciona registro E310 filho com valores zerados e com indicador sem movimentação.
aAdd(aRegE310, {})
nPos	:=	Len (aRegE310)
aAdd (aRegE310[nPos], nE300)				 									//Relacionamento com registro Pai
aAdd (aRegE310[nPos], "E310")	//01 - REG

If !lExtratTaf //Monta o array com base no layout da Receita
	aAdd (aRegE310[nPos],'0')  		//02 - IND_MOV_DIFAL
	aAdd (aRegE310[nPos],0)			//03 - VL_SLD_CRED_ANT_DIFAL
	aAdd (aRegE310[nPos],0)	   		//04 - VL_TOT_DEBITOS_DIFAL
	aAdd (aRegE310[nPos],0)			//05 - VL_OUT_DEB_DIFAL
	aAdd (aRegE310[nPos],0)	   		//06 - VL_TOT_DEB_FCP
	aAdd (aRegE310[nPos],0)	   		//07 - VL_TOT_CREDITOS_DIFAL
	aAdd (aRegE310[nPos],0)	   		//08 - VL_TOT_CRED_FCP
	aAdd (aRegE310[nPos],0)			//09 - VL_OUT_CRED_DIFAL
	aAdd (aRegE310[nPos],0)	   		//10 - VL_SLD_DEV_ANT_DIFAÇ
	aAdd (aRegE310[nPos],0)	   		//11 - VL_DEDUCOES_DIFAL
	aAdd (aRegE310[nPos],0)			//12 - VL_RECOL
	aAdd (aRegE310[nPos],0)  		//13 - VL_SLD_CRED_TRANSPORTAR
	aAdd (aRegE310[nPos],0)	   		//14 - DEB_ESP_DIFAL
	
	IF cVersao >= "011"
		aAdd (aRegE310[nPos],0)			//15
		aAdd (aRegE310[nPos],0)			//16
		aAdd (aRegE310[nPos],0)			//17
		aAdd (aRegE310[nPos],0)			//18
		aAdd (aRegE310[nPos],0)			//19
		aAdd (aRegE310[nPos],0)			//20
		aAdd (aRegE310[nPos],0)			//21	
		aAdd (aRegE310[nPos],0)			//22
	Endif

Else //Monta o array com base no Layout do TAF
	aAdd (aRegE310[nPos],0)			//05 - VL_SLD_CRED_ANT_DIFAL = Posicao do array -> 03
	aAdd (aRegE310[nPos],0)			//06 - VL_TOT_DEBITOS_DIFAL = Posicao do array -> 04
	aAdd (aRegE310[nPos],0)			//07 - VL_OUT_DEB_DIFAL = Posicao do array -> 05
	aAdd (aRegE310[nPos],0)			//08 - VL_EST_CRED_DIFAL = Posicao do array -> 06
	aAdd (aRegE310[nPos],0)			//09 - VL_TOT_CREDITOS_DIFAL = Posicao do array -> 07
	aAdd (aRegE310[nPos],0)			//10 - VL_OUT_CRED_DIFAL = Posicao do array -> 08
	aAdd (aRegE310[nPos],0)			//11 - VL_EST_DEB_DIFAL = Posicao do array -> 09
	aAdd (aRegE310[nPos],0)			//12 - VL_SLD_DEV_ANT_DIFAL = Posicao do array -> 10
	aAdd (aRegE310[nPos],0)			//13 - VL_DEDUÇÕES_DIFAL = Posicao do array -> 11
	aAdd (aRegE310[nPos],0)			//14 - VL_RECOL_DIFAL = Posicao do array -> 12
	aAdd (aRegE310[nPos],0) 			//15 - VL_SLD_CRED_TRANSPORTAR_DIFAL = Posicao do array -> 13
	aAdd (aRegE310[nPos],0)			//16 - DEB_ESP_DIFAL = Posicao do array -> 14
	aAdd (aRegE310[nPos],0)        	//17 - VL_SLD_CRED_ANT_FCP = Posicao do array -> 15
	aAdd (aRegE310[nPos],0)			//18 - VL_TOT_DEB_FCP  = Posicao do array -> 16
	aAdd (aRegE310[nPos],0)        	//19 - VL_OUT_DEB_FCP = Posicao do array -> 17
	aAdd (aRegE310[nPos],0)			//20 - VL_EST_CRE_FCP = Posicao do array -> 18
	aAdd (aRegE310[nPos],0)			//21 - VL_TOT_CRED_FCP = Posicao do array -> 19
	aAdd (aRegE310[nPos],0)			//22 - VL_OUT_CRED_FCP = Posicao do array -> 20
	aAdd (aRegE310[nPos],0) 			//23 - VL_EST_DEB_FCP = Posicao do array -> 21
	aAdd (aRegE310[nPos],0)			//24 - VL_SLD_DEV_ANT_FCP = Posicao do array -> 22
	aAdd (aRegE310[nPos],0)			//25 - VL_DEDUÇÕES_FCP = Posicao do array -> 23
	aAdd (aRegE310[nPos],0)			//26 - VL_RECOL_FCP = Posicao do array -> 24
	aAdd (aRegE310[nPos],0)			//27 - VL_SLD_CRED_TRANSPORTAR_FCP = Posicao do array -> 25
	aAdd (aRegE310[nPos],0)			//28 - DEB_ESP_FCP = Posicao do array -> 26

Endif

If nDifSemIe + nFcpSemIe > 0 //Gera operações sem IE
	
	If !lExtratTaf	
		IF cVersao >= "011"
			aRegE310[nPos][3]	:= '1'
			aRegE310[nPos][5]	:= nDifSemIe				//04 - VL_TOT_DEBITOS_DIFAL
			aRegE310[nPos][15]	:= nFcpSemIe				//14 - VL_TOT_DEB_FCP
			aRegE310[nPos][09]	:= nDifSemIe 				//08 - VL_SLD_DEV_ANT_DIFAL
			aRegE310[nPos][19]	:= nFcpSemIe 				//18 - VL_SLD_DEV_ANT_FCP
			aRegE310[nPos][11]	:= nDifSemIe				//10 - VL_RECOL_DIFAL
			aRegE310[nPos][21]	:= nFcpSemIe				//20 - VL_RECOL_FCP 
		Else
			aRegE310[nPos][3]	:= '1'
			aRegE310[nPos][5]	:= nDifSemIe				//04 - VL_TOT_DEBITOS_DIFAL
			aRegE310[nPos][7]	:= nFcpSemIe				//06 - VL_TOT_DEB_FCP
			aRegE310[nPos][11]	:= nDifSemIe + nFcpSemIe	//10 - VL_SLD_DEV_ANT_DIFAL
			aRegE310[nPos][13]	:= nDifSemIe + nFcpSemIe	//12 - VL_RECOL
		Endif
	Else
		aRegE310[nPos][4]	:= nDifSemIe				//06 - VL_TOT_DEBITOS_DIFAL
		aRegE310[nPos][16]	:= nFcpSemIe				//18 - VL_TOT_DEB_FCP
		aRegE310[nPos][10]	:= nDifSemIe 				//12 - VL_SLD_DEV_ANT_DIFAL
		aRegE310[nPos][22]	:= nFcpSemIe				//24 - VL_SLD_DEV_ANT_FCP
		aRegE310[nPos][12]	:= nDifSemIe 				//14 - VL_RECOL_DIFAL
		aRegE310[nPos][24]	:= nFcpSemIe				//26 - VL_RECOL_FCP
	Endif

ElseIf cIndMov == '1'
	
	If !lExtratTaf
		//Se houver apuração para o Estado, então o registro E310 será atualizado com valores
		IF cVersao >= "011"
			aRegE310[nPos][3]	:= cIndMov
			aRegE310[nPos][4]	:= (cAliasF0I)->F0I_SADIF 					//03 - VL_SLD_CRED_ANT_DIFAL
			aRegE310[nPos][5]	:= (cAliasF0I)->F0I_DEBDIF					//04 - VL_TOT_DEBITOS_DIFAL
			aRegE310[nPos][6]	:= (cAliasF0I)->(F0I_OUTDEB + F0I_ESTCRD)	//05 - VL_OUT_DEB_DIFAL
			aRegE310[nPos][7]	:= (cAliasF0I)->F0I_CRDDIF					//06 - VL_TOT_CREDITOS_DIFAL
			aRegE310[nPos][8]	:= (cAliasF0I)->(F0I_OUTCRE + F0I_ESTDEB)	//07 - VL_OUT_CRED_DIFAL
			aRegE310[nPos][9]	:= (cAliasF0I)->F0I_DEVDIF					//08 - VL_SLD_DEV_ANT_DIFAÇ
			aRegE310[nPos][10]	:= (cAliasF0I)->F0I_DEDDIF					//09 - VL_DEDUCOES_DIFAL
			aRegE310[nPos][11]	:= (cAliasF0I)->F0I_DIFREC  				//10 - VL_RECOL_DIFAL
			aRegE310[nPos][12]	:= (cAliasF0I)->F0I_SPDIF   				//11 - VL_SLD_CRED_TRANSPORTAR_DIFAL
			aRegE310[nPos][13]	:= (cAliasF0I)->F0I_DEBESP					//12 - DEB_ESP_DIFAL  
			aRegE310[nPos][14]	:= (cAliasF0I)->F0I_SAFCP 					//13 - VL_SLD_CRED_ANT_FCP		
			aRegE310[nPos][15]	:= (cAliasF0I)->F0I_DEBFCP 						//14 - VL_TOT_DEB_FCP
			aRegE310[nPos][16]	:= IF(lDIFCamp,(cAliasF0I)->(F0I_OUTDBF + F0I_ESTCRF),0)		//15 - VL_OUT_DEB_FCP
			aRegE310[nPos][17]	:= (cAliasF0I)->F0I_CRDFCP 						//16 - VL_TOT_CRED_FCP
			aRegE310[nPos][18]	:= IF(lDIFCamp,(cAliasF0I)->(F0I_OUTCRF + F0I_ESTDBF),0)		//17 - VL_OUT_CRED_FCP
			aRegE310[nPos][19]	:= IF(lDIFCamp,(cAliasF0I)->F0I_DEVFCP,0) 		//18 - VL_SLD_DEV_ANT_FCP
			aRegE310[nPos][20]	:= IF(lDIFCamp,(cAliasF0I)->F0I_DEDFCP,0)		//19 - VL_DEDUÇÕES_FCP
			aRegE310[nPos][21]	:= (cAliasF0I)->F0I_FCPREC						//20 - VL_RECOL_FCP ( 18-19)
			aRegE310[nPos][22]	:= (cAliasF0I)->F0I_SPFCP						//21 - VL_SLD_CRED_TRANSPORTAR_FCP
			aRegE310[nPos][23]	:= IF(lDIFCamp,(cAliasF0I)->F0I_DBESPF,0)		//22 - DEB_ESP_FCP
		Else
			aRegE310[nPos][3]	:= cIndMov
			aRegE310[nPos][4]	:= (cAliasF0I)->F0I_SADIF   + (cAliasF0I)->F0I_SAFCP 		//03 - VL_SLD_CRED_ANT_DIFAL
			aRegE310[nPos][5]	:= (cAliasF0I)->F0I_DEBDIF									//04 - VL_TOT_DEBITOS_DIFAL
			aRegE310[nPos][6]	:= (cAliasF0I)->F0I_OUTDEB  +  (cAliasF0I)->F0I_ESTCRD		//05 - VL_OUT_DEB_DIFAL
			aRegE310[nPos][7]	:= (cAliasF0I)->F0I_DEBFCP									//06 - VL_TOT_DEB_FCP
			aRegE310[nPos][8]	:= (cAliasF0I)->F0I_CRDDIF									//07 - VL_TOT_CREDITOS_DIFAL
			aRegE310[nPos][9]	:= (cAliasF0I)->F0I_CRDFCP									//08 - VL_TOT_CRED_FCP
			aRegE310[nPos][10]	:= (cAliasF0I)->F0I_OUTCRE  + (cAliasF0I)->F0I_ESTDEB		//09 - VL_OUT_CRED_DIFAL
			aRegE310[nPos][11]	:= (cAliasF0I)->F0I_DEVDIF  + (cAliasF0I)->F0I_FCPREC		//10 - VL_SLD_DEV_ANT_DIFAÇ
			aRegE310[nPos][12]	:= (cAliasF0I)->F0I_DEDDIF									//11 - VL_DEDUCOES_DIFAL
			aRegE310[nPos][13]	:= (cAliasF0I)->F0I_DIFREC  + (cAliasF0I)->F0I_FCPREC		//12 - VL_RECOL
			aRegE310[nPos][14]	:= (cAliasF0I)->F0I_SPDIF   + (cAliasF0I)->F0I_SPFCP		//13 - VL_SLD_CRED_TRANSPORTAR
			aRegE310[nPos][15]	:= (cAliasF0I)->F0I_DEBESP									//14 - DEB_ESP_DIFAL  
		Endif 
		
	Else
		aRegE310[nPos][3]	:= (cAliasF0I)->F0I_SADIF					 //05 - VL_SLD_CRED_ANT_DIFAL
		aRegE310[nPos][4]	:= (cAliasF0I)->F0I_DEBDIF      			 //06 - VL_TOT_DEBITOS_DIFAL
		aRegE310[nPos][5]	:= (cAliasF0I)->F0I_OUTDEB					 //07 - VL_OUT_DEB_DIFAL
		aRegE310[nPos][6]	:= (cAliasF0I)->F0I_ESTCRD					 //08 - VL_EST_CRED_DIFAL
		aRegE310[nPos][7]	:= (cAliasF0I)->F0I_CRDDIF					 //09 - VL_TOT_CREDITOS_DIFAL
		aRegE310[nPos][8]	:= (cAliasF0I)->F0I_OUTCRE					 //10 - VL_OUT_CRED_DIFAL
		aRegE310[nPos][9]	:= (cAliasF0I)->F0I_ESTDEB					 //11 - VL_EST_DEB_DIFAL
		aRegE310[nPos][10]	:= (cAliasF0I)->F0I_DEVDIF				 //12 - VL_SLD_DEV_ANT_DIFAL
		aRegE310[nPos][11]	:= (cAliasF0I)->F0I_DEDDIF				 //13 - VL_DEDUÇÕES_DIFAL
		aRegE310[nPos][12]	:= (cAliasF0I)->F0I_DIFREC				 //14 - VL_RECOL_DIFAL
		aRegE310[nPos][13]	:= (cAliasF0I)->F0I_SPDIF 					 //15 - VL_SLD_CRED_TRANSPORTAR_DIFAL
		aRegE310[nPos][14]	:= (cAliasF0I)->F0I_DEBESP					 //16 - DEB_ESP_DIFAL
		aRegE310[nPos][15]	:= (cAliasF0I)->F0I_SAFCP 					 //17 - VL_SLD_CRED_ANT_FCP
		aRegE310[nPos][16]	:= (cAliasF0I)->F0I_DEBFCP					 //18 - VL_TOT_DEB_FCP
		aRegE310[nPos][17]	:= 0         					 			 //19 - VL_OUT_DEB_FCP - Ainda não foi criado o campo para no Protheus, pois será utilizado apenas a partide de 01/01/2017
		aRegE310[nPos][18]	:= 0										 //20 - VL_EST_CRE_FCP
		aRegE310[nPos][19]	:= (cAliasF0I)->F0I_CRDFCP					 //21 - VL_TOT_CRED_FCP 
		aRegE310[nPos][20]	:= 0         					 			 //22 - VL_OUT_CRED_FCP - Ainda não foi criado o campo para no Protheus, pois será utilizado apenas a partide de 01/01/2017
		aRegE310[nPos][21]	:= 0										 //23 - VL_EST_DEB_FCP
		aRegE310[nPos][22]	:= (cAliasF0I)->F0I_FCPREC 	 			 //24 - VL_SLD_DEV_ANT_FCP - Ainda não foi criado o campo para no Protheus, pois será utilizado apenas a partide de 01/01/2017
		aRegE310[nPos][23]	:= 0         								 //25 - VL_DEDUÇÕES_FCP - Ainda não foi criado o campo para no Protheus, pois será utilizado apenas a partide de 01/01/2017
		aRegE310[nPos][24]	:= (cAliasF0I)->F0I_FCPREC					 //26 - VL_RECOL_FCP
		aRegE310[nPos][25]	:= (cAliasF0I)->F0I_SPFCP 					 //27 - VL_SLD_CRED_TRANSPORTAR_FCP
		aRegE310[nPos][26]	:= 0               				 			 //28 - DEB_ESP_FCP - Ainda não foi criado o campo para no Protheus, pois será utilizado apenas a partide de 01/01/2017
	Endif
			 	
EndIF							

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RegE311312
Função para geração do registro E313
@param aRegE311 	- array com registros E311
@param aRegE312 	- array com registros E312
@param cUf 		- UF processada
@param dDtIni  	- Data inicial de processamento
@param dDtFim  	- Data final de processamento
@param cLivro   	- livro processado
@param nPaiE310   - relação com registro pai E310

@author Erick G Dias
@since 20/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegE311312 (aRegE311, aRegE312, cUf, dDtIni, dDtFim ,cLivro, nPaiE310, lExtratTaf)

Local cSlctF0K	:= ''
local cJoin		:= ''
Local cFiltro		:= ''
Local nPosE311	:= 0
Local nPosE312	:= 0
Default lExtratTAF	:= .F.

cSlctF0K:= '%'
cSlctF0K+= 'F0K.F0K_CODAPU,		F0K.F0K_VALOR ,		F0K.F0K_DESCR ,		F0K.F0K_GNRE, '
cSlctF0K+= 'SF6.F6_NUMERO,		SF6.F6_NUMPROC ,		SF6.F6_INDPROC ,		SF6.F6_DESCOMP, SF6.F6_TIPOIMP%'

cJoin	:="LEFT JOIN "+RetSqlName("SF6")+" SF6 ON (SF6.F6_FILIAL='"+xFilial("SF6")+"' AND SF6.F6_EST = F0K.F0K_UF AND SF6.F6_NUMERO=F0K.F0K_GNRE AND SF6.F6_EST=F0K.F0K_UF AND SF6.D_E_L_E_T_=' ')"
cJoin	:= '%' + cJoin + '%' 

cFiltro := "%"
cFiltro += "F0K.F0K_FILIAL		= '"+ xFilial('F0K')+ "' AND "
cFiltro += "F0K.F0K_PER			>= '" + %Exp:DToS (dDtIni)% + "' AND "
cFiltro += "F0K.F0K_PER			<= '" + %Exp:DToS (dDtFim)% + "' AND "
If !lExtratTaf
	cFiltro += "F0K.F0K_LIVRO 		= '"+ cLivro+ "' AND "
Endif
cFiltro += "F0K.F0K_UF 			= '"+ cUf+ "' AND "
cFiltro += "F0K.D_E_L_E_T_		= ' ' "
cFiltro += 'ORDER BY F0K.F0K_UF, F0K.F0K_GNRE '
cFiltro += "%"

cAliasF0K	:=	GetNextAlias()
BeginSql Alias cAliasF0K	

	SELECT
		%Exp:cSlctF0K%
	FROM
		%Table:F0K% F0K
		%Exp:cJoin%
	WHERE
		%Exp:cFiltro%	
			
EndSql

DbSelectArea (cAliasF0K)
(cAliasF0K)->(DbGoTop ())
Do While !(cAliasF0K)->(Eof ())
	
	nPosE311 := aScan(aRegE311,{|aX| aX[1]==nPaiE310 .AND. aX[3]==(cAliasF0K)->F0K_CODAPU})
	If nPosE311 == 0	
		aAdd(aRegE311, {})
		nPosE311	:=	Len (aRegE311)
		aAdd (aRegE311[nPosE311], nPaiE310)				 			//Relacionamento com registro Pai
		aAdd (aRegE311[nPosE311], "E311")				 				//01 - REG	
		aAdd (aRegE311[nPosE311], (cAliasF0K)->F0K_CODAPU)			//02 - COD_AJ_APUR	
		aAdd (aRegE311[nPosE311], (cAliasF0K)->F0K_DESCR)			//03 - DESCR_COMPL_AJ	
		aAdd (aRegE311[nPosE311], (cAliasF0K)->F0K_VALOR)			//04 - VL_AJ_APUR
	Else
		aRegE311[nPosE311][5]	+=  (cAliasF0K)->F0K_VALOR			//04 - VL_AJ_APUR
	EndIF
	
	If !Empty(Alltrim((cAliasF0K)->F0K_GNRE))
		//Irá gerar registro E312
		
		nPosE312 := aScan(aRegE312,{|aX| aX[1]==nPosE311 .AND. aX[3]==(cAliasF0K)->F0K_GNRE})
		If nPosE312 == 0
			//Somente adiciona a GNRE se ainda não existir para este código de lançamento no registro E311
			aAdd(aRegE312, {})
			nPosE312	:=	Len (aRegE312)
			aAdd (aRegE312[nPosE312], nPosE311)				 		//Relacionamento com registro Pai E311
			aAdd (aRegE312[nPosE312], "E312")				 			//01 - REG	
			aAdd (aRegE312[nPosE312], (cAliasF0K)->F6_NUMERO)		//02 - NUM_DA	
			aAdd (aRegE312[nPosE312], (cAliasF0K)->F6_NUMPROC)		//03 - NUM_PROC	
			aAdd (aRegE312[nPosE312], (cAliasF0K)->F6_INDPROC)		//04 - IND_PROC
			aAdd (aRegE312[nPosE312], (cAliasF0K)->F0K_DESCR)		//05 - PROC
			aAdd (aRegE312[nPosE312], (cAliasF0K)->F6_DESCOMP)		//06 - TXT_COMPL
			
			If lExtratTaf
				aAdd(aRegE312[nPosE312], IIF(Empty((cAliasF0K)->F6_NUMERO),"",IIF((cAliasF0K)->F6_TIPOIMP=="0","0","1"))) //07 - COD_DA
			Endif
			
		EndIF
	
	EndIF
		
	(cAliasF0K)->(DbSkip ())
EndDo
DbSelectArea (cAliasF0K)
(cAliasF0K)->(DbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RegE316
Função para geração do registro E313
@param aRegE316 	- array com registros E316
@param cUf 		- UF processada
@param dDtIni 		- Data de início de processamento
@param dDtFim  	- Data final de processamento
@param cLivro  	- número do livro processado
@param nPaiE310   - relação com registro pai E310

@author Erick G Dias
@since 20/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RegE316(aRegE316, cUf, dDtIni, dDtFim ,cLivro, nPaiE310, lExtratTAF)

Local cSlctF0J	:= ''
local cJoin		:= ''
Local cFiltro		:= ''
//Local nPosE311	:= 0
//Local nPosE312	:= 0
Local cCodRec		:= ''
Local cMesRef		:= ''
Local cMvSFUfGnr	:=	aSPDSX6[MV_SFUFGNR]
Default lExtratTAF:= .F.

cSlctF0J:= '%'
cSlctF0J+= 'F0J.F0J_GNRE, 	SF6.F6_CODREC,	SF6.F6_CLAVENC,		SF6.F6_COBREC,		SF6.F6_DTVENC, 	SF6.F6_NUMPROC,'
cSlctF0J+= 'SF6.F6_INDPROC, SF6.F6_DESCOMP , 		SF6.F6_OBSERV,  	   SF6.F6_MESREF, 	SF6.F6_ANOREF, SF6.F6_VALOR, SF6.F6_NUMERO, SF6.F6_TIPOIMP'
cSlctF0J+= '%'

cJoin	+="%INNER JOIN "+RetSqlName("SF6")+" SF6 ON (Sf6.F6_FILIAL='"+xFilial("SF6")+"' AND SF6.F6_EST = F0J.F0J_UF AND SF6.F6_NUMERO=F0J.F0J_GNRE AND SF6.F6_EST=F0J.F0J_UF AND SF6.D_E_L_E_T_=' ') "
cJoin 	+= '%'

cFiltro := "%"
cFiltro += "F0J.F0J_FILIAL		= '"	+ xFilial('F0J')		+ "' AND "
cFiltro += "F0J.F0J_PER			>= '" 	+ %Exp:DToS (dDtIni)% 		+ "' AND "
cFiltro += "F0J.F0J_PER			<= '" 	+ %Exp:DToS (dDtFim)% 		+ "' AND "
If !lExtratTAF
	cFiltro += "F0J.F0J_LIVRO 		= '"	+ cLivro						+ "' AND "
Endif
cFiltro += "F0J.F0J_UF 			= '"	+ cUf							+ "' AND "
cFiltro += "F0J.F0J_TIPO 		IN	   ('1','2','3')							 AND " //Traz somente guias geradas a pagar do FECP e do DIFAL
cFiltro += "F0J.D_E_L_E_T_		= '' "
cFiltro += 'ORDER BY F0J.F0J_UF, F0J.F0J_GNRE '
cFiltro += "%"

cAliasF0J	:=	GetNextAlias()
BeginSql Alias cAliasF0J
	COLUMN F6_DTVENC AS DATE
	SELECT
		%Exp:cSlctF0J%
	FROM
		%Table:F0J% F0J
		%Exp:cJoin%
	WHERE
		%Exp:cFiltro%		
EndSql

DbSelectArea (cAliasF0J)
(cAliasF0J)->(DbGoTop ())
Do While !(cAliasF0J)->(Eof ())	
	cCodRec	:= Alltrim((cAliasF0J)->F6_CODREC) + Iif(cUf $ cMvSFUfGnr,Alltrim((cAliasF0J)->F6_CLAVENC) , '')
	cMesRef	:= Alltrim( STRzero( (cAliasF0J)->F6_MESREF,2 ) ) + Alltrim(STR((cAliasF0J)->F6_ANOREF))
		
	AddE316(@aRegE316,nPaiE310,cCodRec,cMesRef, ;
			 (cAliasF0J)->F6_COBREC, (cAliasF0J)->F6_DTVENC , (cAliasF0J)->F6_NUMPROC ,;
			 (cAliasF0J)->F6_INDPROC, (cAliasF0J)->F6_DESCOMP, (cAliasF0J)->F6_OBSERV  ,;
			 (cAliasF0J)->F6_VALOR, (cAliasF0J)->F6_NUMERO,lExtratTAF,(cAliasF0J)->F6_TIPOIMP) 	

		
	(cAliasF0J)->(DbSkip ())
	
EndDo
DbSelectArea (cAliasF0J)
(cAliasF0J)->(DbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddE316
Função que adiciona novo registro E316.

@author Erick G Dias
@since 04/02/2016
@version 11.80
/*/
//-------------------------------------------------------------------

Static Function AddE316(aRegE316,nPaiE310,cCodRec,cMesRef, cCOBREC, cDTVENC , cNUMPROC ,cINDPROC, cDESCOMP, cOBSERV ,nVALOR,cNunGnre,lExtratTaf, cTPimp )

Local nPosE316	:= 0  
nPosE316 := aScan(aRegE316,{|aX| aX[1] ==nPaiE310 	.AND. ;
								  aX[3] ==cCOBREC 	.AND. ;
								  aX[5] ==cDTVENC 	.AND. ;
								  aX[6] ==cCodRec    .AND. ;
								  aX[7] ==cNUMPROC 	.AND. ;
								  aX[8] ==cINDPROC 	.AND. ;
								  aX[9] ==cDESCOMP 	.AND. ;
								  aX[10]==cOBSERV 	.AND. ;										  										  										  										  										  
								  aX[10]==cMesRef  })
If nPosE316 == 0	
	aAdd(aRegE316, {})
	nPosE316	:=	Len (aRegE316)
	aAdd (aRegE316[nPosE316], nPaiE310)				//Relacionamento com registro Pai
	aAdd (aRegE316[nPosE316], "E316")					//01 - REG	
	aAdd (aRegE316[nPosE316], cCOBREC)				//02 - COD_OR	
	aAdd (aRegE316[nPosE316], nVALOR)				//03 - VL_OR	
	aAdd (aRegE316[nPosE316], cDTVENC)				//04 - DT_VCTO
	aAdd (aRegE316[nPosE316], cCodRec)				//05 - COD_REC
	aAdd (aRegE316[nPosE316], cNUMPROC)			//06 - NUM_PROC
	aAdd (aRegE316[nPosE316], cINDPROC)			//07 - IND_PROC
	aAdd (aRegE316[nPosE316], cDESCOMP)			//08 - PROC
	aAdd (aRegE316[nPosE316], cOBSERV)				//09 - TXT_COMPL
	aAdd (aRegE316[nPosE316], cMesRef )			//10 - MES_REF
	If lExtratTaf
		aAdd (aRegE316[nPosE316], IIF(cTPimp=="0","0","1"))  //12 - COD_DA
		aAdd (aRegE316[nPosE316], cNunGnre)					//13 - NUM_DA
		aAdd (aRegE316[nPosE316], cNUMPROC)					//14 - NUM_PROC
		aAdd (aRegE316[nPosE316], cINDPROC)					//15 - IND_PROC
	Endif
Else
	If !lExtratTaf
		aRegE316[nPosE316][4]	+= nVALOR				//03 - VL_OR	
	Endif
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RegE313
Função para geração do registro E313
@param aRegE313 - array com registros E313
@param aInfE313 - Array com informações do documento fiscal que possui ajuste de apuração
@param nPaiE311 - Relação com registro pai E311
@param cCodAju  - código de ajuste da apuração

@author Erick G Dias
@since 20/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function RegE313(aRegE313, aInfE313, nPaiE311, cCodAju)

Local nPosE313	:= 0
local nPosNfE313	:= 0
Local nX			:= 0

nPosNfE313 := aScan(aInfE313,{|aX| aX[2]==cCodAju })

If nPosNfE313 > 0

	For nX	:= nPosNfE313 to Len(aInfE313)
	
		If aInfE313[nX][2] == cCodAju
			nPosE313 := aScan(aRegE313,{|aX| aX[1 ]==nPaiE311        .AND. ;
												 aX[3 ]==aInfE313[nX][3 ] .AND.;
												 aX[4 ]==aInfE313[nX][4 ] .AND.;
												 aX[5 ]==aInfE313[nX][5 ] .AND.;
												 aX[7 ]==aInfE313[nX][6 ] .AND.;
												 aX[8 ]==aInfE313[nX][7 ] .AND.;
												 aX[9 ]==aInfE313[nX][8 ] })
												 //aX[10]==aInfE313[nX][9] })
			
			If nPosE313 == 0
			
				aAdd(aRegE313, {})
				nPosE313	:=	Len (aRegE313)
				aAdd (aRegE313[nPosE313], nPaiE311)			//Relacionamento com registro Pai
				aAdd (aRegE313[nPosE313], "E313")				//01 - REG	
				aAdd (aRegE313[nPosE313], aInfE313[nX][3 ])	//02 - COD_PART	
				aAdd (aRegE313[nPosE313], aInfE313[nX][4 ])	//03 - COD_MOD
				aAdd (aRegE313[nPosE313], aInfE313[nX][5 ])	//04 - SER
				aAdd (aRegE313[nPosE313], '')					//05 - SUB
				aAdd (aRegE313[nPosE313], aInfE313[nX][6 ])	//06 - NUM_DOC
				aAdd (aRegE313[nPosE313], aInfE313[nX][7 ])	//07 - CHV_DOCE
				aAdd (aRegE313[nPosE313], aInfE313[nX][8 ])	//08 - DT_DOC
				aAdd (aRegE313[nPosE313], ''/*aInfE313[nX][9]*/)	//09 - COD_ITEM
				aAdd (aRegE313[nPosE313], aInfE313[nX][10])	//10 - VL_AJ_ITEM			
			Else
				aRegE313[nPosE313][11] += aInfE313[nX][10]		//10 - VL_AJ_ITEM
			EndIf
				
		Else
			Exit
		EndIF
	
	Next nX
EndIF

Return

Static Function RetCOD_CTA(cAlias, cReg, aCmpAntSFT )
Local 		cCod_Cta 		:= ""
Default 	cAlias 		:= ""
Default	cReg			:= ""
Default	aCmpAntSFT 	:= {}
If Len(aExistBloc) >= 28 .And. aExistBloc[28] .And. !Empty(cAlias)  .And. cReg $ "C170|C300|C350|D100|D300"
   
   cCod_Cta := ExecBlock("SPDFIS27", .F., .F., {cReg,;
   							(cAlias)->FT_FILIAL,;
							(cAlias)->FT_TIPOMOV,;
							(cAlias)->FT_SERIE,;
							(cAlias)->FT_NFISCAL,;
							(cAlias)->FT_CLIEFOR,;
							(cAlias)->FT_LOJA,;
							(cAlias)->FT_ITEM,;
							(cAlias)->FT_PRODUTO}) 
     

ElseIf Len(aExistBloc) >= 28 .And. aExistBloc[28] .And. !Empty(cAlias) .And. cReg == "0300"
	cCod_Cta := ExecBlock("SPDFIS27", .F., .F., {cReg,;
   							(cAlias)->FA_FILIAL,;
							(cAlias)->FA_CODIGO,;
							(cAlias)->FA_DATA,;
							(cAlias)->FA_TIPO}) 
							
ElseIF Len(aExistBloc) >= 28 .And. aExistBloc[28] .And. !Empty(aCmpAntSFT) .And. cReg == "D500"
	Cod_Cta := ExecBlock("SPDFIS27", .F., .F., {cReg,;
   							aCmpAntSFT[22],; // FT_FILIAL
							aCmpAntSFT[43],; //FT_TIPOMOV
							aCmpAntSFT[2],;  //FT_SERIE
							aCmpAntSFT[1],;  //FT_NFISCAL
							aCmpAntSFT[3],;  //FT_CLIEFOR
							aCmpAntSFT[4],;  //FT_LOJA
							aCmpAntSFT[46],; //FT_ITEM
							aCmpAntSFT[45]})  //FT_PRODUTO

EndIf


Return cCod_Cta

//-------------------------------------------------------------------
/*/{Protheus.doc} SpdGnreDoc
Função responsável por alimentar o array aIcmPago com as informacoes das
GNREs geradas e vinculadas aos documentos fiscais. Estas informacoes
serao utilizadas na geracao dos registros E250 e E316.

@author Joao Victor Pellegrini
@since 05/05/2016
/*/
//-------------------------------------------------------------------
Static Function SpdGnreDoc(aIcmPago, cAliasSF6, cAliasCDC, cCDCChv)

DEFAULT cCDCChv := ""

// Caso nao seja passado o parametro da chave da tabela CDC, nao irei percorrer
// os registros e adicionarei as informacoes com base nos registros ja posicionados.

If !Empty(cCDCChv)
	While !(cAliasCDC)->(Eof()) .AND. ((cAliasCDC)->(CDC_FILIAL+CDC_TPMOV+CDC_DOC+CDC_SERIE+CDC_CLIFOR+CDC_LOJA)==cCDCChv)
		If SpedSeek( cAliasSF6,1,xFilial(cAliasSF6)+(cAliasCDC)->(CDC_UF+CDC_GUIA)) 
			aAdd(aIcmPago,{(cAliasCDC)->CDC_UF,;
							(cAliasSF6)->F6_VALOR,;
							(cAliasCDC)->CDC_GUIA,;
							(cAliasSF6)->F6_DTVENC,;
							(cAliasSF6)->F6_CODREC,;
							(cAliasSF6)->F6_OBSERV,;
							(cAliasSF6)->F6_MESREF,;
							(cAliasSF6)->F6_ANOREF,;
							(cAliasSF6)->F6_NUMPROC,;
							(cAliasSF6)->F6_INDPROC,;
							(cAliasSF6)->F6_DESCOMP,;
							(cAliasSF6)->F6_TIPOIMP})
		EndIf
		(cAliasCDC)->(DbSkip())
	Enddo	
Else
	If SpedSeek( cAliasSF6,1,xFilial(cAliasSF6)+(cAliasCDC)->(CDC_UF+CDC_GUIA)) 
		aAdd(aIcmPago,{(cAliasCDC)->CDC_UF,;
						(cAliasSF6)->F6_VALOR,;
						(cAliasCDC)->CDC_GUIA,;
						(cAliasSF6)->F6_DTVENC,;
						(cAliasSF6)->F6_CODREC,;
						(cAliasSF6)->F6_OBSERV,;
						(cAliasSF6)->F6_MESREF,;
						(cAliasSF6)->F6_ANOREF,;
						(cAliasSF6)->F6_NUMPROC,;
						(cAliasSF6)->F6_INDPROC,;
						(cAliasSF6)->F6_DESCOMP,;
						(cAliasSF6)->F6_TIPOIMP})
	EndIf
EndIf

Return nil

/*/{Protheus.doc} RetStSpd
Função responsável por retornar o valor do ICMS ST validando o parâmetro MV_RESF3FT
@author Henrique Pereira
@since 27/07/2016
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Apesar dos valores de SF3 e SFT serem os mesmos, a gravacao das tabelas nao sao,|
//|e se for considerado os campos correspondentes, os valores apresentados serao   |
//|diferentes, e para resolver isso preciso temos que saber qual tabela esta sendo |
//|considerada na apuracao de ICMS, para isso faco o tratamento abaixo.            |
//|Se o parametro MV_RESF3FT estiver configurado para considerar a tabela SFT,     |
//| tenho que somar os campos de retido+isento+outros, pois nao eh gravado conforme|
//| conforme a SF3, que grava sempre o ICMS retido independente da escrituracao.   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/

Static Function RetStSpd(lResF3FT, cAliasSFT)
Local nRet := 0
Default lResF3FT := .F.
Default cAliasSFT := ''

	If lResF3FT .And. !Empty(cAliasSFT)
		//Na tabela SFT o valor de ICMS Retido pode alternar nas colunas dependendo da escrituracao
		nRet := 	(cAliasSFT)->(FT_ICMSRET+FT_OUTRRET+FT_ISENRET)
						
	Else
		//Na tabela SF3 o valor do ICMS Retido sempre eh gravado em ICMSRET, independente da escrituracao
		nRet := 	(cAliasSFT)->(FT_ICMSRET)
						
	EndIf

Return nRet

//-------------------------------------------------------------------
/*/
{Protheus.doc} AddHash

@author Graziele Mendonça Paro
@since 02.12.2016
/*/
//-------------------------------------------------------------------

Static Function AddHash(oHash,cChave,nPos)
Local cSet  := "HMSet"

&cSet.(oHash, cChave, nPos)

Return

//-------------------------------------------------------------------
/*/
{Protheus.doc} AddHash

@author Graziele Mendonça Paro
@since 02.12.2016

/*/
//-------------------------------------------------------------------

Static Function FindHash(oHash, cChave)

Local nPosRet   := 0
Local cGet    := "HMGet"

&cGet.( oHash , cChave  , @nPosRet )

Return nPosRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SpedBanner

( SOMENTE BRASIL ) Funcao responsabe para efetuar a chamada de um banner para a rotina

@param Nil

@return Nil

@author Gustavo G. Rueda
@since 09/09/2016
/*/
//-------------------------------------------------------------------
/*Static Function SpedBanner()

If cPaisLoc == 'BRA' .And. FindFunction( 'FISBannerTAF' )
	FISBannerTAF()
Endif
	
Return*/

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SPEDQryPri| Autor ³Gustavo G. Rueda  			   ³ Data ³24.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao que retorna o valor de reducao da base de calculo do ICMS   ³±±
±±³          ³ utilizando a regra convencional (SENTO/OUTROS/BASE) ou recalcu-   ³±±
±±³          ³ conforme percentual de reducao gravada na tabela CD2              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                   ³±±
±±³          ³nOpc      -> Opcao de utilizacao da funcao, 1 eh para retornar um  ³±±
±±³          ³             reccount de registros e dieferente de 1 eh para retor-³±±
±±³          ³             nar as informacoes.                                   ³±±
±±³          ³cTpMov    -> Tipo de movimentacao, E=Entrada, S=Saida              ³±±
±±³          ³dDataDe   -> Data inicial do periodo                               ³±±
±±³          ³dDataAte  -> Data final do periodo                                 ³±±
±±³          ³lCstPis   -> Flag de existencia de campo FT_CSTPIS                 ³±±
±±³          ³lCstCof   -> Flag de existencia do campo FT_CSTCOF                 ³±±
±±³          ³aF2EspVol -> Array com os campos da tabela F2 de volume/especie    ³±±
±±³          ³lTabComp  -> Flag de existencia das tabelas do SPED Fiscal         ³±±
±±³          ³lIntTMS   -> Flag que identifica a integracao com o TMS            ³±±
±±³          ³cNrLivro  -> Numero do livro de processamento selecionado no wizard³±±
±±³          ³cAliasSFT -> Alias da tabela SFT a ser retornada por referencia    ³±±
±±³          ³lTabCD0   -> Flag de existencia da tabela CD0 - Compl Ressarcimento³±±
±±³          ³lTabCD1   -> Flag de existencia da tabela CD1 - Natureza Oper/Prest³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1 - 0=Nao tem movimento e maior que ZERO identifica com movimto³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SPEDQryPri(nOpc,cTpMov,dDataDe,dDataAte,lCstPis,lCstCof,aF2EspVol,lTabComp,lIntTMS,cNrLivro,cAliasSFT,lTabCD1)
Local	cFiltro			:=	""
Local	cSlctSFT 		:=	""
Local 	cSlctSF3		:= ""
Local	cSlctF1F2		:=	""
Local	cScan 			:= 	"1"
Local	cSlctD1D2		:=	""
Local	cSlctA1			:=	""
Local	cSlctA2			:=	""
Local	cSlctA4			:=	""
Local	cSlctClient		:=	""
Local	cSlctF4			:=	""
Local	cSlct			:=	""
Local	cSlctAll		:=	""
Local	cJoinF3			:=	""
Local	cJoinD1D2		:=	""
Local	cJoinF1F2		:=	""
Local	cJoinSF4		:=	""
Local	cJoinSA4		:=	""
Local	cJoinCompl		:=	""
Local	nRecCount		:=	0
Local	cOrderBy		:=	"%%"
Local	cSlvAlias		:=	cAliasSFT
Local 	cMVDTINCB1		:= AllTrim(aSPDSX6[MV_DTINCB1])
Local	cPRDPRIB5		:= AllTrim(aSPDSX6[MV_PRDPRI])
Local	aFieldDt		:=	{}
Local	nX				:=	0
Local 	cApurSep		:=	Alltrim(aSPDSX6[MV_APUSEP])
Local	aApurSep		:=	{}
Local	nPos			:=	0
Local	cApur			:=	""
Local 	cMvD310MUN		:= Alltrim(aSPDSX6[MV_D310MUN])

For nPos := 1 to Len(cApurSep)
	cApur := Substr(cApurSep,nPos,1)
	If cApur$"123456789" .And. aScan(aApurSep, {|x| x==cApur})==0
		aAdd(aApurSep, cApur)
	EndIf
Next nPos

DbSelectArea (cAliasSFT)
(cAliasSFT)->(DbSetOrder(2))

#IFDEF TOP
    If (TcSrvType ()<>"AS/400")
    	cFiltro := "%"
		If cNrLivro <> "*"
			If Len(aApurSep)>0
				cFiltro += " ( "
				For nX := 1 To Len(aApurSep)
					cFiltro += " SFT.FT_NRLIVRO = '" +%Exp:(aApurSep[nX])% +"' OR "
				Next nX
				cFiltro += " SFT.FT_NRLIVRO = '" +%Exp:(cNrLivro)% +"' ) AND "
			Else
				cFiltro += " SFT.FT_NRLIVRO = '" +%Exp:(cNrLivro)% +"' AND "
			EndIf
		EndIf
		cFiltro += "%"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Montagem do SELECT FULL em uma unica variavel, pois hora pode ser o SELECT³
		//³  normal e hora pode ser um SELECT COUNT()                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpc==1
			cSlctAll	:=	"COUNT(*) SFTCOUNT"
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Campos da tabela SFT³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSlctSFT := "SFT.FT_FILIAL,  SFT.FT_TIPOMOV,	SFT.FT_ENTRADA, SFT.FT_SERIE,   SFT.FT_NFISCAL, SFT.FT_CLIEFOR,"
			cSlctSFT += "SFT.FT_LOJA,    SFT.FT_ITEM,   	SFT.FT_PRODUTO, SFT.FT_NRLIVRO, SFT.FT_CFOP,    SFT.FT_ESPECIE, "
			cSlctSFT += "SFT.FT_TIPO,    SFT.FT_EMISSAO,	SFT.FT_DTCANC,  SFT.FT_FORMUL,  SFT.FT_ALIQPIS, SFT.FT_VALPIS, "
			cSlctSFT += "SFT.FT_ALIQCOF, SFT.FT_VALCOF, 	SFT.FT_VALCONT, SFT.FT_BASEICM, SFT.FT_VALICM,  SFT.FT_ISSST, "
			cSlctSFT += "SFT.FT_BASERET, SFT.FT_ICMSRET,	SFT.FT_VALIPI,  SFT.FT_ISENICM, SFT.FT_QUANT,   SFT.FT_DESCONT, "
			cSlctSFT += "SFT.FT_TOTAL,   SFT.FT_FRETE,  	SFT.FT_SEGURO,  SFT.FT_DESPESA, SFT.FT_OUTRICM, SFT.FT_BASEIPI, "
			cSlctSFT += "SFT.FT_ISENIPI, SFT.FT_OUTRIPI,	SFT.FT_ICMSCOM, SFT.FT_RECISS,  SFT.FT_BASEIRR, SFT.FT_ALIQICM, "
			cSlctSFT += "SFT.FT_ALIQIPI, SFT.FT_CTIPI,  	SFT.FT_POSIPI,  SFT.FT_CLASFIS, SFT.FT_PRCUNIT, SFT.FT_CFPS, "
			cSlctSFT += "SFT.FT_OBSERV,  SFT.FT_ESTADO, 	SFT.FT_CODISS,  SFT.FT_ALIQIRR, SFT.FT_VALIRR,  SFT.FT_BASEINS, "
			cSlctSFT += "SFT.FT_VALINS,  SFT.FT_PDV,    	SFT.FT_ISSSUB,  SFT.FT_CREDST,  SFT.FT_ISENRET, SFT.FT_OUTRRET, "
			cSlctSFT += "SFT.FT_CONTA,   SFT.FT_BASEPIS,	SFT.FT_BASECOF, SFT.FT_PESO,    SFT.FT_SOLTRIB, SFT.FT_NFORI, "
			cSlctSFT += "SFT.FT_SERORI,  SFT.FT_ITEMORI,	SFT.FT_IDENTF3, SFT.FT_OBSSOL, 	SFT.FT_FORMULA, SFT.FT_CLIENT, SFT.FT_LOJENT"
			cSlctSFT += ", SFT.FT_CHVNFE"
			If SerieNfId("SFT",3,"FT_SERIE") == "FT_SDOC"
				cSlctSFT += ", SFT.FT_SDOC"
			EndIf
			If lCstPis
				cSlctSFT += ", SFT.FT_CSTPIS"
			EndIf
			If lCstCof
				cSlctSFT += ", SFT.FT_CSTCOF"
			EndIf
			cSlctSFT += ", SFT.FT_PAUTPIS"
			cSlctSFT += ", SFT.FT_PAUTCOF"
			cSlctSFT += ", SFT.FT_VALPS3"
			cSlctSFT += ", SFT.FT_VALCF3"
			cSlctSFT += ", SFT.FT_RGESPST"
			cSlctSFT += ", SFT.FT_PAUTIPI"
			cSlctSFT += ", SFT.FT_DESCZFR"
			cSlctSFT += ", SFT.FT_AGREG"
			cSlctSFT += ", SFT.FT_DESCICM"
			cSlctSFT += ", SFT.FT_NORESP"
			cSlctSFT += ", SFT.FT_NATOPER"
			cSlctSFT += ", SFT.FT_MVALCOF , SFT.FT_MALQCOF "	
			cSlctSFT += ", SFT.FT_ALIQSOL"	
			cSlctSFT += iif(SFT->(ColumnPos( "FT_SERSAT" )), ", SFT.FT_SERSAT" , "")
			
			If SFT->(ColumnPos('FT_DIFAL')) > 0
				cSlctSFT += ", SFT.FT_DIFAL"
			EndIF			
			If SFT->(ColumnPos('FT_VFCPDIF')) > 0
				cSlctSFT += ", SFT.FT_VFCPDIF"			
			EndIF
			If aSPDSX3[FP_FT_CSOSN] 
				cSlctSFT += ", SFT.FT_CSOSN"
			Endif						
			
			cSlctSFT 	+= ","
			
			aAdd(aFieldDt,"FT_EMISSAO")
			aAdd(aFieldDt,"FT_ENTRADA")
			aAdd(aFieldDt,"FT_DTCANC")
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Campos para o SELECT da tabela SB1³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSlctSB1	:=	"SB1.B1_UM,      SB1.B1_SELO,    SB1.B1_TAB_IPI, SB1.B1_VLR_IPI, SB1.B1_TIPO,    SB1.B1_DESC, "
			cSlctSB1	+=	"SB1.B1_CODBAR,  SB1.B1_CODANT,  SB1.B1_POSIPI,  SB1.B1_EX_NCM,  SB1.B1_CODISS,  SB1.B1_PICM, "
			cSlctSB1	+=	"SB1.B1_FECP,    SB1.B1_CC,		 SB1.B1_SEGUM,   SB1.B1_TIPCONV, SB1.B1_CONV,    SB1.B1_VLR_PIS, "
			cSlctSB1	+=	"SB1.B1_VLR_COF, SB1.B1_CLASSE,  SB1.B1_CONTA,   SB1.B1_ORIGEM, SB1.B1_IMPORT,    SB1.B1_DATREF, SB1.B1_COD,"
			
			If aSPDSX3[FP_B1_CEST]
				cSlctSB1	+=	"SB1.B1_CEST,"
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tratamento para um campo da tabela SB1 que podera ser utilizado no processamento, ³
			//³  este campo deve estar na query                                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If "B1_"$cMVDTINCB1
				If SB1->(FieldPos(cMVDTINCB1))>0
					cSlctSB1	+=	cMVDTINCB1+","
					aAdd(aFieldDt,cMVDTINCB1)
				EndIf
			EndIf
			
			If !Empty(cPRDPRIB5)
				If SB5->(FieldPos(cPRDPRIB5))>0
					cSlctSB1	+=	"SB5."+cPRDPRIB5+","
				Endif
			Endif		
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Campos para o SELECT da tabela SF2 ou SF1³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aF2EspVol	:=	{}
			cSlctF1F2	:=	""
			If cTpMov=="E"				
				cSlctF1F2	+=	"SF1.F1_FRETE, SF1.F1_COND, SF1.F1_TIPO, SF1.F1_FORMUL, SF1.F1_ESPECIE, SF1.F1_DOC, SF1.F1_SERIE, "
				cSlctF1F2	+=	"SF1.F1_FORNECE, SF1.F1_LOJA, SF1.F1_EMISSAO, SF1.F1_PREFIXO, SF1.F1_DUPL, SF1.F1_CHVNFE, SF1.F1_HAWB "
				cSlctF1F2	+=	", SF1.F1_TRANSP "
				cSlctF1F2	+=	", SF1.F1_TPFRETE "
				cSlctF1F2	+=	", SF1.F1_TPCTE "
				cSlctF1F2	+=	", SF1.F1_MENNOTA "
			Else
				cSlctF1F2	+=	"SF2.F2_FRETE, SF2.F2_COND, SF2.F2_TIPO, SF2.F2_FORMUL, SF2.F2_ESPECIE, SF2.F2_EMISSAO, SF2.F2_CLIENTE, "
				cSlctF1F2	+=	"SF2.F2_LOJA, SF2.F2_NFCUPOM, SF2.F2_PDV, SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_TRANSP, SF2.F2_VEICUL1, "
				cSlctF1F2	+=	"SF2.F2_VEICUL2, SF2.F2_VEICUL3, SF2.F2_PBRUTO, SF2.F2_PLIQUI, SF2.F2_PREFIXO, SF2.F2_DUPL, SF2.F2_ECF, "
				cSlctF1F2	+=	"SF2.F2_VALPIS, SF2.F2_VALCOFI, SF2.F2_FILIAL, SF2.F2_CHVNFE"
				
				If aSPDSX3[FP_F2_MENNOTA]
					cSlctF1F2	+=	", SF2.F2_MENNOTA "
				EndIf
				
				cScan 		:= 	"1"
				While SF2->(FieldPos("F2_ESPECI"+cScan))>0 .Or. SF2->(FieldPos("F2_VOLUME"+cScan))>0
					If SF2->(FieldPos("F2_ESPECI"+cScan))>0
						cSlctF1F2	+=	",F2_ESPECI"+cScan
					EndIf
					If SF2->(FieldPos("F2_VOLUME"+cScan))>0
						cSlctF1F2	+=	",F2_VOLUME"+cScan
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Campos de volume utilizado no registro C160 e que estarao na query³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAdd(aF2EspVol,{"F2_ESPECI"+cScan,,"F2_VOLUME"+cScan,})
	
					cScan := Soma1(cScan,1)
				EndDo
			EndIf
			cSlctF1F2 += ","
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Campos para o SELECT da tabela SD2 ou SD1³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cTpMov=="E"
				cSlctD1D2	:=	"SD1.D1_TES,SD1.D1_TIPO,SD1.D1_UM,SD1.D1_PEDIDO,SD1.D1_ITEM,SD1.D1_SEGUM,SD1.D1_QTSEGUM,SD1.D1_DOC, SD1.D1_VALIPI,"
				cSlctD1D2+="SD1.D1_DESCICM,"
			Else
				cSlctD1D2	:=	"SD2.D2_TES,SD2.D2_TIPO,SD2.D2_UM,SD2.D2_PEDIDO,SD2.D2_SEGUM,SD2.D2_QTSEGUM,SD2.D2_DOC,"
				cSlctD1D2+="SD2.D2_DESCICM,"
				If SD2->(FieldPos(cMvD310MUN))>0
					cSlctD1D2+= cMvD310MUN+","
				EndIf
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Campos para o SELECT da tabela SA1, SA2 e SA4³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//Tabela SA1
			cSlctA1	:=	"SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SA1.A1_PESSOA, SA1.A1_CGC, SA1.A1_EST, SA1.A1_INSCR, SA1.A1_COD_MUN, "
			cSlctA1	+=	"SA1.A1_END, SA1.A1_BAIRRO, SA1.A1_INSCRM, SA1.A1_TIPO"
			cSlctA1	+=	", SA1.A1_CODPAIS"
			cSlctA1	+=	", SA1.A1_SUFRAMA"
			cSlctA1	+=	", SA1.A1_ENDNOT"
			cSlctA1	+=	", SA1.A1_SIMPNAC"
			cSlctA1	+=	", SA1.A1_REGPB"
			cSlctA1	+=	", SA1.A1_COMPLEM"
			cSlctA1 += ","
			
			//Tabela SA1 para que traga as informacoes do cliente de entrega
			cSlctClient	:=	"SA1CLIENT.A1_COD AS CODENT, SA1CLIENT.A1_LOJA AS LOJENT, SA1CLIENT.A1_NOME AS NOMENT, SA1CLIENT.A1_PESSOA AS PESSENT, SA1CLIENT.A1_CGC AS CGCENT, SA1CLIENT.A1_EST AS ESTENT, SA1CLIENT.A1_INSCR AS INSCRENT, SA1CLIENT.A1_COD_MUN AS COD_MUN_ENT, "
			cSlctClient	+=	"SA1CLIENT.A1_END AS ENDENT, SA1CLIENT.A1_BAIRRO AS BAIRROENT, SA1CLIENT.A1_INSCRM AS INSCRMENT, SA1CLIENT.A1_TIPO AS TIPOENT"
			cSlctClient	+=	", SA1CLIENT.A1_CODPAIS AS CODPAISENT"
			cSlctClient	+=	", SA1CLIENT.A1_SUFRAMA AS SUFRAMAENT"
			cSlctClient	+=	", SA1CLIENT.A1_ENDNOT AS ENDNOTENT"
			cSlctClient	+=	", SA1CLIENT.A1_SIMPNAC AS SIMPNACENT"
			cSlctClient	+=	", SA1CLIENT.A1_REGPB AS REGPBENT"
			cSlctClient	+=	", SA1CLIENT.A1_COMPLEM AS COMPLEMENT"
			cSlctClient += ","
			
			//Tabela SA2
			cSlctA2	:=	"SA2.A2_COD, SA2.A2_LOJA, SA2.A2_NOME, SA2.A2_TIPO, SA2.A2_CGC, SA2.A2_EST, SA2.A2_INSCR, SA2.A2_COD_MUN, "
			cSlctA2	+=	"SA2.A2_END, SA2.A2_BAIRRO, SA2.A2_INSCRM"
			cSlctA2	+=	", SA2.A2_CODPAIS"
			If aSPDSX3[FP_A2_SUFRAMA]
//				cSlctA2	+=	", SA2.A2_SUFRAMA"
				cSlctA2	+=	", '            ' AS A2_SUFRAMA"
			EndIf
			cSlctA2	+=	", SA2.A2_ENDNOT"
			cSlctA2	+=	", SA2.A2_SIMPNAC"
			cSlctA2	+=	", SA2.A2_COMPLEM"
			
			If SA2->(ColumnPos("A2_REGPB")) > 0
				cSlctA2	+=	", SA2.A2_REGPB"
			EndIf
			
			cSlctA2 += ","
	
			//Tabela SA4
			cSlctA4	:=	"A4_COD, A4_NOME, A4_CGC, A4_INSEST, A4_EST, A4_END, A4_BAIRRO"
			cSlctA4	+=	", SA4.A4_CODPAIS"
			cSlctA4	+=	", SA4.A4_COD_MUN"
			cSlctA4	+=	", SA4.A4_SUFRAMA"
			cSlctA4	+=	", SA4.A4_ENDNOT"
			cSlctA4	+=	", SA4.A4_COMPLEM"
			cSlctA4 	+= ","
			
			//Tabela SF4
			cSlctF4	:=	"SF4.F4_VLAGREG, SF4.F4_SELO, SF4.F4_TEXTO, SF4.F4_ESTOQUE, SF4.F4_BASEICM, SF4.F4_SITTRIB, SF4.F4_CSTPIS, SF4.F4_CSTCOF, SF4.F4_ICM, SF4.F4_LFICM, SF4.F4_CODIGO, SF4.F4_LFIPI "
			cSlctF4	+=	", SF4.F4_PISDSZF"
			cSlctF4	+=	", SF4.F4_COFDSZF"
			cSlctF4	+=	", SF4.F4_MOVFIS"
			cSlctF4	+=	", SF4.F4_CSOSN"
			cSlctF4	+=	", SF4.F4_RGESPCI"
			cSlctF4	+=	", SF4.F4_OBSSOL"
			cSlctF4	+=	", SF4.F4_AGREG"
			cSlctF4	+=	", SF4.F4_CODOBSE"
			cSlctF4	+=	", SF4.F4_CONSUMO"
			cSlctF4	+=	", SF4.F4_OPERGAR"
			cSlctF4 	+= 	","
	
			//Tabela SF3
			cSlctSF3	:=	"SF3.F3_PROTOC"
			cSlctSF3 	+= ","
	
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Campos do SELECT caso as tabelas estejam criadas na base de dados³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSlct	:=	""
			If lTabComp
				cSlct	:=	",SFU.R_E_C_N_O_ SFURECNO"
				cSlct	+=	",SFX.R_E_C_N_O_ SFXRECNO"
				cSlct	+=	",CD3.R_E_C_N_O_ CD3RECNO"
				cSlct	+=	",CD7.R_E_C_N_O_ CD7RECNO"
				cSlct	+=	",CD8.R_E_C_N_O_ CD8RECNO"
				cSlct	+=	",CD9.R_E_C_N_O_ CD9RECNO"
				cSlct	+=	",CCE.R_E_C_N_O_ CCERECNO"
			EndIf

			/*If lTabCD0
				cSlct	+=	",CD0.R_E_C_N_O_ CD0RECNO"
			EndIf*/
			
			If lTabCD1
				cSlct	+=	",CD1.R_E_C_N_O_ CD1RECNO"
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se houver integracao com o TMS, trago o recno do conhecimento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lIntTMS
				cSlct	+=	",DT6.R_E_C_N_O_ DT6RECNO"			
			EndIf
			//cSlct	+=	","
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Concateno todas as variaveis individuais de SELECT para formar uma³
			//³  soh a ser utilizada no EMBEDED SQL                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSlctAll	:=	cSlctSFT+cSlctSB1+cSlctD1D2+cSlctF4+cSlctF1F2+cSlctA1+cSlctClient+cSlctA2+cSlctA4+cSlctSF3		
			cSlctAll	+=	"SF3.R_E_C_N_O_ SF3RECNO"
			cSlctAll	+=	cSlct
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tratamento retirado devido a um problema de JOIN em ambiente ORACLE, bug da versao 10G.                 ³
			//³Como estas duas informacoes nao estao sendo utilizadas no momento, estou desativando.                   ³
			//³                                                                                                        ³
			//³Error : 1445 - ORA-01445: cannot select ROWID from, or sample, a join view without a key-preserved table³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//cSlctAll	+=	"(SELECT COUNT(*) FROM "+RetSqlName("SF3")+" SF3A WHERE SF3A.F3_FILIAL='"+xFilial("SF3")+"' AND SF3A.F3_ENTRADA=SFT.FT_ENTRADA AND SF3A.F3_NFISCAL=SFT.FT_NFISCAL AND SF3A.F3_SERIE=SFT.FT_SERIE AND SF3A.F3_CLIEFOR=SFT.FT_CLIEFOR AND SF3A.F3_LOJA=SFT.FT_LOJA AND SF3A.F3_TIPO='S' AND SF3A.D_E_L_E_T_=' ') F3CTDTPS,"
			//cSlctAll	+=	"(SELECT COUNT(*) FROM "+RetSqlName("SF3")+" SF3B WHERE SF3B.F3_FILIAL='"+xFilial("SF3")+"' AND SF3B.F3_ENTRADA=SFT.FT_ENTRADA AND SF3B.F3_NFISCAL=SFT.FT_NFISCAL AND SF3B.F3_SERIE=SFT.FT_SERIE AND SF3B.F3_CLIEFOR=SFT.FT_CLIEFOR AND SF3B.F3_LOJA=SFT.FT_LOJA AND SF3B.F3_TIPO=' ' AND SF3B.D_E_L_E_T_=' ') F3CTDTPN
			
			cOrderBy	:=	"%ORDER BY 1,2,3,4,5,6,7,8,9%"
		EndIf
		cSlctAll	:=	"%"+cSlctAll+"%" 
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para campos de tabelas que variam quando ENTRADA ou SAIDA³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
		//JOIN SF3
		If cTpMov=="E"
			cJoinF3	:=	"SF3.F3_CFO<'5'"
		Else
			cJoinF3	:=	"SF3.F3_CFO>'4'"
		EndIf
		cJoinF3 := "%" + cJoinF3 + "%"
		
		//JOIN SD1 e SD2
		If cTpMov=="E"
			cJoinD1D2	:=	"LEFT JOIN "+RetSqlName("SD1")+" SD1 ON(SD1.D1_FILIAL='"+xFilial("SD1")+"'  AND SD1.D1_DOC=SFT.FT_NFISCAL AND SD1.D1_SERIE=SFT.FT_SERIE AND SD1.D1_FORNECE=SFT.FT_CLIEFOR AND SD1.D1_LOJA=SFT.FT_LOJA AND SD1.D1_COD=SFT.FT_PRODUTO AND SD1.D1_ITEM=SFT.FT_ITEM AND SD1.D_E_L_E_T_=' ') "
		Else
			cJoinD1D2	:=	"LEFT JOIN "+RetSqlName("SD2")+" SD2 ON(SD2.D2_FILIAL='"+xFilial("SD2")+"'  AND SD2.D2_DOC=SFT.FT_NFISCAL AND SD2.D2_SERIE=SFT.FT_SERIE AND SD2.D2_CLIENTE=SFT.FT_CLIEFOR AND SD2.D2_LOJA=SFT.FT_LOJA AND SD2.D2_COD=SFT.FT_PRODUTO AND SD2.D2_ITEM=SFT.FT_ITEM AND SD2.D_E_L_E_T_=' ') "
		EndIf
		cJoinD1D2 := "%" + cJoinD1D2 + "%"
		
		//JOIN SF1 e SF2
		If cTpMov=="E"
			cJoinF1F2	:=	"LEFT JOIN "+RetSqlName("SF1")+" SF1 ON(SF1.F1_FILIAL='"+xFilial("SF1")+"'  AND SF1.F1_DOC=SFT.FT_NFISCAL AND SF1.F1_SERIE=SFT.FT_SERIE AND SF1.F1_FORNECE=SFT.FT_CLIEFOR AND SF1.F1_LOJA=SFT.FT_LOJA AND SF1.D_E_L_E_T_=' ') "
		Else
			cJoinF1F2	:=	"LEFT JOIN "+RetSqlName("SF2")+" SF2 ON(SF2.F2_FILIAL='"+xFilial("SF2")+"'  AND SF2.F2_DOC=SFT.FT_NFISCAL AND SF2.F2_SERIE=SFT.FT_SERIE AND SF2.F2_CLIENTE=SFT.FT_CLIEFOR AND SF2.F2_LOJA=SFT.FT_LOJA AND SF2.D_E_L_E_T_=' ') "
		EndIf
		cJoinF1F2 := "%" + cJoinF1F2 + "%"
		
		//JOIN SF4
		If cTpMov=="E"
			cJoinSF4	:=	"SF4.F4_CODIGO=SD1.D1_TES"
		Else
			cJoinSF4	:=	"SF4.F4_CODIGO=SD2.D2_TES"
		EndIf
		cJoinSF4 := "%" + cJoinSF4 + "%"

		//JOIN SA4
		If cTpMov=="E"
			cJoinSA4	:=	"SA4.A4_COD=SF1.F1_TRANSP"
		Else
			cJoinSA4	:=	"SA4.A4_COD=SF2.F2_TRANSP"
		EndIf
		cJoinSA4 := "%" + cJoinSA4 + "%"
		 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tabelas do JOIN caso as mesmas estejam criadas no dicionario de dados³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lTabComp
			cJoinCompl	:=	"LEFT JOIN "+RetSqlName("SFU")+" SFU ON(SFU.FU_FILIAL='"+xFilial("SFU")+"' AND SFU.FU_TIPOMOV=SFT.FT_TIPOMOV AND SFU.FU_SERIE=SFT.FT_SERIE AND SFU.FU_DOC=SFT.FT_NFISCAL AND SFU.FU_CLIFOR=SFT.FT_CLIEFOR AND SFU.FU_LOJA=SFT.FT_LOJA AND SFU.FU_ITEM=SFT.FT_ITEM AND SFU.FU_COD=SFT.FT_PRODUTO AND SFU.D_E_L_E_T_='')"
			cJoinCompl	+=	"LEFT JOIN "+RetSqlName("SFX")+" SFX ON(SFX.FX_FILIAL='"+xFilial("SFX")+"'  AND SFX.FX_TIPOMOV=SFT.FT_TIPOMOV AND SFX.FX_SERIE=SFT.FT_SERIE AND SFX.FX_DOC=SFT.FT_NFISCAL AND SFX.FX_CLIFOR=SFT.FT_CLIEFOR AND SFX.FX_LOJA=SFT.FT_LOJA AND SFX.FX_ITEM=SFT.FT_ITEM AND SFX.FX_COD=SFT.FT_PRODUTO AND SFX.D_E_L_E_T_='') "
			cJoinCompl	+=	"LEFT JOIN "+RetSqlName("CD3")+" CD3 ON(CD3.CD3_FILIAL='"+xFilial("CD3")+"' AND CD3.CD3_TPMOV=SFT.FT_TIPOMOV AND CD3.CD3_SERIE=SFT.FT_SERIE AND CD3.CD3_DOC=SFT.FT_NFISCAL AND CD3.CD3_CLIFOR=SFT.FT_CLIEFOR AND CD3.CD3_LOJA=SFT.FT_LOJA AND CD3.CD3_ITEM=SFT.FT_ITEM AND CD3.CD3_COD=SFT.FT_PRODUTO AND CD3.D_E_L_E_T_='') "
			cJoinCompl	+=	"LEFT JOIN "+RetSqlName("CD7")+" CD7 ON(CD7.CD7_FILIAL='"+xFilial("CD7")+"' AND CD7.CD7_TPMOV=SFT.FT_TIPOMOV AND CD7.CD7_SERIE=SFT.FT_SERIE AND CD7.CD7_DOC=SFT.FT_NFISCAL AND CD7.CD7_CLIFOR=SFT.FT_CLIEFOR AND CD7.CD7_LOJA=SFT.FT_LOJA AND CD7.CD7_ITEM=SFT.FT_ITEM AND CD7.CD7_COD=SFT.FT_PRODUTO AND CD7.D_E_L_E_T_='') "
			cJoinCompl	+=	"LEFT JOIN "+RetSqlName("CD8")+" CD8 ON(CD8.CD8_FILIAL='"+xFilial("CD8")+"' AND CD8.CD8_TPMOV=SFT.FT_TIPOMOV AND CD8.CD8_SERIE=SFT.FT_SERIE AND CD8.CD8_DOC=SFT.FT_NFISCAL AND CD8.CD8_CLIFOR=SFT.FT_CLIEFOR AND CD8.CD8_LOJA=SFT.FT_LOJA AND CD8.CD8_ITEM=SFT.FT_ITEM AND CD8.CD8_COD=SFT.FT_PRODUTO AND CD8.D_E_L_E_T_='') "
			cJoinCompl	+=	"LEFT JOIN "+RetSqlName("CD9")+" CD9 ON(CD9.CD9_FILIAL='"+xFilial("CD9")+"' AND CD9.CD9_TPMOV=SFT.FT_TIPOMOV AND CD9.CD9_SERIE=SFT.FT_SERIE AND CD9.CD9_DOC=SFT.FT_NFISCAL AND CD9.CD9_CLIFOR=SFT.FT_CLIEFOR AND CD9.CD9_LOJA=SFT.FT_LOJA AND CD9.CD9_ITEM=SFT.FT_ITEM AND CD9.CD9_COD=SFT.FT_PRODUTO AND CD9.D_E_L_E_T_='') "
			cJoinCompl	+=	"LEFT JOIN "+RetSqlName("CCE")+" CCE ON(CCE.CCE_FILIAL='"+xFilial("CCE")+"' AND CCE.CCE_COD=SF4.F4_CODOBSE AND CCE.D_E_L_E_T_='') "
		EndIf

		/*If lTabCD0
			cJoinCompl	+=	"LEFT JOIN "+RetSqlName("CD0")+" CD0 ON(CD0.CD0_FILIAL='"+xFilial("CD0")+"' AND CD0.CD0_TPMOV=SFT.FT_TIPOMOV AND CD0.CD0_SERIE=SFT.FT_SERIE AND CD0.CD0_DOC=SFT.FT_NFISCAL AND CD0.CD0_CLIFOR=SFT.FT_CLIEFOR AND CD0.CD0_LOJA=SFT.FT_LOJA AND CD0.CD0_ITEM=SFT.FT_ITEM AND CD0.CD0_COD=SFT.FT_PRODUTO AND CD0.D_E_L_E_T_='') "
		EndIf*/
		
		If lTabCD1
	  		cJoinCompl	+=	"LEFT JOIN "+RetSqlName("CD1")+" CD1 ON(CD1.CD1_FILIAL='"+xFilial("CD1")+"' AND CD1.CD1_CODNAT=SFT.FT_NATOPER AND CD1.D_E_L_E_T_='') "
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se houver integracao com o TMS, faco o JOIN das tabelas      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lIntTMS
			cJoinCompl	+=	"LEFT JOIN "+RetSqlName("DT6")+" DT6 ON(SFT.FT_TIPOMOV='S' AND DT6_FILIAL='"+xFilial("DT6")+"' AND DT6_FILDOC=SFT.FT_FILIAL AND DT6_DOC=SFT.FT_NFISCAL AND DT6_SERIE=SFT.FT_SERIE AND DT6.D_E_L_E_T_='') "
		EndIf
		
		//Se utilizar informacao de produto primario incluo JOIN com tabela SB5
		If !Empty(cPRDPRIB5)
			If SB5->(FieldPos(cPRDPRIB5))>0
				 cJoinCompl +=  "LEFT JOIN "+RetSqlName("SB5")+" SB5 ON(SB5.B5_FILIAL ='"+xFilial("SB5")+"' AND SB5.B5_COD=SB1.B1_COD AND SB5.D_E_L_E_T_='') "
				
			Endif
		Endif
		
		cJoinCompl := "%" + cJoinCompl + "%"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³SELECT COUNT() utilizado para pegar o numero real de registros para montar a barra de progressao corretametne³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³SELECT real para a execucao da rotina³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	cAliasSFT		:=	GetNextAlias()

    	BeginSql Alias cAliasSFT
	    	
	    	SELECT			    	 
				%Exp:cSlctAll%			

			FROM 
				%Table:SFT% SFT				
				/*
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ”•VD¿
				//³Inserida condicao para desconsiderar itens de notas ³
				//³conjugadas que possuam o campo observacao           ³
				//³igual a NOTA DE SERVICO que se enquadram            ³
				//³na seguinte situacao:                               ³
				//³                                                    ³
				//³TES Produto 1, ISS                                  ³
				//³                                                    ³
				//³F4_ICM = Nao                                        ³
				//³F4_LFICM = Isento                                   ³
				//³F4_ISS = Sim                                        ³
				//³F4_SITRIB = 41                                      ³
				//³F4_CFO = 5933                                       ³
				//³                                                    ³
				//³TES Produto 2, ICMS                                 ³
				//³                                                    ³
				//³F4_ICM = Sim                                        ³
				//³F4_LFICM = Tributado                                ³
				//³F4_ISS = Nao                                        ³
				//³F4_SITRIB = 00                                      ³
				//³F4_CFO = 5102                                       ³
				//³                                                    ³
				//³Como a escrituracao gera um item na tabela SF3      ³
				//³para o ICMS Isento da nota de servico, este item    ³
				//³deve ser desconsiderado na geracao do SpedFiscal    ³
				//³pois sua inclusao recorria em valores duplicados    ³
				//³no arquivo                                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ”•VDÙ
				*/								
				LEFT JOIN %Table:SF3% SF3 ON(SF3.F3_FILIAL=%xFilial:SF3%  AND %Exp:cJoinF3% AND SF3.F3_SERIE=SFT.FT_SERIE AND SF3.F3_NFISCAL=SFT.FT_NFISCAL AND SF3.F3_CLIEFOR=SFT.FT_CLIEFOR AND SF3.F3_LOJA=SFT.FT_LOJA AND SF3.F3_IDENTFT=SFT.FT_IDENTF3 AND SF3.F3_ENTRADA=SFT.FT_ENTRADA AND SF3.F3_OBSERV NOT LIKE('NOTA FISCAL DE SERVICO%') AND SF3.%NotDel%)
				%Exp:cJoinD1D2%
				LEFT JOIN %Table:SB1% SB1 ON(SB1.B1_FILIAL=%xFilial:SB1%  AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.%NotDel%)
				LEFT JOIN %Table:SF4% SF4 ON(SF4.F4_FILIAL=%xFilial:SF4%  AND %Exp:cJoinSF4% AND SF4.%NotDel%)
				%Exp:cJoinCompl%
				LEFT JOIN %Table:SA1% SA1 ON(SA1.A1_FILIAL=%xFilial:SA1%  AND SA1.A1_COD=SFT.FT_CLIEFOR AND SA1.A1_LOJA=SFT.FT_LOJA AND SA1.%NotDel%)
				LEFT JOIN %Table:SA1% SA1CLIENT ON(SA1CLIENT.A1_FILIAL=%xFilial:SA1%  AND SA1CLIENT.A1_COD=SFT.FT_CLIENT AND SA1CLIENT.A1_LOJA=SFT.FT_LOJENT AND SA1CLIENT.%NotDel%) AND (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO NOT IN ('D','B') )
				LEFT JOIN %Table:SA2% SA2 ON(SA2.A2_FILIAL=%xFilial:SA2%  AND SA2.A2_COD=SFT.FT_CLIEFOR AND SA2.A2_LOJA=SFT.FT_LOJA AND SA2.%NotDel%)						
				%Exp:cJoinF1F2%
				LEFT JOIN %Table:SA4% SA4 ON(SA4.A4_FILIAL=%xFilial:SA4%  AND %Exp:cJoinSA4% AND SA4.%NotDel%)
			
			WHERE 
				SFT.FT_FILIAL=%xFilial:SFT% AND 
				SFT.FT_TIPOMOV = %Exp:cTpMov% AND 
				SFT.FT_ENTRADA>=%Exp:DToS (dDataDe)% AND 
				SFT.FT_ENTRADA<=%Exp:DToS (dDataAte)% AND 
				((SFT.FT_CFOP NOT LIKE '000%' AND SFT.FT_CFOP NOT LIKE '999%') OR SFT.FT_TIPO='S') AND 
				(SFT.FT_ESPECIE <> 'CF' OR (SFT.FT_ESPECIE = 'CF' AND SFT.FT_VALIPI > 0)) AND  
				%Exp:cFiltro%
				SFT.%NotDel% 
        
			%Exp:cOrderBy%
		EndSql
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o objetivo for soh para retornar o COUNT, posso salvar em uma variavel ³
		//³  e fechar o alias, pois nao serah mais utilizado                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpc==1
			nRecCount	:=	(cAliasSFT)->SFTCOUNT
			
			(cAliasSFT)->(DbCloseArea())
			cAliasSFT	:=	cSlvAlias
		Else
            For nX := 1 To Len(aFieldDt)
				TcSetField(cAliasSFT,aFieldDt[nX],"D",8,0)
			Next nX
		EndIf
	Else
#ENDIF
	    cIndex	:= CriaTrab(NIL,.F.)
	    cFiltro	:= 'FT_FILIAL=="'+xFilial ("SFT")+'".And.'
	    cFiltro += 'FT_TIPOMOV=="'+cTpMov+'" .And. '
	    cFiltro += 'DToS (FT_ENTRADA)>="'+DToS (dDataDe)+'".And.DToS (FT_ENTRADA)<="'+DToS (dDataAte)+'" '
		cFiltro += '.And. (!SubStr (FT_CFOP,1,3)$"999/000" .Or. FT_TIPO=="S")'
		cFiltro += '.And. FT_ESPECIE <> "CF" .Or. (FT_ESPECIE == "CF" .And. FT_VALIPI > 0) '                                 

	    If (cNrLivro<>"*")
		    cFiltro	+=	'.And.FT_NRLIVRO ="'+cNrLivro+'" '
	   	EndIf

	    IndRegua (cAliasSFT, cIndex, SFT->(IndexKey ()),, cFiltro)
	    nIndex := RetIndex(cAliasSFT)

		#IFNDEF TOP
			DbSetIndex(cIndex+OrdBagExt ())
		#ENDIF
		
		DbSelectArea(cAliasSFT)
	    DbSetOrder(nIndex+1)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o objetivo for soh para retornar o COUNT, posso salvar em uma variavel ³
		//³  e fechar o alias, pois nao serah mais utilizado                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpc==1
			nRecCount	:=	(cAliasSFT)->(RecCount ())
			
			(cAliasSFT)->(DbCloseArea())
			Ferase(cIndex+GetDBExtension())
			Ferase(cIndex+OrdBagExt())
			cAliasSFT	:=	cSlvAlias			
		EndIf	    
	    
		DbSelectArea (cAliasSFT)
		(cAliasSFT)->(DbGoTop ())
		
#IFDEF TOP
	Endif
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para quando nao for um SELECT de registros, retornar ZERO ³
//³  quando nao tiver movimento no periodo, e UM para quando tiver.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc<>1 .And. !(cAliasSFT)->(Eof())
	nRecCount	:=	1
EndIf

Return nRecCount

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SPDRetCCST| Autor ³Gustavo G. Rueda              ³ Data ³22.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao que retorna o codigo de situacao tributaria dos impostos    ³±±
±±³          ³ ICMS, IPI, PIS e COFINS                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpA1 :=SPDRetCCST(cPar1,lPar2,lPar3,lPar4,cPar5,cPar6,cPar7,cPar8)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cPar1 - Alias da tabela SFT em processamento                       ³±±
±±³          ³lPar2 - Booleano de identificacao da existencia do registro na     ³±±
±±³          ³        tabela SF4 correspondente ao item da tabela SFT            ³±±
±±³          ³lPar3 - Booleano de identificacao da existencia do campo de CST    ³±±
±±³          ³        do PIS na tabela SFT                                       ³±±
±±³          ³lPar4 - Booleano de identificacao da existencia do campo de CST    ³±±
±±³          ³        da COFINS na tabela SFT                                    ³±±
±±³          ³cPar5 - Especie do documento fiscal em processamento               ³±±
±±³          ³cPar6 - Alias da tabela SF4, query ou SF4                          ³±±
±±³          ³cPar7 - Alias da tabela SB1, query ou SB1                          ³±±
±±³          ³cPar8 - Estado do cliente/Forncedor do documento fiscal            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aRet -> Array com os codigos de situacao tributaria                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SPDRetCCST(cAliasSFT,lAchouSF4,lCstPis,lCstCof,cEspecie,cAliasSF4,cAliasSB1,cPartEst)
//						Icm Ipi Pis	Cof
Local	aRet		:= {"" ,"", "", ""}
Local   lStfrete    := aSPDSX6[MV_STFRETE] //Cod.Situação Tributaria para notas de conhecimento de frete

DEFAULT cEspecie 	:=	"01"
DEFAULT cAliasSF4	:=	"SF4"
DEFAULT cAliasSB1	:=	"SB1"
DEFAULT cPartEst	:=	SA1->A1_EST

//Situacao Tributaria ICMS
If Empty((cAliasSFT)->FT_CLASFIS) .Or. Len(Alltrim((cAliasSFT)->FT_CLASFIS))<>3

	If Empty((cAliasSB1)->B1_ORIGEM)

		If Empty((cAliasSB1)->B1_IMPORT) .Or. (cAliasSB1)->B1_IMPORT=="N" 
			aRet[1] := "0"
		Else
			If cPartEst=="EX"
				aRet[1] := "1"
			Else
				aRet[1] := "2"
			EndIf
		EndIf
	Else
		aRet[1] := (cAliasSB1)->B1_ORIGEM
	EndIf
	
	If lAchouSF4
		aRet[1]	+=	(cAliasSF4)->F4_SITTRIB
	EndIf
Else
	aRet[1] :=(cAliasSFT)->FT_CLASFIS
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄd¿
//³Tratamento para notas de conhecimento de frete.                                         ³
//³  Em consulta junto nossa consultoria Tributária, foi necessario a criação do parametro ³
//³  MV_STFRETE para definir se o campo (CST)Cod.Situação Tributaria  das notas de         ³
//³ conhecimento de frete será considerado do B1_ORIGEM ou se iniciará em "0"              ³
//³ mesmo sendo uma importação.                                                            ³
//³Solicitação feita na FNC 00000019516/2010-01                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄdÙ
If lStfrete    
	If cEspecie$"07#08#09#10#11#26#27#57"
    	aRet[1] := "0"+ SubStr((cAliasSFT)->FT_CLASFIS,2,3)
  	EndIf
EndIf

//Situacao Tributaria IPI
aRet[2] := (cAliasSFT)->FT_CTIPI

//Situacao Tributaria PIS
If lCstPis .And. !Empty((cAliasSFT)->FT_CSTPIS)
	aRet[3] := (cAliasSFT)->FT_CSTPIS
ElseIf lAchouSF4
	aRet[3] := (cAliasSF4)->F4_CSTPIS
EndIf

//Situacao Tributaria COFINS
If lCstCof .And. !Empty((cAliasSFT)->FT_CSTCOF)
	aRet[4] := (cAliasSFT)->FT_CSTCOF
ElseIf lAchouSF4
	aRet[4] := (cAliasSF4)->F4_CSTCOF
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para alterar a classificação fiscal do produto.³        
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aExistBloc[22]
	aRet :=  ExecBlock("SPDFIS03", .F., .F., {(cAliasSFT)->FT_FILIAL,;
						(cAliasSFT)->FT_TIPOMOV,;
						(cAliasSFT)->FT_SERIE,;
						(cAliasSFT)->FT_NFISCAL,;
						(cAliasSFT)->FT_CLIEFOR,;
						(cAliasSFT)->FT_LOJA,;
						(cAliasSFT)->FT_ITEM,;
						(cAliasSFT)->FT_PRODUTO})
EndIf 
Return(aRet)

