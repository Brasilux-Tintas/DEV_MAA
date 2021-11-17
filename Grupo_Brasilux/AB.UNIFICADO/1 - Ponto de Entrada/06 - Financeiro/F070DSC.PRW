#include 'rwmake.ch'
#include 'topconn.ch'
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ F070DSC  บAutor  ณ Luํs G. de Souza   บ Data ณ  27/12/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada para libera็ใo do campo desconto na baixa บฑฑ
ฑฑบ          ณ de titulos a receber somente para usuแrios autorizados.    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Brasilux Tintas T้cnicas Ltda.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
//30/09/2019 - Luํs Gustavo - Adequa็ใo para release 12.1.25
User Function F070DSC()
     Local _cArea  := Alias()
     Local cQry
     Local cCodUsr := RetCodUsr()
     Local lAcsDsc := .f.

     If FWCodEmp() <> '11' //Empresas que nใo sใo do grupo 11(Tecpolpa).
        If Empty(RetSqlName("SZW"))
           Return(.t.)
        Endif
        If (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),cCodUsr) == 0)
           lAcsDsc := .t.
        Else
           cQry := "SELECT ZW_ACESSOS "
           cQry += "FROM "+RetSqlName("SZW")+" SZW WITH (NOLOCK) "
           cQry += "WHERE (ZW_FILIAL = '"+xFilial("SZW")+"') "
           cQry += "AND (ZW_ROTINA = 'FINA070') "
           cQry += "AND (ZW_USUARIO = '"+cCodUsr+"') "
           TCQuery cQry ALIAS "TCQZW" NEW

           DbSelectArea("TCQZW")
           If !Bof() .and. !Eof()
              lAcsDsc := Iif(SubStr(TCQZW->ZW_ACESSOS, 1, 1) == '*', .t., .f.)
           Endif
           DbSelectArea("TCQZW")
           DbCloseArea()
        Endif    

        If !empty(_cArea)
           DbSelectArea(_cArea)
        Endif 
     Else
        lAcsDsc := .T. //LGS#20191007 - Para Tecpolpa nใo hแ o tratamento de desconto utilizado na Brasilux at้ essa data.
     Endif
Return( lAcsDsc )