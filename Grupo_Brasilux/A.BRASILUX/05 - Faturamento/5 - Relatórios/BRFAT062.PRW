#IFNDEF WINDOWS
 #DEFINE PSAY SAY
#ENDIF

#include "rwmake.ch"        
#INCLUDE "TOPCONN.CH"   

/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: BRPCP062     Data....: 05/03/02         //
// Autor.....: Cleber Orati Domingues                   //
// Descriçao.: Relacao de Despachos por Periodo 		//
// Uso.......: Todas as Empresas 						//
//                                                     //
/////////////////////////////////////////////////////////  
//                                                     //
// Variaveis utilizadas para parametros                //         
//                                                     //        
// mv_par01     // Data de                             //
// mv_par02     // Data Ate                            //
// mv_par03     // Notas abaixo de R$                  //
// mv_par04     // Vlr. Frete por Nota(R$)             //
// mv_par05     // % Frete p/ Vlrs Maiores             //
/////////////////////////////////////////////////////////

User Function BRFAT062()     

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
tamanho  :="M"
limite   :=132
titulo   :="DESPACHOS POR PERIODO"
cDesc1   :=PADC("Este programa ira emitir o Rel. de Despachos por Periodo",74)
cDesc2   :=""
cDesc3   :=PADC(" ",74)
cCabec   :=PADC("Rel. Despachos por Periodo",27)
cCabPro  :=""
cNatureza:=""
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog :="BRFAT062"
cPerg    :="BRFT62"
nLastKey := 0
lContinua:=.T.
nLin    := 0
nCol     := 0
wnrel    := "BRFAT062"
nTipo    := 15
m_pag    := 01     
//               0       1           2        3           4       5          6  *       7  *       8  *     9           10        11      12        13
//           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
cCabec1  := "NRO NF   PEDIDO DT. DESP   DESTINATARIO                                 VALOR       PESO     VOL REDESPACHO"
cCabec2  := ""   
cCabec3  := ""
nTamNf   := 80     // Apenas Informativo
cString  := "SZA"

      if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 
     u_zcfga01( 'BRFAT062' ) //LGS#2021201 - Gravação de log de utilização da rotina
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ValidPerg()
Pergunte("BRFT62",.F.)   

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

Local cAux
Local nQtdeNFF // Qtde de notas c/ vlrs menores que mv_par03
Local nQtdeNf // Qtde total de notas fiscais
Local nValorNF // Valor total da Nf
Local nSomaNFF // Soma dos valores das notas fiscais >= mv_par03
Local nSomaNF // Soma dos valores de todas as notas fiscais
Local nSomaVol // Qtde total de volumes

