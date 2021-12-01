#include "rwmake.ch"        
#INCLUDE "TOPCONN.CH"   

/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: BRFAT061     Data....: 03/03/02         //
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
// mv_par01     // Repr. de                            //
// mv_par02     // Repr. Ate                           //
/////////////////////////////////////////////////////////

User Function BRFAT061()     

Private mv_par07,mv_par08
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
tamanho  :="P"
limite   :=132
titulo   :="FATURAMENTO POR REPRESENTANTE"
cDesc1   :=PADC("Este programa ira emitir o Rel. de Faturamento por Representante",74)
cDesc2   :=""
cDesc3   :=PADC(" ",74)
cCabec   :=PADC("Rel. Fat. por Repres.",27)
cCabPro  :=""
cNatureza:=""
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog :="BRFAT061"
cPerg    :="BRFT61"
nLastKey := 0
lContinua:=.T.
nLin    := 0
nCol     := 0
wnrel    := "BRFAT061"
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
     u_zcfga01( 'BRFAT061' ) //LGS#2021201 - Gravação de log de utilização da rotina
//ValidPerg()
Pergunte("BRFT61",.F.)   

//               0       1           2        3           4       5         6        7           8
//           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678
cCabec1  := ""
cCabec2  := "NRO NF    EMISSAO  CLIENTE                                   VLR. PROD. COMIS(%)"
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

Local cRepres,cAux,nCol,nSomaComi,nTotal,nVendInt,nVendExt,nTotalExt,cTipoVen,nValMerc,cQuery

cQuery := "SELECT D2_DOC AS F2_DOC,D2_SERIE AS F2_SERIE,MAX(D2_EMISSAO) AS F2_EMISSAO, "+;
"D2_CLIENTE AS F2_CLIENTE,MAX(A1_NOME) AS A1_NOME,SUM(D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END)) AS F2_VALMERC, "+;
"MAX(F2_VEND1) AS F2_VEND1,MAX(F2_PEDIDO) AS PEDIDO "+;
"FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) "+;
"LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = F2_FILIAL) AND (D2_SERIE = F2_SERIE) AND (D2_DOC = F2_DOC) AND (D2_CLIENTE = F2_CLIENTE) "+;
"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (D2_CLIENTE = A1_COD) "+;
"LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (D2_TES = F4_CODIGO) "+;
"LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = '"+xFilial("SC5")+"') AND (D2_PEDIDO = C5_NUM) "+;
"WHERE (SD2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = '"+xFilial("SD2")+"') AND (D2_TIPO = 'N') AND ((F4_DUPLIC <> 'N') OR (D2_TES = '519')) AND (F2_VEND1 > '') "+;
"AND (D2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"') "+;
"AND (F2_VEND1 BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"') "
//Chamado 007514, tirar códigos de repres. especificos do Glaidon 
if __cUserId = "000282"
	cQuery += "AND (F2_VEND1 NOT IN ('000250','000444','000303','000333','000438','000276')) "
endif 
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
	cQuery += "AND ("+U_ParamSql("A1_SATIV2",MV_PAR07)+") "
endif
if !empty(MV_PAR08)
	cQuery += "AND ("+U_ParamSql("A1_EST",MV_PAR08)+") "
endif
cQuery += "GROUP BY D2_SERIE,D2_DOC,D2_CLIENTE "         
cQuery += "UNION ALL "
//Devoluções
cQuery += "SELECT D1_DOC AS F2_DOC,D1_SERIE AS F2_SERIE,MAX(D1_DTDIGIT) AS F2_EMISSAO, "+;
"D1_FORNECE AS F2_CLIENTE,MAX(A1_NOME) AS A1_NOME,-1.0*SUM(D1_TOTAL) AS F2_VALMERC, "+;
"MAX(F2_VEND1) AS F2_VEND1,MAX(F2_PEDIDO) AS PEDIDO "+;
"FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK) "
cQuery := cQuery + "LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = '"+xFilial("SF2")+"') AND (D1_NFORI = F2_DOC) AND (D1_SERIORI = F2_SERIE) AND (D1_FORNECE = F2_CLIENTE) "
cQuery := cQuery + "LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (F2_CLIENTE = A1_COD) "
cQuery := cQuery + "LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (D1_TES = F4_CODIGO) "
cQuery := cQuery + "WHERE (SD1.D_E_L_E_T_ <> '*') AND (SD1.D1_FILIAL = '"+xFilial("SD1")+"') AND (D1_TIPO = 'D') "+;
"AND (F4_DUPLIC <> 'N') AND (F2_VEND1 > '') "+;
"AND (D1_DTDIGIT BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"') "+;
"AND (F2_VEND1 BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"') "
//Chamado 007514, tirar códigos de repres. especificos do Glaidon 
if __cUserId = "000282"
	cQuery += "AND (F2_VEND1 NOT IN ('000250','000444','000303','000333','000438','000276')) "
