#INCLUDE "rwmake.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"
/*/
+---------------------------------------------------------------------------+
| Programa  ? MAN1276  ? Autor ? Claudio            ? Data ?  16/03/2012    |
+---------------------------------------------------------------------------+
| Descricao ? Carta de corre??o			                                    |
+---------------------------------------------------------------------------+
| Uso       ? FATURAMENTO                                                   |
|           ?                                                               |
|           ? ESTE PROGRAMA EMITE A CARTA DE CORRECAO ELETRONICA BASEADO    |
|           ? NAS TABELAS SPED050 E SPED150, E UTILIZA DUAS SP (STORED      |
|           ? PROCEDURES) PARA BUSCAR OS DADOS DESSAS TABELAS               |
|           ?                                                               |
|           ? **** ATENCAO ****                                             |
|           ? OLHE AS ROTINAS DE FORMATACAO DE TEXTO NO FINAL DESTE PROGRAMA|
+---------------------------------------------------------------------------+
/*/

User Function IMPCCE()                    
	//??????????????????????????????????????????????????????????????????????
	//? Declaracao de variaveis utilizadas no programa atraves da funcao    ?
	//? SetPrvt, que criara somente as variaveis definidas pelo usuario,    ?
	//? identificando as variaveis publicas do sistema utilizadas no codigo ?
	//? Incluido pelo assistente de conversao do AP5 IDE                    ?
	//???????????????????????????????????????????????????????????????????????

	SetPrvt("TAMANHO,WNREL,ARETURN,NLASTKEY,NTIPO,NTIPOA,CSTRING")
	SetPrvt("LEND,TITULO,TITULO2,CDESC1,CDESC2,CDESC3,CPERG")
	SetPrvt("NOMEPROG,M_PAG,aResult,aLinhas,vQuery")
	//???????????????????????????????????????????????????????????????
	//? Define Variaveis                                             ?
	//????????????????????????????????????????????????????????????????
	Tamanho  := "P"
	wnRel    := 'IMPCCE'
	aReturn  := { "Zebrado", 1,"Administracao", 1, 2, 1, "",0 }
	nLastKey := 0
	nTipo    := 18
	cString  :="SRA"
	lEnd     :=.F.
	cDesc1   := "Este relatorio ira imprimir a CARTA DE CORREÇÃO ELETRONICA (CC-e)"
	cDesc2   := ""
	cDesc3   := ""
	cPerg    := ""
	nomeprog := "IMPCCE"
	nLastKey := 0
	cabec1   := ""
	cabec2   := ""
	m_pag    := 01                 
	aResult  := {}                                 
	aLinhas  := {}                                
	vQuery   := "" 
    
	cperg    := "IMPCCE" 
	
	aHelp := {}
	AAdd( aHelp, 'Informe o número da Nota Fiscal que     ' )
	AAdd( aHelp, 'deseja imprimir a Carta de Correção     ' )
	//PutSX1( cPerg,"01","Número da Nota Fiscal?","Número da Nota Fiscal?","Número da Nota Fiscal?","mv_ch1","C",TamSX3("F2_DOC")[1],0,1,"C","","","","","mv_par01","","","","","","","","","","","","","","","","",aHelp,aHelp,aHelp)
	
	aHelp := {}
	AAdd( aHelp, 'Informe a série da Nota Fiscal que      ' )
	AAdd( aHelp, 'deseja imprimir a Carta de Correção     ' )
	//PutSX1( cPerg,"02","Série da Nota Fiscal?","Série da Nota Fiscal?","Série da Nota Fiscal?","mv_ch2","C",TamSX3("F2_SERIE")[1],0,1,"C","","","","","mv_par02","","","","","","","","","","","","","","","","",aHelp,aHelp,aHelp)
	
	IF !Pergunte(cPerg,.T.)
		Return
	Endif                                                             
	titulo   := "CARTA DE CORREÇÃO ELETRONICA - CCe"
	//???????????????????????????????????????????????????????????????
	//?Mv_par01  -  Nota                                            ?
	//?Mv_par02  -  Serie                                           ?
	//????????????????????????????????????????????????????????????????
	//???????????????????????????????????????????????????????????????
	//? Envia controle para a funcao SETPRINT                        ?
	//????????????????????????????????????????????????????????????????

	Processa({|| Gera1276()},"Gera Dados para impressão")  
	If !Empty(aResult)
		RptStatus({|| Imp1276()},"Imprimindo Relatório")
	Else
		MsgInfo("Essa NF-e não possui Carta de Correção... VERIFIQUE!!") 
	EndIf	

