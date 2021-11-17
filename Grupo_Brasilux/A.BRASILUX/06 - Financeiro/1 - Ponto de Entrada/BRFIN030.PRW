#Include "TOTVS.CH"
#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"

/*/
{Protheus.doc} BRFIN030
Filtro de bordero - DOC,TED,CC,Boleto
@type  User Function
@author André Fracassi (3f Consultoria)
@since 23/09/2020
@version P12 12.1.25
@param _cParam01, character, Recebe o Modelo de Pagamento
@return _cRet, character, Retorna expressao filtro para retorno dos titulos
@example
    (examples)
@see
    (links_or_references)
@table
@history
@obs Ticket : #018962 - CNAB Pagamento (SISPAG)
@menu
/*/
User Function BRFIN030( _cParam01 )

    Local _cRet         := ""
    Local _cModPgto     := _cParam01

    If _cModPgto $ "30"                  // boletos do mesmo banco
        _cRet := " Substr( E2_CODBAR, 01, 03 ) == '" + cPort240 + "' .AND. !Empty( E2_CODBAR ) "

    ElseIf _cModPgto $ "31"              // boletos de outros bancos
        _cRet := " Substr( E2_CODBAR, 01, 03 ) != '" + cPort240 + "' .AND. !Empty( E2_CODBAR ) "

    ElseIf _cModPgto $ "01"              // 01-Transferencia para conta corrente (mesmo banco)
        _cRet := " IIf( Empty( E2_FORBCO ), SA2->A2_BANCO, E2_FORBCO ) == '" + cPort240 + "' .AND. Empty( E2_CODBAR ) .AND. !Empty( E2_FORBCO ) "

    ElseIf _cModPgto $ "03|41"           // 03-DOC ou 41 - TED
        _cRet := " IIf( Empty( E2_FORBCO ), SA2->A2_BANCO, E2_FORBCO ) != '" + cPort240 + "' .AND. Empty( E2_CODBAR ) .AND. !Empty( E2_FORBCO ) "

    ElseIf _cModPgto $ "11|13"           // 11/13-Concessionarias
        //_cRet := " IIf( !Empty(E2_CODBAR ), SA2->A2_XCONCE, SA2->A2_XCONCE ) = '1' "

    EndIf

   //( DbSetOrder(2) ) //Cleber(30/11/2020)->Passou a dar erro, retirada ordenação

Return( _cRet )
