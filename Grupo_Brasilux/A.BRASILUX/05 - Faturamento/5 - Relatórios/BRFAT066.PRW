#include "rwmake.ch"        
#INCLUDE "TOPCONN.CH"   

/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: BRFAT066     Data....: 22/03/02         //
// Autor.....: Cleber Orati Domingues                   //
// Descriçao.: Relat. de Clientes Simplificado por Repres//
// Uso.......: Todas as Empresas 						//
//                                                     //
/////////////////////////////////////////////////////////  
//                                                     //
// Variaveis utilizadas para parametros                //         
//                                                     //        
// mv_par01     // Repres. de                          //
// mv_par02     // Repres Ate                          //
// mv_par03     // Filtra Inativos                     //
// mv_par04     // Últ. Compra de                      //
// mv_par05     // Últ. Compra até                     //
/////////////////////////////////////////////////////////

User Function BRFAT066()     
PRIVATE MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06,MV_PAR07,MV_PAR08

SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M")
SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3")
SetPrvt("CCABPRO,CNATUREZA,ARETURN,NOMEPROG,CPERG")
SetPrvt("NLASTKEY,LCONTINUA,NLIN,NCOL,WNREL,NTIPO")
SetPrvt("M_PAG,NTAMNF,CSTRING")
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
titulo   :="RELATORIO SIMPLIFICADO DE CLIENTES POR REPRESENTANTE"
cDesc1   :=PADC("Este programa ira emitir o Rel. de Clientes por Repr.",74)
cDesc2   :=""
cDesc3   :=PADC(" ",74)
cCabPro  :=""
cNatureza:=""
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog :="BRFAT066"
cPerg    :="BRFT66"
nLastKey := 0
lContinua:=.T.
nLin    := 0
nCol     := 0
wnrel    := "BRFAT066"
nTipo    := 15
m_pag    := 01     
nTamNf   := 132     // Apenas Informativo
cString  := "SA1"

    if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 
     u_zcfga01( 'BRFAT066' ) //LGS#2021201 - Gravação de log de utilização da rotina
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

Local nContCli,cAux,cQuery
private cCabec,cCabec1,xCabec2,cCabec3
cCabec   :=PADC("Rel. Clientes Por Repr. Simpl.",27)

//               0       1           2        3           4       5          6  *       7  *       8  *     9           10        11      12        13
//           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
cCabec1  := "Repr.  Tipo Cons.             Cliente                                 Cidade                        Fone             Últ.Compr."
xCabec2  := ""   
cCabec3  := ""



  cQuery = "SELECT SA1.A1_VEND,SA1.A1_CLAS,SA1.A1_COD,SA1.A1_NOME,"+;
  "SA1.A1_EST,SA1.A1_MUN,SA1.A1_DDD,SA1.A1_TEL,SA1.A1_ULTCOM "+;
  "FROM "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) "+;
  "WHERE (D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') "
//Chamado 007514, tirar códigos de repres. especificos do Glaidon 
if __cUserId = "000282"
	cQuery += "AND (A1_VEND NOT IN ('000250','000444','000303','000333','000438','000276')) "
endif 
  IF !empty(mv_par02)
  	cQuery += "AND (A1_VEND BETWEEN '"+mv_par01+"' AND '"+mv_par02+"') " 
  ENDIF 
  if mv_par03 = 1
  	cQuery += "AND (A1_INATIVO = '') "
  endif 
  if !empty(mv_par05)
  	cQuery += "AND (A1_ULTCOM BETWEEN '"+dtos(mv_par04)+"' AND '"+dtos(mv_par05)+"') "
  endif  
  if !empty(mv_par06)
	cAux := U_RegiaoGeo(mv_par06)
	if !empty(cAux)
		cQuery += "AND (A1_EST IN ("+cAux+")) "
	endif 
  endif 

if !empty(MV_PAR07)
	cQuery += "AND ("+U_ParamSql("A1_SATIV2",MV_PAR07)+") "
endif
if !empty(MV_PAR08)
	cQuery += "AND ("+U_ParamSql("A1_EST",MV_PAR08)+") "
