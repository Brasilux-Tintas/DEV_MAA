#IFNDEF WINDOWS
 #DEFINE PSAY SAY
#ENDIF

#include "rwmake.ch"        
#INCLUDE "TOPCONN.CH"   

/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: BRFIS001     Data....: 26/03/02         //
// Autor.....: Cleber Orati Domingues                   //
// Descriçao.: Resumos p/ GIA//
// Uso.......: Todas as Empresas 						//
//                                                     //
/////////////////////////////////////////////////////////  
//                                                     //
// Variaveis utilizadas para parametros                //         
//                                                     //        
// mv_par01     // Emissao de                          //
// mv_par02     // Emissao Ate                          //
/////////////////////////////////////////////////////////

User Function BRFIS001()     

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
limite   :=80
titulo   :="RELATORIO PARA APURACAO DE GIA-ST"
cDesc1   :=PADC("Relatorio para Apuracao de GIA-ST.",74)
cDesc2   :=""
cDesc3   :=PADC(" ",74)
cCabec   :=PADC("Rel. GIA-ST.",27)
cCabPro  :=""
cNatureza:=""
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog :="BRFIS001"
cPerg    :="BRFI01"
nLastKey := 0
lContinua:=.T.
nLin    := 0
nCol     := 0
wnrel    := "BRFIS001"
nTipo    := 18
m_pag    := 01     
//               0       1           2        3           4       5          6  *       7  *       8  *     9           10        11      12        13
//           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
nTamNf   := 80     // Apenas Informativo
cString  := "SF2"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ValidPerg()
Pergunte(cPerg,.F.)   

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

#IFDEF WINDOWS
  RptStatus({|| RptDetail()})
  Return

Static Function RptDetail()
#ENDIF

Local nCont,cIEST,nPosI,nPosF,nTam
Local cMVSUBTRIB := ""

cMVSUBTRIB := alltrim(GetSubTrib())
nTam = len(cMVSUBTRIB)
if (nTam > 1 ) .and. !isalpha(substr(cMVSUBTRIB,1,1)) //Inscrições estão vindo com barra no inicio
   cMVSUBTRIB := substr(cMVSUBTRIB,2,nTam-1)
endif 

cQuery = "SELECT F2_EST,SUM(F2_VALMERC) AS VALORPROD,SUM(F2_VALIPI) AS IPI,"+;
"SUM(F2_BASEICM) AS BASEICMS,SUM(F2_VALICM) AS VALORICMS,SUM(F2_BRICMS) AS BASESUBST,"+;
"SUM(F2_ICMSRET) AS ST FROM "+RetSqlName("SF2")+" "+;
"WHERE (D_E_L_E_T_ <> '*') AND (F2_FILIAL = '"+xFilial("SF2")+"') AND "+;
"(F2_ICMSRET > 0) AND F2_EMISSAO BETWEEN '"+dtos(mv_par01)+"' AND '"+;
dtos(mv_par02)+"' GROUP BY F2_EST ORDER BY F2_EST"

TCQuery cQuery NEW ALIAS "TCQ" 
    
cCabec1  := ALLTRIM(SM0->M0_NOMECOM)
cCabec2  := "PERIODO DE "+dtoc(mv_par01) +" ATE "+dtoc(mv_par02)
cCabec3  := ""
  dbSelectArea("TCQ")
  dbgotop()
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  SetRegua(Reccount())
  While ! EoF()         
	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
	nLin := 08
	nCont = 0
	while !eof() .and. (nCont < 5)
		nCont++
	   	nLin++
	   	@nLin,000 psay "-----------"          
	   	nLin++

            cIEST := ""
            If At (alltrim(TCQ->F2_EST), cMVSUBTRIB)>0
					nPosI	:=	At (alltrim(TCQ->F2_EST), cMVSUBTRIB)+2
					nPosF	:=	At ("/", SubStr (cMVSUBTRIB, nPosI))-1
					nPosF	:=	IIf(nPosF<=0,len(cMVSUBTRIB),nPosF)
               cIEST := ALLTRIM(SubStr (cMVSUBTRIB, nPosI, nPosF))
            Endif

	   	@nLin,000 psay "ESTADO : "+TCQ->F2_EST+" - ("+Iif(Empty(cIEST), "SEM INSCRIÇÃO", cIEST)+")"
	   	nLin++
	   	@nLin,000 psay "-----------"
	   	nLin++
	   	@nLin,000 psay "Valor dos Produtos : "
	   	@nLin,028 psay TCQ->VALORPROD picture "@E 9,999,999.99"
	   	nLin++
	   	@nLin,000 psay "Valor do IPI : "
	   	@nLin,028 psay TCQ->IPI picture "@E 9,999,999.99"
	   	nLin++
   		@nLin,000 psay "Base de Cálc. ICMS Próprio:"
	   	@nLin,028 psay TCQ->BASEICMS picture "@E 9,999,999.99"
   		nLin++
	   	@nLin,000 psay "ICMS Próprio:"
   		@nLin,028 psay TCQ->VALORICMS picture "@E 9,999,999.99"
	   	nLin++
   		@nLin,000 psay "Base de Cálc. do ICMS - ST:"
	   	@nLin,028 psay TCQ->BASESUBST picture "@E 9,999,999.99"
	   	nLin++
	   	@nLin,000 psay "ICMS Retido por ST"
   		@nLin,028 psay TCQ->ST picture "@E 9,999,999.99"
	   	nLin++
   		@nLin,000 psay replicate("_",80)
	   	dbselectarea("TCQ")
   		dbskip()
	   	IncRegua()
  	enddo
		   	

   	dbselectarea("TCQ")
  End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                      FIM DA IMPRESSAO                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


dbSelectArea("TCQ")
dbCloseArea("TCQ")

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
Programa  : VALIDPERG   Autor:  M
Data      : 26/03/02
Descricao : Grava Perguntas
/*/

Static Function ValidPerg()
Local _sAlias := Alias()
Local i, j
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)
aRegs:={}

// mv_par01     // Data de                             //
// mv_par02     // Data Ate                            //


// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01","Data Emissao De  ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Data Emissao Ate ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
dbSelectArea(_sAlias)
Return
