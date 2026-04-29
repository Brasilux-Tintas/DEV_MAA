#Include "BRQIPR050.Ch"
#Include "PROTHEUS.Ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BRQIPR050               André            ³ Data ³ 08.05.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Laudo Técnico (QIPR050 - Adaptado p/ Brasilux)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaQIP                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRQIPR050()
Local oDlgGet
Local oListBox
Local nItem		:=0
Private lEnd	:=.F.
Private aListBox:={}
Private cPerg1	:="QPR051"
Private  __cPRODUTO := CriaVar("QP6_PRODUT") //Codigo do Produto, quando a Especificacao for em Grupo      
Private lProduto   := .F.
Private lFase3     := IIF(QP6->(FieldPos("QP6_SITREV"))<>0,.T.,.F.)
     u_zcfga01( 'BRQIPR050' ) //LGS#2021201 - Gravação de log de utilização da rotina
//AjustaSX1()

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
DEFINE MSDIALOG oDlgGet TITLE "Certificado de Qualidade Brasilux" FROM  0,0	TO 217,297 OF oMainWnd PIXEL 	//"Certificado de Qualidade"
@ 01,05 SAY OemToAnsi(STR0008)	SIZE 100, 07 OF oDlgGet PIXEL					//"Itens de Configuracao"
@ 10,05 LISTBOX oListBox VAR nItem  ITEMS aListBox  ON DBLCLICK Iif(nItem<=3,R050TEXT(oListBox),Pergunte(cPerg1,.T.)) SIZE 110,90 PIXEL OF oDlgGet
DEFINE SBUTTON FROM 10, 120 TYPE 6 ACTION (R050IMP(),oDlgGet:End()) ENABLE OF oDlgGet
DEFINE SBUTTON FROM 26, 120 TYPE 2 ACTION oDlgGet:End() ENABLE OF oDlgGet

ACTIVATE MSDIALOG oDlgGet CENTERED
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
Static Function R050Imp()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Par„metros para a fun‡„o SetPrint () ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL wnrel		:="BRQIPR050"
LOCAL cString	:="QPR"
LOCAL cDesc1	:="Neste relatório será impresso os Certificado de Análise de Qualidade de produtos Brasilux"
LOCAL cDesc2	:=""
LOCAL cDesc3	:=""
Local nVias     :=0
Local cNota     :=""
Local cSerie    :=""
Local cRevi     :=""
Local nImpEns   :=0
Local lAchou    :=.F. 
Local cImprCQ   := GETMV("MV_QIMPRCQ")

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// ³ Par„metros para a fun‡„o Cabec()  ³
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cTitulo 	:="CERTIFICADO DE QUALIDADE BRASILUX"	
PRIVATE cRelatorio	:="BRQIPR050"
PRIVATE nTamanho	:="M"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Vari veis utilizadas pela fun‡„o SetDefault () ³
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

Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If FunName() == "QIPA215"           
	
	Pergunte(cPergR,.F.)
	wnrel := SetPrint(cString,wnrel,cPergR,@ctitulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,nTamanho)
	
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
	dbSelectArea("QPR")     
    dbSetOrder(9)
    If dbSeek(xFilial("QPR")+QPK->QPK_OP+QPK->QPK_LOTE+QPK->QPK_NUMSER)
    	mv_par04  := QPR->QPR_DTENTR     
	Else 
		mv_par04  := QPK->QPK_DTPROD	
	EndIf                      
	
	mv_par05  := QPK->QPK_LOTE	   // Lote                                   
	mv_par06  := QPK->QPK_NUMSER  //  Numero do Lote                                   
	mv_par07  := nVias            // Nr. de Vias                            
	mv_par08  := cRevi            // Revisao                                
	mv_par09  := nImpEns          // Impr. Ensaio Texto (Primeira/Todas)    
	mv_par10  := cNota            // Nota Fiscal                            
	mv_par11  := cSerie           // Serie  
	mv_par12  := QPK->QPK_OP      // Ordem de Produção  
	
