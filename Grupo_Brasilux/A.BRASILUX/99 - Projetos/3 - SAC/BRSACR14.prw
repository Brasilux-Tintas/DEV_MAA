#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function BRSACR14()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE CbTxt
PRIVATE Titulo := "Relatorio de SAC  x Produção"
PRIVATE cDesc1 := "Relatorio informa sacs existentes sob o lote"
PRIVATE cDesc2 := ""
PRIVATE cDesc3 := "" 
                   //   0          1           2         3         4         5         6       7          8        9        10         11        12       13        14         15         16
                   //012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
PRIVATE cCabec1  := "Produto              Descrição                               Lote          Data Sac       Num. Sac       Ocorrencia                              QtdeLK         UM        Total Lote     %         Assunto"
PRIVATE cCabec2  := ""
private nTipo := 18
PRIVATE Tamanho:= "G"
PRIVATE Limite := 220
PRIVATE cString:= "SZR"
private m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:= "BRSACR14"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   := "BRSACR14"
PRIVATE MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06,MV_PAR07,MV_PAR08

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
//CriaSX1(cPerg) //LGS#20200213 - Adequação de release 12.1.25 e posteriores
Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:= "BRSACR14"            //Nome Default do relatorio em Disco

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
Local cQuery,cQry1,cQry2,cWhere
Private _nLin := 7

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery :="WITH TMP AS (SELECT ZR_FILIAL,ZR_ASSUNTO AS ASSUNTO,ISNULL(X5_DESCRI,'') AS DESCR,ZR_OCORREN,"
cQuery +="ZR_PRODUTO,ZR_QTD, B1_DESC,ZR_LOTE,ZQ_DATA,ZQ_NUM, "
cQuery +="CASE WHEN D2_UM IS NULL THEN 0 WHEN D2_UM IN ('K','KG','L') THEN D2_QUANT WHEN D2_SEGUM IN ('K','KG','L') THEN D2_QTSEGUM ELSE 0 END*ZR_QTD/(CASE WHEN D2_QUANT IS NULL THEN 1 ELSE D2_QUANT END) AS QTDELK," //SE QTDELK É SOMENTE LITROS OU KG ENTÃO DESCONSIDERA-SE OUTRAS UNIDADES DE MEDIDA(CLEBER)
cQuery +="CASE WHEN D2_UM IS NULL THEN '' WHEN D2_UM IN ('K','KG','L') THEN D2_UM WHEN D2_SEGUM IN ('K','KG','L') THEN D2_SEGUM ELSE D2_UM END AS UM, "
cQuery +="PRODUZIDO = ISNULL((SELECT SUM(CASE WHEN C2_UM IN ('L','K','KG') THEN C2_QUANT ELSE 0 END) AS QUANTIDADE "
cQuery +="FROM "+RetSQLName("SC2")+" WITH (NOLOCK) "
cQuery +="WHERE (SZR.ZR_LOTE > '') AND (C2_FILIAL = '"+xFilial("SC2")+"') AND (C2_UM IN ('L','K','KG')) AND (C2_LOTE = SZR.ZR_LOTE) AND (C2_LOTE >'')),0), "
cQuery +="PROCEDE = ISNULL((SELECT TOP 1 SZS.ZS_PROCEDE FROM "+RetSQLName("SZS")+" SZS WITH (NOLOCK) WHERE (SZS.ZS_FILIAL   = '"+xFilial("SZS")+"') AND (SZS.D_E_L_E_T_  = '') AND (SZS.ZS_NUM = SZR.ZR_NUM) AND (SZS.ZS_PROCEDE <> '')),''), "
cQuery +="DTATEND = ISNULL((SELECT MIN(SZS.ZS_DATA) "
cQuery +="FROM  "+RetSqlName("SZS")+" SZS WITH (NOLOCK) "
cQuery +="WHERE (SZS.D_E_L_E_T_ = '') AND (SZS.ZS_FILIAL  = SZR.ZR_FILIAL) AND (SZS.ZS_NUM  = SZR.ZR_NUM ) AND (SZS.ZS_LOG IN('ATE', 'DIA', 'FIN', 'REC', 'FIM','TEC','PRO','DIR','COM'))),'') "
cQuery +="FROM "+RetSqlName("SZR")+" SZR WITH (NOLOCK) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SZQ")+" SZQ WITH(NOLOCK) ON ZR_FILIAL = ZQ_FILIAL AND ZR_NUM = ZQ_NUM AND SZQ.D_E_L_E_T_ ='' "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON B1_FILIAL = ZR_FILIAL AND B1_COD = ZR_PRODUTO AND SB1.D_E_L_E_T_ ='' "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) ON (SD2.D_E_L_E_T_ <> '*') AND (ZR_FILIAL = D2_FILIAL) AND (ZR_SERNF = D2_SERIE) AND (ZR_NUMNF = D2_DOC) AND (ZR_ITEMORI = D2_ITEM) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SX5")+" SX5 WITH (NOLOCK) ON (SX5.D_E_L_E_T_ <> '*') AND (X5_FILIAL = '"+xFilial("SX5")+"') AND (X5_TABELA = 'T1') AND (X5_CHAVE = ZR_ASSUNTO) "
cQuery +="WHERE (SZR.D_E_L_E_T_ <> '*') AND (SZR.ZR_FILIAL = '"+xFilial("SZR")+"') AND (ZR_PRODUTO BETWEEN '"+MV_PAR03+"'  AND '"+MV_PAR04+"') "
if !Empty(MV_PAR05)
	cQuery +=" AND (ZR_OCORREN = '"+MV_PAR05+"')"
