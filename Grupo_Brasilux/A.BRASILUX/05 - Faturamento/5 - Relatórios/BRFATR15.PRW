#include "rwmake.ch"        
#INCLUDE "TOPCONN.CH"

User Function BRFATR15()     
Private mv_par01,mv_par02

SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M")
SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3")
SetPrvt("CCABEC,CCABPRO,CNATUREZA,ARETURN,NOMEPROG,CPERG")
SetPrvt("NLASTKEY,LCONTINUA,NLIN,NCOL,WNREL,NTIPO")
SetPrvt("M_PAG,CCABEC1,CCABEC2,CCABEC3,NTAMNF,CSTRING")
SetPrvt("CQUERY,_TOTALG,_TOTFIN,_TOTESTE,_TOTESTS,LIMPEST")
SetPrvt("LIMPFIN,_DTGERAD,_NRAVAR,_TOTAL,_SALIAS,AREGS")
     u_zcfga01( 'BRFATR15' ) //LGS#2021201 - Gravação de log de utilização da rotina

/*/
Programa: BRFATR15  Autor:  Cleber Orati Domingues     
Data:     11/09/09
Descricao:Rel Preços Médios de Venda utilizando os últimos 36 meses
/*/



CbTxt    :=""
CbCont   :=0
nOrdem   :=0
Alfa     :=0
Z        :=0
M        :=0
tamanho  :="M"
limite   :=136
titulo   :="PRECOS MEDIOS ULT 36 MESES"
cDesc1   :=PADC("Precos Medios dos Ultimos 36 meses",74)
cDesc2   :=""
cDesc3   :=PADC(" ",74)
cCabec   :=PADC("Precos Medios",27)
cCabPro  :=""
cNatureza:=""
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog :="BRFATR15"
cPerg    :="BRFR15"
nLastKey := 0
lContinua:=.T.
wnrel    := "BRFATR15"
nTipo    := 15
m_pag    := 01
cCabec1  :="CODIGO "
cCabec2  :=""   
cCabec3  :=""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tamanho do Formulario  (em Linhas)                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nTamNf   :=83     // Apenas Informativo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas, busca o padrao                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cString  :="SB1"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     
  if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 

//ValidPerg()
Pergunte("BRFR15",.F.)   

wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,,,Tamanho)

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

Local  cCond
Local cQuery    := ""
Private cArqCab := ""

// @ 0, 001 PSAY chr(27)+"0"			// Compressão de Espaço entre Linhas(1/8)
@ 0, 001 PSAY Chr(15)                  // Compressao de Impressao

dbSelectArea("SZ5")
dbsetorder(1)

cCond = ""
ImprCols := {} // Vetor c/ Nros das Colunas a IMprimir
AADD(ImprCols,08)
AADD(ImprCols,18)
AADD(ImprCols,28)
AADD(ImprCols,38)
AADD(ImprCols,48)
AADD(ImprCols,58)
AADD(ImprCols,68)
AADD(ImprCols,78)
AADD(ImprCols,88)
AADD(ImprCols,98)
AADD(ImprCols,108)
cQuery = "SELECT MAX(SUBSTRING(C6_PRODUTO,4,2)) AS LINHA,SUBSTRING(C6_PRODUTO,1,5) AS GRUPO,SUBSTRING(C6_PRODUTO,11,2) AS EMBA,"+;
"SUM((CASE WHEN B1_ESTOQUE = 'S' THEN B1_PRV1 ELSE B5_PRV2 END)*C6_QTDVEN)/SUM(C6_QTDVEN) AS MEDIA "+;
"FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "+;
"LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C6_FILIAL = C5_FILIAL) AND (C6_NUM = C5_NUM) "+;
"LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (C6_TES = F4_CODIGO) "+;
"LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (C6_FILIAL = B1_FILIAL) AND (C6_PRODUTO = B1_COD) "+;
"LEFT OUTER JOIN "+RetSqlName("SB5")+" SB5 WITH (NOLOCK) ON (SB5.D_E_L_E_T_ <> '*') AND (C6_FILIAL = B5_FILIAL) AND (C6_PRODUTO = B5_COD) "+;
"WHERE (SC6.D_E_L_E_T_ <> '*') AND (LEN(C6_PRODUTO) = 12) AND (C6_NOTA > '') AND (F4_DUPLIC <> 'N') AND "+;
"(C5_EMISSAO >= convert(varchar,GETDATE() -1095,112)) "+;
"AND (LEN(C6_PRODUTO) = 12) AND "+U_ParamSql("SUBSTRING(C6_PRODUTO,4,2)",mv_par01)+;
" GROUP BY SUBSTRING(C6_PRODUTO,1,5),SUBSTRING(C6_PRODUTO,11,2) "
cQuery = cQuery+"ORDER BY LINHA,GRUPO,EMBA "


//TCQuery Abre uma workarea com o resultado da query
TCQUERY cQuery NEW ALIAS "TMP"


  dbSelectArea("TMP")
  dbgotop()
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  SetRegua(Reccount())
  

