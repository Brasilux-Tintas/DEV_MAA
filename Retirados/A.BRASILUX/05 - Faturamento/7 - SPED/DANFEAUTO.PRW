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
±±ºDesc.     ³Rotina para agendamento (schedule) para geraçao do Danfe em º±±
±±º          ³PDF.                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³WorkFlow - Cenze                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DANFEAUTO(lAuto,cDoc,cSerie,cEmail)
//Local aArea := GetArea()
Local _cEmpresa                                                               
Local _cFilial    
Local aEmp := {}
Local nEmp,_cQuery,nContReg
Local nRegEmp,cCnpj,_cAuxMail,cXml,cMens,cRegNf,lSucesso
//Local _aTabs := {"SX2",'SX3','SX6','SF2','SC5'}
                                        

nContReg := 0

//lAuto := If(Select("SX2")==0,.t.,.f.)
if lAuto
	aEmp := {{'01','010101'},{'01','010104'},{'01','010106'}}
else
	aEmp := {{'01','010101'}}
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
	dbselectarea("SX5")
	dbsetorder(1)

	nRegEmp:=SM0->(RecNo())
	dbSelectArea("SM0")
	if lAuto
		dbSeek(_cEmpresa+_cFilial,.T.)
		if !found()
			lSucesso := .f.
			cMens := "Nao encontrado em SM0 empresa "+_cEmpresa+_cFilial
			//Conout(cMens) desabilitado release 12.1.25
			FwLogMSG( "INFO", , 'SIGAFAT', FunName(), '', '01', cMens, 0 )


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
		"NFE_ID, TIME_NFE, DATE_NFE, STATUS, STATUSMAIL, EMAIL = CASE WHEN A1_MAILXML > '' THEN A1_MAILXML WHEN A1_EMAIL > '' THEN A1_EMAIL ELSE SPED.EMAIL END "+;
		"FROM "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) "+;
		"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (F2_CLIENTE = A1_COD) "+;
		"LEFT OUTER JOIN "+RetSqlName("SX5")+" SX5 WITH (NOLOCK) ON (SX5.D_E_L_E_T_ <> '*') AND (X5_FILIAL = '"+xFilial("SX5")+"') AND (X5_TABELA = '95') AND (SF2.R_E_C_N_O_ = CONVERT(int,X5_CHAVE)) "+;
		"LEFT OUTER JOIN SPED050 SPED WITH (NOLOCK) ON (SPED.D_E_L_E_T_ <> '*') AND ((F2_SERIE+F2_DOC) = NFE_ID) "+;
		"LEFT OUTER JOIN SPED001 EMPR WITH (NOLOCK) ON (EMPR.D_E_L_E_T_ <> '*') AND (EMPR.ID_ENT = SPED.ID_ENT) "+;
		"WHERE (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = '"+xFilial("SF2")+"') AND (F2_EMISSAO >= '20120901') AND "+;
		"(F2_DAUTNFE = '') AND (F2_CHVNFE = '') AND (F2_ESPECIE = 'SPED') "+;
		"AND (EMPR.CNPJ = '"+cCnpj+"') AND (SPED.STATUS = 6) AND (SPED.NFE_PROT <> '') "
		If !Empty(cDoc)                
			_cQuery  += "AND (F2_DOC = '" + cDoc + "') AND (F2_SERIE = '" + cSerie + "') "
		endif 
		_cQuery  += "AND ((SX5.R_E_C_N_O_ IS NULL) OR ((SX5.R_E_C_N_O_ IS NOT NULL) AND (X5_DESCRI <> 'S'))) "
	
		_cQuery  += "ORDER BY SF2.R_E_C_N_O_"

		//Processa a Query principal (do processamento)
		TCQUERY _cQuery NEW ALIAS QUERY

		DbSelectArea("Query")
		DbGoTop()
		if eof() .or. bof()
			cMens := "Nenhuma Ocorrência!"
//			if lAuto
				//Conout(cMens)
				FwLogMSG( "INFO", , 'SIGAFAT', FunName(), '', '01', cMens, 0 )
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
			_cAuxMail := alltrim(If(!Empty(cEmail),cEmail,QUERY->EMAIL))

