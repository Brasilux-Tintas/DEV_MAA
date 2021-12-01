#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function BREXPR01()
//UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA¢¯
//©ø Define Variaveis                                             ©ø
//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAU
PRIVATE CbTxt
PRIVATE Titulo := "Relatorio de SAC x REGIAO"
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
PRIVATE nomeprog:= "BREXPR01"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   := "BREXPR01"

//UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA¢¯
//©ø Verifica as perguntas selecionadas                           ©ø
//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAU
    
//CriaSX1(cPerg)
Pergunte(cPerg,.F.)                                                                            	
//UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA¢¯
//©ø Envia controle para a funcao SETPRINT                        ©ø
//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAU

wnrel:= "BREXPR01"            //Nome Default do relatorio em Disco

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

Local cQuery 	  := ""
Local cQuery1     := ""
Local cCount 	  := 0
Local cCountSampa := 0
Local cCountReg   := 0
Local cAuxTransp  := ""
Local cNum        := ""
Private _nLin     := 7

//UAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA¢¯
//©øInicializa  regua de impressao©ø
//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAU

cQuery :="SELECT ZQ_NUM, ZQ_CLIENTE, ZQ_DATA, F2_TRANSP, ZR_PRODUTO, A1_NOME "
cQuery +="FROM "+RetSqlName("SZQ")+" SZQ WITH (NOLOCK) "
cQuery +="LEFT OUTER JOIN  "+RetSqlName("SZS")+" SZS WITH (NOLOCK) ON (SZS.D_E_L_E_T_ <> '*') AND (ZS_FILIAL = ZQ_FILIAL) AND (ZQ_NUM = ZS_NUM) "
cQuery +="LEFT OUTER JOIN  "+RetSqlName("SZR")+" SZR WITH (NOLOCK) ON (SZR.D_E_L_E_T_ <> '*') AND (ZR_FILIAL = ZS_FILIAL) AND (ZQ_NUM = ZR_NUM) "
cQuery +="LEFT OUTER JOIN  "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = ZR_FILIAL) AND (F2_DOC = ZR_NUMNF) "
cQuery +="LEFT OUTER JOIN  "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (ZQ_CLIENTE = A1_COD) "
cQuery +="WHERE ZQ_FILIAL ='"+xFilial("SZQ")+"' AND ZQ_DATA BETWEEN ('"+dTos(MV_PAR01)+"') AND ('"+dTos(MV_PAR02)+"') AND SZR.D_E_L_E_T_ <> '*' AND ZR_ASSUNTO = '000003' "
cQuery +="ORDER BY ZQ_NUM "

TCQUERY cQuery ALIAS "TCQ" NEW
dbselectarea("TCQ")
                                                                  

Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)

_nLin := 07
cCount := cCountSampa := cCountReg := 0
cNum := TCQ->ZQ_NUM
cAuxTransp := TCQ->F2_TRANSP
	While !Eof()
	  	if Empty(cAuxTransp)
			cQuery1 :="SELECT  TOP 1 F2_CLIENTE, F2_TRANSP,  F2_EMISSAO "
			cQuery1 +="FROM SF2010  SF2 WITH (NOLOCK) "
			cQuery1 +="WHERE SF2.D_E_L_E_T_ <> '*' AND F2_FILIAL = '010101'  AND F2_CLIENT = ('"+TCQ->ZQ_CLIENTE+"') AND F2_TRANSP <> '' "
			cQuery1 +="ORDER BY  F2_EMISSAO DESC" 
						
			TCQUERY cQuery1 ALIAS "TCQ1" NEW
			dbselectarea("TCQ1")
			cAuxTransp := TCQ1->F2_TRANSP   
			dbSelectArea("TCQ1")
			dbCloseArea()	
		EndIf
		dbselectarea("TCQ")
		dbskip() 

		If cNum != TCQ->ZQ_NUM
		   	cCount += 1
		   	If Alltrim(cAuxTransp) == '00700'
				cCountSampa += 1
		   	Else
		   		cCountReg += 1
		   	endif
		   	cNum := TCQ->ZQ_NUM
		EndIf  
		cAuxTransp := TCQ->F2_TRANSP 		
	EndDo
@ _nLin,023 psay "Periodo de "+Substr(dtos(MV_PAR01),7,2)+"/"+Substr(dtos(MV_PAR01),5,2)+"/"+Substr(dtos(MV_PAR01),5,2)+" ate "+Substr(dtos(MV_PAR02),7,2)+"/"+Substr(dtos(MV_PAR02),5,2)+"/"+Substr(dtos(MV_PAR02),5,2)
@ _nLin++     
@ _nLin,000 psay "Total de SAC x Sao Paulo"
@ _nLin,060 psay Transform(cCountSampa,"@E 9999")   
@ _nLin++
@ _nLin,000 psay "Total de SAC x Regiao"
@ _nLin,060 psay Transform(cCountReg,"@E 9999") 
@ _nLin++
@ _nLin,000 psay replicate("_",80)
@ _nLin++
@ _nLin,000 psay "Total de SAC "
@ _nLin,060 psay Transform(cCount,"@E 9999") 

dbSelectArea("TCQ")
dbCloseArea()
Set Device To Screen
If aReturn[5] == 1
   Set Printer TO
   dbcommitAll()
   ourspool(wnrel)
Endif
Return

/* DESABILITADO PARA ADEQUAÇÃO DA RELEASE 12.1.25
Static Function CriaSX1(cPerg)	

Local aHelp := {}

//Texto do help em portugues  ,     ingles, espanhol
AAdd(aHelp, {{"Consultar por Sao Paulo ou Regiao"},  {""}, {""}})
AAdd(aHelp, {{"de Periodo"},  {""}, {""}})
AAdd(aHelp, {{"ate Periodo"},  {""}, {""}})

//(<cGrupo>,<cOrdem>,<Pergunt>,< cPergSpa>,< cPergEng>,< cVar>,< cTipo>,< nTamanho>,[ nDecimal],[ nPreSel],<cGSC>,[ cValid], [ cF3], [ cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil
PutSX1(cPerg,"01","de Periodo: " ,"","","mv_ch1","D",8,00,00,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
PutSX1(cPerg,"02","ate Periodo: " ,"","","mv_ch2","D",8,00,00,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")
Return
*/