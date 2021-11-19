#INCLUDE "rwmake.ch"
#include "TOPCONN.CH" 


User Function BREST002()  
Local oDlg,nOpca
Local cCadastro
Local aSays:={}, aButtons := {}
Local cMens1,cMens2

if cnumemp != "01010101"
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
lAbriu,cAuxX6,aTam
dbselectarea("ZZY")
dbsetorder(1)  
cQuery := "SELECT ZZY_DOC AS CHAVE,D3_TM,D3_COD,D3_UM,D3_QUANT,D3_CF, D3_LOCAL,D3_DOC,D3_EMISSAO,"+;
" D3_ESTORNO, D3_QTSEGUM, D3_TIPO "+;
"FROM "+RetSqlName("ZZY")+" ZZY WITH (NOLOCK) "+;
"LEFT OUTER JOIN SD3020 SD3 ON (ZZY_DOC = SD3.R_E_C_N_O_) AND (SD3.D_E_L_E_T_ <> '*') "+;
"WHERE (ZZY.D_E_L_E_T_ <> '*') AND (ZZY_FILIAL = '"+xFilial("ZZY")+"')"

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
	
	  	dbSelectArea("SD3")
  		nOrdD3:=IndexOrd()
	  	dbSetOrder(2)  
  		aTam := TamSX3("D3_DOC") // Tamanho do campo D3_DOC
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
		AAdd( _aAutoSD3, { "D3_TM"		, iif(TCQ->D3_TM < "500","502","102")		, nil } )		// Produto
		AAdd( _aAutoSD3, { "D3_EMISSAO"	, DDATABASE									, nil } )		// Produto						
		AAdd( _aAutoSD3, { "D3_COD"		, TCQ->D3_COD								, nil } )		// Produto
		AAdd( _aAutoSD3, { "D3_UM" 		, TCQ->D3_UM								, nil } )		// Unidade de Medida    : Obrigatorio
		AAdd( _aAutoSD3, { "D3_QUANT"	, TCQ->D3_QUANT								, nil } )		// Quantidade           : Obrigatorio
		AAdd( _aAutoSD3, { "D3_LOCAL"	, TCQ->D3_LOCAL								, nil } )		// Local
		AAdd( _aAutoSD3, { "D3_TIPO"	, TCQ->D3_TIPO								, nil } )		// Tipo Produto
		AAdd( _aAutoSD3, { "D3_CONTA"	, "" 										, nil } )		// Conta Contábil
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava movimentacao interna sinples utilizando MATA240 (PADRAO)      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		lMsErroAuto := .F.
		Mata240(_aAutoSD3)  
		if !lMsErroAuto 
			cQuery = "DELETE FROM "+RetSqlName("ZZY")+" WHERE ZZY_DOC = "+alltrim(str(TCQ->CHAVE))
			TCSQLEXEC(cQuery)
			_nContLcto++
		else
			nContErro++
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

PutMv("MV_ESTNEG",cEstNeg)
if lAbriu
	dbselectarea("SX6")
	dbclosearea("SX6")
endif 

return