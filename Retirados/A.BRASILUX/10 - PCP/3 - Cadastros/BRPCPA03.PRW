#include "protheus.ch"
#include "topconn.ch"
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥ BRPCPA03 ≥ Autor ≥ LuÌs G. de Souza      ≥ Data ≥ 13/07/06 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Coletor de dados da ProduÁ„o                               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ BRASILUX TINTAS T…CNICAS LTDA.                             ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function BRPCPA03()
     Local cIniFile  := GetAdv97()
     Local cDataBase :=       GetPvProfString("TopConnect", "DataBase"    , "ERROR", cInIfile )
     Local cAlias    :=       GetPvProfString("TopConnect", "Alias"       , "ERROR", cInIfile )
     Local cServer   :=       GetPvProfString("TopConnect", "Server"      , "ERROR", cInIfile )
     Local cConType  := Upper(GetPvProfString("TopConnect", "Contype"     , "TCPIP", cInIfile ))
     Local cHasMapper:= Upper(GetPvProfString("TopConnect", "Mapper"      , "ON"   , cInIfile ))
     Local cProtect  :=       GetPvProfString("TopConnect", "ProtheusOnly", "0"    , cInIfile )
     Local nPort     := Val(  GetPvProfString("TopConnect", "Port"        , "0"    , cInIfile ))
     Local xConnect  := GetGlbValue("MYTOPCONNECT")
     //Local cMsgSai := OemToAnsi('Sair da opÁ„o iniciar')
     Local cMsgIni := OemToAnsi('Iniciar pesagem dos produtos')
     Local cMsgFim := OemToAnsi('Finalizar pesagem dos produtos')
     Local cMsgEnv := OemToAnsi('Envase dos produtos')
     Local lSair   := .f.
     If Empty(xConnect)
        // Ajuste pelo Environment do Server
        cDataBase :=       GetSrvProfString("TopDataBase"    , cDataBase)
        cAlias    :=       GetSrvProfString("TopAlias"       , cAlias)
        cServer	  :=       GetSrvProfString("TopServer"      , cServer)
        cConType  := Upper(GetSrvProfString("TopContype"     , cConType))
        cHasMapper:= Upper(GetSrvProfString("TopMapper"      , cHasMapper))
        cProtect  :=       GetSrvProfString("TopProtheusOnly", cProtect)
        nPort     := Val(  GetSrvProfString("TopPort"        , StrZero(nPort, 4, 0))) //So Para Conexao TCPIP

        xConnect := AllTrim(cDataBase) + "#" + AllTrim(cAlias)     + "#" + AllTrim(cServer)  + "#" + ;
                    AllTrim(cConType)  + "#" + AllTrim(cHasMapper) + "#" + AllTrim(cProtect) + "#" + ;
                    StrZero(nPort, 4, 0)
        PutGlbValue("MYTOPCONNECT", xConnect)
     Else
        xConnect  := StrTokArr(xConnect, "#")
        cDataBase :=     xConnect[1]
        cAlias    :=     xConnect[2]
        cServer	  :=     xConnect[3]
        cConType  :=     xConnect[4]
        cHasMapper:=     xConnect[5]
        cProtect  :=     xConnect[6]
        nPort     := Val(xConnect[7])
     EndIf
     If cProtect == "1"
        cProtect := "@@__@@" //Assinatura para o TOP
     Else
        cProtect := ""
     Endif
     RpcSetType(3) //Desabilita utilizaÁ„o de Licensa
     DEFINE WINDOW oMainWnd FROM 1, 1 TO 400, 500 TITLE 'x'
     DEFINE MSDIALOG oDlgEnt FROM 0, 0 TO 300, 390 PIXEL TITLE OemToAnsi("Apontamento de ProduÁ„o") OF oMainWnd
     DEFINE FONT oFont1 NAME 'ARIAL BACK' SIZE 14,0 BOLD
     DEFINE FONT oFont2 NAME 'ARIAL BACK' SIZE 08,0 BOLD
            @ 010, 010 BTNBMP oBtnIni RESOURCE "HISTORIC" SIZE 373,050 ACTION(fAptIniPro(cConType, cProtect, cDataBase, cAlias, cServer, nPort)) PIXEL OF oDlgEnt
            @ 100, 010 BTNBMP oBtnFim RESOURCE "PMSRELA"  SIZE 373,050 ACTION(                           ) PIXEL OF oDlgEnt
            @ 200, 010 BTNBMP oBtnEnv RESOURCE "CONTAINR" SIZE 373,050 ACTION(                           ) PIXEL OF oDlgEnt
            @ 275, 260 BTNBMP oBtnSai RESOURCE "CANCEL"   SIZE 130,024 ACTION(lSair := .t., oDlgEnt:End()) PIXEL OF oDlgEnt

            oBtnIni:oFont              := oFont1
            oBtnIni:cCaption           := PADR(OemToAnsi("INICIAR PRODU«√O"), 20)
            oBtnIni:cToolTip           := cMsgIni
            oBtnFim:oFont              := oFont1
            oBtnFim:cCaption           := PADR(OemToAnsi("FINALIZAR PRODU«√O"), 20)
            oBtnFim:cToolTip           := cMsgFim
            oBtnFim:lVisible           := .f.
            oBtnEnv:oFont              := oFont1
            oBtnEnv:cCaption           := PADR(OemToAnsi("E N V A S E"), 20)
            oBtnEnv:cToolTip           := cMsgEnv
            oBtnEnv:lVisible           := .f.
            oBtnSai:oFont              := oFont2
            oBtnSai:cCaption           := PADR(OemToAnsi("SAIR"), 20)
            oBtnSai:cToolTip           := cMsgIni
            oDlgEnt:nStyle := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
     ACTIVATE MSDIALOG oDlgEnt CENTERED VALID lSair 
