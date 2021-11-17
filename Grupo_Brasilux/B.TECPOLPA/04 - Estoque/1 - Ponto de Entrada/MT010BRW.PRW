#INCLUDE "rwmake.ch"
/**  MT010BRW - PE Adiciona Botoes no MATA010
***/
//26/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function MT010BRW()
     Local aButton

     If FWCodEmp() = '11' //Empresas que são do grupo 11(Tecpolpa).
        //Chama rotina Chaus  para incluir o botao de legenda no cadastro de produto
        If SUPERGETMV("CF_ATIVARP", .F. , .F.)
           aButton := U_CHROTP02()
        Endif
     Endif
Return aButton
