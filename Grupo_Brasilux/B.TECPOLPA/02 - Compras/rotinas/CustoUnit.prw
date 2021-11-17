#Include 'Protheus.ch'
#Include 'topconn.ch'

/*
Função para cálculo do custo do produto: valor do produto - impostos
Autor: Igor Manrique - Chaus
Data: 13/12/2016
*/
User Function CustoUnit(_cFor, _cLoja,_nItem,_nValUnit,_nQuant,cPro,_nPrcTot,cTes)
Local aArea	:= GetArea()
Local cCrdICM 	:=""
Local cCrdIPI 	:=""
Local cCrdPIS 	:=""
Local cCrdISS 	:=""
Local _nValICM 	:=0
Local _nValIPI 	:=0
Local _nValPIS 	:=0
Local _nValCOF 	:=0
Local _nValISS 	:=0
//Local _nCusPro 	:=0
Local _nBASEICM := _nALIQICM := _nBASEIPI := _nALIQIPI := _nBASEPIS := _nALIQPIS := _nBASECOF := _nALIQCOF := 	_nBASEISS := _nALIQISS := 0
Local _lInclui 	:= INCLUI
Local _lAltera	:= ALTERA	

Local _nCusPro := 0


If !(_lInclui .OR. _lAltera .OR. IsInCallStack("A120Copia"))
	Return(_nCusPro)
Endif

dbSelectArea("SF4")
SF4->(dbSetOrder(1))
SF4->(dbSeek(xFilial("SF4")+cTes))
cCrdICM := SF4->F4_CREDICM
cCrdIPI := SF4->F4_CREDIPI
cCrdPIS := SF4->F4_PISCOF
cCrdISS := SF4->F4_ISS


// Adiciona dados dos produtos na rotina de calculo de impostos       
MaFisAdd(cPro, cTes, _nQuant, _nValUnit, 0, "", "", 0, 0, 0, 0, 0, _nPrcTot, 0)        
  
If cCrdICM == "S"
	_nBASEICM := MaFisRet(_nItem,"IT_BASEICM")
	_nALIQICM := MaFisRet(_nItem,"IT_ALIQICM")
	_nValICM  := MaFisRet(_nItem,"IT_VALICM")
Endif

If cCrdIPI == "S"
	_nBASEIPI := MaFisRet(_nItem,"IT_BASEIPI")
	_nALIQIPI := MaFisRet(_nItem,"IT_ALIQIPI")
	_nValIPI  := MaFisRet(_nItem,"IT_VALIPI")
Endif

If cCrdPIS == "1"
	_nBASEPIS := MaFisRet(_nItem,"IT_BASEPIS")
	_nALIQPIS := MaFisRet(_nItem,"IT_ALIQPIS")
	_nValPIS  := MaFisRet(_nItem,"IT_VALPIS")
ElseIf cCrdPIS == "2"
	_nBASECOF := MaFisRet(_nItem,"IT_BASECOF")
	_nALIQCOF := MaFisRet(_nItem,"IT_ALIQCOF")
	_nValCOF  := MaFisRet(_nItem,"IT_VALCOF")
Else
	_nBASEPIS := MaFisRet(_nItem,"IT_BASEPIS")
	_nALIQPIS := MaFisRet(_nItem,"IT_ALIQPIS")
	_nValPIS  := MaFisRet(_nItem,"IT_VALPIS")

	_nBASECOF := MaFisRet(_nItem,"IT_BASECOF")
	_nALIQCOF := MaFisRet(_nItem,"IT_ALIQCOF")
	_nValCOF  := MaFisRet(_nItem,"IT_VALCOF")
Endif

If cCrdISS == "S"
	_nBASEISS := MaFisRet(_nItem,"IT_BASEPIS")
	_nALIQISS := MaFisRet(_nItem,"IT_ALIQPIS")
	_nValISS  := MaFisRet(_nItem,"IT_VALISS")
Endif   

 
If _nValPIS == 0
	_nValPIS := (_nALIQPIS * _nPrcTot)/100
Endif

If _nValCOF == 0
	_nValCOF := (_nPrcTot * _nALIQCOF)/100
Endif

_nCusPro := (_nPrcTot -(_nValICM+_nValIPI+_nValPIS+_nValCOF+_nValISS))/_nQuant


RestArea(aArea)

Return(_nCusPro)

