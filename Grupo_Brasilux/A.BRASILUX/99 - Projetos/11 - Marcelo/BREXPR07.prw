#include 'protheus.ch'
#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function BREXPR07()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE CbTxt
PRIVATE Titulo := "Faturado x Coletado"
PRIVATE cDesc1:=""
PRIVATE cDesc2:=""
PRIVATE cDesc3 := "" 
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
PRIVATE nomeprog:= "BREXPR07"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   := "BREXPR07"
Private Total := 0  
Private xFlag := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	
//CriaSX1(cPerg)  //LGS#20200210 - Adequação de release 12.1.25 e posteriores
Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:= "BREXPR07"            //Nome Default do relatorio em Disco

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
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        
cQuery :="WITH TMPLOG AS (SELECT DISTINCT ZZB.R_E_C_N_O_ AS REG,ZZB_PEDIDO,ZZB_DATLOG,ZZB_HORLOG "
cQuery +="FROM "+RetSqlName("ZZB")+" ZZB WITH (NOLOCK) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON (SC6.D_E_L_E_T_ <> '*') AND (C6_FILIAL = '"+xFilial("SC6")+"') AND (LEN(C6_PRODUTO) = 12) AND (C6_NUM = ZZB_PEDIDO)) "
cQuery +="WHERE (ZZB_FILIAL = '"+xFilial("ZZB")+"') AND (ZZB_IDLOG IN ('AOU', 'APR')) AND (ZZB_DATLOG BETWEEN ('"+dTos(MV_PAR01)+"') AND ('"+dTos(MV_PAR02)+"')) AND (SC6.R_E_C_N_O_  IS NOT NULL)), "
cQuery +="TMP AS (SELECT DISTINCT ZZB_PEDIDO AS PEDIDO,ZZ0_DTCOLE,F2_EMISSAO,F2_HORA,REGZB = ISNULL((SELECT TOP 1 REG FROM TMPLOG WHERE (ZZB_PEDIDO = SF2.F2_PEDIDO) ORDER BY ZZB_DATLOG,ZZB_HORLOG),0) "
cQuery +="FROM TMPLOG "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = '"+xFilial("SF2")+"') AND (F2_PEDIDO = ZZB_PEDIDO) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = '"+xFilial("SC5")+"') AND (C5_NUM = ZZB_PEDIDO) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("ZZ0")+" ZZ0 WITH (NOLOCK) ON (ZZ0.D_E_L_E_T_ <> '*') AND (ZZ0_FILIAL = ZZ0) AND (C5_NUM = ZZ0_PEDIDO) "
cQuery +="WHERE (SF2.R_E_C_N_O_ IS NOT NULL) AND (F2_DUPL > '') AND (C5_TIPO = 'N') AND (C5_PEDPROG = '') AND ZZ0_DTCOLE >'' AND (F2_TRANSP = '00700' OR F2_TRANSP = '00573')) "
cQuery +="SELECT DATEDIFF(MINUTE,CONVERT(DATETIME,SUBSTRING(ZZB_DATLOG,1,4)+'-'+SUBSTRING(ZZB_DATLOG,5,2)+'-'+SUBSTRING(ZZB_DATLOG,7,2)+' '+SUBSTRING(ZZB_HORLOG,1,2)+':'+SUBSTRING(ZZB_HORLOG,4,2),102),CONVERT(DATETIME,SUBSTRING(ZZ0_DTCOLE,1,4)+'-'+SUBSTRING(ZZ0_DTCOLE,5,2)+'-'+SUBSTRING(ZZ0_DTCOLE,7,2)+' '+'23:59',102)) AS TEMPO, "
cQuery +="ZZB_DATLOG AS DTINI, ZZB_HORLOG AS HRINI, F2_EMISSAO AS DTFIM, F2_HORA AS HRFIM, PEDIDO "
cQuery +="FROM TMP "
cQuery +="LEFT OUTER JOIN "+RetSqlName("ZZB")+" ZZB WITH (NOLOCK) ON (ZZB.R_E_C_N_O_ = TMP.REGZB) ORDER BY PEDIDO"

TCQUERY cQuery ALIAS "TCQ" NEW
dbselectarea("TCQ")

