#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function BRSTRR06()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define Variaveis                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE CbTxt
PRIVATE Titulo := "Relatorio de vendas Vendedor x Faturamento"
PRIVATE cDesc1:=""
PRIVATE cDesc2:=""
PRIVATE cDesc3 := "" 
                   //   0          1           2         3         4         5         6       7          8        9        10         11        12       13        14         15         16
                   //012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
PRIVATE cCabec1  := "                            Relatorio Cliente x Nota xFaturamento x Data"	
PRIVATE cCabec2  := "Codigo    Nome                            Data       Nota   Serie   Valor"  
private nTipo := 18
PRIVATE Tamanho:= "P"
PRIVATE Limite := 80
PRIVATE cString:= "SA1"
private m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:= "BRSTRR06"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   := "BRSTRR06"

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica as perguntas selecionadas                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    
//CriaSX1(cPerg)  //LGS#20200210 - AdequaГЦo de release 12.1.25 e posteriores
Pergunte(cPerg,.F.)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Envia controle para a funcao SETPRINT                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

wnrel:= "BRSTRR06"            //Nome Default do relatorio em Disco

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

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicio do Processamento do Relatorio                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

RptStatus({|| RptDetail()})

return

/////////////////////////////////////////////////////////
// FunГЮo....: RPTDETAIL    Data....: 08/06/15         //
// Autor.....: Marcelo J. A. de Paiva                  //
/////////////////////////////////////////////////////////

Static Function RptDetail()
//Local nTotal := 0
//Local _nCont := 0
//Local lNormal
Private _nLin := 7

//зддддддддддддддддддддддддддддд
//дддддддддддддддддддддддддддддд©
//Ё Inicializa  regua de impressaoЁ
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cQuery :=""
cQuery +="WITH TMP AS (SELECT F2_CLIENT AS CLIENT,A1_NOME AS NOME,F2_DOC,F2_SERIE,D2_EMISSAO AS MES ,SUM(CASE WHEN D2_UM IN ('L','K','KG') THEN D2_QUANT WHEN D2_SEGUM IN ('L','K','KG') THEN D2_QTSEGUM ELSE 0 END) AS VOLUME , "
cQuery +="SUM(D2_VALBRUT) AS FATURAMENTO "
cQuery +="FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = D2_FILIAL) AND (D2_SERIE = F2_SERIE) AND (D2_DOC = F2_DOC) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (D2_TES = F4_CODIGO) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (D2_FILIAL = C5_FILIAL) AND (D2_PEDIDO = C5_NUM) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (F2_CLIENT = A1_COD) "
cQuery +="WHERE (SD2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = '"+xFilial("SD2")+"') AND (D2_TIPO = 'N') AND ((F4_DUPLIC <> 'N') OR (D2_TES = '519')) AND "
cQuery +="(D2_EMISSAO BETWEEN '"+dTos(MV_PAR01)+"' AND '"+dTos(MV_PAR02)+"') AND F2_CLIENT = '"+(MV_PAR03)+"' "
cQuery +="GROUP BY F2_CLIENT, A1_NOME,D2_EMISSAO,F2_DOC,F2_SERIE "
cQuery +="UNION ALL " 
cQuery +="SELECT F2_CLIENT AS CLIENT,A1_NOME as NOME,F2_DOC,F2_SERIE,D1_DTDIGIT AS MES, -1*SUM(CASE WHEN D1_UM IN ('L','K','KG') THEN D1_QUANT WHEN D1_SEGUM IN ('L','K','KG') THEN D1_QTSEGUM ELSE 0 END) AS VOLUME, "
cQuery +="-1*SUM(D1_TOTAL) AS FATURAMENTO "
cQuery +="FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SF1")+" SF1 WITH (NOLOCK) ON (SF1.D_E_L_E_T_ <> '*') AND (D1_FILIAL = F1_FILIAL) AND (D1_FORNECE = F1_FORNECE) AND (D1_SERIE = F1_SERIE) AND (D1_DOC = F1_DOC) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = D1_FILIAL) AND (D1_NFORI = F2_DOC) AND (D1_SERIORI = F2_SERIE) AND (D1_FORNECE = F2_CLIENTE) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (D1_TES = F4_CODIGO) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (F2_VEND1 = A1_COD) "
cQuery +="WHERE (SD1.D_E_L_E_T_ <> '*') AND (D1_FILIAL = '"+xFilial("SD1")+"') AND (D1_TIPO = 'D') AND ((F4_DUPLIC <> 'N') OR (D1_TES = '519')) AND "
cQuery +="(D1_DTDIGIT BETWEEN '"+dTos(MV_PAR01)+"' AND '"+dTos(MV_PAR02)+"') AND F2_CLIENT = '"+(MV_PAR03)+"' "
cQuery +="GROUP BY F2_CLIENT,A1_NOME,D1_DTDIGIT,F2_DOC,F2_SERIE) "
cQuery +="SELECT CLIENT,NOME,SUM(FATURAMENTO) AS FATURAMENTO, SUBSTRING(MES,7,2)+'/'+SUBSTRING(MES,5,2)+'/'+SUBSTRING(MES,1,4) AS MES,F2_DOC,F2_SERIE "
cQuery +="FROM TMP "
cQuery +="GROUP BY CLIENT,NOME,SUBSTRING(MES,7,2)+'/'+SUBSTRING(MES,5,2)+'/'+SUBSTRING(MES,1,4),F2_DOC,F2_SERIE "
cQuery +="ORDER BY CLIENT "
                                                                            
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
	@ _nLin,000 psay TCQ->CLIENT
  	@ _nLin,010 psay SUBSTR(TCQ->NOME,0,30)   
  	@ _nLin,042 psay TCQ->MES
   	@ _nLin,053 psay TCQ->F2_DOC
   	@ _nLin,061 psay TCQ->F2_SERIE
	@ _nLin,063 psay Transform(TCQ->FATURAMENTO,"@E 99,999,999.99")
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

//LGS#20200210 - AdequaГЦo de release 12.1.25 e posteriores
/*Static Function CriaSX1(cPerg)

Local aHelp := {}

//Texto do help em portugues,ingles, espanhol
AAdd(aHelp, {{"de Periodo"  },  {""}, {""}})
AAdd(aHelp, {{"ate Periodo" },  {""}, {""}})
AAdd(aHelp, {{"de Vendedor" },  {""}, {""}})

//(<cGrupo>,<cOrdem>,<Pergunt>,< cPergSpa>,< cPergEng>,< cVar>,< cTipo>,< nTamanho>,[ nDecimal],[ nPreSel],<cGSC>,[cValid],[cF3],[cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil

PutSX1(cPerg,"01","Da emissao    ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"02","Ate a emissao ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"03","Cliente  ?","","","mv_ch3","C",06,0,0,"G","","mv_par03","","","SA1","","","","","","","","","","","","","","","","","","","","","","","")
 
Return*/