//			if !empty(_cAuxMail)
				//ConOut('NF ' + QUERY->F2_SERIE+'-'+QUERY->F2_DOC) desabilitado release 12.1.25	
				cMens :='NF ' + QUERY->F2_SERIE+'-'+QUERY->F2_DOC
				FwLogMSG( "INFO", , 'SIGAFAT', FunName(), '', '01', cMens, 0 )
				
				cXml := "" // QUERY->ARQXML
				//27/09/12 -> Primeiro parametro diz se envia e-mail ou não, atualmente usado somente pra preencher chaves
				//em notas cujo F2_CHVNFE está em branco pois o TSS já envia pdf junto com xml.
	   			GerPDF(.F.,QUERY->ID_ENT,QUERY->F2_DOC,QUERY->F2_SERIE,_cAuxMail,cXml,'',aEmp[nEmp,2],QUERY->REG) 
/*			else          
				//Considerar enviado quando não existir e-mail ou for e-mail para a propria empresa
				cRegNf := padl(alltrim(str(QUERY->REG)),6,"0")
				dbselectarea("SX5")
				dbseek(xFilial("SX5")+"95"+cRegNf)
				if !found()
					SX5->( RecLock( "SX5" , .T. ) )	
					SX5->X5_FILIAL := xFilial("SX5")	
					SX5->X5_TABELA := "95"	
					SX5->X5_CHAVE  := cRegNf 
				else
					SX5->( RecLock( "SX5" , .F. ) )	
				endif
				SX5->X5_DESCRI := "S"
				SX5->( MsUnlock() )								
			endif 
*/				

	   	
		   	DbSelectArea("Query")
	   		DbSkip()
		EndDo
	
		DbSelectArea("Query")
		DbCloseArea("QUERY")
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
Static Function GerPDF(lEnviaEmail,_cIdEnt,_cNumNF,_cSerie,_cEmail,cXML,cEmaTransp,cFil,nRegF2)
Local lAdjustToLegacy,_cDir,cAccount,cArquivo,cMens,;
aAnexos,cPassword,cPara,cDe,lSucesso,cRegNf,nFlags,cVar1,cVar2
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
	//U_PrtNfeSef(StrZero(Val(cFil),6),MV_PAR01,MV_PAR01,oDanfe,oSetup,cFilePrint,.t.,_cEmail,cXML,cEmaTransp, .f.)
	lSucesso := .t.
	if lEnviaEmail .and. ((";" $ _cEmail) .or. !(ALLTRIM(substr(_cEmail,AT("@",_cEmail),LEN(_cEmail))) $ alltrim(SuperGetMv("MV_RELAUSR"))))
		cAccount  	:= alltrim(SuperGetMv("MV_RELAUSR"))                        // MV_RELAUSR
		cPassword	:= Rtrim(SuperGetMv("MV_RELAPSW"))
		cServer   	:= Rtrim(SuperGetMv("MV_RELSERV"))
                                 		//               ****** NAO REATIVAR O ENVIO P/ O E-MAIL DA TRANSPORTADORA *******
		cPara    	:= AllTrim(_cEmail) // +';'+AllTrim(_cETran)       // +';faturamentosp@datasupri.com.br'    
                                 		//               ****** NAO REATIVAR O ENVIO P/ O E-MAIL DA TRANSPORTADORA *******
		cDe 	 	:= Rtrim(SM0->M0_NOMECOM)+" <"+alltrim(SuperGetMv("MV_RELAUSR"))+">" //Rtrim(SM0->M0_NOMECOM)

		aAnexos := {cArquivo}
		If File(cArquivo)
			lSucesso := EnvMail(cAccount	,cPassword	,cServer	,cDe,;
								cPara		,'DANFE referente sua Nota Fiscal Nº ' + MV_PAR01,'Segue Anexo a este email arquivo em Formato PDF ' + Chr(13)+Chr(10)+' do DANFE referente sua nota fiscal Nº ' + MV_PAR01 + ;
								Chr(13)+Chr(10)+Chr(13)+Chr(10)+'Por favor não responda a este e-mail.', aAnexos)                             
								
/*			If RecLock("SF2",.f.)
				SF2->F2_ENVPDF := "S"
				SF2->(MsUnlock())
			Endif*/
		Else
			//Conout("O(s) Arquivo(s) Não Foi(ram) Gerado(s) Corretamente") desabilitado release 12.1.25
			cMens := "O(s) Arquivo(s) Não Foi(ram) Gerado(s) Corretamente"
			FwLogMSG( "INFO", , 'SIGAFAT', FunName(), '', '01', cMens, 0 )
		Endif
    endif 
	if lSucesso       
		cRegNf := padl(alltrim(str(nRegF2)),6,"0")
		
	   //FwPutSX5(cFlavour, cTabela, cChave, cTextoPor, cTextoEng, cTextoEsp, cTextoAlt)
		FwPutSX5(/*cFlavour*/, "95", cRegNf, "S", /*cTextoEng*/, /*cTextoEsp*/, /*cTextoAlt*/)
		/* release 12.1.25
		dbselectarea("SX5")
		dbseek(xFilial("SX5")+"95"+cRegNf)
		if !found()
			SX5->( RecLock( "SX5" , .T. ) )	
			SX5->X5_FILIAL := xFilial("SX5")	
			SX5->X5_TABELA := "95"	
			SX5->X5_CHAVE  := cRegNf 
		else
			SX5->( RecLock( "SX5" , .F. ) )	
		endif
		SX5->X5_DESCRI := "S"
		SX5->( MsUnlock() )								
		*/
	endif 

	If File(cArquivo)
		fErase(cArquivo)
	endif 

