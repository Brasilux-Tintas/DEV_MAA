#IFNDEF WINDOWS
 #DEFINE PSAY SAY
#ENDIF

#include "rwmake.ch"        
#INCLUDE "TOPCONN.CH"   

/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: BRFAT073     Data....: 11/06/02         //
// Autor.....: Cleber Orati Domingues                  //
// Descriçao.: Relatorio de Faturamento por Peso	   //
// Uso.......: Todas as Empresas 					   //
//                                                     //
/////////////////////////////////////////////////////////  
// mv_par01 ->Cliente de ?                             //
// mv_par02 ->Cliente Até?                             //
// mv_par03 ->Emissao de ?                             //
// mv_par04 ->Emissao Até ?                            //
// mv_par05 ->Vendedor de?                             //
// mv_par06 ->Vendedor Até ?                           //
// mv_par07 ->Produto de?                              //
// mv_par08 ->Produto Até?                             //
// mv_par09 ->Cidade de?                               //
// mv_par10 ->Cidade ATé ?                             //
/////////////////////////////////////////////////////////

User Function BRFAT073()     
Private tamanho,limite,cDesc1,cDesc2,cDesc3,cCabec,cCabec1,cCabec2,cCabec3
Private aReturn,nomeprog,cPerg,nLastKey,nLin,nCol,wnrel,nTipo
Private mv_par01,mv_par02,mv_par03,mv_par04,mv_par05,mv_par06,mv_par07,mv_par08,;
mv_par09,mv_par10,m_pag

m_pag = 01
tamanho  :="M"
titulo   :="FATURAMENTO X PESO"
cDesc1   :=PADC("Relatorio de Faturamento, rel. peso e cidade",74)
cDesc2   :=""
cDesc3   :=PADC(" ",74)
cCabec   :=PADC("Rel. Fat. por Peso.",27)
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog :="BRFAT073"
cPerg    :="BRFT73"
nLastKey := 0
nLin    := 0
nCol     := 0
wnrel    := "BRFAT073"
nTipo    := 15
//               0       1           2        3           4       5          6  *       7  *       8  *     9    9,999,999.99 9,999,999.9912        13
//           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
cCabec1  := "NRO NF     CIDADE                                           CLIENTE                                                   PESO   VLR TOT NF "
cCabec2  := ""   
cCabec3  := ""
nTamNf   := 132     // Apenas Informativo
cString  := "SF2"

    if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

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
Local cQuery,nPesoTotal,nValorTotal,cFilterUser

cFilterUser := U_TRATAFILTRO(aReturn[7]) // Chama Func. p/ tratar filtro p/ SQL Server
cQuery = "SELECT F2_DOC,F2_SERIE,F2_CODCID,F2_EST,Z7_NOME,F2_CLIENTE,F2_RAZAO,"+;
"F2_PBRUTO,F2_VALBRUT FROM "+RetSqlName("SF2")+" SF2 "+;
"LEFT OUTER JOIN "+RetSqlName("SZ7")+" SZ7 ON (F2_CODCID = Z7_COD) WHERE "+;
"(F2_CLIENTE BETWEEN '"+mv_par01+"' AND '"+mv_par02+"') AND "+;
"(F2_EMISSAO BETWEEN '"+dtos(mv_par03)+"' AND '"+dtos(mv_par04)+"') AND "+;
"(F2_VEND1 BETWEEN '"+mv_par05+"' AND '"+mv_par06+"') AND "+;
"(F2_CODCID BETWEEN '"+mv_par07+"' AND '"+mv_par08+"') AND "
if !empty(cFilterUser)
	cQuery = cQuery + "("+cFilterUser+") AND "
endif
cQuery = cQuery+"(SF2.D_E_L_E_T_ <> '*') AND (SZ7.D_E_L_E_T_ <> '*') "+;
"ORDER BY F2_EST,Z7_NOME,F2_CODCID,F2_RAZAO,F2_CLIENTE"

 TCQuery cQuery NEW ALIAS "TCQ" 
    
dbSelectArea("TCQ")
dbgotop()
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  SetRegua(Reccount())
  Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
  nLin = 08
  nPesoTotal := 0
  nValorTotal := 0
  While ! EoF()         
    	If nlin >= 61
    		nLin+=1
    		@nLin,000 psay replicate("_",132)
      		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
      		nLin := 08    
    	Endif       

    	nLin+=1
    	@nLin,000 psay ALLTRIM(TCQ->F2_SERIE)+TCQ->F2_DOC
    	@nLin,011 psay ALLTRIM(TCQ->Z7_NOME)+"-"+TCQ->F2_EST
    	@nLin,060 psay SUBSTR(TCQ->F2_CLIENTE+"-"+TCQ->F2_RAZAO,1,47)
    	@nLin,107 psay TCQ->F2_PBRUTO picture "@E 9,999,999.99"
    	@nLin,120 psay TCQ->F2_VALBRUT picture "@E 9,999,999.99"
    	nPesoTotal += TCQ->F2_PBRUTO
    	nValorTotal += TCQ->F2_VALBRUT
    	dbselectarea("TCQ")
    	dbskip()
    	IncRegua()

  	End
	If (nlin+3) >= 61
   		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
   		nLin := 08
   	Endif        
   	 
   	nLin++
   	@nLin,000 psay replicate("_",132)
   	nLin++
   	@nLin,107 psay nPesoTotal picture "@E 9,999,999.99"
  	@nLin,120 psay nValorTotal picture "@E 9,999,999.99"
   	nLin++
   	@nLin,000 psay replicate("_",132)

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
Local _sAlias := Alias()
Local i, j
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)
aRegs:={}

// mv_par01 ->Cliente de ?                             //
// mv_par02 ->Cliente Até?                             //
// mv_par03 ->Emissao de ?                             //
// mv_par04 ->Emissao Até ?                            //
// mv_par05 ->Vendedor de?                             //
// mv_par06 ->Vendedor Até ?                           //
// mv_par07 ->Produto de?                              //
// mv_par08 ->Produto Até?                             //
// mv_par09 ->Cidade de?                               //
// mv_par10 ->Cidade ATé ?                             //


// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01","Cliente De  ?","","","mv_ch1","C",6,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SA1",""})
AADD(aRegs,{cPerg,"02","Cliente Ate ?","","","mv_ch2","C",6,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SA1",""})
AADD(aRegs,{cPerg,"03","Data Emissao de ?","","","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"04","Data Emissao Ate' ?","","","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"05","Repres. De  ?","","","mv_ch5","C",6,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SA3",""})
AADD(aRegs,{cPerg,"06","Repres Ate ?","","","mv_ch6","C",6,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SA3",""})
AADD(aRegs,{cPerg,"07","Cidade De  ?","","","mv_ch7","C",6,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SZ7",""})
AADD(aRegs,{cPerg,"08","Cidade Ate ?","","","mv_ch8","C",6,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","SZ7",""})

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