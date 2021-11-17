#Include 'Protheus.ch'
/*
Autor: Mauricio-Chaus
Objetivo:  Mostrar a razao social do cliente ou Fornecedor no pedido de venda, no campo
           inicializador padrão quando foi alterar, visualizar e excluir o pedido de venda

*/



User Function IniPadRSocial()
Local nReduz := " "
Local _aArea	:= GetArea()

If !INCLUI
	If (SC5->C5_TIPO="N" .or.  SC5->C5_TIPO="C" .or. SC5->C5_TIPO="I" .or. SC5->C5_TIPO="P")
		nReduz := Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME")
	Else
		nReduz := Posicione("SA2",1,xFilial("SA2")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A2_NOME")
	EndIf
EndIf

RestArea(_aArea)
Return(nReduz)