Return Nil

/******************************************************************************************************************/
/*** FAPTINIPRO - APONTAMENTO DO INICIO DA PRODU«√O DE PRODUTOS INTERMEDI¡RIOS                                  ***/
/******************************************************************************************************************/
Static Function fAptIniPro(cConType, cProtect, cDataBase, cAlias, cServer, nPort)
       Local aNumOrd := {{'', '', '', '', '', ''}}
       Local cMsgIni := OemToAnsi('Inicia Ordens de ProduÁ„o')
       Local cMsgEst := OemToAnsi('Estorna Ordens de ProduÁ„o iniciadas')
       Local cMsgExi := OemToAnsi('Sair')
       Local cNumOrd := space(11)
       Local lSair   := .f.
       Local oDlg
       Local oFont1
       Local oFont2
       Local oMonitor
       Local oItens
       Local oBtnIni
       Local oBtnExi
       Private oNumOrd
       DEFINE MSDIALOG oDlg FROM 0, 0 TO 518, 790 PIXEL TITLE OemToAnsi("Apontamento de ProduÁ„o - Inicio") OF oMainWnd
       DEFINE FONT oFont1 NAME 'ARIAL BACK' SIZE 16,0 BOLD
       DEFINE FONT oFont2 NAME 'ARIAL BACK' SIZE 08,0 BOLD
       DEFINE FONT oFont3 NAME 'ARIAL' SIZE 10,0 BOLD
       DEFINE TIMER oTimer INTERVAL 120 ACTION (fAtuInfTel(oMonitor, aNumOrd, oDlg, cConType, cProtect, cDataBase, cAlias, cServer, nPort)) OF oDlg

              /******************** 1∫ ESPERA ENTRADA DO NUMERO DA O.P. ********************/
              @ 015, 001 SAY   OemToAnsi("Nr∫. da O.P.:")  SIZE 100,009                                  PIXEL OF oDlg FONT oFont1
              @ 014, 105 MSGET oNumOrd VAR cNumOrd         SIZE 120,010                                  PIXEL OF oDlg FONT oFont1
              @ 028, 470 BTNBMP oBtnIni RESOURCE "OK"      SIZE 140,024 ACTION(fIncInfTel('IP', oMonitor, aNumOrd, oDlg, @cNumOrd, @oNumOrd, cConType, cProtect, cDataBase, cAlias, cServer, nPort), fAtuInfTel(oMonitor, aNumOrd, oDlg, cConType, cProtect, cDataBase, cAlias, cServer, nPort)) PIXEL OF oDlg
              @ 001, 630 BTNBMP oBtnEst RESOURCE "RECALC"  SIZE 160,024 ACTION(fEstInfTel(oMonitor, cNumOrd, oNumOrd, cConType, cProtect, cDataBase, cAlias, cServer, nPort), fAtuInfTel(oMonitor, aNumOrd, oDlg, cConType, cProtect, cDataBase, cAlias, cServer, nPort)) PIXEL OF oDlg
              @ 028, 630 BTNBMP oBtnExi RESOURCE "CANCEL"  SIZE 160,024 ACTION(lSair := .t., oDlg:End()) PIXEL OF oDlg
              /*****************************************************************************/

              /****************** 2∫ MOSTRA BROWSE DAS ORDENS DE PRODU«√O ******************/
              @ 2, 0.2 LISTBOX oMonitor ITEMS oItens FIELDS HEADER "O.P.", "LOTE", "INICIO", "FIM", "PROCESSADO", "" FIELDSIZES 70, 40, 80, 80, 60, 10 SIZE 393, 230 OF oDlg
              /*****************************************************************************/

              oMonitor:SetArray(aNumOrd)
              oMonitor:bLine             := {|| { aNumOrd[oMonitor:nAt][1], aNumOrd[oMonitor:nAt][2], aNumOrd[oMonitor:nAt][3], aNumOrd[oMonitor:nAt][4], aNumOrd[oMonitor:nAt][5], aNumOrd[oMonitor:nAt][6]} }
              oMonitor:lUseDefaultColors := .f.
              oMonitor:nClrText          := CLR_GRAY
              oMonitor:oFont             := oFont3
              oNumOrd:bLostFocus         := {|| lSaiCam := Iif(Empty(cNumOrd), .f., .t.),  Iif(!lSaiCam, , fIncInfTel('IP', oMonitor, aNumOrd, oDlg, @cNumOrd, @oNumOrd, cConType, cProtect, cDataBase, cAlias, cServer, nPort)), Iif(!lSaiCam, , fAtuInfTel(oMonitor, aNumOrd, oDlg, cConType, cProtect, cDataBase, cAlias, cServer, nPort)) }
              oBtnIni:oFont              := oFont2
              oBtnIni:cCaption           := PADR(OemToAnsi("INICIAR"), 20)
              oBtnIni:cToolTip           := cMsgIni
              oBtnEst:oFont              := oFont2
              oBtnEst:cCaption           := PADR(OemToAnsi("ESTORNAR"), 08)
              oBtnEst:cToolTip           := cMsgEst
              oBtnExi:oFont              := oFont2
              oBtnExi:cCaption           := PADR(OemToAnsi("SAIR"), 04)
              oBtnExi:cToolTip           := cMsgExi
              oTimer:Activate()
              oDlg:nStyle                := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
       ACTIVATE MSDIALOG oDlg CENTERED VALID lSair ON INIT (fAtuInfTel(oMonitor, aNumOrd, oDlg, cConType, cProtect, cDataBase, cAlias, cServer, nPort))
