#include "rwmake.ch"        
#INCLUDE "TOPCONN.CH"   

/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: BRFAT079     Data....:                  //
// Autor.....: Cleber Orati Domingues                  //
// Descriçao.: Rel. de Fat. no Per. por Representante  //
// Uso.......: Todas as Empresas 					   //
//                                                     //
/////////////////////////////////////////////////////////  
//                                                     //
// Variaveis utilizadas para parametros                //         
//                                                     //        
// mv_par01     // Per. de                             //
// mv_par02     // Per Ate                             //
// mv_par03     // Repr. de                            //
// mv_par04     // Repr. Ate                           //
/////////////////////////////////////////////////////////

User Function BRFAT079()     

PRIVATE MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06,MV_PAR07,MV_PAR08,MV_PAR09,MV_MAR10,MV_PAR11
SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M")
SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3")
SetPrvt("CCABEC,CCABPRO,CNATUREZA,ARETURN,NOMEPROG,CPERG")
SetPrvt("NLASTKEY,LCONTINUA,NLIN,NCOL,WNREL,NTIPO")
SetPrvt("M_PAG,CCABEC1,CCABEC2,CCABEC3,NTAMNF,CSTRING")
SetPrvt("CQUERY,_TOTALG,_TOTFIN,_TOTESTE,_TOTESTS,LIMPEST")
SetPrvt("LIMPFIN,_DTGERAD,_NRAVAR,_TOTAL,_SALIAS,AREGS")

CbTxt    :=""
CbCont   :=0
nOrdem   :=0
Alfa     :=0
Z        :=0
M        :=0
tamanho  :="M"
limite   :=132
titulo   :="FATURAMENTO POR REPRESENTANTE"
cDesc1   :=PADC("Este programa ira emitir o Rel. de Faturamento por Representante",74)
cDesc2   :=""
cDesc3   :=PADC(" ",74)
cCabec   :=PADC("Rel. Fat. por Repres.",27)
cCabPro  :=""
cNatureza:=""
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog :="BRFAT079"
cPerg    :="BRFAT079"
nLastKey := 0
lContinua:=.T.
nLin    := 0
nCol     := 0
wnrel    := "BRFAT079"
nTipo    := 18
m_pag    := 01     
nTamNf   := 80     // Apenas Informativo
cString  := "SF2"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

if !u_VldAcesso(funname())
	MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
	return 
endif 

ValidPerg()
Pergunte(cPerg,.F.)   

//               0       1           2        3           4       5         6        7           8      9         10          11       12		  13
//           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
cCabec1  := ""
cCabec2  := "Codigo  Razão Social                                      V. Int         V. Ext          Total Comis(%)  Qt Cli         Cota % Cota"
cCabec3  := ""																											      

wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,,.T.,Tamanho)

cCabec1  := "PERIODO DE "+dtoc(mv_par01)+" ATE "+dtoc(mv_par02)

If nLastKey == 27
   Return
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica Posicao do Formulario na Impressora                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio do Processamento do Relatorio                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

  RptStatus({|| RptDetail()})

Return

Static Function RptDetail()

Local cRepres,cAux,nCol,nSomaComi,nTotal,nVendInt,nVendExt,nTotalExt,cTipoVen,nValMerc,nTotalComis,cQuery,cFatB6,nQtdeCli

cFatB6 = iif(MV_PAR09 == 1, "0.7","1.0")
cQuery := "WITH TMP AS (SELECT D2_DOC AS F2_DOC,D2_SERIE AS F2_SERIE,MAX(D2_EMISSAO) AS F2_EMISSAO,D2_PEDIDO AS PEDIDO, "+;
"D2_CLIENTE AS F2_CLIENTE,MAX(A1_NOME) AS A1_NOME,SUM(D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN "+cFatB6+" ELSE 1.0 END)) AS F2_VALMERC, "+;
"F2_VEND1 "+;
"FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) "+;
"LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = '"+xFilial("SF2")+"') AND (D2_SERIE = F2_SERIE) AND (D2_DOC = F2_DOC) AND (D2_CLIENTE = F2_CLIENTE) "+;
"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (D2_CLIENTE = A1_COD) "+;
"LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (D2_TES = F4_CODIGO) "+;
"LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = '"+xFilial("SC5")+"') AND (D2_PEDIDO = C5_NUM) "+;
"WHERE (SD2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = '"+xFilial("SD2")+"') AND (D2_TIPO = 'N') AND ((F4_DUPLIC <> 'N')"
if MV_PAR09 == 1
	cQuery += " OR (D2_TES = '519')"
