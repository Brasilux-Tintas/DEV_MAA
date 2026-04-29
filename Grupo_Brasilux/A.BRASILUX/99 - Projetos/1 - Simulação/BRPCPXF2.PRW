#include 'rwmake.ch'
#include 'topconn.ch'
#include 'Font.ch'
#include 'ap5mail.ch'                                                                                                    
#include 'brpcpx01.ch'                                                                                
#xtranslate bSETGET(<uVar>) => { | u | If( PCount() == 0, <uVar>, <uVar> := u ) } 
#define DS_MODALFRAME            128  // 0x80
#define WS_POPUP          2147483648  // 0x80000000L
#define WS_CAPTION          12582912  // 0x00C00000L
#define WS_VISIBLE         268435456  // 0x10000000L
#define GEL_ARQ  01
#define GEL_POS  02 

  /************************************************************************************/
  /***                          RETORNA STATUS DA FÓRMULA                           ***/
  /************************************************************************************/
User Function fRetSta(oDlg, aGeral, aMarcacao, lSaida)                                              
     Local nOpcB   	 := 0
     Local cJusDev   := CRIAVAR("ZT_LOG")
     Local lProPA  	 := .f.
     Local lProPI  	 := .f.
     Local lPasta  	 := .f.
     Local aEmail  	 := {}
     Local cMatCod 	 := ""
     Local cRevCod 	 := ""
     Local cBaixa  	 := ""
     Local nX
     
     If Empty(aMarcacao[1][1][1]) // 1º Verificação se o 1º registro está marcado.
        MsgBox("Atenção, marque o 1º registro para retornas pendência, ou cancele !!!","Atenção...","INFO")
        Return .f.
     Else
        cQry := ""
        cQry += "SELECT COUNT(*) AS QUANT "
        cQry += "FROM "+RetSqlName("SZM")+" SZM WITH (NOLOCK) "
        cQry += "WHERE SZM.ZM_FILIAL  = '"+xFilial("SZM")+"' "
        cQry += "  AND SZM.D_E_L_E_T_ = '' "
        cQry += "  AND SZM.ZM_ID      = '"+&(aGeral[GEL_ARQ]+"->TMP_ID")+"' "
        cQry += "  AND SZM.ZM_RESPONS = '' "
        TCQUERY cQry ALIAS "QSZM" NEW
        DbSelectArea("QSZM")
        DbGoTop()
        nQtdPro := QSZM->QUANT
        DbSelectArea("QSZM")
        DbCloseArea()
        If nQtdPro <> 0
           MsgBox("Atenção, existe algum item que não foi verificado no status PCP !!!","Atenção...","INFO")
           Return .f.
        Else
           DbSelectArea("SZN")
           DbSetOrder(2)
           DbSeek(xFilial("SZN")+aMarcacao[1][1][2]+aMarcacao[1][1][4],.t.)
           If Found()
              //If !(cNumEmp == '01010104')
                 If Len(Alltrim(aMarcacao[1][1][2])) == 12 .and. aMarcacao[1][1][9] $ 'PI'
                    lProPI := .t.
                    If Posicione("SZM", 1, xFilial("SZM")+aMarcacao[1][1][2]+aMarcacao[1][1][4], "ZM_STATUS") $ 'EA'
                       	cNewSta := 'PP'
                    Endif
                 ElseIf Len(Alltrim(aMarcacao[1][1][2])) == 12 .and. aMarcacao[1][1][9] $ 'PA'
                        lProPA := .t.
                        If Posicione("SZM", 1, xFilial("SZM")+aMarcacao[1][1][2]+aMarcacao[1][1][4], "ZM_STATUS") $ 'PP'
                           	cNewSta := 'EE'
                        ElseIf Posicione("SZM", 1, xFilial("SZM")+aMarcacao[1][1][2]+aMarcacao[1][1][4], "ZM_STATUS") $ 'EA'
                        	cNewSta := 'PP'
                        Endif
                 ElseIf (Len(Alltrim(aMarcacao[1][1][2])) == 4 .or. Len(Alltrim(aMarcacao[1][1][2])) == 5 .or. Len(Alltrim(aMarcacao[1][1][2])) == 6) .and. aMarcacao[1][1][9] $ 'PI'
                        lPasta  := .t.
                        If Posicione("SZM", 1, xFilial("SZM")+aMarcacao[1][1][2]+aMarcacao[1][1][4], "ZM_STATUS") $ 'EA'
                           	cNewSta := 'EE'
                        Endif
                 Endif
              //Endif
           Else
              MsgBox("Não existem produtos compondo essa formula !!!","Informação...","INFO")
              Return(.f.)
           Endif
        Endif 
     Endif
     DEFINE MSDIALOG oDlg1 TITLE OemToAnsi("Devolução de Pendência") FROM 000,000 TO 010,049 OF oMainWnd
            @ 015,002 GROUP oGrp1 TO 074,191 LABEL  OemToAnsi('Motivo / Justificativa')           PIXEL OF oDlg1
            @ 020,005 GET cJusDev  MEMO             SIZE 183,047 OBJECT oJusDev
            
            oDlg1:nStyle       := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
     ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1, {|| lRet := fValDev(cJusDev), If(lRet, oDlg1:End(), nOpcB := 0), nOpcB := 1 }, {|| oDlg1:End(), nOpcB := 0 } ) CENTERED
     If nOpcB == 1
        lSaida := .t.
        If cNewSta $ 'EE'
           If lPasta
              cProcess := 'PIP'
              cBaixa   := 'DE'
              DbSelectArea("SZM")
              DbSetOrder(1)
              DbSeek(xFilial("SZM")+aMarcacao[1][1][2]+aMarcacao[1][1][4],.t.)
              If Found()
                 RecLock("SZM",.f.)
                    SZM->ZM_STATUS := cNewSta
                 MsUnLock()
                 MsgRun("Gerando LOG de devolução de pendência !!!", "Aguarde", {|| U_fGrvLog(SZM->ZM_ID, "SI", "DE", "Devolução de pendencia para verificação."+Chr(13)+Chr(10)+cJusDev, cUsername, StrZero((VAL(SZM->ZM_SEQ) + 1),3) )} )
                 aadd(aEMail, {SZM->ZM_CODIGO, SZM->ZM_DESCRIC })
              Endif
           ElseIf lProPA
                  cProcess := 'PAT'
                  cBaixa   := 'DE'
                  cIdCod   := aMarcacao[01][01][06]
                  cMatCod := Posicione("SZM", 5, xFilial("SZM")+cIdCod+'101', "ZM_CODIGO")  // Busca CODIGO  do PI pelo código de ID + sequencia constante de 101
                  cRevCod := Posicione("SZM", 5, xFilial("SZM")+cIdCod+'101', "ZM_REVISAO") // Busca REVISÃO do PI pelo código de ID + sequencia constante de 101
                  For nX := 1 To Len(aMarcacao)
                      DbSelectArea("SZM")
                      DbSetOrder(1)
                      DbSeek(xFilial("SZM")+aMarcacao[nX][1][2]+aMarcacao[nX][1][4],.t.)
                      If Found()
                         RecLock("SZM",.f.)
                            SZM->ZM_STATUS := "RT"
                         MsUnLock()
                         MsgRun("Gerando LOG de devolução de pendência !!!", "Aguarde", {|| U_fGrvLog(SZM->ZM_ID, "SI", "DE", "Devolução de pendencia para verificação.", cUsername, StrZero((VAL(SZM->ZM_SEQ) + 1),3) )} )
                      EndIf
                  Next
                  DbSelectArea("SZM")
                  DbSetOrder(1)
                  DbSeek(xFilial("SZM")+cMatCod+cRevCod,.t.)
                  If Found()
                     RecLock("SZM",.f.)
                        SZM->ZM_STATUS := cNewSta
                     MsUnLock()
                     MsgRun("Gerando LOG de devolução de pendência !!!", "Aguarde", {|| U_fGrvLog(SZM->ZM_ID, "SI", "DE", "Devolução de pendencia para verificação."+Chr(13)+Chr(10)+cJusDev, cUsername, StrZero((VAL(SZM->ZM_SEQ) + 1),3) )} )
                     aadd(aEMail, {SZM->ZM_CODIGO, SZM->ZM_DESCRIC })
                  Endif
           Else
              cProcess := 'PAT'
           Endif
        ElseIf cNewSta == 'PP'
               cProcess := 'PIT'
               cBaixa   := 'DE'
               For nX := 1 to Len(aMarcacao)
                   DbSelectArea("SZM")
                   DbSetOrder(1)
                   DbSeek(xFilial("SZM")+aMarcacao[nX][1][2]+aMarcacao[nX][1][4],.t.)
                   If Found()
                      RecLock("SZM",.f.)
                         If Alltrim(SubStr(aMarcacao[nX][1][2],11,2)) $ '00.99'
                            SZM->ZM_STATUS := 'RT'
                         Else
                            SZM->ZM_STATUS := cNewSta
                            aadd(aEMail, {SZM->ZM_CODIGO, SZM->ZM_DESCRIC })
                         Endif
                      MsUnLock()
                      MsgRun("Gerando LOG de devolução de pendência !!!", "Aguarde", {|| U_fGrvLog(SZM->ZM_ID, "SI", "DE", "Devolução de pendencia para verificação."+Chr(13)+Chr(10)+cJusDev, cUsername, StrZero((VAL(SZM->ZM_SEQ) + 1),3) )} )
                   Endif
               Next
        Endif
        MsgRun("Enviando e-mail procedimento !!!", "Aguarde", {|| U_fEMailP(cProcess, cBaixa, @aGeral, @aMarcacao, cJusDev, aEmail, aMarcacao[1][1][2], aMarcacao[1][1][4])} )
        oDlg:End()
     Endif
Return

Static Function fValDev(cJusDev)
       Local lRet := .f.
       If Empty(cJusDev)
          MsgBox("Atenção o motivo / justificativa, não pode ser vazio", "Atenção", "ALERT")
          lRet := .f.
       Else
          lRet := .t.
       Endif
Return(lRet)

