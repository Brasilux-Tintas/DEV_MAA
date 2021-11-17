//#include 'brasilux.ch'
#include "protheus.ch"
#include 'TbiConn.ch'
#include 'topconn.ch'
#include "rwmake.ch"
#xtranslate bSETGET(<uVar>) => { | u | If( PCount() == 0, <uVar>, <uVar> := u ) }
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRSACX02 ºAutor  ³ Luís Gustavo de Souza º Data ³ 02/03/05 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa para gerenciamento do sistema de atendimento ao  -º±±
±±º          ³ consumidor.                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRSACX02()
     Private _CodUsr   := ""
     DbSelectArea("SZQ")
     _CodUsr   := RetCodUsr()
     Private _Rotina   := "BRSACX02  "
     Private _NumEmp   := cNumEmp
     Private _DepUsr   := Posicione("SZW", 4, xFilial("SZW")+_Rotina+_CodUsr+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2), "ZW_DEPTO")
     Private cCadastro := OemToAnsi('Serviço de Atendimento ao Cliente')
     Private lAcsAtv   := Iif(SubStr(Posicione("SZW", 4, xFilial("SZW")+_Rotina+_CodUsr+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2), "ZW_ACESSOS"), 9, 1) == '*', .t., .f.)
     Private lAcsInc   := Iif(SubStr(Posicione("SZW", 4, xFilial("SZW")+_Rotina+_CodUsr+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2), "ZW_ACESSOS"), 1, 1) == '*', .t., .f.)
     Private lAcsRea   := Iif(SubStr(Posicione("SZW", 4, xFilial("SZW")+_Rotina+_CodUsr+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2), "ZW_ACESSOS"), 2, 1) == '*', .t., .f.)
     Private lAcsPar   := Iif(SubStr(Posicione("SZW", 4, xFilial("SZW")+_Rotina+_CodUsr+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2), "ZW_ACESSOS"), 3, 1) == '*', .t., .f.)
     Private lAcsEnc   := Iif(SubStr(Posicione("SZW", 4, xFilial("SZW")+_Rotina+_CodUsr+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2), "ZW_ACESSOS"), 4, 1) == '*', .t., .f.)
     Private lAcsRep   := Iif(SubStr(Posicione("SZW", 4, xFilial("SZW")+_Rotina+_CodUsr+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2), "ZW_ACESSOS"), 5, 1) == '*', .t., .f.)
     Private lAcsDev   := Iif(SubStr(Posicione("SZW", 4, xFilial("SZW")+_Rotina+_CodUsr+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2), "ZW_ACESSOS"), 6, 1) == '*', .t., .f.)
     Private lAcsImp   := Iif(SubStr(Posicione("SZW", 4, xFilial("SZW")+_Rotina+_CodUsr+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2), "ZW_ACESSOS"), 7, 1) == '*', .t., .f.)
     
     Private __SAC_BRASILUX := 1
     
     If !lAcsAtv
        MsgInfo("Usuário sem acesso ao Sistema de SAC", "Atenção...")
        Return
     Endif
     Private aRotina := { { OemToAnsi("&Pesquisar    "), 'AxPesqui'                             , 0, 9},;
                          { OemToAnsi("&Visualiza    "), 'U_SACX02_1(1, __SAC_BRASILUX)        ', 0, 9} }
     If lAcsInc
        aadd(aRotina,     { OemToAnsi("&Atendimento    "), 'U_SACX02_1(2)                      ', 0, 3} )
        aadd(aRotina,     { OemToAnsi("A&ltera         "), 'U_SACX02_1(3, __SAC_BRASILUX)      ', 0, 4} )
        aadd(aRotina,     { OemToAnsi("&Exclui         "), 'U_SACX02_1(4, __SAC_BRASILUX)      ', 0, 9} )
        If lAcsRea
           aadd(aRotina,  { OemToAnsi("&Re-abre        "), 'U_SACX02_1(5, __SAC_BRASILUX)      ', 0, 9} )
        Endif
        aadd(aRotina,     { OemToAnsi("E&ncaminha SAC  "), 'U_FENVSAC (1, __SAC_BRASILUX)      ', 0, 9} )
     Else
        If lAcsRea
           aadd(aRotina,  { OemToAnsi("&Re-abre        "), 'U_SACX02_1(5, __SAC_BRASILUX)      ', 0, 9} )
        Endif
        aadd(aRotina,     { OemToAnsi("E&ncaminha SAC  "), 'U_FENVSAC (1, __SAC_BRASILUX)      ', 0, 9} )
     Endif
     If lAcsPar
        aadd(aRotina,     { OemToAnsi("&Parecer        "), 'U_SACX02_1(6, __SAC_BRASILUX)      ', 0, 9} )
     Endif
     If lAcsEnc
        aadd(aRotina,     { OemToAnsi("En&cerra SAC    "), 'U_SACX02_3()                       ', 0, 9} )
     Endif
     If lAcsRep
        aadd(aRotina,     { OemToAnsi("E-mail Represent."),'U_SACX02_4()                       ', 0, 9} )
     Endif
     aadd(aRotina,        { OemToAnsi("Mostra Pendentes"), 'U_fMSACPn(2, @__SAC_BRASILUX, .t., _DepUsr)', 0, 9} )
     If lAcsImp
        aadd(aRotina,     { OemToAnsi("Imprime SAC")     ,'U_BRSACR01(1)                      ', 0, 9} )
     Endif
     If lAcsDev 
        aadd(aRotina,     { OemToAnsi("Imp. Aut. Devolução"),'U_BRSACR02(1)                      ', 0, 9} )
     Endif
     aadd(aRotina,        { OemToAnsi("Le&genda")        , 'U_SACX02_2(__SAC_BRASILUX)         ', 0, 9} )
            
     Private aCores   := { { "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'A')", 'ENABLE'     },; //SAC com Atendente
                           { "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'D')", 'BR_AZUL'    },; //SAC com Diretoria
                           { "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'C')", 'BR_AMARELO' },; //SAC com Comercial
                           { "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'F')", 'BR_PINK'    },; //SAC com Financeiro
                           { "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'T')", 'BR_MARRON'  },; //SAC com Técnico
                           { "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'E')", 'BR_PRETO'   },; //SAC com Expedição
                           { "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'R')", 'BR_CINZA'   },; //SAC com Recebimento
                           { "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'X')", 'BR_LARANJA' },; //SAC com Final. Atend. Téc.
                           { "(ZQ_STATUS == '2'                     )", 'DISABLE'    } } //SAC encerrado

     DbSelectArea("SZQ")
     DbSetOrder(1)
     mBrowse( 6,1,22,75,"SZQ",,,,,,aCores,,,,,.T.)
Return

/*****************************************************************************************/
/*** SACX02_1 - Rotina de Atendimento / alteração e exclusão de SAC.                   ***/
/*****************************************************************************************/
User Function SACX02_1(xOpc, __SAC_BRASILUX)
     Local cNomCli    := Space(20)                  //Nome do Cliente
     Local cFonCli    := Space(15)                  //Telefone do Cliente
     Local nHisCli    := 0
     Local nOpcG      := 0
     Local nOpcA      := 0
     Local lCont      := .f.
     Local oDlg, oGrp1, oNumSac, oDatSac, oNomCli, oFonCli, oConCli, oTipSac, oNomAte, oHorIni, oHorFim, oHisCli, oDatFim, nY
     Private oCodCli, oDevSac, oCusDev, oCusTot, oCusFre, oCusFin
     Private cNumSac  := Space(6)                   //Numero do Sac
     Private dDatSac  := CTod('  /  /  ')           //Data de emissão do SAC
     Private cTipSac  := Space(1)                   //Tipo do Sac
     Private aTipSac  := {'Reclamação', 'Sugestão'} //Tipo do Sac
     Private aDevSac  := {'Sim', 'Não'}             //Sac de devolução
     Private cConCli  := Space(15)                  //Nome do Contato do Cliente
     Private cNomAte  := Space(15)                  //Nome do Atendente
     Private cHorIni  := Space(8)                   //Hora de Inicio de atendimento
     Private dDatFim  := CTod('  /  /  ')           //Data final do SAC
     Private cHorFim  := Space(8)                   //Hora de Fim de atendimento
     Private cHisCli  := ""                         //Histórico do Cliente
     Private nCusDev  := 0
     Private nCusFre  := 0
     Private nCusFin  := 0
     Private nCusTot  := 0
     Private cDevSac  := Space(1)                   //Sac de devolução
     Private cCodCli  := Space(6)                   //Codigo do Cliente
     Private nOpc     := Iif(xOpc == 5 .or. xOpc == 6, 1, xOpc)
     Private nUsado   := 0
     Private aCols    := {}
     Private aHeader  := {}
     Private aAltGETD := {}
     
     fMonHead()
     fMonCols(nOpc)
     If nOpc == 1
        If xOPC == 6
           If SZQ->ZQ_STATUS == '1'
              If SZQ->ZQ_FLAG == 'A'
                 If !(_DepUsr $ 'ATE.REC')
                    MsgBox("Esse SAC está em outro departamento, não pode ser informado o parecer.", "Atenção...", "STOP")
                    Return
                 Endif
              ElseIf SZQ->ZQ_FLAG == 'D'
                     If !(_DepUsr $ 'DIR')
                        MsgBox("Esse SAC está em outro departamento, não pode ser informado o parecer.", "Atenção...", "STOP")
                        Return
                     Endif
              ElseIf SZQ->ZQ_FLAG == 'C'
                     If !(_DepUsr $ 'COM')
                        MsgBox("Esse SAC está em outro departamento, não pode ser informado o parecer.", "Atenção...", "STOP")
                        Return
                     Endif
              ElseIf SZQ->ZQ_FLAG == 'F'
                     If !(_DepUsr $ 'FIN')
                        MsgBox("Esse SAC está em outro departamento, não pode ser informado o parecer.", "Atenção...", "STOP")
                        Return
                     Endif
              ElseIf SZQ->ZQ_FLAG $ 'T.X'
                     If _DepUsr $ 'FAT'
                        If !Empty(SZQ->ZQ_RESP) 
                           If !(Upper(Alltrim(SZQ->ZQ_RESP)) $ Upper(Alltrim(cUsername)))
                              MsgBox("Usuário não é o responsável por esse SAC.", "Atenção...", "STOP")
                              Return
                           Endif
                        Endif
                     ElseIf _DepUsr $ 'ATC' .or. _DepUsr $ 'TEC'
                        If Empty(SZQ->ZQ_RESP)
                           If !(_DepUsr $ 'ATC')
                              MsgBox("Esse SAC ainda não foi encaminhado pelo Atendimento Técnico.", "Atenção...", "STOP")
                              Return
                           Endif
                        Else
                           If !(Upper(Alltrim(SZQ->ZQ_RESP)) $ Upper(Alltrim(cUsername)))
                              MsgBox("Usuário não é o responsável por esse SAC.", "Atenção...", "STOP")
                              Return
                           Endif
                        Endif
                     ElseIf !(_DepUsr $ 'FAT')
                            MsgBox("Esse SAC está em outro departamento, não pode ser informado o parecer.", "Atenção...", "STOP")
                            Return
                     Else
                        MsgBox("Esse SAC está em outro departamento, não pode ser informado o parecer.", "Atenção...", "STOP")
                        Return
                     Endif
              ElseIf SZQ->ZQ_FLAG == 'E'
                     If !(_DepUsr $ 'EXP')
                        MsgBox("Esse SAC está em outro departamento, não pode ser informado o parecer.", "Atenção...", "STOP")
                        Return
                     Endif
              ElseIf SZQ->ZQ_FLAG == 'R'
                     If !(_DepUsr $ 'REC')
                        MsgBox("Esse SAC está em outro departamento, não pode ser informado o parecer.", "Atenção...", "STOP")
                        Return
                     Endif
              //ElseIf SZQ->ZQ_FLAG == 'X'
              //       
              //          MsgBox("Esse SAC está em outro departamento, não pode ser informado o parecer.", "Atenção...", "STOP")
              //          Return
              //       Endif
              Endif
           Else
              MsgBox("Esse SAC já está encerrado, não pode ser informado o parecer.", "Atenção...", "STOP")
              Return
           Endif
        Endif
     ElseIf nOpc == 3
            If SZQ->ZQ_STATUS == '1'
               If !(Upper(Alltrim(cUsername)) == Upper(Alltrim(SZQ->ZQ_ATENDEN)) .and. (Empty(SZQ->ZQ_RESP) .or. (Upper(Alltrim(cUsername)) <> Upper(Alltrim(SZQ->ZQ_RESP))) ) .and. SZQ->ZQ_FLAG == 'A')
                  If Upper(Alltrim(cUsername)) <> Upper(Alltrim(SZQ->ZQ_ATENDEN))
                     MsgBox("Usuário não é o atendente para esse SAC.", "Atenção...", "STOP")
                     Return
                  Endif
                  If !Empty(SZQ->ZQ_RESP) 
                     If (Upper(Alltrim(cUsername)) <> Upper(Alltrim(SZQ->ZQ_RESP)))
                        MsgBox("Usuário não é o atendente para esse SAC.", "Atenção...", "STOP")
                        Return
                     Else
                        If SZQ->ZQ_FLAG <> 'A'
                           MsgBox("Esse SAC está em outro departamento.", "Atenção...", "STOP")
                           Return
                        Endif
                     Endif
                  Else
                     If SZQ->ZQ_FLAG <> 'A'
                        MsgBox("SAC já tem um responsável.", "Atenção...", "STOP")
                        Return
                     Endif
                  Endif
                  If SZQ->ZQ_FLAG <> 'A'
                     MsgBox("Esse SAC está em outro departamento.", "Atenção...", "STOP")
                     Return
                  Endif
               Endif
            Else
               MsgBox("Esse SAC já está encerrado, não pode ser alterado.", "Atenção...", "STOP")
               Return
            Endif
     ElseIf nOpc == 4
            If SZQ->ZQ_STATUS == '2'
               MsgBox("Esse SAC já está encerrado, não pode ser excluido.", "Atenção...", "STOP")
               Return
            Endif
            If !(Upper(Alltrim(cUsername)) == Upper(Alltrim(SZQ->ZQ_ATENDEN)))
               MsgBox("Usuário não é o atendente desse SAC para excluí-lo.", "Atenção", "STOP")
               Return
            Endif
            If !Empty(SZQ->ZQ_RESP)
               If !(Upper(Alltrim(cUsername)) == Upper(Alltrim(SZQ->ZQ_RESP)))
                  MsgBox("Usuário não é o responsável por esse SAC para excluí-lo.", "Atenção", "STOP")
                  Return
               Endif
            Endif
     ElseIf xOpc == 5
            If SZQ->ZQ_STATUS == '1'
               MsgBox("Esse SAC ainda não foi encerrado para reabrí-lo.", "Atenção...", "STOP")
               Return
            Endif
            If !(Upper(Alltrim(cUsername)) == Upper(Alltrim(SZQ->ZQ_ATENDEN)))
               MsgBox("Usuário não é o atendente desse SAC para reabri-lo.", "Atenção", "STOP")
               Return
            Endif
     Endif

     cNumSac := Iif(nOpc == 2, GetSX8Num("SZQ", "ZQ_NUM"), SZQ->ZQ_NUM )
     //ConfirmSX8()
	 dbselectarea("SA1")
	 dbsetorder(1)
	 dbseek(xFilial("SA1")+SZQ->ZQ_CLIENTE)
     dDatSac := Iif(nOpc == 2, dDataBase                 , SZQ->ZQ_DATA )
     cTipSac := Iif(nOpc == 2, "Reclamação"              , Iif(SZQ->ZQ_TIPOSAC == "1", "Reclamação", "Sugestão") )
     cDevSac := Iif(nOpc == 2, "Não"                     , Iif(SZQ->ZQ_DEVOLV  == "1", "Sim"       , "Não"     ) )
     cCodCli := Iif(nOpc == 2, space(6)                  , SZQ->ZQ_CLIENTE )
     cNomCli := Iif(nOpc == 2, space(20)                 , Posicione("SA1", 1, xFilial("SA1")+SZQ->ZQ_CLIENTE+"01", "A1_NREDUZ") )
     cFonCli := Iif(nOpc == 2, space(15)                 , TRIM(SA1->A1_DDD)+'-'+TRIM(SA1->A1_TEL) )
     cConCli := Iif(nOpc == 2, space(20)                 , Posicione("SA1", 1, xFilial("SA1")+SZQ->ZQ_CLIENTE+"01", "A1_CONTATO") )
     cNomAte := Iif(nOpc == 2, cUsername   , SZQ->ZQ_ATENDEN )
     cHorIni := Iif(nOpc == 2, Time()                    , SZQ->ZQ_HINI )
     dDatFim := Iif(nOpc == 2, Ctod("  /  /  ")          , SZQ->ZQ_DTFIM )
     cHorFim := Iif(nOpc == 2, "  :  :  "                , SZQ->ZQ_HFIM )
     nCusDev := Iif(nOpc == 2, 0                         , SZQ->ZQ_CUSDEV )
     nCusFre := Iif(nOpc == 2, 0                         , SZQ->ZQ_CUSFRE )
     nCusFin := Iif(nOpc == 2, 0                         , SZQ->ZQ_CUSFIN )
     nCusTot := nCusDev + nCusFre + nCusFin

     aAltGETD:= {"ZR_OCORREN", "ZR_PRODUTO", "ZR_QTD", "ZR_PEDIDO", "ZR_NUMNF", "ZR_VUDEV", "ZR_LOTE", "ZR_ITEMDEV", "ZR_OBS"}
     DbSelectArea("SZS")
     DbSetOrder(1)
     DbSeek(xFilial("SZS")+cNumSAC, .t.)
     If Found()
        cHisCli := SZS->ZS_PARECER  //""Iif(nOpc == 2, ""                        , Posicione("SA1", 1, xFilial("SA1")+SZQ->ZQ_CLIENTE, "A1_OBSSAC") )
     Else
        cHisCli := ""
     Endif
     nHisCli := MlCount(cHisCli, 106)
     cNewHis := cHisCli
     cHisCli := ""
     If nHisCli > 0
        For nY := 1 To nHisCli
            cHisCli += MemoLine( cNewHis, 106, nY )+Chr(13)+Chr(10)
        Next
     Endif
     nOpcG    := Iif(nOpc == 2 .or. nOpc == 3, 3, 2)
     cLinOk   := Iif(nOpc == 2 .or. nOpc == 3, "U_fX02_1(oGetDados, nOpc, @oDevSAC, @cDevSAC, @oCusDev, @nCusDev)", "AllwaysTrue()")
     cTudoOk  := Iif(nOpc == 2 .or. nOpc == 3, "U_fX02_2(oGetDados, nOpc)", "AllwaysTrue()")
     cFieldOk := Iif(nOpc == 2 .or. nOpc == 3, "U_fX02_3(oGetDados, nOpc, @oDevSAC, @cDevSAC, @oCodCli, @cCodCli, @oCusDev, @nCusDev, @oCusFre, @nCusFre, @oCusFin, @nCusFin, @oCusTot, @nCusTot)", "AllwaysTrue()")

     DEFINE MSDIALOG oDlg FROM 000,000 TO 450,750 TITLE OemToAnsi(cCadastro)                            PIXEL
            DEFINE FONT oFont1 NAME 'COURIER NEW' SIZE 6,0
            @ 005,005 GROUP oGrp1 TO 054,370 LABEL OemToAnsi("Atendimento")    COLOR CLR_HRED           PIXEL OF oDlg
            /***********************************************************************************/
            @ 011,010 SAY OemToAnsi("Numero:")                     SIZE 025,09 COLOR CLR_HBLUE          PIXEL OF oDlg
            @ 010,040 MSGET oNumSac VAR cNumSac PICTURE "999999"   SIZE 030,09                          PIXEL OF oDlg
            @ 011,095 SAY OemToAnsi("Emissão:")                    SIZE 030,09 COLOR CLR_HBLUE          PIXEL OF oDlg
            @ 010,125 MSGET oDatSac VAR dDatSac                    SIZE 030,09                          PIXEL OF oDlg
            @ 011,200 SAY OemToAnsi("Ocorrência:")                 SIZE 030,09 COLOR CLR_HBLUE          PIXEL OF oDlg
            @ 010,230 MSCOMBOBOX oTipSac VAR cTipSac ITEMS aTipSac SIZE 045,09                          PIXEL OF oDlg
            @ 011,285 SAY OemToAnsi("Devolução:")                  SIZE 030,09 COLOR CLR_HBLUE          PIXEL OF oDlg
            @ 010,315 MSCOMBOBOX oDevSac VAR cDevSac ITEMS aDevSac SIZE 025,09                          PIXEL OF oDlg
            /***********************************************************************************/
            @ 026,010 SAY OemToAnsi("Cliente:")                    SIZE 025,09 COLOR CLR_HBLUE          PIXEL OF oDlg
            @ 025,040 MSGET oCodCli VAR cCodCli PICTURE "999999"   SIZE 030,09                 F3 "CLI" PIXEL OF oDlg
            @ 026,095 SAY OemToAnsi("Nome:")                       SIZE 030,09 COLOR CLR_HBLUE          PIXEL OF oDlg
            @ 025,125 MSGET oNomCli VAR cNomCli PICTURE "@!"       SIZE 070,09                          PIXEL OF oDlg
            @ 026,200 SAY OemToAnsi("Telefone:")                   SIZE 030,09 COLOR CLR_HBLUE          PIXEL OF oDlg
            @ 025,230 MSGET oFonCli VAR cFonCli                    SIZE 050,09                          PIXEL OF oDlg
            @ 026,285 SAY OemToAnsi("Contato:")                    SIZE 030,09 COLOR CLR_HBLUE          PIXEL OF oDlg
            @ 025,315 MSGET oConCli VAR cConCli PICTURE "@!"       SIZE 050,09                          PIXEL OF oDlg
            /***********************************************************************************/
            @ 041,010 SAY OemToAnsi("Atendente:")                  SIZE 030,09 COLOR CLR_HBLUE          PIXEL OF oDlg
            @ 040,040 MSGET oNomAte VAR cNomAte PICTURE "@!"       SIZE 050,09                          PIXEL OF oDlg
            @ 041,095 SAY OemToAnsi("Hr. Inicio:")                 SIZE 030,09 COLOR CLR_HBLUE          PIXEL OF oDlg
            @ 040,125 MSGET oHorIni VAR cHorIni                    SIZE 030,09                          PIXEL OF oDlg
            @ 041,200 SAY OemToAnsi("Data Fim:")                   SIZE 030,09 COLOR CLR_HBLUE          PIXEL OF oDlg
            @ 040,230 MSGET oDatFim VAR dDatFim                    SIZE 030,09                          PIXEL OF oDlg
            @ 041,285 SAY OemToAnsi("Hr. Fim:")                    SIZE 030,09 COLOR CLR_HBLUE          PIXEL OF oDlg
            @ 040,315 MSGET oHorFim VAR cHorFim                    SIZE 030,09                          PIXEL OF oDlg
            /***********************************************************************************/
            @ 055,005 GROUP oGrp2 TO 100,370 LABEL OemToAnsi("Histórico do Cliente")  COLOR CLR_HRED                          PIXEL OF oDlg
            @ 060,010   GET oHisCli VAR cHisCli MEMO READONLY      SIZE 298,35                                                PIXEL OF oDlg FONT oFont1
            @ 165,620 BTNBMP oBtnObs RESOURCE "NOTE"               SIZE 110,24 ACTION fObsCli(1, @oHisCli, @cHisCli, cCodCli) PIXEL OF oDlg
            /***********************************************************************************/
            @ 101,005 GROUP oGrp4 TO 120,370 LABEL OemToAnsi("Custos")                     COLOR CLR_HRED           PIXEL OF oDlg
            @ 107,010 SAY OemToAnsi("Custo Dev.:")                             SIZE 030,09 COLOR CLR_HBLUE          PIXEL OF oDlg
            @ 106,040 MSGET oCusDev VAR nCusDev PICTURE "@E 9,999,999.9999"    SIZE 050,09                          PIXEL OF oDlg
            @ 107,095 SAY OemToAnsi("Custo Frete:")                            SIZE 030,09 COLOR CLR_HBLUE          PIXEL OF oDlg
            @ 106,125 MSGET oCusFre VAR nCusFre PICTURE "@E 9,999,999.9999"    SIZE 050,09                          PIXEL OF oDlg            
            @ 107,200 SAY OemToAnsi("Custo Fin.:")                             SIZE 030,09 COLOR CLR_HBLUE          PIXEL OF oDlg
            @ 106,230 MSGET oCusFin VAR nCusFin PICTURE "@E 9,999,999.9999"    SIZE 050,09                          PIXEL OF oDlg
            @ 107,285 SAY OemToAnsi("Custo Total:")                            SIZE 030,09 COLOR CLR_HBLUE          PIXEL OF oDlg
            @ 106,315 MSGET oCusTot VAR nCusTot PICTURE "@E 9,999,999.9999"    SIZE 050,09                          PIXEL OF oDlg
            /***********************************************************************************/
            @ 121,005 GROUP oGrp3 TO 214,370 LABEL OemToAnsi("Itens")          COLOR CLR_HRED           PIXEL OF oDlg
            oGetDados := MsGetDados():New(126, 010, 209, 365, nOpcG, cLinOk, cTudoOk, "+ZR_SEQITEM", .T., aAltGetD, 3, , 300, cFieldOk)
            /***********************************************************************************/
            If xOpc == 6
               If !(_DepUsr $ 'REC')
                  @ 428,148 BTNBMP oBtnDes RESOURCE "DESTINOS"           SIZE 110,24 ACTION(U_fEnvSAC(2, __SAC_BRASILUX, @oDlg, @lCont))  PIXEL OF oDlg
                  oBtnDes:cCaption := PADR(OemToAnsi("Encaminhar"  ),20)
                  oBtnDes:cToolTip := OemToAnsi("Encaminha atendimento para outro responsável...")
               Else
                  @ 428,148 BTNBMP oBtnDes RESOURCE "NAOCONFO"               SIZE 110,24 ACTION(U_fDevSAC())  PIXEL OF oDlg
                  oBtnDes:cCaption := PADR(OemToAnsi("Devolução"  ),20)
                  oBtnDes:cToolTip := OemToAnsi("Gera nota fiscal de entrada de estoque para devoluções...")
               Endif
               @ 428,268 BTNBMP oBtnPar RESOURCE "EDIT"               SIZE 110,24 ACTION(fMonPar()                                )  PIXEL OF oDlg
               oBtnPar:cCaption := PADR(OemToAnsi("Parecer"  ),20)
               oBtnPar:cToolTip := OemToAnsi("Parecer do atendimento...")
            Endif
            If nOpc <> 2
               @ 428,388 BTNBMP oBtnHis RESOURCE "OBJETIVO"           SIZE 110,24 ACTION(fMosHis()                        )   PIXEL OF oDlg
               oBtnHis:cCaption := PADR(OemToAnsi("Histórico"),20)
               oBtnHis:cToolTip := OemToAnsi("Histórico do atendimento...")
            Endif
            @ 428,508 BTNBMP oBtnCon RESOURCE "OK"                 SIZE 110,24 ACTION(lCont := Iif(oGetDados:TudoOk(), .t., .f.), nOpcA := Iif(lCont, 1, 0), Iif(lCont, oDlg:End(), .f.))   PIXEL OF oDlg
            @ 428,628 BTNBMP oBtnCan RESOURCE "CANCEL"             SIZE 110,24 ACTION(lCont := .t., nOpcA := 0, oDlg:End())   PIXEL OF oDlg

            oDlg:nStyle := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
            If nOpc == 1 .or. nOpc == 4
               oTipSac:bWhen := {||.f.} ; oDevSac:bWhen := {||.f.} ; oCodCli:bWhen := {||.f.} ; oConCli:bWhen := {||.f.}
               oBtnObs:lReadOnly := .t.
            ElseIf nOpc == 3
                   oCodCli:bWhen := {||.f.}
            Endif
            oNumSac:bWhen := {||.f.} ; oDatSac:bWhen := {||.f.} ; oNomCli:bWhen := {||.f.} ; oFonCli:bWhen := {||.f.}
            oNomAte:bWhen := {||.f.} ; oHorIni:bWhen := {||.f.} ; oHorFim:bWhen := {||.f.} ; oDatFim:bWhen := {||.f.}
            oCusDev:bWhen := {||.f.} ; oCusTot:bWhen := {||.f.}
            If _DepUsr == "ATE"
               oCusFin:bWhen := {||.f.} ; oCusFre:bWhen := {||.T.}
               oCusFre:bLostFocus := {||U_fVldFre(nCusDev, @oCusFre, @nCusFre, nCusFin, @oCusTot, @nCusTot) }
            ElseIf _DepUsr == "FIN"
                   oCusFin:bWhen := {||.t.} ; oCusFre:bWhen := {||.f.}
                   oCusFin:bLostFocus := {||U_fVldFre(nCusDev, @oCusFre, @nCusFre, nCusFin, @oCusTot, @nCusTot) }
            Else
               oCusFin:bWhen := {||.f.} ; oCusFre:bWhen := {||.f.}
            Endif
            oTipSAC:bLostFocus := {|| U_fVldTip(@oTipSac, @cTipSAC, @oDevSAC, @cDevSAC) }
            oDevSAC:bLostFocus := {|| U_fVldDev(@oDevSac, @cDevSAC, @oCodCli, @cCodCli) }
            oCodCli:bLostFocus := {|| U_fVldCli(@oCodCli, @cCodCli, @oNomCli, @cNomCli, @oFonCli, @cFonCli, @oConCli, @cConCli, @oHisCli, @cHisCli) }
            oBtnObs:cCaption := PADR(OemToAnsi("Observação"),20)
            oBtnObs:cToolTip := OemToAnsi("Inserir observação...")
            oGetDados:oBrowse:NFreeze := 1
            oBtnCon:cCaption := PADR(OemToAnsi("Confirmar"),20)
            oBtnCon:cToolTip := OemToAnsi("Grava atendimento...")
            oBtnCan:cCaption := PADR(OemToAnsi("Sair"),20)
            oBtnCan:cToolTip := OemToAnsi("Sai do atendimento sem salvar...")
      ACTIVATE MSDIALOG oDlg CENTERED VALID lCont
      If nOpcA == 1
         If xOpc == 2
            ConfirmSX8()
         Endif
         MsgRun(OemToAnsi("Gravando dados do SAC."), OemtoAnsi("Aguarde"), {||fGrvSAC(xOpc)})
         If xOpc == 2 .or. xOpc == 3
            U_FEnvSAC(2, __SAC_BRASILUX)
         Endif
      Endif
      If __SAC_BRASILUX == 2
         U_fMSACPn(2, 1, .f.)
         Return .f.
      Endif
