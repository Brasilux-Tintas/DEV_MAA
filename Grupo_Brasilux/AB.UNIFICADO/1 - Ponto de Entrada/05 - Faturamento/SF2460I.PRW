#include 'TOTVS.CH'

User Function SF2460I()
     Local _cArea    := Alias()  
     Local nQtdVol   := 0
     Local aAreaAnt  := U_PegaArea({"SA1","SA2","ZZB","ZZ6"})
     Local lBloqueado, cAuxMens,lAchou


//Marcar p/ mandar p/ MasterSales
IF (SF2->(FieldPos("F2_X_SIM3G")) > 0)
   RecLock("SF2",.F.)
   IF !(SF2->F2_TIPO = "D") .AND. !EMPTY(ALLTRIM(SF2->F2_DUPL))
      SF2->F2_X_SIM3G := "S"
   ELSE
      SF2->F2_X_SIM3G := "N"
   ENDIF 
   SF2->F2_X_EXPO := " "
   MsUnLock()     
ENDIF

If FWCodEmp() <> '11'
        ///////////////////////////////////////////////////////////////
        // Programa...: SF2460I                                      //
        // Autor......:                              //
        // Ult. Alteracao: Cleber Orati Domingues -> Troca de Pto de //
        //   M460FIM p/ esse, pois o outro só gravava a ult. nota	//
        // Data.......: 04/03/02                                     //
        // Descricao..: Ponto de entrada, apos gravacao do SF2  	//
        // Uso........: Todas as Empresas                            // 
        ///////////////////////////////////////////////////////////////
        //Grava log de exclusao do pedido
         RecLock("ZZB", .t.)
         ZZB->ZZB_FILIAL := xFilial("ZZB")
         ZZB->ZZB_PEDIDO := SC5->C5_NUM
         ZZB->ZZB_IDLOG  := 'FAT'
         ZZB->ZZB_USRLOG := rtrim(cUserName)
         ZZB->ZZB_DATLOG := dDataBase
         ZZB->ZZB_HORLOG := Time()
         MsUnLock()


         DbSelectArea("SF2")
         lBloqueado = U_EstaBloqueado("SF2", RecNo())
         If !lBloqueado
            RecLock("SF2", .F.)
         Endif
         if cModulo != ('ATF')
         SF2->F2_PEDIDO := SC5->C5_NUM
         Endif

         /* parametro que habita uso via PE */
         If GETMV("ZP_PAR0061")

            /* Incluido por Nelieder Corneta em 02/08/2022 */
            /* retirada da trigger SF2010 */
            /* Corrige problema com volumes */
            If !EMPTY(SF2->F2_ESPECI2) .AND. (SF2->F2_VOLUME2 <= 0)
               SF2->F2_ESPECI2 := ''
            EndIf

            If !EMPTY(SF2->F2_ESPECI1) .AND. (SF2->F2_VOLUME1 <= 0)
               SF2->F2_ESPECI1 := ''
            EndIf

         EndIf


         If SC5->C5_TIPO $ "D_B"
		      If !(ALLTRIM(SA2->A2_COD) == ALLTRIM(SF2->F2_CLIENTE))
              dbselectarea("SA2")
              dbsetorder(1)
              dbseek(xFilial("SA2")+SF2->F2_CLIENTE)
            Endif
            DbSelectArea("SF2")
            SF2->F2_CLAS   := alltrim(SA2->A2_CLAS)
            SF2->F2_CGC    := alltrim(SA2->A2_CGC)
            SF2->F2_INSCR  := alltrim(u_SoNumCar(SA2->A2_INSCR))
            SF2->F2_RAZAO  := alltrim(SA2->A2_NOME)
            SF2->F2_CODCID := alltrim(SA2->A2_CODCID)     
            IF SA1->(FieldPos("A1_MENSNF")) > 0
        	      SF2->F2_MENNOTA := SUBSTR(ALLTRIM(SA1->A1_MENSNF),1,TamSx3("F2_MENNOTA")[1])
            ENDIF
         Else
            If !(ALLTRIM(SA1->A1_COD) == ALLTRIM(SF2->F2_CLIENTE))
              dbselectarea("SA1")
              dbsetorder(1)
              dbseek(xFilial("SA1")+SF2->F2_CLIENTE)
            Endif 
            DbSelectArea("SF2")
            SF2->F2_CLAS   := alltrim(SA1->A1_CLAS)
            SF2->F2_CGC    := alltrim(SA1->A1_CGC)
            SF2->F2_INSCR  := alltrim(u_SoNumCar(SA1->A1_INSCR))
            SF2->F2_RAZAO  := alltrim(SA1->A1_NOME)
            SF2->F2_CODCID := alltrim(SA1->A1_CODCID)
         Endif
         DbSelectArea("SF2")
         If !lBloqueado 	
            MsUnLock()
         Endif 
         If (!empty(alltrim(SC5->C5_ESPECI4)) .and. empty(alltrim(SC5->C5_ESPECI3))) .OR. (SC5->C5_X_SIM3G = "S")           
           dbselectarea("SC5")
           lBloqueado = U_EstaBloqueado("SC5", RecNo())
           If !lBloqueado
              RecLock("SC5", .F.)
           Endif     
           IF !empty(alltrim(SC5->C5_ESPECI4)) .and. empty(alltrim(SC5->C5_ESPECI3))
              SC5->C5_ESPECI3 := "VOLUME"
           ENDIF 
           IF SC5->C5_X_SIM3G = "S"
              SC5->C5_X_EXPO := " "
              SC5->C5_ALTERAD := "S"
           ENDIF 
           If !lBloqueado 	
              MsUnLock()
           Endif 
         Endif 
         
         dbselectarea("ZZ6")   
         dbsetorder(1)    //ZZ6_FILIAL+ZZ6_EMPR+ZZ6_TABELA+ZZ6_CHAVE   
         dbseek(xFilial("ZZ6")+xFilial("SC5")+"SC5"+SC5->C5_NUM)                                                                                                              
         lAchou := found()
         reclock("ZZ6",!lAchou)
         ZZ6->ZZ6_FILIAL := xFilial("ZZ6")
         ZZ6->ZZ6_EMPR := xFilial("SC5")
         ZZ6->ZZ6_TABELA := "SC5"
         ZZ6->ZZ6_CHAVE := SC5->C5_NUM
         ZZ6->ZZ6_DIA := dDataBase
         ZZ6->ZZ6_APAGAR := .F.
         ZZ6->ZZ6_PROCES	:= "N"
         ZZ6->ZZ6_VEND := SC5->C5_VEND1
         ZZ6->ZZ6_ULTATU := date()
         MsUnLock()

        //Solic. Michelly em 07/10/2015 -> Enviar email pro Ramon quando o pedido tiver marcado para acompanhar laudo
        IF ((cNumEmp = "01010101") .or. (cNumEmp = "01060101")) .and. (SC5->C5_LAUDO = "S")
           cAuxMens := "Nota Fiscal nro "+SF2->F2_DOC+", pedido nro "+SC5->C5_NUM+", CLIENTE : "+SC5->C5_CLIENTE+"-"+ ALLTRIM(IIF(SC5->C5_TIPO $ "D_B",SA2->A2_NOME,SA1->A1_NOME))+;
           " acompanha LAUDO!"
           If Substr(xFilial("SF2"),1,2)== "06"
		       U_EnvMail("Nota Fiscal "+SF2->F2_DOC+" possui laudo" ,cAuxMens,"laudo@dissoltex.com.br","") 
		   Else
		       U_EnvMail("Nota Fiscal "+SF2->F2_DOC+" possui laudo" ,cAuxMens,"laudo@brasilux.com.br","faturamento@brasilux.com.br","") 
		   Endif
        ENDIF 
Else
        /*Dyego Figueiredo / Chaus
          Este ponto de entrada SF2460I tem como objetivo:			
          1. Gravar na tabela SF2 - Cabecalho da Nota Fiscal a quantidade de volume de caixas
        */
        DbSelectArea("SD2")
        DbSetOrder(3)//D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM,
        If SD2->( DbSeek(xFilial("SD2") + SF2->F2_DOC +  SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA))
           While SD2->(!eof()) .and. (SF2->F2_DOC == SD2->D2_DOC .AND.   SF2->F2_SERIE == SD2->D2_SERIE .AND.  SF2->F2_CLIENTE == SD2->D2_CLIENTE .AND. SF2->F2_LOJA ==  SD2->D2_LOJA)
                 If SD2->D2_UM == 'CX'
                    nQtdVol += SD2->D2_QUANT
                 Endif
                 SD2->(dbskip())
           Enddo      
        Endif
        If SF2->(!Eof()) .AND. nQtdVol > 0
           Reclock("SF2",.F.)
              SF2->F2_VOLUME1 := nQtdVol
           MsUnlock()
        EndIf
Endif
U_VoltaArea(aAreaAnt)
If !empty(_cArea)
   dbselectarea(_cArea)
Endif 

Return