/********************************************************************************************/
/***                          LIBERAÇÃO / APROVAÇÃO DE FÓRMULAS                           ***/
/*** REVISÃO - 28/09/04 - 1º) Ajuste no tipo de produto Existente ou Novo para o PA.      ***/
/***                    - 2º) Retirado recalculo do peso especifico e passado para a roti-***/
/***                          na FGRVFOR (Gravação da Fórmula na aprovação).              ***/
/***                    - 3º) Ajuste na revisão do PA.
/********************************************************************************************/
User Function fAprFor(oDlg, aGeral, aMarcacao)
     //Local nPosAtu  := aGeral[GEL_POS]
     Local cQry     := ""
     Local aEMail   := {}
     Local aEMNew   := {}
     Local lJaGrvd  := .f.
     Local lRet     := .t.
     Local cBaixa   := ""
     Local cProcess := ""
     Local _cLocalPa:= ""
     Local nY, nX, i
     Private aEmailGrp :={}
     
     If Empty(aMarcacao[1][1][1]) // 1º Verificação se o 1º registro está marcado.
        MsgBox("Atenção, marque o 1º registro para baixa de pendência, ou cancele !!!","Atenção...","INFO")
        Return .f.
     Else
        cQry := ""
        cQry += "SELECT COUNT(*) AS QUANT "
        cQry += "FROM "+RetSqlName("SZM")+" SZM WITH (NOLOCK) "
        cQry += "WHERE SZM.ZM_FILIAL  = '"+xFilial("SZM")+"' "
        cQry += "  AND SZM.D_E_L_E_T_ = '' "
        cQry += "  AND SZM.ZM_ID      = '"+&(aGeral[GEL_ARQ]+"->TMP_ID")+"' "
        cQry += "  AND SZM.ZM_RESPONS = '' "
        TCQUERY cQry ALIAS "QSZM" NEW
        DbSelectArea("QSZM")
        DbGoTop()
        nQtdPro := QSZM->QUANT
        DbSelectArea("QSZM")
        DbCloseArea()
        If nQtdPro <> 0
           MsgBox("Atenção, existe algum item que não foi verificado no status PCP !!!","Atenção...","INFO")
           Return .f.
        Else
           DbSelectArea("SZN")
           DbSetOrder(2)
           DbSeek(xFilial("SZN")+aMarcacao[1][1][2]+aMarcacao[1][1][4],.t.)
           If Found()
              //If !(cNumEmp == '01010104')
                 // Produto Tinta
                 If Len(Alltrim(aMarcacao[1][1][2])) == 12 .and. aMarcacao[1][1][9] $ 'PI'
                        cProcess := 'PIT'
                        //Em Elaboração para PCP
                        If Posicione("SZM", 1, xFilial("SZM")+aMarcacao[1][1][2]+aMarcacao[1][1][4], "ZM_STATUS") $ 'EE'
                           cBaixa := 'EE'
				           DbSelectArea("SZ4")
				           DbSetOrder(1)
				           DbSeek(xFilial("SZ4")+Substr(aMarcacao[1][1][2],1,3)+Alltrim(Substr(aMarcacao[1][1][2],4,2)),.t.)   // filial + caracteristica + cor
				           If !Found()
					            MsgBox("Não existe cadastro para essa CARACTERÍSTICA + LINHA. Verifique no cadastro de Características !!!", "Atenção", "INFO")
				                DbSelectArea("SZ4")
				                DbCloseArea()
				                Return
				           Endif
				           DbSelectArea("SZ4")
				           DbCloseArea()
                           
                           DbSelectArea("SZP")
                           DbSetOrder(1)
                           DbSeek(xFilial("SZP")+aMarcacao[1][1][2]+aMarcacao[1][1][4],.t.)
                           //DbSeek(xFilial("SZP")+aMarcacao[1][1][2],.t.)
                           If !Found()
                              MsgBox("Deve existir ao menos uma embalagem sugerida para esse produto !!!","Informação...","INFO")
                              Return
	                       Else
                              cSeq    := StrZero( Val( SubStr( Posicione("SZM", 1, xFilial("SZM")+aMarcacao[1][1][2]+aMarcacao[1][1][4], "ZM_SEQ"), 1, 1) ) + 1, 1)
                              cNumSol := Posicione("SZM", 1, xFilial("SZM")+aMarcacao[1][1][2]+aMarcacao[1][1][4], "ZM_NUMSOL")
                              aCadEmb := {}
                              While !Eof() .and. (SZP->ZP_FILIAL == xFilial("SZP")) .and. SZP->ZP_CODIGO == aMarcacao[1][1][2] .and. SZP->ZP_REVISAO == aMarcacao[1][1][4]
		   	                       If (Substr(Alltrim(aMarcacao[1][1][2]),11,2) =='99' .and. Posicione("SZ5", 1, xFilial("SZ5")+SZP->ZP_EMB, "Z5_UMEMB") $ 'K') .OR. (Substr(Alltrim(aMarcacao[1][1][2]),11,2) =='00' .and. Posicione("SZ5", 1, xFilial("SZ5")+SZP->ZP_EMB, "Z5_UMEMB") $ 'L')
                                   	   aadd(aCadEmb, SZP->ZP_EMB)
								   Else
					                   RecLock("SZP",.f.)
					                   	   Delete
					                   MsUnLock()	
                                   Endif
                                   DbSelectArea("SZP")
                                   DbSkip()
                              Enddo
                              
                              /****************** 
                               Busca Produtos com embalagens em Kg
                               ******************/
                              /*
                              cQry1 := ""
                              cQry1 += "SELECT SUBSTRING(SB1.B1_COD, 11, 02) AS EMBAL, SZ5.Z5_UMEMB AS UNIMED "
                              cQry1 += "FROM "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) "
                              cQry1 += "LEFT OUTER JOIN "+RetSqlName("SZ5")+" SZ5 WITH (NOLOCK) ON "+XFilial("SZ5")+" = SZ5.Z5_FILIAL AND SUBSTRING(SB1.B1_COD, 11, 02) = SZ5.Z5_EMB AND SZ5.D_E_L_E_T_ = '' "
                              cQry1 += "WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
                              cQry1 += "  AND SB1.D_E_L_E_T_ = '' "
                              cQry1 += "  AND SUBSTRING(SB1.B1_COD, 1, 10)  = '"+SubStr(aMarcacao[1][1][2],1,10)+"' "
                              cQry1 += "  AND SUBSTRING(SB1.B1_COD, 11,02) <> '00' "
                              cQry1 += "  AND SZ5.Z5_UMEMB = 'K' "
                              TCQuery cQry1 ALIAS "QEMB" NEW
                              DbSelectArea("QEMB")
                              While !Eof()
                                    If aScan(aCadEmb, QEMB->EMBAL) == 0
                                       aadd(aCadEmb, QEMB->EMBAL)
                                    Endif
                                    DbSelectArea("QEMB")
                                    DbSkip()
                              Enddo
                              DbSelectArea("QEMB")
                              DbCloseArea()
                              */
                              For nY := 1 To Len(aCadEmb)
                                  cRevis  := "000"
                                  lJaGrvd := .f.
                                  DbSelectArea("SZM")
                                  DbSetOrder(3)
                                  DbSeek(xFilial("SZM")+SubStr(aMarcacao[1][1][2],1,10)+aCadEmb[nY],.t.)
                                  If Found()
                                     If SZM->ZM_STATUS $ "RT"
                                        lJaGrvd := .t.
                                        RecLock("SZM",.f.)
                                           SZM->ZM_STATUS := 'PP'
                                        MsUnLock()
                                     Else
                                        cRevis := StrZero((Val(SZM->ZM_REVISAO) + 1),3)
                                     Endif
                                  Else
                                     cRevis := StrZero((Val(cRevis) + 1),3)
                                  Endif
                                  If !lJaGrvd
                                  	 If Len(Alltrim(aMarcacao[1][1][2])) == 12 .AND. (cNumEmp == "01010101") 
										_cLocalPa = Iif(Posicione("SZ1", 1, xFilial("SZ1")+SubStr(Alltrim(aMarcacao[1][1][2]), 04, 02), "Z1_LOCPAD")='02','P1','P2')
                                     Else
                                    	_cLocalPa = 'P1' //Iif(cNumEmp == "01060101",'P1','03')
                                     Endif
                                     //_cLocalPa := Iif(Len(Alltrim(aMarcacao[1][1][2])) == 12,Iif(Posicione("SZM", 1, xFilial("SZM")+Substr(aMarcacao[1][1][2],1,10)+'00',"ZM_LOCAL") $ "02","03","30"),"03")
                                     DbSelectArea("SZM")
                                     RecLock("SZM",.t.)
                                        SZM->ZM_FILIAL  := xFilial("SZM")
                                        SZM->ZM_CODIGO  := SubStr(aMarcacao[1][1][2],1,10)+aCadEmb[nY]
                                        SZM->ZM_REVISAO := cRevis
                                        SZM->ZM_DESCRIC := aMarcacao[1][1][3]
                                        SZM->ZM_RESPONS := space(15)
                                        SZM->ZM_DTINCLU := dDataBase
                                        SZM->ZM_SOLICIT := "QM"
                                        SZM->ZM_PESESP  := 1
                                        SZM->ZM_REVISIN := Inverte(SZM->ZM_REVISAO)
                                        SZM->ZM_STATUS  := "PP"
                                        SZM->ZM_TIPOPRO := Iif(Alltrim(Posicione("SB1", 1, xFilial("SB1")+SubStr(aMarcacao[1][1][2],1,10)+aCadEmb[nY], "B1_COD")) == Alltrim(SubStr(aMarcacao[1][1][2],1,10)+aCadEmb[nY]), "PE", "PN")
                                        SZM->ZM_TIPO    := "PA"
                                        SZM->ZM_LOCAL   := _cLocalPa    //03 FABRICA I - 30 - FABRICA II
                                        SZM->ZM_UM      := "UN"
                                        SZM->ZM_NUMSOL  := cNumSol
                                        SZM->ZM_ID      := aMarcacao[1][1][6]
                                        SZM->ZM_CATALIS := aMarcacao[1][1][7]
                                        SZM->ZM_RELCAT  := aMarcacao[1][1][8]
                                        SZM->ZM_SEQ     := cSeq+'01'
                                     MsUnLock()
                                     MsgRun("Gerando LOG de baixa de pendência !!!", "Aguarde", {|| U_fGrvLog(SZM->ZM_ID,"SI","PP","Gerado pela baixa de pendência de elaboração, para PCP ", cUsername, SZM->ZM_SEQ )} )
                                     cSeq := StrZero(Val(cSeq)+1,1)
                                     _cUmEMB := Posicione("SZ5", 1, xFilial("SZ5")+aCadEmb[nY], "Z5_UMEMB")
                                     _nVlEMB := Posicione("SZ5", 1, xFilial("SZ5")+aCadEmb[nY], "Z5_VOLUME")
                                     _nPsEsp := aMarcacao[1][1][14]
                                     DbSelectArea("SG1")
                                     DbSetOrder(1)
                                     DbSeek(xFilial("SG1")+SZM->ZM_CODIGO,.t.)
                                     If Found()
                                        While !Eof() .and. SG1->G1_COD == SZM->ZM_CODIGO
                                              RecLock("SZN",.t.)
                                                 SZN->ZN_FILIAL  := xFilial("SZN")
                                                 SZN->ZN_CODIGO  := SZM->ZM_CODIGO
                                                 SZN->ZN_REVISAO := SZM->ZM_REVISAO
                                                 SZN->ZN_COMP    := SG1->G1_COMP
                                                 SZN->ZN_TRT     := SG1->G1_TRT
                                                 SZN->ZN_PERC    := Iif(Len(Alltrim(SG1->G1_COMP))== 12 .and. Substr(SG1->G1_COMP,11,2)='00' , Round(Iif(_cUmEMB == 'K', (_nVlEMB / _nPsEsp), _nVlEmb), 3), SG1->G1_PERC)
                                                 SZN->ZN_QUANT   := Iif(Len(Alltrim(SG1->G1_COMP))== 12 .and. Substr(SG1->G1_COMP,11,2)='00', Round(Iif(_cUmEMB == 'K', (_nVlEMB / _nPsEsp), _nVlEmb), 3), SG1->G1_QUANT)
                                                 SZN->ZN_PESESP  := Iif(Len(Alltrim(SG1->G1_COMP))== 12, _nPsEsp, 1)
                                                 SZN->ZN_PERDA   := SG1->G1_PERDA
                                                 SZN->ZN_INI     := SG1->G1_INI
                                                 SZN->ZN_FIM     := SG1->G1_FIM
                                                 SZN->ZN_FIXVAR  := SG1->G1_FIXVAR
                                                 SZN->ZN_REVINI  := SG1->G1_REVINI
                                                 SZN->ZN_REVFIM  := SG1->G1_REVFIM
                                                 SZN->ZN_OPERACA := SG1->G1_OPERACA
                                              MsUnLock()
                                              DbSelectArea("SG1")                           
                                              DbSkip()
                                              //Iif(aMarcacao[1][1][9] $ 'PI', Iif(Len(Alltrim(SG1->G1_COMP)) == 12 .and. Substr(Alltrim(SG1->G1_COMP),11,2)='00' , (SG1->G1_PERC / 100) * _nPsEsp, (SG1->G1_PERC / 100)), SG1->G1_PERC)
                                        Enddo
                                     Else
                                        _cCodig := SZM->ZM_CODIGO
                                        _cRevis := SZM->ZM_REVISAO
                                        _cUmEMB := Posicione("SZ5", 1, xFilial("SZ5")+SubStr(_cCodig, 11, 2), "Z5_UMEMB")
                                        _nVlEMB := Posicione("SZ5", 1, xFilial("SZ5")+SubStr(_cCodig, 11, 2), "Z5_VOLUME")
                                        //_nPsEsp := Iif(Posicione("SB1", 1, xFilial("SB1")+SubStr(_cCodig, 1, 10)+'00   ', "B1_PESOESP") == 0.0, Posicione("SZM", 3, xFilial("SZM")+SubStr(_cCodig, 1, 10)+'00   ', "ZM_PESESP"), Posicione("SB1", 1, xFilial("SB1")+SubStr(_cCodig, 1, 10)+'00   ', "B1_PESOESP"))
										_nPsEsp := Iif(Posicione("SB1", 1, xFilial("SB1")+aMarcacao[1][1][2], "B1_PESOESP") == 0.0, Posicione("SZM", 3, xFilial("SZM")+aMarcacao[1][1][2], "ZM_PESESP"), Posicione("SB1", 1, xFilial("SB1")+aMarcacao[1][1][2], "B1_PESOESP"))
                                        nValVol := RetField("SZ5",1,xFilial("SZ5")+SubStr(SZM->ZM_CODIGO,11,02),"SZ5->Z5_VOLUME")
                                        DbSelectArea("SZN")
                                        RecLock("SZN",.t.)
                                           SZN->ZN_FILIAL  := xFilial("SZN")
                                           SZN->ZN_CODIGO  := _cCodig
                                           SZN->ZN_REVISAO := _cRevis
                                           SZN->ZN_COMP    := aMarcacao[1][1][2]  //SubStr(_cCodig, 1, 10)+"00"
                                           //SZN->ZN_COMP  := SubStr(_cCodig, 1, 10)+"00"
                                           SZN->ZN_TRT     := "001"
                                           SZN->ZN_PERC    := Iif(Len(Alltrim(aMarcacao[1][1][2]))== 12 .and. Substr(aMarcacao[1][1][2],11,2) $ '00', Round(Iif(_cUmEMB == 'K', (_nVlEMB / _nPsEsp), _nVlEmb), 3), _nVlEmb)//Round(Iif(_cUmEMB == 'K', (_nVlEMB / _nPsEsp), _nVlEmb), 3)//Iif(Substr(aMarcacao[1][1][2],11,2) $ '99', Round(_nVlEmb,3), Round(Iif(_cUmEMB == 'K', (_nVlEMB / _nPsEsp), _nVlEmb), 3))//Round(Iif(_cUmEMB == 'K', (_nVlEMB / _nPsEsp), _nVlEmb), 3)
                                           SZN->ZN_QUANT   := Iif(Len(Alltrim(aMarcacao[1][1][2]))== 12 .and. Substr(aMarcacao[1][1][2],11,2)='00', Round(Iif(_cUmEMB == 'K', (_nVlEMB / _nPsEsp), _nVlEmb), 3), _nVlEmb)//Iif(Substr(aMarcacao[1][1][2],11,2) $ '99', Round(_nVlEmb,3), Round(Iif(_cUmEMB == 'K', (_nVlEMB / _nPsEsp), _nVlEmb), 3))//Round(Iif(_cUmEMB == 'K', (_nVlEMB / _nPsEsp), _nVlEmb), 3)
                                           SZN->ZN_PESESP  := Iif(Len(Alltrim(SG1->G1_COMP))== 12, _nPsEsp, 1)
                                           SZN->ZN_PERDA   := 0
                                           SZN->ZN_INI     := dDataBase
                                           SZN->ZN_FIM     := Ctod("31/12/2049")
                                           SZN->ZN_FIXVAR  := "V"
                                           SZN->ZN_REVINI  := ""
                                           SZN->ZN_REVFIM  := "ZZZ"
                                           SZN->ZN_OPERACA := ""
                                           //Iif(aMarcacao[1][1][9] $ 'PI', Iif(Len(Alltrim(aMarcacao[1][1][2])) == 12 .and. Substr(Alltrim(aMarcacao[1][1][2]),11,2)='00' , (SG1->G1_PERC / 100) * _nPsEsp, (SZN->ZN_PERC / 100)), SZN->ZN_PERC)
                                        MsUnLock()
                                     Endif
                                  Else
                                     MsgRun("Gerando LOG de baixa de pendência !!!", "Aguarde", {|| U_fGrvLog(SZM->ZM_ID,"SI","PP","Gerado pela baixa de pendência de elaboração, para PCP ", cUsername, SZM->ZM_SEQ )} )
                                  Endif
                                  aadd(aEmail, {SZM->ZM_CODIGO, SZM->ZM_DESCRIC })
                              Next
                           Endif
                           DbSelectArea("SZM")
                           DbSetOrder(1)
                           DbSeek(xFilial("SZM")+aMarcacao[1][1][2]+aMarcacao[1][1][4],.t.)
                           If Found()
                              RecLock("SZM",.f.)
                                 SZM->ZM_STATUS := 'PP'
                              MsUnLock()
                              MsgRun("Gerando LOG de baixa de pendência !!!", "Aguarde", {|| U_fGrvLog(SZM->ZM_ID, "SI", "PP", "Baixa de pendência de elaboração para PCP.", cUsername, StrZero((VAL(SZM->ZM_SEQ) + 1),3) )} )
                           Endif
                        ElseIf Posicione("SZM", 1, xFilial("SZM")+aMarcacao[1][1][2]+aMarcacao[1][1][4], "ZM_STATUS") $ 'EA'
                               cBaixa  := 'EA'
                               lRetPro := .t.
                               aProNew := {}
                               cMsgPro := ""
                               //Verificar se existe produto novo no processo
                               lRetPro := fChkPro(aMarcacao, @aProNew, @cMsgPro)
                               If lRetPro
                                  For nX := 1 to Len(aMarcacao)
                                      DbSelectArea("SZM")
                                      DbSetOrder(1)
                                      DbSeek(xFilial("SZM")+aMarcacao[nX][1][2]+aMarcacao[nX][1][4],.t.)
                                      If Found()
                                         nPosPro := aScan(aProNew, {|x| x[3] == aMarcacao[nX][1][2]})
                                         MsgRun("Gravando formula !!!", "Aguarde...", {|| lRet := U_fGrvFor(aMarcacao, nX, @aEMNew, nPosPro, aProNew ) } )
                                         If lRet
                                             RecLock("SZM",.f.)
                                             SZM->ZM_STATUS := "AC"
                                             MsUnLock()
                                             aadd(aEmail, {aMarcacao[nX][1][2], aMarcacao[nX][1][3]}) 
											            If aMarcacao[nX][1][11] $ "PN" .and. aMarcacao[nX][1][09] $ "PA" 
												            aadd(aEmailGrp, {aMarcacao[nX][1][2], aMarcacao[nX][1][3]}) 
	                                          Endif
	    		                                 MsgRun("Gerando LOG de devolução de pendência !!!", "Aguarde", {|| U_fGrvLog(  SZM->ZM_ID, "SI", "AC", "Baixa de pendencia da diretoria.", cUsername, StrZero((VAL(SZM->ZM_SEQ ) + 1),3) )} )
                                         Endif
                                      Endif   
                                  Next
                               Else
                                  MsgBox(cMsgPro, "Atenção...", "STOP")
                                  Return
                               Endif
                        Endif
                        //Produto Acabado
                 ElseIf Len(Alltrim(aMarcacao[1][1][2])) == 12 .and. aMarcacao[1][1][9] $ 'PA'
                        cProcess := 'PAT'
                        //Em Elaboração para Liberação
                        If Posicione("SZM", 1, xFilial("SZM")+aMarcacao[1][1][2]+aMarcacao[1][1][4], "ZM_STATUS") $ 'EE'
                           cBaixa := 'EE'
                           lRetPro := .t.
                           aProNew := {}
                           cMsgPro := ""
                           //Verificar se existe produto novo no processo
                           lRetPro := fChkPro(aMarcacao, @aProNew, @cMsgPro)
                           If lRetPro
                              DbSelectArea("SZM")
                              DbSetOrder(1)
                              DbSeek(xFilial("SZM")+aMarcacao[1][1][2]+aMarcacao[1][1][4],.t.)
                              If Found()
                                 nPosPro := aScan(aProNew, {|x| x[3] == aMarcacao[1][1][2]})
                                 MsgRun("Gravando formula !!!", "Aguarde...", {|| lRet := U_fGrvFor(aMarcacao, 1, @aEMNew, nPosPro, aProNew ) } )
                                 If lRet
                                    RecLock("SZM",.f.)
                                       SZM->ZM_STATUS := "AC"
                                    MsUnLock()
                                    aadd(aEmail, {aMarcacao[1][1][2], aMarcacao[1][1][3]})
                                    MsgRun("Gerando LOG de baixa de pendência !!!", "Aguarde", {|| U_fGrvLog(SZM->ZM_ID, "SI", "AC","Baixa de pendencia da diretoria.", cUsername, SZM->ZM_SEQ )} )
                                 Endif
                              Endif
                           Else
                              MsgBox(cMsgPro, "Atenção...", "STOP")
                              Return
                           Endif
                               //Em PCP para Diretoria
                        ElseIf Posicione("SZM", 1, xFilial("SZM")+aMarcacao[1][1][2]+aMarcacao[1][1][4], "ZM_STATUS") $ 'PP'
                               cBaixa  := 'PP'
                               aadd(aEmail, {SubStr(aMarcacao[1][1][2],1,10)+'00   ', aMarcacao[1][1][3]})
                               DbSelectArea("SZM")
                               DbSetOrder(4)
                               //DbSeek(xFilial("SZM")+SubStr(aMarcacao[1][1][2],1,10)+'00   '+aMarcacao[1][1][4],.t.)
                               DbSeek(xFilial("SZM")+SubStr(aMarcacao[1][1][6],1,10),.t.)
                               If Found()
                                  While !Eof() .and. Substr(Alltrim(SZM->ZM_CODIGO), 1, 10) == Substr(Alltrim(aMarcacao[1][1][2]), 1, 10)
                                        If Substr(Alltrim(SZM->ZM_CODIGO), 11, 02) $ '00.99'
                                           RecLock("SZM", .f.)
                                              SZM->ZM_STATUS := "EA"
                                           MsUnLock()
                                           MsgRun("Gerando LOG de baixa de pendência !!!", "Aguarde", {|| U_fGrvLog(SZM->ZM_ID, "SI", "EA", "Baixa de pendência de elaboração para diretoria.", cUsername, StrZero((VAL(SZM->ZM_SEQ) + 1),3) )} )
                                        Endif
                                        DbSelectArea("SZM")
                                        DbSkip()
                                  EndDo
                               Endif
                               For nX := 1 To Len(aMarcacao)
                                   DbSelectArea("SZM")
                                   DbSetOrder(1)
                                   DbSeek(xFilial("SZM")+aMarcacao[nX][1][2]+aMarcacao[nX][1][4],.t.)
                                   If Found()
                                      RecLock("SZM", .f.)
                                         SZM->ZM_STATUS := "EA"
                                      MsUnLock()
                                      MsgRun("Gerando LOG de baixa de pendência !!!", "Aguarde", {|| U_fGrvLog(SZM->ZM_ID, "SI", "EA", "Baixa de pendência de elaboração para diretoria.", cUsername, StrZero((VAL(SZM->ZM_SEQ) + 1),3) )} )
                                      aadd(aEmail, {aMarcacao[nX][1][2], aMarcacao[nX][1][3]})
                                   Endif
                               Next
                        ElseIf Posicione("SZM", 1, xFilial("SZM")+aMarcacao[1][1][2]+aMarcacao[1][1][4], "ZM_STATUS") $ 'EA'
                               cBaixa  := 'EA'
                               aProNew := {}
                               cMsgPro := ""
                               lRetPro := fChkPro(aMarcacao, @aProNew, @cMsgPro)
                               If lRetPro
                                  For nX := 1 to Len(aMarcacao)
                                      DbSelectArea("SZM")
                                      DbSetOrder(1)
                                      DbSeek(xFilial("SZM")+aMarcacao[nX][1][2]+aMarcacao[nX][1][4],.t.)
                                      If Found()
                                         nPosPro := aScan(aProNew, {|x| x[3] == aMarcacao[nX][1][2]})
                                         MsgRun("Gravando formula !!!", "Aguarde...", {|| lRet := U_fGrvFor(aMarcacao, nX, @aEMNew, nPosPro, aProNew ) } )
                                         If lRet
                                            RecLock("SZM",.f.)
                                               SZM->ZM_STATUS := "AC"
                                            MsUnLock()
											//aadd(aEmailGrp, {aMarcacao[nX][1][2], aMarcacao[nX][1][3]}) 
                                         Endif
                                      Endif
                                  Next
                               Else
                                  MsgBox(cMsgPro, "Atenção...", "STOP")
                                  Return
                               Endif
                        Endif
                        //Produto Pasta
                 ElseIf (Len(Alltrim(aMarcacao[1][1][2])) == 4 .or. Len(Alltrim(aMarcacao[1][1][2])) == 5 .or. Len(Alltrim(aMarcacao[1][1][2])) == 6) .and. aMarcacao[1][1][9] $ 'PI'
                        cProcess := 'PIP'
                        //Em Elaboração para Diretoria
                        If Posicione("SZM", 1, xFilial("SZM")+aMarcacao[1][1][2]+aMarcacao[1][1][4], "ZM_STATUS") $ 'EE'
                           cBaixa := 'EE'
                           DbSelectArea("SZM")
                           DbSetOrder(1)
                           DbSeek(xFilial("SZM")+aMarcacao[1][1][2]+aMarcacao[1][1][4],.t.)
                           If Found()
                              RecLock("SZM",.f.)
                                 SZM->ZM_STATUS := 'EA'
                              MsUnLock()
                              aadd(aEmail, {aMarcacao[1][1][2], aMarcacao[1][1][3]})
                              MsgRun("Gerando LOG de baixa de pendência !!!", "Aguarde", {|| U_fGrvLog(SZM->ZM_ID, "SI", "EA", "Baixa de pendência de elaboração para diretoria.", cUsername, StrZero((VAL(SZM->ZM_SEQ) + 1),3) )} )
                           Endif
                               //De diretoria para uso
                        ElseIf Posicione("SZM", 1, xFilial("SZM")+aMarcacao[1][1][2]+aMarcacao[1][1][4], "ZM_STATUS") $ 'EA'
                               cBaixa := 'EA'
                               lRetPro := .t.
                               aProNew := {}
                               cMsgPro := ""
                               //Verificar se existe produto novo no processo
                               lRetPro := fChkPro(aMarcacao, @aProNew, @cMsgPro)
                               If lRetPro
                                  DbSelectArea("SZM")
                                  DbSetOrder(1)
                                  DbSeek(xFilial("SZM")+aMarcacao[1][1][2]+aMarcacao[1][1][4],.t.)
                                  If Found()
                                     nPosPro := aScan(aProNew, {|x| x[3] == aMarcacao[1][1][2]})
                                     MsgRun("Gravando formula !!!", "Aguarde...", {|| lRet := U_fGrvFor(aMarcacao, 1, @aEMNew, nPosPro, aProNew ) } )
                                     If lRet
                                        RecLock("SZM",.f.)
                                           SZM->ZM_STATUS := "AC"
                                        MsUnLock()
                                        aadd(aEmail, {aMarcacao[1][1][2], aMarcacao[1][1][3]})
                                        MsgRun("Gerando LOG de baixa de pendência !!!", "Aguarde", {|| U_fGrvLog(SZM->ZM_ID, "SI", "AC","Baixa de pendencia da diretoria.", cUsername, SZM->ZM_SEQ )} )
                                     Endif
                                  Endif
                               Else
                                  MsgBox(cMsgPro, "Atenção...", "STOP")
                                  Return
                               Endif
                        Endif
                 Endif
              //Endif //FIM If !(cNumEmp == '01010104')
              If lRet
                 MsgRun("Enviando e-mail procedimento !!!", "Aguarde", {|| U_fEMailP(cProcess, cBaixa, @aGeral, @aMarcacao, "", aEMail)} )
				 If Len(aEmailGrp) > 0
	   		   	     cTexto := "Liberado novos produtos pela Diretoria, conferir o cadastro do produto e complementá-lo se for necessário !"+CHR(13)+CHR(10)
					 For i:= 1 to Len(aEmailGrp)
						 cTexto+= CHR(13)+CHR(10)+"CODIGO :  "+aEmailGrp[i,1]+ "  ->  "+aEmailGrp[i,2]+CHR(13)+CHR(10)
					 Next i
			   		 cTexto+= CHR(13)+CHR(10)+"Prog. Origem : BRPCPXF2"
					 If Substr(xFilial("SB1"),1,2)== "06"
					 	U_EnvMail("DISSOLTEX - Liberado novo produto acabado" ,cTexto,"silene@dissoltex.com.br,eliana@brasilux.com.br,fernando@dissoltex.com.br,pcp@dissoltex.com.br","") 
					 Else
					 	U_EnvMail("BRASILUX - Liberado novo produto acabado" ,cTexto,"valdirene@brasilux.com.br,eliana@brasilux.com.br,fg@brasilux.com.br,marciononis@brasilux.com.br","") 					 
					 Endif
				Endif
              Endif
              If Len(aEMNew) > 0
                 MsgRun("Enviando e-mail procedimento !!!", "Aguarde", {|| U_fEMailP("GRV", '', @aGeral, @aMarcacao, "", aEMNew)} )
              Endif
           Else
              MsgBox("Não existem produtos compondo essa formula !!!","Informação...","INFO")
              Return(.f.)
           Endif
        Endif 
     Endif
     oDlg:End()
