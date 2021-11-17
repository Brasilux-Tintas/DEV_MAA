#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function BRFATR19()
	//UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA¢¯
 	//©ø Define Variaveis                                             ©ø
 	//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAU
 	PRIVATE CbTxt,MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06,MV_PAR07
 	PRIVATE Titulo := "Relatorio Fatura"
 	PRIVATE cDesc1 := "Este relatorio ira emitir a Fatura "
 	PRIVATE cDesc2 := "Cliente"
 	PRIVATE cDesc3 := "" 
                   //   0          1           2         3         4         5         6       7     
                   //01234567890123456789012345678901234567890123456789012345678901234567890123456789
    PRIVATE cCabec1  := "Cliente    Razao                                    Mes         Valor"
    PRIVATE cCabec2  := ""   
    private nTipo := 18
    PRIVATE Tamanho:= "P"
    PRIVATE Limite := 80
    PRIVATE cString:= "SA1"
    private m_pag    := 01  
    PRIVATE CbCont,cabec1,cabec2,wnrel
    PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }			
    PRIVATE nomeprog:="BRFATR19"
    PRIVATE aLinha  := { },nLastKey := 0
    PRIVATE cPerg   :="BRFATR19"

    //UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA¢¯
    //©ø Verifica as perguntas selecionadas                           ©ø
    //AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAU
     
    if !u_VldAcesso(funname())
        MsgBox("Acesso nao autorizado!---->"+funname(),"Atencao","Alert")
        return 
    endif 


    //CriaSX1(cPerg)
    Pergunte(cPerg,.F.)
    //UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA¢¯
    //©ø Envia controle para a funcao SETPRINT                        ©ø
    //AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAU

    wnrel:="BRFATR19"            //Nome Default do relatorio em Disco

    wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

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

Return

	/////////////////////////////////////////////////////////
	// Funcao....: RPTDETAIL    Data....: 03/10/13         //
	// Autor.....: Marcelo J. A. de Paiva                  //
	/////////////////////////////////////////////////////////

