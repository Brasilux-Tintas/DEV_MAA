if!#INCLUDE "TOTVS.CH"
#include "topconn.ch"

/*/{Protheus.doc} A100DEL
Verificar se a nota foi dada entrada nos depósitos fechados
@type function Ponto de Entrada
@version 1.00
@author Cleber Orati
@since 02/11/20
@return Logical, permite ou nao a exclusão
/*/

User Function A100DEL()
    Local aArea := GetArea()
    Local _cArea := Alias()
    Local aAreaAnt := U_PegaArea({"SF1"})
    Local cFilDep
    Local cDoc
    Local nReg
    Local _cPed
    Local cMens
    Local lRet := .T.
    Local _cGrpEmp := alltrim(FWGrpCompany())
    Local _cFilial := alltrim(FWCodFil())

    U_ZCFGA01( 'A100DEL' ) //LGS#2021118 - Gravação de log de utilização da rotina

    If _cGrpEmp == "01" // somente empresas do grupo Brasilux
        If .NOT. (_cFilial $ "010106/010107/010108" )
            cMens := ""
            _cPed := "" //Pedido de remessa simbólica
            nReg := SF1->(RECNO())
            cDoc := SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_TIPO
            SF1->(dbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO

            cFilDep := "010106"
            If SF1->(dbSeek(cFilDep+cDoc))
                lRet := .F.
            else
                cFilDep := "010107"
                If SF1->(dbSeek(cFilDep+cDoc))
                    lRet := .F.
                End
                cFilDep := "010108"
                If SF1->(dbSeek(cFilDep+cDoc))
                    lRet := .F.
                End
            End
            SF1->(dbGoto(nReg))
            If .NOT.lRet
                cMens := "Exclua primeiro a Entrada da NF no DEPÓSITO FECHADO!"
            else //VerIficar se tem pedido de saída de remessa simbólica
                cTcq := U_NovoCursor()

                /*
                cQuery := "SELECT DISTINCT SC6.C6_NUM AS PEDIDO "+;
                    "FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK) "+;
                    "LEFT OUTER JOIN "+RetSqlName("SF1")+" SF1 WITH (NOLOCK) ON (SF1.D_E_L_E_T_ <> '*') AND (F1_FILIAL = D1_FILIAL) AND (F1_DOC = D1_DOC) AND (F1_SERIE = D1_SERIE) AND (F1_FORNECE = D1_FORNECE) AND (F1_LOJA = D1_LOJA) AND (F1_TIPO = D1_TIPO) "+;
                    "LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON (SC6.D_E_L_E_T_ <> '*') AND (C6_XREGD1D = SD1.R_E_C_N_O_) "+;
                    "WHERE (SD1.D1_FILIAL = '"+SF1->F1_FILIAL+"') AND (D1_DOC = '"+SF1->F1_DOC+"') AND (D1_SERIE = '"+SF1->F1_SERIE+"') AND (D1_FORNECE = '"+SF1->F1_FORNECE+"') AND "+;
                    "(D1_LOJA = '"+SF1->F1_LOJA+"') AND (C6_XREGD1D > 0)"
                TCQuery cQuery NEW ALIAS (cTcq)
                dbselectarea(cTcq)
                dbgotop()
                */
                BEGINSQL ALIAS cTcq
                    SELECT
                        DISTINCT SC6.C6_NUM AS PEDIDO
                    FROM
                        %Table:SD1% SD1
                        LEFT OUTER JOIN %Table:SF1% SF1 ON SF1.%NotDel%
                        AND SF1.F1_FILIAL = SD1.D1_FILIAL
                        AND SF1.F1_DOC = SD1.D1_DOC
                        AND SF1.F1_SERIE = SD1.D1_SERIE
                        AND SF1.F1_FORNECE = SD1.D1_FORNECE
                        AND SF1.F1_LOJA = SD1.D1_LOJA
                        AND SF1.F1_TIPO = SD1.D1_TIPO
                        LEFT OUTER JOIN %Table:SC6% SC6 ON SC6.%NotDel%
                        AND SC6.C6_XREGD1D = SD1.R_E_C_N_O_
                        AND SC6.C6_XREGD1D > 0
                    WHERE
                        SD1.%NotDel%
                        AND SD1.D1_FILIAL = %Exp:SF1->F1_FILIAL%
                        AND SD1.D1_DOC = %Exp:SF1->F1_DOC%
                        AND SD1.D1_SERIE = %Exp:SF1->F1_SERIE%
                        AND SD1.D1_FORNECE = %Exp:SF1->F1_FORNECE%
                        AND SD1.D1_LOJA = %Exp:SF1->F1_LOJA%
                EndSQl

                If .NOT. cTCQ->(eof()) .and. .NOT. CTCQ->(bof())
                    _cPed := alltrim((cTcq)->PEDIDO)
                End

                If .NOT. empty(_cPed)
                    lRet := .f.
                    cMens := "Exclua antes o pedido de Remessa Simbólica nro "+_cPed
                End

                CTCQ->(dbCloseArea())
            End
        End

        If .NOT. lRet
            FWAlertError(cMens, "Atenção")
        End

    End

    U_VoltaArea(aAreaAnt)

    If  .NOT. empty(_cArea)
        dbSelectArea(_cArea)
    End

    RestArea(aArea)
    
Return(lRet)