Return Nil

/******************************************************************************************************************/
/*** FATUINFTEL - ATUALIZA INFORMA«’ES DA TELA DE INICIO DE PRODU«√O.                                           ***/
/******************************************************************************************************************/
Static Function fAtuInfTel(oMonitor, aNumOrd, oDlg, cConType, cProtect, cDataBase, cAlias, cServer, nPort)
       oTimer:Deactivate()
       aNumOrd := {}
       /*********************************************/
       /***  MONTA CONEX√O COM O BANCO DE DADOS   ***/
       /*********************************************/
       TCCONTYPE(cConType)
       __nConecta := TCLink(cProtect+"@!!@"+cDataBase+"/"+cAlias, cServer, nPort)  // Nao Comer Licenca do Top
       If __nConecta < 0
          MsgStop("N„o foi possÌvel conectar ao Banco de Dados.", "ERROR")
          oNumOrd:SetFocus()
          oTimer:Activate()
          Return
       Endif
       TCSETCONN(__nConecta)

       cQry1 := ""
       cQry1 += "SELECT PRO.ORDEM, PRO.LOTE, "
       cQry1 += "       SUBSTRING(PRO.INICIO, 7, 2)+'/'+SUBSTRING(PRO.INICIO, 5, 2)+'/'+SUBSTRING(PRO.INICIO, 3, 2)+' '+SUBSTRING(PRO.INICIO, 9, 2)+':'+SUBSTRING(PRO.INICIO, 11, 2) AS INICIO, "
       cQry1 += "       SUBSTRING(PRO.FIM   , 7, 2)+'/'+SUBSTRING(PRO.FIM   , 5, 2)+'/'+SUBSTRING(PRO.FIM   , 3, 2)+' '+SUBSTRING(PRO.FIM   , 9, 2)+':'+SUBSTRING(PRO.FIM   , 11, 2) AS FIM, "
       cQry1 += "       CASE WHEN FLAG = 1 THEN 'SIM' ELSE 'NAO' END AS FLAG "
       cQry1 += "FROM PRODUCAO PRO "
       cQry1 += "WHERE SUBSTRING(PRO.INICIO, 1, 8) = '"+DTOS(Date())+"' "
       cQry1 += "ORDER BY 3 DESC "
       TCQuery cQry1 ALIAS "QTMP" NEW
       DbSelectArea("QTMP")
       DbGoTop()
       While !Eof()
             aAdd(aNumOrd, {QTMP->ORDEM, QTMP->LOTE, QTMP->INICIO, QTMP->FIM, QTMP->FLAG, ''})
             DbSelectArea("QTMP")
             DbSkip()
       Enddo
       DbSelectArea("QTMP")
       DbCloseArea()
       oMonitor:SetArray(aNumOrd)
       oMonitor:nAt   := 1
       oMonitor:bLine := {|| { aNumOrd[oMonitor:nAt][1], aNumOrd[oMonitor:nAt][2], aNumOrd[oMonitor:nAt][3], aNumOrd[oMonitor:nAt][4], aNumOrd[oMonitor:nAt][5], aNumOrd[oMonitor:nAt][6]} }
       oMonitor:Refresh()

       /*********************************************/
       /*** DESMONTA CONEX√O COM O BANCO DE DADOS ***/
       /*********************************************/
       TCQuit() //Desmonta conex„o com o banco de dados
       oTimer:Activate()
