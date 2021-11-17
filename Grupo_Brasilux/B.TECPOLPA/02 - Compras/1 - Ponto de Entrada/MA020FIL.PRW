#INCLUDE "rwmake.ch"
/**   MA020FIL - Adiciona Filtro para o cadastro de fornecedores
***/
//26/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function MA020FIL()
     If FWCodEmp() == '11' //Empresas que são do grupo 11(Tecpolpa).
        //Chama rotina Chaus  para setar os campos obrigatorios em disponiveis
        If SUPERGETMV("CF_ATIVARF", .F. , .F.)
           U_CHROTF02()
        Endif
     Endif
Return
