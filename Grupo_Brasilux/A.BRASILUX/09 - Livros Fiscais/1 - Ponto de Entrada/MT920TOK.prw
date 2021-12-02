#INCLUDE "rwmake.ch"

////////////////////////////////////////////////////
// Programa...: MTA920E-PE antes da excl da NF Manual //
// Autor......: Cleber Orati                      //
// Data.......: 16/10/19                          //
// Descricao..: Excluir Lctos Manuais do Financeiro//
// Uso........: Leiria Hotel                      // 
////////////////////////////////////////////////////

User Function MT920TOK 
Local cArea	:= Alias()         
Local nRegE1,aVetor,lRet,cNroNf,cSerie
Private lMsErroAuto
lRet := .t.
     u_zcfga01( 'MT920TOK' ) //LGS#2021201 - Gravação de log de utilização da rotina

IF (cNumEmp = "01100101")
	cNroNf := alltrim(SF2->F2_DOC)
	cSerie := alltrim(SF2->F2_SERIE)
	dbselectarea("SE1")
	dbsetorder(2) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO   
	dbseek(xFilial("SE1")+SF2->F2_CLIENTE+SF2->F2_LOJA+PADR(SF2->F2_SERIE,TamSx3("E1_PREFIXO")[1]," ")+PADR(cNroNf,TamSx3("E1_NUM")[1]," ")+space(TamSx3("E1_PARCELA")[1])+"NF")
	IF FOUND() // Excluir Conta a Receber
	    if SE1->E1_SALDO <> SE1->E1_VALOR
	    	lRet := .f.
	    	MsgAlert("Título da NF "+cNroNf+"/"+cSerie+" JÁ SOFREU BAIXA!")
	    else 
		    aVetor := {}
		    aAdd(aVetor, {"E1_FILIAL",  SE1->E1_FILIAL,  Nil})
			aAdd(aVetor, {"E1_NUM",     SE1->E1_NUM,              Nil})
			aAdd(aVetor, {"E1_PREFIXO", SE1->E1_PREFIXO,          Nil})
			aAdd(aVetor, {"E1_PARCELA", SE1->E1_PARCELA,          Nil})
			aAdd(aVetor, {"E1_TIPO",    SE1->E1_TIPO,             Nil})
			aAdd(aVetor, {"E1_NATUREZ", SE1->E1_NATUREZ,          Nil})
			aAdd(aVetor, {"E1_CLIENTE", SE1->E1_CLIENTE,          Nil})
			aAdd(aVetor, {"E1_LOJA",    SE1->E1_LOJA,             Nil})
			aAdd(aVetor, {"E1_EMISSAO", SE1->E1_EMISSAO,          Nil})
			aAdd(aVetor, {"E1_VENCTO",  SE1->E1_VENCTO,           Nil})
			aAdd(aVetor, {"E1_VALOR",   SE1->E1_VALOR,            Nil})
			aAdd(aVetor, {"E1_MOEDA",   SE1->E1_MOEDA,            Nil})
				 
			//Inicia o controle de transação
			Begin Transaction
			    //Chama a rotina automática
			    lMsErroAuto := .F.
			    MSExecAuto({|x,y| FINA040(x,y)}, aVetor, 5) //Exclusão do título
			     
				    //Se houve erro, mostra o erro ao usuário e desarma a transação
				    If lMsErroAuto
				    	lRet := .f.
				        MostraErro()
				        DisarmTransaction()
				         MsgAlert("Erro na exclusão do título da NF "+cNroNf+", série "+cSerie)
				    EndIf
			//Finaliza a transação
			End Transaction
			
		endif
	ENDIF 
ENDIF   	
	    
if !empty(cArea)
	dbSelectArea(cArea)
endif 

Return(lRet)    
