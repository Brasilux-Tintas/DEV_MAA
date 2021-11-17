#include 'TOTVS.CH'
/*/{Protheus.doc} QIPF3SC2
//TODO Retorna a consulta do SF3.
//30/09/2019 - Luís Gustavo - Adequação para release 12.1.25
@author 
@since   /  /   9
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function QIPF3SC2()
     Local _cRet := "QC2"
      
     If FWCodEmp() <> '11' //Empresas que não são do grupo 11(Tecpolpa).
        _cRet := "XC3"
     Endif
Return _cRet