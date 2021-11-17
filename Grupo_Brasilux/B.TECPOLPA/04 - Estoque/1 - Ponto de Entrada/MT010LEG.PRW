#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH"
/**
	MT010LEG - PE Adiciona Legendas no MATA010
**/
//26/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function MT010LEG()
     If FWCodEmp() = '11' //Empresas que são do grupo 11(Tecpolpa).
        // Chama rotina Chaus incluir legendas no cadastro de produto
        If SUPERGETMV("CF_ATIVARP", .F. , .F.)
           U_CHROTP05()
        Endif
     Endif
Return



