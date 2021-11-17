#include "rwmake.ch"        
#INCLUDE "TOPCONN.CH"   

/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: BRFAT048     Data....: 28.01.02         //
// Autor.....: Marcos Cesar D.Vieira                   //
// Descriçao.: Relatorio de pedidos p/liberacao credito//
// Uso.......: Brasilux/Resina                         //
// Alterações: Cleber Orati Domingues, 27/02/02  //
//     Query não tratava corretament qdo processada   //
//     em outra empresa, devio a SA3 apontar p/ matriz//
// 28/03/02: Não estava consid. Bloq. Est. Apenas     //
//                                                     //
/////////////////////////////////////////////////////////  
//                                                     //
// Variaveis utilizadas para parametros                //         
//                                                     //        
// mv_par01     // Data De                             //
// mv_par02     // Data Ate                            //
/////////////////////////////////////////////////////////

User Function BRFAT048()     

SetPrvt("CQUERY,_TOTALG,_TOTFIN,_TOTESTE,_TOTESTS,LIMPEST")
SetPrvt("LIMPFIN,_DTGERAD,_NRAVAR,_TOTAL,_SALIAS,AREGS")

Private CbTxt    :=""
Private CbCont   :=0
Private nOrdem   :=0
Private Alfa     :=0
Private Z        :=0
Private M        :=0
Private tamanho  :="M"
Private limite   :=132
Private titulo   :="REL. DE PEDIDOS A LIBERAR/CREDITO"
Private cDesc1   :=PADC("Este programa ira emitir o Rel. de Pedidos a liberar/Credito",74)
Private cDesc2   :=""
Private cDesc3   :=PADC(" ",74)
Private cCabec   :=PADC("Rel. Pedidos a Liberar Credito",27)
Private cCabPro  :=""
Private cNatureza:=""
Private aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
Private nomeprog :="BRFAT048"
Private cPerg    :="BRFT48"
Private nLastKey := 0
Private lContinua:=.T.
Private _nLin    := 90
Private nCol     := 60
Private wnrel    := "BRFAT048"
Private nTipo    := 18
Private m_pag    := 01     
//                   0       1           2        3           4       5         6        7           8
//                   1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678
Private cCabec1  := "CLIENTE                                         PEDIDO DT.EMISSAO   VL.TOT.PED.  REPRESENTANTE"
Private cCabec2  := ""   
Private cCabec3  := ""
Private nTamNf   := 83     // Apenas Informativo
Private cString  := "SC9"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 

ValidPerg()
Pergunte("BRFT48",.F.)   

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

Static Function RptDetail()

	Local cQuery   :=""
	Local cVend    :=""
	Local cPedido  :=""
	Local cCliente :=""
	Local cEmissao :=""
	Local cVendedor:=""
	Local nTotPed  := 0 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


	cQuery := "SELECT A.C9_PEDIDO,A.C9_CLIENTE,A.C9_LOJA,"
	cQuery += "A.C9_QTDLIB, A.C9_PRCVEN,B.C5_VEND1,"
	cQuery += "B.C5_EMISSAO,C.A3_NOME FROM "+RetSqlName("SC9")
	cQuery += " A "
	cQuery += "LEFT OUTER JOIN "+RetSqlName("SC5") +" B ON " 
	cQuery += "((A.C9_FILIAL+A.C9_PEDIDO) = (B.C5_FILIAL+B.C5_NUM)) AND (B.D_E_L_E_T_ <> '*') "
	cQuery += "LEFT OUTER JOIN "+RetSqlName("SA3")+" C ON (B.C5_VEND1 = C.A3_COD) AND (C.D_E_L_E_T_ <> '*')"
	cQuery += " WHERE (A.C9_FILIAL = '"+xFilial("SC9")+"')"
	cQuery += " AND A.C9_DATALIB BETWEEN '"+DTOS(Mv_Par01)+"' AND '"+DTOS(Mv_Par02)+"'" 
	cQuery += " AND ((A.C9_BLCRED = '01') OR ((LEN(A.C9_BLCRED) = 0) AND (A.C9_BLEST = '02')))"
	cQuery += " AND A.D_E_L_E_T_ <> '*'"    
	cQuery += " ORDER BY B.C5_VEND1,A.C9_PEDIDO,A.C9_CLIENTE,A.C9_LOJA "

	TCQuery cQuery NEW ALIAS "TCQ" 
    

	dbSelectArea("TCQ")
	dbgotop()
  
	SetRegua(Reccount())
	While !EoF()         
		cPedido   := TCQ->C9_PEDIDO 
		cCliente  := TCQ->C9_CLIENTE
		cEmissao  := substr(TCQ->C5_EMISSAO,7,2)+"/"+substr(TCQ->C5_EMISSAO,5,2)+"/"+substr(TCQ->C5_EMISSAO,1,4)
		cVendedor := TCQ->C5_VEND1+"-"+TCQ->A3_NOME
    
		nTotPed  := 0 
     
		dbSelectArea("SA1")
		dbSetorder(1)
		dbSeek(xFilial("SA1")+TCQ->C9_CLIENTE+TCQ->C9_LOJA,.F.)                                                          
	
		If _nlin >= 68
			Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
			_nLin := 07    
			cVend := Space(20)
		Endif       
    
		dbSelectArea("TCQ")    
		While ! EoF() .And. TCQ->C9_PEDIDO = cPEDIDO
			nTotPed := nTotPed +(TCQ->C9_QTDLIB * TCQ->C9_PRCVEN)
			dbskip()
		End              
             
		If cVend # cVendedor                    
			_nlin := _nlin + 1                      
			cVend := cVendedor
		Endif  
    
		@ _nlin,000 PSAY cCliente+"-"+SUBSTR(SA1->A1_NOME,1,38)
		@ _nlin,047 PSAY cPedido
		@ _nlin,056 PSAY cEmissao
		@ _nlin,067 PSAY nTotPed   Picture "@E 99,999,999.99"
		@ _nlin,081 PSAY cVendedor
    
		_nlin := _nlin + 1                      
		
		DbSelectArea("TCQ")
		DbSkip()
		
	End
 
  //Roda(cbcont,cbtxt,tamanho)

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

Static Function ValidPerg()
Local _sAlias := Alias()
Local i, j
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01","Data Aprov.Ped. De  ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Data Aprov.Ped. Ate ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})

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