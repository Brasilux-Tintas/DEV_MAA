#include "protheus.ch"
#include "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±                        
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ TCPCP002 							  º Data ³  15/10/21  º±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºDescricao Â³ Função para imprimir Ordem de Separação 				  »±±
±±ºAutor: Cleber(15/10/21)												  »±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºUso       Â³ TECPOLPA						.                         »±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß                                                         
/*/                                                                                                        
User Function TCPCP002()
Local cPerg := "TCPCP002"
LOCAL cNroOs := ""
Local cQuery
PRIVATE MV_PAR01,MV_PAR02
SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M")
SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3")
SetPrvt("CCABEC,CCABPRO,CNATUREZA,ARETURN,NOMEPROG,CPERG")
SetPrvt("NLASTKEY,LCONTINUA,NLIN,NCOL,WNREL,NTIPO")
SetPrvt("M_PAG,CCABEC1,CCABEC2,CCABEC3,NTAMNF,CSTRING")
SetPrvt("CQUERY,_TOTALG,_TOTFIN,_TOTESTE,_TOTESTS,LIMPEST")
SetPrvt("LIMPFIN,_DTGERAD,_NRAVAR,_TOTAL,_SALIAS,AREGS")
dbselectarea("SC2")
IF !eof() .and. !bof()
	cNroOs := alltrim(SC2->C2_XORDSEP)
	if !empty(cNroOs)
		MV_PAR01 := alltrim(cNroOs)
		MV_PAR02 := ALLTRIM(cNroOs)
	endif 
ENDIF 
ValidPerg(cPerg)
lResp := Pergunte(cPerg,.T.)
if !lResp 
	RETURN 
endif 
//ISNULL(CB0_QTDE,0.0) AS CB0_QTDE,
 cQuery := "SELECT C2_XOP, C2_PRODUTO, C2_EMISSAO AS EMISSAO,C2_QUANT,C2_UM,C2_XORDSEP, D4_COD, B1_DESC, B1_NAOSEPA,B1_UM, D4_QUANT, D4_LOTECTL, D4_LOCAL AS D4_LOCAL,D4_DTVALID AS D4_DTVALID , "+;
   "D4_XSTATUS = CASE WHEN (D4_XSTATUS = '') AND (B1_NAOSEPA ='2') THEN C2_XSTATUS WHEN (D4_XSTATUS <> '') AND (B1_NAOSEPA <>'2') AND (C2_XSTATUS ='3') THEN C2_XSTATUS ELSE D4_XSTATUS END , "+;
    "C2_XSTATUS, "+;
    "TIPOPRO = CASE WHEN B1_NAOSEPA  = '1'  THEN 'BIPA' WHEN B1_NAOSEPA IN('','2') THEN 'NAO BIPA' ELSE 'VALIDA' END "+;
    "FROM "+RetSqlName("SC2")+" SC2 WITH(NOLOCK) "+;
    "LEFT OUTER JOIN "+RetSqlName("SD4")+" SD4 WITH(NOLOCK) ON (SD4.D_E_L_E_T_ = '') AND (D4_FILIAL = '"+xFilial("SD4")+"') AND (D4_OP = C2_XOP) "+;
    "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON (SB1.D_E_L_E_T_ = '') AND (B1_FILIAL = '"+xFilial("SB1")+"') AND (B1_COD = D4_COD) "+; 
    "WHERE (SC2.D_E_L_E_T_ <> '*') AND (C2_FILIAL = '"+xFilial("SC2")+"') AND "+;
    "(C2_XORDSEP BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' ) AND "+;
    "(B1_TIPO <> 'MO') "+;
    "ORDER BY C2_XORDSEP,C2_XOP,D4_COD"  
//    "LEFT OUTER JOIN "+RetSqlName("CB0")+" CB0 WITH(NOLOCK) ON (CB0.D_E_L_E_T_ = '') AND (CB0_FILIAL ='"+xFilial("CB0")+"') AND (CB0_OP = D4_OP) AND (CB0_CODPRO = D4_COD) AND (CB0_LOTE = D4_LOTECTL) AND (C2_XSTATUS = CB0_XSTATU) "+;
//    "GROUP BY C2_XOP, C2_PRODUTO, C2_XORDSEP, D4_COD, B1_DESC, B1_NAOSEPA, D4_QUANT, D4_LOTECTL, D4_XSTATUS, C2_XSTATUS "+;
    MPSysOpenQuery(  cQuery, 'TCQ' )
    DbSelectArea("TCQ")

dbselectarea("SB1")
dbsetorder(1)

CbTxt    :=""
CbCont   :=0
nOrdem   :=0
Alfa     :=0
Z        :=0
M        :=0
tamanho  :="M"
limite   :=132
titulo   :="ORDENS DE SEPARAÇÃO"
cDesc1   :=PADC("Este programa ira emitir o Rel. de Ordens de Separação",128)
cDesc2   :=""
cDesc3   :=PADC(" ",128)
cCabec   :=PADC("ORDENS DE SEPARAÇÃO",128)
cCabPro  :=""
cNatureza:=""
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog :="TCPCP002"
nLastKey := 0
lContinua:=.T.
nLin    := 9
nCol     := 0
wnrel    := "TCPCP002"
cPerg    := "TCPCP002"
nTipo    := 18
m_pag    := 01     
nTamNf   := 132     // Apenas Informativo
cString  := "SC2"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCabec1  := "                                                 ORDENS DE SEPARACAO"
cCabec2  := ""
cCabec3  := ""																											      


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
Local cOs,cOp
	
//	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
// 	nLin := 08
  	dbSelectArea("TCQ")
  	dbgotop()
  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa  regua de impressao                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  	SetRegua(Reccount())
	//Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
	cOs := ""
	cOp := ""
	//DetCabec()
	While ! EoF()         
	    If (nlin >= 60) .or. !(TCQ->C2_XORDSEP == cOs)
			DetCabec()
   	  		//Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
			if !(TCQ->C2_XORDSEP == cOs)
				if !empty(cOs)
					nLin++
					@nLin,000 psay replicate("-",132)
				endif 
				cOs := TCQ->C2_XORDSEP
			endif 
  	 	Endif   
		if !(TCQ->C2_XOP == cOp)
			if !empty(cOp)
				nLin++
				if nLin >= 58
					DetCabec()
				else 
					@nLin,000 psay replicate("_",132)
					nLin++
					PosCabec()
				endif 
			endif 
			cOp := TCQ->C2_XOP
		endif 

		//"Código          Descrição                                Quantidade UM ALMX LOTE             VALIDADE   "

      	@nLin,00 psay TCQ->D4_COD
    	@nLin,16 psay SUBSTR(TCQ->B1_DESC,1,40)
    	@nLin,57 psay TCQ->D4_QUANT picture "@E 9,999.9999"
    	@nLin,68 psay TCQ->B1_UM 
    	@nLin,71 psay TCQ->D4_LOCAL 
    	@nLin,76 psay TCQ->D4_LOTECTL 
		@nLin,93 psay SUBSTR(TCQ->D4_DTVALID,7,2)+"/"+SUBSTR(TCQ->D4_DTVALID,5,2)+"/"+SUBSTR(TCQ->D4_DTVALID,1,4)
		@nLin,104 psay TCQ->TIPOPRO 
       	nLin++
		dbselectarea("TCQ")
		dbskip()
		IncRegua()
	Enddo
	@nLin,000 psay replicate("-",132)

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



/*/
Programa  : VALIDPERG   Autor: 
Descricao : Grava Perguntas
/*/
Static Function ValidPerg(cPerg)
Local _sAlias := Alias()

/*
*/
u_xPutSx1(cPerg,"01","Da Ord Sep", "Da Ord Serv", "Da Ord Serv", "mv_ch1", "C",  6, 0, 0, "G", " ", "", " ", " ", "MV_PAR01", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
u_xPutSx1(cPerg,"02","Até a Ord Sep", "Até a Ord Sep", "Até a Ord Sep", "mv_ch2", "C",  6, 0, 0, "G", " ", "", " ", " ", "MV_PAR02", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)


dbSelectArea(_sAlias)
Return(.t.)

Static Function DetCabec()
//                  0       1           2        3           4       5         6        7           8      9         10          11       12		  13
//              01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
cCabec1  := ""
cCabec2  := ""
cCabec3  := ""																											      
dbselectarea("TCQ")
IF !EOF() .AND. !BOF()
	cCabec1 := "          ORDEM DE SEPARAÇÃO: "+TCQ->C2_XORDSEP+space(28)+ "LOTE : "+substr(TCQ->C2_XOP,1,6)
	cCabec2 := "Código          Descrição                                Quantidade UM ALMX LOTE             VALIDADE   TIPO SEPARAÇÃO"
	//cCabec2 := "                        O.P.: "+substr(TCQ->C2_XOP,1,6)+"-"+substr(TCQ->C2_XOP,7,2)+"-"+substr(TCQ->C2_XOP,9,3)+space(22)+"Emissão: "+SUBSTR(TCQ->EMISSAO,7,2)+"/"+SUBSTR(TCQ->EMISSAO,5,2)+"/"+SUBSTR(TCQ->EMISSAO,1,4)

ENDIF 
Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
nLin := 9
PosCabec()
return(.t.)


Static Function PosCabec()
//               0       1           2        3           4       5         6        7           8      9         10          11       12		  13
//           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789

	//cCabec2 := "                        O.P.: "+substr(TCQ->C2_XOP,1,6)+"-"+substr(TCQ->C2_XOP,7,2)+"-"+substr(TCQ->C2_XOP,9,3)+space(22)+"Emissão: "+SUBSTR(TCQ->EMISSAO,7,2)+"/"+SUBSTR(TCQ->EMISSAO,5,2)+"/"+SUBSTR(TCQ->EMISSAO,1,4)
dbselectarea("TCQ")
IF !EOF() .AND. !BOF()
	@nLin,00 psay "                        O.P.: "+substr(TCQ->C2_XOP,1,6)+"-"+substr(TCQ->C2_XOP,7,2)+"-"+substr(TCQ->C2_XOP,9,3)
	@nLin,65 psay "Emissão: "+SUBSTR(TCQ->EMISSAO,7,2)+"/"+SUBSTR(TCQ->EMISSAO,5,2)+"/"+SUBSTR(TCQ->EMISSAO,1,4)
	nLin++
	dbselectarea("SB1")
	msseek(xFilial("SB1")+TCQ->C2_PRODUTO)
	if found()
		@nLin,0 psay  "                    Produto : "+ALLTRIM(TCQ->C2_PRODUTO)+"-"+ALLTRIM(SB1->B1_DESC)
		@nLin,101 PSAY "Qtde. : "+transform(TCQ->C2_QUANT,"@E 999,999.9")+" "+TCQ->C2_UM
	endif 
ENDIF 
nLin++
@nLin,00 psay replicate("_",132)
nLin++
/*
@nLin,00 psay "Código          Descrição                                Quantidade UM ALMX LOTE             VALIDADE   TIPO SEPARAÇÃO"
@nLin,00 psay replicate("_",132)
*/
return(.t.)
