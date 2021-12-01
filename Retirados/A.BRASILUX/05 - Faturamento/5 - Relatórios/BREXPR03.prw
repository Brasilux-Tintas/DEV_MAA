#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function BREXPR03()
//UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA¢¯
//©ø Define Variaveis                                             ©ø
//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAU
PRIVATE CbTxt
PRIVATE Titulo := "Relatorio de tempo de rotatividade do pedido"
PRIVATE cDesc1:=""
PRIVATE cDesc2:=""
PRIVATE cDesc3 := "" 
                   //   0          1           2         3         4         5         6       7          8        9        10         11        12       13        14         15         16
                   //012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
PRIVATE cCabec1  := "Pedido  Cliente                                   Data ini  Data Fim  Total Tempo"
PRIVATE cCabec2  := ""
private nTipo := 18
PRIVATE Tamanho:= "P"
PRIVATE Limite := 80
PRIVATE cString:= "SA1"
private m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:= "BREXPR03"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   := "BREXPR03"

//UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA¢¯
//©ø Verifica as perguntas selecionadas                           ©ø
//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAU
    
//CriaSX1(cPerg)
Pergunte(cPerg,.F.)
//UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA¢¯
//©ø Envia controle para a funcao SETPRINT                        ©ø
//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAU

wnrel:= "BREXPR03"            //Nome Default do relatorio em Disco

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

//UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA¢¯
//©ø Inicio do Processamento do Relatorio                         ©ø
//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAU

RptStatus({|| RptDetail()})

return

/////////////////////////////////////////////////////////
// Funcao....: RPTDETAIL    Data....: 08/06/15         //
// Autor.....: Marcelo J. A. de Paiva                  //
/////////////////////////////////////////////////////////

Static Function RptDetail()
//Local nTotal := 0
//Local 	_nCont := 0
//Local lNormal
Local cQuery  :=""
Private _nLin := 7

//UAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA¢¯
//©ø Inicializa  regua de impressao                            ©ø
//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAU

cQuery :="SELECT DATEDIFF(MINUTE,CONVERT(DATETIME,SUBSTRING(ZZB_DATLOG,1,4)+'-'+SUBSTRING(ZZB_DATLOG,5,2)+'-'+SUBSTRING(ZZB_DATLOG,7,2)+' '+SUBSTRING(ZZB_HORLOG,1,2)+':'+SUBSTRING(ZZB_HORLOG,4,2),102),CONVERT(DATETIME,SUBSTRING(F2_EMISSAO,1,4)+'-'+SUBSTRING(F2_EMISSAO,5,2)+'-'+SUBSTRING(F2_EMISSAO,7,2)+' '+SUBSTRING(F2_HORA,1,2)+':'+SUBSTRING(F2_HORA,4,2),102)) AS TEMPO, "
cQuery +="ZZB_DATLOG AS DTINI, ZZB_HORLOG AS HRINI, F2_EMISSAO AS DTFIM, F2_HORA AS HRFIM, F2_PEDIDO AS PEDIDO, F2_RAZAO AS CLIENTE "
cQuery +="FROM "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = F2_FILIAL) AND (C5_NUM = F2_PEDIDO) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH (NOLOCK) ON (SZG.D_E_L_E_T_ <> '*') AND (ZG_FILIAL = F2_FILIAL) AND SUBSTRING(ZG_PEDIDO,3,6) = C5_NUM "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SZF")+" SZF WITH (NOLOCK) ON (SZF.D_E_L_E_T_ <> '*') AND (ZF_FILIAL = F2_FILIAL) AND (ZG_CODIGO = ZF_CODIGO) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("ZZB")+" ZZB WITH (NOLOCK) ON (ZZB.D_E_L_E_T_ <> '*') AND (ZF_FILIAL = F2_FILIAL) AND (ZZB_PEDIDO = C5_NUM) " 
cQuery +="WHERE F2_FILIAL = '"+xFilial("SF2")+"' AND (ZF_EMISSAO BETWEEN ('"+dTos(MV_PAR01)+"') AND ('"+dTos(MV_PAR02)+"'))  AND C5_PEDPROG = '' AND ZZB_IDLOG = 'IAU' "
cQuery +="ORDER BY F2_PEDIDO"