Return

/********************************************************************************************/
/*** FEMAILP - Rotina para envio de e-mail                                                ***/
/********************************************************************************************/
User Function fEMailP(cProcess, cBaixa, aGeral, aMarcacao, cMotivo, aEmail, cMatCod, cRevCod)
     //Local cSerNew := GETMV("MV_RELSERV")            //SERVIDOR SMTP
     //Local cAccNew := GETMV("MV_RELACNT")            //CONTA DE EMAIL
     //Local cEnvNew := GETMV("MV_RELACNT")            //EMAIL
     //Local cPasNew := GETMV("MV_RELPSW")             //SENHA DA CONTA
     Local cMenNew := ""                             //MENSAGEM DO CORPO DO EMAIL
     Local cSubNew := ""                             //ASSUNTO DA MENSAGEM
     //Local cCRLNew := Chr(13) + Chr(10)
     //Local cRemNew := ""                             //REMETENTE
     //Local cParNew := ""                             //DESTINATÁRIO
     Local nTipNew := 0
     Local cCabNew := ""
     Local cAprNew := UsrFullName(cCodUsr)
     
     Local cMensagem := ""
     Local cTo       := ""
     //Local nX        := 1
     
     If cProcess $ 'PIT'
        If cBaixa $ 'EE'
           cSubNew := "Baixa de Simulação - De: Quimico - Para: PCP."
           cCabNew := "Existe pendência de verificação de produtos acabados. Favor verificar!"
           nTipNew := 1
        ElseIf cBaixa $ 'EA'
               cSubNew := "Baixa de Simulação - Produto(s) Aprovado(s)."
               cCabNew :="Produtos aprovados!"
               nTipNew := 1
        ElseIf cBaixa $ 'DE'
               cSubNew := "Baixa de Simulação - De: Diretoria - Para: PCP."
               cCabNew := "Devolução de produto para verificação."
               nTipNew := 3
        ElseIf cBaixa $ 'RE'
               cSubNew := "Baixa de Simulação - Produto Rejeitado."
               cCabNew := "Produto rejeitado!"
               nTipNew := 2
        Endif
     ElseIf cProcess $ 'PAT'
            If cBaixa $ 'EE'
               cSubNew := "Baixa de Simulação - Produto(s) Aprovado(s)."
               cCabNew := "Produtos aprovados!"
               nTipNew := 1
            ElseIf cBaixa $ 'PP'
                   cSubNew := "Baixa de Simulação - De: PCP - Para: Diretoria."
                   cCabNew := "Existe pendência para aprovação. Favor verificar!"
                   nTipNew := 1
            ElseIf cBaixa $ 'EA'
                   /* Foi criado essas variáveis no caso de alguma não conformidade na aprovação pela diretoria. */
                   cSubNew := "Baixa de Simulação."
                   cCabNew := ""
                   nTipNew := 1
            ElseIf cBaixa $ 'DE'
                   cSubNew := "Baixa de Simulação - De: PCP - Para: Quimico."
                   cCabNew := "Devolução de produto para verificação."
                   nTipNew := 3
            Endif
     ElseIf cProcess $ 'PIP'
            If cBaixa $ 'EE'
               cSubNew := "Baixa de Simulação - De: Quimico - Para: Diretoria."
               cCabNew := "Existe pendência para aprovação. Favor verificar!"
               nTipNew := 1
            ElseIf cBaixa $ 'EA'
                   cSubNew := "Baixa de Simulação - Produto(s) Aprovado(s)."
                   cCabNew := "Produtos aprovados!"
                   nTipNew := 1
            ElseIf cBaixa $ 'DE'
                   cSubNew := "Baixa de Simulação - De: Diretoria - Para: Quimico."
                   cCabNew := "Devolução de produto para verificação."
                   nTipNew := 3
            ElseIf cBaixa $ 'RE'
                   cSubNew := "Baixa de Simulação - Produto Rejeitado."
                   cCabNew := "Produto rejeitado!"
                   nTipNew := 2
            Endif
     ElseIf cProcess $ 'GRV'
            cSubNew := "Gravação de Produto Novo."
            cCabNew := "Produto novo!"
            nTipNew := 1
     Endif
     fBusMail(@cTo, cProcess, cBaixa, cMatCod, cRevCod)

     If GETMV("MV_TRSIMUL")
        cMensagem += ' '+cTo
        cTo := GETMV("MV_EMSIMUL")
     Endif

     if !empty(cTo) .and. (substr(cTo,len(cTo),1) == ";")
     	cTo := substr(cTo,1,len(cTo)-1)
     endif 
     If !Empty(cTo)
        fMonMail(nTipNew, @cMenNew, cCabNew, cAprNew, aEmail, cMotivo )
        if !empty(cSubNew) .and. !empty(cMenNew)
        	U_EnvMail(cSubNew,cMenNew,cTo,"","") //para que seja enviado um arquivo em anexo o arquivo deve estar dentro da pasta protheus_data
        endif 
        /*CONNECT SMTP SERVER cSerNew ACCOUNT cAccNew PASSWORD cPasNew Result lConectou
                SEND MAIL FROM 'brasiluxtintas@brasilux.com.br';
                          TO cTo;
                          SUBJECT cSubNew;
                          BODY cMenNew;
                          RESULT lEnviado
                If !lEnviado
                   cMenNew := ""
                   GET MAIL ERROR cMenNew
                   MsgBox(cMenNew, "Erro...", "STOP")
                Endif
        DISCONNECT SMTP SERVER Result lDisConectou */
     Endif
