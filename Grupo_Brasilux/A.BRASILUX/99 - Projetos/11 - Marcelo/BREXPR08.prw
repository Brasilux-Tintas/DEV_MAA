#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function BREXPR08()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Define Variaveis                                             ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
PRIVATE CbTxt
PRIVATE Titulo := "Relatorio Nota x Volume"
PRIVATE cDesc1:=""
PRIVATE cDesc2:=""
PRIVATE cDesc3 := "" 
                   //   0          1           2         3         4         5         6       7          8        9        10         11        12       13        14         15         16
                   //012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
PRIVATE cCabec1  := ""
PRIVATE cCabec2  := ""
private nTipo := 18
PRIVATE Tamanho
PRIVATE Limite
PRIVATE cString:= "SA1"
private m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:= "BREXPR08"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   := "BREXPR08"

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Verifica as perguntas selecionadas                           ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
    
//CriaSX1(cPerg)  //LGS#20200210 - Adequa豫o de release 12.1.25 e posteriores
Pergunte(cPerg,.F.)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Envia controle para a funcao SETPRINT                        ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

wnrel:= "BREXPR08"            //Nome Default do relatorio em Disco

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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Inicio do Processamento do Relatorio                         ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

RptStatus({|| RptDetail()})

return

/////////////////////////////////////////////////////////
// Fun裔o....: RPTDETAIL    Data....: 08/06/15         //
// Autor.....: Marcelo J. A. de Paiva                  //
/////////////////////////////////////////////////////////

Static Function RptDetail()
//Local nTotal := 0
//Local _nCont := 0
//Local lNormal
Private _nLin := 8

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//?Inicializa  regua de impressao?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
If MV_PAR03 = 1
	cQuery :=""
	cQuery +="WITH TMP AS( "
	cQuery +="SELECT F2_DOC, F2_SERIE, F2_VOLUME1, SUBSTRING(F2_EMISSAO,5,2)+'-'+SUBSTRING(F2_EMISSAO,1,4) AS 'MESANO', F2_PBRUTO, SUM(D2_QTSEGUM) AS D2_QTSEGUM,"
	cQuery +="CASE WHEN F2_TRANSP IN('00700','099999', '00573','00800') AND F2_EST <>'EX' THEN '2 - DEPOSITO SP' ELSE "
	cQuery +="CASE WHEN F2_CLIENT IN('021428')THEN '6 - DISSOLTEX' ELSE "	
	cQuery +="CASE WHEN F2_TRANSP IN('00572','01444 ','02172') AND F2_EST <>'EX' THEN '3 - CLI RETIRA' ELSE "
	cQuery +="CASE WHEN F2_TRANSP IN "
   	cQuery +=" ('"+Getmv("MV_XTRAREG")+"') AND F2_EST <>'EX' THEN '5 - REGIAO' ELSE "
	//cQuery +="('00591','00592','00593','00594','00595','00250 ','01512','01499','00812','01604','01679','01676','01902','099998','01579') AND F2_EST <>'EX' THEN '5 - REGIAO' ELSE " 
	cQuery +="CASE WHEN F2_EST ='EX' THEN '1 - EXPORTA플O ' ELSE "
	cQuery +="CASE WHEN SUBSTRING(A4_CGC,1,8) <>'72770878' AND F2_TRANSP = F2_REDESP AND F2_EST <>'EX' THEN '4 - TERC. RETIRA' ELSE '7 - SEM TRANSPORTADORA' "
	cQuery +="END END END END END END AS 'DESTINO', SUM(D2_TOTAL)/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END) AS VALFAT "
	cQuery +="FROM "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) "
	cQuery +="LEFT OUTER JOIN "+RetSqlName("SD2")+" SD2 WITH(NOLOCK) ON D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND SD2.D_E_L_E_T_ ='' "
	cQuery +="LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH(NOLOCK) ON F4_FILIAL = F4_FILIAL AND F4_CODIGO = D2_TES AND F4_ESTOQUE <>'N' AND SF4.D_E_L_E_T_ ='' "
	cQuery +="LEFT OUTER JOIN "+RetSqlName("SA4")+" SA4 WITH(NOLOCK) ON A4_FILIAL = A4_FILIAL AND A4_COD = F2_TRANSP AND SA4.D_E_L_E_T_ ='' "
	cQuery +="LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH(NOLOCK) ON C5_FILIAL = D2_FILIAL AND C5_NUM = D2_PEDIDO AND SD2.D_E_L_E_T_ ='' "
	cQuery +="WHERE (F2_FILIAL = '"+xFilial("SF2")+"') AND SF2.D_E_L_E_T_ ='' AND F2_EMISSAO BETWEEN('"+dTos(MV_PAR01)+"') AND ('"+dTos(MV_PAR02)+"') "
	cQuery +="AND F2_CLIENTE NOT IN('023818','010181','000521','018089') AND F2_TIPO ='N' AND D2_ESTOQUE <>'N' "
	cQuery +="GROUP BY F2_DOC, F2_SERIE, F2_VOLUME1, F2_TRANSP, F2_EST, F2_PBRUTO, A4_CGC, F2_REDESP, F2_EMISSAO, C5_ESPECI4, F2_CLIENT )  " 
	cQuery +="SELECT TMP.MESANO, SUM(TMP.F2_VOLUME1) AS 'VOLUME', COUNT(*) AS 'TOTALNOTA', TMP.DESTINO, ROUND(SUM(F2_PBRUTO),2) AS F2_PBRUTO, ROUND(SUM(D2_QTSEGUM),2) AS D2_QTSEGUM, ROUND(SUM(VALFAT),2)  AS VALFAT "
	cQuery +="FROM TMP GROUP BY DESTINO, MESANO "
	cQuery +="ORDER BY MESANO ,TMP.DESTINO "

