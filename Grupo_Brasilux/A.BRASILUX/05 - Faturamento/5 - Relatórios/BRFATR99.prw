#include "rwmake.ch"        
#INCLUDE "TOPCONN.CH"   

/////////////////////////////////////////////////////////
//                                                     //
// FunГЮo....: BRFATR99     Data....: 01/06/2021       //
// Autor.....: Cleber Orati Domingues                  //
// DescriГao.: Novas Vendas no perМodo                 //
// Uso.......: Grupo 01-BRASILUX        		       //
//                                                     //
/////////////////////////////////////////////////////////  
//                                                     //
// Variaveis utilizadas para parametros                //         
//                                                     //        
// mv_par01     // Per de                             //
// mv_par02     // Per Ate                             //
// mv_par03     // Repres de                           //
// mv_par04     // Repres Ate                          //
/////////////////////////////////////////////////////////

User Function BRFATR99()     

PRIVATE MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04
SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M")
SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3")
SetPrvt("CCABEC,CCABPRO,CNATUREZA,ARETURN,NOMEPROG,CPERG")
SetPrvt("NLASTKEY,LCONTINUA,NLIN,NCOL,WNREL,NTIPO")
SetPrvt("M_PAG,CCABEC1,CCABEC2,CCABEC3,NTAMNF,CSTRING")
SetPrvt("LIMPFIN,AREGS")
     u_zcfga01( 'BRFATR99' ) //LGS#2021201 - GravaГЦo de log de utilizaГЦo da rotina
CbTxt    :=""
CbCont   :=0
nOrdem   :=0
Alfa     :=0
Z        :=0
M        :=0
tamanho  :="G"
limite   :=220
titulo   :="NOVAS VENDAS"
cDesc1   :=PADC("Este programa ira emitir o Rel. de Novas Vendas",74)
cDesc2   :=""
cDesc3   :=PADC(" ",74)
cCabec   :=PADC("Rel. Novas Vendas",27)
cCabPro  :=""
cNatureza:=""
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog :="BRFATR99"
cPerg    :="BRFATR99"
nLastKey := 0
lContinua:=.T.
nLin    := 0
nCol     := 0
wnrel    := "BRFATR99"
nTipo    := 18
m_pag    := 01     
nTamNf   := 220     // Apenas Informativo
cString  := "SC5"

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Envia controle para a funcao SETPRINT                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
/*
if !u_VldAcesso(funname())
	MsgBox("Acesso nЦo autorizado!---->"+funname(),"AtenГЦo","Alert")
	return 
endif 
*/

ValidPerg()
Pergunte(cPerg,.F.)   

//               0       1           2        3           4       5         6        7           8      9         10          11       12		  13		  14		  15    16         17
//           0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
cCabec1  := "" //																																				9,999,999,999.99
cCabec2  := "CLIENTE                                         UF CIDADE                              REPRESENTANTE                             PEDIDO EMISSAO        VALOR PEDIDO ATIVIDADE"
cCabec3  := ""																											      

wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,,.T.,Tamanho)

cCabec1  := "PERIODO DE "+dtoc(mv_par01)+" ATE "+dtoc(mv_par02)

If nLastKey == 27
   Return
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica Posicao do Formulario na Impressora                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicio do Processamento do Relatorio                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

  RptStatus({|| RptDetail()})

Return

Static Function RptDetail()
Local cQuery,nCont,nVlrTotal

dbselectarea("SC5")
cQuery := "WITH TMP AS (SELECT DISTINCT C5_CLIENTE AS CODCLI "+;
"FROM "+RetSqlName("SC5")+" WITH (NOLOCK) "+;
"WHERE (D_E_L_E_T_ <> '*') AND (C5_FILIAL = '"+xFilial("SC5")+"') AND (C5_TIPO = 'N') "+;
"AND (C5_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"') "+;
"AND (C5_LIBCRE = 'T') AND (C5_APROVA IN ('0','1'))),TMP1 AS ( "+;
"SELECT CODCLI,C5_NUM AS PEDIDO,C5_EMISSAO AS EMISSAO "+;
"FROM TMP "+;
"LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = '"+xFilial("SC5")+"') AND (C5_TIPO = 'N') AND (C5_CLIENTE = CODCLI)), "+;
"TMP3 AS ( "+;
"SELECT CODCLI FROM TMP1 GROUP BY CODCLI HAVING MIN(EMISSAO) BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"') "+;
"SELECT CODCLI,A1_NOME AS RAZAO,A1_EST AS UF,A1_MUN,A1_VEND AS CODREPR,A3_NOME,"+;
"C5_NUM AS PEDIDO,SUBSTRING(C5_EMISSAO,7,2)+'/'+SUBSTRING(C5_EMISSAO,5,2)+'/'+SUBSTRING(C5_EMISSAO,1,4) AS EMISSAO,"+;
"C5_VLRDUP AS VALORPED,A1_SATIV2+'-'+X5_DESCRI AS ATIVIDADE "+;
"FROM TMP3 "+;
"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (A1_COD = CODCLI) "+;
"LEFT OUTER JOIN "+RetSqlName("SA3")+" SA3 WITH (NOLOCK) ON (SA3.D_E_L_E_T_ <> '*') AND (A3_FILIAL = '"+xFilial("SA3")+"') AND (A3_COD = A1_VEND) "+;
"LEFT OUTER JOIN "+RetSqlName("SX5")+" SX5 WITH (NOLOCK) ON (SX5.D_E_L_E_T_ <> '*') AND (X5_TABELA = 'T3') AND (X5_CHAVE = A1_SATIV2) "+;
"LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = '"+xFilial("SC5")+"') AND (C5_TIPO = 'N') AND (C5_LIBCRE = 'T') AND (C5_APROVA IN ('0','1')) AND (C5_CLIENTE = CODCLI) "+;
"WHERE (SC5.C5_VLRDUP > 0.0) "+;
"AND (SC5.C5_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"') "
if !EMPTY(MV_PAR04) .AND. (MV_PAR04 >= MV_PAR03)
	cQuery += "AND (A1_VEND BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"') "