Return
//-------------------------------------------------------------------------------------------------
Static Function Gera1276()
//	Local cError   := ""
//	Local cWarning := ""
//	Local oXml := NIL
	
	vNfeId := mv_par02+mv_par01

	// verifica se existe a SP, e se n?o cria
	IF !TCSPExist("Pega_NFeId")
		vQuery := " IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'Pega_NFeId') BEGIN "+;
		"EXEC dbo.sp_executesql @statement = N'"
		vQuery += "Create Procedure Pega_NFeId ( "
		vQuery += " @IN_STR char(255), @OUT_STR varchar(8000) OUTPUT " 
		vQuery += " ) "
		vQuery += " WITH RECOMPILE "
		vQuery += " AS BEGIN "
		vQuery += " 	select @out_str = substring( "
		vQuery += " 	CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))),  "
		vQuery += " 	CHARINDEX(''infNFe Id='', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+14, 44) "
		vQuery += " 	from SPED050 "
		vQuery += " 	where NFE_ID = @in_str "
		vQuery += " 	and D_E_L_E_T_ <> ''*'' "
		vQuery += " END'; "
		vQuery += " END "
		_cret:=  TcSQLExec(vQuery)
		If !(_CRet==0)
			_cRet = TCSQLERROR()   
			APMsgAlert(AllTrim(_cRet),"MAN1276 - 93. Erro na criacao da SP1. Contactar Administrador do Sistema ")
			/*While !Empty(_cRet)
				APMsgAlert(AllTrim(_cRet),"MAN1276 - 93. Erro na criacao da SP1. Contactar Administrador do Sistema ")
				_cRet = TCSQLERROR()
			EndDo  */
		EndIf                                                                          
	EndIf	
                             
	IF !TCSPExist("Dados_CCe")
		vQuery := "IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'Dados_CCe') BEGIN "+;
		"EXEC dbo.sp_executesql @statement = N'"+;
		 "Create Procedure Dados_CCe ( "+;
		 "@IN_STR char(255), "+;
		 "@Versao varchar(4) Output, "+;
		 "@Id_lote varchar(1) Output, "+;
		 "@Id_Evento varchar(54) Output, "+;
		 "@Orgao varchar(2) Output, "+;
		 "@Ambiente varchar(1) Output, "+;
		 "@CNPJ varchar(14) Output, "+;
		 "@Chave_Acesso varchar(44) Output, "+;
		 "@Data_Evento varchar(10) Output, "+;
		 "@Hora_Evento varchar(8) Output, "+;
		 "@Cod_Evento varchar(6) Output, "+;
		 "@Seq_Evento varchar(1) Output, "+;
		 "@Versao_Evento varchar(3) Output, "+;
		 "@Det_Evento varchar(4) Output, "+;
		 "@Desc_Evento varchar(17) Output, "+;
		 "@Correcao varchar(8000) Output, "+;
		 "@Cond_Uso varchar(8000) Output "+;
		 ") "+;
		 "WITH RECOMPILE "+;
		 "AS BEGIN "+;
		 "	select "+;
		 "	@versao = substring(CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))), "+;
		 "	CHARINDEX(''versao='', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+8, 4), "+;
		 "	@id_lote = substring(CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))), "+;
		 "	CHARINDEX(''<idLote>'', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+8, 1), "+;
		 "	@id_evento = substring(CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))), "+;
		 "	CHARINDEX(''<infEvento Id='', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+15, 54), "+;
		 "	@orgao = substring(CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))), "+;
		 "	CHARINDEX(''<cOrgao>'', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+8, 2), "+;
		 "	@ambiente = substring(CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))),  "+;
		 "	CHARINDEX(''<tpAmb>'', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+7, 1), "+;
		 "	@CNPJ = substring(CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))), "+;
		 "	CHARINDEX(''<CNPJ>'', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+6, 14), "+;
		 "	@Chave_Acesso = substring(CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))), "+;
		 "	CHARINDEX(''<chNFe>'', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+7, 44), "+;
		 "	@Data_Evento = substring(CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))), "+;
		 "	CHARINDEX(''<dhEvento>'', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+10, 10), "+;
		 "	@Hora_Evento = substring(CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))), "+;
		 "	CHARINDEX(''<dhEvento>'', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+21, 8), "+;
		 "	@Cod_Evento = substring(CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))), "+;
		 "	CHARINDEX(''<tpEvento>'', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+10, 6), "+;
		 "	@Seq_Evento = substring(CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))), "+;
		 "	CHARINDEX(''<nSeqEvento>'', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+12, 1), "+;
		 "	@Versao_Evento = substring(CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))),  "+;
		 "	CHARINDEX(''<verEvento>'', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+11, 3), "+;
		 "	@Det_Evento = substring(CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))), "+;
		 "	CHARINDEX(''<detEvento versao='', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+19, 4), "+;
		 "	@Desc_Evento = substring(CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))), "+;
		 "	CHARINDEX(''<descEvento>'', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+12, 17), "+;
		 "	@Correcao = substring(CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))),  "+;
		 "	CHARINDEX(''<xCorrecao>'', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+11, "+;
		 "	CHARINDEX(''</xCorrecao>'', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))- "+;
		 "	CHARINDEX(''<xCorrecao>'', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))-11 ), "+;
		 "	@Cond_Uso = substring(CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))), "+;
		 "	CHARINDEX(''<xCondUso>'', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+10, "+;
		 "	CHARINDEX(''</xCondUso>'', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))- "+;
		 "	CHARINDEX(''<xCondUso>'', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))-10 ) "+;
		 "	from SPED150 "+;
		 "	where NFE_CHV = @in_str "+;
		 "	and D_E_L_E_T_ <> ''*'' "+;
		 "END';	 "+;
		 "END"
		 _cret:=  TcSQLExec(vQuery)
		If !(_CRet==0)
			_cRet = TCSQLERROR()
			APMsgAlert(AllTrim(_cRet),"MAN1276 - 168. Erro na criacao da SP2. Contactar Administrador do Sistema ")
			/*_cRet = TCSQLERROR()
			While !Empty(_cRet)
				APMsgAlert(AllTrim(_cRet),"MAN1276 - 168. Erro na criacao da SP2. Contactar Administrador do Sistema ")
				_cRet = TCSQLERROR()
			EndDo       */
		EndIf
	EndIf	
 
	//IF TCSPExist("Pega_NFeId")
		aResult := TCSPEXEC("Pega_NFeId",vNfeId)
		IF empty(aResult)
			MsgInfo("Erro na execução da Stored Procedure : "+TcSqlError()+" - Linha 68 - Avise ao Suporte T?cnico" ) 
			Return
		EndIf	
	//EndIf	
	                                  
	vNfeChv := AllTrim(aResult[1])
	aResult := {}
	If !Empty(vNfeChv)
		//IF TCSPExist("Dados_CCe")
			aResult := TCSPEXEC("Dados_CCe",vNfeChv )
			IF empty(aResult)
				MsgInfo("Erro na execu??o da Stored Procedure : "+TcSqlError()+" - Linha 79 - Avise ao suporte Tecnico") 
				Return
			Endif	
		//EndIf	
	EndIf	
