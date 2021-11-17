#Include 'Protheus.ch'
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH" 


/*

    Funcao criada por Fabiano Dias no dia 22/09/16 para que seja checada se a(s) proxima(s) etapa(s) deve(m) ser geradas posteriormente 
    o preenchimento dos campos determinados no cadastro de setor x campos, pois pode existir uma condicao no cadastro de etapa x setor que
    indique que uma ou mais etapas nao sejam checadas de acordo com determinado criterio estabelecido	

*/
User Function CHROTG10 (_cTipo, _nProxEtapa,_nMaxEtapa)


Local _nEtapa

	For _nEtapa:= _nProxEtapa To _nMaxEtapa

		dbSelectArea("SZQ")
		//ZQ_FILIAL+ZQ_TIPO+ZQ_CODET+ZQ_SETOR                                                                                                                             
		SZQ->(dbSetOrder(1))
		If SZQ->(dbSeek(xFilial("SZQ") + _cTipo + AllTrim(Str(_nEtapa))))
		
			//Verifica se existe uma condicao para executar a etapa	
			If !Empty(SZQ->ZQ_COND001)
			
				//Se a condicao for atendida, levando em consideracao os campos da SB1 a etapa sera checada, caso contrario nao
				If &(SZQ->ZQ_COND001)
				
					exit					
				
				EndIf
			
				//Caso nao tenha uma condicao para executar a etapa a mesma eh dada como obrigatoria a passagem pelo cadastro de produto
				Else
				
					exit
			
			EndIf
				
		EndIf

	Next _nEtapa

Return _nEtapa
