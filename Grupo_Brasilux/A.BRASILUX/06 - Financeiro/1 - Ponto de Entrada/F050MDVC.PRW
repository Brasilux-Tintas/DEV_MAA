#include "protheus.ch"

/*/{Protheus.doc} F050MDVC
//TODO Cálculo da data de vencimento de impostos.
//30/09/2019 - Luís Gustavo - Adequação para release 12.1.25
@author 
@since   /  /   9
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User function F050MDVC()
     Local dNextDay := ParamIxb[1] //data calculada pelo sistema
     Local cIMposto := ParamIxb[2]
     Local dEmissao := ParamIxb[3]
     Local dEmis1   := ParamIxb[4]
     Local dVencRea := ParamIxb[5]
     Local nNextMes := Month(dVencRea)+1 
     Local nAno     := Year(dVencRea)
Local  _cGrpEmp := ALLTRIM(FWGrpCompany())
     u_zcfga01( 'F050MDVC' ) //LGS#2021202 - Gravação de log de utilização da rotina
     If _cGrpEmp <> '11' //Empresas que não são do grupo 11(Tecpolpa).
        If nNextMes == 13
           nNextMes := 1     
           nAno++
        endif

        If At(cImposto,"PIS,CSLL,COFINS") > 0
           dNextDay := STOD(StrZero(nAno,4)+StrZero(nNextMes,2)+"20")//Acho o ultimo dia util do periodo desejado
           dNextday := DataValida(dNextday,.F.)
        Endif
     Endif
Return(dNextDay)
