#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function BRSACR13()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE CbTxt
PRIVATE Titulo := "Relatorio de SAC  x Produção"
PRIVATE cDesc1 := "Relatorio informa sacs existentes sob o lote"
PRIVATE cDesc2 := ""
PRIVATE cDesc3 := "" 
                   //   0          1           2         3         4         5         6       7          8        9        10
                   //012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
PRIVATE cCabec1  := ""
PRIVATE cCabec2  := ""
private nTipo := 18
PRIVATE Tamanho:= "G"
PRIVATE Limite := 220
PRIVATE cString:= "SZR"
private m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:="BRSACR13"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   :="BRSACR13"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
CriaSX1(cPerg)
Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:="BRSACR13"            //Nome Default do relatorio em Disco

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
// Funçào....: RPTDETAIL    Data....: 21/05/15         //
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
               
cQuery :="WITH TMP AS(SELECT ZR_FILIAL, ZR_PRODUTO, B1_DESC, ZR_ASSUNTO, ZR_OCORREN,COUNT(SZR.R_E_C_N_O_) AS 'ZQ_QTDE', COUNT( DISTINCT ZQ_CLIENTE) AS QTDCLI "
cQuery +="FROM "+RetSqlName("SZR")+" SZR WITH (NOLOCK) " 
cQuery +="LEFT OUTER JOIN "+RetSqlName("SZQ")+" SZQ WITH(NOLOCK) ON ZR_FILIAL ='"+xFilial("SZQ")+"' AND ZR_NUM = ZQ_NUM AND SZQ.D_E_L_E_T_ ='' "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON B1_FILIAL ='"+xFilial("SB1")+"' AND B1_COD = ZR_PRODUTO AND SB1.D_E_L_E_T_ ='' "
cQuery +="WHERE SZR.D_E_L_E_T_ ='' AND ZQ_DATA BETWEEN ('"+dtos(MV_PAR01)+"') AND ('"+dtos(MV_PAR02)+"') AND  "  
if MV_PAR07 = 1 
	if Empty(MV_PAR06)
		cQuery +="ZR_OCORREN <> '' "
	else                                           
  		cQuery +="ZR_OCORREN IN('"+(MV_PAR06)+"') "
	endif
elseif MV_PAR07 = 2
	if Empty(MV_PAR03)
		cQuery +="ZR_ASSUNTO BETWEEN ('000001') AND ('010000') "
	else  
		cQuery +="ZR_ASSUNTO IN('"+MV_PAR03+"') "
	endif
elseif MV_PAR07 = 3
	if Empty(MV_PAR03)
		cQuery +="ZR_ASSUNTO BETWEEN ('000001') AND ('010000')  AND "
	else  
		cQuery +="ZR_ASSUNTO IN('"+MV_PAR03+"') AND "                                                          	
	endif                                          
	if Empty(MV_PAR06)
		cQuery +="ZR_OCORREN <> '' "
	else                                           
   		cQuery +="ZR_OCORREN IN('"+(MV_PAR06)+"') "
	endif
endif
cQuery +="AND ZR_PRODUTO  BETWEEN ('"+MV_PAR04+"') AND ('"+MV_PAR05+"') AND (SZR.ZR_FILIAL='"+xFilial("SZR")+"') "	 
cQuery +="GROUP BY ZR_FILIAL, ZR_PRODUTO, B1_DESC, ZR_ASSUNTO,ZR_OCORREN) "
cQuery +="SELECT TMP.*, SUM(SD2.D2_QUANT) AS D2_TOTALVENDA FROM TMP " 
cQuery +="LEFT OUTER JOIN SD2010 SD2 WITH(NOLOCK) ON TMP.ZR_FILIAL = SD2.D2_FILIAL AND TMP.ZR_PRODUTO = SD2.D2_COD  " 
cQuery +="LEFT OUTER JOIN SF4010 SF4 WITH(NOLOCK) ON SF4.F4_FILIAL = SF4.F4_FILIAL AND SF4.F4_CODIGO = SD2.D2_TES  " 
cQuery +="WHERE SD2.D_E_L_E_T_ ='' AND D2_EMISSAO BETWEEN ('"+dTos(MV_PAR01)+"') AND ('"+dTos(MV_PAR02)+"') AND ZR_PRODUTO  BETWEEN ('"+MV_PAR04+"') AND ('"+MV_PAR05+"') AND SF4.F4_ESTOQUE ='S' " 
cQuery +="GROUP BY TMP.ZR_FILIAL, TMP.ZR_PRODUTO, TMP.B1_DESC, TMP.ZR_ASSUNTO, TMP.ZQ_QTDE, TMP.QTDCLI,TMP.ZR_OCORREN "
cQuery +="ORDER BY TMP.ZR_FILIAL, TMP.ZR_PRODUTO, TMP.ZQ_QTDE DESC,TMP.ZR_OCORREN  "


TCQuery cQuery NEW ALIAS "TCQ"

SetRegua(RECCOUNT()) 
cCabec1 :="               SACs emitidos no periodo de: "+SubStr(dtos(MV_PAR01), 7, 2)+'/'+SubStr(dtos(MV_PAR01), 5, 2)+'/'+SubStr(dtos(MV_PAR01), 3, 2)+" até: "+SubStr(dtos(MV_PAR02), 7, 2)+'/'+SubStr(dtos(MV_PAR02), 5, 2)+'/'+SubStr(dtos(MV_PAR02), 3, 2)"

