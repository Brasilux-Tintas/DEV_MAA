#include "totvs.ch"

/*/{Protheus.doc} ZCFGA01
Rotina para gravação de log de utilização de customização na qual foi chamada.
@type function
@version  v.2021.01
@author Luís Gustavo Souza
@since 26/10/2021
@param _cRotina, variant, Variável com nome da rotina que foi chamada.
/*/
User Function ZCFGA01( _cRotina )
     Local _aArea := GetArea()

     DbSelectArea("ZA4")
     ZA4->( DbSetOrder( 1 ) )
     If ZA4->( DbSeek( xFilial( "ZA4" ) + _cRotina ) )
        If RecLock( "ZA4", .f. )
           ZA4->ZA4_USER   := __cUSERID + " - " + cUserName
           ZA4->ZA4_DATA   := dDataBase
           ZA4->ZA4_HORA   := Time()
           ZA4->ZA4_MODULO := StrZero( nModulo, 2 )
        Endif
     else
        If RecLock( "ZA4", .t. )
           ZA4->ZA4_FILIAL := xFilial("ZA4")
           ZA4->ZA4_ROTINA := _cRotina
           ZA4->ZA4_USER   := __cUSERID + " - " + cUserName
           ZA4->ZA4_DATA   := dDataBase
           ZA4->ZA4_HORA   := Time()
           ZA4->ZA4_MODULO := StrZero( nModulo, 2 )
        Endif
     Endif
     RestArea( _aArea )
Return
