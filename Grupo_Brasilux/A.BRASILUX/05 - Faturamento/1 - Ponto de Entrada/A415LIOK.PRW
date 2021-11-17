#include "protheus.ch"
#Translate MSGBOX( => IW_MsgBox(
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ A415LIOK บAutor  ณ Cleber O. Dominguesบ Data ณ  09/09/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se o item jแ estแ digitado no Or็amento           บฑฑ
ฑฑบ                                                                     - บฑฑ
ฑฑบ                                                                     - บฑฑ
ฑฑบ                                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Brasilux Tintas T้cnicas Ltda.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
//25/09/2019 - Luํs Gustavo - Adequa็ใo para release 12.1.25
User Function A415LIOK()
     Local _cArea    := alias()
     Local aAreaTMP1
     Local cCodPro   := ""
     Local lRet      := .t.

     If FWCodEmp() <> '11' //Empresas que nใo sใo do grupo 11(Tecpolpa).
        If !TMP1->CK_FLAG //Verifica se nใo ้ registro deletado         
           cCodPro := TMP1->CK_PRODUTO
           dbSelectArea("TMP1")
           aAreaTMP1 := GetArea()
           dbGotop()
           While ( !Eof() )
                 If !TMP1->CK_FLAG .And. (TMP1->(RecNo()) <> aAreaTMP1[3]) .And. (TMP1->CK_PRODUTO == cCodPro)
                    lRet = .f.
                    exit 
                 Endif 
                 dbSelectArea("TMP1")
		         dbSkip()
           EndDo
           RestArea(aAreaTMP1)
        Endif
        If !lRet
           MsgBox("Existe item em DUPLICIDADE!", "Aten็ใo...", "ALERT")
        Endif 
        If !empty( _cArea )
           DbSelectArea( _cArea )
        Endif 
     Endif
Return(lRet)
