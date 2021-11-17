#include "rwmake.ch"
#include "topconn.ch"

//////////////////////////////////////////////////////////
// Programa...: FA430FIG-PE antes de gravar registro FIG//
// Autor......: Cleber Orati                            //
// Data.......: 12/03/21                                //
// Descricao..: Fornecedor emite boleto por CNPJ dife-  //
// rente da nf original. Tentativa de identificar FIG   //
// com o CNPJ da NF para que se possa conciliar com SE2 //
// posteriormente no FINA260                            // 
// Uso........: Todas as Empresas                       // 
//                                                      //
//////////////////////////////////////////////////////////

User Function FA430FIG           
Local cCNPJ := alltrim(ParamIxb[1])
Local cArea := Alias()
Local cAuxCgc,cQuery,_cTitulo,cValor,cAuxQuery,cAuxTit,cCnpjOrig,nCont,nTam,nQtde,nPos

_cTitulo := U_SoDig(cNumTit)
nPos := iif(len(cCNPJ) == 15,2,1)
cAuxCgc := substr(cCNPJ,nPos,8)
nQtde := 0
dbselectarea("SA2")
dbSetOrder(3)
MsSeek(xFilial("SA2")+cCNPJ)
if !found() //Não encontrado CNPJ do arquivo, tentar encontrar cnpj pela raiz
    MsSeek(xFilial("SA2")+cAuxCgc,.t.)
    if !eof() .and. !bof() 
        if substr(SA2->A2_CGC,1,8) == cAuxCgc
            cCNPJ := SA2->A2_CGC
        endif
    endif 
endif 
cCnpjOrig := cCNPJ
cValor := alltrim(StrTran(TransForm(nValPgto ,'@E 9999999.9999'), ",", "."))
nQtde := 0
IF !eof() .and. !bof() .and. (SA2->A2_CGC = cCNPJ)
    cQuery := "SELECT COUNT(R_E_C_N_O_) AS QTDE "+;
    "FROM "+RetSqlName("SE2")+" SE2 "+;
    "WHERE (SE2.D_E_L_E_T_ <> '*') AND (E2_FILIAL = '"+xFilial("SE2")+"') AND (E2_FORNECE = '"+SA2->A2_COD+"') AND (E2_LOJA = '"+SA2->A2_LOJA+"') "+;
    "AND (E2_VALOR = "+cValor+") AND ((E2_VENCTO = '"+dtos(dBaixa)+"') OR (E2_VENCREA = '"+dtos(dBaixa)+"')) AND (E2_TIPO <> 'PA') "+;
    "AND (E2_NUM = '"+_cTitulo+"')"
    nQtde := QuantosReg(cQuery)
ENDIF 
dbselectarea("SA2")
MsSeek(xFilial("SA2")+cAuxCgc,.t.)
do while (nQtde == 0) .and. !eof() .and. (substr(SA2->A2_CGC,1,8) == cAuxCgc)
    cCNPJ := SA2->A2_CGC
    cAuxQuery := "SELECT COUNT(R_E_C_N_O_) AS QTDE,MAX(R_E_C_N_O_) AS REG "+;
    "FROM "+RetSqlName("SE2")+" SE2 "+;
    "WHERE (SE2.D_E_L_E_T_ <> '*') AND (E2_FILIAL = '"+xFilial("SE2")+"') AND (E2_FORNECE = '"+SA2->A2_COD+"') AND (E2_LOJA = '"+SA2->A2_LOJA+"') "+;
    "AND (E2_VALOR = "+cValor+") AND ((E2_VENCTO = '"+dtos(dBaixa)+"') OR (E2_VENCREA = '"+dtos(dBaixa)+"')) AND (E2_TIPO <> 'PA') "
    cAuxTit := _cTitulo+"."
    do while (nQtde == 0) .and. (len(cAuxTit) > 6)
        nTam := len(cAuxTit)
        cAuxTit := substr(cAuxTit,1,nTam-1)
        cQuery := cAuxQuery+"AND (E2_NUM LIKE '%"+cAuxTit+"%')"
        nQtde := QuantosReg(cQuery)
    enddo 
    IF nQtde > 0
        exit 
    ENDIF 
    cAuxTit := "."+_cTitulo
    do while (nQtde == 0) .and. (len(cAuxTit) > 6)
        nTam := len(cAuxTit)
        cAuxTit := substr(cAuxTit,2,nTam-1)
        cQuery := cAuxQuery+"AND (E2_NUM LIKE '%"+cAuxTit+"%')"
        nQtde := QuantosReg(cQuery)
    enddo 
    IF nQtde > 0
        exit 
    ENDIF 

    cAuxTit := _cTitulo
    nCont = 0
    do while (nQtde == 0) .and. (len(cAuxTit) > 5)
        nCont++ 
        nTam := len(_cTitulo)
        cAuxTit := substr(_cTitulo,nCont+1,nTam-nCont)
        cAuxTit := cAuxTit+"."
        do while (nQtde == 0) .and. (len(cAuxTit) > 5)
            nTam := len(cAuxTit)
            cAuxTit := substr(cAuxTit,1,nTam-1)
            cQuery := cAuxQuery+"AND (E2_NUM LIKE '%"+cAuxTit+"%')"
            nQtde := QuantosReg(cQuery)
        enddo 
        IF nQtde > 0
            exit 
        ENDIF 
    enddo 
    IF nQtde > 0
        exit 
    ENDIF 

    dbselectarea("SA2")
    dbskip()
enddo

if nQtde == 0
    cCNPJ := cCnpjOrig
endif 

if !empty(cCNPJ)
    dbselectarea("SA2")
    MsSeek(xFilial("SA2")+cCNPJ)
endif 

If !empty(cArea)
	DbSelectArea(cArea)
Endif
Return cCNPJ

Static Function QuantosReg(cQuery)
Local cTmp,nQtdeReg
    cTmp := U_NovoCursor()
	TCQuery cQuery NEW ALIAS (cTmp) 
	dbselectarea(cTmp)
    nQtdeReg := (cTmp)->QTDE
    dbclosearea()  
return(nQtdeReg)

//Tirar zeros à esquerda
Static Function TiraZero(_cTit)
Local _cRet,i,cDig
_cRet := _cTit
for i := 1 to len(_cTit)
    cDig := substr(_cTit,i,1)
    if cDig != "0"
        _cRet := substr(_cTit,i,len(_cTit)-i+1)
        exit 
    endif 
next 
return(_cRet)