Else
	cQuery:=""	
	cQuery +="SELECT F2_DOC, F2_SERIE, F2_VOLUME1, F2_RAZAO, F2_TRANSP, ISNULL(A4_NOME,'FATUROU SEM TRANSPORTE') AS 'A4_NOME', F2_EST, F2_PBRUTO, SUM(D2_QTSEGUM) AS D2_QTSEGUM, "
	cQuery +="CASE WHEN F2_TRANSP IN('00700','099999', '00573','00800') AND F2_EST <>'EX' THEN '2 - DEPOSITO SP' ELSE "
	cQuery +="CASE WHEN F2_CLIENT IN('021428')THEN '6 - DISSOLTEX' ELSE "
	cQuery +="CASE WHEN F2_TRANSP IN('00572','01444 ','02172') AND F2_EST <>'EX' THEN '3 - CLI RETIRA' ELSE "
	cQuery +="CASE WHEN F2_TRANSP IN ('"+Getmv("MV_XTRAREG")+"') AND F2_EST <>'EX' THEN '5 - REGIAO' ELSE "
	//cQuery +="CASE WHEN F2_TRANSP IN('00591','00592','00593','00594','00595','00250 ','01512','01499','00812','01604','01679','01676','01902','099998','01579') AND F2_EST <>'EX' THEN '5 - REGIAO' ELSE "
	cQuery +="CASE WHEN F2_EST ='EX' THEN '1 - EXPORTA플O ' ELSE "
	cQuery +="CASE WHEN SUBSTRING(A4_CGC,1,8) <>'72770878' AND F2_TRANSP = F2_REDESP AND F2_EST <>'EX' THEN '4 - TERC. RETIRA' ELSE '7 - VERIFICAR' "
	cQuery +="END END END END END END AS 'DESTINO', "
	cQuery +="CASE WHEN SUBSTRING(A4_CGC,1,8) = '72770878' THEN 'PROPRIO' ELSE 'TERCEIRO' END AS 'TIPOTRANS', ROUND(SUM(D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END)),2) AS VALFAT  "
	cQuery +="FROM "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) "
	cQuery +="LEFT OUTER JOIN "+RetSqlName("SD2")+" SD2 WITH(NOLOCK) ON D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND SD2.D_E_L_E_T_ ='' "
	cQuery +="LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH(NOLOCK) ON F4_FILIAL = F4_FILIAL AND F4_CODIGO = D2_TES AND F4_ESTOQUE <>'N' AND SF4.D_E_L_E_T_ ='' "
	cQuery +="LEFT OUTER JOIN "+RetSqlName("SA4")+" SA4 WITH(NOLOCK) ON A4_FILIAL = A4_FILIAL AND A4_COD = F2_TRANSP AND SA4.D_E_L_E_T_ ='' "
	cQuery +="LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH(NOLOCK) ON C5_FILIAL = D2_FILIAL AND C5_NUM = D2_PEDIDO AND SD2.D_E_L_E_T_ ='' "
	cQuery +="WHERE F2_FILIAL = ('"+xFilial("SF2")+"') AND SF2.D_E_L_E_T_ ='' AND F2_EMISSAO BETWEEN('"+dTos(MV_PAR01)+"') AND ('"+dTos(MV_PAR02)+"') "
	cQuery +="AND F2_CLIENTE NOT IN('023818','010181','000521','018089') AND F2_TIPO ='N' AND D2_ESTOQUE <>'N' "
	cQuery +="GROUP BY F2_DOC, F2_SERIE, F2_VOLUME1, F2_RAZAO, F2_TRANSP, A4_NOME, F2_TRANSP, F2_EST, F2_PBRUTO, A4_CGC, F2_REDESP, F2_CLIENT "
	cQuery +="ORDER BY DESTINO, F2_TRANSP, F2_VOLUME1 DESC "
