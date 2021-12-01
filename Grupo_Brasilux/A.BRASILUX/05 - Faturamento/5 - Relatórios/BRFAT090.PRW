#include "rwmake.ch"        
#INCLUDE "TOPCONN.CH"   

/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: BRFAT090     Data....: 17/08/10         //
// Autor.....: Cleber Orati Domingues                   //
// Descriçao.: Relat. Vendas por Repr. p/ Analise Lucratividade//
// Uso.......: Todas as Empresas 						//
//                                                     //
/////////////////////////////////////////////////////////  
//                                                     //
// Variaveis utilizadas para parametros                //         
//                                                     //        
// mv_par01     // Repres. de                          //
// mv_par02     // Repres Ate                          //
/////////////////////////////////////////////////////////

User Function BRFAT090()     

Local cCodUsr   := RetCodUsr()
Local cRotina   := "BRFAT090"
 

if !u_VldAcesso(funname())
	Msgbox("Acesso não autorizado!---->"+funname(),"Aleta","Aviso")
    return 
endif 

SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M")
SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3")
SetPrvt("CCABEC,CCABPRO,CNATUREZA,ARETURN,NOMEPROG,CPERG")
SetPrvt("NLASTKEY,LCONTINUA,NLIN,NCOL,WNREL,NTIPO")
SetPrvt("M_PAG,CCABEC1,CCABEC2,CCABEC3,NTAMNF,CSTRING")
SetPrvt("CQUERY,_TOTALG,_TOTFIN,_TOTESTE,_TOTESTS,LIMPEST")
SetPrvt("LIMPFIN,_DTGERAD,_NRAVAR,_TOTAL,_SALIAS,AREGS")
     u_zcfga01( 'BRFAT090' ) //LGS#2021201 - Gravação de log de utilização da rotina

     DbSelectArea("SZW")
     DbSetOrder(4)
     DbSeek(xFilial("SZW")+padr(cRotina,10," ")+cCodUsr+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2),.t.)
     If !Found()
        If PSWADMIN( cUsername, SubStr(cUsuario, 1, 6)) == 0
           DbSelectArea("SZW")
           RecLock("SZW", .t.)
              SZW->ZW_FILIAL  := xFilial("SZW")
              SZW->ZW_USUARIO := RetCodUsr()
              SZW->ZW_ACESSOS := '*****   * '
              SZW->ZW_EMPFIL  := SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2)
              SZW->ZW_DTINCLU := dDataBase
              SZW->ZW_ROTINA  := cRotina
           MsUnLock()
        Else
           MsgBox("Acesso não autorizado !!!", "Atenção", "STOP")
           Return
        Endif
     EndIf



CbTxt    :=""
CbCont   :=0
nOrdem   :=0
Alfa     :=0
Z        :=0
M        :=0
tamanho  :="M"
limite   :=132
titulo   :="Análise de Lucratividade por Representante"
cDesc1   :=PADC("Este programa ira emitir o Rel. Lucrativ por Repr.",74)
cDesc2   :=""
cDesc3   :=PADC(" ",74)
cCabec   :=PADC("Rel. Lucrativ por Repr.",limite," ")
cCabPro  :=""
cNatureza:=""
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog :="BRFAT090"
cPerg    :="BRFT90"
nLastKey := 0
lContinua:=.T.
nLin    := 0
nCol     := 0
wnrel    := "BRFAT090"
nTipo    := 15
m_pag    := 01     
cCabec2  := ""   
cCabec3  := ""
nTamNf   := 132     // Apenas Informativo
cString  := "SC5"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

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
Local nSomaValor,nSomaComis,nSLucroMin,nSomaLucro,cRepr,nQtdeLin,;
nTotalValor,nTotalComis,nTLucroMin,nTotalLucro

nQtdeLin = 70 // Nro máx de linhas por página

if mv_par05 == 1
	//               0       1           2        3           4       5          6  *       7  *       8  *     9           10        11      12        13
	//           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	cCabec1  := "Cliente                                  Pedido         Valor               Comissão            Lucro Mínimo                Lucro"
else
	//               0       1           2        3           4       5          6  *       7  *       8  *     9           10        11      12        13
	//           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	cCabec1  := "                                                        Valor               Comissão            Lucro Mínimo                Lucro"
endif 


