/* BUSCAS RAPIDAS Ctrl+L+<codigo abaixo>
   CODIGO   DESCRIÇÃO         
   000000 - Funções de Chamada das Telas Principais                                        
   000001 - Funções de Estorno
   000002 - Funções de Arquivos Temporários
   000003 - Funções de Gravação de Dados
   000004 - Funções de Validação
   000005 - Funções de Outras Chamadas                                                                                                
*/
#INCLUDE 'PROTHEUS.CH'                                          
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'FONT.CH'                   
#INCLUDE 'INKEY.CH'
#INCLUDE 'vkey.CH'
/*************************************************************************************************/
/*** 000000   F U N Ç Õ E S   D E   C H A M A D A   D A S   T E L A S    P R I N C I P A I S   ***/
    /*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
    ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
    ±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
    ±±³Programa  ³ BRPCPA08 ³ Autor ³ Luís G. de Souza      ³ Data ³ 05/05/09 ³±±
    ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
    ±±³Locacao   ³                  ³Contato ³                                ³±±
    ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
    ±±³Descricao ³ Apontamento de Ordens de produção                          ³±±
    ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
    ±±³Parametros³ 0101 - Empresa+Filial                                      ³±±
    ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
    ±±³Retorno   ³                                                            ³±±
    ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
    ±±³Aplicacao ³                                                            ³±±
    ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
    ±±³Uso       ³                                                            ³±±
    ±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
    ±±³Analista Resp.³  Data     ³                                            ³±±
    ±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
    ±±³ Tiago Lucio  ³ 28/02/14  ³   //Inclusão do campo para armazenar 	  ³±±
    ±±³ o status   do parametro                								  ³±± 
    ±±³ Tiago Lucio  ³ 28/02/14  ³   //Inclusão do tratamento para bloquear   ³±±
    ±±³ o exclusão da SD4 pelo parâmetro MV_XHABZZF no apontamento das OPs.   ³±±                                         
    ±±³              ³  /  /  ³                                               ³±±
    ±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
    ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
    ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
    User Function BRPCPA08 (cParInf)
         /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
         ±± Declaração de Variaveis Locais                                          ±±
         Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
		 Local cEnvArq     := GetEnvServer()
         Local cIniFile    := GetAdv97()
         Local cHasMapper  := Upper(GetPvProfString("DBAccess", "Mapper"      , "ON"   , cInIfile ))
         Local xConnect    := GetGlbValue("MYTOPCONNECT")
         //Local lSair       := .f.
         Local _cVerRPO    := GetRPORelease()
		 
		 // cParInf := "01010101 T1" // Apontamento Fábrica I
		 // cParInf := "01010101ET1" // Envase Fábrica I        -PA
         // cParInf := "01010101 T2" // Apontamento Fábrica II                                       
         // cParInf := "01010101ET2" // Envase Fábrica II    -PA
         
		  //cParInf := "01060101 T1" // Apontamento Dissoltex
		  //cParInf := "01060101ET1" // Envase Dissoltex  -PA
         
         /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
         ±± Declaração de Variaveis Private dos Objetos                             ±±
         Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
		 Private cDataBase :=       GetPvProfString("DBAccess", "DataBase"    , "ERROR", cInIfile )      
		 if cDataBase = "ERROR"
		    If _cVerRPO <= '12.1.017'
			   cDataBase := GetPvProfString(cEnvArq, "DBDATABASE"    , "ERROR", cInIfile ) 			         	
			Else
			   cDataBase := GetPvProfString("TOPCONNECT", "DATABASE"    , "ERROR", cInIfile )
			Endif
		 endif 		   
  		 Private cAlias    :=       GetPvProfString("DBAccess", "Alias"       , "ERROR", cInIfile )
		 if cAlias = "ERROR"
		    If _cVerRPO <= '12.1.017'
			   cAlias := GetPvProfString(cEnvArq, "DBALIAS"    , "ERROR", cInIfile )
			Else
			   cAlias := GetPvProfString('TOPCONNECT', "ALIAS"    , "ERROR", cInIfile )
			Endif 			         	
		 endif 		   
         Private nPort     := Val(  GetPvProfString("DBAccess", "Port"        , "0"    , cInIfile ))
		 if nPort = 0
		    If _cVerRPO <= '12.1.017'
			   nPort := Val(GetPvProfString(cEnvArq, "DBPORT"    , "0", cInIfile ) )
			Else
			   nPort := Val(GetPvProfString('TOPCONNECT', "PORT"    , "0", cInIfile ) )
			Endif			         	
		 endif 		   
  		 Private cProtect  :=       GetPvProfString("DBAccess", "ProtheusOnly", "0"    , cInIfile )
  		 If cProtect = "ERROR"
  		    If _cVerRPO <= '12.1.017'
  		       cProtect  :=       GetPvProfString("DBAccess", "ProtheusOnly", "0"    , cInIfile )
  		    Else
  		       cProtect  :=       GetPvProfString("TOPCONNECT", "ProtheusOnly", "0"    , cInIfile )
  		    Endif
  		 Endif
		 Private cServer   :=       GetPvProfString("DBAccess", "Server"      , "ERROR", cInIfile )
		 if cServer = "ERROR"
		    If _cVerRPO <= '12.1.017'
		 	   cServer := GetPvProfString(cEnvArq, "DBSERVER"    , "ERROR", cInIfile ) 			         	
		 	Else
		 	   cServer := GetPvProfString('TOPCONNECT', "SERVER"    , "ERROR", cInIfile )
		 	Endif
		 endif
  		 Private cConType  := Upper(GetPvProfString("DBAccess", "Contype"     , "TCPIP", cInIfile ))
  		 If cConType = "ERROR"
  		    If _cVerRPO <= '12.1.017'
  		       cConType  := Upper(GetPvProfString("DBAccess", "Contype"     , "TCPIP", cInIfile ))
		 	Else
		 	   cConType  := Upper(GetPvProfString("TOPCONNECT", "Contype"     , "TCPIP", cInIfile ))
		 	Endif
         Endif
         Private cVersion  := GetVersao(.F.)
         Private cGet1Apt  := Space(11)
         Private cGet2Apt  := Space(11)
         Private cSay1Apt  := Space(1)
         //Parâmetros para a função: 
         //Posição 01 a 02 - Empresa                                	
         //Posição 03 a 04 - Filial
         //Posição 05 a 05 - Envase  (Se tiver "E", buscar O.P.s para envase)
         //Posição 06 a 06 - Conexão (Se for igual a T tem que usar funções para abrir e fechar conexão com o Top Connect senão utiliza)
         //Posição 07 a 07 - Empresa para apontamento (1 ou 2, somente para cParInf1 = '01' e cParInf2 = '010101')
			if cParInf == Nil
				cParInf := "01010101ET2"
			endif          
         Private cParInf4  := Iif(cParInf == Nil, ""  , SubStr(cParInf,len(cParInf)-1, 1) )                                       //Envase
         Private cParInf1  := Iif(cParInf4 $ "T", Iif(cParInf == Nil, "01", SubStr(cParInf, 1, 2) ), cEmpAnt        ) //Empresa
         Private cParInf2  := Iif(cParInf4 $ "T", Iif(cParInf == Nil, "010101", SubStr(cParInf, 3, len(cParInf)-5) ), xFilial("ZZA") ) //Filial
         Private cParInf3  := Iif(cParInf == Nil, ""  , SubStr(cParInf, len(cParInf)-2, 1) )                                       //Envase
         Private cParInf5  := Iif(cParInf == Nil, ""  , SubStr(cParInf, len(cParInf), 1) )                                       //Empresa para apontamento
         Private aRotProd  := {}
         Private cNumOrd   := ""
         Private cNumLot   := ""
         Private cNumPro   := ""
         Private nPesoApu  := 0
         Private nQtdPro   := 0
         Private cNumRot   := ""
         Private cFlaOrd   := ""
         Private cTipPro   := ""
         Private nPesEsp   := 0
         Private cDesPro   := ""
         Private cProEst   := ""
         Private lJaGrvA   := .f. //Ordem de produção já foi iniciada na tabela ZZA
         Private cMarca    := 'XX'
         Private nPesTar   := 0
         Private dDatIni   := ""
         Private hHorIni   := ""
         Private cMaxTrt   := ""
         Private dDatPes   := ""
         Private hHorPes   := ""
         Private dDatCol   := ""
         Private hHorCol   := ""
         Private dDatLab   := ""
         Private hHorLab   := ""
         Private nVolTotPI := 0
         Private nVolFalt  := 0
         Private nVolPI    := 0
         Private oTempTab01
         Private oTempTab02
         Private oTempTab03
         Private oTempTab04
         Private _cMVULMES 
         Private _cMVCBAIRE
         Private _cMVXHABZZ

         SetPrvt("oFontApt", "oDlg1Apt", "oBtn1Apt", "oSay1Apt", "oGet1Apt")
         //LGS#20201231 - Descontinuação do programa de apontamento de produção.
		 If MsDate() >= CTOD('31/12/2020')
            MessageBox( 'Atenção, esse programa foi descontinuado. Solicitar ao PCP criar o novo atalho.', 'Descontinuado', 48 )
            Return
         Endif
         If !Empty(cParInf4)
            If Empty(xConnect) .OR. 'ERROR' $ xConnect
               // Ajuste pelo Environment do Server
               cDataBase :=       GetSrvProfString("TopDataBase"    , cDataBase)
               cAlias    :=       GetSrvProfString("TopAlias"       , cAlias)
               cServer	 :=       GetSrvProfString("TopServer"      , cServer)
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
               cServer	 :=     xConnect[3]
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
            cEnvArq := GetEnvServer()

            RpcSetType(3)     
            //LGS#20200302 - Ajuste da RPCSetEnv, colocando os parâmetros após as tabelas e adicionando a tabela ZZF 
            x := RpcSetEnv( cParInf1, cParInf2, , , cEnvArq, , {"SA1", "SX5", "SX6", "SB1", "SH6", "SX2", "SB2", "SD3", "ZZA", "SD1", "SD2", "ZZF" }, , , , .t. )  //ORIGINAL
            While !x
         	  	x := RpcSetEnv( cParInf1, cParInf2, , , cEnvArq, , {"SA1", "SX5", "SX6", "SB1", "SH6", "SX2", "SB2", "SD3", "ZZA", "SD1", "SD2", "ZZF" }, , , , .t. )
            Enddo 
         Endif
         _cMVULMES  := GETMV("MV_ULMES")   //LGS#20200204 - Adequação de release 12.1.25 e posteriores
         _cMVCBAIRE := GETMV("MV_CBAIREQ") //LGS#20200204 - Adequação de release 12.1.25 e posteriores
         _cMVXHABZZ := getMV("MV_XHABZZF") //LGS#20200204 - Adequação de release 12.1.25 e posteriores
         /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
         ±± Definicao do Dialog e todos os seus componentes.                        ±±
         Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
         If cParInf1+cParInf2 = '01010101'
            If Empty(cParInf5)
               MessageBox("Atenção, parâmetro que informa a fábrica, inválido.", "Verifique...",48)
               Return
            Else
               lVerFabrica := .T. //Aparece informação sobre a fábrica
            Endif
         Else
            lVerFabrica := .f. //Não aparece informação sobre a fábrica
         Endif
         oFontApt   := TFont():New( "MS Sans Serif", 0, -19, , .T., 0, , 700, .F., .F., , , , , , )
         oFont1Lc   := TFont():New( "Courier New"  , 0, -53, , .T., 0, , 700, .F., .F., , , , , , )
         oDlg1Apt   := MSDialog():New( 312, 391, 792, 691, "Apontamento de "+Iif(cParInf3 $ 'E', 'Envase', 'Produção')+" - v. 1.02", , , .F., , , , , , .T., , , .T. )
         oSay1Apt   := TSay():New( 004, 016, {|| "O.P.:"}, oDlg1Apt, , oFontApt, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 032, 012)
         oSay1Lcl   := TSay():New( 090, 008, {|| "FAB. - "+cParInf5 }, oDlg1Apt, , oFont1Lc, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 140, 036)
         If cParInf3 $ 'E'
            oSay1Env   := TSay():New( 130, 008, {|| " ENVASE" }, oDlg1Apt, , oFont1Lc, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 140, 036)
         Endif
         oGet1Apt   := TGet():New( 002, 052, {|u| If(PCount() > 0, cGet1Apt := u, cGet1Apt)}, oDlg1Apt, 076, 013, '@!R XXXXXX-99-999', , CLR_BLACK, CLR_WHITE, oFontApt, , , .T., "", , , .F., .F., , .F., .F., "", "cGet1Apt", , )
         oGet1Apt:bLostFocus := { || fVerOrdPro() }
         //A Linha abaixo não tem função, foi incluida para se manter compatibilidade.
         oGet2Apt   := TGet():New( 002, 202, {|u| If(PCount() > 0, cGet2Apt := u, cGet2Apt)}, oDlg1Apt, 006, 003, '@!R 999999-99-999', , CLR_BLACK, CLR_WHITE, oFontApt, , , .T., "", , , .F., .F., , .F., .F., "", "cGet2Apt", , )
         oBtnDApt   := TButton():New( 224, 108, "Sair", oDlg1Apt, , 037, 012, , , , .T., , "", , , , .F. )
         oBtnDApt:bAction  := {|| fAptSaiVol(1)}
         If lVerFabrica
            oSay1Lcl:lVisible := .T.
         Else
            oSay1Lcl:lVisible := .F.
         Endif

         oDlg1Apt:Activate(, , , .T.)
    Return

    /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ fAptIniPro() - Aponta inicio/ fim da pesagem
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Static Function fAptIniPro()
       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de cVariable dos componentes                                 ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       Local nOpcA        := 0
       Private cGet1Ini   := cNumOrd
       Private cGet1Fim   := cNumOrd
       Private cGet2Ini   := cNumLot
       Private cGet2Fim   := cNumLot
       Private nGet3Ini   := nQtdPro
       Private cGet4Ini   := cNumRot
       Private nGetLPes   := 0
       Private cGet5Ini   := cNumPro
       Private nGet5Fim   := nPesTar
       Private cGet3Fim   := cNumPro
       Private nGet6Ini   := nPesEsp
       Private cGet7Ini   := cDesPro
       Private cGet8Ini   := Space(6)
       Private nGet9Ini   := 0
       Private cGetAIni   := Space(30)
       Private cSay1Ini   := Space(1)
       Private cSay2Ini   := Space(1)
       Private cSay3Ini   := Space(1)
       Private cSay4Ini   := Space(1)
       Private cSay5Ini   := Space(1)
       Private cSay6Ini   := Space(1)
       Private cSay7Ini   := Space(1)
       Private cSay8Ini   := Space(1)
       Private cSay9Ini   := Space(1)
       Private cSayAIni   := Space(1)
       Private cSay1Fim   := Space(1)
       Private cSay2Fim   := Space(1)
       Private cSay3Fim   := Space(1)

       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de Variaveis Private dos Objetos                             ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       SetPrvt("oFontIni", "oDlg1Ini", "oGrp1Ini", "oSay1Ini", "oSay2Ini", "oSay3Ini", "oSay4Ini", "oGet1Ini", "oGet2Ini")
       SetPrvt("oGet4Ini", "oGrp2Ini", "oSay5Ini", "oSay6Ini", "oSay7Ini", "oGet5Ini", "oGet6Ini", "oGet7Ini", "oGrp3Ini")
       SetPrvt("oSay9Ini", "oSayAIni", "oGet8Ini", "oGet9Ini", "oGetAIni", "oBtn1Ini", "oBtn2Ini", "oFontFim", "oDlg1Fim")
       SetPrvt("oGrp1Fim", "oSay1Fim", "oSay2Fim", "oSay3Fim", "oGet1Fim", "oBtn2Fim", "oGet3Fim", "oBtn1Fim", "oBtn5Fim")
       SetPrvt("oBrw1Fim", "oGrp3Fim", "oGetLPes", "oGrp4Fim", "oGet5Fim", "oBtn6Fim")

       If cFlaOrd $ ' '
          /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
          ±± Definicao do Dialog e todos os seus componentes.                        ±±
          Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
          oFontIni   := TFont():New( "MS Sans Serif", 0, -19, , .F., 0, , 400, .F., .F., , , , , , )
          oDlg1Ini   := MSDialog():New( 095, 232, 456, 804, "Inicio de Produção", , , .F., , , , , , .T., , , .T. )
          oGrp1Ini   := TGroup():New( 004, 004, 052, 280, "Dados da Op.", oDlg1Ini, CLR_RED, CLR_WHITE, .T., .F. )
          oSay1Ini   := TSay():New( 012, 008, {|| "O. Produção:"}, oGrp1Ini, , oFontIni, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 060, 012)
          oGet1Ini   := TGet():New( 010, 072, {|u| If(PCount() > 0, cGet1Ini := u, cGet1Ini)}, oGrp1Ini, 072, 014, '@R XXXXXX-99-999', , CLR_BLACK, CLR_WHITE, oFontIni, , , .T., "", , , .F., .F., , .T., .F., "", "cGet1Ini", ,)
          oSay2Ini   := TSay():New( 012, 160, {|| "Lote:"}       , oGrp1Ini, , oFontIni, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 044, 012)
          oGet2Ini   := TGet():New( 010, 208, {|u| If(PCount() > 0, cGet2Ini := u, cGet2Ini)}, oGrp1Ini, 036, 014, '@R 999999'       , , CLR_BLACK, CLR_WHITE, oFontIni, , , .T., "", , , .F., .F., , .T., .F., "", "cGet2Ini", ,)
          oSay3Ini   := TSay():New( 033, 008, {|| "Quantidade:"} , oGrp1Ini, , oFontIni, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 060, 012)
          oGet3Ini   := TGet():New( 031, 072, {|u| If(PCount() > 0, nGet3Ini := u, nGet3Ini)}, oGrp1Ini, 060, 014, '@E 999,999.999'  , , CLR_BLACK, CLR_WHITE, oFontIni, , , .T., "", , , .F., .F., , .T., .F., "", "nGet3Ini", ,)
          oSay4Ini   := TSay():New( 033, 160, {|| "Roteiro:"}    , oGrp1Ini, , oFontIni, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 044, 012)
          oGet4Ini   := TGet():New( 031, 208, {|u| If(PCount() > 0, cGet4Ini := u, cGet4Ini)}, oGrp1Ini, 016, 014, '@R 99'           , , CLR_BLACK, CLR_WHITE, oFontIni, , , .T., "", , , .F., .F., , .T., .F., "", "cGet4Ini", ,)

          oGrp2Ini   := TGroup():New( 056, 004, 104, 280, "Dados do Produto", oDlg1Ini, CLR_RED, CLR_WHITE, .T., .F. )
          oSay5Ini   := TSay():New( 064, 008, {|| "Produto:"}  , oGrp2Ini, , oFontIni, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 060, 012)
          oGet5Ini   := TGet():New( 062, 072, {|u| If(PCount() > 0, cGet5Ini := u, cGet5Ini)}, oGrp2Ini, 080, 014, '@R XX 99.99.999-99', , CLR_BLACK, CLR_WHITE, oFontIni, , , .T., "", , , .F., .F., , .T., .F., "", "cGet5Ini", ,)
          oSay6Ini   := TSay():New( 064, 160, {|| "P. Espec.:"}, oGrp2Ini, , oFontIni, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 048, 012)
          oGet6Ini   := TGet():New( 062, 208, {|u| If(PCount() > 0, nGet6Ini := u, nGet6Ini)}, oGrp2Ini, 056, 014, '@E 9.999999'       , , CLR_BLACK, CLR_WHITE, oFontIni, , , .T., "", , , .F., .F., , .T., .F., "", "nGet6Ini", ,)
          oSay7Ini   := TSay():New( 085, 008, {|| "Descrição:"}, oGrp2Ini, , oFontIni, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 060, 012)
          oGet7Ini   := TGet():New( 083, 072, {|u| If(PCount() > 0, cGet7Ini := u, cGet7Ini)}, oGrp2Ini, 204, 014, '@!'                , , CLR_BLACK, CLR_WHITE, oFontIni, , , .T., "", , , .F., .F., , .T., .F., "", "cGet7Ini", ,)

          oGrp3Ini   := TGroup():New( 108,004,156,280,"Dados Complementares da O.P.",oDlg1Ini,CLR_RED,CLR_WHITE,.T.,.F. )
          oSay8Ini   := TSay():New( 116, 008, {|| "Recurso:"}  , oGrp3Ini, , oFontIni, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 060, 012)
          oGet8Ini   := TGet():New( 114, 072, {|u| If(PCount() > 0, cGet8Ini := u, cGet8Ini)}, oGrp3Ini, 040, 014, '@!'           , , CLR_BLACK, CLR_WHITE, oFontIni, , , .T., "", , , .F., .F., , .F., .F., "SH1", "cGet8Ini", ,)
          oSay9Ini   := TSay():New( 116, 160, {|| "Tara:"}     , oGrp3Ini, , oFontIni, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 044, 012)
          oGet9Ini   := TGet():New( 114, 208, {|u| If(PCount() > 0, nGet9Ini := u, nGet9Ini)}, oGrp3Ini, 060, 014, '@E 99,999.999', , CLR_BLACK, CLR_WHITE, oFontIni, , , .T., "", , , .F., .F., , .F., .F., ""   , "nGet9Ini", ,)
          oSayAIni   := TSay():New( 137, 008, {|| "Descrição:"}, oGrp3Ini, , oFontIni, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 060, 012)
          oGetAIni   := TGet():New( 135, 072, {|u| If(PCount() > 0, cGetAIni := u, cGetAIni)}, oGrp3Ini, 204, 014, ''             , , CLR_BLACK, CLR_WHITE, oFontIni, , , .T., "", , , .F., .F., , .T., .F., ""   , "cGetAIni", ,)

          oBtn1Ini   := TButton():New( 160, 004, "Abandona", oDlg1Ini, {|| nOpcA := 0, oDlg1Ini:End() }, 052, 012, , oFontIni, , .T., , "", , , , .F. )
          oBtn2Ini   := TButton():New( 160, 228, "Confirma", oDlg1Ini, {|| nOpcA := 1, oDlg1Ini:End() }, 052, 012, , oFontIni, , .T., , "", , , , .F. )
          oGet8Ini:SetFocus()
          oGet8Ini:bLostFocus := {|| fValRecTac() }
          oGet9Ini:bLostFocus := {|| fValTarTac() }

          oDlg1Ini:Activate(, , , .T.)
       Else
          /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
          ±± Definicao do Dialog e todos os seus componentes.                        ±±
          Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
          oFontFim   := TFont():New( "MS Sans Serif", 0, -19, , .F., 0, , 400, .F., .F., , , , , , )
          oFon2Fim   := TFont():New( "Courier New"  , 0,  19, , .T., 0, , 400, .F., .F., , , , , , )
          oDlg1Fim   := MSDialog():New( 303, 299, 764, 976, "Fim da Pesagem", , , .F., , , , , , .T., , , .T. )
          oGrp1Fim   := TGroup():New( 004, 004, 052, 336, "Dados da O.P.", oDlg1Fim, CLR_RED, CLR_WHITE, .T., .F. )
          oSay1Fim   := TSay():New( 012, 008, {|| "Ordem:"  }, oGrp1Fim, , oFontFim, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 052, 012)
          oGet1Fim   := TGet():New( 010, 052, {|u| If(PCount() > 0, cGet1Fim := u, cGet1Fim)}, oGrp1Fim, 072, 014, '@R XXXXXX-99-999', , CLR_BLACK, CLR_WHITE, oFontFim, , , .T., "", , , .F., .F., , .T., .F., "", "cGet1Fim", ,)
          oSay2Fim   := TSay():New( 012, 140, {|| "Lote:"   }, oGrp1Fim, , oFontFim, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 032, 012)
          oGet2Fim   := TGet():New( 010, 168, {|u| If(PCount() > 0, cGet2Fim := u, cGet2Fim)}, oGrp1Fim, 036, 014, '@R 999999', , CLR_BLACK, CLR_WHITE, oFontFim, , , .T., "", , , .F., .F., , .T., .F., "", "cGet2Fim", ,)
          oSay3Fim   := TSay():New( 033, 008, {|| "Produto:"}, oGrp1Fim, , oFontFim, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 056, 012)
          oGet3Fim   := TGet():New( 031, 052, {|u| If(PCount() > 0, cGet3Fim := u, cGet3Fim)}, oGrp1Fim, 080, 014, '@R XX 99.99.999-99', , CLR_BLACK, CLR_WHITE, oFontFim, , , .T., "", , , .F., .F., , .T., .F., "", "cGet3Fim", ,)
          oBtn1Fim   := TButton():New( 010, 264, "Confirma"   , oDlg1Fim, {|| nOpcA := 1, fFimPesPro(), oDlg1Fim:End() }, 052, 016, , oFontFim, , .T., , ""       , , , , .F. )
          oBtn2Fim   := TButton():New( 032, 264, "Abandona"   , oGrp1Fim, {|| nOpcA := 0, oDlg1Fim:End() }              , 052, 016, , oFontFim, , .T., , ""       , , , , .F. )
          oBtn3Fim   := TButton():New( 023, 319, "E"          , oDlg1Fim, {|| nOpcA := 2, fEstIniPes()   }              , 013, 012, , oFontFim, , .T., , "Estorna", , , , .F. )
          oTbl1Ger("FP") //Fim da Pesagem
          DbSelectArea("TMPEMP")
          DbSetOrder(1)
          oGrp2Fim   := TGroup():New( 052, 004, 172, 336, "", oDlg1Fim, CLR_BLACK, CLR_WHITE, .T., .F. )
          oBrw1Fim   := MsSelect():New( "TMPEMP", "MARC", "", { {"ITEM", "", "Item", "@!R XX 99.99.999-99"}, {"SEQU", "", "Seq.", "@R 999"}, {"QTSO", "", "Solicitada", "@E 999,999.9999"}, {"QTUS", "", "Usada", "@E 999,999.9999"}, {"DSCR", "", "Processo", "@!"} }, .F., @cMarca, {058, 007, 168, 260}, , , oGrp2Fim )
          oBrw1Fim:oBrowse:oFont              := oFon2Fim
          oBrw1Fim:obrowse:lAdjustColSize     := .t.
          oBtn4Fim   := TButton():New( 056, 271, "<<-- &Inclui", oGrp2Fim, {|| fMntEmpPro(0, "01")}, 053, 016, , oFontFim, , .T., , "", , , , .F. )
          oBtn5Fim   := TButton():New( 075, 271, "<<-- &Altera", oGrp2Fim, {|| fMntEmpPro(1, "01")}, 052, 016, , oFontFim, , .T., , "", , , , .F. )
          oBtn6Fim   := TButton():New( 095, 271, "<<-- &Exclui", oGrp2Fim, {|| fMntEmpPro(2, "01")}, 052, 016, , oFontFim, , .T., , "", , , , .F. )
          
          oGrp3Fim   := TGroup():New( 112, 264, 140, 332, "Peso Liquido", oGrp2Fim, CLR_RED, CLR_WHITE, .T., .F. )
          oGetLPes   := TGet():New( 119, 268, {|u| If(PCount() > 0, nGetLPes := u, nGetLPes)}, oGrp3Fim, 060, 014, '@E 999,999.999', , CLR_BLACK, CLR_WHITE, oFontFim, , , .T., "", , , .F., .F., , .T., .F., "", "nGetLPes", ,)
          oGrp4Fim   := TGroup():New( 140, 264, 168,332, "Tara", oGrp2Fim, CLR_RED, CLR_WHITE, .T., .F. )
          oGet5Fim   := TGet():New( 147, 268, {|u| If(PCount() > 0, nGet5Fim := u, nGet5Fim)}, oGrp4Fim, 060, 014, '@E 999,999.999', , CLR_BLACK, CLR_WHITE, oFontFim, , , .T., "", , , .F., .F., , .T., .F., "", "nGet5Fim", ,)

          oGrp5Fim   := TGroup():New( 172, 004, 230, 336, "", oDlg1Fim, CLR_BLACK, CLR_WHITE, .T., .F. )
          oTbl2Ger("FP")
          DbSelectArea("TMPFUN")
          DbSetOrder(1)
          oBrw2Fim   := MsSelect():New( "TMPFUN", "", "", { {"FUNFMA", "", "Matricula", "@!R 999999"}, {"FUNNOM", "", "Nome", "@!"} }, .F., , {176, 007, 227, 260}, , , oGrp5Fim ) 
          oBtn7Fim   := TButton():New( 176, 280, "Inclui", oGrp5Fim, {|| fMntFunApt("0", "01")}, 037, 012, , , , .T., , "", , , , .F. )
          oBtn9Fim   := TButton():New( 204, 280, "Exclui", oGrp5Fim, {|| fMntFunApt("1", "01")}, 037, 012, , , , .T., , "", , , , .F. )

          oDlg1Fim:Activate( , , , .T.)
       Endif
       If nOpcA == 0
          fAbaAptPro()        //Abandona apontamento do produto
          If !cFlaOrd $ ' '
             DbSelectArea("TMPEMP")
             DbCloseArea()
             oTempTab01:Delete()
             DbSelectArea("TMPFUN")
             DbCloseArea()
             oTempTab04:Delete()
          Endif
       ElseIf nOpcA == 1
              If cFlaOrd $ ' '
                 //Verificar estoque de produtos no inicio da produção
                 If Alltrim(GETMV("MV_VERESTIP")) $ 'S'
                    nOpcV := 0
                    oTbl1Ger("IP") //Inicio da Pesagem
                    oFontVer   := TFont():New( "MS Sans Serif", 0, -19, , .F., 0, , 400, .F., .F., , , , , , )
                    oFon1Ver   := TFont():New( "Courier New"  , 0,  19, , .T., 0, , 400, .F., .F., , , , , , )
                    oDlg1Ver   := MSDialog():New( 303, 299, 527, 945, "Informação do Estoque", , , .F., , , , , , .T., , , .T. )
                    oGrp1Ver   := TGroup():New( 004, 004, 098, 320, "", oDlg1Ver, CLR_BLACK, CLR_WHITE, .T., .F. )
                    oBrw1Ver   := MsSelect():New( "TMPEMP", "MARC", "", { {"ITEM", "", "Item", "@!R XX 99.99.999-99"}, {"LCBX", "", "LOCAL", "@!R X9"}, {"SEQU", "", "Seq.", "@R 999"}, {"QTSO", "", "Solicitada", "@E 999,999.9999"}, {"SLDE", "", "Estoque", "@E 999,999.999"}, {"SLDR", "", "Reserva", "@E 999,999.999"}, {"DISP", "", "Disponível", "@E 999,999.999"}, {"DSCR", "", "Processo", "@!"} }, .F., @cMarca, {010, 007, 092, 260}, , , oGrp1Ver )
                    oBrw1Ver:oBrowse:oFont              := oFon1Ver
                    oBrw1Ver:oBrowse:lAdjustColSize     := .t.
                    oSay1Ver   := TSay():New( 100, 004, {|| "Disponível = Estoque - Reserva - Solicitada" }, oGrp1Ver, , oFontVer, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 200, 012)
                    oBtn1Ver   := TButton():New( 010, 264, "Confirma"   , oGrp1Ver, {|| nOpcV := 1, oDlg1Ver:End() }, 052, 016, , oFontVer, , .T., , ""       , , , , .F. )
                    oBtn2Ver   := TButton():New( 032, 264, "Sair"       , oGrp1Ver, {|| nOpcV := 0, oDlg1Ver:End() }, 052, 016, , oFontVer, , .T., , ""       , , , , .F. )
                    oDlg1Ver:Activate( , , , .T.)
                    DbSelectArea("TMPEMP")
                    DbCloseArea()
                    oTempTab01:Delete()
                    If nOpcV == 0
                       Messagebox("Ordem de Produção não foi iniciada!","Atenção...",48) 
                       fAbaAptPro()
                    Else
					   fIniPesPro()					   
					   /*
					   If Alltrim(GETMV("MV_BLQOPSAL")) $ 'S'	
	                       If fBloqOpSal()
		                       fAbaAptPro()				                       
		                       Messagebox("Ordem de Produção não foi iniciada por falta de saldo disponível!","Atenção...",48) 
	    				   Else
		                       fIniPesPro() //Grava inicio da pesagem do produto
    					   Endif
    				   Else
	    				   fIniPesPro()
    				   Endif */
                    Endif 
                 Else
                    fIniPesPro() //Grava inicio da pesagem do produto
                 Endif
              Else
                 DbSelectArea("TMPEMP")
                 DbCloseArea()
                 If ValType( oTempTab01 ) == 'O'
				     oTempTab01:Delete()
				 Endif	 
                 DbSelectArea("TMPFUN")
                 DbCloseArea()
                 If ValType( oTempTab04 ) == 'O'
				     oTempTab04:Delete()
				 Endif	 
              Endif
       ElseIf nOpcA == 2
              DbSelectArea("TMPEMP")
              DbCloseArea()
              If ValType( oTempTab01 ) == 'O'
			      oTempTab01:Delete()
			  Endif	  
              DbSelectArea("TMPFUN")
              DbCloseArea()
              If ValType( oTempTab04 ) == 'O'
			      oTempTab04:Delete()
			  Endif	  
       Endif
    Return

    /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ fAptColPro() - Aponta Colorista
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Static Function fAptColPro()
       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de cVariable dos componentes                                 ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       Local nOpcA        := 0
       Private cGet1Col   := cNumOrd
       Private cGet2Col   := cNumLot
       Private cGet3Col   := cNumPro
       Private cSay1Col   := Space(1)
       Private cSay2Col   := Space(1)
       Private cSay3Col   := Space(1)
       Private cSay4Col   := Space(1)
       Private nCBox1Co   := ""
       Private nGetLPes   := 0
       Private nGet5Col   := nPesTar

       SetPrvt("oGrp1Col", "oSay1Col", "oSay2Col", "oSay3Col", "oGet1Col", "oBtn2Col", "oGet3Col", "oBtn1Col", "oBtn4Col")
       SetPrvt("oBrw1Col", "oFontCol", "oDlg1Col", "oCBox1Co", "oGrp3Col", "oGetLPes", "oGrp4Col", "oGet5Col", "oBtn5Col")
       SetPrvt("oBtn3Col", "oGrp5Col", "oBtn7Col", "oBtn8Col", "oBtn9Col", "oBrw2Col")

       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Definicao do Dialog e todos os seus componentes.                        ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       oFontCol   := TFont():New( "MS Sans Serif", 0, -19, , .F., 0, , 400, .F., .F., , , , , , )
       oFon2Col   := TFont():New( "Courier New"  , 0,  19, , .T., 0, , 400, .F., .F., , , , , , )
       oDlg1Col   := MSDialog():New( 303, 299, 764, 976, "Tingimento", , , .F., , , , , , .T., , , .T. )
       oGrp1Col   := TGroup():New( 004, 004, 052, 336, "Dados da O.P.", oDlg1Col, CLR_RED, CLR_WHITE, .T., .F. )
       oSay1Col   := TSay():New( 012, 008, {|| "Ordem:"  }, oGrp1Col, , oFontCol, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 052, 012)
       oGet1Col   := TGet():New( 010, 046, {|u| If(PCount() > 0, cGet1Col := u, cGet1Col)}, oGrp1Col, 072, 014, '@R XXXXXX-99-999', , CLR_BLACK, CLR_WHITE, oFontCol, , , .T., "", , , .F., .F., , .T., .F., "", "cGet1Col", ,)
       oSay2Col   := TSay():New( 012, 140, {|| "Lote:"   }, oGrp1Col, , oFontCol, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 032, 012)
       oGet2Col   := TGet():New( 010, 168, {|u| If(PCount() > 0, cGet2Col := u, cGet2Col)}, oGrp1Col, 036, 014, '@R 999999', , CLR_BLACK, CLR_WHITE, oFontCol, , , .T., "", , , .F., .F., , .T., .F., "", "cGet2Col", ,)
       oSay3Col   := TSay():New( 033, 008, {|| "Produto:"}, oGrp1Col, , oFontCol, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 056, 012)
       oGet3Col   := TGet():New( 031, 046, {|u| If(PCount() > 0, cGet3Col := u, cGet3Col)}, oGrp1Col, 080, 014, '@R XX 99.99.999-99', , CLR_BLACK, CLR_WHITE, oFontCol, , , .T., "", , , .F., .F., , .T., .F., "", "cGet3Col", ,)
       oSay4Col   := TSay():New( 032, 131, {|| "Libera?"}                                 , oGrp1Col, , oFontCol, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 032, 012)
       oCBox1Co   := TComboBox():New( 032, 168, {|u| If(PCount() > 0, nCBox1Co := u, nCBox1Co)}, {"", "Nao", "Sim"}, 036, 016, oGrp1Col, , , , CLR_BLACK, CLR_WHITE, .T., oFontCol, "", , , , ,  , , nCBox1Co )
       oBtn1Col   := TButton():New( 010, 264, "Confirma"   , oDlg1Col, {|| nOpcA := 1, lRet := fFimColPro(), Iif(lRet, oDlg1Col:End(), ) }, 052, 016, , oFontCol, , .T., , ""       , , , , .F. )
       oBtn2Col   := TButton():New( 032, 264, "Abandona"   , oGrp1Col, {|| nOpcA := 0, oDlg1Col:End()               }, 052, 016, , oFontCol, , .T., , ""       , , , , .F. )
       oBtn3Col   := TButton():New( 023, 319, "E"          , oDlg1Col, {|| nOpcA := 2, fEstFimPes()                 }, 013, 012, , oFontCol, , .T., , "Estorna", , , , .F. )
       oTbl1Ger("TG") //Tingimento
       DbSelectArea("TMPEMP")
       DbSetOrder(1)
       oGrp2Col   := TGroup():New( 052, 004, 172, 336, "", oDlg1Col, CLR_BLACK, CLR_WHITE, .T., .F. )
       oBrw1Col   := MsSelect():New( "TMPEMP", "MARC", "", { {"ITEM", "", "Item", "@!R XX 99.99.999-99"}, {"SEQU", "", "Seq.", "@R 999"}, {"QTSO", "", "Solicitada", "@E 999,999.9999"}, {"QTUS", "", "Usada", "@E 999,999.9999"}, {"DSCR", "", "Processo", "@!"} }, .F., @cMarca, {058, 007, 168, 260}, , , oGrp2Col )
       oBrw1Col:oBrowse:oFont              := oFon2Col
       oBrw1Col:obrowse:lAdjustColSize     := .t.
       oBtn4Col   := TButton():New( 056, 271, "<<-- &Inclui", oGrp2Col, {|| fMntEmpPro(0, "04")}, 053, 016, , oFontCol, , .T., , "", , , , .F. )
       oBtn5Col   := TButton():New( 075, 271, "<<-- &Altera", oGrp2Col, {|| fMntEmpPro(1, "04")}, 052, 016, , oFontCol, , .T., , "", , , , .F. )
       oBtn6Col   := TButton():New( 095, 271, "<<-- &Exclui", oGrp2Col, {|| fMntEmpPro(2, "04")}, 052, 016, , oFontCol, , .T., , "", , , , .F. )

       oGrp3Col   := TGroup():New( 112, 264, 140, 332, "Peso Liquido", oGrp2Col, CLR_RED, CLR_WHITE, .T., .F. )
       oGetLPes   := TGet():New( 119, 268, {|u| If(PCount() > 0, nGetLPes := u, nGetLPes)}, oGrp3Col, 060, 014, '@E 999,999.999', , CLR_BLACK, CLR_WHITE, oFontCol, , , .T., "", , , .F., .F., , .T., .F., "", "nGetLPes", ,)
       oGrp4Col   := TGroup():New( 140, 264, 168,332, "Tara", oGrp2Col, CLR_RED, CLR_WHITE, .T., .F. )
       oGet5Col   := TGet():New( 147, 268, {|u| If(PCount() > 0, nGet5Col := u, nGet5Col)}, oGrp4Col, 060, 014, '@E 999,999.999', , CLR_BLACK, CLR_WHITE, oFontCol, , , .T., "", , , .F., .F., , .T., .F., "", "nGet5Col", ,)

       oGrp5Col   := TGroup():New( 172, 004, 230, 336, "", oDlg1Col, CLR_BLACK, CLR_WHITE, .T., .F. )
       oTbl2Ger("TG")
       DbSelectArea("TMPFUN")
       DbSetOrder(1)
       oBrw2Col   := MsSelect():New( "TMPFUN", "", "", { {"FUNFMA", "", "Matricula", "@!R 999999"}, {"FUNNOM", "", "Nome", "@!"} }, .F., , {176, 007, 227, 260}, , , oGrp5Col ) 
       oBtn7Col   := TButton():New( 176, 280, "Inclui", oGrp5Col, {|| fMntFunApt("0", "04")}, 037, 012, , , , .T., , "", , , , .F. )
       oBtn9Col   := TButton():New( 204, 280, "Exclui", oGrp5Col, {|| fMntFunApt("1", "04")}, 037, 012, , , , .T., , "", , , , .F. )

       oDlg1Col:Activate( , , , .T.)
       If nOpcA == 0
          fAbaAptPro() //Abandona apontamento do produto
          If !cFlaOrd $ ' '
             DbSelectArea("TMPEMP")
             DbCloseArea()
             If ValType( oTempTab01 ) == 'O'
                 oTempTab01:Delete()
			 Endif			 
			 DbSelectArea("TMPFUN")
             DbCloseArea()
   		     If ValType( oTempTab04 ) == 'O'
                 oTempTab04:Delete()
			 Endif
          Endif
       ElseIf nOpcA == 1
              //Grava colorista
              DbSelectArea("TMPEMP")
              DbCloseArea()
			  If ValType( oTempTab01 ) == 'O'	
			      oTempTab01:Delete()
			  Endif	
              DbSelectArea("TMPFUN")
              DbCloseArea()
			  If ValType( oTempTab04 ) == 'O'
                  oTempTab04:Delete()
			  Endif
       ElseIf nOpcA == 2 //Estorno Colorista
              DbSelectArea("TMPEMP")
              DbCloseArea()
              If ValType( oTempTab01 ) == 'O'	
			      oTempTab01:Delete()
			  Endif	  
              DbSelectArea("TMPFUN")
              DbCloseArea()
              If ValType( oTempTab04 ) == 'O'	
			      oTempTab04:Delete()
			  Endif	  
       Endif
    Return

    /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ fAptLabPro() - Aponta Laboratorio
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Static Function fAptLabPro()
       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de cVariable dos componentes                                 ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       Local nOpcA        := 0
       Private cGet1Lab   := cNumOrd
       Private cGet2Lab   := cNumLot
       Private cGet3Lab   := cNumPro
       Private nGet4Lab   := nPesEsp
       Private nGet5Lab   := nQtdPro
       Private nGet6Lab   := nQtdPro
       Private nGet7Lab   := nPesEsp
       Private nGet9Lab   := nPesTar
       Private nGetALab   := 0
       Private cSay1Lab   := Space(1)
       Private cSay2Lab   := Space(1)
       Private cSay3Lab   := Space(1)
       Private cSay4Lab   := Space(1)
       Private cSay5Lab   := Space(1)
       Private cSay6Lab   := Space(1)
       Private nGetLPes   := 0
       Private cRetSup    := space(15)

       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de Variaveis Private dos Objetos                             ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       SetPrvt("oFontLab", "oDlg1Lab", "oGrp3Lab", "oGet7Lab", "oGrp5Lab", "oGet9Lab", "oGrp1Lab", "oSay1Lab", "oSay2Lab")
       SetPrvt("oSay4Lab", "oSay5Lab", "oSay6Lab", "oGet1Lab", "oBtn3Lab", "oGet3Lab", "oGet2Lab", "oGet4Lab", "oGet5Lab")
       SetPrvt("oBtn1Lab", "oGrp2Lab", "oBtn4Lab", "oBtn5Lab", "oBrw1Lab", "oBtn6Lab", "oBtn2Lab", "oGrp7Lab", "oBrw2Lab")
       SetPrvt("oBtn8Lab", "oGrp4Lab", "oGetLPes", "oGrp6Lab", "oGetALab", "oBtn9Lab")

       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Definicao do Dialog e todos os seus componentes.                        ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       oFontLab   := TFont():New( "MS Sans Serif", 0, -19, , .F., 0, , 400, .F., .F., , , , , , )
       oFon1Lab   := TFont():New( "MS Sans Serif", 0, -17, , .T., 0, , 400, .F., .F., , , , , , )
       oFon2Lab   := TFont():New( "Courier New"  , 0,  19, , .T., 0, , 400, .F., .F., , , , , , )
       oDlg1Lab   := MSDialog():New( 346, 278, 880, 1040, "Laboratorio", , , .F., , , , , , .T., , , .T. )
       oGrp1Lab   := TGroup():New( 004, 004, 076, 376, "Dados da O.P.", oDlg1Lab, CLR_RED, CLR_WHITE, .T., .F. )
       oSay1Lab   := TSay():New( 012, 008, {||"Ordem:"}         , oGrp1Lab, , oFontLab, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 040, 012)
       oGet1Lab   := TGet():New( 010, 064, {|u| If(PCount() > 0, cGet1Lab := u, cGet1Lab)}, oGrp1Lab, 075, 014, '@R XXXXXX-99-999'  , , CLR_BLACK, CLR_WHITE, oFontLab, , , .T., "", , , .F., .F., , .T., .F., "", "cGet1Lab", , )
       oSay2Lab   := TSay():New( 012, 152, {||"Lote:"}          , oGrp1Lab, , oFontLab, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 032, 012)
       oGet2Lab   := TGet():New( 010, 216, {|u| If(PCount() > 0, cGet2Lab := u, cGet2Lab)}, oGrp1Lab, 036, 014, '@R 999999'         , , CLR_BLACK, CLR_WHITE, oFontLab, , , .T., "", , , .F., .F., , .T., .F., "", "cGet2Lab", , )
       oSay3Lab   := TSay():New( 033, 008, {||"Produto:"}       , oGrp1Lab, , oFontLab, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 040, 012)
       oGet3Lab   := TGet():New( 031, 064, {|u| If(PCount() > 0, cGet3Lab := u, cGet3Lab)}, oGrp1Lab, 080, 014, '@R XX 99.99.999-99', , CLR_BLACK, CLR_WHITE, oFontLab, , , .T., "", , , .F., .F., , .T., .F., "", "cGet3Lab", , )
       oSay4Lab   := TSay():New( 033, 152, {||"P.E. (Teórico):"}, oGrp1Lab, , oFontLab, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 063, 012)
       oGet4Lab   := TGet():New( 031, 216, {|u| If(PCount() > 0, nGet4Lab := u, nGet4Lab)}, oGrp1Lab, 060, 014, '@E 999.999999'     , , CLR_BLACK, CLR_WHITE, oFontLab, , , .T., "", , , .F., .F., , .T., .F., "", "nGet4Lab", , )
       oSay5Lab   := TSay():New( 054, 008, {||"Qtd. Sol. (L):"} , oGrp1Lab, , oFontLab, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 055, 012)
       oGet5Lab   := TGet():New( 052, 064, {|u| If(PCount() > 0, nGet5Lab := u, nGet5Lab)}, oGrp1Lab, 060, 014, '@E 999,999.999'    , , CLR_BLACK, CLR_WHITE, oFontLab, , , .T., "", , , .F., .F., , .T., .F., "", "nGet5Lab", , )
       oSay6Lab   := TSay():New( 055, 152, {||"Qtd. Apt. (L):"} , oGrp1Lab, , oFontLab, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 055, 012)
       oGet6Lab   := TGet():New( 052, 216, {|u| If(PCount() > 0, nGet6Lab := u, nGet6Lab)}, oGrp1Lab, 060, 014, '@E 999,999.999'    , , CLR_RED  , CLR_WHITE, oFontLab, , , .T., "", , , .F., .F., , .T., .F., "", "nGet6Lab", , )
       oBtn1Lab   := TButton():New( 010, 304, "Confirma"    , oDlg1Lab, {|| nOpcA := 1, lRet := fFimLabPro(), Iif(lRet, oDlg1Lab:End(), )  }, 052, 016, , oFontLab, , .T., , "", , , , .F. )
       oBtn2Lab   := TButton():New( 035, 359, "E"           , oDlg1Lab, {|| nOpcA := 2, fEstColPro()  }, 013, 012, , oFontLab, , .T., , "", , , , .F. )
       oBtn3Lab   := TButton():New( 054, 304, "Abandona"    , oGrp1Lab, {|| nOpcA := 0, oDlg1Lab:End()}, 052, 016, , oFontLab, , .T., , "", , , , .F. )

       oGrp2Lab   := TGroup():New( 080, 004, 200, 304, ""             , oDlg1Lab, CLR_BLACK, CLR_WHITE, .T., .F. )
       oTbl1Ger("LB") //Laboratório
       DbSelectArea("TMPEMP")
       DbSetOrder(1)
       oBrw1Lab   := MsSelect():New( "TMPEMP", "", "", { {"ITEM", "", "Item", "@!R XX 99.99.999-99"}, {"SEQU", "", "Sequencia", "@R 999"}, {"QTSO", "", "Qtde. Solicitada", "@E 999,999.9999"}, {"QTUS", "", "Qtde. Usada", "@E 999,999.9999"}, {"DSCR", "", "Processo", "@!"} }, .F., , {086, 007, 196, 240}, , , oGrp2Lab )
       oBrw1Lab:oBrowse:oFont              := oFon2Lab
       oBrw1Lab:obrowse:lAdjustColSize     := .t.
       oBtn4Lab   := TButton():New( 086, 245, "<<-- &Inclui", oGrp2Lab, { || fMntEmpPro(0, "90") }     , 053, 016, , oFontLab, , .T., , "", , , , .F. )
       oBtn5Lab   := TButton():New( 106, 245, "<<-- &Altera", oGrp2Lab, { || fMntEmpPro(1, "90") }     , 053, 016, , oFontLab, , .T., , "", , , , .F. )
       oBtn6Lab   := TButton():New( 126, 245, "<<-- &Exclui", oGrp2Lab, { || fMntEmpPro(2, "90") }     , 053, 016, , oFontLab, , .T., , "", , , , .F. )

       oGrp3Lab   := TGroup():New( 080, 308, 108, 376, "P.E. (Laboratório)", oDlg1Lab, CLR_RED, CLR_WHITE, .T., .F. )
       oGet7Lab   := TGet():New( 088, 312, {|u| If(PCount() > 0, nGet7Lab := u, nGet7Lab)}, oDlg1Lab, 052, 014, '@E 9.999999'   , , CLR_BLUE , CLR_HGRAY, oFon1Lab, , , .T., "", , , .F., .F., , .T., .F., "", "nGet7Lab", , )
       oGrp4Lab   := TGroup():New( 110, 308, 138, 376, "Peso Liquido"      , oDlg1Lab, CLR_RED, CLR_WHITE, .T., .F. )
       oGetLPes   := TGet():New( 118, 312, {|u| If(PCount() > 0, nGetLPes := u, nGetLPes)}, oDlg1Lab, 060, 014, '@E 999,999.999', , CLR_BLACK, CLR_WHITE, oFontLab, , , .T., "", , , .F., .F., , .T., .F., "", "nGetLPes", , )
       oGrp5Lab   := TGroup():New( 140, 308, 168, 376, "Tara"              , oDlg1Lab, CLR_RED, CLR_WHITE, .T., .F. )
       oGet9Lab   := TGet():New( 147, 312, {|u| If(PCount() > 0, nGet9Lab := u, nGet9Lab)}, oDlg1Lab, 060, 014, '@E 999,999.999', , CLR_BLACK, CLR_WHITE, oFontLab, , , .T., "", , , .F., .F., , .T., .F., "", "nGet9Lab", , )
       oGrp6Lab   := TGroup():New( 172, 308, 200, 376, "Peso Bruto"        , oDlg1Lab, CLR_RED, CLR_WHITE, .T., .F. )
       oGetALab   := TGet():New( 180, 312, {|u| If(PCount() > 0, nGetALab := u, nGetALab)}, oDlg1Lab, 055, 014, '@E 999,999.999', , CLR_BLUE , CLR_HGRAY, oFon1Lab, , , .T., "", , , .F., .F., , .T., .F., "", "nGetALab", , )
       oBtn9Lab   := TButton():New( 088, 366, "..."         , oGrp3Lab, {|| fMntValLab('0') }          , 009, 016, , oFontLab, , .T., , "", , , , .F. )
       oBtnALab   := TButton():New( 180, 366, "..."         , oGrp6Lab, {|| fMntValLab('1') }          , 009, 016, , oFontLab, , .T., , "", , , , .F. )

       oGrp7Lab   := TGroup():New( 204,004,262,304,"",oDlg1Lab,CLR_BLACK,CLR_WHITE,.T.,.F. )
       oTbl2Ger("LB")
       DbSelectArea("TMPFUN")
       DbSetOrder(1)
       oBrw2Lab   := MsSelect():New( "TMPFUN", "", "", { {"FUNFMA", "", "Matricula", "999999"}, {"FUNNOM", "", "Nome", "@!"} }, .F., , {208, 007, 259, 240}, , , oGrp7Lab )
       oBtn7Lab   := TButton():New( 212, 255, "Inclui", oGrp7Lab, { || fMntFunApt("0", "90") }, 037, 012, , , , .T., , "", , , , .F. )
       oBtn8Lab   := TButton():New( 242, 255, "Exclui", oGrp7Lab, { || fMntFunApt("1", "90") }, 037, 012, , , , .T., , "", , , , .F. )

       oDlg1Lab:Activate(,,,.T.)
       If nOpcA == 0
          fAbaAptPro() //Abandona apontamento do produto
          If !cFlaOrd $ ' '
             DbSelectArea("TMPEMP")
             DbCloseArea()
             If ValType( oTempTab01 ) == 'O'
			     oTempTab01:Delete()
			 Endif	 
             DbSelectArea("TMPFUN")
             DbCloseArea()
			 If ValType( oTempTab04 ) == 'O'
                 oTempTab04:Delete()
			 Endif	 
          Endif
       ElseIf nOpcA == 1
              //Grava Laboratório
              DbSelectArea("TMPEMP")
              DbCloseArea()
              If ValType( oTempTab01 ) == 'O'
			      oTempTab01:Delete()
			  Endif	  
              DbSelectArea("TMPFUN")
              DbCloseArea()
              If ValType( oTempTab04 ) == 'O'
			      oTempTab04:Delete()
			  Endif	  
       ElseIf nOpcA == 2
              DbSelectArea("TMPEMP")
              DbCloseArea()
              If ValType( oTempTab01 ) == 'O'
			      oTempTab01:Delete()
			  Endif 	  
              DbSelectArea("TMPFUN")
              DbCloseArea()
              If ValType( oTempTab04 ) == 'O'
			      oTempTab04:Delete()
			  Endif	  
       Endif
    Return
/*************************************************************************************************/

/*************************************************************************************************/
/*** 000001                   F U N Ç Õ E S     D E     E S T O R N O                          ***/
    /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ fEstIniPes() - Estorna o inicio da pesagem
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Static Function fEstIniPes()
           Local lConEst    := .t.
           Local lTemMovAnt := .f.
           If !fValPswEst()
              Return
           Endif
           If MsgYesNo("Confirma o estorno dessa O.P. como não iniciada?", "Estorno")
              //Verificar e estornar as baixas - SD3
              DbSelectArea("SD3")
              DbSetOrder(1)
              cQry1 := ""
              cQry1 += "SELECT SD3.D3_COD, SD3.D3_QUANT, SD3.D3_LOCAL, SD3.D3_EMISSAO, SD3.D3_TRT, SD3.D3_UM, SD3.D3_QUANT, SD3.D3_DOC "
              cQry1 += "FROM SD3"+cParInf1+"0 SD3 WITH (NOLOCK) "
              cQry1 += "WHERE SD3.D3_FILIAL  = '"+cParInf2+"' "
              cQry1 += "  AND SD3.D_E_L_E_T_ = '' "
              cQry1 += "  AND SD3.D3_OP      = '"+cNumOrd+"' "
              cQry1 += "  AND SD3.D3_ESTORNO = '' "
              TCQuery cQry1 ALIAS "TCQ" NEW
              DbSelectArea("TCQ")
              aIteMov := {}
              aAuxEst := {}
              iF GetMV("MV_XHABZZF",.F.,.F.)//Alteração 25/02/2014 Tiago Lucio/Chaus - Inclusão de MV para habilitar regra ZZF
	              While !Eof()
	              	//LGS#20200204 - Adequação de release 12.1.25 e posteriores
	              	//If GETMV("MV_ULMES") <= STOD(TCQ->D3_EMISSAO) //Verifica se está fora do limite do ultimo fechamento
	              	If _cMVULMES <= STOD(TCQ->D3_EMISSAO) //Verifica se está fora do limite do ultimo fechamento
	                	DbSelectArea("SD3")
	                    DbSeek(xFilial("SD3")+Alltrim(cNumOrd) + Space( 13 - Len( Alltrim(cNumOrd) ) )+TCQ->D3_COD, .t.)
	                    //LGS#20200204 - Adequação de release 12.1.25 e posteriores
	                    //aAuxEst := { {"D3_TM"     , GETMV("MV_CBAIREQ")                                     , NIL},;
	                    aAuxEst := { {"D3_TM"     , _cMVCBAIRE                                              , NIL},;
	                    			 {"D3_EMISSAO", STOD(TCQ->D3_EMISSAO)                                   , NIL},;
	                                 {"D3_COD"    , TCQ->D3_COD                                             , NIL},;
	                                 {"D3_TRT"    , TCQ->D3_TRT                                             , NIL},;
	                                 {"D3_UM"     , TCQca->D3_UM                                              , NIL},;
	                                 {"D3_DOC"    , TCQ->D3_DOC                                             , NIL},;
	                                 {"D3_LOCAL"  , TCQ->D3_LOCAL                                           , NIL},;
	                                 {"D3_QUANT"  , TCQ->D3_QUANT                                           , NIL},;
	                                 {"D3_OP"     , Alltrim(cNumOrd) + Space( 13 - Len( Alltrim(cNumOrd) ) ), NIL} }
	                	aAdd(aIteMov, aAuxEst)
	                Else
	                	lTemMovAnt := .t.
	                Endif
	                DbSelectArea("TCQ")
	              	DbSkip()
	              Enddo
	              DbSelectArea("TCQ")
	              DbCloseArea()
	              If lTemMovAnt
	                 Messagebox("Atenção existe movimento do mês anterior que não pode ser estornado.","Atenção...",48) 
	              Else
	                 //Executa o estorno dos itens baixados no SD3 e coloca o ZZF com flag de aguardando definição (9)
	                 If Len(aIteMov) > 0 //Se for > 0 significa que ja possui baixas no sistema 
	                    //LGS#20200204 - Adequação de release 12.1.25 e posteriores
	                    //aCabMov := { {"D3_TM"     , GETMV("MV_CBAIREQ"), NIL},;
	                    aCabMov := { {"D3_TM"     , _cMVCBAIRE         , NIL},;
	                                 {"D3_EMISSAO",      MsDate()      , NIL} }
	
	                    lMsErroAuto := .f.
	                    MSExecAuto({|x, y, z| MATA241(x, y, z)}, aCabMov, aIteMov, 6)
	                    If lMsErroAuto
	                       lConEst := .f.
	                    Endif  
	             EndIf//Fim alteração      
                 Endif
            	 If lConEst
                    //Ajustar Flag de itens empenhados.
                    cQry1 := "UPDATE ZZF010 SET ZZF_FLAG = '9', ZZF_OBS = SUBSTRING(ZZF_OBS, 1, 2)+' - Estornado' WHERE ZZF_FILIAL = '"+cParInf2+"' AND D_E_L_E_T_ = '' AND ZZF_ORDEM = '"+cNumOrd+"' AND ZZF_TIPEMP = 'P' AND ZZF_FLAG IN('1') "
                    XXX := TCSQLEXEC(cQry1)
                    If XXX <> 0
                       cNomArq := 'C:\TEMP\ERR'+DTOS(MsDate())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+'.ERR'
                       MemoWrit(cNomArq, cQry1)
                    Endif
              	 	cQry1 := ""
              	 	cQry1 += "SELECT ZZA.R_E_C_N_O_ AS NRECNO FROM ZZA"+cParInf1+"0 ZZA WITH (NOLOCK) "
              	 	cQry1 += "WHERE ZZA.ZZA_FILIAL = '"+cParInf2+"' "
              	 	cQry1 += "  AND ZZA.D_E_L_E_T_ = '' "
              	 	cQry1 += "  AND ZZA.ZZA_ORDEM = '"+SubStr(cGet1Ini, 1, 6)+"02"+SubStr(cGet1Ini, 9, 3)+"' "
              	 	TCQuery cQry1 ALIAS "TCQ" NEW
              	 	DbSelectArea("TCQ")
              	 	DbGoTop()
              	 	nQtdRec := TCQ->NRECNO
              	 	DbSelectArea("TCQ")
              	 	DbCloseArea()
              	 	If nQtdRec > 0
                  	 	cQry1 := ""
                 	 	cQry1 += "UPDATE "+RetSqlName("ZZA")+" "
                 	 	cQry1 += "SET D_E_L_E_T_ = '*', ZZA_HELP = '"+cParInf5+" - E90 - ESTORNADA EM "+Dtoc(dDataBase)+" às "+Time()+" ' "
                 	 	cQry1 += "WHERE ZZA_FILIAL = '"+cParInf2+"' "
                 	 	cQry1 += "  AND D_E_L_E_T_ = '' "
                 	 	cQry1 += "  AND R_E_C_N_O_ = '"+Str(nQtdRec, 10)
                 	 	XXX := TCSQLEXEC(cQry1)
                 	 	If XXX <> 0
                    	 	cNomArq := 'C:\TEMP\ERR'+DTOS(MsDate())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+'.ERR'
                    	 	MemoWrit(cNomArq, cQry1)
                 	 	Endif
              	 	Endif
              	 	cQry1 := ""
              	 	cQry1 += "SELECT ZZA.R_E_C_N_O_ AS NRECNO FROM ZZA"+cParInf1+"0 ZZA WITH (NOLOCK) "
              	 	cQry1 += "WHERE ZZA.ZZA_FILIAL = '"+cParInf2+"' "
              	 	cQry1 += "  AND ZZA.D_E_L_E_T_ = '' "
              	 	cQry1 += "  AND ZZA.ZZA_ORDEM = '"+cGet1Ini+"' "
              	 	TCQuery cQry1 ALIAS "TCQ" NEW
              	 	DbSelectArea("TCQ")
              	 	DbGoTop()
              	 	nQtdRec := TCQ->NRECNO
              	 	DbSelectArea("TCQ")
              	 	DbCloseArea()
              	 	If nQtdRec > 0
                 	 	cQry1 := ""
                 	 	cQry1 += "UPDATE "+RetSqlName("ZZA")+" "
                 	 	cQry1 += "SET D_E_L_E_T_ = '*', ZZA_HELP = '"+cParInf5+" - E01 - ESTORNADA EM "+Dtoc(dDataBase)+" às "+Time()+" ' "
                 	 	cQry1 += "WHERE ZZA_FILIAL = '"+cParInf2+"' "
                 	 	cQry1 += "  AND D_E_L_E_T_ = '' "
                 	 	cQry1 += "  AND R_E_C_N_O_ = "+Str(nQtdRec, 10)
                 	 	XXX := TCSQLEXEC(cQry1)
                 	 	If XXX <> 0
                    	 	cNomArq := 'C:\TEMP\ERR'+DTOS(MsDate())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+'.ERR'
                    	 	MemoWrit(cNomArq, cQry1)
                 	 	Endif
              	 	Endif
              	 	//Fechar tela de Fim de Pesagem
              	 	oDlg1Fim:End()
              	 	cGet1Apt := space(11)
              	 	oGet1Apt:SetFocus()
              	 	oGet1Apt:Refresh()
              	 	oBtnDApt:cCaption := "Sair"
              	 	oBtnDApt:bAction  := {|| fAptSaiVol(1)}
              	 	oBtnDApt:Refresh()
              	 	//oBtn1Apt:lVisible := .f.
              	 	//oBtn1Apt:Refresh()
              	 	oGet1Apt:lReadOnly := .f.
              	 	oGet1Apt:Refresh()
                 Else
                    Messagebox("Essa ordem de produção não pode ser estornada.","Atenção...",48) 
                 Endif
              Endif
           Endif
    Return

    /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ fEstFimPes() - Estorna o fim da pesagem
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Static Function fEstFimPes()
           Local lConEst    := .t.
           Local lTemMovAnt := .f.
           If !fValPswEst()
              Return
           Endif
           If MsgYesNo("Confirma o estorno dessa O.P. como não pesada?", "Estorno")
              //Verificar e estornar as baixas - SD3
              DbSelectArea("SD3")
              DbSetOrder(1)
              cQry1 := ""
              cQry1 += "SELECT SD3.D3_COD, SD3.D3_QUANT, SD3.D3_LOCAL, SD3.D3_EMISSAO, SD3.D3_TRT, SD3.D3_UM, SD3.D3_QUANT, SD3.D3_DOC "
              cQry1 += "FROM SD3"+cParInf1+"0 SD3 WITH (NOLOCK) "
              cQry1 += "WHERE SD3.D3_FILIAL  = '"+cParInf2+"' "
              cQry1 += "  AND SD3.D_E_L_E_T_ = '' "
              cQry1 += "  AND SD3.D3_OP      = '"+cNumOrd+"' "
              cQry1 += "  AND SD3.D3_ESTORNO = '' "
              TCQuery cQry1 ALIAS "TCQ" NEW
              DbSelectArea("TCQ")
              aIteMov := {}
              aAuxEst := {}
              While !Eof()
                    //LGS#20200204 - Adequação de release 12.1.25 e posteriores
                    //If GETMV("MV_ULMES") <= STOD(TCQ->D3_EMISSAO) //Verifica se está fora do limite do ultimo fechamento
                    If _cMVULMES <= STOD(TCQ->D3_EMISSAO) //Verifica se está fora do limite do ultimo fechamento
                       DbSelectArea("SD3")
                       DbSeek(xFilial("SD3")+Alltrim(cNumOrd) + Space( 13 - Len( Alltrim(cNumOrd) ) )+TCQ->D3_COD, .t.)
                       //LGS#20200204 - Adequação de release 12.1.25 e posteriores
                       //aAuxEst := { {"D3_TM"     , GETMV("MV_CBAIREQ")                                     , NIL},;
                       aAuxEst := { {"D3_TM"     , _cMVCBAIRE                                              , NIL},;
                                    {"D3_EMISSAO", STOD(TCQ->D3_EMISSAO)                                   , NIL},;
                                    {"D3_COD"    , TCQ->D3_COD                                             , NIL},;
                                    {"D3_TRT"    , TCQ->D3_TRT                                             , NIL},;
                                    {"D3_UM"     , TCQ->D3_UM                                              , NIL},;
                                    {"D3_DOC"    , TCQ->D3_DOC                                             , NIL},;
                                    {"D3_LOCAL"  , TCQ->D3_LOCAL                                           , NIL},;
                                    {"D3_QUANT"  , TCQ->D3_QUANT                                           , NIL},;
                                    {"D3_OP"     , Alltrim(cNumOrd) + Space( 13 - Len( Alltrim(cNumOrd) ) ), NIL} }
                       aAdd(aIteMov, aAuxEst)
                    Else
                       lTemMovAnt := .t.
                    Endif
                    DbSelectArea("TCQ")
                    DbSkip()
              Enddo
              DbSelectArea("TCQ")
              DbCloseArea()
              If lTemMovAnt
                 Messagebox("Atenção existe movimento do mês anterior que não pode ser estornado.","Atenção...",48) 
              Else
                 //Executa o estorno dos itens baixados no SD3 e coloca o ZZF com flag de aguardando definição (9)
                 If Len(aIteMov) > 0 //Se for > 0 significa que ja possui baixas no sistema 
                    //LGS#20200204 - Adequação de release 12.1.25 e posteriores
                    //aCabMov := { {"D3_TM"     , GETMV("MV_CBAIREQ"), NIL},;
                    aCabMov := { {"D3_TM"     , _cMVCBAIRE         , NIL},;
                                 {"D3_EMISSAO",      MsDate()      , NIL} }

                    lMsErroAuto := .f.
                    MSExecAuto({|x, y, z| MATA241(x, y, z)}, aCabMov, aIteMov, 6)
                    If lMsErroAuto
                       lConEst := .f.
                    Endif
                 Endif
                 If lConEst //Se conseguiu estornar, terminar as atualizações dos flags
                    //Ajustar Flag de itens empenhados.
                    cQry1 := "UPDATE ZZF010 SET ZZF_FLAG = '2', ZZF_OBS = SUBSTRING(ZZF_OBS, 1, 2)+' - Estornado' WHERE ZZF_FILIAL = '"+cParInf2+"' AND D_E_L_E_T_ = '' AND ZZF_ORDEM = '"+cNumOrd+"' AND ZZF_TIPEMP = 'P' AND ZZF_FLAG IN('1') "
                    XXX := TCSQLEXEC(cQry1)
                    If XXX <> 0
                       cNomArq := 'C:\TEMP\ERR'+DTOS(MsDate())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+'.ERR'
                       MemoWrit(cNomArq, cQry1)
                    Endif
                    //Ajustar Flag de baixa - ZZA
                    cQry1 := ""
                    cQry1 += "SELECT ZZA.ZZA_ORDEM, ZZA.ZZA_PRODUT, ROUND(SC2.C2_QUANT, 4) AS QUANT "
                    cQry1 += "FROM "+RetSqlName("ZZA")+" ZZA WITH (NOLOCK) "
                    cQry1 += "LEFT OUTER JOIN "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) ON SC2.C2_FILIAL = ZZA.ZZA_FILIAL AND SC2.C2_NUM = SUBSTRING(ZZA.ZZA_ORDEM, 1, 6) AND SC2.C2_ITEM = SUBSTRING(ZZA.ZZA_ORDEM, 7, 2) AND SC2.C2_SEQUEN = SUBSTRING(ZZA.ZZA_ORDEM, 9, 3) AND SC2.D_E_L_E_T_ = '' "
                    cQry1 += "WHERE ZZA.ZZA_FILIAL = '"+cParInf2+"' "
                    cQry1 += "  AND ZZA.D_E_L_E_T_ = '' "
                    cQry1 += "  AND ZZA_FLAG IN('2', 'Y') "
                    cQry1 += "  AND SUBSTRING(ZZA.ZZA_ORDEM, 1, 6) = '"+SubStr(cNumOrd, 1, 6)+"' "
                    TCQuery cQry1 ALIAS "TCQ" NEW
                    DbSelectArea("TCQ")
                    DbGoTop()
                    While !Eof()
                          If SubStr(TCQ->ZZA_ORDEM, 7, 2) $ '02' .and. TCQ->ZZA_FLAG $ '4' //Ordem de Produção de Concentrado
                             cQry1 := ""
                             cQry1 += "UPDATE "+RetSqlName("ZZA")+" "
                             cQry1 += "SET "
                             cQry1 += "    ZZA_DTFIM  = '', "
                             cQry1 += "    ZZA_HFIM   = '', "
                             cQry1 += "    ZZA_PESFIN = "+StrTran(TransForm(0 ,'@E 99999.9999'), ",", ".")+", "
                             cQry1 += "    ZZA_QUANT  = "+StrTran(TransForm(0 ,'@E 99999.9999'), ",", ".")+", "
                             cQry1 += "    ZZA_HELP   = '"+cParInf5+" - 01 - Inicio da pesagem' "
                             cQry1 += "    ZZA_CAMPO  = 'FAB"+cParInf5+"', "
                             cQry1 += "    ZZA_FLAG   = '1' "
                             cQry1 += "WHERE ZZA_FILIAL = '"+cParInf2+"' AND D_E_L_E_T_ = '' AND ZZA_ORDEM = '"+TCQ->ZZA_ORDEM+"' "
                          ElseIf SubStr(TCQ->ZZA_ORDEM, 7, 2) $ '01'
                                 cQry1 := ""
                                 cQry1 += "UPDATE "+RetSqlName("ZZA")+" "
                                 cQry1 += "SET "
                                 cQry1 += "    ZZA_DTPES = '', "
                                 cQry1 += "    ZZA_HPES  = '', "
                                 cQry1 += "    ZZA_PESPES = "+StrTran(TransForm(0, '@E 99999.99999'), ",", ".")+", "
                                 cQry1 += "    ZZA_HELP   = '"+cParInf5+" - 01 - Inicio da Pesagem', "
                                 cQry1 += "    ZZA_CAMPO  = 'FAB"+cParInf5+"', "
                                 cQry1 += "    ZZA_FLAG = '1' "
                                 cQry1 += "WHERE ZZA_FILIAL = '"+cParInf2+"' AND D_E_L_E_T_ = '' AND ZZA_ORDEM = '"+TCQ->ZZA_ORDEM+"' "
                          Endif
                          XXX := TCSQLExec(cQry1)
                          If XXX <> 0
                             cNomArq := 'C:\TEMP\ERR'+DTOS(MsDate())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+'.ERR'
                             MemoWrit(cNomArq, cQry1)
                          Endif
                          DbSelectArea("TCQ")
                          DbSkip()
                    Enddo
                    DbSelectArea("TCQ")
                    DbCloseArea()
                 Else
                    Messagebox("Essa ordem de produção não pode ser estornada.","Atenção...",48) 
                 Endif
              Endif
           Endif
           oDlg1Col:End()
           cGet1Apt := space(11)
           oGet1Apt:SetFocus()
           oGet1Apt:Refresh()
           oBtnDApt:cCaption := "Sair"
           oBtnDApt:bAction  := {|| fAptSaiVol(1)}
           oBtnDApt:Refresh()
           oGet1Apt:lReadOnly := .f.
           oGet1Apt:Refresh()
    Return
    
    /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ fEstColPro() - Estorna o colorista
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Static Function fEstColPro()
           Local lConEst := .t.
           Local aVerMov := {}
           Local _nY
           If !fValPswEst()
              Return
           Endif
           If MsgYesNo("Confirma o estorno dessa O.P. como não tingida?", "Estorno")
              //Verificar produtos que fizeram parte do Colorista
              msgstop("ROTINA NÃO TESTADA, AVISAR ANDRE DA INFORMÁTICA - RAMAL: 7046")
              DbSelectArea("ZZF")
              DbSetOrder(1)
              DbSeek(xFilial("ZZF")+cNumOrd, .T.)
              If Found()
                 While !Eof() .and. ZZF->ZZF_ORDEM == cNumOrd
                       If ZZF->ZZF_TIPEMP $ "C" .and. ZZF->ZZF_FLAG == '1'
                          //Estornar produtos que fizeram parte do Colorista - SD3
                          DbSelectArea("SD3")
                          DbSetOrder(1)
                          DbSeek(xFilial("SD3")+Alltrim(cNumOrd) + Space( 13 - Len( Alltrim(cNumOrd) ) )+ZZF->ZZF_CODIGO, .t.)
                          If Found()
                             If SD3->D3_TRT == ZZF->ZZF_TRT
                                //LGS#20200204 - Adequação de release 12.1.25 e posteriores
                                //If GETMV("MV_ULMES") <= STOD(SD3->D3_EMISSAO) //Verifica se está fora do limite do ultimo fechamento
                                If _cMVULMES <= STOD(SD3->D3_EMISSAO) //Verifica se está fora do limite do ultimo fechamento
                                   aAdd(aVerMov, {SD3->D3_EMISSAO, SD3->D3_COD, SD3->D3_TRT, SD3->D3_UM, SD3->D3_DOC, SD3->D3_LOCAL, SD3->D3_QUANT, Alltrim(cNumOrd) + Space( 13 - Len( Alltrim(cNumOrd) ) ), ""} )
                                Else
                                   MsgStop("Atenção a movimentação do Item/Sequencia: "+Alltrim(ZZF->ZZF_CODIGO)+" / "+ZZF->ZZF_TRT+" não pode ser realizada devida ao fechamento de estoque", "Atenção")
                                   lConEst := .f.
                                Endif
                             Endif
                          Endif
                       Endif
                       DbSelectArea("ZZF")
                       DbSkip()
                 EndDo
                 If lConEst
                    For _nY := 1 To Len(aVerMov)
                        //LGS#20200204 - Adequação de release 12.1.25 e posteriores
                        //aCabMov := { {"D3_TM"     , GETMV("MV_CBAIREQ")  , NIL},;
                        aCabMov := { {"D3_TM"     , _cMVCBAIRE           , NIL},;
                                     {"D3_EMISSAO", STOD(aVerMov[_nY][1]), NIL} }
                        aAuxMov := {}
                        aAuxMov := { {"D3_COD"    , aVerMov[_nY][2], NIL},;
                                     {"D3_TRT"    , aVerMov[_nY][3], NIL},;
                                     {"D3_UM"     , aVerMov[_nY][4], NIL},;
                                     {"D3_DOC"    , aVerMov[_nY][5], NIL},;
                                     {"D3_LOCAL"  , aVerMov[_nY][6], NIL},;
                                     {"D3_QUANT"  , aVerMov[_nY][7], NIL},;
                                     {"D3_OP"     , aVerMov[_nY][8], NIL} }
                        aAdd(aIteMov, aAuxMov)
                        lMsErroAuto := .f.
                        MSExecAuto({|x, y, z| MATA241(x, y, z)}, aCabMov, aIteMov, 6)
                        If lMsErroAuto
                           aVerMov[_nY][9] := "N"
                           lConEst := .f.
                        Else
                           aVerMov[_nY][9] := "S"
                        Endif
                    Next
                 Else
                    MsgStop("Atenção, um ou mais itens não podem ser estornados da movimentação.", "Atenção")
                    Return
                 Endif
              Endif
              //Voltar produtos que fizeram parte do Colorista - ZZF
              For _nY := 1 To Len(aVerMov)
                  If aVerMov[_nY][9] $ 'S'
                     DbSelectArea("ZZF")
                     DbSetOrder(1)
                     DbSeek(xFilial("ZZF")+aVerMov[_nY][8]+aVerMov[_nY][2]+aVerMov[_nY][3], .t.)
                     If Found()
                        RecLock("ZZF", .f.)
                           ZZF->ZZF_FLAG := "2"
                           ZZF->ZZF_OBS  := SubStr(ZZF->ZZF_OBS, 1, 1)
                        MsUnLock()
                        
                     Endif
                  Else
                     lConEst := .f.
                  Endif
              Next
              //Voltar Status para Colorista.
              If lConEst
                 DbSelectArea("ZZA")
                 DbSetOrder(2)
                 DbSeek(xFilial("ZZA")+cNumOrd, .t.)
                 If Found()
                    RecLock("ZZA", .f.)
                       ZZA->ZZA_FLAG  := '2'
                       ZZA->ZZA_DTCOL := CTOD("  /  /  ")
                       ZZA->ZZA_HCOL  := ""
                       ZZA->ZZA_HELP  := cParInf5+' - 04 - Tingimento'
                    MsUnLock()
                 Endif
              Else
                 MsgStop("Atenção, um ou mais itens não puderam ser estornados da movimentação.", "Atenção")
                 Return
              Endif*/
           Endif
           oDlg1Lab:End()
           cGet1Apt := space(11)
           oGet1Apt:SetFocus()
           oGet1Apt:Refresh()
           oBtnDApt:cCaption := "Sair"
           oBtnDApt:bAction  := {|| fAptSaiVol(1)}
           oBtnDApt:Refresh()
           //oBtn1Apt:lVisible := .f.
           //oBtn1Apt:Refresh()
           oGet1Apt:lReadOnly := .f.
           oGet1Apt:Refresh()
    Return
    
     /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ fEstLabPro() - Estorna o Laboratorio - Chamada pelo menu do sistema
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Static Function fEstLabPro()
           //Local lConEst := .t.
           Local nStatus := 1
           Local nOpcA   := 0
           /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
           ±± Declaração de cVariable dos componentes                                 ±±
           Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
           Private cGet1Est   := cNumOrd
           Private cGet2Est   := cNumLot
           Private cGet3Est   := cNumPro
           Private cGet4Est   := cDesPro
           Private cSay1Est   := Space(1)
           Private cSay2Est   := Space(1)
           Private cSay3Est   := Space(1)

           /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
           ±± Declaração de Variaveis Private dos Objetos                             ±±
           Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
           SetPrvt("oFontEst", "oDlg1Est", "oGrp1Est", "oSay1Est", "oSay2Est", "oSay3Est", "oGet1Est", "oGet2Est", "oGet3Est")
           SetPrvt("oBtn1Est", "oBtn2Est", "oBrw1Est")
           //Verificar se a Ordem de produção já foi encerrada.
           DbSelectArea("SC2")
           DbSetOrder(1)
           DbSeek(xFilial("SC2")+cNumOrd, .t.)
           If Found()
              //LGS#20200204 - Adequação de release 12.1.25 e posteriores
              //If !Empty(SC2->C2_DATRF) .and. GETMV("MV_ULMES") >= SC2->C2_DATRF
              If !Empty(SC2->C2_DATRF) .and. _cMVULMES >= SC2->C2_DATRF
                 Messagebox("Atenção, essa O.P., foi fechada no mês anterior, portanto não pode ser estornada!","Atenção...",48) 
                 cGet1Apt := space(11)
                 oGet1Apt:SetFocus()
                 oGet1Apt:Refresh()
                 oBtnDApt:cCaption := "Sair"
                 oBtnDApt:bAction  := {|| fAptSaiVol(1)}
                 oBtnDApt:Refresh()
                 oGet1Apt:lReadOnly := .f.
                 oGet1Apt:Refresh()
                 Return
              Endif
           Endif
           If MsgYesNo("Confirma o estorno dessa O.P. como Laboratório?", "Estorno")
              If !fValPswEst()
                 cGet1Apt := space(11)
                 oGet1Apt:SetFocus()
                 oGet1Apt:Refresh()
                 oBtnDApt:cCaption := "Sair"
                 oBtnDApt:bAction  := {|| fAptSaiVol(1)}
                 oBtnDApt:Refresh()
                 oGet1Apt:lReadOnly := .f.
                 oGet1Apt:Refresh()
                 Return
              Endif
              
              /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
              ±± Definicao do Dialog e todos os seus componentes.                        ±±
              Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
              MSGSTOP("ROTINA NÃO TESTADA, AVISAR GUSTAVO DA INFORMÁTICA - RAMAL: 7046")
              
              oFontEst   := TFont():New( "MS Sans Serif", 0, -19, , .T., 0, , 700, .F., .F., , , , , , )
              oDlg1Est   := MSDialog():New( 095, 232, 492, 931, "Estorno", , , .F., , , , , , .T., , , .T. )
              oGrp1Est   := TGroup():New( 003, 001, 053, 345, "", oDlg1Est, CLR_BLACK, CLR_WHITE, .T., .F. )
              oSay1Est   := TSay():New( 012, 005, {| | "Ordem:"  }, oGrp1Est, , oFontEst, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 044, 012)
              oSay2Est   := TSay():New( 012, 137, {| | "Lote:"   }, oGrp1Est, , oFontEst, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 040, 012)
              oSay3Est   := TSay():New( 035, 005, {| | "Produto:"}, oGrp1Est, , oFontEst, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 044, 012)
              oGet1Est   := TGet():New( 011, 050, {|u| If(PCount() > 0, cGet1Est := u, cGet1Est)}, oGrp1Est, 075, 014, '@R! XXXXXX-99-999'  , , CLR_BLACK, CLR_WHITE, oFontEst, , , .T., "", , , .F., .F., , .T., .F., "", "cGet1Est", , )
              oGet2Est   := TGet():New( 011, 169, {|u| If(PCount() > 0, cGet2Est := u, cGet2Est)}, oGrp1Est, 040, 014, '@R 999999'          , , CLR_BLACK, CLR_WHITE, oFontEst, , , .T., "", , , .F., .F., , .T., .F., "", "cGet2Est", , )
              oGet3Est   := TGet():New( 033, 049, {|u| If(PCount() > 0, cGet3Est := u, cGet3Est)}, oGrp1Est, 080, 014, '@!R XX 99.99.999-99', , CLR_BLACK, CLR_WHITE, oFontEst, , , .T., "", , , .F., .F., , .T., .F., "", "cGet3Est", , )
              oGet4Est   := TGet():New( 033, 133, {|u| If(PCount() > 0, cGet4Est := u, cGet4Est)}, oGrp1Est, 208, 014, '@!'                 , , CLR_BLACK, CLR_WHITE, oFontEst, , , .T., "", , , .F., .F., , .T., .F., "", "cGet4Est", , )
              oBtn1Est   := TButton():New( 154, 212, "Ver Status", oDlg1Est, { || nOpcA := 1, fValEstLab(@nStatus)}, 058, 012, , oFontEst, , .T., , "", , , , .F. )
              oBtn2Est   := TButton():New( 154, 287, "Sair"      , oDlg1Est, { || nOpcA := 0, oDlg1Est:End()      }, 058, 012, , oFontEst, , .T., , "", , , , .F. )
              oTbl1Est()
              DbSelectArea("TMPEST")
              DbSetOrder(1)
              DbGoTop()
              oBrw1Est   := MsSelect():New( "TMPEST", "", "", { {"TMPTIP", "", "TP", "@!"}, {"TMPENV", "", "E", "@!"}, {"TMPSEQ", "", "SEQ", "@R 99"}, {"TMPPRO", "", "Produto", "@R! XX 99.99.999-99"}, {"TMPQTD", "", "Qtde.", "@E 999,999.999"}, {"TMPHEL", "", "Observacao", ""}, {"TMPSTA", "", "Status", ""}}, .F., , {057, 001, 153, 345}, , , oDlg1Est )

              oDlg1Est:Activate(,,,.T.)
              If nOpcA == 0
                 DbSelectArea("TMPEST")
                 DbCloseArea()
                 oTempTab03:Delete()
              Endif
              cGet1Apt := space(11)
              oGet1Apt:SetFocus()
              oGet1Apt:Refresh()
              oBtnDApt:cCaption := "Sair"
              oBtnDApt:bAction  := {|| fAptSaiVol(1)}
              oBtnDApt:Refresh()
              oGet1Apt:lReadOnly := .f.
              oGet1Apt:Refresh()
           Else
              cGet1Apt := space(11)
              oGet1Apt:SetFocus()
              oGet1Apt:Refresh()
              oBtnDApt:cCaption := "Sair"
              oBtnDApt:bAction  := {|| fAptSaiVol(1)}
              oBtnDApt:Refresh()
              oGet1Apt:lReadOnly := .f.
              oGet1Apt:Refresh()
           Endif
    Return

Static Function fValEstLab(nStatus)
       Local cQry1 := ""
       If nStatus == 1
          nStatus += 1
          oBtn1Est:cCaption := "Confirma"
          DbSelectArea("TMPEST")
          DbSetOrder(2)
          DbGoTop()
          While !Eof()
                If TMPEST->TMPTIP $ 'PA'
                   If TMPEST->TMPFLG $ '6.7.8' //C-D-F
                      RecLock("TMPEST", .f.)
                         TMPEST->TMPSTA := "Ok - Pode estornar"
                   	  MsUnlock()	
                   Else
                      //Verificar data de estorno, fechamento e baixa, pegando o documento da baixa
                      cQry1 := ""
                      cQry1 += "SELECT * "
                      cQry1 += "FROM SD3"+cParInf1+"0 SD3 WITH (NOLOCK) "
                      cQry1 += "LEFT OUTER JOIN SH6"+cParInf1+"0 SH6 WITH (NOLOCK) ON SH6.H6_FILIAL = SD3.D3_FILIAL AND SH6.H6_OP = SD3.D3_OP AND SH6.H6_IDENT = SD3.D3_IDENT AND SH6.D_E_L_E_T_ = '' "
                      cQry1 += "WHERE SD3.D3_FILIAL  = '"+cParInf2+"' "
                      cQry1 += "  AND SD3.D_E_L_E_T_ = '' "
                      cQry1 += "  AND SD3.D3_OP      = '"+TMPEST->TMPOPS+"' "
                      cQry1 += "  AND SD3.D3_TM      = '010' "
                      cQry1 += "ORDER BY D3_NUMSEQ "
                      TCQuery cQry1 ALIAS "TCQ" NEW
                      lJaAchou := .f.
                      aJaAchou := {}
                      DbSelectArea("TCQ")
                      DbGoTop()
                      While !Eof()
                            If aScan(aJaAchou, TCQ->D3_IDENT ) == 0
                               If !lJaAchou
                                  //LGS#20200204 - Adequação de release 12.1.25 e posteriores
                                  //If Dtos(GETMV("MV_ULMES")) <= TCQ->D3_EMISSAO
                                  If Dtos( _cMVULMES ) <= TCQ->D3_EMISSAO
                                     RecLock("TMPEST", .f.)
                                        TMPEST->TMPSTA := "Ok - Pode estornar"
                                     lJaAchou := .t.
                                     aAdd(aJaAchou, TCQ->D3_IDENT)
                                  Else
                                     RecLock("TMPEST", .f.)
                                        TMPEST->TMPSTA := "DF - Não pode estornar"
                                  Endif
                                  MsUnLock()
                               Endif
                            Endif
                            DbSelectArea("TCQ")
                            DbSkip()
                      Enddo
                      DbSelectArea("TCQ")
                      DbCloseArea()
                   Endif
                Else
                   cQry1 += "SELECT * "
                   cQry1 += "FROM SD3"+cParInf1+"0 SD3 WITH (NOLOCK) "
                   cQry1 += "WHERE SD3.D3_FILIAL  = '"+cParInf2+"' "
                   cQry1 += "  AND SD3.D_E_L_E_T_ = '' "
                   cQry1 += "  AND SD3.D3_OP      = '"+TMPEST->TMPOPS+"' "
                   cQry1 += "  AND SD3.D3_TM      = '010' "
                   cQry1 += "  AND SD3.D3_ESTORNO <> 'S' "
                   cQry1 += "ORDER BY D3_NUMSEQ "
                   TCQuery cQry1 ALIAS "TCQ" NEW
                   DbSelectArea("TCQ")
                   DbGoTop()
                   nContReg := 0
                   While !Eof()
                         //LGS#20200204 - Adequação de release 12.1.25 e posteriores
                         //If Dtos(GETMV("MV_ULMES")) <= TCQ->D3_EMISSAO
                         If Dtos( _cMVULMES ) <= TCQ->D3_EMISSAO
                            nContReg += 1
                            RecLock("TMPEST", .f.)
                               TMPEST->TMPSTA := "Ok - Pode estornar"
                            MsUnLock()
                         Else
                            RecLock("TMPEST", .f.)
                               TMPEST->TMPSTA := "DF - Não pode estornar"
                            MsUnLock()
                         Endif
                         DbSelectArea("TCQ")
                         DbSkip()
                   Enddo
                   DbSelectArea("TCQ")
                   DbCloseArea()
                   If nContReg == 0
                      RecLock("TMPEST", .f.)
                         TMPEST->TMPSTA := "Ok - Pode estornar"
                      MsUnLock()
                   Endif
                Endif
                DbSelectArea("TMPEST")
                DbSkip()
          Enddo
          DbSelectArea("TMPEST")
          DbSetOrder(1)
          DbGoTop()
       Else
          DbSelectArea("TMPEST")
          DbSetOrder(1)
          DbGoTop()
          While !Eof() 
                If TMPEST->TMPFLG $ '4'
                   cQry1 := ""
                   cQry1 += "UPDATE "+RetSqlName("ZZA")+" SET ZZA_FLAG = '3' WHERE R_E_C_N_O_ = "+Str(TMPEST->TMPREG)
                   XXX := TCSQLExec(cQry1)
                   If XXX <> 0
                      cNomArq := 'C:\TEMP\ERR'+DTOS(MsDate())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+'.ERR'
                      MemoWrit(cNomArq, cQry1)
                   Endif
                Endif
                DbSelectArea("TMPEST")
                DbSkip()
          EndDo
          DbSelectArea("TMPEST")
          DbCloseArea()
          oTempTab03:Delete()
          oDlg1Est:End()
       Endif
       //estornar movimentos SD3
       //estornar movimentos ZZF
       //estornar movimentos ZZA
Return

/*************************************************************************************************/

/*************************************************************************************************/
/*** 000002     F U N Ç Õ E S     D E     A R Q U I V O S    T E M P O R A R I O S             ***/
    /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ oTbl1Est() - Cria temporario para o Alias: TMPEST
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Static Function oTbl1Est()
           Local aFds := {}
           //Local cTmp

           aAdd( aFds , {"TMPORD"  ,"C", 002, 000} )
           aAdd( aFds , {"TMPOPS"  ,"C", 013, 000} )
           aAdd( aFds , {"TMPTIP"  ,"C", 002, 000} )
           aAdd( aFds , {"TMPENV"  ,"C", 001, 000} )
           aAdd( aFds , {"TMPSEQ"  ,"C", 002, 000} )
           aAdd( aFds , {"TMPPRO"  ,"C", 015, 000} )
           aAdd( aFds , {"TMPQTD"  ,"N", 011, 003} )
           aAdd( aFds , {"TMPHEL"  ,"C", 020, 000} )
           aAdd( aFds , {"TMPSTA"  ,"C", 020, 000} )
           aAdd( aFds , {"TMPINV"  ,"C", 002, 000} )
           aAdd( aFds , {"TMPFLG"  ,"C", 001, 000} )
           aAdd( aFds , {"TMPREG"  ,"N", 010, 000} )

           /********************************************************************************************************************************/
           /*** BLOCO ALTERADO EM 18/11/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
           //cTmp := U_NovoArqTrab("dbf") //CriaTrab( , .F. )
           //DbCreate(cTmp+".dbf", aFds, "DBFCDXADS")
           //Use (cTmp+".Dbf") Alias TMPEST VIA "DBFCDXADS" New Exclusive
           //DbCreateIndex(cTmp+"_1.cdx", "TMPOPS+TMPORD", {||"TMPOPS+TMPORD"} )
           //DbCreateIndex(cTmp+"_2.cdx", "TMPINV"       , {||"TMPINV"} )

           //DbClearInd()
           //DbSetIndex(cTmp+"_1")
           //DbSetIndex(cTmp+"_2")
           oTempTab03 := FWTemporaryTable():New( "TMPEST" )
           oTemptab03:SetFields( aFds )
           oTempTab03:AddIndex( "cInd01", { "TMPOPS", "TMPORD" } )
           oTempTab03:AddIndex( "cInd02", { "TMPINV" } )
           oTempTab03:Create()

           /********************************************************************************************************************************/
           DbSetOrder(1)

           cQry1 := ""
           cQry1 += "SELECT SB1.B1_TIPO, ZZA.ZZA_SEQENV, ZZA.ZZA_PRODUT, ZZA.ZZA_QUANT, ZZA.ZZA_HELP, ZZA.ZZA_TPENVA, ZZA.ZZA_FLAG, ZZA.ZZA_ORDEM, ZZA.R_E_C_N_O_ "
           cQry1 += "FROM ZZA"+cParInf1+"0 ZZA WITH (NOLOCK) "
           cQry1 += "LEFT OUTER JOIN SB1"+cParInf1+"0 SB1 WITH (NOLOCK) ON SB1.B1_FILIAL = ZZA.ZZA_FILIAL AND SB1.B1_COD = ZZA.ZZA_PRODUT AND SB1.D_E_L_E_T_ = '' "
           cQry1 += "WHERE ZZA.ZZA_FILIAL = '"+cParInf2+"' "
           cQry1 += "  AND ZZA.D_E_L_E_T_ = '' "
           cQry1 += "  AND ZZA.ZZA_ORDEM = '"+cNumOrd+"' "
           cQry1 += "  AND ZZA.ZZA_LOTE  = '"+cNumLot+"' "
           cQry1 += "ORDER BY ZZA.R_E_C_N_O_ "
           TCQuery cQry1 ALIAS "TCQ" NEW
           nConOrd := 1
           DbSelectArea("TCQ")
           While !Eof()
                 RecLock("TMPEST", .t.)
                    TMPEST->TMPORD := StrZero(nConOrd, 3)
                    TMPEST->TMPTIP := TCQ->B1_TIPO
                    TMPEST->TMPENV := TCQ->ZZA_TPENVA
                    TMPEST->TMPSEQ := TCQ->ZZA_SEQENV
                    TMPEST->TMPPRO := TCQ->ZZA_PRODUT
                    TMPEST->TMPQTD := TCQ->ZZA_QUANT
                    TMPEST->TMPHEL := TCQ->ZZA_HELP
                    TMPEST->TMPSTA := ""
                    TMPEST->TMPINV := Inverte(StrZero(nConOrd, 3))
                    TMPEST->TMPFLG := TCQ->ZZA_FLAG
                    TMPEST->TMPOPS := TCQ->ZZA_ORDEM
                    TMPEST->TMPREG := TCQ->R_E_C_N_O_
                 MsUnLock()
                 nConOrd += 1
                 DbSelectArea("TCQ")
                 DbSkip()
           Enddo
           DbSelectArea("TCQ")
           DbCloseArea()
    Return

    /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ oTbl2Ger() - Cria temporario para o Alias: TMPFUN
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Static Function oTbl2Ger(cOpcFun)
           Local aFds := {}
           //Local cTmp

           If ChkFile("TMPFUN")
              DbSelectArea("TMPFUN")
              DbCloseArea()
              oTempTab04:Delete()
           Endif
           aAdd( aFds , {"FUNFMA", "C", 008, 000} )
           aAdd( aFds , {"FUNNOM", "C", 030, 000} )
           aAdd( aFds , {"FUNORD", "C", 013, 000} )
           aAdd( aFds , {"FUNSEQ", "C", 002, 000} )
           aAdd( aFds , {"FUNPRO", "C", 015, 000} )
           aAdd( aFds , {"FUNVIS", "C", 001, 000} )

           /********************************************************************************************************************************/
           /*** BLOCO ALTERADO EM 18/11/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
           //cTmp := U_NovoArqTrab("dbf") //CriaTrab( , .F. )
           //DbCreate(cTmp+".dbf", aFds, "DBFCDXADS")
           //Use (cTmp+".Dbf") Alias TMPFUN VIA "DBFCDXADS" New Exclusive
           //DbCreateIndex(cTmp+"_1.cdx", "FUNFMA"              , {||"FUNFMA"} )
           //DbCreateIndex(cTmp+"_2.cdx", "FUNFMA+FUNORD+FUNSEQ", {||"FUNFMA+FUNORD+FUNSEQ"} )
           //DbCreateIndex(cTmp+"_3.cdx", "FUNSEQ+FUNPRO"       , {||"FUNSEQ+FUNPRO"} )

           //DbClearInd()
           //DbSetIndex(cTmp+"_1")
           //DbSetIndex(cTmp+"_2")
           //DbSetIndex(cTmp+"_3")
           oTempTab04 := FWTemporaryTable():New( "TMPFUN" )
           oTemptab04:SetFields( aFds )
           oTempTab04:AddIndex( "cInd01", { "FUNFMA"                     } )
           oTempTab04:AddIndex( "cInd02", { "FUNFMA", "FUNORD", "FUNSEQ" } )
           oTempTab04:AddIndex( "cInd03", { "FUNSEQ", "FUNPRO"           } )
           oTempTab04:Create()
           
           /********************************************************************************************************************************/
           cFilFun := 'FUNVIS == "S"'
           MSFILTER(cFilFun)
           DbSetOrder(1)

           
           DbSelectArea("ZZG")
           DbSetOrder(1)
           DbSeek(xFilial("ZZG")+cNumOrd, .t.)
           If Found()
              While !Eof() .and. ZZG->ZZG_ORDEM == cNumOrd
                    //If ZZG->ZZG_TPUSER $ Iif(cOpcFun $ 'TG', 'C', Iif(cOpcFun $ 'FP', 'B', Iif(cOpcFun $ 'LB', 'L', 'E') ) ) //2.Y - Colorista, 1 - Balanceiro, 3 - Laboratório
                    If ZZG->ZZG_TPUSER $ Iif(cOpcFun $ 'TG', 'C', Iif(cOpcFun $ 'FP', 'B', Iif(cOpcFun $ 'LB', 'L', Iif(cOpcFun $ 'FY','Y', Iif(cOpcFun $ 'FZ', 'Z', 'E' ) ) ) ) )//2.Y - Colorista, 1 - Balanceiro, 3 - Laboratório
                       RecLock("TMPFUN", .t.)
                          TMPFUN->FUNFMA := ZZG->ZZG_FILMAT
                          TMPFUN->FUNNOM := ZZG->ZZG_NOME
                          TMPFUN->FUNORD := ZZG->ZZG_ORDEM
                          TMPFUN->FUNSEQ := ZZG->ZZG_SEQENV
                          TMPFUN->FUNPRO := ZZG->ZZG_PROENV
                          If ZZG->ZZG_TPUSER $ 'E'
                             TMPFUN->FUNVIS := "N"
                          Else
                             TMPFUN->FUNVIS := "S"
                          Endif
                       MsUnLock()
                    Endif
                    DbSelectArea("ZZG")
                    DbSkip()
              EndDo
           Endif
           DbSelectArea("TMPFUN")
           DbGoTop()
    Return

    /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ oTbl1Ger() - Cria temporario para o Alias: TMPEMP
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Static Function oTbl1Ger(cOpcPes) //Opção da pesquisa IP/FP/TG/LB
           Local aFds := {}
           //Local cTmp
           Local cAuxQry1 := ""
           Local cAuxQry2 := ""
           Local cTxtFil1 := ""
           aAdd( aFds , {"MARC", "C", 002, 000} )
           aAdd( aFds , {"ITEM", "C", 015, 000} )
           aAdd( aFds , {"SEQU", "C", 003, 000} )
           aAdd( aFds , {"QTSO", "N", 011, 004} )
           aAdd( aFds , {"QTUS", "N", 011, 004} )
           aAdd( aFds , {"TPEM", "C", 001, 000} )
           aAdd( aFds , {"ARMZ", "C", 002, 000} )
           aAdd( aFds , {"ACER", "N", 007, 003} )
           aAdd( aFds , {"DSCR", "C", 020, 000} )
           aAdd( aFds , {"VISI", "C", 001, 000} )
           aAdd( aFds , {"ORIG", "C", 002, 000} )
           aAdd( aFds , {"FLAG", "C", 001, 000} )
           aAdd( aFds , {"SLDE", "N", 014, 003} )
           aAdd( aFds , {"SLDR", "N", 014, 003} )
           aAdd( aFds , {"DISP", "N", 014, 003} )
           aAdd( aFds , {"LCBX", "C", 002, 000} )
           aAdd( aFds , {"INCL", "C", 002, 000} )
           aAdd( aFds , {"TIPO", "C", 002, 000} )

           /********************************************************************************************************************************/
           /*** BLOCO ALTERADO EM 18/11/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
           //cTmp := U_NovoArqTrab("dbf") //CriaTrab( , .F. )
           //dbcreate(cTmp+".dbf", aFds, "DBFCDXADS")
           //Use (cTmp+".Dbf") Alias TMPEMP VIA "DBFCDXADS" New Exclusive
           //DbCreateIndex(cTmp+"_1.cdx", "SEQU"     , {||"SEQU"} )
           //DbCreateIndex(cTmp+"_2.cdx", "ITEM+SEQU", {||"ITEM+SEQU"} )

           //DbClearInd()
           //DbSetIndex(cTmp+"_1")
           //DbSetIndex(cTmp+"_2")
           oTempTab01 := FWTemporaryTable():New( "TMPEMP" )
           oTemptab01:SetFields( aFds )
           oTempTab01:AddIndex( "cInd01", { "SEQU" } )
           oTempTab01:AddIndex( "cInd02", { "ITEM", "SEQU" } )
           oTempTab01:Create()
           /********************************************************************************************************************************/
           DbSetOrder(1)

           cFilBrw := 'VISI == "S"'
           MSFILTER(cFilBrw)

           If Len(Alltrim(cNumPro)) == 12
              cQry1 := ""
              cQry1 += "SELECT * "
              cQry1 += "FROM "+RetSqlName("SZ1")+" SZ1 WITH (NOLOCK) "
              cQry1 += "WHERE SZ1.Z1_FILIAL = '"+xFilial("SZ1")+"' "
              cQry1 += "  AND SZ1.D_E_L_E_T_ = '' "
              cQry1 += "  AND SZ1.Z1_LINHA = '"+SubStr(cNumPro, 4, 2)+"' "
              TCQuery cQry1 ALIAS "TCQ" NEW
              DbSelectArea("TCQ")
              DbGoTop()
              If !Empty(TCQ->Z1_PRODRET)
                 cAuxQry1 += "  AND SD4.D4_COD NOT IN('"+TCQ->Z1_PRODRET+"' "
                 cAuxQry2 += "  AND ZZF.ZZF_CODIGO NOT IN('"+TCQ->Z1_PRODRET+"' "
                 cTxtFil1 += "'"+TCQ->Z1_PRODRET
              Endif
              If !Empty(cAuxQry1)
                 If !Empty(TCQ->Z1_CODFILT)
                    cAuxQry1 += ", '"+TCQ->Z1_CODFILT+"') "
                    cAuxQry2 += ", '"+TCQ->Z1_CODFILT+"') "
                    cTxtFil1 += "."+TCQ->Z1_CODFILT+"'"
                 Else
                    cAuxQry1 += ") "
                    cAuxQry2 += ") "
                    cTxtFil1 += "'"
                 Endif
              Else
                 If !Empty(TCQ->Z1_CODFILT)
                    cAuxQry1 += "  AND SD4.D4_COD NOT IN('"+TCQ->Z1_CODFILT+"') "
                    cAuxQry2 += "  AND ZZF.ZZF_CODIGO NOT IN('"+TCQ->Z1_CODFILT+"') "
                    cTxtFil1 += "'"+TCQ->Z1_CODFILT+"'"
                 Endif
              Endif
              DbSelectArea("TCQ")
              DbCloseArea()
           Endif

           nGetLPes := 0
           cQry1 := ""
           cQry1 += "SELECT SD4.D4_COD, SD4.D4_TRT, ROUND(SD4.D4_QTDEORI, 4) AS D4_QTDEORI, SD4.D4_LOCAL, ROUND(SD4.D4_ACECOR, 4) AS D4_ACECOR, B2_QATU, B2_RESERVA "
           cQry1 += "FROM SD4"+cParInf1+"0 SD4 WITH (NOLOCK) "
           cQry1 += "LEFT OUTER JOIN SB2"+cParInf1+"0 SB2 WITH (NOLOCK) ON B2_FILIAL = D4_FILIAL AND B2_COD = D4_COD AND B2_LOCAL = D4_LOCAL AND SB2.D_E_L_E_T_ ='' "
           cQry1 += "WHERE SD4.D4_FILIAL = '"+cParInf2+"' "
           cQry1 += "  AND SD4.D_E_L_E_T_ = '' "
           cQry1 += "  AND SD4.D4_OP = '"+Substr(cNumOrd,1,11)+"' "
           cQry1 += "  AND SD4.D4_QUANT > 0.0 "
           If !Empty(cAuxQry1)
              cQry1 += cAuxQry1
           Endif
           cQry1 += "ORDER BY D4_TRT "
           TCQuery cQry1 ALIAS "TCQ" NEW
           DbSelectArea("TCQ")
           DbGoTop()
           While !Eof()                   //Alterei em 19/05/2010 para acertar alguns problemas com o acerto de cor.
                 If TCQ->D4_ACECOR > 0
                    RecLock("TMPEMP", .t.)
                       TMPEMP->ITEM := TCQ->D4_COD
                       TMPEMP->SEQU := TCQ->D4_TRT
                       TMPEMP->QTSO := TCQ->D4_ACECOR
                       TMPEMP->QTUS := TCQ->D4_ACECOR
                       TMPEMP->ARMZ := TCQ->D4_LOCAL
                       TMPEMP->ACER := TCQ->D4_ACECOR
                       TMPEMP->ORIG := "SA"                                      //Empenho Original S-Sim/A=Acerto de Cor
                       TMPEMP->VISI := "N"                                       //Não visivel pois é colorista sempre carrega no inicio/fim da pesagem.
                       TMPEMP->TPEM := "C"                                       //Colorista
                       TMPEMP->DSCR := "Tingimento"
                       TMPEMP->TIPO := Posicione("SB1", 1, xFilial("SB1")+TCQ->D4_COD, "B1_TIPO")
                       //TMPEMP->SLDE := Posicione("SB2", 1, xFilial("SB2")+TCQ->D4_COD+Iif(!cParInf5 $ '2', TMPEMP->LOCA, Iif(TMPEMP->LOCA == '99', '99', Iif(TMPEMP->TIPO $ 'MP', '10', '20' ) ) ), "B2_QATU"   ) //Saldo em estoque
                       //TMPEMP->SLDR := Posicione("SB2", 1, xFilial("SB2")+TCQ->D4_COD+Iif(!cParInf5 $ '2', TMPEMP->LOCA, Iif(TMPEMP->LOCA == '99', '99', Iif(TMPEMP->TIPO $ 'MP', '10', '20' ) ) ), "B2_RESERVA") //Saldo de Reserva para eventual pedido de venda
                       TMPEMP->SLDR := Posicione("SB2", 1, xFilial("SB2")+TCQ->D4_COD+Iif(TMPEMP->TIPO $ 'MP','01', Iif(TMPEMP->TIPO $ 'PI', '02', '03') ), "B2_RESERVA")
                       TMPEMP->SLDE := TCQ->B2_QATU
                       TMPEMP->DISP := TMPEMP->SLDE - TMPEMP->SLDR - TMPEMP->QTSO
                       //TMPEMP->LCBX := Iif(TMPEMP->LOCA == '99', '99', Iif( TMPEMP->TIPO $ 'MP', Iif( cParInf5 $ '1', '01', '10' ), Iif( TMPEMP->TIPO $ 'PI', Iif( cParInf5 $ '1', '02', '20' ), TMPEMP->LOCA ) ))
					   TMPEMP->LCBX := Iif(TMPEMP->ARMZ == '99', '99', Iif( TMPEMP->TIPO $ 'MP', Iif( cParInf5 $ '1', Iif( Posicione("SB1", 1, xFilial("SB1")+TCQ->D4_COD, "B1_LOCPAD") $ 'R1.R2', 'R1', '01'), Iif( Posicione("SB1", 1, xFilial("SB1")+TCQ->D4_COD, "B1_LOCPAD") $ 'R1.R2', 'R2', '10') ), Iif( TMPEMP->TIPO $ 'PI', Iif( cParInf5 $ '1', Iif( Posicione("SB1", 1, xFilial("SB1")+TCQ->D4_COD, "B1_LOCPAD") $ 'R1.R2', 'R1', '02'), Iif( Posicione("SB1", 1, xFilial("SB1")+TCQ->D4_COD, "B1_LOCPAD") $ 'R1.R2', 'R2', '20') ), TMPEMP->ARMZ ) ))					   
                    MsUnLock()
                 Endif                         // 4 - ZZF_FILIAL+ZZF_ORDEM+ZZF_CODIGO+ZZF_TRT 
                 If (TCQ->D4_QTDEORI > 0) // ALTERAÇÃO PARA GRAVAR TIPO DE EMPENHO DE ACORDO COM ZZF NO CAMPO TMPEMP->TPEM PARA CORRIGIR PROBLEMA DE DUPLICAÇÃO NA INCLUSÃO DE ITENS 
                    RecLock("TMPEMP", .t.)// NO PROCESSO DE TINGIMENTO E LABORATÓRIO - ANDRÉ 26-08-14
                       TMPEMP->ITEM := TCQ->D4_COD
                       TMPEMP->SEQU := TCQ->D4_TRT
                       TMPEMP->QTSO := TCQ->D4_QTDEORI
                       TMPEMP->QTUS := TCQ->D4_QTDEORI
                       TMPEMP->ARMZ := TCQ->D4_LOCAL
                       TMPEMP->ACER := 0
                       TMPEMP->ORIG := "SE"                                       //Empenho Original S-Sim/E=Empenho SD4
                       TMPEMP->VISI := "S"                                        //Visivel sempre na pesagem (Inicio da pesagem e fim da pesagem)
                       TMPEMP->TPEM := Iif((Posicione("ZZF", 4, xFilial("ZZF")+Substr(cNumOrd,1,11)+TCQ->D4_COD+TCQ->D4_TRT, "ZZF_TIPEMP") $ 'C.L'), Posicione("ZZF", 4, xFilial("ZZF")+Substr(cNumOrd,1,11)+TCQ->D4_COD+TCQ->D4_TRT, "ZZF_TIPEMP"),"P")                                        //Pesagem
                       TMPEMP->DSCR := Iif(TMPEMP->TPEM == "P", "Pesagem", Iif(TMPEMP->TPEM == "C", "Tingimento", "Laboratório"))//"Pesagem"
                       TMPEMP->TIPO := Posicione("SB1", 1, xFilial("SB1")+TCQ->D4_COD, "B1_TIPO")
                       //TMPEMP->SLDE := Posicione("SB2", 1, xFilial("SB1")+TCQ->D4_COD+Iif(!cParInf5 $ '2', TMPEMP->LOCA, Iif(TMPEMP->LOCA == '99', '99', ( StrZero( ( Val( TMPEMP->LOCA ) * 10 ), 2 ) ) ) ), "B2_QATU"   ) //Saldo em estoque
                       //TMPEMP->SLDR := Posicione("SB2", 1, xFilial("SB1")+TCQ->D4_COD+Iif(!cParInf5 $ '2', TMPEMP->LOCA, Iif(TMPEMP->LOCA == '99', '99', ( StrZero( ( Val( TMPEMP->LOCA ) * 10 ), 2 ) ) ) ), "B2_RESERVA") //Saldo de Reserva para eventual pedido de venda
                       TMPEMP->SLDE := TCQ->B2_QATU
                       TMPEMP->SLDR := TCQ->B2_RESERVA
                       TMPEMP->SLDR := Posicione("SB2", 1, xFilial("SB2")+TCQ->D4_COD+Iif(TMPEMP->TIPO $ 'MP','01', Iif(TMPEMP->TIPO $ 'PI', '02', '03') ), "B2_RESERVA")
                       TMPEMP->DISP := TMPEMP->SLDE - TMPEMP->SLDR - TMPEMP->QTSO
                       //TMPEMP->LCBX := Iif(TMPEMP->LOCA == '99', '99', Iif( TMPEMP->TIPO $ 'MP', Iif( cParInf5 $ '1', '01', '10' ), Iif( TMPEMP->TIPO $ 'PI', Iif( cParInf5 $ '1', '02', '20' ), TMPEMP->LOCA ) ))
					   TMPEMP->LCBX := Iif(TMPEMP->ARMZ == '99', '99', Iif( TMPEMP->TIPO $ 'MP', Iif( cParInf5 $ '1', Iif( Posicione("SB1", 1, xFilial("SB1")+TCQ->D4_COD, "B1_LOCPAD") $ 'R1.R2', 'R1', '01'), Iif( Posicione("SB1", 1, xFilial("SB1")+TCQ->D4_COD, "B1_LOCPAD") $ 'R1.R2', 'R2', '10') ), Iif( TMPEMP->TIPO $ 'PI', Iif( cParInf5 $ '1', Iif( Posicione("SB1", 1, xFilial("SB1")+TCQ->D4_COD, "B1_LOCPAD") $ 'R1.R2', 'R1', '02'), Iif( Posicione("SB1", 1, xFilial("SB1")+TCQ->D4_COD, "B1_LOCPAD") $ 'R1.R2', 'R2', '20') ), TMPEMP->ARMZ ) ))					   
                    MsUnLock()
                 Endif
                 cMaxTRT := Iif(Val(TCQ->D4_TRT) > Val(cMaxTrt), TCQ->D4_TRT, cMaxTrt)
                 nGetLPes += TCQ->D4_QTDEORI
                 DbSelectArea("TCQ")
                 DbSkip()
           EndDo
           DbSelectArea("TCQ")
           DbCloseArea()

           //b3) Recupera dados do empenho alterado só será utilizado se ouver estorno depois do fim da pesagem, antes nunca será utilizado.
           //DbSelectArea("SB2")
           
           cQry1 := ""
           cQry1 += "SELECT * "
           cQry1 += "FROM ZZF"+cParInf1+"0 ZZF WITH (NOLOCK) "
           cQry1 += "WHERE ZZF.ZZF_FILIAL = '"+cParInf2+"' "
           cQry1 += "  AND ZZF.D_E_L_E_T_ = '' "
           cQry1 += "  AND ZZF.ZZF_ORDEM  = '"+Substr(cNumOrd, 1, 11)+"' "
           If !Empty(cAuxQry2)
              cQry1 += cAuxQry2
           Endif
           cQry1 += "ORDER BY ZZF.ZZF_TRT "
           TCQuery cQry1 ALIAS "TCQ" NEW
           DbSelectArea("TCQ")
           DbGoTop()
           While !Eof()
                 DbSelectArea("TMPEMP")
                 DbSetOrder(2)
                 DbSeek(TCQ->ZZF_CODIGO+TCQ->ZZF_TRT, .t.)
                 If !Found()
                    RecLock("TMPEMP", .t.)
                       TMPEMP->ITEM := TCQ->ZZF_CODIGO
                       TMPEMP->SEQU := TCQ->ZZF_TRT
                       TMPEMP->QTSO := TCQ->ZZF_QTDUSA
                       TMPEMP->QTUS := TCQ->ZZF_QTDUSA
                       TMPEMP->TPEM := TCQ->ZZF_TIPEMP
                       TMPEMP->ARMZ := TCQ->ZZF_LOCAL
                       TMPEMP->FLAG := Iif(TCQ->ZZF_FLAG $ '9.5', '2', TCQ->ZZF_FLAG)
                       TMPEMP->ORIG := Iif(Empty(SubStr(TCQ->ZZF_OBS, 1, 2)), '  ', SubStr(TCQ->ZZF_OBS, 1, 2))
                       TMPEMP->SLDE := Posicione("SB2", 1, xFilial("SB1")+TCQ->ZZF_CODIGO+Iif(!cParInf5 $ '2', TMPEMP->ARMZ, Iif(TMPEMP->ARMZ == '99', '99', ( StrZero( ( Val( TMPEMP->ARMZ ) * 10 ), 2 ) ) ) ), "B2_QATU"   ) //Saldo em estoque
                       TMPEMP->SLDR := Posicione("SB2", 1, xFilial("SB1")+TCQ->ZZF_CODIGO+Iif(!cParInf5 $ '2', TMPEMP->ARMZ, Iif(TMPEMP->ARMZ == '99', '99', ( StrZero( ( Val( TMPEMP->ARMZ ) * 10 ), 2 ) ) ) ), "B2_RESERVA") //Saldo de Reserva para eventual pedido de venda
                       TMPEMP->DISP := TMPEMP->SLDE - TMPEMP->SLDR - TMPEMP->QTSO
                       TMPEMP->TIPO := Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZF_CODIGO, "B1_TIPO")
                       //TMPEMP->LCBX := Iif(TMPEMP->LOCA == '99', '99', Iif( TMPEMP->TIPO $ 'MP', Iif( cParInf5 $ '1', '01', '10' ), Iif( TMPEMP->TIPO $ 'PI', Iif( cParInf5 $ '1', '02', '20' ), TMPEMP->LOCA ) ))
                       TMPEMP->LCBX := Iif(TMPEMP->ARMZ == '99', '99', Iif( TMPEMP->TIPO $ 'MP', Iif( cParInf5 $ '1', Iif( Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZF_CODIGO, "B1_LOCPAD") $ 'R1.R2', 'R1', '01'), Iif( Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZF_CODIGO, "B1_LOCPAD") $ 'R1.R2', 'R2', '10') ), Iif( TMPEMP->TIPO $ 'PI', Iif( cParInf5 $ '1', Iif( Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZF_CODIGO, "B1_LOCPAD") $ 'R1.R2', 'R1', '02'), Iif( Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZF_CODIGO, "B1_LOCPAD") $ 'R1.R2', 'R2', '20') ), TMPEMP->ARMZ ) ))					   
                       If TMPEMP->QTSO == 0
                          TMPEMP->VISI := "N"
                       Else
                          TMPEMP->VISI := "S"
                       Endif
                       TMPEMP->DSCR := Iif(TCQ->ZZF_TIPEMP == "P", "Pesagem", Iif(TCQ->ZZF_TIPEMP == "C", "Tingimento", "Laboratório"))+'-'+Iif(TMPEMP->FLAG $ '1', 'BX', Iif(TMPEMP->FLAG $ '9', 'AD', 'AB') )
                       nGetLPes += TCQ->ZZF_QTDUSA
                 Else
                    If TMPEMP->TPEM == TCQ->ZZF_TIPEMP
                       RecLock("TMPEMP", .f.)
                          TMPEMP->DSCR := Iif(TCQ->ZZF_TIPEMP == "P", "Pesagem", Iif(TCQ->ZZF_TIPEMP == "C", "Tingimento", "Laboratório"))+'-'+Iif(TMPEMP->FLAG $ '1', 'BX', Iif(TMPEMP->FLAG $ '9', 'AD', 'AB') )
                          TMPEMP->TPEM := TCQ->ZZF_TIPEMP
                          TMPEMP->QTUS := TCQ->ZZF_QTDUSA
                          TMPEMP->DISP := TMPEMP->SLDE - TMPEMP->SLDR - TMPEMP->QTSO
                          TMPEMP->FLAG := Iif(TCQ->ZZF_FLAG $ '9.5', '2', TCQ->ZZF_FLAG)
                    Else 
                       RecLock("TMPEMP", .t.)
                          TMPEMP->ITEM := TCQ->ZZF_CODIGO
                          TMPEMP->SEQU := TCQ->ZZF_TRT
                          TMPEMP->QTSO := TCQ->ZZF_QTDUSA
                          TMPEMP->QTUS := TCQ->ZZF_QTDUSA
                          TMPEMP->TPEM := TCQ->ZZF_TIPEMP
                          TMPEMP->ARMZ := TCQ->ZZF_LOCAL
                          TMPEMP->FLAG := Iif(TCQ->ZZF_FLAG $ '9.5', '2', TCQ->ZZF_FLAG)
                          TMPEMP->ORIG := Iif(Empty(SubStr(TCQ->ZZF_OBS, 1, 2)), '  ', SubStr(TCQ->ZZF_OBS, 1, 2))
                          TMPEMP->SLDE := Posicione("SB2", 1, xFilial("SB1")+TCQ->ZZF_CODIGO+Iif(!cParInf5 $ '2', TMPEMP->ARMZ, Iif(TMPEMP->ARMZ == '99', '99', ( StrZero( ( Val( TMPEMP->ARMZ ) * 10 ), 2 ) ) ) ), "B2_QATU"   ) //Saldo em estoque
                          TMPEMP->SLDR := Posicione("SB2", 1, xFilial("SB1")+TCQ->ZZF_CODIGO+Iif(!cParInf5 $ '2', TMPEMP->ARMZ, Iif(TMPEMP->ARMZ == '99', '99', ( StrZero( ( Val( TMPEMP->ARMZ ) * 10 ), 2 ) ) ) ), "B2_RESERVA") //Saldo de Reserva para eventual pedido de venda
                          TMPEMP->DISP := TMPEMP->SLDE - TMPEMP->SLDR - TMPEMP->QTSO
                          TMPEMP->TIPO := Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZF_CODIGO, "B1_TIPO")
                          //TMPEMP->LCBX := Iif(TMPEMP->LOCA == '99', '99', Iif( TMPEMP->TIPO $ 'MP', Iif( cParInf5 $ '1', '01', '10' ), Iif( TMPEMP->TIPO $ 'PI', Iif( cParInf5 $ '1', '02', '20' ), TMPEMP->LOCA ) ))
						  TMPEMP->LCBX := Iif(TMPEMP->ARMZ == '99', '99', Iif( TMPEMP->TIPO $ 'MP', Iif( cParInf5 $ '1', Iif( Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZF_CODIGO, "B1_LOCPAD") $ 'R1.R2', 'R1', '01'), Iif( Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZF_CODIGO, "B1_LOCPAD") $ 'R1.R2', 'R2', '10') ), Iif( TMPEMP->TIPO $ 'PI', Iif( cParInf5 $ '1', Iif( Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZF_CODIGO, "B1_LOCPAD") $ 'R1.R2', 'R1', '02'), Iif( Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZF_CODIGO, "B1_LOCPAD") $ 'R1.R2', 'R2', '20') ), TMPEMP->ARMZ ) ))					   
                          If TMPEMP->QTSO == 0
                             TMPEMP->VISI := "N"
                          Else
                             TMPEMP->VISI := "S"
                          Endif
                          TMPEMP->DSCR := Iif(TCQ->ZZF_TIPEMP == "P", "Pesagem", Iif(TCQ->ZZF_TIPEMP == "C", "Tingimento", "Laboratório"))+'-'+Iif(TMPEMP->FLAG $ '1', 'BX', Iif(TMPEMP->FLAG $ '9', 'AD', 'AB') )
                          nGetLPes += TCQ->ZZF_QTDUSA
                    Endif
                 Endif
                 cMaxTRT := Iif(Val(TCQ->ZZF_TRT) > Val(cMaxTrt), TCQ->ZZF_TRT, cMaxTrt)
                 MsUnLock()
                 DbSelectArea("TCQ")
                 DbSkip()
           Enddo
           DbSelectArea("TCQ")
           DbCloseArea()
           
           If cFlaOrd $ '3.X'
              nGetALab   := nGetLPes + nGet9Lab
              If Len(Alltrim(cGet3Lab)) == 4 .or. Len(Alltrim(cGet3Lab)) == 5 .or. Len(Alltrim(cGet3Lab)) == 6 .or. (Len(Alltrim(cGet3Lab))== 12 .and. Substr(Alltrim(cGet3Lab),11,2)=='99')
                 nGet6Lab   := nGetLPes
                 oSay5Lab:cCaption := "Qtd. Sol.(K):"
                 oSay6Lab:cCaption := "Qtd. Apt.(K):"
              Else
                 nGet6Lab   := (nGetALab - nGet9Lab) / nGet7Lab
              Endif
           Endif
           DbSelectArea("TMPEMP")
           DbSetOrder(1)
           DbGoTop()  
           
    Return
/*************************************************************************************************/

/*************************************************************************************************/
/*** 000003       F U N Ç Õ E S     D E     G R A V A Ç Ã O    D E     D A D O S               ***/
    /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ fIniPesPro() - Grava inicio da pesagem do produto
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Static Function fIniPesPro()
           If !Empty(cGet8Ini)
              If nGet9Ini > 0
                 //Gravar Tabela ZZA mudando Status
                 //Verificar se existe Concentrado
                 cQry1 := "SELECT SC2.C2_NUM, SC2.C2_PRODUTO "
                 cQry1 += "FROM SC2"+cParInf1+"0 SC2 WITH (NOLOCK) "
                 cQry1 += "WHERE SC2.C2_FILIAL  = '"+cParInf2+"' "
                 cQry1 += "  AND SC2.D_E_L_E_T_ = '' "
                 cQry1 += "  AND SC2.C2_NUM = '"+SubStr(cGet1Ini, 1, 6)+"' "
                 cQry1 += "  AND SC2.C2_ITEM = '02' "
                 cQry1 += "  AND SC2.C2_SEQUEN = '"+SubStr(cGet1Ini, 9, 3)+"' "
                 TCQuery cQry1 ALIAS "TCQ" NEW
                 DbSelectArea("TCQ")
                 DbGoTop()
                 lTemInkM := Iif(Empty(TCQ->C2_NUM), .f., .t.)
                 cCodiCon := ""
                 cCodiCon := TCQ->C2_PRODUTO
                 DbSelectArea("TCQ")
                 DbCloseArea()

                 If !lJaGrvA //Se não exister a OP Gravada na tabela ZZA
                    //Buscar ultimo registro gravado
                    cQry1 := ""
                    cQry1 += "SELECT ISNULL(MAX(R_E_C_N_O_), 0) + 1 AS NRECNO FROM ZZA"+cParInf1+"0 WITH (NOLOCK) "
                    TCQuery cQry1 ALIAS "TCQ" NEW
                    DbSelectArea("TCQ")
                    DbGoTop()
                    nQtdRec := TCQ->NRECNO
                    DbSelectArea("TCQ")
                    DbCloseArea()

                    If lTemInkM
                       //Insere dados do Concentrado na tabela ZZA
                       cQry1 := ""
                       cQry1 += "INSERT INTO ZZA"+cParInf1+"0 "
                       cQry1 += "      (ZZA_FILIAL    , ZZA_ORDEM                                               , ZZA_LOTE      , ZZA_PRODUT    , ZZA_DTINI         , ZZA_HINI                                       , ZZA_TARA                                                    , ZZA_ID        , ZZA_FLAG, ZZA_SEQENV, R_E_C_N_O_          , ZZA_HELP, ZZA_CAMPO) "
                       cQry1 += "VALUES('"+cParInf2+"', '"+SubStr(cGet1Ini, 1, 6)+"02"+SubStr(cGet1Ini, 9, 3)+"', ''            , '"+cGet5Ini+"', '"+DTOS(Date())+"', '"+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+"', "+StrTran(TransForm(nGet9Ini, '@E 99999.99999'), ",", ".")+", '"+cGet8Ini+"', '1'     , '01'      , "+Str(nQtdRec, 10)+", '"+cParInf5+" - 01 - Ordem de produção concentrado iniciada', 'FAB"+cParInf5+"' ) "
                       XXX := TCSQLEXEC(cQry1)
                       If XXX <> 0
                          cNomArq := 'C:\TEMP\ERR'+DTOS(MsDate())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+'.ERR'
                          MemoWrit(cNomArq, cQry1)
                       Endif
                       nQtdRec += 1
                    Endif
                    //Insere dados da fórmula na tabela ZZA
                    cQry1 := ""
                    cQry1 += "INSERT INTO "+RetSqlName("ZZA")+" "
                    cQry1 += "      (ZZA_FILIAL    , ZZA_ORDEM                                                   , ZZA_LOTE      , ZZA_PRODUT    , ZZA_DTINI         , ZZA_HINI                                       , ZZA_TARA                                                    , ZZA_ID        , ZZA_FLAG, ZZA_SEQENV, R_E_C_N_O_, ZZA_HELP, ZZA_CAMPO) "
                    cQry1 += "VALUES('"+cParInf2+"', '"+SubStr(cGet1Ini, 1, 11)+"'                               , '"+cGet2Ini+"', '"+cGet5Ini+"', '"+DTOS(Date())+"', '"+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+"', "+StrTran(TransForm(nGet9Ini, '@E 99999.99999'), ",", ".")+", '"+cGet8Ini+"', '1'     , '01'      , "+Str(nQtdRec, 10)+", '"+cParInf5+" - 01 - Ordem de produção iniciada', 'FAB"+cParInf5+"' ) "
                    XXX := TCSQLEXEC(cQry1)
                    If XXX <> 0
                       cNomArq := 'C:\TEMP\ERR'+DTOS(MsDate())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+'.ERR'
                       MemoWrit(cNomArq, cQry1)
                    Endif
                 Else //Se exister a OP Gravada na tabela ZZA
                    If lTemInkM
                       cQry1 := ""
                       cQry1 += "SELECT ZZA.R_E_C_N_O_ AS NRECNO FROM ZZA"+cParInf1+"0 ZZA WITH (NOLOCK) "
                       cQry1 += "WHERE ZZA.ZZA_FILIAL = '"+cParInf2+"' "
                       cQry1 += "  AND ZZA.D_E_L_E_T_ = '' "
                       cQry1 += "  AND ZZA.ZZA_ORDEM = '"+SubStr(cGet1Ini, 1, 6)+"02"+SubStr(cGet1Ini, 9, 3)+"' "
                       TCQuery cQry1 ALIAS "TCQ" NEW
                       DbSelectArea("TCQ")
                       DbGoTop()
                       nQtdRec := TCQ->NRECNO
                       DbSelectArea("TCQ")
                       DbCloseArea()
                       cQry1 := ""
                       cQry1 += "UPDATE "+RetSqlName("ZZA")+" "
                       cQry1 += "SET ZZA_DTINI = '"+DTOS(Date())+"', "
                       cQry1 += "    ZZA_HINI  = '"+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+"', "
                       cQry1 += "    ZZA_TARA  = "+StrTran(TransForm(nGet9Ini, '@E 99999.99999'), ",", ".")+", "
                       cQry1 += "    ZZA_ID    = '"+cGet8Ini+"', "
                       cQry1 += "    ZZA_FLAG  = '1' "
                       cQry1 += "WHERE ZZA_FILIAL = '"+cParInf2+"' "
                       cQry1 += "  AND D_E_L_E_T_ = '' "
                       cQry1 += "  AND R_E_C_N_O_ = '"+Str(nQtdRec, 10)
                       XXX := TCSQLEXEC(cQry1)
                       If XXX <> 0
                          cNomArq := 'C:\TEMP\ERR'+DTOS(MsDate())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+'.ERR'
                          MemoWrit(cNomArq, cQry1)
                       Endif
                    Endif
                    cQry1 := ""
                    cQry1 += "SELECT ZZA.R_E_C_N_O_ AS NRECNO FROM ZZA"+cParInf1+"0 ZZA WITH (NOLOCK) "
                    cQry1 += "WHERE ZZA.ZZA_FILIAL = '"+cParInf2+"' "
                    cQry1 += "  AND ZZA.D_E_L_E_T_ = '' "
                    cQry1 += "  AND ZZA.ZZA_ORDEM = '"+cGet1Ini+"' "
                    TCQuery cQry1 ALIAS "TCQ" NEW
                    DbSelectArea("TCQ")
                    DbGoTop()
                    nQtdRec := TCQ->NRECNO
                    DbSelectArea("TCQ")
                    DbCloseArea()
                    cQry1 := ""
                    cQry1 += "UPDATE "+RetSqlName("ZZA")+" "
                    cQry1 += "SET ZZA_DTINI = '"+DTOS(Date())+"', "
                    cQry1 += "    ZZA_HINI  = '"+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+"', "
                    cQry1 += "    ZZA_TARA  = "+StrTran(TransForm(nGet9Ini, '@E 99999.99999'), ",", ".")+", "
                    cQry1 += "    ZZA_ID    = '"+cGet8Ini+"', "
                    cQry1 += "    ZZA_FLAG  = '1' "
                    cQry1 += "WHERE ZZA_FILIAL = '"+cParInf2+"' "
                    cQry1 += "  AND D_E_L_E_T_ = '' "
                    cQry1 += "  AND R_E_C_N_O_ = '"+Str(nQtdRec, 10)
                    XXX := TCSQLEXEC(cQry1)
                    If XXX <> 0
                       cNomArq := 'C:\TEMP\ERR'+DTOS(MsDate())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+'.ERR'
                       MemoWrit(cNomArq, cQry1)
                    Endif
                 Endif
                 //Fechar tela de Inicio
                 cGet1Apt := space(11)
                 oGet1Apt:SetFocus()
                 oGet1Apt:Refresh()
                 oBtnDApt:cCaption := "Sair"
                 oBtnDApt:bAction  := {|| fAptSaiVol(1)}
                 oBtnDApt:Refresh()
                 //oBtn1Apt:lVisible := .f.
                 //oBtn1Apt:Refresh()
                 oGet1Apt:lReadOnly := .f.
                 oGet1Apt:Refresh()
              Else
                 Messagebox("Atenção, Tara tem que ser maior do que zero. Verifique!!!","Atenção...",48)
                 oGet9Ini:SetFocus()
              Endif
           Else
              Messagebox("Atenção, recurso não foi apontado. Verifique!!!","Atenção...",48) 
              oGet8Ini:SetFocus()
           Endif
    Return

    /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ fFimPesPro() - Grava fim da pesagem do produto
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Static Function fFimPesPro()   
              
           cErrAltEmpRet := ""
   
           //Verificação das datas e horas de apontamento
           If dDataBase < dDatIni
              MessageBox("Atenção, a data do computador deve estar errada. Data menor que o processo anterior!", "Atenção...",48)
              Return .f.
           ElseIf dDataBase == dDatIni
                  If SubStr(Time(), 1, 5) < hHorIni
                     MessageBox("Atenção, a hora do computador deve estar errada. Hora menor que o processo anterior!", "Atenção...",48)
                     Return .f.
                  ElseIf SubStr(Time(), 1, 5) == hHorIni
                         Messagebox("Atenção, a hora não pode ser igual ao processo anterior!","Atenção...",48) 
                         Return .f.
                  Endif
           Endif

           //Verifica se os coloristas foram apontados
           DbSelectArea("TMPFUN")
           pack
           DbGoTop()
           If TMPFUN->(RecCount()) <= 0
              Messagebox("O balanceiro não foi apontado, verifique!!!","Atenção...",48) 
              Return .f.
           EndIf
           //Limpa registros de empenhos da pesagem
	           DbSelectArea("ZZF")
	           DbSetOrder(1)
	           DbSeek(xFilial("ZZF")+cNumOrd, .t.)
	           If Found()
	              While !Eof() .and. Alltrim(ZZF->ZZF_ORDEM) == Alltrim(cNumOrd) .and. !Substr(ZZF->ZZF_OBS,1,5) $ 'EST -' 
	                    If ZZF->ZZF_TIPEMP $ 'P' .and. ZZF->ZZF_FLAG == '2'
	                       RecLock("ZZF", .f.)
	                          DbDelete()
	                       MsUnLock()
	                      
	                    Endif
	                    DbSelectArea("ZZF")
	                    DbSkip()
	              Enddo
	           Endif
	           //Gravar dados dos empenhos ( *** Gravar dados da Pesagem, Gravar dados do Acerto de Cor(Colorista), Apagar informação do empenho(SD4) *** )
	           DbSelectArea("TMPEMP")
	           DBCLEARFILTER()
	           DbGoTop()
	           While !Eof() 
	                 //Inclusão do empenho na pesagem
	                 DbSelectArea("ZZF")
	                 DbSetOrder(4)
	                 DbSeek(xFilial("ZZF")+cNumOrd+TMPEMP->ITEM+TMPEMP->SEQU, .t.)
	                 If Found()
	                    If Empty(TMPEMP->INCL)
	                       If !TMPEMP->VISI $ 'E'  //Se for E - Exclusão, não há necessidade de incluir no ZZF (Isso acontece no final da pesagem.)
	                          If Substr(ZZF->ZZF_OBS,1,5) $ 'EST -'  // Se for estorno, ou seja, SD4 excluído, acatar as possíveis alterações nas quantidades.
								RecLock("ZZF", .f.)
	            	               	ZZF->ZZF_QTDORI := Round(TMPEMP->QTSO, 4)
	    	                       	ZZF->ZZF_QTDUSA := Round(TMPEMP->QTUS, 4)
		                          	ZZF->ZZF_OBS    := TMPEMP->ORIG+" / Aguardando."                                //Aguardando processar
								MsUnlock()
							  Else                          	
	                          	RecLock("ZZF", .t.)
	                           		ZZF->ZZF_FILIAL := xFilial("ZZF")
	                           		ZZF->ZZF_ORDEM  := cNumOrd
	                           		ZZF->ZZF_LOTE   := cNumLot
	                           		ZZF->ZZF_CODIGO := TMPEMP->ITEM
	                           		ZZF->ZZF_TRT    := TMPEMP->SEQU
	                           		ZZF->ZZF_QTDORI := Round(TMPEMP->QTSO, 4)
	                           		ZZF->ZZF_QTDUSA := Round(TMPEMP->QTUS, 4)
	                           		ZZF->ZZF_FLAG   := Iif(TMPEMP->TPEM $ "P", '2', '9')                            //Flag: 2 para ser baixado / 9 para aguardar processo.
	                           		ZZF->ZZF_TIPEMP := TMPEMP->TPEM                                                 //P=Pesagem, C=Colorista, L=Laboratorio
	                          		ZZF->ZZF_OBS    := TMPEMP->ORIG+" / Aguardando."                                //Aguardando processar
	                           		ZZF->ZZF_LOCAL  := Iif(cParInf5 $ '2', TMPEMP->LCBX, TMPEMP->ARMZ)              //Troca do local quanto apontamento for na fábrica 2 
	                           		//LGS#20200204 - Adequação de release 12.1.25 e posteriores
	                           		//ZZF->ZZF_XHABIL := getMV("MV_XHABZZF")	//alteração Tiago Lucio/Chaus --28/02/14
	                           		ZZF->ZZF_XHABIL := _cMVXHABZZ	//alteração Tiago Lucio/Chaus --28/02/14
	                          	MsUnLock() 
	                              
	                       	  Endif	
	                       Endif
	                    Else 
	                          If TMPEMP->QTUS == 0  
	                          	 RecLock("ZZF", .f.)
	                              	DbDelete()
	                             MsUnLock()    
	                          Else
	                             If ZZF->ZZF_FLAG == '2'
	                             	RecLock("ZZF", .f.)
	                                	ZZF_QTDUSA := Round(TMPEMP->QTUS,4)
	                                MsUnLock()                
	                             Endif
	                          Endif
	                       MsUnLock()
	                    Endif
	                 Else
	                    //Inclusão do empenho original
	                    If !TMPEMP->VISI $ 'E' //Se for E - Exclusão, não há necessidade de incluir no ZZF (Isso acontece no final da pesagem.)
	                       RecLock("ZZF", .t.)  
	                          DbSelectArea("SB1")
	                          SB1->(DBSetOrder(1))      
	                          SB1->(dbSeek(xFilial("SB1")+TMPEMP->ITEM))
	                          If ALLTRIM(SB1->B1_TIPO)=='MC'
	                            alert(ALLTRIM(SB1->B1_TIPO)+" "+ALLTRIM(SB1->B1_COD)+" "+ALLTRIM(SB1->B1_DESC))
	                          EndIf
	                          
	                          ZZF->ZZF_FILIAL := xFilial("ZZF")
	                          ZZF->ZZF_ORDEM  := cNumOrd
	                          ZZF->ZZF_LOTE   := cNumLot
	                          ZZF->ZZF_CODIGO := TMPEMP->ITEM
	                          ZZF->ZZF_TRT    := TMPEMP->SEQU
	                          ZZF->ZZF_QTDORI := Round(TMPEMP->QTSO, 4)
	                          ZZF->ZZF_QTDUSA := Round(TMPEMP->QTUS, 4)
	                          ZZF->ZZF_FLAG   := Iif(TMPEMP->TPEM $ "P", '2', '9')                            //Flag: 2 para ser baixado / 9 para aguardar processo.
	                          ZZF->ZZF_TIPEMP := TMPEMP->TPEM                                                 //P=Pesagem, C=Colorista, L=Laboratorio
	                          ZZF->ZZF_OBS    := TMPEMP->ORIG+" / Aguardando."                                //Aguardando processar
	                          ZZF->ZZF_LOCAL  := Iif(cParInf5 $ '2', TMPEMP->LCBX, TMPEMP->ARMZ)              //Troca do local quanto apontamento for na fábrica 2        
                              //LGS#20200204 - Adequação de release 12.1.25 e posteriores
	                          //ZZF->ZZF_XHABIL := getMV("MV_XHABZZF") //Inclusão do campo para armazenar status do parametro Tiago Lucio Chaus/28/02/14
	                          ZZF->ZZF_XHABIL := _cMVXHABZZ	//Inclusão do campo para armazenar status do parametro Tiago Lucio Chaus/28/02/14

	                          
	                       MsUnLock()
	                         
						Endif                    
	                    //Exclusão do item empenhado
	                    DbSelectArea("SD5")
	                    DbSelectArea("SD4")
	                    DbSetOrder(1)
	
	                    DbSeek(xFilial("SD4")+TMPEMP->ITEM+(Alltrim(cNumOrd) + Space( 13 - Len( Alltrim(cNumOrd) ) ))+TMPEMP->SEQU, .t.)
	                    If Found()
	                        //LGS#20200204 - Adequação de release 12.1.25 e posteriores
	                        //If GetMV("MV_XHABZZF") .or. TMPEMP->VISI $ 'E' //Alteração 25/02/2014 Tiago Lucio/Chaus - Inclusão de MV para habilitar regra ZZF
	                        If _cMVXHABZZ .or. TMPEMP->VISI $ 'E' //Alteração 25/02/2014 Tiago Lucio/Chaus - Inclusão de MV para habilitar regra ZZF
			                      // EXCLUINDO SD4010 QUANDO NA PESAGEM O ITEM FOR MESMO EXCLUÍDO. A FUNÇÃO ATUALIZSD4 NÃO ESTAVA EXCLUINDO NESTA PRIMEIRA ETAPA.
			                      
			                      lMsErroAuto := .f.
			                      aEmpMov     := {}
			                      aEmpMov := { {"D4_FILIAL", cParInf2    , NIL },;
			                      				{"D4_OP"    , Alltrim(cNumOrd) + Space( 13 - Len( Alltrim(cNumOrd) ) ) , NIL },;
			                          			{"D4_COD"   , TMPEMP->ITEM, NIL },;
			                             		{"D4_TRT"   , TMPEMP->SEQU, NIL } }
			                      MSExecAuto({|x, y| MATA380(x, y)}, aEmpMov, 5) //SigaAuto de Exclusão do empenho  */

/*		                       If TMPEMP->LOCA <> '99' //Produtos empenhados no local 99 são baixados juntamente com a ordem de produção.
		                         
			                          lMsErroAuto := .f.
			                          aEmpMov     := {}
			                          aEmpMov := { {"D4_FILIAL", cParInf2    , NIL },;
			                                       {"D4_OP"    , Alltrim(cNumOrd) + Space( 13 - Len( Alltrim(cNumOrd) ) ) , NIL },;
			                                       {"D4_COD"   , TMPEMP->ITEM, NIL },;
			                                       {"D4_TRT"   , TMPEMP->SEQU, NIL } }
			                          MSExecAuto({|x, y| MATA380(x, y)}, aEmpMov, 5)    //SigaAuto de Exclusão do empenho
			                      
		                       Else  // Produtos de uso Indireto - Almoxar 99
		                          If !TMPEMP->VISI $ 'E' .AND. (TMPEMP->QTUS <> SD4->D4_QUANT) // VERIFICAR SE HOUVE ALTERAÇÃO NA QUANTIDADE EMPENHADA
		                           	   
		                          		lMsErroAuto := .f.
		                           		aEmpMov     := {}
		                           		aEmpMov := { {"D4_FILIAL" , cParInf2    , NIL },;
		                              		          {"D4_OP"     , Alltrim(cNumOrd) + Space( 13 - Len( Alltrim(cNumOrd) ) ) , NIL },;
		                               		          {"D4_COD"    , TMPEMP->ITEM, NIL },;
		                               		   	      {"D4_TRT"    , TMPEMP->SEQU, NIL },;
		                               	        	  {"D4_QTDEORI", TMPEMP->QTUS, NIL },;
		                                  		      {"D4_QUANT"  , TMPEMP->QTUS, NIL } }
		                           		MSExecAuto({|x, y| MATA380(x, y)}, aEmpMov, 4) //SigaAuto de Alteração do empenho
		                          Elseif TMPEMP->VISI $ 'E' // Exclusão de produtos indiretos 
		                          	
			                                lMsErroAuto := .f.
			                                aEmpMov     := {}
			                                aEmpMov := { {"D4_FILIAL", cParInf2    , NIL },;
			                                             {"D4_OP"    , Alltrim(cNumOrd) + Space( 13 - Len( Alltrim(cNumOrd) ) ) , NIL },;
			                                             {"D4_COD"   , TMPEMP->ITEM, NIL },;
			                                             {"D4_TRT"   , TMPEMP->SEQU, NIL } }
			                                MSExecAuto({|x, y| MATA380(x, y)}, aEmpMov, 5) //SigaAuto de Exclusão do empenho
			                        
		                          Endif   
		                       Endif */
		                   Endif //Fim Alteração   
	                    Endif
	                 Endif
	                 RecLock("TMPEMP", .f.)
	                    TMPEMP->INCL := "S"
	                 MsUnLock()
	                 DbSelectArea("TMPEMP")
	                 DbSkip()
	           Enddo
	           //Verificação dos Itens empenhados no SD4 quando OP é apontada na Fabrica 2
	           //LGS#20200205 - Adequação de release 12.1.25 e posteriores
	           //If cParInf5 $ '2' .AND. GetMV("MV_XHABZZF") //Alteração Tiago lucio Chaus
	           If cParInf5 $ '2' .AND. _cMVXHABZZ //Alteração Tiago lucio Chaus
	              aEmpAlt := {}
	              DbSelectArea("SD4")
	              DbSetOrder(2)
	              DbSeek(xFilial("SD4")+cNumOrd, .t.)
	              If Found()
	                 While !Eof() .and. Alltrim(SD4->D4_OP) == cNumOrd
	                       If SD4->D4_LOCAL <> '99'
	                          aEmpAlt := { {"D4_FILIAL" , SD4->D4_FILIAl, NIL },;
	                                       {"D4_OP"     , SD4->D4_OP    , NIL },;
	                                       {"D4_COD"    , SD4->D4_COD   , NIL },;
	                                       {"D4_TRT"    , SD4->D4_TRT   , NIL },;
	                                       {"D4_LOCAL"  , Iif(SD4->D4_LOCAL $ '01', '10', Iif(SD4->D4_LOCAL $ 'R1', 'R2', Iif(SD4->D4_LOCAL $ '02', '20', SD4->D4_LOCAL))), NIL } }
										   
										   //{"D4_LOCAL"  , Iif(SD4->D4_LOCAL $ '01', '10', Iif(SD4->D4_LOCAL $ '02', '20', SD4->D4_LOCAL)), NIL } } 
					                       

	                       Endif
	                       DbSelectArea("SD4")
	                       DbSkip()
	                 EndDo
	              EndIf
	              If Len(aEmpAlt) > 0
	                 lMsErroAuto := .f.
	                 MSExecAuto({|x, y| MATA380(x, y)}, aEmpAlt, 4) //SigaAuto de Alteração do empenho
	                 If lMsErroAuto
	                    cErrAltEmpRet := "NÃO_RET"
	                 Endif
	              Endif
	           Endif
           
          
           //Atualizar flags de apontamento
           cQry1 := ""
           cQry1 += "SELECT ZZA.ZZA_ORDEM, ZZA.ZZA_PRODUT, ROUND(SC2.C2_QUANT, 4) AS QUANT "
           cQry1 += "FROM "+RetSqlName("ZZA")+" ZZA WITH (NOLOCK) "
           cQry1 += "LEFT OUTER JOIN "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) ON SC2.C2_FILIAL = ZZA.ZZA_FILIAL AND SC2.C2_NUM = SUBSTRING(ZZA.ZZA_ORDEM, 1, 6) AND SC2.C2_ITEM = SUBSTRING(ZZA.ZZA_ORDEM, 7, 2) AND SC2.C2_SEQUEN = SUBSTRING(ZZA.ZZA_ORDEM, 9, 3) AND SC2.D_E_L_E_T_ = '' "
           cQry1 += "WHERE ZZA.ZZA_FILIAL = '"+xFilial("ZZA")+"'"
           cQry1 += "  AND ZZA.D_E_L_E_T_ = '' "
           cQry1 += "  AND ZZA_FLAG = '1' "
           cQry1 += "  AND SUBSTRING(ZZA.ZZA_ORDEM, 1, 6) = '"+SubStr(cNumOrd, 1, 6)+"' "
           TCQuery cQry1 ALIAS "TCQ" NEW
           DbSelectArea("TCQ")
           DbGoTop()
           While !Eof()
                 If SubStr(TCQ->ZZA_ORDEM, 7, 2) $ '02' //Ordem de Produção de Concentrado - Baixa direto
                    cQry1 := ""
                    cQry1 += "UPDATE "+RetSqlName("ZZA")+" "
                    cQry1 += "SET "
                    cQry1 += "    ZZA_DTFIM  = '"+DTOS(Date())+"', "
                    cQry1 += "    ZZA_HFIM   = '"+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+"', "
                    cQry1 += "    ZZA_PESFIN = "+StrTran(TransForm(TCQ->QUANT ,'@E 99999.9999'), ",", ".")+", "
                    cQry1 += "    ZZA_QUANT  = "+StrTran(TransForm(TCQ->QUANT ,'@E 99999.9999'), ",", ".")+", "
                    cQry1 += "    ZZA_HELP   = '"+cParInf5+" - 04 - Finalizado Laboratorio' "+cErrAltEmpRet+", "
                    cQry1 += "    ZZA_CAMPO  = 'FAB"+cParInf5+"', "
                    cQry1 += "    ZZA_FLAG   = '4' "
                    cQry1 += "WHERE ZZA_FILIAL = '"+xFilial("ZZA")+ "' AND D_E_L_E_T_ = '' AND ZZA_ORDEM = '"+TCQ->ZZA_ORDEM+"' "
                 ElseIf SubStr(TCQ->ZZA_ORDEM, 7, 2) $ '01'
                        //Fechamento de Ordens de produção para produtos intermediários
                        If Len(Alltrim(TCQ->ZZA_PRODUT)) == 4 .or. Len(Alltrim(TCQ->ZZA_PRODUT)) == 5 .or. Len(Alltrim(TCQ->ZZA_PRODUT)) == 6
                           cQry1 := ""
                           cQry1 += "UPDATE "+RetSqlName("ZZA")+" "
                           cQry1 += "SET "
                           cQry1 += "    ZZA_DTPES  = '"+DTOS(Date())+"', "
                           cQry1 += "    ZZA_HPES   = '"+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+"', "
                           cQry1 += "    ZZA_PESPES = "+StrTran(TransForm(nGetLPes,'@E 99999.9999'), ",", ".")+", "
                           cQry1 += "    ZZA_HELP   = '"+cParInf5+" - 02 - Finalizado Pesagem' "+cErrAltEmpRet+", "
                           cQry1 += "    ZZA_CAMPO  = 'FAB"+cParInf5+"', "
                           cQry1 += "    ZZA_FLAG   = '3' "
                           cQry1 += "WHERE ZZA_FILIAL = '"+cParInf2+"' AND D_E_L_E_T_ = '' AND ZZA_ORDEM = '"+TCQ->ZZA_ORDEM+"' "
                        Else
                            // TODAS AS OPS INDEPENDENTE DO TIPO (ESTOQUE OU NÃO ESTOQUE) E TAMBÉM DA QUANTIDADE DEVEM PASSAR POR TODAS AS ETAPAS DO APONTAMENTO (ANDRÉ 28-03-16)
                           /*If cProEst $ 'N' .and. nGetLPes <= 48.0 //Se o produto não for de estoque e a quantidade for menor que 50, aponta todas as etapas
                              nPesEsp := Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZA_PRODUT, "B1_PESOESP")
                              cHorAux := SubStr(Time(), 1, 2)
                              cMinAux := SubStr(Time(), 4, 2)
                              If cHorAux == '23'
                                 If cMinAux == '59'
                                    cHorCol := '00'
                                    cMinCol := '00'
                                 Else
                                    cHorCol := cHorAux
                                    cMinCol := StrZero(Val(cMinAux) + 1, 2)
                                 Endif
                              Else
                                 If cMinAux == '59'
                                    cHorCol := StrZero(Val(cHorAux) + 1, 2)
                                    cMinCol := '00'
                                 Else
                                    cHorCol := cHorAux
                                    cMinCol := StrZero(Val(cMinAux) + 1, 2)
                                 Endif
                              Endif
                              If cMinCol == '59'
                                 cHorLab := StrZero(Val(cHorCol) + 1, 2)
                                 cHorLab := StrZero(Val(cHorCol) + 1, 2)
                              Else
                                 cHorLab := cHorCol
                                 cMinLab := StrZero(Val(cMinCol) + 1, 2)
                              Endif
                              cQry1 := ""
                              cQry1 += "UPDATE "+RetSqlName("ZZA")+" "
                              cQry1 += "SET "
                              cQry1 += "    ZZA_DTPES  = '"+dTos(dDataBase)+"', "
                              cQry1 += "    ZZA_HPES   = '"+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+"', "
                              cQry1 += "    ZZA_PESPES =  "+StrTran(TransForm(nGetLPes,'@E 99999.99999'), ",", ".")+", "
                              cQry1 += "    ZZA_DTCOL  = '"+dTos(dDataBase)+"', "
                              cQry1 += "    ZZA_HCOL   = '"+cHorCol+cMinCol+"', "
                              cQry1 += "    ZZA_PESCOL =  "+StrTran(TransForm(nGetLPes,'@E 99999.99999'), ",", ".")+", "
                              cQry1 += "    ZZA_DTFIM  = '"+dTos(dDataBase)+"', "
                              cQry1 += "    ZZA_HFIM   = '"+cHorLab+cMinLab+"', "
                              cQry1 += "    ZZA_PESFIN =  "+StrTran(TransForm(nGetLPes,'@E 99999.99999'), ",", ".")+", "
                              If (Len(Alltrim(TCQ->ZZA_PRODUT)) == 12 .and. Substr(Alltrim(TCQ->ZZA_PRODUT),11,2) =='99')  
	                              cQry1 += "    ZZA_QUANT  =  "+StrTran(TransForm(nGetLPes,'@E 99999.9999'), ",", ".")+", "
    						  Else
							      cQry1 += "    ZZA_QUANT  =  "+StrTran(TransForm(nGetLPes / nPesEsp,'@E 99999.9999'), ",", ".")+", "    						  	
                              Endif
                              cQry1 += "    ZZA_PESESP =  "+StrTran(TransForm(nPesEsp ,'@E 99999.99999'), ",", ".")+", "
                              cQry1 += "    ZZA_PESLAB =  "+StrTran(TransForm(nPesEsp ,'@E 99999.99999'), ",", ".")+", "
                              cQry1 += "    ZZA_HELP   =  '"+cParInf5+" - 04 - Finalizado Laboratorio' "+cErrAltEmpRet+", "
                              cQry1 += "    ZZA_CAMPO  = 'FAB"+cParInf5+"', "
                              cQry1 += "    ZZA_FLAG = '4' "
                              cQry1 += "WHERE ZZA_FILIAL = '"+xFilial("ZZA")+"' AND D_E_L_E_T_ = '' AND ZZA_ORDEM = '"+TCQ->ZZA_ORDEM+"' "
                           
                           Else //Fechamento normal para ordens de produção
                           */
                              cQry1 := ""
                              cQry1 += "UPDATE "+RetSqlName("ZZA")+" "
                              cQry1 += "SET "
                              cQry1 += "    ZZA_DTPES  = '"+dTos(dDataBase)+"', "
                              cQry1 += "    ZZA_HPES   = '"+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+"', "
                              cQry1 += "    ZZA_PESPES = "+StrTran(TransForm(nGetLPes,'@E 99999.99999'), ",", ".")+", "
                              cQry1 += "    ZZA_HELP   = '"+cParInf5+" - 02 - Finalizada Pesagem' "+cErrAltEmpRet+", "
                              cQry1 += "    ZZA_CAMPO  = 'FAB"+cParInf5+"', "
                              cQry1 += "    ZZA_FLAG   = '2' "
                              cQry1 += "WHERE ZZA_FILIAL = '"+xfilial("ZZA")+"' AND D_E_L_E_T_ = '' AND ZZA_ORDEM = '"+TCQ->ZZA_ORDEM+"' "
                           //Endif
                        Endif
                 Endif
                 XXX := TCSQLEXEC(cQry1)
                 If XXX <> 0
                    cNomArq := 'C:\TEMP\ERR'+DTOS(MsDate())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+'.ERR'
                    MemoWrit(cNomArq, cQry1)
                 Endif
                 DbSelectArea("TCQ")
                 DbSkip()
           Enddo
           DbSelectArea("TCQ")
           DbCloseArea()

           //Gravar Balanceiros
           DbSelectArea("ZZG")
           DbSetOrder(1)
           DbSeek(xFilial("ZZG")+cNumOrd, .t.)
           If Found()
              While !Eof() .and. ZZG->ZZG_ORDEM == cNumOrd
                    If ZZG->ZZG_TPUSER $ 'B'
                       RecLock("ZZG", .f.)
                          DbDelete()
                       MsUnLock()
                    Endif
                    DbSelectArea("ZZG")
                    DbSkip()
              Enddo
           Endif
           DbSelectArea("TMPFUN")
           Pack
           DbGoTop()
           While !Eof()
                 RecLock("ZZG", .t.)
                    ZZG->ZZG_FILIAL := xFilial("ZZG")
                    ZZG->ZZG_ORDEM  := cNumOrd
                    ZZG->ZZG_LOTE   := cNumLot
                    ZZG->ZZG_PROENV := ""
                    ZZG->ZZG_SEQENV := "01"
                    ZZG->ZZG_TPUSER := "B"
                    ZZG->ZZG_FILMAT := TMPFUN->FUNFMA
                    ZZG->ZZG_NOME   := TMPFUN->FUNNOM
                 MsUnLock()
                 DbSelectArea("TMPFUN")
                 DbSkip()
           Enddo

           //Voltar situação da tela inicial
           cGet1Apt := space(11)
           oGet1Apt:SetFocus()
           oGet1Apt:Refresh()
           oBtnDApt:cCaption := "Sair"
           oBtnDApt:bAction  := {|| fAptSaiVol(1)}
           oBtnDApt:Refresh()
           //oBtn1Apt:lVisible := .f.
           //oBtn1Apt:Refresh()
           oGet1Apt:lReadOnly := .f.
           oGet1Apt:Refresh()
          AtualizSD4() //Tiago Lucio/Chaus 17/04/2014 Atualiza empenhos Pesagem
           
    Return .t.

    /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ fFimColPro() - Grava apontamento do Colorista
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Static Function fFimColPro()
           DbSelectArea("ZZF")
           DbSetOrder(4)

           DbSelectArea("ZZA")
           DbSetOrder(2)

           //Verificação das datas e horas de apontamento
           If dDataBase < dDatCol
              Messagebox("Atenção, a data do computador deve estar errada. Data menor que o processo anterior!","Atenção...",48) 
              Return .f.
           ElseIf dDataBase == dDatCol
                  If SubStr(Time(), 1, 5) < hHorCol
                     Messagebox("Atenção, a hora do computador deve estar errada. Hora menor que o processo anterior!","Atenção...",48) 
                     Return .f.
                  ElseIf SubStr(Time(), 1, 5) == hHorCol
                         Messagebox("Atenção, a hora não pode ser igual ao processo anterior!","Atenção...",48) 
                         Return .f.
                  Endif
           Endif
           //Verifica se os coloristas foram apontados
           DbSelectArea("TMPFUN")
           pack
           DbGoTop()
           If TMPFUN->(RecCount()) <= 0
              Messagebox("Os coloristas não foram apontados, verifique","Atenção...",48) 
              Return .f.
           EndIf
           //Grava dados dos empenhos
           DbSelectArea("TMPEMP")
           DBCLEARFILTER()
           DbGoTop()
	       While !Eof()
                 If TMPEMP->TPEM $ 'C'
                    If TMPEMP->VISI $ 'S'
                       DbSelectArea("ZZF")
                       DbSetOrder(4)
                       DbSeek(xFilial("ZZF")+cNumOrd+TMPEMP->ITEM+TMPEMP->SEQU, .t.)
                       If Found()
                          RecLock("ZZF", .f.)
                       	      ZZF->ZZF_QTDUSA := Round(TMPEMP->QTUS, 4)
                              ZZF->ZZF_FLAG   := '2'  
                           MsUnLock()   
                       Else
                          RecLock("ZZF", .t.)
                             ZZF->ZZF_FILIAL := xFilial("ZZF")
                             ZZF->ZZF_ORDEM  := cNumOrd
                             ZZF->ZZF_LOTE   := cNumLot
                             ZZF->ZZF_CODIGO := TMPEMP->ITEM
                             ZZF->ZZF_TRT    := StrZero(Val(TMPEMP->SEQU), 3)
                             ZZF->ZZF_LOCAL  := Iif(cParInf5 $ '2', TMPEMP->LCBX, TMPEMP->ARMZ)              //Troca do local quanto apontamento for na fábrica 2 //TMPEMP->LOCA
                             ZZF->ZZF_QTDUSA := Round(TMPEMP->QTUS, 4)
                             ZZF->ZZF_FLAG   := "2"
                             ZZF->ZZF_TIPEMP := "C"
                             ZZF->ZZF_OBS    := TMPEMP->ORIG+" / Aguardando."                                //Aguardando processar
                             //LGS#20200204 - Adequação de release 12.1.25 e posteriores
	                         //ZZF->ZZF_XHABIL := getMV("MV_XHABZZF") //Inclusão do campo para armazenar status do parametro Tiago Lucio Chaus/28/02/14
	                         ZZF->ZZF_XHABIL := _cMVXHABZZ	//Inclusão do campo para armazenar status do parametro Tiago Lucio Chaus/28/02/14
   
                          MsUnLock()   
                       Endif
                       MsUnLock()
                    ElseIf TMPEMP->VISI $ 'E' //Excluido no ajuste de empenho Processo 04 - Tingimento
                    	DbSelectArea("ZZF")
                        DbSetOrder(4)
                        DbSeek(xFilial("ZZF")+cNumOrd+TMPEMP->ITEM+TMPEMP->SEQU, .t.)
                        If Found()
                        	RecLock("ZZF", .f.)
                            	ZZF->ZZF_FLAG := "1"
                                ZZF->ZZF_OBS  := "04 - Excluido" 
                             MsUnLock()    
                        Endif
                    Endif
                 Endif
                 DbSelectArea("TMPEMP")
                 DbSkip()
           Enddo
       
           //Trocar Flag para 3 e gravar peso da O.P. Colorista
           DbSelectArea("ZZA")
           DbSetOrder(2)
           DbSeek(xFilial("ZZA")+cNumOrd, .t.)
           If Found()
              RecLock("ZZA", .f.)
                 ZZA->ZZA_DTCOL  := Date()
                 ZZA->ZZA_HCOL   := SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)
                 ZZA->ZZA_PESCOL := nGetLPes
                 ZZA->ZZA_HELP  := cParInf5+" - 04 - Fim  do Tingimento"
                 If SubStr(nCBox1Co, 1, 1) $ 'S'
                    ZZA->ZZA_FLAG := '3'
                 Endif
              MsUnLock()
           Endif

           //Gravar Coloristas
           DbSelectArea("ZZG")
           DbSetOrder(1)
           DbSeek(xFilial("ZZG")+cNumOrd, .t.)
           If Found()
              While !Eof() .and. ZZG->ZZG_ORDEM == cNumOrd
                    If ZZG->ZZG_TPUSER $ 'C'
                       RecLock("ZZG", .f.)
                          DbDelete()
                       MsUnLock()
                    Endif
                    DbSelectArea("ZZG")
                    DbSkip()
              Enddo
           Endif
           DbSelectArea("TMPFUN")
           Pack
           DbGoTop()
           While !Eof()
                 RecLock("ZZG", .t.)
                    ZZG->ZZG_FILIAL := xFilial("ZZG")
                    ZZG->ZZG_ORDEM  := cNumOrd
                    ZZG->ZZG_LOTE   := cNumLot
                    ZZG->ZZG_PROENV := ""
                    ZZG->ZZG_SEQENV := "01"
                    ZZG->ZZG_TPUSER := "C"
                    ZZG->ZZG_FILMAT := TMPFUN->FUNFMA
                    ZZG->ZZG_NOME   := TMPFUN->FUNNOM
                 MsUnLock()
                 DbSelectArea("TMPFUN")
                 DbSkip()
           Enddo
           //Voltar situação da tela inicial
           cGet1Apt := space(11)
           oGet1Apt:SetFocus()
           oGet1Apt:Refresh()
           oBtnDApt:cCaption := "Sair"
           oBtnDApt:bAction  := {|| fAptSaiVol(1)}
           oBtnDApt:Refresh()
           oGet1Apt:lReadOnly := .f.
           oGet1Apt:Refresh()
           
            AtualizSD4() //Tiago Lucio/Chaus 17/04/2014 Atualiza empenhos colorista
    Return .t.

    /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ fFimLabPro() - Grava fim do laboratorio do produto
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Static Function fFimLabPro()
           //Verificação das datas e horas de apontamento
           If dDataBase < dDatLab
              Messagebox("Atenção, a data do computador deve estar errada. Data menor que o processo anterior!","Atenção...",48) 
              Return .f.
           ElseIf dDataBase == dDatLab
                  If SubStr(Time(), 1, 5) < hHorLab
                     Messagebox("Atenção, a hora do computador deve estar errada. Hora menor que o processo anterior!","Atenção...",48) 
                     Return .f.
                  ElseIf SubStr(Time(), 1, 5) == hHorLab
                         Messagebox("Atenção, a hora não pode ser igual ao processo anterior!","Atenção...",48) 
                         Return .f.
                  Endif
           Endif
           //Verifica se os coloristas foram apontados
           If nGet6Lab > 50.0
              DbSelectArea("TMPFUN")
              pack
              DbGoTop()
              If TMPFUN->(RecCount()) <= 0
                 Messagebox("O(s) analista(s) de Laboratório não foram apontados, verifique!!!","Atenção...",48) 
                 Return .f.
              EndIf
           Endif

           //Grava dados dos empenhos
           DbSelectArea("TMPEMP")
           DBCLEARFILTER()
           DbGoTop()
           While !Eof()
                 If TMPEMP->TPEM $ 'L'
                    If TMPEMP->VISI $ 'S'
                       DbSelectArea("ZZF")
                       DbSetOrder(4)
                       DbSeek(xFilial("ZZF")+cNumOrd+TMPEMP->ITEM+TMPEMP->SEQU, .t.)
                       If Found()
                          RecLock("ZZF", .f.)
                             ZZF->ZZF_QTDUSA := Round(TMPEMP->QTUS, 4)
                          MsUnLock()    
                       Else
                          RecLock("ZZF", .t.)
                             ZZF->ZZF_FILIAL := xFilial("ZZF")
                             ZZF->ZZF_ORDEM  := cNumOrd
                             ZZF->ZZF_LOTE   := cNumLot
                             ZZF->ZZF_CODIGO := TMPEMP->ITEM
                             ZZF->ZZF_TRT    := StrZero(Val(TMPEMP->SEQU), 3)
                             ZZF->ZZF_LOCAL  := Iif(cParInf5 $ '2', TMPEMP->LCBX, TMPEMP->ARMZ)              //Troca do local quanto apontamento for na fábrica 2 //TMPEMP->LOCA
                             ZZF->ZZF_QTDUSA := Round(TMPEMP->QTUS, 4)
                             ZZF->ZZF_FLAG   := "2"
                             ZZF->ZZF_TIPEMP := "L"
                             ZZF->ZZF_OBS    := TMPEMP->ORIG+" / Aguardando."                                //Aguardando processar
                             //LGS#20200204 - Adequação de release 12.1.25 e posteriores
	                         //ZZF->ZZF_XHABIL := getMV("MV_XHABZZF")         //Inclusão do campo para armazenar status do parametro Tiago Lucio Chaus/28/02/14
	                         ZZF->ZZF_XHABIL := _cMVXHABZZ	//Inclusão do campo para armazenar status do parametro Tiago Lucio Chaus/28/02/14

                          MsUnLock()
                       Endif
                       MsUnLock()
                    ElseIf TMPEMP->VISI $ 'E' //Excluido no ajuste de empenho Processo 04 - Tingimento
                       DbSelectArea("ZZF")
                       DbSetOrder(4)
                       DbSeek(xFilial("ZZF")+cNumOrd+TMPEMP->ITEM+TMPEMP->SEQU, .t.)
                       If Found()
                	       RecLock("ZZF", .f.)
                    	       ZZF->ZZF_FLAG := "1"
                               ZZF->ZZF_OBS  := "04 - Excluido"  
                           MsUnLock()
                       Endif
                    Endif
                 Endif
                 DbSelectArea("TMPEMP")
                 DbSkip()
           Enddo

           //Trocar Flag para 3 e gravar peso da O.P. Colorista
           DbSelectArea("ZZA")
           DbSetOrder(2)
           DbSeek(xFilial("ZZA")+cNumOrd, .t.)
           If Found()
              RecLock("ZZA", .f.)
                 ZZA->ZZA_DTFIM  := Date()
                 ZZA->ZZA_HFIM   := SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)
                 ZZA->ZZA_PESFIN := Round(nGetLPes, 3)
                 ZZA->ZZA_PESESP := Round(nGet4Lab, 6)
                 ZZA->ZZA_PESLAB := Round(nGet7Lab, 6)
                 ZZA->ZZA_HELP   := cParInf5+" - 90 - Fim  do Laboratório"
                 ZZA->ZZA_FLAG   := '4'
                 ZZA->ZZA_LIBLAB := Iif(Empty(cRetSup), "", cRetSup+StrTran(dtoc(date()), "/")+StrTran(time(), ":") )
                 ZZA->ZZA_QUANT  := Iif(Len(Alltrim(ZZA->ZZA_PRODUTO)) == 12 .and. Substr(Alltrim(ZZA->ZZA_PRODUTO),11,2)=='00', Round( (nGetLPes / nGet7Lab), 4), Round(nGetLPes, 4) )
              MsUnLock()

              AtualizSD4() // ALTERAÇÃO CHAMADO 017024, CHAMANDO ANTES DA ALTERAÇÃO DA OP PARA ACATAR ALTERAÇÃO DE EMPENHO

              //TOTVSMES - Integração com o PCFactory
              //**********************************************************************************************************
              //*** BRASILUX - APÓS GRAVAÇÃO DO APONTAMENTO DE LABORATÓRIO ALTERA A OP PARA ENVIO DO PESO FINAL PARA O PCF
              aMATA650      := {}       //-Array com os campos
              nOpc          := 4
              lMsErroAuto   := .F.

              SetFunName("MATA650") //LGS#20190507 - Para funcionar a integração com o PPI Multitask
              RpcSetType( )
              //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
              //³ Se alteracao ou exclusao, deve-se posicionar no registro     ³
              //³ da SC2 antes de executar a rotina automatica                 ³
              //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
              SC2->(DbSetOrder(1)) // FILIAL + NUM + ITEM + SEQUEN + ITEMGRD
              SC2->(DbSeek(xFilial("SC2") + cNumOrd))
	
              aMata650 := { { 'C2_FILIAL' , SC2->C2_FILIAL           , NIL },;
                            { 'C2_PRODUTO', SC2->C2_PRODUTO          , NIL },;          
                            { 'C2_NUM'    , SC2->C2_NUM              , NIL },;          
                            { 'C2_ITEM'   , SC2->C2_ITEM             , NIL },;
                            { 'C2_SEQUEN' , SC2->C2_SEQUEN           , NIL },;
                            { 'C2_OBS'    , "4 - Fim  do Laboratório", NIL } }

              msExecAuto( { |x, Y| Mata650(x, Y) }, aMata650, nOpc )
              If lMsErroAuto
                 MostraErro()
              Else
                 //Função para buscar Ordens de PAs e integrar pesos
                 fIntegPAs()
              EndIf
           Endif
           //**********************************************************************************************************

           //Grava dados dos Analistas
           DbSelectArea("ZZG")
           DbSetOrder(1)
           DbSeek(xFilial("ZZG")+cNumOrd, .t.)
           If Found()
              While !Eof() .and. ZZG->ZZG_ORDEM == cNumOrd
                    If ZZG->ZZG_TPUSER $ 'L'
                       RecLock("ZZG", .f.)
                          DbDelete()
                       MsUnLock()
                    Endif
                    DbSelectArea("ZZG")
                    DbSkip()
              Enddo
           Endif
           DbSelectArea("TMPFUN")
           Pack
           DbGoTop()
           While !Eof()
                 RecLock("ZZG", .t.)
                    ZZG->ZZG_FILIAL := xFilial("ZZG")
                    ZZG->ZZG_ORDEM  := cNumOrd
                    ZZG->ZZG_LOTE   := cNumLot
                    ZZG->ZZG_PROENV := ""
                    ZZG->ZZG_SEQENV := "01"
                    ZZG->ZZG_TPUSER := "L"
                    ZZG->ZZG_FILMAT := TMPFUN->FUNFMA
                    ZZG->ZZG_NOME   := TMPFUN->FUNNOM
                 MsUnLock()
                 DbSelectArea("TMPFUN")
                 DbSkip()
           Enddo

           //Voltar situação da tela inicial
           cGet1Apt := space(11)
           oGet1Apt:SetFocus()
           oGet1Apt:Refresh()
           oBtnDApt:cCaption := "Sair"
           oBtnDApt:bAction  := {|| fAptSaiVol(1)}
           oBtnDApt:Refresh()
           //oBtn1Apt:lVisible := .f.
           //oBtn1Apt:Refresh()
           oGet1Apt:lReadOnly := .f.
           oGet1Apt:Refresh()  
           
           //AtualizSD4() //Tiago Lucio/Chaus 17/04/2014 - Atualiza empenhos laboratorio
    Return .t.

//************************************************************
//*** TOTVSMES - Integração com o PCFactory - LGS#20191106 ***
//************************************************************
Static Function fIntegPAs()
       Local aMATA650    := {}  //-Array com os campos
       Local nOpc        := 4
       Local lMsErroAuto := .F.
       Private _aPesoProd:= {}

       SetFunName("MATA650") 
       RpcSetType( )

       DbSelectArea("SC2") //Busco Produtos do Lote
       SC2->( DbOrderNickName("SC2001") )
       If SC2->( DbSeek( xFilial("SC2") + ZZA->ZZA_LOTE ) )
          While !Eof() .and. SC2->C2_LOTE == ZZA->ZZA_LOTE
                _aPesoProd := {}
                DbSelectArea("SB1") //Verifico se produto é um PA
                SB1->( DbSetorder( 1 ) )
                If SB1->( DbSeek( xFilial ("SB1") + SC2->C2_PRODUTO ) )
                   If SB1->B1_TIPO == 'PA'
                      _aPesoProd := fPesoPA()
                      aMata650  := { {'C2_FILIAL'   ,SC2->C2_FILIAL                                    , NIL },;
                                     {'C2_PRODUTO'  ,SC2->C2_PRODUTO                                   , NIL },;          
                                     {'C2_NUM'      ,SC2->C2_NUM                                       , NIL },;          
                                     {'C2_ITEM'     ,SC2->C2_ITEM                                      , NIL },;
                                     {'C2_SEQUEN'   ,SC2->C2_SEQUEN                                    , NIL },;
                                     {'C2_OBS'      ,"4 - Fim  do Laboratório" + AllTrim( SC2->C2_OBS ), NIL } }             

                      msExecAuto( { | x, Y | Mata650( x, Y ) }, aMata650, nOpc )
                      If lMsErroAuto
                         MostraErro()
                      EndIf
                   Endif
                Endif
                DbSelectArea("SC2")
                SC2->( DbSkip() )
          EndDo
       Endif
Return

Static Function fPesoPA()
       Local _nPesoLiqu := 0
       Local _nPesoBrut := 0
       Local _aCompProd := {}
       Local _nX        := 0

       DbSelectArea("SG1")
       SG1->( DbSetOrder( 1 ) )
       If SG1->( DbSeek( xFilial("SG1") + SB1->B1_COD) )
          While !Eof() .and. SG1->G1_COD == SB1->B1_COD
                //                  COMPONENTE    QUANTIDADE     UNIDADE  TIPO  PESO  TOTAL
                aAdd( _aCompProd, { SG1->G1_COMP, SG1->G1_QUANT, ''     , ''  , 0   , 0    } )
                DbSelectArea("SG1")
                SG1->( DbSkip( ) )
          EndDo
       Endif
       //Calcula Peso Por item da fórmula
       For _nX := 1 To Len( _aCompProd )
           DbSelectArea( "SB1" )
           SB1->( DbSetorder( 1 ) )
           If SB1->( DbSeek( xFilial( "SB1" ) + _aCompProd[_nX][1] ) )
              _aCompProd[ _nX ][3] := SB1->B1_UM
              _aCompProd[ _nX ][4] := SB1->B1_TIPO
              _aCompProd[ _nX ][5] := SB1->B1_PESO //Peso Liquido do Produto
              If SB1->B1_TIPO == 'PI'
                 _aCompProd[ _nX ][6] := Round( Iif( SB1->B1_UM $ 'KG.K ', _aCompProd[ _nX ][2], _aCompProd[ _nX ][2] * ZZA->ZZA_PESLAB ), 3 )
                 _nPesoLiqu += Round( _aCompProd[ _nX ][6], 3 )
                 _nPesoBrut += Round( _aCompProd[ _nX ][6], 3 )
              Else
                 _aCompProd[ _nX ][6] := Round( _aCompProd[ _nX ][2] * _aCompProd[ _nX ][5], 3 )
                 _nPesoBrut += Round( _aCompProd[ _nX ][6], 3 )
              Endif
           Endif
       Next
Return { _nPesoLiqu, _nPesoBrut }


    /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ fGrvMntApt() - Grava manutenção de inclusão/alteração/exclusão de materias primas
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Static Function fGrvMntApt(cOpcFun, cProFun)    
    Local cQry1,lAchou
           If cOpcFun $ '0' //Inclusão
				//Depois da virada de versão para a 11 o dbseek não funcionou no sra
				cQry1 := "SELECT RA_NOME FROM "+RetSqlName("SRA")+" WHERE (D_E_L_E_T_ <> '*') AND (RA_FILIAL = '"+XFILIAL("SRA")+"') AND (RA_MAT = '"+ALLTRIM(cGet1Mnt)+"')"
	            TCQuery cQry1 ALIAS "TCQRA" NEW
              	DbSelectArea("TCQRA")
              	DbGoTop()
        	   	lAchou := iif(!EOF() .AND. !BOF(),.t.,.f.)
	            DbSelectArea("TCQRA")
				DbCloseArea()
				
				           
              //DbSelectArea("SRA")
              //DbSetOrder(1)         
              //DbSeek(alltrim(cGet1Mnt), .t.) 
              If lAchou
                 If cProFun $ 'EN'
                    If lCBox1En
                       DbselectArea("TMPENV")
                       DbGoTop()
                       While !Eof()
                             DbSelectArea("TMPFUN")
                             DbSetOrder(2)
                             DbSeek(cGet1Mnt+TMPENV->ENVORD+TMPENV->ENVSEQ)
                             If !Found()
                                If !SubStr(TMPENV->ENVBAI, 1, 2) $ 'AP.EX.TO.PA.EN'
                                   RecLock("TMPFUN", .t.)
                                      TMPFUN->FUNFMA := cGet1Mnt
                                      TMPFUN->FUNNOM := cGet2Mnt
                                      TMPFUN->FUNORD := TMPENV->ENVORD
                                      TMPFUN->FUNSEQ := TMPENV->ENVSEQ
                                      TMPFUN->FUNPRO := TMPENV->ENVCOD
                                      TMPFUN->FUNVIS := Iif(TMPENV->(Recno()) == 1, "S", "N")
                                   MsUnLock()
                                Endif
                             Endif
                             DbselectArea("TMPENV")
                             DbSkip()
                       Enddo
                       DbselectArea("TMPENV")
                       DbGoTop()
                    Else
                       If !SubStr(TMPENV->ENVBAI, 1, 2) $ 'AP.EX.TO.PA.EN'
                          RecLock("TMPFUN", .t.)
                             TMPFUN->FUNFMA := cGet1Mnt
                             TMPFUN->FUNNOM := cGet2Mnt
                             TMPFUN->FUNORD := TMPENV->ENVORD
                             TMPFUN->FUNSEQ := TMPENV->ENVSEQ
                             TMPFUN->FUNPRO := TMPENV->ENVCOD
                             TMPFUN->FUNVIS := "S"
                          MsUnLock()
                       Endif
                    Endif
                 Else
                    DbSelectArea("TMPFUN")
                    DbSetOrder(2)
                    DbSeek(cGet1Mnt+cNumOrd, .t.)
                    If !Found()
                       RecLock("TMPFUN", .t.)
                          TMPFUN->FUNFMA := cGet1Mnt
                          TMPFUN->FUNNOM := cGet2Mnt
                          TMPFUN->FUNORD := cNumOrd
                          TMPFUN->FUNSEQ := "01"
                          TMPFUN->FUNVIS := "S"
                       MsUnLock()
                    Endif
                 Endif
              Else
                 //MsgStop("Esse funcionário não existe, verifique!: " + cGet1Mnt)
                 Messagebox("Verificar o cadastro deste Funcionário, pois não foi encontrado funcionário para esta matrícula!:" + cGet1Mnt,"Atenção...",48) 
                 cGet1Mnt := space(08)
                 cGet2Mnt := space(30)
                 oGet1Mnt:Refresh()
                 oGet2Mnt:Refresh()
                 oGet1Mnt:SetFocus()
                 Return
              Endif
           Else //Exclusão
              DbSelectArea("TMPFUN")
              RecLock("TMPFUN", .f.)
                 TMPFUN->FUNVIS := "E"
              MsUnLock()
           Endif
           DbSelectArea("TMPFUN")
           DbGoTop()
           oDlg1Mnt:End()     
           
          
    Return

    /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ fConEmpMnt() - Confirmação da manutenção dos itens empenhados
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Static Function fConEmpMnt(nOpcMnt)
           If nOpcMnt == 0
              If nGet3Mnt > 0
                 RecLock("TMPEMP", .t.)
                    TMPEMP->ITEM := cGet1Mnt
                    TMPEMP->SEQU := cGet2Mnt
                    TMPEMP->QTSO := 0
                    TMPEMP->QTUS := nGet3Mnt
                    TMPEMP->TPEM := Iif(cFlaOrd $ '1.Z', "P", Iif(cFlaOrd $ '2.Y', "C", "L")) //Complemento apontado na Ordem de produção Pesagem=X
                    TMPEMP->TIPO := Posicione("SB1", 1, xFilial("SB1")+cGet1Mnt, "B1_TIPO")
                    //TMPEMP->LOCA := Iif( Posicione("SB1", 1, xFilial("SB1")+cGet1Mnt, "B1_APROPRI") $ 'I', '99', Posicione("SB1", 1, xFilial("SB1")+cGet1Mnt, "B1_LOCPAD") )
					TMPEMP->ARMZ := Iif( Posicione("SB1", 1, xFilial("SB1")+cGet1Mnt, "B1_APROPRI") $ 'I', '99', Iif( TMPEMP->TIPO $ 'MP', Iif( cParInf5 $ '1', Iif( Posicione("SB1", 1, xFilial("SB1")+cGet1Mnt, "B1_LOCPAD") $ 'R1.R2', 'R1', '01'), Iif( Posicione("SB1", 1, xFilial("SB1")+cGet1Mnt, "B1_LOCPAD") $ 'R1.R2', 'R2', '10') ), Iif( TMPEMP->TIPO $ 'PI', Iif( cParInf5 $ '1', Iif( Posicione("SB1", 1, xFilial("SB1")+cGet1Mnt, "B1_LOCPAD") $ 'R1.R2', 'R1', '02'), Iif( Posicione("SB1", 1, xFilial("SB1")+cGet1Mnt, "B1_LOCPAD") $ 'R1.R2', 'R2', '20') ), Posicione("SB1", 1, xFilial("SB1")+cGet1Mnt, "B1_LOCPAD") ) ))					   
                    TMPEMP->ACER := 0
                    TMPEMP->ORIG := "N"
                    TMPEMP->VISI := "S"
                    TMPEMP->DSCR := Iif(cFlaOrd $ '1.Z', "Pesagem", Iif(cFlaOrd $ '2.Y', "Tingimento", "Laboratorio"))
                    //TMPEMP->LCBX := Iif(TMPEMP->LOCA == '99', '99', Iif( TMPEMP->TIPO $ 'MP', Iif( cParInf5 $ '1', '01', '10' ), Iif( TMPEMP->TIPO $ 'PI', Iif( cParInf5 $ '1', '02', '20' ), TMPEMP->LOCA ) ))
					TMPEMP->LCBX := Iif(TMPEMP->ARMZ == '99', '99', Iif( TMPEMP->TIPO $ 'MP', Iif( cParInf5 $ '1', Iif( Posicione("SB1", 1, xFilial("SB1")+cGet1Mnt, "B1_LOCPAD") $ 'R1.R2', 'R1', '01'), Iif( Posicione("SB1", 1, xFilial("SB1")+cGet1Mnt, "B1_LOCPAD") $ 'R1.R2', 'R2', '10') ), Iif( TMPEMP->TIPO $ 'PI', Iif( cParInf5 $ '1', Iif( Posicione("SB1", 1, xFilial("SB1")+cGet1Mnt, "B1_LOCPAD") $ 'R1.R2', 'R1', '02'), Iif( Posicione("SB1", 1, xFilial("SB1")+cGet1Mnt, "B1_LOCPAD") $ 'R1.R2', 'R2', '20') ), TMPEMP->ARMZ ) ))					   
                 MsUnLock()
                
                 cMaxTRT := cGet2Mnt
                 If cFlaOrd $ '1.Z'
                    nGetLPes += nGet3Mnt
                 ElseIf cFlaOrd $ '2.Y'
                        nGetLPes += nGet3Mnt
                 ElseIf cFlaOrd $ '3.X'
                        nGetLPes += nGet3Mnt
                        nGetALab += nGet3Mnt
                 Endif
              Endif
           ElseIf nOpcMnt == 1
                  If cFlaOrd $ '1.Z'
                     nGetLPes -= TMPEMP->QTUS
                  ElseIf cFlaOrd $ '2.Y'
                         nGetLPes -= TMPEMP->QTUS
                  ElseIf cFlaOrd $ '3.X'
                         nGetLPes -= TMPEMP->QTUS
                         nGetALab -= TMPEMP->QTUS
                  Endif
                  RecLock("TMPEMP", .f.)
                     If nGet3Mnt == 0
                        If TMPEMP->TPEM $ 'O'
                           TMPEMP->QTUS := nGet3Mnt
                        Else
                           TMPEMP->VISI := "E"
                        Endif
                     Else
                        TMPEMP->QTUS := nGet3Mnt
                     Endif
                  MsUnLock()
                  If cFlaOrd $ '1.Z'
                     nGetLPes += nGet3Mnt
                  ElseIf cFlaOrd $ '2.Y'
                         nGetLPes += nGet3Mnt
                  ElseIf cFlaOrd $ '3.X'
                         nGetLPes += nGet3Mnt
                         nGetALab += nGet3Mnt
                  Endif
           Else
              If cFlaOrd $ '1.Z'
                 nGetLPes -= TMPEMP->QTUS
              ElseIf cFlaOrd $ '2.Y'
                     nGetLPes -= TMPEMP->QTUS
              ElseIf cFlaOrd $ '3.X'
                     nGetLPes -= TMPEMP->QTUS
                     nGetALab -= TMPEMP->QTUS
              Endif
              RecLock("TMPEMP", .f.)
                 TMPEMP->VISI := "E"
              MsUnLock()
           Endif
           If cFlaOrd $ '3.X'
              If Len(Alltrim(cGet3Lab)) == 4 .or. Len(Alltrim(cGet3Lab)) == 5 .or. Len(Alltrim(cGet3Lab)) == 6 .or. (Len(Alltrim(cGet3Lab))== 12 .and. Substr(Alltrim(cGet3Lab),11,2)=='99')
                 nGet6Lab := Round( (nGetLPes), 3)
              Else
                 nGet6Lab := Round( (nGetLPes / nGet7Lab), 3)
              Endif
           Endif
           oDlg1Mnt:End()
           DbSelectArea("TMPEMP")
           DbGoTop()
           
         
    Return
/*************************************************************************************************/

/*************************************************************************************************/
/*** 000004                F U N Ç Õ E S     D E     V A L I D A Ç Õ E S                       ***/
    /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ fVerOrdPro() - Verifica Ordem de Produção e abre botões para apontamento
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Static Function fVerOrdPro()
           Local cQry1    := ""
           Local aCadPed1 := {}
           Local lRetorna := .f.
           Local lRetMsg  := .t.
           Local nY
           Private nVolSC2:= 0
           Private nVolZZA:= 0
           If Empty(cGet1Apt)
              Return(.t.)
           Else
              If Len(Alltrim(cGet1Apt)) == 6
                 cGet1Apt := AllTrim(cGet1Apt)+'01001'
              ElseIf Len(Alltrim(cGet1Apt)) == 11
                 cGet1Apt := SubStr(cGet1Apt, 1, 11)
              Endif
           Endif
           /*********************************************/
           /***  MONTA CONEXÃO COM O BANCO DE DADOS   ***/
           /*********************************************/
           If !Empty(cParInf4)
              TCCONTYPE(cConType)
              __nConecta := TCLink(cProtect+"@!!@"+cDataBase+"/"+cAlias, cServer, nPort)  // Nao Comer Licenca do Top
              If __nConecta < 0
                 Messagebox("Não foi possível conectar ao Banco de Dados.","ERRO",48) 
                 oGet1Apt:SetFocus()
                 cGet1Apt:= space(11)
                 oGet1Apt:Refresh()
                 Return
              Endif
              TCSETCONN(__nConecta)
           Endif
           If cParInf3 $ "E"
              cQry1 := ""
              cQry1 += "SELECT SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_LOTE, SC2.C2_PRODUTO, SC2.C2_QUANT, SC2.C2_DATRF, SC2.C2_ROTEIRO, SB1.B1_TIPO, SB1.B1_ESTOQUE, SB1.B1_PESOESP, SB1.B1_DESC, SC2.C2_QUJE "
              cQry1 += "FROM SC2"+cParInf1+"0 SC2 WITH(NOLOCK) "
              cQry1 += "LEFT OUTER JOIN SB1"+cParInf1+"0 SB1 WITH(NOLOCK) ON SB1.B1_FILIAL = SC2.C2_FILIAL AND SB1.B1_COD = SC2.C2_PRODUTO AND SB1.D_E_L_E_T_ = '' "
              cQry1 += "WHERE SC2.C2_FILIAL  = '"+cParInf2+"' "
              cQry1 += "  AND SC2.D_E_L_E_T_ = '' "
              cQry1 += "  AND SC2.C2_NUM     = '"+SubStr(cGet1Apt, 1, 6)+"' "
              cQry1 += "  AND SC2.C2_ITEM    = '"+SubStr(cGet1Apt, 7, 2)+"' "
              cQry1 += "  AND SC2.C2_SEQUEN  = '"+SubStr(cGet1Apt, 9, 3)+"' "
              TCQuery cQry1 ALIAS "TCQ" NEW
              DbSelectArea("TCQ")
              If Empty(TCQ->C2_NUM)
                 Messagebox("Ordem de produção inexistente","ERRO",48) 
                 DbSelectArea("TCQ")
                 DbCloseArea()
                 lRetorna := .t.
              Else
                 cNumOrd := cGet1Apt
                 cNumLot := TCQ->C2_LOTE
                 cCodPro := TCQ->C2_PRODUTO
                 If !Empty(TCQ->C2_DATRF)
                    nVolSC2 := TCQ->C2_QUJE
                 Else
                    nVolSC2 := 0
                 Endif
                 DbSelectArea("TCQ")
                 DbCloseArea()
                 DbSelectArea("ZZA")
                 DbSetOrder(2)
                 DbSeek(xFilial("ZZA")+cNumOrd, .t.)
                 If Found()
                    If ZZA->ZZA_FLAG $ '1.2.3' //Informar envasador que o produto está parado em baixas anteriores, porém deixa continuar
                       cMsgEnv := "ATENÇÃO, PRODUTO PARADO EM BAIXAS ANTERIORES"+Chr(13)+Chr(10)
                       If ZZA->ZZA_FLAG $ '1'
                          cMsgEnv += "      AVISAR BALANCEIRO PARA DAR BAIXA      "
                       ElseIf ZZA->ZZA_FLAG $ '2'
                          cMsgEnv += "      AVISAR TINGIMENTO PARA DAR BAIXA      "
                       ElseIf ZZA->ZZA_FLAG $ '3'
                          cMsgEnv += "      AVISAR LABORATORIO PARA DAR BAIXA     "
                       Endif
                       //MsgStop(cMsgEnv)
                       Messagebox(cMsgEnv,"Atenção....",48) 
                       If ALLTRIM(GETMV("MV_APTOPPI")) $ 'N'
                          Messagebox("Atenção, não pode ser apontado envase antes de concluir apontamento do PI.","Atenção....",48) 
                          lRetorna := .t.
                       Endif
                    ElseIf ZZA->ZZA_FLAG $ '4' //Enviar mensagem para o PCP que o produto ainda não foi baixado
                           nVolZZA := ZZA->ZZA_QUANT
                           /*** MELHORIA ** / */
                           //Enviar mensagem para o PCP que o produto ainda não foi baixado
                    Endif
                 Else
                    If ALLTRIM(GETMV("MV_APTOPPI")) $ 'N'
                       Messagebox("Atenção, não pode ser apontado envase, pois o PI não foi ao menos iniciado.","Atenção....",48) 
                       lRetorna := .t.
                    Endif
                 Endif
                 If Posicione("ZZA", 2, xFilial("ZZA")+SubStr(cNumOrd, 1, 11), "ZZA_PESAPU") == 0
                    Messagebox("Necessário terminar o apontamento de Produção antes de iniciar envase, Verifique !!","Atenção....",48) 
                    lRetorna := .t.				 
				 Endif	


                 If Empty(cNumLot) .or. Len(Alltrim(cCodPro)) < 12
                    Messagebox("Ordem de produção não possui envases.","Atenção....",48) 
                    lRetorna := .t.
                 Else
                    If !lRetorna
                       oGet1Apt:lReadOnly := .t.
                       oGet1Apt:Refresh()
                       oBtnDApt:cCaption := "Voltar"
                       oBtnDApt:bAction  := {|| fAptSaiVol(2)}
                       oBtnDApt:Refresh()

                       If fVerPEnv(2)  // checar se percentual de diferença da balança para o apontamento de iniciar envase
					     	u_fEnvaseP()
					   Endif
                       
                       lRetorna := .t.
                    Endif
                 Endif
              Endif
              If lRetorna
                 oGet1Apt:SetFocus()
                 cGet1Apt := space(11)
                 oGet1Apt:Refresh()
                 oGet1Apt:lReadOnly := .f.
                 oBtnDApt:cCaption := "Sair"
                 oBtnDApt:bAction  := {|| fAptSaiVol(1)}
                 oBtnDApt:Refresh()
                 If !Empty(cParInf4)
                    //LGS#20200302 - Retirado TCQuit após mudança do dicionário de dados para o Banco de Dados
                    //TCQuit() //Desmonta conexão com o banco de dados
                 Endif
                 Return(.f.)
              Endif
           Else
              //Verificar SC2 para ver se Ordem de produção ainda não foi apontada.
              cQry1 := ""
              cQry1 += "SELECT SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_LOTE, SC2.C2_PRODUTO, SC2.C2_QUANT, SC2.C2_DATRF, SC2.C2_ROTEIRO, SB1.B1_TIPO, SB1.B1_ESTOQUE, SB1.B1_PESOESP, SB1.B1_DESC "
              cQry1 += "FROM SC2"+cParInf1+"0 SC2 WITH(NOLOCK) "
              cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON SB1.B1_FILIAL = SC2.C2_FILIAL AND SB1.B1_COD = SC2.C2_PRODUTO AND SB1.D_E_L_E_T_ = '' "
              cQry1 += "WHERE SC2.C2_FILIAL  = '"+cParInf2+"' "
              cQry1 += "  AND SC2.D_E_L_E_T_ = '' "
              cQry1 += "  AND SC2.C2_NUM     = '"+SubStr(cGet1Apt, 1, 6)+"' "
              cQry1 += "  AND SC2.C2_ITEM    = '"+SubStr(cGet1Apt, 7, 2)+"' "
              cQry1 += "  AND SC2.C2_SEQUEN  = '"+SubStr(cGet1Apt, 9, 3)+"' "
              TCQuery cQry1 ALIAS "TCQ" NEW
              DbSelectArea("TCQ")
              If Empty(TCQ->C2_NUM)
                 Messagebox("Ordem de produção inexistente","Atenção....",48) 
                 lRetorna := .t.
              Else
                 If !Empty(TCQ->C2_DATRF)
                    //MsgStop('Ordem de produção já foi encerrada')
                    //lRetorna := .t.
                    cNumOrd := TCQ->C2_NUM+TCQ->C2_ITEM+TCQ->C2_SEQUEN
                    cNumLot := TCQ->C2_LOTE
                    cNumPro := TCQ->C2_PRODUTO
                    cTipPro := TCQ->B1_TIPO
                    cDesPro := TCQ->B1_DESC
                    cNumRot := TCQ->C2_ROTEIRO
                    cProEst := TCQ->B1_ESTOQUE
                 Else
                    cNumOrd := TCQ->C2_NUM+TCQ->C2_ITEM+TCQ->C2_SEQUEN
                    cNumLot := TCQ->C2_LOTE
                    cNumPro := TCQ->C2_PRODUTO
                    nQtdPro := TCQ->C2_QUANT
                    cNumRot := TCQ->C2_ROTEIRO
                    cTipPro := TCQ->B1_TIPO
                    nPesEsp := TCQ->B1_PESOESP
                    cDesPro := TCQ->B1_DESC
                    cProEst := TCQ->B1_ESTOQUE
                 Endif
              Endif
              DbSelectArea("TCQ")
              DbCloseArea()
              If lRetorna
                 oGet1Apt:SetFocus()
                 cGet1Apt := space(11)
                 oGet1Apt:Refresh()
                 If !Empty(cParInf4)
                    //LGS#20200302 - Retirado TCQuit após mudança do dicionário de dados para o Banco de Dados
                    //TCQuit() //Desmonta conexão com o banco de dados
                 Endif
                 Return(.f.)
              Else
                 If !cTipPro $ 'PI'
                    Messagebox("Essa Ordem de produção não é a principal","Atenção....",48) 
                    oGet1Apt:SetFocus()
                    cGet1Apt := space(11)
                    oGet1Apt:Refresh()
                    If !Empty(cParInf4)
                       //LGS#20200302 - Retirado TCQuit após mudança do dicionário de dados para o Banco de Dados
                       //TCQuit() //Desmonta conexão com o banco de dados
                    Endif
                    Return(.f.)
                 Endif
              Endif
              //Verificar SG2 para buscar operações
              cQry1 := "SELECT SG2.G2_CODIGO, SG2.G2_OPERAC, SG2.G2_DESCRI "
              cQry1 += "FROM SG2"+cParInf1+"0 SG2 WITH(NOLOCK) "
              cQry1 += "WHERE SG2.G2_FILIAL  = '"+cParInf2+"' "
              cQry1 += "  AND SG2.D_E_L_E_T_ = '' "
              cQry1 += "  AND SG2.G2_CODIGO  = '"+cNumRot+"' "
              cQry1 += "  AND SG2.G2_PRODUTO = '"+cNumPro+"' "
              cQry1 += "ORDER BY SG2.G2_OPERAC "
              TCQuery cQry1 ALIAS "TCQ" NEW
              DbSelectArea("TCQ")
              If Empty(TCQ->G2_CODIGO)
                 Messagebox("Produto não possui roteiro padrão cadastrado.","Atenção....",48) 
                 lRetorna := .t.
              Else
                 aRotProd := {}
                 While !Eof()
                       aAdd(aRotProd, {TCQ->G2_OPERAC, TCQ->G2_DESCRI, ''})
                       DbSelectArea("TCQ")
                       DbSkip()
                 EndDo
              Endif
              DbSelectArea("TCQ")
              DbCloseArea()
              If lRetorna
                 oGet1Apt:SetFocus()
                 cGet1Apt := space(11)
                 oGet1Apt:Refresh()
                 If !Empty(cParInf4)
                    //LGS#20200302 - Retirado TCQuit após mudança do dicionário de dados para o Banco de Dados
                    //TCQuit() //Desmonta conexão com o banco de dados
                 Endif
                 Return(.f.)
              Endif

              //Verificar SH6 para buscar operações baixadas
              For nY := 1 To Len(aRotProd)
                  cQry1 := ""
                  cQry1 += "SELECT SH6.H6_OP, SH6.H6_PRODUTO, SH6.H6_OPERAC "
                  cQry1 += "FROM SH6"+cParInf1+"0 SH6 WITH(NOLOCK) "
                  cQry1 += "WHERE SH6.H6_FILIAL  = '"+cParInf2+"' "
                  cQry1 += "  AND SH6.D_E_L_E_T_ = '' "
                  cQry1 += "  AND SH6.H6_OP      = '"+cNumOrd+"' "
                  cQry1 += "  AND SH6.H6_OPERAC  = '"+aRotProd[nY][1]+"'"
                  TCQuery cQry1 ALIAS "TCQ" NEW
                  DbSelectArea("TCQ")
                  If Empty(TCQ->H6_OPERAC)
                     aRotProd[nY][3] := 'N'
                  Else
                     aRotProd[nY][3] := 'S'
                  Endif
                  DbSelectArea("TCQ")
                  DbCloseArea()
              Next

              //Verificar ZZA para buscar informações do apontamento
              cQry1 := ""
              cQry1 += "SELECT ZZA.ZZA_ORDEM, ZZA.ZZA_FLAG, ZZA.ZZA_TARA, ZZA.ZZA_DTINI, ZZA.ZZA_HINI, ZZA.ZZA_DTPES, ZZA.ZZA_HPES, ZZA.ZZA_DTCOL, ZZA.ZZA_HCOL, ZZA.ZZA_DTFIM, ZZA.ZZA_HFIM "
              cQry1 += "FROM ZZA"+cParInf1+"0 ZZA WITH(NOLOCK) "
              cQry1 += "WHERE ZZA.ZZA_FILIAL  = '"+cParInf2+"' "
              cQry1 += "  AND ZZA.D_E_L_E_T_  = '' "
              cQry1 += "  AND ZZA.ZZA_ORDEM   = '"+cNumOrd+"' "
              TCQuery cQry1 ALIAS "TCQ" NEW
              DbSelectArea("TCQ")
              If Empty(TCQ->ZZA_ORDEM)
                 cFlaOrd := ' '
                 lJaGrvA := .f.
                 // verificar falta de saldo e se existe necessidade maior neste momento chamado 007858
		         If Alltrim(GETMV("MV_BLQOPSAL")) $ 'S'	
                     If fBloqOpSal()
	                     fAbaAptPro()				                       
	                     Messagebox("Ordem de Produção não foi iniciada por falta de saldo disponível!","Atenção...",48)
            		     If !Empty(cParInf4)
            	        	//LGS#20200302 - Retirado TCQuit após mudança do dicionário de dados para o Banco de Dados
            	        	//TCQuit() //Desmonta conexão com o banco de dados
        	        	 Endif
		                 Return(.f.)
   					 Endif
   				 Endif
              Else
                 cFlaOrd := TCQ->ZZA_FLAG
                 nPesTar := TCQ->ZZA_TARA
                 lJaGrvA := .t.
                 dDatIni := STOD(TCQ->ZZA_DTINI)
                 hHorIni := SubStr(TCQ->ZZA_HINI, 1, 2)+":"+SubStr(TCQ->ZZA_HINI, 3, 2)
                 dDatPes := STOD(TCQ->ZZA_DTPES)
                 hHorPes := SubStr(TCQ->ZZA_HPES, 1, 2)+":"+SubStr(TCQ->ZZA_HPES, 3, 2)
                 dDatCol := STOD(TCQ->ZZA_DTCOL)
                 hHorCol := SubStr(TCQ->ZZA_HCOL, 1, 2)+":"+SubStr(TCQ->ZZA_HCOL, 3, 2)
                 dDatLab := STOD(TCQ->ZZA_DTFIM)
                 dHorLab := SubStr(TCQ->ZZA_HFIM, 1, 2)+":"+SubStr(TCQ->ZZA_HFIM, 3, 2)
              Endif
              DbSelectArea("TCQ")
              DbCloseArea()
              oGet1Apt:lReadOnly := .t.
              oGet1Apt:Refresh()
              oBtnDApt:cCaption := "Voltar"
              oBtnDApt:bAction  := {|| fAptSaiVol(2)}
              oBtnDApt:Refresh()
              If cFlaOrd $ ' '
                 If cTipPro $ 'PI' .and. Len(Alltrim(cNumPro)) == 12
       	   	         If GetMv("MV_XLIBOPE") == .F.
	 	  	    	      cQry1 := ""
		    	          cQry1 += " SELECT C6_FILIAL, C6_PRODUTO, C6_DESCRI, SUM(C6_QTDVEN) AS C6_QTDVEN, "
			              cQry1 += " (SELECT SUM(B2_QATU) FROM "+RetSqlName("SB2")+" WITH(NOLOCK) WHERE B2_FILIAL = C6_FILIAL AND B2_COD = C6_PRODUTO AND B2_LOCAL NOT IN('13','G1')) AS 'SALDOATUAL', "
		    	          cQry1 += " (SELECT ISNULL(SUM(C2_QUANT),0) FROM "+RetSqlName("SC2")+" WITH(NOLOCK) WHERE C2_FILIAL = C6_FILIAL AND C2_PRODUTO = C6_PRODUTO AND D_E_L_E_T_ ='' AND C2_DATRF ='' AND C2_QUJE =0 ) AS 'SALDOOPS' ,B1_ESTOQUE "
	            		  cQry1 += " FROM "+RetSqlName("SC6")+" SC6 WITH(NOLOCK) "
	        	    	  cQry1 += " LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH(NOLOCK) ON C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM AND SC5.D_E_L_E_T_ ='' "
		    	          cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON B1_FILIAL = C6_FILIAL AND B1_COD = C6_PRODUTO AND SB1.D_E_L_E_T_ ='' "
			              cQry1 += " LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH(NOLOCK) ON F4_FILIAL = '' AND C6_TES = F4_CODIGO AND SF4.D_E_L_E_T_ ='' "
			              cQry1 += " WHERE SC6.D_E_L_E_T_ ='' AND C6_FILIAL ='"+xFilial("SC6")+"' "
	        	    	  cQry1 += " AND C5_APROVA ='1' AND C6_NOTA ='' "
	        		      cQry1 += " AND SUBSTRING(SC6.C6_PRODUTO, 1, 10) = '"+SubStr(cNumPro, 1, 10)+"' "
	    	        	  cQry1 += " AND F4_ESTOQUE <>'N' "
	    	    	      cQry1 += " GROUP BY C6_FILIAL, C6_PRODUTO, C6_DESCRI,B1_ESTOQUE "

		        	      TCQuery cQry1 ALIAS "TCQ" NEW
    			          DbSelectArea("TCQ")
        			      DbGoTop()              
	            		  While !Eof()
							   If ((TCQ->SALDOATUAL + TCQ->SALDOOPS) < TCQ->C6_QTDVEN) .AND. TCQ->B1_ESTOQUE <> 'S'
					    		  aAdd(aCadPed1, {TCQ->C6_PRODUTO, TCQ->C6_DESCRI, Iif(TCQ->B1_ESTOQUE == 'S', 'SIM', 'NÃO'), TRANSFORM(TCQ->C6_QTDVEN, "@E 999999"), TRANSFORM(TCQ->SALDOATUAL, "@E 999999"), TRANSFORM(TCQ->SALDOOPS, "@E 999999"), TRANSFORM((TCQ->SALDOATUAL+TCQ->SALDOOPS),"@E 999999") })						                    
		    	               Endif
    			               DbSelectArea("TCQ")
	    	    	           DbSkip()
            			  Enddo
	    	    	      DbSelectArea("TCQ")
    		        	  DbCloseArea()              
				  
						  If Len(aCadPed1) > 0  .AND. Posicione("SC2", 1, xFilial("SC2")+cNumOrd, "C2_XLIBOPE") <> "S"
				    	      Messagebox("Existem pedidos que foram aprovados após a emissão desta ordem de produção e devem ser fabricados juntos, verifique com PCP !!","Atenção...",48) 				
							  cAuxMens := "Pedido com Produto específico aprovado após emissão deste lote "+chr(13)+chr(10)
					   	
	    		    	      For nY := 1 To Len(aCadPed1)
						    	  cAuxMens +="Lote.........: "+(cNumLot)+"   O.P : "+(cNumOrd)+chr(13)+chr(10)
								  cAuxMens +="Produto......: "+aCadPed1[nY][1]+" - "+aCadPed1[nY][2]+chr(13)+chr(10)
								  cAuxMens +="Qtd Pedidos..: "+aCadPed1[nY][4]+" (Saldo Atual + Ops em Aberto)..: "+(aCadPed1[nY][7])+chr(13)+chr(10)
								  cAuxMens +="Saldo Atual..: "+aCadPed1[nY][5]+" Ops em Aberto..: "+aCadPed1[nY][6]+chr(13)+chr(10)
	 					    	  cAuxMens +=" "+chr(13)+chr(10)
			   	              Next
							  cAuxMens += chr(13)+chr(10)+"Prog. Origem : BRPCPA08"
        		
   							  If Substr(xFilial("ZZA"),1,2)== "06"
								  //U_EnvMail("DISSOLTEX - Lote "+cNumLot+" deve ser analisado, pois existe necessidade de produção maior do que este lote. !",cAuxMens,silene@brasilux.com.br","")                       	  
	       			   		  Else
	   					    	  U_EnvMail("BRASILUX - Lote "+cNumLot+" deve ser analisado, pois existe necessidade de produção maior do que este lote. !",cAuxMens,"pcp@brasilux.com.br","")                       	  
							  Endif   
	              
				              If !Empty(cParInf4)
				                 //LGS#20200302 - Retirado TCQuit após mudança do dicionário de dados para o Banco de Dados
			            	     //TCQuit() //Desmonta conexão com o banco de dados
    			    	      Endif
       					      fAptSaiVol(2)
        	    			  Return(.f.)  
    		         	  Endif    
		        	 Endif
	                 lRetMsg := fVerMaiOrd()
                 Endif
                 If !lRetMsg
                    If !Empty(cParInf4)
                       /*********************************************/
                       /*** DESMONTA CONEXÃO COM O BANCO DE DADOS ***/
                       /* ********************************************/
                       //LGS#20200302 - Retirado TCQuit após mudança do dicionário de dados para o Banco de Dados
                       //TCQuit() //Desmonta conexão com o banco de dados
                    Endif
                    Return
                 Endif
                 //oBtn1Apt:lVisible := .t.
                 //oBtn1Apt:Refresh()
                 fAptIniPro()     //Aponta inicio/ fim da pesagem
              ElseIf cFlaOrd $ '1.Z'
                     fAptIniPro() //Aponta inicio/ fim da pesagem
              ElseIf cFlaOrd $ '2.Y'
                     If Posicione("ZZA", 2, xFilial("ZZA")+SubStr(cNumOrd, 1, 11), "ZZA_PESAPB") > 0
                     	If fVerPEnv(1) // Verificar se o peso esta dentro ou fora da Margem estabelecida
                     		fAptColPro() //Aponta colorista 
                     	Endif	
                     Else
                     	u_fPesApu(1)  // Aponta peso Balança após Pesagem
                     Endif	
              ElseIf cFlaOrd $ '3.X'
                     fAptLabPro() //Aponta Laboratorio
              ElseIf cFlaOrd $ '4.H'
                     If Posicione("ZZA", 2, xFilial("ZZA")+SubStr(cNumOrd, 1, 11), "ZZA_PESAPU") > 0
						If fVerPEnv(2)
							fEstLabPro()					 
						Endif
					 Else
	                     u_fPesApu(2)
	     			 Endif
              ElseIf cFlaOrd $ '5' //Estorna Ordens de produção
                     If Posicione("ZZA", 2, xFilial("ZZA")+SubStr(cNumOrd, 1, 11), "ZZA_PESAPU") > 0
						If fVerPEnv(2)
							fEstLabPro()					 
						Endif	
					 Else
	                     u_fPesApu(2)// Aponta peso Balança após Laboratório
	     			 Endif
              Endif
           Endif
           If !Empty(cParInf4)
              /*********************************************/
              /*** DESMONTA CONEXÃO COM O BANCO DE DADOS ***/
              /*********************************************/
              //LGS#20200302 - Retirado TCQuit após mudança do dicionário de dados para o Banco de Dados
              //TCQuit() //Desmonta conexão com o banco de dados
           Endif
    Return

    /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ fValCodMnt() - Validação da manutenção dos itens empenhados
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Static Function fValCodMnt(nOpcMnt)
           If nOpcMnt == 0
              DbSelectArea("SB1")
              DbSetOrder(1)
              DbSeek(xFilial("SB1")+cGet1Mnt, .t.)
              If Found() 
                 If SB1->B1_MSBLQL <> '1'
                    If SB1->B1_TIPO $ 'MP.PI'
                       cGet4Mnt := SB1->B1_DESC
                       cGet2Mnt := STRZERO(Val(cMaxTrt)+5, 3)
                       cGet5Mnt := iif(SB1->B1_APROPRI = "I","99",SB1->B1_LOCPAD)
                       oGet4Mnt:Refresh()
                       oGet2Mnt:Refresh()
                       oGet3Mnt:SetFocus()
                       lOpcMnt := .t.
                    Else
                       Messagebox("Produto não é MP ou PI, verifique!!!","Atenção...",48)
                       oGet1Mnt:SetFocus()
                       cGet1Mnt := space(15)
                       oGet1Mnt:Refresh()
                       cGet4Mnt := space(30)
                       oGet4Mnt:Refresh()
                       cGet2Mnt := space(3)
                       oGet2Mnt:Refresh()
                       nGet3Mnt := 0
                       oGet3Mnt:Refresh()
                    Endif
                 Else
                    Messagebox("Produto bloqueado, verifique!!!","Atenção...",48)
                    oGet1Mnt:SetFocus()
                    cGet1Mnt := space(15)
                    oGet1Mnt:Refresh()
                    cGet4Mnt := space(30)
                    oGet4Mnt:Refresh()
                    cGet2Mnt := space(3)
                    oGet2Mnt:Refresh()
                    nGet3Mnt := 0
                    oGet3Mnt:Refresh()
                 Endif
              Else
                 Messagebox("Produto inválido, verifique!!!","Atenção...",48)
                 oGet1Mnt:SetFocus()
                 cGet1Mnt := space(15)
                 oGet1Mnt:Refresh()
                 cGet4Mnt := space(30)
                 oGet4Mnt:Refresh()
                 cGet2Mnt := space(3)
                 oGet2Mnt:Refresh()
                 nGet3Mnt := 0
                 oGet3Mnt:Refresh()
              Endif
           Endif
    Return
    /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ fValTarTac() - Valida digitação da Tara
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Static Function fValTarTac()
           Local lRet := .t.
           If nGet9Ini <= 0.0
              Messagebox("O Valor da tara tem que ser maior que zero!!","Atenção...",48) 
              lRet := .f.
              oGet9Ini:SetFocus()
           Else
              If nGet9Ini > 3000
                 If !MsgYesNo('Valor da tara maior que 3000 Kg. Confirma?!')
                    lRet := .f.
                    oGet9Ini:SetFocus()
                 Endif
              Endif
           Endif
    Return(lRet)

    /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ fValRecTac() - Valida digitação do Recurso
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Static Function fValRecTac()
           Local lRet := .t.
           If !Empty(cGet8Ini)
              cQry1 := ""
              cQry1 += "SELECT SH1.H1_CODIGO, SH1.H1_DESCRI "
              cQry1 += "FROM SH1"+cParInf1+"0 SH1 WITH (NOLOCK) "
              cQry1 += "WHERE SH1.H1_FILIAL = '"+cParInf2+"' "
              cQry1 += "  AND SH1.D_E_L_E_T_ = '' "
              cQry1 += "  AND SH1.H1_CODIGO = '"+cGet8Ini+"' "
              TCQuery cQry1 ALIAS "TCQ" NEW
              DbSelectArea("TCQ")
              If TCQ->H1_CODIGO <> cGet8Ini
                 Messagebox("Recurso digitado é inválido!!","Atenção...",48) 
                 cGet8Ini := space(06)
                 nGet9Ini := 0
                 cGetAIni := space(30)
                 oGet8Ini:SetFocus()
                 oGet8Ini:Refresh()
                 oGet9Ini:Refresh()
                 oGetAIni:Refresh()
                 lRet := .f.
              Else
                 oGet9Ini:SetFocus()
                 cGetAIni := TCQ->H1_DESCRI
                 oGet9Ini:Refresh()
                 oGetAIni:Refresh()
              Endif
              DbSelectArea("TCQ")
              DbCloseArea()
           Else
              Messagebox("Atenção, recruso não foi apontado. Verifique!!!","Atenção...",48)
              oGet8Ini:SetFocus()
           Endif
    Return(lRet)

    /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ fVerMaiOrd() - Verifica ordens de produção desse mesmo produto e pedidos ainda em abertos.
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Static Function fVerMaiOrd()
           Local aCadOps := {}
           Local cMsgApt := ""
           //Local cAuxMens:= ""
           Local aCadPed := {}
           //Local aCadPed1:= {}
           Local lNaoApt := .f.
           Local nOpcA   := 0
           //Local lRetMsg := .f.
           Local nY

           cQry1 := ""
           cQry1 += "SELECT SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN AS OP, SC2.C2_EMISSAO AS EMISSAO, SC2.C2_QUANT AS QUANT, ISNULL(PRO.ZZA_FLAG, '') AS FLAG "
           cQry1 += "FROM SC2"+cParInf1+"0 SC2 WITH (NOLOCK) "
           cQry1 += "LEFT OUTER JOIN "+RetSqlName("ZZA")+" PRO WITH (NOLOCK) ON PRO.ZZA_FILIAL = SC2.C2_FILIAL AND PRO.ZZA_ORDEM = SC2.C2_OP AND PRO.D_E_L_E_T_ = '' "
           cQry1 += "WHERE SC2.C2_FILIAL  = '"+cParInf2+"' "
           cQry1 += "  AND SC2.D_E_L_E_T_ = '' "
           cQry1 += "  AND SC2.C2_OP    <> '"+cNumOrd+"' "                                           '
           cQry1 += "  AND SC2.C2_PRODUTO = '"+cNumPro+"' "
           cQry1 += "  AND SC2.C2_DATRF   = '' "
           TCQuery cQry1 ALIAS "TCQ" NEW
           DbSelectArea("TCQ")
           DbGoTop()
           While !Eof()
                 aAdd(aCadOps, {TCQ->OP, SubStr(TCQ->EMISSAO, 7, 2)+'/'+SubStr(TCQ->EMISSAO, 5, 2)+'/'+SubStr(TCQ->EMISSAO, 1, 4), TCQ->QUANT, Iif(Empty(TCQ->FLAG), 'NÃO', 'SIM') })
                 DbSelectArea("TCQ")
                 DbSkip()
           Enddo
           DbSelectArea("TCQ")
           DbCloseArea()

           If Len(aCadOps) > 0
              //d) Verifica se as Ordens de Produção encontradas já foram ou não iniciadas.
              cMsgApt += '          APONTAMENTO DE ORDENS DE PRODUÇÃO          '+Chr(13)+Chr(10)
              cMsgApt += '+---------------+------------+----------+-----------+'+Chr(13)+Chr(10)
              cMsgApt += '|  ORDEM PROD.  |   EMISSAO  | INICIADA |   QTDE.   |'+Chr(13)+Chr(10)
              cMsgApt += '+---------------+------------+----------+-----------+'+Chr(13)+Chr(10)
              For nY := 1 To Len(aCadOps)
                  cMsgApt += '| '+SubStr(aCadOps[nY][1], 1, 6)+'-'+SubStr(aCadOps[nY][1], 7, 2)+'-'+SubStr(aCadOps[nY][1], 9, 3)+' | '+aCadOps[nY][2]+' |    '+aCadOps[nY][4]+'   | '+Transform(aCadOps[nY][3], "@E 99,999.99")+' |'+Chr(13)+Chr(10)
                  cMsgApt += '+---------------+------------+----------+-----------+'+Chr(13)+Chr(10)
              Next
           Endif
           If !cProEst $ 'S' .and. Len(Alltrim(cNumPro)) >= 12
   	          /*
   	          If GetMv("MV_XLIBOPE") == .F. 
 	  	          cQry1 := ""
	              cQry1 += " SELECT C6_FILIAL, C6_PRODUTO, C6_DESCRI, SUM(C6_QTDVEN) AS C6_QTDVEN, "
	              cQry1 += " (SELECT SUM(B2_QATU) FROM "+RetSqlName("SB2")+" WITH(NOLOCK) WHERE B2_FILIAL = C6_FILIAL AND B2_COD = C6_PRODUTO AND B2_LOCAL NOT IN('13','G1')) AS 'SALDOATUAL', "
	              cQry1 += " (SELECT ISNULL(SUM(C2_QUANT),0) FROM "+RetSqlName("SC2")+" WITH(NOLOCK) WHERE C2_FILIAL = C6_FILIAL AND C2_PRODUTO = C6_PRODUTO AND D_E_L_E_T_ ='' AND C2_DATRF ='' AND C2_QUJE =0 ) AS 'SALDOOPS' ,B1_ESTOQUE "
	              cQry1 += " FROM "+RetSqlName("SC6")+" SC6 WITH(NOLOCK) "
	              cQry1 += " LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH(NOLOCK) ON C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM AND SC5.D_E_L_E_T_ ='' "
	              cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON B1_FILIAL = C6_FILIAL AND B1_COD = C6_PRODUTO AND SB1.D_E_L_E_T_ ='' "
	              cQry1 += " LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH(NOLOCK) ON F4_FILIAL = '' AND C6_TES = F4_CODIGO AND SF4.D_E_L_E_T_ ='' "
	              cQry1 += " WHERE SC6.D_E_L_E_T_ ='' AND C6_FILIAL ='"+xFilial("SC6")+"' "
	              cQry1 += " AND C5_APROVA ='1' AND C6_NOTA ='' "
	              cQry1 += " AND SUBSTRING(SC6.C6_PRODUTO, 1, 10) = '"+SubStr(cNumPro, 1, 10)+"' "
    	          cQry1 += " AND F4_ESTOQUE <>'N' "
        	      cQry1 += " GROUP BY C6_FILIAL, C6_PRODUTO, C6_DESCRI,B1_ESTOQUE "

	              TCQuery cQry1 ALIAS "TCQ" NEW
    	          DbSelectArea("TCQ")
        	      DbGoTop()              
            	  While !Eof()
					   If ((TCQ->SALDOATUAL + TCQ->SALDOOPS) < TCQ->C6_QTDVEN) .AND. TCQ->B1_ESTOQUE <> 'S'
				    	  aAdd(aCadPed1, {TCQ->C6_PRODUTO, TCQ->C6_DESCRI, Iif(TCQ->B1_ESTOQUE == 'S', 'SIM', 'NÃO'), TRANSFORM(TCQ->C6_QTDVEN, "@E 999999"), TRANSFORM(TCQ->SALDOATUAL, "@E 999999"), TRANSFORM(TCQ->SALDOOPS, "@E 999999"), TRANSFORM((TCQ->SALDOATUAL+TCQ->SALDOOPS),"@E 999999") })						                    
	                   Endif
    	               DbSelectArea("TCQ")
        	           DbSkip()
            	  Enddo
	              DbSelectArea("TCQ")
    	          DbCloseArea()              
				  
				  If Len(aCadPed1) > 0  .AND. Posicione("SC2", 1, xFilial("SC2")+cNumOrd, "C2_XLIBOPE") <> "S"
			          Messagebox("Existem pedidos que foram aprovados após a emissão desta ordem de produção e devem ser fabricados juntos, verifique com PCP !!","Atenção...",48) 				
					  cAuxMens := "Pedido com Produto específico aprovado após emissão deste lote "+chr(13)+chr(10)
					   	
	        	      For nY := 1 To Len(aCadPed1)
   					      cAuxMens +="Lote.........: "+(cNumLot)+"   O.P : "+(cNumOrd)+chr(13)+chr(10)
						  cAuxMens +="Produto......: "+aCadPed1[nY][1]+" - "+aCadPed1[nY][2]+chr(13)+chr(10)
						  cAuxMens +="Qtd Pedidos..: "+aCadPed1[nY][4]+" (Saldo Atual + Ops em Aberto)..: "+(aCadPed1[nY][7])+chr(13)+chr(10)
						  cAuxMens +="Saldo Atual..: "+aCadPed1[nY][5]+" Ops em Aberto..: "+aCadPed1[nY][6]+chr(13)+chr(10)
 				    	  cAuxMens +=" "+chr(13)+chr(10)
	   	              Next
					  cAuxMens += chr(13)+chr(10)+"Prog. Origem : BRPCPA08"
        	
   					  If Substr(xFilial("ZZA"),1,2)== "06"
						  //U_EnvMail("DISSOLTEX - Lote "+cNumLot+" deve ser analisado, pois existe necessidade de produção maior do que este lote. !",cAuxMens,silene@brasilux.com.br","")                       	  
	       		   	  Else
	   				      U_EnvMail("BRASILUX - Lote "+cNumLot+" deve ser analisado, pois existe necessidade de produção maior do que este lote. !",cAuxMens,"pcp@brasilux.com.br","")                       	  
					  Endif   
	              
		              If !Empty(cParInf4)
		                 TCQuit(__nConecta) //Desmonta conexão com o banco de dados
    		          Endif
       			      fAptSaiVol(2)
            		  Return(.f.)  

    	          Endif    
        	  Endif     */
             
              
              //e) Se o produto não for de estoque verificar se exitem outros pedidos em aberto para o item
              cQry1 := ""
              cQry1 += "SELECT SC6.C6_NUM AS PEDIDO, SUBSTRING(SC6.C6_PRODUTO, 11, 2) AS EMBALAGEM, SC6.C6_QTDVEN AS QUANT, SC5.C5_APROVA AS APROVA "
              cQry1 += "FROM SC6"+cParInf1+"0 SC6 WITH(NOLOCK) "
              cQry1 += "LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH(NOLOCK) ON SC5.C5_FILIAL = '"+xFilial("SC5")+"' AND SC5.C5_NUM = SC6.C6_NUM AND SC5.D_E_L_E_T_ = '' "
              cQry1 += "WHERE SC6.C6_FILIAL  = '"+cParInf2+"' "
              cQry1 += "  AND SC6.D_E_L_E_T_ = '' "
              cQry1 += "  AND SC6.C6_NOTA    = '' "
              cQry1 += "  AND SUBSTRING(SC6.C6_PRODUTO, 1, 10) = '"+SubStr(cNumPro, 1, 10)+"' "
              //cQry1 += "  AND SC6.C6_NUMOP   = '' "
              cQry1 += "  AND SC5.C5_APROVA = '1' "
              cQry1 += "ORDER BY 1, 2
              TCQuery cQry1 ALIAS "TCQ" NEW
              DbSelectArea("TCQ")
              DbGoTop()
              While !Eof()
                    aAdd(aCadPed, {TCQ->PEDIDO, TCQ->EMBALAGEM, Iif(TCQ->APROVA == '1', 'SIM', 'NÃO'),  TRANSFORM(TCQ->QUANT, "@E 999999")})
                    DbSelectArea("TCQ")
                    DbSkip()
              Enddo
              DbSelectArea("TCQ")
              DbCloseArea()
              If Len(aCadPed) > 0
                 cMsgApt += ''+Chr(13)+Chr(10)
                 cMsgApt += ''+Chr(13)+Chr(10)
                 cMsgApt += '   PEDIDOS EM ABERTO SEM ORDENS DE PRODUÇÃO    '+Chr(13)+Chr(10)
                 cMsgApt += '+--------+------------+-------------+---------+'+Chr(13)+Chr(10)
                 cMsgApt += '| PEDIDO |  APROVADO  |  EMBALAGEM  |  QTDE.  |'+Chr(13)+Chr(10)
                 cMsgApt += '+--------+------------+-------------+---------+'+Chr(13)+Chr(10)
                 For nY := 1 To Len(aCadPed)
                     If aCadPed[nY][3] $ 'SIM'
                        lNaoApt := .t.
                     Endif
                     cMsgApt += '| '+aCadPed[nY][1]+' |    '+aCadPed[nY][3]+'     |     '+aCadPed[nY][2]+'      | '+aCadPed[nY][4]+'  |'+Chr(13)+Chr(10)
                     cMsgApt += '+--------+------------+-------------+---------+'+Chr(13)+Chr(10)
                 Next
              Endif
           Endif
           If !Empty(cMsgApt)
              /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
              ±± Declaração de cVariable dos componentes                                 ±±
              Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
              Private cMGet1Ms

              /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
              ±± Declaração de Variaveis Private dos Objetos                             ±±
              Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
              SetPrvt("oFontMsg", "oDlg1Msg", "oMGet1Ms")

              /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
              ±± Definicao do Dialog e todos os seus componentes.                        ±±
              Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
              cMGet1Ms   := cMsgApt
              oFontMsg   := TFont():New( "Courier New", 0, -15, , .F., 0, , 400, .F., .F., , , , , , )
              oDlg1Msg   := MSDialog():New( 229, 256, 600, 770, "Aviso", , , .F., , , , , , .T., , , .T. )
              oMGet1Ms   := TMultiGet():New( 003, 003, {|u| If(PCount() > 0, cMGet1Ms := u, cMGet1Ms)}, oDlg1Msg, 252,180, oFontMsg, , CLR_BLACK, CLR_WHITE, , .T., "", , , .F., .F., .F., , , .F., , )

              oDlg1Msg:Activate(, , , .T.)
           Endif
           If lNaoApt
              /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
              ±± Declaração de cVariable dos componentes                                 ±±
              Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
              Private cSay1Avs   := Space(1)
              Private cSay2Avs   := Space(1)

              /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
              ±± Declaração de Variaveis Private dos Objetos                             ±±
              Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
              SetPrvt("oFontAvs", "oDlg1Avs", "oSay1Avs", "oSay2Avs", "oBtn1Avs", "oBtn2Avs")

              /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
              ±± Definicao do Dialog e todos os seus componentes.                        ±±
              Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
              lSai1Avs   := .f.
              oFontAvs   := TFont():New( "Courier New", 0, -20, , .T., 0, , 700, .F., .F., , , , , , )
              oDlg1Avs   := MSDialog():New( 282, 250, 405, 945, "Aviso", , , .F., , , , , , .T., , , .T. )
              oSay1Avs   := TSay():New( 008, 003, {|| "               ATENÇÃO, PRODUTO ESPECÍFICO             "}, oDlg1Avs, , oFontAvs, .F., .F., .F., .T., CLR_RED, CLR_WHITE, 340, 012)
              oSay2Avs   := TSay():New( 024, 003, {|| "  *** EXISTEM PRODUTOS LIBERADOS SEM OP, CONTINUA ? ***"}, oDlg1Avs, , oFontAvs, .F., .F., .F., .T., CLR_RED, CLR_WHITE, 340, 012)
              oBtn1Avs   := TButton():New( 040, 304, "ABANDONA", oDlg1Avs, { || nOpcA := 0, lSai1Avs := .t., oDlg1Avs:End()}, 037, 012, , , , .T., , "", , , , .F. )
              oBtn2Avs   := TButton():New( 040, 256, "CONTINUA", oDlg1Avs, { || nOpcA := 1, lSai1Avs := .t., oDlg1Avs:End()}, 037, 012, , , , .T., , "", , , , .F. )
              oDlg1Avs:bValid := {|| lSai1Avs }
              oDlg1Avs:nStyle := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
              oDlg1Avs:Activate(, , , .t.)
           Else
              nOpcA := 1
           Endif
           If nOpcA == 0
              If !Empty(cParInf4)
                 /*********************************************/
                 /*** DESMONTA CONEXÃO COM O BANCO DE DADOS ***/
                 /*********************************************/
                 //LGS#20200302 - Retirado TCQuit após mudança do dicionário de dados para o Banco de Dados
                 //TCQuit() //Desmonta conexão com o banco de dados
              Endif
              fAptSaiVol(2)
              Return(.f.)
           Endif
    Return(.t.)

    /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ fMntQtd() - Manutenção de Quantidades
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/               // alteração da medida no processo de tingimento conforme solicitação de Lucio - 28-10-11 (andré)
    Static Function fMntQtd(cOpcMnt, cProcesso)
           If SubStr(cOpcMnt, 1, 1) $ 'A' //Adiciona
              If SubStr(cOpcMnt, 2, 1) $ '1'
                  If cProcesso $ '01' // Fim da Pesagem
                      nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) + 0.001
                  ElseIf cProcesso $ '04' // Tingimento
                      nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) + 0.001
                  ElseIf cProcesso $ '90' // Laboratorio
                      nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) + 0.001
                  Else
                      nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) + 1
                  Endif
              ElseIf SubStr(cOpcMnt, 2, 1) $ '2'
                  If cProcesso $ '01' // Fim da Pesagem
                      nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) + 0.01
                  ElseIf cProcesso $ '04' // Tingimento
                      nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) + 0.01
                  ElseIf cProcesso $ '90' // Laboratorio
                      nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) + 0.01
                  Else
                      nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) + 10
                  Endif
              ElseIf SubStr(cOpcMnt, 2, 1) $ '3'
                  If cProcesso $ '01' // Fim da Pesagem
                      //nGet1Aju := Int(nGet1Aju) + (Int(Int((nGet1Aju - Int(nGet1Aju)) * 1000) / 100) + 1) / 10
                      nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) + 0.1
                  ElseIf cProcesso $ '04' // Tingimento
                      nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) + 0.1 
                  ElseIf cProcesso $ '90' // Laboratorio
                      nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) + 0.1
                  Else
                      nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) + 50
                  Endif
              ElseIf SubStr(cOpcMnt, 2, 1) $ '4'
                  If cProcesso $ '01' // Fim da Pesagem
				      //nGet1Aju := (Int(nGet1Aju) + 1) + ((Int(Int((nGet1Aju - Int(nGet1Aju)) * 1000) / 100) * 100) ) / 1000
				      nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) + 1 
                  ElseIf cProcesso $ '04' // Tingimento
                      nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) + 1 
                  ElseIf cProcesso $ '90' // Laboratorio
                      nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) + 1
                  Else
                      nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) + 100
                  Endif
              ElseIf SubStr(cOpcMnt, 2, 1) $ '5'
                  If cProcesso $ '01' // Fim da Pesagem
                      //nGet1Aju := (Int(nGet1Aju) + 10) + ((Int(Int((nGet1Aju - Int(nGet1Aju)) * 1000) / 100) * 100) ) / 1000
                      nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) + 10
                  ElseIf cProcesso $ '04' // Tingimento
                      nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) + 10
                  ElseIf cProcesso $ '90' // Laboratorio
                      nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) + 10
                  Else
                      nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) + 200
                  Endif
              Endif
           ElseIf SubStr(cOpcMnt, 1, 1) $ 'D' //Diminui
              If SubStr(cOpcMnt, 2, 1) $ '1'
                 If cProcesso $ '01' // Fim da Pesagem
                        If (Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 0.001) >= 0
                           nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 0.001 
                        Else
                           Messagebox("Quantidade não pode ser negativa.!!!","Atenção...",48)
                        Endif
                 ElseIf cProcesso $ '04' // Tingimento
                        If (Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 0.001) >= 0
                           nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 0.001 
                        Else
                           Messagebox("Quantidade não pode ser negativa.!!!","Atenção...",48)
                        Endif
                 ElseIf cProcesso $ '90' // Laboratorio
                        If (Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 0.001) >= 0
                           nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 0.001
                        Else
                           Messagebox("Quantidade não pode ser negativa.!!!","Atenção...",48)	 
                        Endif
                 Else
                    If (Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 1) >= 0
                       nGet1Aju := (Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 1)
                    Else
                       Messagebox("Quantidade não pode ser negativa.!!!","Atenção...",48)
                    Endif
                 Endif
              ElseIf SubStr(cOpcMnt, 2, 1) $ '2'
                 If cProcesso $ '01' // Fim da Pesagem
                        If (Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 0.01) >= 0
                           nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 0.01 
                        Else
                           Messagebox("Quantidade não pode ser negativa.!!!","Atenção...",48)
                        Endif
                 ElseIf cProcesso $ '04' // Tingimento
                        If (Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 0.01) >= 0
                           nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 0.01 
                        Else
                           Messagebox("Quantidade não pode ser negativa.!!!","Atenção...",48)
                        Endif
                 ElseIf cProcesso $ '90' // Laboratorio
                        If (Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 0.01) >= 0
                           nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 0.01
                        Else
                           Messagebox("Quantidade não pode ser negativa.!!!","Atenção...",48)	 
                        Endif
                 Else
                    If (Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 10) >= 0
                       nGet1Aju := (Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 10)
                    Else
                       Messagebox("Quantidade não pode ser negativa.!!!","Atenção...",48)
                    Endif
                 Endif
              ElseIf SubStr(cOpcMnt, 2, 1) $ '3'
                     If cProcesso $ '01' // Fim da Pesagem
                        If (Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 0.1) >= 0.0
                           //nGet1Aju := Int(nGet1Aju) + ((Int(Int((nGet1Aju - Int(nGet1Aju)) * 1000) / 100) * 100) - 100) / 1000
                           nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 0.1 
                        Else
                           Messagebox("Quantidade não pode ser negativa.!!!","Atenção...",48)	
                        Endif
                     ElseIf cProcesso $ '04' // Tingimento
                            If (Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 0.1) >= 0
                               nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 0.1 
                            Else
                               Messagebox("Quantidade não pode ser negativa.!!!","Atenção...",48)
                            Endif
                     ElseIf cProcesso $ '90' // Laboratorio
                            If (Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 0.1) >= 0
                               nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 0.1
                            Else
                               Messagebox("Quantidade não pode ser negativa.!!!","Atenção...",48)
                            Endif
                     Else
                         If (Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 50) >= 0
                            nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 50
                         Else
                        	Messagebox("Quantidade não pode ser negativa.!!!","Atenção...",48)
                        Endif
                     Endif
              ElseIf SubStr(cOpcMnt, 2, 1) $ '4'
                     If cProcesso $ '01' // Fim da Pesagem
                        If (Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 1) >= 0
                           //nGet1Aju := (Int(nGet1Aju) - 1) + ((Int(Int((nGet1Aju - Int(nGet1Aju)) * 1000) / 100) * 100) ) / 1000
                           nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 1 
                        Else
                           Messagebox("Quantidade não pode ser negativa.!!!","Atenção...",48)	
                        Endif
                     ElseIf cProcesso $ '04' // Tingimento
                            If (Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 1) >= 0
                               nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 1 
                            Else
                               Messagebox("Quantidade não pode ser negativa.!!!","Atenção...",48)	 
                            Endif
                     ElseIf cProcesso $ '90' // Laboratorio
                            If (Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 1) >= 0
                               nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 1
                            Else
                               Messagebox("Quantidade não pode ser negativa.!!!","Atenção...",48)	
                            Endif
                     Else
                        If (Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 100) >= 0
                           nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 100
                        Else
                           Messagebox("Quantidade não pode ser negativa.!!!","Atenção...",48)
                        Endif
                     Endif
              ElseIf SubStr(cOpcMnt, 2, 1) $ '5'
                     If cProcesso $ '01' // Fim da Pesagem
                        If (Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 10) >= 0
                           //nGet1Aju := (Int(nGet1Aju) - 10) + ((Int(Int((nGet1Aju - Int(nGet1Aju)) * 1000) / 100) * 100) ) / 1000
                           nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 10 
                        Else
                           Messagebox("Quantidade não pode ser negativa.!!!","Atenção...",48)	
                        Endif
                     ElseIf cProcesso $ '04' // Tingimento
                            If (Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 10) >= 0
                               nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 10 
                            Else
                               Messagebox("Quantidade não pode ser negativa.!!!","Atenção...",48)	 
                            Endif
                     ElseIf cProcesso $ '90' // Laboratorio
                            If (Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 10) >= 0
                               nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 10
                            Else
                               Messagebox("Quantidade não pode ser negativa.!!!","Atenção...",48)	
                            Endif
                     Else
                        If (Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 200) >= 0
                           nGet1Aju := Int(nGet1Aju) + (nGet1Aju - Int(nGet1Aju)) - 200
                        Else
                           Messagebox("Quantidade não pode ser negativa.!!!","Atenção...",48)
                        Endif
                     Endif
              Endif
           Endif
    Return

    /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ fGrvValLab() - Validação do Peso Específico do Laboratório
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Static Function fGrvValLab(nOpcVal)
           If nOpcVal $ '0'
              If Posicione("SB1", 1, xFilial("SB1")+cNumPro, "B1_UM") $ 'K.KG'
                  nTolera := 0.050 
              Else
	              nTolera := 0.020
              Endif
              //If Round(nGet1Aju, 6) > Round(nGet4Lab + GetMv("MV_TOLAPCQ"), 6)
			  If Round(nGet1Aju, 3) > Round(nGet4Lab + nTolera, 3)  // chamado 004748 passado de 6 pra 3 o número de casas, de acordo com as casas decimais de nossas balanças
                 cTxtMsg := "Peso Específico na O.P "+(cNumOrd)+" informado é MAIOR que o tolerável."+CHR(13)+CHR(10)
                 cTxtMsg += "Peso Esp. Informado: "+Alltrim(TransForm(nGet1Aju, "@E 9.999"))+"   -   Peso Esp. Teórico: "+Alltrim(TransForm(nGet4Lab, "@E 9.999"))+CHR(13)+CHR(10)
                 cTxtMsg += " "+CHR(13)+CHR(10)
				 cTxtMsg += "Tolerância Máxima - ± "+Alltrim(TransForm(nTolera, "@E 9.999"))+"."
                 If GetMv("MV_OMITMSG") $ 'N'
                    Messagebox(cTxtMsg,"Atenção...",48)
                 Endif
				 If Substr(xFilial("ZZA"),1,2)== "06"
   				 	U_EnvMail("DISSOLTEX - O.P "+cNumOrd+" Peso Específico na O.P informado é MAIOR que o tolerável. !" ,cTxtMsg,"silene@dissoltex.com.br,ricardo@dissoltex.com.br","") 
            	 Else
   				 	U_EnvMail("BRASILUX - O.P "+cNumOrd+" Peso Específico na O.P informado é MAIOR que o tolerável. !" ,cTxtMsg,"marciononis@brasilux.com.br, pcp@brasilux.com.br ","")                       	  
				 Endif

                 If GetMv("MV_PASLABO") $ 'S'
                    If Round(nGet1Aju, 6) >= 2.8
                       Messagebox("Peso específico acima de 2.8, inválido!!!","Atenção...",48)
                       nGet1Aju := nGet7Lab
                       oGet1Aju:SetFocus()
                    Else
                       cRetSup := space(15)
                       //If !u_fValSenLabo(GetMv("MV_SUPLABO"), @cRetSup)
                       //   oGet1Aju:SetFocus()
                       //Endif
                    Endif
                 Else
                    oGet1Aju:SetFocus()
                 Endif
              Endif
              If Round(nGet1Aju, 3) < Round(nGet4Lab - nTolera, 3)
                 cTxtMsg := "Peso Específico na O.P "+(cNumOrd)+" informado é MENOR que o tolerável."+CHR(13)+CHR(10)
                 cTxtMsg += "Peso Esp. Informado: "+Alltrim(TransForm(nGet1Aju, "@E 9.999"))+"   -   Peso Esp. Teórico: "+Alltrim(TransForm(nGet4Lab, "@E 9.999"))+CHR(13)+CHR(10)
                 cTxtMsg += " "+CHR(13)+CHR(10)
				 cTxtMsg += "Tolerância Máxima - ± "+Alltrim(TransForm(nTolera, "@E 9.999"))+"."
                 If GetMv("MV_OMITMSG") $ 'N'
                    Messagebox(cTxtMsg,"Atenção...",48)
                 Endif
  				 If Substr(xFilial("ZZA"),1,2)== "06"
   				 	U_EnvMail("DISSOLTEX - O.P "+cNumOrd+" Peso Específico na O.P informado é MENOR que o tolerável. !" ,cTxtMsg,"silene@dissoltex.com.br,ricardo@dissoltex.com.br","") 
                 Else
   				 	U_EnvMail("BRASILUX - O.P "+cNumOrd+" Peso Específico na O.P informado é MENOR que o tolerável. !" ,cTxtMsg,"marciononis@brasilux.com.br,pcp@brasilux.com.br","")                       	  
				 Endif

                 If GetMv("MV_PASLABO") $ 'S'
                    cRetSup := space(15)
                    If !u_fValSenLabo(GetMv("MV_SUPLABO"), @cRetSup)
                       oGet1Aju:SetFocus()
                    Endif
                 Else
                    oGet1Aju:SetFocus()
                 Endif
              Endif
              nGet7Lab := nGet1Aju
              If Len(Alltrim(cGet3Lab)) == 4 .or. Len(Alltrim(cGet3Lab)) == 5 .or. Len(Alltrim(cGet3Lab)) == 6 .or. (Len(Alltrim(cGet3Lab)) == 12 .and. Substr(Alltrim(cGet3Lab),11,2)=='99') 
                 nGet6Lab := nGetLPes
              Else
                 nGet6Lab := Round((nGetALab - nGet9Lab) / nGet7Lab, 3)
              Endif
              oDlg1Aju:End()
           Else
              If Len(Alltrim(cGet3Lab)) == 4 .or. Len(Alltrim(cGet3Lab)) == 5 .or. Len(Alltrim(cGet3Lab)) == 6 .or. (Len(Alltrim(cGet3Lab))== 12 .and. Substr(Alltrim(cGet3Lab),11,2)=='99')
              Else
                 If nGet1Aju > ( (nGetLPes + nGet9Lab) * ( (100 + GetMv("MV_TOLAPTP")) / 100 ) )
                    cTxtMsg := "Atenção, essa O.P. não pode ser finalizada!"+CHR(13)+CHR(10)
                    cTxtMsg += "Peso informado é MAIOR que o tolerável."+CHR(13)+CHR(10)
                    cTxtMsg += "Peso Informado: "+Alltrim(TransForm(nGet1Aju, "@E 99999.99999"))+"   -   Peso Fórmula: "+Alltrim(TransForm((nGetLPes + nGet9Lab), "@E 99999.99999"))+CHR(13)+CHR(10)
                    cTxtMsg += " "+CHR(13)+CHR(10)
                    cTxtMsg += "Tolerâncias: Máxima - "+Alltrim(TransForm(( (nGetLPes + nGet9Lab) * ( (100 + GetMv("MV_TOLAPTP")) / 100 ) ), "@E 99999.99999"))+"   -   Mínima - "+Alltrim(TransForm(( (nGetLPes + nGet9Lab) * ( (100 - GetMv("MV_TOLAPTP")) / 100 ) ), "@E 99999.99999"))
                    If GetMv("MV_OMITMSG") $ 'N'
                       MsgAlert(cTxtMsg)
                    Endif
                    oGet1Aju:SetFocus()
                    nGet1Aju := nGetLPes + nGet9Lab
                    oGet1Aju:SetFocus()
                    Return
                 Endif
                 If nGet1Aju < (nGetLPes + nGet9Lab) * ( (100 - GetMv("MV_TOLAPTP")) / 100 )
                    cTxtMsg := "Atenção, essa O.P. não pode ser finalizada!"+CHR(13)+CHR(10)
                    cTxtMsg += "Peso informado é MAIOR que o tolerável."+CHR(13)+CHR(10)
                    cTxtMsg += "Peso Informado: "+Alltrim(TransForm(nGet1Aju, "@E 99999.99999"))+"   -   Peso Fórmula: "+Alltrim(TransForm((nGetLPes + nGet9Lab), "@E 99999.99999"))+CHR(13)+CHR(10)
                    cTxtMsg += " "+CHR(13)+CHR(10)
                    cTxtMsg += "Tolerâncias: Máxima - "+Alltrim(TransForm(( (nGetLPes + nGet9Lab) * ( (100 + GetMv("MV_TOLAPTP")) / 100 ) ), "@E 99999.99999"))+"   -   Mínima - "+Alltrim(TransForm(( (nGetLPes + nGet9Lab) * ( (100 - GetMv("MV_TOLAPTP")) / 100 ) ), "@E 99999.99999"))
                    If GetMv("MV_OMITMSG") $ 'N'
                       MsgAlert(cTxtMsg)
                    Endif
                    oGet1Aju:SetFocus()
                    nGet1Aju := nGetLPes + nGet9Lab
                    oGet1Aju:SetFocus()
                    Return
                 Endif
              Endif
              nGetALab := nGet1Aju
              nGetLPes := nGetALab - nGet9Lab
              If Len(Alltrim(cGet3Lab)) == 4 .or. Len(Alltrim(cGet3Lab)) == 5 .or. Len(Alltrim(cGet3Lab)) == 6 .or. (Len(Alltrim(cGet3Lab))== 12 .and. Substr(Alltrim(cGet3Lab),11,2)=='99')
                 nGet6Lab := Round((nGetLPes), 3)
              Else
                 nGet6Lab := Round((nGetLPes) / nGet7Lab, 3)
              Endif
              oDlg1Aju:End()
           Endif
    Return
/*************************************************************************************************/

/*************************************************************************************************/
/*** 000005          F U N Ç Õ E S     D E     O U T R A S     C H A M A D A S                 ***/
    /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ fAptSaiVol() - Verifica saida da ordem de produção ou volta para tela principal
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Static Function fAptSaiVol(nOpcApt)
           If nOpcApt == 1
              //LGS#20200302 - Adicionado o comando TCQuit para fechar conexão com tabelas e dicionario abertos na RPCSetEnv
              TCQuit()
              oDlg1Apt:End()
           ElseIf nOpcApt == 2
                  cGet1Apt := space(11)
                  oGet1Apt:SetFocus()
                  oGet1Apt:Refresh()
                  oBtnDApt:cCaption := "Sair"
                  oBtnDApt:bAction  := {|| fAptSaiVol(1)}
                  oBtnDApt:Refresh()
                  //oBtn1Apt:lVisible := .f.
                  //oBtn1Apt:Refresh()
                  //oBtn2Apt:lVisible := .f.
                  //oBtn2Apt:Refresh()
                  //oBtn3Apt:lVisible := .f.
                  //oBtn3Apt:Refresh()
                  //oBtn4Apt:lVisible := .f.
                  ///oBtn4Apt:Refresh()
                  //oBtn5Apt:lVisible := .f.
                  //oBtn5Apt:Refresh()
                  //oBtn6Apt:lVisible := .f.
                  //oBtn6Apt:Refresh()
                  //oBtn7Apt:lVisible := .f.
                  //oBtn7Apt:Refresh()
                  //oBtn8Apt:lVisible := .f.
                  //oBtn8Apt:Refresh()
                  //oBtn9Apt:lVisible := .f.
                  //oBtn9Apt:Refresh()
                  //oBtnAApt:lVisible := .f.
                  //oBtnAApt:Refresh()
                  //oBtnBApt:lVisible := .f.
                  //oBtnBApt:Refresh()
                  //oBtnCApt:lVisible := .f.
                  //oBtnCApt:Refresh()
                  oGet1Apt:lReadOnly := .f.
                  oGet1Apt:Refresh()
           Endif
    Return

    /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ fAbaAptPro() - Abandona apontamento do produto
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Static Function fAbaAptPro()
           cGet1Apt := space(11)
           oGet1Apt:SetFocus()
           oGet1Apt:Refresh()
           oBtnDApt:cCaption := "Sair"
           oBtnDApt:bAction  := {|| fAptSaiVol(1)}
           oBtnDApt:Refresh()
           //oBtn1Apt:lVisible := .f.
           //oBtn1Apt:Refresh()
           oGet1Apt:lReadOnly := .f.
           oGet1Apt:Refresh()
    Return


    /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ fBloqOpSal() - Veririca saldo dos itens da op antes do inicio
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

    Static Function	fBloqOpSal()

	Local cAliAtu := Alias()
    Local cQry1  := ""
    Local cTexto := ""
    Local lReturn:= .f. 
    Local nDif := 0.0,_nDec,nQtd,nQtdSegum 
	Local aVetor := {}, aArea := {}
	//Local aEmpen := {}
	Local nOpc   := 4 //Alterar   
	Private lMsErroAuto
	
	aArea := U_PegaArea({"SD4"})
    
	cQry1 := ""
	cQry1 += " SELECT D4_COD, MAX(B1_DESC) AS B1_DESC, D4_LOCAL, SUM(D4_QUANT) AS D4_QUANT, MAX(B2_QATU) AS B2_QATU, (MAX(B2_QATU) - SUM(D4_QUANT)) AS 'DISP', B1_GRUPO, "
	cQry1 += " 'SALTOTAL' = (SELECT SUM(B2_QATU) FROM SB2"+cParInf1+"0 WITH(NOLOCK) WHERE D4_FILIAL = B2_FILIAL AND D4_COD = B2_COD AND D_E_L_E_T_ ='' AND SUBSTRING(B2_LOCAL,1,1) NOT IN('G','M') ) "
	cQry1 += " FROM SD4"+cParInf1+"0 SD4 WITH(NOLOCK) "
	cQry1 += " LEFT OUTER JOIN SB2"+cParInf1+"0 SB2 WITH(NOLOCK) ON (B2_FILIAL = D4_FILIAL) AND B2_COD = D4_COD AND B2_LOCAL = D4_LOCAL AND SB2.D_E_L_E_T_ ='' "
	cQry1 += " LEFT OUTER JOIN SB1"+cParInf1+"0 SB1 WITH(NOLOCK) ON (B1_FILIAL = D4_FILIAL) AND B1_COD = D4_COD AND SB1.D_E_L_E_T_ ='' "
	cQry1 += " LEFT OUTER JOIN SC2"+cParInf1+"0 SC2 WITH(NOLOCK) ON (C2_FILIAL = D4_FILIAL) AND C2_OP = D4_OP AND SC2.D_E_L_E_T_ ='' "
	cQry1 += " WHERE (SD4.D_E_L_E_T_ ='') AND B1_GRUPO NOT BETWEEN('PI00') AND ('PI99') "
	cQry1 += " AND (D4_FILIAL  = '"+cParInf2+"')"
	//cQry1 += " AND D4_OP = '"+cNumOrd+"'"
	cQry1 += " AND C2_LOTE = '"+cNumLot+"'"
	cQry1 += " GROUP BY D4_FILIAL, D4_COD, D4_LOCAL, B1_GRUPO "
	cQry1 += " HAVING SUM(D4_QUANT) > MAX(B2_QATU) "
	cQry1 += " ORDER BY D4_COD,D4_LOCAL " 
    TCQuery cQry1 ALIAS "TCS" NEW


    DbSelectArea("TCS")
    dbgotop()
    While !Eof()  
    	If SUBSTR(TCS->B1_GRUPO,1,1) <> 'E' // embalagens deve se considerar o saldo de todos os almoxarifados - chamado 007121 - Michelly
	    	IF ABS(TCS->D4_QUANT - TCS->B2_QATU) >= 0.001 //definir tolerância p/ qdo passar de 3 casas
	        	cTexto += "Produto "+TCS->D4_COD+" - "+TCS->B1_DESC+" com saldo insuficiente "+Alltrim(TransForm(TCS->DISP, "@E 9999.9999"))+" Local -> "+TCS->D4_LOCAL+CHR(13)+CHR(10)
		    	lReturn:= .t.
		    ELSE    
		    	//Cleber(22/11/16)->Ajustar empenho tirando a diferença em relação ao saldo.
	    		nDif := TCS->D4_QUANT - TCS->B2_QATU    
	    		dbselectarea("SD4")
			   	dbsetorder(2)
		    	dbseek(xFilial("SD4")+cNumOrd+TCS->D4_COD+TCS->D4_LOCAL)
	    		DO WHILE !EOF() .AND. (SD4->D4_FILIAL == xFilial("SD4")) .AND. (SD4->D4_OP = cNumOrd) .AND. (SD4->D4_COD == TCS->D4_COD) .AND. (SD4->D4_LOCAL == TCS->D4_LOCAL)
		    		IF SD4->D4_QUANT >= nDif //Ajustar empenho tirando resíduo a mais para não dar diferença na baixa

						nQtd := SD4->D4_QUANT-nDif
						_nDec := TamSX3("D4_QTSEGUM")[2]
						nQtdSegum := round(SD4->D4_QTSEGUM - (SD4->D4_QTSEGUM*nQtd/SD4->D4_QUANT),_nDec)
						lMsErroAuto := .F.
 
						aVetor:={   {"D4_COD"     ,SD4->D4_COD			,Nil},; //COM O TAMANHO EXATO DO CAMPO
    	        					{"D4_LOCAL"   ,SD4->D4_LOCAL        ,Nil},;
        	    					{"D4_OP"      ,SD4->D4_OP           ,Nil},;
            						{"D4_DATA"    ,SD4->D4_DATA         ,Nil},;
            						{"D4_QTDEORI" ,SD4->D4_QTDEORI      ,Nil},;
            						{"D4_QUANT"   ,nQtd   			    ,Nil},;
            						{"D4_TRT"     ,SD4->D4_TRT          ,Nil},;
            						{"D4_QTSEGUM" ,nQtdSegum 			,Nil}}
 
						MSExecAuto({|x,y| mata380(x,y)},aVetor,nOpc)      
 
						If lMsErroAuto
	//					    Alert("Erro")
						    MostraErro()
						EndIf      
						EXIT 
	    			 
		    		ENDIF 
			    	dbselectarea("SD4")
			    	dbskip()
		    	ENDDO 	    
	    	ENDIF
    	Else
	    	If (TCS->D4_QUANT) > (TCS->SALTOTAL)
	        	cTexto += "Produto "+TCS->D4_COD+" - "+TCS->B1_DESC+" com saldo insuficiente em todos os almoxarifados somados "+Alltrim(TransForm(TCS->SALTOTAL, "@E 99999"))+" Local -> "+TCS->D4_LOCAL+CHR(13)+CHR(10)
		    	lReturn:= .t.
    	    Endif
    	Endif
    	DbSelectArea("TCS")
    	DbSkip()
    Enddo
    
   	DbSelectArea("TCS")
	DbCloseArea()
	
	If Len(Alltrim(cTexto)) >0
		Messagebox(cTexto,"Produto sem Saldo",48)
	    If Substr(xFilial("ZZA"),1,2)== "06"
   		 	U_EnvMail("DISSOLTEX - O.P "+cNumOrd+" não iniciada por falta de Saldo !" ,cTexto,"silene@dissoltex.com.br,ricardo@dissoltex.com.br","") 
        Else
   		 	U_EnvMail("BRASILUX - O.P "+cNumOrd+" não iniciada por falta de Saldo !" ,cTexto,"materiais@brasilux.com.br, paulo@brasilux.com.br","")                       	  
		Endif
	Endif
	

	U_VoltaArea(aArea)
	
	if !empty(cAliAtu)
 		DbSelectArea(cAliAtu)
	endif 
	Return(lReturn)	

    /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ fQtdAju() - Ajusta quantidades utilizadas
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Static Function fQtdAju(nQtdAju, cProcesso)
           Local nOpcAju := 0
           /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
           ±± Declaração de cVariable dos componentes                                 ±±
           Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
           Private nGet1Aju   := nQtdAju

           /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
           ±± Declaração de Variaveis Private dos Objetos                             ±±
           Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
           SetPrvt("oFont1Aj", "oDlg1Aju", "oGrp1Aju", "oBtn2Aju", "oBtn3Aju", "oBtn1Aju", "oGet1Aju", "oBtn4Aju", "oBtn5Aju")
           SetPrvt("oBtn7Aju", "oBtn8Aju")

           /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
           ±± Definicao do Dialog e todos os seus componentes.                        ±±
           Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
           oFont1Aj   := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
           oDlg1Aju   := MSDialog():New( 095, 232, 180, 677, "Apontar Qtde de Sobra", , , .F., , , , , , .T., , , .T. )
           oGrp1Aju   := TGroup():New( 000, 004, 020, 261, "", oDlg1Aju, CLR_BLACK, CLR_WHITE, .T., .F. )
           oBtn2Aju   := TButton():New( 005, 008, "+++"     , oDlg1Aju, {|| fMntQtd("A4", cProcesso) }, 020, 012, , oFont1Aj, , .T., , "", , , , .F. )
           oBtn3Aju   := TButton():New( 005, 034, "++"      , oDlg1Aju, {|| fMntQtd("A3", cProcesso) }, 017, 012, , oFont1Aj, , .T., , "", , , , .F. )
           oBtn3Aju   := TButton():New( 005, 056, "+"       , oDlg1Aju, {|| fMntQtd("A2", cProcesso) }, 013, 012, , oFont1Aj, , .T., , "", , , , .F. )
           oGet1Aju   := TGet():New( 004, 080,{|u| If(PCount() > 0, nGet1Aju := u, nGet1Aju)}, oDlg1Aju, 030, 012, '@E 9,999.999', , CLR_BLACK, CLR_WHITE, oFont1Aj, , , .T., "", , , .F., .F., , .T., .F., "", "nGet1Aju", ,)
           oBtn4Aju   := TButton():New( 005, 155, "-"       , oDlg1Aju, {|| fMntQtd("D2", cProcesso) }, 013, 012, , oFont1Aj, , .T., , "", , , , .F. )
           oBtn5Aju   := TButton():New( 005, 173, "- -"     , oDlg1Aju, {|| fMntQtd("D3", cProcesso) }, 017, 012, , oFont1Aj, , .T., , "", , , , .F. )
           oBtn6Aju   := TButton():New( 005, 196, "- - -"   , oDlg1Aju, {|| fMntQtd("D4", cProcesso) }, 020, 012, , oFont1Aj, , .T., , "", , , , .F. )
           oBtn7Aju   := TButton():New( 024, 004, "Volta"   , oDlg1Aju, { || lOpcMnt := .f., nOpcAju := 0, oDlg1Aju:end()               }, 037, 012, , , , .T., , "", , , , .F. )
           oBtn8Aju   := TButton():New( 024, 184, "Confirma", oDlg1Aju, { || lOpcMnt := .f., nOpcAju := 1, oDlg1Aju:end() }, 037, 012, , , , .T., , "", , , , .F. )

           oDlg1Aju:Activate( , , , .T.)
           If nOpcAju == 1
              nOpcAju := 0
              nGet3Mnt := nGet1Aju
		   Else
              nGet1Aju := 0
		   Endif
		   	
    Return(nGet1Aju)


    /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ fAjuQtd() - Ajusta quantidades utilizadas
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Static Function fAjuQtd(nQtdAju, cProcesso)
           Local nOpcAju := 0
           /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
           ±± Declaração de cVariable dos componentes                                 ±±
           Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
           Private nGet1Aju   := nQtdAju

           /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
           ±± Declaração de Variaveis Private dos Objetos                             ±±
           Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
           SetPrvt("oFont1Aj", "oDlg1Aju", "oGrp1Aju", "oBtn2Aju", "oBtn3Aju", "oBtn1Aju", "oGet1Aju", "oBtn4Aju", "oBtn5Aju")
           SetPrvt("oBtn7Aju", "oBtn8Aju", "oBtn9Aju", "oBtnAAju")

           /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
           ±± Definicao do Dialog e todos os seus componentes.                        ±±
           Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
           oFont1Aj   := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
           oDlg1Aju   := MSDialog():New( 095, 232, 180, 815, "Quantidade", , , .F., , , , , , .T., , , .T. )
           oGrp1Aju   := TGroup():New( 000, 002, 020, 293, "", oDlg1Aju, CLR_BLACK, CLR_WHITE, .T., .F. )
           oBtnABju   := TButton():New( 005, 004, "+++++"    , oDlg1Aju, {|| fMntQtd("A5", cProcesso) }, 026, 012, , oFont1Aj, , .T., , "", , , , .F. )
           oBtnAAju   := TButton():New( 005, 032, "++++"     , oDlg1Aju, {|| fMntQtd("A4", cProcesso) }, 023, 012, , oFont1Aj, , .T., , "", , , , .F. )
           oBtn1Aju   := TButton():New( 005, 057, "+++"      , oDlg1Aju, {|| fMntQtd("A3", cProcesso) }, 020, 012, , oFont1Aj, , .T., , "", , , , .F. )
           oBtn2Aju   := TButton():New( 005, 079, "++"       , oDlg1Aju, {|| fMntQtd("A2", cProcesso) }, 017, 012, , oFont1Aj, , .T., , "", , , , .F. )
           oBtn3Aju   := TButton():New( 005, 099, "+"        , oDlg1Aju, {|| fMntQtd("A1", cProcesso) }, 013, 012, , oFont1Aj, , .T., , "", , , , .F. )
           oGet1Aju   := TGet():New( 004, 116,{|u| If(PCount() > 0, nGet1Aju := u, nGet1Aju)}, oDlg1Aju, 030, 012, '@E 9,999.999', , CLR_BLACK, CLR_WHITE, oFont1Aj, , , .T., "", , , .F., .F., , .T., .F., "", "nGet1Aju", ,)
           oBtn4Aju   := TButton():New( 005, 182, "-"        , oDlg1Aju, {|| fMntQtd("D1", cProcesso) }, 013, 012, , oFont1Aj, , .T., , "", , , , .F. )
           oBtn5Aju   := TButton():New( 005, 197, "- -"      , oDlg1Aju, {|| fMntQtd("D2", cProcesso) }, 017, 012, , oFont1Aj, , .T., , "", , , , .F. )
           oBtn6Aju   := TButton():New( 005, 216, "- - -"    , oDlg1Aju, {|| fMntQtd("D3", cProcesso) }, 020, 012, , oFont1Aj, , .T., , "", , , , .F. )
           oBtn9Aju   := TButton():New( 005, 238, "- - - -"  , oDlg1Aju, {|| fMntQtd("D4", cProcesso) }, 023, 012, , oFont1Aj, , .T., , "", , , , .F. )
           oBtn9Aju   := TButton():New( 005, 264, "- - - - -", oDlg1Aju, {|| fMntQtd("D5", cProcesso) }, 026, 012, , oFont1Aj, , .T., , "", , , , .F. )

           oBtn7Aju   := TButton():New( 024, 004, "Volta"   , oDlg1Aju, { || lOpcMnt := .f., nOpcAju := 0, oDlg1Aju:end()               }, 037, 012, , , , .T., , "", , , , .F. )
           oBtn8Aju   := TButton():New( 024, 250, "Confirma", oDlg1Aju, { || lOpcMnt := .f., nOpcAju := 1, oDlg1Aju:end() }, 037, 012, , , , .T., , "", , , , .F. )

           oDlg1Aju:Activate( , , , .T.)
           If nOpcAju == 1
              nOpcAju := 0
              nGet3Mnt := nGet1Aju
		   Endif
		   	
    Return(nGet1Aju)

    /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ fMntFunApt() - Manutenção de Funcionários
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Static Function fMntFunApt(cOpcFun, cProFun)
           /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
           ±± Declaração de cVariable dos componentes                                 ±±
           Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
//           Private cPesqF3    := Iif(cProFun $ 'EN', 'XXE', Iif(cProFun $ '01', 'XXB', Iif(cProFun $ '04', 'XXC', 'XXL') ) )
           Private cPesqF3    := Iif(cProFun $ 'EN', 'XE', Iif(cProFun $ '01', 'XB', Iif(cProFun $ '04', 'XC', 'XL') ) )
           Private cGet1Mnt   := Iif(cOpcFun $ '0' , Space(08), TMPFUN->FUNFMA)
           Private cGet2Mnt   := Iif(cOpcFun $ '0' , Space(30), TMPFUN->FUNNOM)
           Private cSay1Mnt   := Space(1)
           Private cSay2Mnt   := Space(1)
           Private lCBox1En   := .T.

           /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
           ±± Declaração de Variaveis Private dos Objetos                             ±±
           Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
           SetPrvt("oFontMn1", "oFontMn2", "oDlg1Mnt", "oSay1Mnt", "oSay2Mnt", "oGet1Mnt", "oGet2Mnt", "oBtn2Mnt", "oBtn1Mnt")
           If cProFun $ 'EN'
              If SubStr(TMPENV->ENVBAI, 1, 2) $ 'AP.TO.PA.EX.EN'
                 Messagebox("Ordem de Produção já apontada. Não pode ter envasador alterado!","Atenção...",48)
                 Return
              Endif
           Endif
           /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
           ±± Definicao do Dialog e todos os seus componentes.                        ±±
           Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
           oFontMn1   := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
           oFontMn2   := TFont():New( "MS Sans Serif", 0, -16, , .F., 0, , 400, .F., .F., , , , , , )
           oDlg1Mnt   := MSDialog():New( 258, 232, 356, 828, "Manutenção de Funcionarios", , , .F., , , , , , .T., , , .T. )
           oSay1Mnt   := TSay():New( 004, 004, {|| "Matric..:"}, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 048, 012)
           oSay2Mnt   := TSay():New( 021, 004, {|| "Nome:"     }, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 048, 012)
           //oGet1Mnt   := TGet():New( 002, 056, {|u| If(PCount() > 0, cGet1Mnt := u, cGet1Mnt)}, oDlg1Mnt, 054, 012, '@!R 999999', , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , Iif(cOpcFun $ '0', .F., .T.), .F., cPesqF3, "cGet1Mnt", , )
           oGet1Mnt   := TGet():New( 002, 056, {|u| If(PCount() > 0, cGet1Mnt := u, cGet1Mnt)}, oDlg1Mnt, 054, 012, '@!R 999999', , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , Iif(cOpcFun $ '0', .F., .T.), .F., , "cGet1Mnt", , )
           oGet2Mnt   := TGet():New( 020, 056, {|u| If(PCount() > 0, cGet2Mnt := u, cGet2Mnt)}, oDlg1Mnt, 236, 012, '@!'           , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .T.                         , .F., ""     , "cGet2Mnt", , )
           oBtn2Mnt   := TButton():New( 036, 254, "Abandona", oDlg1Mnt, {|| oDlg1Mnt:End()}              , 037, 012, , , , .T., , "", , , , .F. )
           oBtn1Mnt   := TButton():New( 036, 212, "Confirma", oDlg1Mnt, {|| fGrvMntApt(cOpcFun, cProFun)}, 037, 012, , , , .T., , "", , , , .F. )
           If cProFun $ "EN"
              If cOpcFun <> '1'
                 oCBox1En   := TCheckBox():New( 038, 004, "Utiliza mesmo envasador para todos os produtos.", {|u| If(PCount() > 0, lCBox1En := u, lCBox1En)}, oDlg1Mnt, 188, 008, , , , , CLR_BLACK, CLR_WHITE, , .T., "", , )
              Endif
           Endif
           oGet1Mnt:bLostFocus := {|| fBusAptOrd() }
           oDlg1Mnt:Activate(,,,.T.)
    Return

    Static Function fBusAptOrd()
           Local cQry1, lAchou,_cNome
           //Local _aRetInf   := FWGetSX5 ( SubStr( cPesqF3, 1, 2 ), cGet1Mnt )   //LGS#20200204 - Adequação de release 12.1.25 e posteriores
           
           /********************************************************************************************************************************/
           /*** BLOCO ALTERADO EM 04/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
           
           DbSelectArea("SX5")
           DbSetOrder(1)
//           DbSeek(xFilial("SX5")+SubStr(cPesqF3, 2, 2)+cGet1Mnt, .t.)
           DbSeek(xFilial("SRA")+SubStr(cPesqF3, 1, 2)+cGet1Mnt, .t.)
           If Found()
				//Depois da virada de versão para a 11 o dbseek não funcionou no SRA
				cQry1 := "SELECT RA_NOME FROM "+RetSqlName("SRA")+" WHERE (D_E_L_E_T_ <> '*') AND (RA_FILIAL = '"+XFILIAL("SRA")+"') AND (RA_MAT = '"+ALLTRIM(cGet1Mnt)+"')"
	            TCQuery cQry1 ALIAS "TCQRA" NEW
              	DbSelectArea("TCQRA")
              	DbGoTop()   
              	if !EOF() .AND. !BOF()
              		lAchou := .t.
              		_cNome := TCQRA->RA_NOME
              	else
              		lAchou := .f.
              	endif 
	            DbSelectArea("TCQRA")
				DbCloseArea()                  

            
              DbSelectArea("SRA")
              DbSetOrder(1)
              DbSeek(XFilial("SRA")+alltrim(cGet1Mnt), .t.) 
            If lAchou 
                 cGet2Mnt := Alltrim(_cNome)
              Else
                 If Empty(cGet2Mnt)
                    //LGS#20200214 - Adequação de release 12.1.25 e posteriores
                    //cGet2Mnt := Alltrim(SX5->X5_DESCRI)
                    cGet2Mnt := FWGetSX5 ( SubStr( cPesqF3, 1, 2 ), cGet1Mnt )[4]
                 Endif
              Endif 
           Else
//              MsgStop("Funcionário não cadastrado como "+Iif(cPesqF3 $ 'XXE', 'envasador', Iif(cPesqF3 $ 'XXB', 'balanceiro', Iif(cPesqF3 $ 'XXC', 'colorista', 'analista de laboratorio') ) )+". Verifique!")
              MsgStop("Funcionário não cadastrado como "+Iif(cPesqF3 $ 'XE', 'envasador', Iif(cPesqF3 $ 'XB', 'balanceiro', Iif(cPesqF3 $ 'XC', 'colorista', 'analista de laboratorio') ) )+". Verifique!")
              //  Messagebox("Funcionário não cadastrado como "+Iif(cPesqF3 $ 'XE', 'envasador', Iif(cPesqF3 $ 'XB', 'balanceiro', Iif(cPesqF3 $ 'XC', 'colorista', 'analista de laboratorio') ) )+". Verifique!",48) 
              oGet1Mnt:SetFocus()
              Return(.f.)
           Endif
/*
           If Len( _aRetInf ) > 0 
              cQry1 := "SELECT RA_NOME FROM "+RetSqlName("SRA")+" WHERE (D_E_L_E_T_ <> '*') AND (RA_FILIAL = '"+XFILIAL("SRA")+"') AND (RA_MAT = '"+ALLTRIM(cGet1Mnt)+"')"
              TCQuery cQry1 ALIAS "TCQRA" NEW
              DbSelectArea("TCQRA")
              DbGoTop()
              If !EOF() .AND. !BOF()
                 lAchou := .t.
                 _cNome := TCQRA->RA_NOME
              Else
                 lAchou := .f.
              Endif
              DbSelectArea("TCQRA")
              DbCloseArea()                  
              If lAchou 
                 cGet2Mnt := Alltrim(_cNome)
              Else
                 If Empty(cGet2Mnt)
                    cGet2Mnt := Alltrim( _aRetInf[1][4] )
                 Endif
              Endif 
           Else
              MsgStop("Funcionário não cadastrado como "+Iif(cPesqF3 $ 'XE', 'envasador', Iif(cPesqF3 $ 'XB', 'balanceiro', Iif(cPesqF3 $ 'XC', 'colorista', 'analista de laboratorio') ) )+". Verifique!")
              oGet1Mnt:SetFocus()
              Return(.f.)
           Endif*/
    Return

    /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ fMntValLab() - Valida manutenção do peso bruto informado
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Static Function fMntValLab(nOpcVal)
           /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
           ±± Declaração de cVariable dos componentes                                 ±±
           Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
           Local cPicMnt    := Iif(nOpcVal $ '0', '@E 9.999999'       , '@E 999,999.999')
           Local cTitMnt    := Iif(nOpcVal $ '0', 'P.E. (Laboratório)', 'Peso Bruto'    )
           Private nGet1Aju := Iif(nOpcVal $ '0', nGet7Lab            , nGetALab        )

           /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
           ±± Declaração de Variaveis Private dos Objetos                             ±±
           Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
           SetPrvt("oFont1", "oDlg1Aju", "oGrp1Aju", "oGet1Aju", "oBtn7Aju", "oBtn8Aju")

           /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
           ±± Definicao do Dialog e todos os seus componentes.                        ±±
           Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
           oFont1     := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
           oDlg1Aju   := MSDialog():New( 219, 537, 296, 776, cTitMnt, , , .F., , , , , , .T., , , .T. )
           oGrp1Aju   := TGroup():New( 000, 004, 020, 116, "", oDlg1Aju, CLR_BLACK, CLR_WHITE, .T., .F. )
           oGet1Aju   := TGet():New( 004, 024, {|u| If(PCount() > 0, nGet1Aju := u, nGet1Aju)}, oDlg1Aju, 070, 012, cPicMnt, {|| positivo() }, CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .F., .F., "", "nGet1Aju", , )
           oBtn7Aju   := TButton():New( 024, 004, "Volta"   , oDlg1Aju, { || oDlg1Aju:End()      }, 037, 012, , , , .T., , "", , , , .F. )
           oBtn8Aju   := TButton():New( 024, 079, "Confirma", oDlg1Aju, { || fGrvValLab(nOpcVal) }, 037, 012, , , , .T., , "", , , , .F. )

           oDlg1Aju:Activate(, , , .T.)
    Return

    /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ fMntEmpPro() - Manutenção dos itens empenhados
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Static Function fMntEmpPro(nOpcMnt, cProcesso)
           /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
           ±± Declaração de cVariable dos componentes                                 ±±
           Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
           Local   lMntAltNao := Iif(nOpcMnt == 0, .f.      , .t.)
           Private cGet1Mnt   := Iif(nOpcMnt == 0, Space(15), TMPEMP->ITEM)
           Private cGet2Mnt   := Iif(nOpcMnt == 0, Space(3) , TMPEMP->SEQU)
           Private nGet3Mnt   := Iif(nOpcMnt == 0, 0        , TMPEMP->QTUS)
           Private cGet4Mnt   := Iif(nOpcMnt == 0, Space(30), Posicione("SB1", 1, xFilial("SB1")+TMPEMP->ITEM, "B1_DESC"))
           Private cGet5Mnt   := space(2)
           Private cSay1Mnt   := Space(1)
           Private cSay2Mnt   := Space(1)
           Private cSay3Mnt   := Space(1)
           Private cSay4Mnt   := Space(1)
           Private lOpcMnt    := .f.

           /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
           ±± Declaração de Variaveis Private dos Objetos                             ±±
           Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
           SetPrvt("oFontMn1", "oFontMn2", "oDlg1Mnt", "oSay1Mnt", "oSay4Mnt", "oSay2Mnt", "oSay3Mnt", "oGet1Mnt", "oGet2Mnt")
           SetPrvt("oGet3Mnt", "oBtn2Mnt", "oBtn1Mnt")

           If nOpcMnt == 1
              If cProcesso $ '01'
                 If !TMPEMP->TPEM $ 'P'
                    Messagebox("Item original da fórmula não pode ser alterado.","Atenção...",48) 
                    Return
                 Else
                    If TMPEMP->FLAG == "1"
                       Messagebox("Item já baixado não pode ser alterado.","Atenção...",48) 
                       Return
                    Endif
                 Endif
              ElseIf cProcesso $ '04' //Tingimento
                     If !TMPEMP->TPEM $ 'C'
	                    Messagebox("Item original da fórmula não pode ser alterado.","Atenção...",48) 
                        Return
                     Else
                        If TMPEMP->FLAG == "1"
                           Messagebox("Item já baixado, não pode ser alterado.","Atenção...",48) 
                           Return
                        Endif
                     Endif
              ElseIf cProcesso $ '90' //Laboratorio
                     If !TMPEMP->TPEM $ 'L'
                        Messagebox("Item original da fórmula não pode ser alterado.","Atenção...",48) 
                        Return
                     Else
                        If TMPEMP->FLAG == "1"
                           Messagebox("Item já baixado, não pode ser alterado.","Atenção...",48) 
                           Return
                        Endif
                     Endif
              Endif
           ElseIf nOpcMnt == 2 //Exclusão
              If cProcesso $ '01' //Pesagem
                 If TMPEMP->ORIG $ 'S' .or. !TMPEMP->TPEM $ 'P'
                    Messagebox("Item original da fórmula não pode ser excluído.","Atenção...",48) 
                    Return
                 Else
                    If TMPEMP->FLAG == "1"
                       Messagebox("Item já baixado, não pode ser excluido","Atenção...",48) 
                       Return
                    Endif
                 Endif
              ElseIf cProcesso $ '04' // Tingimento
                     If TMPEMP->ORIG $ 'S' .or. !TMPEMP->TPEM $ 'C'
                        Messagebox("Item original da fórmula não pode ser excluido.","Atenção...",48) 
                        Return
                     Else
                        If TMPEMP->FLAG == "1"
                           Messagebox("Item já baixado, não pode ser excluido.","Atenção...",48) 
                           Return
                        Endif
                     Endif
              ElseIf cProcesso $ '90' // Laboratorio
                     If TMPEMP->ORIG $ 'S' .or. !TMPEMP->TPEM $ 'L'
                        Messagebox("Item original da fórmula não pode ser excluído.","Atenção...",48) 
                        Return
                     Else
                        If TMPEMP->FLAG == "1"
                           Messagebox("Item já baixado, não pode ser excluido.","Atenção...",48) 
                           Return
                        Endif
                     Endif
              Endif
           Endif
           /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
           ±± Definicao do Dialog e todos os seus componentes.                        ±±
           Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
           oFontMn1   := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
           oFontMn2   := TFont():New( "MS Sans Serif", 0, -16, , .F., 0, , 400, .F., .F., , , , , , )
           oDlg1Mnt   := MSDialog():New( 258, 232, 353, 828, "Manutenção do Empenho", , , .F., , , , , , .T., , , .T. )
           oSay1Mnt   := TSay():New( 004, 004, {|| "Codigo:"   }, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 048, 012)
           oGet1Mnt   := TGet():New( 002, 056, {|u| If(PCount() > 0, cGet1Mnt := u, cGet1Mnt)}, oDlg1Mnt, 068, 012, '@!R XX 99.99.999-99', , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , lMntAltNao, .F., "SB1", "cGet1Mnt", , )
           oSay4Mnt   := TSay():New( 021, 004, {|| "Descrição:"}, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 048, 012)
           oGet4Mnt   := TGet():New( 020, 056, {|u| If(PCount() > 0, cGet4Mnt := u, cGet4Mnt)}, oDlg1Mnt, 236, 012, '@!'                 , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .T.       , .F., ""   , "cGet4Mnt", , )
           oSay2Mnt   := TSay():New( 004, 136, {|| "Seq:"      }, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 024, 012)
           oGet2Mnt   := TGet():New( 002, 164, {|u| If(PCount() > 0, cGet2Mnt := u, cGet2Mnt)}, oDlg1Mnt, 024, 012, '@R 999'             , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .T.       , .F., ""   , "cGet2Mnt", , )
           oSay3Mnt   := TSay():New( 004, 200, {|| "Qtde:"     }, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 028, 012)
           oGet3Mnt   := TGet():New( 002, 232, {|u| If(PCount() > 0, nGet3Mnt := u, nGet3Mnt)}, oDlg1Mnt, 060, 012, '@E 9,999.999'       , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .T.       , .F., ""   , "nGet3Mnt", , )
           oGet3Mnt:bGotFocus := {|| Iif(lOpcMnt, fAjuQtd(nGet3Mnt, cProcesso), ) }
           oGet1Mnt:bLostFocus := {|| fValCodMnt(nOpcMnt) }
           oBtn2Mnt   := TButton():New( 036, 251, "Abandona", oDlg1Mnt, {|| oDlg1Mnt:End()     }, 040, 012, , oFontMn2, , .T., , "", , , , .F. )
           oBtn1Mnt   := TButton():New( 036, 209, "Confirma", oDlg1Mnt, {|| fConEmpMnt(nOpcMnt)}, 040, 012, , oFontMn2, , .T., , "", , , , .F. )
           If nOpcMnt == 1
              oGet3Mnt:SetFocus()
              oDlg1Mnt:bInit:= { || fAjuQtd(nGet3Mnt, cProcesso) }
           Endif
           oDlg1Mnt:Activate( , , , .T.)
    Return
/*************************************************************************************************/

/*Static Function Entre(n1, n2, nValor)
       Local nTmp := n1
       If n1 > n2
          n1 := n2
          n2 := nTmp
       Endif
Return (nValor >= n1 .And. nValor <= n2)*/

Static Function fValPswEst()
       Local lRet := .f.
       Private cGetSup    := space(15)
       Private cGetPas    := space(10)
       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de Variaveis Private dos Objetos                             ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       SetPrvt("oFont1", "oDlgPas", "oSaySup", "oSayPas", "oGetSup", "oGetPas","oBtn1","oBtn2")
       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Definicao do Dialog e todos os seus componentes.                        ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       oFont1     := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
       oDlgPas    := MSDialog():New( 088, 232, 201, 477, "Liberação...", , , .F., , , , , , .T., , , .T. )
       oSaySup    := TSay():New( 004, 004, {|| "Supervisor:"}, oDlgPas, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 056, 012)
       oSayPas    := TSay():New( 019, 004, {|| "Senha:"}     , oDlgPas, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 056, 012)
       oGetSup    := TGet():New( 003, 056, {|u| If(PCount() > 0, cGetSup:=u, cGetSup)}, oDlgPas, 060, 012, '', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .F., .F., "", "cGetSup", , )
       oGetPas    := TGet():New( 020, 056, {|u| If(PCount() > 0, cGetPas:=u, cGetPas)}, oDlgPas, 060, 012, '', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .F., .T., "", "cGetPas", , )
       oBtnCon    := TButton():New( 040, 024, "Confirmar", oDlgPas, {|| lRet := fValPasEst() }, 037, 012, , , , .T., , "", , , , .F. )
       oBtnVol    := TButton():New( 040, 076, "Voltar"   , oDlgPas, {|| oDlgPas:End()        }, 037, 012, , , , .T., , "", , , , .F. )
       oGetSup:bLostFocus := {|| fValSupEst()}
       oDlgPas:Activate(,,,.T.)
Return(lRet)

Static Function fValSupEst()
       Local aRet := {}
       PswOrder(2)
       If PswSeek(cGetSup)
          aRet := PswRet(1)
          If Alltrim(Posicione("SX5", 1, xFilial("SX5")+"XX"+aRet[1][1], "X5_CHAVE")) == aRet[1][1]
             oGetPas:SetFocus()
          Else
             Messagebox("Usuário não autoriado!!!","Atenção...",48) 
             cGetPas := space(10)
             oGetPas:Refresh()
             cGetSup := space(15)
             oGetSup:Refresh()
             oGetSup:SetFocus()
             Return
          Endif
       Else
          Messagebox("Usuário Inválido!!!","Atenção...",48) 
          cGetPas := space(10)
          oGetPas:Refresh()
          cGetSup := space(15)
          oGetSup:Refresh()
          oGetSup:SetFocus()
          Return
       Endif
Return()

Static Function fValPasEst()
       Local aRet := {}
       //PswOrder(1) - Ordena pela Id do usuário
       //PswOrder(2) - Ordena por usuario
       //PswOrder(3) - Ordena por senha
//       PswOrder(1)
	   aRet := PswRet(1)
       If Alltrim(Posicione("SX5", 1, xFilial("SX5")+"XX"+aRet[1][1], "X5_DESCENG")) == Alltrim(cGetPas)
            
            oDlgPas:End()
       Else
			Messagebox("Senha Inválida !!","Atenção...",48) 
          	cGetPas := space(10)
          	oGetPas:Refresh()
          	oGetPas:SetFocus()
            Return
       Endif
 /*
	   
	   If (!PswSeek(__cUserId, .T.) )            

       //If !PswSeek(cGetPas)
          Messagebox("Senha Inválida !!","Atenção...",48) 
          cGetPas := space(10)
          oGetPas:Refresh()
          oGetPas:SetFocus()
          Return
       Endif  */
       
Return(.t.)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³         ³ Autor ³                       ³ Data ³           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³                  ³Contato ³                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±*/

User Function fPesAPu(Fase)

     Private cGet1Env   := cNumOrd
     Private cGet2Env   := cNumLot
     Private cGet3Env   := cNumPro
     Private nGet5Env   := Posicione("ZZA", 2, xFilial("ZZA")+SubStr(cNumOrd, 1, 11), "ZZA_QUANT")
     Private cSay1Env   := Space(1)
     Private cSay2Env   := Space(1)
     Private cSay4Env   := Space(20)
     Private cCor4EnB   := CLR_BLUE
     Private cCor4EnR   := CLR_RED
     Private cCor4Env   := 0
     Private nQtdeIni   := 0
     Private aGerCom    := {}
     Private nGetBPes   := Posicione("ZZA", 2, xFilial("ZZA")+SubStr(cNumOrd, 1, 11), Iif(Fase==1,"ZZA_PESAPB","ZZA_PESAPU"))
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oFontEnv", "oDlg1Env", "oGrp1Env", "oSay1Env", "oSay2Env", "oGet1Env", "oGet2Env", "oBtn1Env", "oBtn2Env")
     SetPrvt("oBrw1Env", "oGrp3Env", "oBtn7Env", "oBtn8Env", "oBrw1Env", "oSay4Env", "oGetBPes", "oGrp4Env", "oSay5Env", "oGet5Env")

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oFontEnv   := TFont():New( "MS Sans Serif", 0, -19, , .F., 0, , 400, .F., .F., , , , , , )
     oFon2Env   := TFont():New( "Courier New"  , 0,  19, , .T., 0, , 400, .F., .F., , , , , , )
     oDlg1Env   := MSDialog():New( 140, 264, 477, 1028, "Apuração de Peso Bruto ("+Iif(Fase==1,"Etapa Pesagem)","Etapa Laboratório)"), , , .F., , , , , , .T., , , .T. )
     oGrp1Env   := TGroup():New( 004, 004, 048, 378, "Ordem de Produção", oDlg1Env, CLR_RED, CLR_WHITE, .T., .F. )
     oSay1Env   := TSay():New( 012, 008, { || "Ordem:"}, oGrp1Env, , oFontEnv, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 040, 012)
     oGet1Env   := TGet():New( 010, 064, { |u| If(PCount() > 0, cGet1Env := u, cGet1Env)}, oGrp1Env, 078, 014, '@R XXXXXX-99-999' , , CLR_BLACK, CLR_WHITE, oFontEnv, , , .T., "", , , .F., .F., , .T., .F., "", "cGet1Env", , )
     oSay2Env   := TSay():New( 012, 152, { || "Lote:" }, oGrp1Env, , oFontEnv, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE,032, 012)
     oGet2Env   := TGet():New( 010, 216, { |u| If(PCount() > 0, cGet2Env := u, cGet2Env)}, oGrp1Env, 036, 014, '@R 999999'        , , CLR_BLACK, CLR_WHITE, oFontEnv, , , .T., "", , , .F., .F., , .T., .F., "", "cGet2Env", , )
     oSay3Env   := TSay():New( 030, 008, { || "Produto:"}, oGrp1Env, , oFontEnv, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 056, 012)
     oGet3Env   := TGet():New( 028, 064, { |u| If(PCount() > 0, cGet3Env := u, cGet3Env)}, oGrp1Env, 080, 014, '@R XX 99.99.999-99', , CLR_BLACK, CLR_WHITE, oFontEnv, , , .T., "", , , .F., .F., , .T., .F., "", "cGet3Env", ,)
     If Fase == 2  // visivel somente para o laboratório.
	     oSay5Env   := TSay():New( 030, 152, { || "Qtde:"}, oGrp1Env, , oFontEnv, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 056, 012)
	     oGet5Env   := TGet():New( 028, 216, { |u| If(PCount() > 0, nGet5Env := u, nGet5Env)}, oGrp1Env, 080, 014, '@E 999,999,999.999', , CLR_BLACK, CLR_WHITE, oFontEnv, , , .T., "", , , .F., .F., , .T., .F., "", "nGet5Env", ,)
     Endif
     oSay4Env   := TSay():New( 030, 152, { || cSay4Env  }, oGrp1Env, , oFontEnv, .F., .F., .F., .T., cCor4Env, CLR_WHITE, 106, 012)
   
     oBtn1Env   := TButton():New( 009, 304, "Confirma", oGrp1Env, {|| fConfPes(Fase)}, 052, 016, , oFontEnv, , .T., , "", , , , .F. )
     oBtn2Env   := TButton():New( 030, 304, "Abandona", oGrp1Env, {|| fSPesApu()}, 052, 016, , oFontEnv, , .T., , "", , , , .F. )

     oGrp2Env   := TGroup():New( 052, 004, 100, 378, "", oDlg1Env, CLR_BLACK, CLR_WHITE, .T., .F. )
     oSay6Env   := TSay():New( 060, 008, { || "Informar com Atenção o Peso Bruto Apurado, inclusive com o peso do Tacho."}, oGrp2Env, , oFontEnv, .F., .F., .F., .T., CLR_RED, CLR_WHITE, 340, 012)

     //If Posicione("ZZA", 2, xFilial("ZZA")+SubStr(cNumOrd, 1, 11), "ZZA_PESAPU") > 0
     //	lJaIniciou := .T.
     //Endif	

     oGrp4Env   := TGroup():New( 104, 306, 162, 378, "Peso Balança", oDlg1Env, CLR_RED, CLR_WHITE, .T., .F. )
     oGetBPes   := TGet():New( 114, 309, {|u| If(PCount() > 0, nGetBPes := u, nGetBPes)}, oDlg1Env, 064, 014, '@E 999,999.999', , CLR_BLACK, CLR_WHITE, oFontEnv, , , .T., "", , , .F., .F., , .F., .F., "", "nGetBPes", ,)

     Iif(Fase==1,oTbl2Ger("FY"),oTbl2Ger("FZ"))
     
     DbSelectArea("TMPFUN")
     DbSetOrder(1)  
     
	 oGrp3Env   := TGroup():New( 104, 004, 162, 304, "", oDlg1Env, CLR_BLACK, CLR_WHITE, .T., .F. )
     oBrw2Env   := MsSelect():New( "TMPFUN", "", "", { {"FUNFMA", "", "Matricula", "@!R 999999"}, {"FUNNOM", "", "Nome", "@!"} }, .F., , {108, 007, 159, 240}, , , oGrp3Env ) 
     //oBtn7Env   := TButton():New( 112, 255, "Inclui", oGrp3Env, {|| fMntFunApt("0", Iif(Fase==1,"01","EN"))}, 037, 012, , , , .T., , "", , , , .F. )
     //oBtn9Env   := TButton():New( 142, 255, "Exclui", oGrp3Env, {|| fMntFunApt("1", Iif(Fase==1,"01","EN"))}, 037, 012, , , , .T., , "", , , , .F. )

     oBtn7Env   := TButton():New( 112, 255, "Inclui", oGrp3Env, {|| fMntFunApt("0", "01")}, 037, 012, , , , .T., , "", , , , .F. )
     oBtn9Env   := TButton():New( 142, 255, "Exclui", oGrp3Env, {|| fMntFunApt("1", "01")}, 037, 012, , , , .T., , "", , , , .F. )

	 oDlg1Env:Activate(,,,.T.)										
Return



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³         ³ Autor ³                       ³ Data ³           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³                  ³Contato ³                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³  /  /  ³                                               ³±±
±±³              ³  /  /  ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function fEnvaseP()
     //Local lJainiciou   := .f.

     Private cGet1Env   := cNumOrd
     Private cGet2Env   := cNumLot
     Private cGet3Env   := cCodPro
     Private cSay1Env   := Space(1)
     Private cSay2Env   := Space(1)
     Private cSay4Env   := Space(20)
     Private cCor4EnB   := CLR_BLUE
     Private cCor4EnR   := CLR_RED
     Private cCor4Env   := 0
     Private nQtdeIni   := 0
     Private aGerCom    := {}
	 //Private nGetBPes   := nPesoApu
     Private nGetBPes   := Posicione("ZZA", 2, xFilial("ZZA")+SubStr(cNumOrd, 1, 11), "ZZA_PESAPU")
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oFontEnv", "oDlg1Env", "oGrp1Env", "oSay1Env", "oSay2Env", "oGet1Env", "oGet2Env", "oBtn1Env", "oBtn2Env")
     SetPrvt("oBtn3Env", "oBtn4Env", "oBtn5Env", "oBtn6Env", "oBrw1Env", "oGrp3Env", "oBtn7Env", "oBtn8Env", "oBrw1Env")
     SetPrvt("oSay4Env", "oBtn9Env", "oGetBPes", "oGrp4Env")

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oFontEnv   := TFont():New( "MS Sans Serif", 0, -19, , .F., 0, , 400, .F., .F., , , , , , )
     oFon2Env   := TFont():New( "Courier New"  , 0,  19, , .T., 0, , 400, .F., .F., , , , , , )
     oDlg1Env   := MSDialog():New( 140, 264, 677, 1028, "Envase", , , .F., , , , , , .T., , , .T. )
     oGrp1Env   := TGroup():New( 004, 004, 048, 378, "Ordem de Produção", oDlg1Env, CLR_RED, CLR_WHITE, .T., .F. )
     oSay1Env   := TSay():New( 012, 008, { || "Ordem:"}, oGrp1Env, , oFontEnv, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 040, 012)
     oGet1Env   := TGet():New( 010, 064, { |u| If(PCount() > 0, cGet1Env := u, cGet1Env)}, oGrp1Env, 078, 014, '@R XXXXXX-99-999' , , CLR_BLACK, CLR_WHITE, oFontEnv, , , .T., "", , , .F., .F., , .T., .F., "", "cGet1Env", , )
     oSay2Env   := TSay():New( 012, 152, { || "Lote:" }, oGrp1Env, , oFontEnv, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE,032, 012)
     oGet2Env   := TGet():New( 010, 216, { |u| If(PCount() > 0, cGet2Env := u, cGet2Env)}, oGrp1Env, 036, 014, '@R 999999'        , , CLR_BLACK, CLR_WHITE, oFontEnv, , , .T., "", , , .F., .F., , .T., .F., "", "cGet2Env", , )
     oSay3Env   := TSay():New( 030, 008, { || "Produto:"}, oGrp1Env, , oFontEnv, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 056, 012)
     oGet3Env   := TGet():New( 028, 064, { |u| If(PCount() > 0, cGet3Env := u, cGet3Env)}, oGrp1Env, 080, 014, '@R XX 99.99.999-99', , CLR_BLACK, CLR_WHITE, oFontEnv, , , .T., "", , , .F., .F., , .T., .F., "", "cGet3Env", ,)
     oSay4Env   := TSay():New( 030, 152, { || cSay4Env  }, oGrp1Env, , oFontEnv, .F., .F., .F., .T., cCor4Env, CLR_WHITE, 106, 012)
     oBtn1Env   := TButton():New( 009, 304, "Confirma", oGrp1Env, {|| fConfEnv()}, 052, 016, , oFontEnv, , .T., , "", , , , .F. )
     oBtn2Env   := TButton():New( 030, 304, "Abandona", oGrp1Env, {|| fSairEnv()}, 052, 016, , oFontEnv, , .T., , "", , , , .F. )
     oGrp2Env   := TGroup():New( 052, 004, 200, 304, "", oDlg1Env, CLR_BLACK, CLR_WHITE, .T., .F. )

     // Informar peso Balança Antes do Envase
     //If Posicione("ZZA", 2, xFilial("ZZA")+SubStr(cNumOrd, 1, 11), "ZZA_PESAPU") > 0 // rotina desabilitada nesta etapa, passada do envase para o final do laboratório
     	//lJaIniciou := .T.
     //Endif	
     //oGrp4Env   := TGroup():New( 175, 306, 200,378, "Peso Balança", oDlg1Env, CLR_RED, CLR_WHITE, Iif(lJaIniciou,.f.,.t.), .F. )
     //oGetBPes   := TGet():New( 182, 309, {|u| If(PCount() > 0, nGetBPes := u, nGetBPes)}, oDlg1Env, 064, 014, '@E 999,999.999', , CLR_BLACK, CLR_WHITE, oFontEnv, , , Iif(lJaIniciou,.f.,.t.), "", , , .F., .F., , .F., .F., "", "nGetBPes", ,)
     oBtn3Env   := TButton():New( 058, 245, "Complemento", oGrp2Env, {|| fManuEnv(1) }, 053, 016, , oFon2Env, , .T., , "", , , , .F. )
     oBtn4Env   := TButton():New( 078, 245, "<-- Aponta" , oGrp2Env, {|| fManuEnv(2) }, 053, 016, , oFon2Env, , .T., , "", , , , .F. )
     oBtn5Env   := TButton():New( 098, 245, "<-- Exclui" , oGrp2Env, {|| fManuEnv(3) }, 053, 016, , oFon2Env, , .T., , "", , , , .F. )
     oBtn6Env   := TButton():New( 180, 245, "<-- Estorna", oGrp2Env, {|| fEstoEnv()  }, 053, 016, , oFon2Env, , .T., , "", , , , .F. )
     //If Len(Alltrim(cGet3Env)) == 12 .and. Substr(Alltrim(cGet3Env),11,2) == '99' 
	 //If Alltrim(Posicione("ZZA", 2, xFilial("ZZA")+Alltrim(cGet1Env), "ZZA_SP")) ==  ""
	     oBtn9Env   := TButton():New( 118, 245, "Apt. Sobra" , oGrp2Env, {|| fManuEnv(4) }, 053, 016, , oFon2Env, , .T., , "", , , , .F. )
     //Endif 
     oTbl2Ger("EN")
     oTbl1Env()
     DbSelectArea("TMPENV")
     DbSetOrder(1)
     DbGoTop()
     oBrw1Env   := MsSelect():New( "TMPENV", "", "", { {"ENVCOD", "", "Codigo", "@R XX 99.99.999-99"}, { "ENVSOL", "", "Solicitada", "@E 99,999"}, { "ENVPRO", "", "Produzida", "@E 99,999"}, { "ENVBAI", "", "Baixa", "@!"} }, .F., , {058, 007, 196, 240}, , , oGrp2Env ) 
     oGrp3Env   := TGroup():New( 204, 004, 262, 304, "", oDlg1Env, CLR_BLACK, CLR_WHITE, .T., .F. )
     oBtn7Env   := TButton():New( 212, 255, "Inclui" , oGrp3Env, {|| fMntFunApt("0", "EN") }, 037, 012, , , , .T., , "", , , , .F. )
     oBtn8Env   := TButton():New( 242, 255, "Excluir", oGrp3Env, {|| fMntFunApt("1", "EN") }, 037, 012, , , , .T., , "", , , , .F. )
     oBrw1Env:oBrowse:oFont          := oFon2Env
     oBrw1Env:oBrowse:lAdjustColSize := .t.
     oBrw1Env:oBrowse:bChange := {|| fTrocaEnv() }

     DbSelectArea("TMPFUN")
     DbGoTop()
     oBrw2Env   := MsSelect():New( "TMPFUN", "", "", { { "FUNFMA", "", "Matricula", ""}, { "FUNNOM", "", "Nome", "@!"} }, .F., , {208, 007, 259, 240}, , , oGrp3Env )

     oDlg1Env:Activate(,,,.T.)
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fTrocaEnv()
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fTrocaEnv()
       //Ajusta Funcionário por produção
       DbSelectArea("TMPFUN")
       DbClearFilter()
       DbSelectArea("TMPFUN")
       DbGoTop()
       While !Eof()
             RecLock("TMPFUN", .f.)
                If TMPFUN->FUNSEQ+TMPFUN->FUNPRO == TMPENV->ENVSEQ+TMPENV->ENVCOD
                   If !TMPFUN->FUNVIS $ "E"
                      TMPFUN->FUNVIS := "S"
                   Endif
                Else
                   If !TMPFUN->FUNVIS $ "E"
                      TMPFUN->FUNVIS := "N"
                   Endif
                Endif
             MsUnLock()
             DbSelectArea("TMPFUN")
             DbSkip()
       Enddo
       cFilFun := 'FUNVIS == "S"'
       MSFILTER(cFilFun)
       DbSelectArea("TMPFUN")
       DbGoTop()
       //Monta botões
       If nQtdeIni == TMPENV->(RecCount()) //Se Esse numeros forem iguais significa que é somente inicio de O.P.
          oBtn1Env:cCaption := "Iniciar" //1º Botão - Iniciar / Confirmar   - 
                                         //2º Botão - Abandona              - Nunca mexer nesse botão
          oBtn3Env:lVisible := .f.       //3º Botão - Complemento / Iniciar -
          oBtn4Env:lVisible := .f.       //4º Botão - Apontar               -
          oBtn5Env:lVisible := .f.       //5º Botão - Excluir / Encerrar    -
          oBtn6Env:lVisible := .f.       //6º Botão - Estornar              -
          oBtn9Env:lVisible := .f.       //7º Botão - Apontamento Perda Pó  -
       Else
          //1º Botão
          If SubStr(TMPENV->ENVBOT, 1, 1) == '0'
             oBtn1Env:lVisible := .f.
          ElseIf SubStr(TMPENV->ENVBOT, 1, 1) == '1'
                 oBtn1Env:cCaption := "Iniciar"
                 oBtn1Env:lVisible := .t.
          ElseIf SubStr(TMPENV->ENVBOT, 1, 1) == '2'
                 oBtn1Env:cCaption := "Confirmar"
                 oBtn1Env:lVisible := .t.
          Endif
          //2º Botão - Nunca mexer nesse botão
          //3º Botão - Complemento Iniciar
          If SubStr(TMPENV->ENVBOT, 3, 1) == '0'
             oBtn3Env:lVisible := .f.
          ElseIf SubStr(TMPENV->ENVBOT, 3, 1) == '1' // .and.
                 oBtn3Env:cCaption := "Complemento"
                 oBtn3Env:lVisible := .F.
          ElseIf SubStr(TMPENV->ENVBOT, 3, 1) == '2'
                 oBtn3Env:cCaption := "Iniciar"
                 oBtn3Env:lVisible := .t.
          Endif
          //4º Botão - Apontar
          If SubStr(TMPENV->ENVBOT, 4, 1) == '0'
             oBtn4Env:lVisible := .f.
          ElseIf SubStr(TMPENV->ENVBOT, 4, 1) == '1'
                 oBtn4Env:lVisible := .t.
          Endif
          //5º Botão - Excluir / Encerrar
          If SubStr(TMPENV->ENVBOT, 5, 1) == '0'
             oBtn5Env:lVisible := .f.
          ElseIf SubStr(TMPENV->ENVBOT, 5, 1) == '1'
                 oBtn5Env:cCaption := "<-- Exclui"
                 oBtn5Env:lVisible := .t.
          ElseIf SubStr(TMPENV->ENVBOT, 5, 1) == '2'
                 oBtn5Env:cCaption := "<-- Encerra"
                 oBtn5Env:lVisible := .t.
          Endif
          //6º Botão - Estornar
          If SubStr(TMPENV->ENVBOT, 6, 1) == '0'
             oBtn6Env:lVisible := .f.
          ElseIf SubStr(TMPENV->ENVBOT, 6, 1) == '1'
          	 oBtn6Env:lVisible := .t.
          Endif
          //7º Botão - Informar sobra
          If (Len(Alltrim(cGet3Env)) == 12) .and. (Substr(Alltrim(cGet3Env),11,2) $ '99.00') .and. (Len(Alltrim(Posicione("ZZA", 2, xFilial("ZZA")+Alltrim(cGet1Env), "ZZA_SP"))) == 0)
	          If (SubStr(TMPENV->ENVBOT, 7, 1) == '0')
    	         oBtn9Env:lVisible := .f.                     
        	  ElseIf (SubStr(TMPENV->ENVBOT, 7, 1) == '1') 
          		 oBtn9Env:lVisible := .t.
	          Endif
    	  Else
      	  	  oBtn9Env:lVisible := .f.
    	  Endif
          oBtn1Env:Refresh()
          oBtn3Env:Refresh()
          oBtn4Env:Refresh()
          oBtn5Env:Refresh()
          oBtn6Env:Refresh()
          oBtn9Env:Refresh()
          
       Endif
       oBrw2Env:oBrowse:Refresh()
Return


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fVerPEnv() Verifica se o Peso da Balança esta dentro do limite 
                     Fase 1 - Após Pesagem Balanceiro
                     Fase 2 - Após Laboratório, antes do Envase
LIMITE PERMITIDO PARA DIFERENÇA DE PESO ENTRE O TOTAL APONTADO E O TOTAL PESADO NA BALANÇA
		DE    0 A 150 KG/LITRO -> 600 GRAMAS/MLS
	    ACIMA DE 150  KG/LITRO -> 0,4 %
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÁÄÄÄÄÄÄÁÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fVerPEnv(Fase)

    Local nVolTotal :=0  
    Local nPesTotal :=0
    Local nTara     :=0
	Local nLimite   :=0 
	Local nDif      :=0
    Local nPesApto  :=0
	Local lReturn   :=.t.
	
	DbSelectArea("ZZA")
    DbSetOrder(2)
	DbSeek(xFilial("ZZA")+cNumOrd, .t.)
   	If Found()
		If Fase ==1
			nVolTotal := (Posicione("SC2", 1, xFilial("SC2")+SubStr(cNumOrd, 1, 11), "C2_QUANT")) 
	 		nPesTotal := ZZA_PESPES // peso após final pesagem       
			nPesApto  := ZZA->ZZA_PESAPB
	   	Elseif Fase == 2
    	   	nVolTotal := ZZA_QUANT
       		nPesTotal := ZZA_PESFIN // peso final, após laboratório
	       	nPesApto  := ZZA->ZZA_PESAPU 
		Endif	        
    
	    nTara := ZZA_TARA 
    
	    If nVolTotal <= 150
    		nLimite  := 0.6
		    nPesTotal:= (nPesTotal+nTara)        	
			nDif     := Iif(nPesApto > nPesTotal,(nPesApto - nPesTotal),(nPesTotal-nPesApto)) //Trata valor negativo        	
			If nDif > nLimite
		    	Messagebox("Diferença entre peso apontado e peso apurado na balança é maior do que o limite estabelecido para este volume. Entre em contato com o PCP - O.P Bloqueada !!","O.P BLOQUEADA",48) 				
		    	lReturn :=.f.
		    Endif
	    ElseIf nVolTotal > 150
		    nLimite  := 0.4
	        nPesTotal:= (nPesTotal+nTara)
			nDif     := Iif(nPesApto > nPesTotal,(nPesApto - nPesTotal),(nPesTotal-nPesApto)) //Trata valor negativo
			nPorcent := Round(((nDif)*(100/nPesApto)),2)
							            
			If nPorcent > nLimite
				Messagebox("Diferença entre peso apontado e peso apurado na balança é maior do que o limite estabelecido para este volume. Entre em contato com o PCP - O.P Bloqueada !!","O.P BLOQUEADA",48) 
				lReturn :=.f.
	   	    Endif 
   		Endif
   	Else
		Messagebox("Ordem de Produção não encontrada !!","Atenção...",48)    			
   	Endif
   	
Return(lReturn)

Static Function fConfPes(Fase) // 1 - Após Pesagem  / 2 - Após Laboratório

    //Local aImpEtq   := {}
    Local nPesTotal := 0
    Local nTara     := 0
    Local nDif      := 0
    Local nPorcent  := 0
       
    //Verifica se os coloristas foram apontados
    DbSelectArea("TMPFUN")
    Pack
    DbGoTop()
    If nGetBPes <=0    // Verificar se o peso apurado na balança esta sendo digitado
   	    lRet := MsgBox("Por favor informe o PESO da Balança !","Pergunta","YESNO")
//		If lRet
  			oGetBPes:SetFocus()
   			Return .f.
//		Endif
    Else

        If TMPFUN->(RecCount()) <= 0
            Messagebox("O colaborador que operou a pesagem não foi indicado, verifique !!","Atenção...",48) 
            Return .f.
        EndIf
        // LIMITE PERMITIDO PARA DIFERENÇA DE PESO ENTRE O TOTAL APONTADO E O TOTAL PESADO NA BALANÇA
        // DE    0 A 150 KG/LITRO -> 600 GRAMAS/MLS
	    // ACIMA DE 150  KG/LITRO -> 0,4 %
        //nVolTotal := (Posicione("ZZA", 2, xFilial("ZZA")+SubStr(cNumOrd, 1, 11), "ZZA_QUANT"))
		
        If Fase ==1
			nVolTotal := (Posicione("SC2", 1, xFilial("SC2")+SubStr(cNumOrd, 1, 11), "C2_QUANT")) 
 			nPesTotal := (Posicione("ZZA", 2, xFilial("ZZA")+SubStr(cNumOrd, 1, 11), "ZZA_PESPES")) // peso após final pesagem       
        Else
        	nVolTotal := (Posicione("ZZA", 2, xFilial("ZZA")+SubStr(cNumOrd, 1, 11), "ZZA_QUANT"))
        	nPesTotal := (Posicione("ZZA", 2, xFilial("ZZA")+SubStr(cNumOrd, 1, 11), "ZZA_PESFIN")) // peso final, após laboratório
		Endif	        
        nTara     := (Posicione("ZZA", 2, xFilial("ZZA")+SubStr(cNumOrd, 1, 11), "ZZA_TARA")) 
        cCodPro   := (Posicione("ZZA", 2, xFilial("ZZA")+SubStr(cNumOrd, 1, 11), "ZZA_PRODUT"))    
        If nVolTotal <= 150
            nLimite := 0.6
	        nPesTotal:= nPesTotal+nTara        	
		    nDif     := Iif(nGetBPes > nPesTotal,(nGetBPes - nPesTotal),(nPesTotal-nGetBPes)) //Trata valor negativo        	
		    If nDif > nLimite
	    		Messagebox("Diferença entre peso apontado e peso apurado na balança é maior do que o limite estabelecido para este volume. Atenção com as divergências de apontamento e pesagem !!","Atenção...",48) 				
			  	cAuxMens := "Diferença entre peso apontado e peso apurado ! "+Iif(Fase==1," - Após Pesagem"," - Após Laboratório")+;
				chr(13)+chr(10)+"Lote.........: "+(cNumLot)+"   O.P : "+(cNumOrd)+;
				chr(13)+chr(10)+"Produto......: "+(cCodPro)+" - "+Posicione("SB1", 1, xFilial("SB1")+Alltrim(cCodPro), "B1_DESC")+; //cNumPro
				chr(13)+chr(10)+"Peso Apontado: "+TRANSFORM(nPesTotal,'@E 999,999.999')+;
				chr(13)+chr(10)+"Peso Apurado.: "+TRANSFORM(nGetBPes, '@E 999,999.999')+;
				chr(13)+chr(10)+"Diferença....: "+TRANSFORM(nDif,     '@E 999,999.999')+;
				chr(13)+chr(10)+"Limite Dif...: "+TRANSFORM(nLimite,  '@E 999,999.999')+;
				chr(13)+chr(10)+"Prog. Origem : BRPCPA08"
   				If Substr(xFilial("ZZA"),1,2)== "06"
   				    //U_EnvMail("DISSOLTEX - O.P "+cNumOrd+" com diferença entre peso apontado e peso apurado !"+Iif(Fase==1," - Após Pesagem"," - Após Laboratório") ,cAuxMens,"silene@dissoltex.com.br,ricardo@dissoltex.com.br","") 
           		Else
   				    U_EnvMail("BRASILUX - O.P "+cNumOrd+" com diferença entre peso apontado e peso apurado !"+Iif(Fase==1," - Após Pesagem"," - Após Laboratório") ,cAuxMens,"pcp@brasilux.com.br, paulo@brasilux.com.br","")                       	  
					//U_EnvMail("BRASILUX - O.P "+cNumOrd+" com diferença entre peso apontado e peso apurado !"+Iif(Fase==1," - Após Pesagem"," - Após Laboratório") ,cAuxMens,"andre@brasilux.com.br","")                       	  
				Endif
		    Endif
   	    ElseIf nVolTotal > 150
		    nLimite  := 0.4
	        nPesTotal:= nPesTotal+nTara
			nDif     := Iif(nGetBPes > nPesTotal,nGetBPes - nPesTotal,nPesTotal-nGetBPes) //Trata valor negativo
			nPorcent := Round(((nDif)*(100/nGetBPes)),2)
							            
			If nPorcent > nLimite
   				Messagebox("Diferença entre peso apontado e peso apurado na balança é maior do que o limite estabelecido para este volume. Atenção com as divergências de apontamento e pesagem !!","Atenção...",48) 
			  	cAuxMens := "Diferença entre peso apontado e peso apurado ! "+Iif(Fase==1," - Após Pesagem"," - Após Laboratório")+;
				chr(13)+chr(10)+"Lote.........: "+(cNumLot)+"   O.P : "+(cNumOrd)+;
				chr(13)+chr(10)+"Produto......: "+(cCodPro)+" - "+Posicione("SB1", 1, xFilial("SB1")+Alltrim(cCodPro), "B1_DESC")+;
				chr(13)+chr(10)+"Peso Apontado: "+TRANSFORM(nPesTotal,'@E 999,999.999')+;
				chr(13)+chr(10)+"Peso Apurado.: "+TRANSFORM(nGetBPes, '@E 999,999.999')+;
				chr(13)+chr(10)+"Diferença....% "+TRANSFORM(nPorcent, '@E 999,999.999')+;
				chr(13)+chr(10)+"Limite Dif...% "+TRANSFORM(nLimite,  '@E 999,999.999')+;
				chr(13)+chr(10)+"Prog. Origem : BRPCPA08"
   				If Substr(xFilial("ZZA"),1,2)== "06"
   				    //U_EnvMail("DISSOLTEX - O.P "+cNumOrd+" com diferença entre peso apontado e peso apurado !"+Iif(Fase==1," - Após Pesagem"," - Após Laboratório") ,cAuxMens,"silene@dissoltex.com.br,ricardo@dissoltex.com.br","") 
            	Else
   				    U_EnvMail("BRASILUX - O.P "+cNumOrd+" com diferença entre peso apontado e peso apurado !"+Iif(Fase==1," - Após Pesagem"," - Após Laboratório") ,cAuxMens,"pcp@brasilux.com.br,paulo@brasilux.com.br","")                       	  
					//U_EnvMail("BRASILUX - O.P "+cNumOrd+" com diferença entre peso apontado e peso apurado !"+Iif(Fase==1," - Após Pesagem"," - Após Laboratório") ,cAuxMens,"andre@brasilux.com.br","")                       	  	
				Endif

   				 //oGetBPes:SetFocus()
   				 //Return .f.
    	    Endif 
     	Endif

        //Gravar ZZA e ZZG 
        DbSelectArea("ZZA")
        DbSetOrder(2)
	    DbSeek(xFilial("ZZA")+cNumOrd, .t.)
   		If Found()
	   		RecLock("ZZA", .f.)
				If Fase == 1
					ZZA->ZZA_PESAPB := nGetBPes		// PESO APURADO APÓS BALANCEIRO
				Else
					ZZA->ZZA_PESAPU := nGetBPes		// PESO APURADO APÓS LABORATÓRIO			
				Endif
	
	        MsUnLock()
      	Endif
                
       	DbSelectArea("ZZG")
        DbSetOrder(6)
        DbSeek(xFilial("ZZG")+cNumLot+Iif(Fase ==1,'Y','Z')+'01', .t.) //ZZG_FILIAL+ZZG_LOTE+ZZG_TPUSER+ZZG_SEQENV                                                                                                                       
	   	If !Found()
           	RecLock("ZZG", .t.)
               	ZZG->ZZG_FILIAL := xFilial("ZZG")
                ZZG->ZZG_ORDEM  := cNumOrd
                ZZG->ZZG_LOTE   := cNumLot
                ZZG->ZZG_PROENV := ''
                ZZG->ZZG_SEQENV := '01'
                ZZG->ZZG_TPUSER := Iif(Fase ==1,'Y','Z')
                ZZG->ZZG_FILMAT := TMPFUN->FUNFMA
                ZZG->ZZG_NOME   := TMPFUN->FUNNOM
            MsUnLock()
        Endif
      
        //Fecha tela de inicio de envase
        DbSelectArea("TMPFUN")
        DbCloseArea()
        oDlg1Env:End()       

        //Voltar situação da tela inicial
        cGet1Apt := space(11)
        oGet1Apt:SetFocus()
        oGet1Apt:Refresh()
        oBtnDApt:cCaption := "Sair"
        oBtnDApt:bAction  := {|| fAptSaiVol(1)}
        oBtnDApt:Refresh()
        oGet1Apt:lReadOnly := .f.
        oGet1Apt:Refresh()  
        
        
        
Endif


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fConfEnv()
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fConfEnv()
       Local aImpEtq   := {}
       //Local nPesTotal := 0
       //Local nTara     := 0
       //Local nDif      := 0
       //Local nPorcent  := 0
       Local _nY, nY
       
       If SubStr(oBtn1Env:cCaption, 1, 1) $ 'I' //Inicio de Envase
          //Verifica se os coloristas foram apontados
          DbSelectArea("TMPFUN")
          pack
          DbGoTop()

          If TMPFUN->(RecCount()) <= 0
             Messagebox("Os envasadores não foram apontados, verifique !!","Atenção...",48) 
             Return .f.
          Else
             aQtdEnv := {}
             DbSelectArea("TMPENV")
             DbGoTop()
             While !Eof()
                   If aScan(aQtdEnv, { |x| x[1] == TMPENV->ENVSEQ+TMPENV->ENVCOD } ) == 0
                      aAdd(aQtdEnv, { TMPENV->ENVSEQ+TMPENV->ENVCOD, 0})
                      DbSelectArea("TMPFUN")
                      DbClearFilter()
                      DbGoTop()
                      DbSetOrder(3)
                      DbSeek(TMPENV->ENVSEQ+TMPENV->ENVCOD, .t.)
                      While !Eof() .and. TMPFUN->FUNSEQ+TMPFUN->FUNPRO == TMPENV->ENVSEQ+TMPENV->ENVCOD
                            aQtdEnv[ aScan(aQtdEnv, { |x| x[1] == TMPENV->ENVSEQ+TMPENV->ENVCOD } ) ][ 2 ] += 1
                            DbSelectArea("TMPFUN")
                            DbSkip()
                      Enddo
                   Else
                      aQtdEnv[ aScan(aQtdEnv, { |x| x[1] == TMPENV->ENVSEQ+TMPENV->ENVCOD } ) ][ 2 ] += 1
                   Endif
                   DbSelectArea("TMPENV")
                   DbSkip()
             Enddo
             DbSelectArea("TMPENV")
             DbGoTop()
             DbSelectArea("TMPFUN")
             DbGoTop()
             cFilFun := 'FUNVIS == "S"'
             MSFILTER(cFilFun)
             cMsgOrd := ""
             For _nY := 1 To Len(aQtdEnv)
                 If aQtdEnv[_nY][2] <= 0
                    cMsgOrd += aQtdEnv[_nY][1]+Chr(13)+Chr(10)
                 Endif
             Next
             If !Empty(cMsgOrd)
                cMsgFun := "Atenção, a(s) Ordem(ns) de Produção abaixo: "+Chr(13)+Chr(10)
                cMsgFun += Alltrim(u_Tiraacento(cMsgOrd))
                cMsgFun += ", não possue(m) envasador(es) cadastrado(s)!"
                //MsgStop(cMsgFun)
                Messagebox(cMsgFun,"Atenção...",48) 
                Return .f.
             Endif
          EndIf
          //Gravar ZZA e ZZG com os inicios dos envases.
          DbSelectArea("TMPFUN")
          DbClearFilter()
          DbGoTop()

          DbSelectArea("TMPENV")
          DbGoTop()
          While !Eof()
                DbSelectArea("ZZA")
                RecLock("ZZA", .t.)
                   ZZA->ZZA_FILIAL := xFilial("ZZA") //FILIAL
                   ZZA->ZZA_ORDEM  := TMPENV->ENVORD //ORDEM DE PRODUÇÃO
                   ZZA->ZZA_LOTE   := TMPENV->ENVLOT //LOTE
                   ZZA->ZZA_PRODUT := TMPENV->ENVCOD //CODIGO DO PRODUTO
                   ZZA->ZZA_FLAG   := '6'            //INICIO DE ENVASE
                   ZZA->ZZA_DTINI  := TMPENV->ENVDAT //DATA DE INICIO
                   ZZA->ZZA_HINI   := TMPENV->ENVHOR //HORA DE INICIO
                   ZZA->ZZA_PESPES := TMPENV->ENVSOL //
                   ZZA->ZZA_PESCOL := TMPENV->ENVSOL //
                   ZZA->ZZA_TPENVA := '1'            //1-PENDENTE; P=PARCIAL; T=TOTAL
                   ZZA->ZZA_SEQENV := TMPENV->ENVSEQ //SEQUENCIA DE ENVASE PARA ENVASE PARCIAL
                   ZZA->ZZA_HELP   := cParInf5+" - 6 - Inicio de Envase"
                   //ZZA->ZZA_PESAPU := nGetBPes		
                MsUnLock()
                /*
                DbSelectArea("ZZA")
	            DbSetOrder(2)
      		    DbSeek(xFilial("ZZA")+cNumOrd, .t.)
           		If Found()
              		RecLock("ZZA", .f.)
						ZZA->ZZA_PESAPU := nGetBPes		
	                MsUnLock()
      			Endif
                */
                DbSelectArea("TMPFUN")
                DbSetOrder(3)
                DbSeek(TMPENV->ENVSEQ+TMPENV->ENVCOD, .t.)
                If Found()
                   While !Eof() .and. TMPFUN->FUNSEQ+TMPFUN->FUNPRO == TMPENV->ENVSEQ+TMPENV->ENVCOD
                         DbSelectArea("ZZG")
                         DbSetOrder(2)
                         DbSeek(xFilial("ZZG")+TMPENV->ENVLOT, .t.)
                         If !Found()
                            RecLock("ZZG", .t.)
                               ZZG->ZZG_FILIAL := xFilial("ZZG")
                               ZZG->ZZG_ORDEM  := cNumOrd
                               ZZG->ZZG_LOTE   := cNumLot
                               ZZG->ZZG_PROENV := TMPENV->ENVCOD
                               ZZG->ZZG_SEQENV := TMPENV->ENVSEQ
                               ZZG->ZZG_TPUSER := "E"
                               ZZG->ZZG_FILMAT := TMPFUN->FUNFMA
                               ZZG->ZZG_NOME   := TMPFUN->FUNNOM
                            MsUnLock()
                         Else
                            lAddEnv := .f.
                            While !Eof() .and. ZZG->ZZG_LOTE == TMPENV->ENVLOT
                                  If ZZG->ZZG_TPUSER $ "E"
                                     If ZZG->ZZG_FILMAT == TMPFUN->FUNFMA
                                        If ZZG->ZZG_PROENV == TMPFUN->FUNPRO
                                           lAddEnv := .f.
                                           Exit
                                        Else
                                           lAddEnv := .t.
                                        Endif
                                     Else
                                        lAddEnv := .t.
                                     Endif
                                  Else
                                     lAddEnv := .t.
                                  Endif
                                  DbSelectArea("ZZG")
                                  DbSkip()
                            EndDo
                            If lAddEnv
                               RecLock("ZZG", .t.)
                                  ZZG->ZZG_FILIAL := xFilial("ZZG")
                                  ZZG->ZZG_ORDEM  := cNumOrd
                                  ZZG->ZZG_LOTE   := cNumLot
                                  ZZG->ZZG_PROENV := TMPENV->ENVCOD
                                  ZZG->ZZG_SEQENV := TMPENV->ENVSEQ
                                  ZZG->ZZG_TPUSER := "E"
                                  ZZG->ZZG_FILMAT := TMPFUN->FUNFMA
                                  ZZG->ZZG_NOME   := TMPFUN->FUNNOM
                               MsUnLock()
                            Endif
                         Endif
                         DbSelectArea("TMPFUN")
                         DbSkip()
                   EndDo
                Endif
                DbSelectArea("TMPENV")
                DbSkip()
          EndDo
          //Fecha tela de inicio de envase
          DbSelectArea("TMPENV")
          DbCloseArea()
          If ValType( oTempTab02 ) == 'O'
             oTempTab02:Delete()
          Endif
          DbSelectArea("TMPFUN")
          DbCloseArea()
          If ValType( oTempTab04 ) == 'O'
             oTempTab04:Delete()
          Endif
          oDlg1Env:End()
          fAbaAptPro()
       Else
          //Verificação das datas e horas de apontamento
          cMsgDtH := ""
          DbSelectArea("TMPENV")
          DbGoTop()
          While !Eof()
                If !SubStr(TMPENV->ENVBAI, 1, 2) $ 'AP'
                   If dDataBase < TMPENV->ENVDAT
                      cMsgDtH += "Atenção, a data do computador deve estar errada, para o produto: "+TMPENV->ENVCOD
                   ElseIf dDataBase == TMPENV->ENVDAT
                          If StrTran( SubStr(Time(), 1, 5), ":") < TMPENV->ENVHOR
                             cMsgDtH += "Atenção, a hora do computador deve estar errada para o produto: "+TMPENV->ENVCOD
                          ElseIf StrTran( SubStr(Time(), 1, 5), ":") == TMPENV->ENVHOR
                                 cMsgDtH += "Atenção, a hora não pode ser igual ao processo anterior para o produto: "+TMPENV->ENVCOD
                          Endif
                   Endif
                   If Empty(cMsgDtH)
                      //Gravar Envasadores
                      DbSelectArea("TMPFUN")
                      DbClearFilter()
                      DbGoTop()
                      DbSetOrder(3)
                      DbSeek(TMPENV->ENVSEQ+TMPENV->ENVCOD, .t.)
                      If Found()
                         aGrvFun := {}
                         While !Eof() .AND. TMPFUN->FUNSEQ == TMPENV->ENVSEQ .AND. TMPFUN->FUNPRO == TMPENV->ENVCOD
                               aAdd(aGrvFun, {TMPFUN->FUNFMA, TMPFUN->FUNNOM, TMPFUN->FUNSEQ, TMPFUN->FUNPRO, TMPFUN->FUNVIS } )
                               DbSelectArea("TMPFUN")
                               DbSkip()
                         EndDo
                         For nY := 1 To Len(aGrvFun)
                             cQry1 := ""
                             cQry1 += "SELECT * "
                             cQry1 += "FROM ZZG"+cParInf1+"0 ZZG WITH (NOLOCK) "
                             cQry1 += "WHERE ZZG.ZZG_FILIAL = '"+cParInf2+"' "
                             cQry1 += "  AND ZZG.D_E_L_E_T_ = '' "
                             cQry1 += "  AND ZZG.ZZG_LOTE   = '"+cNumLot+"' "
                             cQry1 += "  AND ZZG.ZZG_PROENV = '"+aGrvFun[nY][4]+"' "
                             cQry1 += "  AND ZZG.ZZG_SEQENV = '"+aGrvFun[nY][3]+"' "
                             cQry1 += "  AND ZZG.ZZG_FILMAT = '"+aGrvFun[nY][1]+"' "
                             TCQuery cQry1 ALIAS "TCQFUN" NEW
                             DbSelectArea("TCQFUN")
                             DbGoTop()
                             nQtdMnt := 0
                             While !Eof()
                                   nQtdMnt += 1
                                   If nQtdMnt == 1 //Ajusta Encontrado
                                      If aGrvFun[nY][5] $ 'E'
                                         cQry1 := ""
                                         cQry1 += "UPDATE ZZG010 SET D_E_L_E_T_ = '*' WHERE R_E_C_N_O_ = "+Str(TCQFUN->R_E_C_N_O_, 10)
                                         XXX := TCSQLEXEC(cQry1)
                                         If XXX <> 0
                                            cNomArq := 'C:\TEMP\ERR'+DTOS(MsDate())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+'.ERR'
                                            MemoWrit(cNomArq, cQry1)
                                         Endif
                                      Endif
                                   Else            //Exclui duplicidade
                                      cQry1 := ""
                                      cQry1 += "UPDATE ZZG010 SET D_E_L_E_T_ = '*' WHERE R_E_C_N_O_ = "+Str(TCQFUN->R_E_C_N_O_, 10)
                                      XXX := TCSQLEXEC(cQry1)
                                      If XXX <> 0
                                         cNomArq := 'C:\TEMP\ERR'+DTOS(MsDate())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+'.ERR'
                                         MemoWrit(cNomArq, cQry1)
                                      Endif
                                   Endif
                                   DbSelectArea("TCQFUN")
                                   DbSkip()
                             Enddo
                             DbSelectArea("TCQFUN")
                             DbCloseArea()
                             DbSelectArea("TMPFUN")
                             If nQtdMnt == 0 //Inclui novo.
                                If !aGrvFun[nY][5] $ 'E'
                                   RecLock("ZZG", .t.)
                                      ZZG->ZZG_FILIAL := xFilial("ZZG")
                                      ZZG->ZZG_ORDEM  := cNumOrd
                                      ZZG->ZZG_LOTE   := cNumLot
                                      ZZG->ZZG_PROENV := aGrvFun[nY][4]
                                      ZZG->ZZG_SEQENV := aGrvFun[nY][3]
                                      ZZG->ZZG_TPUSER := "E"
                                      ZZG->ZZG_FILMAT := aGrvFun[nY][1]
                                      ZZG->ZZG_NOME   := aGrvFun[nY][2]
                                   MsUnLock()
                                Endif
                             Endif
                         Next
                      Else
                         Messagebox("O Produto "+TMPENV->ENVCOD+" está sem envasador apontado!","Atenção...",48) 
                         DbSelectArea("TMPFUN")
                         cFilFun := 'FUNVIS == "S"'
                         MSFILTER(cFilFun)
                         Return
                      Endif
                      //Gravação dos dados
                      If Alltrim(TMPENV->ENVBAI) $ 'TOTAL.PARCIAL'
                         //Gravar Dados no ZZA
                         DbSelectArea("ZZA")
                         DbSetOrder(3)
                         DbSeek(xFilial("ZZA")+TMPENV->ENVLOT, .t.)
                         If Found()
                            While !Eof() .and. ZZA->ZZA_LOTE == TMPENV->ENVLOT
                                  If (ZZA->ZZA_PRODUT == TMPENV->ENVCOD) .and. (Alltrim(ZZA->ZZA_ORDEM) == Alltrim(TMPENV->ENVORD)) .and. (ZZA->ZZA_SEQENV == TMPENV->ENVSEQ)
                                     RecLock("ZZA", .f.)
                                        ZZA->ZZA_FLAG   := Iif(Alltrim(TMPENV->ENVBAI) $ 'TOTAL', '8', '7')
                                        ZZA->ZZA_DTFIM  := dDataBase
                                        ZZA->ZZA_HFIM   := SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)
                                        ZZA->ZZA_HELP   := SubStr(ZZA->ZZA_HELP, 1, 1)+" - "+Iif(Alltrim(TMPENV->ENVBAI) $ 'TOTAL', 'Apontamento Total.', 'Apontamento Parcial.')
                                        ZZA->ZZA_QUANT  := TMPENV->ENVPRO
                                        ZZA->ZZA_TPENVA := Iif(Alltrim(TMPENV->ENVBAI) $ 'TOTAL', 'T', 'P')
                                     MsUnLock()
                                  Endif
                                  DbSelectArea("ZZA")
                                  DbSkip()
                            EndDo
                         Endif
                         aAdd(aImpEtq, { TMPENV->ENVCOD, TMPENV->ENVLOT, TMPENV->ENVSEQ, TMPENV->ENVPRO } )
                      ElseIf Alltrim(TMPENV->ENVBAI) $ 'INICIADA' //Ajustar Envasadores
                             lSeqNEn := .t.
                             //Gravar Dados no ZZA
                             DbSelectArea("ZZA")
                             DbSetOrder(3)
                             DbSeek(xFilial("ZZA")+TMPENV->ENVLOT, .t.)
                             If Found()
                                While !Eof() .and. ZZA->ZZA_LOTE == TMPENV->ENVLOT
                                      If ZZA->ZZA_PRODUT == TMPENV->ENVCOD .and. ZZA->ZZA_SEQENV == TMPENV->ENVSEQ
                                         lSeqNEn := .f.
                                      Endif
                                      DbSelectArea("ZZA")
                                      DbSkip()
                                EndDo
                             Endif
                             If lSeqNEn //Gravar novo ZZA como inicio de apontamento
                                RecLock("ZZA", .t.)
                                   ZZA->ZZA_FILIAL := xFilial("ZZA")
                                   ZZA->ZZA_ORDEM  := TMPENV->ENVORD
                                   ZZA->ZZA_LOTE   := TMPENV->ENVLOT
                                   ZZA->ZZA_PRODUT := TMPENV->ENVCOD
                                   ZZA->ZZA_HELP   := cParInf5+' - 6 - Inicio de Envase.'
                                   ZZA->ZZA_FLAG   := '6'
                                   ZZA->ZZA_QUANT  := 0
                                   ZZA->ZZA_DTINI  := TMPENV->ENVDAT
                                   ZZA->ZZA_HINI   := TMPENV->ENVHOR
                                   ZZA->ZZA_PESPES := TMPENV->ENVSOL
                                   ZZA->ZZA_PESCOL := TMPENV->ENVSOL
                                   ZZA->ZZA_TPENVA := '1'
                                   ZZA->ZZA_SEQENV := TMPENV->ENVSEQ
                                MsUnLock()
                             Endif
                      ElseIf Alltrim(TMPENV->ENVBAI) $ 'EXCLUIDA' //Gravar como Status 9 para ser excluida
                             DbSelectArea("ZZA")
                             DbSetOrder(2)
                             DbSeek(xFilial("ZZA")+TMPENV->ENVORD, .t.)
                             If Found()
                                While !Eof() .and. Alltrim(ZZA->ZZA_ORDEM) == Alltrim(TMPENV->ENVORD)
                                      If ZZA->ZZA_SEQENV == TMPENV->ENVSEQ
                                         RecLock("ZZA", .f.)
                                            ZZA->ZZA_FLAG   := '9'
                                            ZZA->ZZA_HELP   := SubStr(ZZA->ZZA_HELP, 1, 1)+' - Ordem de Produção Excluida'
                                            ZZA->ZZA_DTFIM  := dDataBase
                                            ZZA->ZZA_HFIM   := SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)
                                            ZZA->ZZA_TPENVA := 'E'
                                            ZZA->ZZA_RAMPA  := 'S'
                                         MsUnLock()
                                      Endif
                                      DbSelectArea("ZZA")
                                      DbSkip()
                                Enddo
                             Endif
                      Endif
                   Else
                      //MsgStop(cMsgDtH)
                      Messagebox(cMsgDtH,"Atenção...",48) 
                      cMsgDtH := ""
                   Endif
                Endif
                DbSelectArea("TMPENV")
                DbSkip()
          EndDo
          
          cQry := ""
          cQry := "SELECT ZZS_PERCEN FROM ZZS"+cParInf1+"0 WHERE ZZS_FILIAL ='"+XFilial("ZZS")+"' AND ZZS_QTMIN <= "+cValToChar(nVolTotPI)+" AND ZZS_QTMAX >="+cValToChar(nVolTotPI)+" AND ZZS_OCORRE ='S' AND  D_E_L_E_T_='' "
          TCQuery cQry ALIAS "TCQ" NEW
          DbSelectArea("TCQ")
          DbgoTop()
          If !Eof() .and. (((nVolTotPI / (nVolFalt * -1)) -1) * 100) >= TCQ->ZZS_PERCEN          	
	          cQry1 := ""
   		      cQry1 += "UPDATE ZZA010 SET ZZA_GEROCO='1' WHERE ZZA_LOTE ='"+Alltrim(cNumLot)+"' AND SUBSTRING(ZZA_PRODUT,11,2) IN('00','99') AND D_E_L_E_T_='' AND ZZA_FILIAL ='"+XFilial("ZZA")+"'"
       		  XXX := TCSQLExec(cQry1)
	          If XXX <> 0
   		         cNomArq := 'C:\TEMP\ERR'+DTOS(MsDate())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+'.ERR'
        	     MemoWrit(cNomArq, cQry1)
			  Endif	          
    	  Endif
    	  DbSelectArea("TCQ")
          DbCloseArea() 
  
          /*
          If Len(aImpEtq) > 0
             //Gerar Etiquetas com Código de Barras para TOTAL/PARCIAL
             For nY := 1 To Len(aImpEtq)
                 fGeraEtiqu(nY, aImpEtq)
             Next
          Endif
          */ // RETIRADO MONTAGEM DE PALLET DURANTE O APONTAMENTO, SOMENTE FEITO NA RAMPA ANDRE 04-08-2015
          AtualizSD4()        //Tiago Lucio/Chaus 17/04/2014
          
          DbSelectArea("TMPFUN")
          DbCloseArea()
          //oTempTab04:Delete()
          DbSelectArea("TMPENV")
          DbCloseArea()
          //oTempTab02:Delete()
          oDlg1Env:End()
       Endif
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fSPesApu()
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fSPesApu()

       DbSelectArea("TMPFUN")
       DbCloseArea()
       oTempTab04:Delete()
       oDlg1Env:End()
Return


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fSairEnv()
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fSairEnv()
       DbSelectArea("TMPENV")
       DbCloseArea()
       If ValType( oTempTab02 ) == 'O'
          oTempTab02:Delete()
       Endif
       DbSelectArea("TMPFUN")
       DbCloseArea()
       If ValType( oTempTab04 ) == 'O'
          oTempTab04:Delete()
       Endif
       oDlg1Env:End()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fManuEnv(nOpc)
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fManuEnv(nOpc)
    Local nY, nX
    Local nQtdAju 		:= 0
    Local nPesEsp 		:= 0
    Local lSoAtualiza 	:= .f. 
	Local cTxtMsg       := ""
	Private _aIteAju 	:= {}
	Private _aCabMov 	:= {}
	Private _aAuxMov    := {}
	Private _aAuto 		:= {}
	Private _aItem 		:= {}

	nVolTotPI 	  		:= 0
	nVolFalt  	  		:= 0
       If nOpc == 1 //Complemento ou inicio de produção
          If SubStr(TMPENV->ENVBOT, 3, 1) $ '2' //Inicio de Produção
             //Adiciona envasador
             lAddNew := .t.
             DbSelectArea("TMPFUN")
             DbGoTop()
             While !Eof()
                   If !Empty(TMPFUN->FUNFMA)
                      DbSelectArea("ZZG")
                      DbSetOrder(2)
                      DbSeek(xFilial("ZZG")+TMPENV->ENVLOT, .t.)
                      If Found()
                         While !Eof() .and. ZZG->ZZG_LOTE == TMPENV->ENVLOT
                               If Alltrim(ZZG->ZZG_PROENV)+ZZG->ZZG_SEQENV == Alltrim(TMPFUN->FUNPRO)+TMPFUN->FUNSEQ
                                  If ZZG->ZZG_TPUSER $ 'E'
                                     lAddNew := .f.
                                  Endif
                               Endif
                               DbSelectArea("ZZG")
                               DbSkip()
                         Enddo
                      Endif
                      If lAddNew
                         RecLock("ZZG", .t.)
                            ZZG->ZZG_FILIAL := xFilial("ZZG")
                            ZZG->ZZG_ORDEM  := cNumOrd
                            ZZG->ZZG_LOTE   := cNumLot
                            ZZG->ZZG_PROENV := TMPENV->ENVCOD
                            ZZG->ZZG_SEQENV := TMPENV->ENVSEQ
                            ZZG->ZZG_TPUSER := "E"
                            ZZG->ZZG_FILMAT := TMPFUN->FUNFMA
                            ZZG->ZZG_NOME   := TMPFUN->FUNNOM
                         MsUnLock()
                      Endif
                   Else
                      Messagebox("Atenção, o envasador não foi apontado!","Atenção...",48) 
                      Return
                   Endif
                   DbSelectArea("TMPFUN")
                   DbSkip()
             EndDo
             DbSelectArea("TMPFUN")
             DbGoTop()
             //Adiciona ZZA
             DbSelectArea("ZZA")
             RecLock("ZZA", .t.)
                ZZA->ZZA_FILIAL := xFilial("ZZA") //FILIAL
                ZZA->ZZA_ORDEM  := TMPENV->ENVORD //ORDEM DE PRODUÇÃO
                ZZA->ZZA_LOTE   := TMPENV->ENVLOT //LOTE
                ZZA->ZZA_PRODUT := TMPENV->ENVCOD //CODIGO DO PRODUTO
                ZZA->ZZA_FLAG   := '6'            //INICIO DE ENVASE
                ZZA->ZZA_DTINI  := TMPENV->ENVDAT //DATA DE INICIO
                ZZA->ZZA_HINI   := TMPENV->ENVHOR //HORA DE INICIO
                ZZA->ZZA_PESPES := TMPENV->ENVSOL //
                ZZA->ZZA_PESCOL := TMPENV->ENVSOL //
                ZZA->ZZA_TPENVA := '1'            //1-PENDENTE; P=PARCIAL; T=TOTAL
                ZZA->ZZA_SEQENV := TMPENV->ENVSEQ //SEQUENCIA DE ENVASE PARA ENVASE PARCIAL
                ZZA->ZZA_HELP   := cParInf5+" - 6 - Inicio de Envase"
             MsUnLock()
             //Ajusta botões de tela
             RecLock("TMPENV", .f.)
                TMPENV->ENVBOT := "2101100"
                TMPENV->ENVBAI := "INICIADA"
             MsUnLock()
             //3º Botão - Complemento Iniciar
             oBtn3Env:lVisible := .f.
             oBtn3Env:Refresh()
             //4º Botão - Apontar
             oBtn4Env:lVisible := .t.
             oBtn4Env:Refresh()
             //5º Botão - Excluir
             oBtn5Env:lVisible := .t.
             oBtn5Env:Refresh()
          Else //Complemento
             Private nGet1Com   := 0
             Private nCbx1Com  
             Private aCbx1Com   := {}
             nOpcEmb := 0
             SetPrvt("oFont1Co", "oFont2Co", "oDlg1Com", "oGrp1Com", "oGrp2Com", "oCbx1Com", "oGrp3Com", "oGet1Com", "oBtn1Com")
             
             cQry1 := ""
             cQry1 += "SELECT SUBSTRING(SB1.B1_COD, 11, 2)+' - '+SZ5.Z5_DESCR AS EMB "
             cQry1 += "FROM SB1"+cParInf1+"0 SB1 WITH (NOLOCK) "
             cQry1 += "LEFT OUTER JOIN SZ5"+cParInf1+"0 SZ5 WITH (NOLOCK) ON SZ5.Z5_FILIAL = '"+xFilial("SZ5")+"' AND SZ5.Z5_EMB = SUBSTRING(SB1.B1_COD, 11, 2)  AND SZ5.D_E_L_E_T_ = '' "
             cQry1 += "WHERE SB1.B1_FILIAL = '"+cParInf2+"' "
             cQry1 += "  AND SB1.D_E_L_E_T_ = '' "
             cQry1 += "  AND SUBSTRING(SB1.B1_COD, 1, 10) = '"+SubStr(cCodPro, 1, 10)+"' "
             cQry1 += "  AND SUBSTRING(SB1.B1_COD, 11, 2) NOT IN('00','99') "
             cQry1 += "  AND SB1.B1_MSBLQL <> '1' "
             TCQuery cQry1 ALIAS "TMPEMB" NEW
             DbSelectArea("TMPEMB")
             While !Eof()
                   aAdd(aCbx1Com, TMPEMB->EMB )
                   DbSelectArea("TMPEMB")
                   DbSkip()
             EndDo
             DbSelectArea("TMPEMB")
             DbCloseArea()
             /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
             ±± Definicao do Dialog e todos os seus componentes.                        ±±
             Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
             oFont1Co   := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
             oFont2Co   := TFont():New( "MS Sans Serif", 0, -13, , .T., 0, , 700, .F., .F., , , , , , )
             oDlg1Com   := MSDialog():New( 091, 232, 220, 670, "Complemento de Envase", , , .F., , , , , , .T., , , .T. )
             oGrp1Com   := TGroup():New( 004, 004, 047, 216, "Complemento", oDlg1Com, CLR_BLACK, CLR_WHITE, .T., .F. )
             oGrp2Com   := TGroup():New( 013, 008, 038, 116,"Selecione a Embalagem:",oGrp1Com,CLR_BLUE,CLR_WHITE,.T.,.F. )
             oCbx1Com   := TComboBox():New( 022, 012, {|u| If(PCount() > 0, nCbx1Com := u, nCbx1Com)}, aCbx1Com, 100, 016, oGrp2Com, , , , CLR_BLACK, CLR_WHITE, .T., oFont1Co, "", , , , , , , nCbx1Com )
             oGrp3Com   := TGroup():New( 013, 120, 038, 212, "Quantidade:", oGrp1Com, CLR_BLUE, CLR_WHITE, .T., .F. )
             oGet1Com   := TGet():New( 020, 125, {|u| If(PCount() > 0, nGet1Com := u, nGet1Com)}, oGrp3Com, 083, 012, '', , CLR_BLACK, CLR_WHITE, oFont1Co, , , .T., "", , , .F., .F., , .F., .F., "", "nGet1Com", ,)
             oBtn1Com   := TButton():New( 052, 179, "Sair"    , oDlg1Com, { || nOpcEmb := 0, oDlg1Com:End() }, 037, 012, , oFont2Co, , .T., , "", , , , .F. )
             oBtn2Com   := TButton():New( 052, 132, "Confirma", oDlg1Com, { || nOpcEmb := 1, oDlg1Com:End() }, 037, 012, , oFont2Co, , .T., , "", , , , .F. )
             oGet1Com:bGotFocus := { || nGet1Com := fAjuQtd(nGet1Com, "EN"), oGet1Com:Refresh() }
             oDlg1Com:Activate(, , , .T.)
             If nOpcEmb == 1
                If nGet1Com > 0
                   //Montar SigaAuto para o Complemento
                   cCodCom := SubStr(TMPENV->ENVCOD, 1, 10)+SubStr(nCbx1Com, 1, 2)+Space(3)
                   lMsErroAuto := .f.
                   aAutoSC2 := {}
                   aAdd(aAutoSC2, {"C2_ITEM"   , "01"                     									      , NIL})
                   aAdd(aAutoSC2, {"C2_SEQUEN" , "001"        									                  , NIL})
                   aAdd(aAutoSC2, {"C2_PRODUTO", cCodCom           										          , NIL})
                   aAdd(aAutoSC2, {"AUTEXPLODE", 'S'        								                      , NIL})
                   aAdd(aAutoSC2, {"C2_LOCAL"  , Posicione("SB1", 1, xFilial("SB1")+Alltrim(cCodCom), "B1_LOCPAD"), NIL}) //Iif(cParInf5 $ '1', '03', '30') // PEGAR O LOCAL PADRÃO PARA HABILITAR ALMOXARIFADOS P1 E P2
                   aAdd(aAutoSC2, {"C2_QUANT"  , nGet1Com               								          , NIL})
                   aAdd(aAutoSC2, {"C2_UM"     , 'UN'                           								  , NIL})
                   aAdd(aAutoSC2, {"C2_DATPRI" , TMPENV->ENVDAT                									  , NIL})
                   aAdd(aAutoSC2, {"C2_DATPRF" , MSDate()                      									  , NIL})
                   aAdd(aAutoSC2, {"C2_EMISSAO", MSDate()                								          , NIL})
                   aAdd(aAutoSC2, {"C2_TPOP"   , 'F'                           									  , NIL})
                   aAdd(aAutoSC2, {"C2_LOTE"   , TMPENV->ENVLOT                									  , NIL})
                   aAdd(aAutoSC2, {"C2_PRIOR"  , '500'              								              , NIL})
                   aAdd(aAutoSC2, {"C2_ROTEIRO", '01'                   								          , NIL})

                   DbSelectArea("SC2")
                   MSExecAuto( {|x| MATA650(x)}, aAutoSC2)
                   If lMsErroAuto
                      cStrErr := MemoLine( MemoRead( NomeAutoLog() ), 30, 1)
                      If "Erro no Gatilho : C2_PRODUTO" $ cStrErr
                         lMsErroAuto := .f.
                      Endif
                   Endif
                   If !lMsErroAuto
                      //Adicionar na tabela ZZA
                      cQry1 := "SELECT ISNULL(MAX(ZZA.ZZA_SEQENV), '0') AS ZZA_SEQENV FROM ZZA"+cParInf1+"0 ZZA WHERE ZZA.ZZA_FILIAL = '"+cParInf2+"' AND ZZA.ZZA_LOTE = '"+SC2->C2_LOTE+"' AND ZZA.D_E_L_E_T_ = '' AND ZZA.ZZA_PRODUT = '"+SC2->C2_PRODUTO+"' "
                      TCQuery cQry1 ALIAS "TMPSEQ" NEW
                      DbSelectArea("TMPSEQ")
                      cSeqEnv := StrZero(Val(TMPSEQ->ZZA_SEQENV) + 1, 2)
                      DbSelectArea("TMPSEQ")
                      DbCloseArea()
                      DbSelectArea("ZZA")
                      RecLock("ZZA", .t.)
                         ZZA->ZZA_FILIAL := xFilial("ZZA")
                         ZZA->ZZA_ORDEM  := SC2->C2_OP
                         ZZA->ZZA_LOTE   := SC2->C2_LOTE
                         ZZA->ZZA_PRODUT := SC2->C2_PRODUTO
                         ZZA->ZZA_HELP   := cParInf5+" - Ordem de produção complementar"
                         ZZA->ZZA_FLAG   := '8'
                         ZZA->ZZA_QUANT  := SC2->C2_QUANT
                         ZZA->ZZA_DTINI  := SC2->C2_DATPRI
                         ZZA->ZZA_HINI   := TMPENV->ENVHOR
                         ZZA->ZZA_DTFIM  := MsDate()
                         ZZA->ZZA_HFIM   := Substr(Time(), 1, 2)+Substr(Time(), 4, 2)
                         ZZA->ZZA_SEQENV := cSeqEnv
                         ZZA->ZZA_RAMPA  := "S"
                         ZZA->ZZA_TPENVA := "C"
                      MsUnLock()
                      //Adicionar na tabela TMPENV
                      RecLock("TMPENV", .t.)
                         TMPENV->ENVCOD := SC2->C2_PRODUTO
                         TMPENV->ENVSOL := 0
                         TMPENV->ENVPRO := SC2->C2_QUANT
                         TMPENV->ENVBAI := 'APONTAMENTO TOTAL'
                         TMPENV->ENVORI := 'C'
                         TMPENV->ENVORD := SC2->C2_OP
                         TMPENV->ENVLOT := SC2->C2_LOTE
                         TMPENV->ENVSEQ := cSeqEnv
                         TMPENV->ENVDAT := SC2->C2_DATPRI
                         TMPENV->ENVHOR := ZZA->ZZA_HFIM
                       	 TMPENV->ENVVOL := Posicione("SB1", 1, xFilial("SB1")+TMPENV->ENVCOD, "B1_CONV")
                         TMPENV->ENVREC := 0
                         TMPENV->ENVBOT := '2110000'
                      MsUnLock()
                      //Adicionar envasadores
                      cQry1 := "SELECT ZZG.ZZG_FILMAT, ZZG.ZZG_NOME FROM ZZG"+cParInf1+"0 ZZG WHERE ZZG.ZZG_FILIAL = '"+cParInf2+"' AND ZZG_LOTE = '"+SC2->C2_LOTE+"' GROUP BY ZZG.ZZG_FILMAT, ZZG.ZZG_NOME "
                      TCQuery cQry1 ALIAS "TMPZZG" NEW
                      DbSelectArea("TMPZZG")
                      DbgoTop()
                      While !Eof()
                            DbSelectArea("ZZG")
                            RecLock("ZZG", .t.)
                               ZZG->ZZG_FILIAL := xFilial("ZZG")
                               ZZG->ZZG_ORDEM  := cNumOrd
                               ZZG->ZZG_LOTE   := SC2->C2_LOTE
                               ZZG->ZZG_PROENV := SC2->C2_PRODUTO
                               ZZG->ZZG_SEQENV := cSeqEnv
                               ZZG->ZZG_TPUSER := "E"
                               ZZG->ZZG_FILMAT := TMPZZG->ZZG_FILMAT
                               ZZG->ZZG_NOME   := TMPZZG->ZZG_NOME
                            MsUnLock()
                            DbSelectArea("TMPZZG")
                            DbSkip()
                      EndDo
                      DbSelectArea("TMPZZG")
                      DbCloseArea()
                   Endif
                Endif
             Endif
          Endif
       ElseIf nOpc == 2 //Aponta Ordem de Produção
              If SubStr(TMPENV->ENVBAI, 1, 2) $ 'AP.EX.EN'
                 Messagebox("Atenção, essa OP. não pode ser apontada.","Atenção...",48) 
                 Return
              Endif
              nQtdAju := TMPENV->ENVPRO
              nQtdAju := fAjuQtd(nQtdAju, "EN")
              If nQtdAju == 0
                 Return
              Endif
              If Round( ( ( nQtdAju / TMPENV->ENVSOL ) - 1 ) * 100, 2) >= 30
                 If MsgYesNo("ATENÇÃO, quantidade apontada muito maior que a solicitada. CONFIRMA?")
                    RecLock("TMPENV", .f.)
                       TMPENV->ENVPRO := nQtdAju
                       TMPENV->ENVBAI := "TOTAL"
                       TMPENV->ENVBOT := "2100000"
                       oBtn4Env:lVisible := .f.
                       oBtn5Env:lVisible := .f.
                    MsUnLock()
                 Endif
              ElseIf nQtdAju >= TMPENV->ENVSOL
                     RecLock("TMPENV", .f.)
                        TMPENV->ENVPRO := nQtdAju
                        TMPENV->ENVBAI := "TOTAL"
                        TMPENV->ENVBOT := "2100000"
                        oBtn4Env:lVisible := .f.
                        oBtn5Env:lVisible := .f.
                     MsUnLock()
              Else
                 //Cria Array com a tabela do envase
                 DbSelectArea("TMPENV")
                 aParOrd := {}
                 For nY := 1 TO FCount()
                     aAdd(aParOrd, FieldGet(nY))
                 Next
                 //Cria Array com a tabela do envasador
                 DbSelectArea("TMPFUN")
                 aParFun := {}
                 DbGoTop()
                 While !Eof()
                       aAdd( aParFun, Array( FCount() ) )
                       For nY := 1 TO FCount()
                           aParFun[Len(aParFun)][nY] := FieldGet(nY)
                       Next
                       DbSelectArea("TMPFUN")
                       DbSkip()
                 Enddo
                 //Ajusta Envase Apontado
                 RecLock("TMPENV", .f.)
                    TMPENV->ENVPRO := nQtdAju
                    TMPENV->ENVBAI := "PARCIAL"
                    TMPENV->ENVBOT := "2100000"
                    oBtn4Env:lVisible := .f.
                    oBtn5Env:lVisible := .f.
                 MsUnLock()
                 nRecEnv := RecNo() //Variável para posicionar no final da saida do apontamento
                 //Inclui uma nova linha com a diferença
                 RecLock("TMPENV", .t.)
                    For nY := 1 To FCount()
                        If "ENVSOL" $ Field(nY)
                           FieldPut(nY, aParOrd[nY] - nQtdAju)
                        ElseIf "ENVSEQ" $ Field(nY)
                               FieldPut(nY, StrZero( ( Val( aParOrd[nY] ) + 1 ), 2 ) )
                        Else
                           FieldPut(nY, aParOrd[nY])
                        Endif
                    Next
                 MsUnLock()
                 //Inclui uma nova Linha com o Envasador
                 DbSelectArea("TMPFUN")
                 For nY := 1 To Len(aParFun)
                     RecLock("TMPFUN", .t.)
                        For nX := 1 To FCount()
                            If "FUNSEQ" $ Field(nX)
                               FieldPut(nX, StrZero( ( Val( aParFun[nY][nX] ) + 1 ), 2 ) )
                            ElseIf "FUNVIS" $ Field(nX)
                                   FieldPut(nX, "N")
                            Else
                               FieldPut(nX, aParFun[nY][nX] )
                            Endif
                        Next
                     MsUnLock()
                 Next
                 DbSelectArea("TMPENV")
                 DbGoTop()
                 oBrw1Env:oBrowse:Refresh()
                 DbGoTo(nRecEnv)
              Endif
       ElseIf nOpc == 3 //Exclui Ordem de Produção
              If SubStr(TMPENV->ENVBAI, 1, 2) $ 'AP.EX.PA.EN' //AP=Apontada; EX=Excluida; PA=Parcial; EN=Encerrada
                 Messagebox("Atenção, essa OP. não pode ser excluida.","Atenção...",48) 
                 Return
              Endif
              If 'Encerra' $ oBtn5Env:cCaption //Encerra Ordem de Produção
                 cQry1 := ""
                 cQry1 += "UPDATE ZZA010 SET ZZA_FLAG = 'E', ZZA_RAMPA = 'S', ZZA_HELP = SUBSTRING(ZZA_HELP, 1, 1)+' - Encerrada.', ZZA_DTFIM = '"+DTOS(MSDATE())+"', ZZA_HFIM = '"+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+"' WHERE R_E_C_N_O_ = "+Str(TMPENV->ENVREC, 10)
                 XXX := TCSQLExec(cQry1)
                 If XXX <> 0
                    cNomArq := 'C:\TEMP\ERR'+DTOS(MsDate())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+'.ERR'
                    MemoWrit(cNomArq, cQry1)
                 Endif
                 RecLock("TMPENV", .f.)
                    TMPENV->ENVBAI := "ENCERRADA"
                    TMPENV->ENVBOT := "2100000"
                 MsUnLock()
              Else
                 //Verifica se não existem outros apontamentos para a ordem de produção.
                 aExcOrd := {}
                 DbSelectArea("ZZA")
                 DbSetOrder(2)
                 DbSeek(xFilial("ZZA")+TMPENV->ENVORD, .t.)
                 If Found()
                    While !Eof() .and. Alltrim(ZZA->ZZA_ORDEM) == Alltrim(TMPENV->ENVORD)
                          aAdd(aExcOrd, {ZZA->ZZA_SEQENV, ZZA->ZZA_FLAG} )
                          DbSelectArea("ZZA")
                          DbSkip()
                    EndDo
                    If Len(aExcOrd) == 1
                       If !aExcOrd[1][2] $ '7.8.9'
                          //Verifica se a Ordem de produção foi apontada na mesma tela.
                          DbSelectArea("TMPENV")
                          nRecEnv  := RecNo()
                          cCompCod := TMPENV->ENVORD
                          aVolEnv := {}
                          DbGoTop()
                          While !Eof()
                          	  If TMPENV->ENVORD $ cCompCod .and. TMPENV->(RecNo()) <> nRecEnv
                                  If SubStr(TMPENV->ENVBAI, 1, 2) $ 'PA'
                                      aAdd(aVolEnv, TMPENV->(RecNo()) )
                                  ElseIf SubStr(TMPENV->ENVBAI, 1, 2) $ 'TO'
                                      aAdd(aVolEnv, TMPENV->(RecNo()) )
                                  Endif
                              Endif
                              DbSelectArea("TMPENV")
                              DbSkip()
                          EndDo
                          If Len(aVolEnv) == 0
                             DbSelectArea("TMPENV")
                             DbGoTo(nRecEnv)
                             RecLock("TMPENV", .f.)
                                TMPENV->ENVBAI := "EXCLUIDA"
                             MsUnLock()
                          ElseIf Len(aVolEnv) >= 1
                             DbSelectArea("TMPENV")
                             DbGoTo(aVolEnv[Len(aVolEnv)])
                             RecLock("TMPENV", .f.)
                                TMPENV->ENVPRO := 0
                                TMPENV->ENVBAI := "INICIADA"
                                TMPENV->ENVBOT := "2101100"
                             MsUnLock()
                             DbSelectArea("TMPENV")
                             DbGoTo(nRecEnv)
                             RecLock("TMPENV", .f.)
                                DbDelete()
                             MsUnLock()   
                          Endif
                       Else
                          If aExcOrd[1][2] $ '7'
                             Messagebox("Ordem de produção já foi apontada parcialmente.","Atenção...",48) 
                          ElseIf aExcOrd[1][2] $ '8'
                                 Messagebox("Ordem de produção já foi apontada totalmente.", "Verifique!",48) 
                          ElseIf aExcOrd[1][2] $ '9'
                                 Messagebox("Ordem de produção já foi excluida", "Verifique!",48) 
                          Endif
                       Endif
                    Else
                       Messagebox("Atenção, essa Ordem de produção possui mais de 1 apontamento, portanto não pode ser excluida", "Verifique!",48) 
                    Endif
                 Endif
              Endif
              DbSelectArea("TMPENV")
              DbGoTop()
       ElseIf nOpc == 4 // Apontamento de Sobra 
              
	       If !Alltrim(Posicione("ZZA", 2, xFilial("ZZA")+Alltrim(cGet1Env), "ZZA_FLAG")) $ '5'
        	   Messagebox("Atenção, a ordem de produção do PI ainda não foi baixada, aguarde até que isso aconteça para apontar a sobra!!","Atenção...",48) 
               Return
		   Endif	
           If Alltrim(Posicione("ZZA", 2, xFilial("ZZA")+Alltrim(cGet1Env), "ZZA_SP")) $ 'S.1.A.6'
               Messagebox("Atenção, apontamento de sobra já apontado !!","Atenção...",48) 
               Return
		   Endif				  
		   If !SubStr(TMPENV->ENVBAI, 1, 2) $ 'AP.PA.BA.EN' //APONTADA / BAIXADA / PARCIAL / ENCERRADA 
               Messagebox("Atenção, a sobra de PI não pode ser apontada antes da Op ser apontada  !! ","Atenção...",48) 
               Return
           Endif

           nQtdAju   := fQtdAju(nQtdAju, "01")  // QUANTIDADE DIGITADA EM KG
           nVolSobra := nQtdAju 
           nVolDigit := nQtdAju 
           
           If MsgYesNo("Confirma o valor da sobra apontado com "+cValtoChar(Round((nVolDigit),3))+" KG ?", "Apontamento de Sobra")	  

		     nQtdVol   := FVolProdAc() // DIFERENÇA ENTRE O TOTAL DE SALDO GERADO ZZA_QUANT E O TOTAL ENVASADO CONVERTIDO PELO B1_CONV
			 cLocOri   := Iif(cParInf5 $ '1', '02', '20' )
     	                    
             cQry1 := " SELECT B2_COD,B2_LOCAL, B2_QATU, B1_DESC, B1_UM, SB2.R_E_C_N_O_ FROM SB2"+cParInf1+"0 SB2 WITH (NOLOCK) "
             cQry1 += " LEFT OUTER JOIN SB1"+cParInf1+"0 SB1 WITH (NOLOCK) ON B1_FILIAL = B2_FILIAL AND B1_COD = B2_COD AND SB1.D_E_L_E_T_ ='' "
			 cQry1 += " WHERE SB2.D_E_L_E_T_ ='' "
			 cQry1 += " AND B2_COD    ='"+Alltrim(cCodPro)+"'"
			 cQry1 += " AND B2_LOCAL  ='"+cLocOri+"'" 
			 cQry1 += " AND B2_FILIAL ='"+XFilial("SB2")+"'"

             TCQuery cQry1 ALIAS "TMPSB2" NEW
             DbSelectArea("TMPSB2")
             DbgoTop()					

			 cUndMed   := TMPSB2->B1_UM //Posicione("SB1", 1, xFilial("SB1")+Alltrim(cCodPro), "B1_UM") 
			 cDescPro  := TMPSB2->B1_DESC //Posicione("SB1", 1, xFilial("SB1")+Alltrim(cCodPro), "B1_DESC")
             nQtdAtu   := TMPSB2->B2_QATU
             nReg      := TMPSB2->R_E_C_N_O_
             
			 /*
			 nVolTotPI := Iif(nVolSC2 > 0, nVolSC2, nVolZZA)
			 nVolTotPA := FVolTotPa()
			 nVolPerda := Iif(nVolTotPI - (nVolTotPA + nVolSobra) <0, 0 , nVolTotPI - (nVolTotPA + nVolSobra)) 
             */
              //cNextDoc  := 'SOB'+Alltrim(cGet2Env)//NextNumero("SD3",2,"D3_DOC",.T.)
             DbSelectArea("TMPSB2")
             DbCloseArea()

			 _aIteAju  := {}
			 _aCabMov  := {}
			 _aAuxMov  := {}


			 //PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010101" MODULO "PCP" TABLES "SD3","SB1","SD4","SB2","SB9","ZZF","SX2","SX3","ZZA"
		     Begin Transaction
      	        //DbSelectArea("SD3")
				//DbSetOrder(4) //(D3_FILIAL+D3_NUMSEQ+D3_CHAVE+D3_COD)                                                                                                                             
				//DBGoBottom()         
				
                DbSelectArea("SX6")
                dbsetorder(1)
                dbgotop()
			    //CNumSeq := GETMV("MV_DOCSEQ")
			    //Messagebox(CNumSeq,"Atenção...",64)                
			    If nQtdAju > (nQtdVol)           // QUANTIDADE DIGITADA EM KG > DIFERENÇA DO VOLUME GERADO - O VOL ENVASADO 
   					nQtdAju  := Iif(nQtdVol <0, Abs(nQtdVol)+nQtdAju ,nQtdAju-Abs(nQtdVol)) 		          	
			        _aCabMov := {{"D3_TM"      , '109'      							    , NIL},;
    	       	      			{"D3_EMISSAO"  , dDatabase   						  	    , NIL} }

			    	_aAuxMov := {{"D3_COD"    , Alltrim(cCodPro)     	        		    , NIL},;
				        		{"D3_QUANT"   , Abs(nQtdAju)   							   	, NIL},;
       							{"D3_UM"      , cUndMed									   	, NIL},;
			        	       	{"D3_LOCAL"   , cLocOri										, NIL},; 
				               	{"D3_OBS"     , Alltrim(cNumOrd)					      	, NIL},; 
		               	        {"D3_DOC"     , NextNumero("SD3",2,"D3_DOC",.T.)  	        , NIL} } 
        						//{"D3_NUMSEQ"  , PROXNUM()                                   , NIL},;
				    aAdd(_aIteAju, _aAuxMov)
		
					If U_EstaBloqueado('SB2',nReg)
						Messagebox("Registro estava Bloqueado !! "+nReg,"Atenção...",64)    	
		                DbSelectArea("SB2")
	                    MsUnLock()
					Endif

					lMsErroAuto := .f.
					MSExecAuto({|x, y, z| MATA241(x, y, z)}, _aCabMov, _aIteAju, 3)
	
					//Colocar um campo de controle no ZZA pra marcar o.ps que já tiveram saldo ajustado				
					If lMsErroAuto
						DisarmTransaction() 
  					    Mostraerro()
						//Return()  //LGS#20200204 - Adequação de release 12.1.25 e posteriores - retirado return pois não pode ser executado dentro de um loop 
					EndIf
	            Elseif nQtdAju <= Abs(nQtdVol) // QUANTIDADE DIGITADA EM KG < DIFERENÇA DO VOLUME GERADO - O VOL ENVASADO 
		       		nQtdAju :=  Iif(nQtdAju = Abs(nQtdVol), nQtdAju, (Abs(nQtdVol)-nQtdAju))
					
					//DbSelectArea("SB2")
					//DbSetorder(1)
					//If SB2->(DBSEEK(xFilial("SB2")+(cCodPro)+cLocOri))
			       		//If (SB2->B2_QATU < ABS(nQtdAju)) .and. (SB2->B2_QATU >0)
						If (nQtdAtu < ABS(nQtdAju)) .and. (nQtdAtu >0)
							nQtdAju := nQtdAtu
						ElseIf nQtdAtu = 0 .or. nQtdAju =0 // se não existir saldo no b2 ou se a quantidade apontada de sobra for igual a zero
		                    lSoAtualiza := .t.
				  		Endif
	       			//Endif
	       		    //DbSelectArea("SB2")
	       		    //DbCloseArea()
	       		    
	       			_aCabMov := {{"D3_TM"    , '599'        						 , NIL},;
		    	    	        {"D3_EMISSAO", dDatabase    						 , NIL} }
   	
		    	    _aAuxMov := {{"D3_COD"    , Alltrim(cCodPro)    				 , NIL},;
   					    	    {"D3_QUANT"   , Abs(nQtdAju)						 , NIL},;
   						  	    {"D3_UM"      , cUndMed								 , NIL},;
	           	    	        {"D3_LOCAL"   , cLocOri								 , NIL},; 
       		   	   	    	    {"D3_OBS"     , Alltrim(cNumOrd)                     , NIL},; 
		               	        {"D3_DOC"     , NextNumero("SD3",2,"D3_DOC",.T.)  	 , NIL} } 

								//	{"D3_NUMSEQ"  , PROXNUM()                            , NIL},;	
		      	    aAdd(_aIteAju, _aAuxMov)                                                                           
	
				    lMsErroAuto := .f.

	       		    If !lSoAtualiza				  
						If U_EstaBloqueado('SB2',nReg)
							Messagebox("Registro Bloqueado !! "+nReg,"Atenção...",64)    	
			                DbSelectArea("SB2")
	        	            MsUnLock()
						Endif
   						PutMv("MV_ESTNEG" , "S")  
				        //MSExecAuto({|x, y, z| MATA241(x, y, z)}, _aCabMov, _aIteAju, 3)
	                Endif
					  //Colocar um campo de controle no ZZA pra marcar o.ps que já tiveram saldo ajustado				
				    If !lMsErroAuto
   						PutMv("MV_ESTNEG" , "N")  
				  	Else
						PutMv("MV_ESTNEG" , "N")  
   	    				DisarmTransaction() 
                      	cStrErr := MemoLine( MemoRead( NomeAutoLog() ), 30, 1)
                      	If "MA240NEGAT" $ cStrErr
		                	Messagebox("Não existe saldo suficiente para exclusão !!","Atenção...",64)    	
                      	Else
							Mostraerro()
					  	Endif 
				  	Endif
			  	Endif	

                // Gravar no ZZA que precisa fazer a transferência de um produto pro outro.

				nVolTotPI := Iif(nVolSC2 > 0, nVolSC2, nVolZZA)
				nVolTotPA := FVolTotPa()
				nVolPerda := Iif(nVolTotPI - (nVolTotPA + nVolSobra) <0, 0 , nVolTotPI - (nVolTotPA + nVolSobra)) 
				
				nSobra := nVolSobra
				nPerda := nVolPerda
                	
	            nPesEsp := Posicione("ZZA", 2, xFilial("ZZA")+SubStr(cNumOrd, 1, 11), "ZZA_PESLAB") 
	     	    nPesEsp := Iif(nPesEsp =0, Posicione("SB1", 1, xFilial("SB1")+Alltrim(cCodPro), "B1_PESOESP") , nPesEsp)

    	                    
        	    If Alltrim(cUndMed) $ 'L' 
				   	nVolSobra := Iif(nVolSobra > 0, Round((nVolSobra / nPesEsp),4), 0 )
		   			nVolPerda := Iif(nVolPerda > 0, Round((nVolPerda / nPesEsp),4), 0 )
		        Endif                 

				cQry1 := "UPDATE  "+RetSqlName("ZZA")+" SET ZZA_SP = '"+Iif(Substr(Alltrim(cCodPro),4,2) $ '97-98-99' .OR. nVolSobra = 0,'S','A')+"', ZZA_SOBRA="+StrTran(TransForm((nVolSobra), '@E 9999.99999'), ",", ".")+", ZZA_PERDA="+StrTran(TransForm((nVolPerda), '@E 9999.99999'), ",", ".")+"  WHERE D_E_L_E_T_ ='' AND ZZA_FILIAL ='"+xFilial("ZZA")+"' AND ZZA_ORDEM = '"+Alltrim(cNumOrd)+"' "
				TCSQLExec(cQry1)		
	
				cQry2 := "UPDATE  "+RetSqlName("SC2")+" SET C2_XSOBRA ="+StrTran(TransForm((nVolDigit), '@E 9999.99999'), ",", ".")+"  WHERE D_E_L_E_T_ ='' AND C2_FILIAL ='"+xFilial("SC2")+"' AND C2_OP = '"+Alltrim(cNumOrd)+"' "
				TCSQLExec(cQry2)		
                
             End Transaction
             //RESET ENVIRONMENT
             
                If (nVolTotPI >0 .and. nVolTotPA >0) .and. ((nSobra >0) .or. (nPerda > 0)) 
                	If (((nSobra / nVolTotPI) * 100) > 2  .OR. ((nPerda / nVolTotPI ) * 100) > 3) 
    	            	cTxtMsg := "O.P "+(cNumOrd)+" com valores de Sobra ou Perda Informados estão fora do range estipulado."+CHR(13)+CHR(10)
						cTxtMsg += "Produto : "+Alltrim(cCodPro)+" - UM :"+cUndMed+CHR(13)+CHR(10)
        	        	If ((nSobra / nVolTotPI) * 100) > 2
            	    		cTxtMsg += "Total da Op: "+Alltrim(TransForm(nVolTotPI, "@E 9999.999"))+" - Qtde da Sobra na Unid. de Medida do PI: "+Alltrim(TransForm(nSobra, "@E 9999.999"))+CHR(13)+CHR(10)
                			cTxtMsg += TransForm(Round(((nSobra / nVolTotPI ) * 100),2),"@E 9999.999")+" %"+CHR(13)+CHR(10)
	                	Endif
	                	If ((nPerda / nVolTotPI ) * 100) > 3
        	        		cTxtMsg += "Total da Op: "+Alltrim(TransForm(nVolTotPI, "@E 9999.999"))+" - Qtde da Perda na Unid. de Medida do PI: "+Alltrim(TransForm(nPerda, "@E 9999.999"))+CHR(13)+CHR(10)
                			cTxtMsg += TransForm(Round(((nPerda / nVolTotPI ) * 100),2),"@E 9999.999")+" %"+CHR(13)+CHR(10)
						Endif
						If Substr(xFilial("ZZA"),1,2)== "06"
   						 	U_EnvMail("DISSOLTEX - O.P "+cNumOrd+" com valores de Sobra ou Perda Informados que estão fora do range estipulado !" ,cTxtMsg,"silene@dissoltex.com.br","") 
	        	    	Else
   						 	U_EnvMail("BRASILUX - O.P "+cNumOrd+" com valores de Sobra ou Perda Informados que estão fora do range estipulado !" ,cTxtMsg,"pcp@brasilux.com.br","")                       	  
						Endif
            	    Endif
				Endif               
             
                DbSelectArea("SX6")
                MsUnlock()
                dbsetorder(1)
                dbgotop()

				// Posicionar no último registro da tabela sd1, sd2 e sd3 pra tentar contornar o erro 
		        // AJUSTAR PARAMETRO MV_DOCSEQ (este parametro é utilizado nas 3 tabelas para alimentar
				// o campo _NUMSEQ
                /* P/ TESTAR
                DbSelecArea("SD1")    
				DbSetOrder(4) //(D1_FILIAL+D1_NUMSEQ)                                                                                                                                             
				DBGoBottom()   

                DbSelecArea("SD2")    
				DbSetOrder(4) //(D2_FILIAL+D1_NUMSEQ)                                                                                                                                             
				DBGoBottom() 
				
                DbSelectArea("SD3")
				DbSetOrder(4) //(D3_FILIAL+D3_NUMSEQ+D3_CHAVE+D3_COD)                                                                                                                             
				DBGoBottom() */

                /*
 	          	If !Substr(Alltrim(cCodPro),4,2) $ '97-98-99' .and. nVolSobra > 0
 	           	// se não for tinta pó, transforma sobra do pi em produto determinado por linha sz1 reaproveitamento
					_aAuto     := {}
					_aItem     := {}
						
					cProduto2 := Iif(Len(AllTrim(cCodPro)) == 12 .and. Alltrim(Posicione("SZ1", 1, xFilial("SZ1")+SubStr(cCodPro,4,2), "Z1_REAPROV")) = "",  '8885           ', Posicione("SZ1", 1, xFilial("SZ1")+SubStr(cCodPro,4,2), "Z1_REAPROV"))
					cLocDest  := Iif(cParInf5 $ '1', '01', '10' )
					cNumDoc   := NextNumero("SD3",2,"D3_DOC",.T.) 

					aadd(_aAuto,{cNumDoc,dDataBase})  	
					aadd(_aItem,cCodPro) 		 												  //D3_COD		
			  	    aadd(_aItem,cDescPro)														  //D3_DESCRI				
					aadd(_aItem,cUndMed)														  //D3_UM		
					aadd(_aItem,cLocOri)														  //D3_LOCAL		
					aadd(_aItem,"")			   													  //D3_LOCALIZ		
					aadd(_aItem,cProduto2) 														  //D3_COD		
				    aadd(_aItem,Posicione("SB1", 1, xFilial("SB1")+Alltrim(cProduto2), "B1_DESC"))//D3_DESCRI
					aadd(_aItem,Posicione("SB1", 1, xFilial("SB1")+Alltrim(cProduto2), "B1_UM"))  //D3_UM		
					aadd(_aItem,Iif(cParInf5 $ '1', '01', '10' ))					              //D3_LOCAL		
					aadd(_aItem,"")				   												  //D3_LOCALIZ		
					aadd(_aItem,cNumOrd)	  													  //D3_NUMSERI		
					aadd(_aItem,criavar("D3_LOTECTL"))											  //D3_LOTECTL  		
					aadd(_aItem,"")         													  //D3_NUMLOTE		
					aadd(_aItem,criavar("D3_DTVALID"))  										  //D3_DTVALID					
					aadd(_aItem,0)																  //D3_POTENCI		
					aadd(_aItem,nVolSobra) 														  //D3_QUANT		
				   	aadd(_aItem,criavar("D3_QTSEGUM"))											  //D3_QTSEGUM
					aadd(_aItem,criavar("D3_ESTORNO"))  										  //D3_ESTORNO
					aadd(_aItem,criavar("D3_NUMSEQ"))   										  //D3_NUMSEQ 
					aadd(_aItem,"")																  //D3_LOTECTL
					aadd(_aItem,criavar("D3_DTVALID"))  										  //D3_DTVALID					
					aadd(_aItem,"")					   											  //D3_ITEMGRD
					aadd(_aItem,criavar("D3_IDDCF"))											  //D3_IDDCF
					aadd(_aItem,criavar("D3_OBSERVA"))											//D3_OBSERVA  
					
                    //criar almxarifado do reaproveitamento caso ainda não exista

	                DbSelectArea("SB2")
                    MsUnLock()

					DbSelectArea("SB2")
					DbSetOrder(1)
					DbGotop()
					If !SB2->(DBSEEK(xFilial("SB2")+cProduto2+cLocDest))
						CriaSB2(cProduto2, cLocDest)
					Endif 

					DbSelectArea("SB2")
					DbSetOrder(1)
					SB2->(DBSEEK(xFilial("SB2")+cCodPro+cLocOri))  

					lMsErroAuto := .f.
					aadd(_aAuto,_aItem)
        	        DbSelectArea("SD3")					

					PutMv("MV_ESTNEG" , "S")       
					If U_EstaBloqueado('SB2',nReg)
						Messagebox("Registro Bloqueado !! "+nReg,"Atenção...",64)    	
		                DbSelectArea("SB2")
	                    MsUnLock()
					Endif
					MSExecAuto({|x,y| mata261(x,y)},_aAuto,3)				
		
					If lMsErroAuto			
						PutMv("MV_ESTNEG" , "N")   
	   	    			//DisarmTransaction() 
   	        			MostraErro()
   	        			//Return()		
					Else
				        nVolTotPI := Iif(nVolSC2 > 0, nVolSC2, nVolZZA)
				        nVolTotPA := FVolTotPa()
				        nVolPerda := Iif(nVolTotPI - (nVolTotPA + nVolSobra) < 0, 0 , nVolTotPI - (nVolTotPA + nVolSobra)) 
                        
                        nPesEsp := Posicione("ZZA", 2, xFilial("ZZA")+SubStr(cNumOrd, 1, 11), "ZZA_PESLAB") 
                        nPesEsp := Iif(nPesEsp =0, Posicione("SB1", 1, xFilial("SB1")+Alltrim(cCodPro), "B1_PESOESP") , nPesEsp)
                        
                        If Alltrim(cUndMed) $ 'L' 
			            	nVolSobra := Iif(nVolSobra > 0, Round((nVolSobra / nPesEsp),4), 0 )
		   					nVolPerda := Iif(nVolPerda > 0, Round((nVolPerda / nPesEsp),4), 0 )
	        			Endif                 
				        
				        cQry1 := "UPDATE  "+RetSqlName("ZZA")+" SET ZZA_SP = 'S', ZZA_SOBRA="+StrTran(TransForm((nVolSobra), '@E 999,999.99999'), ",", ".")+", ZZA_PERDA="+StrTran(TransForm((nVolPerda), '@E 999,999.99999'), ",", ".")+"  WHERE D_E_L_E_T_ ='' AND ZZA_FILIAL ='"+xFilial("ZZA")+"' AND ZZA_ORDEM = '"+Alltrim(cNumOrd)+"' "
					    XXX := TCSQLExec(cQry1)		
					    Messagebox("Apontamento de sobra realizado com Sucesso !!","Atenção...",64) 			
					Endif

				    PutMv("MV_ESTNEG" , "N")  
 	          	Endif */

 	          	RecLock("TMPENV", .f.)
    	      		TMPENV->ENVBOT := "2100000"
                  	oBtn4Env:lVisible := .f.
                  	oBtn5Env:lVisible := .f.
                  	oBtn9Env:lVisible := .f.
              	MsUnLock() 

			    Messagebox("Apontamento de sobra realizado com Sucesso !!","Atenção...",64) 

           //End Transaction

           Endif  // não confirma valor digitado 

       Endif
       //Fazer ajuste do informativo SUFICIENTE / INSUFICIENTE
       DbSelectArea("TMPENV")
       nRecENV := Recno()
       DbGoTop()
       nQtdVol := 0
       While !Eof()
             nQtdVol += Iif( SubStr(TMPENV->ENVBAI, 1, 2) $ 'EX.EN', 0, IIf( TMPENV->ENVPRO == 0, TMPENV->ENVSOL, TMPENV->ENVPRO ) * TMPENV->ENVVOL )
             DbSelectArea("TMPENV")
             DbSkip()
       Enddo
       DbSelectArea("TMPENV")
       DbGoTo(nRecEnv)
       If Iif(nVolSC2 > 0, nVolSC2, nVolZZA) >= nQtdVol //Suficiente
          cSay4Env := "Suficiente: "+Alltrim(TransForm(Iif(nVolSC2 > 0, nVolSC2, nVolZZA) - nQtdVol, "@E 9,999.999"))
          oSay4Env:nClrText := cCor4EnB
       Else
          cSay4Env := "Insuficiente: "+Alltrim(TransForm(Iif(nVolSC2 > 0, nVolSC2, nVolZZA) - nQtdVol, "@E 9,999.999"))
          oSay4Env:nClrText := cCor4EnR
          
          nVolTotPI := Iif(nVolSC2 > 0, nVolSC2, nVolZZA)
          nVolFalt  := (nVolTotPI) - (nQtdVol)
/*
          cQry := ""
          cQry := "SELECT ZZS_PERCEN FROM ZZS"+cParInf1+"0 WHERE ZZS_FILIAL ='"+XFilial("ZZS")+"' AND ZZS_QTMIN <= "+cValToChar(nVolTotPI)+" AND ZZS_QTMAX >="+cValToChar(nVolTotPI)+" AND ZZS_OCORRE ='S' AND  D_E_L_E_T_='' "
          TCQuery cQry ALIAS "TCQ" NEW
          DbSelectArea("TCQ")
          DbgoTop()
          If !Eof() .and. (((nVolTotPI / (nVolFalt * -1)) -1) * 100) >= TCQ->ZZS_PERCEN          	
	          cQry1 := ""
   		      cQry1 += "UPDATE ZZA010 SET ZZA_GEROCO='1' WHERE ZZA_LOTE ='"+Alltrim(cNumLot)+"' AND SUBSTRING(ZZA_PRODUT,11,2)='00' AND D_E_L_E_T_='' AND ZZA_FILIAL ='"+XFilial("ZZA")+"'"
       		  XXX := TCSQLExec(cQry1)
	          If XXX <> 0
   		         cNomArq := 'C:\TEMP\ERR'+DTOS(MsDate())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+'.ERR'
        	     MemoWrit(cNomArq, cQry1)
			  Endif	          
    	  Endif
    	  DbSelectArea("TCQ")
          DbCloseArea() */
  
       Endif
       oSay4Env:Refresh()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fEstoEnv()
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fEstoEnv()

Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fInclFun()
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
/*Static Function fInclFun()

Return*/

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fExclFun()
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
/*Static Function fExclFun()

Return*/

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTbl1Env() - Cria temporario para o Alias: TMPENV
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTbl1Env()
       Local aFds := {}
       //Local cTmp
       Local nY

       aAdd( aFds , { "ENVCOD", "C", 015, 000} ) //Código
       aAdd( aFds , { "ENVSOL", "N", 006, 000} ) //Qtde. Solicitada
       aAdd( aFds , { "ENVPRO", "N", 006, 000} ) //Qtde. Produzida
       aAdd( aFds , { "ENVBAI", "C", 020, 000} ) //Parcial / Total
       aAdd( aFds , { "ENVORI", "C", 001, 000} ) //Original / Complemento
       aAdd( aFds , { "ENVORD", "C", 013, 000} ) //Ordem de Produção
       aAdd( aFds , { "ENVLOT", "C", 006, 000} ) //Lote
       aAdd( aFds , { "ENVSEQ", "C", 002, 000} ) //Seq. de Envase
       aAdd( aFds , { "ENVDAT", "D", 008, 000} ) //Data Inicial
       aAdd( aFds , { "ENVHOR", "C", 005, 000} ) //Hora Inicial
       aAdd( aFds , { "ENVVOL", "N", 010, 003} ) //Volume
       aAdd( aFds , { "ENVREC", "N", 010, 000} ) //R_E_C_N_O_                                      1/2
       aAdd( aFds , { "ENVBOT", "C", 007, 000} ) //Botões de tela 1º Botão - Iniciar/Confirmar   - I/C - Qdo Todas as Ops. estiverem com status I nessa posição, senão é am para gravar os apontamentos
                                                 //               2º Botão - Sair                - S   - Sempre vai ser Abandonar sem gravar nada
                                                 //               3º Botão - Complemento/Iniciar - C   - Só Aparecer esse botão se O.P estiver totalmente encerrada. Caso OP. tiver q ser iniciada a parte esse botão deverá aparecer como Iniciar.
                                                 //               4º Botão - Apontar             - A   - Sempre vai ser Apontar e irá aparecer para O.P.s em aberto, se tiver encerrada não aparece.
                                                 //               5º Botão - Excluir             - E   - A definir
                                                 //               6º Botão - Estornar            - E   - Somente irá aparecer se O.P. estiver encerrada.
												 //               7º Botão - Perda no Processo   - E   - Irá aparecer quando for tinta a pó (LINHA 97, 98 e 99) para informar qtde de perda no processo (PI KG 99 é vendido a granel)       												
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 18/11/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       //cTmp := U_NovoArqTrab("dbf") //CriaTrab( , .F. )
       //dbcreate(cTmp+".dbf", aFds, "DBFCDXADS")
       //Use (cTmp+".Dbf") Alias TMPENV VIA "DBFCDXADS" New Exclusive
       //DbCreateIndex(cTmp+"_1.cdx", "ENVCOD+ENVSEQ", {||"ENVCOD+ENVSEQ"} )
       //DbCreateIndex(cTmp+"_2.cdx", "ENVORD+ENVSEQ", {||"ENVORD+ENVSEQ"} )

       //DbClearInd()
       //DbSetIndex(cTmp+"_1")
       //DbSetIndex(cTmp+"_2")
       oTempTab02 := FWTemporaryTable():New( "TMPENV" )
       oTemptab02:SetFields( aFds )
       oTempTab02:AddIndex( "cInd01", { "ENVCOD", "ENVSEQ" } )
       oTempTab02:AddIndex( "cInd02", { "ENVORD", "ENVSEQ" } )
       oTempTab02:Create()
       /********************************************************************************************************************************/
       DbSetOrder(1)

       //Iniciar carregando dados das Ordens de Produção pelo SC2
       nQtdVol := 0
       aVerEnv := {}
       cQry1 := ""
       cQry1 += "SELECT SC2.C2_PRODUTO, SC2.C2_QUANT, SC2.C2_OP, SC2.C2_LOTE, SB1.B1_CONV, SC2.C2_DATRF, SC2.C2_QUJE  "
       cQry1 += "FROM SC2"+cParInf1+"0 SC2 WITH (NOLOCK) "
       cQry1 += "LEFT OUTER JOIN SB1"+cParInf1+"0 SB1 WITH (NOLOCK) ON SC2.C2_FILIAL = SB1.B1_FILIAL AND SC2.C2_PRODUTO = SB1.B1_COD AND SB1.D_E_L_E_T_ = '' "
       cQry1 += "WHERE SC2.C2_FILIAL = '"+cParInf2+"' "
       cQry1 += "  AND SC2.C2_LOTE = '"+cNumLot+"' "
       cQry1 += "  AND SC2.D_E_L_E_T_ = '' "
       cQry1 += "  AND SUBSTRING(SC2.C2_PRODUTO, 11, 2) NOT IN('00','99') "
       cQry1 += "ORDER BY SC2.C2_PRODUTO "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()
       While !Eof()
             RecLock("TMPENV", .t.)
                TMPENV->ENVCOD := TCQ->C2_PRODUTO
                TMPENV->ENVSOL := TCQ->C2_QUANT
                TMPENV->ENVPRO := TCQ->C2_QUJE
                TMPENV->ENVBAI := Iif(!Empty(TCQ->C2_DATRF), 'FINALIZADA', 'PENDENTE')
                TMPENV->ENVORI := 'ORIGINAL'
                TMPENV->ENVORD := TCQ->C2_OP
                TMPENV->ENVSEQ := '01'
                TMPENV->ENVLOT := TCQ->C2_LOTE
                TMPENV->ENVVOL := TCQ->B1_CONV
             MsUnLock()
             aAdd(aVerEnv, {TCQ->C2_PRODUTO, TCQ->C2_QUANT, TCQ->C2_QUJE, Iif(!Empty(TCQ->C2_DATRF), 'FINALIZADA', 'PENDENTE'), 'ORIGINAL', TCQ->C2_OP, '01', TCQ->C2_LOTE, TCQ->B1_CONV})
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
       
       //Verificar Ordens de Produção na tabela ZZA, e montar regra para botões
       /**********************************************************************************************************************************************/
       //DbSelectArea("TMPENV")
       //DbGoTop()
       //While !Eof()
       For nY := 1 To Len(aVerEnv)
             cQry1 := "SELECT SB1.B1_CONV,ZZA.* "
             cQry2 := "SELECT COUNT(*) AS QTDREC "
             cQry3 := "FROM ZZA"+cParInf1+"0 ZZA WITH (NOLOCK) "
             cQry3 += "LEFT OUTER JOIN SB1"+cParInf1+"0 SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (ZZA_FILIAL = B1_FILIAL) AND (ZZA.ZZA_PRODUT = B1_COD) "
             cQry3 += "WHERE ZZA.ZZA_FILIAL = '"+xFilial("ZZA")+"' "
             cQry3 += "  AND ZZA.D_E_L_E_T_ = '' "
             cQry3 += "  AND ZZA.ZZA_LOTE   = '"+cNumLot+"' "
             //cQry3 += "  AND ZZA.ZZA_ORDEM  = '"+TMPENV->ENVORD+"' "
             cQry3 += "  AND ZZA.ZZA_ORDEM  = '"+aVerEnv[nY][6]+"' "
             cQry2 += cQry3
             cQry3 += "ORDER BY ZZA.ZZA_SEQENV "
             cQry1 += cQry3
             TCQuery cQry2 ALIAS "TCQ" NEW
             DbSelectArea("TCQ")
             DbGoTop()
             If TCQ->QTDREC == 0      //Ordem de produção ainda não foi iniciada
                DbSelectArea("TMPENV")
                DbSetOrder(2)
                DbSeek(aVerEnv[nY][6]+Space(13 - Len(aVerEnv[nY][6]))+aVerEnv[nY][7], .T.)
                If !Found()
                         RecLock("TMPENV", .t.)
                            TMPENV->ENVCOD := aVerEnv[nY][1]
                            TMPENV->ENVSOL := aVerEnv[nY][2]
                            TMPENV->ENVPRO := aVerEnv[nY][3]
                            TMPENV->ENVBAI := aVerEnv[nY][4]
                            TMPENV->ENVORI := aVerEnv[nY][5]
                            TMPENV->ENVORD := aVerEnv[nY][6]
                            TMPENV->ENVSEQ := aVerEnv[nY][7]
                            TMPENV->ENVLOT := aVerEnv[nY][8]
                            TMPENV->ENVVOL := aVerEnv[nY][9]
                            TMPENV->ENVDAT := dDataBase
                            TMPENV->ENVHOR := SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)
                            TMPENV->ENVBOT := "2120000"
                            nQtdVol += TMPENV->ENVSOL * TMPENV->ENVVOL
                         MsUnLock()
                Else
                   RecLock("TMPENV", .f.)
                            TMPENV->ENVLOT := aVerEnv[nY][8]
                            TMPENV->ENVVOL := aVerEnv[nY][9]
                            TMPENV->ENVDAT := dDataBase
                            TMPENV->ENVHOR := SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)
                            TMPENV->ENVBOT := "2120000"
                            nQtdVol += TMPENV->ENVSOL * TMPENV->ENVVOL
                   MsUnLock()
                Endif
                DbSelectArea("TCQ")
                DbCloseArea()
             ElseIf TCQ->QTDREC == 1  //Ordem de produção Iniciada ou Apontada
                  /*
                    oGrp4Env:lVisible :=.f.
					oGetBPes:lVisible :=.f.
                    oGrp4Env:Refresh()
     				oGetBPes:Refresh()
                    */
                    DbSelectArea("TCQ")
                    DbCloseArea()
                    TCQuery cQry1 ALIAS "TCQ" NEW
                    While !Eof()
                          DbSelectArea("TMPENV")
                          DbSetOrder(2)
                          DbSeek(aVerEnv[nY][6]+Space(13 - Len(aVerEnv[nY][6]))+aVerEnv[nY][7], .T.)
                          If Found()
                          RecLock("TMPENV", .f.)
                             If TCQ->ZZA_FLAG == '6' //Somente Iniciada
                                TMPENV->ENVBAI := "INICIADA"
                                nQtdVol += TMPENV->ENVSOL * TCQ->B1_CONV
                                TMPENV->ENVBOT := "2101100"
                             ElseIf TCQ->ZZA_FLAG == '7' //Apontada Parcialmente
                                    TMPENV->ENVBAI := "APONTADA PARCIAL"
                                    TMPENV->ENVPRO := TCQ->ZZA_QUANT
                                    nQtdVol += TMPENV->ENVPRO * TCQ->B1_CONV
                                    TMPENV->ENVBOT := "2100000"
                             ElseIf TCQ->ZZA_FLAG == '8' //Apontada Totalmente
                                    TMPENV->ENVBAI := "APONTADA TOTAL"
                                    TMPENV->ENVPRO := TCQ->ZZA_QUANT
                                    nQtdVol += TMPENV->ENVPRO * TCQ->B1_CONV
                                    TMPENV->ENVBOT := "2100001"
                             ElseIf TCQ->ZZA_FLAG == '9' //Excluida
                                    TMPENV->ENVBAI := "EXCLUIDA"
                                    TMPENV->ENVBOT := "2100000"
                            ElseIf TCQ->ZZA_FLAG == 'E'
                                   TMPENV->ENVBAI := "ENCERRADA"
                                   TMPENV->ENVBOT := "2100000"
                            ElseIf TCQ->ZZA_FLAG == '5' //O.P. Já Baixada
                                   TMPENV->ENVPRO := TCQ->ZZA_QUANT
                                   TMPENV->ENVBAI := "BAIXADA"
                                   TMPENV->ENVBOT := "2100001"
                                   nQtdVol += TMPENV->ENVPRO * TCQ->B1_CONV
                             Endif
                             TMPENV->ENVSEQ := TCQ->ZZA_SEQENV
                             TMPENV->ENVDAT := STOD(TCQ->ZZA_DTINI)
                             TMPENV->ENVHOR := TCQ->ZZA_HINI
                          MsUnLock()
                          Endif
                          DbSelectArea("TCQ")
                          DbSkip()
                    EndDo
                    DbSelectArea("TCQ")
                    DbCloseArea()
             Else                  //Ordem de produção com vários apontamentos
                DbSelectArea("TCQ")
                DbCloseArea()
                TCQuery cQry1 ALIAS "TCQ" NEW
                While !Eof()
                      DbSelectArea("TMPENV")
                      DbSetOrder(2)
                      DbSeek(TCQ->ZZA_ORDEM+Space(13 - Len(TCQ->ZZA_ORDEM))+TCQ->ZZA_SEQENV, .T.)
                      If Found()
                         RecLock("TMPENV", .f.)
                            If TCQ->ZZA_FLAG == '6' //Somente Iniciada
                               TMPENV->ENVBAI := "INICIADA"
                               nQtdVol += TMPENV->ENVSOL * TCQ->B1_CONV
                               TMPENV->ENVBOT := "2101100"
                            ElseIf TCQ->ZZA_FLAG == '7' //Apontada Parcialmente
                                   TMPENV->ENVBAI := "APONTADA PARCIAL"
                                   TMPENV->ENVPRO := TCQ->ZZA_QUANT
                                   nQtdVol += TMPENV->ENVPRO * TCQ->B1_CONV
                                   TMPENV->ENVBOT := "2100000"
                            ElseIf TCQ->ZZA_FLAG == '8' //Apontada Totalmente
                                   TMPENV->ENVBAI := "APONTADA TOTAL"
                                   TMPENV->ENVPRO := TCQ->ZZA_QUANT
                                   nQtdVol += TMPENV->ENVPRO * TCQ->B1_CONV
                                   TMPENV->ENVBOT := "2100001"
                            ElseIf TCQ->ZZA_FLAG == '9' //Excluida
                                   TMPENV->ENVBAI := "EXCLUIDA"
                                   TMPENV->ENVBOT := "2100000"
                            ElseIf TCQ->ZZA_FLAG == 'E'
                                   TMPENV->ENVBAI := "ENCERRADA"
                                   TMPENV->ENVBOT := "2100001"
                            ElseIf TCQ->ZZA_FLAG == '5' //O.P. Já Baixada
                                   TMPENV->ENVPRO := TCQ->ZZA_QUANT
                                   TMPENV->ENVBAI := "BAIXADA"
                                   TMPENV->ENVBOT := "2100001"
                                   nQtdVol += TMPENV->ENVPRO * TCQ->B1_CONV
                            Endif
                            TMPENV->ENVPRO := TCQ->ZZA_QUANT
                            TMPENV->ENVSEQ := TCQ->ZZA_SEQENV
                            TMPENV->ENVDAT := STOD(TCQ->ZZA_DTINI)
                            TMPENV->ENVHOR := TCQ->ZZA_HINI
                         MsUnLock()
                      Else
                         RecLock("TMPENV", .t.)
                            TMPENV->ENVCOD := TCQ->ZZA_PRODUT
                            TMPENV->ENVSOL := TCQ->ZZA_PESPES
                            TMPENV->ENVPRO := TCQ->ZZA_QUANT
                            TMPENV->ENVBAI := Iif(TCQ->ZZA_FLAG == '9', 'EXCLUIDA', Iif(TCQ->ZZA_FLAG == 'E', 'ENCERRADA', Iif( TCQ->ZZA_FLAG == '5', 'BAIXADA', Iif(TCQ->ZZA_QUANT >= TCQ->ZZA_PESPES, 'APONTADA TOTAL', Iif(TCQ->ZZA_QUANT == 0, 'INICIADA', 'APONTADA PARCIAL' )))))
                            TMPENV->ENVORI := "O"
                            TMPENV->ENVORD := TCQ->ZZA_ORDEM
                            TMPENV->ENVLOT := TCQ->ZZA_LOTE
                            TMPENV->ENVSEQ := TCQ->ZZA_SEQENV
                            TMPENV->ENVDAT := STOD(TCQ->ZZA_DTINI)
                            TMPENV->ENVHOR := TCQ->ZZA_HINI
                            TMPENV->ENVVOL := TCQ->B1_CONV
                            TMPENV->ENVREC := TCQ->R_E_C_N_O_
                            TMPENV->ENVBOT := Iif(TCQ->ZZA_FLAG $ '9.E', "2100001", Iif(TCQ->ZZA_QUANT >= TCQ->ZZA_PESPES, "2100000", Iif(TCQ->ZZA_QUANT == 0, "2101201", "2100000" )))
                            nQtdVol += TMPENV->ENVPRO * TCQ->B1_CONV
                         MsUnLock()
                      Endif
                      DbSelectArea("TCQ")
                      DbSkip()
                EndDo
                DbSelectArea("TCQ")
                DbCloseArea()
             Endif
             DbSelectArea("TMPENV")
             DbSkip()
       //EndDo
       Next
       /**********************************************************************************************************************************************/
       //Verifica se tem somente Inicio de O.P. contando o numero de indicações de inicio do campo e comparando com a quantidade de registros da tabela
       aGerCom := {}
       DbSelectArea("TMPENV")
       DbGoTop()
       nQtdeIni := 0
       While !Eof()
             If SubStr(TMPENV->ENVBOT, 3, 1) == '2'
                nQtdeIni += 1
             Endif
             //Verificação para ativar botão de complemento.
             If aScan(aGerCom, { |x| Alltrim(TMPENV->ENVCOD) == Alltrim(x[1]) } ) == 0
                aAdd(aGerCom, {TMPENV->ENVCOD, 1, Iif(SubStr(TMPENV->ENVBAI, 1, 2) $ 'AP.PA.TO.BA', 1, 0) } )
             Else
                aGerCom[aScan(aGerCom, { |x| Alltrim(TMPENV->ENVCOD) == Alltrim(x[1]) } )][2] += 1
                aGerCom[aScan(aGerCom, { |x| Alltrim(TMPENV->ENVCOD) == Alltrim(x[1]) } )][3] += Iif(SubStr(TMPENV->ENVBAI, 1, 2) $ 'AP.PA.TO.BA', 1, 0)
             Endif
             DbSelectArea("TMPENV")
             DbSkip()
       EndDo
       For nY := 1 To Len(aGerCom)
           If aGerCom[nY][2] ==  aGerCom[nY][3]
              DbSelectArea("TMPENV")
              DbSetOrder(1)
              DbSeek(aGerCom[nY][1], .t.)
              If Found()
                 While !Eof() .and. TMPENV->ENVCOD == aGerCom[nY][1]
                       RecLock("TMPENV", .f.)
                          TMPENV->ENVBOT := Stuff( TMPENV->ENVBOT, 3, 1, "1")
                       MsUnLock()
                       DbSelectArea("TMPENV")
                       DbSkip()
                 Enddo
              Endif
           Endif
       Next
       If Iif(nVolSC2 > 0, nVolSC2, nVolZZA) >= nQtdVol //Suficiente
          cSay4Env := "Suficiente: "+Alltrim(TransForm(Iif(nVolSC2 > 0, nVolSC2, nVolZZA) - nQtdVol, "@E 9,999.999"))
          oSay4Env:nClrText := cCor4EnB
       Else
          cSay4Env := "Insuficiente: "+Alltrim(TransForm(Iif(nVolSC2 > 0, nVolSC2, nVolZZA) - nQtdVol, "@E 9,999.999"))
          oSay4Env:nClrText := cCor4EnR
       Endif
       oSay4Env:Refresh()
       //Carregar Funcionários referentes ao envase
       DbSelectArea("TMPENV")
       DbGoTop()
       DbSelectArea("TMPFUN")
       DbClearFilter()
       DbGoTop()
       While !Eof()
             If TMPFUN->FUNPRO == TMPENV->ENVCOD
                RecLock("TMPFUN", .f.)
                   TMPFUN->FUNVIS := "S"
                MsUnLock()
             Endif
             DbSelectArea("TMPFUN")
             DbSkip()
       EndDo
       cFilFun := 'FUNVIS == "S"'
       MSFILTER(cFilFun)
       DbGoTop()
Return
/*
Static Function fGeraEtiqu(nPosEtq, aImpEtq)
       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de cVariable dos componentes                                 ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ/
       Private cSayTit    := Space(1)

       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de Variaveis Private dos Objetos                             ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ/
       SetPrvt("oFont1", "oDlg1", "oSayTit", "oBtnNew", "oBtnAdd", "oBtnSai")

       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Definicao do Dialog e todos os seus componentes.                        ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ/
       oFont1     := TFont():New( "MS Sans Serif", 0, -19, , .T., 0, , 700, .F., .F., , , , , , )
       oDlg1      := MSDialog():New( 225, 248, 350, 757, "Etiqueta de Pallets", , , .F., , , , , , .T., , , .T. )
       oSayTit    := TSay():New( 008, 076, {|| "SAIDA DO ENVASE"}, oDlg1, , oFont1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 096, 012)
       oBtnNew    := TButton():New( 040, 008, "Novo Pallet", oDlg1, { || fNewPal(nPosEtq, aImpEtq)   }, 068, 012, , oFont1, , .T., , "", , , , .F. )
       oBtnAdd    := TButton():New( 040, 092, "Existente"  , oDlg1, { || fAddPal(nPosEtq, aImpEtq)   }, 068, 012, , oFont1, , .T., , "", , , , .F. )
       oBtnSai    := TButton():New( 040, 176, "Não gera"   , oDlg1, { || oDlg1:End()                           }, 068, 012, , oFont1, , .T., , "", , , , .F. )

       oDlg1:Activate(, , , .T.)
Return 

Static Function fNewPal(nPosEtq, aImpEtq)
       Local cQry1   := ""
       //Buscar o ultimo R_E_C_N_O_ para Inclusão
       cQry1 += "SELECT MAX(ZZK.R_E_C_N_O_) AS R_E_C_N_O_ "
       cQry1 += "FROM  ZZK"+cParInf1+"0  ZZK "
       TCQUERY cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()
       nCodReg := Str(TCQ->R_E_C_N_O_ + 1, 10)
       DbSelectArea("TCQ")
       DbCloseArea()

       //Buscar a ultima sequencia do código para Inclusão
       cQry1 := ""
       cQry1 += "SELECT TOP 1 ZZK.ZZK_CODIGO "
       cQry1 += "FROM  ZZK"+cParInf1+"0  ZZK "
       cQry1 += "WHERE ZZK.ZZK_FILIAL = '"+xFilial("ZZK")+"'"
       cQry1 += "  AND ZZK.D_E_L_E_T_ = '' "
       cQry1 += "  AND ZZK.ZZK_DATA   = '"+DTOS(Date())+"' "
       cQry1 += "ORDER BY ZZK.ZZK_CODIGO DESC "
       TCQUERY cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()
       cCodSeq := Iif(Empty(TCQ->ZZK_CODIGO), SubStr(Dtos(Date()), 7, 2)+SubStr(Dtos(Date()), 5, 2)+SubStr(Dtos(Date()), 3, 2)+'/'+'0001', SubStr(TCQ->ZZK_CODIGO, 1, 7)+StrZero(Val(SubStr(TCQ->ZZK_CODIGO, 8, 4))+1, 4) )
       cNomArq := SubStr(cCodSeq, 8, 4)
       DbSelectArea("TCQ")
       DbCloseArea()

       cQry1 := ""
       cQry1 += "INSERT INTO  ZZK"+cParInf1+"0  "
       cQry1 += "      (ZZK_FILIAL, ZZK_CODIGO   , ZZK_PRODUT          , ZZK_LOTE            , ZZK_SEQENV          , ZZK_DATA          , ZZK_HORA                                       , ZZK_QUANT                            , R_E_C_N_O_ , ZZK_FLAG, ZZK_LOCORI                           ) "
       //cQry1 += "VALUES('"+cParInf2+"'      , '"+cCodSeq+"', '"+TMPENV->ENVCOD+"', '"+TMPENV->ENVLOT+"', '"+TMPENV->ENVSEQ+"', '"+DTOS(Date())+"', '"+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+"', "+Str(TMPENV->ENVPRO, 10)+", "+nCodReg+", '1'     , '"+Iif(cParInf5 $ '1', '03', '30')+"') "
       cQry1 += "VALUES('"+cParInf2+"'      , '"+cCodSeq+"', '"+aImpEtq[nPosEtq][1]+"', '"+aImpEtq[nPosEtq][2]+"', '"+aImpEtq[nPosEtq][3]+"', '"+DTOS(Date())+"', '"+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+"', "+Str(aImpEtq[nPosEtq][4], 10)+", "+nCodReg+", '1'     , '"+Iif(cParInf5 $ '1', 'P1', 'P2')+"') "
       XXX := TCSqlExec(cQry1)
       If XXX <> 0
         cNomArq := 'C:\TEMP\ERR'+DTOS(MsDate())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+'.ERR'
         MemoWrit(cNomArq, cQry1)
       Endif
       //Verificação de Impressora ativa
       //oPrint   := TMSPrinter():New("Impressão de Etiquetas de Pallets")
       //lPrinter := oPrint:IsPrinterActive()
       cModelo   := "S600" //Modelo da impressora
       cPorta    := "LPT1" //Porta da impressora
       nTam      := 120    //Tamanho da etiqueta
       lTipo     := .f.    //.f.=Local; .t.=Servidor ou Outro Servidor
       lDrvWin   := .f.    //Usa Drive do Windows
       For nY := 1 To 2
           MSCBPRINTER(cModelo, cPorta, , nTam, lTipo, , , , , , lDrvWin)
           If !MSCBIsPrinter('LPT1')
              Messagebox("Impressora não encontrada!","Atenção",48)
              MSCBCLOSEPRINTER()
              Exit
           Else   
               MSCBBEGIN(1, 6, , .f.)
//                  MSCBSAYBAR(05, 03, cCodSeq, "N", "MB02", 15, .F., .T., .F., , 3, 2)
				//Cleber(17/02/12) -> teste trocando código de barra pra ver se leitor lê melhor
                  MSCBSAYBAR(05, 03, strtran(cCodSeq,"/",""), "N", "MB01", 15, .F., .T., .F., , 3, 2)
                  MSCBCHKSTATUS(.f.)
                  cText := MSCBEND()
               MSCBCLOSEPRINTER()

               cArq := 'C:\TEMP\'+cNomArq+'.ETQ'
               MemoWrit(cArq, cText)
               Type cArq > prn
          Endif
       Next
       oDlg1:End()
Return

Static Function fAddPal(nPosEtq, aImpEtq)
       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de cVariable dos componentes                                 ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ/
       Private cGetCod := Space(11)
       Private cMarca  := 'XX'

       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de Variaveis Private dos Objetos                             ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ/
       SetPrvt("oDlg2", "oBrwSel", "oGetCod", "oBtnCon", "oBtnVol")

       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Definicao do Dialog e todos os seus componentes.                        ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ/
       lRet := oTbl1Etq()
       If !lRet
          DbSelectArea("TMPETQ")
          DbCloseArea()
          Messagebox("Não existem pallets para adicionar produtos","Atenção...",48)
          Return()
       Else
          oDlg2      := MSDialog():New( 094, 490, 327, 791, "Inclui produção em um pallet", , , .F., , , , , , .T., , , .T. )
          DbSelectArea("TMPETQ")
          DbGoTop()
          oBrwSel                     := MsSelect():New( "TMPETQ", "MARCA", "", { { "MARCA", "", "", "" }, {"CODIGO", "", "Codigo", "999999/9999"} }, .F., cMarca, { 000, 000, 080, 148}, , , oDlg2 )
          oBrwSel:bAval               := { || TMPETQMark() }
          oBrwSel:oBrowse:lHasMark    := .T.
          oBrwSel:oBrowse:lCanAllmark := .F.
          oGetCod    := TGet():New( 084, 004, { |u| If(PCount() > 0, cGetCod := u, cGetCod)}, oDlg2, 140, 008, '', , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., "", "cGetCod", , )
          oBtnCon    := TButton():New( 100, 048, "Confirma", oDlg2, { || fGrvInfEtq(nPosEtq, aImpEtq) }, 037, 012, , , , .T., , "", , , , .F. )
          oBtnVol    := TButton():New( 100, 104, "Voltar"  , oDlg2, { || oDlg2:End()                  }, 037, 012, , , , .T., , "", , , , .F. )
          oGetCod:bLostFocus := { || DbSeek(cGetCod), oBrwSel:oBrowse:Refresh() }

          oDlg2:Activate(, , , .T.)
          DbSelectArea("TMPETQ")
          DbCloseArea()
       Endif
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTbl1Etq() - Cria temporario para o Alias: TMPETQ
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ/
Static Function oTbl1Etq()
       Local aFds := {}
       Local cTmp

       aAdd( aFds , {"MARCA"   , "C", 002, 000} )
       aAdd( aFds , {"CODIGO"  , "C", 011, 000} )

       cTmp := U_NovoArqTrab("dbf") //CriaTrab( , .F. )
       dbcreate(cTmp+".dbf", aFds, "DBFCDXADS")
       Use (cTmp+".Dbf") Alias TMPETQ VIA "DBFCDXADS" New Exclusive

       DbCreateIndex(cTmp+"_1.cdx", "CODIGO", {||"CODIGO"} )

       DbClearInd()
       DbSetIndex(cTmp+"_1")
       DbSetOrder(1)

       //1º) Buscar pallets do dia
       cQry1   := ""
       cQry1   += "SELECT * FROM  ZZK"+cParInf1+"0  ZZK WITH (NOLOCK) WHERE ZZK.ZZK_FILIAL = '"+xFilia("ZZK")+"' AND ZZK.ZZK_DATA = '"+Dtos(Date())+"' AND ZZK.ZZK_LOCORI = '"+Iif(cParInf5 $ '1', 'P1', 'P2')+"' AND ZZK.ZZK_FLAG = '1' ORDER BY ZZK.ZZK_HORA "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbgoTop()
       While !Eof()
             DbSelectArea("TMPETQ")
             DbSetOrder(1)
             DbSeek(TCQ->ZZK_CODIGO, .t.)
             If !Found()
                RecLock("TMPETQ", .t.)
                   TMPETQ->CODIGO := TCQ->ZZK_CODIGO
                MsUnLock()
             Endif
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
       
       //2º) Verificar se existem pallets do dia e se for antes das 9:00hs buscar os pallets do dia anterior depois das 16:00 h
       If TMPETQ->(RecCount()) > 0
          If Time() <= '09:00:00'
             lBusca := .t.
             nCont  := 1
             While lBusca .and. nCont <= 5
                   cQry1   := ""
                   cQry1   += "SELECT * FROM  ZZK"+cParInf1+"0  ZZK WITH (NOLOCK) WHERE ZZK.ZZK_FILIAL = '"+xFilial("ZZK")+"' AND ZZK.ZZK_DATA = '"+Dtos(Date()-nCont)+"' AND ZZK_HORA >= '1600' AND ZZK.ZZK_LOCORI = '"+Iif(cParInf5 $ '1', 'P1', 'P2')+"' AND ZZK.ZZK_FLAG = '1' ORDER BY ZZK.ZZK_HORA "
                   TCQuery cQry1 ALIAS "TCQ" NEW
                   DbSelectArea("TCQ")
                   DbgoTop()
                   While !Eof()
                         DbSelectArea("TMPETQ")
                         DbSetOrder(1)
                         DbSeek(TCQ->ZZK_CODIGO, .t.)
                         If !Found()
                            RecLock("TMPETQ", .t.)
                               TMPETQ->CODIGO := TCQ->ZZK_CODIGO
                            MsUnLock()
                         Endif
                         DbSelectArea("TCQ")
                         DbSkip()
                   Enddo
                   DbSelectArea("TCQ")
                   DbCloseArea()
                   If TMPETQ->(RecCount()) > 0
                      nCont  += 5
                      lBusca := .f.
                   Else
                      nCont += 1
                   Endif
             Enddo
          Endif
       //2º) Verificar se não existem pallets do dia buscar os pallets do dia anterior depois das 16:00 h
       Else
          lBusca := .t.
          nCont  := 1
          While lBusca .and. nCont <= 5
                cQry1   := ""
                cQry1   += "SELECT * FROM  ZZK"+cParInf1+"0  ZZK WITH (NOLOCK) WHERE ZZK.ZZK_FILIAL = '"+xFilial("ZZK")+"' AND ZZK.ZZK_DATA = '"+Dtos(Date()-nCont)+"' AND ZZK_HORA >= '1600' AND ZZK.ZZK_LOCORI = '"+Iif(cParInf5 $ '1', 'P1', 'P2')+"' AND ZZK.ZZK_FLAG = '1' ORDER BY ZZK.ZZK_HORA "
                TCQuery cQry1 ALIAS "TCQ" NEW
                DbSelectArea("TCQ")
                DbgoTop()
                While !Eof()
                      DbSelectArea("TMPETQ")
                      DbSetOrder(1)
                      DbSeek(TCQ->ZZK_CODIGO, .t.)
                      If !Found()
                         RecLock("TMPETQ", .t.)
                            TMPETQ->CODIGO := TCQ->ZZK_CODIGO
                         MsUnLock()
                      Endif
                      DbSelectArea("TCQ")
                      DbSkip()
                Enddo
                DbSelectArea("TCQ")
                DbCloseArea()
                If TMPETQ->(RecCount()) > 0
                   nCont  += 5
                   lBusca := .f.
                Else
                   nCont += 1
                Endif
          Enddo
       Endif
Return(TMPETQ->(RecCount()) > 0)

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ TMPETQMark() - Funcao para marcar o MsSelect
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ/
Static Function TMPETQMark()
       Local lDesMarca := TMPETQ->(IsMark("MARCA", cMarca))
       Local nRecno    := TMPETQ->(Recno())
       DbSelectArea("TMPETQ")
       DbGoTop()
       While !Eof()
             If nRecno == Recno()
                RecLock("TMPETQ", .F.)
                   If lDesmarca
                      TMPETQ->MARCA := "  "
                   Else
                      TMPETQ->MARCA := cMarca
                   Endif
                TMPETQ->(MsUnlock())
             Else
                RecLock("TMPETQ", .F.)
                   TMPETQ->MARCA := "  "
                TMPETQ->(MsUnlock())
             Endif
             DbSelectArea("TMPETQ")
             DbSkip()
       Enddo
       DbSelectArea("TMPETQ")
       DbGoTop(nRecno)
       oBrwSel:oBrowse:Refresh()
Return

Static Function fGrvInfEtq(nPosEtq, aImpEtq)
       Local cQry1   := ""
       Local cCodSeq := space(11)

       DbSelectArea("TMPETQ")
       DbGoTop()
       While !Eof()
             If TMPETQ->(IsMark("MARCA", cMarca))
                cCodSeq := TMPETQ->CODIGO
             Endif
             DbSelectArea("TMPETQ")
             DbSkip()
       Enddo
       If Empty(cCodSeq)
          Messagebox("Não foi marcado nenhum pallet para adicionar produtos", "Verifique!",48) 
          DbSelectArea("TMPETQ")
          DbGoTop()
          oBrwSel:oBrowse:Refresh()
          Return
       Else
          //Buscar o ultimo R_E_C_N_O_ para Inclusão
          cQry1 += "SELECT MAX(ZZK.R_E_C_N_O_) AS R_E_C_N_O_ "
          cQry1 += "FROM  ZZK"+cParInf1+"0  ZZK "
          TCQUERY cQry1 ALIAS "TCQ" NEW
          DbSelectArea("TCQ")
          DbGoTop()
          nCodReg := Str(TCQ->R_E_C_N_O_ + 1, 10)
          DbSelectArea("TCQ")
          DbCloseArea()       
       
          cQry1 := ""
          cQry1 += "INSERT INTO  ZZK"+cParInf1+"0  "
          cQry1 += "      (ZZK_FILIAL    , ZZK_CODIGO   , ZZK_PRODUT          , ZZK_LOTE            , ZZK_SEQENV          , ZZK_DATA          , ZZK_HORA                                       , ZZK_QUANT                  , R_E_C_N_O_, ZZK_FLAG, ZZK_LOCORI ) " 
          //cQry1 += "VALUES('"+cParInf2+"', '"+cCodSeq+"', '"+TMPENV->ENVCOD+"', '"+TMPENV->ENVLOT+"', '"+TMPENV->ENVSEQ+"', '"+DTOS(Date())+"', '"+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+"', "+Str(TMPENV->ENVPRO, 10)+", "+nCodReg+", '1', '"+Iif(cParInf5 $ '1', '03', '30')+"') "
          cQry1 += "VALUES('"+cParInf2+"', '"+cCodSeq+"', '"+aImpEtq[nPosEtq][1]+"', '"+aImpEtq[nPosEtq][2]+"', '"+aImpEtq[nPosEtq][3]+"', '"+DTOS(Date())+"', '"+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+"', "+Str(aImpEtq[nPosEtq][4], 10)+", "+nCodReg+", '1', '"+Iif(cParInf5 $ '1', 'P1', 'P2')+"') "
          XXX := TCSqlExec(cQry1)
          If XXX <> 0
            cNomArq := 'C:\TEMP\ERR'+DTOS(MsDate())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+'.ERR'
            MemoWrit(cNomArq, cQry1)
          Endif
       Endif
       oDlg1:End()
       oDlg2:End()
return 
/***
		1 - Inclusão de Empenho
		2 - Exclusão de Empenho
		3 - Aletação de Empenho
****/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ AtualizSD4   º Autor ³ Tiago Lucio/Chausº Data ³ 17/04/2014º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Funcao para alteração da SD4 via sigaauto  de acordo ZZF   ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ SIGAPCP                                                    ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
atual: FSAtuSX3
*/


Static Function AtualizSD4()

Local cArea,aArea,lReturn,lAlteracao,nCont,nItens,aVetor,aItens,cQuery
PRIVATE lMsErroAuto


cArea:=getArea()
aArea := U_PegaArea({"ZZF","ZZA","SD4","SB2","SZ5"})

lReturn:=.T.
lAlteracao:=.F. 
aItens:={} 
nItens:=0 
nCont:=1


  
dbselectArea("ZZF")
ZZF->(dbSetOrder(1)) //ZZF_FILIAL, ZZF_ORDEM, R_E_C_N_O_, D_E_L_E_T_                      
ZZF->(dbSeek(xFilial("ZZF")+cNumOrd))
                                     
While !(ZZF->(eof())) .And. (cNumOrd== ZZF->ZZF_ORDEM)   

	aADD(aItens,{ZZF->ZZF_ORDEM,ZZF->ZZF_CODIGO,ZZF->ZZF_QTDUSA,ZZF->ZZF_TRT,ZZF->ZZF_LOCAL })
	nItens:=nItens + 1
	ZZF->(dbSkip())
    dBselectArea("ZZF")
EndDo


    While nCont <= nItens  //Varre o array aItens
		lAlteracao:=.F.
		dbselectArea("SD4")
		SD4->(dbSetOrder(2)) //D4_FILIAL, D4_OP, D4_COD, D4_LOCAL, R_E_C_N_O_, D_E_L_E_T_                                                    
		SD4->(dbSeek(xFilial("SD4")+aItens[nCont][1]))//Item existente
                  
       While !(SD4->(eof())) .And. aItens[nCont][1]==Trim(SD4->D4_OP)
       		if Trim(aItens[nCont][1])==TRIM(SD4->D4_OP) .And. Trim(aItens[nCont][2])==Trim(SD4->D4_COD) .And. TRIM(SD4->D4_TRT)==TRIM(aItens[nCont][4]) 
       		    lAlteracao:=.T.
		   		If ROUND(SD4->D4_QUANT,4) <>ROUND(aItens[nCont][3],4) //Empenho alterado
				   If ROUND(aItens[nCont][3],4) > ROUND(SD4->D4_QUANT,4)   //HELP: A380QUANT O saldo do empenho não pode ser maior que a quantidade original do mesmo.
				      lMsErroAuto := .f.
					   aVetor:={ {"D4_COD" 			,SD4->D4_COD			,Nil},; //COM O TAMANHO EXATO DO CAMPO                    
								{"D4_OP" 			,SD4->D4_OP       		,Nil},;
								{"D4_FILIAL" 		,xFilial("SD4")        	,Nil},;                           
								{"D4_QTDEORI" 		,SD4->D4_QTDEORI        ,Nil},; 
								{"D4_QUANT" 		,SD4->D4_QUANT          ,Nil},;            
								{"D4_TRT"			,SD4->D4_TRT         	,Nil},;   
								{"D4_LOCAL"			,SD4->D4_LOCAL         	,Nil},;                  
								{"D4_QTSEGUM"		,0                 		,Nil}}
								dbSelectArea("SD4")
								MSExecAuto({|x,y| mata380(x,y)},aVetor,5) //Exclusão
		                                 		
			   		   If lMsErroAuto        
				   	  	   //	MostraErro()
				   		 //	MsgAlert("Não foi possivel ajustar o saldo do Item: "+Trim(SD4->D4_COD)+" /Local: "+Trim(SD4->D4_LOCAL)+" /Saldo: "+Str(ZZF->ZZF_QTDUSA)+" na SD4. Favor verificar com o PCP.")
				   	   Else
							DbSelectArea("SB2") // criar empenhos em armazens não existentes André em 21/06/16
							DbSetOrder(1)
							DbGotop()
							If !SB2->(DBSEEK(xFilial("SB2")+aItens[nCont][2]+aItens[nCont][5]))
								CriaSB2(aItens[nCont][2], aItens[nCont][5])
							Endif 

				   			aVetor:={ {"D4_COD" 	,aItens[nCont][2]		,Nil},; //COM O TAMANHO EXATO DO CAMPO                    
						          	{"D4_OP" 		,aItens[nCont][1]       ,Nil},;
						          	{"D4_FILIAL" 	,xFilial("SD4")        	,Nil},;                           
					              	{"D4_QTDEORI" 	,aItens[nCont][3]       ,Nil},; 
								  	{"D4_QUANT" 	,aItens[nCont][3]       ,Nil},;            
					              	{"D4_TRT"		,aItens[nCont][4]       ,Nil},;   
								  	{"D4_LOCAL"		,aItens[nCont][5]       ,Nil},;                  
								  	{"D4_QTSEGUM"	,0                 		,Nil}}
						          	dbSelectArea("SD4")
								  	MSExecAuto({|x,y| mata380(x,y)},aVetor,3) //Inclui
	                              		
						     If lMsErroAuto        
						  		MostraErro()
						     EndIf
			 		   EndIf      
	             	Else
				       lMsErroAuto := .f.
					   aVetor:={ {"D4_COD"    ,SD4->D4_COD           ,Nil},; //COM O TAMANHO EXATO DO CAMPO                    
								{"D4_OP"      ,SD4->D4_OP            ,Nil},;
								{"D4_FILIAL"  ,xFilial("SD4")        ,Nil},;                           
								{"D4_QUANT"   ,aItens[nCont][3]      ,Nil},;            
								{"D4_QTDEORI" ,aItens[nCont][3]      ,Nil},; 
								{"D4_TRT"     ,SD4->D4_TRT           ,Nil},;   
								{"D4_LOCAL"   ,aItens[nCont][5]      ,Nil},;                  
								{"D4_QTSEGUM" ,0                     ,Nil}}
								dbSelectArea("SD4")
								MSExecAuto({|x,y| mata380(x,y)},aVetor,4) //Alteração
		                                		
				   		If lMsErroAuto        
					   	   MostraErro() 
						   //	MsgAlert("Não foi possivel incluir o empenho do Item: "+Trim(SD4->D4_COD)+" /Local: "+Trim(SD4->D4_LOCAL)+" /Saldo: "+Str(ZZF->ZZF_QTDUSA)+" na SD4. Favor verificar com o PCP.")
				 		EndIf                                            
			 	 Endif	
	           EndIf
	        EndIf 	
			SD4->(dbSkip())   
			dBselectArea("SD4")
	   End
       
    If !lAlteracao //não achou o registro na SD4 
    	lMsErroAuto:=.f. 

		DbSelectArea("SB2") // criar empenhos em armazens não existentes André em 21/06/16
		DbSetOrder(1)
		DbGotop()
		If !SB2->(DBSEEK(xFilial("SB2")+aItens[nCont][2]+aItens[nCont][5]))
			CriaSB2(aItens[nCont][2], aItens[nCont][5])
		Endif 


   		aVetor:={ {"D4_COD" 			,aItens[nCont][2]		,Nil},; //COM O TAMANHO EXATO DO CAMPO                    
		          {"D4_OP" 				,aItens[nCont][1]       ,Nil},;
		          {"D4_FILIAL" 			,xFilial("SD4")        	,Nil},;                           
	              {"D4_QTDEORI" 		,aItens[nCont][3]       ,Nil},; 
				  {"D4_QUANT" 			,aItens[nCont][3]       ,Nil},;            
	              {"D4_TRT"				,aItens[nCont][4]       ,Nil},;   
				  {"D4_LOCAL"			,aItens[nCont][5]       ,Nil},;                  
				  {"D4_QTSEGUM"			,0                 		,Nil}}
		          dbSelectArea("SD4")
				  MSExecAuto({|x,y| mata380(x,y)},aVetor,3) //Inclui
	                              		
	     If lMsErroAuto        
		    // MsgAlert("Não foi possivel incluir o empenho do Item: "+Trim(SD4->D4_COD)+" /Local: "+Trim(SD4->D4_LOCAL)+" /Saldo: "+Str(ZZF->ZZF_QTDUSA)+" na SD4. Favor verificar com o PCP.")
	  		//MostraErro()
	     EndIf
	
    
	EndIf
	nCont:=nCont + 1
 End

If ChkFile("TMPD4")
	DbSelectArea("TMPD4")
	DbCloseArea()
Endif

//Exclusões
cQuery:="	SELECT D4_FILIAL,D4_OP, D4_COD, D4_LOCAL,D4_QTDEORI,D4_QUANT,D4_TRT,D4_QTSEGUM	"
cQuery+="	FROM "+RetSqlName("SD4")+"  SD4	"
cQuery+="   WHERE D4_OP ='"+Trim(cNumOrd)+"' AND D4_FILIAL='"+xFilial("SD4")+"' AND SD4.D_E_L_E_T_=''  "
cQuery+="   AND D4_COD NOT IN (SELECT ZZF_CODIGO FROM "+RetSqlName("ZZF")+" ZZF WHERE ZZF_FILIAL='"+xFilial("ZZF")+"' AND ZZF.D_E_L_E_T_='' AND ZZF_ORDEM ='"+Trim(cNumOrd)+"') "
cQuery+="   ORDER BY D4_COD "

TCQuery cQuery ALIAS "TMPD4" NEW
DbSelectArea("TMPD4")
                  
While !(TMPD4->(eof()))
    
    dbSelectArea("ZZF")
	ZZF->(dbSetOrder(4)) //ZZF_FILIAL, ZZF_ORDEM, ZZF_CODIGO, ZZF_TRT, R_E_C_N_O_, D_E_L_E_T_                  
	iF !ZZF->(dbSeek(xFilial("ZZF")+TMPD4->D4_OP+TMPD4->D4_COD)) //Produto foi excluido
	 			lMsErroAuto := .f.
					   aVetor:={ {"D4_COD" 					,TMPD4->D4_COD	   ,Nil},; //COM O TAMANHO EXATO DO CAMPO                    
								{"D4_OP" 					,TMPD4->D4_OP      ,Nil},;
								{"D4_FILIAL" 				,xFilial("SD4")    ,Nil},;                           
								{"D4_QTDEORI" 				,TMPD4->D4_QTDEORI ,Nil},; 
								{"D4_QUANT" 				,TMPD4->D4_QUANT   ,Nil},;            
								{"D4_TRT"					,TMPD4->D4_TRT     ,Nil},;   
								{"D4_LOCAL"					,TMPD4->D4_LOCAL   ,Nil},;                  
								{"D4_QTSEGUM"				,0                 ,Nil}}
							   //	dbSelectArea("SD4")
								MSExecAuto({|x,y| mata380(x,y)},aVetor,5) //Exclusão
		                                 		
			   		If lMsErroAuto        
		  //		   	   	MostraErro()
				   	   // MsgAlert("Não foi possivel exclui o empenho do Item: "+Trim(SD4->D4_COD)+" /Local: "+Trim(SD4->D4_LOCAL)+" /Saldo: "+Str(ZZF->ZZF_QTDUSA)+" na SD4. Favor verificar com o PCP.")
			 		EndIf                                            
	
	EndIf
	
	
	
	TMPD4->(dbSkip())
	
EndDo

U_VoltaArea(aArea)
RestArea(cArea)  
       
Return lReturn

// Retorna o volume do Pa apontado na OP
Static Function FVolTotPa()
LOCAL cArea,aArea,nQtdVol
cArea:= GetArea()

aArea := U_PegaArea({"ZZA","SB1","SZ5"})

	DbSelectArea("ZZA")
 	DbSetOrder(3)
    DbSeek(xFilial("ZZA")+Alltrim(cGet2Env), .t.)
	nQtdVol := 0
    If Found()
		While !Eof() .and. (ZZA->ZZA_FILIAL == XFilial("ZZA")) .AND. (ZZA->ZZA_LOTE == Alltrim(cGet2Env))
			nQtdConv := Posicione("SB1", 1, xFilial("SB1")+ZZA->ZZA_PRODUT, "B1_CONV")
			If nQtdConv == 0
				nQtdConv := Posicione("SZ5", 1, xFilial("SZ5")+SubStr(Alltrim(ZZA->ZZA_PRODUT), 11, 2), "Z5_VOLUME")
			Endif
			cTipoPro := Posicione("SB1", 1, xFilial("SB1")+ZZA->ZZA_PRODUT, "B1_TIPO") 
        	If cTipoPro == 'PA' .and. !(ZZA->ZZA_FLAG) $ '6.9.X'
        		nQtdVol += (ZZA->ZZA_QUANT * nQtdConv)
        	Endif
		    DbSelectArea("ZZA")
        	DbSkip()
		Enddo
	Endif
	
	DbSelectArea("ZZA")
	//DbClosearea()

                                                                               
U_VoltaArea(aArea)
RestArea(cArea)  

Return(nQtdVol)

// Retorna a diferença entre o Saldo de PI e o volume de Pa apontado na OP
Static Function FVolProdAc()
Local cArea,aArea,nQtdVol,nQtdConv,cTipoPro

	cArea:= GetArea()
aArea := U_PegaArea({"ZZA","SB1","SZ5"})

	DbSelectArea("ZZA")
 	DbSetOrder(3)
    DbSeek(xFilial("ZZA")+Alltrim(cGet2Env), .t.)
	nQtdVol := 0
    If Found()
		While !Eof() .and. (ZZA->ZZA_FILIAL == XFilial("ZZA")) .AND. (ZZA->ZZA_LOTE == Alltrim(cGet2Env))
			nQtdConv := Posicione("SB1", 1, xFilial("SB1")+ZZA->ZZA_PRODUT, "B1_CONV")
			If nQtdConv == 0
				nQtdConv :=	Posicione("SZ5", 1, xFilial("SZ5")+SubStr(Alltrim(ZZA->ZZA_PRODUT), 11, 2), "Z5_VOLUME")
			Endif
			cTipoPro := Posicione("SB1", 1, xFilial("SB1")+ZZA->ZZA_PRODUT, "B1_TIPO") 
	    	//cSegUM   := Posicione("SB1", 1, xFilial("SB1")+ZZA->ZZA_PRODUT, "B1_SEGUM") 
        	If cTipoPro == 'PA' .and. !(ZZA->ZZA_FLAG) $ '6.9.X'
        		nQtdVol += (ZZA->ZZA_QUANT * nQtdConv)
        	Endif
		    DbSelectArea("ZZA")
        	DbSkip()
		Enddo
	Endif
	
	DbSelectArea("ZZA")
	//DbClosearea()

	nSaldo := (Iif(nVolSC2 > 0, nVolSC2, nVolZZA)-nQtdVol)
                                                                               
U_VoltaArea(aArea)
RestArea(cArea)  

Return(nSaldo)

User Function fValSenLabo(cSupLab, cRetSup)
     Local   lRet       := .f.
     Private cGetSup    := space(15)
     Private cGetPas    := space(06)
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oFont1", "oDlgPas", "oSaySup", "oSayPas", "oGetSup", "oGetPas","oBtn1","oBtn2")

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oFont1     := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
     oDlgPas    := MSDialog():New( 088, 232, 201, 477, "Liberação...", , , .F., , , , , , .T., , , .T. )
     oSaySup    := TSay():New( 004, 004, {|| "Supervisor:"}, oDlgPas, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 056, 012)
     oSayPas    := TSay():New( 019, 004, {|| "Senha:"}     , oDlgPas, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 056, 012)
     oGetSup    := TGet():New( 003, 056, {|u| If(PCount() > 0, cGetSup:=u, cGetSup)}, oDlgPas, 060, 012, '', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .F., .F., "", "cGetSup", , )
     oGetPas    := TGet():New( 020, 056, {|u| If(PCount() > 0, cGetPas:=u, cGetPas)}, oDlgPas, 060, 012, '', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .F., .T., "", "cGetPas", , )
     oBtnCon    := TButton():New( 040, 024, "Confirmar", oDlgPas, {|| lRet := fValPas(cSupLab, @cRetSup) }, 037, 012, , , , .T., , "", , , , .F. )
     oBtnVol    := TButton():New( 040, 076, "Voltar"   , oDlgPas, {|| oDlgPas:End()}, 037, 012, , , , .T., , "", , , , .F. )

     oDlgPas:Activate(,,,.T.)

Return(lRet)

Static Function fValPas(cSupLab, cRetSup)
       //PswOrder(1) - Ordena pela Id do usuário
       //PswOrder(2) - Ordena por usuario
       //PswOrder(3) - Ordena por senha
       PswOrder(2)
       If PswSeek(cGetSup)
          If Upper(Alltrim(cGetSup)) $ Upper(Alltrim(cSupLab))
             PswOrder(3)
             If !PswSeek(cGetPas)
                MsgStop('Senha inválida !!!')
                cGetPas := space(06)
                oGetPas:Refresh()
                oGetPas:SetFocus()
                Return
             Endif
          Else
             MsgStop('Usuário não autorizado a liberar o peso específico !!!')
             cGetPas := space(06)
             oGetPas:Refresh()
             cGetSup := space(15)
             oGetSup:Refresh()
             oGetSup:SetFocus()
             Return
          Endif
       Else
          MsgStop('Usuário Inválido !!!')
          cGetPas := space(06)
          oGetPas:Refresh()
          cGetSup := space(15)
          oGetSup:Refresh()
          oGetSup:SetFocus()
          Return
       Endif
       cRetSup := cGetSup
       oDlgPas:End()
Return(.t.)
