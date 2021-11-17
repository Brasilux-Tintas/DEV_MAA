#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"


/**
CHROTG01 - Axcadastro SZP
**/

User Function CHROTG01



Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "SZP"

dbSelectArea("SZP")
dbSetOrder(1)

AxCadastro(cString,"Cad. x Set. x Cps",cVldExc,cVldAlt)  


Return