dbselectarea("SF2")
dbsetorder(1)

  cQuery = "SELECT ZA_CODIGO,F2_DOC,ZA_DTDESPA AS DTDESPA,F2_VALFAT,F2_PEDIDO,F2_SERIE,A1_NOME,"+;
  "F2_PBRUTO,F2_VOLUME1,A4_NOME FROM "+RetSqlName("SZB")+" SZB WITH (NOLOCK) "+;
  "LEFT OUTER JOIN "+RetSqlName("SZA")+" SZA WITH (NOLOCK) ON (SZA.D_E_L_E_T_ <> '*') AND (ZA_FILIAL = ZB_FILIAL) AND (ZB_CODIGO = ZA_CODIGO) "+;
  "LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = '"+xFilial("SF2")+"') AND (SUBSTRING(ZB_PEDIDO,3,6) = F2_PEDIDO) "+;
  "LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (F2_CLIENTE = A1_COD) "+;
  "LEFT OUTER JOIN "+RetSqlName("SA4")+" SA4 WITH (NOLOCK) ON (SA4.D_E_L_E_T_ <> '*') AND (F2_REDESP = A4_COD) "+;
  "WHERE (SZB.D_E_L_E_T_ <> '*') AND (SZB.ZB_FILIAL = '"+xFilial("SZB")+"') AND (SF2.R_E_C_N_O_ IS NOT NULL) "+;
  "AND (ZA_DTDESPA BETWEEN '"+dtos(mv_par01)+"' AND '"+dtos(mv_par02)+"') "+;
  "AND (F2_DOC BETWEEN '"+mv_par06+"' AND '"+mv_par07+"') "+;   
  "ORDER BY ZA_DTDESPA,F2_DOC "
  TCQuery cQuery NEW ALIAS "TCQ" 
    
	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
 	nLin := 08
  dbSelectArea("TCQ")
  dbgotop()
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  SetRegua(Reccount())
  nQtdeNF = 0  // Qtde total de Notas Fiscais
  nQtdeNFF = 0 // Qtde de notas c/ vlrs menores que mv_par03  
  nSomaNFF = 0 // Soma dos valores das notas fiscais >= mv_par03
  nSomaNF = 0 // Soma dos valores de todas as notas fiscais  
  nSomaVol = 0 // Qtde total de volumes
  While ! EoF()         
    If nlin >= 61
    	nLin+=1
    	@nLin,000 psay replicate("_",132)
      Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
      nLin := 08    
    Endif       
    	nLin+=1
    	nValorNf := 0         
    	nValorNf := TCQ->F2_VALFAT
    	cPedido := TCQ->F2_PEDIDO
    	@nLin,000 psay ALLTRIM(TCQ->F2_SERIE)+alltrim(TCQ->F2_DOC )
		cAux = TCQ->DTDESPA   	
		@nLin,009 psay cPedido
    	@nLin,016 psay substr(cAux,7,2)+"/"+substr(cAux,5,2)+"/"+substr(cAux,3,2)
    	@nLin,027 psay SUBSTR(TCQ->A1_NOME,1,40) 
   		@nLin,067 psay nValorNf picture "@E 999,999.99"
    	@nLin,78 psay TCQ->F2_PBRUTO picture "@E 999,999.99"
    	@nLin,89 psay TCQ->F2_VOLUME1 picture "@E 999,999"
    	@nLin,97 psay substr(TCQ->A4_NOME,1,40)
    	if nValorNf < mv_par03
			nQtdeNFF ++
		else
			nSomaNFF += nValorNf
		endif
		nQtdeNF++   
		nSomaNF += nValorNf
		nSomaVol += TCQ->F2_VOLUME1

    	dbselectarea("TCQ")
    	dbskip()
    	IncRegua()

  End
   	If nlin >= 56
   		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
   		nLin := 08
   	Endif        
   	 
   	nLin++
   	@nLin,000 psay replicate("_",132)
   	nLin++
   	@nLin,000 psay "Qtde de Notas: "+alltrim(transform(nQtdeNf,"@E 999,999"))
   	@nLin,054  psay "TOTAIS => "
   	@nLin,065 psay nSomaNf picture "@E 9,999,999.99"
   	@nLin,089 psay nSomaVol picture "@E 999,999"
   	nLin++
   	@nLin,000 psay replicate("_",132)
	nLin++
	@nLin,000 psay "Qtde NF's abaixo de $ "+;
	alltrim(transform(mv_par03,"@E 9,999,999.99"))+" : "+;
	alltrim(transform(nQtdeNFF,"@E 9,999,999"))+;
	" x $ "+ alltrim(transform(mv_par04,"@E 9,999,999.99"))+;
	" + Soma NF's >= $ "+alltrim(transform(nSomaNFF,"@E 9,999,999.99"))+;
	" : a "+alltrim(transform(mv_par05,"@E 999.99"))+"% = "+;
	alltrim(transform(mv_par04*nQtdeNFF + ((mv_par05/100)*nSomaNFF),"@E 9,999,999.99"))
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

// mv_par01     // Data de                             //
// mv_par02     // Data Ate                            //
// mv_par03     // Notas abaixo de R$                  //
// mv_par04     // Vlr. Frete por Nota(R$)             //
// mv_par05     // % Frete p/ Vlrs Maiores             //


// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01","Data De  ?","","","mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Data Ate ?","","","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","Notas abaixo de R$","","","mv_ch3","N",9,2,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"04","Vlr. Frete por Nota(R$)","","","mv_ch4","N",9,2,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"05","% Frete p/ Vlrs Maiores","","","mv_ch5","N",6,2,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"06","Nota Fiscal de  ?","","","mv_ch6","C",6,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"07","Nota Fiscal Ate ?","","","mv_ch7","C",6,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
