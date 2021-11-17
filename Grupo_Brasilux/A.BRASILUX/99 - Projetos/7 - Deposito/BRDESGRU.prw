#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"  


User Function BRDESGRU()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE CbTxt
PRIVATE Titulo := "RELAÇÃO DE PEDIDOS DESPACHADOS POR GUARULHOS"
PRIVATE cDesc1:=""
PRIVATE cDesc2:=""
PRIVATE cDesc3 := "" 
                   //   0          1           2         3         4         5         6       7          8        9        10         11        12       13        14         15         16
                   //012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
PRIVATE cCabec1  := "N.FISCAL  PEDIDO  CLIENTE                        VOL. P. BRUTO   DT.BAIXA  CONF"
PRIVATE cCabec2  := ""  
private nTipo := 18
PRIVATE Tamanho:= "P"
PRIVATE Limite := 80
PRIVATE cString:= "ZZ0"
private m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:= "BRDESGRU"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   := "BRDESGRU"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   

Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:= "BRDESGRU"            //Nome Default do relatorio em Disco

wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

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


Static Function RptDetail()

Local cQuery  := ""
Private _nLin := 7

teste := Mv_Par01
teste2:= Mv_Par02

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cQuery :=" SELECT ZZ0_PEDIDO AS PEDIDO, ZZ0_NFISCA AS NFISCAL, ZZ0_RAZAO AS RAZAO, ZZ0_VOLUME AS VOLUME, " 
cQuery +=" ZZ0_PBRUTO AS PBRUTO, SUBSTRING(ZZ0_ENTREG,7,2)+'/'+SUBSTRING(ZZ0_ENTREG,5,2)+'/'+SUBSTRING(ZZ0_ENTREG,1,4) AS ENTREGA "  
cQuery +=" FROM "+RetSqlName("ZZ0")+" ZZ0 WITH (NOLOCK) " 
cQuery +=" WHERE ZZ0.D_E_L_E_T_ ='' "
cQuery +=" AND ZZ0_ENTREG BETWEEN '"+DTOS(Mv_Par01)+"' AND '"+DTOS(Mv_Par02)+"'"
cQuery +=" AND ZZ0_FILIAL = '"+xFilial("ZZ0")+"' "
cQuery +=" ORDER BY ZZ0_ENTREG, ZZ0_NFISCA "

TCQUERY cQuery ALIAS "TCQ" NEW
dbselectarea("TCQ")

SetRegua(RECCOUNT())   
Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)                       

_nLin   := 08                                                                                             
cAuxVol := 0

While !Eof()
	if _nLin > 64                                                                    	
		@ _nLin,000 psay replicate("_",80)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
		_nLin := 08
	endif 
	@ _nLin,000 psay TCQ->NFISCAL
  	@ _nLin,008 psay TCQ->PEDIDO
	@ _nLin,017 psay SUBSTR(TCQ->RAZAO,1,30)	  
	@ _nLin,051 psay TCQ->VOLUME	  
	@ _nLin,056 psay ROUND(TCQ->PBRUTO,0)	  
	@ _nLin,064 psay TCQ->ENTREGA	  
	@ _nLin,075 psay "|___|"
	@ _nLin++
	@ _nLin,000 psay replicate("_",80)//+"|___|"
	@ _nLin++
	dbselectarea("TCQ")	 
	dbskip() 
EndDo  
	dbSelectArea("TCQ")
    dbCloseArea()

Set Device To Screen

If aReturn[5] == 1
   Set Printer TO
   dbcommitAll()
   ourspool(wnrel)
Endif

Return
