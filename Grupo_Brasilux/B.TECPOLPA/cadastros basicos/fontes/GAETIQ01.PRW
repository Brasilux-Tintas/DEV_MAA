#INCLUDE "rwmake.ch"

#INCLUDE "topconn.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "rwmake.ch" 

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±?Programa  =GAETIQ01 ?Autor  =Tiago  - Chaus      ? Data =  09/05/2016  ?±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕp±±
±±?Desc.     =Gatilho usado no preenchimento dos campos B1_TIPO e B1_GRUPO   ?±±
±±?          =para preenchimento automatico do campo B1_XETIQUE para                     	  ?±±
±±?          =Objetivo: Gravar a tolerancia de entrada de mercadoria.     ?±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕp±±
*/

User Function GAETIQ01()
/*
Local _cGrupos:=""
Local _cTipos:=""
Local _lRet:=.F.

_cGrupos := getMV("MV_XGRPETI")
_cTipos :=  getMV("MV_XTIPETI")

if !(Empty(_cGrupos)) 
	If  M->B1_GRUPO $  _cGrupos
		_lRet:=.T.
	EndIf
Else
	_lRet:=.T.
EndIf

if !(Empty(_cTipos)) 
	If  M->B1_TIPO $  _cTipos
		_lRet:=.T.
	EndIf
Else
	_lRet:=.T.
EndIf

Return _lRet*/

Local _cGrupos:=""
Local _cTipos:=""
Local _lImp:=.F.
Local _cRet:=""

_cGrupos := getMV("MV_XGRPETI")
_cTipos :=  getMV("MV_XTIPETI")

if !(Empty(_cGrupos)) 
	If  M->B1_GRUPO $  _cGrupos
		_lImp:=.T.
	EndIf
Else
	_lImp:=.T.
EndIf

IF !_lImp
	_cRet:="N"
	Return _cRet

EndIf
_lImp:=.F.

if !(Empty(_cTipos)) 
	If  M->B1_TIPO $  _cTipos
		_lImp:=.T.
	EndIf
Else
	_lImp:=.T.
EndIf

If _lImp
	_cRet:="S"
Else
	_cRet:="N"
EndIf

Return _cRet