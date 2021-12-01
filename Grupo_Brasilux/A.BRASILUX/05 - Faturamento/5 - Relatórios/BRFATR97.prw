#include "rwmake.ch"        
#INCLUDE "TOPCONN.CH"   

/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: BRFATR97     Data....: 22/03/2021       //
// Autor.....: Cleber Orati Domingues                  //
// Descriçao.: Comissoes sobre Vendas				   //
// Uso.......: Brasilux/Resina/Dissoltex   		       //
//                                                     //
/////////////////////////////////////////////////////////  
//                                                     //
// Variaveis utilizadas para parametros                //         
//                                                     //        
// mv_par01     // Per. de                             //
// mv_par02     // Per Ate                             //
// mv_par03     // Repr. de                            //
// mv_par04     // Repr. Ate                           //
// mv_par05     // Linha(s) Produto                    //
// mv_par06     // Região Geográf?                     //
// mv_par07     // Segmento(s)          		       //
// mv_par08     // Estado(s)                           //
// mv_par09     // Inclui B6?                          //
// mv_par10     // do Cliente                          //
// mv_par11     // Até o Cliente                       //
// mv_par12     // Só pedidos Aprovados?               //
/////////////////////////////////////////////////////////

User Function BRFATR97()     

PRIVATE MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06,MV_PAR07,MV_PAR08,MV_PAR09,MV_MAR10,MV_PAR11,MV_PAR12
SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M")
SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3")
SetPrvt("CCABEC,CCABPRO,CNATUREZA,ARETURN,NOMEPROG,CPERG")
SetPrvt("NLASTKEY,LCONTINUA,NLIN,NCOL,WNREL,NTIPO")
SetPrvt("M_PAG,CCABEC1,CCABEC2,CCABEC3,NTAMNF,CSTRING")
SetPrvt("_TOTALG")
SetPrvt("LIMPFIN,_DTGERAD,_NRAVAR,AREGS")
     u_zcfga01( 'BRFATR97' ) //LGS#2021201 - Gravação de log de utilização da rotina
CbTxt    :=""
CbCont   :=0
nOrdem   :=0
Alfa     :=0
Z        :=0
M        :=0
tamanho  :="M"
limite   :=132
titulo   :="COMISSOES SOBRE VENDAS"
cDesc1   :=PADC("Este programa ira emitir o Rel. de Vendas por Representante",74)
cDesc2   :=""
cDesc3   :=PADC(" ",74)
cCabec   :=PADC("Rel. Vend. por Repres",27)
cCabPro  :=""
cNatureza:=""
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog :="BRFATR97"
cPerg    :="BRFATR97"
nLastKey := 0
lContinua:=.T.
nLin    := 0
nCol     := 0
wnrel    := "BRFATR97"
nTipo    := 18
m_pag    := 01     
nTamNf   := 80     // Apenas Informativo
cString  := "SC5"

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
cCabec2  := "Codigo  Razão Social                                      V. Int         V. Ext          Total  Comis(%)  Qt Cli         Cota    (%)"
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

Local cRepres,cAux,nCol,nSomaComi,nVendInt,nVendExt,nTotalExt,cTipoVen,nValMerc,nTotalComis,cQuery,cFatB6,nQtdeCli
Local nCCampanha,nTotCampanha,_nTotVlrSolv,nTotComisSolv,nCVariavel,nTotVariavel,nCDistrib,nTotDistrib,lCamp,lThinner

cFatB6 = iif(MV_PAR09 == 1, "0.7","1.0")
dbselectarea("SC5")
cQuery := "WITH TMP AS (SELECT C6_NUM AS PEDIDO,MAX(C5_EMISSAO) AS EMISSAO, "+;
"C5_CLIENTE AS CLIENTE,MAX(A1_NOME) AS A1_NOME,SUM(C6_VALOR/(CASE WHEN C5_ESPECI4 > '' THEN "+cFatB6+" ELSE 1.0 END)) AS VALMERC, "+;
"C5_VEND1 AS REPRES,MAX(A1_CLAS) AS TIPOCLI "+;
"FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "+;
"LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = '"+xFilial("SC5")+"') AND (C6_NUM = C5_NUM) "+;
"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (C5_CLIENTE = A1_COD) "+;
"LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (C6_TES = F4_CODIGO) "+;
"WHERE (SC6.D_E_L_E_T_ <> '*') AND (C6_FILIAL = '"+xFilial("SC6")+"') AND (C5_TIPO = 'N') "
IF (SC5->(FieldPos("C5_APROVA")) > 0)
	cQuery += "AND (C5_APROVA < '2') "