Return

Static Function fBusMail(cTo, cProcess, cBaixa, cMatCod, cRevCod)
       Local lPCP       := .f.
       Local lDiretoria := .f.
       Local lAprova    := .f.
       Local lDevolve   := .f.
       Local lRejeita   := .f.
       Local lGrvNovo   := .f.
       
       cAlias  := Alias()
       cSavOrd := IndexOrd()

       If cProcess $ 'PIT'
          If cBaixa $ 'EE'
             lPCP           := .t. //ok
          ElseIf cBaixa $ 'EA'
                 lAprova    := .t. //ok
          ElseIf cBaixa $ 'DE'
                 lDevolve   := .t. //ok
          ElseIf cBaixa $ 'RE'
                 lRejeita   := .t. //ok
          Endif
       ElseIf cProcess $ 'PAT'
              If cBaixa $ 'EE'
                 lAprova        := .t.
              ElseIf cBaixa $ 'PP'
                     lDiretoria := .t.
              ElseIf cBaixa $ 'EA'
                     lAprova    := .t.
              ElseIf cBaixa $ 'DE'
                     lDevolve   := .t.
              Endif
       ElseIf cProcess $ 'PIP'
              If cBaixa $ 'EE'
                 lDiretoria     := .t. //ok
              ElseIf cBaixa $ 'EA'
                     lAprova    := .t. //ok
              ElseIf cBaixa $ 'DE'
                     lDevolve   := .t. //ok
              ElseIf cBaixa $ 'RE'
                     lRejeita   := .t. //ok
              Endif
       ElseIf cProcess $ 'GRV'
              lGrvNovo := .t. //ok
       Endif
       
       cQryPsw := ""
       cQryPsw += "SELECT * "
       cQryPsw += "FROM "+RetSqlName("SZW")+" SZW "
       cQryPsw += "WHERE SZW.ZW_FILIAL  = '"+xFilial("SZW")+"' "
       cQryPsw += "  AND SZW.D_E_L_E_T_ = '' "
       cQryPsw += "  AND SZW.ZW_ROTINA  = '"+cRotina+"' "
       cQryPsw += "  AND SZW.ZW_EMPFIL  = '"+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2)+"' "
       If lPCP
          cQryPsw += "  AND (SUBSTRING(SZW.ZW_ACESSOS, 4, 1) = '*' AND SUBSTRING(SZW.ZW_ACESSOS, 9, 1) = '*' AND SUBSTRING(SZW.ZW_ACESSOS, 10, 1) = '*') "
       ElseIf lDiretoria
              cQryPsw += " AND (SUBSTRING(SZW.ZW_ACESSOS, 5, 1) = '*' AND SUBSTRING(SZW.ZW_ACESSOS, 9, 1) = '*' AND SUBSTRING(SZW.ZW_ACESSOS, 10, 1) = '*') "
       ElseIf lAprova
              cQryPsw += " AND (SUBSTRING(SZW.ZW_ACESSOS, 9, 1) = '*' AND SUBSTRING(SZW.ZW_ACESSOS, 10, 1) = '*') "
              If cProcess $ 'PIP'
                 cQryPsw += " AND SZW.ZW_DEPTO IN('QUI', 'PCP', 'PRD', 'VEN') "
              ElseIf cProcess $ 'PAT'
                     cQryPsw += " AND SZW.ZW_DEPTO IN('PRD', 'VEN') "
              ElseIf cProcess $ 'PIT'
                     cQryPsw += " AND SZW.ZW_DEPTO IN('QUI', 'PCP', 'PRD', 'VEN') "
              Endif
       ElseIf lDevolve
              If cProcess $ 'PAT.PIP' // De PCP para Quimico para PA e De Diretoria para Quimico para Pasta
                 cAlias1  := Alias()
                 cSavOrd1 := IndexOrd()
                 PswOrder(2)
                 If PswSeek(Posicione("SZM", 1, xFilial("SZM")+cMatCod+cRevCod, "ZM_RESPONS"))
                    cQryPsw += "  AND SZW.ZW_USUARIO = '"+PswRet(1)[1][1]+"' "
                 Endif
                 DbSelectArea(cAlias1)
                 DbSetOrder(cSavOrd1)
              ElseIf cProcess == 'PIT' // De Diretoria para PCP
                     cQryPsw += "  AND (SUBSTRING(SZW.ZW_ACESSOS, 4, 1) = '*' AND SUBSTRING(SZW.ZW_ACESSOS, 9, 1) = '*' AND SUBSTRING(SZW.ZW_ACESSOS, 10, 1) = '*') "
              Endif
       ElseIf lRejeita
              If cProcess $ 'PIP'
                 cAlias1  := Alias()
                 cSavOrd1 := IndexOrd()
                 PswOrder(2)
                 If PswSeek(Posicione("SZM", 1, xFilial("SZM")+cMatCod+cRevCod, "ZM_RESPONS"))
                    cQryPsw += "  AND SZW.ZW_USUARIO = '"+PswRet(1)[1][1]+"' "
                 Endif
                 DbSelectArea(cAlias1)
                 DbSetOrder(cSavOrd1)
              ElseIf cProcess $ 'PIT.PAT'
                     cQryPsw += " AND (SUBSTRING(SZW.ZW_ACESSOS, 9, 1) = '*' AND SUBSTRING(SZW.ZW_ACESSOS, 10, 1) = '*') "
                     cQryPsw += " AND SZW.ZW_DEPTO IN('QUI', 'PCP') "
              Endif
       ElseIf lGrvNovo
              cQryPsw += " AND (SUBSTRING(SZW.ZW_ACESSOS, 9, 1) = '*' AND SUBSTRING(SZW.ZW_ACESSOS, 10, 1) = '*') "
              cQryPsw += " AND SZW.ZW_DEPTO IN('QUI', 'PCP', 'PRD', 'CON', 'VEN') "
       Endif
       TCQuery cQryPsw ALIAS "PSW" NEW

       DbSelectArea("PSW")
       DbGoTop()
       While !Eof() 
             cTo += Alltrim(UsrRetMail(PSW->ZW_USUARIO))+';'
             DbSelectArea("PSW")
             DbSkip()
       Enddo
       DbSelectArea("PSW")
       DbCloseArea()

       DbSelectArea(cAlias)
       DbSetOrder(cSavOrd)

Return(cTo)

