#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"


User Function RELPEDOP()

Local cRelat := 'R4'

alert('RELPEDOP')

CallIReport(cRelat,{'0',1,.F.,.T.})

Return Nil