Return(.t.)
//-------------------------------------------------------------------------------------------------
Static Function Imp1276()
	///----------------------------------    COMECA A IMPRESSAO   -------------------
//	Local   nCol	   := 800
//	Local   nHeight    := 08
//	Local   lBold	   := .F.
//	Local   lUnderLine := .F.
//	Local   lPixel	   := .T.
//	Local   lPrint	   := .F.         
	Local   vInd       
	Private nLin       := 10000
	Private nPage	   := 1
	
	/*------------------------------*/
	/* Define Fontes a serem usados     */
	/*------------------------------*/

	//oFont	:= TFont():New( "Arial"             ,,_xsize,,_xnegrito,,,,, lUnderLine ) 

	oFtA07	:= TFont():New( "Arial"  ,,07     ,,.f.  ,,,,, .f.  )
	oFtA07N	:= TFont():New( "Arial"  ,,07     ,,.t.  ,,,,, .f.  )
	oFtA08	:= TFont():New( "Arial"  ,,08     ,,.f.  ,,,,, .f.  )
	oFtA08N	:= TFont():New( "Arial"  ,,08     ,,.t.  ,,,,, .f.  )
	oFtA09	:= TFont():New( "Arial"  ,,09     ,,.f.  ,,,,, .f.  )
	oFtA09N	:= TFont():New( "Arial"  ,,09     ,,.t.  ,,,,, .f.  )
	oFtA10	:= TFont():New( "Arial"  ,,10     ,,.f.  ,,,,, .f.  )
	oFtA10N	:= TFont():New( "Arial"  ,,10     ,,.t.  ,,,,, .f.  )
	oFtA12	:= TFont():New( "Arial"  ,,12     ,,.f.  ,,,,, .f.  )
	oFtA12N	:= TFont():New( "Arial"  ,,12     ,,.t.  ,,,,, .f.  )
	oFtA14	:= TFont():New( "Arial"  ,,14     ,,.f.  ,,,,, .f.  )
	oFtA14N	:= TFont():New( "Arial"  ,,14     ,,.t.  ,,,,, .f.  )


	//OPen		:= TPen():New(0,5,CLR_BLACK)
	//		oPrint:Box(0530,1900,0730,2300)
	//		oPrint:FillRect({0530,1900,0730,2300},oBrush)
	//		oPrint:Line(nLinha,740,nLinha+70,740)
	nLin := 3000
			
	lAdjustToLegacy := .F. 
	lDisableSetup  := .T.

	oPrn := FWMSPrinter():New("CARTA DE CORRECAO ELETRONICA - CCe", 6, lAdjustToLegacy, , lDisableSetup)			
	oPrn:LPDFASPNG := .F.	
	oPrn:SetResolution(72)
	oPrn:SetPortrait()
	oPrn:SetPaperSize(9)  // a4
	oPrn:SetMargin(60,60,60,60) // nEsquerda, nSuperior, nDireita, nInferior 
	oPrn:cPathPDF := "c:\arqs\" // Caso seja utilizada impress?o em IMP_PDF		 
			