Return

/******************************************************************************************************************/
/*** FINCINFTEL - APONTA INICIO DA ORDEM DE PRODU«√O.                                                           ***/
/******************************************************************************************************************/
Static Function fIncInfTel(cOpc, oMonitor, aNumOrd, oDlg, cNumOrd, oNumOrd, cConType, cProtect, cDataBase, cAlias, cServer, nPort)
       Local nY
       oTimer:Deactivate()
       /*********************************************/
       /***  MONTA CONEX√O COM O BANCO DE DADOS   ***/
       /*********************************************/
       TCCONTYPE(cConType)
       __nConecta := TCLink(cProtect+"@!!@"+cDataBase+"/"+cAlias, cServer, nPort)  // Nao Comer Licenca do Top
       If __nConecta < 0
          MsgStop("N„o foi possÌvel conectar ao Banco de Dados.", "ERROR")
          cNumOrd := space(11)
          oNumOrd:Refresh()
          oNumOrd:SetFocus()
          oTimer:Activate()
          Return
       Endif
       TCSETCONN(__nConecta)
       If cOpc $ 'IP' //Inicio de ProduÁ„o
          //1∫ Verificar se a O.P. j· foi apontada
          cNumOrd := Iif(Len(Alltrim(cNumOrd)) == 6, cNumOrd+'01001', cNumOrd)
          lNaoApt := .f.
          cQry1 := ""
          cQry1 += "SELECT PRO.ORDEM, PRO.FLAG, PRO.FIM "
          cQry1 += "FROM PRODUCAO PRO "
          cQry1 += "WHERE PRO.ORDEM = '"+SubStr(cNumOrd, 1, 11)+"' "
          TCQuery cQry1 ALIAS "TCQ" NEW
          DbSelectArea("TCQ")
          DbGoTop()
          If TCQ->FLAG == '1' .or. !Empty(TCQ->FIM) //Se a Ordem de ProduÁ„o j· foi apontada, desconecta banco e volta para tela principal.
             MsgStop("Ordem de ProduÁ„o j· foi finalizada!", "AtenÁ„o")
             DbSelectArea("TCQ")
             DbCloseArea()
             TCQuit() //Desmonta conex„o com o banco de dados
             cNumOrd := space(11)
             oNumOrd:Refresh()
             oNumOrd:SetFocus()
             oTimer:Activate()
             Return
          Else //Se a Ordem de ProduÁ„o n„o foi finalizada, efetua consistÍncias
             cAptOrd := TCQ->ORDEM
             DbSelectArea("TCQ")
             DbCloseArea()
             //a) Verificar se O.P. existe e se n„o foi apontada manualmente ou por outro processo
             cQry1 := ""
             cQry1 += "SELECT SC2.C2_LOTE, SC2.C2_PRODUTO, SC2.C2_DATRF "
             cQry1 += "FROM "+RetSqlName("SC2")+" SC2 "
             cQry1 += "WHERE SC2.C2_FILIAL = '01' "
             cQry1 += "  AND SC2.D_E_L_E_T_ = '' "
             cQry1 += "  AND SC2.C2_NUM = '"+SubStr(cNumOrd, 1, 6)+"' "
             cQry1 += "  AND SC2.C2_ITEM = '"+SubStr(cNumOrd, 7, 2)+"' "
             cQry1 += "  AND SC2.C2_SEQUEN = '"+SubStr(cNumOrd, 9, 3)+"' "
             TCQuery cQry1 ALIAS "TCQ" NEW
             DbSelectArea("TCQ")
             DbGoTop()
             If Empty(TCQ->C2_DATRF)
                cNumLot := TCQ->C2_LOTE
                cCodPro := TCQ->C2_PRODUTO
                DbSelectArea("TCQ")
                DbCloseArea()
                If !Empty(cCodPro)
                   //b) Verificar se o produto È ou n„o de estoque
                   cMsgApt := ""
                   cQry1   := ""
                   cQry1   += "SELECT B1_ESTOQUE "
                   cQry1   += "FROM "+RetSqlName("SB1")+" SB1 "
                   cQry1   += "WHERE SB1.B1_FILIAL  = '01' "
                   cQry1   += "  AND SB1.D_E_L_E_T_ = '' "
                   cQry1   += "  AND SB1.B1_COD     = '"+cCodPro+"' "
                   TCQuery cQry1 ALIAS "TCQ" NEW
                   DbSelectArea("TCQ")
                   DbGoTop()
                   cProEst := Alltrim(TCQ->B1_ESTOQUE)
                   DbSelectArea("TCQ")
                   DbCloseArea()
                   //c) Verificar se existem Ordens de produÁ„o em aberto para esse item
                   aCadOps := {}
                   cQry1 := ""
                   cQry1 += "SELECT SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN AS OP, SC2.C2_EMISSAO AS EMISSAO, SC2.C2_QUANT AS QUANT "
                   cQry1 += "FROM "+RetSqlName("SC2")+" SC2 "
                   cQry1 += "WHERE SC2.C2_FILIAL  = '01' "
                   cQry1 += "  AND SC2.D_E_L_E_T_ = '' "
                   cQry1 += "  AND SC2.C2_NUM    <> '"+SubStr(cNumOrd, 1, 6)+"' "
                   cQry1 += "  AND SC2.C2_ITEM    = '"+SubStr(cNumOrd, 7, 2)+"' "
                   cQry1 += "  AND SC2.C2_SEQUEN  = '"+SubStr(cNumOrd, 9, 3)+"' "
                   cQry1 += "  AND SC2.C2_PRODUTO = '"+cCodPro+"' "
                   cQry1 += "  AND SC2.C2_DATRF   = '' "
                   TCQuery cQry1 ALIAS "TCQ" NEW
                   DbSelectArea("TCQ")
                   DbGoTop()
                   While !Eof()
                         aAdd(aCadOps, {TCQ->OP, SubStr(TCQ->EMISSAO, 7, 2)+'/'+SubStr(TCQ->EMISSAO, 5, 2)+'/'+SubStr(TCQ->EMISSAO, 1, 4), TCQ->QUANT, '' })
                         DbSelectArea("TCQ")
                         DbSkip()
                   Enddo
                   DbSelectArea("TCQ")
                   DbCloseArea()
                   If Len(aCadOps) > 0
                      //d) Verifica se as Ordens de ProduÁ„o encontradas j· foram ou n„o iniciadas.
                      cMsgApt += '          APONTAMENTO DE ORDENS DE PRODU«√O          '+Chr(13)+Chr(10)
                      cMsgApt += '+---------------+------------+----------+-----------+'+Chr(13)+Chr(10)
                      cMsgApt += '|  ORDEM PROD.  |   EMISSAO  | INICIADA |   QTDE.   |'+Chr(13)+Chr(10)
                      cMsgApt += '+---------------+------------+----------+-----------+'+Chr(13)+Chr(10)
                      For nY := 1 To Len(aCadOps)
                          cQry1 := ""
                          cQry1 += "SELECT PRO.ORDEM "
                          cQry1 += "FROM PRODUCAO PRO "
                          cQry1 += "WHERE PRO.ORDEM IN('"+aCadOps[nY][1]+"') "
                          TCQuery cQry1 ALIAS "TCQ" NEW
                          DbSelectArea("TCQ")
                          DbGoTop()
                          aCadOps[nY][4] := Iif(Empty(TCQ->ORDEM), 'N√O', 'SIM')
                          DbSelectArea("TCQ")
                          DbCloseArea()
                          cMsgApt += '| '+SubStr(aCadOps[nY][1], 1, 6)+'-'+SubStr(aCadOps[nY][1], 7, 2)+'-'+SubStr(aCadOps[nY][1], 9, 3)+' | '+aCadOps[nY][2]+' |    '+aCadOps[nY][4]+'   | '+Transform(aCadOps[nY][3], "@E 99,999.99")+' |'+Chr(13)+Chr(10)
                          cMsgApt += '+---------------+------------+----------+-----------+'+Chr(13)+Chr(10)
                      Next
                   Endif
                   If !cProEst $ 'S' .and. Len(Alltrim(cCodPro)) >= 12
                      //e) Se o produto n„o for de estoque verificar se exitem outros pedidos em aberto para o item
                      aCadPed := {}
                      cQry1 := ""
                      cQry1 += "SELECT SC6.C6_NUM AS PEDIDO, SC6.C6_PRODUTO AS PRODUTO, (SC6.C6_QTDVEN - SC6.C6_QTDENT) AS QUANT, SC5.C5_APROVA AS APROVA "
                      cQry1 += "FROM "+RetSqlName("SC6")+" SC6  "
                      cQry1 += "LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 ON SC6.C6_FILIAL = SC5.C5_FILIAL AND SC6.C6_NUM = SC5.C5_NUM AND SC5.D_E_L_E_T_ = '' "
                      cQry1 += "WHERE SC6.C6_FILIAL  = '01' "
                      cQry1 += "  AND SC6.D_E_L_E_T_ = '' "
                      cQry1 += "  AND (SC6.C6_QTDVEN - SC6.C6_QTDENT) <= 0 "
                      cQry1 += "  AND SC6.C6_PRODUTO = '"+cCodPro+"' "
                      cQry1 += "  AND SC5.C5_APROVA <> '2' "
                      TCQuery cQry1 ALIAS "TCQ" NEW
                      DbSelectArea("TCQ")
                      DbGoTop()
                      While !Eof()
                            nPos := aScan(aCadPed, {|x| x[1]+x[2] == SubStr(TCQ->PRODUTO, 11, 2)})
                            If nPos == 0
                               aAdd(aCadPed, {TCQ->PEDIDO, SubStr(TCQ->PRODUTO, 11, 2), Iif(TCQ->APROVA == '1', 'SIM', 'N√O'),  TCQ->QUANT})
                            Else
                               aCadPed[nPos][4] += TCQ->QUANT
                            Endif
                            DbSelectArea("TCQ")
                            DbSkip()
                      Enddo
                      DbSelectArea("TCQ")
                      DbCloseArea()
                      If Len(aCadPed) > 0
                         cMsgApt += ''+Chr(13)+Chr(10)
                         cMsgApt += ''+Chr(13)+Chr(10)
                         cMsgApt += '   PEDIDOS EM ABERTO SEM ORDENS DE PRODU«√O    '+Chr(13)+Chr(10)
                         cMsgApt += '+--------+------------+-------------+---------+'+Chr(13)+Chr(10)
                         cMsgApt += '| PEDIDO |  APROVADO  |  EMBALAGEM  |  QTDE.  |'+Chr(13)+Chr(10)
                         cMsgApt += '+--------+------------+-------------+---------+'+Chr(13)+Chr(10)
                         For nY := 1 To Len(aCadPed)
                             If aCadPed[nY][2] $ 'SIM'
                                lNaoApt := .t.
                             Endif
                             cMsgApt += '| '+aCadPed[nY][1]+' |  '+aCadPed[nY][2]+'  |  '+aCadPed[nY][3]+'  |  '+Transform(aCadPed[nY][4], "@E 999999")+'  |'+Chr(13)+Chr(10)
                             cMsgApt += '+--------+------------+-------------+---------+'+Chr(13)+Chr(10)
                         Next
                      Endif
                   Endif
                   If !Empty(cMsgApt)
                      DEFINE MSDIALOG oDlgLog FROM 0, 0 TO 400, 590 PIXEL TITLE OemToAnsi("Aviso") OF oMainWnd
                      DEFINE FONT oFontX NAME 'COURIER NEW' SIZE 10, 0
                             @ 001, 003 GET oMsgApt VAR cMsgApt MEMO READONLY SIZE 290,200 PIXEL OF oDlgLog FONT oFontX
                      ACTIVATE MSDIALOG oDlgLog CENTERED
                   Endif
                   If !lNaoApt
                      //5∫) Se a variavel AptOrd for vazia significa que a O.P. ainda n„o foi apontada, usar INSERT, 
                      //    sen„o usar UPDATE e alterar somente a data e hora da O.P.
                      If Empty(cAptOrd)
                         cQry1 := "SELECT * "
                         cQry1 += "FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "
                         cQry1 += "WHERE SC2.C2_FILIAL  = '01' "
                         cQry1 += "  AND SC2.D_E_L_E_T_ = '' "
                         cQry1 += "  AND SC2.C2_NUM = '"+SubStr(cNumOrd, 1, 6)+"' "
                         cQry1 += "  AND SC2.C2_ITEM = '02' "
                         cQry1 += "  AND SC2.C2_SEQUEN = '"+SubStr(cNumOrd, 9, 3)+"' "
                         TCQuery cQry1 ALIAS "TCQ" NEW
                         DbSelectArea("TCQ")
                         DbGoTop()
                         lTemInk := Iif(Empty(TCQ->C2_NUM), .f., .t.)
                         DbSelectArea("TCQ")
                         DbCloseArea()
                         If lTemInk
                            cQry1 := ""
                            cQry1 += "INSERT INTO PRODUCAO (ORDEM, LOTE, INICIO, FIM, FLAG, QTDE) VALUES('"+SubStr(cNumOrd, 1, 6)+"02"+"001"+"', '      ', '"+DTOS(Date())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+"', '', '', 0.0)"
                            TCSQLEXEC(cQry1)
                         Endif
                         cQry1 := ""
                         cQry1 += "INSERT INTO PRODUCAO (ORDEM, LOTE, INICIO, FIM, FLAG, QTDE) VALUES('"+SubStr(cNumOrd, 1, 11)+"', '"+cNumLot+"', '"+DTOS(Date())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+"', '', '', 0.0)"
                         TCSQLEXEC(cQry1)
                      Else
                         cQry1 := "SELECT * "
                         cQry1 += "FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "
                         cQry1 += "WHERE SC2.C2_FILIAL  = '01' "
                         cQry1 += "  AND SC2.D_E_L_E_T_ = '' "
                         cQry1 += "  AND SC2.C2_NUM = '"+SubStr(cNumOrd, 1, 6)+"' "
                         cQry1 += "  AND SC2.C2_ITEM = '02' "
                         cQry1 += "  AND SC2.C2_SEQUEN = '"+SubStr(cNumOrd, 9, 3)+"' "
                         TCQuery cQry1 ALIAS "TCQ" NEW
                         DbSelectArea("TCQ")
                         DbGoTop()
                         lTemInk := Iif(Empty(TCQ->C2_NUM), .f., .t.)
                         DbSelectArea("TCQ")
                         DbCloseArea()
                         If lTemInk
                            cQry1 := ""
                            cQry1 += "UPDATE PRODUCAO SET INICIO = '"+DTOS(Date())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+"' WHERE ORDEM = '"+SubStr(cNumOrd, 1, 6)+"02001' "
                            TCSQLEXEC(cQry1)
                         Endif
                         cQry1 := ""
                         cQry1 += "UPDATE PRODUCAO SET INICIO = '"+DTOS(Date())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+"' WHERE ORDEM = '"+SubStr(cNumOrd, 1, 11)+"' "
                         TCSQLEXEC(cQry1)
                      Endif
                   Else
                      MsgStop("Existem mais pedidos para serem produzidos!", "AtenÁ„o")
                      TCQuit() //Desmonta conex„o com o banco de dados
                      cNumOrd := space(11)
                      oNumOrd:Refresh()
                      oNumOrd:SetFocus()
                      oTimer:Activate()
                      Return
                   Endif
                Else
                   MsgStop("Ordem de ProduÁ„o n„o encontrada!", "AtenÁ„o")
                   TCQuit() //Desmonta conex„o com o banco de dados
                   cNumOrd := space(11)
                   oNumOrd:Refresh()
                   oNumOrd:SetFocus()
                   oTimer:Activate()
                   Return
                Endif
             Else
                MsgStop("Ordem de ProduÁ„o j· foi finalizada!", "AtenÁ„o")
                DbSelectArea("TCQ")
                DbCloseArea()
                TCQuit() //Desmonta conex„o com o banco de dados
                cNumOrd := space(11)
                oNumOrd:Refresh()
                oNumOrd:SetFocus()
                oTimer:Activate()
                Return
             Endif
          Endif
       Endif
       /*********************************************/
       /*** DESMONTA CONEX√O COM O BANCO DE DADOS ***/
       /*********************************************/
       TCQuit() //Desmonta conex„o com o banco de dados
       cNumOrd := space(11)
       oNumOrd:Refresh()
       oNumOrd:SetFocus()
       oTimer:Activate()
