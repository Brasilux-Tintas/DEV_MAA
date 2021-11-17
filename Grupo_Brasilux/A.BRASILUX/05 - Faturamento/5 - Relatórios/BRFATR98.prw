#include "rwmake.ch"        
#INCLUDE "TOPCONN.CH"   

/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: BRFATR98     Data....: 12/05/2021       //
// Autor.....: Cleber Orati Domingues                  //
// Descriçao.: Pedidos em Aberto com Incidência de FCI //
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
// mv_par07     // Segmento(s)                         //
// mv_par08     // Estado(s)                           //
// mv_par09     // do Cliente                          //
// mv_par10     // Até o Cliente                       //
// mv_par11     // Só pedidos Aprovados?               //
/////////////////////////////////////////////////////////

User Function BRFATR98()     

PRIVATE MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06,MV_PAR07,MV_PAR08,MV_PAR09,MV_MAR10
SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M")
SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3")
SetPrvt("CCABEC,CCABPRO,CNATUREZA,ARETURN,NOMEPROG,CPERG")
SetPrvt("NLASTKEY,LCONTINUA,NLIN,NCOL,WNREL,NTIPO")
SetPrvt("M_PAG,CCABEC1,CCABEC2,CCABEC3,NTAMNF,CSTRING")
SetPrvt("_TOTALG")
SetPrvt("LIMPFIN,_DTGERAD,_NRAVAR,AREGS")

CbTxt    :=""
CbCont   :=0
nOrdem   :=0
Alfa     :=0
Z        :=0
M        :=0
tamanho  :="M"
limite   :=132
titulo   :="PEDIDOS COM ICMS 4%"
cDesc1   :=PADC("Este programa ira emitir o Rel. de Pedidos com Icms 4%",74)
cDesc2   :=""
cDesc3   :=PADC(" ",74)
cCabec   :=PADC("Rel. Pedidos Icms 4%",27)
cCabPro  :=""
cNatureza:=""
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog :="BRFATR98"
cPerg    :="BRFATR98"
nLastKey := 0
lContinua:=.T.
nLin    := 0
nCol     := 0
wnrel    := "BRFATR98"
nTipo    := 18
m_pag    := 01     
nTamNf   := 132     // Apenas Informativo
cString  := "SC6"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
if !u_VldAcesso(funname())
	MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
	return 
endif 
*/

ValidPerg()
Pergunte(cPerg,.F.)   

//               0       1           2        3           4       5         6        7           8      9         10          11       12		  13
//           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
cCabec1  := ""
cCabec2  := "PEDIDO EMISSÃO    CLIENTE                                         UF REPRES               PRODUTO"
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
Local _cUf,cPerCal1,cPerCal2,cPerCal3,cAux,cQuery

_cUf := SuperGetMV("MV_ESTADO", ,"SP")

cPerCal1 := DetPer(month(date())-2,year(date()))
cPerCal2 := DetPer(month(date())-1,year(date()))
cPerCal3 := DetPer(month(date()),year(date()))


dbselectarea("SC5")
cQuery := "SELECT C6_NUM AS PEDIDO,C5_EMISSAO AS EMISSAO,C5_CLIENTE AS CODCLI,A1_NOME AS RAZAO,A1_EST AS UF,C5_VEND1 AS CODREPR,A3_NOME AS NOMEREPR,"+;
"C6_PRODUTO AS CODPRO,B1_DESC AS NOMEPRO "+;
"FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "+;
"LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = C6_FILIAL) AND (C5_NUM = C6_NUM) "+;
"LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (C6_TES = F4_CODIGO) "+;
"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (A1_COD = C5_CLIENTE) AND (A1_LOJA = C5_LOJACLI) "+;
"LEFT OUTER JOIN "+RetSqlName("SA3")+" SA3 WITH (NOLOCK) ON (SA3.D_E_L_E_T_ <> '*') AND (A3_FILIAL = '"+xFilial("SA3")+"') AND (A3_COD = C5_VEND1) "+;
"LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = '"+xFilial("SB1")+"') AND (B1_COD = C6_PRODUTO) "+;
"LEFT OUTER JOIN "+RetSqlName("CFD")+" CFD WITH (NOLOCK) ON (CFD.D_E_L_E_T_ <> '*') AND (CFD_FILIAL ='"+xFilial("CFD")+"') AND (CFD_PERVEN IN ('"+cPerCal1+"','"+cPerCal2+"','"+cPerCal3+"')) AND (CFD_COD = C6_PRODUTO) "+; 
"WHERE (SC6.D_E_L_E_T_ <> '*') AND (C6_FILIAL = '"+xFilial("SC6")+"') AND (C5_TIPO = 'N') AND (F4_ICM <> 'N') AND (A1_EST <> 'EX') AND (A1_EST <> '"+_cUf+"') AND (C6_NOTA = '') AND (CFD_FCICOD > '') AND (CFD_CONIMP >= 40.0) "
IF (SC5->(FieldPos("C5_APROVA")) > 0)
	cQuery += "AND (C5_APROVA < '2') "
