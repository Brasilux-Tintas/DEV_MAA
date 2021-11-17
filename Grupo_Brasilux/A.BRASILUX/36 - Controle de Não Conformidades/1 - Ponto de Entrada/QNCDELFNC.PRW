
#include "topconn.ch"

/*/{Protheus.doc} QNCDELFNC
//TODO Para executar ações e/ou validar a exclusão da FNC.
//30/09/2019 - Luís Gustavo - Adequação para release 12.1.25
@author Luís Gustavo
@since   /  /    
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function QNCDELFNC()
     Local lRet  := .T.
     Local cQry  := ""
     Local aArea := GetArea()
     
     If FWCodEmp() <> '11' //Empresas que não são do grupo 11(Tecpolpa).
        cQry := "SELECT SZQ.ZQ_NUM "
        cQry += "FROM "+RetSqlName("SZQ")+" SZQ "
        cQry += "WHERE SZQ.ZQ_FILIAL  = '"+xFilial("SZQ")+"' "
        cQry += "  AND SZQ.D_E_L_E_T_ = '' "
        cQry += "  AND SZQ.ZQ_FNC     = '"+QI2->QI2_FNC+"' "
        TCQuery cQry ALIAS "TCQ" NEW
        DbSelectArea("TCQ")
        cNumSac := TCQ->ZQ_NUM
        DbSelectArea("TCQ")
        DbCloseArea()
        If !Empty(cNumSac)
           cQry := "UPDATE "+RetSqlName("SZQ")+" SET ZQ_FNC = '' WHERE ZQ_FILIAL = '"+xFilial("SZQ")+"' AND D_E_L_E_T_ = '' AND ZQ_NUM = '"+cNumSac+"' "
           If MsgYesNo("Atenção, essa opção irá tirar a ficha de não conformidade do SAC relacionado. Continua?")
              xxx := TCSQLExec(cQry)
           Else
              lRet := .f.   
           Endif
        Endif
        DbSelectArea(aArea[1])
     Endif
Return(lRet)