endif
if !Empty(MV_PAR06)
	cQuery +=" AND (ZR_ASSUNTO = '"+MV_PAR06+"') "
endif   
IF MV_PAR07 == 1
	cQuery += "AND (SZQ.ZQ_TIPOSAC <> '5')"   // Exceto Internos
ENDIF

cQuery +=") "                                 
cWhere := "WHERE (DTATEND BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"') "        
IF MV_PAR08 > 1    
	cWhere += "AND (PROCEDE > '') "
	IF MV_PAR08 == 2
		 cWhere += "AND (PROCEDE IN ('S','A')) "
	ELSE		 
		 cWhere += "AND (PROCEDE NOT IN ('S','A')) "
	ENDIF
ENDIF 
cQry1 := cQuery + "SELECT DESCR,ZR_OCORREN,ZQ_NUM,ASSUNTO,ZR_PRODUTO,ZR_QTD,B1_DESC,ZR_LOTE,ZQ_DATA,UM,QTDELK,PRODUZIDO "+;
"FROM TMP "+;
cWhere+;
"ORDER BY ASSUNTO,ZR_OCORREN,ZQ_NUM "

cQry2 := cQuery + "SELECT ZR_LOTE AS LOTE,UM,MAX(PRODUZIDO) AS PRODUZIDO,QTDE = SUM(QTDELK) "+;
"FROM TMP "+;
cWhere+;
"AND (ZR_LOTE > '') AND (UM > '') AND (UM IN ('K','KG','L')) "+;
"GROUP BY ZR_LOTE,UM ORDER BY LOTE"
//"AND (ZR_LOTE > '') AND (UM > '') AND (UM IN ('K','KG','L')) "+;

TCQUERY cQry1 NEW ALIAS "TCQ"
TCQUERY cQry2 NEW ALIAS "TCQ2"

SetRegua(RECCOUNT()) 

Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)


nQtdLi:=nQtdLi2 :=0
nQtdKg:=nQtdKg2 :=0
nQtdUn:=0                                                  
LimLinha := 70                                         	
nVLoteL:=nVLoteK:=0
cNrLoteL:=cNrLoteK:= TCQ->ZR_LOTE

dbselectarea("TCQ2")
dbgotop()
do while !eof()  
	cLote := alltrim(TCQ2->LOTE)
	do while !eof() .and. (TCQ2->LOTE = cLote)    
		DO CASE
		CASE TCQ2->UM = "L"
			nQtdLi += TCQ2->QTDE 
			nVLoteL += TCQ2->PRODUZIDO
		CASE (TCQ2->UM = "K")
			nQtdKg += TCQ2->QTDE  
			nVLoteK += TCQ2->PRODUZIDO
		ENDCASE
		dbselectarea("TCQ2")
		dbskip()
	ENDDO   
