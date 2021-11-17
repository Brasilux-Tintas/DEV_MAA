/*/{Protheus.doc} PNmddsr01
Ponto de Entrada para tratamento de 1/6 de DSR
No padrão é considerado as horas de atraso e deveria ser considerado 1/6 por dia de atraso.
O sistema estava fazendo dessa forma, porém como o sabado é compensado não consegue ajustar automaticamente.
Dessa forma foi feito o calculo em um unico identificador da folha, na soma dos Descontos de DSR já enviando
a quantidade de Horas corretas para a folha, devendo portando o percentual da verbas estar como 100%. 
@type function
@author Luís Gustavo
@since 29/05/2018
@version 1.0
@return ${nHoras}, ${retorna a quantidade de horas sexagenal}
@example
(examples)
@see (http://tdn-homolog.totvs.com/pages/releaseview.action?pageId=6082531)
21/06/2018 - Ajuste no retorno de horas para quantidade menor que 4.01 horas
/*/
User Function PNmddsr01()
     Local nHoras := ParamIXB[ 2 ]
     Local nOcorr := ParamIXB[ 3 ]

     If GETMV("ZP_PAR0001")
        If nHoras >= GETMV("ZP_PAR0003")
           //-- Em Horas para centesimal
           _nHor := nHoras
           _nMin := ( _nHor - Int( _nHor ) ) * 100
           _nMin := ( _nMin / 60 )
           _nHor := Int( _nHor ) + _nMin 

           _nDSR := Round( _nHor * GETMV("ZP_PAR0002"), 2 )

           //-- Em Centesimal para horas
           _nHor := _nDSR
           _nMin := ( _nHor - Int( _nHor ) )
           _nMin := Round( ( _nMin * 60 ) / 100, 2 )
           _nHor := Int( _nHor ) + _nMin

           nHoras := _nHor
        Else
           nHoras := 0
        Endif
     Endif
Return( { nHoras } )