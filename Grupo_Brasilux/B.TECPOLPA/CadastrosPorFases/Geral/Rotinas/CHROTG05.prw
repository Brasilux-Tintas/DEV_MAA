#INCLUDE "PROTHEUS.CH"  
#include "Rwmake.ch"
#INCLUDE "FWMVCDEF.CH"  
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"



/**	 ValUsrRo
***    Funcao contida no modo de edicao dos campos das tabelas  SA1, SA2 e SB1
***    para habilitar ou desabilitar a edicao dos campos conforme as 
***    regras definidas na tabela SZP
***    Dyego Figueiredo - Chaus - 10/08/2015
***/
User Function CHROTG05(tipo, _campo)
  
                                    
Local aAreaAtu	:= GetArea()
Local lRet := .F.
                        
//IF .T.
//	return .t.
//Endif

//verifica se o cliente possui acesso ilimitado                             
If 	(tipo == "P" .AND. Alltrim(RetCodUsr() ) $ AllTrim(getMv("CF_USILMTP")) ) .OR. ;
	(tipo == "F" .AND. Alltrim(RetCodUsr() ) $ AllTrim(getMv("CF_USILMTF")) ) .OR. ;
	(tipo == "C" .AND. Alltrim(RetCodUsr() ) $ AllTrim(getMv("CF_USILMTC")) ) 

	Return .T.
Endif


//verifica se a rotina esta habilitada                             
If 	(tipo == "P" .AND.  ! getMv("CF_ATIVARP") ) .OR. ;
	(tipo == "F" .AND.  ! getMv("CF_ATIVARF") ) .OR. ;
	(tipo == "C" .AND.  ! getMv("CF_ATIVARC") ) 

	Return .T.
Endif


//If tipo == "C" .And. /*getMv("MV_XHABCH1")  .And. */ (Type("_CliCpos") != "U" .And. AllTrim(_campo) $ _CliCpos) /*.Or. Inclui*/ .Or. Empty(_campo) //se nao tiver regra nao bloqueia
//	lRet := .T.
//Endif  

If Type("_DisCpsP") != "U"
	If   tipo == "P" .And. /*getMv("MV_XHABCH1")  .And. */  AllTrim(_campo) $ _DisCpsP /*.Or. Inclui*/ .Or. Empty(_campo) .or. Substr(AllTrim(_DisCpsP),1,1) == '*'  //se nao tiver regra nao bloqueia
		lRet := .T.
	Endif 
Endif

If Type("_DisCpsF") != "U"

	If tipo == "F" .And. /*getMv("MV_XHABCH1")  .And. */  AllTrim(_campo) $ _DisCpsF /*.Or. Inclui*/ .Or. Empty(_campo) .or.  Substr(AllTrim(_DisCpsF),1,1) == '*' //se nao tiver regra nao bloqueia
		lRet := .T.
	Endif 

Endif


If Type("_DisCpsC") != "U"

	If tipo == "C" .And. /*getMv("MV_XHABCH1")  .And. */  AllTrim(_campo) $ _DisCpsC /*.Or. Inclui*/ .Or. Empty(_campo) .or.  Substr(AllTrim(_DisCpsC),1,1) == '*' //se nao tiver regra nao bloqueia
		lRet := .T.
	Endif 

Endif

RestArea( aAreaAtu )

Return  lRet 

                   
	