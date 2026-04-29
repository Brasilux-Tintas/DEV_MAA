#include "rwmake.ch"        
/* Autor: Cleber Orati Domingues
Data: 26/04/2004
Filtrar At. Preços de Tabela p/ apenas pessoas autorizadas.
Obs.: Deve-se chamar esse programa no menu de cad. de estruturas ao invés 
do MATA420
*/


User Function MATA420()  
Local cAuxUser,lAutoriz
u_zcfga01( 'MATA420' ) //LGS#2021118 - Gravação de log de utilização da rotina
lAutoriz := .t.

//LGS#12/07/2023 - Ajuste dos parametros da função PSWAdmin
//If PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) != 0
If PSWADMIN( , , RetCodUsr() ) != 0
	cAuxUser := UPPER(alltrim(cUserName))
	If cAuxUser $ UPPER(GETMV("MV_ALTTABP"))
		MATA420()
	else	
		lAutoriz := .f.
		MsgBox("Acesso Nao Autorizado!!!","Atenção","STOP")
	endif              
endif
if lAutoriz
	MATA420()
endif 
Return

