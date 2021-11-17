#include "protheus.ch"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ  MTA200  บAutor  ณ Cleber O. Dominguesบ Data ณ    /05/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Bloqueia cadastro de estruturas em nํveis abaixo do prin-  บฑฑ
ฑฑบ          ณ cipal. Usuแrios estavam incluindo / alterando itens em nํ- บฑฑ
ฑฑบ          ณ vel errado por engano.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX TINTAS TษCNICAS LTDA.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
//30/09/2019 - Luํs Gustavo - Adequa็ใo para release 12.1.25
User Function MTA200() 
     Local cAux := oTree:GetCargo()
     Local lRet := .t.

     If FWCodEmp() <> '11' //Empresas que nใo sใo do grupo 11(Tecpolpa).  
        If (Val(SubStr(cAux, 43, 9)) != 1) .and. (Val(SubStr(cAux, 43, 9)) != 0)
           If (Paramixb == "I")
              MsgBox("Inclusao nใo permitida nesse nํvel!", "Aten็ใo...", "STOP")
              lRet := .f.
           Else
              If Substr(cAux, 1, 15) != cCodAtual
                 MsgBox("Edi็ใo de produto nใo permitida nesse nํvel!", "Aten็ใo...", "STOP")
                 lRet := .f.
              Endif
           Endif
        Endif
     Endif   
Return(lRet)
