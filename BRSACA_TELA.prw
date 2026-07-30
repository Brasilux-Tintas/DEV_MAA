#include "Protheus.ch"
#include "colors.ch"
#include "topconn.ch"
#include 'rwmake.ch'

/*/{Protheus.doc} BRSACA_TELA
Tela simplificada de Atendimento ao Cliente (baseada em BRSACA01.prw)
@type function Tela
@version 1.00
@author marioantonaccio
@since 02/06/2026
@return nil
/*/
User Function BRSACA_TELA()

   Local oDlg    := Nil     as Object
   Local oGrp    := Nil     as Object
   Local oSay    := Nil     as Object
   Local oGetNum := Nil     as Object
   Local oGetDt  := Nil     as Object
   Local oCboTp  := Nil     as Object
   Local oGetCod := Nil     as Object
   Local oGetCli := Nil     as Object
   Local oGetAt  := Nil     as Object
   Local oGetAss := Nil     as Object
   Local oMulObs := Nil     as Object
   Local oBtnOk  := Nil     as Object
   Local oBtnEsc := Nil     as Object

   Local cNum := Space(10)  as Character
   Local dData := Date()    as Date
   Local cTipo := "Sem Dev." as Character
   Local cCod := Space(06)  as Character
   Local cCli := Space(40)  as Character
   Local cAtend := Space(30) as Character
   Local cAss := Space(30)  as Character
   Local cObs := Space(500) as Character

   oDlg := MSDialog():New( 091,232,520,760, "Atendimento ao Cliente - Simplificado" , , , .F., , , , , , .T., , , .T. )

   oGrp := TGroup():New( 000,004, 160, 740, "Atendimento", oDlg, CLR_HBLUE, CLR_WHITE, .T., .F. )

   // Dados do SAC
   oSay := TSay():New( 018, 010, {||"Numero:"}, oGrp, , NIL, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 032, 008)
   oGetNum := TGet():New( 016, 042, {|u| If(PCount()>0, cNum := u, cNum)}, oGrp, 120, 010, '', , CLR_BLACK, CLR_WHITE, NIL, , , .T., "", , , .F., .F., , .T., .F., "", "cNum", , )

   oSay := TSay():New( 018, 082, {||"Data:"}, oGrp, , NIL, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 024, 008)
   oGetDt := TGet():New( 016, 104, {|u| If(PCount()>0, dData := u, dData)}, oGrp, 120, 010, '', , CLR_BLACK, CLR_WHITE, NIL, , , .T., "", , , .F., .F., , .T., .F., "", "dData", , )

   oSay := TSay():New( 018, 152, {||"Tp. Desconto:"}, oGrp, , NIL, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 060, 008)
   oCboTp := TComboBox():New( 016, 203, {|u| If(PCount()>0, cTipo := u, cTipo)}, {"Sem Dev.", "NCC", "AB-", "NCC e AB-"}, 150, 012, oGrp, , , , CLR_BLACK, CLR_WHITE, .T., NIL, "", , , , , , , cTipo )

   // Dados do Cliente
   oSay := TSay():New( 048, 010, {||"Codigo:"}, oGrp, , NIL, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 032, 008)
   oGetCod := TGet():New( 047, 042, {|u| If(PCount()>0, cCod := u, cCod)}, oGrp, 080, 010, '', , CLR_BLACK, CLR_WHITE, NIL, , , .T., "", , , .F., .F., , .T., .F., "CLI", "cCod", , )

   oGetCli := TGet():New( 048, 088, {|u| If(PCount()>0, cCli := u, cCli)}, oGrp, 300, 010, '', , CLR_BLACK, CLR_WHITE, NIL, , , .T., "", , , .F., .F., , .T., .F., "", "cCli", , )

   oSay := TSay():New( 048, 186, {||"Fone:"}, oGrp, , NIL, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 024, 008)
   // reutilizamos cAtend para telefone/contato curto
   oGetAt := TGet():New( 047, 210, {|u| If(PCount()>0, cAtend := u, cAtend)}, oGrp, 150, 010, '', , CLR_BLACK, CLR_WHITE, NIL, , , .T., "", , , .F., .F., , .T., .F., "", "cAtend", , )

   // Dados do Atendimento
   oSay := TSay():New( 072, 010, {||"Atendente:"}, oGrp, , NIL, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 040, 008)
   oGetAt := TGet():New( 070, 054, {|u| If(PCount()>0, cAtend := u, cAtend)}, oGrp, 150, 010, '', , CLR_BLACK, CLR_WHITE, NIL, , , .T., "", , , .F., .F., , .T., .F., "", "cAtend", , )

   oSay := TSay():New( 088, 010, {||"Assunto:"}, oGrp, , NIL, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 040, 008)
   oGetAss := TGet():New( 086, 042, {|u| If(PCount()>0, cAss := u, cAss)}, oGrp, 220, 010, '', , CLR_BLACK, CLR_WHITE, NIL, , , .T., "", , , .F., .F., , .T., .F., "T1", "cAss", , )

   oSay := TSay():New( 102, 010, {||"Ocorrência/Problema:"}, oGrp, , NIL, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 080, 008)
   oMulObs := TMultiGet():New( 110, 010, {|u| If(PCount()>0, cObs := u, cObs)}, oGrp, 344, 140, NIL, , CLR_BLACK, CLR_WHITE, , .T., "", , , .F., .F., .T., , , .F., , )

   // Botões
   oBtnOk := TButton():New( 300, 620, "Confirma", oDlg, { || MsgInfo("Dados salvos (simulado).", "Confirmação") }, 080, 016, , , , .T., , "", , , , .F. )
   oBtnEsc := TButton():New( 420, 620, "Sair", oDlg, { || oDlg:End() }, 080, 016, , , , .T., , "", , , , .F. )

   oDlg:Activate(,,,.T.)

Return NIL
