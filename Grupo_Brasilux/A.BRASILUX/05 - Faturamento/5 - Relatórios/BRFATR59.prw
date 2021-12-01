#IFNDEF WINDOWS
 #DEFINE PSAY SAY
#ENDIF

#include "rwmake.ch"        
#INCLUDE "TOPCONN.CH"   

User Function BRFATR59()     
Private tamanho,limite,cDesc1,cDesc2,cDesc3,cCabec,cCabec1,cCabec2,cCabec3
Private aReturn,nomeprog,cPerg,nLastKey,nLin,nCol,wnrel,nTipo
Private mv_par01,m_pag,nQtdeLinhas
     u_zcfga01( 'BRFATR59' ) //LGS#2021201 - Gravação de log de utilização da rotina
m_pag = 01 
nQtdeLinhas := 70
tamanho  :="M"
titulo   :=" borderô de despacho por produto"
cDesc1   :=PADC("Relatorio de borderô de despacho por produto com projeção de saldo",74)
cDesc2   :=""
cDesc3   :=PADC(" ",74)
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog :="BRFATR59"
cPerg    :="BRFATR59"
nLastKey := 0
nLin    := 0
nCol     := 0
wnrel    := "BRFATR59"
nTipo    := 15
//               0       1           2        3           4       5          6  *       7  *       8  *     9       10        11        12        13
//           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
cCabec1  := "FEC Pedido Dt. Lib    Cliente                                        Produto                                          Qtd Ven Border"
cCabec2  := ""   
cCabec3  := ""
nTamNf   := 132     // Apenas Informativo
cString  := "SZB"

    if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ValidPerg()
Pergunte(cPerg,.F.)   

wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,,.T.,Tamanho)

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

#IFDEF WINDOWS
  RptStatus({|| RptDetail()})
  Return

Static Function RptDetail()
#ENDIF
Local cQuery,cFilterUser,nQtdFecha,nQtdNaoFecha,nFecha

cFilterUser := U_TRATAFILTRO(aReturn[7]) // Chama Func. p/ tratar filtro p/ SQL Server

cQuery := "Exec PROJECAODESALDOSPEDIDOS '"+xFilial("SC6")+"','"+ALLTRIM(MV_PAR01)+"'"

TCQuery cQuery NEW ALIAS "TCQ" 


nQtdFecha := 0
nQtdNaoFecha := 0
nFecha = -1  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  SetRegua(Reccount())
  Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
  nLin = 07
dbSelectArea("TCQ")
dbgotop()
  While ! EoF()         
	if nFecha <> TCQ->NAOFECHA
   		nFecha := TCQ->NAOFECHA
    	If (nlin+3) >= nQtdeLinhas
    		nLin+=1
    		@nLin,000 psay replicate("_",132)
      		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
      		nLin := 07    
    	Endif      
    	nLin++
   		@nLin,000 psay replicate("=",32)
    	nLin++
   		@nLin,000 psay iif(nFecha = 0,"PEDIDOS CUJO ESTOQUE ATENDE","PEDIDOS COM ESTOQUE INSUFICIENTE")
    	nLin++
   		@nLin,000 psay replicate("=",32)
    	nLin++
 	endif

    	If nlin >= nQtdeLinhas
    		nLin+=1
    		@nLin,000 psay replicate("_",132)
      		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
      		nLin := 07    
    	Endif       
    	nLin+=1


    	@nLin,000 psay IIF(TCQ->NAOFECHA = 0,"SIM","NAO")
    	@nLin,004 psay TCQ->PEDIDO
    	@nLin,011 psay SUBSTR(TCQ->DTLIB,7,2)+'/'+SUBSTR(TCQ->DTLIB,5,2)+'/'+SUBSTR(TCQ->DTLIB,3,2)
    	@nLin,020 psay TCQ->CODCLI+"-"+SUBSTR(TCQ->RAZAO,1,39)
    	@nLin,067 psay TCQ->CODPRO+"-"+SUBSTR(TCQ->DESCRICAO,1,30)
    	@nLin,114 psay transform(TCQ->QTDE,"@E 99999999.99")
    	@nLin,126 psay TCQ->BORDERO
    	dbselectarea("TCQ")
    	dbskip()
    	IncRegua()

  	End
	If (nlin+3) >= nQtdeLinhas
   		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
   		nLin := 07
   	Endif        
   	 
   	nLin++
   	@nLin,000 psay replicate("_",132)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                      FIM DA IMPRESSAO                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


dbSelectArea("TCQ")
dbCloseArea("TCQ")

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


Static Function ValidPerg()
Local _sAlias := Alias()
Local i, j
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01","Bordero?","","","mv_ch1","C",6,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SZA",""})

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
dbSelectArea(_sAlias)
Return
