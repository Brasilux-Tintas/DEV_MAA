#Include 'Protheus.ch'

User Function GatTrib(_QR)
Local aArea			:= GetArea()
Local _Ret		:= " "    
Local _Suco		:= SubStr(M->B1_COD,5,2)
Local _Sabor    := SubStr(M->B1_COD,7,2)

DBSelectArea("SZ2")
SZ2->(DBSetOrder(1))
SZ2->(DBSeek(xFilial("SZ2")+_Suco+_Sabor,.F.))
If SZ2->(Found())
	If _QR ='NCM'
  		_Ret := SZ2->Z2_POSIPI
	ElseIf _QR = 'ORG'        
		_Ret	:= SZ2->Z2_ORIGEM
	ElseIf _QR = 'GTR'           
		_Ret	:= SZ2->Z2_GRPTRIB
	EndIf  
Else   
	DBSelectArea("SZ2")
	SZ2->(DBSetOrder(2))
	SZ2->(DBSeek(xFilial("SZ2")+_Suco,.F.)) 
	While !SZ2->(Eof()) .and. _Suco = SZ2->Z2_SUCO
		If empty(SZ2->Z2_SABOR)  
			If _QR ='NCM'
	  			_Ret := SZ2->Z2_POSIPI
			ElseIf _QR = 'ORG'        
				_Ret	:= SZ2->Z2_ORIGEM
			ElseIf _QR = 'GTR'           
				_Ret	:= SZ2->Z2_GRPTRIB
			EndIf  
			Exit
		EndIF 
		DBSelectArea("SZ2")
		SZ2->(DBSkip())
	EndDo
EndIf 
                                      
RestArea(aArea)
Return(_Ret)