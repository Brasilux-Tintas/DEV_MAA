#include "protheus.ch"
#include "topconn.ch"
#include "brfatx01.ch"
#include "colors.ch"
#include "font.ch"    
#include 'DIRECTRY.CH'

#Translate MSGBOX( => IW_MsgBox(
#define DS_MODALFRAME            128  // 0x80
#define WS_POPUP          2147483648  // 0x80000000L
#define WS_CAPTION          12582912  // 0x00C00000L
#define WS_VISIBLE         268435456  // 0x10000000L
#xtranslate bSETGET(<uVar>) => { | u | If( PCount() == 0, <uVar>, <uVar> := u ) }
#IFNDEF WINDOWS
        #DEFINE PSAY SAY
#ENDIF
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFATX01 ºAutor  ³ Luís Gustavo       º Data ³  01/06/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para liberação de pedidos de vendas com diversos    º±±
±±º          ³ Status e especifico da Brasilux.                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Luís Gustavo  ³ BRFATX01 - Chamada Principal.              ³±±
±±³          ³ Luís Gustavo  ³ FATX01_1 - Liberação/Estorno de pedidos.   ³±±
±±³          ³ Luís Gustavo  ³ FATX01_2 - Confirmação da analise dos ped. ³±±
±±³          ³ Luís Gustavo  ³ FATX01_3 - Mostra titulos em aberto do cl. ³±±
±±³          ³ Luís Gustavo  ³ FATX01_4 - Mostra titulos recebidos do cl. ³±±
±±³          ³ Luís Gustavo  ³ FATX01_5 - Mostra os itens do pedido.      ³±±
±±³          ³ Luís Gustavo  ³ FATX01_6 - Mostra dados cadastrais do cl.  ³±±
±±³          ³ Luís Gustavo  ³ FATX01_7 - Observações dos pedidos.        ³±±
±±³          ³ Luís Gustavo  ³ FATX01_A - Mostra parcelas da cond. pgto.  ³±±
±±³          ³ Luís Gustavo  ³ FATX01_B - Legenda.                        ³±±
±±³          ³ Luís Gustavo  ³ FATX01_C - Mostra pedidos a Liberar.       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function BRFATX01()
     Local aCores := { {"(C5_APROVA == '0' .and. C5_LIBCAD == 'F' .and. C5_LIBPED == 'F' .and. C5_LIBCRE == 'F' .and. C5_LIBDIR == 'F')", 'DISABLE'   },; // Analise de Cadastro
                       {"(C5_APROVA == '0' .and. C5_LIBCAD == 'T' .and. C5_LIBPED == 'F' .and. C5_LIBCRE == 'F' .and. C5_LIBDIR == 'F')", 'BR_CINZA'  },; // Analise de Vendas
                       {"(C5_APROVA == '0' .and. C5_LIBCAD == 'T' .and. C5_LIBPED == 'T' .and. C5_LIBCRE == 'F' .and. C5_LIBDIR == 'F')", 'BR_PINK'   },; // Analise de Crédito
                       {"(C5_APROVA == '0' .and. C5_LIBCAD == 'T' .and. C5_LIBPED == 'T' .and. C5_LIBCRE == 'T' .and. C5_LIBDIR == 'F')", 'BR_AZUL'   },; // Analise da Diretoria
                       {"(C5_APROVA == '1' .and.  EMPTY(C5_NOTA))"                                              , 'BR_MARROM' },; // Aprovado e não faturado
                       {"(C5_APROVA == '1' .and. !EMPTY(C5_NOTA))"                                              , 'ENABLE'    },; // Aprovado e faturado
                       {"(C5_APROVA == '2')"                                                                    , 'BR_PRETO'  } } // Recusado
     If !((SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2)) $ GETMV("MV_LIBPEDE"))
        MsgBox("Empresa/Filial não autorizada a utilizar essa rotina !", "Atenção...", "ALERT")
        Return
     Endif

     Private cCadastro := "Análise de pedidos"
     Private cCodUsr   := RetCodUsr()
     Private lAdmin    := .f.
     Private cAcesso   := ""
     Private aHeader   := {}
     Private cRotina   := "BRFATX01  "
     Private aRegis    := {}
     Private lAcsCad   := .f.
     Private lAcsPed   := .f.
     Private lAcsCre   := .f.
     Private lAcsDir   := .f.
     Private lAcsOut   := .f.
     Private mvpar01   := 0
     Private cOpcUsr   := ""
     Private oTempTable
     Private oTempTbl01
	     u_zcfga01( 'BRFATX01' ) //LGS#2021214 - Gravação de log de utilização da rotina
	lAdmin := (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),cCodUsr) = 0)
			
	if lAdmin
		cAcesso := '*****   * '		
	else 
     	DbSelectArea("SZW")
     	DbSetOrder(4)
     	DbSeek(xFilial("SZW")+cRotina+cCodUsr+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2),.t.)
     	If Found()
        	cAcesso := SZW->ZW_ACESSOS
     	Else
      	MsgBox("Usuário não autorizado !!! Entre em contato com o administrador do sistema", "Atenção", "STOP")
        	Return
      	Endif 
 	EndIf
  	lAcsAtv := Iif(SubStr(cAcesso, 9, 1) == '*', .t., .f.) // Usuário Inativo
   If !lAcsAtv
      MsgBox("Usuário inativo..."+chr(13)+chr(10)+"Entre em contato com o administrador do sistema !", "Atenção...", "STOP")
      Return
   Endif

	lAcsCad := Iif(SubStr(cAcesso, 1, 1) == '*', .t., .f.) // Itens a serem liberados por vendas.
	lAcsPed := Iif(SubStr(cAcesso, 2, 1) == '*', .t., .f.) // Itens a serem liberados por vendas.
	lAcsCre := Iif(SubStr(cAcesso, 3, 1) == '*', .t., .f.) // Itens a serem liberados pelo crédito
	lAcsDir := Iif(SubStr(cAcesso, 4, 1) == '*', .t., .f.) // Itens a serem liberados pela diretoria
	lAcsOut := Iif(SubStr(cAcesso, 6, 1) == '*', .t., .f.) // Outros pedidos a serem Liberados.
     u_zcfga01( 'BRFATX01' ) //LGS#2021203 - Gravação de log de utilização da rotina
	Private aRotina   := { { OemToAnsi("Pesquisar")        , 'AxPesqui'               , 0, 1   },; //Pesquisar
                          { OemToAnsi("Visualizar")       , 'A410Visual'             , 0, 2   },; //Visualizar
                          { OemToAnsi("Liberação")        , 'U_FATX01_1(1)'          , 0, 2   } } //Liberação nOpc = 1
     
   If lAcsDir
      aadd(aRotina, { OemToAnsi("Diretoria")     , 'U_FATX01_1(3)'      , 0, 3, 0} ) //Diretoria nOpc = 3
   Endif
   If lAcsPed
      aadd(aRotina, { OemToAnsi("Vendas")        , 'U_FATX01_1(5)'      , 0, 3, 0} ) //Vendas nOpc = 5
   Endif
   aadd(aRotina, { OemToAnsi("Estorno")       , 'U_FATX01_1(2)'      , 0, 2   } ) //Estorno nOpc = 2 
   aadd(aRotina, { OemToAnsi("Ped. à Liberar"), 'U_FATX01_C()'       , 0, 2   } ) //Consulta
   aadd(aRotina, { OemToAnsi("Ped. Pendentes"), 'U_FATX01_1(4)'      , 0, 2   } ) //Pendentes nOpc = 4
   aadd(aRotina, { OemToAnsi("Legenda")       , 'U_FATX01_B()'       , 0, 3, 0} ) //Legenda
 
   //aadd(aRotina, {"POSCLI",{||a450F4Con()},"Posição do Cliente","Cliente"})

   If lAdmin
      //aadd(aRotina, { OemToAnsi("Acessos")       , 'U_BRSEN001(cRotina)', 0, 3   } ) //Acessos
   Endif
   Private cString   := "SC5"
     
   If lAcsCre .and. !lAcsDir
      // - DESABILITADO POIS NÃO ESTA EM USO 13/02/2020 - LUIS GUSTAVO
      /*If GETMV("MV_UFILCRE")
           Pergunte("FATX01", .F.)
           mvpar01 := mv_par01
           cOpcUsr := Iif(mvpar01 == 1, 'TODOSP', Iif(mvpar01 == 2, 'CATRAS', 'SATRAS'))
           DbSelectArea("SX5")
           DbSetOrder(1)
           DbSeek(xFilial("SX5")+'LB'+cOpcUsr, .t.)
           If Found()
              If cOpcUsr $ 'TODOSP'
                 If Alltrim(SX5->X5_DESCRI) $ '.'
                    DbSeek(xFilial("SX5")+'LBCATRAS', .t.)
                    If Alltrim(SX5->X5_DESCRI) $ '.'
                       DbSeek(xFilial("SX5")+'LBSATRAS', .t.)
                       If Alltrim(SX5->X5_DESCRI) $ '.'
                          DbSeek(xFilial("SX5")+'LB'+cOpcUsr, .t.)
                          RecLock("SX5", .f.)
                             SX5->X5_DESCRI := Upper(Alltrim(cUsername))
                          MsUnLock()
                          mvpar01 := mv_par01
                       Else
                          cOpcUsr := 'CATRAS'
                          DbSeek(xFilial("SX5")+'LB'+cOpcUsr, .t.)
                          RecLock("SX5", .f.)
                             SX5->X5_DESCRI := Upper(Alltrim(cUsername))
                          MsUnLock()
                          mv_par01 := 2
                          mvpar01  := 2
                       Endif
                    Else
                       cOpcUsr := 'SATRAS'
                       DbSeek(xFilial("SX5")+'LB'+cOpcUsr, .t.)
                       RecLock("SX5", .f.)
                          SX5->X5_DESCRI := Upper(Alltrim(cUsername))
                       MsUnLock()
                       mvpar01 = 3
                    Endif
                 Else
                    MsgBox('Já existe outro usuário analisando todos os pedidos!', 'Atenção', 'STOP')
                    Return
                 Endif
              ElseIf cOpcUsr $ 'CATRAS'
                     If Alltrim(SX5->X5_DESCRI) $ '.'
                        DbSeek(xFilial("SX5")+'LBTODOSP', .t.)
                        If Alltrim(SX5->X5_DESCRI) $ '.'
                           DbSeek(xFilial("SX5")+'LB'+cOpcUsr, .t.)
                           RecLock("SX5", .f.)
                              SX5->X5_DESCRI := Upper(Alltrim(cUsername))
                           MsUnLock()
                           mvpar01 = mv_par01
                        Else
                           MsgBox('Já existe outro usuário analisando todos os pedidos!', 'Atenção', 'STOP')
                           Return
                        Endif
                     Else
                        cOpcUsr := 'SATRAS'
                        DbSeek(xFilial("SX5")+'LB'+cOpcUsr, .t.)
                        If Alltrim(SX5->X5_DESCRI) $ '.'
                           RecLock("SX5", .f.)
                              SX5->X5_DESCRI := Upper(Alltrim(cUsername))
                           MsUnLock()
                           mvpar01 = 3
                        Else
                           MsgBox('Já existe outro usuário analisando os pedidos sem atraso!', 'Atenção', 'STOP')
                           Return
                        Endif
                     Endif
              ElseIf cOpcUsr $ 'SATRAS'
                     If Alltrim(SX5->X5_DESCRI) $ '.'
                        DbSeek(xFilial("SX5")+'LBTODOSP', .t.)
                        If Alltrim(SX5->X5_DESCRI) $ '.'
                           DbSeek(xFilial("SX5")+'LB'+cOpcUsr, .t.)
                           RecLock("SX5", .f.)
                              SX5->X5_DESCRI := Upper(Alltrim(cUsername))
                           MsUnLock()
                           mvpar01 = 3
                        Else
                           MsgBox('Já existe outro usuário analisando todos os pedidos!', 'Atenção', 'STOP')
                           Return
                        Endif
                     Else
                        cOpcUsr := 'CATRAS'
                        DbSeek(xFilial("SX5")+'LB'+cOpcUsr, .t.)
                        If Alltrim(SX5->X5_DESCRI) $ '.'
                           RecLock("SX5", .f.)
                              SX5->X5_DESCRI := Upper(Alltrim(cUsername))
                           MsUnLock()
                           mvpar01 = 2
                        Else
                           MsgBox('Já existe outro usuário analisando os pedidos com atraso!', 'Atenção', 'STOP')
                           Return
                        Endif
                     Endif
              Endif
           Endif
      Endif*/
      //LGS#20200210 - Adequação de release 12.1.25 e posteriores
      //Set Key VK_F12 To FATX01_G()
      //SetKey( VK_F12, { || FATX01_G() } ) - DESABILITADO POIS NÃO ESTA EM USO 13/02/2020
   Endif

   DbSelectArea(cString)
   DbSetOrder(1)
   mBrowse( 6, 1, 22, 75,cString,,,,,,aCores)
     
   If lAcsCre .and. !lAcsDir
      If GETMV("MV_UFILCRE")
         //LGS#20200210 - Adequação de release 12.1.25 e posteriores
         //Set Key VK_F12 To
         //SetKey( VK_F12, { ||  } ) -// - DESABILITADO POIS NÃO ESTA EM USO 13/02/2020 - LUIS GUSTAVO
         // - DESABILITADO POIS NÃO ESTA EM USO 13/02/2020 - LUIS GUSTAVO
         /*DbSelectArea("SX5")
         DbSetOrder(1)
         DbSeek(xFilial("SX5")+'LB'+cOpcUsr, .t.)
         If Found()
            RecLock("SX5", .f.)
               SX5->X5_DESCRI := '.'
            MsUnLock()
         Endif*/
      Endif
   Endif    

	if Select("TMP")<>0
		dbselectarea("TMP")
		dbclosearea()
		If Type("oTempTbl01") == "O"
		   oTempTbl01:Delete()
		Endif
	endif

	if Select("LPD")<>0
		dbselectarea("LPD")
		dbclosearea()
		If Type("oTempTable") == 'O'
		   oTempTable:Delete()
		Endif
	endif

	//aEval(Directory("tmp*.dbf"), { |aFile| FERASE(aFile[F_NAME]) })     
	//aEval(Directory("tmp*.cdx"), { |aFile| FERASE(aFile[F_NAME]) })     
Return

/*****************************************************************************/
/*** FATX01_1 - Liberação / Estorno do pedido.                             ***/
/******************************************************************************
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Luís Gustavo  ³ fMonArq - Monta arq. temp. para lib. pedidos.³±±
±±³          ³ Luís Gustavo  ³ fValCom - Valida comissão digitada.          ³±±
±±³          ³ Luís Gustavo  ³ fAltPed - Atual. dados da tela troca de ped. ³±±
±±³          ³ Luís Gustavo  ³ fMRCPed - Valida marc. da aprov. do pedido.  ³±±
±±³          ³ Luís Gustavo  ³ fMRCCre - Valida marc. da aprov. do credito. ³±±
±±³          ³ Luís Gustavo  ³ fMRCDir - Valida marc. da aprov. do diretor. ³±±
±±³          ³ Luís Gustavo  ³ fMRCRec - Valida marcação da recusa.         ³±±
±±³          ³ Luís Gustavo  ³ fAprPed - Monta enchoice bar diferenciada.   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function FATX01_1(nOpc)
     //Local cQry2        := ""
     //Local cCond        := ""
     Private oLPD
     Private oLibPed    := LoadBitmap( GetResources(), "BR_VERMELHO")
     Private oLibCrd    := LoadBitmap( GetResources(), "BR_AMARELO")
     Private oLibDra    := LoadBitmap( GetResources(), "BR_AZUL")
     Private aHeaderLPD := {}
     Private aPedi      := {}
     Private nTpVen     := 0
     Private oTipVen, oVlrMer, oVlrIpi, oVlrSTb, oVlrTot, oVlrLcr, oPerLcr, oVlrCom, oPerCom, oPriCom, oUltCom, oRisco, oLibCre, oLibDir, oRestri, oIncPed, oAltPed, oUsrPed, oUsrCre, oUsrDir, oLibRec, oUsrRec, oLibCad, oUsrCad, oObsSC5, oObsMsg
     Private nVlrMer    := 0
     Private nVlrIPI    := 0
     Private nVlrSTb    := 0
     Private nVlrTot    := 0
     Private nVlrLcr    := 0
     Private nPerLcr    := 0
     Private nVlrCom    := 0
     Private nPerCom    := 0
     Private cPriCom    := ""
     Private cUltCom    := ""
     Private cRisco     := ""
     Private lLibPed    := .f.
     Private cUsrPed    := ""
     Private lLibCre    := .f.
     Private cUsrCre    := ""
     Private lLibDir    := .f.
     Private cUsrDir    := ""
     Private lLibRec    := .f.
     Private cUsrRec    := "" 
     Private lLibCad    := .f.
     Private cUsrCad    := ""
     Private aItmPed    := {}
     Private cRestri    := ""
     Private cObsMsg    := ""
     Private cObsSC5    := ""
     Private cObserv    := ""
     Private cIncPed    := ""
     Private cAltPed    := ""
     Private aCliente   := {}
     Private lAtual     := .f.
     Private aCamBrw    := {}
     
     If nOpc == 3
        If !lAcsDir
           MsgBox("Acesso negado para essa rotina !", "Atenção...", "STOP")
           Return
        Endif
     Endif
     If nOpc == 5
        If !lAcsPed
           MsgBox("Acesso negado para essa rotina !", "Atenção...", "STOP")
           Return
        Endif
     Endif
     
     If Select("LPD") <> 0
        DbSelectArea("LPD")
        DbCloseArea()
		  If Type("oTempTable") == 'O'
		     oTempTable:Delete()
        Endif
     Endif
     MsgRun("Montando arquivo de trabalho.", "Aguarde...", {||U_fMonArq(nOpc)} )
     DbSelectArea("LPD")
     DbGoTop()
     aadd(aCamBrw, {"PEDIDO"  , "", OemToAnsi("Pedido")      , "999999"} )
     aadd(aCamBrw, {"EMISSAO" , "", OemToAnsi("Emissão")     , ""      } )
     aadd(aCamBrw, {"DATAALT" , "", OemToAnsi("Dt. Alter.")  , ""      } )
     aadd(aCamBrw, {"CLIENTE" , "", OemToAnsi("Cliente/Loja"), "@!"    } )
     aadd(aCamBrw, {"CONDICAO", "", OemToAnsi("Cond. Pgto.") , "@!"    } )
     aadd(aCamBrw, {"BOLETO"  , "", OemToAnsi("Boleto")      , "@!"    } )
     aadd(aCamBrw, {"VENDEDOR", "", OemToAnsi("Vendedor")    , "@!"    } )
     aadd(aCamBrw, {"TRANSPORT","", OemToAnsi("Transp")      , "@!"    } )
     aadd(aCamBrw, {"ULTCOM",   "", OemToAnsi("Ult Compra")  , ""    } )
     
     DEFINE MSDIALOG oDlg FROM 000,000 TO 032,100 TITLE OemToAnsi("Aprovação de Pedidos" ) OF oMainWnd
            DEFINE FONT oFont  SIZE 8,0 BOLD
            DEFINE FONT oFont2 SIZE 5,0 BOLD
            DEFINE FONT oFont3 NAME 'COURIER NEW' SIZE 6,0
            DEFINE FONT oFont4 SIZE 4,0 BOLD
            @ 012,001 GROUP oGrp1 TO 85,395 LABEL  OemToAnsi('Aprovação de Pedidos') PIXEL OF oDlg
            oLPD := MSSelect():New("LPD", "FLAG", Nil, aCamBrw, .f., Nil, {017,003,080,393}, , , oDlg)
            /***************************************************************************/
            @ 085,355 GROUP oGrp2 TO 121,395 LABEL  OemToAnsi('Tipo Venda')           PIXEL OF oDlg
            @ 095,360 RADIO oTipVen VAR nTpVen ITEMS "Interna","Externa" SIZE 030,010 PIXEL OF oDlg 
            /***************************************************************************/
            @ 085,001 GROUP oGrp3 TO 102,352 LABEL  OemToAnsi('Valores')                                      PIXEL OF oDlg
            @ 090,005 SAY OemToAnsi("Mercadoria")                                              SIZE 030,09    PIXEL OF oDlg
            @ 089,040 MSGET oVlrMer VAR nVlrMer    PICTURE '@E 999,999,999.99'        WHEN .f. SIZE 050,09    PIXEL OF oDlg
            @ 090,100 SAY OemToAnsi("I.P.I")                                                   SIZE 015,09    PIXEL OF oDlg
            @ 089,120 MSGET oVlrIPI VAR nVlrIPI    PICTURE '@E 999,999,999.99'        WHEN .f. SIZE 040,09    PIXEL OF oDlg
            @ 090,170 SAY OemToAnsi("Subs. Trib.")                                             SIZE 030,09    PIXEL OF oDlg
            @ 089,205 MSGET oVlrSTb VAR nVlrSTb    PICTURE '@E 999,999,999.99'        WHEN .f. SIZE 050,09    PIXEL OF oDlg
            @ 090,265 SAY OemToAnsi("TOTAL")       COLOR CLR_HRED                              SIZE 025,09    PIXEL OF oDlg FONT oFont2
            @ 089,296 MSGET oVlrTot VAR nVlrTot    PICTURE '@E 999,999,999.99'        WHEN .f. SIZE 050,09    PIXEL OF oDlg
            /***************************************************************************/
            @ 103,001 GROUP oGrp4 TO 121,081 LABEL  OemToAnsi('Lucro')                                        PIXEL OF oDlg
            @ 108,005 MSGET oVlrLcr VAR nVlrLcr    PICTURE '@E 999,999,999.99'        WHEN .f. SIZE 040,09    PIXEL OF oDlg
            @ 108,045 MSGET oPerLcr VAR nPerLcr    PICTURE '@E 999.99%'               WHEN .f. SIZE 030,09    PIXEL OF oDlg
            /***************************************************************************/
            @ 103,083 GROUP oGrp5 TO 121,163 LABEL  OemToAnsi('Comissão')                                     PIXEL OF oDlg
            @ 108,087 MSGET oVlrCom VAR nVlrCom    PICTURE '@E 999,999,999.99'        WHEN .f. SIZE 040,09    PIXEL OF oDlg
            @ 108,127 MSGET oPerCom VAR nPerCom    PICTURE '@E 999.99%'                        SIZE 030,09    PIXEL OF oDlg
            /***************************************************************************/
            @ 103,165 GROUP oGrp6 TO 121,300 LABEL  OemToAnsi('Informações')                                  PIXEL OF oDlg
            @ 109,169 SAY OemToAnsi('1º Compra:')                                              SIZE 030,09    PIXEL OF oDlg
            @ 108,199 SAY oPriCom VAR cPriCom      PICTURE '@!' COLOR CLR_BLUE                 SIZE 040,09    PIXEL OF oDlg  FONT oFont4
            @ 109,220 SAY OemToAnsi('Ult. Compra:')                                            SIZE 030,09    PIXEL OF oDlg
            @ 108,250 SAY oUltCom VAR cUltCom      PICTURE '@!' COLOR CLR_BLUE                 SIZE 040,09    PIXEL OF oDlg  FONT oFont4
            @ 109,271 SAY OemToAnsi('Risco:')                                                  SIZE 015,09    PIXEL OF oDlg
            @ 108,289 SAY oRisco  VAR cRisco       PICTURE '@!' COLOR CLR_BLUE                 SIZE 050,09    PIXEL OF oDlg  FONT oFont4
            /***************************************************************************/
            @ 121,001 GROUP oGrp7 TO 139,395 LABEL  OemToAnsi('Aprovado por:')                                PIXEL OF oDlg
            @ 126,005 CHECKBOX oLibCad VAR lLibCad PROMPT OemToAnsi("Sintegra:")               SIZE 030,10    PIXEL OF oDlg
            @ 126,037 SAY oUsrCad VAR cUsrCad PICTURE '@!' COLOR CLR_BLUE                      SIZE 070,09    PIXEL OF oDlg  FONT oFont4
            @ 126,083 CHECKBOX oLibPed VAR lLibPed PROMPT OemToAnsi("Vendas:")                 SIZE 030,10    PIXEL OF oDlg
            @ 126,113 SAY oUsrPed VAR cUsrPed PICTURE '@!' COLOR CLR_BLUE                      SIZE 070,09    PIXEL OF oDlg  FONT oFont4
            @ 126,161 CHECKBOX oLibCre VAR lLibCre PROMPT OemToAnsi("Crédito:")                SIZE 030,10    PIXEL OF oDlg
            @ 126,191 SAY oUsrCre VAR cUsrCre PICTURE '@!' COLOR CLR_BLUE                      SIZE 070,09    PIXEL OF oDlg  FONT oFont4
            @ 126,239 CHECKBOX oLibDir VAR lLibDir PROMPT OemToAnsi("Diretoria:")              SIZE 030,10    PIXEL OF oDlg
            @ 126,270 SAY oUsrDir VAR cUsrDir PICTURE '@!' COLOR CLR_BLUE                      SIZE 070,09    PIXEL OF oDlg  FONT oFont4
            @ 126,317 CHECKBOX oLibRec VAR lLibRec PROMPT OemToAnsi("Recusar:")                SIZE 030,10    PIXEL OF oDlg
            @ 126,349 SAY oUsrRec VAR cUsrRec PICTURE '@!' COLOR CLR_BLUE                      SIZE 070,09    PIXEL OF oDlg  FONT oFont4

            /***************************************************************************/
            @ 103,302 GROUP oGrp9 TO 121,352 LABEL  OemToAnsi('Ultima Alteração:')                            PIXEL OF oDlg
            @ 108,307 SAY oAltPed VAR cAltPed PICTURE '@!' COLOR CLR_BLUE                      SIZE 050,09    PIXEL OF oDlg  FONT oFont4
            /***************************************************************************/            
            @ 141,001 GROUP oGrp8 TO 241,197 LABEL  OemToAnsi('Restrição:')                                   PIXEL OF oDlg
            @ 146,003 GET oRestri VAR cRestri MEMO READONLY SIZE 192,090 PIXEL OF oDlg FONT oFont3
            /***************************************************************************/            
            @ 141,199 GROUP oGrp9 TO 241,395 LABEL  OemToAnsi('Observações:')                                 PIXEL OF oDlg
            @ 146,201 GET oObsMsg VAR cObsMsg MEMO READONLY SIZE 192,045 PIXEL OF oDlg
            //@ 191,201 GET oObsSC5 VAR cObsSC5 MEMO READONLY SIZE 192,045 PIXEL OF oDlg
            @ 191,201 GET oObsSC5 VAR cObserv MEMO READONLY SIZE 192,045 PIXEL OF oDlg
            oDlg:nStyle    := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
            oTipVen:bWhen  := {||.f.}
            oPerCom:bWhen  := Iif( nOpc == 1 .or. nOpc == 3, Iif( lAcsDir, {||.t.}, {||.f.} ), {||.f.} )
            oPerCom:bLostFocus := {|| fValCom(@oVlrLcr, @nVlrLcr, @oPerLcr, @nPerLcr, @oVlrCom, @nVlrCom, @oPerCom, @nPerCom) }
            oDlg:lEscClose := .T.
            oLpd:oBrowse:lCanAllMark := .f.
            oLpd:bMark := { || .t. }
            oLPD:oBrowse:bChange := { || fAltPed(@oTipVen, @nTpVen, @oVlrMer, @nVlrMer, @oVlrIPI, @nVlrIPI, @oVlrSTb, @nVlrSTb, @oVlrTot, @nVlrTot, @aItmPed, @oVlrLcr, @nVlrLcr, @oPerLcr, @nPerLcr, @oVlrCom, @nVlrCom, @oPerCom, @nPerCom, @oPriCom, @cPriCom, @oUltCom, @cUltCom, @oRisco, @cRisco, @aCliente, @oLibPed, @lLibPed, @oUsrPed, @cUsrPed, @oAltPed, @cAltPed, @oRestri, @cRestri, @oObsMsg, @cObsMsg, @oLibRec, @lLibRec, @oObsSC5, @cObsSC5, @oLibCad, @lLibCad) }
            oLPD:oBrowse:Refresh()
            oLibPed:bLClicked := { || fMRCPed() } ; oLibCre:bLClicked := { || fMRCCre() }
            oLibDir:bLClicked := { || fMRCDir() } ; oLibRec:bLClicked := { || fMRCRec() }
            oLibCad:bLClicked := { || fMRCCad() }
            If nOpc == 4
               oLibCad:bWhen := {||.f.} ; oLibPed:bWhen := {||.f.}
               oLibCre:bWhen := {||.f.} ; oLibDir:bWhen := {||.f.}
               oLibRec:bWhen := {||.f.} ; oPerCom:bWhen := {||.f.}
            Endif
     ACTIVATE MSDIALOG oDlg CENTERED VALID .T. ON INIT ( fAprPed(1, oDlg, {|| DbSelectArea("LPD"), DbCloseArea(), oTempTable:Delete(), oDlg:End() }, {|| DbSelectArea("LPD"), DbCloseArea(), oTempTable:Delete(), oDlg:End() } ), oDlg:lEscClose := .t., fAltPed(@oTipVen, @nTpVen, @oVlrMer, @nVlrMer, @oVlrIPI, @nVlrIPI, @oVlrSTb, @nVlrSTb, @oVlrTot, @nVlrTot, @aItmPed, @oVlrLcr, @nVlrLcr, @oPerLcr, @nPerLcr, @oVlrCom, @nVlrCom, @oPerCom, @nPerCom, @oPriCom, @cPriCom, @oUltCom, @cUltCom, @oRisco, @cRisco, @aCliente, @oLibPed, @lLibPed, @oUsrPed, @cUsrPed, @oAltPed, @cAltPed, @oRestri, @cRestri, @oObsMsg, @cObsMsg, @oLibRec, @lLibRec, @oObsSC5, @cObsSC5, @oLibCad, @lLibCad) )