endif 
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
	cQuery += "AND ("+U_ParamSql("A1_SATIV2",MV_PAR07)+") "
endif
if !empty(MV_PAR08)
	cQuery += "AND ("+U_ParamSql("A1_EST",MV_PAR08)+") "
endif
cQuery += "GROUP BY D1_SERIE,D1_DOC,D1_FORNECE "+;
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
	While ! EoF()         
   		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
   		nLin := 08    

    	nLin++
    	@nLin,00 psay replicate("-",80)
    	cRepres = TCQ->F2_VEND1   
    	cAux := cRepres
    	dbselectarea("SA3")
    	dbseek(xFilial("SA3")+cRepres)
    	if found()
    		cAux += "-"+alltrim(SA3->A3_NOME)
    	endif
    		
    	nLin++    
		nCol = 40 - int(len(cAux)/2)
    	@nLin,nCol psay cAux
    	nLin++
    	@nLin,00 psay replicate("-",80)
    	
		nSomaComi := 0
		nTotal := 0
		nVendInt := 0
		nVendExt := 0
    	dbselectarea("TCQ")
    	while !eof() .AND. (TCQ->F2_VEND1 == cRepres)

    		If nlin >= 58
    			nLin+=1
 	   			@nLin,000 psay replicate("_",80)
	      		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
    	  		nLin := 08    
	    	Endif        
    		nLin++
    		@nLin,000 psay alltrim(TCQ->F2_SERIE)+TCQ->F2_DOC
    		cAux = TCQ->F2_EMISSAO
    		@nLin,10 psay substr(cAux,7,2)+"/"+substr(cAux,5,2)+"/"+substr(cAux,3,2)
   			@nLin,19 psay TCQ->F2_CLIENTE+"-"+SUBSTR(TCQ->A1_NOME,1,34)
			nComis := 0
			cTipoVen = "I" 
			nValMerc := TCQ->F2_VALMERC
	   			dbselectarea("SC5")
				dbseek(xFilial("SC5")+TCQ->PEDIDO)
				if found()                                           
	   				if !empty(SC5->C5_TIPOVEN)
	   					cTipoVen = SC5->C5_TIPOVEN
		   			endif
					//nComis := SC5->C5_PORCOM 
					nComis := SC5->C5_COMIS1 
				endif  
				if cTipoVen == "E"
					nVendExt += nValMerc
				else
					nVendInt += nValMerc
				endif 
				nSomaComi += nValMerc * (nComis/100)
   			@nLin,61 psay nValMerc picture "@E 999,999.99"
			@nLin,72 psay nComis picture "@E 999.99"
			@nLin,79 psay cTipoVen
			nTotal += nValMerc
			dbselectarea("TCQ")
 			dbskip()
 			IncRegua()
 		Enddo     
 		nTotalInt += nVendInt
 		nTotalExt += nVendExt 
    	If nlin >= 58
    		nLin+=1
 	   		@nLin,000 psay replicate("_",80)
      		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
      		nLin := 08    
    	Endif        
    	nLin++
    	@nLin,00 psay replicate("-",80)
    	nLin++ 
    	@nLin,00 psay "V. INT: "
    	@nLin,08 psay nVendInt picture "@E 9,999,999.99"
    	@nLin,21 psay "V. EXT: "
    	@nLin,30 psay nVendExt picture "@E 9,999,999.99"
    	@nLin,50 psay "TOTAIS : "
    	@nLin,59 psay nTotal picture "@E 9,999,999.99"
		@nLin,74 psay (nSomaComi/nTotal)*100 picture "@E 999.99"
    	nLin++
    	@nLin,00 psay replicate("-",80)
	Enddo
   	If nlin >= 60
   		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
   		nLin := 08
   	Endif         
   	nLin+=1
   	@nLin,000 psay replicate("_",80)

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
/* DESABILITADO RELEASE 12.1.25
Static Function ValidPerg()
Local _sAlias := Alias()
Local aHelp := {}
Local i, j


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
PutSX1(cPerg,"07","Segmento(s)    ","Segmento(s)    ", "Segmento(s)   ","mv_ch7", "C", 99,00,00, "G",  "", "T3",  "",  "", "mv_par07","","","","","","","","","","","","","","","","",Nil  , Nil     , Nil,cPerg)
PutSX1(cPerg,"08",   "Estado(s)          ", "Estado(s)          ", "Estado(s)          ", "mv_ch8", "C", 99,00,00, "G",  "", "",  "",  "", "mv_Par08","","","","","","","","","","","","","","","","",Nil  , Nil     , Nil ,cPerg)


dbSelectArea(_sAlias)
Return

*/
