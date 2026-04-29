//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
#Include "BRQIPR050.Ch"
 
//Alinhamentos
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2
 
//Cores
#Define COR_CINZA   RGB(180, 180, 180)
#Define COR_PRETO   RGB(000, 000, 000)
 
//Colunas
#Define COL_NOTA    0015
#Define COL_LOTE    0095
#Define COL_OP      0120
#Define COL_CLIENTE 0210

/*/{Protheus.doc} brqip050
Exemplos de FWMSPrinter
@author Atilio
@since 27/01/2019
@version 1.0
@type function
/*/
User Function BRQIP050(ccLote,ccCliente,ccLoja,aAnexoss)
    Local   aArea    := GetArea()  
    Private lJob     := .T.
	Private xcLote   := ccLote
	Private xCliente := ccCliente
	Private xLoja    := ccLoja

/*     
    //Chamado pelo Schedule
	If Select("SX2") <> 0
      SX2->(dbCloseArea())
    Endif
	dbSelectArea("SX2")
    If Select("SX2") < 40
       //Preparando o ambiente
       lJob := .T.
       RPCSetType(3)
       RPCSetEnv("01", "01", "", "", "")
    EndIf
*/
    lJob := .T.
    //Se for execução automática, não mostra pergunta, executa direto
    If lJob
        Processa({|| fMontaRel()}, "Processando...")
         
    //Senão, se a pergunta for confirmada, executa o relatório
    Else
        If MsgYesNo("Deseja gerar o relatório de grupos de produtos?", "Atenção")
            Processa({|| fMontaRel()}, "Processando...")
        EndIf
    EndIf
     
   RestArea(aArea) 
Return()
 
/*---------------------------------------------------------------------*
 | Func:  fMontaRel                                                    |
 | Desc:  Função que monta o relatório                                 |
 *---------------------------------------------------------------------*/
 
Static Function fMontaRel()
    Local cCaminho    := ""
    Local cArquivo    := ""
//  Local aAnexos     := "" 

    //Linhas e colunas
    Private nLinAtu   := 0
    Private nTamLin   := 10
    Private nLinFin   := 0
    Private nColIni   := 001
    Private nColFin   := 550
    Private nColMeio  := (nColFin-nColIni)/2

	//Objeto de Impressão
    Private oPrintPvt

    //Variáveis auxiliares
    Private dDataGer  := Date()
    Private cHoraGer  := Time()
    Private nPagAtu   := 1
    Private cNomeUsr  := UsrRetName(RetCodUsr())

    //Fontes
    Private cNomeFont := "Arial"
    Private oFontDet  := TFont():New(cNomeFont, 9, -08, .T., .F., 5, .T., 5, .T., .F.)
    Private oFontDetN := TFont():New(cNomeFont, 9, -15, .T., .T., 5, .T., 5, .T., .F.)
    Private oFontRod  := TFont():New(cNomeFont, 9, -08, .T., .F., 5, .T., 5, .T., .F.)
    Private oFontTit  := TFont():New(cNomeFont, 9, -13, .T., .T., 5, .T., 5, .T., .F.)
     
    //Se for via JOB, muda as parametrizações
    If lJob
        //Define o caminho dentro da protheus data e o nome do arquivo
        cCaminho := "\SPOOL\" 
        cArquivo := "BRQIP050_" + dToS(dDataGer) + "_" + StrTran(cHoraGer, ':', '-') + ".pdf"

        //Se não existir a pasta na Protheus Data, cria ela
        If !ExistDir(cCaminho)
            MakeDir(cCaminho)
        EndIf
     //--------------------------------------------------------------------------------------------- 28/11/2023    
        //Cria o objeto FWMSPrinter
        oPrintPvt := FWMSPrinter():New(cArquivo, IMP_PDF, .F., '', .T., .F., , , .T., .T., , .F.)
        oPrintPvt:cPathPDF := cCaminho
    //--------------------------------------------------------------------------------------------- 28/11/2023     
    Else
        //Definindo o diretório como a temporária do S.O. e o nome do arquivo com a data e hora (sem dois pontos)
        cCaminho  := "\SPOOL\"
        cArquivo  := "BRQIP050_" + dToS(dDataGer) + "_" + StrTran(cHoraGer, ':', '-') + ".pdf"
         
        //Criando o objeto do FMSPrinter
        oPrintPvt := FWMSPrinter():New(cArquivo, IMP_PDF, .F., "", .T., , @oPrintPvt, "", , , , .T.)
    EndIf
     
    //Setando os atributos necessários do relatório
    oPrintPvt:SetResolution(72)
    oPrintPvt:SetPortrait()
    oPrintPvt:SetPaperSize(DMPAPER_A4)
    oPrintPvt:SetMargin(60, 60, 60, 60)

    fImpcert()
     
    //Se for via job, imprime o arquivo para gerar corretamente o pdf
    If lJob
        oPrintPvt:Print()
         
       //Atenção! - é necessário baixar a função zEnvMail() - disponível em https://terminaldeinformacao.com/2017/10/17/funcao-dispara-e-mail-varios-anexos-em-advpl/
       aAdd(aAnexoss, cCaminho + cArquivo)
//     aAnexos  := cCaminho + cArquivo  
//     U_EnvMail("Laudo !! do Produto","CERTIFICADO DE QUALIDADE DE PRODUTOS BRASILUX ","joseuliana@brasilux.com.br","joseuliana@brasilux.com.br",aAnexos) 
    //Se for via manual, mostra o relatório
    Else
     oPrintPvt:Preview()
    EndIf
  Return()
 
//---------   Certifica de Qualidade ----------------------------------------------------------------
Static Function fImpcert()
Private lEnd	:=.F.
Private aListBox:={}
Private cPerg1	:="QPR051"
Private  __cPRODUTO := CriaVar("QP6_PRODUT") //Codigo do Produto, quando a Especificacao for em Grupo      
Private lProduto   := .F.


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Janela Principal                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aListBox,OemToAnsi(STR0004))		//" Texto Superior "
AADD(aListBox,OemToAnsi(STR0005))		//" Texto Inferior "
AADD(aListBox,OemToAnsi(STR0034))		//" Informacoes Complementares "
AADD(aListBox,OemToAnsi(STR0006))		//" Impressao "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa ListBox com opcoes para o array da configuracao          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

R050IMP(xcLote)

//ACTIVATE MSDIALOG oDlgGet CENTERED
Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Ativa Tela para preenchimento do conteudo relacionado com o ³±±
±±³          ³ListBox.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³BRQIPR050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R050Text(oListBox)
Local oDlgGet2
Local oTexto
Local cTexto 		:= ""
Local oFontDialog	:= TFont():New("Arial",6,15,,.T.)

nAt:=oListBox:nAt

cNomeArq := "X"
nHdl:=MSFCREATE(cNomeArq,0)
If nHdl <= -1
	HELP(" ",1,"NODIRCQ")
	Return .T.
Else
	If File(cNomeArq)
		FCLOSE(nHdl)
		FERASE(cNomeArq)
	Endif
Endif

cNomeArq := "QPR050"+Str(nAt,1)+".TXT"

While .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Le arquivo                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTexto:=MemoRead(cNomeArq)
		
	DEFINE MSDIALOG oDlgGet2 FROM	62,100 TO 345,610 TITLE  OemToAnsi(STR0008) PIXEL FONT oFontDialog		//"Itens de Configura‡Æo"
	@ 003, 004 TO 027, 250 LABEL "" 	OF oDlgGet2 PIXEL
	@ 040, 004 TO 110, 250				OF oDlgGet2 PIXEL
		
	@ 013, 010 MSGET aListBox[nAt]		             WHEN .F. SIZE 235, 010 OF oDlgGet2 PIXEL
	@ 050, 010 GET oTexto VAR cTexto MEMO NO VSCROLL WHEN .T. SIZE 235, 051 OF oDlgGet2 PIXEL
		
	DEFINE SBUTTON FROM 120,190 TYPE 1 ACTION (MemoWrit( cNomeArq,cTexto ),FCLOSE(cNomeArq),oDlgGet2:End()) ENABLE OF oDlgGet2
	DEFINE SBUTTON FROM 120,220 TYPE 2 ACTION oDlgGet2:End() ENABLE OF oDlgGet2
		
	ACTIVATE MSDIALOG oDlgGet2 CENTERED
	Exit