Return

/*****************************************************************************/
/*** FALTPED - Atualiza variáveis de tela com os dados do ped. em questão. ***/
/******************************************************************************
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Luis Gustavo  ³ fBusInf - Busca inform. financ. do cliente.  ³±±
±±³          ³ Luis Gustavo  ³ fBusObs - Busca inform. do pedido.           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fAltPed(oTipVen, nTpVen, oVlrMer, nVlrMer, oVlrIPI, nVlrIPI, oVlrSTb, nVlrSTb, oVlrTot, nVlrTot, aItmPed, oVlrLcr, nVlrLcr, oPerLcr, nPerLcr, oVlrCom, nVlrCom, oPerCom, nPerCom, oPriCom, cPriCom, oUltCom, cUltCom, oRisco, cRisco, aCliente, oLibPed, lLibPed, oUsrPed, cUsrPed, oAltPed, cAltPed, oRestri, cRestri, oObsMsg, cObsMsg, oLibRec, lLibRec, oObsSC5, cObsSC5, oLibCad, lLibCad)
       Local cQry3  := "", cUf := "", nAliqSol := 0
       Local _nMVTXPIS  := GETMV("MV_TXPIS")   //LGS#20200210 - Adequação de release 12.1.25 e posteriores
       Local _nMVTXCOFI := GETMV("MV_TXCOFIN")

       nTpVen  := Iif(LPD->TIPOVEN == 'I', 1, 2) // Tipo de Vendas Interna ou externa
       
       cQry3 := ""
       cQry3 += "SELECT C6_VALOR,C6_TES,C6_PRODUTO,C6_QTDVEN,C6_PRCVEN,R_E_C_N_O_, C6_ITEM, C6_NUM "
       cQry3 += "FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "
       cQry3 += "WHERE SC6.C6_FILIAL = '"+xFilial("SC6")+"' "
       cQry3 += "  AND SC6.D_E_L_E_T_ = '' "
       cQry3 += "  AND SC6.C6_NUM    = '"+LPD->PEDIDO+"' "
       
       TCQUERY cQry3 ALIAS "ITM" NEW
       DbSelectArea("ITM")
       DbGoTop()

       nVlrMer    := 0
       nVlrIPI    := 0
       nVlrTOT    := 0
       nAuxIPI    := 0
       nBaseIcms  := 0
       nAuxIcms   := 0
       nLucroST   := 0
       nBaseSubst := 0
       nDescZFR   := 0
       cUf 		  := Iif(LPD->TIPOPED $ "D_B", Posicione("SA2", 1, xFilial("SA2")+SubStr(LPD->CLIENTE,1,6)+SubStr(LPD->CLIENTE,8,2),"A2_EST"), Posicione("SA1", 1, xFilial("SA1")+SubStr(LPD->CLIENTE,1,6)+SubStr(LPD->CLIENTE,8,2),"A1_EST"))
       nAliqInt   := U_Aliqinterna(cUf) //Val( Substr( cAux, At( cUf,cAux)+2,2))/100
       nAliqSol   := nAliqInt
       nPerIcm    := AliqIcms(LPD->TIPOPED,'S',LPD->TIPOCLI)/100 // Alíquota de ICMS
       cEstCli    := Iif(LPD->TIPOCLI $ "D_B", Posicione("SA2", 1, xFilial("SA2")+SubStr(LPD->CLIENTE,1,6)+SubStr(LPD->CLIENTE,8,2),"A2_EST"), Posicione("SA1", 1, xFilial("SA1")+SubStr(LPD->CLIENTE,1,6)+SubStr(LPD->CLIENTE,8,2),"A1_EST"))
       cClaCli    := Iif(LPD->TIPOCLI $ "D_B", Posicione("SA2", 1, xFilial("SA2")+SubStr(LPD->CLIENTE,1,6)+SubStr(LPD->CLIENTE,8,2),"A2_CLAS"), Posicione("SA1", 1, xFilial("SA1")+SubStr(LPD->CLIENTE,1,6)+SubStr(LPD->CLIENTE,8,2),"A1_CLAS"))
       nPercSubst := If( Posicione("SZ8", 1, xFilial("SZ8")+cEstCli+cClaCli,"Z8_PERC") > 0, Posicione("SZ8", 1, xFilial("SZ8")+cEstCli+cClaCli,"Z8_PERC"), 0)
       nVlrSTb    := 0
       nVlrLcr    := 0
       nPerLcr    := 0
       nVlrPisCof := 0
       lPisCof    := .f.
       aItmPed    := {}
       aCliente   := {}
       cRestri    := ""
       aRegis     := {}
       
       aadd(aCliente, Iif(LPD->TIPOPED $ "D_B", "SA2", "SA1") )
       aadd(aCliente, Iif(LPD->TIPOPED $ "D_B", Posicione("SA2", 1, xFilial("SA2")+SubStr(LPD->CLIENTE,1,6)+SubStr(LPD->CLIENTE,8,2),"A2_COD"), Posicione("SA1", 1, xFilial("SA1")+SubStr(LPD->CLIENTE,1,6)+SubStr(LPD->CLIENTE,8,2),"A1_COD")) )
       
       //******************************************************
       //** ROTINA PARA CALCULO DE IMPOSTOS
       //Posiciono Cabeçalho de pedidos para garantir que está correto
       DbSelectArea("SC5") 
       SC5->( DbSetOrder(1) )
       SC5->( DbSeek( xFilial("SC5") + LPD->PEDIDO ))

       DbSelectArea("ITM")
       While !Eof()
             nVlrMer += ITM->C6_VALOR
             nAuxIpi := 0
             If Posicione("SF4", 1, xFilial("SF4")+ITM->C6_TES, "F4_IPI") == 'S'
                nAuxIPI   := ITM->C6_VALOR * (Posicione("SB1", 1, xFilial("SB1")+ITM->C6_PRODUTO, "B1_IPI") / 100)
                nVlrIPI += nAuxIPI
             Else
                nAuxIPI   := 0
             Endif
             If Posicione("SF4", 1, xFilial("SF4")+ITM->C6_TES, "F4_INCSOL") == 'S'
                nAliqSol := nAliqInt + iif((cUf = "RJ") .AND. (SF4->F4_ISEFECP <> '1'),0.01,0) // Consid. 1% fundo pobreza RJ
             	
                nBaseIcms  := ITM->C6_VALOR + Iif( Posicione("SF4", 1, xFilial("SF4")+ITM->C6_TES, "F4_INCIDE") == "S", nAuxIPI, 0)
                nAuxIcms   := nBaseIcms * nPerIcm
                nLucroST   := (1+(nPercSubst/100))
                nBaseSubst := (ITM->C6_VALOR + nAuxIPI) * nLucroST*IIF(SF4->F4_BSICMST > 0,SF4->F4_BSICMST/100,1)
                nVlrSTb    += (nBaseSubst * nAliqSol) - nAuxIcms
                If !(LPD->TIPOPED $ "D_B") .and. (Posicione("SF4", 1, xFilial("SF4")+ITM->C6_TES, "F4_PISCOF") $ '3') .and. (Posicione("SF4", 1, xFilial("SF4")+ITM->C6_TES, "F4_PISCRED") $ '4') 
                // Cleber(10/02/11)-Retirado pois o TES calcula o desconto independente do cliente-> .and. (Posicione("SA1", 1, xFilial("SA1")+SubStr(LPD->CLIENTE, 1, 6), "A1_CODCID") $ '002054.002259')  .and. (Posicione("SA1", 1, xFilial("SA1")+SubStr(LPD->CLIENTE, 1, 6), "A1_CALCSUF") $ 'S')
                   //LGS#20200210 - Adequação de release 12.1.25 e posteriores
                   //nVlrPisCof += ITM->C6_VALOR * ((GETMV("MV_TXPIS")+GETMV("MV_TXCOFIN")) / 100)
                   nVlrPisCof += ITM->C6_VALOR * ( ( ( _nMVTXPIS ) + ( _nMVTXCOFI ) ) / 100 )
                   lPisCof    := .t.
                Endif
             Else
                nBaseIcms  := ITM->C6_VALOR + Iif( Posicione("SF4", 1, xFilial("SF4")+ITM->C6_TES, "F4_INCIDE") == "S", nAuxIPI, 0)
                nAuxIcms   := nBaseIcms * nPerIcm
                nBaseSubst := (ITM->C6_VALOR + nAuxIPI) * nLucroST*IIF(SF4->F4_BSICMST > 0,SF4->F4_BSICMST/100,1)
                nLucroST   := (1+(nPercSubst/100))
                nBaseSubst := 0
             Endif
             aadd(aItmPed, { ITM->C6_PRODUTO, Posicione("SB1", 1, xFilial("SB1")+ITM->C6_PRODUTO, "B1_DESC"),;
                             Iif(Len(Alltrim(ITM->C6_PRODUTO)) == 12, SubStr(ITM->C6_PRODUTO, 11, 2)+" - "+Alltrim(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(ITM->C6_PRODUTO, 11, 2), "Z5_DESCR")), Posicione("SB1", 1, xFilial("SB1")+ITM->C6_PRODUTO, "B1_UM")) ,;
                             Transform(ITM->C6_QTDVEN,"@E 999,999"),;
                             Transform(ITM->C6_PRCVEN,"@E 999,999.99"),;
                             Transform(ITM->C6_VALOR,"@E 999,999,999.99"),;
                             Transform(nAuxIPI,"@E 999,999.99"),;
                             Transform(((nBaseSubst * nAliqSol) - nAuxIcms),"@E 999,999,999.99"),;
                             Transform(((ITM->C6_VALOR+nAuxIPI)+((nBaseSubst * nAliqSol) - nAuxIcms)),"@E 999,999,999.99") })
             aadd(aRegis, ITM->R_E_C_N_O_)

             DbSelectArea("ITM")
             DbSkip()
       Enddo
       If !(LPD->TIPOPED $ "D_B") .and. (Posicione("SA1", 1, xFilial("SA1")+SubStr(LPD->CLIENTE,1,6)+SubStr(LPD->CLIENTE,8,2),"A1_CALCSUF") != "N") .and. !Empty(Posicione("SA1", 1, xFilial("SA1")+SubStr(LPD->CLIENTE,1,6)+SubStr(LPD->CLIENTE,8,2),"A1_SUFRAMA"))
          nDescZFR := nVlrMer * 0.07
       Endif
       If lPisCof
          nVlrMer := nVlrMer - nDescZFR - nVlrPisCof
          nVlrTot := nVlrMer + nVlrIPI + nVlrSTb
       Else
          nVlrMer := nVlrMer - nDescZFR
          nVlrTot := nVlrMer + nVlrIPI + nVlrSTb - nDescZFR
       Endif
       
       RecLock("LPD",.f.)
          LPD->VALTOT := nVlrTot
       MsUnLock()
       
       DbSelectArea("ITM")
       DbCloseArea()
       
       /*** ATUALIZAÇÃO DO LUCRO ***/
       nPerLcr := LPD->LUCRO
       nVlrLcr := nVlrMer * (LPD->LUCRO / 100)
       
       /*** ATUALIZAÇÃO DA COMISSÃO ***/
       nPerCom := LPD->COMISSAO
       nVlrCom := LPD->VLRCOMIS
       
       /*** ATUALIZAÇÃO DO HISTÓRICO DO CLIENTE ***/
       cPriCom := LPD->PRICOM
       cUltCom := LPD->ULTCOM
       cRisco  := LPD->RISCOCLI
       
       /*** ATUALIZAÇÃO DA ULTIMA ALTERAÇÃO DO PEDIDO ***/
       cAltPed := Alltrim(LPD->ALTERACAO) //+" - "+DTOC(LPD->DATAALT)
       
       /*** ATUALIZAÇÃO DAS APROVAÇÕES ***/
       If !lAcsCad
          If !lAcsOut
             oLibCad:bWhen := {||.f.} 
          Else
             oLibCad:bWhen := {||.t.} 
          Endif
       Else 
          oLibRec:bWhen := {||.t.}
       Endif
       If !lAcsPed 
          oLibPed:bWhen := {||.f.} 
       Endif
       If !lAcsCre
          oLibCre:bWhen := {||.f.} 
       Endif
       If !lAcsDir
          oLibDir:bWhen := {||.f.}
       Endif
       lLibPed := LPD->LIBPED ; cUsrPed := LPD->USRPED
       lLibCre := LPD->LIBCRE ; cUsrCre := LPD->USRCRE
       lLibDir := LPD->LIBDIR ; cUsrDir := LPD->USRDIR
       lLibRec := Iif(LPD->APROVA <> '2', .f., .t.) ; cUsrRec := LPD->USRAPR
       lLibCad := Iif(LPD->LIBCAD == .F., .f., .t.) ; cUsrCad := LPD->USRCAD
       /*** ATUALIZAÇÃO DAS RESTRIÇÕES ***/
       fBusInf(@oRestri, @cRestri, nPercSubst, nPerIcm, nAliqSol)
       
       /*** ATUALIZAÇÃO DAS OBSERVAÇÕES ***/
       fBusObs(@oObsMsg, @cObsMsg, @oObsSC5, @cObsSC5)
       
       /*** ATUALIZAÇÃO DE TODAS AS VARIÁVEIS DE TELA ***/
       oTipVen:Refresh()
       oVlrMer:Refresh()
       oVlrIPI:Refresh()
       oVlrSTb:Refresh()
       oVlrTot:Refresh()
       oVlrLcr:Refresh()
       oPerLcr:Refresh()
       oVlrCom:Refresh()
       oPerCom:Refresh()
       oLibPed:Refresh()
       oLibCre:Refresh()
       oLibDir:Refresh()
       oLibRec:Refresh()
       oLibCad:Refresh()
       oPriCom:SetText(cPriCom)
       oUltCom:SetText(cUltCom)
       oRisco:SetText(cRisco)
       oAltPed:SetText(cAltPed)
       oUsrPed:SetText(cUsrPed)
       oUsrCre:SetText(cUsrCre)
       oUsrDir:SetText(cUsrDir)
       oUsrRec:SetText(cUsrRec)
       oUsrCad:SetText(cUsrCad)
       oObsSC5:SetText(cObsSC5)
       oObsMsg:SetText(cObsMsg)
       oRestri:Refresh()
       oObsMsg:Refresh()
       oObsSC5:Refresh()
Return Nil

/*****************************************************************************/
/*** FBUSINF - Busca informações do crédito do cliente.                    ***/
/******************************************************************************
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Luís Gustavo  ³ fAcuPed - Busca acumul. de ped. do cliente.  ³±±
±±³20/08/10  ³ Cleber        ³ Informando Saldo de Ped. do Cliente no mes.  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fBusInf(oRestri, cRestri, nPercSubst, nPerIcm, nAliqSol)
       Local cQry1     := ""
       Local nTotTit   := 0
       Local nTotRes   := 0
       //Local nTotTes := 0
       Local nSaldoMes := 0 // Saldo em valor de pedidos no mês, exceto pedido atual
       Local _nTotAtr  := 0 //LGS#20200624 - Soma do Total de Titulos em atraso
       Local _nTotPAb  := 0 //LGS#20200625 - Soma do Total de Pedidos aprovados não faturados
       
       /*** INFORMAÇÕES FINANCEIRAS ***/
		 cQry1 := "SELECT     CASE WHEN (SE1.E1_VENCREA < SE1.E1_BAIXA) THEN '1-PAT' WHEN (SE1.E1_SALDO > 0.0) AND (SE1.E1_VENCREA < "+;
                           "(SELECT     CAST(DATEPART(Year, GETDATE()) AS VARCHAR) + CASE WHEN LEN(DATEPART(Month, GETDATE())) = 1 THEN CAST('0' AS VARCHAR) "+;
                                                   "+ CAST(DATEPART(Month, GETDATE()) AS VARCHAR) ELSE CAST(DATEPART(Month, GETDATE()) AS VARCHAR) END + CASE WHEN LEN(DATEPART(Day, "+;
                                                   " GETDATE())) = 1 THEN CAST('0' AS VARCHAR) + CAST(DATEPART(Day, GETDATE()) AS VARCHAR) ELSE CAST(DATEPART(Day, GETDATE()) AS VARCHAR) "+;
                                                   " END)) THEN '2-ATR' ELSE '3-NORMAL' END AS STATUS, E1_FILIAL, CASE WHEN (SE1.E1_VENCREA < SE1.E1_BAIXA) "+;
                      "THEN CAST(CAST(SE1.E1_BAIXA AS DATETIME) AS INT) - CAST(CAST(SE1.E1_VENCREA AS DATETIME) AS INT) WHEN (SE1.E1_SALDO > 0.0) AND "+;
                      "(SE1.E1_VENCREA < "+;
                          "(SELECT     CAST(DATEPART(Year, GETDATE()) AS VARCHAR) + CASE WHEN LEN(DATEPART(Month, GETDATE())) = 1 THEN CAST('0' AS VARCHAR) "+;
                                                   "+ CAST(DATEPART(Month, GETDATE()) AS VARCHAR) ELSE CAST(DATEPART(Month, GETDATE()) AS VARCHAR) END + CASE WHEN LEN(DATEPART(Day, "+;
                                                   "GETDATE())) = 1 THEN CAST('0' AS VARCHAR) + CAST(DATEPART(Day, GETDATE()) AS VARCHAR) ELSE CAST(DATEPART(Day, GETDATE()) AS VARCHAR) "+;
                                                   "END)) THEN CAST(CAST "+;
                          "((SELECT     SUBSTRING(CONVERT(VARCHAR, GETDATE(), 105), 7, 4) + SUBSTRING(CONVERT(VARCHAR, GETDATE(), 105), 4, 2) + SUBSTRING(CONVERT(VARCHAR, "+;
                                                   " GETDATE(), 105), 1, 2)) AS DATETIME) AS INT) - CAST(CAST(SE1.E1_VENCREA AS DATETIME) AS INT) ELSE 0 END AS ATRASO, "+;
                      "E1_CLIENTE + '-' + E1_LOJA AS CLIENTE, E1_PREFIXO + '-' + E1_NUM + '-' + E1_PARCELA AS TITULO, SUBSTRING(E1_VENCREA, 7, 2) "+;
                      "+ '/' + SUBSTRING(E1_VENCREA, 5, 2) + '/' + SUBSTRING(E1_VENCREA, 1, 4) AS VENCIMENTO, E1_SALDO AS VALOR "+;
				"FROM "+RetSqlName("SE1")+" AS SE1 WITH (NOLOCK) "+;
				"WHERE (D_E_L_E_T_ = '') AND (E1_CLIENTE = '"+SubStr(LPD->CLIENTE, 1, 6)+"') AND (E1_SALDO > 0)"


       /*
       cQry1 := ""
       cQry1 += "SELECT * "
       cQry1 += "FROM MAT_"+cEmpAnt+"041FINANC WITH (NOLOCK) "
       cQry1 += "WHERE CLIENTE = '"+SubStr(LPD->CLIENTE, 1, 6)+"-"+SubStr(LPD->CLIENTE, 8, 2)+"' "
       cQry1 += "  AND VALOR   > 0 "  
       */       
       TCQUERY cQry1 ALIAS "TIT" NEW

		 /*Levantamento de Saldo de Pedidos Aprovados no Mês*/       
       cQry1 := "SELECT SUM(C6_VALOR*(CASE WHEN C5_ESPECI4 > '' THEN (1/0.7) ELSE 1 END)) AS VALOR FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "+;
                "LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C6_FILIAL = C5_FILIAL) AND (C6_NUM = C5_NUM) "+;
                "LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (C6_TES = F4_CODIGO) "+;
                "WHERE (SC6.D_E_L_E_T_ <> '*') AND (C6_FILIAL = '"+xFilial("SC6")+"') AND (C5_CLIENTE = '"+SubStr(LPD->CLIENTE, 1, 6)+;
                "') AND (SUBSTRING(C5_EMISSAO,1,6) = '"+SUBSTR(DTOS(DATE()),1,6)+"') AND (C6_NUM <> '"+LPD->PEDIDO+"') AND (C5_APROVA = '1') AND "+;
                "((F4_DUPLIC <> 'N') OR (C6_TES = '519'))"
       TCQUERY cQry1 ALIAS "TOTVENDIDO" NEW
       nSaldoMes := TOTVENDIDO->VALOR
       dbselectarea("TOTVENDIDO")
       dbclosearea()

       DbSelectArea("TIT")
       DbGoTop()
       cRestri := ""
       cAuxRes := ""
       While !Eof()
             If SubStr(TIT->STATUS, 1, 1) == '2' //Titulos em atraso
                cAuxRes += "    - TIT.: "+TIT->E1_FILIAL+'/'+TIT->TITULO+" VENCTO. EM "+TIT->VENCIMENTO+Chr(13)+chr(10)
                cAuxRes += "      * "+StrZero(TIT->ATRASO,3)+" dia(s) de atraso. - "+TransForm( TIT->VALOR, "@E 999,999,999.99")+Chr(13)+chr(10)
                nTotTit += TIT->VALOR
                _nTotAtr += TIT->VALOR
             ElseIf SubStr(TIT->STATUS, 1, 1) == '1'
                    cAuxRes += "    - TIT.: "+TIT->E1_FILIAL+'/'+TIT->TITULO+" VENCTO. EM "+TIT->VENCIMENTO+Chr(13)+chr(10)
                    cAuxRes += "      * "+StrZero(TIT->ATRASO,3)+" dia(s) de atraso. - "+TransForm( TIT->VALOR, "@E 999,999,999.99")+Chr(13)+chr(10)
                    nTotTit += TIT->VALOR
                    _nTotAtr += TIT->VALOR
             ElseIf SubStr(TIT->STATUS, 1, 1) == '3'
                    nTotTit += TIT->VALOR
             Endif
             /*
             If TIT->EMPRESA $ '0101_0501'
                If SubStr(TIT->STATUS, 1, 1) == '2'
                   cAuxRes += "    - TIT.: "+SUBSTR(TIT->EMPRESA, 1, 2)+'/'+TIT->TITULO+" VENCTO. EM "+TIT->VENCIMENTO+Chr(13)+chr(10)
                   cAuxRes += "      * "+StrZero(TIT->ATRASO,3)+" dia(s) de atraso. - "+TransForm( TIT->VALOR, "@E 999,999,999.99")+Chr(13)+chr(10)
                   nTotTit += TIT->VALOR
                ElseIf SubStr(TIT->STATUS, 1, 1) == '1'
                       cAuxRes += "    - TIT.: "+SUBSTR(TIT->EMPRESA, 1, 2)+'/'+TIT->TITULO+" VENCTO. EM "+TIT->VENCIMENTO+Chr(13)+chr(10)
                       cAuxRes += "      * "+StrZero(TIT->ATRASO,3)+" dia(s) de atraso. - "+TransForm( TIT->VALOR, "@E 999,999,999.99")+Chr(13)+chr(10)
                       nTotTit += TIT->VALOR
                ElseIf SubStr(TIT->STATUS, 1, 1) == '3'
                       nTotTit += TIT->VALOR
                Endif
             ElseIf TIT->EMPRESA $ '0104'
                    If GETMV("MV_JUNFIL")
                       If SubStr(TIT->STATUS, 1, 1) == '2'
                          cAuxRes += "    - TIT.: "+SUBSTR(TIT->EMPRESA, 1, 2)+'/'+TIT->TITULO+" VENCTO. EM "+TIT->VENCIMENTO+Chr(13)+chr(10)
                          cAuxRes += "      * "+StrZero(TIT->ATRASO,3)+" dia(s) de atraso."+Chr(13)+chr(10)
                          nTotRes += TIT->VALOR
                       ElseIf SubStr(TIT->STATUS, 1, 1) == '1'
                              cAuxRes += "    - TIT.: "+SUBSTR(TIT->EMPRESA, 1, 2)+'/'+TIT->TITULO+" VENCTO. EM "+TIT->VENCIMENTO+Chr(13)+chr(10)
                              cAuxRes += "      * "+StrZero(TIT->ATRASO,3)+" dia(s) de atraso."+Chr(13)+chr(10)
                              nTotRes += TIT->VALOR
                       ElseIf SubStr(TIT->STATUS, 1, 1) == '3'
                              nTotRes += TIT->VALOR
                       Endif
                    Else
                       If SubStr(TIT->STATUS, 1, 1) == '2'
                          cAuxRes += "    - TIT.: "+SUBSTR(TIT->EMPRESA, 1, 2)+'/'+TIT->TITULO+" VENCTO. EM "+TIT->VENCIMENTO+Chr(13)+chr(10)
                          cAuxRes += "      * "+StrZero(TIT->ATRASO,3)+" dia(s) de atraso."+Chr(13)+chr(10)
                          nTotRes += TIT->VALOR
                       ElseIf SubStr(TIT->STATUS, 1, 1) == '1'
                              cAuxRes += "    - TIT.: "+SUBSTR(TIT->EMPRESA, 1, 2)+'/'+TIT->TITULO+" VENCTO. EM "+TIT->VENCIMENTO+Chr(13)+chr(10)
                              cAuxRes += "      * "+StrZero(TIT->ATRASO,3)+" dia(s) de atraso."+Chr(13)+chr(10)
                              nTotRes += TIT->VALOR
                       ElseIf SubStr(TIT->STATUS, 1, 1) == '3'
                              nTotRes += TIT->VALOR
                       Endif
                       //nTotRes += TIT->VALOR
                    Endif
             ElseIf TIT->EMPRESA $ '0201'
                    If GETMV("MV_JUNEMP")
                       If SubStr(TIT->STATUS, 1, 1) == '2'
                          cAuxRes += "    - TIT.: "+SUBSTR(TIT->EMPRESA, 1, 2)+'/'+TIT->TITULO+" VENCTO. EM "+TIT->VENCIMENTO+Chr(13)+chr(10)
                          cAuxRes += "      * "+StrZero(TIT->ATRASO,3)+" dia(s) de atraso."+Chr(13)+chr(10)
                          nTotTes += TIT->VALOR
                       ElseIf SubStr(TIT->STATUS, 1, 1) == '1'
                              cAuxRes += "    - TIT.: "+SUBSTR(TIT->EMPRESA, 1, 2)+'/'+TIT->TITULO+" VENCTO. EM "+TIT->VENCIMENTO+Chr(13)+chr(10)
                              cAuxRes += "      * "+StrZero(TIT->ATRASO,3)+" dia(s) de atraso."+Chr(13)+chr(10)
                              nTotTes += TIT->VALOR
                       ElseIf SubStr(TIT->STATUS, 1, 1) == '3'
                              nTotTes += TIT->VALOR
                       Endif
                    Else
                       nTotTes += TIT->VALOR
                    Endif
             Endif*/
             DbSelectArea("TIT")
             DbSkip()
       Enddo
       DbSelectArea("TIT")
       DbCloseArea()

       cRestri += "1º) ÍNDICE DE LIQUIDEZ: "+Transform(Posicione("SA1", 1, xFilial("SA1")+SubStr(LPD->CLIENTE,1,6)+SubStr(LPD->CLIENTE,8,2), "A1_LIQUID") ,"@E 999.99%")+Chr(13)+chr(10)
       cRestri += ""+Chr(13)+chr(10)
       cRestri += "2º) TENDÊNCIA DE LIQUIDEZ ULT. VENCTOS.:"+Transform(Posicione("SA1", 1, xFilial("SA1")+SubStr(LPD->CLIENTE,1,6)+SubStr(LPD->CLIENTE,8,2), "A1_TENLIQ"),"@E 999.99%")+Chr(13)+chr(10)
       cRestri += ""+Chr(13)+chr(10)
       cRestri += "3º) TITULOS EM ABERTO C/ ATRASO: "+Chr(13)+chr(10)
       cRestri += cAuxRes
       cRestri += ""+Chr(13)+chr(10)
       cRestri += "4º) VALOR TOTAL DE TITULOS EM ABERTO: R$ "+Alltrim(Transform(nTotTit,"@E 999,999,999.99"))+" (M)"+Chr(13)+chr(10)
       cRestri += "                                      R$ "+Alltrim(Transform(nTotRes,"@E 999,999,999.99"))+" (R)"+Chr(13)+chr(10)
       cRestri += ""+Chr(13)+chr(10)
       cRestri += "5º) SCI "+Chr(13)+chr(10)
       nLinMen := 0
       nPasso  := 0
       nLinMen := mlcount(Posicione("SA1", 1, xFilial("SA1")+SubStr(LPD->CLIENTE,1,6)+SubStr(LPD->CLIENTE,8,2), "A1_OB"), 51)
       cTexto  := Posicione("SA1", 1, xFilial("SA1")+SubStr(LPD->CLIENTE,1,6)+SubStr(LPD->CLIENTE,8,2), "A1_OB")
       While nPasso <= nLinMen
             cDescri := MemoLine( cTexto, 51, nPasso )
             nPasso++
             If Empty(cDescri)
                Loop
             EndIf
             cRestri += "    - "+Alltrim(cDescri)+Chr(13)+chr(10)
       Enddo
       cRestri += ""+Chr(13)+chr(10)
       nAcumul := fAcuPed(aCliente, nPercSubst, nPerIcm, nAliqSol)
       cRestri += "6º) PEDIDOS EM ABERTO: R$ "+Transform(nAcumul, "@E 999,999,999.99")+Chr(13)+chr(10)
       If nAcumul > Posicione("SA1", 1, xFilial("SA1")+aCliente[2], "A1_LC")
          cRestri += "    - Ultrapassa sugestão de crédito: "+Chr(13)+chr(10)
          cRestri += "      R$ "+Transform(Posicione("SA1", 1, xFilial("SA1")+aCliente[2], "A1_LC"), "@E 999,999,999.99")+Chr(13)+chr(10)
       Endif
       cRestri += ""+Chr(13)+chr(10)
       cRestri += "7º) SALDO DE PEDIDOS DO CLIENTE NO MÊS (EXCETO ESTE): R$ "+alltrim(Transform(nSaldoMes, "@E 999,999,999.99"))+Chr(13)+chr(10)

       //LGS#20200625 - Apuração de total (R$) pedidos em Aberto - MENOS O QUE ESTÁ SENDO LIBERADO
       _nTotPAb := fAcuPed(aCliente, nPercSubst, nPerIcm, nAliqSol, LPD->PEDIDO )


       //LGS#20200624 - CRIAÇÃO DE REGRA DE APROVAÇÃO AUTOMÁTICO.
       RECLOCK( "LPD", .F. )
          LPD->VALATR := _nTotAtr
          LPD->TOTTIT := nTotTit
          LPD->TOTPAB := _nTotPAb
       MSUNLOCK()
