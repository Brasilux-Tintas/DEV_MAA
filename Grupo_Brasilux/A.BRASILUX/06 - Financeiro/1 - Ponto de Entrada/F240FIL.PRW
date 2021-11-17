#Include "TOTVS.CH"
#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"

/*/
{Protheus.doc} F240FIL
Chamada do fonte BRFIN030 para elaborar filtro na montagem do bordero
@type  User Function
@author André Fracassi (3f Consultoria)
@since 23/09/2020
@version P12 12.1.25
@param param_name, param_type, param_descr
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
User Function F240FIL()

    Local _cRet := " "

    If FindFunction("U_BRFIN030")
        _cRet := U_BRFIN030( cModPgto )
    EndIf

Return( _cRet )
