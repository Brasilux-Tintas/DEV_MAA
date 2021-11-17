#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} A265NACD
//TODO Ponto de entrada que valida endereçamento pelo ACD
//26/09/2019 - Luís Gustavo - Adequação para release 12.1.25
@author 
@since   /  /    
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function A265NACD()
     Local lRet := .F.
     If FWCodEmp() = '11' //Empresas que são do grupo 11(Tecpolpa).
        lRet := .T.
     Endif
return lRet