#Include "Protheus.ch"
 
/*---------------------------------------------------------------------------------*
 | P.E.:  MT121BRW                                                                 |
 | Desc:  Adição de opções no Ações Relacionadas do Pedidos de Compra              |
 | Link:  http://tdn.totvs.com/pages/releaseview.action?pageId=51249528            |
 *---------------------------------------------------------------------------------*/
 
User Function MT121BRW()
    aAdd(aRotina, {"ImpR ALT", "U_BRCOM012", 0, 7, 0, Nil})
Return
