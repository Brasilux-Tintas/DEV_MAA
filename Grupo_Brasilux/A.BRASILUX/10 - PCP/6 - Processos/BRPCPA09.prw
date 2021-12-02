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
    ±±³Programa  ³ BRPCPA09 ³ Autor ³ Luís G. de Souza      ³ Data ³ 30/06/10 ³±±
    ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
    ±±³Locacao   ³                  ³Contato ³                                ³±±
    ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
    ±±³Descricao ³ Gera arquivo TXT para Ordens de produção.                  ³±±
    ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
    ±±³Parametros³ 0101 - Empresa+Filial                                      ³±±
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
    User Function BRPCPA09(cParInf)
         /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
         ±± Declaração de Variaveis Locais                                          ±±
         Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
         Local cIniFile    := GetAdv97()
         Local cHasMapper  := Upper(GetPvProfString("TopConnect", "Mapper"      , "ON"   , cInIfile ))
         Local xConnect    := GetGlbValue("MYTOPCONNECT")
         //Local lSair       := .f.

         /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
         ±± Declaração de Variaveis Private dos Objetos                             ±±
         Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
         Private cDataBase :=       GetPvProfString("TopConnect", "DataBase"    , "ERROR", cInIfile )
         Private cAlias    :=       GetPvProfString("TopConnect", "Alias"       , "ERROR", cInIfile )
         Private nPort     := Val(  GetPvProfString("TopConnect", "Port"        , "0"    , cInIfile ))
         Private cProtect  :=       GetPvProfString("TopConnect", "ProtheusOnly", "0"    , cInIfile )
         Private cServer   :=       GetPvProfString("TopConnect", "Server"      , "ERROR", cInIfile )
         Private cConType  := Upper(GetPvProfString("TopConnect", "Contype"     , "TCPIP", cInIfile ))
         Private cVersion  := "MP8"
         Private cGet1Apt  := Space(11)
         Private cGet2Apt  := Space(11)
         Private cSay1Apt  := Space(1)
         //Parâmetros para a função: 
         //Posição 01 a 02 - Empresa
         //Posição 03 a 04 - Filial
         //Posição 05 a 05 - Envase  (Se tiver "E", buscar O.P.s para envase)
         //Posição 06 a 06 - Conexão (Se for igual a T tem que usar funções para abrir e fechar conexão com o Top Connect senão utiliza)
         //Posição 07 a 07 - Empresa para apontamento (1 ou 2, somente para cParInf1 = '01' e cParInf2 = '010101')
         Private cParInf4  := Iif(cParInf == Nil, ""  , SubStr(cParInf,len(cParInf)-1, 1) )                                       //Envase
         Private cParInf1  := Iif(cParInf4 $ "T", Iif(cParInf == Nil, "01", SubStr(cParInf, 1, 2) ), cEmpAnt        ) //Empresa
         Private cParInf2  := Iif(cParInf4 $ "T", Iif(cParInf == Nil, "010101", SubStr(cParInf, 3, len(cParInf)-5) ), xFilial("ZZA") ) //Filial
         Private cParInf3  := Iif(cParInf == Nil, ""  , SubStr(cParInf, len(cParInf)-2, 1) )                                       //Envase
         Private cParInf5  := Iif(cParInf == Nil, "2"  , SubStr(cParInf, len(cParInf), 1) )                                       //Empresa para apontamento
         Private aRotProd  := {}
         Private cNumOrd   := ""
         Private cNumLot   := ""
         Private cNumPro   := ""
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

         SetPrvt("oFontApt", "oDlg1Apt", "oBtn1Apt", "oSay1Apt", "oGet1Apt")
     u_zcfga01( 'BRPCPA09' ) //LGS#2021201 - Gravação de log de utilização da rotina
         If !Empty(cParInf4)
            If Empty(xConnect)
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
            RpcSetType(3) //Desabilita utilização de Licensa
            //x := RpcSetEnv( "01", "01", "Expedicao", "NGlgSO", "Environment", "BRPCPA08", {"SA1", "SX6", "SB1"} )
            x := RpcSetEnv( cParInf1, cParInf2, , , cEnvArq, , {"SA1", "SX6", "SB1", "SH6"} )
            While !x
                  x := RpcSetEnv( cParInf1, cParInf2, , , cEnvArq, , {"SA1", "SX6", "SB1", "SH6"} )
            Enddo
         Endif
         /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
         ±± Definicao do Dialog e todos os seus componentes.                        ±±
         Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
         If cParInf1+cParInf2 $ '01010101'
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
         oDlg1Apt   := MSDialog():New( 312, 391, 792, 691, "Gera arquivo das Ordens de Produção", , , .F., , , , , , .T., , , .T. )
         oSay1Apt   := TSay():New( 004, 016, {|| "O.P.:"}, oDlg1Apt, , oFontApt, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 032, 012)
         oSay1Lcl   := TSay():New( 090, 008, {|| "FAB. - "+cParInf5 }, oDlg1Apt, , oFont1Lc, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 140, 036)
         oGet1Apt   := TGet():New( 002, 052, {|u| If(PCount() > 0, cGet1Apt := u, cGet1Apt)}, oDlg1Apt, 076, 013, '@!R XXXXXX-99-999', , CLR_BLACK, CLR_WHITE, oFontApt, , , .T., "", , , .F., .F., , .F., .F., "", "cGet1Apt", , )
         oGet1Apt:bLostFocus := { || fVerOrdPro() }
         //A Linha abaixo não tem função, foi incluida para se manter compatibilidade.
         oGet2Apt   := TGet():New( 002, 202, {|u| If(PCount() > 0, cGet2Apt := u, cGet2Apt)}, oDlg1Apt, 006, 003, '@!R XXXXXX-99-999', , CLR_BLACK, CLR_WHITE, oFontApt, , , .T., "", , , .F., .F., , .F., .F., "", "cGet2Apt", , )
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
    Function  ³ fVerOrdPro() - Verifica Ordem de Produção e abre botões para apontamento
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Static Function fVerOrdPro()
           Local cQry1    := ""
           Local lRetorna := .f.
           Local nX
           Private cEOL   := CHR(13)+CHR(10)
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
                 MessageBox("Não foi possível conectar ao Banco de Dados.", "Erro...",48)
                 oGet1Apt:SetFocus()
                 cGet1Apt:= space(11)
                 oGet1Apt:Refresh()
                 Return
              Endif
              TCSETCONN(__nConecta)
           Endif
           cQry1 := ""
           cQry1 += "SELECT SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_LOTE, SC2.C2_PRODUTO, SC2.C2_QUANT, SC2.C2_DATRF, SC2.C2_ROTEIRO, SB1.B1_TIPO, SB1.B1_ESTOQUE, SB1.B1_PESOESP, SB1.B1_DESC, SC2.C2_EMISSAO "
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
              //MsgStop('Ordem de produção inexistente')
              MessageBox("Ordem de produção inexistente.", "Atenção...",48)
              lRetorna := .t.
           Else
              If !Empty(TCQ->C2_DATRF)
                 MsgStop("Ordem de produção já foi finalizada!")
                 lRetorna := .t.
              Else
                 If TCQ->B1_TIPO $ 'PI'
                    aGerTxt := {}
                    aAdd(aGerTxt, {TCQ->C2_PRODUTO, TCQ->C2_LOTE, TCQ->C2_NUM+TCQ->C2_ITEM+TCQ->C2_SEQUEN, TCQ->C2_EMISSAO, TCQ->C2_QUANT })
                 Else
                    MessageBox("Ordem de produção para esse produto não pode ter o arquivo gerado", "Atenção...",48)
                    lRetorna := .t.
                 Endif
              Endif
              DbSelectArea("TCQ")
              DbCloseArea()
              If lRetorna
                 oGet1Apt:SetFocus()
                 cGet1Apt := space(11)
                 oGet1Apt:Refresh()
                 If !Empty(cParInf4)
                    TCQuit() //Desmonta conexão com o banco de dados
                 Endif
                 Return(.f.)
              Else
                 /********************************************************************************************************************/
                 //Dados genéricos para as duas fábricas
                 lExiste   := .f.
                 lNaoGer   := .f.
                 cDescri := Posicione("SB1", 1, xFilial("SB1")+aGerTXT[1][1], "B1_DESC")
                 aQtdMat := {} ; aVolMat := {}
                 aCodMat := {}
                 aadd(aQtdMat, { 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0})
                 aadd(aCodMat, {"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
                 aadd(aVolMat, { 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0})
                 aMatIte := {}
                 nPos    := 1
                 DbSelectArea("SD4")
                 DbSetOrder(2)
                 DbSeek(xFilial("SD4")+aGerTxt[1][3], .t.)
                 If Found()
                     While !Eof() .and. Alltrim(SD4->D4_OP) == Alltrim(aGerTxt[1][3])
                         /*
                         If nPos <= 20
                            If !Alltrim(SD4->D4_COD) $ Alltrim(GETMV("MV_RETENOP"))
                               aAdd(aMatIte, {SD4->D4_QUANT, Alltrim(SD4->D4_COD), SD4->D4_QUANT / Posicione("SB1", 1, xFilial("SB1")+SD4->D4_COD, "B1_PESOESP") } )
                               //aQtdMat[1][nPos] := SD4->D4_QUANT
                               //aCodMat[1][nPos] := Alltrim(SD4->D4_COD)
                               //aVolMat[1][nPos] := SD4->D4_QUANT / Posicione("SB1", 1, xFilial("SB1")+SD4->D4_COD, "B1_PESOESP")
                               nPos += 1
                               If Posicione("SB1", 1, xFilial("SB1")+SD4->D4_COD, "B1_DOSADOR") $ 'S'
                                  lExiste := .t.
                               Endif
                            Endif
                         Endif

                         DbSelectArea("SD4")
                         DbSkip() */
                         If nPos <= 20
	                         If Substr(Posicione("SC2", 1, xFilial("SC2")+SD4->D4_OP, "C2_PRODUTO"),6,2) =='05' .and. Len(Alltrim(Posicione("SC2", 1, xFilial("SC2")+SD4->D4_OP, "C2_PRODUTO")))==12
		                        If !Posicione("SB1", 1, xFilial("SB1")+Alltrim(SD4->D4_COD), "B1_DESC") $ 'PASTA' .and. SD4->D4_QUANT >= 0.2  .AND. !U_IsProdCusto( SD4->D4_COD )
			                        aAdd(aMatIte, {SD4->D4_QUANT, Alltrim(SD4->D4_COD), SD4->D4_QUANT / Posicione("SB1", 1, xFilial("SB1")+SD4->D4_COD, "B1_PESOESP") } )
    			                    //aQtdMat[1][_nPos] := SD4->D4_QUANT
        			                //aCodMat[1][_nPos] := Alltrim(SD4->D4_COD)
            			            //aVolMat[1][_nPos] := SD4->D4_QUANT / Posicione("SB1", 1, xFilial("SB1")+SD4->D4_COD, "B1_PESOESP")
                			        nPos += 1
                             
		                	        If Posicione("SB1", 1, xFilial("SB1")+SD4->D4_COD, "B1_DOSADOR") $ 'S'
    		                           lExiste := .t.
	        	              	    Endif
	        	              	Endif
    	    	             Else
                            If !U_IsProdCusto( SD4->D4_COD )
			                    aAdd(aMatIte, {SD4->D4_QUANT, Alltrim(SD4->D4_COD), SD4->D4_QUANT / Posicione("SB1", 1, xFilial("SB1")+SD4->D4_COD, "B1_PESOESP") } )
	             		        nPos += 1
    	            	        If Posicione("SB1", 1, xFilial("SB1")+SD4->D4_COD, "B1_DOSADOR") $ 'S'
   	    	            	       lExiste := .t.
       	    	                Endif
                            Endif
	        	             Endif
                         Endif
                         DbSelectArea("SD4")
                         DbSkip() 
                     Enddo
                 Endif
                 nPos    := 1
                 aSort(aMatIte, , , { | x, y | x[3] > y[3] } )
                 For nX := 1 To Len(aMatIte)
                     If nPos <= 20
                        aQtdMat[1][nPos] := aMatIte[nX][1]
                        aCodMat[1][nPos] := aMatIte[nX][2]
                        aVolMat[1][nPos] := aMatIte[nX][3]
                        nPos += 1
                     Endif
                 Next
                 nQtdMat := 0
                 For nX := 1 To 20
                     nQtdMat += aQtdMat[1][nX]
                 Next
                 If nQtdMat <= 0
                    lNaoGer := .t.
                 Endif
                 If !lExiste
                    lNaoGer := .t.
                 Endif
                 If !lNaoGer
                    cProduto := aGerTxt[1][1]
                    cCatalis := Posicione("SB1", 1, xFilial("SB1")+aGerTXT[1][1], "B1_CATALIS")
                    dEmissao := DTOC(Stod(aGerTxt[1][4]))
                    nVolume  := aGerTxt[1][5]
                    nPeso    := aGerTxt[1][5] * Posicione("SB1", 1, xFilial("SB1")+aGerTXT[1][1], "B1_PESOESP")
                    cNumOrd  := aGerTxt[1][3]
                    cNumLot  := aGerTxt[1][2]
                    /********************************************************************************************************************/
                    If cParInf5 $ '2'
                       cPatGer := 'C:\DADOS\OP\'+SubStr(aGerTxt[1][3], 1, 6)+".DAT"
                       lContinua := .t.
                       If FILE(cPatGer)
                          If MsgYesNo("Essa Ordem de produção já tem o arquivo gerado. Sobrepõe?")
                             lContinua := .t.
                          Else
                             lContinua := .f.
                          Endif
                       Else
                          lContinua := .t.
                       Endif
                       If lContinua
                          /******************************************************************/
                          /*** MONTAGEM DO ARQUIVO TEXTO                                  ***/
                          /******************************************************************/
                          /*** Linha 1 - Código do Produto ***/
                          cLinMes := ""
                          cFab2   := ""
                          cCpoMes := Alltrim(cProduto)
                          cLinMes := Stuff(cLinMes, 001, 040, cCpoMes)+cEol
                          cFab2   += cLinMes
                          /*** Linha 2 - Descrição do produto ***/
                          cLinMes := ""
                          cCpoMes := PADR(cDescri, 040)
                          cLinMes := Stuff(cLinMes, 001, 040, cCpoMes)+cEol
                          cFab2   += cLinMes
                          /*** Linha 3 - Peso ***/
                          cLinMes := ""
                          cCpoMes := Alltrim(Stuff(TransForm(nPeso, "@E 99999.999999"), At(",", TransForm(nPeso, "@E 99999.999999")), 1, "."))
                          cLinMes := Stuff(cLinMes, 001, Len(Alltrim(cCpoMes)), cCpoMes)+cEol
                          cFab2   += cLinMes
                          /*** Linha 4 - Volume ***/
                          cLinMes := ""
                          cCpoMes := Alltrim(Stuff(TransForm(nVolume, "@E 99999.999999"), At(",", TransForm(nVolume, "@E 99999.999999")), 1, "."))
                          cLinMes := Stuff(cLinMes, 001, Len(Alltrim(cCpoMes)), cCpoMes)+cEol
                          cFab2   += cLinMes
                          /*** Linha 5 - Materias Primas ***/
                          For nX := 1 To 20
                              cLinMes := ""
                              cCpoMes := ""
                              If !Empty(aCodMat[1][nX])
                                 cCpoMes := Alltrim(aCodMat[1][nX])+' '
                              Else
                                 cCpoMes := " "
                              Endif
                              cCpoMes := PADR(Alltrim(cCpoMes), Len(Alltrim(cCpoMes)))
                              cLinMes := Stuff(cLinMes, 001, Len(Alltrim(cCpoMes)), cCpoMes)+cEol
                              cFab2   += cLinMes
                          Next
                          /*** Linha 25 - Quantidades de matérias primas ***/
                          cLinMes := ""
                          cCpoMes := ""
                          For nX := 1 To 20
                              cCpoMes += Alltrim(Stuff( TransForm(Round(aQtdMat[1][nX], 3), "@E 99999.999999"), At(",", TransForm(Round(aQtdMat[1][nX], 3), "@E 99999.999999")), 1 , "."))+' '
                          Next
                          cCpoMes := PADR(Alltrim(cCpoMes), Len(Alltrim(cCpoMes)))
                          cLinMes := Stuff(cLinMes, 001, Len(Alltrim(cCpoMes)), Alltrim(cCpoMes))+cEol
                          cFab2   += cLinMes
                          /*** Linha 26 - Quantidades de matérias primas com valor negativo ***/
                          cLinMes := ""
                          cCpoMes := ""
                          For nX := 1 To 20
                              cCpoMes += Alltrim(Stuff( TransForm((Round(aQtdMat[1][nX], 3) * (-1)), "@E 99999.999999"), At(",", TransForm((Round(aQtdMat[1][nX], 3) * (-1)), "@E 99999.999999")), 1 , "."))+' '
                          Next
                          cCpoMes := PADR(Alltrim(cCpoMes), Len(Alltrim(cCpoMes)))
                          cLinMes := Stuff(cLinMes, 001, Len(Alltrim(cCpoMes)), Alltrim(cCpoMes))+cEol
                          cFab2   += cLinMes
                          MemoWrit(cPatGer, cFab2)
                       Endif
                    Endif
                 Else
                    cPatGer := 'C:\DADOS\OP\NOVA\'+SubStr(aGerTxt[1][3], 1, 6)+".DAT"
                    If FILE(cPatGer)
                       If MsgYesNo("Essa Ordem de produção já tem o arquivo gerado. Sobrepõe?")
                          MsgStop("Rotina não desenvolvida")
                       Endif
                    Endif
                 Endif
                 
              Endif
           Endif
           If !Empty(cParInf4)
              /*********************************************/
              /*** DESMONTA CONEXÃO COM O BANCO DE DADOS ***/
              /*********************************************/
              TCQuit() //Desmonta conexão com o banco de dados
           Endif
           fAptSaiVol(2)
    Return
    
    /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ fAptSaiVol() - Verifica saida da ordem de produção ou volta para tela principal
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Static Function fAptSaiVol(nOpcApt)
           If nOpcApt == 1
              oDlg1Apt:End()
           ElseIf nOpcApt == 2
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