Else
	wnrel := SetPrint(cString,wnrel,cPerg,@ctitulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,nTamanho)
	DbSelectArea("QPK")
	//DbSetOrder(2)
	//If DbSeek(xFilial("QPK")+MV_PAR03)
	DbSetOrder(3)
	If DbSeek(xFilial("QPK")+MV_PAR05)

		If Found()	
			mv_par03  := QPK->QPK_PRODUT  // Produto  
			mv_par04  := QPK->QPK_DTPROD	
   			mv_par05  := QPK->QPK_LOTE	  // Lote                                   
			mv_par06  := QPK->QPK_NUMSER  // Numero do Lote  
			mv_par08  := QPK->QPK_REVI    // Revisao 
			mv_par12  := QPK->QPK_OP      // Ordem de Produção        
   			While !EOF().AND. AllTrim(QPK->QPK_PRODUT) == AllTrim(MV_PAR03)
	   		    If cImprCQ == "N"
   			   		If DTOS(QPK->QPK_DTPROD) == DTOS(MV_PAR04) .AND. AllTrim(QPK_OP) == AllTrim(MV_PAR12) .AND. AllTrim(QPK_LOTE) == AllTrim(MV_PAR05) .AND.;
	    	        	AllTrim(QPK_NUMSER) == AllTrim(MV_PAR06) .AND. AllTrim(QPK_REVI) == AllTrim(MV_PAR08) .AND. !Empty(QPK_CERQUA)
        				lAchou := .T.  
        				Exit
	        		EndIf
    	       		DbSkip()
        	     Else
            	 	If DTOS(QPK->QPK_DTPROD) == DTOS(MV_PAR04) .AND. AllTrim(QPK_OP) == AllTrim(MV_PAR12) .AND. AllTrim(QPK_LOTE) == AllTrim(MV_PAR05) .AND.;
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

If nLastKey == 27
	Set Filter to
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter to
	Return
Endif

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
Local cCliente		:=mv_par01
Local cLoja			:=mv_par02
Local cData			:=""
Local cArqTxt		:=""
Local cTexto		:=""
Local cImpTxt		:=""
Local cEnsaio		:=""
Local cChave		:=""
Local cSeek			:=""
Local cTxtRes		:=""
Local cTxt			:=""
Local cLabor		:=""
Local cRevi			:= If(Empty(mv_par08),QA_UltRevEsp(mv_par03,,,,"QIP"), mv_par08) 
Local cLote			:=""
Local cProdut       :=""
Local cLaborat		:=""
Local dValidade
Local aTexto		:={}
Local aTxtRes		:={}
Local aLinha		:={}
Local cImpLinha	:={}
//Local cbCont		:=00
Local nVlrMin		:=999999
Local nVlrMax		:=-999999
Local nVlrUnic		:=0
Local nC			:=0
Local nCount		:=0
Local nV			:=1
Local nX			:=0
Local nAmostra		:=0
Local nPorcent		:=0
Local lUnic			:=.T.
Local nContador	:=1
Local cOp			:=mv_par12
Local cOperacao	:=""
Local cRoteiro 	:=""
//Local CbTxt
Local cNomArq		:=""
Local cPrd 			:=mv_par03
Local dDatOP		:=mv_par04
Local cLot			:=Padr(mv_par05,TamSX3("QPR_LOTE")[1]) 
Local cNumSer       :=Padr(mv_par06,TamSX3("QPR_NUMSER")[1]) 
Local lEnsaio		:=.F.
Local lChecaQQ7		:=.F.
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

Private Titulo 	 := cTitulo
Private Cabec1 	 := ""
Private Cabec2	 := ""
Private	nomeprog := "BRQIPR050"
Private cTamanho := "M"
Private nTipo	 := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
li       := 80
m_pag    := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se deve comprimir ou nao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTipo := If(aReturn[4]==1,15,18)

If Empty(mv_par12)
	dbSelectArea("QPR")
	dbSetOrder(6)
	DbSeek(xFilial("QPR")+cPrd+cRevi+Dtos(dDatOP)+cLot)
Else 
	dbSelectArea("QPR")
	dbSetOrder(1)
	DbSeek(xFilial("QPR")+cOp)
EndIf
nPosQPR  := QPR->(RecNo())
nOrdQPR  := QPR->(IndexOrd())


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
dbSelectArea("QQ7")
dbSetOrder(1)
If dbSeek(xFilial("QQ7")+QPR->QPR_PRODUT+cCliente+cLoja)
	nPosQQ7  := QQ7->(RecNo())
	nOrdQQ7  := QQ7->(IndexOrd())
