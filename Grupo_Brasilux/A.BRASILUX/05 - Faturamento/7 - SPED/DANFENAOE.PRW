#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GerDanfe  ºAutor  ³Max Ivan            º Data ³  29/09/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Geração de Danfes que não foram emitidos pra poder gravar   º±±
±±º          ³F2_CHVNFE                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³WorkFlow - Cenze                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DANFENAOE(lAuto,cDoc,cSerie)
//Local aArea := GetArea()
Local _cEmpresa                                                               
Local _cFilial    
Local aEmp := {}
Local nEmp,_cQuery,nContReg
Local nRegEmp,cCnpj,cXml,cMens,lSucesso
DEFAULT lAuto := .f.
DEFAULT cDoc := ""
DEFAULT cSerie := ""
//Local _aTabs := {"SX2",'SX3','SX6','SF2','SC5'}
                                        

nContReg := 0

//lAuto := If(Select("SX2")==0,.t.,.f.)
if lAuto
//	aEmp := {{'01','010101'},{'01','010104'},{'01','010106'}}
	aEmp := {{'01','010106'}}
else
	aEmp := {{'01',xFilial("SF2")}}
endif	

For nEmp := 1 To Len(aEmp)
	_cEmpresa := iif(lAuto,aEmp[nEmp,1],substr(cNumEmp,1,2))
	_cFilial := iif(lAuto,aEmp[nEmp,2],xFilial("SF2"))
	lSucesso := .t.
	If lAuto
		RPCSetType( 3 )	// Não consome licensa de uso
        PREPARE ENVIRONMENT EMPRESA _cEmpresa FILIAL _cFilial TABLES "SX5","SF2","SD1","SB1", "SB2", "SA1","SA2","SF4","SD2"
//		RpcSetEnv(aEmp[nEmp,1],aEmp[nEmp,2],,,,GetEnvServer()) //, _aTabs
		sleep( 5000 )	// aguarda 5 segundos para que as jobs IPC subam.
	Endif

	nRegEmp:=SM0->(RecNo())
	dbSelectArea("SM0")
	if lAuto
		dbSeek(_cEmpresa+_cFilial,.T.)
		if !found()
			lSucesso := .f.
			cMens := "Nao encontrado em SM0 empresa "+_cEmpresa+_cFilial
			//Conout(cMens) release 12.1.25
			FwLogMSG( "WARN", , 'SIGAFAT', FunName(), '', '01', cMens, 0 )
/*			if lAuto                        
				Conout(cMens)
			else
				Help(" ",1,'Erro!',,cMens,4,5)
			endif  */
		endif 
	endif 
	if lSucesso
		cCnpj := alltrim(SM0->M0_CGC)
		SM0->(dbGoTo(nRegEmp))		
	
	//Define o conteudo (miolo) da query - informacao unica as duas querys
	
//	"CONVERT(varchar(MAX),convert(varbinary(MAX),XML_ERP)) AS ARQXML "+;
		_cQuery := "SELECT SPED.ID_ENT,SF2.R_E_C_N_O_ AS REG,F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_EMISSAO, F2_HORA, "+;
		"NFE_ID, TIME_NFE, DATE_NFE, STATUS, STATUSMAIL  "+;
		"FROM "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) "+;
		"LEFT OUTER JOIN SPED001 EMPR WITH (NOLOCK) ON (EMPR.D_E_L_E_T_ <> '*') AND (EMPR.CNPJ = '"+cCnpj+"') "+;
		"LEFT OUTER JOIN SPED050 SPED WITH (NOLOCK) ON (SPED.D_E_L_E_T_ <> '*') AND (SPED.ID_ENT = EMPR.ID_ENT) AND ((F2_SERIE+F2_DOC) = NFE_ID) "+;
		"WHERE (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = '"+xFilial("SF2")+"') AND (F2_EMISSAO >= '20151201') AND "+;
		"(F2_CHVNFE = '') AND (F2_ESPECIE = 'SPED') "+;
		"AND (EMPR.CNPJ LIKE '"+substr(cCnpj,1,8)+"%') AND (SPED.STATUS = 6) AND (SPED.NFE_PROT <> '') "
		If !Empty(cDoc)                
			_cQuery  += "AND (F2_DOC = '" + cDoc + "') AND (F2_SERIE = '" + cSerie + "') "
		endif 
		_cQuery  += "ORDER BY SF2.R_E_C_N_O_"

		//Processa a Query principal (do processamento)
		TCQUERY _cQuery NEW ALIAS QUERY

		DbSelectArea("Query")
		DbGoTop()
		if eof() .or. bof()
			cMens := "Nenhuma Ocorrência!"
