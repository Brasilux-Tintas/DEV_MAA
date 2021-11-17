#INCLUDE "rwmake.ch"

////////////////////////////////////////////////////
// Programa...: MS520VLD-PE antes da excl da nf   //
// Autor......: Cleber Orati                      //
// Data.......: 02/11/20                          //
// Descricao..: Verificar se a nota foi dada e    //
// entrada nos depósitos fechados                 //
// Uso........: Brasilux                          // 
//                                                //
////////////////////////////////////////////////////

User Function MS520VLD() 
Local _cArea := Alias()
Local aAreaAnt := U_PegaArea({"SF1","SA1","SA2"})
Local _cGrpEmp,_cFilial,_cFornec,lRet,cCgc,cFilDep,nTamDoc,cDoc

lRet := .t.
_cGrpEmp := alltrim(FWGrpCompany())
_cFilial := alltrim(FWCodFil())


if _cGrpEmp == "01" // somente empresas do grupo Brasilux
    if !(_cFilial == "010106") .and. !(_cFilial == "010107") 
        cCgc := ""
        cFilDep := ""
        IF SF2->F2_TIPO $ "D-B"
            dbselectarea("SA2")
            dbsetorder(1)
            dbseek(xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA)
            if found()
                cCgc := alltrim(SA2->A2_CGC)
            endif 
        ELSE 
            dbselectarea("SA1")
            dbsetorder(1)
            dbseek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)
            if found()
                cCgc := alltrim(SA1->A1_CGC)
            endif 
        ENDIF 
        if !empty(cCgc)
            do case
            case cCgc == "72770878000540" //dep guarulhos
                cFilDep := "010106"
                _cFornec := padr("00354",TamSx3("A2_COD")[1]," ") 
            case cCgc == "72770878000621" //dep matão
                cFilDep := "010107"
                _cFornec := padr("00401",TamSx3("A2_COD")[1]," ") 
            endcase
        endif 
        if !empty(cFilDep)
            cDoc := SF2->F2_DOC
            dbselectarea("SF1")
            dbsetorder(1) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO  
            dbseek(cFilDep+cDoc+SF2->F2_SERIE+_cFornec+SF2->F2_LOJA+SF2->F2_TIPO)
            if found()
                lRet := .f.
            else 
                //Verificar se não cadastrou a nota com 9 dígitos!
                nTamDoc := TamSx3("F1_DOC")[1]
                IF LEN(alltrim(SF2->F2_DOC)) < nTamDoc
                    cDoc := padl(alltrim(SF2->F2_DOC),nTamDoc,"0")
                    dbseek(cFilDep+cDoc+SF2->F2_SERIE+_cFornec+SF2->F2_LOJA+SF2->F2_TIPO)
                    if found()
                        lRet := .f.
                    endif 
                ENDIF 
            endif 
        endif 
    endif 
    if !lRet
        MessageBox( "Exclua primeiro a Entrada da NF "+SF2->F2_DOC+" no DEPÓSITO FECHADO!", "Atenção", 48 )
    endif 
endif 


U_VoltaArea(aAreaAnt)
if !empty(_cArea)
   dbSelectArea(_cArea)
endif 
Return(lRet)    
