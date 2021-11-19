#INCLUDE 'PROTHEUS.CH'                                          
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#include "ap5mail.ch"                                                     	

/*/{Protheus.doc} MT241LOK
//TODO Descrição auto-gerada.
@author 
@since 
@version 1.0
@return ${return}, ${return_description}

@type function
25/09/2019 - Luís Gustavo - Adequação para release 12.1.25
/*/
User function MT241LOK()
     //--------Ponto de entrada pega troca de aCols, problema na hora de confirmar, o mesmo está sendo chamado mais tres vezes. 
     Local cValida                                                                        
     Local n := ParamIxb[1]
     Local cArea := Alias()
     Local aArea := U_PegaArea({"SB1"})
     u_zcfga01( 'MT241LOK' ) //LGS#2021119 - Gravação de log de utilização da rotina
     If FWCodEmp() <> '11' //Empresas que não são do grupo 11(Tecpolpa).
        DbSelectArea("SB1")
        DbSetorder(1)
        DbSeek(xFilial("SB1")+(aCols[n][1]))
        If found()
           cValida := Posicione("SB1", 1, xFilial("SB1")+(aCols[n][1]),"B1_TIPO")                                                                        
        EndIf
        If cValida == "PA" 
           If !((PSWADMIN( cUsername, SubStr(cUsuario, 6, 1),RetCodUsr()) = 0) .OR. (PSWADMIN( cUsername, SubStr(cUsuario, 6, 1),RetCodUsr()) = 4) ) 
              Messagebox("Não é permitido inclusão/baixa de produtos acabados por esta rotina!!!","Atenção...",48)
              Return .F.
           Endif
        EndIf                        
        U_VoltaArea(aArea)
        If !empty(cArea)
           DbSelectArea(cArea)
        Endif 
     Endif
Return         
