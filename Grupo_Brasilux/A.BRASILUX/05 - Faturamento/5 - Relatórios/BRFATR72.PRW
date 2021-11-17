#IFNDEF WINDOWS
 #DEFINE PSAY SAY
#ENDIF

#include "rwmake.ch"        
#INCLUDE "TOPCONN.CH"   

/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: BRFATR72     Data....: 01/06/20         //
// Autor.....: Cleber Orati Domingues                  //
// Descriçao.: Clientes que não faturam no Período	   //
// Uso.......: Todas as Empresas 						//
//                                                     //
/////////////////////////////////////////////////////////  
//                                                     //
// Variaveis utilizadas para parametros                //         
//                                                     //        
// mv_par01     // Há quantos dias?		               //
// mv_par02  // Representante de ?						//
// mv_par03  // Representante até ?						//
// mv_par04  // Somente Esta Filial? 				//
/////////////////////////////////////////////////////////

User Function BRFATR72()     
Local CbTxt,CbCont,nOrdem,Alfa,Z,M
Private tamanho,limite,titulo,cDesc1,cDesc2,cDesc3,cCabec,cCabPro
Private cNatureza,aReturn,nomeprog,cPerg,nLastKey,lContinua,nLin,nCol,wnrel,;
nTipo,m_pag,nTamNf,cString

CbTxt    :=""
CbCont   :=0
nOrdem   :=0
Alfa     :=0
Z        :=0
M        :=0
tamanho  :="M"
limite   :=136
titulo   :="CLIENTES QUE NAO FATURAM"
cDesc1   :=PADC("Este programa ira emitir o Rel. Clientes que Nao Faturam.",74)
cDesc2   :=""
cDesc3   :=PADC(" ",74)
cCabec   :=PADC("Cliente que Nao Faturam",27)
cCabPro  :=""
cNatureza:=""
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog :="BRFATR72"
cPerg    :="BRFATR72"
nLastKey := 0
lContinua:=.T.
nLin    := 0
nCol     := 0
wnrel    := "BRFATR72"
nTipo    := 15
m_pag    := 01     
nTamNf   := 136     // Apenas Informativo
cString  := "SA1"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 

ValidPerg(cPerg)
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

Local cData,dAux,nCont,cNomeCli,cNomeVend

cData = dtos(date() - mv_par01)
//CODIGO:  RAZAO :  ESTADO:  REPRES:  ULTIMA COMPRA:
cQuery := "SELECT F2_CLIENTE,F2_VEND1, MAX(F2_EMISSAO) AS EMISSAO "+; 
"FROM "+RetSqlName("SF2")+" SF2 "
IF MV_PAR05 == 1
	cQuery += "LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (F2_CLIENTE = A1_COD) AND (F2_LOJA = A1_LOJA) "
ENDIF 
cQuery += "WHERE (SF2.D_E_L_E_T_ <> '*') "
IF MV_PAR04 == 1
	cQuery += "AND (F2_FILIAL = '"+xFilial("SF2")+"') "
ENDIF 
cQuery += "AND (F2_TIPO = 'N') AND (F2_DUPL > '') "
IF MV_PAR05 == 1
	cQuery += "AND (SA1.A1_MSBLQL <> '1') "
ENDIF 
IF !empty(MV_PAR03) .AND. (MV_PAR03 >= MV_PAR02)
	cQuery += "AND (F2_VEND1 BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"') "
ENDIF 
cQuery += "GROUP BY F2_CLIENTE,F2_VEND1 HAVING MAX(F2_EMISSAO) <= '"+cData+"' ORDER BY EMISSAO"

TCQuery cQuery NEW ALIAS "TCQ" 
    
//               0       1           2        3           4       5          6  *       7  *       8  *     9           10        11      12        13      14        15          16       17        18        19
//           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
cCabec2  := "CLIENTE                                                   UF  REPRES                                        ULT. COMPRA  QTDE DIAS"

cCabec1  := "CLIENTES QUE NAO FATURAM HA' MAIS DE "+ALLTRIM(STR(MV_PAR01))+" DIAS"
cCabec3  := ""
Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
nLin = 08
dbselectarea("SA1")
dbsetorder(1)
dbselectarea("SA3")
dbsetorder(1)

