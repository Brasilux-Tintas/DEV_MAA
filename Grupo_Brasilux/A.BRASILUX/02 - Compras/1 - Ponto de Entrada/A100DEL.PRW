#INCLUDE "rwmake.ch"
#include "topconn.ch"

////////////////////////////////////////////////////
// Programa...: A100DEL-PE antes da excl da nf en //
// Autor......: Cleber Orati                      //
// Data.......: 02/11/20                          //
// Descricao..: Verificar se a nota foi dada e    //
// entrada nos depósitos fechados                 //
// Uso........: Brasilux                          // 
//                                                //
////////////////////////////////////////////////////

User Function A100DEL() 
Local _cArea := Alias()
Local aAreaAnt := U_PegaArea({"SF1"})
Local _cGrpEmp,_cFilial,lRet,cFilDep,cDoc,nReg,_cPed,cMens

lRet := .t.
_cGrpEmp := alltrim(FWGrpCompany())
_cFilial := alltrim(FWCodFil())


if _cGrpEmp == "01" // somente empresas do grupo Brasilux
    if !(_cFilial == "010106") .and. !(_cFilial == "010107")
        cMens := ""
        _cPed := "" //Pedido de remessa simbólica
        dbselectarea("SF1")
        nReg := recno()
        cDoc := SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_TIPO
        dbsetorder(1) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO  
        cFilDep := "010106"
        dbseek(cFilDep+cDoc)
        if found()
            lRet := .f.
        else 
            cFilDep := "010107"
            dbseek(cFilDep+cDoc)
            if found()
                lRet := .f.
            endif 
        endif 
        goto nReg
        if !lRet    
            cMens := "Exclua primeiro a Entrada da NF no DEPÓSITO FECHADO!"
        else //Verificar se tem pedido de saída de remessa simbólica
            cTcq := U_NovoCursor()
            cQuery := "SELECT DISTINCT SC6.C6_NUM AS PEDIDO "+;
            "FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK) "+;
            "LEFT OUTER JOIN "+RetSqlName("SF1")+" SF1 WITH (NOLOCK) ON (SF1.D_E_L_E_T_ <> '*') AND (F1_FILIAL = D1_FILIAL) AND (F1_DOC = D1_DOC) AND (F1_SERIE = D1_SERIE) AND (F1_FORNECE = D1_FORNECE) AND (F1_LOJA = D1_LOJA) AND (F1_TIPO = D1_TIPO) "+;
            "LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON (SC6.D_E_L_E_T_ <> '*') AND (C6_XREGD1D = SD1.R_E_C_N_O_) "+;
            "WHERE (SD1.D1_FILIAL = '"+SF1->F1_FILIAL+"') AND (D1_DOC = '"+SF1->F1_DOC+"') AND (D1_SERIE = '"+SF1->F1_SERIE+"') AND (D1_FORNECE = '"+SF1->F1_FORNECE+"') AND "+;
            "(D1_LOJA = '"+SF1->F1_LOJA+"') AND (C6_XREGD1D > 0)"
            TCQuery cQuery NEW ALIAS (cTcq)
        	dbselectarea(cTcq)
	        dbgotop()
            IF !eof() .and. !bof()
                _cPed := alltrim((cTcq)->PEDIDO)
            ENDIF 
            if !empty(_cPed)
                lRet := .f.
                cMens := "Exclua antes o pedido de Remessa Simbólica nro "+_cPed
            endif 
            dbselectarea(cTcq)
	        dbCloseArea()
        endif 
    endif 
    if !lRet
        MessageBox( cMens, "Atenção", 48 )
    endif 
endif 


U_VoltaArea(aAreaAnt)
if !empty(_cArea)
   dbSelectArea(_cArea)
endif 
Return(lRet)    
