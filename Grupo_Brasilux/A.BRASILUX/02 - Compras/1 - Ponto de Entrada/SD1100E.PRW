#INCLUDE "TOTVS.CH"

////////////////////////////////////////////////////
// Programa...: SD1100E-PE antes da excl do item //
// Autor......: Cleber Orati                      //
// Data.......: 16/07/15                          //
// Descricao..: Marcar lctos p/ Dep. Fechado      //
// Uso........: Brasilux/Deposito                 // 
////////////////////////////////////////////////////
//25/09/2019 - Luís Gustavo - Adequação para release 12.1.25
//19/06/2024 - André Maester - Ajuste Filial 010108 - Depósito fechado Araraquara
User Function SD1100E 
   
   Local _cArea := Alias()         
   Local nRegD1,_cGrpEmp,_cFilial,_cNumEmp
   u_zcfga01( 'SD1100E' ) //LGS#2021118 - Gravação de log de utilização da rotina
   _cGrpEmp := alltrim(FWGrpCompany())
   _cFilial := alltrim(FWCodFil())
   _cNumEmp := _cGrpEmp+_cFilial

   IF (SD1->(FieldPos("D1_X_SIM3G")) > 0)
      IF SD1->D1_X_SIM3G == "S"
         RecLock("SD1",.F.)
         SD1->D1_X_SIM3G := "N"
         SD1->D1_X_EXPO  := "N"
         MsUnLock()
      ENDIF
   ENDIF 

   If _cGrpEmp <> '11' //Empresas que não são do grupo 11(Tecpolpa).
      dbselectarea("SD1")
      nRegD1 := RecNo()
      IF (_cNumEmp == "01010106") .OR. (_cNumEmp == "01010107") .OR. (_cNumEmp == "01010108")
         //Gravar registro de movimentação de saída para depósito p/ ref. p/ movim. interna na filial 010101
         dbselectarea("ZZY")
         RecLock("ZZY", .T.)
            ZZY->ZZY_FILIAL := "010101"
            ZZY->ZZY_DOC := nRegD1
            ZZY->ZZY_TIPO := "S"
            ZZY->ZZY_TAB := "SD1"
         MsUnLock()
      ENDIF   	
      
      if FWAliasInDic("ZZZ")
         dbselectarea("ZZZ")
         DbOrderNickName("REGD1") //ZZZ_REGD1                                                                                                                                                       
         dbseek(nRegD1)
         if found()
            RecLock("ZZZ", .F.)
	            ZZZ->(DbDelete())
	         MsUnlock()
         endif
      endif 
   Endif
   If !empty( _cArea )
      dbSelectArea( _cArea )
   Endif

Return    
