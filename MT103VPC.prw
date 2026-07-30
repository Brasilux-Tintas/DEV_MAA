
/*/{Protheus.doc} MT103VPC
Verifica se ao acionar F5 ou F6 para importação do pedido se o mesmo está liberado
@type function Ponto de Entrada
@version  1.00
@author marioantonaccio
@since 14/07/2026
@return logical, se o item está liberado
/*/
User Function MT103VPC()
    Local cTipo  := "PC" as character
    Local cWhere := ""   as character
    Local lRet   := .T.  as logical

    SC7->(dbSetOrder(1))
    If SC7->(dbSeek(xFilial("SC7")+aCols[nx,nPosPc]+aCols[nx,nPosItPc]))
        If (SC7->C7_CONAPRO $ 'L ')  // Se Esta Liberado , verifico na SCR por via das duvidas
            cWhere += " AND CR_NUM = '"+aCols[nx,nPosPc]+"' "
            cWhere += " AND CR_TIPO = '"+cTipo+"' "
            cWhere += " AND CR_STATUS ='02'"  //Pedido Liberado

            cWhere := '%'+cWhere+'%'

            BeginSql Alias "TMPSCR"
                SELECT
                    COUNT(*) AS NREG
                FROM
                    %table:SCR% SCR
                WHERE
                    SCR.%notDel%
                    AND SCR.CR_FILIAL = %xFilial:SCR% 
                    %Exp:cWhere%
            EndSql

            lRet := (TMPSCR->NREG == 0)
            TMPSCR->(dbCloseArea())
        End
    End
Return (lRet)