//14/06/21 ->Troca de C5_PORCOM por C5_COMIS1
if mv_par05 == 1
	cQuery := "SELECT C5_VEND1 AS REPRES,MAX(ISNULL(A3_NOME,'')) AS NOMEREPR,C5_NUM AS PEDIDO,MAX(C5_EMISSAO) AS EMISSAO,MAX(C5_CLIENTE) AS CLIENTE,"+;
	"MAX(A1_NOME) AS RAZAO,SUM(C6_VALOR*(CASE WHEN C5_ESPECI4 > '' THEN (1/0.7) ELSE 1 END)) AS VALOR,"+;
	"SUM((C5_COMIS1*C6_VALOR*(CASE WHEN C5_ESPECI4 > '' THEN (1/0.7) ELSE 1 END))/100) AS VLRCOMIS,"+;
	"SUM((C5_MEDLUCR*C6_VALOR*(CASE WHEN C5_ESPECI4 > '' THEN (1/0.7) ELSE 1 END))/100) AS VLRLUCROMIN,"+;
	"SUM((C5_LUCRO*C6_VALOR*(CASE WHEN C5_ESPECI4 > '' THEN (1/0.7) ELSE 1 END))/100) AS VLRLUCRO "+;
	"FROM "+RetSqlName("SC6")+" SC6 "+;
	"LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 ON (SC5.D_E_L_E_T_ <> '*') AND (C6_FILIAL = C5_FILIAL) AND (C6_NUM = C5_NUM) "+;
	"LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 ON (SF4.D_E_L_E_T_ <> '*') AND (C6_TES = F4_CODIGO) "+;
	"LEFT OUTER JOIN "+RetSqlName("SA3")+" SA3 ON (SA3.D_E_L_E_T_ <> '*') AND (C5_VEND1 = A3_COD) "+;
	"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 ON (SA1.D_E_L_E_T_ <> '*') AND (C5_CLIENTE = A1_COD) "+;
	"WHERE (SC6.D_E_L_E_T_ <> '*') AND (SC6.C6_FILIAL = '"+xFilial("SC6")+"') AND "+;
	"(C5_LIBDIR = 'T') AND (C5_VEND1 > '') AND (C5_MEDLUCR > 0) AND ((F4_DUPLIC <> 'N') OR (C6_TES = '519')) "+;  
	iif(!empty(mv_par02),"AND (C5_VEND1 BETWEEN '"+mv_par01+"' AND '"+mv_par02+"') ","")+;
	"AND (C5_EMISSAO BETWEEN '"+dtos(mv_par03)+"' AND '"+dtos(mv_par04)+"') "+;
	"GROUP BY C5_VEND1,C5_NUM ORDER BY REPRES,EMISSAO,PEDIDO"
else
	cQuery := "SELECT C5_VEND1 AS REPRES,MAX(ISNULL(A3_NOME,'')) AS NOMEREPR,"+;
	"SUM(C6_VALOR*(CASE WHEN C5_ESPECI4 > '' THEN (1/0.7) ELSE 1 END)) AS VALOR,"+;
	"SUM((C5_COMIS1*C6_VALOR*(CASE WHEN C5_ESPECI4 > '' THEN (1/0.7) ELSE 1 END))/100) AS VLRCOMIS,"+;
	"SUM((C5_MEDLUCR*C6_VALOR*(CASE WHEN C5_ESPECI4 > '' THEN (1/0.7) ELSE 1 END))/100) AS VLRLUCROMIN,"+;
	"SUM((C5_LUCRO*C6_VALOR*(CASE WHEN C5_ESPECI4 > '' THEN (1/0.7) ELSE 1 END))/100) AS VLRLUCRO "+;
	"FROM "+RetSqlName("SC6")+" SC6 "+;
	"LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 ON (SC5.D_E_L_E_T_ <> '*') AND (C6_FILIAL = C5_FILIAL) AND (C6_NUM = C5_NUM) "+;
	"LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 ON (SF4.D_E_L_E_T_ <> '*') AND (C6_TES = F4_CODIGO) "+;
	"LEFT OUTER JOIN "+RetSqlName("SA3")+" SA3 ON (SA3.D_E_L_E_T_ <> '*') AND (C5_VEND1 = A3_COD) "+;
	"WHERE (SC6.D_E_L_E_T_ <> '*') AND (SC6.C6_FILIAL = '"+xFilial("SC6")+"') AND "+;
	"(C5_LIBDIR = 'T') AND (C5_VEND1 > '') AND (C5_MEDLUCR > 0) AND ((F4_DUPLIC <> 'N') OR (C6_TES = '519')) "+;
	iif(!empty(mv_par02),"AND (C5_VEND1 BETWEEN '"+mv_par01+"' AND '"+mv_par02+"') ","")+;
	"AND (C5_EMISSAO BETWEEN '"+dtos(mv_par03)+"' AND '"+dtos(mv_par04)+"') "+;
	"GROUP BY C5_VEND1 ORDER BY REPRES"