cQuery1 :="WITH TMPLOG AS (SELECT DISTINCT ZZB.R_E_C_N_O_ AS REG,ZZB_PEDIDO,ZZB_DATLOG,ZZB_HORLOG "
cQuery1 +="FROM "+RetSqlName("ZZB")+" ZZB WITH (NOLOCK) "
cQuery1 +="LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON (SC6.D_E_L_E_T_ <> '*') AND (C6_FILIAL = '"+xFilial("SC6")+"') AND (LEN(C6_PRODUTO) = 12) AND (C6_NUM = ZZB_PEDIDO)) "
cQuery1 +="WHERE (ZZB_FILIAL = '"+xFilial("ZZB")+"') AND (ZZB_IDLOG IN ('AOU', 'APR')) AND (ZZB_DATLOG BETWEEN ('"+dTos(MV_PAR01)+"') AND ('"+dTos(MV_PAR02)+"')) AND (SC6.R_E_C_N_O_  IS NOT NULL)), "
cQuery1 +="TMP AS (SELECT DISTINCT ZZB_PEDIDO AS PEDIDO,ZZ0_DTCOLE,F2_EMISSAO,F2_HORA,REGZB = ISNULL((SELECT TOP 1 REG FROM TMPLOG WHERE (ZZB_PEDIDO = SF2.F2_PEDIDO) ORDER BY ZZB_DATLOG,ZZB_HORLOG),0) "
cQuery1 +="FROM TMPLOG "
cQuery1 +="LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = '"+xFilial("SF2")+"') AND (F2_PEDIDO = ZZB_PEDIDO) "
cQuery1 +="LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = '"+xFilial("SC5")+"') AND (C5_NUM = ZZB_PEDIDO) "
cQuery1 +="LEFT OUTER JOIN "+RetSqlName("ZZ0")+" ZZ0 WITH (NOLOCK) ON (ZZ0.D_E_L_E_T_ <> '*') AND (ZZ0_FILIAL = ZZ0) AND (C5_NUM = ZZ0_PEDIDO) "
cQuery1 +="WHERE (SF2.R_E_C_N_O_ IS NOT NULL) AND (F2_DUPL > '') AND (C5_TIPO = 'N') AND (C5_PEDPROG = '') AND ZZ0_DTCOLE >'' AND (F2_TRANSP <> '00700' AND F2_TRANSP <> '00573')) "
cQuery1 +="SELECT DATEDIFF(MINUTE,CONVERT(DATETIME,SUBSTRING(ZZB_DATLOG,1,4)+'-'+SUBSTRING(ZZB_DATLOG,5,2)+'-'+SUBSTRING(ZZB_DATLOG,7,2)+' '+SUBSTRING(ZZB_HORLOG,1,2)+':'+SUBSTRING(ZZB_HORLOG,4,2),102),CONVERT(DATETIME,SUBSTRING(ZZ0_DTCOLE,1,4)+'-'+SUBSTRING(ZZ0_DTCOLE,5,2)+'-'+SUBSTRING(ZZ0_DTCOLE,7,2)+' '+'23:59',102)) AS TEMPO, "
cQuery1 +="ZZB_DATLOG AS DTINI, ZZB_HORLOG AS HRINI, F2_EMISSAO AS DTFIM, F2_HORA AS HRFIM, PEDIDO "
cQuery1 +="FROM TMP "
cQuery1 +="LEFT OUTER JOIN "+RetSqlName("ZZB")+" ZZB WITH (NOLOCK) ON (ZZB.R_E_C_N_O_ = TMP.REGZB) ORDER BY PEDIDO"

TCQUERY cQuery1 ALIAS "TCQ1" NEW  
dbselectarea("TCQ1")

SetRegua(RECCOUNT()) 
Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
_nLin := 07
cTempoS := TCQ->TEMPO
cCountS :=1
cCountR :=1
cTempoR := TCQ1->TEMPO            

While !Eof()                                                           	
   	dbselectarea("TCQ")	 
	dbskip() 
	xFlag := 0
	CalcTemp()
	cTempoS += Total
	cCountS +=1
EndDo
dbselectarea("TCQ1")
While !Eof()                 	                                                                         
   	dbselectarea("TCQ1")	 
	dbskip()  
	xFlag := 1 
	CalcTemp()                                                                        	
	cTempoR += Total
	cCountR +=1
