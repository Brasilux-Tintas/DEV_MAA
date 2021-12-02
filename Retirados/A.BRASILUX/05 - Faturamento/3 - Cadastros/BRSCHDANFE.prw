#include 'tbiconn.ch'
#include 'error.ch'
#include 'topconn.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRSCHPED บAutor  ณ Cleber Orati Domingues   บ Data ณ  16/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Chamada de emissใo automatica de danfes por email          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Brasilux Tintas T้cnicas Ltda.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function BRSCHDANFE

	Local _cAuxMens :=""
	
	/* DESABILITADO EM FUNวรO DA RELEASE 12.1.25		
	ConOut("*****************************************")
	ConOut("*  BRSCHDANFE - DANFES POR EMAIL        *")
	ConOut("*****************************************")
	U_DANFEAUTO(.T.,"","","") 
    ConOut("-- FIM DANFES POR EMAIL")
    */

    _cAuxMens := Repl( "-", 80 )              			     + CHR( 13 ) + CHR( 10 )
    _cAuxMens += "*****************************************" + CHR( 13 ) + CHR( 10 )
    _cAuxMens += "*  BRSCHDANFE - DANFES POR EMAIL        *" + CHR( 13 ) + CHR( 10 )
    _cAuxMens += "*****************************************" + CHR( 13 ) + CHR( 10 )
    _cAuxMens += "Inicio: " + Time() + CHR( 13 ) + CHR( 10 )
	FwLogMSG( "INFO", , 'SIGAFAT', FunName(), '', '01', _cAuxMens, 0 )
	U_DANFEAUTO(.T.,"","","") 
    _cAuxMens := "-- FIM DANFES POR EMAIL --"
    FwLogMSG( "INFO", , 'SIGAFAT', FunName(), '', '01', _cAuxMens, 0 )
                
                
Return(Nil)
               
