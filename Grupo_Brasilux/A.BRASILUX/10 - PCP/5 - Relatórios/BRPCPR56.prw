#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF
#include "RWMAKE.CH"        
#INCLUDE "TOPCONN.CH"   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BRPCPR56  º Autor ³ VIVIANE            º Data ³  22/03/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ REL. FICHAS DE ANALISES DO PRODUTO             			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCP / COMPRAS                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function BRPCPR56()     

Local cPerg
SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M")
SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3")
SetPrvt("CCABEC,CCABPRO,CNATUREZA,ARETURN,NOMEPROG")
SetPrvt("NLASTKEY,LCONTINUA,NLIN,NCOL,WNREL,NTIPO")
SetPrvt("M_PAG,CCABEC1,CCABEC2,CCABEC3,NTAMNF,CSTRING")
SetPrvt("CQUERY,_TOTALG,_TOTFIN,_TOTESTE,_TOTESTS,LIMPEST")
SetPrvt("LIMPFIN,_DTGERAD,_NRAVAR,_TOTAL,_SALIAS,AREGS")
SetPrvt("MV_PAR01,MV_PAR02")
     u_zcfga01( 'BRPCPR56' ) //LGS#2021201 - Gravação de log de utilização da rotina


CbTxt    :=""
CbCont   :=0
nOrdem   :=0
Alfa     :=0
Z        :=0
M        :=0
tamanho  :="P"
limite   :=80
titulo   :=PADC("BRPCPR56",74)
cDesc1   :=PADC("Este programa ira emitir o Rel. de Analises",74)
cDesc2   :=""
cDesc3   :=PADC(" ",74)
cCabPro  :=""
cNatureza:=""
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog :=PADC("BRPCPR56",74)
nLastKey := 0
lContinua:=.T.
nLin     := 0
nCol     := 0
wnrel    := "BRPCPR56"
nTipo    := 15
m_pag    := 01     
//               0       1           2        3           4       5          6  *       7  *       8  *     9           10        11      12        13
//           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
cCabec1  := PADC("RELATORIO DE ANALISES",80)
cCabec2  := ""   
cCabec3  := ""
nTamNf   := 80     // Apenas Informativo
cString  := "Z02"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     
  if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 


cPerg    := "BRPCPR56"
//ValidPerg(cPerg)  //LGS#20200204 - Adequação de release 12.1.25 e posteriores
Pergunte(cPerg,.F.)   
cCabec   :=PADC("RELATORIO DE ANALISES",limite," ")

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

Local cQuery
Private nQtdeLin



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetRegua(val(mv_par02)-val(mv_par01)+1)
nQtdeLin = 70 // Nro máx de linhas por página

// Logica do programa
cQuery := "SELECT Z02_FILIAL, Z02_COD, Z02_TIPO, Z02_PROD, Z02_FORN, CONVERT(VARCHAR(MAX),CONVERT(VARBINARY(MAX),Z02_TESTES)), CONVERT(VARCHAR(MAX),CONVERT(VARBINARY(MAX),Z02_RESULT)), CONVERT(VARCHAR(MAX),CONVERT(VARBINARY(MAX),Z02_LAUDO)), Z02_CONTDS, Z02_ALTERA, Z02_APROV, Z02_GEREN, "
cQuery += "Z02_DATA, CONVERT(VARCHAR(MAX),CONVERT(VARBINARY(MAX),Z02_OBS)) "
cQuery += "FROM "+RetSqlName("Z02")+" Z02 WITH (NOLOCK) "
cQuery += "WHERE D_E_L_E_T_ <> '*' AND (Z02_FILIAL = '"+xFilial("Z02")+"') AND "
cQuery += "(Z02_COD >= '"+MV_PAR01+"') AND (Z02_COD <= '"+MV_PAR02+"') AND (Z02_DATA >= '"+dtos(MV_PAR03)+"') AND (Z02_DATA <= '"+dtos(MV_PAR04)+"') "
cQuery += "ORDER BY Z02_COD, Z02_DATA"

TCQUERY cQuery ALIAS "TCQ" NEW
dbSelectArea("TCQ")
dbgotop()

