#Include 'Protheus.ch'
 
/*/{Protheus.doc} MA131QSC
Ponto de entrada mao gerar aglutinação de itens na Cotação 
@type function Ponto de Entrada
@version  1.00
@author marioantonaccio
@since 14/04/2026
@return codeblock, bloco de codigo de quebra de itens
/*/
User Function MA131QSC()
  
Local bQuebra:= PARAMIXB[1]
  
bQuebra:={|| C1_ITEM+C1_PRODUTO}
  
Return bQuebra