endIf
                                                                             
TCQUERY cQuery ALIAS "TCQ" NEW
dbselectarea("TCQ")
	
SetRegua(RECCOUNT( ))     
cCabec1  := "                  Relatorio Nota x Volume     "+substr(DTOS(MV_PAR01),7,2)+"/"+substr(DTOS(MV_PAR01),5,2)+"/"+substr(DTOS(MV_PAR01),1,4)+"  -  "+substr(DTOS(MV_PAR02),7,2)+"/"+substr(DTOS(MV_PAR02),5,2)+"/"+substr(DTOS(MV_PAR02),1,4)

Limite = 220
Tamanho = "G"	

If  MV_PAR03 = 1        
	cCabec2  := "Data                 Volume           Total Notas           Peso Bruto           Lt/Kg             Valor	                Destino" 
			//   0          1           2         3         4         5         6       7          8        9        10         11        12       13        14         15         16
            //   012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
Else              
	cCabec2  := "Nota   Serie     Volumes   Peso          Lt/Kg       Valor          Raz?                                 Codigo   Nome Transp                               Estado       Destino          Tipo Transporte"
			//   0          1           2         3         4         5         6       7          8        9        10         11        12       13        14         15         16
            //   012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
Endif
Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)                       
_nLin := 9                                                                                             
cAuxVol := 0  
nTotNot := 0
nTotPes := 0
nTotSeg := 0
nTotVal := 0
cCountTotal := 0  
If MV_PAR03 = 1
cMes:= Substring(MESANO,0,2)
	while !eof()
		while cMes == Substring(MESANO,0,2) 
			@ _nLin,000 psay TCQ->MESANO
			@ _nLin,025 psay transform(TCQ->VOLUME,"@E 99,999,999")
			@ _nLin,037 psay transform(TCQ->TOTALNOTA,"@E 99,999,999")
			@ _nLin,058 psay transform(TCQ->F2_PBRUTO,"@E 99,999,999.99")
			@ _nLin,078 psay transform(TCQ->D2_QTSEGUM,"@E 99,999,999.99")
			@ _nLin,097 psay transform(TCQ->VALFAT,"@E 99,999,999.99")
			@ _nLin,120 psay TCQ->DESTINO
			@ _nLin++                    
			if _nLin > 70                                                                    	
				@ _nLin,000 psay replicate("_",220)
				Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
				_nLin := 09
			endif 
			cAuxVol += TCQ->VOLUME
			nTotNot += TCQ->TOTALNOTA
			nTotPes += TCQ->F2_PBRUTO
			nTotSeg += TCQ->D2_QTSEGUM
			nTotVal += TCQ->VALFAT
		   	dbselectarea("TCQ")
		 	dbskip()
		EndDo
		@ _nLin,000 psay replicate("_",220)
		@ _nLin++   
		@ _nLin,010 psay "Totais"
		@ _nLin,022 psay transform(cAuxVol,"@E 99,999,999.99")
		@ _nLin,037 psay transform(nTotNot,"@E 99,999,999")
		@ _nLin,059 psay transform(nTotPes,"@E 99,999,999.99")
		@ _nLin,079 psay transform(nTotSeg,"@E 99,999,999.99")
		@ _nLin,097 psay transform(nTotVal,"@E 99,999,999.99")
		@ _nLin++   
		@ _nLin,000 psay replicate("_",220)
		@ _nLin++   
		cMes:= Substring(MESANO,0,2)  
		cCountTotal += cAuxVol
		cAuxVol :=0
		nTotNot :=0
		nTotPes :=0
		nTotSeg :=0
		nTotVal :=0
	EndDo     
		//@ _nLin,000 psay "Total Volumes "+transform(cCountTotal,"@E 9999,999,999.99")