Return

/****************************************************************************************/
/*** FACUPED - Acumulado de pedidos.                                                  ***/
/*** Luis Gustavo - 29/06/2020 - Ajustei essa função para retornar o valor de pedidos ***/
/***                             liberados com valor total (Mercadoria + IPI + ST)    ***/
/***                             menos o pedido atual.                                ***/
/****************************************************************************************/
Static Function fAcuPed(aCliente, nPercSubst, nPerIcm, nAliqSol, _NumPedAtu )
       Local cQuery  := ""
       Local nAcumul := 0
       
       cQuery += "SELECT VALTOT = SUM(SC6.C6_VALOR), "
       cQuery += "       VALIPI = SUM((SC6.C6_VALOR * (SB1.B1_IPI / 100))), "
       cQuery += "       VALICM = (CASE WHEN SF4.F4_INCSOL = 'S' THEN (CASE WHEN SF4.F4_INCIDE = 'S' THEN SUM(SC6.C6_VALOR + (SC6.C6_VALOR * (SB1.B1_IPI / 100))) ELSE 0 END ) ELSE 0 END), "
       cQuery += "       AUXICM = ((CASE WHEN SF4.F4_INCSOL = 'S' THEN (CASE WHEN SF4.F4_INCIDE = 'S' THEN SUM(SC6.C6_VALOR + (SC6.C6_VALOR * (SB1.B1_IPI / 100))) ELSE 0 END ) ELSE 0 END) * "+Stuff( Transform(nPerIcm,"@E 999.99"), AT(",",Transform(nPerIcm,"@E 999.99")), 1, ".")+"), "
       cQuery += "       LUCROS = ( 1 + ( "+Stuff( Transform(nPercSubst,"@E 999.99"), AT(",",Transform(nPercSubst,"@E 999.99")), 1, ".")+" / 100) ), "
       cQuery += "       BASEST = CASE WHEN SF4.F4_INCSOL = 'S' THEN ( SUM(SC6.C6_VALOR) + SUM((SC6.C6_VALOR * (SB1.B1_IPI / 100))) ) * ( 1 + ( "+Stuff( Transform(nPercSubst,"@E 999.99"), AT(",",Transform(nPercSubst,"@E 999.99")), 1, ".")+" / 100) ) ELSE 0 END, "
       cQuery += "       VALSTB = ( (CASE WHEN SF4.F4_INCSOL = 'S' THEN ( SUM(SC6.C6_VALOR) + SUM((SC6.C6_VALOR * (SB1.B1_IPI / 100))) ) * ( 1 + ( "+Stuff( Transform(nPercSubst,"@E 999.99"), AT(",",Transform(nPercSubst,"@E 999.99")), 1, ".")+" / 100) ) ELSE 0 END) * "+Stuff( Transform(nAliqSol,"@E 999.99"), AT(",",Transform(nAliqSol,"@E 999.99")), 1, ".")+" ) - (CASE WHEN SF4.F4_INCSOL = 'S' THEN (CASE WHEN SF4.F4_INCIDE = 'S' THEN SUM(SC6.C6_VALOR + (SC6.C6_VALOR * (SB1.B1_IPI / 100))) ELSE 0 END ) ELSE 0 END) * "+Stuff( Transform(nPerIcm,"@E 999.99"), AT(",",Transform(nPerIcm,"@E 999.99")), 1, ".")+" "
       cQuery += "FROM SC5"+cEmpAnt+"0 SC5 WITH (NOLOCK) "
       cQuery += "LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON SC5.C5_FILIAL = SC6.C6_FILIAL AND SC5.C5_NUM = SC6.C6_NUM AND SC6.D_E_L_E_T_ = '' "
       cQuery += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON SB1.B1_FILIAL = SC6.C6_FILIAL AND SB1.B1_COD = SC6.C6_PRODUTO "
       cQuery += "LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON '  '          = SF4.F4_FILIAL AND SF4.F4_CODIGO = SC6.C6_TES "
       IF GETMV("MV_JUNFIL")
          cQuery += "WHERE "
       Else
          cQuery += "WHERE SC5.C5_FILIAL   = '"+xFilial("SC5")+"' AND "
       Endif
       cQuery += "         SC5.D_E_L_E_T_  = '' "
       cQuery += "  AND SC5.C5_NOTA     = '' "
       cQuery += "  AND SC5.C5_CLIENTE  = '"+aCliente[2]+"' "
       If _NumPedAtu <> NIL
          cQuery += "  AND SC5.C5_NUM <> '" + _NumPedAtu + "' "
       Endif
       cQuery += "GROUP BY SF4.F4_INCSOL, SF4.F4_INCIDE "
       If GETMV("MV_JUNEMP")
          If TcCanOpen("SC5020")
             cQuery += "UNION ALL "
             cQuery += "SELECT VALTOT = SUM(SC6.C6_VALOR), "
             cQuery += "       VALIPI = SUM((SC6.C6_VALOR * (SB1.B1_IPI / 100))), "
             cQuery += "       VALICM = (CASE WHEN SF4.F4_INCSOL = 'S' THEN (CASE WHEN SF4.F4_INCIDE = 'S' THEN SUM(SC6.C6_VALOR + (SC6.C6_VALOR * (SB1.B1_IPI / 100))) ELSE 0 END ) ELSE 0 END), "
             cQuery += "       AUXICM = ((CASE WHEN SF4.F4_INCSOL = 'S' THEN (CASE WHEN SF4.F4_INCIDE = 'S' THEN SUM(SC6.C6_VALOR + (SC6.C6_VALOR * (SB1.B1_IPI / 100))) ELSE 0 END ) ELSE 0 END) * "+Stuff( Transform(nPerIcm,"@E 999.99"), AT(",",Transform(nPerIcm,"@E 999.99")), 1, ".")+"), "
             cQuery += "       LUCROS = ( 1 + ( "+Stuff( Transform(nPercSubst,"@E 999.99"), AT(",",Transform(nPercSubst,"@E 999.99")), 1, ".")+" / 100) ), "
             cQuery += "       BASEST = CASE WHEN SF4.F4_INCSOL = 'S' THEN ( SUM(SC6.C6_VALOR) + SUM((SC6.C6_VALOR * (SB1.B1_IPI / 100))) ) * ( 1 + ( "+Stuff( Transform(nPercSubst,"@E 999.99"), AT(",",Transform(nPercSubst,"@E 999.99")), 1, ".")+" / 100) ) ELSE 0 END, "
             cQuery += "       VALSTB = ( (CASE WHEN SF4.F4_INCSOL = 'S' THEN ( SUM(SC6.C6_VALOR) + SUM((SC6.C6_VALOR * (SB1.B1_IPI / 100))) ) * ( 1 + ( "+Stuff( Transform(nPercSubst,"@E 999.99"), AT(",",Transform(nPercSubst,"@E 999.99")), 1, ".")+" / 100) ) ELSE 0 END) * "+Stuff( Transform(nAliqSol,"@E 999.99"), AT(",",Transform(nAliqSol,"@E 999.99")), 1, ".")+" ) - (CASE WHEN SF4.F4_INCSOL = 'S' THEN (CASE WHEN SF4.F4_INCIDE = 'S' THEN SUM(SC6.C6_VALOR + (SC6.C6_VALOR * (SB1.B1_IPI / 100))) ELSE 0 END ) ELSE 0 END) * "+Stuff( Transform(nPerIcm,"@E 999.99"), AT(",",Transform(nPerIcm,"@E 999.99")), 1, ".")+" "
             cQuery += "FROM SC5"+Iif(cEmpAnt $ '01', '02', '01')+"0 SC5 WITH (NOLOCK) "
             cQuery += "LEFT OUTER JOIN SC6020 SC6 WITH (NOLOCK) ON SC5.C5_FILIAL = SC6.C6_FILIAL AND SC5.C5_NUM = SC6.C6_NUM AND SC6.D_E_L_E_T_ = '' "
             cQuery += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON SB1.B1_FILIAL = SC6.C6_FILIAL AND SB1.B1_COD = SC6.C6_PRODUTO "
             cQuery += "LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON '  '          = SF4.F4_FILIAL AND SF4.F4_CODIGO = SC6.C6_TES "
             IF GETMV("MV_JUNFIL")
                cQuery += "WHERE "
             Else
                cQuery += "WHERE SC5.C5_FILIAL   = '"+xFilial("SC5")+"' "
             Endif
             cQuery += "  AND SC5.D_E_L_E_T_  = '' "
             cQuery += "  AND SC5.C5_NOTA     = '' "
             cQuery += "  AND SC5.C5_CLIENTE  = '"+aCliente[2]+"' "
             cQuery += "GROUP BY SF4.F4_INCSOL, SF4.F4_INCIDE "
          Endif
       Endif
       TCQUERY cQuery ALIAS "LIQ" NEW
            
       DbSelectArea("LIQ")
       DbGoTop()
       While !Eof()
             nAcumul += (LIQ->VALTOT + LIQ->VALIPI + LIQ->VALSTB)
             DbSelectArea("LIQ")
             DbSkip()
       Enddo
       DbSelectArea("LIQ")
       DbCloseArea()
Return(nAcumul)

/*************************************************************************************/
/*** FBUSOBS - Monta observações do pedido.                                        ***/
/*************************************************************************************/
Static Function fBusObs(oObsMsg, cObsMsg, oObsSC5, cObsSC5)
       cObsMsg := ""
       //cObsSC5 := ""
       cObserv := ""
       //oObsSc5:SetText(cObsSC5)
       //oObsSC5:Refresh()
       DbSelectArea("SC5")
       DbSetOrder(1)
       DbSeek(xFilial("SC5")+LPD->PEDIDO,.t.)
       If Found()
          cObsMsg := MSMM(SC5->C5_OBSPED, , , , 3)
          cObserv := Alltrim(U_TiraAcento(MSMM(SC5->C5_OBSSC5)))
          //cObsSC5 := Alltrim(U_TiraAcento(MSMM(SC5->C5_OBSSC5)))
       Else
          cObsMsg := ""
          cObsSC5 := ""
       Endif
       oObsSc5:SetText(cObserv)
       //oObsSc5:SetText(cObsSC5)
       oObsSC5:Refresh()       
Return

/*************************************************************************************/
/*** FVALCOM - Atualiza variáveis de comissão e lucro, caso a comis. seja alterada.***/
/*************************************************************************************/
Static Function fValCom(oVlrLcr, nVlrLcr, oPerLcr, nPerLcr, oVlrCom, nVlrCom, oPerCom, nPerCom)
       DbSelectArea("LPD")
       If RecCount() < 0
          Return
       Endif
       If QtdComp(LPD->COMISSAO) <> QtdComp(nPerCom)
          If Round(nPerCom, 2) > Round(Posicione("SC5", 1, xFilial("SC5")+LPD->PEDIDO, "C5_MEDCOM"), 2)
             MsgBox("Comissão excede o percentual máximo permitido para esse pedido.", "Atenção", "ALERT")
             nPerCom := LPD->COMISSAO
             nPerLcr := LPD->LUCRO
          Else
             If QtdComp(nPerCom) < QtdComp(LPD->COMISSAO)
                nDifCom := LPD->COMISSAO - nPerCom
                nPerLcr := nPerLcr + nDifCom
             Else 
                nDifCom := nPerCom - LPD->COMISSAO
                nPerLcr := nPerLcr - nDifCom
             Endif
          Endif
          nVlrLcr := nVlrMer * (nPerLcr / 100)
          nVlrCom := nVlrMer * (nPerCom / 100)
          RecLock("LPD",.f.)
             LPD->COMISSAO := nPerCom
             LPD->LUCRO    := nPerLcr
             LPD->VLRCOMIS := nVlrCom
          MsUnLock()
       Endif
       /*** ATUALIZAÇÃO DE TODAS AS VARIÁVEIS DE TELA ***/
       oVlrLcr:Refresh()
       oPerLcr:Refresh()
       oVlrCom:Refresh()
       oPerCom:Refresh()
Return 

/*************************************************************************************/
/*** FMRCPED - Marcação da aprovação de pedidos.                                  ***/
/*************************************************************************************/
Static Function fMRCPed()
       DbSelectArea("LPD")
       If RecCount() > 0
          DbSelectArea("SC5")
          DbSetOrder(1)
          DbSeek(xFilial("SC5")+LPD->PEDIDO,.t.)
          If Found()
             If SC5->C5_NAOCONF $ 'S'
                MsgBox("Atenção, pedido não conforme com a Politica de Vendas.", "Atenção...", "STOP")
                lLibPed := .F. //Iif(lLibPed, .f., .f.)
                Return
             Else
                cUsrPed := Iif(lLibPed, cUsername, space(15) )
                oUsrPed:SetText(cUsrPed)
                RecLock("LPD",.f.)
                   LPD->LIBPED := lLibPed
                   LPD->USRPED := Iif(lLibPed, cUsername, space(15) )
                MsUnLock()
             Endif
          Endif
       Endif
Return

/*************************************************************************************/
/*** FMRCCRE - Marcação da aprovação de credito.                                  ***/
/*************************************************************************************/
Static Function fMRCCre()
       DbSelectArea("LPD")
       If RecCount() > 0
          cUsrCre := Iif(lLibCre, cUsername, space(15) )
          oUsrCre:SetText(cUsrCre)
          RecLock("LPD",.f.)
             LPD->LIBCRE := Iif(lLibCre, .t.                    , .f.       )
             LPD->USRCRE := Iif(lLibCre, cUsername, space(15) )
          MsUnLock()
       Endif
Return

/*************************************************************************************/
/*** FMRCDIR - Marcação da aprovação de diretoria.                                ***/
/*************************************************************************************/
Static Function fMRCDir()
       DbSelectArea("LPD")
       If RecCount() > 0
          cUsrDir := Iif(lLibDir, cUsername, space(15) )
          oUsrDir:SetText(cUsrDir)
          RecLock("LPD",.f.)
             LPD->LIBDIR := Iif(lLibDir, .t.                    , .f.       )
             LPD->USRDIR := Iif(lLibDir, cUsername, space(15) )
             LPD->USRAPR := cUsername
          MsUnLock()
       Endif
Return

/*************************************************************************************/
/*** FMRCREC - Marcação da aprovação de credito.                                  ***/
/*************************************************************************************/
Static Function fMRCRec()
       DbSelectArea("LPD")
       If RecCount() > 0
          /*
          LPD->APROVA := Iif(lLibRec, "2", Iif( lLibPed .and. lLibCre .and. lLibDir, "1", "0") )
          LPD->USRAPR := cUsrRec
          */
          cUsrRec := Iif(lLIbRec, cUsername, space(15))
          RecLock("LPD",.f.)
             LPD->USRAPR := cUsrRec
             if lLIbRec
                LPD->APROVA := "2"
             else
                LPD->APROVA := "0"
             endif
             LPD->LIBPED := .f. ; LPD->LIBDIR := .f. ; LPD->LIBCRE := .f.
             LPD->USRCRE := "" ; LPD->USRDIR := "" ; LPD->USRPED := ""
             cUsrPed := "" ; cUsrCre := "" ; cUsrDir := ""
             lLibPed := .f. ;  lLibCre := .f. ; lLibDir := .f.
          MsUnLock()
          oUsrRec:SetText(cUsrRec)
          oUsrPed:SetText(cUsrPed)
          oUsrDir:SetText(cUsrDir)
          oUsrCre:SetText(cUsrCre)
       Endif
Return

/*************************************************************************************/
/*** FMRCCAD - Marcação da liberação de cadastro (Sintegra)                       ***/
/*************************************************************************************/
Static Function fMRCCad()
       DbSelectArea("LPD")
       If RecCount() > 0
          cUsrCad := Iif(lLibCad, cUsername, space(15) )
          oUsrCad:SetText(cUsrCad)
          RecLock("LPD",.f.)
             LPD->LIBCAD := Iif(lLibCad, .T.                    , .F.       )
             LPD->USRCAD := Iif(lLibCad, cUsername, space(15) )
             If lAcsOut
                LPD->LIBPED := Iif(lLibCad, .T.                    , .F.       )
                LPD->USRPED := Iif(lLibCad, cUsername, space(15) )
                oUsrPed:SetText(cUsrCad)
                lLibPed := Iif(lLibCad, .T.                    , .F.       )
                LPD->LIBCRE := Iif(lLibCad, .T.                    , .F.       )
                LPD->USRCRE := Iif(lLibCad, cUsername, space(15) )
                oUsrCre:SetText(cUsrCad)
                lLibCre := Iif(lLibCad, .T.                    , .F.       )
                LPD->LIBDIR := Iif(lLibCad, .T.                    , .F.       )
                LPD->USRDIR := Iif(lLibCad, cUsername, space(15) )
                oUsrDir:SetText(cUsrCad)
                lLibDir := Iif(lLibCad, .T.                    , .F.       )
                LPD->USRAPR := Iif(lLibCad, cUsername, space(15) )
                LPD->APROVA := Iif(lLibCad, '1', '0' )
             Endif
          MsUnLock()
       Endif
Return

/*************************************************************************************/
/*** FAPRPED - Montagem da enchoicebar no menu de aprovação                        ***/
/*************************************************************************************/
Static Function fAprPed(nOpc, oDlg, bOk, bCancel)
       Private oBar
       //DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlg
       //LGS#20190923 - ATUALIZADO FUNÇÕES PARA ATENDIMENTO DE ATUALIZAÇÃO DE RELEASE 12.1.25 
       
       oBar := FwButtonBar():New()
       oBar:Init( oDlg, 025, 025, CONTROL_ALIGN_TOP, .T., .f. )
       If nOpc == 1
          oBar:addBtnImage( "SIMULACAO.PNG" , "Titulos abertos..."      , { | | FATX01_3( aCliente ) }, , .T., CONTROL_ALIGN_LEFT )
          oBar:addBtnImage( "BUDGET.PNG"    , "Titulos Recebidos..."    , { | | FATX01_4( aCliente ) }, , .T., CONTROL_ALIGN_LEFT )
          oBar:addBtnImage( "CONTAINR.PNG"  , "Itens..."                , { | | FATX01_5( aItmPed  ) }, , .T., CONTROL_ALIGN_LEFT )
          oBar:addBtnImage( "BMPGROUP.PNG"  , "Cliente..."              , { | | FATX01_6( aCliente ) }, , .T., CONTROL_ALIGN_LEFT )
          oBar:addBtnImage( "OBJETIVO.PNG"  , "Histórico do pedido..."  , { | | U_fHisPed(2)         }, , .T., CONTROL_ALIGN_LEFT )
          oBar:addBtnImage( "EDITWEB.PNG"   , "Inclui observações..."   , { | | FATX01_7()           }, , .T., CONTROL_ALIGN_LEFT )
          oBar:addBtnImage( "PRECO.PNG"     , "Condição de Pagamento...", { | | FATX01_A()           }, , .T., CONTROL_ALIGN_LEFT )
          oBar:addBtnImage( "ORDEM.PNG"     , "Visualiza Pedido..."     , { | | FATX01_E()           }, , .T., CONTROL_ALIGN_LEFT )
          oBar:addBtnImage( "NOVACELULA.PNG", "Pesquisa..."             , { | | FATX01_F(1, "LPD")   }, , .T., CONTROL_ALIGN_LEFT )
          oBar:addBtnImage( "RELATORIO.PNG" , "Planilha Financeira.."   , { | | U_FATX01_P()         }, , .T., CONTROL_ALIGN_LEFT )
          oBar:addBtnImage( "OK.PNG"        , "Confirma..."             , { | | FATX01_2(nOpc)       }, , .T., CONTROL_ALIGN_LEFT )
          oBar:addBtnImage( "CANCEL.PNG"    , "Sair..."                 , { | | oDlg:End()           }, , .T., CONTROL_ALIGN_LEFT )
       Else
          oBar:addBtnImage( "S4WB010N.PNG"     , "Impressão..."            , { | | u_FATX01_h()         }, , .T., CONTROL_ALIGN_LEFT )
          oBar:addBtnImage( "NOVACELULA.PNG"   , "Pesquisa..."                 , { | | FATX01_F(2, "TMP")   }, , .T., CONTROL_ALIGN_LEFT )
          oBar:addBtnImage( "CANCEL.PNG"       , "Sair..."                 , { | | DbSelectArea("TMP"), DbCloseArea(), oTempTbl01:Delete(), oDlg:End() }, , .T., CONTROL_ALIGN_LEFT )
       Endif
       //DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlg
       //If nOpc == 1
       //   DEFINE BUTTON oBtAb  RESOURCE "SIMULACA"   OF oBar GROUP ACTION  FATX01_3(aCliente)                            TOOLTIP OemToAnsi("Titulos abertos...")
       //   DEFINE BUTTON oBtRe  RESOURCE "BUDGETY"    OF oBar GROUP ACTION  FATX01_4(aCliente)                            TOOLTIP OemToAnsi("Titulos Recebidos...")
       //   DEFINE BUTTON oBtIt  RESOURCE "CONTAINR"   OF oBar GROUP ACTION  FATX01_5(aItmPed)                             TOOLTIP OemToAnsi("Itens...")
       //   DEFINE BUTTON oBtCl  RESOURCE "BMPGROUP"   OF oBar GROUP ACTION  FATX01_6(aCliente)                            TOOLTIP OemToAnsi("Cliente...")
       //   DEFINE BUTTON oBrSi  RESOURCE "OBJETIVO"   OF oBar GROUP ACTION  U_fHisPed(2)                                  TOLLTIP OemToAnsi("Histórico do pedido...")
       //   DEFINE BUTTON oBtIt  RESOURCE "EDIT"       OF oBar GROUP ACTION  FATX01_7()                                    TOOLTIP OemToAnsi("Inclui observações...")
       //   DEFINE BUTTON oBtIt  RESOURCE "PRECO"      OF oBar GROUP ACTION  FATX01_A()                                    TOOLTIP OemToAnsi("Condição de Pagamento...")
       //   DEFINE BUTTON oBtIt  RESOURCE "ORDEM"      OF oBar GROUP ACTION  FATX01_E()                                    TOOLTIP OemToAnsi("Visualiza Pedido...")
       //   DEFINE BUTTON oBtPs  RESOURCE "NOVACELULA" OF oBar GROUP ACTION  FATX01_F(1, "LPD")                            TOOLTIP OemToAnsi("Pesquisa...")
       //   DEFINE BUTTON oBtPl  RESOURCE "RELATORIO"  OF oBar GROUP ACTION  U_FATX01_P()                                  TOOLTIP OemToAnsi("Planilha Financeira..")
       //   DEFINE BUTTON oBtOk  RESOURCE "OK"         OF oBar GROUP ACTION  FATX01_2(nOpc)                                TOOLTIP OemToAnsi("Confirma...")
       //   DEFINE BUTTON oBtCa  RESOURCE "CANCEL"     OF oBar GROUP ACTION  oDlg:End()                                    TOOLTIP OemToAnsi("Sair...")
       //Else
       //   DEFINE BUTTON        RESOURCE "S4WB010N"   OF oBar       ACTION u_FATX01_h()                                     TOOLTIP OemToAnsi("Impressão...")
       //   DEFINE BUTTON oBtPs  RESOURCE "NOVACELULA" OF oBar GROUP ACTION FATX01_F(2, "TMP")                             TOOLTIP OemToAnsi("Pesquisa...")
       //   DEFINE BUTTON oBtCa  RESOURCE "CANCEL"     OF oBar GROUP ACTION DbSelectArea("TMP"), DbCloseArea(), oDlg:End() TOOLTIP OemToAnsi("Sair...")
       //Endif
       //oBar:bRClicked := {|| AllwaysTrue()}
Return Nil

/*************************************************************************************/
/*** FMONARQ - Montagem dos arquivos.                                              ***/
/*************************************************************************************/
User Function fMonArq(nOpc)
     Local cCond   := ""
     Local aCampos := {}
     //Local  Table
     //Local cAuxQry := ""
     Local cBaseQry, nY
     Local _cMVUFILCR := GETMV("MV_UFILCRE") //LGS#20200210 - Adequação de release 12.1.25 e posteriores
     
     aadd(aCampos, {"FLAG"    , "C",  2, 0 }) ; aadd(aCampos, {"PEDIDO"   , "C",  6, 0 }) //Flag(01)      ; Pedido(02)
     aadd(aCampos, {"EMISSAO" , "D",  8, 0 }) ; aadd(aCampos, {"CLIENTE"  , "C", 52, 0 }) //Emissão(03)   ; Cliente(04)
     aadd(aCampos, {"CONDICAO", "C", 40, 0 }) ; aadd(aCampos, {"VENDEDOR" , "C", 50, 0 }) //Condição(05)  ; Vendedor(06)
     aadd(aCampos, {"TIPOVEN" , "C",  1, 0 }) ; aadd(aCampos, {"TIPOPED"  , "C",  1, 0 }) //Tipo Vend.(07); Tipo Ped.(08)
     aadd(aCampos, {"TIPOCLI" , "C",  1, 0 }) ; aadd(aCampos, {"LUCRO"    , "N", 15, 4 }) //Tipo Cli.(09) ; Lucro(10)
     aadd(aCampos, {"COMISSAO", "N",  15, 4 }) ; aadd(aCampos, {"VLRCOMIS" , "N",  15, 4 }) //Comissão(11)  ; Vlr. Com.(12)
     aadd(aCampos, {"PRICOM"  , "D",  8, 0 }) ; aadd(aCampos, {"ULTCOM"   , "D",  8, 0 }) //1º Compra(13) ; Ult. Com.(14)
     aadd(aCampos, {"RISCOCLI", "C",  1, 0 }) ; aadd(aCampos, {"INCLUSAO" , "C", 15, 0 }) //Risco Cli.(15); Inclusao(16)
     aadd(aCampos, {"DATAINC" , "D",  8, 0 }) ; aadd(aCampos, {"ALTERACAO", "C", 15, 0 }) //Dt. Incl.(17) ; Alteracao(18)
     aadd(aCampos, {"DATAALT" , "D",  8, 0 }) ; aadd(aCampos, {"STATUS"   , "C",  1, 0 }) //Dt. Alt.(19)  ; Status(20)
     aadd(aCampos, {"VALTOT"  , "N", 14, 2 }) ; aadd(aCampos, {"LIBPED"   , "L",  1, 0 }) //Vlr. Tot.(21) ; Lib. Ped.(22)
     aadd(aCampos, {"USRPED"  , "C", 15, 0 }) ; aadd(aCampos, {"LIBCRE"   , "L",  1, 0 }) //Usr. Ped.(23) ; Lib. Cred.(24)
     aadd(aCampos, {"USRCRE"  , "C", 15, 0 }) ; aadd(aCampos, {"LIBDIR"   , "L",  1, 0 }) //Usr. Cred.(25); Lib. Dir.(26)
     aadd(aCampos, {"USRDIR"  , "C", 15, 0 }) ; aadd(aCampos, {"APROVA"   , "C",  1, 0 }) //Usr. Dir.(27) ; Flag Aprov.(28)
     aadd(aCampos, {"APROVAOR", "C",  1, 0 }) ; aadd(aCampos, {"USRAPR"   , "C", 15, 0 }) //Usr. Rec.(29) ; Flag Aprov.(30)
     aadd(aCampos, {"LIBCAD"  , "L",  1, 0 }) ; aadd(aCampos, {"USRCAD"   , "C", 15, 0 }) //Lib. Cad.(31) ; Usr. Cad.(32)
     aadd(aCampos, {"USRCADO" , "C", 15, 0 }) ; aadd(aCampos, {"USRPEDO"  , "C", 15, 0 })
     aadd(aCampos, {"USRCREO" , "C", 15, 0 }) ; aadd(aCampos, {"USRDIRO"  , "C", 15, 0 })
     aadd(aCampos, {"BOLETO"  , "C",  1, 0 }) ; aadd(aCampos, {"TRANSPORT", "C",  6, 0 })
     aadd(aCampos, {"CODCLI"  , "C",  6, 0 }) ; aadd(aCampos, {"NOMCLI"   , "C", 40, 0 }) //LGS#20190923 - CRIADO OS CAMPOS CODCLI E NOMCLI NA QUERY PARA ATENDIMENTO DE ATUALIZAÇÃO DE RELEASE 12.1.25
     aadd(aCampos, {"VALATR"  , "N", 20, 2 }) ; aadd(aCampos, {"TOTTIT"   , "N", 20, 2 })
     aadd(aCampos, {"TOTPAB"  , "N", 20, 2 })

