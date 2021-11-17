#Include 'Protheus.ch'


/*
Autor: Mauricio-Chaus
Descrição:  Inicializar o campo B1_XDESC com a descricao do produto

*/

User Function IniPDescPro()
Local nReduz := " "
Local _aArea	:= GetArea()
Local _nPos1 := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="D1_COD"})
Local _nCodPro  := aCols[n,_nPos1]
Local i := 0 


If !Empty(ALLTRIM(_nCodPro))
 For i := 1 to len(acols)
  nReduz := Posicione("SB1",1,xFilial("SB1")+aCols[i,_nPos1],"B1_DESC")
 Next i
Else
	nReduz := " "
EndIf

RestArea(_aArea)
Return(nReduz)

