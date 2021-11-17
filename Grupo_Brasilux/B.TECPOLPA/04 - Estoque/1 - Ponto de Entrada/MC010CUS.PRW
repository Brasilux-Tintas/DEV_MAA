//============================================================================//
// Autor    | Dyego Figueiredo / www.chaus.com.br                             //
//----------------------------------------------------------------------------//
// Data     | 14/06/2015                                                      //
//----------------------------------------------------------------------------//
// Descricao| Altera o valor do custo unitï¿½rio de cada componente  comprado //
//          | na estrutura         											  //
//----------------------------------------------------------------------------//
// Objetivo | Utilizar o campo B1_XUPRC no calculo da formacao de preco, ao   // 
//          | inves de utilizar o campo padrao B1_UPRC.					      //
//----------------------------------------------------------------------------//
// Programa  |																  //
// Fonte	 | MATC010X.PRX.PRW												  //
//----------------------------------------------------------------------------//
// Partida  | Menu de programa                                                //
//============================================================================//
//26/09/2019 - Luís Gustavo - Adequação para release 12.1.25
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH" 

User Function MC010CUS()
Local cProd    := PARAMIXB[1]
Local nCusPad  := PARAMIXB[2]
Local nRet     := 0
Local _cGrpEmp := alltrim(FWGrpCompany())
Local _cFilial := alltrim(FWCodFil())
Local cHabXPrc := ""

if empty(_cGrpEmp)
	_cGrpEmp := "01"
endif 
nRet := nCusPad 

do case 
case _cGrpEmp == '11' //Empresas que são do grupo 11(Tecpolpa).
//Cleber (24/06/21) ->Retirada customização Chaus, deixando padrão
 /*
        cHabXPrc := GETMV("MV_XULPRC")
        If AllTrim(cHabXPrc) == '1' .AND. cProd == SB1->B1_COD .AND. CCUSTO == "ULTPRECO"        
           nRet :=  SB1->B1_XUPRC
        ElseIf AllTrim(cHabXPrc) == '2' .AND. cProd == SB1->B1_COD .AND. CCUSTO == "ULTPRECO"        
               nRet :=  SB1->B1_XMAXPRC
        ElseIf AllTrim(cHabXPrc) == '3' .AND. cProd == SB1->B1_COD .AND. CCUSTO == "ULTPRECO"        
               nRet :=  SB1->B1_XPRCTAB
        Else
           nRet := nCusPad	
        Endif
*/
case _cGrpEmp == '01'
   //LGS#20200319 - Ajuste para que carregue o ultimo preço do produto. Chamado - 016254
   if substr(_cFilial,1,2) $ "01_06"
      nRet := SB1->B1_UPRC
   endif 
endcase 

Return(nRet)