if MV_PAR07 = 1 
	cCabec2 :="Produto        Descrição                       Qtde       QtdeCli       Total Venda        Ocorrencia"
elseif MV_PAR07 = 2
	cCabec2 :="Produto        Descrição                       Qtde       QtdeCli       Total Venda        Assunto"
else                                                                                                
	cCabec2 :="Produto        Descrição                       Qtde       QtdeCli       Total Venda        Assunto             Ocorrencia"
endif
Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)

dbselectarea("TCQ")
dbgotop()         
cAssunto    := POSICIONE("SX5",1,XFILIAL("SX5")+"T1"+TCQ->ZR_ASSUNTO,"X5_DESCRI")  
cOcorrencia := POSICIONE("SU9",1,XFILIAL("SU9")+TCQ->ZR_ASSUNTO+TCQ->ZR_OCORREN,"U9_DESC")  
                                                  
_nLin := 08
LimLinha := 70    

While !eof()
	if _nLin > LimLinha
		@ _nLin,000 psay replicate("_",220)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)               
		_nLin := 08	    
	endif                              
If MV_PAR07 = 1   
	@_nLin,000 psay TCQ->ZR_PRODUTO
	@_nLin,015 psay TCQ->B1_DESC
	@_nLin,050 psay TCQ->ZQ_QTDE
	@_nLin,060 psay TCQ->QTDCLI
	@_nLin,076 psay TCQ->D2_TOTALVENDA
	@_nLin,091 psay cOcorrencia
elseif MV_PAR07 = 2
	@_nLin,000 psay TCQ->ZR_PRODUTO
	@_nLin,015 psay TCQ->B1_DESC
	@_nLin,050 psay TCQ->ZQ_QTDE
	@_nLin,060 psay TCQ->QTDCLI
	@_nLin,076 psay TCQ->D2_TOTALVENDA
	@_nLin,091 psay cAssunto	
else
	@_nLin,000 psay TCQ->ZR_PRODUTO
	@_nLin,015 psay TCQ->B1_DESC
	@_nLin,050 psay TCQ->ZQ_QTDE
	@_nLin,060 psay TCQ->QTDCLI
	@_nLin,076 psay TCQ->D2_TOTALVENDA
	@_nLin,091 psay cAssunto  
	@_nLin,112 psay cOcorrencia  		
endif 	
	_nLin++
	dbSelectArea("TCQ")
	dbSkip()
	cAssunto := POSICIONE("SX5",1,XFILIAL("SX5")+"T1"+TCQ->ZR_ASSUNTO,"X5_DESCRI") 
	cOcorrencia := POSICIONE("SU9",1,XFILIAL("SU9")+TCQ->ZR_ASSUNTO+TCQ->ZR_OCORREN,"U9_DESC")      
endDo 
  _nLin++                  
@ _nLin,000 psay replicate("_",220)
	   
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

AAdd(aHelp, {{"de Periodo"},  {""}, {""}})
AAdd(aHelp, {{"ate Periodo"},  {""}, {""}})
AAdd(aHelp, {{"Assunto"},  {""}, {""}})
AAdd(aHelp, {{"de Periodo"},  {""}, {""}})
AAdd(aHelp, {{"ate Periodo"},  {""}, {""}})
AAdd(aHelp, {{"Assunto"},  {""}, {""}})
AAdd(aHelp, {{"Assunto"},  {""}, {""}})                                                               
//( < cGrupo>, < cOrdem>, < cPergunt>, < cPergSpa>, < cPergEng>, < cVar>, < cTipo>, < nTamanho>, [ nDecimal], [ nPreSel], < cGSC>, [ cValid], [ cF3], [ cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil
PutSX1(cPerg,"01","de : " ,"","","mv_ch1","D",8,00,00,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
PutSX1(cPerg,"02","ate: " ,"","","mv_ch2","D",8,00,00,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")
PutSX1(cPerg,"03","Assunto: " ,"","","mv_ch3","C",6,00,00,"G","","T1","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelp[3,1],aHelp[3,2],aHelp[3,3],"")
PutSX1(cPerg,"04","de Produto : " ,"","","mv_ch4","C",6,00,00,"G","","","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelp[4,1],aHelp[4,2],aHelp[4,3],"")
PutSX1(cPerg,"05","ate Produto: " ,"","","mv_ch5","C",6,00,00,"G","","","","","MV_PAR05","","","","","","","","","","","","","","","","",aHelp[5,1],aHelp[5,2],aHelp[5,3],"")
PutSX1(cPerg,"06","Ocorrencia: " ,"","","mv_ch6","C",6,00,00,"G","","SU9","","","MV_PAR06","","","","","","","","","","","","","","","","",aHelp[6,1],aHelp[6,2],aHelp[6,3],"")
PutSX1(cPerg,"07","Consultar por? " ,"","","mv_ch7","N",1,00,00,"C","","","","","MV_PAR07","Ocorrencia","","","","Assunto","","","Ambos","","","","","","","","",aHelp[7,1],aHelp[7,2],aHelp[7,3],"")

Return*/