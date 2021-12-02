#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function BRSTRR01()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define Variaveis                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE CbTxt
PRIVATE Titulo := "Relatorio de vendas Vendedor x Volume(Kg+L)"
PRIVATE cDesc1:=""
PRIVATE cDesc2:=""
PRIVATE cDesc3 := "" 
                   //   0          1           2         3         4         5         6       7          8        9        10         11        12       13        14         15         16
                   //012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
PRIVATE cCabec1  := "                            Relatorio Vendedor x Volume"
PRIVATE cCabec2  := "Codigo    Nome                                              Data      Volume"  
private nTipo := 18
PRIVATE Tamanho:= "P"
PRIVATE Limite := 80
PRIVATE cString:= "SA1"
private m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:= "BRSTRR01"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   := "BRSTRR01"
     u_zcfga01( 'BRSTRR01' ) //LGS#2021201 - GravaГЦo de log de utilizaГЦo da rotina
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica as perguntas selecionadas                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    
//CriaSX1(cPerg)  //LGS#20200204 - AdequaГЦo de release 12.1.25 e posteriores
Pergunte(cPerg,.F.)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Envia controle para a funcao SETPRINT                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

wnrel:= "BRSTRR01"            //Nome Default do relatorio em Disco

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
//Local	_nCont := 0
//Local lNormal
Private _nLin := 7

//зддддддддддддддддддддддддддддд
//дддддддддддддддддддддддддддддд©
//Ё Inicializa  regua de impressaoЁ
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cQuery :="WITH TMP AS (SELECT F2_VEND1 AS VEND,MAX(A3_NOME) AS NOME,SUBSTRING(D2_EMISSAO,1,6) AS MES, "
cQuery +="VOLUME = SUM(CASE WHEN D2_UM IN ('L','K','KG') THEN D2_QUANT WHEN D2_SEGUM IN ('L','K','KG') THEN D2_QTSEGUM ELSE 0 END) "
cQuery +="FROM  "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = F2_FILIAL) AND (D2_SERIE = F2_SERIE) AND (D2_DOC = F2_DOC) AND (D2_CLIENTE = F2_CLIENTE) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (D2_TES = F4_CODIGO) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SA3")+" SA3 WITH (NOLOCK) ON (SA3.D_E_L_E_T_ <> '*') AND (F2_VEND1 = A3_COD) "
cQuery +="WHERE (SD2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = '"+xFilial("SD2")+"') AND (D2_TIPO = 'N') AND ((F4_DUPLIC = 'S') OR (D2_TES = '519')) AND "
	cQuery +="(D2_EMISSAO BETWEEN ('"+dTos(MV_PAR01)+"') AND ('"+dTos(MV_PAR02)+"')) AND (LEN(D2_COD) = 12) AND F2_VEND1 BETWEEN ('"+MV_PAR03+"') AND ('"+MV_PAR04+"') "
cQuery +="GROUP BY F2_VEND1,SUBSTRING(D2_EMISSAO,1,6) " 
cQuery +="UNION ALL "
cQuery +="SELECT F2_VEND1 AS VEND,MAX(A3_NOME) AS NOME,SUBSTRING(D1_DTDIGIT,1,6) AS MES, "
cQuery +="VOLUME = SUM(-1.0*CASE WHEN D1_UM IN ('L','K','KG') THEN D1_QUANT WHEN D1_SEGUM IN ('L','K','KG') THEN D1_QTSEGUM ELSE 0 END) " 
cQuery +="FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (D1_FILIAL = F2_FILIAL) AND (D1_SERIORI = F2_SERIE) AND (D1_NFORI = F2_DOC) AND (D1_FORNECE = F2_CLIENTE) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (D1_TES = F4_CODIGO) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SA3")+" SA3 WITH (NOLOCK) ON (SA3.D_E_L_E_T_ <> '*') AND (F2_VEND1 = 	A3_COD) "
cQuery +="WHERE (SD1.D_E_L_E_T_ <> '*') AND (D1_FILIAL = '"+xFilial("SD1")+"') AND (D1_TIPO = 'D') AND (F4_DUPLIC = 'S') AND " 
cQuery +="(D1_DTDIGIT BETWEEN ('"+dTos(MV_PAR01)+"') AND ('"+dTos(MV_PAR02)+"')) AND (LEN(D1_COD) = '12') AND F2_VEND1 BETWEEN ('"+MV_PAR03+"') AND ('"+MV_PAR04+"') "
cQuery +="GROUP BY F2_VEND1,SUBSTRING(D1_DTDIGIT,1,6)) "
cQuery +="SELECT VEND,MAX(NOME) AS NOME,MES,SUM(VOLUME) AS VOLUME "
cQuery +="FROM TMP "
cQuery +="GROUP BY VEND,MES ORDER BY VEND,MES"
// AND (D1_FORNECE <> '021428') ==>> Cleber(14/02/17) -> Estava excluindo as devoluГУes da Dissoltex porИm nЦo estava excluindo as vendas!!                                                                            
TCQUERY cQuery ALIAS "TCQ" NEW
dbselectarea("TCQ")

SetRegua(RECCOUNT()) 
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
  	@ _nLin,010 psay TCQ->NOME
	@ _nLin,060 psay substr(TCQ->MES,5,2)+"/"+substr(TCQ->MES,3,2)
	@ _nLin,067 psay Transform(TCQ->VOLUME,"@E 99,999,999.99")
	cAuxVol += TCQ->VOLUME
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
    dbCloseArea()
Set Device To Screen
If aReturn[5] == 1             	
   Set Printer TO
   dbcommitAll()
   ourspool(wnrel)
Endif
Return

//LGS#20200204 - AdequaГЦo de release 12.1.25 e posteriores
/*Static Function CriaSX1(cPerg)

Local aHelp := {}

//Texto do help em portugues,ingles, espanhol
AAdd(aHelp, {{"de Periodo"  },  {""}, {""}})
AAdd(aHelp, {{"ate Periodo" },  {""}, {""}})
AAdd(aHelp, {{"de Vendedor" },  {""}, {""}})
AAdd(aHelp, {{"ate Vendedor"},  {""}, {""}})

//(<cGrupo>,<cOrdem>,<Pergunt>,< cPergSpa>,< cPergEng>,< cVar>,< cTipo>,< nTamanho>,[ nDecimal],[ nPreSel],<cGSC>,[cValid],[cF3],[cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil
PutSX1(cPerg,"01","de Periodo: " ,"","","mv_ch1","D",,00,00,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
PutSX1(cPerg,"02","ate Periodo: " ,"","","mv_ch2","D",8,00,00,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")
PutSX1(cPerg,"03","Consulta por: " ,"","","mv_ch3","C",6,00,00,"G","","SA3","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelp[3,1],aHelp[3,2],aHelp[3,3],"")
PutSX1(cPerg,"04","Consulta por: " ,"","","mv_ch4","C",6,00,00,"G","","SA3","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelp[4,1],aHelp[4,2],aHelp[4,3],"")

Return*/
