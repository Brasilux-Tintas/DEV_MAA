#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function TCACDR01()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE CbTxt
PRIVATE Titulo := "Relatorio de Ordem de Separação"
PRIVATE cDesc1:=""
PRIVATE cDesc2:=""
PRIVATE cDesc3 := "" 
                   //   0          1           2         3         4         5         6       7          8        9        10         11        12       13        14         15         16
                   //012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
PRIVATE cCabec1  := "                                                                                   Relatorio Ordem Separação"
PRIVATE cCabec2  := ""  
private nTipo := 18
PRIVATE Tamanho:= "M"
PRIVATE Limite := 132
PRIVATE cString:= "SA1"
private m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:= "TCACDR01"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   := "TCACDR01  "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
//CriaSX1(cPerg) //LGS#20200217 - Adequação de release 12.1.25 e posteriores
Pergunte(cPerg,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:= "TCACDR01"            //Nome Default do relatorio em Disco

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
Local lFlag := .t.
Local cNOS := "" //Numero da ordem de separação
Private _nLin := 9


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cQuery :="SELECT CB7_ORDSEP,CB7_PEDIDO,CB7_CLIENT,A1_NOME,CB7_LOJA,CB8_PROD,B1_DESC,CB8_LOCAL,CB8_LCALIZ,CB8_LOTECT,CB8_QTDORI, "
cQuery +="CASE WHEN CB7_DIVERG = '1' THEN 'DIVERGENCIA' "
cQuery +="WHEN CB7_STATPA = '2' THEN 'PAUSA' "
cQuery +="WHEN CB7_STATUS = '9' THEN 'FINALIZADO' "
cQuery +="WHEN CB7_STATUS IN ('1','2','3','4','5''6','7','8') THEN 'EM ANDAMENTO' "
cQuery +="WHEN CB7_STATUS = '0' THEN 'NÃO INICIADO' "
cQuery +="END AS 'STATUS' "
cQuery +="FROM "+RetSqlName("CB7")+" CB7 "
cQuery +="LEFT OUTER JOIN "+RetSqlName("CB8")+" CB8 WITH(NOLOCK)ON CB7_FILIAL = CB8_FILIAL AND CB7_ORDSEP = CB8_ORDSEP AND CB8.D_E_L_E_T_<> '*' "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH(NOLOCK)ON (A1_FILIAL = '"+xFilial("SA1")+"') AND A1_COD = CB7_CLIENT AND SA1.D_E_L_E_T_ <> '*' AND CB7_LOJA = A1_LOJA "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK)ON B1_COD = CB8_PROD AND SB1.D_E_L_E_T_ <> '*' "
cQuery +="WHERE (CB7_ORDSEP BETWEEN ('"+(MV_PAR01)+"') AND ('"+(MV_PAR02)+"')) AND CB7.D_E_L_E_T_ <> '*' AND (CB7_FILIAL = '"+xFilial("CB7")+"')"

TCQUERY cQuery ALIAS "TCQ" NEW
dbselectarea("TCQ")

SetRegua(RECCOUNT()) 

cCabec2 :="OS: "+TCQ->CB7_ORDSEP+"    Pedido de venda:  "+TCQ->CB7_PEDIDO+"     Cliente: "+TCQ->CB7_CLIENT+" - "+TCQ->A1_NOME+"  Loja: "+TCQ->CB7_LOJA+"    Status: "+TCQ->STATUS

Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)

cNOS := TCQ->CB7_ORDSEP
While !Eof()
	if TCQ->CB7_ORDSEP != cNOS
		cNOS := TCQ->CB7_ORDSEP
		_nLin := 56
	endif
	if _nLin > 55
		@ _nLin,000 psay replicate("_",170)
		_nLin := 9
		cCabec2 :="OS: "+TCQ->CB7_ORDSEP+"    Pedido de venda:  "+TCQ->CB7_PEDIDO+"     Cliente: "+TCQ->CB7_CLIENT+" - "+TCQ->A1_NOME+"  Loja: "+TCQ->CB7_LOJA+"    Status: "+TCQ->STATUS
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
		lFlag := .t.
	endif
	if lFlag
		@ _nLin,000 psay "Produto"
		@ _nLin,020 psay "Descricao"
		@ _nLin,065 psay "Armazem"
		@ _nLin,080 psay "Endereco"
		@ _nLin,095 psay "Lote"
		@ _nLin,110 psay "Quantidade"
		@ _nLin++		
		lFlag := .f.		
	endif
	
	@ _nLin,000 psay TCQ->CB8_PROD
  	@ _nLin,020 psay SUBSTR(TCQ->B1_DESC,1,40)
	@ _nLin,065 psay TCQ->CB8_LOCAL
	@ _nLin,080 psay TCQ->CB8_LCALIZ
	@ _nLin,095 psay TCQ->CB8_LOTECT
	@ _nLin,110 psay Transform(TCQ->CB8_QTDORI,"@E 99,999,999.99")	
	@ _nLin++
	dbselectarea("TCQ")	 
	dbskip() 
EndDo
	@ _nLin,000 psay replicate("_",170) 
	
	dbSelectArea("TCQ")
    dbCloseArea()
Set Device To Screen
If aReturn[5] == 1             	
   Set Printer TO
   dbcommitAll()
   ourspool(wnrel)
Endif
Return

//LGS#20200221 - Adequação de release 12.1.25 e posteriores
/*
Static Function CriaSX1(cPerg)
Local aHelp := {}

// cGrupo, cOrdem,   cTexto,   cMVPar, cVariavel, cTipoCamp, nTamanho, nDecimal, cTipoPar, cValid, cF3, cPicture, cDef01, cDef02, cDef03, cDef04, cDef05, cHelp
aAdd( aHelp, "de Ordem de servico" )
u_zPutSX1(cPerg     ,"01"     ,"de Ordem de servico: "               ,"MV_PAR01" ,"mv_ch1"   ,"C"     ,6          ,0          ,"G"    ,""           ,"CB7"    ,""         ,""          ,""                ,""       ,""       ,""       ,aHelp[1])

aAdd( aHelp, "ate Ordem de servico" )
u_zPutSX1(cPerg,"02","ate Ordem de servico: " ,"MV_PAR02","mv_ch2","C",6,00,"G","","CB7","","","","","","",aHelp[2])

Return*/