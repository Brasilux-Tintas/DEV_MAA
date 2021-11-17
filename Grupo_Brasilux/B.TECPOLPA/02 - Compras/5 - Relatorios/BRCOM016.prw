#include "rwmake.ch"        
#INCLUDE "TOPCONN.CH"   

/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: BRCOM016     Data....: 08/01/2021       //
// Autor.....: Cleber Orati Domingues                  //
// Descriçao.: Rel. de Últ. Preço MP,     transposicao //
// planilha
// Uso.......: TECPOLPA       					       //
//                                                     //
/////////////////////////////////////////////////////////  
//                                                     //
// Variaveis utilizadas para parametros                //         
//                                                     //        
/////////////////////////////////////////////////////////

User Function BRCOM016()     
Private cCabec1,cCabec2
PRIVATE MV_PAR01
SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M")
SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3")
SetPrvt("CCABEC,CCABPRO,CNATUREZA,ARETURN,NOMEPROG,CPERG")
SetPrvt("NLASTKEY,LCONTINUA,NLIN,NCOL,WNREL,NTIPO")
SetPrvt("M_PAG,CCABEC3,NTAMNF,CSTRING")
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
titulo   :="ULTIMO PRECO MP-EM"
cDesc1   :=PADC("Este programa ira emitir o Rel. de Ultimo Preco MP-EM",74)
cDesc2   :=""
cDesc3   :=PADC(" ",74)
cCabec   :=PADC("Rel. Ultimo Preco MP-EM",27)
cCabPro  :=""
cNatureza:=""
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog :="BRCOM016"
cPerg    :="BRCOM016"
nLastKey := 0
lContinua:=.T.
nLin    := 0
nCol     := 0
wnrel    := "BRCOM016"
nTipo    := 18
m_pag    := 01     
nTamNf   := 132     // Apenas Informativo
cString  := "SB1"

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
cCabec1  := "ULTIMO PRECO MP-EM"
cCabec2  := "CODIGO       DESCRIÇÃO                                             TP UM ULT. PRC. NF ULT. PRC NET TEVE ENTR.? TEM FORM.? ULT COMPRA"
cCabec3  := ""																											      

wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,,.T.,Tamanho)

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

Local cQuery,nLin,nSomaVol
cQuery := "SELECT B1_COD AS CODIGO, B1_DESC AS DESCR, B1_TIPO AS TIPO, B1_UM AS UM, B1_UPRC AS UPRCNF, "+;
"CAST(dbo.UltPreco(B1_FILIAL, B1_COD)AS FLOAT) AS UPRCNET, "+;
"SUBSTRING(B1_UCOM,7,2)+'/'+SUBSTRING(B1_UCOM,5,2)+'/'+SUBSTRING(B1_UCOM,1,4) AS UCOMPRA,"+;
"CASE WHEN (SELECT MAX(D1_COD) FROM "+RetSqlName("SD1")+" SD1 "+;
"LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 ON (F4_FILIAL = '"+xFilial("SF4")+"') AND (D1_TES = F4_CODIGO) AND (SF4.D_E_L_E_T_ ='') "+;
"WHERE (SD1.D_E_L_E_T_ ='') AND (B1_FILIAL = D1_FILIAL) AND (B1_COD = D1_COD) AND (SB1.D_E_L_E_T_ = '') AND (F4_UPRC ='S') AND "+;
"D1_TIPO IN('N','B') ) IS NULL THEN 'NAO' ELSE 'SIM' END AS TEVEENTR, "+;
"CASE WHEN (SELECT MAX(G1_COMP) FROM "+;
RetSqlName("SG1")+" SG1 WHERE (G1_FILIAL = B1_FILIAL) AND (G1_COMP = B1_COD) AND "+;
"(SG1.D_E_L_E_T_ ='')) IS NULL THEN 'NAO' ELSE 'SIM' END AS TEMFORM "+;
"FROM "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) "+;
"WHERE (SB1.D_E_L_E_T_ = '') AND (B1_MSBLQL <> '1') AND "
do case 
case MV_PAR01 == 1
	cQuery += "(B1_TIPO = 'MP') "
