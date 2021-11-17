#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function BRFATR89()
PRIVATE MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06,MV_PAR07,MV_PAR08
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE CbTxt
PRIVATE Titulo := "Relatorio de Segmento Repres x Valor Faturado"
PRIVATE cDesc1:=""
PRIVATE cDesc2:=""
PRIVATE cDesc3 := ""                                                                    
                   //   0          1           2         3         4         5         6       7          8        9        10         11        12       13        14         15         16
                   //012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
PRIVATE cCabec1  := "Código  Razão                                          Industria            Mat.Construc.        Revenda             Total"
PRIVATE cCabec2  := ""  
private nTipo := 18
PRIVATE Tamanho:= "G"
PRIVATE Limite := 220
PRIVATE cString:= "SA1"
private m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:= "BRFATR89"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   := "BRFATR89"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
//CriaSX1(cPerg)  //LGS#20200210 - Adequação de release 12.1.25 e posteriores
Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:= "BRFATR89"            //Nome Default do relatorio em Disco

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
Local nPos,cAux,_nCol
Local aTotais := {}
Private _nLin := 7

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//cCabec1  := "Código  Razão                                          Industria            Mat.Construc.        Revenda             Total"
cQuery := "SELECT X5_CHAVE AS COD,SUBSTRING(X5_DESCRI,1,17) AS DESCR  FROM SX5010 WHERE (D_E_L_E_T_ <> '*') AND (X5_TABELA = 'T3') ORDER BY COD"
TCQUERY cQuery NEW ALIAS "TMPCAB" 
cCabec1 := "Código  Razão"+space(25)
dbselectarea("TMPCAB")
dbgotop()
_nCol := 0
nPos := 39 - 18
do while !eof()
	_nCol++
	nPos += 18
	aadd(aTotais,0)
	cCabec1 += SPACE(18-LEN(ALLTRIM(TMPCAB->DESCR)))+ALLTRIM(TMPCAB->DESCR)
	dbskip()
enddo 

cQuery :="WITH TMP AS (SELECT F2_VEND1,A1_SATIV2,SUM(D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END)) AS F2_VALMERC "
cQuery +="FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = '"+xFilial("SF2")+"') AND (D2_SERIE = F2_SERIE) AND (D2_DOC = F2_DOC) AND (D2_CLIENTE = F2_CLIENTE) AND (D2_PEDIDO = F2_PEDIDO) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (D2_CLIENTE = A1_COD) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (D2_TES = F4_CODIGO) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = '"+xFilial("SC5")+"') AND (D2_PEDIDO = C5_NUM) "
cQuery +="WHERE (SD2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = '"+xFilial("SD2")+"') AND (D2_TIPO = 'N') AND ((F4_DUPLIC <> 'N') OR (D2_TES = '519')) "
cQuery +="AND (D2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"') "
cQuery +="AND (F2_VEND1 BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"') "
IF !empty(alltrim(MV_PAR05))
	cQuery +="AND ((A1_SATIV2 = '') OR ("+U_ParamSql("A1_SATIV2",MV_PAR05)+")) "
ENDIF
if !empty(MV_PAR06)   
	cAux := U_RegiaoGeo(MV_PAR06)
	if !empty(cAux)
		cQuery += "AND (D2_EST IN ("+cAux+")) "
	endif 
endif
if !empty(MV_PAR07)
	cQuery += "AND ("+U_ParamSql("A1_EST",MV_PAR07)+") "
endif
cQuery += "GROUP BY F2_VEND1,A1_SATIV2 "
cQuery += "UNION ALL "
cQuery +="SELECT F2_VEND1,A1_SATIV2,SUM(-1.0*D1_TOTAL) AS F2_VALMERC "+;
"FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK) "+;
"LEFT OUTER JOIN "+RetSqlName("SF1")+" SF1 WITH (NOLOCK) ON (SF1.D_E_L_E_T_ <> '*') AND (F1_FILIAL = D1_FILIAL) AND (F1_DOC = D1_DOC) AND (F1_SERIE = D1_SERIE) AND (F1_FORNECE = D1_FORNECE) AND (F1_TIPO = D1_TIPO) "+;
"LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = D1_FILIAL) AND (F2_SERIE = D1_SERIORI) AND (F2_DOC = D1_NFORI) "+;
"LEFT OUTER JOIN "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) ON (SD2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = D1_FILIAL) AND (D2_SERIE =  D1_SERIORI) AND (D2_DOC = D1_NFORI) AND (D2_ITEM = D1_ITEMORI) AND (D2_CLIENTE = D1_FORNECE) AND (D2_LOJA = D1_LOJA) "+;
"LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (D1_TES = F4_CODIGO) "+;
"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (A1_COD = D1_FORNECE) "+;
"WHERE (SD1.D_E_L_E_T_ <> '*') AND (D1_FILIAL = '"+xFilial("SD1")+"') AND (D1_TIPO = 'D') AND (D1_NFORI > '') AND (F4_DUPLIC <> 'N') "
cQuery +="AND (D1_DTDIGIT BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"') "
cQuery +="AND (F2_VEND1 BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"') "
IF !empty(alltrim(MV_PAR05))
	cQuery +="AND ((A1_SATIV2 = '') OR ("+U_ParamSql("A1_SATIV2",MV_PAR05)+")) "
ENDIF
if !empty(MV_PAR06)   
	cAux := U_RegiaoGeo(MV_PAR06)
	if !empty(cAux)
		cQuery += "AND (A1_EST IN ("+cAux+")) "
	endif 
endif
if !empty(MV_PAR07)
	cQuery += "AND ("+U_ParamSql("A1_EST",MV_PAR07)+") "