//	oPrn:= TMSPrinter():New() // Inicializa o Objeto de impressao
//	oPrn:SetLandscape()

	If nLin>480
		Cab977()
	Endif         

	oPrn:Say(nLin ,0210 ,"CARTA DE CORREÇÃO", 		oFta14N, 100 )                                  
	nlin+=40                        	

	oPrn:Say(nLin ,0010 ,"Versão", 		oFta12, 100 )                                  
	nlin+=10                        	
	oPrn:Say(nLin ,0010 ,aResult[1], 	oFta12, 100 )                                  
	nlin+=20                        	
	 	
	oPrn:Say(nLin ,0010 ,"Ambiente", 	oFta12, 100 )                                  
	oPrn:Say(nLin ,0120 ,"Id", 			oFta12, 100 )                                  
	oPrn:Say(nLin ,0420 ,"Orgão", 		oFta12, 100 )                                  
	nlin+=10                        	
	oPrn:Say(nLin ,0010 ,aResult[5], 	oFta12, 100 )                                  
	oPrn:Say(nLin ,0120 ,aResult[3], 	oFta12, 100 )                                  
	oPrn:Say(nLin ,0420 ,aResult[4], 	oFta12, 100 )                                  
	nlin+=20                        	
	
	oPrn:Say(nLin ,0010 ,"CNPJ", 			oFta12, 100 )                                  
	oPrn:Say(nLin ,0120 ,"Chave de Acesso",	oFta12, 100 )                                  
	oPrn:Say(nLin ,0420 ,"Data/Hora",		oFta12, 100 )                                  
	nlin+=10                        	
	oPrn:Say(nLin ,0010 ,aResult[6], 	oFta12, 100 )                                  
	oPrn:Say(nLin ,0120 ,aResult[7], 	oFta12, 100 )                                  
	oPrn:Say(nLin ,0420 ,aResult[8]+"-"+aResult[9], 	oFta12, 100 )                                  
	nlin+=20                        	

	oPrn:Say(nLin ,0010 ,"Cod. Evento",		oFta12, 100 )                                  
	oPrn:Say(nLin ,0120 ,"Seq. Evento",		oFta12, 100 )                                  
	oPrn:Say(nLin ,0420 ,"Versão Evento",	oFta12, 100 )                                  
	nlin+=10                        	
	oPrn:Say(nLin ,0010 ,aResult[10], 	oFta12, 100 )                                  
	oPrn:Say(nLin ,0120 ,aResult[11], 	oFta12, 100 )                                  
	oPrn:Say(nLin ,0420 ,aResult[12], 	oFta12, 100 )                                  
	nlin+=40                        	

	oPrn:Say(nLin ,0010 ,"INFORMAÇÕES DA CARTA DE CORREÇÃO",		oFta12N, 100 )                                  
	nlin+=40                        	

	oPrn:Say(nLin ,0010 ,"Versão",			oFta12, 100 )                                  
	oPrn:Say(nLin ,0210 ,"Descr. Evento",	oFta12, 100 )                                  
	nlin+=10                        	
	oPrn:Say(nLin ,0010 ,aResult[13], 	oFta12, 100 )                                  
	oPrn:Say(nLin ,0210 ,aResult[14], 	oFta12, 100 )                                  
	nlin+=40                        	
              
	oPrn:Say(nLin ,0010 ,"Texto da Carta de Correção",			oFta12, 100 )                                  
	nlin+=10                        	

	vTexto := u_FormatText(decodeutf8(aResult[15]), 100, aLinhas)
    For vInd := 1 to len(aLinhas)
		oPrn:Say(nLin ,0010 ,aLinhas[vInd, 1], 	oFta12, 100 )		
		nlin+=10                        	
	Next    	
	
	aLinhas := {}	
	nLin +=30

	oPrn:Say(nLin ,0010 ,"Condições de Uso da Carta de Correção",			oFta12, 100 )                                  
	nlin+=10                        	

	vTexto := u_FormatText(aResult[16], 100, aLinhas)
    For vInd := 1 to len(aLinhas)
		oPrn:Say(nLin ,0010 ,aLinhas[vInd, 1], 	oFta12, 100 )		
		nlin+=10                        	
	Next    	

	SetPgEject(.F.) // Funcao pra n?o ejetar pagina em branco 
	oPrn:Setup()   // para configurar impressora - comentar se quiser gerar o PDF direto.