Return

/*****************************************************************************************/
/*** SACX02_2 - Mostra a legenda com cores correspondentes.                            ***/
/*****************************************************************************************/
User Function SACX02_2(__SAC_BRASILUX)
     Local cCadastro := OemToAnsi('Serviço de Atendimento ao Cliente')
     BrwLegenda(cCadastro,"Status",{ {"ENABLE"     ,"Atendimento"            } ,;
                                     {"BR_AZUL"    ,"Análise Diretoria"      } ,;
                                     {"BR_AMARELO" ,"Análise Comercial"      } ,;
                                     {"BR_PINK"    ,"Análise Financeira"     } ,; 
                                     {"BR_MARRON"  ,"Análise Técnica"        } ,;
                                     {"BR_PRETO"   ,"Análise Expedição"      } ,;
                                     {"BR_CINZA"   ,"Análise Recebimento"    } ,;
                                     {"BR_LARANJA" ,"Análise Técnica(Final)" } ,;
                                     {"DISABLE"    ,"Encerrado"              } })
     If __SAC_BRASILUX == 2
        U_fMSACPn(2, 1, .f.)
        Return .f.
     Endif
Return(.t.)

User Function SACX02_3()
     If SZQ->ZQ_STATUS == '2'
        ApMsgStop("Esse SAC já se encontra encerrado.", "Atenção")
        Return(.f.)
     Else
        If _DepUsr $ 'ATE.FIN'
           If Empty(SZQ->ZQ_RESP)
              If !SubStr(Alltrim(_DepUsr), 1, 1) == SZQ->ZQ_FLAG
                 ApMsgStop("Esse SAC está em outro departamento.", "Atenção")
                 Return(.f.)
              Endif
           Else
              If !Upper(Alltrim(cUsername)) == Upper(Alltrim(SZQ->ZQ_RESP))
                 ApMsgStop("Esse SAC está com outro responsável.", "Atenção")
                 Return(.f.)
              Endif
           Endif
        Else
           ApMsgStop("Esse departamento não está autorizado a encerrar SAC.", "Atenção")
           Return(.f.)
        Endif
     Endif
     fMonPar('FIM')
Return

/*************************************************************************************/
/*** FVLDCLI - Validação do campo codigo do cliente.                               ***/
/*************************************************************************************/
User Function fVldCli(oCodCli, cCodCli, oNomCli, cNomCli, oFonCli, cFonCli, oConCli, cConCli, oHisCli, cHisCli)
     If Empty(cCodCli)
        MsgStop("Código não pode ser vazio ?", "Atenção")
        oCodCli:SetFocus(.t.)
        Return(.f.)
     Else
		dbselectarea("SA1")
		dbsetorder(1)
		dbseek(xFilial("SA1")+cCodCli)
        cNomCli := SA1->A1_NREDUZ
        cFonCli := TRIM(SA1->A1_DDD)+'-'+RTRIM(SA1->A1_TEL)
        cConCli :=SA1->A1_CONTATO
        //cHisCli := SA1->A1_OBSSAC
        //nHisCli := MlCount(cHisCli, 106)
        //cNewHis := cHisCli
        //cHisCli := ""
        //If nHisCli > 0
        //   For nY := 1 To nHisCli
        //       cHisCli += MemoLine( cNewHis, 106, nY )+Chr(13)+Chr(10)
        //   Next
        //Endif
        oNomCli:Refresh() ; oFonCli:Refresh() ; oConCli:Refresh() //; oHisCli:Refresh()
     Endif
Return

/*************************************************************************************/
/*** FVLDTIP - Validação do campo tipo do SAC                                      ***/
/*************************************************************************************/
User Function fVldTip(oTipSac, cTipSac, oDevSac, cDevSac)
     If Empty(cTipSac)
        oTipSAC:SetFocus(.t.)
        Return(.f.)
     Else
        oDevSac:SetFocus(.t.)
        oTipSac:Refresh() ; oDevSac:Refresh()
     Endif
Return

/*************************************************************************************/
/*** FVLDDEV - Validação do campo devolução do SAC                                 ***/
/*************************************************************************************/
User Function fVldDev(oDevSac, cDevSac, oCodCli, cCodCli)
     If Empty(cDevSac)
        oDevSAC:SetFocus(.t.)
        Return(.f.)
     Else
        oCodCli:SetFocus(.t.)
        oDevSac:Refresh()
     Endif
Return

/*************************************************************************************/
/*** FVLDFRE - Validação do campo custo de frete.                                  ***/
/*************************************************************************************/
User Function fVldFre(nCusDev, oCusFre, nCusFre, nCusFin, oCusTot, nCusTot)
     nCusTot := nCusDev + nCusFre + nCusFin
     oCusTot:Refresh()
     oCusFre:Refresh()
Return

/*************************************************************************************/
/*** FVLDFIN - Validação do campo custo financeiro.                                ***/
/*************************************************************************************/
User Function fVldFin(nCusDev, nCusFre, oCusFin, nCusFin, oCusTot, nCusTot)
     nCusTot := nCusDev + nCusFre + nCusFin
     oCusTot:Refresh()
     oCusFin:Refresh()
Return

/*************************************************************************************/
/*** FOBSCLIE - Observação no SAC.                                                 ***/
/*************************************************************************************/
Static Function fObsCli(nOpc, oHisCli, cHisCli, cCodCli)
       Local nOpcB   := 0
       Local cObsCli := cHisCli
       If nOpc == 1
          If Empty(cCodCli)
             MsgBox("Informe inicialmente o código do cliente!", "Informação", "INFO")
             Return
          Endif
       Endif
       DEFINE MSDIALOG oDlg1 TITLE OemToAnsi("Observação no Pedido") FROM 000,000 TO 010,049 OF oMainWnd
              @ 015,002 GROUP oGrp1 TO 074,191 LABEL  OemToAnsi('Observação')           PIXEL OF oDlg1
              @ 020,005 GET oObsCli VAR cObsCli  MEMO             SIZE 183,047          PIXEL OF oDlg1
              oDlg1:nStyle       := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
       ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1, {|| oDlg1:End(), nOpcB := 1 }, {|| oDlg1:End(), nOpcB := 0 } ) CENTERED
       If nOpcB == 1
          If nOpc == 1
             //cAuxObs := cHisCli
             //cHisCli := Upper(Alltrim(cUsername))+" ("+dToc(dDataBase)+" "+Time()+"):"+Chr(13)+chr(10)
             //cHisCli += Upper(Alltrim(cObsCli))+Chr(13)+chr(10)+Chr(13)+chr(10)
             cHisCli := Upper(Alltrim(cObsCli))
          Endif
       Endif
Return