endif

  cQuery = cQuery + "ORDER BY A1_VEND,A1_EST,A1_MUN "
  TCQuery cQuery NEW ALIAS "TCQ" 
    
  dbSelectArea("TCQ")
  dbgotop()
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  SetRegua(Reccount())   
  xCabec2 := ""
  Cabec(titulo,cCabec1,xCabec2,nomeprog,tamanho,nTipo)
  nLin = 08
  nContCli := 0
  While ! EoF()         
    If nlin >= 61
    	nLin+=1
    	@nLin,000 psay replicate("_",132)
      	Cabec(titulo,cCabec1,xCabec2,nomeprog,tamanho,nTipo)
      	nLin := 08    
    Endif       
    	nLin+=1
    	@nLin,000 psay TCQ->A1_VEND
    	do case
    		case TCQ->A1_CLAS == "C"
    			cAux := "CONSUMIDOR FINAL"
    		case TCQ->A1_CLAS == "I"
    			cAux := "INDUSTRIALIZACAO"
    		case TCQ->A1_CLAS == "N"
    			cAux := "NAO CONTRIBUINTE"
    		case TCQ->A1_CLAS == "V"
    			cAux := "COMERCIO/REVENDA"
    		case TCQ->A1_CLAS == "D"
    			cAux := "COM. DISTRIB."
    	endcase
    	@nLin,007 psay cAux
    	@nLin,030 psay TCQ->A1_COD+"-"+substr(TCQ->A1_NOME,1,32)
    	@nLin,070 psay ALLTRIM(substr(TCQ->A1_MUN,1,26))+"-"+TCQ->A1_EST
    	@nLin,100 psay TRIM(TCQ->A1_DDD)+'-'+TCQ->A1_TEL
    	@nLin,117 psay substr(TCQ->A1_ULTCOM,7,2)+"/"+substr(TCQ->A1_ULTCOM,5,2)+"/"+substr(TCQ->A1_ULTCOM,3,2)
		nContCli++
    	dbselectarea("TCQ")
    	dbskip()
    	IncRegua()

  End
   	If nlin >= 58
   		Cabec(titulo,cCabec1,xCabec2,nomeprog,tamanho,nTipo)
   		nLin := 08
   	Endif        
   	 
   	nLin+=1
   	@nLin,000 psay replicate("_",132)
   	nLin++
   	@nLin,105 psay "Total de Clientes : "
   	@nLin,125 psay nContCli picture "@E 999,999"

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
/* DESABILITADO RELEASE 12.1.25
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
AADD(aRegs,{cPerg,"01","Repres. De  ?","","","mv_ch1","C",6,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SA3",""})
AADD(aRegs,{cPerg,"02","Repres Ate ?","","","mv_ch2","C",6,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SA3",""})

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
PutSX1(cPerg, "03"  ,  "Filtra Inativos     ?", "Filtra Inativos     ?", "Filtra Inativos     ?", "mv_ch3", "N",  1, 0, 1, "C"  , "","","","", "mv_par03","Sim", "Si", "Yes"   , ""   , "Não", "No", "No", "", "", "" , "", "", "", "", "", "",{},{},{}, "" )
PutSX1(cPerg, "04"  ,  "Últ. Compra de  ?"    , "Últ. Compra de  ?"    , "Últ. Compra de  ?"    , "mv_ch4", "D",  8, 0, 0, "G"  , "","","","", "mv_par04", ""  , ""  , ""      , ""   , ""   , ""  , ""  , "", "", "" , "", "", "", "", "", "",{},{},{}, "" )
PutSX1(cPerg, "05"  ,  "Últ. Compra até ?"    , "Últ. Compra até ?"    , "Últ. Compra até ?"    , "mv_ch5", "D",  8, 0, 0, "G"  , "","","","", "mv_par05", ""  , ""  , ""      , ""   , ""   , ""  , ""  , "", "", "" , "", "", "", "", "", "",{},{},{}, "" )
PutSx1(cPerg, "06"  ,  "Região Geográf?"      , "Região Geográf?"       , "Região Geográf?"      , "mv_ch6", "C",2,0,0,"G","","ZE","","","mv_par06","","","","","","","","","","","","",Nil  , Nil     , Nil,cPerg)
PutSX1(cPerg, "07"  ,"Segmento(s)    ","Segmento(s)    ", "Segmento(s)   ","mv_ch7", "C", 99,00,00, "G",  "", "T3",  "",  "", "mv_par07","","","","","","","","","","","","","","","","",Nil  , Nil     , Nil,cPerg)
PutSX1(cPerg, "08"  ,   "Estado(s)          ", "Estado(s)          ", "Estado(s)          ", "mv_ch8", "C", 99,00,00, "G",  "", "",  "",  "", "mv_Par08","","","","","","","","","","","","","","","","",Nil  , Nil     , Nil ,cPerg)

dbSelectArea(_sAlias)
Return

*/
