#include "protheus.ch"
User Function BRFAT097()
Local cAlias := "Z01"
Local cTitulo := "TES Inteligente"
Local cVldExc := ".T."
Local cVldAlt := ".T."
dbSelectArea(cAlias)
dbSetOrder(1)
AxCadastro(cAlias,cTitulo,cVldExc,cVldAlt)
Return