#include 'TOTVS.CH'
#DEFINE EVE_HRE_70      '240'
#DEFINE EVE_HRE_110     '262'
#DEFINE EVE_HRE_NOT     '239'

/*/{Protheus.doc} PNM07001
Tratamento de horas para o banco de horas, quando for hora extra de adicional noturno + horas extras normais
@type function
@version 
@author Luís Gustavo
@since 27/04/2020
@return Nil, Função sem retorno
/*/
User Function PONCALD
     Local _cFunc    := SRA->RA_MAT
     Local _aAuxDia1 := { }
     Local _nX, _nY
     Local _nLimite  := 1.20 //Valor em Centesimal corresponde a 1:12h
     Local _lLimite  := .f.
     Local _nIndLim  := 0
     Local _nTotHor  := 0

     /*+------------------------------------------------------------+
       | ANALISE DO HORAS DO BANCO DE HORAS POR DIA POR FUNCIONARIO |
       +------------------------------------------------------------+*/
     DbSelectArea("SPI")
     SPI->( DbSetOrder( 2 ) )
     If SPI->( DbSeek( xFilial("SPI") + _cFunc ) )
        While !Eof() .and. SPI->PI_FILIAL == xFilial("SPI") .and. SPI->PI_MAT == _cFunc
              If SPI->PI_DATA >= STOD( SubStr( cPerApo, 1, 8 ) ) .and. ( SPI->PI_PD == EVE_HRE_NOT .or. SPI->PI_PD == EVE_HRE_70 .or. SPI->PI_PD == EVE_HRE_110 )
                 If aScan( _aAuxDia1, { |x| x[1] == SPI->PI_DATA } ) == 0
                    aAdd( _aAuxDia1, { SPI->PI_DATA, 1, { { SPI->PI_PD, SPI->PI_QUANT, SPI->PI_QUANTV, SPI->( RECNO( ) ) } } } )
                 else
                    _aAuxDia1[aScan( _aAuxDia1, { |x| x[1] == SPI->PI_DATA } )][2] += 1
                    aAdd( _aAuxDia1[aScan( _aAuxDia1, { |x| x[1] == SPI->PI_DATA } )][3], { SPI->PI_PD, SPI->PI_QUANT, SPI->PI_QUANTV, SPI->( RECNO( ) ) } )
                 Endif
              Endif
              DbSelectArea("SPI")
              SPI->( DbSkip( ) )
        EndDo
     Endif
     /*+------------------------------------------------------------+*/

     /*+-----------------------------------------------------------------------------------------+
       | ANALISE SE EXISTEM MAIS DE DOIS LANÇAMENTOS DE HORA EXTRAS EM UM DIA PARA O FUNCIONARIO |
       +-----------------------------------------------------------------------------------------+*/
     For _nX := 1 To Len( _aAuxDia1 )
         _nTotHor   := 0
         _lLimite   := .f.
         _nIndLim   := _nY
         _nMantemBH := 0
         _nDifBH    := 0
         _nDifFP    := 0
         If _aAuxDia1[_nX][2] > 1 //Analisar se houveram mais que dois lançamentos por dia de H.E. para o B.H.
            For _nY := 1 To Len( _aAuxDia1[_nX][3] ) //Verificar se um dos lançamentos atingiu o limite diário do B.H.
                _nTotHor += Round( fConvHr( _aAuxDia1[_nX][3][_nY][2], 'D' ), 2 )
                If fConvHr( _aAuxDia1[_nX][3][_nY][2], 'D' ) >= _nLimite .and. !_lLimite
                   _lLimite := .T.
                   _nIndLim := _nY //Indicador da posição do array que atingiu o limite diário para B.H.
                Endif
            Next
            If _nTotHor > _nLimite //Verifica se a soma das H.E. excedem o limite para o B.H.
               /*+-----------------------------------------------------------------------------------+
                 | Analise para ajuste dos lançamentos para B.H. (SPI) e/ou Folha de Pagamento (SPB) |
                 | IMPORTANTE: SPB (Resultados para folha): Horas centesimais - sem valorização, pois|
                 |                                          as horas serão valorizadas no calculo da |
                 |                                          folha.                                   |
                 |             SPI (Banco de horas):        Horas sexagenais  - normal e valorizadas |
                 +-----------------------------------------------------------------------------------+*/
               For _nY := 1 To Len( _aAuxDia1[_nX][3] )
                   //Posiciono no Cadastro de Eventos (uso para valorização do B.H. - SPI)
                   DbSelectArea("SP9")
                   SP9->( DbSetOrder( 1 ) )
                   SP9->( DbSeek(xFilial("SP9") + _aAuxDia1[_nX][3][_nY][1] ) )
                   //Posiciono no Cadastro de Verbas (uso para valorização do Resultado - SPB)
                   DbSelectArea("SRV")
                   SRV->( DbSetOrder( 1 ) )
                   SRV->( DbSeek( xFilial("SRV") + SP9->P9_CODFOL ) )
                   If _lLimite //Se existir um evento que já atinge limite diário
                      If !_nY == _nIndLim //Ajusto pelo Indicador diferente da posição do array encontrado na análise da SPI(B.H.)
                         DbSelectArea("SPB")
                         SPB->( DbSetOrder( 1 ) )
                         If SPB->( DbSeek( xFilial("SPB") + _cFunc + _aAuxDia1[_nX][3][_nY][1] ) )
                            //Posiciono nas horas do Banco de horas para exclusão
                            DbSelectArea("SPI")
                            SPI->( DbSetOrder( 2 ) )
                            If SPI->( DbSeek( xFilial("SPI") + SRA->RA_MAT + DTOS( _aAuxDia1[_nX][1] ) + _aAuxDia1[_nX][3][_nY][1] ))
                               RecLock("SPI", .f.)
                                  SPI->( DbDelete() )
                               SPI->( MsUnLock( ) )
                            Endif
                            //Verifico se as horas são valorizadas ou não
                            RecLock("SPB", .f.)
                               SPB->PB_HORAS += Round( fConvHr( _aAuxDia1[_nX][3][_nY][2], 'D' ), 2 )
                            SPB->( MsUnLock( ) )
                         else
                            //Grava a verba nova no SPB para pagamento da Folha
                            RecLock("SPB", .t.)
                               SPB->PB_FILIAL := xFilial("SPB")
                               SPB->PB_MAT    := SRA->RA_MAT
                               SPB->PB_PD     := _aAuxDia1[_nX][3][_nY][1]
                               SPB->PB_TIPO1  := 'H'
                               SPB->PB_HORAS  := Round( fConvHr( _aAuxDia1[_nX][3][_nY][2], 'D' ), 2 )
                               SPB->PB_DATA   := STOD( SubStr( cPerApo, 9, 8 ) )
                               SPB->PB_CC     := SRA->RA_CC
                               SPB->PB_TIPO2  := 'G'
                            SPB->( MsUnLock() )
                            //Excluo o evento da SPI para respeitar a regra do limite do ponto
                            DbSelectArea("SPI")
                            SPI->( DbSetOrder( 2 ) )
                            If SPI->( DbSeek( xFilial("SPI") + SRA->RA_MAT + DTOS( _aAuxDia1[_nX][1] ) + _aAuxDia1[_nX][3][_nY][1] ))
                               RecLock("SPI", .f.)
                                  SPI->( DbDelete() )
                               SPI->( MsUnLock( ) )
                            Endif
                         Endif
                      Endif
                   Else //Se não existir evento que atingiu o limite diário
                      _nMantemBH += Round( fConvHr( _aAuxDia1[_nX][3][_nY][2], 'D' ), 2 )
                      If _nMantemBH >= _nLimite
                         _nDifFP := _nMantemBH - _nLimite
                         _nDifBH := Round( fConvHr( _aAuxDia1[_nX][3][_nY][2], 'D' ), 2 ) - _nDifFP

                         //Posiciono e ajusto SPI (B.H.)
                         DbSelectArea("SPI")
                         SPI->( DbSetOrder( 2 ) )
                         If SPI->( DbSeek( xFilial("SPI") + SRA->RA_MAT + DTOS( _aAuxDia1[_nX][1] ) + _aAuxDia1[_nX][3][_nY][1] ))
                            RecLock("SPI", .f.)
                               SPI->PI_QUANT  := fConvHr( _nDifBH, 'H' )
                               SPI->PI_QUANTV := fConvHr( _nDifBH * ( SP9->P9_BHPERC / 100 ), 'H' )
                            SPI->( MsUnLock( ) )
                         Endif

                         //Posiciono e ajusto SPB (Folha)
                         DbSelectArea("SPB")
                         SPB->( DbSetOrder( 1 ) )
                         If SPB->( DbSeek( xFilial("SPB") + _cFunc + _aAuxDia1[_nX][3][_nY][1] ) )
                            //Verifico se as horas são valorizadas ou não
                            RecLock("SPB", .f.)
                               SPB->PB_HORAS += _nDifFP
                            SPB->( MsUnLock( ) )
                         else
                            RecLock("SPB", .t.)
                               SPB->PB_FILIAL := xFilial("SPB")
                               SPB->PB_MAT    := SRA->RA_MAT
                               SPB->PB_PD     := _aAuxDia1[_nX][3][_nY][1]
                               SPB->PB_TIPO1  := 'H'
                               SPB->PB_HORAS  := _nDifFP
                               SPB->PB_DATA   := STOD( SubStr( cPerApo, 9, 8 ) )
                               SPB->PB_CC     := SRA->RA_CC
                               SPB->PB_TIPO2  := 'G'
                            SPB->( MsUnLock() )
                         Endif
                      Endif
                   Endif
               Next
            Endif
         Endif
     Next
Return