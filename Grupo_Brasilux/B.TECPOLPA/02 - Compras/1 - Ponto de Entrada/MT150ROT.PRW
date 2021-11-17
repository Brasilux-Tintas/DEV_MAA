#include "rwmake.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "protheus.ch"
#INCLUDE "topconn.ch"
// LOCALIZAÇÃO : Function MATA150 - Função da atualização de cotações.
// EM QUE PONTO : No inico da rotina e antes da execução da Mbrowse da cotação, 
// utilizado para adicionar mais opções no aRotina.
//25/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function MT150ROT()
     Local aRotina := ParamIXB
     If FWCodEmp() == '11' //Empresas que são do grupo 11(Tecpolpa).
        If SUPERGETMV("CT_ATIVACT", .F. , .F.)
           aRotina := U_CHRTCT01(aRotina)
        Endif
     Endif
Return aRotina