Return

Static Function EnvMail(cAccount	,cPassword	,cServer	,cFrom,;
					cEmail		,cAssunto	,cMensagem	,aAttach)

Local cEmailTo := ""							// E-mail de destino
Local cEmailBcc:= ""							// E-mail de copia
Local lResult  := .F.							// Se a conexao com o SMPT esta ok
Local cError   := ""							// String de erro
Local lRelauth := SuperGetMv("MV_RELAUTH")		// Parametro que indica se existe autenticacao no e-mail
Local lRet	   := .F.							// Se tem autorizacao para o envio de e-mail
Local cConta   := ALLTRIM(cAccount)				// Conta de acesso 
Local cSenhaTK := ALLTRIM(cPassword)	        // Senha de acesso
Local nI,cAnexos, cMens
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia o mail para a lista selecionada. Envia como BCC para que a pessoa pense³
//³que somente ela recebeu aquele email, tornando o email mais personalizado.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cEmailTo := cEmail
If At(";",cEmail) > 0 // existe um segundo e-mail.
	cEmailBcc:= SubStr(cEmail,At(";",cEmail)+1,Len(cEmail))
Endif	

CONNECT SMTP SERVER cServer ACCOUNT cConta PASSWORD cSenhaTK RESULT lResult
lRet := lResult
// Se a conexao com o SMPT esta ok
If lRet

	// Se existe autenticacao para envio valida pela funcao MAILAUTH
	If lRelauth
		lRet := Mailauth(cConta,cSenhaTK)	
	Else
		lRet := .T.	
    Endif    

	cAnexos:=''
	For nI:=1 to Len(aAttach)
	  cAnexos+=aAttach[nI]+";"  
	Next
	cAnexos:=Left(cAnexos,Len(cAnexos)-1)
	
	If lRet
		SEND MAIL FROM cFrom ;
		TO      	cEmailTo;
		SUBJECT 	cAssunto;
		BODY    	cMensagem;
		ATTACHMENT  cAnexos  ;
		RESULT lResult
		lRet := lResult
		If !lRet
			//Erro no envio do email
			GET MAIL ERROR cError
			//Conout('Erro no Envio do Email '+cError+' - '+cEmailTo) DESABILITADO RELEASE 12.1.25
			cMens := 'Erro no Envio do Email '+cError+' - '+cEmailTo
			FwLogMSG( "INFO", , 'SIGAFAT', FunName(), '', '01', cMens, 0 )
//				Help(" ",1,'Erro no Envio do Email',,cError+ " " + cEmailTo,4,5)	//Atenção
		Endif

	Else
		GET MAIL ERROR cError

		//Conout('Erro de Autenticação. Verifique a conta e a senha para envio') desabilitada release 12.1.25
		cMens := 'Erro de Autenticação. Verifique a conta e a senha para envio'

		FwLogMSG( "INFO", , 'SIGAFAT', FunName(), '', '01', cMens, 0 )

/*		Help(" ",1,'Autenticação',,cError,4,5)  //"Autenticacao"
		MsgStop('Erro de Autenticação','Verifique a conta e a senha para envio') 		 //"Erro de autenticação","Verifique a conta e a senha para envio"
*/		
	Endif
		
	DISCONNECT SMTP SERVER
	
/*	For nI:=1 To Len(aAttach) 
		FErase(aAttach[nI]) 
	Next
*/	
Else
	//Erro na conexao com o SMTP Server
	GET MAIL ERROR cError
	//Conout('Erro no Envio do Email - '+cError) desabilitada release 12.1.25
	cMens := 'Erro no Envio do Email - '+cError
	FwLogMSG( "INFO", , 'SIGAFAT', FunName(), '', '01', cMens, 0 )
	
	
//	Help(" ",1,'Erro no Envio do Email',,cError,4,5)      //Atencao
Endif

Return(lRet)
