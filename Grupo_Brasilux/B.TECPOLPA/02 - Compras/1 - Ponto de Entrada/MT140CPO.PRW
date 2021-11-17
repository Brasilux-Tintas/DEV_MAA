#Include 'Protheus.ch'

//26/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function MT140CPO()
     Local aCampos := {}

     If FWCodEmp() = '11' //Empresas que são do grupo 11(Tecpolpa).
        aCampos := {'D1_XQTVL'} 
     Endif
Return aCampos
