#include 'protheus.ch'
#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function chamTree()  
Private oDlgs

DEFINE MSDIALOG oDlgs TITLE "Tela de BIPE" FROM 000, 000 TO 200, 300 PIXEL 

TButton():New( 000, 000, "Consulta Bipe Pedido", oDlgs,{|| u_MyTree() },152,050,,,.F.,.T.,.F.,,.F.,,,.F. )
TButton():New( 050, 000, "Consulta Bipe Bordero", oDlgs,{|| u_TreeBord() },152,050,,,.F.,.T.,.F.,,.F.,,,.F. )

ACTIVATE MSDIALOG oDlgs CENTERED
Return Nil    