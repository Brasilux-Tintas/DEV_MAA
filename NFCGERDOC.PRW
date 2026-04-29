#include 'Protheus.ch'
 
User Function NFCGERDOC()
 
Local cOpc      := PARAMIXB[1]
Local aDados    := PARAMIXB[2]
Local aItVenc   := {}
Local aContr    := {}
Local aSupInfo  := {}
Local cCotCod   := ""
Local cFornCod  := ""
Local cLoja     := ""
Local cProp     := ""
Local cTpDoc    := ""
Local cProdCod  := ""
Local nQtdSel   := 0
Local nVlrTot   := 0
Local nVlrUnit  := 0
Local lRet      := .T.
Local cMsg      := ""
Local aRet      := {}
 
 /*
if cOpc == "1" // Geração documento por proposta
 
    cCotCod   := aDados[1] // -- Número da cotação
    cFornCod  := aDados[2] // -- Código do fornecedor
    cLoja     := aDados[3] // -- Loja
    cProp     := aDados[4] // -- Proposta vigente.
    cTpDoc    := aDados[5] // -- 1 = Pedido de Compra, 2 = Contrato(GCT)
 
    // -- Customização
 
    lRet := .F.
    cMsg := "Não foi permitido gerar a cotação - PE NFCGERDOC"
 
elseif cOpc == "2" //Geração documento por item      
 
    cCotCod     := aDados[1] // -- Número da cotação
    aItVenc     := aDados[2] // -- Itens selecionados na proposta por item - Cada posição no array aItVenc é um respectivo item selecionado na análise.
    aContr      := aDados[3] // -- Dados complementares ao selecionar contrato(Virá em branco se não houver contrato selecionado).
 
    aSupInfo    := aItVenc[1]['supplierInfo'] //-- Detalhes da proposta do primeiro item vencedor selecionado.
     
    cProp     := aSupInfo['proposal']         // -- Proposta vigente.
    nVlrUnit  := aSupInfo['unityvalue']       // -- Valor unitário
    nVlrTot   := aSupInfo['totalvalue']       // -- Valor total
    cFornCod  := aSupInfo['suppliercode']     // -- Código do fornecedor
    cLoja     := aSupInfo['supplierstore']    // -- Loja
    cTpDoc    := aSupInfo['documenttype']     // -- 1 = Pedido de Compra, 2 = Contrato(GCT)
    cProdCod  := aSupInfo['productcode']      // -- Código do produto
    nQtdSel   := aItVenc[1]['quantityOrder']  // -- Quantidade a ser gerada inserida na tela de formalização.  
 
    // -- Customização
 
    lRet := .F.
    cMsg := "Não foi permitido gerar a cotação - PE NFCGERDOC"
endif
 
aRet := {lRet,cMsg}
*/ 
Return aRet