Endif

dbSelectArea("SA1")
dbSetOrder(1)
If dbSeek(xFilial("SA1")+cCliente+cLoja)
	nPosSA1  := SA1->(RecNo())
	nOrdSA1  := SA1->(IndexOrd())
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

dbSelectArea("QPL")
dbSetOrder(3)
If dbSeek(xFilial("QPL")+QPK->QPK_OP+QPK->QPK_LOTE+QPK->QPK_NUMSER+cRoteiro+Space(TamSX3("QPL_OPERAC")[1])+Space(TamSX3("QPL_LABOR")[1]))
	dbSelectArea("QPD")
	dbSetOrder(1)
	If dbSeek(xFilial("QPD")+QPL->QPL_LAUDO)
		If QPD->QPD_CATEG == '4'
			MessageDlg(OemToAnsi(STR0035),OemToAnsi(STR0036),2)		//'Devido o laudo estar com Libera‡Æo Urgente, nÆo ser  poss¡vel emitir o Certificado de Qualidade.'###'Aten‡Æo'
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

	cData := AllTrim(SM0->M0_CIDENT) +","+ Strzero(day(dDataBase),2) + " DE " + aMeses[month(dDataBase)] + " DE "+ StrZero(year(dDataBase),4)		//" de "###" de "
	@ Li,132-Len(cData) PSAY cData
	Li+=2
	@Li,01 PSAY "PRODUTO"+Replicate(".",23-Len(AllTrim(TitSX3("QPR_PRODUT")[1])))+":"
	If !Empty(QPR->QPR_PRODUT)
		@Li,27 PSAY AllTrim(QPR->QPR_PRODUT)+" - "+AllTrim(QP6->QP6_DESCPO) +" - "+QPR->QPR_REVI
	Endif
	Li+=2
	@Li,01 PSAY "CLIENTE"+Replicate(".",23-Len(AllTrim(TitSX3("A7_CLIENTE")[1])))+":"
	@Li,27 PSAY AllTrim(cCliente)+"/"+cLoja+" - "+SA1->A1_NOME
	Li+=2
	@Li,01 PSAY "DATA DE PRODUÇÃO"+Replicate(".",23-Len("DATA DE PRODUÇÃO"))+":"
	@Li,27 PSAY QPK->QPK_DTPROD
	@Li,52 PSAY "LOTE"+Replicate(".",20-Len(AllTrim(TitSX3("QPR_LOTE")[1])))+":"
	@Li,75 PSAY cLot         
	If !Empty(MV_PAR10) .or. !Empty(MV_PAR11)
		@Li,97 PSAY "NOTA FISCAL"+Replicate(".",18-Len("NOTA FISCAL"))+":"
		@Li,120 PSAY MV_PAR10
	EndIf
	Li+=2
	@Li,01 PSAY "ORDEM DE PRODUÇÃO"+Replicate(".",18-Len(AllTrim(TitSX3("QPR_OP")[1])))+":"
	If !Empty(QPR->QPR_OP)
		@Li,27 PSAY QPR->QPR_OP
	Else
		@Li,27 PSAY cOp
	Endif
	@Li,52 PSAY "TAMANHO DO LOTE"+Replicate(".",14-Len(AllTrim(TitSX3("QEK_TAMLOT")[1])))+": "
	SAH->(dbSeek(xFilial("SAH")+QPK->QPK_UM))
	@Li,75 PSAY Alltrim(str(QPK->QPK_TAMLOT))+" "+SAH->AH_UMRES
	If !Empty(MV_PAR10) .or. !Empty(MV_PAR11)
		@Li,97 PSAY "SERIE"+Replicate(".",18-Len("SERIE"))+":"
		@Li,120 PSAY MV_PAR11
	EndIf
	Li+=2

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chave de ligacao da medicao com outros arquivos              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cChave := QQ7->QQ7_CHAVE

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a ImpressÆo do Texto-Amarracao Prod.xCliente QQ7    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par02 == 1
		dbSelectArea("QA2")
		dbSetOrder(1)
		If dbSeek(xFilial("QA2")+"QIPA070 "+cChave)
			@Li,01 PSAY "OBS.: "
			While QA2->(!Eof()) .And. xFilial("QA2") == QA2->QA2_FILIAL .And. QA2->QA2_CHAVE == cChave
				If Li > 55
					Cabec(cTitulo,Cabec1,Cabec2,nomeprog,cTamanho,nTipo)
				Endif
				@Li,08 PSAY StrTran(QA2_TEXTO, "\13\10", "")
				Li++
				dbSkip()
			EndDo
		EndIf
		Li++
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
			@Li,01 PSAY cImpLinha
			Li++
		Next nC
	EndIf
	Li++
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a ImpressÆo dos Ensaios especificado com Encontrado           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	aAreaQPR	:= GetArea()
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
		
		If QIP50OC(cRoteiro)
			If cOperacao <> QPR->QPR_OPERAC
				cLabor := ""
				cEnsaio:=""		
				cOperacao:= QPR->QPR_OPERAC
				Li++
				@Li,01 PSAY "OPERAÇÃO :"+QPR->QPR_OPERAC+ " - "+RetDesOper(QPR->QPR_OP,cOperacao,QPR->QPR_PRODUT,QPR->QPR_REVI)		// "OPERACAO : "
			EndIf
		Endif
	
		
		If cLabor <> QPR->QPR_LABOR	
		    cEnsaio:=""		
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
					DbSelectArea("QPR")
					DbSkip()
					Loop
				EndIf

				Li++
				@Li,01 PSAY "LABORATORIO : "+QPR->QPR_LABOR		//"LABORATORIO : "
				Li++			
	
				lEnsaio:= .T.			
				If mv_par01 ==1 .And. QP1->QP1_TPCART <> "X"
					@Li,082 PSAY "ESPECIFICAÇÕES"		//"Especificado"
					@Li,114 PSAY "RESULTADOS"   		//"Encontrados"
				Else
					If QP1->QP1_CARTA$"XBR/XBS/XMR/IND/HIS/TXT"
						@Li,082 PSAY "ESPECIFICAÇÕES"		//"Especificado"
						@Li,114 PSAY "RESULTADOS"		//"Encontrado"
					EndIf
				EndIf
			EndIf

			Li++
			If lEnsaio
				@Li,001 PSAY "ENSAIOS"
				@Li,047 PSAY "MÉTODOS"
				@Li,065 PSAY "UN. MEDIDA"
				If mv_par01 ==1 .And. QP1->QP1_TPCART <> "X"
					@Li,077 PSAY "MÍNIMO"		//"Minimo"
					@Li,093 PSAY "MÁXIMO"		//"Maximo"
					//@Li,108 PSAY "MÍNIMO"		//"Minimo"
					//@Li,125 PSAY "MÁXIMO"		//"Maximo"
				Else
					If QP1->QP1_CARTA$"XBR/XBS/XMR/IND/HIS"
						@Li,077 PSAY "MINIMO"		//"Minimo"
						@Li,093 PSAY "MÁXIMO"		//"Maximo"	
						@Li,116 PSAY "MEDIA"        //"Media"
					Else
						@Li,077 PSAY "MÍNIMO"		//"Minimo"
						@Li,093 PSAY "MÁXIMO"		//"Maximo"
						//@Li,108 PSAY "MÍNIMO"		//"Minimo"
						//@Li,125 PSAY "MÁXIMO"		//"Maximo"
					EndIf
				EndIf
				Li++
				@Li,01 PSAY Replicate("=",130)
				Li++
			EndIf
			If Li > 55
				Cabec(cTitulo,Cabec1,Cabec2,nomeprog,cTamanho,nTipo,,.F.)
			EndIf
		EndIf

		dbSelectArea("QP1")
		dbSetOrder(1)
		If dbSeek(xFilial("QP1")+QPR->QPR_ENSAIO)

			If cEnsaio <> QPR->QPR_ENSAIO 
	
				If QP1->QP1_TPCART <> "X"
					dbSelectArea("QP7")
					dbSetOrder(1)
					If dbSeek(xFilial("QP7")+QPR->QPR_PRODUT+QPR->QPR_REVI+cRoteiro+QPR->QPR_OPERAC+QPR->QPR_ENSAIO)
						If QP7->QP7_CERTIF == "S"
							@Li,01 PSAY QP1->QP1_DESCPO
							@Li,47 PSAY QP7->QP7_METODO
							SAH->(dbSeek(xFilial("SAH")+QP7->QP7_UNIMED))
							@Li,65 PSAY SAH->AH_UMRES
							If mv_par01 = 1
								If QP7_MINMAX == "1"
									@Li,78 PSAY QP7->QP7_LIE
									@Li,93 PSAY QP7->QP7_LSE
								ElseIf QP7_MINMAX == "2"
									@Li,78 PSAY QP7->QP7_LIE
									@Li,93 PSAY ">>>"
								ElseIf QP7_MINMAX == "3"
									@Li,78 PSAY "<<<"
									@Li,93 PSAY QP7->QP7_LSE
								EndIf
							ElseIf QP1->QP1_CARTA$"XBR/XBS/XMR/IND/HIS"  
								@Li,78 PSAY QP7->QP7_LIE
								@Li,93 PSAY QP7->QP7_LSE					
							Else
								@ li,65 PSAY Padc(AllTrim(QP7->QP7_NOMINA), 38)
							Endif
							lEnsaio := .T.
						Else
							lEnsaio	:= .F.
						EndIf
					EndIf
				Else
					dbSelectArea("QP8")
					dbSetOrder(1)
					If dbSeek(xFilial()+QPR->QPR_PRODUT+QPR->QPR_REVI+cRoteiro+QPR->QPR_OPERAC+QPR->QPR_ENSAIO)
						If QP8->QP8_CERTIF == "S"
	//						Li++
							If Li > 55
								Cabec(cTitulo,Cabec1,Cabec2,nomeprog,cTamanho,nTipo,,.F.)
							EndIf
							@Li,01 PSAY QP1->QP1_DESCPO
							@Li,47 PSAY QP8->QP8_METODO
							lEnsaio := .T.
						Else
							lEnsaio	:= .F.
						EndIf	
					EndIf
				EndIf
			EndIF	    
		Endif
		
		If Li > 55
			Cabec(cTitulo,Cabec1,Cabec2,nomeprog,cTamanho,nTipo,,.F.)
		EndIf
		dDat		:= QPR->QPR_DTMEDI
		cLote		:= QPR->QPR_LOTE
		cProdut     := QPR->QPR_PRODUT
		cLaborat	:= QPR->QPR_LABOR
		cEnsaio		:= QPR->QPR_ENSAIO
		cOp			:= QPR->QPR_OP
		If lEnsaio
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
					cPrd     	== QPR->QPR_PRODUT	.And.	cRevi		== QPR->QPR_REVI .And.;
					dDat		== QPR->QPR_DTMEDI	.And.	cLote		== QPR->QPR_LOTE .And.;  
					cLaborat	== QPR->QPR_LABOR	.And. 	cOperacao	== QPR->QPR_OPERAC .And. ;
					cOp			== QPR->QPR_OP .And. QPK->QPK_NUMSER  == QPR->QPR_NUMSER .And.;        
					cEnsaio	== QPR->QPR_ENSAIO				
					lEnsaio := .t.
					If lEnsaio
						If li > 55
							Cabec(cTitulo,Cabec1,Cabec2,nomeprog,cTamanho,nTipo,,.F.)
						EndIf
		
						IncRegua()
				
						cChave:= QPR->QPR_CHAVE
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Os tipos de cartas:XBR|XBS|XMR|IND|HIS - Se o param. for "Minimo/  ³
						//³Maximo"-ira considerar o menor e o maior valor. Se o param. for    ³
						//³"Valor Unico-Ser  o maior valor encontrado ou menor fora da espec. ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If QP1->QP1_TPCART <> "X"
							If QP1->QP1_CARTA$"XBR/XBS/XMR/IND/HIS"
								dbSelectArea("QPS")
								dbSetOrder(1)
								If dbSeek(xFilial("QPS")+cChave)
									While QPS->(!Eof()) .And. 	QPS->QPS_FILIAL == xFilial("QPS") .And. ;
															QPS->QPS_CODMED == cChave
									
										nVlrMin:=IIF(SuperVal(QPS->QPS_MEDICA)<SuperVal(nVlrMin) .Or. ;
														SuperVal(nVlrMin)==0,QPS->QPS_MEDICA,nVlrMin)