EndDo

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R050Imp  ³ Autor ³     Marcelo Pimentel  ³ Data ³ 08.04.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Certificado                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaQIP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R050Imp(xcLote)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Par„metros para a fun‡„o SetPrint () ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL wnrel		:="BRQIP050"
LOCAL cString	:="QPR"
// Jose 05/12/2023 LOCAL cDesc1	:="Neste relatório será impresso os Certificado de Análise de Qualidade de produtos Brasilux"
// Jose 05/12/2023 LOCAL cDesc2	:=""
// Jose 05/12/2023 LOCAL cDesc3	:=""
Local nVias     :=0
Local cNota     :=""
Local cSerie    :=""
Local cRevi     :=""
Local nImpEns   :=0
Local lAchou    :=.F. 
Local cImprCQ   := GETMV("MV_QIMPRCQ")

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// ³ Parametros para a função Cabec()  ³
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cTitulo 	:="CERTIFICADO DE QUALIDADE BRASILUX"	
PRIVATE cRelatorio	:="BRQIP050"
PRIVATE nTamanho	:="M"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas pela função SetDefault () ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aReturn 	:= {"Zebrado", 1,"Administracao",  1, 2, 1, "",1 }	
PRIVATE nLastKey 	:= 0
PRIVATE cPerg		:= "QPR050"
PRIVATE cPergR		:= "QPR50R"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01           // Cliente                                ³
//³ mv_par02           // Loja do Cliente                        ³
//³ mv_par03           // Produto                                ³
//³ mv_par04           // Data da Producao                       ³
//³ mv_par05           // Lote                                   ³
//³ mv_par06           // Lote                                   ³
//³ mv_par07           // Nr. de Vias                            ³
//³ mv_par08           // Revisao                                ³
//³ mv_par09           // Impr. Ensaio Texto (Primeira/Todas)    ³
//³ mv_par10           // Nota Fiscal                            ³
//³ mv_par11           // Serie                                  ³
//³ mv_par12           // Ordem de Produção                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//  verificar aqui  06/11/2023   Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If FunName() == "QIPA215"           

//  wnrel := SetPrint(cString,wnrel,cPergR,@ctitulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,nTamanho)

	//Salva variaveis do pergunte QIPR501
	nVias     :=mv_par01
	cRevi     :=Iif(Empty(AllTrim(QPK->QPK_REVI)),QA_UltRevEsp(QPK->QPK_PRODUT,,,,"QIP"),QPK->QPK_REVI)
	nImpEns   :=mv_par03
	cNota     :=mv_par04
	cSerie    :=mv_par05

	Pergunte(cPerg,.F.)
	
	//Atualiza variaveis do pergunte padrao do relatorio QIPR050
	mv_par01  := cIPCLIENT        // Cliente                                
	mv_par02  := cIPLoj           // Loja do Cliente                        
	mv_par03  := QPK->QPK_PRODUT  // Produto  
	
	//Pesquisa data da medição.
	If Select("QPR") <> 0
       QPR->(dbCloseArea())
    Endif
	dbSelectArea("QPR")     
    dbSetOrder(9)
    If dbSeek(xFilial("QPR")+QPK->QPK_OP+QPK->QPK_LOTE+QPK->QPK_NUMSER)
    	mv_par04  := QPR->QPR_DTENTR     
	Else 
		mv_par04  := QPK->QPK_DTPROD	
	EndIf                      
	
	mv_par05  := QPK->QPK_LOTE	   // Lote                                   
	mv_par06  := QPK->QPK_NUMSER   // Numero do Lote                                   
	mv_par07  := nVias             // Nr. de Vias                            
	mv_par08  := cRevi             // Revisao                                
	mv_par09  := nImpEns           // Impr. Ensaio Texto (Primeira/Todas)    
	mv_par10  := cNota             // Nota Fiscal                            
	mv_par11  := cSerie            // Serie  
	mv_par12  := QPK->QPK_OP       // Ordem de Produção  
	
Else
//	wnrel := SetPrint(cString,wnrel,cPerg,@ctitulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,nTamanho)

    MV_PAR05 := xcLote  
	If Select("QPK") <> 0
       QPK->(dbCloseArea())
    Endif
	DbSelectArea("QPK")
	DbSetOrder(3)
	If DbSeek(xFilial("QPK")+MV_PAR05)

		If Found()	
			mv_par03  := QPK->QPK_PRODUT  // Produto  
			mv_par04  := QPK->QPK_DTPROD  // Data Produção
   			mv_par05  := QPK->QPK_LOTE	  // Lote                                   
			mv_par06  := QPK->QPK_NUMSER  // Numero do Lote  
			mv_par08  := QPK->QPK_REVI    // Revisao 
			mv_par12  := QPK->QPK_OP      // Ordem de Produção        
   			While !EOF() .AND. AllTrim(QPK->QPK_PRODUT) == AllTrim(MV_PAR03)
	   		    If cImprCQ == "N"
   			   		If DTOS(QPK->QPK_DTPROD) == DTOS(MV_PAR04)  .AND. AllTrim(QPK_OP) == AllTrim(MV_PAR12)   .AND. AllTrim(QPK_LOTE) == AllTrim(MV_PAR05) .AND.;
	    	           AllTrim(QPK_NUMSER) == AllTrim(MV_PAR06) .AND. AllTrim(QPK_REVI) == AllTrim(MV_PAR08) .AND. !Empty(QPK_CERQUA)
        			   lAchou := .T.  
        			   Exit
	        		EndIf
    	       		DbSkip()
        	    Else
            	 	If DTOS(QPK->QPK_DTPROD) == DTOS(MV_PAR04)  .AND. AllTrim(QPK_OP) == AllTrim(MV_PAR12) .AND. AllTrim(QPK_LOTE) == AllTrim(MV_PAR05) .AND.;
	            	   AllTrim(QPK_NUMSER) == AllTrim(MV_PAR06) .AND. AllTrim(QPK_REVI) == AllTrim(MV_PAR08) 
        			   lAchou := .T.  
	        		   Exit
    	    		EndIf
        	   		DbSkip() 
            	Endif
	   		EndDo
   		
   		Endif
   		
   		If !lAchou
			MsgInfo(STR0043) // "Identificada inconsistencia, favor verificar (Ordem de Producao + Lote + Num Serie + Produto + Revisao)"
			Return()
   		EndIf   
	Else
		MsgInfo(STR0044) // "Identificada inconsistencia, favor verificar a chave (Produto + Data Producao)"
		return()
	EndIf

EndIF
/*   -----------------      jOSE 21/02/2024 ----------------------------------
If nLastKey == 27
	Set Filter to
	Return
Endif

If substring(cNumEmp,1,2) <> '11'
	If Select("SC5") <> 0
       SC5->(dbCloseArea())
    Endif
	dbSelectArea("SC5")     
    dbSetOrder(9)
    If dbSeek( xFilial("SC5")+Alltrim(MV_PAR05) )
         IF ((cNumEmp = "01010101") .or. (cNumEmp = "01060101")) .and. (SC5->C5_LAUDO = "S")
            cAuxMens := "Nota Fiscal nro "+SC5->C5_CLIENTE+", pedido nro "+SC5->C5_NUM+", CLIENTE : "+SC5->C5_CLIENTE+"-"+ ALLTRIM(IIF(SC5->C5_TIPO $ "D_B",SC5->C5_EMISSAO,SC5->C5_TRANSP))+;
            " LAUDO ENVIADO"
          If Substr(xFilial("SF2"),1,2)== "06"
		       U_EnvMail("Nota Fiscal "+SC5->C5_NUM+" possui laudo" ,cAuxMens,"joseuliana@brasilux.com.br","")  // "laudo@dissoltex.com.br" 
		   Else
		       U_EnvMail("Nota Fiscal "+SC5->C5_DOC+" possui laudo" ,cAuxMens,"joseuliana@brasilux.com.br","")  // "laudo@brasilux.com.br","faturamento@brasilux.com.br"
		   Endif
        ENDIF 
	EndIf 
Endif

If nLastKey == 27
	Set Filter to
	Return
Endif
---------------------  ATÉ AQUI   joSE 21/02/2024     --------------------*/
RptStatus({|lEnd| A050Imp(@lEnd,wnRel,cString,cTitulo)},ctitulo)

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A050Imp  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 08.04.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rela‡Æo dos Certificados                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A050Imp(lEnd,wnRel,cString)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaQIP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A050Imp(lEnd,wnRel,cString,cTitulo)
Local cAcentos		:="€ú‡úúú…ú†úƒú úúˆú‚ú¡ú“ú”ú¢ú™ú£ú",cAcSubst := "C,c,A~A'a`a~a^a'E'e^e'i'o^o~o'O~U'"
Local aMeses		:={"JANEIRO","FEVEREIRO","MARÇO","ABRIL","MAIO","JUNHO","JULHO","AGOSTO","SETEMBRO","OUTUBRO","NOVEMRO","DEZEMBRO"}	
Local dDat			:=Ctod("  /  /  ")
Local cCliente		:= xCliente // jose 28/11/2023   mv_par01
Local cLoja			:= xLoja    // Jose 28/11/2023   mv_par02
Local cData			:= ""
Local cArqTxt		:= ""
Local cTexto		:= ""
Local cImpTxt		:= ""
Local cEnsaio		:= ""
Local cChave		:= ""
Local cSeek			:= ""
Local cTxtRes		:= ""
Local cTxt			:= ""
Local cLabor		:= ""
Local cRevi			:= If(Empty(mv_par08),QA_UltRevEsp(mv_par03,,,,"QIP"), mv_par08) 
Local cLote			:= ""
Local cProdut       := ""
Local cLaborat		:= ""
Local dValidade
Local aTexto		:= {}
Local aTxtRes		:= {}
Local aLinha		:= {}
Local cImpLinha   	:= {}
//Local cbCont		:= 00
Local nVlrMin		:= 999999
Local nVlrMax		:= -999999
Local nVlrUnic		:= 0
Local nC			:= 0
Local nCount		:= 0
Local nV			:= 1
Local nX			:= 0
Local nAmostra		:= 0
Local nPorcent		:= 0
Local lUnic			:= .T.
Local nContador	    := 1
Local cOp			:= mv_par12
Local cOperacao  	:= ""
Local cRoteiro  	:= ""
//Local CbTxt
Local cNomArq		:= ""
Local cPrd 			:= mv_par03
Local dDatOP		:= mv_par04
Local cLot			:= Padr(mv_par05,TamSX3("QPR_LOTE")[1]) 
Local cNumSer       := Padr(mv_par06,TamSX3("QPR_NUMSER")[1]) 
Local lEnsaio		:= .F.
Local lChecaQQ7		:= .F.
Local aAreaQPR		:= {}
Local lImpTxt       := .T.
Local lPula         := .T.
Local nMedia        := 0
Local nPosQPR       := 0
Local nOrdQPR       := 0
Local nPosQQ7       := 0
Local nOrdQQ7       := 0
Local nPosSA1       := 0
Local nOrdSA1       := 0
Local nPosQP6       := 0
Local nOrdQP6       := 0
Local nPosSC2       := 0
Local nOrdSC2       := 0
Local nRecQPR       := 0
Local _DesOP        := ""
//----------   Jose 04/12/2023   ---------------
Local cCamilogo    := ""
Local cArqulogo    := ""
Local cCaminhoLogo := ""
//----------------------------------------------

