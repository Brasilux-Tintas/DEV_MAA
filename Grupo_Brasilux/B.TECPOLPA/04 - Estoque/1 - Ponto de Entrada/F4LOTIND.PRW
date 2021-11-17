#INCLUDE "totvs.ch"

/*/{Protheus.doc} F4LOTIND
//Ponto de entrada na impressão de etiquetas pelo ACDI011 para ajuste das informações retornadas ao acionar a tecla F4 (Lote) 
@author Luis Gustavo Souza
@since 27/03/2020
@version 1.0
@return ${_aArrayF4}, ${Conteudo dos lotes desconsiderando empenhos e retornando a quantidade existente do lote. }

@type function
/*/
User Function F4LOTIND()
     Local _aArrayF4 := PARAMIXB[1]
     Local _cAliasTMP

     If FWCodEmp() == '11' //Somente para empresas do grupo 11(Tecpolpa).
        If Alltrim( FunName() ) == 'ACDI011'
           _cAliasTMP := GetNextAlias()
           BEGINSQL ALIAS _cAliasTMP
                    SELECT * 
                    FROM %Table:SB8% SB8
                    WHERE SB8.B8_FILIAL  = %exp:xFilial("SB8")%
                      AND SB8.%notDel%
                      AND SB8.B8_PRODUTO = %exp:MV_PAR01%
                      AND SB8.B8_LOCAL   = %exp:MV_PAR04%
                      AND SB8.B8_SALDO  <> 0 
                     ORDER BY SB8.B8_LOTECTL
           ENDSQL

           DbselectArea( _cAliasTMP )
           While !Eof()
                 _nPosLot := aScan( _aArrayF4, { |x| Alltrim( x[1] ) == Alltrim( ( _cAliasTMP )->B8_LOTECTL ) } )
                 If _nPosLot > 0
                    _aArrayF4[ _nPosLot ][ 3 ] := ( _cAliasTMP )->B8_SALDO
                 Else
                    aAdd( _aArrayF4, { ( _cAliasTMP )->B8_LOTECTL, ( _cAliasTMP )->B8_PRODUTO, ( _cAliasTMP )->B8_SALDO, 0, STOD( ( _cAliasTMP )->B8_DTVALID ), ( _cAliasTMP )->B8_LOTEFOR, STOD( ( _cAliasTMP )->B8_DATA ), 0, ( _cAliasTMP )->B8_DOC, ( _cAliasTMP )->B8_SERIE, ( _cAliasTMP )->B8_CLIFOR, ( _cAliasTMP )->B8_LOJA } )
                 Endif
                 ( _cAliasTMP )->( DbSkip(  ) )
           ENDDO
           DbSelectArea( _cAliasTMP )
           ( _cAliasTMP )->( DbCloseArea(  ) )
        Endif
     Endif

Return _aArrayF4