//	oPrn:Preview() // Visualiza relatorio na tela     
	oPrn:Print() // Visualiza relatorio na tela
	Ms_Flush()             
Return .T.
//-------------------------------------------------------------------------------------------------
Static function Cab977()
	_cNomLogo := "LGRL"+cNumEmp+".bmp"
	_nLarg    := 150
	_nAlt     := 35                                 
	If nlin<10000
		oPrn:EndPage()
		oPrn:StartPage()
	Endif                    
	nLin := 30
	oPrn:SayBitmap( nlin  , 0010 , _cNomLogo     , _nLarg , _nAlt )
	nLin += 5
	oPrn:Say( nLin+5, 0470 , "Data : " + Dtoc(dDataBase)   , oFtA07 , 100 )      
	nLin += 10
	oPrn:Say( nLin+5, 0470 , "Pagina : " + StrZero(npage,3)     , oFtA07 , 100 )
	nLin += 10
	
  	oPrn:Say( nLin+710 , 0005 , nomeprog            , oFtA07 , 100 )
	oPrn:Say( nLin+710 , 0470 ,"Hora : " + Time()   , oFtA07 , 100 )      
	oPrn:Say( nLin+720 , 0005 , "SIGA/V.P11"        , oFtA07 , 100 )

	npage++
	nLin := 90    
Return(.t.)

