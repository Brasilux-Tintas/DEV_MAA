#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function BRMPAR01()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE CbTxt
PRIVATE Titulo :=""
PRIVATE cDesc1:=""
PRIVATE cDesc2:=""
PRIVATE cDesc3 :="" 
                   //   0          1           2         3         4         5         6       7          8        9        10         11        12       13        14         15         16
                   //012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
PRIVATE cCabec1  := ""
PRIVATE cCabec2  := ""  
private nTipo := 18
PRIVATE Tamanho:= "P"
PRIVATE Limite := 80
PRIVATE cString:= "SA1"
private m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:= "BRMPAR01"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   := "BRMPAR01"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
//CriaSX1(cPerg)  //LGS#20200210 - Adequação de release 12.1.25 e posteriores
Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:= "BRMPAR01"            //Nome Default do relatorio em Disco

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
//Local _nCont := 0
//Local lNormal
Private _nLin := 7

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery :=" SELECT ZZJ_CODIGO AS PALLET, SUM(ZZK_QUANT) AS QUANTIDADE, ROUND(SUM(ZZK_QUANT * B1_PESBRU),2) AS PESO, COUNT(ZZK.R_E_C_N_O_) AS VOLUME "
cQuery +=" FROM "+RetSqlName("ZZJ")+" ZZJ WITH (NOLOCK) "
cQuery +=" LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) ON (ZZK.D_E_L_E_T_ <> '*') AND (ZZK_CODIGO = ZZJ_CODIGO) AND (ZZK_FILIAL = ZZJ_FILIAL) "
cQuery +=" LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_COD = ZZK_PRODUT) AND (B1_FILIAL = ZZJ_FILIAL) "
cQuery +=" LEFT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH (NOLOCK) ON (SZG.D_E_L_E_T_ <> '*') AND (ZG_FILIAL = ZZK_FILIAL) AND (SUBSTRING(ZG_PEDIDO,3,6) = ZZK_PEDIDO) "
cQuery +=" WHERE  (ZZJ_FILIAL = '"+xFilial("ZZJ")+"') "
cQuery +=" AND (ZG_CODIGO = ('"+(MV_PAR01)+"')) "
cQuery +=" AND (ZZJ.D_E_L_E_T_ <> '*') 
cQuery +=" AND (ZZK_FILIAL = '"+xFilial("ZZK")+"') "
cQuery +=" GROUP BY ZZJ_CODIGO "
If MV_PAR02 = 1 
	cQuery +=" ORDER BY PALLET"
Else                           
	cQuery +=" ORDER BY PESO"
EndIf
TCQUERY cQuery ALIAS "TCQ" NEW
dbselectarea("TCQ")

Titulo := "Relatorio de Bordero       "+ MV_PAR01
cCabec1 :="Pallet               Quantidade     Volume        Peso"

SetRegua(RECCOUNT()) 
Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)                       
_nLin := 08  
cTotalCount := cTotalPallet := cTotalVol := cTPeso := cFlag:= 0                                                                                         
While !Eof()
	if _nLin > 55                                                                    	
		@ _nLin,000 psay replicate("_",80)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
		_nLin := 08
	endif 
	if !Eof() .AND. cFlag = 1
		@ _nLin,000 psay replicate("-",80)
		@ _nLin++
	endIf 

	@_nLin,000 PSAY TCQ->PALLET
	@_nLin,021 PSAY Transform(TCQ->QUANTIDADE,"@E 999999")
	@_nLin,036 PSAY Transform(TCQ->VOLUME,"@E 999999")
	@_nLin,050 PSAY Transform(TCQ->PESO,"@E 999,999.99")
	@ _nLin++		
	
	cTotalCount  += TCQ->QUANTIDADE
	cTotalPallet += 1 
	cTotalVol	 += TCQ->VOLUME
	cTPeso       += TCQ->PESO
	If _nLin > 55
		cFlag := 0
	Else
		cFlag := 1
	EndIf
	dbselectarea("TCQ")	 
	dbskip()
  
EndDo        
  	if _nLin > 55                                                                    	
		@ _nLin,000 psay replicate("_",80)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
		_nLin := 08
	endif
	@ _nLin,000 psay replicate("_",80)
	@ _nLin++		
	@_nLin,000 PSAY "Total Quantidade:"
   	@_nLin,020 PSAY Transform(cTotalCount,"@E 999999")
   	@ _nLin++
	@_nLin,000 PSAY "Numero de Pallets:"
	@_nLin,020 PSAY Transform(cTotalPallet,"@E 999999")
	@ _nLin++
	@_nLin,000 PSAY "Total Volume:"
	@_nLin,020 PSAY Transform(cTotalVol,"@E 999999")    
	@ _nLin++
	@_nLin,000 PSAY "Total Peso:"
	@_nLin,020 PSAY Transform(cTPeso,"@E 999,999.99")    
	
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
/*Static Function CriaSX1(cPerg)	

Local aHelp := {}

//Texto do help em portugues  ,     ingles, espanhol
AAdd(aHelp, {{"Bordero de Pedidos"},  {""}, {""}})
AAdd(aHelp, {{"Ordenar"},  {""}, {""}})

//(<cGrupo>,<cOrdem>,<Pergunt>,< cPergSpa>,< cPergEng>,< cVar>,< cTipo>,< nTamanho>,[ nDecimal],[ nPreSel],<cGSC>,[ cValid], [ cF3], [ cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil
PutSX1(cPerg,"01","Bordero " ,"","","mv_ch1","C",6,00,00,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
PutSX1(cPerg,"02","Ordernar por: " ,"","","mv_ch2","N",1,00,00,"C","","","","","MV_PAR02","PALLET","","","","PESO","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")

Return*/