ENDDO


dbselectarea("TCQ")
dbgotop()                                                                                   
While !eof()
	cOcorrencia := POSICIONE("SU9",1,XFILIAL("SU9")+TCQ->ASSUNTO+TCQ->ZR_OCORREN,"U9_DESC")
	cAssunto    := TCQ->DESCR
	if _nLin > LimLinha
		@ _nLin,000 psay replicate("_",220)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)               
		_nLin := 08	    
	endif                              
 	@_nLin,000 psay TCQ->ZR_PRODUTO
	@_nLin,020 psay TCQ->B1_DESC
    @_nLin,060 psay TCQ->ZR_LOTE
    @_nLin,075 psay SubStr(TCQ->ZQ_DATA, 7, 2)+'/'+SubStr(TCQ->ZQ_DATA, 5, 2)+'/'+SubStr(TCQ->ZQ_DATA, 3, 2)
    @_nLin,090 psay TCQ->ZQ_NUM
    @_nLin,105 psay cOcorrencia
    @_nLin,145 psay TCQ->QTDELK
    @_nLin,160 psay TCQ->UM

   	nQtdeLote := TCQ->PRODUZIDO  
   	IF empty(TCQ->ZR_LOTE)
   		nQtdUn += TCQ->QTDELK
   	ENDIF 
/*
   	nQtdeLote := 0
	IF !EMPTY(TCQ->ZR_LOTE) 
		dbselectarea("SB1")
		dbsetorder(1)
		dbselectarea("SC2")
		DbOrderNickName("SC2001")
		dbseek(xFilial("SC2")+TCQ->ZR_LOTE)
	
		do while !eof() .and. (SC2->C2_FILIAL == xFilial("SC2")) .AND. (SC2->C2_LOTE = TCQ->ZR_LOTE)
			dbselectarea("SB1")
			dbseek(xFilial("SB1")+SC2->C2_PRODUTO)
			if found() .and. (SB1->B1_TIPO = "PI")
				nQtdeLote := SC2->C2_QUANT
			endif
			dbselectarea("SC2")
			dbskip()
		enddo 
	ENDIF      */
 	@_nLin,170 psay TCQ->PRODUZIDO //nQtdeLote       
 	if !EMPTY(TCQ->ZR_LOTE) .AND. (TCQ->ZR_LOTE > '0') .AND. (TCQ->PRODUZIDO > 0)
 		@ _nLin,182 psay round(((TCQ->QTDELK/nQtdeLote)*100),2)  
 	endif  
 	@ _nLin,195  psay cAssunto

    _nLin++   
    dbSelectArea("TCQ")
	dbSkip()
	
	
endDo 


if (_nLin+13) > LimLinha
	@ _nLin,000 psay replicate("_",220)
	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)               
	_nLin := 08	    
endif                              

_nLin++                  
@ _nLin,000 psay replicate("_",220)
  _nLin++
@ _nLin,000 psay "Total Litros em SACs c/ Lote Informado"
@ _nLin,050 psay "Total Litros em Lotes c/ Lote Informado"
@ _nLin,090 psay "Porcentagem Devolução(SAC/LOTE)" 
//@ _nLin,095 psay "Total Devolvido" 
_nLin++
@ _nLin,000 psay nQtdLi
@ _nLin,050 psay nVLoteL
@ _nLin,090 psay round(((nQtdLi/nVLoteL)*100),2)
//@ _nLin,095 psay nQtdLi2+nQtdLi

  _nLin++  
@ _nLin,000 psay replicate("_",220)
  _nLin++
@ _nLin,000 psay "Total Kg em SACs c/ Lote Informado"
@ _nLin,050 psay "Total Kg em Lotes c/ Lote Informado"
@ _nLin,090 psay "Porcentagem Devolução(SAC/LOTE)" 
//@ _nLin,095 psay "Total Devolvido" 
_nLin++
@ _nLin,000 psay nQtdKg
@ _nLin,050 psay nVLoteK
@ _nLin,090 psay round(((nQtdKg/nVLoteK)*100),2)
//@ _nLin,095 psay nQtdKg2+nQtdKg