endif
cQuery += "GROUP BY F2_VEND1,A1_SATIV2) "
cQuery += "SELECT F2_VEND1,MAX(A3_NOME) AS A3_NOME,A1_SATIV2,SUM(F2_VALMERC) AS F2_VALMERC "+;
"FROM TMP "+;
"LEFT OUTER JOIN "+RetSqlName("SA3")+" SA3 WITH (NOLOCK) ON (SA3.D_E_L_E_T_ <> '*') AND (A3_FILIAL = '"+xFilial("SA3")+"') AND (A3_COD = F2_VEND1) "
cQuery +="GROUP BY F2_VEND1,A1_SATIV2 "
cQuery +="ORDER BY F2_VEND1,A1_SATIV2 "

TCQUERY cQuery NEW ALIAS "TCQ" 
dbselectarea("TCQ")
dbgotop()

SetRegua(RECCOUNT( )) 
Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
_nLin := 08                                                                                             
contTotal := 0
dbselectarea("TCQ")
dbgotop()                                                                                  
cUfTotal := cMCTotal := cTotal := 0
While !eof()
    if _nLin > 55                                                                    	
		@ _nLin,000 psay replicate("_",220)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
		_nLin := 09
	endif 
	codVendedor := TCQ->F2_VEND1
	valorTotal := 0  
	@_nLin,000 psay TCQ->F2_VEND1
	@_nLin,008 psay SUBSTR(TCQ->A3_NOME,0,30)

	While !eof() .and. (TCQ->F2_VEND1 == codVendedor) 
		nPos := 39 - 18
		dbselectarea("TMPCAB")
		dbgotop()
		_nCol := 0
		do while !eof()
			_nCol++ 
			nPos += 18
			IF ALLTRIM(TCQ->A1_SATIV2) == alltrim(TMPCAB->COD)
				aTotais[_nCol] += TCQ->F2_VALMERC
				exit 
			ENDIF 
			dbselectarea("TMPCAB")
			dbskip()
		enddo 
		dbselectarea("TCQ")
		@_nLin,nPos psay TRANSFORM(TCQ->F2_VALMERC,"@E 99,999,999,999.99")  
		valorTotal += TCQ->F2_VALMERC
		dbSelectArea("TCQ")
    	dbSkip()	
	EndDo	
	@_nLin,202 psay TRANSFORM(valorTotal,"@E 99,999,999,999.99")		
	contTotal += valorTotal
	@_nLin++	
EndDo	                                                    	
                                                                    	
@ _nLin,000 psay replicate("_",220) 
@_nLin++
		dbselectarea("TMPCAB")
		dbgotop()
		_nCol := 0
		nPos := 39-18
		do while !eof()
			_nCol++ 
			nPos += 18
			@ _nLin,nPos psay TRANSFORM(aTotais[_nCol],"@E 99,999,999,999.99")
			dbselectarea("TMPCAB")
			dbskip()
		enddo 
/*
@ _nLin,055 psay TRANSFORM(cUfTotal,"@E 999,999,999.99")
@ _nLin,075 psay TRANSFORM(cMCTotal,"@E 999,999,999.99")
@ _nLin,095 psay TRANSFORM(cTotal,"@E 999,999,999.99")
*/
@ _nLin,203 psay TRANSFORM(contTotal,"@E 9,999,999,999.99")

dbSelectArea("TCQ")
dbCloseArea( )
dbselectarea("TMPCAB")
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

//Texto do help em portugues  ,     ingles, espanhol
AAdd(aHelp, {{"De data"},  {""}, {""}})
AAdd(aHelp, {{"até data"},  {""}, {""}})	
AAdd(aHelp, {{"do Representante"},  {""}, {""}})
AAdd(aHelp, {{"até o Representante"},  {""}, {""}})
AAdd(aHelp, {{"segmentos"},  {""}, {""}})
//(<cGrupo>,<cOrdem>,<Pergunt>,< cPergSpa>,< cPergEng>,< cVar>,< cTipo>,< nTamanho>,[ nDecimal],[ nPreSel],<cGSC>,[ cValid], [ cF3], [ cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil
PutSX1(cPerg,"01","de Periodo: " ,"","","mv_ch1","D",8,00,00,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")
PutSX1(cPerg,"02","ate Periodo: " ,"","","mv_ch2","D",8,00,00,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp[3,1],aHelp[3,2],aHelp[3,3],"")
PutSX1(cPerg,"03","Do Representante   ", "Do Representante   ", "Do Representante   ", "mv_ch3", "C",  6, 0, 0, "G", " ", "SA3", " ", " ", "mv_par03", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
PutSX1(cPerg,"04","Até o Representante", "Até o Representante", "Até o Representante", "mv_ch4", "C",  6, 0, 0, "G", " ", "SA3", " ", " ", "mv_par04", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
PutSX1(cPerg,"05","Segmento(s)        ", "Segmento(s)        ", "Segmento(s)        ", "mv_ch5", "C", 99,00,00, "G",  "", "T3",  "",  "", "mv_Par05","","","","","","","","","","","","","","","","",Nil  , Nil     , Nil,cPerg)
PutSx1(cPerg,"06","Região Geográf?","Região Geográf?","Região Geográf?","mv_ch6","C",2,0,0,"G","","ZE","","","mv_par06","","","","","","","","","","","","",Nil  , Nil     , Nil,cPerg)
PutSX1(cPerg,"07","Estado(s)          ", "Estado(s)          ", "Estado(s)          ", "mv_ch7", "C", 99,00,00, "G",  "", "",  "",  "", "mv_Par07","","","","","","","","","","","","","","","","",Nil  , Nil     , Nil ,cPerg)
Return*/
