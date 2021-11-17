#INCLUDE "rwmake.ch"
/**  MA030ROT - Ponto de entrada para incluir novas rotinas no cadastro de cliente
***/
//26/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function MT030ROT()
     Local aButton	:= {}
     
     If FWCodEmp() == '11' //Empresas que são do grupo 11(Tecpolpa).
        //Chama rotina Chaus  para incluir o botao de legenda no cadastro de cliente
        If SUPERGETMV("CF_ATIVARC", .F. , .F.)
           aButton := U_CHROTC02()
        Endif
     Endif
Return aButton