_nLin++  
@ _nLin,000 psay replicate("_",220)
  _nLin++
@ _nLin,000 psay "Soma Qtdes SEM Lote informado"
_nLin++
@ _nLin,000 psay nQtdUn
_nLin++                		   
                  		   
dbselectarea("TCQ")
dbclosearea()

dbselectarea("TCQ2")
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
AAdd(aHelp, {{"Produto"},  {""}, {""}})
AAdd(aHelp, {{"Produto"},  {""}, {""}})
AAdd(aHelp, {{"Ocorrencia"},  {""}, {""}})
AAdd(aHelp, {{"Assunto"},  {""}, {""}})
AAdd(aHelp, {{"Filtra SACs Internos?"},  {"Filtra SACs Internos?"}, {"Filtra SACs Internos?"}})
AAdd(aHelp, {{"Todos/Somen Procedentes/Somen não Proc"},  {"Todos/Somen Procedentes/Somen não Proc"}, {"Todos/Somen Procedentes/Somen não Proc"}})
//(<cGrupo>,<cOrdem>,<Pergunt>,< cPergSpa>,< cPergEng>,< cVar>,< cTipo>,< nTamanho>,[ nDecimal],[ nPreSel],<cGSC>,[ cValid], [ cF3], [ cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil
PutSX1(cPerg,"01","de Periodo: " ,"","","mv_ch1","D",8,00,00,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
PutSX1(cPerg,"02","ate Periodo: " ,"","","mv_ch2","D",8,00,00,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")
PutSX1(cPerg,"03","de Produto: " ,"","","mv_ch3","C",15,00,00,"G","","SB1","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelp[3,1],aHelp[3,2],aHelp[3,3],"")
PutSX1(cPerg,"04","ate Produto: " ,"","","mv_ch4","C",15,00,00,"G","","SB1","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelp[4,1],aHelp[4,2],aHelp[4,3],"")
PutSX1(cPerg,"05","Ocorrencia: " ,"","","mv_ch5","C",6,00,00,"G","","SU9","","","MV_PAR05","","","","","","","","","","","","","","","","",aHelp[5,1],aHelp[5,2],aHelp[5,3],"")
PutSX1(cPerg,"06","Assunto: " ,"Assunto: ","Assunto: ","mv_ch6","C",6,00,00,"G","","T1","","","MV_PAR06","","","","","","","","","","","","","","","","",aHelp[6,1],aHelp[6,2],aHelp[6,3],"")
PutSX1(cPerg,"07","Excluir SACs tipo Interno?"  , "Excluir SACs tipo Interno?"  , "Excluir SACs tipo Interno?"  , "mv_ch7", "N"      ,  1          , 0           , 1          , "C"     , ""        , ""      , ""         , ""       , "mv_par07", "Sim"     , "Sim"       , "Sim"       , ""        , "Não"     , "Não"       , "Não"       , ""        , ""          , ""          , ""        , ""          , ""          ,  ""       , ""          , ""          , aHelp[7,1],aHelp[7,2],aHelp[7,3],"")
//    (<cGrupo>,<cOrdem>,<Pergunt>            ,< cPergSpa>           ,< cPergEng>           ,< cVar>    ,< cTipo>,< nTamanho>,[ nDecimal],[ nPreSel],<cGSC>,[ cValid], [ cF3], [ cGrpSXG], [ cPyme], < cVar01> , [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02]   , [ cDefSpa2]  , [ cDefEng2]  , [ cDef03]   , [ cDefSpa3] , [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil
PutSX1(cPerg   ,"08"    ,"Proced/Não Proced"  , "Proced/Não Proced"  , "Proced/Não Proced"  , "mv_ch8"  , "N"    ,  1        , 0         , 1        , "C"  , ""      , ""    , ""        , ""      , "mv_par08", "Todos"  , "Todos"    , "Todos"    , ""       ,"Procedentes", "Procedentes", "Procedentes", "NÃO Proced", "NÃO Proced","NÃO Proced", ""        , ""          , ""          ,  ""       , ""          , ""          , aHelp[8,1],aHelp[8,2],aHelp[8,3],"")

Return*/