/*//14/06/21
     cBaseQry := "SELECT  SC5.C5_NUM AS PEDIDO, SUBSTRING(SC5.C5_EMISSAO, 7, 2) + '/' + SUBSTRING(SC5.C5_EMISSAO, 5, 2) "+;
                         "+ '/' + SUBSTRING(SC5.C5_EMISSAO, 1, 4) AS EMISSAO, SC5.C5_CLIENTE + '/' + SC5.C5_LOJACLI + ' - ' + SA1.A1_NOME AS CLIENTE, "+;
                         "SC5.C5_CONDPAG + ' - ' + SE4.E4_DESCRI AS CONDICAO, SC5.C5_VEND1 + ' - ' + SA3.A3_NOME AS VENDEDOR, SC5.C5_TIPOVEN AS TIPOVEN, "+;
                         "SC5.C5_TIPO AS TIPOPED, SC5.C5_TIPOCLI AS TIPOCLI, SC5.C5_LUCRO AS LUCRO, SC5.C5_PORCOM AS COMISSAO, SC5.C5_VLRCOM AS VLRCOMIS, "+;
                         "SUBSTRING(SA1.A1_PRICOM, 7, 2) + '/' + SUBSTRING(SA1.A1_PRICOM, 5, 2) + '/' + SUBSTRING(SA1.A1_PRICOM, 1, 4) AS PRICOM, SUBSTRING(SA1.A1_ULTCOM, 7, "+;
                         "2) + '/' + SUBSTRING(SA1.A1_ULTCOM, 5, 2) + '/' + SUBSTRING(SA1.A1_ULTCOM, 1, 4) AS ULTCOM, SA1.A1_RISCO AS RISCOCLI, SC5.C5_CAD AS INCLUSAO, "+;
                         "SUBSTRING(SC5.C5_DTCAD, 7, 2) + '/' + SUBSTRING(SC5.C5_DTCAD, 5, 2) + '/' + SUBSTRING(SC5.C5_DTCAD, 1, 4) AS DATAINC, SC5.C5_ALT AS ALTERACAO, "+;
                         "SUBSTRING(SC5.C5_DTALT, 7, 2) + '/' + SUBSTRING(SC5.C5_DTALT, 5, 2) + '/' + SUBSTRING(SC5.C5_DTALT, 1, 4) AS DATAALT, 'P' AS STATUS, "+;
                         "SC5.C5_LIBPED AS LIBPED, SC5.C5_USRPED AS USRPED, SC5.C5_LIBCRE AS LIBCRE, SC5.C5_USRCRE AS USRCRE, SC5.C5_LIBDIR AS LIBDIR, "+;
                         "SC5.C5_USRDIR AS USRDIR, '  ' AS FLAG, 0 AS VALTOT, SC5.C5_APROVA AS APROVA, SC5.C5_USRAPR AS USRAPR, SC5.C5_LIBCAD AS LIBCAD, "+;
                         "SC5.C5_USRCAD AS USRCAD, SC5.C5_BOLETO AS BOLETO, SC5.C5_TRANSP AS TRANSPORT, "+;
                         "SC5.C5_CLIENTE AS CODCLI, SA1.A1_NOME AS NOMCLI, 0 AS VALATR, 0 AS TOTTIT, 0 AS TOTPAB "+;
                 "FROM "+RetSqlName("SC5")+" AS SC5 WITH (NOLOCK) "+;
                 "LEFT OUTER JOIN "+RetSqlName("SA1")+" AS SA1 WITH (NOLOCK) ON (A1_FILIAL = '"+xFilial("SA1")+"') AND (SC5.C5_CLIENTE = SA1.A1_COD) AND (SC5.C5_LOJACLI = SA1.A1_LOJA) AND (SA1.D_E_L_E_T_ = '') "+; 
                 "LEFT OUTER JOIN "+RetSqlName("SE4")+" AS SE4 WITH (NOLOCK) ON (E4_FILIAL = '"+xFilial("SE4")+"') AND (C5_CONDPAG = E4_CODIGO) AND SE4.D_E_L_E_T_ = '' "+;
                 "LEFT OUTER JOIN "+RetSqlName("SA3")+" AS SA3 WITH (NOLOCK) ON (A3_FILIAL = '"+xFilial("SA3")+"') AND (C5_VEND1 = SA3.A3_COD) AND (SA3.D_E_L_E_T_ = '') "+;
                 "WHERE (SC5.D_E_L_E_T_ = '') AND (C5_FILIAL = '"+xFilial("SC5")+"') AND (SC5.C5_EMISSAO >= '20040906') " +;
                 iif(nOpc != 2 .and. nOpc != 4, " AND (SC5.C5_APROVA = '0')","")
*/                 

     cBaseQry := "SELECT  SC5.C5_NUM AS PEDIDO, SUBSTRING(SC5.C5_EMISSAO, 7, 2) + '/' + SUBSTRING(SC5.C5_EMISSAO, 5, 2) "+;
                         "+ '/' + SUBSTRING(SC5.C5_EMISSAO, 1, 4) AS EMISSAO, SC5.C5_CLIENTE + '/' + SC5.C5_LOJACLI + ' - ' + SA1.A1_NOME AS CLIENTE, "+;
                         "SC5.C5_CONDPAG + ' - ' + SE4.E4_DESCRI AS CONDICAO, SC5.C5_VEND1 + ' - ' + SA3.A3_NOME AS VENDEDOR, SC5.C5_TIPOVEN AS TIPOVEN, "+;
                         "SC5.C5_TIPO AS TIPOPED, SC5.C5_TIPOCLI AS TIPOCLI, SC5.C5_LUCRO AS LUCRO, SC5.C5_COMIS1 AS COMISSAO, SC5.C5_VLRCOM AS VLRCOMIS, "+;
                         "SUBSTRING(SA1.A1_PRICOM, 7, 2) + '/' + SUBSTRING(SA1.A1_PRICOM, 5, 2) + '/' + SUBSTRING(SA1.A1_PRICOM, 1, 4) AS PRICOM, SUBSTRING(SA1.A1_ULTCOM, 7, "+;
                         "2) + '/' + SUBSTRING(SA1.A1_ULTCOM, 5, 2) + '/' + SUBSTRING(SA1.A1_ULTCOM, 1, 4) AS ULTCOM, SA1.A1_RISCO AS RISCOCLI, SC5.C5_CAD AS INCLUSAO, "+;
                         "SUBSTRING(SC5.C5_DTCAD, 7, 2) + '/' + SUBSTRING(SC5.C5_DTCAD, 5, 2) + '/' + SUBSTRING(SC5.C5_DTCAD, 1, 4) AS DATAINC, SC5.C5_ALT AS ALTERACAO, "+;
                         "SUBSTRING(SC5.C5_DTALT, 7, 2) + '/' + SUBSTRING(SC5.C5_DTALT, 5, 2) + '/' + SUBSTRING(SC5.C5_DTALT, 1, 4) AS DATAALT, 'P' AS STATUS, "+;
                         "SC5.C5_LIBPED AS LIBPED, SC5.C5_USRPED AS USRPED, SC5.C5_LIBCRE AS LIBCRE, SC5.C5_USRCRE AS USRCRE, SC5.C5_LIBDIR AS LIBDIR, "+;
                         "SC5.C5_USRDIR AS USRDIR, '  ' AS FLAG, 0 AS VALTOT, SC5.C5_APROVA AS APROVA, SC5.C5_USRAPR AS USRAPR, SC5.C5_LIBCAD AS LIBCAD, "+;
                         "SC5.C5_USRCAD AS USRCAD, SC5.C5_BOLETO AS BOLETO, SC5.C5_TRANSP AS TRANSPORT, "+;
                         "SC5.C5_CLIENTE AS CODCLI, SA1.A1_NOME AS NOMCLI, 0 AS VALATR, 0 AS TOTTIT, 0 AS TOTPAB "+;
                 "FROM "+RetSqlName("SC5")+" AS SC5 WITH (NOLOCK) "+;
                 "LEFT OUTER JOIN "+RetSqlName("SA1")+" AS SA1 WITH (NOLOCK) ON (A1_FILIAL = '"+xFilial("SA1")+"') AND (SC5.C5_CLIENTE = SA1.A1_COD) AND (SC5.C5_LOJACLI = SA1.A1_LOJA) AND (SA1.D_E_L_E_T_ = '') "+; 
                 "LEFT OUTER JOIN "+RetSqlName("SE4")+" AS SE4 WITH (NOLOCK) ON (E4_FILIAL = '"+xFilial("SE4")+"') AND (C5_CONDPAG = E4_CODIGO) AND SE4.D_E_L_E_T_ = '' "+;
                 "LEFT OUTER JOIN "+RetSqlName("SA3")+" AS SA3 WITH (NOLOCK) ON (A3_FILIAL = '"+xFilial("SA3")+"') AND (C5_VEND1 = SA3.A3_COD) AND (SA3.D_E_L_E_T_ = '') "+;
                 "WHERE (SC5.D_E_L_E_T_ = '') AND (C5_FILIAL = '"+xFilial("SC5")+"') AND (SC5.C5_EMISSAO >= '20040906') " +;
                 iif(nOpc != 2 .and. nOpc != 4, " AND (SC5.C5_APROVA = '0')","")

     //AND (SC5.C5_LIBCAD = 'F')
     //LGS#20190923 - CRIADO OS CAMPOS CODCLI E NOMCLI NA QUERY PARA ATENDIMENTO DE ATUALIZAÇÃO DE RELEASE 12.1.25
     cQry2 := cBaseQry
     cCond := ""
     If nOpc == 1
        If lAcsCad
           /*
           If !Empty(GETMV("MV_LSINFER"))
              cAuxQry := Upper(Alltrim(GETMV("MV_LSINFER")))
              nVez := 1
              While Len(cAuxQry) > 0
                    If nVez == 1
                       cAux2 := "('"
                       cAux2 += SubStr(cAuxQry, 1, Iif(At(".", cAuxQry)==0, Len(cAuxQry), At(".", cAuxQry)-1))+"','"
                       nVez += 1
                       cAuxQry := Alltrim(Stuff(cAuxQry, 1, Iif(At(".", cAuxQry)==0, Len(cAuxQry), At(".", cAuxQry)), ""))
                    Else
                       cAux2 += SubStr(cAuxQry, 1, Iif(At(".", cAuxQry)==0, Len(cAuxQry), At(".", cAuxQry)-1))+"','"
                       nVez += 1
                       cAuxQry := Alltrim(Stuff(cAuxQry, 1, Iif(At(".", cAuxQry)==0, Len(cAuxQry), At(".", cAuxQry)), ""))
                    Endif
              Enddo
              If !UPPER(GETMV("MV_LSINFER")) $ UPPER(cUsername)
                 cAuxQry := "  AND (Upper(C5_CAD) IN "+cAux2+Upper(Alltrim(cUsername))+"') "
              Else
                 cAuxQry := "  AND (Upper(C5_CAD) IN "+SubStr(cAux2, 1, Len(cAux2) - 2)+") "
              Endif
           Endif   
           cQry2 += "SELECT * "
           cQry2 += "FROM MAT_"+cEmpAnt+"010SINTEGRA WITH (NOLOCK) "
           cQry2 += "WHERE FILIAL = '"+xFilial("SC5")+"' "  
           */          
			cCond += "(((SC5.C5_CAD = '"+cUsername+"') "
           If Alltrim(UPPER(cUsername)) $ Alltrim(UPPER(GETMV("MV_LIBSINT")))
              cCond += "  OR (SUBSTRING(SC5.C5_CAD,1,1) IN('0','1','2','3','4','5','6','7','8','9'))"
           endif 
           cCond += ")"
           cCond += "AND (SC5.C5_LIBCAD = 'F')) "
        Endif
        If lAcsPed
           //SC5.C5_LIBCAD = 'T') AND (SC5.C5_LIBPED = 'F')
           if !empty(cCond)
           		cCond += " OR "
           endif 
           cCond += "((SC5.C5_LIBCAD = 'T') AND (SC5.C5_LIBPED = 'F'))"
           /*
           cQry2 += Iif(lAcsCad, " OR ", " ")
           cQry2 += "SELECT * "
           cQry2 += "FROM MAT_"+cEmpAnt+"011PEDIDOS WITH (NOLOCK) "
           cQry2 += "WHERE FILIAL = '"+xFilial("SC5")+"' "

           cQry2 += Iif(lAcsCad, " UNION ALL ", " ")
           cQry2 += "SELECT * "
           cQry2 += "FROM MAT_"+cEmpAnt+"011PEDIDOS WITH (NOLOCK) "
           cQry2 += "WHERE FILIAL = '"+xFilial("SC5")+"' "
           */
        Endif
        If lAcsCre
           if !empty(cCond)
           		cCond += " OR "
           endif 
           cCond += "((SC5.C5_LIBCAD = 'T') AND (SC5.C5_LIBCRE = 'F'))"
        Endif
        If lAcsDir
           if !empty(cCond)
           		cCond += " OR "
           endif 
           cCond += "((SC5.C5_LIBCAD = 'T') AND (SC5.C5_LIBDIR = 'F'))"
           /*
           cQry2 += Iif(lAcsPed .or. lAcsCre, " UNION ALL ", " ")
           cQry2 += "SELECT * "
           cQry2 += "FROM MAT_"+cEmpAnt+"013DIRETOR WITH (NOLOCK) "
           cQry2 += "WHERE FILIAL = '"+xFilial("SC5")+"' "    
           */
        Endif
        If lAcsOut
           if !empty(cCond)
           		cCond += " OR "
           endif 
           cCond += "((SC5.C5_LIBCAD = 'F') AND (A1_CGC LIKE '"+SubStr(SM0->M0_CGC, 1, 8)+"%'))"
           /*
           cQry2 += Iif(lAcsCad .or. lAcsPed .or. lAcsCre .or. lAcsDir, " UNION ALL ", " ")
           cQry2 += "SELECT MAT_"+cEmpAnt+"010SINTEGRA.* "
           cQry2 += "FROM MAT_"+cEmpAnt+"010SINTEGRA WITH (NOLOCK) "
           cQry2 += "LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON SA1.A1_FILIAL = '' AND SA1.A1_COD = SUBSTRING(CLIENTE, 1, 6) AND SA1.D_E_L_E_T_ = '' "
           cQry2 += "WHERE FILIAL = '"+xFilial("SC5")+"' "
           cQry2 += "  AND SUBSTRING(SA1.A1_CGC, 1, 8) = '"+SubStr(SM0->M0_CGC, 1, 8)+"' "
           */
        Endif
     ElseIf nOpc == 2 //Estorno
            If lAcsPed
	           	if !empty(cCond)
    	       		cCond += " OR "
        	   	endif 
           		cCond += "((SC5.C5_LIBPED = 'T')"
           		if (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) != 0)
           			cCond += " AND (SC5.C5_USRPED = '"+cUsername+"')"
           		endif 
           		cCond += ")"
           		/*
               cQry2 += "SELECT * "
               cQry2 += "FROM MAT_"+cEmpAnt+"021ESTPEDI WITH (NOLOCK) "
               cQry2 += "WHERE FILIAL = '"+xFilial("SC5")+"' "
               If !PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),cCodUsr) == 0
                  cQry2 += "  AND USRAPR = '"+cUsername+"' "
               Endif
               */
            Endif
            If lAcsCre
	           	if !empty(cCond)
    	       		cCond += " OR "
        	   	endif 
           		cCond += "((SC5.C5_LIBCRE = 'T')"
           		if (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) != 0)
           			cCond += " AND (SC5.C5_USRCRE = '"+cUsername+"')"
           		endif 
           		cCond += ")"
           		/*
               cQry2 += Iif(lAcsPed, " UNION ALL ", " ")
               cQry2 += "SELECT * "
               cQry2 += "FROM MAT_"+cEmpAnt+"022ESTCRED WITH (NOLOCK) "
               cQry2 += "WHERE FILIAL = '"+xFilial("SC5")+"' "
               If !PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),cCodUsr) == 0
                  cQry2 += "  AND USRAPR = '"+cUsername+"' "
               Endif
               */
            Endif
            If lAcsDir
	           	if !empty(cCond)
    	       		cCond += " OR "
        	   	endif 
           		cCond += "((SC5.C5_LIBDIR = 'T')"
           		if (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) != 0)
           			cCond += " AND (SC5.C5_USRDIR = '"+cUsername+"')"
           		endif 
           		cCond += ")"                     
           		/*
               cQry2 += Iif(lAcsPed .or. lAcsCre, " UNION ALL ", " ")
               cQry2 += "SELECT * "
               cQry2 += "FROM MAT_"+cEmpAnt+"023ESTDIRE WITH (NOLOCK) "
               cQry2 += "WHERE FILIAL = '"+xFilial("SC5")+"' "
               If !PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),cCodUsr) == 0
                  cQry2 += "  AND USRAPR = '"+cUsername+"' "
               Endif
               */
            Endif
           	if !empty(cCond)
   	      	cCond += " OR "
       	   endif 
			   cCond += "((SC5.C5_APROVA = '2')"
   			if (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) != 0)
           		cCond += " AND (SC5.C5_USRAPR = '"+cUsername+"')"
      		endif 
           	cCond += ")"  
           	
           	cCond := "("+cCond+") AND (C5_NUM = '"+SC5->C5_NUM+"')"
           	/*                   
            If !Empty(cQry2)
               cQry2 += " UNION ALL "
            Endif
            cQry2 += "SELECT * "
            cQry2 += "FROM MAT_"+cEmpAnt+"031REJEITA WITH (NOLOCK) "
            cQry2 += "WHERE FILIAL = '"+xFilial("SC5")+"' "
            If !PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),cCodUsr) == 0
               cQry2 += "  AND USRAPR = '"+cUsername+"' "
            Endif
            */
     ElseIf nOpc == 3  //Diretoria
           	if !empty(cCond)
   	      	cCond += " OR "
       	   endif 
			   cCond += "((SC5.C5_LIBCAD = 'T') AND (C5_LIBPED = 'T') AND (C5_LIBCRE = 'T') AND (SC5.C5_LIBDIR = 'F'))"
     ElseIf nOpc == 4   //Ped. Pendentes
            cCond += "((SC5.C5_LIBCAD = 'F') OR (C5_LIBPED = 'F') OR (C5_LIBCRE = 'F') OR (SC5.C5_LIBDIR = 'F') OR (SC5.C5_APROVA = '2'))"  
       		/*
            cQry2 += "SELECT * "
            cQry2 += "FROM MAT_"+cEmpAnt+"010SINTEGRA WITH (NOLOCK) "
            cQry2 += "WHERE FILIAL = '"+xFilial("SC5")+"' "
            cQry2 += "UNION ALL "
            cQry2 += "SELECT * "
            cQry2 += "FROM MAT_"+cEmpAnt+"011PEDIDOS WITH (NOLOCK) "
            cQry2 += "WHERE FILIAL = '"+xFilial("SC5")+"' "
            cQry2 += "UNION ALL "
            cQry2 += "SELECT * "
            cQry2 += "FROM MAT_"+cEmpAnt+"012CREDITO WITH (NOLOCK) "
            cQry2 += "WHERE FILIAL = '"+xFilial("SC5")+"' "
            cQry2 += "UNION ALL "
            cQry2 += "SELECT * "
            cQry2 += "FROM MAT_"+cEmpAnt+"013DIRETOR WITH (NOLOCK) "
            cQry2 += "WHERE FILIAL = '"+xFilial("SC5")+"' "
            cQry2 += "UNION ALL "
            cQry2 += "SELECT * "
            cQry2 += "FROM MAT_"+cEmpAnt+"031REJEITA WITH (NOLOCK) "
            cQry2 += "WHERE FILIAL = '"+xFilial("SC5")+"' "  
            */
     ElseIf nOpc == 5 //Vendas
     		   cCond += "((SC5.C5_LIBCAD = 'T') AND (C5_LIBPED = 'F'))"    
     		   /*
            cQry2 += "SELECT * "
            cQry2 += "FROM MAT_"+cEmpAnt+"011PEDIDOS WITH (NOLOCK) "
            cQry2 += "WHERE FILIAL = '"+xFilial("SC5")+"' "
            cQry2 += "ORDER BY PEDIDO " 
            */
     Endif       
     //LGS#20200114 - Ajustado a inclusão da variável cCond pois da forma que estava se a mesma fosse vazia estava ocorrendo problema nos parenteses.
     //cQry2 := cBaseQry + iif(!empty(cCond)," AND ","")+"("+cCond+") ORDER BY PEDIDO"
     cQry2 := cBaseQry + Iif( !Empty( cCond ), " AND ( " + cCond + " ) ", "" ) + " ORDER BY PEDIDO"

     TCQUERY cQry2 ALIAS "LPD1" NEW

     /********************************************************************************************************************************/
     /*** BLOCO ALTERADO EM 23/09/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
     If SELECT( "LPD" ) <> 0
        DbSelectArea("LPD")
        DbCloseArea()
		  If Type("oTempTable") == 'O'
		     oTempTable:Delete()
		  Endif
     Endif
     oTempTable := FWTemporaryTable():New( 'LPD' )
     oTemptable:SetFields( aCampos )
     oTempTable:AddIndex( "cInd01", { "PEDIDO" } )
     oTempTable:AddIndex( "cInd02", { "CODCLI" } )
     oTempTable:AddIndex( "cInd03", { "NOMCLI" } )
     oTempTable:Create()
     //cNomArq := CriaTrab(aCampos, .t.)
     //cNomArq := U_NovoArqTrab("dbf")
     //dbcreate(cNomArq+".dbf",aCampos,"DBFCDXADS")     
     //cKey01  := "PEDIDO"
     //cInd01  := SubStr(cNomArq, 1, 10)+"_1" //"SC"+SubStr(cNomArq, 8, 6)+"_1"
     //cKey02  := "SubStr(CLIENTE, 01, 06)"
     //cInd02  := SubStr(cNomArq, 1, 10)+"_2" //"SC"+SubStr(cNomArq, 8, 6)+"_2"
     //cKey03  := "SubStr(CLIENTE, 13, 40)"
     //cInd03  := SubStr(cNomArq, 1, 10)+"_3" //"SC"+SubStr(cNomArq, 8, 6)+"_3"
     //DbUseArea(.t., , cNomArq, "LPD", .t., .f.)     
     //if Select("LPD")<>0
     //   dbselectarea("LPD")
     //   dbclosearea()
     //endif
     //USE (cNomArq+".dbf") ALIAS LPD VIA "DBFCDXADS" NEW
     //DbCreateIndex(cInd01+".cdx", cKey01, {||cKey01} )
     //DbCreateIndex(cInd02+".cdx", cKey02, {||cKey02} )
     //DbCreateIndex(cInd03+".cdx", cKey03, {||cKey03} )            
     //DbClearIndex()
     //DbSetIndex(cInd01)
     //DbSetIndex(cInd02)
     //DbSetIndex(cInd03)
     /********************************************************************************************************************************/
     DbSelectArea("LPD")
     DbSetOrder(1)
     DbGoTop()
     
     aVerDup := {}
     DbSelectArea("LPD1")
     DbGoTop()
     While !Eof()
           If aScan(aVerDup, {|x| x[1] == LPD1->PEDIDO} ) == 0
              If nOpc == 1
                 //LGS#20200210 - Adequação de release 12.1.25 e posteriores
                 //If GETMV("MV_UFILCRE")
                 If _cMVUFILCR
                    If lAcsCre .and. !lAcsDir
                       If !cOpcUsr $ 'TODOSP'
                          cQry1 := ""
                          cQry1 += "SELECT 'ATRASO' = CASE "
                          cQry1 += "                  WHEN (SE1.E1_VENCREA < SE1.E1_BAIXA) "
                          cQry1 += "                       THEN CAST(CAST(SE1.E1_BAIXA AS DATETIME) AS INT) - CAST(CAST(SE1.E1_VENCREA AS DATETIME) AS INT) "
                          cQry1 += "                  WHEN (SE1.E1_SALDO > 0.0) AND (SE1.E1_VENCREA < (SELECT CAST(DATEPART(Year, GETDATE()) AS VARCHAR) + "
                          cQry1 += "                                                                  CASE WHEN LEN(DATEPART(Month, GETDATE())) = 1 THEN CAST('0' AS VARCHAR)+CAST(DATEPART(Month, GETDATE()) AS VARCHAR) ELSE CAST(DATEPART(Month, GETDATE()) AS VARCHAR) END + "
                          cQry1 += "                                                                  CASE WHEN LEN(DATEPART(Day, GETDATE())) = 1 THEN CAST('0' AS VARCHAR)+CAST(DATEPART(Day, GETDATE()) AS VARCHAR) ELSE CAST(DATEPART(Day, GETDATE()) AS VARCHAR) END )) THEN CAST(CAST((SELECT SUBSTRING(CONVERT(VARCHAR, GETDATE(), 105),7,4)+SUBSTRING(CONVERT(VARCHAR, GETDATE(), 105),4,2)+SUBSTRING(CONVERT(VARCHAR, GETDATE(), 105),1,2)) AS DATETIME) AS INT) - CAST(CAST(SE1.E1_VENCREA AS DATETIME) AS INT) "
                          cQry1 += "                  ELSE 0 "
                          cQry1 += "                  END "
                          cQry1 += "FROM "+RetSqlName("SE1")+" SE1 WITH (NOLOCK) "
                          cQry1 += "WHERE SE1.D_E_L_E_T_ = '' "
                          cQry1 += "  AND SE1.E1_CLIENTE = '"+SubStr(LPD1->CLIENTE, 1, 6)+"' "
                          cQry1 += "  AND SE1.E1_LOJA    = '"+SubStr(LPD1->CLIENTE, 8, 2)+"' "
                          cQry1 += "  AND SE1.E1_SALDO   > 0 "
                          TCQUERY cQry1 ALIAS "TIT" NEW
                          DbSelectArea("TIT")
                          nDiaAtr := 0
                          While !Eof()
                                nDiaAtr := TIT->ATRASO
                                DbSelectArea("TIT")
                                DbSkip()
                          Enddo
                          DbSelectArea("TIT")
                          DbCloseArea()
                          If cOpcUsr $ 'CATRAS'
                             If nDiaAtr > 0
                                DbSelectArea("LPD1")
                                DbSkip()
                                Loop
                             Endif
                          ElseIf cOpcUsr $ 'SATRAS'
                                 If nDiaAtr <= 0
                                    DbSelectArea("LPD1")
                                    DbSkip()
                                    Loop
                                 Endif
                          Endif
                       Endif
                    Endif
                 Endif
              Endif
              RecLock("LPD", .t.)
                 For nY := 1 To Len(aCampos)
                     If Alltrim(aCampos[nY][1]) $ 'LIBPED.LIBCRE.LIBDIR.LIBCAD'
                        FieldPut(nY, Iif(&('LPD1->'+aCampos[nY][1]) == 'T', .t., .f.) )
                     ElseIf Alltrim(aCampos[nY][1]) $ 'APROVAOR'
                            FieldPut(nY, LPD1->APROVA)
                     ElseIf Alltrim(aCampos[nY][1]) $ 'USRCADO'
                            FieldPut(nY, LPD1->USRCAD)
                     ElseIf Alltrim(aCampos[nY][1]) $ 'USRPEDO'
                            FieldPut(nY, LPD1->USRPED)
                     ElseIf Alltrim(aCampos[nY][1]) $ 'USRCREO'
                            FieldPut(nY, LPD1->USRCRE)
                     ElseIf Alltrim(aCampos[nY][1]) $ 'USRDIRO'
                            FieldPut(nY, LPD1->USRDIR)
                     ElseIf Alltrim(aCampos[nY][1]) $ 'EMISSAO.PRICOM.ULTCOM.DATAINC.DATAALT'
                            FieldPut(nY, CtoD(&('LPD1->'+aCampos[nY][1])) )
                     Else
                        FieldPut(nY, &('LPD1->'+aCampos[nY][1]) )
                     Endif
                 Next
              MsUnLock()
              aadd(aVerDup, {LPD1->PEDIDO})
           Endif
           DbSelectArea("LPD1")
           DbSkip()
     Enddo
     DbSelectArea("LPD1")
     DbCloseArea()
Return

