#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF

#include "rwmake.ch"        
#INCLUDE "TOPCONN.CH"   

User Function BRFATR05()     
//LOCAL cAux
Private tamanho,limite,cDesc1,cDesc2,cDesc3,cCabec,cCabec1,cCabec2,cCabec3
Private aReturn,nomeprog,cPerg,nLastKey,nLin,nCol,wnrel,nTipo
Private mv_par01,mv_par02,mv_par03,mv_par04,mv_par05,mv_par06,mv_par07,mv_par08,;
mv_par09,mv_par10,m_pag

m_pag = 01
tamanho  :="P"
titulo   :=" Pesos e Qtde NFs de Redespachos"
cDesc1   :=PADC("Relatorio de Pesos e Qtde NFs de Redespachos",74)
cDesc2   :=""
cDesc3   :=PADC(" ",74)
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog :="BRFATR05"
cPerg    :="BRFATR05"
nLastKey := 0
nLin    := 0
nCol     := 0
wnrel    := "BRFATR05"
nTipo    := 15
//               0       1           2        3           4       5          6  *       7  *       8  *     9    9,999,999.99 9,999,999.9912        13
//           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
cCabec1  := "Codigo Descrição                                   Peso QtdeNF     Valor NF "
cCabec2  := ""   
cCabec3  := ""
nTamNf   := 80     // Apenas Informativo
cString  := "SZB"

  if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ValidPerg()  //LGS#20200212 - Adequação de release 12.1.25 e posteriores
Pergunte(cPerg,.F.)   

wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,,.T.,Tamanho)

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

#IFDEF WINDOWS
  RptStatus({|| RptDetail()})
  Return

Static Function RptDetail()
#ENDIF
Local cQuery,nPesoTotal,nValorTotal,cFilterUser

cFilterUser := U_TRATAFILTRO(aReturn[7]) // Chama Func. p/ tratar filtro p/ SQL Server

cQuery := "SELECT F2_REDESP AS CODTRAN,MAX(A4_NOME) AS NOMEREDESP,SUM(F2_PBRUTO) AS PESO,COUNT(SF2.R_E_C_N_O_) AS QTDENF,SUM(F2_VALBRUT) AS VALORNF "+;
"FROM "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) "+;
"LEFT OUTER JOIN "+RetSqlName("SA4")+" SA4 WITH (NOLOCK) ON (SA4.D_E_L_E_T_ <> '*') AND (A4_FILIAL = '"+xFilial("SA4")+"') AND (F2_REDESP = A4_COD) "+;
"WHERE (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = '"+xFilial("SF2")+"') AND (F2_REDESP > '') AND "+;
"(F2_EMISSAO BETWEEN '"+dtos(mv_par01)+"' AND '"+dtos(mv_par02)+"') AND "+;
"(F2_REDESP BETWEEN '"+mv_par03+"' AND '"+mv_par04+"') AND "+;
IIF(!EMPTY(MV_PAR06),"(F2_EST = '"+UPPER(mv_par06)+"') AND ","")
if !empty(MV_PAR07)   
	cAux := U_RegiaoGeo(MV_PAR07)
	if !empty(cAux)
		cQuery += "(F2_EST IN ("+cAux+")) AND "
	endif 
endif		                           
cQuery += "(SUBSTRING(A4_CGC,1,8) <> '"+SUBSTR(SM0->M0_CGC,1,8)+"') "+;
"GROUP BY F2_REDESP "+;
"ORDER BY "+IIF(MV_PAR05 == 1,"PESO","QTDENF")+" DESC"

 TCQuery cQuery NEW ALIAS "TCQ" 
    
dbSelectArea("TCQ")
dbgotop()
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  SetRegua(Reccount())
  Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
  nLin = 07
  nPesoTotal := 0
  nValorTotal := 0 
  dbSelectArea("TCQ")
  dbgotop()
  
  While !EoF()
  	
    	If nlin >= 60
    		nLin+=1
    		@nLin,000 psay replicate("_",80)
      		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
      		nLin := 07    
    	Endif       
		 	nLin+=1
	    	@nLin,000 psay ALLTRIM(TCQ->CODTRAN)
	    	@nLin,007 psay substr(ALLTRIM(TCQ->NOMEREDESP),1,40)
	    	@nLin,048 psay transform(TCQ->PESO,"@E 999,999")
	    	@nLin,056 psay transform(TCQ->QTDENF,"@E 99,999")
	    	@nLin,063 psay transform(TCQ->VALORNF,"@E 9,999,999.99")
	    	dbselectarea("TCQ")
	    	dbskip()
	    	IncRegua()
	End
	If (nlin+3) >= 60
   		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
   		nLin := 07
   	Endif        
   	 
   	nLin++
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
//³                   FUNCOES ESPECIFICA                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//LGS#20200212 - Adequação de release 12.1.25 e posteriores
/*
Static Function ValidPerg()
Local aHelp := {}
// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05

PutSX1("BRFATR05","01","de Data "           ,"","","mv_ch1","D",8,00,00,"G","","","","","mv_Par01","","","","","","","","","","","","","","","","","","","","")
PutSX1("BRFATR05","02","até Data"           ,"","","mv_ch2","D",8,00,00,"G","","","","","mv_Par02","","","","","","","","","","","","","","","","","","","","")
PutSX1("BRFATR05","03","de Transportadora"  ,"","","mv_ch3","C",6,00,00,"G","","SA4","","","mv_Par03","","","","","","","","","","","","","","","","","","","","")
PutSX1("BRFATR05","04","até Transportadora" ,"","","mv_ch4","C",6,00,00,"G","","SA4","","","mv_Par04","","","","","","","","","","","","","","","","","","","","")
PutSX1("BRFATR05","05","Ordem"              ,"","","mv_ch5","C",1,00,00,"C","","","","","mv_Par05","Peso","","","","QTDENF","","","","","","","","","","","","","","","")
PutSX1("BRFATR05","06","Estado"             ,"","","mv_ch6","C",2,00,00,"G","","","","","mv_Par06","","","","","","","","","","","","","","","","","","","","")
//SX1 (<cGrupo>, <cOrdem>, <cPergunt>, <cPergSpa>, <cPergEng>, <cVar>, <cTipo>, <nTamanho>, [nDecimal], [ nPreSel], < cGSC>, [ cValid], [ cF3], [ cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil
AAdd(aHelp, {{"Informe a Região Geográfica a filtrar"},  {"Informe a Região Geográfica a filtrar"}, {"Informe a Região Geográfica a filtrar"}})
PutSx1("BRFATR05","07","Região Geográf?","Região Geográf?","Região Geográf?","mv_ch7","C",2,0,0,"G","","ZE","","","mv_par07","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")

Return*/