#include 'TOTVS.CH'
#include 'topconn.CH'
User Function FA070TIT()
     Local cArea    := Alias()
     Local _aArea   := GetArea()
     Local lRet     := .F.
     Local cQry     := ""
     Local nDescMax := 0  
     Local _cCodUsr := RetCodUsr()
Local  _cGrpEmp := ALLTRIM(FWGrpCompany())

do case 
case _cGrpEmp == '01' //Empresas do grupo 01-BRASILUX
        /*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
        ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
        ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
        ฑฑบPrograma  ณ F070DSC  บAutor  ณ Luํs G. de Souza   บ Data ณ  18/01/06   บฑฑ
        ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
        ฑฑบDesc.     ณ Ponto de entrada para libera็ใo do campo desconto na baixa บฑฑ
        ฑฑบ          ณ de titulos a receber somente para usuแrios autorizados.    บฑฑ
        ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
        ฑฑบUso       ณ Brasilux Tintas T้cnicas Ltda.                             บฑฑ
        ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
        ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
        ฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
        //Se for Administrador tem acesso irrestrito
        If Empty( RetSqlName("SZW") ) .OR. ( PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),_cCodUsr) = 0) .OR. ( nDESCONT <= nDescMax )
           Return(.t.)
        Endif
        nDescMax := GETMV("MV_CRDESCM")
        cQry += "SELECT SZW.ZW_ACESSOS, SZW.ZW_DEPTO "
        cQry += "FROM "+RetSqlName("SZW")+" SZW WITH (NOLOCK) "
        cQry += "WHERE SZW.ZW_FILIAL = '"+xFilial("SZW")+"' "
        cQry += "  AND SZW.ZW_ROTINA = 'FINA070' "
        cQry += "  AND ZW_USUARIO = '"+_cCodUsr+"' "

        TCQuery cQry ALIAS "TCQ" NEW
        DbSelectArea("TCQ")
        If !Bof() .and. !Eof()
           lRet := Iif(SubStr(TCQ->ZW_ACESSOS, 1, 1) == '*', .t., .f.)
        Endif
        IF !lRet
           MsgBox("Desconto NรO PERMITIDO! ", "Aten็ใo", "STOP")
        Else 
           If !nDESCONT <= nDescMax
              lRet := .f.
              MsgBox("Desconto ้ maior do que o permitido de: "+TransForm(nDescMax, "@E 99.99"), "Aten็ใo", "STOP")
           Endif
        Endif 
        DbSelectArea("TCQ")
        DbCloseArea() 
case _cGrpEmp == '11' //Empresas do grupo 11-TECPOLPA
        //============================================================================//
        // Autor    | Dyego Figueiredo / www.chaus.com.br                             //
        //----------------------------------------------------------------------------//
        // Data     | 31/05/2015                                                      //
        //----------------------------------------------------------------------------//
        // Descricao| O ponto de entrada FA070TIT sera executado apos a confirmacao   //
        //          | da baixa do contas a receber.								      //
        //----------------------------------------------------------------------------//
        // Objetivo | Verificar se o titulo a ser baixado possui um RA ou NCC         // 
        //          | em aberto, e sugere a compensa็ใo.						      //
        //----------------------------------------------------------------------------//
        // Programa |																  //
        // Fonte	| FINA070.PRW													  //
        //----------------------------------------------------------------------------//
        // Partida  | Menu de programa                                                //
        //============================================================================//
        lRet := u_RFIN0002( SE1->E1_CLIENTE, SE1->E1_LOJA, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_PREFIXO )
endcase 
RestArea(_aArea)
If !Empty(cArea)
   DbSelectArea(cArea)
Endif
Return( lRet )
