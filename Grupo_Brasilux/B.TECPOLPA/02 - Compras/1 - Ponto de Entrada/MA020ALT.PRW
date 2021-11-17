/** MA020ALT - Validacoes adicionais para alteraÁ„o do fornecedor 
*** Funcao chamada para validar se o usuario preencheu os campos obrigatorios 
***  de acordo com a regra por campos/tipo de cadastro/Grupo de Usuario definida na tabela SZP
***/ 
//26/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function MA020ALT()
     Local lRet := .T.

     If FWCodEmp() == '11' //Empresas que são do grupo 11(Tecpolpa).
        //Chama rotina Chaus  para validar se o usuario preencheu os campos obrigatorios 
        If SUPERGETMV("CF_ATIVARF", .F. , .F.)
           lRet := u_CHROTF01()	  
        Endif
     Endif
Return lRet    
