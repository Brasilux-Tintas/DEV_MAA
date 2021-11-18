/*/{Protheus.doc} M310FILIAL
description
@type function
@version  
@author gustavosouza
@since 22/09/2021
@return variant, return_description
Cleber(23/09/21)->Ajustes para transferência entre Brasilux/Matriz e Resina
/*/
User Function M310FILIAL()
 //    Local cUserLog := ParamIxb[1]      // Recebimento do Parametro 'Usuario' do ponto.
//     Local aFilsAtu := ParamIxb[2]      // Recebimento do Parametro 'Filiais' do ponto
Local _cFilOrig          // Filias de origem.
Local cFildest          // Filias de destino.
Local aFilPE := ""                  // Array de retorno, início com valor diferente de array para o caso de não retornar nada e o sistema precisar desconsiderar
Local _cFilial
     u_zcfga01( 'M310FILIAL' ) //LGS#2021118 - Gravação de log de utilização da rotina
If alltrim(FWGrpCompany()) == '01' //Empresas que não são do grupo 11(Tecpolpa).
   _cFilial := alltrim(FWCodFil())
   _cFilOrig := _cFilial
   cFildest := iif(ALLTRIM(MV_PAR03) == _cFilial,ALLTRIM(MV_PAR04),ALLTRIM(MV_PAR03))
   if !empty(cFildest)
      aFilPE := {}
      Aadd( aFilPE, _cFilOrig )           // Inserindo filias de origem  na 1 dimensao do array.
      Aadd( aFilPE, cFildest )           // Inserindo filias de destino na 2 dimensao do array.
   endif 
endif      
Return( aFilPE )
