#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function BRSTRR05()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE CbTxt
PRIVATE Titulo := "Relatorio de vendas Vendedor x Faturamento"
PRIVATE cDesc1:=""
PRIVATE cDesc2:=""
PRIVATE cDesc3 := "" 
                   //   0          1           2         3         4         5         6       7          8        9        10         11        12       13        14         15         16
                   //012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
PRIVATE cCabec1  := "                            Relatorio Vendedor x Faturamento"	
PRIVATE cCabec2  := "Codigo    Nome                                              Data      Faturamento"  
private nTipo := 18
PRIVATE Tamanho:= "P"
PRIVATE Limite := 80
PRIVATE cString:= "SA1"
private m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:= "BRSTRR05"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   := "BRSTRR05"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
//CriaSX1(cPerg)  //LGS#20200210 - Adequação de release 12.1.25 e posteriores
Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:= "BRSTRR05"            //Nome Default do relatorio em Disco

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
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery :=""
cQuery +="WITH TMP AS (SELECT F2_VEND1 AS VEND,A3_NOME AS NOME,SUBSTRING(D2_EMISSAO,1,6) AS MES ,SUM(CASE WHEN D2_UM IN ('L','K','KG') THEN D2_QUANT WHEN D2_SEGUM IN ('L','K','KG') THEN D2_QTSEGUM ELSE 0 END) AS VOLUME , "
cQuery +="SUM(D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END)) AS FATURAMENTO "
cQuery +="FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) " 
cQuery +="LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = D2_FILIAL) AND (D2_SERIE = F2_SERIE) AND (D2_DOC = F2_DOC) " 
cQuery +="LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (D2_TES = F4_CODIGO) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (D2_FILIAL = C5_FILIAL) AND (D2_PEDIDO = C5_NUM) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SA3")+" SA3 WITH (NOLOCK) ON (SA3.D_E_L_E_T_ <> '*') AND (A3_FILIAL = '"+xFilial("SA3")+"') AND (F2_VEND1 = A3_COD) "
cQuery +="WHERE (SF2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = '"+xFilial("SD2")+"') AND (D2_TIPO = 'N') AND ((F4_DUPLIC <> 'N') OR (D2_TES = '519')) AND "
cQuery +="(D2_EMISSAO BETWEEN ('"+dTos(MV_PAR01)+"') AND ('"+dTos(MV_PAR02)+"')  AND F2_VEND1 = '"+(MV_PAR03)+"') "
cQuery +="GROUP BY F2_VEND1, A3_NOME,D2_EMISSAO "
cQuery +="UNION ALL " 
cQuery +="SELECT F2_VEND1 AS VEND,A3_NOME as NOME,SUBSTRING(D1_DTDIGIT,1,6) AS MES, -1*SUM(CASE WHEN D1_UM IN ('L','K','KG') THEN D1_QUANT WHEN D1_SEGUM IN ('L','K','KG') THEN D1_QTSEGUM ELSE 0 END) AS VOLUME, "
cQuery +="-1*SUM(D1_TOTAL) AS FATURAMENTO "
cQuery +="FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK) " 
cQuery +="LEFT OUTER JOIN "+RetSqlName("SF1")+" SF1 WITH (NOLOCK) ON (SF1.D_E_L_E_T_ <> '*') AND (D1_FILIAL = F1_FILIAL) AND (D1_FORNECE = F1_FORNECE) AND (D1_SERIE = F1_SERIE) AND (D1_DOC = F1_DOC) " 
cQuery +="LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = D1_FILIAL) AND (D1_NFORI = F2_DOC) AND (D1_SERIORI = F2_SERIE) AND (D1_FORNECE = F2_CLIENTE) " 
cQuery +="LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (D1_TES = F4_CODIGO) " 
cQuery +="LEFT OUTER JOIN "+RetSqlName("SA3")+" SA3 WITH (NOLOCK) ON (SA3.D_E_L_E_T_ <> '*') AND (A3_FILIAL = '"+xFilial("SA3")+"') AND (F2_VEND1 = A3_COD) "
cQuery +="WHERE (SD1.D_E_L_E_T_ <> '*') AND (D1_FILIAL = '"+xFilial("SD1")+"') AND (D1_TIPO = 'D') AND ((F4_DUPLIC <> 'N') OR (D1_TES = '519')) AND " 
cQuery +="(D1_DTDIGIT BETWEEN ('"+dTos(MV_PAR01)+"') AND ('"+dTos(MV_PAR02)+"')  AND F2_VEND1 = '"+(MV_PAR03)+"') " 
cQuery +="GROUP BY F2_VEND1,A3_NOME,D1_DTDIGIT) " 
cQuery +="SELECT VEND,NOME,SUM(VOLUME) AS VOLUME,SUM(FATURAMENTO) AS FATURAMENTO, SUBSTRING(MES,1,6) " 
cQuery +="FROM TMP "
cQuery +="GROUP BY VEND,NOME,SUBSTRING(MES,1,6) "
cQuery +="ORDER BY VEND "
                                                                            
TCQUERY cQuery ALIAS "TCQ" NEW
dbselectarea("TCQ")

SetRegua(RECCOUNT( )) 
Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
_nLin := 10
cAuxVol := 0
While !Eof()
	if _nLin > 55
		@ _nLin,000 psay replicate("_",80)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
		_nLin := 10
	endif
	@ _nLin,000 psay TCQ->VEND
  	@ _nLin,010 psay Transform(TCQ->VOLUME,"@E 999999.99")
	@ _nLin,067 psay Transform(TCQ->FATURAMENTO,"@E 99,999,999.99")
	cAuxVol += TCQ->FATURAMENTO
	@ _nLin++
	dbselectarea("TCQ")	 
	dbskip() 
EndDo
if _nLin > 55                                                                    	
	@ _nLin,000 psay replicate("_",80)
	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
	_nLin := 10  
endif 
	@ _nLin,000 psay replicate("_",80) 
	@ _nLin++
	@ _nLin,060 psay Transform(cAuxVol,"@E 999,999,999,999.99")
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
/*Static Function CriaSX1(cPerg)

Local aHelp := {}

//Texto do help em portugues,ingles, espanhol
AAdd(aHelp, {{"de Periodo"  },  {""}, {""}})
AAdd(aHelp, {{"ate Periodo" },  {""}, {""}})
AAdd(aHelp, {{"de Vendedor" },  {""}, {""}})
AAdd(aHelp, {{"ate Vendedor"},  {""}, {""}})
AAdd(aHelp, {{"ate Vendedor"},  {""}, {""}})

PutSX1(cPerg,"01","De periodo    ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"02","Ate periodo   ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"03","Cod Vendedor  ?","","","mv_ch3","C",06,0,0,"G","","mv_par03","","","SA3","","","","","","","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"04","Cod Vendedor  ?","","","mv_ch4","C",06,0,0,"G","","mv_par04","","","SA3","","","","","","","","","","","","","","","","","","","","","","","")
 
Return*/