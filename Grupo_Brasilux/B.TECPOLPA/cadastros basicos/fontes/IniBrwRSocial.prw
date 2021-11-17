#Include 'Protheus.ch'

/*
Autor: Mauricio-Chaus
Descrição:  Função chamada no Inicializado padrão do Browser do campo C5_XNREDUZ , para trazer o nome
            fantasia do cliente ou fornecedor dependedo do Tipo de Pedido de Venda e/ou entrada de nota
            
*/

User Function IniBrwRSocial(_Origem)
Local nReduz := " "
Local _aArea	:= GetArea()

If _Origem ="OMS"
	If (SC5->C5_TIPO="N" .or.  SC5->C5_TIPO="C" .or. SC5->C5_TIPO="I" .or. SC5->C5_TIPO="P")
		nReduz := Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME")
	Else
		nReduz := Posicione("SA2",1,xFilial("SA2")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A2_NOME")
	EndIf
Else
	If (SF1->F1_TIPO="B" .or. SF1->F1_TIPO="D" )
		nReduz := Posicione("SA1",1,xFilial("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA,"A1_NOME")
	Else
		nReduz := Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"A2_NOME")
	EndIf
EndIf

RestArea(_aArea)
Return(nReduz)

