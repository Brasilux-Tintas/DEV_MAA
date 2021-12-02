#include "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PAGACTA  ºAutor  ³                    º Data ³    /  /     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa para separar a C/C do codigo de barra para o pro- º±±
±±º          ³ grama do PAGFOR - posições(105 - 119)                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function Pagacta()
     u_zcfga01( 'PAGACTA' ) //LGS#2021202 - Gravação de log de utilização da rotina
     _CTACED := "0000000000000"
     If SubStr(SE2->E2_CODBAR, 1, 3) == "237"
        _Ctaced := StrZero(Val(SubStr(SE2->E2_CODBAR, 37, 7)), 13, 0)
        _RETDIG := " "
        _DIG1   := SubStr(SE2->E2_CODBAR, 37, 1)
        _DIG2   := SubStr(SE2->E2_CODBAR, 38, 1)
        _DIG3   := SubStr(SE2->E2_CODBAR, 39, 1)
        _DIG4   := SubStr(SE2->E2_CODBAR, 40, 1)
        _DIG5   := SubStr(SE2->E2_CODBAR, 41, 1)
        _DIG6   := SubStr(SE2->E2_CODBAR, 42, 1)
        _DIG7   := SubStr(SE2->E2_CODBAR, 43, 1)
        _MULT   := (Val(_DIG1) * 2) + (Val(_DIG2) * 7) + (Val(_DIG3) * 6) + (Val(_DIG4) * 5) + (Val(_DIG5) * 4) + (Val(_DIG6) * 3) + (Val(_DIG7) * 2)
        _RESUL  := Int(_MULT / 11)
        _RESTO  := Int(_MULT % 11)
        _DIGITO := StrZero((11 - _RESTO), 1, 0)
        _RETDIG := If(_resto == 0, "0", If(_resto == 1, "P", _DIGITO) )
        _Ctaced := _Ctaced + _RETDIG
     EndIf
Return(_Ctaced)
