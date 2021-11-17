#Include 'Protheus.ch'
#include "rwmake.ch"

//ponto de entrada utilizado no cotaocao web
//25/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function MT094END()
     If FWCodEmp() == '11' //Empresas que são do grupo 11(Tecpolpa).
        If SUPERGETMV("CT_ATIVACT", .F. , .F.) .and. SUPERGETMV("CT_ENVIAPC", .F. , .F.)
           u_CHRTCT06(PARAMIXB)
        Endif
     Endif	
Return

