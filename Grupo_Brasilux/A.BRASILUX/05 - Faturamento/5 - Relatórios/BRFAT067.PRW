#include "rwmake.ch"
#include "topconn.ch"

/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: BRFAT067     Data....: 28/03/02         //
// Autor.....: Cleber Orati Domingues                   //
// Descriçao.: Pedidos Liberados, prontos p/ FAturar
// Uso.......: Todas as Empresas 						//
//                                                     //
/////////////////////////////////////////////////////////  
//                                                     //
// Variaveis utilizadas para parametros                //         
//                                                     //        
// mv_par01     // Dt. Lib. de                          //
// mv_par02     // Dt. Lib Ate                          //
/////////////////////////////////////////////////////////

User Function BRFAT067()     

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
titulo   :="PEDIDOS LIBERADOS, PRONTOS P/ FATURAR"
cDesc1   :=PADC("Este programa ira emitir o Rel. de Pedidos Prontos p/ Faturar.",74)
cDesc2   :=""
cDesc3   :=PADC(" ",74)
cCabec   :=PADC("Ped. Liberados",27)
cCabPro  :=""
cNatureza:=""
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog :="BRFAT067"
cPerg    :="BRFT67"
nLastKey := 0
lContinua:=.T.
nLin    := 0
nCol     := 0
wnrel    := "BRFAT067"
nTipo    := 15
m_pag    := 01     
nTamNf   := 80     // Apenas Informativo
cString  := "SC9"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

 if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif  
     u_zcfga01( 'BRFAT067' ) //LGS#2021201 - Gravação de log de utilização da rotina
//ValidPerg()
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


	RptStatus({|| RptDetail()})

Return

Static Function RptDetail()


    Local nCont, nSomaVlrProd, cRef, cGrupo, nSomaGrupo, cQuery, cOrdem
	do case
	case mv_par03 == 1
		cOrdem := " A1_EST,A1_MUN,A1_NOME " 
		cGrupo := "MAX(A1_EST)+MAX(A1_MUN)"
	case mv_par03 == 2
		cOrdem := " C9_PEDIDO "
		cGrupo := "C9_PEDIDO"
	case mv_par03 == 3
		cOrdem := " REPRES,C9_PEDIDO "
		cGrupo := "MAX(C5_VEND1)"
	otherwise
		mv_par03 = 1
		cOrdem := " A1_EST,A1_MUN,A1_NOME " 
		cGrupo := "MAX(A1_EST)+MAX(A1_MUN)"
	endcase 		


   	cQuery := ""
    cQuery += "SELECT GRUPO = "+cGrupo+",SC9.C9_PEDIDO, MAX(SC9.C9_CLIENTE) AS C9_CLIENTE, MAX(SA1.A1_NOME) AS A1_NOME, "+;
    "MAX(SA1.A1_MUN) AS A1_MUN, MAX(SA1.A1_EST) AS A1_EST, MAX(SC9.C9_DTLCRED) AS C9_DTLCRED, "+;
    "MAX(SC5.C5_EMISSAO) AS C5_EMISSAO, MAX(C5_VEND1) AS REPRES, SUM(SC9.C9_QTDLIB * SC9.C9_PRCVEN) AS VALOR "
    cQuery += "FROM "+RetSqlName("SC9")+" SC9 WITH (NOLOCK) "
    cQuery += "LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON SA1.A1_COD = SC9.C9_CLIENTE AND SA1.D_E_L_E_T_ = '' "
    cQuery += "LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON SC5.C5_FILIAL = SC9.C9_FILIAL AND SC5.C5_NUM = SC9.C9_PEDIDO AND SC5.D_E_L_E_T_ = '' "
    cQuery += "WHERE (SC9.C9_FILIAL = '"+xFilial("SC9")+"') "
    cQuery += "  AND (SC9.C9_DTLCRED BETWEEN '"+DTOS(mv_par01)+"' AND '"+DTOS(mv_par02)+"') "
    if !empty(mv_par05)
    	cQuery += "AND (C5_VEND1 BETWEEN '"+mv_par04+"' AND '"+mv_par05+"') "
    endif 
    cQuery += "  AND (LEN(SC9.C9_BLCRED) = 0) "
    cQuery += "  AND (LEN(SC9.C9_BLEST) = 0) "
    cQuery += "  AND (C9_NFISCAL = '') "
    cQuery += "  AND (SC9.D_E_L_E_T_ <> '*') "
    cQuery += "  AND (SC5.C5_TIPO = 'N') "
    cQuery += "  AND (SC5.C5_APROVA = '1') "
    cQuery += "  AND (SC5.C5_NOTA = '') "
    cQuery += "GROUP BY SC9.C9_PEDIDO "
    cQuery += "ORDER BY "+cOrdem
    
    /*
	cQuery = "SELECT MAX('"+cEmpresa+"') AS EMPRESA,C9_PEDIDO,MAX(C9_CLIENTE) AS C9_CLIENTE,MAX(A1_NOME) AS A1_NOME,"+;
	"MAX(A1_MUN) AS A1_MUN,MAX(A1_EST) AS A1_EST,"+;
	"MAX(C9_DTLCRED) AS C9_DTLCRED,MAX(C5_EMISSAO) AS C5_EMISSAO,SUM(C9_QTDLIB*C9_PRCVEN) AS VALOR"+;
	" FROM SC9"+cEmpresa+"0 SC9 LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1"+;
	" ON (SC9.C9_CLIENTE = SA1.A1_COD) AND (SA1.D_E_L_E_T_ <> '*') "+;
	"LEFT OUTER JOIN SC5"+cEmpresa+"0 SC5 "+;
	" ON ((SC9.C9_FILIAL+SC9.C9_PEDIDO) = (SC5.C5_FILIAL+SC5.C5_NUM)) AND (SC5.D_E_L_E_T_ <> '*') "+;
	"WHERE (SC9.C9_FILIAL = '"+xFilial("SC9")+"')"+;
	" AND SC9.C9_DTLCRED BETWEEN '"+DTOS(Mv_Par01)+"' AND '"+DTOS(Mv_Par02)+"'"+;
  	" AND (LEN(SC9.C9_BLCRED) = 0) AND (LEN(SC9.C9_BLEST) = 0) AND (LEN(C9_NFISCAL) = 0)"+;
	" AND (SC9.D_E_L_E_T_ <> '*') GROUP BY C9_PEDIDO"
	*/    

	TCQuery cQuery NEW ALIAS "TCQ" 
    