/* 
AS ROTINAS ABAIXO S?O UTILIZADAS ACIMA, PARA FORMATAR OS TEXTOS DA CCE.
ESTAO COMENTADAS POIS AS COLOQUEI EM OUTRO PRW, ONDE DEIXO TODAS AS MINHAS ROTINAS COMUNS.
PARA UTILIZA-LAS, BASTA TIRAR OS COMENTARIOS ACIMA E NO FINAL DESSE ARQUIVO.
PS: ESTAS ROTINAS N?O S?O MINHAS. UMA ALMA CARIDOSA ESCREVEU EM CLIPPER E DISPONIBILIZOU NA INTERNET
FIZ APENAS ALGUMAS ADAPTACOES PARA RODAR EM ADVPL
*/
//----------------------------------------------------------------------------
User FUNCTION FormatText(cMemo, nLen)
//----------------------------------------------------------------------------
// Objetivo      : Formata linhas do campo memo                               *
// Observacao    :                                                            *
// Sintaxe       : FormatText(@cMemo, nLen)                                   *
// Parametros    : cMemo ----> texto memo a ser formatado                     *
//                 nLen  ----> tamanho de colunas por linha                   *
// Retorno       : array aLinhas - retorna o texto linha a linha              *
// Fun. chamadas : CalcSpaces()                                               *
// Arquivo fonte : Memo.prg                                                   *
// Arq. de dados : -                                                          *
// Veja tamb?m   : MemoWindow()                                               *
//----------------------------------------------------------------------------
   LOCAL nLin, cLin, lInic, lFim, aWords:={}, cNovo:="", cWord, lContinua, nTotLin, nAux, nNext, vInd
   lInic:=.T.
   lFim:=.F.
   nTotLin:=MLCOUNT(cMemo, nLen)
   FOR nLin:=1 TO nTotLin

      cLin:=RTRIM(MEMOLINE(cMemo, nLen, nLin)) //recuperar

      IF EMPTY(cLin) //Uma linha em branco ->Considerar um par?grafo vazio
         IF lInic  //Inicio de paragrafo
           aWords:={}  //Limpar o vetor de palavras
           lInic:=.F.
         ELSE
            AADD(aWords, CHR(13)+CHR(10)) //Incluir quebra de linha
         ENDIF
         AADD(aWords, CHR(13)+CHR(10)) //Incluir quebra de linha
         lFim:=.T.
      ELSE
         IF lInic  //Inicio de paragrafo
            aWords:={} //Limpar o vetor de palavras
            //Incluir a primeira palavra com os espacos que a antecedem
            cWord:=""
            WHILE SUBSTR(cLin, 1, 1)==" "
               cWord+=" "
               cLin:=SUBSTR(cLin, 2)
            END
            IF(nNext:=AT(SPACE(1), cLin))<>0
               cWord+=SUBSTR(cLin, 1, nNext-1)
            ENDIF
            AADD(aWords, cWord)
            cLin:=SUBSTR(cLin, nNext+1)
            lInic:=.F.
         ENDIF
         //Retirar as demais palavras da linha
         WHILE(nNext:=AT(SPACE(1), cLin))<>0
            IF !EMPTY(cWord:=SUBSTR(cLin, 1, nNext-1))
               IF cWord=="," .AND. !EMPTY(aWords)
                  aWords[LEN(aWords)]+=cWord
               ELSE
                  AADD(aWords, cWord)
               ENDIF
            ENDIF
            cLin:=SUBSTR(cLin, nNext+1)
         END
         IF !EMPTY(cLin) //Incluir a ultima palavra
            IF cLin=="," .AND. !EMPTY(aWords)
               aWords[LEN(aWords)]+=cLin
            ELSE
               AADD(aWords, cLin)
            ENDIF
         ENDIF
         IF nLin==nTotLin  //Foi a ultima linha -> Finalizar o paragrafo
            lFim:=.T.
         ELSEIF RIGHT(cLin, 1)=="." //Considerar que o 'ponto' finaliza paragrafo
            AADD(aWords, CHR(13)+CHR(10))
            lFim:=.T.
         ENDIF
      ENDIF

      IF lFim
         IF LEN(aWords)>0
            nNext:=1
            nAuxLin:=1
            WHILE nAuxLin<=LEN(aWords)
               //Montar uma linha formatada
               lContinua:=.T.
               nTot:=0
               WHILE lContinua
                  nTot+=(IF(nTot=0, 0, 1)+LEN(aWords[nNext]))
                  IF nNext==LEN(aWords)
                     lContinua:=.F.
                  ELSEIF (nTot+1+LEN(aWords[nNext+1]))>=nLen
                     lContinua:=.F.
                  ELSE
                     nNext++
                  ENDIF
               END
               IF nNext==LEN(aWords)  //Ultima linha ->Nao formata
                  FOR nAux:=nAuxLin TO nNext
                     cNovo+=(IF(nAux==nAuxLin, "", " ")+aWords[nAux])
                  NEXT
               ELSE //Formatar
                  FOR nAux:=nAuxLin TO nNext
                     cNovo+=(CalcSpaces(nNext-nAuxLin, nLen-nTot-1, nAux-nAuxLin)+aWords[nAux])
                  NEXT
                  cNovo+=" "
               ENDIF
               nNext++
               nAuxLin:=nNext
            END
         ENDIF

         lFim:=.F.  //Indicar que o fim do paragrafo foi processado
         lInic:=.T. //Forcar inicio de paragrafo

      ENDIF

   NEXT

   //Retirar linhas em branco no final
   WHILE LEN(cNovo)>2 .AND. (RIGHT(cNovo, 2)==CHR(13)+CHR(10))
      cNovo:=LEFT(cNovo, LEN(cNovo)-2)
   END

	For vInd := 0 to (len(cNovo)/nLen)
		AADD(aLinhas, {Substr(cNovo, (vInd*nLen)+1, nLen) } )
	Next		

