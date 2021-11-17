#IFNDEF WINDOWS
 #DEFINE PSAY SAY
#ENDIF

#include "rwmake.ch"        
#INCLUDE "TOPCONN.CH"   

/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: BRFAT084     Data....: 30.07.03         //
// Autor.....: Cleber Orati Domingues                  //
// Descriçao.: Relatorio de pedidos que não respeitam  //
// a política de preços para revenda                   //
// Uso.......: Brasilux/Resina                         //
//                                                     //
/////////////////////////////////////////////////////////  
//                                                     //
// Variaveis utilizadas para parametros                //         
//                                                     //        
// mv_par01     // Data Aprov de                       //
// mv_par02     // Data Aprov até                      //
/////////////////////////////////////////////////////////

User Function BRFAT084()     
Private CbTxt,CbCont,nOrdem,Alfa,Z,M,tamanho,limite,titulo,cDesc1,cDesc2,cDesc3,;
cCabec,cCabPro,aReturn,nomeprog,cPerg,nLastKey,lContinua,_nLin,nCol,wnrel,nTipo,;
m_pag

CbTxt    :=""
CbCont   :=0
nOrdem   :=0
Alfa     :=0
Z        :=0
M        :=0
tamanho  :="M"
limite   :=132
titulo   :="REL. DE PEDIDOS NAO CONFORMES C/ POL VENDA"
cDesc1   :=PADC("Programa para emitir Rel. de Pedidos Nao Conformes c/ Pol. Venda Rev",74)
cDesc2   :=""
cDesc3   :=PADC(" ",74)
cCabec   :=PADC("Ped. Nao Conformes Polit Reven",27)
cCabPro  :=""
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog :="BRFAT084"
cPerg    :="BRFT84"
nLastKey := 0
lContinua:=.T.
_nLin    := 90
nCol     := 60
wnrel    := "BRFAT084"
nTipo    := 18
m_pag = 1
//               0       1           2        3           4       5         6        7           8        9         10       11         12
//           12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
cCabec1  := "CLIENTE                                         PEDIDO DT.EMISSAO   VL.TOT.PED.  REPRESENTANTE                             Lucro(%)
cCabec2  := ""   
cCabec3  := ""
nTamNf   := 80     // Apenas Informativo
cString  := "SC5"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 

ValidPerg()
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

#IFDEF WINDOWS
  RptStatus({|| RptDetail()})
  Return

Static Function RptDetail()
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

  cQuery := "SELECT A.C6_NUM AS C9_PEDIDO,MAX(A.C6_CLI) AS C9_CLIENTE,MAX(C6_NOTA) AS NRONF,"
  cQuery := cQuery + "SUM(C6_QTDVEN*C6_PRCVEN) AS VALOR,MAX(C5_VEND1) AS C5_VEND1,"
  cQuery := cQuery + "MAX(C5_EMISSAO) AS C5_EMISSAO,MAX(C5_LUCRO) AS C5_LUCRO,"+;
  "MAX(A3_NOME) AS A3_NOME FROM "+RetSqlName("SC6")
  cQuery := cQuery + " A "
  cQuery += "LEFT OUTER JOIN "+RetSqlName("SC5") +" B ON " 
  cQuery += "((A.C6_FILIAL+A.C6_NUM) = (B.C5_FILIAL+B.C5_NUM)) AND (B.D_E_L_E_T_ <> '*') "
  cQuery += "LEFT OUTER JOIN "+RetSqlName("SA3")+" C ON (B.C5_VEND1 = C.A3_COD) AND (C.D_E_L_E_T_ <> '*')"
  cQuery := cQuery + " WHERE (A.C6_FILIAL = '"+xFilial("SC6")+"')"
  cQuery := cQuery + " AND C5_EMISSAO BETWEEN '"+DTOS(Mv_Par01)+"' AND '"+DTOS(Mv_Par02)+"'" 
  cQuery := cQuery + " AND (C5_NAOCONF = 'S') "
  cQuery := cQuery + " AND A.D_E_L_E_T_ <> '*'"+;
  " GROUP BY C6_NUM"
  cQuery := cQuery + " ORDER BY C5_VEND1,C6_NUM,C9_CLIENTE "

  TCQuery cQuery NEW ALIAS "TCQ" 
    
  cVend := Space(20)

   dbSelectArea("SA1")
   dbSetorder(1)
  dbSelectArea("TCQ")
  dbgotop()
  
  SetRegua(Reccount())
  While ! EoF()         
    cPedido   := TCQ->C9_PEDIDO
    cCliente  := TCQ->C9_CLIENTE
    cEmissao  := substr(TCQ->C5_EMISSAO,7,2)+"/"+substr(TCQ->C5_EMISSAO,5,2)+"/"+substr(TCQ->C5_EMISSAO,1,4)
    cVendedor := TCQ->C5_VEND1+"-"+TCQ->A3_NOME
    
    dbSelectArea("SA1")
    dbSeek(xFilial("SA1")+TCQ->C9_CLIENTE,.F.)                                                          
	
    If _nlin >= 68
      Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
      _nLin := 07    
      cVend := Space(20)
    Endif       
    
    If cVend # cVendedor                    
      _nlin := _nlin + 1                      
      cVend := cVendedor
    Endif  
    
    @ _nlin,000 PSAY cCliente+"-"+SUBSTR(SA1->A1_NOME,1,38)
    @ _nlin,047 PSAY cPedido+iif(EMPTY(TCQ->NRONF),"*","")
    @ _nlin,056 PSAY cEmissao
    @ _nlin,067 PSAY TCQ->VALOR   Picture "@E 99,999,999.99"
    @ _nlin,081 PSAY substr(cVendedor,1,40)
    @ _nLin,123 psay tcq->c5_lucro picture "@E 9999.99"
    
    _nlin := _nlin + 1                      
	dbselectarea("TCQ")
	dbskip()
  End
 
  Roda(cbcont,cbtxt,tamanho)

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

/*/
Programa  : VALIDPERG   Autor:   
Data      : 07/2003
Descricao : Grava Perguntas
/*/

Static Function ValidPerg()    
Local _sAlias,aRegs
Local _sAlias := Alias()
Local i, j
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01","Emissao Pedido de  ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Emissao Pedido ate' ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})

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