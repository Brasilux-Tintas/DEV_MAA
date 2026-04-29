#include "protheus.ch"

User Function GP670ARR()
Local aRet := {}

aadd(aRet,{"E2_HIST",'MATR.F.:'+RC1->RC1_MAT+'- '+RC1->RC1_DESCRI,NIL})
aadd(aRet,{"E2_CCD",RC1->RC1_CC,NIL})
aadd(aRet,{"E2_CCUSTO",RC1->RC1_CC,NIL})

Return aRet
