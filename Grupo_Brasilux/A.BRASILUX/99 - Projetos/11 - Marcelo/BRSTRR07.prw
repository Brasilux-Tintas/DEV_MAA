#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function BRSTRR07()
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
PRIVATE cCabec1  := "                            Relatorio Cliente x Nota xFaturamento x Data"	
PRIVATE cCabec2  := "Código  Razão                                          Industria            Mat.Construc.        Revenda             Total"
private nTipo := 18
PRIVATE Tamanho:= "M"
PRIVATE Limite := 132
PRIVATE cString:= "SA1"
private m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:= "BRSTRR07"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   := "BRSTRR07"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
//CriaSX1(cPerg)   //LGS#20200210 - Adequação de release 12.1.25 e posteriores
Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:= "BRSTRR07"            //Nome Default do relatorio em Disco

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
cQuery +="WITH TMP AS (SELECT F2_VEND1,A3_NOME,A1_SATIV2, "
cQuery +="VOLUME = SUM(CASE WHEN D2_UM IN ('L','K','KG') THEN D2_QUANT WHEN D2_SEGUM IN ('L','K','KG') THEN D2_QTSEGUM ELSE 0 END) "
cQuery +="FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK)  "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = '"+xFilial("SF2")+"') AND (D2_SERIE = F2_SERIE) AND (D2_DOC = F2_DOC) AND (D2_CLIENTE = F2_CLIENTE) AND (D2_PEDIDO = F2_PEDIDO) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SA3")+" SA3 WITH (NOLOCK) ON (SA3.D_E_L_E_T_ <> '*') AND (A3_FILIAL = '"+xFilial("SA3")+"') AND (A3_COD = F2_VEND1)  "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (D2_CLIENTE = A1_COD)  "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (D2_TES = F4_CODIGO)  "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = '"+xFilial("SC5")+"') AND (D2_PEDIDO = C5_NUM)  "
cQuery +="WHERE (SD2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = '"+xFilial("SD2")+"') AND (D2_TIPO = 'N') AND ((F4_DUPLIC <> 'N') OR (D2_TES = '519')) AND (D2_EMISSAO BETWEEN ('"+dTos(MV_PAR01)+"') AND ('"+dTos(MV_PAR02)+"')) "
cQuery +="GROUP BY F2_VEND1,A3_NOME,A1_SATIV2  "
cQuery +="UNION ALL SELECT F2_VEND1 ,A3_NOME,A1_SATIV2, "
cQuery +="VOLUME = SUM(-1.0*CASE WHEN D1_UM IN ('L','K','KG') THEN D1_QUANT WHEN D1_SEGUM IN ('L','K','KG') THEN D1_QTSEGUM ELSE 0 END)  "
cQuery +="FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK)  "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SF1")+" SF1 WITH (NOLOCK) ON (SF1.D_E_L_E_T_ <> '*') AND (D1_FILIAL = '"+xFilial("SD1")+"') AND (D1_FORNECE = F1_FORNECE) AND (D1_SERIE = F1_SERIE) AND (D1_DOC = F1_DOC)  "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = '"+xFilial("SF2")+"') AND (D1_NFORI = F2_DOC) AND (D1_SERIORI = F2_SERIE) AND (D1_FORNECE = F2_CLIENTE)  "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (D1_TES = F4_CODIGO)  "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SA3")+" SA3 WITH (NOLOCK) ON (SA3.D_E_L_E_T_ <> '*') AND (A3_FILIAL = '"+xFilial("SA3")+"') AND (A3_COD = F2_VEND1)  "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (F2_VEND1 = A1_COD) "
cQuery +="WHERE (SD1.D_E_L_E_T_ <> '*') AND (D1_FILIAL = '"+xFilial("SD1")+"') AND (D1_TIPO = 'D') AND ((F4_DUPLIC <> 'N') OR (D1_TES = '519')) AND  (D1_DTDIGIT BETWEEN ('"+dTos(MV_PAR01)+"') AND ('"+dTos(MV_PAR02)+"')) "
cQuery +="GROUP BY F2_VEND1,A3_NOME,A1_SATIV2) "
cQuery +="SELECT F2_VEND1,A3_NOME,VOLUME,A1_SATIV2 "
cQuery +="FROM TMP "
cQuery +="GROUP BY F2_VEND1,A3_NOME,VOLUME,A1_SATIV2 "
cQuery +="ORDER BY F2_VEND1,A1_SATIV2 "
                                                                            
TCQUERY cQuery ALIAS "TCQ" NEW
dbselectarea("TCQ")

SetRegua(RECCOUNT()) 
Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
_nLin := 10
cAuxVol := 0
valorTotal := 0  
codVendedor := TCQ->F2_VEND1
cUfTotal := cMCTotal := cTotal := 0  
contTotal:=0
While !eof()
    if _nLin > 55                                                                    	
		@ _nLin,000 psay replicate("_",132)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
		_nLin := 09
	endif 
	@_nLin,000 psay TCQ->F2_VEND1
	@_nLin,008 psay SUBSTR(TCQ->A3_NOME,0,40)
	While TCQ->F2_VEND1 == codVendedor .AND. !eof()
		If 	TCQ->VOLUME > 0
			If ALLTRIM(TCQ->A1_SATIV2) == "UF"
				@_nLin,055 psay TRANSFORM(TCQ->VOLUME,"@E 999,999,999")  
				cUfTotal += TCQ->VOLUME
			ElseIf ALLTRIM(TCQ->A1_SATIV2) == "MC"
				@_nLin,075 psay TRANSFORM(TCQ->VOLUME,"@E 999,999,999")	 
				cMCTotal += TCQ->VOLUME
			ElseIf ALLTRIM(TCQ->A1_SATIV2) == "RE"                        
				@_nLin,095 psay TRANSFORM(TCQ->VOLUME,"@E 999,999,999")	
				cTotal += TCQ->VOLUME
			EndIf       
		EndIf
		valorTotal += TCQ->VOLUME
		dbSelectArea("TCQ")
    	dbSkip()	
	EndDo	
	@_nLin,115 psay TRANSFORM(valorTotal,"@E 999,999,999")		
	contTotal += valorTotal
	valorTotal := 0
	@_nLin++	
	codVendedor := TCQ->F2_VEND1
EndDo	                                                    	
@ _nLin,000 psay replicate("_",132) 
@_nLin++	
@ _nLin,055 psay TRANSFORM(cUfTotal,"@E 999,999,999")
@ _nLin,075 psay TRANSFORM(cMCTotal,"@E 999,999,999")
@ _nLin,095 psay TRANSFORM(cTotal,"@E 999,999,999")
@ _nLin,115 psay TRANSFORM(contTotal,"@E 999,999,999")
if _nLin > 55                                                                    	
	@ _nLin,000 psay replicate("_",132)
	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
	_nLin := 10  
endif 
	@ _nLin,000 psay replicate("_",132) 
	@ _nLin++
	@ _nLin,060 psay Transform(cAuxVol,"@E 999,999,99999")
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

//Texto do help em portugues,ingles, espanhol
AAdd(aHelp, {{"de Periodo"  },  {""}, {""}})
AAdd(aHelp, {{"ate Periodo" },  {""}, {""}})
AAdd(aHelp, {{"de Vendedor" },  {""}, {""}})

//(<cGrupo>,<cOrdem>,<Pergunt>,< cPergSpa>,< cPergEng>,< cVar>,< cTipo>,< nTamanho>,[ nDecimal],[ nPreSel],<cGSC>,[cValid],[cF3],[cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil

PutSX1(cPerg,"01","Da emissao    ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"02","Ate a emissao ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","")
 
Return*/