//	jose 30/05/2023  					nVlrMax:=IIF(SuperVal(QPS->QPS_MEDICA)>SuperVal(nVlrMax),QPS->QPS_MEDICA,nVlrMax)
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
								dbSelectArea("QPS")
								dbSetOrder(1)
								If dbSeek(xFilial("QPS")+cChave)
									While QPS->(!Eof()) .And. 	QPS->QPS_FILIAL == xFilial("QPS") .And. QPS->QPS_CODMED == cChave
																
//										nVlrMax:=IIF(SuperVal(QPS->QPS_MEDICA)>SuperVal(nVlrMax),QPS->QPS_MEDICA,nVlrMax)  // Jose 30/05/2023
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
								dbSelectArea("QPS")
								dbSetOrder(1)
								If dbSeek(xFilial("QPS")+cChave)
									While QPS->(!Eof()) .And. 	QPS->QPS_FILIAL == xFilial("QPS") .And. ;
															QPS->QPS_CODMED == cChave
										If nV == 2
//											nVlrMax:=IIF(SuperVal(QPS->QPS_MEDICA)>SuperVal(nVlrMax),QPS->QPS_MEDICA,nVlrMax) //Jose 30/05/2023
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
								//³nimo ser  0, o M ximo ser  o maior valor de :                      ³
								//³Amostra * (Porcent./100)                                           ³
								//³Se param. for "Valor Unico" - Ser  o maior valor da Amostra:       ³
								//³Amostra * (Porcent./100)                                           ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
