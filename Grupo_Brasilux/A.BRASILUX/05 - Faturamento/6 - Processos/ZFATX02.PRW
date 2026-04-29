#include 'protheus.ch'

/*/{Protheus.doc} ZFATX02
Programa feito para execução unica no ambiente de emergencia a fim de corrigir a TES
@type function
@version  v.1.01
@author Luis Gustavo Souza
@since 24/11/2023
@return variant, return_description
/*/
User Function ZFATX02()
     Local _cWhere    := ''
     Local _cAliasTmp := GetNextAlias()
     Local _cLogTroca := ''

     _cWhere    := "%"
     _cWhere    += "%"
     
     BeginSql ALIAS _cAliastmp
              SELECT SC5.C5_NUM, SC5.C5_DEPOSI, SC5.C5_APROVA, SC6.C6_OPER, SC5.C5_X_PVSIM, SC5.C5_TIPOCLI, SC6.C6_TES, SUBSTRING(SC6.C6_CF, 1, 1) AS 'SUBTES', SC6.C6_CF, SC6.C6_NOTA, SC5.C5_CLIENTE, SC5.C5_LOJACLI, SC6.C6_PRODUTO, SC6.C6_ITEM, SC5.C5_TIPO, SA1.A1_EST
              FROM SC5010 SC5
              LEFT JOIN SC6010 SC6 ON SC6.C6_FILIAL = SC5.C5_FILIAL AND SC6.%notdel% AND SC6.C6_NUM = SC5.C5_NUM
              LEFT JOIN SA1010 SA1 ON SA1.A1_FILIAL = '' AND SA1.D_E_L_E_T_ = '' AND SA1.A1_COD = SC5.C5_CLIENTE AND SA1.A1_LOJA = SC5.C5_LOJACLI
              WHERE SC5.C5_FILIAL  = '010101'
                AND SC5.%notdel%  AND SC5.C5_EMISSAO >= '20231114'
                AND SC5.C5_X_PVSIM <> ''
                AND SC6.C6_OPER    <> ''
                AND SC6.C6_NOTA    <> ''
                %exp:_cWhere%
     EndSql
     _cLogTroca += Time() + Chr(13) + Chr(10)
     _cLogTroca += 'PEDIDO | ITEM | PRODUTO      | TES ANT | CF ANT | TES NEW | CF NEW | TROCOU?' + Chr(13) + Chr(10)
     DbSelectArea( _cAliastmp )
     ( _cAliastmp )->( DbGoTop() )
     While !Eof()
           _cLogTroca += ( _cAliastmp )->C5_NUM + ' | ' + ( _cAliastmp )->C6_ITEM + '   | ' + RTRIM( ( _cAliastmp )->C6_PRODUTO ) + ' | ' + ( _cAliastmp )->C6_TES + '    | ' + ( _cAliastmp )->C6_CF + '   | '
           _cNewTes   := U_BRFAT053( ( _cAliastmp )->C5_TIPO, ( _cAliastmp )->C5_CLIENTE, ( _cAliastmp )->C6_PRODUTO )
           DbSelectArea('SF4')
           SF4->( DbSetOrder( 1 ) )
           If SF4->( DbSeek( xFilial('SF4') + _cNewTes ) )
              If ( _cAliastmp )->C5_DEPOSI == 'S'
                 _cCFNew := ( _cAliastmp )->SUBTES + Iif( Empty(SF4->F4_XCFODEP), SubStr( SF4->F4_CF, 2, 3 ), SubStr( SF4->F4_XCFODEP, 2, 3 ) )
              Else
                 _cCFNew := ( _cAliastmp )->SUBTES + SubStr( SF4->F4_CF, 2, 3 )
              Endif
              _cLogTroca += _cNewTes + '     | ' + _cCFNew + '   | ' 
              DbSelectArea('SC6')
              SC6->( DbSetOrder(1) )
              If DbSeek( xFilial('SC6') + ( _cAliastmp )->C5_NUM + ( _cAliastmp )->C6_ITEM + ( _cAliastmp )->C6_PRODUTO )
                 If SC6->C6_TES <> _cNewTES
                    _cLogTroca += 'ERRADO'
                 else
                    _cLogTroca += 'OK'
                 Endif
              Endif
           Endif
           _cLogTroca += CHR(13) + CHR(10)
           ( _cAliastmp )->( DbSkip() )
     EndDo
     _cLogTroca += Time() + Chr(13) + Chr(10)
     MEMOWRITE( 'C:\TEMP\SFA_NOTA.log', _cLogTroca )

     
Return