Return
          
/******************************************************************************************************************/
/*** FESTINFTEL - ESTORNA APONTAMENTO DA ORDEM DE PRODU«√O, SOMENTE PARA INICIADAS E N√O FINALIZADAS.           ***/
/******************************************************************************************************************/
Static Function fEstInfTel(oMonitor, cNumOrd, oNumOrd, cConType, cProtect, cDataBase, cAlias, cServer, nPort)
       oTimer:Deactivate()
       cNumEst := space(11)
       DEFINE MSDIALOG oDlgEst FROM 0, 0 TO 050, 590 PIXEL TITLE OemToAnsi("Estorno de Ordens de ProduÁ„o") OF oMainWnd
              @ 010, 001 SAY   OemToAnsi("Nr∫. da O.P.:")  SIZE 100,009                                  PIXEL OF oDlgEst FONT oFont1
              @ 011, 105 MSGET oNumEst VAR cNumEst         SIZE 120,010                                  PIXEL OF oDlgEst FONT oFont1
              @ 021, 470 BTNBMP oBtnEOp RESOURCE "OK"      SIZE 120,024 ACTION(fValEstOps(cNumEst, cConType, cProtect, cDataBase, cAlias, cServer, nPort)) PIXEL OF oDlgEst
              oBtnEOp:oFont      := oFont1
              oBtnEOp:cCaption   := PADR(OemToAnsi("OK"), 02)
              oBtnEOp:cToolTip   := 'Confirma estorno da O.P.'
              oNumEst:bLostFocus := {|| fValEstOps(cNumEst, cConType, cProtect, cDataBase, cAlias, cServer, nPort)}
       ACTIVATE MSDIALOG oDlgEst CENTERED
       cNumOrd := space(11)
       oNumOrd:Refresh()
       oNumOrd:SetFocus()
       oTimer:Activate()
