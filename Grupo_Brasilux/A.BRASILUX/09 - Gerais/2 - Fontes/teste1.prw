#include "protheus.ch"
#include 'tbiconn.ch'                                                       
#include 'error.ch'                                                
#include 'topconn.ch'                          
#INCLUDE "RWMAKE.CH"

user function teste1()
Local _cAuxMens := "Teste mensagem Console"
//FwLogMSG( "INFO", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
U_ESTX06(2)

//FwLogMsg("INFO", , "REST", FunName(), "", "01", "Teste Mensagem Console", 0,0,{})

  
return(.t.)
