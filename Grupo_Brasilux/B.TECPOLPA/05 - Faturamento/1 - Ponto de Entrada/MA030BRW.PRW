#Include 'Protheus.ch'
//26/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function MA030BRW()
     If FWCodEmp() == '11' //Empresas que são do grupo 11(Tecpolpa).
        //Chama rotina Chaus para inicializar as variaveis
        If SUPERGETMV("CF_ATIVARC", .F. , .F.)
           U_CHROTC06()
        Endif
     Endif
Return

