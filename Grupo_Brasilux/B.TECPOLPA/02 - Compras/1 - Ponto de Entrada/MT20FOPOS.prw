#Include 'Protheus.ch'
/**
	MT20FOPOS - Customizacoes apos a gravacao do Fornecedor.
**/
//26/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function MT20FOPOS()
     If FWCodEmp() = '11' //Empresas que são do grupo 11(Tecpolpa).
        // Chama rotina Chaus incluir enviar email para a proxima etapa
        If SUPERGETMV("CF_ATIVARF", .F. , .F.)
           U_CHROTF04()
        Endif
     Endif
Return