EndDo                	                                                                         
@ _nLin,023 psay "Periodo de "+Substr(dtos(MV_PAR01),7,2)+"/"+Substr(dtos(MV_PAR01),5,2)+"/"+Substr(dtos(MV_PAR01),5,2)+" até "+Substr(dtos(MV_PAR02),7,2)+"/"+Substr(dtos(MV_PAR02),5,2)+"/"+Substr(dtos(MV_PAR02),5,2)
@ _nLin++     
@ _nLin,000 psay "São Paulo"
@ _nLin++     
@ _nLin,000 psay "Total Minutos:"
@ _nLin,017 psay Transform(cTempoS,"@E 999999999") 
@ _nLin++     
@ _nLin,000 psay "Media Minutos:"
@ _nLin,017 psay Transform(cTempoS/cCountS,"@E 999999999") 
@ _nLin++     
@ _nLin,000 psay "Media Horas:"
@ _nLin,017 psay Transform((cTempoS/cCountS)/60,"@E 999999999")    
@ _nLin++     
@_nLin,000 psay replicate("_",80) 
@ _nLin++     
@ _nLin,000 psay "Região"              
@ _nLin++     
@ _nLin,000 psay "Total Minutos:"
@ _nLin,017 psay Transform(cTempoR,"@E 999999999") 
@ _nLin++     
@ _nLin,000 psay "Media Minutos:"
@ _nLin,017 psay Transform(cTempoR/cCountR,"@E 999999999")                                       	
@ _nLin++     
@ _nLin,000 psay "Media Horas:"
@ _nLin,017 psay Transform((cTempoR/cCountR)/60,"@E 999999999")    
@ _nLin++     
@_nLin,000 psay replicate("_",80)        
@ _nLin++     

dbSelectArea("TCQ")
dbCloseArea( )     

dbSelectArea("TCQ1")
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
AAdd(aHelp, {{"de Periodo"},  {""}, {""}})
AAdd(aHelp, {{"ate Periodo"},  {""}, {""}})

//(<cGrupo>,<cOrdem>,<Pergunt>,< cPergSpa>,< cPergEng>,< cVar>,< cTipo>,< nTamanho>,[ nDecimal],[ nPreSel],<cGSC>,[ cValid], [ cF3], [ cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil
PutSX1(cPerg,"01","de Periodo: " ,"","","mv_ch1","D",8,00,00,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
PutSX1(cPerg,"02","ate Periodo: " ,"","","mv_ch2","D",8,00,00,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")
Return*/

Static Function CalcTemp()
       Local i, dtInicial, dtFinal, hrIni, hrFim, xflag
  if xflag == 0                                                                                                    
  	dtInicial := TCQ->DTINI
  	dtFinal := TCQ->DTFIM
  	hrIni := TCQ->HRINI
  	hrFim := TCQ->HRFIM
  Else
  	dtInicial := TCQ1->DTINI
  	dtFinal := TCQ1->DTFIM
  	hrIni := TCQ1->HRINI
  	hrFim := TCQ1->HRFIM
  EndIf
  dtInicial := substr(dtInicial,7,2)+'/'+substr(dtInicial,5,2)+'/'+substr(dtInicial,1,4)
  dtInicial := ctod(dtInicial)
  dtFinal := substr(dtFinal,7,2)+'/'+substr(dtFinal,5,2)+'/'+substr(dtFinal,1,4)
  dtFinal := ctod(dtFinal)
  AuxHora:=0
  AuxMin:= 0
  iAuxMinIni := transform(substr(hrIni,4,2),"@E99")	
  iAuxMinFim := transform(substr(hrFim,4,2),"@E99")
  iAuxMin := val(iAuxMinIni) +  val(iAuxMinFim) 
  TransfHora := (Val(Transform(substr(hrIni,1,2),"@E 99")) - Val(Transform(substr(hrFim,1,2),"@E 99")))
  If TransfHora < 0
  	TransfHora := TransfHora * (-1)
  EndIf  		 
  dtotalDias := 0
  for i = datavalida(dtInicial) to dtFinal
    if datavalida(i) > i
    	i+= datavalida(i) - i
    endif
  	dtotalDias ++ 
  Next   
  dtotalDias:= dtotalDias-2
  If iAuxMin > 60
  	iAuxMin := val(iAuxMinIni) -  val(iAuxMinFim) 
  	TransfHora += 1
  	If iAuxMin < 0 
  		iAuxMin := iAuxMin * (-1)
	EndIf
  EndIf	  
  If (substr(hrIni,1,2) < substr(hrFim,1,2)) 
  	 	If  dtInicial != dtFinal  
  		AuxHora := TransfHora + 24
  	Else 
  		//TransfHora //???????????????????????
  	EndIf
  Else                                                    
  	AuxHora := 24 - TransfHora
  EndIf     
  iif(dtotalDias>=1,calcH:=((dtotalDias*24)*60),calcH := 0)
  AuxMin += (AuxHora * 60) + (iAuxMin) 
  Total := AuxMin + calcH
 Return(Total)