Static Function RptDetail()
	Local cQuery := ""
	Local nTotal := 0
	Local ccliente :=""
	Private _nLin 		:= 7

	//UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA¢¯
	//©ø Inicializa  regua de impressao                            ©ø
	//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAU

	cQuery := "WITH TMP AS (SELECT D2_CLIENTE AS CLIENTE,SUBSTRING(D2_EMISSAO,1,6) AS MES,MAX(A1_NOME) AS RAZAO,SUM(D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END)) AS VALOR "+;
	" FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) "+;
	"LEFT OUTER JOIN "+RetSqlName("SF4")+ " SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (D2_TES = F4_CODIGO) "+;
	"LEFT OUTER JOIN "+RetSqlName("SA1")+ " SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (D2_CLIENTE = A1_COD) "+;
	"LEFT OUTER JOIN "+RetSqlName("SC5")+ " SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (D2_FILIAL = C5_FILIAL) AND (D2_PEDIDO = C5_NUM) "+;
	"WHERE (SD2.D_E_L_E_T_ <> '*') AND(D2_FILIAL = '"+xFILIAL("SD2")+"' )AND (D2_TIPO = 'N') AND ((F4_DUPLIC = 'S') OR (D2_TES = '519')) AND "+;
	"(D2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"') AND (D2_CLIENTE BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"') "
	//Chamado 007514, tirar codigos de repres. especificos do Glaidon 
	if __cUserId = "000282"
		cQuery += "AND (C5_VEND1 NOT IN ('000250','000444','000303','000333','000438','000276')) "
	endif 
	if !empty(MV_PAR05)
		cQuery += "AND (LEN(D2_COD) = 12) AND "+U_ParamSql("SUBSTRING(D2_COD,4,2)",MV_PAR05)+" "
	endif		
	IF !empty(MV_PAR06)
		cQuery +="AND ((A1_SATIV2 = '') OR ("+U_ParamSql("A1_SATIV2",MV_PAR06)+")) "
	ENDIF
	if !empty(MV_PAR07)
		cQuery += "AND ("+U_ParamSql("D2_EST",MV_PAR07)+") "
	endif
	cQuery += "GROUP BY D2_CLIENTE,SUBSTRING(D2_EMISSAO,1,6) "+;
	"UNION ALL "+;
	"SELECT D1_FORNECE AS CLIENTE,SUBSTRING(D1_DTDIGIT,1,6) AS MES,MAX(A1_NOME) AS RAZAO,SUM(D1_TOTAL*-1) AS VALOR "+;
	"FROM " +RetSqlName("SD1")+ " SD1 WITH (NOLOCK) "+;
	"LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (D1_TES = F4_CODIGO) "+;
	"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (D1_FORNECE = A1_COD) "+;
	"WHERE (SD1.D_E_L_E_T_ <> '*') AND (D1_FILIAL = '"+xFILIAL("SD1")+"' ) AND (D1_TIPO = 'D') AND (F4_DUPLIC = 'S') AND "+;
	"(D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"') AND (D1_FORNECE BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"') "
	//Chamado 007514, tirar codigos de repres. especificos do Glaidon 
	if __cUserId = "000282"
		cQuery += "AND (A1_VEND NOT IN ('000250','000444','000303','000333','000438','000276')) "
	endif 
	if !empty(MV_PAR05)
		cQuery += "AND (LEN(D1_COD) = 12) AND "+U_ParamSql("SUBSTRING(D1_COD,4,2)",MV_PAR05)+" "
	endif		
	IF !empty(MV_PAR06)
		cQuery +="AND ((A1_SATIV2 = '') OR ("+U_ParamSql("A1_SATIV2",MV_PAR06)+")) "
	ENDIF
	if !empty(MV_PAR07)
		cQuery += "AND ("+U_ParamSql("A1_EST",MV_PAR07)+") "
	endif
	cQuery += "GROUP BY D1_FORNECE,SUBSTRING(D1_DTDIGIT,1,6)) "+;
	"SELECT CLIENTE,MES,MAX(RAZAO) AS RAZAO,SUM(VALOR) AS VALOR FROM "+;
	"TMP GROUP BY CLIENTE,MES ORDER BY CLIENTE,MES "
				
	TCQuery cQuery NEW ALIAS "TCQ"         

	SetRegua(RECCOUNT())
	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			

	dbselectarea("TCQ")
	dbgotop()

	_nLin := 07
	ccliente := TCQ->CLIENTE
	While !eof()
		if _nLin > 55                                                                    	
			@ _nLin,000 psay replicate("_",80)
			Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
			_nLin := 07
		endif 
		_nLin++
		@ _nLin,000 psay TCQ->CLIENTE 
		@ _nLin,009 psay TCQ->RAZAO
		@ _nLin,052 psay  Substr(MES,5,6) + "/" + Substr(MES,1,4)
		@ _nLin,060 psay transform(TCQ->VALOR,"@E 9,999,999.99")

		nTotal+= TCQ->VALOR
		ccliente := TCQ->CLIENTE
		
		dbSelectArea("TCQ")
		dbSkip()

		if eof() .or. (TCQ->CLIENTE != ccliente)
			_nLin++
			if _nLin > 55                                                                    	
				@ _nLin,000 psay replicate("_",80)
				Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
				_nLin := 07
			endif 

			_nLin++
			@_nLin,053 psay "TOTAL: "+transform(nTotal,"@E 9,999,999.99")
			if _nLin > 55                                                                    	
				@ _nLin,000 psay replicate("_",80)
				Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
				_nLin := 07
			endif 
			_nLin++
			@ _nLin,000 psay replicate("-",80)
			nTotal := 0 
		endif    
		dbSelectArea("TCQ")
	endDo   

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
Data      : 10/10/13
/*/
/*
Static Function CriaSX1(cPerg)

Local aHelp := {}                                                                                                                                       

AAdd(aHelp, {{"Informe a Linha de Produto"},  {"Informe a Linha de Produto"}, {"Informe a Linha de Produto"}})

//Texto do help em portugues  ,     ingles, espanhol

AAdd(aHelp, {{"Informe de Emissao"},  {""}, {""}})
AAdd(aHelp, {{"Informe ate Emissao"},  {""}, {""}})
AAdd(aHelp, {{"Informe do Cliente"},  {""}, {""}})
AAdd(aHelp, {{"Informe ate Cliente"},  {""}, {""}})
AAdd(aHelp, {{"Deixar em branco para puxar todos"},  {""}, {""}})
AAdd(aHelp, {{"Deixar em branco para puxar todos"},  {""}, {""}})

PutSX1(cPerg,"01","de Emissao" ,"","","mv_ch1","D",8,00,00,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
PutSX1(cPerg,"02","ate Emissao" ,"","","mv_ch2","D",8,00,00,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")
PutSX1(cPerg,"03","do Cliente" ,"","","mv_ch3","C",6,00,00,"G","","SA1","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelp[3,1],aHelp[3,2],aHelp[3,3],"")
PutSX1(cPerg,"04","ate Cliente" ,"","","mv_ch4","C",6,00,00,"G","","SA1","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelp[4,1],aHelp[4,2],aHelp[4,3],"")
PutSX1(cPerg,"05","Linha(s) Produto"    ,"Linha(s) Produto","Linha(s) Produto","mv_ch5","C",99,00,00,"G","","","","","mv_Par05","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
PutSX1(cPerg,"06","Segmento(s)        ", "Segmento(s)        ", "Segmento(s)        ", "mv_ch6", "C", 99,00,00, "G",  "", "T3",  "",  "", "mv_Par06","","","","","","","","","","","","","","","","",Nil  , Nil     , Nil,cPerg)
PutSX1(cPerg,"07","Estado(s)          ", "Estado(s)          ", "Estado(s)          ", "mv_ch7", "C", 99,00,00, "G",  "", "",  "",  "", "mv_Par07","","","","","","","","","","","","","","","","",Nil  , Nil     , Nil ,cPerg)

Return
*/