//    jose 30/05/2023						nVlrMax:= IIF(SuperVal(nAmostra) * (SuperVal(nPorcent) / 100 ) > SuperVal(nVlrMax),SuperVal(nAmostra) * (SuperVal(nPorcent) / 100 ),nVlrMax)
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
											@Li,077 PSAY Alltrim(aTexto[nC])
											EndIf
										EndIf	
									EndIf
									If  Len(aTxtRes) >= nC
										If	!Empty(aTxtRes[nC])
										@Li,108 PSAY AllTrim(aTxtRes[nC])
										EndIf
									EndIf
									If Li > 55
										Cabec(cTitulo,Cabec1,Cabec2,nomeprog,cTamanho,nTipo,,.F.)
									EndIf
									Li++
								Next nC
							Endif							
							
						EndIf
	
						If Li > 55
								Cabec(cTitulo,Cabec1,Cabec2,nomeprog,cTamanho,nTipo,,.F.) 
						EndIf
					Else
						li++
					EndIf
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
						@Li,114-Len(AllTrim(nVlrMin)) PSAY AllTrim(nVlrMin)
						@Li,130-Len(AllTrim(nVlrMax)) PSAY AllTrim(nVlrMax)
					Else
						@Li,104 PSAY Padc(AllTrim(nVlrUnic), 27)
					EndIf
				
				ElseIf AllTrim(QP1->QP1_CARTA)$"C/NP/U/P"
					If mv_par01 == 1
						@Li,113 PSAY "0"  
						If ValType(nVlrMax) = "N"
			        		@Li,130-Len(AllTrim(Str(nVlrMax))) PSAY AllTrim(Str(nVlrMax))
			   			Else                                                              
			        		@Li,130-Len(AllTrim(nVlrMax)) PSAY AllTrim(nVlrMax)
			      		EndIf
					Else
						@Li,104 PSAY Padc(AllTrim(nVlrUnic), 27)
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
				Li++
			EndIf	
		EndIf
		dbSelectArea("QPR")
		dbSetOrder(9)
		dbGoTo(nRecQPR)
		dbSkip()
	EndDo
	RestArea(aAreaQPR)
	lEnsaio := .T.	//Flag para impressao dos ensaios
	Endif

	dbSelectArea("QPL")
	dbSetOrder(2)                          
	If !Empty(cLote)
		cSeek := xFilial("QPL")+cOP+cLote+Space(TamSX3("QPL_OPERAC")[1])+Space(TamSX3("QPL_LABOR")[1])
	Else
		cSeek := xFilial("QPL")+cOP
	Endif
	If dbSeek(cSeek)
		dbSelectArea("QPD")
		dbSetOrder(1)
		If dbSeek(xFilial("QPD")+QPL->QPL_LAUDO)
			Li+=2
			@Li,01 PSAY "LAUDO"+Replicate(".",20-Len(AllTrim(TitSX3("QPL_LAUDO")[1])))+": "+QPD->QPD_DESCPO
			Li+=2
			@Li,01 PSAY "DATA LAUDO"+Replicate(".",20-Len(AllTrim(TitSX3("QPL_DTLAUD")[1])))+": "+Dtoc(QPL->QPL_DTLAUD)
			Li+=2
			If !Empty(QPL->QPL_QTREJ)
				SAH->(dbSeek(xFilial("SAH")+QPK->QPK_UM))
				@Li,01 PSAY "QTDE REJEITADA"+Replicate(".",16-Len(AllTrim(TitSX3("QPL_QTREJ")[1])))+": "+QPL->QPL_QTREJ
				Li+=2
			EndIf
			If mv_par03 == 1
				@Li,01 PSAY "JUSTIFICATIVA LAUDO"+Replicate(".",12-Len(AllTrim(TitSX3("QPL_JUSTLA")[1])))+": "+QPL->QPL_JUSTLA
				Li+=2
			EndIf   