endif
cQuery += ") AND (D2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"') "+;
"AND (F2_VEND1 BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"') "
if !empty(MV_PAR05)
	cQuery += "AND (LEN(D2_COD) = 12) AND "+U_ParamSql("SUBSTRING(D2_COD,4,2)",MV_PAR05)+" "
endif  
if !empty(MV_PAR06)   
	cAux := U_RegiaoGeo(MV_PAR06)
	if !empty(cAux)
		cQuery += "AND (D2_EST IN ("+cAux+")) "
	endif 
endif		                           
if !empty(MV_PAR07)
	cQuery += "AND ((A1_SATIV2 = '') OR ("+U_ParamSql("A1_SATIV2",MV_PAR07)+")) "
endif       
if !empty(MV_PAR08)
	cQuery += "AND ("+U_ParamSql("A1_EST",MV_PAR08)+") "
endif
if !empty(MV_PAR11) 
	cQuery += "AND (D2_CLIENTE BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"') "
endif

cQuery += "GROUP BY D2_SERIE,D2_DOC,D2_CLIENTE,D2_PEDIDO,F2_VEND1 "
cQuery += "UNION ALL "
cQuery += "SELECT D1_DOC AS F2_DOC,D1_SERIE AS F2_SERIE,MAX(D1_DTDIGIT) AS F2_EMISSAO,D2_PEDIDO AS PEDIDO, "+;
"D1_FORNECE AS F2_CLIENTE,MAX(A1_NOME) AS A1_NOME,SUM(-1.0*D1_TOTAL) AS F2_VALMERC, "+;
"F2_VEND1 "+;
"FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK) "+;
"LEFT OUTER JOIN "+RetSqlName("SF1")+" SF1 WITH (NOLOCK) ON (SF1.D_E_L_E_T_ <> '*') AND (F1_FILIAL = D1_FILIAL) AND (F1_DOC = D1_DOC) AND (F1_SERIE = D1_SERIE) AND (F1_FORNECE = D1_FORNECE) AND (F1_TIPO = D1_TIPO) "+;
"LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = D1_FILIAL) AND (F2_SERIE = D1_SERIORI) AND (F2_DOC = D1_NFORI) "+;
"LEFT OUTER JOIN "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) ON (SD2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = D1_FILIAL) AND (D2_SERIE =  D1_SERIORI) AND (D2_DOC = D1_NFORI) AND (D2_ITEM = D1_ITEMORI) AND (D2_CLIENTE = D1_FORNECE) AND (D2_LOJA = D1_LOJA) "+;
"LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (D1_TES = F4_CODIGO) "+;
"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (A1_COD = D1_FORNECE) "+;
"WHERE (SD1.D_E_L_E_T_ <> '*') AND (D1_FILIAL = '"+xFilial("SD1")+"') AND (D1_TIPO = 'D') AND (D1_NFORI > '') AND (F4_DUPLIC <> 'N') "+;
"AND (D1_DTDIGIT BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"') "+;
"AND (F2_VEND1 BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"') "
if !empty(MV_PAR05)
	cQuery += "AND (LEN(D1_COD) = 12) AND "+U_ParamSql("SUBSTRING(D1_COD,4,2)",MV_PAR05)+" "
endif  
if !empty(MV_PAR06)   
	cAux := U_RegiaoGeo(MV_PAR06)
	if !empty(cAux)
		cQuery += "AND (A1_EST IN ("+cAux+")) "
	endif 
endif		                           
if !empty(MV_PAR07)
	cQuery += "AND ((A1_SATIV2 = '') OR ("+U_ParamSql("A1_SATIV2",MV_PAR07)+")) "
endif       
if !empty(MV_PAR08)
	cQuery += "AND ("+U_ParamSql("A1_EST",MV_PAR08)+") "
endif
if !empty(MV_PAR11) 
	cQuery += "AND (A1_COD BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"') "
endif