iNroLin = 9
nNroPag = 0

Cabecalho()
GeraCols()
cabecalho2()
LinhaProd()
cTipo = TMP->LINHA
//DetCab()
  dbselectarea("SB1")
  dbsetorder(1)
  dbselectarea("SZ1")
  dbsetorder(1)
  
  dbSelectArea("TMP")
  dbgotop()
  
  SetRegua(Reccount())

While ! EoF()      
   
                       
	If iNroLin >= 58
		iNroLin = iNroLin+1
		@iNroLin,00 psay replicate("=",136)   
//		eject  
       	Cabecalho()  
       	Cabecalho2()
  	Endif
	ImprReg()
//    iNroLin = iNroLin+1
	dbselectarea("TMP")	            
    if !eof() .AND. (cTipo != TMP->LINHA)
    
		cTipo := TMP->LINHA              
		iNroLin = iNroLin+1
		@iNroLin,00 psay replicate("=",136)
		if iNroLin >= 53
//			eject
			cabecalho()
		endif
		Cabecalho2()   
		LinhaProd()
	endif
                                        
     
    dbSelectArea("TMP")              
    IncRegua()
    //dbskip()
  End
	iNroLin = iNroLin+1
	@iNroLin,00 psay replicate("=",136)
  
//Roda(cbcont,cbtxt,tamanho)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                      FIM DA IMPRESSAO                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


dbSelectArea("TMP")
dbCloseArea()
/*
if file(cArqCab+".dbf")
	cAux = cArqCab+".dbf"
	delete file &cAux
endif
if file(cArqCab+".cdx")
	cAux = cArqCab+".cdx"
	delete file &cAux
endif
*/
If Valtype(oTempTbl01) =='O'
	oTempTbl01:Delete()
Endif

dbSelectArea("SB1")
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

/*/
Programa: VALIDPERG   Autor:  Fernando Roquete     
Data:     05/06/01
Descricao:Grava Perguntas
/*/

/* DESABILITADO RELEASE 12.1.25
Static Function ValidPerg()
LOCAL _sAlias := Alias()
Local aHelp := {}


//            Texto do help em português    , inglês, espanhol
AAdd(aHelp, {{"Informe a Linha de Produto"},  {"Informe a Linha de Produto"}, {"Informe a Linha de Produto"}})

//SX1 (<cGrupo>, <cOrdem>, <cPergunt>, <cPergSpa>, <cPergEng>, <cVar>, <cTipo>, <nTamanho>, [nDecimal], [ nPreSel], < cGSC>, [ cValid], [ cF3], [ cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil
PutSX1(cPerg,"01","Linha(s) Produto"    ,"","","mv_ch1","C",99,00,00,"G","","","","","mv_Par01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")

dbSelectArea(_sAlias)

Return
*/

static function LinhaProd()
local nArea,cAux

nArea = Alias()
cAux := ""
dbselectarea("SZ1")     
dbseek(xFilial("SZ1")+TMP->LINHA)
if found()
	cAux := rtrim(SZ1->Z1_DESCR)
endif 
iNroLin = iNroLin+1
@iNroLin,64-(len(cAux)/2) psay cAux
iNroLin = iNroLin+1
@iNroLin,00 psay replicate("=",136)
dbselectarea(nArea)
return          


static function ImprReg() 
Local cPreco,cAux,nCont,cLinha
	iNroLin = iNroLin+1
  	@iNroLin,00  psay TMP->GRUPO picture "@R XXX99"
//  	@iNroLin  ,14   psay rtrim(SUBSTR(TMP->DESCR,1,30))
// 	@iNroLin,45 psay SUBSTR(TMP->B1_CATALIS,1,10)
//	cAux = rtrim(iif(!EMPTY(TMP->RELCAT),"("+rtrim(TMP->RELCAT)+")",""))
//	cAux = ltrim(cAux)
//  	@iNroLin,55 psay  substr(cAux,1,12)
	cProd = TMP->GRUPO
	cLinha = TMP->LINHA
	dbselectarea("TMP")

	while !eof() .and. (TMP->GRUPO == cProd) 

		dbselectarea("TMPC")
		dbseek(cLinha)
		nCont = 0                  
		while !eof() .AND. (TMPC->LINHA == cLinha) .AND. (nCont < 11)
			nCont = nCont+1   
			cPreco := alltrim(transform(TMP->MEDIA,"@E 99,999.99"))
			if (TMP->EMBA == TMPC->EMBA)
				cAux = space(9-len(cPreco))+cPreco
				@iNroLin,ImprCols[nCont] psay cAux
			endif
			dbselectarea("TMPC")
			dbskip()
		end 
		dbselectarea("TMP")
		dbskip()
	end    
RETURN