/*****************************************************************************/
/*** FATX01_2 - Montagem do botão legenda na enchoicebar.                  ***/
/******************************************************************************
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Luís Gustavo  ³ FATX01_8 - Processa arq. grav. inform. alter.³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FATX01_2(nOpc)
       DbSelectArea("LPD")
       If RecCount() > 0
          If nOpc <> 4
             MsgRun("Processando arquivo...","Aguarde...", {||FATX01_8()} )
          Endif
          oDlg:End()
       Else
          MsgBox("Não existem registros para serem processados, utilize a opção Sair !!!", "Atenção...", "INFO")
          Return
       Endif
       DbSelectArea("SC5")
       DbGoTop()
Return Nil

/*****************************************************************************/
/*** FATX01_8 - Aprovação dos pedidos.                                     ***/
/******************************************************************************
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Luís Gustavo  ³ fPedLib - Cham. de fun. micr. Lib. Pedido.   ³±±
±±³          ³ Luís Gustavo  ³ fCreLib - Cham. de fun. micr. Lib. Cred./Est.³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FATX01_8()
       Local lSucesso,dAux,lLibAuto,cReg,nRegC5,lLDir,lLCad,lLPed,lLCre,_cUsrDir,cQry1,lCif, _lAutCre
       //Local lBloqueado
       Local cPedNLi := ""
       Local nDesc1,nDesc2,nDesc3,nDesc4             
       Local _cRegra := ""
       Local _cIncon := ""
       Local _ZPPAR0018 := GetMV( "ZP_PAR0018" )
       Local _ZPPAR0019 := GetMV( "ZP_PAR0019" )

       DbSelectArea("LPD")
       DbGoTop()
       If RecCount() > 0
          While !Eof()
                lLibAuto := .f. //Variável para informar se houve liberação automática da Diretoria
                _lAutCre := .f.
                lLCad    := .f. 
                lLPed    := .f. 
                lLCre    := .f. 
                lLDir    := .f.
                lSucesso := .t.
                lPed     := .f.
                DbSelectArea("SA1")
                DbSetOrder(1)
                DbSeek( xFilial("SA1") + SUBSTR( LPD->CLIENTE, 1, 6 ) + SUBSTR( LPD->CLIENTE, 8, 2 ) )
                DbSelectArea("SC5")
                DbSetOrder(1)
                DbSeek(xFilial("SC5")+LPD->PEDIDO,.t.)
                If Found()
                   cQry1 := "SELECT C5_USRDIR,C5_USRCAD,C5_USRPED,C5_USRCRE,C5_LIBCAD,C5_LIBPED,C5_LIBCRE,C5_LIBDIR "+;
                            "FROM "+RetSqlName("SC5")+" WHERE (D_E_L_E_T_ <> '*') AND (C5_FILIAL = '"+xFilial("SC5")+"' AND (C5_NUM = '"+LPD->PEDIDO+"'))"
                   TCQUERY cQry1 ALIAS "TMPSC5" NEW
                   DBSELECTAREA("TMPSC5")
                   If !eof() .and. !bof()
                      _cUsrDir := TMPSC5->C5_USRDIR //Usado para comparação posterior
                      lLCad := iif((lAcsCad .or. lAcsOut) .AND. (TMPSC5->C5_USRCAD <> LPD->USRCAD),LPD->LIBCAD,IIF(TMPSC5->C5_LIBCAD = "T",.T.,.F.))
                      lLPed := IIF((lAcsPed .or. lAcsOut) .AND. (TMPSC5->C5_USRPED <> LPD->USRPED),LPD->LIBPED,IIF(TMPSC5->C5_LIBPED = "T",.T.,.F.))
                      lLCre := IIF((lAcsCre .or. lAcsOut) .AND. (TMPSC5->C5_USRCRE <> LPD->USRCRE),LPD->LIBCRE,IIF(TMPSC5->C5_LIBCRE = "T",.T.,.F.))
                      lLDir := IIF((lAcsDir .or. lAcsOut) .AND. (TMPSC5->C5_USRDIR <> LPD->USRDIR),LPD->LIBDIR,IIF(TMPSC5->C5_LIBDIR = "T",.T.,.F.))
                   Else
                      _cUsrDir := SC5->C5_USRDIR //Usado para comparação posterior
                      lLCad := LPD->LIBCAD
                      lLPed := LPD->LIBPED
                      lLCre := LPD->LIBCRE
                      lLDir := LPD->LIBDIR
                   Endif
                   If (lAcsCad .or. lAcsOut) .AND. (TMPSC5->C5_USRCAD <> LPD->USRCAD)
                      DbSelectArea("SC5")
                      If !U_EstaBloqueado("SC5", RecNo()) //DBRLock(RecNo())
                         // Cleber (14/01/19) => Tentativa de evitar deadlock
                         DbSelectArea("SC5")
                         cReg := alltrim(str(RecNo())) 
                         cQuery = "UPDATE "+RetSqlName("SC5")+" SET C5_LIBCAD = '"+Iif(LPD->LIBCAD,'T','F')+"',C5_USRCAD = '"+Iif(LPD->LIBCAD, cUsername, " ")+"' WHERE R_E_C_N_O_ = "+cReg
                         TCSQLExec(cQuery)
                         /*RecLock("SC5", .f.)
                            SC5->C5_LIBCAD := Iif(LPD->LIBCAD,                     'T', 'F')
                            SC5->C5_USRCAD := Iif(LPD->LIBCAD, cUsername, " ")
                           MsUnLock()*/
                         lSucesso := .t.
                         DbSelectArea("ZZB")
                         RecLock("ZZB", .t.)
                            ZZB->ZZB_FILIAL := xFilial("ZZB")
                            ZZB->ZZB_PEDIDO := SC5->C5_NUM
                            ZZB->ZZB_IDLOG  := Iif(lAcsOut, 'VOU', 'LCA')
                            ZZB->ZZB_USRLOG := cUsername
                            ZZB->ZZB_DATLOG := dDataBase
                            ZZB->ZZB_HORLOG := Time()
                         MsUnLock()
                         Else
                            lSucesso := .f.
                            U_fMosAvs("Atenção", "O pedido: "+LPD->PEDIDO+" não foi liberado pelo cadastro, por estar travado por outro usuário."+chr(10)+char(13)+;
                                   "Tente novamente mais tarde.", {"Continua"}, 2)
                         Endif
                         /********************************************************************************************************************/
                         //** ANALISE DE CREDITO PARA LIBERAÇÃO AUTOMÁTICA - 
                         //** 1º) SEM TITULOS EM ATRASO
                         //** 2º) CONDIÇÃO DE PAGAMENTO DIFERENTE DE 001 (A VISTA)
                         //** 3º) SALDO DE TITULOS EM ABERTO (SE1) + SALDO ATUAL + PEDIDO ATUAL (VALORES COM IMPOSTOS) < = A1_LC  DO CLIENTE
                         //** 4º) PEDIDOS ATÉ R$ 100.000,00 (LIBERA CRÉDITO + LIBERA DIRETORIA) >= R$ 100.000,00 (LIBERA CRÉDITO)
                         /********************************************************************************************************************/
                         If _ZPPAR0018 //Habilita utilização da regra
                            If lSucesso
                               _cRegra := ""
                               _cRegra += "Pedido: " + LPD->PEDIDO + CHR(13) + CHR(10)
                               _cIncon := ""
                               If LPD->VALATR <= 0 //Regra 1 - Titulos em atraso
                                  _cRegra += "Valor atraso em R$ " + DTOC( dDataBase ) + ": " + Transform( LPD->VALATR, "@E 999,999,999.99" ) + " OK" + CHR(13) + CHR(10)
                                  If SubStr( LPD->CONDICAO, 1, 3 ) <> '001' //Regra 2 - Condição de pagamento a vista
                                     _cRegra += "Condição: " + Alltrim( LPD->CONDICAO ) + " OK" + CHR(13) + CHR(10)
                                     If ( LPD->TOTTIT + LPD->TOTPAB + LPD->VALTOT ) < SA1->A1_LC //Regra 3 - ( TITULOS EM ABERTO + SALDO ATUAL + PEDIDO ATUAL ) < LIMITE CREDITO
                                        _cRegra += "Titulos: R$ " + Alltrim( Transform( LPD->TOTTIT, "@E 999,999,999.99" ) ) + " + Ped. em Aberto: R$ " + Alltrim( Transform( LPD->TOTPAB, "@E 999,999,999.99" ) ) + " + Ped. Atual: R$ " + Alltrim( Transform( LPD->VALTOT, "@E 999,999,999.99" ) ) +;
                                                   " = " + Alltrim( Transform( ( LPD->TOTTIT + LPD->TOTPAB + LPD->VALTOT ), "@E 999,999,999.99" ) ) + " OK" + CHR(13) + CHR(10)
                                        _cRegra += "Limite de Crédito: R$ " + Alltrim( Transform( ( SA1->A1_LC ), "@E 999,999,999.99" ) ) + CHR(13) + CHR(10)
                                        If LPD->VALTOT <= _ZPPAR0019
                                           _cRegra += "Valor do Pedido: R$ " + Alltrim( Transform( ( LPD->VALTOT ), "@E 999,999,999.99" ) ) + " OK" + CHR(13) + CHR(10)
                                           _cRegra += "LIBERADO AUTOMATICO CREDITO E DIRETORIA"
                                           _lAutCre := .t. //Liberação do crédito
                                           lLibAuto := .t. //Liberação da diretoria
                                           lLCre    := .t. //Parâmetro para considerar liberação de crédito na liberação do pedido
                                        else
                                           _cRegra += "Valor do Pedido: R$ " + Alltrim( Transform( ( LPD->VALTOT ), "@E 999,999,999.99" ) ) + " OK" + CHR(13) + CHR(10)
                                           _cRegra += "LIBERADO AUTOMATICO CREDITO"
                                           _lAutCre := .t. //Liberação do crédito
                                           lLCre    := .t. //Parâmetro para considerar liberação de crédito na liberação do pedido
                                           lLDir    := .t. //Parâmetro para considerar liberação de diretoria na liberação do pedido
                                        Endif
                                     Else
                                        _cRegra += "Titulos: R$ " + Alltrim( Transform( LPD->TOTTIT, "@E 999,999,999.99" ) ) + " + Ped. em Aberto: R$ " + Alltrim( Transform( LPD->TOTPAB, "@E 999,999,999.99" ) ) + " + Ped. Atual: R$ " + Alltrim( Transform( LPD->VALTOT, "@E 999,999,999.99" ) ) +;
                                                   " = R$ " + Alltrim( Transform( ( LPD->TOTTIT + LPD->TOTPAB + LPD->VALTOT ), "@E 999,999,999.99" ) ) + " NÃO LIBERADO" + CHR(13) + CHR(10)
                                        _cRegra += "Limite de Crédito: R$ " + Alltrim( Transform( ( SA1->A1_LC ), "@E 999,999,999.99" ) ) + CHR(13) + CHR(10)
                                        _cIncon := "INCONSISTÊNCIA: LIMITE DE CRÉDITO"
                                     Endif
                                  else
                                     _cRegra += "Condição: " + Alltrim( LPD->CONDICAO ) + " NÃO LIBERADO"
                                     _cIncon := "INCONSISTÊNCIA: CONDIÇÃO DE PAGAMENTO A VISTA"
                                  Endif
                               else
                                  _cRegra += "Valor atraso em R$ " + DTOC( dDataBase ) + ": " + Transform( LPD->VALATR, "@E 999,999,999.99" ) + " NÃO LIBERADO" + CHR(13) + CHR(10)
                                  _cIncon := "INCONSISTÊNCIA: TITULOS EM ATRASO"
                               Endif
                               _cNomArq := xFilial("SC5") + '_' + LPD->PEDIDO + "_" + Iif( _lAutCre .and. lLibAuto, 'L', Iif( _lAutCre .and. !lLibAuto, 'C', 'B' ) ) + '_' + StrTran( Time(), ":", "" )
                               MEMOWRITE( "\dirdoc\comercial\libped\" + _cNomArq + '.log', _cRegra )
                               If !_lAutCre .or. !lLibAuto
                                  DbSelectArea("SC5")
                                  DbSetOrder(1)
                                  DbSeek(xFilial("SC5")+LPD->PEDIDO,.t.)
                                  _cObsAtu := MSMM( SC5->C5_OBSSC5 )
                                  If !( 'AGUARDANDO LIBERAÇÃO' $ _cObsAtu )
                                    _cObsAtu += Iif( Empty(_cObsAtu), '', CHR(13) + CHR(10) )
                                    _cObsAtu += Iif( Empty(_cObsAtu), '', CHR(13) + CHR(10) )
                                    _cObsAtu += 'AGUARDANDO LIBERAÇÃO'
                                    MSMM( SC5->C5_OBSSC5,      , , _cObsAtu   , 1, , , "SC5", 'C5_OBSSC5' )
                                  Endif
                                  If !Empty( Alltrim( _cIncon ) )
                                     _cObsLib := DTOC(dDataBase) + '-' + Time() + ': ' + _cIncon
                                     _cObsLib += Iif( Empty( Alltrim( MSMM( SC5->C5_OBSPED ) ) ), '', CHR(13) + CHR(10) + Alltrim( MSMM( SC5->C5_OBSPED ) ) )
                                     MSMM( SC5->C5_OBSPED,      , , _cObsLib   , 1, , , "SC5", 'C5_OBSPED' )
                                  Endif
                               Endif
                               If _lAutCre
                                  dbselectarea("LPD")
                                  RecLock("LPD",.f.)
                                     LPD->LIBCRE := .t.
                                     LPD->USRCRE := "Administrador"
                                  MsUnLock()
                               Endif
                            Endif
                         Endif
                         /********************************************************************************************************************/
                      Endif
                      If (lAcsPed .or. lAcsOut) .AND. (TMPSC5->C5_USRPED <> LPD->USRPED)
                         DbSelectArea("SC5")
                         If !U_EstaBloqueado("SC5", RecNo()) //DBRLock(RecNo())
                            If LPD->LIBPED
                               MsgRun("Liberando pedido "+LPD->PEDIDO, "Aguarde...", {|| lPed := U_fPedLib() } ) //MsgRun("Liberando pedido "+LPD->PEDIDO, "Aguarde...", {|| lPed := .t. } )  
                               lPed  := .t.
                               lLPed := .t.
                            Endif
                            If lPed
                               DbSelectArea("SC5")
                               DbSetOrder(1)
                               DbSeek(xFilial("SC5")+LPD->PEDIDO,.t.)
                               If Found()
                                  // Cleber (14/01/19) => Tentativa de evitar deadlock
                                  DbSelectArea("SC5")
                                  cReg := alltrim(str(RecNo())) 
                                  cQuery = "UPDATE "+RetSqlName("SC5")+" SET C5_LIBPED = '"+Iif(LPD->LIBPED,'T', 'F')+"',C5_USRPED = '"+Iif(LPD->LIBPED, cUsername, " ")+"' WHERE R_E_C_N_O_ = "+cReg
                                  TCSQLExec(cQuery)
                                  /*RecLock("SC5",.f.)
                                     SC5->C5_LIBPED := Iif(LPD->LIBPED,                     'T', 'F')
                                     SC5->C5_USRPED := Iif(LPD->LIBPED, cUsername, " ")
                                  MsUnLock()*/
                                  lSucesso := .t.
                                  RecLock("ZZB", .t.)
                                     ZZB->ZZB_FILIAL := xFilial("ZZB")
                                     ZZB->ZZB_PEDIDO := SC5->C5_NUM
                                     ZZB->ZZB_IDLOG  := Iif(lAcsOut, 'POU', 'LVE')
                                     ZZB->ZZB_USRLOG := cUsername
                                     ZZB->ZZB_DATLOG := dDataBase
                                     ZZB->ZZB_HORLOG := Time()
                                  MsUnLock()
                               Endif
                            Else
                               lSucesso := .f.
                            Endif
                         Else
                            lSucesso := .f.
                            U_fMosAvs("Atenção", "O pedido: "+LPD->PEDIDO+" não foi liberado por vendas, por estar travado por outro usuário."+chr(10)+char(13)+;
                                   "Tente novamente mais tarde.", {"Continua"}, 2)
                         Endif
                      Endif
                      If (lAcsCre .or. lAcsOut .or. _lAutCre) .AND. (TMPSC5->C5_USRCRE <> LPD->USRCRE)
                         DbSelectArea("SC5")
                         If !U_EstaBloqueado("SC5", RecNo()) //DBRLock(RecNo())
                            dbselectarea("SC5")
                            nRegC5 := RecNo()
                            cReg := alltrim(str(nRegC5)) 
                            
                            //LGS#20200625 - Ajuste na gravação da liberação de crédito caso seja referente a regra de aprovação automática
                            If _lAutCre
                               cQuery := "UPDATE "+RetSqlName("SC5")+" SET C5_LIBCRE = 'T',C5_USRCRE = 'Administrador' "
                            Else
                               cQuery := "UPDATE "+RetSqlName("SC5")+" SET C5_LIBCRE = '"+Iif(LPD->LIBCRE,'T', 'F')+"',C5_USRCRE = '"+Iif(LPD->LIBCRE, cUsername, " ")+"' "
                            Endif
                            //(04/08/2017)Chamado 007850 => Kelly pediu para liberar automaticamente pedidos abaixo de R$ 50 mil com lucratividade maior ou igual a 6%
                            IF LPD->LIBCRE .AND. !(TMPSC5->C5_LIBDIR == "T") .AND. (SC5->C5_VLRDUP < 50000) .AND. (SC5->C5_LUCRO >= 6.0)
                               cQuery += ", C5_LIBDIR = 'T', C5_USRDIR = 'Administrador' "
                               lLibAuto := .t.
                               lLDir := .t.
                               _cUsrDir := 'Administrador'
                            ENDIF
                            cQuery += "WHERE R_E_C_N_O_ = "+cReg
                            TCSQLExec(cQuery)
                            dbselectarea("SC5")
                            /*RecLock("SC5",.f.)
                               SC5->C5_LIBCRE := Iif(LPD->LIBCRE,'T', 'F')
                               SC5->C5_USRCRE := Iif(LPD->LIBCRE, cUsername, " ") 
                               //(04/08/2017)Chamado 007850 => Kelly pediu para liberar automaticamente pedidos abaixo de R$ 50 mil com lucratividade maior ou igual a 6%
                               IF LPD->LIBCRE .AND. !(SC5->C5_LIBDIR == "T") .AND. (SC5->C5_VLRDUP < 50000) .AND. (SC5->C5_LUCRO >= 6.0)
                                  SC5->C5_LIBDIR := "T"
                                  SC5->C5_USRDIR := "Administrador"   
                                  lLibAuto := .t.
                               ENDIF
                            MsUnLock()*/
                            lSucesso := .t.
                            DbSelectArea("ZZB")
                            RecLock("ZZB", .t.)
                               ZZB->ZZB_FILIAL := xFilial("ZZB")
                               ZZB->ZZB_PEDIDO := SC5->C5_NUM
                               ZZB->ZZB_IDLOG  := Iif(lAcsOut, 'COU', 'LCR')
                               ZZB->ZZB_USRLOG := Iif(_lAutCre, 'Admistrador', cUsername )
                               ZZB->ZZB_DATLOG := dDataBase
                               ZZB->ZZB_HORLOG := Time()
                            MsUnLock()       
                            If lLibAuto
                               dbselectarea("LPD")
                               RecLock("LPD",.f.)
                                  LPD->LIBDIR := .t.
                                  LPD->USRDIR := "Administrador"
                               MsUnLock()
                            Endif
                         Else
                            lSucesso := .f.
                            U_fMosAvs("Atenção", "O pedido: "+LPD->PEDIDO+" não foi liberado pelo crédito, por estar bloqueado por outro usuário."+chr(10)+char(13)+;
                                      "Tente novamente mais tarde.", {"Continua"}, 2)
                         Endif
                      Endif
                      DBSELECTAREA("TMPSC5")
                      DBCLOSEAREA()

                      If (lAcsDir .or. lAcsOut .or. lLibAuto) .AND. (_cUsrDir <> LPD->USRDIR)
                         DbSelectArea("SC5")
                         If !U_EstaBloqueado("SC5", RecNo()) //DBRLock(RecNo())
                            RecLock("SC5",.f.)                  
                               If !lLibAuto //Informações já salvas anteriormente 
                                  lLDir := LPD->LIBDIR
                                  SC5->C5_LIBDIR := Iif(LPD->LIBDIR,'T', 'F')
                                  SC5->C5_USRDIR := Iif(LPD->LIBDIR, cUsername, " ")
                               Endif
//                               If QtdComp(Round(SC5->C5_PORCOM, 3)) <> QtdComp(Round(LPD->COMISSAO, 3)) //14/06/21
                               If QtdComp(Round(SC5->C5_COMIS1, 3)) <> QtdComp(Round(LPD->COMISSAO, 3))
                                  SC5->C5_COMIS1:= LPD->COMISSAO
                                  SC5->C5_VLRCOM := LPD->VLRCOMIS
                                  SC5->C5_LUCRO  := LPD->LUCRO
                               Endif
                               dbselectarea("SC5")
                            MsUnLock()
                            If !lAcsOut
                               U_EnviaRec("SC5", SC5->C5_NUM, .f.,SC5->C5_VEND1)
                            Endif
                            lSucesso := .t.
                            DbSelectArea("ZZB")
                            RecLock("ZZB", .t.)
                               ZZB->ZZB_FILIAL := xFilial("ZZB")
                               ZZB->ZZB_PEDIDO := SC5->C5_NUM
                               ZZB->ZZB_IDLOG  := Iif(lAcsOut, 'DOU', 'LDI')
                               ZZB->ZZB_USRLOG := iif(!lLibAuto,cUsername,"Administrador")
                               ZZB->ZZB_DATLOG := dDataBase
                               ZZB->ZZB_HORLOG := Time()
                            MsUnLock()
                         Else
                            lSucesso := .f.
                            U_fMosAvs("Atenção", "O pedido: "+LPD->PEDIDO+" não foi liberado, por estar travado por outro usuário."+chr(10)+char(13)+;
                                   "Tente novamente mais tarde.", {"Continua"}, 2)
                         Endif
                      Endif
                      /***********************************************************************************************/
                      //If LPD->LIBCAD .and. LPD->LIBPED .and. LPD->LIBCRE .and. (LPD->LIBDIR .OR. lLibAuto) .and. (LPD->APROVA <> '2')  
                      If lLCad .and. lLPed .and. lLCre .and. lLDir .and. (LPD->APROVA <> '2')  
                         DbSelectArea("SC5")
                         If U_EstaBloqueado("SC5", RecNo()) //DBRLock(RecNo())
                            lSucesso := .f.
                         Else
                            lPed := .t.
                            //MsgRun("Liberando pedido "+LPD->PEDIDO, "Aguarde...", {|| lPed := fPedLib() } )
                            //MsgRun("Liberando credito / estoque do pedido "+LPD->PEDIDO, "Aguarde...", {|| lCre := fCreLib() } )
                            fCreLib()
                            lCif := .f.
                            //Se for frete CIF, somar frete nos itens
                            Begin Transaction
                                  IF (SC5->C5_TPFRETE = "C") .AND. (SC5->C5_XVLRFRE > 0.0) .AND. (SC5->C5_TIPO = "N") 
                                     lCif := .t.
                                  ENDIF
                                  //Determinar data de entrega
                                  IF !EMPTY(SC5->C5_PEDPROG)                                                                  
                                     dAux := SC5->C5_PEDPROG
                                  ELSE
                                     dAux := U_ProxDiaUtil(dDataBase,SC5->C5_ENTREGA)
                                  ENDIF
                                  RecLock("SC5",.f.)
                                     SC5->C5_APROVA := '1'
                                     SC5->C5_USRAPR := iif(lCif,"#*#CIF#*#",cUserName) //(Cleber, 16/01/14) LPD->USRAPR
                                     SC5->C5_DTAPR := dDataBase //(Cleber, 27/04/16) -> Data de Aprovação do Pedido
                                     SC5->C5_SUGENT := dAux
                                     SC5->C5_X_EXPO := " "
                                     if lCif // Se for CIF, zerar descontos antes de alterar valores dos itens para evitar problemas de se colocar valor de tabela descontado
                                        nDesc1 := SC5->C5_DESCON1
                                        nDesc2 := SC5->C5_DESCON2
                                        nDesc3 := SC5->C5_DESCON3
                                        nDesc4 := SC5->C5_DESCON4
                                        SC5->C5_DESCON1 := 0
                                        SC5->C5_DESCON2 := 0
                                        SC5->C5_DESCON3 := 0
                                        SC5->C5_DESCON4 := 0
                                     Endif
                                  MsUnLock()
                                  U_EnviaRec("SC5", SC5->C5_NUM, .f.,SC5->C5_VEND1)
                                  lSucesso := .t.
                                  DbSelectArea("ZZB")
                                  RecLock("ZZB", .t.)
                                     ZZB->ZZB_FILIAL := xFilial("ZZB")
                                     ZZB->ZZB_PEDIDO := SC5->C5_NUM
                                     ZZB->ZZB_IDLOG  := Iif(lAcsOut, 'AOU', 'APR')
                                     ZZB->ZZB_USRLOG := cUsername
                                     ZZB->ZZB_DATLOG := dDataBase
                                     ZZB->ZZB_HORLOG := Time()
                                  MsUnLock()
                                  If lCif
                                     lSucesso := XSomaCIF(SC5->C5_NUM)
                                     IF lSucesso
                                        lSucesso := U_LiberaPed(SC5->C5_NUM)
                                     Endif
                                     dbselectarea("SC5")
                                     RecLock("SC5",.f.)
                                        SC5->C5_USRAPR := cUserName
                                        SC5->C5_DESCON1 := nDesc1
                                        SC5->C5_DESCON2 := nDesc2
                                        SC5->C5_DESCON3 := nDesc3
                                        SC5->C5_DESCON4 := nDesc4
                                     MsUnLock()
                                  Endif
                        		end transaction
                         		IF !lSucesso
                         			U_fMosAvs("Atenção", "O pedido: "+LPD->PEDIDO+" teve problemas ao tentar AGREGAR O FRETE CIF!!!."+chr(10)+char(13)+;
                         			"Contate o Administrador do SISTEMA!", {"Continua"}, 2)
                         		ENDIF 
                         	
						Endif
                   	ElseIf LPD->APROVA == '2'
	 					DbSelectArea("SC5")
	      				lSucesso := !U_EstaBloqueado("SC5", RecNo()) 
    	      			If lSucesso
              				RecLock("SC5",.f.)
                         	SC5->C5_APROVA := '2'
                         	SC5->C5_USRAPR := cUserName //(Cleber, 16/01/14) LPD->USRAPR
                  			SC5->C5_X_EXPO := " "
                  			SC5->C5_X_SIM3G := "N"
                  			SC5->C5_ALTERAD := "S"
              				MsUnLock()
                  			U_EnviaRec("SC5", SC5->C5_NUM, .f.,SC5->C5_VEND1)
                     		lSucesso := .t.
		                   	DbSelectArea("ZZB")
                      		RecLock("ZZB", .t.)
                                ZZB->ZZB_FILIAL := xFilial("ZZB")
                                ZZB->ZZB_PEDIDO := SC5->C5_NUM
                                ZZB->ZZB_IDLOG  := 'REC'
                                ZZB->ZZB_USRLOG := cUsername
                                ZZB->ZZB_DATLOG := dDataBase
                                ZZB->ZZB_HORLOG := Time()
                             MsUnLock()
                            lSucesso := AlteraPed(SC5->C5_NUM) //Alterar pedido pra eliminar aprovações e SC9
                      	Endif
                   	ElseIf (LPD->APROVAOR == '2') .AND. (LPD->APROVAOR <> LPD->APROVA)
	                   	  DbSelectArea("SC5")
    	                  If !U_EstaBloqueado("SC5", RecNo()) //DBRLock(RecNo())
//                          If RLock()
  //                           UnLock
                             RecLock("SC5",.f.)
                                SC5->C5_APROVA := "0"
                                SC5->C5_USRAPR := ""
                                SC5->C5_SUGENT := SC5->C5_PEDPROG
                                SC5->C5_X_EXPO := " "
                                
                             MsUnLock()
                             lSucesso := .t.
		                   	  DbSelectArea("ZZB")
                             RecLock("ZZB", .t.)
                                ZZB->ZZB_FILIAL := xFilial("ZZB")
                                ZZB->ZZB_PEDIDO := SC5->C5_NUM
                                ZZB->ZZB_IDLOG  := 'ERE'
                                ZZB->ZZB_USRLOG := cUsername
                                ZZB->ZZB_DATLOG := dDataBase
                                ZZB->ZZB_HORLOG := Time()
                             MsUnLock()
                          Else
                             lSucesso := .f.
                          Endif
                   	Else
                      //If RLock()
                      //   UnLock
                      //   RecLock("SC5",.f.)
                      //      SC5->C5_APROVA := '0'
                      //      SC5->C5_USRAPR := LPD->USRAPR
                      //   MsUnLock()
                      //   U_EnviaRec("SC5", SC5->C5_NUM, .f.)
                      //   lSucesso := .t.
                      //   RecLock("ZZB", .t.)
                      //      ZZB->ZZB_FILIAL := xFilial("ZZB")
                      //      ZZB->ZZB_PEDIDO := SC5->C5_NUM
                      //      ZZB->ZZB_IDLOG  := 'SAP'
                      //      ZZB->ZZB_USRLOG := cUsername
                      //      ZZB->ZZB_DATLOG := dDataBase
                      //      ZZB->ZZB_HORLOG := Time()
                      //   MsUnLock()
                      //Else
                      //   lSucesso := .f.
                      //Endif
                   	Endif
                   	If !lSucesso
                      	cPedNLi += LPD->PEDIDO+' / '
                   	else 
						// Cleber (17/10/07) => Tentativa de disparar trigger p/ atualizar o C9_APROVA
						cQuery = "UPDATE "+RetSqlName("SC5")+" SET C5_APROVA = C5_APROVA WHERE (D_E_L_E_T_ <> '*') AND (C5_FILIAL = '"+xFilial("SC5")+"') AND (C5_NUM = '"+LPD->PEDIDO+"')"
	   					TCSQLExec(cQuery)
	   							
                   	Endif
		Endif //Fim If Found()
		DbSelectArea("LPD")
  		DbSkip()
	Enddo
 	MsUnLockAll()
  	If !Empty(cPedNLi)
   		MsgBox("Pedidos não processados: "+Chr(13)+Chr(10)+cPedNLi+"!", "Atenção...", "STOP")
	Endif
Else
	MsgBox("Não existem registros para serem mostrados !", "Atenção...", "STOP")
 	Return
Endif
Return


/*****************************************************************************/
/*** FCRELIB - Chamada de função microsiga passando parâm. para liberação. ***/
/*****************************************************************************/
Static Function fCreLib()
       LOCAL cQuery
       //Local cAlias := "SC9"
       //Local lEnd   := .f.
       //Local lHelp  := .T.
       Local lRet   := .t.

       //Pergunte("LIBAT2", .f.)
       //MV_PAR01 := LPD->PEDIDO                // Do pedido
       //MV_PAR02 := LPD->PEDIDO                // Ate pedido
       //MV_PAR03 := SubStr(LPD->CLIENTE, 1, 6) // Do Cliente
       //MV_PAR04 := SubStr(LPD->CLIENTE, 1, 6) // Ate Cliente
       //MV_PAR05 := CTOD('  /  /  ')           // Da Data Entrega
       //MV_PAR06 := CTOD('31/12/10')           // Ate Data Entrega
       //MV_PAR07 := 1                          // Quanto ao Estoque? - Blq.Estoque/WMS # Bloqueio WMS
       //DbSelectArea("SC5")
       //DbSelectArea("SC6")
       
		 // Cleber (04/10/07) => Tentativa de melhorar performance
       cQuery := "UPDATE "+RetSqlName("SC9")+" SET C9_LIBPOR = '"+cUsername+"',C9_DTLCRED = convert(varchar,getdate(),112) "+;
                 "WHERE (D_E_L_E_T_ <> '*') AND (C9_FILIAL = '"+xFilial("SC9")+"') AND (C9_PEDIDO = '"+LPD->PEDIDO+"')"
       nErro := TCSQLExec(cQuery)		
       If nErro < 0
          MsgBox("Erro ao atualizar data de Lib. Crédito !", "Atenção...", "STOP")			
       Endif 

       /*DbSelectArea("SC9")
       DbSetOrder(1)
       DbSeek(xFilial("SC9")+LPD->PEDIDO,.t.)
       If Found()
          While !Eof() .and. SC9->C9_FILIAL = xFilial("SC9") .and. SC9->C9_PEDIDO = LPD->PEDIDO
                //a450Grava(1, .T., .T., @lHelp)
                RecLock("SC9", .f.)
                   SC9->C9_LIBPOR  := cUsername
                   SC9->C9_DTLCRED := dDataBase
                MsUnLock()
                DbSelectArea("SC9")
                DbSkip()
          Enddo
          */          
          //cQry1 := ""
          //cQry1 += "SELECT * "
          //cQry1 += "FROM "+RetSqlName("SC9")+" SC9 WITH (NOLOCK) "
          //cQry1 += "WHERE SC9.C9_FILIAL  = '"+xFilial("SC9")+"' "
          //cQry1 += "  AND SC9.D_E_L_E_T_ = '' "
          //cQry1 += "  AND SC9.C9_PEDIDO  = '"+LPD->PEDIDO+"' "
          //cQry1 += "  AND SC9.C9_BLEST   <> '' "
          //cQry1 += "  AND SC9.C9_BLCRED  <> '' "
          //TCQuery cQry1 ALIAS "TSC9" NEW
          //DbSelectArea("TSC9")
          //If !Bof() .and. !Eof()
          //   lRet := .f.
          //Else
          //   lRet := .t.
          //Endif
          //DbSelectArea("TSC9")
          //DbCloseArea()       
       //Endif
Return(lRet)

/*************************************************************************************/
/*** FATX01_3 - Mostra os titulos em aberto do cliente.                            ***/
/*************************************************************************************/
Static Function FATX01_3(aCliente)
       Local aParam   := {}
       Local aAlias   := {}
       Local cxArea   := "FC010QRY01"
       //Local aGet     := {"","","",""}
       Private nCasas := GetMv("MV_CENT")

       DbSelectArea("LPD")
       If RecCount() > 0
          If Pergunte("FIC010",.t.)
             aadd(aParam, MV_PAR01) ; aadd(aParam, MV_PAR02) ; aadd(aParam, MV_PAR03)
             aadd(aParam, MV_PAR04) ; aadd(aParam, MV_PAR05) ; aadd(aParam, MV_PAR06)
             aadd(aParam, MV_PAR07) ; aadd(aParam, MV_PAR08) ; aadd(aParam, MV_PAR09)
             aadd(aParam, MV_PAR10) ; aadd(aParam, MV_PAR11) ; aadd(aParam, MV_PAR12)
             aadd(aParam, MV_PAR13) ; aadd(aParam, MV_PAR14) ; aadd(aParam, MV_PAR15)
             aadd(aParam, MV_PAR16) ; aadd(aParam, MV_PAR17)
             DbSelectArea("SA1")
             DbSetOrder(1)
             DbSeek(xFilial(aCliente[1])+aCliente[2],.t.)
             If Found()
                //Fc010Brow(1, @aAlias, aParam,.T.)
                U_FINFUN_01(1, @aAlias, aParam, .t., Nil, Nil, lAcsCre)
                DbSelectArea(cxArea)
                DbCloseArea()
             Endif
          Endif
       Else
          MsgBox("Não existem registros para serem mostrados !", "Atenção...", "STOP")
          Return
       Endif
Return(.t.)

/*************************************************************************************/
/*** FATX01_4 - Mostra os titulos recebidos do cliente.                            ***/
/*************************************************************************************/
Static Function FATX01_4(aCliente)
       Local aParam   := {}
       Local aAlias   := {}
       Local cxArea   := "FC010QRY02"
       //Local aGet     := {"","","",""}
       Private nCasas := GetMv("MV_CENT")
       DbSelectArea("LPD")
       If RecCount() > 0
          If Pergunte("FIC010",.t.)
             aadd(aParam, MV_PAR01) ; aadd(aParam, MV_PAR02) ; aadd(aParam, MV_PAR03)
             aadd(aParam, MV_PAR04) ; aadd(aParam, MV_PAR05) ; aadd(aParam, MV_PAR06)
             aadd(aParam, MV_PAR07) ; aadd(aParam, MV_PAR08) ; aadd(aParam, MV_PAR09)
             aadd(aParam, MV_PAR10) ; aadd(aParam, MV_PAR11) ; aadd(aParam, MV_PAR12)
             aadd(aParam, MV_PAR13) ; aadd(aParam, MV_PAR14) ; aadd(aParam, MV_PAR15)
             aadd(aParam, MV_PAR16) ; aadd(aParam, MV_PAR17)
             DbSelectArea("SA1")
             DbSetOrder(1)
             DbSeek(xFilial(aCliente[1])+aCliente[2],.t.)
             If Found()
                U_FINFUN_01(2, @aAlias, aParam, .t., Nil, Nil, lAcsCre)
                //Fc010Brow(2, @aAlias, aParam,.T.,aGet)   // 23/02/15 parou de funcionar apos atualização rpo
                DbSelectArea(cxArea)
                DbCloseArea()
             Endif
          Endif
       Else
          MsgBox("Não existem registros para serem mostrados !", "Atenção...", "STOP")
          Return
       Endif
Return(.t.)

/*************************************************************************************/
/*** FATX01_5 - Mostra os itens do pedido do cliente.                              ***/
/*************************************************************************************/
Static Function FATX01_5(aItmPed)
       Local oDlg2, oIPD
       Local aHeaderIPD := {}
       DbSelectArea("LPD")
       If RecCount() > 0
          aadd(aHeaderIPD,"Produto") ; aadd(aHeaderIPD,"Descrição")   ; aadd(aHeaderIPD,"UM")
          aadd(aHeaderIPD,"Qtde.")   ; aadd(aHeaderIPD,"Preço Unit.") ; aadd(aHeaderIPD,"Total Produto")
          aadd(aHeaderIPD,"IPI")     ; aadd(aHeaderIPD,"Subst. Trib."); aadd(aHeaderIPD,"TOTAL DO ITEM")
          DEFINE MSDIALOG oDlg2 FROM 000,000 TO 011,089 TITLE OemToAnsi("Itens do Pedido") OF oMainWnd
                 @ 013,003 LISTBOX oIPD FIELDS TITLE "Itens do Pedido"  SIZE 346,065 PIXEL OF oDlg2 
                 oIPD:aHeaders := aHeaderIPD
                 oIPD:SetArray(aItmPed)
                 oIPD:bLine    := {|| oIPD:aArray[oIPD:nAt] }
          ACTIVATE MSDIALOG oDlg2 CENTERED ON INIT EnchoiceBar(oDlg2, {||oDlg2:End()}, {||oDlg2:End()} )
       Else
          MsgBox("Não existem registros para serem mostrados !", "Atenção...", "STOP")
          Return
       Endif
Return

/*************************************************************************************/
/*** FATX01_6 - Mostra os dados cadastrais do cliente.                             ***/
/*************************************************************************************/
Static Function FATX01_6(aCliente)
       Local nOpcE          := 4 //2
       Local cArea    		:= alias()
       Local aAreaAnt 		:= U_PegaArea({"SA1","SC5","SYP"})
       Local _ni
       Local _nModAtu      := nModulo
       Private lVirtual     := .F.
       Private aAltEnChoice := {}
       Private aCpoEnChoice := {}
       Private aTELA        := Array(0,0)
       Private aGets        := Array(0)
       Private bCampo       := {|nCPO|Field(nCPO)}
       nModulo := _nModAtu
       DbSelectArea("LPD")
       If RecCount() > 0
          RegToMemory(aCliente[1],.F.)
         
          DbSelectArea(aCliente[1])
          DbSetOrder(1)
          DbSeek(xFilial(aCliente[1])+aCliente[2],.t.)
          If Found()
             nReg := Recno()
          Else
             nReg := 1
          Endif 
          For _ni := 1 to Fcount()
              aadd(aCpoEnchoice, {EVAL(bCampo, _ni)})
          Next
          oDlg3 := MSDialog():New(200,200,620,980,'Dados de Clientes',,,,,CLR_BLACK,CLR_WHITE,,,.T.)
          //DEFINE MSDIALOG oDlg3 FROM 000,000 TO 020,089 TITLE OemToAnsi("Dados do Cliente") OF oMainWnd
                 EnChoice(aCliente[1],nReg,nOpcE,,,,,{26,1,180,347})
          ACTIVATE MSDIALOG oDlg3 CENTERED ON INIT EnchoiceBar(oDlg3, {||oDlg3:End()}, {||oDlg3:End()} )
       Else
          MsgBox("Não existem registros para serem mostrados !", "Atenção...", "STOP")
          Return
       Endif
       _nModAtu := nModulo
       U_VoltaArea(aAreaAnt)
	   
	   If !empty(cArea)
 		  DbSelectArea(cArea)
 	   Endif 

       /*** ATUALIZAÇÃO DAS OBSERVAÇÕES ***/  
       fBusObs(@oObsMsg, @cObsMsg, @oObsSC5, @cObsSC5)

Return

/*************************************************************************************/
/*** FATX01_7 - Observação no pedido.                                              ***/
/*************************************************************************************/
Static Function FATX01_7()
       Local nOpcB   := 0
       Local cObsPed := CRIAVAR("ZT_LOG")
       DbSelectArea("LPD")
       If RecCount() > 0
          DEFINE MSDIALOG oDlg1 TITLE OemToAnsi("Observação no Pedido") FROM 000,000 TO 010,049 OF oMainWnd
                 @ 015,002 GROUP oGrp1 TO 074,191 LABEL  OemToAnsi('Observação')           PIXEL OF oDlg1
                 @ 020,005 GET cObsPed  MEMO             SIZE 183,047 OBJECT oObsPed
                 oDlg1:nStyle       := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
          ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1, {|| oDlg1:End(), nOpcB := 1 }, {|| oDlg1:End(), nOpcB := 0 } ) CENTERED
          If nOpcB == 1
             cAuxObs := cObsMsg
             cObsMsg := Alltrim(cUsername)+" ("+dToc(dDataBase)+" "+Time()+"):"+Chr(13)+chr(10)
             cObsMsg += Upper(cObsPed)+Chr(13)+chr(10)+Chr(13)+chr(10)
             cObsMsg += cAuxObs
             oObsMsg:Refresh()
             DbSelectArea("SC5")
             DbSetOrder(1)
             DbSeek(xFilial("SC5")+LPD->PEDIDO,.t.)
             If Found()
                MSMM(SC5->C5_OBSPED, , , cObsMsg, 1, , , "SC5", "C5_OBSPED")
             Endif
          Endif
       Else
          MsgBox("Não existem registros para serem mostrados !", "Atenção...", "STOP")
          Return
       Endif