RETURN(cNovo)

//----------------------------------------------------------------------------
Static FUNCTION CalcSpaces(nQt, nTot, nPos)
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
// Objetivo      : Calcula espacos necessarios para completar a linha         *
// Observacao    :                                                            *
// Sintaxe       : CalcSpaces(nQt, nTot, nPos)                                *
// Parametros    : nQt  ---> quantidade de separacoes que devem existir       *
//                 nTot ---> total de caracteres em branco excedentes a serem *
//                           distribuidos                                     *
//                 nPos ---> a posicao de uma separacao em particular         *
//                           (comecando do zero)                              *
// Retorno       : a separacao ja pronta de posicao nPos                      *
// Fun. chamadas : -                                                          *
// Arquivo fonte : Memo.prg                                                   *
// Arq. de dados : -                                                          *
// Veja tamb?m   : MemoWindow()                                               *
//----------------------------------------------------------------------------
LOCAL cSpaces,; //Retorno de espacos
      nDist,;   //Total de espacos excedentes a distribuir em cada separacao
      nLim      //Ate que posicao devera conter o resto da divisao

   IF nPos==0
      cSpaces:=""
   ELSE
      nDist:=INT(nTot/nQt)
      nLim:=nTot-(nQt*nDist)
      cSpaces:=REPL(SPACE(1), 1+nDist+IF(nPos<=nLim, 1, 0))
   ENDIF

RETURN cSpaces
/*
//----------------------------------------------------------------------------
STATIC FUNCTION Position(nMode, nRow, nCol, lEdicao)
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
// Objetivo      : Mostra linha e coluna na edicao do campo memo              *
// Observacao    :                                                            *
// Sintaxe       : Position(nMode, nRow, nCol, lEdicao)                       *
// Parametros    : nMode ---> Nome da funcao de controle da memoedit          *
//                 nRow  ---> Linha                                           *
//                 nCol  ---> Coluna                                          *
//                 lEdicao -> .T. p/ edicao .F. p/ consulta  de campo memo    *
// Retorno       : NIL                                                        *
// Fun. chamadas : FillString()                                               *
// Arquivo fonte : Memo.prg                                                   *
// Arq. de dados : -                                                          *
// Veja tamb?m   : MemoWindow()                                               *
//----------------------------------------------------------------------------
STATIC nPictRow, nPictCol

LOCAL cRow, cCol

IF lEdicao
   IF nMode==1
      nPictRow:=nRow
      nPictCol:=nCol
      FillString(nPictRow, nPictCol-5, " Lin    ")
      FillString(nPictRow, nPictCol+3, " Col    ")
      nRow:=0
      nCol:=0
   ENDIF
   FillString(nPictRow, nPictCol, PADR(ALLTRIM(STR(nRow)),3))
   FillString(nPictRow, nPictCol+8, PADR(ALLTRIM(STR(nCol)),3))
ENDIF

RETURN NIL
*/
/*
//----------------------------------------------------------------------------
STATIC FUNCTION FillString(nRow, nCol, cString)
//----------------------------------------------------------------------------*
// Objetivo      : Imprime uma string na tela sem mudar a cor de fundo        *
// Observacao    :                                                            *
// Sintaxe       : fillstring(a,b,c)                                          *
// Parametros    : nRow  ----> linha                                          *
//                 nCol  ----> coluna                                         *
//                 cString --> string                                         *
// Retorno       : NIL                                                        *
// Fun. chamadas : -                                                          *
// Arquivo fonte : Memo.prg                                                   *
// Arq. de dados : -                                                          *
// Veja tamb?m   : MemoWindow()                                               *
//----------------------------------------------------------------------------
LOCAL cArea, cNewArea, nK, nLen

nLen     := LEN(cString)
cArea    := SAVESCREEN(nRow, nCol, nRow, nCol+nLen-1)
cNewArea := ""
FOR nK := 1 TO nLen
   cNewArea += SUBSTR(cString, nK, 1)+SUBSTR(cArea, 2*nK, 1)
NEXT
RESTSCREEN(nRow, nCol, nRow, nCol+nLen-1, cNewArea)

RETURN NIL
*/