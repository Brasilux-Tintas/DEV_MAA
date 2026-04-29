#include 'TOTVS.CH'
#include 'tbiconn.ch'
#include "rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} ZWSDLI01
Programa que faz a integração do Protheus com o ProdWin para Tecpolpa.
@type function
@version  v.2022.05
@author Luís Gustavo Souza
@since 22/07/2022
/*/
User Function ZWSDLI01()
     
     Local _oRest
     Local _aHeader := {}
     Local _cError
     Local _nStatus
     Local _cURL     := GETMV( "ZP_PAR0045" ) //"http://187.94.59.147:9000/ws/Integracao.asmx/ImportarOrdemProducao"
     Local _cTipoPro := GETMV( "ZP_PAR0046" ) //Tipos de produtos que serão integrados
     Local _nTPTxPro := GETMV( "ZP_PAR0047" ) //Tipo da Taxa de Produção de acordo com o manual de integração do ProdWin
     Local _aArea    := GetArea()

     _aArea := GetArea()

     If Empty( SC2->C2_ROTEIRO )
        MessageBox( "Ordem de produção sem roteiro informado não pode ser integrada.", "Atenção", 16 )
        Return
     Endif

     SB1->( DbSeek( xFilial('SB1') + SC2->C2_PRODUTO ) )
     If _cTipoPro $ SB1->B1_TIPO
        MessageBox( "Somente os produtos com os tipos " + _cTipoPro + "podem ser integrados com o ProdWin.", "Atenção", 16 )
        Return
     Endif

     _oRest := FwRest():New( _cURL) // INSTANCIAÇÃO DE OBJETO REST
     _oRest:setPath("")

     aAdd( _aHeader, "Accept-Encoding: UTF-8" )
     aAdd( _aHeader, "Content-Type: application/json; charset=utf-8" )

     jBody := JsonObject():New()
     
     If SG2->( DbSeek( xFilial('SG2') + SC2->C2_PRODUTO + SC2->C2_ROTEIRO ) )
        While !Eof() .and. Alltrim( SG2->G2_PRODUTO ) == Alltrim( SC2->C2_PRODUTO )
              _dDate := SubStr( DTOS( SC2->C2_DATPRI ), 1, 4 ) + '-' + SubStr( DTOS( SC2->C2_DATPRI ), 5, 2 ) + '-' + SubStr( DTOS( SC2->C2_DATPRI ), 7, 2 )
              jBody[ "cdOrdemProducao" ]  := SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN
              jBody[ "cdOperacao" ]       := SG2->G2_OPERAC
              jBody[ "cdFerramenta" ]     := ""
              jBody[ "descFerramenta" ]   := ""
              jBody[ "cdEstrutura" ]      := ""
              jBody[ "cdProduto" ]        := SC2->C2_PRODUTO
              jBody[ "descProduto" ]      := SB1->B1_DESC
              jBody[ "nomeCliente" ]      := Iif( SubStr( SC2->C2_PRODUTO, 1, 4 ) == '1COC', 'COCA COLA', Iif( SubStr( SC2->C2_PRODUTO, 1, 1 ) == '1', 'MARCAS PROPRIAS', Iif( SubStr( SC2->C2_PRODUTO, 1, 1 ) == '2', 'GRANDES REDES', 'BENEFICIAMENTO' ) ) )
              jBody[ "cdMaquina" ]        := SC2->C2_LINHA //SG2->G2_RECURSO
              jBody[ "taxaProducao" ]     := SG2->G2_LOTEPAD //SG2->G2_TEMPAD
              jBody[ "tipoTaxaProducao" ] := _nTPTxPro
              jBody[ "pecasCiclo" ]       := 1 //SG2->G2_LOTEPAD
              jBody[ "pontosPeca" ]       := 0
              jBody[ "dtInicio" ]         := _dDate
              jBody[ "dtEntrega" ]        := ""
              jBody[ "qtdPecas" ]         := SC2->C2_QUANT
              jBody[ "complemento1"]      := ''
              jBody[ "complemento2"]      := ''
              jBody[ "complemento3"]      := ''
              jBody[ "complemento4"]      := ''
              jBody[ "complemento5"]      := ''
              jBody[ "complemento6"]      := ''
              jBody[ "complemento7"]      := ''
              jBody[ "complemento8"]      := ''
              jBody[ "complemento9"]      := ''
              jBody[ "complemento10"]     := ''
              jBody[ "complemento11"]     := ''
              jBody[ "complemento12"]     := ''
              jBody[ "complemento13"]     := ''
              jBody[ "complemento14"]     := ''
              jBody[ "complemento15"]     := ''

              DbSelectArea('SG2')
              SG2->( DbSkip( ) )
        EndDo
     Endif

     _oRest:SetPostParams( jBody:toJson() )
     _oRest:SetChkStatus( .F. )

     If _oRest:Post( _aHeader )
        _cError  := ""
        _nStatus := HTTPGetStatus( @_cError )
        If _nStatus >= 200 .AND. _nStatus <= 299
           If Empty( _oRest:getResult() )
              MessageBox( StrZero( _nStatus, 3), 'Atenção', 64 )
           Else
              MessageBox( _oRest:getResult(), 'Atenção', 64 )
           Endif
        Else
           MessageBox( _cError, 'Atenção', 64 )
        Endif
     Else
        MessageBox( _oRest:getLastError() + Chr(13) + Chr(10) + _oRest:getResult(), 'Atenção', 16 )
     Endif
     RestArea( _aArea )
Return
