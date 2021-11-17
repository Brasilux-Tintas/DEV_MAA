#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function BRVENR01()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE CbTxt
PRIVATE Titulo := ""                         	
PRIVATE cDesc1:=""
PRIVATE cDesc2:=""
PRIVATE cDesc3 := "" 
                   //   0          1           2         3         4         5         6       7          8        9        10         11        12       13        14         15         16
                   //012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
PRIVATE cCabec1  := "Pedido     Estoque       Especifico  Dt.Aprovado    Dt.Entregue"
PRIVATE cCabec2  := ""
private nTipo := 18
PRIVATE Tamanho:= "P"
PRIVATE Limite := 80
PRIVATE cString:= "SA1"
private m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:= "BRVENR01"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   := "BRVENR01"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
//CriaSX1(cPerg)  //LGS#20200210 - Adequação de release 12.1.25 e posteriores
Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:= "BRVENR01"            //Nome Default do relatorio em Disco

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
// Funçào....: RPTDETAIL    Data....: 25/04/16         //
// Autor.....: Marcelo J. A. de Paiva                  //
/////////////////////////////////////////////////////////

Static Function RptDetail()
//Local nTotal := 0
//Local _nCont := 0
//Local lNormal
Private _nLin := 7

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery :=""
cQuery +="SELECT C6_NUM, SUM(CASE WHEN B1_ESTOQUE = 'S' THEN 1 ELSE 0 END) as ESTOQUE, "
cQuery +="SUM(CASE WHEN B1_ESTOQUE <> 'S' THEN 1 ELSE 0 END) as ESPECIFICO, C5_SUGENT AS DATAENTREGA,C5_DTAPR AS DTAPROVA,C5_PEDPROG AS PEDIDOPROGRAMADO	 "
cQuery +="FROM "+RetSqlName("SC6")+" SC6 WITH(NOLOCK) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SC5")+"  SC5 WITH(NOLOCK) ON SC5.D_E_L_E_T_ <> '*' AND C5_NUM = C6_NUM AND C5_FILIAL = C6_FILIAL "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON SB1.D_E_L_E_T_ <> '*' AND C6_PRODUTO = B1_COD AND B1_FILIAL = C6_FILIAL "
cQuery +="WHERE SC6.D_E_L_E_T_ <> '*' AND C5_SUGENT BETWEEN ('"+DTOS(MV_PAR01)+"') AND ('"+DTOS(MV_PAR02)+"') AND C6_NOTA = '' AND C6_FILIAL = '"+xFilial("SC6")+"' AND C5_APROVA = '1'"
cQuery +="GROUP BY C6_NUM,SC6.C6_FILIAL,C5_SUGENT,C5_DTAPR,C5_PEDPROG "
cQuery +="ORDER BY C6_NUM DESC"
                                                                            
TCQUERY cQuery ALIAS "TCQ" NEW
dbselectarea("TCQ")
   
Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)                       

If MV_PAR03 == 1
	While !EOF()
		if _nLin > 55                                                                    	
			@ _nLin,000 psay replicate("_",80)
			Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)	  		
			_nLin := 10
		endif
		If ((DTOS(dDatabase) < TCQ->PEDIDOPROGRAMADO) .AND. !Empty(TCQ->PEDIDOPROGRAMADO)) .OR. (DTOS(dDatabase) < TCQ->DATAENTREGA)
			@ _nLin,000 psay TCQ->C6_NUM
			@ _nLin,010 psay TCQ->ESTOQUE
			@ _nLin,025 psay TCQ->ESPECIFICO 
			@ _nLin,037 psay SUBSTR(TCQ->DTAPROVA,7,2)+"/"+SUBSTR(TCQ->DTAPROVA,5,2)+"/"+SUBSTR(TCQ->DTAPROVA,0,4) 
			@ _nLin,052 psay SUBSTR(TCQ->DATAENTREGA,7,2)+"/"+SUBSTR(TCQ->DATAENTREGA,5,2)+"/"+SUBSTR(TCQ->DATAENTREGA,0,4) 
			@ _nLin++
		EndIf 
		dbselectarea("TCQ")	 
		dbskip()
	EndDo   

Else 
While !EOF()
	if _nLin > 55                                                                    	
		@ _nLin,000 psay replicate("_",80)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)	  		
		_nLin := 10
	endif
	@ _nLin,000 psay TCQ->C6_NUM
	@ _nLin,010 psay TCQ->ESTOQUE
	@ _nLin,025 psay TCQ->ESPECIFICO 
	@ _nLin,037 psay SUBSTR(TCQ->DTAPROVA,7,2)+"/"+SUBSTR(TCQ->DTAPROVA,5,2)+"/"+SUBSTR(TCQ->DTAPROVA,0,4) 
	@ _nLin,052 psay SUBSTR(TCQ->DATAENTREGA,7,2)+"/"+SUBSTR(TCQ->DATAENTREGA,5,2)+"/"+SUBSTR(TCQ->DATAENTREGA,0,4) 
	@ _nLin++
	
	dbselectarea("TCQ")	 
	dbskip() 
EndDo   
EndIf

dbSelectArea("TCQ")
dbCloseArea()

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
AAdd(aHelp, {{"Filtrar só pedidos atrasados?" },  {""}, {""}})

//(<cGrupo>,<cOrdem>,<Pergunt>,< cPergSpa>,< cPergEng>,< cVar>,< cTipo>,< nTamanho>,[ nDecimal],[ nPreSel],<cGSC>,[cValid],[cF3],[cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil
PutSX1(cPerg,"01","de Periodo: " ,"","","mv_ch1","D",8,00,00,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
PutSX1(cPerg,"02","ate Periodo: " ,"","","mv_ch2","D",8,00,00,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")
PutSX1(cPerg,"03","filtar Atrasados: " ,"","","mv_ch2","N",1,00,00,"C","","","","","MV_PAR03","Sim","","","","Não","","","","","","","","","","","",aHelp[3,1],aHelp[3,2],aHelp[3,3],"")
Return*/