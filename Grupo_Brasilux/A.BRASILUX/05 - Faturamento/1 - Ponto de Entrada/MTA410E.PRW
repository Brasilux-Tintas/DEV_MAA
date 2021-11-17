#include 'protheus.ch'
#include 'topconn.ch'
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MTA410E   บAutor  ณ Cleber Orati      บ Data ณ  28/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Executado ap๓s deletar o registro no SC6 (item do pedido deบฑฑ
ฑฑบ          ณ  venda).                                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX TINTAS TษCNICAS LTDA.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
//25/09/2019 - Luํs Gustavo - Adequa็ใo para release 12.1.25
User Function MTA410E()   
     Local cQry1,cTmp
     Local cAliAtu := Alias()

     If FWCodEmp() <> '11' //Empresas que nใo sใo do grupo 11(Tecpolpa).
        If (cNumEmp = "01010101") .OR. (cNumEmp = "01060101") // .and. !empty(M->C5_PEDREPR)
           cTmp := U_NovoCursor()
           cQry1 := "SELECT ESPECIFICOS.ID FROM ESPECIFICOS WITH (NOLOCK) "+;
           "LEFT OUTER JOIN ESPEPEDIDOS WITH (NOLOCK) ON (ESPECIFICOS.ID = ESPEPEDIDOS.ID) AND (SUBSTRING(ESPECIFICOS.PRODUTO,11,2) = ESPEPEDIDOS.EMBAL) "+;
           "WHERE (ESPECIFICOS.EMPRESA = '"+alltrim(cNumEmp)+"') AND (ESPECIFICOS.PRODUTO = '"+SC6->C6_PRODUTO+"') AND (ESPEPEDIDOS.PEDIDO = '"+SC6->C6_NUM+"')"
           TCQuery cQry1 ALIAS (cTmp) NEW
           DbSelectArea(cTmp)  
           dbgotop()
           if !eof()
              cQry1 = "DELETE FROM ESPEPEDIDOS WHERE (EMPRESA = '"+alltrim(cNumEmp)+"') AND (ID = '"+(cTmp)->ID+"') AND (PEDIDO = '"+SC6->C6_NUM+"') AND (EMBAL = '"+Alltrim(SC6->C6_PRODUTO)+"') "
              TCSQLExec(cQry1)
           Endif
           DbSelectArea(cTmp)
           DbCloseArea()
        Endif 
        if !empty(cAliAtu)
           DbSelectArea(cAliAtu)
        endif
     Endif
Return Nil
