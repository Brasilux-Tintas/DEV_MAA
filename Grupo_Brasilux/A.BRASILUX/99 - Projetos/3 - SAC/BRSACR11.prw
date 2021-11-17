#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function BRSACR11()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE CbTxt
PRIVATE Titulo := "Relatorio de SAC x Lote"
PRIVATE cDesc1 := "Relatorio informa sacs existentes sob o lote"
PRIVATE cDesc2 := ""
PRIVATE cDesc3 := "" 
                   //   0          1           2         3         4         5         6       7
                   //01234567890123456789012345678901234567890123456789012345678901234567890123456789
PRIVATE cCabec1  := "NUM. SAC       Produto       QTDE  PEDIDO   NOTA F    LOTE"
PRIVATE cCabec2  := ""
private nTipo := 18
PRIVATE Tamanho:= "P"
PRIVATE Limite := 80
PRIVATE cString:= "SZR"
private m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:="BRSACR11"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   :="BRSACR11"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
//CriaSX1(cPerg)  //LGS#20200211 - Adequação de release 12.1.25 e posteriores
Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:="BRSACR11"            //Nome Default do relatorio em Disco

wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)
//wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,,.T.,Tamanho)

If nLastKey==27
	dbClearFilter()
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey==27
	dbClearFilter()
   Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio do Processamento do Relatorio                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RptStatus({|| RptDetail()})

return

/////////////////////////////////////////////////////////
// Funçào....: RPTDETAIL    Data....: 30/03/15         //
// Autor.....: Marcelo J. A. de Paiva                  //
/////////////////////////////////////////////////////////

Static Function RptDetail()
//Local nTotal := 0
//Local 	_nCont := 0
//Local lNormal
Private _nLin := 7

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cQuery :="SELECT SZR.ZR_NUM, SZR.ZR_PRODUTO, SZR.ZR_QTD, SZR.ZR_PEDIDO, SZR.ZR_NUMNF, SZR.ZR_LOTE "
cQuery +="FROM "+RetSqlName("SZR")+" SZR WITH (NOLOCK) "
cQuery +="WHERE (SZR.ZR_FILIAL='"+xFilial("SZR")+"') AND (SZR.D_E_L_E_T_='') AND (SZR.ZR_LOTE= '"+MV_PAR01+"')"

TCQuery cQuery NEW ALIAS "TCQ"

SetRegua(RECCOUNT())
Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)

dbselectarea("TCQ")
dbgotop()         
                                            
_nLin := 07
LimLinha := 55
While !eof()
	if _nLin > LimLinha
		@ _nLin,000 psay replicate("_",80)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
		_nLin := 07
	endif                              
 	_nLin++    
	@_nLin,000 psay TCQ->ZR_NUM
	@_nLin,015 psay TCQ->ZR_PRODUTO
	@_nLin,030 psay TCQ->ZR_QTD
	@_nLin,035 psay TCQ->ZR_PEDIDO
	@_nLin,045 psay TCQ->ZR_NUMNF
	@_nLin,055 psay TCQ->ZR_LOTE
		
	dbSelectArea("TCQ")
	dbSkip() 
endDo 
  _nLin++                  
@ _nLin,000 psay replicate("_",80)
	   
dbselectarea("TCQ")
dbclosearea()

Set Device To Screen
If aReturn[5] == 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnrel)
Endif
Return

//LGS#20200211 - Adequação de release 12.1.25 e posteriores
/*Static Function CriaSX1(cPerg)

Local aHelp := {}

//Texto do help em portugues  ,     ingles, espanhol

AAdd(aHelp, {{"Numero do lote"},  {""}, {""}})

PutSX1(cPerg,"01","Lote: " ,"","","mv_ch1","C",6,00,00,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
Return*/