endif 
cQuery += "ORDER BY CODREPR,CODCLI,PEDIDO "
TCQuery cQuery NEW ALIAS "TCQ"   	
	
//	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
// 	nLin := 08
  	dbSelectArea("TCQ")
  	dbgotop()
  
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicializa  regua de impressao                            Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nCont := 0
	nVlrTotal := 0
  	SetRegua(Reccount())
	nLin := 9 
	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
	While ! EoF()     
		nCont++  
		nVlrTotal += TCQ->VALORPED
	    If nlin >= 60
   	  		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
	   	  	nLin := 09
  	 	Endif   

      	@nLin,00 psay SUBSTR(TCQ->CODCLI+'-'+TCQ->RAZAO,1,46)
    	@nLin,48 psay TCQ->UF 
    	@nLin,51 psay SUBSTR(TCQ->A1_MUN,1,35)
    	@nLin,87 psay SUBSTR(TCQ->CODREPR+'-'+TCQ->A3_NOME,1,40) 
		@nLin,129 psay TCQ->PEDIDO
		@nLin,136 psay TCQ->EMISSAO
		@nLin,147 psay TCQ->VALORPED PICTURE "@E 9,999,999,999.99"
		@nLin,164 psay TCQ->ATIVIDADE
       	nLin++
		dbselectarea("TCQ")
		dbskip()
		IncRegua()

	Enddo
	If nlin >= 59
   		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
  		nLin := 09
 	endif
   	nLin+=1
	@nLin,000 psay replicate("-",220)
 	nLin+=1
	@nLin,00 psay "TOTAL DE PEDIDOS ====>>>>>> "+alltrim(transform(nCont,"@E 999,999,999"))
	@nLin,147 psay nVlrTotal PICTURE "@E 9,999,999,999.99"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё                      FIM DA IMPRESSAO                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

dbSelectArea("TCQ")
dbCloseArea()

Set Device To Screen
If aReturn[5] == 1
   Set Printer TO
   dbcommitAll()
   ourspool(wnrel)
Endif

Return

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё                   FUNCOES ESPECIFICAS                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

/*/
Programa  : VALIDPERG   Autor: 
Descricao : Grava Perguntas
/*/
Static Function ValidPerg()
Local _sAlias := Alias()

u_xPutSX1(cPerg,"01","Data Emissao De  ?" ,"Data Emissao De  ?" ,"Data Emissao De  ?" ,"mv_ch1","D",08,0,0,"G","" ,""   ,"" ,"" ,"MV_PAR01","","" ,"" ,"" ,"","" ,"" ,"","" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,Nil,Nil,Nil,cPerg)
u_xPutSX1(cPerg,"02","Data Emissao Ate ?" ,"Data Emissao Ate ?" ,"Data Emissao Ate ?" ,"mv_ch2","D",08,0,0,"G","" ,""   ,"" ,"" ,"MV_PAR02","","" ,"" ,"" ,"","" ,"" ,"","" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,Nil,Nil,Nil,cPerg)
u_xPutSx1(cPerg,"03","Repres De  ?"       , "Repres De  ?"      , "Repres De  ?"      ,"mv_ch3","C",06,0,0,"G"," ","SA3"," "," ","MV_PAR03",""," "," "," ",""," "," ",""," "," "," "," "," "," "," "," ",Nil,Nil,Nil,cPerg)
u_xPutSx1(cPerg,"04","Repres Ate ?"       , "Repres Ate ?"      , "Repres Ate ?"      ,"mv_ch4","C",06,0,0,"G"," ","SA3"," "," ","MV_PAR04",""," "," "," ",""," "," ",""," "," "," "," "," "," "," "," ",Nil,Nil,Nil,cPerg)

dbSelectArea(_sAlias)
Return