//---- Jose 09/02/2024 --------------------------
            If xFilial("QPL") <> '010104'
//-----------------------------------------------   
//----jose 25/07/2022 ---------------------------
               dValidade := U_ValidProd(cLote,cProdut) 
//-----------------------------------------------
//----- jOSE 09/02/2024 -------------------------
            Else
			   dValidade := QPL->QPL_DTVAL
			Endif
//-----------------------------------------------
// inibido por Jose 22/02/2023			@Li,01 PSAY "DATA VALIDADE"+Replicate(".",12-Len(AllTrim(TitSX3("QPL_DTVAL")[1])))+": "+Dtoc(QPL->QPL_DTVAL)
//          @Li,01 PSAY "DATA VALIDADE"+Replicate(".",12-Len(AllTrim(TitSX3("dValidade")[1])))+": "+Dtoc(dValidade)
            @Li,01 PSAY "DATA VALIDADE"+"."+": "+Dtoc(dValidade)
			Li+=2
//-----------------------------------------------
		Endif
	EndIf
	
	
	Li+=2

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
			@Li,01 PSAY cImpLinha
			Li++
			If Li > 55
				Cabec(cTitulo,Cabec1,Cabec2,nomeprog,cTamanho,nTipo,,.F.)
			EndIf
		Next nC
	EndIf
	
	Li+=2
	
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
			@Li,01 PSAY cImpLinha
			Li++
			If Li > 55
				Cabec(cTitulo,Cabec1,Cabec2,nomeprog,cTamanho,nTipo,,.F.)
			EndIf
		Next nC
	EndIf
	Li++
