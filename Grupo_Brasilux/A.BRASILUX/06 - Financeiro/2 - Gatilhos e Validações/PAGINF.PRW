#include "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³  PAGINF  ºAutor  ³                    º Data ³    /  /     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Utilizado no Lay-out PAGFOR - BRADESCO (Posição 347-413)   º±±
±±º          ³ Grava informações complementares.                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function Paginf()
     Local _RETINF
     u_zcfga01( 'PAGINF' ) //LGS#2021202 - Gravação de log de utilização da rotina
     If SubStr(SEA->EA_MODELO, 1, 2) == "03"
        _RETINF := SE2->E2_TIPODOC+"00000001"+Space(31)
     ElseIf SubStr(SEA->EA_MODELO, 1, 2) == "31"
            If SubStr(SE2->E2_CODBAR, 1, 3) == "237"
               _RETINF := SubStr(SE2->E2_CODBAR, 05, 04) + SubStr(SE2->E2_CODBAR, 09, 01)+;
                          SubStr(SE2->E2_CODBAR, 11, 01) + SubStr(SE2->E2_CODBAR, 12, 09)+;
                          SubStr(SE2->E2_CODBAR, 22, 02) + SubStr(SE2->E2_CODBAR, 24, 07)+;
                          "0"+;
                          SubStr(SE2->E2_CODBAR, 33, 01) + SubStr(SE2->E2_CODBAR, 04, 01)+;
                          Space(13)
            Else
               _RETINF := SubStr(SE2->E2_CODBAR, 05, 05) + SubStr(SE2->E2_CODBAR, 11, 10)+;
                          SubStr(SE2->E2_CODBAR, 22, 10) + SubStr(SE2->E2_CODBAR, 33, 01)+;
                          SubStr(SE2->E2_CODBAR, 04, 01) + Space(13)
            Endif
     Else
        _RETINF := Space(40)
     Endif
Return(_RETINF)
