#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#include 'tbiconn.ch'
#include 'topconn.ch'

/////////////////////////////////////////////////////////
// Programa...: DANFEMAIL                               //
// Autor......:                                        //
// Data.......: 22/06/12                               //
// Descricao..: Enviar Danfes por e-mail               //
// Uso........: Brasilux                               // 
/////////////////////////////////////////////////////////

User Function DANFEMAIL()   

if messagebox("Processa envio de Danfes por e-mail?","Confirme!",4+32) == 6
	U_DANFEAUTO(.F.,"","","")
endif 

Return      

/*
@ 150,1 TO 380,380 DIALOG _oEnvDanfe TITLE "      ENVIAR DANFES POR E-MAIL    " 
@ 10,018 Say " Este programa ira enviar os Danfes para os e-mails dos  " SIZE 200,200 
@ 18,018 Say " clientes.                                               " SIZE 200,200
@ 90,110 BMPBUTTON TYPE 01 ACTION U_DANFEAUTO(.F.,"","","")
@ 90,140 BMPBUTTON TYPE 02 ACTION Close(_oEnvDanfe)

Activate Dialog _oEnvDanfe Centered
*/


Static Function Envdanfe(_oDlg)
//Processa({|| Envdanfe() },"Processando...")
U_DANFEAUTO(.F.,"","","")
	
Return (.F.)

