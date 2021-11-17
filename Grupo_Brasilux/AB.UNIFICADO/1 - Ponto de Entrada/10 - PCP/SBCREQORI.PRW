#INCLUDE "PROTHEUS.CH"

// Ponto de entrada para manipular o Cod. de requisição no MATA685 - Apontamento de Perdas por OP , na movimentação de origem.
// Criado para tratar tipo de movimentação no apontamento de perda de produtos de terceiros

USER FUNCTION SBCREQORI()

Local cReqOri := Paramixb[1]

IF SB1->B1_AGREGCU =='1' .AND. cReqOri $ 'RE0.RE1'
    cReqOri := 'RE9'
Endif

Return cReqOri
