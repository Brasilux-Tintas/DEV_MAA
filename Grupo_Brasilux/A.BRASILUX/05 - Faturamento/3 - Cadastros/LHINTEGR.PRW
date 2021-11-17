#INCLUDE 'Protheus.ch'
#include "topconn.ch"
#include "rwmake.ch"
#include "totvs.ch"
#include 'DIRECTRY.CH' 
#include "TbiConn.ch"
#include 'avprint.ch'
#include 'appexcel.ch'
/*
19/02/2015
Integração Leiria Hotel - Importação de Faturamento

*/
User Function LHINTEGR() 
Local cArqBloq,aBloq,_cAreaBloq
Private _oGeraTxt ,MV_PAR01,MV_PAR02 
Private _cPath     := '', _cFile  := ''
Private _cPerg     := "LHINTEGR"
Private oFont1    := AppExcFont():New( "Calibri", '14', '#000000')
Private oFont2    := AppExcFont():New( "Calibri", '12', '#000000')

if !(alltrim(cNumEmp) == "01100101")
	MsgAlert("Importação deverá ser feita na empresa Leiria Hotel!")
	return
endif 

if !u_VldAcesso(funname())
	MsgAlert("Acesso não autorizado!---->"+funname())
	return 
endif 

cArqBloq := "LHINTEGR"+Substr(ALLTRIM(cNumEmp),3,6) //Cleber (14/02/20)  -> Reajuste da função  BloqProg
aBloq := U_BloqProg(cArqBloq) //Retorna matriz com primeira coluna verdadeiro ou falso se tá bloqueado e segunda coluna com nome de quem está bloqueando ou nome da área de trabalho gerada

if aBloq[1,1] //Já estava bloqueado?
	cAux := "O programa já está sendo usado por: "+aBloq[1,2]
	Messagebox(cAux,"Atenção!",48) 		
	Return
endif

_cAreaBloq := aBloq[1,4] //Cleber (14/02/20)  -> Reajuste da função  BloqProg