case MV_PAR01 == 2
	cQuery += "(B1_TIPO = 'EM') AND (SUBSTRING(B1_COD,1,1) <> '4') "
otherwise
	cQuery += "((B1_TIPO = 'MP') OR ((B1_TIPO = 'EM') AND (SUBSTRING(B1_COD,1,1) <> '4'))) "
endcase
cQuery += "ORDER BY B1_TIPO, B1_DESC"

 TCQuery cQuery NEW ALIAS "TCQ"     
	
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
	nSomaVol := 0
    while !eof()
   		If nlin >= 60
   			nLin+=1
   			@nLin,000 psay replicate("_",132)
      		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
   	  		nLin := 09
    	Endif        
      	@nLin,00 psay alltrim(TCQ->CODIGO)
    	@nLin,13 psay SUBSTR(TCQ->DESCR,1,52)
    	@nLin,67 psay alltrim(TCQ->TIPO)
    	@nLin,70 psay alltrim(TCQ->UM)
		@nLin,73 psay TCQ->UPRCNF picture "@E 999,999.9999"
		@nLin,86 psay TCQ->UPRCNET picture "@E 999,999.9999"
		@nLin,99 psay TCQ->TEVEENTR
		@nLin,111 psay TCQ->TEMFORM
		@nLin,122 psay substr(TCQ->UCOMPRA,1,10)
       	nLin++
		dbselectarea("TCQ")
		dbskip()
		IncRegua()
	Enddo     
/*	If nlin >= 58
   		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
  		nLin := 09
 	endif
	nLin++
	@nLin,000 psay replicate("_",132)
	nLin++
	@nLin,68 psay "TOTAL VOLUMES->"
	@nLin,84 psay nSomaVol picture "@E 9,999,999"
*/
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
/*
Local _sAlias := Alias()
Local aHelp := {}

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

//SX1 (<cGrupo>, <cOrdem>, <cPergunt>, <cPergSpa>, <cPergEng>, <cVar>, <cTipo>, <nTamanho>, [nDecimal], [ nPreSel], < cGSC>, [ cValid], [ cF3], [ cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil
PutSX1(cPerg,"05","Linha(s) Produto"    ,"Linha(s) Produto","Linha(s) Produto","mv_ch5","C",99,00,00,"G","","","","","mv_Par05","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
PutSx1(cPerg,"06","Região Geográf?","Região Geográf?","Região Geográf?","mv_ch6","C",2,0,0,"G","","ZE","","","mv_par06","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")
PutSX1(cPerg,"07","Segmento(s)        ", "Segmento(s)        ", "Segmento(s)        ", "mv_ch7", "C", 99,00,00, "G",  "", "T3",  "",  "", "mv_Par07","","","","","","","","","","","","","","","","",Nil  , Nil     , Nil,cPerg)
PutSX1(cPerg,"08",   "Estado(s)          ", "Estado(s)          ", "Estado(s)          ", "mv_ch8", "C", 99,00,00, "G",  "", "",  "",  "", "mv_Par08","","","","","","","","","","","","","","","","",Nil  , Nil     , Nil ,cPerg)
u_xPutSX1(cPerg,"01","Data Emissao De  ?" ,"Data Emissao De  ?"  ,"Data Emissao De  ?"  ,"mv_ch1" ,"D",08,0,0,"G",""  ,""    ,""  ,""  , "mv_par01","","","","","","","","","","","","","","","","",Nil,Nil,Nil,"BRFAT102")
*/
u_xPutSX1(cPerg,"01","Tipo Prod?" ,"Tipo Prod?","Tipo Prod?","mv_ch1","N",6,0,1,"C","","","","","MV_PAR01","1-Matéria Prima","1-Matéria Prima","1-Matéria Prima","","2-Embalagem","2-Embalagem","2-Embalagem","3-MP+Embal","3-MP+Embal","3-MP+Embal","","","","","","","Tipo Prod?","Tipo Prod?","Tipo Prod?","BRCOM016")
Return