TCQUERY cQuery ALIAS "TCQ" NEW
dbselectarea("TCQ")

cQuery1 :="SELECT DATEDIFF(MINUTE,CONVERT(DATETIME,SUBSTRING(ZZB_DATLOG,1,4)+'-'+SUBSTRING(ZZB_DATLOG,5,2)+'-'+SUBSTRING(ZZB_DATLOG,7,2)+' '+SUBSTRING(ZZB_HORLOG,1,2)+':'+SUBSTRING(ZZB_HORLOG,4,2),102),CONVERT(DATETIME,SUBSTRING(F2_EMISSAO,1,4)+'-'+SUBSTRING(F2_EMISSAO,5,2)+'-'+SUBSTRING(F2_EMISSAO,7,2)+' '+SUBSTRING(F2_HORA,1,2)+':'+SUBSTRING(F2_HORA,4,2),102)) AS TEMPO, "
cQuery1 +="ZZB_DATLOG AS DTINI, ZZB_HORLOG AS HRINI, F2_EMISSAO AS DTFIM, F2_HORA AS HRFIM, F2_PEDIDO AS PEDIDO, F2_RAZAO AS CLIENTE "
cQuery1 +="FROM "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) "
cQuery1 +="LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = F2_FILIAL) AND (C5_NUM = F2_PEDIDO) "
cQuery1 +="LEFT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH (NOLOCK) ON (SZG.D_E_L_E_T_ <> '*') AND (ZG_FILIAL = F2_FILIAL) AND SUBSTRING(ZG_PEDIDO,3,6) = C5_NUM "
cQuery1 +="LEFT OUTER JOIN "+RetSqlName("SZF")+" SZF WITH (NOLOCK) ON (SZF.D_E_L_E_T_ <> '*') AND (ZF_FILIAL = F2_FILIAL) AND (ZG_CODIGO = ZF_CODIGO) "
cQuery1 +="LEFT OUTER JOIN "+RetSqlName("ZZB")+" ZZB WITH (NOLOCK) ON (ZZB.D_E_L_E_T_ <> '*') AND (ZF_FILIAL = F2_FILIAL) AND (ZZB_PEDIDO = C5_NUM) " 
cQuery1 +="WHERE F2_FILIAL = '"+xFilial("SF2")+"' AND (ZF_EMISSAO BETWEEN ('"+dTos(MV_PAR01)+"') AND ('"+dTos(MV_PAR02)+"'))  AND C5_PEDPROG = '' AND ZZB_IDLOG = 'IAU' AND F2_TRANSP <> '00700' "
cQuery1 +="ORDER BY F2_PEDIDO"

TCQUERY cQuery1 ALIAS "TCQ1" NEW  
dbselectarea("TCQ1")

SetRegua(RECCOUNT()) 
Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
_nLin := 08

If !Empty(MV_PAR04) .AND. VAL(MV_PAR04) > VAL(Transform(((TCQ->TEMPO / 60)/24),"@E  99.999"))
	cTempoS := TCQ->TEMPO
	cCountS :=1 
	cTempoR := TCQ1->TEMPO
	cCountR :=1
ElseIf Empty(MV_PAR04)
	cTempoS := TCQ->TEMPO
	cCountS :=1 
	cTempoR := TCQ1->TEMPO
	cCountR :=1
EndIf

