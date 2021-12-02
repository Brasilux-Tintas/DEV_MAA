#Include "TOTVS.CH"
#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"
#Include "RWMAKE.CH"

#Define CRLF    CHR(13)+CHR(10)

/*/
{Protheus.doc} BRFIN031
Limpa o campo E2_IDCNAB para disponibilizar em novo borderô
@type  User Function
@author André Fracassi (3f Consultoria)
@since 08/10/2020
@version P12 12.1.25
@param _cParam01, character, recebe o tipo da carteira (R-Receber;P-Pagar)
@param _cParam02, character, recebe o numero do borderô
@return _lRet, logical, retorna se foi retirado ou não o título do borderô
@example
    (examples)
@see
    (links_or_references)
@table
@history
@obs Ticket : #018962 - CNAB Pagamento (SISPAG)
@menu
/*/
User Function BRFIN031( _cParam01, _cParam02 )

    Local _lRet     := .F.
    Local _cTipo    := _cParam01
    Local _cNumBor  := _cParam02
     u_zcfga01( 'BRFIN031' ) //LGS#2021202 - Gravação de log de utilização da rotina
    // Efetua a chamada somente se for Borderô Pagamento
    If _cTipo = "P"
        If MsgYesNo("Deseja retirar do Borderô : " + _cNumBor + ", o título abaixo ?"   + CRLF + CRLF +;
                    "Prefixo : "    + SE2->E2_PREFIXO                                   + CRLF +;
                    "Número : "     + SE2->E2_NUM                                       + CRLF +;
                    "Parcela : "    + SE2->E2_PARCELA                                   + CRLF +;
                    "Fornecedor : " + AllTrim( SE2->E2_NOMFOR )                         + CRLF +;
                    "Valor R$ : "   + Transform( SE2->E2_VALOR, PesqPict("SE2", "E2_VALOR") ), "Atenção" )

            If !Empty( SE2->E2_IDCNAB )
                _lRet := .T.
                If RecLock("SE2", .F. )
                    SE2->E2_OCORREN := " "
                    SE2->E2_IDCNAB  := " "
                    SE2->( MsUnlock() )
                EndIf
            EndIf
        EndIf
    EndIf
Return( _lRet )
