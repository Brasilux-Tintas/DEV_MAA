#Include 'TOTVS.ch'

/*/{Protheus.doc} MTI650LOTE
//TODO Complementa informações do XML para integração com o PCFactory.
//30/09/2019 - Luís Gustavo - Adequação para release 12.1.25
@author gustavosouza
@since 01/01/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function MTI650LOTE()
     Local _cPont := PARAMIXB //Ponteiro para recuperar as informações da SC2. Utilização: &(cPont+"(C2_QUANT)")
     Local _cLote := ""
     Local _aArea := GetArea()

     If FWCodEmp() <> '11' //Empresas que não são do grupo 11(Tecpolpa).
        _cLote := &(_cPont+"(C2_LOTE)")
     Endif
     RestArea(_aArea)
Return _cLote