cQuery += "GROUP BY D1_SERIE,D1_DOC,D1_FORNECE,D2_PEDIDO,F2_VEND1) "
cQuery += ",TMP1 AS (SELECT DISTINCT F2_CLIENTE AS CLIENTE,F2_VEND1 AS REPRES FROM TMP) "
cQuery += "SELECT F2_DOC,F2_SERIE,MAX(F2_EMISSAO) AS F2_EMISSAO,PEDIDO,F2_CLIENTE,MAX(A1_NOME) AS A1_NOME,SUM(F2_VALMERC) AS F2_VALMERC, "+;
"F2_VEND1, "+;
"QTDECLI = (SELECT COUNT(CLIENTE) FROM TMP1 WHERE REPRES = TMP.F2_VEND1) "+;
"FROM TMP "+;
"GROUP BY F2_SERIE,F2_DOC,F2_CLIENTE,PEDIDO,F2_VEND1 "+;
"ORDER BY F2_VEND1,F2_SERIE,F2_DOC"
 TCQuery cQuery NEW ALIAS "TCQ"     
	dbselectarea("SC5") // Pedidos
	dbsetorder(1)
	dbselectarea("SD2") // Itens da Nota Fiscal
	dbsetorder(3) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	dbselectarea("SA3") // Vendedores
	dbsetorder(1)
	
//	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
// 	nLin := 08
  	dbSelectArea("TCQ")
  	dbgotop()
  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa  regua de impressao                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  	SetRegua(Reccount())
  	nTotalInt := 0
  	nTotalExt := 0
	nTotalComis := 0
	nLin := 9 
	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
	While ! EoF()         
	    If nlin >= 60
   	  		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
	   	  	nLin := 09
  	 	Endif   
		nCota := 0      
   	   	cRepres = alltrim(TCQ->F2_VEND1)   
    	cAux := cRepres
    	dbselectarea("SA3")
    	dbseek(xFilial("SA3")+cRepres)
    	if found()
    		cAux += "-"+alltrim(SA3->A3_NOME)
			nCota := SA3->A3_COTA
    	endif    		
       
		nCol = 40 - int(len(cAux)/2)
       	nSomaComi := 0
		nTotal := 0
		nVendInt := 0
		nVendExt := 0
		nQtdeCli := TCQ->QTDECLI //Qtde de Clientes diferentes
		
    	dbselectarea("TCQ")
    	while !eof() .AND. (alltrim(TCQ->F2_VEND1) == cRepres)
    		If nlin >= 58
    			nLin+=1
 	   			@nLin,000 psay replicate("_",132)
	      		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
    	  		nLin := 09
	    	Endif        
    		nComis := 0
			cTipoVen = "I" 
			nValMerc := TCQ->F2_VALMERC
   			dbselectarea("SC5")
			dbseek(xFilial("SC5")+TCQ->PEDIDO)
			if found()                                           
	   			if !empty(SC5->C5_TIPOVEN)
	   				cTipoVen = SC5->C5_TIPOVEN
		   		endif
				nComis := SC5->C5_COMIS1  //SC5->C5_PORCOM //14/06/21
			endif 
			if cTipoVen == "E"
				nVendExt += nValMerc
			else
				nVendInt += nValMerc
			endif 
			nSomaComi += nValMerc * (nComis/100)
   			nTotal += nValMerc
			dbselectarea("TCQ")
 			dbskip()
 			IncRegua()
 		Enddo     
 		nTotalInt += nVendInt
 		nTotalExt += nVendExt 
 		nTotalComis += nSomaComi
    	If nlin >= 60
    		nLin+=1
 	   		@nLin,000 psay replicate("_",132)
      		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
      		nLin := 09   
    	Endif        
      	@nLin,00 psay cAux
    	@nLin,50 psay nVendInt picture "@E 999,999,999.99"
    	@nLin,65 psay nVendExt picture "@E 999,999,999.99"
    	@nLin,80 psay nTotal   picture "@E 999,999,999.99"
		@nLin,97 psay (nSomaComi/nTotal)*100 picture "@E 999.99"
		@nLin,104 psay nQtdeCli picture "@E 999,999"
		@nLin,112 psay nCota picture "@E 9,999,999.99"
		@nLin,126 psay iif(nCota > 0,nTotal*100/nCota,0) picture "@E 999.9"
       	nLin++
	Enddo
	If nlin >= 57
   		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
  		nLin := 09
 	endif
   	nLin+=1
	@nLin,000 psay replicate("-",132)
   	nLin+=1
   	@nLin,50 psay nTotalInt           picture "@E 999,999,999.99"
   	@nLin,65 psay nTotalExt           picture "@E 999,999,999.99"
   	@nLin,80 psay nTotalInt+nTotalExt picture "@E 999,999,999.99"
	@nLin,97 psay round((nTotalComis*100)/(nTotalInt+nTotalExt),2) picture "@E 999.99"
   	nLin+=1
	@nLin,000 psay replicate("-",132)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                      FIM DA IMPRESSAO                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("TCQ")
