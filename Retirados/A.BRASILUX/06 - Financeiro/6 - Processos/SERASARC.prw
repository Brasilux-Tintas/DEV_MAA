#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"


User Function SERASARC()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Local cCgc := "",nValor,cBaixa,cAuxTit
Private _cString   := "SE1"
Private _cPerg     := "SERASARC"
Private _oGeraTxt  
Private _cPath     := '', _cFile  := ''
Private _cEOL      := "CHR(13)+CHR(10)"
Private _nTotCli   := 0 
Private _nTotcRec  := 0

//CriaSX1(_cPerg)  //LGS#20200131 - Adequação para release 12.1.25 e posteriores
Pergunte(_cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da tela de processamento.                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

@ 200,1 TO 380,450 DIALOG _oGeraTxt TITLE OemToAnsi("Tratamento Arq. Retorno SERASA")
@ 02,10 TO 060,215
@ 10,018 Say " Este programa ira gerar um novo arquivo texto à partir de arquivo RETORNO " SIZE 196,0
@ 18,018 Say " fornecido pelo SERASA." SIZE 196,0

@ 70,128 BMPBUTTON TYPE 05 ACTION Pergunte(_cPerg,.T.)
@ 70,158 BMPBUTTON TYPE 01 ACTION Processa( {|| OkGeraTrb() }) 
@ 70,188 BMPBUTTON TYPE 02 ACTION Close(_oGeraTxt)

Activate Dialog _oGeraTxt Centered

Return
//-------------------------------------
Static Function OkGeraTrb
Local _nHdl,cArq,lFim,nTamArq,lComeco,nLidos,nArqDest,lSucesso,cDataLimite
//Local cArcDest
Local _cFile     := alltrim(mv_par01)
Local _cPath     := Alltrim( mv_par02 )  
lSucesso := .t.
_cTipoMov  :=''
_nTotcRec  := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o arquivo texto                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if substr(_cPath,len(_cPath),1) != "\"
	_cPath += "\"
endif

cArq := _cPath+_cFile        

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

cArqDest := _cPath+"R"+_cFile   
if file(cArqDest)
	delete file &cArqDest
endif
nArqDest  := fCreate(cArqDest)

If nArqDest == -1
	MsgAlert("O arquivo "+cArqDest+" nao pode ser criado!","Atencao!")
	Return
Endif

dbselectarea("SE1")
dbsetorder(1)

fSeek(_nHdl, 0, 0)
nTamArq := fSeek(_nHdl, 0, 2)
fSeek(_nHdl, 0, 0)
lComeco = .t. 
lFim = .f.
nLidos := 0
nLinha := 0              

ProcRegua( round(nTamArq/132,0) )
While lSucesso .and. (nLidos < nTamArq) .and. !lFim
	if nLidos < nTamArq
		cLinha := U_fGets(_nHdl)
		nLidos += Len(cLinha) 
	else
		lFim = .t.
	endif 
	nLinha++
  	IncProc("Lendo linha "+alltrim(str(nLinha)))  

	if (nLinha == 1) .and. !(SUBSTR(cLinha,37,8) == "CONCILIA")
		MsgAlert("Este arquivo não é um arquivo de CONCILIAÇÃO SERASA! ","Atencao!")
		lSucesso := .f. 
		exit 
	endif     
	if nLinha == 1
		cDataLimite := substr(cLinha,45,8)
	endif 
	if (nLinha > 1) .and. (substr(cLinha,1,2) != "99")
		cAux := rtrim(substr(cLinha,68,32))
	   /*	if len(cAux) == 15
			cAux := xFilial("SE1")+cAux
		endif 
		*/
		dbselectarea("SE1")
		dbseek(cAux)
		if !found()
			/*
			MsgAlert("Não encontrado o título "+cAux+" da linha do arquivo nro "+alltrim(str(nLinha)),"Atencao!")
			lSucesso := .f.                                                                                      
			*/
			cAux := substr(cLinha,29,8) // Título excluido no sistema, colocar a data de emissão do mesmo na data de baixa
		ELSE
			cAux := padr(dtos(SE1->E1_BAIXA),8," ")
		endif 
		if cAux > cDataLimite
			cAux := space(8)
		endif 
//		cAux := substr(cLinha,1,57)+padr(dtos(SE1->E1_BAIXA),8," ")+substr(cLinha,66,len(cLinha)-65)
		cLinha := substr(cLinha,1,57)+cAux+substr(cLinha,66,len(cLinha)-65)
	
	endif 

	If fWrite(nArqDest,cLinha,Len(cLinha)) != Len(cLinha)
		MsgAlert("Ocorreu um erro na gravacao do arquivo retorno, linha do arquivo nro "+alltrim(str(nLinha)),"Atencao!")
		lSucesso := .f.
		exit 
	Endif     
		
enddo 
fClose(_nHdl)
fClose(nArqDest)
if lSucesso
	MsgAlert("Arquivo "+cArqDest+" gerado com SUCESSO!","Aviso")
else
	MsgAlert("Houve falha na geração do arquivo!","Aviso")
endif 

Return  

/*/
Programa  : CRIASX1   Autor:  
Data      : 01/03/02
Descricao : Grava Perguntas
/*/
//LGS#20200131 - Adequação para release 12.1.25 e posteriores
/*
Static Function CriaSX1(cPerg)

Local aHelp := {}

//            Texto do help em português                , inglês,                    espanhol
AAdd(aHelp, {{"Nome do arquivo COM EXTENSÃO"}, {"Nome do arquivo COM EXTENSÃO"}, {"Nome do arquivo COM EXTENSÃO"}})
AAdd(aHelp, {{"Caminho onde está o arquivo"}, {"Caminho onde está o arquivo"}, {"Caminho onde está o arquivo"}})

PutSX1(cPerg,"01",  "Nome do Arquivo?"  ,"Nome do Arquivo?","Nome do Arquivo?","mv_ch1","C",20,00,00,"G","",""   ,"","","mv_Par01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],cPerg)
PutSX1(cPerg,"02",  "Salvo em?"  ,"Salvo em?","Salvo em?","mv_ch2","C",40,00,00,"G","",""   ,"","","mv_Par02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],cPerg)

Return
*/