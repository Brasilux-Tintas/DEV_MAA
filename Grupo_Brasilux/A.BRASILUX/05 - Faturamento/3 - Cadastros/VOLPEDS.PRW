#include "rwmake.ch"
#include "topconn.ch"
#include "protheus.ch"
#include "totvs.ch"
#include 'DIRECTRY.CH' 
#include "TbiConn.ch"

/*
Acertar volumes de pedidos
*/
user function VOLPEDS()
	Local lRet		 	:= .T.
	Local oQtdGanho		:= Nil
	Local cBordero := "      "
	Local cPedido := "      "
	Local lOk		 	:= .F. 

/*
if !u_VldAcesso(funname())
	MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
	return 
endif 
*/

   			DEFINE MSDIALOG oDlg  FROM 000, 000  TO 180, 360 TITLE OemToAnsi("Corrige Volumes")/*"Classificação da quantidade produzida acima do previsto"*/ PIXEL STYLE DS_MODALFRAME 
			cTexto := "Informe o Bordero"
			/*----------------------------
			Texto contido na variável cTexto que será exibida na tela
			"Foi produzida quantidade de <nExcede> ;
			" acima da quantidade prevista pela ordem de produção, que era <SC2->C2_QUANT>.
			" Classifique este excedente conforme abaixo:"
			------------------------------*/
			 
			@ 010, 015 SAY cTexto SIZE 160, 025 OF oDlg COLORS 0, 16777215 PIXEL
			
			@ 040, 015 SAY OemToAnsi("Borderô: ")/*"Ganho de produção:"*/ SIZE 055, 015 OF oDlg COLORS 0, 16777215 PIXEL
			@ 040, 070 MSGET oQtdGanho VAR cBordero Picture PesqPict("SC5","C5_NUM") SIZE 070, 010 OF oDlg PIXEL						

			@ 060, 015 SAY OemToAnsi("Pedido: ")/*"Ganho de produção:"*/ SIZE 055, 015 OF oDlg COLORS 0, 16777215 PIXEL
			@ 060, 070 MSGET oQtdGanho VAR cPedido Picture PesqPict("SC5","C5_NUM") SIZE 070, 010 OF oDlg PIXEL						
		
			DEFINE SBUTTON FROM 075, 086 TYPE 01 OF oDlg ENABLE ACTION (lOK := .T.,oDlgOK(oDlg, lOk, cBordero, cPedido))
			DEFINE SBUTTON FROM 075, 115 TYPE 02 OF oDlg ENABLE ACTION (lOK := .F.,oDlg:End())
			
			oDlg:lEscClose := .F.
			ACTIVATE MSDIALOG oDlg CENTERED	                     
       		//---------------------------	 
            lRet := lOk
            if lRet
            
			EndIf	


RETURN


Static Function oDlgOK(oDlg, lOk, cBordero, cPedido)
Local lRet
if lOk 
	do case
	case empty(cPedido) .and. !empty(cBordero)
      	dbselectarea("SZG")
      	dbsetorder(1)
      	dbgotop()
      	dbseek(xFilial("SZG")+cBordero)
      	do while (SZG->ZG_FILIAL == xFilial("SZG")) .AND. (SZG->ZG_CODIGO = cBordero)
      		U_CorrigeVol(SUBSTR(SZG->ZG_PEDIDO,3,6))
      		dbselectarea("SZG")
      		dbskip()
      	enddo
   case !empty(cPedido)
     	U_CorrigeVol(cPedido)
   endcase
      	
	oDlg:End()
endif
return lRet