endif 	
  TCQuery cQuery NEW ALIAS "TCQ" 


    
  dbSelectArea("TCQ")
  dbgotop()
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  SetRegua(Reccount())
  Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
  nLin = 08      
  	
   	nTotalValor := 0
   	nTotalComis := 0
   	nTLucroMin := 0
   	nTotalLucro := 0

  While ! EoF()         
	If nLastKey == 27
   		exit
	Endif

  	cRepr := TCQ->REPRES
    If (nlin+3) >= nQtdeLin
    	nLin+=1
    	@nLin,000 psay replicate("_",132)
      	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
      	nLin := 08    
    Endif       

  	if mv_par05 == 1
    	nLin++
    	@nLin,000 psay replicate("-",60)      
    	nLin++
    	@nLin,000 psay "Representante: "+TCQ->REPRES+'-'+TCQ->NOMEREPR
    	nLin++
    	@nLin,000 psay replicate("-",60)
   	endif 
   	nSomaValor := 0
   	nSomaComis := 0
   	nSLucroMin := 0
   	nSomaLucro := 0
  	while !eof() .and. (TCQ->REPRES == cRepr)
    	If nlin >= nQtdeLin
    		nLin+=1
    		@nLin,000 psay replicate("_",132)
      		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
      		nLin := 08    
    	Endif       
    	nLin+=1
    	if mv_par05 == 1
	    	@nLin,000 psay SUBSTR(TCQ->CLIENTE+'-'+TCQ->RAZAO,1,40)
	    	@nLin,041 psay TCQ->PEDIDO 
	    ELSE
	    	@nLin,000 psay SUBSTR(TCQ->REPRES+'-'+TCQ->NOMEREPR,1,40)
		ENDIF 

    	@nLin,048 psay TCQ->VALOR PICTURE "99,999,999.99"
    	@nLin,064 psay TCQ->VLRCOMIS PICTURE "9,999,999.99"
    	@nLin,076 psay "("
    	@nLin,077 psay ROUND((TCQ->VLRCOMIS/TCQ->VALOR)*100,2) PICTURE "999.99"
    	@nLin,083 psay ")" 
    	@nLin,086 psay TCQ->VLRLUCROMIN PICTURE "9,999,999.99"
    	@nLin,100 psay "("
    	@nLin,101 psay ROUND((TCQ->VLRLUCROMIN/TCQ->VALOR)*100,2) PICTURE "999.99"
    	@nLin,107 psay ")"
    	@nLin,109 psay TCQ->VLRLUCRO PICTURE "9,999,999.99"
    	@nLin,121 psay "("
    	@nLin,122 psay ROUND((TCQ->VLRLUCRO/TCQ->VALOR)*100,2) PICTURE "999.99"
    	@nLin,128 psay ")"
	   	
	   	nSomaValor += TCQ->VALOR
   		nSomaComis += TCQ->VLRCOMIS
	   	nSLucroMin += TCQ->VLRLUCROMIN
   		nSomaLucro += TCQ->VLRLUCRO
    	
    	   
    	dbselectarea("TCQ")
    	dbskip()
    	IncRegua()
	ENDDO
	if mv_par05 == 1
    	If (nlin+2) >= nQtdeLin
    		nLin+=1
    		@nLin,000 psay replicate("_",132)
      		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
      		nLin := 08    
    	Endif      
    	nLin++
   		@nLin,000 psay replicate("_",132)
   		nLin++ 
   		@nLin,017 psay "TOTAIS P/ O REPR "+cRepr+" => "
    	@nLin,048 psay nSomaValor PICTURE "99,999,999.99"
    	@nLin,064 psay nSomaComis PICTURE "9,999,999.99"
    	@nLin,076 psay "("
    	@nLin,077 psay ROUND((nSomaComis/nSomaValor)*100,2) PICTURE "999.99"
    	@nLin,083 psay ")" 
    	@nLin,086 psay nSLucroMin PICTURE "9,999,999.99"
    	@nLin,100 psay "("
    	@nLin,101 psay ROUND((nSLucroMin/nSomaValor)*100,2) PICTURE "999.99"
    	@nLin,107 psay ")"
    	@nLin,109 psay nSomaLucro PICTURE "9,999,999.99"
    	@nLin,121 psay "("
    	@nLin,122 psay ROUND((nSomaLucro/nSomaValor)*100,2) PICTURE "999.99"
    	@nLin,128 psay ")"
	endif 
	   	nTotalValor += nSomaValor
   		nTotalComis += nSomaComis
	   	nTLucroMin += nSLucroMin
   		nTotalLucro += nSomaLucro

   	dbselectarea("TCQ")
  End
    	If (nlin+2) >= nQtdeLin
    		nLin+=1
    		@nLin,000 psay replicate("_",132)
      		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
      		nLin := 08    
    	Endif      
    	nLin++
   		@nLin,000 psay replicate("_",132)
   		nLin++ 
   		@nLin,017 psay "TOTAL GERAL ==> "
    	@nLin,048 psay 	nTotalValor PICTURE "99,999,999.99"
    	@nLin,064 psay nTotalComis PICTURE "9,999,999.99"
    	@nLin,076 psay "("
    	@nLin,077 psay ROUND((nTotalComis/nTotalValor)*100,2) PICTURE "999.99"
    	@nLin,083 psay ")" 
    	@nLin,086 psay nTLucroMin PICTURE "9,999,999.99"
    	@nLin,100 psay "("
    	@nLin,101 psay ROUND((nTLucroMin/nTotalValor)*100,2) PICTURE "999.99"
    	@nLin,107 psay ")"
    	@nLin,109 psay nTotalLucro PICTURE "9,999,999.99"
    	@nLin,121 psay "("
    	@nLin,122 psay ROUND((nTotalLucro/nTotalValor)*100,2) PICTURE "999.99"
    	@nLin,128 psay ")"


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
Programa  : VALIDPERG   Autor:  Marcos Cesar     
Data      : 28/01/02
Descricao : Grava Perguntas
/*/
/*
Static Function ValidPerg()
Local _sAlias
_sAlias := Alias()
cPerg := PADR(cPerg,10)


       PutSX1(cPerg, "01",  "Repres. De  ?", "Repres. De  ?", "Repres. De  ?", "mv_ch1", "C",  6, 0, 0, "G", " ", "SA3", " ", " ", "mv_par01", ""                , " "        , " "     , " "   , ""                 , " "        , " "        , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , cPerg )
       PutSX1(cPerg, "02",  "Repres Ate  ?", "Repres Ate  ?", "Repres Ate  ?", "mv_ch2", "C",  6, 0, 0, "G", " ", "SA3", " ", " ", "mv_par02", ""                , " "        , " "     , " "   , ""                 , " "        , " "        , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , cPerg )
       PutSX1(cPerg, "03",  "Emissao de  ?", "Emissao de  ?", "Emissao de  ?", "mv_ch3", "D",  8, 0, 0, "G", " ", ""   , " ", " ", "mv_par03", ""                , " "        , " "     , " "   , ""                 , " "        , " "        , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , cPerg )
       PutSX1(cPerg, "04",  "Emissao até ?", "Emissao até ?", "Emissao até ?", "mv_ch4", "D",  8, 0, 0, "G", " ", ""   , " ", " ", "mv_par04", ""                , " "        , " "     , " "   , ""                 , " "        , " "        , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , cPerg )
       PutSX1(cPerg, "05",  "Tipo        ?", "Tipo        ?", "Tipo        ?", "mv_ch5", "N",  1, 0, 1, "C", " ", ""   , " ", " ", "mv_par05", "Analitico"       , "Analitico", "Analitico"     , " "   , "Sintetico", "Sintetico", "Sintetico", ""                , " "     , " "     , ""                , " "     , " "     , ""            ,  " ",  " "     , Nil  , Nil     , Nil     , cPerg )


dbSelectArea(_sAlias)
Return

*/