do while !eof()
 	//Ir pra proxima pagina a cada Codigo de Analise diferente
	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
	nLin = 07      

	If nLastKey == 27
		exit
	Endif
 		
 		nLin++
  	@nLin,000 PSAY replicate("_",80)
  		nLin++
       	chkpulapag()
   	@nLin,000 PSAY "DATA: "+SUBSTR(Z02_DATA,7,2)+'/'+SUBSTR(Z02_DATA,5,2)+'/'+SUBSTR(Z02_DATA,1,4)
	@nLin,027 psay (" | ")
    @nLin,030 PSAY "COD. ANALISE: "+TCQ->Z02_COD
	@nLin,052 psay (" | ")
	@nLin,055 PSAY "TIPO: "+IIF(TCQ->Z02_TIPO='1','Amostra','Especificacao') 
	 	nLin++
  	@nLin,000 PSAY replicate("_",80)
		nLin++
       	chkpulapag()  
  
    @nLin,000 PSAY "MATERIAL: "+TCQ->Z02_PROD
 	@nLin,027 PSAY (" | ")
    @nLin,030 PSAY "FORNECEDOR: "+TCQ->Z02_FORN+" - "+Posicione('SA2', 1, xFilial('SA2')+TCQ->Z02_FORN,'A2_NOME')
		nLin++
  	@nLin,000 PSAY replicate("_",80)
  		nLin++
       	chkpulapag()
   		
	@nLin,000 PSAY PADC("VERIFICACOES E TESTES REALIZADOS",limite," ")
		nLin++
  	@nLin,000 PSAY replicate("_",80)
  		nLin++
       	chkpulapag()
    
	@nLin,000 PSAY TRIM(Z02->Z02_TESTES)
		nLin++
  	@nLin,000 PSAY replicate("_",80)
  		nLin++
       	chkpulapag()
        
   	@nLin,000 PSAY padc("RESULTADOS ENCONTRADOS",limite," ")
		nLin++
  	@nLin,000 PSAY replicate("_",80)
  		nLin++
       	chkpulapag()
	@nLin,000 PSAY TRIM(Z02->Z02_RESULT)   	
    	nLin++
  	@nLin,000 PSAY replicate("_",80)
  		nLin++
       	chkpulapag()
    	
    @nLin,000 PSAY padc("ANALISES E LAUDO FINAL",limite," ")
    	nLin++
  	@nLin,000 PSAY replicate("_",80)
  		nLin++
       	chkpulapag()
   
   	@nLin,000 PSAY TRIM(Z02->Z02_LAUDO)   	
   		nLin++
  	@nLin,000 PSAY replicate("_",80)
  		nLin++
       	chkpulapag()
   		
	@nLin,000 psay "APROVADO?: "+IIF(TCQ->Z02_APROV='1','Sim','Nao') //+Z02->Z02_APROV			
   	@nLin,027 psay (" | ")
	@nLin,030 psay "CONTINUAR DESENVOLVIMENTO?: "+IIF(TCQ->Z02_CONTDS='1','Sim','Nao') //+Z02->Z02_CONTDS
		nLin++
  	@nLin,000 PSAY replicate("_",80)
  		nLin++
       	chkpulapag()
    @nLin,000 PSAY "PROPOR ALTERACOES?: "+IIF(TCQ->Z02_ALTERA='1','Sim','Nao') //+Z02->Z02_ALTERA
 	@nLin,027 PSAY (" | ")
	@nLin,030 PSAY "RESPONSAVEL: "+UsrRetName(Z02->Z02_GEREN)
		nLin++
  	@nLin,000 PSAY replicate("_",80)
  		nLin++
        chkpulapag()
   	nLin++
       	chkpulapag()
        
   	@nLin,000 PSAY PADC("OBSERVACOES",limite," ")
		nLin++
  	@nLin,000 PSAY replicate("_",80)
  		nLin++
       	chkpulapag()
	@nLin,000 PSAY TRIM(Z02->Z02_OBS)   	
    	nLin++
  	@nLin,000 PSAY replicate("_",80)
  		nLin++
       	chkpulapag()
       
dbselectarea("TCQ")
dbskip()
IncRegua()
end 
	
dbSelectArea("TCQ")
dbclosearea()
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                      FIM DA IMPRESSAO                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Set Device To Screen
If aReturn[5] == 1
   Set Printer TO
   dbcommitAll()
   ourspool(wnrel)
Endif

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                   FUNCOES ESPECIFICA                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//LGS#20200204 - Adequação de release 12.1.25 e posteriores
/*Static Function ValidPerg(cPerg)
Local aHelp := {}

// Texto do help      pt   , en  ,  sp
AAdd(aHelp, {{"Da Ficha"} , {""}, {""}})
AAdd(aHelp, {{"Ate Ficha"}, {""}, {""}})
AAdd(aHelp, {{"Da Data"}  , {""}, {""}})
AAdd(aHelp, {{"Ate Data"} , {""}, {""}})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01        	// Da Ficha? 							 ³
//³ mv_par02        	// Ate Ficha?		                     ³ 
//³ mv_par03        	// Da Data?				                 ³
//³ mv_par04        	// Ate Data?			                 ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//SX1 (<cGrupo>, <cOrdem>, <cPergunt>, <cPergSpa>, <cPergEng>, <cVar>, <cTipo>, <nTamanho>, [nDecimal], [ nPreSel], < cGSC>, [ cValid], [ cF3], [ cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil
PutSX1(cPerg,"01","Da Ficha?"   ,"","","mv_ch1","C",06,00,00,"G","","","","","mv_Par01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
PutSX1(cPerg,"02","Ate Ficha?"  ,"","","mv_ch2","C",06,00,00,"G","","","","","mv_Par02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")
PutSX1(cPerg,"03","Da Data?"    ,"","","mv_ch3","D",08,00,00,"G","","","","","mv_Par03","","","","","","","","","","","","","","","","",aHelp[3,1],aHelp[3,2],aHelp[3,3],"")
PutSX1(cPerg,"04","Ate Data?"   ,"","","mv_ch4","D",08,00,00,"G","","","","","mv_Par04","","","","","","","","","","","","","","","","",aHelp[4,1],aHelp[4,2],aHelp[4,3],"")

return*/

Static Function chkpulapag()
	If nlin >= nQtdeLin
 		nLin+=1
   		@nLin,000 psay replicate("_",limite)
     	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
      	nLin := 07
   	Endif    

return