Static Function Cabecalho()
				nNroPag = nNroPag+1

				cNroPag = rtrim(str(nNroPag,3))
				cNroPag = replicate("0",3-len(cNroPag))+cNroPag

                iNroLin = 1
				@iNroLin,25 psay replicate("-",80)
				iNroLin = iNroLin+1
				@iNroLin,25 psay "P R E C O S  M E D I O S"
				@iNroLin,85 psay "EXPEDICAO : "+DTOC(DATE())
				iNroLin = iNroLin+1
				@iNroLin,25 psay ALLTRIM(SM0->M0_NOMECOM)
				@iNroLin,85 psay "PAGINA....: "
				@iNroLin,102 psay cNroPag
				iNroLin = iNroLin+1
				@iNroLin,25 psay replicate("-",80)
				iNroLin = iNroLin+1
				@iNroLin,00 psay replicate("=",136)

//iNroLin = 9

RETURN

static function cabecalho2()

				cLinha = TMP->LINHA
				dbSelectArea("TMPC") 
				dbseek(cLinha)
//				locate for TMPC->LINHA == cLinha
				nContEmba = 0
				while !EOF() .AND. (TMPC->LINHA == cLinha) .AND. (nContEmba < 11)
					nContEmba++
					cAux = "cEmba"+alltrim(str(nContEmba,2))
					&cAux = space(9)
				 	dbSelectArea("SZ5")
				   	dbSeek(xFilial("SZ5")+TMPC->EMBA)
					if found()
						&cAux = rtrim(substr(SZ5->Z5_DESCR,1,9))
					endif
					dbselectarea("TMPC")
					dbskip()
				End              
				
				iNroLin = iNroLin+1
				@iNroLin,00 psay "CODIGO"
				if nContEmba >= 1
					@iNroLin,ImprCols[1] psay space(9-len(cEmba1))+cEmba1
				endif
				if nContEmba >= 2
					@iNroLin,ImprCols[2] psay space(9-len(cEmba2))+cEmba2
				endif
				if nContEmba >= 3
					@iNroLin,ImprCols[3] psay space(9-len(cEmba3))+cEmba3
				endif
				if nContEmba >= 4
					@iNroLin,ImprCols[4] psay space(9-len(cEmba4))+cEmba4
				endif
				if nContEmba >= 5
					@iNroLin,ImprCols[5] psay space(9-len(cEmba5))+cEmba5
				endif
				if nContEmba >= 6
					@iNroLin,ImprCols[6] psay space(9-len(cEmba6))+cEmba6
				endif
				if nContEmba >= 7
					@iNroLin,ImprCols[7] psay space(9-len(cEmba7))+cEmba7
				endif
				if nContEmba >= 8
					@iNroLin,ImprCols[8] psay space(9-len(cEmba8))+cEmba8
				endif
				if nContEmba >= 9
					@iNroLin,ImprCols[9] psay space(9-len(cEmba9))+cEmba9
				endif
				if nContEmba >= 10
					@iNroLin,ImprCols[10] psay space(9-len(cEmba10))+cEmba10
				endif
				if nContEmba >= 11
					@iNroLin,ImprCols[11] psay space(9-len(cEmba11))+cEmba11
				endif
				// @prow(),127 say "Ref."
				iNroLin = iNroLin+1
				@iNroLin,00 psay replicate("=",136)



return

Static Function GeraCols()  

Local _aCampos, cQuery
Private oTempTbl01

cQuery := "SELECT DISTINCT SUBSTRING(C6_PRODUTO,4,2) AS LINHA,SUBSTRING(C6_PRODUTO,11,2) AS EMBA "+;
"FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "+;
"LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C6_FILIAL = C5_FILIAL) AND (C6_NUM = C5_NUM) "+;
"LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (C6_TES = F4_CODIGO) "+;
"WHERE (SC6.D_E_L_E_T_ <> '*') AND (LEN(C6_PRODUTO) = 12) AND (C6_NOTA > '') AND (F4_DUPLIC <> 'N') AND "+;
"(C5_EMISSAO >= convert(varchar,GETDATE() -1095,112)) "+;
"ORDER BY LINHA,EMBA

TCQUERY cQuery NEW ALIAS "TMPCC"

	_aCampos = {}    
	AADD(_aCampos,{"LINHA","C",2,0})
	AADD(_aCampos,{"EMBA" ,"C",2,0})
	
	/* DESABILITADO RELEASE 12.1.25
	cArqCab = criatrab(_aCampos,.t.)
	use &cArqCab alias TMPC new
	index on linha tag linha
	DbSetIndex(cArqCab)
	DbSetOrder(1)
	*/
	oTempTbl01 := FWTemporaryTable():New( "TMPLOT" )
    oTempTbl01:SetFields( _aCampos )
    oTempTbl01:AddIndex( "cInd01", { "LINHA"    } )
    oTempTbl01:Create()
	
	DbSetOrder(1)
	
	dbselectarea("TMPCC")
	dbgotop()
	
	do while !eof()
		dbselectarea("TMPC")
		reclock("TMPC",.T.)
			TMPC->LINHA := TMPCC->LINHA
			TMPC->EMBA := TMPCC->EMBA
		msunlock()
		dbselectarea("TMPCC")
		dbskip()
	enddo
                           
	dbselectarea("TMPCC")
	dbclosearea()
	dbselectarea("TMPC")
	dbgotop()
return
