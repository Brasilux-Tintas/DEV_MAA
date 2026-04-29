#Include 'Protheus.ch'

/*/{Protheus.doc} MA131KEY
Pont de Entrada para nao permitir aglutinação de itens da SC na cotaçao
@type function Ponto de Entrada
@version  1.00
@author marioantonaccio
@since 14/04/2026
@return character, chave de quebra
/*/
User Function MA131KEY()
 
Local cRet  :=  ''
Local cKey  :=  ParamIXB[1]
 
 If .NOT. 'C1_ITEM'  $  Upper(  cKey  )
     cRet  :=  'C1_ITEM+C1_PRODUTO'
 EndIf
  
 Return cRet