If MV_PAR03 = 1
	While !Eof()     
		if _nLin > 55                                                                    	
			@ _nLin,000 psay replicate("_",80)
			Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
			_nLin := 08
		endif          
		If MV_PAR05 = 1 
			If !Empty(MV_PAR04) .AND. VAL(MV_PAR04) < VAL(Transform(((TCQ->TEMPO / 60)/24),"@E  99.999"))
				@_nLin,000 psay TCQ->PEDIDO
				@_nLin,008 psay SUBSTR(TCQ->CLIENTE,0,40)    
				@_nLin,050 psay SUBSTR(TCQ->DTINI,7,2)+"/"+SUBSTR(TCQ->DTINI,5,2)+"/"+SUBSTR(TCQ->DTINI,3,2)
				@_nLin,060 psay SUBSTR(TCQ->DTFIM,7,2)+"/"+SUBSTR(TCQ->DTFIM,5,2)+"/"+SUBSTR(TCQ->DTFIM,3,2)
				@_nLin,070 psay TCQ->TEMPO
				@_nLin++
			Endif
		Else
			If !Empty(MV_PAR04) .AND. VAL(MV_PAR04) > VAL(Transform(((TCQ->TEMPO / 60)/24),"@E  99.999"))
				@_nLin,000 psay TCQ->PEDIDO
				@_nLin,008 psay SUBSTR(TCQ->CLIENTE,0,40)    
				@_nLin,050 psay SUBSTR(TCQ->DTINI,7,2)+"/"+SUBSTR(TCQ->DTINI,5,2)+"/"+SUBSTR(TCQ->DTINI,3,2)
				@_nLin,060 psay SUBSTR(TCQ->DTFIM,7,2)+"/"+SUBSTR(TCQ->DTFIM,5,2)+"/"+SUBSTR(TCQ->DTFIM,3,2)
				@_nLin,070 psay TCQ->TEMPO
				@_nLin++
			Endif
		EndIf
		If	Empty(MV_PAR04)
			@_nLin,000 psay TCQ->PEDIDO
			@_nLin,008 psay SUBSTR(TCQ->CLIENTE,0,40)    
			@_nLin,050 psay SUBSTR(TCQ->DTINI,7,2)+"/"+SUBSTR(TCQ->DTINI,5,2)+"/"+SUBSTR(TCQ->DTINI,3,2)
			@_nLin,060 psay SUBSTR(TCQ->DTFIM,7,2)+"/"+SUBSTR(TCQ->DTFIM,5,2)+"/"+SUBSTR(TCQ->DTFIM,3,2)
			@_nLin,070 psay TCQ->TEMPO
			@_nLin++
		EndIf       
		dbselectarea("TCQ")	 
		dbskip()
		If !Empty(MV_PAR04) .AND. VAL(MV_PAR04) > VAL(Transform(((TCQ->TEMPO / 60)/24),"@E  99.999"))  
			cTempoS += TCQ->TEMPO 
			cCountS +=1
		ElseIf Empty(MV_PAR04)
			cTempoS += TCQ->TEMPO 
			cCountS +=1		
		EndIf
	EndDo  