/********************************************************************************************/
/*** fGRVFOR - Gravação da nova Fórmula no cad. de estrutura e ajustes no cad. de produto ***/
/*** REVISÃO - 28/09/04 - Mudança na lógica da gravação e recalculo do peso específico    ***/
/********************************************************************************************/
User Function fGrvFor( aMarcacao, nPos, aEmail, nPosPro, aProNew)
     Local aDados  := {}
     Local nPesLiq := 0
     Local nPesBru := 0
     Local lTemEmb := .f.,_nCustoComp
     //Local cZNINI  :=""
     //Local cZNFIM  :=""
     Local nPesNewSav := 0
     Private lMSErroAuto := .f.
     Private lMSHelpAuto := .t.
      If aMarcacao[nPos][1][11] $ 'PE'
        // Limpar produto da Estrutura SG1
        DbSelectArea("SG1")
        DbSetOrder(1)
        DbSeek(xFilial("SG1")+aMarcacao[nPos][1][2],.t.)
        If Found()
           While !Eof() .and. SG1->G1_COD == aMarcacao[nPos][1][2]
                 RecLock("SG1",.f.)                        
                    Delete
                 MsUnLock()
                 DbSelectArea("SG1")
                 DbSkip()
           Enddo
        Endif
        // Gravar nova Fórmula do Produto
        DbSelectArea("SZN")
        DbSetOrder(2)
        DbSeek(xFilial("SZN")+aMarcacao[nPos][1][2]+aMarcacao[nPos][1][4],.t.)
        If Found()
           While !Eof() .and. SZN->ZN_CODIGO == aMarcacao[nPos][1][2] .and. SZN->ZN_REVISAO == aMarcacao[nPos][1][4]
                  // produto de custeio
                  If U_IsProdCusto(SZN->ZN_COMP)
                     If !(nPesNew == 1)
                        nPesNewSav := nPesNew
                        nPesNew := 1
                     Endif
                  Endif      
                 RecLock("SG1", .t.)
                    SG1->G1_FILIAL  := xFilial("SZN")
                    SG1->G1_COD     := SZN->ZN_CODIGO
                    SG1->G1_COMP    := SZN->ZN_COMP
                    SG1->G1_TRT     := SZN->ZN_TRT
					      SG1->G1_QUANT   := Iif(aMarcacao[nPos][1][9] $ 'PI', Iif(Len(Alltrim(aMarcacao[nPos][1][2])) == 12 .AND. Substr(aMarcacao[nPos][1][2],11,2) $ '00', ((SZN->ZN_PERC / 100) * nPesNew), (SZN->ZN_PERC / 100)), SZN->ZN_PERC)
                    SG1->G1_PERC    := SZN->ZN_PERC //Iif(Len(Alltrim(aMarcacao[nPos][1][2])) == 12 .AND. Substr(aMarcacao[nPos][1][2],11,2)='00',(nPesNew * (SZN->ZN_PERC / 100) ),(SZN->ZN_PERC))//SZN->ZN_PERC
                    //SG1->G1_QUANT := Iif(aMarcacao[nPos][1][9] $ 'PI', Iif(Len(Alltrim(aMarcacao[nPos][1][2])) == 12, (SZN->ZN_PERC / 100) * nPesNew, (SZN->ZN_PERC / 100)), SZN->ZN_PERC)
                    SG1->G1_PERDA   := SZN->ZN_PERDA
                    SG1->G1_INI     := SZN->ZN_INI//IiF(POSICIONE("SB1",1,xFilial("SB1")+SZN->ZN_COMP,"B1_TIPO")="MC" .AND. POSICIONE("SB1",1,xFilial("SB1")+SZN->ZN_COMP,"B1_GRUPO2")= Alltrim(GETMV("MV_XGRPMC")),CTOD("31/12/2012"),ddatabase)          //SG1->G1_INI     := SZN->ZN_INI
                    SG1->G1_FIM     := SZN->ZN_FIM//IiF(POSICIONE("SB1",1,xFilial("SB1")+SZN->ZN_COMP,"B1_TIPO")="MC" .AND. POSICIONE("SB1",1,xFilial("SB1")+SZN->ZN_COMP,"B1_GRUPO2")= Alltrim(GETMV("MV_XGRPMC")),CTOD("31/12/2012"),CTOD("31/12/2049")) //SG1->G1_FIM     := SZN->ZN_FIM
                    SG1->G1_OBSERV  := ""
                    SG1->G1_FIXVAR  := SZN->ZN_FIXVAR
                    SG1->G1_GROPC   := ""
                    SG1->G1_OPC     := ""
                    SG1->G1_REVINI  := SZN->ZN_REVINI
                    SG1->G1_REVFIM  := SZN->ZN_REVFIM
                    SG1->G1_NIV     := ""
                    SG1->G1_NIVINV  := ""
                    SG1->G1_OPERACA := SZN->ZN_OPERACA

                 MsUnLock()
                 // produto de custeio
                 If !Empty(nPesNewSav)
                     nPesNew := nPesNewSav
                 Endif    
                 If aMarcacao[nPos][1][9] $ 'PI'
                     // produto de custeio
                     If U_IsProdCusto(SZN->ZN_COMP)
                     Else
                        nPesLiq += SZN->ZN_QUANT
                     Endif   
                 ElseIf aMarcacao[nPos][1][9] $ 'PA' .and. Len(Alltrim(aMarcacao[nPos][1][2])) == 12
						cKL := IIf(Alltrim(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(Alltrim(aMarcacao[nPos][1][2]), 11, 02), "Z5_UMEMB"))='K','99','00') 
                        If Len(Alltrim(SZN->ZN_COMP)) == 12 .and. SubStr(SZN->ZN_COMP, 11, 2) $ '00'
                            nPesLiq += SZN->ZN_QUANT * Posicione("SB1", 1, xFilial("SB1")+SZN->ZN_COMP, "B1_PESOESP")
                        ElseIf Len(Alltrim(SZN->ZN_COMP)) == 12 .and. SubStr(SZN->ZN_COMP, 11, 2) $ '99'
	                        nPesLiq += SZN->ZN_QUANT
                        Else
                           If Posicione("SB1", 1, xFilial("SB1")+SZN->ZN_COMP, "B1_TIPO") $ 'MP-PA' /* Alterar por Nelieder 31/10/2022 */
                              If !Empty(Alltrim(Posicione("SB1", 1, xFilial("SB1")+SZN->ZN_COMP, "B1_RELCAT1")))
                                 //nPesBru += SZN->ZN_QUANT * Posicione("SZ5", 1, xFilial("SZ5")+Alltrim(Posicione("SB1", 1, xFilial("SB1")+SZN->ZN_COMP, "B1_RELCAT1")), "Z5_PESO")
                                 nPesBru += Posicione("SB1", 1, xFilial("SB1")+SZN->ZN_COMP, "B1_PESO")
                                 lTemEmb := .t.
                              Else
                                 nPesBru += SZN->ZN_QUANT * Posicione("SB1", 1, xFilial("SB1")+SZN->ZN_COMP, "B1_PESO")
                              Endif
                           ElseIf Posicione("SB1", 1, xFilial("SB1")+SZN->ZN_COMP, "B1_TIPO") $ 'MC'
                                  nPesBru += SZN->ZN_QUANT * Posicione("SB1", 1, xFilial("SB1")+SZN->ZN_COMP, "B1_PESO")
                           Endif
                        Endif
                 Endif
                 DbSelectArea("SZN")
                 _nCustoComp := Posicione("SB1", 1, xFilial("SB1")+SZN->ZN_COMP, "B1_UPRC")
                 RecLock("SZN", .F.)
                 SZN->ZN_CUSTO   := _nCustoComp
                 MsUnLock()
                 DbSkip()
           Enddo
        Endif
        // Ajusta Peso Liquido e Bruto no Cadastro de Produto
        DbSelectArea("SB1")
        DbSetOrder(1)
        DbSeek(xFilial("SB1")+aMarcacao[nPos][1][2],.t.)
        If Found()
           RecLock("SB1",.f.)
              SB1->B1_DESC    := Alltrim(aMarcacao[nPos][1][3])
              SB1->B1_CATALIS := aMarcacao[nPos][1][7]
              SB1->B1_RELCAT1 := aMarcacao[nPos][1][8]
              SB1->B1_PESOESP := nPesNew
              SB1->B1_GRTRIB  := '001'
              SB1->B1_REVATU  := aMarcacao[nPos][1][4]
              If aMarcacao[nPos][1][9] $ 'PI'
                 SB1->B1_PESO    := nPesLiq
                 SB1->B1_PESBRU  := nPesLiq
              Else
                 If !lTemEmb
                    nPesBru += Posicione("SZ5", 1, xFilial("SZ5")+SubStr(aMarcacao[nPos][1][2], 11, 2), 'Z5_PESO')
                 Endif
                 SB1->B1_PESO    := nPesLiq
                 SB1->B1_PESBRU  := nPesBru + nPesLiq
              Endif
           MsUnLock()  
           /*Cleber (12/12/16) -> Chamado 006016, impedir inicialmente de o sistema atualizar preço automaticamente pelo último custo.
           Rui irá fazê-lo manualmente até que todo o chamado seja atendido
           */
           //fCalcPrc(aMarcacao[nPos][01][02]) // ATUALIZAR O PREÇO DE VENDA DO PRODUTO EXISTENTE
        Endif        
      ElseIf aMarcacao[nPos][1][11] $ 'PN'
         // Cadastrar novo produto
         cGrpPro := ""
         //Cleber(24/04/12)
           	 
         If Len(alltrim(aProNew[nPosPro][03])) >= 12
            cGrpPro := aProNew[nPosPro][02]+SubStr(aProNew[nPosPro][03], 4, 2)
         Endif   
                 
         DbSelectArea("SB1")
		   DbSetOrder(1)
        	DbSeek(xFilial("SB1")+aMarcacao[nPos][1][2],.t.)
        	If Found()
  	         MsgBox("Atenção, produto já existente no cadastro de produto, portanto não é PN. Verifique código: "+aProNew[nPosPro][03], "Atenção", "ALERT")
			   Return()	
      	Endif
            nPesNew := aProNew[nPosPro][08] //Recuperar peso específico de PI, está trazendo zerado.
            aadd(aDados,{"B1_FILIAL" , aProNew[nPosPro][01], Nil   }) ; aadd(aDados,{"B1_TIPO"   , aProNew[nPosPro][02]						, Nil   })
            aadd(aDados,{"B1_COD"    , aProNew[nPosPro][03], Nil   }) ; aadd(aDados,{"B1_DESC"   , aProNew[nPosPro][04]						, Nil   })
            aadd(aDados,{"B1_RESUMO" , aProNew[nPosPro][05], Nil   }) ; aadd(aDados,{"B1_UM"     , aProNew[nPosPro][06]						, Nil   })
            aadd(aDados,{"B1_LOCPAD" , aProNew[nPosPro][07], Nil   }) ; aadd(aDados,{"B1_PESOESP", aProNew[nPosPro][08]						, Nil   })
            aadd(aDados,{"B1_POSIPI" , aProNew[nPosPro][09], Nil   }) ; aadd(aDados,{"B1_EX_NCM" , aProNew[nPosPro][25]                     , Nil   }) 
            aadd(aDados,{"B1_COMIS"  , aProNew[nPosPro][10], Nil   })
            aadd(aDados,{"B1_IPI"    , aProNew[nPosPro][11], Nil   }) ; aadd(aDados,{"B1_LCRMIN" , aProNew[nPosPro][12]						, Nil   })
            aadd(aDados,{"B1_LUCRO"  , aProNew[nPosPro][13], Nil   }) ; aadd(aDados,{"B1_LUCROM2", aProNew[nPosPro][14]						, Nil   })
            aadd(aDados,{"B1_LUCRO2" , aProNew[nPosPro][15], Nil   }) ; aadd(aDados,{"B1_CONTA"  , aProNew[nPosPro][16]						, Nil   })
            aadd(aDados,{"B1_TS"     , aProNew[nPosPro][17], Nil   }) ; aadd(aDados,{"B1_CATALIS", aProNew[nPosPro][18]						, Nil   })
            aadd(aDados,{"B1_RELCAT1", aProNew[nPosPro][19], Nil   }) ; aadd(aDados,{"B1_OPERPAD", aProNew[nPosPro][20]						, Nil   })
            aadd(aDados,{"B1_GRUPO"  , cGrpPro             , Nil   }) ; aadd(aDados,{"B1_GRTRIB" , '001'               						, Nil   }) 
            aadd(aDados,{"B1_XCODANT", aProNew[nPosPro][22], Nil   }) ; aadd(aDados,{"B1_SEGUM"  , Iif(aProNew[nPosPro][02] $ 'PA', 'L', ''), Nil   }) 
            aadd(aDados,{"B1_REVATU" , aProNew[nPosPro][23], Nil   }) ; aadd(aDados,{"B1_GRUPO2" , aProNew[nPosPro][24], Nil   })

            MSExecAuto( {|x| MATA010(x)}, aDados)
          
            If lMsErroAuto
               MostraErro()
               Return(.F.)
            Else
               aadd(aEmail, {aMarcacao[nPos][01][02], aMarcacao[nPos][01][03]} )
            Endif
            // Gravar nova fórmula do produto
            DbSelectArea("SZN")
            DbSetOrder(2)
            DbSeek(xFilial("SZN")+aMarcacao[nPos][01][02]+aMarcacao[nPos][01][04],.t.)
            If Found()
               While !Eof() .and. SZN->ZN_CODIGO == aMarcacao[nPos][01][02] .and. SZN->ZN_REVISAO == aMarcacao[nPos][01][04]
                     // produto de custeio
                     If U_IsProdCusto(SZN->ZN_COMP)
                        If !(nPesNew == 1)
                           nPesNewSav := nPesNew
                           nPesNew := 1
                        Endif
                     Endif      
                     RecLock("SG1",.T.)
                        SG1->G1_FILIAL  := xFilial("SZN")
                        SG1->G1_COD     := SZN->ZN_CODIGO
                        SG1->G1_COMP    := SZN->ZN_COMP
                        SG1->G1_TRT     := SZN->ZN_TRT 
                        //SG1->G1_QUANT   := Iif(aMarcacao[nPos][1][9] $ 'PI', Iif(Len(Alltrim(aMarcacao[nPos][1][2])) == 12, (SZN->ZN_PERC / 100) * nPesNew, (SZN->ZN_PERC / 100)), SZN->ZN_PERC)
						SG1->G1_QUANT   := Iif(aMarcacao[nPos][1][9] $ 'PI', Iif(Len(Alltrim(aMarcacao[nPos][1][2])) == 12 .and. Substr(Alltrim(aMarcacao[nPos][1][2]),11,2) $ '00' , ((SZN->ZN_PERC / 100) * nPesNew), (SZN->ZN_PERC / 100)), SZN->ZN_PERC)
                        SG1->G1_PERDA   := SZN->ZN_PERDA
                        SG1->G1_INI     := SZN->ZN_INI//IiF(POSICIONE("SB1",1,xFilial("SB1")+SZN->ZN_COMP,"B1_TIPO")="MC" .AND. POSICIONE("SB1",1,xFilial("SB1")+SZN->ZN_COMP,"B1_GRUPO2") = Alltrim(GETMV("MV_XGRPMC")),CTOD("31/12/2012"),ddatabase)          //SG1->G1_INI     := SZN->ZN_INI
                        SG1->G1_FIM     := SZN->ZN_FIM//IiF(POSICIONE("SB1",1,xFilial("SB1")+SZN->ZN_COMP,"B1_TIPO")="MC" .AND. POSICIONE("SB1",1,xFilial("SB1")+SZN->ZN_COMP,"B1_GRUPO2") = Alltrim(GETMV("MV_XGRPMC")),CTOD("31/12/2012"),CTOD("31/12/2049")) //SG1->G1_FIM     := SZN->ZN_FIM
                        SG1->G1_OBSERV  := ""
                        SG1->G1_FIXVAR  := SZN->ZN_FIXVAR
                        SG1->G1_GROPC   := ""
                        SG1->G1_OPC     := ""
                        SG1->G1_REVINI  := SZN->ZN_REVINI
                        SG1->G1_REVFIM  := SZN->ZN_REVFIM
                        SG1->G1_NIV     := ""
                        SG1->G1_NIVINV  := ""
                        SG1->G1_PERC    := SZN->ZN_PERC
                        SG1->G1_OPERACA := SZN->ZN_OPERACA
                     MsUnLock()
                     // produto de custeio
                     If !Empty(nPesNewSav)
                        nPesNew := nPesNewSav
                     Endif    
                     If aMarcacao[nPos][1][9] $ 'PI'
                        // produto de custeio
                        If U_IsProdCusto(SZN->ZN_COMP)
                        Else
                           nPesLiq += SZN->ZN_QUANT
                        Endif   
                     ElseIf aMarcacao[nPos][1][9] $ 'PA' .and. Len(Alltrim(aMarcacao[nPos][1][2])) == 12
                            cKL := IIf(Alltrim(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(Alltrim(aMarcacao[nPos][1][2]), 11, 02), "Z5_UMEMB"))='K','99','00') 
                            If Len(Alltrim(SZN->ZN_COMP)) == 12 .and. SubStr(SZN->ZN_COMP, 11, 2) $ '00'
                               nPesLiq += SZN->ZN_QUANT * Posicione("SB1", 1, xFilial("SB1")+SubStr(SZN->ZN_COMP, 1, 10)+cKL, "B1_PESOESP")
                            ElseIf Len(Alltrim(SZN->ZN_COMP)) == 12 .and. SubStr(SZN->ZN_COMP, 11, 2) $ '99' 
	                           nPesLiq += SZN->ZN_QUANT 
                            Else
                               If Posicione("SB1", 1, xFilial("SB1")+SZN->ZN_COMP, "B1_TIPO") $ 'MP-PA' /* Alterar por Nelieder 31/10/2022 */
                                  If !Empty(Alltrim(Posicione("SB1", 1, xFilial("SB1")+SZN->ZN_COMP, "B1_RELCAT1")))
                                     nPesBru += SZN->ZN_QUANT * Posicione("SZ5", 1, xFilial("SZ5")+Alltrim(Posicione("SB1", 1, xFilial("SB1")+SZN->ZN_COMP, "B1_RELCAT1")), "Z5_PESO")
                                     lTemEmb := .t.
                                  Else
                                     nPesBru += SZN->ZN_QUANT * Posicione("SB1", 1, xFilial("SB1")+SZN->ZN_COMP, "B1_PESO")
                                  Endif
                               ElseIf Posicione("SB1", 1, xFilial("SB1")+SZN->ZN_COMP, "B1_TIPO") $ 'MC'
                                      nPesBru += SZN->ZN_QUANT * Posicione("SB1", 1, xFilial("SB1")+SZN->ZN_COMP, "B1_PESO")
                               Endif
                            Endif
                     Endif
                     DbSelectArea("SZN")
                     _nCustoComp := Posicione("SB1", 1, xFilial("SB1")+SZN->ZN_COMP, "B1_UPRC")
                     RecLock("SZN", .F.)
                     SZN->ZN_CUSTO   := _nCustoComp
                     MsUnLock()
                     DbSkip()
               Enddo
            Endif
            // Ajusta Peso Liquido e Bruto no Cadastro de Produto
            DbSelectArea("SB1")
            DbSetOrder(1)
            DbSeek(xFilial("SB1")+aMarcacao[nPos][1][2],.t.)
            If Found()
               RecLock("SB1",.f.)
                  If aMarcacao[nPos][1][9] $ 'PI'
                     SB1->B1_PESO    := nPesLiq
                     SB1->B1_PESBRU  := nPesLiq
                  Else
                     If !lTemEmb
                        nPesBru += Posicione("SZ5", 1, xFilial("SZ5")+SubStr(aMarcacao[nPos][1][2], 11, 2), 'Z5_PESO')
                     Endif 
                     //Cleber(11/10/13) -> Cód. de barras passou a ser preenchido por trigger no sql server
                     /*
                     //cCodBar := u_fBCODBar() - //LGS#20200210 - Adequação de release 12.1.25 e posteriores
                     SB1->B1_CODBAR  := cCodBar
                     */
                     SB1->B1_PESO    := nPesLiq
                     SB1->B1_PESBRU  := nPesBru + nPesLiq
                  Endif
               MsUnLock()
               DbSelectArea("SB1")
            Endif        
            
           
            //If aMarcacao[nPos][01][09] == "PA"
            	
               	fCalcPrc(aMarcacao[nPos][01][02])  //Ajustar preço Produto Novo
            //Endif
      Endif