Private Titulo 	    := cTitulo
Private Cabec1      := ""
Private Cabec2	    := ""
Private	nomeprog    := "BRQIP050"
Private cTamanho    := "M"
Private nTipo	    := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

m_pag    := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se deve comprimir ou nao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTipo := If(aReturn[4]==1,15,18)

If Empty(mv_par12)
	If Select("QPR") <> 0
       QPR->(dbCloseArea())
    Endif
	dbSelectArea("QPR")
	dbSetOrder(6)
	DbSeek(xFilial("QPR")+cPrd+cRevi+Dtos(dDatOP)+cLot)
Else 
	If Select("QPR") <> 0
       QPR->(dbCloseArea())
    Endif
	dbSelectArea("QPR") 
	dbSetOrder(1)
	DbSeek(xFilial("QPR")+cOp)
EndIf
nPosQPR  := QPR->(RecNo())
nOrdQPR  := QPR->(IndexOrd())

If Select("SC2") <> 0
   SC2->(dbCloseArea())
Endif
dbSelectArea("SC2") 
dbSetOrder(1)
If !Empty(QPR->QPR_OP)
	cSeek := QPR->QPR_OP
Else
	cSeek := cOp
Endif
If dbSeek(xFilial("SC2")+cSeek)
	nPosSC2  := SC2->(RecNo())
	nOrdSC2  := SC2->(IndexOrd())
	cRoteiro := SC2->C2_ROTEIRO
Endif

If Select("QPK") <> 0
   QPK->(dbCloseArea())
Endif
dbSelectArea("QPK")
dbSetOrder(1)
If !Empty(QPR->QPR_OP)
	cSeek := QPR->QPR_OP+cLot+cNumser
Else
	cSeek := cOp+cLot+cNumser
Endif
If dbSeek(xFilial("QPK")+cSeek)
	nPosQQ7  := QQ7->(RecNo())
	nOrdQQ7  := QQ7->(IndexOrd())
Endif
                    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe amarração Cliente x Produto               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cCliente) .and. !Empty(QPR->QPR_CLIENT)
	If QPK->(FieldPos("QPK_CLIENT"))>0
		cCliente := QPK->QPK_CLIENT
		cLoja    := QPK->QPK_LOJA
	Else
		cCliente := QPR->QPR_CLIENT
		cLoja    := QPR->QPR_LOJA
	EndIF
EndIF 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01           // Resultados:1-Minimo/Maximo 2-Vlr.Unico ³
//³ mv_par02           // Observacao da Entrega:  1-Sim 2-Nao    ³
//³ mv_par03           // Justificativa do Laudo: 1-Sim 2-Nao    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg1,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona em Registros de outros arquivos                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("QQ7") <> 0
   QQ7->(dbCloseArea())
Endif
dbSelectArea("QQ7")
dbSetOrder(1)
If dbSeek(xFilial("QQ7")+QPR->QPR_PRODUT+cCliente+cLoja)
	nPosQQ7  := QQ7->(RecNo())
	nOrdQQ7  := QQ7->(IndexOrd())
Endif

If Select("SA1") <> 0
   SA1->(dbCloseArea())
Endif
dbSelectArea("SA1")
dbSetOrder(1)
If dbSeek(xFilial("SA1")+cCliente+cLoja)
	nPosSA1  := SA1->(RecNo())
	nOrdSA1  := SA1->(IndexOrd())
Endif

If Select("QP6") <> 0
   QP6->(dbCloseArea())
Endif
dbSelectArea("QP6")
dbSetOrder(1)
If !Empty(QPR->QPR_PRODUT)
	cSeek := QPR->QPR_PRODUT+Inverte(QPR->QPR_REVI)
Else
	cSeek := cPrd+Inverte(cRevi)
Endif
If dbSeek(xFilial("QP6")+cSeek)
	nPosQP6  := QP6->(RecNo())
	nOrdQP6  := QP6->(IndexOrd())
Endif

If Select("QPL") <> 0
   QPL->(dbCloseArea())
Endif
dbSelectArea("QPL")
dbSetOrder(3)
If dbSeek(xFilial("QPL")+QPK->QPK_OP+QPK->QPK_LOTE+QPK->QPK_NUMSER+cRoteiro+Space(TamSX3("QPL_OPERAC")[1])+Space(TamSX3("QPL_LABOR")[1]))
	If Select("QPD") <> 0
       QPD->(dbCloseArea())
    Endif
	dbSelectArea("QPD")
	dbSetOrder(1)
	If dbSeek(xFilial("QPD")+QPL->QPL_LAUDO)
		If QPD->QPD_CATEG == '4'
			MessageDlg(OemToAnsi(STR0035),OemToAnsi(STR0036),2)	//'Devido o laudo estar com Libera‡Æo Urgente, nÆo ser  poss¡vel emitir o Certificado de Qualidade.'###'Aten‡Æo'
	        If Select("QPR") <> 0
               QPR->(dbCloseArea())
            Endif
			dbSelectArea("QPR")
			RetIndex("QPR")
			dbSetOrder(1)
			Set Filter To
			If File(cNomArq+OrdBagExt())
				Ferase(cNomArq+OrdBagExt())
			EndIf
			Return .T.
		EndIf	
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclusao do Certificado de qualidade ao Titulo.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitulo += " - " +QPK->QPK_CERQUA

If Empty(mv_par07)
	mv_par07 := 1
EndIf

SetRegua(mv_par07)