Next nContador

//If Li != 80
//	roda(CbCont,cbtxt,nTamanho)
//EnDif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a Integridade dos dados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
User Function QIP50OC(cRoteiro)

Local aAreaQPR:= GETAREA("QPR")
Local aAreaQQ7:= GETAREA("QQ7")
Local lRetorno:=.F.

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



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QIPR050   ºAutor  ³Iolanda Vilanova    º Data ³  03/01/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³AJUSTASX1                                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±                           
±±ºUso       ³ QIPR050                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


/*User Function AjustaSX1

Local aArea := GetArea()
dbSelectArea("SX1")
dbSetOrder(1)

/*
PutSX1("BRQPR050", "01", "Cliente           ?", "", "", "mv_ch1", "C", 1, 0, 1, "G", " ", " ", " ", " ", "mv_par01", "", " ", " ", " ", "", " ", " ", "", " ", " ", "", " ", " ", "", " ", " ", Nil, Nil, Nil, cPerg )
PutSX1("BRQPR050", "03", "Do Produto        ?", "", "", "mv_ch3", "C", 1, 0, 1, "G", " ", " ", " ", " ", "mv_par03", "", " ", " ", " ", "", " ", " ", "", " ", " ", "", " ", " ", "", " ", " ", Nil, Nil, Nil, cPerg )
PutSX1("BRQPR050", "05", "Lote              ?", "", "", "mv_ch5", "C", 1, 0, 1, "G", " ", " ", " ", " ", "mv_par05", "", " ", " ", " ", "", " ", " ", "", " ", " ", "", " ", " ", "", " ", " ", Nil, Nil, Nil, cPerg )
PutSX1("BRQPR050", "07", "Número do Cópias  ?", "", "", "mv_ch7", "N", 1, 0, 1, "G", " ", " ", " ", " ", "mv_par07", "", " ", " ", " ", "", " ", " ", "", " ", " ", "", " ", " ", "", " ", " ", Nil, Nil, Nil, cPerg )
PutSX1("BRQPR050", "10", "Nota Fiscal       ?", "", "", "mv_cha", "C", 1, 0, 1, "G", " ", " ", " ", " ", "mv_par10", "", " ", " ", " ", "", " ", " ", "", " ", " ", "", " ", " ", "", " ", " ", Nil, Nil, Nil, cPerg )
PutSX1("BRQPR050", "11", "Série             ?", "", "", "mv_chb", "C", 1, 0, 1, "G", " ", " ", " ", " ", "mv_par11", "", " ", " ", " ", "", " ", " ", "", " ", " ", "", " ", " ", "", " ", " ", Nil, Nil, Nil, cPerg )
PutSX1("BRQPR050", "12", "Ordem de Produção ?", "", "", "mv_chc", "C", 1, 0, 1, "G", " ", " ", " ", " ", "mv_par12", "", " ", " ", " ", "", " ", " ", "", " ", " ", "", " ", " ", "", " ", " ", Nil, Nil, Nil, cPerg )


PutSX1("BRQPR051", "01", "Resultados        ?", "", "", "mv_ch1", "N", 1, 0, 1, "C", " ", " ", " ", " ", "mv_par01", "", " ", " ", " ", "", " ", " ", "", " ", " ", "", " ", " ", "", " ", " ", Nil, Nil, Nil, cPerg )
PutSX1("BRQPR051", "02", "Observação Produto?", "", "", "mv_ch2", "N", 1, 0, 1, "C", " ", " ", " ", " ", "mv_par02", "", " ", " ", " ", "", " ", " ", "", " ", " ", "", " ", " ", "", " ", " ", Nil, Nil, Nil, cPerg )
PutSX1("BRQPR051", "03", "Just. do Laudo    ?", "", "", "mv_ch3", "N", 1, 0, 1, "C", " ", " ", " ", " ", "mv_par03", "", " ", " ", " ", "", " ", " ", "", " ", " ", "", " ", " ", "", " ", " ", Nil, Nil, Nil, cPerg )



//PutSx1( cGrupo  , cOrdem,  cPergunt                 , cPerSpa, cPerEng  ,  cVar   ,  cTipo, nTamanho, nDecimal, nPresel,  cGSC,  cValid  ,  cF3 , cGrpSxg,  cPyme,  cVar01   ,  cDef01       ,cDefSpa1   ,  cDefEng1   ,  cCnt01     ,  cDef02        ,  cDefSpa2  ,  cDefEng2  ,  cDef03 ,  cDefSpa3  ,  cDefEng3   ,  cDef04    ,  cDefSpa4  ,  cDefEng4 ,  cDef05  ,  cDefSpa5  ,  cDefEng5     , aHelpPor, aHelpEng, aHelpSpa,  cHelp)
  PutSX1("FAR121    ", "01"   , "Opção do relatório " , ""     , ""      , "mv_ch1", "N"   , 01      , 0       , 1      , "C"  , ""       , "   ", "   "  , "   " , "mv_par01", "SIM          ", "        ", "          ", "          ", "NÃO          ", "         ", "         ", "      ", "         ", "          ", "         ", "         ", "        ", "       ", "         ", "            ", Nil     , Nil     , Nil     , ".BRQPR051." )
  aHelPor1 := {}
  aAdd(aHelPor1, 'Selecione o tipo de relatório a ser im- ')
  aAdd(aHelPor1, 'presso.                                 ')
  PutSX1Help("P.FAR12101.", aHelPor1, Nil, Nil)
*/
/*   
If (SX1->(DbSeek("QPR051    "+"01")))
		RecLock("SX1",.F.)
		Replace SX1->X1_DEF01 With "Minimo/Maximo"		
		MsUnlock()
	
Endif
*/

RestArea(aArea)