//			if lAuto
				//Conout(cMens) RELEASE 12.1.25
				FwLogMSG( "WARN", , 'SIGAFAT', FunName(), '', '01', cMens, 0 )
/*			else     
				Help(" ",1,'Aviso!',,cMens,4,5)
			endif */
		else           
			dbgobottom()
			nContReg := QUERY->REG
			dbgotop()
			nContReg := nContReg - QUERY->REG + 1
		endif 
		if !lAuto
			ProcRegua(nContReg)	
		endif 
		While !Eof()
			if !lAuto
				IncProc()
			endif 

				//ConOut('NF ' + QUERY->F2_SERIE+'-'+QUERY->F2_DOC) RELEASE 12.1.25
				cMens :='NF ' + QUERY->F2_SERIE+'-'+QUERY->F2_DOC	
				FwLogMSG( "WARN", , 'SIGAFAT', FunName(), '', '01', cMens, 0 )
				cXml := "" // QUERY->ARQXML
				//27/09/12 -> Primeiro parametro diz se envia e-mail ou não, atualmente usado somente pra preencher chaves
				//em notas cujo F2_CHVNFE está em branco pois o TSS já envia pdf junto com xml.
	   			GerPDF(.F.,QUERY->ID_ENT,QUERY->F2_DOC,QUERY->F2_SERIE,cXml,'',aEmp[nEmp,2],QUERY->REG) 

	   	
		   	DbSelectArea("Query")
	   		DbSkip()
		EndDo
	
		DbSelectArea("Query")
		DbCloseArea()
	endif 
	
	If lAuto
        RESET ENVIRONMENT
//		RpcClearEnv()
	Endif

Next
//RestArea(aArea)                
if lAuto
	__Quit()
endif 
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GerPDF    ºAutor  ³Max Ivan            º Data ³  23/04/2009 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a transmissao dos e-mails com os PDFs.                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GerDanfe.prw                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GerPDF(lEnviaEmail,_cIdEnt,_cNumNF,_cSerie,cXML,cEmaTransp,cFil,nRegF2)
Local lAdjustToLegacy,_cDir,cArquivo,;
lSucesso,nFlags,cVar1,cVar2
Private MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05
Private oDanfe,_oSetup
Pergunte("NFSIGW",.F.)
/*
xMV_PAR01 := MV_PAR01
xMV_PAR02 := MV_PAR02
xMV_PAR03 := MV_PAR03
xMV_PAR05 := MV_PAR05 */
MV_PAR01 := _cNumNF
MV_PAR02 := _cNumNF
MV_PAR03 := _cSerie
MV_PAR04 := 2
MV_PAR05 := 2

    _cDir := "\spool\"
	cFilePrint := ALLTRIM(SM0->M0_NOME)+"_"+"DANFE_"+AllTrim(MV_PAR01)+"_"+AllTrim(MV_PAR03)
	cArquivo := AllTrim(_cDir+cFilePrint+".pdf")
	If File(cArquivo)
		fErase(cArquivo)
	endif 
	nFlags     := PD_ISTOTVSPRINTER+ PD_DISABLEORIENTATION + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
	_oSetup     := FWPrintSetup():New(nFlags, "DANFE")    
	_oSetup:SetProperty(PD_PRINTTYPE,IMP_PDF)                                                              
	_oSetup:SetProperty(PD_DESTINATION,AMB_SERVER)                                                              
//	__RelDir := _cDir
	_oSetup:aOptions[PD_VALUETYPE] := _cDir
	lAdjustToLegacy := .f. // Inibe legado de resolução com a TMSPrinter
	oDanfe     := FWMSPrinter():New(cFilePrint, IMP_PDF, lAdjustToLegacy, _cDir, .T., /*[ lTReport]*/, @_oSetup , "", .T., /*[ lPDFAsPNG]*/,/* [ lRaw]*/, .F.)
	U_DANFE_P1(_cIdEnt,@cVar1,@cVar2,oDanfe,_oSetup,.f.)  
	FreeObj(_oSetup)
	_oSetup := nil
	lSucesso := .t.

	If File(cArquivo)
		fErase(cArquivo)
	endif 

Return

