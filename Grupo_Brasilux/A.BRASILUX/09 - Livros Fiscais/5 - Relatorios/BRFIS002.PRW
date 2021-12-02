#IFNDEF WINDOWS
 #DEFINE PSAY SAY
#ENDIF

#include "rwmake.ch"        
#INCLUDE "TOPCONN.CH"   

/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: BRFIS002     Data....: 26/03/02         //
// Autor.....: Cleber Orati Domingues                   //
// Descriçao.: Resumos p/ GIA, por nro de NF//
// Uso.......: Todas as Empresas 						//
//                                                     //
/////////////////////////////////////////////////////////  
//                                                     //
// Variaveis utilizadas para parametros                //         
//                                                     //        
// mv_par01     // Emissao de                          //
// mv_par02     // Emissao Ate                          //
/////////////////////////////////////////////////////////

User Function BRFIS002()     

SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M")
SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3")
SetPrvt("CCABEC,CCABPRO,CNATUREZA,ARETURN,NOMEPROG,CPERG")
SetPrvt("NLASTKEY,LCONTINUA,NLIN,NCOL,WNREL,NTIPO")
SetPrvt("M_PAG,CCABEC1,CCABEC2,CCABEC3,NTAMNF,CSTRING")
SetPrvt("CQUERY,_TOTALG,_TOTFIN,_TOTESTE,_TOTESTS,LIMPEST")
SetPrvt("LIMPFIN,_DTGERAD,_NRAVAR,_TOTAL,_SALIAS,AREGS")
     u_zcfga01( 'BRFIS002' ) //LGS#2021201 - Gravação de log de utilização da rotina
CbTxt    :=""
CbCont   :=0
nOrdem   :=0
Alfa     :=0
Z        :=0
M        :=0
tamanho  :="M"
limite   :=132
titulo   :="REL. P/ APURACAO DE GIA-ST - POR NF"
cDesc1   :=PADC("Relatorio para Apuracao de GIA-ST por NF",74)
cDesc2   :=""
cDesc3   :=PADC(" ",74)
cCabec   :=PADC("Rel. GIA-ST por NF.",27)
cCabPro  :=""
cNatureza:=""
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog :="BRFIS002"
cPerg    :="BRFI02"
nLastKey := 0
lContinua:=.T.
nLin    := 0
nCol     := 0
wnrel    := "BRFIS002"
nTipo    := 18
m_pag    := 01     
//               0       1           2        3           4       5          6  *       7  *       8  *     9           10        11      12        13
//           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
nTamNf   := 132     // Apenas Informativo
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

Local nCont,cEstado
Local nSomaVlrProd := 0
Local nSomaIpi := 0
Local nSomaBaseIcms := 0
Local nSomaVlrIcms := 0
Local nSomaBaseST := 0
Local nSomaST := 0


cQuery = "SELECT F2_DOC,F2_SERIE,F2_EST,F2_VALMERC AS VALORPROD,F2_VALIPI AS IPI,"+;
"F2_BASEICM AS BASEICMS,F2_VALICM AS VALORICMS,F2_BRICMS AS BASESUBST,"+;
"F2_ICMSRET AS ST FROM "+RetSqlName("SF2")+" "+;
"WHERE (D_E_L_E_T_ <> '*') AND (F2_FILIAL = '"+xFilial("SF2")+"') AND "+;
"(F2_ICMSRET > 0) AND F2_EMISSAO BETWEEN '"+dtos(mv_par01)+"' AND '"+;
dtos(mv_par02)+"' ORDER BY F2_EST,F2_DOC"

TCQuery cQuery NEW ALIAS "TCQ" 
    
cCabec1  := substr(ALLTRIM(SM0->M0_NOMECOM),1,30)+", "+"PERIODO DE "+dtoc(mv_par01) +" ATE "+dtoc(mv_par02)
//               0       1           2        3           4       5          6  *       7  *       8  *     9           10        11      12        13
//           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//			 		 9,999,999.99 999,999.99 9,999,999.99 999,999.99 9,999,999.99  999,999.99
cCabec2  := "NRO NF      VALOR PROD.  VALOR IPI    BASE ICMS VALOR ICMS BASE ICMS ST VLR ICMS ST
cCabec3  := ""       


  dbSelectArea("TCQ")
  dbgotop()
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  SetRegua(Reccount())
	nLin = 61
  While ! EoF()  
  	if (nLin+4) > 60
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
		nLin := 08
	endif
   	nLin++
   	@nLin,000 psay "-----------"          
   	nLin++
   	@nLin,000 psay "ESTADO : "+TCQ->F2_EST
   	nLin++
   	@nLin,000 psay "-----------"
   	nLin++
 	nSomaVlrProd = 0
  	nSomaIpi = 0
   	nSomaBaseIcms = 0
   	nSomaVlrIcms = 0
   	nSomaBaseST = 0
   	nSomaST = 0
	cEstado = F2_EST
	while !eof() .and. (F2_EST == cEstado)
		if nLin > 60
			nLin++
	   		@nLin,000 psay replicate("_",132)
			Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
			nLin := 08
		endif

		nLin++
		@nLin,00 psay ALLTRIM(TCQ->F2_DOC)+alltrim(TCQ->F2_SERIE)
	   	@nLin,11 psay TCQ->VALORPROD picture "@E 9,999,999.99"
	   	@nLin,24 psay TCQ->IPI picture "@E 999,999.99"
	   	@nLin,35 psay TCQ->BASEICMS picture "@E 9,999,999.99"
   		@nLin,48 psay TCQ->VALORICMS picture "@E 999,999.99"
	   	@nLin,59 psay TCQ->BASESUBST picture "@E 999,999.99"
   		@nLin,73 psay TCQ->ST picture "@E 999,999.99"      
   		nSomaVlrProd += TCQ->VALORPROD
   		nSomaIpi += TCQ->IPI
   		nSomaBaseIcms += TCQ->BASEICMS
   		nSomaVlrIcms += TCQ->VALORICMS
   		nSomaBaseST += TCQ->BASESUBST
   		nSomaST += TCQ->ST
	   	dbselectarea("TCQ")
   		dbskip()
	   	IncRegua()
  	enddo
  	nLin++
	@nLin,000 psay replicate("_",132)
	if ((nLin+2) > 60)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
		nLin := 08
	endif
		
	   	nLin++ 
	   	@nLin,00 psay "TOT("+cEstado+")"
	   	@nLin,11 psay nSomaVlrProd picture "@E 9,999,999.99"
	   	@nLin,24 psay nSomaIpi picture "@E 999,999.99"
	   	@nLin,35 psay nSomaBaseIcms picture "@E 9,999,999.99"
   		@nLin,48 psay nSomaVlrIcms picture "@E 999,999.99"
	   	@nLin,59 psay nSomaBaseST picture "@E 9,999,999.99"
   		@nLin,73 psay nSomaST picture "@E 999,999.99"
	   	nLin++
   		@nLin,000 psay replicate("_",132)

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
Local i, j
Local _sAlias := Alias()
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