For nContador := 1 To mv_par07
	IncRegua(nContador)		//Incrementar a Regua
	If nContador > 1
		//Retorna a Ordem/Posicao Atual dos arquivos para  executar uma  nova  impressao do certificado
		QPR->(DbGoto(nPosQPR))
		QPR->(DbSetOrder(nOrdQPR))
		QQ7->(DbGoto(nPosQQ7))
		QQ7->(DbSetOrder(nOrdQQ7))
		SA1->(DbGoto(nPosSA1))
		SA1->(DbSetOrder(nOrdSA1))
		QP6->(DbGoto(nPosQP6))
		QP6->(DbSetOrder(nOrdQP6))
		SC2->(DbGoto(nPosSC2))
		SC2->(DbSetOrder(nOrdSC2))
		cOperacao:= ""
		cLabor:= ""
		lEnsaio		:=.F.
	EndIf
	m_pag := 1
	Cabec(cTitulo,Cabec1,Cabec2,nomeprog,cTamanho,nTipo,,.F.)
	nLinAtu := 15
    oPrintPvt:Say(nLinAtu, 005, Replicate("-",155), oFontDetN,,, COR_PRETO, PAD_LEFT, 0)

    nLinAtu += nTamLin
	cCamilogo    := "\Spool\"
    cArqulogo    := "LogoBrasilux.png"
	cCaminhoLogo :=  cCamilogo + cArqulogo
    oPrintPvt:SayBitmap(014, 005, cCaminhologo, 070, 015)

    nLinAtu += nTamLin	
    oPrintPvt:Say(nLinAtu, 005, nomeprog,        oFontDet,,,  COR_PRETO, PAD_LEFT, 0)
    oPrintPvt:Say(nLinAtu, 095, cTitulo,         oFontDetN,,, COR_PRETO, PAD_LEFT, 0)
    oPrintPvt:Say(nLinAtu, 120, Cabec1,          oFontDetN,,, COR_PRETO, PAD_LEFT, 0)
    oPrintPvt:Say(nLinAtu, 200, Cabec2,          oFontDetN,,, COR_PRETO, PAD_LEFT, 0)
	oPrintPvt:Say(nLinAtu, 510, "DT.Ref...:",    oFontDet,,,  COR_PRETO, PAD_LEFT, 0)
    oPrintPvt:Say(nLinAtu, 550, Dtoc(DdATAbASE), oFontDet,,,  COR_PRETO, PAD_LEFT, 0)
    nLinAtu += nTamLin	
    oPrintPvt:Say(nLinAtu, 005, "Hora...:",             oFontDet,,, COR_PRETO, PAD_LEFT, 0)
    oPrintPvt:Say(nLinAtu, 030, cHoraGer,               oFontDet,,, COR_PRETO, PAD_LEFT, 0) //StrTran(cHoraGer, ':')
    oPrintPvt:Say(nLinAtu, 065, "- Grupo de Empresa.:", oFontDet,,, COR_PRETO, PAD_LEFT, 0)
    oPrintPvt:Say(nLinAtu, 140, "GRUPO BRASILUX ",      oFontDet,,, COR_PRETO, PAD_LEFT, 0)
    oPrintPvt:Say(nLinAtu, 230, " Filial..:",           oFontDet,,, COR_PRETO, PAD_LEFT, 0)
    oPrintPvt:Say(nLinAtu, 260, "MATRIZ ",              oFontDet,,, COR_PRETO, PAD_LEFT, 0)
    oPrintPvt:Say(nLinAtu, 510, "Emissão.:",            oFontDet,,, COR_PRETO, PAD_LEFT, 0)
    oPrintPvt:Say(nLinAtu, 550, dToc(dDataGer),         oFontDet,,, COR_PRETO, PAD_LEFT, 0)
    nLinAtu += nTamLin
    oPrintPvt:Say(nLinAtu, 005, Replicate("-",155), oFontDetN,,, COR_PRETO, PAD_LEFT, 0)
    nLinAtu += nTamLin
	cData := AllTrim(SM0->M0_CIDENT) +", "+ Strzero(day(dDataBase),2) + " DE " + aMeses[month(dDataBase)] + " DE "+ StrZero(year(dDataBase),4)		
	oPrintPvt:Say(nLinAtu, 460, cData,     oFontDet,,,COR_PRETO, PAD_LEFT, 0) 
    nLinAtu += nTamLin 
	oPrintPvt:Say(nLinAtu, 005 , 'PRODUTO.................................:', oFontDet,,, COR_PRETO, PAD_LEFT, 0)
	If !Empty(QPR->QPR_PRODUT)
	   oPrintPvt:Say(nLinAtu, 005, '                                      ', oFontDet,,, COR_PRETO, PAD_LEFT, 0)  // tirar Jose 09/11/20223
       oPrintPvt:Say(nLinAtu, 120, QPR->QPR_PRODUT, oFontDet,,, COR_PRETO, PAD_LEFT, 0) 
       oPrintPvt:Say(nLinAtu, 180, ' - ',           oFontDet,,, COR_PRETO, PAD_LEFT, 0) 
       oPrintPvt:Say(nLinAtu, 205, QP6->QP6_DESCPO, oFontDet,,, COR_PRETO, PAD_LEFT, 0) 
       oPrintPvt:Say(nLinAtu, 300, ' - ',           oFontDet,,, COR_PRETO, PAD_LEFT, 0) 
       oPrintPvt:Say(nLinAtu, 310, QPR->QPR_REVI,   oFontDet,,, COR_PRETO, PAD_LEFT, 0) 
	Endif
    nLinAtu += nTamLin
    oPrintPvt:Say(nLinAtu, 005 , "CLIENTE....................................:", oFontDet,,, COR_PRETO, PAD_LEFT, 0)
    oPrintPvt:Say(nLinAtu, 120 , cCliente,                         oFontDet,,, COR_PRETO, PAD_LEFT, 0)
    oPrintPvt:Say(nLinAtu, 160 , '/',                              oFontDet,,, COR_PRETO, PAD_LEFT, 0)
    oPrintPvt:Say(nLinAtu, 170 , cLoja,                            oFontDet,,, COR_PRETO, PAD_LEFT, 0)
    oPrintPvt:Say(nLinAtu, 180 , ' - ',                            oFontDet,,, COR_PRETO, PAD_LEFT, 0)
    oPrintPvt:Say(nLinAtu, 190 , SA1->A1_NOME,                     oFontDet,,, COR_PRETO, PAD_LEFT, 0)

	nLinAtu += nTamLin
    oPrintPvt:Say(nLinAtu, 005, "DATA DE PRODUÇÃO.............:", oFontDet,,, COR_PRETO, PAD_LEFT, 0)
    oPrintPvt:Say(nLinAtu, 120, Dtoc(QPK->QPK_DTPROD),            oFontDet,,, COR_PRETO, PAD_LEFT, 0)
    oPrintPvt:Say(nLinAtu, 250, "LOTE........................................:", oFontDet,,, COR_PRETO, PAD_LEFT, 0)
    oPrintPvt:Say(nLinAtu, 370, cLot,                             oFontDet,,, COR_PRETO, PAD_LEFT, 0)

	If !Empty(MV_PAR10) .or. !Empty(MV_PAR11)
        oPrintPvt:Say(nLinAtu, 110, 'NOTA FISCAL',         oFontDet,,, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:Say(nLinAtu, 021, '..................:', oFontDet,,, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:Say(nLinAtu, 040, MV_PAR10,              oFontDet,,, COR_PRETO, PAD_LEFT, 0)
	EndIf
    nLinAtu += nTamLin
    oPrintPvt:Say(nLinAtu, 005 , 'ORDEM DE PRODUÇÃO',   oFontDet,,, COR_PRETO, PAD_LEFT, 0)
    oPrintPvt:Say(nLinAtu, 070 , '..................:', oFontDet,,, COR_PRETO, PAD_LEFT, 0)

	If !Empty(QPR->QPR_OP)
       oPrintPvt:Say(nLinAtu, 120 , QPR->QPR_OP,        oFontDet,,, COR_PRETO, PAD_LEFT, 0)
	Else
       oPrintPvt:Say(nLinAtu, 120 , cOp,                oFontDet,,, COR_PRETO, PAD_LEFT, 0)
	Endif
    oPrintPvt:Say(nLinAtu, 250 , 'TAMANHO DO LOTE',             oFontDet,,, COR_PRETO, PAD_LEFT, 0)
    oPrintPvt:Say(nLinAtu, 320 , '..............:',             oFontDet,,, COR_PRETO, PAD_LEFT, 0)
	SAH->(dbSeek(xFilial("SAH")+QPK->QPK_UM))
    oPrintPvt:Say(nLinAtu, 370 , Alltrim(str(QPK->QPK_TAMLOT)), oFontDet,,, COR_PRETO, PAD_LEFT, 0)
    oPrintPvt:Say(nLinAtu, 410 , SAH->AH_UMRES,                 oFontDet,,, COR_PRETO, PAD_LEFT, 0)

	If !Empty(MV_PAR10) .or. !Empty(MV_PAR11)
       oPrintPvt:Say(nLinAtu, 005, 'SERIE',              oFontDet,,, COR_PRETO, PAD_LEFT, 0)
       oPrintPvt:Say(nLinAtu, 011, '..................', oFontDet,,, COR_PRETO, PAD_LEFT, 0)
       oPrintPvt:Say(nLinAtu, 035, ' : ',                oFontDet,,, COR_PRETO, PAD_LEFT, 0)
       oPrintPvt:Say(nLinAtu, 040, MV_PAR11,             oFontDet,,, COR_PRETO, PAD_LEFT, 0)
	EndIf
    nLinAtu += nTamLin

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chave de ligacao da medicao com outros arquivos              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cChave := QQ7->QQ7_CHAVE

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a ImpressÆo do Texto-Amarracao Prod.xCliente QQ7    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par02 == 1
		If Select("QA2") <> 0
           QA2->(dbCloseArea())
        Endif
		dbSelectArea("QA2")
		dbSetOrder(1)
		If dbSeek(xFilial("QA2")+"QIPA070 "+cChave)
	       nLinAtu += nTamLin
           oPrintPvt:Say(nLinAtu, 005, 'OBS.:',        oFontDet,,, COR_PRETO, PAD_LEFT, 0)
			While QA2->(!Eof()) .And. xFilial("QA2") == QA2->QA2_FILIAL .And. QA2->QA2_CHAVE == cChave
				If nLinAtu > 55 
                   oPrintPvt:Say(nLinAtu, COL_TITULO , cTitulo,  oFontDet,,, COR_PRETO, PAD_LEFT, 0)
                   oPrintPvt:Say(nLinAtu, COL_CABEC1 , Cabec1,   oFontDet,,, COR_PRETO, PAD_LEFT, 0)
                   oPrintPvt:Say(nLinAtu, COL_CABEC2 , Cabec2,   oFontDet,,, COR_PRETO, PAD_LEFT, 0)
                   oPrintPvt:Say(nLinAtu, COL_NOMPROG, nomeprog, oFontDet,,, COR_PRETO, PAD_LEFT, 0)
                   oPrintPvt:Say(nLinAtu, COL_TAMANHO, cTamanho, oFontDet,,, COR_PRETO, PAD_LEFT, 0)
                   oPrintPvt:Say(nLinAtu, COL_TIPO,  Str(nTipo), oFontDet,,, COR_PRETO, PAD_LEFT, 0)
				Endif
                nLinAtu += nTamLin
                oPrintPvt:Say(nLinAtu, 005, trTran(QA2_TEXTO, "\13\10", "") , oFontDet,,, COR_PRETO, PAD_LEFT, 0)
			    nLinAtu += nTamLin
				dbSkip()
			EndDo
		EndIf
        nLinAtu += nTamLin
	EndIf	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a ImpressÆo do Texto superior                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cArqTxt := "QPR0501"+".TXT"
	If File(cArqTxt)
		cTexto:=MemoRead(cArqTxt)
		For nC := 1 To MLCOUNT(cTexto,130)
			aLinha := MEMOLINE(cTexto,130,nC)
			cImpTxt   := ""
			cImpLinha := ""
			For nCount := 1 To Len(aLinha)
				cImpTxt := Substr(aLinha,nCount,1)
				If AT(cImpTxt,cAcentos)>0
					cImpTxt:=Substr(cAcSubst,AT(cImpTxt,cAcentos),1)
				EndIf
				cImpLinha := cImpLinha+cImpTxt
			Next nCount
            oPrintPvt:Say(nLinAtu, 005, cImpLinha,  oFontDet,,, COR_PRETO, PAD_LEFT, 0)
            nLinAtu += nTamLin
		Next nC
	EndIf
    nLinAtu += nTamLin

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a ImpressÆo dos Ensaios especificado com Encontrado           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	aAreaQPR	:= GetArea()
	If Select("QPR") <> 0
       QPR->(dbCloseArea())
    Endif
	dbSelectArea("QPR")
 	dbSetOrder(9)
    If dbSeek(xFilial("QPR")+QPK->QPK_OP+QPK->QPK_LOTE+QPK->QPK_NUMSER)

	While QPR->(!Eof()) .and. xFilial("QPR") == QPR->QPR_FILIAL .And. ;
		QPK->QPK_OP+QPK->QPK_LOTE+QPK->QPK_NUMSER == QPR->QPR_OP+QPR->QPR_LOTE+QPR->QPR_NUMSER
		lPula:= .T.
		lEnsaio:=.F.  
		nRecQPR := QPR->(Recno())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Checa a existˆncia do registro na amarra‡Æo Produto x Cliente.    ³
		//³ Se existir, ser  impresso somente os ensaios selecionados.        ³
		//³ Se nÆo achar o registro, ser  impresso todos os ensaios, sem      ³
		//³ a checagem.                                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QQ7->(dbSetOrder(1))
		If QQ7->(dbSeek(xFilial("QQ7")+QPR->QPR_PRODUT+cCliente+cLoja,.T.))
			lChecaQQ7 := .T.
		Endif
		
		If lChecaQQ7
			If !QQ7->(dbSeek(xFilial("QQ7")+QPR->QPR_PRODUT+cCliente+cLoja+QPR->QPR_LABOR+;
						QPR->QPR_ENSAIO+cRoteiro+QPR->QPR_OPERAC))
				dbSkip()
				Loop
			EndIf
		EndIf
		
		If  cOperacao == QPR->QPR_OPERAC .AND. cLabor == QPR->QPR_LABOR	.AND. cEnsaio == QPR->QPR_ENSAIO
			dbSkip()
			Loop
		EndIF
		
		If QIP50OCA(cRoteiro)
			If cOperacao <> QPR->QPR_OPERAC
				cLabor := ""
				cEnsaio:=""		
				cOperacao:= QPR->QPR_OPERAC
                nLinAtu += nTamLin
				_DesOP := RetDesOper(QPR->QPR_OP,cOperacao,QPR->QPR_PRODUT,QPR->QPR_REVI)
                oPrintPvt:Say(nLinAtu, 005, "OPERAÇÃO.........................:", oFontDet,,, COR_PRETO, PAD_LEFT, 0)
                oPrintPvt:Say(nLinAtu, 120, QPR->QPR_OPERAC,     oFontDet,,, COR_PRETO, PAD_LEFT, 0)
                oPrintPvt:Say(nLinAtu, 129, " - ",               oFontDet,,, COR_PRETO, PAD_LEFT, 0)
                oPrintPvt:Say(nLinAtu, 136, _DesOP,              oFontDet,,, COR_PRETO, PAD_LEFT, 0)
			EndIf
		Endif
	
		
		If cLabor <> QPR->QPR_LABOR	
		    cEnsaio:=""		
			If Select("QP1") <> 0
               QP1->(dbCloseArea())
            Endif
			dbSelectArea("QP1")
			dbSetOrder(1)
			If dbSeek(xFilial("QP1")+QPR->QPR_ENSAIO)

				If QP1->QP1_TPCART <> "X"
					If QP7->(dbSeek(xFilial("QP7")+QPR->QPR_PRODUT+QPR->QPR_REVI+cRoteiro+QPR->QPR_OPERAC+QPR->QPR_ENSAIO))
						If QP7->QP7_CERTIF == "S"
							lPula := .F.
							cLabor:= QPR->QPR_LABOR
						EndIf
					EndIf
				Else	
					If QP8->(DbSeek(xFilial()+QPR->QPR_PRODUT+QPR->QPR_REVI+cRoteiro+QPR->QPR_OPERAC+QPR->QPR_ENSAIO))
						If QP8->QP8_CERTIF == "S"
							lPula := .F.
							cLabor:= QPR->QPR_LABOR
						EndIf
					EndIf
				EndIf
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Nao imprime ensaio que esta setado para nao constar no certificado. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lPula
					cLabor:= " "
					If Select("QPR") <> 0
                       QPR->(dbCloseArea())
                    Endif
					DbSelectArea("QPR")
					DbSkip()
					Loop
				EndIf
                nLinAtu += nTamLin
                oPrintPvt:Say(nLinAtu, 005, "LABORATORIO..................:", oFontDet,,, COR_PRETO, PAD_LEFT, 0)
                oPrintPvt:Say(nLinAtu, 120, QPR->QPR_LABOR,   oFontDet,,, COR_PRETO, PAD_LEFT, 0)
                nLinAtu += nTamLin
	
				lEnsaio:= .T.			
				If mv_par01 ==1 .And. QP1->QP1_TPCART <> "X"
                   oPrintPvt:Say(nLinAtu, 360, "ESPECIFICAÇÕES", oFontDet,,, COR_PRETO, PAD_LEFT, 0)
                   oPrintPvt:Say(nLinAtu, 460,  "RESULTADOS",    oFontDet,,, COR_PRETO, PAD_LEFT, 0)
				Else
					If QP1->QP1_CARTA$"XBR/XBS/XMR/IND/HIS/TXT"
                       oPrintPvt:Say(nLinAtu, 360, "ESPECIFICAÇÕES", oFontDet,,, COR_PRETO, PAD_LEFT, 0)
                       oPrintPvt:Say(nLinAtu, 460, "RESULTADOS",     oFontDet,,, COR_PRETO, PAD_LEFT, 0)
					EndIf
				EndIf
			EndIf
            nLinAtu += nTamLin
			If lEnsaio
               oPrintPvt:Say(nLinAtu, 005, "ENSAIOS",    oFontDet,,, COR_PRETO, PAD_LEFT, 0)
               oPrintPvt:Say(nLinAtu, 200, "MÉTODOS",    oFontDet,,, COR_PRETO, PAD_LEFT, 0)
               oPrintPvt:Say(nLinAtu, 250, "UN. MEDIDA", oFontDet,,, COR_PRETO, PAD_LEFT, 0)

				If mv_par01 ==1 .And. QP1->QP1_TPCART <> "X"
                   oPrintPvt:Say(nLinAtu, 350, "MÍNIMO", oFontDet,,, COR_PRETO, PAD_LEFT, 0)
                   oPrintPvt:Say(nLinAtu, 400, "MAXIMO", oFontDet,,, COR_PRETO, PAD_LEFT, 0)
				Else
					If QP1->QP1_CARTA$"XBR/XBS/XMR/IND/HIS"
                       oPrintPvt:Say(nLinAtu, 350, "MÍNIMO", oFontDet,,, COR_PRETO, PAD_LEFT, 0)
                       oPrintPvt:Say(nLinAtu, 400, "MAXIMO", oFontDet,,, COR_PRETO, PAD_LEFT, 0)
                       oPrintPvt:Say(nLinAtu, 450, "MEDIA",  oFontDet,,, COR_PRETO, PAD_LEFT, 0)
					Else
                       oPrintPvt:Say(nLinAtu, 350, "MÍNIMO", oFontDet,,, COR_PRETO, PAD_LEFT, 0)
                       oPrintPvt:Say(nLinAtu, 400, "MAXIMO", oFontDet,,, COR_PRETO, PAD_LEFT, 0)
					EndIf
				EndIf
                nLinAtu += nTamLin
                oPrintPvt:Say(nLinAtu, 005, Replicate("=",150), oFontDet,,, COR_PRETO, PAD_LEFT, 0)
                nLinAtu += nTamLin
			EndIf
		EndIf

	    If Select("QP1") <> 0
           QP1->(dbCloseArea())
        Endif
		dbSelectArea("QP1")
		dbSetOrder(1)
		If dbSeek(xFilial("QP1")+QPR->QPR_ENSAIO)

			If cEnsaio <> QPR->QPR_ENSAIO 
	
				If QP1->QP1_TPCART <> "X"
					If Select("QP7") <> 0
                       QP7->(dbCloseArea())
                    Endif
					dbSelectArea("QP7")
					dbSetOrder(1)
					If dbSeek(xFilial("QP7")+QPR->QPR_PRODUT+QPR->QPR_REVI+cRoteiro+QPR->QPR_OPERAC+QPR->QPR_ENSAIO)
						If QP7->QP7_CERTIF == "S"
                            oPrintPvt:Say(nLinAtu, 005, QP1->QP1_DESCPO, oFontDet,,, COR_PRETO, PAD_LEFT, 0)
                            oPrintPvt:Say(nLinAtu, 200, QP7->QP7_METODO, oFontDet,,, COR_PRETO, PAD_LEFT, 0)
							SAH->(dbSeek(xFilial("SAH")+QP7->QP7_UNIMED))
                            oPrintPvt:Say(nLinAtu, 250, SAH->AH_UMRES,   oFontDet,,, COR_PRETO, PAD_LEFT, 0)
							If mv_par01 = 1
								If QP7_MINMAX == "1"
                                   oPrintPvt:Say(nLinAtu, 350, QP7->QP7_LIE, oFontDet,,, COR_PRETO, PAD_LEFT, 0)
                                   oPrintPvt:Say(nLinAtu, 400, QP7->QP7_LSE, oFontDet,,, COR_PRETO, PAD_LEFT, 0)
								ElseIf QP7_MINMAX == "2"
                                    oPrintPvt:Say(nLinAtu, 350, QP7->QP7_LIE, oFontDet,,, COR_PRETO, PAD_LEFT, 0)
                                    oPrintPvt:Say(nLinAtu, 400, ">>>",        oFontDet,,, COR_PRETO, PAD_LEFT, 0)
								ElseIf QP7_MINMAX == "3"
                                    oPrintPvt:Say(nLinAtu, 350, "<<<",        oFontDet,,, COR_PRETO, PAD_LEFT, 0)
                                    oPrintPvt:Say(nLinAtu, 400, QP7->QP7_LSE, oFontDet,,, COR_PRETO, PAD_LEFT, 0)
								EndIf
							ElseIf QP1->QP1_CARTA$"XBR/XBS/XMR/IND/HIS"  
                                   oPrintPvt:Say(nLinAtu, 350, QP7->QP7_LIE, oFontDet,,, COR_PRETO, PAD_LEFT, 0)
                                   oPrintPvt:Say(nLinAtu, 400, QP7->QP7_LSE, oFontDet,,, COR_PRETO, PAD_LEFT, 0)
							Else
                               oPrintPvt:Say(nLinAtu, 450, Padc(AllTrim(QP7->QP7_NOMINA), 38), oFontDet,,, COR_PRETO, PAD_LEFT, 0)
							Endif
							lEnsaio := .T.
						Else
							lEnsaio	:= .F.
						EndIf
					EndIf
				Else
					If Select("QP8") <> 0
                       QP8->(dbCloseArea())
                    Endif
					dbSelectArea("QP8")
					dbSetOrder(1)
					If dbSeek(xFilial()+QPR->QPR_PRODUT+QPR->QPR_REVI+cRoteiro+QPR->QPR_OPERAC+QPR->QPR_ENSAIO)
						If QP8->QP8_CERTIF == "S"
                            oPrintPvt:Say(nLinAtu, 005 , QP1->QP1_DESCPO,  oFontDet,,, COR_PRETO, PAD_LEFT, 0)
                            oPrintPvt:Say(nLinAtu, 200 , QP8->QP8_METODO,  oFontDet,,, COR_PRETO, PAD_LEFT, 0)
							lEnsaio := .T.
						Else
							lEnsaio	:= .F.
						EndIf	
					EndIf
				EndIf
			EndIF	    
		Endif
		dDat		:= QPR->QPR_DTMEDI
		cLote		:= QPR->QPR_LOTE
		cProdut     := QPR->QPR_PRODUT
		cLaborat	:= QPR->QPR_LABOR
		cEnsaio		:= QPR->QPR_ENSAIO
		cOp			:= QPR->QPR_OP
		If lEnsaio
			If Select("QPR") <> 0
               QPR->(dbCloseArea())
            Endif
			dbSelectArea("QPR")
	 		dbSetOrder(9)
	    	IF dbSeek(xFilial("QPR")+cOp+cLote+QPK->QPK_NUMSER+cRoteiro+cOperacao+cLaborat+cEnsaio+dTos(dDat))
	
				lImpTxt  := .T.
				nVlrUnic := ""
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Defini‡Æo das vari veis para impressÆo:                            ³
				//³Cartas:XBR,XBS,XMR,IND,HIS,C,NP,U,P : nVlrMin,nVlrMax,nVlrUnic     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				While QPR->(!Eof()) .And. xFilial("QPR") == QPR->QPR_FILIAL .And.;
					  cPrd     == QPR->QPR_PRODUT .And.	cRevi		    == QPR->QPR_REVI   .And.;
					  dDat	   == QPR->QPR_DTMEDI .And.	cLote		    == QPR->QPR_LOTE   .And.;  
					  cLaborat == QPR->QPR_LABOR  .And. cOperacao   	== QPR->QPR_OPERAC .And.;
					  cOp	   == QPR->QPR_OP     .And. QPK->QPK_NUMSER == QPR->QPR_NUMSER .And.;        
					  cEnsaio  == QPR->QPR_ENSAIO				
					lEnsaio  := .t.
					If lEnsaio
						IncRegua()
				
						cChave:= QPR->QPR_CHAVE
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Os tipos de cartas:XBR|XBS|XMR|IND|HIS - Se o param. for "Minimo/  ³
						//³Maximo"-ira considerar o menor e o maior valor. Se o param. for    ³
						//³"Valor Unico-Ser  o maior valor encontrado ou menor fora da espec. ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If QP1->QP1_TPCART <> "X"
							If QP1->QP1_CARTA$"XBR/XBS/XMR/IND/HIS"
								If Select("QPS") <> 0
                                   QPS->(dbCloseArea())
                                Endif
								dbSelectArea("QPS")
								dbSetOrder(1)
								If dbSeek(xFilial("QPS")+cChave)
									While QPS->(!Eof()) .And. 	QPS->QPS_FILIAL == xFilial("QPS") .And. ;
														    	QPS->QPS_CODMED == cChave
									
										nVlrMin:=IIF(SuperVal(QPS->QPS_MEDICA)<SuperVal(nVlrMin) .Or. ;
														SuperVal(nVlrMin)==0,QPS->QPS_MEDICA,nVlrMin)
                                        nVlrMAx:= ''   //  jose 30/05/2023
				 						If mv_par01 == 2 // Valor Unico
										   nVlrUnic := Alltrim(Str(SuperVal(nVlrUnic) + SuperVal(QPS->QPS_MEDICA)))
										   nMedia ++
										EndIf
				
										dbSkip()
									EndDo
								EndIf
							
							ElseIf QP1->QP1_CARTA$"C  /NP "
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Os tipos de carta : C / NP -Se o param. for "Minimo/Maximo", o Mi- ³
								//³nimo ser  0, o M ximo ser  o maior valor da 1a. medicao do QPS p/  ³
								//³cada data/hora. Sempre existem 1 medi‡Æo para cada data/hora.      ³
								//³Se param. for "Valor Unico" - Ser  o maior valor do QPS.           ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
	                            If Select("QPS") <> 0
                                   QPS->(dbCloseArea())
                                Endif
								dbSelectArea("QPS")
								dbSetOrder(1)
								If dbSeek(xFilial("QPS")+cChave)
									While QPS->(!Eof()) .And. 	QPS->QPS_FILIAL == xFilial("QPS") .And. QPS->QPS_CODMED == cChave
	                                    nVlrMAx:= ''   //  jose 30/05/2023
										dbSkip()
									EndDo
									If mv_par01 == 2 // Valor Unico
										If SuperVal(nVlrMax) > SuperVal(QP7->QP7_LSE) .Or. SuperVal(nVlrUnic) == 0
										   nVlrUnic:= nVlrMax
										EndIf
									EndIf
								EndIf
					
							ElseIf AllTrim(QP1->QP1_CARTA)=="U"
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³O  tipo  de carta : U      -Se o param. for "Minimo/Maximo", o Mi- ³
								//³nimo ser  0, o M ximo ser  o maior valor da 2a. medicao do QPS p/  ³
								//³cada data/hora. Sempre existem 2 regs. medi‡äes para cada data/hora³
								//³Se param. for "Valor Unico" - Ser  a 2a. medi‡Æo do QPS para a 1a. ³
								//³data/hora.                                                         ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If Select("QPS") <> 0
                                   QPS->(dbCloseArea())
                                Endif
								dbSelectArea("QPS")
								dbSetOrder(1)
								If dbSeek(xFilial("QPS")+cChave)
									While QPS->(!Eof()) .And. 	QPS->QPS_FILIAL == xFilial("QPS") .And. ;
															    QPS->QPS_CODMED == cChave
										If nV == 2
                                            nVlrMAx:= ''   //  jose 30/05/2023
											nV:=0
											If mv_par01 == 2 .And. lUnic
												nVlrUnic := QPS->QPS_MEDICA
												lUnic:= .F.
											EndIf
										EndIf
										nV++
										dbSkip()
									EndDo
								EndIf
						
							ElseIf AllTrim(QP1->QP1_CARTA)=="P"
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³O  tipo  de carta : P      -Se o param. for "Minimo/Maximo", o Mi- ³
								//³nimo ser  0, o Maximo ser  o maior valor de :                      ³
								//³Amostra * (Porcent./100)                                           ³
								//³Se param. for "Valor Unico" - Ser  o maior valor da Amostra:       ³
								//³Amostra * (Porcent./100)                                           ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If Select("QPS") <> 0
                                   QPS->(dbCloseArea())
                                Endif
								dbSelectArea("QPS")
								dbSetOrder(1)
								If dbSeek(xFilial("QPS")+cChave)
									While QPS->(!Eof()) .And. 	QPS->QPS_FILIAL == xFilial("QPS") .And. QPS->QPS_CODMED == cChave
										If QPS->QPS_INDMED == "A"
											nAmostra := QPS->QPS_MEDICA
										ElseIf QPS->QPS_INDMED == "P"
											nPorcent := QPS->QPS_MEDICA
										EndIf
										If !Empty(nAmostra) .And. !Empty(nPorcent)
                                            nVlrMAx:= ''   //  jose 30/05/2023
											nAmostra:= ""
											nPorcent:= ""
											If mv_par01 == 2 // Valor Unico
	 				  						   nVlrUnic:= Str(nVlrMax)
											EndIf
										EndIf
									dbSkip()
									EndDo
								EndIf
							EndIf
						Else	
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³O tipo de Carta:TXT ir  o 1o. resultado encontrado ou Todas Med. ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If (Len(aTexto) == 0 .And. Len(aTxtRes) == 0) .Or. mv_par09 == 2
								aTexto  := {}
								aTxtRes := {}
								lImpTxT := .T.
								If Len(aTexto) == 0
									cTxt := QP8->QP8_TEXTO
									While ! Empty(cTxt)
								        	Aadd(aTexto, Left(cTxt, 23))
								        	cTxt := Subs(cTxt, 24, Len(cTxt))
									EndDo
								EndIf
	
								If Len(aTxtRes) == 0	
									If Select("QPQ") <> 0
                                       QPQ->(dbCloseArea())
                                    Endif						
									dbSelectArea("QPQ")
									dbSetOrder(1)
									If dbSeek(xFilial()+cChave)
										cTxtRes:= QPQ->QPQ_MEDICA
										nX:=0
									
										While ! Empty(cTxtRes)
							        			Aadd(aTxtRes, Left(cTxtRes, 23))
									        	cTxtRes := Subs(cTxtRes, 24, Len(cTxtRes))
										EndDo
									Endif
								EndIf	
	
								nTot:= IIF(Len(aTexto)>Len(aTxtRes),Len(aTexto),Len(aTxtRes))
								For nC := 1 to nTot
									If lImpTxT
										If Len(aTexto) >= nC
											If	!Empty(aTexto[nC])
                                                oPrintPvt:Say(nLinAtu, 350, Alltrim(aTexto[nC]), oFontDet,,, COR_PRETO, PAD_LEFT, 0)
											EndIf
										EndIf	
									EndIf
									If  Len(aTxtRes) >= nC
										If	!Empty(aTxtRes[nC])
                                            oPrintPvt:Say(nLinAtu, 470,  AllTrim(aTxtRes[nC]), oFontDet,,, COR_PRETO, PAD_LEFT, 0)
										EndIf
									EndIf
                                    nLinAtu += nTamLin
								Next nC
							Endif							
							
						EndIf

					Else
                        nLinAtu += nTamLin
					EndIf
					If Select("QPR") <> 0
                       QPR->(dbCloseArea())
                    Endif
					dbSelectArea("QPR")
					dbSkip()
				EndDo
				
			EndIf
			
			If QP1->QP1_CARTA$"XBR/XBS/XMR/IND/HIS" .and. mv_par01 == 2 // Valor Unico
				nVlrUnic := Alltrim(Str(SuperVal(nVlrUnic) /nMedia))
			EndIF   
		Endif
	
		If lEnsaio
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Faz impressÆo de todas as cartas                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If QP1->QP1_TPCART <> "X"
				If QP1->QP1_CARTA$"XBR/XBS/XMR/IND/HIS"
					If mv_par01 == 1
                        oPrintPvt:Say(nLinAtu, 450, AllTrim(nVlrMin),  oFontDet,,, COR_PRETO, PAD_LEFT, 0)
                        oPrintPvt:Say(nLinAtu, 500, AllTrim(nVlrMax),  oFontDet,,, COR_PRETO, PAD_LEFT, 0)
					Else
                        oPrintPvt:Say(nLinAtu, 550, Padc(AllTrim(nVlrUnic), 27),  oFontDet,,, COR_PRETO, PAD_LEFT, 0)
					EndIf
				
				ElseIf AllTrim(QP1->QP1_CARTA)$"C/NP/U/P"
					If mv_par01 == 1
                        oPrintPvt:Say(nLinAtu, 450, "0",  oFontDet,,, COR_PRETO, PAD_LEFT, 0)                
						If ValType(nVlrMax) = "N"
                           oPrintPvt:Say(nLinAtu, 500, AllTrim(Str(nVlrMax)), oFontDet,,, COR_PRETO, PAD_LEFT, 0)   
			   			Else                                                              
                           oPrintPvt:Say(nLinAtu, 500, AllTrim(Str(nVlrMax)), oFontDet,,, COR_PRETO, PAD_LEFT, 0)   
			      		EndIf
					Else
                        oPrintPvt:Say(nLinAtu, 550, Padc(AllTrim(nVlrUnic), 27), oFontDet,,, COR_PRETO, PAD_LEFT, 0)   
					EndIf
				EndIf
			EndIf
			
			If QP1->QP1_TPCART == "X"
				aTexto:={}
				aTxtRes:={}
			Else
				nVlrMin :=999999
				nVlrMax :=-999999
				nVlrUnic:=""
				lUnic   :=.T.
				nMedia  :=0
                nLinAtu += nTamLin
			EndIf	
		EndIf
		If Select("QPR") <> 0
           QPR->(dbCloseArea())
        Endif
		dbSelectArea("QPR")
		dbSetOrder(9)
		dbGoTo(nRecQPR)
		dbSkip()
	EndDo
	RestArea(aAreaQPR)
	lEnsaio := .T.	//Flag para impressao dos ensaios
	Endif
	If Select("QPL") <> 0
       QPL->(dbCloseArea())
    Endif
	dbSelectArea("QPL")
	dbSetOrder(2)                          
	If !Empty(cLote)
		cSeek := xFilial("QPL")+cOP+cLote+Space(TamSX3("QPL_OPERAC")[1])+Space(TamSX3("QPL_LABOR")[1])
	Else
		cSeek := xFilial("QPL")+cOP
	Endif
	If dbSeek(cSeek)
		If Select("QPD") <> 0
           QPD->(dbCloseArea())
        Endif
		dbSelectArea("QPD")
		dbSetOrder(1)
		If dbSeek(xFilial("QPD")+QPL->QPL_LAUDO)
            nLinAtu += nTamLin
            oPrintPvt:Say(nLinAtu, 005, "LAUDO",                        oFontDet,,,COR_PRETO, PAD_LEFT, 0) //, 0001, nTamLin, COR_PRETO, PAD_LEFT, 0)  //1
            oPrintPvt:Say(nLinAtu, 032, "...........................:", oFontDet,,,COR_PRETO, PAD_LEFT, 0) //, 0100, nTamLin, COR_PRETO, PAD_LEFT, 0)  //2
            oPrintPvt:Say(nLinAtu, 100, QPD->QPD_DESCPO,                oFontDet,,,COR_PRETO, PAD_LEFT, 0) //, 0500, nTamLin, COR_PRETO, PAD_LEFT, 0)  //4
            nLinAtu += nTamLin
            oPrintPvt:Say(nLinAtu, 005, "DATA LAUDO",                   oFontDet,,,COR_PRETO, PAD_LEFT, 0) //, 0005, nTamLin, COR_PRETO, PAD_LEFT, 0)  
            oPrintPvt:Say(nLinAtu, 037,  "......................:",     oFontDet,,,COR_PRETO, PAD_LEFT, 0) //, 0060, nTamLin, COR_PRETO, PAD_LEFT, 0)
            oPrintPvt:Say(nLinAtu, 100,  Dtoc(QPL->QPL_DTLAUD),         oFontDet,,,COR_PRETO, PAD_LEFT, 0) //, 0250, nTamLin, COR_PRETO, PAD_LEFT, 0) 
            nLinAtu += nTamLin
			If !Empty(QPL->QPL_QTREJ)
				SAH->(dbSeek(xFilial("SAH")+QPK->QPK_UM))
                oPrintPvt:Say(nLinAtu, 005, "QTDE REJEITADA",      oFontDet,,, COR_PRETO, PAD_LEFT, 0)  
                oPrintPvt:Say(nLinAtu, 045, ".......:",            oFontDet,,, COR_PRETO, PAD_LEFT, 0)
                oPrintPvt:Say(nLinAtu, 100, QPL->QPL_QTREJ,        oFontDet,,, COR_PRETO, PAD_LEFT, 0) 
                nLinAtu += nTamLin
			EndIf
			If mv_par03 == 1
                oPrintPvt:Say(nLinAtu, 005, "JUSTIFICATIVA LAUDO", oFontDet,,, COR_PRETO, PAD_LEFT, 0)  
                oPrintPvt:Say(nLinAtu, 060, "..:",                 oFontDet,,, COR_PRETO, PAD_LEFT, 0)
                oPrintPvt:Say(nLinAtu, 100, QPL->QPL_JUSTLA,       oFontDet,,, COR_PRETO, PAD_LEFT, 0) 
                nLinAtu += nTamLin
			EndIf 		
//---- Jose 09/02/2024 --------------------------------
            If xFilial("QPL") <> '010104'
//-----------------------------------------------------   
//----jose 25/07/2022 ---------------------------------			     
               dValidade := U_ValidProd(cLote,cProdut)
//-----------------------------------------------------
//----- jOSE 09/02/2024 -------------------------------
            Else
			   dValidade := QPL->QPL_DTVAL
			Endif
//-----------------------------------------------------
            oPrintPvt:Say(nLinAtu, 005, "DATA VALIDADE",           oFontDet,,, COR_PRETO, PAD_LEFT, 0)   
            oPrintPvt:Say(nLinAtu, 045, "............:",           oFontDet,,, COR_PRETO, PAD_LEFT, 0) 
            oPrintPvt:Say(nLinAtu, 100,  Dtoc(dValidade),          oFontDet,,, COR_PRETO, PAD_LEFT, 0) 
            nLinAtu += nTamLin
		Endif
	EndIf
    nLinAtu += nTamLin	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a ImpressÆo das Informa‡äes Complementares   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cArqTxt := "QPR0503"+".TXT"
	If File(cArqTxt)
		cTexto:=MemoRead(cArqTxt)
		For nC := 1 To MLCOUNT(cTexto,130)
			aLinha := MEMOLINE(cTexto,130,nC)
			cImpTxt   := ""
			cImpLinha := ""
			For nCount := 1 To Len(aLinha)
				cImpTxt := Substr(aLinha,nCount,1)
				If AT(cImpTxt,cAcentos)>0
					cImpTxt:=Substr(cAcSubst,AT(cImpTxt,cAcentos),1)
				EndIf
				cImpLinha := cImpLinha+cImpTxt
			Next nCount
            oPrintPvt:Say(nLinAtu, 005, cImpLinha, oFontDet,,, COR_PRETO, PAD_LEFT, 0) 
            nLinAtu += nTamLin 
		Next nC
	EndIf
    nLinAtu += nTamLin 	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a ImpressÆo do Texto inferior                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cArqTxt := "QPR0502"+".TXT"
	If File(cArqTxt)
		cTexto:=MemoRead(cArqTxt)
		For nC := 1 To MLCOUNT(cTexto,130)
			aLinha := MEMOLINE(cTexto,130,nC)
			cImpTxt   := ""
			cImpLinha := ""
			For nCount := 1 To Len(aLinha)
				cImpTxt := Substr(aLinha,nCount,1)
				If AT(cImpTxt,cAcentos)>0
					cImpTxt:=Substr(cAcSubst,AT(cImpTxt,cAcentos),1)
				EndIf
				cImpLinha := cImpLinha+cImpTxt
			Next nCount
            oPrintPvt:Say(nLinAtu, 005, cImpLinha, oFontDet,,, COR_PRETO, PAD_LEFT, 0) 
            nLinAtu += nTamLin
		Next nC
	EndIf
    nLinAtu += nTamLin
Next nContador

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a Integridade dos dados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("QPR") <> 0
   QPR->(dbCloseArea())
Endif
dbSelectArea("QPR")
RetIndex("QPR")
dbSetOrder(1)
Set Filter To

If File(cNomArq+OrdBagExt())
	Ferase(cNomArq+OrdBagExt())
EndIf
	
Set device to Screen

If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()
Return .T.         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QIPR050   ºAutor  ³Renata Cavalcante   º Data ³  05/15/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função para verificação se há ensaios com Certificado como  º±±
±±º          ³S(Sim) para a Operação. Tanto ensaios texto qto dimensionaisº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Verificação dos Ensaios                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QIP50OCA(cRoteiro)

Local aAreaQPR:= GETAREA("QPR")
Local aAreaQQ7:= GETAREA("QQ7")
Local lRetorno:=.F.

If Select("QP7") <> 0
   QP7->(dbCloseArea())
Endif
Dbselectarea("QP7")
Dbsetorder(1)

If DbSeek(xFilial("QP7")+QPR->QPR_PRODUT+QPR->QPR_REVI+cRoteiro+QPR->QPR_OPERAC+QPR->QPR_ENSAIO)
	While QP7->(!Eof())   .And. QP7->QP7_OPERAC == QPR->QPR_OPERAC
			If QP7->QP7_CERTIF == "S"
				lRetorno:= .T. 
				exit
			EndIf	 
			QP7->(DBSKIP())
	Enddo
Else
	If Select("QP8") <> 0
       QP8->(dbCloseArea())
    Endif
	DbSelectarea("QP8")
	Dbsetorder(1)

	If DbSeek(xFilial()+QPR->QPR_PRODUT+QPR->QPR_REVI+cRoteiro+QPR->QPR_OPERAC+QPR->QPR_ENSAIO)
		While QP8->(!Eof())   .And. QP8->QP8_OPERAC == QPR->QPR_OPERAC
			If QP8->QP8_CERTIF == "S"
				lRetorno:= .T.
				exit
			EndIf
			QP8->(DBSKIP())
		
		Enddo
	Endif
Endif

              
Restarea(aAreaQPR)
Restarea(aAreaQQ7)
Return(lRetorno)  

RestArea(aArea)

