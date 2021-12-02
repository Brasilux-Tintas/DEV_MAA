#include 'TOTVS.CH'
#include "topconn.ch"

/*/{Protheus.doc} QP010DEL
//TODO Descrição auto-gerada.
//30/09/2019 - Luís Gustavo - Adequação para release 12.1.25
@author gustavosouza
@since 30/09/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function QP010DEL()
     Local cAreAtu := Alias()
     Local cIndAtu := IndexOrd()
     Local cRecAtu := RecNo()
     Local cProdut := PARAMIXB[1]
     Local cRevAtu := PARAMIXB[2]
     Local cRotAtu := PARAMIXB[3]
     Local cRevAnt := Iif(Val(PARAMIXB[2]) - 1 <= 0,StrZero(0,2), StrZero(Val(PARAMIXB[2]) - 1,2) )
     Local cQry1   := ""
          u_zcfga01( 'QP010DEL' ) //LGS#2021201 - Gravação de log de utilização da rotina
     If FWCodEmp() <> '11' //Empresas que não são do grupo 11(Tecpolpa).
        cQry1 += "SELECT COUNT(*) AS QTDREC "
        cQry1 += "FROM "+RetSqlName("QP6")+" QP6 "
        cQry1 += "WHERE QP6.QP6_FILIAL = '"+xFilial("QP6")+"'"
        cQry1 += "  AND QP6.D_E_L_E_T_ = '' "
        cQry1 += "  AND QP6.QP6_PRODUT = '"+cProdut+"' "
        cQry1 += "  AND QP6.QP6_REVI   = '"+cRevAnt+"' "
        TCQuery cQry1 NEW ALIAS "TCQ"
     
        DbSelectArea("TCQ")
        If TCQ->QTDREC > 0
           If cNumEmp == '01010101'
              cQry1 := ""
              cQry1 += "UPDATE "+RetSqlName("SG2")+" "
              cQry1 += "SET G2_REVIPRD = '"+cRevAnt+"' "
              cQry1 += "WHERE G2_FILIAL  = '"+xFilial("SG2")+"' "
              cQry1 += "  AND D_E_L_E_T_ = '' "
              cQry1 += "  AND G2_CODIGO  = '"+cRotAtu+"' "
              cQry1 += "  AND G2_PRODUTO = '"+cProdut+"' "
              cQry1 += "  AND G2_REVIPRD = '"+cRevAtu+"' "
              TCSQLEXEC(cQry1)
           Endif
        Endif
        DbSelectArea("TCQ")
        DbCloseArea()
        DbSelectArea(cAreAtu)
        DbSetOrder(cIndAtu)
        DbGoTo(cRecAtu)
     Endif
Return
