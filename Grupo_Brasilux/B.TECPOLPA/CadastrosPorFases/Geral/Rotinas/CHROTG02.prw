#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"


/**
CHROTG02 - Axcadastro SZQ
**/

User Function CHROTG02

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "SZQ"

dbSelectArea("SZQ")
dbSetOrder(1)

AxCadastro(cString,"Cad. x Set. x Etapas",cVldExc,cVldAlt)  


Return