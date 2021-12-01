#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function BRFATR28()
 //UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA¢¯
 //©ø Define Variaveis                                             ©ø
 //AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAU
PRIVATE CbTxt
PRIVATE Titulo 	:= "Relatorio solicitacao de amostra "
PRIVATE cDesc1 	:= ""
PRIVATE cDesc2 	:= ""
PRIVATE cDesc3 	:= "" 
PRIVATE cCabec1 := ""
PRIVATE cCabec2 := ""
private nTipo 	:= 18
PRIVATE Tamanho	:= "P"
PRIVATE Limite 	:= 80
PRIVATE cString	:= "Z04"
private m_pag   := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:="BRFATR28"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   :="BRFATR28"

//UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA¢¯
//©ø Verifica as perguntas selecionadas                           ©ø
//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAU
    if !u_VldAcesso(funname())
      MsgBox("Acesso nao autorizado!---->"+funname(),"Atencao","Alert")
      return 
  endif 
     u_zcfga01( 'BRFATR28' ) //LGS#2021201 - Gravação de log de utilização da rotina
//CriaSX1(cPerg)
Pergunte(cPerg,.F.)
//UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA¢¯
//©ø Envia controle para a funcao SETPRINT                        ©ø
//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAU

wnrel:="BRFATR28"            //Nome Default do relatorio em Disco

wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)


If nLastKey==27
	dbClearFilter()
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey==27
	dbClearFilter()
   Return
Endif

//UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA¢¯
//©ø Inicio do Processamento do Relatorio                         ©ø
//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAU

RptStatus({|| RptDetail()})

return

/////////////////////////////////////////////////////////
// Funcao....: RPTDETAIL    Data....: 03/10/13         //
// Autor.....: Marcelo J. A. de Paiva                  //
/////////////////////////////////////////////////////////

Static Function RptDetail()
Local nTotal   := 0
Local cQuery   := ""
Local nAmostra := 0
Local cRepres  := ""
Private _nLin  := 7
 
 
//UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA¢¯
//©ø Inicializa  regua de impressao                            ©ø
//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAU

cQuery :="SELECT Z04_CODIGO,Z04_REPRES, A3_NOME, Z04_CLIENT ,A1_NOME, Z04_CODGER "
cQuery +="FROM "+RetSqlName("Z04")+" Z04 WITH (NOLOCK) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON SA1.D_E_L_E_T_ <> '*' AND (A1_FILIAL = '"+XFILIAL("SA1")+"') AND A1_COD = Z04_CLIENT "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SA3")+" SA3 WITH (NOLOCK) ON SA3.D_E_L_E_T_ <> '*' AND (A3_FILIAL = '"+XFILIAL("SA3")+"') AND A3_COD = Z04_REPRES "
cQuery +="WHERE (Z04.D_E_L_E_T_ <> '*') AND (Z04_FILIAL = '"+XFILIAL("Z04")+"') "
cQuery +="AND (Z04_DATA1 BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"') "
cQuery +="AND (Z04_REPRES BETWEEN '"+(MV_PAR03)+"' AND '"+(MV_PAR04)+"') AND (Z04_CLIENT BETWEEN '"+(MV_PAR05)+"' AND '"+(MV_PAR06)+"') "
cQuery +="ORDER BY Z04_REPRES,Z04_CLIENT"

TCQuery cQuery NEW ALIAS "TCQ"

SetRegua(RECCOUNT())

dbselectarea("TCQ")
dbgotop()         
cCabec1 :=TCQ->A3_NOME
cCabec2 := "Amostra  Cliente                                 Cod Amostra       "
Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)

nAmostra:= 0
nTotal:=0
_nLin := 09
cRepres := TCQ->Z04_REPRES

While !eof()   
	while !eof() .AND. (TCQ->Z04_REPRES == cRepres)
		@ _nLin,000 psay  TCQ->Z04_CODIGO
		@ _nLin,009 psay  substr(TCQ->A1_NOME,0,30)
		@ _nLin,042 psay  TCQ->Z04_CLIENT
		@ _nLin,050 psay  TCQ->Z04_CODGER
		_nLin++
		nAmostra++
   		nTotal++
		if _nLin > 55
			@ _nLin,000 psay replicate("_",80)
			Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
			_nLin := 09
		endif
		dbSelectArea("TCQ")
	    dbSkip()
	endDo   
	cRepres := TCQ->Z04_REPRES
	_nLin++
	_nLin++
	if _nLin > 55
		@ _nLin,000 psay replicate("_",80)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
		_nLin := 09
	endif
	@_nLin,040 psay "Quantidade de Amostras: "+transform(nAmostra,"@E 999999")
	_nLin++
	@ _nLin,000 psay replicate("_",80)
	if !eof()	       
		cCabec1 :=TCQ->A3_NOME
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
		_nLin := 09
		nAmostra := 0    
	EndIf	
endDo                                                                                    
_nLin++
@ _nLin,045 psay "Total de Amostras: " + transform(nTotal,"@E 999999")
_nLin++
@ _nLin,000 psay replicate("_",80)
//-------------------------------------------------------------------------
//-------------------------------------------------------------------------
dbselectarea("TCQ")
dbclosearea()

Set Device To Screen
If aReturn[5] == 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnrel)
Endif
Return
/*/
Programa  : CRIASX1   Autor:  MARCELO PAIVA                                        	
Data      : 13/11/13
/*/
/* DESABILITADO RELEASE 12.1.25
Static Function CriaSX1(cPerg)
Local aHelp := {}

//Texto do help em portugues  ,     ingles, espanhol

AAdd(aHelp, {{"Data Inicial"},  {""}, {""}})
AAdd(aHelp, {{"Data Final"},  {""}, {""}})
AAdd(aHelp, {{"De Representante"},  {""}, {""}})
AAdd(aHelp, {{"Ate Representante"},  {""}, {""}})
AAdd(aHelp, {{"De Cliente"},  {""}, {""}})
AAdd(aHelp, {{"Ate Cliente"},  {""}, {""}})

PutSX1(cPerg,"01","de Data" ,"","","mv_ch1","D",8,00,00,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
PutSX1(cPerg,"02","ate Data" ,"","","mv_ch2","D",8,00,00,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")
PutSX1(cPerg,"03","de Representante" ,"","","mv_ch3","C",6,00,00,"G","","SA3","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelp[3,1],aHelp[3,2],aHelp[3,3],"")
PutSX1(cPerg,"04","ate Representante" ,"","","mv_ch4","C",6,00,00,"G","","SA3","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelp[4,1],aHelp[4,2],aHelp[4,3],"")
PutSX1(cPerg,"05","de Cliente" ,"","","mv_ch5","C",6,00,00,"G","","SA1","","","MV_PAR05","","","","","","","","","","","","","","","","",aHelp[5,1],aHelp[5,2],aHelp[5,3],"")
PutSX1(cPerg,"06","ate Cliente" ,"","","mv_ch6","C",6,00,00,"G","","SA1","","","MV_PAR06","","","","","","","","","","","","","","","","",aHelp[6,1],aHelp[6,2],aHelp[6,3],"")

Return
*/
