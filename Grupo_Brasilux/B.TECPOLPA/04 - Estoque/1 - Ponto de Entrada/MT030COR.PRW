#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH"
/*
MT030COR = PE Adiciona Legendas de cores na tela de cadastro de cliente
*/
//26/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User function MT030COR()
     If FWCodEmp() = '11' //Empresas que são do grupo 11(Tecpolpa).
        //Chama rotina Chaus incluir legendas de cores no cadastro de cliente
        If SUPERGETMV("CF_ATIVARC", .F. , .F.)
           aCores := U_CHROTC04()
        Endif
     Endif
Return aCores

