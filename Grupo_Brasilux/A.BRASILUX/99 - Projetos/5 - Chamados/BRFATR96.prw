#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function BRFATR96()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE CbTxt
PRIVATE Titulo := "ESTATISTICAS DE VENDAS (Cliente X Produto) Valores em R$"
PRIVATE cDesc1:=""
PRIVATE cDesc2:=""
PRIVATE cDesc3 := "" 
                   //   0          1           2         3         4         5         6       7          8        9        10         11        12       13        14         15         16
                   //012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
PRIVATE cCabec1  := "Cliente      Razao Social"
PRIVATE cCabec2  := "Produto      Descricao                           Nota Fiscal      Emissao       UN        Quantidade     Preco Unitario           Total          Vendedor"  
private nTipo := 18
PRIVATE Tamanho:= "M"
PRIVATE Limite := 132
PRIVATE cString:= "SA1"
private m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:= "BRFATR96"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   := "BRFATR96"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
//CriaSX1(cPerg)  //LGS#20200211 - Adequação de release 12.1.25 e posteriores
Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:= "BRFATR96"            //Nome Default do relatorio em Disco

wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)
//wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,,.T.,Tamanho)

If nLastKey==27
	dbClearFilter()
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey==27
	dbClearFilter()
   Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio do Processamento do Relatorio                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RptStatus({|| RptDetail()})

return

/////////////////////////////////////////////////////////
// Funçào....: RPTDETAIL    Data....: 08/06/15         //
// Autor.....: Marcelo J. A. de Paiva                  //
/////////////////////////////////////////////////////////

Static Function RptDetail()
//Local nTotal := 0
//Local _nCont := 0
//Local lNormal
//Local cVend
Local cCliente, cProd
Private _nLin := 7  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery :="SELECT D2_CLIENTE,A1_NOME, D2_COD, B1_DESC,D2_DOC, D2_SERIE, D2_EMISSAO, D2_UM, D2_QUANT, D2_PRCVEN, D2_TOTAL, C5_VEND1 "
cQuery +="FROM "+RetSqlName("SD2")+" SD2 WITH(NOLOCK) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH(NOLOCK) ON C5_NOTA = D2_DOC AND D2_FILIAL = C5_FILIAL AND SC5.D_E_L_E_T_ <> '*' "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH(NOLOCK) ON SA1.D_E_L_E_T_ <> '*' AND A1_FILIAL = '"+xFilial("SA1")+"' AND A1_COD = D2_CLIENTE "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON B1_FILIAL = D2_FILIAL AND SB1.D_E_L_E_T_ <> '*' AND B1_COD = D2_COD "
cQuery +="WHERE D2_FILIAL = '"+xFilial("SD2")+"' AND SD2.D_E_L_E_T_ <> '*' AND (C5_VEND1 BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"') AND "
cQuery +="(D2_CLIENTE BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"') AND (D2_EMISSAO BETWEEN '"+dTos(MV_PAR05)+"' AND '"+dTos(MV_PAR06)+"') AND (D2_COD BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"') "
cQuery +="ORDER BY D2_CLIENTE,D2_COD"

TCQUERY cQuery ALIAS "TCQ" NEW
dbselectarea("TCQ")

SetRegua(RECCOUNT()) 
Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)                       
_nLin := 10 
cProd := TCQ->D2_COD
cCliente := TCQ->D2_CLIENTE   
cTotalGEmb := cTotalGVal := 0
cToEmbCli := cToVendCli := 0
cEmb := cValor := 0          