ENDIF 
cQuery += "AND ((F4_DUPLIC <> 'N') "
if MV_PAR09 == 1
	cQuery += " OR (C6_TES = '519')"
endif
cQuery += ") AND (C5_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"') "
IF !EMPTY(MV_PAR04) .AND. (MV_PAR04 >= MV_PAR03)
	cQuery += "AND (C5_VEND1 BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"') "
ENDIF 
if !empty(MV_PAR05)
	cQuery += "AND (LEN(C6_PRODUTO) = 12) AND "+U_ParamSql("SUBSTRING(C6_PRODUTO,4,2)",MV_PAR05)+" "
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
	cQuery += "AND (C5_CLIENTE BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"') "
endif
if (MV_PAR12 == 1) .AND. (SC5->(FieldPos("C5_APROVA")) > 0)
	cQuery += " AND (C5_APROVA = '1')"
endif


cQuery += "GROUP BY C6_NUM,C5_CLIENTE,C5_VEND1) "
cQuery += ",TMP1 AS (SELECT DISTINCT CLIENTE ,REPRES FROM TMP) "
cQuery += "SELECT PEDIDO,MAX(EMISSAO) AS EMISSAO,CLIENTE,MAX(A1_NOME) AS A1_NOME,MAX(TIPOCLI) AS TIPOCLI,SUM(VALMERC) AS VALMERC, "+;
"REPRES, "+;
"QTDECLI = (SELECT COUNT(CLIENTE) FROM TMP1 WHERE REPRES = TMP.REPRES) "+;
"FROM TMP "+;
"GROUP BY PEDIDO,CLIENTE,REPRES "+;
"ORDER BY REPRES,PEDIDO"
 TCQuery cQuery NEW ALIAS "TCQ"     
	dbselectarea("SC5") // Pedidos
	dbsetorder(1)
	dbselectarea("SA3") // Vendedores
	dbsetorder(1)
	dbselectarea("SX5") //Cadastro genérico de tabelas
	dbsetorder(1)
	
	
