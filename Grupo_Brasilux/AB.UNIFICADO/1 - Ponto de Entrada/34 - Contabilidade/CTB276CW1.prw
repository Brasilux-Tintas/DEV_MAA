#include 'TOTVS.CH'

/*/{Protheus.doc} CTB276CW1
Ponto de entrada usado para validar o total do rateio offline se pode ou não ser maior que 100%
CHAMADO: 026760 - Fernando solicitou para deixar todos os rateios poderem ser diferente de 100%
@type function
@version  v.2022.07.26
@author Luis Gustavo Souza
@since 26/07/2022
@return Logical, Retorna verdadeiro deixando o rateio ficar diferente de 100%
/*/
User Function CTB276CW1()
     Local _aArea          := GetArea()
     //Local cTpVld        := PARAMIXB[1]
     //Local cCw1_Tipo     := PARAMIXB[2]
     //Local cCw1_Entidade := PARAMIXB[3]
     //Local nTotRat       := PARAMIXB[4]
     //Local nLinRat       := PARAMIXB[5]
     //Local lRet          := ( cCw1_Tipo == "1" .AND. nTotRat >= 100 )
     Local _lRet           := .T.

     RestArea( _aArea )

Return _lRet
