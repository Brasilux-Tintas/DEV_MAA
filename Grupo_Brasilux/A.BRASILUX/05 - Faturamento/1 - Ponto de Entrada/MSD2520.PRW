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
////////////////////////////////////////////////////

User Function MSD2520() 
     Local _cArea := Alias()
     Local nRegD2

IF (SD2->(FieldPos("D2_X_SIM3G")) > 0)
   IF SD2->D2_X_SIM3G = "S"
      SD2->D2_X_SIM3G := "N"
      SD2->D2_X_EXPO := "N"
   ENDIF
ENDIF 


     If FWCodEmp() <> '11' //Empresas que não são do grupo 11(Tecpolpa).
        IF ( (cNumEmp = "01010106") .OR. (cNumEmp = "01010107") ) .and. (SD2->D2_CF <> '5907')
           dbselectarea("SD2")
           nRegD2 := RecNo()
           //Gravar registro de movimentação de saída para depósito p/ ref. p/ movim. interna na filial 010101
           dbselectarea("ZZY")
           RecLock("ZZY", .T.)
              ZZY->ZZY_FILIAL := "010101"
              ZZY->ZZY_DOC := nRegD2
              ZZY->ZZY_TIPO := "E"
              ZZY->ZZY_TAB := "SD2"
           MsUnLock()
        ENDIF   	
     Endif
if !empty(_cArea)
   dbSelectArea(_cArea)
endif 
Return    