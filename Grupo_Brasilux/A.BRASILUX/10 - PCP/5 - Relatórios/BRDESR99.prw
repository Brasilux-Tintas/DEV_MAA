#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"  


User Function BRDESR99()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE CbTxt
PRIVATE Titulo := ""
PRIVATE cDesc1:=""
PRIVATE cDesc2:=""
PRIVATE cDesc3 := "" 
                   //   0          1           2         3         4         5         6       7          8        9        10         11        12       13        14         15         16
                   //012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
PRIVATE cCabec1  := "Bordero      Cliente"
PRIVATE cCabec2  := ""  
private nTipo := 18
PRIVATE Tamanho:= "P"
PRIVATE Limite := 80
PRIVATE cString:= "SA1"
private m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:= "BRDESR99"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   := "BRDESR99"
     u_zcfga01( 'BRDESR99' ) //LGS#2021201 - Gravação de log de utilização da rotina
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
//CriaSX1(cPerg)  //LGS#20200131 - Adequação de release 12.1.25 e posteriores
Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:= "BRDESR99"            //Nome Default do relatorio em Disco

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
//Local 	_nCont := 0
//Local lNormal
Private _nLin := 7

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cQuery :=" WITH TMP AS(SELECT C6_FILIAL, ZB_CODIGO, C6_NUM, C6_PRODUTO, C6_QTDVEN, C6_CLI, ISNULL(SUM(ZZK_QUANT),0) AS ZZK_QUANT, COUNT(ZZK_PRODUT) AS COUNTZZK, CASE WHEN LEN(C6_PRODUTO)<12 THEN 1 ELSE 0 END AS 'COUNTPRODMENOR', "
cQuery +=" CASE WHEN LEN(C6_PRODUTO)< 12 THEN C6_QTDVEN ELSE 0 END AS 'SUMPRODMENOR' "
cQuery +=" FROM "+RetSqlName("SZB")+" SZB WITH (NOLOCK) " 
cQuery +=" LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON C6_FILIAL = ZB_FILIAL AND C6_NUM = SUBSTRING(ZB_PEDIDO,3,6) AND SC6.D_E_L_E_T_ ='' "
cQuery +=" LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) ON ZZK_FILIAL = C6_FILIAL AND ZZK_PEDIDO = C6_NUM AND C6_PRODUTO = ZZK_PRODUT AND ZZK.D_E_L_E_T_ ='' "
cQuery +=" WHERE ZB_CODIGO ='"+MV_PAR01+"' " 
cQuery +=" AND SZB.D_E_L_E_T_ ='' "
cQuery +=" AND ZB_FILIAL = '"+xFilial("SD2")+"' "
If MV_PAR02 == 1
	cQuery +=	" AND SUBSTRING(C6_PRODUTO,1,5) <> 'ST 55' "
EndIF
If MV_PAR04 == 1
	cQuery +=	" AND LEN(C6_PRODUTO) = 12   "
Endif   
cQuery +=" GROUP BY C6_FILIAL, ZB_CODIGO, C6_NUM, C6_QTDVEN, C6_PRODUTO, C6_CLI) "
cQuery +=" SELECT TMP.C6_NUM, A1_NOME, COUNT(SC6.C6_PRODUTO) AS 'TOTAL', SUM(TMP.COUNTPRODMENOR) AS 'PROD MENOR 12 DIG', SUM(TMP.SUMPRODMENOR) AS 'TOTAL MENOR QUE 12', SUM(TMP.C6_QTDVEN) AS 'TOTAL PED', SUM(ZZK_QUANT) AS 'TOTAL BIP' "
cQuery +=" FROM TMP "
cQuery +=" LEFT OUTER JOIN SA1010 SA1 WITH(NOLOCK) ON A1_FILIAL = A1_FILIAL AND A1_COD = C6_CLI AND SA1.D_E_L_E_T_ ='' "
cQuery +=" LEFT OUTER JOIN SC6010 SC6 WITH(NOLOCK) ON SC6.C6_FILIAL = TMP.C6_FILIAL AND SC6.C6_NUM = TMP.C6_NUM AND SC6.C6_PRODUTO = TMP.C6_PRODUTO AND SC6.D_E_L_E_T_ ='' "
cQuery +=" GROUP BY TMP.C6_NUM, A1_NOME "
If MV_PAR03 == 2
	cQuery +=" HAVING (SUM(TMP.C6_QTDVEN) - ISNULL(SUM(ZZK_QUANT),0)) <> 0 AND (SUM(TMP.COUNTPRODMENOR) <> COUNT(SC6.C6_PRODUTO)) "