//CriaSX1(_cPerg) release 12.1.25
Pergunte(_cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da tela de processamento.                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

@ 200,1 TO 380,450 DIALOG _oGeraTxt TITLE OemToAnsi("Integracao AppSistemas -> Protheus")
@ 02,10 TO 060,215
@ 10,018 Say "Este programa ira importar arquivo texto de integração " SIZE 196,0
@ 18,018 Say "gerado pelo sistema AppSistemas." SIZE 196,0

@ 70,128 BMPBUTTON TYPE 05 ACTION Pergunte(_cPerg,.T.)
@ 70,158 BMPBUTTON TYPE 01 ACTION Processa( {|| OkImpTrb() }) 
@ 70,188 BMPBUTTON TYPE 02 ACTION Close(_oGeraTxt)

Activate Dialog _oGeraTxt Centered

dbselectarea(_cAreaBloq)
DBRUnlock( aBloq[1,3]) //Cleber (14/02/20)  -> Reajuste da função  BloqProg
DbCloseArea() //Cleber (14/02/20)  -> Reajuste da função  BloqProg

Return

//-------------------------------------
Static Function OkImpTrb
Local _nHdl,cArq,lFim,nTamArq,lComeco,nLidos,lSucesso,nOpc,cAux,_cEOL,cProd,cUm,cSegum,nConv,cTipConv,cCodBar,lLeuProds  
Local cCod,cCgc,lInclui,nAux,cSerie,cNroNf,lBloqueou,cCodCid,cCodCli,nX,cEmail,aCli,dEmissao,cLinha,nValor
Local nAuxCont,cMun,cPais,cCodPais,cChvNfe,cCliApp,cTitulo,aBaixa,aCab,cFiltro,aTitOri,aTitCx,cCliLiq,cLojaLiq,;
cNaturez,nMoeda,cTipoLiq,cCond,cCliCta,lBaixaFin,cConta,dVencto,nSldDisp,aExcl,aTitAux,nSomaItens,cNcm,cEspecie,cMensErro,i
Local aVetor := {}
Local aCabec := {}
Local aItens := {}
Local aLinha := {}
Local aNfProbl := {} // Nfs sem Cód Clientes


private lMsErroAuto := .F. 
//Private lAutoErrNoFile  := .T.
Private lMsHelpAuto := .t.
Private MVXCLICC := supergetmv("MV_XCLICC",.f.,'020022')
lSucesso := .t.
lLeuProds := .f. //Identifica se já leu as notas fiscais (xmls) de produtos pra não ficar passando pela função
_cFile     := alltrim(mv_par01)
_cPath     := Alltrim( mv_par02 )  
cMensErro := ""
if substr(_cPath,len(_cPath),1) != "\"
	_cPath += "\"
endif


//Verificar TES
dbSelectArea("SF4")
dbSetOrder(1)
If !SF4->(MsSeek(xFilial("SF4")+"707"))
	 lSucesso := .F.
	 MsgAlert("O TES de serviço 707 nao existe!","Atencao!")
	 Return
EndIf

//Verificar cond. pgto 001
dbSelectArea("SE4")
dbSetOrder(1)
If !SE4->(MsSeek(xFilial("SE4")+"001"))
	 lSucesso := .F.
	 MsgAlert("A Cond. Pgto 001 nao existe!","Atencao!")
	 Return
EndIf

//Checar prod. Serviço
dbSelectArea("SB1")
dbSetOrder(1)
If !SB1->(MsSeek(xFilial("SB1")+"ZZV0012999999"))
 	lSucesso := .f.
	 MsgAlert("Produto de Serviço código ZZV0012999999 não existe!","Atencao!")
	 Return
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o arquivo texto                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cArq := _cPath+_cFile        
_nHdl := -1
if !empty(_cFile)
	if !file(cArq)
		MsgAlert("O arquivo "+cArq+" nao existe! Verifique os parametros.","Atencao!")
		Return
	Endif

	_nHdl  := fopen(_cPath+_cFile)

	If _nHdl == -1
		MsgAlert("O arquivo "+cArq+" nao pode ser aberto! Verifique os parametros.","Atencao!")
		Return
	Endif

	_cEOL := CHR(13)+CHR(10)

	fSeek(_nHdl, 0, 0)
	nTamArq := fSeek(_nHdl, 0, 2)
	fSeek(_nHdl, 0, 0)
else
	nTamArq := 0
endif 

lComeco = .t. 
lFim = .f.
nLidos := 0
nLinha := 0              

if lSucesso 
	cQuery := "IF (OBJECT_ID('HOSPEDESPORNF', 'U') IS NULL) "+; 
		"CREATE TABLE HOSPEDESPORNF (CHVNFE VARCHAR(44) COLLATE database_default,CODIGO VARCHAR(15) COLLATE database_default);"
	TCSQLEXEC(cQuery)
//	cQuery := "IF (OBJECT_ID('tempdb..#LHPGTOS', 'U') IS NOT NULL) "+;


	cQuery := "IF (OBJECT_ID('LHPGTOS', 'U') IS NOT NULL) "+;
	"DROP TABLE LHPGTOS; "+;
	"CREATE TABLE LHPGTOS (BLOCO VARCHAR(3) COLLATE database_default,CONTASEQ VARCHAR(22) COLLATE database_default,TIPOPGTO VARCHAR(30) COLLATE database_default NOT NULL DEFAULT '',"+;
	"CODHOSPEDE VARCHAR(15) COLLATE database_default NOT NULL DEFAULT '',VALOR FLOAT NOT NULL DEFAULT 0.0,VENCTO VARCHAR(8) COLLATE database_default NOT NULL DEFAULT '',"+;
	"BCOCHEQUE VARCHAR(3) COLLATE database_default NOT NULL DEFAULT '',AGENCIA VARCHAR(6) COLLATE database_default NOT NULL DEFAULT '', CONTA VARCHAR(6) COLLATE database_default NOT NULL DEFAULT '',"+;
	"NROCHEQUE VARCHAR(20) COLLATE database_default NOT NULL DEFAULT '',PORTADOR VARCHAR(50) COLLATE database_default NOT NULL DEFAULT '',DEBCRED VARCHAR(1) COLLATE database_default NOT NULL DEFAULT '',"+;
	"NRONF VARCHAR(9) COLLATE database_default NOT NULL DEFAULT '',SERIE VARCHAR(3) COLLATE database_default NOT NULL DEFAULT '');"
	TCSQLEXEC(cQuery)

	cQuery := "IF (OBJECT_ID('NFPGTOS', 'U') IS NOT NULL) "+;
	"DROP TABLE NFPGTOS; "+;
	"CREATE TABLE NFPGTOS (CONTASEQ VARCHAR(22) COLLATE database_default,CLIENTE VARCHAR(6) COLLATE database_default,CODHOSPEDE VARCHAR(15) COLLATE database_default NOT NULL DEFAULT '',"+;
	"NRONF VARCHAR(9) COLLATE database_default NOT NULL DEFAULT '',SERIE VARCHAR(3) COLLATE database_default NOT NULL DEFAULT '',VALOR FLOAT NOT NULL DEFAULT 0.0);"
	TCSQLEXEC(cQuery)

	/*
	cQuery := "IF (OBJECT_ID('LHPGTOS', 'U') IS NULL) "+;
	"CREATE TABLE LHPGTOS (BLOCO VARCHAR(3) COLLATE database_default,CONTASEQ VARCHAR(22) COLLATE database_default,TIPOPGTO VARCHAR(30) COLLATE database_default NOT NULL DEFAULT '',"+;
	"CODHOSPEDE VARCHAR(15) COLLATE database_default NOT NULL DEFAULT '',VALOR FLOAT NOT NULL DEFAULT 0.0,VENCTO VARCHAR(8) COLLATE database_default NOT NULL DEFAULT '',"+;
	"BCOCHEQUE VARCHAR(3) COLLATE database_default NOT NULL DEFAULT '',AGENCIA VARCHAR(6) COLLATE database_default NOT NULL DEFAULT '', CONTA VARCHAR(6) COLLATE database_default NOT NULL DEFAULT '',"+;
	"NROCHEQUE VARCHAR(20) COLLATE database_default NOT NULL DEFAULT '',PORTADOR VARCHAR(50) COLLATE database_default NOT NULL DEFAULT '',DEBCRED VARCHAR(1) COLLATE database_default NOT NULL DEFAULT '')"
	TCSQLEXEC(cQuery)
	*/
endif 

dbselectarea("SB1")
dbsetorder(1)
ProcRegua( round(nTamArq/600,0) )
While lSucesso .and. (nLidos < nTamArq) .and. !lFim
	if nLidos < nTamArq
		cLinha := U_fGets(_nHdl)
		nLidos += Len(cLinha) 
	else
		lFim = .t.
	endif 
	nLinha++
  	IncProc("Lendo linha "+alltrim(str(nLinha)))  

	if (nLinha == 1) .and. !(alltrim(SUBSTR(cLinha,20,10)) == "1.001")
		MsgAlert("Este arquivo não é um arquivo de Integração do Leiria Hotel! ","Atenção!")
		lSucesso := .f. 
		exit 
	endif     

	//Bloco 001-Clientes/Hospedes
	if (substr(cLinha,1,3) == "001")
		cCod := substr(cLinha,4,15)
		
		If SELECT("HSP") > 0
			HSP->(DbcloseArea())
		Endif

		cQuery := "SELECT TOP 1 ID FROM HOSPEDES WHERE CODIGO = '"+cCod+"'"
		TCQuery cQuery NEW ALIAS "HSP" 
		dbselectarea("HSP") 
		dbgotop()
		lInclui := iif(eof(),.t.,.f.)
		if lInclui
			cQuery := "INSERT INTO HOSPEDES (CODIGO,NOMEFANTAS,RAZAO,CNPJ,INSCRRG,PESSOA,CODPAIS,SIGLAPAIS,NOMEPAIS,UF,CIDADE,CODIBGE,BAIRRO,ENDERECO,NUMEND,COMPLEMENTO,CEP,FONE,EMAIL,COMISSAO) "+;
			"VALUES ("+;
			"'"+cCod+"','"+nvl(substr(cLinha,19,100))+"','"+nvl(substr(cLinha,119,100))+"','"+nvl(substr(cLinha,219,14))+"','"+u_sonumcar(nvl(substr(cLinha,233,20)))+"','"+nvl(substr(cLinha,253,1))+;
			"','"+nvl(substr(cLinha,261,5))+"','"+nvl(substr(cLinha,266,3))+"','"+nvl(substr(cLinha,269,50))+"','"+nvl(substr(cLinha,319,2))+"','"+u_TiraAcento(nvl(substr(cLinha,321,50)))+"','"+nvl(substr(cLinha,371,7))+;
			"','"+strtran(nvl(substr(cLinha,378,50)),"'"," ")+"','"+strtran(nvl(substr(cLinha,428,100)),"'"," ")+"','"+nvl(substr(cLinha,528,10))+"','"+nvl(substr(cLinha,538,100))+"','"+nvl(substr(cLinha,638,8))+;
			"','"+u_sonumcar(nvl(substr(cLinha,646,15)))+"','"+nvl(substr(cLinha,661,100))+"',"+nvl(substr(cLinha,761,3))+"."+nvl(substr(cLinha,765,2))+")"
		else
			cQuery := "UPDATE HOSPEDES SET CODIGO = '"+cCod+"',NOMEFANTAS = '"+nvl(substr(cLinha,19,100))+"',"+;
			"RAZAO = '"+nvl(substr(cLinha,119,100))+"',CNPJ = '"+nvl(substr(cLinha,219,14))+"',INSCRRG = '"+u_sonumcar(nvl(substr(cLinha,233,20)))+"',"+;
			"PESSOA = '"+nvl(substr(cLinha,253,1))+"',CODPAIS = '"+nvl(substr(cLinha,261,5))+"',SIGLAPAIS = '"+nvl(substr(cLinha,266,3))+"',"+;
			"NOMEPAIS = '"+nvl(substr(cLinha,269,50))+"',UF = '"+nvl(substr(cLinha,319,2))+"',CIDADE = '"+u_TiraAcento(nvl(substr(cLinha,321,50)))+"',"+;
			"CODIBGE = '"+nvl(substr(cLinha,371,7))+"',BAIRRO = '"+strtran(nvl(substr(cLinha,378,50)),"'"," ")+"',ENDERECO = '"+strtran(nvl(substr(cLinha,428,100)),"'"," ")+"',"+;
			"NUMEND = '"+nvl(substr(cLinha,528,10))+"',COMPLEMENTO = '"+nvl(substr(cLinha,538,100))+"',CEP = '"+nvl(substr(cLinha,638,8))+"',"+;
			"FONE = '"+u_sonumcar(nvl(substr(cLinha,646,15)))+"',EMAIL = '"+nvl(substr(cLinha,661,100))+"',COMISSAO = "+nvl(substr(cLinha,761,3))+"."+nvl(substr(cLinha,765,2))+;
			" WHERE ID = "+ALLTRIM(STR(HSP->ID))
		endif 
		TCSQLEXEC(cQuery)
		dbselectarea("HSP") 
		dbclosearea()
		

	endif // Fim Bloco 001-Clientes/Hospedes
	//Bloco 002-Produtos
	if (substr(cLinha,1,3) == "002")
		if substr(cLinha,64,70) = "PRODUTO"	
			cProd = right(U_SoNumCar(substr(cLinha,4,30)),6) 
			cUm := ALLTRIM(SUBSTR(cLinha,248,3))
			cSegum := ALLTRIM(SUBSTR(cLinha,195,3))
			if cUm == cSegum
				nConv := 0
				cTipConv := "M"
			else        
				nAux := val(substr(cLinha,301,10))+(val(substr(cLinha,312,4))/10000)
				nConv := iif(nAux > 0,1/nAux,0)
				cTipConv := iif(substr(cLinha,316,1) == "D","M","D")
			endif
			cCodBar := ALLTRIM(SUBSTR(cLinha,171,14)) 
			cDesc := u_TiraAcendo(ALLTRIM(SUBSTR(cLinha,71,30)))
			cNcm := U_SoNumCar(substr(cLinha,187,8))
			if empty(alltrim(cNcm))
				cNcm := "00000000"
			endif
			dbselectarea("SB1")
			dbseek(xFilial("SB1")+cProd)
			nOpc := iif(found(),4,3)
			aVetor := {}
			aadd(aVetor,{"B1_FILIAL"         , xFilial("SB1")   ,NIL})
	          aadd(aVetor,{"B1_COD"         , cProd   ,NIL})
              aadd(aVetor,{"B1_TIPO"    	,"PA"            ,Nil})
              aadd(aVetor,{"B1_DESC"        ,cDesc ,Nil})
              aadd(aVetor,{"B1_UM"      	,ALLTRIM(SUBSTR(cLinha,248,3))            ,Nil})                   
              aadd(aVetor,{"B1_LOCPAD"  	,"03"            ,Nil})                   
              aadd(aVetor,{"B1_PICM"    	,0               ,Nil})                   
              aadd(aVetor,{"B1_POSIPI"     	,cNcm  ,Nil})                   
              aadd(aVetor,{"B1_PESOESP"     ,1  ,Nil})                   
              aadd(aVetor,{"B1_GRUPO"     ,""  ,Nil})                   
	          aadd(aVetor,{"B1_CODITE"         , ALLTRIM(SUBSTR(cLinha,37,27))   ,NIL})
//              aadd(aVetor,{"B1_RESUMO"        ,ALLTRIM(SUBSTR(cLinha,121,30)) ,.F.})
              aadd(aVetor,{"B1_RESUMO"        ,cDesc ,.F.})
              aadd(aVetor,{"B1_SEGUM"      	,cSegum           ,Nil})                   
              aadd(aVetor,{"B1_CONV"      	,nConv            ,Nil})                   
              aadd(aVetor,{"B1_TIPCONV"     ,cTipConv         ,Nil})                   
              aadd(aVetor,{"B1_CONTRAT" 	,"N"              ,Nil})                   
              aadd(aVetor,{"B1_LOCALIZ" 	,"N"              ,Nil})				 
              aadd(aVetor,{"B1_TE"      	,"402"            ,Nil})
              aadd(aVetor,{"B1_PICMRET"    	,0                ,Nil})
              aadd(aVetor,{"B1_MSBLQL"    	,"2"              ,Nil})
              
			IF !empty(cCodBar)
				aadd(aVetor, {"B1_CODBAR"      ,cCodBar ,NIL})
			endif 
			lMsErroAuto := .F.
 			MSExecAuto({|x,y| Mata010(x,y)},aVetor,nOpc) 
 			If lMsErroAuto
		 		lSucesso := .f.
	 			MostraErro() 
			 	exit 
		 	Endif  
		endif 
	endif // Fim importação do cad. produtos          

/*
IF (OBJECT_ID('tempdb..#TMPCLAS1', 'U') IS NOT NULL) 
	DROP TABLE #TMPCLAS1
CREATE TABLE #TMPCLAS1 (FILIAL VARCHAR(6) COLLATE database_default,
CODRAIZ VARCHAR(10) COLLATE database_default,
VOLUME FLOAT ,ACUMULADO FLOAT ,CLASSIF VARCHAR(1) COLLATE database_default)

*/

/*		
	cQuery := "IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LHINTEGR]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1) "+;
					"CREATE TABLE [dbo].[LHINTEGR]( "+;
					"[ID] [INT] IDENTITY(1,1) NOT NULL,"+;
					"[BLOCO] [varchar](3) NOT NULL DEFAULT (''),"+;
					"[CAMPO] [varchar](2) NOT NULL DEFAULT (''),"+;
					"[TIPO] [varchar](1) NOT NULL DEFAULT (''),"+;
					"[CHAVE] [varchar](30) NOT NULL DEFAULT (''),"+;
					"[VALOR] [varchar](MAX) NOT NULL DEFAULT ('')"+;
					") ON [PRIMARY] "

   	    TCSQLEXEC(cQuery)
*/   	    

	//Bloco 100-Contas Fechadas
	//Bloco 101-Hospedes e Empresas da conta    
	//Bloco 102 - Lançamentos (Diárias, Extras, Taxa de Serviço)	
	//Bloco 103 - Taxa de ISS    
	//Bloco 104 - Descontos
	//Bloco 106 - Crédito de Adiantamentos 
	//Bloco 107 - Notas Fiscais Vinculadas 
/*
	if (substr(cLinha,1,3) $ "100-101-102-103-104-106-107")
   	    
   	    cAux = substr(cLinha,24,22) // Chave = Nro da Conta + Sequência
		cQuery := "SELECT TOP 1 ID FROM LHINTEGR WHERE (BLOCO = '"+substr(cLinha,1,3)+"') AND (CAMPO =  '03') AND (CHAVE = '"+cAux+"')"
		TCQuery cQuery NEW ALIAS "HSP" 
		dbselectarea("HSP") 
		dbgotop()
		lInclui := iif(eof(),.t.,.f.)  
		if lInclui   
			cQuery := "INSERT INTO LHINTEGR (BLOCO,CAMPO,TIPO,CHAVE,VALOR) VALUES ('"+substr(cLinha,1,3)+"','03','N','"+cAux+"','"+cLinha+"')
		else        
			cQuery := "UPDATE LHINTEGR SET TIPO = 'N',VALOR = '"+cLinha+"' WHERE ID = "+ALLTRIM(STR(HSP->ID))
		endif 
		TCSQLEXEC(cQuery)
		dbselectarea("HSP") 
		dbclosearea()

	endif 	//Fim Bloco 100 a 104, 106 e 107
	*/
    
    //BLOCO 050 - MOVIMENTAÇÃO DE PAGAMENTOS
    //Bloco 105 - Pagamentos                             
	if lSucesso .and. (substr(cLinha,1,3) == "105") //(substr(cLinha,1,3) $ "050-105")
		//Determinação do valor
		/*
		cAux := substr(cLinha,59,14)+substr(cLinha,74,2)
		nAux := ""
		for i := 1 to len(cAux)
			if substr(cAux,i,1) <> "0"
				nAux := val(substr(cAux,i,len(cAux)-i+1))/100
				exit 
			endif
		next 
		*/
		cAux := substr(cLinha,391,1)
		/*
		cQuery := "INSERT INTO #LHPGTOS (BLOCO,CONTASEQ, TIPOPGTO ,CODHOSPEDE ,VALOR  ,VENCTO ,BCOCHEQUE ,AGENCIA , CONTA ,NROCHEQUE ,PORTADOR ,DEBCRED) VALUES "+;
		"('050','"+substr(cLinha,433,22)+"','"+substr(cLinha,14,30)+"','"+substr(cLinha,44,15)+"','"+substr(cLinha,59,17)+"','"+substr(cLinha,84,8)+"','"+;
		substr(cLinha,292,3)+"','"+substr(cLinha,295,6)+"','"+substr(cLinha,301,20)+"','"+substr(cLinha,321,20)+"','"+substr(cLinha,341,50)+"','"+;
		iif(substr(cLinha,391,1) == "E","D","C")+"')"
		*/
		cQuery := "INSERT INTO LHPGTOS (BLOCO,CONTASEQ, TIPOPGTO ,CODHOSPEDE ,VALOR  ,VENCTO ,BCOCHEQUE ,AGENCIA , CONTA ,NROCHEQUE ,PORTADOR ,DEBCRED) VALUES "+;
		"('105','"+substr(cLinha,433,22)+"','"+substr(cLinha,14,30)+"','"+substr(cLinha,44,15)+"',"+STRTRAN(substr(cLinha,59,17),",",".")+",'"+substr(cLinha,84,8)+"','"+;
		substr(cLinha,292,3)+"','"+substr(cLinha,295,6)+"','"+substr(cLinha,301,20)+"','"+substr(cLinha,321,20)+"','"+substr(cLinha,341,50)+"','"+;
		iif(substr(cLinha,391,1) == "E","D","C")+"')"
		TCSQLEXEC(cQuery)

	endif 	//Fim Bloco 050,105

	// Pagamentos antecipados
	if lSucesso .and. (substr(cLinha,1,3) == "106") 
		/*
		cQuery := "INSERT INTO #LHPGTOS (CONTASEQ, TIPOPGTO ,CODHOSPEDE ,VALOR  ,VENCTO ,BCOCHEQUE ,AGENCIA , CONTA ,NROCHEQUE ,PORTADOR ,DEBCRED) VALUES "+;
		"('106','"+substr(cLinha,24,22)+"','0000000000000000000001.001.001','','"+substr(cLinha,101,17)+"','"+substr(cLinha,68,8)+;
		"'','','','','','"+;
		iif(substr(cLinha,118,1) == "E","D","C")+"')"
		*/
		cQuery := "INSERT INTO LHPGTOS (CONTASEQ, TIPOPGTO ,CODHOSPEDE ,VALOR  ,VENCTO ,BCOCHEQUE ,AGENCIA , CONTA ,NROCHEQUE ,PORTADOR ,DEBCRED) VALUES "+;
		"('106','"+substr(cLinha,24,22)+"','0000000000000000000001.001.001','','"+strtran(substr(cLinha,101,17),",",".")+"','"+substr(cLinha,68,8)+;
		"'','','','','','"+;
		iif(substr(cLinha,118,1) == "E","D","C")+"')"
		TCSQLEXEC(cQuery)

	endif 	//Fim Bloco 050,105

	//Bloco 102 - Lançamentos (Diárias, Extras, Taxa de Serviço) , usado para cadastrar itens das NF´s
	if lSucesso 
		cQuery := "IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LHINTEGR]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1) "+;
					"CREATE TABLE [dbo].[LHINTEGR]( "+;
					"[ID] [INT] IDENTITY(1,1) NOT NULL,"+;
					"[BLOCO] [varchar](3) NOT NULL DEFAULT (''),"+;
					"[CAMPO] [varchar](2) NOT NULL DEFAULT (''),"+;
					"[TIPO] [varchar](1) NOT NULL DEFAULT (''),"+;
					"[CHAVE] [varchar](30) NOT NULL DEFAULT (''),"+;
					"[VALOR] [varchar](MAX) NOT NULL DEFAULT ('')"+;
					") ON [PRIMARY] "

   	    TCSQLEXEC(cQuery)
	
	
		cQuery := "IF (OBJECT_ID('tempdb..#ITENSNF', 'U') IS NOT NULL) "+;
		"DROP TABLE #ITENSNF; "+;
		"CREATE TABLE #ITENSNF (BLOCO VARCHAR(3) COLLATE database_default,CONTASEQ VARCHAR(22) COLLATE database_default,TIPOLCTO VARCHAR(2) COLLATE database_default NOT NULL DEFAULT '',"+;
		"DATAMOVTO VARCHAR(8) COLLATE database_default NOT NULL DEFAULT '',CODPRO VARCHAR(30) COLLATE database_default NOT NULL DEFAULT '',"+;
		"UM VARCHAR(3) COLLATE database_default NOT NULL DEFAULT '',"+;
		"CODHOSPEDE VARCHAR(15) COLLATE database_default NOT NULL DEFAULT '',VALOR VARCHAR(17) COLLATE database_default NOT NULL DEFAULT '',VENCTO VARCHAR(8) COLLATE database_default NOT NULL DEFAULT '',"+;
		"BCOCHEQUE VARCHAR(3) COLLATE database_default NOT NULL DEFAULT '',AGENCIA VARCHAR(6) COLLATE database_default NOT NULL DEFAULT '', CONTA VARCHAR(6) COLLATE database_default NOT NULL DEFAULT '',"+;
		"NROCHEQUE VARCHAR(20) COLLATE database_default NOT NULL DEFAULT '',PORTADOR VARCHAR(50) COLLATE database_default NOT NULL DEFAULT '',DEBCRED VARCHAR(1) COLLATE database_default NOT NULL DEFAULT '')"

		TCSQLEXEC(cQuery)
	endif 
	
	//Ler Notas de Produto
/*
	if lSucesso .and. !lLeuProds .and. (substr(cLinha,1,3) == "107") //Notas Fiscais de Produto antes das Notas de Serviço
		lSucesso := LerNfProd()
		lLeuProds := .t. //Identifica se já leu as notas fiscais (xmls) de produtos pra não ficar passando pela função
	endif 
*/
	if lSucesso .and. (substr(cLinha,1,3) == "107") //Notas Fiscais
		cSerie := substr(cLinha,51,3)
		cNroNf := substr(cLinha,67,9)
		cEspecie := alltrim(substr(cLinha,46,5)) 
		if !(cEspecie == "CF")
			cAux := alltrim(substr(cLinha,161,50))
			cAux := strtran(strtran(cAux,chr(13),""),chr(10),"")
			cEspecie := IIF(EMPTY(cAux),"SPED","NFS")
		endif
		/*
		if cEspecie == "NFS"
			cNroNf := strzero(val(alltrim(substr(cLinha,160,51))),9)
		endif
		*/
		if cEspecie == "CF" //Cupom Fiscal ainda não tem tratamento!!
			loop
		endif 
		

		cCliApp := substr(cLinha,84,15)
		if cEspecie == "SPED" 
			cChvNfe := substr(cLinha,116,44) //chave da NFe
			cQuery := "IF NOT EXISTS(SELECT * FROM HOSPEDESPORNF WITH (NOLOCK) WHERE CHVNFE = '"+cChvNfe+"') "+;
			"INSERT INTO HOSPEDESPORNF (CHVNFE,CODIGO) VALUES ('"+cChvNfe+"','"+cCliApp+"')"
			TCSQLEXEC(cQuery)
		endif 
		
		
		lInclui := .F. // Incluir cliente
		cCodCli := ""

		If SELECT("HSP") > 0
			HSP->(DbcloseArea())
		Endif
		
		cQuery := "SELECT CODIGO,NOMEFANTAS,RAZAO,CNPJ,INSCRRG,PESSOA,CODPAIS,SIGLAPAIS,NOMEPAIS,UF,CIDADE,CODIBGE,BAIRRO,ENDERECO,NUMEND,COMPLEMENTO,CEP,FONE,EMAIL "+;
		"FROM HOSPEDES WHERE CODIGO = '"+cCliApp+"'"
		TCQuery cQuery NEW ALIAS "HSP" 
		dbselectarea("HSP") 
		dbgotop()

		
		IF eof() .AND. !(cEspecie == "SPED") // Se for NF de Produto, como os dados estão no XML, serão pegos dele
			dbselectarea("SA1")
			DbOrderNickName("CODLEIRIA")
			//dbsetorder(7) //Numero RA (Utilizado campo Nro RA para guardar código pessoa do cadastro APP para gravar)
			dbseek(xFilial("SA1")+cCliApp)
			if !found()
				aadd(aNfProbl,{nLinha,cSerie,cNroNf,cCliApp})
				dbselectarea("HSP") 
				dbclosearea() //Fechar consulta cad Hospedes
				loop 
			endif 

/*
			lSucesso := .f.
			MsgAlert("Não encontrado o Hóspede de Código "+cCliApp+", linha "+alltrim(str(nLinha))+"!")
			dbselectarea("HSP") 
			dbclosearea()
			EXIT 
			*/
		ENDIF 
		dbselectarea("HSP")
		IF !eof()
			IF (HSP->UF = "EX")
				dbselectarea("SA1")
				DbOrderNickName("CODLEIRIA")
				//dbsetorder(7) //Numero RA (Utilizado campo Nro RA para guardar código pessoa do cadastro APP para gravar)
				dbseek(xFilial("SA1")+HSP->CODIGO)
				IF !FOUND() 
					lInclui := .t.
				ELSE
					IF !(SA1->A1_EST = "EX") //Nro RA inválido!
						reclock("SA1",.f.)
						SA1->A1_CODLEIR := ""
						msunlock()
						lInclui := .t.
					ENDIF 
					if !lInclui
						cCodCli := SA1->A1_COD
					endif
				ENDIF
				IF lInclui
					cPais := ""
					cCodPais :=  ""
					if HSP->SIGLAPAIS = "EUA"
						cPais := "249"
						cCodPais := "02496"
					endif 
					if empty(cPais)
						If SELECT("TMPPAIS") > 0
							TMPPAIS->(DbcloseArea())
						Endif
	
						IF LEN(ALLTRIM(HSP->CODPAIS)) < 3
							cQuery := "SELECT YA_CODGI,YA_SISEXP FROM "+RetSqlName("SYA")+;
							" WHERE (D_E_L_E_T_ <> '*') AND (YA_FILIAL = '"+xFilial("SYA")+"') AND (YA_DESCR = '"+U_TIRAACENTO(ALLTRIM(HSP->NOMEPAIS))+"')"
						ELSE
							cQuery := "SELECT YA_CODGI,YA_SISEXP FROM "+RetSqlName("SYA")+;
							" WHERE (D_E_L_E_T_ <> '*') AND (YA_FILIAL = '"+xFilial("SYA")+"') AND (YA_SISEXP = '"+ALLTRIM(HSP->CODPAIS)+"')"
						ENDIF 
						TCQuery cQuery NEW ALIAS "TMPPAIS"
						nAuxCont := 0
						SELECT "TMPPAIS"
						dbgotop()
						do while !eof()
							nAuxCont++
							cPais := TMPPAIS->YA_CODGI
							cCodPais := PADL(ALLTRIM(YA_SISEXP),5,"0")
							dbskip()
						enddo 
						dbclosearea()
					endif
					if empty(cPais)
						cPais := "994"
					endif
					if EMPTY(cCodPais)
						cCodPais := "01058"
					endif
				ENDIF 
	//			MsgAlert("Nota Fiscal "+cNroNf+"/"+alltrim(cSerie)+", linha "+alltrim(str(nLinha))+" do arquivo deverá ser cadastrada manualmente caso ainda não tenha sido inserida!")
			ELSE
				cPais := "105"
				cCodPais :=  "01058"
				cCgc := alltrim(ALLTRIM(HSP->CNPJ))
				IF HSP->PESSOA = "F"
					cCgc := right(cCgc,11)
				ENDIF 
				dbselectarea("SA1")
				dbsetorder(3) //cnpj
				dbseek(xFilial("SA1")+cCgc)
				IF found()
					cCodCli := SA1->A1_COD
					lBloqueou := .f.
					if (SA1->A1_MSBLQL = "1")
						lBloqueou := .t.
						reclock("SA1",.f.)
						IF SA1->A1_MSBLQL = "1"
							SA1->A1_MSBLQL := "2"
						ENDIF
					endif 
					IF EMPTY(SA1->A1_EMAIL) .AND. !EMPTY(HSP->EMAIL)
						if !lBloqueou
							lBloqueou := .t.
							reclock("SA1",.f.)
						endif 
						SA1->A1_EMAIL := HSP->EMAIL
					ENDIF
					IF !EMPTY(HSP->INSCRRG)
						IF EMPTY(SA1->A1_INSCR) .AND. (SA1->A1_PESSOA = "J")
							if !lBloqueou
								lBloqueou := .t.
								reclock("SA1",.f.)
							endif 
							SA1->A1_INSCR := HSP->INSCRRG
						ENDIF 
						IF EMPTY(SA1->A1_PFISICA) .AND. (SA1->A1_PESSOA = "F")
							if !lBloqueou
								lBloqueou := .t.
								reclock("SA1",.f.)
							endif 
							SA1->A1_PFISICA := HSP->INSCRRG
						ENDIF 
					ENDIF
					if lBloqueou
						msunlock()
					endif
				ELSE
					lInclui := .t.
				ENDIF 
			ENDIF 
		ENDIF // fim IF !eof("HSP")
		IF lInclui  // Incluir Cliente de HSP?
			//Cadastrar Cliente
				
			IF HSP->UF = "EX"
				cCodCid := "300000"
				cMun := "99999"
				cCgc := ""
			ELSE 
				cCodCid := DetCodCid(alltrim(HSP->CODIBGE))
				cMun := substr(HSP->CODIBGE,3,5)
			ENDIF 
			if empty(cCodCid)
				lSucesso := .f.
				MsgAlert("Não encontrada a Cidade "+HSP->CIDADE+", UF "+HSP->UF+", linha do arquivo: "+alltrim(str(nLinha))+"!")
				dbselectarea("HSP") 
				dbclosearea()
				EXIT
			endif 
				 
			dbselectarea("SZ7")
			dbsetorder(1) //Estava dando erro de cód cidade inválido ao incluir!!
			lMsErroAuto := .F.
			aCli := {}
			aAdd(aCli, {"A1_FILIAL" , xFilial("SA1")          , Nil})
			dbselectarea("SA1")
			dbsetorder(1)
			dbgobottom()
			if !eof() .and. !bof()
				reclock("SA1",.F.)
				cAux := PADL(alltrim(STR(val(SA1->A1_COD)+1)),TamSx3("A1_COD")[1],"0")
				msunlock()
			else
				cAux := padl("1",TamSx3("A1_COD")[1],"0")
			endif
			aAdd(aCli, {"A1_COD",   cAux ,Nil}) // código
			aAdd(aCli, {"A1_CODLEIR",  HSP->CODIGO ,Nil}) // código no sistema APP
			aAdd(aCli, {"A1_NOME" , SUBSTR(HSP->RAZAO,1,40)         , Nil}) // Nome 
			aAdd(aCli, {"A1_NREDUZ",    SUBSTR(HSP->NOMEFANTAS,1,20), .F.}) // Nome reduz. 
			cAux := alltrim(HSP->ENDERECO)+iif(!empty(ALLTRIM(HSP->NUMEND)),","+ALLTRIM(HSP->NUMEND),"")
			aAdd(aCli, {"A1_END",       SUBSTR(cAux,1,40),Nil}) // Endereco
			aAdd(aCli, {"A1_BAIRRO",    SUBSTR(HSP->BAIRRO,1,30) ,Nil}) // Bairro
			IF !EMPTY(ALLTRIM(HSP->COMPLEMENTO))
				aAdd(aCli, {"A1_COMPLEM",  SUBSTR(ALLTRIM(HSP->COMPLEMENTO),1,50) ,Nil}) // COMPLEMENTO END
			ENDIF 
			aAdd(aCli, {"A1_TIPO", IIF(HSP->UF = "EX","X","F")  ,Nil}) // Tipo 
			aAdd(aCli, {"A1_CODCID",   cCodCid   ,Nil}) // Codigo Municipio                
			aAdd(aCli, {"A1_COD_MUN",   cMun   ,Nil}) // Codigo Municipio                
			aAdd(aCli, {"A1_CEP",       HSP->CEP      ,Nil}) // CEP
			cAux := IIF(EMPTY(alltrim(HSP->INSCRRG)) .or. (HSP->PESSOA = "F"),"ISENTO",alltrim(HSP->INSCRRG))
			aAdd(aCli, {"A1_INSCR", cAux,.F.}) // Inscricao Estadual
			aAdd(aCli, {"A1_PESSOA",    HSP->PESSOA  ,Nil}) // Tipo Pessoa
			aAdd(aCli, {"A1_CGC",   cCgc ,Nil}) // CNPJ/CPF            
			if (HSP->PESSOA = "F") .AND. !empty(alltrim(HSP->INSCRRG))
				aAdd(aCli, {"A1_PFISICA",  alltrim(HSP->INSCRRG) ,Nil}) // Pais
			endif    
			aAdd(aCli, {"A1_PAIS",      cPais  ,Nil}) // Pais   
			cEmail := substr(alltrim(HSP->EMAIL),1,TamSx3("A1_EMAIL")[1])
			IF empty(alltrim(cEmail))
				cEmail := "leiriahotel@leiriahotel.com.br"
			ENDIF
			aAdd(aCli, {"A1_EMAIL",      cEmail ,Nil}) // E-Mail
			aAdd(aCli, {"A1_DDD",       SUBSTR(HSP->FONE,1,2) ,Nil}) // DDD            
			aAdd(aCli, {"A1_TEL",       SUBSTR(HSP->FONE,3,LEN(HSP->FONE)-2)  ,Nil}) // Fone                 
			aAdd(aCli, {"A1_CLAS",    "C"  ,Nil}) // Tipo Pessoa
			aAdd(aCli, {"A1_CNAE",   "9900-8/00"  ,.F.}) // CNAE
			aAdd(aCli, {"A1_CODPAIS",   cCodPais  ,Nil}) // Tipo Pessoa
			aAdd(aCli, {"A1_SATIV2",    "UF" ,Nil}) // Tipo Pessoa
			lMsErroAuto := .f.
			MsExecAuto({|x,y| MATA030(x,y)}, aCli, 3)
			If lMsErroAuto
				MostraErro()    
				lSucesso := .f.
				exit 
			EndIf
				
			//Fim Cadastrar Cliente
		endif // Fim if lInclui
			
		IF empty(cCodCli) .AND. !eof("HSP")
			//Consultar novamente no cadastro pra ver se encontra
			dbselectarea("SA1")
			IF HSP->UF = "EX"	
				DbOrderNickName("CODLEIRIA") 
				//dbsetorder(7) //Numero RA (Utilizado campo Nro RA para guardar código pessoa do cadastro APP para gravar)
				dbseek(xFilial("SA1")+cCliApp)
			ELSE 
				dbsetorder(3) //cnpj
				dbseek(xFilial("SA1")+cCgc)
			ENDIF 
			if found()
				cCodCli := SA1->A1_COD
			ENDIF
		ENDIF

		if empty(cCodCli)
			dbselectarea("SA1")
			DbOrderNickName("CODLEIRIA") 
			dbseek(xFilial("SA1")+cCliApp)
			if found()
				cCodCli := SA1->A1_COD
			ENDIF
		endif 

		//Se ainda assim o código estiver em branco e for NF de Serviço algo deu errado!!
		if empty(cCodCli) .AND. !(cEspecie == "SPED")
			aadd(aNfProbl,{nLinha,cSerie,cNroNf,cCliApp})
			dbselectarea("HSP") 
			dbclosearea() //Fechar consulta cad Hospedes
			loop 
			/*
			lSucesso := .f.
			MsgAlert("Nota Fiscal "+cNroNf+"/"+alltrim(cSerie)+", linha "+alltrim(str(nLinha))+" , algo deu errado, não encontrado o código do cliente!")
			exit
			*/
		endif 
		dbselectarea("HSP") 
		dbclosearea() //Fechar consulta cad Hospedes
		

		cQuery := "INSERT INTO NFPGTOS (NRONF,SERIE,CLIENTE,CODHOSPEDE,VALOR,CONTASEQ) VALUES ('"+cNroNf+"','"+cSerie+"','"+cCodCli+"','"+cCliApp+"',"+STRTRAN(substr(cLinha,99,17),",",".")+",'"+substr(cLinha,24,22)+"')" 
		/*cQuery := "UPDATE LHPGTOS SET NRONF = '"+cNroNf+"',SERIE = '"+cSerie+"' WHERE (CONTASEQ = '"+substr(cLinha,24,22)+"') AND "+;
		"(CODHOSPEDE = '"+cCliApp+"')"*/
		TCSQLEXEC(cQuery)


		if cEspecie == "SPED" //Cadastrar NF de Produtos via XML!!
			loop
		endif 
		 
		if (cEspecie == "NFS")
			cAux := alltrim(substr(cLinha,211,255)) //Código de verificação da NFSe
			if empty(cAux) //NF não autorizada
				loop
			endif
		endif 
		dEmissao := ctod(substr(cLinha,76,2)+"/"+substr(cLinha,78,2)+"/"+substr(cLinha,80,4))
	    nValor := val(substr(cLinha,99,14)) + (val(substr(cLinha,114,2))/100)

		dbselectarea("SF2")
		dbsetorder(2) //F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE+F2_TIPO+F2_ESPECIE 
		dbseek(xFilial("SF2")+cCodCli+"01"+cNroNf+cSerie+"N"+cEspecie)
		if !found() // Se não existir NF, cadastrar
			//*****Inclusão da Nota Fiscal
			lMsErroAuto := .F.
	
			dbSelectArea("SF2")
			aCabec := {}
			aItens := {}
	
			aadd(aCabec,{"F2_TIPO"   ,"N"})
			aadd(aCabec,{"F2_FORMUL"   ,"S"})
			aadd(aCabec,{"F2_DOC"    ,cNroNf})
			aadd(aCabec,{"F2_SERIE"  ,cSerie})
			aadd(aCabec,{"F2_EMISSAO",dEmissao})
			aadd(aCabec,{"F2_DTDIGIT",dEmissao,.F.})
			aadd(aCabec,{"F2_CLIENTE",cCodCli})
			aadd(aCabec,{"F2_LOJA"   ,"01"})
			aadd(aCabec,{"F2_RAZAO"   ,SA1->A1_NOME})
			aadd(aCabec,{"F2_ESPECIE",cEspecie})
			aadd(aCabec,{"F2_COND","001"})
			aadd(aCabec,{"F2_DESCONT",0})
			aadd(aCabec,{"F2_FRETE",0})
			aadd(aCabec,{"F2_SEGURO",0})
			aadd(aCabec,{"F2_DESPESA",0})
			if cEspecie == "SPED"
				aadd(aCabec,{"F2_CHVNFE",substr(cLinha,116,44)})
			endif
			
			//Inclusão dos itens
			   aLinha := {}
			   aadd(aLinha,{"D2_COD"  ,"ZZV0012999999",Nil})
			   aadd(aLinha,{"D2_ITEM" ,"01",Nil})
			   aadd(aLinha,{"D2_DTDIGIT",dEmissao,.F.})
			   aadd(aLinha,{"D2_QUANT",1,Nil})
			   aadd(aLinha,{"D2_PRCVEN",nValor,Nil})
			   aadd(aLinha,{"D2_TOTAL",nValor,Nil})
			   aadd(aLinha,{"D2_TES","707",Nil})
			   aadd(aItens,aLinha)
			//-- Inclusão da Nota
			MATA920(aCabec,aItens)
			If lMsErroAuto
			   	MostraErro()
			    MsgAlert("Erro na inclusão da NF "+cNroNf+", série "+cSerie)
		    EndIf
			//*****Fim Inclusão da Nota Fiscal
		endif //if !found() // Se não existir NF, cadastrar
		
		//**Início tratamento Financeiro Fazendo liquidações para Cartões de Créditos, baixas pgtos em dinheiro, etc..
		//Prepara o array para o execauto
		dbselectarea("SE1")
		dbsetorder(2) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO    
		dbgotop()
		cTitulo := cCodCli+PADR("01",TamSx3("E1_LOJA")[1]," ")+PADR(cSerie,TamSx3("E1_PREFIXO")[1]," ")+cNroNf+space(TamSx3("E1_PARCELA")[1])+"NF"
		dbseek(xFilial("SE1")+cTitulo)
		IF !FOUND() // Cadastrar Conta a Receber
		     //Verificar se cod vendedor esta bloqueado
		     lDesblVend := .f.
			dbselectarea("SA1")
			dbsetorder(1)
			dbseek(xFilial("SA1")+cCodCli)
			IF found() .and. (!EMPTY(SA1->A1_VEND))
				dbselectarea("SA3")     
				dbsetorder(1)    
				dbseek(xFilial("SA3")+SA1->A1_VEND)   
				if found() .and. (SA3->A3_MSBLQL = "1")
					reclock("SA3",.F.)
					SA3->A3_MSBLQL := "2"
					msunlock()
					lDesblVend := .T.
				endif
			ENDIF
		
				
				                                                                                                                                                                                                                    
			aVetor := {}
			aAdd(aVetor, {"E1_FILIAL",  xFilial("SE1"),  Nil})
			aAdd(aVetor, {"E1_NUM",     cNroNf,           Nil})
			aAdd(aVetor, {"E1_PREFIXO", cSerie,          Nil})
			aAdd(aVetor, {"E1_PARCELA", "",          Nil})
			aAdd(aVetor, {"E1_TIPO",    "NF",             Nil})
			aAdd(aVetor, {"E1_NATUREZ", "11111",         Nil})
			aAdd(aVetor, {"E1_CLIENTE", cCodCli,          .f.})
			aAdd(aVetor, {"E1_LOJA",    "01",             .f.})
			aAdd(aVetor, {"E1_VEND1","",          Nil})
			//aAdd(aVetor, {"E1_NOMCLI",  cNomCli,           Nil})
			aAdd(aVetor, {"E1_EMISSAO", dEmissao,          Nil})
			aAdd(aVetor, {"E1_VENCTO",  dEmissao,           Nil})
			//aAdd(aVetor, {"E1_VENCREA", dVencReal,         Nil})
			aAdd(aVetor, {"E1_VALOR",   nValor,            Nil})
			//aAdd(aVetor, {"E1_VALJUR",  nValJuros,         Nil})
			//aAdd(aVetor, {"E1_PORCJUR", nPorcJuros,        Nil})
			//aAdd(aVetor, {"E1_HIST",    cHist,             Nil})
			aAdd(aVetor, {"E1_MOEDA",   1,                 Nil})
			 
			//Inicia o controle de transação
			Begin Transaction
			    //Chama a rotina automática
			    lMsErroAuto := .F.
			    MSExecAuto({|x,y| FINA040(x,y)}, aVetor, 3)
			     
			    //Se houve erro, mostra o erro ao usuário e desarma a transação
			    If lMsErroAuto
			        MostraErro()
			        DisarmTransaction()
			        MsgAlert("Erro na inclusão do título da NF "+cNroNf+", série "+cSerie)
			        lSucesso := .f.
			    EndIf
			//Finaliza a transação
			End Transaction
			
			//Voltar bloqueio de vendedor
			IF lDesblVend
				dbselectarea("SA1")
				dbsetorder(1)
				dbseek(xFilial("SA1")+cCodCli)
				IF found() 
					dbselectarea("SA3")     
					dbsetorder(1)    
					dbseek(xFilial("SA3")+SA1->A1_VEND)   
					if found() 
						reclock("SA3",.F.)
						SA3->A3_MSBLQL := "1"
						msunlock()
					endif
				ENDIF
			ENDIF
				
		ENDIF  
	
	endif // Fim da leitura das Notas fiscais

	
enddo 
if _nHdl <> -1
	fClose(_nHdl)
endif 

//Caso deixem o parâmetro do TXT em branco tentar ler apenas os xmls dos produtos
if lSucesso .and. !lLeuProds
	lSucesso := LerNfProd()
	lLeuProds := .t. //Identifica se já leu as notas fiscais (xmls) de produtos pra não ficar passando pela função
endif 

if !lSucesso
	MsgAlert("Houve falha na leitura do arquivo!"+" Linha do arquivo "+alltrim(str(nLinha)),"Aviso")
	return
endif 

If Select("HSB") > 0
	dbselectarea("HSB")
	dbclosearea()
endif

ProcRegua( 6)
 
IncProc("Inserindo Notas Fiscais no Sistema ")   

IF len(aNfProbl) > 0
	lSucesso := .f. // Não continuar até cadastrar Hóspedes Faltantes
	cMensErro := "Hóspedes Faltantes! Cadastre e REPROCESSE!!"
    aCabExcel := {}
    AADD(aCabExcel, {"Linha Arq"    ,"N", 6,  0}) 
    AADD(aCabExcel, {"Série NF"    , "C", 10, 0}) 
    AADD(aCabExcel, {"Nro NF" 		,"C", 09, 0}) 
    AADD(aCabExcel, {"Cód Hóspede Sist. App","C", 30, 0}) 

    If !ApOleClient("MsExcel")
             MsgAlert("Microsoft Excel nao instalado.")  //"Microsoft Excel nao instalado."
    else
		cNomeArq := retfilename(_cFile)+".xml"
		IF FILE(_cPath+cNomeArq)
			ferase(_cPath+cNomeArq)
		ENDIF
		if len(aNfProbl) > 0
			oExcel      := AppExcel():New()

			oExcel:SetDestPath(_cPath )
			If ! ExistDir( "\spool\" )
				MakeDir( "\spool\" )
			Endif
			oExcel:SetFileName( "\spool\"+cNomeArq )
			oExcel:SetSheetName( 'Nfs' )
			//Cabeçalho
			oFont1:SetBold( .T. )
			oCelL01C01 := AppExcCell():New() 
			oCelL01C01:SetCellColor("#FFFFFF") 
			oCelL01C01:SetHorzAlign( HORIZONTAL_ALIGN_CENTER ); oCelL01C01:SetFont( oFont1 )
			oCelL01C01:SetVertAlign( VERTICAL_ALIGN_CENTER )
			oFont2:SetBold( .F. )
			oCelL02C01 := AppExcCell():New()
			oCelL02C01:SetFont( oFont2 )
			oExcel:Merge( 1, 01, 00, 00, "Linha Arq"                                                 , oCelL01C01 )
			oExcel:Merge( 1, 02, 00, 00, "Série NF"                                                  , oCelL01C01 )
			oExcel:Merge( 1, 03, 00, 00, "Nro NF"                                                     , oCelL01C01 )
			oExcel:Merge( 1, 04, 00, 00, "Cód Hóspede Sist. App"                                      , oCelL01C01 )
			for i := 1 to len(aNfProbl)
	//{nLinha,cSerie,cNroNf,cCliApp}		
				oExcel:Merge( i+1,  1, 0, 0, aNfProbl[i,1]                                      , oCelL02C01 )
				oExcel:Merge( i+1,  2, 0, 0, aNfProbl[i,2]                                       , oCelL02C01 )
				oExcel:Merge( i+1,  3, 0, 0, aNfProbl[i,3]                                       , oCelL02C01 )
				oExcel:Merge( i+1,  4, 0, 0, aNfProbl[i,4]	                                    , oCelL02C01 )
				
			next

			oExcel:Make( .F. )
			oExcel:SetFileName( _cPath+cNomeArq )
			oExcel:Destroy()
			IF FILE("\spool\"+cNomeArq)
				ferase("\spool\"+cNomeArq)
			ENDIF
			IF FILE(_cPath+cNomeArq)
				MsgAlert("Gerada a Planilha com Hóspedes a entrar manualmente: "+_cPath+cNomeArq,"Aviso")
			ELSE
				MsgAlert("NÃO FOI POSSÍVEL GERAR PLANILHA COM RELAÇÃO DE NFS COM PROBLEMA!","Erro")
			ENDIF 
		endif
		
    EndIf
	
ENDIF 



lBaixaFin := .T.
if lSucesso
	If SELECT("TMPNFS") > 0
		TMPNFS->(DbcloseArea())
	Endif
	cQuery := "SELECT TOP 1 NRONF,SERIE,CLIENTE FROM NFPGTOS "+;
	"LEFT OUTER JOIN SE1010 SE1 WITH (NOLOCK ) ON (SE1.D_E_L_E_T_ <> '*') AND (E1_FILIAL = '"+xFilial("SE1")+"') AND (E1_TIPO = 'NF') AND (E1_PARCELA = '') AND "+; 
	"(E1_PREFIXO = NFPGTOS.SERIE) AND (E1_NUM = NFPGTOS.NRONF) AND (E1_CLIENTE = NFPGTOS.CLIENTE) "+;
	"WHERE (NFPGTOS.NRONF IS NULL)"
	TCQuery cQuery NEW ALIAS "TMPNFS" 
	dbselectarea("TMPNFS")
	dbgotop()
	do while lSucesso .and. !eof()
		lBaixaFin := .f.
		MsgAlert("Atenção! Faltam NFs a importar, por ex a nro "+TMPNFS->NRONF+", série "+TMPNFS->SERIE)
		exit
	enddo 

	If SELECT("TMPNFS") > 0
		TMPNFS->(DbcloseArea())
	Endif
endif 


// Registrar Pagamentos
if lSucesso .and. lBaixaFin

/*
	cQuery := "IF (OBJECT_ID('LHPGTOS', 'U') IS NOT NULL) "+;
	"DROP TABLE LHPGTOS; "+;
	"CREATE TABLE LHPGTOS (BLOCO VARCHAR(3) COLLATE database_default,CONTASEQ VARCHAR(22) COLLATE database_default,TIPOPGTO VARCHAR(30) COLLATE database_default NOT NULL DEFAULT '',"+;
	"CODHOSPEDE VARCHAR(15) COLLATE database_default NOT NULL DEFAULT '',VALOR FLOAT NOT NULL DEFAULT 0.0,VENCTO VARCHAR(8) COLLATE database_default NOT NULL DEFAULT '',"+;
	"BCOCHEQUE VARCHAR(3) COLLATE database_default NOT NULL DEFAULT '',AGENCIA VARCHAR(6) COLLATE database_default NOT NULL DEFAULT '', CONTA VARCHAR(6) COLLATE database_default NOT NULL DEFAULT '',"+;
	"NROCHEQUE VARCHAR(20) COLLATE database_default NOT NULL DEFAULT '',PORTADOR VARCHAR(50) COLLATE database_default NOT NULL DEFAULT '',DEBCRED VARCHAR(1) COLLATE database_default NOT NULL DEFAULT '',"+;
	"NRONF VARCHAR(9) COLLATE database_default NOT NULL DEFAULT '',SERIE VARCHAR(3) COLLATE database_default NOT NULL DEFAULT '')"
	TCSQLEXEC(cQuery)

	cQuery := "IF (OBJECT_ID('NFPGTOS', 'U') IS NOT NULL) "+;
	"DROP TABLE NFPGTOS; "+;
	"CREATE TABLE NFPGTOS (CONTASEQ VARCHAR(22) COLLATE database_default,CLIENTE VARCHAR(6) COLLATE database_default,"+;
	"NRONF VARCHAR(9) COLLATE database_default NOT NULL DEFAULT '',SERIE VARCHAR(3) COLLATE database_default NOT NULL DEFAULT '',VALOR FLOAT NOT NULL DEFAULT 0.0)"
	TCSQLEXEC(cQuery)
*/

	cQuery := "IF (OBJECT_ID('LHPGTOSR', 'U') IS NOT NULL) "+;
	"DROP TABLE LHPGTOSR; "+;
	"WITH TMP AS (SELECT CODHOSPEDE,CONTASEQ,TIPOPGTO,MAX(VENCTO) AS VENCTO,BCOCHEQUE,AGENCIA,CONTA,NROCHEQUE,PORTADOR,SUM(VALOR) AS VALOR "+;
	"FROM LHPGTOS "+;  
	"WHERE (BLOCO = '105') "+; 
	"GROUP BY CODHOSPEDE,CONTASEQ,TIPOPGTO,BCOCHEQUE,AGENCIA,CONTA,NROCHEQUE,PORTADOR HAVING SUM(VALOR) > 0.0) "+; 
	"SELECT ROW_NUMBER() OVER (ORDER BY CONTASEQ,CODHOSPEDE,TIPOPGTO) AS REG,* INTO LHPGTOSR FROM TMP ORDER BY CONTASEQ,CODHOSPEDE,TIPOPGTO; "
	TCSQLEXEC(cQuery) 


	If SELECT("NFPGTOS") > 0
		NFPGTOS->(DbcloseArea())
	Endif


	dbselectarea("SE1")
	dbsetorder(2) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO                                                                                               
	cQuery := "SELECT CONTASEQ,CLIENTE,CODHOSPEDE,NRONF,SERIE,VALOR FROM NFPGTOS ORDER BY CONTASEQ,SERIE,NRONF DESC,CODHOSPEDE "
	TCQuery cQuery NEW ALIAS "NFPGTOS" 
	dbselectarea("NFPGTOS")
	dbgotop()
	do while lSucesso .and. !eof()
		nSldDisp := 0
		aCab      :=  {}
		aTitOri   :=  {}      
		aTitCx    := {}
		cLojaLiq  :=  '01'
		cNaturez  :=  "11111"
		nMoeda    :=  1
		cCliApp := NFPGTOS->CODHOSPEDE
		cConta := NFPGTOS->CONTASEQ
		cCliCta := NFPGTOS->CLIENTE+NFPGTOS->CONTASEQ
		dbselectarea("NFPGTOS")
		do while lSucesso .and. !eof() .and. (cConta == NFPGTOS->CONTASEQ)//(cCliCta == (NFPGTOS->CLIENTE+NFPGTOS->CONTASEQ))
			dbselectarea("SE1")
			dbseek(xFilial("SE1")+padr(NFPGTOS->CLIENTE,TamSx3("E1_CLIENTE")[1]," ")+"01"+padr(NFPGTOS->SERIE,TamSx3("E1_PREFIXO")[1]," ")+padr(NFPGTOS->NRONF,TamSx3("E1_NUM")[1]," ")+SPACE(TamSx3("E1_PARCELA")[1])+"NF ")
			if found()    
				if SE1->E1_SALDO > 0
					Aadd(aTitOri,{;
					xFilial("SE1"),; //E1_FILIAL
					NFPGTOS->SERIE,; //E1_PREFIXO
					NFPGTOS->NRONF,; //E1_NUM
					'  ',; //E1_PARCELA
					'NF ',; //E1_TIPO
					NFPGTOS->CLIENTE,; //E1_CLIENTE
					'01'; //E1_LOJA
					})
					nSldDisp += SE1->E1_SALDO
				endif
			endif 
			dbselectarea("NFPGTOS")
			dbskip()
		enddo  
		
		
/*		
		cQuery := "SELECT CONTASEQ,TIPOPGTO,MAX(VENCTO) AS VENCTO,BCOCHEQUE,AGENCIA,CONTA,NROCHEQUE,PORTADOR,SUM(VALOR) AS VALOR "+;
		"FROM LHPGTOS "+; 
		"WHERE (BLOCO = '105') AND (CODHOSPEDE = '"+cCliApp+"') AND (CONTASEQ = '"+cConta+"')"+;
		"GROUP BY CONTASEQ,TIPOPGTO,BCOCHEQUE,AGENCIA,CONTA,NROCHEQUE,PORTADOR HAVING SUM(VALOR) > 0.0 "+;
		"ORDER BY TIPOPGTO,VENCTO,BCOCHEQUE,AGENCIA,CONTA,NROCHEQUE,PORTADOR"
		*/
		/*
		cQuery := "SELECT * "+;
		"FROM LHPGTOSR "+; 
		"WHERE (CODHOSPEDE = '"+cCliApp+"') AND (CONTASEQ = '"+cConta+"')"+;
		"ORDER BY TIPOPGTO,VENCTO,BCOCHEQUE,AGENCIA,CONTA,NROCHEQUE,PORTADOR"
		*/
		If SELECT("TMPPGTOS") > 0
			TMPPGTOS->(DbcloseArea())
		Endif
		cQuery := "SELECT * "+;
		"FROM LHPGTOSR "+; 
		"WHERE (CONTASEQ = '"+cConta+"') "+;
		"ORDER BY TIPOPGTO,VENCTO,BCOCHEQUE,AGENCIA,CONTA,NROCHEQUE,PORTADOR"
		TCQuery cQuery NEW ALIAS "TMPPGTOS" 
		select TMPPGTOS
		dbgotop()
		nCont := 0
		do while lSucesso .and. !eof()

			aItens    :=  {}
			aExcl := {}
			nSomaItens := 0
			aExcl := {} //Excluir saldos após baixados
			cFiltro   :=  ""  //filtro quem conterá os títulos que serão liquidados gerado com base no array aTitOri
			nSaldoBx := TMPPGTOS->VALOR
			cTipoPgto := TMPPGTOS->TIPOPGTO
			do while lSucesso .and. !eof() .and. (TMPPGTOS->TIPOPGTO == cTipoPgto)
				DO CASE
				CASE TMPPGTOS->TIPOPGTO $ "0000000000000000000001.001.001#0000000000000000000001.001.006" //DINHEIRO#DEPÓSITO
					//BAIXAR POR CAIXA
					for nX := 1 to len(aTitOri)
						dbselectarea("SE1")
						dbsetorder(2) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO                                                                                               
						dbseek(xFilial("SE1")+aTitOri[nX][6]+"01"+padr(aTitOri[nX][2],TamSx3("E1_PREFIXO")[1]," ")+padr(aTitOri[nX][3],TamSx3("E1_NUM")[1]," ")+SPACE(TamSx3("E1_PARCELA")[1])+"NF ")
						if !found()    
							lSucesso := .f.
							MsgAlert("Não encontrado o título da NF "+aTitOri[nX][3]+", série "+aTitOri[nX][2]+" para baixar!")
							exit 
						endif 
						
						if (nSaldoBx > 0) .AND. (SE1->E1_SALDO > 0)
							if nSaldoBx > SE1->E1_SALDO
								nValor := SE1->E1_SALDO
							else
								nValor := nSaldoBx
							endif 
							nSaldoBx := nSaldoBx - nValor
							nSldDisp -= nValor
							dVencto := ctod(substr(TMPPGTOS->VENCTO,1,2)+"/"+substr(TMPPGTOS->VENCTO,3,2)+"/"+substr(TMPPGTOS->VENCTO,7,2))
							do case
							case dVencto > date()
								dVencto := date()
							case dVencto < SE1->E1_EMISSAO
								dVencto := SE1->E1_EMISSAO
							endcase 
							IF TMPPGTOS->TIPOPGTO = "0000000000000000000001.001.001
								_cBco := padr("CX1",TamSx3("E8_BANCO")[1]," ") 
								_cAgencia := padr("00001",TamSx3("E8_AGENCIA")[1]," ")
								_cCta := padr("0000000010",TamSx3("E8_CONTA")[1]," ")
							ELSE
								_cBco := padr("237",TamSx3("E8_BANCO")[1]," ")
								_cAgencia := padr("33839",TamSx3("E8_AGENCIA")[1]," ")
								_cCta :=  padr("359009",TamSx3("E8_CONTA")[1]," ")
							ENDIF 
							dbselectarea("SE8")
							dbsetorder(1) //E8_FILIAL+E8_BANCO+E8_AGENCIA+E8_CONTA+DTOS(E8_DTSALAT)                                                                                                         
							dbseek(xFilial("SE8")+_cBco+_cAgencia+_cCta+DTOS(dVencto))
							aBaixa := {}
							aBaixa := {{"E1_PREFIXO"  ,aTitOri[nX][2]          ,Nil    },;           
							{"E1_NUM"      ,aTitOri[nX][3]            ,Nil    },;                   
							{"E1_PARCELA"  ,REPLICATE(" ",TamSx3("E1_PARCELA")[1])     ,Nil    },;           
							{"E1_TIPO"     ,"NF "                  ,Nil    },;           
							{"E1_CLIENTE"  ,aTitOri[nX][6]                  ,Nil    },;           
							{"E1_LOJA"     ,"01"                  ,Nil    },;           
							{"AUTMOTBX"    ,"NOR"                  ,Nil    },;           
							{"AUTBANCO"    ,_cBco                  ,Nil    },;          
							{"AUTAGENCIA"  ,_cAgencia                ,Nil    },;           
							{"AUTCONTA"    ,_cCta           ,Nil    },;           
							{"AUTDTBAIXA"  ,dVencto,Nil    },;           
							{"AUTDTCREDITO",dVencto,Nil    },;           
							{"AUTHIST"     ,"BX "+aTitOri[nX][3]+"/"+aTitOri[nX][2]   ,Nil    },;           
							{"AUTJUROS"    ,0                      ,Nil,.T.},;           
							{"AUTVALREC"   ,nValor       ,Nil    }} 
							lMsErroAuto := .f. 
							dbselectarea("SE1") 
							MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3)    
							If lMsErroAuto
								MostraErro()
								MsgAlert("Erro na baixa do título da NF "+aTitOri[nX][3]+", série "+aTitOri[nX][2])
							Else
								cAux := alltrim(str(int(nSaldoBx*100)))
								cQuery := "UPDATE LHPGTOSR SET VALOR = "+cAux+"/100.0 WHERE REG = "+ALLTRIM(STR(TMPPGTOS->REG))
								TCSQLEXEC(cQuery) 
								
							EndIf
							lSucesso := !lMsErroAuto
						endif
					next
				CASE (TMPPGTOS->TIPOPGTO $ "0000000000000000000001.001.002#0000000000000000000001.001.003#0000000000000000000001.001.005#0000000000000000000001.001.007#000000000000000001.002.001.001#000000000000000001.002.001.002#000000000000000001.002.001.003#000000000000000001.002.001.005") 
							//Liquidar
						nCont++
						cTipoLiq  :=  IIF(TMPPGTOS->TIPOPGTO = "0000000000000000000001.001.002",'CH ','CC ')
						cCliLiq   :=  IIF(cTipoLiq = "CC ",MVXCLICC,aTitOri[1][6]) //MUDAR!!
						cCond     :=  ""
						dVencto   := ctod(substr(TMPPGTOS->VENCTO,1,2)+"/"+substr(TMPPGTOS->VENCTO,3,2)+"/"+substr(TMPPGTOS->VENCTO,7,2))
						if dVencto < date()
							dVencto := date()
							nAux := len(aTitOri)
							if nAux > 0
								IncProc("Vencto Título "+aTitOri[nAux][3]+ " atrasado! Consid dt atual!")
							endif   
						endif 
						if nSldDisp >= (nSomaItens+TMPPGTOS->VALOR)
							nValor := TMPPGTOS->VALOR
						else
							nValor := nSldDisp - nSomaItens
						endif
						nSomaItens += nValor
						if nValor > 0
							IF cTipoLiq = "CH "
								Aadd(aItens,{;
								{"E1_FILIAL"   ,xFilial("SE1") },;
								{"E1_PREFIXO"   ,"CHQ" },;
								{'E1_NUM' , TMPPGTOS->NROCHEQUE },;
								{'E1_PARCELA' , padl(alltrim(str(nCont)),TamSx3("E1_PARCELA")[1],"0") },;
								{'E1_VENCTO' , dVencto },;
								{'E1_BCOCHQ' , TMPPGTOS->BCOCHEQUE },;
								{'E1_AGECHQ' , ALLTRIM(TMPPGTOS->AGENCIA) },;
								{'E1_CTACHQ' , ALLTRIM(TMPPGTOS->CONTA) },;
								{'E1_EMITCHQ' , ALLTRIM(TMPPGTOS->PORTADOR) },;
								{'E1_VLCRUZ' , TMPPGTOS->VALOR } })

									aadd(aExcl,{;
									TMPPGTOS->VALOR , TMPPGTOS->REG })
							ELSE
								nAux := len(aTitOri)
								if nAux > 0
									Aadd(aItens,{;
									{"E1_FILIAL"   ,xFilial("SE1") },;
									{"E1_PREFIXO"   ,"CC " },;
									{'E1_NUM' , aTitOri[nAux][3] },;
									{'E1_PARCELA' , padl(alltrim(str(nCont)),TamSx3("E1_PARCELA")[1],"0") },;
									{'E1_VENCTO' , dVencto },;
									{'E1_VLCRUZ' , nValor } })
									
									aadd(aExcl,{;
									 nValor, TMPPGTOS->REG })
								endif 
							ENDIF
						endif 
				ENDCASE 
				select TMPPGTOS
				dbskip()
			enddo 
			
			
			
			aTitAux := {}
			if (len(aItens) > 0) .and. (len(aTitOri) > 0)
				//Conferir se todos os títulos ainda possuem saldo
				dbselectarea("SE1")
				dbsetorder(2) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO                                                                                               
				For nX := 1 To Len(aTitOri)
					dbselectarea("SE1")
					dbseek(xFilial("SE1")+padr(aTitOri[nX][6],TamSx3("E1_CLIENTE")[1]," ")+aTitOri[nX][7]+padr(aTitOri[nX][2],TamSx3("E1_PREFIXO")[1]," ")+padr(aTitOri[nX][3],TamSx3("E1_NUM")[1]," ")+SPACE(TamSx3("E1_PARCELA")[1])+"NF ")
					if found()    
						if SE1->E1_SALDO > 0
							Aadd(aTitAux,{;
								aTitOri[nX][1],; //E1_FILIAL
								aTitOri[nX][2],; //E1_PREFIXO
								aTitOri[nX][3],; //E1_NUM
								aTitOri[nX][4],; //E1_PARCELA
								aTitOri[nX][5],; //E1_TIPO
								aTitOri[nX][6],; //E1_CLIENTE
								aTitOri[nX][7]; //E1_LOJA
								})
						endif
					if aTitOri[nX][3] = "000033824"
						cAux := ""
					endif 

					endif 
				Next 
			endif 

			if (len(aItens) > 0) .and. (len(aTitAux) > 0)

				//lAutoErrNoFile  := .T.
				//Filtro do Usuario
				cFiltro := " ("
				For nX := 1 To Len(aTitAux)
				    If nX > 1
				    	cFiltro += " .Or. "
				    EndIf
				    cFiltro += " ("
				    cFiltro += " E1_FILIAL == '" + aTitAux[nX][1] + "' .And. "
				    cFiltro += " E1_PREFIXO == '" + aTitAux[nX][2] + "' .And. E1_NUM == '" + aTitAux[nX][3] + "' .And. "
				    cFiltro += " E1_PARCELA == '" + aTitAux[nX][4] + "' .And. E1_TIPO == '" + aTitAux[nX][5] + "' .And. "
				    cFiltro += " E1_CLIENTE == '" + aTitAux[nX][6] + "' .And. E1_LOJA == '" + aTitAux[nX][7] + "' )"    
				Next
				cFiltro += ") .And. E1_SITUACA $ '0FG' .And. (E1_SALDO > 0) .And. Empty(E1_NUMLIQ) "
							
				//Array do processo automatico (aAutoCab)
				aCab:={{"cCondicao"     ,""      },;
				{"cNatureza"    ,"11111"   },;
				{"E1_TIPO"      ,cTipoLiq   },;
				{"cCliente"     ,cCliLiq    },;
			    {"nMoeda"       ,nMoeda   },;
				{"cLoja"        ,"01"  }}

				dbselectarea("SE1")			
				dbsetorder(2) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO  
				//Verificar se já não liquidou (caso de reprocessamento)
				dbseek(xFilial("SE1")+padr(cCliLiq,TamSx3("E1_CLIENTE")[1]," ")+padr("01",TamSx3("E1_LOJA")[1]," ")+padr(aItens[1,2,2],TamSx3("E1_PREFIXO")[1]," ")+padr(aItens[1,3,2],TamSx3("E1_NUM")[1]," ")+padr(aItens[1,4,2],TamSx3("E1_PARCELA")[1]," ")+padr(cTipoLiq,TamSx3("E1_TIPO")[1]," "))
				if !found()
					Fina460(,aCab , aItens , 3, cFiltro)
					If lMsErroAuto
						MostraErro()
						MsgAlert("Erro na liquidação do título da NF "+aTitAux[1][3]+", série "+aTitAux[1][2])
					Else
						for nX := 1 To Len(aExcl)
							if aExcl[nX][1] > 0
								cAux := alltrim(str(int(aExcl[nX][1]*100)))
								cQuery := "UPDATE LHPGTOSR SET VALOR = VALOR - ("+cAux+"/100.0) WHERE REG = "+ALLTRIM(STR(aExcl[nX][2]))
								TCSQLEXEC(cQuery)
							endif 
						next
					EndIf
					lSucesso := !lMsErroAuto
				endif 
			endif
			SELECT("TMPPGTOS") 
		enddo 
		If SELECT("TMPPGTOS") > 0
			TMPPGTOS->(DbcloseArea())
		Endif
			
		dbselectarea("NFPGTOS")
	enddo 
	If SELECT("NFPGTOS") > 0
		NFPGTOS->(DbcloseArea())
	Endif

endif 


if lSucesso
	MsgAlert("Dados lidos com SUCESSO!","Aviso")
else
	cAux := "Houve(ram) falha(s) na(s) leitura(s)!"+" Linha do arquivo "+alltrim(str(nLinha))
	if !empty(cMensErro)
		cAux += chr(13)+chr(10)+cMensErro
	endif

	MsgAlert(cAux,"Aviso")
endif 

Return  
/*/

/*
Programa  : CRIASX1   Autor:  
Data      : 01/03/02
Descricao : Grava Perguntas
/*/
/*
//Cleber (17/02/20) -> Verificar após subir dicionário pro BD
Static Function CriaSX1(cPerg)

Local aHelp := {}

//            Texto do help em português                , inglês,                    espanhol
AAdd(aHelp, {{"Nome do arquivo COM EXTENSÃO"}, {"Nome do arquivo COM EXTENSÃO"}, {"Nome do arquivo COM EXTENSÃO"}})
AAdd(aHelp, {{"Caminho onde está o arquivo"}, {"Caminho onde está o arquivo"}, {"Caminho onde está o arquivo"}})

PutSX1(cPerg,"01",  "Nome do Arquivo?"  ,"Nome do Arquivo?","Nome do Arquivo?","mv_ch1","C",40,00,00,"G","",""   ,"","","mv_Par01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],cPerg)
PutSX1(cPerg,"02",  "Salvo em?"  ,"Salvo em?","Salvo em?","mv_ch2","C",50,00,00,"G","",""   ,"","","mv_Par02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],cPerg)

Return  
*/


Static Function Nvl(cTexto)
local cRet

if upper(alltrim(cTexto)) == ".NULL."
	cRet := ""
else
	cRet := cTexto
endif 
return(cRet)

Static Function DetCodCid(cIbge)
Local cCodCid,cQuery //,cIbge
				cCodCid := ""
				//cIbge := alltrim(HSP->CODIBGE)
				if !empty(cIbge) .and. (len(cIbge) == 7)
					cIbge := substr(cIbge,3,5)
					If SELECT("TMPCID") > 0
						TMPCID->(DbcloseArea())
					Endif

					cQuery := "SELECT Z7_COD FROM SZ7010 WHERE (D_E_L_E_T_ <> '*') AND (Z7_IBGE = '"+cIbge+"') AND (Z7_EST = '"+ALLTRIM(HSP->UF)+"')"
					TCQuery cQuery NEW ALIAS "TMPCID"
					dbselectarea("TMPCID")
					goto top
					if !eof() .AND. !EMPTY(TMPCID->Z7_COD)
					 	cCodCid := TMPCID->Z7_COD
					endif
					dbselectarea("TMPCID")
					dbclosearea()
				endif
				if empty(cCodCid)
					SELECT("SZ7")
					dbsetorder(2)
					dbseek(xFilial("SZ7")+ALLTRIM(HSP->CIDADE))
					DO WHILE !eof() .AND. (SZ7->Z7_FILIAL == xFilial("SZ7")) .and. (ALLTRIM(HSP->CIDADE) == ALLTRIM(SZ7->Z7_NOME)) .and. (SZ7->Z7_EST <> HSP->UF)
						dbskip()
					ENDDO
					if !eof() .and. !bof() .and. (SZ7->Z7_FILIAL == xFilial("SZ7")) .and. (ALLTRIM(HSP->CIDADE) == ALLTRIM(SZ7->Z7_NOME)) .and. (SZ7->Z7_EST = HSP->UF)
						cCodCid := SZ7->Z7_COD
					endif
				endif
return(cCodCid)

Static Function LerNfProd()
Local cCaminho,cArquivo,aCli,cAux,cUf,cCodCid,cPessoa,nValor,nAux
Local lSucesso,cEspecie,aVetor,cMun,cCodApp
Local nHdl,aFiles,nArq,nTamFile,nBtLidos,lAchouBloqueado
Local cAviso,cErro,cChvNfe,_DESCdigit,cTipoNf,_NCMdigit,cEdit1,cCgc,lAchou,cCodCli,cNroNf,cSerie
Local aCabec,aItens,cData,dData,cMenNota,nX,aLinha,cCodPro,nQtde,nPreco,cTes,nPPis,nPCofins,cInativo

Private oNfe,oNF,oEmitente,oIdent,oDestino,oTotal,oTransp,oDet,oICM,oFatura,oAux
Private lMsErroAuto := .f.
Private lMsHelpAuto := .t.
//Private lAutoErrNoFile  := .T.

lSucesso := .t.
cCaminho := _cPath

aFiles := Directory(cCaminho+"*.XML", "D")

cEspecie := "SPED"			
For nArq := 1 To Len(aFiles)
	cArquivo := AllTrim(cCaminho+aFiles[nArq,1])
	
	nHdl    := fOpen(cArquivo,0)
	If nHdl < 0
		lSucesso := .f.
		MsgAlert("O arquivo de nome "+cArquivo+" nao pôde ser aberto! ERRO:"+StrZero(FERROR(), 1)+"!", "Atencao!")
		exit 
		//loop      
	Endif
	nTamFile := fSeek(nHdl,0,2)
	fSeek(nHdl,0,0)
	cBuffer  := Space(nTamFile)                // Variavel para criacao da linha do registro para leitura
	nBtLidos := fRead(nHdl,@cBuffer,nTamFile)  // Leitura  do arquivo XML
	fClose(nHdl)

	cAviso := ""
	cErro  := ""
	cCodApp := "" //Cod Hospede App p/ caso de estrangeiro
	cCodCli := "" //Cód. Cliente                                   
	oNfe := XmlParser(cBuffer,"_",@cAviso,@cErro)
	
	//If Type("oNFe:_NfeProc")<> "U"
	If ValAtrib("oNFe:_NfeProc")<> "U"
		oNF := oNFe:_NFeProc:_NFe
	Else   
		IF ValAtrib("oNFe:_NFe") <> "U"
			oNF := oNFe:_NFe
		ELSE  
			LOOP 
			/*MsgAlert("Não foi possível abrir o arquivo XML "+cArquivo+", provavel falha em sua estrutura. Por favor substitua o arquivo","Atencao!")
			lSucesso := .f.
			exit */
		ENDIF 
	Endif
	
	
	oEmitente  := oNF:_InfNfe:_Emit
	oIdent     := oNF:_InfNfe:_IDE
	oDestino   := oNF:_InfNfe:_Dest
	oTotal     := oNF:_InfNfe:_Total
	oTransp    := oNF:_InfNfe:_Transp
	oDet       := oNF:_InfNfe:_Det

	cChvNfe    := IIF(ValAtrib("oNF:_INFNFE:_ID:TEXT") <> "U",substr(oNF:_INFNFE:_ID:TEXT,4,44),oNFe:_NFeProc:_protNFe:_INFPROT:_CHNFE:TEXT)	//oNFChv:_INFPROT:_CHNFE:TEXT
	
	//	<chNFe>41101108365527000121550050000014611623309134</chNFe>
	If ValAtrib("oNF:_InfNfe:_ICMS")<> "U"
		oICM := oNF:_InfNfe:_ICMS
	Else
		oICM := nil
	Endif 
	
	oFatura    := IIf(ValAtrib("oNF:_InfNfe:_Cobr")=="U",Nil,oNF:_InfNfe:_Cobr)
	cEdit1	   := Space(15)
	_DESCdigit :=space(55)
	_NCMdigit  :=space(8)
	
	
	oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
	// Validações -------------------------------
	// -- CNPJ da NOTA = CNPJ do CLIENTE ? oEmitente:_CNPJ
	cTipoNf := "N"
	cUf := IIF(ValAtrib("oDestino:_EnderDest:_UF:TEXT") <> "U",oDestino:_EnderDest:_UF:TEXT,"")
	IF cUf = "EX"
		//HOSPEDESPORNF (CHVNFE,CODIGO)
		If SELECT("TMPHO") > 0
			TMPHO->(DbcloseArea())
		Endif

		cQuery := "SELECT CODIGO FROM HOSPEDESPORNF WHERE CHVNFE = '"+cChvNfe+"'"
		TCQuery cQuery NEW ALIAS "TMPHO"
		dbselectarea("TMPHO")
		dbgotop()
		if !eof() .and. !bof()
			cCodApp := alltrim(TMPHO->CODIGO)
		endif
		dbclosearea()
		if !empty(cCodApp)
			dbselectarea("SA1")
			DbOrderNickName("CODLEIRIA")    
			//dbsetorder(7) //Numero RA                                                             
			dbseek(xFilial("SA1")+cCodApp)
			if FOUND()
				cCodCli := SA1->A1_COD
			endif
		endif
		if empty(cCodCli)
			MsgAlert("NF do arq "+aFiles[nArq,1]+", hóspede estrangeiro, deverá ser cadastrada manualmente caso ainda não tenha sido inserida!")
			LOOP
		endif
	ENDIF
	if empty(cUf)
		MsgAlert("NF do arq "+aFiles[nArq,1]+", está com a UF do destinatário em branco!")
		lSucesso := .f.
		exit 
	endif

	
	// CNPJ ou CPF
	cCgc := AllTrim(IIf(ValAtrib("oEmitente:_CPF")=="U",oEmitente:_CNPJ:TEXT,oEmitente:_CPF:TEXT)) 
	if !(cCgc == alltrim(SM0->M0_CGC))
		loop 
	Endif
		
	if !(cUf = "EX")
		IF ValAtrib("oDestino:_CPF:TEXT") <> "U"
			cPessoa := "F"
			cCgc := padl(alltrim(oDestino:_CPF:TEXT),11,"0")
		ELSE
			cPessoa := "J"
			cCgc := right(padl(alltrim(oDestino:_CNPJ:TEXT),14,"0"),14)
		ENDIF
	endif

	lAchou := !empty(cCodCli) 
	if lAchou 
		lAchouBloqueado := IIF(SA1->A1_MSBLQL = "1" .OR. !EMPTY(ALLTRIM(SA1->A1_INATIVO)),.T.,.F.)
		cInativo := ALLTRIM(SA1->A1_INATIVO)
	else
		lAchouBloqueado := .f.
		cInativo := "" //Guardar mensagem de A1_INATIVO
		// Considerar situação em que registro está bloqueado
		dbselectarea("SA1")
		dbSetOrder(3)
		dbSeek(xFilial("SA1")+cCgc)
		do while !eof() .and. (xFilial("SA1") = SA1->A1_FILIAL) .AND.  !lAchou .and. (alltrim(SA1->A1_CGC) == cCgc)
			IF !(SA1->A1_MSBLQL == "1")
				lAchou := .t.
				cCodCli := SA1->A1_COD
				EXIT 
			ELSE
				lAchouBloqueado := .t.
				lAchou := .t.
				cCodCli := SA1->A1_COD
			endif
			dbselectarea('SA1')
			dbskip()
		enddo 
	endif
	cSerie := PADR(alltrim(str(val(oIdent:_serie:TEXT))),3," ")
	cNroNf := Right(REPLICATE("0",9)+Alltrim(oIdent:_nNF:TEXT),9)
	
	If !lAchou //Cadastrar Cliente se não encontrar

		lMsErroAuto := .F.
		aCli := {}
		aAdd(aCli, {"A1_FILIAL" , xFilial("SA1")          , Nil})
		cAux := IIf(ValAtrib("oDestino:_xNome:TEXT") <> "U",SUBSTR(oDestino:_xNome:TEXT,1,40)," ")
		aAdd(aCli, {"A1_NOME" , cAux         , Nil}) // Nome 
		aAdd(aCli, {"A1_NREDUZ", SUBSTR(cAux,1,TamSx3("A1_NREDUZ")[1]), Nil}) // Nome reduz. 
		cAux := substr(IIF(ValAtrib("oDestino:_EnderDest:_xLgr:TEXT") <> "U",oDestino:_EnderDest:_xLgr:TEXT," "),1,TamSx3("A1_END")[1])
		cAux1 := IIF(ValAtrib("oDestino:_EnderDest:_nro:TEXT") <> "U",alltrim(oDestino:_EnderDest:_nro:TEXT),"")
		if !empty(cAux1)
			cAux := alltrim(cAux)+", "+cAux1
		endif 
		aAdd(aCli, {"A1_END",  SUBSTR(cAux,1,40),Nil}) // Endereco
		cAux := substr(IIF(ValAtrib("oDestino:_EnderDest:_xBairro:TEXT") <> "U",oDestino:_EnderDest:_xBairro:TEXT," "),1,TamSx3("A1_BAIRRO")[1])
		aAdd(aCli, {"A1_BAIRRO",  cAux ,Nil}) // Bairro
		aAdd(aCli, {"A1_TIPO",      "F"  ,Nil}) // Tipo
		cCodCid := "" 
		cMun := IIF(ValAtrib("oDestino:_EnderDest:_cMun:TEXT") <> "U",oDestino:_EnderDest:_cMun:TEXT,"")
		if !empty(cMun)
				If SELECT("TMPZ7") > 0
					TMPZ7->(DbcloseArea())
				Endif
				cQuery := "SELECT Z7_COD AS CODCID FROM "+RetSqlName("SZ7")+" WHERE (D_E_L_E_T_ <> '*') AND (Z7_FILIAL = '"+xFilial("SZ7")+"') AND (Z7_EST = '"+cUf+"') AND (Z7_IBGE = '"+substr(ALLTRIM(cMun),3,5)+"')"
				TCQuery cQuery NEW ALIAS "TMPZ7"
				dbselectarea("TMPZ7")
				if !EOF() .AND. !BOF()
					cCodCid := TMPZ7->CODCID
				endif 
		endif
		If Select("TMPZ7") <> 0
			TMPZ7->(dbCloseArea())
		Endif
		if empty(cCodCid)
			lSucesso := .f.
			MsgAlert("Não enc cód da cid do arquivo "+aFiles[nArq,1],"Atencao!")
			lSucesso := .f.
			exit
		endif  
		aAdd(aCli, {"A1_CODCID",   cCodCid   ,Nil}) // Codigo Municipio  
		aAdd(aCli, {"A1_COD_MUN",   substr(cMun,3,5)   ,Nil}) // Codigo Municipio IBGE
		cAux := substr(IIF(ValAtrib("oDestino:_EnderDest:_CEP:TEXT") <> "U",oDestino:_EnderDest:_CEP:TEXT," "),1,TamSx3("A1_CEP")[1])
		aAdd(aCli, {"A1_CEP", cAux      ,Nil}) // CEP
		
		cAux := substr(IIF(ValAtrib("oDestino:_IE:TEXT") <> "U",oDestino:_IE:TEXT,""),1,TamSx3("A1_INSCR")[1])
		if (cPessoa = "F") .AND. !empty(cAux)
			aAdd(aCli, {"A1_PFISICA",  cAux ,Nil}) // Inscr Estadual
		endif    
		IF EMPTY(cAux) .OR. (cPessoa == "F")
			cAux := "ISENTO"
		ENDIF 
		aAdd(aCli, {"A1_INSCR", cAux,.F.}) // Inscricao Estadual
		aAdd(aCli, {"A1_PESSOA",  cPessoa  ,Nil}) // Tipo Pessoa
		IF cUf = "EX"
			cCgc := ""
		ENDIF
		aAdd(aCli, {"A1_CGC",   cCgc ,Nil}) // CNPJ/CPF   
		if cUf <> "EX"         
			aAdd(aCli, {"A1_PAIS",      "105"  ,Nil}) // Pais
			aAdd(aCli, {"A1_CODPAIS",    "01058"  ,Nil}) // Tipo Pessoa
		endif    
		cAux := substr(IIF(ValAtrib("oDestino:_email:TEXT") <> "U",oDestino:_email:TEXT,""),1,TamSx3("A1_EMAIL")[1])
		if empty(cAux)
			cAux := "leiriahotel@leiriahotel.com.br"
		endif 
		aAdd(aCli, {"A1_EMAIL",    cAux ,Nil}) // E-Mail
		cAux := substr(IIF(ValAtrib("oDestino:_EnderDest:_fone:TEXT") <> "U",oDestino:_EnderDest:_fone:TEXT," "),1,TamSx3("A1_TEL")[1])
		aAdd(aCli, {"A1_DDD",       SUBSTR(cAux,1,2) ,Nil}) // DDD            
		aAdd(aCli, {"A1_TEL",       SUBSTR(cAux,3,LEN(cAux)-2)  ,Nil}) // Fone                 
		aAdd(aCli, {"A1_CLAS",    "C"  ,Nil}) // Tipo Pessoa
		aAdd(aCli, {"A1_CNAE",   "9900-8/00"  ,.F.}) // CNAE
		aAdd(aCli, {"A1_SATIV2",    "UF" ,Nil}) // Tipo Pessoa

		dbselectarea("SA1")
		dbsetorder(1)
		dbgobottom()
		if !eof() .and. !bof()
			reclock("SA1",.F.)
			cAux := PADL(alltrim(STR(val(SA1->A1_COD)+1)),TamSx3("A1_COD")[1],"0")
			msunlock()
		else
			cAux := padl("1",TamSx3("A1_COD")[1],"0")
		endif
		aAdd(aCli, {"A1_COD",   cAux ,Nil}) // código
		lMsErroAuto := .f.
		MsExecAuto({|x,y| MATA030(x,y)}, aCli, 3)
		If lMsErroAuto
			MostraErro()    
			lSucesso := .f.
			MsgAlert("Erro ao tentar incluir Cliente da Nota Fiscal "+cNroNf+'/'+cSerie)
			exit 
		EndIf
	else
	 	if !empty(cCodCli) .and. lAchouBloqueado
	 		dbselectarea("SA1")
	 		dbsetorder(1)
	 		dbseek(xFilial("SA1")+cCodCli)
	 		if found()
	 			cInativo := SA1->A1_INATIVO
	 			reclock("SA1",.f.)
	 			SA1->A1_MSBLQL := "2"
	 			SA1->A1_INATIVO := ""
	 			msunlock()
	 		endif 
	 	endif 
	Endif

	IF empty(cCodCli)
		//Consultar novamente no cadastro pra ver se encontra
		dbselectarea("SA1")
		dbsetorder(3) //cnpj
		dbseek(xFilial("SA1")+cCgc)
		if found()
			cCodCli := SA1->A1_COD
		ENDIF
	ENDIF
	//Se ainda assim o código estiver em branco algo deu errado!!
	if empty(cCodCli)
		lSucesso := .f.
		MsgAlert("Nota Fiscal do arquivo "+cArquivo+", algo deu errado, não encontrado o código do cliente!")
		exit
	endif 
		
	//Atualizar NFPGTOS para o caso de não ter cadastrado o cliente antes
	cQuery := "UPDATE NFPGTOS SET CLIENTE = '"+cCodCli+"' WHERE (CLIENTE = '') AND (NRONF = '"+cNroNf+"') AND (SERIE = '"+cSerie+"')"
	TCSQLEXEC(cQuery)
	
  	IncProc("Lendo Nf Prod "+cNroNf+'/'+cSerie) 
		
	dbselectarea("SF2")
	dbsetorder(2) //F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE+F2_TIPO+F2_ESPECIE 
		 
	dbseek(xFilial("SF2")+cCodCli+"01"+cNroNf+cSerie+"N"+cEspecie)
	if found() // Nota fiscal já cadastrada
		loop
	endif 

		
		
	//*****Inclusão da Nota Fiscal
	lMsErroAuto := .F.

	//Verificar existência do produto

	dbSelectArea("SF2")
	aCabec := {}
	aItens := {}

	aadd(aCabec,{"F2_TIPO"   ,"N"})
	aadd(aCabec,{"F2_FORMUL"   ,"S"})
	aadd(aCabec,{"F2_DOC"    ,cNroNf})
	aadd(aCabec,{"F2_SERIE"  ,cSerie})
	if !ValAtrib("OIdent:_dEmi:TEXT") = "C"
		cData:=Alltrim(OIdent:_dHEMI:TEXT)  
	else  	
		cData:=Alltrim(OIdent:_dEmi:TEXT)
	endif 
	dData:=CTOD(Substr(cData,9,2)+'/'+Substr(cData,6,2)+'/'+Left(cData,4))
	aadd(aCabec,{"F2_EMISSAO",dData})
	aadd(aCabec,{"F2_DTDIGIT",dData,.F.})
	aadd(aCabec,{"F2_CLIENTE",cCodCli})
	aadd(aCabec,{"F2_LOJA"   ,"01"})
	aadd(aCabec,{"F2_RAZAO"   ,SA1->A1_NOME})
	aadd(aCabec,{"F2_ESPECIE",cEspecie})
	aadd(aCabec,{"F2_COND","001"})
	aadd(aCabec,{"F2_DESCONT",0})
	aadd(aCabec,{"F2_FRETE",0})
	aadd(aCabec,{"F2_SEGURO",0})
	aadd(aCabec,{"F2_DESPESA",0})
	//Informações adicionais da nota
	cMenNota := substr(IIF(ValAtrib("oNF:_InfNfe:_InfAdic:_infcpl:TEXT") <> "U",oNF:_InfNfe:_InfAdic:_infcpl:TEXT,""),1,TamSx3("F2_MENNOTA")[1])
	aadd(aCabec,{"F2_MENNOTA",cMenNota})
	aadd(aCabec,{"F2_CHVNFE",cChvNfe})
	
	dbselectarea("SB1")
	dbsetorder(7) //B1_FILIAL+B1_GRUPO+B1_CODITE                                                                                                                                    	
	//Inclusão dos itens
	nValor := 0
	For nX := 1 To Len(oDet)
		oAux := oDet[nX]
		aLinha := {}
		
		cAux := U_SoNumCar(AllTrim(oDet[nX]:_Prod:_cProd:TEXT))
		lAchou := .f.
		dbselectarea("SB1")
		dbseek(xFilial("SB1")+SPACE(TamSx3("B1_GRUPO")[1])+cAux)
		if !found() //Considerar que foi considerado código analítico
			dbsetorder(1)
			dbseek(xFilial("SB1")+cAux)
			if found() .and. (ALLTRIM(SB1->B1_COD) == cAux)
				lAchou := .t.
			endif 
			dbsetorder(7) //B1_FILIAL+B1_GRUPO+B1_CODITE   
		else
			lAchou := .t.
		endif 
		IF !lAchou
			lSucesso := .f.
			MsgAlert("Não encontrado o Produto "+cAux+" do arquivo "+cArquivo+"!")
			exit
		ELSE
			nPPis := 0
			nPCofins := 0
			cTes := IIF(ValAtrib("oAux:_Imposto:_PIS:_PISAliq:_VPIS:TEXT") <> "U","703","704")
			if cTes == "703" //Determinar PIS e COFINS
				if ValAtrib("oAux:_Imposto:_PIS:_PISAliq:_PPIS:TEXT") <> "U"
					nPPis := val(oAux:_Imposto:_PIS:_PISAliq:_PPIS:TEXT)
				endif
				if ValAtrib("oAux:_Imposto:_COFINS:_COFINSAliq:_PCOFINS:TEXT") <> "U"
					nPCofins := val(oAux:_Imposto:_COFINS:_COFINSAliq:_PCOFINS:TEXT)
				endif
			endif 
			if ((nPPis > 0) .and. (nPPis <> SB1->B1_PPIS)) .or. ((nPCofins > 0) .AND. (nPCofins <> SB1->B1_PCOFINS)) .OR. !(alltrim(SB1->B1_TS) == cTes)
				dbselectarea("SB1")
				reclock("SB1",.f.)
				IF nPPis > 0
					SB1->B1_PPIS := nPPis
				ENDIF
				IF nPCofins > 0 
					SB1->B1_PCOFINS := nPCofins
				ENDIF
				IF !(alltrim(SB1->B1_TS) == cTes)
					SB1->B1_TS := cTes
				ENDIF
				msunlock()
			endif 
		ENDIF
		cCodPro := SB1->B1_COD
		aadd(aLinha,{"D2_COD"  ,cCodPro,Nil})
		aadd(aLinha,{"D2_ITEM" ,StrZero(nX,2),Nil})
		aadd(aLinha,{"D2_DTDIGIT",dData,.F.})
		
		If Val(oDet[nX]:_Prod:_qCom:TEXT) != 0
			nQtde := round(Val(oDet[nX]:_Prod:_qCom:TEXT),TamSx3("D2_QUANT")[2]) 
			nPreco := Round(Val(oDet[nX]:_Prod:_vProd:TEXT)/Val(oDet[nX]:_Prod:_qCom:TEXT),TamSx3("D2_PRCVEN")[2])     
		Else
			nQtde := round(Val(oDet[nX]:_Prod:_qTrib:TEXT),TamSx3("D2_QUANT")[2]) 
			nPreco := Round(Val(oDet[nX]:_Prod:_vProd:TEXT)/Val(oDet[nX]:_Prod:_qTrib:TEXT),TamSx3("D2_PRCVEN")[2])
		Endif
		aadd(aLinha,{"D2_QUANT",nQtde,Nil})
		aadd(aLinha,{"D2_PRCVEN",nPreco,Nil})
		nAux := round(Val(oDet[nX]:_Prod:_vProd:TEXT),TamSx3("D2_TOTAL")[2])
		nValor += nAux
		aadd(aLinha,{"D2_TOTAL",nAux,Nil})
		aadd(aLinha,{"D2_TES",cTes,Nil})
		aadd(aItens,aLinha)
		
	Next nX
	dbselectarea("SB1")
	dbsetorder(1)
	dbselectarea("SF2")
	//-- Inclusao
	MATA920(aCabec,aItens)
	If lMsErroAuto
		MostraErro()
		lSucesso := .f.
	    MsgAlert("Erro na inclusão da NF "+cNroNf+", série "+cSerie)
	    exit 
	else
		if !ExistDir( cCaminho+"\PROCESSADOS" )
			nRet := MakeDir( cCaminho+"\PROCESSADOS" )
			if nRet != 0
				MsgAlert("Não foi possível criar a pasta "+cCaminho+"\PROCESSADOS , erro: "+StrZero(FERROR(), 1)+"!", "Atencao!")
				lSucesso := .f.
			endif 
		endif 
		if lSucesso
			xFile := STRTRAN(Upper(cArquivo),UPPER(cCaminho), cCaminho+"\PROCESSADOS\")
			COPY FILE &cArquivo TO &xFile
			FErase(cArquivo)
		endif
    EndIf
	
	//*****Fim Inclusão da Nota Fiscal
	
	
	if lAchouBloqueado
		dbselectarea("SA1")
		dbsetorder(1)
		dbseek(xFilial("SA1")+cCodCli)
		reclock("SA1",.f.)
		SA1->A1_MSBLQL := "1"
		SA1->A1_INATIVO := cInativo
		msunlock()
	endif 	

	lDesblVend := .f.
	IF !EMPTY(SA1->A1_VEND)
		dbselectarea("SA3")     
		dbsetorder(1)    
		dbseek(xFilial("SA3")+SA1->A1_VEND)   
		if found() .and. (SA3->A3_MSBLQL = "1")
			reclock("SA3",.F.)
			SA3->A3_MSBLQL := "2"
			msunlock()
			lDesblVend := .T.
		endif
	ENDIF

	
		//**Início tratamento Financeiro Fazendo liquidações para Cartões de Créditos, baixas pgtos em dinheiro, etc..
		//Prepara o array para o execauto
		dbselectarea("SE1")
		dbsetorder(2) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO   
		dbseek(xFilial("SE1")+cCodCli+PADR("01",TamSx3("E1_LOJA")[1]," ")+PADR(cSerie,TamSx3("E1_PREFIXO")[1]," ")+cNroNf+space(TamSx3("E1_PARCELA")[1])+"NF")
		IF !FOUND() // Cadastrar Conta a Receber                                                                                                                                                                                                                                              
			aVetor := {}
			aAdd(aVetor, {"E1_FILIAL",  xFilial("SE1"),  Nil})
			aAdd(aVetor, {"E1_NUM",     cNroNf,           Nil})
			aAdd(aVetor, {"E1_PREFIXO", cSerie,          Nil})
			aAdd(aVetor, {"E1_PARCELA", "",          Nil})
			aAdd(aVetor, {"E1_TIPO",    "NF",             Nil})
			aAdd(aVetor, {"E1_NATUREZ", "11111",         Nil})
			aAdd(aVetor, {"E1_CLIENTE", cCodCli,          Nil})
			aAdd(aVetor, {"E1_LOJA",    "01",             Nil})
			//aAdd(aVetor, {"E1_NOMCLI",  cNomCli,           Nil})
			aAdd(aVetor, {"E1_EMISSAO", dData,          Nil})
			aAdd(aVetor, {"E1_VENCTO",  dData,           Nil})
			//aAdd(aVetor, {"E1_VENCREA", dVencReal,         Nil})
			aAdd(aVetor, {"E1_VALOR",   nValor,            Nil})
			//aAdd(aVetor, {"E1_VALJUR",  nValJuros,         Nil})
			//aAdd(aVetor, {"E1_PORCJUR", nPorcJuros,        Nil})
			//aAdd(aVetor, {"E1_HIST",    cHist,             Nil})
			aAdd(aVetor, {"E1_MOEDA",   1,                 Nil})
			 
			//Inicia o controle de transação
			Begin Transaction
			    //Chama a rotina automática
			    lMsErroAuto := .F.
			    MSExecAuto({|x,y| FINA040(x,y)}, aVetor, 3)
			     
			    //Se houve erro, mostra o erro ao usuário e desarma a transação
			    If lMsErroAuto
			        MostraErro()
			        DisarmTransaction()
			        MsgAlert("Erro na inclusão do título da NF "+cNroNf+", série "+cSerie)
			        lSucesso := .f.
			    EndIf
			//Finaliza a transação
			End Transaction
			//Voltar bloqueio de vendedor
			IF lDesblVend
				dbselectarea("SA1")
				dbsetorder(1)
				dbseek(xFilial("SA1")+cCodCli)
				IF found() 
					dbselectarea("SA3")     
					dbsetorder(1)    
					dbseek(xFilial("SA3")+SA1->A1_VEND)   
					if found() 
						reclock("SA3",.F.)
						SA3->A3_MSBLQL := "1"
						msunlock()
					endif
				ENDIF
			ENDIF
			
		ENDIF  
	
	if !lSucesso
		exit
	endif 
next // Fim "For nArq := 1 To Len(aFiles)"


return(lSucesso) // Fim LerNfProd()

static Function ValAtrib(atributo)
Return (type(atributo) )

