#include "rwmake.ch"        
/*Autor: Cleber Orati Domingues
Data: 27/03/02
Ponto de Entrada para setar registro de deleção p/ envio a representantes
Uso: Brasilux/Matriz e Brasitec.
*/
//30/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function MTA010E()
     Local nArea, lMandarBrasRepres
nArea = Alias()

If ALLTRIM(FWGrpCompany()) == '01' //Empresas que  são do grupo 01

   // Enviar alteracoes p/ representante
   lMandarBrasRepres = .F.
   If (cNumEmp == "01010101") .OR. (cNumEmp == "01060101")
      If SB1->B1_TIPO == 'PA'
         lMandarBrasRepres = .t.
      Else
         dbselectarea("SX5")
         If DBSEEK(xFilial("SX5")+"Z3"+ALLTRIM(SB1->B1_COD))
            lMandarBrasRepres = .t.
         Endif
      Endif
   Endif 
   IF lMandarBrasRepres
      U_EnviaRec("SB1",SB1->B1_COD,.t.)
   ENDIF
Endif
If (SB1->(FieldPos("B1_X_SIM3G")) > 0) 
           IF SB1->B1_X_SIM3G = "S"
              reclock("SB1",.F.)
                 SB1->B1_X_SIM3G := "N"
                 SB1->B1_X_DTATU := DATE()
                 SB1->B1_X_EXPO  := "N"
              msunlock()
           ENDIF
endif
dbselectarea(nArea)
Return  