ELSE 
	//cQuery +=" HAVING (SUM(TMP.C6_QTDVEN) - ISNULL(SUM(ZZK_QUANT),0)) = 0 OR (SUM(TMP.COUNTPRODMENOR) = COUNT(SC6.C6_PRODUTO)) "
	cQuery +=" HAVING (SUM(TMP.C6_QTDVEN) - ISNULL(SUM(ZZK_QUANT),0)) = 0 OR  (SUM(TMP.C6_QTDVEN) - SUM(TMP.SUMPRODMENOR) = ISNULL(SUM(ZZK_QUANT),0)) "
EndIF    
cQuery +=" ORDER BY TMP.C6_NUM "

TCQUERY cQuery ALIAS "TCQ" NEW
dbselectarea("TCQ")

SetRegua(RECCOUNT())   
If MV_PAR03 = 2
	titulo := "Pedidos Incompletos"
Else                               
	titulo := "Pedidos Completos"
EndIf
Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)                       
_nLin := 08                                                                                             
cAuxVol := 0
While !Eof()
	if _nLin > 55                                                                    	
		@ _nLin,000 psay replicate("_",80)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
		_nLin := 08
	endif 
	@ _nLin,000 psay TCQ->C6_NUM
  	@ _nLin,013 psay TCQ->A1_NOME
	@ _nLin++
	dbselectarea("TCQ")	 
	dbskip() 
EndDo  
	dbSelectArea("TCQ")
    dbCloseArea()
Set Device To Screen
If aReturn[5] == 1
   Set Printer TO
   dbcommitAll()
   ourspool(wnrel)
Endif
Return

//LGS#20200131 - Adequação de release 12.1.25 e posteriores
/*
Static Function CriaSX1(cPerg)	

Local aHelp := {}

//Texto do help em portugues  ,     ingles, espanhol
AAdd(aHelp, {{"Numero de Bordero"}					,  {""}, {""}})
AAdd(aHelp, {{"Filtrar Spray?"}   					,  {""}, {""}})
AAdd(aHelp, {{"Tipo de pedido"}   					,  {""}, {""}})
AAdd(aHelp, {{"Considera só Produtos 12 Digitos"}   ,  {""}, {""}})

//(<cGrupo>,<cOrdem>,<Pergunt>,< cPergSpa>,< cPergEng>,< cVar>,< cTipo>,< nTamanho>,[ nDecimal],[ nPreSel],<cGSC>,[ cValid], [ cF3], [ cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil
PutSX1(cPerg,"01","Bordero Despacho               " ,"","","mv_ch1","C",6,00,00,"G","","","","","MV_PAR01",""         ,"","","",""           ,"","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
PutSX1(cPerg,"02","Filtra Spray  ?                " ,"","","mv_ch2","N",1,00,00,"C","","","","","MV_PAR02","Sim"      ,"","","","Não"        ,"","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")
PutSX1(cPerg,"03","Tipo de Pedido                 " ,"","","mv_ch3","N",1,00,00,"C","","","","","MV_PAR03","Completos","","","","Incompletos","","","","","","","","","","","",aHelp[3,1],aHelp[3,2],aHelp[3,3],"")
PutSX1(cPerg,"04","Considera só Prod. 12 Digitos? " ,"","","mv_ch4","N",1,00,00,"C","","","","","MV_PAR04","Sim"      ,"","","","Não"        ,"","","","","","","","","","","",aHelp[4,1],aHelp[4,2],aHelp[4,3],"")

Return*/