Else
	While !eof()
		@ _nLin,000 psay TCQ->F2_DOC
		@ _nLin,010 psay TCQ->F2_SERIE
		@ _nLin,014 psay transform(TCQ->F2_VOLUME1,"@E 99,999,999")
		@ _nLin,024 psay transform(TCQ->F2_PBRUTO,"@E 99,999,999.99")
		@ _nLin,036 psay transform(TCQ->D2_QTSEGUM,"@E 99,999,999.99")
		@ _nLin,048 psay transform(TCQ->VALFAT,"@E 99,999,999.99")
		@ _nLin,063 psay SUBSTR(TCQ->F2_RAZAO,0,40)
		@ _nLin,106 psay TCQ->F2_TRANSP
		@ _nLin,115 psay SUBSTR(TCQ->A4_NOME,0,40)
		@ _nLin,159 psay TCQ->F2_EST
		@ _nLin,170 psay TCQ->DESTINO
		@ _nLin,190 psay TCQ->TIPOTRANS
		@ _nLin++  
		if _nLin > 70                                                                    	
			@ _nLin,000 psay replicate("_",220)
			Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
			_nLin := 08
		endif 
		dbselectarea("TCQ")
	 	dbskip()
	EndDo
EndIf

dbSelectArea("TCQ")
dbCloseArea( )
Set Device To Screen
If aReturn[5] == 1
   Set Printer TO
   dbcommitAll()
   ourspool(wnrel)
Endif
Return

//LGS#20200210 - Adequa豫o de release 12.1.25 e posteriores
/*
Static Function CriaSX1(cPerg)

Local aHelp := {}

//Texto do help em portugues,ingles, espanhol
AAdd(aHelp, {{"de Periodo"  },  {""}, {""}})
AAdd(aHelp, {{"ate Periodo" },  {""}, {""}})
AAdd(aHelp, {{"ate Periodo" },  {""}, {""}})

//(<cGrupo>,<cOrdem>,<Pergunt>,< cPergSpa>,< cPergEng>,< cVar>,< cTipo>,< nTamanho>,[ nDecimal],[ nPreSel],<cGSC>,[cValid],[cF3],[cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil
PutSX1(cPerg,"01","de Periodo: " ,"","","mv_ch1","D",8,00,00,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
PutSX1(cPerg,"02","ate Periodo: " ,"","","mv_c bh2","D",8,00,00,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")
PutSX1(cPerg,"03","Tipo relatorio: " ,"","","mv_ch3","N",1 ,00,00,"C","",""   ,"","","MV_PAR03","Resumido","","","","Completo","","","","","","","","","","","",aHelp[3,1],aHelp[3,2],aHelp[3,3],"")

Return*/