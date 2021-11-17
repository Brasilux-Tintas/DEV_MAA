#include 'TOTVS.CH'

/*/{Protheus.doc} QPGERQPK
//TODO Existente na integração do PCP com QIP no final da geração da tabela QPK criada através da inclusão da Ordem de Produção..
//30/09/2019 - Luís Gustavo - Adequação para release 12.1.25
@author Luís Gustavo
@since   /  /    
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function QPGERQPK()
     If FWCodEmp() <> '11' //Empresas que não são do grupo 11(Tecpolpa).
        If PARAMIXB[1] $ 'SC2' //Alias da Operação SC2 (Ordem de Produção) ou SH6(Apontamento de produção)
           If PARAMIXB[2] == 1 //Operação 1 - Inclusão
              If SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD == QPK->QPK_OP
                 RecLock("QPK", .f.)
                    QPK->QPK_LOTE = SC2->C2_LOTE
                 MsUnLock()
              Endif
           Endif
        Endif
     Endif
Return