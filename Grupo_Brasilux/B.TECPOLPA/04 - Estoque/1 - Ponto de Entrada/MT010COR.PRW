#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH"
/*
MT010COR = PE Adiciona Legendas de cores na tela de cadastro de produtos
*/
//26/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function MT010COR()
     Local aCores := {}

     If FWCodEmp() == '11' //Empresas que são do grupo 11(Tecpolpa).
        //Chama rotina Chaus incluir legendas de cores no cadastro de produto
        If SUPERGETMV("CF_ATIVARP", .F. , .F.)
           aCores := U_CHROTP04()
        Endif
     Endif
Return aCores

