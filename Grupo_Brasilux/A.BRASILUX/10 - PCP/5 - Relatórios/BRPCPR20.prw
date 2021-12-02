#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function BRPCPR20()
 //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
 //Ё Define Variaveis                                             Ё
 //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE CbTxt
PRIVATE Titulo := "Relatorio PCP"
PRIVATE cDesc1 := " "
PRIVATE cDesc2 := ""
PRIVATE cDesc3 := "" 
                   //   0          1           2         3         4         5         6       7
                   //012345678901234567890123456789012345678901234567890123456789012345678901234567890
PRIVATE cCabec1  := ""
PRIVATE cCabec2  := ""
private nTipo := 18
PRIVATE Tamanho:= "M"
PRIVATE Limite := 132
PRIVATE cString:= "SC2"
private m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:="BRPCPR20"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   :="BRPCPR20"
     u_zcfga01( 'BRPCPR20' ) //LGS#2021201 - GravaГЦo de log de utilizaГЦo da rotina
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica as perguntas selecionadas                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
//CriaSX1(cPerg)  //LGS#20200204 - AdequaГЦo de release 12.1.25 e posteriores
Pergunte(cPerg,.F.)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Envia controle para a funcao SETPRINT                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

wnrel:="BRPCPR20"            //Nome Default do relatorio em Disco

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
// FunГЮo....: RPTDETAIL    Data....: 29/04/14         //
// Autor.....: Marcelo J. A. de Paiva                  //
/////////////////////////////////////////////////////////

Static Function RptDetail()
Local nTotal := 0
//Local 	_nCont := 0
//Local lNormal
Private _nLin := 7

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa  regua de impressao                            Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

cQuery :=" SELECT CASE WHEN ZZG.ZZG_TPUSER ='B' THEN '1 - BALAN' ELSE "
cQuery +=" CASE WHEN ZZG.ZZG_TPUSER ='L' THEN '2 - LABOR' ELSE "
cQuery +=" CASE WHEN ZZG.ZZG_TPUSER ='C' THEN '3 - COLOR' ELSE "
cQuery +=" CASE WHEN ZZG.ZZG_TPUSER ='E' THEN '4 - ENVAS' ELSE ZZG_TPUSER END END END END AS ZZG_TPUSER, "
cQuery +=" C2_QUANT , ZZG.ZZG_SEQENV, ZZG.ZZG_PROENV, ISNULL(ZZA.ZZA_QUANT,0) AS ZZA_QUANT, SRA.RA_MAT, SRA.RA_NOME,ZZA_PESESP,SB1.B1_PESOESP,ZZG_ORDEM,ZZG_LOTE,ZZA_PESLAB, ZZA.ZZA_FLAG,ZZA.ZZA_PRODUT,ZZA.ZZA_ORDEM,ZZA.ZZA_QUANT,ZZA.ZZA_LOTE,SB1.B1_DESC  "
cQuery +=" FROM "+RetSqlName("ZZG")+" ZZG WITH(NOLOCK) 
cQuery +=" LEFT OUTER JOIN "+RetSqlName("SRA")+" SRA WITH (NOLOCK) ON SUBSTRING(ZZG_FILMAT,1,2) = SUBSTRING(RA_FILIAL,5,2) AND SUBSTRING(ZZG_FILMAT,3,6)= RA_MAT AND SRA.D_E_L_E_T_ =''  "
cQuery +=" LEFT OUTER JOIN "+RetSqlName("ZZA")+" ZZA WITH (NOLOCK) ON ZZA_FILIAL = ZZG_FILIAL AND ZZA_LOTE = ZZG_LOTE  AND ZZA_PRODUT = ZZG_PROENV AND ZZA_SEQENV = ZZG_SEQENV AND ZZA.D_E_L_E_T_ =''  "
cQuery +=" LEFT OUTER JOIN "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) ON (SC2.D_E_L_E_T_ <> '*') AND (ZZG_FILIAL = C2_FILIAL) AND (ZZG_ORDEM = (C2_NUM+C2_ITEM+C2_SEQUEN)) "
cQuery +=" LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = C2_FILIAL) AND (B1_COD = C2_PRODUTO) "
cQuery +=" WHERE ZZG.ZZG_FILIAL  = '"+xFilial("ZZG")+"' "
cQuery +=" AND (ZZG_LOTE BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"')  "
cQuery +=" AND ZZG.D_E_L_E_T_ = '' "
cQuery +=" ORDER BY ZZG_PROENV, ZZG.R_E_C_N_O_"

