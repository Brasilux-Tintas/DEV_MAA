#include 'TOTVS.CH'
/* Ponto de Entrada para ocultar o Help QIP650ENSCAD quando se utiliza o parâmetro 
   MV_QIPMAT ativado e o produto possui uma especificação cadastrada sem ensaios no 
   módulo Inspeção de Processos. */
//30/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function QIP650ENSCAD()
     Local _lRet := .T.

     If FWCodEmp() <> '11' //Empresas que não são do grupo 11(Tecpolpa).
        _lRet := .F.
     Endif
Return( _lRet )