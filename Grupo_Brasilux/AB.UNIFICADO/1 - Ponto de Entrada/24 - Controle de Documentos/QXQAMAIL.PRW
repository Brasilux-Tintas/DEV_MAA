#include 'TOTVS.CH'

/*/{Protheus.doc} QXQAMAIL
Ponto de entrada para validar a alteração dos dados de e-mail nos módulos de qualidade
@type function
@author Luis Gustavo
@since 29/08/2019
@version 1.0
@return ${_lRet}, ${Retorna o valor falso se a chamada for do fechamento. }
@example
(examples)
@see (links_or_references)
/*/
User Function QXQAMAIL()
     Local _lRet := .F.
     
     //**************************************************************************
     //*** Verifica na pilha de chamadas se está sendo executado o fechamento
     //*** da Folha de Pagamento, se sim não altera as informações referente a
     //*** e-mail do funcionário.
     //If FWIsInCallStack( 'GPEM120' )
     //   _lRet := .F.
     //Endif
Return _lRet