TCQuery cQuery NEW ALIAS "TCQ"

SetRegua(RECCOUNT())
Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)

dbselectarea("TCQ")
dbgotop()         
nAmostra:= 0
nTotal:=0
_nLin := 07
cLote := TCQ->ZZG_LOTE

While !eof()                                     

	if _nLin > 50
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
		_nLin := 07
	endif                              
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------

   	@ _nLin,000 psay "LOTE: "+ TCQ->ZZG_LOTE
   	@ _nLin,030 psay "ORDEM DE PRODUгцO: "+ TCQ->ZZG_ORDEM
   	@ _nLin,065 psay "QUANTIDADE: "+ transform(TCQ->C2_QUANT,"@E 99999.99")
   	_nLin++
    _nLin++
	@ _nLin,000 psay "PRODUTO: "+ TCQ->ZZA_PRODUT
	@ _nLin,065 psay "DESCRIгцO: "+ TCQ->B1_DESC
   	_nLin++
   	@ _nLin,000 psay "PESO ESP TEсRICO: "+ transform(TCQ->B1_PESOESP,"@E 999.9999")
	_nLin++   	
	@ _nLin,000 psay "PESO ESP LAB.:   "+ transform(TCQ->ZZA_PESLAB,"@E 999.9999")
	_nLin++
	_nLin++   	  
	@ _nLin,000 psay "PROCESSOS                                                        QTDE APONT     APONTADORES"	

	_nLin++ 
	_nLin++
   
	while !eof() .AND. (TCQ->ZZG_LOTE == cLote )
	
		@ _nLin,000 psay TCQ->ZZG_TPUSER
		@ _nLin,015 psay TCQ->B1_DESC
		@ _nLin,065 psay IIF(TCQ->ZZA_QUANT = 0,'_' ,Transform(TCQ->ZZA_QUANT,"@E 99999"))                             
		@ _nLin,080 psay TCQ->RA_NOME
		_nLin++

		dbSelectArea("TCQ")
    	dbSkip()  
        
		if _nLin > 50               
			@ _nLin,000 psay replicate("_",132)
			Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
			_nLin := 07
		endif
		
	endDo
@ _nLin,000 psay replicate("_",132)
			
cLote := TCQ->ZZG_LOTE
_nLin := 55

endDo                  

//-------------------------------------------------------------------------
//-------------------------------------------------------------------------

dbselectarea("TCQ")
dbclosearea()

Set Device To Screen              

If aReturn[5] == 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnrel)
Endif

Return

/*/
Programa  : CRIASX1   Autor:  MARCELO PAIVA
Data      : 29/04/14
/*/
//LGS#20200204 - AdequaГЦo de release 12.1.25 e posteriores
/*Static Function CriaSX1(cPerg)

Local aHelp := {}

//Texto do help em portugues  ,     ingles, espanhol

AAdd(aHelp, {{"Informar o lote Inicial"},  {""}, {""}})
AAdd(aHelp, {{"Informar o lote Final"},  {""}, {""}})

PutSX1(cPerg,"01","Do Lote"    ,"","","mv_ch1","C",06,00,00,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
PutSX1(cPerg,"02","AtИ o Lote" ,"","","mv_ch2","C",06,00,00,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")

Return*/