Return(.t.)

/*************************************************************************************/
/*** FATX01_A - Condição de Pagamento.                                             ***/
/*************************************************************************************/
Static Function FATX01_A()
       Local aCond := {}
       Local cCND  := ""
       Local aRet  := Condicao( (nVlrMer+nVlrIpi), SubStr(LPD->CONDICAO,1,3), 0.00, dDataBase, 0.00)
       Local nX
       DbSelectArea("LPD")
       If RecCount() > 0
          For nX := 1 To Len(aRet)
              aadd(aCond, { StrZero(nX,2)+'º', aRet[nX][1], Transform(Iif(nX == 1, (aRet[nX][2]+nVlrSTb), aRet[nX][2]), "@E 999,999,999.99") })
          Next
          DEFINE MSDIALOG oDlg1 TITLE OemToAnsi("Condição de Pagamento") FROM 000,000 TO 010,042 OF oMainWnd
                 @ 015,003 LISTBOX oCND VAR cCND FIELDS HEADER OemToAnsi("Parcela"), OemToAnsi("Vencimento"), OemToAnsi("Valor") SIZE 160,058 PIXEL OF oDlg1
                 bCNDLine := { || { aCond[oCND:nAt,1], aCond[oCND:nAt,2], aCond[oCND:nAt,3] } }
                 oCND:SetArray( aCond )
                 oCND:bLine   := bCNDLine
                 oCND:GoTop()
          ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1, {|| oDlg1:End(), nOpcB := 1 }, {|| oDlg1:End(), nOpcB := 0 } ) CENTERED
       Else
          MsgBox("Não existem registros para serem mostrados !", "Atenção...", "STOP")
          Return
       Endif
Return(.t.)

/*************************************************************************************/
/*** FATX01_B - Legenda.                                                           ***/
/*************************************************************************************/
User Function FATX01_B(nPos, aPedi)
       BrwLegenda(OemToAnsi("Legenda"), "Status", { { "DISABLE"  , "Analise de Cadastro"     } ,;
                                                    { "BR_CINZA" , "Analise de Vendas"       } ,;
                                                    { "BR_PINK"  , "Analise de Crédito"      } ,;
                                                    { "BR_AZUL"  , "Analise da Diretoria"    } ,;
                                                    { "BR_MARROM", "Aprovado e não faturado" } ,;
                                                    { "ENABLE"   , "Aprovado e faturado"     } ,;
                                                    { "BR_PRETO" , "Recusado"                } })
Return

/*****************************************************************************/
/*** FATX01_C - Mostra pedidos a liberar.                                  ***/
/******************************************************************************
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Luís Gustavo  ³ FATX01_D - Impressão de pedidos a aprovar.   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function FATX01_C()
     Local aCamBrw := {}
     Local aCampos := {}
     Local cQry2   := ""   
     Local cUf,nAliqSol, nY
     
     aadd(aCampos, {"TEMP"   , "C",  2, 0 }) ; aadd(aCampos, {"FILIAL"  , "C",  2, 0 }) //Temp(01)      ; FILIAL(02)
     aadd(aCampos, {"CLIENTE", "C", 45, 0 }) ; aadd(aCampos, {"PEDIDO"  , "C",  6, 0 }) //Cliente(03)   ; Pedido(04)
     aadd(aCampos, {"EMISSAO", "D",  8, 0 }) ; aadd(aCampos, {"VLRMERC" , "N", 10, 2 }) //Emissão(05)   ; Vlr. Merc.(06)
     aadd(aCampos, {"VLRTOT" , "N", 10, 2 }) ; aadd(aCampos, {"VENDEDOR", "C", 45, 0 }) //Vlr. Total(07); Vendedor (08)
     
     /********************************************************************************************************************************/
     /*** BLOCO ALTERADO EM 11/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
     //cNomArq := U_NovoArqTrab("dbf")
     //CriaTrab(aCampos)
     //dbcreate(cNomArq+".dbf",aCampos,"DBFCDXADS")     

     //cKey01  := "PEDIDO"
     //cInd01  := SubStr(cNomArq, 1, 10)+"_1" //"SC"+SubStr(cNomArq, 8, 6)+"_1"
     //cKey02  := "SubStr(CLIENTE, 01, 06)"
     //cInd02  := SubStr(cNomArq, 1, 10)+"_2" //"SC"+SubStr(cNomArq, 8, 6)+"_2"
     //cKey03  := "SubStr(CLIENTE, 13, 40)"
     //cInd03  := SubStr(cNomArq, 1, 10)+"_3" //"SC"+SubStr(cNomArq, 8, 6)+"_3"
     //cKey04  := "SubStr(VENDEDOR, 10, 35)"
     //cInd04  := SubStr(cNomArq, 1, 10)+"_4" //"SC"+SubStr(cNomArq, 8, 6)+"_4"
     //DbUseArea(.t., , cNomArq, "TMP", .t., .f.)
     if Select("TMP")<>0
        dbselectarea("TMP")
        dbclosearea()
        If Type("oTempTbl01") == "O"
           oTempTbl01:Delete()
        Endif
     endif
     //USE (cNomArq+".dbf") ALIAS TMP VIA "DBFCDXADS" NEW
     //DbCreateIndex(cInd01+".cdx", cKey01, {||cKey01} )
     //DbCreateIndex(cInd02+".cdx", cKey02, {||cKey02} )
     //DbCreateIndex(cInd03+".cdx", cKey03, {||cKey03} )
     //DbCreateIndex(cInd04+".cdx", cKey04, {||cKey04} )
     //DbClearIndex()
     //DbSetIndex(cInd01)
     //DbSetIndex(cInd02)
     //DbSetIndex(cInd03)
     //DbSetIndex(cInd04)
     oTempTbl01 := FWTemporaryTable():New( "TMP" )
     oTempTbl01:SetFields( aCampos )
     oTempTbl01:AddIndex( "cInd01", { "PEDIDO" } )
     oTempTbl01:AddIndex( "cInd02", { "SubStr(CLIENTE, 01, 06)" } )
     oTempTbl01:AddIndex( "cInd03", { "SubStr(CLIENTE, 13, 40)" } )
     oTempTbl01:AddIndex( "cInd04", { "VENDEDOR" } )
     oTempTbl01:Create()
     /********************************************************************************************************************************/
     DbSelectArea("TMP")
     DbSetOrder(1)
     If lAcsCad
        cQry2 += "SELECT * "
        cQry2 += "FROM MAT_"+cEmpAnt+"010SINTEGRA "
        cQry2 += "WHERE FILIAL = '"+xFilial("SC5")+"' "
        cQry2 += "  AND (INCLUSAO = '"+cUsername+"' "
        If Alltrim(UPPER(cUsername)) $ Alltrim(UPPER(GETMV("MV_LIBSINT")))
           cQry2 += "  OR LEN(RTRIM(INCLUSAO)) = 6 )"
        Else
           cQry2 += ")"
        Endif
     Endif
     If lAcsPed
        cQry2 += Iif(!Empty(cQry2), " UNION ALL ", " ")
        cQry2 += "SELECT * "
        cQry2 += "FROM MAT_"+cEmpAnt+"011PEDIDOS "
        cQry2 += "WHERE FILIAL = '"+xFilial("SC5")+"' "
     Endif
     If lAcsCre
        cQry2 += Iif(!Empty(cQry2), " UNION ALL ", " ")
        cQry2 += "SELECT * "
        cQry2 += "FROM MAT_"+cEmpAnt+"012CREDITO "
        cQry2 += "WHERE FILIAL = '"+xFilial("SC5")+"' "
     Endif
     If lAcsDir
        cQry2 += Iif(!Empty(cQry2), " UNION ALL ", " ")
        cQry2 += "SELECT * "
        cQry2 += "FROM MAT_"+cEmpAnt+"013DIRETOR "
        cQry2 += "WHERE FILIAL = '"+xFilial("SC5")+"' "
     Endif
     //cQry2 += "UNION ALL "
     //cQry2 += "SELECT * "
     //cQry2 += "FROM MAT_"+cEmpAnt+"031REJEITA "
     //cQry2 += "WHERE FILIAL = '"+xFilial("SC5")+"' "
     cQry2 += "ORDER BY VENDEDOR, PEDIDO "

     TCQUERY cQry2 ALIAS "LPD1" NEW
     aVerDup := {}
     DbSelectArea("LPD1")
     DbGoTop()
     While !Eof()
           If aScan(aVerDup, {|x| x[1] == LPD1->PEDIDO} ) == 0
              RecLock("TMP", .t.)
                 For nY := 1 To Len(aCampos)
                    If Alltrim(aCampos[nY][1]) $ 'TEMP'
                       FieldPut(nY, '  ')
                     ElseIf Alltrim(aCampos[nY][1]) $ 'EMISSAO'
                            FieldPut(nY, CtoD(&('LPD1->'+aCampos[nY][1])) )
                     ElseIf Alltrim(aCampos[nY][1]) $ 'CLIENTE.VENDEDOR.PEDIDO'
                            FieldPut(nY, &('LPD1->'+aCampos[nY][1]) )
                     ElseIf Alltrim(aCampos[nY][1]) $ 'VLRMERC.VLRTOT'
                            cQry3 := ""
                            cQry3 += "SELECT * "
                            cQry3 += "FROM SC6"+cEmpAnt+"0 SC6 WITH (NOLOCK) "
                            cQry3 += "WHERE SC6.C6_FILIAL = '"+LPD1->FILIAL+"' "
                            cQry3 += "  AND SC6.D_E_L_E_T_ = '' "
                            cQry3 += "  AND SC6.C6_NUM    = '"+LPD1->PEDIDO+"' "
       
                            TCQUERY cQry3 ALIAS "ITM1" NEW
                            DbSelectArea("ITM1")
                            DbGoTop()
                            nVlrMer    := 0
                            nVlrIPI    := 0
                            nVlrTOT    := 0
                            nAuxIPI    := 0
                            nBaseIcms  := 0
                            nAuxIcms   := 0
                            nLucroST   := 0
                            nBaseSubst := 0
                            nDescZFR   := 0
                            cUf 	   := Iif(LPD1->TIPOPED $ "D_B", Posicione("SA2", 1, xFilial("SA2")+SubStr(LPD1->CLIENTE,1,6)+SubStr(LPD1->CLIENTE,8,2),"A2_EST"), Posicione("SA1", 1, xFilial("SA1")+SubStr(LPD1->CLIENTE,1,6)+SubStr(LPD1->CLIENTE,8,2),"A1_EST"))
                            nAliqInt   := U_Aliqinterna(cUf) //Val( Substr( cAux, At( cUf,cAux)+2,2))/100
                            nPerIcm    := AliqIcms(LPD1->TIPOPED,'S',LPD1->TIPOCLI)/100 // Alíquota  de ICMS
                            cEstCli    := Iif(LPD1->TIPOCLI $ "D_B", Posicione("SA2", 1, xFilial("SA2")+SubStr(LPD1->CLIENTE,1,6)+SubStr(LPD1->CLIENTE,8,2),"A2_EST"), Posicione("SA1", 1, xFilial("SA1")+SubStr(LPD1->CLIENTE,1,6)+SubStr(LPD1->CLIENTE,8,2),"A1_EST"))
                            cClaCli    := Iif(LPD1->TIPOCLI $ "D_B", Posicione("SA2", 1, xFilial("SA2")+SubStr(LPD1->CLIENTE,1,6)+SubStr(LPD1->CLIENTE,8,2),"A2_CLAS"), Posicione("SA1", 1, xFilial("SA1")+SubStr(LPD1->CLIENTE,1,6)+SubStr(LPD1->CLIENTE,8,2),"A1_CLAS"))
                            nPercSubst := If( Posicione("SZ8", 1, xFilial("SZ8")+cEstCli+cClaCli,"Z8_PERC") > 0, Posicione("SZ8", 1, xFilial("SZ8")+cEstCli+cClaCli,"Z8_PERC"), 0)
                            nVlrSTb    := 0
                            nVlrLcr    := 0
                            nPerLcr    := 0
                            DbSelectArea("ITM1")
                            While !Eof()
                                  nVlrMer += ITM1->C6_VALOR
                                  nAuxIpi := 0
                                  If Posicione("SF4", 1, xFilial("SF4")+ITM1->C6_TES, "F4_IPI") == 'S'
                                     nAuxIPI   := ITM1->C6_VALOR * (Posicione("SB1", 1, xFilial("SB1")+ITM1->C6_PRODUTO, "B1_IPI") / 100)
                                     nVlrIPI += nAuxIPI
                                  Else
                                     nAuxIPI   := 0
                                  Endif
                                  If Posicione("SF4", 1, xFilial("SF4")+ITM1->C6_TES, "F4_INCSOL") == 'S'
				 						nAliqSol := nAliqInt + iif((cUf = "RJ") .AND. (SF4->F4_ISEFECP <> '1'),0.01,0) // Consid. 1% fundo pobreza RJ
                                  	
                                     nBaseIcms  := ITM1->C6_VALOR + Iif( Posicione("SF4", 1, xFilial("SF4")+ITM1->C6_TES, "F4_INCIDE") == "S", nAuxIPI, 0)
                                     nAuxIcms   := nBaseIcms * nPerIcm
                                     nLucroST   := (1+(nPercSubst/100))
                                     nBaseSubst := (ITM1->C6_VALOR + nAuxIPI) * nLucroST*IIF(SF4->F4_BSICMST > 0,SF4->F4_BSICMST/100,1)
                                     nVlrSTb    += (nBaseSubst * nAliqSol) - nAuxIcms
                                  Else
                                     nBaseIcms  := ITM1->C6_VALOR + Iif( Posicione("SF4", 1, xFilial("SF4")+ITM1->C6_TES, "F4_INCIDE") == "S", nAuxIPI, 0)
                                     nAuxIcms   := nBaseIcms * nPerIcm
                                     nBaseSubst := (ITM1->C6_VALOR + nAuxIPI) * nLucroST*IIF(SF4->F4_BSICMST > 0,SF4->F4_BSICMST/100,1)
                                     nLucroST   := (1+(nPercSubst/100))
                                     nBaseSubst := 0
                                  Endif
                                  DbSelectArea("ITM1")
                                  DbSkip()
                            Enddo
                            DbSelectArea("ITM1")
                            DbCloseArea()
                            DbSelectArea("LPD1")
                            DbSelectArea("TMP")
                            If !(LPD1->TIPOPED $ "D_B") .and. (Posicione("SA1", 1, xFilial("SA1")+SubStr(LPD1->CLIENTE,1,6)+SubStr(LPD1->CLIENTE,8,2),"A1_CALCSUF") != "N") .and. !Empty(Posicione("SA1", 1, xFilial("SA1")+SubStr(LPD1->CLIENTE,1,6)+SubStr(LPD1->CLIENTE,8,2),"A1_SUFRAMA"))
                               nDescZFR := nVlrMer * 0.07
                            Endif
                            nVlrMer := nVlrMer - nDescZFR
                            nVlrTot := nVlrMer + nVlrIPI + nVlrSTb - nDescZFR
                            If Alltrim(aCampos[nY][1]) $ 'VLRMERC'
                               FieldPut(nY, nVlrMer )
                            ElseIf Alltrim(aCampos[nY][1]) $ 'VLRTOT'
                                   FieldPut(nY, nVlrTot )
                            Endif
                     Endif
                 Next
              MsUnLock()
              aadd(aVerDup, {LPD1->PEDIDO})
           Endif
           DbSelectArea("LPD1")
           DbSkip()
     Enddo
     DbSelectArea("LPD1")
     DbCloseArea()

     DbSelectArea("TMP")
     DbGoTop()
     aadd(aCamBrw, {"CLIENTE" , "", OemToAnsi("Cliente")    , "@!"            } )
     aadd(aCamBrw, {"PEDIDO"  , "", OemToAnsi("Pedido")     , "999999"        } )
     aadd(aCamBrw, {"EMISSAO" , "", OemToAnsi("Emissão")    , ""              } )
     aadd(aCamBrw, {"VLRMERC" , "", OemToAnsi("Valor Merc."), "@E 999,999.99" } )
     aadd(aCamBrw, {"VLRTOT"  , "", OemToAnsi("Valor Total"), "@E 999,999.99" } )
     aadd(aCamBrw, {"VENDEDOR", "", OemToAnsi("Vendedor")   , "@!"            } )

     DEFINE MSDIALOG oDlg FROM 000,000 TO 032,100 TITLE OemToAnsi("Aprovação de Pedidos" ) OF oMainWnd
            oTMP := MSSelect():New("TMP", "TEMP", Nil, aCamBrw, .f., Nil, {015,001,240,394}, , , oDlg)
            oDlg:nStyle    := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
     ACTIVATE MSDIALOG oDlg CENTERED VALID .T. ON INIT ( fAprPed(2, oDlg, {|| DbSelectArea("TMP"), DbCloseArea(), oTempTbl01:Delete(), oDlg:End() }, {|| DbSelectArea("TMP"), DbCloseArea(), oTempTbl01:Delete(), oDlg:End() } ), oDlg:lEscClose := .t. )
Return

/*****************************************************************************/
/*** FATX01_D - Impressão de relatório de pedidos a liberar.               ***/
/******************************************************************************
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Luís Gustavo  ³ fImpReg - Impressão de pedidos a aprovar.    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function FATX01_D()
       Local cDesc1        := "Este programa ira emitir a relação de pedidos a serem liberados."
       Local cDesc2        := "."
       Local cDesc3        := "."
       //Local cPict         := ""
       Local titulo        := "Relatório de Pedidos a Liberar"
       Local nLin          := 80
       //                      0         1         2         3         4         5         6         7         8         9         10        11        12        13
       //                      0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
       //                      999999/99 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999999  99/99/99  999,999.99  999,999.99  999999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
       //Local Cabec1       := "CLIENTE                                        PEDIDO  EMISSAO   VLR. MERC.  VLR.TOTAL   REPRESENTANTE"
       //Local Cabec2       := ""   
       //Local imprime       := .T.
       Local aOrd          := {}

       Private lEnd        := .F.
       Private lAbortPrint := .F.
       //Private CbTxt       := ""
       Private limite      := 132
       Private tamanho     := "M"
       Private nomeprog    := "FATX01_D"
       Private nTipo       := 15
       Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
       Private nLastKey    := 0
       Private cPerg       := "FATX01"
       Private cbtxt       := Space(10)
       Private cbcont      := 00
       Private CONTFL      := 01
       Private m_pag       := 01
       Private wnrel       := "FATX01_D"
       Private cString       := "SC9"

       //Pergunte(cPerg, .f.)
       wnrel := SetPrint(cString, NomeProg,      , @titulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho,,.F.)
       //wnrel := SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho,,.F.)

       If nLastKey == 27
          Return
       Endif

       SetDefault(aReturn, cString)

       If nLastKey == 27
          Return
       Endif
       nTipo := If(aReturn[4] == 1, 15, 18)
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Inicio do Processamento do Relatorio                         ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

       RptStatus({|| fImpReg(cCabec1, cCabec2, Titulo, nLin) }, Titulo)
       
Return

/*****************************************************************************/
/*** FIMPREG - Impressão de relatório de pedidos a liberar.                ***/
/*****************************************************************************/
Static Function fImpReg(Cabec1, Cabec2, Titulo, nLin)
       //Local nOrdem
       
       DbSelectArea("TMP")
       DbGoTop()
       SetRegua(Reccount())
       While !EoF()
             If lAbortPrint
                @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
                Exit
             Endif
       
             If nlin >= 68
                Cabec(titulo, Cabec1, Cabec2, nomeprog, tamanho, nTipo)
                nLin  := 8
                cVend := Space(20)
             Endif
             
             @ nLin, 000 PSAY TMP->CLIENTE  Picture "@!"
             @ nLin, 047 PSAY TMP->PEDIDO   Picture "999999"
             @ nLin, 055 PSAY TMP->EMISSAO
             @ nLin, 065 PSAY TMP->VLRMERC  Picture "@E 999,999.99"
             @ nLin, 077 PSAY TMP->VLRTOT   Picture "@E 999,999.99"
             @ nLin, 089 PSAY TMP->VENDEDOR Picture "@!"
             nLin += 1
             
             DbSelectArea("TMP")
             Dbskip()
       Enddo
       Roda(cbcont,cbtxt,tamanho)

       Set Device To Screen

       If aReturn[5] == 1
          Set Printer TO
          DbCommitAll()
          OurSpool(wnrel)
       Endif
       MS_FLUSH()
       
       DbSelectArea("TMP")
       DbGoTop()