While !Eof()
	if _nLin > 55                                                                    	
		@ _nLin,000 psay replicate("_",156)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
		_nLin := 10
	endif
 		@ _nLin,000 psay replicate("-",156)
    	 _nLin++
    	@ _nLin,000 psay TCQ->D2_CLIENTE
  		@ _nLin,010 psay TCQ->A1_NOME
    	_nLin++ 
    	_nLin++
	   	While cCliente == TCQ->D2_CLIENTE 
	   		if _nLin > 55                                                                    	
				@ _nLin,000 psay replicate("_",156)
				Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
				_nLin := 10
			endif
    		@ _nLin,000 psay TCQ->D2_COD
  			@ _nLin,015 psay SUBSTR(TCQ->B1_DESC,0,30)
  			@ _nLin,050 psay TCQ->D2_DOC
  			@ _nLin,058 psay "/ "+TCQ->D2_SERIE
  			@ _nLin,065 psay SUBSTR(TCQ->D2_EMISSAO,7,2)+"/"+SUBSTR(TCQ->D2_EMISSAO,5,2)+"/"+SUBSTR(TCQ->D2_EMISSAO,0,4)
  			@ _nLin,080 psay TCQ->D2_UM
  			@ _nLin,090 psay TRANSFORM(TCQ->D2_QUANT,"@E 9999.99")
  			@ _nLin,105 psay TRANSFORM(TCQ->D2_PRCVEN,"@E 99,999.99")
  			@ _nLin,125 psay TRANSFORM(TCQ->D2_TOTAL,"@E 999,999.99")
  			@ _nLin,145 psay TCQ->C5_VEND1  			
  			_nLin++  
  			While cProd == TCQ->D2_COD 
    			if _nLin > 55                                                                    	
					@ _nLin,000 psay replicate("_",156)
					Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
					_nLin := 10
				endif
    			cEmb += TCQ->D2_QUANT  
	  			cToEmbCli  += TCQ->D2_QUANT 
    			cValor += TCQ->D2_TOTAL
	  			cToVendCli += TCQ->D2_TOTAL
	  			dbselectarea("TCQ")
				dbskip()   
				If cProd == TCQ->D2_COD 		
	    			@ _nLin,050 psay TCQ->D2_DOC
		  			@ _nLin,058 psay "/ "+TCQ->D2_SERIE
		  			@ _nLin,065 psay SUBSTR(TCQ->D2_EMISSAO,7,2)+"/"+SUBSTR(TCQ->D2_EMISSAO,5,2)+"/"+SUBSTR(TCQ->D2_EMISSAO,0,4)
		  			@ _nLin,080 psay TCQ->D2_UM
		  			@ _nLin,090 psay TRANSFORM(TCQ->D2_QUANT,"@E 9999.99")
		  			@ _nLin,105 psay TRANSFORM(TCQ->D2_PRCVEN,"@E 99,999.99")
		  			@ _nLin,125 psay TRANSFORM(TCQ->D2_TOTAL,"@E 999,999.99")
		  			@ _nLin,145 psay TCQ->C5_VEND1
		  			_nLin++
		  		EndIf			
			EndDo         
    		_nLin++
    		@ _nLin,008 psay "TOTAL DO PRODUTO - "+cProd+SPACE(10)+"---->"
    		@ _nLin,081 psay TCQ->D2_UM
    		@ _nLin,091 psay TRANSFORM(cEmb,"@E 9999.99")
    		@ _nLin,126 psay TRANSFORM(cValor,"@E 999,999.99")
    		_nLin++
			_nLin++
    		cProd := TCQ->D2_COD
    		cEmb := cValor := 0
    	Enddo
    	_nLin++
    	@ _nLin,008 psay "TOTAL DO CLIENTE - "+cCliente+SPACE(19)+"---->"
    	@ _nLin,091 psay TRANSFORM(cToEmbCli,"@E 9999.99")
    	@ _nLin,126 psay TRANSFORM(cToVendCli,"@E 999,999.99")
    	cTotalGEmb += cToEmbCli
    	cTotalGVal += cToVendCli
    	_nLin++
    	cCliente := TCQ->D2_CLIENTE
    	cToVendCli := cToEmbCli := 0
	EndDo
	if _nLin > 55
		@ _nLin,000 psay replicate("_",80)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
		_nLin := 10  
	endif
	_nLin++
	_nLin++
	@ _nLin,008 psay "T O T A L   G E R A L  "+SPACE(21)+"---->"  
	@ _nLin,091 psay TRANSFORM(cTotalGEmb,"@E 999,999.99")
	@ _nLin,130 psay TRANSFORM(cTotalGVal,"@E 999,999.99") 
	@ _nLin,000 psay replicate("_",156)
	dbSelectArea("TCQ")
    dbCloseArea()
Set Device To Screen
If aReturn[5] == 1             	
   Set Printer TO
   dbcommitAll()
   ourspool(wnrel)
Endif
Return

//LGS#20200211 - Adequação de release 12.1.25 e posteriores
/*Static Function CriaSX1(cPerg)
Local aHelp := {}
//Texto do help em portugues,ingles, espanhol
AAdd(aHelp,{{"de Vendedor" },{""},{""}})
AAdd(aHelp,{{"ate Vendedor"},{""},{""}})
AAdd(aHelp,{{"de Cliente"  },{""},{""}})
AAdd(aHelp,{{"ate Cliente" },{""},{""}})
AAdd(aHelp,{{"de Periodo"  },{""},{""}})
AAdd(aHelp,{{"ate Periodo" },{""},{""}})
AAdd(aHelp,{{"de Produto"  },{""},{""}})
AAdd(aHelp,{{"ate Produto" },{""},{""}})

//(<cGrupo>,<cOrdem>,<Pergunt>,< cPergSpa>,< cPergEng>,< cVar>,< cTipo>,< nTamanho>,[ nDecimal],[ nPreSel],<cGSC>,[cValid],[cF3],[cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil
PutSX1(cPerg,"01","de Vendedor: " ,"","","mv_ch1","C",6,00,00,"G","","SA3","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
PutSX1(cPerg,"02","ate Vendedor: " ,"","","mv_ch2","C",6,00,00,"G","","SA3","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")
PutSX1(cPerg,"03","de Cliente: " ,"","","mv_ch3","C",6,00,00,"G","","SA1","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelp[3,1],aHelp[3,2],aHelp[3,3],"")
PutSX1(cPerg,"04","Ate Cliente: " ,"","","mv_ch4","C",6,00,00,"G","","SA1","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelp[4,1],aHelp[4,2],aHelp[4,3],"")
PutSX1(cPerg,"05","de Periodo: " ,"","","mv_ch5","D",8,00,00,"G","","","","","MV_PAR05","","","","","","","","","","","","","","","","",aHelp[5,1],aHelp[5,2],aHelp[5,3],"")
PutSX1(cPerg,"06","ate Periodo: " ,"","","mv_ch6","D",8,00,00,"G","","","","","MV_PAR06","","","","","","","","","","","","","","","","",aHelp[6,1],aHelp[6,2],aHelp[6,3],"")
PutSX1(cPerg,"07","de Produto: " ,"","","mv_ch7","C",15,00,00,"G","","SB1","","","MV_PAR07","","","","","","","","","","","","","","","","",aHelp[7,1],aHelp[7,2],aHelp[7,3],"")
PutSX1(cPerg,"08","Ate Produto: " ,"","","mv_ch8","C",15,00,00,"G","","SB1","","","MV_PAR08","","","","","","","","","","","","","","","","",aHelp[8,1],aHelp[8,2],aHelp[8,3],"")
Return*/