Return

/******************************************************************************************************************/
/*** FVALESTOPS - VALIDA O ESTORNO DAS ORDENS DE PRODU«√O                                                       ***/
/******************************************************************************************************************/
Static Function fValEstOps(cNumEst, cConType, cProtect, cDataBase, cAlias, cServer, nPort)
       Local cQry1 := ""
       cQry1 += "SELECT * "
       cQry1 += "FROM PRODUCAO PRO "
       cQry1 += "WHERE PRO.ORDEM = '"+SubStr(cNumEst, 1, 11)+"' "

       /*********************************************/
       /***  MONTA CONEX√O COM O BANCO DE DADOS   ***/
       /*********************************************/
       TCCONTYPE(cConType)
       __nConecta := TCLink(cProtect+"@!!@"+cDataBase+"/"+cAlias, cServer, nPort)  // Nao Comer Licenca do Top
       If __nConecta < 0
          MsgStop("N„o foi possÌvel conectar ao Banco de Dados.", "ERROR")
          Return
       Endif
       TCSETCONN(__nConecta)

       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()
       cFimOrd := TCQ->FIM
       cFlaOrd := TCQ->FLAG
       DbSelectArea("TCQ")
       DbCloseArea()
       If Empty(cFimOrd) .and. Empty(cFlaOrd)
          cQry1 := ""
          cQry1 += "DELETE PRODUCAO WHERE ORDEM = '"+cNumEst+"' "
          TCSQLExec(cQry1)
       Else
          MsgStop("Essa Ordem de produÁ„o j· foi finalizada!", "AtenÁ„o")
       Endif
       TCQuit() //Desmonta conex„o com o banco de dados
       oDlgEst:End()
Return