Return

/*****************************************************************************/
/*** FATX01_E - Consulta do pedido.                                        ***/
/*****************************************************************************/
Static Function FATX01_E()
       DbSelectArea("LPD")
       If RecCount() > 0
          DbSelectArea("SC5")
          DbSetOrder(1)
          DbSeek(xFilial("SC5")+LPD->PEDIDO,.t.)
          If Found()
             A410Visual("SC5", RecNo(), 2)
          Endif
       Endif
Return Nil

/*****************************************************************************/
/*** FATX01_F - Pesquisa pedido.                                           ***/
/*****************************************************************************/
Static Function FATX01_F(nOpcBar, cAlias)
       Local oDlgPes, oCbxPes, cOrdPes, oBigGet
       Local nSavReg
       Local oScroll
       Local lSeek      := .f.
       //Local nMax       := 1
       Local nOrdPes    := 1
       //Local aLista     := {}
       //Local nChave     := 1
       Local cCampo     := Space(40)
       //Local lDetail    := .f.
       Local lUseDetail := .f.
       //Local aAllLista  := {}
       //Local oDetail
       Local nI
       Private aOrdPes  := {}
       
       DbSelectArea(cAlias)
       nSavReg    := RecNo()
       nOrdPes    := 1
       nMaiorStr  := 0
       lUseDetail := .t.
       aadd(aOrdPes, "Pedido")
       aadd(aOrdPes, "Código do Cliente")
       aadd(aOrdPes, "Nome do Cliente")
       If nOpcBar == 2
          aadd(aOrdPes, "Nome do Vendedor")
       Endif
       cOrdPes := aOrdPes[1]
       cCampo  := SPACE(40)
       For nI := 1 To Len(aOrdPes)
           aOrdPes[nI] := OemToAnsi(aOrdPes[nI])
       Next
       If IndexOrd() >= Len(aOrdPes)
          cOrdPes := aOrdPes[Len(aOrdPes)]
          nOrdPes := Len(aOrdPes)
       ElseIf IndexOrd() <= 1
              cOrdPes := aOrdPes[1]
              nOrdPes := 1
       Else
          cOrdPes := aOrdPes[IndexOrd()]
          nOrdPes := IndexOrd()
       EndIf
       DEFINE MSDIALOG oDlgPes FROM 00,00 TO 100,490 TITLE OemToAnsi("Pesquisa") PIXEL
              @ 005, 005 COMBOBOX oCbxPes VAR cOrdPes ITEMS aOrdPes SIZE 206,36 PIXEL OF oDlgPes
              @ 022, 005 MSGET oBigGet VAR cCampo SIZE 206,10 PIXEL
              @ 022, 005 SCROLLBOX oScroll VERTICAL SIZE 84,205 OF oDlgPes BORDER
              oScroll:Hide()
              oCbxPes:bChange := {|| nOrdPes := oCbxPes:nAt}
              
              DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlgPes ENABLE ACTION (lSeek := .T., oDlgPes:End())
              DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlgPes ENABLE ACTION oDlgPes:End()

       ACTIVATE MSDIALOG oDlgPes CENTERED
       If ( lSeek )
          cCampo := Trim(cCampo)
          nReg := Recno()
          SET SOFTSEEK ON
          DbSetOrder(nOrdPes)
          DbSeek(cCampo)
          If Eof()
             DbGoTo(nReg)
             Help(" ",1,"PESQ01")
          EndIf
          If nOpcBar == 1
             fAltPed(@oTipVen, @nTpVen, @oVlrMer, @nVlrMer, @oVlrIPI, @nVlrIPI, @oVlrSTb, @nVlrSTb, @oVlrTot, @nVlrTot, @aItmPed, @oVlrLcr, @nVlrLcr, @oPerLcr, @nPerLcr, @oVlrCom, @nVlrCom, @oPerCom, @nPerCom, @oPriCom, @cPriCom, @oUltCom, @cUltCom, @oRisco, @cRisco, @aCliente, @oLibPed, @lLibPed, @oUsrPed, @cUsrPed, @oAltPed, @cAltPed, @oRestri, @cRestri, @oObsMsg, @cObsMsg, @oLibRec, @lLibRec, @oObsSC5, @cObsSC5, @oLibCad, @lLibCad)
          Endif
          SET SOFTSEEK OFF
          lRefresh := .t.
       EndIf
Return Nil

/*****************************************************************************/
/*** FATX01_G - Ativa tecla F12                                            ***/
/*****************************************************************************/
// - DESABILITADO POIS NÃO ESTA EM USO 13/02/2020 - LUIS GUSTAVO
/*
Static Function FATX01_G()
       Local lCont    := .t.
       cOpcUsr := Iif(mvpar01 == 1, 'TODOSP', Iif(mvpar01 == 2, 'CATRAS', 'SATRAS'))
       
       //LGS#20200210 - Adequação de release 12.1.25 e posteriores
       //PutSX1("FATX01", "01", "Separa Pedidos", " ", " ", "mv_ch1", "N", 1, 0, 1, "C", " ", " ", " ", " ", "mv_par01", "Todos", " ", " ", " ", "C/ Atraso", " ", " ", "S/ Atraso", " ", " ", " ", " ", " ", " ", " ", " ", Nil, Nil, Nil, "FATX01" )
       While lCont
             //LGS#20200210 - Adequação de release 12.1.25 e posteriores
             If Pergunte("FATX01", .t.)
             //If fValPer() //Substituição da API pela função
                cOpcAtu := Iif(mv_par01 == 1, 'TODOSP', Iif(mv_par01 == 2, 'CATRAS', 'SATRAS'))
                If cOpcAtu == cOpcUsr
                   lCont := .f.
                Else
                   If cOpcAtu $ 'TODOSP'
                      cAuxOpc := Iif(cOpcUsr $ 'CATRAS', 'SATRAS', 'CATRAS')
                      DbSelectArea("SX5")
                      DbSetOrder(1)
                      DbSeek(xFilial("SX5")+'LB'+cAuxOpc, .t.)
                      If Alltrim(SX5->X5_DESCRI) $ '.'
                         DbSeek(xFilial("SX5")+'LB'+cOpcAtu, .t.)
                         RecLock("SX5", .f.)
                            SX5->X5_DESCRI := Upper(Alltrim(cUsername))
                         MsUnLock()
                         DbSeek(xFilial("SX5")+'LB'+cOpcUsr, .t.)
                         RecLock("SX5", .f.)
                            SX5->X5_DESCRI := '.'
                         MsUnLock()
                         cOpcUsr := cOpcAtu
                         mvpar01 := mv_par01
                         lCont   := .f.
                      Else
                         MsgBox('Não pode alterar a opção para TODOS PEDIDOS, pois existe outro usuário utilizando!', 'Atenção', 'STOP')
                         mv_par01 := mvpar01
                         lCont    := .f.
                      Endif
*/
                      /*
                      _aRetInf := FWGetSX5 ( "LB", cAuxOpc )
                      If Alltrim( _aRetInf[1][4] ) $ '.'
                         _aRetInf := FWGetSX5 ( "LB", cOpcAtu )
                         FwPutSX5(cFlavour, cTabela, cChave, cTextoPor, cTextoEng, cTextoEsp, cTextoAlt)
                      Else
                         MsgBox('Não pode alterar a opção para TODOS PEDIDOS, pois existe outro usuário utilizando!', 'Atenção', 'STOP')
                         mv_par01 := mvpar01
                         lCont    := .f.
                      Endif*/
/*                   ElseIf cOpcAtu $ 'CATRAS'
                          DbSelectArea("SX5")
                          DbSetOrder(1)
                          DbSeek(xFilial("SX5")+'LB'+cOpcAtu, .t.)
                          If Alltrim(SX5->X5_DESCRI) $ '.'
                             DbSeek(xFilial("SX5")+'LBTODOSP', .t.)
                             If Alltrim(SX5->X5_DESCRI) $ '.'
                                DbSeek(xFilial("SX5")+'LB'+cOpcAtu, .t.)
                                RecLock("SX5", .f.)
                                   SX5->X5_DESCRI := Upper(Alltrim(cUsername))
                                MsUnLock()
                                DbSeek(xFilial("SX5")+'LB'+cOpcUsr, .t.)
                                RecLock("SX5", .f.)
                                   SX5->X5_DESCRI := '.'
                                MsUnLock()
                                cOpcUsr := cOpcAtu
                                mvpar01 := mv_par01
                                lCont   := .f.
                             Else
                                If Upper(Alltrim(SX5->X5_DESCRI)) == Upper(Alltrim(cUsername))
                                   RecLock("SX5", .f.)
                                      SX5->X5_DESCRI := '.'
                                   MsUnLock()
                                   DbSeek(xFilial("SX5")+'LB'+cOpcAtu, .t.)
                                   RecLock("SX5", .f.)
                                      SX5->X5_DESCRI := Upper(Alltrim(cUsername))
                                   MsUnLock()
                                   cOpcUsr := cOpcAtu
                                   mvpar01 := mv_par01
                                   lCont := .f.
                                Else
                                   MsgBox('Já existe outro usuário analisando todos os pedidos!', 'Atenção', 'STOP')
                                   lCont := .f.
                                Endif
                             Endif
                          Else
                             cOpcAtu := 'SATRAS'
                             DbSeek(xFilial("SX5")+'LB'+cOpcAtu, .t.)
                             If Alltrim(SX5->X5_DESCRI) $ '.'
                                RecLock("SX5", .f.)
                                   SX5->X5_DESCRI := Upper(Alltrim(cUsername))
                                MsUnLock()
                                DbSeek(xFilial("SX5")+'LB'+cOpcUsr, .t.)
                                RecLock("SX5", .f.)
                                   SX5->X5_DESCRI := '.'
                                MsUnLock()
                                cOpcUsr := cOpcAtu
                                mvpar01 := 1
                                lCont   := .f.
                             Else
                                MsgBox('Já existe outro usuário analisando os pedidos!', 'Atenção', 'STOP')
                             Endif
                          Endif
                   ElseIf cOpcAtu $ 'SATRAS'
                          DbSelectArea("SX5")
                          DbSetOrder(1)
                          DbSeek(xFilial("SX5")+'LB'+cOpcAtu, .t.)
                          If Alltrim(SX5->X5_DESCRI) $ '.'
                             DbSeek(xFilial("SX5")+'LBTODOSP', .t.)
                             If Alltrim(SX5->X5_DESCRI) $ '.'
                                DbSeek(xFilial("SX5")+'LB'+cOpcAtu, .t.)
                                RecLock("SX5", .f.)
                                   SX5->X5_DESCRI := Upper(Alltrim(cUsername))
                                MsUnLock()
                                DbSeek(xFilial("SX5")+'LB'+cOpcUsr, .t.)
                                RecLock("SX5", .f.)
                                   SX5->X5_DESCRI := '.'
                                MsUnLock()
                                cOpcUsr := cOpcAtu
                                mvpar01 := mv_par01
                                lCont   := .f.
                             Else
                                If Upper(Alltrim(SX5->X5_DESCRI)) == Upper(Alltrim(cUsername))
                                   RecLock("SX5", .f.)
                                      SX5->X5_DESCRI := '.'
                                   MsUnLock()
                                   DbSeek(xFilial("SX5")+'LB'+cOpcAtu, .t.)
                                   RecLock("SX5", .f.)
                                      SX5->X5_DESCRI := Upper(Alltrim(cUsername))
                                   MsUnLock()
                                   cOpcUsr := cOpcAtu
                                   mvpar01 := mv_par01
                                   lCont := .f.
                                Else
                                   MsgBox('Já existe outro usuário analisando todos os pedidos!', 'Atenção', 'STOP')
                                   lCont := .f.
                                Endif
                             Endif
                          Else
                             cOpcAtu := 'CATRAS'
                             DbSeek(xFilial("SX5")+'LB'+cOpcAtu, .t.)
                             If Alltrim(SX5->X5_DESCRI) $ '.'
                                RecLock("SX5", .f.)
                                   SX5->X5_DESCRI := Upper(Alltrim(cUsername))
                                MsUnLock()
                                DbSeek(xFilial("SX5")+'LB'+cOpcUsr, .t.)
                                RecLock("SX5", .f.)
                                   SX5->X5_DESCRI := '.'
                                MsUnLock()
                                cOpcUsr := cOpcAtu
                                mvpar01 := 3
                                lCont   := .f.
                             Else
                                MsgBox('Já existe outro usuário analisando os pedidos!', 'Atenção', 'STOP')
                             Endif
                          Endif
                   Endif
                Endif
             Else
                lCont := .f.
             Endif
       Enddo
       DbSelectArea("SC5")
Return Nil
*/
/*
Static Function fValPer()
       Local _lRet
       
       _lRet := Pergunte("FATX01", .F.)
Return _lRet*/

