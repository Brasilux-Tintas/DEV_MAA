#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function BRFATR73()
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define Variaveis                                             ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE CbTxt
PRIVATE Titulo := "Fat por Regiao ICMS"
PRIVATE cDesc1 := "Este relatorio ira emitir o Faturamento "
PRIVATE cDesc2 := "por Região de ICMS"
PRIVATE cDesc3 := "" 
                   //   0          1           2         3         4         5         6       7
                   //01234567890123456789012345678901234567890123456789012345678901234567890123456789
PRIVATE cCabec1  := "Cliente    Razao                               Estado ICM  MES    Valor     QTDE"
PRIVATE cCabec2  := ""
private nTipo := 18
PRIVATE Tamanho:= "P"
PRIVATE Limite := 80
PRIVATE cString:= "SA1"
private m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:="BRFATR73"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   :="BRFATR73"

     
      if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//CriaSX1(cPerg)
Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:="BRFATR73"            //Nome Default do relatorio em Disco

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
// Funçào....: RPTDETAIL    Data....: 03/10/13         //
// Autor.....: Marcelo J. A. de Paiva                  //
/////////////////////////////////////////////////////////

Static Function RptDetail()
Local nTotal  := 0
//Local _nCont  := 0
//Local lNormal
Local cQuery  :=""
Private _nLin := 7

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cQuery :="WITH TMP AS (SELECT D2_CLIENTE AS CLIENTE,D2_EST AS UF,SUBSTRING(D2_EMISSAO,1,6) AS MES,"
cQuery +="SUM(D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END)) AS VLRMES,"
cQuery +="MAX(CASE WHEN D2_EST IN ('AC','AL','AM','AP','BA','CE','DF','ES','GO','MA','MS','MT','PA','PB',"
cQuery +="'PE','PI','RN','RO','RR','SE','TO') THEN 'ICM07' "
cQuery +="WHEN D2_EST IN ('MG','PR','RJ','RS','SC') THEN 'ICM12' "
cQuery +="WHEN D2_EST = 'SP' THEN 'ICM18' "
cQuery +="ELSE 'ICMEX' END) AS REGICM "
cQuery +="FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (D2_TES = F4_CODIGO) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (D2_FILIAL = C5_FILIAL) AND (D2_PEDIDO = C5_NUM) "
cQuery +="WHERE (SD2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = '"+XFILIAL("SD2")+"') AND ((F4_DUPLIC = 'S') OR (D2_TES = '519')) AND "
cQuery +="(D2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"') "
cQuery +="GROUP BY D2_CLIENTE,SUBSTRING(D2_EMISSAO,1,6),D2_EST "
cQuery +="UNION ALL "
cQuery +="SELECT D1_FORNECE AS CLIENTE,A1_EST AS UF,SUBSTRING(D1_DTDIGIT,1,6) AS MES,"
cQuery +="SUM(D1_TOTAL*-1) AS VLRMES,"
cQuery +="MAX(CASE WHEN A1_EST IN ('AC','AL','AM','AP','BA','CE','DF','ES','GO','MA','MS','MT','PA','PB', "
cQuery +="'PE','PI','RN','RO','RR','SE','TO') THEN 'ICM07' "
cQuery +="WHEN A1_EST IN ('MG','PR','RJ','RS','SC') THEN 'ICM12' "
cQuery +="WHEN A1_EST = 'SP' THEN 'ICM18' "
cQuery +="ELSE 'ICMEX' END) AS REGICM "
cQuery +="FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (D1_TES = F4_CODIGO) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (D1_FORNECE = A1_COD) "
cQuery +="WHERE (SD1.D_E_L_E_T_ <> '*') AND (D1_FILIAL = '"+XFILIAL("SD1")+"') AND (D1_TIPO = 'D') AND (F4_DUPLIC = 'S') AND "
cQuery +="(D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"') "
cQuery +="GROUP BY D1_FORNECE,SUBSTRING(D1_DTDIGIT,1,6),A1_EST), "
cQuery +="TMP1 AS ( "
cQuery +="SELECT D2_CLIENTE AS CLIENTE,SUM(D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END)) AS VALOR "
cQuery +="FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (D2_TES = F4_CODIGO) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (D2_FILIAL = C5_FILIAL) AND (D2_PEDIDO = C5_NUM) "
cQuery +="WHERE (SD2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = '"+xFilial("SD2")+"') AND ((F4_DUPLIC = 'S') OR (D2_TES = '519')) AND "
cQuery +="(D2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"') "
cQuery +="GROUP BY D2_CLIENTE "
cQuery +="UNION ALL "
cQuery +="SELECT D1_FORNECE AS CLIENTE,SUM(D1_TOTAL*-1) AS VALOR "
cQuery +="FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (D1_TES = F4_CODIGO) "
cQuery +="WHERE (SD1.D_E_L_E_T_ <> '*') AND (D1_FILIAL = '"+xFilial("SD1")+"') AND (D1_TIPO = 'D') AND (F4_DUPLIC = 'S') AND "
cQuery +="(D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"') " 
cQuery +="GROUP BY D1_FORNECE), "
cQuery +="TMP2 AS ( "
cQuery +="SELECT DISTINCT D2_CLIENTE AS CLIENTE,SUBSTRING(F2_EMISSAO,1,6) AS MES,SF2.R_E_C_N_O_ AS REG "
cQuery +="FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (D2_TES = F4_CODIGO) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = F2_FILIAL) AND (D2_SERIE = F2_SERIE) AND (D2_DOC = F2_DOC) AND (D2_CLIENTE = F2_CLIENTE) "
cQuery +="WHERE (SD2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = '"+xFilial("SD2")+"') AND ((F4_DUPLIC = 'S') OR (D2_TES = '519')) AND "
cQuery +="(D2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"') "
cQuery +="UNION ALL "
cQuery +="SELECT DISTINCT D1_FORNECE AS CLIENTE,SUBSTRING(D1_DTDIGIT,1,6) AS MES,SF1.R_E_C_N_O_*-1 AS REG "
cQuery +="FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (D1_TES = F4_CODIGO) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SF1")+" SF1 WITH (NOLOCK) ON (SF1.D_E_L_E_T_ <> '*') AND (D1_FILIAL = F1_FILIAL) AND (D1_SERIE = F1_SERIE) AND (D1_DOC = F1_DOC) AND (D1_FORNECE = F1_FORNECE) "
cQuery +="WHERE (SD1.D_E_L_E_T_ <> '*') AND (D1_FILIAL = '"+xFilial("SD1")+"') AND (D1_TIPO = 'D') AND (F4_DUPLIC = 'S') AND "
cQuery +="(D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"')), "
cQuery +="TMP3 AS (SELECT CLIENTE,MES,SUM(CASE WHEN REG < 0 THEN -1 ELSE 1 END) AS QTDENF FROM TMP2 GROUP BY CLIENTE,MES), "
cQuery +="MESES AS (SELECT CLIENTE,MES,SUM(VLRMES) AS VLRMES,REGICM FROM TMP GROUP BY CLIENTE,MES,REGICM), "
cQuery +="TOTAIS AS (SELECT CLIENTE,SUM(VALOR) AS VALOR FROM TMP1 GROUP BY CLIENTE) "
cQuery +="SELECT MESES.CLIENTE,A1_NOME AS RAZAO,A1_EST AS ESTADO,MESES.MES,MESES.VLRMES,MESES.REGICM,TOTAIS.VALOR,TMP3.QTDENF FROM MESES "
cQuery +="LEFT OUTER JOIN TOTAIS ON (MESES.CLIENTE = TOTAIS.CLIENTE)  "
cQuery +="LEFT OUTER JOIN TMP3 ON (MESES.CLIENTE = TMP3.CLIENTE) AND (MESES.MES = TMP3.MES) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (MESES.CLIENTE = A1_COD) "
cQuery +="ORDER BY REGICM,VALOR DESC"