Return(.t.)

Static Function fCalcPrc(cProduto)
       Local cAlias := Alias()
       Local nOrder := indexOrd()
       Local nRecno := RecNo()
       Local nCusto := 0
       Local nSomaCusto, nPerc, nContCols, nQtdeCols, nQtdeParc, i, nJur, cVar
       //Local cAux
       Private aArray
       aArray = {}
       aadd(aArray,{ "", "", "", cProduto})

       aPrazos    := {}
       aadd(aPrazos, 60)
       cPlanilha  := Iif(cNumEmp = '01010101', "BRASILUX.pdv", iif(cNumEmp = '01010104',"RESINA.PDV",iif(cNumEmp = '01060101',"DISSOLTE.PDV",iif(cNumEmp = '05',"UNIONSUR.PDV","SEMPLANI.pdv"))))
       nArq       := fopen(cPlanilha)
       nLidos     := 0
       If nArq > 0 
          FSEEK(nArq,0,0)
          nTamArq :=FSEEK(nArq,0,2)
          FSEEK(nArq,0,0)
          lOk     := .f.
          nUsado  := 0
          aAux    := {}
          While nLidos < nTamArq
                cLinha = U_fgets(nArq,nTamArq)
                If SubStr(cLinha, 6, 3) $ "PIS_IVA"
                   lOk = .t.
                Endif
                If lOk
                   nUsado := nUsado+1
                   cVar   := "V"+Alltrim(Str(nUsado))
                   aadd(aAux, { cVar, U_CTon( Alltrim( Substr( cLinha, 36, 10 ) ) ) })
                Endif	
                If SubStr(cLinha, 6, 16) == "DESP. COMERCIAIS"
                   lOk = .f.
                Endif
                nLidos += len(cLinha)+2
          EndDo
          fclose(nArq)
          If !Empty(cProduto)
             nMO       := 0
             nLucro    := 0
             nCusto    := 0
             nPreco    := 0
             nLinGetD  := 0
             nComissao := 0
             nIcms     := GETMV("MV_ICMPAD")
             nJuros    := GETMV("MV_JUROS")
		     DbSelectArea("SB1")		
             If DbSeek(xFilial("SB1")+cProduto)
                nCusto    := U_CustoPro(cProduto)
                nMo       := ExecBlock("BRPCP011",.F.,.F.,"MO")
                nLucro    := ExecBlock("BRPCP011",.F.,.F.,"LU")
                nLucro2   := ExecBlock("BRPCP011",.F.,.F.,"L2")
                nComissao := ExecBlock("BRPCP011",.F.,.F.,"CO")   

                nQtdeParc := len(aPrazos)
                nJur      := 0
                nPerc     := 0
                nPerc2    := 0
	            For i = 1 to nQtdeParc
                    nJur += 1 / ((1 + (nJuros / 100)) ^ ((12 * aPrazos[i]) / 365))
                Next                                              
                nJur       := (1 / nQtdeParc) * nJur
                nSomaCusto := nCusto + nMo
                nQtdeCols  := len(aAux)
                For nContCols := 1 to nQtdeCols    
                    nPerc  += aAux[nContCols,2]
                Next
                nPreco  := nSomaCusto / (nJur - ((nPerc + nIcms + nComissao + nLucro ) / 100))
                nPreco2 := nSomaCusto / (nJur - ((nPerc + nIcms + nComissao + nLucro2) / 100))
                DbSelectArea("SB1")
                DbSetOrder(1)
                DbSeek(xFilial("SB1")+cProduto,.t.)
                If Found()
                   RecLock("SB1",.f.)
                      SB1->B1_CUSTOR := nCusto+nMo //Cleber (19/06/2015), NÃO estava somando a mão de obra!!
                      SB1->B1_PERINT := nPerc
                      SB1->B1_PRV1   := nPreco
                   MsUnLock()
                Endif
                DbSelectArea("SB5")
                DbSetOrder(1)
                DbSeek(xFilial("SB5")+cProduto,.t.)
                If !Found()
                   RecLock("SB5",.t.)
                      SB5->B5_FILIAL  := xFilial("SB5")
                      SB5->B5_COD     := cProduto
                      SB5->B5_CEME    := SB1->B1_DESC
                      SB5->B5_CODATIV := SB1->B1_POSIPI
                Else
                   RecLock("SB5",.f.)
                Endif
				SB5->B5_PRV2    := nPreco2
				SB5->B5_DTREFP2 := dDataBase
				MsUnLock()
             Else 
                Alert("Produto Inexistente!")
             Endif
          Endif
       Else
          MsgBox("Impossível abrir planilha "+cPlanilha, "Atenção", "ALERT")
       Endif
       DbSelectArea(cAlias)
       DbSetOrder(nOrder)
       DbGoTo(nRecno)
Return
  /************************************************************************************/
  /***                              REJEITA A FÓRMULA                               ***/
  /************************************************************************************/
User Function fRejFor(oDlg, aGeral, aMarcacao)
     Local nOpcB   := 0
     Local cJusDev := CRIAVAR("ZT_LOG")
     Local lProPA  := .f.
     Local lProPI  := .f.
     Local lPasta  := .f.
     Local aEmail  := {}
     Local nX
     If Empty(aMarcacao[1][1][1]) // 1º Verificação se o 1º registro está marcado.
        MsgBox("Atenção, marque o 1º registro para retornas pendência, ou cancele !!!","Atenção...","INFO")
        Return .f.
     Else
        cQry := ""
        cQry += "SELECT COUNT(*) AS QUANT "
        cQry += "FROM "+RetSqlName("SZM")+" SZM "
        cQry += "WHERE SZM.ZM_FILIAL  = '"+xFilial("SZM")+"' "
        cQry += "  AND SZM.D_E_L_E_T_ = '' "
        cQry += "  AND SZM.ZM_ID      = '"+&(aGeral[GEL_ARQ]+"->TMP_ID")+"' "
        cQry += "  AND SZM.ZM_RESPONS = '' "
        TCQUERY cQry ALIAS "QSZM" NEW
        DbSelectArea("QSZM")
        DbGoTop()
        nQtdPro := QSZM->QUANT
        DbSelectArea("QSZM")
        DbCloseArea()
        If nQtdPro <> 0
           MsgBox("Atenção, existe algum item que não foi verificado no status PCP !!!","Atenção...","INFO")
           Return .f.
        Else
           DbSelectArea("SZN")
           DbSetOrder(2)
           DbSeek(xFilial("SZN")+aMarcacao[1][1][2]+aMarcacao[1][1][4],.t.)
           If Found()
              //If !(cNumEmp == '01010104')
                 If Len(Alltrim(aMarcacao[1][1][2])) == 12 .and. aMarcacao[1][1][9] $ 'PI'
                    lProPI := .t.
                    cNewSta := 'RE'
                 ElseIf Len(Alltrim(aMarcacao[1][1][2])) == 12 .and. aMarcacao[1][1][9] $ 'PA'
                        lProPA := .t.
                        cNewSta := 'RE'
                 ElseIf (Len(Alltrim(aMarcacao[1][1][2])) == 4 .or. Len(Alltrim(aMarcacao[1][1][2])) == 5 .or. Len(Alltrim(aMarcacao[1][1][2])) == 6) .and. aMarcacao[1][1][9] $ 'PI'
                        lPasta := .t.
                        cNewSta := 'RE'
                 Endif
              //Endif
           Else
              MsgBox("Não existem produtos compondo essa formula !!!","Informação...","INFO")
              Return(.f.)
           Endif
        Endif 
     Endif
     DEFINE MSDIALOG oDlg1 TITLE OemToAnsi("Rejeição de Fórmula") FROM 000,000 TO 015,059 OF oMainWnd
            @ 030,002 GROUP oGrp1 TO 078,195 LABEL  OemToAnsi('Motivo / Justificativa')           PIXEL OF oDlg1
            @ 040,005 GET cJusDev  MEMO             SIZE 183,047 OBJECT oJusDev
            
            oDlg1:nStyle       := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
     ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1, {|| lRet := fValDev(cJusDev), If(lRet, oDlg1:End(), nOpcB := 0), nOpcB := 1 }, {|| oDlg1:End(), nOpcB := 0 } ) CENTERED
     If nOpcB == 1
        If lPasta
           cProcess := 'PIP'
           cBaixa   := 'RE'
           DbSelectArea("SZM")
           DbSetOrder(1)
           DbSeek(xFilial("SZM")+aMarcacao[1][1][2]+aMarcacao[1][1][4],.t.)
           If Found()
              RecLock("SZM",.f.)
                 SZM->ZM_STATUS := cNewSta
              MsUnLock()
              aadd(aEMail, {SZM->ZM_CODIGO, SZM->ZM_DESCRIC })
              MsgRun("Gerando LOG de rejeição !!!", "Aguarde", {|| U_fGrvLog(SZM->ZM_ID, "SI", "DE", "Devolução de pendencia para verificação."+Chr(13)+Chr(10)+cJusDev, cUsername, StrZero((VAL(SZM->ZM_SEQ) + 1),3) )} )
           Endif
        Else
           cProcess := 'PIT'
           cBaixa   := 'RE'
           For nX := 1 to Len(aMarcacao)
               DbSelectArea("SZM")
               DbSetOrder(1)
               DbSeek(xFilial("SZM")+aMarcacao[nX][1][2]+aMarcacao[nX][1][4],.t.)
               If Found()
                  RecLock("SZM",.f.)
                     SZM->ZM_STATUS := cNewSta
                  MsUnLock()
                  MsgRun("Gerando LOG de rejeição !!!", "Aguarde", {|| U_fGrvLog(SZM->ZM_ID, "SI", "DE", "Devolução de pendencia para verificação."+Chr(13)+Chr(10)+cJusDev, cUsername, StrZero((VAL(SZM->ZM_SEQ) + 1),3) )} )
                  aadd(aEMail, {SZM->ZM_CODIGO, SZM->ZM_DESCRIC })
               Endif
           Next
        Endif
        MsgRun("Enviando e-mail procedimento !!!", "Aguarde", {|| U_fEMailP(cProcess, cBaixa, @aGeral, @aMarcacao, cJusDev, aEmail, aMarcacao[1][1][2], aMarcacao[1][1][4] )} )
        oDlg:End()
     Endif
