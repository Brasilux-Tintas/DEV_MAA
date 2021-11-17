#include "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ M030EXC  ºAutor  ³ Cleber O. Dominguesº Data ³  26/03/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Após confirmação de exclusão de cliente para enviar dados  º±±
±±º          ³ para representante.                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//25/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function M030EXC()
     Local aArea := GetArea()
     Local lBloqueado,_cGrpEmp

_cGrpEmp := ALLTRIM(FWGrpCompany())
     If _cGrpEmp == '01' //Empresas que não são do grupo 11(Tecpolpa).
        U_EnviaRec("SA1", SA1->A1_COD, .T.,SA1->A1_VEND)
     Endif     
      
      dbselectarea("SA1")
     IF (SA1->(FieldPos("A1_X_SIM3G")) > 0) 
           IF SA1->A1_X_SIM3G = "S"
              lBloqueado = U_EstaBloqueado("SA1", RecNo())
              If !lBloqueado
                 RecLock("SA1", .F.)
              Endif
              SA1->A1_X_SIM3G := "N"
              SA1->A1_X_DTATU := DATE()
              SA1->A1_X_EXPO  := "N"
              If !lBloqueado
                 MsUnLock()
              Endif
           ENDIF
     ENDIF 


     Restarea(aArea)
Return(.t.)
