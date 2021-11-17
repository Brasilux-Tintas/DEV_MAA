#include "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PAGAGEN   ºAutor  ³                    º Data ³    /  /     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa para separar a agência do codigo de barra para o  º±±
±±º          ³ programa do PAGFOR - posições(99 - 104)                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PagAgen() 
     _Agencia := "00000"

     IF SUBSTR(SE2->E2_CODBAR, 1, 3) == "237"
        _Agencia := "0" + SubStr(SE2->E2_CODBAR, 20, 4)
        _RETDIG  := " "
        _DIG1    := SubStr(SE2->E2_CODBAR, 20, 1)
        _DIG2    := SubStr(SE2->E2_CODBAR, 21, 1)
        _DIG3    := SubStr(SE2->E2_CODBAR, 22, 1)
        _DIG4    := SubStr(SE2->E2_CODBAR, 23, 1)
        _MULT    := (Val(_DIG1) * 5) + (Val(_DIG2) * 4) + (Val(_DIG3) * 3) + (Val(_DIG4) * 2)
        _RESUL   := Int(_MULT / 11)
        _RESTO   := Int(_MULT % 11)
        _DIGITO  := 11 - _RESTO
        _RETDIG  := If(_RESTO == 0, "0", If(_RESTO == 1, "0", Alltrim(Str(_DIGITO))) )
        _Agencia := _Agencia + _RETDIG
     EndIf
Return(_Agencia)