@_nLin,000 psay replicate("_",80)
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
ElseIf MV_PAR03 = 2
	dbselectarea("TCQ1")
	While !Eof()     
		if _nLin > 55                                                                    	
			@ _nLin,000 psay replicate("_",80)
			Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
			_nLin := 08
		endif          
		If MV_PAR05 = 1 
			If !Empty(MV_PAR04) .AND. VAL(MV_PAR04) < VAL(Transform(((TCQ1->TEMPO / 60)/24),"@E  99.999"))
				@_nLin,000 psay TCQ1->PEDIDO
				@_nLin,008 psay SUBSTR(TCQ1->CLIENTE,0,40)    
				@_nLin,050 psay SUBSTR(TCQ1->DTINI,7,2)+"/"+SUBSTR(TCQ1->DTINI,5,2)+"/"+SUBSTR(TCQ1->DTINI,3,2)
				@_nLin,060 psay SUBSTR(TCQ1->DTFIM,7,2)+"/"+SUBSTR(TCQ1->DTFIM,5,2)+"/"+SUBSTR(TCQ1->DTFIM,3,2)
				@_nLin,070 psay TCQ1->TEMPO
				@_nLin++
			Endif
		Else
			If !Empty(MV_PAR04) .AND. VAL(MV_PAR04) > VAL(Transform(((TCQ1->TEMPO / 60)/24),"@E  99.999"))
				@_nLin,000 psay TCQ1->PEDIDO
				@_nLin,008 psay SUBSTR(TCQ1->CLIENTE,0,40)    
				@_nLin,050 psay SUBSTR(TCQ1->DTINI,7,2)+"/"+SUBSTR(TCQ1->DTINI,5,2)+"/"+SUBSTR(TCQ1->DTINI,3,2)
				@_nLin,060 psay SUBSTR(TCQ1->DTFIM,7,2)+"/"+SUBSTR(TCQ1->DTFIM,5,2)+"/"+SUBSTR(TCQ1->DTFIM,3,2)
				@_nLin,070 psay TCQ1->TEMPO
				@_nLin++
			Endif
		EndIf
		If	Empty(MV_PAR04)
			@_nLin,000 psay TCQ1->PEDIDO
			@_nLin,008 psay SUBSTR(TCQ1->CLIENTE,0,40)    
			@_nLin,050 psay SUBSTR(TCQ1->DTINI,7,2)+"/"+SUBSTR(TCQ1->DTINI,5,2)+"/"+SUBSTR(TCQ1->DTINI,3,2)
			@_nLin,060 psay SUBSTR(TCQ1->DTFIM,7,2)+"/"+SUBSTR(TCQ1->DTFIM,5,2)+"/"+SUBSTR(TCQ1->DTFIM,3,2)
			@_nLin,070 psay TCQ1->TEMPO
			@_nLin++
		EndIf       
		dbselectarea("TCQ1")	 
		dbskip()
		If !Empty(MV_PAR04) .AND. VAL(MV_PAR04) > VAL(Transform(((TCQ1->TEMPO / 60)/24),"@E  99.999"))  
			cTempoR += TCQ1->TEMPO 
			cCountR +=1
		ElseIf Empty(MV_PAR04)
			cTempoR += TCQ1->TEMPO 
			cCountR +=1		
		EndIf
	EndDo  
@_nLin,000 psay replicate("_",80)
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
EndIf	    

dbSelectArea("TCQ")
dbCloseArea()     

dbSelectArea("TCQ1")
dbCloseArea()
Set Device To Screen
If aReturn[5] == 1
   Set Printer TO
   dbcommitAll()
   ourspool(wnrel)
Endif
Return

/* release 12.1.25
Static Function CriaSX1(cPerg)	

Local aHelp := {}
//Texto do help em portugues  ,     ingles, espanhol
AAdd(aHelp, {{"de Periodo"},  {""}, {""}})
AAdd(aHelp, {{"ate Periodo"},  {""}, {""}})
AAdd(aHelp, {{"Selecionar destino dos pedidos"},  {""}, {""}})
AAdd(aHelp, {{"Quantidade de dias parado, deixar em branco para puxar todos os pedidos"},  {""}, {""}})
AAdd(aHelp, {{"Maior que, ou menor que a quantidade de dias parados"},  {""}, {""}})

//(<cGrupo>,<cOrdem>,<Pergunt>,< cPergSpa>,< cPergEng>,< cVar>,< cTipo>,< nTamanho>,[ nDecimal],[ nPreSel],<cGSC>,[ cValid], [ cF3], [ cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil
PutSX1(cPerg,"01","de Periodo: " ,"","","mv_ch1","D",8,00,00,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
PutSX1(cPerg,"02","ate Periodo: " ,"","","mv_ch2","D",8,00,00,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")
PutSX1(cPerg,"03","Rota: " ,"","","mv_ch3","N",1,00,00,"C","","","","","MV_PAR03","Sao Paulo","","","","Regiao","","","","","","","","","","","",aHelp[3,1],aHelp[3,2],aHelp[3,3],"")
PutSX1(cPerg,"04","Dias: " ,"","","mv_ch4","C",2,00,00,"G","","","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelp[4,1],aHelp[4,2],aHelp[4,3],"")
PutSX1(cPerg,"05","Tipo consulta" ,"","","mv_ch5","N",1,00,00,"C","","","","","MV_PAR05","Maior","","","","Menor","","","","","","","","","","","",aHelp[5,1],aHelp[5,2],aHelp[5,3],"")
Return
/*