#include "rwmake.ch"        
#INCLUDE "TOPCONN.CH"   

/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: BRFAT094     Data....: 18/08/10         //
// Autor.....: Cleber Orati Domingues                   //
// Descriçao.: Relação de Borderôs de despacho         //
// Uso.......: Todas as Empresas 						//
//                                                     //
/////////////////////////////////////////////////////////  
//                                                     //
// Variaveis utilizadas para parametros                //         
//                                                     //        
/////////////////////////////////////////////////////////

User Function BRFAT094()     

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
titulo   :="Relação de Borderôs de Despacho"
cDesc1   :=PADC("Este programa ira emitir Relação de Borderôs de Despacho",74)
cDesc2   :=""
cDesc3   :=PADC(" ",74)
cCabec   :=PADC("Relação de Borderôs de Despacho",limite," ")
cCabPro  :=""
cNatureza:=""
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog :="BRFAT094"
cPerg    :="BRFT94"
nLastKey := 0
lContinua:=.T.
nLin    := 0
nCol     := 0
wnrel    := "BRFAT094"
nTipo    := 15
m_pag    := 01     
//               0       1           2        3           4       5          6  *       7  *       8  *     9           10        11      12        13
//           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
cCabec1  := "Borderô Emissão     Dt Despacho Previs Carregto Descrição                                   Peso     Qtde Vol"
cCabec2  := ""   
cCabec3  := ""
nTamNf   := 132     // Apenas Informativo
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
Local nQtdeLin,cQuery,cAux,nPeso,nVol

nQtdeLin = 70 // Nro máx de linhas por página



cQuery := "SELECT ZA_CODIGO,ZA_EMISSAO,ZA_DTDESPA,ZA_PREVDSP,ZA_DESCR,ZA_PESO,ZA_VOLUME FROM SZA010 "+;
"WHERE (D_E_L_E_T_ <> '*') AND (ZA_FILIAL = '"+xFilial("SZA")+"') AND "+;
"(ZA_CODIGO BETWEEN '"+mv_par01+"' AND '"+mv_par02+"') AND "+;
"(ZA_DTDESPA BETWEEN '"+dtos(mv_par03)+"' AND '"+dtos(mv_par04)+"') ORDER BY ZA_CODIGO"

  TCQuery cQuery NEW ALIAS "TCQ" 


    
  dbSelectArea("TCQ")
  dbgotop()
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  SetRegua(Reccount())
  Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
  nLin = 08      
  	
  	nPeso := 0
  	nVol := 0
  While ! EoF()         
	If nLastKey == 27
   		exit
	Endif
	
    	If nlin >= nQtdeLin
    		nLin+=1
    		@nLin,000 psay replicate("_",132)
      		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
      		nLin := 08    
    	Endif       
    	nLin+=1


    	@nLin,000 psay TCQ->ZA_CODIGO                  
    	cAux = TCQ->ZA_EMISSAO
    	@nLin,008 psay SUBSTR(cAux,7,2)+"/"+SUBSTR(cAux,5,2)+"/"+SUBSTR(cAux,3,2)
    	cAux = TCQ->ZA_DTDESPA
    	@nLin,020 psay SUBSTR(cAux,7,2)+"/"+SUBSTR(cAux,5,2)+"/"+SUBSTR(cAux,3,2)
    	cAux = TCQ->ZA_PREVDSP
    	@nLin,032 psay SUBSTR(cAux,7,2)+"/"+SUBSTR(cAux,5,2)+"/"+SUBSTR(cAux,3,2)
    	@nLin,048 psay TCQ->ZA_DESCR
    	@nLin,084 psay TCQ->ZA_PESO PICTURE "9,999,999.99"
    	@nLin,100 psay TCQ->ZA_VOLUME PICTURE "99,999.99"
	   	                                                 
	   	nPeso += TCQ->ZA_PESO
	   	nVol += TCQ->ZA_VOLUME
    	   
    	dbselectarea("TCQ")
    	dbskip()
    	IncRegua()
  End
	nLin+=1
	@nLin,000 psay replicate("_",132)
	nLin+=1
   	@nLin,083 psay nPeso PICTURE "99,999,999.99"
   	@nLin,97 psay nVol PICTURE "9,999,999.99"
	


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
/*
Static Function ValidPerg()
Local _sAlias
_sAlias := Alias()
cPerg := PADR(cPerg,10)


       PutSX1(cPerg, "01",  "Borderô De  ?", "Repres. De  ?", "Repres. De  ?", "mv_ch1", "C",  6, 0, 0, "G", " ", "SZA", " ", " ", "mv_par01", ""                , " "        , " "     , " "   , ""                 , " "        , " "        , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , cPerg )
       PutSX1(cPerg, "02",  "Borderô Até ?", "Repres Ate  ?", "Repres Ate  ?", "mv_ch2", "C",  6, 0, 0, "G", " ", "SZA", " ", " ", "mv_par02", ""                , " "        , " "     , " "   , ""                 , " "        , " "        , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , cPerg )
       PutSX1(cPerg, "03",  "Dt Desp de  ?", "Dt Desp de  ?", "Dt Desp de  ?", "mv_ch3", "D",  8, 0, 0, "G", " ", ""   , " ", " ", "mv_par03", ""                , " "        , " "     , " "   , ""                 , " "        , " "        , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , cPerg )
       PutSX1(cPerg, "04",  "Dt Desp até ?", "Dt Desp até ?", "Dt Desp até ?", "mv_ch4", "D",  8, 0, 0, "G", " ", ""   , " ", " ", "mv_par04", ""                , " "        , " "     , " "   , ""                 , " "        , " "        , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , cPerg )


dbSelectArea(_sAlias)
Return
*/