Return

Static Function fChkPro(aMarcacao, aProNew, cMsgPro)
       Local lProNew  := .t.
       Local nPesEsp  := 0
       Local cConta   := "" 
       Local nIPI     := 0
       Local cPosIPI  := ""
	   Local cExNcm   := ""
       Local nComiss  := 0
       Local nLucMin  := 0
       Local nLucro   := 0
       Local nLucMin2 := 0
       Local nLucro2  := 0
       Local cTes     := ""
       Local nX
       
       cMsgPro := ""
       cMsgPro += "Atenção os seguintes produtos não tem sua classificação cadastrada: "+Chr(13)+Chr(10)
       
       For nX := 1 to Len(aMarcacao)
           If aMarcacao[nX][1][11] == 'PN'
              nPesEsp := 0
              DbSelectArea("SZN")
              DbSetOrder(2)
              DbSeek(xFilial("SZN")+aMarcacao[nX][01][02]+aMarcacao[nX][01][04],.t.)
              While !Eof() .and. SZN->ZN_CODIGO == aMarcacao[nX][01][02] .and. SZN->ZN_REVISAO == aMarcacao[nX][01][04]
                  // produto de custeio
                  If U_IsProdCusto(SZN->ZN_COMP)
                     SZN->(dbSkip())
                     Loop
                  Endif   

                    If aMarcacao[nX][01][09] == "PI"
                       //If Len(Alltrim(aMarcacao[nX][01][02])) == 12
                          //nPesEsp += ( (SZN->ZN_PERC / 100) ) /// Posicione("SB1", 1, xFilial("SB1")+SZN->ZN_COMP, "B1_PESOESP") )
                       //Else
                          nPesEsp += ( (SZN->ZN_PERC / 100) / Posicione("SB1", 1, xFilial("SB1")+SZN->ZN_COMP, "B1_PESOESP") )
                       //Endif
                    Else
                       nPesEsp := 1
                    Endif
                    DbSelectArea("SZN")
                    DbSkip()
              Enddo
              nPesEsp := (1 / nPesEsp)
              cConta := ""
              If aMarcacao[nX][01][09] == "PI"
                 //cConta := "11301001"
              Else
                 //cConta := "11307001"
              Endif
              If Len(Alltrim(aMarcacao[nX][01][02])) == 12
                 DbSelectArea("SZ6")
                 DbSetOrder(1)
                 DbSeek(xFilial("SZ6")+SubStr(Alltrim(aMarcacao[nX][01][02]),1,3)+SubStr(Alltrim(aMarcacao[nX][01][02]),04,02)+SubStr(Alltrim(aMarcacao[nX][01][02]),06,02), .t.)
                 If Found()
                    DbSelectArea("SYD")
                    DbSetOrder(1)
                    DbSeek(xFilial("SYD")+SZ6->Z6_CLASFIS+SZ6->Z6_EX_NCM, .t.)
                    If Found()
                       nIPI    := SYD->YD_PER_IPI
                       cPosIPI := Alltrim(SZ6->Z6_CLASFIS)
					   cExNcm := Alltrim(SZ6->Z6_EX_NCM)
                    Else
                       nIPI    := 0
                       cPosIPI := ""
					   cExNcm := ""
                       lProNew := .f.
                       cMsgPro += Alltrim(aMarcacao[nX][01][02])+Chr(13)+Chr(10)
                       MsgBox("Atenção não foi encontrada a Classificação fiscal para essa CARACTERÍSTICA + LINHA + COR !!!", "Atenção", "INFO")
                    Endif
                 Else
                    nIPI    := 0
                    cPosIPI := ""
					cExNcm := ""
                    lProNew := .f.
                    cMsgPro += Alltrim(aMarcacao[nX][01][02])+Chr(13)+Chr(10)
                    MsgBox("Atenção não foi encontrada a Classificação fiscal para a LINHA + COR do produto "+Alltrim(aMarcacao[nX][01][02])+"!!!", "Atenção", "INFO")
                 Endif
                 DbSelectArea("SZ1")
                 DbSetOrder(1)
                 DbSeek(xFilial("SZ1")+SubStr(Alltrim(aMarcacao[nX][01][02]),04,06),.t.)
                 If Found()
                    nComiss  := SZ1->Z1_COMISSA
                    nLucMin  := SZ1->Z1_LUCRMIN 
                    nLucro   := SZ1->Z1_LUCRO
                    nLucMin2 := SZ1->Z1_LUCROM2
                    nLucro2  := SZ1->Z1_LUCRO2
                 Endif
              Else
                 cPosIpi  := Posicione("SZM", 1, xFilial("SZM")+aMarcacao[nX][1][2]+aMarcacao[nX][1][4], "ZM_POSIPI") 
				 cExNcm := Posicione("SZM", 1, xFilial("SZM")+aMarcacao[nX][1][2]+aMarcacao[nX][1][4], "ZM_EX_NCM")

                 //cPosIPI  := ""
                 nIPI     := 0
                 nComiss  := 0
                 nLucMin  := 0
                 nLucro   := 0
                 nLucMin2 := 0
                 nLucro2  := 0
              Endif
              If SubStr(aMarcacao[nX][01][02], 1, 2) $ 'ED'
                 cTes := '502'
              Else
                 cTes := ''
              Endif
              
              aadd(aProNew, {xFilial("SB1")       , aMarcacao[nX][01][09], aMarcacao[nX][01][02],;
                             aMarcacao[nX][01][03], aMarcacao[nX][01][03], aMarcacao[nX][01][12],;
                             aMarcacao[nX][01][10], nPesEsp              , cPosIPI              ,;
                             nComiss              , nIPI                 , nLucMin              ,;
                             nLucro               , nLucMin2             , nLucro2              ,;
                             cConta               , cTes                 , aMarcacao[nX][01][07],;
                             aMarcacao[nX][01][08], aMarcacao[nX][01][13], nPesEsp              ,;
                             aMarcacao[nX][01][15], aMarcacao[nX][01][04], aMarcacao[nX][01][17],cExNcm})
           Endif
       Next
       cMsgPro += "Favor providenciar cadastro antes de liberar. "+Chr(13)+Chr(10)
Return(lProNew)

