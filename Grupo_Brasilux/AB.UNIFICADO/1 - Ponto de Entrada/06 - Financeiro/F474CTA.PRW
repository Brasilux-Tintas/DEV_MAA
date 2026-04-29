#include 'TOTVS.CH'

/*/{Protheus.doc} F474CTA
Ponto de entrada para ajuste de informações do banco, agencia e conta corretas, 
para importação do extrato bancario, devido ao cadastro.
@type function
@version 
@author Jose Uliana	
@since 09/01/2025
@return array, Retorna vetor com as informações corretas do banco, agencia e conta.
/*/

User Function F474CTA()
     Local _aRet     as Array
     Local _cBanco   as String
     Local _cAgencia as String
     Local _cConta   as String

     _cBanco   := PARAMIXB[1]
     _cAgencia := PARAMIXB[2]
     _cConta   := PARAMIXB[3]

     If alltrim(FWCodEmp()) == '01'
        If _cBanco == '237'
           If FWFilial() == '01'
              _aRet := { '237', '33839', '297704' }
           ElseIf FWFilial() == '04'
                  _aRet := { '237', '33839', '436003' }
           Endif
        ElseIf _cBanco == '001'
               _aRet := { '001', '33707', '204030-1' }
        ElseIf _cBanco == '341'
               _aRet := { '341', '0649', '26150-0' }
        Else
           _aRet := { _cBanco, _cAgencia, _cConta }
        Endif
     ElseIf Alltrim( xFilial("SA6") ) == '06'
            If _cBanco == '237'
               _aRet := { '237', '33839', '74772' }
            ElseIf _cBanco == '001'
                   _aRet := { '001', '33707', '30813' }
            ElseIf _cBanco == '341'
                   _aRet := { '341', '0484', '414271' }
            Else
               _aRet := { _cBanco, _cAgencia, _cConta }
            Endif
     ElseIf Alltrim( xFilial("SA6") ) == '08'
            If _cBanco == '237'
               _aRet := { '237', '33839', '1449' }
            Else
               _aRet := { _cBanco, _cAgencia, _cConta }
            Endif
     ElseIf ALLTRIM(FWGrpCompany()) == '11'
            If _cBanco == '001'
               _aRet := { '001', '33707', '1086235' } //001-33707-1086235
            ElseIf _cBanco == '237'
                   _aRet := { '237', '3383', '2141' } //237-33839-2141
            ElseIf _cBanco == '341'
                   _aRet := { '341', '0649', '170263' } //341-0649-170263
            ElseIf _cBanco == '756' //Sicoob
                   _aRet := { '341', '3188', '45861' } //756-3188-4-45861-9
            Else
               _aRet := { _cBanco, _cAgencia, _cConta }
            Endif
     Else
        _aRet := { _cBanco, _cAgencia, _cConta }
     Endif
Return _aRet
