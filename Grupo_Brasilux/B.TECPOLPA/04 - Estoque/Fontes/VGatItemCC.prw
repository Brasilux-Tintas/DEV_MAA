#Include 'Protheus.ch'
/*
Autor: Mauricio/Chaus
Descrição:  
     Validacao de gatilho sequencia 021 disparado pelo B1_COD para preenchimento do campo
     B1_ITEMCC referente ao ITem contábol para o Cliente da TecPolpa
  

*/

User Function VGatItemCC(_Orig)
Local _Ret := .F.
Local aArea    := GetArea()

If _Orig = "C"  //Item contábil dos clientes da TecPolpa

	
	If !_Ret .and. M->B1_TIPO = "TA"
		_Ret := .T.
	EndIf
	
	If !(_Ret)  .and. M->B1_TIPO="PA" .AND. SUBSTR(M->B1_COD,2,3) <> "AAA" //Não e TecPolpa
		_Ret := .T.
	EndIF
ElseIF _Orig = "T"  //Item Contábil da TecPolpa
	If M->B1_TIPO="PA" .and.  SUBSTR(M->B1_COD,2,3) = "AAA"
		_Ret := .T.
	EndIf
EndIf



RestArea(aArea)
Return(_Ret)