//	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
// 	nLin := 08
  	dbSelectArea("TCQ")
  	dbgotop()
  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa  regua de impressao                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  	SetRegua(Reccount())
  	nTotalInt := 0.0
  	nTotalExt := 0.0
	nTotalComis := 0.0
		nCCampanha := 0.0
		nTotCampanha := 0.0
		_nTotVlrSolv := 0.0
		nTotComisSolv := 0.0
		nTotDistrib := 0.0
		nCDistrib := 0.0				
		nCVariavel := 0.0
		nTotVariavel := 0.0
	nLin := 9 
	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
	While ! EoF()         
	    If nlin >= 60
   	  		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
	   	  	nLin := 09
  	 	Endif   
		nCota := 0      
   	   	cRepres = alltrim(TCQ->REPRES)   
    	cAux := cRepres
    	dbselectarea("SA3")
    	dbseek(xFilial("SA3")+cRepres)
    	if found()
    		cAux += "-"+alltrim(SA3->A3_NOME)
			nCota := SA3->A3_COTA
    	endif    		
       
		nCol = 40 - int(len(cAux)/2)
       	nSomaComi := 0
		nVendInt := 0
		nVendExt := 0
		nQtdeCli := TCQ->QTDECLI //Qtde de Clientes diferentes
	  	dbselectarea("TCQ")
    	while !eof() .AND. (alltrim(TCQ->REPRES) == cRepres)
    		If nlin >= 58
    			nLin+=1
 	   			@nLin,000 psay replicate("_",132)
	      		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
    	  		nLin := 09
	    	Endif        
    		nComis := 0
			cTipoVen = "I" 
			lCamp := .f. //Campanha de venda?
			nValMerc := TCQ->VALMERC
   			dbselectarea("SC5")
			dbseek(xFilial("SC5")+TCQ->PEDIDO)
			if found()                                           
	   			if !empty(SC5->C5_TIPOVEN)
	   				cTipoVen = SC5->C5_TIPOVEN
		   		endif
				nComis := SC5->C5_COMIS1 //SC5->C5_PORCOM 
				IF (SC5->(FieldPos("C5_XCONF")) > 0) 
					lCamp := SC5->C5_XCONF //Pedido originário de Campanha de Vendas
				ENDIF 
			endif 

			lThinner := .f.
			dbselectarea("SX5")
			dbseek(xFilial("SC5")+"96"+TCQ->PEDIDO)
			if found() .and. (ALLTRIM(SX5->X5_DESCRI) == "S") //Se for Solvente
				lThinner := .t.
			endif 
			
			do case 
			case lCamp //Pedido originário de Campanha de Vendas
				nCCampanha += nValMerc * (nComis/100)
				nTotCampanha += nValMerc
			case lThinner
				nTotComisSolv += nValMerc * (nComis/100)
				_nTotVlrSolv += nValMerc
			case TCQ->TIPOCLI = "D" // Venda p. Com/Distrib
				nCDistrib += nValMerc * (nComis/100)				
				nTotDistrib += nValMerc
			otherwise  
				nCVariavel += nValMerc * (nComis/100)
				nTotVariavel += nValMerc
			endcase 
			nSomaComi += nValMerc * (nComis/100)
	 		nTotalComis += nValMerc * (nComis/100)
			if cTipoVen == "E"
				nVendExt += nValMerc
		 		nTotalExt += nValMerc 
			else
				nVendInt += nValMerc
		 		nTotalInt += nValMerc
			endif 
			dbselectarea("TCQ")
 			dbskip()
 			IncRegua()
 		Enddo     
    	If nlin >= 60
    		nLin+=1
 	   		@nLin,000 psay replicate("_",132)
      		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
      		nLin := 09   
    	Endif        
      	@nLin,00 psay cAux
    	@nLin,50 psay nVendInt picture "@E 999,999,999.99"
    	@nLin,65 psay nVendExt picture "@E 999,999,999.99"
    	@nLin,80 psay nVendInt+nVendExt   picture "@E 999,999,999.99"
		@nLin,97 psay round((nSomaComi*100/(nVendInt+nVendExt)),3) picture "@E 999.999"
		@nLin,105 psay nQtdeCli picture "@E 999,999"
		@nLin,113 psay nCota picture "@E 9,999,999.99"
		@nLin,127 psay iif(nCota > 0,(nVendInt+nVendExt)*100/nCota,0) picture "@E 999.9"
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
	@nLin,97 psay round((nTotalComis*100)/(nTotalInt+nTotalExt),3) picture "@E 999.999"
   	nLin+=1
	@nLin,000 psay replicate("-",132)

	   	nLin+=1
		If nlin >= 57
			Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
			nLin := 09
		endif
		cAux := "CAMPANHA : "+alltrim(TRANSFORM(nCCampanha,"@E 999,999,999.99"))+"("+iif(nTotCampanha > 0,alltrim(transform(nCCampanha*100/nTotCampanha,"@E 999.9")),"0")+"%)|"
		cAux += "THINNER : "+alltrim(TRANSFORM(nTotComisSolv,"@E 999,999,999.99"))+"("+iif(_nTotVlrSolv > 0,alltrim(transform(nTotComisSolv*100/_nTotVlrSolv,"@E 999.9")),"0")+"%)|"
		cAux += "COM/DISTRIB : "+alltrim(TRANSFORM(nCDistrib,"@E 999,999,999.99"))+"("+iif(nTotDistrib > 0,alltrim(transform(nCDistrib*100/nTotDistrib,"@E 999.9")),"0")+"%)|"
		cAux += "VARIAVEL(PADRAO) : "+alltrim(TRANSFORM(nCVariavel,"@E 999,999,999.99"))+"("+iif(nTotVariavel > 0,alltrim(transform(nCVariavel*100/nTotVariavel,"@E 999.9")),"0")+"%)|"

		@nLin,00 psay cAux
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

