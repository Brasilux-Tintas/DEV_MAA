#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function RPEDPROG()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE CbTxt
PRIVATE Titulo := "Relatorio de Pedidos Programados"
PRIVATE cDesc1:=""
PRIVATE cDesc2:=""
PRIVATE cDesc3 := "" 
                   //   0          1           2         3         4         5         6       7          8        9        10         11        12       13        14         15         16
                   //012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
PRIVATE cCabec1  := "                            Pedidos Programados"
PRIVATE cCabec2  := "Pedido  Aprovado    Programado  Vendedor                         Valor"  
private nTipo := 18
PRIVATE Tamanho:= "P"
PRIVATE Limite := 80
PRIVATE cString:= "SA1"
private m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:= "RPEDPROG"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   := "RPEDPROG"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
//CriaSX1(cPerg)  //LGS#20200210 - Adequação de release 12.1.25 e posteriores
Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:= "RPEDPROG"            //Nome Default do relatorio em Disco

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
// Funçào....: RPTDETAIL    Data....: 08/06/15         //
// Autor.....: Marcelo J. A. de Paiva                  //
/////////////////////////////////////////////////////////

Static Function RptDetail()
//Local nTotal := 0
//Local 	_nCont := 0
//Local lNormal
Private _nLin := 7

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cQuery :="SELECT C6_NUM AS PEDIDO, C5_DTAPR AS APROVADO, C5_PEDPROG AS PROGRAMADO, A3_NOME AS VENDEDOR, SUM(C6_VALOR) AS VALOR "
cQuery +="FROM "+RetSqlName("SC6")+" SC6 (NOLOCK) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 (NOLOCK) ON SC5.D_E_L_E_T_ <> '*' AND C5_NUM = C6_NUM AND (C5_FILIAL = '"+xFilial("SC5")+"') "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 (NOLOCK) ON SF4.D_E_L_E_T_ <> '*' AND F4_CODIGO = C6_TES AND (F4_FILIAL = '"+xFilial("SF4")+"') "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SA3")+" SA3 (NOLOCK) ON SA3.D_E_L_E_T_ <> '*' AND A3_COD = C5_VEND1 AND (A3_FILIAL = '"+xFilial("SA3")+"') " 
cQuery +="WHERE C5_PEDPROG <> '' AND SC6.D_E_L_E_T_ <> '*' AND (C6_FILIAL = '"+xFilial("SC6")+"') AND C6_NOTA = ''  AND C5_APROVA = '1' AND F4_ESTOQUE = 'S' AND (C5_PEDPROG BETWEEN ('"+dTos(MV_PAR01)+"') AND ('"+dTos(MV_PAR02)+"'))"
cQuery +="GROUP BY C6_NUM, C5_DTAPR,C5_PEDPROG,A3_NOME "
cQuery +="ORDER BY C6_NUM "

TCQUERY cQuery ALIAS "TCQ" NEW
dbselectarea("TCQ")

SetRegua(RECCOUNT( )) 
Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
_nLin := 9
cAuxVal := 0
While !Eof()
	if _nLin > 55
		@ _nLin,000 psay replicate("_",80)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
		_nLin := 9
	endif
	@ _nLin,000 psay TCQ->PEDIDO
  	@ _nLin,008 psay substr(TCQ->APROVADO,7,2)+"/"+substr(TCQ->APROVADO,5,2)+"/"+substr(TCQ->APROVADO,0,4)
	@ _nLin,020 psay substr(TCQ->PROGRAMADO,7,2)+"/"+substr(TCQ->PROGRAMADO,5,2)+"/"+substr(TCQ->PROGRAMADO,0,4)
	@ _nLin,032 psay SUBSTR(TCQ->VENDEDOR,0,30)
	@ _nLin,065 psay Transform(TCQ->VALOR,"@E 99,999,999.99")
	cAuxVal += TCQ->VALOR
	@ _nLin++
	dbselectarea("TCQ")	 
	dbskip() 
EndDo
if _nLin > 55                                                                    	
	@ _nLin,000 psay replicate("_",80)
	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
	_nLin := 9  
endif 
	@ _nLin,000 psay replicate("_",80) 
	@ _nLin++
	@ _nLin,060 psay Transform(cAuxVal,"@E 999,999,999,999.99")
	dbSelectArea("TCQ")
    dbCloseArea( )
Set Device To Screen
If aReturn[5] == 1             	
   Set Printer TO
   dbcommitAll()
   ourspool(wnrel)
Endif
Return

//LGS#20200210 - Adequação de release 12.1.25 e posteriores
/*
Static Function CriaSX1(cPerg)

Local aHelp := {}

//Texto do help em portugues,ingles, espanhol
AAdd(aHelp, {{"de Periodo"  },  {""}, {""}})
AAdd(aHelp, {{"ate Periodo" },  {""}, {""}})

//(<cGrupo>,<cOrdem>,<Pergunt>,< cPergSpa>,< cPergEng>,< cVar>,< cTipo>,< nTamanho>,[ nDecimal],[ nPreSel],<cGSC>,[cValid],[cF3],[cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil
PutSX1(cPerg,"01","de Periodo: " ,"","","mv_ch1","D",8,00,00,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
PutSX1(cPerg,"02","ate Periodo: " ,"","","mv_ch2","D",8,00,00,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")

Return*/