#include "rwmake.ch"        
#INCLUDE "TOPCONN.CH"   

/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: BRFAT094     Data....: 27/04/11         //
// Autor.....: Cleber Orati Domingues                  //
// Descriçao.: Quadrantes de Borderos de Pedidos       //
// Uso.......: Todas as Empresas 					   //
//                                                     //
/////////////////////////////////////////////////////////  
//                                                     //
// Variaveis utilizadas para parametros                //         
//                                                     //        
/////////////////////////////////////////////////////////

User Function BRFATR17()     

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
titulo   :="Localizações de Pedidos em Borderô"
cDesc1   :=PADC("Este programa ira emitir Relação de Localizações de Pedidos em Borderô",74)
cDesc2   :=""
cDesc3   :=PADC(" ",74)
cCabec   :=PADC("Localizações de Pedidos em Borderô",limite," ")
cCabPro  :=""
cNatureza:=""
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog :="BRFATR17"
cPerg    :="BRFT17"
nLastKey := 0
lContinua:=.T.
nLin    := 0
nCol     := 0
wnrel    := "BRFATR17"
nTipo    := 15
m_pag    := 01     
//               0       1           2        3           4       5          6  *       7  *       8  *     9           10        11      12        13
//           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
cCabec1  := "Borderô Emissão    Pedido  Razão                                   Localização"
cCabec2  := ""   
cCabec3  := ""
nTamNf   := 80     // Apenas Informativo
cString  := "SZA"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     
     if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 

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
Local nQtdeLin,cQuery,cAux,cBord

nQtdeLin = 70 // Nro máx de linhas por página

cQuery := " SELECT ZA_CODIGO AS CODIGO,ZA_EMISSAO AS EMISSAO,A1_NOME AS RAZAO,ZG_LOCALIZ,C5_NUM AS PEDIDO "
cQuery += " FROM "+RetSqlName("SZA")+" SZA WITH (NOLOCK) "
cQuery += " LEFT OUTER JOIN "+RetSqlName("SZB")+" SZB WITH (NOLOCK) ON (SZB.D_E_L_E_T_ <> '*') AND (ZA_FILIAL = ZB_FILIAL) AND (ZA_CODIGO = ZB_CODIGO) "
cQuery += " LEFT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH (NOLOCK) ON (SZG.D_E_L_E_T_ <> '*') AND (ZB_FILIAL = ZG_FILIAL) AND (ZB_PEDIDO = ZG_PEDIDO) "
cQuery += " LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (ZG_PEDIDO = ('"+substr(cnumemp,1,2)+"'+C5_NUM)) "
cQuery += " LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (C5_CLIENTE = A1_COD) "
cQuery += " WHERE (SZA.D_E_L_E_T_ <> '*') AND (ZA_FILIAL = '"+xFilial("SZA")+"') AND (ZG_PEDIDO IS NOT NULL) AND "
cQuery += "(ZA_CODIGO BETWEEN '"+mv_par01+"' AND '"+mv_par02+"') "   

if !empty(mv_par04) .and. (mv_par04 >= mv_par03)
	cQuery += " AND (ZA_EMISSAO BETWEEN '"+dtos(mv_par03)+"' AND '"+dtos(mv_par04)+"') "
endif
cQuery += " ORDER BY CODIGO,ZG_LOCALIZ,PEDIDO"

TCQuery cQuery NEW ALIAS "TCQ" 

dbSelectArea("TCQ")
dbgotop()
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  	SetRegua(Reccount())
  	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
  	nLin = 07      
	cBord := "" //iif(!eof(),TCQ->CODIGO,"")
  	While ! EoF()         
		If nLastKey == 27
   			exit
		Endif

    	If nlin >= nQtdeLin
    		nLin+=1
    		@nLin,000 psay replicate("_",limite)
      		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
      		nLin := 07
    	Endif  
    	nLin+=1   
		cAux := iif((TCQ->CODIGO <> cBord) .OR. empty(cBord),alltrim(TCQ->CODIGO)," _")   	
    	if (TCQ->CODIGO <> cBord) .OR. empty(cBord)
	    	cBord := TCQ->CODIGO                  
	    endif 
    	@nLin,000 psay cAux
    	cAux = TCQ->EMISSAO
    	@nLin,008 psay SUBSTR(cAux,7,2)+"/"+SUBSTR(cAux,5,2)+"/"+SUBSTR(cAux,3,2)
    	@nLin,018 psay TCQ->PEDIDO
    	@nLin,026 psay SUBSTR(TCQ->RAZAO,1,38) 
    	@nLin,068 psay TCQ->ZG_LOCALIZ
    	   
    	dbselectarea("TCQ")
    	dbskip()
    	IncRegua()
  	End
	
	nLin+=1
	@nLin,000 psay replicate("_",limite)


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
//³                   FUNCOES ESPECIFICA                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/* DESABILITADO RELEASE 12.1.25
Static Function ValidPerg()
Local _sAlias
_sAlias := Alias()
cPerg := PADR(cPerg,10)


       PutSX1(cPerg, "01",  "Borderô De  ?", "Borderô De  ?", "Borderô De  ?", "mv_ch1", "C",  6, 0, 0, "G", " ", "SZA", " ", " ", "mv_par01", ""                , " "        , " "     , " "   , ""                 , " "        , " "        , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , cPerg )
       PutSX1(cPerg, "02",  "Borderô Até ?", "Borderô Até ?", "Borderô Até ?", "mv_ch2", "C",  6, 0, 0, "G", " ", "SZA", " ", " ", "mv_par02", ""                , " "        , " "     , " "   , ""                 , " "        , " "        , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , cPerg )
       PutSX1(cPerg, "03",  "Emissao de  ?", "Emissao de  ?", "Emissao de  ?", "mv_ch3", "D",  8, 0, 0, "G", " ", ""   , " ", " ", "mv_par03", ""                , " "        , " "     , " "   , ""                 , " "        , " "        , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , cPerg )
       PutSX1(cPerg, "04",  "Emissao até ?", "Emissao até ?", "Emissao até ?", "mv_ch4", "D",  8, 0, 0, "G", " ", ""   , " ", " ", "mv_par04", ""                , " "        , " "     , " "   , ""                 , " "        , " "        , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , cPerg )


dbSelectArea(_sAlias)
Return
*/