User Function FATX01_P()
     Local aArea      := GetArea()
     Local aAreaSA1   := SA1->(GetArea())
     Local aFisGet    := {}
     Local aFisGetSC5 := {}
     Local aTitles    := {"Nota Fiscal", "Duplicatas"}
     Local aDupl      := {}
     Local aFlHead    := { "Vencimento", "Valor", 'STR0063' }
     Local aEntr      := {}                
     Local aDuplTmp   := {}
     Local aHeadSC6   := MHeaderSC6()
     Local aColsSC6   := MonAcolSC6(aHeadSC6)
     Local nPTotal    := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_VALOR"   })
     Local nPValDesc  := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_VALDESC" })
     Local nPPrUnit   := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_PRUNIT"  })
     Local nPPrcVen   := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_PRCVEN"  })
     Local nPQtdVen   := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_QTDVEN"  })
     Local nPDtEntr   := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_ENTREG"  })
     Local nPProduto  := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_PRODUTO" })
     Local nPTES      := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_TES"     })
     Local nPNfOri    := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_NFORI"   })
     Local nPSerOri   := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_SERIORI" })
     Local nPItemOri  := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_ITEMORI" })
     Local nPCodPro   := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_PRODUTO" })
     //Local nUsado     := Len(aHeadSC6)
     Local nX         := 0
     Local nAcerto    := 0
     Local nPrcLista  := 0
     Local nValMerc   := 0
     Local nDesconto  := 0
     Local nAcresFin  := 0
     Local nQtdPeso   := 0
     Local nRecOri    := 0
     Local nPosEntr   := 0
     Local nItem      := 0
     Local nY         := 0 
     Local nPosCpo    := 0
     Local lDtEmi     := SuperGetMv("MV_DPDTEMI", .F., .T.)
     Local dDataCnd   := SC5->C5_EMISSAO
     Local oDlg
     Local oDupl
     Local oFolder
     Local _lOpen        := .F. //LGS#20200210 - Adequação para release 12.1.25
     Local _cAliasSX3 := GetNextAlias() //LGS#20200210 - Adequação para release 12.1.25
     Local _nNFFRETE     //LGS#20200211 - Adequação para release 12.1.25
     Local _nNFSEGUR
     Local _nNFDESCO
     Local _nNFAUTON
     Local _nNFDESPE
     Local _nNFBASED
     Local _nNFTOTAL

     Private nUsdSC6  := Len(aHeadSC6)

     // ABERTURA DO DICIONÁRIO SX3 - LGS#20200210 - Adequação para release 12.1.25
     OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
     _lOpen := Select( _cAliasSX3 ) > 0
     If !_lOpen //LGS#20200210 - Adequação para release 12.1.25
        MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
        Return
     Endif
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Busca referencias no SC5                     ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     DbSelectArea("SC5")
     DbSetOrder(1)
     DbSeek(xFilial("SC5")+LPD->PEDIDO, .t.)
     dDataCnd   := SC5->C5_EMISSAO
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Busca referencias no SC6                     ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     aFisGet	:= {}

     /********************************************************************************************************************************/
     /*** BLOCO ALTERADO EM 10/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
     /*DbSelectArea("SX3")
     DbSetOrder(1)
     MsSeek("SC6")
     While !Eof() .And. X3_ARQUIVO == "SC6"
           cValid := UPPER(X3_VALID+X3_VLDUSER)
           If 'MAFISGET("' $ cValid
              nPosIni     := AT('MAFISGET("', cValid)+10
              nLen        := AT('")',Substr(cValid, nPosIni, Len(cValid) - nPosIni)) - 1
              cReferencia := Substr(cValid, nPosIni, nLen)
              aAdd(aFisGet, {cReferencia, X3_CAMPO, MaFisOrdem(cReferencia)})
           EndIf
           If 'MAFISREF("' $ cValid
              nPosIni     := AT('MAFISREF("', cValid) + 10
              cReferencia :=Substr(cValid, nPosIni, AT('","MT410",', cValid) - nPosIni)
              aAdd(aFisGet, {cReferencia, X3_CAMPO, MaFisOrdem(cReferencia)})
           EndIf
           DbSkip()
     EndDo*/
     DbSelectArea( _cAliasSX3 )
     ( _cAliasSX3 )->( DbSetOrder(1) )
     ( _cAliasSX3 )->( MsSeek("SC6") )
     While !Eof() .And. ( _cAliasSX3 )->( X3_ARQUIVO ) == "SC6"
           cValid := UPPER( ( _cAliasSX3 )->( X3_VALID ) + ( _cAliasSX3 )->( X3_VLDUSER ) )
           If 'MAFISGET("' $ cValid
              nPosIni     := AT('MAFISGET("', cValid)+10
              nLen        := AT('")',Substr(cValid, nPosIni, Len(cValid) - nPosIni)) - 1
              cReferencia := Substr(cValid, nPosIni, nLen)
              aAdd(aFisGet, {cReferencia, ( _cAliasSX3 )->( X3_CAMPO ), MaFisOrdem(cReferencia)})
           EndIf
           If 'MAFISREF("' $ cValid
              nPosIni     := AT('MAFISREF("', cValid) + 10
              cReferencia :=Substr(cValid, nPosIni, AT('","MT410",', cValid) - nPosIni)
              aAdd(aFisGet, {cReferencia, ( _cAliasSX3 )->( X3_CAMPO ), MaFisOrdem(cReferencia)})
           EndIf
           DbSkip()
     EndDo
     /********************************************************************************************************************************/
     aSort(aFisGet, , ,{|x, y| x[3] < y[3]})

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Busca referencias no SC5                     ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     aFisGetSC5	:= {}

     /********************************************************************************************************************************/
     /*** BLOCO ALTERADO EM 10/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
     /*dbSelectArea("SX3")
     dbSetOrder(1)
     MsSeek("SC5")
     While !Eof() .And. X3_ARQUIVO == "SC5"
           cValid := UPPER(X3_VALID+X3_VLDUSER)
           If 'MAFISGET("' $ cValid
              nPosIni     := AT('MAFISGET("', cValid) + 10
              nLen        := AT('")', Substr(cValid, nPosIni, Len(cValid) - nPosIni)) - 1
              cReferencia := Substr(cValid, nPosIni, nLen)
              aAdd(aFisGetSC5, {cReferencia, X3_CAMPO, MaFisOrdem(cReferencia)})
           EndIf
           If 'MAFISREF("' $ cValid
              nPosIni     := AT('MAFISREF("', cValid) + 10
              cReferencia :=Substr(cValid, nPosIni, AT('","MT410",', cValid) - nPosIni)
              aAdd(aFisGetSC5, { cReferencia, X3_CAMPO, MaFisOrdem(cReferencia)})
           EndIf
           DbSkip()
     EndDo*/
     dbSelectArea( _cAliasSX3 )
     ( _cAliasSX3 )->( dbSetOrder(1) )
     ( _cAliasSX3 )->( MsSeek("SC5") )
     While !Eof() .And. ( _cAliasSX3 )->( X3_ARQUIVO ) == "SC5"
           cValid := UPPER( ( _cAliasSX3 )->( X3_VALID ) + ( _cAliasSX3 )->( X3_VLDUSER ) )
           If 'MAFISGET("' $ cValid
              nPosIni     := AT('MAFISGET("', cValid) + 10
              nLen        := AT('")', Substr(cValid, nPosIni, Len(cValid) - nPosIni)) - 1
              cReferencia := Substr(cValid, nPosIni, nLen)
              aAdd(aFisGetSC5, {cReferencia, ( _cAliasSX3 )->( X3_CAMPO ), MaFisOrdem(cReferencia)})
           EndIf
           If 'MAFISREF("' $ cValid
              nPosIni     := AT('MAFISREF("', cValid) + 10
              cReferencia :=Substr(cValid, nPosIni, AT('","MT410",', cValid) - nPosIni)
              aAdd(aFisGetSC5, { cReferencia, ( _cAliasSX3 )->( X3_CAMPO ), MaFisOrdem(cReferencia)})
           EndIf
           DbSkip()
     EndDo
     /********************************************************************************************************************************/
     aSort(aFisGetSC5, , , {|x, y| x[3] < y[3]})

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Inicializa a funcao fiscal                   ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     MaFisSave()
     MaFisEnd()
     MaFisIni(SC5->C5_CLIENTE                   ,; //1-Codigo Cliente/Fornecedor
              SC5->C5_LOJAENT                   ,; //2-Loja do Cliente/Fornecedor
              IIf(SC5->C5_TIPO $ 'DB', "F", "C"),; //3-C:Cliente , F:Fornecedor
              SC5->C5_TIPO                      ,; //4-Tipo da NF
              SC5->C5_TIPOCLI                   ,; //5-Tipo do Cliente/Fornecedor
              Nil                               ,;
              Nil                               ,;
              Nil                               ,;
              Nil                               ,;
              "MATA461"                          )

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Agrega os itens para a funcao fiscal         ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     If nPTotal > 0 .And. nPValDesc > 0 .And. nPPrUnit > 0 .And. nPProduto > 0 .And. nPQtdVen > 0 .And. nPTes > 0
        For nX := 1 To Len(aColsSC6)
            nQtdPeso := 0
            If Len(aColsSC6[nX]) == nUsdSC6 .Or. !aColsSC6[nX][nUsdSC6+1]
               nItem++
               If nPNfOri > 0 .And. nPSerOri > 0 .And. nPItemOri > 0
                  If !Empty(aColsSC6[nX][nPNfOri]) .And. !Empty(aColsSC6[nX][nPItemOri])
                     SD1->(dbSetOrder(1))
                     If SD1->(MSSeek(xFilial("SD1")+aColsSC6[nX][nPNfOri]+aColsSC6[nX][nPSerOri]+SC5->C5_CLIENTE+SC5->C5_LOJACLI+aColsSC6[nX][nPCodPro]+aColsSC6[nX][nPItemOri]))
                        nRecOri := SD1->(Recno())
                     Endif	
                  Endif
               Endif	
               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
               //³Calcula o preco de lista                     ³
               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
               nValMerc  := aColsSC6[nX][nPTotal]
               nPrcLista := aColsSC6[nX][nPPrUnit]
               If ( nPrcLista == 0 )
                  nPrcLista := NoRound(nValMerc / aColsSC6[nX][nPQtdVen], TamSX3("C6_PRCVEN")[2])
               EndIf
               nAcresFin := a410Arred(aColsSC6[nX][nPPrcVen] * SC5->C5_ACRSFIN / 100, "D2_PRCVEN")
               nValMerc  += a410Arred(aColsSC6[nX][nPQtdVen] * nAcresFin, "D2_TOTAL")
               nDesconto := a410Arred(nPrcLista * aColsSC6[nX][nPQtdVen], "D2_DESCON") - nValMerc
               nDesconto := IIf(nDesconto == 0, aColsSC6[nX][nPValDesc], nDesconto)
               nDesconto := Max(0, nDesconto)
               nPrcLista += nAcresFin
               nValMerc  += nDesconto

               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
               //³Verifica a data de entrega para as duplicatas³
               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
               If ( nPDtEntr > 0 )
                  If ( dDataCnd > aColsSC6[nX][nPDtEntr] .And. !Empty(aColsSC6[nX][nPDtEntr]) )
                     dDataCnd := aColsSC6[nX][nPDtEntr]
                  EndIf
               Else
                  dDataCnd  := SC5->C5_EMISSAO
               EndIf
               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
               //³Agrega os itens para a funcao fiscal         ³
               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
               MaFisAdd(aColsSC6[nX][nPProduto],; // 1-Codigo do Produto ( Obrigatorio )
                        aColsSC6[nX][nPTES]    ,; // 2-Codigo do TES ( Opcional )
                        aColsSC6[nX][nPQtdVen] ,; // 3-Quantidade ( Obrigatorio )
                        nPrcLista           ,; // 4-Preco Unitario ( Obrigatorio )
                        nDesconto           ,; // 5-Valor do Desconto ( Opcional )
                        ""                  ,; // 6-Numero da NF Original ( Devolucao/Benef )
                        ""                  ,; // 7-Serie da NF Original ( Devolucao/Benef )
                        nRecOri             ,; // 8-RecNo da NF Original no arq SD1/SD2
                        0                   ,; // 9-Valor do Frete do Item ( Opcional )
                        0                   ,; // 10-Valor da Despesa do item ( Opcional )
                        0                   ,; // 11-Valor do Seguro do item ( Opcional )
                        0                   ,; // 12-Valor do Frete Autonomo ( Opcional )
                        nValMerc            ,; // 13-Valor da Mercadoria ( Obrigatorio )
                        0                    ) // 14-Valor da Embalagem ( Opiconal )
            EndIf
            SB1->(dbSetOrder(1))
            If SB1->(MsSeek(xFilial("SB1")+aColsSC6[nX][nPProduto]))
               nQtdPeso := aColsSC6[nX][nPQtdVen] * SB1->B1_PESO
            Endif	
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³Altera peso para calcular frete              ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            MaFisLoad("IT_VALMERC", nValMerc, nItem)
            MaFisAlt("IT_PESO"    , nQtdPeso, nItem)
        Next nX
     EndIf

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Indica os valores do cabecalho               ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     MaFisAlt("NF_FRETE"   , SC5->C5_FRETE)
     MaFisAlt("NF_SEGURO"  , SC5->C5_SEGURO)
     MaFisAlt("NF_AUTONOMO", SC5->C5_FRETAUT)
     MaFisAlt("NF_DESPESA" , SC5->C5_DESPESA)
     If SC5->C5_DESCONT > 0
        MaFisAlt("NF_DESCONTO", Min(MaFisRet(, "NF_VALMERC") - 0.01, SC5->C5_DESCONT + MaFisRet(, "NF_DESCONTO")))
     EndIf
     If SC5->C5_PDESCAB > 0
        MaFisAlt("NF_DESCONTO", A410Arred(MaFisRet(, "NF_VALMERC") * SC5->C5_PDESCAB / 100, "C6_VALOR")+MaFisRet(, "NF_DESCONTO"))
     EndIf

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Realiza alteracoes de referencias do SC6         ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     DbSelectArea("SC6")
     If Len(aFisGet) > 0
        For nX := 1 to Len(aColsSC6)
            If !aColsSC6[nX][Len(aHeadSC6)+1]
               For nY := 1 to Len(aFisGet)
                   nPosCpo := aScan(aHeadSC6, { |x| AllTrim(x[2]) == Alltrim(aFisGet[ny][2])})
                   If nPosCpo > 0
                      If !Empty(aColsSC6[nX][nPosCpo])
                         MaFisAlt(aFisGet[ny][1], aColsSC6[nX][nPosCpo], nX, .F.)
                      Endif
                   EndIf
               Next nX
            Endif
        Next nY           
     Endif

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Realiza alteracoes de referencias do SC5         ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     If Len(aFisGetSC5) > 0	
        DbSelectArea("SC5")
        For nY := 1 to Len(aFisGetSC5)
            If !Empty(&("SC5->"+Alltrim(aFisGetSC5[ny][2])))
               MaFisAlt(aFisGetSC5[ny][1], &("SC5->"+Alltrim(aFisGetSC5[ny][2])), nItem, .F.)
            EndIf
        Next nY
     Endif
     If ExistBlock("M410PLNF")
        ExecBlock("M410PLNF", .F., .F.)
     EndIf
     MaFisWrite(1)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Calcula os venctos conforme a condicao de pagto  ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     If lDtEmi
        DbSelectarea("SE4")
        DbSetOrder(1)
        MsSeek(xFilial("SE4")+SC5->C5_CONDPAG)
        If !(SE4->E4_TIPO == "9")
           aDupl := Condicao(MaFisRet(, "NF_BASEDUP"), SC5->C5_CONDPAG, MaFisRet(, "NF_VALIPI"), dDataCnd, MaFisRet(, "NF_VALSOL"))
           If Len(aDupl) > 0
              For nX := 1 To Len(aDupl)
                  nAcerto += aDupl[nX][2]
              Next nX
              aDupl[Len(aDupl)][2] += MaFisRet(,"NF_BASEDUP") - nAcerto
              For nX := 1 To Len(aDupl)
                  aDupl[nX][2] := TransForm(aDupl[nX][2], PesqPict("SE1", "E1_VALOR"))
              Next nX
           Endif	
        Else
           aDupl := {{Ctod(""), TransForm(MaFisRet(,"NF_BASEDUP"), PesqPict("SE1", "E1_VALOR"))}}
        EndIf
     Else
        For nX := 1 to Len(aColsSC6)
            If Len(aColsSC6[nX]) == nUsdSC6 .Or. !aColsSC6[nX][nUsdSC6+1]
               If nPDtEntr > 0
                  nPosEntr := Ascan(aEntr, {|x| x[1] == aColsSC6[nX][nPDtEntr]})
                  If nPosEntr == 0
                     aAdd(aEntr, {aColsSC6[nX][nPDtEntr], MaFisRet(nX, "IT_BASEDUP"), MaFisRet(nX, "IT_VALIPI"), MaFisRet(nX, "IT_VALSOL")})
                  Else
                     aEntr[nPosEntr][2]+= MaFisRet(nX, "IT_BASEDUP")
                     aEntr[nPosEntr][2]+= MaFisRet(nX, "IT_VALIPI")
                     aEntr[nPosEntr][2]+= MaFisRet(nX, "IT_VALSOL")
                  Endif
               Endif
            Endif
        Next
        DbSelectArea("SE4")
        DbSetOrder(1)
        MsSeek(xFilial("SE4")+SC5->C5_CONDPAG)
        If !(SE4->E4_TIPO == "9")
           For nY := 1 to Len(aEntr)           
               nAcerto := 0
               aDuplTmp := Condicao(aEntr[nY][2], SC5->C5_CONDPAG, aEntr[nY][3], aEntr[nY][1], aEntr[nY][4])
               For nX := 1 To Len(aDuplTmp)
                   nAcerto += aDuplTmp[nX][2]
               Next nX
               aDuplTmp[Len(aDuplTmp)][2] += aEntr[nY][2] - nAcerto
               For nX := 1 To Len(aDuplTmp)
                   aDuplTmp[nX][2] := TransForm(aDuplTmp[nX][2], PesqPict("SE1", "E1_VALOR"))
               Next nX
               aEval(aDuplTmp, {|x| Aadd(aDupl, {aEntr[nY][1], x[1], x[2]})})
           Next
        Else
           aDupl := { {Ctod(""), TransForm(MaFisRet(, "NF_BASEDUP"), PesqPict("SE1", "E1_VALOR"))}}
        EndIf
     Endif
     If Len(aDupl) == 0
        aDupl := {{Ctod(""), TransForm(MaFisRet(, "NF_BASEDUP"), PesqPict("SE1", "E1_VALOR"))}}
     Endif
     _nNFFRETE := MaFisRet(,"NF_FRETE")  //LGS#20200210 - Adequação de release 12.1.25 e posteriores
     _nNFSEGUR := MaFisRet(,"NF_SEGURO")
     _nNFDESCO := MaFisRet(,"NF_DESCONTO")
     _nNFAUTON := MaFisRet(,"NF_AUTONOMO")
     _nNFDESPE := MaFisRet(,"NF_DESPESA")
     _nNFBASED := MaFisRet(,"NF_BASEDUP")
     _nNFTOTAL := MaFisRet(,"NF_TOTAL")
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Monta a tela de exibicao dos valores fiscais ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     DEFINE MSDIALOG oDlg TITLE OemToAnsi("Planilha Financeira") FROM 09, 00 TO 28, 80
            oFolder := TFolder():New(001, 001, aTitles, {"HEADER"}, oDlg, , , , .T., .F., 315, 140)
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³Folder 1                                     ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            MaFisRodape(1, oFolder:aDialogs[1], , {005, 001, 310, 60}, Nil, .T.)
            @ 070, 005 SAY RetTitle("F2_FRETE")       SIZE 40, 10 PIXEL OF oFolder:aDialogs[1]
            @ 070, 105 SAY RetTitle("F2_SEGURO")      SIZE 40, 10 PIXEL OF oFolder:aDialogs[1]
            @ 070, 205 SAY RetTitle("F2_DESCONT")     SIZE 40, 10 PIXEL OF oFolder:aDialogs[1]
            @ 085, 005 SAY RetTitle("F2_FRETAUT")     SIZE 40, 10 PIXEL OF oFolder:aDialogs[1]
            @ 085, 105 SAY RetTitle("F2_DESPESA")     SIZE 40, 10 PIXEL OF oFolder:aDialogs[1]
            @ 085, 205 SAY RetTitle("F2_VALFAT")      SIZE 40, 10 PIXEL OF oFolder:aDialogs[1]
            //LGS#20200210 - Adequação de release 12.1.25 e posteriores - Troquei as chamadas de função para variável pois não será suportado em versões futuras.
            //@ 070, 050 MSGET MaFisRet(,"NF_FRETE")    PICTURE PesqPict("SF2", "F2_FRETE"   , 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
              @ 070, 050 MSGET _nNFFRETE                PICTURE PesqPict("SF2", "F2_FRETE"   , 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
            //@ 070, 150 MSGET MaFisRet(,"NF_SEGURO")   PICTURE PesqPict("SF2", "F2_SEGURO"  , 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
              @ 070, 150 MSGET _nNFSEGUR                PICTURE PesqPict("SF2", "F2_SEGURO"  , 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
            //@ 070, 250 MSGET MaFisRet(,"NF_DESCONTO") PICTURE PesqPict("SF2", "F2_DESCONTO", 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
              @ 070, 250 MSGET _nNFDESCO                PICTURE PesqPict("SF2", "F2_DESCONTO", 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
            //@ 085, 050 MSGET MaFisRet(,"NF_AUTONOMO") PICTURE PesqPict("SF2", "F2_FRETAUT" , 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
              @ 085, 050 MSGET _nNFAUTON                PICTURE PesqPict("SF2", "F2_FRETAUT" , 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
            //@ 085, 150 MSGET MaFisRet(,"NF_DESPESA")  PICTURE PesqPict("SF2", "F2_DESPESA" , 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
              @ 085, 150 MSGET _nNFDESPE                PICTURE PesqPict("SF2", "F2_DESPESA" , 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
            //@ 085, 250 MSGET MaFisRet(,"NF_BASEDUP")  PICTURE PesqPict("SF2", "F2_VALFAT"  , 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
              @ 085, 250 MSGET _nNFBASED                PICTURE PesqPict("SF2", "F2_VALFAT"  , 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
            @ 105, 005 TO 106, 310 PIXEL OF oFolder:aDialogs[1]
            @ 110, 005 SAY OemToAnsi("Total da Nota") SIZE 40, 10 PIXEL OF oFolder:aDialogs[1]
            //@ 110, 050 MSGET MaFisRet(,"NF_TOTAL")    PICTURE PesqPict("SF2","F2_VALBRUT",16,2)     SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
              @ 110, 050 MSGET   _nNFTOTAL              PICTURE PesqPict("SF2","F2_VALBRUT",16,2)     SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
            @ 110, 270 BUTTON OemToAnsi("Sair")       SIZE 040,11 FONT oFolder:aDialogs[1]:oFont ACTION oDlg:End() OF oFolder:aDialogs[1] PIXEL
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³Folder 2                                     ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If lDtEmi
               @ 005, 001 LISTBOX oDupl FIELDS TITLE aFlHead[1], aFlHead[2]             SIZE 310, 095 OF oFolder:aDialogs[2] PIXEL
            Else	
               @ 005, 001 LISTBOX oDupl FIELDS TITLE aFlHead[3], aFlHead[1], aFlHead[2] SIZE 310, 095 OF oFolder:aDialogs[2] PIXEL
            Endif
            oDupl:SetArray(aDupl)
            oDupl:bLine := {|| aDupl[oDupl:nAt] }
            @ 105, 005 TO 106, 310 PIXEL OF oFolder:aDialogs[2]
            If cPaisLoc == "BRA"
               @ 110, 005 SAY RetTitle("F2_VALFAT") SIZE 40, 10 PIXEL OF oFolder:aDialogs[2]
            Else
               @ 110, 005 SAY OemToAnsi('STR0051')    SIZE 40, 10 PIXEL OF oFolder:aDialogs[2]
            Endif	
            //@ 110, 050 MSGET MaFisRet(,"NF_BASEDUP")  PICTURE PesqPict("SF2", "F2_VALFAT", 16, 2)   SIZE 50, 07 PIXEL WHEN .F. OF oFolder:aDialogs[2]
              @ 110, 050 MSGET _nNFBASED                PICTURE PesqPict("SF2", "F2_VALFAT", 16, 2)   SIZE 50, 07 PIXEL WHEN .F. OF oFolder:aDialogs[2]
            @ 110, 270 BUTTON OemToAnsi("Sair")       SIZE 040,11 FONT oFolder:aDialogs[1]:oFont ACTION oDlg:End() OF oFolder:aDialogs[2] PIXEL

     ACTIVATE MSDIALOG oDlg CENTERED
     MaFisEnd()
     MaFisRestore()

     DbSelectArea( _cAliasSX3 )
     DbCloseArea()

     RestArea(aAreaSA1)
     RestArea(aArea)
Return(.T.)

Return

Static Function MHeaderSC6()
       Local aHeaderSC6 := {}
       Local _lOpen        := .F. //LGS#20200210 - Adequação para release 12.1.25
       Local _cAliasSX3 := GetNextAlias() //LGS#20200210 - Adequação para release 12.1.25

       // ABERTURA DO DICIONÁRIO SX3 - LGS#20200210 - Adequação para release 12.1.25
       OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
       _lOpen := Select( _cAliasSX3 ) > 0
       If !_lOpen //LGS#20200210 - Adequação para release 12.1.25
          MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
          Return
       Endif
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 10/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*DbSelectArea("SX3")
       DbSetOrder(1)
       MsSeek("SC6")
       While ( !Eof() .And. (SX3->X3_ARQUIVO == "SC6") )
             If ( X3USO(SX3->X3_USADO) .And. !(	Trim(SX3->X3_CAMPO) == "C6_NUM" ) .And. Trim(SX3->X3_CAMPO) <> "C6_QTDEMP" .And. Trim(SX3->X3_CAMPO) <> "C6_QTDENT" .And. cNivel >= SX3->X3_NIVEL )
                aAdd(aHeaderSC6, { TRIM(( _cAliasSX3 )->( X3_TITULO )), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT } )
             EndIf
             DbSelectArea("SX3")
             DbSkip()
       EndDo*/
       DbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( DbSetOrder(1) )
       ( _cAliasSX3 )->( MsSeek("SC6") )
       While ( !Eof() .And. ( ( _cAliasSX3 )->( X3_ARQUIVO ) == "SC6") )
             If ( X3USO( ( _cAliasSX3 )->( X3_USADO ) ) .And. !( Trim( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C6_NUM" ) .And. Trim( ( _cAliasSX3 )->( X3_CAMPO ) ) <> "C6_QTDEMP" .And. Trim( ( _cAliasSX3 )->( X3_CAMPO ) ) <> "C6_QTDENT" .And. cNivel >= ( _cAliasSX3 )->( X3_NIVEL ) )
                aAdd( aHeaderSC6, { TRIM(( _cAliasSX3 )->( X3_TITULO )), ( _cAliasSX3 )->( X3_CAMPO ), ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), ( _cAliasSX3 )->( X3_VALID ), ( _cAliasSX3 )->( X3_USADO ), ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_ARQUIVO ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
             EndIf
             DbSelectArea( _cAliasSX3 )
             ( _cAliasSX3 )->( DbSkip() )
       EndDo
       DbSelectArea( _cAliasSX3 )
       DbCloseArea()
       /********************************************************************************************************************************/
Return( aHeaderSC6 )

Static Function MonAcolSC6(aHeadSC6)
       Local aColsSC6 := {}
       Local nCntFor
       Private AHEADGRADE := {}
       Private ACOLSGRADE := {}
       DbSelectArea("SC6")
       DbSetOrder(1)
       MsSeek(xFilial("SC6")+SC5->C5_NUM)
       While ( !Eof() .And. SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == SC5->C5_NUM )
             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³ Verifica se este item foi digitada atraves de uma    ³
             //³ grade, se for junta todos os itens da grade em uma   ³
             //³ referencia , abrindo os itens so quando teclar enter ³
             //³ na quantidade                                        ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             If ( SC6->C6_GRADE == "S" .And. lGrade )
                //a410Grade(.F., , cArqQry)
             Else
                aAdd(aColsSC6, Array(Len(aHeadSC6)+1))
                For nCntFor:=1 To Len(aHeadSC6)
                    If ( aHeadSC6[nCntFor,10] <>  "V" )
                       aCOLSSC6[Len(aColsSC6)][nCntFor] := FieldGet(FieldPos(aHeadSC6[nCntFor,2]))
                    Else			
                       aCOLSSC6[Len(aColsSC6)][nCntFor] := CriaVar(aHeadSC6[nCntFor,2])
                    EndIf
                Next nCntFor
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Mesmo nao sendo um item digitado atraves de grade e' necessa-³
                //³ rio criar o Array referente a este item para controle da     ³
                //³ grade                                                        ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                MatGrdMont(Len(aColsSC6))
             EndIf
             aColsSC6[Len(aColsSC6)][Len(aHeadSC6)+1] := .F.	
             DbSelectArea("SC6")
             DbSkip()
       EndDo
Return(aColsSC6)



/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Tela para rápida atualização do e-mail do cliente                       ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/


User Function AtuEmail

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Declaração de Variaveis Private dos Objetos                             ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
SetPrvt("oDlg1","oSay1","oSay2","oSay3","oGetCod","oGetRaz","oGetEmail","oSBtOK")

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Definicao do Dialog e todos os seus componentes.                        ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
oDlg1      := MSDialog():New( 171,642,319,1202,"ATUALIZA CADASTRO DE E-MAIL",,,.F.,,,,,,.T.,,,.T. )
oSay1      := TSay():New( 004,028,{||"Atualização de E-mail (Clientes)"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,120,008)
oSay2      := TSay():New( 013,014,{||"Código"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay3      := TSay():New( 032,012,{||"e-mail"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oGetCod      := TGet():New( 020,013,,oDlg1,038,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGetRaz      := TGet():New( 020,054,,oDlg1,188,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGetEmail      := TGet():New( 039,012,,oDlg1,232,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oSBtOK     := SButton():New( 052,241,1,,oDlg1,,"", )

oDlg1:Activate(,,,.T.)

Return




                               
/**************************************************************************************/
/*** MontaCols - Montagem do aCols para liberacao do pedido                          ***/
/**************************************************************************************/
/*
STATIC Function MontaCols()
Local aCols := {}  
Local aArea := GetArea() 
Local cArqQry,	aStruSC6 , lQuery, cQuery, nCntFor, lContinua, cCampo , nUsado, aRegSC6
Local _cRSDOFAT := GetMv("MV_RSDOFAT")
lContinua := .t.
aRegSC6 := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do aheader                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
nUsado := 0
aHeader := {}
dbSelectArea("SX3")
dbSetOrder(1)
MsSeek("SC6")
While ( !Eof() .And. SX3->X3_ARQUIVO == "SC6" )
	If ( X3Uso(SX3->X3_USADO) .And.;
			!AllTrim(SX3->X3_CAMPO)=="C6_NUM"    .And.;
			!AllTrim(SX3->X3_CAMPO)=="C6_QTDEMP" .And.;
			!AllTrim(SX3->X3_CAMPO)=="C6_QTDENT" .And.;
			cNivel >= SX3->X3_NIVEL ) .Or.;
			AllTrim(SX3->X3_CAMPO)=="C6_SLDALIB"
		nUsado++
		AADD(aHeader,{ AllTrim(( _cAliasSX3 )->( X3_TITULO )),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT } )
	EndIf
	dbSelectArea("SX3")
	dbSkip()
EndDo


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do aCols                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SC6")
	dbSetOrder(1)
			aStruSC6:= SC6->(dbStruct())
			cArqQry := U_NovoCursor()
			lQuery  := .T.
			cQuery := "SELECT SC6.*,SC6.R_E_C_N_O_ SC6RECNO "
			cQuery += "FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "
			cQuery += "WHERE SC6.C6_FILIAL='"+xFilial("SC6")+"' AND "
			cQuery += "SC6.C6_NUM='"+SC5->C5_NUM+"' AND "
			cQuery += "SC6.D_E_L_E_T_<>'*' "
			cQuery += "ORDER BY "+SqlOrder(SC6->(IndexKey()))

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArqQry,.T.,.T.)
			For nCntFor := 1 To Len(aStruSC6)
				If ( aStruSC6[nCntFor,2]<>"C" )
					TcSetField(cArqQry,aStruSC6[nCntFor,1],aStruSC6[nCntFor,2],aStruSC6[nCntFor,3],aStruSC6[nCntFor,4])
				EndIf
			Next nCntFor
	
	dbselectarea(cArqQry)
	dbgotop()
	While ( !Eof() .And. (cArqQry)->C6_FILIAL == xFilial("SC6") .And.;
			(cArqQry)->C6_NUM == SC5->C5_NUM .And. lContinua )
		//LGS#20200210 - Adequação de release 12.1.25 e posteriores
		//If !(("R"$Alltrim((cArqQry)->C6_BLQ)).And.(GetMv("MV_RSDOFAT")=="N"))
		If !(("R"$Alltrim((cArqQry)->C6_BLQ)).And.( _cRSDOFAT =="N"))
			lBloqueio := .F.
		EndIf

			AADD(aCols,Array(Len(aHeader)+1))
			For nCntFor := 1 To Len(aHeader)
				cCampo := Alltrim(aHeader[nCntFor,2])
				If ( aHeader[nCntFor,10] # "V" .And. cCampo <> "C6_QTDLIB" .And. cCampo <> "C6_MOPC" )
					aCols[Len(aCols)][nCntFor] := FieldGet(FieldPos(cCampo))
				Else
					aCols[Len(aCols)][nCntFor] := CriaVar(cCampo)
				EndIf 
				if cCampo = "C6_QTDLIB"
					aCols[Len(aCols)][nCntFor] := (cArqQry)->C6_QTDVEN
				endif
			Next nCntFor
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Mesmo nao sendo um item digitado atraves de grade e' necessa-³
			//³ rio criar o Array referente a este item para controle da     ³
			//³ grade                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MatGrdMont(Len(aCols))

//			MaIniLiber(M->C5_NUM,(cArqQry)->C6_QTDVEN,Len(aCols))


		aCols[Len(aCols)][Len(aHeader)+1] := .F.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Guarda os registros do SC6 para posterior gravacao                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aadd(aRegSC6,(cArqQry)->SC6RECNO)

		dbSelectArea(cArqQry)
		dbSkip()
	EndDo
	dbSelectArea(cArqQry)
	dbCloseArea()
	dbSelectArea("SC6")

RestArea(aArea)

return(aCols)*/

Static Function AlteraPed(_cPed)
Local lRet := .t.
Local aCabec := {}
Local aItens := {}
Local aLinha := {}
//Local cAux
Private lMsErroAuto := .f.
Private lMsHelpAuto := .f.
	aCabec := {}	
	aItens := {}	
	aadd(aCabec,{"C5_NUM",SC5->C5_NUM,Nil})	
	aadd(aCabec,{"C5_TIPO",SC5->C5_TIPO,Nil})	
	aadd(aCabec,{"C5_CLIENTE",SC5->C5_CLIENTE,Nil})	
	aadd(aCabec,{"C5_LOJACLI",SC5->C5_LOJACLI,Nil})	
	aadd(aCabec,{"C5_LOJAENT",SC5->C5_LOJAENT,Nil})	
	aadd(aCabec,{"C5_CONDPAG",SC5->C5_CONDPAG,Nil})	
	dbselectarea("SC6")
	dbsetorder(1)
	dbseek(xFilial("SC6")+SC5->C5_NUM)
	DO WHILE !eof() .and. (SC6->C6_FILIAL == xFilial("SC6")) .and. (SC6->C6_NUM == SC5->C5_NUM)
		aLinha := {}		
		aadd(aLinha,{"LINPOS","C6_ITEM",SC6->C6_ITEM})		
		aadd(aLinha,{"AUTDELETA","N",Nil})		
		aadd(aLinha,{"C6_PRODUTO",SC6->C6_PRODUTO,Nil})		
		aadd(aLinha,{"C6_QTDVEN",SC6->C6_QTDVEN,Nil})		
		aadd(aLinha,{"C6_PRCVEN",SC6->C6_PRCVEN,Nil})		
		aadd(aLinha,{"C6_PRUNIT",SC6->C6_PRUNIT,Nil})		
		aadd(aLinha,{"C6_VALOR",SC6->C6_VALOR,Nil})		
		aadd(aLinha,{"C6_TES",SC6->C6_TES,Nil})		
		aadd(aItens,aLinha)	        
		dbselectarea("SC6")
		dbskip()
	enddo 

	DbSelectArea("SC5")
	MsgRun("Excluindo liberações...", "Aguarde", {|| MsExecAuto( { |x, y, z| MATA410(x, y, z) }, aCabec, aItens, 4 ) } )
	If lMsErroAuto
		MostraErro()
	ENDIF 

return(lRet)

Static Function XSomaCIF(_cPed)
       Local lRet := .t.
       Local aCabec := {}
       Local aItens := {}
       Local aLinha := {}
       Local nTam1,nTam2,nVlrFrete,nVlrProd,nSaldo,nFreteItem,nVlrUnit,nQtde,nPos,nVlrUnAnt,_nVlrTotDup,nComis,cAux,_cAlias
       //Local nTam3,nValor
       Local _lOpen        := .F. //LGS#20200210 - Adequação para release 12.1.25
       Local _cAliasSX3 := GetNextAlias() //LGS#20200210 - Adequação para release 12.1.25
       Private lMsErroAuto := .f.
       Private lMsHelpAuto := .f.

       // ABERTURA DO DICIONÁRIO SX3 - LGS#20200210 - Adequação para release 12.1.25
       OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
       _lOpen := Select( _cAliasSX3 ) > 0
       If !_lOpen //LGS#20200210 - Adequação para release 12.1.25
          MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
          Return
       Endif

       nVlrFrete := SC5->C5_XVLRFRE
       nSaldo := nVlrFrete

       dbselectarea("SF4")
	   dbsetorder(1)

       aItens := {}
       /*aCabec := {} 	
       aadd(aCabec,{"C5_NUM",SC5->C5_NUM,Nil})	
       aadd(aCabec,{"C5_TIPO",SC5->C5_TIPO,Nil})	
       aadd(aCabec,{"C5_CLIENTE",SC5->C5_CLIENTE,Nil})	
       aadd(aCabec,{"C5_LOJACLI",SC5->C5_LOJACLI,Nil})	
       aadd(aCabec,{"C5_LOJAENT",SC5->C5_LOJAENT,Nil})	
       aadd(aCabec,{"C5_CONDPAG",SC5->C5_CONDPAG,Nil})	
       aadd(aCabec,{"C5_REDESP",SC5->C5_REDESP,Nil}) */	
       dbselectarea("SC6")
       dbsetorder(1)
       nVlrProd := 0.0
       nQtde = 0
       dbseek(xFilial("SC6")+SC5->C5_NUM)
       DO WHILE !eof() .and. (SC6->C6_FILIAL == xFilial("SC6")) .and. (SC6->C6_NUM == SC5->C5_NUM)
          nVlrProd += (SC6->C6_QTDVEN*SC6->C6_PRCVEN)
          nQtde++
          dbskip()
       ENDDO
       nTam1 := TamSX3("C6_PRCVEN")[2]
       nTam2 := TamSX3("C6_XVLRFRE")[2]
       nPos := 0
       _nVlrTotDup := 0.0 // Valor total financeiro novo sem ipi+st
       dbseek(xFilial("SC6")+SC5->C5_NUM)
       DO WHILE !eof() .and. (SC6->C6_FILIAL == xFilial("SC6")) .and. (SC6->C6_NUM == SC5->C5_NUM)
		nPos++
		if nPos == nQtde
			nFreteItem := nSaldo
		else 
			nFreteItem := round(nVlrFrete*(SC6->C6_QTDVEN*SC6->C6_PRCVEN)/nVlrProd,nTam2)
		endif 
		nVlrUnAnt := SC6->C6_PRCVEN
		nVlrUnit := round(((SC6->C6_QTDVEN*SC6->C6_PRCVEN)+nFreteItem)/SC6->C6_QTDVEN,nTam1)
		nSaldo := nSaldo - nFreteItem
		dbselectarea("SF4")
		dbseek(xFilial("SF4")+SC6->C6_TES)
		if found()
            If (SF4->F4_DUPLIC = "S") .OR. (SF4->F4_CODIGO = "519")
				_nVlrTotDup := _nVlrTotDup + (nVlrUnit*SC6->C6_QTDVEN)
			Endif
		endif
		/*
		aLinha := {}		
		aadd(aLinha,{"LINPOS","C6_ITEM",SC6->C6_ITEM})		
		aadd(aLinha,{"AUTDELETA","N",Nil})		
		aadd(aLinha,{"C6_PRODUTO",SC6->C6_PRODUTO,Nil})		
		aadd(aLinha,{"C6_QTDVEN",SC6->C6_QTDVEN,Nil})		
		aadd(aLinha,{"C6_PRCVEN",nVlrUnit,Nil})		
		aadd(aLinha,{"C6_TES",SC6->C6_TES,Nil})		
		aadd(aLinha,{"C6_XVLRFRE",nVlrUnAnt,Nil})		
		aadd(aItens,aLinha)	  
		*/
		aLinha := U_DetCposTab("SC6","C6_XVLRFRE-C6_PRCVEN-C6_PRUNIT-C6_FILIAL-C6_ITEM-C6_NUM-C6_BLOQUEI-C6_BLQ-C6_GEROUPV-C6_QTDEMP-C6_QTDEMP2-C6_QTDENT-C6_QTDENT2-C6_QTDLIB-C6_QTDLIB2-C6_QTDRESE-C6_SLDALIB-C6_SUGENTR-C6_TRT")
		aadd(aLinha,{"LINPOS","C6_ITEM",SC6->C6_ITEM})		
		aadd(aLinha,{"AUTDELETA","N",Nil})
		aadd(aLinha,{"C6_PRCVEN",nVlrUnit,Nil})		
		aadd(aLinha,{"C6_PRUNIT",nVlrUnit,Nil})		
		aadd(aLinha,{"C6_XVLRFRE",nVlrUnAnt,Nil})		
		aadd(aItens,aLinha)
		      
		dbselectarea("SC6")
		dbskip()
	enddo 
	if _nVlrTotDup > 0.0
		nComis := round(SC5->C5_VLRCOM*100/_nVlrTotDup,TamSX3("C5_COMIS1")[2])
	else
		nComis := SC5->C5_COMIS1
	endif
	_nVlrTotDup := ROUND(_nVlrTotDup,TamSX3("C5_VLRDUP")[2])
/*	aadd(aCabec,{"C5_COMIS1",nComis,Nil})	
	aadd(aCabec,{"C5_VLRDUP",_nVlrTotDup,Nil})	
*/	
       _cAlias := "SC5"	
       aCabec := {} 	

       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 10/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*dbSelectArea("SX3")
       dbSetOrder(1)
       dbSeek("SC5")
       While !EOF() .And. X3_ARQUIVO = _cAlias
		If (X3Uso(X3_USADO) .AND. !(X3_CONTEXT = "V") .and. !(ALLTRIM(X3_CAMPO) == "C5_FILIAL")) .OR. ((ALLTRIM(X3_CAMPO) == "C5_COMIS1") .OR. (ALLTRIM(X3_CAMPO) == "C5_VLRDUP"))
			cAux := alltrim(_cAlias)+"->"+X3_CAMPO
			do case
			case ALLTRIM(X3_CAMPO) == "C5_COMIS1"
				xValor := nComis
			case ALLTRIM(X3_CAMPO) == "C5_VLRDUP"
				xValor := _nVlrTotDup
			otherwise
				xValor := &cAux
			endcase
			if !empty(xValor)
				aadd(aCabec,{X3_CAMPO   ,xValor,.F.})		
			endif 
		Endif
		dbSelectArea("SX3")
		dbSkip()
       End*/
       dbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( dbSetOrder(1) )
       ( _cAliasSX3 )->( dbSeek("SC5") )
       While !EOF() .And. ( _cAliasSX3 )->( X3_ARQUIVO ) = _cAlias
             If ( X3Uso( ( _cAliasSX3 )->( X3_USADO ) ) .AND. !( ( _cAliasSX3 )->( X3_CONTEXT ) = "V") .and. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_FILIAL")) .OR. ( ( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_COMIS1") .OR. ( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_VLRDUP" ) )
                cAux := alltrim(_cAlias)+"->"+( _cAliasSX3 )->( X3_CAMPO )
                do case
                   case ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_COMIS1"
                        xValor := nComis
                   case ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_VLRDUP"
                        xValor := _nVlrTotDup
                   otherwise
                        xValor := &cAux
                endcase
                if !empty(xValor)
                   aadd( aCabec, { ( _cAliasSX3 )->( X3_CAMPO ), xValor, .F. } )
                endif
             Endif
             dbSelectArea( _cAliasSX3 )
             ( _cAliasSX3 )->( dbSkip() )
       End
       DbSelectArea("SC5")
       MsgRun("Frete CIF...", "Aguarde", {|| MsExecAuto( { |x, y, z| MATA410(x, y, z) }, aCabec, aItens, 4 ) } )
       If lMsErroAuto
          lRet := !lMsErroAuto
          MostraErro()
       ENDIF

       DbSelectArea( _cAliasSX3 )
       DbCloseArea()

       DbSelectArea("SC5")
       dbsetorder(1)
       dbseek(xFilial("SC5")+_cPed)
Return(lRet)