TCQuery cQuery NEW ALIAS "TCQ"

SetRegua(RECCOUNT())
Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)

dbselectarea("TCQ")
dbgotop()

_nLin := 07
V_CLIENTE := TCQ->CLIENTE
While !eof()

	if _nLin > 55
		@ _nLin,000 psay replicate("_",80)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
		_nLin := 07
	endif
	_nLin++
	 @ _nLin,000 psay TCQ->CLIENTE
	 @ _nLin,007 psay TCQ->RAZAO
 	 @ _nLin,050 psay TCQ->ESTADO  
 	 @ _nLin,053 psay TCQ->REGICM
 	 @ _nLin,059 psay  substr(TCQ->MES,5,2)+"/"+substr(TCQ->MES,3,2)
 	 @ _nLin,064 psay transform(TCQ->VLRMES,"@E 99,999,999.99")
	 @ _nLin,078 psay TCQ->QTDENF
	
	 nTotal+= TCQ->VLRMES
	 V_CLIENTE := TCQ->CLIENTE
     dbSelectArea("TCQ")
     dbSkip()

	if eof() .or. (TCQ->CLIENTE != V_CLIENTE)
	_nLin++
	if _nLin > 55
	@ _nLin,000 psay replicate("_",80)
	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
	_nLin := 07
		endif

		_nLin++
		@_nLin,053 psay "TOTAL: "+transform(nTotal,"@E 99,999,999.99")
		if _nLin > 55
			@ _nLin,000 psay replicate("_",80)
			Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
			_nLin := 07
		endif
		_nLin++
		@ _nLin,000 psay replicate("-",80)

		nTotal := 0
	endif
     dbSelectArea("TCQ")
endDo

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
/*
Static Function CriaSX1(cPerg)

Local aHelp := {}

//Texto do help em portugues  ,     ingles, espanhol

AAdd(aHelp, {{"Informe de Emissao"},  {""}, {""}})
AAdd(aHelp, {{"Informe ate Emissao"},  {""}, {""}})

PutSX1(cPerg,"01","de Emissao" ,"","","mv_ch1","D",8,00,00,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
PutSX1(cPerg,"02","ate Emissao" ,"","","mv_ch2","D",8,00,00,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")

Return
*/