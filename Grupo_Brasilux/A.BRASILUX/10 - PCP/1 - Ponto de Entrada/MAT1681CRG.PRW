#include 'protheus.ch'

/*/{Protheus.doc} MATI681CRG
Ponto de entrada desenvolvido para tratar apontamento a maior feito pelo PCFactory
@type function
@version 
@author Luís Gustavo
@since 03/06/2020
@return array, return_description
/*/
User Function MATI681CRG()
     Local _aRet      := {} 
     Local _nPos      := aScan( PARAMIXB, { |aX| AllTrim( aX[1] ) == "H6_TIPO" } )
     //Local _nPosPT    := aScan( PARAMIXB, { |aX| AllTrim( aX[1] ) == "H6_PT" } )
     Local _aArea     := GetArea()
     Local _nQtdMaior := 0
     Local _nQtdFalta := 0
     Local _nQtdApont := nQtdSOG
     //Local _nQtdPerd  := 0
     //---------------- LGS#20231023 ----- RETIRADA DA GRAVAÇÃO DO LOG DE ROTINA PARA MELHORA DE PERFORMANCE.
     //u_zcfga01( 'MATI681CRG' ) //LGS#2021201 - Gravação de log de utilização da rotina
     If FWCodEmp() <> '11' //Empresas que não são do grupo 11(Tecpolpa).
        If PARAMIXB[ _nPos ][ 2 ] == "P"
           //Verificar se SC2 está posicionado
           If nQtdSOG > 0 //Não é apontamento de Horas, nem status da OP
              _nQtdFalta := SC2->C2_QUANT - SC2->C2_QUJE
              _nQtdMaior := _nQtdApont - _nQtdFalta
              //Apontamento de produção
              //Adiciona quantidade a maior para o apontamento.
              If _nQtdMaior > 0
                 aAdd( _aRet, { "H6_QTMAIOR", _nQtdMaior, Nil } ) 
              Endif
           Endif
        Else
           //Apontamento de parada
        EndIf
	 Endif
     RestArea( _aArea )
Return _aRet
