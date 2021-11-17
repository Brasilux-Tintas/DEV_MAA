#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function BRFAT087()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE CbTxt
PRIVATE Titulo := "Relatorio de Faturamento x Estado"
PRIVATE cDesc1:=""
PRIVATE cDesc2:=""
PRIVATE cDesc3 := "" 
                   //   0          1           2         3         4         5         6       7          8        9        10         11        12       13        14         15         16
                   //012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
PRIVATE cCabec1  := "Estado        Volume                   Faturamento"
PRIVATE cCabec2  := ""  
private nTipo := 18
PRIVATE Tamanho:= "P"
PRIVATE Limite := 80
PRIVATE cString:= "SA1"
private m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:= "BRFAT087"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   := "BRFAT087"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
//CriaSX1(cPerg)
Pergunte(cPerg,.F.)

wnrel:= "BRFAT087"            //Nome Default do relatorio em Disco

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

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  14/01/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RptDetail()
Local cQuery  :=""
Local AuxTotalFat :=0
Local AuxTotalVol :=0   
Private _nLin := 7
       
       cQuery := ""
       cQuery += "WITH TMP AS (SELECT F2_EST AS UF,SUM(CASE WHEN D2_UM IN ('L','K','KG') THEN D2_QUANT WHEN D2_SEGUM IN ('L','K','KG') THEN D2_QTSEGUM ELSE 0 END) AS VOLUME , "
       cQuery +="SUM(D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END)) AS VALFAT "
       cQuery += "FROM "+RetSqlName("SD2")+"  SD2 WITH (NOLOCK) "
       cQuery += "LEFT OUTER JOIN "+RetSqlName("SF2")+"  SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = D2_FILIAL) AND (D2_SERIE = F2_SERIE) AND (D2_DOC = F2_DOC) "
       cQuery += "LEFT OUTER JOIN "+RetSqlName("SF4")+"  SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (D2_TES = F4_CODIGO) "
       cQuery += "LEFT OUTER JOIN "+RetSqlName("SC5")+"  SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (D2_FILIAL = C5_FILIAL) AND (D2_PEDIDO = C5_NUM) "
       cQuery += "WHERE (SF2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = '"+xFilial("SD2")+"') AND (D2_TIPO = 'N') AND ((F4_DUPLIC <> 'N') OR (D2_TES = '519')) AND "
       cQuery += "((D2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"') AND (F2_EST BETWEEN '"+(MV_PAR03)+"' AND '"+(MV_PAR04)+"') "
       IF !EMPTY(MV_PAR05)
	   		cQuery += "AND (LEN(D2_COD) = 12) AND ((SUBSTRING(D2_COD,4,2) IN('"+MV_PAR05+"'))) "	
       ENDIF
       cQuery += ") GROUP BY F2_EST "
       cQuery += "UNION ALL "
       cQuery += "SELECT F1_EST AS UF,-1*SUM(CASE WHEN D1_UM IN ('L','K','KG') THEN D1_QUANT WHEN D1_SEGUM IN ('L','K','KG') THEN D1_QTSEGUM ELSE 0 END) AS VOLUME, "
       cQuery += "-1*SUM(D1_TOTAL) AS VALFAT "
       cQuery += "FROM "+RetSqlName("SD1")+"  SD1 WITH (NOLOCK) "
       cQuery += "LEFT OUTER JOIN "+RetSqlName("SF1")+"  SF1 WITH (NOLOCK) ON (SF1.D_E_L_E_T_ <> '*') AND (D1_FILIAL = F1_FILIAL) AND (D1_FORNECE = F1_FORNECE) AND (D1_SERIE = F1_SERIE) AND (D1_DOC = F1_DOC) "
       cQuery += "LEFT OUTER JOIN "+RetSqlName("SF4")+"  SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (D1_TES = F4_CODIGO) "
       cQuery += "WHERE (SF1.D_E_L_E_T_ <> '*') AND (D1_FILIAL = '"+xFilial("SD1")+"') AND (D1_TIPO = 'D') AND (F4_DUPLIC <> 'N') AND "
       cQuery += "( (D1_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"') AND (F1_EST BETWEEN '"+(MV_PAR03)+"' AND '"+(MV_PAR04)+"') "
       IF !EMPTY(MV_PAR05)
	   		cQuery += "AND (LEN(D1_COD) = 12) AND ((SUBSTRING(D1_COD,4,2) IN('"+MV_PAR05+"'))) "	
       ENDIF 
       cQuery += ") GROUP BY F1_EST) SELECT UF,SUM(VOLUME) AS VOLUME,SUM(VALFAT) AS VALFAT FROM TMP GROUP BY UF ORDER BY VALFAT DESC "