AAdd(aHelp, {{"Informe a Linha de Produto"},  {"Informe a Linha de Produto"}, {"Informe a Linha de Produto"}})
AAdd(aHelp, {{"Informe a Região Geográfica a filtrar"},  {"Informe a Região Geográfica a filtrar"}, {"Informe a Região Geográfica a filtrar"}})

u_xPutSX1(cPerg,"01","Data Emissao De  ?"      ,"Data Emissao De  ?" ,"Data Emissao De  ?"  ,"mv_ch1" ,"D",08,0,0,"G",""  ,"","","","MV_PAR01",""     ,""     ,""     ,"",""     ,""     ,""     ,"","","","","","","","","",Nil         ,Nil         ,Nil         ,cPerg)
u_xPutSX1(cPerg,"02","Data Emissao Ate ?"      ,"Data Emissao Ate ?" ,"Data Emissao Ate ?"  ,"mv_ch2" ,"D",08,0,0,"G",""  ,"","","","MV_PAR02",""     ,""     ,""     ,"",""     ,""     ,""     ,"","","","","","","","","",Nil         ,Nil         ,Nil         ,cPerg)
u_xPutSx1(cPerg,"03","Repres. De  ?", "Repres. De  ?", "Repres. De  ?", "mv_ch3", "C",  6, 0, 0, "G", " ", "SA3", " ", " ", "MV_PAR03", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
u_xPutSx1(cPerg,"04","Repres Ate ?"       , "Repres Ate ?"       , "Repres Ate ?"       , "mv_ch4", "C",  6, 0, 0, "G", " ", "SA3", " ", " ", "MV_PAR04", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
U_xPutSx1(cPerg,"05","Linha(s) Produto"   , "Linha(s) Produto"   , "Linha(s) Produto"   , "mv_ch5", "C",  99, 0, 0, "G", " ", "",  "",  "", "MV_PAR05","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],cPerg)
U_xPutSx1(cPerg,"06",   "Região Geográf?"   , "Região Geográf?"   , "Região Geográf?"   , "mv_ch6", "C", 2,00,00, "G",  "", "",  "ZE",  "", "MV_PAR06","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],cPerg)
U_xPutSx1(cPerg,"07",   "Segmento(s)        "   , "Segmento(s)        "   , "Segmento(s)        "   , "mv_ch7", "C", 99,00,00, "G",  "", "",  "T3",  "", "MV_PAR07","","","","","","","","","","","","","","","","",Nil         ,Nil         ,Nil     ,cPerg)
U_xPutSx1(cPerg,"08",   "Estado(s)          "   , "Estado(s)          "   , "Estado(s)          "   , "mv_ch8", "C", 99,00,00, "G",  "", "",  "",  "", "MV_PAR08","","","","","","","","","","","","","","","","",Nil         ,Nil         ,Nil     ,cPerg)
u_xPutSX1(cPerg,"09","Inclui B6?"              ,"Inclui B6?"         ,"Inclui B6?"          ,"mv_ch9" ,"N",6 ,0,1,"C",""  ,"","","","MV_PAR09","1-Sim","1-Sim","1-Sim","","2-Não","2-Não","2-Não","","","","","","","","","","Inclui B6?","Inclui B6?","Inclui B6?",cPerg)
u_xPutSx1(cPerg,"10","Do Cliente         ", "Do Cliente         ", "Do Cliente         ", "mv_cha", "C",  6, 0, 0, "G", " ", "SA1", " ", " ", "mv_par11", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
u_xPutSx1(cPerg,"11","Até o Cliente      ", "Até o Cliente      ", "Até o Cliente      ", "mv_chb", "C",  6, 0, 0, "G", " ", "SA1", " ", " ", "mv_par12", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
u_xPutSX1(cPerg,"12","Somen Ped Aprovados?" ,"Somen Ped Aprovados?","Somen Ped Aprovados?" ,"mv_chc" ,"N",6 ,0,1,"C",""  ,"","","","MV_PAR12","1-Sim","1-Sim","1-Sim","","2-Não","2-Não","2-Não","","","","","","","","","","Ped Aprov?","Ped Aprov?","Ped Aprov?",cPerg)


dbSelectArea(_sAlias)
Return

