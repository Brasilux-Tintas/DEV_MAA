#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function BREMPROD()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE CbTxt
PRIVATE Titulo := "Relatorio de empenho producao"
PRIVATE cDesc1:=""
PRIVATE cDesc2:=""
PRIVATE cDesc3 := "" 
                   //   0          1           2         3         4         5         6       7          8        9        10         11        12       13        14         15         16
                   //012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
PRIVATE cCabec1  := "                           Relatorio de empenho producao"
PRIVATE cCabec2  := "Codigo    Descricao                        Tipo   Local          Qtd.Atual     Qtd.Emp    Necessidade         Endereço"  
private nTipo := 18
PRIVATE Tamanho:= "M"
PRIVATE Limite := 132
PRIVATE cString:= "ZZL"
private m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:= "BREMPROD"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   := "BREMPROD"                                                                                  
                                                                                                               
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
//CriaSX1(cPerg)  //LGS#20200210 - Adequação de release 12.1.25 e posteriores
Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:= "BREMPROD"            //Nome Default do relatorio em Disco

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


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery :=""      


cQuery +=" SELECT B2_COD, B1_DESC, B1_TIPO, B2_LOCAL, B2_QATU, B2_QEMP, (B2_QEMP - B2_QATU) AS 'NECESSIDADE', "
cQuery +=" 'LOCALIZE' = ISNULL((SELECT MAX(ZZL_LOCALI) FROM "+RetSqlName("ZZL")+" ZZL WITH(NOLOCK) WHERE ZZL.D_E_L_E_T_ <> '*' AND ZZL_FILIAL = B1_FILIAL AND ZZL_PRODUT = B1_COD ),'')  "
cQuery +=" FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON B1_FILIAL = B2_FILIAL AND B1_COD = B2_COD AND SB1.D_E_L_E_T_ ='' "
cQuery +=" WHERE SB2.D_E_L_E_T_ ='' "
cQuery +=" AND B2_FILIAL = '"+xFilial("SB2")+"'" 
cQuery +=" AND (B2_QEMP - B2_QATU) > 0 "
cQuery +=" AND B2_LOCAL = '"+MV_PAR01+"'" 
cQuery +=" AND B1_TIPO BETWEEN '"+MV_PAR02+"'AND'"+MV_PAR03+"'"
If MV_PAR04 = 1
	cQuery +=" AND B2_COD NOT IN(SELECT DISTINCT(G1_COMP) FROM "+RetSqlName("SG1")+" WHERE G1_FILIAL = '"+xFilial("SG1")+"' AND D_E_L_E_T_ ='' AND SUBSTRING(G1_COD,4,2) IN('97','98','99') AND LEN(G1_COD)=12  )"
EndIf
cQuery +=" ORDER BY (B2_QEMP - B2_QATU) DESC, B2_COD "
                                                                            
TCQUERY cQuery ALIAS "TCQ" NEW
dbselectarea("TCQ")

SetRegua(RECCOUNT()) 
Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
_nLin := 09
While !Eof()
	@ _nLin,000 psay SUBSTR(TCQ->B2_COD,0,4)
  	@ _nLin,010 psay SUBSTR(TCQ->B1_DESC,0,30)
  	@ _nLin,045 psay TCQ->B1_TIPO
  	@ _nLin,052 psay TCQ->B2_LOCAL  	
	@ _nLin,059 psay Transform(TCQ->B2_QATU,"@E 99,999,999.99")
	@ _nLin,072 psay Transform(TCQ->B2_QEMP,"@E 99,999,999.99")
	@ _nLin,085 psay Transform(TCQ->NECESSIDADE,"@E 99,999,999.99")
  	@ _nLin,110 psay TCQ->LOCALIZE
		
	@ _nLin++
	dbselectarea("TCQ")	 
	dbskip() 
	if _nLin > 55
		@ _nLin,000 psay replicate("_",80)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
		_nLin := 09
	endif
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

//LGS#20200210 - Adequação de release 12.1.25 e posteriores
/*Static Function CriaSX1(cPerg)

Local aHelp := {}

//Texto do help em portugues,ingles, espanhol
AAdd(aHelp, {{"de Periodo"  },  {""}, {""}})
AAdd(aHelp, {{"ate Periodo" },  {""}, {""}})
AAdd(aHelp, {{"de Vendedor" },  {""}, {""}})
AAdd(aHelp, {{"ate Vendedor"},  {""}, {""}})

//(<cGrupo>,<cOrdem>,<Pergunt>,< cPergSpa>,< cPergEng>,< cVar>,< cTipo>,< nTamanho>,[ nDecimal],[ nPreSel],<cGSC>,[cValid],[cF3],[cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil
PutSX1(cPerg,"01","Armazem? " ,"","" ,"mv_ch1","C",2,00,00,"G","","99","","","MV_PAR01","","","","","","","","","","","","","","","","",nil,nil,nil,"")
PutSX1(cPerg,"02","De tipo: " ,"","" ,"mv_ch2","C",2,00,00,"G","","02","","","MV_PAR02","","","","","","","","","","","","","","","","",nil,nil,nil,"")
PutSX1(cPerg,"03","Até tipo: " ,"","","mv_ch3","C",2,00,00,"G","","02","","","MV_PAR03","","","","","","","","","","","","","","","","",nil,nil,nil,"")
PutSX1(cPerg,"04","Filtrar Pó? " ,"","","mv_ch4","N",1,00,00,"C","","","","","MV_PAR04","Sim","","","","Não","","","","","","","","","","","",nil,nil,nil,"")

Return*/