Static Function fMonMail(nTipNew, _cMenNew, cCabNew, cAprNew, aEmail, cMotivo)
       Local cMenNew := ''
       Local nX
       If nTipNew == 1
          cMenNew += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">'
          cMenNew += '<HTML>'
          cMenNew += '     <HEAD>'
          cMenNew += '          <META HTTP-EQUIV="CONTENT-TYPE" CONTENT="text/html; charset=windows-1252">'
          cMenNew += '          <TITLE>SIGAPCP</TITLE>'
          cMenNew += '          <META NAME="GENERATOR" CONTENT="OpenOffice.org 1.0.1  (Win32)">'
          cMenNew += '          <META NAME="CREATED" CONTENT="20030512;10464508">'
          cMenNew += '          <META NAME="CHANGED" CONTENT="20030625;9142607">'
          cMenNew += '     </HEAD>'
          cMenNew += '     <BODY LANG="pt-BR">'
          cMenNew += '         <TABLE WIDTH=645 BORDER=1 BORDERCOLOR="#0099cc" CELLPADDING=2 CELLSPACING=1 STYLE="page-break-before: always">'
          cMenNew += '             <TR>'
          cMenNew += '                 <TD WIDTH=606 HEIGHT=1 BGCOLOR="#0099cc">'
          cMenNew += '                     <P ALIGN=CENTER><FONT COLOR="#ffffff"><FONT FACE="Courier New"><FONT SIZE=4><B>MENSAGEM</B></FONT></FONT></FONT></P>'
          cMenNew += '                 </TD>'
          cMenNew += '             </TR>'
          cMenNew += '             <TR>'
          cMenNew += '                 <TD WIDTH=606 HEIGHT=32>'
          cMenNew += '                     <P ALIGN=CENTER>'+cCabNew+'.</P>'
          cMenNew += '                 </TD>'
          cMenNew += '             </TR>'
          cMenNew += '         </TABLE>'
          cMenNew += '         <P STYLE="margin-bottom: 0cm"><BR>'
          cMenNew += '         </P>'
          cMenNew += '         <TABLE WIDTH=643 BORDER=1 CELLPADDING=4 CELLSPACING=3>'
          cMenNew += '             <COL WIDTH=73>'
          cMenNew += '             <COL WIDTH=133>'
          cMenNew += '             <COL WIDTH=399>'
          cMenNew += '             <THEAD>'
          cMenNew += '                 <TR VALIGN=TOP>'
          cMenNew += '                     <TH WIDTH=73 BGCOLOR="#0099cc">'
          cMenNew += '                         <P><FONT COLOR="#ffffff"><SPAN STYLE="background: transparent">Item</SPAN></FONT></P>'
          cMenNew += '                     </TH>'
          cMenNew += '                     <TH WIDTH=133 BGCOLOR="#0099cc">'
          cMenNew += '                         <P><FONT COLOR="#ffffff"><SPAN STYLE="background: transparent">C&oacute;digo</SPAN></FONT></P>'
          cMenNew += '                     </TH>'
          cMenNew += '                     <TH WIDTH=399 BGCOLOR="#0099cc">'
          cMenNew += '                         <P><FONT COLOR="#ffffff"><SPAN STYLE="background: transparent">Descri&ccedil;&atilde;o</SPAN></FONT></P>'
          cMenNew += '                     </TH>'
          cMenNew += '                 </TR>'
          cMenNew += '             </THEAD>'
          cMenNew += '         </TABLE>'
          For nX := 1 to Len(aEmail)
              cMenNew += '         <TABLE WIDTH=643 BORDER=1 CELLPADDING=4 CELLSPACING=3>'
              cMenNew += '             <COL WIDTH=73>'
              cMenNew += '             <COL WIDTH=132>'
              cMenNew += '             <COL WIDTH=400>'
              cMenNew += '             <THEAD>'
              cMenNew += '                 <TR VALIGN=TOP>'
              cMenNew += '                     <TH WIDTH=73 BGCOLOR="#ffffff">'
              cMenNew += '                         <P><FONT COLOR="#0099cc"><SPAN STYLE="background: transparent">'+StrZero(nX,3)+'</SPAN></FONT></P>'
              cMenNew += '                     </TH>'
              cMenNew += '                     <TH WIDTH=132 BGCOLOR="#ffffff">'
              cMenNew += '                         <P><FONT COLOR="#0099cc"><SPAN STYLE="background: transparent">'+aEmail[nX][1]+'</SPAN></FONT></P>'
              cMenNew += '                     </TH>'
              cMenNew += '                     <TH WIDTH=400 BGCOLOR="#ffffff">'
              cMenNew += '                         <P><FONT COLOR="#0099cc"><SPAN STYLE="background: transparent">'+aEmail[nX][2]+'</SPAN></FONT></P>'
              cMenNew += '                     </TH>'
              cMenNew += '                 </TR>'
              cMenNew += '             </THEAD>'
              cMenNew += '         </TABLE>'
          Next
          cMenNew += '         <P><BR>Atenciosamente,<BR>'+cAprNew+'<BR><BR><BR>'
          cMenNew += '         </P>'
          cMenNew += '         <P><EM><FONT SIZE=2>Mensagem gerada Automaticamente pelo Modulo'
          cMenNew += '         SIGAPCP &ndash; Planejamento e Controle de Produ&ccedil;&atilde;o.</FONT></EM></P>'
          cMenNew += '    </BODY>'
          cMenNew += '</HTML>'
       ElseIf nTipNew == 2
              cMenNew += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">'
              cMenNew += '<HTML>'
              cMenNew += '    <HEAD>'
              cMenNew += '        <META HTTP-EQUIV="CONTENT-TYPE" CONTENT="text/html; charset=windows-1252">'
              cMenNew += '        <TITLE>SIGAPCP</TITLE>'
              cMenNew += '        <META NAME="GENERATOR" CONTENT="OpenOffice.org 1.0.1  (Win32)">'
              cMenNew += '        <META NAME="CREATED" CONTENT="20030512;10464508">'
              cMenNew += '        <META NAME="CHANGED" CONTENT="20030630;10383400">'
              cMenNew += '    </HEAD>'
              cMenNew += '    <BODY LANG="pt-BR">'
              cMenNew += '        <TABLE WIDTH=645 BORDER=1 BORDERCOLOR="#0099cc" CELLPADDING=2 CELLSPACING=1 STYLE="page-break-before: always">'
              cMenNew += '            <TR>'
              cMenNew += '                <TD WIDTH=606 HEIGHT=1 BGCOLOR="#0099cc">'
              cMenNew += '                    <P ALIGN=CENTER><FONT COLOR="#ffffff"><FONT FACE="Courier New"><FONT SIZE=4><B>MENSAGEM</B></FONT></FONT></FONT></P>'
              cMenNew += '                </TD>'
              cMenNew += '            </TR>'
              cMenNew += '            <TR>'
              cMenNew += '                <TD WIDTH=606 HEIGHT=32>'
              cMenNew += '                    <P ALIGN=CENTER>'+cCabNew+'.</P>'
              cMenNew += '                </TD>'
              cMenNew += '            </TR>'
              cMenNew += '        </TABLE>'
              cMenNew += '        <P STYLE="margin-bottom: 0cm"><BR>'
              cMenNew += '        </P>'
              cMenNew += '        <TABLE WIDTH=643 BORDER=1 CELLPADDING=4 CELLSPACING=3>'
              cMenNew += '            <COL WIDTH=73>'
              cMenNew += '            <COL WIDTH=133>'
              cMenNew += '            <COL WIDTH=399>'
              cMenNew += '            <THEAD>'
              cMenNew += '                <TR VALIGN=TOP>'
              cMenNew += '                    <TH WIDTH=73 BGCOLOR="#0099cc">'
              cMenNew += '                        <P><FONT COLOR="#ffffff"><SPAN STYLE="background: transparent">Item</SPAN></FONT></P>'
              cMenNew += '                    </TH>'
              cMenNew += '                    <TH WIDTH=133 BGCOLOR="#0099cc">'
              cMenNew += '                        <P><FONT COLOR="#ffffff"><SPAN STYLE="background: transparent">C&oacute;digo</SPAN></FONT></P>'
              cMenNew += '                    </TH>'
              cMenNew += '                    <TH WIDTH=399 BGCOLOR="#0099cc">'
              cMenNew += '                        <P><FONT COLOR="#ffffff"><SPAN STYLE="background: transparent">Descri&ccedil;&atilde;o</SPAN></FONT></P>'
              cMenNew += '                    </TH>'
              cMenNew += '                </TR>'
              cMenNew += '            </THEAD>'
              cMenNew += '        </TABLE>'
              For nX := 1 to Len(aEmail)
                  cMenNew += '        <TABLE WIDTH=643 BORDER=1 CELLPADDING=4 CELLSPACING=3>'
                  cMenNew += '            <COL WIDTH=73>'
                  cMenNew += '            <COL WIDTH=132>'
                  cMenNew += '            <COL WIDTH=400>'
                  cMenNew += '            <THEAD>'
                  cMenNew += '                <TR VALIGN=TOP>'
                  cMenNew += '                    <TH WIDTH=73 BGCOLOR="#ffffff">'
                  cMenNew += '                        <P><FONT COLOR="#0099cc"><SPAN STYLE="background: transparent">'+StrZero(nX,3)+'</SPAN></FONT></P>'
                  cMenNew += '                    </TH>'
                  cMenNew += '                    <TH WIDTH=132 BGCOLOR="#ffffff">'
                  cMenNew += '                        <P><FONT COLOR="#0099cc"><SPAN STYLE="background: transparent">'+aEmail[nX][1]+'</SPAN></FONT></P>'
                  cMenNew += '                    </TH>'
                  cMenNew += '                    <TH WIDTH=400 BGCOLOR="#ffffff">'
                  cMenNew += '                        <P><FONT COLOR="#0099cc"><SPAN STYLE="background: transparent">'+aEmail[nX][2]+'</SPAN></FONT></P>'
                  cMenNew += '                    </TH>'
                  cMenNew += '                </TR>'
                  cMenNew += '            </THEAD>'
                  cMenNew += '        </TABLE>'
              Next
              cMenNew += '        <P><BR><BR>'
              cMenNew += '        </P>'
              cMenNew += '        <TABLE WIDTH=645 BORDER=1 BORDERCOLOR="#0099cc" CELLPADDING=2 CELLSPACING=3>'
              cMenNew += '            <COL WIDTH=633>'
              cMenNew += '            <TR>'
              cMenNew += '                <TD WIDTH=633 BGCOLOR="#0099cc">'
              cMenNew += '                    <P ALIGN=CENTER><FONT COLOR="#ffffff"><FONT FACE="Courier New"><FONT SIZE=4><B>Motivo'
              cMenNew += '                    da Rejei&ccedil;&atilde;o</B></FONT></FONT></FONT></P>'
              cMenNew += '                </TD>'
              cMenNew += '            </TR>'
              cMenNew += '            <TR>'
              cMenNew += '                <TD WIDTH=633 HEIGHT=30>'
              cMenNew += '                    <P ALIGN=LEFT>'+cMotivo+'</P>'
              cMenNew += '                </TD>'
              cMenNew += '            </TR>'
              cMenNew += '        </TABLE>'
              cMenNew += '        <P><BR>Atenciosamente,<BR>'+cAprNew+'<BR><BR><BR>'
              cMenNew += '        </P>'
              cMenNew += '        <P><EM><FONT SIZE=2>Mensagem gerada Automaticamente pelo Modulo'
              cMenNew += '        SIGAPCP &ndash; Planejamento e Controle de Produ&ccedil;&atilde;o.</FONT></EM></P>'
              cMenNew += '    </BODY>'
              cMenNew += '</HTML>'
       ElseIf nTipNew == 3
              cMenNew += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">'
              cMenNew += '<HTML>'
              cMenNew += '    <HEAD>'
              cMenNew += '        <META HTTP-EQUIV="CONTENT-TYPE" CONTENT="text/html; charset=windows-1252">'
              cMenNew += '        <TITLE>SIGAPCP</TITLE>'
              cMenNew += '        <META NAME="GENERATOR" CONTENT="OpenOffice.org 1.0.1  (Win32)">'
              cMenNew += '        <META NAME="CREATED" CONTENT="20030512;10464508">'
              cMenNew += '        <META NAME="CHANGED" CONTENT="20030630;10383400">'
              cMenNew += '    </HEAD>'
              cMenNew += '    <BODY LANG="pt-BR">'
              cMenNew += '        <TABLE WIDTH=645 BORDER=1 BORDERCOLOR="#0099cc" CELLPADDING=2 CELLSPACING=1 STYLE="page-break-before: always">'
              cMenNew += '            <TR>'
              cMenNew += '                <TD WIDTH=606 HEIGHT=1 BGCOLOR="#0099cc">'
              cMenNew += '                    <P ALIGN=CENTER><FONT COLOR="#ffffff"><FONT FACE="Courier New"><FONT SIZE=4><B>MENSAGEM</B></FONT></FONT></FONT></P>'
              cMenNew += '                </TD>'
              cMenNew += '            </TR>'
              cMenNew += '            <TR>'
              cMenNew += '                <TD WIDTH=606 HEIGHT=32>'
              cMenNew += '                    <P ALIGN=CENTER>'+cCabNew+'.</P>'
              cMenNew += '                </TD>'
              cMenNew += '            </TR>'
              cMenNew += '        </TABLE>'
              cMenNew += '        <P STYLE="margin-bottom: 0cm"><BR>'
              cMenNew += '        </P>'
              cMenNew += '        <TABLE WIDTH=643 BORDER=1 CELLPADDING=4 CELLSPACING=3>'
              cMenNew += '            <COL WIDTH=73>'
              cMenNew += '            <COL WIDTH=133>'
              cMenNew += '            <COL WIDTH=399>'
              cMenNew += '            <THEAD>'
              cMenNew += '                <TR VALIGN=TOP>'
              cMenNew += '                    <TH WIDTH=73 BGCOLOR="#0099cc">'
              cMenNew += '                        <P><FONT COLOR="#ffffff"><SPAN STYLE="background: transparent">Item</SPAN></FONT></P>'
              cMenNew += '                    </TH>'
              cMenNew += '                    <TH WIDTH=133 BGCOLOR="#0099cc">'
              cMenNew += '                        <P><FONT COLOR="#ffffff"><SPAN STYLE="background: transparent">C&oacute;digo</SPAN></FONT></P>'
              cMenNew += '                    </TH>'
              cMenNew += '                    <TH WIDTH=399 BGCOLOR="#0099cc">'
              cMenNew += '                        <P><FONT COLOR="#ffffff"><SPAN STYLE="background: transparent">Descri&ccedil;&atilde;o</SPAN></FONT></P>'
              cMenNew += '                    </TH>'
              cMenNew += '                </TR>'
              cMenNew += '            </THEAD>'
              cMenNew += '        </TABLE>'
              For nX := 1 to Len(aEmail)
                  cMenNew += '        <TABLE WIDTH=643 BORDER=1 CELLPADDING=4 CELLSPACING=3>'
                  cMenNew += '            <COL WIDTH=73>'
                  cMenNew += '            <COL WIDTH=132>'
                  cMenNew += '            <COL WIDTH=400>'
                  cMenNew += '            <THEAD>'
                  cMenNew += '                <TR VALIGN=TOP>'
                  cMenNew += '                    <TH WIDTH=73 BGCOLOR="#ffffff">'
                  cMenNew += '                        <P><FONT COLOR="#0099cc"><SPAN STYLE="background: transparent">'+StrZero(nX,3)+'</SPAN></FONT></P>'
                  cMenNew += '                    </TH>'
                  cMenNew += '                    <TH WIDTH=132 BGCOLOR="#ffffff">'
                  cMenNew += '                        <P><FONT COLOR="#0099cc"><SPAN STYLE="background: transparent">'+aEmail[nX][1]+'</SPAN></FONT></P>'
                  cMenNew += '                    </TH>'
                  cMenNew += '                    <TH WIDTH=400 BGCOLOR="#ffffff">'
                  cMenNew += '                        <P><FONT COLOR="#0099cc"><SPAN STYLE="background: transparent">'+aEmail[nX][2]+'</SPAN></FONT></P>'
                  cMenNew += '                    </TH>'
                  cMenNew += '                </TR>'
                  cMenNew += '            </THEAD>'
                  cMenNew += '        </TABLE>'
              Next
              cMenNew += '        <P><BR><BR>'
              cMenNew += '        </P>'
              cMenNew += '        <TABLE WIDTH=645 BORDER=1 BORDERCOLOR="#0099cc" CELLPADDING=2 CELLSPACING=3>'
              cMenNew += '            <COL WIDTH=633>'
              cMenNew += '            <TR>'
              cMenNew += '                <TD WIDTH=633 BGCOLOR="#0099cc">'
              cMenNew += '                    <P ALIGN=CENTER><FONT COLOR="#ffffff"><FONT FACE="Courier New"><FONT SIZE=4><B>Motivo'
              cMenNew += '                    da Devolu&ccedil;&atilde;o</B></FONT></FONT></FONT></P>'
              cMenNew += '                </TD>'
              cMenNew += '            </TR>'
              cMenNew += '            <TR>'
              cMenNew += '                <TD WIDTH=633 HEIGHT=30>'
              cMenNew += '                    <P ALIGN=LEFT>'+cMotivo+'</P>
              cMenNew += '                </TD>'
              cMenNew += '            </TR>'
              cMenNew += '        </TABLE>
              cMenNew += '        <P><BR>Atenciosamente,<BR>'+cAprNew+'<BR><BR><BR>'
              cMenNew += '        </P>'
              cMenNew += '        <P><EM><FONT SIZE=2>Mensagem gerada Automaticamente pelo Modulo'
              cMenNew += '        SIGAPCP &ndash; Planejamento e Controle de Produ&ccedil;&atilde;o.</FONT></EM></P>'
              cMenNew += '    </BODY>'
              cMenNew += '</HTML>'
       Endif
Return

User Function fBCODBar()
     Local cQry1      := ""        //Variável para montagem da query de pesquisa
     Local cSeqCodBar := ""        //Sequencia do código de barras com 5 digitos
     Local cFixCodBar := "7893866" //Parte Fixa do Código de Barras
     //Local cSeqCheck  := ''        //Checa a sequencia do código de barras
     //Local lBusCod    := .f.       //Valida Busca do código de barras

     If (cNumEmp = '01010101') .OR. (substr(cNumEmp,1,2) == "05")
        cQry1 += "SELECT TOP 1 * "
        cQry1 += "FROM BR_CODBAR XCB WITH (NOLOCK) "
        cQry1 += "WHERE SUBSTRING(XCB.CODIGO, 8, 5) <> XCB.SEQCOD "
        cQry1 += "ORDER BY XCB.CODIGO "
        TCQuery cQry1 ALIAS "TCQ" NEW
        DbSelectArea("TCQ")
        nSeqCod := TCQ->SEQCOD
        DbSelectArea("TCQ")
        DbCloseArea()
        If Empty(nSeqCod)
           cQry1 := ""
           cQry1 += "SELECT COUNT(*) AS QTDCOD "
           cQry1 += "FROM BR_CODBAR XCB WITH (NOLOCK) "
           TCQuery cQry1 ALIAS "TCQ" NEW
           DbSelectArea("TCQ")
           nSeqCod := StrZero(TCQ->QTDCOD + 1, 5)
           DbSelectArea("TCQ")
           DbCloseArea()
        Endif
     Endif
     If Val(nSeqCod) >= 99999
        MsgStop("Código inválido...")
        Return
     Else
        cSeqCodBar := cFixCodBar+nSeqCod
     Endif
     DbSelectArea("SB1")
Return(cSeqCodBar)