dbSelectArea("TCQ")
dbgotop()
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetRegua(Reccount())   
nCont = 0
While ! EoF()         
	nCont++
  	if (nLin > 60)
  		nLin++
  		@nLin,000 psay replicate("_",136)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
		nLin := 08
	endif   
	cNomeCli := ""
	cNomeVend := ""
	dbselectarea("SA1")
	dbseek(xFilial("SA1")+TCQ->F2_CLIENTE)
	if found()
		cNomeCli := substr(SA1->A1_NOME,1,40)
	endif 
	IF !empty(TCQ->F2_VEND1)
			dbselectarea("SA3")
			dbseek(xFilial("SA3")+TCQ->F2_VEND1)
			cNomeVend := iif(found(),substr(SA3->A3_NOME,1,40),"")
	ENDIF
   	nLin++
    @nLin,00  psay TCQ->F2_CLIENTE+"-"+cNomeCli
    @nLin  ,58  psay SA1->A1_EST
    @nLin  ,62  psay TCQ->F2_VEND1+"-"+cNomeVend
    @nLin  ,108 psay substr(TCQ->EMISSAO,7,2)+"/"+substr(TCQ->EMISSAO,5,2)+"/"+substr(TCQ->EMISSAO,1,4)
    dAux = CTOD(substr(TCQ->EMISSAO,7,2)+"/"+substr(TCQ->EMISSAO,5,2)+"/"+substr(TCQ->EMISSAO,1,4))
    @nLin  ,125 psay date() - dAux picture "999,999"
  	
	dbselectarea("TCQ")
	dbskip()  
	IncRegua()		   	

End
nLin++
@nLin,00 psay replicate("_",136)
if (nLin > 59)
	nLin++
 	@nLin,000 psay replicate("_",136)
	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
	nLin := 08
endif
nLin++
@nLin,00 psay "TOTAL DE CLIENTES => "+alltrim(str(nCont))
nLin++
@nLin,00 psay replicate("_",136)
  		
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
Programa  : VALIDPERG   Autor:  Cleber
Data      : 10/05/02
Descricao : Grava Perguntas
/*/



Static Function ValidPerg(cPerg)

Local aHelp := {}

//Texto do help em portugues  ,     ingles, espanhol

AAdd(aHelp, {{"Nao fat ha qtos dias"},  {"Nao fat ha qtos dias"}, {"Nao fat ha qtos dias"}})
AAdd(aHelp, {{"Repres. De  ?"},  {"Repres. De  ?"}, {"Repres. De  ?"}})
AAdd(aHelp, {{"Repres Ate ?"},  {"Repres Ate ?"}, {"Repres Ate ?"}})
AAdd(aHelp, {{"Proc Somente esta Filial?"},  {"Proc Somente esta Filial?"}, {"Proc Somente esta Filial?"}})
AAdd(aHelp, {{"Tirar Clientes Bloqueados"},  {"Tirar Clientes Bloqueados"}, {"Tirar Clientes Bloqueados"}})

u_xPutSX1(cPerg,"01","Ha quantos dias ?" ,"Ha quantos dias ?","Ha quantos dias ?","mv_ch1","N",6,0,0,"G","",""   ,"","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
u_xPutSX1(cPerg,"02","Repres. De  ?" ,"Repres. De  ?","Repres. De  ?",               "mv_ch2","C",6,0,0,"G","","SA3","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")
u_xPutSX1(cPerg,"03","Repres Ate ?" ,"Repres Ate ?","Repres Ate ?","mv_ch3","C",   6,0,0,"G","","SA3","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelp[3,1],aHelp[3,2],aHelp[3,3],"")
u_xPutSX1(cPerg,"04","So esta Filial?" ,"So esta Filial?","So esta Filial?","mv_ch4","N",6,0,1,"C","","","","","MV_PAR04","1-Sim","1-Sim","1-Sim","","2-Não","2-Não","2-Não","","","","","","","","","",aHelp[4,1],aHelp[4,2],aHelp[4,3],"")
u_xPutSX1(cPerg,"05","Filtra Inativos?" ,"Filtra Inativos?","Filtra Inativos?","mv_ch5","N",6,0,1,"C","","","","","MV_PAR05","1-Sim","1-Sim","1-Sim","","2-Não","2-Não","2-Não","","","","","","","","","",aHelp[5,1],aHelp[5,2],aHelp[5,3],"")
Return
