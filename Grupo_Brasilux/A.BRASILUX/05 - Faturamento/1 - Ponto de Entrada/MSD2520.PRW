#INCLUDE "rwmake.ch"

////////////////////////////////////////////////////
// Programa...: MSD25202-PE antes da excl do item //
// Autor......: Cleber Orati                      //
// Data.......: 16/07/15                          //
// Descricao..: Marcar lctos p/ Dep. Fechado      //
// Uso........: Brasilux/Deposito                 // 
//                                                //
// Data...........: 25/09/2019                    //
// Alteração......: Luís Gustavo                  //
// Ocorrência.....: Adequação para release 12.1.25//
//                                                // 
// Data...........: 19/06/2024                    //
// Alteração......: André Maester                 //
// Ocorrência.....: Adequação Filial 010108 - ARA //
////////////////////////////////////////////////////

User Function MSD2520() 
   
   Local _cArea := Alias()
   Local nRegD2

   u_zcfga01( 'MSD2520' ) //LGS#2021201 - Gravação de log de utilização da rotina

   If (SD2->(FieldPos("D2_X_SIM3G")) > 0)
      If SD2->D2_X_SIM3G  := "S"
         SD2->D2_X_SIM3G  := "N"
         SD2->D2_X_EXPO   := "N"
      Endif
   Endif
   If FWCodEmp() <> '11' //Empresas que não são do grupo 11(Tecpolpa).
      If ( (cNumEmp = "01010106") .OR. (cNumEmp = "01010107") .OR.  (cNumEmp = "01010108")) .and. (SD2->D2_CF <> '5907')
         Dbselectarea("SD2")
         nRegD2 := RecNo()
         //Gravar registro de movimentação de saída para depósito p/ ref. p/ movim. interna na filial 010101
         Dbselectarea("ZZY")
         RecLock("ZZY", .T.)
            ZZY->ZZY_FILIAL   := "010101"
            ZZY->ZZY_DOC      := nRegD2
            ZZY->ZZY_TIPO     := "E"
            ZZY->ZZY_TAB      := "SD2"
         MsUnLock()
      Endif
   Endif
   If !empty(_cArea)
      DbSelectArea(_cArea)
   Endif 

Return    
