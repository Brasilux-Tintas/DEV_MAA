#INCLUDE "rwmake.ch"
#include "TOPCONN.CH" 

User Function BREST028()  
Local oDlg,nOpca
Local cCadastro
Local aSays:={}, aButtons := {}
Local cMens1,cMens2

if !(cnumemp $ "01010101_01010104")
	Alert("Nada a executar!")
	return
endif

AADD(aSays,"Este programa ira atualizar o estoque de acordo com as        ")
AADD(aSays,"movimentacoes de entrada e saida do periodo.")
AADD(aSays,"Este recalculo deve ser realizado periodicamente para que seu  ")
AADD(aSays,"saldo em estoque nao fique comprometido.")
nOpca:= 0
cCadastro:=OemToAnsi("Atualizacao de Estoque")

AADD(aButtons, { 1,.T.,{|o| nOpca:= 1, o:oWnd:End() } } )
AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

FormBatch( cCadastro, aSays, aButtons )

IF nOpcA == 1
	Processa({|lEnd| BREST003()})
Endif

Return  

Static Function BREST003()      
Local _aAutoSD3 := {}
Local _nContLcto := 0,nReg,lRet,nContErro,cMens,nOrdD3,nRegD3,cDocumento,cMay,cEstNeg,;
lAbriu,cAuxX6,cUm,cLocal,cTipo,aTam
dbselectarea("SB1")
dbsetorder(1)
cQuery := "SELECT PRODUTO,TM,QTDE,RECNO AS REG FROM ZZYEST WHERE (FILIAL = '"+SUBSTR(cNumEmp,FWSizeFilial()+1,2)+;
"') AND (PROCESSADO <> 1)"

TCQuery cQuery NEW ALIAS "TCQ"

_nContLcto := 0  
nContErro := 0
cEstNeg = getmv("MV_ESTNEG") // Guarda valor de EstNeg, pois será colocado como "S" e restaurado depois

lAbriu = .f.
//PUTMV("MV_ESTNEG","S")

DbSelectArea("TCQ")   
Dbgotop()   
ProcRegua(TCQ->(RecCount()),21,6)
While !Eof()
	    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta array com os dados dos itens da NF.                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cUm = "" 
		cLocal = "" 
		cTipo = ""
		dbselectarea("SB1")
		dbseek(xFilial("SB1")+TCQ->PRODUTO)
		if found()
			cUM := SB1->B1_UM
			cLocal := SB1->B1_LOCPAD
			cTipo := SB1->B1_TIPO
		endif 
	
		aTam := TamSX3("D3_DOC") // Tamanho do campo E1_NUM

	  	dbSelectArea("SD3")
  		nOrdD3:=IndexOrd()
	  	dbSetOrder(2)                   
	  	cDocumento := space(aTam[1])
  		dbSeek(xFilial("SD3")+cDocumento)
	  	cMay := "SD3"+Alltrim(xFilial("SD3"))+cDocumento
  		While ((D3_FILIAL+D3_DOC)==(xFilial("SD3")+cDocumento)).Or.!MayIUseCode(cMay)
  			cDocumento 	:= NextNumero("SD3",2,"D3_DOC",.T.)
  			cDocumento 	:= A261RetINV(cDocumento)
  			cMay       	:= "SD3"+Alltrim(xFilial("SD3"))+cDocumento
	  		dbSkip()
  		EndDo
		_aAutoSD3	:= {}
		         
		AAdd( _aAutoSD3, { "D3_DOC"		, cDocumento  								, nil } )		// Produto
		AAdd( _aAutoSD3, { "D3_TM"		, TCQ->TM 									, nil } )		// Produto
		AAdd( _aAutoSD3, { "D3_EMISSAO"	, DDATABASE									, nil } )		// Produto						
		AAdd( _aAutoSD3, { "D3_COD"		, TCQ->PRODUTO								, nil } )		// Produto
		AAdd( _aAutoSD3, { "D3_UM" 		, cUm										, nil } )		// Unidade de Medida    : Obrigatorio
		AAdd( _aAutoSD3, { "D3_QUANT"	, TCQ->QTDE									, nil } )		// Quantidade           : Obrigatorio
		AAdd( _aAutoSD3, { "D3_LOCAL"	, cLocal									, nil } )		// Local
		AAdd( _aAutoSD3, { "D3_TIPO"	, cTipo										, nil } )		// Tipo Produto
		AAdd( _aAutoSD3, { "D3_CONTA"	, "" 										, nil } )		// Conta Contábil
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava movimentacao interna sinples utilizando MATA240 (PADRAO)      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		lMsErroAuto := .F.
		Mata240(_aAutoSD3)  
		if !lMsErroAuto 
			cQuery = "UPDATE ZZYEST SET PROCESSADO = 1 WHERE RECNO = "+alltrim(str(TCQ->REG))
			TCSQLEXEC(cQuery)
			_nContLcto++
		else
			nContErro++ 
			MostraErro()
		endif
		
	dbselectarea("TCQ")
	dbskip()        
	IncProc()
enddo
if _nContLcto == 0 .and. (nContErro == 0)   
	Alert("Nenhuma Ocorrência!")
else
	cMens := "Processo Finalizado! Executados "+alltrim(str(_nContLcto))+" lançamentos!"
	if nContErro > 0
		cMens += chr(13)+chr(10)+"Total de Lancamentos que nao puderam ser feitos: "+alltrim(str(nContErro))
	endif
	Alert(cMens)
endif
dbselectarea("TCQ")
dbclosearea("TCQ")
//PUTMV("MV_ESTNEG",cEstNeg)

if lAbriu
	dbselectarea("SX6")
	dbclosearea("SX6")
endif 

return