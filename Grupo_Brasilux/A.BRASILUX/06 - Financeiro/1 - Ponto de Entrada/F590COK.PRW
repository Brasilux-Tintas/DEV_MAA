#Include "TOTVS.CH"
#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"

/*/
{Protheus.doc} F590COK
Chamada do fonte BRFIN031 para limpar campo SE2
@obs
Ponto de entrada que valida o cancelamento/retirada de um determinado título de um borderô.
@type  User Function
@author André Fracassi (3f Consultoria)
@since 08/10/2020
@version P12 12.1.25
@param param_name, param_type, param_descr
@return _lRet, logical, Retorna verdadeiro ou false se permite a retirada do título em borderô
@example
    (examples)
@see
    https://tdn.totvs.com/pages/releaseview.action?pageId=6071559
@table
@history
@obs Ticket : #018962 - CNAB Pagamento (SISPAG)
@menu
/*/
User Function F590COK()

    Local _lRet     := .F.
    Local _cTipo    := ParamIxb[ 01 ]           // identifica o tipo do cnab {P-Pagar;R-Receber}
    Local _cNumBor  := ParamIxb[ 02 ]           // identifica o código do borderô

    If FindFunction("U_BRFIN031")
        _lRet := U_BRFIN031( _cTipo, _cNumBor )
    EndIf

Return( _lRet )