ENDIF 
cQuery += "AND (C5_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"') "
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
if !empty(MV_PAR10) .AND. (MV_PAR10 >= MV_PAR09)
	cQuery += "AND (C5_CLIENTE BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"') "
endif
if (MV_PAR11 == 1) .AND. (SC5->(FieldPos("C5_APROVA")) > 0)
	cQuery += "AND (C5_APROVA = '1') "
endif


cQuery += "ORDER BY CODCLI,PEDIDO,CODPRO "
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
	nLin := 9 
	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
	While ! EoF()         
	    If nlin >= 60
   	  		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
	   	  	nLin := 09
  	 	Endif   


      	@nLin,00 psay TCQ->PEDIDO
    	@nLin,07 psay SUBSTR(TCQ->EMISSAO,7,2)+"/"+SUBSTR(TCQ->EMISSAO,5,2)+"/"+SUBSTR(TCQ->EMISSAO,1,4) 
    	@nLin,18 psay SUBSTR(TCQ->CODCLI+"-"+TCQ->RAZAO,1,48)
    	@nLin,66 psay TCQ->UF 
		@nLin,69 psay SUBSTR(TCQ->CODREPR+'-'+TCQ->NOMEREPR,1,20)
		@nLin,90 psay SUBSTR(ALLTRIM(TCQ->CODPRO)+'-'+TCQ->NOMEPRO,1,43)
       	nLin++
		dbselectarea("TCQ")
		dbskip()
		IncRegua()

	Enddo
	If nlin >= 60
   		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
  		nLin := 09
 	endif
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
U_xPutSx1(cPerg,"06",   "Região Geográf?"   , "Região Geográf?"   , "Região Geográf?"   , "mv_ch6", "C", 2,00,00, "G",  "", "ZE",  "",  "", "MV_PAR06","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],cPerg)
U_xPutSx1(cPerg,"07",   "Segmento(s)        "   , "Segmento(s)        "   , "Segmento(s)        "   , "mv_ch7", "C", 99,00,00, "G",  "", "T3",  "",  "", "MV_PAR07","","","","","","","","","","","","","","","","",Nil         ,Nil         ,Nil     ,cPerg)
U_xPutSx1(cPerg,"08",   "Estado(s)          "   , "Estado(s)          "   , "Estado(s)          "   , "mv_ch8", "C", 99,00,00, "G",  "", "",  "",  "", "MV_PAR08","","","","","","","","","","","","","","","","",Nil         ,Nil         ,Nil     ,cPerg)
u_xPutSx1(cPerg,"09","Do Cliente         ", "Do Cliente         ", "Do Cliente         ", "mv_ch9", "C",  6, 0, 0, "G", " ", "SA1", " ", " ", "MV_PAR09", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
u_xPutSx1(cPerg,"10","Até o Cliente      ", "Até o Cliente      ", "Até o Cliente      ", "mv_cha", "C",  6, 0, 0, "G", " ", "SA1", " ", " ", "MV_PAR10", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
u_xPutSX1(cPerg,"11","Somen Ped Aprovados?" ,"Somen Ped Aprovados?","Somen Ped Aprovados?" ,"mv_chb" ,"N",6 ,0,1,"C",""  ,"","","","MV_PAR11","1-Sim","1-Sim","1-Sim","","2-Não","2-Não","2-Não","","","","","","","","","","Ped Aprov?","Ped Aprov?","Ped Aprov?",cPerg)


dbSelectArea(_sAlias)
Return

Static Function DetPer(nMes,nAno)
Local cPerCal,nAuxAno,nAuxMes
nAuxAno := nAno
nAuxMes := nMes
if nMes <= 0
	nAuxAno--
	nAuxMes += 12
endif 

cPerCal := padl(alltrim(str(nAuxMes)),2,"0")+padl(alltrim(str(nAuxAno)),4,"0")

return(cPerCal)
