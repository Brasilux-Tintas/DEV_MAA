#IFNDEF WINDOWS
 #DEFINE PSAY SAY
#ENDIF

#include "rwmake.ch"        
#INCLUDE "TOPCONN.CH"   

/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: BRFIS004     Data....: 11/06/02         //
// Autor.....: Cleber Orati Domingues                   //
// Descriçao.: Relatorio de GNR's s/ Nro de Autenticacao//
// Uso.......: Todas as Empresas 						//
//                                                     //
/////////////////////////////////////////////////////////  
// mv_par01 ->Estado                                   //
/////////////////////////////////////////////////////////

User Function BRFIS004()     

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
titulo   :="GNR'S S/ NRO AUTENTICACAO"
cDesc1   :=PADC("Relatorio de GNR's que nao tem Nro Autentic.",74)
cDesc2   :=""
cDesc3   :=PADC(" ",74)
cCabec   :=PADC("Rel. GNR's s/ Autentic.",27)
cCabPro  :=""
cNatureza:=""
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog :="BRFIS004"
cPerg    :="BRFI04"
nLastKey := 0
lContinua:=.T.
nLin    := 0
nCol     := 0
wnrel    := "BRFIS004"
nTipo    := 18
m_pag    := 01     
//               0       1           2        3           4       5          6  *       7  *       8  *     9           10        11      12        13
//           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
cCabec1  := "UF NRO DOC  EMISSAO  CLIENTE                                  AGENC"
cCabec2  := ""   
cCabec3  := ""
nTamNf   := 80     // Apenas Informativo
cString  := "SZ9"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     
     if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 

ValidPerg()
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

cQuery = "SELECT Z9_NF,Z9_SERIENF,Z9_UF,Z9_DTVENC,F2_CLIENTE,F2_RAZAO,Z9_AGENCIA"+;
" FROM "+RetSqlName("SZ9")+" SZ9 "+;
"LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 ON (Z9_FILIAL = F2_FILIAL) AND (Z9_NF = F2_DOC) AND (Z9_SERIENF = F2_SERIE) "+;
"WHERE (Z9_FILIAL = '"+xFilial("SZ9")+"') AND ((LEN(Z9_NROAUTE) = 0) OR "+;
"(LEN(Z9_BCO) = 0) OR (LEN(Z9_AGENCIA) = 0)) "
if !empty(mv_par01)
	cQuery += " AND (Z9_UF = '"+mv_par01+"')"
endif
cQuery = cQuery+" AND (SZ9.D_E_L_E_T_ <> '*')"+;
" AND (SF2.D_E_L_E_T_ <> '*') ORDER BY Z9_NF,Z9_SERIENF"
 TCQuery cQuery NEW ALIAS "TCQ" 
    
  dbSelectArea("TCQ")
  dbgotop()
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  SetRegua(Reccount())
  Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
  nLin = 08
  While ! EoF()         
    If nlin >= 61
    	nLin+=1
    	@nLin,000 psay replicate("_",80)
      	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
      	nLin := 08    
    Endif       
    	nLin+=1
    	@nLin,00 psay TCQ->Z9_UF
    	@nLin,03 psay ALLTRIM(TCQ->Z9_SERIENF)+ALLTRIM(Z9_NF)
    	@nLin,12 psay substr(Z9_DTVENC,7,2)+"/"+substr(Z9_DTVENC,5,2)+"/"+substr(Z9_DTVENC,3,2)
    	@nLin,21 psay SUBSTR(F2_CLIENTE+"-"+F2_RAZAO,1,40)
    	@nLin,62 psay Z9_AGENCIA
    	dbselectarea("TCQ")
    	dbskip()
    	IncRegua()

  End
   	If nlin >= 61
   		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
   		nLin := 08
   	Endif        
   	 
   	nLin+=1
   	@nLin,000 psay replicate("_",80)

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
Programa  : VALIDPERG   Autor:  Marcos Cesar     
Data      : 28/01/02
Descricao : Grava Perguntas
/*/

Static Function ValidPerg()
Local i, j
Local _sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)
aRegs:={}

// mv_par01     // Data de                             //


// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01","Estado  ?","","","mv_ch1","C",2,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})

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