//               0       1           2        3           4       5          6  *       7  *       8  *     9           10        11      12        13
//           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
cCabec2  := "Pedido Cliente                                                 Cidade                                  EMISSAO    DT LIB CRED REPRES"
cCabec1  := "PERIODO DE LIBERACAO DE "+dtoc(mv_par01) +" ATE "+dtoc(mv_par02)
cCabec3  := ""
Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  SetRegua(Reccount())

  dbSelectArea("TCQ")
  dbgotop()
  
	nCont = 0
	nSomaVlrProd = 0
	nLin = 08
  While ! EoF() 
  	nSomaGrupo := 0        
  	cRef := TCQ->GRUPO
  	do while !eof() .and. (TCQ->GRUPO == cRef)
	  	if nLin > 60
  			nLin++
	  		@nLin,000 psay replicate("_",132)
			Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
			nLin := 08
		endif
		nCont++
	   	nLin++
	   	@nLin,000 psay TCQ->C9_PEDIDO
	   	@nLin,007 psay SUBSTR(TCQ->C9_CLIENTE+"-"+A1_NOME,1,55)
	   	@nLin,063 psay ALLTRIM(TCQ->A1_MUN)+"-"+TCQ->A1_EST
	   	@nLin,103 psay substr(TCQ->C5_EMISSAO,7,2)+"/"+substr(TCQ->C5_EMISSAO,5,2)+"/"+substr(TCQ->C5_EMISSAO,1,4)
   		@nLin,114 psay substr(TCQ->C9_DTLCRED,7,2)+"/"+substr(TCQ->C9_DTLCRED,5,2)+"/"+substr(TCQ->C9_DTLCRED,1,4)
	   	@nLin,126 psay TCQ->REPRES
	   	dbselectarea("TCQ")
	   	nSomaVlrProd += TCQ->VALOR
	   	nSomaGrupo += TCQ->VALOR
   		dbskip()
	   	IncRegua()
	enddo
  	if nLin > 60
		nLin++
 		@nLin,000 psay replicate("_",132)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
		nLin := 08  
	else
	  	nLin++
		@nLin,000 psay replicate("_",132)
	endif
 	nLin++
	@nLin,000 psay "           TOTAL PARCIAL : "+alltrim(transform(nSomaGrupo,"9,999,999.99"))
  	if nLin > 60
		nLin++
 		@nLin,000 psay replicate("_",132)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
		nLin := 08  
	else
	  	nLin++
		@nLin,000 psay replicate("_",132)
	endif
	 	   	

  End

  		nLin++
  		@nLin,000 psay replicate("_",132)
  		nLin++
  		@nLin,000 psay "VALOR TOTAL DOS PRODUTOS : "+alltrim(transform(nSomaVlrProd,"99,999,999.99"))
  		
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
Programa  : VALIDPERG   Autor:  M
Data      : 28/03/02
Descricao : Grava Perguntas
/*/
/* DESABILITADO RELEASE 12.1.25
Static Function ValidPerg()     
local aArea := GetArea()
Local i,aRegs, j
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)
aRegs:={}

// mv_par01     // Data de                             //
// mv_par02     // Data Ate                            //


// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01","Data Lib De  ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Data Lib Ate ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
PutSX1(cPerg, "03"  ,  "Ordem de     ?", "Ordem de     ?", "Ordem de     ?", "mv_ch3", "N",  1, 0, 1, "C"  , "","","","","mv_par03","ESTADO/CIDADE", "ESTADO/CIDADE", "ESTADO/CIDADE"   , ""   , "PEDIDO", "PEDIDO", "PEDIDO", "REPRES+PEDIDO", "REPRES+PEDIDO", "REPRES+PEDIDO" , "", "", "",  "", "", "",{},{},{}, "" )
PutSX1(cPerg, "04","do Repres"    ,"do Repres"   ,"do Repres"   ,"mv_ch4","C",6,00,00,"G","","SA3","","","mv_par04","","","","","","","","","","","","","","","","",{},{},{}, "")
PutSX1(cPerg, "05","ate o Repres" ,"ate o Repres","ate o Repres","mv_ch5","C",6,00,00,"G","","SA3","","","mv_par05","","","","","","","","","","","","","","","","",{},{},{}, "")


RestArea(aArea)

Return
*/
