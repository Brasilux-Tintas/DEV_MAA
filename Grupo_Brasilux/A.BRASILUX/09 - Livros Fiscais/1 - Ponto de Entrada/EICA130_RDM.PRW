#include 'TOTVS.CH'

/*/{Protheus.doc} EICA130
Ajusta IPI no cadastro de produtos
@type function
@version  v2022.03.02
@author Luis Gustavo de Souza
@since 02/03/2022
/*/
User Function EICA130()
     Local _cParam   := ParamIXB
     
     If _cParam <> NIL
        If _cParam == 'MENU'
           Aadd( aRotina, { "Ajusta IPI Cadastro de Produtos", "U_ZFISA01('M')" , 0 , 6 } ) 
        Endif
     EndIf
Return