TCQUERY cQuery NEW ALIAS "TCQ"  

dbselectarea("TCQ")
dbgotop()

SetRegua(RECCOUNT()) 

Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
_nLin := 09                                             

dbselectarea("TCQ")
dbgotop()                                                                                  

AuxTotalFat :=0
AuxTotalVol :=0   

While !eof()
	if _nLin > 55                                                                    	
		@ _nLin,000 psay replicate("_",80)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
		_nLin := 09
	endif 
	@ _nLin,002 psay TCQ->UF
	@ _nLin,012 psay transform(TCQ->VOLUME,"@E 99999999.99")
	@ _nLin,034 psay transform(TCQ->VALFAT,"@E 9,999,999,999.99")  
	AuxTotalFat+= TCQ->VALFAT
	AuxTotalVol += TCQ->VOLUME
	dbSelectArea("TCQ")
	dbSkip()      
	@ _nLin++
EndDo     
if _nLin > 55                                                                    	
	@ _nLin,000 psay replicate("_",80)
	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
	_nLin := 09
endif 
@ _nLin++  
@ _nLin,000 psay replicate("_",80)
@ _nLin++  
@ _nLin,012 psay transform(AuxTotalVol,"@E 99999999.99")
@ _nLin,040 psay transform(AuxTotalFat,"@E 999,999,999.99")  
DbSelectArea("TCQ")
DbCloseArea()
       SET DEVICE TO SCREEN
       If aReturn[5]==1
          dbCommitAll()
          SET PRINTER TO
          OurSpool(wnrel)
       Endif
       MS_FLUSH()
Return
/*
Static Function CriaSX1(cPerg)	

Local aHelp := {}

//Texto do help em portugues  ,     ingles, espanhol

AAdd(aHelp, {{"De emissao"},  {""}, {""}})
AAdd(aHelp, {{"Até emissao"},  {""}, {""}})
AAdd(aHelp, {{"Do Estado"},  {""}, {""}})
AAdd(aHelp, {{"Até estado"},  {""}, {""}})
AAdd(aHelp, {{"Linhas"},  {""}, {""}})

PutSX1(cPerg,"01","de emissao ?"    ,"Linha(s) Produto","Linha(s) Produto","mv_ch1","D",08,00,00,"G","","","","","mv_Par01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
PutSX1(cPerg,"02","ate emissao ?"    ,"Linha(s) Produto","Linha(s) Produto","mv_ch2","D",08,00,00,"G","","","","","mv_Par02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")
PutSX1(cPerg,"03","de estado ?"    ,"Linha(s) Produto","Linha(s) Produto","mv_ch3","C",02,00,00,"G","","","","","mv_Par03","","","","","","","","","","","","","","","","",aHelp[3,1],aHelp[3,2],aHelp[3,3],"")
PutSX1(cPerg,"04","ate estado ?"    ,"Linha(s) Produto","Linha(s) Produto","mv_ch4","C",02,00,00,"G","","","","","mv_Par04","","","","","","","","","","","","","","","","",aHelp[4,1],aHelp[4,2],aHelp[4,3],"")
PutSX1(cPerg,"05","Linha(s) Produto"    ,"Linha(s) Produto","Linha(s) Produto","mv_ch5","C",99,00,00,"G","","","","","mv_Par05","","","","","","","","","","","","","","","","",aHelp[5,1],aHelp[5,2],aHelp[5,3],"")
Return
*/