/*****************************************************************************************/
/*** fMonHead - Rotina para montar aHeader da GetDados.                                ***/
/*****************************************************************************************/
Static Function fMonHead()
       Local _lOpen     := .F. //LGS#20200211 - Adequação para release 12.1.25
       Local _cAliasSX3 := GetNextAlias() //LGS#20200211 - Adequação para release 12.1.25

       // ABERTURA DO DICIONÁRIO SX3 - LGS#20200211 - Adequação para release 12.1.25
       OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
       _lOpen := Select( _cAliasSX3 ) > 0
       If !_lOpen //LGS#20200211 - Adequação para release 12.1.25
          MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
          Return
       Endif

       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 11/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*DbSelectArea("SX3")
       DbSetOrder(1)
       DbSeek("SZR")
       While !Eof() .And. (X3_ARQUIVO == "SZR")
             If X3USO(X3_USADO) .And. cNivel >= X3_NIVEL .And. !(TRIM(X3_CAMPO) $ "ZR_FILIAL")
                nUsado += 1
                AADD(aHeader, { Trim(X3_TITULO), X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )
             EndIf
             DbSkip()
       Enddo*/
       DbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( DbSetOrder(1) )
       ( _cAliasSX3 )->( DbSeek("SZR") )
       While !Eof() .And. ( ( _cAliasSX3 )->( X3_ARQUIVO ) == "SZR" )
             If X3USO( ( _cAliasSX3 )->( X3_USADO ) ) .And. cNivel >= ( _cAliasSX3 )->( X3_NIVEL ) .And. !( TRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) $ "ZR_FILIAL" )
                nUsado += 1
                AADD(aHeader, { Trim( ( _cAliasSX3 )->( X3_TITULO ) ), ( _cAliasSX3 )->( X3_CAMPO ), ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), ( _cAliasSX3 )->( X3_VALID ), ( _cAliasSX3 )->( X3_USADO ), ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_ARQUIVO ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
             EndIf
             DbSkip()
       Enddo
       /********************************************************************************************************************************/
       DbSelectArea( _cAliasSX3 )
       DbCloseArea()
Return

/*****************************************************************************************/
/*** fMonCols - Rotina para montar o aCols da GetDados.                                ***/
/*****************************************************************************************/
Static Function fMonCols(nOpc)
       //Local nPosSeqItem := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_SEQITEM" } )
       //Local nPosOcor    := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_OCORREN" } )
       //Local nPosDescOco := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_DESCOCO" } ) 
       //Local nPosProd    := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_PRODUTO" } ) 
       //Local nPosDescPro := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_DESCPRO" } )
       //Local nPosQtd     := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_QTD"     } )
       //Local nPosPed     := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_PEDIDO"  } )
       //Local nPosNumnf   := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_NUMNF"   } )
       //Local nPosLote    := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_LOTE"    } )
       //Local nPosDtVal   := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_DTVALID" } )
       //Local nPosItdev   := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_ITEMDEV" } )
       //Local nPosobs     := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_OBS"     } )
       Local _nI

       If nOpc == 2
          aCols := {}
          aCols := {Array(nUsado+1)}
          aCols[1][nUsado+1] := .F.
          For _ni := 1 To nUsado
              aCols[1][_ni] := CriaVar(aHeader[_ni][2])
              If AllTrim(aHeader[_ni][2]) == "ZR_SEQITEM"
                 aCols[1][_ni] := "01"
              Endif       
          Next
       Else
          DbSelectArea("SZR")
          DbSetOrder(1)
          DbSeek(xFilial("SZR")+SZQ->ZQ_NUM, .t.)
          If Found()
             While !Eof() .AND. SZQ->ZQ_NUM == SZR->ZR_NUM
                   AADD(aCols, Array(nUsado+1) )
                   For _ni := 1 To nUsado
                       If AllTrim(aHeader[_ni][2]) == "ZR_SEQITEM"                    // 01
                          aCols[Len(aCols)][_ni] := SZR->ZR_SEQITEM
                       ElseIf AllTrim(aHeader[_ni][2]) == "ZR_ASSUNTO"                // 02
                              aCols[Len(aCols)][_ni] := SZR->ZR_ASSUNTO
                       ElseIf AllTrim(aHeader[_ni][2]) == "ZR_OCORREN"                // 03
                          aCols[Len(aCols)][_ni] := SZR->ZR_OCORREN
                       ElseIf AllTrim(aHeader[_ni][2]) == "ZR_DESCOCO"                // 04
                              aCols[Len(aCols)][_ni] := Posicione("SU9", 1, xFilial("SU9")+SZR->ZR_ASSUNTO+SZR->ZR_OCORREN, "U9_DESC")
                       ElseIf AllTrim(aHeader[_ni][2]) == "ZR_PRODUTO"                // 05
                              aCols[Len(aCols)][_ni] := SZR->ZR_PRODUTO
                       ElseIf AllTrim(aHeader[_ni][2]) == "ZR_DESCPRO"                // 06
                              aCols[Len(aCols)][_ni] := Posicione("SB1", 1, xFilial("SB1")+SZR->ZR_PRODUTO, "B1_DESC")
                       ElseIf AllTrim(aHeader[_ni][2]) == "ZR_QTD"                    // 07
                              aCols[Len(aCols)][_ni] := SZR->ZR_QTD
                       ElseIf AllTrim(aHeader[_ni][2]) == "ZR_QTDORIG"                // 08
                              aCols[Len(aCols)][_ni] := SZR->ZR_QTDORIG
                       ElseIf AllTrim(aHeader[_ni][2]) == "ZR_PEDIDO"                 // 09
                              aCols[Len(aCols)][_ni] := SZR->ZR_PEDIDO 
                       ElseIf AllTrim(aHeader[_ni][2]) == "ZR_NUMNF"                  // 10
                              aCols[Len(aCols)][_ni] := SZR->ZR_NUMNF
                       ElseIf AllTrim(aHeader[_ni][2]) == "ZR_VUORI"                  // 11
                              aCols[Len(aCols)][_ni] := SZR->ZR_VUORI
                       ElseIf AllTrim(aHeader[_ni][2]) == "ZR_VTORI"                  // 12
                              aCols[Len(aCols)][_ni] := SZR->ZR_VTORI
                       ElseIf AllTrim(aHeader[_ni][2]) == "ZR_VUDEV"                  // 13
                              aCols[Len(aCols)][_ni] := SZR->ZR_VUDEV
                       ElseIf AllTrim(aHeader[_ni][2]) == "ZR_VTDEV"                  // 14
                              aCols[Len(aCols)][_ni] := (SZR->ZR_VUDEV * SZR->ZR_QTD)
                       ElseIf AllTrim(aHeader[_ni][2]) == "ZR_LOTE"                   // 15
                              aCols[Len(aCols)][_ni] := SZR->ZR_LOTE
                       ElseIf AllTrim(aHeader[_ni][2]) == "ZR_DTVALID"                // 16
                              aCols[Len(aCols)][_ni] := SZR->ZR_DTVALID
                       ElseIf AllTrim(aHeader[_ni][2]) == "ZR_QTDPRO"                 // 17
                              aCols[Len(aCols)][_ni] := SZR->ZR_QTDPRO
                       ElseIf AllTrim(aHeader[_ni][2]) == "ZR_RETEN"                  // 18
                              aCols[Len(aCols)][_ni] := SZR->ZR_RETEN
                       ElseIf AllTrim(aHeader[_ni][2]) == "ZR_ITEMDEV"                // 19
                              aCols[Len(aCols)][_ni] := SZR->ZR_ITEMDEV
                       ElseIf AllTrim(aHeader[_ni][2]) == "ZR_OBS"                    // 20
                              aCols[Len(aCols)][_ni] := SZR->ZR_OBS
                       Endif
                   Next
                   aCols[Len(aCols)][nUsado+1]:=.F.
                   DbSelectArea("SZR")
                   DbSkip()
             EndDo
          Else
             AADD(aCols, Array(nUsado+1))
             For _ni := 1 To nUsado
                 aCols[LEN(aCols)][_ni] := CriaVar(aHeader[_ni][2])
                 If AllTrim(aHeader[_ni][2]) == "ZR_SEQITEM"
                    aCols[1][_nI] := "01"
                 Endif       
             Next
             aCols[LEN(aCols)][nUsado+1]:=.F.  
          Endif  
       Endif
Return

/*****************************************************************************************/
/*** fX02_1 - Rotina para validação da GetDados na mudança de linhas.                  ***/
/*****************************************************************************************/
User Function fX02_1(oGetD, nOpc, oDevSAC, cDevSAC, oCusDev, nCusDev)
     Local lRet := .t.
     Local nPosPro := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_PRODUTO" } ) // 04
     Local nPosQtd := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_QTD"     } ) // 06
     Local nPosVUD := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_VUDEV"   } ) // 13     
     Local nPosIDv := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_ITEMDEV" } ) // 19
     Local nY     
     
     If nOpc == 2 .or. nOpc == 3 // 2 = INCLUSAO ; 3 = ALTERACAO
        If !aCols[n][Len(aHeader)+1]
           If !Empty(aCols[n][nPosPro])
              If aCols[n][nPosQtd] <= 0
                 MsgBox("Quantidade não pode ser menor ou igual a zero!", "Atenção...", "ALERT")
                 DbSelectArea("SZR")
                 Return(.f.)
              Endif
           Else
              MsgBox("Código do produto não pode ser vazio!", "Atenção...", "ALERT")
              DbSelectArea("SZR")
              Return(.f.)
           Endif
        Else                          
           lRet  := .t.
        Endif
        nCusDev := 0
        nCusTot := 0
        nQtdS   := 0
        For nY := 1 To Len(aCols)
            If !aCols[nY][Len(aHeader)+1]
               If SubStr(aCols[nY][nPosIDv], 1, 1) == '1'
                  nCusDev += aCols[nY][nPosQtd] * aCols[nY][nPosVUD]
                  nCusTot += aCols[nY][nPosQtd] * aCols[nY][nPosVUD]
                  nQtdS += 1
               Endif
            Endif
        Next
        cDevSAC := Iif(nQtdS == 0, "Não", "Sim")
        nCusTot += (nCusFre + nCusFin)
        oCusTot:Refresh()
        oCusDev:Refresh()
        oDevSAC:Refresh()
     Endif
     DbSelectArea("SZR")
Return(lRet)

/*****************************************************************************************/
/*** fSACX02_2 - Rotina para validação da total da GetDados.                           ***/
/*****************************************************************************************/
User Function fX02_2(oGetD, nOpc)
     lRet := .T.
Return(lRet)

/*****************************************************************************************/
/*** fSACX02_3 - Rotina para validação da GetDados na alteração de campos.             ***/
/*****************************************************************************************/
User Function fX02_3(oGetD, nOpc, oDevSAC, cDevSAC, oCodCli, cCodCli, oCusDev, nCusDev, oCusFre, nCusFre, oCusFin, nCusFin, oCusTot, nCusTot)
     Local lRet       := .t.
     Local oDlg, nY
     Local nOpcb      := 0
     Local _lOpen     := .F. //LGS#20200211 - Adequação para release 12.1.25
     Local _cAliasSX3 := GetNextAlias() //LGS#20200211 - Adequação para release 12.1.25
     Local oTempTbl01

     // ABERTURA DO DICIONÁRIO SX3 - LGS#20200211 - Adequação para release 12.1.25
     OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
     _lOpen := Select( _cAliasSX3 ) > 0
     If !_lOpen //LGS#20200211 - Adequação para release 12.1.25
        MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
        Return
     Endif

     If nOpc == 2 .or. nOpc == 3
        nPosSIt := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_SEQITEM" } ) // 01
        nPosAss := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_ASSUNTO" } ) // 02
        nPosOco := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_OCORREN" } ) // 03
        nPosDOc := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_DESCOCO" } ) // 04
        nPosPro := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_PRODUTO" } ) // 05
        nPosDPr := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_DESCPRO" } ) // 06
        nPosQtd := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_QTD"     } ) // 07
        nPosQtO := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_QTDORIG" } ) // 08
        nPosPed := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_PEDIDO"  } ) // 09
        nPosNNF := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_NUMNF"   } ) // 10
        nPosVUO := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_VUORI"   } ) // 11
        nPosVUT := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_VTORI"   } ) // 12
        nPosVUD := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_VUDEV"   } ) // 13
        nPosVTD := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_VTDEV"   } ) // 14
        nPosLot := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_LOTE"    } ) // 15
        nPosDtV := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_DTVALID" } ) // 16
        nPosQPR := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_QTDPRO"  } ) // 17
        nPosRet := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_RETEN"   } ) // 18
        nPosIDv := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_ITEMDEV" } ) // 19
        nPosobs := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_OBS"     } ) // 20

        If oGetD == Nil
           oDlg := GetWndDefault()
           oDlg := oGetD:oWnd
        Endif
        If __ReadVar $ "M->ZR_OCORREN"
           If !Empty(M->ZR_OCORREN)
              DbSelectArea("SU9")
              DbSetOrder(1)
              If !DbSeek(xFilial("SU9")+SU9->U9_ASSUNTO+M->ZR_OCORREN, .t.)
                 MsgBox("Ocorrência não Cadastrada.","Atenção","ALERT")
                 Return(.F.)
              Else
                 aCols[n][nPosAss] := SU9->U9_ASSUNTO
                 aCols[n][nPosOco] := SU9->U9_CODIGO
                 aCols[n][nPosDOc] := SU9->U9_DESC
                 aCols[n][nPosIDv] := Iif(SubStr(cDevSac,1 ,1) == "S", "1", "2")
              Endif
           Else
              MsgBox("Ocorrência não pode em Branco.","Atenção","ALERT")
              Return(.F.)
           Endif
           oGetDados:oBrowse:Refresh()
           DbSelectArea("SU9")
           DbGoTop()
        ElseIf __ReadVar $ "M->ZR_PRODUTO"
               If !Empty(M->ZR_PRODUTO)
                  DbSelectarea( "SB1" )
                  DbSetorder(1)
                  If !(DbSeek(xFilial("SB1")+M->ZR_PRODUTO,.t.))
                     MsgBox("Produto não Cadastrado.","Atenção","ALERT")
                     Return(.F.)
                  Endif
                  aStru := {}
                  aHead := {}
                  
                  /********************************************************************************************************************************/
                  /*** BLOCO ALTERADO EM 11/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
                  /*DbSelectArea("SX3")
                  DbSetOrder(2)
                  aadd(aStru, {"TMP_OK"    , "C"         , 2              , 0               } ) 
                  MsSeek("D2_ITEM")
                  aadd(aStru, {"TMP_ITEM"  , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
                  MsSeek("D2_DOC")
                  aadd(aStru, {"TMP_DOC"   , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
                  MsSeek("D2_QUANT")
                  aadd(aStru, {"TMP_QUANT" , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
                  MsSeek("D2_EMISSAO")
                  aadd(aStru, {"TMP_EMISS" , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
                  MsSeek("D2_PRCVEN")
                  aadd(aStru, {"TMP_PRCVEN", SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
                  MsSeek("D2_TOTAL")
                  aadd(aStru, {"TMP_TOTAL" , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )*/
               
                  DbSelectArea( _cAliasSX3 )
                  ( _cAliasSX3 )->( DbSetOrder(2) )
                  aadd(aStru, {"TMP_OK"    , "C"         , 2              , 0               } ) 
                  MsSeek("D2_ITEM")
                  aadd(aStru, {"TMP_ITEM"  , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
                  MsSeek("D2_DOC")
                  aadd(aStru, {"TMP_DOC"   , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
                  MsSeek("D2_QUANT")
                  aadd(aStru, {"TMP_QUANT" , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
                  MsSeek("D2_EMISSAO")
                  aadd(aStru, {"TMP_EMISS" , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
                  MsSeek("D2_PRCVEN")
                  aadd(aStru, {"TMP_PRCVEN", ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
                  MsSeek("D2_TOTAL")
                  aadd(aStru, {"TMP_TOTAL" , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
                  /********************************************************************************************************************************/

                  aadd(aHead, {"TMP_OK"    , "", ""                    , ""                           } )
                  aadd(aHead, {"TMP_ITEM"  , "", RetTitle("D2_ITEM")   , PesqPict("SD2","D2_ITEM")    } )
                  aadd(aHead, {"TMP_DOC"   , "", RetTitle("D2_DOC")    , PesqPict("SD2","D2_DOC")     } )
                  aadd(aHead, {"TMP_QUANT" , "", RetTitle("D2_QUANT")  , PesqPict("SD2","D2_QUANT")   } )
                  aadd(aHead, {"TMP_EMISS" , "", RetTitle("D2_EMISSAO"), PesqPict("SD2","D2_EMISSAO") } )
                  aadd(aHead, {"TMP_PRCVEN", "", RetTitle("D2_PRCVEN") , PesqPict("SD2","D2_PRCVEN")  } )
                  aadd(aHead, {"TMP_TOTAL" , "", RetTitle("D2_TOTAL")  , PesqPict("SD2","D2_TOTAL")   } )

                  /********************************************************************************************************************************/
                  /*** BLOCO ALTERADO EM 11/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
                  cArqTmp := GetNextAlias()
                  //cArqTmp := CriaTrab(aStru, .t.)
                  //dbUseArea(.T., __LocalDrive, cArqTmp, cArqTmp, .F., .F.)
                  oTempTbl01 := FWTemporaryTable():New( cArqTmp )
                  oTempTbl01:SetFields( aStru )
                  oTempTbl01:Create()
                  /********************************************************************************************************************************/
                  cQry1 := ""
                  cQry1 += "SELECT SD2.D2_ITEM, SD2.D2_DOC, SD2.D2_QUANT, SD2.D2_EMISSAO, SD2.D2_COD, SD2.D2_PRCVEN, SD2.D2_TOTAL "
                  cQry1 += "FROM "+RetSqlName("SD2")+" SD2 "
                  cQry1 += "WHERE SD2.D2_FILIAL  = '"+xFilial("SD2")+"' "
                  cQry1 += "  AND SD2.D_E_L_E_T_ = '' "
                  cQry1 += "  AND SD2.D2_CLIENTE = '"+cCodCli+"' "
                  cQry1 += "  AND SD2.D2_COD     = '"+SB1->B1_COD+"' "
                  cQry1 += "ORDER BY SD2.D2_EMISSAO DESC "
                  TCQuery cQry1 ALIAS "TCQ" NEW
               
                  DbSelectArea("TCQ")
                  DbGoTop()
                  While !Eof()
                        If aScan(aCols, {|x| x[nPosNNF]+x[nPosPro] = TCQ->D2_DOC+TCQ->D2_COD }) == 0 .or. aCols[aScan(aCols, {|x| x[nPosNNF]+x[nPosPro] = TCQ->D2_DOC+TCQ->D2_COD })][Len(aHeader)+1]
                           RecLock(cArqTmp, .t.)
                              (cArqTmp)->TMP_OK     := "  "
                              (cArqTmp)->TMP_ITEM   := TCQ->D2_ITEM
                              (cArqTmp)->TMP_DOC    := TCQ->D2_DOC
                              (cArqTmp)->TMP_QUANT  := TCQ->D2_QUANT
                              (cArqTmp)->TMP_EMISS  := CtoD(SubStr(TCQ->D2_EMISSAO, 7, 2)+'/'+SubStr(TCQ->D2_EMISSAO, 5, 2)+'/'+SubStr(TCQ->D2_EMISSAO, 1, 4))
                              (cArqTmp)->TMP_PRCVEN := TCQ->D2_PRCVEN
                              (cArqTmp)->TMP_TOTAL  := TCQ->D2_TOTAL
                           MsUnLock()
                        Endif
                        DbSelectArea("TCQ")
                        DbSkip()
                  Enddo
                  DbSelectArea("TCQ")
                  DbCloseArea()
                  DbSelectArea(cArqTmp)
                  DbGoTop()
                  If RecCount() > 0
                     DEFINE MSDIALOG oDlgPro FROM 000,000 TO 020,050 TITLE OemToAnsi("Produto x Cliente") OF oMainWnd 
                            oSelNF                     := MsSelect():New(cArqTmp, "TMP_OK", , aHead, .F., "XX", {015, 001, 150, 197}, , , oDlgPro )
                            oSelNF:oBrowse:lCanAllMark := .F.
                            oSelNF:bMark               := {|| fMrkDis(1) }
                            oDlgPro:nStyle             := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
                     ACTIVATE MSDIALOG oDlgPro ON INIT EnchoiceBar(oDlgPro, { ||nOpcb:=1, oDlgPro:End() }, {||nOpcb := 0, oDlgPro:End() },,) CENTERED
                     If nOpcb == 1
                        aCols[n][nPosPro] := SB1->B1_COD
                        aCols[n][nPosDPr] := SB1->B1_DESC
                        aCols[n][nPosPed] := space(06)
                        aCols[n][nPosNNF] := space(06)
                        aCols[n][nPosQtO] := 0
                        aCols[n][nPosQtd] := 0
                        aCols[n][nPosVUO] := 0
                        aCols[n][nPosVUT] := 0
                        DbSelectArea(cArqTmp)
                        DbGoTop()
                        While !Eof()
                              If Marked("TMP_OK")
                                 If aCols[n][nPosQtO] <= 0
                                    aCols[n][nPosPro] := SB1->B1_COD
                                    aCols[n][nPosDPr] := SB1->B1_DESC
                                    aCols[n][nPosPed] := Posicione("SF2", 1, xFilial("SF2")+(cArqTmp)->TMP_DOC, "F2_PEDIDO")
                                    aCols[n][nPosNNF] := (cArqTmp)->TMP_DOC
                                    aCols[n][nPosQtO] := (cArqTmp)->TMP_QUANT
                                    aCols[n][nPosQtd] := 0
                                    aCols[n][nPosVUO] := (cArqTmp)->TMP_PRCVEN
                                    aCols[n][nPosVUT] := (cArqTmp)->TMP_TOTAL 
                                    aCols[n][nPosVUD] := 0
                                    aCols[n][nPosVTD] := 0
                                    aCols[n][nPosLot] := space(06)
                                    aCols[n][nPosDtV] := cTod("  /  /  ")
                                    aCols[n][nPosQPR] := 0.0
                                    aCols[n][nPosRET] := space(06)
                                    aCols[n][nPosOBS] := space(300)
                                 Else
                                    cSeqItem := StrZero((Val(aCols[Len(aCols)][nPosSIt]) + 1), 2)
                                    cCodOcor := aCols[n][nPosOco]
                                    cDescOco := aCols[n][nPosDOc]
                                    cCodProd := aCols[n][nPosPro]
                                    cDescPro := aCols[n][nPosDPr]
                                    nQuantid := CriaVar(aHeader[nPosQtd][2])
                                    nQtdOrig := (cArqTmp)->TMP_QUANT
                                    cNumPedi := Posicione("SF2", 1, xFilial("SF2")+(cArqTmp)->TMP_DOC, "F2_PEDIDO")
                                    cNumNFis := (cArqTmp)->TMP_DOC
                                    cNumLote := CriaVar(aHeader[nPosLot][2])
                                    cDataVal := CriaVar(aHeader[nPosDtV][2])
                                    cItemDev := cDevSAC
                                    cObserva := CriaVar(aHeader[nPosobs][2])
                                 Endif
                              Endif
                              DbSelectArea(cArqTmp)
                              DbSkip()
                        EndDo
                     Else
                        aCols[n][nPosPro] := SB1->B1_COD
                        aCols[n][nPosDPr] := SB1->B1_DESC
                        aCols[n][nPosQtd] := 0
                        aCols[n][nPosQtO] := 0
                        aCols[n][nPosPed] := space(06)
                        aCols[n][nPosNNF] := space(06)
                        aCols[n][nPosVUO] := 0
                        aCols[n][nPosVUT] := 0
                        aCols[n][nPosVUD] := 0
                        aCols[n][nPosVTD] := 0
                        aCols[n][nPosLot] := space(06)
                        aCols[n][nPosDtV] := cTod("  /  /  ")
                        aCols[n][nPosQPR] := 0.0
                        aCols[n][nPosRET] := space(06)
                        aCols[n][nPosOBS] := space(300)
                     Endif
                  Else  //Se não encontrada nenhuma NF que esteja amarrado o Cliente x Produto
                     aCols[n][nPosPro] := SB1->B1_COD
                     aCols[n][nPosDPr] := SB1->B1_DESC
                     aCols[n][nPosQtd] := 0
                     aCols[n][nPosQtO] := 0
                     aCols[n][nPosPed] := space(06)
                     aCols[n][nPosNNF] := space(06)
                     aCols[n][nPosVUO] := 0
                     aCols[n][nPosVUT] := 0
                     aCols[n][nPosLot] := space(06)
                     aCols[n][nPosDtV] := cTod("  /  /  ")
                  Endif
                  DbSelectArea( cArqTmp )
                  DbCloseArea()
                  oTempTbl01:Delete()
               Else
                  MsgBox("Produto não pode ser em Branco.","Atenção","ALERT")
                  Return(.F.)
               Endif
               oGetDados:oBrowse:Refresh()
        ElseIf __ReadVar $ "M->ZR_QTD"
               If aCols[n][nPosQtO] > 0
                  If M->ZR_QTD > aCols[n][nPosQtO]
                     MsgBox("Atenção, quantidade devolvida não pode ser maior que quantidade original da NF.", "Atenção", "STOP")
                     aCols[n][nPosQtd] := 0
                     Return(.f.)
                  Endif
                  aCols[n][nPosQtd] := M->ZR_QTD
                  nCusDev           := 0
                  nCusTot           := 0
                  nQtdS             := 0
                  For nY := 1 To Len(aCols)
                      If !aCols[nY][Len(aHeader)+1]
                         If SubStr(aCols[nY][nPosIDv], 1, 1) == '1'
                            nCusDev += aCols[nY][nPosQtd] * aCols[nY][nPosVUD]
                            nCusTot += aCols[nY][nPosQtd] * aCols[nY][nPosVUD]
                            nQtdS += 1
                         Endif
                      Endif
                  Next
                  cDevSAC := Iif(nQtdS == 0, "Não", "Sim")
                  nCusTot += (nCusFre + nCusFin)
                  oCusTot:Refresh()
                  oDevSAC:Refresh()
                  oCusDev:Refresh()
               Endif
               aCols[n][nPosQtd] := M->ZR_QTD
               aCols[n][nPosVTD] := aCols[n][nPosQtd] * aCols[n][nPosVUD]
               oGetDados:oBrowse:Refresh()
        ElseIf __ReadVar $ "M->ZR_PEDIDO"
               If aCols[n][nPosQtO] > 0
                  aCols[n][nPosPed] := aCols[n][nPosPed]
                  M->ZR_PEDIDO      := aCols[n][nPosPed]
               Else
                  If SubStr(Alltrim(aCols[n][nPosPro]), 1, 3) $ "DIV"
                     If !Posicione("SC5", 3, xFilial("SC5")+cCodCli+'01'+M->ZR_PEDIDO, "C5_NUM") == M->ZR_PEDIDO
                        MsgBox("Pedido X Cliente inválido!", "Atenção", "ALERT")
                        Return(.f.)
                     Else
                        aCols[n][nPosPed] := M->ZR_PEDIDO
                        aCols[n][nPosQtd] := 0
                        aCols[n][nPosNNF] := Posicione("SC5", 3, xFilial("SC5")+cCodCli+'01'+M->ZR_PEDIDO, "C5_NOTA")
                        aCols[n][nPosQtO] := 0
                        aCols[n][nPosVUO] := 0
                        aCols[n][nPosVUT] := 0
                     Endif
                  Else
                     If !Posicione("SC6", 2, xFilial("SC6")+aCols[n][nPosPro]+M->ZR_PEDIDO, "C6_NUM") == M->ZR_PEDIDO
                        MsgBox("Produto x Pedido X Cliente inválido!", "Atenção", "ALERT")
                        Return(.f.)
                     Else
                        aCols[n][nPosPed] := M->ZR_PEDIDO
                        aCols[n][nPosQtd] := 0
                        aCols[n][nPosNNF] := Posicione("SC6", 2, xFilial("SC6")+aCols[n][nPosPro]+M->ZR_PEDIDO, "C6_NOTA")
                        aCols[n][nPosQtO] := Posicione("SD2", 3, xFilial("SD2")+aCols[n][nPosNNF]+'   '+cCodCli+'01'+aCols[n][nPosPro], "D2_QUANT")
                        aCols[n][nPosVUO] := Posicione("SD2", 3, xFilial("SD2")+aCols[n][nPosNNF]+'   '+cCodCli+'01'+aCols[n][nPosPro], "D2_PRCVEN")
                        aCols[n][nPosVUT] := Posicione("SD2", 3, xFilial("SD2")+aCols[n][nPosNNF]+'   '+cCodCli+'01'+aCols[n][nPosPro], "D2_TOTAL")
                     Endif
                  Endif
               Endif
               oGetDados:oBrowse:Refresh()
        ElseIf __ReadVar $ "M->ZR_NUMNF"
               If aCols[n][nPosQtO] > 0
                  aCols[n][nPosNNF] := aCols[n][nPosNNF]
                  M->ZR_NUMNF       := aCols[n][nPosNNF]
               Else
                  If SubStr(Alltrim(aCols[n][nPosPro]), 1, 3) $ "DIV"
                     If !Posicione("SF2", 2, xFilial("SF2")+cCodCli+'01'+M->ZR_NUMNF, "F2_DOC") == M->ZR_NUMNF
                        MsgBox("Nota Fiscal X Cliente inválido!", "Atenção", "ALERT")
                        Return(.f.)
                     Else
                        aCols[n][nPosNNF] := M->ZR_NUMNF
                        aCols[n][nPosQtd] := 0
                        aCols[n][nPosPed] := Posicione("SF2", 1, xFilial("SF2")+aCols[n][nPosNNF]+'   '+cCodCli+'01', "F2_PEDIDO")
                        aCols[n][nPosQtO] := 0
                        aCols[n][nPosVUO] := 0
                        aCols[n][nPosVUT] := 0
                     Endif
                  Else
                     If !Posicione("SD2", 3, xFilial("SD2")+M->ZR_NUMNF+'   '+cCodCli+'01'+aCols[n][nPosPro], "D2_DOC") == M->ZR_NUMNF
                        MsgBox("Produto x Nota Fiscal x Cliente inválido!", "Atenção", "ALERT")
                        Return(.f.)
                     Else
                        aCols[n][nPosNNF] := M->ZR_NUMNF
                        aCols[n][nPosQtd] := 0
                        aCols[n][nPosPed] := Posicione("SF2", 1, xFilial("SF2")+aCols[n][nPosNNF]+'   '+cCodCli+'01', "F2_PEDIDO")
                        aCols[n][nPosQtO] := Posicione("SD2", 3, xFilial("SD2")+aCols[n][nPosNNF]+'   '+cCodCli+'01'+aCols[n][nPosPro], "D2_QUANT")
                        aCols[n][nPosVUO] := Posicione("SD2", 3, xFilial("SD2")+aCols[n][nPosNNF]+'   '+cCodCli+'01'+aCols[n][nPosPro], "D2_PRCVEN")
                        aCols[n][nPosVUT] := Posicione("SD2", 3, xFilial("SD2")+aCols[n][nPosNNF]+'   '+cCodCli+'01'+aCols[n][nPosPro], "D2_TOTAL")
                     Endif
                  Endif
               Endif
               oGetDados:oBrowse:Refresh()
        ElseIf __ReadVar $ "M->ZR_VUDEV"
               aCols[n][nPosVUD] := M->ZR_VUDEV
               aCols[n][nPosVTD] := aCols[n][nPosQtd] * aCols[n][nPosVUD]
               nCusDev           := 0
               nCusTot           := 0
               nQtdS             := 0
               For nY := 1 To Len(aCols)
                   If !aCols[n][Len(aHeader)+1]
                      If SubStr(aCols[nY][nPosIDv], 1, 1) == '1'
                         nCusDev += aCols[nY][nPosQtd] * aCols[nY][nPosVUD]
                         nCusTot += aCols[nY][nPosQtd] * aCols[nY][nPosVUD]
                         nQtdS += 1
                      Endif
                   Endif
               Next
               cDevSAC := Iif(nQtdS == 0, "Não", "Sim")
               nCusTot += (nCusFre + nCusFin)
               oCusTot:Refresh()
               oCusDev:Refresh()
               oDevSAC:Refresh()
               oGetDados:oBrowse:Refresh()
        ElseIf __ReadVar $ "M->ZR_LOTE"
               dValid := cTod('  /  /  ')
               If !Empty(M->ZR_LOTE)
                  cQry1 := "" 
                  cQry1 += "SELECT SC2.C2_EMISSAO AS EMISSAO, COUNT(SC2.C2_LOTE) AS QTDE "
                  cQry1 += "FROM "+RetSqlName("SC2")+" SC2 "
                  cQry1 += "WHERE SC2.C2_FILIAL  = '"+xFilial("SC2")+"' "
                  cQry1 += "  AND SC2.D_E_L_E_T_ = '' "
                  cQry1 += "  AND SC2.C2_LOTE    = '"+M->ZR_LOTE+"' "
                  cQry1 += "  AND SC2.C2_PRODUTO = '"+aCols[n][nPosPro]+"' "
                  cQry1 += "GROUP BY SC2.C2_EMISSAO "
                  TCQuery cQry1 ALIAS "TCQ" NEW
                  DbSelectArea("TCQ")
                  DbGoTop()
                  dValid := cTod(SubStr(TCQ->EMISSAO, 7, 2)+'/'+SubStr(TCQ->EMISSAO, 5, 2)+'/'+SubStr(TCQ->EMISSAO, 1, 4))
                  DbSelectArea("TCQ")
                  DbCloseArea()
               Endif
               If Empty(dValid)
                  aCols[n][nPosLot] := space(06)
                  M->ZR_LOTE        := space(06)
                  aCols[n][nPosDtV] := cTod('  /  /  ')
                  MsgBox("Atenção esse produto não pertence a esse lote. Verifique !", "Atenção", "STOP")
                  Return(.f.)
               Else
                  aCols[n][nPosLot]  := M->ZR_LOTE
                  aCols[n][nPosDtV] := dValid + ( Posicione("SZ1", 1, xFilial("SZ1")+SubStr(aCols[n][nPosPro], 4, 2), "Z1_VALIDAD") * 30)
                  cQry1 := "" 
                  cQry1 += "SELECT * "
                  cQry1 += "FROM "+RetSqlName("SC2")+" SC2 "
                  cQry1 += "WHERE SC2.C2_FILIAL  = '"+xFilial("SC2")+"' "
                  cQry1 += "  AND SC2.D_E_L_E_T_ = '' "
                  cQry1 += "  AND SC2.C2_LOTE    = '"+M->ZR_LOTE+"' "
                  cQry1 += "  AND SC2.C2_PRODUTO = '"+SubStr(aCols[n][nPosPro], 1, 10)+"00' "
                  TCQuery cQry1 ALIAS "TCQ" NEW
                  DbSelectArea("TCQ")
                  DbGoTop()
                  If TCQ->C2_QUANT < GETMV("MV_QTDRETE")
                     MsgInfo("Quantidade desse lote menor que "+StrZero(GETMV("MV_QTDRETE"), 2)+" litros, pode não haver retenção.", "Atenção...")
                  Endif
                  aCols[n][nPosQPr] := TCQ->C2_QUANT
                  aCols[n][nPosRET] := Posicione("ZZ1", 2, xFilial("ZZ1")+M->ZR_LOTE, "ZZ1_RETENC")
                  DbSelectArea("TCQ")
                  DbCloseArea()
                  
                  cQry1 := ""                   
                  cQry1 += "SELECT SZR.ZR_NUM+'/'+SZR.ZR_PRODUTO AS SAC "
                  cQry1 += "FROM "+RetSqlName("SZR")+" SZR "
                  cQry1 += "WHERE SZR.ZR_FILIAL  = '"+xFilial("SZR")+"' "
                  cQry1 += "  AND SZR.D_E_L_E_T_ = '' "
                  cQry1 += "  AND SZR.ZR_LOTE    = '"+M->ZR_LOTE+"' "
                  cQry1 += "ORDER BY R_E_C_N_O_ DESC "
                  TCQuery cQry1 ALIAS "TCQ" NEW
                  DbSelectArea("TCQ")
                  DbGoTop()
                  cMsgSAC := "Lote já possui os seguintes atendimentos cadastrados: "+CHR(13)+CHR(10)
                  cAuxSAC := ""
                  While !Eof()
                        cAuxSAC += TCQ->SAC+CHR(13)+CHR(10)
                        DbSelectArea("TCQ")
                        DbSkip()
                  Enddo
                  DbSelectArea("TCQ")
                  DbCloseArea()
                  If !Empty(cAuxSAC)
                     MsgInfo(cMsgSAC+cAuxSAC, "Atenção...")
                  Endif
               Endif
               oGetDados:oBrowse:Refresh()  
        ElseIf __ReadVar $ "M->ZR_DTVALID"
               aCols[n][nPosDtV] := M->ZR_DTVALID
               oGetDados:oBrowse:Refresh()   
        ElseIf __ReadVar $ "M->ZR_ITEMDEV"
               aCols[n][nPosIDv] := M->ZR_ITEMDEV
               nCusDev           := 0
               For nY := 1 To Len(aCols)
                   If !aCols[n][Len(aHeader)+1]
                      If SubStr(aCols[nY][nPosIDv], 1, 1) == '1'
                         nCusDev += aCols[nY][nPosQtd] * aCols[nY][nPosVUD]
                      Endif
                   Endif
               Next
               oCusDev:Refresh()
               oGetDados:oBrowse:Refresh()
        Else
           oGetDados:oBrowse:Refresh()
        Endif
     Else
        lRet := .F.
     Endif
     DbSelectArea( _cAliasSX3 )
     DbCloseArea()
     DbSelectArea("SZR")
Return(lRet)

/*****************************************************************************************/
/*** fMarkDis - Rotina marcar e desmarcar Nfs. selecionadas do Produto x Cliente.      ***/
/*****************************************************************************************/
Static Function fMrkDis(nOpc, oSelDpto)
       Local aArea    := GetArea()
       Local cAlias   := Alias()
       Local nLinha   := (cAlias)->(RecNo())
       If nOpc == 1
          If (cAlias)->( IsMark("TMP_OK", ThisMark(), ThisInv() ) )
             RecLock(cAlias)
                (cAlias)->TMP_OK := "XX"
             MsUnLock()
          Else
             RecLock(cAlias)
                (cAlias)->TMP_OK := ""
             MsUnLock()
          EndIf
       Else
          DbSelectArea(cAlias)
          DbGoTop()
          While !Eof()
                If !(Recno() == nLinha)
                   RecLock(cAlias)
                      (cAlias)->TMP_OK := "  "
                   MsUnLock()
                Else
                   If (cAlias)->( IsMark("TMP_OK", ThisMark(), ThisInv() ) )
                      RecLock(cAlias)
                         (cAlias)->TMP_OK := "XX"
                      MsUnLock()
                   Else
                      RecLock(cAlias)
                         (cAlias)->TMP_OK := "  "
                      MsUnLock()
                   Endif
                Endif
                DbSelectArea(cAlias)
                DbSkip()
          EndDo
          DbSelectArea(cAlias)
          DbGoTop()
          DbGoTo(nLinha)
          oSelDpto:oBrowse:Refresh()
       Endif
       RestArea(aArea)
Return(.t.)

/*****************************************************************************************/
/*** fGrvSAC - Rotina para gravação dos dados do SAC.                                  ***/
/*****************************************************************************************/
Static Function fGrvSAC(nOpc)
       Local nPosIte := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_SEQITEM" } ) // 02
       Local nPosAss := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_ASSUNTO" } ) // 02
       Local nPosOco := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_OCORREN" } ) // 03
       Local nPosPro := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_PRODUTO" } ) // 05
       Local nPosQtd := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_QTD"     } ) // 07
       Local nPosQtO := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_QTDORIG" } ) // 08
       Local nPosPed := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_PEDIDO"  } ) // 09
       Local nPosNNF := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_NUMNF"   } ) // 10
       Local nPosVUO := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_VUORI"   } ) // 11
       Local nPosVUT := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_VTORI"   } ) // 12
       Local nPosVUD := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_VUDEV"   } ) // 13
       Local nPosLot := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_LOTE"    } ) // 15
       Local nPosDtV := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_DTVALID" } ) // 16
       Local nPosQPR := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_QTDPRO"  } ) // 17
       Local nPosRet := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_RETEN"   } ) // 18
       Local nPosIDv := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_ITEMDEV" } ) // 19
       Local nPosobs := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_OBS"     } ) // 20
       Local nY

       If nOpc == 2 // Inclui Atendimento
          //Grava SZQ (Cabeçalho do SAC)
          RecLock("SZQ", .t.)
             SZQ->ZQ_FILIAL  := xFilial("SZQ")
             SZQ->ZQ_NUM     := cNumSac
             SZQ->ZQ_DATA    := dDatSac
             SZQ->ZQ_TIPOSAC := Iif(SubStr(cTipSac, 1, 1) == 'R', '1', '2')
             SZQ->ZQ_DEVOLV  := Iif(SubStr(cDevSac, 1, 1) == 'S', '1', '2')
             SZQ->ZQ_CLIENTE := cCodCli
             SZQ->ZQ_CONTATO := cConCli
             SZQ->ZQ_ATENDEN := cNomAte
             SZQ->ZQ_HINI    := cHorIni
             SZQ->ZQ_DTFIM   := dDatFim
             SZQ->ZQ_HFIM    := cHorFim
             SZQ->ZQ_CUSDEV  := nCusDev
             SZQ->ZQ_CUSFRE  := nCusFre
             SZQ->ZQ_CUSFIN  := nCusFin
             SZQ->ZQ_STATUS  := '1'
             SZQ->ZQ_FLAG    := 'A'
          MsUnLock()
          //Grava SZR (Itens do SAC)
          nCont := 0
          For nY := 1 TO Len(aCols)
              If !aCols[nY][Len(aHeader)+1]
                 RecLock("SZR", .t.)
                    SZR->ZR_FILIAL  := xFilial("SZR")
                    SZR->ZR_NUM     := cNumSac
                    SZR->ZR_SEQITEM := aCols[nY][nPosIte] //Soma1( StrZero(nCont, 2))
                    SZR->ZR_ASSUNTO := aCols[nY][nPosAss]
                    SZR->ZR_OCORREN := aCols[nY][nPosOco]
                    SZR->ZR_PRODUTO := aCols[nY][nPosPro]
                    SZR->ZR_QTD     := aCols[nY][nPosQtd]
                    SZR->ZR_QTDORIG := aCols[nY][nPosQtO]
                    SZR->ZR_PEDIDO  := aCols[nY][nPosPed]
                    SZR->ZR_NUMNF   := aCols[nY][nPosNNF]
                    SZR->ZR_VUORI   := aCols[nY][nPosVUO]
                    SZR->ZR_VTORI   := aCols[nY][nPosVUT]
                    SZR->ZR_VUDEV   := aCols[nY][nPosVUD]
                    SZR->ZR_LOTE    := aCols[nY][nPosLot]
                    SZR->ZR_DTVALID := aCols[nY][nPosDtV]
                    SZR->ZR_QTDPRO  := aCols[nY][nPosQPR]
                    SZR->ZR_RETEN   := aCols[nY][nPosRet]
                    SZR->ZR_ITEMDEV := aCols[nY][nPosIDv]
                    SZR->ZR_OBS     := aCols[nY][nPosobs]
                 MsUnLock()
                 nCont += 1
              Endif
          Next
          //Grava SZS (Histórico do SAC)
          RecLock("SZS", .t.)
             SZS->ZS_FILIAL  := xFilial("SZS")
             SZS->ZS_NUM     := cNumSAC
             SZS->ZS_SEQ     := '001'
             SZS->ZS_LOG     := 'ABE'
             SZS->ZS_DATA    := dDataBase
             SZS->ZS_HORA    := Time()
             SZS->ZS_RESP    := cNomAte
             SZS->ZS_DEPTO   := _DepUsr
             SZS->ZS_PROCEDE := ''
             SZS->ZS_PARECER := cHisCli
             SZS->ZS_REUTIL  := ''
             SZS->ZS_ESTOQUE := ''
          MsUnLock()
          //Grava histórico do Cliente
          DbSelectArea("SA1")
          DbSetOrder(1)
          DbSeek(xFilial("SA1")+cCodCli+'01', .t.)
          RecLock("SA1", .f.)
             SA1->A1_OBSSAC := cHisCli
          MsUnLock()
       ElseIf nOpc == 3 // Altera Atendimento
              //Grava SZQ (Cabeçalho do SAC)
              DbSelectArea("SZQ")
              RecLock("SZQ", .f.)
                 SZQ->ZQ_TIPOSAC := Iif(SubStr(cTipSac, 1, 1) == 'R', '1', '2')
                 SZQ->ZQ_DEVOLV  := Iif(SubStr(cDevSac, 1, 1) == 'S', '1', '2')
                 SZQ->ZQ_CUSDEV  := nCusDev
                 SZQ->ZQ_CUSFRE  := nCusFre
                 SZQ->ZQ_CUSFIN  := nCusFin
              MsUnLock()
              //Grava SZR (Itens do SAC)
              For nY := 1 TO Len(aCols)
                  If !aCols[nY][Len(aHeader)+1]
                     DbSelectArea("SZR")
                     DbSetOrder(1)
                     If DbSeek(xFilial("SZR")+cNumSAC+aCols[nY][nPosIte],.t.)
                        RecLock("SZR", .f.)
                     Else
                        RecLock("SZR", .t.)
                           SZR->ZR_FILIAL  := xFilial("SZR")
                           SZR->ZR_NUM     := cNumSAC
                           SZR->ZR_SEQITEM := aCols[nY][nPosIte]
                     Endif
                        SZR->ZR_ASSUNTO := aCols[nY][nPosAss]
                        SZR->ZR_OCORREN := aCols[nY][nPosOco]
                        SZR->ZR_PRODUTO := aCols[nY][nPosPro]
                        SZR->ZR_QTD     := aCols[nY][nPosQtd]
                        SZR->ZR_QTDORIG := aCols[nY][nPosQtO]
                        SZR->ZR_PEDIDO  := aCols[nY][nPosPed]
                        SZR->ZR_NUMNF   := aCols[nY][nPosNNF]
                        SZR->ZR_VUORI   := aCols[nY][nPosVUO]
                        SZR->ZR_VTORI   := aCols[nY][nPosVUT]
                        SZR->ZR_VUDEV   := aCols[nY][nPosVUD]
                        SZR->ZR_LOTE    := aCols[nY][nPosLot]
                        SZR->ZR_DTVALID := aCols[nY][nPosDtV]
                        SZR->ZR_QTDPRO  := aCols[nY][nPosQPR]
                        SZR->ZR_RETEN   := aCols[nY][nPosRet]
                        SZR->ZR_ITEMDEV := aCols[nY][nPosIDv]
                        SZR->ZR_OBS     := aCols[nY][nPosobs]
                     MsUnLock()
                  Else
                     DbSelectArea("SZR")
                     DbSetOrder(1)
                     DbSeek(xFilial("SZR")+cNumSAC+aCols[nY][nPosIte], .t.)
                     If Found()
                        RecLock("SZR", .f.)
                           Delete
                        MsUnLock()
                     Endif
                  Endif
              Next
              //Grava SZS (Histórico do SAC)
              DbSelectArea("SZS")
              RecLock("SZS", .t.)
                 SZS->ZS_FILIAL  := xFilial("SZS")
                 SZS->ZS_NUM     := cNumSAC
                 SZS->ZS_SEQ     := '001'
                 SZS->ZS_LOG     := 'ALT'
                 SZS->ZS_DATA    := dDataBase
                 SZS->ZS_HORA    := Time()
                 SZS->ZS_RESP    := cNomAte
                 SZS->ZS_DEPTO   := _DepUsr
                 SZS->ZS_PROCEDE := ''
                 SZS->ZS_PARECER := 'Alterado pelo usuário(a) '+Alltrim(cNomAte)+'.'+Chr(10)+Chr(13)+cHisCli
                 SZS->ZS_REUTIL  := ''
                 SZS->ZS_ESTOQUE := ''
              MsUnLock()
              //Grava histórico do Cliente
              DbSelectArea("SA1")
              DbSetOrder(1)
              DbSeek(xFilial("SA1")+SZQ->ZQ_CLIENTE, .t.)
              If Found()
                 RecLock("SA1", .f.)
                    SA1->A1_OBSSAC := cHisCli
                 MsUnLock()
              Endif
       ElseIf nOpc == 4 // Exclui Atendimento
              //Exclui SZQ (Cabeçalho do SAC)
              DbSelectArea("SZQ")
              DbSetOrder(1)
              DbSeek(xFilial("SZQ")+cNumSAC, .t.)
              If Found()
                 RecLock("SZQ", .f.)
                    Delete
                 MsUnLock()
              Endif
              //Exclui SZR (Itens do SAC)
              DbSelectArea("SZR")
              DbSetOrder(1)
              DbSeek(xFilial("SZQ")+cNumSAC, .t.)
              If Found()
                 While !Eof() .and. SZR->ZR_NUM == cNumSAC
                       RecLock("SZR", .f.)
                          Delete
                       MsUnLock()
                       DbSelectArea("SZR")
                       DbSkip()
                 Enddo
              Endif
              //Exclui SZS (Histórico do SAC)
              DbSelectArea("SZS")
              DbSetOrder(1)
              DbSeek(xFilial("SZS")+cNumSAC, .t.)
              If Found()
                 While !Eof() .and. SZS->ZS_NUM == cNumSAC
                       RecLock("SZS", .f.)
                          Delete
                       MsUnLock()
                       DbSelectArea("SZR")
                       DbSkip()
                 Enddo
              Endif              
       ElseIf nOpc == 5
              //Re-Abre SAC
              RecLock("SZQ", .f.)
                 SZQ->ZQ_RESP   := cUsername
                 SZQ->ZQ_FLAG   := 'A'
                 SZQ->ZQ_STATUS := '1'
              MsUnLock()
              //Grava SZS (Histórico do SAC)
              DbSelectArea("SZS")
              RecLock("SZS", .t.)
                 SZS->ZS_FILIAL  := xFilial("SZS")
                 SZS->ZS_NUM     := cNumSAC
                 SZS->ZS_SEQ     := '001'
                 SZS->ZS_LOG     := 'REA'
                 SZS->ZS_DATA    := dDataBase
                 SZS->ZS_HORA    := Time()
                 SZS->ZS_RESP    := cNomAte
                 SZS->ZS_DEPTO   := _DepUsr
                 SZS->ZS_PROCEDE := 'N'
                 SZS->ZS_PARECER := 'Atendimento re-aberto pelo usuário(a) '+Alltrim(cNomAte)+'.'
                 SZS->ZS_REUTIL  := 'N'
                 SZS->ZS_ESTOQUE := 'N'
              MsUnLock()
       ElseIf nOpc == 6
              If QtdComp(SZQ->ZQ_CUSFIN) <> QtdComp(nCusFin)
                 RecLock("SZQ", .f.)
                    SZQ->ZQ_CUSFIN := nCusFin
                 MsUnLock()
                 //Grava SZS (Histórico do SAC)
                 DbSelectArea("SZS")
                 RecLock("SZS", .t.)
                    SZS->ZS_FILIAL  := xFilial("SZS")
                    SZS->ZS_NUM     := cNumSAC
                    SZS->ZS_SEQ     := '001'
                    SZS->ZS_LOG     := 'REA'
                    SZS->ZS_DATA    := dDataBase
                    SZS->ZS_HORA    := cHorIni
                    SZS->ZS_RESP    := cNomAte
                    SZS->ZS_DEPTO   := _DepUsr
                    SZS->ZS_PROCEDE := 'N'
                    SZS->ZS_PARECER := 'Alterado custo financeiro pelo usuário(a) '+Alltrim(cNomAte)+'.'
                    SZS->ZS_REUTIL  := 'N'
                    SZS->ZS_ESTOQUE := 'N'
                 MsUnLock()
              Endif
       Endif
Return

/*****************************************************************************************/
/*** fEnvSAC - Rotina para envio de SAC para outro usuário.                            ***/
/*****************************************************************************************/
User Function fEnvSAC(nOpc, __SAC_BRASILUX, oDlg, lCont)
     Local oDlg1, oRadio, oSelDpto
     Local nEnvRes := 1
     Local nOpca   := 0
     Local lValid  := .f.
     Local aStru   := {}
     Local aHead   := {}
     Local aSigDpt := {OemToAnsi("ATE"), OemToAnsi("DIR"), OemToAnsi("COM"), OemToAnsi("TEC"), OemToAnsi("ATC"), OemToAnsi("FIN"), OemToAnsi("REC"), OemToAnsi("EXP"), OemToAnsi("FAT") }
     Local aDeptos := {OemToAnsi("Atendimento"), OemToAnsi("Diretoria"), OemToAnsi("Comercial"), OemToAnsi("Técnico"), OemToAnsi("Atend. Técnico"), OemToAnsi("Financeiro"), OemToAnsi("Recebimento"), OemToAnsi("Expedição"), OemToAnsi("Final. Atend. Tec.") }
     Local cParec  := ""
     Local cDepto  := ""
     Local oTempTbl01
     If nOpc == 1
        If SZQ->ZQ_STATUS == '2'
           MsgBox("Esse SAC já está encerrado, não pode ser encaminhado.", "Atenção...", "STOP")
           Return
        Endif
        If Empty(SZQ->ZQ_RESP)
           If !(Upper(Alltrim(cUsername)) == Upper(Alltrim(SZQ->ZQ_ATENDEN)))
              MsgBox("Usuário não é o atendente desse SAC para encaminha-lo.", "Atenção", "STOP")
              Return
           Endif
           If !(SZQ->ZQ_FLAG $ SubStr(_DepUsr, 1, 1))
              MsgBox("Usuário não pode encaminhar esse SAC.", "Atenção", "STOP")
              Return
           Endif
        Else
           If !(Upper(Alltrim(cUsername)) == Upper(Alltrim(SZQ->ZQ_RESP)))
              MsgBox("Usuário não é o responsável desse SAC para encaminha-lo.", "Atenção", "STOP")
              Return
           Endif
        Endif
     Endif
     aadd(aStru, {"TMP_OK", "C", 02, 0  } ) ; aadd(aStru, {"TMP_DEPUS", "C",                 15, 0    } ) ; aadd(aStru, {"TMP_DEPTO", "C", 20, 0    } )
     aadd(aHead, {"TMP_OK", "" , "", "" } ) ; aadd(aHead, {"TMP_DEPUS", "" , "Depto. / Usuário", "@!" } )
     
     /********************************************************************************************************************************/
     /*** BLOCO ALTERADO EM 11/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
     cArqTmp := GetNextAlias()
     //cArqTmp := CriaTrab(aStru, .t.)
     //DbUseArea(.T., __LocalDrive, cArqTmp, cArqTmp, .F., .F.)
     oTempTbl01 := FWTemporaryTable():New( cArqTmp )
     oTempTbl01:SetFields( aStru )
     oTempTbl01:Create()
     /********************************************************************************************************************************/
     DEFINE MSDIALOG oDlg1 FROM 000,000 TO 020,040 TITLE OemToAnsi("Encaminha SAC") OF oMainWnd
            @ 002,002 GROUP oGrp1 TO 032,130 LABEL  OemToAnsi('Departamento / Usuário ?')                        PIXEL OF oDlg1
            @ 008,005 RADIO oRadio VAR nEnvRes ITEMS OemToAnsi('Departamento'), OemToAnsi('Usuário') SIZE 050,11 ON CHANGE fDepUsu(nEnvRes, aSigDpt, aDeptos, oDlg1, aHead, @oSelDpto) PIXEL OF oDlg1
            DEFINE SBUTTON FROM 004,130 TYPE 1 OF oDlg1 ENABLE ACTION (lValid := .t., nOpca := 1, oDlg1:End())
            DEFINE SBUTTON FROM 018,130 TYPE 2 OF oDlg1 ENABLE ACTION (lValid := .t., nOpca := 0, oDlg1:End())
            /*******************************************************************************************************/
            @ 034,002 GROUP oGrp2 TO 150,157 LABEL  OemToAnsi('Usuário / Departamento')                                 PIXEL OF oDlg1
            oDlg1:nStyle := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
     ACTIVATE MSDIALOG oDlg1 VALID lValid CENTERED ON INIT fDepUsu(nEnvRes, aSigDpt, aDeptos, oDlg1, aHead, @oSelDpto)
     If nOpcA == 1
        If nEnvRes == 1 //Departamento
           DbSelectArea(cArqTmp)
           DbGoTop()
           While !Eof()
                 If (cArqTmp)->( IsMark("TMP_OK", ThisMark(), ThisInv() ) )
                    cDepto := (cArqTmp)->TMP_DEPUS
                    cParec := "Encaminhado para o departamento "+Alltrim(cDepto)+"."
                 Endif
                 DbSelectArea(cArqTmp)
                 DbSkip()
           Enddo
           If Empty(cDepto)
              ApMsgStop("Atencao, o SAC nao foi encaminhado.", "Atencao")
              Return
           Endif
        Else //Usuário
           DbSelectArea(cArqTmp)
           DbGoTop()
           While !Eof()
                 If (cArqTmp)->( IsMark("TMP_OK", ThisMark(), ThisInv() ) )
                    cUsuar := (cArqTmp)->TMP_DEPUS
                    cDepto := (cArqTmp)->TMP_DEPTO
                    cParec := "Encaminhado para o departamento "+Alltrim(cDepto)+", para o(a) usuário(a) "+Alltrim(cUsuar)+"."
                 Endif
                 DbSelectArea(cArqTmp)
                 DbSkip()
           Enddo
           If Empty(cDepto)
              ApMsgStop("Atencao, o SAC nao foi encaminhado.", "Atencao")
              Return
           Endif
        Endif
        //Grava histórico
        RecLock("SZS", .t.)
           SZS->ZS_FILIAL  := xFilial("SZS")
           SZS->ZS_NUM     := SZQ->ZQ_NUM
           SZS->ZS_SEQ     := '001'
           SZS->ZS_LOG     := 'ENC'
           SZS->ZS_DATA    := dDataBase
           SZS->ZS_HORA    := Time()
           SZS->ZS_RESP    := cUsername
           SZS->ZS_DEPTO   := _DepUsr
           SZS->ZS_PROCEDE := ''
           SZS->ZS_PARECER := cParec
           SZS->ZS_REUTIL  := ' '
           SZS->ZS_ESTOQUE := ' '
        MsUnLock()
        //Grava Informação no SAC
        RecLock("SZQ", .f.)
           If nEnvRes == 1
              SZQ->ZQ_FLAG := Iif(aSigDpt[aScan(aDeptos,  Alltrim(cDepto))] == 'ATC', 'T', Iif(aSigDpt[aScan(aDeptos,  Alltrim(cDepto))] == 'FAT', 'X', UPPER(SubStr(Alltrim(cDepto), 1, 1))))
              SZQ->ZQ_RESP := ""
           Else
              SZQ->ZQ_FLAG := Iif(Alltrim(cDepto) $ 'Final. Atend. Téc.', 'X', UPPER(SubStr(Alltrim(cDepto), 1, 1)))
              SZQ->ZQ_RESP := UPPER(Alltrim(cUsuar))
           Endif
        MsUnLock()
     Endif
     DbSelectArea( cArqTmp )
     DbCloseArea()
     oTempTbl01:Delete()
     If !(oDlg == Nil)
        lCont := .t.
        oDlg:End()
     Endif
     If __SAC_BRASILUX == 2
        U_fMSACPn(2, 1, .t.)
        Return .f.
     Endif
Return

/*****************************************************************************************/
/*** fDepUsu - Rotina mostrar departamento ou usuario para encaminhamento do SAC.      ***/
/*****************************************************************************************/
Static Function fDepUsu(nEnvRes, aSigDpt, aDeptos, oDlg1, aHead, oSelDpto)
       Local cDptUsr := ""
       Local nY
       If nEnvRes == 1
          aHead[2][3] := "Departamento"
          If Len(aHead) == 3
             nNewTam := Len(aHead) - 1
             aSize(aDel(aHead, Len(aHead)), nNewTam)
          Endif
          DbSelectArea(cArqTmp)
          DbGoTop()
          While !Eof()
                RecLock(cArqTmp, .f.)
                   Delete
                MsUnLock()
                DbSelectArea(cArqTmp)
                DbSkip()
          Enddo
          For nY := 1 To Len(aDeptos)
              If !(_DepUsr == aSigDpt[nY])
                 If _DepUsr == 'ATC'
                    If !(aSigDpt[nY] $ 'DIR.COM.FIN.REC.EXP.TEC')
                       RecLock(cArqTmp, .t.)
                          (cArqTmp)->TMP_OK    := "  "
                          (cArqTmp)->TMP_DEPUS := aDeptos[nY]
                       MsUnLock()
                    Endif
                 ElseIf _DepUsr == 'ATE'
                        If !(aSigDpt[nY] $ 'TEC')
                           RecLock(cArqTmp, .t.)
                              (cArqTmp)->TMP_OK    := "  "
                              (cArqTmp)->TMP_DEPUS := aDeptos[nY]
                           MsUnLock()
                        Endif
                 ElseIf _DepUsr == 'EXP.FIN'
                        If !(aSigDpt[nY] $ 'TEC.DIR.COM.FIN.REC.EXP.ATC')
                           RecLock(cArqTmp, .t.)
                              (cArqTmp)->TMP_OK    := "  "
                              (cArqTmp)->TMP_DEPUS := aDeptos[nY]
                           MsUnLock()
                        Endif
                 ElseIf _DepUsr == 'TEC'
                        If !(aSigDpt[nY] $ 'TEC.DIR.COM.FIN.REC.EXP')
                           RecLock(cArqTmp, .t.)
                              (cArqTmp)->TMP_OK    := "  "
                              (cArqTmp)->TMP_DEPUS := aDeptos[nY]
                           MsUnLock()
                        Endif
                 Else
                    RecLock(cArqTmp, .t.)
                       (cArqTmp)->TMP_OK    := "  "
                       (cArqTmp)->TMP_DEPUS := aDeptos[nY]
                    MsUnLock()
                 Endif
              Endif
          Next
          oSelDpto := MsSelect():New(cArqTmp, "TMP_OK", , aHead, .F., "XX", {039, 005, 145, 154}, , , oDlg1 )
          oSelDpto:oBrowse:lCanAllMark := .F.
          oSelDpto:bMark := {|| fMrkDis(2, @oSelDpto) }
       ElseIf nEnvRes == 2
              aHead[2][3] := "Usuário"
              aadd(aHead, {"TMP_DEPTO", "" , "Departamento", "@!" } )
              oSelDpto:oBrowse:Destroy()
              DbSelectArea(cArqTmp)
              DbGoTop()
              While !Eof()
                    RecLock(cArqTmp, .f.)
                       Delete
                    MsUnLock()
                    DbSelectArea(cArqTmp)
                    DbSkip()
              Enddo
              cQry1 := ""
              cQry1 += "SELECT * "
              cQry1 += "FROM "+RetSqlName("SZW")+" SZW "
              cQry1 += "WHERE SZW.ZW_FILIAL  = '"+xFilial("SZW")+"' "
              cQry1 += "  AND SZW.D_E_L_E_T_ = '' "
              cQry1 += "  AND SZW.ZW_EMPFIL  = '"+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2)+"' "
              cQry1 += "  AND SZW.ZW_ROTINA  = '"+_Rotina+"' "
              cQry1 += "  AND SUBSTRING(SZW.ZW_ACESSOS, 9, 1) = '*' "
              TCQuery cQry1 ALIAS "TCQ" NEW
              
              DbSelectArea("TCQ")
              DbGoTop()
              While !Eof()
                    If _DepUsr $ "INF"
                       DbSelectArea("TCQ")
                       DbSkip()
                    Endif
                    If !(_CodUsr == TCQ->ZW_USUARIO)
                       If TCQ->ZW_DEPTO == 'ATE'
                          cDptUsr := 'Atendimento' 
                       ElseIf TCQ->ZW_DEPTO == 'DIR'
                              cDptUsr := 'Diretoria'
                       ElseIf TCQ->ZW_DEPTO == 'COM'
                              cDptUsr := 'Comercial'
                       ElseIf TCQ->ZW_DEPTO == 'FIN'
                              cDptUsr := 'Financeiro'
                       ElseIf TCQ->ZW_DEPTO == 'TEC'
                              cDptUsr := 'Técnico'
                       ElseIf TCQ->ZW_DEPTO == 'ATC'
                              cDptUsr := 'Atendimento Técnico'
                       ElseIf TCQ->ZW_DEPTO == 'REC'
                              cDptUsr := 'Recebimento'
                       ElseIf TCQ->ZW_DEPTO == 'EXP'
                              cDptUsr := 'Expedição'
                       ElseIf TCQ->ZW_DEPTO == 'FAT'
                              cDptUsr := 'Final. Atend. Téc.'
                       Endif
                       If _DepUsr $ 'ATC'
                          If !(TCQ->ZW_DEPTO $ 'DIR.COM.FIN.REC.EXP')
                             RecLock(cArqTmp, .t.)
                                (cArqTmp)->TMP_OK    := "  "
                                (cArqTmp)->TMP_DEPUS := UsrRetName(TCQ->ZW_USUARIO)
                                (cArqTmp)->TMP_DEPTO := cDptUsr
                             MsUnLock()
                          Endif
                       ElseIf _DepUsr $ 'TEC'
                              If !(TCQ->ZW_DEPTO $ 'TEC.DIR.COM.FIN.REC.EXP')
                                 RecLock(cArqTmp, .t.)
                                    (cArqTmp)->TMP_OK    := "  "
                                    (cArqTmp)->TMP_DEPUS := UsrRetName(TCQ->ZW_USUARIO)
                                    (cArqTmp)->TMP_DEPTO := cDptUsr
                                 MsUnLock()
                              Endif
                       Else
                          RecLock(cArqTmp, .t.)
                             (cArqTmp)->TMP_OK    := "  "
                             (cArqTmp)->TMP_DEPUS := UsrRetName(TCQ->ZW_USUARIO)
                             (cArqTmp)->TMP_DEPTO := cDptUsr
                          MsUnLock()
                       Endif
                    Endif
                    DbSelectArea("TCQ")
                    DbSkip()
              Enddo
              DbSelectArea("TCQ")
              DbCloseArea()
              oSelDpto := MsSelect():New(cArqTmp, "TMP_OK", , aHead, .F., "XX", {039, 005, 145, 154}, , , oDlg1 )
              oSelDpto:oBrowse:lCanAllMark := .F.
              oSelDpto:bMark := {|| fMrkDis(2, @oSelDpto) }
       Endif
       DbSelectArea(cArqTmp)
       DbGoTop()
       While !Eof()
             oSelDpto:oBrowse:Refresh()
             DbSelectArea(cArqTmp)
             DbSkip()
       Enddo
       DbGoTop()
       oSelDpto:oBrowse:GoDown()
       oSelDpto:oBrowse:GoUp()
       oSelDpto:oBrowse:Refresh(.t.)
Return

/*****************************************************************************************/
/*** fMosHis - Rotina para mostrar histórico do SAC.                                   ***/
/*****************************************************************************************/
Static Function fMosHis()
       Local oDlgHis, oGrp1, oLBXHis, oTxtMemo
       Local cLBXHis := ""
       Local cQry1   := ""
       Local aLog    := {}
       Local cLog    := ""
       Local cParecer:= ""
       Local cTxtMemo:= ""
     
       
       cQry1 += "SELECT ZS_FILIAL,ZS_NUM,ZS_SEQ,ZS_LOG,ZS_DATA,ZS_HORA,ZS_RESP,ZS_DEPTO,ZS_PROCEDE,ZS_REUTIL,"+;
       "ZS_ESTOQUE,ZS_RECEPTO,ZS_EMISSOR,R_E_C_N_O_, "+;
       "RTRIM(CONVERT(VARCHAR(2046),CONVERT(VARBINARY(2046), SZS.ZS_PARECER))) AS ZS_PARECER "
       cQry1 += "FROM "+RetSqlName("SZS")+" SZS "
       cQry1 += "WHERE SZS.ZS_FILIAL  = '"+xFilial("SZS")+"' "
       cQry1 += "  AND SZS.D_E_L_E_T_ = '' "
       cQry1 += "  AND SZS.ZS_NUM     = '"+cNumSAC+"' "
       //TCQUERY cQry1 ALIAS "TCQ" NEW
       cQry1 := ChangeQuery(cQry1)
       dbUseArea(.T., "TOPCONN", TcGenQry(,, cQry1), "TCQ", .T., .T.)
       DbSelectArea("TCQ")
       While !Eof()
             DO CASE
                CASE TCQ->ZS_LOG == 'ABE'
                     cLog     := 'Abertura'
                     cParecer := TCQ->ZS_PARECER //Posicione("SA1", 1, xFilial("SA1")+Posicione("SZQ", 1, xFilial("SZQ")+TCQ->ZS_NUM, "ZQ_CLIENTE"), "A1_OBSSAC")
                CASE TCQ->ZS_LOG == 'ATE'
                     cLog := 'Atendimento'
                     cParecer := TCQ->ZS_PARECER
                CASE TCQ->ZS_LOG == 'ENC'
                     cLog := 'Encaminhado'
                     cParecer := TCQ->ZS_PARECER
                CASE TCQ->ZS_LOG == 'ALT'
                     cLog := 'Alterado'
                     cParecer := TCQ->ZS_PARECER
                CASE TCQ->ZS_LOG == 'ATC'
                     cLog := 'Atendimento Técnico'
                     cParecer := TCQ->ZS_PARECER
                CASE TCQ->ZS_LOG == 'ALF'
                     cLog := 'Alt. Financ.'
                     cParecer := TCQ->ZS_PARECER
                CASE TCQ->ZS_LOG == 'DIR'
                     cLog := 'Diretoria'
                     cParecer := TCQ->ZS_PARECER
                CASE TCQ->ZS_LOG == 'COM'
                     cLog := 'Comercial'
                     cParecer := TCQ->ZS_PARECER
                CASE TCQ->ZS_LOG == 'FIN'
                     cLog := 'Financeiro'
                     cParecer := TCQ->ZS_PARECER
                CASE TCQ->ZS_LOG == 'TEC'
                     cLog := 'Técnico'
                     cParecer := TCQ->ZS_PARECER
                CASE TCQ->ZS_LOG == 'EXP'
                     cLog := 'Expedição'
                     cParecer := TCQ->ZS_PARECER
                CASE TCQ->ZS_LOG == 'REC'
                     cLog := 'Recebimento'
                     cParecer := TCQ->ZS_PARECER
                CASE TCQ->ZS_LOG == 'FIM'
                     cLog := 'Finalizado'
                     cParecer := TCQ->ZS_PARECER
                CASE TCQ->ZS_LOG == 'EMA'
                     cLog := 'E-mail'
                     cParecer := TCQ->ZS_PARECER
                CASE TCQ->ZS_LOG == 'REA'
                     cLog := 'Re-abertura'
                     cParecer := TCQ->ZS_PARECER
                CASE TCQ->ZS_LOG == 'FAT'
                     cLog := 'Fin. Atend. Técnico'
                     cParecer := TCQ->ZS_PARECER
                CASE TCQ->ZS_LOG == 'DIA'
                     cLog := 'Diagnóstico/Solução'
                     cParecer := TCQ->ZS_PARECER
             ENDCASE
             aadd(aLog, {TCQ->ZS_SEQ, cLog, SubStr(TCQ->ZS_DATA, 7, 2)+'/'+SubStr(TCQ->ZS_DATA, 5, 2)+'/'+SubStr(TCQ->ZS_DATA, 1, 4), TCQ->ZS_HORA, Upper(TCQ->ZS_RESP), TCQ->ZS_PROCEDE, TCQ->ZS_REUTIL, TCQ->ZS_ESTOQUE, cParecer, TCQ->R_E_C_N_O_, TCQ->ZS_LOG })
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
       If Len(aLog) <= 0
          aadd(aLog, {'', '', '', '', '', '', '', '', '', 0 , ''})
       Endif
       aSort( aLog,,,{ |x,y| x[10] > y[10] } )
       DEFINE MSDIALOG oDlgHis TITLE OemToAnsi( "Histórico do Atendimento" ) FROM 000,000 TO 020, 080 OF oMainWnd
              DEFINE FONT oFont1 NAME 'COURIER NEW' SIZE 6,0
              @ 005,005 GROUP oGrp1 TO 078,312 LABEL OemToAnsi("Movimentos") COLOR CLR_HRED PIXEL OF oDlgHis
              @ 010,007 LISTBOX oLBXHis VAR cLBXHis FIELDS HEADER OemToAnsi('Log'), OemToAnsi('Data'), OemToAnsi('Hora'), OemToAnsi('Responsável'), OemToAnsi('Procede ?'), OemToAnsi('Reutiliza ?'), OemToAnsi('Estoque ?')  SIZE 302,065 ON CHANGE fAtuHis( oLBXHis:nAt, aLog, @oTxtMemo, @cTxtMemo) PIXEL OF oDlgHis
              @ 080,005 GROUP oGrp2 TO 150,312 LABEL OemToAnsi( "Parecer")   COLOR CLR_HRED PIXEL OF oDlgHis
              @ 085,007   GET oTxtMemo VAR cTxtMemo  MEMO READONLY      SIZE 302,060                                                PIXEL OF oDlgHis FONT oFont1
              bHisLin := { || { aLog[oLBXHis:nAt][2], aLog[oLBXHis:nAt][3], aLog[oLBXHis:nAt][4], aLog[oLBXHis:nAt][5], aLog[oLBXHis:nAt][6], aLog[oLBXHis:nAt][7], aLog[oLBXHis:nAt][8] } }

              oLBXHis:SetArray( aLog )
              oLBXHis:bLine  := bHisLin
              oLBXHis:GoTop()
              oDlgHis:nStyle := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
       ACTIVATE MSDIALOG oDlgHis CENTERED ON INIT fAtuHis( oLBXHis:nAt, aLog, @oTxtMemo, @cTxtMemo)
Return

/*****************************************************************************************/
/*** fAtuHis - Atualiza histórico do SAC.                                              ***/
/*****************************************************************************************/
Static Function fAtuHis( nPos, aLog, oTxtMemo, cTxtMemo)
       cTxtMemo := ""
       //If aLog[nPos][11] $ 'ABE'
       //   cTxtMemo := Posicione("SA1", 1, xFilial("SA1")+SZQ->ZQ_CLIENTE, "A1_OBSSAC")
       //Else
          cTxtMemo := aLog[nPos][9]
       //Endif
       oTxtMemo:Refresh()
Return

/*****************************************************************************************/
/*** fMonPar - Rotina para informar parecer do SAC                                     ***/
/*****************************************************************************************/
Static Function fMonPar(cFinal)
       Local oDlgPar, oGrp1, oTxtMemo, oNomRes, oOcoSAC, oRetSAC, oEstSAC
       //Local oLBXPar
       Local cNomRes := cUsername
       Local cOcoSAC := 'Não Procede'
       Local cRetSAC := 'Não'
       Local cEstSAC := 'Não'
       Local aOcoSAC := {'Procede', 'Não Procede'}
       Local aRetSAC := {'Sim', 'Não'}
       Local aEstSAC := {'Sim', 'Não'}
       //Local cLBXPar := ""
       //Local cQry1   := ""
       //Local aLog    := {}
       Local cTxtMemo:= ""
       Local lValid  := .f.
       Local nOpca   := 0
       cFinal        := Iif(cFinal == Nil, '', cFinal)
       
       DEFINE MSDIALOG oDlgPar TITLE OemToAnsi( "Parecer do Atendimento" ) FROM 000,000 TO 015, 080 OF oMainWnd
              DEFINE FONT oFont1 NAME 'COURIER NEW' SIZE 6,0
              @ 005,005 GROUP oGrp1 TO 024,312 LABEL OemToAnsi("Movimentos")     COLOR CLR_HRED  PIXEL OF oDlgPar
              @ 011,010 SAY OemToAnsi("Responsável:")                SIZE 035,09 COLOR CLR_HBLUE PIXEL OF oDlgPar
              @ 010,047 MSGET oNomRes VAR cNomRes PICTURE "@!"       SIZE 053,09                 PIXEL OF oDlgPar
              If !(_DepUsr $ 'REC')
                 @ 011,105 SAY OemToAnsi("Ocorrência:")                 SIZE 030,09 COLOR CLR_HBLUE PIXEL OF oDlgPar
                 @ 010,137 MSCOMBOBOX oOcoSAC VAR cOcoSAC ITEMS aOcoSac SIZE 045,09                 PIXEL OF oDlgPar
              Endif
              If Empty(cFinal)
                 If (_DepUsr $ 'EXP.TEC.ATE.FAT')
                    @ 011,188 SAY OemToAnsi("Retrabalho:")                 SIZE 030,09 COLOR CLR_HBLUE PIXEL OF oDlgPar
                    @ 010,220 MSCOMBOBOX oRetSac VAR cRetSac ITEMS aRetSac SIZE 025,09                 PIXEL OF oDlgPar
                    @ 011,250 SAY OemToAnsi("Estoque:")                    SIZE 030,09 COLOR CLR_HBLUE PIXEL OF oDlgPar
                    @ 010,275 MSCOMBOBOX oEstSac VAR cEstSac ITEMS aEstSac SIZE 025,09                 PIXEL OF oDlgPar
                 Endif
              Endif
              @ 025,005 GROUP oGrp2 TO 095,312 LABEL OemToAnsi( "Parecer")       COLOR CLR_HRED  PIXEL OF oDlgPar
              @ 030,007   GET oTxtMemo VAR cTxtMemo  MEMO            SIZE 302,060                PIXEL OF oDlgPar FONT oFont1
              
              DEFINE SBUTTON FROM 098,255 TYPE 1 OF oDlgPar ENABLE ACTION (lValid := .t., nOpca := 1, oDlgPar:End())
              DEFINE SBUTTON FROM 098,285 TYPE 2 OF oDlgPar ENABLE ACTION (lValid := .t., nOpca := 0, oDlgPar:End())

              oNomRes:bWhen  := {||.f.}
              oDlgPar:nStyle := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
       ACTIVATE MSDIALOG oDlgPar CENTERED VALID lValid
       If nOpca == 1
          RecLock("SZS", .t.)
             SZS->ZS_FILIAL  := xFilial("SZS")
             SZS->ZS_NUM     := SZQ->ZQ_NUM
             SZS->ZS_SEQ     := '001'
             SZS->ZS_LOG     := Iif(Empty(cFinal), _DepUsr, 'FIM')
             SZS->ZS_DATA    := dDataBase
             SZS->ZS_HORA    := Time()
             SZS->ZS_RESP    := cUsername
             SZS->ZS_DEPTO   := _DepUsr
             SZS->ZS_PROCEDE := Iif( !(_DepUsr $ 'REC')        , Iif(SubStr(cOcoSAC, 1, 1) == "N", "N", "S"), '')
             SZS->ZS_PARECER := cTxtMemo
             SZS->ZS_REUTIL  := Iif(  (_DepUsr $ 'FAT.EXP.TEC.ATE'), Iif(SubStr(cRetSAC, 1, 1) == "N", "N", "S"), '')
             SZS->ZS_ESTOQUE := Iif(  (_DepUsr $ 'FAT.EXP.TEC.ATE'), Iif(SubStr(cEstSAC, 1, 1) == "N", "N", "S"), '')
          MsUnLock()
          If _DepUsr $ 'DIR.EXP.FIN.COM'
             RecLock("SZQ", .f.)
                SZQ->ZQ_RESP := cUsername
             MsUnLock()
          Endif
          If !Empty(cFinal)
             RecLock("SZQ", .f.)
                SZQ->ZQ_STATUS  := '2'
                SZQ->ZQ_RESP    := cUsername
                SZQ->ZQ_DTFIM   := dDataBase
                SZQ->ZQ_HFIM    := Time()
                SZQ->ZQ_PROCEDE := Iif(SubStr(nCBo2Sac, 1, 1) == "N", "N", "S")     // Gravar Campo Procede ou Não Procede 23/07/12
             MsUnLock()
          Endif
       Endif
Return

User Function fMSACPn(nOpc, __SAC_BRASILUX, lFiltra, _xDepUsr)
     Local _CodUsr  := ""//RetCodUsr()
     Local cLogUsr  := cUsername
     Local _Rotina  := "BRSACX02  "
     //Local _NumEmp  := cNumEmp
     Local _DepUsr  := ""//Posicione("SZW", 4, xFilial("SZW")+_Rotina+_CodUsr+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2), "ZW_DEPTO")
     Local cQry1    := ""
     Local cMosPen  := '(ZQ_FILIAL == xFilial("SZQ")) .AND. (ZQ_STATUS = "1") '
     Local aStatus  := {}
     Local oSACATE  := LoadBitmap( GetResources(), "BR_VERDE")
     Local oSACDIR  := LoadBitmap( GetResources(), "BR_AZUL")
     Local oSACCOM  := LoadBitmap( GetResources(), "BR_AMARELO")
     Local oSACFIN  := LoadBitmap( GetResources(), "BR_PINK")
     Local oSACTEC  := LoadBitmap( GetResources(), "BR_MARRON")
     Local oSACEXP  := LoadBitmap( GetResources(), "BR_PRETO")
     Local oSACREC  := LoadBitmap( GetResources(), "BR_CINZA")
     //Local oSACFAT  := LoadBitmap( GetResources(), "BR_LARANJA")

     DbSelectArea("SZQ")
     _CodUsr := RetCodUsr()
     _DepUsr := Posicione("SZW", 4, xFilial("SZW")+_Rotina+_CodUsr+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2), "ZW_DEPTO")
     
     If nOpc == 1
        cQry1 += "SELECT * "
        cQry1 += "FROM "+RetSqlName("SZQ")+" SZQ "
        cQry1 += "WHERE SZQ.ZQ_FILIAL  = '"+xFilial("SZQ")+"' "
        cQry1 += "  AND SZQ.D_E_L_E_T_ = '' "
        cQry1 += "  AND SZQ.ZQ_STATUS  = '1' " //Atendimentos Pendentes
        If _DepUsr $ 'ATE'
           cQry1 += "AND SZQ.ZQ_FLAG    = 'A' AND SZQ.ZQ_RESP = '' "
           oLege := oSACATE
        ElseIf _DepUsr $ 'DIR'
               cQry1 += "AND SZQ.ZQ_FLAG    = 'D' AND (SZQ.ZQ_RESP = '' OR SZQ.ZQ_RESP = '"+cLogUsr+"') "
               oLege := oSACDIR
        ElseIf _DepUsr $ 'COM'
               cQry1 += "AND SZQ.ZQ_FLAG    = 'C' AND (SZQ.ZQ_RESP = '' OR SZQ.ZQ_RESP = '"+cLogUsr+"') "
               oLege := oSACCOM
        ElseIf _DepUsr $ 'FIN'
               cQry1 += "AND SZQ.ZQ_FLAG    = 'F' AND (SZQ.ZQ_RESP = '' OR SZQ.ZQ_RESP = '"+cLogUsr+"') "
               oLege := oSACFIN
        ElseIf _DepUsr $ 'TEC.FAT'
               cQry1 += "AND SZQ.ZQ_FLAG    IN('T','X') AND (SZQ.ZQ_RESP = '"+cLogUsr+"') "
               oLege := oSACTEC
        ElseIf _DepUsr $ 'ATC'
               cQry1 += "AND SZQ.ZQ_FLAG    = 'T' AND (SZQ.ZQ_RESP = '') "
               oLege := oSACTEC
        ElseIf _DepUsr $ 'EXP'
               cQry1 += "AND SZQ.ZQ_FLAG    = 'E' AND (SZQ.ZQ_RESP = '' OR SZQ.ZQ_RESP = '"+cLogUsr+"') "
               oLege := oSACEXP
        ElseIf _DepUsr $ 'REC'
               cQry1 += "AND SZQ.ZQ_FLAG    = 'R' AND (SZQ.ZQ_RESP = '' OR SZQ.ZQ_RESP = '"+cLogUsr+"') "
               oLege := oSACREC
        Endif
        cQry1 += "ORDER BY SZQ.ZQ_NUM "
        TCQuery cQry1 ALIAS "TCQ" NEW
        DbSelectArea("TCQ")
        DbGoTop()
        While !Eof()
              aadd(aStatus, {oLege, TCQ->ZQ_NUM, TCQ->ZQ_CLIENTE, Posicione("SA1", 1, xFilial("SA1")+TCQ->ZQ_CLIENTE, "A1_NOME" )} )
              DbSelectArea("TCQ")
              DbSkip()
        Enddo
        DbSelectArea("TCQ")
        DbCloseArea()

        If Len(aStatus) <= 0
           Return
        Endif
        DEFINE MSDIALOG oDlg TITLE OemToAnsi( "Pendências de SAC" ) FROM 000,000 TO 020, 080 OF oMainWnd
               @ 018,003 LISTBOX oSZQ VAR cSZQ FIELDS HEADER "", OemToAnsi("Numero"), OemToAnsi("Cliente"), OemToAnsi("Razão") SIZE 310,130 PIXEL OF oDlg 
               bSZQLine := { || { aStatus[oSZQ:nAt][1], aStatus[oSZQ:nAt][2], aStatus[oSZQ:nAt][3], aStatus[oSZQ:nAt][4]  } }
            
               oSZQ:SetArray( aStatus )
               oSZQ:bLine  := bSZQLine
               oSZQ:GoTop()
               oDlg:nStyle := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
        ACTIVATE MSDIALOG oDlg CENTERED ON INIT fPenOpc(oDlg, {|| oDlg:End() }, {|| oDlg:End() }, .t. )
     ElseIf nOpc == 2
            _DepUsr := Iif(Empty(_DepUsr), Posicione("SZW", 4, xFilial("SZW")+_Rotina+_CodUsr+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2), "ZW_DEPTO"), _DepUsr)
            If __SAC_BRASILUX == 1
               If _DepUsr $ 'ATE'
                      cMosPen += '.AND. (ZQ_FLAG == "A") .AND. ( Alltrim(ZQ_RESP) == "")'
               ElseIf _DepUsr $ 'DIR'
                      cMosPen += '.AND. (ZQ_FLAG == "D") .AND. ((Alltrim(ZQ_RESP) == "") .OR. Upper(Alltrim(ZQ_RESP)) == "'+Upper(Alltrim(cLogUsr))+"') '
               ElseIf _DepUsr $ 'COM'
                      cMosPen += '.AND. (ZQ_FLAG == "C") .AND. ((Alltrim(ZQ_RESP) == "") .OR. Upper(Alltrim(ZQ_RESP)) == "'+Upper(Alltrim(cLogUsr))+'") '
               ElseIf _DepUsr $ 'FIN'
                      cMosPen += '.AND. (ZQ_FLAG == "F") .AND. ((Alltrim(ZQ_RESP) == "") .OR. Upper(Alltrim(ZQ_RESP)) == "'+Upper(Alltrim(cLogUsr))+'") '
               ElseIf _DepUsr $ 'TEC.FAT'
                      cMosPen += '.AND. (ZQ_FLAG $ "T.X") .AND. ( (Empty(ZQ_RESP)) .OR. Upper(Alltrim(ZQ_RESP)) == "'+Upper(Alltrim(cLogUsr))+'") '
               ElseIf _DepUsr $ 'ATC'
                      cMosPen += '.AND. (ZQ_FLAG == "T") .AND. ((Alltrim(ZQ_RESP) == "")                                                              ) '
               ElseIf _DepUsr $ 'EXP'
                      cMosPen += '.AND. (ZQ_FLAG == "E") .AND. ((Alltrim(ZQ_RESP) == "") .OR. Upper(Alltrim(ZQ_RESP)) == "'+Upper(Alltrim(cLogUsr))+'") '
               ElseIf _DepUsr $ 'REC'
                      cMosPen += '.AND. (ZQ_FLAG == "R") .AND. ((Alltrim(ZQ_RESP) == "") .OR. Upper(Alltrim(ZQ_RESP)) == "'+Upper(Alltrim(cLogUsr))+'") '
               Endif
               If lFiltra
                  __SAC_BRASILUX := 2
                  DbSelectArea("SZQ")
                  Set Filter to &(cMosPen)
                  DbSetOrder(1)
                  DbGoTop()
                  SysRefresh()
               Else
                  DbSelectArea("SZQ")
                  Set Filter to &(cMosPen)
                  DbSetOrder(1)
                  DbGoTop()
                  SysRefresh()
               Endif
            Else
               If lFiltra
                  __SAC_BRASILUX := 1
                  cMosPen := ""
                  cMosPen += 'ZQ_FILIAL = xFilial("SZQ") '
                  DbSelectArea("SZQ")
                  Set Filter to &(cMosPen)
                  DbSetOrder(1)
                  DbGoTop()
                  SysRefresh()
               Endif
            Endif
     ElseIf nOpc == 0
     Endif
Return Nil

Static Function fPenOpc(oDlg, bOk, bCancel, lEntr)
       Private oBar
       DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlg
       If lEntr
          DEFINE BUTTON oBtOk  RESOURCE "PENDENTE" OF oBar GROUP ACTION U_SACX02_2() TOOLTIP OemToAnsi("Legenda...")
       Endif
       DEFINE BUTTON oBtOk  RESOURCE "S4WB018N" OF oBar GROUP ACTION oDlg:End() TOOLTIP OemToAnsi("Sair...")
       oBar:bRClicked := {|| AllwaysTrue()}
Return Nil

User Function SACX02_4()
     Local oDlgRep, oGrp1, oGrp2, nOpcb := 0, oObsRep, cObsRep := ""
     //Local cToEnv
     Local lSaida    := .f.
     Local lRet      := .f.
     Local cToRep    := Space(35)    
     Local cPara     := Space(20)
     //Local cMensagem := Space(255)
     Local cCodHTM   := ""
     Local cMenSAC   := OemToAnsi("Conclusão de SAC,  informada pelo atendente do SAC.")+Chr(13)+Chr(10)
     Local cSerNew := GETMV("MV_RELSERV")            //SERVIDOR SMTP
     Local cAccNew := GETMV("MV_RELACNT")            //CONTA DE EMAIL
     //Local cEnvNew := GETMV("MV_RELACNT")            //EMAIL
     Local cPasNew := GETMV("MV_RELPSW")             //SENHA DA CONTA
     Local lRelauth := SuperGetMv("MV_RELAUTH")	     //AUTENTICAÇÃO
     Local cSubNew := "SAC - Serviço de Atendimento ao Cliente."

     
     DEFINE MSDIALOG oDlgRep FROM 000,000 TO 020,046.8 TITLE OemToAnsi("Envio de Email a Representantes ou Outros") OF oMainWnd
            @ 012,002 GROUP oGrp1 TO 040,184 LABEL   OemToAnsi('')                                                     PIXEL OF oDlgRep
            @ 016,005 SAY OemToAnsi("Forneça os dados abaixo, Para: Nome do Destinatário, ")                           PIXEL OF oDlgRep
            @ 024,005 SAY OemToAnsi("E-mail: endereço de e-mail, Ex.joaodasilva@uol.com.br")                           PIXEL OF oDlgRep
            @ 032,005 SAY OemToAnsi("Mensagem:coloque sua mensagem ao destinatário.       ")                           PIXEL OF oDlgRep
            @ 042,002 GROUP oGrp2 TO 080,184 LABEL   OemToAnsi('Dados...')                                             PIXEL OF oDlgRep
            @ 049,005 SAY OemToAnsi("Para: ")                                                                          PIXEL OF oDlgRep
            @ 049,025 MSGET oPara VAR cPara                                                     SIZE 070,009           PIXEL OF oDlgRep
            @ 065,005 SAY OemToAnsi("E-mail: ")                                                                        PIXEL OF oDlgRep
            @ 063,025 MSGET oToRep VAR cToRep                                                   SIZE 120,009           PIXEL OF oDlgRep
            @ 082,002 GROUP oGrp3 TO 150,184 LABEL   OemToAnsi('Mensagem...')                                          PIXEL OF oDlgRep
            @ 087,005 GET oObsRep VAR cObsRep  MEMO                                                        SIZE 175,58 PIXEL OF oDlgRep
            oDlgRep:nStyle             := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
     ACTIVATE MSDIALOG oDlgRep VALID lSaida ON INIT EnchoiceBar(oDlgRep, { ||nOpcb := 1, lSaida := .t., oDlgRep:End() }, {||nOpcb := 0, lSaida := .t., oDlgRep:End() },,) CENTERED
     If nOpcb == 1
        cCodHTM := ""
        cMenSAC := OemToAnsi("Conclusão de SAC,  informada pelo atendente do SAC.")+Chr(13)+Chr(10)
        cMenSAC += Alltrim(cObsRep)
        cResSAC := cPara
        cNumSAC := SZQ->ZQ_NUM
        cEmiSAC := cUsername
        cCliSAC := SZQ->ZQ_CLIENTE+" - "+Posicione("SA1", 1, xFilial("SA1")+SZQ->ZQ_CLIENTE, "A1_NREDUZ")
        cMenPar := ""+Chr(13)+Chr(10)
         
        DbSelectArea("SZS")
        DbSetOrder(1)
        DbSeek(xFilial("SZS")+SZQ->ZQ_NUM, .t.)
        If Found()
           While !Eof() .and. SZS->ZS_NUM == SZQ->ZQ_NUM
                 If SZS->ZS_LOG $ 'ABE.ALT.ATE.ATC.EMA.ENC.FIM.REA'
                    DbSelectArea("SZS")
                    DbSkip()
                    Loop
                 Endif
                 If SZS->ZS_LOG $ 'COM.VEN'
                    cMenPar += "PARECER COMERCIAL        - "+AllTrim(SZS->ZS_PARECER)+Chr(13)+Chr(10)
                 ElseIf SZS->ZS_LOG $ 'DIR'
                        cMenPar += "PARECER DA DIRETORIA - "+AllTrim(SZS->ZS_PARECER)+Chr(13)+Chr(10)
                 ElseIf SZS->ZS_LOG $ 'EXP'
                        cMenPar += "PARECER DA EXPEDIÇÃO - "+AllTrim(SZS->ZS_PARECER)+Chr(13)+Chr(10)
                 ElseIf SZS->ZS_LOG $ 'FIN'
                        cMenPar += "PARECER FINANCEIRO   - "+AllTrim(SZS->ZS_PARECER)+Chr(13)+Chr(10)
                 ElseIf SZS->ZS_LOG $ 'FAT.TEC'
                        If SZS->ZS_DATA >= CTOD('20/08/05')
                           If SZS->ZS_LOG $ 'FAT'
                              cMenPar += "PARECER TÉCNICO      - "+AllTrim(SZS->ZS_PARECER)+Chr(13)+Chr(10)
                           ElseIf SZS->ZS_LOG = 'TEC' .AND. UPPER(Alltrim(SZS->ZS_RESP)) $ 'MARCOS'
                                  cMenPar += "PARECER TÉCNICO      - "+AllTrim(SZS->ZS_PARECER)+Chr(13)+Chr(10)
                           Endif
                        Else
                           If SZS->ZS_LOG $ 'TEC'
                              cMenPar += "PARECER TÉCNICO      - "+AllTrim(SZS->ZS_PARECER)+Chr(13)+Chr(10)
                           Endif
                        Endif
                 ElseIf SZS->ZS_LOG $ 'REC'
                        cMenPar += "PARECER RECEBIMENTO      - "+AllTrim(SZS->ZS_PARECER)+Chr(13)+Chr(10)
                 Endif
                 DbSelectArea("SZS")
                 DbSkip()
           Enddo
           fMonHTML(@cCodHtm, @cMenSAC, @cResSAC, @cNumSac, @cEmiSAC, cCliSAC, cMenPar)
           
           CONNECT SMTP SERVER cSerNew ACCOUNT cAccNew PASSWORD cPasNew Result lConectou
           lRet := lConectou
		   // Se a conexao com o SMPT esta ok
		   If lRet
	       // Se existe autenticacao para envio valida pela funcao MAILAUTH
	        	If lRelauth
		  			lRet := Mailauth(cAccNew,cPasNew)	
		  		Else
					lRet := .T.	
    	  		Endif    
    
                SEND MAIL FROM 'brasiluxtintas@brasilux.com.br';
                TO cToRep;
                SUBJECT cSubNew;
                BODY cCodHTM;
                RESULT lEnviado
          
                If !lEnviado
                    cMenSAC := ""
                    GET MAIL ERROR cMenNew
                    MsgBox(cMenNew, "Erro...", "STOP") //cMenSAC
                Endif
          
           		DISCONNECT SMTP SERVER Result lDisConectou
           Else
           		GET MAIL ERROR cMenNew
				//LGS#20200211 - Adequação de release 12.1.25 e posteriores
				//Conout('Erro de Autenticação. Verifique a conta e a senha para envio')
                FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', 'Erro de Autenticação. Verifique a conta e a senha para envio', 0 )
		   Endif
           	  RecLock("SZS", .t.)
              SZS->ZS_FILIAL  := xFilial("SZS")
              SZS->ZS_NUM     := SZQ->ZQ_NUM
              SZS->ZS_SEQ     := '001'
              SZS->ZS_LOG     := 'EMA'
              SZS->ZS_DATA    := dDatabase
              SZS->ZS_HORA    := TIME()
              SZS->ZS_RESP    := cUsername
              SZS->ZS_DEPTO   := cDepUsu
              SZS->ZS_PROCEDE := ''
              SZS->ZS_PARECER := Alltrim(cObsRep)
              SZS->ZS_REUTIL  := ''
              SZS->ZS_ESTOQUE := ''
           MsUnLock()
        Endif
     Endif
Return

Static Function fMonHTML(cCodHtm, cMenSAC, cResSAC, cNumSac, cEmiSAC, cCliSAC, cMenPar)
       cCodHtm += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">'
       cCodHtm += '<HTML>'
       cCodHtm += '    <HEAD>'
       cCodHtm += '        <META HTTP-EQUIV="CONTENT-TYPE" CONTENT="text/html; charset=windows-1252">'
       cCodHtm += '        <TITLE>SIGAQDO</TITLE>'
       cCodHtm += '        <META NAME="GENERATOR" CONTENT="OpenOffice.org 1.1.0  (Win32)">'
       cCodHtm += '        <META NAME="CREATED" CONTENT="20030512;10464508">'
       cCodHtm += '        <META NAME="CHANGED" CONTENT="20041011;14210060">'
       cCodHtm += '    </HEAD>'
       cCodHtm += '    <BODY LANG="pt-BR" BGCOLOR="#ffffff" DIR="LTR">'
       cCodHtm += '        <TABLE WIDTH=654 BORDER=1 BORDERCOLOR="#0099cc" CELLPADDING=2 CELLSPACING=3 STYLE="page-break-before: always">'
       cCodHtm += '            <COL WIDTH=642>'
       cCodHtm += '                <TR>'
       cCodHtm += '                    <TD WIDTH=642 BGCOLOR="#0099cc">'
       cCodHtm += '                        <P ALIGN=CENTER><FONT COLOR="#ffffff"><FONT FACE="Courier New"><FONT SIZE=4><B>MENSAGEM</B></FONT></FONT></FONT></P>'
       cCodHtm += '                    </TD>'
       cCodHtm += '                </TR>'
       cCodHtm += '                <TR>'
       cCodHtm += '                    <TD WIDTH=642 HEIGHT=30>'
       cCodHtm += '                        <P ALIGN=CENTER>'+cMenSAC+'.</P>'
       cCodHtm += '                    </TD>'
       cCodHtm += '                </TR>'
       cCodHtm += '        </TABLE>'
       cCodHtm += '        <P STYLE="margin-bottom: 0cm"><BR>'
       cCodHtm += '        </P>'
       cCodHtm += '        <P STYLE="margin-bottom: 0cm"><BR>'
       cCodHtm += '        </P>'
       cCodHtm += '        <P STYLE="margin-bottom: 0cm"><BR>'
       cCodHtm += '        </P>'
       cCodHtm += '        <TABLE WIDTH=655 BORDER=1 BORDERCOLOR="#23b8dc" CELLPADDING=2 CELLSPACING=3>'
       cCodHtm += '            <COL WIDTH=94>'
       cCodHtm += '            <COL WIDTH=163>'
       cCodHtm += '            <COL WIDTH=0>'
       cCodHtm += '            <COL WIDTH=370>'
       cCodHtm += '            <THEAD>'
       cCodHtm += '                <TR>'
       cCodHtm += '                    <TD COLSPAN=3 WIDTH=266 HEIGHT=28>'
       cCodHtm += '                        <P ALIGN=LEFT><B>A/C Sr(a): <I>'+cResSAC+'</I></B>'
       cCodHtm += '                        </P>'
       cCodHtm += '                    </TD>'
       cCodHtm += '                    <TD WIDTH=370>'
       cCodHtm += '                        <P ALIGN=LEFT><B>SAC N&ordm;.: <I>'+cNumSac+'</I></B></P>'
       cCodHtm += '                    </TD>'
       cCodHtm += '                </TR>'
       cCodHtm += '            </THEAD>'
       cCodHtm += '            <TBODY>'
       cCodHtm += '                <TR>'
       cCodHtm += '                    <TD COLSPAN=4 WIDTH=643 HEIGHT=24 VALIGN=TOP>'
       cCodHtm += '                       <P ALIGN=LEFT><B>CLIENTE.: </B>'+cCliSAC+' '
       cCodHtm += '                       </P>'
       cCodHtm += '                    </TD>'
       cCodHtm += '                </TR>'
       cCodHtm += '                <TR VALIGN=TOP>'
       cCodHtm += '                    <TH WIDTH=94 BGCOLOR="#0099cc">'
       cCodHtm += '                       <P><FONT COLOR="#ffffff"><FONT SIZE=4><SPAN STYLE="background: transparent">Item</SPAN></FONT></FONT></P>'
       cCodHtm += '                    </TH>'
       cCodHtm += '                    <TH WIDTH=163 BGCOLOR="#0099cc">'
       cCodHtm += '                       <P><FONT COLOR="#ffffff"><FONT SIZE=4><SPAN STYLE="background: transparent">C&oacute;digo</SPAN></FONT></FONT></P>'
       cCodHtm += '                    </TH>'
       cCodHtm += '                    <TH COLSPAN=2 WIDTH=372 BGCOLOR="#0099cc">'
       cCodHtm += '                       <P><FONT COLOR="#ffffff"><FONT SIZE=4><SPAN STYLE="background: transparent">Descri&ccedil;&atilde;o</SPAN></FONT></FONT></P>'
       cCodHtm += '                    </TH>'
       cCodHtm += '                </TR>'
       DbSelectArea("SZR")
       DbSetOrder(1)
       DbSeek(xFilial("SZR")+cNumSAC, .t.)
       If Found()
          nY := 0
          While !Eof() .and. SZR->ZR_NUM == cNumSAC
                nY += 1
                cCodHtm += '                <TR VALIGN=TOP>'
                cCodHtm += '                    <TH WIDTH=94 BGCOLOR="#ffffff">'
                cCodHtm += '                       <P><FONT COLOR="#0099cc"><SPAN STYLE="background: transparent">'+StrZero(nY, 2)+'</SPAN></FONT></P>'
                cCodHtm += '                    </TH>'
                cCodHtm += '                    <TH WIDTH=163 BGCOLOR="#ffffff">'
                cCodHtm += '                       <P><FONT COLOR="#0099cc"><SPAN STYLE="background: transparent">'+Alltrim(SZR->ZR_PRODUTO)+'</SPAN></FONT></P>'
                cCodHtm += '                    </TH>'
                cCodHtm += '                    <TH COLSPAN=2 WIDTH=372 BGCOLOR="#ffffff">'
                cCodHtm += '                       <P><FONT COLOR="#0099cc"><SPAN STYLE="background: transparent">'+Posicione("SB1", 1, xFilial("SB1")+SZR->ZR_PRODUTO, "B1_DESC")+'</SPAN></FONT></P>'
                cCodHtm += '                    </TH>'
                cCodHtm += '                </TR>'
                DbSelectArea("SZR")
                DbSkip()
          Enddo
       Endif
       cCodHtm += '                <TR>'
       cCodHtm += '                    <TD COLSPAN=4 WIDTH=643 HEIGHT=106 VALIGN=TOP>'
       cCodHtm += '                       <P ALIGN=LEFT><B>PARECER.: </B>'+cMenPar+'</P>'
       cCodHtm += '                    </TD>'
       cCodHtm += '                </TR>'
       cCodHtm += '            </TBODY>'
       cCodHtm += '        </TABLE>'
       cCodHtm += '            <P><BR><BR>'
       cCodHtm += '            </P>'
       cCodHtm += '            <P>Atenciosamente,<BR>'+cEmiSAC+'<BR><BR><BR>'
       cCodHtm += '            </P>'
       cCodHtm += '            <P><EM><FONT SIZE=2>Mensagem gerada Automaticamente pelo SAC &ndash;'
       cCodHtm += '            Servi&ccedil;o de Atendimento ao Cliente da Brasilux Tintas T&eacute;cnicas'
       cCodHtm += '            Ltda.</FONT></EM></P>'
       cCodHtm += '    </BODY>'
       cCodHtm += '</HTML>'
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FDEVSAC ³ Autor ³ Luís G. de Souza      ³ Data ³ 27/05/08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³                  ³Contato ³                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Devolução pelo SAC                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³  /  /  ³                                               ³±±
±±³              ³  /  /  ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function fDevSAC()
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de cVariable dos componentes                               ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     Local nOpc     := GD_INSERT+GD_DELETE+GD_UPDATE
     If SZQ->ZQ_GEREST $ 'S'
        MsgAlert('Nota Fiscal de Devolução de Estoque já foi gerada!')
        Return
     Endif
     Private aCores := { {"TMP_QTDS == TMP_QTDC", "BR_VERDE"}   ,;
                         {"TMP_QTDS <> TMP_QTDC", "BR_VERMELHO"} }
     Private cCodCli    := SZQ->ZQ_CLIENTE
     Private cEspDoc    := "NFE"
     Private cLojCli    := Posicione("SA1", 1, xFilial("SA1")+SZQ->ZQ_CLIENTE, "A1_LOJA")
     Private cNomCli    := Posicione("SA1", 1, xFilial("SA1")+SZQ->ZQ_CLIENTE, "A1_NOME")
     Private cNumNFD    := Iif(Empty(SZQ->ZQ_NFDEV)  , Space(9), SZQ->ZQ_NFDEV)
     Private cSerNFD    := Iif(Empty(SZQ->ZQ_SERDEV) , Space(3), SZQ->ZQ_SERDEV)
     Private ddatEmi    := Iif(Empty(SZQ->ZQ_DTNFDEV), CtoD("  /  /  "), SZQ->ZQ_DTNFDEV)
     Private aCoBrw1    := {}
     Private aHoBrw1    := {}
     Private noBrw1     := 0

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de Variaveis Private dos Objetos                           ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oDlg1"  , "oGrp1"  , "oSay1"  , "oSay2", "oSay3", "oSay4", "oSay5", "oSerNFD", "oEspDoc", "odatEmi", "oCodCli")
     SetPrvt("oNomCli", "oBrwEnt", "oNumNFD", "oBtn1", "oBtn2", "oBtn3")

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Definicao do Dialog e todos os seus componentes.                      ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oDlg1      := MSDialog():New( 088, 232, 428, 924, "Recebimento de Devoluções", , , .F., , , , , , .T., , , .T. )
     oGrp1      := TGroup():New( 000, 000, 035, 344, "", oDlg1, CLR_BLACK, CLR_WHITE, .T., .F. )
     oSay1      := TSay():New( 008, 004,{||"Numero da NF:"}, oGrp1, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 037, 008)
     oSay2      := TSay():New( 008, 092,{||"Série:"}       , oGrp1, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 037, 008)
     oSay3      := TSay():New( 008, 168,{||"Espéc.Docum.:"}, oGrp1, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 037, 008)
     oSay4      := TSay():New( 008, 244,{||"Dt. Emissão:"} , oGrp1, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 037, 008)
     oSay5      := TSay():New( 021, 004,{||"Cliente:"}     , oGrp1, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 032, 008)
     oNumNFD    := TGet():New( 007, 044, {|u| If(PCount()>0, cNumNFD:=u, cNumNFD)}, oDlg1, 036, 008, '', , CLR_BLACK, CLR_WHITE, , , , .T., "", , { || .t.}                          , .F., .F., , .F., .F., ""   , "cNumNFD", , )
     oSerNFD    := TGet():New( 007, 132, {|u| If(PCount()>0, cSerNFD:=u, cSerNFD)}, oGrp1, 024, 008, '', , CLR_BLACK, CLR_WHITE, , , , .T., "", , { || .t.}                          , .F., .F., , .F., .F., ""   , "cSerNFD", , )
     oEspDoc    := TGet():New( 007, 208, {|u| If(PCount()>0, cEspDoc:=u, cEspDoc)}, oGrp1, 024, 008, '', , CLR_BLACK, CLR_WHITE, , , , .T., "", , { || .f.}                          , .F., .F., , .F., .F., "42" , "cEspDoc", , )
     odatEmi    := TGet():New( 007, 284, {|u| If(PCount()>0, ddatEmi:=u, ddatEmi)}, oGrp1, 044, 008, '', , CLR_BLACK, CLR_WHITE, , , , .T., "", , { || .t.}                          , .F., .F., , .F., .F., ""   , "ddatEmi", , )
     oCodCli    := TGet():New( 020, 044, {|u| If(PCount()>0, cCodCli:=u, cCodCli)}, oGrp1, 036, 008, '', , CLR_BLACK, CLR_WHITE, , , , .T., "", , { || .f.}                          , .F., .F., , .F., .F., "SA1", "cCodCli", , )
     oLojCli    := TGet():New( 020, 084, {|u| If(PCount()>0, cLojCli:=u, cLojCli)}, oGrp1, 016, 008, '', , CLR_BLACK, CLR_WHITE, , , , .T., "", , { || .f.}, .F., .F., , .F., .F., ""   , "cLojCli", , )
     oNomCli    := TGet():New( 020, 104, {|u| If(PCount()>0, cNomCli:=u, cNomCli)}, oGrp1, 224, 008, '', , CLR_BLACK, CLR_WHITE, , , , .T., "", , { || .f.}, .F., .F., , .F., .F., ""   , "cNomCli", , )
     //oNumNFD:bValid := {|| If(Empty(cNumNFD), oNumNFD:SetFocus(), oSerNFD:SetFocus())}
     //oSerNFD:bValid := {|| oDatEmi:SetFocus()}
     //oDatEmi:bValid := {|| If(Empty(dDatEmi), oDatEmi:SetFocus(), )}
     MHoBrw1()
     MCoBrw1()
     oBrw1      := MsNewGetDados():New(036, 000, 148, 344, nOpc, 'u_SACX02_5("L")', 'AllwaysTrue()', '+D1_ITEM', {"ZR_PRODUTO", "ZR_LOCDEV", "ZR_QTDDEV" }, 0, 999, 'u_SACX02_5("C")', 'AllwaysTrue()', {|| u_fApaIte()}  , oDlg1, aHoBrw1, aCoBrw1 )
     
     oBtn1      := TButton():New( 152, 304, "Sair"    ,oDlg1, { || oDlg1:End() }, 037, 012, , , , .T., , "", , , , .F. )
     oBtn2      := TButton():New( 152, 004, "Gerar NF",oDlg1, { || fGrvDev("G")}, 037, 012, , , , .T., , "", , , , .F. )
     oBtn3      := TButton():New( 152, 060, "Grava"   ,oDlg1, { || fGrvDev("N")}, 037, 012, , , , .T., , "", , , , .F. )
     oBtn4      := TButton():New( 152, 116, "Dividir" ,oDlg1, { || fGrvDev("D")}, 037, 012, , , , .T., , "", , , , .F. )

     oDlg1:Activate(,,,.T.)
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MHoBrw1() - Monta aHeader da MsNewGetDados para o Alias: TMP
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MHoBrw1()
       noBrw1++
       Aadd(aHoBrw1,{'Item'     , 'D1_ITEM'    , '99'                 , 002, 0, "", "", 'C', "", "" } )
       noBrw1++
       Aadd(aHoBrw1,{'Produto'  , 'ZR_PRODUTO' , '@!R XXX99.99.999-99', 015, 0, "", "", 'C', "", "" } )
       noBrw1++
       Aadd(aHoBrw1,{'Descrição', 'ZR_DESCPRO' , '@!'                 , 030, 0, "", "", 'C', "", "" } )
       noBrw1++
       Aadd(aHoBrw1,{'Local'    , 'ZR_LOCDEV'  , ''                   , 002, 0, "", "", 'C', "", "" } )
       noBrw1++
       Aadd(aHoBrw1,{'Qtd. SAC' , 'ZR_QTD'     , '@E 9999'            , 004, 0, "", "", 'N', "", "" } )
       noBrw1++
       Aadd(aHoBrw1,{'Qtd. Dev.', 'ZR_QTDDEV'  , '@E 9999'            , 004, 0, "", "", 'N', "", "" } )
       noBrw1++
       Aadd(aHoBrw1,{'Lote'     , 'ZR_LOTE'    , '@!'                 , 002, 0, "", "", 'C', "", "" } )
       noBrw1++
       Aadd(aHoBrw1,{'It. SAC'  , 'ZR_SEQITEM' , '99'                 , 002, 0, "", "", 'C', "", "" } )
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MCoBrw1() - Monta aCols da MsNewGetDados para o Alias: TMP
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MCoBrw1()
       //Local aAux := {}
       Local nI
       DbSelectArea("SZR")
       DbSetOrder(1)
       DbSeek(xFilial("SZR")+SZQ->ZQ_NUM, .t.)
       If Found()
          cLocDev := ""
          cQtdDev := ""
          nConIte := 1
          While !Eof() .and. SZR->ZR_NUM == SZQ->ZQ_NUM
                cLocDev := SZR->ZR_LOCDEV2
                cQtdDev := SZR->ZR_QTDDEV2
                If Empty(cLocDev)
                   cLocBrw := '  '
                   cQtdBrw := '0000'
                   aAdd(aCoBrw1, {StrZero(nConIte, 2), SZR->ZR_PRODUTO, Posicione("SB1", 1, xFilial("SB1")+SZR->ZR_PRODUTO, "B1_DESC"), cLocBrw, SZR->ZR_QTD, Val(cQtdBrw), SZR->ZR_LOTE, SZR->ZR_SEQITEM, .f.})
                   nConIte += 1
                Else
                   While !Empty(cLocDev)
                         cLocBrw := SubStr(cLocDev, 1, 2)
                         cQtdBrw := SubStr(cQtdDev, 1, 4)
                         aAdd(aCoBrw1, {StrZero(nConIte, 2), SZR->ZR_PRODUTO, Posicione("SB1", 1, xFilial("SB1")+SZR->ZR_PRODUTO, "B1_DESC"), cLocBrw, SZR->ZR_QTD, Val(cQtdBrw), SZR->ZR_LOTE, SZR->ZR_SEQITEM, .f.})
                         nConIte += 1
                         cLocDev := SubStr(cLocDev, 4, Len(cLocDev)-3)
                         cQtdDev := SubStr(cQtdDev, 6, Len(cLocDev)-5)
                   EndDo
                Endif
                DbSelectARea("SZR")
                DbSkip()
          Enddo
       Else
          Aadd(aCoBrw1, Array(noBrw1+1))
          For nI := 1 To noBrw1
              aCoBrw1[1][nI] := CriaVar(aHoBrw1[nI][2])
          Next
          aCoBrw1[1][noBrw1+1] := .F.
       Endif
Return

User Function SACX02_5(cValBrw)
     If cValBrw $ 'L'
        If Empty(aCoBrw1[oBrw1:nAt][aScan(aHoBrw1, {|x| Alltrim(Upper(x[2])) == 'ZR_LOCDEV'})])
           MsgAlert('Atenção, LOCAL não pode ser em branco.')
           Return(.f.)
        Endif
        If aCoBrw1[oBrw1:nAt][aScan(aHoBrw1, {|x| Alltrim(Upper(x[2])) == 'ZR_QTDDEV'})] <= 0.0
           MsgAlert('Atenção, QTD. DEV. não pode ser zero.')
           Return(.f.)
        Endif
     ElseIf cValBrw $ 'C'
            If Alltrim(__ReadVar) $ 'M->ZR_LOCDEV'
               If !ExistCpo("SX5", '99'+M->ZR_LOCDEV)
                  //MsgStop("Armazem inválido!")
                  aCoBrw1[oBrw1:nAt][aScan(aHoBrw1, {|x| Alltrim(Upper(x[2])) == 'ZR_LOCDEV'})] := space(02)
                  M->ZR_LOCDEV := space(02)
                  Return(.f.)
               Else
                  aCoBrw1[oBrw1:nAt][aScan(aHoBrw1, {|x| Alltrim(Upper(x[2])) == 'ZR_LOCDEV'})] := M->ZR_LOCDEV
               Endif
            ElseIf Alltrim(__ReadVar) $ 'M->ZR_QTDDEV'
                   If M->ZR_QTDDEV <= 0
                      MsgStop("Quantidade inválida!")
                      aCoBrw1[oBrw1:nAt][aScan(aHoBrw1, {|x| Alltrim(Upper(x[2])) == 'ZR_QTDDEV'})] := space(02)
                      M->ZR_QTDDEV := space(02)
                   Else
                      aCoBrw1[oBrw1:nAt][aScan(aHoBrw1, {|x| Alltrim(Upper(x[2])) == 'ZR_QTDDEV'})] := M->ZR_QTDDEV
                   Endif
            ElseIf Alltrim(__ReadVar) $ 'M->ZR_PRODUTO'
                   If !ExistCpo("SB1", xFilial("SB1")+M->ZR_PRODUTO)
                      oBrw1:aCols[oBrw1:nAt][aScan(aHoBrw1, {|x| Alltrim(Upper(x[2])) == 'ZR_PRODUTO'})] := space(15)
                      M->ZR_PRODUTO:= space(15)
                      oBrw1:aCols[oBrw1:nAt][aScan(aHoBrw1, {|x| Alltrim(Upper(x[2])) == 'ZR_DESCPRO'})] := space(30)
                   Else
                      aCoBrw1[oBrw1:nAt][aScan(aHoBrw1, {|x| Alltrim(Upper(x[2])) == 'ZR_PRODUTO'})] := M->ZR_LOCDEV
                   Endif
            Endif
     Endif
Return(.t.)

Static Function fGrvDev(cOpcG)
       Local nZ
       If cOpcG $ 'N'     //Grava informações da Devolução
          lDivGrv := .f.
          For nZ := 1 To Len(oBrw1:aCols)
              If !oBrw1:aCols[nZ][noBrw1+1]
                 If Empty(oBrw1:aCols[nZ][4]) .or. oBrw1:aCols[nZ][6] <= 0
                    lDivGrv := .t.
                 Endif
              Endif
          Next
          If !lDivGrv
             RecLock("SZQ", .f.)
                SZQ->ZQ_NFDEV   := cNumNFD
                SZQ->ZQ_SERDEV  := cSerNFD
                SZQ->ZQ_DTNFDEV := dDatEmi
                SZQ->ZQ_GEREST  := 'N'
             MsUnLock()
             aGrvIte := {}
             For nZ := 1 To Len(oBrw1:aCols)
                 If !oBrw1:aCols[nZ][noBrw1+1]
                    DbSelectArea("SZR")
                    DbSetOrder(1)
                    DbSeek(xFilial("SZR")+SZQ->ZQ_NUM+oBrw1:aCols[nZ][8], .t.)
                    If Found()
                       nPos := aScan(aGrvIte, {|x| x[1] == xFilial("SZR")+SZQ->ZQ_NUM+oBrw1:aCols[nZ][8]})
                       If nPos == 0
                          aAdd(aGrvIte, {xFilial("SZR")+SZQ->ZQ_NUM+oBrw1:aCols[nZ][8], oBrw1:aCols[nZ][4], StrZero(oBrw1:aCols[nZ][6], 4)} )
                       Else
                          aGrvIte[nPos][2] += '.'+oBrw1:aCols[nZ][4]
                          aGrvIte[nPos][3] += '.'+StrZero(oBrw1:aCols[nZ][6], 4)
                       Endif
                    Endif
                 Endif
             Next
             For nZ := 1 To Len(aGrvIte)
                 DbSelectArea("SZR")
                 DbSetOrder(1)
                 DbSeek(aGrvIte[nZ][1], .t.)
                 If Found()
                    RecLock("SZR", .f.)
                       SZR->ZR_LOCDEV2 := aGrvIte[nZ][2]
                       SZR->ZR_QTDDEV2 := aGrvIte[nZ][3]
                    MsUnLock()
                 Endif
             Next
             oDlg1:End()
          Else
             MsgStop("Existe Local ou quantidade inválidos. Verifique!")
          Endif
       ElseIf cOpcG $ 'G' //Grava Nota Fiscal de Devolução
              Private lMsErroAuto := .F. 
              Private _aCabec     := {}
              Private _aItem1     := {}                 
              Private _aItens     := {}
              
              If Empty(cNumNFD) .or. Empty(dDatEmi)
                 MsgStop("Atenção, Numero da Nota ou Data de Emissão estão com seu conteúdo vazio. Verifique!!!")
                 Return
              Endif
              cLojCli := Posicione("SA1", 1, xFilial("SA1")+SZQ->ZQ_CLIENTE, "A1_LOJA")
              cEstCli := Posicione("SA1", 1, xFilial("SA1")+SZQ->ZQ_CLIENTE, "A1_EST")

              aAdd(_aCabec,  {"F1_FILIAL"  , xFilial("SF1") , Nil})
              aAdd(_aCabec,  {"F1_TIPO"    , "B"            , Nil})
              aAdd(_aCabec,  {"F1_DOC"     , SZQ->ZQ_NUM    , Nil})
              aAdd(_aCabec,  {"F1_SERIE"   , "SAC"          , Nil})
              aAdd(_aCabec,  {"F1_EMISSAO" , ddatabase      , Nil})
              aAdd(_aCabec,  {"F1_ESPECIE" , "NFE"          , Nil})
              aAdd(_aCabec,  {"F1_DTDIGIT" , ddatabase      , Nil})
              aAdd(_aCabec,  {"F1_FORMUL"  , "N"            , Nil})
              aAdd(_aCabec,  {"F1_FORNECE" , SZQ->ZQ_CLIENTE, Nil})
              aAdd(_aCabec,  {"F1_LOJA"    , cLojCli        , Nil}) 
              aAdd(_aCabec,  {"F1_EST"     , cEstCli        , Nil})

              For nZ := 1 To Len(aCoBrw1)
                  If !aCoBrw1[nZ][noBrw1+1]
                     nVlrUni := 0
                     If Posicione("SB1", 1, xFilial("SB1")+aCoBrw1[nZ][aScan(aHoBrw1, {|x| Alltrim(Upper(x[2])) == 'ZR_PRODUTO'})], "B1_TIPO") $ 'MP.GG'
                        nVlrUni := Posicione("SB1", 1, xFilial("SB1")+aCoBrw1[nZ][aScan(aHoBrw1, {|x| Alltrim(Upper(x[2])) == 'ZR_PRODUTO'})], "B1_UPRC")
                     Else
                        If Posicione("SB1", 1, xFilial("SB1")+aCoBrw1[nZ][aScan(aHoBrw1, {|x| Alltrim(Upper(x[2])) == 'ZR_PRODUTO'})], "B1_ESTOQUE") $ 'S'
                           nVlrUni := Posicione("SB1", 1, xFilial("SB1")+aCoBrw1[nZ][aScan(aHoBrw1, {|x| Alltrim(Upper(x[2])) == 'ZR_PRODUTO'})], "B1_PRV1")
                        Else
                           nVlrUni := Posicione("SB5", 1, xFilial("SB5")+aCoBrw1[nZ][aScan(aHoBrw1, {|x| Alltrim(Upper(x[2])) == 'ZR_PRODUTO'})], "B5_PRV2")
                        Endif
                     Endif

                     cCodPro := aCoBrw1[nZ][aScan(aHoBrw1, {|x| Alltrim(Upper(x[2])) == 'ZR_PRODUTO'})]
                     nQtdDev := aCoBrw1[nZ][aScan(aHoBrw1, {|x| Alltrim(Upper(x[2])) == 'ZR_QTDDEV'}) ]
                     cTesEnt := '082'
                     cCFOEnt := '000' //Iif(Posicione("SA1", 1, xFilial("SA1")+SZQ->ZQ_CLIENTE, "A1_EST") $ 'SP', '1', '2')+SubStr(Posicione("SF4", 1, xFilial("SF4")+'082', "F4_CF"), 2, 3)

                     DbSelectArea("SB1")
                     DbSetOrder(1)
                     DbSeek(xFilial("SB1")+cCodPro, .t.)
                     cUniMed := SB1->B1_UM
                     cTipPro := SB1->B1_TIPO
                     cLocPro := aCoBrw1[nZ][4]
                     _aItem1 := { {"D1_COD"    , cCodPro                          , NIL},;
                                  {"D1_ITEM"   , StrZero(nZ, TamSX3("D1_ITEM")[1]), NIL},;
                                  {"D1_DOC"    , SZQ->ZQ_NUM                      , NIL},;
                                  {"D1_UM"     , cUniMed                          , NIL},;
                                  {"D1_QUANT"  , nQtdDev                          , NIL},;
                                  {"D1_VUNIT"  , nVlrUni                          , NIL},;
                                  {"D1_TOTAL"  , nVlrUni * nQtdDev                , NIL},;
                                  {"D1_PICM"   , 0                                , NIL},;
                                  {"D1_VALICM" , 0                                , NIL},;
                                  {"D1_TES"    , cTesEnt                          , NIL},;
                                  {"D1_CF"     , cCFOEnt                          , NIL},;
                                  {"D1_RATEIO" , ""                               , NIL},;
                                  {"D1_FORNECE", SZQ->ZQ_CLIENTE                  , NIL},;
                                  {"D1_LOJA"   , cLojCli                          , NIL},;
                                  {"D1_EMISSAO", dDataBase                        , NIL},;
                                  {"D1_DTDIGIT", dDataBase                        , NIL},;
                                  {"D1_TIPO"   , "N"                              , NIL},;
                                  {"D1_TP"     , cTipPro                          , NIL},;
                                  {"D1_LOCAL"  , cLocPro                          , NIL} }
                     aAdd(_aItens, _aItem1)
                  Endif
              Next
              nModulo := 2
              MSExecAuto({|x, y, z| MATA103(x, y, z)}, _aCabec, _aItens, 3)
              xxx := 0
              If lMsErroAuto
                 If Aviso("Pergunta", "Devolução não gerada. Deseja visualizar o log?", {"Sim","Nao"}, 1, "Atencao") = 1
                    MostraErro()
                 Endif
                 nModulo := 13
              Else
                 nModulo := 13
                 DbSelectArea("SZQ")
                 RecLock("SZQ", .f.)
                    SZQ->ZQ_NFDEV   := cNumNFD
                    SZQ->ZQ_SERDEV  := cSerNFD
                    SZQ->ZQ_DTNFDEV := dDatEmi
                    SZQ->ZQ_GEREST  := 'S'
                 MsUnLock()
             aGrvIte := {}
             For nZ := 1 To Len(oBrw1:aCols)
                 If !oBrw1:aCols[nZ][noBrw1+1]
                    DbSelectArea("SZR")
                    DbSetOrder(1)
                    DbSeek(xFilial("SZR")+SZQ->ZQ_NUM+oBrw1:aCols[nZ][8], .t.)
                    If Found()
                       nPos := aScan(aGrvIte, {|x| x[1] == xFilial("SZR")+SZQ->ZQ_NUM+oBrw1:aCols[nZ][8]})
                       If nPos == 0
                          aAdd(aGrvIte, {xFilial("SZR")+SZQ->ZQ_NUM+oBrw1:aCols[nZ][8], oBrw1:aCols[nZ][4], StrZero(oBrw1:aCols[nZ][6], 4)} )
                       Else
                          aGrvIte[nPos][2] += '.'+oBrw1:aCols[nZ][4]
                          aGrvIte[nPos][3] += '.'+StrZero(oBrw1:aCols[nZ][6], 4)
                       Endif
                    Endif
                 Endif
             Next
             For nZ := 1 To Len(aGrvIte)
                 DbSelectArea("SZR")
                 DbSetOrder(1)
                 DbSeek(aGrvIte[nZ][1], .t.)
                 If Found()
                    RecLock("SZR", .f.)
                       SZR->ZR_LOCDEV2 := aGrvIte[nZ][2]
                       SZR->ZR_QTDDEV2 := aGrvIte[nZ][3]
                    MsUnLock()
                 Endif
             Next
                 MsgInfo("NF Devolução gerada!")
                 oDlg1:End()
              Endif
       ElseIf cOpcG $ 'D' //Divide Itens de Devolução
              If !Empty(oBrw1:aCols[oBrw1:nAt][2])
                 aAdd(aCoBrw1    , {StrZero(Len(aCoBrw1)    +1, 2), aCoBrw1[oBrw1:nAt][2], aCoBrw1[oBrw1:nAt][3], space(02), aCoBrw1[oBrw1:nAt][5], 0.0, aCoBrw1[oBrw1:nAt][7], aCoBrw1[oBrw1:nAt][8], aCoBrw1[oBrw1:nAt][9]})
                 aAdd(oBrw1:aCols, {StrZero(Len(oBrw1:aCols)+1, 2), aCoBrw1[oBrw1:nAt][2], aCoBrw1[oBrw1:nAt][3], space(02), aCoBrw1[oBrw1:nAt][5], 0.0, aCoBrw1[oBrw1:nAt][7], aCoBrw1[oBrw1:nAt][8], aCoBrw1[oBrw1:nAt][9]})
                 oBrw1:nAt := Len(oBrw1:aCols)
              Endif
       Endif
Return

User Function fApaIte()
     aCoBrw1[oBrw1:nAt][noBrw1+1] := !aCols[oBrw1:nAt][noBrw1+1]
     aCols[oBrw1:nAt][noBrw1+1]   := !aCols[oBrw1:nAt][noBrw1+1]
     oBrw1:oBrowse:Refresh()
Return