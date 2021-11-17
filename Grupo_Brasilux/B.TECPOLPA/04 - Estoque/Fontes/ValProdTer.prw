#Include 'Protheus.ch'

User Function ValProdTer()
Local _aArea := GetArea()
Local _cProd := ""
Local _lRet	 := .T.
Local _nQtdIni := 0

If .T.
  return .T.
Endif

IF FunName()=="MATA220"
	_cProd := M->B9_COD
	_nQtdIni := M->B9_QINI
	If SUBSTR(_cProd,1,1) == "4" .AND. _nQtdIni > 0
		If Alltrim(POSICIONE("SB1", 1, xFilial("SB1")+_cProd,"B1_TIPO")) <> "TA"
			_lRet := .F.
			Aviso("Prod. Terceiros","O Produto "+ Alltrim(_cProd) +" não pertence à TecPolpa. "+;
	    				"Sua entrada deverá ser via Documento Fiscal!",{"OK"})
			Return(_lRet)
		Endif
	EndIf
	
ElseIf FunName()=="MATA270"
	_cProd := M->B7_COD
	If SUBSTR(_cProd,1,1) == "4"
		If Alltrim(POSICIONE("SB1", 1, xFilial("SB1")+_cProd,"B1_TIPO")) <> "TA"
			_lRet := .F.
			Aviso("Prod. Terceiros","O Produto "+ Alltrim(_cProd) +" não pertence à TecPolpa. "+;
	    				"Sua entrada deverá ser via Documento Fiscal!",{"OK"})
			Return(_lRet)
		Endif
	EndIf
Endif
RestArea(_aArea)

Return(_lRet)