dbCloseArea()

Set Device To Screen
If aReturn[5] == 1
   Set Printer TO
   dbcommitAll()
   ourspool(wnrel)
Endif

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                   FUNCOES ESPECIFICAS                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*/
Programa  : VALIDPERG   Autor: 
Descricao : Grava Perguntas
/*/
Static Function ValidPerg()
Local _sAlias := Alias()
Local aHelp := {}
Local i, j

/*
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01","Data Emissao De  ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Data Emissao Ate ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","Repres. De  ?","","","mv_ch3","C",6,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SA3",""})
AADD(aRegs,{cPerg,"04","Repres Ate ?","","","mv_ch4","C",6,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
   If !dbSeek(cPerg+aRegs[i,2])
     RecLock("SX1",.T.)
     For j:=1 to FCount()
        If j <= Len(aRegs[i])
          FieldPut(j,aRegs[i,j])
        Endif
     Next
     MsUnlock()
   Endif
Next

//            Texto do help em português    , inglês, espanhol
AAdd(aHelp, {{"Informe a Linha de Produto"},  {"Informe a Linha de Produto"}, {"Informe a Linha de Produto"}})
AAdd(aHelp, {{"Informe a Região Geográfica a filtrar"},  {"Informe a Região Geográfica a filtrar"}, {"Informe a Região Geográfica a filtrar"}})

//SX1 (<cGrupo>, <cOrdem>, <cPergunt>, <cPergSpa>, <cPergEng>, <cVar>, <cTipo>, <nTamanho>, [nDecimal], [ nPreSel], < cGSC>, [ cValid], [ cF3], [ cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil
PutSX1(cPerg,"05","Linha(s) Produto"    ,"Linha(s) Produto","Linha(s) Produto","mv_ch5","C",99,00,00,"G","","","","","mv_Par05","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
PutSx1(cPerg,"06","Região Geográf?","Região Geográf?","Região Geográf?","mv_ch6","C",2,0,0,"G","","ZE","","","mv_par06","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")
PutSX1(cPerg,"07","Segmento(s)        ", "Segmento(s)        ", "Segmento(s)        ", "mv_ch7", "C", 99,00,00, "G",  "", "T3",  "",  "", "mv_Par07","","","","","","","","","","","","","","","","",Nil  , Nil     , Nil,cPerg)
PutSX1(cPerg,"08",   "Estado(s)          ", "Estado(s)          ", "Estado(s)          ", "mv_ch8", "C", 99,00,00, "G",  "", "",  "",  "", "mv_Par08","","","","","","","","","","","","","","","","",Nil  , Nil     , Nil ,cPerg)
*/
u_xPutSX1(cPerg,"09","Inclui B6?" ,"Inclui B6?","Inclui B6?","mv_ch9","N",6,0,1,"C","","","","","MV_PAR09","1-Sim","1-Sim","1-Sim","","2-Não","2-Não","2-Não","","","","","","","","","","Inclui B6?","Inclui B6?","Inclui B6?","BRFAT079")
u_xPutSx1(cPerg,"10","Do Cliente         ", "Do Cliente         ", "Do Cliente         ", "mv_cha", "C",  6, 0, 0, "G", " ", "SA1", " ", " ", "mv_par11", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,"BRFAT079")
u_xPutSx1(cPerg,"11","Até o Cliente      ", "Até o Cliente      ", "Até o Cliente      ", "mv_chb", "C",  6, 0, 0, "G", " ", "SA1", " ", " ", "mv_par12", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,"BRFAT079")


dbSelectArea(_sAlias)
Return

